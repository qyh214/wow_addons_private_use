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

local lookup = {'DeathKnight-Unholy','Shaman-Restoration','DeathKnight-Frost','Paladin-Retribution','Priest-Discipline','Priest-Holy','DeathKnight-Blood','Mage-Frost','Rogue-Subtlety','Evoker-Augmentation','Evoker-Preservation','Evoker-Devastation','Paladin-Protection','Druid-Balance','Unknown-Unknown','DemonHunter-Vengeance','Warrior-Protection','Shaman-Elemental','DemonHunter-Devourer','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Druid-Restoration','DemonHunter-Havoc','Druid-Guardian','Warrior-Fury','Monk-Brewmaster',}
local provider = {region='CN',realm='诺森德',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akiradk:BAAALgAECgEJAQAAAA==.',
Ao='Aozorasama:BAAALgAECgYJBwAAAA==.',
Bl='Blademaster:BAAALgAECgIJAwAAAA==.',
Br='Brush:BAAALgAECgEJAgAAAA==.',
Ch='Charlter:BAABLgAECn8aAAIBAAYJBiLsWwDeAQABAAYJBiLsWwDeAQAAAA==.',
Da='Darkdk:BAAALgAECgcJEgAAAA==.',
De='Deathsword:BAAALgAFFAQJBAAAAA==.',
Fo='Forgotten:BAAALgAECgkJCQAAAA==.',
Gl='Globefish:BAAALgAECgEJAQAAAA==.',
Gz='Gz:BAAALgAECgYJCAAAAA==.',
Ja='Janekin:BAACLgAFFH8LAAICAAQJdxAlBwASAQACAAQJdxAlBwASAQAuAAQKfyAAAgIABwkhJSQJAOQCAAIABwkhJSQJAOQCAAAA.',
Ka='Kanemi:BAAALgAECgEJAQAAAA==.',
Kk='Kklcen:BAACLgAFFH8QAAMBAAQJtiJhBgCfAQABAAQJtiJhBgCfAQADAAEJvQjeBABVAAAuAAQKfyEAAwEACAlwJOINACwDAAEACAlwJOINACwDAAMAAgk4H2IRAH0AAAAA.',
La='Lasyon:BAABLgAFFH8FAAIEAAMJohykEAAhAQAEAAMJohykEAAhAQAAAA==.',
Mi='Mirc:BAACLgAFFH8OAAIFAAUJ7RwhAwDSAQAFAAUJ7RwhAwDSAQAuAAQKfxUAAgUACQkJHgAGAOsCAAUACQkJHgAGAOsCAAAA.Mire:BAAALgAFFAMJAwAAAA==.Mirf:BAAALgAECgYJBgAAAA==.Mirg:BAABLgAECn8VAAIFAAkJMhgaCgCXAgAFAAkJMhgaCgCXAgAAAA==.Mirh:BAAALgAFFAIJAgAAAA==.Miri:BAAALgAFFAQJBAAAAA==.Mirj:BAACLgAFFH8LAAIFAAQJgRoACABcAQAFAAQJgRoACABcAQAuAAQKfxYAAgUABwkLHtkSABsCAAUABwkLHtkSABsCAAAA.Mirk:BAABLgAFFH8JAAIFAAUJhhRvCgA3AQAFAAUJhhRvCgA3AQAAAA==.Mirn:BAAALgAFFAQJBAAAAA==.Mirrors:BAACLgAFFH8SAAIFAAUJTSKcAgDrAQAFAAUJTSKcAgDrAQAuAAQKfzYAAgUACQndJJMAALoDAAUACQndJJMAALoDAAAA.Mirv:BAAALgAFFAQJBAAAAA==.Mirz:BAAALgAFFAQJBAAAAA==.',
Mn='Mnmnmnmnmn:BAAALgAECgUJDwAAAA==.',
Mo='Molly:BAAALgADCgUJBQAAAA==.',
Ni='Nickcave:BAAALgAECgMJAwAAAA==.',
Po='Poppy:BAACLgAFFH8IAAIGAAQJhCNRAQB8AQAGAAQJhCNRAQB8AQAuAAQKfycAAgYACAmPICMHANoCAAYACAmPICMHANoCAAAA.',
Qa='Qadnpydrwlp:BAAALgAECgEJAQAAAA==.',
Ro='Rope:BAAALgADCgEJAQAAAA==.',
Sy='Sylviaheng:BAAALgAECgEJAQAAAA==.',
Vi='Vig:BAAALgAECgQJBwAAAA==.',
We='Wellplayed:BAAALgAECgQJBgAAAA==.',
Wi='Willburx:BAAALgAFFAIJAgABLgAFFAYJCAAGAA4aAA==.Wintersb:BAACLgAFFH8PAAIHAAYJLxuhAQDdAQAHAAYJLxuhAQDdAQAuAAQKfxcAAgcACAkuI0IFAO4CAAcACAkuI0IFAO4CAAAA.',
Wo='Wokao:BAAALgAECgQJCAAAAA==.',
Ya='Yamaha:BAAALgAFFAIJAgAAAA==.',
Zh='Zhai:BAACLgAFFH8IAAIIAAMJvhyzJQAcAQAIAAMJvhyzJQAcAQAuAAQKfyQAAggACAmxJI8QAEQDAAgACAmxJI8QAEQDAAAA.',
['一路']='一路风骚:BAAALgADCgIJAgAAAA==.',
['丄諦']='丄諦啲仇魜:BAAALgAECgIJAgAAAA==.',
['不能']='不能懂:BAACLgAFFH8OAAIJAAQJ3x2NAgBvAQAJAAQJ3x2NAgBvAQAuAAQKfxsAAgkACAneHaILANwCAAkACAneHaILANwCAAAA.',
['东岳']='东岳路:BAABLgAECn8oAAIBAAgJEhseMQBzAgABAAgJEhseMQBzAgAAAA==.',
['丨暗']='丨暗殇:BAAALgADCgUJBQAAAA==.',
['丨果']='丨果果妈丨:BAAALgAFFAMJAwAAAA==.',
['丶岳']='丶岳先森:BAAALgAECgEJAgAAAA==.',
['丶慕']='丶慕思思:BAAALgAECgYJBgAAAA==.',
['丶陌']='丶陌忆:BAAALgAECgEJAgAAAA==.',
['丷户']='丷户愚吕弟:BAAALgAECgkJEgAAAA==.',
['为了']='为了胜光:BAAALgAECgkJCQAAAA==.',
['九公']='九公子:BAAALgAFFAIJAwAAAA==.',
['佑佑']='佑佑就捣蛋:BAAALgADCgMJAwAAAA==.',
['你家']='你家的白菜:BAAALgAFFAEJAQAAAA==.',
['你才']='你才是奶龙:BAACLgAFFH8HAAMKAAQJDAcGDQDPAAAKAAQJDAcGDQDPAAALAAEJlwghGABBAAAuAAQKfyYABAoACAkqGMQHAJYBAAoACAnKF8QHAJYBAAwABQmiCvUkAP4AAAsABAnDA2g5AJ8AAAAA.',
['依然']='依然女流氓:BAAALgAECgkJDwAAAA==.依然饭太硬:BAAALgAECgYJCwAAAA==.',
['侠之']='侠之大者:BAAALgAECgMJAwAAAA==.',
['倷水']='倷水尤嘟:BAAALgAECgYJBwAAAA==.',
['倾为']='倾为谁颜:BAAALgAECgQJBAAAAA==.',
['光大']='光大师:BAABLgAECn8VAAIEAAkJiSBDBQB4AwAEAAkJiSBDBQB4AwAAAA==.',
['八六']='八六下山了:BAABLgAFFH8GAAIBAAQJYxq7EwBTAQABAAQJYxq7EwBTAQAAAA==.',
['冈崎']='冈崎渚:BAAALgADCgIJAgAAAA==.',
['冰块']='冰块姐:BAABLgAECn8VAAIGAAYJQA18EgABAQAGAAYJQA18EgABAQAAAA==.',
['冰封']='冰封大地:BAABLgAFFH8FAAMNAAIJEwO7AwBSAAANAAIJEwO7AwBSAAAEAAEJSwAPPAAsAAAAAA==.',
['冰指']='冰指丶绕微凉:BAAALgAECgYJBgAAAA==.',
['冷艳']='冷艳小妈:BAAALgADCgcJBwAAAA==.',
['凤梨']='凤梨酱:BAABLgAFFH8FAAIEAAUJhwdqBwB6AQAEAAUJhwdqBwB6AQAAAA==.',
['凯兰']='凯兰丶崔尔:BAACLgAFFH8RAAIOAAUJfiPEAQD/AQAOAAUJfiPEAQD/AQAuAAQKfyQAAg4ACAlSJNQEAFQDAA4ACAlSJNQEAFQDAAAA.',
['刚交']='刚交的朋友:BAAALgAECgMJAwAAAA==.',
['力大']='力大无穷:BAAALgAECgYJBgAAAA==.',
['北极']='北极尛妖:BAAALgAECgUJBgAAAA==.',
['十一']='十一楼哈士奇:BAAALgAECgEJAgAAAA==.',
['卅木']='卅木:BAAALgAECgEJAQABLgAFFAEJAgAPAAAAAA==.',
['卖女']='卖女孩的吙祡:BAAALgADCgYJBgAAAA==.',
['卖血']='卖血玩魔瘦:BAAALgADCgQJBAAAAA==.',
['南风']='南风予宁:BAAALgAECgQJBAAAAA==.',
['卜酷']='卜酷塔丶:BAAALgAECgIJAgAAAA==.',
['卡兹']='卡兹克:BAAALgAECgIJAgAAAA==.',
['卡嘉']='卡嘉莉:BAAALgAECgUJBwAAAA==.',
['卿爲']='卿爲谁顔:BAAALgAFFAEJAQAAAA==.',
['叁柱']='叁柱子丶:BAAALgADCgMJAwAAAA==.',
['取名']='取名字最烦:BAAALgAECgEJAQAAAA==.',
['叫你']='叫你站着别动:BAAALgADCgYJBgAAAA==.',
['右缟']='右缟丸疼:BAAALgAECgMJCQAAAA==.',
['叶汎']='叶汎:BAAALgAECgQJBgAAAA==.',
['含泪']='含泪做奶妈:BAAALgAECgQJBgAAAA==.',
['听说']='听说你叫瓜:BAABLgAFFH8MAAIHAAcJthytAAA9AgAHAAcJthytAAA9AgAAAA==.',
['呆呆']='呆呆遛宠:BAAALgAECgEJAQAAAA==.',
['咕擼']='咕擼咕噜噜:BAAALgAFFAEJAQAAAA==.',
['咕鲁']='咕鲁咕噜噜:BAAALgAFFAQJBAAAAA==.',
['哥布']='哥布林杀手:BAAALgAECgkJBwAAAA==.',
['哥本']='哥本哈根:BAABLgAFFH8JAAIQAAQJlxXyAAAzAQAQAAQJlxXyAAAzAQABLgAFFAQJCwARAFsZAA==.',
['哲里']='哲里:BAAALgADCgEJAQABLgAECgEJAQAPAAAAAA==.',
['嘴角']='嘴角小卷毛:BAAALgAECgUJBgAAAA==.',
['圣僧']='圣僧哥哥:BAAALgAFFAIJAgAAAA==.',
['塞尔']='塞尔达啊:BAAALgAECgYJCAAAAA==.',
['夏暖']='夏暖:BAAALgAECgYJBgAAAA==.',
['夏绿']='夏绿蒂:BAAALgADCgMJAwAAAA==.',
['多多']='多多提杠:BAAALgAFFAIJAgAAAA==.',
['夜丶']='夜丶第七章:BAABLgAECn8gAAIIAAgJLB/wKQDLAgAIAAgJLB/wKQDLAgAAAA==.',
['夜影']='夜影歌者:BAAALgAECgQJBwAAAA==.',
['夜色']='夜色玖:BAACLgAFFH8PAAIFAAUJKhxcAwDJAQAFAAUJKhxcAwDJAQAuAAQKfyAAAwUACQlLG0kCAGwCAAUACQlLG0kCAGwCAAYAAgnCBuRyAFwAAAAA.',
['大志']='大志哥哥:BAAALgADCgYJBgAAAA==.',
['大腿']='大腿码二腿:BAAALgAECgUJCAABLgAECgYJEAAPAAAAAA==.',
['大袁']='大袁总:BAACLgAFFH8KAAMDAAQJqRuGAABvAQADAAQJZRiGAABvAQABAAMJKBosIwAKAQAuAAQKfxsAAwEACAmkJI0NAC4DAAEACAkgJI0NAC4DAAMABQkSIEYCAIIBAAAA.',
['大长']='大长蛙:BAABLgAFFH8IAAISAAQJoBgHCABaAQASAAQJoBgHCABaAQAAAA==.',
['天机']='天机:BAAALgAECgQJBAAAAA==.',
['奈落']='奈落丶:BAAALgAFFAIJAwAAAA==.',
['女权']='女权克星:BAAALgAECgMJAwAAAA==.',
['娃哈']='娃哈哈之红酒:BAAALgAECgcJBgAAAA==.',
['娜美']='娜美美:BAABLgAFFH8IAAIEAAQJDA3GBwAyAQAEAAQJDA3GBwAyAQAAAA==.',
['孙悟']='孙悟空:BAAALgAECgQJBAAAAA==.',
['宇宙']='宇宙第一红手:BAABLgAECn8ZAAITAAkJDR/9BwBLAwATAAkJDR/9BwBLAwAAAA==.',
['守护']='守护梦琦之宝:BAACLgAFFH8FAAIUAAMJTxGJCwAGAQAUAAMJTxGJCwAGAQAuAAQKfx0ABBQACAluHsUcAFkCABQABwlkH8UcAFkCABUABwnUD6lLACMBABYAAQl7Aq0aADUAAAAA.守护梦琦乖乖:BAAALgADCgMJBAAAAA==.',
['安丘']='安丘児偲:BAAALgAECgQJBAAAAA==.',
['安娜']='安娜佩瑞拉:BAAALgADCgIJAgAAAA==.',
['宝可']='宝可蛙:BAAALgAFFAMJAgAAAA==.',
['宝宝']='宝宝:BAABLgAFFH8FAAIIAAIJshabOAC5AAAIAAIJshabOAC5AAAAAA==.',
['实在']='实在太靓了:BAAALgADCgEJAQAAAA==.',
['宠老']='宠老婆会发财:BAAALgAECgYJEAAAAA==.',
['宸心']='宸心宸意:BAAALgADCgEJAQAAAA==.',
['寒烟']='寒烟:BAABLgAECn8XAAQXAAgJxhhiNwAuAgAXAAcJxhhiNwAuAgAYAAEJAADaJABeAAAZAAEJ4QEbdAAxAAAAAA==.',
['小叮']='小叮铛:BAAALgAECgUJBwAAAA==.',
['小叶']='小叶鱼风震:BAAALgAECgYJCAAAAA==.',
['小小']='小小的萨满:BAAALgAECgQJAwAAAA==.',
['小弟']='小弟混装备难:BAAALgAECgEJAQAAAA==.',
['小掀']='小掀女:BAAALgAECgcJCgAAAA==.',
['小杰']='小杰克:BAAALgAECgcJDgAAAA==.',
['小狐']='小狐涂神:BAAALgAECgYJBgAAAA==.',
['小白']='小白不黑丶:BAAALgAECgMJAwAAAA==.小白白同学:BAAALgAECgYJBwAAAA==.',
['小红']='小红丶:BAAALgAECgUJBQAAAA==.',
['小野']='小野莉莎:BAABLgAFFH8IAAIEAAMJUhFADQD7AAAEAAMJUhFADQD7AAAAAA==.',
['小马']='小马先生:BAACLgAFFH8IAAIIAAQJ1g69DABRAQAIAAQJ1g69DABRAQAuAAQKfycAAggACAkfH/InANMCAAgACAkfH/InANMCAAAA.',
['山姆']='山姆斯韦德:BAAALgAECgEJAQAAAA==.',
['帅贼']='帅贼:BAAALgAECgQJCQAAAA==.',
['希斯']='希斯克利夫:BAAALgAECgIJAgAAAA==.',
['席妹']='席妹:BAAALgADCgcJBwAAAA==.',
['座杀']='座杀博徒:BAACLgAFFH8LAAIBAAQJsh2/AgCJAQABAAQJsh2/AgCJAQAuAAQKfygAAgEACAnVIpMbANgCAAEACAnVIpMbANgCAAAA.',
['彼岸']='彼岸灬梦境:BAAALgAECgYJDgAAAA==.',
['德不']='德不尝尸:BAAALgAFFAIJAgAAAA==.',
['德灬']='德灬殇:BAABLgAECn8aAAIaAAkJBCHTDwC6AgAaAAkJBCHTDwC6AgAAAA==.',
['德艺']='德艺双馨:BAAALgADCgUJBQAAAA==.',
['德阳']='德阳劈叉王:BAAALgAECgcJCAAAAA==.',
['悪魔']='悪魔猟手:BAABLgAECn8VAAMQAAgJwgvPEQA0AQAQAAcJuQzPEQA0AQAbAAEJ9gWNawA6AAAAAA==.',
['惡作']='惡作劇丶:BAAALgAECgYJCgAAAA==.',
['想你']='想你就天晴:BAAALgADCgUJBgAAAA==.',
['想死']='想死哪就死哪:BAAALgAECgEJAQAAAA==.',
['慕羽']='慕羽陌浅浅:BAAALgAECgUJBQAAAA==.',
['懒懒']='懒懒德:BAACLgAFFH8GAAIaAAQJbRAfCwAsAQAaAAQJbRAfCwAsAQAuAAQKfxUAAhoACAkdHBoWAIYCABoACAkdHBoWAIYCAAAA.',
['我想']='我想我是河:BAAALgAECgIJAgAAAA==.',
['我爱']='我爱你呀:BAAALgAFFAUJAwAAAA==.',
['我的']='我的小小术:BAAALgAECgEJAQAAAA==.',
['戰吙']='戰吙紛飛:BAAALgAECgQJCAAAAA==.',
['打不']='打不过就加入:BAAALgAECgUJAwAAAA==.',
['抛物']='抛物流:BAAALgADCgEJAQAAAA==.',
['护国']='护国神牛:BAAALgAECgUJBQAAAA==.',
['抹茶']='抹茶柠檬:BAAALgAECgUJCQAAAA==.',
['拉克']='拉克丝克莱因:BAABLgAECn8UAAMGAAgJYRPbMwBvAQAGAAcJZg/bMwBvAQAFAAQJKhW+DgAFAQAAAA==.',
['掌中']='掌中寶:BAAALgADCgQJBAAAAA==.',
['提莫']='提莫大魔王:BAAALgAECgYJDgAAAA==.',
['斤斤']='斤斤计较:BAAALgAECgMJAwAAAA==.',
['旋风']='旋风小雄:BAAALgAECgMJAwAAAA==.',
['早濑']='早濑优香:BAAALgADCgYJBgAAAA==.',
['明意']='明意:BAAALgADCgIJAgAAAA==.',
['星小']='星小痕:BAAALgAFFAEJAQAAAA==.',
['星落']='星落花火:BAAALgAECgkJDQAAAA==.',
['暮雨']='暮雨听蝉:BAAALgADCgYJBgABLgAFFAYJCAAGAA4aAA==.暮雨寒煙:BAACLgAFFH8GAAIOAAMJiQ3yDgDyAAAOAAMJiQ3yDgDyAAAuAAQKfyIAAw4ACAmgGy0RAJQCAA4ACAmgGy0RAJQCABwAAQm9A043ABoAAAAA.',
['曾經']='曾經的祸氺:BAAALgAECgkJBwAAAA==.',
['月神']='月神酱:BAAALgAECgQJBAAAAA==.',
['有种']='有种放学群殴:BAABLgAFFH8IAAIdAAQJ2xOSDQAuAQAdAAQJ2xOSDQAuAQAAAA==.',
['术爷']='术爷爷术:BAAALgAECgYJCgAAAA==.',
['李豆']='李豆沙:BAAALgAECgEJAQAAAA==.',
['杏仁']='杏仁冰淇淋:BAAALgADCgIJAgAAAA==.',
['杰洛']='杰洛齐贝林:BAAALgAECgMJAwAAAA==.',
['极道']='极道羅刹:BAAALgAECgQJBQAAAA==.',
['栗丨']='栗丨子:BAABLgAFFH8HAAMUAAMJhREGCgAJAQAUAAMJhREGCgAJAQAVAAEJQAN/LABBAAAAAA==.',
['格式']='格式化:BAAALgAECgYJCwAAAA==.',
['梦境']='梦境行者:BAACLgAFFH8HAAIaAAMJshzSDAAYAQAaAAMJshzSDAAYAQAuAAQKfyAAAhoABwkuIgITAJ4CABoABwkuIgITAJ4CAAAA.',
['横浜']='横浜桥小爷叔:BAAALgAECgEJAQABLgAECgQJBAAPAAAAAA==.',
['欺光']='欺光:BAAALgAFFAEJAQABLgAFFAQJCAAEAAwNAA==.',
['死之']='死之神:BAAALgADCggJAgAAAA==.',
['永泰']='永泰辣仔鹏:BAACLgAFFH8HAAICAAMJyxDcDwDpAAACAAMJyxDcDwDpAAAuAAQKfxYAAwIACAk9EAMrAOEBAAIACAk9EAMrAOEBABIAAgnYED1zAHUAAAAA.',
['汐時']='汐時:BAAALgAECgIJAgAAAA==.',
['江户']='江户小川:BAAALgADCgEJAQAAAA==.',
['江海']='江海寄丶余生:BAAALgAECgQJBQAAAA==.',
['法爷']='法爷爷法:BAAALgAECgMJAwAAAA==.',
['波波']='波波与泼泼:BAAALgAFFAUJBAAAAA==.',
['泰蕾']='泰蕾狗萨:BAAALgAECgIJAgABLgAECgYJBwAPAAAAAA==.',
['海妮']='海妮老美:BAAALgAECgEJAQAAAA==.',
['海棠']='海棠朵朵丶:BAAALgAECgQJBAAAAA==.',
['游戏']='游戏好难玩:BAAALgAECgUJBQAAAA==.',
['溺水']='溺水丶三天:BAAALgAECgcJDQAAAA==.',
['滋滋']='滋滋丶:BAAALgAECgIJBAAAAA==.',
['灬小']='灬小胖胖灬:BAAALgAECgYJCAAAAA==.',
['灬阿']='灬阿布大人灬:BAAALgAECgIJAgAAAA==.',
['炒碗']='炒碗蛋炒饭:BAAALgADCgkJCgAAAA==.',
['点点']='点点冰语:BAAALgAECgEJAgAAAA==.',
['然也']='然也:BAACLgAFFH8FAAIBAAMJaQuRLADpAAABAAMJaQuRLADpAAAuAAQKfxcAAwEABglkG5t6AI8BAAEABglkG5t6AI8BAAcAAQlbA4ZLAB8AAAAA.',
['熊大']='熊大:BAAALgAFFAIJAgAAAA==.',
['熊牧']='熊牧猫师:BAACLgAFFH8GAAIGAAIJeRh8CwCrAAAGAAIJeRh8CwCrAAAuAAQKfyEAAgYABwkqHBIWACwCAAYABwkqHBIWACwCAAAA.',
['爱吃']='爱吃花菜:BAAALgADCgEJAQAAAA==.爱吃鱼的猫:BAAALgAECgUJCwAAAA==.',
['爱的']='爱的飞行日记:BAAALgAECgEJAQAAAA==.',
['牛碧']='牛碧梨缇:BAAALgAECgEJAQAAAA==.',
['猛牛']='猛牛冰绿茶:BAAALgAECgQJBAAAAA==.',
['獨舞']='獨舞丶月影:BAACLgAFFH8IAAIcAAQJdgcRAgDXAAAcAAQJdgcRAgDXAAAuAAQKfycAAhwACAkSEwYPAI0BABwACAkSEwYPAI0BAAAA.',
['玩坦']='玩坦不抗怪:BAAALgAECgQJBAAAAA==.',
['玬妮']='玬妮莉丝:BAACLgAFFH8MAAMKAAUJbBWcDwAIAQAKAAMJ1hqcDwAIAQAMAAIJLwWUBwCBAAAuAAQKfxcABAoACAkNHR4UAEECAAoABwlDHR4UAEECAAwABAltFQUnAOkAAAsAAgnREPMOAHUAAAAA.',
['珍妮']='珍妮玛尖:BAAALgAFFAQJAwAAAA==.',
['珞珈']='珞珈:BAAALgAECgIJAQAAAA==.',
['田馥']='田馥甄:BAAALgAECgUJCgAAAA==.',
['电磁']='电磁炉高手:BAAALgAECgYJBgAAAA==.',
['痛太']='痛太痛了:BAAALgAECgEJAgAAAA==.',
['痛苦']='痛苦不痛苦:BAAALgAECgYJCAABLgAECgYJEAAPAAAAAA==.',
['白梦']='白梦妍:BAAALgAECgYJBgAAAA==.',
['白蟹']='白蟹炒年糕:BAAALgAECgYJBgAAAA==.',
['皓楠']='皓楠:BAABLgAFFH8JAAIEAAUJvR+OAgDZAQAEAAUJvR+OAgDZAQAAAA==.',
['看吾']='看吾眼神行事:BAAALgAECgcJCwAAAA==.',
['看我']='看我有几个头:BAACLgAFFH8IAAIBAAMJ1gfjLgDcAAABAAMJ1gfjLgDcAAAuAAQKfyAAAgEACAkHF7kQAKkBAAEACAkHF7kQAKkBAAAA.',
['神奇']='神奇小苗:BAABLgAFFH8HAAIIAAMJ1w5mLQABAQAIAAMJ1w5mLQABAQAAAA==.',
['神烦']='神烦的熊猫:BAAALgAFFAEJAQAAAA==.',
['竹蜻']='竹蜻蜓的擦肩:BAABLgAECn8XAAMRAAcJCw8+HQBcAQARAAcJTg4+HQBcAQAdAAMJ2QL6NgAwAAAAAA==.',
['箭中']='箭中有盗:BAAALgAECgYJDAAAAA==.',
['米雪']='米雪丶大人:BAABLgAFFH8FAAMTAAIJNhfCKACgAAATAAIJNhfCKACgAAAbAAEJyga6DQBPAAABLgAFFAUJEQAOAH4jAA==.',
['糖门']='糖门棍术:BAAALgAFFAEJAQAAAA==.',
['紫川']='紫川魔:BAAALgAECgQJBQAAAA==.',
['紫焰']='紫焰花生:BAAALgADCgYJBgAAAA==.',
['纵有']='纵有离别意:BAAALgAECgIJAgAAAA==.',
['结城']='结城亚丝娜:BAAALgAECgcJBwAAAA==.',
['给我']='给我毛点爬爬:BAAALgAECgIJAgAAAA==.',
['绝世']='绝世缺德:BAAALgAECgMJAwAAAA==.',
['统一']='统一沙琪玛:BAAALgAFFAMJBAAAAA==.',
['缺德']='缺德的组上我:BAAALgAECgUJBQAAAA==.',
['羽熊']='羽熊:BAAALgAECgIJAgAAAA==.',
['聋傲']='聋傲天:BAAALgAECgYJCQABLgAFFAIJAgAPAAAAAA==.',
['肉坨']='肉坨子:BAACLgAFFH8IAAIeAAMJDRmMEQDwAAAeAAMJDRmMEQDwAAAuAAQKfyQAAh4ACAlOGLwJAHoBAB4ACAlOGLwJAHoBAAAA.',
['肥胖']='肥胖嘎蟆:BAAALgAFFAUJBAAAAA==.',
['舞一']='舞一鹿:BAAALgAECgcJBwAAAA==.',
['艾克']='艾克裘德洛:BAAALgAECgEJAQAAAA==.',
['花和']='花和尚鲁智牛:BAAALgAECgIJAgAAAA==.',
['花寻']='花寻梦醉:BAAALgAECgIJAgAAAA==.',
['苗苗']='苗苗小鸡毛:BAABLgAFFH8HAAIBAAMJAxcoEwD4AAABAAMJAxcoEwD4AAAAAA==.',
['莱莎']='莱莎蕾尔:BAAALgAFFAIJBAAAAA==.',
['萌萌']='萌萌的番茄:BAABLgAFFH8HAAICAAMJQxGwDwDqAAACAAMJQxGwDwDqAAAAAA==.',
['落花']='落花的窗台:BAAALgADCgEJAQAAAA==.',
['蓝色']='蓝色哀伤:BAAALgADCgEJAQAAAA==.蓝色残渣:BAAALgAECgQJBAAAAA==.',
['薛定']='薛定谔的鸽:BAAALgAECgMJBAAAAA==.',
['藤井']='藤井莉娜:BAAALgAECgYJCQAAAA==.',
['虾哥']='虾哥儿:BAAALgADCgUJBQAAAA==.',
['西尔']='西尔斯:BAAALgAECgEJAQAAAA==.',
['西瓜']='西瓜水果:BAAALgAECgYJCgAAAA==.',
['角爷']='角爷爷角:BAAALgAECgQJBQAAAA==.',
['诺澜']='诺澜谷粒多:BAAALgAECgEJAQAAAA==.',
['豚骨']='豚骨拉麺:BAAALgADCgYJCAAAAA==.',
['起开']='起开:BAACLgAFFH8IAAIIAAMJvBo0JgAaAQAIAAMJvBo0JgAaAQAuAAQKfyIAAggACAlkHr0JAC8CAAgACAlkHr0JAC8CAAAA.',
['起開']='起開:BAAALgAECgUJBQAAAA==.',
['超级']='超级马枪王:BAAALgADCgEJAQAAAA==.',
['辣仔']='辣仔永泰鹏:BAAALgAECgMJAwAAAA==.',
['达贡']='达贡之神力:BAAALgADCgEJAQAAAA==.',
['迪皮']='迪皮艾斯:BAACLgAFFH8FAAMUAAMJdhTKCgACAQAUAAMJRA7KCgACAQAVAAIJbhi1GgCuAAAuAAQKfxkAAxUACAnpIAALAPQCABUACAnpIAALAPQCABQABgmfF+cTAIABAAAA.',
['迷失']='迷失幻境:BAAALgAECgYJBgAAAA==.迷失月洸:BAAALgAECgYJCwAAAA==.迷失月色:BAAALgAECgYJCwAAAA==.',
['那个']='那个奶德:BAAALgAECgIJAgAAAA==.',
['酸菜']='酸菜牛肉:BAAALgAECgkJCQAAAA==.',
['酸辣']='酸辣土豆丝丶:BAAALgAECgcJDAAAAA==.',
['醉扶']='醉扶归:BAABLgAFFH8IAAMaAAMJOhxgDQARAQAaAAMJOhxgDQARAQAOAAIJPRb3EgCsAAAAAA==.',
['野兽']='野兽啊:BAAALgAECgcJBwAAAA==.',
['野性']='野性一抓:BAAALgAECgQJBAAAAA==.',
['铁柱']='铁柱哥哥:BAAALgAFFAIJBAAAAA==.',
['铁游']='铁游夏:BAAALgADCgMJAwAAAA==.',
['铁血']='铁血丹心:BAAALgAECgEJAQAAAA==.',
['长安']='长安靓仔:BAAALgADCgMJAwAAAA==.',
['阿司']='阿司匹林:BAAALgAECgQJBAAAAA==.',
['阿对']='阿对对:BAAALgAECgQJBAAAAA==.',
['阿布']='阿布:BAAALgAECgYJDgAAAA==.',
['阿莫']='阿莫西林:BAAALgAECgYJCQAAAA==.',
['阿里']='阿里曼:BAAALgAECgcJBwAAAA==.',
['限量']='限量版丨信仰:BAAALgAECgEJAQAAAA==.',
['雅斯']='雅斯:BAAALgAECgYJCwAAAA==.',
['雪菜']='雪菜必吃:BAAALgADCgcJDQAAAA==.',
['零丶']='零丶霖拾:BAAALgAFFAIJBAAAAA==.零丶霖柒:BAAALgAECgUJBQAAAA==.零丶霖贰:BAAALgAECgYJBgAAAA==.零丶霖鹉:BAABLgAFFH8OAAIOAAQJ2xdxAwBWAQAOAAQJ2xdxAwBWAQAAAA==.',
['露可']='露可:BAAALgAECgYJDwAAAA==.',
['青坡']='青坡澜路:BAAALgAECgcJCgAAAA==.',
['面壁']='面壁者:BAAALgAECgMJAwAAAA==.',
['韩政']='韩政:BAAALgAECgIJAgAAAA==.',
['顾晰']='顾晰和:BAAALgADCgIJAgAAAA==.',
['風之']='風之逝言:BAABLgAECn8UAAISAAgJyBgCGQBMAgASAAgJyBgCGQBMAgAAAA==.',
['風水']='風水輪牛灷:BAACLgAFFH8GAAIEAAMJLgdFGQDeAAAEAAMJLgdFGQDeAAAuAAQKfyoAAgQACAkyESQbAHMBAAQACAkyESQbAHMBAAAA.',
['飞天']='飞天蛋:BAAALgAFFAMJAwAAAA==.',
['魔灵']='魔灵之魂:BAAALgAECgcJAQAAAA==.',
['鱼香']='鱼香肉丝丶:BAAALgAECgcJEQAAAA==.',
['鲨鹿']='鲨鹿刀:BAAALgAECgYJBgAAAA==.',
['鳶尾']='鳶尾低語:BAAALgAECgkJBgAAAA==.',
['鸪噜']='鸪噜咕噜噜:BAAALgAFFAIJAgABLgAFFAQJBAAPAAAAAA==.鸪噜鸪噜噜:BAAALgAFFAMJAwABLgAFFAQJBAAPAAAAAA==.',
['麦勒']='麦勒迪:BAABLgAFFH8FAAITAAIJhQtMGwCTAAATAAIJhQtMGwCTAAAAAA==.',
['黑百']='黑百合:BAAALgADCgYJBgAAAA==.',
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
