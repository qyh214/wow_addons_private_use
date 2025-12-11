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
 local lookup = {'DeathKnight-Frost','Druid-Balance','Druid-Restoration','Rogue-Assassination','Rogue-Subtlety','Mage-Frost','Warlock-Destruction','Paladin-Retribution','Evoker-Devastation','Warrior-Fury','Priest-Discipline','Priest-Holy','Shaman-Restoration','Paladin-Holy','Paladin-Protection','Warlock-Demonology','Hunter-BeastMastery','Mage-Arcane','Priest-Shadow','Warrior-Protection','DemonHunter-Vengeance','DemonHunter-Havoc','Hunter-Marksmanship','Monk-Mistweaver','Monk-Windwalker','Hunter-Survival','Unknown-Unknown','Shaman-Elemental','Evoker-Augmentation','Evoker-Preservation','Druid-Guardian','DeathKnight-Unholy','DeathKnight-Blood','Mage-Fire','Monk-Brewmaster','Warlock-Affliction',}; local provider = {region='CN',realm='摩摩尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Angelababe:BAAALAAECgQIBAAAAA==.',Bl='Bleachmoon:BAACLAAFFH8eAAIBAAUIrxmTOgBRAQABAAUIrxmTOgBRAQAsAAQKfxwAAgEACAjnG1pwABYCAAEACAjnG1pwABYCAAAA.',Cl='Cliff:BAAALAAECgUICAAAAA==.',Co='Coldharvest:BAAALAAECggICAAAAA==.Concussive:BAABLAAFFH8YAAMCAAYIKg/HDQAYAQACAAYIKg/HDQAYAQADAAEIWgMRTwA4AAAAAA==.',Da='Daimonp:BAAALAAECggICAAAAA==.Darkside:BAAALAAECggICwAAAA==.',De='Deathsaint:BAABLAAFFH8HAAIBAAII8w3ncwCOAAABAAII8w3ncwCOAAAAAA==.Demondemon:BAAALAAECggICAAAAA==.Deviltrigger:BAAALAAECgYIBgAAAA==.',Eg='Egbert:BAAALAAECgUIBQAAAA==.',Ev='Evilputrefy:BAACLAAFFH8SAAIEAAYIcQvxCgBgAQAEAAYIcQvxCgBgAQAsAAQKfysAAwQACAiPGPYVAGkCAAQACAiPGPYVAGkCAAUAAwgaB3ZDAH8AAAAA.',Fe='Feifei:BAABLAAFFH8QAAIGAAMI3A1qDgB2AAAGAAMI3A1qDgB2AAAAAA==.',Gl='Glory:BAAALAAECgYIBwAAAA==.',Gr='Grittyhunter:BAAALAAECgYIDwAAAA==.',Iq='Iqoql:BAAALAADCgIIAgAAAA==.',Ja='Jaiur:BAAALAAECggICAAAAA==.',Kr='Kris:BAACLAAFFH8NAAIBAAMIWRhaJgAAAQABAAMIWRhaJgAAAQAsAAQKfyIAAgEACAgdG5g6AJACAAEACAgdG5g6AJACAAAA.Krìs:BAAALAAFFAEIAQAAAA==.Krís:BAAALAAFFAIIAwAAAA==.',Lu='Lucktank:BAAALAAFFAIIAgAAAA==.Luckyhunter:BAAALAAFFAIIAgAAAA==.Luckyshaman:BAAALAAFFAIIAgAAAA==.Luckywarlock:BAAALAAFFAQIBAAAAA==.',Me='Meteor:BAAALAADCgEIAQAAAA==.',No='Nocturnal:BAAALAAECggIAwAAAA==.',Pu='Pullo:BAAALAAECgYIEQAAAA==.Purplejoker:BAAALAAECgUIBQAAAA==.',Re='Respect:BAAALAAECgEIAQAAAA==.',Sh='Shakir:BAAALAAECgEIAQAAAA==.',Si='Similist:BAAALAAFFAEIAQAAAA==.',So='Somnusy:BAAALAAECgIIAgAAAA==.',St='Stickers:BAAALAADCgIIAgAAAA==.',Su='Sunmage:BAAALAAECgYIBwABLAAFFAIICgADAK4dAA==.',Ur='Uro:BAAALAAECgMIAwAAAA==.',Va='Vaisramana:BAAALAAECgUIBQAAAA==.',Wi='Winner:BAAALAAECgQIBAAAAA==.Winners:BAAALAAECggICgAAAA==.Winterisdk:BAAALAAFFAMIAwAAAA==.',Wo='Wowwarlock:BAAALAADCgQIBAAAAA==.',['一一']='一一年的怒火:BAAALAADCgEIAQAAAA==.',['一万']='一万物理伤害:BAAALAAECgMIBQAAAA==.',['一四']='一四七万:BAAALAAFFAIIAgAAAA==.',['一帅']='一帅到底:BAAALAAFFAIIAgAAAA==.',['一戰']='一戰成名:BAAALAADCggICAAAAA==.',['一术']='一术弑一:BAAALAAECgYIBAAAAA==.',['一条']='一条小鱼:BAAALAAECgIIAgAAAA==.',['一碗']='一碗水:BAAALAAECgYIBgAAAA==.',['一箭']='一箭中心:BAAALAAECgMIAwAAAA==.',['一脸']='一脸懵比:BAAALAAECgIIAgAAAA==.',['一路']='一路杀一路烧:BAAALAAECgQIBAAAAA==.一路烧一路杀:BAAALAAFFAIIBAAAAA==.一路缘一路断:BAAALAAECgQICgAAAA==.一路风一路雨:BAAALAAECgYIDwAAAA==.',['一魅']='一魅婀一:BAAALAAFFAIIAgAAAA==.',['万事']='万事如意:BAAALAAECgYICAAAAA==.',['三个']='三个五双冰:BAAALAAECgEIAQAAAA==.',['三哥']='三哥传奇:BAACLAAFFH8gAAIHAAYIdBSlLABoAQAHAAYIdBSlLABoAQAsAAQKfxUAAgcABgh7GoxZAOQBAAcABgh7GoxZAOQBAAAA.',['三聚']='三聚氰胺:BAAALAADCgQIBAAAAA==.',['下水']='下水道龙妈妈:BAAALAADCggICAAAAA==.',['下雨']='下雨天去划船:BAABLAAFFH8FAAIIAAMIYgxnRwB9AAAIAAMIYgxnRwB9AAAAAA==.',['不万']='不万能:BAAALAAECgYICQAAAA==.',['不吃']='不吃麻辣:BAABLAAECn8aAAIJAAgIQRVwDQC8AQAJAAgIQRVwDQC8AQAAAA==.',['不摸']='不摸也要给钱:BAABLAAFFH8GAAIDAAIIhgohTABZAAADAAIIhgohTABZAAAAAA==.',['专业']='专业刷锅:BAABLAAFFH8TAAIKAAYInxq7EQDLAQAKAAYInxq7EQDLAQAAAA==.',['丝滑']='丝滑纵享德福:BAAALAAECgEIAQAAAA==.',['两只']='两只拖鞋:BAAALAAECgYICwAAAA==.',['丧心']='丧心病狂:BAAALAADCgYIBgAAAA==.',['丨卸']='丨卸弦丨:BAAALAAFFAEIAQAAAA==.',['丨心']='丨心碎灬丨:BAAALAAECgYIBgAAAA==.',['丨方']='丨方丈打叮噹:BAAALAAFFAIIAgAAAA==.',['丨格']='丨格拉海德丨:BAAALAAECgMIAwAAAA==.',['中储']='中储部帯焘:BAAALAAECgIIAgAAAA==.',['丶小']='丶小手凉凉:BAAALAAFFAIIAwAAAA==.丶小手贼红:BAAALAAECgcIDQAAAA==.',['丶指']='丶指尖冰凉:BAAALAAECgYIDgAAAA==.',['丶摩']='丶摩可可丶:BAAALAADCgYIBgAAAA==.',['丶是']='丶是小手吖:BAAALAAFFAIIAgAAAA==.',['丶艾']='丶艾卡西亚:BAAALAAECgYIBgAAAA==.',['丶西']='丶西卡:BAAALAADCggICAAAAA==.',['丹妮']='丹妮坦格利安:BAABLAAECn8YAAMLAAYIqxErCwBHAQALAAYIqxErCwBHAQAMAAMIywJYYABGAAAAAA==.',['丿灰']='丿灰灬朦朦丶:BAAALAAECgYICQAAAA==.',['乌云']='乌云:BAABLAAFFH8bAAIDAAYImwpcHgAxAQADAAYImwpcHgAxAQAAAA==.',['乌拉']='乌拉:BAAALAAECgMIBQAAAA==.',['九脸']='九脸龙王:BAAALAAECgYIBgAAAA==.',['二十']='二十四夜:BAABLAAFFH8GAAINAAIIBB3nQgCdAAANAAIIBB3nQgCdAAAAAA==.',['二牛']='二牛快点跑:BAAALAAECgIIAgAAAA==.',['二郎']='二郎戏嫂:BAAALAAECgYIBgAAAA==.',['人体']='人体自燃:BAAALAADCggICAAAAA==.',['今夜']='今夜回忆过去:BAAALAAFFAYIAgAAAA==.',['从前']='从前有个德:BAABLAAFFH8LAAMDAAYIKAuFKgDGAAADAAQI9wqFKgDGAAACAAIInwF1LwBDAAAAAA==.',['代表']='代表月亮削你:BAACLAAFFH8ZAAMOAAUIEBL3FAA+AQAOAAUIEBL3FAA+AQAPAAQIjBI+DQC0AAAsAAQKfx4ABA8ACAipFoITAIIBAA8ABghCG4ITAIIBAAgABQjADZYKARkBAA4ABghRELsoAPsAAAAA.',['伊利']='伊利郸丶怒凤:BAAALAAECgYIEAAAAA==.',['伊莉']='伊莉丝:BAAALAAECgYICQAAAA==.',['伊露']='伊露维塔:BAABLAAECn8bAAIHAAgICiHmJwClAgAHAAgICiHmJwClAgAAAA==.',['伏特']='伏特加:BAAALAAECggICAAAAA==.',['伪戒']='伪戒:BAAALAADCgMIAwAAAA==.',['伽马']='伽马:BAAALAAECgMIAwAAAA==.',['你们']='你们全体大耶:BAABLAAFFH8KAAMQAAIIgAQmIQBkAAAQAAIIgAQmIQBkAAAHAAIIKwLvcQAnAAAAAA==.',['你在']='你在我身边丶:BAACLAAFFH8KAAIRAAIIlhzJhwBJAAARAAIIlhzJhwBJAAAsAAQKfyEAAhEACAhMH28hADUCABEACAhMH28hADUCAAAA.',['你好']='你好紧张女士:BAAALAAECgMIBAAAAA==.',['你灬']='你灬瞅啥:BAAALAAECgYIBgAAAA==.',['你看']='你看那悲伤:BAAALAADCgIIAgAAAA==.',['你那']='你那么孤独:BAABLAAFFH8NAAISAAYIgBThJwB0AQASAAYIgBThJwB0AQAAAA==.',['依柔']='依柔:BAAALAAECgcICQAAAA==.',['依然']='依然丨嫒祢:BAAALAAECgYICwAAAA==.',['俞俞']='俞俞:BAACLAAFFH8JAAIDAAUICRICHwArAQADAAUICRICHwArAQAsAAQKfxQAAgMABggRHJdDANIBAAMABggRHJdDANIBAAAA.',['俞瑜']='俞瑜:BAACLAAFFH8pAAIMAAUIHRx8FQCnAQAMAAUIHRx8FQCnAQAsAAQKfyUAAwwACAihHf0dAIUCAAwACAihHf0dAIUCABMAAQhuAkOmACMAAAAA.',['做个']='做个盖世英雄:BAAALAADCgYIBgAAAA==.',['偶尔']='偶尔也销魂:BAAALAAECgMIAwAAAA==.',['偷妞']='偷妞人:BAABLAAFFH8WAAIUAAYICBISEQBCAQAUAAYICBISEQBCAQAAAA==.',['傲枯']='傲枯骨:BAAALAAECgUIBQAAAA==.',['傲灭']='傲灭世:BAAALAAECgYIBwAAAA==.',['傲神']='傲神:BAAALAAECgYICAAAAA==.',['傲秘']='傲秘:BAAALAAECgIIAgAAAA==.',['傲蔚']='傲蔚:BAAALAAECgYIBgAAAA==.',['傲视']='傲视:BAAALAAECgQIBAAAAA==.',['傲酒']='傲酒:BAAALAAECgMIAwAAAA==.',['傲骄']='傲骄:BAAALAAECgQIBAAAAA==.',['傲魔']='傲魔:BAAALAAECgEIAQAAAA==.',['傻慢']='傻慢:BAAALAAECgUIBgAAAA==.',['元素']='元素咆哮:BAAALAAECgEIAQAAAA==.',['八月']='八月飞雪:BAAALAADCgYIBgAAAA==.',['八葉']='八葉丶:BAAALAAECgUIBQAAAA==.',['关于']='关于小熊:BAAALAAECgcIBwAAAA==.',['再出']='再出发小萨:BAAALAAECgcIEwAAAA==.',['冎叔']='冎叔叔:BAAALAAFFAIIAgAAAA==.',['冥月']='冥月影:BAACLAAFFH8GAAINAAIIfgrhWgBkAAANAAIIfgrhWgBkAAAsAAQKfyEAAg0ABwgRFi9qALABAA0ABwgRFi9qALABAAAA.冥月獵風:BAAALAAFFAEIAQAAAA==.',['冰冠']='冰冠之王:BAAALAAECgYIDAAAAA==.',['冰冻']='冰冻罐头:BAAALAAECgEIAQAAAA==.',['冰雪']='冰雪幻月:BAAALAADCgIIAgAAAA==.',['冲锋']='冲锋者:BAAALAADCgIIAgAAAA==.',['冷冰']='冷冰冰:BAAALAAECgUIBQAAAA==.',['凌乱']='凌乱一杀戮:BAAALAAECgYICgAAAA==.',['凶残']='凶残的棉花糖:BAAALAAECgYIBgAAAA==.',['出马']='出马仙:BAAALAAECgMIAwAAAA==.',['刀剑']='刀剑笑:BAAALAADCgEIAQAAAA==.',['利威']='利威亚杰洛特:BAAALAAECgYIBgAAAA==.',['刹秦']='刹秦:BAAALAAECgYIBgAAAA==.',['勇敢']='勇敢:BAAALAAECgYICQAAAA==.',['北戰']='北戰丨丶:BAAALAAECgQIBAAAAA==.',['千早']='千早爱音:BAAALAADCgEIAQAAAA==.',['千秋']='千秋血:BAAALAADCgEIAQAAAA==.',['半仙']='半仙呦:BAAALAAECgYICwAAAA==.',['半天']='半天妖:BAAALAAFFAIIAgAAAA==.',['卖萌']='卖萌的老幺:BAAALAAECggICAAAAA==.',['南北']='南北极的光:BAAALAAECgcIEgAAAA==.南北极的卅:BAAALAAECgcIDQAAAA==.',['南征']='南征北战:BAACLAAFFH8YAAMVAAYIoAmiCgCcAAAWAAUIKwuUMQAFAQAVAAUI+wOiCgCcAAAsAAQKfywAAxYACAgcG9MYABUCABYACAgcG9MYABUCABUABwiFDo0wADsBAAAA.',['叉歪']='叉歪歪:BAAALAAFFAQIBAAAAA==.',['变身']='变身大全:BAAALAAECgQIBAAAAA==.',['叚靣']='叚靣微笑:BAABLAAFFH8VAAIBAAUICxvxOgBPAQABAAUICxvxOgBPAQAAAA==.',['古灬']='古灬尔灬丹:BAAALAAECgEIAQAAAA==.',['古神']='古神的悄悄话:BAAALAADCggICAAAAA==.',['可怜']='可怜的沫沫:BAAALAADCgEIAQAAAA==.',['可琦']='可琦安:BAAALAAFFAEIAQAAAA==.',['右岸']='右岸:BAAALAADCgYIBgAAAA==.',['叶落']='叶落無痕:BAABLAAFFH8KAAIXAAIIdRswFABJAAAXAAIIdRswFABJAAAAAA==.',['吃我']='吃我一暗影箭:BAAALAAECgYIEQAAAA==.吃我一箭袋:BAAALAAECgYICAAAAA==.',['吃蛙']='吃蛙群众:BAAALAAECgMIAwAAAA==.',['吹吹']='吹吹乐:BAAALAAFFAIIAgAAAA==.',['吹老']='吹老师:BAAALAAFFAIIBAAAAA==.吹老湿:BAABLAAFFH8IAAIVAAIIlxVrDgCBAAAVAAIIlxVrDgCBAAAAAA==.',['咖啡']='咖啡屋主理人:BAAALAAECgMIAwAAAA==.',['哘屍']='哘屍灬赱肉:BAAALAAFFAIIAwAAAA==.',['哟湿']='哟湿幽盅:BAAALAAECgUIBQAAAA==.',['哥丶']='哥丶牛中龙凤:BAABLAAFFH8GAAMYAAIIFQE1GwA/AAAYAAIIFQE1GwA/AAAZAAIIfQILHAAqAAAAAA==.哥丶玉樹臨風:BAAALAAFFAIIBAAAAA==.哥丶风流倜傥:BAAALAAFFAIIAgAAAA==.',['哥哥']='哥哥我岸上走:BAAALAAECgUIBQAAAA==.',['哥布']='哥布林撒手:BAAALAAECgYIBgAAAA==.',['哦也']='哦也射滴深:BAAALAADCgIIAgAAAA==.',['唐伯']='唐伯虎点迷香:BAAALAADCgIIAgAAAA==.唐伯虎猎风:BAACLAAFFH8bAAMRAAYI1xbdLQB/AQARAAYI1xbdLQB/AQAXAAEIxQIoGgA2AAAsAAQKfxYABBEABwg2HyqEANcBABEABwhRHiqEANcBABoAAQiVJEkPAG0AABcAAgh0EZ+lAGcAAAAA.',['喞喞']='喞喞喎喎:BAAALAAFFAIIAgAAAA==.',['喬妮']='喬妮娜灬草性:BAAALAAECgcIBwAAAA==.',['嘉德']='嘉德丽雅:BAAALAAECggICAAAAA==.',['嘿小']='嘿小子:BAAALAAECgQIBAAAAA==.',['圆月']='圆月弯刀:BAAALAAECgYIDQAAAA==.',['圣光']='圣光守护者:BAAALAAECgYIBgAAAA==.圣光永渡:BAABLAAECn8UAAIIAAYIhQ66hAD3AAAIAAYIhQ66hAD3AAAAAA==.圣光背叛了我:BAABLAAFFH8GAAIPAAIImwGUIQBMAAAPAAIImwGUIQBMAAAAAA==.',['圣殿']='圣殿男爵:BAAALAADCgQIBAAAAA==.圣殿魔导师:BAAALAADCgcIEQAAAA==.',['基尔']='基尔:BAAALAAECggICAABLAAFFAgIBgABAF8TAA==.',['塔塔']='塔塔斯基:BAAALAADCgEIAQAAAA==.',['墓秋']='墓秋:BAAALAAECgYICgABLAAFFAgIAgAbAAAAAA==.',['墨若']='墨若:BAAALAAECgIIAgAAAA==.',['壹卡']='壹卡洛斯:BAAALAAFFAQIBAAAAA==.',['夏天']='夏天的热浪:BAAALAAECggICAAAAA==.',['夕卜']='夕卜才圭:BAAALAAECgYIBwAAAA==.',['夜伴']='夜伴幽夢:BAAALAAECggICAAAAA==.',['夜十']='夜十三妹:BAAALAAECgEIAQAAAA==.夜十三猎:BAAALAAECgYIBgAAAA==.',['夜语']='夜语潇潇:BAABLAAFFH8LAAIWAAIItw3ZSQCSAAAWAAIItw3ZSQCSAAAAAA==.',['大地']='大地雄心:BAAALAAECgIIAgAAAA==.',['大智']='大智若魚:BAABLAAECn8iAAMDAAgI/hVqNgAGAgADAAgI/hVqNgAGAgACAAgI5hVVOQDSAQAAAA==.',['大铭']='大铭:BAAALAAFFAIIBAAAAA==.',['大锤']='大锤啪啪趴:BAAALAAECgIIAgAAAA==.',['大青']='大青山:BAAALAADCgIIAgAAAA==.',['大麦']='大麦青汁:BAABLAAFFH8IAAIWAAIISAySVQBFAAAWAAIISAySVQBFAAAAAA==.',['大黑']='大黑:BAAALAAECgYIBgAAAA==.',['夨落']='夨落灬萌萌:BAAALAAFFAQIBAAAAA==.',['天堂']='天堂杀戮:BAAALAADCgcICgAAAA==.天堂荣耀:BAAALAAFFAMIAwAAAA==.',['天枢']='天枢:BAABLAAFFH8KAAIHAAgINRcaDgAlAgAHAAgINRcaDgAlAgAAAA==.',['天照']='天照御神:BAAALAAECgYIBgAAAA==.',['天玑']='天玑:BAAALAADCgEIAQAAAA==.',['天璇']='天璇:BAABLAAFFH8GAAIHAAYIfQn8NQA5AQAHAAYIfQn8NQA5AQAAAA==.',['天蝎']='天蝎座灬擒獣:BAABLAAFFH8HAAIMAAIIJQnwPQB6AAAMAAIIJQnwPQB6AAAAAA==.',['天降']='天降正义丶:BAAALAADCggICAAAAA==.',['太丶']='太丶阳:BAABLAAFFH8cAAMNAAYIVyO3BQBmAgANAAYIVyO3BQBmAgAcAAQIDwstLwC6AAABLAAFFAgIFwAcANUeAA==.',['太杨']='太杨:BAABLAAECn8dAAMRAAgIEyMrEwCMAgARAAgIEyMrEwCMAgAXAAEIlRPOLAA8AAABLAAFFAIICgADAK4dAA==.',['太阳']='太阳萌德:BAABLAAFFH8KAAIDAAIIrh2sJQCRAAADAAIIrh2sJQCRAAAAAA==.',['失控']='失控的灵魂:BAAALAAECggICAABLAAFFAgIBgAOAOIhAA==.',['奈亞']='奈亞:BAABLAAFFH8RAAIBAAQI4RaaTQDxAAABAAQI4RaaTQDxAAAAAA==.',['奔跑']='奔跑的面包:BAABLAAFFH8QAAIRAAYI3gWVUQAJAQARAAYI3gWVUQAJAQAAAA==.',['奢香']='奢香公子:BAAALAADCgMIAwAAAA==.',['奥乐']='奥乐米拉:BAAALAAFFAIIAgAAAA==.',['奥琺']='奥琺:BAABLAAFFH8OAAISAAIIjxUhUQBLAAASAAIIjxUhUQBLAAAAAA==.',['女王']='女王之刃:BAAALAADCgEIAQAAAA==.',['奶丫']='奶丫:BAABLAAFFH8NAAIIAAMI+xouOwCqAAAIAAMI+xouOwCqAAAAAA==.',['妙手']='妙手丶回春:BAAALAAECgUICQAAAA==.妙手丶圣光:BAAALAAECgQIBAAAAA==.',['妮尔']='妮尔塔莉:BAAALAADCgMIAwAAAA==.',['娇气']='娇气包儿:BAAALAAECgUIBQAAAA==.',['守林']='守林人:BAAALAAECgYIBgAAAA==.',['安丶']='安丶度丶因:BAAALAAECgQIBAAAAA==.',['宝贝']='宝贝早点睡:BAAALAAECgcIBwAAAA==.',['审判']='审判灬圣光:BAAALAAECgYIEwAAAA==.',['室女']='室女座释静摩:BAACLAAFFH8KAAMdAAMIDQ/8CACMAAAdAAII5A38CACMAAAJAAIIxw8+HACEAAAsAAQKfyEABAkACAigGYMfAB4CAAkACAguGIMfAB4CAB0AAgj5HCEXAJUAAB4AAggABipBAEoAAAEsAAUUCAgXAAYAig8A.',['寄长']='寄长月:BAAALAAECgYIBgAAAA==.',['射手']='射手座格式塔:BAACLAAFFH8sAAMaAAYIHCRTAAAeAgAaAAYIHCRTAAAeAgARAAYIDxdKMQB0AQAsAAQKfzQAAxoACAhxJiMAABoDABoACAhfJiMAABoDABEACAjaJHQDAAIDAAEsAAUUCAgXAAYAig8A.',['對児']='對児胡:BAABLAAECn8aAAIRAAgIsAgA4wBTAQARAAgIsAgA4wBTAQAAAA==.',['小北']='小北鼻:BAAALAAECgYIBgAAAA==.',['小奶']='小奶狼死哪了:BAABLAAECn8XAAINAAgIhRYnNQCIAQANAAgIhRYnNQCIAQAAAA==.',['小小']='小小德:BAAALAADCgUIBQAAAA==.小小怂:BAABLAAFFH8MAAMOAAYIZgPlFgAgAQAOAAYIZgPlFgAgAQAIAAIIOBskRgCaAAAAAA==.小小龙:BAAALAAECggICAAAAA==.',['小损']='小损样儿:BAAALAAECgEIAQAAAA==.',['小狗']='小狗:BAAALAADCgIIAQAAAA==.',['小葫']='小葫菟:BAAALAADCggICAAAAA==.',['小鈥']='小鈥怡情:BAAALAADCgYIBgAAAA==.',['小镇']='小镇全能家:BAAALAADCgIIAgAAAA==.',['小饺']='小饺:BAABLAAFFH8LAAINAAQIBgsJGgDjAAANAAQIBgsJGgDjAAAAAA==.',['小鬼']='小鬼头头:BAAALAAECgIIAgAAAA==.小鬼当家:BAABLAAFFH8HAAIJAAUIEAcZEgDzAAAJAAUIEAcZEgDzAAABLAAFFAYIDgAHADMTAA==.',['小鳥']='小鳥游飞雁:BAAALAADCgIIAgAAAA==.',['尼古']='尼古拉斯凯骑:BAABLAAFFH8LAAIIAAUIOBy2JQBHAQAIAAUIOBy2JQBHAQAAAA==.',['山妖']='山妖丶灵:BAAALAAECggIDQAAAA==.山妖丶祈:BAAALAAECgEIAQAAAA==.',['崔希']='崔希丝:BAABLAAFFH8UAAIRAAUI+RblRgAvAQARAAUI+RblRgAvAQABLAAFFAcIJAAMAEQfAA==.',['川峰']='川峰:BAABLAAFFH8GAAMRAAIIOBocgQBUAAARAAIIOBocgQBUAAAXAAIIqQHZMgBMAAAAAA==.',['巴德']='巴德:BAAALAADCgYICgAAAA==.',['布都']='布都御魂丶:BAAALAAECgQIBAAAAA==.',['希尔']='希尔瓦娜澌:BAABLAAECn8XAAIRAAcIRSCIQQBiAgARAAcIRSCIQQBiAgAAAA==.',['幻林']='幻林枫:BAAALAAFFAEIAQAAAA==.',['幽忧']='幽忧杀你玩:BAABLAAFFH8GAAIfAAII9hR7CwA/AAAfAAII9hR7CwA/AAAAAA==.',['幽默']='幽默小黄人:BAAALAAECgUIBQAAAA==.',['废铁']='废铁的凝视:BAAALAADCggICAAAAA==.',['开心']='开心超人:BAAALAAECgQIBAAAAA==.',['弈秋']='弈秋丶:BAABLAAFFH8OAAMgAAIIoxtuEACYAAABAAIIpBavXACaAAAgAAIIDBtuEACYAAAAAA==.',['弓长']='弓长老湿:BAAALAAECgMIAwAAAA==.',['弗丶']='弗丶丁:BAAALAAECgYIAwABLAAFFAEIAQAbAAAAAA==.',['弗兰']='弗兰克加拉格:BAAALAADCggICQAAAA==.',['张继']='张继科:BAABLAAECn8VAAMCAAYIuhgNQQCwAQACAAYIuhgNQQCwAQADAAYITRQIOQA6AQAAAA==.',['张角']='张角:BAAALAADCggICAAAAA==.',['彩虹']='彩虹之湖:BAAALAADCgEIAQAAAA==.',['影忄']='影忄殇:BAAALAAECggIDAAAAA==.',['影月']='影月:BAACLAAFFH8OAAIMAAUI8w6rDACEAQAMAAUI8w6rDACEAQAsAAQKfykAAgwACAgAHjgYAKoCAAwACAgAHjgYAKoCAAAA.',['影柯']='影柯:BAAALAAFFAIIBAAAAA==.',['微笑']='微笑的神:BAAALAAFFAEIAQAAAA==.',['微醺']='微醺的小拇指:BAAALAAECgYICQAAAA==.',['快乐']='快乐就是上帝:BAAALAAECgYICQAAAA==.快乐的小麦:BAAALAAECgEIAQAAAA==.快乐肥仔水:BAAALAAECgUICAAAAA==.',['怀夕']='怀夕:BAAALAAECgYIDgAAAA==.',['恋恋']='恋恋星夜:BAAALAAECgMIAwAAAA==.恋恋风歌:BAAALAADCgYIBgAAAA==.',['恩互']='恩互:BAAALAADCgIIAgAAAA==.',['恶魔']='恶魔之手尼禄:BAABLAAFFH8GAAIKAAYIVQJFNwCVAAAKAAYIVQJFNwCVAAAAAA==.',['悲伤']='悲伤的小提米:BAAALAAFFAIIBAAAAA==.',['惊鹊']='惊鹊:BAAALAAECgMIAwAAAA==.',['惜楚']='惜楚霸王:BAAALAAECgYICAAAAA==.',['憨憨']='憨憨的小跟班:BAAALAAECggIEgAAAA==.',['憾地']='憾地红牛:BAAALAAECgYIBgAAAA==.',['懒惰']='懒惰:BAACLAAFFH8LAAMhAAYIxQWNEQDMAAAhAAUIHgSNEQDMAAABAAII1AkrfQCJAAAsAAQKfxoAAwEACAgiFK+TANoBAAEABwggFK+TANoBACEACAggDRUTAE4BAAAA.',['戀戰']='戀戰:BAABLAAFFH8RAAIHAAUIIQsAPgAHAQAHAAUIIQsAPgAHAQAAAA==.',['我一']='我一个后跳:BAAALAADCgYIBwAAAA==.我一个大跳:BAAALAAECgIIAgAAAA==.',['我是']='我是六娃:BAAALAAECgEIAQAAAA==.',['我爱']='我爱丨娜娜:BAAALAAECgMIBAAAAA==.我爱梦之仙子:BAAALAAECgYIDAAAAA==.',['戒嗔']='戒嗔:BAABLAAFFH8NAAIKAAUIGRINDwCiAQAKAAUIGRINDwCiAQAAAA==.',['戒怒']='戒怒:BAACLAAFFH8tAAMBAAcIWBpgBABgAgABAAcIWBpgBABgAgAgAAEInBlOHQBQAAAsAAQKfyQABAEACAhRI6siAOUCAAEACAigIqsiAOUCACEABghdEUknAEQBACAAAwg3ImVCAMoAAAAA.',['戒悔']='戒悔:BAAALAAECgIIAgAAAA==.',['战争']='战争崩碎:BAAALAAECgYIBgAAAA==.',['戦灬']='戦灬逍遥:BAAALAADCgYIBgAAAA==.',['扎实']='扎实:BAAALAAECggICAAAAA==.',['扎尔']='扎尔吉拉:BAACLAAFFH8FAAIHAAMIZwSnVQBRAAAHAAMIZwSnVQBRAAAsAAQKfxkAAgcABwgOF9grAKMBAAcABwgOF9grAKMBAAAA.',['拉咘']='拉咘拉咔:BAAALAAECgYICQAAAA==.',['提裏']='提裏奥弗丁:BAAALAAECgYIBgAAAA==.',['提里']='提里奥丶福叮:BAABLAAECn8bAAMIAAYItR3FPQCjAQAIAAYItR3FPQCjAQAPAAMIqgQrRAAxAAAAAA==.提里奥丶芙汀:BAAALAAECgYIDgAAAA==.',['插棍']='插棍棍的牛牛:BAAALAADCgYIBgAAAA==.',['携秋']='携秋水揽星河:BAABLAAFFH8MAAIcAAIILB4QPABXAAAcAAIILB4QPABXAAABLAAFFAYIIgANAGESAA==.',['擒灬']='擒灬獣:BAAALAAECgIIAgAAAA==.',['收手']='收手吧阿汤:BAAALAAECgYICgAAAA==.',['放我']='放我去死:BAAALAADCggICwAAAA==.',['文静']='文静的高太尉:BAAALAAECgQIBAAAAA==.',['斯嘉']='斯嘉莉:BAAALAADCgUICQAAAA==.',['无名']='无名相思掌:BAAALAAECgQIBAAAAA==.',['无灬']='无灬欲:BAAALAAFFAEIAQAAAA==.',['无良']='无良小鬼:BAABLAAFFH8OAAIHAAYIMxOxLQBjAQAHAAYIMxOxLQBjAQAAAA==.',['无趣']='无趣滴灵魂:BAAALAAECgcIEQAAAA==.',['日番']='日番股趴趴熊:BAAALAAFFAIIAgAAAA==.日番谷趴趴熊:BAABLAAFFH8LAAIBAAIIUQw+cgCPAAABAAIIUQw+cgCPAAAAAA==.',['时光']='时光旅行者:BAAALAAECgIIAgAAAA==.',['昊天']='昊天锤:BAABLAAFFH8GAAIgAAIItQJPFgB3AAAgAAIItQJPFgB3AAAAAA==.',['明月']='明月是前身:BAABLAAFFH8GAAISAAYIhBdtHwCZAQASAAYIhBdtHwCZAQAAAA==.',['昕佑']='昕佑:BAAALAAFFAEIAQAAAA==.',['晓法']='晓法:BAACLAAFFH8OAAMGAAMI5BXhBQDpAAAGAAMI5BXhBQDpAAASAAII3BB5VgBEAAAsAAQKfxsAAwYACAhKGRM3AJkBABIACAgbGF9yALQBAAYABwiiFhM3AJkBAAAA.',['晓烨']='晓烨:BAAALAAFFAIIBAAAAA==.',['晚冬']='晚冬:BAAALAADCgcIBwAAAA==.',['暗夜']='暗夜之骑士:BAAALAAECgUIBQAAAA==.',['暴怒']='暴怒丶:BAACLAAFFH8KAAIUAAQIRAzkHACbAAAUAAQIRAzkHACbAAAsAAQKfxcAAxQACAhREpYaAGwBABQACAiCEZYaAGwBAAoAAwjZETjWAL0AAAAA.',['暴走']='暴走的灵魂:BAAALAAECggICAAAAA==.',['曉宇']='曉宇:BAACLAAFFH8eAAMfAAYIkw5uBAD+AAAfAAYIkw5uBAD+AAADAAIILQbjRABaAAAsAAQKfysAAx8ACAhrFjEKAJwBAB8ACAhrFjEKAJwBAAMABAihFGCQAPcAAAAA.',['曹轩']='曹轩寜寜:BAAALAAECgEIAQAAAA==.',['月夜']='月夜飘雪:BAAALAAECgYICgAAAA==.',['月色']='月色朦朦:BAAALAAECgMIAwAAAA==.',['月蚀']='月蚀:BAAALAADCgMIAwAAAA==.',['有点']='有点东西:BAAALAAECggICAAAAA==.',['有趣']='有趣滴灵魂:BAABLAAFFH8IAAIIAAgIlgC1iAABAAAIAAgIlgC1iAABAAAAAA==.',['朕有']='朕有你的:BAAALAAECgYICwAAAA==.',['木木']='木木大魔王:BAAALAAECgIIAQABLAAFFAIIAgAbAAAAAA==.',['末日']='末日灵舞:BAAALAAFFAIIAgAAAA==.',['本间']='本间葵:BAAALAAECgcIEQAAAA==.',['术出']='术出:BAAALAAECgUIBQAAAA==.',['朱二']='朱二旦:BAABLAAFFH8NAAIHAAMIMQ2ULADUAAAHAAMIMQ2ULADUAAAAAA==.',['杀戮']='杀戮兽兽:BAAALAAECgYICQAAAA==.杀戮小小贼:BAAALAAECgYICgAAAA==.杀戮小小龙人:BAAALAAECgYIDQAAAA==.杀戮小萨:BAAALAAECgYIBgAAAA==.杀戮德:BAAALAAECgYIBwAAAA==.杀戮死骑:BAAALAAECgYIEwAAAA==.杀戮法爷:BAAALAAECgQIBAAAAA==.杀戮骑士:BAAALAAECgYIDAAAAA==.',['李火']='李火旺:BAABLAAFFH8KAAIUAAIIdx0QFQCpAAAUAAIIdx0QFQCpAAAAAA==.',['杜尔']='杜尔赞:BAAALAAECgUIBQAAAA==.',['杰拉']='杰拉多尼:BAAALAAFFAYIAgAAAA==.',['果汁']='果汁分你一半:BAAALAADCgcIBwAAAA==.',['枫棕']='枫棕小狼:BAAALAADCgEIAQAAAA==.',['柒尐']='柒尐对児:BAAALAADCggIDwAAAA==.',['柠蓝']='柠蓝浅夏丶:BAACLAAFFH8JAAINAAYIvgZlLwDzAAANAAYIvgZlLwDzAAAsAAQKfy0AAg0ACAgPFkFRAO4BAA0ACAgPFkFRAO4BAAAA.',['格罗']='格罗玛:BAAALAADCgEIAQAAAA==.',['梦之']='梦之魂:BAAALAAECgIIAgAAAA==.',['梦想']='梦想上将:BAAALAAFFAIIAgAAAA==.',['梦追']='梦追梦:BAACLAAFFH8jAAMSAAYIOQ5pKgBoAQASAAYIOQ5pKgBoAQAiAAIIXgmyDgA6AAAsAAQKfy0AAxIACAgQGYxCAEICABIACAgQGYxCAEICACIAAQiuCmoiADkAAAAA.',['棉花']='棉花橙:BAAALAAECgYIEQAAAA==.棉花粉:BAAALAAECgYIBgAAAA==.',['榴链']='榴链味:BAAALAADCgQIBAAAAA==.',['樱夜']='樱夜美子:BAAALAAECgMIAwAAAA==.',['樱岛']='樱岛麻衣:BAABLAAFFH8JAAISAAUITBS0MQA7AQASAAUITBS0MQA7AQAAAA==.',['欣欣']='欣欣宝宝:BAAALAAFFAIIAgAAAA==.',['款冬']='款冬:BAAALAAECggIBgAAAA==.',['正统']='正统部落:BAAALAAECgYIBgAAAA==.',['武七']='武七:BAAALAADCgQIBQAAAA==.',['死乂']='死乂亡:BAABLAAFFH8XAAIBAAYIICSTEQABAgABAAYIICSTEQABAgAAAA==.',['江月']='江月初照人:BAAALAADCgEIAQAAAA==.',['汪汪']='汪汪小饼干:BAAALAADCgMIAwAAAA==.',['沈璧']='沈璧君:BAAALAAECgYICgABLAAECgYIDwAbAAAAAA==.',['沫小']='沫小也:BAABLAAFFH8KAAIYAAYI1A9KCgBrAQAYAAYI1A9KCgBrAQAAAA==.',['治疗']='治疗你的波:BAAALAAECgIIAgAAAA==.',['法司']='法司:BAAALAAECgUICQAAAA==.',['泣洫']='泣洫丶灬:BAAALAAFFAIIBAAAAA==.',['活力']='活力鱼串:BAAALAAFFAQIBAAAAA==.',['活宝']='活宝他姐:BAABLAAECn8UAAIIAAYIlh1rfwDtAQAIAAYIlh1rfwDtAQAAAA==.',['流水']='流水无情丶:BAAALAADCgMIAwAAAA==.',['浣纱']='浣纱溪:BAAALAAECgcIEAAAAA==.',['清野']='清野凛:BAAALAAFFAIIBAAAAA==.',['清风']='清风暮雨:BAAALAAECgMIAwAAAA==.',['温柔']='温柔老大哥:BAAALAAECgYICgAAAA==.',['漏电']='漏电的男朋友:BAAALAADCgMIAwAAAA==.',['灬妖']='灬妖术灬:BAAALAAFFAEIAQAAAA==.灬妖猎灬:BAABLAAECn8cAAIRAAgI7yDSHADnAgARAAgI7yDSHADnAgAAAA==.',['灬嬡']='灬嬡巳荿暀倳:BAAALAAFFAIIBAABLAAFFAIICwADAL4fAA==.',['灰太']='灰太狼不后悔:BAAALAAFFAIIAgAAAA==.',['灵魂']='灵魂丶彼岸:BAAALAAECggICAAAAA==.灵魂丶碎裂:BAAALAAECggICAABLAAFFAgIBgABAF8TAA==.',['烈丶']='烈丶酒:BAAALAADCggICAAAAA==.',['烈日']='烈日当空:BAAALAAECgMIAwAAAA==.',['烟水']='烟水寒:BAAALAAFFAIIAgAAAA==.',['烟熏']='烟熏玫瑰:BAAALAAECgYIDAAAAA==.',['烟鬼']='烟鬼:BAABLAAECn8UAAISAAYInhLmjwBsAQASAAYInhLmjwBsAQAAAA==.',['烤肉']='烤肉披萨:BAAALAAFFAIIAwAAAA==.',['然然']='然然:BAABLAAFFH8GAAMcAAYIVxDqRABDAAAcAAUIfQ3qRABDAAANAAEIqAIAAAAAAAAAAA==.',['熊中']='熊中熊:BAAALAADCgIIAgAAAA==.',['熊猫']='熊猫灬小妞:BAAALAAECgYIBwAAAA==.',['爱你']='爱你哦老婆:BAAALAAFFAIIAgAAAA==.爱你老婆大人:BAAALAAECgYIBgAAAA==.',['爱吃']='爱吃酸柠檬:BAAALAAECgQIBQAAAA==.',['爱沫']='爱沫沫:BAAALAAECgMIAwAAAA==.',['爷的']='爷的霸气长存:BAAALAAECgYICAAAAA==.',['牛奶']='牛奶煮萝莉:BAAALAAECggIDwAAAA==.',['牛德']='牛德收割机:BAAALAAFFAIIAgAAAA==.',['牛气']='牛气水獭王:BAABLAAFFH8JAAIDAAMI0h03JgDnAAADAAMI0h03JgDnAAAAAA==.',['牛牛']='牛牛嗜血:BAABLAAECn8eAAINAAgIrBhQPAAqAgANAAgIrBhQPAAqAgAAAA==.',['牢总']='牢总:BAAALAAECgQIBAAAAA==.',['牧有']='牧有意思:BAAALAADCggICAAAAA==.',['牧零']='牧零:BAAALAAECgQIBAAAAA==.',['犹格']='犹格索托斯:BAAALAADCgEIAQAAAA==.',['狸狸']='狸狸原上跑:BAAALAAFFAIIAgAAAA==.',['猫已']='猫已经肥了:BAABLAAFFH8mAAMZAAYIJCCfAwDlAQAZAAYIJCCfAwDlAQAjAAMIWwNCFACBAAABLAAFFAcIKAAHANcaAA==.',['王不']='王不丨留行:BAABLAAFFH8GAAIKAAII4BQwLQCiAAAKAAII4BQwLQCiAAAAAA==.',['玛德']='玛德尔法克:BAAALAADCggIDwAAAA==.',['玛法']='玛法丨里奥:BAABLAAFFH8FAAIDAAIIWBAkNQBrAAADAAIIWBAkNQBrAAAAAA==.',['玩闹']='玩闹小裤衩:BAAALAAECgYIBgAAAA==.',['环烷']='环烷烃:BAAALAAECgIIAgAAAA==.',['珊瑚']='珊瑚蛇:BAABLAAFFH8FAAMGAAUIZwhrDgB2AAASAAMIrwn2RwCBAAAGAAIIfAZrDgB2AAAAAA==.',['琴酒']='琴酒:BAAALAAECggICAABLAAFFAgIBgAOAOIhAA==.',['瑪法']='瑪法里奧怒風:BAAALAADCgQIBAAAAA==.',['瑾年']='瑾年丨七章:BAABLAAFFH8gAAMIAAYI7SGvDADeAQAIAAYI7SGvDADeAQAOAAMI0B0mDQANAQABLAAFFAgIAgAbAAAAAA==.',['瘸子']='瘸子别跑:BAAALAADCggICAAAAA==.',['白桃']='白桃狸:BAAALAAFFAIIBAAAAA==.',['白白']='白白更健康:BAAALAAECgYIDQAAAA==.',['白羊']='白羊丶:BAACLAAFFH8lAAIWAAYIsxFsIQB6AQAWAAYIsxFsIQB6AQAsAAQKfxQAAhYACAhPFpdVACQCABYACAhPFpdVACQCAAAA.',['白色']='白色:BAAALAAECggICAAAAA==.',['白银']='白银之手:BAAALAAECgIIAwAAAA==.',['白驹']='白驹过隙:BAACLAAFFH8eAAMPAAUIMxLaCQASAQAPAAUIMxLaCQASAQAIAAII9wcjQwCLAAAsAAQKfx8AAw8ABwjkHVcWAEUCAA8ABwjkHVcWAEUCAAgABAi2CLtBAa0AAAAA.',['百香']='百香果啤酒:BAAALAAECgYIBgAAAA==.',['皎若']='皎若升霞:BAAALAAFFAIIBAAAAA==.',['睡不']='睡不着起的号:BAAALAAECgYIEwAAAA==.',['瞅你']='瞅你妹夫阿:BAAALAAECgMIAwAAAA==.瞅你妹阿:BAABLAAFFH8TAAMRAAYI0R3PLQB/AQARAAYI0R3PLQB/AQAaAAIIthVyBACdAAABLAAFFAYIIQAJAGEbAA==.',['瞬发']='瞬发炉石:BAAALAAECgcIDgAAAA==.',['矮壮']='矮壮壮:BAAALAAECgUICAAAAA==.',['砙裏']='砙裏安乌瑞恩:BAAALAADCgYICQAAAA==.',['硬的']='硬的吓银:BAAALAADCgQIBAAAAA==.',['碎肉']='碎肉:BAABLAAECn8UAAIBAAgIRCBVJwDTAgABAAgIRCBVJwDTAgAAAA==.',['神乐']='神乐仙鹤:BAAALAAECgYIDAAAAA==.',['神都']='神都老道:BAABLAAECn8XAAQQAAYIFArdIgC8AAAQAAUI1AvdIgC8AAAkAAII5gOpNABfAAAHAAMIkQKBAgE6AAAAAA==.',['祺丶']='祺丶:BAABLAAFFH8HAAMFAAII8QwTHQBCAAAEAAEIMAppIwBLAAAFAAEIsw8THQBCAAAAAA==.',['秋暮']='秋暮:BAAALAADCgEIAgAAAA==.',['科拉']='科拉多红鬃:BAABLAAECn8hAAIKAAYI2Bk4QwBPAQAKAAYI2Bk4QwBPAQAAAA==.',['秦淮']='秦淮茹:BAAALAAECgYIDwAAAA==.',['穆萨']='穆萨罗:BAAALAAECgMIAwAAAA==.',['穷奇']='穷奇:BAAALAADCgMIAwAAAA==.',['立风']='立风:BAABLAAECn8YAAINAAgI1R0yHQChAgANAAgI1R0yHQChAgAAAA==.',['筱梦']='筱梦梦:BAABLAAFFH8MAAIRAAYIPR4bHQC+AQARAAYIPR4bHQC+AQAAAA==.',['米瑟']='米瑟莉娜斯:BAAALAAECgMIBQAAAA==.',['粉色']='粉色:BAACLAAFFH8HAAMOAAUISwUFCwBAAQAOAAUISwUFCwBAAQAPAAII2BmoFgBFAAAsAAQKfxgABA8ACAi1GsIfAPwBAA8ACAi1GsIfAPwBAAgABQg7Dz4wAdEAAA4AAwj8GAA0AKYAAAAA.',['粼玉']='粼玉:BAAALAAECgEIAQAAAA==.',['精灵']='精灵:BAAALAAFFAIIAwAAAA==.',['精神']='精神丶小妹:BAAALAAECgMIAwAAAA==.',['糖逗']='糖逗:BAAALAAECgYIDAAAAA==.',['紫色']='紫色:BAAALAAECgYIDAAAAA==.',['红色']='红色的樱花树:BAAALAADCggICAAAAA==.',['纵横']='纵横丨捭阖灬:BAAALAAFFAIIAgAAAA==.',['绝版']='绝版可乐:BAACLAAFFH8LAAIDAAIIvh/MJwCLAAADAAIIvh/MJwCLAAAsAAQKfxQAAgMACAjsFoQyABYCAAMACAjsFoQyABYCAAAA.',['绵鱼']='绵鱼:BAABLAAECn8XAAMEAAgIEhmQLADBAQAEAAcI1hiQLADBAQAFAAMI4hX9QACTAAAAAA==.',['翔冰']='翔冰灵月:BAAALAAECgYIDAAAAA==.',['老北']='老北鼻:BAAALAAECgYIBgAAAA==.',['老哥']='老哥稳:BAAALAAECgIIAgAAAA==.',['老婆']='老婆最好:BAAALAAFFAIIBAAAAA==.',['老炮']='老炮:BAABLAAECn8WAAMNAAYIlg5EWQD7AAANAAYIlg5EWQD7AAAcAAMIeQ0ybQBfAAAAAA==.',['老牛']='老牛北鼻:BAAALAAECggICAAAAA==.',['老鼠']='老鼠小弟:BAAALAAECgYIBwAAAA==.',['耶哥']='耶哥蕊特:BAAALAAECgYICQAAAA==.',['聖珖']='聖珖:BAAALAAECgYIBgAAAA==.',['聖白']='聖白聖:BAAALAADCgYIBgAAAA==.',['肆喜']='肆喜:BAAALAAECgYICwAAAA==.',['能抗']='能抗能打:BAABLAAECn8WAAMKAAYIqwmyZQDkAAAKAAYIqwmyZQDkAAAUAAEIlgErWwARAAAAAA==.',['腰若']='腰若流纨素:BAAALAAFFAIIAwAAAA==.',['舅妈']='舅妈:BAAALAAECgYIBgAAAA==.',['舞埗']='舞埗榎雪:BAABLAAFFH8OAAMMAAMIBQkqSABaAAAMAAIIGAUqSABaAAATAAEI8wFoMAAyAAABLAAFFAYIHwAGADgWAA==.',['艾尔']='艾尔咆哮:BAAALAAECgQIBAAAAA==.',['芫爆']='芫爆肚丝:BAAALAAECgYIDAAAAA==.',['芬达']='芬达丶丶:BAAALAAECgMIAwAAAA==.',['芭芭']='芭芭拉:BAAALAAECgYIBgAAAA==.芭芭拉冲鸭:BAAALAAECgIIAgAAAA==.',['花丛']='花丛下永生:BAAALAAECgQIBAAAAA==.',['苟蛋']='苟蛋:BAAALAAECgIIAgAAAA==.',['若相']='若相惜丶卟離:BAAALAAECgQIBAAAAA==.',['英特']='英特纳雄奈尔:BAAALAAFFAEIAQAAAA==.',['英雄']='英雄王座:BAABLAAECn8UAAIBAAYIJxqWqQC4AQABAAYIJxqWqQC4AQAAAA==.',['苹什']='苹什猫:BAAALAAFFAIIBAAAAA==.',['茕茕']='茕茕白兔丶:BAABLAAECn8gAAIIAAcIjQyjbQAnAQAIAAcIjQyjbQAnAQAAAA==.',['茜茜']='茜茜小公主:BAABLAAFFH8IAAIIAAIIpwsVcAA+AAAIAAIIpwsVcAA+AAAAAA==.',['草莓']='草莓小奶昔:BAAALAAECgMIAwAAAA==.',['荣耀']='荣耀之箭:BAAALAAFFAIIBAAAAA==.',['莺歌']='莺歌:BAAALAADCgYIBgAAAA==.',['萌萌']='萌萌很德:BAAALAADCgIIAgAAAA==.',['萨满']='萨满:BAAALAAECggIDAAAAA==.萨满丶贺:BAAALAADCgIIAgAAAA==.',['萨灬']='萨灬灬尔:BAAALAAECgIIAgAAAA==.',['萨茜']='萨茜摩尔:BAAALAAECgYICwAAAA==.',['萨蛋']='萨蛋之血:BAAALAADCgIIAgAAAA==.',['落誮']='落誮冇意:BAABLAAFFH8IAAIIAAIIjB8FPgCgAAAIAAIIjB8FPgCgAAAAAA==.',['葡萄']='葡萄小果汁:BAAALAAECgYIDwAAAA==.',['蓝莓']='蓝莓可乐丶:BAAALAADCgIIAgAAAA==.',['蓝魔']='蓝魔晶灵:BAABLAAFFH8KAAISAAYIeADfawAdAAASAAYIeADfawAdAAAAAA==.',['虎鲸']='虎鲸:BAAALAAFFAIIAgAAAA==.',['蛮牛']='蛮牛:BAACLAAFFH8QAAIUAAMIfQt8IQBtAAAUAAMIfQt8IQBtAAAsAAQKfx8AAhQACAiNFXsYAIABABQACAiNFXsYAIABAAAA.蛮牛牛:BAAALAAECgEIAQAAAA==.',['血煞']='血煞骑士:BAAALAAFFAIIAgAAAA==.',['血蹄']='血蹄丶之殇:BAAALAAFFAIIAgAAAA==.',['行秋']='行秋:BAAALAAECgYIAwAAAA==.',['表妹']='表妹丶来了哦:BAAALAAFFAIIBAAAAA==.',['裙下']='裙下之臣:BAAALAADCgEIAQAAAA==.',['识得']='识得东风面:BAAALAADCgQIBAAAAA==.',['诗蓝']='诗蓝丶:BAABLAAFFH8IAAIRAAYIehCEQgA/AQARAAYIehCEQgA/AQAAAA==.',['说爱']='说爱你:BAABLAAFFH8MAAINAAII1QdzYwBdAAANAAII1QdzYwBdAAAAAA==.',['请叫']='请叫我小賊:BAAALAAFFAIIAgAAAA==.',['谁叫']='谁叫的外卖:BAAALAAECgIIAgAAAA==.',['谕光']='谕光:BAAALAADCgMIAwAAAA==.',['谷唯']='谷唯一:BAAALAAFFAIIAwAAAA==.',['豌豆']='豌豆射手:BAAALAAECgEIAQAAAA==.',['豪门']='豪门绝恋:BAAALAADCgIIAgAAAA==.',['貓貓']='貓貓雨:BAACLAAFFH8oAAINAAcIohLtFwCdAQANAAcIohLtFwCdAQAsAAQKfzQAAg0ACAhKH50QAHACAA0ACAhKH50QAHACAAAA.',['賈賈']='賈賈:BAAALAAECgcICwAAAA==.',['贝塔']='贝塔:BAAALAAECgYIEwAAAA==.',['贼贼']='贼贼帅丶丨:BAAALAAECgYICAAAAA==.',['贾一']='贾一乐:BAABLAAFFH8FAAIcAAIIhw6qKwCRAAAcAAIIhw6qKwCRAAAAAA==.',['赌气']='赌气巴拉:BAAALAADCgMIAwAAAA==.',['赵一']='赵一荻:BAAALAAFFAIIAgAAAA==.',['超烦']='超烦之萌:BAAALAAECgYIBwAAAA==.',['超级']='超级熊猫:BAABLAAFFH8KAAIIAAIIwgRkfQAzAAAIAAIIwgRkfQAzAAAAAA==.超级熊猫爸爸:BAABLAAFFH8GAAIKAAIImAGRTwBeAAAKAAIImAGRTwBeAAAAAA==.',['路过']='路过的路:BAACLAAFFH8IAAIRAAMIMBY2bwCDAAARAAMIMBY2bwCDAAAsAAQKfyMAAhEABwi4IOErAAkCABEABwi4IOErAAkCAAAA.',['踏雪']='踏雪寻梅:BAAALAAECgEIAQAAAA==.',['达闻']='达闻希:BAAALAAECgEIAQAAAA==.',['这孩']='这孩子叫奥鲁:BAAALAAECgYIDAAAAA==.',['迦丶']='迦丶罗娜:BAAALAAECgYIEwAAAA==.',['迪迦']='迪迦奥特曼:BAAALAAECgUIBQAAAA==.',['迷路']='迷路的橘子:BAAALAAECgYIBgAAAA==.',['逍遥']='逍遥臭臭:BAAALAAECgYIBgAAAA==.',['遙遠']='遙遠有多遠:BAAALAAECgYICAAAAA==.',['那夜']='那夜忘带药:BAAALAAFFAIIAgAAAA==.',['邪痕']='邪痕:BAABLAAFFH8GAAIUAAIIeh7cJgBKAAAUAAIIeh7cJgBKAAAAAA==.',['部落']='部落晚风:BAAALAAECgYIBwAAAA==.',['醉丶']='醉丶春风:BAAALAAECgYIBgAAAA==.',['重门']='重门花影:BAAALAAECgQIBAAAAA==.',['野生']='野生小凹凸曼:BAABLAAFFH8FAAIIAAIIzRioQACeAAAIAAIIzRioQACeAAABLAAFFAgIBwAQAMwgAA==.野生猎手:BAAALAAECgUIBQAAAA==.',['野蛮']='野蛮的鞭哥:BAAALAAECggICAAAAA==.',['金曈']='金曈迪妮莎:BAAALAAECgcIBwAAAA==.',['钢丝']='钢丝床:BAACLAAFFH8lAAIWAAYIqSKHEADcAQAWAAYIqSKHEADcAQAsAAQKfxkAAhYACAhqJIsJAFIDABYACAhqJIsJAFIDAAAA.',['钱多']='钱多多:BAAALAADCgIIAgAAAA==.',['铁血']='铁血小刀:BAAALAAECgQIBQAAAA==.',['锋行']='锋行天下:BAAALAAECggICAAAAA==.',['長岛']='長岛冰茶:BAAALAAECggICAAAAA==.',['长天']='长天一色:BAAALAADCgIIAgAAAA==.',['闪电']='闪电宝宝:BAAALAAECgQIBAAAAA==.',['阿刁']='阿刁:BAAALAAECgEIAQAAAA==.',['阿劣']='阿劣劣:BAAALAAECgYIBgAAAA==.',['阿尔']='阿尔德尼亚:BAAALAAECgYICgAAAA==.',['阿拉']='阿拉蕾囧:BAAALAAECgYIBgAAAA==.',['阿氪']='阿氪萌德:BAAALAADCgQIBAAAAA==.',['阿灬']='阿灬尔萨灬斯:BAAALAADCgYIDAAAAA==.',['阿苏']='阿苏焉:BAAALAAFFAIIAwAAAA==.',['陈佳']='陈佳影:BAAALAAECgYIDAABLAAECgYIDwAbAAAAAA==.',['降龍']='降龍一八掌:BAAALAADCgQIBAAAAA==.',['隐藏']='隐藏悲伤:BAAALAAECgMIAwAAAA==.',['隔壁']='隔壁老張:BAAALAADCgYIBgABLAAFFAgIAgAbAAAAAA==.',['雕你']='雕你妹:BAACLAAFFH8aAAITAAYICwkmEgBKAQATAAYICwkmEgBKAQAsAAQKfxwAAhMACAjYEbYXAJABABMACAjYEbYXAJABAAAA.',['雪莉']='雪莉:BAAALAAECggICAAAAA==.',['雷灬']='雷灬克灬萨丶:BAAALAAECgYIDwAAAA==.',['露琳']='露琳之光:BAAALAAFFAIIAgAAAA==.',['青岛']='青岛小黄鱼:BAABLAAFFH8bAAMMAAUI3gqSIwAiAQAMAAUI3gqSIwAiAQATAAMIsgUOIgB0AAAAAA==.',['韩德']='韩德萨姆:BAAALAAECgQIBAAAAA==.',['风一']='风一样的男人:BAAALAADCgIIAgAAAA==.',['风暴']='风暴烈焰:BAAALAADCgUIBQAAAA==.',['飒飒']='飒飒萨:BAAALAAECgUIBwAAAA==.',['飞天']='飞天小牛:BAAALAADCgMIAwAAAA==.',['飞雪']='飞雪无情:BAAALAAECgQIBAAAAA==.飞雪星尘:BAAALAAECgcIBwAAAA==.',['饼饼']='饼饼小公主:BAAALAAECgMIAwAAAA==.',['香苓']='香苓:BAAALAAECgYIBgAAAA==.',['马戏']='马戏团驯兽师:BAAALAAECgYIBgAAAA==.',['高兴']='高兴丶骑:BAAALAAECgUIBQAAAA==.',['鬼火']='鬼火冲天:BAAALAADCgQIBAAAAA==.',['鬼雨']='鬼雨墨山:BAAALAAECgMIAwABLAAFFAIICgADAK4dAA==.',['魁梧']='魁梧的汉子:BAABLAAFFH8FAAIOAAUIQAnvFwAOAQAOAAUIQAnvFwAOAQAAAA==.',['魔法']='魔法闹闹:BAAALAAECggIDgAAAA==.',['鮮血']='鮮血哀川凜:BAAALAAECgcICAAAAA==.',['鲜血']='鲜血丶荣耀:BAAALAAECgMIAwAAAA==.',['鲨鱼']='鲨鱼饵丶:BAACLAAFFH8KAAIgAAUIGwtCAgCKAQAgAAUIGwtCAgCKAQAsAAQKfxoAAiAACAgdH9QHANoCACAACAgdH9QHANoCAAAA.',['麥灬']='麥灬迪灬文:BAAALAAECgYIBgAAAA==.',['麦克']='麦克雷女青年:BAAALAAECgYIBgAAAA==.',['麦兜']='麦兜:BAAALAADCgQIBAAAAA==.',['麻珐']='麻珐里奥:BAAALAAECgYIBgAAAA==.',['麻衣']='麻衣学姐丶:BAAALAADCgYIBgAAAA==.',['麽啊']='麽啊:BAAALAAFFAEIAQAAAA==.',['黎恩']='黎恩舒华泽:BAAALAAECgQIBAAAAA==.',['黑色']='黑色守望:BAAALAAECgYIDAAAAA==.',['龍希']='龍希尔:BAACLAAFFH9FAAMeAAgIhhoeAwCQAgAeAAgIhhoeAwCQAgAJAAUIIhnyDQA/AQAsAAQKfxcAAx4ACAjiIFIHAMMCAB4ACAjiIFIHAMMCAAkAAggDGlVbAIMAAAAA.',['龙泽']='龙泽罗拉:BAAALAAECgYIBgAAAA==.',['龙虾']='龙虾:BAAALAADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end