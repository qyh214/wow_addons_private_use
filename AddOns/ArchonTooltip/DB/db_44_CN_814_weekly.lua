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
 local lookup = {'Warlock-Destruction','Druid-Balance','Druid-Feral','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Paladin-Protection','DeathKnight-Frost','Warrior-Protection','Warrior-Arms','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Restoration','Paladin-Holy','Paladin-Retribution','Shaman-Restoration','Druid-Guardian','DeathKnight-Blood','Shaman-Elemental','Mage-Frost','Mage-Arcane','Monk-Brewmaster','Monk-Mistweaver','Warrior-Fury','DeathKnight-Unholy','Priest-Shadow','Evoker-Preservation','Evoker-Devastation','Warlock-Demonology','Rogue-Subtlety','Rogue-Assassination','Unknown-Unknown','Priest-Discipline','Rogue-Outlaw','Monk-Windwalker','Evoker-Augmentation',}; local provider = {region='CN',realm='菲米丝',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alanwake:BAABLAAFFH8GAAIBAAIIFR63MQCyAAABAAIIFR63MQCyAAAAAA==.',Am='Ambitions:BAAALAAECggICAAAAA==.Amofz:BAAALAAECgUIBwAAAA==.',As='Asaki:BAABLAAFFH8FAAMCAAIIeQ+INAA8AAACAAEImw6INAA8AAADAAII3A3VDwA6AAAAAA==.',Ce='Cersei:BAAALAAECgcIBwAAAA==.',Cl='Clancy:BAABLAAFFH8GAAMEAAIINhoZhwBKAAAEAAIINhoZhwBKAAAFAAEIUgDRHQAGAAAAAA==.',Da='Dababy:BAAALAAFFAIIAwAAAA==.',De='Decadent:BAAALAAECgYIBgAAAA==.',Do='Dogthing:BAAALAADCggICQAAAA==.',Fl='Flowerleaf:BAABLAAFFH8GAAIGAAYIxQSpIQA5AQAGAAYIxQSpIQA5AQAAAA==.',Gf='Gfgjhff:BAACLAAFFH8JAAMFAAIIDiTzEgBPAAAFAAIIDiTzEgBPAAAEAAEIGRuejgBGAAAsAAQKfyMAAwUACAjnIgIPAOsCAAUACAheIQIPAOsCAAQAAggBIK5PAa8AAAAA.',Ho='Holynove:BAABLAAFFH8NAAIHAAIIxAgTHgBkAAAHAAIIxAgTHgBkAAAAAA==.',La='Labubu:BAAALAADCggIDQAAAA==.',Le='Lefy:BAABLAAFFH8GAAIIAAIImx75QACxAAAIAAIImx75QACxAAAAAA==.',Me='Mediocre:BAABLAAECn8WAAMJAAYIihTiSwBSAQAJAAYIihTiSwBSAQAKAAEI3Ai9PwAnAAAAAA==.Merciless:BAAALAAECgYIBwAAAA==.',Pl='Playerqqfvbo:BAABLAAFFH8vAAIEAAYI7RkzFQB1AQAEAAYI7RkzFQB1AQAAAA==.',Ra='Raywind:BAABLAAFFH8PAAILAAMIABJHQgCFAAALAAMIABJHQgCFAAAAAA==.',Ro='Rockey:BAAALAAFFAQIBAAAAA==.',Sa='Safarirose:BAAALAAFFAIIBAAAAA==.',Ti='Timing:BAAALAAECgYIBgAAAA==.',Vi='Vivit:BAAALAAECgYIBgAAAA==.',['一个']='一个这么帅:BAAALAAECgIIAgAAAA==.',['三兮']='三兮水无寒:BAACLAAFFH8GAAIJAAII/R1SFACuAAAJAAII/R1SFACuAAAsAAQKfxkAAwkABgitIbYcAEwCAAkABgitIbYcAEwCAAoAAQh2CSI+AC0AAAAA.',['不要']='不要吃地板:BAAALAAFFAIIAgAAAA==.',['丶冷']='丶冷骨头:BAACLAAFFH9BAAMLAAYIVSOGCgD4AQALAAYIVSOGCgD4AQAMAAEIsRE0HAA6AAAsAAQKfxYAAgsACAiFHYNDAFcCAAsACAiFHYNDAFcCAAAA.',['丶文']='丶文熙:BAAALAADCgEIAQAAAA==.',['丶肚']='丶肚:BAAALAAECgEIAQAAAA==.',['丹妮']='丹妮莉丝:BAAALAAFFAIIBAAAAA==.',['为肚']='为肚为战:BAAALAAECgYIEgABLAAECggIHgANAFUiAA==.',['乱世']='乱世丶:BAAALAAECgIIAgAAAA==.',['乱流']='乱流:BAAALAADCgEIAQAAAA==.',['二口']='二口之家:BAAALAAFFAEIAQAAAA==.',['仙人']='仙人摘桃:BAAALAAECgYIDQAAAA==.',['伊利']='伊利丶丹怒風:BAAALAAFFAIIBAAAAA==.',['会再']='会再见吗燕子:BAAALAAFFAIIAgAAAA==.',['低调']='低调的亲嘴:BAAALAADCgYIBgAAAA==.',['何其']='何其臭的嘴:BAABLAAFFH8IAAMOAAgIgQ35CwDGAQAOAAcIeA35CwDGAQAPAAEI9wjzZABEAAAAAA==.何其臭的手:BAABLAAFFH8IAAMOAAgIAQrvDAC3AQAOAAcInQrvDAC3AQAPAAEIeAMdegA3AAAAAA==.何其臭的脚:BAAALAAECgYIBgAAAA==.',['你先']='你先活着做人:BAABLAAFFH8GAAIIAAYIyxAbNABsAQAIAAYIyxAbNABsAQAAAA==.',['做梦']='做梦都在振刀:BAAALAAECgYIBgAAAA==.',['傻蛮']='傻蛮:BAAALAADCgUIBQAAAA==.',['元素']='元素增强萨:BAABLAAFFH8VAAIQAAYIVhaYFwCiAQAQAAYIVhaYFwCiAQAAAA==.',['元让']='元让之手:BAAALAADCgcIBwAAAA==.',['八荒']='八荒劫无锋:BAAALAAFFAIIAgAAAA==.',['六七']='六七转弯:BAAALAAFFAIIAgAAAA==.',['六叔']='六叔跌摩托:BAACLAAFFH8IAAMNAAMIfBsaMwCeAAANAAIIsh8aMwCeAAACAAMIjhT8JQCDAAAsAAQKfy0ABAIACAhTIfwNAP8CAAIACAhTIfwNAP8CAA0ABAizIGRdAHsBABEAAQjSGEk2AEcAAAAA.',['兰德']='兰德鲁的礼盒:BAAALAAECgYICwAAAA==.',['冰魂']='冰魂丸:BAAALAAFFAIIBAABLAAFFAYIHwAFAJMkAA==.',['冲锋']='冲锋不用技:BAAALAAECgYIBgAAAA==.',['冷月']='冷月殇魂舞:BAAALAAECgYIBgAAAA==.',['凄灬']='凄灬丶:BAAALAAECgYICwAAAA==.',['凯特']='凯特骑士:BAAALAAFFAIIAgAAAA==.',['凹凸']='凹凸曼:BAAALAADCgIIAgAAAA==.',['刀锋']='刀锋战神:BAAALAAFFAIIBAAAAA==.',['分开']='分开才说抱歉:BAAALAAFFAIIAgABLAAFFAMIBgADAC4RAA==.',['初见']='初见乍惊欢:BAAALAAECgYIBwAAAA==.',['办震']='办震刻章:BAAALAAECgYICwAAAA==.',['化粪']='化粪池毒奶:BAACLAAFFH8mAAIOAAcIayLsAgCaAgAOAAcIayLsAgCaAgAsAAQKfyUAAg4ACAjOIvsCAPwCAA4ACAjOIvsCAPwCAAEsAAUUCAgGAA4A8AkA.',['北呆']='北呆河:BAAALAAECgMIAwAAAA==.',['千铭']='千铭之車:BAAALAAECgYIBAAAAA==.',['卓可']='卓可亲:BAAALAAFFAIIBAAAAA==.',['单身']='单身勇着:BAABLAAECn8ZAAMSAAgIuhPsEABtAQASAAgIsRPsEABtAQAIAAIIABP+cgF/AAAAAA==.',['卢队']='卢队长:BAACLAAFFH88AAICAAYIbB0DCwCxAQACAAYIbB0DCwCxAQAsAAQKfxYAAgIACAjqFjEmADkCAAIACAjqFjEmADkCAAAA.',['卧槽']='卧槽小灰:BAAALAAFFAIIAgAAAA==.卧槽帅狗:BAABLAAFFH8oAAITAAYI2SEgDgDUAQATAAYI2SEgDgDUAQAAAA==.卧槽罗根:BAABLAAFFH8GAAIHAAIIqRgKEQCSAAAHAAIIqRgKEQCSAAAAAA==.卧槽萌猫:BAABLAAFFH8mAAMNAAYIyR0/CwAAAgANAAYIyR0/CwAAAgACAAUILwvGHADrAAAAAA==.卧槽野猫:BAABLAAFFH8NAAINAAUIDRaXGABtAQANAAUIDRaXGABtAQAAAA==.',['古灵']='古灵精怪:BAABLAAFFH8GAAMUAAYIBQ+xDwBlAAAVAAMIDBhHOwDtAAAUAAMI/gWxDwBlAAAAAA==.',['只杀']='只杀不渡:BAAALAAECgUIBQAAAA==.',['叫什']='叫什么妥呢:BAAALAAFFAIIAgAAAA==.',['召唤']='召唤黑暗之魂:BAAALAADCgQIBAAAAA==.',['可以']='可以丶可以:BAACLAAFFH8nAAIWAAcI1RtWAQB8AgAWAAcI1RtWAQB8AgAsAAQKfyAAAxYACAh5H/4LAJ4CABYACAh5H/4LAJ4CABcAAwhcFrk+AMYAAAAA.',['可牛']='可牛了:BAABLAAECn8VAAMCAAcIOBy4NQDkAQACAAcIOBy4NQDkAQANAAMINBUuWgCyAAAAAA==.',['叶知']='叶知秋:BAAALAAECgcIDQABLAAFFAgICgAYAKoiAA==.',['叶落']='叶落无声:BAABLAAECn8VAAIFAAgIdw1OUAB1AQAFAAgIdw1OUAB1AQAAAA==.',['吃瓜']='吃瓜群众:BAAALAAECgYIEAAAAA==.',['吉良']='吉良吉影:BAAALAAECgcIBwAAAA==.',['吕少']='吕少控球:BAAALAAFFAIIAgAAAA==.',['呆呆']='呆呆河:BAAALAAFFAIIAgAAAA==.',['呆河']='呆河:BAACLAAFFH9KAAISAAYI7RmCBQCbAQASAAYI7RmCBQCbAQAsAAQKfxoAAxkACAjhHXIZAPEBABkABQhHIXIZAPEBABIACAifGzUZANMBAAAA.',['呲莮']='呲莮孓未緡:BAABLAAFFH8JAAIEAAIISQ1blwBCAAAEAAIISQ1blwBCAAAAAA==.',['咆哮']='咆哮斩杀者:BAAALAAECgcIDAAAAA==.',['咔咔']='咔咔希:BAAALAAECgYIDQAAAA==.',['哈儿']='哈儿宝宝:BAAALAAFFAIIAgAAAA==.',['哎啾']='哎啾丶:BAAALAAECgYICwAAAA==.',['唯美']='唯美记忆:BAAALAAFFAIIAgABLAAFFAMIBgADAC4RAA==.',['嗜殺']='嗜殺:BAAALAAECgUIBQAAAA==.',['嗜酒']='嗜酒丶:BAAALAAFFAIIAgAAAA==.',['嘲渢']='嘲渢:BAAALAAECgEIAQAAAA==.',['四时']='四时沐无心:BAABLAAFFH8uAAMGAAYIfQwmDQB7AQAGAAYIfQwmDQB7AQAaAAUISwbWGADyAAAAAA==.',['回家']='回家爱好窝:BAAALAAFFAIIAgAAAA==.',['囡哒']='囡哒哆:BAAALAAECgEIAgAAAA==.',['圆肚']='圆肚丶:BAAALAADCgcIBgAAAA==.',['圈圈']='圈圈是骑士:BAAALAADCgUIBQAAAA==.',['圣光']='圣光呆呆河:BAABLAAFFH8FAAIPAAUIng+7KgAsAQAPAAUIng+7KgAsAQAAAA==.圣光忽悠你:BAAALAADCgcIBwAAAA==.',['圣器']='圣器士:BAAALAADCgMIAwAAAA==.',['坏坏']='坏坏学长:BAABLAAFFH8vAAMbAAcIahetBgAQAgAbAAcIahetBgAQAgAcAAUI/RGOEAARAQAAAA==.',['坏小']='坏小骑:BAAALAAFFAMIAwAAAA==.',['坐忘']='坐忘道丶:BAAALAAECgQIBQAAAA==.',['堕落']='堕落的瓦斯琦:BAABLAAECn8fAAIIAAcIpBe2MgCtAQAIAAcIpBe2MgCtAQAAAA==.',['塞琳']='塞琳娜凯尔:BAAALAAFFAIIAgAAAA==.',['夏沫']='夏沫浅浅:BAACLAAFFH8xAAINAAcInhrMCAAhAgANAAcInhrMCAAhAgAsAAQKfz8AAw0ACAi4IEAgAG4CAA0ACAi4IEAgAG4CAAIABwgwENswAAMBAAAA.',['夏紫']='夏紫汐:BAAALAAECgYICgAAAA==.',['多恩']='多恩舞:BAAALAAECgYIBgAAAA==.',['夜太']='夜太美:BAAALAAECgYIBgAAAA==.',['大宝']='大宝可可:BAAALAAFFAIIAgAAAA==.',['大白']='大白兔灬奶糖:BAAALAAFFAIIAgAAAA==.',['大路']='大路元帅:BAAALAAFFAMIAwAAAA==.',['天下']='天下我最靓:BAAALAADCggICAAAAA==.',['天命']='天命:BAABLAAFFH8IAAILAAII9h1kSwBOAAALAAII9h1kSwBOAAABLAAFFAgINwADAKgeAA==.天命战:BAABLAAFFH8IAAIKAAIIug7OBQBBAAAKAAIIug7OBQBBAAAAAA==.',['奥德']='奥德彪拉香蕉:BAAALAAFFAMIAwAAAA==.',['奥格']='奥格瑞瑪:BAABLAAFFH8FAAIYAAMIewazKQCnAAAYAAMIewazKQCnAAAAAA==.',['妥妥']='妥妥的小白牛:BAAALAAFFAIIAgAAAA==.',['姑娘']='姑娘你别走:BAAALAAECgYIBgAAAA==.',['姬丨']='姬丨风暴图腾:BAAALAADCgcIBwAAAA==.',['威克']='威克斯卡尔:BAAALAAECgYIBgAAAA==.',['学长']='学长:BAABLAAFFH8uAAMOAAYIYBl2CwDOAQAOAAYIYBl2CwDOAQAHAAYIOhQvBwBWAQAAAA==.学长不坏:BAABLAAFFH8xAAMCAAYI4xs6DwB4AQACAAUIgyA6DwB4AQANAAYIfBlhDQAjAQAAAA==.',['安世']='安世灵犀:BAABLAAFFH8QAAILAAMIjRQiHwDtAAALAAMIjRQiHwDtAAAAAA==.',['安德']='安德利啵啵:BAABLAAFFH8FAAINAAUITgbxJQDrAAANAAUITgbxJQDrAAAAAA==.',['寒羽']='寒羽洋:BAAALAAECgYIBgAAAA==.',['小丶']='小丶:BAABLAAFFH8GAAMdAAMI4wluDwBOAAABAAMIbQNdVABcAAAdAAMIsQluDwBOAAAAAA==.',['小小']='小小明日:BAAALAAECgUIBQAAAA==.',['小柔']='小柔柔:BAAALAAECgIIAgAAAA==.',['小狐']='小狐狸花:BAAALAAECgYIBgAAAA==.',['小草']='小草莓:BAAALAAECgUIBQAAAA==.',['小薇']='小薇薇:BAAALAAECgYIBgAAAA==.',['小阿']='小阿叁:BAABLAAFFH8RAAIYAAYIOhpqGQCYAQAYAAYIOhpqGQCYAQAAAA==.小阿肆:BAABLAAFFH8GAAIIAAYIExksKQCTAQAIAAYIExksKQCTAQAAAA==.',['小雨']='小雨冷夜:BAABLAAFFH8HAAIPAAYIrRDTKQAxAQAPAAYIrRDTKQAxAQAAAA==.',['小飞']='小飞棍来咯:BAAALAAECgYIBQAAAA==.',['小黑']='小黑嘿潶:BAACLAAFFH9BAAMNAAYIHSX4AgAXAgANAAYIHSX4AgAXAgACAAIINQcSKAB1AAAsAAQKfxQAAg0ACAizIG4mAE0CAA0ACAizIG4mAE0CAAAA.',['小鼠']='小鼠鼠:BAAALAAECgYIEAAAAA==.',['少见']='少见:BAAALAAECgcICAAAAA==.',['尼古']='尼古拉斯伊娃:BAABLAAFFH8GAAIQAAYISAB1ggAHAAAQAAYISAB1ggAHAAAAAA==.',['岁末']='岁末的秋天:BAAALAAFFAIIAgAAAA==.',['岩七']='岩七七:BAABLAAFFH8IAAMBAAIISB/ePwCYAAABAAIIwBXePwCYAAAdAAEIfiHwIwBWAAAAAA==.',['岩小']='岩小帅:BAAALAAECgIIAgAAAA==.',['巧克']='巧克力奶豆丶:BAABLAAFFH8IAAMQAAYIUQITdwA+AAAQAAII6wETdwA+AAATAAQIkQA0VQAhAAAAAA==.',['希尔']='希尔瓦娜女王:BAACLAAFFH8VAAMFAAYIcBWwCAAuAQAFAAUIuROwCAAuAQAEAAQIhBYgXQDSAAAsAAQKfyEAAwQACAi+HqNHAFMCAAQABwhOIKNHAFMCAAUAAgj+D3mpAF4AAAAA.',['干戈']='干戈止境:BAAALAADCgcIBwAAAA==.',['幺妹']='幺妹儿:BAAALAAECgUICQAAAA==.',['弄月']='弄月:BAAALAAECgYIBgAAAA==.',['张凌']='张凌峰:BAAALAAECgYIDAAAAA==.',['强灬']='强灬干丶:BAACLAAFFH8GAAIPAAII4BpsUgBRAAAPAAII4BpsUgBRAAAsAAQKfx4AAg8ABggyJBhGAGoCAA8ABggyJBhGAGoCAAAA.',['彩虹']='彩虹心:BAABLAAFFH8KAAIIAAII0xzDdABMAAAIAAII0xzDdABMAAABLAAFFAcINwAVAKEfAA==.',['德一']='德一只:BAABLAAFFH8GAAIDAAMILhHaBgDsAAADAAMILhHaBgDsAAAAAA==.',['快餐']='快餐面:BAAALAADCggICAAAAA==.',['忽而']='忽而今夏:BAAALAAECgYIEAAAAA==.',['怒雷']='怒雷丶:BAAALAAFFAIIAgAAAA==.',['怡玥']='怡玥:BAABLAAECn8YAAMdAAgIAgvCLwCwAQAdAAgIAgvCLwCwAQABAAEI2AOoEAEjAAAAAA==.',['恐龙']='恐龙扛狼:BAAALAADCgMIAwAAAA==.',['悠然']='悠然丶见南山:BAAALAAECggIDAAAAA==.',['想要']='想要狼群之饥:BAAALAAFFAIIAgAAAA==.',['我的']='我的二哈呢:BAACLAAFFH9KAAMEAAYIaSYRDAArAgAEAAYIYiYRDAArAgAFAAUIRiIiCQB9AQAsAAQKfxoAAwUACAjFJCURANsCAAUACAhfIyURANsCAAQABgh7Jbc6AHUCAAAA.',['我要']='我要抓只喵:BAABLAAFFH8EAAIEAAIIdCSPeABtAAAEAAIIdCSPeABtAAAAAA==.',['手黑']='手黑:BAABLAAFFH8FAAMNAAII2wJWVgBHAAANAAII2wJWVgBHAAARAAII3gEXEgAdAAAAAA==.',['打不']='打不过就装死:BAAALAAECgYICgAAAA==.',['打工']='打工人丶:BAABLAAFFH8XAAIGAAYICBnlEADXAQAGAAYICBnlEADXAQAAAA==.',['技师']='技师来自河北:BAAALAAFFAEIAQABLAAFFAMIBgADAC4RAA==.',['折腰']='折腰丶為紅顏:BAABLAAECn8ZAAIIAAgIcBcrLgC+AQAIAAgIcBcrLgC+AQAAAA==.',['抬手']='抬手打冲拳:BAACLAAFFH8qAAIEAAYISiOlDADRAQAEAAYISiOlDADRAQAsAAQKfxQAAgQACAiFHZsvAJoCAAQACAiFHZsvAJoCAAAA.',['抽如']='抽如象:BAABLAAFFH8IAAMeAAII/gqyHQA/AAAfAAEIignRIgBNAAAeAAEIcwyyHQA/AAAAAA==.',['拉平']='拉平:BAACLAAFFH8kAAMCAAYI5Q80EwBNAQACAAYI5Q80EwBNAQANAAQIqxAjKADYAAAsAAQKfyYAAw0ABwjPGoQYAAwCAA0ABgjGHoQYAAwCAAIABwiQEYNnACMBAAAA.',['拔丝']='拔丝土豆:BAAALAAECgYIBgAAAA==.',['擦擦']='擦擦二号:BAAALAAFFAIIBAAAAA==.',['放开']='放开那娘们:BAAALAAECgUICAAAAA==.放开那蕾丝:BAAALAAECgUIBQAAAA==.放开那阿婆:BAAALAAECgUIBQAAAA==.',['斗人']='斗人士:BAAALAAECgYIEAAAAA==.',['断茎']='断茎:BAAALAAECgQIBAAAAA==.',['斯坦']='斯坦丶马什:BAAALAAECgcICgAAAA==.',['新垣']='新垣结衣:BAAALAAFFAIIBAAAAA==.',['旧与']='旧与花飞:BAABLAAFFH8pAAMVAAYIuSFvEwDgAQAVAAYIuSFvEwDgAQAUAAIIaBN4EwCHAAAAAA==.',['时机']='时机:BAABLAAFFH8LAAIIAAUIxRFCRgAjAQAIAAUIxRFCRgAjAQAAAA==.',['星垂']='星垂平野阔:BAAALAAECgIIAgABLAAECgYIBwAgAAAAAA==.',['星愿']='星愿星语:BAAALAAECgYIDQAAAA==.',['星月']='星月点点:BAAALAAECgEIAQAAAA==.',['星辉']='星辉缀罗裳:BAABLAAECn8dAAIEAAgImBknLAAJAgAEAAgImBknLAAJAgAAAA==.',['星辰']='星辰暴击:BAAALAAECgMIAwAAAA==.',['春夏']='春夏丶秋冬:BAABLAAFFH8FAAIIAAII4x8caACUAAAIAAII4x8caACUAAAAAA==.',['晚秋']='晚秋残叶:BAAALAAFFAIIAgABLAAFFAMIBgADAC4RAA==.',['普罗']='普罗德莫尔:BAAALAAECggIEAAAAA==.',['普莉']='普莉希拉:BAABLAAFFH8GAAINAAIIghGtRABnAAANAAIIghGtRABnAAAAAA==.',['暗夜']='暗夜之歌:BAABLAAFFH8HAAIQAAIIKgZNbwBMAAAQAAIIKgZNbwBMAAAAAA==.暗夜魂魄:BAAALAADCggICAAAAA==.',['暗言']='暗言术:BAAALAAECgYIBgAAAA==.',['月光']='月光宝盒:BAAALAAECgYIDAAAAA==.',['月涌']='月涌大江流:BAAALAAECgYIBgABLAAECgYIBwAgAAAAAA==.',['术殇']='术殇:BAABLAAFFH8GAAIBAAIIEgsHTACIAAABAAIIEgsHTACIAAAAAA==.',['杰尼']='杰尼杰尼:BAAALAAFFAIIAgAAAA==.',['构币']='构币居保我:BAABLAAFFH8GAAIPAAIIPxFiQACeAAAPAAIIPxFiQACeAAAAAA==.',['林江']='林江仙丶:BAAALAAECgcIEQAAAA==.',['枫绝']='枫绝恋涙丶:BAABLAAFFH8MAAIYAAYIxw3fHwBuAQAYAAYIxw3fHwBuAQAAAA==.',['枯萎']='枯萎凋零:BAABLAAFFH8FAAIIAAIIhAifmwA5AAAIAAIIhAifmwA5AAAAAA==.',['柒月']='柒月:BAAALAADCgEIAQAAAA==.',['柠檬']='柠檬薄荷:BAABLAAFFH8IAAIQAAIIygizYwBdAAAQAAIIygizYwBdAAABLAAFFAYIRQAcAB8ZAA==.',['梧桐']='梧桐兼细雨:BAACLAAFFH85AAIBAAYI3iXGDwAVAgABAAYI3iXGDwAVAgAsAAQKfxYAAgEACAiIIsodANkCAAEACAiIIsodANkCAAAA.',['检查']='检查身体:BAAALAAECgMIBQAAAA==.',['森多']='森多木:BAAALAAFFAMIAwAAAA==.',['橙黄']='橙黄色螃蟹:BAACLAAFFH83AAIVAAcIoR+rCwAtAgAVAAcIoR+rCwAtAgAsAAQKfzYAAhUACAhmJBsTAA0DABUACAhmJBsTAA0DAAAA.',['毒奶']='毒奶小炮:BAACLAAFFH8PAAIGAAIIgROELACTAAAGAAIIgROELACTAAAsAAQKfx4AAwYACAg3D51UAIUBAAYACAggDZ1UAIUBACEABAhWDRUkAMkAAAAA.',['毛茸']='毛茸茸:BAAALAADCgcIBwAAAA==.',['沃坎']='沃坎:BAAALAADCgIIAgAAAA==.',['沙漠']='沙漠之狐:BAAALAAFFAIIBAAAAA==.',['没有']='没有脑壳:BAACLAAFFH8FAAIIAAMIDAbVOwC6AAAIAAMIDAbVOwC6AAAsAAQKfxoAAggABwhaEwZUAEwBAAgABwhaEwZUAEwBAAAA.',['法力']='法力残渣:BAABLAAFFH8IAAIVAAIIWhGeVgBEAAAVAAIIWhGeVgBEAAAAAA==.',['泪打']='泪打湿肯德基:BAAALAADCggICAAAAA==.',['洋马']='洋马驾驶员:BAAALAAFFAIIBAABLAAFFAMIBgADAC4RAA==.',['流用']='流用:BAACLAAFFH8TAAIHAAUIFhdKBwDxAAAHAAUIFhdKBwDxAAAsAAQKfywAAwcACAgMHYQQAH8CAAcACAgMHYQQAH8CAA8ABAicFmYzAcsAAAAA.',['清秋']='清秋依依:BAAALAAECgYIBgAAAA==.',['滑溜']='滑溜先生:BAAALAAECgIIAgAAAA==.',['潞過']='潞過傷人:BAAALAAFFAIIAgAAAA==.',['火球']='火球术:BAAALAAECgcICQAAAA==.',['灭霸']='灭霸猎魂:BAAALAADCgMIAwAAAA==.',['灰常']='灰常么么水:BAABLAAFFH8IAAIEAAIIISC7OwCtAAAEAAIIISC7OwCtAAAAAA==.',['炎君']='炎君:BAAALAAECgcICgAAAA==.',['爆烟']='爆烟子佬头:BAAALAAECgYIBgAAAA==.',['爱你']='爱你的猫:BAABLAAFFH8HAAIBAAII+gxhaAA4AAABAAII+gxhaAA4AAAAAA==.',['爱而']='爱而不得:BAABLAAFFH8QAAIHAAIIEBdnHAAyAAAHAAIIEBdnHAAyAAAAAA==.',['牛大']='牛大:BAAALAADCgIIAgAAAA==.牛大嗝:BAAALAADCgcIBwAAAA==.',['牛气']='牛气十足:BAACLAAFFH9HAAIQAAYI4hZJDgBbAQAQAAYI4hZJDgBbAQAsAAQKfxoAAhAACAjQGtFAABsCABAACAjQGtFAABsCAAAA.牛气骁德:BAAALAAECgQIBQAAAA==.',['牛永']='牛永信:BAAALAAFFAIIAgAAAA==.',['牛頓']='牛頓:BAAALAAFFAIIAgAAAA==.',['牡丹']='牡丹丶:BAABLAAFFH8LAAILAAMIXxq/GgAFAQALAAMIXxq/GgAFAQAAAA==.',['牵手']='牵手丶:BAACLAAFFH8OAAIPAAIInBx/OQCjAAAPAAIInBx/OQCjAAAsAAQKfx8AAg8ABghcIktoABkCAA8ABghcIktoABkCAAAA.',['特靂']='特靂灬吙嘵酥:BAAALAADCgYIBgAAAA==.',['狂奔']='狂奔不回头:BAACLAAFFH9KAAIIAAYIOSNSEwD2AQAIAAYIOSNSEwD2AQAsAAQKfxsAAggACAi7IX8wALECAAgACAi7IX8wALECAAEsAAUUCAgIAAgA8BkA.',['狂怒']='狂怒:BAABLAAFFH8IAAIYAAYIHxpOFAC5AQAYAAYIHxpOFAC5AQAAAA==.',['狡猾']='狡猾的兔子:BAAALAAECgQIBAAAAA==.',['独版']='独版小贝:BAAALAAECgYICgAAAA==.',['猎之']='猎之舞:BAAALAAECggIEgAAAA==.',['猪鼓']='猪鼓励:BAABLAAFFH8GAAIJAAIICAQvOQAmAAAJAAIICAQvOQAmAAAAAA==.',['猫小']='猫小软:BAABLAAFFH8MAAIWAAYIqBcVDQB1AQAWAAYIqBcVDQB1AQAAAA==.',['猫猫']='猫猫咪丫:BAAALAAECgYICgAAAA==.',['玉王']='玉王手面雷:BAAALAAECgQIBAAAAA==.',['王者']='王者降临:BAACLAAFFH9JAAIJAAYIUiLQBQDuAQAJAAYIUiLQBQDuAQAsAAQKfx0AAwkACAjjJAYMAOwCAAkACAjjJAYMAOwCABgAAwg6HfxcAAABAAAA.',['琉瑜']='琉瑜不是榴莲:BAAALAAECgYIBgAAAA==.',['甜心']='甜心戦士:BAACLAAFFH8JAAILAAMIkB4eJQDMAAALAAMIkB4eJQDMAAAsAAQKfx0AAgsACAhbJccFAGoDAAsACAhbJccFAGoDAAAA.',['由我']='由我来平衡丶:BAAALAAECgQIBAAAAA==.',['番茄']='番茄牛肉煲:BAAALAAECgIIAgAAAA==.',['疯癫']='疯癫到巅峰:BAAALAAECgYICAAAAA==.',['白衣']='白衣不染尘:BAAALAAECgYIBwAAAA==.',['百变']='百变萌叔:BAAALAAECgcIEwAAAA==.',['盒子']='盒子的小蓉蓉:BAAALAAECgMIAwAAAA==.',['盗女']='盗女有熊:BAAALAAECgQIBAAAAA==.',['真不']='真不愧是我:BAABLAAECn8bAAIZAAgIXxTRFQAVAgAZAAgIXxTRFQAVAgAAAA==.',['砍死']='砍死一切:BAABLAAECn8TAAIIAAgIyiKyGQAJAwAIAAgIyiKyGQAJAwAAAA==.',['破如']='破如防:BAACLAAFFH8GAAILAAIInhRVQgCXAAALAAIInhRVQgCXAAAsAAQKfxwAAgsABgjzIGxmAPsBAAsABgjzIGxmAPsBAAAA.',['碎星']='碎星:BAAALAAECgYIBwAAAA==.',['碧蓝']='碧蓝:BAAALAAFFAIIBAAAAA==.',['神龙']='神龙大俠:BAAALAADCggICgAAAA==.',['秀宇']='秀宇:BAAALAAECgYIDQAAAA==.',['科比']='科比布莱恩特:BAABLAAFFH8OAAIPAAQIEiACEwAhAQAPAAQIEiACEwAhAQAAAA==.',['穿洋']='穿洋裙的勋爵:BAAALAAFFAIIBAAAAA==.',['站在']='站在我后边:BAAALAAFFAIIBAAAAA==.',['笨笨']='笨笨月亮:BAAALAAECgcICgAAAA==.',['索斯']='索斯爵士:BAAALAAFFAIIAgAAAA==.',['红将']='红将:BAAALAAECgUIDQAAAA==.',['红灬']='红灬莲:BAAALAAECgYIEQAAAA==.',['红烧']='红烧地瓜:BAABLAAECn8UAAIBAAgIDRjKPQBCAgABAAgIDRjKPQBCAgABLAAFFAUIGAAQAL8XAA==.',['纯恋']='纯恋:BAAALAAFFAIIAgABLAAFFAMIBgADAC4RAA==.',['纯爱']='纯爱丶米迦勒:BAAALAADCgEIAQAAAA==.',['细嗅']='细嗅蔷薇:BAAALAAECgIIAgAAAA==.',['绘梨']='绘梨衣:BAAALAADCgYIBgAAAA==.',['缘起']='缘起缘散:BAAALAAECgQIBAAAAA==.',['肚子']='肚子丨:BAABLAAECn8eAAQNAAgIVSI1JgBOAgANAAYIGCM1JgBOAgADAAcIeRoFFQALAgARAAIIYgozNQBPAAAAAA==.肚子丶:BAAALAAECgcICgABLAAECggIHgANAFUiAA==.',['胭珈']='胭珈凌雪:BAACLAAFFH8RAAIVAAMIxg8eLADhAAAVAAMIxg8eLADhAAAsAAQKfykAAxUACAg2GpE9AFQCABUACAh+GZE9AFQCABQABghuGtBAAG0BAAAA.',['脆脆']='脆脆鲨:BAABLAAECn8YAAIPAAgILBrqVgA/AgAPAAgILBrqVgA/AgAAAA==.',['致命']='致命一箭:BAAALAAFFAIIAgAAAA==.',['舔狗']='舔狗:BAAALAAECgYIEgAAAA==.',['舞葉']='舞葉丶:BAAALAAECgYIBgAAAA==.',['艳鱼']='艳鱼鱼:BAAALAADCgIIAgAAAA==.',['芒果']='芒果布丁丶:BAAALAAECgIIAgAAAA==.',['芝心']='芝心丶:BAABLAAFFH8OAAIBAAgI3xbDDQArAgABAAgI3xbDDQArAgAAAA==.',['苹果']='苹果贼:BAACLAAFFH8GAAIeAAIIFRv5EQBRAAAeAAIIFRv5EQBRAAAsAAQKfxoABB4ABghVGzQZANABAB4ABghVGzQZANABAB8AAgjEEk5hAHgAACIAAgiWCf8bAGEAAAAA.',['范德']='范德萨:BAAALAADCgIIAgAAAA==.',['菜狗']='菜狗:BAACLAAFFH8HAAIWAAIIxCX0DADUAAAWAAIIxCX0DADUAAAsAAQKfxsAAxYACAjaJWUCAFgDABYACAjaJWUCAFgDACMABAjHHgtGABEBAAAA.',['菲胡']='菲胡:BAABLAAFFH8LAAMIAAMIIw7wXACWAAAIAAMIIw7wXACWAAASAAII7AGQFgBVAAAAAA==.',['萌丶']='萌丶米迦勒:BAAALAAECggICAAAAA==.',['萌塔']='萌塔基丨钢蛋:BAAALAAECgQIBAAAAA==.',['萌萌']='萌萌的小客官:BAAALAADCggIGAAAAA==.',['落叶']='落叶寒冰:BAAALAAECgYIBgAAAA==.',['蒙面']='蒙面光头:BAAALAAECgYICgAAAA==.',['蒸饺']='蒸饺丶:BAABLAAFFH8SAAIQAAYIThRaGgCKAQAQAAYIThRaGgCKAQAAAA==.',['蓝斯']='蓝斯洛:BAAALAAFFAIIAgAAAA==.',['蕾姆']='蕾姆:BAABLAAFFH8GAAMLAAYI8wBxUQBIAAALAAUI3QBxUQBIAAAMAAEIXgHJGwAXAAAAAA==.',['薇儿']='薇儿丶:BAACLAAFFH8HAAIGAAQIagUJLADHAAAGAAQIagUJLADHAAAsAAQKfxUAAgYABwgYEmNOAJwBAAYABwgYEmNOAJwBAAAA.',['薇唲']='薇唲:BAAALAAFFAIIAgAAAA==.',['薇薇']='薇薇:BAAALAAECgMIBAAAAA==.',['蘇丶']='蘇丶:BAABLAAFFH8IAAIIAAQIlBjASwCkAAAIAAQIlBjASwCkAAABLAAFFAYIOQABAN4lAA==.',['虚弱']='虚弱肥宅:BAAALAADCggICAAAAA==.',['蜻蜓']='蜻蜓队长:BAACLAAFFH8cAAMPAAYIWCVJBAAqAgAPAAYIWCVJBAAqAgAOAAEI1QIOKgBAAAAsAAQKfxcAAg8ACAi7Jn4SAC8DAA8ACAi7Jn4SAC8DAAAA.',['血色']='血色永恒:BAAALAAECgEIAQAAAA==.',['裂創']='裂創丶:BAABLAAFFH8FAAIBAAUIEgT1VgBLAAABAAUIEgT1VgBLAAAAAA==.',['裆里']='裆里冒出圣光:BAAALAAFFAIIAgAAAA==.',['让你']='让你三招:BAAALAAECgcIBwAAAA==.',['诠释']='诠释东锅锅:BAAALAAECgYIDAAAAA==.',['贝蒂']='贝蒂:BAABLAAFFH8KAAIEAAYIUwepXgDKAAAEAAYIUwepXgDKAAAAAA==.',['贫尼']='贫尼光天化日:BAAALAAECgYIEgAAAA==.',['赤座']='赤座灯里:BAAALAAECggIEgAAAA==.',['赫拉']='赫拉克斯:BAAALAAECgYICQAAAA==.',['趙灬']='趙灬子灬龍:BAAALAADCgMIAwAAAA==.',['路西']='路西法丶晨星:BAABLAAFFH8GAAIVAAIIrxSRRQCaAAAVAAIIrxSRRQCaAAABLAAFFAMIBgADAC4RAA==.路西法晨星:BAAALAAFFAIIBAABLAAFFAMIBgADAC4RAA==.',['踮脚']='踮脚吃个个:BAABLAAECn8UAAIHAAgIThoUGwAeAgAHAAgIThoUGwAeAgAAAA==.',['轩辕']='轩辕水狂风:BAACLAAFFH8FAAIQAAMI+BA3QwCdAAAQAAMI+BA3QwCdAAAsAAQKfxkAAhAACAhfG9MoAG4CABAACAhfG9MoAG4CAAAA.',['软脚']='软脚虾妮扣:BAAALAADCgUIBQAAAA==.',['迷你']='迷你棒棒糖:BAABLAAECn8XAAIQAAYIjg/xUgARAQAQAAYIjg/xUgARAQAAAA==.',['逐丶']='逐丶星辰:BAAALAAECgUIBQAAAA==.',['逐风']='逐风者之哀伤:BAAALAADCgMIAwAAAA==.逐风者之影:BAAALAAECgYICwAAAA==.',['那落']='那落伽:BAABLAAFFH8GAAMYAAII9iETIQDBAAAYAAII9iETIQDBAAAJAAII8AcUKgBpAAABLAAFFAMIBgADAC4RAA==.',['邮电']='邮电部诗人:BAAALAAECgYIBgAAAA==.',['酷酷']='酷酷迪达拉:BAAALAAECgUIBQAAAA==.',['锤神']='锤神之喵喵:BAAALAAECgUIBwAAAA==.',['阳光']='阳光薄荷:BAACLAAFFH9FAAQcAAYIHxmnCQCJAQAcAAYIHxmnCQCJAQAkAAUIeAsUBABqAQAbAAMIoANtEQCcAAAsAAQKfxoABCQACAhpGWYLALIBACQABggiGWYLALIBABwACAhxF2QYADgBABsABggpCI0vAOQAAAAA.',['阳角']='阳角:BAAALAAECgQIBAAAAA==.',['阿本']='阿本:BAABLAAECn8YAAMBAAgIKRIpawCzAQABAAcI4RIpawCzAQAdAAMIzAodeQCVAAAAAA==.',['阿璃']='阿璃丶:BAAALAAECggIEAAAAA==.',['隐杀']='隐杀者乄风:BAAALAAECgUIBQAAAA==.',['雪翼']='雪翼邪影:BAAALAAECgYIBgAAAA==.',['雷加']='雷加尔:BAABLAAFFH8LAAMQAAIISh+NKACzAAAQAAIISh+NKACzAAATAAIInw9vQwBFAAAAAA==.',['雷萨']='雷萨:BAAALAADCggICQAAAA==.',['震电']='震电:BAAALAADCgYIBgAAAA==.',['青春']='青春的忧伤:BAAALAAECggICAAAAA==.',['非胡']='非胡:BAABLAAFFH8FAAIMAAMIqQ+kDABvAAAMAAMIqQ+kDABvAAAAAA==.',['面包']='面包牛奶:BAAALAAFFAEIAQAAAA==.',['颓废']='颓废的耶酥:BAABLAAECn8aAAMFAAcI/xi/NADsAQAFAAcI/xi/NADsAQAEAAIIIA4+gAFbAAAAAA==.',['風魇']='風魇灬丶:BAACLAAFFH8JAAIQAAII4BVKOQCOAAAQAAII4BVKOQCOAAAsAAQKfzUAAhAACAiyG20oAHACABAACAiyG20oAHACAAAA.',['风丶']='风丶影:BAAALAADCgIIAgAAAA==.',['风入']='风入疏竹:BAACLAAFFH8YAAINAAUIbhIwHABIAQANAAUIbhIwHABIAQAsAAQKfxwAAg0ACAhuHF4gAG0CAA0ACAhuHF4gAG0CAAAA.',['风吹']='风吹乱我的发:BAAALAADCggICAAAAA==.',['风如']='风如火:BAAALAAFFAIIAwAAAA==.',['风掠']='风掠四季:BAAALAAFFAQIBAAAAA==.',['风暴']='风暴恶灵:BAABLAAECn8bAAIBAAYIExwKLQCdAQABAAYIExwKLQCdAQAAAA==.',['风行']='风行姐:BAAALAAFFAIIAwAAAA==.',['飞翔']='飞翔的荷兰牛:BAAALAAFFAIIAgAAAA==.',['饭桶']='饭桶:BAABLAAECn8WAAMIAAcIYiRiPwCCAgAIAAcIYiRiPwCCAgAZAAEIXyCtWABGAAAAAA==.',['高科']='高科技:BAACLAAFFH8KAAIYAAIIqBdtLgCgAAAYAAIIqBdtLgCgAAAsAAQKfxcAAhgABwiPHRc0AGUCABgABwiPHRc0AGUCAAAA.',['魔德']='魔德丶:BAABLAAFFH8GAAMCAAYI2A+hGgACAQACAAUI9A6hGgACAQANAAEIoA0pWgA7AAAAAA==.',['魔王']='魔王女神:BAAALAAECgYIBgAAAA==.',['鹑宁']='鹑宁:BAAALAAFFAMIAwAAAA==.',['鹿鹿']='鹿鹿丑丑花花:BAAALAAFFAIIAgAAAA==.',['黍离']='黍离丶:BAAALAAFFAIIAgAAAA==.',['黑手']='黑手先锋军:BAAALAAECgUIBQAAAA==.',['黑暗']='黑暗游俠:BAABLAAFFH8GAAIEAAIIVRvdVQCSAAAEAAIIVRvdVQCSAAAAAA==.黑暗狂暴姝:BAAALAAFFAIIAgAAAA==.黑暗遊侠:BAAALAAECgYIBwAAAA==.',['黑白']='黑白电视机:BAAALAADCgMIAwAAAA==.',['黑盅']='黑盅:BAAALAAFFAIIBAAAAA==.',['黑色']='黑色油膜:BAAALAAFFAIIAgAAAA==.',['黯觞']='黯觞:BAAALAAFFAIIBAAAAA==.',['龙影']='龙影渡客:BAAALAAECgUICQABLAAECggIHgANAFUiAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end