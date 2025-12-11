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
 local lookup = {'Paladin-Retribution','Warrior-Fury','Warrior-Protection','Warrior-Arms','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Priest-Holy','DeathKnight-Frost','Evoker-Augmentation','Evoker-Devastation','Monk-Windwalker','Rogue-Assassination','Mage-Arcane','Monk-Brewmaster','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Druid-Restoration','Shaman-Elemental','Shaman-Restoration','DemonHunter-Vengeance','DeathKnight-Blood','DeathKnight-Unholy','Mage-Frost','Mage-Fire','Monk-Mistweaver','Rogue-Subtlety','Priest-Shadow','Druid-Balance','Paladin-Holy','Druid-Guardian','Paladin-Protection','Druid-Feral','Unknown-Unknown','Priest-Discipline','Rogue-Outlaw',}; local provider = {region='CN',realm='布莱恩',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alina:BAABLAAECn8UAAIBAAYI5xwrQgCVAQABAAYI5xwrQgCVAQAAAA==.Alive:BAAALAAECgYICwAAAA==.Altria:BAACLAAFFH8OAAMCAAQI2hnmKwAEAQACAAQI2hnmKwAEAQADAAIIjA2BIwB3AAAsAAQKfx4ABAQABggoHRURAMMBAAQABghLGRURAMMBAAIABghFGNxmAMIBAAMAAQi3DpiWADYAAAEsAAUUBQgaAAUA2hoA.',Ar='Arii:BAACLAAFFH8LAAMGAAIIZg7LoAA+AAAGAAIIZg7LoAA+AAAHAAEIoAVzGwAvAAAsAAQKfygABAcACAizIIwpACoCAAcACAjtHIwpACoCAAYACAiCGnhSAJ8BAAgAAgi4B+4iAFIAAAAA.',Ca='Caesar:BAABLAAFFH8HAAMGAAUIGRSrUQAIAQAGAAUIGRSrUQAIAQAIAAEIJRiaBwBUAAAAAA==.Casilas:BAAALAAECgMIAwAAAA==.',Cr='Crime:BAAALAAECgYIEAAAAA==.',Di='Diina:BAAALAAECgYIBgAAAA==.',Du='Ducati:BAAALAAECgYIEAAAAA==.',Fa='Famahada:BAACLAAFFH81AAIFAAcI+BotDQD8AQAFAAcI+BotDQD8AQAsAAQKfykAAgUACAjAIWgjANMCAAUACAjAIWgjANMCAAAA.',Fi='Fingerto:BAABLAAECn8cAAMGAAcIzRidYwB7AQAGAAcIzRidYwB7AQAHAAUISw7qfQDiAAAAAA==.',Gi='Gifty:BAABLAAFFH8KAAIJAAIIaA07NgCGAAAJAAIIaA07NgCGAAAAAA==.',Ha='Hanamaki:BAAALAAECgYIEgAAAA==.',Ho='Houraisan:BAAALAAFFAIIAgAAAA==.',Jc='Jchc:BAABLAAFFH8GAAIKAAIIthycfQBHAAAKAAIIthycfQBHAAAAAA==.',Js='Jsts:BAABLAAFFH8GAAICAAIIiw4dSQBKAAACAAIIiw4dSQBKAAAAAA==.',Ka='Kakamie:BAACLAAFFH9KAAMLAAgIpx+eAQBhAgALAAgIZh6eAQBhAgAMAAUIDx9SCgBxAQAsAAQKfzQAAgwACAg/JfoDAEwDAAwACAg/JfoDAEwDAAAA.Kakamis:BAACLAAFFH8KAAINAAQITRTVDQDaAAANAAQITRTVDQDaAAAsAAQKfyAAAg0ABgh3I9MWAFoCAA0ABgh3I9MWAFoCAAEsAAUUCAhKAAsApx8A.Karuiy:BAAALAAFFAIIAgAAAA==.',Li='Linabell:BAAALAADCgMIAwAAAA==.',Ls='Ls:BAAALAAECgcIBwAAAA==.',Lu='Luteinizing:BAAALAAECggIEAAAAA==.',Nh='Nhtw:BAAALAADCgQIBAAAAA==.',Ni='Nitro:BAAALAAECgYIDwAAAA==.',Pg='Pg:BAABLAAFFH8FAAIOAAIIVRFjGgCWAAAOAAIIVRFjGgCWAAABLAAFFAgIBgAPADsOAA==.',Pl='Playerkkvowd:BAAALAAECgIIAgAAAA==.',Re='Redhandslol:BAAALAADCgMIAwAAAA==.',Ro='Root:BAAALAAECgYIBgAAAA==.',Sa='Sakur:BAAALAADCgEIAQAAAA==.Samaelquiet:BAAALAAFFAIIBAAAAA==.',Sh='Shootingstar:BAAALAADCgcICAAAAA==.',Sn='Snakeql:BAAALAADCgEIAQAAAA==.',Su='Suemac:BAABLAAECn8oAAICAAgI9RqsGQAWAgACAAgI9RqsGQAWAgAAAA==.',Um='Umbreon:BAAALAADCggICAAAAA==.',Ya='Yakiihu:BAACLAAFFH9cAAIQAAgIlSToAADWAgAQAAgIlSToAADWAgAsAAQKfzsAAhAACAjMJQQCAGADABAACAjMJQQCAGADAAAA.Yamahada:BAABLAAFFH8UAAIRAAYILg7rLgBeAQARAAYILg7rLgBeAQAAAA==.',Yi='Yiyi:BAAALAAECgEIAQAAAA==.',['一只']='一只老鸽子:BAABLAAFFH8HAAQRAAMIqgthLQDPAAARAAMIqgthLQDPAAASAAII9AbbBAB9AAATAAEIZwixLwBDAAAAAA==.',['一叶']='一叶随风:BAAALAAFFAIIAgAAAA==.一叶飘零:BAABLAAFFH8FAAIBAAIITRurWABKAAABAAIITRurWABKAAAAAA==.',['一梦']='一梦一归期:BAAALAAECggIBgAAAA==.一梦一瑾年:BAAALAAECggIEAAAAA==.',['一箭']='一箭闯天涯:BAAALAADCgYIBgAAAA==.',['一路']='一路咕咕:BAAALAAECgIIAwAAAA==.一路哀愁:BAAALAAECgEIAQAAAA==.',['一颗']='一颗小菠菜:BAAALAAFFAIIAgAAAA==.',['一骑']='一骑绝尘风:BAABLAAFFH8PAAIGAAcIQAQfRwAuAQAGAAcIQAQfRwAuAQAAAA==.',['七十']='七十二变:BAAALAAECgUIBQAAAA==.',['七皇']='七皇:BAAALAAECgUIBQAAAA==.',['万象']='万象天引:BAAALAAECggICAAAAA==.',['三又']='三又三分之一:BAAALAADCgEIAQAAAA==.',['三月']='三月:BAAALAAECgYICwAAAA==.',['三鹰']='三鹰朝:BAAALAAECgYIDAAAAA==.',['上帝']='上帝:BAAALAAECgIIAgAAAA==.',['不死']='不死战神:BAABLAAFFH8KAAIKAAII+g1efQBHAAAKAAII+g1efQBHAAAAAA==.',['不许']='不许喂猫呀丶:BAAALAAECgYIBgAAAA==.',['中岛']='中岛由贵:BAABLAAFFH8HAAMLAAYITwG7CwCSAAALAAQIvQC7CwCSAAAMAAIIcwLUJAApAAAAAA==.',['中指']='中指好痛:BAAALAAECgUIBQAAAA==.',['丰汝']='丰汝肥臀:BAAALAADCggIBQAAAA==.',['丶刺']='丶刺玫瑰丶:BAAALAAECggIDwAAAA==.',['丶喵']='丶喵呜喵呜:BAAALAAFFAIIAgAAAA==.',['丶夜']='丶夜玫瑰丶:BAABLAAFFH8IAAICAAII7RVqQwBQAAACAAII7RVqQwBQAAAAAA==.',['丶黑']='丶黑玫瑰丶:BAABLAAFFH8FAAIUAAIICAggQABgAAAUAAIICAggQABgAAAAAA==.',['丷爱']='丷爱似水仙丷:BAAALAAFFAIIBAAAAA==.',['为什']='为什么是蹄子:BAABLAAFFH8LAAMVAAMI3RayMgCVAAAVAAMI3RayMgCVAAAWAAIItQgoXQBiAAABLAAFFAUIGgAFANoaAA==.',['义人']='义人:BAAALAAECgEIAQAAAA==.',['乐乐']='乐乐十世:BAAALAADCgUIBQAAAA==.',['九天']='九天战神:BAACLAAFFH8QAAIDAAIIZhWJIAB9AAADAAIIZhWJIAB9AAAsAAQKfzcAAwMACAjJHDIVAJ4BAAMACAjJHDIVAJ4BAAIAAwgMEQiaAEoAAAAA.',['了然']='了然:BAAALAAECggICAAAAA==.',['云巅']='云巅之上:BAAALAAECgUICQAAAA==.',['五分']='五分之一狼:BAAALAAECgYICQAAAA==.',['五十']='五十铃华:BAAALAADCgYIBgAAAA==.',['亦剣']='亦剣:BAACLAAFFH8NAAIDAAIIsQ3ILwAzAAADAAIIsQ3ILwAzAAAsAAQKfxQAAwIACAhZFWJXAOsBAAIACAi+E2JXAOsBAAMAAwilD8d7AJcAAAEsAAUUAggPABcA6wwA.',['优雅']='优雅的沉沦:BAAALAAECgEIAQAAAA==.优雅的牛牛:BAAALAAECgIIAgAAAA==.',['传火']='传火:BAAALAAECgYICAAAAA==.',['传说']='传说般的神棍:BAAALAAECgYIBgAAAA==.',['伤了']='伤了我的心:BAAALAADCggICQAAAA==.',['借风']='借风吻你:BAAALAAECgMIAwAAAA==.',['傀儡']='傀儡小鼠:BAAALAAECgUICAAAAA==.',['傲世']='傲世灬神射手:BAAALAAECgMICAAAAA==.',['傲特']='傲特慢:BAAALAAECgQIBgAAAA==.',['克里']='克里斯滕丽特:BAAALAAFFAIIBAAAAA==.',['全是']='全是肉肉呀:BAAALAAECgIIAgAAAA==.',['全能']='全能之手:BAAALAAFFAIIAgAAAA==.',['典丨']='典丨韦:BAAALAAECgIIAgAAAA==.',['军爺']='军爺:BAAALAAECgUIBQAAAA==.',['冰之']='冰之灵魂:BAABLAAECn8aAAMKAAcI0w3bVwBCAQAKAAcITAzbVwBCAQAYAAEIXBMYMAA6AAAAAA==.',['冰河']='冰河葬寒心:BAACLAAFFH8TAAIZAAYIYhQ3AwCbAQAZAAYIYhQ3AwCbAQAsAAQKfxcAAxkACAgNILILAJcCABkACAgNILILAJcCAAoAAQjIBqenAS0AAAAA.',['冰菲']='冰菲:BAAALAAECgIIAgAAAA==.',['冲钅']='冲钅丶迁坟:BAABLAAFFH8RAAIDAAUIjxJhCABnAQADAAUIjxJhCABnAQAAAA==.',['冷色']='冷色:BAAALAAECgQIBAAAAA==.',['凉宫']='凉宫夏绪:BAAALAADCgYIBgAAAA==.',['凤吹']='凤吹三花开:BAAALAAECgMIAwAAAA==.',['凯米']='凯米尔酷:BAAALAADCgEIAQAAAA==.',['凯鲨']='凯鲨:BAACLAAFFH8QAAIPAAII4hc2RACbAAAPAAII4hc2RACbAAAsAAQKfy0ABA8ACAioHpE+AFACAA8ACAioHZE+AFACABoABwgNGkMmAPMBABsAAQgGB58lAC4AAAAA.',['刺探']='刺探你的温柔:BAAALAAECgQIBgAAAA==.',['剑破']='剑破长风:BAAALAAFFAIIAgAAAA==.',['剑箭']='剑箭丶:BAAALAAECgQIBQAAAA==.',['剡溟']='剡溟:BAABLAAECn8jAAIcAAgIpCSECQDNAgAcAAgIpCSECQDNAgAAAA==.',['勇敢']='勇敢的火柴:BAABLAAFFH8GAAIRAAYIlBmkCgAdAgARAAYIlBmkCgAdAgAAAA==.',['北雁']='北雁当寄红翎:BAABLAAFFH8NAAIGAAUIIQ/UWwDWAAAGAAUIIQ/UWwDWAAABLAAFFAYIEwAZAGIUAA==.',['十万']='十万伏特毛妹:BAAALAAFFAIIAgAAAA==.',['十年']='十年术木:BAACLAAFFH8WAAMRAAUIZBwOMgBPAQARAAUImhsOMgBPAQATAAEIXSBgIgBdAAAsAAQKfyUAAxEACAiWIN0XAPgCABEACAh+IN0XAPgCABMABAhaIVxHAFIBAAAA.',['千钧']='千钧一发:BAACLAAFFH8dAAMOAAUI6hc2DQD9AAAOAAUI6hc2DQD9AAAdAAIIsw9RFgCAAAAsAAQKfx8AAw4ABwimHFMkAPYBAA4ABgj0HFMkAPYBAB0ABAg7FskzAAIBAAAA.',['卡德']='卡德迦:BAAALAAECgYIBgAAAA==.',['去而']='去而复返:BAABLAAECn8gAAIFAAcIphZmZgD7AQAFAAcIphZmZgD7AQAAAA==.',['受死']='受死:BAAALAAFFAIIAgAAAA==.',['只因']='只因泥太煤:BAAALAAECgYIBgAAAA==.',['可乐']='可乐泡枸杞:BAAALAAECgYIBgAAAA==.',['叶随']='叶随风:BAABLAAFFH8OAAIGAAMI0hb9RwCcAAAGAAMI0hb9RwCcAAAAAA==.',['向日']='向日葵:BAAALAAECgIIAwAAAA==.',['听风']='听风不是雨啊:BAABLAAFFH8pAAIBAAYIcBovFACpAQABAAYIcBovFACpAQAAAA==.',['吾歆']='吾歆:BAABLAAECn8UAAIBAAYI/hUwtwCUAQABAAYI/hUwtwCUAQAAAA==.',['告白']='告白气球:BAAALAADCgMIAwAAAA==.',['咙逗']='咙逗逗:BAAALAAECgIIAgAAAA==.',['咚锵']='咚锵咚锵:BAABLAAFFH8FAAIJAAUIZg5uIQA6AQAJAAUIZg5uIQA6AQAAAA==.',['哀木']='哀木涕拉好怪:BAAALAAECgUIBQAAAA==.',['哮天']='哮天狗子琳:BAAALAAFFAIIAgAAAA==.',['啊克']='啊克丶萌德:BAABLAAFFH8vAAIeAAYItxzjCQC1AQAeAAYItxzjCQC1AQAAAA==.',['啊我']='啊我瞎啦:BAACLAAFFH8JAAMFAAUIKQ6PMAARAQAFAAUIKQ6PMAARAQAXAAIIIA13FgApAAAsAAQKfxgAAgUABgiGH3dXAB8CAAUABgiGH3dXAB8CAAEsAAUUBwg1ABYAAxsA.',['啊灭']='啊灭火啦:BAACLAAFFH81AAMWAAcIAxt1CQCmAQAWAAcIAxt1CQCmAQAVAAUIqhcNDwCQAQAsAAQKfyIAAxYACAj5H2QiAIkCABYACAj5H2QiAIkCABUABwi0IAorAGYCAAAA.',['啼不']='啼不是武僧:BAAALAAECgYIDwAAAA==.',['喔呜']='喔呜喔丶:BAAALAAECgEIAQAAAA==.',['喵熊']='喵熊:BAAALAADCgQIBAAAAA==.',['嗨山']='嗨山羊:BAAALAAECgMIAwAAAA==.',['嗯嗯']='嗯嗯对:BAAALAAFFAMIAwAAAA==.',['嘚嘚']='嘚嘚德:BAABLAAFFH8HAAMUAAYIkAjXMQCiAAAUAAQIiAbXMQCiAAAfAAIIOw1NNAA8AAAAAA==.',['噬渊']='噬渊行者:BAAALAAECgYIBgAAAA==.',['回到']='回到过去:BAAALAADCgEIAQAAAA==.',['团子']='团子:BAAALAADCggICAAAAA==.',['圣光']='圣光将熄:BAABLAAFFH8HAAIgAAMITA1YHgCvAAAgAAMITA1YHgCvAAABLAAFFAYIEwAZAGIUAA==.',['地狱']='地狱不是天堂:BAAALAAECgYIBgAAAA==.',['复仇']='复仇:BAACLAAFFH85AAMPAAcIMCAxDQAZAgAPAAcIMCAxDQAZAgAbAAEIgwyvDABEAAAsAAQKfyAABA8ACAjrISciAMYCAA8ACAjrISciAMYCABsAAQiqHT4gAD8AABoAAQi6FMORADgAAAAA.',['多莉']='多莉的擁抱:BAACLAAFFH9cAAIXAAgIKh9cAACMAgAXAAgIKh9cAACMAgAsAAQKfzsAAhcACAj9JSYCAGADABcACAj9JSYCAGADAAAA.',['夜染']='夜染衣:BAAALAADCgEIAQAAAA==.',['夜梦']='夜梦花星雨:BAAALAAECgEIAQAAAA==.',['夜澜']='夜澜听雪:BAABLAAFFH8GAAIhAAYIlwCyEgAKAAAhAAYIlwCyEgAKAAAAAA==.',['大精']='大精西:BAAALAAECgYICwAAAA==.',['大藏']='大藏里想奈:BAAALAAFFAIIBAAAAA==.',['大迪']='大迪克:BAAALAAECgMIAwAAAA==.',['天下']='天下無敌:BAABLAAECn8YAAINAAYILCTXCQALAgANAAYILCTXCQALAgAAAA==.',['天使']='天使妹妹:BAAALAAECgIIAgAAAA==.',['天剑']='天剑绝刀:BAAALAAECggICAAAAA==.',['天启']='天启骑士:BAAALAAECgYIDAAAAA==.',['天海']='天海:BAABLAAFFH8JAAINAAUIqQ6WCwAdAQANAAUIqQ6WCwAdAQABLAAFFAYIEwAZAGIUAA==.',['天然']='天然呆:BAAALAADCgUIBQAAAA==.',['天霜']='天霜无垢:BAAALAAECgQIBAAAAA==.',['头上']='头上有犄角:BAACLAAFFH8aAAIFAAUI2hpaJgBdAQAFAAUI2hpaJgBdAQAsAAQKfx8AAgUABwhNIbAyAJECAAUABwhNIbAyAJECAAAA.',['头壳']='头壳空空:BAAALAAECgEIAQAAAA==.',['奶糖']='奶糖的复仇:BAAALAAECgUIBQAAAA==.',['她也']='她也有难处:BAABLAAFFH8GAAIGAAIItBMPUACWAAAGAAIItBMPUACWAAAAAA==.',['妇女']='妇女之友:BAAALAAECgYIBgAAAA==.',['妳的']='妳的名字:BAAALAADCgQIBAAAAA==.',['娘杀']='娘杀个闲腿:BAAALAADCggICAAAAA==.',['嬛嬛']='嬛嬛:BAACLAAFFH8GAAIKAAIIfyDQUQCgAAAKAAIIfyDQUQCgAAAsAAQKfxwAAwoACAhzJbUgAO0CAAoACAhzJbUgAO0CABkABggMF8UyADcBAAAA.',['孤单']='孤单想起谁:BAAALAAECgIIAgAAAA==.',['安静']='安静丶丶:BAABLAAECn8UAAIDAAcIuRW8OQChAQADAAcIuRW8OQChAQAAAA==.安静的搞钱:BAABLAAECn8cAAIiAAYIQh02JgDPAQAiAAYIQh02JgDPAQAAAA==.',['宸朵']='宸朵:BAAALAAECgQIBAAAAA==.',['寂灭']='寂灭者阿古斯:BAAALAAFFAQIBAAAAA==.',['寒山']='寒山石径斜:BAAALAAECggICAAAAA==.',['对影']='对影:BAAALAADCggICAAAAA==.',['小丑']='小丑龙:BAACLAAFFH8yAAMMAAcIBCboAgBXAgAMAAcIBCboAgBXAgALAAYI4iOdAwDSAQAsAAQKfygAAgwACAjSJdUBAG4DAAwACAjSJdUBAG4DAAAA.',['小小']='小小飞马:BAAALAAFFAIIAgAAAA==.',['小德']='小德:BAAALAAFFAIIAgAAAA==.',['小手']='小手火热热丶:BAAALAAECgYIBgABLAAECggIIQAVAA0SAA==.',['小笑']='小笑豆豆:BAAALAADCgEIAQAAAA==.',['小菜']='小菜鸟来也:BAAALAAECgYIBgAAAA==.',['小落']='小落落:BAAALAAECgUICAAAAA==.',['小蘑']='小蘑菇灬春天:BAAALAAFFAIIAgAAAA==.',['小身']='小身材大神通:BAAALAAECgYIBgAAAA==.',['小面']='小面包啊呜:BAAALAADCgIIAgAAAA==.',['就是']='就是玩玩:BAAALAADCgYIBgAAAA==.就是那么拽:BAAALAADCgQIBAAAAA==.',['尼禄']='尼禄:BAACLAAFFH8RAAMKAAYIaxahMQB0AQAKAAYIaxahMQB0AQAYAAIIWgUqHQAtAAAsAAQKfyAAAgoACAgZILYuALcCAAoACAgZILYuALcCAAEsAAUUCAhLABQAthEA.',['山有']='山有木兮:BAAALAAFFAIIAgAAAA==.',['左眼']='左眼跳桃花开:BAAALAAFFAIIBAAAAA==.',['巨型']='巨型科莫多龙:BAAALAAECgYIBgAAAA==.',['布瑞']='布瑞尔的星光:BAAALAAFFAIIBAAAAA==.',['帅炸']='帅炸天:BAAALAAECgYICgAAAA==.',['希尓']='希尓瓦娜丝:BAABLAAFFH8ZAAMHAAYIRyF6CQB0AQAHAAYIRyF6CQB0AQAGAAIIRBRvawCLAAAAAA==.',['幽璃']='幽璃:BAAALAAECgEIAQAAAA==.',['弱娇']='弱娇受:BAAALAAECgYICQAAAA==.',['影风']='影风者:BAAALAADCgUIBQAAAA==.',['德伊']='德伊贝瑞:BAABLAAFFH8JAAIhAAIIuRNsCQBTAAAhAAIIuRNsCQBTAAAAAA==.',['忽悠']='忽悠忽悠法:BAAALAAECgYIBgAAAA==.',['怒灿']='怒灿:BAABLAAFFH8OAAIEAAIIbhybAwCkAAAEAAIIbhybAwCkAAAAAA==.',['总裁']='总裁玩我也玩:BAABLAAFFH8WAAIWAAYIThZSFQC1AQAWAAYIThZSFQC1AQAAAA==.',['惜君']='惜君漂泊心:BAABLAAECn8hAAMJAAYIpgcFhgDwAAAJAAYIpgcFhgDwAAAeAAYI4gkTMgDHAAAAAA==.',['我们']='我们还行吧:BAABLAAECn8fAAIeAAcIvSXxCgAsAgAeAAcIvSXxCgAsAgAAAA==.',['我头']='我头上有只角:BAAALAAECgQIBAAAAA==.',['我是']='我是一个演员:BAAALAAECgcIBwAAAA==.',['我本']='我本属猴:BAAALAAECgMIAwAAAA==.',['我沒']='我沒有鬍子:BAAALAAECgYICwAAAA==.',['我爱']='我爱奶茶:BAAALAAECgcIDAAAAA==.',['戰魂']='戰魂丶小雄:BAAALAAECgMIAgAAAA==.',['扯淡']='扯淡灬:BAAALAAECgEIAQAAAA==.',['抬手']='抬手鸠毛:BAAALAADCgUIBQAAAA==.',['提莫']='提莫队长:BAAALAAECgQIBAAAAA==.',['提里']='提里奥弗丁丶:BAABLAAFFH8GAAIBAAYI5AkkJQBKAQABAAYI5AkkJQBKAQAAAA==.',['揷哥']='揷哥来了:BAACLAAFFH8GAAIBAAIIkRg4UgBRAAABAAIIkRg4UgBRAAAsAAQKfy4AAwEABwhCFXlHAIYBAAEABwhCFXlHAIYBACAABgi4B14uANIAAAAA.',['擎天']='擎天柱力:BAACLAAFFH8OAAIFAAYIZRPlHACRAQAFAAYIZRPlHACRAQAsAAQKfyMAAgUACAi0GXJFAFECAAUACAi0GXJFAFECAAAA.',['擎潮']='擎潮主:BAACLAAFFH86AAMWAAgIeByeAgC8AgAWAAgIeByeAgC8AgAVAAUIFA+mFAAWAQAsAAQKfyYAAxYACAi4GeQ8ACgCABYACAi4GeQ8ACgCABUACAikEBs5ACoBAAAA.',['故湘']='故湘的风:BAABLAAFFH8iAAMKAAgI5RorKACVAQAKAAYItBUrKACVAQAZAAQIhSHKCADaAAAAAA==.',['散夜']='散夜花影:BAABLAAFFH8MAAMBAAYIqA5CKwAoAQABAAYIOwlCKwAoAQAiAAIIbx3SEQCOAAABLAAFFAcINQAWAAMbAA==.',['斩雷']='斩雷:BAAALAAECggICAAAAA==.',['斯卡']='斯卡蒂:BAAALAAECgYIBgAAAA==.',['斯可']='斯可拉:BAAALAAECgYIDAAAAA==.',['无奈']='无奈的小精灵:BAAALAAECgYIBgAAAA==.',['无形']='无形装逼:BAAALAAFFAIIAgAAAA==.',['无玄']='无玄:BAAALAAECgcIEwAAAA==.',['无聊']='无聊的奶妈:BAAALAAECgIIAgAAAA==.',['无鱼']='无鱼伦比:BAABLAAFFH8PAAMGAAUIPBn0IgD1AAAGAAUIPBn0IgD1AAAHAAIIIQzzKAB2AAAAAA==.',['时间']='时间紧任务重:BAAALAAECgYICwAAAA==.',['时雨']='时雨:BAAALAAECggICAAAAA==.',['明明']='明明就:BAAALAADCgYIBgAAAA==.',['星空']='星空凛:BAAALAAECgYIBgAAAA==.',['是眼']='是眼子啊:BAABLAAFFH8sAAMjAAYIrSEBAgDpAQAjAAYIrSEBAgDpAQAfAAEI7BCeMQA/AAAAAA==.',['晓雪']='晓雪:BAAALAAECgYIBgAAAA==.',['晴风']='晴风烟雨:BAAALAAECgYIBgAAAA==.',['暗夜']='暗夜的圣光:BAAALAAECgQIBQAAAA==.',['暗月']='暗月苍狼:BAAALAAFFAIIAgAAAA==.',['暗黑']='暗黑丶幽魂:BAAALAAECgYIBgAAAA==.',['暮雪']='暮雪千山:BAAALAADCgMIAwAAAA==.',['暴风']='暴风星辰:BAABLAAFFH8FAAIVAAMIqhsYIACzAAAVAAMIqhsYIACzAAAAAA==.',['曦风']='曦风月:BAAALAADCgEIAQABLAAECgcIDAAkAAAAAA==.',['有事']='有事稳李锐:BAABLAAFFH8UAAIKAAYICBX0LACFAQAKAAYICBX0LACFAQAAAA==.',['木依']='木依:BAACLAAFFH85AAIRAAcIGiPKCwBEAgARAAcIGiPKCwBEAgAsAAQKfyYABBEACAj9IXoWAAADABEACAj9IXoWAAADABIABQhyF8YWAFkBABMAAQinDdSVAD0AAAAA.',['木公']='木公子:BAACLAAFFH8XAAMgAAYIXBcCDgClAQAgAAYIXBcCDgClAQABAAUIDxDCLAAfAQAsAAQKfxQAAyAABghdGBMwAK8BACAABghdGBMwAK8BAAEABggUFDG6AJABAAAA.',['木宁']='木宁馨:BAABLAAFFH8eAAMYAAcIZBVXBwC4AQAYAAcIJBVXBwC4AQAKAAUIvw8DRwAeAQAAAA==.',['杂毛']='杂毛小鸡:BAAALAADCgQIBAAAAA==.',['杨桃']='杨桃子:BAABLAAFFH8IAAIWAAIIbgu0VQBnAAAWAAIIbgu0VQBnAAAAAA==.',['枪花']='枪花:BAAALAAECgcIDQAAAA==.',['枫之']='枫之林晚:BAAALAADCgIIAgAAAA==.',['枫岚']='枫岚:BAABLAAFFH8IAAIGAAgIkwAZxAAPAAAGAAgIkwAZxAAPAAAAAA==.',['栖月']='栖月:BAAALAAECgYIEgAAAA==.',['橙橙']='橙橙爱果子:BAAALAAECgMIBQAAAA==.',['欧洲']='欧洲大焱焱:BAAALAADCgMIAwAAAA==.',['欧皇']='欧皇丶惩戒骑:BAAALAAECgIIAgAAAA==.欧皇敏敏:BAAALAADCgYIBgAAAA==.欧皇敏爷:BAAALAAFFAIIAgAAAA==.',['正义']='正义裁决者:BAAALAAECgIIAgAAAA==.',['武汉']='武汉特色小吃:BAABLAAECn8XAAIfAAgIRSIdIABhAgAfAAgIRSIdIABhAgABLAAFFAYINwACAF0hAA==.',['死亡']='死亡行者:BAABLAAFFH8HAAIKAAUIZBfqPwA7AQAKAAUIZBfqPwA7AQAAAA==.',['殇纟']='殇纟佷:BAAALAAECgEIAQAAAA==.',['段青']='段青狐:BAAALAAECgEIAQAAAA==.',['水云']='水云长青丶:BAAALAADCgEIAQAAAA==.',['汐汐']='汐汐冰儿:BAAALAAFFAIIAgAAAA==.',['沙加']='沙加:BAAALAAECgYICQAAAA==.',['沧浪']='沧浪:BAABLAAECn8aAAMWAAcI6hzjOgAuAgAWAAcI6hzjOgAuAgAVAAYIDQrciwAfAQAAAA==.',['波可']='波可丨波克:BAABLAAECn8ZAAIDAAYISR77KQD0AQADAAYISR77KQD0AQAAAA==.',['泰莎']='泰莎拉克:BAAALAADCgYIBgAAAA==.',['流星']='流星岛屿:BAAALAAECgYIBgAAAA==.',['流風']='流風回雪:BAABLAAFFH8KAAMOAAIIix5EEQC8AAAOAAIIix5EEQC8AAAdAAEI/AoRHgA+AAAAAA==.',['浅墨']='浅墨未央:BAACLAAFFH8ZAAIBAAcISBLyDwDFAQABAAcISBLyDwDFAQAsAAQKfyMAAgEACAh5HU0yAKkCAAEACAh5HU0yAKkCAAAA.浅墨猪影:BAAALAAECgMIAwABLAAFFAgISwAUALYRAA==.',['浪荡']='浪荡的恶魔:BAAALAAECgYIDAAAAA==.',['海问']='海问香:BAABLAAECn8UAAIDAAYIsBAmTwBFAQADAAYIsBAmTwBFAQAAAA==.',['消磨']='消磨时间:BAAALAAECgYICAAAAA==.',['淺墨']='淺墨未央:BAACLAAFFH9PAAIOAAgIhAqCBACdAQAOAAgIhAqCBACdAQAsAAQKfzEAAg4ACAhEFNQcAC4CAA4ACAhEFNQcAC4CAAAA.',['渡鸦']='渡鸦丶:BAAALAAFFAMIAwAAAA==.',['温蕾']='温蕾萨:BAABLAAFFH8HAAIQAAQIWg2YFwCoAAAQAAQIWg2YFwCoAAAAAA==.',['游荡']='游荡的魔鬼:BAAALAAECgEIAQAAAA==.',['湛蓝']='湛蓝一生:BAAALAAECgYIBgAAAA==.',['湿透']='湿透她衣裳:BAABLAAFFH8IAAIGAAIISRjJTQCXAAAGAAIISRjJTQCXAAAAAA==.',['满眼']='满眼星辰:BAAALAAECgEIAQAAAA==.',['漫漫']='漫漫罗:BAABLAAFFH8JAAIWAAIIBhbnRAB5AAAWAAIIBhbnRAB5AAABLAAFFAUIGgAFANoaAA==.',['火焰']='火焰灬舞者:BAAALAAECgYIBgAAAA==.',['灬喵']='灬喵灬:BAAALAADCgMIAwAAAA==.',['灵魂']='灵魂淡泊者:BAABLAAFFH8MAAIKAAUItxUwRQAmAQAKAAUItxUwRQAmAQAAAA==.',['炼狱']='炼狱修罗斩:BAAALAADCgIIAgAAAA==.',['炽热']='炽热暴徒:BAAALAAECgYIDAAAAA==.',['烈海']='烈海王:BAACLAAFFH81AAINAAgIFh1CAQCCAgANAAgIFh1CAQCCAgAsAAQKfyQAAg0ACAjxJZYEAEUDAA0ACAjxJZYEAEUDAAAA.',['烏哭']='烏哭:BAABLAAFFH8PAAMXAAII6wwEFQAsAAAFAAIITQrpUACLAAAXAAII6wwEFQAsAAAAAA==.',['烟丶']='烟丶茉:BAAALAAECggIDQAAAA==.',['热不']='热不同:BAACLAAFFH8HAAIWAAIIoQ2gYgBYAAAWAAIIoQ2gYgBYAAAsAAQKfxoAAxYACAjaEQJrAK4BABYACAjaEQJrAK4BABUABgiSE6U1ADkBAAAA.',['焰天']='焰天火雨:BAABLAAFFH8MAAMVAAYI1AE8LgDFAAAVAAYI1AE8LgDFAAAWAAIIPBU5UwBpAAAAAA==.',['熊熊']='熊熊不怕疼:BAAALAAECgMIAwAAAA==.',['燃烧']='燃烧的柚子皮:BAABLAAFFH8IAAICAAMIUg3GPAB8AAACAAMIUg3GPAB8AAAAAA==.燃烧的火龙果:BAAALAAECgUIBQAAAA==.',['牛一']='牛一扭:BAAALAADCgYIBgAAAA==.',['狂暴']='狂暴战:BAAALAADCgMIAwAAAA==.',['猎炎']='猎炎:BAAALAAECgYIEgAAAA==.',['猫熊']='猫熊兽:BAAALAAECgUIBAAAAA==.',['猫色']='猫色的橘:BAAALAADCggICAAAAA==.',['玖伍']='玖伍贰丶柒:BAAALAAECgYIBgAAAA==.',['玩具']='玩具枪丶:BAABLAAECn8hAAMVAAgIDRJ2cQBpAQAVAAYIpQ92cQBpAQAWAAQISAWeIAFsAAAAAA==.',['琥珀']='琥珀封印:BAAALAAECggICwAAAA==.',['瑞瓦']='瑞瓦肖:BAAALAAECgIIAgAAAA==.',['白馒']='白馒头:BAABLAAFFH8NAAMlAAIIMQmXBABxAAAlAAIIcAaXBABxAAAJAAIIGAnsQgBlAAAAAA==.',['真红']='真红:BAAALAAECgYIBgAAAA==.',['真纪']='真纪:BAAALAADCgEIAQAAAA==.',['真页']='真页孑亥:BAAALAAFFAIIBAAAAA==.',['瞎掉']='瞎掉的冰:BAABLAAFFH8IAAIFAAYIYhriGACmAQAFAAYIYhriGACmAQAAAA==.',['社会']='社会你二熟:BAACLAAFFH8hAAImAAYI4hhOAQCdAQAmAAYI4hhOAQCdAQAsAAQKfxUAAiYACAioHCUEAKMCACYACAioHCUEAKMCAAAA.',['神丶']='神丶欧皇:BAAALAAECgYIDwAAAA==.',['神隐']='神隐鬼宿:BAAALAADCgYIBgAAAA==.',['秋名']='秋名山河令:BAABLAAFFH8FAAIFAAII6BceNACjAAAFAAII6BceNACjAAAAAA==.',['空帽']='空帽子:BAACLAAFFH8gAAIKAAYIRBOILQCDAQAKAAYIRBOILQCDAQAsAAQKfxwAAgoACAg/FN+bAM0BAAoACAg/FN+bAM0BAAAA.',['笙箫']='笙箫叶落:BAABLAAECn8bAAIWAAYIBRSERQBEAQAWAAYIBRSERQBEAQAAAA==.',['第一']='第一死骑:BAAALAAFFAIIAgAAAA==.',['简单']='简单爱:BAAALAADCgYICgAAAA==.',['米奇']='米奇亚:BAAALAAECgYIDAAAAA==.',['精灵']='精灵术:BAAALAAFFAIIAgAAAA==.精灵的无奈:BAAALAAECgQICAAAAA==.',['紫曦']='紫曦小米粥:BAAALAAECgUIBwAAAA==.',['绘梨']='绘梨依:BAABLAAECn8VAAMPAAYINh3bagDIAQAPAAYINh3bagDIAQAaAAMI6gx1dQCWAAAAAA==.',['绯樱']='绯樱闲:BAACLAAFFH8QAAMRAAIIkRayQwCTAAARAAIIkRayQwCTAAATAAEIPBF/LQBIAAAsAAQKfz4ABBEACAi0HlkaAA4CABEACAiaHVkaAA4CABMABQjXGCVFAFoBABIAAQiOCFA/ADwAAAAA.',['罗曼']='罗曼罗兰德:BAAALAAECgYIDQAAAA==.',['美神']='美神令子:BAABLAAFFH8JAAMgAAMIVgb2FQCtAAAgAAMIVgb2FQCtAAABAAIIZRLxVQBMAAAAAA==.',['翻江']='翻江倒海海:BAAALAADCgYIBgAAAA==.',['老灯']='老灯:BAABLAAFFH8JAAIKAAMI6iIZMwDQAAAKAAMI6iIZMwDQAAAAAA==.',['脆脆']='脆脆角:BAACLAAFFH8UAAMQAAYITyaiBAAgAgAQAAYITyaiBAAgAgANAAII7h3PDACvAAAsAAQKfxoAAxAABgjOJWsMAJUCABAABgidJWsMAJUCAA0ABgiwIpkYAEcCAAEsAAUUBwgyAAwABCYA.',['臭圈']='臭圈:BAAALAAECgYIBgAAAA==.',['舍身']='舍身入魔:BAAALAADCgIIAgAAAA==.',['艾鲁']='艾鲁恩:BAAALAAECgYIDgAAAA==.',['花凋']='花凋惹人怜:BAAALAAECgYICQAAAA==.',['苍天']='苍天:BAAALAAECgYIBgAAAA==.',['苍火']='苍火:BAAALAAFFAIIAwAAAA==.',['若松']='若松美雪:BAAALAAECgYIBgAAAA==.',['草莓']='草莓焗饭:BAAALAAFFAIIAwAAAA==.',['莉莉']='莉莉丫丫:BAAALAADCgYIBgAAAA==.',['莉雅']='莉雅:BAAALAAECgYIBgAAAA==.',['莫得']='莫得法:BAAALAAECgYIEAAAAA==.',['萧瑟']='萧瑟:BAAALAAECgEIAQAAAA==.萧瑟寒风:BAACLAAFFH8NAAIKAAMIJxFFXwCPAAAKAAMIJxFFXwCPAAAsAAQKfx8AAwoACAhqHdcUAEACAAoACAi9HNcUAEACABgABAjtF+sXABIBAAAA.',['落叶']='落叶归风:BAAALAAECgYIBwAAAA==.落叶是我的:BAABLAAFFH8HAAIJAAIIExoVKQCYAAAJAAIIExoVKQCYAAAAAA==.',['落英']='落英:BAAALAAECgYIEgAAAA==.',['蒲公']='蒲公英的约定:BAAALAADCgMIAwAAAA==.',['蓅輦']='蓅輦丶:BAACLAAFFH8kAAIFAAUINR66IwBtAQAFAAUINR66IwBtAQAsAAQKfyMAAgUABghSJAwZABMCAAUABghSJAwZABMCAAEsAAUUBgg/ABkAuSUA.',['蓝幻']='蓝幻森林:BAAALAAFFAIIAgAAAA==.',['蔚蓝']='蔚蓝海岸:BAABLAAFFH8KAAIKAAIIZhiBXACaAAAKAAIIZhiBXACaAAAAAA==.',['虚空']='虚空之火:BAAALAAECgIIAgAAAA==.虚空领主:BAAALAAECggIAwAAAA==.',['虚雤']='虚雤薺:BAAALAAECgYIEQAAAA==.',['虚音']='虚音丶:BAAALAAECgYIBgAAAA==.',['虹雾']='虹雾:BAAALAAECgYIBgAAAA==.',['蛋蛋']='蛋蛋的大哥:BAABLAAECn8gAAMFAAgIwR+eDQB8AgAFAAgIwR+eDQB8AgAXAAEIvRrFKQBOAAAAAA==.',['西海']='西海岸一:BAABLAAFFH8bAAIPAAgIAxcMCwAzAgAPAAgIAxcMCwAzAgAAAA==.西海岸二:BAABLAAFFH8UAAIPAAgI1xYXCQBRAgAPAAgI1xYXCQBRAgAAAA==.',['说谁']='说谁是小个子:BAAALAAECgYIDgAAAA==.',['超大']='超大支:BAAALAAECgYICgAAAA==.',['超级']='超级奶糖:BAAALAAECgYIEAAAAA==.',['路卡']='路卡利欧:BAACLAAFFH8GAAIcAAIIGQjwFwBfAAAcAAIIGQjwFwBfAAAsAAQKfxUAAxwABwiZEQIsAEMBABwABwiZEQIsAEMBABAABggxBe88ALAAAAAA.',['軍爺']='軍爺:BAAALAAECgYIBwAAAA==.',['轩辕']='轩辕彬少:BAAALAADCgcICAAAAA==.',['轻柔']='轻柔:BAAALAADCgcIBwAAAA==.',['轻轻']='轻轻的杀了你:BAAALAAECgIIAgAAAA==.轻轻的魔:BAAALAADCgEIAQAAAA==.',['轻风']='轻风徐来:BAAALAAECgEIAQAAAA==.',['辛月']='辛月舞:BAAALAAECgYIEgAAAA==.',['辣个']='辣个帅锅:BAABLAAFFH8lAAMfAAYIlSBSEABrAQAfAAUIYiFSEABrAQAUAAUIUxoNDgAYAQAAAA==.',['达克']='达克赛德:BAAALAAECggICQAAAA==.',['达到']='达到燃放:BAAALAAECgYIBgAAAA==.',['达达']='达达风车:BAAALAAECgQIBQAAAA==.',['远浪']='远浪:BAAALAAECgYICQAAAA==.',['迷离']='迷离:BAAALAAECgYIBgAAAA==.',['迷糊']='迷糊熊猫:BAAALAADCgIIAgAAAA==.',['迷麟']='迷麟:BAABLAAFFH8IAAIBAAIInB6sUABVAAABAAIInB6sUABVAAAAAA==.',['逆转']='逆转:BAAALAAFFAgIAgAAAA==.',['逆龙']='逆龙之舞:BAAALAADCgEIAQAAAA==.',['邦邦']='邦邦桑迪:BAABLAAFFH8MAAIBAAIICRthUABWAAABAAIICRthUABWAAABLAAFFAIIDwAXAOsMAA==.',['郁灵']='郁灵:BAABLAAFFH8QAAIFAAUI7QYuNQDaAAAFAAUI7QYuNQDaAAAAAA==.',['酷酷']='酷酷砍:BAAALAAECggICAAAAA==.',['醉枪']='醉枪:BAACLAAFFH8gAAIHAAYIlBZYFADEAAAHAAYIlBZYFADEAAAsAAQKfzoAAgcACAiAHywTAMoCAAcACAiAHywTAMoCAAAA.',['野猪']='野猪佩奇:BAAALAAECgYIBgAAAA==.',['钛机']='钛机拳:BAAALAADCgYIBgAAAA==.',['铜須']='铜須:BAABLAAECn8YAAMGAAYI+B5qPgDQAQAGAAYI+B5qPgDQAQAHAAQIpAzmhgDFAAAAAA==.',['锵里']='锵里个锵:BAABLAAFFH8GAAIJAAYIPR01DQD8AQAJAAYIPR01DQD8AQAAAA==.',['长崎']='长崎素世:BAAALAAECgYICAAAAA==.',['闹闹']='闹闹桑:BAACLAAFFH8SAAIWAAIImhMQSAB0AAAWAAIImhMQSAB0AAAsAAQKfy0AAhYACAgGHF1BABkCABYACAgGHF1BABkCAAAA.',['阿伟']='阿伟:BAABLAAFFH8pAAIPAAcIfR+CDwD/AQAPAAcIfR+CDwD/AQAAAA==.',['阿克']='阿克萌德:BAAALAAECgIIAwAAAA==.',['阿兰']='阿兰娜逐星:BAAALAAECgYIBgABLAAFFAcIHgAYAGQVAA==.',['阿菲']='阿菲:BAAALAADCgcIBwAAAA==.',['阿鲁']='阿鲁迪巴:BAAALAAECgQIBgAAAA==.',['隔叶']='隔叶听风:BAAALAAFFAIIAwAAAA==.',['雅克']='雅克琳:BAAALAAECgUIBQAAAA==.',['雨夜']='雨夜听荷:BAABLAAFFH8GAAMiAAII9BSEFQBMAAAiAAII9BSEFQBMAAABAAIIugy0ZgBDAAAAAA==.',['雪丶']='雪丶碧:BAACLAAFFH8KAAIFAAIIzw9QUQCLAAAFAAIIzw9QUQCLAAAsAAQKfxQAAgUABwjDGQMqALIBAAUABwjDGQMqALIBAAAA.',['青云']='青云:BAAALAAECgIIAgAAAA==.',['青色']='青色的蜂鸟:BAABLAAFFH8GAAIBAAYIaAO2PAChAAABAAYIaAO2PAChAAAAAA==.',['非妳']='非妳沫属:BAAALAADCgMIAwAAAA==.',['风中']='风中的传说:BAACLAAFFH8JAAIGAAIIbAckswA1AAAGAAIIbAckswA1AAAsAAQKfzYAAgYACAivEiFfAIQBAAYACAivEiFfAIQBAAAA.',['风剪']='风剪云:BAAALAAFFAIIAgAAAA==.',['风影']='风影轻舞:BAAALAAFFAIIAgAAAA==.',['飞马']='飞马小幻想:BAABLAAFFH8FAAIYAAMIxRboEwCMAAAYAAMIxRboEwCMAAAAAA==.飞马梦想:BAAALAAECgYIDAAAAA==.飞马的种子袋:BAAALAAECgYIDAAAAA==.飞马的糖罐:BAAALAAECgEIAQAAAA==.',['饮风']='饮风作伴:BAAALAADCgEIAQAAAA==.',['马库']='马库斯葬爱:BAAALAAECgMIAwAAAA==.',['骑着']='骑着毛驴逛街:BAAALAADCggICAAAAA==.',['鬼见']='鬼见愁:BAAALAAECgYIBwAAAA==.',['魑魅']='魑魅丶魍魉:BAACLAAFFH8/AAMZAAYIuSXdAAAlAgAZAAYIuSXdAAAlAgAKAAEIhhvsrQAAAAAsAAQKfykAAxkACAhDI44EABkDABkACAhDI44EABkDAAoAAgg/HahiAZ0AAAAA.',['魔文']='魔文一司:BAABLAAFFH8bAAIPAAYI1xilHQCiAQAPAAYI1xilHQCiAQAAAA==.',['魔法']='魔法小妖:BAAALAADCgQIBAAAAA==.',['鲸离']='鲸离:BAAALAAECgMIAwABLAAECgYIBgAkAAAAAA==.',['麦克']='麦克老狼:BAAALAADCgQIBAAAAA==.',['黑暗']='黑暗圣堂武士:BAAALAAECgcIBwABLAAECgcIDAAkAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end