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
 local lookup = {'Evoker-Devastation','Unknown-Unknown','Warlock-Destruction','Paladin-Retribution','Mage-Fire','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','Priest-Shadow','Priest-Holy','Priest-Discipline','Druid-Balance','Druid-Restoration','Warrior-Arms','Warlock-Affliction','Warrior-Fury','Warrior-Protection','Mage-Frost','Paladin-Protection','Monk-Mistweaver','Evoker-Preservation','Monk-Windwalker','DemonHunter-Havoc','DeathKnight-Blood','Rogue-Outlaw','Rogue-Assassination','Rogue-Subtlety','Warlock-Demonology','Druid-Feral','Shaman-Restoration','Paladin-Holy','Shaman-Elemental','Shaman-Enhancement','Monk-Brewmaster','Mage-Arcane','DemonHunter-Vengeance','Hunter-Survival','Druid-Guardian',}; local provider = {region='CN',realm='托塞德林',name='CN',type='weekly',zone=42,date='2025-08-08',data={Bl='Blackblood:BAAAKgAECggIEgAAAA==.',Ch='Chovy:BAABKgAFFH8IAAIBAAQIbRQ1DQDlAAABAAQIbRQ1DQDlAAABKgAFFAYIBAACAAAAAA==.',Cr='Crius:BAABKgAFFH8MAAIDAAgIQRzqAgBxAgADAAgIQRzqAgBxAgAAAA==.',Df='Dfdf:BAAAKgADCgEIAQAAAA==.',Ec='Eclipsare:BAABKgAFFH8OAAIDAAgI8RVxAgC0AQADAAgI8RVxAgC0AQAAAA==.',Ex='Exx:BAABKgAFFH8RAAIEAAgIeSTpAQDiAgAEAAgIeSTpAQDiAgAAAA==.',Fl='Flurry:BAAAKgAECggICAAAAA==.',Gl='Glory:BAABKgAFFH8MAAIFAAYIORuvAwDTAQAFAAYIORuvAwDTAQAAAA==.',Gr='Grimreaper:BAABKgAFFH8HAAIGAAQIBR+FEQAHAQAGAAQIBR+FEQAHAQABKgAFFAgIHgAHAI0mAA==.',He='Helplee:BAAAKgAECggIDgABKgAFFAgIBgAIAB0dAA==.',Ho='Horacio:BAAAKgAECgYIDAAAAA==.',Ik='Ikun:BAAAKgADCgMIAwAAAA==.',Jl='Jlm:BAABKgAFFH8PAAQJAAcIIxtvAAA+AgAJAAcIIxtvAAA+AgAKAAQIlA9EDgDKAAALAAMIfB4AAAAAAAABKgAFFAgIEwAIALQUAA==.',Ki='Kikikukukaka:BAABKgAFFH8HAAMMAAQIqiK3BgA+AQAMAAQIqiK3BgA+AQANAAIIphRwFgCCAAAAAA==.Kirito:BAABKgAFFH8FAAIOAAUINQ88EAANAQAOAAUINQ88EAANAQAAAA==.',Lr='Lr:BAACKgAFFH8eAAMHAAYIjSZ4BAA+AgAHAAYIjSZ4BAA+AgAGAAQIbiOSDAAgAQAqAAQKfxUAAwYACAijI+I4ABICAAYACAijI+I4ABICAAcAAgi5EvVtAHoAAAAA.',Lu='Luzsagrada:BAAAKgADCggICAAAAA==.',Ly='Lytehz:BAABKgAFFH8LAAIGAAMIBBA2MwDDAAAGAAMIBBA2MwDDAAAAAA==.',Ma='Manet:BAAAKgAECgIIAgAAAA==.Marimo:BAABKgAFFH8HAAMPAAMIpw6YEwCNAAAPAAIIbguYEwCNAAADAAEIGxXRLwBHAAAAAA==.',Mi='Minivince:BAEBKgAFFH8JAAMQAAYITxiEBgA0AQAQAAQIoySEBgA0AQARAAUIBAtdCwCvAAAAAA==.',Pl='Playerlqcgib:BAAAKgADCgEIAgAAAA==.',Re='Rembrandt:BAAAKgAECgMIAwAAAA==.Reniya:BAABKgAECn8UAAIJAAgI/hkDIQDNAQAJAAgI/hkDIQDNAQAAAA==.',Ru='Ruik:BAAAKgAECgcICgAAAA==.',Su='Superbimango:BAABKgAFFH8KAAISAAYIQyQgAgADAgASAAYIQyQgAgADAgAAAA==.',Va='Vartuên:BAAAKgAECgMICgAAAA==.',Vi='Victoria:BAABKgAFFH8GAAIEAAYIWg7rJQBSAQAEAAYIWg7rJQBSAQAAAA==.',Vo='Voldemortlol:BAAAKgAFFAIIAgAAAA==.',Zi='Zimoo:BAABKgAECn8eAAMEAAgILg+ZjAB+AQAEAAgICQ+ZjAB+AQATAAgIhgmGNADAAAAAAA==.',['一个']='一个九妹:BAAAKgAECgYIBgAAAA==.',['一拳']='一拳一个:BAABKgAFFH8FAAIUAAQIlSIWCAAqAQAUAAQIlSIWCAAqAQAAAA==.',['一瞬']='一瞬千躺:BAABKgAFFH8IAAIEAAQISyN9DgAaAQAEAAQISyN9DgAaAQAAAA==.',['一笔']='一笔雕凿:BAABKgAFFH8GAAMVAAQIeBthAwDmAAAVAAQIeBthAwDmAAABAAIIOQnLIAA/AAABKgAFFAgIEwAKAP0gAA==.',['一缕']='一缕青丝:BAAAKgAFFAQIBAAAAA==.',['三分']='三分王库里:BAABKgAFFH8LAAIFAAYIlSUDBwDrAQAFAAYIlSUDBwDrAQAAAA==.',['不抽']='不抽烟只抽你:BAAAKgADCgEIAgAAAA==.',['临风']='临风纵欢丶:BAAAKgADCgEIAQAAAA==.',['丶右']='丶右手:BAAAKgAECggICAAAAA==.',['丶沈']='丶沈凤昱:BAAAKgAFFAEIAQAAAA==.',['五月']='五月寒风:BAAAKgADCgIIAgAAAA==.',['人间']='人间清醒:BAABKgAFFH8IAAIWAAQI7R0YDgD8AAAWAAQI7R0YDgD8AAAAAA==.',['仲时']='仲时:BAAAKgADCgEIAQAAAA==.',['你如']='你如温阳丶:BAABKgAECn8eAAMEAAgIegxvqwD4AAAEAAcIfg5vqwD4AAATAAEIZAAAAAAAAAAAAA==.',['倾城']='倾城月夜:BAAAKgAECgIIAgAAAA==.',['八苦']='八苦:BAAAKgAECgYIDAABKgAFFAgIMgABAGQdAA==.',['冰棒']='冰棒:BAACKgAFFH9BAAMHAAgIyRrIAgBQAQAGAAgIhBgJCwC9AQAHAAYIihnIAgBQAQAqAAQKfywAAwcACAjOJGMEANYCAAcACAjOJGMEANYCAAYAAggBFL36AEEAAAAA.',['刃舞']='刃舞:BAAAKgADCggIFQAAAA==.',['十六']='十六耶:BAABKgAFFH8MAAIXAAgITBToBwA8AQAXAAgITBToBwA8AQAAAA==.',['千秋']='千秋雪:BAAAKgAECgMIAwAAAA==.',['半根']='半根烟闯江湖:BAAAKgADCgEIBAAAAA==.',['博君']='博君一笑:BAAAKgAECgcICQAAAA==.',['卿卿']='卿卿:BAABKgAFFH8TAAMIAAgItBQsAAB4AgAIAAgItBQsAAB4AgAYAAUIhxP1BgAjAQAAAA==.',['卿欢']='卿欢:BAABKgAFFH8MAAMLAAQIniHWBgApAQALAAQIniHWBgApAQAJAAQINQNOGQCZAAAAAA==.',['台风']='台风交个消失:BAACKgAFFH8uAAQZAAgIrSYXAAD0AgAZAAgIACUXAAD0AgAaAAgIPyABAQDjAgAbAAIInxVXDwBXAAAqAAQKfx8AAxsACAg8Ih4FAKACABsACAg8Ih4FAKACABoAAwi3EYQxANAAAAAA.',['后会']='后会无期:BAABKgAFFH8IAAMJAAQIuhzBFQDNAAAJAAQIuhzBFQDNAAAKAAQIPwTZMQB+AAAAAA==.',['听劝']='听劝:BAAAKgAECgMIBQAAAA==.',['吴苗']='吴苗苗:BAAAKgAFFAIIAgAAAA==.',['吹散']='吹散小白云:BAAAKgAECggIEAABKgAFFAgICAAEAC8jAA==.',['周角']='周角:BAAAKgADCggICAAAAA==.',['周郎']='周郎:BAABKgAECn8XAAIDAAgIbRXCJgDfAQADAAgIbRXCJgDfAQAAAA==.',['哀木']='哀木涕:BAAAKgAECgIIAgAAAA==.',['喜欢']='喜欢下雨天:BAAAKgAECgQIBwAAAA==.喜欢小圆脸丶:BAAAKgAFFAQIBAAAAA==.',['喷火']='喷火梦嫣龙:BAABKgAFFH8FAAIBAAUIABQcGgDxAAABAAUIABQcGgDxAAAAAA==.',['圣骑']='圣骑玎玎:BAABKgAFFH8SAAITAAgI0wwmCAA3AQATAAgI0wwmCAA3AQAAAA==.',['堇墨']='堇墨浮华丶:BAAAKgADCgEIAgAAAA==.',['夏天']='夏天小熊猫:BAAAKgAFFAQIBAAAAA==.',['夏慕']='夏慕槿苏丶:BAABKgAFFH8MAAMDAAMIFxA5GQC1AAADAAMIFxA5GQC1AAAcAAEIogRdMQA1AAAAAA==.',['大丨']='大丨狼狗:BAAAKgADCggICAAAAA==.',['大爆']='大爆:BAAAKgADCgEIAQABKgAFFAcIHgAIAEIfAA==.',['大爷']='大爷逍遥游:BAAAKgAECgYIBgAAAA==.',['天之']='天之川沙夜:BAABKgAFFH8KAAMKAAYI3g/REAAsAQAKAAYIzw3REAAsAQALAAQI9RSbDADwAAABKgAFFAgICwAPAJMeAA==.',['天气']='天气预报:BAACKgAFFH8KAAMJAAYIFw7rDQAhAQAJAAYIFw7rDQAhAQALAAQIRQXHJQCHAAAqAAQKfxcAAwsACAjVHtkLAHICAAsACAjVHtkLAHICAAoABwjPEsIuAIkBAAAA.',['天降']='天降大锤:BAAAKgAECgIIAgAAAA==.',['太古']='太古雷傲天:BAAAKgADCggICAAAAA==.',['奔跑']='奔跑的五花肉:BAAAKgAECgIIAgAAAA==.',['奶龙']='奶龙也是龙:BAAAKgAECgEIAQAAAA==.',['姬魅']='姬魅蓝:BAABKgAFFH8PAAMMAAYI5RxaAwCXAQAMAAYI5RxaAwCXAQANAAII3wq8GgBvAAABKgAFFAgIEQANAD4jAA==.',['威尔']='威尔斯丨铁蹄:BAABKgAFFH8GAAMdAAMIsAiqBQC9AAAdAAMIsAiqBQC9AAAMAAMINwIHKgBtAAABKgAFFAcIHgAIAEIfAA==.',['子龙']='子龙:BAAAKgAECggIEwAAAA==.',['寒冰']='寒冰箭砸死你:BAAAKgADCgQIBAAAAA==.',['寒少']='寒少充电宝:BAABKgAFFH8MAAIeAAMIFQ39GwCZAAAeAAMIFQ39GwCZAAAAAA==.',['寒风']='寒风凛冽:BAAAKgAECggICAAAAA==.',['小气']='小气巴拉:BAAAKgADCggICAAAAA==.',['小狐']='小狐狸米纱:BAAAKgAECgYICgAAAA==.',['小红']='小红手灬:BAABKgAFFH8MAAIHAAgIPhe5BAAoAgAHAAgIPhe5BAAoAgAAAA==.小红手王哥:BAABKgAFFH8FAAMbAAUIfBFMCwCnAAAbAAMIew1MCwCnAAAaAAIIgB3eFwBWAAAAAA==.',['尤缇']='尤缇安娜:BAAAKgAFFAYIBAABKgAFFAgIBgAUAEMYAA==.',['尸罗']='尸罗:BAAAKgAFFAQIBAAAAA==.',['山山']='山山而川:BAAAKgAECgUIBgAAAA==.',['山村']='山村拓哉:BAABKgAFFH8GAAIIAAYIkAjDHgApAQAIAAYIkAjDHgApAQAAAA==.',['差不']='差不多该出了:BAABKgAFFH8IAAMIAAQIqBhBLQDZAAAIAAQIqBhBLQDZAAAYAAQImQEqLgBYAAAAAA==.',['常山']='常山的子龙:BAAAKgADCgEIAQAAAA==.',['康桥']='康桥之恋:BAABKgAFFH8LAAMJAAYIlxSyCwBDAQAJAAYIlxSyCwBDAQAKAAUIMQzaGgDkAAAAAA==.',['弦千']='弦千钧:BAAAKgAFFAgIAQAAAA==.',['弹跳']='弹跳波比:BAAAKgAFFAYIAgAAAA==.',['当浮']='当浮一大白:BAAAKgAECgUIBQAAAA==.',['彭哥']='彭哥:BAAAKgAECgIIAgAAAA==.',['影魔']='影魔德:BAAAKgADCgUIBQAAAA==.',['待敌']='待敌:BAACKgAFFH8mAAIfAAgIixFdBgBcAQAfAAgIixFdBgBcAQAqAAQKfysAAx8ACAi+HH0TANkBAB8ACAi+HH0TANkBABMAAQjCAthiAAUAAAAA.',['微笑']='微笑骑士:BAABKgAFFH8NAAIIAAYIZyEFAQD4AQAIAAYIZyEFAQD4AQAAAA==.',['德艺']='德艺双双:BAABKgAFFH8GAAIMAAYIwQ/CGABSAQAMAAYIwQ/CGABSAQAAAA==.',['心火']='心火牧:BAAAKgAECgcICgAAAA==.',['怀澍']='怀澍先生:BAAAKgAECggICAAAAA==.',['我压']='我压迫众生:BAAAKgAFFAgIBAAAAA==.',['我在']='我在冲了你呢:BAACKgAFFH8HAAMYAAUIBRIdEAC+AAAYAAQINRMdEAC+AAAIAAEIdQ5IUQBPAAAqAAQKfxkAAxgACAg6GC0iAHkBABgACAh0FC0iAHkBAAgAAwh1Gox9AOsAAAAA.',['我有']='我有小秘密:BAAAKgAECgcIBwAAAA==.',['打的']='打的菜没烦恼:BAABKgAFFH8OAAMeAAgISxTwCgCZAQAeAAYIMxnwCgCZAQAgAAIIRgbNHQCKAAAAAA==.',['抱抱']='抱抱:BAABKgAFFH8LAAMhAAYIXxc+AQDQAQAhAAYIXxc+AQDQAQAeAAUIfRmfAgBiAQAAAA==.',['指引']='指引者:BAAAKgADCgMIAwAAAA==.',['捡到']='捡到猫胡子:BAAAKgAFFAUIAQAAAA==.',['攸然']='攸然飄葉:BAABKgAFFH8IAAIDAAYIxRXmEQB5AQADAAYIxRXmEQB5AQAAAA==.',['敖丙']='敖丙:BAACKgAFFH8yAAMBAAgIZB08BwAXAgABAAcIch48BwAXAgAVAAUIihkaAwDvAAAqAAQKfyoAAxUACAgHHOsEAFACABUACAgHHOsEAFACAAEACAisHV0cANkBAAAA.',['斬殺']='斬殺型:BAABKgAFFH8KAAMQAAYISRmMCgATAQAQAAQISx+MCgATAQAOAAYIeRStFgBaAAAAAA==.',['无名']='无名小德:BAAAKgAECgQICgAAAA==.',['无與']='无與偷比:BAAAKgAFFAEIAQABKgAFFAgIDAAIAPURAA==.',['春丽']='春丽:BAAAKgAFFAQIBAAAAA==.',['晚秋']='晚秋晚凉天丶:BAAAKgAFFAMIAwAAAA==.',['暮夕']='暮夕:BAABKgAFFH8IAAILAAQIywI0KAB1AAALAAQIywI0KAB1AAAAAA==.',['有梦']='有梦想的咸鱼:BAEAKgAFFAIIAQABKgAFFAgIBgAhAK4TAA==.',['末希']='末希:BAAAKgADCgQIBAAAAA==.',['李老']='李老酒:BAABKgAFFH8OAAIiAAQIZBBhBQCbAAAiAAQIZBBhBQCbAAAAAA==.',['枕头']='枕头:BAACKgAFFH8uAAQSAAYI/hhtDAAGAQAFAAUIIBOtFAAUAQASAAQIeiBtDAAGAQAjAAEILxn2QQBMAAAqAAQKf1QAAxIACAimI98LAKQCABIACAimI98LAKQCACMABAgNIfoyAIQBAAAA.',['林花']='林花谢了春红:BAAAKgAECgQIBAAAAA==.',['果汁']='果汁分你一半:BAAAKgADCgMIAwAAAA==.果汁分她一半:BAAAKgAECgcIBwAAAA==.',['梦烬']='梦烬:BAAAKgAFFAQIBAABKgAFFAgIDgADACUZAA==.',['棒棒']='棒棒哒:BAABKgAFFH8MAAMIAAgIHBpvBQBKAgAIAAgIHBpvBQBKAgAYAAIIGxZ2GgCCAAAAAA==.',['森海']='森海飞侠:BAABKgAFFH8GAAMHAAYIBhaiNQCdAAAHAAQImRCiNQCdAAAGAAIIKR4AAAAAAAAAAA==.',['樟树']='樟树兜老前辈:BAAAKgAECgYIBgAAAA==.',['欧皇']='欧皇灬小哥哥:BAAAKgAECgQIBAAAAA==.',['歐皇']='歐皇:BAAAKgADCgMIBQAAAA==.',['殇之']='殇之逝:BAABKgAECn8iAAIIAAgIhhLSNQCeAQAIAAgIhhLSNQCeAQAAAA==.',['殢无']='殢无伤:BAAAKgAFFAgIBAAAAA==.',['水蓝']='水蓝色天空:BAABKgAFFH8SAAISAAgIDiDLAACpAgASAAgIDiDLAACpAgAAAA==.',['汪利']='汪利丹丶怒风:BAAAKgADCgQIBAAAAA==.',['沉睡']='沉睡森林:BAABKgAFFH8MAAIHAAgIYhQVBgD5AQAHAAgIYhQVBgD5AQAAAA==.',['沪爷']='沪爷冲击:BAABKgAFFH8IAAIKAAgI8Q51BQDCAQAKAAgI8Q51BQDCAQAAAA==.',['油焖']='油焖大虾:BAAAKgAECgcICwAAAA==.',['油竹']='油竹:BAAAKgAECgEIAQAAAA==.',['洛丹']='洛丹伦忧伤:BAAAKgAECgIIAgAAAA==.',['洛克']='洛克塔尔:BAACKgAFFH8UAAIQAAYI0iHOCADJAQAQAAYI0iHOCADJAQAqAAQKfxQAAhAACAjuGp8cAC0CABAACAjuGp8cAC0CAAAA.',['洛姬']='洛姬雅:BAAAKgAECgIIAgAAAA==.',['液丶']='液丶氧罐头:BAAAKgADCgEIAwAAAA==.',['液氧']='液氧罐丶头:BAAAKgADCgEIAwAAAA==.',['湫兮']='湫兮如风:BAAAKgADCggICAAAAA==.',['火焰']='火焰牛牛:BAAAKgAECgEIAQAAAA==.',['灵吉']='灵吉:BAAAKgAECgEIAQAAAA==.',['炽热']='炽热智慧之光:BAABKgAFFH8OAAIKAAYIkRJ9DgBCAQAKAAYIkRJ9DgBCAQAAAA==.',['熊猫']='熊猫银:BAABKgAFFH8FAAIHAAUIJhUIHQAJAQAHAAUIJhUIHQAJAQAAAA==.',['爆破']='爆破鬼才:BAAAKgAFFAQIBAAAAA==.',['犀利']='犀利不解释:BAAAKgAECgYIEwAAAA==.',['猫舍']='猫舍晚:BAAAKgAFFAgIBAAAAA==.',['猴师']='猴师傅哦:BAABKgAFFH8IAAMYAAgIMBkWDgA5AQAYAAQIkhkWDgA5AQAIAAQIrRi2MQDMAAAAAA==.',['王小']='王小濛:BAAAKgAECgQIBAAAAA==.王小白:BAAAKgADCggICAAAAA==.',['玛夏']='玛夏多:BAAAKgAECgIIAgAAAA==.',['环绕']='环绕太阳:BAAAKgAECgQIBAAAAA==.',['瑞克']='瑞克:BAABKgAFFH8UAAMGAAQIXxPEMgDEAAAGAAQIXxPEMgDEAAAHAAEIcgIuVgAqAAAAAA==.瑞克克阿阿:BAABKgAECn8mAAMGAAgIjxNMTgDHAQAGAAgIjBNMTgDHAQAHAAcIFgvVYADUAAAAAA==.',['留白']='留白:BAABKgAFFH8QAAIEAAgIphYPDAAJAgAEAAgIphYPDAAJAgAAAA==.',['盲眼']='盲眼猎手卡恩:BAACKgAFFH8XAAIkAAMIugLwEwBjAAAkAAMIugLwEwBjAAAqAAQKfycAAiQACAgsB6c+AMcAACQACAgsB6c+AMcAAAAA.',['硬龙']='硬龙龙战:BAAAKgADCgYIBgAAAA==.',['神原']='神原骏河:BAAAKgAFFAQIBAAAAA==.',['神秘']='神秘的加菲猫:BAABKgAFFH88AAIIAAgI/CXSAAD0AgAIAAgI/CXSAAD0AgAAAA==.',['离雨']='离雨弥港丶:BAAAKgADCgEIAQAAAA==.',['秋冬']='秋冬:BAAAKgAECgQIBAABKgAFFAgIDQAFADUdAA==.',['秋刀']='秋刀鱼:BAAAKgAECgEIAwAAAA==.',['第一']='第一时间甩锅:BAACKgAFFH8RAAMDAAMIURbYEwDVAAADAAMIURbYEwDVAAAPAAEI+QotHwBDAAAqAAQKfyEAAwMACAiAIkMNAEkCAAMACAiAIkMNAEkCAA8AAQgjAgRPABMAAAAA.',['箫瑟']='箫瑟:BAAAKgAFFAYIAgABKgAFFAgIDAAMAHMZAA==.',['米尼']='米尼亨特:BAACKgAFFH8RAAIGAAQIkhi6GwDmAAAGAAQIkhi6GwDmAAAqAAQKfxoAAgYACAjGHVQtAD4CAAYACAjGHVQtAD4CAAAA.',['紫小']='紫小虾:BAABKgAFFH8SAAIXAAgI2RSHBwAeAgAXAAgI2RSHBwAeAgAAAA==.',['紫苏']='紫苏桃子:BAAAKgAECgQIBAAAAA==.',['纵情']='纵情享乐丶:BAAAKgADCgIIBQAAAA==.',['终极']='终极晓德:BAAAKgAECgYIBgAAAA==.',['缇亚']='缇亚:BAAAKgADCgYIBgAAAA==.',['羽月']='羽月风花:BAAAKgADCgEIAQAAAA==.',['翟老']='翟老师:BAABKgAFFH8MAAMHAAYIXh+DAQCiAQAHAAYICBaDAQCiAQAGAAYIXh/dDwB8AQAAAA==.',['考试']='考试必胜佛:BAABKgAFFH8KAAQlAAMI9QYZBACeAAAlAAMIxwYZBACeAAAHAAEI8wfZKQAwAAAGAAEIUAL7YwApAAAAAA==.',['耐揍']='耐揍王:BAAAKgAFFAYIAwAAAA==.',['耶卡']='耶卡:BAAAKgADCgEIAQAAAA==.',['聂风']='聂风:BAAAKgAFFAIIAgAAAA==.',['肥肚']='肥肚肚左卫门:BAACKgAFFH8vAAIEAAcIHSXSCgAZAgAEAAcIHSXSCgAZAgAqAAQKfy4AAgQACAidJh0JAPYCAAQACAidJh0JAPYCAAAA.',['腌笃']='腌笃鲜:BAAAKgAECggICAAAAA==.',['艾斯']='艾斯德斯:BAAAKgAFFAQIBAAAAA==.',['花尽']='花尽千霜默:BAAAKgADCgEIAQAAAA==.',['若舞']='若舞清风丶:BAABKgAFFH8IAAIEAAII9RKwdgB8AAAEAAII9RKwdgB8AAAAAA==.',['英雄']='英雄挽歌:BAAAKgAFFAgIBAAAAA==.',['荆棘']='荆棘冠上的针:BAAAKgAECgUICgAAAA==.',['荞麦']='荞麦面:BAAAKgAFFAgIAQAAAA==.',['莉亚']='莉亚德琳:BAAAKgAECgIIAgAAAA==.',['莫柔']='莫柔殿下:BAAAKgADCggICAAAAA==.',['萌肉']='萌肉肉:BAAAKgADCggIDAAAAA==.',['萌萌']='萌萌的康子:BAABKgAFFH8IAAIEAAQImSNbDgAbAQAEAAQImSNbDgAbAQAAAA==.',['萌骑']='萌骑帝路飛:BAAAKgAFFAMIAwAAAA==.',['落花']='落花无言:BAABKgAFFH8XAAIYAAgIzQYGCwDtAAAYAAgIzQYGCwDtAAAAAA==.',['葛东']='葛东骏:BAAAKgAECggICQAAAA==.',['蒙嘉']='蒙嘉慧:BAAAKgADCggICAAAAA==.',['蒙多']='蒙多:BAABKgAECn8YAAIQAAgIpRSxMwCyAQAQAAgIpRSxMwCyAQAAAA==.',['蕾依']='蕾依丽雅:BAABKgAFFH8GAAIGAAYIMQ6cFgBDAQAGAAYIMQ6cFgBDAQAAAA==.',['薇薇']='薇薇:BAAAKgADCggIEAAAAA==.',['藿藿']='藿藿:BAABKgAFFH8FAAIUAAMIWhabGQCwAAAUAAMIWhabGQCwAAABKgAFFAgICwAPAJMeAA==.',['血雨']='血雨探花刂:BAABKgAECn8VAAIQAAgIhw8CNgCnAQAQAAgIhw8CNgCnAQABKgAFFAYIBAACAAAAAA==.',['街頭']='街頭戰神:BAAAKgAECggIDgAAAA==.',['裂心']='裂心萨:BAAAKgAECgQIBAAAAA==.',['角瓜']='角瓜炖茄子:BAAAKgADCgUIBQAAAA==.',['订卡']='订卡小李一号:BAAAKgAECggIDgAAAA==.',['认真']='认真就输了:BAAAKgAECgMIAwAAAA==.',['语玲']='语玲珑:BAAAKgADCgUIBQAAAA==.',['贝如']='贝如塔:BAAAKgAFFAgIBAAAAA==.',['贫穷']='贫穷的阿昆达:BAAAKgAECggICAAAAA==.',['贴贴']='贴贴:BAABKgAFFH8MAAIXAAgIdCFKBACcAQAXAAgIdCFKBACcAQABKgAFFAgIEwAIALQUAA==.',['赤布']='赤布:BAAAKgAFFAQIBAAAAA==.',['走吧']='走吧风儿:BAAAKgAECgQIBAAAAA==.',['软丶']='软丶饼干:BAAAKgADCgEIBQAAAA==.',['轻描']='轻描淡写:BAABKgAFFH8KAAIYAAYILg1kFQD3AAAYAAYILg1kFQD3AAABKgAFFAgIBgAIAB0dAA==.',['轻装']='轻装上阵:BAAAKgAFFAYIAgAAAA==.',['辰月']='辰月之狐:BAACKgAFFH8RAAMDAAUIsBNdGADAAAADAAQICxJdGADAAAAcAAEIQRoXJgBNAAAqAAQKfykAAxwACAj2GHAcAJoBABwABghDF3AcAJoBAAMABghSEF9zALEAAAAA.',['这个']='这个是雨天:BAABKgAFFH8GAAIUAAYIQxisEQDeAAAUAAYIQxisEQDeAAAAAA==.',['遗失']='遗失梦境:BAAAKgADCgcIBwAAAA==.',['部落']='部落子龙:BAAAKgAECgUIBgAAAA==.',['酥茶']='酥茶儿:BAABKgAFFH8GAAIDAAYI0R+hAAAVAgADAAYI0R+hAAAVAgAAAA==.',['醉梦']='醉梦璑訫:BAAAKgAECgYICAAAAA==.醉梦訫德:BAABKgAECn8dAAQdAAgIsxbWDgC1AQAdAAYI7RXWDgC1AQAMAAgI9RBnTwB6AQAmAAEI+R6YNQBTAAAAAA==.',['醉落']='醉落夕风丶:BAABKgAFFH8LAAMGAAMIHxR2RwCFAAAGAAIIThV2RwCFAAAHAAIIQg9NQQB1AAAAAA==.',['里雍']='里雍:BAAAKgADCgEIAgAAAA==.',['野原']='野原新之助:BAAAKgAFFAEIAQAAAA==.',['野獣']='野獣初號機:BAAAKgAFFAQIAQAAAA==.',['铁锤']='铁锤:BAAAKgAFFAYIAgAAAA==.',['阳光']='阳光宅牛:BAAAKgAECgcIEAAAAA==.',['阿夏']='阿夏芙:BAAAKgADCgEIAQAAAA==.',['阿布']='阿布达雷:BAACKgAFFH8XAAIIAAgIxSA0AwCTAgAIAAgIxSA0AwCTAgAqAAQKfycAAggACAjNI4smACACAAgACAjNI4smACACAAAA.',['阿祖']='阿祖:BAAAKgADCggIEAAAAA==.',['阿良']='阿良:BAABKgAFFH8GAAIjAAYICByUCwCwAQAjAAYICByUCwCwAQAAAA==.',['陈睿']='陈睿大哥哥:BAAAKgAECgEIAQAAAA==.',['陈风']='陈风暴醉酒:BAABKgAFFH8MAAMOAAgIhx3fBQB+AQAOAAgIhx3fBQB+AQAQAAQIjg1fFADlAAAAAA==.',['难受']='难受想哭:BAACKgAFFH8GAAIIAAUIIAgnOQC3AAAIAAUIIAgnOQC3AAAqAAQKfzIAAggACAhEIBkWAHwCAAgACAhEIBkWAHwCAAAA.',['雪糕']='雪糕:BAAAKgAECgQIBAAAAA==.',['零一']='零一士魂:BAAAKgAECgQIBgAAAA==.',['雷声']='雷声普化天尊:BAAAKgADCgcIBwAAAA==.',['靇龍']='靇龍:BAAAKgAECgQIBAAAAA==.',['青眼']='青眼究极龙:BAAAKgAECgIIAgAAAA==.',['青鹭']='青鹭狂想曲:BAAAKgAECggICAAAAA==.',['風之']='風之殇:BAAAKgADCgQIBAAAAA==.',['风语']='风语如歌:BAAAKgAECgcIBwAAAA==.',['飛雪']='飛雪倾城:BAABKgAFFH8UAAIEAAgIQSHVAwCiAgAEAAgIQSHVAwCiAgAAAA==.',['麒乄']='麒乄麟:BAAAKgADCgEIAQAAAA==.',['麻辣']='麻辣姬丝:BAAAKgAECgIIAgAAAA==.麻辣鸡棒棒:BAAAKgAECggICwAAAA==.',['黄昏']='黄昏圣痕:BAABKgAFFH8GAAIEAAQIDA0NKgDKAAAEAAQIDA0NKgDKAAAAAA==.',['黄油']='黄油面包:BAAAKgAECgEIAQAAAA==.',['齐天']='齐天大圣:BAAAKgAFFAYIBAAAAA==.',['龙首']='龙首彩虹:BAAAKgADCgQICgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end