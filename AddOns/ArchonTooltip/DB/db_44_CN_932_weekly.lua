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
 local lookup = {'Warrior-Arms','Warrior-Fury','DeathKnight-Frost','Unknown-Unknown','Hunter-BeastMastery','Evoker-Devastation','Shaman-Elemental','DemonHunter-Havoc','Mage-Arcane','Hunter-Marksmanship','Paladin-Retribution','Warlock-Destruction','DeathKnight-Blood','Monk-Mistweaver','Druid-Restoration','Warlock-Demonology','Shaman-Restoration','Mage-Frost','Rogue-Outlaw','Warrior-Protection','Monk-Brewmaster','Evoker-Augmentation','Paladin-Protection','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','Mage-Fire','Druid-Balance','Druid-Feral','DemonHunter-Vengeance','Monk-Windwalker','Paladin-Holy',}; local provider = {region='CN',realm='塞纳留斯',name='CN',type='weekly',zone=44,date='2025-12-07',data={Ab='Absentmind:BAABLAAECn8WAAMBAAcIfRdWEgCyAQABAAcIfRdWEgCyAQACAAEIrwQaGQEgAAAAAA==.',Ae='Aeonight:BAAALAADCggIEAAAAA==.',An='Andyxin:BAAALAAECgIIAgAAAA==.',Ar='Arthase:BAABLAAFFH8HAAIDAAIImQcOoQA1AAADAAIImQcOoQA1AAABLAAFFAYIBAAEAAAAAA==.',Au='Aumaric:BAAALAAECgYIBgAAAA==.',Ba='Babyhoney:BAAALAADCgEIAQAAAA==.',Ci='Cinderela:BAABLAAFFH8hAAIFAAYIIiHrFADsAQAFAAYIIiHrFADsAQAAAA==.',Cl='Climacool:BAAALAAECgcIDAAAAA==.',Dr='Dragonglaive:BAABLAAFFH8GAAICAAMI4QzsPAB+AAACAAMI4QzsPAB+AAABLAAFFAYILQAGAK8aAA==.Dramwill:BAAALAAECgYIBgAAAA==.',Er='Ericka:BAABLAAFFH8nAAIHAAYIohwJEwClAQAHAAYIohwJEwClAQAAAA==.',Ex='Exdh:BAAALAAFFAIIAgAAAA==.Exdru:BAAALAAECgYIBwAAAA==.Exwl:BAAALAAECgQIBgAAAA==.',Fe='Feeds:BAAALAAFFAIIAgAAAA==.',Fh='Fhramazon:BAAALAADCggICAAAAA==.Fhrpaladin:BAAALAADCgMIAwAAAA==.',Ge='Genisis:BAAALAAECgYIBgAAAA==.',Gr='Grommash:BAAALAAECgUIBgAAAA==.',Le='Leahdizon:BAAALAAECgIIAgAAAA==.',Me='Meglee:BAABLAAFFH8OAAIFAAUIwgwZVgD5AAAFAAUIwgwZVgD5AAAAAA==.Menethil:BAAALAAECgYIBwAAAA==.',Mi='Miraitowa:BAABLAAFFH8GAAIIAAMIAAoGQgCIAAAIAAMIAAoGQgCIAAABLAAFFAYIIQAFACIhAA==.',My='Mysteryj:BAABLAAFFH8HAAIJAAMI/wT/SwBnAAAJAAMI/wT/SwBnAAAAAA==.',Nu='Nuyoah:BAAALAAECgUIBQAAAA==.',Pl='Playerqwjsrd:BAAALAAFFAEIAQAAAA==.',Re='Requiems:BAABLAAFFH8LAAIDAAMIRRg6JQAFAQADAAMIRRg6JQAFAQABLAAFFAYILQAGAK8aAA==.',Ri='Ringchaw:BAAALAAECggIDgAAAA==.',Ro='Rosalyn:BAAALAADCgUIBQAAAA==.',Sa='Saurfang:BAAALAAECgQIBAAAAA==.',Se='Selina:BAAALAAFFAIIAgAAAA==.',Sh='Sharess:BAAALAADCggIDwAAAA==.',St='Steffie:BAAALAADCgIIBAAAAA==.',Su='Sunyata:BAAALAAFFAIIAgAAAA==.',Te='Terrist:BAACLAAFFH8ZAAIFAAcIhBo2CQD2AQAFAAcIhBo2CQD2AQAsAAQKfxoAAwoACAixIUQZAJkCAAoACAhfIEQZAJkCAAUACAgMIOo/AGcCAAAA.',Wa='Waystalker:BAABLAAFFH8KAAIFAAMIhx0iJADtAAAFAAMIhx0iJADtAAAAAA==.',Xr='Xroad:BAAALAAECgYIEgAAAA==.',Ye='Yeogmoon:BAAALAAECgYIBgAAAA==.',['一剑']='一剑霜寒:BAABLAAFFH8HAAILAAMI0RH/RACHAAALAAMI0RH/RACHAAAAAA==.',['一片']='一片血一片:BAAALAAECgYIBgAAAA==.',['一粒']='一粒米:BAAALAAECgYIBgAAAA==.',['七星']='七星怜月:BAAALAAECgYIBgAAAA==.',['丛林']='丛林小德:BAAALAAECgQIBAAAAA==.',['严嵩']='严嵩:BAAALAAECggICAAAAA==.',['丨海']='丨海狼丨:BAAALAADCgMIAwAAAA==.',['丶中']='丶中啯古拳法:BAAALAAECgYIBgAAAA==.',['丶青']='丶青山:BAAALAAECgYIBgAAAA==.',['丸子']='丸子:BAABLAAFFH8GAAIIAAIIpAprZAA8AAAIAAIIpAprZAA8AAAAAA==.',['为啥']='为啥不是猴子:BAAALAADCgcIBwAAAA==.',['乃大']='乃大有容:BAAALAADCgMIAwAAAA==.',['买买']='买买提:BAABLAAFFH8JAAIFAAUI6g3gWADsAAAFAAUI6g3gWADsAAABLAAFFAYIGQADAIQaAA==.',['二娘']='二娘:BAAALAAECgMIAwAAAA==.',['云扬']='云扬子:BAAALAAECgMIAwAAAA==.',['云起']='云起碧落:BAAALAADCgUIBgAAAA==.',['五月']='五月二十八:BAAALAADCgcIBwAAAA==.',['亲爱']='亲爱的马儿:BAAALAADCgMIAwAAAA==.',['任性']='任性的小魔样:BAAALAAECgYIBgAAAA==.',['伊利']='伊利蛋丶邪刃:BAAALAAECgYIBgAAAA==.',['休闲']='休闲逛世界:BAAALAAECgIIAgAAAA==.',['佐罗']='佐罗三道:BAAALAADCgMIAwAAAA==.',['你打']='你打高点行吗:BAAALAAECggIBgAAAA==.',['修罗']='修罗紫衣:BAABLAAFFH8NAAICAAIIKhdUQgBVAAACAAIIKhdUQgBVAAAAAA==.',['倷芙']='倷芙蒂斯:BAABLAAFFH8GAAIMAAYIHwmjFQCuAQAMAAYIHwmjFQCuAQAAAA==.',['倾城']='倾城之恋:BAAALAAECgYIBgAAAA==.',['光和']='光和影的传说:BAABLAAFFH8tAAINAAYIPww0DQA4AQANAAYIPww0DQA4AQAAAA==.',['光明']='光明流浪者:BAAALAAECgUIBgAAAA==.',['再生']='再生丶:BAACLAAFFH8QAAIOAAMIfg9wEQCjAAAOAAMIfg9wEQCjAAAsAAQKfyYAAg4ACAjwEAgXADcBAA4ACAjwEAgXADcBAAAA.',['再粗']='再粗些再大些:BAAALAAECgIIAgAAAA==.',['再见']='再见孙悟空:BAABLAAFFH8LAAIPAAQImxOQJgDnAAAPAAQImxOQJgDnAAAAAA==.',['冰雪']='冰雪寒霜:BAAALAAECgEIAQAAAA==.',['冷丶']='冷丶萨:BAAALAAFFAMIAwAAAA==.冷丶魂:BAAALAADCgIIAgAAAA==.',['冻结']='冻结黎明:BAABLAAFFH8MAAILAAIIPw8AYwBFAAALAAIIPw8AYwBFAAAAAA==.',['凉森']='凉森玲梦:BAAALAAFFAIIAgAAAA==.',['凌枫']='凌枫:BAAALAAECgUICgAAAA==.',['刘跑']='刘跑跑:BAAALAAECgYICQAAAA==.',['别克']='别克风:BAAALAADCgQIBAAAAA==.别克风商务:BAAALAADCgMIAwAAAA==.',['别疯']='别疯:BAABLAAFFH8KAAIQAAIIdB6cCgC2AAAQAAIIdB6cCgC2AAAAAA==.',['刺客']='刺客水大师:BAAALAAECgYIDwAAAA==.刺客的小第:BAABLAAFFH8GAAIRAAIIqweXbQBOAAARAAIIqweXbQBOAAAAAA==.刺客的小跟班:BAAALAAFFAIIAgAAAA==.',['剑来']='剑来:BAABLAAFFH8RAAIFAAUIjBaaSwAhAQAFAAUIjBaaSwAhAQAAAA==.',['势坤']='势坤:BAAALAADCgIIAgAAAA==.',['北锋']='北锋校尉:BAAALAADCgIIAgAAAA==.',['千早']='千早爱音:BAAALAAFFAMIAwAAAA==.',['千秋']='千秋真一:BAAALAAECgYIBgAAAA==.',['卡媞']='卡媞西娅:BAABLAAFFH8LAAMSAAII4SCdDQCaAAASAAII4SCdDQCaAAAJAAEItwpGbABCAAAAAA==.',['卷柏']='卷柏:BAAALAAECgYICQAAAA==.',['厄洛']='厄洛斯:BAABLAAFFH8GAAIRAAMIOQNsWwBlAAARAAMIOQNsWwBlAAAAAA==.',['厚德']='厚德:BAAALAAECgYICAAAAA==.',['友善']='友善:BAAALAAECgYIBgAAAA==.',['变形']='变形大滨州:BAAALAAECgEIAQAAAA==.',['叫我']='叫我大爷:BAAALAAECgcIDAAAAA==.',['可是']='可是你没有:BAABLAAFFH8GAAIRAAIIcBXFTwB9AAARAAIIcBXFTwB9AAAAAA==.',['叶舞']='叶舞霜:BAAALAAECgcIDAAAAA==.',['吃我']='吃我电法一箭:BAAALAAECgMIAwAAAA==.',['吡吡']='吡吡:BAABLAAFFH8IAAITAAYIlBdDAgAwAQATAAYIlBdDAgAwAQAAAA==.',['吱吱']='吱吱小鸽鸽:BAAALAAECgYICgAAAA==.',['吼鱼']='吼鱼:BAACLAAFFH8vAAIUAAYIriFdBgDjAQAUAAYIriFdBgDjAQAsAAQKfxoAAhQACAjuIQsIABsDABQACAjuIQsIABsDAAAA.',['咋进']='咋进不去:BAAALAAECgEIAQAAAA==.',['和你']='和你没关系:BAABLAAFFH8GAAIDAAIITAgBkAA/AAADAAIITAgBkAA/AAAAAA==.',['咕咕']='咕咕是一只猫:BAAALAADCggICAAAAA==.',['哒哒']='哒哒嘀哒哒:BAAALAADCgMIAwAAAA==.',['哔哔']='哔哔:BAAALAADCgYIBgAAAA==.',['哼哼']='哼哼哈兮:BAABLAAFFH8JAAIVAAMIYRc2EACpAAAVAAMIYRc2EACpAAAAAA==.',['嘎嘎']='嘎嘎大叔:BAAALAAECgYIBgAAAA==.嘎嘎的小手手:BAAALAAECggICAAAAA==.',['四哥']='四哥哥:BAAALAAECgYIBgAAAA==.',['图腾']='图腾下乡回收:BAAALAAECgIIAgAAAA==.',['圣的']='圣的力量:BAABLAAFFH8KAAILAAIIWxkNNACnAAALAAIIWxkNNACnAAAAAA==.',['在你']='在你身后:BAAALAAECgYIEgAAAA==.',['坚韧']='坚韧的雪贝:BAABLAAFFH8GAAIFAAIIMAaQuQAxAAAFAAIIMAaQuQAxAAAAAA==.',['埃克']='埃克瑟利昂:BAAALAAECgYIBgAAAA==.',['塔迪']='塔迪乌斯:BAAALAAECgMIAwAAAA==.',['墨無']='墨無訫:BAAALAAFFAIIBAAAAA==.',['墨色']='墨色轻纱:BAABLAAFFH8LAAIIAAII1Ry/QQCYAAAIAAII1Ry/QQCYAAAAAA==.',['夔因']='夔因:BAAALAAECgYICgAAAA==.',['多拉']='多拉贡:BAACLAAFFH8lAAIGAAUIriN7CAChAQAGAAUIriN7CAChAQAsAAQKf1MAAwYACAjPJDABAPMCAAYACAjPJDABAPMCABYAAghZA4AcADUAAAAA.',['夜色']='夜色最撩人:BAAALAAFFAIIBAAAAA==.夜色醉撩人:BAABLAAFFH8HAAISAAIIBw+CEwCHAAASAAIIBw+CEwCHAAAAAA==.',['夜锋']='夜锋:BAAALAAECgYIDgAAAA==.',['大侠']='大侠西北风:BAABLAAFFH8MAAICAAII4Be1NACaAAACAAII4Be1NACaAAAAAA==.',['大凤']='大凤:BAAALAAECgUIBQAAAA==.',['大观']='大观世音菩萨:BAAALAAECgYIBgAAAA==.',['大雨']='大雨:BAAALAAECgYIBgAAAA==.',['天启']='天启随风:BAAALAADCgEIAQAAAA==.',['天尊']='天尊护法:BAAALAAECgYIDAAAAA==.',['天气']='天气好晴朗:BAAALAAECgQIBAAAAA==.',['天潜']='天潜:BAAALAAECgIIAgAAAA==.',['天灾']='天灾坤坤:BAABLAAECn8VAAIDAAYIIxt+nwDIAQADAAYIIxt+nwDIAQAAAA==.',['天真']='天真的避风港:BAAALAAECgYICAAAAA==.',['天降']='天降正义:BAABLAAFFH8GAAIXAAMIMAzmEQBmAAAXAAMIMAzmEQBmAAAAAA==.',['奥雷']='奥雷利亚:BAAALAAFFAIIAgAAAA==.',['奶盖']='奶盖多多丶:BAABLAAFFH8GAAIMAAIIXQeUTACHAAAMAAIIXQeUTACHAAAAAA==.',['好奇']='好奇喵:BAAALAAECgYIBgAAAA==.',['姆丝']='姆丝加奥:BAACLAAFFH8RAAISAAMIXR22CwCiAAASAAMIXR22CwCiAAAsAAQKfxYAAhIACAjCInENAMsCABIACAjCInENAMsCAAAA.',['威震']='威震天:BAAALAAECgYIDQAAAA==.',['宇宙']='宇宙大帝:BAAALAAFFAIIAgAAAA==.',['宇文']='宇文浩劫:BAABLAAFFH8GAAIYAAIIfwxDNACJAAAYAAIIfwxDNACJAAAAAA==.',['守护']='守护:BAAALAAECgIIBgAAAA==.',['小可']='小可空白:BAAALAAECgIIAgAAAA==.',['小小']='小小乂幻樱:BAAALAAECgYIBwAAAA==.小小的嘉米:BAAALAAFFAIIAgAAAA==.',['小无']='小无双:BAAALAADCgEIAQAAAA==.',['小术']='小术闹闹:BAAALAAFFAIIAgAAAA==.',['小水']='小水墨:BAAALAAECgIIAgAAAA==.',['小爱']='小爱苟萨:BAABLAAFFH8oAAIWAAcIpBaWAwDWAQAWAAcIpBaWAwDWAQAAAA==.小爱酱:BAAALAAECgYIBgAAAA==.',['小牧']='小牧闹闹:BAABLAAFFH8MAAIZAAIIVxFTAwCKAAAZAAIIVxFTAwCKAAAAAA==.',['小翻']='小翻小小:BAAALAAFFAIIAgAAAA==.',['小菊']='小菊头蝠:BAABLAAFFH8jAAMJAAYIOx9uHACpAQAJAAYIOx9uHACpAQASAAIIUBMuEwCIAAAAAA==.',['小飒']='小飒雪:BAABLAAECn8bAAMQAAYIQhZ4IADRAAAQAAQIZRF4IADRAAAMAAYIvg2dZgDNAAAAAA==.',['小鬼']='小鬼儿最难缠:BAAALAAFFAIIAgAAAA==.',['尤霏']='尤霏:BAAALAAFFAIIAgAAAA==.',['就很']='就很气:BAAALAAECgYIBgAAAA==.',['山丘']='山丘丨之王:BAAALAAECgEIAQAAAA==.',['崂山']='崂山绿:BAAALAAECgYIBgAAAA==.',['帕奇']='帕奇维克战:BAAALAAFFAIIAwAAAA==.',['带瞎']='带瞎子看电影:BAABLAAFFH8GAAMDAAYIuB7YDQDpAQADAAUICR/YDQDpAQAaAAEIIx0wFwBpAAAAAA==.',['帶着']='帶着靈魂漫步:BAAALAADCgQIBAAAAA==.',['幽冥']='幽冥的咏叹:BAAALAAFFAIIAgAAAA==.幽冥魔帝:BAAALAAFFAIIAgAAAA==.',['库胖']='库胖:BAAALAAECgYICAAAAA==.',['开心']='开心一笑:BAAALAAECgcIDAAAAA==.开心丶泡泡:BAAALAAECgUICwAAAA==.开心咕咕喵:BAAALAAECgYIBgAAAA==.开心大领主:BAABLAAECn8cAAILAAYIryOhUwBHAgALAAYIryOhUwBHAgAAAA==.开心旋律曲:BAABLAAECn8nAAIIAAYIKiK5IADkAQAIAAYIKiK5IADkAQAAAA==.',['开枪']='开枪就放倒:BAAALAAECgYIBgAAAA==.',['弗丁']='弗丁:BAAALAAFFAIIAgAAAA==.弗丁的灾变:BAAALAAECgEIAQAAAA==.',['弹奏']='弹奏寂寞:BAAALAAFFAIIBAAAAA==.',['影月']='影月:BAABLAAFFH8GAAIFAAYIWw79PgBNAQAFAAYIWw79PgBNAQAAAA==.',['待嫁']='待嫁:BAAALAADCggICAAAAA==.',['德莱']='德莱厄斯:BAAALAADCgIIAgAAAA==.',['忍者']='忍者叶:BAAALAAFFAMIAwAAAA==.',['快跑']='快跑啊小姑娘:BAAALAAECgYIDAAAAA==.',['怀夕']='怀夕:BAAALAAFFAIIAgAAAA==.',['思华']='思华年:BAAALAADCgUIBQAAAA==.',['思律']='思律機薩:BAAALAAECgQIBAAAAA==.',['恩莱']='恩莱科:BAAALAAECgYICQAAAA==.',['恶魔']='恶魔君王:BAABLAAFFH8GAAIIAAII9wZ1YwA9AAAIAAII9wZ1YwA9AAAAAA==.恶魔闹闹:BAABLAAFFH8MAAIIAAIIRQpUXwBAAAAIAAIIRQpUXwBAAAAAAA==.',['感受']='感受这:BAAALAAECgYICgAAAA==.',['慢慢']='慢慢玩吧:BAABLAAFFH8sAAIDAAYIzwrDNwBfAQADAAYIzwrDNwBfAQAAAA==.',['我也']='我也不知:BAAALAAECgEIAQAAAA==.',['我只']='我只喝特仑苏:BAAALAAFFAIIBAAAAA==.',['我就']='我就酷:BAAALAADCgEIAQAAAA==.',['我是']='我是圣女:BAAALAAECgYIBgAAAA==.',['我有']='我有大犄角:BAAALAADCgEIAQAAAA==.',['扯拐']='扯拐猫:BAAALAADCgcIBwAAAA==.',['抠你']='抠你丫的:BAAALAADCgYICQAAAA==.',['护夜']='护夜娜娜:BAAALAAECgcIDAAAAA==.',['护法']='护法天尊:BAACLAAFFH8PAAIYAAIIegcBRQBiAAAYAAIIegcBRQBiAAAsAAQKfxkAAhgABgj0EohhAFgBABgABgj0EohhAFgBAAAA.',['抹茶']='抹茶多多丶:BAABLAAFFH8IAAIJAAIIgQ9YSgCWAAAJAAIIgQ9YSgCWAAAAAA==.',['拥你']='拥你进我怀里:BAABLAAFFH8MAAIFAAYIqxztKQCPAQAFAAYIqxztKQCPAQAAAA==.',['拾柒']='拾柒:BAAALAAECggIBgAAAA==.',['挽月']='挽月清风:BAABLAAFFH8GAAIIAAIIqQrIYAA/AAAIAAIIqQrIYAA/AAAAAA==.',['斗魂']='斗魂觉醒:BAAALAAECgYIBgAAAA==.',['斯文']='斯文土豆:BAAALAAECgYIBgAAAA==.',['无双']='无双小迷妹:BAAALAAFFAIIAgAAAA==.',['无敌']='无敌神棍德:BAAALAAFFAMIAwAAAA==.',['时光']='时光煮酒:BAAALAAECgYICwAAAA==.',['昂剑']='昂剑:BAAALAAECgYICgAAAA==.',['明觉']='明觉不厉:BAAALAAECgYIDAAAAA==.',['晓風']='晓風残玥:BAAALAAECgYICgAAAA==.',['晨梦']='晨梦初醒:BAABLAAFFH8GAAILAAIIQhGiaQBCAAALAAIIQhGiaQBCAAAAAA==.',['暖阳']='暖阳丶:BAABLAAFFH8KAAIMAAgIRCKdBwCGAgAMAAgIRCKdBwCGAgAAAA==.',['暗影']='暗影如风:BAAALAAFFAIIAgAAAA==.',['暗月']='暗月之夜:BAAALAADCgIIAgAAAA==.暗月死骑:BAAALAADCgMIAwAAAA==.',['暴力']='暴力狗:BAAALAAECgUIBQAAAA==.',['最美']='最美的烈酒:BAAALAADCgQIBAAAAA==.',['望咩']='望咩啊:BAAALAADCgYIBgAAAA==.',['期待']='期待:BAAALAAECgYIBgAAAA==.',['朱双']='朱双宝宝:BAAALAAECgYICAAAAA==.',['杰西']='杰西娅:BAABLAAFFH8KAAIDAAYIJSDTJQCgAQADAAYIJSDTJQCgAQAAAA==.',['林语']='林语唐:BAAALAADCgEIAQAAAA==.',['枪杰']='枪杰克:BAABLAAECn8WAAMQAAgIIx30HgAJAgAMAAgILRuuTQAJAgAQAAYIoB30HgAJAgAAAA==.',['柚子']='柚子先生:BAAALAAFFAIIAwAAAA==.',['柠檬']='柠檬红茶:BAAALAAECgQIBgAAAA==.',['柳如']='柳如霜:BAABLAAFFH8IAAIFAAYIMA8dQABJAQAFAAYIMA8dQABJAQABLAAFFAgIDAAFACgbAA==.',['柳絮']='柳絮随风飘:BAAALAADCgMIAwAAAA==.',['梦伴']='梦伴:BAABLAAFFH8WAAMbAAYIYRhVBACqAAAJAAUIDxg3IgAVAQAbAAQIeRRVBACqAAABLAAFFAgIQQAJAF0kAA==.',['梵额']='梵额林:BAAALAAECgQIBgAAAA==.',['楓訫']='楓訫標簽:BAACLAAFFH8hAAQaAAYIuhYyCADpAAADAAYIUBaiLACIAQAaAAMIPBIyCADpAAANAAEIAAKiHgAoAAAsAAQKfyUAAxoACAgPIWwGAPICABoACAg+IGwGAPICAAMABggLHTx2AAsCAAAA.',['橘味']='橘味可乐:BAABLAAFFH8FAAIRAAIIHghEbwBMAAARAAIIHghEbwBMAAAAAA==.',['橙子']='橙子多多丶:BAABLAAFFH8IAAQcAAII+guZJQB8AAAcAAII+guZJQB8AAAPAAIIQQl9PgBhAAAdAAEI7AFvFAArAAAAAA==.',['欧扬']='欧扬雨凡:BAAALAADCgEIAQAAAA==.',['歌月']='歌月武影:BAAALAAECgEIAQAAAA==.',['正经']='正经辣妹:BAAALAAECgIIAgAAAA==.',['此刻']='此刻浪漫:BAAALAAECgIIAgAAAA==.',['死孩']='死孩子皮:BAACLAAFFH8XAAIRAAUIvyCfFAC9AQARAAUIvyCfFAC9AQAsAAQKfxsAAhEACAgxIC8XAMICABEACAgxIC8XAMICAAAA.',['死骑']='死骑闹闹:BAABLAAFFH8MAAIDAAIIaRilVACeAAADAAIIaRilVACeAAAAAA==.',['水墨']='水墨嫣然:BAAALAADCggICAAAAA==.',['江疏']='江疏影:BAAALAAFFAIIAgAAAA==.',['法娘']='法娘:BAAALAAECgYIBgAAAA==.',['流星']='流星陨落:BAABLAAFFH8JAAISAAIIZSDhCAC+AAASAAIIZSDhCAC+AAAAAA==.',['流浪']='流浪的小恶魔:BAAALAAFFAIIBAAAAA==.',['浅笑']='浅笑曾经:BAAALAAECgYIBgAAAA==.',['海川']='海川:BAAALAADCgIIAgAAAA==.',['渃漪']='渃漪:BAABLAAFFH8UAAIYAAUIHw98IgAyAQAYAAUIHw98IgAyAQAAAA==.',['渃翼']='渃翼:BAABLAAFFH8PAAILAAQIZg8LHgDcAAALAAQIZg8LHgDcAAABLAAFFAYIDgARAMQMAA==.',['清甜']='清甜乌龙:BAAALAAECgYIDQAAAA==.',['游想']='游想想:BAABLAAFFH8MAAIJAAMIBQwiLQDdAAAJAAMIBQwiLQDdAAAAAA==.',['湮灭']='湮灭之魂:BAAALAADCgEIAQAAAA==.',['源聚']='源聚一生:BAAALAADCgMIAwAAAA==.',['溡緔']='溡緔绯註蓅:BAAALAAFFAIIBAAAAA==.',['漫卷']='漫卷西风:BAAALAADCgQIBAAAAA==.',['灰烬']='灰烬君王:BAABLAAFFH8IAAIDAAIImBqebwBWAAADAAIImBqebwBWAAAAAA==.',['燕红']='燕红叶:BAAALAADCggICQAAAA==.',['爆炸']='爆炸的雪贝:BAAALAAECgIIAgAAAA==.',['爱上']='爱上猫地鱼:BAAALAAECgYIBgAAAA==.',['爱之']='爱之无奈:BAAALAAECgUICgAAAA==.',['爱睡']='爱睡的云:BAABLAAFFH8GAAIRAAIIAwOwbABSAAARAAIIAwOwbABSAAAAAA==.',['片片']='片片血宁静:BAAALAAECgYICgAAAA==.',['牌子']='牌子丶班尼路:BAAALAAECgYIDgAAAA==.',['牛腾']='牛腾兰:BAAALAADCgQIBAAAAA==.',['牧野']='牧野旋风:BAAALAAECgYIBgAAAA==.',['特别']='特别周:BAAALAAECgYIBgAAAA==.',['狐烈']='狐烈烈:BAAALAAECgQIBAAAAA==.',['猎猎']='猎猎闹闹:BAABLAAFFH8IAAIFAAIIYgoiaQCFAAAFAAIIYgoiaQCFAAAAAA==.',['猫猫']='猫猫爱唱歌:BAACLAAFFH8xAAIYAAUIvSO4DAAEAgAYAAUIvSO4DAAEAgAsAAQKfxsAAhgACAieIZUPAOsCABgACAieIZUPAOsCAAAA.',['玄学']='玄学不救非酋:BAAALAADCgUIBQAAAA==.',['王后']='王后:BAAALAAECgYICgAAAA==.',['王者']='王者雷霆:BAAALAAECgMIAwAAAA==.',['玻璃']='玻璃灬訫:BAAALAAECgcIDAAAAA==.',['珑溪']='珑溪儿:BAAALAAECgYICQAAAA==.',['琉璃']='琉璃眸娃娃:BAAALAAECgcIBwAAAA==.',['瑟琳']='瑟琳娜:BAABLAAFFH8jAAMRAAUIpRUYIwBIAQARAAUIpRUYIwBIAQAHAAUIBQ2sLADaAAABLAAFFAYIIQAFACIhAA==.',['生生']='生生所资:BAACLAAFFH8IAAILAAMIDQsNTABpAAALAAMIDQsNTABpAAAsAAQKfxYAAgsABghAGuelAK4BAAsABghAGuelAK4BAAAA.',['留念']='留念人间:BAAALAAFFAIIAgAAAA==.',['百亿']='百亿乌鸦:BAAALAAECgQIAgAAAA==.',['盗戝']='盗戝:BAAALAAECgYIEQAAAA==.',['盛大']='盛大登场:BAAALAAFFAIIAgAAAA==.',['真衣']='真衣:BAAALAAECgYICAAAAA==.',['着魔']='着魔:BAAALAAECgIIAgAAAA==.',['睡到']='睡到小时候:BAAALAAECgYIBgAAAA==.',['砍怪']='砍怪我先冲:BAAALAADCgIIAgAAAA==.',['确认']='确认下眼神:BAAALAAECgcIDAAAAA==.',['磁起']='磁起彼伏:BAAALAAFFAMIBAAAAA==.',['秋满']='秋满:BAABLAAFFH8IAAIRAAMI+gW8VgBuAAARAAMI+gW8VgBuAAAAAA==.',['筹灬']='筹灬码:BAAALAAECgIIAgAAAA==.',['简单']='简单点:BAAALAAECgYIEAAAAA==.',['索尼']='索尼:BAAALAAECgYIBgAAAA==.',['紫眉']='紫眉毛:BAAALAAECgEIAQAAAA==.',['紫箬']='紫箬:BAAALAADCgUIBQAAAA==.',['紫顏']='紫顏:BAAALAADCgYIBgAAAA==.',['红烧']='红烧大咕咕:BAAALAAECgcICgAAAA==.',['红镰']='红镰渡佳人:BAAALAAECgIIAgAAAA==.',['缘筱']='缘筱天:BAAALAAECgYIBgAAAA==.',['老狩']='老狩猎者:BAAALAADCgcIBwAAAA==.',['老骨']='老骨头:BAABLAAECn8bAAIFAAYINBvBcABjAQAFAAYINBvBcABjAQAAAA==.',['肤白']='肤白大波浪:BAAALAAFFAIIAgAAAA==.',['自游']='自游自在:BAAALAADCgYIBgAAAA==.',['艾拉']='艾拉小德:BAAALAAECgUIBQAAAA==.',['艾迪']='艾迪丶泡泡:BAAALAAECgYICwAAAA==.',['苏枋']='苏枋:BAAALAAECgIIAgAAAA==.',['茉莉']='茉莉灬:BAAALAAECgUIBQAAAA==.',['草氯']='草氯蟲:BAAALAADCgQIBAAAAA==.',['荡啊']='荡啊荡啊荡:BAAALAAECgIIAgAAAA==.',['莱耶']='莱耶斯:BAABLAAECn8eAAMeAAgIBAhuNwASAQAeAAgIBAhuNwASAQAIAAMICwPSQwFWAAAAAA==.',['菜刀']='菜刀之怒:BAACLAAFFH8kAAQOAAYIoRbsBwCxAQAOAAYIoRbsBwCxAQAVAAUIkQqIFQDmAAAfAAMIIgmGEgB0AAAsAAQKfxgABA4ABwhGGbQPALABAA4ABgg2GLQPALABABUABggqFJQlAGUBAB8AAQh4HLFjAFUAAAEsAAUUBgguAAkAXRwA.菜刀之猎:BAABLAAFFH8nAAIFAAYIRhy0HwAKAQAFAAYIRhy0HwAKAQABLAAFFAYILgAJAF0cAA==.菜刀之骑:BAACLAAFFH8oAAMgAAYI2yEKBQBSAgAgAAYI2yEKBQBSAgALAAUI2xhEKAA8AQAsAAQKfykAAwsACAhzIJkuALgCAAsABwimIpkuALgCACAABwgIGqwjAPoBAAEsAAUUBgguAAkAXRwA.菜刀火车侠:BAACLAAFFH8mAAQCAAYI/hzgEgDDAQACAAYI/hzgEgDDAQABAAIIYAkCBwBmAAAUAAEIXQW5PQAAAAAsAAQKfzAAAwEACAh/IroGAJUCAAIACAj9IHMkALMCAAEACAg1ILoGAJUCAAEsAAUUBgguAAkAXRwA.菜刀烈焰之灼:BAACLAAFFH8uAAMJAAYIXRw5GgC1AQAJAAYIXRw5GgC1AQAbAAMI7gd/CABzAAAsAAQKfykAAxsABgh4IQsJAMUBAAkABgicIJBLACMCABsABgg4GAsJAMUBAAAA.菜刀的欧米伽:BAACLAAFFH8hAAMYAAcIZxgqDAALAgAYAAcIIxgqDAALAgAZAAEIuBlwBQBQAAAsAAQKfxoAAxkABghiIxoGAGACABkABghiIxoGAGACABgABghkGqgkAJIBAAEsAAUUCAghABgAkBsA.菜刀的萨满:BAACLAAFFH8pAAMRAAYIFhY/GwCEAQARAAYIFhY/GwCEAQAHAAUIZg0MJwASAQAsAAQKfyQAAxEABgj5HVgrALwBABEABgj5HVgrALwBAAcABgh/HM8oAHsBAAEsAAUUBgguAAkAXRwA.菜刀萌萌德:BAABLAAFFH8mAAMPAAYI1SH0BQBTAgAPAAYI1SH0BQBTAgAcAAEIpA6nMgA+AAABLAAFFAYILgAJAF0cAA==.',['菜瓜']='菜瓜瓜:BAAALAAECgYIBgAAAA==.',['萨掌']='萨掌柜:BAAALAAECgIIAgAAAA==.',['萨斯']='萨斯多拉:BAAALAADCggIDwAAAA==.',['萨满']='萨满闹闹:BAABLAAFFH8IAAIRAAIIlwr1XgBhAAARAAIIlwr1XgBhAAAAAA==.',['萨鲁']='萨鲁法尔咆哮:BAAALAADCgQIBAAAAA==.',['落葵']='落葵:BAAALAAFFAIIAgAAAA==.',['葛温']='葛温德林:BAAALAAFFAMIAwAAAA==.',['蒼空']='蒼空青嵐:BAAALAAECgQIBAAAAA==.',['蓝色']='蓝色忧愁:BAAALAAFFAQIBAAAAA==.',['薄荷']='薄荷加水:BAAALAADCgMIAwAAAA==.薄荷糖微凉:BAAALAAECgYICgAAAA==.',['虾仁']='虾仁猪心灬:BAABLAAFFH8GAAIIAAYIxBt0GwCaAQAIAAYIxBt0GwCaAQAAAA==.',['蝴蝶']='蝴蝶兰:BAAALAADCgEIAQAAAA==.蝴蝶的保镖:BAAALAADCgIIAgAAAA==.',['血腥']='血腥该隐:BAAALAAECgUIBQAAAA==.',['血魔']='血魔瞳:BAAALAADCgQIBAAAAA==.',['谓我']='谓我何求:BAAALAAECgYICAAAAA==.',['谢谢']='谢谢观赏:BAAALAADCggICAAAAA==.',['谷尔']='谷尔旦:BAAALAAFFAIIAgAAAA==.',['豆丁']='豆丁宝宝:BAAALAADCgMIAwAAAA==.',['賈薾']='賈薾震撼源:BAACLAAFFH8HAAIPAAIINQ8yMgBwAAAPAAIINQ8yMgBwAAAsAAQKfxgAAg8ABwhiFytDANQBAA8ABwhiFytDANQBAAEsAAUUCAgDAAQAAAAA.',['贺兰']='贺兰豆:BAACLAAFFH8HAAILAAIIlhhwLACxAAALAAIIlhhwLACxAAAsAAQKfyUAAwsABgheJLBAAHkCAAsABgheJLBAAHkCABcABggZHH4iAOcBAAAA.',['贺走']='贺走走:BAAALAAECgEIAQAAAA==.',['赖美']='赖美云:BAAALAAECgEIAQAAAA==.',['赢赢']='赢赢:BAAALAAECgYIBwAAAA==.',['赫敏']='赫敏:BAABLAAECn8UAAIMAAYIfApmYADfAAAMAAYIfApmYADfAAAAAA==.',['走路']='走路有点斜:BAAALAADCgEIAQAAAA==.',['路宝']='路宝纽字:BAABLAAFFH8JAAIFAAUIlA7sUwADAQAFAAUIlA7sUwADAQAAAA==.',['辉火']='辉火:BAABLAAFFH8LAAIFAAYIrwR9cwB8AAAFAAYIrwR9cwB8AAAAAA==.',['辰辰']='辰辰:BAAALAAFFAIIBAAAAA==.',['达利']='达利派:BAAALAADCggIBgAAAA==.',['逆行']='逆行天下:BAAALAAECggIEAAAAA==.',['逆风']='逆风祈雨丶:BAAALAAFFAYIAgAAAA==.',['选择']='选择流浪:BAABLAAFFH8KAAIFAAIIPxA8oQA+AAAFAAIIPxA8oQA+AAAAAA==.',['那边']='那边的狼人:BAABLAAECn8jAAMFAAgIUBC+lQApAQAFAAgIUQ6+lQApAQAKAAYIrg4ragAdAQAAAA==.',['邦桑']='邦桑迪:BAAALAADCgYIBgAAAA==.',['郝思']='郝思嘉嘉:BAAALAADCggICAAAAA==.',['重铸']='重铸聖光:BAACLAAFFH8ZAAIDAAYIhBphJAClAQADAAYIhBphJAClAQAsAAQKfyoAAgMABgjfJccWADMCAAMABgjfJccWADMCAAAA.',['长相']='长相一般:BAAALAAECgYIBgAAAA==.长相很黑:BAAALAADCggICAAAAA==.',['长缨']='长缨:BAAALAAECgIIAgAAAA==.',['问我']='问我个锤子:BAABLAAECn8eAAILAAgIViO1EgAuAwALAAgIViO1EgAuAwAAAA==.',['阿狸']='阿狸爱钓鱼:BAAALAADCgQIBAAAAA==.',['阿里']='阿里嘎多:BAAALAAECgUIBgAAAA==.',['陈洁']='陈洁琪:BAAALAAECgYICwAAAA==.',['陌上']='陌上錵開:BAAALAAECgcIDwAAAA==.',['随意']='随意猎:BAAALAAECgcICwAAAA==.',['雄魄']='雄魄:BAAALAAECgMIAwAAAA==.',['雨季']='雨季过境:BAABLAAFFH8GAAIYAAIIGQPiSQBWAAAYAAIIGQPiSQBWAAAAAA==.',['雪丨']='雪丨吻:BAACLAAFFH8JAAIDAAII2R2OTACjAAADAAII2R2OTACjAAAsAAQKfxQAAgMABgiRIGmFAPABAAMABgiRIGmFAPABAAAA.',['雪乂']='雪乂吻:BAABLAAFFH8IAAIRAAIIOxaUQACAAAARAAIIOxaUQACAAAAAAA==.',['雪乄']='雪乄吻:BAABLAAFFH8IAAIFAAIIzhxqXACOAAAFAAIIzhxqXACOAAAAAA==.',['雪花']='雪花随风飘:BAAALAADCgMIAwAAAA==.',['雪诺']='雪诺:BAAALAAECgYICAAAAA==.',['雪贝']='雪贝公主:BAABLAAFFH8GAAICAAII5ghRVABBAAACAAII5ghRVABBAAAAAA==.',['雾气']='雾气麻黑:BAAALAADCggIGAAAAA==.',['霸天']='霸天虎:BAAALAAECgYIEgAAAA==.',['霸气']='霸气:BAAALAAECgcIDAAAAA==.',['青薇']='青薇:BAAALAADCgYIBgAAAA==.',['非美']='非美女:BAAALAAECgYIDwAAAA==.',['风暴']='风暴之怒:BAAALAAECgcIDAAAAA==.风暴降生:BAAALAAECgUIBQAAAA==.',['风流']='风流丶斐语:BAAALAADCgYIBgAAAA==.',['风起']='风起沧海:BAABLAAFFH8GAAIIAAMIpwvbQACNAAAIAAMIpwvbQACNAAAAAA==.',['骑士']='骑士归来之时:BAAALAAECgEIAQAAAA==.',['高文']='高文丨塞西尔:BAABLAAFFH8MAAICAAIIDxIVOgCUAAACAAIIDxIVOgCUAAAAAA==.',['魅鱼']='魅鱼:BAACLAAFFH8KAAIIAAIIlRUUQACZAAAIAAIIlRUUQACZAAAsAAQKfxQAAwgABwhrIXhPADQCAAgABwhrIXhPADQCAB4AAQjtIRxaAGMAAAAA.',['魔法']='魔法闹闹:BAABLAAFFH8MAAIJAAIIdg5jTACUAAAJAAIIdg5jTACUAAAAAA==.',['魔雾']='魔雾:BAAALAADCgEIAQAAAA==.魔雾随从:BAAALAADCgYIBgAAAA==.',['鸟人']='鸟人:BAAALAAECgUICAAAAA==.',['鸿运']='鸿运当头:BAAALAAECgYIBgAAAA==.',['鹰击']='鹰击长空丿:BAAALAADCgQIBAAAAA==.',['鹿斗']='鹿斗典善:BAAALAAFFAIIAgAAAA==.',['麝香']='麝香葡萄:BAABLAAFFH8GAAMXAAMIABWBEAB3AAAXAAMIABWBEAB3AAALAAEI2QDXbQAcAAAAAA==.',['黄花']='黄花菜小龙包:BAAALAAECgYIBgAAAA==.',['黑石']='黑石行者:BAAALAAFFAIIBAAAAA==.',['黛绮']='黛绮丝:BAABLAAFFH8JAAIFAAMImRSFbgCHAAAFAAMImRSFbgCHAAAAAA==.',['龙妹']='龙妹妹:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end