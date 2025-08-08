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
 local lookup = {'Evoker-Devastation','Evoker-Preservation','Priest-Shadow','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Monk-Mistweaver','Warrior-Protection','Warrior-Arms','Hunter-BeastMastery','Mage-Frost','Mage-Arcane','DeathKnight-Blood','DeathKnight-Unholy','Monk-Windwalker','Shaman-Restoration','Shaman-Elemental','Mage-Fire','DemonHunter-Vengeance','Hunter-Marksmanship','Priest-Holy','Shaman-Enhancement','DemonHunter-Havoc','Priest-Discipline','Druid-Guardian','Druid-Restoration','Druid-Balance','Unknown-Unknown','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','Hunter-Survival','Monk-Brewmaster','Warrior-Fury','DeathKnight-Frost',}; local provider = {region='CN',realm='法拉希姆',name='CN',type='weekly',zone=42,date='2025-08-08',data={Az='Azure:BAAAKgADCgcIBwAAAA==.',Ba='Babyhms:BAABKgAFFH8QAAMBAAQIfx17EAAGAQABAAQIfx17EAAGAQACAAIIUAj1BwAsAAABKgAFFAgILAADAEMfAA==.Babyms:BAACKgAFFH8sAAIDAAgIQx8BAQD4AQADAAgIQx8BAQD4AQAqAAQKfxwAAgMACAhSIdwOAHECAAMACAhSIdwOAHECAAAA.Babyqs:BAABKgAFFH8eAAQEAAYIZBSMOgACAQAEAAQIkRyMOgACAQAFAAQIwxTYCwDGAAAGAAYIaAbTCwCaAAABKgAFFAgILAADAEMfAA==.Babyss:BAABKgAFFH8LAAMHAAQImRpUEwD4AAAHAAQImRpUEwD4AAAIAAEIYQwBEwBBAAABKgAFFAgILAADAEMfAA==.',Bl='Blind:BAABKgAFFH8KAAMHAAYIBxiBFgBPAQAHAAUILxuBFgBPAQAJAAIIagsbKQBHAAAAAA==.',Br='Bron:BAABKgAFFH8KAAIKAAYIJh8RCAAqAQAKAAYIJh8RCAAqAQAAAA==.',Cr='Critcake:BAABKgAFFH8GAAMLAAQIQhPLBADDAAALAAQIQhPLBADDAAAMAAIIygzUEgCHAAABKgAFFAgICQANAM8VAA==.',Da='Dagon:BAAAKgAECgUIBwAAAA==.Dajia:BAAAKgAECggICAAAAA==.',De='Devils:BAACKgAFFH9GAAQIAAgI2Rb4BQAlAQAIAAQI+BT4BQAlAQAHAAUI7g1XFADpAAAJAAMInyGhIABfAAAqAAQKfzQABAkACAgXHT0eAI4BAAkABwiYHD0eAI4BAAcABwilFEJFAFQBAAgABAg+FekeAPkAAAAA.',Di='Diverdown:BAAAKgAFFAMIAwAAAA==.',Do='Donut:BAAAKgAFFAYIBAAAAA==.',Ex='Excarlibur:BAAAKgADCggICAAAAA==.',Fa='Fane:BAAAKgAECggICQAAAA==.',Gr='Grand:BAAAKgAFFAEIAQAAAA==.',Gu='Gustavo:BAAAKgAECggICgAAAA==.',Hi='Hideonbush:BAAAKgAECgEIAQAAAA==.',Li='Lillin:BAAAKgAECgMIBAAAAA==.',Me='Meow:BAAAKgADCgEIAQAAAA==.',Mo='Moodyblues:BAABKgAFFH8QAAMOAAYIxhkKBAAVAQAPAAYIzRGwEABkAQAOAAQIKiAKBAAVAQAAAA==.Mostima:BAAAKgAECgUIBQAAAA==.',Ph='Pharah:BAABKgAFFH8GAAIHAAYIFBcGEgB4AQAHAAYIFBcGEgB4AQAAAA==.',Po='Pomrakkun:BAAAKgAFFAQIBAAAAA==.',Pu='Pulordmorl:BAAAKgAECggICgAAAA==.',Rd='Rdie:BAABKgAFFH8IAAMQAAQI5w3gGACNAAARAAQI5w3vOQC1AAAQAAQI5AbgGACNAAAAAA==.',Re='Reapel:BAAAKgAECgcIDgAAAA==.',Ru='Ruler:BAABKgAFFH8JAAMSAAYIFxrfBgCeAQASAAYIFxrfBgCeAQAKAAEIAACvMQAAAAAAAA==.',Sa='Sakazakii:BAAAKgAFFAgIAwAAAA==.Sananna:BAAAKgAECgEIAQAAAA==.Sasuke:BAAAKgAFFAQIBAAAAA==.',Sh='Shadowheart:BAABKgAECn8WAAIHAAgIWSJMCgBrAgAHAAgIWSJMCgBrAgAAAA==.',St='Strawberry:BAABKgAFFH8IAAIEAAgIVhaaBwA8AgAEAAgIVhaaBwA8AgAAAA==.',Ve='Venusqs:BAABKgAFFH8aAAMTAAgIJyC2AQB1AgATAAgIJyC2AQB1AgAUAAIIhB8XDgC2AAAAAA==.',Vi='Vitktord:BAABKgAFFH8FAAIVAAUIXRvGEQAzAQAVAAUIXRvGEQAzAQAAAA==.',Vv='Vvtanknewbie:BAACKgAFFH8IAAIQAAgIBSJKAQDEAgAQAAgIBSJKAQDEAgAqAAQKfxYAAxEACAiTGWdGAJoBABEACAjcFmdGAJoBABAABAjzGKw+AMUAAAAA.',Yb='Ybnb:BAABKgAFFH8FAAIWAAUIQAcKCgCsAAAWAAUIQAcKCgCsAAAAAA==.',Yu='Yukino:BAAAKgADCggICAAAAA==.',Yz='Yz:BAAAKgAECgEIAgAAAA==.',Za='Zarya:BAABKgAFFH8IAAMXAAQIhCOXIADyAAAXAAQIoiCXIADyAAANAAQIIhjrKADiAAAAAA==.',Zi='Zireael:BAAAKgAECgcIDQAAAA==.',Zy='Zywoo:BAAAKgADCgYIBgAAAA==.',['一战']='一战:BAAAKgAECgIIAQAAAA==.',['一拳']='一拳小星星:BAAAKgADCggICAAAAA==.',['一果']='一果可爱捏:BAACKgAFFH8tAAMRAAgIAB4UCwDdAQARAAgIHh0UCwDdAQAQAAQIBybPBgAmAQAqAAQKfx8AAxAACAjKITcLAHICABAACAgoITcLAHICABEABAglI942AJkBAAAA.',['一殇']='一殇:BAABKgAFFH8GAAIYAAYIBxybCQCJAQAYAAYIBxybCQCJAQAAAA==.',['一颗']='一颗糖:BAAAKgADCgEIAQAAAA==.',['一魚']='一魚一:BAAAKgAECggICgAAAA==.',['丁尼']='丁尼格费尔:BAAAKgAFFAMIAwAAAA==.',['三颗']='三颗糖:BAAAKgADCgUIBQAAAA==.',['不难']='不难:BAAAKgAECgIIAgAAAA==.',['丨小']='丨小鱼:BAAAKgAECgMIAwAAAA==.',['丨法']='丨法神丶:BAABKgAFFH8JAAIVAAYIuiJ4AQAiAgAVAAYIuiJ4AQAiAgAAAA==.',['丨风']='丨风度丨:BAAAKgAECggICgAAAA==.',['丶為']='丶為愛奮戦:BAACKgAFFH8FAAIXAAQIvBRtFgCxAAAXAAQIvBRtFgCxAAAqAAQKfxgAAhcACAg3H2cOAGYCABcACAg3H2cOAGYCAAAA.',['丶莉']='丶莉芳:BAACKgAFFH8GAAIDAAQI9gidHgB0AAADAAQI9gidHgB0AAAqAAQKfxoAAgMACAisGkomAKQBAAMACAisGkomAKQBAAAA.',['丶齐']='丶齐柏林:BAABKgAFFH8PAAIZAAQI5Ba5DgDmAAAZAAQI5Ba5DgDmAAAAAA==.',['丸纸']='丸纸喵:BAAAKgAFFAYIAgAAAA==.',['为你']='为你活着:BAACKgAFFH8QAAMRAAgI4w0SCwDdAQARAAgI4w0SCwDdAQAQAAQI1w6jFwCUAAAqAAQKfxgAAxEACAhUIxYKAMwCABEACAhUIxYKAMwCABAACAgsDS8wABQBAAAA.',['乌瑞']='乌瑞尔勛爵:BAAAKgAECggIBAAAAA==.',['乐布']='乐布裙:BAAAKgAFFAgIAgAAAA==.',['二狗']='二狗骑士:BAAAKgAFFAIIAgAAAA==.',['五条']='五条悟:BAAAKgAECgQIBwAAAA==.',['人间']='人间小苦瓜:BAAAKgADCggICAAAAA==.人间忽晚:BAAAKgAECgQIBQAAAA==.',['亿利']='亿利达雷:BAAAKgAECggIEwAAAA==.',['今天']='今天吃什么:BAAAKgADCggICAAAAA==.',['仙乐']='仙乐:BAAAKgAFFAIIAgAAAA==.',['伊丽']='伊丽丹丶怛秀:BAAAKgAECgIIAgAAAA==.',['伊利']='伊利双:BAAAKgAECgcIBwAAAA==.伊利莎灬怒风:BAABKgAFFH8MAAMaAAgIKxBUDADAAQAaAAgIKwxUDADAAQAWAAQIYQvkCwDwAAAAAA==.',['假面']='假面恶灵:BAAAKgAFFAEIAQAAAA==.假面战魂:BAAAKgAFFAEIAQAAAA==.',['傲视']='傲视鱼儿:BAACKgAFFH8SAAMbAAMIgh1XFAD0AAAbAAMIgh1XFAD0AAAYAAIIhgIfHwBiAAAqAAQKfxYAAxgACAj6GYkdAO4BABgACAi4FokdAO4BABsABwjOFPEmAG8BAAAA.',['光之']='光之祈愿:BAAAKgADCgQIBAAAAA==.光之霍因海姆:BAABKgAFFH8GAAIEAAYIaxIjIwBfAQAEAAYIaxIjIwBfAQAAAA==.',['光辉']='光辉之耀:BAAAKgAECgIIAgAAAA==.',['克鲁']='克鲁鲁娜:BAABKgAFFH8GAAIHAAYImRdqFQBYAQAHAAYImRdqFQBYAQAAAA==.',['兜里']='兜里有块糖:BAAAKgAECggICAAAAA==.',['冬秋']='冬秋夏春:BAAAKgAECgcIBwAAAA==.',['冷冰']='冷冰凝爱语梦:BAABKgAFFH8GAAIPAAYI/RCzFAA/AQAPAAYI/RCzFAA/AQAAAA==.',['冻柠']='冻柠檬:BAAAKgAECgEIAQAAAA==.',['冻椰']='冻椰奶:BAAAKgAECgcIDwAAAA==.',['凱麗']='凱麗根:BAAAKgAECggICAAAAA==.',['凹凸']='凹凸曼:BAACKgAFFH8RAAITAAMIWxu2JADkAAATAAMIWxu2JADkAAAqAAQKfyAAAhMABwhyF3FIAGgBABMABwhyF3FIAGgBAAAA.',['刘淑']='刘淑琴:BAAAKgADCgIIAgAAAA==.',['刚贵']='刚贵才:BAAAKgAECggICAAAAA==.',['刷子']='刷子:BAAAKgAECggICgAAAA==.',['刹那']='刹那年华:BAABKgAFFH8dAAMXAAUIcyUwBgAXAQAXAAUIcyUwBgAXAQANAAII0RoNSQBFAAAAAA==.',['势不']='势不可挡土灵:BAABKgAECn8eAAIEAAgIcSBNTAANAgAEAAgIcSBNTAANAgAAAA==.势不可挡盾兵:BAAAKgADCgUIBQAAAA==.',['勒科']='勒科克:BAAAKgADCggICQAAAA==.',['勥大']='勥大:BAAAKgADCggICAAAAA==.',['北海']='北海蔷薇:BAABKgAFFH8GAAINAAYIoiVEBwANAgANAAYIoiVEBwANAgAAAA==.',['南燕']='南燕皇家骑士:BAAAKgAECgIIAgAAAA==.',['南风']='南风知我矣:BAAAKgAFFAQIBAAAAA==.',['卡利']='卡利亚的锋刃:BAAAKgADCggICAAAAA==.',['卡扎']='卡扎菲:BAAAKgADCgIIAgAAAA==.',['发型']='发型很危险:BAAAKgAFFAIIAgAAAA==.',['叮铃']='叮铃桄榔:BAACKgAFFH8KAAIbAAgIsxe6AwAfAgAbAAgIsxe6AwAfAgAqAAQKfxsAAxgACAirEPg0AGsBABgABwjUEvg0AGsBABsAAwhyCFZ4AGQAAAAA.',['司空']='司空风风:BAAAKgADCggICAAAAA==.',['吉米']='吉米佩奇:BAAAKgAFFAEIAQAAAA==.',['吉羽']='吉羽令羽:BAAAKgAECgYICwAAAA==.',['名字']='名字长就能苟:BAAAKgAECgQIBAAAAA==.',['向曰']='向曰葵不向曰:BAABKgAECn8UAAIYAAgI2Q+POABbAQAYAAgI2Q+POABbAQAAAA==.',['吨吨']='吨吨桶:BAABKgAFFH8IAAIEAAgI3g1qDgDxAQAEAAgI3g1qDgDxAQAAAA==.',['听罢']='听罢龙吟:BAAAKgAECgIIAgAAAA==.',['吴春']='吴春花:BAAAKgADCgQIBAAAAA==.',['吾以']='吾以氵德服人:BAABKgAECn8ZAAIcAAgI4BN8EgCDAQAcAAgI4BN8EgCDAQAAAA==.',['吾儿']='吾儿袁袁丶:BAABKgAFFH8KAAMdAAYIbBI9AgB9AQAdAAYIbBI9AgB9AQAeAAQIpSJ6KQDtAAABKgAFFAgIBAAfAAAAAA==.',['呆毛']='呆毛球球:BAAAKgAECgEIAQAAAA==.',['哈伲']='哈伲狐狸:BAAAKgAECgMIAwAAAA==.',['哈士']='哈士骑:BAAAKgADCggICAAAAA==.',['唐一']='唐一一:BAAAKgAECgYIBgAAAA==.',['唐纳']='唐纳德宝:BAAAKgAFFAQIBAAAAA==.唐纳德钰:BAAAKgADCggICAAAAA==.唐纳德馨:BAAAKgADCggICgAAAA==.',['啊这']='啊这也太好啦:BAAAKgAFFAgIBAAAAA==.',['喂我']='喂我花生:BAAAKgAECgYIBwAAAA==.',['喜欢']='喜欢打天:BAAAKgAECgIIAgAAAA==.',['嗯哼']='嗯哼丶:BAAAKgAFFAQIAwAAAA==.',['嘟嘟']='嘟嘟熊:BAAAKgADCgcICwAAAA==.',['回锅']='回锅肉:BAAAKgADCgQIBAAAAA==.',['囧囧']='囧囧丷:BAACKgAFFH8FAAIOAAMISR6xEwDJAAAOAAMISR6xEwDJAAAqAAQKfxYAAg4ACAioJEMIAMcCAA4ACAioJEMIAMcCAAEqAAUUCAgOABUAwyIA.囧囧灬:BAAAKgAECgcIBwAAAA==.',['囿团']='囿团囡囝:BAAAKgAECgcICwAAAA==.',['圈养']='圈养小兔熊:BAAAKgADCgQIBAAAAA==.',['圣丨']='圣丨骑士:BAAAKgAECggIDgAAAA==.',['圣光']='圣光的永恒:BAAAKgAECgMIBAAAAA==.',['圣十']='圣十字审判:BAAAKgADCgYIBgAAAA==.',['圣芒']='圣芒使者:BAABKgAFFH8GAAIEAAYIPg9jJABZAQAEAAYIPg9jJABZAQAAAA==.',['埃兰']='埃兰之赐:BAAAKgAFFAQIAgAAAA==.',['城户']='城户沙织:BAAAKgADCggICAAAAA==.',['基诺']='基诺理维斯:BAAAKgAFFAYIBAAAAA==.',['塔兰']='塔兰克斯:BAACKgAFFH8eAAQgAAQIaBBDCgC+AAAhAAQIYw+1HADHAAAgAAMIrgJDCgC+AAAiAAQIwwj7BgChAAAqAAQKfyAABCAACAgkGZoRANMBACAACAgHFJoRANMBACEABQj6HDsPACkBACIAAQizDR4fADQAAAAA.塔兰骑:BAACKgAFFH8FAAIRAAMIpgWqPQCnAAARAAMIpgWqPQCnAAAqAAQKfxgAAhEACAgRE3s5AI4BABEACAgRE3s5AI4BAAAA.',['墨影']='墨影:BAAAKgAECgUIBQAAAA==.墨影游侠:BAABKgAECn8iAAQNAAgIqRrAHQCLAQANAAgIbhrAHQCLAQAXAAcIuAkSagC4AAAjAAMIyBB6EgCXAAAAAA==.',['壹粒']='壹粒蛋丶怒风:BAAAKgADCggICAAAAA==.',['夏夕']='夏夕烟:BAABKgAFFH8aAAIdAAQIVSYyBgAXAQAdAAQIVSYyBgAXAQABKgAFFAgIDgATAOEeAA==.',['夏芽']='夏芽:BAAAKgAFFAQIBAAAAA==.',['夜一']='夜一丶:BAAAKgAECggIDAAAAA==.',['夜影']='夜影舞:BAAAKgAECgIIBgAAAA==.',['夜月']='夜月没断:BAAAKgADCgEIAQAAAA==.',['夜来']='夜来风雨笙:BAAAKgADCgUIBQAAAA==.',['大祭']='大祭司:BAAAKgADCggICAAAAA==.',['夺命']='夺命牙签:BAABKgAFFH8HAAMeAAQIexQjFwDhAAAeAAQIexQjFwDhAAAdAAII8hi8FACOAAAAAA==.',['奥克']='奥克雷斯特:BAAAKgAFFAgIAgAAAA==.',['奥尼']='奥尼科西亚:BAAAKgAECgUIBQAAAA==.',['女帝']='女帝柳如烟:BAAAKgAFFAMIBAAAAA==.',['好多']='好多德:BAAAKgAECgIIAgAAAA==.',['妖龙']='妖龙:BAABKgAFFH8IAAIBAAYIRRCDDQBNAQABAAYIRRCDDQBNAQAAAA==.',['妮迪']='妮迪塔斯:BAACKgAFFH8ZAAIYAAgI0R5OAgBZAgAYAAgI0R5OAgBZAgAqAAQKfzgAAhgACAgFIpELAHYCABgACAgFIpELAHYCAAAA.',['姜岑']='姜岑:BAAAKgAFFAIIAgAAAA==.',['娜乌']='娜乌熙卡:BAAAKgADCggICgAAAA==.',['婷婷']='婷婷熊:BAAAKgAECggIDAAAAA==.',['婷熊']='婷熊:BAAAKgAECgMIAwAAAA==.婷熊婷:BAAAKgAECgUIBQAAAA==.婷熊熊:BAAAKgAFFAMIAwAAAA==.',['嫂嫂']='嫂嫂请放手:BAAAKgADCgYIBgAAAA==.',['子夜']='子夜梦:BAABKgAFFH8PAAMdAAYIqyRdAAAlAgAdAAYIqyRdAAAlAgAeAAQI6RdpGADdAAABKgAFFAgIEQAdAD4jAA==.',['宁静']='宁静之乐:BAAAKgAFFAEIAQAAAA==.宁静之约:BAAAKgADCggICAAAAA==.',['安全']='安全大酋长:BAABKgAFFH8FAAMEAAMICAe0OQB2AAAEAAMIYQa0OQB2AAAFAAIIpAPcKABJAAAAAA==.',['安迪']='安迪斯丶血魔:BAAAKgAFFAQIBAAAAA==.',['宝贝']='宝贝人武:BAACKgAFFH8YAAMKAAgIfhQ1BQDVAQAKAAgIfhQ1BQDVAQASAAQIYw1yDQDQAAAqAAQKfxsABBIACAhXHtcXACECABIACAhvHdcXACECAAoABwizEYg/AEMBACQABAgdGzYQACgBAAEqAAUUCAgsAAMAQx8A.',['寂寞']='寂寞也狂欢:BAACKgAFFH8KAAMTAAYI8Rh9DwDmAAATAAQIpxZ9DwDmAAAZAAIILhS8DgC4AAAqAAQKfxgABBkACAhRGNEcAOIBABkACAh9F9EcAOIBABMABgjWGhxjABcBABQAAghYEZJtAHAAAAEqAAUUCAgOAAwADRcA.',['寒江']='寒江:BAABKgAFFH8JAAMOAAYIpRwSBgBxAQAOAAYIWhsSBgBxAQAPAAMIFBFtOACAAAAAAA==.',['寫輪']='寫輪眼蕩漾:BAAAKgAECgUIBQAAAA==.',['射杀']='射杀环取之日:BAAAKgAECgEIAQAAAA==.',['将晓']='将晓玉:BAAAKgADCgcIBwAAAA==.',['小凹']='小凹凸嫚:BAABKgAFFH8ZAAMMAAgIyh7vAQCBAgAlAAgINxwOAwCMAgAMAAgIUB3vAQCBAgAAAA==.',['小季']='小季摆:BAAAKgAFFAQIBAAAAA==.',['小小']='小小怪兽:BAABKgAFFH8IAAIEAAgIQhRHCgAgAgAEAAgIQhRHCgAgAgAAAA==.',['小水']='小水母:BAAAKgAECgMIAwAAAA==.',['小西']='小西红柿:BAAAKgAFFAEIAQAAAA==.',['小迷']='小迷途:BAABKgAFFH8SAAIKAAYI3yEDBwDMAQAKAAYI3yEDBwDMAQAAAA==.',['小黑']='小黑手骑骑:BAAAKgAECgcIBwAAAA==.',['尐乳']='尐乳豬:BAABKgAFFH8SAAMhAAYIYSCZCADZAQAhAAYIYSCZCADZAQAgAAMIpwy/DQCLAAAAAA==.',['尐騎']='尐騎壵:BAAAKgAECggICAAAAA==.',['尼踩']='尼踩:BAABKgAFFH8GAAMJAAYIFBBEBwAHAQAJAAUIsRJEBwAHAQAHAAEIngWhTAA8AAAAAA==.',['山河']='山河已秋:BAAAKgAECgcIBwAAAA==.',['巨石']='巨石冬瓜:BAAAKgAECgYICwAAAA==.',['已读']='已读乱回:BAAAKgADCgEIAQAAAA==.',['帕拉']='帕拉丁的激流:BAABKgAFFH8GAAITAAYIhBrqCwCJAQATAAYIhBrqCwCJAQAAAA==.',['帝国']='帝国之术:BAAAKgADCggICAAAAA==.',['幽幽']='幽幽我歆:BAAAKgAECgQIAQAAAA==.幽幽我芯:BAAAKgAECgIIAgAAAA==.',['幽西']='幽西:BAAAKgAFFAQIBAAAAA==.',['广西']='广西第一深情:BAAAKgAECggICAAAAA==.',['开心']='开心就好:BAAAKgADCgIIAgAAAA==.',['强力']='强力迪凯:BAABKgAFFH8OAAMQAAYIPhESFgDxAAAQAAYIogsSFgDxAAARAAQITBV6NADFAAAAAA==.',['强龘']='强龘:BAAAKgADCggICAAAAA==.',['当年']='当年那瓶津威:BAABKgAECn8UAAMRAAgI4glWYQD6AAARAAcIdQpWYQD6AAAQAAcIcgMDQwBqAAAAAA==.当年那瓶芬达:BAAAKgAECgYICAAAAA==.',['影子']='影子白菜:BAABKgAFFH8IAAQbAAMIMwQZGQCZAAAbAAMIMwQZGQCZAAADAAMIuwE/JgBeAAAYAAEIFgGOQwAkAAAAAA==.',['影炙']='影炙怒风:BAAAKgAECgUICwAAAA==.',['影色']='影色舞:BAAAKgADCgEIAQAAAA==.',['御坂']='御坂灬天使:BAACKgAFFH9LAAIUAAYIYiWAAgA6AQAUAAYIYiWAAgA6AQAqAAQKfygAAhQACAhoJrYEANwCABQACAhoJrYEANwCAAAA.',['德丶']='德丶兰妮:BAABKgAFFH8GAAITAAYI/R7HAADVAQATAAYI/R7HAADVAQABKgAFFAgIDgATABUPAA==.',['德德']='德德小浣熊:BAABKgAFFH8GAAIKAAYIog/AEAAmAQAKAAYIog/AEAAmAQABKgAFFAgIJgAMAHgcAA==.',['怒涛']='怒涛卷霜雪:BAEBKgAFFH8KAAQJAAYI2B0OBQDlAAAIAAQIoCHkBQD8AAAJAAQIzBIOBQDlAAAHAAIILBjkNACcAAAAAA==.',['怒焰']='怒焰小法:BAABKgAECn8VAAIOAAgI0hItDQCpAQAOAAgI0hItDQCpAQAAAA==.',['愿圣']='愿圣光闪瞎你:BAABKgAFFH8IAAIEAAMIvx8JNwAPAQAEAAMIvx8JNwAPAQAAAA==.',['慧宝']='慧宝宝:BAAAKgAECggIEwAAAA==.',['我叫']='我叫为难:BAACKgAFFH8bAAIQAAQIPyRrCQAAAQAQAAQIPyRrCQAAAQAqAAQKfyEAAhAACAiXIbAMAF8CABAACAiXIbAMAF8CAAAA.我叫牙套姐:BAACKgAFFH8iAAINAAYI+x+xDQCWAQANAAYI+x+xDQCWAQAqAAQKfy4AAg0ACAhSJEIdAIICAA0ACAhSJEIdAIICAAAA.',['我才']='我才是奶龙:BAABKgAFFH8IAAIBAAgI6Qe1CgCgAQABAAgI6Qe1CgCgAQAAAA==.',['我爱']='我爱夏天:BAAAKgAFFAMIAwAAAA==.',['我的']='我的野茉莉:BAAAKgADCggICAAAAA==.',['战无']='战无畏惧:BAAAKgAECggIDQAAAA==.',['战神']='战神果爸:BAAAKgAECgcICgAAAA==.',['执着']='执着丶为那爱:BAAAKgADCggICAAAAA==.',['承诺']='承诺六六:BAAAKgADCgIIAgAAAA==.',['拽拽']='拽拽的小肖:BAABKgAFFH8MAAIYAAYIWCJfBQDjAQAYAAYIWCJfBQDjAQAAAA==.',['掠天']='掠天之翼:BAAAKgAFFAgIBAAAAA==.',['敖闰']='敖闰:BAAAKgAECgQIBAAAAA==.',['断桥']='断桥雪:BAABKgAFFH8GAAIaAAQIrxQ4HAAfAQAaAAQIrxQ4HAAfAQABKgAFFAgIDAAaANQlAA==.',['新新']='新新怡怡:BAAAKgAECgUIBQAAAA==.',['无敌']='无敌和炉石:BAAAKgAFFAEIAQAAAA==.',['无聊']='无聊玩小号了:BAABKgAECn8aAAIEAAgI7g5gfgBTAQAEAAgI7g5gfgBTAQAAAA==.',['时代']='时代在召唤:BAAAKgAFFAMIAwAAAA==.',['时未']='时未寒:BAAAKgAECgQIBAAAAA==.',['星之']='星之匙:BAAAKgADCgIIAgAAAA==.',['星空']='星空下的麦田:BAACKgAFFH8HAAMHAAUIFyOsEgByAQAHAAUIFyOsEgByAQAIAAIIqSCoGQBUAAAqAAQKf3EABAcACAgGJg8PAHECAAcABwgMJA8PAHECAAkABggkJlQNACoCAAgABQg+IXkGAHgBAAAA.',['是的']='是的咯:BAACKgAFFH8bAAIhAAQI5A1vDQDKAAAhAAQI5A1vDQDKAAAqAAQKfxkAAiEACAh2F94UAMwBACEACAh2F94UAMwBAAAA.',['晚睡']='晚睡猫咪:BAABKgAFFH8IAAIEAAMImB77OAAIAQAEAAMImB77OAAIAQAAAA==.',['普罗']='普罗比斯:BAACKgAFFH8GAAIaAAMIxgrxMwCxAAAaAAMIxgrxMwCxAAAqAAQKfxgAAhoACAg3Gew3AMsBABoACAg3Gew3AMsBAAAA.',['暗夜']='暗夜灬男:BAACKgAFFH8bAAMeAAQI3xeWLgDZAAAeAAQI3xeWLgDZAAAdAAMI0xLJHgCyAAAqAAQKfygAAx4ACAgWHZotAPgBAB4ACAgWHZotAPgBAB0AAwibEVJfAJcAAAAA.',['暗月']='暗月狩狼:BAAAKgAECgMIAQAAAA==.',['暗黑']='暗黑小德:BAABKgAFFH8GAAIeAAYIpBcIFgBoAQAeAAYIpBcIFgBoAQAAAA==.',['暴走']='暴走大叔:BAAAKgADCggICAAAAA==.暴走皮皮虾:BAAAKgAECgUIBQAAAA==.',['月亮']='月亮代表我心:BAACKgAFFH8SAAMOAAMI1BZRCQDjAAAOAAMI1BZRCQDjAAAPAAEIcwKGKgAiAAAqAAQKfyQAAg4ACAgaI1IGAFMCAA4ACAgaI1IGAFMCAAAA.月亮的死骑:BAABKgAFFH8IAAIRAAMIzxLNMgDKAAARAAMIzxLNMgDKAAAAAA==.',['有龙']='有龙乃大:BAABKgAFFH8IAAIBAAgI/hBXCAD6AQABAAgI/hBXCAD6AQAAAA==.',['木丨']='木丨頭:BAAAKgAECggIDQAAAA==.',['术术']='术术得氵正:BAABKgAECn8eAAMJAAgIWg0RQADzAAAHAAgIvgn1WgAAAQAJAAcIyQoRQADzAAAAAA==.',['李沐']='李沐恩:BAAAKgAECgcICwAAAA==.',['杏花']='杏花疏影里:BAABKgAFFH8KAAIBAAYIUiWkBgAnAgABAAYIUiWkBgAnAgAAAA==.',['松风']='松风入清听:BAAAKgADCggICAAAAA==.',['林佳']='林佳树:BAACKgAFFH8UAAMOAAQI4RmMDADJAAAPAAQIhxkvIgDcAAAOAAMIxRCMDADJAAAqAAQKfxwABA4ACAioG1MiAP4BAA4ACAgdGlMiAP4BAA8AAgh2GSQkAHIAABUAAwhYEKCJAGgAAAAA.',['果爸']='果爸先生:BAAAKgAECgMIAwAAAA==.',['枫林']='枫林下线:BAACKgAFFH8eAAISAAcIjhPFBQDLAQASAAcIjhPFBQDLAQAqAAQKfyYAAhIACAgXIPASAB0CABIACAgXIPASAB0CAAAA.',['柯南']='柯南:BAAAKgAECgIIAgAAAA==.',['格特']='格特鲁德:BAAAKgAFFAQIBAAAAA==.',['桐三']='桐三三丶:BAAAKgAECgYIBgAAAA==.',['梓晔']='梓晔:BAABKgAFFH8IAAILAAQIxRKKDACgAAALAAQIxRKKDACgAAAAAA==.',['梦幻']='梦幻哦哦:BAAAKgAFFAIIAgAAAA==.',['棉发']='棉发糖:BAAAKgADCggIDgAAAA==.',['榻血']='榻血寻灵根:BAAAKgAFFAIIAgAAAA==.',['樱桃']='樱桃鱼丸子:BAAAKgAECggICAAAAA==.',['橘子']='橘子的邂逅:BAAAKgAECgYIBgAAAA==.',['橙子']='橙子萱:BAAAKgAFFAEIAQAAAA==.',['欲乘']='欲乘风:BAAAKgAFFAgIBAAAAA==.',['武装']='武装熊喵:BAAAKgADCgYIBgAAAA==.',['死亡']='死亡之丶毅驴:BAABKgAFFH8KAAIlAAgIGhmhAAD2AQAlAAgIGhmhAAD2AQAAAA==.死亡毅丶毅驴:BAACKgAFFH8bAAMBAAQIcSPzCwDuAAABAAQIcSPzCwDuAAACAAQI/g/LBADFAAAqAAQKfyAAAgIACAg9EccJAHABAAIACAg9EccJAHABAAAA.',['死寂']='死寂之寒:BAAAKgAECggIEQAAAA==.',['残忆']='残忆流年:BAABKgAFFH8MAAIEAAgItxadCgAcAgAEAAgItxadCgAcAgAAAA==.',['残牙']='残牙:BAABKgAECn8eAAIRAAgIKRnfHgAdAgARAAgIKRnfHgAdAgAAAA==.',['水之']='水之加百列:BAAAKgAECggICAAAAA==.',['水寧']='水寧兒:BAABKgAFFH8GAAISAAYIABlLAQDcAQASAAYIABlLAQDcAQAAAA==.',['氵大']='氵大司命:BAAAKgAECgYIDAAAAA==.',['氵熊']='氵熊战:BAABKgAECn8tAAQMAAgIlg9jFAD1AAAMAAcINA9jFAD1AAALAAgIogrCKgDZAAAlAAUIxQgPbwCeAAAAAA==.',['汉诺']='汉诺崇高力量:BAAAKgAECgIIAgAAAA==.',['汪汪']='汪汪鱼鳍:BAAAKgAECgMIBgAAAA==.',['没弦']='没弦的断:BAAAKgADCgEIAQAAAA==.',['没断']='没断嘚弦:BAACKgAFFH8IAAIEAAMIZhzIOwD+AAAEAAMIZhzIOwD+AAAqAAQKfx4AAgQACAhbH/xDAPUBAAQACAhbH/xDAPUBAAAA.没断愈合祷言:BAAAKgADCgEIAgAAAA==.没断的弦:BAAAKgADCgMIAwAAAA==.',['沧古']='沧古烟:BAAAKgADCgcIBwAAAA==.',['法尔']='法尔伽:BAAAKgADCggICAAAAA==.',['泽伊']='泽伊:BAABKgAFFH8OAAIMAAYIDRdEAgCQAQAMAAYIDRdEAgCQAQAAAA==.',['流氓']='流氓包工头:BAABKgAFFH8MAAIHAAMIfwl9MgClAAAHAAMIfwl9MgClAAAAAA==.',['流风']='流风幻葬:BAACKgAFFH8bAAIHAAQI8RUnGQC8AAAHAAQI8RUnGQC8AAAqAAQKfysABAcACAiZHCMdAL4BAAcABwglHCMdAL4BAAgAAQhQHxU8AFYAAAkAAQheHoxyAFIAAAAA.',['浅笑']='浅笑安然:BAABKgAFFH8GAAIPAAYIDR+fCQDWAQAPAAYIDR+fCQDWAQABKgAFFAgIBgAPALAdAA==.',['浩瀚']='浩瀚星海:BAAAKgADCgEIAQAAAA==.',['浮云']='浮云若逝:BAACKgAFFH8GAAMOAAII5Ak4FwB9AAAOAAII5Ak4FwB9AAAPAAIIcQb/PgBgAAAqAAQKfzIAAw4ACAgGHSMTACcCAA4ACAhYHCMTACcCAA8ACAh4FnE9AE4BAAAA.',['海兰']='海兰珠:BAAAKgAECgYIBgAAAA==.',['海因']='海因特:BAAAKgAFFAQIBAABKgAFFAgIGwAaAI0bAA==.',['涂山']='涂山红红:BAAAKgADCgYIBgAAAA==.',['深深']='深深呼吸:BAAAKgAECgUIBQAAAA==.',['深爱']='深爱牛肉汤:BAAAKgAECgcIEwAAAA==.',['混世']='混世大叔:BAABKgAFFH8GAAIEAAYIoQ8DKgA/AQAEAAYIoQ8DKgA/AQAAAA==.',['火油']='火油:BAAAKgAECggIBgAAAA==.',['火霸']='火霸:BAAAKgADCgMIAwAAAA==.',['灬孙']='灬孙小戦灬:BAAAKgAECggICAAAAA==.灬孙小猎灬:BAAAKgAFFAgIBAAAAA==.',['灬沫']='灬沫丶尛:BAABKgAFFH8HAAIHAAcIdR4rBABGAgAHAAcIdR4rBABGAgAAAA==.',['灬芙']='灬芙莉莲灬:BAAAKgAECggICwAAAA==.',['灵愈']='灵愈星语丶橙:BAAAKgAECgUIBQAAAA==.',['灼墨']='灼墨丶憨憨:BAAAKgAECgEIAgAAAA==.',['炮丶']='炮丶灰灰:BAAAKgAECgYIBwAAAA==.',['熊婷']='熊婷婷:BAAAKgAECgUIBgAAAA==.熊婷熊婷:BAAAKgAECgUIBQAAAA==.',['熊熊']='熊熊婷:BAAAKgAECggICAAAAA==.',['熊猪']='熊猪:BAABKgAFFH8GAAIQAAYIzxFSAwBeAQAQAAYIzxFSAwBeAQAAAA==.',['燕知']='燕知春:BAACKgAFFH87AAMbAAgIyyKEAQDHAQAYAAgIyyJZAgBXAgAbAAYI9BaEAQDHAQAqAAQKf1EAAxgACAiKJGkFAMECABgACAh+JGkFAMECABsACAgEH7ELAHQCAAAA.',['燕飞']='燕飞玉鸿:BAAAKgAECggIBgAAAA==.',['爱机']='爱机斯坦:BAAAKgADCggICAAAAA==.',['爱泽']='爱泽咲夜:BAAAKgAECgYICAAAAA==.',['爷傲']='爷傲灬奈我何:BAABKgAFFH8MAAIRAAgIVBE/CQD5AQARAAgIVBE/CQD5AQAAAA==.',['牧法']='牧法氵牧天:BAAAKgAECgEIBAAAAA==.',['牧牧']='牧牧:BAAAKgADCgQIBAAAAA==.',['犹格']='犹格索托斯:BAAAKgAECgYIBgAAAA==.',['狗得']='狗得被人砍:BAACKgAFFH8cAAMVAAQIGCb8DQAnAQAPAAQI3iVqEwBJAQAVAAQIDSX8DQAnAQAqAAQKfzYAAxUACAhsJi0CAAkDABUACAhMJi0CAAkDAA8ACAgcJhgEAPACAAAA.',['猎影']='猎影之风:BAAAKgAFFAQIBAAAAA==.',['猫咪']='猫咪没断:BAAAKgADCgEIAgAAAA==.',['猫小']='猫小小的跟班:BAAAKgAECggICAAAAA==.',['猫肉']='猫肉丸:BAABKgAFFH8GAAIZAAYIUAvZCABMAQAZAAYIUAvZCABMAQAAAA==.',['王伈']='王伈:BAAAKgAECggICAAAAA==.',['玙卿']='玙卿的恶魔:BAAAKgADCgEIAQAAAA==.',['玛戈']='玛戈之泪:BAABKgAFFH8GAAIYAAYIUgZrDgDkAAAYAAYIUgZrDgDkAAAAAA==.玛戈火热:BAABKgAFFH8MAAMPAAYINRHPEwDoAAAPAAQIPRbPEwDoAAAVAAQIrAfvIgChAAAAAA==.玛戈雅利:BAACKgAFFH8OAAQHAAYIxxvRGAA9AQAHAAQIix3RGAA9AQAJAAMIyxKIFwCOAAAIAAIINQ8pFgB3AAAqAAQKfx8ABAgACAiQGrwcAAkBAAcACAgBGEM+ABIBAAgABgjEELwcAAkBAAkAAghoGIFVAJcAAAAA.',['玥玲']='玥玲珑乀:BAAAKgAECgMIAwAAAA==.',['珍妮']='珍妮玛仕哆:BAAAKgAFFAgIBAAAAA==.',['璀璨']='璀璨梦境没断:BAAAKgADCgEIAQAAAA==.',['甜甜']='甜甜姐:BAAAKgADCggIEAAAAA==.',['田心']='田心:BAACKgAFFH8WAAMYAAQInQ/QKgCYAAAYAAQIJA/QKgCYAAAbAAEIGQ9BFgA3AAAqAAQKfxkAAxgACAjkGQkfAMwBABgACAjzFwkfAMwBABsABwhMEBE7AAIBAAAA.',['白色']='白色幽灵丶:BAAAKgADCgUIBQAAAA==.',['白鹤']='白鹤亮翅:BAAAKgAECgEIAQAAAA==.',['百丶']='百丶事:BAABKgAFFH8eAAIQAAYImw7LFAD7AAAQAAYImw7LFAD7AAAAAA==.',['百合']='百合丛中过:BAAAKgADCgEIAQAAAA==.',['百夜']='百夜擦:BAAAKgAECggIDwAAAA==.',['百里']='百里东东君:BAAAKgADCggICAAAAA==.',['皮蛋']='皮蛋配豆腐:BAAAKgAECgMIAwAAAA==.',['目白']='目白麦昆:BAAAKgADCgYIBgAAAA==.',['看我']='看我眼色行动:BAAAKgADCgEIAQAAAA==.',['看眯']='看眯咪:BAACKgAFFH81AAMDAAgISh6NBQDgAQADAAYIeCKNBQDgAQAYAAgImRz0BQDUAQAqAAQKfy8AAhgACAiHI1YCAMMCABgACAiHI1YCAMMCAAAA.',['真龙']='真龙氵傲天:BAABKgAECn8YAAIkAAgIEA0VCgAnAQAkAAgIEA0VCgAnAQAAAA==.',['眼神']='眼神很犀利:BAAAKgAECggIEAAAAA==.',['瞄准']='瞄准开炮:BAAAKgAFFAEIAQAAAA==.',['矢泽']='矢泽妮可:BAAAKgADCggICAAAAA==.',['知否']='知否知否:BAABKgAFFH8HAAMKAAcI7BLTFgDsAAAKAAQIeQbTFgDsAAAkAAMI4hIOBAC4AAAAAA==.',['破车']='破车石佛:BAAAKgAFFAgIAQAAAA==.',['神圣']='神圣的蛋蛋:BAAAKgAECggIEAAAAA==.',['离子']='离子汽水:BAAAKgAECgQIBQAAAA==.',['秋水']='秋水白:BAABKgAFFH8OAAITAAQI4R6QDwAGAQATAAQI4R6QDwAGAQAAAA==.',['秋珏']='秋珏枫:BAAAKgAECgYIBgAAAA==.',['符水']='符水灵:BAAAKgAECgcIDAAAAA==.',['笨死']='笨死了:BAAAKgAFFAQIBAAAAA==.',['笨笨']='笨笨加油咯:BAAAKgAFFAQIBAAAAA==.',['简小']='简小兰:BAAAKgAFFAQIBAAAAA==.',['箭火']='箭火之殇:BAABKgAFFH8NAAINAAgIOQ9kCQDdAQANAAgIOQ9kCQDdAQAAAA==.',['粑粑']='粑粑作陷阱:BAAAKgAECggICAAAAA==.',['粪海']='粪海灬狂蛆:BAABKgAFFH8MAAIlAAgI2xU8BQAsAgAlAAgI2xU8BQAsAgAAAA==.',['糊你']='糊你一熊脸:BAABKgAFFH8IAAIeAAgI2QmsCwDKAQAeAAgI2QmsCwDKAQAAAA==.',['糖芋']='糖芋头:BAAAKgAFFAIIAgAAAA==.',['素顏']='素顏小主:BAAAKgAECgIIAgAAAA==.',['紫气']='紫气九:BAAAKgADCgEIAQAAAA==.',['紫色']='紫色装绑五:BAAAKgADCgEIAQAAAA==.紫色装绑四:BAAAKgADCgEIAQAAAA==.',['纯纯']='纯纯的:BAAAKgAFFAEIAQAAAA==.',['纵横']='纵横杀戮:BAAAKgAFFAQIBAAAAA==.',['终不']='终不似少年游:BAABKgAFFH8IAAIKAAgIAAmzBwB/AQAKAAgIAAmzBwB/AQAAAA==.',['绫濑']='绫濑桃:BAAAKgAECgEIAQAAAA==.',['罗罗']='罗罗亚呢:BAAAKgAFFAMIAwAAAA==.',['羌族']='羌族灬小萨:BAAAKgAFFAQIBAAAAA==.',['美死']='美死了:BAAAKgAFFAgIAQABKgAFFAgIDAAEALcWAA==.',['美美']='美美哒:BAAAKgADCgUIBQAAAA==.',['羞羞']='羞羞灬铁拳:BAAAKgAFFAQIBAAAAA==.',['老拾']='老拾柒:BAAAKgAECgYIBgAAAA==.',['老衲']='老衲周出光:BAAAKgADCgUIBQAAAA==.老衲要电嘿:BAAAKgAECgcIEQAAAA==.',['老靓']='老靓仔:BAAAKgAECgMIAwAAAA==.',['耗子']='耗子欺负喵:BAAAKgAFFAgIAQAAAA==.',['肚皮']='肚皮饿饿:BAAAKgAFFAQIBAABKgAFFAgIOwAbAMsiAA==.',['胧月']='胧月:BAAAKgADCgIIAgAAAA==.',['脑瓜']='脑瓜子疼:BAAAKgAFFAQIAgAAAA==.',['艾瑞']='艾瑞薇娅:BAABKgAFFH8GAAIXAAYI3RCgEwBFAQAXAAYI3RCgEwBFAQAAAA==.',['艾菲']='艾菲尔丶织影:BAABKgAECn8gAAIJAAgIVh5JDQArAgAJAAgIVh5JDQArAgAAAA==.',['芒果']='芒果干:BAAAKgAECgEIAQAAAA==.',['花海']='花海:BAAAKgAECgcICwAAAA==.',['苍生']='苍生何辜:BAAAKgADCgEIAQAAAA==.',['若能']='若能不相见:BAAAKgAFFAQIBAAAAA==.',['茜苽']='茜苽僦媞圜嘚:BAAAKgADCggICAAAAA==.',['莓子']='莓子酱:BAABKgAFFH8QAAIKAAgIlA/sBQC8AQAKAAgIlA/sBQC8AQAAAA==.',['莫斯']='莫斯缇玛:BAAAKgAECgMIAwAAAA==.',['莫道']='莫道红尘苦:BAAAKgAECggICAAAAA==.',['菊花']='菊花一线天:BAAAKgADCggICAAAAA==.',['萨满']='萨满之牧之:BAAAKgAECgcIBwAAAA==.萨满壮壮:BAAAKgAFFAYIBAAAAA==.',['落幽']='落幽燕:BAAAKgAECgYIBgABKgAFFAgIDgATAOEeAA==.',['落羽']='落羽成霜:BAABKgAFFH8IAAQHAAQI2B7OCgAKAQAHAAQI2B7OCgAKAQAIAAMIHhBLEgCUAAAJAAEIPBb1FABTAAAAAA==.',['葱花']='葱花一朵朵:BAAAKgAECgIIAgAAAA==.',['蓓小']='蓓小猪:BAAAKgADCgEIAQAAAA==.',['蓝雨']='蓝雨欣:BAAAKgADCgcIBwAAAA==.',['薛坤']='薛坤:BAAAKgAECggIDwAAAA==.',['蜘蛛']='蜘蛛侠:BAAAKgAECgEIAQAAAA==.',['蜜铃']='蜜铃兰丨梅蒂:BAACKgAFFH8pAAMdAAgI3yQNAwAiAgAdAAgI3yQNAwAiAgAeAAMI7BDwJQCMAAAqAAQKfz4AAx0ACAhTJeQCANYCAB0ACAhTJeQCANYCAB4ACAizHPEJAFgCAAAA.',['裂石']='裂石潜踪:BAAAKgAECggICAAAAA==.',['西木']='西木野真姬:BAAAKgAECggIEAAAAA==.',['西部']='西部大镖客:BAAAKgAFFAQIBAAAAA==.',['誓约']='誓约一:BAAAKgADCgUIBQAAAA==.',['語戈']='語戈:BAAAKgAECgIIAgAAAA==.',['诡诈']='诡诈计谋:BAAAKgAFFAYIAgAAAA==.',['语戈']='语戈:BAAAKgAECgIIAgAAAA==.',['贝拉']='贝拉梅斯:BAABKgAFFH8IAAILAAgIKghVBABIAQALAAgIKghVBABIAQAAAA==.',['贯中']='贯中:BAAAKgAFFAYIBAAAAA==.',['贰伍']='贰伍捌壹玖:BAABKgAFFH8GAAIMAAYIrws2AgCUAQAMAAYIrws2AgCUAQAAAA==.',['贰柒']='贰柒:BAAAKgAFFAIIAgABKgAFFAYIHAAVABgmAA==.',['赵悳']='赵悳男人丶:BAAAKgAFFAIIAgAAAA==.',['赶海']='赶海的咕凉:BAAAKgAECggIDAAAAA==.',['超级']='超级奶霸:BAAAKgAECgUIBQAAAA==.',['踏光']='踏光:BAAAKgAFFAgIAgAAAA==.',['轻舞']='轻舞丸子:BAAAKgAECgYIDgAAAA==.',['输出']='输出及格线:BAAAKgADCgQIBAAAAA==.',['迷你']='迷你土豆:BAAAKgAECggICgAAAA==.',['追忆']='追忆赤信号:BAABKgAFFH8QAAMNAAUILh+aEgBiAQANAAUILh+aEgBiAQAXAAEIVwfvUwAxAAAAAA==.',['逍遥']='逍遥仙:BAAAKgAECgEIAQAAAA==.',['速度']='速度灭散会:BAAAKgAFFAEIAQAAAA==.',['邓呆']='邓呆呆:BAAAKgAECgMIAwAAAA==.',['那眼']='那眼温柔:BAABKgAFFH8IAAIHAAgIJgbXDAB4AQAHAAgIJgbXDAB4AQAAAA==.',['邪眸']='邪眸奥特曼:BAABKgAFFH8MAAIaAAgIkBQuGAA6AQAaAAgIkBQuGAA6AQAAAA==.',['酒仙']='酒仙儿:BAAAKgADCggIEAAAAA==.',['酒吞']='酒吞童子:BAAAKgADCgEIAQAAAA==.',['钏婶']='钏婶婶:BAAAKgADCggICQAAAA==.',['钢铁']='钢铁侠:BAAAKgAECggIDwAAAA==.',['银剑']='银剑:BAABKgAECn8wAAIEAAgIlRQ9bgC8AQAEAAgIlRQ9bgC8AQAAAA==.',['银白']='银白哨兵:BAABKgAFFH8IAAIEAAQI0hidRADlAAAEAAQI0hidRADlAAAAAA==.',['银色']='银色柠语:BAABKgAFFH8GAAINAAYInBtcDgCOAQANAAYInBtcDgCOAQAAAA==.',['锦鲤']='锦鲤附体:BAAAKgAECggICgAAAA==.',['门先']='门先生:BAAAKgAECggICwABKgAFFAgIBAAfAAAAAA==.',['闪光']='闪光的嘉特琳:BAAAKgADCggIAQAAAA==.',['阿宝']='阿宝妹:BAAAKgAECgQIBAAAAA==.',['阿怪']='阿怪:BAABKgAFFH8JAAIlAAMIUhV5HQDeAAAlAAMIUhV5HQDeAAAAAA==.',['阿沙']='阿沙:BAACKgAFFH80AAMmAAYInA7eBgAMAQAmAAYInA7eBgAMAQARAAIInwMZKwBwAAAqAAQKfxYAAiYACAhlFysQAJIBACYACAhlFysQAJIBAAAA.',['限量']='限量版麒麒:BAACKgAFFH8KAAIEAAMIyhoqPgD3AAAEAAMIyhoqPgD3AAAqAAQKfxUAAwUACAi4FqwiAEABAAUABwgdE6wiAEABAAQAAwhHH5GhAAsBAAAA.',['随机']='随机漫步:BAAAKgAECgEIAQAAAA==.',['随风']='随风而去:BAAAKgAFFAUIBAABKgAFFAgIEQAHABIfAA==.',['雅尔']='雅尔托利亚:BAABKgAFFH8FAAIEAAQIUyG2OQAFAQAEAAQIUyG2OQAFAQABKgAFFAgICAANAHMNAA==.',['雍月']='雍月:BAAAKgAECgUIBQAAAA==.',['雨夜']='雨夜蓝梦:BAAAKgAFFAQIBAAAAA==.',['雨幕']='雨幕夕阳夏:BAAAKgADCggICAAAAA==.',['雪乃']='雪乃一生推:BAABKgAFFH8SAAMXAAUI0xqODgARAQAXAAUI0xqODgARAQANAAEITg/1WwA/AAAAAA==.',['雪白']='雪白大龙:BAAAKgAFFAQIBAAAAA==.',['雲大']='雲大王:BAAAKgAECgMIBAAAAA==.',['零帧']='零帧起手:BAAAKgAECgMIAwAAAA==.',['霜印']='霜印:BAACKgAFFH8kAAIOAAgI2Bc4BACoAQAOAAgI2Bc4BACoAQAqAAQKfyYAAg4ACAjTINQQAHkCAA4ACAjTINQQAHkCAAAA.',['青丘']='青丘白凤九:BAAAKgAFFAcIAgAAAA==.',['靓晓']='靓晓蔚:BAABKgAFFH8GAAIVAAYIDxDjEQAyAQAVAAYIDxDjEQAyAQAAAA==.',['須佐']='須佐能乎:BAAAKgAFFAQIBAAAAA==.',['领土']='领土:BAAAKgADCgQIBAAAAA==.',['颜妃']='颜妃:BAAAKgAECggIDgAAAA==.',['風丨']='風丨舞:BAABKgAECn8cAAIEAAgI8CX2BwD8AgAEAAgI8CX2BwD8AgAAAA==.',['風烛']='風烛小树:BAABKgAFFH8SAAMeAAgIqxEzCAAhAgAeAAgIqxEzCAAhAgAdAAYIBBEyDQA5AQAAAA==.',['风怒']='风怒没断:BAAAKgADCgEIAQAAAA==.',['风流']='风流东去:BAABKgAFFH8JAAIbAAMITwKrJwB5AAAbAAMITwKrJwB5AAAAAA==.',['风萨']='风萨:BAAAKgAECgMIBQAAAA==.',['风行']='风行者没断:BAAAKgADCgEIAQAAAA==.',['风轩']='风轩大盗:BAABKgAFFH8GAAMhAAUISiPYFQD6AAAhAAQIMyXYFQD6AAAgAAEIjh3ADgBqAAAAAA==.',['风逝']='风逝无痕:BAAAKgAECgQIBAAAAA==.',['飛鳥']='飛鳥和游魚:BAAAKgAECgYIBgABKgAFFAgIEAARAOMNAA==.',['飞天']='飞天小萝卜:BAABKgAFFH8GAAIIAAYI7A5yBABDAQAIAAYI7A5yBABDAQAAAA==.',['飞翔']='飞翔的肥羊:BAABKgAFFH8FAAMXAAUIGBBCNAChAAAXAAQIsAtCNAChAAANAAEIUh3tVgBQAAAAAA==.',['饭泡']='饭泡粥:BAAAKgAFFAQIBAAAAA==.',['饵丝']='饵丝:BAAAKgAECgYIBgAAAA==.',['香蕉']='香蕉棒棒糖:BAAAKgAECgUICQAAAA==.',['魔兽']='魔兽肥龙:BAAAKgAECgcICwAAAA==.',['魔魚']='魔魚祈:BAABKgAFFH8KAAMFAAYIFh0QCQDQAAAEAAQIbRhvIADoAAAFAAYIXBYQCQDQAAAAAA==.',['鲨氵']='鲨氵钦:BAABKgAECn8dAAITAAgITxENSwBOAQATAAgITxENSwBOAQAAAA==.',['鸭梨']='鸭梨树下:BAAAKgAECgIIAgAAAA==.',['麦那']='麦那斯吟唱者:BAAAKgAECgYICAAAAA==.',['黑手']='黑手大酋长:BAAAKgAECgMIAwAAAA==.',['黑皇']='黑皇哈特:BAABKgAFFH8OAAIEAAYIZxd/EQAPAQAEAAYIZxd/EQAPAQAAAA==.',['黑蛋']='黑蛋卫士:BAAAKgADCggICAAAAA==.',['黑鍋']='黑鍋丨我来背:BAACKgAFFH8RAAIYAAQI2ROVFgCNAAAYAAQI2ROVFgCNAAAqAAQKfyUAAhgACAjjEkYyAFgBABgACAjjEkYyAFgBAAAA.',['黑鬃']='黑鬃:BAAAKgAECgMIAwAAAA==.',['龙之']='龙之召唤:BAABKgAECn8UAAMCAAgIggxEDQAcAQACAAgIggxEDQAcAQABAAIIFQIdZAAYAAAAAA==.',['龙惑']='龙惑契约:BAAAKgADCggIDwAAAA==.',['龙王']='龙王丸:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end