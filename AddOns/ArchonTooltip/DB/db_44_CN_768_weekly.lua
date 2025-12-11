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
 local lookup = {'Mage-Frost','DeathKnight-Frost','Mage-Arcane','Rogue-Assassination','Rogue-Subtlety','Rogue-Outlaw','Priest-Holy','Priest-Shadow','Paladin-Retribution','Unknown-Unknown','Shaman-Restoration','Druid-Restoration','Druid-Balance','DeathKnight-Blood','Hunter-BeastMastery','Druid-Feral','Warrior-Fury','Monk-Mistweaver','Hunter-Marksmanship','DemonHunter-Havoc','Monk-Brewmaster','Warrior-Protection','Druid-Guardian','Warlock-Destruction','DemonHunter-Vengeance','Paladin-Holy','Shaman-Elemental','Warrior-Arms','Paladin-Protection','Evoker-Devastation','Evoker-Augmentation','Hunter-Survival','Warlock-Demonology','Evoker-Preservation','Warlock-Affliction','Priest-Discipline','Shaman-Enhancement','DeathKnight-Unholy',}; local provider = {region='CN',realm='甜水绿洲',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Ai:BAAALAAECgYICAAAAA==.',As='Assdadadad:BAAALAAECgEIAQAAAA==.',Ba='Ball:BAAALAAECggICAAAAA==.',Bi='Bigzai:BAAALAADCgEIAQAAAA==.',Bl='Blackpear:BAAALAAECgYIBgAAAA==.',Ca='Calafiori:BAACLAAFFH84AAIBAAcIFCGPAABUAgABAAcIFCGPAABUAgAsAAQKfzUAAgEACAiHJfICAGEDAAEACAiHJfICAGEDAAAA.',Cl='Cleven:BAAALAAECgcICAAAAA==.',Cr='Crsan:BAAALAAECgIIAgABLAAFFAYIGwACANAgAA==.',Dk='Dk:BAAALAAECgIIBAAAAA==.',Du='Duster:BAAALAAECgQIBAAAAA==.',El='Ele:BAAALAAECgIIAgAAAA==.',Fa='Faxmonkey:BAAALAADCgUIBQAAAA==.',Fl='Flinto:BAAALAAECggIDgAAAA==.',Fr='Freedomer:BAAALAAECgYICQAAAA==.',Fy='Fynx:BAAALAAECgYIBgAAAA==.',Ho='Honggor:BAAALAAECgYIDQAAAA==.',Ic='Icehotflam:BAABLAAFFH8TAAMDAAYIOiBuBQBQAgADAAYIOiBuBQBQAgABAAYIFxGKBQBnAQAAAA==.',Ja='Jackey:BAAALAADCgYICQAAAA==.Jacky:BAACLAAFFH8UAAMEAAUIrR2eCAA1AQAEAAMIMx6eCAA1AQAFAAII4xyWDgCpAAAsAAQKfyIABAQACAjHJTgGABoDAAQACAiMJDgGABoDAAUABAh6GVsqAEgBAAYAAQiOGtwdAEgAAAAA.Jackydh:BAAALAAECgQIAgABLAAFFAUIFAAEAK0dAA==.Jambo:BAABLAAFFH8GAAMHAAUIqBahJwD0AAAHAAQI3hKhJwD0AAAIAAIIowsfJgBMAAAAAA==.',Je='Jett:BAABLAAFFH8KAAIJAAMI8AsZSAB6AAAJAAMI8AsZSAB6AAAAAA==.',Ka='Kaptfionn:BAAALAAFFAIIBAABLAAFFAIIBAAKAAAAAA==.',Ke='Kennyfper:BAAALAAECgYIBgAAAA==.',La='Lalalal:BAAALAAECggIDgAAAA==.',Lu='Lukas:BAAALAAECgIIAgAAAA==.Lunar:BAAALAAECgIIAgAAAA==.',Ly='Lylian:BAABLAAFFH8GAAIDAAYIwxhDGwCtAQADAAYIwxhDGwCtAQAAAA==.',Mi='Mile:BAAALAADCgIIAgAAAA==.',My='Myprincess:BAAALAAECgYIBgAAAA==.',Na='Naowhlul:BAABLAAFFH8JAAICAAQIWAzjUQDRAAACAAQIWAzjUQDRAAAAAA==.',No='Nomoxi:BAAALAAECgUIBwAAAA==.',Ny='Nymphali:BAAALAADCgYIBgAAAA==.',Oo='Ooz:BAAALAAECgYIBgAAAA==.',Pa='Palfionn:BAAALAAFFAIIBAAAAA==.',Pu='Pulsar:BAAALAAECgQIBgAAAA==.',Re='Readyone:BAAALAAECgYIBwAAAA==.',Rk='Rktovo:BAAALAAECgYIBgAAAA==.',Ru='Rukia:BAABLAAFFH8GAAIJAAYIMwNWMgDwAAAJAAYIMwNWMgDwAAAAAA==.',Ry='Ryz:BAAALAAFFAIIAgAAAA==.',Se='Seirias:BAACLAAFFH8MAAIDAAII+hmWUgBJAAADAAII+hmWUgBJAAAsAAQKfyIAAwMACAh/HHQ6AGACAAMACAh/HHQ6AGACAAEAAQjrFBSXAC0AAAAA.',Sh='Sherryly:BAAALAAFFAIIBAAAAA==.',Sm='Smoky:BAAALAAECgUIBQAAAA==.',So='Solaris:BAAALAAECgYIDgAAAA==.',Sz='Szeretlekll:BAAALAAECgQIBAAAAA==.',Ti='Tiny:BAABLAAECn8VAAIJAAYIVhniswCZAQAJAAYIVhniswCZAQAAAA==.',To='Tom:BAAALAAECgcIDwAAAA==.',Ul='Ultrakill:BAABLAAFFH8GAAICAAIIkhIjaACUAAACAAIIkhIjaACUAAAAAA==.',Ve='Venti:BAAALAAFFAIIAgAAAA==.',Vi='Vidda:BAABLAAECn8hAAIJAAcIdCN+MACwAgAJAAcIdCN+MACwAgAAAA==.Vitatea:BAAALAAECgQIBAAAAA==.',Vl='Vldda:BAAALAAECgYIBgAAAA==.',Vv='Vvidda:BAAALAAECgQIBAAAAA==.',['一三']='一三五八:BAAALAAECgEIAQAAAA==.',['一二']='一二三亖:BAABLAAFFH8IAAIDAAII6AiFWQBCAAADAAII6AiFWQBCAAAAAA==.',['一品']='一品温如言:BAAALAAECgYIBgAAAA==.',['一水']='一水黑:BAAALAAFFAIIBAAAAA==.',['一碰']='一碰就倒地:BAAALAAECggICAAAAA==.',['一非']='一非:BAAALAADCgUIBQAAAA==.',['一颗']='一颗肉丸:BAABLAAFFH8IAAILAAYIoCFcCQAxAgALAAYIoCFcCQAxAgAAAA==.',['万剑']='万剑归宗:BAAALAAECgQIBgAAAA==.',['万灵']='万灵守护:BAAALAAECgMIAwAAAA==.',['三七']='三七:BAAALAAECgQIBAAAAA==.',['三带']='三带一:BAAALAADCgQIBgAAAA==.',['不倾']='不倾城但成熟:BAAALAAECggICQAAAA==.',['不嘚']='不嘚不牛:BAACLAAFFH8rAAIMAAYIrhp3DgDXAQAMAAYIrhp3DgDXAQAsAAQKfywAAwwACAiQHTAVALQCAAwACAiQHTAVALQCAA0ACAhvGvMnAC4CAAAA.',['不笑']='不笑猫猫:BAAALAADCgIIAgAAAA==.',['不讲']='不讲武德:BAAALAADCgIIAgAAAA==.',['专吃']='专吃小女孩:BAAALAAECgIIAgAAAA==.',['且听']='且听风声丶:BAAALAAECgYIBwAAAA==.',['丢丢']='丢丢仔:BAABLAAFFH8IAAICAAIIGCKFSgClAAACAAIIGCKFSgClAAAAAA==.',['两小']='两小胡猜:BAAALAAECgYIBgAAAA==.',['丨咕']='丨咕咕丨:BAAALAAECgIIAgAAAA==.',['丨恺']='丨恺丶屹丨:BAABLAAFFH8IAAMCAAMIOB40VgCvAAACAAMIOB40VgCvAAAOAAIIbAKfHwAgAAAAAA==.',['丨瓜']='丨瓜丨:BAAALAAECgUIBQAAAA==.',['临兵']='临兵斗者:BAAALAAECgYIAQAAAA==.',['丶轻']='丶轻而易举:BAAALAADCgEIAQAAAA==.',['丷口']='丷口丷:BAAALAAECgYIBgAAAA==.',['丹妮']='丹妮利斯:BAAALAAECgQIBAAAAA==.',['为了']='为了鸡蛋:BAAALAADCgYIBgAAAA==.',['九月']='九月風:BAAALAADCggIDgAAAA==.',['了尘']='了尘居士:BAABLAAECn8kAAIHAAcIniDVEABOAgAHAAcIniDVEABOAgAAAA==.',['二环']='二环十四郎:BAAALAAECgMIAwAAAA==.',['云灬']='云灬儿:BAABLAAFFH8IAAIHAAIIcxYCOACBAAAHAAIIcxYCOACBAAAAAA==.',['五斗']='五斗米三季稻:BAAALAADCgYIBgAAAA==.',['五火']='五火球毅哥:BAABLAAFFH8IAAIDAAIIiAoHXwB9AAADAAIIiAoHXwB9AAAAAA==.',['五迷']='五迷老师:BAAALAADCgQIBAAAAA==.',['亚瑞']='亚瑞:BAACLAAFFH8JAAIMAAIIowyTOQBmAAAMAAIIowyTOQBmAAAsAAQKfxUAAgwABwh1F8Y/AOABAAwABwh1F8Y/AOABAAAA.',['亲爱']='亲爱的老徐:BAACLAAFFH8LAAIPAAIIswMPuAAxAAAPAAIIswMPuAAxAAAsAAQKfxQAAg8ACAg4EnaIANABAA8ACAg4EnaIANABAAAA.',['今日']='今日刑满:BAABLAAFFH8HAAMOAAYIKxjFCgBlAQAOAAYI5BbFCgBlAQACAAEIPSCBmgBPAAAAAA==.',['他们']='他们叫我德神:BAABLAAFFH8NAAMMAAgIgw5mFACVAQAMAAcITA9mFACVAQANAAEI6RGhMABBAAAAAA==.',['付娜']='付娜:BAAALAAECggICAAAAA==.',['伊抹']='伊抹淡淡:BAAALAAECggICAAAAA==.',['会梦']='会梦丶超小马:BAAALAAECgYICgAAAA==.',['何伟']='何伟杰:BAAALAAFFAYIAgAAAA==.',['何幼']='何幼荷:BAAALAAECgYIBgAAAA==.',['佛耶']='佛耶鸽儿丶:BAAALAAECgYICwAAAA==.',['你冲']='你冲前面:BAAALAADCgMIAwAAAA==.',['你踏']='你踏雾而来:BAABLAAFFH8RAAIQAAYIPSUlAQAvAgAQAAYIPSUlAQAvAgABLAAFFAcIIgARAMUlAA==.',['你随']='你随意:BAAALAAECgUIBwAAAA==.',['佬倌']='佬倌矶:BAACLAAFFH8VAAISAAYIrApxCwBLAQASAAYIrApxCwBLAQAsAAQKfyIAAhIABwhuGuMKAA0CABIABwhuGuMKAA0CAAEsAAUUBggrAAwArhoA.',['俗人']='俗人之乡愁:BAAALAAFFAIIAwAAAA==.',['修车']='修车师傅阿祖:BAAALAADCggICAAAAA==.',['倾岚']='倾岚:BAAALAADCgIIAgAAAA==.',['儿化']='儿化音:BAAALAAECgYICwAAAA==.',['光年']='光年网吧:BAAALAAECgYIBwAAAA==.',['克卜']='克卜勒:BAAALAAFFAIIAgAAAA==.',['兔八']='兔八哥:BAABLAAFFH8OAAIRAAgIix8OAwDIAgARAAgIix8OAwDIAgAAAA==.',['全需']='全需:BAAALAAECgQIBAAAAA==.',['六六']='六六橙:BAACLAAFFH8QAAMPAAMIMBleIAAGAQAPAAMIMBleIAAGAQATAAEIkRHxNQA+AAAsAAQKfxYAAw8ABgjpHhB9AOQBAA8ABgjpHhB9AOQBABMAAQhTFTO4AD8AAAAA.',['冥殇']='冥殇羽:BAAALAAFFAMIBAAAAA==.',['冰影']='冰影狐:BAAALAAFFAIIAgAAAA==.',['冰霜']='冰霜贼:BAACLAAFFH8LAAMCAAMIhhrPKAD2AAACAAMIhhrPKAD2AAAOAAII1gKMFgBVAAAsAAQKfyYAAwIABwhdIKg0AKMCAAIABwhdIKg0AKMCAA4ABwgeEqkmAEkBAAAA.',['冷死']='冷死飛段:BAAALAAECgYIBgAAAA==.',['冷笑']='冷笑:BAAALAAECgYIBgAAAA==.',['冷馨']='冷馨丨灬:BAAALAAFFAIIAgAAAA==.冷馨儿:BAAALAAECgQIBAAAAA==.',['凨酔']='凨酔里一剣:BAAALAAFFAYIBAAAAA==.',['凶猛']='凶猛小猫咪:BAACLAAFFH8MAAIRAAIIpQj/VgA/AAARAAIIpQj/VgA/AAAsAAQKfyIAAhEABgi+E7+EAH0BABEABgi+E7+EAH0BAAAA.凶猛的一米九:BAAALAADCgYIBgAAAA==.',['刘德']='刘德华:BAAALAADCgEIAQAAAA==.',['别挡']='别挡我的路:BAABLAAFFH8JAAIUAAQIyA6eNADhAAAUAAQIyA6eNADhAAAAAA==.',['别逼']='别逼我放鸽子:BAAALAAECgYIBgAAAA==.',['剑斧']='剑斧斩杀:BAAALAAECgYICQAAAA==.',['力阳']='力阳谋:BAABLAAECn8ZAAMPAAYI3hUCxwB2AQAPAAYI3hUCxwB2AQATAAQIJQybjgCsAAAAAA==.',['十步']='十步流肾骑士:BAAALAAECgUIBQAAAA==.',['千兆']='千兆特斯拉:BAAALAAECgYIBgAAAA==.',['半世']='半世沧桑:BAAALAADCgIIAgAAAA==.',['半夜']='半夜我敲门:BAAALAAECgYICAAAAA==.',['卡璞']='卡璞鳍鳍:BAAALAAECgUIBQAAAA==.',['卡里']='卡里斯缇娜:BAAALAAECgYIDAAAAA==.',['印第']='印第安老板鸠:BAABLAAECn8kAAIVAAgIpR6JCwCnAgAVAAgIpR6JCwCnAgAAAA==.',['可爱']='可爱又迷人:BAAALAADCgQIBAAAAA==.',['吊成']='吊成一匹马:BAABLAAECn8UAAMPAAgInhoEZQARAgAPAAgInhoEZQARAgATAAMI/wIGqwBaAAAAAA==.',['向下']='向下就是天空:BAAALAAECggICAAAAA==.',['告白']='告白气球:BAAALAADCgYIDAAAAA==.',['命运']='命运脚印:BAAALAAECgIIAgAAAA==.',['咕咕']='咕咕嗒丶:BAAALAAECgUIBQAAAA==.',['咖喱']='咖喱牛丸加蛋:BAABLAAFFH8JAAIWAAIIIgk9KABtAAAWAAIIIgk9KABtAAABLAAFFAMICQAXAAsJAA==.',['咸香']='咸香脆薯条:BAAALAAECgUIBQAAAA==.',['哥还']='哥还不是传说:BAAALAAECgQIBAAAAA==.',['哦那']='哦那吗:BAAALAAECggIDwAAAA==.',['啊夜']='啊夜色儿:BAAALAADCgcIBwAAAA==.',['啸月']='啸月孤狼:BAAALAADCgUIBwAAAA==.',['啾瑟']='啾瑟夫:BAAALAADCgYIBwAAAA==.',['喊我']='喊我老王:BAAALAAECgEIAQAAAA==.',['喜微']='喜微晨巷:BAAALAAECgYIBgAAAA==.',['喵尾']='喵尾大回旋:BAABLAAFFH8GAAICAAIIHyQmPQC3AAACAAIIHyQmPQC3AAAAAA==.',['嗖嗖']='嗖嗖灬嗖:BAAALAAECgEIAQAAAA==.',['嘎巴']='嘎巴一下死那:BAAALAAECgYIBgAAAA==.',['嘟比']='嘟比哒吧:BAAALAADCgIIAgAAAA==.',['嘶呗']='嘶呗嘶嚒绿:BAABLAAFFH8GAAICAAYI/AdNPwA9AQACAAYI/AdNPwA9AQAAAA==.',['嘿妞']='嘿妞比:BAAALAADCgUIBQAAAA==.',['嘿西']='嘿西欧:BAAALAAECgQIBAAAAA==.',['圐一']='圐一戦尸:BAABLAAFFH8GAAIRAAIIEA4ZXAA6AAARAAIIEA4ZXAA6AAAAAA==.圐一湿泥碑:BAABLAAFFH8GAAICAAIIlxoybgCRAAACAAIIlxoybgCRAAAAAA==.',['圣堂']='圣堂之战:BAAALAAECggIDgABLAAFFAgICgAUAJ0EAA==.圣堂之法:BAAALAAECggIEAAAAA==.',['在下']='在下丘处鸡:BAAALAADCgEIAQAAAA==.',['地九']='地九神:BAAALAAECggICAAAAA==.',['地狱']='地狱飞魔:BAAALAAFFAIIAgAAAA==.',['地藏']='地藏丨天道西:BAAALAAECggICAAAAA==.',['坐忘']='坐忘道:BAAALAAECgYIBgAAAA==.',['型到']='型到跌渣:BAAALAAFFAIIAgAAAA==.',['埃德']='埃德勒弗林:BAAALAADCgYIBgAAAA==.',['塔斯']='塔斯盯沟:BAAALAAECgYICAAAAA==.',['壞籹']='壞籹囡:BAABLAAFFH8GAAIYAAYIyhKvNQA6AQAYAAYIyhKvNQA6AQAAAA==.',['壹呻']='壹呻:BAAALAAECgYIBwAAAA==.',['复仇']='复仇的圣骑:BAAALAAFFAIIAgAAAA==.',['夏夜']='夏夜满天星:BAAALAAFFAEIAQAAAA==.',['夜店']='夜店女王:BAAALAAECggICAAAAA==.',['大家']='大家不要慌:BAAALAADCgMIAwAAAA==.',['大巴']='大巴不在:BAAALAAECgYIBgAAAA==.',['大杀']='大杀死方:BAAALAAECgUIBQAAAA==.',['大肚']='大肚皮酒仙:BAAALAADCgUIBwAAAA==.',['大雨']='大雨烫脚吗:BAAALAAECgMIAwAAAA==.',['天下']='天下無敵:BAAALAAECgYIBgAAAA==.',['天使']='天使与魔神:BAAALAAECgMIBAAAAA==.',['天地']='天地公子:BAAALAADCggICAAAAA==.',['天天']='天天捏票纸:BAAALAAECgIIAgAAAA==.',['天煞']='天煞罒死神:BAAALAADCgEIAQAAAA==.',['奇異']='奇異博士:BAAALAAECgQIBAAAAA==.',['女王']='女王殿下:BAAALAAFFAIIBAAAAA==.',['奶农']='奶农:BAABLAAFFH8IAAILAAIIdRHVTwBrAAALAAIIdRHVTwBrAAAAAA==.',['奶糖']='奶糖丶:BAAALAAECgEIAQAAAA==.',['如烟']='如烟:BAAALAADCgEIAQAAAA==.',['妞妞']='妞妞牜牛:BAAALAAECgIIAgAAAA==.',['威仔']='威仔蠻衫:BAAALAAFFAIIAgAAAA==.',['孙尚']='孙尚香:BAAALAAECgIIAgAAAA==.',['宇宙']='宇宙首富:BAAALAAECgYIBgAAAA==.',['安岳']='安岳:BAAALAAECgEIAQAAAA==.',['安牧']='安牧希:BAAALAAECgUIBQAAAA==.',['宝宝']='宝宝别闹:BAABLAAFFH8HAAIZAAII7RXmDQCFAAAZAAII7RXmDQCFAAABLAAFFAgIXgAaAGglAA==.',['宝贝']='宝贝蛋:BAAALAAFFAMIAwAAAA==.',['寂寞']='寂寞老人:BAAALAAECggICAAAAA==.',['寇辰']='寇辰:BAAALAAECgYIEAAAAA==.',['寒枫']='寒枫:BAACLAAFFH8HAAIHAAIILQoSOgCAAAAHAAIILQoSOgCAAAAsAAQKfxkAAgcABwiaGKVBANEBAAcABwiaGKVBANEBAAAA.',['寒茫']='寒茫:BAAALAAFFAIIBAABLAAFFAgICgACAOQiAA==.',['寒阶']='寒阶望月华:BAAALAAFFAIIAgAAAA==.',['封魔']='封魔剑魂:BAABLAAFFH8KAAICAAUIsgxMSwADAQACAAUIsgxMSwADAQAAAA==.',['小一']='小一是啾咪:BAAALAAECgYIBgAAAA==.',['小不']='小不封控:BAAALAAECggIDgAAAA==.',['小卡']='小卡拉米巴:BAAALAAECgIIAwAAAA==.',['小多']='小多多:BAAALAAECgMIAwAAAA==.',['小屹']='小屹屹:BAAALAAECggIEgAAAA==.',['小心']='小心观众:BAAALAAECggIEAAAAA==.',['小手']='小手儿冰凉凉:BAABLAAFFH8GAAIPAAYIMRZ5CgDoAQAPAAYIMRZ5CgDoAQAAAA==.',['小李']='小李胖了吗:BAAALAAECgIIAgAAAA==.',['小柒']='小柒柒:BAAALAADCgYIBgAAAA==.',['小水']='小水包:BAABLAAFFH8VAAILAAgISSKIAACtAgALAAgISSKIAACtAgAAAA==.',['小泽']='小泽玛骊亜:BAAALAAECgUICQAAAA==.',['小满']='小满:BAAALAAECgEIAQAAAA==.',['小胖']='小胖鸟:BAAALAAECgMIAwAAAA==.',['小色']='小色牛:BAAALAAECgEIAQAAAA==.',['小鲨']='小鲨仔:BAAALAAECggICgAAAA==.',['小鸡']='小鸡比波:BAAALAAFFAIIAgAAAA==.',['少司']='少司命:BAAALAADCggICAAAAA==.',['尛尛']='尛尛丸子丶:BAAALAAFFAIIBAAAAA==.',['尤素']='尤素利华:BAAALAAECgEIAQAAAA==.',['尹晴']='尹晴丶:BAABLAAFFH8LAAIDAAMIoxV2RwCEAAADAAMIoxV2RwCEAAAAAA==.',['尹深']='尹深丶:BAABLAAFFH8IAAIUAAIIrxPnTgBKAAAUAAIIrxPnTgBKAAAAAA==.尹深深儿丶:BAABLAAFFH8OAAICAAYIlxCbLACGAQACAAYIlxCbLACGAQAAAA==.',['尹瞒']='尹瞒丶:BAABLAAFFH8IAAIbAAYIewhcJwALAQAbAAYIewhcJwALAQAAAA==.',['尹藏']='尹藏丶:BAAALAAFFAIIAgAAAA==.',['山月']='山月:BAAALAADCgIIAgAAAA==.',['岛田']='岛田半藏:BAAALAAFFAIIAgAAAA==.',['布丁']='布丁可可:BAAALAAECgEIAQAAAA==.',['布叔']='布叔:BAAALAAECgYICQAAAA==.',['布响']='布响丸喇:BAAALAADCgEIAQAAAA==.',['布哥']='布哥:BAAALAAECgIIAgAAAA==.',['布布']='布布果:BAAALAAECgYICAAAAA==.',['布鲁']='布鲁諾:BAABLAAECn8VAAIUAAcI6Ra2eQDSAQAUAAcI6Ra2eQDSAQAAAA==.',['帅的']='帅的没边:BAAALAAECgYIBwAAAA==.',['希瑞']='希瑞菈:BAAALAAECgUIBQAAAA==.',['帝皮']='帝皮艾斯:BAABLAAFFH8IAAICAAIInh3GQACyAAACAAIInh3GQACyAAAAAA==.',['幻冥']='幻冥刃舞:BAAALAAECgYIBgAAAA==.',['幽冥']='幽冥刃舞:BAAALAAFFAEIAQAAAA==.',['廿五']='廿五:BAAALAADCgIIAgAAAA==.',['异化']='异化美:BAABLAAFFH8GAAMZAAIIyg+vEwBkAAAZAAIIyg+vEwBkAAAUAAII9wM0agA0AAAAAA==.',['弓如']='弓如霹雳弦惊:BAEALAAFFAIIAgAAAA==.',['张小']='张小秋:BAAALAAFFAEIAQAAAA==.',['弦锋']='弦锋守护:BAAALAAECgYIBgAAAA==.',['弯弯']='弯弯:BAAALAADCgYIBgAAAA==.',['强哥']='强哥的春天:BAAALAAECgYIBgAAAA==.',['强颜']='强颜欢笑:BAAALAAECgYIBgAAAA==.',['影心']='影心:BAAALAAECgIIAgAAAA==.',['彼岸']='彼岸妖影:BAAALAAECgUIBgAAAA==.彼岸虬胤:BAAALAAECgIIAgAAAA==.',['彼得']='彼得:BAABLAAFFH8LAAMRAAIIngs9VABBAAARAAIIngs9VABBAAAcAAIILwdrBgA1AAAAAA==.',['彼端']='彼端:BAAALAADCgMIAwAAAA==.',['微笑']='微笑着说放弃:BAABLAAFFH8GAAMJAAIIER/5WABKAAAJAAIIER/5WABKAAAdAAII5gnGHwAsAAAAAA==.',['德福']='德福:BAAALAAECgYIDAAAAA==.',['快乐']='快乐小子:BAAALAAECgYIBgAAAA==.',['怪怪']='怪怪丶:BAAALAAECgYIAwAAAA==.',['恋爱']='恋爱脑:BAABLAAFFH8GAAIWAAYIlhkwAwATAgAWAAYIlhkwAwATAgAAAA==.',['恶龙']='恶龙咆哮嗷呜:BAABLAAFFH8GAAMeAAIICgZvHwB0AAAeAAIIwgRvHwB0AAAfAAIICgZUEQAzAAAAAA==.',['恺屹']='恺屹:BAAALAAECgUIBQAAAA==.',['惩戒']='惩戒奶骑:BAAALAAECgYIBgAAAA==.',['愤怒']='愤怒主播万峰:BAABLAAECn8ZAAIHAAgIOBRpPgDfAQAHAAgIOBRpPgDfAQAAAA==.',['我十']='我十步杀一人:BAABLAAECn8uAAIYAAgI4hxeKQCdAgAYAAgI4hxeKQCdAgAAAA==.',['我是']='我是渣渣辉:BAAALAAECgYICgAAAA==.',['扶她']='扶她:BAABLAAFFH8FAAMJAAMI1AxGRwB9AAAJAAMI1AxGRwB9AAAdAAEIyA1wIgBBAAAAAA==.',['报丧']='报丧女妖:BAAALAADCggICAAAAA==.',['抱着']='抱着弩:BAABLAAFFH8GAAQPAAII3QnnegBwAAAPAAIIrQTnegBwAAAgAAII1Aj4BwBPAAATAAEIMAE9OwAcAAAAAA==.',['拐子']='拐子嗦边边:BAAALAAECgYIDAAAAA==.拐子姐:BAAALAAECgMIAwAAAA==.拐子蜀到叁:BAAALAAECgYIBgAAAA==.',['指着']='指着太阳说日:BAAALAAFFAQIBAAAAA==.',['振魂']='振魂醒身:BAABLAAFFH8wAAISAAcI3htzAwBDAgASAAcI3htzAwBDAgAAAA==.',['挺特']='挺特别:BAAALAAECgUIBQAAAA==.',['提瓦']='提瓦特老中医:BAABLAAFFH8GAAIIAAYIZQ6WEQBSAQAIAAYIZQ6WEQBSAQAAAA==.',['摇曳']='摇曳之影:BAABLAAFFH8LAAIDAAMIshQXRACSAAADAAMIshQXRACSAAAAAA==.',['敲泥']='敲泥蛙:BAAALAAECgQIBAAAAA==.',['文疯']='文疯子:BAAALAAFFAIIBAAAAA==.',['斋藤']='斋藤飞狗:BAABLAAFFH8fAAIIAAYI7xXyDgBzAQAIAAYI7xXyDgBzAQAAAA==.',['斗鱼']='斗鱼满意:BAAALAADCgMIAwAAAA==.',['斯芬']='斯芬克斯:BAAALAAFFAEIAQAAAA==.',['新疆']='新疆喀纳斯:BAABLAAECn8WAAIPAAgItBlrKwALAgAPAAgItBlrKwALAgAAAA==.',['方天']='方天画戟:BAEALAAECgQIBAABLAAFFAIIAgAKAAAAAA==.',['旋风']='旋风腿:BAAALAAECgcICAAAAA==.',['无心']='无心一一再杀:BAAALAAECgQIBAAAAA==.',['无情']='无情的小机智:BAAALAAECgMIAwAAAA==.无情老瞎子:BAAALAAECgUICAAAAA==.',['无敌']='无敌死骑:BAAALAADCggICAAAAA==.无敌的啊大:BAAALAADCgYIBgAAAA==.无敌萧条:BAAALAAECggIBAAAAA==.',['时天']='时天使阿蒙:BAABLAAFFH8HAAICAAUIsRV8RQAkAQACAAUIsRV8RQAkAQAAAA==.',['明月']='明月清風:BAAALAADCgEIAQAAAA==.',['昕喵']='昕喵:BAABLAAFFH8IAAIUAAII3hfyPACcAAAUAAII3hfyPACcAAAAAA==.',['星空']='星空的游侠:BAAALAAFFAIIAgAAAA==.',['春眠']='春眠白雪:BAAALAAECgUICwAAAA==.',['昵芭']='昵芭咩咩:BAAALAAECggICAAAAA==.昵芭夕夕:BAAALAAFFAMIBAAAAA==.昵芭奶奶:BAAALAAFFAQIBAAAAA==.昵芭羊羊:BAABLAAFFH8OAAIPAAYIsAlMVQD5AAAPAAYIsAlMVQD5AAAAAA==.',['晓野']='晓野妹子:BAAALAADCgEIAQAAAA==.',['晴风']='晴风村村长:BAAALAADCgQIBAAAAA==.',['智取']='智取巧克力丶:BAAALAADCgYIBgAAAA==.',['暖巷']='暖巷:BAAALAAECgIIAgAAAA==.',['曼巴']='曼巴丶黑肘:BAAALAAECgcIBwAAAA==.',['曼曼']='曼曼:BAAALAAECgMIAwAAAA==.',['最郁']='最郁闷的情绪:BAAALAAFFAIIAgAAAA==.',['月光']='月光图腾:BAAALAAECggICAAAAA==.',['月礼']='月礼服假面:BAAALAAECgIIAgAAAA==.',['有事']='有事先走了:BAAALAADCgQIBAAAAA==.',['有点']='有点乂狂:BAACLAAFFH8HAAIUAAII7Qc7XwA/AAAUAAII7Qc7XwA/AAAsAAQKfxUAAhQABgiBF209AGYBABQABgiBF209AGYBAAAA.有点脆:BAAALAAECgYIBgABLAAFFAIICwAPAFIjAA==.',['朋克']='朋克美女:BAAALAAECgIIAgAAAA==.',['来啊']='来啊小妞:BAABLAAFFH8KAAMYAAYIuiJYEwDvAQAYAAYIuiJYEwDvAQAhAAIILw5tFgCXAAAAAA==.来啊美眉:BAABLAAFFH8MAAMaAAgIpRRAEACBAQAaAAYIjhNAEACBAQAJAAQIvRZLLQCvAAAAAA==.来啊美眉丶:BAAALAAFFAYIBAAAAA==.来啊萝莉:BAAALAAECgEIAQAAAA==.',['杨浦']='杨浦三子:BAAALAAECgQIBAAAAA==.杨浦阿四:BAAALAADCggICAAAAA==.',['枕雪']='枕雪:BAAALAADCgQIBAAAAA==.',['柑橘']='柑橘乌云:BAABLAAECn8kAAMWAAgIJRQeLwDYAQAWAAgIJRQeLwDYAQARAAEI8Ap2EQEwAAAAAA==.',['柒宝']='柒宝柒:BAABLAAFFH8JAAIPAAYI7hWeLACDAQAPAAYI7hWeLACDAQAAAA==.',['桃也']='桃也雾漫漫:BAABLAAFFH8GAAIJAAII/QuKcgA8AAAJAAII/QuKcgA8AAAAAA==.',['梁小']='梁小无拆:BAAALAAECgQIBAAAAA==.',['梦鱼']='梦鱼得鹿:BAAALAADCggIDgAAAA==.',['森木']='森木林:BAAALAAECgYIBgAAAA==.',['森苍']='森苍丶补漏:BAABLAAFFH8FAAIFAAQIHwJaEwBKAAAFAAQIHwJaEwBKAAABLAAFFAYICQACAAkDAA==.',['橙吉']='橙吉大师:BAAALAADCgIIAgAAAA==.',['欧皇']='欧皇之力:BAAALAAECgYIBgAAAA==.',['歡喜']='歡喜就好:BAAALAAECgYIBwAAAA==.',['正太']='正太猪八戒:BAAALAAFFAEIAQAAAA==.',['死亡']='死亡前奏:BAAALAAECgMIAwAAAA==.',['死鬼']='死鬼好坏:BAAALAAECgYIDwAAAA==.',['残夜']='残夜破殇:BAACLAAFFH8iAAICAAUIrh+xMwBsAQACAAUIrh+xMwBsAQAsAAQKfxUAAgIABgi6IjwgAPkBAAIABgi6IjwgAPkBAAAA.',['殺戮']='殺戮機器:BAAALAAECgEIAQAAAA==.',['毁在']='毁在伱手里:BAAALAADCgUIBQAAAA==.',['水水']='水水小白:BAAALAADCgMIBQAAAA==.',['氵释']='氵释天血:BAAALAADCgEIAQAAAA==.',['氷菓']='氷菓:BAACLAAFFH8LAAIPAAUIDxYFEwCOAQAPAAUIDxYFEwCOAQAsAAQKfxUAAg8ABghmHq52APABAA8ABghmHq52APABAAAA.',['永远']='永远的老人:BAAALAAECgYICwAAAA==.',['汗血']='汗血河馬:BAAALAADCgQIBAAAAA==.',['池池']='池池在鱼:BAABLAAFFH8GAAIiAAYIjRcUBADeAQAiAAYIjRcUBADeAQAAAA==.',['沃滋']='沃滋基丨硕德:BAAALAADCgMIBAAAAA==.',['法兰']='法兰茜丝卡:BAAALAAECgYIBgAAAA==.',['泛泛']='泛泛之辈的辈:BAABLAAFFH8PAAIDAAUI2COdJACCAQADAAUI2COdJACCAQAAAA==.',['注意']='注意你的态度:BAAALAAECgUIBQAAAA==.',['洒满']='洒满:BAACLAAFFH8gAAIbAAYI/BJtGQBzAQAbAAYI/BJtGQBzAQAsAAQKfzkAAhsACAhWHxUMAGkCABsACAhWHxUMAGkCAAEsAAUUBggrAAwArhoA.',['活死']='活死人牧:BAAALAADCgMIAwAAAA==.',['流光']='流光嗌彩:BAAALAAECgUIBwAAAA==.流光追月神:BAABLAAFFH8IAAIdAAII2h9JCwC7AAAdAAII2h9JCwC7AAAAAA==.',['海默']='海默:BAAALAAECgUIBgAAAA==.',['深蓝']='深蓝中浅蓝:BAAALAAECgEIAQAAAA==.深蓝浅蓝:BAACLAAFFH8GAAIJAAIIyBpNWgBJAAAJAAIIyBpNWgBJAAAsAAQKfxUAAgkACAi0G0MqAOoBAAkACAi0G0MqAOoBAAAA.',['混乱']='混乱飘零:BAAALAAFFAEIAQAAAA==.',['清风']='清风伴月:BAAALAAECgUIBQAAAA==.',['温柔']='温柔天涯:BAAALAAECggIEAAAAA==.',['温酒']='温酒:BAAALAADCgYIBgAAAA==.',['港位']='港位显风采:BAAALAAECgQIBQAAAA==.',['游戏']='游戏玩我:BAAALAAFFAIIAgABLAAFFAYICQACAAkDAA==.',['湖人']='湖人总冠军:BAACLAAFFH8JAAIYAAgIciAlBwCLAgAYAAgIciAlBwCLAgAsAAQKfyUABBgABgiBH0UtAJsBABgABgilHUUtAJsBACEABAgLHRldAAMBACMAAwjrFjAOAIUAAAAA.',['湮花']='湮花不待:BAAALAAECgcICgAAAA==.',['火晒']='火晒的神话:BAAALAAECgUIBQAAAA==.',['灬楓']='灬楓之貓貓灬:BAAALAAECgYIBgAAAA==.',['灵打']='灵打否:BAAALAAFFAIIAwAAAA==.',['灵罗']='灵罗娃娃:BAAALAAECgUIBQAAAA==.',['灵魂']='灵魂借宿丶:BAAALAADCgYIDAAAAA==.',['点卡']='点卡在燃烧:BAABLAAFFH8gAAIPAAUICCOqKACQAQAPAAUICCOqKACQAQAAAA==.',['炽热']='炽热之火:BAAALAAECgYIDQAAAA==.',['烈火']='烈火英豪:BAAALAADCgYICwAAAA==.',['無尽']='無尽怒火:BAAALAAECgYIBgAAAA==.無尽深澜:BAAALAADCgYIBgAAAA==.',['熹微']='熹微晨巷:BAABLAAECn8lAAQgAAgIbBCdDQDOAQAgAAcIehCdDQDOAQATAAUIJgruhgDFAAAPAAYIkwl8TAG1AAAAAA==.',['爆爆']='爆爆:BAABLAAFFH8OAAIUAAUIvBicLAAyAQAUAAUIvBicLAAyAQAAAA==.',['爱抚']='爱抚卡卡:BAAALAAECgYIDwAAAA==.',['父親']='父親:BAAALAAFFAYIAwAAAA==.',['爽文']='爽文男主:BAAALAAECgUICQAAAA==.',['牛乂']='牛乂甩甩:BAABLAAFFH8LAAIPAAIIMRV0kABFAAAPAAIIMRV0kABFAAAAAA==.',['牛憨']='牛憨憨:BAAALAAECgYIBgAAAA==.',['牛牛']='牛牛壮:BAAALAAECgQIBAAAAA==.',['牛皮']='牛皮巴巴:BAAALAAECgUIBgAAAA==.',['特怀']='特怀德:BAABLAAFFH8NAAINAAMI7AqiKABxAAANAAMI7AqiKABxAAAAAA==.',['特莉']='特莉丝:BAAALAAECgIIAgAAAA==.',['狂野']='狂野狂暴:BAAALAAECgIIAgAAAA==.狂野腮帮猴丿:BAAALAADCgEIAQAAAA==.',['狐狸']='狐狸爪子:BAAALAAECgUIDAAAAA==.',['猎仁']='猎仁:BAAALAAECgEIAQAAAA==.',['猎心']='猎心姬:BAACLAAFFH8PAAIPAAYI3BICOwBWAQAPAAYI3BICOwBWAQAsAAQKfxcAAw8ACAiHD1FYAJIBAA8ACAhhD1FYAJIBABMACAg/AOjYAAgAAAAA.',['猫猫']='猫猫头:BAABLAAFFH8GAAIUAAIIlRLQQwCWAAAUAAIIlRLQQwCWAAAAAA==.',['王力']='王力宏:BAABLAAFFH8HAAICAAIIExFidACOAAACAAIIExFidACOAAAAAA==.',['王婆']='王婆:BAAALAAECgIIAgAAAA==.',['王德']='王德发:BAABLAAFFH8IAAIJAAIIbBCrWwBIAAAJAAIIbBCrWwBIAAAAAA==.',['王者']='王者之泪:BAAALAAFFAIIAgAAAA==.王者来也:BAAALAAECggICAAAAA==.',['珐师']='珐师的荣耀丿:BAAALAAECgQIBAAAAA==.',['球球']='球球宝宝:BAAALAAECgIIAgAAAA==.',['理查']='理查德丶泰森:BAAALAAECgMIAwAAAA==.',['瑞妍']='瑞妍祥和:BAAALAAECgIIAgAAAA==.',['甜不']='甜不辣:BAAALAAFFAIIBAAAAA==.',['甜酥']='甜酥酥小蛋卷:BAACLAAFFH8PAAIaAAYIDSGuAgAqAgAaAAYIDSGuAgAqAgAsAAQKfxgAAxoACAj3IDoRAIkCABoACAj3IDoRAIkCAAkABQiLGm7cAF8BAAAA.',['田螺']='田螺鸭脚煲:BAAALAAECgYIBgAAAA==.',['畏惧']='畏惧吧弟弟:BAAALAAECgYIBgAAAA==.',['疯狂']='疯狂小萨萨:BAAALAAFFAIIBAAAAA==.疯狂的粪草:BAAALAAECgUIBQAAAA==.疯狂的铁锤:BAAALAAECgEIAQAAAA==.',['白巧']='白巧克力牛:BAAALAAECgEIAQAAAA==.',['白猴']='白猴子:BAAALAAFFAIIAgAAAA==.',['看淡']='看淡这个世界:BAACLAAFFH8VAAIaAAYI5Bk3CwDQAQAaAAYI5Bk3CwDQAQAsAAQKfx8AAhoABwiGGtYQAOkBABoABwiGGtYQAOkBAAAA.',['看着']='看着玩:BAABLAAFFH8GAAMhAAIISgknFwA8AAAYAAIIjgS4UQB8AAAhAAIISgknFwA8AAAAAA==.',['眞实']='眞实:BAABLAAFFH8HAAMBAAMI2gx4DwBnAAABAAMI2gx4DwBnAAADAAIIBAeAaAAwAAAAAA==.',['真没']='真没素质:BAAALAAFFAMIAgAAAA==.',['真理']='真理之剑:BAAALAAECgEIAQAAAA==.',['破晓']='破晓:BAAALAADCgMIAwAAAA==.',['磊哥']='磊哥哥:BAABLAAFFH8FAAIMAAII7g13RQBkAAAMAAII7g13RQBkAAAAAA==.磊哥哥灬懒啊:BAAALAAFFAIIAgAAAA==.',['祝您']='祝您永不便秘:BAAALAAECgMIAwAAAA==.',['神惊']='神惊兮兮:BAAALAAECgUIBQAAAA==.',['神经']='神经兮兮:BAAALAAECgYIDAAAAA==.神经沐沐:BAABLAAECn8VAAMHAAcIOQ1YXwBgAQAHAAcIOQ1YXwBgAQAIAAEI8QHgpwAeAAAAAA==.',['禁术']='禁术乄电疗:BAAALAADCgcIBwAAAA==.',['稍有']='稍有常识的猴:BAAALAAFFAIIAgAAAA==.',['稥粉']='稥粉丶香奈:BAAALAAFFAIIAgAAAA==.',['穆易']='穆易:BAAALAADCgEIAQAAAA==.',['立正']='立正丶:BAAALAAFFAQIBAABLAAFFAcIIgARAMUlAA==.',['竹影']='竹影丶清风:BAAALAAFFAIIAgAAAA==.',['笑忘']='笑忘书:BAAALAAFFAIIAgAAAA==.',['笑看']='笑看风韵:BAAALAAECgIIAgAAAA==.',['等风']='等风来:BAAALAADCgUIBQAAAA==.等风来丶:BAAALAAECgYIDAAAAA==.',['筱眠']='筱眠:BAACLAAFFH8bAAIIAAYI5BErFAAzAQAIAAYI5BErFAAzAQAsAAQKfyIABAgABggQG3IbAGwBAAgABggQG3IbAGwBAAcAAwiNFoNGAMIAACQAAghzCXsbAEsAAAAA.',['簿暮']='簿暮晨光:BAAALAADCggICAAAAA==.',['粗又']='粗又硬:BAAALAAECgIIBQAAAA==.粗又苌:BAABLAAECn8aAAIRAAYIiRyqNQCCAQARAAYIiRyqNQCCAQAAAA==.',['糯米']='糯米团:BAAALAADCgIIAgAAAA==.',['紅茶']='紅茶兔子:BAAALAAECgYIDgAAAA==.',['红鲤']='红鲤鱼绿鲤鱼:BAAALAAECgYIBgAAAA==.',['纯粹']='纯粹灬忽悠你:BAAALAADCgYIBgAAAA==.',['纯红']='纯红没角兽:BAAALAAECgYICAAAAA==.',['纳西']='纳西妲妲:BAAALAAECgMIAwAAAA==.',['细雨']='细雨江南:BAAALAAECgYICQAAAA==.',['给朕']='给朕跪下丶:BAABLAAFFH8IAAICAAgIixjWCgBNAgACAAgIixjWCgBNAgAAAA==.',['绵宝']='绵宝:BAAALAAFFAIIBAAAAA==.',['绿洲']='绿洲小奶牛:BAACLAAFFH8rAAMbAAYIfBtEFACaAQAbAAYIfBtEFACaAQALAAMIsA/kVQBnAAAsAAQKfyoAAxsACAglHpgaAMkCABsACAglHpgaAMkCAAsABwgNGsR4AJABAAAA.',['罒一']='罒一罒:BAAALAAFFAIIAgAAAA==.',['罒丅']='罒丅罒:BAAALAAFFAIIAgAAAA==.',['罒丶']='罒丶罒:BAABLAAFFH8FAAIgAAIIJhe5BQCRAAAgAAIIJhe5BQCRAAAAAA==.',['美少']='美少女壮士:BAAALAAFFAIIAgAAAA==.',['羴骉']='羴骉犇猋:BAAALAAECgEIAQAAAA==.',['老六']='老六的神话:BAAALAAECgEIAQAAAA==.',['老挝']='老挝盾牌兵:BAABLAAECn8aAAIbAAgI8RhKLQBbAgAbAAgI8RhKLQBbAgAAAA==.',['老衲']='老衲也射:BAABLAAFFH8GAAITAAYIIw/4BgCxAQATAAYIIw/4BgCxAQABLAAFFAgICAACAIsYAA==.',['老陈']='老陈的大钢炮:BAAALAAECgYICAAAAA==.',['耐干']='耐干小王子:BAAALAAECgYIBgAAAA==.',['聖光']='聖光大領主:BAAALAAECgIIAgAAAA==.',['肉筋']='肉筋怒张:BAABLAAFFH8JAAIPAAUITRC6VgDyAAAPAAUITRC6VgDyAAAAAA==.',['胸前']='胸前一簇毛:BAAALAAECgMIBQAAAA==.',['脆脆']='脆脆鲨丶:BAAALAAECgEIAQAAAA==.',['脚板']='脚板:BAAALAAECggIDQAAAA==.',['膏锋']='膏锋锷:BAABLAAFFH8KAAICAAMIqBr6WACgAAACAAMIqBr6WACgAAAAAA==.',['艾似']='艾似疾风:BAAALAAFFAMIAwAAAA==.',['艾哈']='艾哈特:BAAALAAECgcIDgAAAA==.',['艾希']='艾希蕾:BAAALAAECggICAAAAA==.',['艾瑞']='艾瑞娜火叶:BAAALAAECggIDwABLAAFFAYIFwAbABMdAA==.',['芙兰']='芙兰达:BAAALAAECggICAAAAA==.',['芙琳']='芙琳吉拉:BAAALAAECgcIBwAAAA==.',['芝麻']='芝麻糊:BAAALAAECgYIBgAAAA==.芝麻豆:BAAALAAECgcIEAAAAA==.',['花大']='花大妞:BAAALAAECgYIBgAAAA==.',['花木']='花木籣:BAAALAAECgcIBQAAAA==.',['花田']='花田:BAAALAAECgYIBgABLAAFFAIIAgAKAAAAAA==.',['苍穹']='苍穹编织者:BAAALAAECgEIAQAAAA==.',['苏拉']='苏拉梨:BAAALAADCgcIBwAAAA==.苏拉玛亚:BAAALAADCgEIAQAAAA==.',['若离']='若离:BAAALAAFFAYIBAAAAA==.',['茜瑞']='茜瑞:BAAALAAECgEIAQAAAA==.',['莉亚']='莉亚德琳:BAAALAAECgMIAwAAAA==.',['萨拉']='萨拉利丝:BAABLAAFFH8NAAMDAAMIFyCZMADJAAADAAMIFyCZMADJAAABAAEIqBbjHwBEAAAAAA==.',['萨爹']='萨爹一枚:BAAALAAECgIIAgAAAA==.',['萨狗']='萨狗的召唤:BAAALAADCgYIBgAAAA==.',['落焱']='落焱之殇:BAAALAADCgUIBQAAAA==.',['葆蝶']='葆蝶家:BAAALAAECgcIEAAAAA==.',['葵之']='葵之上:BAAALAAECgYICwAAAA==.',['蒂德']='蒂德菲尔:BAAALAAECgIIAQAAAA==.',['蒋劲']='蒋劲夫:BAABLAAFFH8GAAIWAAYIBhRAEQBAAQAWAAYIBhRAEQBAAQAAAA==.',['蒋维']='蒋维:BAAALAAECgYICQAAAA==.',['蓝胡']='蓝胡子丶:BAABLAAECn8VAAICAAYIhSDWaAAkAgACAAYIhSDWaAAkAgAAAA==.',['薄暮']='薄暮晨光:BAABLAAECn83AAMMAAgImCJFCgAKAwAMAAgImCJFCgAKAwANAAYIrBuCPADEAQAAAA==.',['虫下']='虫下月易:BAAALAAFFAMIAgAAAA==.',['蛋蛋']='蛋蛋疼啊:BAAALAADCgYIAwAAAA==.',['血染']='血染迺:BAAALAAFFAIIAgAAAA==.',['血血']='血血加加:BAAALAAECgUIBQAAAA==.',['裁决']='裁决神雷:BAAALAAFFAIIBAAAAA==.',['西域']='西域男孩:BAAALAADCggICAAAAA==.',['西格']='西格玛晓美:BAAALAAECgYIBgAAAA==.',['西瓜']='西瓜猫文化:BAAALAADCgYICAAAAA==.',['西街']='西街的尼采:BAAALAADCgQIBQAAAA==.',['西装']='西装逗:BAAALAAECgYIBwAAAA==.',['諸神']='諸神之戰:BAABLAAFFH8KAAIRAAYI5Q0RIgBcAQARAAYI5Q0RIgBcAQAAAA==.',['變形']='變形出發:BAAALAAECgMIAwAAAA==.',['让左']='让左泪死:BAAALAADCggIDwABLAAECggIJAAVAKUeAA==.',['诅咒']='诅咒视界:BAAALAAECgMIAwAAAA==.',['诸暨']='诸暨依霸:BAAALAADCgMIAwAAAA==.',['谋阳']='谋阳:BAAALAAECgQIBAAAAA==.',['谢小']='谢小萌:BAAALAAECgYICwAAAA==.',['豌豆']='豌豆射手:BAACLAAFFH8IAAIPAAgIQxVlDQAeAgAPAAgIQxVlDQAeAgAsAAQKfxoAAxMACAh8FzEJAMoBABMACAiCFTEJAMoBAA8ABQjVFAX6ADYBAAAA.',['败露']='败露球菇:BAAALAAECggIEAABLAAFFAIIBgAeAAoGAA==.',['蹄子']='蹄子跑得快丶:BAAALAAECggICgAAAA==.',['车厘']='车厘子:BAAALAAECgQIAQAAAA==.',['软丶']='软丶惊天:BAAALAAECgYIBwAAAA==.',['轻裹']='轻裹你的风:BAAALAAECgQIBAAAAA==.',['辉煌']='辉煌錭:BAAALAAFFAMIBAAAAA==.',['达菲']='达菲鸭:BAABLAAFFH8IAAIVAAgIUx1vAgB5AgAVAAgIUx1vAgB5AgAAAA==.',['达里']='达里尔:BAAALAAECggICAAAAA==.',['进击']='进击的水豚氵:BAAALAADCgYIBgAAAA==.',['远古']='远古恐惧:BAAALAAECgQIBAAAAA==.',['迷逗']='迷逗白:BAAALAAECgYIBgAAAA==.',['追風']='追風:BAAALAADCggIEAAAAA==.',['逆天']='逆天丶凋零者:BAABLAAFFH8HAAMFAAYI4BduDQCiAAAEAAQIvBamEQDnAAAFAAIIKRpuDQCiAAAAAA==.',['通灵']='通灵一恋梦:BAAALAADCgEIAQAAAA==.',['道士']='道士不好惹:BAAALAAECgYIBgABLAAFFAYIKwAMAK4aAA==.',['遗忘']='遗忘欧若拉:BAABLAAFFH8KAAICAAYI4hI5NABrAQACAAYI4hI5NABrAQABLAAFFAYIFwAbABMdAA==.',['那个']='那个萨满丶:BAABLAAFFH8eAAIaAAgIxB7WAQDVAgAaAAgIxB7WAQDVAgAAAA==.',['部落']='部落的希望:BAABLAAFFH8JAAICAAYICQOaUADaAAACAAYICQOaUADaAAAAAA==.',['郭靖']='郭靖:BAACLAAFFH8GAAIPAAIIrhHRnQA/AAAPAAIIrhHRnQA/AAAsAAQKfxYAAg8ABgjRHDZ4AFUBAA8ABgjRHDZ4AFUBAAAA.',['酸葱']='酸葱:BAABLAAFFH8GAAIYAAYIHA8gHwAyAQAYAAYIHA8gHwAyAQAAAA==.',['醉剑']='醉剑如霜:BAABLAAFFH8GAAINAAYIdgJYJACMAAANAAYIdgJYJACMAAAAAA==.',['野生']='野生胖胖鸟:BAACLAAFFH8SAAIQAAUI/BwZAgDqAQAQAAUI/BwZAgDqAQAsAAQKfyoAAxAACAhfJXoBAGQDABAACAhfJXoBAGQDAAwAAQjmF0/oAC4AAAAA.',['鑫淼']='鑫淼:BAAALAAECgYIBgAAAA==.',['钢铁']='钢铁之手:BAABLAAECn8YAAIlAAYIOyF8EADYAQAlAAYIOyF8EADYAQAAAA==.',['铁须']='铁须的神话:BAAALAAECgYIDAAAAA==.',['银河']='银河之心:BAABLAAFFH8GAAIbAAMIrBBnNgCDAAAbAAMIrBBnNgCDAAAAAA==.银河系的未来:BAAALAADCggICAAAAA==.',['长征']='长征粉条:BAAALAAECgYICwAAAA==.',['閻魔']='閻魔丶愛:BAAALAADCgcIBwAAAA==.',['闪电']='闪电风暴:BAABLAAFFH8XAAMbAAYIEx1iHgBOAQAbAAUIHxtiHgBOAQALAAEIlA8LeAA7AAAAAA==.',['阐述']='阐述你的梦:BAAALAAECgIIAgAAAA==.',['阿博']='阿博洛迪忒:BAAALAAFFAIIAwAAAA==.阿博洛迪特:BAABLAAFFH8IAAIZAAIIGgGpGwAYAAAZAAIIGgGpGwAYAAAAAA==.',['阿咪']='阿咪喏思:BAABLAAFFH8FAAIHAAIIwxjGJgCdAAAHAAIIwxjGJgCdAAAAAA==.',['阿威']='阿威十八式丶:BAAALAAFFAIIAgAAAA==.',['阿润']='阿润润阿:BAAALAAECgcICQAAAA==.',['阿良']='阿良丶:BAAALAADCgYIBgAAAA==.',['阿花']='阿花纯牛奶:BAAALAADCgMIAwAAAA==.',['陈年']='陈年老酒:BAAALAADCgEIAQAAAA==.',['陈暖']='陈暖树:BAAALAAECgcIBwAAAA==.',['雨落']='雨落芊芊:BAAALAAECgEIAQAAAA==.',['雪舞']='雪舞:BAAALAAECgEIAQAAAA==.',['雪花']='雪花:BAAALAAECgIIAgAAAA==.',['零度']='零度:BAABLAAFFH8PAAILAAMIfRc3NQDQAAALAAMIfRc3NQDQAAAAAA==.',['雷丨']='雷丨疯:BAAALAAECggICAABLAAFFAgICAACAIsYAA==.',['雷军']='雷军:BAAALAAECgYIBgAAAA==.',['雾中']='雾中寻鹿:BAABLAAFFH8eAAIJAAYItCSjBQAqAgAJAAYItCSjBQAqAgABLAAFFAcIIgARAMUlAA==.',['霜眠']='霜眠眠:BAAALAADCgIIAgAAAA==.',['霸王']='霸王强上弓:BAAALAADCgQIBAAAAA==.',['霹雳']='霹雳雷霆:BAAALAAECgMIAwAAAA==.',['风一']='风一般的男子:BAAALAAECgMIAwAAAA==.',['风中']='风中风:BAAALAAECgYIEgAAAA==.',['风之']='风之记忆:BAAALAAECgIIAgAAAA==.',['风吹']='风吹沙:BAABLAAFFH8IAAMCAAII6AZbjAB8AAACAAII6AZbjAB8AAAmAAEIswIqIABDAAAAAA==.',['风怒']='风怒者:BAABLAAFFH8GAAILAAMIwQKldQBBAAALAAMIwQKldQBBAAAAAA==.',['风扬']='风扬起的梦:BAAALAADCgMIAwAAAA==.',['风酔']='风酔里一剣:BAABLAAECn8WAAIRAAgIvyGMIgC9AgARAAgIvyGMIgC9AgAAAA==.',['风骚']='风骚乐乐哥:BAAALAAECgYIBgAAAA==.',['飒丶']='飒丶飒:BAAALAAECgYIBgAAAA==.',['飞龙']='飞龙:BAACLAAFFH8MAAQWAAIIxhSkHQCDAAAWAAIIxhSkHQCDAAAcAAEIcxUPCABQAAARAAII+geQXQA4AAAsAAQKfxcABBEABgh+HddfANQBABEABgjDHNdfANQBABwABAhPFtcgAAoBABYAAQhzFViTAEEAAAAA.',['食铁']='食铁兽:BAAALAAECgYIBgAAAA==.',['香奈']='香奈儿亚军:BAAALAAFFAIIAgAAAA==.',['香嫩']='香嫩椒椒鸡:BAAALAADCgUIBQAAAA==.',['马桶']='马桶小圣:BAAALAAECgYIBgAAAA==.',['骑士']='骑士我想走欧:BAAALAAECgEIAQAAAA==.',['骷髅']='骷髅色的白泽:BAAALAAECgQIBAAAAA==.',['鬼五']='鬼五延:BAAALAAFFAIIAgAAAA==.',['魔神']='魔神笔笔:BAAALAAFFAEIAQAAAA==.',['鲁鲁']='鲁鲁伊:BAAALAADCgQIBAAAAA==.',['鲍抱']='鲍抱:BAABLAAECn8sAAMRAAgI9xpDMwBpAgARAAgI9xpDMwBpAgAWAAgIEhEoMwDCAQAAAA==.',['鲜血']='鲜血小圣光:BAAALAAECgYICwAAAA==.鲜血小萨满:BAAALAAECgYIBgAAAA==.',['鸠摩']='鸠摩智:BAAALAAFFAIIBAAAAA==.',['鸡肥']='鸡肥蛋大:BAAALAADCgQIBAAAAA==.',['麥洛']='麥洛汀朵:BAAALAAECgMIAwAAAA==.',['黄泉']='黄泉:BAAALAADCggICAAAAA==.',['黑夜']='黑夜不再来:BAAALAADCgYIBgAAAA==.',['黑猫']='黑猫:BAAALAAECgYICAAAAA==.',['黑色']='黑色的眼线:BAABLAAFFH8GAAMaAAYIExM+FQA5AQAaAAUIWRM+FQA5AQAJAAEIeQPudAA7AAAAAA==.',['黯然']='黯然飞灭:BAABLAAFFH8FAAMeAAMIVhVCDwDpAAAeAAMIVhVCDwDpAAAiAAIIEQtjFQCEAAAAAA==.',['龅牙']='龅牙滤茶渣:BAAALAAECgEIAQAAAA==.',['龙暗']='龙暗:BAAALAADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end