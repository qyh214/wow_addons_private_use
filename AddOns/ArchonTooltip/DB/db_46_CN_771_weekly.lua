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

local lookup = {'Unknown-Unknown','DeathKnight-Unholy','Priest-Holy','Hunter-BeastMastery','Druid-Guardian','Druid-Feral','Druid-Restoration','DemonHunter-Devourer','Priest-Discipline','Druid-Balance','Paladin-Retribution','Warrior-Arms','Warrior-Fury','Warrior-Protection','Mage-Frost','Monk-Brewmaster','Evoker-Augmentation','Evoker-Devastation','Monk-Windwalker','Monk-Mistweaver','Hunter-Marksmanship','Hunter-Survival','DeathKnight-Blood','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Paladin-Holy','Shaman-Elemental','DeathKnight-Frost','Evoker-Preservation',}
local provider = {region='CN',realm='白骨荒野',name='CN',type='weekly',zone=46,date='2026-04-25',data={Av='Avri:BAAALgAECgEJAgAAAA==.',
Cu='Cuzzmage:BAAALgAECgYJDQABLgAECgcJDQABAAAAAA==.',
De='Deartea:BAAALgAFFAEJAQAAAA==.Deepresearch:BAAALgADCgIJAgAAAA==.Detectives:BAABLgAECn8mAAICAAgJUhiYDwC0AQACAAgJUhiYDwC0AQAAAA==.',
Go='Gobnin:BAAALgAECgQJBQAAAA==.',
He='Herpresent:BAAALgAECgMJCAAAAA==.',
In='Interstellar:BAACLgAFFH8FAAIDAAIJGh9OCgDBAAADAAIJGh9OCgDBAAAuAAQKfyIAAgMACAkqHxIIAMoCAAMACAkqHxIIAMoCAAAA.',
Ir='Irissy:BAAALgAECgIJAgAAAA==.',
Kj='Kjssa:BAAALgAECgUJAQAAAA==.',
Ky='Kyo:BAAALgAFFAIJBAAAAA==.',
Li='Ligt:BAAALgADCgEJAQAAAA==.',
Mo='Moff:BAAALgAECgIJAgAAAA==.Momentwo:BAAALgAECgQJBgAAAA==.Momokoo:BAABLgAFFH8HAAIEAAMJhh6pBgAtAQAEAAMJhh6pBgAtAQAAAA==.Monsterc:BAAALgAECgEJAQAAAA==.',
Na='Natalie:BAAALgAECgYJBAAAAA==.',
Ol='Oliver:BAAALgAECgcJDQAAAA==.',
Po='Pockyi:BAAALgAFFAIJAgAAAA==.',
Py='Py:BAAALgAECgcJBAAAAA==.',
Si='Silence:BAAALgAECgYJCgAAAA==.Silent:BAAALgAECgcJEAAAAA==.',
So='Sola:BAAALgAECgkJCQAAAA==.',
Sy='Sylvanaswind:BAAALgAECgcJBwAAAA==.',
Ti='Tiamole:BAAALgAFFAEJAQAAAA==.Timesup:BAAALgAECgUJBwAAAA==.',
To='Toadmarshal:BAAALgAECgYJBwAAAA==.Tobeapet:BAAALgAECgQJBQAAAA==.Tomoki:BAABLgAECn8iAAQFAAkJxx+iAwDQAgAFAAcJ9iOiAwDQAgAGAAkJtBxUAQAmAgAHAAEJMxCbzwAvAAAAAA==.',
Tw='Twinsper:BAABLgAFFH8FAAIIAAIJlx7UIgC4AAAIAAIJlx7UIgC4AAAAAA==.',
Wh='Whitelnte:BAAALgAECgIJAgAAAA==.',
Xw='Xw:BAAALgAECgEJAgAAAA==.',
Xx='Xxder:BAAALgAECgYJCgAAAA==.Xxms:BAABLgAFFH8GAAIJAAUJvxLJAgCfAQAJAAUJvxLJAgCfAQAAAA==.',
Zh='Zhuli:BAAALgAECgkJEQAAAA==.',
['一二']='一二三一二三:BAAALgAECgMJBAAAAA==.一二冲:BAAALgADCgUJBQAAAA==.',
['一心']='一心想嫁长鹅:BAAALgAECgYJBwAAAA==.',
['一牛']='一牛打死拳:BAAALgAECgMJAwAAAA==.',
['一纸']='一纸心碎:BAACLgAFFH8RAAIHAAUJ3ySDAAAoAgAHAAUJ3ySDAAAoAgAuAAQKfyUABAcACAlhIc4NAMwCAAcACAlhIc4NAMwCAAoABAl0GXBNAPQAAAYAAgkPI0AhANIAAAAA.',
['七弦']='七弦抚尽:BAAALgADCgYJBgAAAA==.',
['七月']='七月的风:BAAALgAECggJDwAAAA==.',
['上厕']='上厕所不带纸:BAAALgAECgQJBAAAAA==.',
['上帝']='上帝的师傅:BAAALgADCgMJAwAAAA==.',
['不煽']='不煽情:BAAALgAECgUJBQAAAA==.',
['丶丗']='丶丗頭鎶鎶:BAAALgAECgUJBwAAAA==.',
['丶亵']='丶亵渎少女:BAAALgAECggJDgAAAA==.',
['丶初']='丶初晓:BAAALgAECgIJAgAAAA==.',
['丶天']='丶天启:BAAALgAECgUJBgAAAA==.',
['丶契']='丶契约:BAAALgAECgQJBQAAAA==.',
['丶小']='丶小王子:BAAALgAFFAQJAwAAAA==.',
['丶悲']='丶悲鸣丿:BAAALgAECgQJBAAAAA==.',
['丶爺']='丶爺:BAAALgAECgEJAQAAAA==.丶爺爺:BAAALgAECgEJAQAAAA==.',
['丶红']='丶红夜丶:BAAALgAECgcJAwAAAA==.',
['丶续']='丶续师傅丶:BAAALgAECgEJAgAAAA==.',
['丶铁']='丶铁马冰河:BAAALgAECgEJAQAAAA==.',
['丿可']='丿可口可乐:BAAALgAECgQJBAAAAA==.',
['丿起']='丿起了个名字:BAAALgAECgUJBQAAAA==.',
['乃小']='乃小兔:BAAALgAFFAEJAQAAAA==.',
['么么']='么么哒丿:BAAALgAECgIJAgAAAA==.',
['之愿']='之愿:BAAALgAECgYJCgAAAA==.',
['乐而']='乐而雅:BAAALgAECgYJDAAAAA==.',
['乐蚌']='乐蚌詹士:BAAALgAECgMJBQAAAA==.',
['九牧']='九牧马桶:BAAALgAECgYJCQAAAA==.',
['九零']='九零后找人带:BAAALgADCgUJBQAAAA==.',
['五十']='五十一到:BAAALgAFFAEJAQAAAA==.',
['五号']='五号床:BAABLgAECn8hAAILAAgJNBpACQAZAgALAAgJNBpACQAZAgAAAA==.',
['亵渎']='亵渎少女丶:BAAALgAECgIJAgAAAA==.',
['人很']='人很菜又爱躺:BAAALgADCgEJAQAAAA==.',
['人未']='人未木杉子:BAAALgAECgEJAgAAAA==.',
['什么']='什么职业:BAAALgAECgUJBQAAAA==.',
['仇羊']='仇羊羊:BAAALgAECgcJBgAAAA==.',
['佐培']='佐培尔:BAAALgADCgcJBwAAAA==.',
['佳臻']='佳臻丶:BAAALgAECgUJBgAAAA==.',
['依依']='依依丶:BAAALgAFFAIJAwAAAA==.',
['依澜']='依澜:BAAALgADCgUJBQAAAA==.',
['依然']='依然蘩:BAAALgADCgEJAQAAAA==.',
['俊羽']='俊羽丨丶:BAAALgADCgQJBAAAAA==.',
['八岐']='八岐大蛇:BAAALgAECgkJCQAAAA==.',
['六边']='六边形:BAABLgAECn8XAAQMAAYJjRj9DQC9AQAMAAUJRxz9DQC9AQANAAYJgxBUVgBSAQAOAAEJownhRwAvAAAAAA==.',
['关中']='关中小霸王:BAAALgAFFAMJAwAAAA==.',
['冰冷']='冰冷:BAAALgADCgIJAgAAAA==.',
['冰火']='冰火燎原:BAAALgAECgYJEAAAAA==.',
['冰霜']='冰霜哀蹄:BAAALgAECgEJAQAAAA==.',
['冷艳']='冷艳火:BAABLgAECn8VAAIPAAYJHh92WgAqAgAPAAYJHh92WgAqAgAAAA==.',
['凝氷']='凝氷统帅:BAAALgAFFAEJAQABLgAFFAcJCwAQAM0PAA==.',
['分劣']='分劣:BAAALgAECgYJCQAAAA==.',
['别叫']='别叫我开门:BAAALgADCgIJAQAAAA==.',
['剑不']='剑不归:BAABLgAECn8WAAQOAAYJPhPCGgB3AQAOAAYJPhPCGgB3AQAMAAQJ3AGXPgA7AAANAAEJ0QA+tgAUAAABLgAECgYJBQABAAAAAA==.',
['剑海']='剑海鹰扬:BAAALgAFFAIJBAAAAA==.',
['十点']='十点过:BAAALgAECgUJCQAAAA==.',
['午夜']='午夜清晨:BAAALgADCgcJBwAAAA==.',
['半生']='半生酆都:BAAALgAFFAIJBAABLgAFFAIJBAABAAAAAA==.',
['卖奶']='卖奶茶的口口:BAAALgAECgYJBAAAAA==.',
['卜尧']='卜尧吖俤俤:BAAALgADCgMJAwAAAA==.',
['参商']='参商之盟:BAAALgADCgEJAQAAAA==.',
['双剑']='双剑滑斩:BAAALgADCgMJAwAAAA==.',
['双彩']='双彩专业户:BAAALgADCgcJBwAAAA==.',
['古力']='古力查力度:BAAALgAECgQJDQAAAA==.',
['古龍']='古龍:BAACLgAFFH8RAAIRAAUJ6BqkBABXAQARAAUJ6BqkBABXAQAuAAQKfyUAAxEACAklIJkHAAADABEACAklIJkHAAADABIABgnpGLcTAKkBAAAA.',
['古龙']='古龙弱闪光:BAABLgAECn8cAAMTAAgJICTmAwBPAwATAAgJICTmAwBPAwAUAAEJbQO3bAAqAAAAAA==.',
['只踢']='只踢下半身:BAAALgADCggJAgAAAA==.',
['可口']='可口可乐灬:BAAALgAFFAEJAQAAAA==.',
['吃尸']='吃尸体的猫:BAAALgAECgYJBgAAAA==.',
['听雨']='听雨寻梦:BAACLgAFFH8IAAIEAAQJ6RgnAwBrAQAEAAQJ6RgnAwBrAQAuAAQKfyMAAwQABwnfJLoJAPsCAAQABwnfJLoJAPsCABUABQm6D+ZOABMBAAEuAAUUBQkQAA8AUiUA.',
['吴夏']='吴夏荣:BAAALgAECgIJAgAAAA==.',
['呆包']='呆包:BAACLgAFFH8GAAMVAAMJ4Ri8EwACAQAVAAMJ4Ri8EwACAQAWAAEJmwZ0CQBSAAAuAAQKfx4AAxUABwn1Ie4SAJsCABUABwn1Ie4SAJsCABYAAgkVFo8WAEwAAAAA.',
['咕法']='咕法者:BAAALgAECgEJAQAAAA==.',
['哈登']='哈登丶戴维斯:BAAALgAECgEJAQAAAA==.',
['哎呀']='哎呀美屡:BAAALgADCgYJBgAAAA==.',
['哓玲']='哓玲:BAAALgAECgQJBQAAAA==.',
['哥丨']='哥丨只是寂寞:BAAALgAECggJCAAAAA==.',
['唔呣']='唔呣唔呣:BAAALgAECgEJAQAAAA==.',
['唥笑']='唥笑笑:BAAALgADCgEJAQAAAA==.',
['啊丶']='啊丶虎:BAAALgAECgEJAQAAAA==.',
['啦哄']='啦哄的妞妞:BAAALgAECgMJAwAAAA==.',
['喂吧']='喂吧呀:BAAALgAECgIJAgAAAA==.',
['嗦耳']='嗦耳:BAAALgAECgcJCwAAAA==.',
['嘻嘻']='嘻嘻小猎:BAAALgAFFAIJBAAAAA==.',
['四枫']='四枫院灬夜一:BAAALgAECgEJAQAAAA==.',
['土豆']='土豆儿大魔王:BAAALgAFFAQJBAABLgAFFAUJBQANAD8PAA==.土豆儿小魔王:BAAALgAECgcJBwAAAA==.',
['圣光']='圣光勾引你:BAAALgAECgEJAQAAAA==.圣光忽悠你:BAAALgAECgcJBwAAAA==.',
['在梅']='在梅边:BAAALgADCgEJAQAAAA==.',
['地狱']='地狱咆啸:BAACLgAFFH8FAAIMAAIJiAzdBACpAAAMAAIJiAzdBACpAAAuAAQKfxoAAwwACAknF3cJABUCAAwACAknFHcJABUCAA0ABglxF/9GAIgBAAAA.',
['夜空']='夜空丶丨:BAAALgAECgIJAgAAAA==.',
['大力']='大力水手:BAAALgAECgEJAgAAAA==.',
['大寶']='大寶唄:BAAALgADCgUJBQAAAA==.',
['大角']='大角:BAAALgAECgEJAQAAAA==.',
['大郎']='大郎该喝药啦:BAAALgADCgEJAQAAAA==.',
['大雄']='大雄来个萨:BAAALgAECgYJBwAAAA==.',
['天台']='天台微凉丶:BAAALgADCgEJAQAAAA==.',
['天堂']='天堂暖暖:BAAALgAECgMJAwAAAA==.',
['天帝']='天帝至尊:BAAALgAECggJDAAAAA==.',
['天才']='天才小狐狸:BAAALgAFFAIJAgAAAA==.',
['天沐']='天沐:BAAALgADCgEJAQAAAA==.',
['太寿']='太寿鸠毛:BAAALgAECgUJBQAAAA==.',
['头孢']='头孢呋辛酯:BAAALgAECgcJBwAAAA==.',
['奈小']='奈小多:BAAALgAECgMJAwAAAA==.',
['奎尔']='奎尔拉斯:BAAALgAECgMJBAAAAA==.',
['奕英']='奕英雄:BAAALgAECgUJBgAAAA==.',
['奶不']='奶不动脆皮:BAAALgAECgQJBAAAAA==.',
['奶油']='奶油棒大腿:BAACLgAFFH8GAAICAAIJdBuHNwCsAAACAAIJdBuHNwCsAAAuAAQKfxgAAgIACQlmHnkTAAYDAAIACQlmHnkTAAYDAAAA.',
['好大']='好大一只虎虎:BAAALgAECgYJBgAAAA==.',
['好无']='好无邪:BAAALgAFFAIJBAAAAA==.',
['妖帝']='妖帝丶:BAAALgAFFAEJAgAAAA==.',
['婲婲']='婲婲嗷呜呜:BAAALgAECgQJBAAAAA==.',
['家里']='家里蹲儿:BAAALgADCgEJAQAAAA==.',
['寒箭']='寒箭羞月:BAAALgAECgEJAQAAAA==.',
['小娘']='小娘孖:BAAALgAECgYJDAAAAA==.',
['小小']='小小卷泡泡糖:BAAALgAECgEJAQAAAA==.小小珂:BAAALgAECgkJBwAAAA==.',
['小油']='小油桃丶:BAAALgADCgIJAgAAAA==.',
['小法']='小法跑快快:BAAALgADCgQJBAAAAA==.',
['小浣']='小浣熊干脆面:BAAALgADCgUJBQAAAA==.',
['小牛']='小牛肉:BAAALgADCgYJBgAAAA==.',
['小石']='小石头丨小法:BAAALgAECgEJAQAAAA==.',
['小胖']='小胖胖:BAAALgAECgEJAQAAAA==.',
['小莫']='小莫的骑士:BAAALgADCgEJAQAAAA==.',
['小靌']='小靌珼:BAAALgAECgYJDQAAAA==.',
['小魚']='小魚丸:BAAALgADCgYJCQAAAA==.',
['小鸡']='小鸡脚:BAAALgADCgYJBwAAAA==.',
['尕丷']='尕丷熙:BAAALgAFFAQJAgAAAA==.',
['尹利']='尹利玬:BAAALgAFFAUJBAAAAA==.',
['差点']='差点諟帥謌:BAAALgAECgEJAQAAAA==.',
['开局']='开局带个骷髅:BAAALgAECgEJAQAAAA==.',
['强良']='强良:BAABLgAECn8XAAIXAAkJzBE8BAC3AQAXAAkJzBE8BAC3AQAAAA==.',
['從不']='從不孤獨:BAAALgAECgEJAgAAAA==.',
['御清']='御清絕:BAAALgAECgEJAQAAAA==.',
['德巴']='德巴德徳的:BAABLgAECn8bAAIHAAgJKx4VDwDBAgAHAAgJKx4VDwDBAgAAAA==.',
['忧伤']='忧伤的小鳖:BAAALgAFFAIJAgAAAA==.',
['快乐']='快乐风男:BAAALgADCgEJAQAAAA==.',
['恐怖']='恐怖愤子:BAAALgAECgUJCAAAAA==.',
['恩赐']='恩赐乄解脱:BAAALgADCgQJBAAAAA==.',
['恶之']='恶之影伤:BAABLgAECn8aAAICAAgJNw+vYgDLAQACAAgJNw+vYgDLAQAAAA==.',
['慕尘']='慕尘墨染丶:BAAALgADCgEJAQAAAA==.',
['我半']='我半藏贼丶六:BAAALgAECgIJAgAAAA==.',
['我很']='我很菜:BAAALgAFFAEJAQAAAA==.',
['我才']='我才是真帅:BAAALgAFFAEJAQAAAA==.',
['我能']='我能抗:BAAALgAFFAIJAwAAAA==.',
['战之']='战之殇茫:BAAALgADCgYJCAAAAA==.',
['战争']='战争使者:BAAALgADCgEJAQAAAA==.',
['战豆']='战豆豆呀:BAABLgAECn8UAAQNAAYJVg4tYgApAQANAAUJKw4tYgApAQAMAAEJBA/rQAA3AAAOAAEJhQQbSwAmAAAAAA==.',
['扎克']='扎克里亚斯:BAABLgAECn8jAAIEAAgJDx2FBwAQAgAEAAgJDx2FBwAQAgAAAA==.',
['护叔']='护叔宝:BAAALgAECgMJAwAAAA==.',
['拉格']='拉格萨戈:BAAALgAECgEJAQAAAA==.',
['招积']='招积:BAABLgAECn8YAAQYAAgJeBNETwDaAQAYAAcJ8hNETwDaAQAZAAEJmhBtLgBBAAAaAAEJoBVvaQA/AAAAAA==.',
['拽巷']='拽巷啰街:BAAALgAECgYJCAAAAA==.',
['挴賽']='挴賽徳凘:BAAALgAECgMJAwAAAA==.',
['摁住']='摁住丶往死捶:BAAALgAECgcJBwAAAA==.',
['敖闰']='敖闰闰:BAAALgAECgUJBgAAAA==.',
['敗家']='敗家女:BAAALgAFFAEJAQAAAA==.',
['无尽']='无尽苍穹:BAAALgAECgcJCAAAAA==.',
['旺仔']='旺仔大馒头:BAAALgAFFAEJAQAAAA==.',
['星城']='星城悍匪:BAAALgAECgQJBAAAAA==.星城悍妇:BAAALgAECgYJCAAAAA==.',
['星河']='星河渺渺:BAAALgAECgEJBAAAAA==.',
['星泪']='星泪:BAAALgAECgEJAQAAAA==.',
['星见']='星见雅:BAAALgAECgQJBAAAAA==.',
['晓懒']='晓懒猫:BAAALgADCgIJAQAAAA==.',
['晓精']='晓精灵:BAAALgAFFAEJAQAAAA==.',
['暗七']='暗七夜:BAAALgAECgMJAwAAAA==.',
['暗影']='暗影橘子:BAAALgAECgYJCgAAAA==.',
['暗黑']='暗黑小风:BAAALgAECgEJAQAAAA==.',
['暴走']='暴走的热血:BAAALgAECgIJAgAAAA==.',
['最爱']='最爱番茄炒蛋:BAAALgAECgEJAQAAAA==.',
['朝朝']='朝朝又暮暮:BAABLgAFFH8GAAIPAAIJyh2eNADFAAAPAAIJyh2eNADFAAAAAA==.',
['朵朵']='朵朵来了:BAABLgAFFH8GAAMLAAUJARGNBQCXAQALAAUJARGNBQCXAQAbAAEJFx7AGgBXAAAAAA==.',
['村口']='村口王叔叔:BAAALgAECgQJBAAAAA==.',
['東芳']='東芳集团经理:BAAALgADCgYJBgAAAA==.',
['板栗']='板栗再炖鸡腿:BAAALgAECgIJAgAAAA==.',
['柠檬']='柠檬海:BAAALgAFFAIJAgAAAA==.',
['格温']='格温不受影响:BAAALgADCgcJAQAAAA==.',
['梦境']='梦境之末:BAAALgADCgUJBQABLgAFFAQJDgAcAE0mAA==.',
['森僧']='森僧:BAAALgAECgYJBgAAAA==.',
['榮矅']='榮矅丨僧:BAAALgAECgQJBAAAAA==.',
['武侣']='武侣泪:BAAALgAECgEJAQAAAA==.',
['武大']='武大郎:BAAALgADCgYJBgAAAA==.',
['死了']='死了也要羊:BAAALgAECgMJAwAAAA==.',
['死亡']='死亡凋零丶慎:BAAALgAECgkJBgAAAA==.',
['死骑']='死骑之王:BAAALgADCgcJDQAAAA==.',
['殊秋']='殊秋丶:BAAALgAECgYJBgAAAA==.',
['比鲁']='比鲁斯大人:BAAALgAECgYJDgAAAA==.',
['毛利']='毛利兰:BAAALgAECgEJAQAAAA==.',
['毫不']='毫不犹豫:BAAALgAECgEJAQAAAA==.',
['永恒']='永恒之夜:BAAALgADCgYJBgAAAA==.',
['江上']='江上柳:BAAALgAECgEJAQAAAA==.',
['沅芷']='沅芷:BAAALgAFFAEJAQAAAA==.',
['沐秋']='沐秋:BAAALgAECgEJAQAAAA==.',
['泰蕾']='泰蕾希雅:BAAALgADCgEJAQABLgAFFAMJDAACAAYiAA==.',
['消失']='消失的背影:BAAALgAECgQJBAAAAA==.',
['深蓝']='深蓝寶藏:BAAALgADCgkJCgAAAA==.',
['清茶']='清茶丶:BAABLgAFFH8GAAIPAAMJpxrLFAAOAQAPAAMJpxrLFAAOAQAAAA==.',
['滥用']='滥用型布里:BAAALgADCgEJAQAAAA==.',
['潘灬']='潘灬西:BAAALgAECgEJAQAAAA==.',
['灬無']='灬無殇灬:BAAALgAECgEJAgAAAA==.',
['灬禅']='灬禅意灬:BAAALgADCgEJAQAAAA==.',
['灬艾']='灬艾派德灬:BAAALgAECgQJBAAAAA==.',
['灬血']='灬血海飘香灬:BAAALgAECgMJBQAAAA==.',
['灰原']='灰原丶哀:BAAALgAECgEJAQAAAA==.',
['灰流']='灰流丽:BAAALgAECgYJBwAAAA==.',
['灰烬']='灰烬一使者:BAAALgADCgYJBgAAAA==.',
['灵能']='灵能唱诗班:BAAALgADCgcJBwAAAA==.',
['灾祸']='灾祸丶:BAAALgAECgQJAwAAAA==.',
['炎獄']='炎獄:BAAALgAFFAUJBAAAAA==.',
['烈焰']='烈焰锁蔷薇:BAAALgAECgIJAwAAAA==.',
['烈风']='烈风斩舞:BAAALgAECgUJBgAAAA==.',
['烟霞']='烟霞不系舟:BAAALgADCgUJCAAAAA==.',
['無丨']='無丨常:BAAALgAECgQJBAAAAA==.',
['無聊']='無聊:BAAALgAECgIJAgAAAA==.',
['燃烧']='燃烧的蚂蚁:BAAALgAECgcJCwAAAA==.',
['燒香']='燒香:BAAALgAECgYJCgAAAA==.',
['爱吃']='爱吃咖喱鸡:BAAALgAFFAIJAwAAAA==.爱吃小汉堡丶:BAACLgAFFH8NAAICAAMJ6Q4SMgDBAAACAAMJ6Q4SMgDBAAAuAAQKfywAAgIACQl6IZwMADUDAAIACQl6IZwMADUDAAAA.',
['爱里']='爱里克斯:BAABLgAFFH8FAAIVAAUJygSGAwAOAQAVAAUJygSGAwAOAQAAAA==.',
['牛肉']='牛肉面热汤:BAAALgAECgcJBwAAAA==.',
['牛郎']='牛郎恋刘娘:BAAALgAECgYJEAAAAA==.',
['狂暴']='狂暴小墨:BAAALgAECgcJBwAAAA==.',
['狐果']='狐果聦:BAAALgADCgQJBAAAAA==.',
['狐里']='狐里灬狐涂:BAABLgAFFH8IAAIYAAMJESRkCgBAAQAYAAMJESRkCgBAAQAAAA==.',
['狙菊']='狙菊者:BAAALgAFFAEJAQAAAA==.',
['狸猫']='狸猫丶:BAAALgAECgYJDAAAAA==.',
['猫球']='猫球球:BAAALgAECgMJAwAAAA==.',
['王玥']='王玥:BAAALgAECgEJAQAAAA==.',
['玩家']='玩家昵称:BAAALgAFFAIJBAAAAA==.',
['瓜神']='瓜神的陈皮糖:BAAALgAECgEJAQAAAA==.',
['男人']='男人的浪漫:BAABLgAFFH8HAAINAAQJdhDZCgBOAQANAAQJdhDZCgBOAQAAAA==.',
['疯狂']='疯狂的贝吉塔:BAAALgADCgEJAQABLgAFFAQJDQAdAHAZAA==.',
['痞子']='痞子伯爵:BAAALgAECgQJBQAAAA==.',
['白鸟']='白鸟樱不樱:BAACLgAFFH8GAAIOAAMJXA9pCADRAAAOAAMJXA9pCADRAAAuAAQKfxwAAg4ABgkvI9YDAMgBAA4ABgkvI9YDAMgBAAAA.',
['皮皮']='皮皮橙:BAAALgAECgYJCAAAAA==.',
['盲灬']='盲灬僧:BAAALgAECgEJAQAAAA==.',
['睡觉']='睡觉的懒猫:BAAALgAFFAEJAQAAAA==.',
['破执']='破执一心:BAAALgADCgEJAQAAAA==.',
['破阵']='破阵不归:BAAALgAECgYJBQAAAA==.',
['碎江']='碎江丿:BAAALgAFFAEJAQAAAA==.',
['神武']='神武战皇:BAAALgAFFAIJAgAAAA==.',
['秋名']='秋名山车霸:BAAALgAECgEJAQAAAA==.',
['空心']='空心丿薩滿:BAAALgAECgkJCQAAAA==.空心死亡騎士:BAABLgAECn8VAAICAAcJhhLNdwCVAQACAAcJhhLNdwCVAQAAAA==.',
['笨蛋']='笨蛋人机:BAAALgAECgcJBwAAAA==.',
['米莉']='米莉奥媞尼:BAAALgAECgkJCAAAAA==.',
['粉色']='粉色小矮子:BAAALgADCgUJBQAAAA==.',
['糖门']='糖门大师兄:BAAALgAFFAIJAwAAAA==.',
['紫月']='紫月夜殇:BAAALgADCgUJBQAAAA==.',
['絕望']='絕望先生:BAAALgAECgEJAQAAAA==.',
['红烧']='红烧肥肠:BAAALgADCgcJBwAAAA==.',
['红眼']='红眼黑牛:BAAALgAFFAIJAgAAAA==.',
['红色']='红色体育生:BAAALgADCgQJBAAAAA==.',
['羿星']='羿星黎:BAAALgADCgEJAQAAAA==.',
['翰天']='翰天爵帝:BAAALgAFFAIJAwAAAA==.',
['翼德']='翼德丶老妖:BAAALgAECgEJAQAAAA==.',
['老哥']='老哥你先走:BAAALgADCgEJAQAAAA==.',
['老衲']='老衲有礼了:BAABLgAFFH8NAAMCAAUJZSR9AgCOAQACAAQJZSR9AgCOAQAXAAUJrwRTBwAbAQAAAA==.',
['肥比']='肥比亚:BAAALgADCgYJBgAAAA==.',
['至尊']='至尊精灵:BAAALgAECgYJBgAAAA==.',
['艾佛']='艾佛僧:BAAALgAECgIJAgAAAA==.',
['芒果']='芒果千层:BAAALgAECgQJBAAAAA==.',
['芯蓝']='芯蓝:BAAALgAFFAEJAQAAAA==.',
['苹果']='苹果嘉儿:BAAALgAECgYJCgAAAA==.',
['范佩']='范佩西丶:BAAALgAECgUJBwAAAA==.',
['范小']='范小雨:BAAALgAECgMJAwAAAA==.',
['荒神']='荒神:BAAALgAECgYJBgAAAA==.',
['荣荣']='荣荣:BAAALgADCgEJAQAAAA==.',
['莫如']='莫如長風:BAAALgAECgYJBwAAAA==.',
['萌小']='萌小兽丶:BAABLgAECn8bAAICAAkJcR8TFAADAwACAAkJcR8TFAADAwAAAA==.',
['萌虎']='萌虎掌:BAAALgAECgEJAQAAAA==.',
['萨满']='萨满一仓库:BAAALgADCgEJAQAAAA==.',
['蒋劲']='蒋劲夫:BAAALgAFFAEJAgAAAA==.',
['薛之']='薛之谦:BAABLgAECn8hAAMYAAcJ1h4dPAAcAgAYAAcJ1h4dPAAcAgAaAAMJaxbGMQDyAAAAAA==.',
['行军']='行军大总管:BAAALgADCgYJBgAAAA==.',
['街头']='街头树下碗:BAAALgAFFAIJAgAAAA==.',
['被遗']='被遗忘民工:BAAALgAFFAIJBAAAAA==.被遗忘者卫兵:BAAALgADCgYJCwAAAA==.',
['襲風']='襲風斑斕:BAAALgADCgYJBwAAAA==.',
['西米']='西米果:BAAALgAECgYJBgAAAA==.',
['西西']='西西楓子:BAAALgADCgUJBQAAAA==.',
['西门']='西门大菠萝:BAAALgADCgQJBAAAAA==.',
['要你']='要你命:BAAALgAECgMJBAABLgAECgUJBAABAAAAAA==.',
['訫筎']='訫筎芷氺:BAAALgAECgQJCAAAAA==.',
['许大']='许大茂:BAAALgAECgQJBwAAAA==.',
['说好']='说好不玩了:BAAALgAECgQJBwAAAA==.',
['请释']='请释放靈魂:BAAALgAFFAQJBAAAAA==.',
['谁稀']='谁稀罕:BAAALgAFFAMJAwAAAA==.',
['贫僧']='贫僧乱来:BAAALgAECgcJDQAAAA==.',
['贰大']='贰大王:BAAALgAECgYJBgAAAA==.',
['走到']='走到哪萌到哪:BAAALgADCgcJBwAAAA==.',
['跟斗']='跟斗大师:BAAALgAECgYJCgAAAA==.',
['蹊跷']='蹊跷波波:BAAALgAECgEJAQAAAA==.',
['辛酸']='辛酸德咕:BAAALgAFFAMJBAAAAA==.',
['达文']='达文西乀:BAAALgAECgMJAwAAAA==.',
['达芬']='达芬骑:BAAALgAECgQJBQAAAA==.',
['迅疾']='迅疾爪击:BAAALgAECgcJCAAAAA==.',
['进击']='进击的黄瓜:BAAALgAECgYJBgAAAA==.',
['迟到']='迟到的祝福:BAAALgAECgQJBQAAAA==.',
['迷彩']='迷彩雷电:BAABLgAFFH8FAAIPAAMJhBNwLgD9AAAPAAMJhBNwLgD9AAAAAA==.',
['邀明']='邀明月:BAAALgAECgYJCwAAAA==.',
['邓紫']='邓紫棋:BAABLgAFFH8IAAIOAAMJbQUUCgCsAAAOAAMJbQUUCgCsAAAAAA==.',
['那个']='那个信仰战:BAAALgADCgQJBAAAAA==.',
['铁盒']='铁盒:BAAALgAECgYJCwAAAA==.铁盒丶:BAAALgAFFAIJBAAAAA==.',
['银月']='银月守护:BAAALgAECgEJAQAAAA==.',
['锐迦']='锐迦:BAAALgAECgMJAwAAAA==.',
['锦鸿']='锦鸿萨满:BAAALgADCgEJAQAAAA==.',
['长离']='长离:BAAALgAECgYJBwAAAA==.',
['閃解']='閃解人衣:BAABLgAECn8UAAMOAAgJURRpDwASAgAOAAgJURRpDwASAgANAAEJhwHEtAAeAAAAAA==.',
['闪光']='闪光的哈萨维:BAAALgAECgUJBQAAAA==.',
['闹斯']='闹斯特麻麻:BAACLgAFFH8GAAIcAAQJWQ0uDAAqAQAcAAQJWQ0uDAAqAQAuAAQKfxUAAhwACAm5H1oOAL4CABwACAm5H1oOAL4CAAEuAAUUBQkGAAkAvxIA.',
['队长']='队长你别拔枪:BAAALgADCgQJBAAAAA==.',
['阿伊']='阿伊吐蕃公主:BAAALgADCgUJBQABLgAECgkJDwABAAAAAA==.',
['阿加']='阿加莎:BAAALgAECgEJAgAAAA==.',
['阿桶']='阿桶:BAABLgAECn8dAAMEAAkJ7BKRHQBUAgAEAAkJ7BKRHQBUAgAVAAYJ6hH4RgA4AQAAAA==.',
['阿莱']='阿莱丽斯塔萨:BAAALgADCgcJCAAAAA==.阿莱克斯爪萨:BAAALgADCgEJAQAAAA==.',
['阿达']='阿达泥螺:BAAALgAECgYJEgAAAA==.阿达泥螺二号:BAAALgAECgcJBwAAAA==.',
['陈太']='陈太公:BAAALgADCgUJBQAAAA==.',
['陌上']='陌上椛開:BAAALgAECgcJEgAAAA==.',
['院长']='院长专家:BAAALgAECgMJAwAAAA==.',
['雨中']='雨中残雪:BAAALgAFFAEJAQABLgAFFAMJBgAeACQQAA==.',
['雨夜']='雨夜故城桥:BAABLgAECn8aAAINAAkJqyNhAAAYAwANAAkJqyNhAAAYAwABLgAFFAEJAQABAAAAAA==.',
['雪狼']='雪狼一闪:BAAALgAECgYJCQAAAA==.',
['雪碧']='雪碧灬灬:BAAALgAFFAEJAQAAAA==.',
['零壹']='零壹:BAABLgAFFH8IAAIbAAMJgRyfDAATAQAbAAMJgRyfDAATAQAAAA==.',
['零帧']='零帧起手:BAAALgADCgEJAQAAAA==.',
['雷小']='雷小寒:BAAALgADCgIJAgAAAA==.',
['霁初']='霁初:BAAALgADCgEJAQABLgAECgYJBQABAAAAAA==.',
['青星']='青星:BAAALgADCgMJAwAAAA==.',
['青涩']='青涩后妈:BAAALgAECgIJAgAAAA==.',
['青衣']='青衣白马:BAAALgAECgYJCAAAAA==.',
['非常']='非常可乐灬:BAAALgADCgIJAgAAAA==.',
['顺亡']='顺亡:BAABLgAFFH8GAAICAAMJWRyrJwD5AAACAAMJWRyrJwD5AAAAAA==.',
['風清']='風清扬:BAAALgAECgYJCAAAAA==.',
['风之']='风之怒嚎:BAAALgAECgEJAQAAAA==.',
['风满']='风满楼:BAAALgAECgkJDgAAAA==.',
['风火']='风火发电:BAAALgAECgEJAQAAAA==.',
['风疯']='风疯風:BAAALgAFFAMJBAAAAA==.',
['风追']='风追晚霞:BAAALgADCgcJBwAAAA==.',
['风雨']='风雨潇潇:BAAALgAECgEJAQAAAA==.',
['飞起']='飞起的大法师:BAAALgAECgYJDAAAAA==.',
['香橙']='香橙:BAAALgAECgYJBwAAAA==.',
['香酥']='香酥油条:BAAALgAECgIJAgAAAA==.',
['骑驴']='骑驴找猪:BAAALgAECgMJBQAAAA==.',
['鬼頭']='鬼頭明里:BAAALgAECgIJAgAAAA==.',
['鲜虾']='鲜虾脆薯盏:BAAALgAECgMJAgABLgAFFAUJCQAEAMwQAA==.',
['鸠羽']='鸠羽千夜:BAAALgAFFAEJAQAAAA==.',
['黑凤']='黑凤梨:BAAALgADCgEJAQAAAA==.',
['黑宝']='黑宝宝丶:BAAALgAECgEJAgAAAA==.',
['點心']='點心:BAABLgAFFH8FAAIHAAMJTxYeCgDkAAAHAAMJTxYeCgDkAAAAAA==.',
['黯然']='黯然消魂智丈:BAAALgAECgYJBwABLgAFFAcJBwAaAE0eAA==.黯然消魂癫狂:BAAALgAECgkJEAAAAA==.黯然销魂流浪:BAAALgAFFAEJAQAAAA==.',
['龘丶']='龘丶枫随箭舞:BAABLgAECn8VAAIEAAcJkSNTBQA/AgAEAAcJkSNTBQA/AgAAAA==.',
['龙啸']='龙啸九天:BAAALgAECgcJBwAAAA==.',
['龙夕']='龙夕尔:BAABLgAFFH8GAAIRAAQJbQLWEwDdAAARAAQJbQLWEwDdAAAAAA==.',
['龙摆']='龙摆尾:BAAALgAECgYJCQAAAA==.',
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
