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

local lookup = {'Hunter-Marksmanship','Mage-Frost','Evoker-Preservation','DemonHunter-Devourer','Druid-Restoration','Druid-Balance','Shaman-Elemental','Priest-Shadow','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Fury','Paladin-Retribution','Paladin-Protection','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','DemonHunter-Vengeance','Monk-Brewmaster','Monk-Windwalker','Hunter-BeastMastery','Paladin-Holy','Warrior-Protection','Warrior-Arms',}
local provider = {region='CN',realm='甜水绿洲',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Ai:BAABLgAECn8WAAIBAAcJFxxsGgBTAgABAAcJFxxsGgBTAgAAAA==.',
At='Atg:BAAALgADCgEJAQAAAA==.',
Be='Beat:BAAALgAECgEJAQAAAA==.',
Bi='Bigzai:BAAALgADCgMJAwAAAA==.',
Ca='Calafiori:BAACLgAFFH8HAAICAAMJKCPvIQA3AQACAAMJKCPvIQA3AQAuAAQKfxQAAgIACAnFILUWACEDAAIACAnFILUWACEDAAAA.Cat:BAAALgAECgcJDQABLgAFFAQJDAADAEskAA==.',
Dm='Dmdh:BAAALgAECgIJAwABLgAFFAQJDgADAHUIAA==.',
Ic='Icehotflam:BAABLgAFFH8FAAICAAQJuhsREwB/AQACAAQJuhsREwB/AQAAAA==.',
Ka='Kafuuchino:BAAALgADCgcJBwAAAA==.Katos:BAAALgAECgEJAQAAAA==.',
La='Lalalal:BAAALgAECgYJBgAAAA==.',
Lo='Lollipop:BAAALgAECgYJBgAAAA==.',
Lu='Lucy:BAAALgAECgYJBAAAAA==.',
My='Myprincess:BAAALgAECgcJBwAAAA==.',
Oo='Oocc:BAAALgADCgQJBAAAAA==.',
Pa='Paladinmo:BAAALgAECgUJBwAAAA==.',
Pl='Playerhqpxul:BAAALgAECgEJAQAAAA==.',
Ra='Rainbowstar:BAAALgADCgYJBgAAAA==.',
Ro='Rosé:BAAALgAECgYJBgABLgAFFAcJHAAEAPEdAA==.',
Se='Seirias:BAAALgAECgYJCgAAAA==.',
Ul='Ultrakill:BAAALgAECgYJBwAAAA==.',
['一号']='一号呆呆兽:BAAALgAECgYJBwAAAA==.',
['一品']='一品温如言:BAAALgAECgMJAwAAAA==.',
['一水']='一水黑:BAAALgAECgYJBgAAAA==.',
['万剑']='万剑归宗:BAAALgAECgYJCgAAAA==.',
['上帝']='上帝佛:BAAALgAECgYJBwAAAA==.',
['不嘚']='不嘚不牛:BAABLgAECn8fAAMFAAgJpBdIKQAOAgAFAAcJjBlIKQAOAgAGAAcJUBd5KAC6AQABLgAFFAIJBgAHAFcGAA==.',
['不给']='不给笨蛋战复:BAAALgAECgMJAwAAAA==.',
['东瘟']='东瘟疫大肥蛆:BAAALgADCgEJAQAAAA==.',
['丢丢']='丢丢仔:BAAALgAECgEJAQAAAA==.',
['丨罒']='丨罒丷罒丨:BAAALgAFFAIJAgAAAA==.',
['乜都']='乜都唔想理:BAAALgAECgEJAgAAAA==.',
['二环']='二环十四郎:BAAALgADCgIJAgAAAA==.',
['云朵']='云朵:BAAALgAECgQJBAAAAA==.',
['五火']='五火球毅哥:BAAALgAECgQJCQAAAA==.',
['五迷']='五迷老师:BAAALgAECgIJAgAAAA==.',
['亚瑞']='亚瑞:BAACLgAFFH8FAAIFAAMJsQjYDAC/AAAFAAMJsQjYDAC/AAAuAAQKfxQAAgUACAlQGREbAGICAAUACAlQGREbAGICAAAA.',
['亢龙']='亢龙有悔丶龍:BAAALgADCgEJAQAAAA==.',
['亦萌']='亦萌无双:BAAALgADCgUJBQAAAA==.',
['仓木']='仓木麻衣:BAAALgAFFAYJAwAAAA==.',
['仓颉']='仓颉:BAAALgADCgMJAwAAAA==.',
['付娜']='付娜:BAAALgAECgkJAQAAAA==.',
['传说']='传说中的亚特:BAABLgAECn8cAAIIAAcJyBWJCQB7AQAIAAcJyBWJCQB7AQAAAA==.',
['何伟']='何伟姐:BAAALgAECgkJDQAAAA==.何伟杰:BAAALgAECgcJAwABLgAECgkJDQAJAAAAAA==.',
['何意']='何意味:BAAALgAFFAQJBAAAAA==.',
['佬倌']='佬倌矶:BAAALgAFFAIJAgABLgAFFAIJBgAHAFcGAA==.',
['俗人']='俗人之乡愁:BAAALgAECgQJBAAAAA==.',
['儿化']='儿化音:BAAALgAFFAIJBAAAAA==.',
['元祸']='元祸赦生:BAAALgADCgcJBwAAAA==.',
['光之']='光之圣堂:BAAALgAECgcJAQAAAA==.',
['克卜']='克卜勒:BAAALgAECgUJCQAAAA==.',
['兔八']='兔八哥:BAAALgAFFAQJBAAAAA==.',
['六个']='六个核丶桃:BAAALgADCgMJAwAAAA==.',
['兽星']='兽星魂:BAAALgAECgIJAgAAAA==.',
['内田']='内田有纪:BAAALgAFFAUJBAAAAA==.',
['冬天']='冬天榖:BAAALgADCgEJAQAAAA==.',
['冰霜']='冰霜贼:BAACLgAFFH8HAAIKAAMJDhjWIgALAQAKAAMJDhjWIgALAQAuAAQKfx0AAwoABwnPIRotAIQCAAoABwlGIRotAIQCAAsAAgl5G6o2AI0AAAAA.',
['冷语']='冷语疯:BAAALgAECgQJBAAAAA==.',
['凨酔']='凨酔里一剣:BAABLgAFFH8GAAIMAAQJ6gGVEwDjAAAMAAQJ6gGVEwDjAAAAAA==.',
['力阳']='力阳谋:BAAALgAECgEJAQAAAA==.',
['十一']='十一丷:BAAALgADCgEJAQAAAA==.',
['千丨']='千丨夜:BAAALgAECgEJAQAAAA==.',
['千里']='千里马凤凰:BAAALgAECgUJBQAAAA==.',
['古尓']='古尓氮:BAAALgAECgEJAQAAAA==.',
['叫我']='叫我祝踏岚:BAAALgAFFAIJAgAAAA==.',
['吟游']='吟游人之歌:BAAALgADCgEJAQAAAA==.',
['呼而']='呼而嗨哟:BAAALgAECgUJDAAAAA==.',
['咕叽']='咕叽来了:BAAALgAECgUJBQAAAA==.',
['咪喵']='咪喵喵:BAAALgAECgYJDgAAAA==.',
['咸骑']='咸骑:BAACLgAFFH8FAAMNAAIJBw25HQBYAAANAAIJBw25HQBYAAAOAAIJXQrJBwA5AAAuAAQKfxYAAw0ABwkTGpBQAPABAA0ABwleGJBQAPABAA4ABglkGF8TAJUBAAAA.',
['哓丶']='哓丶涳酱:BAAALgAECgIJAwAAAA==.',
['哥还']='哥还不是传说:BAAALgAECgEJAQAAAA==.',
['喜微']='喜微晨巷:BAAALgAECgcJDAAAAA==.',
['嗯啊']='嗯啊哦:BAAALgAECgEJAQAAAA==.',
['嘉豪']='嘉豪杜文博:BAAALgAECgcJBgAAAA==.',
['嘿西']='嘿西欧:BAAALgADCgUJBQAAAA==.',
['圐一']='圐一湿泥碑:BAAALgAFFAQJBAAAAA==.',
['地狱']='地狱飞魔:BAAALgAECgUJDQAAAA==.',
['埃德']='埃德勒弗林:BAAALgAECgEJAQAAAA==.',
['城里']='城里大叔:BAAALgAECgEJAQAAAA==.',
['塞拉']='塞拉:BAAALgAECgkJCQAAAA==.',
['墨染']='墨染櫻丶:BAABLgAFFH8FAAIKAAIJXhBmIQCeAAAKAAIJXhBmIQCeAAAAAA==.',
['壞籹']='壞籹囡:BAAALgADCgEJAQAAAA==.',
['复仇']='复仇的圣骑:BAAALgAECgcJBwAAAA==.',
['大点']='大点灬不好吗:BAAALgAECgMJAwAAAA==.',
['天下']='天下無敵:BAAALgAECgYJEAAAAA==.',
['天使']='天使与魔神:BAAALgAECgYJDwAAAA==.',
['天岚']='天岚丶:BAAALgADCgEJAQAAAA==.',
['女装']='女装元气少男:BAACLgAFFH8JAAIHAAMJlQ7tCADkAAAHAAMJlQ7tCADkAAAuAAQKfxUAAwcABgmYHyElAOgBAAcABgmYHyElAOgBAA8ABQl3GtRNAEwBAAAA.',
['奶油']='奶油柠檬:BAAALgADCgYJBgAAAA==.',
['奶瓶']='奶瓶儿:BAAALgAECgcJDQAAAA==.',
['如果']='如果的事:BAAALgAECgEJAgAAAA==.',
['姑奶']='姑奶奶有枪:BAAALgAECgEJAQAAAA==.',
['娇花']='娇花:BAAALgADCgYJCwAAAA==.',
['孤秋']='孤秋一叶:BAAALgAECgQJBgAAAA==.',
['安室']='安室奈美惠:BAAALgAFFAYJAwAAAA==.',
['寒枫']='寒枫:BAAALgAECgYJCwAAAA==.',
['對酒']='對酒當歌:BAAALgAECgQJBQAAAA==.',
['小人']='小人物的逆袭:BAAALgAECgYJCwAAAA==.',
['小屹']='小屹屹:BAAALgAECgQJBAAAAA==.',
['小水']='小水包:BAABLgAFFH8JAAMHAAUJ1wySBgBxAQAHAAUJ1wySBgBxAQAPAAQJfQzICgAqAQAAAA==.',
['小色']='小色牛:BAAALgAECgUJBwAAAA==.',
['小豚']='小豚:BAAALgAECgUJBgAAAA==.',
['尐尐']='尐尐戀歌:BAAALgAFFAMJAwAAAA==.',
['就是']='就是胡子:BAABLgAECn8aAAMQAAcJTg5gGQBsAQAQAAYJTg5gGQBsAQARAAIJLQi7WABkAAAAAA==.',
['布哥']='布哥:BAAALgADCgEJAQAAAA==.',
['幽冥']='幽冥刃舞:BAAALgADCgcJBwAAAA==.',
['弃誓']='弃誓者之舞:BAAALgADCgMJAwAAAA==.',
['强壮']='强壮的坦克:BAAALgAFFAIJBAAAAA==.',
['彩虹']='彩虹会飞:BAAALgAECgUJCAAAAA==.',
['影子']='影子恋人:BAAALgAECgMJAwAAAA==.',
['影落']='影落飞神箭:BAAALgAECgIJAwAAAA==.',
['彼岸']='彼岸妖影:BAAALgAECgEJAQAAAA==.',
['志心']='志心皈命礼:BAAALgAECgMJAwAAAA==.',
['恋爱']='恋爱脑:BAAALgAECgYJBgAAAA==.',
['悬日']='悬日:BAAALgAECgEJAgAAAA==.',
['惩戒']='惩戒奶骑:BAAALgAECgYJBgAAAA==.',
['我想']='我想静静:BAAALgAECgIJAgAAAA==.',
['战刁']='战刁:BAAALgADCgEJAQAAAA==.',
['战刃']='战刃挽歌:BAAALgAECgIJAgABLgAECgcJCwAJAAAAAA==.',
['扑尔']='扑尔敏宁:BAAALgAECgcJBwAAAA==.',
['扶她']='扶她:BAAALgADCgEJAQAAAA==.',
['抱着']='抱着弩:BAAALgAFFAIJAwAAAA==.',
['招魂']='招魂之舟:BAAALgADCgEJAQAAAA==.',
['摇曳']='摇曳之影:BAAALgAECgcJDQAAAA==.',
['文疯']='文疯子:BAAALgAFFAIJAgAAAA==.',
['无事']='无事可乐丶:BAAALgAECgEJAQAAAA==.',
['无双']='无双武圣:BAAALgADCgUJBQAAAA==.',
['无头']='无头苍蝇室友:BAABLgAECn8YAAMEAAcJyBxZOAAUAgAEAAcJvRxZOAAUAgASAAcJ+BMeBABJAQAAAA==.',
['无法']='无法言語的爱:BAAALgAECgMJAwAAAA==.',
['日式']='日式抹茶:BAAALgADCgEJAQAAAA==.',
['时天']='时天使阿蒙:BAABLgAECn8eAAIKAAkJMRRxLgB+AgAKAAkJMRRxLgB+AgAAAA==.',
['昕喵']='昕喵:BAABLgAFFH8IAAIEAAIJCBIHGwCVAAAEAAIJCBIHGwCVAAAAAA==.',
['昵芭']='昵芭变变:BAAALgAECgYJAQAAAA==.昵芭羊羊:BAAALgAECgEJAwAAAA==.',
['暮羽']='暮羽轻弦:BAAALgAECgMJBgAAAA==.',
['有点']='有点乂狂:BAAALgAECgEJAQAAAA==.有点乂疯:BAAALgADCgYJBgAAAA==.',
['杜王']='杜王町乌萨奇:BAAALgADCgYJBgAAAA==.',
['来啊']='来啊美眉:BAAALgAFFAQJBAABLgAFFAYJEwANAMggAA==.',
['杨浦']='杨浦小阿三:BAAALgAECgUJCAAAAA==.杨浦阿四:BAAALgADCgYJBwAAAA==.',
['柑橘']='柑橘乌云:BAAALgAECgQJBAAAAA==.',
['柒宝']='柒宝柒:BAACLgAFFH8FAAIBAAMJAxQVFQDzAAABAAMJAxQVFQDzAAAuAAQKfxsAAgEACQn4FqUbAEgCAAEACQn4FqUbAEgCAAAA.',
['桃也']='桃也丶雾漫漫:BAAALgAECgYJBgAAAA==.桃也雾漫漫:BAAALgAECggJEAAAAA==.',
['梁小']='梁小无拆:BAAALgADCgYJBgAAAA==.',
['梁师']='梁师傅:BAAALgAECgEJAgAAAA==.',
['梦里']='梦里看花:BAAALgAECgIJAgAAAA==.',
['棒棒']='棒棒虫:BAAALgAECgUJBQAAAA==.',
['樱花']='樱花雨:BAAALgAECgYJBgABLgAFFAcJHAAQALgiAA==.',
['歌诗']='歌诗达:BAAALgADCgEJAQAAAA==.',
['歌颂']='歌颂:BAAALgAFFAIJBAAAAA==.',
['歡喜']='歡喜就好:BAAALgAECgEJAQAAAA==.',
['正义']='正义的圣光:BAAALgAECgEJAQAAAA==.',
['正太']='正太猪八戒:BAAALgADCgEJAQAAAA==.',
['武月']='武月花:BAAALgAECgEJAQAAAA==.',
['残夜']='残夜破殇:BAAALgAECgcJCwAAAA==.',
['比比']='比比拉布:BAAALgADCgUJBQAAAA==.',
['泛泛']='泛泛之辈的辈:BAABLgAFFH8IAAICAAMJuxPmKQANAQACAAMJuxPmKQANAQAAAA==.',
['注意']='注意你的态度:BAAALgADCgUJBQAAAA==.',
['洒满']='洒满:BAACLgAFFH8GAAIHAAIJVwakDQCQAAAHAAIJVwakDQCQAAAuAAQKfx0AAgcABwmOFFItALABAAcABwmOFFItALABAAAA.',
['洛书']='洛书丶:BAAALgAECgIJBQAAAA==.',
['流光']='流光嗌彩:BAAALgAECgkJCgAAAA==.',
['浣熊']='浣熊软趴趴:BAAALgAECgkJBAAAAA==.',
['深秋']='深秋寒意:BAABLgAFFH8FAAIKAAIJmhO0PgCiAAAKAAIJmhO0PgCiAAAAAA==.',
['清风']='清风缺月:BAAALgAECgYJBgAAAA==.',
['温柔']='温柔的圣光:BAAALgAECgQJCwAAAA==.',
['湖人']='湖人总冠军:BAAALgAECgUJBQAAAA==.',
['湮花']='湮花不待:BAAALgAECgMJAwAAAA==.',
['漩涡']='漩涡涅槃:BAAALgADCgEJAQAAAA==.',
['漫洛']='漫洛达:BAAALgAECgIJAwAAAA==.',
['火晒']='火晒的神话:BAAALgAFFAEJAQAAAA==.',
['灬楓']='灬楓之貓貓灬:BAAALgAFFAIJAgAAAA==.',
['灬花']='灬花酒貓貓灬:BAAALgAECgMJBQAAAA==.',
['灰烬']='灰烬之刃:BAAALgADCgcJBwAAAA==.',
['灵打']='灵打否:BAAALgAFFAIJAgAAAA==.',
['灵魂']='灵魂借宿丶:BAAALgAECgIJAwAAAA==.',
['点卡']='点卡在燃烧:BAAALgAECgIJAwAAAA==.',
['炽热']='炽热之火:BAAALgAECgQJBAAAAA==.',
['烤奶']='烤奶渣:BAAALgAECgcJDAAAAA==.',
['無尽']='無尽怒火:BAAALgAECgMJAwAAAA==.',
['無極']='無極灬依凝:BAAALgADCgcJBwAAAA==.',
['熊猫']='熊猫快跑:BAAALgADCgMJAwAAAA==.熊猫迷了又迷:BAABLgAECn8WAAMTAAYJmBD5TgAHAQATAAYJmBD5TgAHAQAUAAQJzQaDVgC2AAAAAA==.',
['熹微']='熹微晨巷:BAABLgAECn8UAAIVAAcJXBbbRQCZAQAVAAcJXBbbRQCZAQAAAA==.',
['爆炸']='爆炸输出:BAAALgAECgcJBwAAAA==.',
['爱可']='爱可萌妹:BAAALgADCgEJAQAAAA==.',
['爱抚']='爱抚卡卡:BAAALgAFFAIJAwAAAA==.',
['牛乂']='牛乂甩甩:BAAALgAECgMJAwAAAA==.',
['牢大']='牢大:BAAALgADCgUJBQAAAA==.',
['狂醉']='狂醉:BAAALgAECgYJCgAAAA==.',
['猎客']='猎客:BAAALgAECgMJAwAAAA==.',
['猎心']='猎心姬:BAABLgAECn8lAAIVAAgJMBSoEQCTAQAVAAgJMBSoEQCTAQAAAA==.',
['王德']='王德发:BAAALgAECgYJCwAAAA==.',
['王者']='王者之泪:BAAALgAECgUJBgAAAA==.',
['珐师']='珐师的荣耀丿:BAAALgAECgcJCgAAAA==.',
['瑟里']='瑟里耶克:BAAALgAFFAIJAgAAAA==.',
['甜恩']='甜恩静:BAAALgAECgcJCgAAAA==.',
['甜酥']='甜酥酥小蛋卷:BAABLgAFFH8PAAIWAAQJ4iDXBQB+AQAWAAQJ4iDXBQB+AQAAAA==.',
['白狼']='白狼杰洛特:BAAALgAECgEJAgAAAA==.',
['真没']='真没素质:BAAALgAFFAIJBAAAAA==.',
['破镜']='破镜之刃:BAABLgAFFH8IAAIEAAQJARmPDgBaAQAEAAQJARmPDgBaAQAAAA==.',
['碧空']='碧空雀:BAABLgAFFH8FAAILAAMJWx2wCAD+AAALAAMJWx2wCAD+AAAAAA==.',
['祝您']='祝您永不便秘:BAAALgAECgcJBwAAAA==.',
['章鱼']='章鱼丸:BAAALgAECgYJCwAAAA==.',
['笑忘']='笑忘书:BAAALgAECgcJDAAAAA==.',
['索尼']='索尼亚:BAAALgADCgEJAQAAAA==.',
['红领']='红领章:BAAALgAECgMJAwAAAA==.',
['纯粹']='纯粹灬忽悠你:BAAALgADCgEJAgAAAA==.',
['经典']='经典黑白:BAAALgAECgcJBwAAAA==.',
['维尔']='维尔罗纳:BAAALgAECgEJAQAAAA==.',
['罒丶']='罒丶罒:BAAALgAFFAIJAgAAAA==.',
['老哒']='老哒卟:BAAALgADCgcJBwAAAA==.',
['老挝']='老挝盾牌兵:BAAALgAECgYJCwAAAA==.',
['聖光']='聖光大領主:BAAALgAECgMJAwAAAA==.聖光照啊照:BAAALgADCgYJBgAAAA==.',
['肥嘟']='肥嘟嘟左卫门:BAAALgAFFAUJBAAAAA==.',
['胧月']='胧月纱:BAAALgADCgUJBQAAAA==.',
['膏锋']='膏锋锷:BAAALgAFFAEJAQAAAA==.',
['花城']='花城丶:BAAALgAECgkJAQAAAA==.',
['花雕']='花雕宝宝:BAAALgAECgQJBAAAAA==.',
['苏丽']='苏丽珍:BAAALgAECgYJDAAAAA==.',
['若离']='若离:BAAALgAECgcJDgAAAA==.',
['英雄']='英雄:BAAALgAECgYJDAAAAA==.',
['苹果']='苹果:BAAALgAECgIJBQAAAA==.苹果核:BAAALgAECgEJAQAAAA==.',
['茉雅']='茉雅:BAAALgAECgYJCgAAAA==.',
['莉莉']='莉莉亚斯:BAAALgAECgcJEAAAAA==.',
['菲尼']='菲尼克斯特:BAABLgAFFH8FAAMBAAQJtQg6BQDHAAABAAMJBws6BQDHAAAVAAEJvgHRIABHAAAAAA==.',
['萌之']='萌之痴痴:BAAALgADCgUJBQAAAA==.',
['萌萌']='萌萌喵:BAAALgADCgEJAQAAAA==.',
['萌还']='萌还痴痴:BAAALgADCgEJAQAAAA==.',
['萧葑']='萧葑魄谇:BAAALgAFFAIJBAAAAA==.',
['蒙牛']='蒙牛纯牛奶:BAAALgAECgEJAQAAAA==.',
['薄暮']='薄暮晨光:BAABLgAECn8ZAAIFAAcJyCDqBQA9AgAFAAcJyCDqBQA9AgAAAA==.',
['衰灬']='衰灬劣人:BAABLgAECn8UAAIVAAYJcxWgQQCpAQAVAAYJcxWgQQCpAQAAAA==.',
['裁决']='裁决:BAAALgAFFAQJBAAAAA==.',
['西装']='西装逗:BAAALgAFFAEJAQAAAA==.',
['諸神']='諸神之戰:BAAALgAECggJDQAAAA==.',
['让左']='让左泪死:BAAALgAECgEJAQAAAA==.',
['败爷']='败爷丶:BAAALgAECgkJCQAAAA==.',
['输出']='输出基本靠吼:BAAALgAECgcJCwAAAA==.',
['达里']='达里尔:BAAALgAECgkJDgAAAA==.',
['迷逗']='迷逗白:BAAALgADCgEJAQAAAA==.',
['逆天']='逆天丶凋零者:BAAALgAECgIJAQAAAA==.',
['遗忘']='遗忘欧若拉:BAAALgAFFAEJAQABLgAFFAIJAgAJAAAAAA==.',
['邋遢']='邋遢大叔:BAAALgADCgIJAgAAAA==.',
['郭靖']='郭靖:BAAALgAECgEJAQAAAA==.',
['酸梨']='酸梨:BAAALgADCgMJAwAAAA==.',
['酸葱']='酸葱:BAAALgAECgkJBgAAAA==.',
['醉挽']='醉挽霜风:BAAALgAECgYJEAAAAA==.',
['醉美']='醉美:BAAALgADCgYJCgAAAA==.',
['铁须']='铁须的神话:BAAALgAECgEJAQAAAA==.',
['铅华']='铅华录:BAAALgAECgcJBwAAAA==.',
['閻魔']='閻魔丶愛:BAAALgADCgEJAQAAAA==.',
['闪电']='闪电风暴:BAAALgAFFAIJAgAAAA==.',
['阿丢']='阿丢丢:BAAALgAECgUJBgAAAA==.',
['阿禅']='阿禅:BAAALgADCgYJDwAAAA==.',
['阿莫']='阿莫西林天尊:BAAALgAECgQJBQAAAA==.',
['陆沉']='陆沉的狗:BAAALgAFFAIJAgAAAA==.',
['陈大']='陈大油:BAAALgAECgQJBQAAAA==.',
['陈暖']='陈暖树:BAAALgAECgcJBwAAAA==.',
['风中']='风中风:BAAALgAECgQJBQAAAA==.',
['风睚']='风睚:BAAALgAECgcJDQAAAA==.',
['飞龙']='飞龙:BAABLgAFFH8IAAMXAAQJqAszBwDxAAAXAAQJqAszBwDxAAAYAAEJ4Q3bCwBTAAAAAA==.',
['魔神']='魔神笔笔:BAAALgAECgIJAgAAAA==.',
['鲁鲁']='鲁鲁伊:BAAALgAECggJDgABLgAECggJJQAVADAUAA==.',
['鲍抱']='鲍抱:BAAALgAECgcJCAAAAA==.',
['鸠摩']='鸠摩智:BAAALgADCgEJAQAAAA==.',
['鸡飞']='鸡飞狗跳:BAAALgAECgEJAgAAAA==.',
['黄色']='黄色潜水艇:BAABLgAFFH8FAAMLAAIJgxEXDQAzAAAKAAIJgQ8bQQCfAAALAAIJFQgXDQAzAAAAAA==.',
['龙瞑']='龙瞑散人:BAAALgADCgUJBQAAAA==.',
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
