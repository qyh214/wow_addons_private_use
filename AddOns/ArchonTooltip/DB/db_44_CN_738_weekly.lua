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
 local lookup = {'Evoker-Preservation','Evoker-Augmentation','Hunter-BeastMastery','DeathKnight-Frost','Mage-Arcane','Warlock-Destruction','Shaman-Elemental','DemonHunter-Havoc','Hunter-Survival','Warrior-Protection','Paladin-Protection','Paladin-Retribution','Paladin-Holy','Shaman-Restoration','Monk-Brewmaster','Warrior-Fury','Druid-Restoration','Druid-Guardian','Warlock-Demonology','Unknown-Unknown','Mage-Frost','Hunter-Marksmanship','Evoker-Devastation','Monk-Mistweaver','DeathKnight-Blood','Monk-Windwalker','Priest-Holy','Druid-Balance','Rogue-Outlaw','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Unholy','Mage-Fire','Druid-Feral','Priest-Shadow','Warlock-Affliction',}; local provider = {region='CN',realm='激流之傲',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ad='Adniy:BAAALAADCgEIAQAAAA==.',Aq='Aquarius:BAAALAAECgYICAAAAA==.',Ar='Arborin:BAAALAAECgQICgAAAA==.Aries:BAAALAAECgYIEQAAAA==.',As='Asunal:BAABLAAFFH8FAAMBAAMIcw8dDQDTAAABAAMIcw8dDQDTAAACAAEIvhUwCwBSAAAAAA==.',Ay='Ayã:BAABLAAFFH8FAAIDAAIIXxluiwBHAAADAAIIXxluiwBHAAAAAA==.',Ca='Caesarr:BAAALAAECgcIBwAAAA==.',Ch='Chyeang:BAAALAAFFAIIAgAAAA==.',De='Deadace:BAAALAAECgcIBwAAAA==.',Di='Dieofaoe:BAABLAAFFH8GAAIEAAQIJhoPTwDmAAAEAAQIJhoPTwDmAAAAAA==.',Dr='Dragonfs:BAABLAAFFH8PAAIFAAMI8RNxPgChAAAFAAMI8RNxPgChAAAAAA==.Dragons:BAABLAAFFH8HAAIGAAIIWBySPwCYAAAGAAIIWBySPwCYAAAAAA==.',Ea='Ea:BAAALAAECgIIAgAAAA==.',El='Elegia:BAAALAAECgcIDQAAAA==.Elohar:BAAALAAECgIIAgAAAA==.',Ep='Epon:BAAALAAECgYIEQAAAA==.',Fi='Fint:BAAALAAECgEIAQAAAA==.',Fo='Foward:BAAALAAECggICAAAAA==.',Fu='Fuita:BAAALAAECgIIAgAAAA==.',Ha='Hack:BAAALAADCgcIBwAAAA==.Hagnes:BAAALAADCggICAAAAA==.Hasee:BAAALAAECggIDgAAAA==.',Ho='Holiday:BAAALAAECgYIBgAAAA==.',Ic='Iceyu:BAAALAAECgMIAwAAAA==.',Ke='Kevoss:BAAALAAECgYICQAAAA==.',Lu='Luciferphil:BAAALAAECgYICgAAAA==.Lukc:BAABLAAFFH8UAAIHAAUItRGeJQAaAQAHAAUItRGeJQAaAQAAAA==.',Lv='Lv:BAABLAAFFH8LAAIIAAII3B6RLgCtAAAIAAII3B6RLgCtAAAAAA==.',Ma='Mardrm:BAAALAAECgYIDQAAAA==.Maste:BAAALAAECgUIBQAAAA==.Maxver:BAAALAADCgEIAQAAAA==.Maycat:BAAALAADCgYIAwAAAA==.Maymay:BAABLAAFFH8GAAIFAAYIehiqHwCYAQAFAAYIehiqHwCYAQAAAA==.',Mo='Momota:BAABLAAFFH8GAAIIAAYIEQy8JgBaAQAIAAYIEQy8JgBaAQAAAA==.',Na='Naer:BAAALAAECgYIBgAAAA==.',Qc='Qcao:BAAALAAECgIIAgAAAA==.',Ra='Raininthesun:BAAALAADCgIIAgAAAA==.',Re='Refused:BAABLAAECn8XAAMJAAYIMSS2BgBgAgAJAAYIXSO2BgBgAgADAAYIER4KZQARAgAAAA==.Rehenter:BAAALAAFFAMIAwAAAA==.',Sk='Skye:BAABLAAFFH8GAAIGAAYIaQ8dOwAbAQAGAAYIaQ8dOwAbAQAAAA==.',Sp='Spitfire:BAAALAADCggICAAAAA==.',St='Starboy:BAAALAAECgcIDwAAAA==.',Ti='Tinychenss:BAABLAAFFH8GAAIKAAYIJBSsEQA6AQAKAAYIJBSsEQA6AQAAAA==.',Un='Unaq:BAACLAAFFH8iAAMLAAYIShnxBQB5AQALAAYIShnxBQB5AQAMAAUIDRCzLAAfAQAsAAQKfxcAAgsACAhLIRsJAOgCAAsACAhLIRsJAOgCAAAA.Unas:BAAALAAFFAIIBAAAAA==.',Vi='Vivi:BAACLAAFFH8fAAMMAAUIbRpVFQAPAQALAAUIERihCQAZAQAMAAMIdh1VFQAPAQAsAAQKfzgABA0ACAh3JEgDADIDAA0ACAh3JEgDADIDAAwACAjUI98cAP8CAAsABQhLGeoUAHMBAAAA.',Xc='Xcao:BAABLAAFFH8PAAMOAAYIQgkHSQCLAAAOAAIIFhgHSQCLAAAHAAUIUAGFSQA+AAAAAA==.',Ys='Ysxhr:BAAALAADCggICAAAAA==.',Yz='Yzhnqs:BAABLAAFFH8FAAILAAMIBxm6CgDAAAALAAMIBxm6CgDAAAABLAAFFAgIHwAPAJwjAA==.',['一刀']='一刀:BAAALAAECgYIEgABLAAFFAgIOAAQAHgjAA==.',['一只']='一只小猫咪:BAAALAAFFAIIBAAAAA==.一只花太牛:BAABLAAFFH8OAAIRAAUIzQ2nKADSAAARAAUIzQ2nKADSAAAAAA==.',['一心']='一心狂暴:BAAALAAECgYICQAAAA==.',['一念']='一念神魔:BAAALAAECgYICgAAAA==.',['一捅']='一捅出血:BAAALAADCgIIAgAAAA==.',['一步']='一步:BAAALAAECgYICgAAAA==.',['一贱']='一贱成名:BAAALAAECgYIDAAAAA==.',['七夜']='七夜倾情:BAAALAADCggICAAAAA==.',['三步']='三步:BAAALAAECgYIDgAAAA==.',['上帝']='上帝的救赎:BAAALAAFFAIIAgAAAA==.',['不堪']='不堪重妇:BAAALAAECgYICwAAAA==.',['不拉']='不拉丁铜须:BAAALAADCgYIBgAAAA==.',['不要']='不要说话:BAABLAAFFH8GAAIIAAYIahXzOACsAAAIAAYIahXzOACsAAABLAAFFAgIBgAKACQUAA==.',['丑得']='丑得要死:BAACLAAFFH8WAAIEAAcIVBWIFADtAQAEAAcIVBWIFADtAQAsAAQKfxgAAgQABghyD0H+AEYBAAQABghyD0H+AEYBAAAA.',['丘丶']='丘丶比特:BAAALAAECgEIAQAAAA==.',['东啸']='东啸山:BAAALAAECgEIAQAAAA==.',['东瓜']='东瓜酱拌面:BAAALAAFFAQIAQABLAAFFAgIBwAQAEIWAA==.',['丨淡']='丨淡淡悲殇丨:BAAALAADCggICgAAAA==.',['中年']='中年油腻大叔:BAAALAAECgYIDwAAAA==.',['丶刘']='丶刘凤儿:BAAALAAECgIIAgAAAA==.',['丶戰']='丶戰爹丶:BAAALAAECggICwAAAA==.',['乖乖']='乖乖小熊猫:BAABLAAFFH8FAAISAAUIfg/vBADhAAASAAUIfg/vBADhAAAAAA==.',['九步']='九步:BAABLAAECn8YAAITAAYIrxyYDACaAQATAAYIrxyYDACaAQAAAA==.',['乾丶']='乾丶:BAAALAAECgIIAgAAAA==.',['二弟']='二弟关云长:BAAALAAECgYIBQAAAA==.',['二步']='二步:BAABLAAECn8YAAIMAAYI8x0nbgANAgAMAAYI8x0nbgANAgAAAA==.',['云南']='云南老表:BAAALAAFFAIIBAAAAA==.',['五步']='五步:BAAALAADCgUIBgAAAA==.',['亵渎']='亵渎者小周:BAAALAAFFAIIAgAAAA==.',['人工']='人工智能一号:BAAALAAECggICAABLAAFFAgIJAAPAFYmAA==.',['今夜']='今夜有雨:BAAALAAFFAIIAwAAAA==.',['从小']='从小就很帅:BAAALAAECgIIAgAAAA==.',['从尐']='从尐就鋌乖:BAAALAADCgMIAwAAAA==.',['仙赛']='仙赛学院:BAAALAAECgYIEQAAAA==.',['伐竹']='伐竹取道:BAABLAAECn8aAAIEAAcI2Rp9gAD5AQAEAAcI2Rp9gAD5AQAAAA==.',['优质']='优质丷果冻:BAAALAADCgYIBgAAAA==.',['伙子']='伙子:BAAALAAECgYIDAAAAA==.',['传奇']='传奇耐砍王:BAABLAAFFH8IAAIMAAIItiTkIwDDAAAMAAIItiTkIwDDAAAAAA==.',['伦纳']='伦纳德:BAABLAAFFH8GAAISAAYIyBz7AQCYAQASAAYIyBz7AQCYAQAAAA==.',['伽言']='伽言:BAABLAAECn8oAAIOAAYI3xm/LQCtAQAOAAYI3xm/LQCtAQABLAAECgYIOAAOADMgAA==.',['低位']='低位单打:BAAALAADCgEIAQAAAA==.',['低手']='低手上篮:BAAALAADCgEIBQAAAA==.',['何弃']='何弃疗:BAABLAAFFH8HAAIDAAMIwRsiRwCdAAADAAMIwRsiRwCdAAAAAA==.',['何瑞']='何瑞尔:BAAALAADCgUIBQAAAA==.',['佟湘']='佟湘玉:BAAALAAECggICAAAAA==.',['你别']='你别皱眉:BAAALAAECgQIBAAAAA==.',['使魔']='使魔无痕:BAAALAAECgYIDAAAAA==.',['依旧']='依旧是发挥:BAAALAAECgIIAgAAAA==.',['依然']='依然:BAAALAAECgQIBAAAAA==.依然哀殇:BAAALAAECgIIAgAAAA==.',['便便']='便便超人丶:BAAALAAECgQIBAAAAA==.',['倔强']='倔强的阿昆达:BAAALAAECgYICAAAAA==.',['倥白']='倥白记忆:BAAALAADCgQIBAAAAA==.',['傻馒']='傻馒:BAAALAAFFAIIAgAAAA==.',['兇兇']='兇兇的奶嘴:BAAALAAECgMIBQAAAA==.',['先秦']='先秦淑女步:BAABLAAFFH8bAAMOAAYIRBzWDgDzAQAOAAYIRBzWDgDzAQAHAAIIkgNVTwA2AAAAAA==.',['光影']='光影不離:BAAALAAECggIDgABLAAFFAQIBAAUAAAAAA==.',['兔八']='兔八哥:BAAALAADCgIIAgAAAA==.',['兔宝']='兔宝儿:BAAALAAECggICAABLAAFFAgIHwAPAJwjAA==.',['六步']='六步:BAAALAAECgQIBwAAAA==.',['兰伯']='兰伯特:BAAALAADCggICAAAAA==.',['其实']='其实很想你:BAAALAAECgYICAAAAA==.',['军团']='军团之灾:BAAALAAECgYIBwAAAA==.',['冰凌']='冰凌逸雪:BAAALAAECgUIBQAAAA==.',['冰轩']='冰轩爻魔幻:BAAALAAFFAIIAgABLAAFFAgISwAQAE4lAA==.',['冷飲']='冷飲:BAACLAAFFH8LAAIVAAMIXBR5DgB1AAAVAAMIXBR5DgB1AAAsAAQKfyEAAxUACAgnGTwbAEECABUACAgnGTwbAEECAAUABwhrDNqrACwBAAEsAAUUCAgsAAUAYCMA.',['凌羽']='凌羽:BAABLAAFFH8GAAIWAAYI8w9wBwCnAQAWAAYI8w9wBwCnAQAAAA==.',['凸爫']='凸爫灬爫凸:BAAALAADCgQIBAAAAA==.',['出家']='出家失败:BAAALAAFFAMIAwAAAA==.',['刘诗']='刘诗晨:BAAALAAFFAIIAgAAAA==.',['刘野']='刘野:BAAALAAECgYIBgAAAA==.',['前后']='前后夹击:BAAALAAECgYIDAAAAA==.',['剩枪']='剩枪游侠尾巴:BAACLAAFFH8OAAQDAAMI8hhWawCMAAADAAMI8hhWawCMAAAJAAEIywPECABDAAAWAAEIaQg8OAA2AAAsAAQKfx4ABAMACAjNIKZCAGACAAMACAjNIKZCAGACAAkABgh2G6wNAM0BABYAAwiREauYAIwAAAAA.',['加勒']='加勒比熊猫人:BAAALAADCgIIAgAAAA==.',['加鲁']='加鲁鲁:BAABLAAFFH8OAAMOAAIIFA79XABhAAAOAAIIFA79XABhAAAHAAIIrArNSAA/AAAAAA==.',['劣灬']='劣灬丶人:BAACLAAFFH8FAAIDAAIIfxZtlgBCAAADAAIIfxZtlgBCAAAsAAQKfxoAAgMABgjtIcxNAEQCAAMABgjtIcxNAEQCAAAA.',['劳动']='劳动路一姐:BAABLAAFFH8MAAIMAAYIFQsqJABQAQAMAAYIFQsqJABQAQAAAA==.',['勇太']='勇太:BAABLAAFFH8MAAIEAAUIiAmkSgAIAQAEAAUIiAmkSgAIAQAAAA==.',['勤兽']='勤兽:BAAALAAFFAQIBAAAAA==.',['北大']='北大落榜生:BAAALAAECgEIAQAAAA==.',['十一']='十一月的小德:BAABLAAFFH8GAAIRAAII2AiETQBXAAARAAII2AiETQBXAAAAAA==.',['十步']='十步:BAAALAAECgYIDAAAAA==.',['十破']='十破天:BAAALAAECgIIAgAAAA==.',['十胆']='十胆小鬼十:BAABLAAFFH8GAAIOAAII5R5rKQCxAAAOAAII5R5rKQCxAAAAAA==.',['千反']='千反田琉璃:BAAALAAECgMIAwAAAA==.',['午夜']='午夜前十分钟:BAABLAAECn8jAAIHAAgIrhU8GwDRAQAHAAgIrhU8GwDRAQAAAA==.午夜德傲天:BAAALAAECgEIAQAAAA==.',['半糖']='半糖:BAABLAAFFH8GAAIMAAYIRwrwCADXAQAMAAYIRwrwCADXAQAAAA==.',['华丽']='华丽乄俊皓:BAAALAAECgQIBwAAAA==.',['卡扎']='卡扎库杉:BAAALAAECgQIBAAAAA==.',['卡波']='卡波恰叔叔:BAAALAADCgIIAgAAAA==.',['反手']='反手掏大铞:BAAALAADCgEIAQAAAA==.',['发型']='发型很土:BAAALAADCgYIBgAAAA==.',['古夫']='古夫大帝:BAAALAAFFAIIAgAAAA==.',['只對']='只對伱訫動:BAAALAAECgUIBQAAAA==.',['叫我']='叫我陈晓莫:BAAALAAFFAYIBAAAAA==.',['可可']='可可丷:BAABLAAFFH8GAAIRAAIIeRs5LQB7AAARAAIIeRs5LQB7AAAAAA==.',['叵世']='叵世奶温:BAAALAADCgIIAgAAAA==.',['叶青']='叶青云:BAAALAAFFAEIAQAAAA==.',['君庭']='君庭敖天:BAAALAAECgQIBAABLAAFFAgIJAAXAAYcAA==.君庭须蹄:BAABLAAECn8XAAMYAAYIDw+9MQAZAQAYAAYIDw+9MQAZAQAPAAYINhL0EgAWAQABLAAFFAYIDAAZALEgAA==.君庭饕餮:BAAALAAECgYIDAAAAA==.',['吟的']='吟的一手好湿:BAABLAAFFH8OAAIRAAIIVyFZLQC3AAARAAIIVyFZLQC3AAAAAA==.',['周杰']='周杰伦:BAAALAAECgIIAgAAAA==.',['咿利']='咿利丹双刃:BAAALAAECgYICgAAAA==.',['哇库']='哇库哇库:BAAALAAECgYIBgAAAA==.',['哞哞']='哞哞不是渐层:BAABLAAFFH8IAAIDAAYIpwbbWQDhAAADAAYIpwbbWQDhAAABLAAFFAYICAAEAJ4MAA==.',['哥德']='哥德巴赫猜想:BAAALAAECgQIBAAAAA==.',['唧唧']='唧唧胖胖的:BAAALAAECgYIBgAAAA==.',['啪啪']='啪啪一声响:BAAALAAECgQIBAAAAA==.',['喵帕']='喵帕斯:BAAALAAECgMIAwAAAA==.',['嗳意']='嗳意随钟起:BAAALAADCgIIAwAAAA==.',['嗷嗷']='嗷嗷叫:BAAALAAECgEIAQAAAA==.',['囶里']='囶里橙丶:BAAALAAECgYIBgAAAA==.',['圣耀']='圣耀星辉:BAACLAAFFH8bAAIMAAUInBlJFgAJAQAMAAUInBlJFgAJAQAsAAQKfxUAAgwABgjHHy16APYBAAwABgjHHy16APYBAAAA.',['地心']='地心之战:BAAALAAFFAIIAgAAAA==.',['地狱']='地狱狂猪佩奇:BAAALAAECgQICAAAAA==.',['地蕾']='地蕾我最爱:BAACLAAFFH8SAAIMAAMIkh7pKwCyAAAMAAMIkh7pKwCyAAAsAAQKfxkAAgwACAiyIxgXAFUCAAwACAiyIxgXAFUCAAAA.',['坏人']='坏人喵:BAABLAAFFH8IAAIKAAIIXgrjJgBwAAAKAAIIXgrjJgBwAAAAAA==.',['城门']='城门炸鱼:BAABLAAECn8WAAIQAAYIqQ1WVQAVAQAQAAYIqQ1WVQAVAQAAAA==.',['壮根']='壮根若杵:BAABLAAFFH8cAAIZAAYIYQarDwACAQAZAAYIYQarDwACAQAAAA==.',['多乐']='多乐是只猫:BAABLAAFFH8IAAIEAAYIngxRQQA1AQAEAAYIngxRQQA1AQAAAA==.',['多肉']='多肉葡萄冻:BAAALAAECgIIAgAAAA==.',['夜很']='夜很静:BAAALAAECgUICgAAAA==.',['夜裳']='夜裳浓妆:BAABLAAFFH8MAAMMAAMIUgpcTABkAAALAAIIkg2HGwBuAAAMAAMI8ARcTABkAAAAAA==.',['大发']='大发:BAAALAAECgIIAgAAAA==.大发发挥:BAAALAAECgQICwAAAA==.',['大吉']='大吉吉萌妹:BAAALAADCgYIBwAAAA==.',['大杵']='大杵若桩:BAAALAAFFAIIAgAAAA==.',['大理']='大理老表:BAAALAAFFAIIAgAAAA==.',['大白']='大白兔:BAAALAADCgcIBwAAAA==.',['大锤']='大锤来了:BAAALAAFFAIIAgAAAA==.',['大鱼']='大鱼吃虾米嘿:BAAALAAECgEIAQAAAA==.',['天之']='天之残月:BAAALAADCggICAAAAA==.',['天天']='天天六三零:BAAALAAECgYIEAAAAA==.天天想念你:BAAALAAECgUIDAAAAA==.',['天雨']='天雨忧樂:BAABLAAFFH8GAAIFAAMI1AYBNQC1AAAFAAMI1AYBNQC1AAAAAA==.',['奔波']='奔波儿菠萝:BAAALAAECgUIBQAAAA==.',['奔雷']='奔雷:BAACLAAFFH8KAAIQAAUIWRoPIABrAQAQAAUIWRoPIABrAQAsAAQKfxUAAhAABgg0HekvAJoBABAABgg0HekvAJoBAAAA.',['奶粉']='奶粉加点盐:BAAALAAECgQIBAAAAA==.',['好帅']='好帅的我呀:BAAALAADCgQIBAAAAA==.',['好运']='好运來:BAACLAAFFH8YAAIDAAUI7RyHLwB5AQADAAUI7RyHLwB5AQAsAAQKfxUAAgMACAjmEpfKAHEBAAMACAjmEpfKAHEBAAAA.',['如月']='如月小舞:BAAALAAECgYIDwAAAA==.',['妖娆']='妖娆的腿毛:BAAALAAFFAIIAgAAAA==.',['姐妹']='姐妹们开扣辣:BAAALAAECgMIBAAAAA==.姐妹们快开扣:BAAALAAECgIIAgAAAA==.',['姜姜']='姜姜好:BAAALAAECgYIDAAAAA==.',['姬无']='姬无命:BAAALAAECggICAABLAAFFAgICAAVAGwEAA==.',['娜塔']='娜塔丽:BAAALAADCgMIAwAAAA==.',['嫑烎']='嫑烎:BAAALAAECgIIAgAAAA==.',['嬡沵']='嬡沵杺恏痌:BAAALAAECgYICwAAAA==.',['孤注']='孤注一掷:BAABLAAFFH8GAAIIAAYIWBxLFgC0AQAIAAYIWBxLFgC0AQAAAA==.',['孤独']='孤独:BAAALAAECgIIAgAAAA==.',['宁小']='宁小萌:BAABLAAFFH8FAAIEAAMINgpnYQCLAAAEAAMINgpnYQCLAAAAAA==.',['寂寞']='寂寞蚊子:BAAALAAECgYICQAAAA==.',['寡言']='寡言丶:BAABLAAFFH8GAAIHAAYIeBuSFwCBAQAHAAYIeBuSFwCBAQAAAA==.',['小七']='小七:BAACLAAFFH8FAAIEAAMIeAkaZgB+AAAEAAMIeAkaZgB+AAAsAAQKfxcAAgQACAjBFTo9AIoBAAQACAjBFTo9AIoBAAAA.',['小个']='小个子:BAABLAAFFH8GAAMZAAYIZwPzEwCLAAAZAAMIrAPzEwCLAAAEAAMIIwOXqgATAAAAAA==.',['小丶']='小丶姐姐:BAAALAAFFAgIBAAAAA==.',['小北']='小北鼻:BAAALAAECgYIBgAAAA==.',['小周']='小周的浩劫:BAAALAAECggICAAAAA==.',['小妖']='小妖:BAAALAAFFAMIBAAAAA==.',['小屁']='小屁孩的夏天:BAAALAAECgEIAQAAAA==.',['小柱']='小柱柱:BAAALAAECggIEAAAAA==.',['小楼']='小楼又南风丶:BAAALAADCgIIAgAAAA==.',['小槟']='小槟榔:BAAALAAFFAMIAwAAAA==.',['小漠']='小漠:BAACLAAFFH8xAAIYAAcIFRtwBQD7AQAYAAcIFRtwBQD7AQAsAAQKfxsAAxgACAhkH9kMAJkCABgACAhkH9kMAJkCABoAAwjSA1tfAGsAAAAA.',['小火']='小火车:BAAALAAECggICAAAAA==.',['小烦']='小烦烦:BAABLAAFFH8TAAIGAAYIYQxmLQDPAAAGAAYIYQxmLQDPAAAAAA==.',['小煤']='小煤球快跑:BAABLAAFFH8MAAIHAAQIzw8THADWAAAHAAQIzw8THADWAAABLAAFFAgICAAFAMQcAA==.',['小熊']='小熊软糖:BAABLAAFFH8SAAIRAAYIVxfDEgCmAQARAAYIVxfDEgCmAQAAAA==.',['小笼']='小笼包:BAABLAAFFH8IAAIOAAIIDhFXRwB1AAAOAAIIDhFXRwB1AAAAAA==.',['小羊']='小羊奶芙:BAAALAAFFAYIAgAAAA==.',['小舟']='小舟潮:BAABLAAFFH8SAAIGAAYIgRLXKwBrAQAGAAYIgRLXKwBrAQAAAA==.小舟澪:BAABLAAFFH8MAAIGAAYIFRaUJgB/AQAGAAYIFRaUJgB/AQAAAA==.',['小芙']='小芙遥:BAABLAAFFH8GAAIbAAIIeA0GOACDAAAbAAIIeA0GOACDAAABLAAFFAgIBgAKACQUAA==.',['小酸']='小酸奶守护者:BAAALAAFFAIIBAAAAA==.',['小风']='小风哥:BAAALAAECggIDAAAAA==.',['尐圣']='尐圣:BAAALAAECgQICQAAAA==.',['少帅']='少帅:BAAALAADCggICAAAAA==.',['尘千']='尘千枫:BAAALAAECgYIBgAAAA==.',['尘封']='尘封旧叶:BAAALAAECgQIBAAAAA==.',['尛笨']='尛笨孩:BAAALAAFFAIIAgAAAA==.',['尛綿']='尛綿羊:BAAALAAECgEIAgAAAA==.',['尼尼']='尼尼:BAAALAAFFAEIAQAAAA==.',['屠戮']='屠戮者小周:BAAALAAFFAIIAgAAAA==.',['山有']='山有扶苏:BAAALAAFFAIIAgAAAA==.',['崽丶']='崽丶:BAABLAAFFH8bAAMRAAUIABuyEwCdAQARAAUIABuyEwCdAQAcAAII/QXxKQBlAAAAAA==.崽丶僧:BAAALAAECgEIAQAAAA==.崽丶骑:BAABLAAFFH8PAAMNAAUILxroDgCXAQANAAUILxroDgCXAQAMAAEIrAKPggAlAAAAAA==.',['崽灬']='崽灬:BAAALAAECgUIBQAAAA==.崽灬電:BAABLAAFFH8FAAMOAAQIYAhDSwCGAAAOAAMIFwlDSwCGAAAHAAIIZgfyTgA2AAAAAA==.',['巴克']='巴克娜:BAAALAADCgEIAQAAAA==.',['布丁']='布丁大魔王:BAABLAAFFH8GAAIHAAYIkAdxIgAvAQAHAAYIkAdxIgAvAQAAAA==.布丁酱:BAAALAAFFAMIAgABLAAFFAYILQAVAH8YAA==.',['平生']='平生我自知:BAAALAAECgYIBgAAAA==.',['年华']='年华:BAAALAADCgcIBwAAAA==.',['库洛']='库洛洛鲁西鲁:BAACLAAFFH8PAAMdAAQIASC0AQAfAQAdAAQIASC0AQAfAQAeAAEIcAHdJAA3AAAsAAQKfykABB0ACAiRJMEAAFoDAB0ACAiRJMEAAFoDAB4AAwgQGfpQAOgAAB8AAwi9DQg/AKMAAAAA.',['廿一']='廿一是只猫:BAAALAAFFAIIAgABLAAFFAYICAAEAJ4MAA==.',['德不']='德不配喂:BAACLAAFFH8aAAIRAAUIXBdeGQBjAQARAAUIXBdeGQBjAQAsAAQKfyYAAxEABgi4HT4bAPUBABEABgi4HT4bAPUBABIAAwgPCa4lAEoAAAEsAAUUBggbAA4ARBwA.',['心有']='心有半亩花田:BAABLAAFFH8IAAIbAAgIMAAmTQBFAAAbAAgIMAAmTQBFAAAAAA==.',['怀特']='怀特迈恩丶:BAAALAAFFAMIBAAAAA==.',['悄咪']='悄咪滴进村儿:BAABLAAECn8WAAMfAAgInxcqEAA6AgAfAAgITxYqEAA6AgAeAAgIlQxoLwCwAQAAAA==.',['悦惜']='悦惜:BAAALAADCgEIAQAAAA==.',['情之']='情之亦心往:BAAALAAFFAIIAgAAAA==.',['我有']='我有牛奶:BAAALAAECgIIAgAAAA==.',['我爱']='我爱一条柴:BAAALAAECggICAAAAA==.',['手冲']='手冲熊豪:BAABLAAFFH8QAAIKAAUIwwWaGwCsAAAKAAUIwwWaGwCsAAAAAA==.',['扶摇']='扶摇上青山:BAAALAADCgcICQAAAA==.',['把酒']='把酒戏红尘:BAAALAADCggIEAAAAA==.把酒自欢愉:BAAALAAECgYIDAAAAA==.',['拉斯']='拉斯维纳:BAAALAAECgYIBwAAAA==.',['拔剑']='拔剑忘抹毒:BAAALAAECgYICQAAAA==.',['挽晚']='挽晚:BAAALAAECgYICwAAAA==.',['接著']='接著樂接着舞:BAAALAADCggICAAAAA==.',['掼蛋']='掼蛋大师:BAABLAAFFH8JAAIXAAIIMR7VEwCzAAAXAAIIMR7VEwCzAAAAAA==.',['撒结']='撒结婚的:BAAALAAECgQIAgAAAA==.',['放开']='放开那名女子:BAAALAAFFAQIBAAAAA==.',['救世']='救世神棍萨:BAAALAAECgUICAAAAA==.',['文質']='文質栤栤:BAAALAAFFAMIAwAAAA==.',['斌宝']='斌宝:BAAALAAFFAQIBAAAAA==.',['斜月']='斜月垂光丶:BAAALAAECgUIBAABLAAFFAgIIAAQAN8dAA==.',['斯洛']='斯洛特:BAAALAAECgcIDgAAAA==.',['无所']='无所畏惧先生:BAAALAAECgcIDgAAAA==.',['无敌']='无敌菜包:BAABLAAFFH8IAAIbAAIIkAWWRwBbAAAbAAIIkAWWRwBbAAAAAA==.',['无衣']='无衣:BAAALAAECggICAAAAA==.',['日一']='日一一:BAAALAAECgMIAwAAAA==.',['早餐']='早餐店劫匪:BAAALAADCgQIBAAAAA==.',['星空']='星空下的情觞:BAAALAAFFAIIAgAAAA==.',['映梅']='映梅来了:BAABLAAFFH8HAAMcAAUIqxKzCQCVAQAcAAUIqxKzCQCVAQARAAIIxgP1RgBWAAAAAA==.',['春利']='春利:BAAALAADCgYIBgAAAA==.',['春袋']='春袋砸核桃:BAAALAAFFAYIAgAAAA==.',['暗影']='暗影追猎:BAAALAADCgYIBgAAAA==.',['暗月']='暗月星魂:BAAALAADCggICAAAAA==.暗月血影:BAAALAAECgYICQAAAA==.',['暗黑']='暗黑丹丹:BAABLAAFFH8GAAIEAAIIEgb+jAB7AAAEAAIIEgb+jAB7AAAAAA==.',['暴躁']='暴躁丶小静静:BAAALAAECgQIBAAAAA==.',['月光']='月光倾城:BAABLAAFFH8MAAIGAAYIDgjoSACYAAAGAAYIDgjoSACYAAAAAA==.月光光照大王:BAAALAADCgEIAQAAAA==.',['月宝']='月宝儿:BAAALAAECggICAAAAA==.',['月柒']='月柒妖梦:BAAALAAECggICAAAAA==.',['月梦']='月梦上青楼:BAABLAAECn8XAAIEAAcIvB72NgCeAQAEAAcIvB72NgCeAQAAAA==.',['月牙']='月牙:BAAALAAECgYIBgAAAA==.',['未来']='未来仁:BAAALAADCgMIAwAAAA==.未来可期:BAABLAAFFH8IAAIEAAIIPAVHlAA8AAAEAAIIPAVHlAA8AAAAAA==.',['本座']='本座德艺双馨:BAAALAAECgMIAwAAAA==.本座略懂拳脚:BAAALAAECgYIEgAAAA==.',['机智']='机智的大菜刀:BAABLAAFFH8VAAIEAAYIXhndLACFAQAEAAYIXhndLACFAQAAAA==.',['杀破']='杀破熊哥:BAAALAAFFAMIAwAAAA==.',['李二']='李二狗他老汉:BAAALAADCgIIAgAAAA==.',['李狗']='李狗蛋超级凶:BAACLAAFFH8yAAMgAAUI9R96BAAvAQAEAAUIYx+VMgBxAQAgAAQIbx16BAAvAQAsAAQKfyoAAwQACAi1IqkhAPIBACAABgj5IFwXAAYCAAQABwjIIKkhAPIBAAAA.',['李白']='李白:BAABLAAFFH8UAAMTAAUIHB//BgC5AAAGAAQIbBkLQQDoAAATAAMICiD/BgC5AAAAAA==.',['杨仔']='杨仔灬小德:BAABLAAFFH8WAAIRAAYI5hcEEQC5AQARAAYI5hcEEQC5AQAAAA==.杨仔灬萨满:BAABLAAFFH8XAAMOAAYIBw8FJwAqAQAOAAYIBw8FJwAqAQAHAAIIoQMwUwArAAAAAA==.',['杨哒']='杨哒哒:BAABLAAFFH8GAAISAAYI8QmqBADxAAASAAYI8QmqBADxAAAAAA==.',['杨小']='杨小婲:BAACLAAFFH8GAAIMAAIIHh5TJgC9AAAMAAIIHh5TJgC9AAAsAAQKfyMAAwwACAj/Ie4XABUDAAwACAixIe4XABUDAAsACAh6HK4GAEYCAAAA.',['枫叶']='枫叶下的猫:BAAALAADCgYIBgAAAA==.枫叶下的白毛:BAACLAAFFH8KAAIEAAIIECKLNgDFAAAEAAIIECKLNgDFAAAsAAQKfxgAAgQABgjBJJBEAHQCAAQABgjBJJBEAHQCAAAA.枫叶下的鱼:BAAALAAECgUIBQAAAA==.',['柚子']='柚子气泡水:BAAALAADCgcIBwAAAA==.',['槑乄']='槑乄冷兮:BAAALAAECgIIAgAAAA==.',['欧罗']='欧罗拉丶栖夜:BAABLAAFFH8GAAMMAAII8QwaXACDAAAMAAIIxQcaXACDAAALAAII8QzcIAAqAAAAAA==.',['欻霊']='欻霊:BAABLAAFFH8IAAMWAAIIOgURLwBlAAAWAAIIeQQRLwBlAAADAAII/wQfuwAuAAAAAA==.',['步青']='步青瑶:BAAALAAECgYIBgAAAA==.',['残念']='残念無双:BAAALAAECgIIAgAAAA==.',['毁灭']='毁灭吧麻了:BAABLAAFFH8GAAIGAAYIFSAmBgBVAgAGAAYIFSAmBgBVAgAAAA==.',['母草']='母草:BAABLAAFFH8HAAMRAAQIcxs7KgDIAAARAAIIuSI7KgDIAAAcAAII1RJlIACKAAAAAA==.',['水牛']='水牛:BAAALAAECgYIBgAAAA==.',['氵崽']='氵崽灬:BAABLAAFFH8HAAIbAAQIrwvwKADmAAAbAAQIrwvwKADmAAAAAA==.',['永恒']='永恒之钇:BAABLAAFFH8GAAILAAYI6ABeIwAjAAALAAYI6ABeIwAjAAAAAA==.永恒之镅:BAABLAAFFH8IAAIKAAgIUwGYIAB0AAAKAAgIUwGYIAB0AAAAAA==.',['氿伍']='氿伍贰柒:BAABLAAECn8UAAQVAAYIGSB7EwCWAQAVAAYIGSB7EwCWAQAhAAEIfQ7XEwA4AAAFAAEIVghodQAxAAAAAA==.',['氿爷']='氿爷:BAABLAAFFH8GAAIiAAIInhqODABMAAAiAAIInhqODABMAAAAAA==.',['求求']='求求你别说了:BAAALAAECgYIBgAAAA==.',['汪汪']='汪汪队立大功:BAABLAAFFH8IAAIQAAgIFwEBYAA0AAAQAAgIFwEBYAA0AAAAAA==.',['沃德']='沃德:BAAALAADCgYIBgAAAA==.',['没有']='没有恋爱天赋:BAAALAAECgcIEgAAAA==.',['法魂']='法魂魔神:BAAALAAECgIIAgAAAA==.',['泡泡']='泡泡小牛:BAAALAADCgIIAgAAAA==.',['注水']='注水牛肉五妹:BAAALAADCgIIAgAAAA==.注水牛肉大哥:BAAALAAECgYIBwAAAA==.注水牛肉老娘:BAAALAADCgQIBAAAAA==.',['泽成']='泽成美雪:BAAALAAECgQIBAAAAA==.',['洛克']='洛克塔:BAABLAAFFH8LAAIEAAUI0hIySAAYAQAEAAUI0hIySAAYAQAAAA==.',['洛其']='洛其飞:BAAALAAECgYICgAAAA==.',['浅时']='浅时光:BAAALAAFFAEIAQAAAA==.',['浪浪']='浪浪山小当家:BAABLAAFFH8IAAIEAAgItAASogAzAAAEAAgItAASogAzAAAAAA==.',['深冬']='深冬:BAAALAAECgYICgAAAA==.',['清华']='清华落榜生:BAAALAAECgYIBwAAAA==.',['清歌']='清歌扶酒:BAAALAADCgcIBwAAAA==.',['渡海']='渡海的浮囊:BAAALAADCgEIAQABLAADCggICAAUAAAAAA==.',['湘灵']='湘灵:BAABLAAFFH8LAAIFAAII/w6UUQCPAAAFAAII/w6UUQCPAAAAAA==.',['湛澜']='湛澜:BAAALAADCgcIBwAAAA==.',['火球']='火球快递员:BAAALAAECgMIAwAAAA==.',['灬喷']='灬喷火龙灬:BAAALAADCgMIBgAAAA==.',['灬淡']='灬淡淡蕜傷灬:BAAALAADCgEIAQAAAA==.',['灰机']='灰机逝者:BAAALAAECgYIBgAAAA==.',['灵光']='灵光一闪:BAABLAAFFH8GAAIMAAYICAbWKQAvAQAMAAYICAbWKQAvAQAAAA==.',['灵珊']='灵珊三凌:BAAALAAECgIIAgAAAA==.',['烟雨']='烟雨丶:BAAALAAECgYICQAAAA==.',['烣烬']='烣烬之炽:BAAALAAECgUIBwAAAA==.',['焚天']='焚天纪:BAAALAAECgYIEAAAAA==.',['然然']='然然:BAABLAAFFH8GAAIHAAYImxB9TgA3AAAHAAYImxB9TgA3AAAAAA==.',['熊猫']='熊猫老大:BAAALAAECggICgAAAA==.',['熊盖']='熊盖无双:BAAALAADCgcIBwAAAA==.',['熊里']='熊里安乌瑞恩:BAAALAAECgIIAgAAAA==.',['燎原']='燎原拾六强:BAAALAAECgQIBAAAAA==.',['爱不']='爱不过时光:BAAALAAECgYIBgAAAA==.',['爱派']='爱派德:BAABLAAECn8XAAIRAAYIpSAMOwDzAQARAAYIpSAMOwDzAQAAAA==.',['版本']='版本之子:BAAALAAECgIIAgAAAA==.',['牛气']='牛气天下:BAABLAAFFH8SAAIRAAYIhxRbEgCrAQARAAYIhxRbEgCrAQAAAA==.',['牛牛']='牛牛不卖萌:BAAALAAFFAIIBAAAAA==.牛牛百步穿杨:BAAALAAECgYIDAAAAA==.',['牧云']='牧云丶清歌:BAAALAAECgEIAQAAAA==.',['牧无']='牧无王法:BAAALAAECgYIDAAAAA==.',['物远']='物远:BAAALAAECgYICAAAAA==.',['特洛']='特洛伊德:BAAALAAECggIDwAAAA==.',['犟烎']='犟烎:BAAALAAECgYIBgAAAA==.',['狂砍']='狂砍一条街:BAAALAAECgEIAgAAAA==.',['狩猎']='狩猎三哥:BAAALAADCgIIAgAAAA==.',['狼爸']='狼爸爸:BAABLAAFFH8FAAIQAAUIHA/DKAAoAQAQAAUIHA/DKAAoAQAAAA==.',['猎肠']='猎肠者蝳釰:BAABLAAFFH8JAAIJAAIIXwvABQBCAAAJAAIIXwvABQBCAAAAAA==.',['猛邪']='猛邪鬼:BAABLAAFFH8GAAIKAAYIkwrDFQAJAQAKAAYIkwrDFQAJAQAAAA==.',['猫咖']='猫咖啡:BAAALAAFFAIIAwAAAA==.',['猫的']='猫的冰咖啡:BAABLAAFFH8HAAIYAAUIdAU8DgDxAAAYAAUIdAU8DgDxAAAAAA==.',['獠刹']='獠刹:BAABLAAFFH8SAAMKAAUIgAfBGgC7AAAKAAUIFQfBGgC7AAAQAAEINQnDWwA6AAAAAA==.獠刹德鲁尔:BAABLAAFFH8NAAISAAYIKANWBgCkAAASAAYIKANWBgCkAAAAAA==.',['玛力']='玛力亚:BAAALAADCgEIAQAAAA==.',['玛德']='玛德:BAACLAAFFH8PAAMSAAYI5gz+AwARAQASAAYI5gz+AwARAQARAAMIPxnnGgC2AAAsAAQKfxwAAhEABgh/I+4jAFkCABEABgh/I+4jAFkCAAAA.',['玛雅']='玛雅达婕妮:BAABLAAFFH8ZAAMbAAUIIhffGwBvAQAbAAUIIhffGwBvAQAjAAII5AZILgA5AAAAAA==.',['玩电']='玩电萨的小周:BAAALAAECgIIAgAAAA==.',['玳瑁']='玳瑁丨猫爪草:BAACLAAFFH8IAAIbAAUIMAlrKADrAAAbAAUIMAlrKADrAAAsAAQKfyAAAhsABwiSFKhKAKsBABsABwiSFKhKAKsBAAAA.',['瑶光']='瑶光:BAAALAAECgYIBwAAAA==.',['瑾若']='瑾若流年:BAAALAAECgIIAgAAAA==.',['甜橙']='甜橙气泡水:BAAALAADCgUIBQAAAA==.',['甜甜']='甜甜的甜甜圈:BAAALAAECggICAAAAA==.',['生前']='生前是个丑丑:BAAALAAECgQIBAAAAA==.生前是圣骑:BAACLAAFFH8sAAMEAAYIJyJUFADuAQAEAAYIJyJUFADuAQAgAAMIUwmUFQCAAAAsAAQKfyEAAwQACAjPHcBbAD4CAAQACAh0HcBbAD4CACAABAiXG/M4ABABAAAA.',['留頭']='留頭人法師:BAACLAAFFH8OAAIQAAIIbyBsNgCYAAAQAAIIbyBsNgCYAAAsAAQKfxUAAhAABghwIPdBAC4CABAABghwIPdBAC4CAAAA.',['疯狂']='疯狂折耳根:BAAALAAECggICAAAAA==.',['白木']='白木:BAABLAAFFH8FAAIbAAIIshj1OQB4AAAbAAIIshj1OQB4AAAAAA==.',['白织']='白织:BAABLAAFFH8IAAIZAAIIJgcxFABsAAAZAAIIJgcxFABsAAAAAA==.',['白银']='白银月亮骑士:BAABLAAFFH8IAAIOAAIIZg9VSQByAAAOAAIIZg9VSQByAAAAAA==.',['百地']='百地希留耶:BAAALAADCggICAAAAA==.',['皇莆']='皇莆狗蛋:BAAALAAECgcIEQAAAA==.',['真的']='真的只是脚滑:BAABLAAFFH8PAAIIAAQICQoGNgDPAAAIAAQICQoGNgDPAAAAAA==.',['破晓']='破晓归来:BAABLAAFFH8XAAIQAAUIvhAIJwA4AQAQAAUIvhAIJwA4AQAAAA==.破晓骄阳:BAABLAAFFH8WAAMcAAYIRRWjDwBzAQAcAAYIRRWjDwBzAQARAAII7QyYSQBdAAAAAA==.',['神棍']='神棍一头:BAAALAAECgYICAAAAA==.',['神龙']='神龙侠阿宝:BAAALAAECgYIEQAAAA==.神龙大侠丶:BAAALAAECgYIBgAAAA==.',['祥子']='祥子:BAABLAAECn8fAAIMAAYI7x8hZQAgAgAMAAYI7x8hZQAgAgAAAA==.',['禁闭']='禁闭室报到:BAAALAAECgYIDAAAAA==.',['禾央']='禾央央:BAABLAAFFH8IAAIbAAMINBA9MACqAAAbAAMINBA9MACqAAAAAA==.',['秒躺']='秒躺猝死专员:BAAALAAFFAIIAgAAAA==.',['秦史']='秦史皇:BAAALAADCgYIBgAAAA==.',['第叄']='第叄稳限:BAAALAAECgEIAQAAAA==.',['筒仔']='筒仔米糕:BAAALAAECgYIEAAAAA==.',['筱邪']='筱邪鬼:BAAALAAECggIDAAAAA==.',['箭见']='箭见脱靶:BAAALAADCgYICAAAAA==.',['米拉']='米拉:BAAALAADCgEIAQAAAA==.',['紋畵']='紋畵刄:BAAALAAECgYICgAAAA==.',['紫雨']='紫雨夕颜:BAAALAAECgUIBQAAAA==.',['纳個']='纳個灬德:BAAALAADCgIIAgAAAA==.',['练霓']='练霓裳:BAABLAAECn8lAAMDAAYIWR5nkgDAAQADAAYIWR5nkgDAAQAWAAEIkxFZwAAwAAAAAA==.',['结野']='结野克莉丝特:BAAALAADCggICAAAAA==.',['维他']='维他命:BAAALAAFFAIIAgAAAA==.',['维多']='维多利亚:BAABLAAFFH8FAAIDAAUIMBeUSQAlAQADAAUIMBeUSQAlAQAAAA==.',['绿林']='绿林出好汉:BAAALAAFFAIIAgAAAA==.',['绿野']='绿野之愈:BAAALAAECgYIBgAAAA==.',['老二']='老二巨踏马帅:BAACLAAFFH8RAAMEAAYIBBbSKwCJAQAEAAYIOhXSKwCJAQAZAAEIYRWZFwBGAAAsAAQKfxUAAgQABgilHjE5AJcBAAQABgilHjE5AJcBAAAA.老二帅爆了:BAAALAADCgIIAgAAAA==.老二胖胖哒:BAACLAAFFH8HAAIYAAIIhBc7EQCMAAAYAAIIhBc7EQCMAAAsAAQKfyIABBgABgjSH/ELAPcBABgABgjSH/ELAPcBABoABQilFL0XAE0BAA8AAQhwCUkrAAAAAAEsAAUUBggRAAQABBYA.',['老毕']='老毕登:BAAALAAECgMIAwAAAA==.',['老爷']='老爷爷归来:BAABLAAFFH8KAAIIAAIImxx2MQCnAAAIAAIImxx2MQCnAAAAAA==.',['背后']='背后报菊华丶:BAAALAAECgYIBgAAAA==.',['胸奴']='胸奴李狗蛋:BAABLAAFFH8HAAIDAAII4Q4/ZACJAAADAAII4Q4/ZACJAAAAAA==.',['腐竹']='腐竹牛腩:BAAALAADCgEIAQAAAA==.',['腾汛']='腾汛安全助手:BAAALAAFFAMIAwAAAA==.',['舞炫']='舞炫神迷:BAABLAAFFH8fAAIPAAgInCNAAAATAwAPAAgInCNAAAATAwAAAA==.',['艾米']='艾米莉娅:BAAALAAECgYICgAAAA==.',['芙遥']='芙遥丶:BAAALAAFFAQIBAAAAA==.',['花神']='花神路过:BAABLAAECn8WAAIDAAYIJiLAOADgAQADAAYIJiLAOADgAQAAAA==.',['芷菀']='芷菀:BAACLAAFFH8MAAIIAAQIcAwANQDcAAAIAAQIcAwANQDcAAAsAAQKfxsAAggACAgxF4MaAAkCAAgACAgxF4MaAAkCAAAA.',['菊纹']='菊纹解锁:BAAALAAECgIIAgAAAA==.',['菜依']='菜依琳:BAAALAADCgUIBQAAAA==.',['萌味']='萌味丶巧訫结:BAAALAAECgIIAgAAAA==.',['落箭']='落箭:BAACLAAFFH8GAAIDAAIIKw+HjgBGAAADAAIIKw+HjgBGAAAsAAQKfyEAAwMACAgFHu85AHgCAAMACAgFHu85AHgCABYAAgj3CEi+ADMAAAAA.',['落花']='落花叩玉枕:BAAALAAECgIIAgAAAA==.落花无痕:BAAALAAECgEIAQAAAA==.',['葵花']='葵花点泬掱:BAAALAAECgMIAwAAAA==.',['薇琪']='薇琪儿小古寨:BAAALAAFFAIIAgAAAA==.',['薛定']='薛定谔的雾:BAACLAAFFH8MAAIYAAQI7Q41DgDyAAAYAAQI7Q41DgDyAAAsAAQKfxYAAhgABgjpGckOAL8BABgABgjpGckOAL8BAAEsAAUUBggbAA4ARBwA.',['薩瑪']='薩瑪豊頓大臣:BAAALAADCgIIAgAAAA==.',['虎啸']='虎啸龙吟:BAAALAADCgMIAwAAAA==.',['蛋疼']='蛋疼大师:BAAALAADCgYIBgAAAA==.',['蝴蝶']='蝴蝶吻花香:BAAALAAECgMIAwAAAA==.',['血之']='血之霜殇:BAAALAAECgYIBgAAAA==.',['血夜']='血夜:BAABLAAECn8gAAIEAAYIZBxikwDaAQAEAAYIZBxikwDaAQAAAA==.',['裂肠']='裂肠熊一:BAABLAAFFH8HAAIPAAMIPgIvHgA+AAAPAAMIPgIvHgA+AAAAAA==.',['西天']='西天九妖:BAAALAAECgYIDAAAAA==.',['西门']='西门女昌:BAAALAAECgEIAQAAAA==.西门嫖:BAAALAAECgYIBgAAAA==.',['言冰']='言冰云:BAAALAAECgYIBgAAAA==.言冰云的奶妈:BAAALAAECgYIBgAAAA==.',['言峰']='言峰神父:BAAALAAECgIIAgAAAA==.',['许愿']='许愿星基拉祈:BAABLAAFFH8GAAIIAAQIBhgOJwDCAAAIAAQIBhgOJwDCAAAAAA==.',['诛神']='诛神之冰雨:BAAALAAECgMIAwAAAA==.',['贝之']='贝之影:BAAALAAECgYICwAAAA==.',['贝克']='贝克汉姆:BAABLAAFFH8PAAIOAAYI2yN8BQBqAgAOAAYI2yN8BQBqAgAAAA==.',['贪食']='贪食丶恐王:BAAALAADCgYIBgAAAA==.',['贫僧']='贫僧略懂拳脚:BAAALAAECgYIBgAAAA==.',['贵妇']='贵妇人:BAAALAADCgIIAgAAAA==.',['贵宾']='贵宾八百八:BAAALAAECgIIAgAAAA==.',['赵德']='赵德柱:BAAALAAFFAIIAgAAAA==.',['超硬']='超硬的咯哈哈:BAAALAAECgIIAwAAAA==.',['跑的']='跑的比苟快:BAAALAAECgEIAQAAAA==.',['路过']='路过幸福:BAAALAAECgYIBgAAAA==.',['身先']='身先士卒:BAABLAAFFH8IAAIMAAYINxYbPgCaAAAMAAYINxYbPgCaAAAAAA==.',['轰炸']='轰炸机:BAAALAADCgMIAwAAAA==.',['辣椒']='辣椒炒肉拌面:BAABLAAECn8eAAIIAAYIARtAPwBfAQAIAAYIARtAPwBfAQAAAA==.',['达那']='达那多斯:BAABLAAFFH8HAAIFAAMILAO9VABGAAAFAAMILAO9VABGAAAAAA==.',['还能']='还能喝点:BAACLAAFFH8NAAIYAAMIPBJfEACzAAAYAAMIPBJfEACzAAAsAAQKfxkAAxgABghUHrcZAPABABgABghUHrcZAPABABoABghEFrMWAFYBAAAA.',['这不']='这不河里:BAAALAAECgQIBAAAAA==.',['进肚']='进肚条卡住了:BAAALAAECgIIAgAAAA==.',['迪迦']='迪迦奥特馒:BAAALAAECgEIAQAAAA==.',['追法']='追法者:BAAALAADCgYIBgAAAA==.',['道猎']='道猎:BAAALAADCgMIAgAAAA==.',['邪恶']='邪恶灬力量:BAAALAADCgEIAQAAAA==.',['邪筱']='邪筱鬼:BAAALAAECggICAAAAA==.',['部落']='部落钩子王:BAAALAAECgcICwAAAA==.',['都是']='都是我的翅膀:BAAALAAFFAIIAgABLAAFFAYIGwAOAEQcAA==.',['鄙人']='鄙人冲锋秒跪:BAAALAAECgYIBgAAAA==.',['酸萝']='酸萝卜别吃:BAAALAADCgUIBQAAAA==.',['重庆']='重庆肥牛王:BAABLAAECn8bAAMcAAYILBBxXABJAQAcAAYILBBxXABJAQARAAYIZg0HSAD2AAAAAA==.重庆酸菜鱼:BAAALAAECgYIEgAAAA==.重庆野蛮牛:BAABLAAECn8gAAIQAAYIdBL1SgA1AQAQAAYIdBL1SgA1AQAAAA==.重庆阿春家:BAABLAAECn8aAAIDAAgIIR4LGQBmAgADAAgIIR4LGQBmAgAAAA==.重庆香辣虾:BAABLAAECn8bAAIMAAgIHheXKADyAQAMAAgIHheXKADyAQAAAA==.重庆黄辣丁:BAABLAAECn8UAAMTAAYI6xvjDACWAQATAAYI6xvjDACWAQAGAAYIzwuTXwDgAAAAAA==.',['野性']='野性咕咕:BAAALAAECgEIAQAAAA==.',['针尖']='针尖对麦芒:BAAALAAECgIIAgAAAA==.',['钢铁']='钢铁般的左键:BAACLAAFFH8TAAIEAAQIoxCJUADbAAAEAAQIoxCJUADbAAAsAAQKfxcAAgQACAiTF5BUAE4CAAQACAiTF5BUAE4CAAAA.',['钱满']='钱满满:BAAALAAECgYICgAAAA==.',['铁血']='铁血李太白:BAAALAAECgUIBQAAAA==.铁血李时珍:BAAALAAECgYIBgAAAA==.铁血李清照:BAAALAAECggIBAAAAA==.',['锁甲']='锁甲费:BAAALAAECgcICQAAAA==.',['闪灵']='闪灵之影:BAABLAAFFH8GAAIfAAII/wjpFQBBAAAfAAII/wjpFQBBAAAAAA==.',['问剑']='问剑:BAAALAAFFAIIBAAAAA==.',['阿尔']='阿尔忒弥司:BAAALAAECgYIBgAAAA==.',['阿狄']='阿狄芙洛斯:BAAALAAECgUIBQAAAA==.',['阿瑞']='阿瑞斯之怒:BAABLAAFFH8TAAIEAAYINxbQKgCMAQAEAAYINxbQKgCMAQAAAA==.',['阿瓦']='阿瓦达啃口瓜:BAAALAAECgYIBwABLAAFFAYIGwAOAEQcAA==.',['阿蕾']='阿蕾克斯塔萨:BAABLAAFFH8KAAIFAAII0hOTSACXAAAFAAII0hOTSACXAAAAAA==.',['雨夜']='雨夜听花落:BAAALAAFFAIIAgAAAA==.',['雪原']='雪原的冰:BAAALAADCgMIAwAAAA==.',['雪顶']='雪顶咖啡:BAAALAAECggICAAAAA==.',['雷声']='雷声普化天尊:BAAALAADCgcIBwAAAA==.',['霍山']='霍山文峰学校:BAABLAAFFH8GAAIDAAYIhBIRDwC3AQADAAYIhBIRDwC3AQAAAA==.',['霜白']='霜白奶酥:BAAALAADCgMIAwAAAA==.',['霜风']='霜风吹吹:BAAALAAECgYICwAAAA==.霜风猎猎:BAAALAAECgUIBwAAAA==.',['霸道']='霸道折耳根:BAABLAAFFH8IAAIIAAII0BCfTwBJAAAIAAII0BCfTwBJAAAAAA==.',['青心']='青心:BAAALAADCgEIAgAAAA==.',['青春']='青春你太痘:BAABLAAFFH8IAAIeAAIIyhj6FgCjAAAeAAIIyhj6FgCjAAAAAA==.',['青涩']='青涩的回忆:BAAALAADCgQIBAAAAA==.青涩菂回忆:BAAALAADCgQIBAAAAA==.',['风洛']='风洛邪丶:BAAALAAFFAIIAgAAAA==.',['风火']='风火雷电:BAAALAAECgYIBgAAAA==.',['风起']='风起意难平:BAAALAAECgYIBgAAAA==.',['风辰']='风辰熠:BAAALAAFFAIIAgAAAA==.',['风霜']='风霜了了:BAAALAAECgEIAQAAAA==.',['飞云']='飞云:BAABLAAFFH8GAAIQAAIInAqcUwBBAAAQAAIInAqcUwBBAAAAAA==.',['馨囡']='馨囡囡:BAABLAAFFH8OAAMGAAYItiCeGQC/AQAGAAYIiyCeGQC/AQAkAAEI3CDmBQBkAAAAAA==.',['骑老']='骑老奶过马路:BAACLAAFFH8uAAMXAAYILBs1CQCQAQAXAAYILBs1CQCQAQABAAIIPgkzFgCBAAAsAAQKfycAAxcACAhWG14dADECABcACAhWG14dADECAAEAAQgAFOpCAD0AAAAA.',['鬼宝']='鬼宝宝丶:BAABLAAFFH8YAAIPAAgIdBXBBAAcAgAPAAgIdBXBBAAcAgAAAA==.',['魔域']='魔域幽兰:BAAALAAECgEIAQAAAA==.',['魔武']='魔武神甲:BAAALAAECgYIBgAAAA==.',['鲤鱼']='鲤鱼打挺:BAAALAAFFAMIAwAAAA==.',['黄块']='黄块块:BAAALAAECgYICwAAAA==.',['黑山']='黑山老妖丶:BAAALAAECgIIAgAAAA==.',['黑手']='黑手审判军:BAAALAAECgYIBgAAAA==.黑手突击兵:BAAALAADCgIIAgAAAA==.',['黑暗']='黑暗骑士:BAAALAADCgIIAgAAAA==.',['黑老']='黑老妖丶:BAAALAAECgEIAQAAAA==.',['黑脸']='黑脸骑士:BAAALAAECgIIAgAAAA==.',['黑色']='黑色牛战丶:BAAALAAECgYIDQAAAA==.',['黑锋']='黑锋:BAABLAAFFH8NAAMEAAUIuguOSgAIAQAEAAUI4AmOSgAIAQAgAAIIbg83EgCQAAAAAA==.',['龙伽']='龙伽尔:BAABLAAFFH8WAAMEAAcI0B8mDQArAgAEAAcI0B8mDQArAgAgAAEIlRVuGwBVAAAAAA==.',['龙珈']='龙珈尔:BAAALAAECgUICQAAAA==.',['龙迦']='龙迦尔:BAAALAAFFAIIAgAAAA==.',['龙门']='龙门飞甲:BAAALAAECgYIDwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end