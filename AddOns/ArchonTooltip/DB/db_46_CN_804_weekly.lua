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

local lookup = {'Rogue-Subtlety','Mage-Frost','Druid-Balance','Druid-Restoration','Warrior-Fury','Shaman-Elemental','Shaman-Restoration','Evoker-Augmentation','Hunter-Marksmanship','Warlock-Demonology','DemonHunter-Devourer','Paladin-Retribution','Hunter-BeastMastery','Unknown-Unknown','Warlock-Destruction','Rogue-Assassination','Priest-Shadow','Evoker-Preservation','DeathKnight-Unholy','Priest-Discipline','Priest-Holy','Mage-Fire','Warrior-Protection','DeathKnight-Blood','DemonHunter-Havoc','DeathKnight-Frost','Monk-Mistweaver','Warrior-Arms','Monk-Brewmaster','Paladin-Holy','Druid-Feral','Hunter-Survival','Monk-Windwalker',}
local provider = {region='CN',realm='艾露恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Agoni:BAAALgAECgEJAQAAAA==.',
Am='Ameiyi:BAAALgAECgUJBQAAAA==.',
Ba='Barrya:BAAALgADCgEJAQABLgAFFAUJDQABABEaAA==.',
Bi='Biuboom:BAAALgAECgMJAwAAAA==.',
Bl='Blackmemory:BAAALgAECgkJDQAAAA==.',
Ce='Cesare:BAAALgAECgEJAQAAAA==.',
Co='Corgi:BAAALgADCgUJCQAAAA==.',
Da='Darkdurex:BAAALgAECgcJBwAAAA==.',
El='Electroly:BAAALgAECgQJBAAAAA==.',
Fo='Foley:BAAALgAECgQJBgABLgAFFAMJCAACAGgDAA==.',
Ga='Galaxyangle:BAAALgAECgEJAQAAAA==.',
Gg='Ggentleman:BAAALgAECgEJAQAAAA==.',
Ho='Hodge:BAABLgAECn8eAAMDAAgJyho8EQCTAgADAAgJyho8EQCTAgAEAAEJ/wty1AArAAAAAA==.Honour:BAABLgAFFH8GAAIFAAMJkhURCAD+AAAFAAMJkhURCAD+AAAAAA==.Horzin:BAAALgADCgUJBQAAAA==.',
In='Inariel:BAAALgAECgEJAwAAAA==.',
Jo='Jokergs:BAAALgAECgcJBwAAAA==.Jokersm:BAABLgAFFH8FAAIGAAMJSRUtDwD8AAAGAAMJSRUtDwD8AAAAAA==.Jokerss:BAAALgAFFAQJBAAAAA==.Jokerzs:BAAALgAECgYJCQAAAA==.',
Ju='Juzzth:BAAALgAFFAEJAQAAAA==.',
Ke='Kellies:BAAALgAECgYJCAAAAA==.',
Kh='Kharif:BAAALgAECgIJAgAAAA==.',
Ko='Komorebix:BAAALgAFFAQJBAAAAA==.',
Kr='Kralph:BAABLgAFFH8FAAIHAAMJQBT6DgDxAAAHAAMJQBT6DgDxAAAAAA==.',
La='Langley:BAACLgAFFH8JAAICAAMJqxDOKgAKAQACAAMJqxDOKgAKAQAuAAQKfyAAAgIABgniHBVrAP8BAAIABgniHBVrAP8BAAAA.',
Ma='Marxism:BAAALgAECgYJCgAAAA==.',
Nb='Nbzs:BAAALgADCgQJBAAAAA==.',
On='Online:BAAALgAECgMJAwAAAA==.',
Pe='Pestilence:BAAALgAECgYJDAAAAA==.',
Po='Pokemongo:BAAALgAECgMJAwABLgAFFAMJBQAIAEwPAA==.',
Sh='Shuyedk:BAAALgAFFAMJAwAAAA==.Shuyelr:BAAALgAECgkJEAABLgAFFAUJCgAJAPEQAA==.',
Sp='Spellbreaker:BAAALgAECgEJAQAAAA==.Spike:BAAALgADCgcJBwAAAA==.',
Ta='Taygeta:BAAALgAECgkJAwAAAA==.',
Te='Tedfans:BAAALgAECgYJDAAAAA==.',
Ti='Tikorei:BAACLgAFFH8OAAICAAUJIB/rBACIAQACAAUJIB/rBACIAQAuAAQKfxQAAgIABwl5IjQ7AIoCAAIABwl5IjQ7AIoCAAAA.',
Un='Unclej:BAAALgAECgIJAQAAAA==.',
Vi='Vieruodis:BAAALgAECgEJAQAAAA==.Vincentia:BAAALgAFFAMJAwAAAA==.',
We='Weiwei:BAABLgAFFH8EAAIKAAQJRxcLBgBkAQAKAAQJRxcLBgBkAQAAAA==.',
Xd='Xdrag:BAAALgADCgEJAQABLgAFFAIJBQALAFgQAA==.',
Xm='Xmres:BAABLgAFFH8FAAILAAIJWBA4KAChAAALAAIJWBA4KAChAAAAAA==.',
Yu='Yujie:BAAALgAFFAEJAQAAAA==.Yukitoki:BAAALgAECgMJAwAAAA==.',
Zz='Zzx:BAAALgAECgkJDQAAAA==.',
['一个']='一个驭兽师:BAAALgAECgUJBQAAAA==.',
['一之']='一之助:BAAALgAECgYJCQAAAA==.',
['一剑']='一剑霜月寒:BAAALgADCgYJCAAAAA==.',
['一方']='一方神圣:BAAALgAECgkJBwAAAA==.',
['一无']='一无灬所有:BAAALgADCgEJAQAAAA==.',
['一朵']='一朵雨云:BAAALgADCgYJBgAAAA==.',
['一杯']='一杯丶冰美式:BAAALgAECgcJBwAAAA==.',
['七宝']='七宝妙熊:BAAALgAECgEJAQAAAA==.',
['万雷']='万雷天牢引:BAAALgAECgUJCgAAAA==.',
['三千']='三千:BAAALgAECgYJBgAAAA==.',
['不二']='不二丨:BAAALgADCgUJBwAAAA==.不二爱丢东西:BAAALgAECgQJBgAAAA==.',
['不会']='不会起名儿:BAABLgAFFH8FAAIMAAMJQA0fFwD0AAAMAAMJQA0fFwD0AAABLgAFFAQJBwAKAC8SAA==.',
['不咬']='不咬人恶心人:BAAALgADCgYJBgAAAA==.',
['不抢']='不抢电脑:BAAALgAECgcJAQAAAA==.',
['不讲']='不讲道德灬:BAAALgADCgcJBgAAAA==.',
['不语']='不语的娃哥:BAACLgAFFH8FAAIMAAQJVQS+CQAYAQAMAAQJVQS+CQAYAQAuAAQKfxkAAgwABwlFGKcVAJoBAAwABwlFGKcVAJoBAAAA.',
['与你']='与你同在:BAAALgADCgEJAQAAAA==.',
['两个']='两个确立:BAAALgAECgQJBAAAAA==.',
['丨南']='丨南明离火:BAAALgAECgEJAQAAAA==.',
['丨君']='丨君莫笑:BAAALgAECgEJAQAAAA==.',
['丨大']='丨大鹅本鹅丨:BAABLgAECn8UAAINAAcJKiLzDQDOAgANAAcJKiLzDQDOAgAAAA==.',
['丨犽']='丨犽羽獠丨:BAAALgADCgUJBQAAAA==.',
['丶光']='丶光头加暴击:BAAALgAECgEJAQAAAA==.',
['丶嚞']='丶嚞:BAAALgAECgcJBQAAAA==.',
['丶游']='丶游神:BAAALgAECgQJBQAAAA==.',
['丶翩']='丶翩若惊鸿:BAAALgAECgYJBgAAAA==.',
['久别']='久别无恙:BAAALgAECgEJAQAAAA==.',
['乌瑟']='乌瑟尔丶:BAAALgADCgYJBgAAAA==.',
['乌露']='乌露露:BAAALgAECgUJBQAAAA==.',
['九久']='九久:BAAALgAECgIJAgAAAA==.',
['也曾']='也曾信仰圣光:BAAALgAECgYJBwAAAA==.',
['云湮']='云湮:BAAALgADCgUJBQAAAA==.',
['亮亮']='亮亮的皮皮:BAAALgAECgQJCgAAAA==.',
['人蠢']='人蠢冇药医:BAAALgAECgMJAwAAAA==.',
['人造']='人造丶十八号:BAAALgAECgUJBwAAAA==.',
['企鹅']='企鹅岛:BAAALgAECgEJAQAAAA==.',
['伊斯']='伊斯瑞尔:BAABLgAFFH8JAAIMAAQJtg5LDgA4AQAMAAQJtg5LDgA4AQABLgAFFAYJGAAGAB4dAA==.',
['你看']='你看美不美灬:BAAALgAECggJAwAAAA==.',
['佬司']='佬司机:BAABLgAECn8VAAIHAAcJ2x/REgB/AgAHAAcJ2x/REgB/AgAAAA==.',
['修罗']='修罗骑士:BAAALgADCgUJDAAAAA==.',
['俱是']='俱是梦中人:BAAALgAECgEJAQAAAA==.',
['倒头']='倒头就睡:BAAALgAECgYJBgAAAA==.',
['元素']='元素不理我了:BAAALgADCgcJBwAAAA==.',
['克拉']='克拉克:BAAALgAECgYJBgABLgAFFAUJBQAKAKQVAA==.',
['六个']='六个苹果丶:BAAALgADCgYJBgAAAA==.',
['冰丨']='冰丨糖葫芦:BAAALgADCgYJCAAAAA==.',
['冰丶']='冰丶荥:BAAALgADCgcJBwAAAA==.',
['冰之']='冰之影:BAAALgAECgMJAgAAAA==.',
['冰淇']='冰淇淋总管:BAAALgAECgkJCgAAAA==.',
['冲锋']='冲锋向右:BAAALgAECgYJDQAAAA==.冲锋向左:BAAALgADCgQJBAAAAA==.',
['冷艳']='冷艳继母:BAAALgAECgQJBQAAAA==.',
['凉拌']='凉拌肥肠:BAAALgAECgkJCQAAAA==.',
['凌月']='凌月仙姬:BAAALgAECggJCAAAAA==.',
['凑友']='凑友希那:BAABLgAFFH8GAAIKAAQJjRHTEgBRAQAKAAQJjRHTEgBRAQAAAA==.',
['划划']='划划水跑跑尸:BAAALgADCgQJBAAAAA==.',
['初恋']='初恋:BAAALgAECgEJAQAAAA==.',
['别打']='别打我齐刘海:BAAALgADCgYJBgAAAA==.',
['前男']='前男友:BAAALgAECgYJBgAAAA==.',
['剑似']='剑似:BAAALgAFFAEJAQAAAA==.',
['劳伦']='劳伦斯丶:BAAALgAECgYJBgAAAA==.',
['勇敢']='勇敢牛暖暖:BAAALgAECgYJBgAAAA==.勇敢牛牛:BAAALgAECgYJCAAAAA==.',
['北白']='北白河千百合:BAEALgAECggJCAABLgAFFAIJBAAOAAAAAA==.',
['千叶']='千叶岚:BAAALgAECgUJBwAAAA==.',
['升斗']='升斗市民:BAAALgAECgYJDQAAAA==.',
['半只']='半只狐狸:BAAALgAECgYJCwAAAA==.',
['华茂']='华茂春松:BAAALgAECgcJBgAAAA==.',
['叁元']='叁元:BAAALgAFFAUJBAABLgAFFAcJCgACAO4cAA==.',
['叁千']='叁千:BAAALgAECgYJBgAAAA==.',
['双魚']='双魚理:BAABLgAFFH8FAAICAAQJ5Ru0EwB8AQACAAQJ5Ru0EwB8AQABLgAFFAYJCwACAMUbAA==.',
['古堡']='古堡中的阴影:BAAALgAECgIJAgAAAA==.',
['只想']='只想活下去:BAAALgAECgQJBgAAAA==.',
['可怕']='可怕的小鼠:BAAALgAECgEJAgAAAA==.',
['可我']='可我在读条啊:BAACLgAFFH8OAAIKAAYJcw75AwDgAQAKAAYJcw75AwDgAQAuAAQKfx0AAwoACQkUIBgOAAkDAAoACQkUIBgOAAkDAA8AAgkVChNUAHIAAAAA.',
['叶惠']='叶惠美丶:BAAALgAECgIJAgAAAA==.',
['叶舒']='叶舒华:BAAALgAECgEJAQAAAA==.',
['吃嫩']='吃嫩草:BAAALgAFFAQJAwAAAA==.',
['君凉']='君凉:BAAALgAECgEJAQAAAA==.',
['听说']='听说你们缺德:BAAALgADCgUJBQAAAA==.',
['吴丶']='吴丶尔丹:BAAALgAECgcJEgAAAA==.',
['呆萌']='呆萌小恶魔:BAAALgAECgcJEgAAAA==.',
['呱呱']='呱呱王:BAAALgAECgYJCwAAAA==.',
['咕咕']='咕咕嘎嘎丶:BAAALgAECgkJCAAAAA==.',
['哈兰']='哈兰达尔:BAAALgAECgQJBAAAAA==.',
['哈几']='哈几米:BAAALgAECgYJCQAAAA==.',
['啸风']='啸风者迪奥斯:BAAALgAECgcJAQABLgAECgcJAgAOAAAAAA==.',
['嗜胸']='嗜胸:BAAALgADCgcJBwAAAA==.',
['四月']='四月一:BAAALgAECgIJBQAAAA==.',
['回忆']='回忆上了发条:BAAALgAFFAEJAQAAAA==.',
['圆圆']='圆圆丨滚滚:BAAALgADCgYJBgAAAA==.',
['圣光']='圣光之子:BAAALgADCgcJBwAAAA==.圣光米饭:BAAALgAECgYJCQAAAA==.',
['地狱']='地狱狂战:BAAALgAECgIJAgAAAA==.',
['坏三']='坏三岁:BAABLgAFFH8FAAMQAAMJagpNBACsAAAQAAMJagpNBACsAAABAAEJggQdEABRAAAAAA==.',
['墨莉']='墨莉絲:BAABLgAFFH8FAAIRAAUJUiDyAACUAQARAAUJUiDyAACUAQAAAA==.',
['复仇']='复仇男爵:BAAALgAECgkJDgAAAA==.',
['多莫']='多莫克萨拉姆:BAAALgAFFAEJAQAAAA==.',
['夜天']='夜天:BAAALgAECgEJAQAAAA==.',
['夜月']='夜月苍狼:BAAALgAECggJCQAAAA==.',
['大八']='大八角:BAAALgADCgEJAQAAAA==.',
['大地']='大地守護者:BAAALgAECgUJBwAAAA==.',
['大守']='大守八云:BAAALgADCggJCAAAAA==.',
['大漠']='大漠孤雁:BAAALgAECgQJBQABLgAECggJIQAMAE4iAA==.',
['大盛']='大盛無料:BAACLgAFFH8GAAISAAMJdRL7DQD5AAASAAMJdRL7DQD5AAAuAAQKfxYAAhIABwlKHnYMAG4CABIABwlKHnYMAG4CAAAA.',
['大角']='大角牛灬:BAAALgAECgYJDAAAAA==.',
['大辣']='大辣条汁:BAACLgAFFH8GAAIMAAMJshC3DAD/AAAMAAMJshC3DAD/AAAuAAQKfyQAAgwACAmKIMwYANQCAAwACAmKIMwYANQCAAAA.',
['大黑']='大黑牛灬:BAAALgAECggJDQAAAA==.',
['天泣']='天泣之刃:BAABLgAFFH8HAAITAAMJ3iAzGwC1AAATAAMJ3iAzGwC1AAAAAA==.',
['天蜚']='天蜚丶:BAAALgAECgQJBgAAAA==.',
['天马']='天马座幻想:BAAALgADCgIJAgAAAA==.',
['太平']='太平令:BAAALgAECgQJBQAAAA==.',
['奈法']='奈法尼奥:BAAALgAECgEJAQAAAA==.',
['奔雷']='奔雷手文泰來:BAAALgADCgUJBQAAAA==.',
['女纸']='女纸無才:BAAALgAECgYJBgAAAA==.',
['奶妈']='奶妈跟我走:BAAALgADCgEJAQABLgAFFAYJFwAMAN0fAA==.',
['妖孽']='妖孽灬:BAAALgAECgQJAgAAAA==.',
['姜汁']='姜汁可乐:BAACLgAFFH8OAAIUAAQJNCMOAwCYAQAUAAQJNCMOAwCYAQAuAAQKfyYAAxQACAnxIrsJAJ8CABQABwmJIbsJAJ8CABUABgkBIb0RAFQCAAAA.',
['婉若']='婉若游龍:BAAALgAECgYJBAAAAA==.',
['子元']='子元:BAACLgAFFH8LAAITAAUJVhzGBQCmAQATAAUJVhzGBQCmAQAuAAQKfxQAAhMACAkqGOpJABUCABMACAkqGOpJABUCAAAA.',
['宇宙']='宇宙:BAAALgADCgYJBgAAAA==.',
['安雅']='安雅泰勒侨伊:BAAALgAECgYJCQAAAA==.',
['宗嘉']='宗嘉杰:BAAALgAFFAIJAgAAAA==.',
['宜醉']='宜醉不宜醒:BAAALgAECgEJAQAAAA==.',
['宝宝']='宝宝小德:BAAALgAECgcJDgAAAA==.',
['宠物']='宠物大乱炖:BAAALgAECgEJAQAAAA==.',
['家有']='家有凶喵:BAAALgAECgMJAQAAAA==.',
['宿迁']='宿迁酱豆子:BAAALgADCgcJCwABLgAFFAQJEAAJAPsVAA==.',
['寂寞']='寂寞的小脑袋:BAAALgAECgUJBQAAAA==.寂寞的小鼠:BAAALgAECgkJCQABLgAFFAUJCQAJADQcAA==.',
['对宁']='对宁談墙:BAAALgAECgkJDAAAAA==.',
['寿司']='寿司是只猫:BAABLgAECn8dAAICAAgJIQnnpwCKAQACAAgJIQnnpwCKAQAAAA==.',
['小劣']='小劣吟:BAABLgAFFH8IAAINAAMJKBjUCAAbAQANAAMJKBjUCAAbAQAAAA==.',
['小呼']='小呼噜猪:BAABLgAFFH8FAAINAAUJcAGFCgANAQANAAUJcAGFCgANAQAAAA==.',
['小学']='小学生:BAEALgAECgMJAwABLgAFFAIJBAAOAAAAAA==.',
['小小']='小小消防管:BAAALgAFFAIJAwABLgAFFAQJBwAKAC8SAA==.小小滴湮灭:BAAALgAECgcJCgAAAA==.',
['小枭']='小枭乖乖:BAAALgAECgUJBQAAAA==.',
['小牛']='小牛爬电竿:BAAALgAECgUJCAAAAA==.',
['小猪']='小猪乔治:BAAALgAECgIJAwAAAA==.',
['小猫']='小猫点点:BAAALgAECgUJBQAAAA==.',
['小空']='小空灬霁月:BAAALgAECgEJAQAAAA==.',
['小筱']='小筱熊猫:BAAALgADCgcJBwABLgAECgYJDAAOAAAAAA==.',
['小米']='小米果果:BAAALgAECgcJBwAAAA==.',
['小能']='小能喵:BAAALgAECgYJDAAAAA==.',
['尐德']='尐德:BAAALgAECgUJAwAAAA==.',
['尐馜']='尐馜馜:BAAALgAECgkJCQABLgAFFAUJBQALAHoGAA==.',
['少侠']='少侠请饶命:BAABLgAECn8ZAAICAAgJeBw/NgCbAgACAAgJeBw/NgCbAgAAAA==.',
['屁屁']='屁屁妞:BAAALgAFFAEJAQAAAA==.',
['山泥']='山泥若:BAAALgAECgYJCQABLgAFFAYJBgACABIBAA==.',
['岛琦']='岛琦瑶香:BAACLgAFFH8IAAMCAAMJyhRoKwAIAQACAAMJyhRoKwAIAQAWAAEJ7xVFAQBaAAAuAAQKfyMAAgIABwkpHV1aACoCAAIABwkpHV1aACoCAAAA.',
['左边']='左边画条龙:BAAALgADCgMJAwAAAA==.',
['差点']='差点掉神器:BAAALgADCgUJBQAAAA==.',
['巴拉']='巴拉斯巴:BAAALgAECgEJAQAAAA==.',
['巴斯']='巴斯特之舞:BAAALgADCgEJAQAAAA==.',
['巴黎']='巴黎欧莱雅:BAAALgAECgUJBQAAAA==.',
['帅破']='帅破苍穹:BAAALgADCgYJBgAAAA==.',
['师太']='师太快走:BAAALgAECgcJBgAAAA==.师太快跑:BAAALgAECgYJDgAAAA==.',
['希尔']='希尔梅丽娅:BAAALgADCgUJBQAAAA==.',
['希瑞']='希瑞赐我力量:BAAALgAECgYJBgAAAA==.',
['帕博']='帕博力克:BAAALgADCgYJBgAAAA==.',
['帕格']='帕格巴克:BAAALgADCgIJAgAAAA==.',
['帕路']='帕路奇亚:BAAALgAECgkJDgAAAA==.',
['帝皇']='帝皇欲望麻酱:BAAALgAFFAEJAQAAAA==.',
['幽能']='幽能风暴:BAAALgAECgYJBwAAAA==.',
['幽默']='幽默芋泥:BAAALgAECgUJBQAAAA==.',
['弗利']='弗利萨大王:BAABLgAECn8YAAIXAAcJ8wnLCwDnAAAXAAcJ8wnLCwDnAAAAAA==.',
['弗萊']='弗萊婭:BAACLgAFFH8IAAICAAMJaAPYMQDhAAACAAMJaAPYMQDhAAAuAAQKfxwAAgIABwmYEdWdAJoBAAIABwmYEdWdAJoBAAAA.',
['归宿']='归宿丿:BAAALgAFFAMJAwAAAA==.',
['彡缘']='彡缘得一人心:BAAALgAECgQJBAAAAA==.彡缘得一人訫:BAAALgAFFAEJAQAAAA==.',
['影弟']='影弟丶:BAAALgAECgMJBAAAAA==.',
['影月']='影月黯刃:BAAALgAECgYJFwAAAQ==.',
['影踪']='影踪双花红棍:BAAALgAECgYJBgAAAA==.',
['彼岸']='彼岸丨阑珊处:BAAALgAECgUJAQAAAA==.',
['微雨']='微雨冰尘:BAAALgAFFAEJAQAAAA==.',
['微风']='微风影焰:BAAALgAECgQJBgAAAA==.微风拂过:BAAALgADCgQJBAAAAA==.',
['德彪']='德彪西的月光:BAAALgAECgUJEQAAAA==.',
['德拉']='德拉萨鲁法尔:BAAALgAFFAIJBAAAAA==.',
['德莱']='德莱文:BAAALgADCgUJBQAAAA==.',
['心月']='心月狐丶:BAABLgAFFH8LAAMTAAUJ4QvzGwA0AQATAAQJ4QvzGwA0AQAYAAEJAACLFABNAAAAAA==.',
['悠悠']='悠悠夏曰:BAACLgAFFH8IAAMZAAMJriYfAwBYAQAZAAMJriYfAwBYAQALAAEJvBaVNABQAAAuAAQKfx8AAxkABgl6JqcLAKYCABkABgl6JqcLAKYCAAsABQmrIK5iAHkBAAAA.',
['愛欣']='愛欣覚羅:BAAALgADCgQJBAAAAA==.',
['我一']='我一朋友:BAAALgAECgUJBwAAAA==.',
['我用']='我用拖鞋:BAAALgAFFAIJAgAAAA==.',
['我超']='我超级脆:BAAALgAECgIJBgAAAA==.',
['手残']='手残患者:BAAALgAECgYJEwAAAA==.',
['把你']='把你卤好:BAAALgAECgEJAgAAAA==.',
['把妹']='把妹丶不花钱:BAABLgAECn8cAAIHAAgJSxqnFQBoAgAHAAgJSxqnFQBoAgAAAA==.把妹丶九尾狐:BAABLgAECn8mAAMHAAkJUBzvCQDaAgAHAAkJUBzvCQDaAgAGAAIJWA5deABhAAAAAA==.把妹丶命太苦:BAABLgAECn8XAAMHAAkJehhYEQCMAgAHAAkJehhYEQCMAgAGAAIJ7gzuegBYAAAAAA==.把妹丶大漩涡:BAABLgAECn8aAAIHAAkJTSLrAQBuAwAHAAkJTSLrAQBuAwAAAA==.把妹丶小狐仙:BAAALgAECgcJCQAAAA==.把妹丶小狐狸:BAABLgAECn8ZAAMHAAkJxRAWRQBuAQAHAAkJxRAWRQBuAQAGAAIJPxLDIgB6AAAAAA==.把妹丶爱妲己:BAAALgAECgcJEAAAAA==.把妹丶爱花钱:BAAALgAECgcJBgAAAA==.',
['拆骨']='拆骨肉:BAAALgAECgYJBgAAAA==.',
['拾特']='拾特兮兮:BAAALgADCgQJBAAAAA==.',
['指环']='指环空间:BAAALgAECgEJAQAAAA==.',
['挽秋']='挽秋丶:BAAALgAECgYJCAAAAA==.',
['撒旦']='撒旦之怒:BAAALgADCgIJAgAAAA==.',
['撒顶']='撒顶顶:BAAALgAECgEJAgAAAA==.',
['擦嘴']='擦嘴:BAAALgAECgEJAQAAAA==.',
['整死']='整死不要抬:BAAALgAFFAEJAQAAAA==.',
['新鲜']='新鲜阳光:BAAALgAECgYJBgAAAA==.',
['无名']='无名释:BAAALgADCgYJBgAAAA==.',
['无尽']='无尽夏日:BAAALgADCgUJBQAAAA==.',
['无生']='无生心:BAAALgAECgkJDQAAAA==.',
['无糖']='无糖可乐:BAAALgADCgEJAQAAAA==.',
['无耻']='无耻的奶奶:BAAALgAECgEJAQAAAA==.',
['日见']='日见星辰:BAAALgAECgEJAQAAAA==.',
['星点']='星点点:BAAALgAECgQJBwAAAA==.',
['春日']='春日野穹:BAABLgAECn8aAAMGAAkJQBhjDgC9AgAGAAkJQBhjDgC9AgAHAAcJRRo+IwALAgAAAA==.',
['昼眠']='昼眠:BAAALgAFFAEJAQAAAA==.',
['晓晓']='晓晓豆包:BAAALgAECgkJAQAAAA==.晓晓青团:BAAALgAECgYJBgAAAA==.',
['晓月']='晓月星辰:BAAALgADCgQJBAAAAA==.',
['晓灬']='晓灬龙:BAAALgAECgYJCAAAAA==.',
['晓薇']='晓薇:BAAALgAECgEJAQAAAA==.',
['晴天']='晴天霹雳:BAAALgAECgYJBgAAAA==.',
['暗夜']='暗夜男爵:BAAALgADCgMJAwAAAA==.',
['暗月']='暗月锋刃:BAAALgAECgMJCAABLgAECgYJFwAOAAAAAQ==.',
['暮寒']='暮寒:BAAALgADCgEJAQAAAA==.',
['暴怒']='暴怒灵魂:BAAALgAECgEJAgAAAA==.暴怒的老牛:BAAALgAFFAIJAwAAAA==.',
['曜夜']='曜夜:BAAALgADCgYJBgAAAA==.',
['曹婴']='曹婴:BAAALgAECgEJAQAAAA==.',
['曾照']='曾照彩雲归:BAAALgAECgEJAgAAAA==.',
['最光']='最光阴:BAABLgAECn8VAAIKAAkJPSGyAAAeAwAKAAkJPSGyAAAeAwAAAA==.',
['最后']='最后一片藤叶:BAAALgAECgEJAQAAAA==.',
['月光']='月光也是光:BAAALgAECgIJAgAAAA==.',
['月影']='月影熊猫:BAAALgAECgUJAQAAAA==.',
['朔夜']='朔夜:BAAALgAECgYJAgAAAA==.',
['木子']='木子丹:BAAALgADCgEJAQAAAA==.',
['未完']='未完的故事:BAAALgADCgEJAQAAAA==.',
['机智']='机智的小熊猫:BAAALgAECgYJBgAAAA==.',
['李守']='李守财语风:BAAALgAECgIJAgAAAA==.',
['李风']='李风:BAAALgAECgYJBgAAAA==.',
['枫停']='枫停:BAAALgADCgIJAgAAAA==.',
['枫林']='枫林蔓:BAAALgAECgMJAwAAAA==.',
['柒宝']='柒宝:BAAALgAECgkJDgAAAA==.',
['柠檬']='柠檬不加糖:BAABLgAFFH8GAAITAAIJOBqwHwCiAAATAAIJOBqwHwCiAAAAAA==.',
['查斯']='查斯特贝宁顿:BAAALgAECgkJCgAAAA==.',
['桑灬']='桑灬叶落:BAAALgAECgYJDAAAAA==.',
['棘语']='棘语者丶:BAAALgAFFAEJAQAAAA==.',
['椰汁']='椰汁小汤圆:BAAALgAECgUJBAAAAA==.',
['楓隨']='楓隨箭舞:BAAALgAECgQJBQAAAA==.',
['欣然']='欣然的回忆:BAABLgAECn8aAAICAAcJzRr3GgCUAQACAAcJzRr3GgCUAQAAAA==.',
['歪比']='歪比巴波:BAAALgAECgYJBgAAAA==.',
['死亡']='死亡的距离:BAAALgAFFAIJAgAAAA==.死亡騎士:BAAALgAECgYJBgAAAA==.',
['殇丶']='殇丶死亡:BAABLgAECn8UAAMTAAgJ9xbvOwBHAgATAAgJ9xbvOwBHAgAaAAQJnw1hDgDAAAAAAA==.',
['殉道']='殉道者丶:BAAALgAECgEJAQAAAA==.',
['残影']='残影灬:BAAALgAECgEJAQAAAA==.',
['残江']='残江月:BAAALgAECgcJDQAAAA==.',
['毁灭']='毁灭金刚:BAAALgADCgUJBQAAAA==.',
['比尔']='比尔甘尼斯:BAAALgADCgIJAgAAAA==.',
['比目']='比目大贫猫:BAAALgADCgQJBAAAAA==.',
['毛茸']='毛茸茸萨摩猪:BAAALgAECgQJBwAAAA==.',
['永恒']='永恒丨:BAAALgAECgUJCwAAAA==.',
['江东']='江东杰瑞:BAAALgAECgkJBgAAAA==.',
['江桥']='江桥卡鸽:BAAALgAECgYJBwAAAA==.',
['沭丝']='沭丝:BAABLgAFFH8HAAIbAAUJAhPBAgCHAQAbAAUJAhPBAgCHAQAAAA==.',
['波雅']='波雅丶:BAAALgADCgYJDAAAAA==.',
['泰式']='泰式按摩:BAAALgAECgEJAgAAAA==.',
['洛昕']='洛昕:BAAALgAECgEJAQAAAA==.',
['洞里']='洞里的小秃子:BAAALgAECggJBwABLgAECgkJFwAXAMAcAA==.',
['洪武']='洪武正韵:BAAALgAECgcJCQAAAA==.',
['派遣']='派遣执行官:BAAALgAECgYJBgAAAA==.',
['流浪']='流浪的蜗牛:BAAALgAECgcJAQAAAA==.',
['浮光']='浮光掠影里丶:BAABLgAECn8UAAMJAAcJ1hdzPABrAQAJAAYJzhVzPABrAQANAAMJfx1JhwDSAAAAAA==.',
['淞鼠']='淞鼠鳜鱼:BAACLgAFFH8IAAIXAAMJTxkuBwDxAAAXAAMJTxkuBwDxAAAuAAQKfxgABBcABwmlH6YKAGcCABcABwmlH6YKAGcCAAUAAwlCDmCDALEAABwAAQknFRs9AD4AAAAA.',
['混沌']='混沌镇魂歌:BAACLgAFFH8IAAIHAAMJOxxhDQAFAQAHAAMJOxxhDQAFAQAuAAQKfxwAAgcABwnVH7ERAIkCAAcABwnVH7ERAIkCAAAA.',
['清净']='清净如水:BAAALgAECgcJDQAAAA==.',
['清风']='清风朗月:BAAALgAFFAIJAgAAAA==.',
['滑稽']='滑稽踢腿人:BAAALgAECgQJCwAAAA==.',
['满肚']='满肚小鸡翔:BAAALgAECgYJEwAAAA==.',
['漂流']='漂流的圣光:BAAALgADCgUJBgAAAA==.',
['火羽']='火羽冰翼:BAAALgAECgcJEgAAAA==.',
['灬宸']='灬宸灬:BAAALgADCgcJBwAAAA==.',
['灬收']='灬收割者灬:BAAALgAECgYJCwAAAA==.',
['灬皇']='灬皇甫帝灬:BAAALgAECgYJDwAAAA==.灬皇甫灬:BAAALgAECgIJAgAAAA==.',
['烈风']='烈风烈风:BAAALgADCgUJBQAAAA==.',
['烏龍']='烏龍茶:BAAALgAECgkJCQAAAA==.',
['焕佳']='焕佳:BAABLgAFFH8GAAIXAAQJUwWbBwDlAAAXAAQJUwWbBwDlAAAAAA==.',
['熊猫']='熊猫丨武僧:BAAALgAECgYJBwAAAA==.',
['燚王']='燚王:BAAALgADCgMJAwAAAA==.燚王一一萨满:BAAALgAECgIJAQAAAA==.',
['爆大']='爆大锤:BAAALgADCgUJBQAAAA==.',
['爆风']='爆风城酋长:BAAALgAECgMJAwAAAA==.',
['爱吃']='爱吃汉堡包:BAAALgAECgIJAwAAAA==.',
['牧糖']='牧糖果:BAAALgAECgYJEQAAAA==.',
['牧芊']='牧芊芊:BAAALgADCgYJBgAAAA==.',
['特莱']='特莱科斯卡:BAABLgAECn8WAAMDAAcJUgiVSQAFAQADAAYJMQiVSQAFAQAEAAcJJgbfdgDzAAAAAA==.',
['犄角']='犄角大不好滚:BAAALgAFFAEJAQAAAA==.',
['狮心']='狮心王:BAAALgAECgUJBQAAAA==.',
['猎雨']='猎雨:BAAALgAECgYJCAAAAA==.',
['猛妞']='猛妞:BAABLgAECn8MAAMKAAYJcQ/wpQAMAQAKAAYJcQ/wpQAMAQAPAAEJFAMlfgAeAAAAAA==.',
['猛弄']='猛弄瘸子右手:BAACLgAFFH8GAAINAAMJ8h4PCAAbAQANAAMJ8h4PCAAbAQAuAAQKfygAAg0ACAnsJDwFADgDAA0ACAnsJDwFADgDAAAA.',
['猜不']='猜不透的故事:BAAALgADCgEJAQAAAA==.',
['猪皮']='猪皮星:BAAALgAECgIJBAABLgAFFAQJBAAOAAAAAA==.',
['猿飞']='猿飞安琪儿:BAAALgADCgMJAwAAAA==.猿飞安祺儿:BAAALgADCgYJBgAAAA==.猿飞安绮儿:BAAALgADCgUJBQAAAA==.猿飞阿斯瑪:BAAALgADCgEJAQAAAA==.',
['王心']='王心凌:BAAALgAECgUJBQAAAA==.',
['王老']='王老师来休闲:BAAALgAECgkJEAAAAA==.',
['玩心']='玩心已泯:BAAALgAECgcJCwAAAA==.',
['现男']='现男友:BAAALgAECgQJBAAAAA==.',
['瑾年']='瑾年丨优里:BAAALgAECgYJCgAAAA==.',
['生在']='生在红旗下:BAAALgAECgEJAQAAAA==.',
['生气']='生气扔粑粑:BAAALgAECgIJAgABLgAECgYJGQAcAKodAA==.',
['疯狂']='疯狂伊雯:BAAALgAFFAEJAQAAAA==.疯狂的七水:BAAALgAECgYJBgAAAA==.',
['痞子']='痞子豪杰:BAAALgAECgUJCQAAAA==.',
['真皮']='真皮沙发:BAAALgAECgcJCwAAAA==.',
['知己']='知己与知彼:BAAALgADCgYJBwAAAA==.',
['碎碎']='碎碎念灬:BAAALgAECgIJAgAAAA==.',
['礼堂']='礼堂顶针:BAAALgAECgYJBgAAAA==.',
['祈光']='祈光如月:BAAALgAECgUJBQAAAA==.',
['神宫']='神宫寺玖惠澄:BAEALgAFFAIJBAAAAA==.',
['神牧']='神牧宁宁:BAABLgAECn8WAAIUAAkJIB/aAwAnAwAUAAkJIB/aAwAnAwAAAA==.',
['神秘']='神秘卷:BAAALgADCgQJBAAAAA==.',
['神罚']='神罚之翼:BAAALgAECgIJAwAAAA==.',
['福克']='福克斯领主:BAAALgAECgEJAQAAAA==.',
['离别']='离别礼物:BAAALgAECgYJDQAAAA==.',
['秋风']='秋风落叶红:BAAALgAECgQJBAAAAA==.',
['空海']='空海翁:BAAALgAECgQJBQAAAA==.',
['笛口']='笛口雏实:BAAALgAECgkJAgAAAA==.',
['第二']='第二十一:BAAALgAECgIJAgAAAA==.',
['筱冰']='筱冰:BAAALgADCgQJBAAAAA==.',
['粽子']='粽子噎兔子丶:BAAALgAFFAIJBAAAAA==.',
['精致']='精致卷:BAAALgADCgUJDQAAAA==.',
['糖醋']='糖醋丿排骨:BAAALgADCgEJAQAAAA==.',
['素问']='素问:BAAALgAECgQJBAAAAA==.',
['紫宵']='紫宵丶阿尼亚:BAAALgAECgkJDwAAAA==.',
['紫枫']='紫枫孤心:BAAALgAECgcJAQAAAA==.紫枫孤珏:BAAALgAECgcJAgAAAA==.',
['紫风']='紫风孤刃:BAAALgAECgcJAQAAAA==.',
['繁缈']='繁缈:BAABLgAECn8YAAIHAAcJXyMJBABUAgAHAAcJXyMJBABUAgAAAA==.',
['红牛']='红牛:BAAALgAECgIJAgAAAA==.',
['红豆']='红豆氵:BAAALgAECgMJAwAAAA==.',
['约阿']='约阿希姆:BAAALgAECgEJAQAAAA==.',
['练习']='练习六年半:BAAALgAECgkJCQAAAA==.',
['绯红']='绯红女人:BAAALgAFFAIJAgAAAA==.',
['羊宫']='羊宫妃那:BAACLgAFFH8WAAIEAAYJBiJuAABxAgAEAAYJBiJuAABxAgAuAAQKfxkAAgQACAlkJT8EAEsDAAQACAlkJT8EAEsDAAAA.',
['美杜']='美杜莎之怒:BAAALgAECgYJBQAAAA==.',
['羡慕']='羡慕许仙睡蛇:BAAALgAECgYJCgAAAA==.',
['翻滚']='翻滚叭熊宝宝:BAAALgAFFAEJAgAAAA==.翻滚啊熊宝宝:BAAALgADCgYJBgAAAA==.',
['老公']='老公爱玩:BAAALgAECgEJAQAAAA==.',
['老骥']='老骥伏骑:BAAALgADCgEJAQAAAA==.',
['聖裁']='聖裁丷霂痕:BAAALgAECgMJAwAAAA==.',
['能撩']='能撩会射丶玖:BAAALgAECggJDgAAAA==.',
['艾丶']='艾丶什:BAAALgAECgEJAgAAAA==.',
['艾爾']='艾爾卡迪雅:BAAALgAECgQJBAAAAA==.',
['艾露']='艾露玛:BAAALgAECgQJBAAAAA==.',
['花儿']='花儿的赞歌:BAAALgAECgQJBwAAAA==.',
['花火']='花火牧:BAAALgADCgQJBAAAAA==.',
['芳蔼']='芳蔼:BAACLgAFFH8JAAICAAMJRCWaDgBDAQACAAMJRCWaDgBDAQAuAAQKfygAAgIACAl8JN0EAIoCAAIACAl8JN0EAIoCAAAA.',
['苏糯']='苏糯儿:BAAALgAECgEJAQAAAA==.',
['若干']='若干个风格:BAAALgAFFAIJAwAAAA==.',
['苹果']='苹果乐狗:BAAALgAECgcJBwAAAA==.',
['茅台']='茅台:BAAALgAECgcJCwABLgAFFAUJDQAdAL4aAA==.',
['茴香']='茴香馅饼:BAAALgAFFAIJAgAAAA==.',
['莉娜']='莉娜巴恩斯:BAAALgAECgcJEgAAAA==.',
['莱拉']='莱拉丶月行者:BAAALgADCgQJBAAAAA==.',
['莲花']='莲花乡一枝花:BAAALgAECgYJDQAAAA==.',
['萌面']='萌面潮人:BAACLgAFFH8IAAIGAAMJPAiFEQDfAAAGAAMJPAiFEQDfAAAuAAQKfxcAAwYABwmYGq0lAOQBAAYABwmYGq0lAOQBAAcAAglBAjmSAFIAAAAA.',
['萧十']='萧十五:BAAALgAECgEJAwAAAA==.',
['蓝纹']='蓝纹奶酪:BAACLgAFFH8OAAICAAQJeiH0BgB0AQACAAQJeiH0BgB0AQAuAAQKfyQAAgIACAnsI2wPAEwDAAIACAnsI2wPAEwDAAAA.',
['蔡楚']='蔡楚炀:BAAALgAECgEJAQAAAA==.',
['薰风']='薰风微凉:BAAALgADCgUJBQAAAA==.',
['虛灵']='虛灵灬:BAAALgAECgYJCQAAAA==.',
['蛟老']='蛟老板:BAABLgAECn8ZAAMZAAcJxB8eDgCCAgAZAAcJxB8eDgCCAgALAAUJVxrzdgBBAQAAAA==.',
['蜜汁']='蜜汁番茄:BAABLgAFFH8MAAMKAAUJqBHzCwB8AQAKAAUJrg3zCwB8AQAPAAEJRRbAEwBXAAAAAA==.',
['衣轻']='衣轻乘肥:BAAALgADCgEJAQAAAA==.',
['西西']='西西贝:BAAALgAECgEJAQAAAA==.',
['西贝']='西贝贝:BAAALgAECgEJAgAAAA==.',
['誶誶']='誶誶念:BAAALgAECgEJAQAAAA==.',
['计划']='计划有变:BAAALgAECgQJCwAAAA==.',
['让圣']='让圣光拍死你:BAAALgAECgUJBgAAAA==.',
['该躲']='该躲不躲晕晕:BAAALgAECgYJBgAAAA==.',
['谁不']='谁不低头:BAABLgAECn8hAAIMAAgJTiKaDQAhAwAMAAgJTiKaDQAhAwAAAA==.',
['谋谟']='谋谟帷幄:BAAALgAECgYJBgAAAA==.',
['豊川']='豊川祥子:BAABLgAFFH8FAAILAAIJ0heQJQCpAAALAAIJ0heQJQCpAAAAAA==.',
['赤脚']='赤脚小仙:BAAALgAECgQJBAAAAA==.',
['赤龙']='赤龙尊者总管:BAAALgAECgkJBwABLgAFFAYJDgAcANUkAA==.',
['超級']='超級炎炎舞:BAACLgAFFH8LAAIeAAQJ2BfRBABEAQAeAAQJ2BfRBABEAQAuAAQKfyUAAx4ACQnHHF4HAPcCAB4ACQnHHF4HAPcCAAwABwnNHw4tABgBAAAA.',
['超级']='超级牛:BAAALgAECgkJCQAAAA==.',
['路口']='路口转左:BAABLgAFFH8HAAIKAAQJLxIvEwBPAQAKAAQJLxIvEwBPAQAAAA==.',
['车丶']='车丶厘子:BAAALgAECgcJEAAAAA==.',
['辉夜']='辉夜姬:BAABLgAFFH8HAAIKAAQJpxk9EABeAQAKAAQJpxk9EABeAQAAAA==.',
['辛多']='辛多雷之殇:BAAALgADCggJCAAAAA==.',
['达利']='达利安的沉没:BAAALgAECgUJBQAAAA==.',
['达芬']='达芬骑:BAAALgAECgYJDAAAAA==.',
['过眼']='过眼烟云:BAAALgAECgYJCQAAAA==.',
['近战']='近战小劣人:BAABLgAFFH8HAAMNAAMJNR2oCAAdAQANAAMJNR2oCAAdAQAJAAEJJg+nKABKAAABLgAFFAQJBwAKAC8SAA==.',
['遁夜']='遁夜安魂师:BAAALgADCgEJAQAAAA==.',
['邪小']='邪小邪:BAABLgAFFH8GAAITAAIJtxnAIACgAAATAAIJtxnAIACgAAAAAA==.',
['邪神']='邪神丨恶魔术:BAAALgAECgcJAQAAAA==.',
['邪能']='邪能有点甜:BAAALgAECgYJBwAAAA==.',
['鄙人']='鄙人略懂拳脚:BAAALgAECgYJBwAAAA==.',
['酆都']='酆都之刃:BAAALgAECgQJBAAAAA==.',
['释永']='释永信:BAAALgAECgkJAQAAAA==.',
['银色']='银色誓约:BAAALgAECgEJAQAAAA==.',
['铸光']='铸光天师总管:BAAALgAECgkJBgAAAA==.',
['问号']='问号精:BAAALgAECgYJCAAAAA==.',
['队长']='队长一:BAAALgADCgcJBwAAAA==.队长二:BAAALgAECgUJBQAAAA==.队长壹:BAAALgAECgUJBQAAAA==.',
['阿比']='阿比盖尔:BAAALgAECgUJBQAAAA==.',
['阿良']='阿良丷德:BAAALgADCgEJAQAAAA==.',
['阿黛']='阿黛拉:BAAALgAECgEJAQAAAA==.',
['陆心']='陆心禾:BAABLgAFFH8IAAINAAMJGxdcCgAPAQANAAMJGxdcCgAPAQAAAA==.',
['陆辛']='陆辛禾:BAAALgAECgcJCAAAAA==.',
['陈丶']='陈丶数码相机:BAAALgAECgYJBgAAAA==.',
['陈心']='陈心如意:BAAALgAECgEJAQAAAA==.',
['陈景']='陈景:BAAALgADCgIJAgAAAA==.',
['陶诺']='陶诺米:BAAALgAFFAIJAwAAAA==.',
['随风']='随风漂流:BAAALgADCgYJCgAAAA==.',
['隐耀']='隐耀:BAAALgAECgMJBAAAAA==.',
['雅过']='雅过敏丶:BAACLgAFFH8FAAIDAAMJ9QOmCQC/AAADAAMJ9QOmCQC/AAAuAAQKfyEAAwMACAmaFHopALQBAAMACAmaFHopALQBAB8ABgnHAz8hANIAAAAA.',
['雨霖']='雨霖铃丶:BAAALgAECgkJCQAAAA==.',
['雪之']='雪之下:BAAALgAECgEJAQAAAA==.',
['雪姨']='雪姨:BAAALgAECgMJBgAAAA==.',
['雲裳']='雲裳:BAAALgADCgMJAwAAAA==.',
['雷恩']='雷恩加尔喵:BAAALgAECgIJAgAAAA==.',
['露易']='露易丝灬露:BAAALgAECgQJBQAAAA==.',
['青丝']='青丝忆华年:BAAALgAECgEJAQAAAA==.',
['青木']='青木倩:BAABLgAFFH8MAAISAAQJmQ6ECwAyAQASAAQJmQ6ECwAyAQAAAA==.青木安:BAAALgAECgMJAwAAAA==.',
['青涩']='青涩后妈:BAAALgAECgEJAwAAAA==.',
['静安']='静安面包房:BAAALgAECgYJAQAAAA==.',
['面包']='面包专卖:BAAALgADCgEJAQAAAA==.',
['韩文']='韩文杰:BAABLgAECn8ZAAMgAAgJdBkvBgCgAgAgAAgJdBkvBgCgAgAJAAEJ3gcBjwAsAAAAAA==.',
['風凌']='風凌雪:BAAALgAECgIJAQAAAA==.',
['风之']='风之幻想:BAAALgAECgYJAQAAAA==.',
['风禾']='风禾尽起:BAABLgAECn8cAAMhAAcJ6RIFDQAoAQAhAAcJ6RIFDQAoAQAdAAUJYwOLZwCjAAAAAA==.',
['飘零']='飘零的羽毛:BAAALgAFFAQJBAAAAA==.',
['饭中']='饭中淹:BAAALgAECgQJBAAAAA==.',
['香水']='香水丶:BAAALgAECgUJCQAAAA==.',
['骑鼓']='骑鼓咙咚呛:BAAALgAECgEJAQAAAA==.',
['鬼崎']='鬼崎绮罗罗:BAAALgADCgcJBwAAAA==.',
['魔力']='魔力筱鼠:BAAALgAECgEJAQAAAA==.',
['魔法']='魔法失忆:BAAALgAECgYJDgAAAA==.',
['鲸落']='鲸落灬万物生:BAAALgADCgEJAQAAAA==.',
['鹿野']='鹿野:BAAALgAECgEJAQAAAA==.',
['黎明']='黎明的寂寞:BAAALgAECgEJAgAAAA==.',
['黑心']='黑心超人:BAAALgADCgkJCQAAAA==.',
['黑曼']='黑曼巴丶:BAAALgAECgYJBgAAAA==.',
['龙秀']='龙秀儿:BAAALgADCggJCQAAAA==.',
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
