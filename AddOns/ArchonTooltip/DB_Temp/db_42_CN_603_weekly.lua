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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Shaman-Restoration','Hunter-BeastMastery','Paladin-Retribution','Paladin-Holy','Warrior-Fury','Druid-Restoration','Druid-Balance','Rogue-Assassination','Mage-Fire','Mage-Frost','Paladin-Protection','DemonHunter-Havoc','Unknown-Unknown','DeathKnight-Frost','Priest-Discipline','Priest-Holy','Warlock-Destruction','Warlock-Affliction','Hunter-Marksmanship','Priest-Shadow','Mage-Arcane','Warrior-Arms','Warlock-Demonology','Warrior-Protection','Evoker-Preservation','Evoker-Devastation',}; local provider = {region='CN',realm='古加尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aarnes:BAAAKgAECgUIBgAAAA==.',Al='Alphakenyone:BAAAKgADCgMIAwAAAA==.',As='Ashbringe:BAAAKgADCgEIAQAAAA==.',Ca='Candice:BAAAKgAECgUICQAAAA==.',Ch='Chenxiaobao:BAAAKgADCgYIBgAAAA==.',De='Deathme:BAAAKgAFFAgIBAAAAA==.',Do='Donmdunk:BAAAKgAECggICAAAAA==.',Du='Dugg:BAABKgAFFH8TAAMBAAgIjBUuDQC9AQABAAgIHRUuDQC9AQACAAQI/xa3HQC1AAAAAA==.',Ei='Eiwa:BAAAKgAECgIIBAAAAA==.',Fi='Filipo:BAABKgAFFH8GAAIDAAYIQAdoGAAgAQADAAYIQAdoGAAgAQAAAA==.',Gi='Gilgil:BAABKgAFFH8MAAIDAAgILRQtBwDWAQADAAgILRQtBwDWAQAAAA==.',Hu='Hunterhh:BAABKgAFFH8FAAIEAAUIMxiKIAALAQAEAAUIMxiKIAALAQAAAA==.',Ja='Jackeychen:BAAAKgADCgMIAwAAAA==.',Ko='Koiluy:BAAAKgAECgQIBAAAAA==.',Lu='Luan:BAAAKgAECggIEwAAAA==.',Mq='Mqs:BAACKgAFFH8JAAMFAAYIrBamAQDWAQAFAAYIrBamAQDWAQAGAAIIaB1yDACcAAAqAAQKfxgAAgUACAixIjUiAJECAAUACAixIjUiAJECAAAA.',No='Noberad:BAABKgAECn80AAIGAAgIkiGWCwA2AgAGAAgIkiGWCwA2AgAAAA==.',Pl='Playergrnqec:BAAAKgAECgQIBAAAAA==.Playerhvtutm:BAABKgAECn8eAAIFAAgIaBX5dACtAQAFAAgIaBX5dACtAQAAAA==.',Re='Redbin:BAABKgAECn8YAAMBAAgIcx4dGABMAgABAAgIcx4dGABMAgACAAEIIwX2IQAZAAAAAA==.',Sa='Sankes:BAABKgAFFH8QAAIHAAgIRhoJAwCYAgAHAAgIRhoJAwCYAgAAAA==.',Sw='Sweetbang:BAAAKgAECgMIAwAAAA==.',Ti='Tiktok:BAAAKgAECgUIBAAAAA==.',Un='Unpoco:BAAAKgAECgMIAwAAAA==.',Yo='Yoao:BAAAKgAFFAQIBAAAAA==.',['一次']='一次意外之外:BAAAKgAECggIDQAAAA==.',['一炬']='一炬:BAACKgAFFH8OAAIFAAMITyC5OgACAQAFAAMITyC5OgACAQAqAAQKfx0AAgUACAhZHXVaAOkBAAUACAhZHXVaAOkBAAAA.',['一般']='一般:BAAAKgAECgMIAwAAAA==.',['七崽']='七崽:BAAAKgAECgMIAwAAAA==.',['下雪']='下雪天:BAAAKgAECgEIAQAAAA==.',['丢丢']='丢丢饕餮:BAAAKgAFFAgIBAAAAA==.',['丧娇']='丧娇的小提琴:BAAAKgAECgYIBgAAAA==.',['丶断']='丶断香:BAABKgAECn8WAAMIAAgIkRJlJAB+AQAIAAgIkRJlJAB+AQAJAAEI3Ag52wAqAAAAAA==.',['丶暗']='丶暗刺:BAABKgAFFH8IAAIKAAgIzQX+CADMAQAKAAgIzQX+CADMAQAAAA==.',['丶法']='丶法灬殇:BAACKgAFFH8IAAILAAQIvCHBEAARAQALAAQIvCHBEAARAQAqAAQKfxgAAwwACAivEcw+AG8BAAwACAivEcw+AG8BAAsACAj1Ap1rAMUAAAAA.',['丶纵']='丶纵火饭:BAAAKgAECgEIAQAAAA==.',['为了']='为了丨圣光:BAAAKgAECgEIAQAAAA==.',['乂骨']='乂骨头小白乂:BAABKgAFFH8HAAIMAAQIvwu8DAC7AAAMAAQIvwu8DAC7AAAAAA==.',['乔乔']='乔乔:BAAAKgADCggICAAAAA==.',['也许']='也许是的:BAAAKgAECgQIBgAAAA==.',['云儿']='云儿丶飘飘:BAAAKgADCggICAAAAA==.',['五火']='五火球神教:BAAAKgAECgYIBgAAAA==.',['人间']='人间不清醒:BAAAKgAFFAQIBAAAAA==.',['仙女']='仙女味胳肢窝:BAAAKgADCggICAAAAA==.',['仙气']='仙气灬飘飘:BAAAKgADCggICAAAAA==.',['以记']='以记忆为眸丶:BAAAKgAFFAYIBAAAAA==.',['依然']='依然丨任性:BAAAKgAFFAQIBAAAAA==.依然丨固执:BAABKgAFFH8FAAINAAUIxwgNCwDbAAANAAUIxwgNCwDbAAAAAA==.',['光明']='光明的灰灰:BAABKgAFFH8FAAIFAAUI2xodLwArAQAFAAUI2xodLwArAQAAAA==.',['兜里']='兜里有枪:BAABKgAFFH8FAAIDAAMIlA+FNQCnAAADAAMIlA+FNQCnAAAAAA==.',['公孙']='公孙丶淑芬:BAAAKgAECgEIAQAAAA==.',['农夫']='农夫桑拳:BAAAKgAECggICAAAAA==.',['冥冥']='冥冥的狐林:BAAAKgAECggIEwAAAA==.',['冰可']='冰可乐丶:BAAAKgAECgEIAQAAAA==.',['凡妮']='凡妮莎:BAAAKgAECggICQAAAA==.',['刘病']='刘病已:BAAAKgAECgEIAQAAAA==.',['别挤']='别挤药膏潮了:BAAAKgAECgYIBwAAAA==.',['剃头']='剃头的影子:BAAAKgAECggIDgAAAA==.',['加厼']='加厼鲁什:BAAAKgAECggICAAAAA==.',['劣质']='劣质西瓜:BAAAKgAFFAQIBAAAAA==.',['十宝']='十宝茶:BAAAKgAECgMIAwAAAA==.',['南极']='南极飘飘雪:BAAAKgAFFAgIAQAAAA==.',['卡西']='卡西利亚斯丶:BAAAKgAECgUIBQAAAA==.',['卷毛']='卷毛的小顺宝:BAAAKgAECgUIBQAAAA==.',['原来']='原来的我:BAAAKgADCgUIBQAAAA==.',['又硬']='又硬了:BAABKgAFFH8PAAIHAAYI4g1xDgBsAQAHAAYI4g1xDgBsAQAAAA==.',['只会']='只会假死:BAABKgAFFH8GAAIEAAYIwQ9DFQBLAQAEAAYIwQ9DFQBLAQAAAA==.',['右边']='右边忧伤:BAABKgAFFH8GAAIJAAYICA4tHAA5AQAJAAYICA4tHAA5AQAAAA==.',['司徒']='司徒丶翠花:BAAAKgAECggICwAAAA==.',['吖宝']='吖宝灬:BAABKgAFFH8IAAIJAAMI/gk6PgCxAAAJAAMI/gk6PgCxAAAAAA==.',['君子']='君子的法丝:BAABKgAECn8XAAILAAgIOSHREACTAgALAAgIOSHREACTAgAAAA==.君子的骑士:BAABKgAFFH8GAAINAAYI+RVcDAAxAQANAAYI+RVcDAAxAQAAAA==.',['听雨']='听雨落:BAABKgAFFH8VAAIFAAYI4RacEQCGAQAFAAYI4RacEQCGAQAAAA==.',['哈达']='哈达思根:BAAAKgAECgMIAwAAAA==.',['哎呦']='哎呦喂纳:BAAAKgAECgYIBgAAAA==.',['哑蛮']='哑蛮嗲:BAAAKgADCgcIBwAAAA==.',['四肢']='四肢疼:BAAAKgADCggICgAAAA==.',['因崔']='因崔斯汀:BAAAKgAFFAMIAgAAAA==.',['国民']='国民小三:BAABKgAECn8nAAIOAAgIkBmIIwDrAQAOAAgIkBmIIwDrAQAAAA==.',['圣光']='圣光照耀人夭:BAAAKgAECgIIAgAAAA==.圣光蟹丶:BAABKgAFFH8HAAIFAAMI3hAiUADPAAAFAAMI3hAiUADPAAAAAA==.',['圣血']='圣血魔骑:BAACKgAFFH8GAAIFAAMI/QnPXgCzAAAFAAMI/QnPXgCzAAAqAAQKfxUAAwUABwhhEb+yADIBAAUABwiyD7+yADIBAA0AAQgEFnlQAD8AAAAA.',['地狱']='地狱小武:BAAAKgADCggICAAAAA==.地狱小法:BAAAKgADCggICAAAAA==.地狱小萨:BAAAKgADCgMIAwAAAA==.地狱音铃:BAAAKgADCgQIBAAAAA==.',['坟场']='坟场做戏:BAAAKgAECgIIAgAAAA==.',['堕落']='堕落丷天神:BAAAKgAECgQIBQAAAA==.',['复仇']='复仇哀木梯:BAABKgAFFH8GAAIHAAYICRjJCgCeAQAHAAYICRjJCgCeAQABKgAFFAgIAgAPAAAAAA==.',['大叔']='大叔十八:BAAAKgADCggICAAAAA==.',['天外']='天外飞仙:BAABKgAFFH8IAAIHAAQIbxG7EgDuAAAHAAQIbxG7EgDuAAABKgAFFAgIAgAPAAAAAA==.',['天真']='天真丶小恶魔:BAAAKgAECggICAAAAA==.天真丶小术:BAAAKgAECgMIBQAAAA==.',['头疼']='头疼的老蜗牛:BAAAKgAFFAYIAgAAAA==.',['奶德']='奶德:BAAAKgAFFAcIAwABKgAFFAgIBAAPAAAAAA==.',['奶油']='奶油轻乳酪:BAAAKgAECggICAAAAA==.',['奶骑']='奶骑:BAAAKgAFFAQIBAABKgAFFAgIBAAPAAAAAA==.',['好大']='好大一块德芙:BAAAKgADCggICAAAAA==.',['孔雀']='孔雀东南飞:BAABKgAFFH8MAAQBAAQI/iEXJAAEAQABAAQI/iEXJAAEAQAQAAQI/RX/CADbAAACAAII+A5WHQBxAAABKgAFFAgIEAAFAIwiAA==.',['宠魅']='宠魅:BAAAKgAECgEIAQAAAA==.',['射人']='射人先射鸟:BAAAKgAECgEIAQAAAA==.',['射鬼']='射鬼:BAAAKgAFFAYIBAABKgAFFAgIAwAPAAAAAA==.',['小丶']='小丶木:BAAAKgAFFAIIAgAAAA==.',['小小']='小小木:BAAAKgAECgIIAgAAAA==.',['小木']='小木:BAABKgAFFH8KAAMRAAYIICNrBABQAQASAAYIDxxrCQCNAQARAAQIZSZrBABQAQAAAA==.',['小柒']='小柒殿:BAAAKgADCgcIBwAAAA==.',['小瓷']='小瓷气:BAAAKgAECgMIAwAAAA==.',['小纯']='小纯洁:BAAAKgAECgMIBQAAAA==.',['左边']='左边忧伤:BAACKgAFFH8WAAIFAAYIvyRkAQDjAQAFAAYIvyRkAQDjAQAqAAQKfyQAAgUACAgHJlsJAPUCAAUACAgHJlsJAPUCAAEqAAUUCAgMAAcAJBoA.',['幸运']='幸运猫小妹:BAAAKgAECgcIBwAAAA==.',['异凌']='异凌夜色:BAAAKgADCgYIBgAAAA==.',['德不']='德不常死:BAAAKgAECgYICgAAAA==.',['德道']='德道:BAAAKgADCggICAAAAA==.',['怕尾']='怕尾围绕:BAAAKgAECgMIAwAAAA==.',['恩静']='恩静:BAAAKgADCggIEAAAAA==.',['情绪']='情绪:BAAAKgADCgEIAQAAAA==.',['惊蛰']='惊蛰:BAAAKgAFFAYIAgAAAA==.',['憨憨']='憨憨的贝贝:BAAAKgAECgEIAQAAAA==.',['戈魯']='戈魯哈格:BAAAKgAECggICAAAAA==.',['我不']='我不管我最萌:BAABKgAFFH8IAAICAAgIWBLyBQDZAQACAAgIWBLyBQDZAQAAAA==.',['打手']='打手手打:BAABKgAFFH8IAAIFAAgIZxwPBQCCAgAFAAgIZxwPBQCCAgAAAA==.',['扶伤']='扶伤丶不救死:BAAAKgAECggIEQAAAA==.',['抱紧']='抱紧你离开你:BAAAKgAECgMIAwAAAA==.',['拂晓']='拂晓:BAAAKgAECgQIBgAAAA==.',['拒绝']='拒绝者:BAAAKgAFFAQIAQAAAA==.',['挪威']='挪威朗拿度:BAABKgAFFH8GAAMTAAQIqgtyJwBxAAATAAIIOw1yJwBxAAAUAAQIjAmDHgBFAAAAAA==.',['斗战']='斗战苍穹:BAAAKgAECggICAAAAA==.',['无邪']='无邪幸运喵:BAABKgAFFH8GAAMVAAQIBBQ5DQAsAQAVAAQIBBQ5DQAsAQAEAAIIRQMcJQCBAAAAAA==.无邪幸运汪:BAABKgAFFH8IAAIFAAgILRZtCQArAgAFAAgILRZtCQArAgAAAA==.',['旺财']='旺财不要狗带:BAAAKgAECgUICgAAAA==.',['星丶']='星丶期丶八:BAAAKgAECgEIAQAAAA==.',['晶晶']='晶晶的呆呆:BAAAKgAECgEIAQAAAA==.',['暗夜']='暗夜双刀:BAAAKgAECgIIAgAAAA==.',['暗灵']='暗灵丽姿华舞:BAAAKgADCgIIAgAAAA==.',['有得']='有得必有湿:BAAAKgADCggICAAAAA==.',['有点']='有点淘气:BAAAKgAECgUICQAAAA==.',['木木']='木木:BAAAKgADCgUICAAAAA==.',['朴实']='朴实吳华:BAAAKgADCggICwAAAA==.',['李扬']='李扬:BAAAKgADCgMIAwAAAA==.',['枪之']='枪之勇者:BAAAKgAECggIDAAAAA==.',['柚柚']='柚柚:BAAAKgAFFAQIBAAAAA==.',['根号']='根号肆:BAAAKgAECggICwAAAA==.',['楓丨']='楓丨忆霖:BAAAKgAFFAQIBAAAAA==.',['槙岛']='槙岛沙织:BAAAKgADCgMIAwAAAA==.',['樱花']='樱花丶宝儿:BAACKgAFFH8HAAINAAcI1APnCQD5AAANAAcI1APnCQD5AAAqAAQKfx4AAwUACAimHFRHABoCAAUACAimHFRHABoCAAYACAijEgkZAKABAAAA.',['欧墨']='欧墨尼得斯:BAAAKgADCgQIBgAAAA==.',['歆竹']='歆竹:BAABKgAFFH8GAAIFAAUIAQkQHwDuAAAFAAUIAQkQHwDuAAAAAA==.',['永恒']='永恒极昼:BAAAKgADCgMIBQAAAA==.',['汉格']='汉格玛:BAABKgAFFH8RAAMVAAgITCDMAgB/AgAVAAgITCDMAgB/AgAEAAQIdxFhPACrAAAAAA==.',['汪易']='汪易勃:BAAAKgADCgIIAgAAAA==.',['没名']='没名字的名字:BAAAKgAFFAEIAQAAAA==.',['没的']='没的事做:BAAAKgAECgQICQAAAA==.',['没空']='没空洗澡:BAAAKgAECgIIAgAAAA==.没空洗脸:BAAAKgADCgMIAwAAAA==.',['浪浪']='浪浪山小猪仙:BAAAKgAECgEIAQAAAA==.',['清清']='清清小猎:BAAAKgADCggIDQAAAA==.',['灰来']='灰来灰气:BAAAKgAFFAIIAgAAAA==.',['灰色']='灰色的天空:BAAAKgAECgcIDgAAAA==.',['炬一']='炬一:BAABKgAFFH8NAAIMAAMIEBpmEADfAAAMAAMIEBpmEADfAAAAAA==.',['烈蹄']='烈蹄丨美酒:BAAAKgADCggICAAAAA==.',['燃烧']='燃烧丶:BAABKgAECn8VAAIDAAgInxV/MQCyAQADAAgInxV/MQCyAQAAAA==.',['爆护']='爆护小欧皇:BAAAKgAECgYICQAAAA==.',['爱睡']='爱睡觉的小华:BAAAKgADCggICAAAAA==.',['狄瑞']='狄瑞吉丶:BAAAKgADCgQIBAAAAA==.',['独孤']='独孤丶富贵:BAAAKgAECgUIBgAAAA==.',['猎穎']='猎穎:BAAAKgAECgEIAQAAAA==.',['猎龙']='猎龙者:BAABKgAECn8fAAIEAAgIuxzXIwApAgAEAAgIuxzXIwApAgAAAA==.',['猴大']='猴大侠:BAAAKgAECgMIBAAAAA==.',['玄灵']='玄灵仙人:BAAAKgADCggICAAAAA==.',['王者']='王者归来:BAAAKgAECgEIAQAAAA==.',['瓦纳']='瓦纳斯:BAABKgAFFH8SAAIEAAMI0CDMFgD0AAAEAAMI0CDMFgD0AAAAAA==.',['甜甜']='甜甜圈公主:BAABKgAFFH8IAAIOAAgI9xBrCQDoAQAOAAgI9xBrCQDoAQAAAA==.',['痴心']='痴心丶换情深:BAAAKgAECgMIAwAAAA==.',['白雪']='白雪酥酥:BAAAKgAECgYIDQAAAA==.',['百厮']='百厮不嘚骑姐:BAAAKgAFFAIIBAAAAA==.',['真红']='真红奈奈娜:BAACKgAFFH8RAAIRAAQIYxf3CwD1AAARAAQIYxf3CwD1AAAqAAQKfygAAxEACAgzIXkJAIsCABEACAgzIXkJAIsCABYABAjIBppSAKEAAAAA.真红幽梦:BAAAKgADCggICAAAAA==.真红梅莉娜:BAAAKgAECgIIAgAAAA==.',['眼眸']='眼眸熏染绝情:BAAAKgADCggICAAAAA==.',['矿工']='矿工路小学:BAAAKgAECgcICQAAAA==.',['神射']='神射手啊:BAAAKgAECgYIBgAAAA==.',['秋秋']='秋秋吖:BAABKgAFFH8fAAMWAAgIpBOxAgCvAQAWAAgIpBOxAgCvAQASAAQI4QfoLQCNAAAAAA==.',['米歇']='米歇尔丶:BAAAKgAECggIDQAAAA==.',['紫色']='紫色蝙蝠:BAAAKgAFFAQIBAAAAA==.',['紫遐']='紫遐仙子:BAAAKgAFFAQIBAAAAA==.',['絕鈑']='絕鈑小木:BAAAKgAECgYIBgAAAA==.',['纤尘']='纤尘:BAABKgAFFH8IAAIJAAgIOgkFDADCAQAJAAgIOgkFDADCAQAAAA==.',['经常']='经常性缺氧:BAAAKgADCggIDAAAAA==.',['绣衣']='绣衣:BAAAKgAECgQIBAAAAA==.',['罪恶']='罪恶天生:BAAAKgAECgMIAwAAAA==.',['老衲']='老衲只用力士:BAAAKgAFFAMIAwAAAA==.',['老陈']='老陈冲钅:BAAAKgAFFAYIBAAAAA==.老陈盲侠:BAAAKgAFFAQIAQAAAA==.',['肌肉']='肌肉坤:BAAAKgADCgQIAQAAAA==.',['能能']='能能横扫天下:BAAAKgADCgMIAwAAAA==.',['自然']='自然之愈:BAAAKgADCggICAAAAA==.',['舞神']='舞神:BAAAKgAECgQIBAAAAA==.',['艾尔']='艾尔奎特:BAACKgAFFH8JAAMRAAQIiRXSDQDoAAARAAQIiRXSDQDoAAAWAAEIDxHiIwBOAAAqAAQKfxgAAxEACAjKH5EMAGsCABEACAjKH5EMAGsCABIACAhxEdE3AF4BAAAA.',['菌大']='菌大叔玛丽奥:BAAAKgAECgMIBAAAAA==.',['蓝莓']='蓝莓丶面包:BAAAKgAECgIIAQAAAA==.',['蔡徐']='蔡徐困:BAAAKgADCggICAAAAA==.',['螃蟹']='螃蟹丶:BAACKgAFFH8UAAMMAAMIQCABDAALAQAMAAMIQCABDAALAQALAAEIHhLROwBFAAAqAAQKfxYAAgwABgiEJFEhAKgBAAwABgiEJFEhAKgBAAEqAAUUCAgQAAsApxoA.',['西门']='西门猎艳:BAAAKgAECgYICQAAAA==.',['西风']='西风醉:BAAAKgAFFAQIBAAAAA==.',['诗怡']='诗怡很健康:BAAAKgAECgEIAQAAAA==.',['豿看']='豿看家貓鎭宅:BAACKgAFFH8gAAISAAUIqxrcAgA1AQASAAUIqxrcAgA1AQAqAAQKfywAAhIACAiNHU0VACgCABIACAiNHU0VACgCAAAA.',['贫僧']='贫僧法号一灯:BAAAKgAECgUIBQAAAA==.',['赛丽']='赛丽亚丶:BAAAKgADCggICAAAAA==.',['赫尔']='赫尔德丶:BAAAKgADCgUIBgAAAA==.',['超级']='超级帝皮埃斯:BAAAKgAFFAQIBAAAAA==.',['辛师']='辛师不玩墓尸:BAAAKgAECgYICgAAAA==.',['这种']='这种族真丑:BAACKgAFFH8IAAIEAAQI7x/NKgDaAAAEAAQI7x/NKgDaAAAqAAQKfxgAAgQACAgcHysiAG0CAAQACAgcHysiAG0CAAEqAAUUCAgNABcADh0A.',['追梦']='追梦者:BAAAKgAECggICgAAAA==.',['道化']='道化能猫:BAAAKgADCggIFAAAAA==.',['那边']='那边的骑士:BAABKgAFFH8GAAIYAAIIlRGzIgB+AAAYAAIIlRGzIgB+AAAAAA==.',['酒后']='酒后秒杀岳父:BAAAKgADCgEIAQAAAA==.',['醉卧']='醉卧沙场:BAAAKgADCgQIBAAAAA==.',['释怀']='释怀:BAAAKgADCggICAAAAA==.',['铜墙']='铜墙:BAAAKgAECgYIDQAAAA==.',['队长']='队长很生气:BAAAKgAECggICAAAAA==.',['阿布']='阿布滴避风港:BAABKgAECn8VAAIEAAgI6As8bgAMAQAEAAgI6As8bgAMAQAAAA==.阿布的左手:BAAAKgAECgQIBwAAAA==.',['阿达']='阿达尔之手:BAAAKgADCgQICgAAAA==.',['陈八']='陈八八:BAABKgAFFH8TAAMEAAcILh/+CgAqAQAEAAYIch/+CgAqAQAVAAUI8B/0BgAPAQAAAA==.',['限量']='限量鈑嘚嗳:BAAAKgAECgQIBAAAAA==.',['雨双']='雨双木:BAABKgAFFH8WAAMTAAYIKh5sBgA9AQATAAYIKh5sBgA9AQAZAAEI1xVuEwBYAAAAAA==.',['雨天']='雨天不打伞:BAABKgAFFH8JAAMHAAIIdw66IwB0AAAHAAIIBwm6IwB0AAAaAAIIdw7iEgBlAAAAAA==.',['雷勋']='雷勋爵:BAABKgAFFH8LAAITAAMITxScKgDDAAATAAMITxScKgDDAAAAAA==.',['静静']='静静太淘气:BAACKgAFFH8cAAMbAAQI4h/7AwD6AAAbAAQI4h/7AwD6AAAcAAQIPAZPGQCYAAAqAAQKf0YAAhsACAiuJS8BAMQCABsACAiuJS8BAMQCAAAA.',['须臾']='须臾之梦:BAACKgAFFH84AAIEAAgImB5JCQDfAQAEAAgImB5JCQDfAQAqAAQKfyQAAwQACAjeIeMcAIQCAAQACAjeIeMcAIQCABUAAwhoGxtcAOQAAAAA.',['风筝']='风筝:BAAAKgADCgMIAwAAAA==.',['飘渺']='飘渺洛洛:BAAAKgAECgEIAQAAAA==.',['香丶']='香丶飄飄:BAAAKgAECgYIBgAAAA==.',['香灬']='香灬飘飘:BAAAKgADCgEIAQAAAA==.',['马魔']='马魔:BAAAKgAECgMIAwAAAA==.',['魔道']='魔道圣君:BAAAKgADCggICAAAAA==.',['鱼丶']='鱼丶腩:BAAAKgAFFAgIBAAAAA==.',['鲸鱼']='鲸鱼软糖:BAAAKgAFFAQIBAAAAA==.',['麦田']='麦田:BAAAKgADCgEIAgAAAA==.',['黑糖']='黑糖玛琪朵:BAABKgAECn8bAAIEAAgIpSFEEQCdAgAEAAgIpSFEEQCdAgAAAA==.',['齊天']='齊天大圣:BAAAKgAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end