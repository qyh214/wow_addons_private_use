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

local lookup = {'Druid-Restoration','Rogue-Subtlety','Priest-Discipline','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Paladin-Retribution','Priest-Shadow','DeathKnight-Unholy','Monk-Brewmaster','DemonHunter-Devourer','DemonHunter-Havoc','Mage-Frost','Unknown-Unknown','Warrior-Fury','Warlock-Demonology','Priest-Holy','DeathKnight-Blood','Shaman-Restoration','Warrior-Arms','Shaman-Elemental','Paladin-Holy','Druid-Feral','Warlock-Destruction','Warlock-Affliction','Paladin-Protection','Warrior-Protection','Monk-Mistweaver','Hunter-BeastMastery','Druid-Balance','Monk-Windwalker','Rogue-Assassination','Rogue-Outlaw','DeathKnight-Frost',}
local provider = {region='CN',realm='伊瑟拉',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Airtraffic:BAAALgAFFAMJBAAAAA==.',
An='Antinua:BAABLgAFFH8FAAIBAAMJNAg8IAB1AAABAAMJNAg8IAB1AAAAAA==.',
Ar='Arcanemager:BAAALgAECgYJCQAAAA==.',
As='Ashfive:BAAALgAECgkJCQAAAA==.Ashsix:BAAALgAECgcJBwAAAA==.Aspetta:BAAALgAECgQJBAAAAA==.Asuka:BAAALgAECgYJDAAAAA==.',
At='Atermis:BAAALgADCgEJAQAAAA==.',
Ba='Basuosz:BAAALgADCgYJAQAAAA==.',
Bb='Bbmater:BAABLgAECn8VAAICAAgJQAlpJADVAQACAAgJQAlpJADVAQAAAA==.',
Be='Before:BAAALgAECgcJDQAAAA==.Belinda:BAAALgAECgQJBQAAAA==.',
Bo='Boxinq:BAAALgAECgYJBgAAAA==.Boxinx:BAAALgAECgIJAgAAAA==.',
Ca='Camila:BAAALgADCgEJAQAAAA==.Carrefour:BAAALgAECgYJBgAAAA==.Cartethyia:BAAALgAECgcJBwAAAA==.',
Ch='Chayen:BAAALgAECgcJCgABLgAFFAQJDwADAIEmAA==.',
Co='Conright:BAAALgAECgMJAwAAAA==.Cooinv:BAAALgAECgIJAwAAAA==.',
Cr='Crazyboy:BAAALgAECgMJBQAAAA==.',
Cx='Cxixi:BAAALgADCgUJBQAAAA==.',
Da='Darksouls:BAAALgAECgQJCAAAAA==.',
De='Destiny:BAAALgADCgcJBwAAAA==.Devilstar:BAAALgAECgEJAQAAAA==.',
Dr='Dragondog:BAAALgAECgMJAwAAAA==.',
En='Entropystar:BAAALgAECgUJBQAAAA==.',
Ff='Ff:BAAALgAECgEJAQAAAA==.',
Fi='Fi:BAAALgADCgEJAQAAAA==.Firepandaz:BAAALgAFFAEJAQAAAA==.',
Ha='Hakunamatata:BAACLgAFFH8FAAMEAAIJDBfKEwCMAAAEAAIJDBfKEwCMAAAFAAEJEwGCJQA6AAAuAAQKfx8ABAQACAm2EDIaALoBAAQACAm2EDIaALoBAAUABAmlBl1JALAAAAYAAwl6BqYzAHcAAAAA.Havocc:BAAALgAFFAIJBAAAAA==.',
He='Hersheys:BAAALgADCgEJAQAAAA==.',
Hi='Hillelena:BAACLgAFFH8FAAIHAAIJ3xp/HwCvAAAHAAIJ3xp/HwCvAAAuAAQKfycAAgcACAmJIncSAP8CAAcACAmJIncSAP8CAAAA.',
Hy='Hydrangea:BAAALgAECgEJAQAAAA==.',
Iv='Ivellios:BAAALgADCgQJBAAAAA==.',
Kl='Klia:BAAALgADCgYJBgAAAA==.',
Ku='Kunkun:BAAALgAECgYJBgAAAA==.',
La='Larken:BAAALgADCgEJAQAAAA==.Lastprayer:BAAALgAECgIJAwAAAA==.',
Le='Legecy:BAAALgAECgcJBwAAAA==.',
Li='Lina:BAAALgAECgQJBwAAAA==.',
Lo='Lookthat:BAAALgAECgcJAwAAAA==.',
Ma='Malage:BAAALgAECgYJDwAAAA==.',
Mi='Mianbao:BAAALgAECgEJAQAAAA==.Mirrorxx:BAAALgADCgEJAQAAAA==.',
My='Mystere:BAAALgAECgQJBAAAAA==.',
Ne='Neme:BAAALgADCgEJAQAAAA==.',
Ob='Oblivionis:BAACLgAFFH8bAAIIAAcJDiURAAAPAwAIAAcJDiURAAAPAwAuAAQKfxUAAggACAmsJhUDAHEDAAgACAmsJhUDAHEDAAAA.',
Ph='Phanteks:BAAALgADCgEJAQAAAA==.Phrolova:BAAALgAECgUJBQAAAA==.',
Ra='Raperapeme:BAAALgAECgcJBwAAAA==.',
Re='Reali:BAAALgAECgIJAgAAAA==.Redcherry:BAAALgAECgEJAQAAAA==.Respsga:BAAALgAECggJDQAAAA==.',
Ri='Rin:BAAALgAECgEJAQAAAA==.',
Se='Seanat:BAAALgAECgcJDQAAAA==.',
Sh='Shiroyi:BAAALgAECgYJCQAAAA==.',
Sk='Skillet:BAAALgAECgkJBwAAAA==.',
So='Solara:BAAALgAECgEJAQAAAA==.',
Sy='Synthetic:BAAALgAECgQJBAAAAA==.',
Te='Tempesty:BAAALgAECgMJAwAAAA==.Tenderness:BAAALgAECgIJAgABLgAFFAMJCAAJAOwfAA==.',
Th='Thedeadtime:BAAALgAECggJCwAAAA==.Thorin:BAAALgAFFAEJAQAAAA==.',
Ts='Tsairl:BAAALgAECgcJDQAAAA==.',
Ut='Uthersh:BAAALgAECgcJEAAAAA==.',
Vi='Virginie:BAAALgAECgUJBgAAAA==.',
Vo='Vorgath:BAAALgAECgEJAQAAAA==.',
Wa='Wanlang:BAAALgAECgcJBwAAAA==.',
Yo='Your:BAAALgAECgkJDgAAAA==.',
Yu='Yuyuyu:BAAALgADCgcJBwABLgAECggJFQAKALkkAA==.',
Za='Zacharydruid:BAAALgAECgEJAQAAAA==.Zartu:BAAALgAECgYJBwABLgAECggJFQAKALkkAA==.',
Ze='Zerel:BAACLgAFFH8IAAMLAAMJ3BCdHADuAAALAAMJ3BCdHADuAAAMAAEJ5gGpDwBEAAAuAAQKfxkAAwsABwnSGag/APYBAAsABwnSGag/APYBAAwABgnaEk0vAFQBAAEuAAUUBQkFAAsA3xoA.',
['一个']='一个半:BAAALgAFFAEJAQAAAA==.一个白胡子:BAAALgAECgcJDgAAAA==.',
['一冰']='一冰封絕戀一:BAACLgAFFH8QAAINAAUJDBrQCQDQAQANAAUJDBrQCQDQAQAuAAQKfycAAg0ACAmJILIsAL8CAA0ACAmJILIsAL8CAAAA.',
['一剑']='一剑封喉:BAAALgAECgEJAQAAAA==.一剑致命:BAAALgAECgkJCQAAAA==.',
['一射']='一射千里之外:BAAALgAECgMJAwAAAA==.',
['一戳']='一戳二蹦跶:BAAALgADCgEJAQAAAA==.',
['一朵']='一朵牛小花:BAAALgAECgQJBAAAAA==.',
['一淡']='一淡痕一:BAAALgAECgEJAQAAAA==.',
['一箭']='一箭致命:BAAALgAECggJCAAAAA==.',
['一起']='一起哈啤丿:BAAALgAFFAEJAgAAAA==.',
['三文']='三文鱼刺身:BAAALgAECgQJBQAAAA==.',
['三鲜']='三鲜粉:BAAALgAECgQJBAABLgAFFAEJAQAOAAAAAA==.',
['不会']='不会玩电脑:BAAALgAECgUJBQAAAA==.',
['不吃']='不吃土豆皮:BAAALgAECgYJEAAAAA==.',
['不帅']='不帅术爷:BAAALgADCgYJCwAAAA==.',
['不要']='不要不识抬举:BAAALgAECgYJDAAAAA==.',
['不语']='不语随心:BAAALgAECgEJAwAAAA==.',
['不足']='不足为骑:BAAALgAECgkJBAAAAA==.',
['与夜']='与夜同行:BAABLgAFFH8IAAINAAQJYhTUGgBgAQANAAQJYhTUGgBgAQAAAA==.',
['与时']='与时:BAAALgADCgcJBwAAAA==.',
['与风']='与风同行:BAABLgAFFH8IAAINAAQJ4hBMGwBeAQANAAQJ4hBMGwBeAQAAAA==.',
['专切']='专切豆腐:BAAALgAFFAEJAgAAAA==.',
['世界']='世界大战:BAAALgAECgQJBgAAAA==.',
['东风']='东风谷早苗:BAAALgAECgYJBgAAAA==.',
['丫头']='丫头和伊玄:BAAALgAECgcJAwAAAA==.',
['中二']='中二病叔叔:BAAALgAECgEJAgAAAA==.',
['丶云']='丶云碎:BAAALgAECgcJBgABLgAFFAYJCwANAIUbAA==.丶云長:BAAALgAECgkJBwAAAA==.',
['丶紫']='丶紫罗兰:BAAALgAECgMJAwAAAA==.',
['丷星']='丷星河璀璨丷:BAAALgAECgYJDgAAAA==.',
['丿剑']='丿剑客丿:BAABLgAECn8dAAIPAAgJDxxKBQDbAQAPAAgJDxxKBQDbAQAAAA==.',
['乃琳']='乃琳:BAABLgAECn8SAAIQAAcJ3yE8UADXAQAQAAcJ3yE8UADXAQAAAA==.',
['乄冰']='乄冰霜灬凋零:BAAALgADCgEJAQAAAA==.',
['乙醇']='乙醇方丈:BAAALgAECgMJAwAAAA==.',
['乾坤']='乾坤:BAAALgAECgYJBgAAAA==.',
['亚莉']='亚莉安洛德:BAAALgAECgQJBAAAAA==.',
['亡灵']='亡灵乄死神:BAAALgAECgEJAQAAAA==.',
['亲吾']='亲吾爱光羊:BAAALgAECgEJAQAAAA==.亲吾爱棍羊:BAAALgAECgMJAwAAAA==.亲吾肥羊:BAAALgAECgMJAwAAAA==.亲吾魔羊:BAAALgADCgYJCAAAAA==.',
['人头']='人头牛酋长:BAAALgAECgEJAQAAAA==.',
['人是']='人是我杀的:BAAALgAECgYJBgAAAA==.',
['从不']='从不不从:BAAALgAFFAIJAgAAAA==.从不奶人:BAACLgAFFH8GAAMIAAIJLCTuDADXAAAIAAIJLCTuDADXAAARAAEJsyW2EABsAAAuAAQKfxoABBEABwlHJLUTAEECAAMABgnfIswNAF0CABEABgluI7UTAEECAAgAAwmVJIs1AD4BAAAA.',
['伊斯']='伊斯坎达尓:BAAALgAECgYJDAAAAA==.',
['伊莉']='伊莉雅丶晨星:BAAALgAECgEJAQAAAA==.',
['伍伦']='伍伦:BAAALgADCgEJAQAAAA==.',
['传说']='传说中的三百:BAAALgAECgYJBwAAAA==.传说中的龙三:BAAALgADCgYJBgAAAA==.',
['体育']='体育生茄茄:BAAALgAECgQJBAAAAA==.',
['你也']='你也不想被人:BAAALgAECgEJAQAAAA==.',
['依瑟']='依瑟萨斯:BAABLgAECn8YAAISAAgJVhZjEwDXAQASAAgJVhZjEwDXAQAAAA==.',
['依蓝']='依蓝:BAAALgAECgYJEgAAAA==.',
['俏舌']='俏舌音的俏:BAAALgAFFAEJAQAAAA==.',
['俪琳']='俪琳彼得:BAAALgAECgYJBgAAAA==.',
['倔强']='倔强的大饼:BAAALgAECgEJAQAAAA==.',
['傲世']='傲世法法:BAACLgAFFH8KAAINAAMJhBAHLAAGAQANAAMJhBAHLAAGAQAuAAQKfxoAAg0ABwmNIMI/AHoCAA0ABwmNIMI/AHoCAAAA.',
['元素']='元素灵魂之神:BAAALgAECgYJBgAAAA==.',
['光丫']='光丫丫:BAAALgAECgYJBgAAAA==.',
['光明']='光明雪奶:BAAALgADCgUJBQAAAA==.',
['光舞']='光舞倾城:BAAALgAECgEJAgAAAA==.',
['光铸']='光铸丨弥尔:BAAALgAECgQJAwAAAA==.',
['兔美']='兔美酱:BAABLgAFFH8FAAIRAAIJTh2eCwCoAAARAAIJTh2eCwCoAAAAAA==.',
['八云']='八云若曦:BAAALgAECgYJCgAAAA==.',
['八十']='八十几个小奶:BAAALgAECgIJAwABLgAECgcJHAATAEEgAA==.',
['八夕']='八夕吃汉堡:BAAALgAECgYJBgAAAA==.',
['再来']='再来一瓶么:BAAALgAECgEJAQAAAA==.',
['冰冷']='冰冷的热水:BAAALgAECgUJBgAAAA==.',
['冰凝']='冰凝成的夏天:BAAALgAECgEJAgAAAA==.',
['冰加']='冰加红茶:BAAALgAECgQJBgABLgAECgUJBwAOAAAAAA==.',
['冰幽']='冰幽魂:BAAALgAFFAEJAgAAAA==.冰幽魂战:BAAALgAECgYJCAABLgAFFAUJBQAJAPoVAA==.',
['冰淇']='冰淇啉:BAAALgADCgMJAwAAAA==.',
['冰若']='冰若雨:BAAALgAECggJEAAAAA==.',
['冲锋']='冲锋兮萧萧:BAAALgADCgUJBQAAAA==.冲锋然后释放:BAAALgAECgUJBwAAAA==.',
['凉宫']='凉宫桑葚酱:BAAALgAECgYJBwAAAA==.凉宫沙茶酱:BAAALgAECgEJAQAAAA==.凉宫番茄酱:BAAALgAFFAEJAgAAAA==.',
['凋零']='凋零的心:BAACLgAFFH8NAAMSAAQJmxx5BQBIAQASAAQJmxx5BQBIAQAJAAEJrANtWQBIAAAuAAQKfxoAAxIABwmUIakMAEUCABIABwm0IKkMAEUCAAkAAwnFJNWyAB0BAAAA.',
['凌霄']='凌霄:BAABLgAFFH8FAAMPAAMJlB+tBwDPAAAPAAIJ7SStBwDPAAAUAAEJ4xQAAAAAAAAAAA==.',
['凝光']='凝光:BAAALgAECgUJBQAAAA==.',
['凤求']='凤求凤:BAAALgAECgUJBQAAAA==.',
['创意']='创意的由来:BAAALgAECgkJDwAAAA==.',
['剑绣']='剑绣清风一:BAAALgAFFAUJBAAAAA==.剑绣清风三:BAABLgAFFH8FAAIVAAUJKhghAwC9AQAVAAUJKhghAwC9AQAAAA==.剑绣清风九:BAABLgAFFH8MAAIVAAYJ7hpZAgDcAQAVAAYJ7hpZAgDcAQAAAA==.剑绣清风二:BAAALgAFFAQJAgAAAA==.剑绣清风什:BAABLgAFFH8FAAIVAAQJARlTCABVAQAVAAQJARlTCABVAQAAAA==.剑绣清风伍:BAAALgAFFAIJAQAAAA==.剑绣清风四:BAABLgAFFH8HAAIVAAQJCh/uBACRAQAVAAQJCh/uBACRAQAAAA==.',
['剩光']='剩光小蹄子:BAAALgAECgcJBwABLgAFFAQJDQAFAPISAA==.',
['劫杀']='劫杀:BAABLgAFFH8GAAIWAAIJDRXwFQCSAAAWAAIJDRXwFQCSAAAAAA==.',
['匆匆']='匆匆灬那年:BAAALgAECgcJCAAAAA==.',
['千森']='千森:BAAALgADCgEJAQAAAA==.',
['千里']='千里千成:BAAALgAECggJCAAAAA==.',
['卓娅']='卓娅:BAAALgADCgUJBQAAAA==.',
['南山']='南山羿者:BAAALgAFFAEJAgAAAA==.',
['南瓜']='南瓜世家:BAAALgAECgYJBgABLgAFFAEJAQAOAAAAAA==.南瓜丶武僧:BAAALgAECgMJAwAAAA==.',
['卡雷']='卡雷拉:BAAALgAECgMJAwAAAA==.',
['双刀']='双刀狂魔:BAAALgAECgEJAQAAAA==.',
['反叛']='反叛的朱朱:BAAALgADCgYJBgAAAA==.',
['变谁']='变谁象谁:BAAALgAECgEJAgAAAA==.',
['古怪']='古怪小机灵:BAAALgAECgMJAwAAAA==.',
['只若']='只若初见:BAAALgAECgEJAQAAAA==.',
['叮叮']='叮叮猫儿:BAAALgAECgEJAQAAAA==.',
['可可']='可可魔:BAAALgAFFAIJAgAAAA==.',
['司板']='司板客:BAACLgAFFH8GAAIRAAMJJxjrBgAGAQARAAMJJxjrBgAGAQAuAAQKfx4ABBEACQkLHVkEAA4DABEACQkLHVkEAA4DAAMAAwk3BCtNAF4AAAgAAQkFBwljADIAAAAA.',
['吃瓜']='吃瓜的群众:BAAALgAECgYJEQAAAA==.',
['同尘']='同尘:BAAALgAECgYJCgAAAA==.',
['后羿']='后羿擎天:BAAALgAECgIJAwAAAA==.',
['君帅']='君帅:BAAALgAECgQJCQAAAA==.',
['听不']='听不进去:BAAALgAECgEJAQAAAA==.',
['听梦']='听梦雨人:BAAALgADCgUJBQAAAA==.',
['咕咕']='咕咕思:BAAALgAECgYJCgAAAA==.',
['咕嚕']='咕嚕小藍龍:BAAALgAECgIJAgAAAA==.',
['唐圣']='唐圣骑:BAAALgAECgcJDwAAAA==.',
['啼哭']='啼哭亥时:BAAALgAECgEJAQAAAA==.',
['喜欢']='喜欢你呀:BAACLgAFFH8NAAIKAAQJtArjDwADAQAKAAQJtArjDwADAQAuAAQKfxkAAgoABwmBD2w4AGgBAAoABwmBD2w4AGgBAAAA.',
['嗨皮']='嗨皮猪:BAAALgAECgYJCAAAAA==.',
['嘉山']='嘉山路毛院:BAABLgAFFH8FAAIHAAIJIhSFJACjAAAHAAIJIhSFJACjAAAAAA==.',
['噬魂']='噬魂:BAAALgAECgEJAQAAAA==.',
['噵丶']='噵丶戢:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光灌注:BAAALgAECgcJCQAAAA==.圣光青露:BAABLgAFFH8FAAIHAAQJdQ92DABIAQAHAAQJdQ92DABIAQAAAA==.',
['圣女']='圣女贞狄:BAABLgAECn8aAAIHAAYJxBA9kgBYAQAHAAYJxBA9kgBYAQAAAA==.',
['圣法']='圣法仙女:BAAALgAECgEJAQAAAA==.',
['地域']='地域骑兵:BAAALgAECgYJBgAAAA==.',
['地府']='地府归来:BAAALgAFFAEJAQAAAA==.',
['坏坏']='坏坏:BAAALgAFFAQJAgAAAA==.',
['坐不']='坐不坐牢:BAAALgAECgEJAQAAAA==.',
['坑的']='坑的你惨兮兮:BAAALgAFFAIJAwAAAA==.',
['坠入']='坠入群星:BAAALgAECgMJAwAAAA==.',
['埃姆']='埃姆林:BAAALgAECgIJAgAAAA==.',
['埃斯']='埃斯蒂尼危:BAAALgADCgkJCQABLgAECggJFQAKALkkAA==.',
['城塚']='城塚翡翠:BAAALgAECgkJEAAAAA==.',
['塃弇']='塃弇貓:BAAALgADCgEJAQABLgAFFAQJBAAOAAAAAA==.',
['塔布']='塔布:BAAALgADCgEJAQAAAA==.',
['塔罗']='塔罗斯:BAAALgAECgcJBwABLgAFFAQJBwALALMDAA==.',
['塔露']='塔露拉:BAAALgAECgYJAgAAAA==.',
['塞拉']='塞拉纽斯小鹿:BAAALgAECgEJAQAAAA==.',
['墨彩']='墨彩:BAAALgAECgcJBwAAAA==.',
['壹副']='壹副挨打相:BAAALgAECgMJAwAAAA==.',
['复仇']='复仇在我:BAABLgAFFH8HAAILAAQJswOFGAALAQALAAQJswOFGAALAQAAAA==.',
['夏天']='夏天爱小猫:BAAALgAFFAIJAwABLgAFFAQJDQAKALQKAA==.',
['夜冰']='夜冰入梦:BAAALgAFFAQJAgAAAA==.',
['夜刃']='夜刃蹦一刀:BAAALgADCgcJBwAAAA==.',
['夜家']='夜家阿风:BAAALgAFFAQJBAAAAA==.',
['大主']='大主教泰瑞尔:BAAALgAECgMJBQAAAA==.',
['大叔']='大叔也有春天:BAAALgAECgUJBgAAAA==.',
['大杀']='大杀四方:BAAALgAECgEJAgAAAA==.',
['大橘']='大橘汁:BAAALgADCgIJAgAAAA==.',
['大阿']='大阿亚图拉:BAABLgAFFH8GAAIJAAIJgRp7FgCtAAAJAAIJgRp7FgCtAAAAAA==.',
['天使']='天使凌:BAAALgAECgIJAgAAAA==.',
['天未']='天未老情难绝:BAABLgAECn8VAAMHAAcJXQ0cggB2AQAHAAcJXQ0cggB2AQAWAAYJqQx4WgASAQAAAA==.',
['天灾']='天灾太上皇:BAAALgAECgQJCAAAAA==.',
['天神']='天神御师:BAAALgADCgYJBgAAAA==.',
['天罚']='天罚干戈:BAAALgAECgYJCgAAAA==.',
['夯夯']='夯夯兔:BAAALgADCgEJAQAAAA==.',
['奇摩']='奇摩基:BAABLgAECn8VAAIXAAcJtBuKCQA6AgAXAAcJtBuKCQA6AgAAAA==.',
['奎尔']='奎尔瑟兰:BAAALgAECgUJBQAAAA==.',
['奥术']='奥术猫爪:BAAALgAECgQJBAAAAA==.',
['奥莉']='奥莉丝塔夫人:BAAALgAECgEJAQAAAA==.',
['女爱']='女爱:BAAALgAECgcJEAAAAA==.',
['奶到']='奶到负无穷:BAABLgAECn8cAAITAAcJQSDWFABuAgATAAcJQSDWFABuAgAAAA==.',
['好几']='好几个神牧:BAAALgAECgEJBAAAAA==.',
['好困']='好困啊:BAABLgAFFH8IAAINAAQJUhDgHABYAQANAAQJUhDgHABYAQAAAA==.',
['姐迷']='姐迷人的发色:BAAALgAECggJEwAAAA==.',
['字幕']='字幕飞龙:BAAALgAECgUJAwAAAA==.',
['字母']='字母横行:BAABLgAECn8VAAIJAAgJWRNoVAD0AQAJAAgJWRNoVAD0AQAAAA==.',
['孤月']='孤月皎皎:BAAALgAECgUJCQAAAA==.',
['宇宙']='宇宙大帝:BAAALgAECgEJAQAAAA==.',
['守護']='守護之光:BAAALgADCgMJAwAAAA==.',
['安娜']='安娜塔希娅:BAABLgAFFH8HAAMHAAQJ2BCdFQD+AAAHAAMJthSdFQD+AAAWAAEJdA0qGwBTAAAAAA==.',
['宙斯']='宙斯之雷:BAAALgADCgUJBQAAAA==.',
['宛若']='宛若千星:BAAALgAECgEJAQAAAA==.',
['寻找']='寻找蜜丝拉:BAAALgAECgIJAgAAAA==.',
['小太']='小太子奶:BAAALgAFFAEJAQAAAA==.',
['小宓']='小宓蜂:BAAALgAECgIJAgAAAA==.',
['小巴']='小巴辣子:BAABLgAECn8bAAQQAAcJpx9TPwAQAgAQAAYJpx9TPwAQAgAYAAIJIA3EVQBtAAAZAAEJAACQJABfAAAAAA==.',
['小拇']='小拇指:BAAALgAECgEJAQAAAA==.',
['小曰']='小曰月:BAAALgAECgYJBwAAAA==.',
['小白']='小白也暴力:BAAALgAECgEJAgAAAA==.小白浪:BAAALgADCgUJBQAAAA==.',
['小肥']='小肥猪:BAAALgAECgYJBwAAAA==.',
['小舍']='小舍成大得:BAAALgADCgEJAQAAAA==.',
['小舞']='小舞女:BAAALgAECgEJAQAAAA==.',
['小镇']='小镇做题家:BAAALgAECgIJAwAAAA==.',
['小陆']='小陆姑娘:BAAALgAECgYJDAAAAA==.',
['小隔']='小隔隔:BAAALgAECgIJAgAAAA==.',
['尐曰']='尐曰月:BAAALgAFFAEJAQAAAA==.',
['山丘']='山丘索林:BAAALgAECgQJBAAAAA==.',
['山色']='山色有無中:BAACLgAFFH8NAAINAAQJ+yFoDgCmAQANAAQJ+yFoDgCmAQAuAAQKfxkAAg0ACAkoJlUVACgDAA0ACAkoJlUVACgDAAAA.',
['巅峰']='巅峰武魂:BAAALgADCgUJBQAAAA==.',
['布丁']='布丁:BAAALgAECgIJAgAAAA==.布丁大欧皇:BAAALgAECgYJCgAAAA==.',
['布德']='布德施恩:BAAALgAECgMJAQAAAA==.',
['帅气']='帅气的尸体:BAAALgAECgIJAgAAAA==.',
['幻月']='幻月星光:BAAALgAECgIJAwAAAA==.',
['幼稚']='幼稚園小喬:BAAALgAECgMJAwABLgAFFAUJDwARAOEQAA==.',
['废多']='废多吃崩:BAAALgAECgEJAgAAAA==.',
['康思']='康思密达康:BAAALgADCgMJAwAAAA==.',
['开局']='开局一条狗:BAAALgAECgYJCQAAAA==.',
['开车']='开车的老阿訇:BAAALgAECgUJBQAAAA==.',
['弗甲']='弗甲:BAAALgAFFAIJAwAAAA==.',
['弹幕']='弹幕护体:BAAALgAECgYJBgAAAA==.',
['彩翼']='彩翼妞妞:BAAALgADCgEJAQAAAA==.',
['彪彪']='彪彪不再爱:BAAALgAECgEJBAAAAA==.',
['彼岸']='彼岸花丶:BAAALgADCgMJAwAAAA==.',
['往事']='往事随梦:BAAALgAECgYJBwAAAA==.',
['御帝']='御帝哥哥:BAAALgAECgEJAQAAAA==.',
['微微']='微微壹笑:BAAALgAECgYJBgAAAA==.',
['德哈']='德哈娜:BAAALgADCgcJBwAAAA==.',
['忧郁']='忧郁的夏天:BAABLgAECn8ZAAMaAAYJIRIuHQAhAQAaAAYJPg0uHQAhAQAHAAQJrQ4C4ADNAAABLgAFFAQJDQAKALQKAA==.',
['恻隐']='恻隐悲悯之苦:BAAALgAECgMJAwABLgAECggJFQAKALkkAA==.',
['悠然']='悠然潇洒:BAACLgAFFH8IAAMHAAQJFhM+AwBkAQAHAAQJFhM+AwBkAQAWAAQJ4wGsDQD9AAAuAAQKfxUAAgcABwk+IBQrAHcCAAcABwk+IBQrAHcCAAAA.',
['悲夜']='悲夜:BAAALgAFFAQJBAAAAA==.',
['慢游']='慢游云端:BAAALgAECgUJBQAAAA==.',
['懒得']='懒得说再见:BAAALgAFFAUJBAAAAA==.',
['我不']='我不是神仙:BAAALgADCgMJAwAAAA==.',
['我有']='我有点紧张丶:BAAALgAECgYJBgAAAA==.',
['我要']='我要我觉得:BAAALgAECgYJBgAAAA==.我要来抓你啦:BAAALgADCgYJBwAAAA==.',
['打扰']='打扰:BAAALgAECgUJBwAAAA==.',
['执手']='执手观星:BAAALgAFFAQJBAAAAA==.',
['把酒']='把酒舟行慢:BAAALgAECgEJAQAAAA==.',
['拉矢']='拉矢高手:BAAALgAECgMJAwAAAA==.',
['拉粑']='拉粑粑小魔仙:BAAALgAECgcJBwAAAA==.',
['拥抱']='拥抱黑暗:BAAALgAECgEJAQAAAA==.',
['挽救']='挽救灵魂之神:BAAALgAECgcJBgAAAA==.',
['撕裂']='撕裂王三千:BAAALgADCgEJAQAAAA==.',
['斯特']='斯特修斯:BAABLgAECn8aAAIHAAgJyA4ufACCAQAHAAgJyA4ufACCAQABLgAFFAcJDQAbAM4ZAA==.',
['旖丶']='旖丶旎:BAAALgADCgEJAQAAAA==.',
['无地']='无地矮子:BAAALgAECgIJAgAAAA==.',
['明天']='明天你好:BAACLgAFFH8KAAISAAQJBQFHBgCcAAASAAQJBQFHBgCcAAAuAAQKfxsAAxIABwk7DoUoAPoAABIABwk3B4UoAPoAAAkAAgmkFyHzAJcAAAEuAAUUBAkNAAoAtAoA.',
['明摄']='明摄宗:BAACLgAFFH8GAAIcAAMJ6hj9CQARAQAcAAMJ6hj9CQARAQAuAAQKfysAAhwACAkFJPEDADQDABwACAkFJPEDADQDAAAA.',
['星光']='星光倒影:BAAALgAECgEJAQAAAA==.',
['星极']='星极迸升:BAAALgAECgYJBgABLgAECggJFQAKALkkAA==.',
['星河']='星河未眠:BAABLgAFFH8JAAINAAQJ0RU1GABpAQANAAQJ0RU1GABpAQAAAA==.',
['星璐']='星璐:BAAALgADCggJBgAAAA==.',
['星落']='星落之武:BAAALgAECgMJAwAAAA==.星落之风:BAAALgAECggJEwAAAA==.星落之魔:BAAALgAECgQJBAAAAA==.星落林间:BAABLgAFFH8MAAINAAQJ0h3MEQCHAQANAAQJ0h3MEQCHAQAAAA==.',
['星野']='星野佑树:BAAALgAECgUJDAAAAA==.',
['是爬']='是爬海啊丶:BAABLgAFFH8TAAIWAAYJFBhPAwC0AQAWAAYJFBhPAwC0AQABLgAFFAcJDQAcAB0SAA==.',
['晋城']='晋城赵子龙:BAACLgAFFH8OAAIHAAUJlBjYBACjAQAHAAUJlBjYBACjAQAuAAQKfxYAAwcACQnWHZoYANUCAAcACQnVHZoYANUCABYABwk6EG43AJ0BAAAA.',
['晓丶']='晓丶圣帝:BAAALgAECgQJBwAAAA==.晓丶毅气:BAAALgAECgIJAgAAAA==.',
['晓月']='晓月之终途:BAAALgAFFAMJAwAAAA==.',
['晓豆']='晓豆丁:BAAALgAECgkJCQAAAA==.',
['晚星']='晚星:BAAALgAFFAQJBAAAAA==.',
['暗之']='暗之夜月:BAAALgAECggJCAAAAA==.',
['暗影']='暗影茄茄:BAAALgAECgMJAwAAAA==.',
['暗雪']='暗雪飘香:BAAALgAECgYJBgAAAA==.',
['暗黑']='暗黑影者:BAAALgAECgYJBgAAAA==.',
['暴血']='暴血公司:BAAALgAECggJCAAAAA==.',
['暴躁']='暴躁小舟:BAAALgAFFAEJAQAAAA==.',
['暴风']='暴风之瞳:BAABLgAECn8dAAMJAAgJpB8dGwDbAgAJAAgJpB8dGwDbAgASAAcJTxHgIgAqAQAAAA==.暴风之翼:BAAALgAECgQJBAAAAA==.暴风劣酒:BAAALgAECgUJBQAAAA==.',
['曦琪']='曦琪:BAABLgAFFH8KAAMDAAQJowYjDAAUAQADAAQJaAQjDAAUAQARAAIJrwhYDwCDAAAAAA==.',
['曹姐']='曹姐:BAAALgAECgQJBAAAAA==.',
['最后']='最后的雪里枫:BAAALgAFFAEJAgAAAA==.',
['月夜']='月夜战魔:BAAALgAECgMJAwAAAA==.月夜水寒:BAAALgAECgYJCAAAAA==.',
['月色']='月色肩头:BAAALgAECgYJBgAAAA==.',
['月魔']='月魔的归来:BAAALgAECgYJCgAAAA==.',
['朵拉']='朵拉贡:BAABLgAFFH8FAAIFAAQJ/hmEFQC8AAAFAAQJ/hmEFQC8AAABLgAFFAUJDAANAJUiAA==.',
['杀柒']='杀柒柒:BAAALgAECgIJAgAAAA==.',
['李青']='李青山:BAAALgAFFAEJAQAAAA==.',
['杏目']='杏目:BAAALgAECgQJBAAAAA==.',
['杰洛']='杰洛齐贝林:BAAALgAECgYJEgAAAA==.',
['枕水']='枕水江南:BAABLgAFFH8IAAIdAAMJMxnKEADCAAAdAAMJMxnKEADCAAAAAA==.',
['枣核']='枣核:BAAALgADCgYJBgAAAA==.',
['柑蕉']='柑蕉桔梨萝柚:BAAALgADCgIJAgAAAA==.',
['柠檬']='柠檬味咖啡:BAABLgAECn8XAAINAAYJdBxIdwDjAQANAAYJdBxIdwDjAQAAAA==.',
['柳絮']='柳絮儿:BAABLgAECn8WAAITAAYJDxvRCQCiAQATAAYJDxvRCQCiAQAAAA==.',
['栖息']='栖息:BAAALgAECgcJBwAAAA==.',
['梦幻']='梦幻法王:BAAALgADCgEJAQAAAA==.',
['梦碎']='梦碎星陨:BAAALgAECgIJAgAAAA==.',
['梵大']='梵大梵:BAAALgAECgUJBQAAAA==.',
['樱小']='樱小路露娜:BAACLgAFFH8GAAINAAQJ0AamIQA6AQANAAQJ0AamIQA6AQAuAAQKfxoAAg0ACAl+Gc9LAFMCAA0ACAl+Gc9LAFMCAAAA.',
['橘红']='橘红色的温柔:BAAALgAECgcJEwAAAA==.',
['正镔']='正镔:BAABLgAECn8WAAIeAAgJMgddOQBSAQAeAAgJMgddOQBSAQAAAA==.',
['歧月']='歧月求瑕:BAAALgAECgcJDQAAAA==.',
['江月']='江月小小唰:BAAALgADCgEJAQAAAA==.',
['沉睡']='沉睡夜怪:BAAALgADCgEJAQAAAA==.',
['沙丁']='沙丁胺醇:BAAALgAECgQJBQAAAA==.',
['没事']='没事打打猎:BAAALgAECgQJBAAAAA==.',
['没脑']='没脑袋不高兴:BAABLgAFFH8QAAIbAAYJMxnnAACIAQAbAAYJMxnnAACIAQAAAA==.',
['泪滴']='泪滴嘎嘎:BAAALgAECgEJAQAAAA==.',
['洒满']='洒满人间:BAAALgAECgEJAQAAAA==.',
['洗洗']='洗洗睡吧丶:BAAALgAECgYJDwAAAA==.',
['洛瑟']='洛瑟琳:BAABLgAFFH8FAAIQAAIJ8QdFOwCcAAAQAAIJ8QdFOwCcAAAAAA==.',
['派拉']='派拉黛司:BAAALgAECgYJCwAAAA==.',
['流光']='流光化霜雪:BAAALgAECgkJCQAAAA==.',
['海拔']='海拔不够高:BAAALgAFFAEJAgAAAA==.',
['海的']='海的女鹅:BAABLgAFFH8GAAINAAMJ5RbxDgAXAQANAAMJ5RbxDgAXAQAAAA==.',
['涛涛']='涛涛的小可爱:BAAALgAECggJBQAAAA==.',
['涝汁']='涝汁三文鱼:BAAALgAFFAQJBAAAAA==.',
['涨停']='涨停板:BAAALgAECgIJAgAAAA==.',
['淡定']='淡定自若:BAAALgAFFAIJBAAAAA==.',
['淡淡']='淡淡草莓:BAAALgAECgEJAQAAAA==.',
['淡漠']='淡漠伤悲:BAAALgAECgYJBgAAAA==.',
['淡雅']='淡雅观世音:BAAALgAECgYJBgAAAA==.',
['混吃']='混吃等死:BAABLgAFFH8HAAIJAAMJ5hyXIgANAQAJAAMJ5hyXIgANAQAAAA==.',
['淼洋']='淼洋:BAAALgAECgcJBwAAAA==.',
['湛蓝']='湛蓝丶火羽:BAAALgAECgYJEwAAAA==.',
['湮灭']='湮灭拳豪:BAAALgAECgEJAgAAAA==.',
['滑来']='滑来滑去:BAAALgAECgcJDQAAAA==.',
['灌木']='灌木丛之心:BAAALgAECgYJCQAAAA==.',
['火羽']='火羽丨:BAAALgAECgEJAQAAAA==.',
['灬棋']='灬棋圣灬:BAAALgADCgEJAQAAAA==.',
['灬流']='灬流年:BAAALgAECgYJBwAAAA==.',
['灵药']='灵药不感冒:BAAALgAECgcJBwAAAA==.',
['炽翼']='炽翼天使:BAAALgAECgYJCgAAAA==.',
['烟波']='烟波悠然:BAAALgAECgEJAgAAAA==.',
['無影']='無影:BAAALgAECgYJCwAAAA==.',
['焦点']='焦点:BAAALgAECgMJAwAAAA==.',
['焦迈']='焦迈不齐:BAAALgADCgUJBQAAAA==.',
['爆钻']='爆钻欧皇:BAAALgAECgYJBgAAAA==.',
['爱吃']='爱吃貓的鱼:BAAALgAECgcJDQAAAA==.',
['爱回']='爱回温丶:BAABLgAFFH8JAAIBAAQJXQ/+CwAiAQABAAQJXQ/+CwAiAQAAAA==.',
['爱神']='爱神:BAAALgAECgYJBgAAAA==.',
['爽爽']='爽爽灬好媚:BAAALgADCgUJCQAAAA==.爽爽灬好爽:BAAALgADCgYJBgAAAA==.爽爽灬好肥:BAAALgADCgQJBAAAAA==.爽爽灬好靓:BAAALgADCgMJAwAAAA==.',
['牛卡']='牛卡斯尔:BAAALgAECgQJBAAAAA==.',
['牛马']='牛马术:BAAALgAECgYJBQABLgAFFAUJEAANAJURAA==.',
['牢贼']='牢贼怎么你了:BAAALgADCgEJAQAAAA==.',
['牧有']='牧有文化:BAAALgADCgEJAQAAAA==.',
['牧木']='牧木目:BAAALgAECgUJBgAAAA==.',
['牧警']='牧警长:BAAALgADCgcJCAAAAA==.',
['狂恋']='狂恋春风:BAAALgAECgIJAgAAAA==.',
['狐狸']='狐狸死骑:BAAALgAECgQJBAAAAA==.',
['狗奥']='狗奥龙龙版:BAAALgAECgkJCQAAAA==.',
['独自']='独自仰望星空:BAAALgAECgEJAQAAAA==.',
['狮堂']='狮堂光:BAAALgAFFAEJAgAAAA==.',
['猎影']='猎影伊芙:BAAALgADCgEJAQAAAA==.',
['猎空']='猎空:BAAALgAECgEJAQAAAA==.',
['猎魔']='猎魔一二三:BAAALgAECgcJCwAAAA==.',
['猪会']='猪会飞:BAAALgADCgcJDQAAAA==.',
['瓶诘']='瓶诘妖精:BAAALgAECgMJAwAAAA==.',
['甄挚']='甄挚:BAAALgAECgIJAgAAAA==.',
['电炮']='电炮飞脚:BAAALgAECgYJBgAAAA==.',
['画影']='画影:BAAALgAECgcJBwAAAA==.',
['瘌痢']='瘌痢头拉尼子:BAAALgADCgMJAwABLgAFFAYJCgAQAOMaAA==.',
['白小']='白小凡:BAAALgAECgcJDAAAAA==.',
['百思']='百思特灬:BAACLgAFFH8MAAINAAQJoyRyDgClAQANAAQJoyRyDgClAQAuAAQKfyYAAg0ACAkCJTAMAGMDAA0ACAkCJTAMAGMDAAAA.',
['皓月']='皓月长歌:BAAALgAECgUJBQAAAA==.',
['直男']='直男:BAAALgADCgMJAwAAAA==.',
['真理']='真理部特使:BAAALgADCgEJAQAAAA==.',
['睡不']='睡不够的喵:BAAALgAECggJCQAAAA==.',
['矮猎']='矮猎:BAAALgAECgEJAQAAAA==.',
['碎冰']='碎冰冰:BAAALgAFFAQJBAAAAA==.',
['碎碎']='碎碎冰冰:BAABLgAFFH8QAAINAAYJXhaWGABoAQANAAYJXhaWGABoAQAAAA==.',
['示波']='示波蜜柑:BAAALgAECgEJAgAAAA==.',
['祝福']='祝福之叶:BAAALgAECgYJDwAAAA==.',
['神之']='神之恶魔复活:BAAALgAECgYJCQAAAA==.神之迷茫:BAAALgAECgYJDAAAAA==.',
['神圣']='神圣的梦泥巴:BAAALgAECgMJAwAAAA==.',
['离我']='离我十一步:BAAALgAECgEJAQAAAA==.',
['科比']='科比传球啊:BAAALgAECgYJBgAAAA==.',
['秦時']='秦時眀月:BAAALgAECgQJBQAAAA==.',
['空午']='空午:BAAALgAECgEJAQAAAA==.',
['穿叉']='穿叉裤吹风:BAAALgAECgYJBgAAAA==.',
['穿袈']='穿袈裟去蹦迪:BAAALgAECgQJBAAAAA==.',
['等我']='等我电话:BAAALgAECgYJDgAAAA==.',
['米子']='米子哈:BAABLgAECn8VAAMKAAgJuSQ+BQA1AwAKAAgJuSQ+BQA1AwAfAAIJ5BpDYgCGAAAAAA==.',
['米酒']='米酒香:BAAALgAFFAEJAQAAAA==.',
['糖小']='糖小咕猫猫:BAAALgAECgkJDwABLgAFFAYJBAAOAAAAAA==.',
['糸月']='糸月纱:BAACLgAFFH8FAAIdAAMJNAUYDgDjAAAdAAMJNAUYDgDjAAAuAAQKfxoAAh0ACAkXGrsXAHsCAB0ACAkXGrsXAHsCAAAA.',
['索西']='索西亚:BAAALgAECgYJCwAAAA==.',
['索酒']='索酒:BAABLgAFFH8IAAQgAAQJVQvBAQBcAQAgAAQJ2ArBAQBcAQAhAAEJJAkAAAAAAAACAAEJAQMAAAAAAAAAAA==.',
['紫云']='紫云闪电:BAAALgAECgEJAQAAAA==.',
['紫玥']='紫玥:BAAALgAECgMJAwAAAA==.',
['紫紫']='紫紫小号:BAAALgAECgEJAQAAAA==.',
['红叶']='红叶丶三体骑:BAAALgAECgYJBgABLgAFFAIJBQABABcSAA==.红叶丶大德:BAABLgAFFH8FAAIBAAIJFxKPGgCSAAABAAIJFxKPGgCSAAAAAA==.红叶丶布鲁萨:BAAALgAECgUJBQAAAA==.',
['红茶']='红茶加冰:BAAALgAECgUJBwAAAA==.',
['纯恋']='纯恋此生:BAAALgAECgYJBgAAAA==.',
['给你']='给你一血溅:BAAALgAECgcJBgABLgAFFAYJFQAdAHYgAA==.',
['绚辻']='绚辻词:BAACLgAFFH8JAAMYAAUJBSVsBABHAQAYAAMJ+yRsBABHAQAQAAQJLyGDCQAuAQAuAAQKfxoAAxgACQmJIxkJAC8CABgABQn1JRkJAC8CABAABQkdIphKAOoBAAAA.',
['绯红']='绯红女皇:BAAALgADCgUJBQAAAA==.绯红洛羽:BAAALgAECgcJEwAAAA==.',
['缄默']='缄默骑士:BAAALgAFFAIJAwABLgAFFAYJEwAHAMggAA==.',
['缘分']='缘分啊:BAAALgAECgYJCgAAAA==.',
['缠丝']='缠丝玛瑙:BAAALgAECgYJCgAAAA==.',
['罗生']='罗生門:BAAALgAECgMJBAAAAA==.',
['罗罗']='罗罗托马西:BAAALgAFFAEJAQAAAA==.',
['罪歌']='罪歌:BAAALgAECggJEQAAAA==.',
['美丽']='美丽死神:BAAALgAECgEJAQAAAA==.',
['群星']='群星寂灭:BAAALgAECgkJCwAAAA==.',
['羽羿']='羽羿:BAAALgAECgEJAQAAAA==.',
['翅膀']='翅膀精灵:BAAALgAECgQJCAAAAA==.',
['老派']='老派:BAAALgAECgIJAwAAAA==.',
['聖白']='聖白蓮:BAAALgAFFAEJAQAAAA==.',
['背起']='背起了行囊:BAAALgADCgIJAgAAAA==.',
['胖元']='胖元宝儿:BAAALgAECgYJCAAAAA==.',
['脚滑']='脚滑的小德:BAAALgAECgEJAgAAAA==.',
['腾焰']='腾焰飞芒:BAAALgAECgYJBgAAAA==.',
['舞风']='舞风之雨:BAAALgAECgEJAgAAAA==.',
['艾姬']='艾姬多娜:BAACLgAFFH8YAAMDAAYJfxYUBACwAQADAAUJzhUUBACwAQARAAMJIA5nAwD0AAAuAAQKfx4AAxEACQnqH34NAIECABEABwlRH34NAIECAAMAAgn+IUo9AMEAAAAA.',
['艾玛']='艾玛薬師院:BAABLgAFFH8IAAMYAAQJMSJCAQDKAAAQAAIJnCEIEwDPAAAYAAMJfCFCAQDKAAAAAA==.',
['芝士']='芝士莓莓:BAAALgAECgYJCwAAAA==.',
['芭斯']='芭斯特:BAAALgAFFAQJBAAAAA==.',
['花不']='花不渝:BAAALgAECgIJAgAAAA==.',
['花江']='花江雲:BAAALgADCgUJBQAAAA==.',
['芳心']='芳心纵火萨:BAACLgAFFH8OAAMVAAUJAhBSBQCIAQAVAAUJAhBSBQCIAQATAAMJrAfxGwCIAAAuAAQKfyIAAxUACAlEHZsNAMgCABUACAlEHZsNAMgCABMAAQllCZCZADsAAAAA.',
['苍炎']='苍炎的轨迹:BAAALgAECgYJDAAAAA==.',
['苍穹']='苍穹风雷:BAAALgAECgMJAwAAAA==.',
['若将']='若将泪水汇聚:BAAALgAECgEJAQAAAA==.',
['英姿']='英姿萨爽:BAAALgAECgkJCQAAAA==.',
['苹果']='苹果:BAACLgAFFH8PAAIDAAQJgSZpAwDHAQADAAQJgSZpAwDHAQAuAAQKfxwABBEACQmjJVMGAOoCABEABwluJlMGAOoCAAMABwlFI6QHAMcCAAgABQmOGFovAGcBAAAA.',
['茈苑']='茈苑冰凝:BAAALgAECgMJAwAAAA==.茈苑无邪:BAAALgAECgEJAQAAAA==.',
['茉莉']='茉莉花茶:BAAALgAECgEJAQAAAA==.',
['荆棘']='荆棘谷的青山:BAAALgAFFAMJAwAAAA==.',
['莉莉']='莉莉洛:BAABLgAFFH8MAAILAAQJihudDQBjAQALAAQJihudDQBjAQAAAA==.',
['莉萝']='莉萝雅:BAAALgAECgEJAQAAAA==.',
['莫名']='莫名其妙:BAAALgAECgkJCgAAAA==.',
['莫尔']='莫尔迪基安:BAAALgAECgUJBQAAAA==.',
['菜刀']='菜刀御用侍卫:BAAALgAECgYJBgAAAA==.',
['菲菲']='菲菲安:BAAALgAECgYJBwAAAA==.',
['萌萌']='萌萌哒雪梨酱:BAAALgAFFAIJAwAAAA==.',
['葡萄']='葡萄:BAAALgADCgMJAwAAAA==.',
['蓝妖']='蓝妖姬:BAAALgAECgQJBQAAAA==.',
['蓝染']='蓝染:BAABLgAECn8XAAIdAAcJ9h1TEwCdAgAdAAcJ9h1TEwCdAgAAAA==.',
['蓝海']='蓝海灵:BAAALgAECgUJBgAAAA==.',
['蓝色']='蓝色灬星辰:BAAALgAECgkJBwAAAA==.',
['蕾丝']='蕾丝芙芙:BAABLgAECn8fAAINAAgJQRtKRABrAgANAAgJQRtKRABrAgAAAA==.',
['蘸水']='蘸水米线:BAAALgADCgIJAQAAAA==.',
['虚空']='虚空之遗:BAAALgADCgEJAQAAAA==.',
['蛋炒']='蛋炒饼儿:BAAALgAECgcJCwAAAA==.',
['血丫']='血丫丫:BAAALgAECgEJAwAAAA==.',
['血无']='血无梦:BAAALgAECgEJAgAAAA==.',
['被告']='被告请坐下:BAAALgAFFAEJAQAAAA==.',
['见猎']='见猎心喜:BAAALgAECgkJBwAAAA==.',
['诡鬼']='诡鬼:BAAALgAECgIJAgAAAA==.',
['贪婪']='贪婪猫:BAAALgAECgEJAQAAAA==.',
['走去']='走去抓巨龙:BAAALgADCgcJCAAAAA==.',
['超级']='超级爱下雨:BAAALgAECgYJBgAAAA==.',
['轰炸']='轰炸黑黑猫:BAAALgAECgkJCQAAAA==.',
['迅捷']='迅捷的宝贝兔:BAAALgAECgQJBQAAAA==.',
['逝去']='逝去的哀伤啊:BAAALgAECgYJBQAAAA==.',
['那边']='那边可能有雨:BAAALgAECgcJDgAAAA==.',
['部落']='部落蜀黍:BAAALgAECgUJCgAAAA==.',
['酒醒']='酒醒入定:BAACLgAFFH8TAAIKAAUJiiQdAQAaAgAKAAUJiiQdAQAaAgAuAAQKfxUAAgoABwkmJRILANsCAAoABwkmJRILANsCAAAA.',
['酥哒']='酥哒姬:BAAALgAECgQJBQAAAA==.',
['酸菜']='酸菜五花肉:BAAALgADCgIJAwAAAA==.',
['醉梦']='醉梦无心:BAAALgAECgYJCgAAAA==.',
['醉飘']='醉飘摇:BAAALgADCgUJBQAAAA==.',
['铁娘']='铁娘子:BAAALgADCgEJAQAAAA==.',
['长尾']='长尾喵:BAAALgAECgQJCQAAAA==.',
['闲心']='闲心懿舊:BAAALgAFFAEJAQAAAA==.',
['队友']='队友强行输入:BAAALgAECgMJAwAAAA==.',
['阿宝']='阿宝神龍:BAAALgAECgkJEAAAAA==.',
['阿尔']='阿尔托利亚:BAAALgADCgYJBgAAAA==.阿尔萨司之泪:BAAALgAECgQJBAAAAA==.',
['阿肯']='阿肯因:BAAALgAECgkJAwAAAA==.',
['阿莱']='阿莱柯斯塔萨:BAAALgAECgQJBAAAAA==.',
['阿诺']='阿诺之元素:BAAALgAECgcJDQAAAA==.阿诺之审判:BAAALgAECgcJDAAAAA==.',
['陪我']='陪我看超新星:BAAALgAFFAEJAQAAAA==.',
['隐形']='隐形超亼:BAACLgAFFH8QAAITAAUJRxdWAwCjAQATAAUJRxdWAwCjAQAuAAQKfyYAAxMACQmDIJQAAAIDABMACQmDIJQAAAIDABUABAkUHj08AFsBAAAA.',
['雨师']='雨师妾:BAAALgAECgcJBAAAAA==.',
['雪乃']='雪乃灬:BAAALgAECgkJCQAAAA==.',
['雪冢']='雪冢:BAAALgAFFAIJAgABLgAFFAQJBAAOAAAAAA==.',
['雪域']='雪域灵言:BAAALgADCgYJBgAAAA==.',
['雷斯']='雷斯的迪凯:BAABLgAFFH8GAAIJAAIJCRZDPQCkAAAJAAIJCRZDPQCkAAAAAA==.',
['雷欧']='雷欧:BAAALgADCgIJAgAAAA==.',
['雷殇']='雷殇魂小号:BAAALgAECgQJBAAAAA==.',
['霜露']='霜露:BAABLgAECn8VAAINAAcJWBk7XwAdAgANAAcJWBk7XwAdAgAAAA==.',
['露娜']='露娜塔:BAAALgAFFAIJAwAAAA==.露娜森语:BAAALgAECgIJAgAAAA==.',
['韩大']='韩大脑袋:BAAALgADCgEJAQAAAA==.',
['风中']='风中尘埃:BAAALgADCgEJAQAAAA==.风中飘零:BAAALgAECgEJAwAAAA==.',
['风待']='风待:BAAALgAECgYJCQAAAA==.',
['风暴']='风暴康纳利:BAAALgAECgYJDAAAAA==.',
['风灵']='风灵的断角:BAAALgADCgUJBQAAAA==.',
['风舞']='风舞天堂:BAAALgADCgYJBgAAAA==.',
['风骚']='风骚大鸡哥:BAAALgAECgEJAQAAAA==.',
['飘飞']='飘飞的落雁:BAAALgAECgEJAQAAAA==.',
['飙龙']='飙龙妙影:BAAALgADCgcJBwAAAA==.',
['马莱']='马莱之盾贼硬:BAAALgAECgQJBAAAAA==.',
['驾驶']='驾驶班班长:BAAALgAECgUJCQAAAA==.',
['高粱']='高粱米水饭丶:BAAALgAECgEJAQAAAA==.',
['魔法']='魔法兄贵真安:BAABLgAFFH8GAAIHAAMJ5hurEQAYAQAHAAMJ5hurEQAYAQAAAA==.',
['鲜虾']='鲜虾鱼板面:BAAALgAECgQJBAAAAA==.',
['鲜血']='鲜血牛牛:BAAALgAFFAEJAgAAAA==.',
['鴻少']='鴻少:BAACLgAFFH8IAAMJAAMJ7B8wIAAZAQAJAAMJ7B8wIAAZAQAiAAEJhAN8BABNAAAuAAQKfyAAAgkACAkyH1MoAJkCAAkACAkyH1MoAJkCAAAA.',
['鶴見']='鶴見篤四郎:BAABLgAFFH8WAAIJAAYJOCK5AABZAgAJAAYJOCK5AABZAgAAAA==.',
['鸟赛']='鸟赛文:BAAALgAECgYJBgAAAA==.',
['鸢代']='鸢代代:BAAALgAECggJDgAAAA==.',
['鹘靥']='鹘靥:BAAALgAECgYJCwAAAA==.',
['麦兜']='麦兜的祝骨头:BAAALgAECgYJDAAAAA==.',
['麦格']='麦格天雷:BAAALgAECgEJAQAAAA==.',
['黄蓉']='黄蓉宝宝:BAAALgADCgYJBgAAAA==.',
['黎明']='黎明就在眼前:BAAALgAECgMJAwAAAA==.',
['黑旋']='黑旋风铜须:BAAALgAECgkJDgAAAA==.',
['黑猫']='黑猫院长大人:BAAALgADCgQJBAAAAA==.',
['黯楿']='黯楿:BAAALgAECgkJAQAAAA==.',
['黯滅']='黯滅丶:BAAALgAECgcJBwAAAA==.',
['龍戦']='龍戦:BAAALgAECgcJBwAAAA==.',
['龙汐']='龙汐丶孤鸿:BAAALgAFFAMJBAAAAA==.',
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
