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

local lookup = {'Priest-Shadow','Priest-Discipline','Priest-Holy','Druid-Balance','Druid-Restoration','Evoker-Devastation','Evoker-Augmentation','Rogue-Subtlety','Monk-Windwalker','Unknown-Unknown','Paladin-Retribution','Paladin-Protection','Hunter-BeastMastery','Monk-Mistweaver','Hunter-Marksmanship','Shaman-Restoration','Warlock-Demonology','Warrior-Fury','Warrior-Arms','Warlock-Destruction','Shaman-Elemental','Mage-Frost','DeathKnight-Unholy','DeathKnight-Blood','Hunter-Survival','DemonHunter-Vengeance','DemonHunter-Devourer','Paladin-Holy','Monk-Brewmaster','Warrior-Protection','Warlock-Affliction','DemonHunter-Havoc','Evoker-Preservation',}
local provider = {region='CN',realm='古尔丹',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Ams:BAAALgAECgcJBwAAAA==.',
Ar='Arpanda:BAACLgAFFH8cAAMBAAcJqx5HAACwAgABAAcJqx5HAACwAgACAAIJfgoRCQCOAAAuAAQKfywABAEACQmuJMIAANgDAAEACQmuJMIAANgDAAIABgnJCn8+ALkAAAMAAgnjC+0cAEEAAAAA.',
Bl='Bladefury:BAAALgAECgMJAwAAAA==.',
Cl='Clawie:BAAALgAECgYJEAAAAA==.',
Cu='Cujohjolyne:BAAALgAFFAIJBAAAAA==.',
Da='Dadimama:BAACLgAFFH8KAAIEAAQJYgriCwAsAQAEAAQJYgriCwAsAQAuAAQKfxoAAwQACAksG1oUAHACAAQACAksG1oUAHACAAUABAncFqmBANYAAAAA.',
Df='Dfka:BAAALgAECgEJAwAAAA==.',
Dh='Dhqaq:BAAALgAECgkJCgAAAA==.',
Dr='Dracoaltais:BAACLgAFFH8bAAMGAAcJcSISAACzAQAHAAUJ6hgwBADPAQAGAAUJZSQSAACzAQAuAAQKfxsAAwYACQljJdwAAG0DAAYACAn4JdwAAG0DAAcAAgnOIaxEAMsAAAAA.',
Ec='Eclipse:BAAALgAECgcJEwAAAA==.',
En='Entarovarian:BAAALgAECgEJAQAAAA==.',
Er='Eripmav:BAACLgAFFH8GAAIIAAMJswSTDwD0AAAIAAMJswSTDwD0AAAuAAQKfxkAAggABwmHFw0cAB8CAAgABwmHFw0cAB8CAAAA.',
Et='Ethereal:BAAALgAECgcJDQABLgAFFAQJBQAJABEMAA==.',
Fa='Faceshot:BAAALgADCgEJAQAAAA==.Faerie:BAAALgAECgEJAQABLgAECgYJDgAKAAAAAA==.',
Ho='Holybringer:BAABLgAECn8ZAAILAAgJFSSSCABPAwALAAgJFSSSCABPAwAAAA==.',
Hu='Hunteanger:BAAALgAECgYJBgAAAA==.',
In='Innocentsmel:BAAALgAFFAIJAgAAAA==.',
Is='Ishtarin:BAAALgAECggJCAAAAA==.',
Jo='Jolyne:BAAALgAECgEJAQAAAA==.',
Ka='Kairos:BAABLgAFFH8FAAIJAAQJEQyMBQAtAQAJAAQJEQyMBQAtAQAAAA==.',
Ke='Kellykeith:BAAALgAECgUJBAABLgAECgYJDgAKAAAAAA==.',
Lo='Loghorizon:BAAALgAFFAIJAgAAAA==.',
Ls='Lserendipity:BAAALgAECgEJAwAAAA==.',
Ma='Magnus:BAAALgAECgcJBwAAAA==.Mayuyu:BAAALgAECgMJBQAAAA==.',
Mi='Minigen:BAAALgAECgQJBAAAAA==.',
Mk='Mklovenowar:BAABLgAFFH8FAAMMAAQJ/RTvAQD/AAAMAAQJnA7vAQD/AAALAAEJkhwKLwBWAAAAAA==.',
On='Onyu:BAAALgAECgYJDAAAAA==.',
Or='Orion:BAAALgAFFAMJBAABLgAFFAQJBQAJABEMAA==.Orman:BAABLgAECn8cAAINAAgJKyH7CgDtAgANAAgJKyH7CgDtAgAAAA==.Orp:BAAALgAECgcJBwAAAA==.',
Pa='Pand:BAABLgAFFH8FAAIOAAUJlyEdAgD9AQAOAAUJlyEdAgD9AQAAAA==.',
Ph='Phrolova:BAAALgAFFAEJAQAAAA==.',
Pl='Playerlsbgcb:BAAALgAECgcJCQAAAA==.',
Ps='Psh:BAAALgADCgQJBAAAAA==.',
Re='Redstar:BAAALgAECgEJAQAAAA==.',
Sa='Safarilala:BAABLgAFFH8GAAIFAAMJFRm0DwDuAAAFAAMJFRm0DwDuAAAAAA==.Saulh:BAAALgAECgcJDQAAAA==.',
Sh='Shoei:BAAALgAECgcJEwAAAA==.',
Si='Silverwonder:BAAALgAFFAEJAgAAAA==.',
Sl='Slyrk:BAACLgAFFH8OAAMNAAQJyyKTAACYAQANAAQJyyKTAACYAQAPAAQJRhN4DgA/AQAuAAQKfx8AAw8ACAnBIhgZAF8CAA8ACAmPHhgZAF8CAA0ABQlXI/0xAOgBAAAA.',
So='Sore:BAAALgAECgEJAQAAAA==.Soulmocca:BAAALgAFFAIJAgAAAA==.',
St='Stalinced:BAAALgADCgIJAgAAAA==.',
Su='Suzaku:BAAALgAECgEJAQAAAA==.',
Ta='Tangowb:BAAALgAECgYJCwAAAA==.',
Te='Teas:BAAALgADCgcJBwAAAA==.',
Tr='Tranzalore:BAAALgAECgcJCwAAAA==.Traviss:BAAALgAFFAIJAgAAAA==.Treetreeder:BAAALgAECgYJBgAAAA==.',
Tw='Twinkledark:BAACLgAFFH8RAAIQAAUJxBoPAQC1AQAQAAUJxBoPAQC1AQAuAAQKfyMAAhAACAmaHlUNALICABAACAmaHlUNALICAAAA.',
Vi='Villter:BAAALgAECgIJAgAAAA==.',
Wa='Watos:BAAALgADCgkJCQAAAA==.',
Wu='Wugii:BAAALgAECgYJBwABLgAFFAYJDgARAA8YAA==.',
Xe='Xel:BAAALgADCgMJAwAAAA==.',
Xy='Xylia:BAAALgAECgcJEwAAAA==.',
Yu='Yuurie:BAAALgAECgUJBgAAAA==.',
Yy='Yycck:BAAALgAECgYJBwABLgAFFAUJFAASAAEiAA==.Yyck:BAACLgAFFH8UAAMSAAUJASIFAQABAgASAAUJASIFAQABAgATAAMJQhRQAwC1AAAuAAQKfx8AAxMACAlzJMMCAO4CABMACAmiIMMCAO4CABIABwnwJfMPANMCAAAA.',
Za='Zand:BAAALgADCgcJBwAAAA==.',
['一叶']='一叶之秋:BAAALgAECgUJBAAAAA==.一叶织秋:BAAALgAECgYJBgAAAA==.',
['七个']='七个名字好难:BAAALgAECgQJBAAAAA==.',
['七里']='七里香的欢愉:BAAALgAECgYJBgAAAA==.',
['丄十']='丄十丅:BAAALgAECgEJAQAAAA==.',
['三丗']='三丗八度六:BAAALgADCgUJBQAAAA==.',
['三明']='三明治:BAAALgAECgEJAgAAAA==.',
['三湖']='三湖川哥:BAAALgAECgQJBQAAAA==.',
['上马']='上马就跑:BAAALgADCgYJBwAAAA==.',
['东方']='东方艺术家:BAAALgAECgcJCAAAAA==.',
['东门']='东门小酒:BAAALgAFFAIJBAAAAA==.',
['丨业']='丨业有专攻:BAABLgAECn8UAAMRAAkJZxvUDAATAwARAAkJZxvUDAATAwAUAAEJAACkbAA7AAAAAA==.',
['丨尘']='丨尘不染:BAAALgAECgcJBwAAAA==.',
['丶丶']='丶丶奶茶:BAAALgAECgcJAQABLgAFFAcJBAAKAAAAAA==.',
['丶千']='丶千钧:BAACLgAFFH8QAAIVAAUJohnsAwCpAQAVAAUJohnsAwCpAQAuAAQKfx4AAhUACAn+I5kFADwDABUACAn+I5kFADwDAAAA.',
['丶望']='丶望舒:BAAALgAECgcJBwAAAA==.',
['丶淡']='丶淡若清风:BAAALgADCgYJBgAAAA==.',
['丶老']='丶老村长:BAAALgAECgEJAQAAAA==.',
['丶聖']='丶聖光:BAAALgAECgMJAQAAAA==.',
['丶萨']='丶萨满:BAAALgAECgEJAQAAAA==.',
['丶骚']='丶骚气蛋蛋:BAAALgAECgQJBAAAAA==.',
['为你']='为你冲枫:BAAALgAECgUJBQAAAA==.为你冲风:BAABLgAFFH8QAAILAAQJdxtSBABSAQALAAQJdxtSBABSAQAAAA==.',
['丿龙']='丿龙龙:BAAALgAECgkJCQAAAA==.',
['乂皮']='乂皮卡灿乂:BAAALgADCgQJBAAAAA==.',
['乐而']='乐而忘返:BAAALgAECgEJAgAAAA==.',
['乞敌']='乞敌:BAAALgADCgYJBgAAAA==.',
['五菱']='五菱车神:BAAALgADCgIJAgAAAA==.',
['井中']='井中月:BAAALgAECgcJBwAAAA==.',
['亲亲']='亲亲不回来:BAAALgADCgIJAgAAAA==.亲亲回来了:BAAALgAECgYJDgAAAA==.',
['人類']='人類不宜飛行:BAAALgADCgEJAQAAAA==.',
['仁王']='仁王:BAAALgADCgIJAgAAAA==.',
['今天']='今天不能翻翻:BAAALgADCgIJAgAAAA==.',
['仙逼']='仙逼戳戳:BAAALgADCgMJAwAAAA==.',
['仲煌']='仲煌:BAABLgAECn8cAAISAAcJLh0UIQBKAgASAAcJLh0UIQBKAgAAAA==.',
['会冰']='会冰会火:BAAALgAECgEJAQAAAA==.',
['佐伊']='佐伊:BAAALgADCgUJBQAAAA==.',
['你别']='你别说话我烦:BAAALgAECgcJBwAAAA==.',
['你爷']='你爷他手一抬:BAABLgAFFH8HAAISAAMJ6BQRBgABAQASAAMJ6BQRBgABAQAAAA==.',
['侬哈']='侬哈无作:BAAALgAECgYJDAAAAA==.',
['保羅']='保羅西決地板:BAABLgAECn8WAAIWAAYJUBt7jwC0AQAWAAYJUBt7jwC0AQAAAA==.',
['倚剑']='倚剑向天歌:BAAALgAECgcJBgAAAA==.',
['偶尔']='偶尔懵逼:BAAALgAFFAEJAgAAAA==.',
['偶系']='偶系一个小德:BAAALgAECgQJBAAAAA==.',
['傲然']='傲然之天:BAAALgAFFAEJAgAAAA==.',
['充气']='充气玩偶:BAAALgAECgUJCAAAAA==.',
['光帝']='光帝:BAABLgAECn8UAAMXAAcJAiITPwA8AgAXAAcJAiITPwA8AgAYAAYJPhv1IgAqAQAAAA==.',
['克图']='克图格亞:BAABLgAFFH8GAAIXAAIJIx3ZPACkAAAXAAIJIx3ZPACkAAAAAA==.',
['兔斯']='兔斯基丶旺旺:BAAALgAECgUJBQAAAA==.',
['兲使']='兲使丶熊:BAAALgAFFAIJAwAAAA==.',
['军团']='军团执政官:BAAALgADCgcJBwAAAA==.',
['冫中']='冫中钅:BAAALgADCgEJAQAAAA==.',
['冷月']='冷月云峰:BAAALgAECgIJAgAAAA==.冷月弧光:BAAALgADCgMJAwAAAA==.',
['凉风']='凉风女王:BAAALgAECgEJAQAAAA==.',
['刘夏']='刘夏:BAAALgAECgEJAQAAAA==.',
['初鸫']='初鸫:BAAALgAECgcJCgAAAA==.',
['剑小']='剑小轩培圣:BAAALgAECgYJCgAAAA==.',
['剑舞']='剑舞丶:BAAALgAECgEJAQAAAA==.',
['加勒']='加勒比海带王:BAAALgAECgYJBgAAAA==.',
['北冥']='北冥有鱼丶:BAAALgAECgUJBwAAAA==.',
['千原']='千原万神:BAAALgAECgEJAgAAAA==.',
['千本']='千本蒼:BAAALgAECgcJCQAAAA==.',
['半包']='半包黄鹤楼:BAAALgAFFAIJAgAAAA==.',
['华华']='华华有我:BAAALgAECgEJAQAAAA==.',
['华德']='华德鲁:BAAALgADCgYJBgAAAA==.',
['占山']='占山:BAAALgAECgQJBAAAAA==.',
['卡哇']='卡哇伊戴斯乃:BAABLgAECn8cAAMVAAgJfxIWKwC+AQAVAAgJfxIWKwC+AQAQAAYJeg6xTABQAQAAAA==.',
['卢美']='卢美琳:BAAALgADCgYJBwAAAA==.',
['叉叉']='叉叉个叉:BAAALgAECgEJAQAAAA==.',
['发呆']='发呆的丶蜗牛:BAAALgADCgEJAQAAAA==.',
['发彪']='发彪的丶蜗牛:BAAALgAECgQJBAAAAA==.',
['发条']='发条橙丶:BAAALgAECgYJDAAAAA==.',
['古尔']='古尔丹孤而单:BAAALgAECgcJCAAAAA==.',
['召唤']='召唤小弟:BAAALgAECgEJAQAAAA==.',
['叮当']='叮当响:BAAALgAECgEJAQAAAA==.',
['可可']='可可乐乐:BAAALgAECgMJBAAAAA==.',
['吃啥']='吃啥都不吃亏:BAAALgAECgIJAgAAAA==.',
['后卿']='后卿丶:BAAALgAFFAEJAQABLgAFFAYJDAAYABkYAA==.',
['呆呆']='呆呆的你:BAAALgADCgEJAQAAAA==.',
['咸鱼']='咸鱼烧饼:BAAALgAECgQJBQAAAA==.',
['哈基']='哈基米大王:BAAALgAFFAEJAQAAAA==.',
['哈撒']='哈撒给:BAAALgAECgYJBgAAAA==.',
['哒灬']='哒灬哒灬:BAAALgAECgUJBQAAAA==.',
['哦嚯']='哦嚯踩地板:BAACLgAFFH8IAAMNAAMJhx8aBwAvAQANAAMJlx4aBwAvAQAPAAEJwiRuIwBfAAAuAAQKfxYAAw8ACAlxGzAgACECAA8ABwlJHTAgACECABkAAQlgEFArAE4AAAAA.',
['唔识']='唔识起名:BAAALgADCggJCAAAAA==.',
['唯美']='唯美钢琴师:BAAALgADCgIJAgAAAA==.',
['啦拉']='啦拉:BAABLgAECn8bAAIWAAgJ6SLzEwAwAwAWAAgJ6SLzEwAwAwAAAA==.啦拉啦:BAAALgAECgYJBgAAAA==.',
['喊出']='喊出我的名字:BAAALgAECgEJAQAAAA==.',
['喔喔']='喔喔奶糖:BAAALgADCgEJAQAAAA==.',
['喜中']='喜中五千万:BAAALgAECgYJCAAAAA==.',
['喵鬃']='喵鬃圆手:BAAALgAFFAEJAQAAAA==.',
['嗜睡']='嗜睡的疯子:BAAALgAECgkJCQAAAA==.',
['嘟嘟']='嘟嘟滚圆:BAAALgAECgYJBgAAAA==.',
['国王']='国王的鞋子:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光仰望:BAAALgAECgMJAwAAAA==.圣光大领主:BAAALgADCgIJAQAAAA==.',
['圣骑']='圣骑龍龍酱:BAAALgAECgkJAQAAAA==.',
['地狱']='地狱之焱:BAAALgAECgcJCwAAAA==.',
['坏小']='坏小仔:BAAALgAECgcJCwAAAA==.',
['坚果']='坚果杀手:BAAALgAECgIJAgAAAA==.',
['堕落']='堕落杀戮:BAAALgADCgkJCQAAAA==.',
['墨色']='墨色樱花:BAAALgADCgYJCAAAAA==.',
['壬辰']='壬辰年冬初九:BAAALgADCgMJAwAAAA==.',
['壮壮']='壮壮丶:BAABLgAECn8UAAIXAAcJfBOpYwDJAQAXAAcJfBOpYwDJAQAAAA==.',
['夏一']='夏一可死毒舌:BAAALgAECgYJBgAAAA==.',
['夏库']='夏库拉斯之刃:BAACLgAFFH8QAAMaAAUJzxg0AQAWAQAbAAMJGB5LFwAWAQAaAAUJEQw0AQAWAQAuAAQKfxQAAxsABwn4ICBAAPQBABsABgkoHiBAAPQBABoAAwmdHQsWAPkAAAAA.',
['夏紀']='夏紀:BAABLgAECn8UAAMcAAcJuBjMMwCuAQAcAAcJuBjMMwCuAQALAAYJChUpswAeAQAAAA==.',
['多蒙']='多蒙丨卡修:BAABLgAECn8ZAAIXAAgJoyIxEAAbAwAXAAgJoyIxEAAbAwAAAA==.',
['多重']='多重刘德华:BAAALgAFFAIJAgAAAA==.',
['夜慕']='夜慕微殇:BAAALgAECgYJCwAAAA==.夜慕微霜:BAACLgAFFH8GAAILAAQJnQ9BDABKAQALAAQJnQ9BDABKAQAuAAQKfxYAAwsABwlKFpZsAKQBAAsABwlKFpZsAKQBABwABglADYVbAA4BAAAA.',
['夜色']='夜色流沙:BAAALgAECgMJBAABLgAFFAMJBgAIALMEAA==.',
['夜雨']='夜雨声声:BAAALgAECgUJBgAAAA==.',
['大瀚']='大瀚哥:BAAALgAECgYJCgAAAA==.',
['大肥']='大肥猫:BAABLgAFFH8FAAIWAAIJ+xqRPACyAAAWAAIJ+xqRPACyAAAAAA==.',
['大青']='大青山:BAAALgAECgEJAQAAAA==.',
['天使']='天使之风:BAAALgAECgEJAgABLgAECgYJDgAKAAAAAA==.',
['天凉']='天凉好个秋丶:BAAALgAECgQJBgAAAA==.',
['天鋣']='天鋣:BAAALgAECgIJAgAAAA==.',
['失落']='失落得宠:BAAALgADCgEJAQAAAA==.',
['奎拖']='奎拖斯:BAABLgAECn8UAAIWAAYJ5iABUwA/AgAWAAYJ5iABUwA/AgAAAA==.',
['奔放']='奔放的橙橙:BAAALgAECgYJBgAAAA==.',
['奥斯']='奥斯曼:BAAALgAECgYJBgABLgAFFAIJBQAYAMgRAA==.',
['奶你']='奶你无罪:BAAALgAECgEJAQAAAA==.',
['好硬']='好硬硬:BAAALgAECgEJAQAAAA==.',
['妍霜']='妍霜雪:BAAALgAECgcJDgAAAA==.',
['妙手']='妙手箜箜:BAAALgAECgUJBAAAAA==.',
['妮蔻']='妮蔻:BAAALgAECgEJAQAAAA==.',
['姬灬']='姬灬安娜:BAAALgAECgEJBAAAAA==.',
['婉南']='婉南的路:BAAALgAECgIJAgAAAA==.',
['季末']='季末了去:BAAALgAECggJCAAAAA==.',
['孤单']='孤单灿烂的神:BAAALgADCgcJBwAAAA==.孤单魅惑:BAAALgADCgMJAwAAAA==.',
['安娜']='安娜斯塔西娅:BAAALgAFFAEJAQAAAA==.',
['安德']='安德雷奥利:BAAALgAFFAIJBAAAAA==.',
['官才']='官才:BAAALgAECgYJEQAAAA==.',
['家乐']='家乐福海盗:BAAALgAECgIJAgAAAA==.',
['家养']='家养的骑士:BAAALgAECgcJCgAAAA==.',
['寂寞']='寂寞先生丶:BAAALgAECgEJAQAAAA==.',
['富強']='富強福丶:BAACLgAFFH8IAAMdAAMJEwZUDQB7AAAdAAIJswhUDQB7AAAOAAEJ3AKvDQA4AAAuAAQKfyAAAx0ACAmjGM0aAC4CAB0ACAmjGM0aAC4CAA4AAQkvFMhnADQAAAEuAAUUBAkOAB0A5SIA.',
['寒霜']='寒霜炽:BAAALgAECgEJAQAAAA==.',
['小丶']='小丶兔几:BAAALgAFFAIJAgAAAA==.小丶唯唯:BAAALgAECggJDgABLgAFFAIJAgAKAAAAAA==.',
['小乄']='小乄暗:BAAALgADCgEJAQAAAA==.小乄烬:BAAALgAECgMJAwAAAA==.',
['小企']='小企鹅:BAAALgADCgEJAQAAAA==.',
['小及']='小及莫丶:BAABLgAFFH8PAAMRAAQJISWFBwBIAQARAAMJDiWFBwBIAQAUAAIJZCSpAgBtAAAAAA==.',
['小奶']='小奶牛:BAABLgAECn8XAAILAAcJpCOJIwCbAgALAAcJpCOJIwCbAgAAAA==.',
['小宵']='小宵虎喃:BAAALgAECgYJCQAAAA==.',
['小小']='小小兵:BAAALgAECgMJAwAAAA==.',
['小强']='小强的童话:BAABLgAECn8aAAISAAkJZCVUAADuAwASAAkJZCVUAADuAwABLgAFFAYJDgATANUkAA==.',
['小懒']='小懒虫:BAABLgAFFH8NAAICAAUJ1RRwBACnAQACAAUJ1RRwBACnAQAAAA==.',
['小手']='小手冰凉:BAAALgAECgUJBQAAAA==.',
['小楼']='小楼吹彻:BAAALgAECgEJAQAAAA==.',
['小波']='小波爾加:BAAALgAFFAIJAgAAAA==.',
['小糊']='小糊涂地:BAAALgADCgIJAgAAAA==.',
['小轩']='小轩培之唤:BAAALgAECgYJDAAAAA==.小轩培之萨:BAAALgAECgYJBgAAAA==.',
['小辫']='小辫子:BAAALgADCgIJAgAAAA==.',
['小阿']='小阿紫:BAAALgADCgIJAgAAAA==.',
['小鬼']='小鬼儿别追了:BAAALgAECgUJCwAAAA==.',
['山里']='山里灵活:BAAALgAECgYJCwAAAA==.',
['巨蟹']='巨蟹座的小鱼:BAAALgAFFAIJAwAAAA==.',
['巴赫']='巴赫丶:BAAALgAECgYJBgAAAA==.',
['希波']='希波里图斯:BAAALgAECgYJBgABLgAFFAIJBQAYAMgRAA==.',
['希瑞']='希瑞非凡公主:BAAALgAECgUJBQAAAA==.',
['幻境']='幻境毕老爷:BAAALgAECgEJAgAAAA==.',
['幽光']='幽光之盾:BAABLgAECn8WAAQeAAcJbBowFADJAQAeAAYJaxkwFADJAQASAAUJ4BXMVgBRAQATAAEJrhu0OABMAAAAAA==.',
['弦动']='弦动:BAAALgAECgEJAQAAAA==.',
['当代']='当代牛马仔:BAAALgAECgEJAQAAAA==.',
['徐福']='徐福:BAAALgAECgYJDQAAAA==.',
['循环']='循环式丶浅笑:BAABLgAECn8WAAMRAAYJbBiOUADWAQARAAYJbBiOUADWAQAfAAEJVw5wLwA/AAAAAA==.',
['心平']='心平气和丶:BAABLgAECn8bAAIFAAgJ2xmxHABXAgAFAAgJ2xmxHABXAgAAAA==.',
['心脏']='心脏起博器:BAAALgAFFAEJAQAAAA==.心脏起搏器:BAAALgAFFAMJAwAAAA==.',
['快乐']='快乐之极:BAAALgAECgYJCgAAAA==.',
['性感']='性感囚犯:BAAALgAECgIJAwAAAA==.性感小丸子:BAAALgAECgcJBwAAAA==.',
['恶魔']='恶魔召唤术:BAAALgADCgEJAQAAAA==.',
['悠岚']='悠岚山:BAAALgAECgcJBwAAAA==.',
['意韵']='意韵酒心:BAAALgAECgYJBgAAAA==.',
['愤怒']='愤怒的大脸:BAACLgAFFH8IAAIgAAMJZxn4BAARAQAgAAMJZxn4BAARAQAuAAQKfycAAiAACAm3I0QEADUDACAACAm3I0QEADUDAAAA.',
['慕容']='慕容丨紫瑛:BAAALgAECgQJBAAAAA==.',
['戆得']='戆得得的:BAAALgAECgIJAgAAAA==.',
['我好']='我好润:BAAALgAECgEJAQAAAA==.',
['我是']='我是一个德:BAAALgAECgEJAQAAAA==.',
['我滴']='我滴呆米鸡:BAAALgADCgEJAQAAAA==.',
['我爱']='我爱国足:BAAALgAFFAIJBAAAAA==.',
['我的']='我的刀盾:BAAALgAECgkJEQAAAA==.我的生活放蕩:BAAALgAECgYJBAAAAA==.',
['战兀']='战兀惧:BAAALgADCgEJAQAAAA==.',
['战吐']='战吐血:BAAALgAECgYJBgAAAA==.',
['手心']='手心冰凉:BAAALgAECgYJBwAAAA==.',
['打酱']='打酱油的四牛:BAAALgAFFAEJAgAAAA==.',
['披着']='披着床单冲锋:BAAALgAECgUJBgAAAA==.',
['抹茶']='抹茶色灬:BAAALgAFFAIJAwAAAA==.',
['拯救']='拯救部落:BAAALgAECgQJBAAAAA==.',
['换坦']='换坦不嘲讽:BAACLgAFFH8JAAIYAAQJUhAnCAAJAQAYAAQJUhAnCAAJAQAuAAQKfxoAAxgACQnUGhkHAL8CABgACAnaHBkHAL8CABcABwl4GUNMAA4CAAAA.',
['搓搓']='搓搓丶坏人:BAAALgAECgcJAQABLgAFFAgJIAAHAAAlAA==.',
['摇光']='摇光丶:BAAALgADCgEJAgAAAA==.',
['摇曳']='摇曳的风:BAAALgADCgcJBwAAAA==.',
['摸个']='摸个大奖:BAAALgAECgMJAwAAAA==.',
['文体']='文体两开花:BAABLgAFFH8FAAIEAAUJWg0dBgCFAQAEAAUJWg0dBgCFAQAAAA==.',
['无关']='无关风月丶:BAAALgAECgIJAgAAAA==.',
['无敌']='无敌不炉石:BAAALgAECgEJAQAAAA==.无敌小值:BAACLgAFFH8HAAMcAAMJUxacDgDsAAAcAAMJUxacDgDsAAALAAIJWgfxEQCUAAAuAAQKfx0AAxwABwkNGUgpAOYBABwABwkNGUgpAOYBAAsABQkBGuahADwBAAAA.',
['无耻']='无耻求拉:BAAALgAECgUJCQAAAA==.',
['时光']='时光流砂:BAAALgADCgMJAwAAAA==.时光流逝:BAAALgAECgcJDQAAAA==.',
['明日']='明日娱乐广告:BAAALgAECgEJAQAAAA==.',
['星光']='星光尾气猫:BAAALgADCgUJBQAAAA==.',
['星海']='星海浮沉:BAAALgAECgEJAgAAAA==.',
['星黛']='星黛露:BAAALgAECgYJBgAAAA==.',
['晚上']='晚上好:BAAALgAECgcJDgAAAA==.',
['晴空']='晴空狱天骑:BAAALgAECgEJAQAAAA==.',
['暗夜']='暗夜灬絯杍:BAAALgAECgUJBgAAAA==.',
['暗影']='暗影好好偶:BAAALgADCgUJBQAAAA==.',
['暗鬼']='暗鬼夜魅乔二:BAAALgAECgIJAgAAAA==.暗鬼小乔:BAABLgAECn8bAAMRAAgJ7xXANQA1AgARAAgJ7xXANQA1AgAUAAYJ/QoXKAAjAQAAAA==.',
['暴力']='暴力天启:BAAALgAECgEJAQAAAA==.',
['暴怒']='暴怒的糖爷爷:BAAALgAECgUJCAAAAA==.',
['月光']='月光闪闪:BAAALgAECgYJBgAAAA==.',
['月墟']='月墟:BAAALgAECgcJBwAAAA==.',
['有德']='有德有拾:BAAALgAECgEJAQAAAA==.',
['有苏']='有苏鸩:BAAALgAECgEJAwAAAA==.',
['木容']='木容皓:BAAALgAECgcJBwAAAA==.',
['未照']='未照耀的荣光:BAAALgAECgYJDQAAAA==.',
['术诗']='术诗:BAAALgAECgEJAgAAAA==.',
['李火']='李火旺:BAAALgAECgIJAgAAAA==.',
['染指']='染指忆流年:BAAALgAECgEJAQAAAA==.',
['柱哥']='柱哥:BAAALgAECgYJBgAAAA==.',
['梦醒']='梦醒四月谎:BAAALgADCgMJAwAAAA==.',
['森林']='森林炎湮:BAACLgAFFH8PAAIeAAQJ+hfrAwBIAQAeAAQJ+hfrAwBIAQAuAAQKfyQAAh4ABwlZG0ANADcCAB4ABwlZG0ANADcCAAAA.',
['楓葉']='楓葉落:BAACLgAFFH8OAAIRAAQJ6BfYBwBEAQARAAQJ6BfYBwBEAQAuAAQKfyYAAxEACAl9HwwFACsCABEACAl9HwwFACsCABQAAQkCFdVuADgAAAAA.',
['槑丨']='槑丨槑:BAAALgAECgYJEAAAAA==.',
['樂芙']='樂芙兰:BAAALgAECgYJBgAAAA==.',
['此起']='此起彼伏:BAAALgADCgcJDgAAAA==.',
['武圣']='武圣雷怒:BAAALgAECgEJAQAAAA==.',
['歪比']='歪比吧卟:BAAALgAECgYJCwAAAA==.',
['歪脸']='歪脸:BAAALgADCgIJAgAAAA==.',
['死亡']='死亡夜一:BAABLgAFFH8FAAIXAAMJVQcsGQCjAAAXAAMJVQcsGQCjAAAAAA==.',
['殁殁']='殁殁:BAAALgAECggJEwAAAA==.',
['毕总']='毕总:BAAALgAECgEJAQAAAA==.',
['毕老']='毕老三:BAAALgAECgkJCgAAAA==.毕老爷:BAAALgAECgMJBQAAAA==.',
['毛线']='毛线:BAABLgAFFH8KAAIFAAUJlRFlBQCEAQAFAAUJlRFlBQCEAQABLgAFFAcJDwAFAJIXAA==.',
['水中']='水中镜月:BAAALgADCgEJAQAAAA==.',
['水毐']='水毐:BAAALgAECgMJAwABLgAECgQJBwAKAAAAAA==.',
['水流']='水流觴:BAAALgAFFAEJAQAAAA==.',
['水煮']='水煮鱼:BAABLgAFFH8FAAILAAQJRxFmDABIAQALAAQJRxFmDABIAQAAAA==.',
['氷霜']='氷霜:BAAALgAFFAEJAQAAAA==.',
['汉堡']='汉堡怪兽:BAAALgAFFAEJAgAAAA==.',
['江上']='江上月:BAAALgAECgIJAgAAAA==.',
['江南']='江南丷:BAAALgAECgMJAwAAAA==.',
['汤圆']='汤圆儿就是牛:BAABLgAECn8YAAIVAAcJchgMJQDoAQAVAAcJchgMJQDoAQAAAA==.',
['沉默']='沉默的冰霜:BAAALgAFFAEJAQAAAA==.',
['沙隆']='沙隆巴斯丶:BAAALgADCgEJAQAAAA==.',
['没有']='没有集中值:BAACLgAFFH8FAAQPAAIJfxCaIACRAAAPAAIJrAiaIACRAAAZAAEJJR01BgBlAAANAAEJ2AMAAAAAAAAuAAQKfx8AAw8ACAkIHIQTAJYCAA8ACAlOGoQTAJYCABkABQlzGJwZADUBAAAA.',
['沫湘']='沫湘小璟:BAAALgAECgcJCQABLgAFFAcJDQAeAM4ZAA==.',
['治疗']='治疗训练假人:BAAALgAECgcJCQAAAA==.',
['法不']='法不择众:BAAALgAECgEJAgAAAA==.',
['法师']='法师丨重楼:BAAALgAECgYJBwAAAA==.',
['法爷']='法爷来个糖:BAABLgAECn8WAAIWAAcJOCDRRQBmAgAWAAcJOCDRRQBmAgAAAA==.',
['洋火']='洋火:BAAALgAECgEJAQAAAA==.',
['流云']='流云心:BAAALgAECgcJCwABLgAFFAcJBwARANgSAA==.',
['流年']='流年未央:BAAALgAECgYJBgAAAA==.流年碎影:BAAALgAECgIJAwAAAA==.',
['浅妆']='浅妆:BAAALgAECgIJAgAAAA==.',
['浅浅']='浅浅兔:BAAALgADCgEJAQAAAA==.',
['海若']='海若凌波:BAAALgAECgcJBwAAAA==.',
['消散']='消散的天蓝:BAAALgAECgYJCwAAAA==.',
['淡写']='淡写:BAABLgAFFH8HAAIWAAMJAwwMFQDjAAAWAAMJAwwMFQDjAAAAAA==.',
['混沌']='混沌骑:BAAALgAECgIJAQAAAA==.',
['添腹']='添腹一饼:BAAALgAECgYJEAAAAA==.',
['清凉']='清凉一夏:BAAALgAECgQJBAAAAA==.',
['清水']='清水溜溜:BAAALgAECgEJAQAAAA==.',
['清汤']='清汤小面:BAAALgAECgQJBAAAAA==.',
['渣住']='渣住支竹:BAAALgAECgQJBAAAAA==.',
['渣渣']='渣渣灬:BAAALgADCgUJCAAAAA==.',
['温柔']='温柔的七号:BAAALgAECgEJAgAAAA==.',
['湖光']='湖光静影:BAAALgADCgMJAwAAAA==.',
['溜达']='溜达熊:BAABLgAECn8fAAINAAgJpSUgAgB7AwANAAgJpSUgAgB7AwAAAA==.',
['满杯']='满杯红柚:BAAALgAECgIJAgAAAA==.',
['滴滴']='滴滴代喝丶:BAACLgAFFH8IAAIYAAQJtB+yAwB8AQAYAAQJtB+yAwB8AQAuAAQKfxQAAhgABwnTFx8eAFgBABgABwnTFx8eAFgBAAAA.',
['潶潶']='潶潶:BAAALgAECgcJDwABLgAECgkJDwAKAAAAAA==.',
['灬战']='灬战刃灬:BAAALgAECgYJCgAAAA==.',
['灬無']='灬無丶顏灬:BAABLgAFFH8FAAIWAAIJJw25PwCuAAAWAAIJJw25PwCuAAAAAA==.',
['灬瓜']='灬瓜哥灬:BAAALgADCgcJBwAAAA==.',
['灬莲']='灬莲城灬:BAAALgAECgIJAgAAAA==.',
['灬龘']='灬龘:BAAALgAFFAIJAgAAAA==.',
['灵魂']='灵魂提炼师:BAAALgAECgYJBwAAAA==.',
['炎焱']='炎焱燚焱炎:BAAALgAECgIJAgAAAA==.',
['無稽']='無稽:BAAALgAECgcJDgAAAA==.',
['熊猫']='熊猫京京:BAAALgADCgEJAQAAAA==.',
['爆掉']='爆掉盔儿的裆:BAAALgAECgEJAQAAAA==.',
['牛殁']='牛殁殁:BAAALgADCgEJAQAAAA==.',
['狗团']='狗团长灬:BAAALgAECgEJAQAAAA==.',
['狮子']='狮子挽歌:BAAALgAECgIJAgAAAA==.',
['狸沫']='狸沫:BAAALgAECggJCAAAAA==.',
['猩红']='猩红灯火:BAAALgAECgQJBQABLgAFFAMJBgAIALMEAA==.',
['猪肉']='猪肉荣炖熊掌:BAAALgAECgYJBwAAAA==.',
['猫猫']='猫猫得儿猪猪:BAAALgADCgEJAQAAAA==.',
['珀徳']='珀徳:BAABLgAECn8dAAILAAgJqyJIEAANAwALAAgJqyJIEAANAwAAAA==.',
['珂诺']='珂诺小鱼:BAAALgAECgIJAgAAAA==.',
['琅邪']='琅邪子墨:BAAALgAFFAIJAgAAAA==.',
['琉星']='琉星:BAAALgAECgQJBwAAAA==.',
['生活']='生活艰苦:BAAALgAECgYJDAAAAA==.',
['电燎']='电燎哀木啼:BAABLgAECn8aAAIQAAgJ8BMbKQDrAQAQAAgJ8BMbKQDrAQAAAA==.',
['畿畿']='畿畿龍:BAAALgAECgYJDwABLgAFFAUJEQAQAMQaAA==.',
['登临']='登临意:BAAALgAECgUJBQAAAA==.',
['白峰']='白峰美羽:BAAALgAFFAEJAgAAAA==.',
['皮卡']='皮卡皮卡灿:BAAALgAECgcJDgAAAA==.',
['皮皮']='皮皮:BAAALgADCgMJAwAAAA==.',
['矛盾']='矛盾螺旋:BAAALgAECgMJBAAAAA==.',
['碓冰']='碓冰愁生:BAAALgADCgEJAQAAAA==.',
['碧妮']='碧妮奧:BAAALgADCgUJBQABLgAFFAUJDwAWAE8RAA==.',
['神掉']='神掉喽:BAAALgAECgYJBgABLgAFFAUJDwAWAE8RAA==.',
['神牧']='神牧龍龍酱:BAABLgAECn8cAAIDAAgJPCCZCADCAgADAAgJPCCZCADCAgAAAA==.',
['神聖']='神聖星空:BAAALgAECgIJAwAAAA==.',
['秋夜']='秋夜麦田:BAAALgAFFAEJAQAAAA==.',
['穷儒']='穷儒丶公羊羽:BAAALgAECgEJAQAAAA==.',
['空帽']='空帽子:BAAALgAECgYJBgABLgAFFAMJBAAKAAAAAA==.',
['第三']='第三次:BAAALgADCgkJEAAAAA==.',
['粉之']='粉之天舞:BAAALgAECgIJAgAAAA==.',
['粉红']='粉红色体育生:BAAALgAECgcJAQAAAA==.',
['素士']='素士:BAAALgAECgEJAQAAAA==.',
['素月']='素月双云:BAAALgADCgMJAwAAAA==.',
['紫雨']='紫雨夜:BAAALgAECgQJBQAAAA==.',
['绝版']='绝版小样我是:BAAALgADCgUJBQAAAA==.',
['绝绝']='绝绝子丷:BAAALgAECgUJBQAAAA==.',
['继国']='继国缘壹:BAAALgADCgYJBgAAAA==.',
['绯红']='绯红脉动:BAAALgAECgcJBgAAAA==.',
['绿豆']='绿豆沙包:BAAALgADCgQJBAAAAA==.',
['老丶']='老丶邪:BAAALgAECgMJAwAAAA==.',
['老汉']='老汉迩忒車:BAAALgAECgYJCAAAAA==.',
['老猪']='老猪嗦包:BAAALgADCgMJAwAAAA==.',
['老闲']='老闲:BAABLgAECn8cAAMhAAcJ3Bl9EQAlAgAhAAcJ3Bl9EQAlAgAGAAEJxQXJQwAnAAAAAA==.',
['肥妞']='肥妞妞:BAAALgAECgcJCwAAAA==.',
['肥狗']='肥狗:BAABLgAECn8bAAIbAAcJGRXHSwDFAQAbAAcJGRXHSwDFAQAAAA==.',
['肥肠']='肥肠粗面:BAAALgAECgUJCgAAAA==.',
['胖大']='胖大叔:BAAALgADCgUJCAAAAA==.',
['胖达']='胖达爱丹丹:BAABLgAFFH8FAAINAAIJoBaZFQCuAAANAAIJoBaZFQCuAAAAAA==.',
['胸肌']='胸肌很大:BAAALgADCgcJBwAAAA==.',
['能抗']='能抗丨能打:BAAALgADCgQJBAAAAA==.',
['脆脆']='脆脆薯条:BAAALgAFFAIJBAABLgAFFAUJEQAQAMQaAA==.',
['腾梦']='腾梦:BAABLgAECn8VAAIFAAgJ0gawaAAZAQAFAAgJ0gawaAAZAQAAAA==.',
['花忮']='花忮:BAAALgAECgQJBwAAAA==.',
['莉丝']='莉丝缇娅:BAAALgAECgQJBQAAAA==.',
['莫得']='莫得雷德:BAAALgAECgEJAQAAAA==.',
['莫格']='莫格莱倪:BAAALgAECgMJAwABLgAFFAIJAgAKAAAAAA==.',
['莱莉']='莱莉丨灵影:BAAALgADCgEJAQAAAA==.',
['莽哥']='莽哥:BAAALgADCgEJAQAAAA==.',
['菈尼']='菈尼:BAAALgAECgEJAQAAAA==.',
['菜菜']='菜菜熊:BAAALgAECgcJDQAAAA==.',
['華胥']='華胥引:BAAALgAECgYJBgAAAA==.',
['萌吐']='萌吐血:BAACLgAFFH8QAAIXAAUJBw0VDgBqAQAXAAUJBw0VDgBqAQAuAAQKfx0AAhcACQlJGVodANACABcACQlJGVodANACAAAA.',
['萌萌']='萌萌的奶油:BAABLgAFFH8HAAIQAAMJQBhhDQAFAQAQAAMJQBhhDQAFAQAAAA==.',
['萨拉']='萨拉塔斯虚影:BAAALgAECgEJAQAAAA==.',
['萨琪']='萨琪满:BAAALgAECgQJBAAAAA==.',
['萨莉']='萨莉怀特迈恩:BAACLgAFFH8FAAICAAIJYxKwEgCgAAACAAIJYxKwEgCgAAAuAAQKfxoAAwIACAnsFoUUAAYCAAIACAnsFoUUAAYCAAEABQlIEgY4AC4BAAAA.',
['落灬']='落灬落丶:BAAALgAECgcJBAAAAA==.',
['蒳絲']='蒳絲遝晞亞:BAAALgADCggJCQAAAA==.',
['蓝城']='蓝城:BAAALgAECgEJAQAAAA==.',
['蕉呐']='蕉呐:BAABLgAFFH8LAAIOAAQJCSQCBACrAQAOAAQJCSQCBACrAQAAAA==.',
['薇薇']='薇薇公主:BAAALgAECgIJAgAAAA==.',
['虎啸']='虎啸龍吟:BAAALgADCgEJAQAAAA==.',
['虾饺']='虾饺掌门:BAABLgAFFH8GAAIdAAIJoRPsGgCTAAAdAAIJoRPsGgCTAAAAAA==.',
['蜻蜓']='蜻蜓队长:BAAALgADCgUJBQAAAA==.',
['螃蟹']='螃蟹小哥:BAAALgAECgEJAQAAAA==.',
['蟹皇']='蟹皇堡老板:BAAALgADCgYJBgAAAA==.',
['血刺']='血刺印:BAABLgAFFH8FAAISAAIJJhXOGACmAAASAAIJJhXOGACmAAAAAA==.',
['血色']='血色妖姬:BAAALgAECgIJAgAAAA==.',
['血铸']='血铸:BAAALgAECgQJBwABLgAECgQJCAAKAAAAAA==.',
['被拐']='被拐来的:BAAALgAECgcJBwAAAA==.',
['要啥']='要啥自行車:BAAALgAECgEJAQAAAA==.',
['请叫']='请叫我虾哥丶:BAAALgAECgcJBwAAAA==.',
['诸神']='诸神修罗:BAAALgADCgQJBAAAAA==.',
['谁也']='谁也打不过:BAAALgADCgEJAQAAAA==.',
['谋小']='谋小预:BAACLgAFFH8FAAIWAAMJMQs1SgCXAAAWAAMJMQs1SgCXAAAuAAQKfxQAAhYABglsHF4eAF4BABYABglsHF4eAF4BAAAA.',
['貝茵']='貝茵羙:BAACLgAFFH8GAAILAAMJnBFDCQACAQALAAMJnBFDCQACAQAuAAQKfxcAAgsACAl6Ic4bAMMCAAsACAl6Ic4bAMMCAAAA.',
['赤爪']='赤爪焚风:BAAALgAECgIJAgAAAA==.',
['轨僟']='轨僟:BAAALgAECgYJCgAAAA==.',
['软萌']='软萌的康娜酱:BAAALgAECgIJAwAAAA==.',
['轻萝']='轻萝小扇:BAAALgAECgIJAgAAAA==.',
['辛咕']='辛咕咕:BAAALgAECgEJAQAAAA==.',
['远古']='远古丶宅男:BAABLgAFFH8FAAILAAIJhRJ+DwCpAAALAAIJhRJ+DwCpAAAAAA==.',
['遗忘']='遗忘之風:BAAALgAECgIJAgABLgAECgYJDgAKAAAAAA==.',
['那个']='那个萨满:BAAALgAECgEJAQAAAA==.',
['那位']='那位莱特:BAAALgAECgYJDQAAAA==.',
['那年']='那年那段情:BAAALgAECgEJAQAAAA==.',
['邪帝']='邪帝:BAABLgAECn8cAAIXAAgJaSE9EwAIAwAXAAgJaSE9EwAIAwAAAA==.',
['野比']='野比大穷:BAAALgAECgQJBwAAAA==.',
['长安']='长安里:BAAALgADCgcJBwAAAA==.',
['阿丶']='阿丶姨:BAAALgAECgEJAQAAAA==.',
['阿凡']='阿凡达戴眼镜:BAACLgAFFH8FAAIXAAMJ/xlCIgAOAQAXAAMJ/xlCIgAOAQAuAAQKfxkAAhcABwkGJZwZAOMCABcABwkGJZwZAOMCAAAA.',
['阿小']='阿小凤:BAABLgAFFH8GAAINAAMJGBUGBwAQAQANAAMJGBUGBwAQAQAAAA==.',
['阿彤']='阿彤牧:BAAALgAECgEJAQAAAA==.',
['陈灬']='陈灬风暴烈玖:BAAALgADCgIJAgAAAA==.',
['雒雒']='雒雒:BAAALgAECgkJBgAAAA==.',
['雨天']='雨天:BAAALgAFFAIJBAAAAA==.',
['霜魄']='霜魄:BAAALgAECgQJCAAAAA==.',
['青青']='青青子襟:BAAALgAECgQJBAAAAA==.',
['静怡']='静怡流水:BAAALgADCgcJCwAAAA==.',
['静风']='静风逐影:BAAALgAECgYJCAAAAA==.',
['非常']='非常贤淑:BAAALgAFFAEJAQAAAA==.',
['音控']='音控师:BAAALgAECgYJBgAAAA==.',
['風灬']='風灬:BAAALgAECgYJDgAAAA==.',
['风一']='风一样男神:BAAALgAECgcJCwAAAA==.风一样的男子:BAAALgAECgMJAwAAAA==.',
['风暴']='风暴之女:BAAALgAECgIJAgAAAA==.',
['风眼']='风眼泪:BAAALgAFFAEJAgAAAA==.',
['风骑']='风骑路:BAAALgAFFAMJBAABLgAFFAQJDgARAOgXAA==.',
['飞天']='飞天牛:BAABLgAECn8cAAIaAAgJxhXKBgAhAgAaAAgJxhXKBgAhAgAAAA==.',
['飞扬']='飞扬箭舞:BAAALgAECgYJBgAAAA==.',
['馬猴']='馬猴烧酒:BAAALgADCgEJAQAAAA==.',
['马一']='马一龙:BAAALgAECgYJBgABLgAFFAEJAQAKAAAAAA==.',
['马卡']='马卡龙:BAAALgAFFAIJAgABLgAFFAUJEQAQAMQaAA==.',
['骑士']='骑士回归:BAAALgAECgkJCQAAAA==.骑士队丶小兵:BAAALgADCgcJBwAAAA==.',
['鬓髯']='鬓髯微霜:BAAALgAECgYJCgAAAA==.',
['鬼途']='鬼途:BAAALgADCgIJAgAAAA==.',
['魔天']='魔天无际:BAAALgADCgIJAgAAAA==.',
['鱼的']='鱼的森林:BAAALgAECgIJAgAAAA==.',
['鳟鱼']='鳟鱼:BAAALgAECgYJCAAAAA==.',
['鸡地']='鸡地组织:BAAALgAECgYJBwAAAA==.',
['麦片']='麦片酱:BAABLgAECn8VAAIcAAgJnB3FDQCqAgAcAAgJnB3FDQCqAgAAAA==.',
['黄昏']='黄昏现白骨:BAAALgADCgEJAQAAAA==.',
['黑月']='黑月铁騎:BAAALgAECgYJBgAAAA==.',
['黑老']='黑老鸹灬:BAAALgAECgEJAQAAAA==.',
['龍木']='龍木:BAAALgAECgcJBwABLgAFFAUJEQAQAMQaAA==.',
['龖灬']='龖灬龘:BAAALgAECgYJBgAAAA==.',
['龘灬']='龘灬龖:BAAALgAECgEJAQAAAA==.龘灬龘:BAAALgAECgEJAQAAAA==.',
['龙虾']='龙虾塔克:BAAALgADCgUJBQAAAA==.',
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
