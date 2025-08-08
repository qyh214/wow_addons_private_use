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
 local lookup = {'Shaman-Restoration','Paladin-Retribution','Paladin-Protection','DeathKnight-Unholy','Rogue-Assassination','Druid-Balance','Warrior-Fury','Warrior-Arms','Rogue-Outlaw','Mage-Fire','Mage-Arcane','Monk-Windwalker','Druid-Restoration','DemonHunter-Vengeance','Warlock-Destruction','Mage-Frost','Hunter-BeastMastery','Warlock-Affliction','Warlock-Demonology','Shaman-Elemental','Shaman-Enhancement','Hunter-Marksmanship','Druid-Guardian','Warrior-Protection','Paladin-Holy','Monk-Mistweaver','Priest-Discipline','Priest-Shadow','Priest-Holy','DemonHunter-Havoc','DeathKnight-Blood','Unknown-Unknown','Evoker-Preservation','Evoker-Devastation','DeathKnight-Frost','Monk-Brewmaster',}; local provider = {region='CN',realm='卡德罗斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Af='Af:BAAAKgAECgEIAQAAAA==.',Al='Alencia:BAAAKgAFFAgIBAAAAA==.',Ap='Apollo:BAAAKgADCgEIAQAAAA==.',Ar='Ariana:BAABKgAFFH8NAAIBAAQIORcMGAC1AAABAAQIORcMGAC1AAAAAA==.Aries:BAAAKgAECgUIBQAAAA==.Armist:BAAAKgADCggIEAAAAA==.',Au='Automata:BAAAKgAFFAEIAQAAAA==.',Bo='Boxter:BAACKgAFFH8ZAAMCAAYIfCQzDQD8AQACAAYIfCQzDQD8AQADAAIIQgs2EACEAAAqAAQKfxwAAgIABwiyJcIvAGECAAIABwiyJcIvAGECAAAA.',Ca='Cavali:BAAAKgAECggICAAAAA==.',Co='Coolukyo:BAAAKgAECgcICQAAAA==.',Dr='Drew:BAAAKgADCgcIBwAAAA==.',Ei='Eileen:BAABKgAFFH8RAAMCAAYIfiXZDgDsAQACAAYIfiXZDgDsAQADAAQIOAySDgCSAAABKgAFFAgIEgAEAIMXAA==.',En='Envy:BAAAKgAECgQICwAAAA==.',Eu='Eustoma:BAAAKgAECgEIAQAAAA==.',Fg='Fgdfdhhjdtj:BAAAKgADCgEIAQAAAA==.',Fi='Fizzbelle:BAAAKgAECgQIBAAAAA==.',Ft='Fto:BAAAKgAFFAIIAgAAAA==.Ftot:BAAAKgAECggIDQAAAA==.',Gi='Gigantas:BAAAKgAECgMIAwAAAA==.',Gl='Glitter:BAAAKgADCgYIBgAAAA==.',Gy='Gyshen:BAAAKgADCggICAAAAA==.',Ho='Hope:BAAAKgAECgEIAQAAAA==.',Jo='Joker:BAAAKgAECgUIBwAAAA==.',Ka='Kallen:BAAAKgAECgIIAgAAAA==.',Ku='Kuizy:BAABKgAFFH8GAAIFAAQIeh+LBwAJAQAFAAQIeh+LBwAJAQAAAA==.',La='Lancer:BAAAKgAECgYIBgAAAA==.',Ma='Macan:BAAAKgADCggICAAAAA==.Macana:BAAAKgADCgEIAgAAAA==.',Me='Mevius:BAABKgAFFH8IAAMCAAYIVxfRAgCxAQACAAYIeRPRAgCxAQADAAIIoxMmIgBxAAAAAA==.',Mi='Miku:BAABKgAFFH8GAAIGAAYI8AsGIQAaAQAGAAYI8AsGIQAaAQAAAA==.Miyo:BAAAKgAFFAEIAQAAAA==.',Nt='Ntr:BAACKgAFFH8UAAMHAAYIAR75BwDdAQAHAAYIAR75BwDdAQAIAAQIdRoWDABNAQAqAAQKfyYAAwcACAjbGqAtANABAAcACAjbGqAtANABAAgABAh7B9lIAKoAAAEqAAUUCAgIAAkAQhwA.',Pl='Playerebhvnk:BAAAKgADCggICAAAAA==.',Pr='Prime:BAAAKgAFFAIIAgAAAA==.Priss:BAACKgAFFH8MAAMKAAUIRB0aCACCAQAKAAQIThsaCACCAQALAAMIniEqIgDcAAAqAAQKfyUAAwoACAjxJLsEAO4CAAoACAjxJLsEAO4CAAsABQiTIsw6AFsBAAEqAAUUCAgPAAoAgSEA.',Sn='Snake:BAAAKgADCgQIBAAAAA==.',Te='Tea:BAABKgAFFH8HAAIMAAMIsRefEQDVAAAMAAMIsRefEQDVAAAAAA==.',Th='Thyrian:BAAAKgAECgIIAgAAAA==.',Ti='Timlibin:BAABKgAFFH8GAAMNAAQIYA8MDQDHAAANAAQIYA8MDQDHAAAGAAIIFhocJQCfAAABKgAFFAgIKQAGAGQbAA==.',To='Touchmebaby:BAAAKgAFFAgIAgAAAA==.',Tr='Treasure:BAAAKgAECggICAAAAA==.',Uz='Uzi:BAABKgAFFH8NAAICAAYIqhlxDwCqAQACAAYIqhlxDwCqAQAAAA==.',Vr='Vrutne:BAAAKgAECgQIBQAAAA==.',Vy='Vylanic:BAABKgAECn8dAAIOAAgIYBAwLQAfAQAOAAgIYBAwLQAfAQABKgAFFAMIBgAPAEEVAA==.',Wo='Wowmen:BAAAKgAECgUIBQAAAA==.',Ya='Yangccshm:BAAAKgADCgYIBgAAAA==.',Yb='Ybkq:BAABKgAFFH8IAAIQAAQIfx9GBwD0AAAQAAQIfx9GBwD0AAABKgAFFAgICQALAJobAA==.',Ze='Zeus:BAAAKgAECgQIBAAAAA==.',Zo='Zodiac:BAAAKgAECgIIAwAAAA==.',['一只']='一只狗古德佰:BAAAKgAFFAQIBAAAAA==.',['一碗']='一碗毒鸡汤:BAAAKgAFFAQIBAAAAA==.',['一莺']='一莺一:BAABKgAECn8UAAICAAgIWhtwawDCAQACAAgIWhtwawDCAQAAAA==.',['一薇']='一薇一:BAAAKgAECgYIBgAAAA==.',['万兽']='万兽之缰:BAAAKgAECgYIBAAAAA==.',['不玩']='不玩歪歪:BAAAKgAECgUIBQAAAA==.不玩贴吧:BAABKgAECn8UAAIRAAgIIhsXLABDAgARAAgIIhsXLABDAgAAAA==.',['严禁']='严禁占用盲道:BAAAKgAECgcIBwAAAA==.',['丶不']='丶不会:BAAAKgAFFAQIBAABKgAFFAYIBgADAIodAA==.丶不炫燿:BAAAKgAFFAEIAQAAAA==.丶不炫耀:BAABKgAFFH8GAAIDAAQIih3BEwDcAAADAAQIih3BEwDcAAAAAA==.',['丶瞳']='丶瞳瞳:BAAAKgAECgcICQAAAA==.',['丶蛋']='丶蛋卷:BAAAKgAECggICgAAAA==.丶蛋清:BAAAKgAECgcIBwAAAA==.',['丿初']='丿初丶一:BAACKgAFFH8SAAQSAAYI4h2IBQAsAQAPAAYIWBIQFgBTAQASAAUIyh2IBQAsAQATAAEIRR7BJABQAAAqAAQKfycABA8ACAj5Hm0XADcCAA8ABwgKIm0XADcCABIAAwhDH9UdAAEBABMAAwgpCw14AD0AAAAA.',['丿灬']='丿灬滿滿:BAABKgAECn8aAAMUAAgIBCN8CQChAgAUAAgIBCN8CQChAgABAAEIDw9buQAxAAAAAA==.',['丿神']='丿神之灬守护:BAAAKgAECgcICAAAAA==.',['么么']='么么小神牛:BAABKgAFFH8KAAICAAYI1hp1HACCAQACAAYI1hp1HACCAQAAAA==.么么小神骑:BAAAKgAFFAQIBAAAAA==.',['乌干']='乌干达:BAABKgAFFH8NAAQUAAcIng2mCwATAQAUAAYIbgWmCwATAQAVAAMIxQ6KFgCYAAABAAEI7QG3KAA+AAAAAA==.',['乌槑']='乌槑乌:BAACKgAFFH8GAAMPAAMIQRVqPQB4AAAPAAIIORJqPQB4AAASAAEITxuNHwBMAAAqAAQKfxcABA8ACAicHH4uALkBAA8ACAigGn4uALkBABMAAgiPHdFwAFYAABIAAQhIC7JLACUAAAAA.',['乌青']='乌青筠:BAABKgAFFH8IAAICAAMIEBTsVADHAAACAAMIEBTsVADHAAAAAA==.',['九幺']='九幺幺:BAAAKgADCgQIBAAAAA==.',['二甲']='二甲双胍:BAAAKgAECgEIAQAAAA==.',['五块']='五块钱的悲催:BAABKgAECn8VAAIEAAgI9hsFIABCAgAEAAgI9hsFIABCAgAAAA==.',['五朵']='五朵:BAAAKgAECgMIAwAAAA==.',['仁剑']='仁剑仁爱:BAABKgAECn8VAAMCAAgI3CJCEwC9AgACAAgI3CJCEwC9AgADAAgIHQt6LAD2AAAAAA==.',['仁箭']='仁箭仁爱:BAACKgAFFH8TAAIRAAMIxxupJAD1AAARAAMIxxupJAD1AAAqAAQKf0AAAxEACAgfIjQRAJ0CABEACAgfIjQRAJ0CABYAAwjqBpB0AGgAAAAA.',['以德']='以德服仁:BAABKgAFFH8QAAQGAAMIYAZ+JACWAAAGAAMIYAZ+JACWAAANAAEIBgE7PQAWAAAXAAEIPAD0EQAHAAAAAA==.',['仨达']='仨达:BAAAKgADCgIIAgAAAA==.',['伊利']='伊利单妮妹:BAAAKgAECgcIBwAAAA==.',['传说']='传说中的兽兽:BAAAKgAECgEIAQAAAA==.',['使命']='使命丶必达:BAAAKgADCgIIAgAAAA==.',['依然']='依然拒绝你:BAAAKgAFFAYIAgAAAA==.',['倾城']='倾城一剑:BAACKgAFFH8GAAMYAAMIaxlcBwCZAAAHAAMISxU3HwDXAAAYAAIIsRlcBwCZAAAqAAQKfy4ABAcACAgdJOgIAK4CAAcACAg0I+gIAK4CAAgABAhGG6svAEABABgABgh/GI8hACABAAAA.',['假酒']='假酒:BAAAKgAFFAYIBAAAAA==.',['光之']='光之国美少女:BAABKgAFFH8UAAMCAAYI7CGFDgDwAQACAAYI7CGFDgDwAQAZAAYIbSN4AwDZAQAAAA==.',['光殇']='光殇:BAAAKgAFFAQIBAAAAA==.',['光铸']='光铸晨曦:BAAAKgAECgUICgAAAA==.',['克里']='克里尼利基:BAAAKgADCgIIAgAAAA==.',['关二']='关二郎:BAAAKgADCgEIAQAAAA==.',['冷月']='冷月无极:BAAAKgAECgYIBgAAAA==.',['凤独']='凤独影:BAAAKgAECgUIBQAAAA==.',['十两']='十两欢:BAABKgAFFH8IAAIaAAQIfh+wDABaAQAaAAQIfh+wDABaAQAAAA==.',['十月']='十月的颖:BAAAKgAECgYIBgAAAA==.',['单调']='单调木头人:BAABKgAFFH8IAAQbAAYIrxv0BgC8AQAbAAQI+yX0BgC8AQAcAAIIXRUNIACLAAAdAAIIFgeGHgBnAAAAAA==.',['南巴']='南巴妹:BAAAKgADCgEIAQAAAA==.',['占有']='占有欲:BAAAKgAFFAgIBAAAAA==.',['原神']='原神:BAAAKgAECgQIBAAAAA==.',['厶亡']='厶亡靇烒:BAAAKgAECgIIAwAAAA==.',['反差']='反差感:BAABKgAFFH8GAAIGAAYIaAiFJgD8AAAGAAYIaAiFJgD8AAAAAA==.',['古德']='古德千:BAAAKgAFFAYIBAABKgAFFAgICAAQAA4PAA==.古德坑狗:BAABKgAFFH8GAAIBAAYIegaFLwC5AAABAAYIegaFLwC5AAABKgAFFAgIDwAVAC4bAA==.',['叫夜']='叫夜夜:BAABKgAFFH8GAAIWAAYIHBEHFgA0AQAWAAYIHBEHFgA0AQAAAA==.',['叫我']='叫我七仔:BAAAKgAECgEIAQAAAA==.',['叮叮']='叮叮帕拉叮:BAAAKgAECgIIAgAAAA==.',['可乐']='可乐加冰红茶:BAAAKgAECgYIDgAAAA==.',['可可']='可可浆:BAAAKgADCggIDQAAAA==.',['叶心']='叶心薇:BAAAKgAECggIDwAAAA==.',['叶风']='叶风信子:BAAAKgADCggICAAAAA==.',['吃鱼']='吃鱼的果果:BAAAKgAECgUIBQAAAA==.',['吉爾']='吉爾伽美什:BAAAKgAFFAMIAwAAAA==.',['呐么']='呐么嘻哈一匝:BAAAKgAECgcIBwAAAA==.',['呾呾']='呾呾:BAAAKgAECggIDgAAAA==.',['咆哮']='咆哮游侠:BAAAKgAFFAQIBAAAAA==.咆哮阿狸:BAABKgAFFH8IAAIBAAgIPwSQCgBYAQABAAgIPwSQCgBYAQAAAA==.',['咪哥']='咪哥骨排酱:BAAAKgAECgUIBQAAAA==.',['唐氏']='唐氏脆皮鸡:BAABKgAFFH8RAAIGAAYIsSIdAQDrAQAGAAYIsSIdAQDrAQABKgAFFAgIHgAGAE0jAA==.',['啤啤']='啤啤龙:BAABKgAECn8VAAINAAgIzAvPNgAQAQANAAgIzAvPNgAQAQAAAA==.',['因为']='因为我善啊:BAABKgAFFH8GAAIGAAYIhhmQEgCIAQAGAAYIhhmQEgCIAQAAAA==.',['圆环']='圆环之理法则:BAACKgAFFH8iAAMWAAgI2hSnEgBOAQAWAAgI3RGnEgBOAQARAAUIuxIwGwDnAAAqAAQKfykAAxEACAheISYhAHECABEACAilICYhAHECABYACAimHgxAAFIBAAAA.',['圣翼']='圣翼风舞:BAAAKgAECgMIAwAAAA==.',['圭臬']='圭臬:BAABKgAFFH8GAAILAAYIKxO5EQBaAQALAAYIKxO5EQBaAQAAAA==.',['埃尔']='埃尔之光:BAAAKgAECgIIAgAAAA==.',['塞亚']='塞亚特之星:BAAAKgAECgMIAwAAAA==.',['境界']='境界之空:BAACKgAFFH8qAAIeAAcI8yEcCQAAAgAeAAcI8yEcCQAAAgAqAAQKfyQAAh4ACAiZI4oLAMcCAB4ACAiZI4oLAMcCAAAA.',['墨香']='墨香:BAAAKgADCgEIAQAAAA==.',['壹天']='壹天世界:BAABKgAFFH8NAAMEAAUIxhvWBABiAQAEAAUIfhrWBABiAQAfAAQIzRPOHwCmAAABKgAFFAgIGQAKANQZAA==.',['夏灬']='夏灬天丶:BAAAKgAFFAIIAgAAAA==.',['夜夜']='夜夜殇:BAABKgAFFH8HAAIHAAMIUA33JAC8AAAHAAMIUA33JAC8AAAAAA==.',['夜月']='夜月飞:BAAAKgADCgYIBgAAAA==.',['大地']='大地咕:BAAAKgAECggICAAAAA==.大地母亲:BAABKgAFFH8GAAIGAAYIIxzgEQCPAQAGAAYIIxzgEQCPAQAAAA==.',['大场']='大场车神:BAAAKgAFFAgIBAAAAA==.大场雀圣:BAABKgAFFH8IAAIMAAgI6Qv7BQDCAQAMAAgI6Qv7BQDCAQAAAA==.',['大脚']='大脚丫子:BAAAKgAECgEIAQAAAA==.',['大道']='大道如青天:BAACKgAFFH8JAAIeAAMIqBWJLwC/AAAeAAMIqBWJLwC/AAAqAAQKfx0AAh4ACAiyGaMnABoCAB4ACAiyGaMnABoCAAAA.',['大鹫']='大鹫:BAABKgAFFH8GAAIBAAYItQpZAgB1AQABAAYItQpZAgB1AQAAAA==.',['天台']='天台见:BAAAKgADCgcIBwABKgAFFAIIBAAgAAAAAA==.',['天天']='天天吃火锅:BAAAKgADCgMIAwAAAA==.',['天神']='天神打击:BAAAKgADCgIIAgAAAA==.天神的呐喊:BAAAKgAECgYIBgAAAA==.',['天罚']='天罚之雷:BAAAKgAECgMIAwAAAA==.',['太阴']='太阴:BAAAKgADCgMIAwAAAA==.',['头孢']='头孢就酒:BAABKgAFFH8GAAIEAAYIEA3QFwBfAQAEAAYIEA3QFwBfAQAAAA==.',['奎桑']='奎桑提:BAABKgAFFH8MAAMfAAYIXRGdEAAfAQAEAAYIBQvqGwA+AQAfAAYI2xCdEAAfAQAAAA==.',['奎状']='奎状闪电:BAABKgAFFH8IAAIBAAgIIQeGCQCtAQABAAgIIQeGCQCtAQAAAA==.',['奎贼']='奎贼:BAAAKgAFFAgIBAAAAA==.',['套里']='套里都是水:BAAAKgADCgEIAQAAAA==.',['奥扎']='奥扎格蕾:BAABKgAFFH8PAAMRAAYImBmwFAD7AAARAAQIaiKwFAD7AAAWAAIIXgysPACFAAAAAA==.',['女人']='女人狼精:BAAAKgAECgMIBAAAAA==.',['奶油']='奶油丶煎饼:BAAAKgAECgYICwAAAA==.',['如影']='如影随行:BAAAKgAECgEIAQAAAA==.',['如梦']='如梦似水流年:BAABKgAECn8ZAAICAAgIUSDSJABtAgACAAgIUSDSJABtAgAAAA==.',['妲己']='妲己再世:BAAAKgAECgYIBgAAAA==.',['姜蒋']='姜蒋犟犟:BAAAKgAFFAUIBAAAAA==.',['姬迦']='姬迦娜:BAAAKgAFFAQIBAAAAA==.',['婀娜']='婀娜多姿丶:BAABKgAFFH8KAAIaAAQIQSWACgARAQAaAAQIQSWACgARAQAAAA==.',['孑孑']='孑孑:BAAAKgADCggIFQAAAA==.',['孑然']='孑然妒火:BAAAKgAECgQIBQAAAA==.',['宁静']='宁静灬林夕:BAAAKgAECgcIBwAAAA==.',['寂寞']='寂寞星球玫瑰:BAAAKgAFFAQIBAAAAA==.',['寒语']='寒语邪心:BAAAKgAFFAEIAQAAAA==.',['射射']='射射兄弟:BAAAKgAFFAQIBAAAAA==.',['射机']='射机精器:BAAAKgADCggICAAAAA==.',['小吴']='小吴帅哥:BAAAKgADCggICAAAAA==.小吴森森:BAAAKgAECgUIBQAAAA==.小吴老师:BAAAKgAECgEIAQAAAA==.',['小喷']='小喷菇:BAABKgAFFH8IAAIKAAgIjAJMBQCBAQAKAAgIjAJMBQCBAQAAAA==.',['小奎']='小奎蜂采涛蜜:BAABKgAFFH8FAAIWAAUIqAm+FAA9AQAWAAUIqAm+FAA9AQAAAA==.',['小姊']='小姊姊呀:BAAAKgADCggICAAAAA==.',['小小']='小小大懒猫:BAACKgAFFH8gAAMhAAYIzhl4BQDBAAAhAAQIsBZ4BQDBAAAiAAIIWCO/IQC6AAAqAAQKfyoAAyEACAhnGyAJAOoBACEACAhnGyAJAOoBACIABwgcCpk7AOsAAAAA.',['小月']='小月饼:BAABKgAFFH8OAAIKAAgIYxceBQAuAgAKAAgIYxceBQAuAgAAAA==.',['小牙']='小牙骑:BAAAKgAECgEIAQAAAA==.',['小猫']='小猫驴儿:BAAAKgAECgEIAQAAAA==.',['小甜']='小甜饼:BAACKgAFFH8IAAMBAAgI0gWuHwD8AAABAAQICAKuHwD8AAAUAAQI5w4lGQCxAAAqAAQKfxYAAgEACAj6IlQKAJsCAAEACAj6IlQKAJsCAAAA.',['小羊']='小羊儿丶:BAABKgAECn83AAMKAAgILB+7JAAZAgAKAAgILB+7JAAZAgALAAUIwA8vYwC5AAAAAA==.',['小辣']='小辣鸡:BAAAKgAECgYIDAAAAA==.',['尤瑞']='尤瑞艾莉:BAABKgAFFH8UAAMdAAYIDRSBDABbAQAdAAYIDRSBDABbAQAcAAEIYBfnKgBHAAAAAA==.',['尼克']='尼克尼克泥:BAABKgAFFH8GAAIGAAYIOh5/EQCSAQAGAAYIOh5/EQCSAQAAAA==.',['屁儿']='屁儿痛:BAAAKgAECgMIAwAAAA==.',['屠龙']='屠龙者墩墩:BAAAKgAECggICAAAAA==.',['屮渊']='屮渊:BAAAKgADCgcIBwABKgAFFAMIBgAPAEEVAA==.',['左眼']='左眼看到鬼:BAAAKgAFFAIIAgAAAA==.',['巨炮']='巨炮蜀黍:BAABKgAECn8XAAMQAAgI/hbvIACrAQAQAAgI/hbvIACrAQAKAAEIIglKowApAAAAAA==.',['巨蟹']='巨蟹座:BAABKgAFFH8JAAMQAAYIHxxkBgBoAQAQAAYIHxxkBgBoAQAKAAMITAbRNgBjAAABKgAFFAgIEAAKAKcaAA==.',['帅气']='帅气的宝宝:BAAAKgAFFAEIAgAAAA==.',['师妹']='师妹讨厌:BAAAKgAECgYIBwAAAA==.',['希望']='希望赞美诗:BAAAKgAECgYIBgAAAA==.',['幻若']='幻若残缺之影:BAAAKgAECgIIAgAAAA==.幻若流转之风:BAAAKgADCgYIBgAAAA==.',['幼稚']='幼稚园吴老师:BAAAKgAECgcIBwAAAA==.',['库洛']='库洛米:BAAAKgADCgUIBQAAAA==.',['影哲']='影哲:BAAAKgAECgUIBQAAAA==.',['忧郁']='忧郁咕:BAABKgAFFH8HAAMEAAYI1B6mKwDfAAAEAAQI5R6mKwDfAAAfAAMIuh4QHgCyAAAAAA==.',['快乐']='快乐吃手手:BAABKgAFFH8OAAMBAAYIGQ6bFAAzAQABAAYIGQ6bFAAzAQAVAAQImQQ7DADsAAAAAA==.',['念雨']='念雨:BAABKgAFFH8GAAIZAAYIew1CBwBAAQAZAAYIew1CBwBAAQAAAA==.',['急则']='急则疲慌则乱:BAAAKgAECgcIBwAAAA==.',['性感']='性感小蹄子:BAAAKgAECgMIAwAAAA==.',['恶大']='恶大手:BAAAKgAFFAMIAwAAAA==.',['恶魔']='恶魔主宰:BAAAKgAECggICAAAAA==.',['悄悄']='悄悄话:BAAAKgADCgIIAgAAAA==.',['感觉']='感觉良好:BAAAKgAECgIIAgAAAA==.',['懿天']='懿天世界:BAAAKgAFFAEIAQAAAA==.',['我不']='我不胖吧:BAAAKgAFFAUIAwAAAA==.',['我叫']='我叫硬三彩:BAAAKgAFFAgIBAAAAA==.',['我忍']='我忍不了:BAAAKgAECggICAAAAA==.',['我是']='我是阿枪哥:BAAAKgAECgQIBQAAAA==.',['我爱']='我爱吃炸鸡:BAAAKgADCgMIAwABKgAFFAYIEAARAIsiAA==.我爱大飞机:BAABKgAFFH8QAAMRAAQIiyI1EwAAAQARAAQIiyI1EwAAAQAWAAQIth4HIAD2AAAAAA==.',['戒不']='戒不掉的烟:BAAAKgAECggIDQAAAA==.',['战争']='战争灬践踏:BAAAKgAECgQIBQAAAA==.',['战念']='战念:BAACKgAFFH8UAAMHAAgIExT2CQCvAQAHAAcI2Bb2CQCvAQAIAAEIbwNhKgBDAAAqAAQKfzQAAwcACAgEIo0WAFQCAAcACAgEIo0WAFQCAAgABQiIFm49AOYAAAAA.',['戳克']='戳克:BAAAKgAECgMIAwAAAA==.',['执念']='执念:BAABKgAECn8kAAMCAAgIkRcdpwBJAQACAAgIkRcdpwBJAQAZAAUIERVTMgDTAAAAAA==.',['抖乧']='抖乧:BAAAKgAFFAIIAgABKgAFFAMIBgAPAEEVAA==.',['拉人']='拉人丶发糖:BAAAKgAECggIDQAAAA==.',['拔剑']='拔剑四顾:BAAAKgAECgMIAwAAAA==.',['拿锤']='拿锤子搓火球:BAAAKgAECgEIAQAAAA==.',['捣田']='捣田丶半藏:BAAAKgAECggICQAAAA==.',['提里']='提里奥意志:BAAAKgAECgUICgAAAA==.',['搁丶']='搁丶浅:BAAAKgADCggIDAAAAA==.',['搁浅']='搁浅丨:BAAAKgAECgMIAwAAAA==.搁浅丶:BAAAKgAECgUIBwAAAA==.',['搻闼']='搻闼譶:BAAAKgAECgYIBgABKgAFFAMIBgAPAEEVAA==.',['放开']='放开那哥哥:BAABKgAECn8ZAAMGAAgIiBujKwABAgAGAAgIiBujKwABAgANAAcIwxMfEwBAAQAAAA==.',['放飞']='放飞你的心灵:BAAAKgAECgQIBQAAAA==.',['救赎']='救赎与信仰:BAABKgAFFH8IAAQdAAQIPCCECwDaAAAbAAMIrCXPDgDhAAAdAAQIARSECwDaAAAcAAEIfhkJIgBUAAAAAA==.',['旋风']='旋风激光剑:BAABKgAFFH8IAAMHAAYI4w5zEwAnAQAHAAQIpRRzEwAnAQAIAAMIRATuIQCEAAAAAA==.',['无极']='无极丶明珠:BAAAKgAECggICAAAAA==.',['旧时']='旧时旧夢:BAABKgAFFH8IAAIPAAgIRQ9kCgDlAQAPAAgIRQ9kCgDlAQAAAA==.',['时光']='时光:BAAAKgAECgEIAQAAAA==.',['旺达']='旺达:BAABKgAFFH8RAAMQAAYI/hiZAwAcAQALAAYIfAw0FgAyAQAQAAQIPyGZAwAcAQABKgAFFAgIHAAGADYlAA==.',['明眸']='明眸靓眼:BAABKgAECn80AAIeAAgICyBlEQB4AgAeAAgICyBlEQB4AgAAAA==.',['星期']='星期八丶萌萌:BAAAKgAFFAQIAwAAAA==.',['星渊']='星渊源泉:BAAAKgADCggIFAABKgAFFAIIAgAgAAAAAA==.',['晓丶']='晓丶觉:BAAAKgADCgcIBwAAAA==.',['晓觉']='晓觉丶:BAAAKgAECgIIAgAAAA==.',['晨殇']='晨殇:BAABKgAFFH8KAAIHAAYIeh9FCQC+AQAHAAYIeh9FCQC+AQAAAA==.',['暧昧']='暧昧的理由:BAAAKgADCggICAAAAA==.',['暮雾']='暮雾:BAAAKgADCggICAAAAA==.',['曹月']='曹月香:BAABKgAFFH8GAAMKAAQIiQwjKACuAAAKAAQIygUjKACuAAAQAAIIQBIuFwB9AAAAAA==.',['木叶']='木叶甜馨:BAAAKgAECgcICAAAAA==.',['来自']='来自海洋:BAAAKgADCgQIAgAAAA==.',['杺殇']='杺殇:BAAAKgAFFAQIBAAAAA==.',['松赞']='松赞:BAACKgAFFH8aAAIfAAUImwiLHwCoAAAfAAUImwiLHwCoAAAqAAQKfxYAAx8ACAhhCCYvANcAAB8ACAg4CCYvANcAAAQABQgnA1S2AF4AAAAA.',['林夕']='林夕灬宁静:BAAAKgAECgYIBgAAAA==.',['枫言']='枫言疯语:BAAAKgADCggICAAAAA==.',['柠檬']='柠檬味:BAAAKgAECgcIDAAAAA==.柠檬汽水:BAAAKgAECgIIAgAAAA==.',['梦灬']='梦灬幻丶:BAAAKgAFFAQIBAAAAA==.',['梦里']='梦里我会飞:BAAAKgAECggICgAAAA==.',['森林']='森林忽悠着你:BAAAKgAECgUICAAAAA==.',['橘子']='橘子焦糖丶:BAABKgAFFH8GAAIfAAYIZAiNGADcAAAfAAYIZAiNGADcAAAAAA==.',['比例']='比例喷睡:BAABKgAFFH8QAAMBAAYIiBDCBgAjAQABAAUIsg/CBgAjAQAUAAEILwQBGABPAAAAAA==.',['永恒']='永恒地星空:BAABKgAFFH8IAAMjAAQINhGmAwDbAAAjAAQIExCmAwDbAAAfAAMI/wa5MABJAAAAAA==.永恒的恶魔:BAAAKgAFFAgIBAAAAA==.',['汰灬']='汰灬孖妃丶:BAAAKgADCgUIBQAAAA==.',['没脑']='没脑子的曹潇:BAAAKgAECgYIBgAAAA==.',['泰迪']='泰迪小狗熊:BAAAKgADCggICAAAAA==.',['洗脚']='洗脚神兽:BAAAKgAECgUICAAAAA==.',['流纱']='流纱:BAAAKgADCggICQAAAA==.',['海潮']='海潮沫:BAAAKgAFFAIIAgABKgAFFAcIFAAaAEgVAA==.海潮溟:BAACKgAFFH8UAAIaAAUISBXtGQDOAAAaAAUISBXtGQDOAAAqAAQKfxcAAxoACAilFVMoAE8BABoACAilFVMoAE8BAAwABAh6D+hWAKAAAAAA.',['海韵']='海韵:BAABKgAFFH8VAAMGAAYItSLlDADIAQAGAAYItSLlDADIAQANAAQI4Ry6FAD6AAAAAA==.',['海马']='海马濑人:BAAAKgAECgQIBAAAAA==.',['涛哥']='涛哥:BAACKgAFFH8IAAIBAAYI+xpbCQCwAQABAAYI+xpbCQCwAQAqAAQKfxUAAgEACAgJFK05AJ8BAAEACAgJFK05AJ8BAAAA.',['淡落']='淡落芬芳:BAAAKgADCgEIAQAAAA==.',['溜德']='溜德滑:BAAAKgAECgUIBQAAAA==.',['潇洒']='潇洒天哥:BAABKgAFFH8IAAIWAAgIVx+vAgCEAgAWAAgIVx+vAgCEAgAAAA==.潇洒的天哥:BAAAKgAECgMIAwAAAA==.',['灬尛']='灬尛尛:BAABKgAFFH8QAAICAAYIRxiQJQDaAAACAAYIRxiQJQDaAAAAAA==.',['灬田']='灬田采薇灬:BAAAKgADCggICgAAAA==.',['烈焰']='烈焰暖阳:BAAAKgAECgYIBgAAAA==.烈焰风行者:BAABKgAECn8sAAMPAAgIwh6EDABRAgAPAAgI0x2EDABRAgATAAgIORakHwCOAQAAAA==.',['烬殇']='烬殇:BAAAKgAFFAgIAgAAAA==.',['無心']='無心问剣:BAAAKgADCggIDAABKgAECgcIBwAgAAAAAA==.',['熊猫']='熊猫阿宽:BAAAKgADCggIFQAAAA==.',['燃烧']='燃烧的胸毛:BAAAKgAECgIIAgAAAA==.',['爆血']='爆血:BAAAKgADCgYIBgAAAA==.',['爱跳']='爱跳舞的晶晶:BAAAKgAFFAIIAgAAAA==.',['片儿']='片儿川加蛋:BAAAKgAECgcIBwAAAA==.',['牛肉']='牛肉肉:BAAAKgAECgQIBAAAAA==.',['牧香']='牧香:BAAAKgAECggICAAAAA==.',['特别']='特别追踪:BAAAKgADCgcIBwAAAA==.',['特斯']='特斯拉:BAABKgAFFH8KAAIBAAYI6g1CFQAvAQABAAYI6g1CFQAvAQAAAA==.',['特蓝']='特蓝克斯:BAAAKgAECgcIDAAAAA==.',['狂野']='狂野天使:BAAAKgADCgcIBwAAAA==.',['狐尼']='狐尼克:BAAAKgAECgIIAwAAAA==.',['狐曦']='狐曦曦:BAAAKgADCggICAAAAA==.',['狠狠']='狠狠的偷:BAABKgAFFH8UAAIFAAYIMRPnCwCOAQAFAAYIMRPnCwCOAQAAAA==.',['猎涛']='猎涛人:BAABKgAFFH8MAAMeAAgI2xRKBwAlAgAeAAgI2xRKBwAlAgAOAAQIVAfUDQDZAAAAAA==.',['獵人']='獵人要單刀:BAAAKgADCggICAAAAA==.',['瑾瑜']='瑾瑜:BAAAKgAFFAIIAgAAAA==.',['璇殇']='璇殇:BAABKgAFFH8GAAICAAYIUhemHQB8AQACAAYIUhemHQB8AQAAAA==.',['瓜子']='瓜子壳壳:BAAAKgAECgUIBQAAAA==.',['瓦尔']='瓦尔多克:BAAAKgAECgMIAwABKgAFFAMIBgAPAEEVAA==.',['生活']='生活要继续:BAAAKgAECggIDAAAAA==.',['画圆']='画圆圈诅咒你:BAABKgAFFH8MAAMRAAgIBxW7BgAfAgARAAgIRBS7BgAfAgAWAAQIvhvRIwDfAAAAAA==.',['疯狂']='疯狂沃坦:BAAAKgAECgQIBAAAAA==.',['痛风']='痛风:BAAAKgADCggICgABKgAECgcIBwAgAAAAAA==.',['瘟疫']='瘟疫忽悠着你:BAAAKgAECgMIAwAAAA==.',['瘾与']='瘾与深港:BAABKgAFFH8OAAMGAAgIsBg8DQDDAQAGAAgIsBg8DQDDAQANAAEIGgUnOgAwAAAAAA==.',['盲风']='盲风乂怪雨:BAAAKgAECgMIAwAAAA==.',['直视']='直视哥的双眼:BAAAKgAFFAQIBAAAAA==.',['福殇']='福殇:BAAAKgAECgcICQAAAA==.',['秋初']='秋初看鈤落:BAAAKgAFFAEIAQAAAA==.',['秦梦']='秦梦瑶:BAAAKgADCgIIAgAAAA==.',['端木']='端木丶樱:BAAAKgADCggIEAAAAA==.端木樱:BAAAKgADCggICAAAAA==.',['米兰']='米兰小暗号:BAABKgAFFH8IAAIEAAgIbA85BgACAgAEAAgIbA85BgACAgAAAA==.',['精灵']='精灵小谢:BAAAKgADCggICQAAAA==.精灵莱尼:BAAAKgAECgUIBwAAAA==.',['紫玉']='紫玉不乖:BAAAKgADCgUIBQAAAA==.',['红牙']='红牙牙:BAAAKgAECgEIAQAAAA==.',['纤纤']='纤纤小手:BAABKgAFFH8HAAIbAAQIVgvSHwCkAAAbAAQIVgvSHwCkAAAAAA==.',['纯爱']='纯爱奎:BAABKgAFFH8MAAMIAAgIVBQ6AwAvAgAIAAgIVBQ6AwAvAgAYAAQItAphDwCEAAAAAA==.',['绝区']='绝区零:BAAAKgAECgcICwAAAA==.',['维岳']='维岳:BAAAKgAFFAIIAgAAAA==.',['维鲁']='维鲁德拉:BAAAKgAECgQIDQAAAA==.',['缘起']='缘起缘灭:BAABKgAFFH8LAAIPAAgIyAvdBwDnAQAPAAgIyAvdBwDnAQAAAA==.',['羊百']='羊百万:BAAAKgAFFAMIAwABKgAFFAgICgADAL4TAA==.',['美式']='美式加冰:BAAAKgADCgEIAQAAAA==.',['羔雪']='羔雪崖:BAAAKgAECgcIBwAAAA==.',['胖点']='胖点错了吗:BAAAKgAFFAIIAgAAAA==.',['舒傲']='舒傲寒:BAAAKgADCggICgAAAA==.',['舞之']='舞之凋零:BAAAKgADCgMIAwAAAA==.',['艾夫']='艾夫里特:BAAAKgAECgQIBAAAAA==.',['艾文']='艾文:BAAAKgAECgcIEwAAAA==.',['艾沙']='艾沙维尔:BAAAKgAFFAQIBAAAAA==.',['艾温']='艾温丽莎:BAAAKgADCgMIAwAAAA==.',['花小']='花小染:BAABKgAFFH8IAAIbAAgI6g0WBAC+AQAbAAgI6g0WBAC+AQABKgAFFAgICgAWADAVAA==.',['花督']='花督抜德鸟:BAAAKgAECgYIBgAAAA==.',['花间']='花间舞:BAABKgAFFH8KAAMWAAYIMBU7EwBJAQAWAAYIMBU7EwBJAQARAAMIfQywOwCtAAAAAA==.',['苏南']='苏南:BAACKgAFFH8JAAQKAAMI/R5nFgD/AAAKAAMIGx1nFgD/AAAQAAIIOB+3HQCXAAALAAIIiRehOACAAAAqAAQKfxwAAwoACAhWIb8PAJoCAAoACAhWIb8PAJoCABAAAgjKIrOiAEQAAAAA.',['荼荼']='荼荼:BAAAKgAFFAgIBAAAAA==.',['莜莜']='莜莜筱影:BAAAKgADCggICAAAAA==.',['莫笑']='莫笑我痴狂:BAAAKgAECgUIBQAAAA==.',['莫高']='莫高雷走地咕:BAAAKgAFFAgIBAAAAA==.',['莲生']='莲生:BAABKgAECn8YAAIkAAgINx5EBQBOAgAkAAgINx5EBQBOAgAAAA==.',['菜王']='菜王小鬼:BAAAKgAECggIEgAAAA==.',['萌丶']='萌丶巨龙:BAAAKgADCgIIAgAAAA==.萌丶犟思:BAAAKgAFFAQIBAAAAA==.',['萌狼']='萌狼赫罗酱:BAABKgAFFH8OAAMPAAgI3RJACAAjAQAPAAcIgxBACAAjAQATAAMIfBUoGACLAAAAAA==.',['蕾贝']='蕾贝卡:BAABKgAFFH8eAAMIAAYIyBtLCACHAQAHAAYIoRmbCwCSAQAIAAYI+BZLCACHAQAAAA==.',['蘑咕']='蘑咕不咕:BAACKgAFFH8qAAIBAAcIXx0LCQC2AQABAAcIXx0LCQC2AQAqAAQKfyUAAwEACAgzGyUkAAACAAEACAgzGyUkAAACABQAAQioA3iAABwAAAAA.',['蛋疼']='蛋疼精英:BAAAKgAECgcICgAAAA==.',['血龙']='血龙至尊宝:BAABKgAFFH8GAAIIAAYIoxKfCQByAQAIAAYIoxKfCQByAQAAAA==.',['覆灭']='覆灭重生:BAACKgAFFH8WAAMWAAcIex1TEAD1AAAWAAUIihdTEAD1AAARAAQIICHLJgDrAAAqAAQKfyYAAxEACAhDIZweAHwCABEACAgCIZweAHwCABYACAjzGfUsAIUBAAAA.',['請勿']='請勿拍打餵食:BAABKgAFFH8KAAMGAAQIzRInHwC/AAAGAAQIzRInHwC/AAANAAQIqQ31JwCFAAAAAA==.',['诶哟']='诶哟哟丶:BAACKgAFFH8rAAMdAAUIiA8ICwDdAAAdAAQIXBMICwDdAAAcAAII3gORJQBiAAAqAAQKf1kAAx0ACAhrH+UaAP8BAB0ACAhrH+UaAP8BABwAAgiJCEhdAD4AAAAA.',['赖皮']='赖皮蛇花花:BAABKgAFFH8IAAICAAgIOBBpCgD/AQACAAgIOBBpCgD/AQAAAA==.',['起早']='起早贪黑:BAAAKgADCgEIAQAAAA==.',['超雄']='超雄老奶:BAAAKgAFFAIIAgAAAA==.',['软床']='软床等硬枪:BAAAKgAECggIDQAAAA==.',['迈尔']='迈尔斯:BAAAKgAECgUIBwAAAA==.',['迪士']='迪士尼酒僧:BAAAKgAECgIIAgAAAA==.',['逐日']='逐日轩:BAAAKgAFFAMIAwAAAA==.',['通通']='通通西开:BAAAKgAECgUIBQAAAA==.',['速度']='速度之靴:BAAAKgAECgIIAgAAAA==.',['逸之']='逸之助:BAABKgAECn8UAAICAAgIEx1KLwBjAgACAAgIEx1KLwBjAgAAAA==.',['邂逅']='邂逅丶:BAAAKgAECgUIBgAAAA==.邂逅丶猎:BAAAKgAECgcICwAAAA==.',['邪奎']='邪奎:BAABKgAFFH8XAAQPAAgISRzUAAAGAgAPAAgISRzUAAAGAgASAAIIhyWrFwBnAAATAAEIqQ34FABTAAAAAA==.',['钛灬']='钛灬孖妃:BAAAKgADCgYIBgAAAA==.',['钢牙']='钢牙脆脆鲨:BAAAKgADCggICAAAAA==.',['铁首']='铁首松赞干布:BAACKgAFFH8MAAIHAAMI+xiTEQD0AAAHAAMI+xiTEQD0AAAqAAQKfyIABAcACAgNHUocAC8CAAcACAgNHUocAC8CABgABAjQBis6AHgAAAgAAQhPDzRiAEUAAAAA.',['锅巴']='锅巴火鸡味:BAABKgAECn8VAAMRAAcIfhOJZACEAQARAAcIfhOJZACEAQAWAAEIlwVMlwAcAAAAAA==.',['長命']='長命鎖:BAABKgAECn8UAAMEAAgI6hDbVABqAQAEAAgIAw/bVABqAQAfAAgIoQ6MLAArAQAAAA==.',['闷头']='闷头就干:BAAAKgADCggICAAAAA==.',['队长']='队长丶是我:BAACKgAFFH8rAAMHAAUIwhBlEwAnAQAHAAUIwhBlEwAnAQAYAAMI5AefCgB/AAAqAAQKfzAAAwcACAheFyAqAOIBAAcACAheFyAqAOIBABgAAwhHEew0AJcAAAAA.',['阿坝']='阿坝州:BAAAKgADCgYIBgAAAA==.',['阿德']='阿德德:BAAAKgAFFAIIAgAAAA==.',['阿特']='阿特別:BAAAKgAFFAYIBAABKgAFFAgIBAAgAAAAAA==.',['陈一']='陈一发兒:BAACKgAFFH8mAAIRAAUIsh1FFQBLAQARAAUIsh1FFQBLAQAqAAQKf1UAAhEACAifI8caAI4CABEACAifI8caAI4CAAAA.',['雅原']='雅原姐姐:BAAAKgAECggIDQAAAA==.',['雨夜']='雨夜带着刀:BAAAKgAECggICAAAAA==.',['雪白']='雪白的大腿:BAABKgAFFH8GAAIWAAYIbhl5EABiAQAWAAYIbhl5EABiAQAAAA==.',['零度']='零度手手:BAAAKgADCgIIAgAAAA==.',['雾行']='雾行者:BAABKgAFFH8TAAMWAAgI1x24AgCCAgAWAAgI1x24AgCCAgARAAEIAAAXZwAAAAAAAA==.',['颍殇']='颍殇:BAAAKgAFFAQIBAABKgAFFAgIEgAbAGQaAA==.',['颖殇']='颖殇:BAABKgAFFH8JAAMbAAQIFhxjCAAVAQAbAAQIFhxjCAAVAQAcAAIIBQx9IwBwAAAAAA==.',['风华']='风华玉碎:BAAAKgAECgYIAgAAAA==.',['风筝']='风筝吧乌龟壳:BAAAKgAECggICAAAAA==.',['风韵']='风韵犹存:BAAAKgADCggIDQAAAA==.',['香菜']='香菜馄饨:BAAAKgAECgQIBAAAAA==.',['駄菓']='駄菓子屋:BAABKgAFFH8KAAIKAAYIVA+OJgC4AAAKAAYIVA+OJgC4AAAAAA==.',['驫龘']='驫龘殇:BAACKgAFFH8KAAIPAAMIjwdmOACPAAAPAAMIjwdmOACPAAAqAAQKfx8AAg8ACAjlFywiAPgBAA8ACAjlFywiAPgBAAEqAAUUCAgEACAAAAAA.',['马奶']='马奶:BAAAKgAECgYIBgAAAA==.',['骑小']='骑小士:BAABKgAFFH8KAAIDAAYIPiUiBQDvAQADAAYIPiUiBQDvAQAAAA==.',['骑猪']='骑猪的猫:BAAAKgAECgUIBQAAAA==.',['骑着']='骑着小猪逛街:BAABKgAFFH8IAAICAAII2B6qaQCZAAACAAII2B6qaQCZAAAAAA==.',['高了']='高了没:BAAAKgADCgEIAwAAAA==.',['高大']='高大佛爷:BAAAKgADCgQIBAAAAA==.',['魅魔']='魅魔饲养员:BAABKgAFFH8IAAIPAAgIUhVlBABAAgAPAAgIUhVlBABAAgAAAA==.',['魔界']='魔界巫医:BAAAKgADCgQIBAAAAA==.',['鹤舞']='鹤舞白沙:BAAAKgAECgMIAwAAAA==.',['龘龐']='龘龐瀣:BAAAKgAECgEIAQAAAA==.',['龙涛']='龙涛:BAAAKgAFFAgIBAAAAA==.',['龙焰']='龙焰无极:BAABKgAFFH8OAAIBAAgIJQn5CAC3AQABAAgIJQn5CAC3AQAAAA==.',['龙舌']='龙舌兰姑娘:BAAAKgAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end