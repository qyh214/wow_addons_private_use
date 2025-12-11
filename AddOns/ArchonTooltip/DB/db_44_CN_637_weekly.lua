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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','DeathKnight-Frost','DeathKnight-Unholy','Monk-Brewmaster','Warlock-Destruction','Evoker-Preservation','Evoker-Devastation','Warlock-Demonology','Druid-Restoration','Shaman-Elemental','Paladin-Holy','Shaman-Restoration','DemonHunter-Havoc','Druid-Balance','Paladin-Retribution','Monk-Mistweaver','Paladin-Protection','Mage-Arcane','Unknown-Unknown','Warrior-Protection','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Vengeance','Priest-Shadow','Priest-Holy','Druid-Guardian','Warrior-Fury','DeathKnight-Blood','Monk-Windwalker','Evoker-Augmentation','Mage-Fire',}; local provider = {region='CN',realm='奈萨里奥',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ag='Agrainofsand:BAAALAAFFAIIBAAAAA==.',Al='Alteregos:BAAALAAECgYIBgAAAA==.',An='Anastasia:BAAALAAECgYIBgAAAA==.Angelcat:BAACLAAFFH8MAAIBAAIIexGsnAA/AAABAAIIexGsnAA/AAAsAAQKfyQAAwEABghWF1zDAHsBAAEABgjKFlzDAHsBAAIABggaEBhkADEBAAAA.Anubis:BAAALAAECgYIBgAAAA==.',As='Ashly:BAAALAAECgYIBwAAAA==.',Be='Becci:BAAALAAECgYICQAAAA==.',Bl='Bloodwarlock:BAAALAAFFAIIBAAAAA==.',Ca='Caat:BAAALAADCgEIAQAAAA==.',Cc='Ccmilk:BAAALAADCggICAAAAA==.',Cj='Cjjlilill:BAAALAAECgIIAgAAAA==.',Dc='Dcsakura:BAABLAAFFH8KAAIDAAYITAeACAANAQADAAYITAeACAANAQAAAA==.',El='Elysia:BAAALAAECgYIBwAAAA==.',Ev='Evenbeloved:BAAALAAFFAIIAgAAAA==.',Fa='Fatalviolet:BAAALAAECgYICAAAAA==.',Gc='Gcup:BAAALAAFFAIIAQAAAA==.',Gg='Ggpo:BAAALAAECgYIDgAAAA==.',Gj='Gjmax:BAACLAAFFH8KAAIEAAIISBsvaQCUAAAEAAIISBsvaQCUAAAsAAQKfxcAAwQABgg1I3ZUAE4CAAQABgg1I3ZUAE4CAAUAAQj6GipaAEAAAAAA.',Gr='Grimrak:BAAALAAECgIIAgAAAA==.',In='Injoker:BAABLAAFFH8NAAIGAAMIpAJtHABMAAAGAAMIpAJtHABMAAAAAA==.',La='Lancelots:BAAALAAECgQIBAAAAA==.',Lu='Lucien:BAACLAAFFH8UAAIHAAUIehYYMwBJAQAHAAUIehYYMwBJAQAsAAQKfxYAAgcACAg1GA8gAOcBAAcACAg1GA8gAOcBAAAA.',Ma='Marquez:BAACLAAFFH8WAAMIAAIIBhpkEQCcAAAIAAIIBhpkEQCcAAAJAAIIIAKQJQAfAAAsAAQKfycAAwgACAhRHp0IAKkCAAgACAhRHp0IAKkCAAkABQjLDyNHABsBAAAA.Maysuan:BAABLAAFFH8JAAIHAAMIlA1xTwB8AAAHAAMIlA1xTwB8AAAAAA==.',Mi='Miselly:BAAALAAECgYIBgAAAA==.',Ol='Oldgun:BAAALAAECggICgAAAA==.',Pr='Prayrain:BAAALAAFFAIIAgAAAA==.',Ro='Royle:BAABLAAFFH8GAAMKAAYIng25BAATAQAKAAUIqw+5BAATAQAHAAEIWwMdbQAzAAAAAA==.',Se='Selene:BAAALAAECgQIBAAAAA==.',So='Solciella:BAABLAAFFH8KAAILAAIIRCFYHACxAAALAAIIRCFYHACxAAAAAA==.Soloshow:BAABLAAFFH8LAAMBAAMIqyWAWwDYAAABAAMIqyWAWwDYAAACAAEIpwffNwA3AAAAAA==.',Sv='Sven:BAAALAAECggICAAAAA==.',Sz='Szeretlek:BAAALAAFFAIIAgAAAA==.',Ti='Tibei:BAABLAAFFH8GAAIEAAYIMBHoNQBkAQAEAAYIMBHoNQBkAQAAAA==.Tiefang:BAAALAAECgYIBgABLAAFFAcIDQAMAPsFAA==.',To='Torres:BAAALAAECgIIAgAAAA==.',Va='Vacation:BAAALAAECgYIEAAAAA==.Vaxiya:BAABLAAECn8WAAINAAgI2Q34GwBpAQANAAgI2Q34GwBpAQAAAA==.',Zo='Zombie:BAAALAAFFAIIAgAAAA==.',['一之']='一之黑亚梨子:BAABLAAFFH8IAAIOAAIIIBH6WQBnAAAOAAIIIBH6WQBnAAAAAA==.',['一击']='一击入魂:BAAALAAECgMIAwAAAA==.',['一发']='一发入魂:BAAALAAFFAIIBAAAAA==.',['一年']='一年一寂:BAAALAADCggICAAAAA==.',['一梦']='一梦:BAAALAAECgIIAgAAAA==.',['一般']='一般通过肥猫:BAAALAAECgYIDAAAAA==.',['一颗']='一颗蛋:BAABLAAECn8ZAAIPAAYIqQhm7QANAQAPAAYIqQhm7QANAQAAAA==.',['七擒']='七擒萌货:BAACLAAFFH8qAAILAAYIiB5OCQAYAgALAAYIiB5OCQAYAgAsAAQKfyQAAwsABwg1IIAfAHICAAsABwg1IIAfAHICABAAAQjGGQ1aAE0AAAAA.',['万山']='万山之巅:BAAALAADCgYIBgAAAA==.',['三生']='三生花:BAAALAAECgYICgAAAA==.',['上帝']='上帝掷骰子:BAABLAAECn8YAAIPAAYIjQ/YWgANAQAPAAYIjQ/YWgANAQAAAA==.',['上海']='上海地板王:BAAALAAECgYIDAAAAA==.',['不落']='不落小莱妹:BAAALAAFFAIIAgAAAA==.不落模范好牛:BAAALAAFFAIIAgAAAA==.不落酸牛牛:BAAALAAFFAIIBAAAAA==.不落酸酸:BAAALAAECgQIBAAAAA==.',['丑也']='丑也是小师妹:BAABLAAFFH8IAAIRAAIIoR0tVgBMAAARAAIIoR0tVgBMAAAAAA==.',['东门']='东门笑嘻嘻:BAAALAAECgUIDgAAAA==.',['两仪']='两仪式:BAAALAAECgYICAAAAA==.',['丽蒂']='丽蒂丶墨菲斯:BAAALAAFFAIIAgAAAA==.',['九音']='九音小心前面:BAAALAAECgEIAQAAAA==.',['二柱']='二柱子:BAABLAAFFH8GAAIPAAIILwgtYwA8AAAPAAIILwgtYwA8AAAAAA==.',['亦瑤']='亦瑤:BAABLAAFFH8GAAILAAYIqhaDEwCfAQALAAYIqhaDEwCfAQAAAA==.',['亦瑶']='亦瑶:BAABLAAECn8VAAIOAAgI9R08DACgAgAOAAgI9R08DACgAgAAAA==.',['亦窈']='亦窈:BAACLAAFFH8GAAISAAYIzgcYDAA3AQASAAYIzgcYDAA3AQAsAAQKfzIAAhIACAiwIoAGAP0CABIACAiwIoAGAP0CAAAA.',['人间']='人间指南:BAAALAAECgEIAQAAAA==.',['伊利']='伊利斯丶逐星:BAAALAAECgYIDAAAAA==.伊利达蕾:BAAALAAECgYICgAAAA==.',['伊姆']='伊姆卡:BAAALAAECggICAAAAA==.',['你黑']='你黑劳资:BAAALAAECgYIBgAAAA==.',['修羅']='修羅之刻:BAAALAAFFAIIBAAAAA==.',['傅风']='傅风雪:BAAALAAFFAIIAgAAAA==.',['元素']='元素祝福:BAABLAAFFH8cAAIRAAYIkxgnGACSAQARAAYIkxgnGACSAQAAAA==.',['光头']='光头就是刚猛:BAABLAAFFH8GAAIPAAYI5BzGFQC4AQAPAAYI5BzGFQC4AQAAAA==.',['光师']='光师傅:BAAALAAFFAMIAwAAAA==.',['光环']='光环小强:BAAALAADCgYIBgAAAA==.',['光老']='光老师:BAAALAAECgYIEwAAAA==.',['克伦']='克伦薇尔:BAACLAAFFH8OAAITAAQIQga7CADWAAATAAQIQga7CADWAAAsAAQKfxsAAxMACAjkFuMdAAkCABMACAjkFuMdAAkCAA0AAQivCRxGACgAAAAA.',['兰斯']='兰斯洛特:BAABLAAFFH8SAAIRAAYIRQoJTgBeAAARAAYIRQoJTgBeAAABLAAFFAgICAARAFQTAA==.',['关山']='关山枫岳:BAAALAAECgcICQAAAA==.关山清缘:BAAALAAECgIIAgAAAA==.关山炫餶:BAAALAAECgYIEAAAAA==.关山飞雨:BAAALAAECgQIBAAAAA==.',['冷月']='冷月飘零丶:BAABLAAFFH8KAAMNAAIIrhHQJgBwAAANAAIIrhHQJgBwAAATAAIIAgxWHQAwAAAAAA==.',['凉拌']='凉拌西蓝花丶:BAAALAAECgYICgAAAA==.',['凝葉']='凝葉成霜丶:BAAALAAFFAIIBAAAAA==.凝葉無霜丶:BAABLAAFFH8KAAIEAAIIKyFfWACcAAAEAAIIKyFfWACcAAAAAA==.',['凰之']='凰之游侠潇洒:BAAALAAECggICAAAAA==.',['初中']='初中学姐:BAABLAAFFH8IAAIBAAYIARZSPABSAQABAAYIARZSPABSAQAAAA==.',['初音']='初音镜:BAABLAAFFH8LAAIPAAMIvBGCTgBKAAAPAAMIvBGCTgBKAAAAAA==.',['别急']='别急:BAABLAAFFH8NAAIOAAIITyLkOQC7AAAOAAIITyLkOQC7AAAAAA==.',['剑秀']='剑秀凌云:BAAALAAECgEIAQAAAA==.',['力巴']='力巴伊赫:BAAALAADCggICAAAAA==.',['勇敢']='勇敢的心:BAAALAADCgEIAQAAAA==.',['勿忘']='勿忘我:BAAALAADCggICAAAAA==.',['千层']='千层纸:BAABLAAFFH8NAAIEAAYIEQJzZACDAAAEAAYIEQJzZACDAAAAAA==.',['千早']='千早灬法:BAAALAAFFAYIAgAAAA==.',['卡斯']='卡斯得艾斯:BAAALAAECgQIBAAAAA==.',['卡西']='卡西亚托马斯:BAAALAAECgYICwAAAA==.',['叮耶']='叮耶叮不咚:BAABLAAFFH8VAAIBAAYI6yDxFwDYAQABAAYI6yDxFwDYAQAAAA==.',['可乐']='可乐酸奶白喵:BAAALAADCggICAAAAA==.',['可怕']='可怕的小宝宝:BAAALAAFFAIIAgAAAA==.',['可楽']='可楽加牛奶:BAABLAAFFH8KAAIUAAIIPxlVTACUAAAUAAIIPxlVTACUAAAAAA==.',['可樂']='可樂加牛奶:BAAALAAFFAIIBAABLAAFFAgIAwAVAAAAAA==.',['名字']='名字长人品好:BAABLAAFFH8GAAIWAAIIsApHNAAuAAAWAAIIsApHNAAuAAAAAA==.',['咕嘟']='咕嘟一口:BAAALAAECgIIAgAAAA==.',['咸鱼']='咸鱼抽脸:BAABLAAFFH8KAAIRAAIIhBJWaQBCAAARAAIIhBJWaQBCAAAAAA==.',['咻咻']='咻咻棉糀餹:BAAALAAECgQIBQAAAA==.',['哈切']='哈切叭嗒:BAACLAAFFH8MAAIBAAYIjRKiOQBaAQABAAYIjRKiOQBaAQAsAAQKfxoAAgEACAhzH0ITAIsCAAEACAhzH0ITAIsCAAAA.',['哈姐']='哈姐天灾:BAAALAADCggICAAAAA==.',['唐牛']='唐牛才是食神:BAAALAAFFAMIAgAAAA==.',['唔开']='唔开心:BAAALAAECgYIBgAAAA==.',['唔自']='唔自闭:BAAALAAECgYIBgAAAA==.',['啵啵']='啵啵萨:BAAALAAFFAIIAwAAAA==.',['嗜血']='嗜血丨师妹:BAAALAAECgYIDAAAAA==.',['嗨呀']='嗨呀嗨呀嗨呀:BAAALAAECgUIBQAAAA==.',['地狱']='地狱一刀:BAAALAAECgQIBgAAAA==.地狱一酒鬼:BAAALAAECgYIEwAAAA==.',['埃波']='埃波利耶塔:BAAALAAECgYIBwAAAA==.',['堕天']='堕天使一魅魔:BAAALAAECgYICAAAAA==.',['墨云']='墨云子:BAAALAAFFAIIAgAAAA==.',['墨染']='墨染樱飞:BAAALAAECgEIAQAAAA==.',['多毛']='多毛体制:BAAALAAECgYIDAAAAA==.',['夜乂']='夜乂:BAACLAAFFH8GAAIPAAIIqA10WQBDAAAPAAIIqA10WQBDAAAsAAQKfxYAAg8ABghfHydYAB0CAA8ABghfHydYAB0CAAAA.',['夜之']='夜之愿:BAACLAAFFH8KAAMXAAII+g2oGACdAAAXAAII+g2oGACdAAAYAAIIEAjCFQBBAAAsAAQKfxkAAxcABgihHnczAJgBABcABQhxH3czAJgBABgABQiqFp4qAEUBAAAA.',['夜怒']='夜怒:BAAALAAECgYIDAAAAA==.',['夜愿']='夜愿:BAAALAAECggICAAAAA==.',['夜雨']='夜雨晨露:BAAALAAECgUIBgAAAA==.',['夢幻']='夢幻鯨靈:BAAALAAECggIBgAAAA==.',['大名']='大名叫上帝:BAAALAAECgYICwAAAA==.',['大块']='大块强光碎片:BAABLAAFFH8cAAIRAAYIgSSaBwAPAgARAAYIgSSaBwAPAgAAAA==.',['大登']='大登登:BAAALAAFFAIIBAAAAA==.',['大葱']='大葱蘸大酱:BAABLAAFFH8IAAIEAAIIAgo1mgA5AAAEAAIIAgo1mgA5AAAAAA==.',['大贤']='大贤良师:BAABLAAFFH8IAAIBAAIIwhq/iQBIAAABAAIIwhq/iQBIAAAAAA==.',['大飞']='大飞哥:BAAALAAECggICAAAAA==.',['大鬼']='大鬼头:BAAALAADCgcIBwAAAA==.',['天下']='天下唯一:BAAALAAFFAIIAgAAAA==.',['天之']='天之藍:BAABLAAFFH8KAAIDAAIIaRXGFQBDAAADAAIIaRXGFQBDAAAAAA==.',['天地']='天地一颖宝:BAAALAAECgYIBgAAAA==.',['天龙']='天龙仁:BAABLAAFFH8KAAIJAAIIvApGHQCAAAAJAAIIvApGHQCAAAAAAA==.',['奥特']='奥特曼:BAAALAADCgYIBgAAAA==.奥特曼丶:BAAALAADCgEIAQAAAA==.',['奶猪']='奶猪:BAAALAAECgYIBgAAAA==.',['好好']='好好说话:BAAALAAFFAEIAQAAAA==.',['妈再']='妈再奶我一次:BAAALAAECgMIAwAAAA==.',['孤独']='孤独的旅者:BAAALAAECggIBQAAAA==.',['孻月']='孻月飘零:BAACLAAFFH8MAAIUAAIIfxE6UgBKAAAUAAIIfxE6UgBKAAAsAAQKfyYAAxQACAiqF6kYAOQBABQACAiqF6kYAOQBAAMAAgh8D22DAGEAAAAA.',['密涅']='密涅娃:BAAALAAECgYIBwAAAA==.',['寒冰']='寒冰电链:BAAALAAFFAIIAgAAAA==.',['小周']='小周老师:BAAALAAFFAIIAgAAAA==.',['小哑']='小哑巴:BAAALAAECggIDgABLAAFFAgIBgAWAJwbAA==.',['小喷']='小喷嚏:BAABLAAFFH8IAAIRAAIILAgtcAA+AAARAAIILAgtcAA+AAAAAA==.',['小块']='小块强光碎片:BAABLAAFFH8dAAIEAAYIzR4sHgC8AQAEAAYIzR4sHgC8AQAAAA==.',['小妲']='小妲己:BAAALAAECgYIBgAAAA==.',['小萌']='小萌兜:BAAALAAECgYIDQAAAA==.',['小酸']='小酸酸:BAAALAAECgQICAAAAA==.',['小门']='小门童:BAACLAAFFH8mAAIUAAYIHCSBEAD2AQAUAAYIHCSBEAD2AQAsAAQKfxoAAhQABghhJYYTABECABQABghhJYYTABECAAAA.',['小黑']='小黑角:BAAALAADCgQIBAABLAADCgcIBwAVAAAAAA==.',['少林']='少林寺的土豆:BAAALAADCgIIAgAAAA==.',['就是']='就是菜:BAAALAAECgYIDAAAAA==.',['尾巴']='尾巴真有型:BAAALAAFFAIIAgAAAA==.',['山之']='山之风岚:BAAALAAECgYICQAAAA==.',['工藤']='工藤峰子:BAAALAAFFAIIBAAAAA==.工藤疯子:BAABLAAFFH8FAAIBAAMIUROQSACbAAABAAMIUROQSACbAAAAAA==.工藤锋子:BAAALAAFFAIIBAAAAA==.',['布坦']='布坦:BAAALAAECgUICQAAAA==.',['帅帅']='帅帅的小洒:BAAALAAECgEIAQAAAA==.',['希尔']='希尔瓦那斯:BAAALAADCgQIBAAAAA==.希尔萨斯:BAABLAAFFH8KAAIPAAQIAQubGAAUAQAPAAQIAQubGAAUAQAAAA==.',['幻灭']='幻灭梦想:BAAALAAFFAIIBAAAAA==.',['异想']='异想魅惑:BAAALAAFFAIIBAAAAA==.',['影天']='影天使一刀客:BAAALAAECgIIAgAAAA==.',['往后']='往后余生:BAAALAAECgYICwAAAA==.',['忘了']='忘了离开:BAAALAAECgUICAAAAA==.',['忘记']='忘记施法:BAAALAAECgYIBgAAAA==.',['怒及']='怒及吾命:BAAALAAECgEIAQAAAA==.',['怪叔']='怪叔叔的逆袭:BAACLAAFFH8eAAIRAAYIcBUHGgCIAQARAAYIcBUHGgCIAQAsAAQKfysAAhEACAhEHlc2AJoCABEACAhEHlc2AJoCAAAA.',['恶魔']='恶魔姬:BAAALAAFFAEIAQAAAA==.',['悠悠']='悠悠丶:BAAALAAECgIIAgAAAA==.',['我叫']='我叫脑缠吼:BAAALAAECgIIAgAAAA==.',['我是']='我是神:BAAALAAFFAIIAgAAAA==.',['我最']='我最美:BAAALAAECgYIBgAAAA==.',['我若']='我若成风:BAAALAAECgUIBgAAAA==.',['我顶']='我顶你锅肺:BAAALAAECggICAAAAA==.',['扛靶']='扛靶子:BAAALAAECgYIBgAAAA==.',['抗怪']='抗怪抗到晕:BAAALAAFFAIIAgAAAA==.',['挨打']='挨打全能:BAAALAAECgYIBgAAAA==.',['捣蛋']='捣蛋鬼狐狸:BAAALAAFFAMIAwAAAA==.',['摸出']='摸出个大鸟:BAABLAAFFH8FAAIEAAIIPxasgABFAAAEAAIIPxasgABFAAAAAA==.',['断舍']='断舍离:BAABLAAFFH8JAAIZAAMINAPaDgB9AAAZAAMINAPaDgB9AAAAAA==.',['旋涡']='旋涡鸣人:BAAALAAECgIIAwAAAA==.',['旺旺']='旺旺仙贝:BAACLAAFFH8XAAITAAYIuxvaBABFAQATAAYIuxvaBABFAQAsAAQKfxcAAhMACAjPIacKAM8CABMACAjPIacKAM8CAAEsAAUUCAgCABUAAAAA.旺旺小小酥:BAABLAAFFH8JAAMPAAYI2RQJHQCQAQAPAAYI6xIJHQCQAQAZAAMISBGtDABtAAAAAA==.',['晓小']='晓小:BAAALAAECgEIAQAAAA==.',['晶月']='晶月莹华:BAAALAAECgYIBgAAAA==.',['暖夕']='暖夕:BAAALAAFFAIIAgAAAA==.',['暗影']='暗影议会议长:BAAALAADCgEIAQAAAA==.',['暴打']='暴打雁雁:BAAALAAECgUIBQAAAA==.',['暴走']='暴走的憨憨:BAAALAAECgYIDgAAAA==.',['月满']='月满丶西楼:BAAALAADCgMIAwAAAA==.',['月蚀']='月蚀的假面:BAAALAAECgYIBgAAAA==.',['木哆']='木哆哆:BAACLAAFFH8NAAIPAAIIASD5LwCqAAAPAAIIASD5LwCqAAAsAAQKfxsAAg8ABghUJCM+AGkCAA8ABghUJCM+AGkCAAAA.',['未日']='未日联盟:BAAALAAFFAIIAgAAAA==.',['朴妮']='朴妮唛:BAAALAAECggICAAAAA==.',['杀戮']='杀戮魔仙:BAAALAAECgUIDQAAAA==.',['来瓣']='来瓣儿蒜丶:BAAALAAECgYIBgAAAA==.',['杨家']='杨家坪动物园:BAAALAAECggICAAAAA==.',['枫叶']='枫叶落:BAAALAAECgYICwAAAA==.',['柊祈']='柊祈:BAABLAAFFH8KAAMRAAYI5gdQMAADAQARAAYIZwRQMAADAQATAAIIZxBBHgAvAAAAAA==.',['柊镜']='柊镜:BAABLAAFFH8GAAIDAAIIkQ1XGwA6AAADAAIIkQ1XGwA6AAAAAA==.',['柏拉']='柏拉图的灵魂:BAAALAAECggIDgABLAAFFAgIDwAEADsAAA==.',['栩意']='栩意阑珊:BAABLAAECn8sAAIaAAgIMhb+EQDMAQAaAAgIMhb+EQDMAQAAAA==.',['桃白']='桃白白:BAAALAAFFAIIAgAAAA==.',['梦萍']='梦萍涵香:BAAALAAECgQIBAAAAA==.',['橋本']='橋本环奈:BAAALAAECgYIBwAAAA==.',['欧皇']='欧皇战神:BAABLAAFFH8IAAIWAAIIBg17KQBrAAAWAAIIBg17KQBrAAAAAA==.',['此时']='此时花开:BAAALAAECgYICwAAAA==.此时花灭:BAAALAAECgUIBQAAAA==.',['毘沙']='毘沙门天:BAABLAAFFH8IAAIbAAIIagpnQQBnAAAbAAIIagpnQQBnAAAAAA==.',['毛绒']='毛绒沧沧:BAAALAAFFAIIBAAAAA==.',['永冬']='永冬战吼:BAAALAAECgYICwAAAA==.',['永生']='永生信仰:BAACLAAFFH8KAAIEAAIINBgKUQCgAAAEAAIINBgKUQCgAAAsAAQKfx4AAgQABgjfHuhwABUCAAQABgjfHuhwABUCAAAA.',['永铭']='永铭于心:BAACLAAFFH8JAAIBAAIIVw2WqgA6AAABAAIIVw2WqgA6AAAsAAQKfxQAAwEABghOEa3gAFUBAAEABgiTEK3gAFUBAAIABgjFCxJ0AAABAAAA.',['沐雨']='沐雨晴光丶:BAAALAAECgIIAgAAAA==.',['法爷']='法爷粑粑:BAAALAAECgIIAgAAAA==.',['泡沫']='泡沫花火:BAABLAAECn8WAAIBAAYIFBwWXgCGAQABAAYIFBwWXgCGAQAAAA==.',['波比']='波比:BAAALAAFFAEIAQAAAA==.',['洒洒']='洒洒水了:BAAALAADCgUIBQAAAA==.',['派大']='派大星:BAAALAAECggIBgAAAA==.',['海之']='海之狸:BAABLAAECn8hAAMRAAYItBvjRgCHAQARAAYItBvjRgCHAQANAAIIgRynZwCaAAABLAAFFAgINAANAHIkAA==.',['海绵']='海绵宝宝很胖:BAAALAAECggICwAAAA==.',['消逝']='消逝的雪:BAABLAAFFH8GAAMLAAIIwBRpKwCAAAALAAIIwBRpKwCAAAAcAAIInxcMCwBDAAABLAAFFAgIAwAVAAAAAA==.',['清风']='清风徐徐:BAABLAAFFH8OAAMdAAIIQyBvKwCkAAAdAAIIQyBvKwCkAAAWAAIIfAnsKABsAAAAAA==.',['温柔']='温柔的刺客:BAAALAAFFAIIAgAAAA==.',['滅天']='滅天使一焚天:BAAALAAECgIIBAAAAA==.',['滚不']='滚不莱:BAABLAAECn8UAAITAAYIrxGEPwA9AQATAAYIrxGEPwA9AQAAAA==.',['濒死']='濒死之瞳:BAAALAAECgMIAwAAAA==.',['灰雁']='灰雁:BAAALAAECgIIAgAAAA==.',['灵妖']='灵妖妖:BAACLAAFFH8KAAMKAAIIbRsLEwBGAAAKAAIIbRsLEwBGAAAHAAIIAgc6YwA8AAAsAAQKfxsAAwoABgiwGhsuALcBAAoABghIGRsuALcBAAcABAiMFwevABsBAAAA.',['灵岩']='灵岩大师:BAAALAAECgYIEQAAAA==.',['炽天']='炽天使一圣女:BAAALAAECgIIAgAAAA==.',['照花']='照花台:BAAALAAECgYICAAAAA==.',['燃烧']='燃烧的诛妖:BAABLAAFFH8OAAIBAAMICw0hLgDLAAABAAMICw0hLgDLAAAAAA==.',['牛嘞']='牛嘞咯牛:BAAALAAECgEIAQAAAA==.',['牛奶']='牛奶加咖啡:BAABLAAECn8UAAIUAAYI9xygXQDrAQAUAAYI9xygXQDrAQAAAA==.',['牛白']='牛白白:BAAALAAECgUIBQAAAA==.',['牧有']='牧有小咪:BAABLAAFFH8iAAIbAAYIgxCxHABoAQAbAAYIgxCxHABoAQAAAA==.',['狂野']='狂野不死鸟:BAAALAAECgYICgAAAA==.',['狸呜']='狸呜嗷:BAAALAAFFAIIBAAAAA==.',['狸子']='狸子:BAABLAAECn8rAAIbAAgIYgUZQADgAAAbAAgIYgUZQADgAAAAAA==.',['狼盟']='狼盟雨:BAAALAAECgYIDQAAAA==.',['猎仞']='猎仞:BAAALAAECgYICwAAAA==.',['猎天']='猎天使一魔女:BAAALAAECgEIAQABLAAFFAgIHAAQAOIkAA==.',['猎狐']='猎狐:BAAALAAECgMIAwAAAA==.',['猫熊']='猫熊:BAAALAAECgYIBgAAAA==.',['猫猫']='猫猫糖:BAAALAAECgEIAQAAAA==.',['獬豸']='獬豸:BAABLAAFFH8HAAIOAAMISgldUQB4AAAOAAMISgldUQB4AAAAAA==.',['玛丽']='玛丽亚贝尔:BAABLAAFFH8GAAIKAAIIWRmeEQBJAAAKAAIIWRmeEQBJAAAAAA==.',['珊珊']='珊珊宝贝:BAAALAAECgIIAgAAAA==.',['瓦德']='瓦德拉肯盾卫:BAAALAAECggIBwAAAA==.',['甘多']='甘多夫:BAAALAADCgEIAQAAAA==.',['生存']='生存还是毁灭:BAAALAAECgIIAgAAAA==.',['男人']='男人要过节:BAAALAAECgYICAAAAA==.',['痛苦']='痛苦的小猫:BAAALAADCgIIAgAAAA==.',['皮卡']='皮卡丘:BAAALAAFFAIIBAAAAA==.',['盖亚']='盖亚的愤怒:BAABLAAFFH8KAAIOAAQIFBqPKQAYAQAOAAQIFBqPKQAYAQAAAA==.',['碉堡']='碉堡的卜哥:BAAALAADCgIIAgAAAA==.',['祈月']='祈月之雨:BAAALAAECgQICAAAAA==.',['神丶']='神丶狐:BAAALAAECgYIEAAAAA==.',['神珍']='神珍草:BAAALAAECgIIAwAAAA==.',['神秘']='神秘的狗蛋:BAAALAAECgUIBQAAAA==.',['神裂']='神裂火织:BAABLAAFFH8GAAIeAAIIZAZuHQAsAAAeAAIIZAZuHQAsAAABLAAFFAgIHgAEAKscAA==.',['科目']='科目三好难:BAAALAAECgYIBgAAAA==.',['究极']='究极大美女:BAABLAAFFH8HAAIBAAMIrgk4eQBpAAABAAMIrgk4eQBpAAAAAA==.究极小美女:BAABLAAFFH8JAAMbAAIIZA5uPQBvAAAbAAIIZA5uPQBvAAAaAAIIcQSXMQAtAAAAAA==.究极狼外婆:BAABLAAFFH8SAAIEAAUIAAaAUADbAAAEAAUIAAaAUADbAAAAAA==.究极美少女:BAABLAAFFH8HAAIUAAMIzQZgSwBpAAAUAAMIzQZgSwBpAAAAAA==.',['空天']='空天:BAAALAAECgEIAQAAAA==.',['窜稀']='窜稀:BAAALAAECgYIDAAAAA==.',['箭秀']='箭秀凌云:BAAALAADCgEIAQAAAA==.',['米小']='米小柒:BAAALAAECgYICgAAAA==.',['糖葫']='糖葫芦哦:BAABLAAFFH8IAAIfAAII2xQQFgBGAAAfAAII2xQQFgBGAAAAAA==.',['紫月']='紫月緋雪:BAAALAAECggICAAAAA==.',['紫色']='紫色大波浪:BAAALAADCgQICAAAAA==.',['红烧']='红烧牛肉:BAABLAAFFH8IAAIEAAII6CNbNADMAAAEAAII6CNbNADMAAAAAA==.',['红糖']='红糖珍珠奶茶:BAAALAAECgYIBgAAAA==.',['纳兹']='纳兹个林:BAAALAADCgUIBQAAAA==.',['绝对']='绝对球星:BAAALAAECgYIDQAAAA==.绝对球星三号:BAAALAADCggIDwAAAA==.',['绣气']='绣气的瀦:BAAALAAECgMIBAAAAA==.',['绯红']='绯红的亚里亚:BAABLAAFFH8JAAMRAAYIgxrkGgCDAQARAAUIIh/kGgCDAQANAAEIph3GLABWAAAAAA==.',['缘来']='缘来是小强:BAABLAAFFH8HAAIDAAQIZhI4CgDLAAADAAQIZhI4CgDLAAAAAA==.',['翡翠']='翡翠熊:BAAALAAECgYIEAAAAA==.',['艿白']='艿白的雪子:BAAALAAFFAIIAgAAAA==.',['芝士']='芝士即是力量:BAAALAADCgYIBgAAAA==.',['苍穹']='苍穹发丝:BAABLAAECn8YAAIUAAgIJh/0IwC+AgAUAAgIJh/0IwC+AgAAAA==.',['范尼']='范尼是徳鲁伊:BAABLAAFFH8aAAIQAAUIFRMnGgAFAQAQAAUIFRMnGgAFAQAAAA==.',['莫云']='莫云梵:BAABLAAFFH8LAAIUAAgIZQB1awAhAAAUAAgIZQB1awAhAAAAAA==.',['莫辛']='莫辛納甘:BAAALAAECgYIBgAAAA==.',['莽村']='莽村村支书:BAAALAAECgMIAwAAAA==.',['萝卜']='萝卜坑:BAAALAAECgYICAAAAA==.',['蓝月']='蓝月之吟:BAABLAAECn8dAAIDAAYIah/ZEQCpAQADAAYIah/ZEQCpAQAAAA==.',['蓧嘢']='蓧嘢汰長:BAABLAAECn8hAAIOAAYIoRYIhwBxAQAOAAYIoRYIhwBxAQAAAA==.',['虱多']='虱多不咬人:BAAALAADCgcIBwAAAA==.',['蜂怡']='蜂怡:BAAALAADCgQIBwAAAA==.',['血战']='血战狂刀:BAAALAAECgYIDQAAAA==.',['血瑟']='血瑟:BAAALAAFFAIIBAAAAA==.',['西门']='西门吹牛币:BAAALAAECgQIBwAAAA==.',['言叶']='言叶之庭:BAAALAAECggIDgAAAA==.',['言灵']='言灵:BAACLAAFFH8IAAMZAAIIDRrJDgB+AAAZAAIIDRrJDgB+AAAPAAIIhg+6WABEAAAsAAQKfzEAAw8ACAj3G3AaAAkCAA8ACAj1GnAaAAkCABkACAjME+MbAN8BAAAA.',['请叫']='请叫我大领主:BAAALAAFFAIIAwAAAA==.',['谎言']='谎言之镜:BAABLAAFFH8GAAIaAAYIFgC+NAADAAAaAAYIFgC+NAADAAAAAA==.',['豆锅']='豆锅:BAAALAADCgMIAwAAAA==.',['貂蝉']='貂蝉:BAABLAAFFH8LAAITAAMIggRJFABUAAATAAMIggRJFABUAAAAAA==.',['赤发']='赤发狂牙:BAAALAADCgUIBQAAAA==.',['越夜']='越夜越堕落:BAABLAAFFH8HAAIBAAIIxBgsRgCeAAABAAIIxBgsRgCeAAAAAA==.',['软耳']='软耳朵:BAAALAAECggICgAAAA==.',['软霸']='软霸萧枫:BAAALAAECgYIDAAAAA==.',['迁本']='迁本夏实:BAAALAAECgYIBgAAAA==.',['迪迦']='迪迦:BAABLAAFFH8oAAIgAAYI8AoVBwA5AQAgAAYI8AoVBwA5AQAAAA==.',['迷惘']='迷惘者:BAAALAAECgYIBgAAAA==.',['追风']='追风逐月:BAAALAAECgQIBAAAAA==.',['遛弯']='遛弯的小白:BAAALAAECgQIBAAAAA==.',['邪天']='邪天使一若兰:BAAALAAECgIIAwAAAA==.',['邪月']='邪月之靈:BAAALAAECgYIDwAAAA==.',['邪皇']='邪皇:BAAALAAECgQIBQAAAA==.',['酒过']='酒过三巡:BAAALAADCgYICgAAAA==.',['酒鬼']='酒鬼小萨:BAAALAAECgUIBwAAAA==.',['醉生']='醉生夢死:BAABLAAFFH8qAAIeAAYIwQ0pBwBJAQAeAAYIwQ0pBwBJAQAAAA==.',['野性']='野性的守护:BAACLAAFFH8zAAILAAYInhzKBwCdAQALAAYInhzKBwCdAQAsAAQKfxcAAgsACAgGH3sgAG0CAAsACAgGH3sgAG0CAAAA.',['野牲']='野牲拉个萨丝:BAAALAAECgEIAQAAAA==.',['钉宫']='钉宫理惠:BAABLAAFFH8HAAIbAAMIxAIKSABaAAAbAAMIxAIKSABaAAAAAA==.',['铁光']='铁光:BAABLAAFFH8GAAIXAAYIUQ8HCgBzAQAXAAYIUQ8HCgBzAQAAAA==.',['银月']='银月城主:BAAALAAECgYICgAAAA==.',['长得']='长得困难:BAAALAAECgYICQAAAA==.',['长毛']='长毛琦玉:BAAALAAECgIIAgAAAA==.',['阿咧']='阿咧咧:BAACLAAFFH8PAAMRAAMIaBuuJgC8AAARAAMIaBuuJgC8AAATAAIIZBWqFwB5AAAsAAQKfxYAAhEABgjoJPpFAGoCABEABgjoJPpFAGoCAAAA.',['阿秋']='阿秋:BAABLAAFFH8YAAQLAAUI5RxEGwBRAQALAAQI+B9EGwBRAQAQAAMI1RnwJACIAAAcAAIIIROwDQAsAAAAAA==.',['阿莱']='阿莱娜米兰达:BAACLAAFFH8IAAIBAAIIFg7knwA+AAABAAIIFg7knwA+AAAsAAQKfxYAAwEABghbGnpwAGMBAAEABghbGnpwAGMBAAIAAQiXD1LBAC8AAAAA.',['随便']='随便狂男:BAAALAAECgYICwAAAA==.',['随风']='随风摇摆:BAABLAAFFH8GAAILAAIIIBHYNwBoAAALAAIIIBHYNwBoAAABLAAFFAIIFgAOAI8mAA==.',['隨風']='隨風澹淡:BAACLAAFFH8WAAMOAAIIjyakGgDgAAAOAAIIjyakGgDgAAAMAAIIwRSVPwBLAAAsAAQKfxgAAw4ABggFJpglAHwCAA4ABggFJpglAHwCAAwAAwgyGoioALYAAAAA.',['隼蛇']='隼蛇:BAABLAAFFH8MAAIHAAIIhA3iVQBuAAAHAAIIhA3iVQBuAAAAAA==.',['雪月']='雪月之狼:BAAALAAECgYIDwAAAA==.',['雪深']='雪深:BAAALAADCgYIBgAAAA==.',['雪花']='雪花肥牛:BAABLAAECn8WAAIEAAgIHAusSgBjAQAEAAgIHAusSgBjAQAAAA==.',['雷霆']='雷霆风暴:BAAALAAFFAIIAgAAAA==.',['雾里']='雾里花:BAAALAAECgYIBgAAAA==.',['霜之']='霜之冰刃:BAAALAAECgMIAwAAAA==.霜之冰华:BAAALAAECgMIAwAAAA==.',['霜天']='霜天使一领主:BAAALAADCggICAAAAA==.',['霞之']='霞之丘诗羽:BAACLAAFFH8KAAIUAAUIHgx0GwByAQAUAAUIHgx0GwByAQAsAAQKfxkAAxQACAj3ILkZAO0CABQACAj3ILkZAO0CACEAAQiGELshADsAAAAA.',['静悄']='静悄悄的风:BAAALAAECgIIAgAAAA==.',['风中']='风中凌乱:BAAALAADCgIIAgAAAA==.',['风雷']='风雷电雨:BAAALAAECgYIBgAAAA==.',['飘零']='飘零剑客:BAAALAADCgUIBQAAAA==.',['飞翔']='飞翔的大熊:BAAALAAECgQIBAAAAA==.',['饭饭']='饭饭崽:BAABLAAECn8ZAAIbAAYIcR1wPADnAQAbAAYIcR1wPADnAQAAAA==.',['魔天']='魔天使一星夜:BAAALAAECgEIAQAAAA==.',['魔王']='魔王灬先锋:BAAALAAFFAIIBAAAAA==.',['鳞长']='鳞长安波莎:BAAALAAECgMIAwAAAA==.',['麻辣']='麻辣王子:BAAALAAECgIIAgAAAA==.',['黎明']='黎明之雾:BAAALAAFFAIIBAAAAA==.',['黑牛']='黑牛一断角:BAAALAAECgQIBAAAAA==.',['黑猫']='黑猫警长:BAAALAAFFAIIBAAAAA==.',['龖鍅']='龖鍅師:BAABLAAFFH8FAAIdAAIIAwrCWAA9AAAdAAIIAwrCWAA9AAAAAA==.',['龙天']='龙天使一御魔:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end