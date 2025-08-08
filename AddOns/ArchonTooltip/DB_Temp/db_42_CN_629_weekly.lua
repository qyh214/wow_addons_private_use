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
 local lookup = {'DemonHunter-Havoc','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Mage-Frost','Priest-Discipline','Priest-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Assassination','Rogue-Outlaw','DeathKnight-Blood','DeathKnight-Unholy','DeathKnight-Frost','Mage-Fire','Mage-Arcane','Warrior-Fury','Paladin-Retribution','Paladin-Holy','Shaman-Elemental','Shaman-Enhancement','Paladin-Protection','Shaman-Restoration','Priest-Shadow','DemonHunter-Vengeance','Druid-Restoration','Druid-Balance','Monk-Mistweaver','Druid-Guardian','Unknown-Unknown','Warrior-Protection','Warrior-Arms','Hunter-Survival','Monk-Windwalker','Monk-Brewmaster','Paladin-Any','Evoker-Devastation',}; local provider = {region='CN',realm='夏维安',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ab='Abiubiubiu:BAAAKgADCgMIAwAAAA==.',Ai='Ailice:BAABKgAFFH8MAAIBAAMIkRxHIQD7AAABAAMIkRxHIQD7AAAAAA==.',An='Andrea:BAAAKgAECggIDAAAAA==.Annriokita:BAAAKgAFFAYIBAAAAA==.',Ca='Carando:BAEBKgAFFH8UAAQCAAgIIyJnBABdAgACAAgIGiJnBABdAgADAAUIbh8FBAA4AQAEAAEIAAAXJAAAAAAAAA==.Cask:BAAAKgADCgQIBAAAAA==.',Da='Darknessover:BAAAKgADCggICAAAAA==.Darkrepulse:BAABKgAFFH8GAAIFAAYIuBvhAwC0AQAFAAYIuBvhAwC0AQAAAA==.',De='Deathdirge:BAAAKgAECgQIBAAAAA==.Deepfire:BAAAKgAECgEIAQAAAA==.Deepray:BAABKgAFFH8QAAMGAAQI3BptEADXAAAGAAQIvhFtEADXAAAHAAQIZhmEFQCUAAAAAA==.Devilone:BAAAKgAECggICwAAAA==.',Di='Dijin:BAABKgAFFH8WAAMIAAQIQBKKMwDCAAAIAAQItw+KMwDCAAAJAAMI/Qu2GQCbAAAAAA==.',Dr='Dreamkiller:BAAAKgAECgUIBwAAAA==.',Ed='Edream:BAABKgAFFH8hAAMKAAYIYhFvDgBqAQAKAAYIOg5vDgBqAQALAAQIJhl0BADbAAAAAA==.',Es='Escaped:BAAAKgAFFAgIAgAAAA==.',Ex='Excelsior:BAABKgAFFH8GAAIJAAYIwwrjGwAQAQAJAAYIwwrjGwAQAQAAAA==.',Fa='Faeries:BAAAKgAFFAgIAwAAAA==.',Fe='Fearmonger:BAABKgAFFH8IAAMMAAQIJgzIJACFAAAMAAQIJgzIJACFAAANAAQIHwV4RwCCAAAAAA==.',Ga='Gabriel:BAAAKgAECgYIBgAAAA==.Gamer:BAAAKgADCggICAAAAA==.',Ho='Howonewobee:BAAAKgAECgYIDAAAAA==.',In='Inori:BAAAKgAFFAgIAgAAAA==.',Ju='June:BAAAKgAECggICAAAAA==.',Ka='Kaserlin:BAABKgAFFH8gAAMOAAYIEBHSAwBmAQAOAAYIEBHSAwBmAQAMAAQIrgifGgCBAAAAAA==.Kay:BAAAKgAFFAIIAgAAAA==.',Ld='Ldream:BAABKgAFFH8UAAIGAAQIcBibFgDeAAAGAAQIcBibFgDeAAAAAA==.',Le='Legendh:BAAAKgADCgcIBwAAAA==.',Lj='Ljg:BAAAKgAECgYIBgAAAA==.',Lo='Loe:BAABKgAFFH8GAAIIAAYIYRFEGgAtAQAIAAYIYRFEGgAtAQAAAA==.Lolzc:BAAAKgAECgcIBwAAAA==.',Ma='Mamahunter:BAAAKgAECgIIAgAAAA==.',Mi='Michacell:BAAAKgAFFAgIAQABKgAFFAgIRwAPADUlAA==.',Mo='Monesy:BAAAKgAFFAIIAgAAAA==.Mostaza:BAABKgAFFH8QAAICAAgIEhqIBwDuAQACAAgIEhqIBwDuAQAAAA==.',Ne='Nermal:BAABKgAFFH8KAAIQAAYI8xF4EwBJAQAQAAYI8xF4EwBJAQAAAA==.Nerzhulh:BAAAKgADCggICAAAAA==.Neverflee:BAACKgAFFH8RAAIRAAMIFhgmGwDpAAARAAMIFhgmGwDpAAAqAAQKfxcAAhEACAh9Ge8iAAkCABEACAh9Ge8iAAkCAAAA.',Od='Odream:BAABKgAFFH8TAAISAAQIxiJzNQAVAQASAAQIxiJzNQAVAQAAAA==.',Ol='Oldwong:BAABKgAECn8aAAIRAAgI4hq5JwDuAQARAAgI4hq5JwDuAQAAAA==.',On='Oniros:BAAAKgAFFAMIAwAAAA==.',Pu='Puplylove:BAAAKgAFFAIIAgAAAA==.',Qi='Qingdao:BAAAKgAFFAQIBAAAAA==.',Qu='Quin:BAAAKgAECgcICgAAAA==.',Ro='Rockms:BAAAKgAFFAgIBAAAAA==.Rockmssq:BAABKgAFFH8GAAMTAAYIlw7WAQBEAQATAAUI3Q7WAQBEAQASAAEIVAOyUgBDAAAAAA==.',Sr='Srphy:BAACKgAFFH8XAAISAAQIvhI0UADPAAASAAQIvhI0UADPAAAqAAQKfxkAAhIACAhTGxlPAAUCABIACAhTGxlPAAUCAAAA.',St='Stuck:BAABKgAFFH8JAAIKAAMI1wgbHgC6AAAKAAMI1wgbHgC6AAAAAA==.',Th='Thunderbolt:BAABKgAFFH8KAAMUAAYIsBzOBQCWAQAUAAYIsBzOBQCWAQAVAAQIXQxlDADqAAAAAA==.',Up='Uplift:BAAAKgAECggICAAAAA==.',Wa='Waitforyou:BAAAKgAECgIIAgAAAA==.',Xg='Xgswdwy:BAAAKgAFFAMIAwAAAA==.',Yi='Yilidanss:BAAAKgADCggICAAAAA==.',Zi='Zireal:BAAAKgAECgEIAQAAAA==.',['一只']='一只浩子:BAAAKgAECggICAAAAA==.',['一叶']='一叶之丘:BAAAKgADCgYIBgAAAA==.',['一往']='一往深情:BAAAKgAECggIDwAAAA==.',['一支']='一支枪:BAAAKgAECgEIAQAAAA==.一支骨:BAAAKgAECgIIAgAAAA==.',['一朵']='一朵灵宝:BAAAKgAECgcIEgAAAA==.',['丁一']='丁一:BAAAKgADCgEIAQAAAA==.',['三修']='三修坠马手:BAABKgAFFH8GAAIWAAYIYwwMEgDuAAAWAAYIYwwMEgDuAAAAAA==.',['三莜']='三莜:BAABKgAFFH8HAAIXAAYIcR63AADeAQAXAAYIcR63AADeAQAAAA==.',['不二']='不二八谦:BAAAKgADCgMIAwAAAA==.',['专门']='专门逮枯法:BAAAKgAFFAIIAgAAAA==.专门逮螃蟹:BAABKgAFFH8KAAQHAAYI+RZOEgAgAQAHAAUIKRlOEgAgAQAYAAEIng9uKwBFAAAGAAQITRSAJwBEAAAAAA==.',['东日']='东日:BAAAKgAECgYIBgAAAA==.',['东阳']='东阳:BAACKgAFFH8LAAIYAAMIChnrFADVAAAYAAMIChnrFADVAAAqAAQKfx8AAhgACAheIgkIAJ4CABgACAheIgkIAJ4CAAAA.',['丨光']='丨光与暗之子:BAAAKgAECgEIAQAAAA==.',['丨八']='丨八喜丨:BAAAKgAECgYICQAAAA==.',['丨可']='丨可乐丨:BAAAKgAFFAMIAwAAAA==.',['丨子']='丨子牙丨:BAAAKgADCgYIBgAAAA==.',['丨巭']='丨巭牜:BAAAKgADCggICAAAAA==.',['丨灵']='丨灵魂之翼丨:BAABKgAECn8nAAMWAAgIUxIGKQANAQASAAYIhhKMuQAmAQAWAAgI9wsGKQANAQAAAA==.',['丨熊']='丨熊猫丨:BAAAKgAECggICAAAAA==.',['丨葡']='丨葡萄哟丨:BAAAKgAFFAgIAgAAAA==.',['丨饺']='丨饺子:BAACKgAFFH8PAAIMAAQIRgG0IQBSAAAMAAQIRgG0IQBSAAAqAAQKfxYAAgwACAjEAa9KAJEAAAwACAjEAa9KAJEAAAAA.',['丶一']='丶一身貓餅:BAAAKgAECggICAAAAA==.',['丶丨']='丶丨希诺:BAAAKgAECgUIDQAAAA==.',['丶亵']='丶亵渎:BAACKgAFFH8QAAIZAAQIvwcDDwCIAAAZAAQIvwcDDwCIAAAqAAQKfxcAAhkACAjAD8AnAEQBABkACAjAD8AnAEQBAAAA.',['丶再']='丶再丗纣王灬:BAAAKgAECgcIBwAAAA==.',['丶嘘']='丶嘘别说话丶:BAABKgAFFH8YAAMJAAYIGCC6CgCrAQAJAAYIGCC6CgCrAQAIAAQI7wluPwCgAAAAAA==.',['丶小']='丶小红花:BAAAKgAECgcIDAAAAA==.丶小语:BAABKgAFFH8OAAIHAAMI6g3tKwCUAAAHAAMI6g3tKwCUAAAAAA==.',['丶柟']='丶柟:BAAAKgAECgcIBwAAAA==.',['丶艾']='丶艾伦:BAAAKgADCgQIBAAAAA==.',['为梦']='为梦而战:BAABKgAFFH8GAAIKAAYINBiOCwCTAQAKAAYINBiOCwCTAQAAAA==.',['丿永']='丿永灬恒丶:BAAAKgAFFAgIBAAAAA==.',['丿魍']='丿魍灬魉丶:BAABKgAFFH8FAAMGAAMIZQv5HwB8AAAHAAMIXQXcMACCAAAGAAII1w35HwB8AAAAAA==.',['丿魑']='丿魑灬魅丶:BAABKgAECn8VAAIBAAgIpRGHOgC/AQABAAgIpRGHOgC/AQAAAA==.',['九龙']='九龙湖墩哥:BAABKgAECn8aAAIWAAcIGgu/LwDhAAAWAAcIGgu/LwDhAAAAAA==.',['书童']='书童灬小贼:BAAAKgAECgUICAAAAA==.',['乱人']='乱人心萨:BAABKgAFFH8FAAIXAAUIswu7DwAEAQAXAAUIswu7DwAEAQAAAA==.',['二等']='二等一:BAAAKgADCgIIAgAAAA==.',['云水']='云水蟾心:BAAAKgAECgYIEAAAAA==.',['五岛']='五岛灭九:BAABKgAFFH8gAAMJAAQIdxNSLwCwAAAJAAQI7Q9SLwCwAAAIAAMIrQiiTwBtAAAAAA==.',['亖极']='亖极度深寒亖:BAABKgAFFH8KAAMQAAYIYiBYDQCQAQAQAAYIYiBYDQCQAQAFAAQIHhSaCwDRAAAAAA==.',['介猴']='介猴卖嘛:BAAAKgAFFAIIBAAAAA==.',['以心']='以心融迹:BAAAKgADCggICAAAAA==.',['以迹']='以迹寻心:BAAAKgADCgMIAwAAAA==.',['伊利']='伊利蛋:BAAAKgAECgEIAQAAAA==.',['众生']='众生为果:BAABKgAECn8fAAMaAAgIlAfTQwDUAAAaAAgIlAfTQwDUAAAbAAIIFQSp5wAUAAAAAA==.',['优秀']='优秀潜力股:BAABKgAFFH8NAAIXAAMIuh3ZJwDXAAAXAAMIuh3ZJwDXAAAAAA==.',['伶俐']='伶俐丨丶阿牛:BAAAKgAECgUIBQAAAA==.',['你脸']='你脸上全是坑:BAAAKgAFFAQICgAAAA==.',['佰事']='佰事可乐:BAAAKgAFFAQIBAAAAA==.',['依然']='依然牛哥:BAAAKgADCggIDAAAAA==.',['信小']='信小絮叨:BAAAKgADCgEIAQAAAA==.',['傻傻']='傻傻望天:BAAAKgADCggIDAAAAA==.',['光之']='光之霓裳:BAAAKgADCgMIAgAAAA==.',['克己']='克己复礼:BAABKgAFFH8NAAIXAAYITBcpBwCtAQAXAAYITBcpBwCtAQAAAA==.',['克莱']='克莱斯顿:BAABKgAFFH8GAAISAAIIRA11SABoAAASAAIIRA11SABoAAAAAA==.',['兔斯']='兔斯基斯:BAAAKgAECggICAAAAA==.',['入殓']='入殓师:BAAAKgAFFAQIBAAAAA==.',['六月']='六月牧歌:BAAAKgAECgcIBwAAAA==.',['其实']='其实不是猫:BAAAKgADCgEIAQAAAA==.',['再见']='再见老恶魔:BAABKgAFFH8GAAISAAYI5hYPAgDIAQASAAYI5hYPAgDIAQAAAA==.',['军团']='军团再临:BAABKgAECn8XAAIFAAcIDhEfRwBJAQAFAAcIDhEfRwBJAQAAAA==.',['冬天']='冬天的冬:BAAAKgAFFAgIBAAAAA==.',['冬歌']='冬歌:BAAAKgAECgIIAgAAAA==.',['冰冷']='冰冷的热血:BAABKgAFFH8IAAQCAAQIASAVHQClAAACAAIIUCEVHQClAAADAAEInh/GEQBcAAAEAAEIxB0pIQBHAAABKgAFFAgIIAAYANQgAA==.',['冰冻']='冰冻三尺:BAAAKgADCggICAAAAA==.',['冰糖']='冰糖丶雪梨:BAAAKgADCgIIAgAAAA==.',['冲锋']='冲锋啊嗖:BAAAKgADCgIIAgAAAA==.',['冷淡']='冷淡夜风:BAACKgAFFH8VAAMZAAQIoRmMBAA6AQAZAAQIoRmMBAA6AQABAAEIkgzOSwA7AAAqAAQKfxwAAhkACAg3G1kVAOoBABkACAg3G1kVAOoBAAEqAAUUCAg2ABwAMSMA.',['冻柠']='冻柠茶:BAABKgAFFH8IAAINAAgIRwiGDgCvAQANAAgIRwiGDgCvAQAAAA==.',['凯尔']='凯尔萨克斯:BAAAKgAFFAUIBAAAAA==.',['刀哥']='刀哥天下无敌:BAAAKgADCggIEAAAAA==.',['刁卡']='刁卡咩:BAAAKgADCggICAAAAA==.',['刃丶']='刃丶殇情:BAAAKgAECgcIDAAAAA==.',['初小']='初小帅:BAAAKgAECgUIBgAAAA==.',['利奥']='利奥大魔王:BAAAKgAECgQIBQAAAA==.',['医不']='医不了:BAAAKgAFFAgIBAAAAA==.',['十年']='十年乄如一:BAACKgAFFH8SAAITAAMIBR0gCwD3AAATAAMIBR0gCwD3AAAqAAQKf2gAAhMACAgsIKoHAHACABMACAgsIKoHAHACAAAA.',['千叶']='千叶美智子:BAAAKgADCgYIBgAAAA==.',['千早']='千早愛音:BAAAKgAECggIEQAAAA==.',['半糖']='半糖小天才:BAAAKgAECgYICAAAAA==.',['南枝']='南枝:BAABKgAFFH8GAAIdAAMITBcCBQDNAAAdAAMITBcCBQDNAAAAAA==.',['南風']='南風:BAABKgAFFH8LAAIdAAQITRlwBADdAAAdAAQITRlwBADdAAAAAA==.',['南风']='南风知我意:BAABKgAFFH8MAAIZAAgIRAvqAwCKAQAZAAgIRAvqAwCKAQAAAA==.',['叁陆']='叁陆壹零殺手:BAAAKgADCgIIAwAAAA==.',['又啫']='又啫喱又祸祸:BAAAKgADCgIIAgAAAA==.',['发霉']='发霉的馒头:BAAAKgAFFAQIBAAAAA==.',['口曷']='口曷三酉:BAABKgAECn8UAAMbAAgIsxepPAC1AQAbAAcIuRqpPAC1AQAdAAEIjAUgRwAMAAAAAA==.口曷灬氵酉:BAABKgAECn8VAAMNAAgIQgZbcADLAAANAAgIQgZbcADLAAAOAAII1AQVNwAyAAAAAA==.',['只有']='只有香如故:BAAAKgAECgMIBwAAAA==.',['叮当']='叮当飞吻:BAABKgAECn85AAIFAAgI2CM3AwC5AgAFAAgI2CM3AwC5AgAAAA==.',['叶丹']='叶丹:BAAAKgAECgYICwABKgAFFAgINgAcADEjAA==.',['叶雨']='叶雨风飘:BAABKgAFFH8HAAMNAAcIAAX4PQClAAANAAMIPwP4PQClAAAMAAQIwQbaKgBqAAAAAA==.',['司马']='司马夏侯:BAABKgAECn8kAAMaAAgIkAxPQAAPAQAaAAgIkAxPQAAPAQAbAAIInAIQ2AAYAAAAAA==.',['各种']='各种被单刷丶:BAABKgAECn9JAAIdAAgIjwuRGgDMAAAdAAgIjwuRGgDMAAAAAA==.',['合法']='合法马路杀手:BAAAKgAFFAgIAgAAAA==.',['向着']='向着朝阳奔跑:BAABKgAFFH8IAAIIAAgIhg3CCADfAQAIAAgIhg3CCADfAQAAAA==.',['吕师']='吕师傅:BAAAKgAFFAEIAgAAAA==.',['君倩']='君倩:BAAAKgADCgYIBgAAAA==.',['听丨']='听丨弦:BAABKgAFFH8GAAIIAAYIHRTpEwBWAQAIAAYIHRTpEwBWAQAAAA==.',['听香']='听香笑依:BAABKgAFFH8LAAISAAQIARx1HAABAQASAAQIARx1HAABAQAAAA==.',['呂師']='呂師傅:BAAAKgADCggICAAAAA==.',['呆若']='呆若牧一:BAAAKgAFFAcIAQAAAA==.',['周大']='周大福:BAABKgAECn8kAAMaAAYI7CFEHwDNAQAaAAYI7CFEHwDNAQAbAAEINgUm1AAhAAAAAA==.周大褔:BAAAKgAECgIIAgAAAA==.',['哈士']='哈士七饲养员:BAAAKgADCggICAAAAA==.',['哎呦']='哎呦小兽兽:BAAAKgAECgQIBAAAAA==.哎呦小师师:BAAAKgADCggICAAAAA==.哎呦小猫猫:BAAAKgAECgUICQAAAA==.哎呦小蛋蛋:BAAAKgAECggIDgAAAA==.',['哑巴']='哑巴湖大水怪:BAAAKgAECgYICgAAAA==.',['哭泣']='哭泣的迪妮莎:BAAAKgADCgEIAQAAAA==.',['唉我']='唉我无敌呢:BAAAKgAFFAIIAgAAAA==.',['啊臭']='啊臭臭:BAAAKgAECgIIAgAAAA==.',['啤酒']='啤酒:BAAAKgAFFAIIAgAAAA==.',['善良']='善良的牧丝:BAAAKgAECgQIBAAAAA==.',['喝汤']='喝汤吃牛肉:BAAAKgAFFAIIAgAAAA==.',['喵咪']='喵咪咪:BAAAKgADCgEIAQAAAA==.',['喵哩']='喵哩个咕:BAAAKgADCggICAAAAA==.',['噬血']='噬血天琊:BAAAKgADCggICAAAAA==.',['回忆']='回忆无限:BAAAKgAECggICAAAAA==.',['回旋']='回旋镖:BAAAKgAECgQIBwAAAA==.',['图腾']='图腾发射器:BAAAKgAECgQIBAAAAA==.',['圣光']='圣光没有圣光:BAAAKgAFFAEIAQAAAA==.',['地狱']='地狱吼丨甜瓜:BAAAKgAECgYIBgAAAA==.',['地獄']='地獄圣光:BAAAKgAECgEIAQAAAA==.',['坦是']='坦是壹种艺术:BAABKgAFFH8JAAIWAAYIqBV3DQAjAQAWAAYIqBV3DQAjAQAAAA==.',['堕落']='堕落天使沙加:BAAAKgADCggIEgAAAA==.',['塞优']='塞优娜啦:BAAAKgAECgUIBgAAAA==.',['塞缪']='塞缪尔的悲歌:BAAAKgAECggIAQAAAA==.',['墓有']='墓有亡法:BAAAKgADCgEIAQAAAA==.',['夜破']='夜破:BAAAKgADCgcIAgAAAA==.',['大地']='大地母亲:BAACKgAFFH8KAAIWAAgImQ5sCQBpAQAWAAgImQ5sCQBpAQAqAAQKfxcAAxIACAgKHvIzAFQCABIACAgKHvIzAFQCABYAAQiAA3BcABkAAAAA.',['大帝']='大帝的阿妮斯:BAAAKgAECgYICwAAAA==.',['大抗']='大抗:BAAAKgADCgQIBAAAAA==.',['大暖']='大暖龙:BAAAKgAECgIIAgAAAA==.',['大波']='大波浪的:BAAAKgAECgYICgAAAA==.',['大浪']='大浪逼:BAAAKgAECgMIBQAAAA==.',['大甜']='大甜瓜:BAABKgAECn8XAAIbAAgIQhaIOADGAQAbAAgIQhaIOADGAQAAAA==.',['大被']='大被窝:BAAAKgAFFAQIBAAAAA==.',['大锤']='大锤抡嫩妹:BAAAKgAFFAIIAgABKgAFFAMIEQARABYYAA==.',['大黑']='大黑翼:BAAAKgAECgYIBgAAAA==.',['天上']='天上天:BAAAKgAECgUIBQAAAA==.',['天下']='天下为公:BAAAKgADCgMIAwAAAA==.天下无贼:BAAAKgAECgMIAwAAAA==.',['天之']='天之圣骑:BAAAKgADCgIIAgAAAA==.',['天使']='天使的呼唤:BAAAKgADCgMIAwAAAA==.',['天地']='天地破裂舞:BAAAKgAECggICAAAAA==.',['天水']='天水无梦:BAABKgAFFH8WAAISAAQIqg4BVADIAAASAAQIqg4BVADIAAAAAA==.',['天要']='天要下雨:BAAAKgADCgcIBwAAAA==.',['天达']='天达尔卡门:BAAAKgAECgMIAwAAAA==.',['天阳']='天阳星巴度:BAABKgAECn8fAAIBAAgINwalMADOAAABAAgINwalMADOAAAAAA==.',['太寿']='太寿鸠毛:BAABKgAFFH8TAAMSAAYIIR7lKgA7AQASAAUINiPlKgA7AQATAAEImhZmDwBWAAAAAA==.',['太阳']='太阳离子:BAAAKgAECgYIBgAAAA==.',['奎尔']='奎尔扎拉姆:BAABKgAFFH8GAAIRAAYIKRjOCgCeAQARAAYIKRjOCgCeAQAAAA==.',['套牌']='套牌的阿江:BAAAKgADCgIIAgAAAA==.',['奥能']='奥能徽记:BAABKgAFFH8GAAMFAAQIUxleBgD9AAAFAAQIUxleBgD9AAAQAAII9CJqQgBJAAAAAA==.',['奶你']='奶你丶小叮叮:BAABKgAFFH8GAAISAAYIXgs9MAAnAQASAAYIXgs9MAAnAQAAAA==.',['奶是']='奶是壹种艺术:BAAAKgAFFAgIAwAAAA==.',['好漂']='好漂亮:BAAAKgAECgMIAwAAAA==.',['妞丶']='妞丶迷糊样:BAAAKgAECgcIEAAAAA==.',['威威']='威威一笑:BAAAKgADCggIDAAAAA==.',['威廉']='威廉姆斯牛:BAAAKgAECgYIBgAAAA==.',['孤雨']='孤雨寒烟:BAAAKgAECgMIAwAAAA==.',['宁静']='宁静者:BAAAKgADCgUIBQAAAA==.',['守望']='守望少年:BAAAKgAECgMIAwAAAA==.',['安安']='安安宝贝:BAAAKgADCggICAAAAA==.',['宝宝']='宝宝巴士:BAAAKgADCgEIAQAAAA==.宝宝贝:BAAAKgADCgEIAQAAAA==.',['寂无']='寂无喧:BAAAKgAECgEIAQAAAA==.',['寻踪']='寻踪虐影:BAAAKgAECgEIAQAAAA==.',['導演']='導演丶我死哪:BAABKgAFFH8SAAMFAAYIjCHvBACTAQAQAAYIYR+oCwCvAQAFAAYIuRnvBACTAQABKgAFFAgICAANAD4KAA==.',['小号']='小号二八七五:BAAAKgADCgYIBgAAAA==.',['小咣']='小咣头:BAABKgAFFH8GAAMXAAYItQ6OJwDYAAAXAAUIFAyOJwDYAAAUAAEIhANtJwA/AAAAAA==.',['小妞']='小妞给爷笑:BAAAKgADCgEIAQAAAA==.',['小害']='小害怕:BAACKgAFFH8IAAIRAAYIRh2sCwCRAQARAAYIRh2sCwCRAQAqAAQKfykAAhEACAiGIrMEAJECABEACAiGIrMEAJECAAAA.',['小巧']='小巧倩兮:BAAAKgAFFAYIBAAAAA==.',['小希']='小希瑞:BAABKgAFFH8QAAMSAAYIWSB1DADbAQASAAYIWSB1DADbAQATAAQIvBKoCwClAAAAAA==.',['小心']='小心你的后面:BAAAKgADCggICAAAAA==.',['小杀']='小杀神:BAAAKgAECggICAAAAA==.',['小柒']='小柒夜:BAAAKgAFFAQIBAAAAA==.',['小法']='小法熊:BAAAKgAFFAYIBAAAAA==.',['小犄']='小犄角大作为:BAAAKgAECggICAAAAA==.',['小猪']='小猪木哈哈:BAABKgAFFH8GAAITAAQInR5eBQD0AAATAAQInR5eBQD0AAABKgAFFAgIEAAYAFsKAA==.',['小糯']='小糯米:BAAAKgAECggICAAAAA==.',['小角']='小角的熊喵:BAABKgAFFH8KAAIbAAQIqxx8DwD9AAAbAAQIqxx8DwD9AAAAAA==.',['小马']='小马宝莉:BAAAKgAECgYICgAAAA==.',['小鱼']='小鱼的霸霸:BAAAKgAECggIBgAAAA==.',['尤利']='尤利:BAAAKgADCggICQAAAA==.',['尼克']='尼克杨:BAAAKgADCggICgAAAA==.',['尼飞']='尼飞比特:BAAAKgAECgYIBgAAAA==.',['尾巴']='尾巴好看吗:BAAAKgAECgUIEAAAAA==.',['巧克']='巧克力布朗尼:BAAAKgAFFAIIAgAAAA==.',['巴适']='巴适得板:BAAAKgAECgIIAgAAAA==.',['希尔']='希尔梅丽娜:BAABKgAFFH8GAAIFAAYIcBgWKQBJAAAFAAYIcBgWKQBJAAABKgAFFAYIBQAWAAEUAA==.希尔梅丽雅:BAACKgAFFH8FAAMWAAQIARSOHQCOAAAWAAQIXQ6OHQCOAAASAAEILSA5UgBEAAAqAAQKfxkAAxIACAirIoMcAKYCABIACAirIoMcAKYCABYAAQhOAhVjAAUAAAAA.',['希望']='希望剩哥:BAAAKgAFFAMIAwAAAA==.',['希里']='希里亚斯:BAAAKgAFFAQIBAAAAA==.',['帕格']='帕格:BAACKgAFFH8ZAAMDAAQIuB8OCwDcAAADAAQIuB8OCwDcAAACAAQI3hKNFwDDAAAqAAQKfxgAAwIACAhKG18SABUCAAIACAhKG18SABUCAAMAAQhBCrl7ADYAAAAA.',['帘后']='帘后的月光:BAAAKgAECgQIBAAAAA==.',['帝之']='帝之萨:BAAAKgAECgMIAwAAAA==.',['帝释']='帝释回天:BAAAKgAECgcICAAAAA==.',['带头']='带头大哥:BAAAKgAECgQIBAAAAA==.带头抡锤丶:BAAAKgAECgIIAgAAAA==.带头邪恶丶:BAAAKgADCgUIBQAAAA==.',['带灵']='带灵魂漫步:BAABKgAFFH8GAAIQAAYIYBs/EgBVAQAQAAYIYBs/EgBVAQABKgAFFAgIGAAQAIQeAA==.',['带着']='带着心流浪:BAAAKgAECggIDQAAAA==.',['帯灵']='帯灵魂漫步:BAAAKgAECgEIAQAAAA==.',['幸以']='幸以:BAAAKgAECggIAwAAAA==.',['幻影']='幻影棒棒糖:BAAAKgAECgYICgAAAA==.',['幽魂']='幽魂行者:BAAAKgAECggICAAAAA==.',['弦羽']='弦羽:BAAAKgADCgYICAAAAA==.',['当公']='当公主好难:BAAAKgAFFAQIBAAAAA==.',['彼岸']='彼岸丶蘩婲:BAAAKgAECgEIAQAAAA==.',['往复']='往复:BAAAKgADCgUIBQAAAA==.',['御宅']='御宅喵帕斯:BAAAKgAECgcICQAAAA==.',['德了']='德了罢:BAAAKgAECgUIBQAAAA==.',['德尔']='德尔加德:BAABKgAFFH8FAAIbAAMIehA8OQC+AAAbAAMIehA8OQC+AAAAAA==.',['心如']='心如死水:BAABKgAFFH8JAAMOAAQI3g7ADQCMAAAOAAMIegTADQCMAAAMAAQI3g41LQBeAAABKgAFFAgIBgAPAOgaAA==.',['心灵']='心灵死神:BAAAKgADCgIIAgAAAA==.心灵猎手:BAAAKgADCgIIAgAAAA==.心灵猎魔者:BAAAKgADCgQIBAAAAA==.',['忄牛']='忄牛大:BAACKgAFFH8PAAISAAQIZSGBIADoAAASAAQIZSGBIADoAAAqAAQKfykAAhIACAhbHwhPAAUCABIACAhbHwhPAAUCAAAA.',['怜沥']='怜沥丨丶牛牛:BAAAKgADCgYIBgAAAA==.',['性田']='性田来慰:BAAAKgADCgQIBAAAAA==.',['恢复']='恢复牛牛:BAABKgAFFH8TAAIXAAMI2iCAGgAVAQAXAAMI2iCAGgAVAQAAAA==.',['恺撒']='恺撒:BAACKgAFFH8IAAISAAgIuwtsEADcAQASAAgIuwtsEADcAQAqAAQKfxgAAhIACAinIksoAF8CABIACAinIksoAF8CAAAA.',['惜淼']='惜淼:BAABKgAFFH8MAAISAAYI9iFoEgDJAQASAAYI9iFoEgDJAQABKgAFFAgIBAAeAAAAAA==.',['愤怒']='愤怒的哈密瓜:BAAAKgAFFAMIAwAAAA==.愤怒的曲奇:BAACKgAFFH8GAAIdAAMIqhC9BACVAAAdAAMIqhC9BACVAAAqAAQKfxwAAx0ACAjYG6IJABcCAB0ACAjYG6IJABcCABsAAghgE2NQAEYAAAAA.愤怒的猕猴桃:BAABKgAFFH8JAAIfAAMI/QUwCwB2AAAfAAMI/QUwCwB2AAAAAA==.愤怒的豆腐:BAABKgAFFH8GAAIFAAMIEA4TDADDAAAFAAMIEA4TDADDAAAAAA==.愤怒的香蕉:BAACKgAFFH8GAAIIAAMIfxbEFQDgAAAIAAMIfxbEFQDgAAAqAAQKfxwAAwgACAgkHF0jAF4BAAgABghFIV0jAF4BAAkABQjMDyluAKsAAAAA.',['我就']='我就是螃蟹:BAABKgAFFH8GAAIBAAYIOg+5FQBMAQABAAYIOg+5FQBMAQAAAA==.',['我是']='我是个墓师:BAABKgAECn8iAAINAAcItBxXPgC4AQANAAcItBxXPgC4AQAAAA==.我是个站尸:BAAAKgAFFAIIAgAAAA==.我是圣骑大王:BAAAKgADCggICAAAAA==.我是大牛哥:BAAAKgAECggICAAAAA==.我是奶豆贼:BAAAKgAECgQIBAAAAA==.我是幻影圣狙:BAAAKgAECgYIBgABKgAECgYICgAeAAAAAA==.',['我真']='我真不等了:BAABKgAFFH8GAAIMAAYI1QvWFQDyAAAMAAYI1QvWFQDyAAAAAA==.',['我还']='我还小别打我:BAAAKgAECgEIAQAAAA==.',['战忽']='战忽局局座:BAAAKgADCggICAAAAA==.',['技高']='技高一筹:BAAAKgADCggIEAAAAA==.',['拂晓']='拂晓硬汉:BAAAKgAECgQIBAAAAA==.拂晓莫机车:BAAAKgAECgQIBAAAAA==.',['拉斯']='拉斯塔哈大王:BAABKgAECn8jAAMRAAgIJx+1GgA5AgARAAgICB61GgA5AgAgAAgIrhnEIgBwAQAAAA==.',['捷科']='捷科弗里德:BAAAKgAECgIIAgAAAA==.',['排骨']='排骨大侠:BAAAKgAECgcIBwAAAA==.',['携寵']='携寵诱佳人:BAAAKgAECggIDgAAAA==.',['放火']='放火烧山:BAAAKgAECgMIAwAAAA==.',['散板']='散板:BAACKgAFFH8NAAIIAAMIRBuBJgDsAAAIAAMIRBuBJgDsAAAqAAQKfx0AAwgACAh2HNcvAOsBAAgACAh2HNcvAOsBAAkAAgh2BKuWAB0AAAAA.',['斗萝']='斗萝:BAABKgAECn8bAAMaAAgIGSF8CwBeAgAaAAgIGSF8CwBeAgAbAAEIAACC4QAAAAAAAA==.',['新疆']='新疆窜天猴:BAABKgAFFH8GAAMIAAQInBcWOwCvAAAIAAQI0A8WOwCvAAAJAAIIfByaNQCdAAAAAA==.',['无刃']='无刃刀:BAABKgAFFH8TAAIfAAgIVA5uAwCCAQAfAAgIVA5uAwCCAQAAAA==.',['无名']='无名斗士:BAAAKgAECgQIBAAAAA==.无名死亡骑:BAAAKgAECgMIAwAAAA==.无名法神:BAAAKgAECgEIAQAAAA==.',['无尽']='无尽屠戮:BAAAKgAFFAQIBAAAAA==.',['无心']='无心制裁:BAAAKgAECgQIBQAAAA==.',['无敌']='无敌的炉石:BAAAKgAECggIEgAAAA==.',['无浪']='无浪不起风:BAAAKgADCgEIAgAAAA==.',['明人']='明人不说暗话:BAAAKgAECgcIBwAAAA==.',['星河']='星河长明:BAAAKgAECgEIAQAAAA==.',['星破']='星破:BAAAKgADCggIEAAAAA==.',['晓敌']='晓敌:BAAAKgADCgEIAQAAAA==.',['普羅']='普羅米修斯:BAAAKgAFFAQIBAAAAA==.',['暗淡']='暗淡的街灯:BAAAKgAECgYIBgAAAA==.',['暴躁']='暴躁的煤气罐:BAAAKgAFFAQIBAAAAA==.',['曼达']='曼达洛星坠:BAAAKgAECgMIBAAAAA==.',['最爱']='最爱书宝呗:BAABKgAFFH8VAAICAAUIpBYfFABkAQACAAUIpBYfFABkAQAAAA==.最爱书宝贝:BAAAKgAECgEIAQAAAA==.',['月映']='月映狂魔:BAAAKgAECggIEwAAAA==.',['有酒']='有酒等故事:BAAAKgADCgYICQAAAA==.',['木馨']='木馨:BAAAKgADCgQIBwAAAA==.',['术丨']='术丨术:BAAAKgAECgEIAQAAAA==.',['术有']='术有专攻:BAAAKgAECgUICAAAAA==.',['杀气']='杀气腾腾:BAAAKgADCgEIAQAAAA==.',['杖尾']='杖尾鳞甲龙:BAAAKgAFFAQIBAAAAA==.',['来真']='来真德:BAABKgAFFH8WAAMbAAYIDB9WCwAUAQAbAAQI8SNWCwAUAQAaAAII0g6gJACTAAABKgAFFAgIDAAbAHMZAA==.',['杭州']='杭州萧炎:BAABKgAFFH8GAAISAAYIghAAJgBRAQASAAYIghAAJgBRAQAAAA==.',['极夜']='极夜暗语:BAABKgAFFH8FAAIaAAMI4BN+HQC5AAAaAAMI4BN+HQC5AAAAAA==.',['林姐']='林姐姐:BAABKgAFFH8IAAIMAAgISAMhEQAbAQAMAAgISAMhEQAbAQAAAA==.',['枫叶']='枫叶微黄:BAABKgAFFH8YAAIcAAQIBx4yFgDyAAAcAAQIBx4yFgDyAAAAAA==.',['柏云']='柏云:BAABKgAECn8VAAMWAAgIwwfdPgCTAAAWAAcIngjdPgCTAAASAAgIMgIvMgF7AAAAAA==.',['柯妮']='柯妮丽娅:BAACKgAFFH9HAAMTAAgIlCE7AAACAgATAAYIqCE7AAACAgASAAQIaxhJGgAUAQAqAAQKfxkAAhMACAjYIiMIAGgCABMACAjYIiMIAGgCAAAA.',['栊基']='栊基努斯:BAAAKgADCgMIAwAAAA==.',['桃子']='桃子来了:BAABKgAFFH8GAAIDAAMI9QjaCgCmAAADAAMI9QjaCgCmAAAAAA==.',['桃爷']='桃爷:BAAAKgADCggICAAAAA==.',['梦中']='梦中的梦中:BAAAKgADCggICAAAAA==.',['梦惜']='梦惜缘:BAAAKgAECgQIBAAAAA==.',['梦想']='梦想青云:BAAAKgAECgMIBwAAAA==.',['梦飛']='梦飛雪:BAABKgAFFH8WAAMHAAQIkRmSHwDKAAAHAAQIkRmSHwDKAAAGAAIIFwYQLgBdAAAAAA==.',['梦魇']='梦魇:BAAAKgAECgIIAgAAAA==.',['梨涡']='梨涡远点:BAAAKgAECgUIBgAAAA==.',['森之']='森之黑山羊:BAAAKgAFFAIIAgAAAA==.',['樱姬']='樱姬丨嫣然:BAAAKgAECgQIBQAAAA==.',['樱落']='樱落灬天堂:BAABKgAFFH8PAAMWAAQIORnaCgC4AAAWAAQIKBnaCgC4AAASAAMIoRJnNAChAAAAAA==.',['橘小']='橘小美:BAAAKgAECgUIBgAAAA==.橘小美分美:BAAAKgAECgMIBAAAAA==.',['歆圣']='歆圣骑:BAABKgAFFH8IAAIWAAgILwnVBgBrAQAWAAgILwnVBgBrAQAAAA==.',['死可']='死可惜了:BAAAKgAFFAMIBAAAAA==.',['死宅']='死宅也疯狂:BAAAKgAECgMIAQAAAA==.',['残影']='残影刀:BAAAKgAECgQIBAAAAA==.',['毁梦']='毁梦:BAABKgAFFH8VAAQFAAQIGiMrBwAXAQAPAAQIDiE5EwAjAQAFAAQIUyArBwAXAQAQAAIICSEmKwC3AAAAAA==.',['毛乐']='毛乐:BAACKgAFFH8nAAMaAAYIHB6aCwBMAQAaAAQIpSaaCwBMAQAbAAYImQoGBgBGAQAqAAQKfygAAxoACAj/JMEIAJQCABoACAj/JMEIAJQCABsAAQhlCsRXAC4AAAAA.',['永恒']='永恒审判:BAAAKgAFFAQIAwAAAA==.',['沉沦']='沉沦与遐想:BAAAKgADCggICQAAAA==.',['沉睡']='沉睡的美杜莎:BAABKgAFFH8MAAQFAAQI9BV1FADFAAAFAAQIohR1FADFAAAPAAEIMiDpLABUAAAQAAEIcgWpSAAvAAAAAA==.',['沙迦']='沙迦:BAAAKgADCgUIBQAAAA==.',['没事']='没事哒没事哒:BAAAKgAECggICAAAAA==.',['没用']='没用的阿吉:BAAAKgADCgMIAwAAAA==.',['没虱']='没虱子的牛:BAAAKgAECgYIBwAAAA==.',['沭灬']='沭灬噬:BAAAKgAECgIIAgAAAA==.',['河城']='河城荷取:BAABKgAFFH8MAAIXAAgIdA57CAC/AQAXAAgIdA57CAC/AQAAAA==.',['油炸']='油炸土克勒:BAABKgAECn8eAAMgAAcIYwo2MgAGAQARAAYIhgheVAALAQAgAAcIRQo2MgAGAQAAAA==.',['法力']='法力值不足:BAACKgAFFH8HAAIGAAMINxb3GQDCAAAGAAMINxb3GQDCAAAqAAQKfycAAwYACAiDGkMeANUBAAYACAiDGkMeANUBAAcABggeDpNZANUAAAAA.',['流浪']='流浪的烟嘴儿:BAABKgAECn8ZAAQXAAgIYB2aFwA6AgAXAAgIYB2aFwA6AgAUAAYIiB7wIgC2AQAVAAEIhxf3QwBGAAAAAA==.流浪的烟壳儿:BAABKgAECn8bAAQhAAgIYB6oBgC+AQAIAAcIdxwBNwDJAQAhAAYI1h6oBgC+AQAJAAEIow9xSQA2AAAAAA==.流浪的烟头儿:BAAAKgAECgQIBwAAAA==.流浪的烟灰:BAABKgAECn8gAAQiAAgIxhQoIQCVAQAiAAcIABcoIQCVAQAcAAgIlBMxLwAjAQAjAAQIDAilIgA1AAAAAA==.流浪的烟灰缸:BAAAKgAECgEIAQAAAA==.流浪的烟痞:BAAAKgAECgQICQAAAA==.流浪的烟盒儿:BAAAKgAECgcIEAAAAA==.流浪的烟花儿:BAABKgAECn8fAAMRAAgIZB5DDwBnAgARAAgIZB5DDwBnAgAfAAQICQzoOgB0AAAAAA==.',['浅唱']='浅唱的天空:BAABKgAFFH8GAAIJAAYI+h1uBAAyAgAJAAYI+h1uBAAyAgAAAA==.',['浮生']='浮生肥巧:BAAAKgAFFAQIBAAAAA==.浮生若晨:BAAAKgAFFAYIBAAAAA==.',['海德']='海德拉:BAABKgAFFH8GAAICAAYI4xHXGgCyAAACAAYI4xHXGgCyAAAAAA==.',['海洋']='海洋的堕落:BAABKgAFFH8SAAMbAAgIpiFsBQBqAgAbAAcIhyNsBQBqAgAaAAII3g3uMgBMAAAAAA==.',['清丶']='清丶夏:BAAAKgAECgQIAQAAAA==.',['清波']='清波弄影:BAAAKgADCggICAAAAA==.',['清盏']='清盏涂墨衣:BAABKgAFFH8GAAQOAAMIxxjxBwDrAAAOAAMIxxjxBwDrAAANAAIIXQ4oRwCEAAAMAAEIWRCpMwAxAAAAAA==.',['源丨']='源丨纆:BAAAKgAECgYICQAAAA==.',['源丶']='源丶纆:BAAAKgAECggIDgAAAA==.',['溜溜']='溜溜哥不得溜:BAAAKgAECgIIAgAAAA==.溜溜球贼溜:BAABKgAFFH8IAAIQAAgIZQcaCwCqAQAQAAgIZQcaCwCqAQAAAA==.',['漫漫']='漫漫:BAAAKgAFFAEIAQAAAA==.',['濠柒']='濠柒灬灵魂:BAAAKgAECgMIBQAAAA==.',['灬凤']='灬凤凰涅槃灬:BAAAKgADCgIIAgAAAA==.',['灬灬']='灬灬飛灬灬:BAAAKgAECgYIDgAAAA==.',['灬玄']='灬玄玉:BAACKgAFFH8IAAIFAAMIwQn8HACcAAAFAAMIwQn8HACcAAAqAAQKfx4AAgUACAhzFR0xAK8BAAUACAhzFR0xAK8BAAAA.',['炖鸡']='炖鸡喔:BAAAKgAFFAYIBAAAAA==.',['熊猫']='熊猫子球儿:BAABKgAFFH8GAAMGAAYI+hp0DQA/AQAGAAUIyxh0DQA/AQAYAAEI2RiLKQBLAAAAAA==.',['熊管']='熊管家:BAAAKgAECgIIAgAAAA==.',['爱吃']='爱吃汉堡王:BAAAKgAFFAEIAQAAAA==.爱吃肯德基:BAACKgAFFH8UAAIIAAQIWyQzGwAnAQAIAAQIWyQzGwAnAQAqAAQKfxgAAggACAhvJcwDAAkDAAgACAhvJcwDAAkDAAAA.爱吃麦当劳:BAAAKgAFFAEIAQAAAA==.',['爱小']='爱小熊:BAABKgAECn8VAAIUAAgIGh77IADnAQAUAAgIGh77IADnAQAAAA==.',['爱是']='爱是一道光:BAAAKgAECgEIAQAAAA==.',['牛奶']='牛奶会有的:BAABKgAFFH8SAAIXAAYIRhvbCwCKAQAXAAYIRhvbCwCKAQABKgAFFAgIDwAGAIQcAA==.',['牛有']='牛有德:BAAAKgAECggIDgAAAA==.',['牢底']='牢底坐穿:BAAAKgAECgYICgAAAA==.',['牧小']='牧小雅:BAACKgAFFH8dAAMGAAQI1xbJCgDHAAAGAAQItxbJCgDHAAAHAAEIVB+nHABUAAAqAAQKfyEAAwYACAi5FyMqAIgBAAYACAj7ESMqAIgBAAcACAjdEYYZAA0BAAAA.',['特别']='特别一小德:BAAAKgAECgIIAgAAAA==.',['狂狼']='狂狼骑士:BAAAKgAECgcIBwAAAA==.',['狐妖']='狐妖小红娘:BAAAKgAECgIIAgAAAA==.',['狐狸']='狐狸糊涂:BAABKgAFFH8IAAIXAAgIFhJQBgDqAQAXAAgIFhJQBgDqAQAAAA==.',['猎祖']='猎祖猎宗:BAAAKgAECgYIBgAAAA==.',['猫妖']='猫妖在猫腰:BAAAKgADCggICgAAAA==.',['玲娜']='玲娜贝儿丶:BAABKgAFFH8QAAIXAAgIxBCSBgDjAQAXAAgIxBCSBgDjAQAAAA==.',['玲玲']='玲玲:BAAAKgADCgcIBwAAAA==.',['琪琪']='琪琪与牛牛:BAABKgAECn8cAAISAAgI1CB9NgBMAgASAAgI1CB9NgBMAgAAAA==.',['瓦合']='瓦合:BAABKgAFFH8IAAMdAAMIbAdoBgBqAAAdAAMIbAdoBgBqAAAaAAII/AWGMQBSAAAAAA==.',['瓦尼']='瓦尼菈:BAAAKgAECgEIAQAAAA==.',['生抽']='生抽:BAAAKgAFFAYIAgAAAA==.',['生死']='生死難左右:BAAAKgAECgcIBwAAAA==.',['用脸']='用脸去嘲讽:BAABKgAFFH8GAAIfAAMI/ACvFQBJAAAfAAMI/ACvFQBJAAAAAA==.',['疯狂']='疯狂摇滚:BAAAKgAFFAMIAwAAAA==.疯狂面具:BAABKgAFFH8FAAIIAAUIXQmTJwDnAAAIAAUIXQmTJwDnAAAAAA==.',['疯癫']='疯癫的小籹人:BAAAKgAFFAEIAQAAAA==.',['癫癫']='癫癫疯疯:BAAAKgADCgYIBgAAAA==.',['白袍']='白袍干豆腐:BAAAKgADCgEIAgAAAA==.',['百理']='百理屠苏:BAAAKgADCgEIAQAAAA==.',['真水']='真水幽香:BAACKgAFFH8PAAMFAAMIvRr1DgDrAAAFAAMIvRr1DgDrAAAQAAIIiQkQQQBSAAAqAAQKf24ABAUACAi7ICMMAHsCAAUACAi7ICMMAHsCABAACAj7FzUkANYBAA8ABQjjB5Z0AKYAAAAA.',['真理']='真理在射程内:BAABKgAECn8cAAMIAAcIqCNcIQA3AgAIAAcIqCNcIQA3AgAJAAMIIhMocQByAAAAAA==.',['眼花']='眼花缭乱:BAAAKgAFFAgIBAAAAA==.',['祸祸']='祸祸牛:BAAAKgAECgEIAQAAAA==.',['秋得']='秋得墨:BAAAKgAFFAMIAwAAAA==.',['科雷']='科雷负能量:BAAAKgAFFAQIBAAAAA==.',['穿心']='穿心丶:BAAAKgAECggICAAAAA==.',['窝老']='窝老攻:BAAAKgAECgMIAwAAAA==.',['立志']='立志锤:BAAAKgAECgYIBgAAAA==.',['筱个']='筱个子:BAAAKgAECgUIBQAAAA==.',['筱琥']='筱琥牙:BAAAKgADCgMIAwAAAA==.',['粗鄙']='粗鄙的武夫:BAAAKgADCgMIAwAAAA==.',['糊涂']='糊涂德:BAAAKgAECgUIBQAAAA==.',['糖乐']='糖乐乐:BAABKgAFFH8KAAIKAAgI6hB2DwBaAQAKAAgI6hB2DwBaAQAAAA==.',['素质']='素质低下德:BAAAKgAFFAQIBAAAAA==.',['緈諨']='緈諨映苍穹:BAAAKgAECggICQAAAA==.',['红云']='红云老祖:BAABKgAFFH8GAAIXAAIIoAscKwByAAAXAAIIoAscKwByAAAAAA==.',['织雾']='织雾潘达:BAABKgAECn8WAAIcAAgIsh36EwBIAgAcAAgIsh36EwBIAgABKgAFFAMIEwAXANogAA==.',['罐儿']='罐儿:BAAAKgAFFAMIAwAAAA==.',['罐头']='罐头瓶:BAAAKgAECgQIBAAAAA==.',['罒鳕']='罒鳕熊罒:BAACKgAFFH8KAAMXAAYIyBw9CwCTAQAXAAYIyBw9CwCTAQAUAAEInRTnJgBBAAAqAAQKf2YAAhcACAhRJTwGAMQCABcACAhRJTwGAMQCAAAA.',['羿影']='羿影逐魔:BAABKgAECn8WAAMIAAgILhniNQDOAQAIAAgIjxjiNQDOAQAJAAUIJhDZhABxAAAAAA==.',['翼馥']='翼馥:BAAAKgAFFAEIAQAAAA==.',['老衲']='老衲要出家:BAAAKgAECgYIBgAAAA==.',['耳冉']='耳冉:BAABKgAFFH8TAAQHAAgIvSCFBQDeAQAGAAcIUB2MBAABAgAHAAYImCKFBQDeAQAYAAYILBlGCgBcAQAAAA==.',['肥皂']='肥皂哥丶:BAAAKgAECgMIAwAAAA==.',['脆皮']='脆皮松子:BAABKgAECn8UAAIbAAgIORCifQDlAAAbAAgIORCifQDlAAAAAA==.',['自有']='自有后来人:BAAAKgAECgYIBgAAAA==.',['自然']='自然的伙伴:BAABKgAFFH8QAAMbAAYI8yDnDADIAQAbAAYI8yDnDADIAQAaAAYI8BVjBwCaAQAAAA==.',['自由']='自由和諧:BAAAKgAECgUICAAAAA==.',['臭鳜']='臭鳜鱼:BAABKgAECn8VAAISAAgI+xJmawCBAQASAAgI+xJmawCBAQAAAA==.',['舞笛']='舞笛小土人:BAAAKgAECgYIBgAAAA==.舞笛揉露噬:BAAAKgAFFAYIBAABKgAFFAgIGAANAKUbAA==.',['芒灬']='芒灬果:BAACKgAFFH8IAAISAAgIuwvvDADUAQASAAgIuwvvDADUAQAqAAQKfxcAAiQACAg5AAAAAAAAABIACAg5AAAAAAAAAAAA.',['芣洁']='芣洁灬靈魂:BAAAKgAECgcIDgAAAA==.',['花衬']='花衬衫:BAAAKgAFFAMIAwABKgAFFAMIEQARABYYAA==.',['苗木']='苗木:BAAAKgADCggICgAAAA==.',['若灬']='若灬梦:BAAAKgAECgEIAQAAAA==.',['若萌']='若萌初醒:BAABKgAECn8aAAIFAAcImAaVTQC1AAAFAAcImAaVTQC1AAAAAA==.',['英皇']='英皇丶美屡:BAABKgAFFH8HAAMJAAQICBTyEADUAAAJAAQICBTyEADUAAAIAAEIYw0gLwA/AAAAAA==.',['范老']='范老師:BAAAKgAECgMIAwAAAA==.',['范迪']='范迪塞迩:BAABKgAFFH8MAAMIAAgIWxbWDgATAQAIAAQI6hzWDgATAQAJAAQIbxFfFwCnAAAAAA==.',['草莓']='草莓酱:BAAAKgAFFAQIBAABKgAFFAgIGgANAEwhAA==.',['荖瑖']='荖瑖:BAAAKgAECgUIBQAAAA==.',['药王']='药王孙思邈:BAABKgAFFH8MAAIXAAgIPhWgBQD6AQAXAAgIPhWgBQD6AQAAAA==.',['莯灬']='莯灬缌:BAAAKgAECgIIAgAAAA==.',['菊小']='菊小浅:BAAAKgADCgEIAQAAAA==.',['菜刀']='菜刀大叔:BAABKgAECn8nAAMJAAgITRrMIgDtAQAJAAgITRrMIgDtAQAIAAEIAABEHAEAAAAAAA==.',['萌萌']='萌萌的海棉体:BAAAKgAECgMIAwAAAA==.',['萨穆']='萨穆罗丨甜瓜:BAAAKgAECgcICQAAAA==.',['萨罗']='萨罗尼奥:BAAAKgAECgYIDAAAAA==.',['落幕']='落幕之舞:BAACKgAFFH8lAAIMAAUIdgTzIgCQAAAMAAUIdgTzIgCQAAAqAAQKfxwAAgwACAiTB8Q5AJoAAAwACAiTB8Q5AJoAAAAA.',['蒙圈']='蒙圈的哈士七:BAAAKgAECgEIAQAAAA==.',['蓉城']='蓉城大熊猫:BAACKgAFFH8HAAIjAAQImwkbBwCVAAAjAAQImwkbBwCVAAAqAAQKfxQAAyMACAi4EsoNAFgBACMACAi4EsoNAFgBABwAAQgQBhqUACkAAAEqAAUUCAgIABIAdBYA.',['蓝怒']='蓝怒:BAAAKgAECgMIAwAAAA==.',['蕾米']='蕾米莉亚:BAAAKgAFFAYIAgABKgAFFAgIAgAeAAAAAA==.',['蜉蝣']='蜉蝣:BAABKgAFFH8FAAMIAAMI/wRaSQBEAAAJAAII7QEMTgBGAAAIAAIIzAZaSQBEAAAAAA==.',['蜥蜴']='蜥蜴成精:BAABKgAFFH8HAAIlAAcIwRBNCgDMAQAlAAcIwRBNCgDMAQAAAA==.',['血魔']='血魔少帅:BAAAKgAECgYICwAAAA==.',['行无']='行无疆:BAABKgAFFH8FAAIXAAMI8As6NgClAAAXAAMI8As6NgClAAAAAA==.',['術小']='術小陌:BAAAKgAECgUIBgAAAA==.',['西何']='西何庄吴彦祖:BAAAKgAFFAMIAwAAAA==.',['西敏']='西敏寺的夜:BAAAKgAECgYIBgAAAA==.',['观世']='观世正宗:BAAAKgAFFAYIBAAAAA==.',['譞雨']='譞雨:BAACKgAFFH8RAAIBAAgIeB/qAgC6AgABAAgIeB/qAgC6AgAqAAQKfyIAAgEACAiyFscVAK8BAAEACAiyFscVAK8BAAAA.',['训兽']='训兽师:BAAAKgAECgMIAwAAAA==.',['诸法']='诸法:BAEBKgAFFH8LAAMGAAQIFhJeDwDeAAAGAAQIFhJeDwDeAAAYAAQIgRrVGAC2AAABKgAFFAgIFAACACMiAA==.',['诸神']='诸神之月:BAAAKgAFFAEIAQAAAA==.',['谁来']='谁来救我:BAABKgAFFH8JAAIYAAMI+AvnEQCiAAAYAAMI+AvnEQCiAAAAAA==.',['谢必']='谢必安丶:BAAAKgAECggICAAAAA==.',['赏钻']='赏钻熊猫猎:BAAAKgADCggIEAAAAA==.',['赞达']='赞达拉女王:BAAAKgAECggIDAAAAA==.',['赫墨']='赫墨拉:BAAAKgAECgYIDQAAAA==.',['赶紧']='赶紧的速度灭:BAAAKgADCggICAAAAA==.',['超哥']='超哥的永定河:BAAAKgADCggICAAAAA==.',['蹩脚']='蹩脚的小男孩:BAABKgAFFH8KAAINAAMIsBQqMADQAAANAAMIsBQqMADQAAAAAA==.',['达蕾']='达蕾妮亚:BAAAKgAFFAEIAQAAAA==.',['远哥']='远哥你好:BAAAKgADCgYIBgAAAA==.',['连名']='连名带姓:BAAAKgAECgMIAwAAAA==.',['迪奥']='迪奥普罗墨斯:BAABKgAFFH8OAAIXAAgIFhGvBgDhAQAXAAgIFhGvBgDhAQAAAA==.',['迪许']='迪许蒙格:BAAAKgAECgQIBgAAAA==.',['送礼']='送礼的阿江:BAAAKgADCggICAAAAA==.',['郭师']='郭师傅:BAAAKgADCgYIBgAAAA==.',['酋长']='酋长凯恩血蹄:BAAAKgAECgUIBQAAAA==.',['酱爆']='酱爆:BAAAKgAECgYIBgAAAA==.',['野牛']='野牛小德德:BAAAKgAECgQIBgAAAA==.',['鈺博']='鈺博:BAAAKgAFFAQIBAAAAA==.',['钢铁']='钢铁苍穹:BAAAKgAFFAgIAgAAAA==.',['钰藻']='钰藻前:BAAAKgADCgQIBAAAAA==.',['铭语']='铭语:BAAAKgAFFAQIBAAAAA==.',['银歌']='银歌:BAAAKgAECgEIAQAAAA==.',['银蛉']='银蛉儿:BAABKgAFFH8EAAIcAAQIXwpeEgCNAAAcAAQIXwpeEgCNAAAAAA==.',['银鞍']='银鞍白马:BAAAKgAFFAQIBAAAAA==.',['阿伊']='阿伊古:BAAAKgAFFAYIBAAAAA==.',['阿尔']='阿尔卑斯暴风:BAABKgAFFH8SAAMNAAYIgh8fCwDcAQANAAYIgh8fCwDcAQAMAAQIoQQyLQBeAAAAAA==.',['阿爾']='阿爾蕯斯:BAACKgAFFH8UAAMNAAgIKhnYAgC2AQANAAgIKhnYAgC2AQAMAAEISAKcNAApAAAqAAQKfxQAAg0ACAgRH9ciADMCAA0ACAgRH9ciADMCAAAA.',['陌丄']='陌丄花开丶:BAACKgAFFH8sAAIjAAQIvAbvBgB2AAAjAAQIvAbvBgB2AAAqAAQKfzMAAyMACAh/DBkTAA4BACMACAjQChkTAA4BACIAAgheDMZjAHMAAAEqAAUUCAgmACAAeBwA.',['陌寒']='陌寒烟:BAACKgAFFH8iAAQGAAcI7RGjCwBbAQAGAAcIwBGjCwBbAQAYAAUIPAwdEgDwAAAHAAII9gsnIAA3AAAqAAQKfxgABAYACAitGUonAJkBAAYABQh1G0onAJkBAAcABggmFDpMAAcBABgABQi/DxNXAI8AAAAA.',['降尘']='降尘:BAAAKgADCgMIAwAAAA==.',['限量']='限量的阿江:BAAAKgADCgIIAgAAAA==.',['随了']='随了蝴蝶:BAAAKgAFFAIIBAAAAA==.',['隐藏']='隐藏萌狐:BAAAKgADCggICAAAAA==.',['隔壁']='隔壁王大爷:BAAAKgAECgcIAgAAAA==.',['雅克']='雅克洪尼斯特:BAACKgAFFH8aAAMSAAQI1RK3VQDFAAASAAMI1RK3VQDFAAAWAAQI0AOPJQBfAAAqAAQKfx0ABBIACAh9HX9gANsBABIACAh9HX9gANsBABYABAg4DtkZAIIAABMAAQi2A0hZAB0AAAAA.',['雅静']='雅静:BAAAKgAECggIDwAAAA==.',['雨天']='雨天丶已婷:BAAAKgAFFAEIAQAAAA==.',['雨帆']='雨帆儿:BAAAKgAECgEIAQAAAA==.',['雪山']='雪山榴莲:BAAAKgAECggICAAAAA==.',['雪涩']='雪涩烈钕:BAAAKgADCggICgAAAA==.',['雷神']='雷神落雁:BAAAKgADCgQIBAAAAA==.',['雷霆']='雷霆小刀:BAAAKgADCgQIBAAAAA==.',['震天']='震天战鼓:BAAAKgADCgcIBwAAAA==.',['霜之']='霜之哀痕:BAABKgAFFH8GAAICAAMIkgr8GAC9AAACAAMIkgr8GAC9AAAAAA==.',['霸气']='霸气侧露:BAABKgAFFH8GAAMCAAYIMBXTIAABAQACAAQINhXTIAABAQADAAIIGxUuLABCAAAAAA==.霸气小翅膀:BAAAKgAECggICAAAAA==.',['静侯']='静侯那年:BAAAKgAECgEIAQAAAA==.',['静雅']='静雅:BAABKgAECn8VAAQSAAgIMB07UwDDAQASAAYIFyE7UwDDAQATAAIIWR44OgCyAAAWAAQI/RB+PACUAAAAAA==.',['非洲']='非洲大洋芋:BAAAKgAECgEIAQAAAA==.',['风吹']='风吹雪:BAACKgAFFH80AAIBAAcIchiDDgCbAQABAAcIchiDDgCbAQAqAAQKfyMAAwEACAigIVMRAHkCAAEACAigIVMRAHkCABkABAg0D0RAAL8AAAAA.',['风灵']='风灵追火:BAAAKgAECgcIEQAAAA==.',['风神']='风神的神德:BAACKgAFFH8SAAMUAAQIjA6dFgC/AAAUAAQIjA6dFgC/AAAXAAMIZQ8RNACrAAAqAAQKfy4AAxQACAhHGow0AGsBABQABgiZF4w0AGsBABcACAguEblQAE0BAAAA.',['风筝']='风筝王子:BAABKgAFFH8IAAIIAAUIWAo+HwCmAAAIAAUIWAo+HwCmAAAAAA==.',['风语']='风语尘埃落丶:BAABKgAFFH80AAIBAAgIHhdPBwArAgABAAgIHhdPBwArAgAAAA==.',['风铠']='风铠:BAAAKgAFFAMIAwAAAA==.',['飒飒']='飒飒伊香:BAABKgAECn8YAAIBAAgI/haoJQDdAQABAAgI/haoJQDdAQAAAA==.飒飒冷风:BAAAKgAECgEIAQAAAA==.飒飒南风:BAAAKgAECgQIBAAAAA==.',['飞鸟']='飞鸟:BAACKgAFFH8gAAMFAAgIVxj4BgBYAQAFAAcIrBn4BgBYAQAQAAQIFxQ/DwA9AQAqAAQKf0IAAwUACAj9JJsIAMQCAAUACAj+I5sIAMQCABAACAiUIuIEAKoCAAAA.',['馨瑶']='馨瑶:BAAAKgADCgEIAQAAAA==.',['馨馨']='馨馨:BAAAKgADCggICAAAAA==.',['马革']='马革裹尸:BAAAKgAECgYIBgAAAA==.',['驯麓']='驯麓:BAAAKgAFFAEIAQAAAA==.',['高大']='高大帅男雕弩:BAAAKgAECgQIBQAAAA==.',['魅影']='魅影丶塞隆:BAAAKgAFFAMIAwAAAA==.',['魏淑']='魏淑芬:BAABKgAFFH8IAAIRAAQIdSSZBgAzAQARAAQIdSSZBgAzAQABKgAFFAgIAgAQAAIWAA==.',['鹹菜']='鹹菜:BAABKgAFFH8MAAMSAAYI7xphGgCOAQASAAYI7xphGgCOAQAWAAYIgAwBEQD6AAAAAA==.',['鹿鸣']='鹿鸣之什:BAACKgAFFH8MAAIEAAgIeR41AAClAgAEAAgIeR41AAClAgAqAAQKfy4ABAMACAj7HzgZALcBAAMABwhEHzgZALcBAAIABggjGuk3ACwBAAQAAghXEXIyAGYAAAAA.',['黄岐']='黄岐圣弦:BAAAKgAECgQIBAAAAA==.',['黄昏']='黄昏之海:BAAAKgAECgcIEAAAAA==.',['黄泉']='黄泉猎:BAAAKgAECgQIBAAAAA==.',['黑崎']='黑崎八千:BAAAKgAECgYIBgAAAA==.',['黑暗']='黑暗中牛牛:BAAAKgAECgYICwAAAA==.',['黑白']='黑白:BAABKgAFFH8GAAIcAAYI6x4YAQD2AQAcAAYI6x4YAQD2AQAAAA==.',['默涩']='默涩:BAAAKgAECgEIAQAAAA==.',['龘龘']='龘龘:BAAAKgAECgQIBQAAAA==.',['龙吟']='龙吟幽逸:BAAAKgADCggIDQAAAA==.',['龙女']='龙女神月:BAABKgAECn8XAAIWAAgIpBluBwDYAQAWAAgIpBluBwDYAQAAAA==.',['龙歇']='龙歇会儿:BAAAKgADCggICAAAAA==.',['龙裔']='龙裔火花:BAAAKgADCggIDgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end