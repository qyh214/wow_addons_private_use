local V2_TAG_NUMBER = 4

---@param v2Rankings ProviderProfileV2Rankings
---@return ProviderProfileSpec
local function convertRankingsToV1Format(v2Rankings, difficultyId, sizeId)
	---@type ProviderProfileSpec
	local v1Rankings = {}
	v1Rankings.progress = v2Rankings.progressKilled
	v1Rankings.total = v2Rankings.progressPossible
	v1Rankings.average = v2Rankings.bestAverage
	v1Rankings.spec = v2Rankings.spec
	v1Rankings.asp = v2Rankings.allStarPoints
	v1Rankings.rank = v2Rankings.allStarRank
	v1Rankings.difficulty = difficultyId
	v1Rankings.size = sizeId

	v1Rankings.encounters = {}
	for id, encounter in pairs(v2Rankings.encountersById) do
		v1Rankings.encounters[id] = {
			kills = encounter.kills,
			best = encounter.best,
		}
	end

	return v1Rankings
end

---Convert a v2 profile to a v1 profile
---@param v2 ProviderProfileV2
---@return ProviderProfile
local function convertToV1Format(v2)
	---@type ProviderProfile
	local v1 = {}
	v1.subscriber = v2.isSubscriber
	v1.perSpec = {}

	if v2.summary ~= nil then
		v1.progress = v2.summary.progressKilled
		v1.total = v2.summary.progressPossible
		v1.totalKillCount = v2.summary.totalKills
		v1.difficulty = v2.summary.difficultyId
		v1.size = v2.summary.sizeId
	else
		local bestSection = v2.sections[1]
		v1.progress = bestSection.anySpecRankings.progressKilled
		v1.total = bestSection.anySpecRankings.progressPossible
		v1.average = bestSection.anySpecRankings.bestAverage
		v1.totalKillCount = bestSection.totalKills
		v1.difficulty = bestSection.difficultyId
		v1.size = bestSection.sizeId
		v1.anySpec = convertRankingsToV1Format(bestSection.anySpecRankings, bestSection.difficultyId, bestSection.sizeId)
		for i, rankings in pairs(bestSection.perSpecRankings) do
			v1.perSpec[i] = convertRankingsToV1Format(rankings, bestSection.difficultyId, bestSection.sizeId)
		end
		v1.encounters = v1.anySpec.encounters
	end

	if v2.mainCharacter ~= nil then
		v1.mainCharacter = {}
		v1.mainCharacter.spec = v2.mainCharacter.spec
		v1.mainCharacter.average = v2.mainCharacter.bestAverage
		v1.mainCharacter.difficulty = v2.mainCharacter.difficultyId
		v1.mainCharacter.size = v2.mainCharacter.sizeId
		v1.mainCharacter.progress = v2.mainCharacter.progressKilled
		v1.mainCharacter.total = v2.mainCharacter.progressPossible
		v1.mainCharacter.totalKillCount = v2.mainCharacter.totalKills
	end

	return v1
end

---Parse a single set of rankings from `state`
---@param decoder BitDecoder
---@param state ParseState
---@param lookup table<number, string>
---@return ProviderProfileV2Rankings
local function parseRankings(decoder, state, lookup)
	---@type ProviderProfileV2Rankings
	local result = {}
	result.spec = decoder.decodeString(state, lookup)
	result.progressKilled = decoder.decodeInteger(state, 1)
	result.progressPossible = decoder.decodeInteger(state, 1)
	result.bestAverage = decoder.decodePercentileFixed(state)
	result.allStarRank = decoder.decodeInteger(state, 3)
	result.allStarPoints = decoder.decodeInteger(state, 2)

	local encounterCount = decoder.decodeInteger(state, 1)
	result.encountersById = {}
	for i = 1, encounterCount do
		local id = decoder.decodeInteger(state, 4)
		local kills = decoder.decodeInteger(state, 2)
		local best = decoder.decodeInteger(state, 1)
		local isHidden = decoder.decodeBoolean(state)

		result.encountersById[id] = { kills = kills, best = best, isHidden = isHidden }
	end

	return result
end

