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
 local lookup = {'Paladin-Retribution','Hunter-BeastMastery','Priest-Holy','Priest-Discipline','DemonHunter-Havoc','Druid-Restoration','Druid-Balance','Hunter-Marksmanship','DeathKnight-Frost','DeathKnight-Unholy','Mage-Fire','Mage-Frost','DeathKnight-Blood','Shaman-Restoration','Monk-Mistweaver','Monk-Windwalker','Evoker-Devastation','Rogue-Assassination','Rogue-Subtlety','Warlock-Demonology','Unknown-Unknown','Warrior-Arms','Mage-Arcane','Paladin-Protection','Warrior-Protection','Warrior-Fury','Paladin-Holy','Warlock-Destruction','Warlock-Affliction','Druid-Guardian','Druid-Feral','Shaman-Elemental','Shaman-Enhancement','Priest-Shadow','DemonHunter-Vengeance',}; local provider = {region='CN',realm='符文图腾',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Acelyydd:BAAAKgAFFAQIBAAAAA==.',Al='Alien:BAAAKgAFFAgIAwAAAA==.',As='Asaas:BAAAKgAFFAQIBAAAAA==.',Bo='Borrl:BAABKgAFFH8MAAIBAAgI2RCwEgDHAQABAAgI2RCwEgDHAQAAAA==.',Br='Bruce:BAAAKgAFFAEIAQAAAA==.',Ca='Calliope:BAABKgAFFH8IAAICAAgIlRDWCADoAQACAAgIlRDWCADoAQAAAA==.Cassandra:BAAAKgADCgcIBwAAAA==.Catcs:BAABKgAFFH8GAAIBAAYIggoSKQBDAQABAAYIggoSKQBDAQAAAA==.',Cl='Cloudphoenix:BAAAKgADCggIDAAAAA==.',Co='Combq:BAAAKgAFFAYIBAABKgAFFAgIBwADAM4fAA==.',Da='Darkenergy:BAAAKgAECggICgAAAA==.',Do='Doctere:BAACKgAFFH8VAAMDAAQIGROWJgCoAAADAAQIGROWJgCoAAAEAAIIjAtXHgCDAAAqAAQKfx8AAwQACAgtG3ATACoCAAQACAgtG3ATACoCAAMAAQjKCiuFAC0AAAAA.Doggie:BAAAKgAECgcIBwAAAA==.Doraemo:BAAAKgADCggIDAAAAA==.',Ei='Eiie:BAAAKgAECgEIAQAAAA==.',Eu='Euterpe:BAABKgAFFH8IAAIFAAgIUBrfCQDvAQAFAAgIUBrfCQDvAQAAAA==.',Gu='Guff:BAABKgAFFH8HAAMGAAQIVBb4CQDkAAAGAAQIVBb4CQDkAAAHAAMImhmuJACgAAABKgAFFAgICAAIALMfAA==.',He='Heavensgate:BAACKgAFFH8XAAMJAAYIHSEsAgDTAQAJAAYIHSEsAgDTAQAKAAYItA7NGQBPAQAqAAQKfxYAAgoACAgLD2RdAE4BAAoACAgLD2RdAE4BAAAA.',Lo='Lookman:BAAAKgADCggICAAAAA==.',Ne='Necrolyte:BAABKgAFFH8PAAMLAAgIvA9NCgCTAQALAAcIEA1NCgCTAQAMAAQICBmqCADvAAAAAA==.',No='Nonsense:BAAAKgAECgcIBAAAAA==.',Po='Poems:BAABKgAFFH8IAAILAAgIDwecCAC6AQALAAgIDwecCAC6AQAAAA==.',Ra='Rachle:BAAAKgAECgUIBQAAAA==.',Re='Reartist:BAAAKgAFFAQIBAAAAA==.',Se='Seasons:BAAAKgAECgYIEQAAAA==.',Sp='Spr:BAABKgAECn8YAAINAAgIgB6yCwA5AgANAAgIgB6yCwA5AgAAAA==.',Te='Tempestorz:BAAAKgAECgEIAQAAAA==.',Th='Thatgirl:BAAAKgADCggICAAAAA==.',Um='Umika:BAAAKgAECgQIBgAAAA==.Umikk:BAAAKgAECgEIAQAAAA==.',Us='Usiel:BAACKgAFFH8XAAIOAAgIZRwaAgB2AgAOAAgIZRwaAgB2AgAqAAQKfycAAg4ACAitIrYKAJgCAA4ACAitIrYKAJgCAAAA.',Vt='Vtargaryen:BAAAKgAECgUICQAAAA==.',Ze='Zealot:BAAAKgAECgQIBgAAAA==.',['一七']='一七月一:BAABKgAECn8YAAIGAAgI/B0jDwBSAgAGAAgI/B0jDwBSAgAAAA==.',['一只']='一只爪子:BAAAKgADCgIIAgAAAA==.',['一炁']='一炁丶大笨牛:BAAAKgADCggIEAAAAA==.',['一缕']='一缕青丝:BAAAKgADCggIEAAAAA==.',['一西']='一西毒一:BAABKgAFFH8LAAMCAAMI/BCAGQDJAAACAAMI/BCAGQDJAAAIAAIIJAYZSwBTAAAAAA==.',['七千']='七千:BAAAKgADCgYIBgAAAA==.',['七月']='七月别走:BAAAKgADCggICAAAAA==.',['三十']='三十六变:BAAAKgADCgYIBgAAAA==.',['上善']='上善如水:BAAAKgAECgEIAQAAAA==.',['上帝']='上帝的右脚:BAAAKgAECgYICwAAAA==.',['下山']='下山抓绵羊:BAACKgAFFH8bAAMIAAMIIhz1JADZAAAIAAMIIhz1JADZAAACAAMIKhVLLQDSAAAqAAQKfyQAAwgACAhIHQUTADsCAAgACAhIHQUTADsCAAIABwhGFMp0AFYBAAAA.',['不动']='不动金刚明王:BAAAKgADCgEIAQAAAA==.',['不知']='不知道:BAAAKgADCggICwAAAA==.',['不高']='不高兴丶释槐:BAAAKgAECggIEgAAAA==.',['与时']='与时:BAAAKgAFFAQIBAAAAA==.',['两千']='两千:BAAAKgADCgIIAgAAAA==.',['两口']='两口奶满:BAACKgAFFH8KAAIPAAYI/BnlCwBoAQAPAAYI/BnlCwBoAQAqAAQKfxkAAw8ACAhsGhIaALgBAA8ABwg1GhIaALgBABAABAhcIIIpAFgBAAAA.',['丨妮']='丨妮児:BAAAKgAFFAgIBAAAAA==.',['丨星']='丨星期一丨:BAAAKgADCgcIBwAAAA==.',['丨火']='丨火锅丨:BAAAKgAECgQIBAAAAA==.',['丨燈']='丨燈萢大叔丨:BAABKgAFFH8IAAIBAAQI/xSfJwDUAAABAAQI/xSfJwDUAAAAAA==.',['临海']='临海:BAABKgAFFH8KAAINAAYI+Q87CAAYAQANAAYI+Q87CAAYAQABKgAFFAgIDQABAOEYAA==.',['丶小']='丶小艾:BAAAKgAFFAQIBAAAAA==.',['丶尐']='丶尐夜:BAACKgAFFH8IAAMCAAMImRWVIwCMAAACAAMImRWVIwCMAAAIAAEImRCuJwA9AAAqAAQKfxUAAwIACAhAG4RCAO8BAAIACAggG4RCAO8BAAgAAwjvHUgiAAUBAAAA.',['丶镜']='丶镜花氺月:BAABKgAFFH8KAAMNAAYIrQyXFQD1AAANAAYIrQyXFQD1AAAKAAQIVgJ7RQCKAAAAAA==.',['丶龍']='丶龍崽:BAAAKgAECgQIBAAAAA==.',['丷舞']='丷舞丷:BAABKgAECn8fAAIBAAgIDBcGVwC4AQABAAgIDBcGVwC4AQAAAA==.',['丹呢']='丹呢莉丝:BAABKgAFFH8MAAIRAAgIRxR2BwARAgARAAgIRxR2BwARAgAAAA==.',['乔治']='乔治基维斯:BAACKgAFFH8KAAISAAMIWBpSEACuAAASAAMIWBpSEACuAAAqAAQKfyIAAxIACAjxIc8FAKoCABIACAjxIc8FAKoCABMABAjdCrgrAJUAAAAA.',['二世']='二世丨英豪:BAAAKgAECgYIBwAAAA==.',['二分']='二分之七:BAAAKgAECgEIAQAAAA==.',['二号']='二号大米:BAAAKgADCggIEAAAAA==.',['云间']='云间月:BAAAKgADCggIDQAAAA==.',['亿尘']='亿尘不染:BAAAKgAECgYIBwAAAA==.',['今夜']='今夜打虎虎:BAABKgAFFH8HAAIFAAQIOAuCGwC1AAAFAAQIOAuCGwC1AAAAAA==.',['今天']='今天打虎虎:BAAAKgAFFAQIBAAAAA==.',['仲夏']='仲夏沫之恋:BAABKgAFFH8GAAIEAAYIuxG2CgBrAQAEAAYIuxG2CgBrAQAAAA==.',['伊伊']='伊伊布兰达:BAAAKgAECgYIDAAAAA==.',['低调']='低调的老牛:BAAAKgAECgQIBgAAAA==.',['何物']='何物似情浓丶:BAAAKgAECgIIAgAAAA==.',['你家']='你家隔壁王哥:BAAAKgAFFAYIBAAAAA==.',['侏侏']='侏侏与儒儒:BAACKgAFFH8cAAIUAAMIZhaCCwDYAAAUAAMIZhaCCwDYAAAqAAQKfx4AAhQACAiiHRcMADoCABQACAiiHRcMADoCAAAA.',['依旧']='依旧憧憬:BAAAKgAECggICAAAAA==.依旧飞到火星:BAAAKgAECggICAABKgAFFAgIBAAVAAAAAA==.',['俄赛']='俄赛里斯:BAABKgAFFH8IAAIWAAgIkxNsAwAlAgAWAAgIkxNsAwAlAgABKgAFFAgICQACAE8SAA==.',['俗名']='俗名小强:BAAAKgAECgQIBAAAAA==.',['保证']='保证不抽死你:BAAAKgAFFAQIBAAAAA==.',['修仙']='修仙狂徒:BAAAKgAECgYICAAAAA==.',['俺是']='俺是白牛:BAAAKgAECgUIBQAAAA==.',['倾城']='倾城倾国:BAAAKgAECggICAAAAA==.',['做一']='做一晚泥工:BAAAKgAECggIEgAAAA==.',['傲剑']='傲剑独步:BAAAKgAECggICAAAAA==.傲剑玄皇:BAAAKgAECgMIAwAAAA==.',['僵丝']='僵丝坦丁:BAABKgAFFH8GAAMXAAQIZhvPHwDqAAAXAAQIZhvPHwDqAAAMAAII9wwaJQBpAAAAAA==.',['光丨']='光丨头:BAAAKgADCgEIAQAAAA==.',['冰冷']='冰冷易水寒:BAABKgAECn8VAAIDAAgIDxRFJwCVAQADAAgIDxRFJwCVAQAAAA==.',['冰凌']='冰凌傲天:BAAAKgADCgMIAwAAAA==.',['冰封']='冰封乱城:BAAAKgAECggICQAAAA==.',['冰霜']='冰霜万里:BAAAKgAECgUIBQAAAA==.',['刀刀']='刀刀丶:BAABKgAFFH8FAAIYAAQIMBUuCgDCAAAYAAQIMBUuCgDCAAABKgAFFAYIBgAXAK0NAA==.',['初十']='初十:BAAAKgAECggIEAAAAA==.',['别具']='别具只眼:BAAAKgADCgQIBAAAAA==.',['别打']='别打俺的屁屁:BAABKgAFFH8IAAIKAAQIfQmCOwCvAAAKAAQIfQmCOwCvAAAAAA==.',['劳斯']='劳斯来斯:BAAAKgAECggIDgAAAA==.',['勇敢']='勇敢牛牛啊:BAABKgAFFH8JAAIZAAMInQXMCwBtAAAZAAMInQXMCwBtAAAAAA==.',['勥氼']='勥氼:BAACKgAFFH8KAAIaAAIIPRm8HgCaAAAaAAIIPRm8HgCaAAAqAAQKfyIAAhoACAiGI7wKAJgCABoACAiGI7wKAJgCAAAA.',['北落']='北落情衣:BAAAKgAFFAYIBAAAAA==.',['千穗']='千穗:BAAAKgAECgMIAwAAAA==.',['千金']='千金买邻:BAABKgAECn8kAAMBAAgIhRJScQBzAQABAAgIhRJScQBzAQAYAAUItAgzRwBgAAAAAA==.',['半面']='半面痴狂:BAACKgAFFH8KAAINAAMIrBBxJACHAAANAAMIrBBxJACHAAAqAAQKfycAAg0ACAjKHbENAFMCAA0ACAjKHbENAFMCAAAA.',['单蓝']='单蓝色:BAABKgAFFH8IAAIbAAMIQB62CwDvAAAbAAMIQB62CwDvAAAAAA==.',['卡卡']='卡卡干:BAACKgAFFH8NAAIWAAQIHyCCCwC/AAAWAAQIHyCCCwC/AAAqAAQKfxgAAxYACAimHagPACYCABYACAimHagPACYCABoAAQizH4+EAFkAAAAA.',['卡巴']='卡巴内瑞:BAAAKgADCgEIAQAAAA==.',['双刀']='双刀贼:BAABKgAFFH8QAAMcAAYIAReCDQD1AAAcAAYIoxOCDQD1AAAUAAEI8RU6JwBKAAAAAA==.',['发疯']='发疯天:BAAAKgADCggICAAAAA==.',['变起']='变起花样整:BAAAKgADCggICAAAAA==.',['叶师']='叶师兄:BAABKgAFFH8JAAIKAAMI9gdLGAClAAAKAAMI9gdLGAClAAAAAA==.',['司马']='司马仙:BAABKgAFFH8GAAIPAAYIIwULFQD9AAAPAAYIIwULFQD9AAAAAA==.',['听歌']='听歌的希瓦:BAAAKgAECgMIAwAAAA==.',['吻心']='吻心雕龍:BAAAKgADCgIIAgAAAA==.吻心雕龙:BAAAKgAECgEIAQAAAA==.',['呆小']='呆小萌可爱:BAABKgAFFH8KAAIBAAcIYBUwCwAUAgABAAcIYBUwCwAUAgAAAA==.',['哆丶']='哆丶啦:BAAAKgAECgQIBwAAAA==.',['哈托']='哈托尔:BAABKgAFFH8IAAMdAAgIlg/9AgBsAQAdAAYIkxP9AgBsAQAcAAIIngUWOgCIAAABKgAFFAgICQACAE8SAA==.',['哈起']='哈起一坨:BAAAKgAECgEIAQAAAA==.',['哲别']='哲别:BAAAKgAECggICAAAAA==.',['唉沐']='唉沐踢:BAAAKgADCgUIBQAAAA==.',['唯我']='唯我忆风尘:BAAAKgADCggICAAAAA==.',['喝水']='喝水的阿昆达:BAAAKgAECggICAAAAA==.',['喵突']='喵突突:BAAAKgAFFAMIAwAAAA==.',['嘚比']='嘚比嘚的德:BAACKgAFFH8nAAIHAAUIGiMMEQCXAQAHAAUIGiMMEQCXAQAqAAQKf0QABAcACAjwJWoDAAcDAAcACAjwJWoDAAcDAB4ACAhyESUPAFwBAB8AAgitD7AjAIoAAAAA.',['嘟嘟']='嘟嘟抓宝宝:BAAAKgAFFAIIAwAAAA==.',['嚎叫']='嚎叫的肥肥熊:BAAAKgADCgYIBgAAAA==.',['因为']='因为所以:BAAAKgAFFAMIBAAAAA==.',['圈圈']='圈圈波比:BAAAKgADCgMIAwAAAA==.',['圐圙']='圐圙:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光洗礼:BAAAKgAECgQIBAAAAA==.',['圥忈']='圥忈甲:BAAAKgAECgUIBQAAAA==.',['地狱']='地狱鬼嚎:BAACKgAFFH8PAAMWAAQI2xX+EACXAAAWAAIIABL+EACXAAAaAAIIkh2SJgBWAAAqAAQKfxUAAxYACAilGVQpAG8BABoACAjyDy88AIcBABYABgiSGlQpAG8BAAAA.',['埃尔']='埃尔梅罗二世:BAAAKgADCgQIBAAAAA==.',['塔丽']='塔丽拉:BAABKgAECn8lAAIHAAgIaiMuBQCxAgAHAAgIaiMuBQCxAgAAAA==.',['塞赫']='塞赫美特:BAAAKgAFFAIIAgABKgAFFAgICQACAE8SAA==.',['夜丨']='夜丨夢姨:BAAAKgAECgIIAgAAAA==.',['夜之']='夜之璀璨:BAAAKgAFFAIIAgAAAA==.',['夜幕']='夜幕之刃:BAACKgAFFH8GAAISAAMIuwSiFQCAAAASAAMIuwSiFQCAAAAqAAQKfxcAAhIACAgJDXAjAFUBABIACAgJDXAjAFUBAAAA.',['夜影']='夜影晨夕:BAABKgAFFH8GAAIXAAYIrQ1uFgAwAQAXAAYIrQ1uFgAwAQAAAA==.',['夜思']='夜思苏虹:BAAAKgADCgIIAgAAAA==.',['大个']='大个儿:BAACKgAFFH8TAAIOAAYI3hdxCAAUAQAOAAYI3hdxCAAUAQAqAAQKfxgAAg4ABwg5Gmc9AJABAA4ABwg5Gmc9AJABAAAA.',['大姐']='大姐姐丨:BAAAKgAECggICAAAAA==.',['天亡']='天亡天下:BAABKgAFFH8FAAIXAAMIXQMgIQB7AAAXAAMIXQMgIQB7AAAAAA==.',['天官']='天官八:BAAAKgADCgcIBwAAAA==.',['天树']='天树:BAABKgAFFH8LAAIFAAQIKRGyLQDEAAAFAAQIKRGyLQDEAAAAAA==.',['天福']='天福元宝:BAAAKgAECgUIBQAAAA==.',['天谴']='天谴之光:BAAAKgAECggIEAAAAA==.',['天车']='天车上搞锤子:BAACKgAFFH8HAAMCAAIImQvlVQBVAAACAAIImQvlVQBVAAAIAAEIVA3hJwBDAAAqAAQKfxYAAwgACAjzHJZJAPcAAAIABghuHBOEACsBAAgABggUFZZJAPcAAAAA.',['失落']='失落寒冬:BAAAKgAECgYIBgAAAA==.',['奈何']='奈何一叶知秋:BAAAKgAFFAgIAwAAAA==.奈何雪落无声:BAAAKgAFFAYIBAAAAA==.',['奈芙']='奈芙蒂斯:BAABKgAFFH8JAAICAAgITxLlBgAXAgACAAgITxLlBgAXAgAAAA==.',['奕傷']='奕傷:BAAAKgAFFAIIAgAAAA==.',['奥格']='奥格带头大哥:BAAAKgAECggICAAAAA==.',['奶油']='奶油沼泽岛:BAAAKgAECggIDAAAAA==.',['奶锤']='奶锤:BAACKgAFFH8YAAIbAAQIyxwjCwD3AAAbAAQIyxwjCwD3AAAqAAQKfxUAAhsACAjqHz8GAIgCABsACAjqHz8GAIgCAAAA.',['她摸']='她摸我:BAACKgAFFH8JAAIHAAMI3AqXQgCjAAAHAAMI3AqXQgCjAAAqAAQKfxcAAwcACAiCEcVMAIQBAAcACAiCEcVMAIQBAAYABAgbAh6DADsAAAAA.',['如此']='如此肆意妄为:BAAAKgAECgYIBgAAAA==.',['妮特']='妮特丽:BAAAKgAFFAQIBAAAAA==.',['守猎']='守猎者:BAAAKgADCggICAAAAA==.',['安舍']='安舍:BAACKgAFFH8fAAIBAAQIwCG+MwAaAQABAAQIwCG+MwAaAQAqAAQKfz8AAgEACAiSJHANAOMCAAEACAiSJHANAOMCAAAA.',['宋老']='宋老师:BAABKgAFFH8GAAIWAAMIMQa1DwCbAAAWAAMIMQa1DwCbAAAAAA==.',['富贵']='富贵:BAAAKgADCggICQAAAA==.',['寒瞳']='寒瞳若影:BAABKgAFFH8GAAIBAAYISSQUDgD0AQABAAYISSQUDgD0AQAAAA==.',['射穿']='射穿他的心脏:BAAAKgAECgMIBQAAAA==.',['小呆']='小呆爷爷:BAAAKgAECgcIBwAAAA==.',['小呵']='小呵呵:BAAAKgAFFAYIAQAAAA==.',['小小']='小小护士:BAAAKgAFFAIIAgAAAA==.',['小屋']='小屋的俩人:BAAAKgAECggIEQAAAA==.小屋的倆人:BAAAKgAECggIEwAAAA==.',['小汤']='小汤圆软软:BAABKgAFFH8PAAIBAAYI0yUFCgAjAgABAAYI0yUFCgAjAgAAAA==.',['小涵']='小涵涵:BAABKgAFFH8GAAIYAAYIyRKuDwAIAQAYAAYIyRKuDwAIAQABKgAFFAgIDAAYAB4TAA==.',['小胖']='小胖沐沐:BAAAKgAFFAQIAwAAAA==.',['小黄']='小黄杏拿铁:BAAAKgAECggICAAAAA==.',['就地']='就地正法:BAAAKgAECgEIAQAAAA==.',['就想']='就想瘦一斤:BAAAKgAECgUIBQAAAA==.',['尸宴']='尸宴:BAAAKgAFFAIIAgAAAA==.',['尹月']='尹月行:BAAAKgAECgEIAQAAAA==.',['山哥']='山哥来啦:BAABKgAFFH8GAAMZAAYI8gPqEAB2AAAZAAQIbQXqEAB2AAAaAAIIugHZGwBkAAAAAA==.',['山洪']='山洪谈锋:BAAAKgADCggIEAAAAA==.',['岁月']='岁月挽歌:BAAAKgAECgcIBwAAAA==.',['崽崽']='崽崽:BAAAKgAECgEIAQAAAA==.',['左老']='左老师:BAABKgAFFH8GAAIIAAYIMgaxIQDsAAAIAAYIMgaxIQDsAAABKgAFFAgIDAACAL0UAA==.',['布衣']='布衣买清闲:BAAAKgAECgYICQAAAA==.',['帅气']='帅气野牛:BAABKgAFFH8JAAIHAAMI5A7vPgCuAAAHAAMI5A7vPgCuAAAAAA==.',['希尔']='希尔妲:BAAAKgAFFAIIAgAAAA==.希尔瓦纳丝:BAAAKgAECgUIBQAAAA==.希尔莉亚:BAAAKgAECggICAAAAA==.',['幸福']='幸福陪伴你:BAAAKgAECgUIBQAAAA==.',['康康']='康康兔:BAABKgAFFH8JAAMcAAYICxf6FQBUAQAcAAYICxf6FQBUAQAUAAIIswt3KgBFAAAAAA==.',['廢黯']='廢黯:BAACKgAFFH8HAAIBAAMIrg1FJwDVAAABAAMIrg1FJwDVAAAqAAQKfx4AAgEABwimINRFAB4CAAEABwimINRFAB4CAAAA.',['异曈']='异曈:BAACKgAFFH8NAAIBAAQIBRXiHADwAAABAAQIBRXiHADwAAAqAAQKfxYAAgEACAiGDrE3AC0BAAEACAiGDrE3AC0BAAEqAAUUCAgKAAEArSUA.',['张沉']='张沉心丶:BAABKgAFFH8MAAIBAAQIxhsrSADeAAABAAQIxhsrSADeAAABKgAFFAgIEQAYAFUbAA==.',['弹得']='弹得得丶:BAAAKgAECggICgAAAA==.',['從不']='從不曾放棄:BAAAKgADCgYIBgAAAA==.',['御丶']='御丶:BAAAKgAECgQIBAAAAA==.',['御法']='御法终成仙:BAAAKgAECgYIBwAAAA==.',['御风']='御风亚索:BAAAKgAECgIIBQAAAA==.',['德鲁']='德鲁斯特:BAAAKgAFFAMIAwAAAA==.',['快驱']='快驱散:BAABKgAFFH8FAAIcAAUIfRtOGwAsAQAcAAUIfRtOGwAsAQAAAA==.',['恨世']='恨世龙之泪:BAABKgAFFH8OAAIGAAMISBTCHwCtAAAGAAMISBTCHwCtAAAAAA==.',['恶魔']='恶魔一芭芭塔:BAAAKgAECgYIBgAAAA==.',['憨憨']='憨憨德鲁咦:BAAAKgADCgMIAwAAAA==.憨憨萨满:BAABKgAFFH8IAAIgAAgIPRoXAgBvAgAgAAgIPRoXAgBvAgAAAA==.',['成都']='成都市战神:BAABKgAFFH8JAAIBAAMI3hh4RQDjAAABAAMI3hh4RQDjAAAAAA==.成都武侯崽崽:BAAAKgAFFAMIAwAAAA==.',['我只']='我只能卖萌:BAABKgAFFH8MAAIHAAQIKRfZKwDjAAAHAAQIKRfZKwDjAAAAAA==.',['我怎']='我怎能不變態:BAAAKgAECgUIBQAAAA==.',['我最']='我最亲爱的:BAAAKgADCgUIBQAAAA==.',['我爱']='我爱喝大窑:BAAAKgAECgYICAAAAA==.',['战神']='战神老白:BAAAKgAECgUIBQAAAA==.',['手法']='手法极其刺激:BAAAKgAECgEIAQAAAA==.',['拣月']='拣月亮:BAAAKgADCgYIBgAAAA==.',['提拉']='提拉米蘇:BAAAKgADCgQIBAAAAA==.',['收你']='收你们来了:BAAAKgAECggIDgAAAA==.',['新有']='新有菜桑:BAAAKgADCgQIBAAAAA==.',['旋风']='旋风冰火:BAAAKgAECggIDwAAAA==.旋风大锤:BAAAKgAFFAQIBAAAAA==.',['无一']='无一名:BAAAKgAECgUIBgAAAA==.',['无名']='无名小卒:BAAAKgAECgUIBgAAAA==.',['无限']='无限绵延的心:BAABKgAFFH8GAAIMAAMI7Qm4GgCpAAAMAAMI7Qm4GgCpAAAAAA==.',['旧梦']='旧梦时有你:BAAAKgADCgEIAQAAAA==.',['旺财']='旺财小吗:BAACKgAFFH8KAAIDAAMIgBLQKACfAAADAAMIgBLQKACfAAAqAAQKfycAAwMACAiUGesbAPkBAAMACAiMGesbAPkBAAQABggRFJI/ABkBAAAA.',['昆仑']='昆仑镜:BAACKgAFFH8WAAIbAAUI0iJ7AgAuAQAbAAUI0iJ7AgAuAQAqAAQKfy4AAhsACAjdJAYCANgCABsACAjdJAYCANgCAAAA.',['明会']='明会不会来:BAAAKgADCgUIBQAAAA==.',['春风']='春风一露:BAAAKgADCgEIAQAAAA==.',['昭月']='昭月炫星辰:BAAAKgAECgYIBwAAAA==.',['是大']='是大叔啊:BAABKgAFFH8HAAIgAAMIaBeMEgDUAAAgAAMIaBeMEgDUAAAAAA==.',['暖风']='暖风吹:BAAAKgADCgMIAwAAAA==.',['暗夜']='暗夜猎者:BAAAKgAECgcIDwAAAA==.',['最后']='最后的游灵:BAAAKgAECgEIAQAAAA==.',['月影']='月影成双:BAABKgAFFH8GAAMXAAMIegQPOACCAAAXAAMItgMPOACCAAAMAAIIhwVtJgBhAAAAAA==.',['有个']='有个黑铁骑士:BAAAKgADCggIDAAAAA==.',['杀戮']='杀戮海豹:BAAAKgADCggICAAAAA==.',['杀死']='杀死蛋蛋:BAAAKgAFFAQIBAAAAA==.',['杀破']='杀破无敌:BAAAKgAECgcIBwAAAA==.',['村头']='村头大美丽:BAABKgAFFH8FAAIgAAMI+A1DFwC7AAAgAAMI+A1DFwC7AAAAAA==.',['枫芝']='枫芝刃舞:BAAAKgAECgEIAQAAAA==.',['柚守']='柚守昊娴:BAAAKgAECggICAAAAA==.',['柠檬']='柠檬奶油包:BAACKgAFFH8LAAIMAAMIFSGADwDmAAAMAAMIFSGADwDmAAAqAAQKfx4AAwwACAgOIrEQAHoCAAwACAi4ILEQAHoCAAsACAg0HHIcAEkCAAAA.',['栗子']='栗子球:BAAAKgAFFAEIAQAAAA==.',['桃兔']='桃兔兔:BAABKgAFFH8NAAMEAAMIOCE4EQAVAQAEAAMIOCE4EQAVAQADAAIItQRpHgBoAAAAAA==.',['桃夭']='桃夭:BAAAKgAECgQIBAAAAA==.',['桑格']='桑格云盾:BAAAKgAFFAYIAwAAAA==.',['梦回']='梦回八千里路:BAAAKgAFFAQIAQABKgAFFAgIAgAVAAAAAA==.',['梦娴']='梦娴:BAAAKgAECggIEAAAAA==.',['梦灵']='梦灵画银潭:BAAAKgAECgYIEAAAAA==.',['梦醒']='梦醒人未觉丶:BAABKgAECn8kAAIaAAgIfCJ6EQBRAgAaAAgIfCJ6EQBRAgAAAA==.',['梨三']='梨三蒸三酿:BAAAKgAECgYIBwAAAA==.',['梨天']='梨天行:BAAAKgAECgcIDAAAAA==.',['梨留']='梨留香:BAABKgAECn8XAAICAAgIphaoFQDYAQACAAgIphaoFQDYAQAAAA==.',['椰子']='椰子蟹:BAAAKgADCggICAAAAA==.',['楚芙']='楚芙丽叶:BAAAKgAECgIIAgAAAA==.',['榴莲']='榴莲果酱丶:BAABKgAFFH8KAAMGAAgICAxuBwCZAQAGAAgICAxuBwCZAQAHAAIIehMSRwCTAAAAAA==.',['横贯']='横贯八方:BAAAKgADCggICAAAAA==.',['橙小']='橙小雨:BAAAKgADCgMIAwAAAA==.橙小麦:BAABKgAFFH8HAAMIAAcIUBVQGQAgAQAIAAQIaxJQGQAgAQACAAMIGhuQKACuAAAAAA==.',['橙熟']='橙熟:BAACKgAFFH8RAAIYAAMIbwb4IgBtAAAYAAMIbwb4IgBtAAAqAAQKfxQAAhgACAh8CkYqAAMBABgACAh8CkYqAAMBAAAA.',['欧泡']='欧泡果奶:BAAAKgAFFAQIBAAAAA==.',['武侯']='武侯区崽崽:BAAAKgAFFAIIAgAAAA==.',['汐无']='汐无忧:BAABKgAFFH8ZAAISAAgIphYHBQBEAgASAAgIphYHBQBEAgAAAA==.',['沐浴']='沐浴在阳光下:BAABKgAFFH8IAAMCAAYIbwmDGgAsAQACAAYIbwmDGgAsAQAIAAEIKASkVgAoAAAAAA==.',['没穿']='没穿裤子:BAAAKgAECggIEwAAAA==.',['油炸']='油炸花生米:BAAAKgAECgMIAwAAAA==.',['流星']='流星冰雨:BAAAKgADCgUIBwAAAA==.',['流浪']='流浪在远方:BAABKgAFFH8IAAIIAAgIVht4AwBjAgAIAAgIVht4AwBjAgAAAA==.',['浪漫']='浪漫的莽子:BAACKgAFFH8SAAMaAAQIrBFHJgC1AAAaAAQIQQhHJgC1AAAWAAII0RTwHwCPAAAqAAQKfxgABBYACAhuGVYWAAMCABYACAiqF1YWAAMCABoABgiBF1k+ACQBABkABAh8Ca4+AGEAAAAA.',['消毒']='消毒水:BAABKgAECn8WAAIOAAcIRRaQQgBsAQAOAAcIRRaQQgBsAQAAAA==.',['淡看']='淡看江湖丶:BAABKgAFFH8NAAMYAAYInhX+EQDuAAABAAQIZB77HQD1AAAYAAYITwz+EQDuAAAAAA==.',['淮南']='淮南良好市民:BAAAKgAFFAQIBAAAAA==.',['深秋']='深秋的蝎子:BAAAKgADCgIIAgAAAA==.',['混世']='混世星雨留年:BAABKgAECn8XAAIgAAgIXxf/CQD3AQAgAAgIXxf/CQD3AQAAAA==.',['淺倉']='淺倉北北:BAABKgAFFH8FAAICAAMIOBdHFwDyAAACAAMIOBdHFwDyAAAAAA==.',['淺凔']='淺凔北北:BAAAKgADCgEIAQAAAA==.',['淺瑲']='淺瑲北北:BAAAKgAECgIIAgAAAA==.',['淺篬']='淺篬北北:BAAAKgAECgQIBAAAAA==.',['清闲']='清闲布衣:BAAAKgADCgMIAwAAAA==.',['渡渡']='渡渡鸟杀手:BAAAKgAFFAQIBAAAAA==.',['漠烟']='漠烟烟:BAACKgAFFH8JAAILAAMI2xH7HQDCAAALAAMI2xH7HQDCAAAqAAQKfyYAAwsACAijG44mAA8CAAsACAhSG44mAA8CAAwAAwjRGOCLAHYAAAEqAAUUCAgFAAsAxBIA.',['漫游']='漫游者老刘:BAAAKgADCgUIBQAAAA==.',['灬小']='灬小雪:BAAAKgADCgEIAQAAAA==.',['灬风']='灬风:BAAAKgAECgMIAwAAAA==.',['灭亡']='灭亡迅雷:BAAAKgAECggICAAAAA==.',['灵异']='灵异之血:BAAAKgAECgcIDQAAAA==.',['灾厄']='灾厄之星提丰:BAABKgAECn8ZAAIIAAgIZyMKDQCTAgAIAAgIZyMKDQCTAgAAAA==.',['点子']='点子王:BAABKgAFFH8SAAMKAAgIgB6SAgCJAgAKAAgIgB6SAgCJAgANAAQIoArbFQCeAAAAAA==.',['烤牛']='烤牛排:BAACKgAFFH8sAAMLAAUIQSXrCQCZAQALAAUIHiXrCQCZAQAXAAQIfCWEEwBJAQAqAAQKf1gAAwsACAhNJuUFAOMCAAsACAjDJeUFAOMCABcACAixJS0GANkCAAAA.',['热爱']='热爱玉鼠:BAAAKgAFFAgIBAAAAA==.',['爆米']='爆米花二号:BAAAKgAFFAQIBAAAAA==.',['爆酱']='爆酱:BAABKgAECn8hAAIIAAgIpyC2EgA+AgAIAAgIpyC2EgA+AgAAAA==.',['爱吸']='爱吸雷子:BAAAKgAECgUICAAAAA==.',['爱思']='爱思唯尔:BAAAKgAFFAIIAgAAAA==.',['爱神']='爱神丘比特:BAABKgAFFH8MAAMCAAYIvRQAEwBeAQACAAYIvRQAEwBeAQAIAAQIDQywEgDKAAAAAA==.',['牧小']='牧小豆:BAACKgAFFH8IAAMEAAgIYRO5DgAxAQAEAAUIxwq5DgAxAQADAAMI2h5kGQDtAAAqAAQKfxkAAwMACAjmEQk8AEsBAAMACAj5Dgk8AEsBAAQAAgiCEMVwAE0AAAAA.',['牧有']='牧有名字:BAABKgAFFH8GAAIEAAYINBMhCwBjAQAEAAYINBMhCwBjAQAAAA==.',['狂暴']='狂暴丶战:BAAAKgAECggICAAAAA==.',['狂若']='狂若狼月:BAAAKgAECgQIBAAAAA==.',['狐灬']='狐灬小戰:BAAAKgAFFAMIAwAAAA==.',['狼丶']='狼丶殇:BAAAKgADCgQIBAAAAA==.',['狼兄']='狼兄:BAACKgAFFH8XAAIKAAMIIxCcNADEAAAKAAMIIxCcNADEAAAqAAQKfxsAAgoACAihHrIVAF4CAAoACAihHrIVAF4CAAAA.',['狼牙']='狼牙轰轰拳:BAABKgAFFH8IAAINAAgIewuECQB9AQANAAgIewuECQB9AQAAAA==.',['猪大']='猪大娘:BAAAKgAECgEIAQAAAA==.',['玖伍']='玖伍貮柒:BAAAKgAECgIIAgAAAA==.',['玖尾']='玖尾奶魅:BAABKgAFFH8OAAIOAAMIsRk0KADVAAAOAAMIsRk0KADVAAAAAA==.',['玩咩']='玩咩啊:BAABKgAFFH8JAAIHAAQINiJIDgADAQAHAAQINiJIDgADAQABKgAFFAgICgAGAO0VAA==.',['瑪维']='瑪维:BAAAKgAECgUIBQAAAA==.',['瓜天']='瓜天蛆影:BAABKgAFFH8JAAMJAAMInAmNDACyAAAJAAMIyweNDACyAAAKAAIINgkJVAA/AAAAAA==.',['生胖']='生胖气:BAAAKgADCgEIAQAAAA==.',['男神']='男神你山哥:BAABKgAFFH8GAAIOAAQIWxdADwDoAAAOAAQIWxdADwDoAAAAAA==.',['病毒']='病毒疫苗:BAAAKgAFFAIIAgAAAA==.',['痞子']='痞子丶笨蛋:BAABKgAFFH8IAAIXAAgIQR/MAgCaAgAXAAgIQR/MAgCaAgAAAA==.',['瘟到']='瘟到死岔劈:BAAAKgAECgQIBAAAAA==.',['瘾修']='瘾修者博恩:BAABKgAFFH8IAAMcAAcIvhbtEQDdAAAcAAYIvhbtEQDdAAAdAAEIAABlJAAAAAAAAA==.',['白鹭']='白鹭先生:BAAAKgADCgUIBQAAAA==.',['皓丶']='皓丶月:BAAAKgAECgIIAgAAAA==.',['看似']='看似简单快乐:BAAAKgADCgQIBAAAAA==.',['砍爆']='砍爆:BAABKgAECn8UAAMaAAgI3yTIDQB3AgAaAAYIAyTIDQB3AgAWAAcI/yRJCwBgAgABKgAFFAYICQABAJogAA==.',['砍瓜']='砍瓜切菜蔬:BAAAKgAFFAgIBAAAAA==.',['祖公']='祖公威武:BAABKgAECn8ZAAMJAAcIxxdbEQCTAQAJAAcIxxdbEQCTAQAKAAMI5AeSmABkAAAAAA==.',['神丨']='神丨殇:BAABKgAECn8gAAIBAAgIlCC4SgARAgABAAgIlCC4SgARAgABKgAFFAgIDwAhAC4bAA==.',['祥云']='祥云:BAAAKgAECgYIBgAAAA==.',['突然']='突然乂乂:BAAAKgAECgYIBgAAAA==.',['突突']='突突斩:BAACKgAFFH8NAAIWAAMIGiAhEgD2AAAWAAMIGiAhEgD2AAAqAAQKfysAAhYACAg5JV4CAPcCABYACAg5JV4CAPcCAAAA.',['筱筱']='筱筱灬牧:BAABKgAFFH8JAAIEAAcI+xNLBgDKAQAEAAcI+xNLBgDKAQAAAA==.',['米宝']='米宝儿:BAAAKgAFFAQIBAABKgAFFAgIBAAVAAAAAA==.',['米希']='米希卡:BAAAKgAECgQIBAAAAA==.',['米菲']='米菲小麒:BAABKgAECn8YAAIFAAgIDBqbKgC9AQAFAAgIDBqbKgC9AQAAAA==.',['粪海']='粪海萌蛆:BAAAKgAECgUIDAAAAA==.',['糊涂']='糊涂塌客:BAAAKgAECgcIBwAAAA==.',['素裕']='素裕:BAAAKgAFFAQIBAAAAA==.',['索林']='索林橡木盾:BAAAKgAFFAIIAgAAAA==.',['繆大']='繆大将军:BAABKgAECn8XAAIIAAYIuwdvXACuAAAIAAYIuwdvXACuAAAAAA==.',['红唇']='红唇高跟鞋:BAAAKgAECggIEgAAAA==.',['红肠']='红肠九块肌:BAAAKgAFFAIIBAAAAA==.',['终誓']='终誓骑士:BAABKgAECn8YAAMBAAgIMBVzbADAAQABAAgIMBVzbADAAQAbAAEIuAHSWAAJAAAAAA==.',['给我']='给我一支烟:BAAAKgADCgUIBQAAAA==.',['统统']='统统:BAAAKgAECgUIBQAAAA==.',['绿的']='绿的就是好的:BAAAKgADCgEIAQAAAA==.',['羊羊']='羊羊爱咩咩:BAAAKgAECgIIAgAAAA==.',['老登']='老登你要起舞:BAAAKgAECgEIAQAAAA==.',['胡椒']='胡椒蒸虾头:BAAAKgADCggICAAAAA==.',['脆弱']='脆弱易碎:BAABKgAECn8ZAAIBAAgIZh8XLgBHAgABAAgIZh8XLgBHAgAAAA==.',['花内']='花内酷:BAAAKgAECggIEAAAAA==.',['花奇']='花奇奇:BAAAKgAFFAMIAwAAAA==.',['花街']='花街龙少:BAACKgAFFH8HAAIhAAcIIwAYHQBFAAAhAAcIIwAYHQBFAAAqAAQKfyUAAyEACAhUH5cCAJUCACEACAhUH5cCAJUCAA4AAQhsBQFUACMAAAAA.',['苍白']='苍白之翼:BAAAKgAECgUIBgAAAA==.',['范德']='范德彪:BAAAKgAFFAgIBAAAAA==.',['范特']='范特西施:BAAAKgAECggICgAAAA==.',['荒堂']='荒堂:BAABKgAFFH8GAAIFAAMIpSJ+HgAPAQAFAAMIpSJ+HgAPAQAAAA==.',['荷兰']='荷兰凤凰:BAAAKgAECgQIBAAAAA==.',['荼啊']='荼啊:BAACKgAFFH8FAAIDAAQIHw+MJgCoAAADAAQIHw+MJgCoAAAqAAQKfxgAAwMACAhmFGUwAGEBAAMACAhmFGUwAGEBACIAAghVDO5TAF4AAAAA.',['莉莉']='莉莉斯:BAAAKgADCgYIBgAAAA==.',['菲乐']='菲乐:BAAAKgAECggICAAAAA==.',['菲楽']='菲楽:BAACKgAFFH8VAAMBAAYIVhwUDAAkAQABAAYIixkUDAAkAQAYAAYIRhMaDgAbAQAqAAQKfxUABAEACAjhHxJRAAACAAEACAjhHxJRAAACABsAAwisBzE8AJgAABgAAQgcBAdrAA8AAAAA.',['萌萝']='萌萝莉:BAAAKgADCgYIBgAAAA==.',['萨菲']='萨菲:BAABKgAFFH8GAAMCAAMIRAzENgC7AAACAAMIRAzENgC7AAAIAAEIegGoKwAeAAAAAA==.',['蓅哖']='蓅哖丶似氺:BAAAKgAFFAQIBAAAAA==.',['蓝色']='蓝色滴天空灬:BAAAKgAECgUIBwAAAA==.',['蛋蛋']='蛋蛋的忧伤啊:BAABKgAECn8XAAMFAAgI5RPpPABdAQAFAAcIChTpPABdAQAjAAYIjg6XQgC2AAAAAA==.',['血祭']='血祭苍天:BAAAKgAFFAYIAgABKgAFFAgIEwAPAE0iAA==.',['被偷']='被偷的小贼:BAAAKgADCgMIAwAAAA==.',['西丁']='西丁卡特尔:BAAAKgADCgYIBgAAAA==.',['西红']='西红柿炒饭:BAAAKgAFFAIIAgAAAA==.',['西门']='西门大官人:BAABKgAFFH8FAAIBAAMIxgmIZwCeAAABAAMIxgmIZwCeAAAAAA==.',['诗与']='诗与胡说:BAABKgAFFH8IAAIFAAYIYhPiAgC6AQAFAAYIYhPiAgC6AQAAAA==.',['豆浆']='豆浆油条:BAABKgAFFH8HAAMLAAUIsSK/AQASAgALAAUIsSK/AQASAgAMAAII8xRBEgCXAAAAAA==.',['貂皮']='貂皮德:BAAAKgADCgIIAwAAAA==.',['贝尔']='贝尔纳缇塔:BAAAKgAFFAIIAgAAAA==.贝尔蒙特:BAAAKgAECgEIAQAAAA==.',['赛仁']='赛仁贵:BAAAKgADCgEIAgAAAA==.',['踢你']='踢你噢哞丁:BAAAKgAFFAQIBAAAAA==.',['轰隆']='轰隆医生:BAABKgAFFH8KAAIRAAMI7w6CIwCyAAARAAMI7w6CIwCyAAAAAA==.',['进击']='进击的墨西哥:BAAAKgAECgcICQAAAA==.',['迦拉']='迦拉克龙:BAAAKgADCgEIAQAAAA==.',['迷人']='迷人二哥:BAAAKgADCgEIAQAAAA==.',['追光']='追光:BAAAKgAECggIDAAAAA==.',['逆天']='逆天之自来也:BAABKgAECn8dAAILAAgIZg32QgB+AQALAAgIZg32QgB+AQAAAA==.',['逍遥']='逍遥酒半仙:BAAAKgAFFAEIAQAAAA==.',['遇术']='遇术临疯丷:BAAAKgAECgYIBgAAAA==.',['邪百']='邪百万:BAABKgAECn8bAAIKAAYIPBuNRwCWAQAKAAYIPBuNRwCWAQAAAA==.',['郭达']='郭达斯坦森:BAAAKgADCgcIBwAAAA==.',['配角']='配角演员:BAAAKgAECgYIBgAAAA==.',['重机']='重机枪:BAAAKgAFFAEIAgAAAA==.',['野性']='野性小萨:BAAAKgAECgcIDgAAAA==.野性驻铁使者:BAABKgAECn8lAAIOAAgIhCGHDQCCAgAOAAgIhCGHDQCCAgAAAA==.',['钢铁']='钢铁狐狸:BAAAKgADCgQIBAAAAA==.',['钩吻']='钩吻:BAAAKgAECgQIBAABKgAFFAMIEQAYAG8GAA==.',['长手']='长手加鲁鲁:BAAAKgAFFAYIAQAAAA==.',['长脸']='长脸皮:BAABKgAFFH8GAAINAAYIPAbUGwDEAAANAAYIPAbUGwDEAAAAAA==.',['闲音']='闲音散曲:BAAAKgAECgUIBgAAAA==.',['阁下']='阁下如何应对:BAAAKgADCgIIAgAAAA==.',['防空']='防空洞:BAAAKgAECgQIBAAAAA==.',['阴天']='阴天晒太阳:BAAAKgAECggICAAAAA==.',['阿华']='阿华田:BAAAKgADCggIGAAAAA==.',['陈厂']='陈厂长冰冰冻:BAAAKgAECggICAAAAA==.陈厂长喝奶酒:BAAAKgAECgMIAwAAAA==.',['陈汉']='陈汉生:BAABKgAFFH8MAAIgAAMIQxVpEgDVAAAgAAMIQxVpEgDVAAAAAA==.',['除心']='除心魔:BAAAKgAECgEIAQAAAA==.',['随风']='随风而逝丶:BAAAKgAFFAQIBAAAAA==.随风躲猫猫:BAAAKgAECgEIAQAAAA==.',['隔壁']='隔壁老程:BAAAKgAECgIIAgAAAA==.',['雕炸']='雕炸天:BAAAKgADCggICAAAAA==.',['雪月']='雪月丶风花:BAAAKgAFFAEIAQAAAA==.',['雪柔']='雪柔琉璃:BAAAKgAECgcIDQAAAA==.',['雷霆']='雷霆牛:BAACKgAFFH8KAAIJAAMISxABBgCTAAAJAAMISxABBgCTAAAqAAQKfyEAAgkACAhPHZIHAEcCAAkACAhPHZIHAEcCAAAA.',['震天']='震天怒:BAAAKgAECgUIBgAAAA==.',['霜舞']='霜舞沐琉苏:BAAAKgAECgUIBwAAAA==.',['青羊']='青羊区射神:BAABKgAFFH8YAAICAAMI+CLRGgAqAQACAAMI+CLRGgAqAQAAAA==.',['靓坤']='靓坤:BAABKgAFFH8GAAIBAAQI3xQnIQDmAAABAAQI3xQnIQDmAAAAAA==.',['非乐']='非乐:BAABKgAFFH8OAAIFAAYI+x5eDADAAQAFAAYI+x5eDADAAQAAAA==.',['非楽']='非楽:BAABKgAFFH8aAAMIAAYIrR6tDQCAAQAIAAYIQButDQCAAQACAAQIqyOoDQAZAQAAAA==.',['韩式']='韩式炒年糕:BAABKgAFFH8IAAIRAAYIISHJCADtAQARAAYIISHJCADtAQAAAA==.',['韩盗']='韩盗:BAAAKgAECggIDQAAAA==.',['風花']='風花丶雪月:BAAAKgAECggICAAAAA==.',['风中']='风中奇冤:BAAAKgAECgEIAQAAAA==.风中奇原:BAAAKgAECggIEQAAAA==.风中奇媛图腾:BAAAKgAECgcICgAAAA==.风中奇瑗:BAAAKgAECgIIAwAAAA==.',['风之']='风之幻影:BAAAKgADCggICAAAAA==.',['风暴']='风暴龙王:BAABKgAFFH8HAAIRAAcIUxCpLAB/AAARAAcIUxCpLAB/AAABKgAFFAgIDQAIANEcAA==.',['飘落']='飘落秋叶:BAAAKgAECgcIDQAAAA==.',['飛影']='飛影覓潺悠:BAAAKgAECgcICgAAAA==.',['骨头']='骨头盾:BAABKgAECn8jAAIZAAgIUBCJDgA3AQAZAAgIUBCJDgA3AQAAAA==.',['鬼刹']='鬼刹天戮:BAAAKgAECgEIAQAAAA==.',['魂淡']='魂淡:BAAAKgADCgEIAQAAAA==.',['魂霜']='魂霜:BAACKgAFFH8mAAINAAUIpw/GGADbAAANAAUIpw/GGADbAAAqAAQKf0IAAg0ACAh/GVMSANkBAA0ACAh/GVMSANkBAAAA.',['魔丨']='魔丨殇:BAAAKgAFFAgIAgAAAA==.',['魔法']='魔法张张包:BAAAKgAFFAQIBAAAAA==.',['麦笛']='麦笛文:BAAAKgAECgEIAQAAAA==.',['黑色']='黑色柳丁:BAAAKgAFFAQIBAAAAA==.',['黑锋']='黑锋之花:BAABKgAECn8ZAAQJAAgIKCIqBgBrAgAJAAgIKCIqBgBrAgAKAAYI5BkKXABTAQANAAMIaR/MSgCRAAAAAA==.',['龙井']='龙井:BAAAKgAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end