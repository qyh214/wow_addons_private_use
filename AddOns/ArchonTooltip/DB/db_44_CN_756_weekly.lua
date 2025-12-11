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
 local lookup = {'DemonHunter-Vengeance','DemonHunter-Havoc','Shaman-Restoration','DeathKnight-Frost','DeathKnight-Unholy','Mage-Arcane','Hunter-BeastMastery','Shaman-Elemental','Druid-Restoration','Druid-Guardian','Paladin-Retribution','Warrior-Fury','Hunter-Marksmanship','Warlock-Destruction','Druid-Balance','Unknown-Unknown','Warlock-Demonology','DeathKnight-Blood','Evoker-Preservation','Warrior-Protection','Druid-Feral','Priest-Holy','Paladin-Holy','Paladin-Protection','Monk-Brewmaster','Hunter-Survival','Mage-Frost','Warlock-Affliction',}; local provider = {region='CN',realm='玛多兰',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aa='Aaiai:BAAALAAECgQIBAAAAA==.',Al='Albus:BAAALAAECgEIAQAAAA==.Alexchow:BAABLAAECn8sAAMBAAgIGhdQCgC2AQACAAcIixeRawDwAQABAAgIERVQCgC2AQAAAA==.',Am='Amoi:BAAALAAECgMIBAAAAA==.',Ar='Arale:BAAALAAFFAIIAwAAAA==.',As='Asuna:BAAALAAECgYIBgAAAA==.',Au='August:BAAALAAECgUICQAAAA==.',Ba='Bansheeoi:BAACLAAFFH8vAAICAAcIdCLyBwAeAgACAAcIdCLyBwAeAgAsAAQKfy0AAgIACAi8JTMKAE4DAAIACAi8JTMKAE4DAAAA.Bansheeoo:BAAALAAECgIIAgAAAA==.',Bi='Bigpanda:BAAALAAECgEIAQAAAA==.Bigsmock:BAAALAAECgEIAQAAAA==.',Ch='Chatty:BAAALAAFFAIIBAAAAA==.',Cx='Cx:BAACLAAFFH8PAAIDAAQIFhRILgD5AAADAAQIFhRILgD5AAAsAAQKf2QAAgMACAitIuEFAPoCAAMACAitIuEFAPoCAAAA.',Do='Doublefly:BAAALAAECgYICQAAAA==.',Dw='Dwinchester:BAABLAAFFH8tAAICAAYI9yNmCwDsAQACAAYI9yNmCwDsAQAAAA==.',Er='Erico:BAAALAAECgQIBAAAAA==.Erisapfel:BAAALAAECggIEAAAAA==.',Fu='Fusing:BAACLAAFFH8WAAIEAAgInh0kCAB2AgAEAAgInh0kCAB2AgAsAAQKfxkAAwQABgjUIwFJAGkCAAQABgjUIwFJAGkCAAUAAwhtIZ08APUAAAAA.',Gu='Guldandie:BAAALAADCgYIBgAAAA==.',Ha='Harlots:BAAALAAECggIEAAAAA==.',He='Hebe:BAABLAAFFH8HAAIGAAcIYhIHEQDxAQAGAAcIYhIHEQDxAQAAAA==.',Kk='Kkabcdefghi:BAABLAAECn8UAAIHAAYI6g3VuAD4AAAHAAYI6g3VuAD4AAAAAA==.',Mf='Mfyf:BAAALAADCgcIBwAAAA==.',Mi='Mib:BAAALAADCgQIBAAAAA==.',Ph='Phenexooe:BAAALAAFFAIIAgAAAA==.',Re='Readtea:BAAALAAFFAIIAgAAAA==.',Rp='Rpman:BAABLAAFFH8FAAIDAAMI8xQBQQCAAAADAAMI8xQBQQCAAAAAAA==.',Se='Sevenmangos:BAACLAAFFH8tAAIDAAYImyF8CAA8AgADAAYImyF8CAA8AgAsAAQKfyUAAwMACAhXH+4kAH4CAAMACAhXH+4kAH4CAAgABghAFNY1ADgBAAAA.',Si='Silverman:BAAALAAECgEIAQAAAA==.',Ve='Verlassen:BAAALAAECgYICgAAAA==.',Vo='Volaliy:BAAALAADCggICAAAAA==.Voldemoet:BAAALAADCgcIBwAAAA==.',Vr='Vrose:BAABLAAECn8fAAMJAAcIOhZpYAByAQAJAAYI2xRpYAByAQAKAAcIqxT1DQBWAQAAAA==.',Wa='Warlocksoul:BAAALAAECgMIAwAAAA==.',Wu='Wuho:BAAALAAFFAIIAgAAAA==.',Xi='Xiaofo:BAAALAADCgYIBgAAAA==.',Ya='Yagamiovo:BAABLAAFFH8GAAILAAQIaQgVOgCxAAALAAQIaQgVOgCxAAAAAA==.Yaho:BAAALAAFFAIIAgAAAA==.',Yo='Yoho:BAAALAAECgYIBgAAAA==.',['一夙']='一夙愿一:BAAALAAECgYICwAAAA==.',['一箭']='一箭红:BAABLAAFFH8JAAIHAAYIcySeDgAUAgAHAAYIcySeDgAUAgAAAA==.',['一般']='一般扭曲:BAABLAAFFH8GAAIDAAIIHBFdVwBsAAADAAIIHBFdVwBsAAAAAA==.',['一键']='一键血怒:BAAALAAECgYIBgAAAA==.一键辅助:BAABLAAFFH8VAAIDAAYIrCKwCgAhAgADAAYIrCKwCgAhAgABLAAFFAcIKAAGAAIgAA==.',['三五']='三五久久:BAAALAAFFAIIBAAAAA==.三五尊者:BAABLAAECn8jAAILAAcIrR/WHAAtAgALAAcIrR/WHAAtAgAAAA==.三五王牌:BAACLAAFFH8MAAIMAAQIpxGwLwDTAAAMAAQIpxGwLwDTAAAsAAQKfx4AAgwACAhjHAkaABQCAAwACAhjHAkaABQCAAAA.',['不只']='不只是玩玩:BAAALAADCgEIAQAAAA==.',['不洁']='不洁的凡塔:BAABLAAFFH8JAAIEAAIIIghQmgA5AAAEAAIIIghQmgA5AAAAAA==.',['不钲']='不钲之固:BAAALAAFFAIIAgAAAA==.',['丘八']='丘八比目泪牛:BAAALAAFFAIIAgAAAA==.',['中美']='中美:BAACLAAFFH8PAAINAAYIVxO2BgBjAQANAAYIVxO2BgBjAQAsAAQKfxcAAg0ABwgMHGUsABkCAA0ABwgMHGUsABkCAAAA.',['丰川']='丰川祥子:BAAALAADCgYIBgAAAA==.',['丶水']='丶水墨:BAAALAAECgYIDAAAAA==.',['丶霜']='丶霜语:BAAALAAECgYIBgAAAA==.',['为了']='为了希女王:BAAALAAECgEIAQAAAA==.为了部落:BAAALAAECgYICgAAAA==.',['为爱']='为爱嗜魔:BAAALAADCgYIBgAAAA==.',['久久']='久久哥:BAACLAAFFH8QAAIHAAUIHQ/ZUwD/AAAHAAUIHQ/ZUwD/AAAsAAQKfx8AAgcACAjsHBtQAD4CAAcACAjsHBtQAD4CAAAA.',['久龙']='久龙:BAAALAAECgYICAAAAA==.',['乌爾']='乌爾奇奥拉:BAAALAADCgQIBwAAAA==.',['乔婉']='乔婉:BAAALAAECgYIBgAAAA==.',['乖乖']='乖乖德:BAAALAAECgYIBgAAAA==.乖乖猎手:BAAALAAECgYIDgAAAA==.',['九月']='九月猪猪:BAAALAAECgYIDAAAAA==.',['九条']='九条:BAAALAADCgYIBgAAAA==.',['云梦']='云梦泽:BAAALAAECgYIEgAAAA==.',['亚瑟']='亚瑟亡:BAAALAAFFAMIAwAAAA==.',['仙蒂']='仙蒂火炉:BAAALAAECgYICAAAAA==.',['伊利']='伊利大蛋蛋:BAAALAAECgYIEQAAAA==.',['伊吾']='伊吾安苑:BAAALAAFFAIIAgAAAA==.',['伊莉']='伊莉雅丝菲尔:BAAALAAFFAIIAwAAAA==.',['传说']='传说中的花菜:BAAALAAFFAMIAwAAAA==.',['你充']='你充扣币吗:BAAALAAECgQIBQAAAA==.',['佩奇']='佩奇吃饱了:BAAALAAFFAIIAgAAAA==.',['信仰']='信仰圣光吧:BAAALAAFFAIIBAAAAA==.',['俺是']='俺是不:BAAALAAECgEIAQAAAA==.俺是吗:BAAALAAFFAIIAgAAAA==.',['元素']='元素丶大帝:BAAALAAECgUIBQAAAA==.',['兰色']='兰色忧郁:BAACLAAFFH8IAAIMAAYIsQaXJwAzAQAMAAYIsQaXJwAzAQAsAAQKfyQAAgwABwhfEz8/AF4BAAwABwhfEz8/AF4BAAAA.',['冥月']='冥月:BAAALAAECgQIBAAAAA==.',['冬山']='冬山如睡:BAAALAAECggICQAAAA==.',['凯帕']='凯帕:BAAALAAECgcIBwAAAA==.',['刘庸']='刘庸:BAAALAAECgYIBgAAAA==.',['剑心']='剑心丶:BAAALAAECgMIAwAAAA==.',['劣人']='劣人美屡:BAAALAAFFAQIBAAAAA==.',['劳资']='劳资杀猪的:BAAALAADCgYIBgAAAA==.',['勋芳']='勋芳:BAAALAADCggICwAAAA==.',['化骨']='化骨龙:BAAALAAECgYIEgABLAAECgYIGAAGANwVAA==.',['十字']='十字星星:BAAALAADCgIIAgAAAA==.',['十无']='十无畏十:BAAALAAECgcIEAAAAA==.',['午后']='午后河流:BAAALAAECgYIDQABLAAFFAYIGgAOANMUAA==.',['单手']='单手扶墙:BAAALAADCgEIAQAAAA==.单手扶墙灬:BAAALAAECgYIBgAAAA==.',['卖碳']='卖碳翁:BAACLAAFFH8gAAIPAAYIiyCSCADbAQAPAAYIiyCSCADbAQAsAAQKfzQAAg8ACAihJBcDAOcCAA8ACAihJBcDAOcCAAAA.',['卖糖']='卖糖术神:BAACLAAFFH8JAAIOAAMI9iMILQDRAAAOAAMI9iMILQDRAAAsAAQKfxQAAg4ACAgtIxwPAHMCAA4ACAgtIxwPAHMCAAEsAAUUBwgoAAYAAiAA.',['卖酱']='卖酱油的:BAAALAAECgYICAAAAA==.',['印心']='印心:BAAALAAECgYIBgAAAA==.',['去年']='去年的红叶:BAAALAAECgUIBQAAAA==.',['又大']='又大又白:BAAALAAECgYIDQABLAAECggICwAQAAAAAA==.',['取暖']='取暖的猫:BAABLAAECn8VAAIHAAYIkx8dlAC+AQAHAAYIkx8dlAC+AQABLAAFFAYIGgAOANMUAA==.',['口味']='口味王:BAABLAAFFH8KAAMDAAQI5QxXSQCLAAADAAMIEw5XSQCLAAAIAAMISAXgOQBuAAAAAA==.',['古谚']='古谚久:BAAALAAFFAIIAgAAAA==.',['叫我']='叫我大坏蛋:BAAALAAECgUIBQAAAA==.',['可乐']='可乐飞冰:BAAALAADCgEIAQAAAA==.',['吉利']='吉利的小乌鸦:BAAALAAFFAEIAQAAAA==.',['吉安']='吉安那那:BAABLAAFFH8NAAIEAAMIRh0TRgCqAAAEAAMIRh0TRgCqAAAAAA==.',['吕布']='吕布曰貂蝉丶:BAAALAAECgYIBgAAAA==.',['吾斯']='吾斯哈子:BAABLAAFFH8HAAIBAAIIngjJFgBaAAABAAIIngjJFgBaAAAAAA==.',['吾道']='吾道不孤:BAAALAAFFAIIAgAAAA==.',['命运']='命运决定人:BAAALAAFFAIIBAAAAA==.',['咔咔']='咔咔一顿:BAAALAAFFAEIAQAAAA==.',['哈湫']='哈湫湫:BAAALAAECgYIBgAAAA==.',['啊多']='啊多给:BAAALAAECgMIAwAAAA==.',['喔哦']='喔哦喔哦耶咦:BAAALAAECgYICgAAAA==.',['喔喔']='喔喔:BAAALAAECgYIBgAAAA==.喔喔丶:BAAALAAECgYIBwAAAA==.喔喔丶奶糖:BAAALAAECgYIBgAAAA==.喔喔彡奶糖:BAAALAAECgQIBgAAAA==.',['喵喵']='喵喵猪:BAAALAAECgMIAwAAAA==.',['嘻嘻']='嘻嘻哈哈丶:BAAALAAECgEIAQAAAA==.',['四大']='四大名柱:BAACLAAFFH8OAAMDAAII8SFMIgDFAAADAAII8SFMIgDFAAAIAAIInR73JACdAAAsAAQKfx0AAwMABwh5IoUaAB8CAAMABwh5IoUaAB8CAAgABQgdHH8+ABMBAAAA.',['国服']='国服司空震:BAAALAAECgYIBgAAAA==.',['土猎']='土猎:BAAALAAECgEIAQAAAA==.',['塞纳']='塞纳柳丝:BAAALAAECgUIBQAAAA==.',['夏末']='夏末丶将至:BAABLAAFFH8GAAILAAIInRpCOACkAAALAAIInRpCOACkAAABLAAFFAgIBAAQAAAAAA==.',['夕阳']='夕阳:BAAALAAFFAIIAgAAAA==.',['夜光']='夜光丶:BAACLAAFFH8GAAIHAAII2Rf2SwCZAAAHAAII2Rf2SwCZAAAsAAQKfxYAAgcABgi1G+ujAKYBAAcABgi1G+ujAKYBAAAA.',['夜的']='夜的第柒章:BAACLAAFFH8RAAMRAAUIVAzACQCFAAAOAAUINwv+PgD/AAARAAMIbBHACQCFAAAsAAQKfxsAAw4ABghXItgdAPYBAA4ABghXItgdAPYBABEAAwjpFM5qAMsAAAAA.',['大卫']='大卫高栢飞:BAABLAAECn8dAAMRAAYINA1IGwD7AAAOAAYIeQlbpwAsAQARAAYI3AxIGwD7AAAAAA==.',['大罗']='大罗法咒:BAABLAAECn8YAAIGAAYI3BUVLQBkAQAGAAYI3BUVLQBkAQAAAA==.',['天地']='天地非人间:BAAALAAECgYICQAAAA==.',['奈厄']='奈厄:BAABLAAECn8XAAICAAYIzhuwdADcAQACAAYIzhuwdADcAQAAAA==.',['奈幽']='奈幽:BAAALAAECgYIBwAAAA==.',['奈阿']='奈阿:BAAALAAECgYIBgAAAA==.',['如果']='如果是龙也好:BAAALAAFFAYIBAAAAA==.',['孤星']='孤星不语:BAABLAAFFH8FAAISAAMIeQtjFQBtAAASAAMIeQtjFQBtAAAAAA==.',['宝宝']='宝宝巴士丶:BAAALAADCgcIBwAAAA==.',['寒星']='寒星如翎:BAAALAAFFAIIAgAAAA==.',['小北']='小北灬:BAAALAADCggICAAAAA==.',['小小']='小小无双:BAAALAAECgYIBwAAAA==.',['小我']='小我:BAABLAAFFH8YAAIIAAgIiyGbAwCtAgAIAAgIiyGbAwCtAgAAAA==.',['小新']='小新青涩:BAAALAAECgYIBgAAAA==.',['小桂']='小桂头:BAAALAAECgYIBgAAAA==.',['小毛']='小毛笔:BAACLAAFFH8iAAILAAYIByDJDADdAQALAAYIByDJDADdAQAsAAQKfzoAAgsACAgNJZUFAPECAAsACAgNJZUFAPECAAAA.',['小炜']='小炜炜:BAAALAAECgMIAwAAAA==.',['小米']='小米粥雄起:BAAALAAECgYICwAAAA==.小米粥麻麻:BAAALAAECgYIBgAAAA==.',['小翎']='小翎儿:BAAALAAECgYIDQAAAA==.',['小飞']='小飞:BAAALAADCgQIBAAAAA==.',['小鱼']='小鱼哥啊:BAAALAAFFAIIAgAAAA==.小鱼哥戦士:BAAALAAECgQIBAAAAA==.小鱼哥骑士:BAAALAAFFAIIAgAAAA==.小鱼謌:BAABLAAFFH8GAAIEAAQIEAk+lAA8AAAEAAQIEAk+lAA8AAAAAA==.',['巴尔']='巴尔德尔:BAAALAADCgEIAQAAAA==.',['布耶']='布耶尔:BAABLAAFFH8IAAITAAIICA2LGgBqAAATAAIICA2LGgBqAAAAAA==.',['帅的']='帅的那么过分:BAAALAAECggICAAAAA==.',['帝么']='帝么航投:BAAALAAECgEIAQAAAA==.',['幻灭']='幻灭彩蝶:BAABLAAFFH8NAAMJAAYISBcMIAAgAQAJAAQI2xYMIAAgAQAPAAUIjwx9HADtAAAAAA==.',['库小']='库小供:BAABLAAFFH8IAAMUAAIIIR5eJQBTAAAMAAIIiBU2PwCOAAAUAAIIIR5eJQBTAAABLAAFFAgIEQAOAJYaAA==.',['德艺']='德艺双馨:BAAALAAECgYICgAAAA==.',['心甘']='心甘情愿:BAABLAAFFH8GAAIUAAIIXQtuJQBzAAAUAAIIXQtuJQBzAAAAAA==.',['恶魔']='恶魔少女:BAAALAADCgMIAwAAAA==.',['惊艳']='惊艳之猎:BAACLAAFFH8KAAMHAAIIKggNdAB7AAAHAAII0gcNdAB7AAANAAEIdQfRNwA3AAAsAAQKfxQAAgcABwjvGASLAMwBAAcABwjvGASLAMwBAAAA.惊艳如初:BAABLAAFFH8MAAILAAIIsRb+TgCTAAALAAIIsRb+TgCTAAAAAA==.',['我有']='我有筋斗云:BAAALAAECgYICQAAAA==.',['我来']='我来自地狱:BAAALAAFFAIIAgAAAA==.',['我爱']='我爱一根柴柴:BAAALAAECgIIAgAAAA==.',['我的']='我的宠物呢:BAAALAAECgMIAwAAAA==.我的猫很粘人:BAACLAAFFH8RAAMPAAMIRR4XGACjAAAPAAIIiB0XGACjAAAJAAMIVQVJJACWAAAsAAQKfx0AAg8ABghAJMoQAPwBAA8ABghAJMoQAPwBAAEsAAUUBggEABAAAAAA.',['手刃']='手刃法士:BAAALAADCgMIAwAAAA==.',['扭曲']='扭曲的法琳娜:BAABLAAFFH8GAAIOAAIIWg+1XQBBAAAOAAIIWg+1XQBBAAAAAA==.',['抽丫']='抽丫一嘴巴:BAAALAADCgEIAQAAAA==.',['拾柒']='拾柒笔畫:BAAALAAECgEIAQAAAA==.',['撒拉']='撒拉嘿呦:BAABLAAFFH8RAAIMAAUI9RetIQBfAQAMAAUI9RetIQBfAQAAAA==.',['放逐']='放逐者光影:BAAALAADCgQIBAAAAA==.放逐者无明:BAAALAAECgIIAgAAAA==.',['文豪']='文豪野犬:BAAALAAECgYIBgAAAA==.',['无光']='无光月:BAAALAADCgEIAQAAAA==.',['无小']='无小小:BAAALAAECgcIDwAAAA==.',['昔我']='昔我往矣:BAAALAAFFAIIAwAAAA==.',['星玲']='星玲珑:BAACLAAFFH8KAAQJAAQI4hFsJQCSAAAJAAQI4hFsJQCSAAAPAAEIigndLQBDAAAVAAII9wotEAA4AAAsAAQKfy4AAwkACAhyGmYyABcCAAkACAhyGmYyABcCAA8ABwgWGEE9AMABAAAA.',['星街']='星街彗星:BAAALAAECgMIAwAAAA==.',['是俺']='是俺不:BAAALAAFFAIIAgABLAAFFAIIAgAQAAAAAA==.',['晓星']='晓星尘:BAAALAAFFAIIAgAAAA==.',['晨丶']='晨丶曦:BAAALAAFFAIIAgAAAA==.',['晴天']='晴天雨:BAAALAAECgQIBAAAAA==.',['暗暗']='暗暗骑士:BAAALAADCgEIAQAAAA==.',['暮雨']='暮雨先生:BAAALAAECgYIBgAAAA==.',['曦丶']='曦丶公主殿下:BAAALAAECgYICAAAAA==.曦丶吹吹水:BAACLAAFFH8IAAIOAAMI9wbQUgBoAAAOAAMI9wbQUgBoAAAsAAQKfzgAAg4ACAj+FMgqAKgBAA4ACAj+FMgqAKgBAAAA.曦丶晚秋月明:BAABLAAECn8gAAIWAAcIsw82KwBeAQAWAAcIsw82KwBeAQAAAA==.曦丶梦兮:BAABLAAECn8qAAIHAAcIRRKedgBYAQAHAAcIRRKedgBYAQAAAA==.曦丶火柴蝴蝶:BAABLAAECn8UAAMSAAcIbQ6NGQD/AAAEAAcI2warcwAHAQASAAYIZQ+NGQD/AAAAAA==.曦丶蜜雪儿:BAAALAAECgYIEQAAAA==.',['曲终']='曲终人散:BAAALAAECgYIDAAAAA==.',['月下']='月下无霜:BAABLAAFFH8GAAIWAAIIfhCWMACOAAAWAAIIfhCWMACOAAAAAA==.',['月影']='月影之神:BAAALAADCgMIAwAAAA==.',['木易']='木易石:BAAALAADCgYIBgAAAA==.',['木木']='木木:BAAALAADCgMIAwAAAA==.',['板栗']='板栗盾击:BAABLAAECn8bAAILAAYIWyCJOAC0AQALAAYIWyCJOAC0AQAAAA==.',['林沫']='林沫汐:BAACLAAFFH8NAAIMAAMIKBGSKACoAAAMAAMIKBGSKACoAAAsAAQKfxQAAgwABgi7Hi9KABICAAwABgi7Hi9KABICAAAA.',['枫霜']='枫霜:BAAALAADCgcIBwAAAA==.',['柯里']='柯里尔影斧:BAAALAADCgIIAgAAAA==.',['柰阿']='柰阿:BAAALAAECgQIBAAAAA==.',['栗山']='栗山酱未来:BAAALAAECgYIBgAAAA==.',['格物']='格物知之尽也:BAAALAAECggICAAAAA==.',['椒盐']='椒盐皮皮虾:BAAALAAECgYIDAAAAA==.',['樱雨']='樱雨绵绵:BAAALAADCgQIBAAAAA==.',['正是']='正是在下:BAAALAAECgYIBgAAAA==.',['水晶']='水晶晶:BAACLAAFFH8gAAIXAAYIlxruCwDFAQAXAAYIlxruCwDFAQAsAAQKfyEAAhcACAhjIrERAIQCABcACAhjIrERAIQCAAAA.',['沉沉']='沉沉:BAAALAAECgYIDwAAAA==.',['河流']='河流午后:BAABLAAFFH8aAAIOAAYI0xSiLABoAQAOAAYI0xSiLABoAQAAAA==.',['法尼']='法尼瓦伦泰:BAAALAAECgUICgAAAA==.',['泪珠']='泪珠儿:BAAALAADCgYIBgAAAA==.',['泰瑞']='泰瑞尔风行者:BAAALAAFFAIIAgAAAA==.',['海滨']='海滨丶盛夏:BAAALAAECgYIBgAAAA==.',['深山']='深山孤寂:BAAALAADCgQIBAAAAA==.',['深海']='深海不太冷:BAAALAAECgYIBgAAAA==.',['清风']='清风十井:BAAALAAECggICAAAAA==.',['温布']='温布雷:BAAALAAFFAIIAgAAAA==.',['温蕾']='温蕾萨:BAABLAAFFH8GAAILAAMIWyFGOgCvAAALAAMIWyFGOgCvAAAAAA==.温蕾萨风行者:BAABLAAECn8VAAMHAAYIOxZlhgA+AQAHAAYIOxZlhgA+AQANAAUIYQfnjgCrAAAAAA==.',['溪亭']='溪亭:BAAALAAECgIIAgAAAA==.',['滚刀']='滚刀肉:BAAALAADCgYIBgAAAA==.',['火兮']='火兮:BAAALAAECgYICQAAAA==.',['火焰']='火焰丶小安静:BAAALAAECgQIBAAAAA==.火焰丶小淼淼:BAAALAAECgYIBgAAAA==.火焰丶小猫咪:BAAALAAECgUIBQAAAA==.',['火麒']='火麒麟烽锋:BAAALAAFFAIIAgAAAA==.',['灵动']='灵动一箭:BAAALAAFFAQIBAAAAA==.',['炖鸡']='炖鸡炖鸡炖鸡:BAABLAAFFH8IAAIYAAIIOQsIHAAyAAAYAAIIOQsIHAAyAAAAAA==.',['炜少']='炜少在此:BAAALAAFFAIIBAAAAA==.',['点击']='点击就送:BAAALAAECggICAAAAA==.',['烈焰']='烈焰猫头鹰:BAAALAAECggIEAAAAA==.',['無僧']='無僧:BAAALAAECgYIBgAAAA==.',['爱之']='爱之煞:BAAALAAFFAIIAgAAAA==.',['爱淘']='爱淘玩物:BAAALAADCgMIAwAAAA==.',['牧法']='牧法无边:BAAALAAECgYIBgAAAA==.',['猪喵']='猪喵喵:BAAALAAECgcICwAAAA==.',['猪猪']='猪猪仙:BAAALAAECgYICQAAAA==.',['玉藻']='玉藻前:BAABLAAFFH8GAAIJAAIIkR04MQClAAAJAAIIkR04MQClAAAAAA==.',['王哥']='王哥哥诶:BAAALAAECgEIAQABLAAECggICwAQAAAAAA==.',['珈的']='珈的毛大毛丶:BAAALAAECgMIAwAAAA==.',['珊瑚']='珊瑚宫心海:BAAALAAFFAIIAwAAAA==.',['珊蒂']='珊蒂影歌:BAAALAADCggICAAAAA==.',['珍波']='珍波椰:BAAALAAFFAIIBAAAAA==.',['甄夏']='甄夏琉:BAAALAAECgEIAQAAAA==.',['疯喵']='疯喵喵:BAAALAAECgMIAwAAAA==.',['白发']='白发孙悟空:BAAALAADCgIIAgAAAA==.',['盛情']='盛情难却:BAAALAAFFAIIBAAAAA==.',['睇下']='睇下条冰棍:BAAALAAECgQIBAAAAA==.',['码头']='码头整点炸鸡:BAAALAAECgQIBAAAAA==.',['碎光']='碎光者:BAAALAAFFAIIAgAAAA==.',['祝你']='祝你例假不断:BAAALAAECgQIBAAAAA==.',['神射']='神射手紫樱枫:BAAALAAECgYIDAAAAA==.',['秦川']='秦川哥哥:BAAALAAFFAIIAwAAAA==.',['程诚']='程诚诚:BAAALAAECgYIBgAAAA==.',['空酒']='空酒杯:BAAALAAECgYICgAAAA==.',['突突']='突突:BAAALAAECgYIDQABLAAFFAYIGgAOANMUAA==.',['窄宽']='窄宽强:BAAALAAECgIIAgAAAA==.',['第一']='第一次射:BAAALAAECgcIEwAAAA==.',['糖蝴']='糖蝴蝶:BAAALAAFFAIIAgAAAA==.',['紫色']='紫色信念:BAABLAAECn8XAAILAAcIbCJdMACwAgALAAcIbCJdMACwAgAAAA==.紫色堕落:BAAALAAECgYIBgAAAA==.紫色复仇:BAAALAAECgYIBgAAAA==.',['絡繰']='絡繰町案内:BAABLAAECn8ZAAIZAAgIBA9yJABvAQAZAAgIBA9yJABvAQAAAA==.',['约尔']='约尔灬提西娅:BAABLAAFFH8KAAMHAAMIQxn/awCKAAAHAAMIQxn/awCKAAAaAAEIuyAzBwAAAAAAAA==.',['约翰']='约翰史密斯:BAABLAAFFH8RAAIZAAYINQYPFQDtAAAZAAYINQYPFQDtAAAAAA==.',['纯爱']='纯爱战神:BAABLAAFFH8GAAIMAAIIYiH0IADCAAAMAAIIYiH0IADCAAABLAAFFAcIKAAGAAIgAA==.',['罗拉']='罗拉洛兰:BAAALAAECgYIBgAAAA==.',['老烟']='老烟:BAAALAADCgYIBgAAAA==.',['肉肉']='肉肉爸爸:BAAALAAECgQIBAAAAA==.',['自摸']='自摸九条:BAAALAAECgUIBQAAAA==.',['般若']='般若月:BAAALAAECgUICAAAAA==.',['色喵']='色喵喵:BAAALAAECgYIBwAAAA==.',['艾罗']='艾罗娜丶星叶:BAAALAAECgEIAQAAAA==.',['艾露']='艾露莎丶月歌:BAAALAAFFAIIBAAAAA==.',['花仙']='花仙女:BAABLAAECn8cAAIOAAcI6hkoJQDIAQAOAAcI6hkoJQDIAQAAAA==.',['花火']='花火:BAAALAAFFAQIBAABLAAFFAgIDgAOAJgfAA==.',['英诺']='英诺森三世:BAAALAAECgEIAQAAAA==.',['英雄']='英雄归来:BAAALAAECgEIAQAAAA==.',['莱弦']='莱弦:BAAALAAECgYIDQAAAA==.',['萘阿']='萘阿:BAAALAAECgEIAQAAAA==.',['萨其']='萨其玛:BAAALAAFFAIIBAAAAA==.',['萨卡']='萨卡:BAABLAAFFH8QAAQKAAYI4gGQDwAmAAAVAAMI+gLmDwA6AAAKAAMIyQCQDwAmAAAJAAIIGQAmYgANAAAAAA==.',['萨格']='萨格啦斯利刃:BAAALAAECgYIBgAAAA==.萨格啦斯风语:BAABLAAFFH8HAAIHAAMI4RjISACbAAAHAAMI4RjISACbAAAAAA==.',['蓝心']='蓝心雪翎:BAAALAAECgUIBwAAAA==.',['蓝精']='蓝精龙:BAAALAADCgUIBQAAAA==.',['蓬户']='蓬户为父开:BAAALAADCgcIDAAAAA==.',['蔚蓝']='蔚蓝星辰:BAAALAADCgMIAwAAAA==.',['薯条']='薯条:BAACLAAFFH8WAAILAAUIZCJeHQB2AQALAAUIZCJeHQB2AQAsAAQKfxUAAgsABgg/JEAuANkBAAsABgg/JEAuANkBAAAA.',['虎喵']='虎喵喵:BAAALAAECgIIAgAAAA==.',['蚀人']='蚀人:BAAALAADCgMIAwAAAA==.',['蚩尤']='蚩尤:BAACLAAFFH8WAAIHAAYIjxL/OwBTAQAHAAYIjxL/OwBTAQAsAAQKfyEAAwcABwgvIFEwAPsBAAcABwgvIFEwAPsBAA0AAQhfAjfWABAAAAAA.',['血衣']='血衣天使:BAAALAADCggICAAAAA==.',['袁园']='袁园园:BAAALAAECgYIBgAAAA==.',['西神']='西神西神西神:BAACLAAFFH8oAAIGAAcIAiAgCwAyAgAGAAcIAiAgCwAyAgAsAAQKfzAAAgYACAiVJugCAHgDAAYACAiVJugCAHgDAAAA.',['詞不']='詞不达意丶:BAAALAAECggIDgABLAAFFAgIDwAUAKYjAA==.',['豆芽']='豆芽菜丶:BAABLAAFFH8KAAIGAAIIgSRfLwDQAAAGAAIIgSRfLwDQAAAAAA==.',['走霉']='走霉运:BAAALAAECgEIAQAAAA==.',['超级']='超级天鼓:BAAALAAECgQIBAAAAA==.',['轻扯']='轻扯老妈肚兜:BAAALAADCgYIBgAAAA==.',['迷路']='迷路天才:BAAALAAFFAYIBAAAAA==.迷路的熊趴趴:BAABLAAFFH8GAAIMAAII8ReNSgBIAAAMAAII8ReNSgBIAAABLAAFFAYIGgAOANMUAA==.迷路的菊花茶:BAAALAAECgYICAAAAA==.',['逍遥']='逍遥玉龙:BAAALAADCgUIBQAAAA==.',['逐月']='逐月色追凶:BAAALAADCgQIBAAAAA==.',['遇见']='遇见狐狸:BAACLAAFFH8QAAIWAAUITg5wIgAvAQAWAAUITg5wIgAvAQAsAAQKfzAAAhYACAjkF1YzABACABYACAjkF1YzABACAAAA.遇见黑铁:BAAALAAECgUIBQAAAA==.',['邮电']='邮电部诗人:BAAALAAECgYIBgAAAA==.',['酸葡']='酸葡萄呀:BAAALAAECgEIAQAAAA==.',['铁手']='铁手:BAAALAADCgMIAwAAAA==.',['银霜']='银霜飞月:BAAALAADCggIDAAAAA==.',['阿兰']='阿兰若若:BAAALAAFFAIIAgAAAA==.',['阿嗜']='阿嗜尼:BAAALAAECgYIBgAAAA==.',['阿尔']='阿尔尤拉诺斯:BAAALAAECgMIBgAAAA==.阿尔萨丝:BAAALAAECgIIAgAAAA==.',['隆隆']='隆隆震地:BAAALAAFFAIIAgAAAA==.',['雅兒']='雅兒贝德:BAAALAAECgYIBgAAAA==.',['雪羽']='雪羽悠悠:BAAALAAECgcIEgAAAA==.',['雷神']='雷神:BAAALAADCgYIBwAAAA==.',['霜行']='霜行天下:BAAALAAECgYICQAAAA==.',['露露']='露露丝晨歌:BAAALAAECgYICgAAAA==.',['青丶']='青丶枫:BAAALAAECgcIBwAAAA==.',['非洲']='非洲来茶壶:BAAALAAECgYIDAAAAA==.',['风之']='风之雪:BAAALAADCgIIAgAAAA==.',['风火']='风火:BAAALAAECgYIDgAAAA==.',['风的']='风的颜色:BAAALAAECgYIEgAAAA==.',['飞喧']='飞喧:BAABLAAFFH8IAAIDAAIIVRbATQCAAAADAAIIVRbATQCAAAAAAA==.',['飞暄']='飞暄:BAAALAAECgYIBgAAAA==.',['飞萱']='飞萱:BAABLAAFFH8KAAIHAAIIAResjgBFAAAHAAIIAResjgBFAAAAAA==.',['香草']='香草冰淇淋:BAAALAAFFAYIBAAAAA==.',['香辣']='香辣芹菜皮:BAABLAAFFH8LAAIHAAYIoRSRLACDAQAHAAYIoRSRLACDAQAAAA==.香辣蓝莓皮:BAABLAAFFH8VAAMGAAYIhxa0IQCPAQAGAAYIhxa0IQCPAQAbAAIIXBO0EwCGAAAAAA==.',['骑着']='骑着妞的九条:BAABLAAECn8UAAIJAAYIMw3UUADSAAAJAAYIMw3UUADSAAAAAA==.',['鬼幻']='鬼幻影:BAAALAAECgYICgAAAA==.',['鬼月']='鬼月影:BAABLAAFFH8MAAIJAAQI9h81GQBlAQAJAAQI9h81GQBlAQAAAA==.',['鬼烈']='鬼烈影:BAAALAAECgYIBgAAAA==.',['鬼语']='鬼语者:BAACLAAFFH8GAAIFAAIIOxLfEQBOAAAFAAIIOxLfEQBOAAAsAAQKfyIAAgUABwjtHcYPAFsCAAUABwjtHcYPAFsCAAAA.',['鲁班']='鲁班柒号:BAAALAAECgYIBgAAAA==.',['鸱鸮']='鸱鸮:BAAALAAECgYIBgAAAA==.',['鸿运']='鸿运:BAABLAAFFH8WAAIHAAYI9x76JACeAQAHAAYI9x76JACeAQAAAA==.',['鹤仙']='鹤仙人:BAABLAAFFH8JAAIMAAUIowcELwDdAAAMAAUIowcELwDdAAAAAA==.',['麽麽']='麽麽香:BAABLAAECn8dAAQOAAcIxRSyYADPAQAOAAcIxRSyYADPAQARAAMIUQpWeACYAAAcAAMIpwhhKwCRAAAAAA==.',['黄河']='黄河之水:BAAALAAECgYIDQAAAA==.',['黑化']='黑化国宝:BAAALAAECgcIDQAAAA==.',['黑发']='黑发孙悟空:BAAALAADCgEIAQAAAA==.',['黑老']='黑老大:BAAALAAECgYICQAAAA==.',['默数']='默数繁华:BAACLAAFFH8MAAIbAAQIfAz6CgC0AAAbAAQIfAz6CgC0AAAsAAQKfxgAAhsACAioGj0MAPgBABsACAioGj0MAPgBAAAA.',['龙喵']='龙喵喵:BAAALAAECgYIDAAAAA==.',['龙象']='龙象:BAAALAAECgYIDQAAAA==.',['龙骑']='龙骑士丶:BAAALAAECgYIDwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end