---Parse a binary-encoded data string into a provider profile
---@param decoder BitDecoder
---@param content string
---@param lookup table<number, string>
---@param formatVersion number
---@return ProviderProfile|ProviderProfileV2|nil
local function parse(decoder, content, lookup, formatVersion) -- luacheck: ignore 211
	-- For backwards compatibility. The existing addon will leave this as nil
	-- so we know to use the old format. The new addon will specify this as 2.
	formatVersion = formatVersion or 1
	if formatVersion > 2 then
		return nil
	end

	---@type ParseState
	local state = { content = content, position = 1 }

	local tag = decoder.decodeInteger(state, 1)
	if tag ~= V2_TAG_NUMBER then
		return nil
	end

	---@type ProviderProfileV2
	local result = {}
	result.isSubscriber = decoder.decodeBoolean(state)
	result.summary = nil
	result.sections = {}
	result.progressOnly = false
	result.mainCharacter = nil

	local sectionsCount = decoder.decodeInteger(state, 1)
	if sectionsCount == 0 then
		---@type ProviderProfileV2Summary
		local summary = {}
		summary.zoneId = decoder.decodeInteger(state, 2)
		summary.difficultyId = decoder.decodeInteger(state, 1)
		summary.sizeId = decoder.decodeInteger(state, 1)
		summary.progressKilled = decoder.decodeInteger(state, 1)
		summary.progressPossible = decoder.decodeInteger(state, 1)
		summary.totalKills = decoder.decodeInteger(state, 2)

		result.summary = summary
	else
		for i = 1, sectionsCount do
			---@type ProviderProfileV2Section
			local section = {}
			section.zoneId = decoder.decodeInteger(state, 2)
			section.difficultyId = decoder.decodeInteger(state, 1)
			section.sizeId = decoder.decodeInteger(state, 1)
			section.partitionId = decoder.decodeInteger(state, 1) - 128
			section.totalKills = decoder.decodeInteger(state, 2)

			local specCount = decoder.decodeInteger(state, 1)
			section.anySpecRankings = parseRankings(decoder, state, lookup)

			section.perSpecRankings = {}
			for j = 1, specCount - 1 do
				local specRankings = parseRankings(decoder, state, lookup)
				table.insert(section.perSpecRankings, specRankings)
			end

			table.insert(result.sections, section)
		end
	end

	local hasMainCharacter = decoder.decodeBoolean(state)
	if hasMainCharacter then
		---@type ProviderProfileV2MainCharacter
		local mainCharacter = {}
		mainCharacter.zoneId = decoder.decodeInteger(state, 2)
		mainCharacter.difficultyId = decoder.decodeInteger(state, 1)
		mainCharacter.sizeId = decoder.decodeInteger(state, 1)
		mainCharacter.progressKilled = decoder.decodeInteger(state, 1)
		mainCharacter.progressPossible = decoder.decodeInteger(state, 1)
		mainCharacter.totalKills = decoder.decodeInteger(state, 2)
		mainCharacter.spec = decoder.decodeString(state, lookup)
		mainCharacter.bestAverage = decoder.decodePercentileFixed(state)

		result.mainCharacter = mainCharacter
	end

	local progressOnly = decoder.decodeBoolean(state)
	result.progressOnly = progressOnly

	if formatVersion == 1 then
		return convertToV1Format(result)
	end

	return result
