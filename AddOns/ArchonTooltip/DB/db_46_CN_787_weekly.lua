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

local lookup = {'Druid-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','DeathKnight-Blood','Warlock-Demonology','Evoker-Preservation','Evoker-Augmentation','Warrior-Fury','Evoker-Devastation','Unknown-Unknown','Warrior-Arms','Monk-Brewmaster','DemonHunter-Devourer','Priest-Holy','Priest-Shadow','Priest-Discipline','DeathKnight-Unholy','Mage-Frost','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Rogue-Subtlety','Shaman-Elemental','Shaman-Restoration',}
local provider = {region='CN',realm='纳克萨玛斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Absol:BAAALgAFFAIJAwAAAA==.',
Am='Amani:BAAALgAECgIJAgAAAA==.',
Ax='Axiaoai:BAAALgADCgUJBQAAAA==.',
Be='Bella:BAAALgAECgQJBAAAAA==.',
Cp='Cpwlnda:BAAALgAFFAIJAgAAAA==.',
Du='Dunkelkreuz:BAAALgADCgEJAQAAAA==.',
Ee='Ee:BAAALgAFFAMJAwABLgAFFAcJDwABAJIXAA==.',
Fl='Flyingphenix:BAAALgAECgYJCwAAAA==.',
Ga='Galaxyj:BAACLgAFFH8IAAMCAAQJXBSjBQBBAQACAAQJXBSjBQBBAQADAAEJWQnbKQBIAAAuAAQKfycAAwIACAldHeQLAM8BAAMACAnpGYoZAFsCAAIABgl1HuQLAM8BAAAA.',
Gr='Groupiesl:BAAALgAECgEJAgAAAA==.',
Ha='Haerin:BAAALgAECgYJBgAAAA==.Happinezz:BAABLgAFFH8GAAIEAAMJvhZOAgATAQAEAAMJvhZOAgATAQAAAA==.Hardcandy:BAABLgAECn8WAAMCAAkJ6iCrAgBsAwACAAkJ6iCrAgBsAwADAAYJCxPjRgA4AQAAAA==.',
Lk='Lkasjdflj:BAAALgADCgQJBAAAAA==.',
Ma='Maverick:BAAALgADCgEJAQAAAA==.',
Mo='Moneybee:BAAALgADCgQJBAAAAA==.',
Pi='Pino:BAAALgAFFAIJAwAAAA==.',
Pl='Playervejyke:BAAALgAECgQJCwAAAA==.',
Ri='Rita:BAAALgAFFAEJAQAAAA==.',
Sa='Saoe:BAAALgAECgYJBgAAAA==.',
Se='Seath:BAAALgAECgYJBwAAAA==.',
Sn='Snadow:BAAALgAECgcJBwAAAA==.',
Sp='Spellbreake:BAAALgAECgUJBgAAAA==.',
Tn='Tneisnart:BAAALgAFFAMJAwAAAA==.',
Xs='Xsevendady:BAAALgAECgEJAQAAAA==.',
['七侠']='七侠荡寇:BAAALgAECgEJAQAAAA==.',
['万奴']='万奴之王:BAAALgAECgMJAwAAAA==.',
['专业']='专业卖萌:BAAALgADCgIJAgAAAA==.',
['个性']='个性埘玳:BAABLgAECn8YAAIBAAkJJxcgHABbAgABAAkJJxcgHABbAgAAAA==.',
['丶丶']='丶丶八:BAABLgAFFH8IAAIFAAQJQhaBBgAuAQAFAAQJQhaBBgAuAQAAAA==.',
['丿酒']='丿酒仙丨傻馒:BAAALgAECgQJBgAAAA==.',
['乄花']='乄花葬乄:BAAALgAECgUJBQAAAA==.',
['九天']='九天暗风:BAABLgAECn8VAAIGAAgJUg15GAByAQAGAAgJUg15GAByAQAAAA==.',
['仁醫']='仁醫:BAAALgAECgIJBAAAAA==.',
['今宵']='今宵别梦寒:BAAALgAECgEJAgAAAA==.',
['仰望']='仰望星空:BAAALgAECgQJBQAAAA==.',
['伊利']='伊利安慕希:BAAALgADCgIJAgAAAA==.',
['你是']='你是龙也好:BAABLgAECn8UAAMHAAgJxQ0yHwCGAQAHAAcJgA8yHwCGAQAIAAUJMQ9UOgAJAQAAAA==.',
['佩里']='佩里柯洁:BAAALgAECgEJAQAAAA==.',
['俾面']='俾面派对:BAAALgAECgcJAwAAAA==.',
['偏要']='偏要吃兔兔丶:BAAALgAECgcJCQABLgAFFAMJCgAJANgXAA==.',
['兄弟']='兄弟盟血羽:BAAALgAECgEJAQAAAA==.',
['光明']='光明神王:BAAALgADCgEJAQAAAA==.',
['光脚']='光脚丫:BAAALgAECgQJBQAAAA==.',
['光鳞']='光鳞:BAAALgAFFAMJBAAAAA==.',
['克里']='克里斯波什:BAABLgAFFH8FAAMKAAMJGAuJBgCmAAAKAAIJuwyJBgCmAAAIAAIJmAiXGgCXAAAAAA==.',
['冰川']='冰川葬华佗:BAAALgADCgUJBQAAAA==.',
['冲锋']='冲锋的牛:BAAALgAECgQJBgAAAA==.',
['凌冽']='凌冽寒冬:BAAALgADCgcJBwAAAA==.',
['凶貓']='凶貓笔芯:BAAALgAFFAEJAQAAAA==.',
['刚铎']='刚铎:BAAALgAECgEJAQABLgAFFAMJBAALAAAAAA==.',
['刺骨']='刺骨寒冬:BAAALgADCgEJAQABLgAFFAMJAwALAAAAAA==.',
['办她']='办她:BAAALgAECgMJBAAAAA==.',
['劳登']='劳登尔西亚:BAAALgADCgIJAgAAAA==.',
['勇敢']='勇敢的牛仔:BAAALgAECgkJCQAAAA==.',
['北将']='北将七:BAABLgAFFH8JAAIMAAMJDSL+AQAsAQAMAAMJDSL+AQAsAQABLgAFFAQJDQAMAJQaAA==.',
['医护']='医护骑士:BAAALgADCgMJAwAAAA==.',
['千山']='千山风云过:BAAALgAECgEJAQAAAA==.',
['南湖']='南湖东:BAACLgAFFH8IAAIMAAMJIyG2AgA4AQAMAAMJIyG2AgA4AQAuAAQKfxkAAgwACAmWHLACAPECAAwACAmWHLACAPECAAEuAAUUBAkNAAwAlBoA.',
['古蛋']='古蛋:BAAALgADCgEJAQAAAA==.',
['呆呆']='呆呆的看她:BAAALgAECgYJBgABLgAFFAcJCwANAM0PAA==.',
['呼啦']='呼啦:BAAALgAFFAIJAgABLgAFFAMJAwALAAAAAA==.',
['咪莉']='咪莉娅:BAAALgAECgEJAQAAAA==.',
['哈利']='哈利波特别大:BAAALgAECgUJBQAAAA==.',
['哈吉']='哈吉米的春天:BAAALgADCgEJAQAAAA==.',
['啊哒']='啊哒哒:BAAALgADCgUJBQAAAA==.',
['噬灭']='噬灭:BAABLgAECn8VAAIOAAYJ4RtjRQDeAQAOAAYJ4RtjRQDeAQAAAA==.',
['回幼']='回幼儿园深造:BAAALgAECgEJAQAAAA==.',
['土猫']='土猫:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光棍骑士团:BAAALgAECgYJCAAAAA==.圣光钕神:BAAALgADCgEJAQAAAA==.',
['圣殿']='圣殿的旋律:BAAALgADCgQJBAAAAA==.',
['地狱']='地狱嚎叫:BAAALgAECgMJAwAAAA==.',
['墨雨']='墨雨:BAAALgAECgcJCQAAAA==.',
['壮志']='壮志凌雲:BAAALgADCgEJAQAAAA==.',
['夜色']='夜色暮雪:BAAALgAECgMJAQAAAA==.',
['大地']='大地之灵萨尔:BAAALgADCgQJAgAAAA==.大地之灵酒神:BAAALgAECgEJAQAAAA==.',
['大拳']='大拳头:BAAALgAECgYJBgAAAA==.',
['大米']='大米稀饭:BAAALgAECgIJAgAAAA==.',
['夺妻']='夺妻断手丶:BAAALgADCgUJBAAAAA==.',
['奶思']='奶思兔咪特悠:BAAALgAECgUJBQAAAA==.',
['奶糖']='奶糖丶:BAACLgAFFH8FAAMPAAMJtRBtBwD4AAAPAAMJtRBtBwD4AAAQAAEJGgjNFQBMAAAuAAQKfxgAAw8ABwlaIFYQAGICAA8ABwlaIFYQAGICABAAAwmfBQ5UAHQAAAAA.',
['妹子']='妹子你站住丷:BAAALgAECgQJBAAAAA==.',
['嬌嫩']='嬌嫩華貴妃:BAAALgAECggJAQAAAA==.',
['宇宙']='宇宙时光:BAAALgAECgEJAQAAAA==.',
['寂灭']='寂灭颂歌:BAAALgAECgEJAQAAAA==.',
['小棉']='小棉花球:BAAALgADCgYJBgAAAA==.小棉花餹:BAAALgAECgEJAQAAAA==.',
['小花']='小花生:BAAALgAECgcJBwAAAA==.',
['小路']='小路老师:BAABLgAFFH8FAAIRAAMJrhVhDQD1AAARAAMJrhVhDQD1AAAAAA==.',
['山岳']='山岳之力:BAAALgADCggJCgAAAA==.',
['希尔']='希尔瓦娜嘶:BAAALgADCgYJBgAAAA==.',
['幺婶']='幺婶儿:BAAALgAECgIJAgAAAA==.',
['彡影']='彡影丶行者灬:BAAALgADCgEJAQAAAA==.',
['彩虹']='彩虹色的红:BAABLgAFFH8FAAIJAAMJqQ03EgD0AAAJAAMJqQ03EgD0AAAAAA==.',
['怒牛']='怒牛发呆:BAAALgAECgQJBAAAAA==.',
['恰克']='恰克:BAAALgADCgMJAwAAAA==.',
['恶魔']='恶魔在背后:BAAALgAECgYJBgAAAA==.',
['悠悠']='悠悠小凡:BAAALgAECgUJBgAAAA==.悠悠萌宝宝:BAABLgAECn8ZAAMCAAcJJhsFDADNAQACAAcJJhsFDADNAQAEAAQJ9wNeIwCzAAAAAA==.',
['情人']='情人:BAABLgAFFH8GAAIJAAQJvAziBAAzAQAJAAQJvAziBAAzAQAAAA==.',
['想想']='想想:BAAALgADCgUJBQAAAA==.',
['想赢']='想赢:BAAALgAECgEJAQAAAA==.',
['懓娜']='懓娜娜:BAAALgAFFAEJAQAAAA==.',
['我勒']='我勒个韶钢:BAAALgAECgcJDAAAAA==.',
['我爱']='我爱冰美式:BAAALgAECgEJAQAAAA==.',
['我要']='我要去远方:BAAALgAFFAIJBAAAAA==.',
['我还']='我还要去远方:BAAALgAECgEJAQAAAA==.',
['戰狼']='戰狼之狼:BAAALgAECgcJBwAAAA==.',
['戰骑']='戰骑:BAAALgADCgMJAwAAAA==.',
['所遇']='所遇皆良缘:BAAALgADCgEJAQABLgAFFAQJCAACABkWAA==.',
['按摩']='按摩院首座:BAAALgAECgYJCAAAAA==.',
['擦扁']='擦扁球:BAAALgAECgQJCAAAAA==.',
['放浪']='放浪的財子:BAABLgAECn8XAAMSAAcJARbRZgDBAQASAAcJUxXRZgDBAQAFAAIJnwSXRAA2AAAAAA==.',
['斑斑']='斑斑点点:BAAALgAECgYJBgAAAA==.',
['无尽']='无尽的回忆:BAACLgAFFH8FAAIBAAMJ6xTrDgD4AAABAAMJ6xTrDgD4AAAuAAQKfxoAAgEACAl+IJoQALMCAAEACAl+IJoQALMCAAAA.',
['晓得']='晓得怎摸样:BAAALgADCgQJBAAAAA==.',
['暖风']='暖风:BAAALgADCgUJBQAAAA==.',
['暗天']='暗天之妖雪:BAAALgAECgcJDwAAAA==.',
['暗行']='暗行狱史:BAABLgAECn8VAAMDAAcJ/RmTMACvAQADAAYJfRqTMACvAQACAAMJ8RWZhwDRAAAAAA==.',
['月光']='月光玛奇朵:BAAALgAECgEJAQAAAA==.',
['杨国']='杨国福麻辣拌:BAAALgAECgIJAgABLgAECgYJCgALAAAAAA==.',
['标准']='标准结题:BAAALgAECgQJBAAAAA==.',
['树鸟']='树鸟熊猫:BAAALgAECgQJBgAAAA==.',
['桃气']='桃气泡泡:BAAALgAECgcJEAAAAA==.',
['梦境']='梦境缠绕:BAAALgADCgYJBgAAAA==.',
['棈灵']='棈灵坏汶汶:BAAALgAFFAEJAQAAAA==.',
['楚乄']='楚乄:BAAALgAECgQJCQAAAA==.',
['楼兰']='楼兰绮綾:BAAALgAECgEJAQAAAA==.',
['榴莲']='榴莲披萨:BAAALgAECgYJBwAAAA==.',
['欢与']='欢与欢丶兮:BAAALgAECgQJBAAAAA==.欢与欢兮:BAAALgAECgQJBAAAAA==.',
['歸來']='歸來的王子:BAAALgAECgQJBAAAAA==.',
['死神']='死神阿信:BAAALgAECgYJDAAAAA==.',
['水灵']='水灵依素:BAAALgAECgcJDQAAAA==.',
['氵伈']='氵伈佄灬启:BAAALgADCgkJCgAAAA==.',
['沃去']='沃去:BAAALgAECgYJCAAAAA==.',
['没梦']='没梦想的咸鱼:BAACLgAFFH8OAAITAAQJfCKiDwCaAQATAAQJfCKiDwCaAQAuAAQKfyMAAhMABwmkJe8fAPUCABMABwmkJe8fAPUCAAAA.',
['泡泡']='泡泡龙:BAAALgAECgYJDQAAAA==.',
['派大']='派大小星星:BAAALgAECgQJBAAAAA==.',
['流小']='流小雨:BAAALgAECgEJAQABLgAFFAMJBAALAAAAAA==.',
['流羽']='流羽:BAAALgADCgEJAQABLgAFFAMJBAALAAAAAA==.',
['浮生']='浮生残梦:BAAALgAECgMJAwAAAA==.',
['涟漪']='涟漪之秀:BAABLgAECn8ZAAIUAAcJkAvnhQBuAQAUAAcJkAvnhQBuAQAAAA==.',
['温水']='温水小鞠:BAAALgAECgEJAQAAAA==.温水杏菜:BAABLgAFFH8NAAIBAAQJvRv2BABPAQABAAQJvRv2BABPAQAAAA==.温水柠檬:BAAALgAECgYJBgABLgAFFAQJDQABAL0bAA==.',
['温酒']='温酒斩华佗:BAAALgAFFAEJAQAAAA==.',
['湖人']='湖人:BAABLgAFFH8FAAINAAMJCwPnFwCwAAANAAMJCwPnFwCwAAAAAA==.',
['火腿']='火腿炒饭丶:BAAALgAECgEJAQAAAA==.',
['灬佬']='灬佬龍乤灬:BAAALgAECgcJEgAAAA==.',
['灬苍']='灬苍丨月灬:BAAALgADCgYJCQAAAA==.',
['熊杨']='熊杨:BAAALgAFFAEJAQAAAA==.',
['爱之']='爱之六翼天使:BAAALgAECgkJAQAAAA==.',
['爱德']='爱德华纽盖特:BAAALgAECgYJBgAAAA==.',
['牢猫']='牢猫:BAABLgAFFH8GAAICAAIJbSRiDwDNAAACAAIJbSRiDwDNAAAAAA==.',
['牧丶']='牧丶勿念:BAAALgAFFAIJAwAAAA==.',
['猎物']='猎物:BAAALgAECgEJAgAAAA==.',
['猎猎']='猎猎黑巧:BAAALgAFFAIJAgAAAA==.',
['猫爪']='猫爪:BAAALgAECgIJAgAAAA==.',
['玃如']='玃如:BAAALgAECgYJDgAAAA==.',
['画画']='画画的北北:BAAALgADCgMJBAAAAA==.',
['疾风']='疾风剑濠:BAAALgAECgIJAgAAAA==.',
['痛苦']='痛苦的谜情:BAAALgAECgUJBQAAAA==.',
['痴道']='痴道:BAAALgAECgcJAQAAAA==.',
['白兔']='白兔茕茕:BAAALgAECgEJAQAAAA==.',
['白色']='白色乐章:BAAALgAECgMJBAAAAA==.',
['相对']='相对亦忘言丶:BAACLgAFFH8FAAIBAAMJ6h6WDQANAQABAAMJ6h6WDQANAQAuAAQKfx0AAgEABglZJX0ZAGwCAAEABglZJX0ZAGwCAAAA.',
['瞬间']='瞬间丨永恒:BAAALgAECgEJAQAAAA==.',
['神也']='神也低调:BAAALgAECgYJBgAAAA==.',
['神圣']='神圣干涉:BAABLgAFFH8FAAMUAAIJqh+FEQC9AAAUAAIJqh+FEQC9AAAVAAEJJgfZCAAuAAAAAA==.',
['福尔']='福尔摩斯先生:BAAALgAECgUJBQAAAA==.',
['秋叶']='秋叶木枫:BAAALgADCgQJBQAAAA==.',
['秋风']='秋风只影:BAAALgAFFAIJAwAAAA==.',
['科比']='科比:BAAALgAECgMJBAAAAA==.',
['立秋']='立秋:BAAALgAECgEJAwAAAA==.',
['粉沫']='粉沫:BAAALgAECgYJCwAAAA==.',
['索然']='索然丶无味:BAAALgAECgcJBwAAAA==.',
['紫丶']='紫丶汐:BAAALgAFFAEJAQAAAA==.',
['繁星']='繁星:BAAALgAECggJBgAAAA==.',
['红小']='红小樱:BAAALgAECgcJDAAAAA==.',
['红手']='红手小蹄子:BAAALgAFFAEJAQAAAA==.红手法小诗:BAAALgAECgYJBwAAAA==.红手龙战:BAAALgAECgYJCQAAAA==.',
['纯情']='纯情青年:BAAALgAFFAEJAQAAAA==.',
['绿小']='绿小野:BAAALgAECgUJBgAAAA==.',
['绿绿']='绿绿:BAAALgAECgkJDwAAAA==.',
['缘来']='缘来如此:BAAALgAFFAEJAQAAAA==.',
['翠花']='翠花上电棍:BAAALgAECgcJBwAAAA==.',
['老嬢']='老嬢嬢:BAAALgAECgYJEwAAAA==.',
['脑人']='脑人人:BAAALgAECgYJCgAAAA==.',
['良缘']='良缘:BAAALgAFFAIJBAAAAA==.',
['艾梵']='艾梵达尔:BAAALgAECgQJCAAAAA==.',
['芒果']='芒果欧蕾:BAAALgAECgcJCwAAAA==.',
['芝芝']='芝芝芒芒:BAAALgADCgUJBQABLgAECgcJEAALAAAAAA==.',
['草原']='草原牛王:BAAALgAECgQJBAAAAA==.',
['莉泽']='莉泽罗忒:BAAALgAECgMJBAAAAA==.',
['落花']='落花成塚:BAABLgAECn8aAAIWAAcJnhX7KQDhAQAWAAcJnhX7KQDhAQAAAA==.',
['落魄']='落魄的旋律丶:BAAALgAECgEJAQAAAA==.',
['蓝博']='蓝博:BAAALgAECgYJDQAAAA==.',
['蓝色']='蓝色的雷:BAAALgAECgIJAwAAAA==.',
['薄荷']='薄荷糖丶:BAABLgAFFH8IAAICAAQJGRb/BABTAQACAAQJGRb/BABTAQAAAA==.',
['虚空']='虚空堂堂聚合:BAAALgAECgYJEAAAAA==.',
['蚀魂']='蚀魂狂魔:BAAALgAFFAIJAwAAAA==.',
['蝴蝶']='蝴蝶满园春:BAAALgAECgQJBgAAAA==.',
['血夜']='血夜红魔:BAAALgADCgEJAQAAAA==.',
['血斩']='血斩丶沸:BAABLgAFFH8FAAIXAAMJ+x3NCwAmAQAXAAMJ+x3NCwAmAQAAAA==.',
['諸葛']='諸葛孔眀:BAAALgAECgYJCwAAAA==.',
['请叫']='请叫我灰太狼:BAAALgADCgEJAQAAAA==.',
['谜情']='谜情:BAAALgADCgIJAgAAAA==.',
['赫塞']='赫塞汀:BAAALgAECgcJDQAAAA==.',
['近战']='近战五码分散:BAAALgADCgEJAQABLgAFFAMJBAALAAAAAA==.',
['迷迭']='迷迭香:BAAALgAFFAMJAwAAAA==.',
['道法']='道法:BAAALgAECgUJBQAAAA==.',
['道观']='道观道:BAAALgADCgEJAQAAAA==.',
['遗忘']='遗忘原諒:BAAALgAECgYJCAAAAA==.遗忘的背叛者:BAAALgAFFAIJAgAAAA==.',
['醉卧']='醉卧看斜阳:BAABLgAECn8YAAIXAAcJqBGPJwC8AQAXAAcJqBGPJwC8AQAAAA==.',
['释茄']='释茄摸妮:BAAALgADCgUJBQAAAA==.',
['釒熊']='釒熊猫:BAABLgAFFH8GAAIUAAMJ9xt8DQD5AAAUAAMJ9xt8DQD5AAAAAA==.釒熊貓:BAAALgADCgYJBgAAAA==.',
['银丶']='银丶月:BAAALgAECgEJAQABLgAFFAQJBAALAAAAAA==.',
['阿尔']='阿尔灬帕西诺:BAAALgAECgIJAgAAAA==.',
['陈大']='陈大黑:BAABLgAFFH8NAAIMAAQJlBoEAQBvAQAMAAQJlBoEAQBvAQAAAA==.',
['随遇']='随遇而安:BAAALgADCgIJAgAAAA==.',
['雷霆']='雷霆妞妞:BAABLgAECn8VAAMYAAcJTRthHwAVAgAYAAcJTRthHwAVAgAZAAEJGwg9nQA0AAAAAA==.',
['雾绡']='雾绡拂青溪:BAAALgADCgUJBQAAAA==.',
['霜之']='霜之骨陵:BAAALgAFFAIJAgAAAA==.',
['风一']='风一样的男人:BAAALgADCgUJBQAAAA==.',
['风剑']='风剑雅:BAAALgAECgQJBwABLgAFFAEJAQALAAAAAA==.',
['鬼鬼']='鬼鬼笑笑:BAAALgAECgEJAQAAAA==.',
['魔魔']='魔魔法:BAAALgAECgYJCAAAAA==.',
['鲜血']='鲜血毒牙:BAACLgAFFH8JAAMCAAQJOhCsEAC0AAADAAMJbgpRGADOAAACAAIJ0xisEAC0AAAuAAQKfxsAAwMACAl4HxIdADwCAAMABwnhHhIdADwCAAIAAQkCI0qtAGkAAAAA.',
['麦香']='麦香狗:BAAALgAECgYJBgAAAA==.',
['黄昏']='黄昏的乐章:BAAALgAECgYJDQAAAA==.',
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
