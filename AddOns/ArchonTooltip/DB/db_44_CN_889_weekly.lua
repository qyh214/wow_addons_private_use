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
 local lookup = {'Unknown-Unknown','DemonHunter-Havoc','DeathKnight-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Protection','Priest-Holy','Warrior-Protection','Warrior-Fury','Monk-Windwalker','Monk-Brewmaster','Shaman-Restoration','Shaman-Enhancement','Warlock-Destruction','Shaman-Elemental','Druid-Restoration','Hunter-Survival','Priest-Shadow','Mage-Arcane','DemonHunter-Vengeance','Paladin-Retribution','Druid-Balance','Mage-Fire','Mage-Frost','DeathKnight-Blood','Druid-Guardian','Paladin-Holy','Priest-Discipline','DeathKnight-Unholy','Warlock-Demonology','Rogue-Assassination','Druid-Feral','Evoker-Preservation','Evoker-Devastation','Rogue-Outlaw','Evoker-Augmentation',}; local provider = {region='CN',realm='鹰巢山',name='CN',type='weekly',zone=44,date='2025-12-10',data={Ad='Adawong:BAAALAAFFAIIAgAAAA==.',Al='Alexcjq:BAAALAAFFAIIAgAAAA==.',Am='Ameria:BAAALAAFFAIIAgAAAA==.Amora:BAAALAAFFAQIAwAAAA==.',An='Anima:BAAALAAECgIIBAAAAA==.',Ba='Batistuta:BAAALAAECgUIBQAAAA==.',Bu='Buibuibuibui:BAAALAAECgIIAgAAAA==.Buring:BAAALAAECgMIAwAAAA==.',Ca='Casillas:BAAALAAECggICgAAAA==.',Ch='Character:BAAALAAECggIAgABLAAFFAgIAgABAAAAAA==.Chrisp:BAAALAAFFAIIAgAAAA==.Chriswl:BAAALAAFFAIIAgAAAA==.',Dc='Dclxvi:BAAALAAFFAIIAgAAAA==.',De='Deaf:BAABLAAFFH8OAAICAAUIzhUvLAA9AQACAAUIzhUvLAA9AQAAAA==.Dearstan:BAAALAAECgYIBgAAAA==.',Du='Dulcis:BAAALAAECgYIBwAAAA==.',Ek='Eklampsus:BAAALAAECgQIBAAAAA==.',Em='Emocracy:BAABLAAFFH8aAAIDAAUITQ9fSAAgAQADAAUITQ9fSAAgAQAAAA==.',Ev='Evo:BAAALAAFFAEIAQAAAA==.',Ha='Handwin:BAACLAAFFH8sAAMEAAYIBCKIGADcAQAEAAYIASKIGADcAQAFAAIIpCPSEwDIAAAsAAQKfxkAAgUABwhqJZMTAMcCAAUABwhqJZMTAMcCAAAA.',Hc='Hcoo:BAAALAAECgEIAQAAAA==.',Ko='Kolant:BAAALAADCgQIBAAAAA==.',La='Lafayette:BAAALAAECgIIAgAAAA==.Lanfe:BAAALAAECggICQAAAA==.Langrisser:BAAALAAFFAMIAwAAAA==.',Li='Listendung:BAAALAADCgMIAwAAAA==.',Lo='Looe:BAAALAAFFAIIAgAAAA==.',Ma='Manner:BAAALAAECgYIBgAAAA==.Mathilde:BAAALAAECgYIDQAAAA==.',Mc='Mcga:BAAALAAFFAIIAgABLAAFFAMIBQAGAEMOAA==.',Me='Memeda:BAAALAAECgIIAgAAAA==.',Ms='Msuqq:BAABLAAFFH8GAAIHAAIICAQCQgBxAAAHAAIICAQCQgBxAAAAAA==.',Na='Nathaniel:BAAALAAECgQIBAAAAA==.',Os='Oswald:BAAALAADCgcICQAAAA==.',Ou='Outrage:BAAALAAECgYIEAAAAA==.',Pa='Papayatittie:BAAALAAECgMIAwAAAA==.',Re='Rescuer:BAAALAAECgQIBAAAAA==.',Sa='Sableye:BAAALAAECgYIDAAAAA==.Sagittaurus:BAAALAAECgMIAwAAAA==.Saman:BAAALAAECgYIDAAAAA==.Sawa:BAABLAAFFH8YAAMIAAYI/x5JCADEAQAIAAYI/x5JCADEAQAJAAUI0AEpNwCbAAAAAA==.',Si='Silas:BAABLAAFFH8FAAMKAAMIcg/gEgByAAAKAAMIcg/gEgByAAALAAIIBgyOGABsAAAAAA==.',Sk='Skyevil:BAAALAAECgQIBAAAAA==.',Ta='Tani:BAAALAAECgYIAQABLAAFFAYIGAAIAP8eAA==.',To='Tobacoo:BAAALAAECgIIAgAAAA==.',Tp='Tpoi:BAAALAAECgYIBgAAAA==.',Ty='Tyrus:BAAALAAFFAIIAgAAAA==.',Vi='Vive:BAAALAAECgYIBgAAAA==.',Wa='Warmsunshine:BAABLAAFFH8GAAMMAAIIhQIUbQBRAAAMAAIIhQIUbQBRAAANAAIIKhBcBwBAAAABLAAFFAcIIQACAMMXAA==.',Xe='Xellos:BAABLAAFFH8GAAICAAIIiyH5KQC4AAACAAIIiyH5KQC4AAAAAA==.',Zs='Zsess:BAABLAAFFH8GAAIOAAII3AWZUAB/AAAOAAII3AWZUAB/AAAAAA==.',['一个']='一个饭团:BAAALAADCgIIAgAAAA==.',['一夜']='一夜白了头:BAAALAAECgMIBAAAAA==.',['一尐']='一尐柒一:BAAALAAECgEIAQAAAA==.一尐柒乀:BAAALAAECgUIBQAAAA==.',['一往']='一往如昔:BAAALAAECgMIAwAAAA==.',['一怒']='一怒拔剑:BAAALAAECgQIBAAAAA==.',['一杖']='一杖判阴阳:BAAALAADCgEIAQAAAA==.',['一路']='一路电过去:BAABLAAECn8WAAMMAAgIXBXLbACqAQAMAAgIXBXLbACqAQAPAAcIBg3zRAD+AAAAAA==.',['丁丁']='丁丁当当:BAAALAAECgYIBgAAAA==.',['七情']='七情渡:BAAALAAECgUIBQAAAA==.',['万恶']='万恶的狗麦:BAAALAAECgUIBQAAAA==.',['三下']='三下悠亚:BAAALAADCggICAAAAA==.',['不争']='不争不灭:BAAALAAECgYIDwAAAA==.',['不必']='不必等天晴:BAABLAAFFH8NAAIKAAUIhhqzCQBPAQAKAAUIhhqzCQBPAQABLAAFFAgIDgAPABYUAA==.不必等天青:BAAALAAFFAIIAgAAAA==.',['不忘']='不忘出心:BAAALAAFFAIIAgAAAA==.',['不要']='不要揉我匈:BAAALAADCgIIAgAAAA==.',['不锈']='不锈钢的心:BAAALAAECgQIBAAAAA==.',['与卿']='与卿赴韶华:BAAALAADCgQIBAAAAA==.',['世外']='世外桃园:BAAALAADCgYIBgAAAA==.',['丨弎']='丨弎纸情书丨:BAAALAAECggIAgAAAA==.',['中彩']='中彩票:BAAALAADCgQIBAAAAA==.',['丶灬']='丶灬尐鑫:BAAALAADCgIIAgAAAA==.',['丶煎']='丶煎蛋丶:BAAALAADCgYIBgAAAA==.',['丶獨']='丶獨角戱丶:BAAALAAECggIEgAAAA==.',['为爱']='为爱守玲丶:BAAALAAECgcIDwAAAA==.',['丿尐']='丿尐柒乚:BAAALAAECgYIBgAAAA==.',['乐乐']='乐乐茶:BAAALAAECgYIBgAAAA==.',['乔治']='乔治不拿盾:BAABLAAFFH8GAAIHAAIIPBnbNQCRAAAHAAIIPBnbNQCRAAAAAA==.',['九天']='九天凤:BAAALAAECgYIBgAAAA==.',['云中']='云中小望望:BAACLAAFFH8eAAICAAUIGQ2jLwAlAQACAAUIGQ2jLwAlAQAsAAQKfxcAAgIACAiEFDRcABICAAIACAiEFDRcABICAAAA.',['云治']='云治:BAABLAAFFH8GAAIQAAYIKB1KCgAOAgAQAAYIKB1KCgAOAgAAAA==.',['云稀']='云稀夜:BAAALAAECgQIBAAAAA==.',['亲亲']='亲亲小可爱:BAABLAAECn8WAAMRAAcI7RE5DADlAQARAAcI7RE5DADlAQAEAAUI5wLiXAGYAAAAAA==.',['今晚']='今晚打佬虎:BAABLAAFFH8FAAIDAAMIBAmWagB0AAADAAMIBAmWagB0AAAAAA==.',['仙本']='仙本那:BAAALAADCgcIBwAAAA==.',['伊斯']='伊斯:BAABLAAECn8rAAISAAgIFhsTDAAeAgASAAgIFhsTDAAeAgAAAA==.',['似风']='似风如我:BAABLAAFFH8FAAIIAAUI2RW3EABMAQAIAAUI2RW3EABMAQAAAA==.',['低调']='低调打枪:BAAALAAECgEIAQAAAA==.',['傍桑']='傍桑迪:BAAALAAFFAIIBAAAAA==.',['傲世']='傲世狂龍:BAABLAAFFH8GAAIJAAYILQ8gIABwAQAJAAYILQ8gIABwAQAAAA==.',['傻傻']='傻傻牛妹妹:BAABLAAFFH8GAAIQAAIITA8gSABhAAAQAAIITA8gSABhAAAAAA==.傻傻的玩玩:BAAALAAECgIIAgAAAA==.',['光翼']='光翼展开:BAAALAAECgYIBgAAAA==.',['兔二']='兔二福:BAAALAAFFAIIAgAAAA==.',['兔子']='兔子二号:BAAALAAECgQIBwAAAA==.',['兔死']='兔死狐悲:BAAALAADCgYIBwAAAA==.',['八福']='八福子:BAACLAAFFH8+AAMJAAYItCJEDAAAAgAJAAYItCJEDAAAAgAIAAYIRhGXDQDpAAAsAAQKfykAAwgACAh6JHYEAKoCAAgACAh6JHYEAKoCAAkAAgjAHXfaALEAAAAA.',['六月']='六月:BAAALAAECgYIEQAAAA==.六月丶:BAABLAAECn8fAAIIAAgIhyJHCAAYAwAIAAgIhyJHCAAYAwAAAA==.',['兮安']='兮安丶:BAAALAAECgUIBQAAAA==.',['冷艳']='冷艳茶叶蛋:BAAALAAECgYIDQAAAA==.',['凝惜']='凝惜:BAAALAADCgcIBwAAAA==.',['凤秀']='凤秀苍穹:BAAALAAECgQIBAAAAA==.',['凤起']='凤起龙翔:BAAALAAECgIIAgAAAA==.',['凤青']='凤青:BAAALAAECggIBgAAAA==.',['分身']='分身无术:BAAALAAECgEIAQAAAA==.',['刑部']='刑部尚书:BAAALAAECgYIEgAAAA==.',['初夏']='初夏微晴丶:BAABLAAFFH8KAAIJAAIIGx8tMQCdAAAJAAIIGx8tMQCdAAABLAAFFAgISwAJAE4lAA==.',['力厚']='力厚王:BAAALAADCgcIBwAAAA==.',['功夫']='功夫小猫咪:BAAALAAECgIIAgAAAA==.',['北极']='北极:BAAALAAECgYICQAAAA==.',['十一']='十一月的轨迹:BAAALAAECgYIBgAAAA==.',['华佗']='华佗:BAAALAAECgMIAgAAAA==.',['协同']='协同过滤:BAAALAAECgYIBgAAAA==.',['卡尔']='卡尔萨斯:BAABLAAFFH8GAAIOAAYIfxkQCQAuAgAOAAYIfxkQCQAuAgAAAA==.',['原力']='原力大师:BAABLAAFFH8LAAIOAAYIZgVaQwDbAAAOAAYIZgVaQwDbAAAAAA==.',['叁岁']='叁岁含奶补刀:BAAALAADCggICAAAAA==.',['友舞']='友舞玖菜:BAAALAAECgYIBgAAAA==.',['发牌']='发牌大师:BAABLAAECn8VAAITAAgIQhxSJwCvAgATAAgIQhxSJwCvAgAAAA==.',['叛逃']='叛逃五晨寺:BAAALAAECgYICwAAAA==.',['可可']='可可的小伙伴:BAABLAAFFH8PAAMUAAYIdw2iCADdAAAUAAYIAwuiCADdAAACAAIIfB3DUABKAAAAAA==.',['可爱']='可爱欢欢:BAAALAAECgYIDQAAAA==.',['司凹']='司凹利利:BAABLAAFFH8TAAIVAAUIciK7GACVAQAVAAUIciK7GACVAQAAAA==.',['叹地']='叹地:BAAALAAECgUIBQAAAA==.',['名狗']='名狗官余沧海:BAAALAAECgYICQAAAA==.',['吏部']='吏部尚书:BAAALAAECgEIAQAAAA==.',['吓老']='吓老子一跳:BAAALAAECgQICAAAAA==.',['吕归']='吕归尘阿苏勒:BAAALAAECgIIAgAAAA==.',['呀唛']='呀唛德:BAABLAAFFH8JAAIWAAMIoxlKJgCFAAAWAAMIoxlKJgCFAAAAAA==.',['呆呆']='呆呆丶小囡:BAABLAAFFH8qAAMEAAYIEBJAFwBZAQAEAAYIEBJAFwBZAQAFAAEIQQKGNQA/AAABLAAFFAgIEgAEAM0MAA==.',['呆萌']='呆萌小僧:BAAALAAECgQIBAABLAAFFAcIKQAQACMjAA==.',['呦丶']='呦丶宋威:BAACLAAFFH8nAAQTAAYIQRPQJQB+AQATAAYIIBPQJQB+AQAXAAMIwQwZBgDUAAAYAAIIUxVCFwBBAAAsAAQKfzYABBMACAi/Hn8PAD4CABMACAjFHX8PAD4CABgABginHRI0AKgBABcABAhaIJIIACIBAAAA.',['命运']='命运的落叶:BAABLAAFFH8IAAIDAAIIYBPqhQBEAAADAAIIYBPqhQBEAAAAAA==.',['命運']='命運的落葉:BAABLAAFFH8OAAIVAAYIVBXlKQA3AQAVAAYIVBXlKQA3AQAAAA==.',['哟我']='哟我的小乖乖:BAAALAADCgMIAwAAAA==.',['唐狮']='唐狮子牡丹:BAAALAAECggICQAAAA==.',['唠唠']='唠唠:BAAALAAECggICAAAAA==.',['喜羊']='喜羊羊:BAAALAADCgYICAAAAA==.',['嗯叽']='嗯叽哇塞:BAABLAAFFH8GAAIDAAMIqA2bZQCFAAADAAMIqA2bZQCFAAAAAA==.',['嘛哩']='嘛哩丶哄哄:BAAALAADCgEIAQAAAA==.嘛哩丶嘛哩:BAAALAAECggICAAAAA==.',['嘟爆']='嘟爆你个肾:BAABLAAFFH8WAAIOAAYIhRYmJgCFAQAOAAYIhRYmJgCFAQAAAA==.',['嘿哈']='嘿哈嗨:BAAALAAECgYICQAAAA==.',['四月']='四月丶:BAABLAAFFH8NAAIGAAYIsQ0dCQAqAQAGAAYIsQ0dCQAqAQABLAAFFAcIQQATAMwmAA==.',['因囡']='因囡囚:BAAALAADCgMIBAAAAA==.',['因缘']='因缘际慧:BAAALAAFFAIIBAAAAA==.',['图样']='图样:BAACLAAFFH8iAAMDAAcIjR2pEAARAgADAAcIjR2pEAARAgAZAAEILQT8GAAzAAAsAAQKfxQAAgMABghFI+dOAFsCAAMABghFI+dOAFsCAAAA.',['图槮']='图槮破:BAABLAAFFH8SAAIaAAIIcxUcDAA8AAAaAAIIcxUcDAA8AAAAAA==.',['图腾']='图腾烫手:BAABLAAFFH8qAAMMAAYIkR6xDQAEAgAMAAYIkR6xDQAEAgAPAAEIPwrFRQBDAAAAAA==.',['土木']='土木老哥:BAAALAAECgIIAgAAAA==.',['地水']='地水风火:BAABLAAFFH8GAAIMAAII4QbabQBPAAAMAAII4QbabQBPAAAAAA==.',['壞临']='壞临水的愛:BAAALAAECgQIBwAAAA==.壞临荷的愛:BAAALAAECgYICAAAAA==.',['夏夜']='夏夜的柔风:BAABLAAFFH8IAAIVAAIIKiNsMgCpAAAVAAIIKiNsMgCpAAAAAA==.',['夏日']='夏日的记忆:BAABLAAFFH8GAAITAAYIgwjcFQC1AQATAAYIgwjcFQC1AQAAAA==.',['夏沫']='夏沫浅雨:BAAALAAECgYIDAAAAA==.',['大冰']='大冰角:BAAALAAECgYICAAAAA==.',['大宝']='大宝貝:BAAALAAFFAIIAgAAAA==.',['大寶']='大寶貝:BAAALAAFFAIIBAAAAA==.',['大松']='大松狮:BAAALAAFFAIIBAAAAA==.',['大猫']='大猫哥:BAABLAAFFH8hAAMPAAYIMxspFgCQAQAPAAYIMxspFgCQAQAMAAIIFAPCawBUAAAAAA==.',['大苹']='大苹果:BAABLAAFFH8WAAIDAAYIRhbqKAD1AAADAAYIRhbqKAD1AAAAAA==.',['大酒']='大酒缸:BAAALAAECggIEgAAAA==.',['大雨']='大雨烫脚:BAABLAAFFH8nAAMMAAcI2B8VBQB5AgAMAAcI2B8VBQB5AgAPAAEIrAjdRgBBAAAAAA==.',['大领']='大领主丶:BAAALAADCgUIBQAAAA==.',['天一']='天一:BAAALAAECggICAAAAA==.',['天剑']='天剑的小德:BAAALAAFFAIIBAAAAA==.天剑的小战:BAABLAAFFH8GAAIIAAII4AQ0OAApAAAIAAII4AQ0OAApAAAAAA==.',['天官']='天官赐福:BAACLAAFFH8VAAIVAAUIsRkgJwBGAQAVAAUIsRkgJwBGAQAsAAQKfxkAAhUABgjeFjenAKwBABUABgjeFjenAKwBAAAA.',['天朝']='天朝的产物:BAABLAAFFH8IAAIEAAII5hOjWgCPAAAEAAII5hOjWgCPAAAAAA==.',['天火']='天火丶天火:BAACLAAFFH8OAAIOAAIINCCNPACbAAAOAAIINCCNPACbAAAsAAQKfxUAAg4ABgjKH2FNAAoCAA4ABgjKH2FNAAoCAAAA.',['天猎']='天猎战虎:BAAALAAECgYIEQAAAA==.',['头真']='头真大:BAAALAAECgcICgAAAA==.',['套住']='套住唔好玩:BAAALAAECgYIEQAAAA==.',['女丶']='女丶邪:BAACLAAFFH8IAAMVAAIIpRWNRACbAAAVAAIIpRWNRACbAAAbAAIISQp2IACHAAAsAAQKfxoABAYACAh7FtM9AEYBABUABgg9FC3qAEsBAAYABggFFdM9AEYBABsACAhwDQslAB4BAAAA.',['奶油']='奶油不小了:BAAALAAFFAIIBAAAAA==.奶油不洗澡:BAAALAAECgEIAQAAAA==.奶油烩蜊饭:BAAALAAECgYIBwAAAA==.',['奶爸']='奶爸海怪:BAAALAAECgIIAgAAAA==.',['妖之']='妖之杏:BAAALAADCgEIAQAAAA==.',['妞粗']='妞粗鲁:BAAALAAECgIIAgAAAA==.',['姑奶']='姑奶奶:BAABLAAFFH8GAAIMAAIIeBh7UAB9AAAMAAIIeBh7UAB9AAAAAA==.',['姜饼']='姜饼人:BAAALAAECgYIBgAAAA==.',['威震']='威震天:BAAALAAECgIIAgAAAA==.',['娜娜']='娜娜虾:BAAALAAECgQIBAAAAA==.',['嫣语']='嫣语:BAAALAAECgUIDQAAAA==.',['完整']='完整的男人:BAABLAAFFH8IAAMUAAIIHgwsFABjAAACAAIILgQPXAB8AAAUAAIIHgwsFABjAAABLAAFFAMIBQAGAEMOAA==.',['寒塘']='寒塘渡鹤影丶:BAABLAAFFH8NAAICAAMIXBh3OwCkAAACAAMIXBh3OwCkAAAAAA==.',['封稀']='封稀冰:BAAALAAECgIIAwAAAA==.',['射射']='射射已经谢了:BAABLAAFFH8YAAMEAAcIJSBSDAAvAgAEAAcIJSBSDAAvAgAFAAIIxBcgHwCMAAAAAA==.',['射来']='射来射去的:BAABLAAFFH8SAAIEAAYIThPqOwBZAQAEAAYIThPqOwBZAQAAAA==.',['小呀']='小呀小白兔:BAABLAAECn8WAAIVAAcIqReAiADdAQAVAAcIqReAiADdAQAAAA==.',['小困']='小困包:BAAALAAECgQIBgAAAA==.',['小小']='小小美美:BAABLAAFFH8GAAMRAAIIjwnTBQCPAAARAAIIjwnTBQCPAAAEAAIIlgWCvwAsAAAAAA==.',['小德']='小德不能抓:BAABLAAECn8XAAIWAAYIBAkpdAD1AAAWAAYIBAkpdAD1AAAAAA==.',['小水']='小水杯:BAAALAADCgcIBwAAAA==.',['小游']='小游贝果:BAAALAAECggIBwAAAA==.',['小磕']='小磕唠稀碎:BAAALAAECgIIAgAAAA==.',['小蓉']='小蓉:BAABLAAFFH8GAAMcAAIIvgkZBAB8AAAcAAIIvgkZBAB8AAAHAAIIeAQMSQBZAAAAAA==.',['小黄']='小黄帝俊俊:BAAALAAECgUIBQAAAA==.小黄龙:BAAALAAECgMIBQAAAA==.',['就是']='就是不套盾:BAAALAAECgYICQAAAA==.就是不潜行:BAAALAAECgYIBgAAAA==.',['屁是']='屁是翔的魂:BAAALAAFFAIIAgAAAA==.',['山的']='山的朝阳面:BAAALAAFFAIIAgAAAA==.',['工部']='工部尚书:BAAALAAECgYICgAAAA==.',['巴鲁']='巴鲁霸多斯:BAAALAAFFAIIBAAAAA==.',['布疆']='布疆吾德:BAAALAAECgUIBQAAAA==.',['帅死']='帅死:BAAALAAECggICAAAAA==.',['希卡']='希卡利丶:BAABLAAFFH8VAAMHAAYImhAwGgCFAQAHAAYImhAwGgCFAQASAAUIJxXKFAAwAQAAAA==.',['库昊']='库昊:BAAALAAECgYICwAAAA==.',['应橙']='应橙尽橙:BAAALAAECgIIAwAAAA==.',['底槽']='底槽清:BAAALAADCgQIBAAAAA==.',['康斯']='康斯坦汀:BAACLAAFFH8HAAIVAAIIog23SwCWAAAVAAIIog23SwCWAAAsAAQKfx0AAxsABgj6FBA5AIABABsABgj6FBA5AIABABUABggRH/xMAHkBAAAA.',['开黑']='开黑我选半藏:BAAALAADCgEIAQAAAA==.',['弑神']='弑神之魄:BAAALAAECgEIAQAAAA==.',['张十']='张十一:BAAALAAECgQIBAAAAA==.',['影兰']='影兰:BAAALAAECgcIEwAAAA==.',['彻底']='彻底疯狂:BAABLAAFFH8jAAMTAAYIDCHXEQDYAQATAAYIDCHXEQDYAQAYAAEIKRPXHQBLAAAAAA==.',['彼得']='彼得灬德鲁克:BAAALAAECgIIAwAAAA==.',['徐娘']='徐娘中意角酱:BAAALAAECgYIBgAAAA==.',['御扳']='御扳美琴:BAAALAAFFAIIAgAAAA==.',['德莱']='德莱文辅助:BAACLAAFFH8SAAIQAAQIVw5SKQDTAAAQAAQIVw5SKQDTAAAsAAQKfxYAAxAABwiJF3E8AO4BABAABwiJF3E8AO4BABYABAgqBwiFAK8AAAAA.',['德鲁']='德鲁狼:BAAALAAECgYICwAAAA==.',['心情']='心情愉悦:BAAALAAECgYIDQAAAA==.',['忧郁']='忧郁的蜗牛牛:BAAALAAFFAIIAgAAAA==.',['怎么']='怎么看都是贼:BAAALAADCgMIAwAAAA==.',['怠惰']='怠惰丶:BAACLAAFFH8jAAMDAAYIkCSLEQAKAgADAAYIkCSLEQAKAgAdAAEINB5DEABUAAAsAAQKfykAAwMACAg3JC8nANQCAAMABwiaJS8nANQCAB0ABAgvGwoyADsBAAAA.',['恶了']='恶了魔猎手:BAACLAAFFH8hAAICAAcIwxdsDwDtAQACAAcIwxdsDwDtAQAsAAQKfxoAAgIACAgZHjNPADQCAAIACAgZHjNPADQCAAAA.',['恶魔']='恶魔之眼:BAABLAAECn8WAAMCAAYIzxLPUAArAQACAAYIzxLPUAArAQAUAAMIegpJJQByAAAAAA==.',['悠兰']='悠兰:BAAALAAECgYIBgAAAA==.',['悲剧']='悲剧的小辣条:BAAALAAECgUIBQAAAA==.',['惊艳']='惊艳双刃:BAAALAAECgUIBQAAAA==.',['想法']='想法阿弄死你:BAAALAADCgYICAAAAA==.',['想飞']='想飞的羽毛:BAAALAADCgQIBAAAAA==.',['成都']='成都白袜子:BAAALAAECgYICgAAAA==.',['我东']='我东山啊:BAAALAAECgYICwAAAA==.',['我可']='我可以躺这么:BAAALAADCggICAAAAA==.',['我有']='我有一个特长:BAAALAADCgYIBgAAAA==.',['我真']='我真系就快钉:BAABLAAFFH8MAAICAAUIqhX1DwCsAQACAAUIqhX1DwCsAQAAAA==.',['战场']='战场原丶:BAAALAAECgEIAQAAAA==.',['戴高']='戴高乐:BAAALAAECgUICwAAAA==.',['手到']='手到出水:BAABLAAECn8eAAICAAcIyxFniAC1AQACAAcIyxFniAC1AQAAAA==.',['拉稀']='拉稀奥:BAAALAAECgEIAgAAAA==.',['拾柒']='拾柒:BAABLAAFFH8TAAMUAAYIVBVTCADmAAACAAYIVBU4LgAwAQAUAAUIbRBTCADmAAAAAA==.',['探长']='探长:BAAALAADCggICAAAAA==.',['推老']='推老婆下楼梯:BAABLAAFFH8QAAIDAAYIwQ7VOwBTAQADAAYIwQ7VOwBTAQAAAA==.',['收你']='收你税:BAABLAAFFH8GAAIEAAIIMBg7mgBCAAAEAAIIMBg7mgBCAAAAAA==.',['收集']='收集梦想:BAAALAAECgQIBAAAAA==.',['放开']='放开那丶姑娘:BAAALAAECgYIDgAAAA==.放开那老奶:BAACLAAFFH8GAAIVAAIIPQoecwA9AAAVAAIIPQoecwA9AAAsAAQKfxYAAhUABwjXFgNFAI8BABUABwjXFgNFAI8BAAAA.',['新庄']='新庄嘟雷龙:BAAALAAECggICAAAAA==.',['方知']='方知有:BAABLAAFFH8KAAIOAAYIcwTSQQDtAAAOAAYIcwTSQQDtAAAAAA==.',['日不']='日不落:BAABLAAFFH8GAAIeAAIILxVqEQChAAAeAAIILxVqEQChAAAAAA==.',['旧忆']='旧忆双刀:BAAALAAECgUIDQAAAA==.',['时崎']='时崎狂叁:BAAALAADCgIIAgAAAA==.',['明日']='明日大侠三:BAABLAAFFH8GAAIVAAYIJhHyIwBYAQAVAAYIJhHyIwBYAQAAAA==.',['星光']='星光灭绝:BAACLAAFFH8FAAIVAAMIPRW/RgCEAAAVAAMIPRW/RgCEAAAsAAQKfzUAAhUACAh5JO4KAL4CABUACAh5JO4KAL4CAAAA.',['星宸']='星宸:BAACLAAFFH8GAAICAAUIwgjTMgAFAQACAAUIwgjTMgAFAQAsAAQKfykAAgIABwhbGqUwAJkBAAIABwhbGqUwAJkBAAAA.',['星尘']='星尘:BAAALAADCgcIBwAAAA==.',['星星']='星星与太阳:BAAALAAFFAMIAwAAAA==.',['晚秋']='晚秋初肃丶:BAABLAAFFH8KAAIEAAIIHBOalQBEAAAEAAIIHBOalQBEAAAAAA==.',['景秀']='景秀衣:BAABLAAFFH8FAAIVAAII/hPCaABCAAAVAAII/hPCaABCAAAAAA==.',['暖暖']='暖暖:BAABLAAECn8XAAIHAAcIOQzfaABAAQAHAAcIOQzfaABAAQAAAA==.',['暗夜']='暗夜猎手:BAABLAAECn8UAAICAAYIdhNgtABrAQACAAYIdhNgtABrAQAAAA==.',['月之']='月之哀傷:BAAALAAFFAIIBAAAAA==.',['木子']='木子星辰:BAAALAAECgYIBgAAAA==.木子虚:BAAALAADCgQIBgAAAA==.',['末知']='末知曰标:BAAALAADCgEIAQAAAA==.',['杰杰']='杰杰阿童木:BAAALAAFFAQIBAAAAA==.',['林兮']='林兮:BAABLAAECn8cAAIHAAYIFByiHQDRAQAHAAYIFByiHQDRAQAAAA==.',['林暮']='林暮月:BAAALAAECgMIBAAAAA==.',['柒柒']='柒柒的翘嘴鱼:BAAALAADCgYIBgAAAA==.',['树欲']='树欲静风不止:BAAALAAECgYIBgAAAA==.',['栗子']='栗子炸裂:BAAALAAFFAIIAgABLAAFFAMIBgADAGkSAA==.',['桃之']='桃之夭夭:BAAALAAECgYIBQAAAA==.',['梦丶']='梦丶复仇女神:BAAALAAECgUIBQAAAA==.梦丶离火幻灵:BAAALAAECgYIDAAAAA==.梦丶虚冥鬼影:BAACLAAFFH8KAAIDAAYIJQK8TgD3AAADAAYIJQK8TgD3AAAsAAQKfxsAAgMACAgjDgGrALYBAAMACAgjDgGrALYBAAAA.',['梦想']='梦想抓小德:BAAALAAECgYIBgAAAA==.',['棒棒']='棒棒的灰灰:BAAALAAECggICAAAAA==.',['棠棠']='棠棠:BAABLAAFFH8IAAIMAAIIVxuyMgCcAAAMAAIIVxuyMgCcAAAAAA==.',['樱桃']='樱桃小完犊子:BAAALAAECgYIBgAAAA==.',['橘阳']='橘阳菜丶:BAABLAAFFH8zAAIDAAcIqiS5CQATAgADAAcIqiS5CQATAgAAAA==.',['橙心']='橙心丶:BAABLAAFFH8HAAICAAIIOB7/NgCgAAACAAIIOB7/NgCgAAABLAAFFAcIQQATAMwmAA==.',['橙色']='橙色的迪凯:BAAALAAECgMIAwAAAA==.',['欢乐']='欢乐全家桶:BAAALAAECgEIAQAAAA==.欢乐树的喷友:BAACLAAFFH8nAAIJAAYIEBkHDQDIAQAJAAYIEBkHDQDIAQAsAAQKfxUAAgkABgiKIXZOAAUCAAkABgiKIXZOAAUCAAAA.',['歌方']='歌方月乃丶:BAAALAAFFAEIAQAAAA==.',['正義']='正義執行:BAAALAAECgYIBwAAAA==.',['残丨']='残丨剑:BAABLAAFFH8GAAIVAAIIvwUeewA4AAAVAAIIvwUeewA4AAAAAA==.',['残剱']='残剱:BAAALAAFFAIIAgAAAA==.',['每夜']='每夜一次:BAAALAAECgMIAwAAAA==.',['毒菇']='毒菇猫猫:BAABLAAECn8WAAIEAAcICRR4sACUAQAEAAcICRR4sACUAQAAAA==.',['比尔']='比尔拉塞尔:BAAALAAECgMIAwAAAA==.',['水品']='水品月沙:BAAALAAECgYIBgAAAA==.',['沉睡']='沉睡中的卡卡:BAAALAADCgMIAwAAAA==.',['沉霜']='沉霜:BAAALAAECgIIAgAAAA==.',['沙加']='沙加:BAAALAAECgYIBgAAAA==.',['法如']='法如雪:BAAALAADCgQIBAAAAA==.',['泣雷']='泣雷:BAACLAAFFH8GAAIJAAIIbwhkXwA4AAAJAAIIbwhkXwA4AAAsAAQKfzIAAgkACAicGfUeAPcBAAkACAicGfUeAPcBAAAA.',['泪湿']='泪湿澜杆:BAAALAAECgYICAAAAA==.',['泰瑞']='泰瑞尔:BAAALAAECgYICgAAAA==.',['流年']='流年之伤:BAAALAAECgYICgAAAA==.',['海水']='海水梦悠悠:BAAALAADCgYIBgAAAA==.',['海苔']='海苔小火人:BAAALAADCgcIBwAAAA==.',['漂泊']='漂泊一:BAAALAAECgYIBgAAAA==.',['漏夜']='漏夜过东莞:BAAALAAFFAIIBAAAAA==.',['漠漠']='漠漠冒烟:BAAALAAECgIIAgAAAA==.',['潜行']='潜行的奈亚子:BAACLAAFFH8mAAIfAAcIMCCKAwApAgAfAAcIMCCKAwApAgAsAAQKfzAAAh8ACAjwI/YFAB4DAB8ACAjwI/YFAB4DAAAA.',['火车']='火车王:BAAALAAFFAIIBAAAAA==.',['灬尐']='灬尐菟灬:BAAALAADCgcIBwAAAA==.',['灬鬼']='灬鬼魅丶家族:BAAALAAECgMIAwAAAA==.',['灰烬']='灰烬:BAAALAAECggIDAAAAA==.灰烬之天剑:BAAALAAFFAIIBAAAAA==.',['灵魂']='灵魂者汰尔:BAAALAAFFAIIBAAAAA==.',['炭某']='炭某:BAAALAAECgMIAwAAAA==.',['炼乳']='炼乳酥丝:BAAALAAECgYIBwAAAA==.',['無乄']='無乄雙:BAAALAAECgEIAQAAAA==.',['熊熊']='熊熊:BAAALAAECgYIDAAAAA==.',['爖七']='爖七:BAAALAAECgYIEAAAAA==.',['爱上']='爱上张无忌:BAAALAAFFAIIBAAAAA==.',['牛喜']='牛喜欢:BAAALAAFFAEIAQAAAA==.',['牛欢']='牛欢喜:BAAALAAFFAIIBAAAAA==.',['牛魔']='牛魔降世:BAAALAAECgYIBgAAAA==.',['犀牛']='犀牛图拉:BAAALAAECgEIAQAAAA==.',['狂热']='狂热小飞:BAAALAAECgYIBgAAAA==.',['狂野']='狂野胖胖:BAAALAAECgYIBgAAAA==.',['猎刃']='猎刃之矛:BAAALAAECgEIAQAAAA==.',['猛冲']='猛冲:BAAALAAECgYIBAAAAA==.',['猫又']='猫又:BAAALAAECgcICQABLAAECggIGAAgAH8dAA==.',['王二']='王二炮杀手:BAAALAAECgEIAQAAAA==.',['王者']='王者傲雄:BAAALAAECgYIDAAAAA==.王者奥雄:BAAALAAECgYICgAAAA==.',['琳娜']='琳娜贝儿灬:BAABLAAFFH8IAAIMAAMIgxpANQDVAAAMAAMIgxpANQDVAAAAAA==.',['瑅里']='瑅里奥弗丁:BAAALAADCgEIAQAAAA==.',['瑞雪']='瑞雪飘儿:BAAALAADCgYIDAAAAA==.',['璇小']='璇小琪:BAAALAADCgMIAwAAAA==.',['瓜拾']='瓜拾叁:BAABLAAFFH8wAAICAAgI8yWjAAAYAwACAAgI8yWjAAAYAwAAAA==.瓜拾壹:BAABLAAFFH8yAAICAAgIwSXVAAASAwACAAgIwSXVAAASAwAAAA==.瓜拾肆:BAABLAAFFH80AAICAAgImSQVAQAJAwACAAgImSQVAQAJAwAAAA==.瓜拾贰:BAABLAAFFH8uAAICAAgINyXlAAAQAwACAAgINyXlAAAQAwAAAA==.',['瓦尔']='瓦尔基丽雅:BAAALAAECggIAgAAAA==.',['生命']='生命本无意义:BAAALAAFFAIIAgAAAA==.',['癞皮']='癞皮狗:BAAALAADCgUIBQAAAA==.',['白银']='白银德莱文:BAACLAAFFH8TAAIhAAQIdRSiEQAOAQAhAAQIdRSiEQAOAQAsAAQKfxoAAyEACAi/EnkMAKIBACEACAi/EnkMAKIBACIABAiMCY8pAJMAAAAA.',['百发']='百发百中:BAABLAAFFH8FAAIEAAMI8RAicgCDAAAEAAMI8RAicgCDAAABLAAFFAcIIQACAMMXAA==.',['百变']='百变牛钢:BAAALAAECgYICAAAAA==.',['皮埃']='皮埃尔欸:BAAALAADCgIIAgAAAA==.',['目前']='目前情绪稳定:BAAALAAECgQIBAAAAA==.',['相対']='相対性理论:BAACLAAFFH8GAAIDAAMIaRK0LADmAAADAAMIaRK0LADmAAAsAAQKfxUAAgMACAicG0JQAFgCAAMACAicG0JQAFgCAAAA.',['看看']='看看怎么个事:BAAALAAECgcIDQABLAAFFAcIJgAfADAgAA==.',['真诚']='真诚的套路:BAAALAAECgYIBgAAAA==.',['睡梦']='睡梦罗汉拳:BAAALAAECgEIAQAAAA==.',['瞬间']='瞬间消散:BAAALAAFFAEIAQAAAA==.',['石敢']='石敢当:BAABLAAFFH8vAAIIAAcIKxQ8BwCOAQAIAAcIKxQ8BwCOAQAAAA==.',['碧柠']='碧柠酱:BAAALAAECggICAAAAA==.',['碧火']='碧火青天:BAAALAAECgYIEgAAAA==.',['碧青']='碧青波澜:BAAALAAFFAIIBAAAAA==.',['神使']='神使之耀:BAAALAAECgQIBgAAAA==.',['神勇']='神勇勇:BAABLAAECn8rAAITAAcIgRLtcwCwAQATAAcIgRLtcwCwAQAAAA==.',['神枪']='神枪手龟龟:BAABLAAECn8VAAIEAAgIiBo3JQAmAgAEAAgIiBo3JQAmAgAAAA==.',['神無']='神無月時雨:BAABLAAFFH8PAAIEAAUI/QWTYADKAAAEAAUI/QWTYADKAAAAAA==.',['神舌']='神舌达芙妮:BAAALAADCgMIAwAAAA==.',['神马']='神马灬先生:BAAALAAECgYIBgAAAA==.',['禁军']='禁军总教官:BAAALAAECgYIBgAAAA==.',['禪心']='禪心定不忘生:BAAALAAECgYIBgAAAA==.',['秋熙']='秋熙黛:BAAALAAECgYIDAAAAA==.',['秋豆']='秋豆麻袋:BAAALAAECgYIDQAAAA==.',['童帝']='童帝结成:BAAALAAFFAIIAgAAAA==.',['符玄']='符玄:BAACLAAFFH8hAAIIAAcIrRS/CQCsAQAIAAcIrRS/CQCsAQAsAAQKfxgAAwgABwhKFtkwAM4BAAgABwhKFtkwAM4BAAkABAitAR8CAUsAAAAA.',['粉呼']='粉呼呼滴:BAAALAAFFAMIAwAAAA==.',['精灵']='精灵傻傻:BAAALAAECgYIBgAAAA==.',['索马']='索马里渔夫:BAAALAADCgMIAwAAAA==.',['红肚']='红肚兜丶:BAACLAAFFH8yAAIfAAcI7hiyBADzAQAfAAcI7hiyBADzAQAsAAQKfysAAh8ABwgyItoQAJwCAB8ABwgyItoQAJwCAAAA.',['红色']='红色的忧郁:BAAALAAECgYICwAAAA==.',['给我']='给我你的暧:BAAALAADCgQIBAAAAA==.',['绝美']='绝美:BAAALAAECgYICgAAAA==.',['绮丽']='绮丽之梦:BAAALAADCgIIAgAAAA==.',['维吉']='维吉尔:BAAALAAECgQIBAAAAA==.',['维莱']='维莱里奥:BAABLAAFFH8GAAIDAAIIPBvrSwCkAAADAAIIPBvrSwCkAAAAAA==.',['绿大']='绿大佬:BAAALAAECgcICQAAAA==.',['绿皮']='绿皮鬼:BAACLAAFFH8wAAMOAAYIBhvjIQCYAQAOAAYIuxrjIQCYAQAeAAIIxhOYEACjAAAsAAQKfyUAAw4ACAgNGlMjANcBAA4ACAgNGlMjANcBAB4ABAjrFJRgAPUAAAAA.',['翅膀']='翅膀的梦:BAAALAAECgYICwAAAA==.',['老脸']='老脸笑成菊花:BAAALAADCgEIAQAAAA==.',['考试']='考试得了一百:BAAALAAECgYIBwAAAA==.',['肆分']='肆分肆秒:BAAALAAECgYIBgAAAA==.',['肆拾']='肆拾肆:BAABLAAFFH8FAAIDAAUItRWpQwAzAQADAAUItRWpQwAzAQAAAA==.',['肉弹']='肉弹丶:BAAALAAFFAIIAgAAAA==.',['肚子']='肚子变大了:BAAALAAECgYIBwAAAA==.',['肝不']='肝不动时刻:BAABLAAECn8dAAIDAAYIEg2pfgDyAAADAAYIEg2pfgDyAAAAAA==.',['胖瑶']='胖瑶瑶:BAAALAAECgEIAQAAAA==.',['脆皮']='脆皮甜甜圈:BAAALAADCgcIBwAAAA==.',['腐国']='腐国大西瓜:BAAALAADCgMIAwAAAA==.',['腰间']='腰间盘突出:BAAALAAECgEIAQAAAA==.',['自定']='自定义小狗:BAAALAADCgMIAwAAAA==.',['艾俄']='艾俄洛斯:BAAALAAECgYIDAAAAA==.',['艾尔']='艾尔奎特:BAAALAAECgUIDQAAAA==.',['艾斯']='艾斯库库:BAAALAAECggICAAAAA==.',['艾黛']='艾黛尔贾特:BAAALAAECgYIAQAAAA==.',['芝士']='芝士猪柳蛋堡:BAABLAAFFH8FAAMGAAMIQw7zGQByAAAGAAIImgvzGQByAAAbAAEIsQWXKQBEAAAAAA==.',['花差']='花差小将军:BAAALAAECgYIDgAAAA==.',['花村']='花村两颗菜:BAAALAAFFAIIAgAAAA==.花村如梦:BAAALAAFFAIIAgAAAA==.花村小开开:BAAALAAECgUIBQAAAA==.花村小牛气:BAAALAAFFAIIBAAAAA==.花村慢摇:BAAALAAECgQIBAAAAA==.花村村长:BAAALAAECgIIAgAAAA==.花村清洁工:BAABLAAECn8dAAICAAYIjCGhHgDyAQACAAYIjCGhHgDyAQAAAA==.花村的信仰:BAAALAAFFAIIBAAAAA==.花村的杏痒:BAABLAAFFH8PAAIMAAIIeyJ/OADFAAAMAAIIeyJ/OADFAAAAAA==.花村铁锤:BAAALAAECgYIBwAAAA==.花村阿花:BAAALAAECgYIBgAAAA==.',['苕苳']='苕苳茄:BAAALAAECgEIAQAAAA==.',['莉薇']='莉薇亚:BAABLAAFFH8IAAIQAAIIHxtyIgCcAAAQAAIIHxtyIgCcAAAAAA==.',['菊花']='菊花里放鞭炮:BAAALAAECgEIAQAAAA==.',['萌工']='萌工:BAAALAAECgQIBgAAAA==.',['萨尓']='萨尓丨:BAAALAAFFAIIAgAAAA==.',['萨总']='萨总的小员工:BAAALAADCgYIBgAAAA==.',['萨鲁']='萨鲁灬曼:BAABLAAFFH8FAAIPAAIIlgrwNAB+AAAPAAIIlgrwNAB+AAAAAA==.',['落魄']='落魄山小米粒:BAAALAAECgEIAQAAAA==.',['蒜蓉']='蒜蓉饺子:BAAALAAECgYIDgABLAAFFAUIFwAhAKUaAA==.',['蓝色']='蓝色最垃圾:BAAALAADCgEIAQAAAA==.',['虚空']='虚空打火机:BAAALAAECgYIDQAAAA==.',['蛋蛋']='蛋蛋不太傲娇:BAAALAAECgYIEQAAAA==.',['蛋黄']='蛋黄饭团:BAABLAAFFH8GAAIPAAII2BStJQCcAAAPAAII2BStJQCcAAAAAA==.',['蝶中']='蝶中蝶:BAABLAAFFH8IAAIEAAgI1wFKfwBfAAAEAAgI1wFKfwBfAAAAAA==.',['蠟筆']='蠟筆小佳:BAAALAADCgIIAgAAAA==.',['血之']='血之哀傷:BAACLAAFFH8RAAIEAAQIkhd0PQCqAAAEAAQIkhd0PQCqAAAsAAQKfxQAAgQABghpGTxqAHEBAAQABghpGTxqAHEBAAAA.',['街边']='街边一炮手:BAAALAAECgQICAAAAA==.',['裤档']='裤档里有霸气:BAAALAAECgIIAgAAAA==.',['褲儅']='褲儅悝有殺暣:BAAALAAECgQIBAAAAA==.',['西京']='西京:BAAALAAECgIIAgAAAA==.',['西伯']='西伯利亚郎:BAAALAAECgYICQAAAA==.',['西雅']='西雅啚不眠夜:BAAALAAECgUIDwAAAA==.西雅啚夜未眠:BAAALAAECgYICQAAAA==.西雅図不眠夜:BAAALAAECgQIBwAAAA==.西雅図夜未眠:BAAALAAECgYIEgAAAA==.西雅图不眠夜:BAAALAAECgMIBgAAAA==.西雅图夜未眠:BAAALAAECgMIBAAAAA==.西雅圖不眠夜:BAAALAAECgMIBQAAAA==.西雅圖夜未眠:BAAALAAECgMIBAAAAA==.西雅圗不眠夜:BAAALAAECgMIAgAAAA==.',['謎圗']='謎圗灬曉牧:BAABLAAFFH8MAAMSAAII3B+1GQCjAAASAAII3B+1GQCjAAAcAAIIqBVtAgCeAAAAAA==.',['调理']='调理农务系:BAABLAAFFH8IAAMYAAIInhQfFwBCAAAYAAEIeBIfFwBCAAATAAIIdg+EXwA9AAAAAA==.',['賊可']='賊可愛:BAAALAAECgIIAgAAAA==.',['贾状']='贾状酰:BAAALAAECgQIBAAAAA==.',['超级']='超级好吃:BAABLAAFFH8dAAQGAAYI7BdMCADbAAAGAAUILBxMCADbAAAVAAMItwLVTgBhAAAbAAEIVACQMgATAAAAAA==.',['路在']='路在丶何方:BAABLAAFFH8LAAICAAMI6wpvQQCOAAACAAMI6wpvQQCOAAAAAA==.',['跳舞']='跳舞的咕咕:BAAALAAECgUIBQAAAA==.',['辣个']='辣个兰人:BAABLAAFFH8FAAICAAII5w+CSgCRAAACAAII5w+CSgCRAAAAAA==.',['辰辰']='辰辰:BAAALAAECgQIBAAAAA==.',['这世']='这世界是块冰:BAAALAAECgYICAAAAA==.',['进击']='进击的城爷:BAABLAAFFH8HAAIOAAMI/gpPUAB9AAAOAAMI/gpPUAB9AAAAAA==.',['逐月']='逐月清风:BAACLAAFFH8zAAIHAAcIBiPQAwCoAgAHAAcIBiPQAwCoAgAsAAQKfxkAAgcABwiGHXolAFkCAAcABwiGHXolAFkCAAAA.',['逐焱']='逐焱者明:BAABLAAFFH8JAAIFAAII9BhUKAB3AAAFAAII9BhUKAB3AAAAAA==.',['遇见']='遇见方知有:BAAALAAECgYICgAAAA==.',['道无']='道无涯:BAAALAADCgYIBwAAAA==.',['遗忘']='遗忘小哥哥:BAAALAAECgcIDwAAAA==.遗忘的情人:BAAALAAECgUIBwAAAA==.遗忘的选择:BAAALAAECgEIAQAAAA==.',['那个']='那个帅丶哥:BAAALAAECgYICAAAAA==.',['那维']='那维莱特:BAAALAAECgUIBQABLAAFFAMIBQAGAEMOAA==.',['邪术']='邪术:BAAALAAECgYIBgAAAA==.',['邪魔']='邪魔:BAAALAAECgYIBgAAAA==.',['都是']='都是泪:BAAALAAFFAIIAQAAAA==.',['酱油']='酱油战:BAAALAADCgYICAAAAA==.酱油瓶子:BAAALAAECgYIEgAAAA==.',['采矿']='采矿学训练师:BAAALAAECgcIBwAAAA==.',['金刚']='金刚狼人王:BAAALAADCgEIAQAAAA==.',['铁牛']='铁牛俊俊:BAAALAAECgYIBgAAAA==.',['闇口']='闇口崩子:BAABLAAFFH8WAAIDAAUInBwYPgBJAQADAAUInBwYPgBJAQAAAA==.',['闪闪']='闪闪的玩:BAAALAAFFAIIBAAAAA==.',['闻香']='闻香拾女:BAABLAAFFH8KAAIJAAIIzw/3OgCTAAAJAAIIzw/3OgCTAAAAAA==.',['阮玲']='阮玲玉的阮:BAABLAAFFH8GAAMjAAIIIxDoBQA9AAAfAAEICBDmIABUAAAjAAIIdQzoBQA9AAAAAA==.',['防战']='防战不太凶:BAAALAAECgYIBgAAAA==.',['防风']='防风小火柴:BAAALAAECgYICgAAAA==.',['阴阳']='阴阳师晴明:BAAALAAECgEIAQAAAA==.',['阿修']='阿修罗:BAAALAADCgEIAQAAAA==.',['阿弥']='阿弥陀佛:BAAALAADCgYIBgAAAA==.',['阿龍']='阿龍丶:BAAALAAECgUIBQAAAA==.',['阿龙']='阿龙的警告:BAAALAAECgYIBgAAAA==.',['陋夜']='陋夜过东莞:BAACLAAFFH8GAAICAAIIHxqSSwBPAAACAAIIHxqSSwBPAAAsAAQKfxUAAgIABgjbIeUgAOQBAAIABgjbIeUgAOQBAAAA.',['隐锋']='隐锋:BAAALAADCgEIAQAAAA==.',['雄起']='雄起勇敢牛牛:BAAALAAECgUIBQAAAA==.',['雪糕']='雪糕刺客:BAAALAAFFAIIAgAAAA==.',['雲中']='雲中追月:BAAALAADCgYIDwAAAA==.',['雾之']='雾之守护者:BAAALAAECgYICgAAAA==.',['霜语']='霜语:BAAALAAFFAIIAgAAAA==.',['霸王']='霸王別急:BAAALAAECgQIBwAAAA==.',['青鸟']='青鸟:BAACLAAFFH8QAAISAAYINx0TCgC4AQASAAYINx0TCgC4AQAsAAQKfxQAAhIABghHJn0KADYCABIABghHJn0KADYCAAAA.',['非洲']='非洲矿工:BAAALAAFFAIIBAAAAA==.',['韩德']='韩德温:BAACLAAFFH9BAAMkAAgIvhpvAQB5AgAkAAgIvhpvAQB5AgAiAAUIvhAbCgB3AQAsAAQKfxgAAiIABwgxHiogABgCACIABwgxHiogABgCAAAA.',['顶风']='顶风喷一丈:BAAALAAECgYICQAAAA==.',['風雲']='風雲啸:BAABLAAECn8WAAIEAAgIYBiTdwDuAQAEAAgIYBiTdwDuAQAAAA==.',['风一']='风一样飘:BAABLAAFFH8UAAMVAAUI2xIhKgA1AQAVAAUI2xIhKgA1AQAbAAIIIgdNKwBjAAAAAA==.',['风行']='风行者的神:BAAALAADCgYIBgAAAA==.',['飘落']='飘落叶:BAAALAAECgYIBgAAAA==.',['飞来']='飞来飞去得:BAAALAAFFAIIAgAAAA==.',['飞过']='飞过苍海:BAAALAAECgYICAAAAA==.',['饭团']='饭团团酱:BAACLAAFFH8LAAIOAAMIzQuSLADUAAAOAAMIzQuSLADUAAAsAAQKfxkAAg4ACAgdHYMmAKwCAA4ACAgdHYMmAKwCAAAA.',['香粹']='香粹甜甜圈:BAAALAAECgMIAwAAAA==.',['鬱悶']='鬱悶的風:BAAALAAECgMIAwAAAA==.',['鬼方']='鬼方无悔:BAABLAAECn8dAAIJAAYITBZWQABcAQAJAAYITBZWQABcAQAAAA==.',['鱼旦']='鱼旦:BAAALAAECgQIBAAAAA==.',['鸿海']='鸿海:BAAALAAECgIIAgAAAA==.',['黑神']='黑神话佩奇:BAABLAAFFH8NAAIEAAYIgBobLQCHAQAEAAYIgBobLQCHAQAAAA==.',['黑色']='黑色沉沦:BAACLAAFFH8cAAMEAAYIChdjMgB2AQAEAAYIChdjMgB2AQAFAAIIkQMNMABgAAAsAAQKfzEAAwQACAilHhEgAEACAAQACAilHhEgAEACAAUABwicE5ZJAI4BAAAA.',['黑铁']='黑铁骑:BAABLAAFFH8IAAIdAAIIpxuHDQCpAAAdAAIIpxuHDQCpAAAAAA==.',['龙啸']='龙啸苍穹:BAAALAAECgQIBAAAAA==.',['龙舌']='龙舌蓝:BAAALAAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end