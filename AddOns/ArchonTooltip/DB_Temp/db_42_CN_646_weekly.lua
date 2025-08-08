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
 local lookup = {'Rogue-Outlaw','Warrior-Arms','Warrior-Fury','Paladin-Retribution','Hunter-BeastMastery','Rogue-Assassination','Druid-Restoration','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','DeathKnight-Unholy','DemonHunter-Havoc','Warlock-Destruction','Evoker-Devastation','Druid-Balance','Shaman-Elemental','Warlock-Affliction','Paladin-Holy','Druid-Feral','Mage-Fire','Mage-Arcane','Warlock-Demonology','Shaman-Restoration','DeathKnight-Frost','Warrior-Protection','DeathKnight-Blood','Druid-Guardian','Mage-Frost','Priest-Holy','Priest-Discipline','Priest-Shadow','Evoker-Preservation','Rogue-Subtlety','Monk-Brewmaster','Paladin-Protection','Unknown-Unknown','Shaman-Enhancement','DemonHunter-Vengeance',}; local provider = {region='CN',realm='奥达曼',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Acoge:BAABKgAECn9gAAIBAAgIHR4AAgBgAgABAAgIHR4AAgBgAgAAAA==.Acosta:BAAAKgAECgQIBgAAAA==.',At='Atalante:BAAAKgAECgcICgAAAA==.',Bi='Bigseven:BAAAKgADCggIDQAAAA==.',Br='Bressanon:BAAAKgADCggICAAAAA==.',Bu='Burnteddy:BAABKgAFFH8HAAMCAAYIXA5KAwA/AQACAAQIvQxKAwA/AQADAAMIIRJFHACmAAAAAA==.',Ca='Carreras:BAABKgAECn8gAAIDAAgIjBCsLwByAQADAAgIjBCsLwByAQAAAA==.',Cc='Cchris:BAAAKgAFFAQIBAAAAA==.Ccrbq:BAAAKgAECgIIAgAAAA==.',De='Deathfeather:BAABKgAFFH8VAAIEAAYI0yJ+DQD6AQAEAAYI0yJ+DQD6AQAAAA==.',Do='Doremon:BAAAKgAECgIIAgAAAA==.',Ec='Eclipsee:BAABKgAECn8ZAAIEAAcI2Rx/YQDZAQAEAAcI2Rx/YQDZAQAAAA==.',Fe='Feely:BAABKgAFFH8GAAIFAAYImxhIDgCPAQAFAAYImxhIDgCPAQAAAA==.',Fo='Forgetyou:BAABKgAFFH8IAAIGAAgIsgi1BQD9AQAGAAgIsgi1BQD9AQAAAA==.',Go='Goingunder:BAAAKgAFFAQIBAAAAA==.',Gw='Gwenstefani:BAAAKgAECgUIBwAAAA==.',Ha='Hallelujah:BAABKgAFFH8MAAIEAAcI2BGqFQCuAQAEAAcI2BGqFQCuAQAAAA==.',Ky='Kytee:BAAAKgAECgIIAgAAAA==.',La='Latenight:BAABKgAFFH8GAAIHAAYIYxbrCAB5AQAHAAYIYxbrCAB5AQAAAA==.',Li='Lifedrain:BAAAKgAECggIEwAAAA==.',Lu='Lumix:BAAAKgAECgUIBQAAAA==.',Ma='Maydie:BAAAKgAECggICAAAAA==.',Mi='Milka:BAABKgAFFH8LAAMIAAYI3RwIEwBKAQAFAAUI+R6sDABvAQAIAAYIkxcIEwBKAQAAAA==.',Mo='Moonspring:BAAAKgAECgUICQAAAA==.',Sa='Saintsrow:BAAAKgAFFAIIAgAAAA==.Sandro:BAAAKgAFFAQIBAAAAA==.',Sh='Shadoo:BAAAKgAECgYIBwAAAA==.',Ta='Taro:BAABKgAFFH8GAAIIAAYIXyQ5BwDvAQAIAAYIXyQ5BwDvAQAAAA==.',To='Toolkit:BAAAKgAECggICAAAAA==.',Ur='Ursoll:BAAAKgAECggICAAAAA==.',Va='Vashrei:BAAAKgAFFAIIAgAAAA==.',Wa='Wa:BAAAKgAECgYICgAAAA==.',Wy='Wyrd:BAAAKgAECgcIDgAAAA==.',Yi='Yiyu:BAAAKgAECgUIBQAAAA==.',['一个']='一个骑士:BAAAKgADCgcIBwAAAA==.',['一千']='一千叔啊啊:BAAAKgAECggICAAAAA==.',['一滴']='一滴都没啦:BAAAKgADCgEIAQAAAA==.',['丁真']='丁真:BAAAKgAFFAIIAgAAAA==.',['七个']='七个隆冬强:BAAAKgADCgMIAwAAAA==.',['万俟']='万俟翔幻:BAAAKgAECgIIAgAAAA==.',['三仨']='三仨分毒:BAAAKgADCggIEAAAAA==.',['三尺']='三尺剑:BAACKgAFFH8GAAMJAAMI0AfDDwChAAAJAAMI0AfDDwChAAAKAAMI1ARaFAB3AAAqAAQKfyQAAwoACAh9GvMUAOkBAAoACAh9GvMUAOkBAAkAAgicDu8sADEAAAAA.',['不喜']='不喜农:BAAAKgADCggICAAAAA==.',['不惑']='不惑之痒:BAAAKgAECgcIDgAAAA==.',['不死']='不死不归:BAABKgAFFH8GAAILAAYI5xIjGABcAQALAAYI5xIjGABcAQAAAA==.',['不玩']='不玩惩戒骑:BAAAKgAFFAQIBAABKgAFFAgIHAAMACQZAA==.',['不要']='不要爱我灬:BAAAKgAECgYIBgAAAA==.',['严禁']='严禁黄赌毒:BAABKgAFFH8GAAIEAAYIDxyxGACYAQAEAAYIDxyxGACYAQAAAA==.',['丶扒']='丶扒衣老爷丶:BAAAKgAECggIEQAAAA==.',['丶放']='丶放开那嫂嫂:BAABKgAFFH8KAAIKAAgI1BUKBgDoAQAKAAgI1BUKBgDoAQAAAA==.',['丶石']='丶石原里美:BAABKgAFFH8GAAIFAAYIuBz9CQC5AQAFAAYIuBz9CQC5AQAAAA==.',['乔妹']='乔妹:BAAAKgADCgEIAQAAAA==.',['九亿']='九亿少男的梦:BAAAKgADCggIEwAAAA==.',['九秋']='九秋莲:BAABKgAFFH8GAAINAAMIsAUDHwCOAAANAAMIsAUDHwCOAAAAAA==.',['五月']='五月的图腾:BAAAKgAECgQIBAAAAA==.',['亚琉']='亚琉哲:BAAAKgAECggICAAAAA==.',['人高']='人高狗大:BAAAKgAECgcICAAAAA==.',['企鹅']='企鹅不是鹅:BAABKgAFFH8HAAIIAAcIJgtACwBdAQAIAAcIJgtACwBdAQAAAA==.',['伊地']='伊地知虹夏:BAAAKgADCggIDAABKgAFFAMIDAAOAOkiAA==.',['伊晓']='伊晓万:BAAAKgADCggICAAAAA==.',['伊露']='伊露维恩:BAABKgAFFH8GAAIPAAYIahjCEwB9AQAPAAYIahjCEwB9AQAAAA==.',['优伶']='优伶丨虚:BAAAKgAECgYICQAAAA==.',['佛琳']='佛琳特火炉:BAAAKgAFFAIIAgAAAA==.',['你以']='你以为我不帅:BAAAKgAECgEIAQAAAA==.',['你说']='你说我不猛:BAAAKgADCgEIAQAAAA==.',['佩露']='佩露薇利:BAABKgAFFH8GAAIOAAYI6RhFDACiAQAOAAYI6RhFDACiAQAAAA==.',['來都']='來都來了:BAABKgAFFH8JAAIQAAQIBApZDwCoAAAQAAQIBApZDwCoAAAAAA==.',['侔侔']='侔侔:BAAAKgADCgEIAQAAAA==.',['修罗']='修罗煞:BAAAKgADCgQIBAAAAA==.',['俺滴']='俺滴麒麟臂:BAABKgAFFH8GAAIPAAYIiBfJFQBrAQAPAAYIiBfJFQBrAQAAAA==.',['假面']='假面涅盘:BAABKgAECn81AAMNAAgIgB7tCgBkAgANAAgIgB7tCgBkAgARAAEISAcFSAAvAAAAAA==.',['傻卷']='傻卷毛:BAAAKgAECggICAAAAA==.',['光光']='光光绿丶:BAABKgAFFH8VAAIQAAYIHBN9BwBlAQAQAAYIHBN9BwBlAQAAAA==.',['六水']='六水厂:BAAAKgAFFAEIAQAAAA==.',['六钧']='六钧弓:BAACKgAFFH8KAAMEAAMIoAnbXwCwAAAEAAMIoAnbXwCwAAASAAMIoA+1CgCqAAAqAAQKfzIAAwQACAiRHhQQAFsCAAQACAiRHhQQAFsCABIAAQgmBx8lACkAAAAA.',['军团']='军团大当家:BAABKgAECn8dAAMCAAgIaR2VBABcAgACAAgIaR2VBABcAgADAAQIiRHaWQCjAAAAAA==.',['冬枯']='冬枯草:BAABKgAECn81AAMHAAgIyxkLDQCbAQAHAAgIyxkLDQCbAQATAAcI4RQYEQBsAQAAAA==.',['冲锋']='冲锋变态:BAAAKgAECggICAAAAA==.',['凌雨']='凌雨洁:BAAAKgAECgYIBgAAAA==.',['凛冬']='凛冬灬之怒:BAAAKgADCggICAAAAA==.',['凤囚']='凤囚凰:BAAAKgAECggICAAAAA==.',['凭渊']='凭渊听雨眠:BAABKgAFFH8KAAIEAAYIhBuhGQCSAQAEAAYIhBuhGQCSAQAAAA==.',['凶猛']='凶猛的葫芦:BAAAKgAECgYIDAAAAA==.',['刀妹']='刀妹:BAABKgAFFH8GAAILAAYIGQXJHgAoAQALAAYIGQXJHgAoAQAAAA==.',['刚被']='刚被老婆删号:BAAAKgAECgUIBQAAAA==.',['初羽']='初羽艾瑞:BAABKgAFFH8KAAIEAAQIVQzPKQDLAAAEAAQIVQzPKQDLAAAAAA==.',['剑破']='剑破苍穹:BAAAKgAFFAIIAgAAAA==.',['劉鞴']='劉鞴:BAAAKgADCgEIAQAAAA==.',['北极']='北极甜虾:BAAAKgAFFAYIBAAAAA==.',['十六']='十六苍熏筱:BAAAKgADCggICAAAAA==.',['半个']='半个苹果:BAAAKgAFFAQIBAAAAA==.',['半岛']='半岛铁盒阿:BAAAKgAECgYIDAAAAA==.',['华发']='华发拆迁队:BAAAKgADCgQIBAAAAA==.',['卡多']='卡多雷之愛:BAAAKgAECggIEAAAAA==.',['卡莎']='卡莎尼梵蒂:BAABKgAFFH8MAAMRAAQIth2ABgD2AAARAAQIYh2ABgD2AAANAAQIzxh1EADlAAAAAA==.',['受死']='受死吧武器战:BAABKgAFFH8IAAIUAAQIPxpTIQDRAAAUAAQIPxpTIQDRAAAAAA==.',['古尔']='古尔円:BAAAKgAECgYICgAAAA==.',['古镇']='古镇刘亦菲:BAAAKgADCggIEQAAAA==.',['古馆']='古馆魔术师忧:BAABKgAECn8vAAIVAAgIZyB0BABMAgAVAAgIZyB0BABMAgAAAA==.',['叶清']='叶清欢:BAAAKgAECgMIAwAAAA==.',['叶落']='叶落孤:BAAAKgAFFAEIAQAAAA==.',['叶风']='叶风挡不住:BAAAKgADCggICAAAAA==.',['吃橙']='吃橙子的殇弢:BAAAKgADCgEIAQAAAA==.',['吃饱']='吃饱了才可爱:BAABKgAFFH8jAAMNAAgIiSSBAAD+AgANAAgIiSSBAAD+AgAWAAQI5xi4CQDpAAAAAA==.',['后山']='后山冷飕飕:BAAAKgAECggICAAAAA==.',['吟风']='吟风月:BAAAKgAECgQIBQAAAA==.',['听说']='听说你很勇噢:BAAAKgAFFAQIBAAAAA==.',['告死']='告死之靈:BAAAKgAECggIDQAAAA==.',['告白']='告白气球:BAAAKgAECgMIAwAAAA==.',['和联']='和联胜丶星爷:BAABKgAECn8VAAILAAgICxudMwCnAQALAAgICxudMwCnAQAAAA==.',['和谐']='和谐小牧:BAAAKgAECgEIAQAAAA==.',['咕噜']='咕噜噗:BAABKgAFFH8MAAIFAAMIbyFAHAAhAQAFAAMIbyFAHAAhAQAAAA==.',['哑蠛']='哑蠛蝶:BAAAKgAECgcIDQAAAA==.',['哟哟']='哟哟帅气:BAABKgAECn8gAAIEAAgIzSDfHgCdAgAEAAgIzSDfHgCdAgAAAA==.',['哟黄']='哟黄:BAAAKgADCggICAAAAA==.',['哥布']='哥布林大王:BAAAKgADCgEIAQAAAA==.',['唐纳']='唐纳德:BAAAKgAECgEIAQAAAA==.',['嗷嗷']='嗷嗷偷发糕:BAAAKgADCgIIAgAAAA==.',['噬灵']='噬灵天火:BAAAKgADCgUIBQAAAA==.',['嚀唲']='嚀唲寶寶:BAABKgAFFH8GAAIVAAYI/xOSEQBbAQAVAAYI/xOSEQBbAQAAAA==.',['图腾']='图腾医逝:BAACKgAFFH8OAAIXAAQIAiKDFwAkAQAXAAQIAiKDFwAkAQAqAAQKfxgAAxcACAhZGkswALgBABcACAhZGkswALgBABAAAgjZB2ZwAEQAAAAA.',['圣嘉']='圣嘉然之力:BAAAKgADCgEIAQAAAA==.',['地狱']='地狱邮差:BAABKgAFFH8KAAIYAAMIpwrNDACsAAAYAAMIpwrNDACsAAAAAA==.',['城北']='城北徐工:BAAAKgAECgQIBAAAAA==.',['夏花']='夏花糕点师:BAAAKgAECggIEAAAAA==.',['夜丶']='夜丶且听风吟:BAAAKgAFFAEIAQAAAA==.夜丶流星丨雨:BAAAKgAFFAEIAgAAAA==.',['夜勤']='夜勤张大夫:BAAAKgAECggIDAAAAA==.',['夜织']='夜织:BAABKgAFFH8HAAMNAAYIUx4KFwBLAQANAAQIFB4KFwBLAQAWAAIITx9sIwBTAAAAAA==.',['夜羽']='夜羽殇镜:BAAAKgAECgEIAQAAAA==.',['夜雨']='夜雨风歌:BAAAKgADCgMIBAAAAA==.',['大叔']='大叔玩治疗:BAAAKgAECgIIAgAAAA==.',['大橙']='大橙在德:BAAAKgAECgYIBgAAAA==.',['大聖']='大聖:BAAAKgAFFAYIBAAAAA==.',['天堂']='天堂有泪:BAAAKgADCgIIAgAAAA==.',['天幕']='天幕:BAAAKgAECgMIAwAAAA==.',['天涯']='天涯悠悠:BAAAKgADCggICAAAAA==.',['天空']='天空:BAABKgAECn8VAAIZAAgIJxTJFACjAQAZAAgIJxTJFACjAQAAAA==.',['天蓬']='天蓬元帅八戒:BAABKgAFFH8GAAIaAAIIGQBaNgAKAAAaAAIIGQBaNgAKAAAAAA==.',['天青']='天青的骑士:BAAAKgAECgUIDAAAAA==.',['太子']='太子敖广:BAAAKgAFFAIIAgAAAA==.',['夺命']='夺命三孃:BAAAKgAECgQIAQAAAA==.',['奇蒂']='奇蒂拉马哲理:BAABKgAFFH8FAAIbAAIITABBEQAVAAAbAAIITABBEQAVAAAAAA==.',['奇迹']='奇迹我信了:BAABKgAFFH8GAAIcAAYIaBu+AwC3AQAcAAYIaBu+AwC3AQAAAA==.',['奈奎']='奈奎思特:BAACKgAFFH8MAAIdAAQIuBUbEgC0AAAdAAQIuBUbEgC0AAAqAAQKfyUABB0ACAgVH48MAGwCAB0ACAgVH48MAGwCAB4ACAgyDo8tAEcBAB8AAwjgGCEeAOQAAAAA.',['奔跑']='奔跑的豆子:BAAAKgAECgYIBgAAAA==.',['奪命']='奪命三娘:BAAAKgAECgEIAQAAAA==.',['奶粉']='奶粉好贵吖:BAAAKgAFFAMIAwAAAA==.奶粉真贵吖:BAABKgAFFH8IAAIdAAgINQDLLgCKAAAdAAgINQDLLgCKAAAAAA==.',['妖妖']='妖妖烨:BAAAKgADCggICAAAAA==.',['姜无']='姜无涯:BAAAKgADCgEIAQAAAA==.',['娜个']='娜个傻馒:BAAAKgAECggICAAAAA==.',['娜美']='娜美尼娅:BAAAKgAFFAgIAQAAAA==.',['孙猴']='孙猴王悟空:BAAAKgAECgQIBwAAAA==.',['守夜']='守夜者雪诺:BAAAKgADCgMIAwAAAA==.',['安阿']='安阿苏:BAAAKgAECggICAAAAA==.',['安静']='安静潇雪:BAABKgAFFH8FAAMeAAUIHgosEwDFAAAeAAQIdAosEwDFAAAfAAEImxVGIQBYAAAAAA==.',['宋宗']='宋宗鸡:BAACKgAFFH8HAAIXAAMIHhFfGwCeAAAXAAMIHhFfGwCeAAAqAAQKfyQAAxAACAiRDZ4wAF4BABAACAiRDZ4wAF4BABcACAhnENQhACEBAAAA.',['宝石']='宝石的流霞:BAAAKgADCggICAAAAA==.',['寂寞']='寂寞之殇:BAAAKgAECggICAAAAA==.寂寞烟圈:BAABKgAFFH8MAAILAAQI9xEUFADoAAALAAQI9xEUFADoAAAAAA==.',['寂滅']='寂滅之刃:BAAAKgAFFAIIAgAAAA==.',['寧狐']='寧狐冲:BAAAKgADCggICAAAAA==.',['寺大']='寺大白:BAAAKgAFFAgIAQAAAA==.',['射太']='射太阳的人:BAABKgAFFH8IAAIFAAMI7hOIGgDDAAAFAAMI7hOIGgDDAAAAAA==.',['小七']='小七:BAABKgAFFH8GAAQfAAQIbxSUFgCvAAAfAAMIDxOUFgCvAAAeAAEI7CNJLQBhAAAdAAEIjBDoPQBDAAAAAA==.',['小囡']='小囡人:BAAAKgADCgcIBwAAAA==.',['小太']='小太保:BAAAKgADCggICAAAAA==.',['小妖']='小妖水瓶:BAAAKgAECgYIBgAAAA==.小妖氺瓶:BAAAKgADCgEIAQAAAA==.',['小小']='小小野晒:BAAAKgAECggICQAAAA==.',['尐丸']='尐丸籽酿酒:BAABKgAFFH8IAAIEAAgIAg5ZDwDnAQAEAAgIAg5ZDwDnAQAAAA==.',['山山']='山山木林:BAAAKgADCggICAAAAA==.',['左肩']='左肩天使:BAAAKgAECggICAAAAA==.',['巧克']='巧克力曲奇:BAAAKgADCgIIAgAAAA==.',['差一']='差一点点:BAABKgAFFH8JAAIXAAIIdxUjKwByAAAXAAIIdxUjKwByAAAAAA==.',['布加']='布加迪威龙:BAAAKgADCgYIBgAAAA==.',['布拉']='布拉德菲斯:BAABKgAFFH8IAAICAAgIDhqjAQB+AgACAAgIDhqjAQB+AgAAAA==.',['帅骑']='帅骑帅骑帅:BAABKgAECn8eAAILAAgILSN5OQDKAQALAAgILSN5OQDKAQAAAA==.',['干饭']='干饭:BAAAKgADCggICAAAAA==.',['幸福']='幸福病:BAAAKgAFFAMIAwAAAA==.',['库丘']='库丘林:BAAAKgAECggIDAAAAA==.',['开心']='开心锤锤:BAAAKgAECggIEQAAAA==.',['强壮']='强壮的大熊:BAAAKgAFFAQIBAAAAA==.',['影丨']='影丨帝:BAAAKgAECggICQAAAA==.',['德甲']='德甲天下:BAAAKgAECgUIBQAAAA==.',['快餐']='快餐上门一百:BAAAKgAECgYIBgAAAA==.快餐上门九百:BAAAKgAECgEIAQAAAA==.快餐上门二百:BAAAKgAECgEIAQAAAA==.快餐上门五百:BAAAKgADCggICAAAAA==.快餐上门六百:BAAAKgADCgYIBgAAAA==.',['怎么']='怎么会怎么会:BAAAKgADCggICAAAAA==.',['恋香']='恋香灬:BAAAKgAECgMIAwAAAA==.',['恶魔']='恶魔滴泪:BAAAKgAECgEIAQAAAA==.',['情由']='情由天定:BAAAKgAFFAQIBAAAAA==.',['惑德']='惑德:BAABKgAECn8gAAMTAAgI4BjkCAANAgATAAgI4BjkCAANAgAPAAcIWwk5fQDnAAAAAA==.',['愤怒']='愤怒的牛:BAAAKgADCggIDwAAAA==.',['慕蓝']='慕蓝:BAAAKgAECgEIAQAAAA==.',['懒得']='懒得理你:BAAAKgAFFAIIBAAAAA==.',['懒羊']='懒羊羊村长:BAAAKgADCgQIBAAAAA==.',['懵萌']='懵萌丶小内:BAAAKgAECgcICgAAAA==.',['我一']='我一个人:BAAAKgAECgEIAwAAAA==.',['我从']='我从后面来:BAABKgAFFH8JAAIMAAMIhQ0pMQC6AAAMAAMIhQ0pMQC6AAAAAA==.',['我会']='我会开无敌:BAAAKgADCgcIBwAAAA==.',['我是']='我是不好养的:BAAAKgAECgIIAgAAAA==.我是欧根亲王:BAAAKgAECgYIBgAAAA==.',['我若']='我若为王:BAAAKgAECggIEAAAAA==.',['战争']='战争狂人:BAACKgAFFH8lAAIDAAQIiRm7CwBVAQADAAQIiRm7CwBVAQAqAAQKfxUAAgMACAiSHAMfANoBAAMACAiSHAMfANoBAAAA.',['战兵']='战兵驿:BAAAKgAECgUIBQAAAA==.',['抵消']='抵消分录:BAAAKgAECgEIAQAAAA==.',['拉斯']='拉斯塔哈国王:BAAAKgADCgIIAgAAAA==.',['拿头']='拿头像:BAAAKgADCgUIBQAAAA==.',['挽弓']='挽弓射猪:BAAAKgADCgEIAQAAAA==.',['敏捷']='敏捷你不要吧:BAAAKgADCgMIAwAAAA==.',['敖蛟']='敖蛟:BAAAKgADCgIIAgAAAA==.',['斩你']='斩你狗头:BAAAKgAFFAQIBAAAAA==.',['斯维']='斯维恩:BAAAKgAECggICAAAAA==.',['方园']='方园:BAABKgAFFH8GAAMJAAMIZQhBGQCgAAAJAAMIZQhBGQCgAAAKAAMI2RA4EwCFAAABKgAFFAgIEAAgAHgfAA==.',['无光']='无光之盾:BAAAKgAECggICgAAAA==.',['无双']='无双千珏:BAAAKgAECgQIBgAAAA==.',['日么']='日么疼:BAAAKgADCggICQAAAA==.',['易世']='易世梵花:BAAAKgADCggICAAAAA==.',['星幻']='星幻粼:BAABKgAFFH8MAAMUAAYIcRRoDABvAQAUAAYIbhNoDABvAQAVAAYIKQ9DFABDAQAAAA==.',['星河']='星河不及你:BAAAKgAFFAEIAQAAAA==.',['星辰']='星辰朔影:BAAAKgAECgQIBAAAAA==.',['暗影']='暗影相随:BAABKgAECn9TAAQNAAgIKSLQBQCpAgANAAgIKSLQBQCpAgAWAAIIoh2aVACoAAARAAIINB0lKACkAAAAAA==.暗影相随毁:BAABKgAECn8pAAMNAAgI2R+ICQB1AgANAAgIJh+ICQB1AgAWAAEIhyFSawBjAAAAAA==.',['曦糯']='曦糯:BAAAKgAECgIIAgAAAA==.',['最萌']='最萌天然呆:BAAAKgAECgIIAgAAAA==.',['未央']='未央西瓜:BAAAKgAECggICAAAAA==.',['术我']='术我貌美:BAAAKgAECgUIBQAAAA==.',['朱敛']='朱敛:BAABKgAECn8hAAMDAAgIqBqSCwDqAQADAAgIqBqSCwDqAQACAAUIVAf4SACqAAAAAA==.',['朱雀']='朱雀纪貂蝉:BAAAKgAFFAQIBAAAAA==.',['李小']='李小毛:BAAAKgAFFAYIBAAAAA==.',['杨嘤']='杨嘤:BAAAKgAECgIIAgAAAA==.',['杯中']='杯中撒:BAAAKgAECggIDgAAAA==.',['格雷']='格雷麦恩:BAAAKgAECgUIBQAAAA==.',['桃白']='桃白白:BAAAKgADCgIIAgAAAA==.',['梅川']='梅川裤子:BAAAKgAFFAIIAgAAAA==.',['梦回']='梦回什么来着:BAAAKgAECgYIBwAAAA==.',['橡皮']='橡皮擦:BAACKgAFFH8GAAMVAAUIuR7cEQBYAQAVAAUIuR7cEQBYAQAUAAEIAAAsRAAAAAAqAAQKfxYAAxwACAiAJqQMAJ4CABwACAiAJqQMAJ4CABQAAgjaGpCEAHcAAAAA.',['残梦']='残梦慰清愁:BAACKgAFFH8KAAIEAAYIPQ1aLQAyAQAEAAYIPQ1aLQAyAQAqAAQKfxYAAgQACAhIFEF4AKYBAAQACAhIFEF4AKYBAAAA.',['殘念']='殘念:BAAAKgAECgcIDgAAAA==.',['毙肾']='毙肾客:BAAAKgAECgQIBAAAAA==.',['永恒']='永恒复仇的眼:BAAAKgAECggIDQAAAA==.',['沈慧']='沈慧:BAAAKgADCggICgAAAA==.',['没有']='没有云的雨:BAAAKgAECgMIAwAAAA==.',['沪小']='沪小白的拉拉:BAAAKgAECggICwAAAA==.',['泰瑞']='泰瑞尓:BAAAKgADCgcIBwAAAA==.',['浮生']='浮生千重变:BAAAKgADCgYIBgAAAA==.',['海月']='海月凝:BAAAKgADCgIIAgAAAA==.',['涅颜']='涅颜:BAABKgAFFH8JAAMhAAcICQ/DCQDRAAAGAAMIbRR1FwDrAAAhAAQIpQnDCQDRAAAAAA==.',['涵涵']='涵涵没烦恼:BAAAKgAFFAYIAwAAAA==.',['清风']='清风一号:BAAAKgAECggICAAAAA==.清风七号:BAAAKgAECgQIBAAAAA==.清风二号:BAAAKgAECgYIBgAAAA==.清风再起:BAAAKgAECgcICgAAAA==.',['湟源']='湟源老万:BAACKgAFFH8FAAIEAAMIjxMhWgC9AAAEAAMIjxMhWgC9AAAqAAQKfyAAAgQACAjSHkFHABoCAAQACAjSHkFHABoCAAAA.',['湮灭']='湮灭之暗:BAABKgAFFH8HAAILAAQILAgYGACmAAALAAQILAgYGACmAAAAAA==.',['漆黑']='漆黑你摩羯:BAABKgAFFH8HAAILAAcI4QgpCgCAAQALAAcI4QgpCgCAAQAAAA==.',['潘达']='潘达莉雅:BAAAKgAECgUIBQAAAA==.',['潴籽']='潴籽芃:BAAAKgAECgEIAQAAAA==.',['火红']='火红的搬运工:BAAAKgADCgMIAwAAAA==.',['灬今']='灬今晚打老虎:BAAAKgADCgUIBQAAAA==.',['灬土']='灬土肥圆:BAABKgAFFH8NAAMKAAYIVRUbDgBEAQAKAAYIVRUbDgBEAQAiAAMIqQUgCgBkAAAAAA==.',['灬夏']='灬夏末丶秋至:BAABKgAFFH8IAAIjAAgIMSD7AQCYAgAjAAgIMSD7AQCYAgAAAA==.',['灬小']='灬小保灬:BAAAKgAECgYIDQAAAA==.',['灬无']='灬无言修罗:BAABKgAFFH8IAAIaAAgInBGaAwDgAQAaAAgInBGaAwDgAQAAAA==.',['灬薇']='灬薇薇安娜露:BAAAKgAFFAIIAgAAAA==.',['灬露']='灬露宝牛牛:BAABKgAFFH8MAAQjAAYIFiAcBQAaAQAjAAYIORwcBQAaAQASAAUIvgLKEgCqAAAEAAEI6h1LgwBZAAAAAA==.',['灵魂']='灵魂猎手:BAAAKgADCgEIAQAAAA==.',['炫冰']='炫冰:BAACKgAFFH8GAAICAAMIuAV5DwCeAAACAAMIuAV5DwCeAAAqAAQKfxUAAwIACAi+EKkPAEEBAAIACAj4D6kPAEEBAAMABgjyDZNDAAkBAAAA.',['烙绅']='烙绅:BAACKgAFFH8fAAIXAAgIpiKyAgBBAgAXAAgIpiKyAgBBAgAqAAQKfxcAAhcACAgbHGUnAPABABcACAgbHGUnAPABAAAA.',['照桥']='照桥心美:BAAAKgAFFAQIBAAAAA==.',['熊猫']='熊猫灬阿宝:BAAAKgAECgQIBAAAAA==.',['爱在']='爱在枫最红时:BAAAKgADCggICwAAAA==.',['爱晚']='爱晚睡呦:BAAAKgAECggICAAAAA==.',['爱睡']='爱睡觉的考拉:BAAAKgAFFAQIBAABKgAFFAgIBAAkAAAAAA==.',['牛奶']='牛奶树:BAAAKgAECgcIBwAAAA==.',['牛德']='牛德不得鸟:BAAAKgADCggICAAAAA==.',['特猫']='特猫柔:BAACKgAFFH8QAAISAAMINh28CQAMAQASAAMINh28CQAMAQAqAAQKfyoAAhIACAjfH18IAGYCABIACAjfH18IAGYCAAAA.',['狂热']='狂热之锋:BAABKgAFFH8FAAIEAAUIzB88IgBkAQAEAAUIzB88IgBkAQAAAA==.',['猫和']='猫和老许:BAAAKgAECggIDgAAAA==.',['玫斯']='玫斯特拉:BAABKgAECn8WAAIXAAgISAuWXAAVAQAXAAgISAuWXAAVAQAAAA==.',['瑞丝']='瑞丝奎拉希雅:BAAAKgADCgYIBgAAAA==.',['瓦尔']='瓦尔基拉:BAAAKgADCggICgAAAA==.',['甜心']='甜心灬妖妖:BAABKgAFFH8KAAMlAAYIuALWCwAOAQAlAAYIuALWCwAOAQAXAAQIlQevOgCaAAABKgAFFAgICgAEAG0lAA==.',['生命']='生命的治疗:BAAAKgAFFAYIAgAAAA==.生命的猎手:BAAAKgAFFAYIBAABKgAFFAgICAAaAL0eAA==.',['留在']='留在我身边:BAAAKgADCgMIAwAAAA==.',['疏影']='疏影织晚意:BAABKgAFFH8MAAINAAYIjRcUGABDAQANAAYIjRcUGABDAQAAAA==.',['疯了']='疯了般想你:BAAAKgAFFAIIAgAAAA==.',['瘦了']='瘦了吧唧:BAAAKgADCgEIAQAAAA==.',['白虎']='白虎超人:BAAAKgAECggICQAAAA==.',['看你']='看你的脚下:BAACKgAFFH8IAAIEAAYIzg9/KgA9AQAEAAYIzg9/KgA9AQAqAAQKfxgAAgQACAjzInoUAMUCAAQACAjzInoUAMUCAAAA.',['破晓']='破晓晨星:BAABKgAFFH8FAAIjAAUIZgPZHwB+AAAjAAUIZgPZHwB+AAAAAA==.',['祝小']='祝小兔:BAAAKgAECgYIBgAAAA==.',['神之']='神之一手:BAAAKgAFFAMIAwAAAA==.',['神话']='神话星空:BAABKgAFFH8IAAIEAAgIlAPYEgBxAQAEAAgIlAPYEgBxAQAAAA==.',['空庭']='空庭春欲晚:BAABKgAFFH8KAAIKAAYInwfHEwAJAQAKAAYInwfHEwAJAQAAAA==.',['空心']='空心禅:BAABKgAFFH8KAAMcAAQIkA4TDQC3AAAVAAQI1g2EGAC5AAAcAAMILAoTDQC3AAAAAA==.',['等待']='等待你降临:BAABKgAFFH8IAAIaAAgIxAp8BQB9AQAaAAgIxAp8BQB9AQAAAA==.',['筱爱']='筱爱骑:BAAAKgAECgcIDgAAAA==.',['米老']='米老哥:BAABKgAFFH8PAAMdAAYIBBi8DABYAQAdAAYI8xe8DABYAQAeAAUISQ5DFQDrAAAAAA==.',['精工']='精工炒:BAAAKgAFFAQIBAAAAA==.',['精灵']='精灵琰:BAAAKgADCgcIBwAAAA==.',['紅隆']='紅隆隆:BAAAKgAFFAgIBAAAAA==.',['紫凝']='紫凝:BAAAKgADCggICAAAAA==.',['红杏']='红杏:BAAAKgAECgUIBQAAAA==.',['给了']='给了你得瑟丶:BAAAKgAECgcICAAAAA==.',['维里']='维里安:BAAAKgADCggICAAAAA==.',['绿林']='绿林小妖:BAAAKgAECgUIBQAAAA==.',['罒厶']='罒厶罒:BAAAKgADCgUIBwAAAA==.',['罗拉']='罗拉娜米莎凯:BAAAKgAFFAIIAgAAAA==.',['罗莎']='罗莎琳德:BAAAKgAECggIEAAAAA==.',['美到']='美到抠脚:BAAAKgAFFAQIBAAAAA==.',['翌日']='翌日不当差:BAAAKgAECggIBgAAAA==.',['翠翠']='翠翠唯一男友:BAAAKgAECgEIAQAAAA==.',['耀骑']='耀骑士临光:BAAAKgAECggIDwAAAA==.',['老衲']='老衲乄北境狼:BAAAKgADCggICAAAAA==.老衲乄南域虎:BAAAKgADCggICAAAAA==.',['老陌']='老陌:BAAAKgAECggICAAAAA==.',['聆聽']='聆聽者丨風玲:BAAAKgAECggIEwAAAA==.',['肉肉']='肉肉壮熊:BAAAKgAECgIIAgAAAA==.',['肥肠']='肥肠道人:BAAAKgAECgYIEAAAAA==.',['胖灬']='胖灬肚:BAAAKgADCgMIAwAAAA==.',['胤祥']='胤祥:BAABKgAECn8XAAILAAgIyhKcDQCjAQALAAgIyhKcDQCjAQAAAA==.',['脸接']='脸接怪被锤飞:BAABKgAFFH8JAAIjAAYIuxc5AgByAQAjAAYIuxc5AgByAQAAAA==.',['腐烂']='腐烂的骨头:BAAAKgADCgIIAgAAAA==.',['自然']='自然沉睡:BAABKgAECn8bAAIbAAgImxi6DgC7AQAbAAgImxi6DgC7AQAAAA==.',['舍命']='舍命暗夜:BAAAKgAECgIIAgAAAA==.',['色格']='色格得蛮:BAABKgAECn8bAAIFAAYI5ArMiQC/AAAFAAYI5ArMiQC/AAAAAA==.',['艾露']='艾露蒽女祭司:BAAAKgAECgIIAgAAAA==.',['芋泥']='芋泥啵啵:BAABKgAFFH8GAAIdAAMI/RAjFACeAAAdAAMI/RAjFACeAAAAAA==.',['芙兰']='芙兰朵露:BAAAKgADCgcIBwAAAA==.',['芙闌']='芙闌朵露:BAAAKgAECggICgAAAA==.',['芦苇']='芦苇笑倾城:BAAAKgAECgUIBQAAAA==.',['莴苣']='莴苣女士:BAAAKgAECgQIBAAAAA==.',['萌兽']='萌兽饲养员:BAABKgAFFH8HAAIIAAIIhg57QgByAAAIAAIIhg57QgByAAAAAA==.',['落花']='落花煮酒:BAAAKgAECgMIAwAAAA==.',['薄樱']='薄樱:BAAAKgAFFAEIAQAAAA==.',['蚑蚑']='蚑蚑:BAABKgAFFH8QAAMgAAgIeB/6AAD5AQAgAAcIXB/6AAD5AQAOAAUIMhLDGAD+AAAAAA==.',['蚩尤']='蚩尤大帝:BAAAKgAECggICAAAAA==.',['蜀道']='蜀道山:BAAAKgADCgMIAwAAAA==.',['血玫']='血玫:BAAAKgADCggICAAAAA==.',['血色']='血色洗礼:BAACKgAFFH8wAAMUAAgIWRUlBgAIAgAUAAgIWRUlBgAIAgAcAAEIxAlJJAAxAAAqAAQKfyoAAxQACAiLHPQiACMCABQACAiLHPQiACMCABwABwgJESpOACwBAAAA.',['西塞']='西塞山野翔:BAAAKgADCgEIAQAAAA==.',['西尔']='西尔唯娅:BAAAKgADCggIEAAAAA==.',['西猫']='西猫:BAAAKgAFFAIIAgAAAA==.',['诺兰']='诺兰:BAAAKgADCggIDQAAAA==.',['豆米']='豆米快跑:BAABKgAFFH8JAAIEAAcIXB4QCgAiAgAEAAcIXB4QCgAiAgAAAA==.',['貓狗']='貓狗雙全:BAAAKgAFFAYIAgAAAA==.',['贫尼']='贫尼名叫乱来:BAAAKgAECgcIBwAAAA==.',['贱贱']='贱贱:BAABKgAFFH8GAAMdAAYICA1PGgDnAAAdAAUIeA1PGgDnAAAfAAEIJweLLQA/AAAAAA==.',['赫月']='赫月:BAAAKgAECggIEwAAAA==.',['路虎']='路虎将:BAAAKgADCggICAAAAA==.',['跳即']='跳即死:BAAAKgADCggICAAAAA==.',['辛程']='辛程:BAAAKgADCggICgAAAA==.',['逍遥']='逍遥法灵:BAAAKgAECggIEgAAAA==.',['遇求']='遇求得道:BAAAKgADCggICAAAAA==.',['部落']='部落丶话事人:BAABKgAECn8hAAIEAAgIqSDcJABtAgAEAAgIqSDcJABtAgAAAA==.',['钱德']='钱德:BAAAKgADCgMIAwAAAA==.',['铁锅']='铁锅炖盒饭:BAAAKgADCggICAAAAA==.',['银月']='银月之星:BAAAKgAECggIDwAAAA==.',['长卿']='长卿:BAAAKgAECgEIAQAAAA==.',['长大']='长大了不好:BAAAKgAFFAMIAwAAAA==.',['长期']='长期素食:BAAAKgAECgYIEAAAAA==.',['闭店']='闭店酒馆:BAAAKgAECgYICgAAAA==.',['阔到']='阔到霹雳面:BAAAKgAECgYIBgAAAA==.',['阿祖']='阿祖没时间:BAAAKgAFFAgIBAAAAA==.',['雷斯']='雷斯琳马哲理:BAAAKgAFFAIIBAAAAA==.',['雷米']='雷米莉亚:BAACKgAFFH8KAAIMAAMItAfmNgClAAAMAAMItAfmNgClAAAqAAQKfxQAAwwACAi0Esw9AFkBAAwACAi0Esw9AFkBACYAAQgAAKh7AAAAAAAA.',['霊儿']='霊儿曦諾:BAAAKgAECgYICAABKgAECggIEAAkAAAAAA==.',['霏雨']='霏雨:BAAAKgAECgEIAQAAAA==.',['霓葳']='霓葳蕤:BAABKgAFFH8GAAMHAAQIhQq4JgCLAAAHAAQIhQq4JgCLAAAPAAII1ArsUABzAAAAAA==.',['霜飔']='霜飔窈:BAABKgAFFH8GAAIMAAYIiQySFgBGAQAMAAYIiQySFgBGAQAAAA==.',['霪荡']='霪荡瓦里奥:BAAAKgAECgEIAQAAAA==.',['露宝']='露宝之恶猎:BAABKgAFFH8GAAImAAYIFAVPCQC3AAAmAAYIFAVPCQC3AAAAAA==.',['霸天']='霸天虎丶:BAAAKgAECgcICwAAAA==.',['霸气']='霸气角斗士:BAABKgAFFH8UAAMIAAQIrhmFJADbAAAIAAMIOxmFJADbAAAFAAQIxQviQgCUAAAAAA==.',['響今']='響今:BAAAKgAECggICQAAAA==.',['顽强']='顽强小猪:BAABKgAFFH8PAAIEAAMIUhtrSADdAAAEAAMIUhtrSADdAAAAAA==.',['风残']='风残光度:BAAAKgAECgcICwAAAA==.',['飘摇']='飘摇的风筝:BAAAKgADCggICAAAAA==.',['饭粒']='饭粒粒:BAABKgAFFH8JAAISAAMIgxXLDgDMAAASAAMIgxXLDgDMAAAAAA==.',['饱以']='饱以喵拳:BAACKgAFFH8FAAIKAAMI/hBoDwDrAAAKAAMI/hBoDwDrAAAqAAQKfyYAAgoACAgKG3YWADQCAAoACAgKG3YWADQCAAEqAAUUAwgQABIANh0A.',['马油']='马油:BAABKgAECn8eAAIEAAgIeBqEGQD3AQAEAAgIeBqEGQD3AQAAAA==.',['魑魅']='魑魅魍魉魍魉:BAAAKgAECggIEQAAAA==.',['魔女']='魔女琪莉:BAAAKgAECgQIBAAAAA==.',['鸡毛']='鸡毛灬劣人:BAAAKgADCggIDAAAAA==.',['鸡蛋']='鸡蛋饼:BAABKgAFFH8GAAIEAAYIFBLhHgB2AQAEAAYIFBLhHgB2AQAAAA==.',['黄少']='黄少天:BAAAKgADCgIIAgAAAA==.黄少天丶:BAABKgAFFH8GAAIEAAIImg5WdwB7AAAEAAIImg5WdwB7AAAAAA==.',['黄昏']='黄昏现白骨:BAAAKgAECgYICQAAAA==.',['黑翼']='黑翼炽天使:BAAAKgADCggICAAAAA==.',['黑色']='黑色的雪:BAAAKgADCgYIBgABKgAFFAgIEAAlAMcjAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end