end
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Warrior-Fury','Warrior-Protection','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','DeathKnight-Unholy','Unknown-Unknown','Hunter-BeastMastery','Druid-Restoration','Monk-Brewmaster','DemonHunter-Havoc','Mage-Frost','Mage-Fire','Mage-Arcane','Paladin-Holy','Hunter-Marksmanship','Priest-Shadow',}
local provider = {region='CN',realm='毁灭之锤',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Aldrich:BAAALgAFFAEJAQAAAA==.',
Az='Azurophia:BAAALgADCgEJAQAAAA==.',
Ba='Bakeles:BAAALgADCgUJBQAAAA==.',
Bu='Burberry:BAAALgADCgEJAQAAAA==.',
Ca='Casdruid:BAAALgAECgEJAwAAAA==.Casnn:BAACLgAFFH8GAAMBAAIJVA/rGAClAAABAAIJVA/rGAClAAACAAIJlwUAAAAAAAAuAAQKfxwAAwEABwnfGhssAAQCAAEABwlzGhssAAQCAAIABQnADEgqAO4AAAAA.',
Ch='Chopper:BAAALgADCgEJAgAAAA==.',
Ei='Eilmaris:BAAALgADCgEJAQAAAA==.',
Er='Error:BAAALgAECgUJBQAAAA==.',
Fe='Felslayer:BAABLgAECn8bAAQDAAgJWhkobACJAQADAAcJcRgobACJAQAEAAMJmhaGMgDuAAAFAAEJAAAeKwBJAAAAAA==.',
Ha='Hanslanda:BAAALgAECgMJAwAAAA==.',
In='Int:BAAALgAECgUJBwAAAA==.Intpall:BAAALgAECgMJAwAAAA==.',
Md='Mdga:BAAALgAECgIJAQAAAA==.',
Mi='Mingzic:BAACLgAFFH8WAAIGAAYJ1SSjAABlAgAGAAYJ1SSjAABlAgAuAAQKfxoAAgYACQm0JXQCALQDAAYACQm0JXQCALQDAAAA.',
Or='Orton:BAAALgAECgUJCAAAAA==.',
Pr='Pride:BAAALgAFFAQJBAAAAA==.',
Ri='Richarcheung:BAAALgAFFAMJAwAAAA==.Richarchueng:BAAALgAECgYJBgAAAA==.Richarxt:BAAALgAECgcJBwAAAA==.',
Sm='Smite:BAAALgAECgMJAwAAAA==.',
St='Stronger:BAAALgAECgUJBQAAAA==.',
Su='Supermission:BAAALgAECgEJAQAAAA==.',
Te='Tezukaj:BAAALgAFFAMJBAAAAA==.',
Tt='Ttoweringo:BAAALgAFFAEJAQAAAA==.',
Ve='Veermicelli:BAAALgAFFAEJAQAAAA==.Verrmicelli:BAAALgAFFAIJAwAAAA==.',
['一眼']='一眼电死你:BAAALgAECgQJBAAAAA==.',
['七一']='七一夜:BAAALgAECgUJBwAAAA==.',
['七乂']='七乂夜:BAAALgAECgcJCwABLgAFFAcJDQACAM4ZAA==.',
['不复']='不复之血:BAAALgAECgcJBgAAAA==.',
['与歌']='与歌:BAAALgAECgEJAQAAAA==.',
['专业']='专业千年杀:BAAALgAECgMJAwAAAA==.',
['丨袜']='丨袜子丨:BAAALgAECgMJBgAAAA==.',
['临兵']='临兵斗者:BAAALgAECgYJEgAAAA==.',
['云冶']='云冶:BAAALgAECgYJDAAAAA==.',
['云治']='云治:BAAALgAECgYJDAAAAA==.',
['京城']='京城蚀血者:BAAALgAECgEJAQAAAA==.',
['何处']='何处有此境:BAAALgADCgcJBwAAAA==.',
['元素']='元素大师:BAAALgADCgQJBgAAAA==.',
['全幺']='全幺九:BAABLgAFFH8IAAIGAAQJyAeIHQArAQAGAAQJyAeIHQArAQAAAA==.',
['八十']='八十:BAAALgAECgQJBAABLgAECgYJEgAHAAAAAA==.',
['冻住']='冻住不洗脚:BAAALgAECgEJAwAAAA==.',
['凶猛']='凶猛大狐狸:BAAALgAECgUJBQAAAA==.',
['卡洛']='卡洛斯:BAAALgADCgYJBgAAAA==.',
['吃葱']='吃葱不吃蒜:BAAALgADCgMJAwAAAA==.',
['后羿']='后羿射曰:BAAALgADCgcJBwAAAA==.',
['吼吼']='吼吼牛:BAAALgAECgEJAQAAAA==.',
['命萧']='命萧疏:BAABLgAFFH8LAAIGAAUJLg27CgB9AQAGAAUJLg27CgB9AQAAAA==.',
['咒咒']='咒咒:BAAALgAECgUJBQAAAA==.',
['哈登']='哈登:BAAALgAECgYJCgAAAA==.',
['啊闹']='啊闹之术:BAAALgAFFAIJAgAAAA==.',
['嗜血']='嗜血蓝天:BAAALgAECgYJEAAAAA==.',
['圣灵']='圣灵武士灭魔:BAAALgADCgUJBQAAAA==.',
['墨鱼']='墨鱼小鼻嘎:BAAALgAECgEJAQAAAA==.',
['夜无']='夜无双:BAAALgAECgYJDgAAAA==.',
['大炮']='大炮:BAABLgAECn8YAAIIAAcJbR5XHwBJAgAIAAcJbR5XHwBJAgAAAA==.',
['天殇']='天殇之萨:BAAALgAECgEJAgAAAA==.',
['天蓝']='天蓝毛衣:BAAALgADCgYJBgAAAA==.',
['太刀']='太刀川美美:BAAALgAECgcJDgABLgAECgkJFAAJAC8kAA==.',
['小和']='小和尚一:BAABLgAFFH8JAAIJAAUJOwq5BgBrAQAJAAUJOwq5BgBrAQABLgAFFAcJDwAJAJIXAA==.小和尚三:BAABLgAFFH8GAAIJAAUJmg61BQB9AQAJAAUJmg61BQB9AQABLgAFFAcJDwAJAJIXAA==.小和尚五:BAABLgAFFH8IAAIJAAUJPRMFBAChAQAJAAUJPRMFBAChAQAAAA==.',
['小蒙']='小蒙奇:BAAALgAECgYJCAAAAA==.',
['小豪']='小豪猪:BAAALgAECgEJAQAAAA==.',
['巴恩']='巴恩:BAAALgAECgYJCAAAAA==.',
['帅萌']='帅萌:BAAALgAECgQJAwAAAA==.',
['广寒']='广寒月清冷:BAAALgAECgQJBQAAAA==.',
['忙忙']='忙忙璐璐:BAAALgAECgQJBAAAAA==.',
['惩戒']='惩戒天堂:BAAALgAECgEJAgAAAA==.',
['想我']='想我没:BAAALgAECgQJBQAAAA==.',
['感谢']='感谢米圣:BAAALgAECgYJCwAAAA==.',
['战灵']='战灵儿:BAAALgADCgEJAQAAAA==.',
['指环']='指环刹海五号:BAAALgAFFAQJBAAAAA==.指环宝山二号:BAAALgAFFAQJBAAAAA==.指环尖子一号:BAABLgAFFH8MAAIGAAUJywbIDwBiAQAGAAUJywbIDwBiAQAAAA==.指环无影三号:BAAALgAFFAQJBAAAAA==.指环海盗四号:BAABLgAFFH8GAAIGAAUJnQU+EABgAQAGAAUJnQU+EABgAQAAAA==.指环狂龙六号:BAAALgAFFAQJBAAAAA==.',
['无名']='无名王者:BAAALgAECgEJAQAAAA==.',
['既判']='既判力:BAABLgAFFH8IAAIGAAQJKQqcHAAwAQAGAAQJKQqcHAAwAQAAAA==.',
['杀光']='杀光日夲鬼子:BAAALgAECgUJBQAAAA==.',
['杨哥']='杨哥归来:BAAALgAECgQJBgAAAA==.',
['柚子']='柚子不太可爱:BAABLgAFFH8HAAIJAAUJMhOiBACUAQAJAAUJMhOiBACUAQAAAA==.',
['梁欢']='梁欢:BAABLgAECn8WAAIKAAkJ3CFRAgB3AwAKAAkJ3CFRAgB3AwAAAA==.',
['欧阳']='欧阳非凡:BAABLgAFFH8FAAIDAAIJjxiOLwCzAAADAAIJjxiOLwCzAAAAAA==.',
['死了']='死了就安心了:BAAALgAECgEJAQAAAA==.',
['毁灭']='毁灭女魔头:BAAALgADCgEJAQAAAA==.',
['水晶']='水晶:BAAALgADCgMJAwAAAA==.',
['氺丶']='氺丶龙人:BAAALgAECgEJAQAAAA==.',
['氺火']='氺火:BAAALgAECgYJDgAAAA==.',
['泡泡']='泡泡无奈:BAAALgAECgYJBgAAAA==.',
['涟漪']='涟漪凛冬:BAAALgAECgkJBgABLgAFFAQJBgALAK0eAA==.',
['溪子']='溪子山丶:BAAALgAECgEJAQAAAA==.',
['满江']='满江红:BAAALgAECgIJAgAAAA==.',
['灭团']='灭团剩骑士:BAAALgAECgUJBQAAAA==.',
['爬墙']='爬墙头等红杏:BAAALgAECgEJAgAAAA==.',
['牛逼']='牛逼:BAAALgAFFAIJAgAAAA==.',
['王龙']='王龙霸:BAABLgAECn8cAAQMAAgJcSR4LgC4AgAMAAcJFSR4LgC4AgANAAQJpBwZBgBHAQAOAAEJlyYtFQB0AAAAAA==.',
['瑞查']='瑞查儿:BAAALgAECgEJAQABLgAFFAUJDwAPAAEjAA==.',
['皿众']='皿众何:BAAALgAECgkJEAAAAA==.',
['碧火']='碧火蓝天:BAAALgAECgMJAwAAAA==.',
['神圣']='神圣大狐狸:BAAALgAECgUJBQAAAA==.',
['糖醋']='糖醋丶排骨:BAAALgAECgEJAQAAAA==.',
['紫盒']='紫盒子:BAAALgAECgYJDgAAAA==.',
['紫露']='紫露凝香:BAAALgAECgcJBwAAAA==.',
['织光']='织光者卡洛斯:BAAALgADCgkJCQAAAA==.',
['给力']='给力:BAAALgAECgUJBQAAAA==.',
['羿杉']='羿杉:BAAALgAECgUJBQAAAA==.',
['老公']='老公说我胖了:BAAALgAECgIJAgAAAA==.',
['老实']='老实人:BAAALgAECgkJEAAAAA==.',
['艾利']='艾利桑德:BAAALgADCgEJAQAAAA==.',
['花倾']='花倾城:BAAALgAECgEJAQAAAA==.',
['花枪']='花枪:BAAALgAECgkJCAABLgAFFAcJBQAMANIGAA==.',
['花落']='花落丶:BAAALgAECgYJBgAAAA==.',
['菜鸟']='菜鸟驿站:BAAALgAECgYJBgAAAA==.',
['萌荳']='萌荳:BAAALgAECgEJAQAAAA==.',
['萌萌']='萌萌的汤圆:BAAALgADCgIJAgAAAA==.',
['葉問']='葉問:BAAALgAECgMJAgABLgAECgUJCwAHAAAAAA==.',
['蓝盒']='蓝盒子:BAAALgAECgUJBQAAAA==.',
['薄荷']='薄荷水:BAAALgAECgEJAQAAAA==.',
['藏神']='藏神合朔:BAAALgAECgIJAgAAAA==.',
['虎皮']='虎皮猫大人:BAAALgAECgEJAQAAAA==.',
['血霸']='血霸王:BAAALgAECgQJBAAAAA==.',
['誓约']='誓约胜利之剑:BAAALgAECgEJAgAAAA==.',
['谷雨']='谷雨春深:BAAALgAECgYJCAAAAA==.',
['贝贝']='贝贝呗极星:BAAALgAFFAQJBAAAAA==.',
['距离']='距离不够:BAAALgAECgYJBgAAAA==.',
['跳跃']='跳跃音符:BAAALgADCgYJBQAAAA==.',
['轻舟']='轻舟逐雨:BAAALgAECgEJAgABLgAECgUJBgAHAAAAAA==.',
['迷人']='迷人牛大侠:BAAALgAECgMJAwAAAA==.',
['逍遥']='逍遥自得:BAAALgAECgYJCgABLgAECgYJEAAHAAAAAA==.',
['都别']='都别动我来抗:BAAALgAECgIJAgAAAA==.',
['酒醉']='酒醉灬花下眠:BAAALgAECgcJDgAAAA==.',
['阿扬']='阿扬教授:BAAALgAECgQJBgAAAA==.',
['随便']='随便你莽:BAAALgADCgUJBQAAAA==.',
['随缘']='随缘枫:BAAALgAECgEJAQAAAA==.',
['随风']='随风而行:BAAALgAECgcJBwAAAA==.',
['雅吼']='雅吼吼:BAAALgAECgcJCwAAAA==.',
['雪雪']='雪雪儿:BAAALgAECgIJAgAAAA==.',
['雷公']='雷公助我:BAAALgADCgIJAgAAAA==.',
['霜寒']='霜寒之月:BAAALgAFFAQJBAAAAA==.',
['青乄']='青乄黛:BAAALgAECgkJBgABLgAFFAUJBwAQALciAA==.',
['青原']='青原一智羊羊:BAAALgAECgYJBwAAAA==.',
['青雀']='青雀:BAAALgAECgYJDwAAAA==.',
['面包']='面包奥:BAAALgADCgYJBgAAAA==.',
['颜爆']='颜爆一法湿:BAAALgADCgMJAwAAAA==.',
['风影']='风影六翼:BAAALgAECgQJBAAAAA==.',
['香槟']='香槟拉菲:BAAALgAECgYJEAAAAA==.',
['骑手']='骑手战鹰:BAAALgADCgEJAQAAAA==.',
['高耸']='高耸之源:BAAALgAFFAEJAQAAAA==.',
['魔戒']='魔戒渴望五号:BAABLgAFFH8FAAIGAAUJAQLxEwBSAQAGAAUJAQLxEwBSAQAAAA==.魔戒烈焰七号:BAABLgAFFH8QAAIGAAUJERXEBwCTAQAGAAUJERXEBwCTAQAAAA==.魔戒狂怒一号:BAABLgAFFH8FAAIGAAUJ3gdmDAByAQAGAAUJ3gdmDAByAQAAAA==.魔戒玉缘三号:BAAALgAECggJCAAAAA==.魔戒雄狮六号:BAAALgAFFAQJBAAAAA==.魔戒魔穴二号:BAAALgAECgcJBwAAAA==.',
['黑白']='黑白下午茶:BAABLgAECn8bAAIRAAgJ4RsuAwAJAgARAAgJ4RsuAwAJAgAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
