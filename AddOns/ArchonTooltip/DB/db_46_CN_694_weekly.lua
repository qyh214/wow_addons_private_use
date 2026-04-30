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

local lookup = {'Druid-Balance','Paladin-Holy','Unknown-Unknown','Mage-Frost','Shaman-Elemental','Hunter-BeastMastery','Priest-Discipline','Priest-Holy','Druid-Restoration','Warrior-Protection','Warlock-Destruction','Hunter-Marksmanship','Hunter-Survival','DeathKnight-Unholy','Druid-Guardian','Paladin-Retribution','Paladin-Protection','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Blood','Monk-Windwalker','Shaman-Restoration','Warrior-Fury','Evoker-Preservation','DemonHunter-Devourer','DemonHunter-Havoc','Warlock-Demonology','Priest-Shadow',}
local provider = {region='CN',realm='摩摩尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ap='Apollo:BAAALgAECgUJBwABLgAECggJFQABAB8ZAA==.',
Ar='Arcgoat:BAAALgAECgQJBAAAAA==.',
Ba='Bakura:BAAALgAECgcJBwAAAA==.Barley:BAAALgAECgQJBAAAAA==.',
Ca='Cass:BAAALgAECgUJCAAAAA==.',
Cc='Ccl:BAAALgAECgUJCgAAAA==.Cclahs:BAAALgAECgYJBwAAAA==.',
Cu='Cuayt:BAAALgAECggJEQAAAA==.',
De='Demondemon:BAAALgAECgQJBAAAAA==.Destroyer:BAAALgAECgMJAwAAAA==.Deviltrigger:BAAALgADCgkJBwAAAA==.',
Ev='Evilputrefy:BAAALgAFFAEJAQAAAA==.',
Fe='Feb:BAAALgAECgMJAwAAAA==.',
Ho='Hoefischers:BAAALgAECgkJCQABLgAFFAYJBgACAGYWAA==.',
Ja='Jaiur:BAAALgAECgYJBgABLgAFFAQJBAADAAAAAA==.',
Mo='Morningstar:BAAALgAECgYJDAAAAA==.',
Pl='Playersranok:BAAALgADCgEJAQAAAA==.',
Qs='Qskiko:BAAALgAECgUJBQAAAA==.',
Sa='Saimage:BAABLgAFFH8MAAIEAAQJmRukBQB0AQAEAAQJmRukBQB0AQAAAA==.',
Si='Sigy:BAAALgAECgYJCwAAAA==.',
So='Somnusy:BAAALgAECgEJAQAAAA==.Soul:BAAALgAECgcJBwAAAA==.',
St='Starssea:BAAALgAECgEJAQAAAA==.',
Tr='Trease:BAAALgAECgEJAQAAAA==.',
Vv='Vviper:BAAALgAECgMJAwAAAA==.',
Wi='Winner:BAAALgAECgEJAQAAAA==.',
Ws='Wskiko:BAAALgAECgkJCQABLgAFFAcJDgAFAA8kAA==.',
Yi='Yii:BAAALgADCgEJAQAAAA==.',
['一天']='一天空之怒一:BAAALgAECgQJBAAAAA==.',
['一帅']='一帅到底:BAAALgAECgMJBgAAAA==.',
['一手']='一手好枪法丶:BAAALgAECgkJCAAAAA==.',
['一枪']='一枪成父:BAAALgAECgEJAQAAAA==.',
['七万']='七万七万:BAACLgAFFH8GAAIGAAIJYyQsDwDQAAAGAAIJYyQsDwDQAAAuAAQKfxUAAgYACAlMIrQIAAcDAAYACAlMIrQIAAcDAAAA.',
['万物']='万物皆可秀:BAAALgAECgQJCAAAAA==.',
['不丶']='不丶缺德:BAAALgAECgYJCwAAAA==.',
['不必']='不必理会:BAAALgAECgEJAQAAAA==.',
['专业']='专业刷锅:BAAALgAECgkJDwAAAA==.',
['两只']='两只拖鞋:BAAALgAECgIJAgAAAA==.',
['丨卸']='丨卸弦丨:BAAALgAFFAEJAQAAAA==.',
['二十']='二十四夜:BAAALgAFFAIJAwAAAA==.',
['二郎']='二郎戏嫂:BAAALgAECgIJAgAAAA==.',
['今夜']='今夜回忆过去:BAAALgAECgEJAQAAAA==.',
['仰望']='仰望天堂丶:BAAALgAECgEJAQAAAA==.',
['伪戒']='伪戒:BAABLgAECn8eAAIEAAkJ+RA5UgBBAgAEAAkJ+RA5UgBBAgAAAA==.',
['你别']='你别这样说:BAAALgAECgcJDQAAAA==.',
['你吃']='你吃饭了吗:BAAALgADCgkJCQAAAA==.',
['你在']='你在我身边丶:BAAALgAFFAEJAQAAAA==.',
['你才']='你才缺德:BAAALgAECgEJAQAAAA==.',
['你看']='你看那悲伤:BAAALgAECgMJCwAAAA==.',
['你真']='你真好:BAAALgADCgEJAQAAAA==.',
['你那']='你那么孤独:BAAALgAECgcJDQAAAA==.',
['依然']='依然丨嫒祢:BAABLgAECn8UAAIGAAcJNBd4OQDIAQAGAAcJNBd4OQDIAQAAAA==.',
['俞俞']='俞俞:BAAALgADCgcJBwAAAA==.',
['俞瑜']='俞瑜:BAABLgAECn8iAAMHAAcJ7xngFgDqAQAHAAcJNxjgFgDqAQAIAAQJrBXzSwAJAQAAAA==.',
['倾城']='倾城丨游侠:BAAALgAECgcJCwAAAA==.',
['假面']='假面战神:BAAALgAECgQJBgAAAA==.',
['傲神']='傲神:BAAALgADCgEJAQAAAA==.',
['傲视']='傲视:BAAALgADCgEJAQAAAA==.',
['傲骨']='傲骨铁蹄:BAABLgAECn8aAAIJAAcJ/hAeEwAyAQAJAAcJ/hAeEwAyAQAAAA==.',
['傻慢']='傻慢:BAAALgAECgEJAQAAAA==.',
['光铸']='光铸小骑:BAAALgAECgEJAQAAAA==.',
['全职']='全职猎手:BAAALgADCgYJBgAAAA==.',
['八月']='八月飞雪:BAAALgAECgQJBQAAAA==.',
['关于']='关于小熊:BAAALgADCgYJBgAAAA==.',
['再出']='再出发小萨:BAAALgADCgYJBgAAAA==.',
['凋謝']='凋謝灬玫瑰:BAAALgAECgkJBwAAAA==.',
['凋靈']='凋靈者:BAAALgADCgIJAgAAAA==.',
['凌乱']='凌乱一杀戮:BAAALgAECgMJAwAAAA==.',
['切克']='切克闹:BAAALgAECgUJBgAAAA==.',
['别奶']='别奶:BAAALgAECgEJAQAAAA==.',
['勇者']='勇者天下:BAAALgADCgUJBQAAAA==.',
['千面']='千面凤凰:BAAALgAECgQJBAAAAA==.',
['卡丽']='卡丽熙:BAAALgAECgYJEQABLgAFFAMJBgAKAA0RAA==.',
['卤煮']='卤煮加肺:BAAALgAECgEJAQAAAA==.',
['叉歪']='叉歪歪:BAAALgAECgkJEAABLgAFFAUJCQALANghAA==.',
['古尔']='古尔一老登:BAAALgAECgUJCgAAAA==.',
['古拉']='古拉加斯:BAAALgAECgcJCwAAAA==.',
['可怜']='可怜的沫沫:BAAALgAECggJAwAAAA==.',
['可雕']='可雕之木:BAABLgAECn8gAAMHAAgJshrhDABqAgAHAAgJ6xnhDABqAgAIAAUJaBZfQQAzAQAAAA==.',
['史蒂']='史蒂芬周:BAAALgAECgEJAgAAAA==.',
['叶落']='叶落無痕:BAABLgAFFH8FAAIMAAMJwgqZFgDlAAAMAAMJwgqZFgDlAAAAAA==.',
['名字']='名字嫩难起呢:BAAALgAECgcJEwAAAA==.名字嫩难起啊:BAAALgADCgEJAQAAAA==.',
['听说']='听说不好玩:BAAALgAECgEJAQAAAA==.',
['咕噜']='咕噜喵:BAAALgAECgUJBQAAAA==.',
['哆啦']='哆啦喵咪咪:BAAALgAECgMJAwAAAA==.',
['哔哩']='哔哩哔哩:BAAALgADCgEJAQAAAA==.',
['哥布']='哥布林撒手:BAABLgAECn8XAAIFAAYJThNaDgAeAQAFAAYJThNaDgAeAQAAAA==.',
['唐伯']='唐伯虎点迷香:BAAALgAECgQJBAAAAA==.唐伯虎猎风:BAABLgAECn8aAAQGAAYJpxgqRgCYAQAGAAUJsRoqRgCYAQAMAAYJxBJPRgA7AQANAAIJ3AwAAAAAAAAAAA==.',
['喞喞']='喞喞喎喎:BAAALgAECgIJAgAAAA==.',
['嗨弗']='嗨弗雷:BAAALgAECgUJBQAAAA==.',
['嘿小']='嘿小子:BAAALgAECgMJBAAAAA==.',
['圣光']='圣光归来:BAAALgADCgcJBwAAAA==.',
['基尔']='基尔:BAAALgAECgYJBgABLgAFFAUJCwAOAIwTAA==.',
['塔塔']='塔塔露:BAAALgAECgYJEgAAAA==.',
['塞拉']='塞拉斯:BAAALgAECgEJAQAAAA==.',
['夏天']='夏天天:BAAALgAECgEJAQAAAA==.',
['夏娃']='夏娃冰梦缘:BAAALgAECgIJAgAAAA==.',
['大神']='大神贼高:BAAALgAFFAIJAgAAAA==.',
['大脑']='大脑按摩:BAAALgAFFAQJBAAAAA==.',
['大铭']='大铭:BAAALgAECgYJEQAAAA==.',
['大锤']='大锤啪啪趴:BAAALgADCgYJBgAAAA==.',
['天神']='天神舞:BAAALgAFFAEJAQAAAA==.',
['太阳']='太阳萌德:BAABLgAECn8VAAMBAAgJHxnCJgDHAQABAAcJxxrCJgDHAQAPAAYJ/w8DFQAhAQAAAA==.',
['失控']='失控的灵魂:BAAALgAECgYJBgABLgAFFAcJBAADAAAAAA==.',
['奈亞']='奈亞:BAAALgADCgEJAQAAAA==.',
['奥乐']='奥乐米拉:BAAALgAECgUJBwAAAA==.',
['奶奶']='奶奶牛牛:BAAALgAECgUJBgAAAA==.',
['奶水']='奶水:BAAALgAECgYJBgAAAA==.',
['奶聋']='奶聋小宝贝:BAAALgADCgEJAQAAAA==.',
['奶茶']='奶茶:BAAALgAECgYJBQAAAA==.',
['好想']='好想闪瞎你:BAAALgAECgQJCgAAAA==.',
['妙手']='妙手丶回春:BAAALgAECgEJAQAAAA==.',
['安暖']='安暖如夏:BAAALgAECgEJAQAAAA==.',
['寒冬']='寒冬灬惜梦:BAAALgAECgEJAQAAAA==.',
['小丶']='小丶浣熊:BAAALgAECgMJAwAAAA==.',
['小小']='小小乔:BAAALgAECgEJAQAAAA==.小小怂:BAACLgAFFH8GAAIQAAIJix7uHQC1AAAQAAIJix7uHQC1AAAuAAQKfxcAAxAABwkAIvoNALsBABAABwkAIvoNALsBABEAAglKFlg0AHYAAAEuAAUUBQkKAA4ALBkA.小小鵝:BAAALgADCgUJBAAAAA==.',
['小心']='小心心:BAAALgADCgUJBQAAAA==.',
['小母']='小母龙:BAAALgAECgEJAQAAAA==.',
['小鬼']='小鬼当家:BAABLgAECn8hAAMSAAgJzyKDDQCdAgASAAgJxR6DDQCdAgATAAYJziKsCQBEAgAAAA==.',
['少然']='少然人如风:BAAALgADCgEJAQAAAA==.',
['尔非']='尔非鱼:BAAALgADCgQJBAAAAA==.',
['尤朵']='尤朵拉:BAAALgAECgQJBAAAAA==.',
['尤欧']='尤欧:BAAALgAECgEJAQAAAA==.',
['尼古']='尼古拉斯凯骑:BAAALgAECgQJBQAAAA==.',
['尼莫']='尼莫:BAAALgAECgYJDAAAAA==.',
['巴黎']='巴黎世家圣骑:BAAALgAECgUJBQAAAA==.',
['帝骑']='帝骑:BAAALgAECgUJDQAAAA==.',
['年少']='年少有点轻狂:BAAALgAECgcJCQAAAA==.',
['幻林']='幻林枫:BAAALgAECgEJAwAAAA==.',
['幽忧']='幽忧杀你玩:BAAALgAECgQJBAAAAA==.',
['弈秋']='弈秋丶:BAAALgAFFAIJAgAAAA==.',
['德不']='德不配胃:BAAALgAECgEJAgAAAA==.',
['德咕']='德咕啦:BAAALgAECgEJAgAAAA==.',
['快乐']='快乐肥仔水:BAAALgAECgUJBwAAAA==.',
['怀朔']='怀朔:BAAALgAECgEJAQAAAA==.',
['恩互']='恩互:BAAALgADCgIJAgAAAA==.',
['恶魔']='恶魔全都死:BAAALgAECgYJCgAAAA==.',
['悲伤']='悲伤的小提米:BAAALgADCgMJAwAAAA==.',
['悲酥']='悲酥清风:BAAALgAECgkJCQAAAA==.',
['愤怒']='愤怒的詾毛:BAAALgAECgMJAwAAAA==.',
['慷慨']='慷慨:BAAALgAECgYJDQAAAA==.',
['我是']='我是六娃:BAAALgAECgcJDAAAAA==.',
['我爱']='我爱丨娜娜:BAAALgAECgYJCgAAAA==.我爱梦之仙子:BAAALgAECgYJBgAAAA==.',
['戒怒']='戒怒:BAACLgAFFH8NAAMOAAUJAhULFgBLAQAOAAQJAhULFgBLAQAUAAEJAAATGQA4AAAuAAQKfyYAAg4ACQkEHesUAP4CAA4ACQkEHesUAP4CAAAA.',
['戒狂']='戒狂:BAAALgAECgYJDAAAAA==.',
['戒痴']='戒痴:BAABLgAECn8VAAIVAAkJuRFMFQBCAgAVAAkJuRFMFQBCAgAAAA==.',
['戒贪']='戒贪:BAAALgAECgkJEgAAAA==.',
['戦灬']='戦灬逍遥:BAAALgADCgkJEAAAAA==.',
['抡板']='抡板凳:BAAALgAECgEJAQAAAA==.',
['拉克']='拉克萨斯:BAABLgAFFH8GAAIWAAMJZBH6CgCXAAAWAAMJZBH6CgCXAAAAAA==.',
['拨皮']='拨皮双子:BAAALgAFFAIJBAAAAA==.',
['描边']='描边卡拉咪:BAAALgAECgEJAQAAAA==.',
['提比']='提比酱:BAAALgAECgIJAgAAAA==.',
['携秋']='携秋水揽星河:BAABLgAFFH8FAAIFAAMJ/BjrDQANAQAFAAMJ/BjrDQANAQAAAA==.',
['攒劲']='攒劲的节目:BAAALgAECgEJAQAAAA==.',
['收手']='收手吧阿汤:BAAALgAECgQJBQAAAA==.',
['放我']='放我去死:BAABLgAFFH8GAAIBAAIJUBc5EgCyAAABAAIJUBc5EgCyAAAAAA==.',
['敏敏']='敏敏特穆尔:BAAALgAECgYJAgAAAA==.',
['斩油']='斩油鸡:BAAALgAECgYJBwAAAA==.',
['断翅']='断翅邪灵:BAAALgAECgEJAQAAAA==.',
['无良']='无良小鬼:BAAALgAECgUJCwABLgAECggJIQASAM8iAA==.',
['星月']='星月女神:BAAALgAECgcJBwAAAA==.',
['晓法']='晓法:BAAALgAECgUJDgAAAA==.',
['曉宇']='曉宇:BAABLgAECn8hAAIPAAgJ/hEcDwCLAQAPAAgJ/hEcDwCLAQAAAA==.',
['月色']='月色朦朦:BAAALgAECgIJAQAAAA==.',
['末日']='末日灵舞:BAAALgAECgIJAgAAAA==.',
['本特']='本特利:BAAALgADCgYJBgAAAA==.',
['本间']='本间葵:BAAALgAECggJCQAAAA==.',
['杀戮']='杀戮德:BAAALgAECgYJBwAAAA==.',
['村东']='村东一老登:BAAALgADCgUJBQAAAA==.',
['東風']='東風谷早苗:BAACLgAFFH8LAAIFAAQJ9hrbBwBcAQAFAAQJ9hrbBwBcAQAuAAQKfxoAAgUACAlsIPUKAOcCAAUACAlsIPUKAOcCAAAA.',
['枸丶']='枸丶杞:BAAALgADCgMJAwAAAA==.',
['柑橘']='柑橘栀子花:BAAALgADCgIJAgAAAA==.',
['核桃']='核桃露露:BAAALgADCgEJAgAAAA==.',
['桂丶']='桂丶圆:BAAALgAFFAEJAgAAAA==.',
['梦尐']='梦尐姐丶:BAAALgADCgUJBQABLgAFFAIJBgAXACMSAA==.',
['梦追']='梦追梦:BAABLgAECn8VAAIEAAgJ6Q2NiQC/AQAEAAgJ6Q2NiQC/AQAAAA==.',
['梧桐']='梧桐树:BAAALgADCgUJBQAAAA==.',
['榴链']='榴链味:BAAALgAFFAIJBAAAAA==.',
['槐序']='槐序:BAAALgAECgcJCgAAAA==.',
['死乂']='死乂亡:BAACLgAFFH8KAAIOAAUJLBkgBgCiAQAOAAUJLBkgBgCiAQAuAAQKfxkAAg4ABwk5HQEMAMMBAA4ABwk5HQEMAMMBAAAA.',
['沉睡']='沉睡:BAAALgAFFAEJAQAAAA==.',
['法司']='法司:BAAALgAECgIJAwAAAA==.',
['泣血']='泣血丶:BAAALgAECgQJBAAAAA==.',
['洁盈']='洁盈:BAAALgAECgUJBgAAAA==.',
['洋唐']='洋唐僧:BAAALgADCgUJBQAAAA==.',
['活宝']='活宝他姐:BAAALgAECgYJCwAAAA==.',
['流水']='流水无情丶:BAAALgAECgEJAgAAAA==.',
['浣纱']='浣纱溪:BAAALgAECgEJAQAAAA==.',
['浮云']='浮云沉香丶:BAAALgAECgUJDQAAAA==.',
['清野']='清野凛:BAAALgADCgUJBQAAAA==.',
['灬冰']='灬冰美式灬:BAAALgAECgIJAgAAAA==.',
['灬碧']='灬碧空痕灬:BAAALgAECgcJCgAAAA==.',
['灬笑']='灬笑丶红颜:BAAALgAECgEJAwAAAA==.',
['灵魂']='灵魂丶冰糖:BAAALgAECgYJBgAAAA==.灵魂丶彼岸:BAAALgAECgYJBgAAAA==.灵魂丶碎裂:BAAALgAECgcJBwABLgAFFAUJCwAOAIwTAA==.',
['烟水']='烟水寒:BAAALgAECgQJBQAAAA==.',
['烬末']='烬末离殇:BAAALgAFFAEJAQAAAA==.',
['熊猫']='熊猫灬小妞:BAAALgAECggJDwAAAA==.',
['爱到']='爱到疯的:BAAALgAECgEJAgAAAA==.',
['牛牛']='牛牛嗜血:BAAALgADCgYJBgAAAA==.',
['狐开']='狐开山:BAAALgADCgMJAgAAAA==.',
['独宠']='独宠:BAAALgAECgEJAQAAAA==.',
['猪猪']='猪猪向前跑:BAAALgAECgIJAwAAAA==.',
['猫大']='猫大虓:BAAALgAECgEJAQAAAA==.',
['玩闹']='玩闹小裤衩:BAAALgAECgEJAgAAAA==.',
['瑾年']='瑾年丨七章:BAAALgAECgUJBwABLgAFFAUJBgAYAHsWAA==.',
['瓦藜']='瓦藜拉:BAAALgAECgEJAQAAAA==.',
['白白']='白白更健康:BAAALgAECgYJCQAAAA==.',
['白羊']='白羊丶:BAACLgAFFH8MAAIZAAQJqApyFAAvAQAZAAQJqApyFAAvAQAuAAQKfx4AAxkACAk6FxQ8AAQCABkACAlWFRQ8AAQCABoABAn3ErBHANUAAAAA.',
['白菜']='白菜大王:BAAALgAFFAEJAQAAAA==.',
['白驹']='白驹过隙:BAAALgAECgQJBQAAAA==.',
['短裤']='短裤:BAAALgAECgQJCAAAAA==.',
['矮壮']='矮壮壮:BAAALgAECgEJAwAAAA==.',
['神都']='神都老道:BAAALgAECgUJBgAAAA==.',
['立风']='立风:BAAALgAECgkJCQAAAA==.',
['笑的']='笑的比花甜:BAAALgAECgEJAwAAAA==.',
['粉色']='粉色:BAABLgAFFH8FAAICAAIJBCV4BwDHAAACAAIJBCV4BwDHAAAAAA==.',
['红丶']='红丶枣:BAAALgADCgYJCQAAAA==.',
['红色']='红色狐狸:BAAALgAECgYJBwAAAA==.',
['绝对']='绝对反冲:BAAALgAFFAIJAgAAAA==.',
['绵鱼']='绵鱼:BAAALgAECgEJAgAAAA==.',
['美国']='美国的华莱士:BAABLgAFFH8HAAIbAAMJQArVJADvAAAbAAMJQArVJADvAAABLgAFFAQJCgAOAB4XAA==.',
['老哥']='老哥稳:BAAALgAECgEJAQAAAA==.',
['老婆']='老婆最好:BAAALgAECgQJBAAAAA==.',
['老鼠']='老鼠小弟:BAAALgADCgIJAgAAAA==.',
['聖光']='聖光小怪獸:BAAALgAECgcJDQAAAA==.',
['聪明']='聪明的小脑袋:BAAALgAECgkJCgAAAA==.',
['胡恩']='胡恩高岭:BAAALgAECgUJBQAAAA==.',
['腰若']='腰若流纨素:BAAALgAECgEJAgAAAA==.',
['色丶']='色丶欲:BAAALgAECgQJBAAAAA==.',
['芋圆']='芋圆葡萄:BAAALgAECgQJBQAAAA==.',
['芭芭']='芭芭拉:BAAALgAECgQJBgAAAA==.',
['花裤']='花裤衩之無双:BAAALgAECgcJDQAAAA==.',
['英特']='英特纳雄奈尔:BAAALgAECgEJAQAAAA==.',
['茕茕']='茕茕白兔丶:BAAALgAECgYJDAAAAA==.',
['荡世']='荡世灬美梅:BAAALgAECgEJAQAAAA==.',
['落日']='落日归山海:BAAALgAECgcJBwAAAA==.',
['薛定']='薛定谔的圣光:BAAALgAECgEJAQAAAA==.',
['虎杖']='虎杖悠仁:BAAALgAECgYJBgAAAA==.',
['蜗牛']='蜗牛也是牛:BAAALgADCgIJAgAAAA==.',
['裴珠']='裴珠泫:BAAALgAFFAIJBAABLgAFFAQJBAADAAAAAA==.',
['说爱']='说爱你:BAAALgAECgQJBAAAAA==.',
['谈笑']='谈笑风生:BAACLgAFFH8KAAIOAAQJHhcSBAByAQAOAAQJHhcSBAByAQAuAAQKfx8AAg4ACAnqHcAgAL4CAA4ACAnqHcAgAL4CAAAA.',
['豪门']='豪门绝恋:BAAALgADCgEJAQAAAA==.',
['贝塔']='贝塔:BAAALgADCgUJCAAAAA==.',
['贴身']='贴身小护:BAAALgAECgEJAQAAAA==.贴身小蜜:BAAALgAECgEJAwAAAA==.',
['走马']='走马观花:BAAALgADCgEJAQAAAA==.',
['超级']='超级大法师:BAAALgAECgkJCQAAAA==.',
['辉煌']='辉煌嗳呦喂:BAAALgADCgUJBQAAAA==.',
['辐射']='辐射怪:BAAALgAECgQJBgAAAA==.',
['还真']='还真是:BAAALgAECgUJCAAAAA==.',
['逍遥']='逍遥臭臭:BAAALgAECgUJBwAAAA==.',
['邪痕']='邪痕:BAAALgAECgIJAgAAAA==.',
['醉丶']='醉丶春风:BAAALgAECgMJAwAAAA==.',
['野生']='野生小凹凸曼:BAAALgAECgkJBwAAAA==.',
['野空']='野空:BAAALgAECgUJBgAAAA==.',
['阿尔']='阿尔德古亞:BAAALgADCgIJAgAAAA==.阿尔德尼亚:BAEALgAECggJDgAAAA==.',
['阿拉']='阿拉蕾囧:BAAALgAECgUJBgAAAA==.',
['阿斯']='阿斯特蕾娅:BAAALgAECgIJAwAAAA==.',
['阿苏']='阿苏焉:BAAALgAECgIJAgAAAA==.',
['陈秋']='陈秋池:BAAALgAECgQJBAAAAA==.',
['降龙']='降龙一巴掌:BAAALgAFFAEJAgAAAA==.',
['雕你']='雕你妹:BAABLgAECn8gAAIcAAgJ+xx5EQByAgAcAAgJ+xx5EQByAgAAAA==.',
['雨落']='雨落星河:BAABLgAFFH8JAAIbAAMJPgy5JADwAAAbAAMJPgy5JADwAAAAAA==.',
['飞雪']='飞雪星尘:BAAALgAECgIJAgAAAA==.',
['香风']='香风智乃:BAAALgADCgIJAgAAAA==.',
['鮮血']='鮮血哀川凜:BAAALgAECgYJEgAAAA==.',
['鲜血']='鲜血丶荣耀:BAAALgAECgEJAQAAAA==.',
['鲨鱼']='鲨鱼饵丶:BAACLgAFFH8FAAIOAAMJhQrDLADoAAAOAAMJhQrDLADoAAAuAAQKfyMAAg4ACAnaIyIMADkDAA4ACAnaIyIMADkDAAAA.',
['麽啊']='麽啊:BAAALgADCgEJAQAAAA==.',
['黄忠']='黄忠:BAAALgADCgMJAwAAAA==.',
['黄昏']='黄昏星:BAAALgAECgEJAQAAAA==.',
['黑皮']='黑皮娃娃:BAAALgAECgIJAgAAAA==.',
['龍希']='龍希尔:BAACLgAFFH8RAAIYAAYJsBJOAgAAAgAYAAYJsBJOAgAAAgAuAAQKfykABBgACQmBG2cFAPQCABgACQmBG2cFAPQCABIACQn0GVgBAHgCABMAAwkQFHguAKUAAAAA.',
['龙村']='龙村老叔:BAAALgADCgYJCwAAAA==.',
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
