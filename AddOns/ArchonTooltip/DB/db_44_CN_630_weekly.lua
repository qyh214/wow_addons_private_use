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
 local lookup = {'Warlock-Destruction','Hunter-BeastMastery','Rogue-Assassination','Rogue-Subtlety','Paladin-Retribution','Shaman-Restoration','Paladin-Protection','DeathKnight-Frost','Warlock-Demonology','Mage-Frost','Priest-Shadow','Priest-Holy','Warrior-Fury','Unknown-Unknown','Warrior-Protection','Warrior-Arms','Paladin-Holy','Druid-Restoration','Mage-Arcane','Shaman-Elemental','DemonHunter-Havoc','Hunter-Marksmanship','Warlock-Affliction','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Blood','DemonHunter-Vengeance','Monk-Windwalker','Druid-Guardian','Monk-Brewmaster','Monk-Mistweaver','Mage-Fire',}; local provider = {region='CN',realm='外域',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ak='Akilwoew:BAAALAAECgEIAQAAAA==.',Am='Ami:BAAALAAECgYIDAAAAA==.',Ar='Artoriuce:BAAALAAECgMIAwAAAA==.',Ce='Cedric:BAABLAAFFH8KAAIBAAMIyA3ULADTAAABAAMIyA3ULADTAAAAAA==.',Ci='Ciwon:BAAALAAECgIIAgAAAA==.',Cr='Crx:BAAALAAFFAIIAgAAAA==.',De='Demonyd:BAAALAADCgEIAQAAAA==.Devilmaycry:BAABLAAFFH8PAAICAAUI3hCbUQAJAQACAAUI3hCbUQAJAQAAAA==.',Di='Distance:BAAALAADCgIIAgAAAA==.',Dr='Dreamo:BAAALAADCgQIBAAAAA==.',Fe='Felicity:BAAALAAECgYIBwAAAA==.',Gi='Girlfriends:BAAALAAECgEIAQAAAA==.',Go='Goodluck:BAAALAAECgYIBgAAAA==.',Ha='Halfkoala:BAABLAAFFH8VAAMDAAMI7CVuDwDYAAADAAIIbCVuDwDYAAAEAAEI6yY6GQBiAAAAAA==.',Jo='Joyqs:BAABLAAFFH8IAAIFAAYIux2hEADAAQAFAAYIux2hEADAAQAAAA==.',Ju='July:BAABLAAFFH8GAAIGAAIITQRXcQBIAAAGAAIITQRXcQBIAAAAAA==.',Ld='Ld:BAACLAAFFH8UAAICAAYIFR1rLgB9AQACAAYIFR1rLgB9AQAsAAQKfyIAAgIABgh4JRk6AHcCAAIABgh4JRk6AHcCAAAA.',Le='Leclerc:BAABLAAFFH8GAAIHAAII1COqCgDBAAAHAAII1COqCgDBAAAAAA==.',Li='Liadrin:BAABLAAFFH8TAAIFAAMIJx2oKgC0AAAFAAMIJx2oKgC0AAABLAAFFAYIFQAIAKYZAA==.',Ly='Lycks:BAAALAAFFAIIAgAAAA==.Lydls:BAABLAAFFH8FAAIJAAII+xccEACkAAAJAAII+xccEACkAAAAAA==.Lyjxs:BAAALAAFFAIIAgAAAA==.Lysls:BAABLAAFFH8GAAIKAAII5BZ8DwCRAAAKAAII5BZ8DwCRAAAAAA==.Lyxls:BAAALAAFFAIIAgAAAA==.Lyyes:BAAALAAFFAIIAgAAAA==.',Ma='Mail:BAAALAAECgYIBgAAAA==.',Me='Mermaid:BAABLAAFFH8IAAICAAYIfwiSSAApAQACAAYIfwiSSAApAQAAAA==.',Mi='Miamalkova:BAAALAAFFAIIAgAAAA==.',Mu='Mudgad:BAAALAAECgIIAgAAAA==.',No='Nobody:BAAALAAFFAQIBAAAAA==.',Pi='Pickletaco:BAABLAAFFH8YAAMLAAUIshg2DgBBAQALAAUIshg2DgBBAQAMAAIIkw0PMwCKAAAAAA==.',Pl='Playerrjhfuk:BAAALAAECgYIDgAAAA==.Playerudeitp:BAAALAADCgYIBgAAAA==.',Sl='Slyfox:BAAALAAECgEIAQAAAA==.',So='Soublades:BAABLAAECn8XAAINAAYIIxalRQBGAQANAAYIIxalRQBGAQAAAA==.',Th='Thursday:BAAALAAFFAIIBAAAAA==.',Wi='Windwhisper:BAAALAAECgYIBwAAAA==.',Ya='Yacker:BAAALAAECggIDgABLAAFFAgIBwAJAMwgAA==.',Yb='Ybdk:BAAALAAECgYIBgABLAAFFAEIAQAOAAAAAA==.Ybfs:BAAALAAFFAEIAQAAAA==.Ybzs:BAAALAAECgYIBgABLAAFFAEIAQAOAAAAAA==.',Ye='Yellowbaby:BAAALAAECgYICwAAAA==.',Za='Zap:BAABLAAFFH8PAAMPAAMILwyTEwCzAAAPAAMILwyTEwCzAAAQAAIIdwt/BQCKAAAAAA==.',['一世']='一世安然:BAAALAAECgYIBgAAAA==.一世平安:BAAALAADCgYIBwAAAA==.一世心安:BAAALAAECgYIDwAAAA==.',['一头']='一头德:BAAALAAECgUIBQAAAA==.',['一棍']='一棍闷到腰子:BAAALAADCggICAAAAA==.',['一路']='一路平安:BAAALAADCgEIAQAAAA==.',['一银']='一银月一:BAAALAAECgEIAQAAAA==.',['七七']='七七:BAABLAAFFH8JAAIGAAIIxxFnQgB9AAAGAAIIxxFnQgB9AAAAAA==.',['七个']='七个隆咚锵:BAABLAAFFH8GAAIFAAIIuBbhNQCmAAAFAAIIuBbhNQCmAAAAAA==.',['七森']='七森莉莉丶:BAAALAAECgUIBQAAAA==.',['七神']='七神之誓:BAAALAAECgYIEgAAAA==.',['七香']='七香恋:BAAALAAECgYIBgAAAA==.',['三十']='三十稳重男士:BAAALAADCgMIAwAAAA==.',['不死']='不死小强:BAAALAAECgIIAgAAAA==.',['不要']='不要追我:BAAALAAFFAIIAgAAAA==.',['专门']='专门尖啸草哥:BAAALAAECgYIEAAAAA==.专门误导草哥:BAAALAAECgYICAAAAA==.',['东海']='东海莽道人:BAAALAAECgUIBQAAAA==.',['东西']='东西有点多:BAAALAAFFAIIAgAAAA==.',['丣熙']='丣熙:BAABLAAFFH8OAAIKAAUI1Q9ACAAVAQAKAAUI1Q9ACAAVAQAAAA==.',['丨冲']='丨冲锋切唧唧:BAACLAAFFH8TAAIPAAUIWgspGQDXAAAPAAUIWgspGQDXAAAsAAQKfxgAAg8ABghSGPwfAEQBAA8ABghSGPwfAEQBAAAA.',['丨史']='丨史泰龙丶:BAABLAAFFH8GAAINAAIIPBHYRwBLAAANAAIIPBHYRwBLAAABLAAFFAgIOAANAHgjAA==.',['丨阿']='丨阿尔薩斯丨:BAABLAAECn8VAAQFAAYImxEucAAhAQAFAAYImxEucAAhAQARAAYIJQjELQDWAAAHAAYI0AehLQCyAAAAAA==.',['丨鬼']='丨鬼鬼丨:BAAALAAECgIIAgAAAA==.',['临时']='临时演员:BAAALAAECggIAwAAAA==.',['丶丶']='丶丶暗色丶丶:BAAALAAFFAIIBAAAAA==.',['丶天']='丶天妒:BAAALAAFFAIIAgAAAA==.',['丶怀']='丶怀瑾握瑜:BAABLAAFFH8UAAISAAYIkhd9EAC/AQASAAYIkhd9EAC/AQAAAA==.',['丶恍']='丶恍惚:BAAALAAFFAIIAgAAAA==.',['丶毛']='丶毛豆:BAAALAAECgYICQAAAA==.',['主任']='主任别介啊:BAABLAAFFH8WAAITAAgIrhoxCABiAgATAAgIrhoxCABiAgAAAA==.',['丿月']='丿月夜灬牛牛:BAAALAADCgYIBAAAAA==.',['九月']='九月掠风痕:BAAALAAECgUICAAAAA==.',['乱舞']='乱舞小咕咕:BAAALAAFFAIIAgAAAA==.',['亂舞']='亂舞小獅子:BAAALAADCggICAAAAA==.',['五五']='五五:BAAALAAECgIIAgAAAA==.',['亡者']='亡者已逝:BAAALAAECgYIBgAAAA==.',['人生']='人生贵淡泊:BAAALAAECgMIAwAAAA==.',['亿万']='亿万少女的梦:BAACLAAFFH8MAAITAAUIBhTbNQAhAQATAAUIBhTbNQAhAQAsAAQKfx0AAhMACAi6HE8vAI0CABMACAi6HE8vAI0CAAAA.',['今天']='今天没有糖:BAAALAAFFAIIAgAAAA==.',['从頭']='从頭开始:BAABLAAFFH8HAAIIAAMI5RMeXwCQAAAIAAMI5RMeXwCQAAAAAA==.',['仓崎']='仓崎枫子丶:BAAALAAECgEIAQAAAA==.',['伊利']='伊利氮:BAAALAAFFAIIAgAAAA==.',['佛搂']='佛搂觅:BAAALAAFFAIIAgAAAA==.',['你在']='你在狗叫什么:BAAALAADCgQIBAAAAA==.',['你抓']='你抓不到我丶:BAAALAAFFAIIBAAAAA==.',['你有']='你有币币咩:BAAALAAECgYIBgAAAA==.你有币币嘛:BAABLAAECn8WAAICAAgIgRI3WQCQAQACAAgIgRI3WQCQAQAAAA==.',['佩罗']='佩罗纳喲:BAAALAAECgEIAQAAAA==.',['侃侃']='侃侃瑞恩:BAAALAAFFAIIAgAAAA==.侃侃盖恩:BAABLAAFFH8GAAIGAAIICh61KwCsAAAGAAIICh61KwCsAAAAAA==.侃侃菲恩:BAABLAAECn8cAAMFAAYIFSOIVABFAgAFAAYIxCGIVABFAgAHAAYInCDDIwDfAQAAAA==.',['依然']='依然烤香肠:BAABLAAFFH8bAAMUAAYIqwiyEABsAQAUAAUImgmyEABsAQAGAAYIZBPNIQDHAAAAAA==.',['侵蚀']='侵蚀污染:BAAALAAFFAIIAgAAAA==.',['信仰']='信仰之力:BAABLAAFFH8IAAIVAAII6g0NRwCUAAAVAAII6g0NRwCUAAAAAA==.',['偶迈']='偶迈噶得:BAAALAADCgIIAgAAAA==.',['光铸']='光铸亲王霜火:BAACLAAFFH8ZAAMFAAYI6x9aDQDZAQAFAAYI6x9aDQDZAQAHAAIINhFhGQA4AAAsAAQKfxwAAwcACAhcH1cXAD0CAAcABwi6HlcXAD0CAAUAAwhMIddxAB4BAAEsAAUUBgggAAUAMSMA.',['克里']='克里思:BAABLAAFFH8GAAIGAAIIKghCagBRAAAGAAIIKghCagBRAAAAAA==.',['全冠']='全冠清:BAAALAAECgQIBgAAAA==.',['全方']='全方测绘二:BAAALAAECgMIAwAAAA==.',['兰丶']='兰丶丶娅:BAAALAAECgUIBQAAAA==.',['共同']='共同富裕:BAAALAADCgQIBAAAAA==.',['关晛']='关晛:BAAALAADCgMIAwAAAA==.',['冥焰']='冥焰小仔:BAAALAADCgEIAQAAAA==.冥焰小左:BAABLAAFFH8QAAMGAAYI6h40DAB8AQAGAAYI6h40DAB8AQAUAAIIVhWYPwBLAAAAAA==.',['冬尼']='冬尼大木:BAAALAADCgIIAgAAAA==.',['冰刺']='冰刺夜莺:BAAALAAECgYIDAAAAA==.',['冰糖']='冰糖汤圆:BAAALAAECgYICwAAAA==.',['冰翼']='冰翼圣灵:BAABLAAFFH8GAAIHAAYIDweCCgACAQAHAAYIDweCCgACAQAAAA==.',['冷焱']='冷焱散失:BAAALAAECgYIBgAAAA==.',['凑凑']='凑凑哈:BAABLAAFFH8UAAITAAUIaRNQKQDuAAATAAUIaRNQKQDuAAAAAA==.',['凛风']='凛风:BAAALAAECgYIBgAAAA==.',['划水']='划水的鱼:BAACLAAFFH8GAAITAAMIAxJ8RwCEAAATAAMIAxJ8RwCEAAAsAAQKfykAAhMABgiqIl0WAPYBABMABgiqIl0WAPYBAAAA.',['剑聖']='剑聖:BAAALAAECgIIAgAAAA==.',['动情']='动情时最美:BAACLAAFFH8NAAIHAAQIoxUEDQC7AAAHAAQIoxUEDQC7AAAsAAQKfxUAAgcABwj6GB8SAJIBAAcABwj6GB8SAJIBAAAA.',['劳资']='劳资蜀道山:BAAALAAECgYICQAAAA==.',['北归']='北归丶:BAAALAAECgMIAwAAAA==.',['北极']='北极小兔:BAAALAAFFAIIAgAAAA==.',['十字']='十字路口听风:BAAALAAECgUIBQAAAA==.',['十恶']='十恶不射:BAAALAAECgYICAAAAA==.',['十里']='十里飘雪:BAAALAAECgMIAwAAAA==.',['千幻']='千幻流光:BAACLAAFFH8MAAITAAYIxR/dGQC1AQATAAYIxR/dGQC1AQAsAAQKfyUAAwoABwgAG5sZAFYBABMABwhEFYsrAG0BAAoABgisGZsZAFYBAAEsAAUUCAgiAAEAfSUA.',['半只']='半只哈基米:BAAALAAFFAIIBAAAAA==.半只苍蝇:BAABLAAFFH8FAAIVAAUI0hAiKwA8AQAVAAUI0hAiKwA8AQAAAA==.半只鹌鹑:BAAALAADCggICAABLAAFFAgICgAWAIEbAA==.',['半吨']='半吨土豆:BAAALAAECgYICwAAAA==.',['卌爱']='卌爱莎卌:BAABLAAFFH8kAAMCAAYIUQuEQQBCAQACAAYIUQuEQQBCAQAWAAEISQHNOgAmAAAAAA==.',['单吊']='单吊柒筒:BAAALAAFFAIIAgAAAA==.',['卖炊']='卖炊饼的:BAAALAAECgYIDwAAAA==.',['卡哇']='卡哇伊貝貝:BAABLAAFFH8GAAIKAAIIrhcOGAA/AAAKAAIIrhcOGAA/AAAAAA==.',['友友']='友友泡凤爪:BAAALAAECgYICgABLAAECgcICAAOAAAAAA==.',['发粪']='发粪涂墙噢:BAAALAAFFAMIAwAAAA==.',['叔叔']='叔叔也很帅:BAABLAAFFH8KAAISAAIIWw+RMwBtAAASAAIIWw+RMwBtAAAAAA==.',['古枂']='古枂:BAAALAADCgIIAgAAAA==.',['合心']='合心成:BAABLAAFFH8MAAIVAAMIIyDlFgAlAQAVAAMIIyDlFgAlAQABLAAFFAMIFQADAOwlAA==.',['吉鲁']='吉鲁普普:BAAALAAFFAIIAgAAAA==.',['名字']='名字要六个字:BAAALAADCgcIBwAAAA==.',['吖童']='吖童牧:BAAALAAECggICAAAAA==.',['吴宫']='吴宫干戈:BAAALAAECgIIAgAAAA==.',['吸引']='吸引你的瞬间:BAAALAADCgcIBwAAAA==.',['告别']='告别过去:BAAALAADCgMIAwAAAA==.',['呜喵']='呜喵王丶:BAAALAAECggIAwAAAA==.',['咖啡']='咖啡有毒:BAAALAAECgEIAQAAAA==.',['咖喱']='咖喱牛肉面:BAAALAAECgMIBQAAAA==.',['咸湿']='咸湿:BAABLAAECn8VAAIMAAYIGBxIPwDbAQAMAAYIGBxIPwDbAQAAAA==.',['哇唔']='哇唔噢吽:BAAALAAECgUIBQAAAA==.',['哞哞']='哞哞小钻风:BAAALAAFFAIIAgAAAA==.',['嗜血']='嗜血起:BAAALAADCgQIBAAAAA==.',['嗳儿']='嗳儿:BAAALAAFFAIIAgAAAA==.嗳儿小乖乖:BAAALAAFFAIIAgAAAA==.嗳儿精灵:BAAALAAECgYICAAAAA==.',['四月']='四月物语:BAAALAAECgYIBgAAAA==.',['四琴']='四琴的鹰:BAAALAADCgEIAQAAAA==.',['圣使']='圣使之命:BAAALAADCgMIAwAAAA==.',['圣光']='圣光灭滅:BAAALAAECgYICwAAAA==.',['圣化']='圣化忽悠着你:BAAALAAECgMIBQAAAA==.',['坝霸']='坝霸:BAAALAAECgYIBgAAAA==.',['基无']='基无霸:BAAALAADCgYIBgAAAA==.',['塔兰']='塔兰吉之女:BAAALAAECgIIAgAAAA==.',['壹索']='壹索:BAAALAAECgEIAQAAAA==.',['复仇']='复仇元素:BAAALAADCgQIBAAAAA==.',['夏天']='夏天丿:BAAALAAFFAIIAgAAAA==.夏天的太阳:BAAALAAFFAIIAgAAAA==.',['夏日']='夏日微凉:BAAALAAFFAIIAgAAAA==.',['夏雪']='夏雪瑶:BAAALAAFFAIIAgAAAA==.',['夕枯']='夕枯:BAAALAADCggICAAAAA==.',['外科']='外科手术刀:BAABLAAFFH8LAAMDAAMIshZBEwC0AAADAAMIshZBEwC0AAAEAAEIpxA3GgAAAAAAAA==.',['夜游']='夜游:BAABLAAFFH8KAAICAAMINBq6agCNAAACAAMINBq6agCNAAAAAA==.',['夜溪']='夜溪儿:BAABLAAFFH8oAAIRAAYICRq/CgDYAQARAAYICRq/CgDYAQAAAA==.夜溪兒:BAACLAAFFH8pAAIRAAYIiRX/DgCWAQARAAYIiRX/DgCWAQAsAAQKfyQAAxEABggNHUUmAOkBABEABggNHUUmAOkBAAUAAghADsPGAGwAAAAA.',['夜王']='夜王一寒冬城:BAAALAAECgQIBAAAAA==.',['夜阑']='夜阑丨孤鸿:BAABLAAFFH8JAAIVAAIIvCWRIQDgAAAVAAIIvCWRIQDgAAAAAA==.',['大佑']='大佑池久:BAAALAADCgIIAgAAAA==.',['大宜']='大宜賓:BAAALAAECgYIBgAAAA==.',['大表']='大表哥丶:BAAALAAECgMIAwAAAA==.大表姐丶:BAAALAAFFAIIAgAAAA==.',['大辫']='大辫双马尾:BAAALAAECgEIAQAAAA==.',['天使']='天使芯晨:BAAALAAECgYIBgAAAA==.',['天地']='天地仁心:BAAALAAFFAIIAgAAAA==.',['天堂']='天堂信仰丶朮:BAABLAAFFH8oAAIBAAYImRZOJQCFAQABAAYImRZOJQCFAQAAAA==.',['天宇']='天宇之欣:BAACLAAFFH8GAAIVAAII0g+HUwBHAAAVAAII0g+HUwBHAAAsAAQKfx0AAhUABgjlF108AGkBABUABgjlF108AGkBAAAA.',['太假']='太假:BAAALAAECgYICgAAAA==.',['太寿']='太寿鸠毛:BAAALAADCgYIBgAAAA==.',['夺命']='夺命老腊肉:BAAALAAECgUIBQAAAA==.夺命追魂:BAAALAADCgYIBwAAAA==.',['奈奈']='奈奈酱:BAAALAAFFAEIAQAAAA==.',['她老']='她老公不同意:BAAALAAECgYIDAAAAA==.',['姆斯']='姆斯:BAAALAAECgYIBgAAAA==.',['威廉']='威廉姆斯:BAAALAAECgYICAAAAA==.',['娜娜']='娜娜是铁憨憨:BAAALAAECgYICgAAAA==.',['媚惑']='媚惑者:BAACLAAFFH8LAAIBAAII+w9IQwCUAAABAAII+w9IQwCUAAAsAAQKfxoAAgEACAi2FH1RAP0BAAEACAi2FH1RAP0BAAAA.',['子曾']='子曾经爱过鱼:BAAALAAECgMIBAAAAA==.',['孙大']='孙大剩丶:BAAALAAFFAIIAgAAAA==.',['宇文']='宇文術学:BAACLAAFFH8MAAMBAAQILA2zKQDlAAABAAMIAg+zKQDlAAAXAAEIqAfMBwBOAAAsAAQKfxcABAEACAhYHPcnAKQCAAEACAhYHPcnAKQCABcABAjUC4wgAOsAAAkAAQhcEkeUAEAAAAAA.',['守之']='守之血骑:BAABLAAECn8rAAIFAAcIpRpVLQDeAQAFAAcIpRpVLQDeAQAAAA==.',['安提']='安提:BAAALAAECgMIBAAAAA==.',['宋小']='宋小美:BAAALAADCgQIBAAAAA==.',['宙斯']='宙斯盾级:BAAALAAECgcIBwAAAA==.',['家有']='家有只熊:BAAALAADCgQIBAAAAA==.',['寒冰']='寒冰宝珠:BAAALAAECgMIBAAAAA==.',['寧龍']='寧龍冰龙剑:BAABLAAFFH8IAAMDAAII5gmjHQB7AAADAAII5gmjHQB7AAAEAAEIRQAZIQAbAAAAAA==.',['射到']='射到天荒地老:BAAALAADCgQIBAAAAA==.',['射的']='射的就是我:BAAALAAECgYIEAAAAA==.',['射鸡']='射鸡猎:BAAALAAFFAIIBAAAAA==.',['将心']='将心:BAAALAAECgYIBgAAAA==.',['小二']='小二二:BAAALAAECgYIBgAAAA==.',['小兔']='小兔姬:BAACLAAFFH8OAAIMAAQI7hRcJAAaAQAMAAQI7hRcJAAaAQAsAAQKfxcAAgwABgi1HTkhAKwBAAwABgi1HTkhAKwBAAAA.',['小八']='小八有神奇:BAAALAAECggICAAAAA==.',['小叶']='小叶:BAAALAAECgYICAAAAA==.',['小林']='小林未郁:BAAALAAECggICAAAAA==.',['小烨']='小烨:BAAALAAECggICwAAAA==.',['小熙']='小熙:BAAALAAFFAIIAwAAAA==.',['小猫']='小猫猫:BAABLAAFFH8GAAISAAIIyxPYQwBoAAASAAIIyxPYQwBoAAAAAA==.',['小电']='小电:BAAALAADCgEIAQAAAA==.',['小艺']='小艺的老公:BAAALAAECgYIBgAAAA==.小艺的超凡:BAABLAAECn8XAAMFAAYIeBWreQANAQAHAAYI9BBRQwAqAQAFAAUIghereQANAQAAAA==.',['小芈']='小芈:BAAALAAECgYIBgAAAA==.',['小镇']='小镇做题家:BAAALAAECgEIAQAAAA==.',['小黄']='小黄油拿铁:BAAALAAECgQIBAAAAA==.',['少年']='少年郎丶:BAAALAAECgMIBAAAAA==.',['尔利']='尔利丹怒风:BAAALAAECgYIDAAAAA==.',['就不']='就不奶就哔哔:BAAALAAECgYIDAAAAA==.',['尼奥']='尼奥奥龙:BAABLAAFFH8LAAMYAAYIDQs4EQARAQAYAAUItQw4EQARAQAZAAMInAOXDQBgAAAAAA==.尼奥奥龙龙:BAABLAAFFH8NAAMZAAYI+w0VCQD4AAAZAAUIIAkVCQD4AAAYAAQIZw7UEgDnAAAAAA==.尼奥龙:BAABLAAFFH8SAAMYAAYIMxYEDwBIAQAYAAUIxRQEDwBIAQAZAAQIMQ5zCgDDAAAAAA==.尼奥龙龙:BAABLAAFFH8MAAMZAAYIFxFeCAAQAQAZAAUItRBeCAAQAQAYAAUInwp9EQAKAQAAAA==.',['尼尼']='尼尼奥龙:BAABLAAFFH8OAAMYAAYIaREcEAAtAQAYAAUI6BEcEAAtAQAZAAMICgOmDQBeAAAAAA==.',['巧克']='巧克力香子兰:BAAALAAECgQIBAAAAA==.',['巫小']='巫小可:BAABLAAFFH8RAAMCAAYINRaDOwBVAQACAAYINRaDOwBVAQAWAAEITRvBMwBGAAAAAA==.',['巫毒']='巫毒嘎嘎:BAAALAAECgYIDAAAAA==.',['席琳']='席琳元素萨:BAACLAAFFH8GAAMUAAYIMQ8QKAAEAQAUAAUIrQ0QKAAEAQAGAAEIyQGefgAoAAAsAAQKfxcAAxQACAj7FygxAEYCABQACAj7FygxAEYCAAYAAQgRCHhOASUAAAAA.席琳小龙人:BAACLAAFFH8IAAIYAAYIzRPvCwCPAQAYAAYIzRPvCwCPAQAsAAQKfxgABBoACAhWHDgSAKECABoACAhWHDgSAKECABkACAiYDtkLAKgBABgABAhFFasqAAwBAAAA.席琳汼头猫:BAAALAAECgcICwAAAA==.席琳追猎者:BAAALAAECggIEgAAAA==.',['幸福']='幸福的满满:BAAALAAECgIIAgAAAA==.',['幽兒']='幽兒小斑:BAAALAAECggIBQAAAA==.',['序曲']='序曲之末:BAABLAAFFH8FAAIFAAIIoiCjTABjAAAFAAIIoiCjTABjAAAAAA==.序曲终章:BAAALAADCgcIBwAAAA==.',['康斯']='康斯坦丁:BAABLAAFFH8GAAICAAYIRw9YQgA/AQACAAYIRw9YQgA/AQAAAA==.',['开嗜']='开嗜血的:BAACLAAFFH8HAAIGAAMIZweiUgB2AAAGAAMIZweiUgB2AAAsAAQKfxYAAgYABwgnGnRpALIBAAYABwgnGnRpALIBAAAA.',['弹珠']='弹珠:BAABLAAFFH8JAAIIAAIIYRL3fQBGAAAIAAIIYRL3fQBGAAAAAA==.',['强悍']='强悍的燕儿:BAAALAAECgEIAQAAAA==.',['彪悍']='彪悍丶砖头:BAAALAAECggIDgAAAA==.',['很活']='很活适:BAAALAAFFAIIAgAAAA==.',['很硬']='很硬的头哦:BAAALAAECgYIDQAAAA==.',['微光']='微光:BAABLAAFFH8GAAIFAAQIpxGkGgDwAAAFAAQIpxGkGgDwAAAAAA==.',['德川']='德川肩备:BAABLAAFFH8IAAIFAAgItQEDggAoAAAFAAgItQEDggAoAAAAAA==.',['怀瑾']='怀瑾握瑜:BAAALAAECgIIAwAAAA==.',['怂怂']='怂怂:BAAALAAECgYICQAAAA==.',['思丶']='思丶雨:BAAALAAECgYIBgAAAA==.',['恩丶']='恩丶我知道:BAABLAAFFH8LAAIGAAIIKhjZSwCFAAAGAAIIKhjZSwCFAAABLAAFFAgIGwAUAHAXAA==.',['悠忧']='悠忧小牧:BAAALAAECgYIBgAAAA==.',['想归']='想归隐丶:BAAALAAECgYIEAAAAA==.',['憶如']='憶如往昔丶:BAAALAADCgIIAgAAAA==.',['戏雨']='戏雨听风:BAAALAAECgQIBAAAAA==.',['我叫']='我叫阿牛:BAAALAAFFAMIAwAAAA==.',['我是']='我是活老鬼:BAAALAAECgYIDAAAAA==.我是虾仁:BAAALAAECgQIBAAAAA==.我是闪电:BAAALAAFFAMIBAAAAA==.',['我爱']='我爱吃火锅:BAABLAAFFH8UAAINAAUInxd2IwBSAQANAAUInxd2IwBSAQAAAA==.我爱小麦:BAABLAAFFH8FAAIRAAUIQQ2mFgAjAQARAAUIQQ2mFgAjAQAAAA==.我爱阿狗:BAAALAAECggICgAAAA==.',['战之']='战之神:BAAALAAECgYIBgAAAA==.',['战争']='战争之毛:BAAALAAECgYIBgAAAA==.战争的艺术:BAAALAAECgEIAQAAAA==.',['打肥']='打肥鸡:BAAALAAFFAQIBAAAAA==.',['拉文']='拉文克劳冠冕:BAAALAAECggICwAAAA==.拉文盹盹:BAAALAAECgMIAwAAAA==.',['拯救']='拯救天使:BAAALAAECggICQAAAA==.',['拾拳']='拾拳大补完:BAABLAAFFH8HAAIUAAQIbwbiLgC9AAAUAAQIbwbiLgC9AAAAAA==.',['按住']='按住啦北鼻:BAAALAAECgUIBQAAAA==.',['摇了']='摇了摇头灬:BAAALAAFFAIIAgAAAA==.',['放了']='放了那大婶:BAABLAAECn8eAAMNAAgInhw8HQD/AQANAAgInhw8HQD/AQAPAAEISxV+UAA/AAAAAA==.',['放纵']='放纵着忧伤:BAAALAAECgYICAAAAA==.',['斩灵']='斩灵:BAAALAAFFAQIBAAAAA==.',['断情']='断情殇:BAAALAAECgYIBgAAAA==.',['新奇']='新奇士:BAABLAAFFH8HAAIIAAIIbQX9mgA5AAAIAAIIbQX9mgA5AAAAAA==.',['无妻']='无妻:BAABLAAFFH8IAAIFAAIIICBtJADCAAAFAAIIICBtJADCAAAAAA==.',['无谓']='无谓再提丶:BAAALAAFFAIIBAAAAA==.',['明月']='明月心:BAACLAAFFH8ZAAINAAQIYBoRLQD0AAANAAQIYBoRLQD0AAAsAAQKfyMAAw0ABwiaIiIsAIsCAA0ABwiaIiIsAIsCAA8AAQibEMdTADEAAAAA.明月相思:BAAALAAECgYIBgAAAA==.',['星夜']='星夜:BAAALAADCgEIAQAAAA==.星夜城北:BAAALAAECgIIAgAAAA==.',['星梨']='星梨花:BAAALAAFFAQIBAAAAA==.',['星界']='星界德:BAAALAAFFAIIAgAAAA==.',['星痕']='星痕破晓:BAAALAAECgYIDAAAAA==.',['星空']='星空耀世:BAABLAAFFH8KAAMZAAYIbRZDAwCoAQAZAAUIOxRDAwCoAQAYAAEIixgtGwBHAAABLAAFFAgIBgAZAMYbAA==.',['星辰']='星辰魂:BAAALAAFFAIIBAAAAA==.',['春风']='春风不解意:BAABLAAFFH8NAAMMAAUIAhXdIgCuAAAMAAMIcxvdIgCuAAALAAMI7AWlHACqAAAAAA==.',['晴天']='晴天小猪:BAACLAAFFH8GAAMJAAIIlg2oHgB1AAAJAAIIlg2oHgB1AAABAAEI3grxZAA7AAAsAAQKfxQAAwkACAhhGm8kAOkBAAkACAiyGW8kAOkBAAEABQieF/g9AFABAAAA.',['暗瞳']='暗瞳:BAAALAADCgUIBQAAAA==.',['曦児']='曦児丶阿曼达:BAAALAAECgMIAwAAAA==.',['曰白']='曰白不要钱:BAAALAAFFAIIAgAAAA==.',['書生']='書生:BAABLAAECn8UAAICAAYINSAnXQAiAgACAAYINSAnXQAiAgAAAA==.',['月夜']='月夜幻世:BAABLAAFFH8JAAIGAAYIJw0kHADZAAAGAAYIJw0kHADZAAAAAA==.月夜灬玄冥帝:BAAALAADCggICQAAAA==.',['月落']='月落云生:BAAALAAECggICAAAAA==.',['有一']='有一个德:BAAALAAECgYICgAAAA==.',['有之']='有之狐:BAAALAAECggICAAAAA==.',['末日']='末日小宝贝:BAAALAADCgYIBgAAAA==.',['李老']='李老师丶:BAAALAADCgIIAgAAAA==.',['杜呆']='杜呆子:BAABLAAFFH8GAAITAAYIBg/gEADfAQATAAYIBg/gEADfAQAAAA==.',['枫人']='枫人愿:BAAALAAFFAIIBAAAAA==.',['枫灬']='枫灬宝宝丶:BAAALAAECgYIDAAAAA==.',['柠檬']='柠檬丨冰红茶:BAABLAAFFH8GAAIBAAII+AMMbAA0AAABAAII+AMMbAA0AAAAAA==.',['校花']='校花儿:BAAALAAECgYIBgAAAA==.',['核桃']='核桃糯米:BAAALAADCgMIAwAAAA==.',['桃心']='桃心小西西:BAAALAAECgMIAwAAAA==.',['梅川']='梅川乂内酷:BAAALAAECggIDgAAAA==.',['梅梅']='梅梅:BAAALAAECgYIBgAAAA==.',['棉花']='棉花糖小熊:BAAALAAFFAIIAgAAAA==.',['槑圆']='槑圆润:BAAALAAFFAQIAgAAAA==.',['槑闻']='槑闻花:BAAALAAFFAMIAwAAAA==.',['橙羊']='橙羊羊:BAABLAAFFH8GAAICAAYIjgImhABNAAACAAYIjgImhABNAAABLAAFFAgIDAACACgbAA==.',['欢茄']='欢茄炒鸡蛋:BAAALAAECgYIBgAAAA==.',['欲说']='欲说还休:BAAALAAECgYICAAAAA==.',['武安']='武安君:BAABLAAFFH8GAAIPAAYIuhRkEgAyAQAPAAYIuhRkEgAyAQAAAA==.',['歪特']='歪特多拉贡:BAABLAAFFH8GAAIPAAIIZgt8JQBzAAAPAAIIZgt8JQBzAAAAAA==.',['歲月']='歲月雨中奏:BAABLAAFFH8nAAIbAAYIVw4xDABJAQAbAAYIVw4xDABJAQAAAA==.',['歳月']='歳月雨中奏:BAAALAAECgQIBAAAAA==.',['殺戮']='殺戮戦骑:BAAALAAECgMIAwAAAA==.',['比你']='比你更猛:BAAALAAECggIEAAAAA==.',['比特']='比特牛:BAABLAAECn8YAAIHAAYIDxWINgBtAQAHAAYIDxWINgBtAQAAAA==.',['毛豆']='毛豆丶猎:BAAALAAECgIIAwAAAA==.',['水管']='水管工:BAAALAAECgQIBAAAAA==.',['永恒']='永恒法力:BAAALAAECgYIDAAAAA==.',['汝防']='汝防:BAAALAAECggIEAAAAA==.',['汤圆']='汤圆丶:BAAALAADCgIIAgAAAA==.',['沐子']='沐子:BAACLAAFFH8FAAIFAAII9hwgLgCuAAAFAAII9hwgLgCuAAAsAAQKfxQAAgUABwjOIPQ6AIoCAAUABwjOIPQ6AIoCAAAA.',['油条']='油条:BAAALAAFFAEIAQAAAA==.',['法号']='法号神棍:BAAALAAECgYIBwAAAA==.',['泡泡']='泡泡哒光:BAAALAADCggIEAAAAA==.泡泡哒希:BAAALAADCggICAAAAA==.',['泰奶']='泰奶奶骑白虎:BAABLAAFFH8VAAIIAAYIphmaIgATAQAIAAYIphmaIgATAQAAAA==.',['泷夜']='泷夜叉姬:BAAALAAECgQIBAAAAA==.',['洛丶']='洛丶萨:BAABLAAECn8WAAIGAAcIaBZsNACMAQAGAAcIaBZsNACMAQAAAA==.洛丶骑:BAAALAAFFAIIAgAAAA==.',['洛丽']='洛丽塔审查官:BAAALAADCgIIAgAAAA==.',['洛必']='洛必达:BAABLAAFFH8JAAIGAAMImhQIPgCsAAAGAAMImhQIPgCsAAAAAA==.',['洛柯']='洛柯:BAABLAAFFH8PAAIFAAYIjwT3NADaAAAFAAYIjwT3NADaAAAAAA==.',['流氓']='流氓大学生:BAAALAAECgcICAAAAA==.流氓帅哥:BAAALAAFFAIIBAAAAA==.',['浓墨']='浓墨凝霜:BAAALAAECgYIBgAAAA==.浓墨凝香:BAABLAAFFH8IAAIBAAgIZR1LBwCJAgABAAgIZR1LBwCJAgAAAA==.',['浮生']='浮生未歇:BAAALAAECgYIBQAAAA==.',['海大']='海大爷:BAAALAAECggIDwAAAA==.',['涅尼']='涅尼末:BAABLAAFFH8TAAIBAAYIGAtSNgA3AQABAAYIGAtSNgA3AQAAAA==.',['液魔']='液魔影瑝:BAABLAAFFH8GAAIIAAIIuhdMWgCbAAAIAAIIuhdMWgCbAAAAAA==.',['涴涴']='涴涴清风:BAACLAAFFH8oAAIRAAUI7yFoCQB5AQARAAUI7yFoCQB5AQAsAAQKfx0AAhEACAimGz8TAHYCABEACAimGz8TAHYCAAAA.',['淡漠']='淡漠星辰:BAAALAAECgYIDAAAAA==.',['清凉']='清凉灬依夏:BAAALAAECgEIAQAAAA==.',['清风']='清风狂虐:BAAALAAECgYIBgAAAA==.',['渐隐']='渐隐:BAABLAAFFH8GAAIVAAYIuQNpNADjAAAVAAYIuQNpNADjAAAAAA==.',['渣男']='渣男一号:BAACLAAFFH8KAAMMAAMI6B8aHgDJAAAMAAII1CEaHgDJAAALAAMI2ht9HgCWAAAsAAQKfxUAAwsACAglGyYkAFUCAAsACAglGyYkAFUCAAwABghCEMhlAEoBAAAA.',['温柔']='温柔儒雅的贼:BAAALAADCgQIBAAAAA==.',['滚球']='滚球球:BAABLAAECn8eAAMRAAYIMBUOOwB2AQARAAYIMBUOOwB2AQAFAAQIfyN+awArAQAAAA==.',['漆黑']='漆黑之刃:BAAALAAECgIIAgAAAA==.',['火锅']='火锅哥:BAAALAAFFAMIAwAAAA==.',['灬唉']='灬唉吆喂灬:BAAALAADCgYIBgAAAA==.',['灲魂']='灲魂:BAAALAAECgYICwAAAA==.',['灵风']='灵风无痕:BAABLAAFFH8GAAIKAAIIlAd2HgAzAAAKAAIIlAd2HgAzAAAAAA==.',['灵魂']='灵魂魅影:BAAALAADCgQIBAAAAA==.',['烈焰']='烈焰使者:BAAALAAECgIIBAAAAA==.',['烬劫']='烬劫丶瞳淵:BAABLAAFFH8OAAMVAAIIfRsySgBPAAAVAAIIfRsySgBPAAAcAAII2xRbEwA1AAABLAAFFAUIHwAdADghAA==.',['無影']='無影:BAAALAAECgIIAgAAAA==.',['無痛']='無痛人牛:BAACLAAFFH8RAAIIAAQI+BXmTgDoAAAIAAQI+BXmTgDoAAAsAAQKfxkAAggABgioHJxAAIABAAgABgioHJxAAIABAAAA.',['燃烧']='燃烧的腋髦:BAAALAAECgYIDAAAAA==.',['燃面']='燃面:BAAALAADCgYIBgAAAA==.',['燕宇']='燕宇恒:BAAALAAECgYIDAAAAA==.',['燕过']='燕过无痕:BAAALAAECgEIAQAAAA==.',['爆缸']='爆缸:BAAALAAECgYIBgAAAA==.',['爱吃']='爱吃豆腐脑:BAAALAADCgYIAQAAAA==.爱吃香菜:BAAALAAECgYICgAAAA==.',['爱手']='爱手艺:BAAALAAECggICAAAAA==.',['牛之']='牛之刚健:BAAALAAECgYIBgAAAA==.',['牛牛']='牛牛光环:BAAALAAFFAIIAwAAAA==.牛牛本牛:BAAALAAECgYIBwAAAA==.',['牜丶']='牜丶萨满:BAABLAAFFH8JAAIGAAMIchVVPACyAAAGAAMIchVVPACyAAAAAA==.',['牧果']='牧果:BAAALAADCggIEAAAAA==.',['牧畜']='牧畜业手艺人:BAABLAAFFH8GAAIJAAMIQhy2CgC2AAAJAAMIQhy2CgC2AAAAAA==.',['牧莱']='牧莱克斯塔萨:BAAALAAECggICAAAAA==.',['特仑']='特仑苏:BAAALAAECgcIBwAAAA==.',['狂傲']='狂傲天下:BAAALAAECgMIAwAAAA==.',['狂战']='狂战无双:BAAALAADCgIIAgAAAA==.',['狂暴']='狂暴战:BAABLAAFFH8GAAINAAMIRROhGgDzAAANAAMIRROhGgDzAAAAAA==.狂暴的鸽子:BAABLAAECn8YAAMGAAgIvCX3AwBHAwAGAAgIvCX3AwBHAwAUAAgIzA93SgDdAQAAAA==.',['狂野']='狂野的男人:BAABLAAFFH8fAAINAAYIWh+hEADTAQANAAYIWh+hEADTAQAAAA==.',['狐狸']='狐狸晓姐:BAAALAAECgYIBgAAAA==.',['狐里']='狐里糊涂:BAABLAAFFH8KAAICAAYInBLZOQBZAQACAAYInBLZOQBZAQAAAA==.',['猎空']='猎空:BAAALAAECgMIAwAAAA==.',['猎行']='猎行天下麒麟:BAAALAAECgEIAQAAAA==.',['猥者']='猥者至尊:BAAALAADCgUIBQAAAA==.',['猫不']='猫不是我家滴:BAABLAAFFH8KAAIeAAUI9hNTBAACAQAeAAUI9hNTBAACAQAAAA==.',['猫就']='猫就是我家滴:BAACLAAFFH8jAAIfAAYI/RPBDwBOAQAfAAYI/RPBDwBOAQAsAAQKfyYAAh8ABwhNGtsTACQCAB8ABwhNGtsTACQCAAAA.',['玛利']='玛利亚屁屁:BAAALAAECgUIBQAAAA==.',['琉羽']='琉羽汐:BAAALAAECgYIBgAAAA==.',['瑶一']='瑶一瑶:BAAALAAECgIIAgAAAA==.',['生命']='生命终章:BAAALAAFFAIIBAAAAA==.',['电气']='电气精灵:BAAALAAECgYICwAAAA==.',['疋爿']='疋爿奥特曼:BAABLAAFFH8HAAICAAUIRhNkTwAQAQACAAUIRhNkTwAQAQAAAA==.',['疯狂']='疯狂的牛牛:BAAALAAECgMIBAAAAA==.疯狂的飞机丶:BAAALAADCgcIAgAAAA==.',['痞子']='痞子术:BAAALAAECgYIBwAAAA==.',['白山']='白山茶丶:BAAALAAFFAIIAgAAAA==.',['白芷']='白芷:BAAALAAFFAIIAgAAAA==.',['白雪']='白雪精灵:BAAALAAECgMIBgAAAA==.',['百发']='百发百中丶:BAABLAAFFH8IAAIWAAgIzQCFHAAmAAAWAAgIzQCFHAAmAAAAAA==.',['皆过']='皆过客:BAAALAAECgIIAgAAAA==.',['看我']='看我眼神行动:BAAALAAECgEIAQAAAA==.',['看见']='看见快乐老用:BAAALAAECgIIAgAAAA==.',['真是']='真是无语:BAAALAADCgEIAQAAAA==.',['眼见']='眼见喜:BAABLAAFFH8GAAIaAAYI+wFmEwDTAAAaAAYI+wFmEwDTAAAAAA==.',['睁眼']='睁眼瞎:BAAALAAFFAIIAgAAAA==.',['石川']='石川恩斯惠:BAAALAAECgYIBgAAAA==.',['破城']='破城卒:BAAALAAECgYIBgAAAA==.',['破釜']='破釜沉舟:BAABLAAFFH8tAAINAAgIBiNZAgDaAgANAAgIBiNZAgDaAgAAAA==.',['硬条']='硬条:BAAALAAECgYIDAAAAA==.',['祝福']='祝福之歌:BAAALAAECggIDgAAAA==.',['神棍']='神棍:BAAALAAECgYICwAAAA==.',['福星']='福星高照:BAAALAADCgMIAwAAAA==.',['种牛']='种牛:BAAALAAFFAEIAQAAAA==.',['立花']='立花里子丶:BAAALAAECgYIDAAAAA==.',['端坐']='端坐霜天:BAAALAAECgIIAgAAAA==.',['笃定']='笃定:BAAALAAECgUIBQAAAA==.',['笨犇']='笨犇犇:BAAALAAECgQIBAAAAA==.',['第十']='第十三:BAAALAAFFAIIAgAAAA==.',['等我']='等我升腾:BAABLAAFFH8lAAIUAAYIgCA6CQDqAQAUAAYIgCA6CQDqAQAAAA==.',['等风']='等风起:BAACLAAFFH8XAAINAAYIeBazDgCpAQANAAYIeBazDgCpAQAsAAQKfxYAAg0ABgjtH8BVAO8BAA0ABgjtH8BVAO8BAAAA.',['米娜']='米娜:BAAALAAECgEIAQAAAA==.',['米花']='米花:BAAALAADCggIEAAAAA==.',['米饭']='米饭丶风行者:BAAALAAECggIBgAAAA==.',['粉牛']='粉牛:BAAALAAFFAEIAQAAAA==.',['糖醋']='糖醋苹果:BAABLAAFFH8IAAITAAgINhRNDwABAgATAAgINhRNDwABAgAAAA==.',['糖门']='糖门佐道:BAAALAADCgcIBwAAAA==.',['素心']='素心忘情:BAAALAAECgIIAgAAAA==.',['索兰']='索兰:BAAALAADCggICAAAAA==.',['紫彤']='紫彤:BAABLAAFFH8IAAIMAAII5Qw5PwBsAAAMAAII5Qw5PwBsAAAAAA==.',['絳雪']='絳雪:BAABLAAFFH8GAAMLAAYIgxwXCgCqAQALAAUIlBwXCgCqAQAMAAEImBL3RgBQAAABLAAFFAgIBQAMALAfAA==.',['红美']='红美玲:BAAALAAECggIBAAAAA==.',['纯害']='纯害人的:BAABLAAFFH8MAAMDAAcIMRc+CgBtAQADAAYIJhc+CgBtAQAEAAIIdB1qEgBOAAAAAA==.',['纯情']='纯情学生妹:BAAALAAECgIIAgAAAA==.',['纳格']='纳格兰的星空:BAAALAAFFAIIAgAAAA==.',['纵横']='纵横乄龍战:BAAALAAECgIIAgAAAA==.',['终结']='终结小队:BAABLAAFFH8oAAIIAAYIriKWEwDzAQAIAAYIriKWEwDzAQAAAA==.',['绘雪']='绘雪灵儿冫:BAAALAAECgcIBwAAAA==.',['给力']='给力就好:BAAALAAFFAIIAgAAAA==.',['给钱']='给钱才医病:BAAALAAFFAIIBAAAAA==.',['绥破']='绥破坏:BAAALAAECgMIAwAAAA==.',['罐罐']='罐罐发财九:BAAALAAECggIAgAAAA==.罐罐发财四:BAAALAAECgYIBQAAAA==.',['羅蘭']='羅蘭蘭:BAABLAAFFH8GAAIVAAYI1hrFFwCsAQAVAAYI1hrFFwCsAQAAAA==.',['老子']='老子是天棒乄:BAAALAAFFAIIAgAAAA==.',['老铁']='老铁:BAAALAAECgcIDgAAAA==.',['耗爺']='耗爺:BAAALAAECgUIBQAAAA==.',['肉奥']='肉奥:BAAALAAECgYIBgAAAA==.',['肥思']='肥思:BAAALAAECgIIAgAAAA==.',['肾虚']='肾虚骑士:BAABLAAECn8aAAIIAAcITB37XAA8AgAIAAcITB37XAA8AgAAAA==.',['肾骑']='肾骑士:BAABLAAFFH8FAAIHAAMIWA3cEQBmAAAHAAMIWA3cEQBmAAAAAA==.',['胖垚']='胖垚:BAAALAADCgMIAwAAAA==.',['能忍']='能忍归来:BAAALAADCgEIAQAAAA==.',['能起']='能起吗:BAAALAAFFAIIBAAAAA==.',['腊月']='腊月初柒:BAAALAAECgIIAgAAAA==.',['腾云']='腾云美式咖啡:BAAALAAECgYICAAAAA==.',['舌尝']='舌尝思:BAAALAAECgYIBgAAAA==.',['艾斯']='艾斯卡诺:BAACLAAFFH8OAAIFAAII1iCLOwChAAAFAAII1iCLOwChAAAsAAQKfycAAwUABgiDI/FQAE0CAAUABgiKIvFQAE0CAAcABgiCG9ciAOUBAAAA.',['芙宁']='芙宁娜大冲撞:BAACLAAFFH8JAAIGAAMIsxN5JgC5AAAGAAMIsxN5JgC5AAAsAAQKfxkAAgYACAi1FwhXAOABAAYACAi1FwhXAOABAAAA.',['苍嵐']='苍嵐鳕:BAAALAAFFAIIAgAAAA==.',['苏妲']='苏妲季:BAAALAADCgUIBQAAAA==.',['苏菲']='苏菲丶玛索:BAABLAAFFH8LAAIIAAMICBlwVACeAAAIAAMICBlwVACeAAAAAA==.',['苗儿']='苗儿:BAAALAAECgYIBgAAAA==.',['莫利']='莫利亚蒂:BAAALAAFFAEIAQAAAA==.',['莫夜']='莫夜溟:BAAALAAECgIIAwAAAA==.',['莱戈']='莱戈拉斯乄:BAAALAAECgUIBQAAAA==.',['萌物']='萌物:BAAALAAECgUICwAAAA==.',['萌萌']='萌萌大国宝:BAAALAAECgMIBAAAAA==.萌萌尐姐姐:BAAALAAECgYIBgAAAA==.萌萌若水:BAAALAADCggICAAAAA==.萌萌蓝筱:BAAALAADCgYIBgAAAA==.',['萨迪']='萨迪克:BAAALAAECgEIAQAAAA==.',['葉奈']='葉奈法:BAAALAAECggICAAAAA==.',['葬爱']='葬爱十七:BAAALAAECgYICQAAAA==.葬爱家族:BAAALAAECgYIBgAAAA==.',['蒋劲']='蒋劲夫:BAAALAADCggICAAAAA==.',['蓝绿']='蓝绿红牛:BAAALAAECggICAAAAA==.',['薇恩']='薇恩:BAAALAADCgMIAwAAAA==.',['蘇櫻']='蘇櫻:BAABLAAFFH8IAAIMAAgIAwA1UwAKAAAMAAgIAwA1UwAKAAAAAA==.',['蜜蜂']='蜜蜂蜂蜜:BAAALAAECgYIBgAAAA==.',['蜜雪']='蜜雪冰橙:BAAALAADCgYIBgAAAA==.',['袁小']='袁小喵:BAAALAADCggIEQAAAA==.',['被卡']='被卡在黑洞中:BAAALAAFFAIIBAAAAA==.',['解梦']='解梦:BAAALAAECgEIAQAAAA==.',['让风']='让风吹醒你:BAAALAAECggICAAAAA==.',['语过']='语过嫣然:BAAALAAECgYIDAAAAA==.',['请你']='请你食三文鱼:BAAALAADCggICAAAAA==.',['谢夫']='谢夫涅:BAAALAAECgEIAQAAAA==.',['豆皮']='豆皮欢喜坨:BAAALAAECgYIDQAAAA==.',['豉汁']='豉汁排骨煲饭:BAABLAAFFH8MAAIYAAYIbxdxBADRAQAYAAYIbxdxBADRAQAAAA==.',['贝戋']='贝戋人:BAAALAADCgMIAwAAAA==.',['贝贝']='贝贝:BAABLAAFFH8GAAIFAAYIUQiQJwA9AQAFAAYIUQiQJwA9AQAAAA==.',['贪婪']='贪婪强袭:BAAALAADCgIIAgAAAA==.',['贫道']='贫道劫个色:BAAALAADCgIIAgAAAA==.',['贱仔']='贱仔:BAAALAAECgIIAgAAAA==.',['贼羊']='贼羊羊:BAAALAAECggIAgAAAA==.',['赞达']='赞达拉崛起:BAAALAAECgYIDQAAAA==.',['赫萝']='赫萝:BAABLAAFFH8KAAIGAAQIcRU8KwAMAQAGAAQIcRU8KwAMAQAAAA==.',['赵老']='赵老师:BAAALAAECgMIAwAAAA==.',['超凡']='超凡:BAABLAAECn8VAAMGAAYIAhOoRQBDAQAGAAYIAhOoRQBDAQAUAAQIcg65oQDRAAAAAA==.',['践踏']='践踏战争:BAAALAAECgYICAAAAA==.',['踏绘']='踏绘:BAACLAAFFH8oAAIRAAYIIg0iCgBfAQARAAYIIg0iCgBfAQAsAAQKfyAAAhEACAgjEkIxAKgBABEACAgjEkIxAKgBAAAA.',['踩死']='踩死囧猫:BAAALAAFFAIIAgAAAA==.',['达拉']='达拉崩吧:BAAALAAECgYIBgABLAAECgcICAAOAAAAAA==.',['过河']='过河卒:BAAALAAECgYICgAAAA==.',['迈克']='迈克戴维斯:BAAALAADCgIIAgAAAA==.',['进击']='进击的官人:BAAALAAECgYIBgAAAA==.',['迷你']='迷你烤鸡翅:BAABLAAFFH8PAAIgAAUI6gvkDAAcAQAgAAUI6gvkDAAcAQAAAA==.迷你烤鸡腿:BAAALAADCgIIAgAAAA==.',['迷小']='迷小龙:BAAALAAECgYIBwAAAA==.',['逆水']='逆水魔乳:BAABLAAECn8iAAMGAAgItQsYagDFAAAGAAgItQsYagDFAAAUAAEIYQHFhQAMAAAAAA==.',['逗豆']='逗豆:BAAALAAECgUIBQAAAA==.',['逹蓋']='逹蓋爾的旗帜:BAABLAAFFH8GAAICAAYI3hH7MgBvAQACAAYI3hH7MgBvAQAAAA==.',['遇鬼']='遇鬼斩鬼:BAAALAADCgEIAQAAAA==.',['邪恶']='邪恶的渣爷:BAAALAAFFAIIAgAAAA==.',['邪能']='邪能汉堡:BAAALAAFFAMIAwAAAA==.',['邪魅']='邪魅:BAAALAAECgMIAwAAAA==.',['郑吒']='郑吒:BAAALAADCgYIBwAAAA==.',['都是']='都是檰椛:BAAALAAECgIIAgAAAA==.',['醉月']='醉月丶觞:BAABLAAFFH8uAAMTAAcI6CAkCQBQAgATAAcI6CAkCQBQAgAhAAEIBgP9DgA5AAAAAA==.',['醉雨']='醉雨清晨:BAAALAAECgYICgAAAA==.醉雨清風:BAAALAAECgYIBgAAAA==.醉雨轻枫:BAAALAAECgEIAQAAAA==.',['重生']='重生丶:BAABLAAFFH8GAAIbAAYIawToDwD8AAAbAAYIawToDwD8AAAAAA==.',['銅鑼']='銅鑼灣扛把子:BAAALAAECgYIDwABLAAFFAYIGgAFAFwcAA==.',['錘龘']='錘龘:BAABLAAFFH8OAAIIAAUIGxAQRQAmAQAIAAUIGxAQRQAmAQAAAA==.',['钕神']='钕神矜嘚祈愿:BAAALAAECgMIBAAAAA==.',['铁人']='铁人老五:BAAALAAFFAIIAwAAAA==.',['铺路']='铺路的:BAABLAAECn8cAAICAAgIDB93OgB2AgACAAgIDB93OgB2AgAAAA==.',['锅盖']='锅盖头:BAABLAAFFH8WAAIFAAYInh0PDQDbAQAFAAYInh0PDQDbAQAAAA==.',['锯末']='锯末慕师:BAAALAAECgEIAQAAAA==.',['门房']='门房大爷:BAAALAAECgQIBAAAAA==.',['闪电']='闪电皮卡丘:BAAALAAECgIIAgAAAA==.',['阿尔']='阿尔星河:BAAALAAECgYIEgAAAA==.',['阿纳']='阿纳克洛斯:BAAALAADCgUIBQAAAA==.',['阿臀']='阿臀牧:BAAALAADCggIEQAAAA==.',['陆佰']='陆佰壹拾柒:BAAALAAFFAQIBAAAAA==.',['隐秘']='隐秘通途:BAABLAAECn8UAAIVAAYIzxm/hgC4AQAVAAYIzxm/hgC4AQAAAA==.',['雨丶']='雨丶:BAAALAAECgQIBQAAAA==.',['雪崩']='雪崩:BAAALAAECgUIDAAAAA==.',['雪溅']='雪溅四方:BAABLAAFFH8GAAIIAAIIExDhbQCRAAAIAAIIExDhbQCRAAAAAA==.',['雷丘']='雷丘丶:BAAALAADCgIIAgAAAA==.',['霜火']='霜火圣光:BAACLAAFFH8gAAMFAAYIMSNVCgD0AQAFAAYIMSNVCgD0AQAHAAIIYhMiGAA+AAAsAAQKfyUAAwcABwjLIxkXAD8CAAcABwhJHBkXAD8CAAUABwjLI0xqAC4BAAAA.',['青椒']='青椒荷包蛋:BAAALAADCgEIAQAAAA==.',['面條']='面條:BAAALAADCggICAAAAA==.',['鞭鞭']='鞭鞭:BAAALAAECgcIDQAAAA==.',['顶住']='顶住火力:BAAALAADCgUIBQAAAA==.',['频烦']='频烦之鹿:BAAALAAECgcICAAAAA==.',['风情']='风情微解:BAAALAAECgYIBgAAAA==.',['风暴']='风暴意志:BAAALAAECgIIAgAAAA==.',['香皂']='香皂丶:BAAALAAECggIDgAAAA==.',['高毛']='高毛豆:BAAALAAECgIIAgAAAA==.',['鬼丨']='鬼丨鬼:BAABLAAFFH8GAAICAAYI3BuXIQCsAQACAAYI3BuXIQCsAQAAAA==.',['魔卡']='魔卡少牛:BAAALAAECgIIAgAAAA==.',['魔术']='魔术大师:BAAALAAFFAIIAgAAAA==.',['魔法']='魔法披风:BAABLAAECn8fAAICAAYI4xN9lwAlAQACAAYI4xN9lwAlAQAAAA==.',['鱼幼']='鱼幼真:BAAALAAECgQIBAAAAA==.',['鱼心']='鱼心丸子:BAAALAAFFAIIBAAAAA==.',['麦小']='麦小琪:BAAALAAECgYIDQAAAA==.',['麦香']='麦香园:BAAALAAECgEIAQAAAA==.',['麻油']='麻油恶丶:BAABLAAFFH8MAAIcAAMIWROfCAC1AAAcAAMIWROfCAC1AAAAAA==.',['黄粱']='黄粱一萌:BAAALAAECgEIAQAAAA==.',['黎明']='黎明前的审判:BAAALAAFFAIIBAABLAAFFAYIFQAIAKYZAA==.黎明的光晕:BAABLAAECn8eAAIWAAgIih3dBABEAgAWAAgIih3dBABEAgAAAA==.',['黑夜']='黑夜灬绽放:BAAALAAECgcIBwAAAA==.',['黑豌']='黑豌豆:BAAALAAECgMIAwAAAA==.',['黑雪']='黑雪姬:BAAALAADCgMIAwAAAA==.',['鼻嗅']='鼻嗅爱:BAAALAAECggICAAAAA==.',['龍少']='龍少爷:BAABLAAFFH8IAAIFAAIIeRKPaABCAAAFAAIIeRKPaABCAAAAAA==.',['龙裔']='龙裔:BAAALAADCgQIBAAAAA==.',['龙魂']='龙魂小德:BAAALAADCgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end