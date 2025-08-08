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
 local lookup = {'DeathKnight-Blood','Paladin-Holy','Paladin-Retribution','Paladin-Protection','Druid-Balance','Priest-Shadow','Hunter-Marksmanship','Hunter-BeastMastery','Evoker-Devastation','Warrior-Arms','Warrior-Fury','Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Evoker-Preservation','Priest-Holy','Priest-Discipline','Rogue-Assassination','Rogue-Outlaw','Shaman-Restoration','Mage-Arcane','DemonHunter-Havoc','Druid-Guardian','Monk-Mistweaver','Monk-Windwalker','Hunter-Survival','DeathKnight-Unholy','Rogue-Subtlety','Mage-Fire','Druid-Restoration','Mage-Frost','Warrior-Protection','DeathKnight-Frost','Shaman-Elemental','Shaman-Enhancement','Warlock-Affliction','DemonHunter-Vengeance',}; local provider = {region='CN',realm='熵魔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Bl='Blued:BAAAKgAFFAIIAgAAAA==.',Cc='Ccvip:BAAAKgAECgQIBAAAAA==.',Ch='Chovy:BAABKgAFFH8IAAIBAAgIyAZpBgBXAQABAAgIyAZpBgBXAQAAAA==.',Da='Darwin:BAAAKgAFFAgIAgAAAA==.',De='Deserteagle:BAAAKgAECgQIBAAAAA==.',Do='Doken:BAABKgAECn8WAAQCAAgIYBwlDQAhAgACAAgIYBwlDQAhAgADAAcIXSS9RwAZAgAEAAEIowCSawANAAABKgAFFAgIEQAFAEEeAA==.',Dr='Drail:BAABKgAECn8WAAIGAAgIRhnQGwD3AQAGAAgIRhnQGwD3AQAAAA==.',Fl='Floptropica:BAAAKgAECgMIAwAAAA==.',Fw='Fwmanman:BAABKgAFFH8IAAMHAAMIiBjAFAC/AAAHAAMIjhPAFAC/AAAIAAII7hYLIQCcAAAAAA==.',Ga='Gaura:BAABKgAFFH8JAAIJAAMISQTVGgCHAAAJAAMISQTVGgCHAAAAAA==.',Go='Goblinkiller:BAABKgAFFH8HAAMKAAcIIBNXDgArAQAKAAQIHg9XDgArAQALAAMIJhvGKwCSAAAAAA==.',Gu='Gumayusi:BAAAKgAFFAQIBAAAAA==.',Ha='Halo:BAAAKgAECgMIAwAAAA==.',['Hé']='Héstía:BAAAKgAECgYIBgAAAA==.',Ic='Icecoffee:BAABKgAFFH8KAAIDAAYICCFHDgDyAQADAAYICCFHDgDyAQABKgAFFAgICgADAK0lAA==.',Je='Jesse:BAACKgAFFH8UAAIMAAYI0RsuEQCCAQAMAAYI0RsuEQCCAQAqAAQKfywAAwwACAjfI10KAGsCAAwACAhJI10KAGsCAA0AAQgqIxZqAGYAAAAA.',Ko='Kous:BAABKgAFFH8FAAIMAAUIDQoGIwDwAAAMAAUIDQoGIwDwAAAAAA==.',La='Lams:BAAAKgAFFAMIAwABKgAFFAgIAwAOAAAAAA==.',Lm='Lmn:BAABKgAFFH8PAAMPAAYImheDBADLAAAPAAQIGhODBADLAAAJAAUINyBMEgDCAAABKgAFFAgIEwAQAP0gAA==.',Lo='Losointa:BAAAKgAECgcIEgAAAA==.',Ma='Maxgogo:BAAAKgAECgQIBAAAAA==.',Mi='Mizuki:BAAAKgAECgQIBAAAAA==.',Mo='Mohan:BAABKgAFFH8KAAMGAAYI8AkmDgAeAQAGAAYI8AkmDgAeAQARAAMIoBfIGACbAAAAAA==.',Ni='Nimble:BAABKgAFFH8KAAMSAAgI5ww/CwCYAQASAAYIEQo/CwCYAQATAAQIjQuqBAC0AAABKgAFFAgIEgARAF8aAA==.Nishizhu:BAAAKgAFFAIIAwAAAA==.',No='Nobubu:BAAAKgAFFAIIAgAAAA==.Nobus:BAAAKgAFFAYIAQAAAA==.',Re='Red:BAAAKgAECgMIAwAAAA==.',Si='Silent:BAABKgAFFH8GAAIUAAYI1g/PEQBGAQAUAAYI1g/PEQBGAQAAAA==.Sinner:BAAAKgAECggICAAAAA==.',Sm='Smartliu:BAAAKgADCgIIAgAAAA==.',St='Stars:BAACKgAFFH8KAAMHAAgIIRfMDwBpAQAHAAYImxfMDwBpAQAIAAQIhBjXFABPAQAqAAQKfxQAAggACAgTEgxSALsBAAgACAgTEgxSALsBAAAA.',Uz='Uzi:BAAAKgAFFAYIAgAAAA==.',Vo='Voviod:BAABKgAFFH8IAAIVAAgIagRTDQBuAQAVAAgIagRTDQBuAQAAAA==.',Yl='Ylinf:BAAAKgAECgQIBAAAAA==.',Zy='Zyh:BAABKgAECn8bAAIIAAgIEhn6PQAAAgAIAAgIEhn6PQAAAgAAAA==.',['一个']='一个奶爸:BAACKgAFFH8YAAIUAAQIwxdhLgC+AAAUAAQIwxdhLgC+AAAqAAQKfyAAAhQACAhZHdUeABACABQACAhZHdUeABACAAAA.一个技能够了:BAACKgAFFH8GAAIDAAYI+w7VJABWAQADAAYI+w7VJABWAQAqAAQKfxgAAwMACAhZI2kPANACAAMACAhZI2kPANACAAQAAgjqFLghADwAAAAA.',['一亚']='一亚瑟王一:BAABKgAFFH8IAAIDAAgIjggPPQD6AAADAAgIjggPPQD6AAAAAA==.',['一刀']='一刀掌死你:BAAAKgAFFAIIBAAAAA==.',['一夜']='一夜如歌:BAABKgAFFH8KAAIWAAYIag5vFwA/AQAWAAYIag5vFwA/AQAAAA==.',['一撮']='一撮毛:BAABKgAFFH8PAAIXAAQIMBQqBgCwAAAXAAQIMBQqBgCwAAAAAA==.',['一梦']='一梦入星河:BAAAKgAECggIEQAAAA==.',['一脚']='一脚不小心:BAABKgAECn8qAAMYAAgILRdyJwC+AQAYAAgILRdyJwC+AQAZAAIITQ2sZQAxAAAAAA==.',['七彩']='七彩斑斓的黑:BAAAKgAECggICwAAAA==.',['七海']='七海娜娜米丷:BAABKgAFFH8GAAIEAAYIsQw+EgDrAAAEAAYIsQw+EgDrAAAAAA==.',['万人']='万人敬仰的萨:BAAAKgAECgIIAgAAAA==.',['三少']='三少爷丶:BAAAKgADCggICAAAAA==.',['三指']='三指元素:BAAAKgAECgIIAgAAAA==.',['三花']='三花红棍:BAABKgAFFH8SAAMKAAYIwyLOBADvAQAKAAYIwyLOBADvAQALAAYIUQieCwBZAQAAAA==.',['三角']='三角函数嫖哥:BAABKgAFFH8HAAIDAAQIwB7xFgD/AAADAAQIwB7xFgD/AAAAAA==.',['不洁']='不洁至高王:BAAAKgAECggIDQABKgAFFAgICQAaAFobAA==.',['不眠']='不眠:BAAAKgAECgYIBgAAAA==.',['严禁']='严禁期待:BAAAKgAECgUIDAAAAA==.',['丨圣']='丨圣斗士丨:BAAAKgADCggIGAAAAA==.',['丨宝']='丨宝瓶座丨:BAAAKgADCggICAAAAA==.',['丨燃']='丨燃丨:BAAAKgAECgcIBwAAAA==.',['丨赤']='丨赤丨:BAAAKgADCgQIBAAAAA==.',['丨阿']='丨阿牛丨:BAAAKgAECgYICQAAAA==.',['丨鲸']='丨鲸鱼座丨:BAAAKgAFFAQIBAAAAA==.',['丨黑']='丨黑悟空丨:BAAAKgADCggICAAAAA==.',['丶如']='丶如花:BAAAKgAFFAQIAgAAAA==.',['丶沐']='丶沐雨橙风:BAABKgAFFH8MAAMbAAgIwxkCBQBVAgAbAAgIwxkCBQBVAgABAAQISxekHQC2AAAAAA==.',['为了']='为了德玛西亚:BAAAKgAECgEIAgAAAA==.',['丿丶']='丿丶亞瑟:BAAAKgAECgcICgAAAA==.',['九袋']='九袋长老:BAAAKgAECgEIAQAAAA==.',['云之']='云之君兮:BAAAKgADCgcIBwAAAA==.',['以德']='以德扶人:BAABKgAFFH8IAAIXAAMIVAZZBgBGAAAXAAMIVAZZBgBGAAAAAA==.',['你怎']='你怎么不笑:BAAAKgAECggICAAAAA==.',['你愁']='你愁啥:BAABKgAECn8hAAIYAAgIeRMtDQBaAQAYAAgIeRMtDQBaAQABKgAFFAgICAADAC8jAA==.',['依然']='依然風騒:BAABKgAECn8ZAAMcAAgIExbwDwDrAQASAAgIdBNUFQDsAQAcAAgIyhPwDwDrAQABKgAFFAgIEwASAC0cAA==.',['修仙']='修仙者:BAAAKgAECggICAAAAA==.',['倩影']='倩影无双:BAAAKgAECgYIBgAAAA==.',['兔兔']='兔兔子:BAAAKgADCgMIAwAAAA==.',['八队']='八队猎手:BAAAKgADCggICAAAAA==.',['公子']='公子丶上边请:BAAAKgADCgQIBAAAAA==.公子丶请留步:BAAAKgADCgIIAgAAAA==.',['公牛']='公牛的血:BAAAKgAFFAYIAgABKgAFFAgIBAAOAAAAAA==.',['六百']='六百六十六:BAAAKgADCgEIAQAAAA==.',['兵甲']='兵甲龙痕:BAAAKgAECgcICQAAAA==.',['兽无']='兽无寸铁:BAAAKgADCgUIBQAAAA==.',['再不']='再不玩就老了:BAAAKgADCggICAAAAA==.',['冰忆']='冰忆:BAABKgAFFH8GAAIDAAYI+BwYJwBMAQADAAYI+BwYJwBMAQAAAA==.',['冰棠']='冰棠桂圆:BAAAKgAECgYIBgAAAA==.',['冰糖']='冰糖桂元:BAAAKgAFFAIIAgAAAA==.冰糖桂原:BAAAKgAFFAMIAwAAAA==.冰糖桂圆:BAAAKgAFFAIIAgAAAA==.',['准备']='准备脱战:BAAAKgAECgMIAwAAAA==.',['凌香']='凌香:BAAAKgAECgYIBgAAAA==.',['凝残']='凝残丶凛:BAAAKgAECgMIAwAAAA==.凝残丶殇:BAAAKgAECgcICAAAAA==.凝残丶魔:BAAAKgAECgYIBgAAAA==.',['凡人']='凡人皆有一死:BAABKgAECn8WAAIDAAYIsR+ZHgDHAQADAAYIsR+ZHgDHAQAAAA==.',['凯西']='凯西:BAAAKgADCggIEAAAAA==.',['别逼']='别逼我按这钮:BAAAKgADCgQIBAAAAA==.',['割草']='割草机:BAAAKgADCgMIAwAAAA==.',['功夫']='功夫熊猫无敌:BAAAKgADCgUIBQAAAA==.',['北门']='北门教父:BAABKgAFFH8OAAMHAAQIIg00HQCGAAAHAAMIaA40HQCGAAAIAAEIlgpvSgBCAAAAAA==.',['卓文']='卓文君:BAAAKgAECgQIBAAAAA==.',['卡列']='卡列乌斯:BAAAKgAFFAYIBAABKgAFFAgIFAAZAFsOAA==.',['原典']='原典创星图:BAAAKgAECggICwAAAA==.',['原则']='原则:BAAAKgAFFAEIAQAAAA==.',['反光']='反光镜:BAAAKgADCgEIAQAAAA==.',['叔叔']='叔叔的果粒橙:BAABKgAFFH8FAAIbAAIIEgpmTABvAAAbAAIIEgpmTABvAAAAAA==.',['变不']='变不了树:BAAAKgAECggICwAAAA==.',['只会']='只会睡觉的鱼:BAACKgAFFH8kAAIYAAgIUB7jAgCgAQAYAAgIUB7jAgCgAQAqAAQKfycAAhgACAhPJaMDAOACABgACAhPJaMDAOACAAAA.',['叫兽']='叫兽:BAABKgAFFH8FAAIVAAMIYAxeKwC2AAAVAAMIYAxeKwC2AAABKgAFFAgIDQALAF0fAA==.',['叭八']='叭八:BAAAKgADCgcIBwAAAA==.',['叮叮']='叮叮:BAAAKgAECgIIAgAAAA==.',['可燃']='可燃点:BAAAKgAECgUIBQAAAA==.',['可爱']='可爱的达达:BAABKgAECn81AAIDAAgIPSXYBgD+AgADAAgIPSXYBgD+AgAAAA==.可爱软软:BAAAKgADCgEIAQAAAA==.',['吉尔']='吉尔尼斯德:BAAAKgAECgcIBwAAAA==.',['君临']='君临天下寒:BAAAKgADCgUIBQAAAA==.',['吴不']='吴不在:BAACKgAFFH8VAAIDAAYIOBSaLQAxAQADAAYIOBSaLQAxAQAqAAQKfyUAAgMACAgwHtc5AEECAAMACAgwHtc5AEECAAAA.',['吾命']='吾命欲真:BAACKgAFFH8cAAIdAAMIvhfPGQDbAAAdAAMIvhfPGQDbAAAqAAQKf1AAAh0ACAhJIJkBAHICAB0ACAhJIJkBAHICAAAA.',['呀呜']='呀呜一口:BAAAKgAFFAQIAwAAAA==.',['呂布']='呂布:BAACKgAFFH8QAAIDAAMIvRrNTQDUAAADAAMIvRrNTQDUAAAqAAQKfxoAAgMACAhdI1IPANoCAAMACAhdI1IPANoCAAAA.',['哈库']='哈库菈玛塔塔:BAABKgAFFH8JAAIKAAYIRSDeAwAtAQAKAAYIRSDeAwAtAQAAAA==.',['哈鸡']='哈鸡米:BAAAKgAECgYIBgAAAA==.',['哑巴']='哑巴湖小米粒:BAAAKgADCgcIBwAAAA==.',['啊污']='啊污卵:BAABKgAFFH8KAAISAAYIghmPDACEAQASAAYIghmPDACEAQAAAA==.',['喝酸']='喝酸奶忝瓶蓋:BAABKgAFFH8GAAIHAAQIYRj7JADZAAAHAAQIYRj7JADZAAAAAA==.',['嗦溜']='嗦溜一口儿:BAAAKgADCggICwAAAA==.',['四糸']='四糸乃:BAABKgAFFH8IAAIMAAgIqQs2CwDZAQAMAAgIqQs2CwDZAQAAAA==.',['回忆']='回忆回不去:BAAAKgAFFAQIBAAAAA==.',['圆小']='圆小米:BAAAKgAECgUIBQAAAA==.',['地狱']='地狱黎明:BAAAKgAECgQIBAAAAA==.',['塔布']='塔布羊:BAAAKgAECgQIBgAAAA==.',['夜听']='夜听云海:BAABKgAFFH8IAAMFAAgIbB02EQCVAQAFAAcI/Rw2EQCVAQAeAAEIZRIHNABJAAAAAA==.',['夜浮']='夜浮华:BAABKgAFFH8IAAIDAAQInh6ADQAeAQADAAQInh6ADQAeAQABKgAFFAgIEgAWAJgVAA==.',['夜鼠']='夜鼠子:BAAAKgAECgMIAwAAAA==.',['大保']='大保健老司机:BAAAKgADCgYIBgAAAA==.',['大木']='大木老師:BAABKgAFFH8HAAMZAAYIIRytBwCAAQAZAAYIIRytBwCAAQAYAAEIxQGiMAAsAAAAAA==.大木老湿:BAAAKgADCgIIAgAAAA==.',['大爱']='大爱仙尊:BAABKgAFFH8JAAMHAAYIMxo9DwBvAQAHAAYIMxo9DwBvAQAIAAMI5wj4OACFAAAAAA==.',['大羊']='大羊肖恩:BAAAKgAECgMIAwAAAA==.',['大跳']='大跳扭断腿:BAAAKgADCgYIBgAAAA==.',['大馍']='大馍王:BAAAKgADCggICgAAAA==.',['大魔']='大魔王到此:BAAAKgADCgIIAgAAAA==.',['天空']='天空中的雷鸣:BAABKgAECn8UAAIUAAgIyR/bFgBLAgAUAAgIyR/bFgBLAgAAAA==.',['天赐']='天赐淡雅香丶:BAABKgAFFH8IAAMSAAMIwwt/HgC3AAASAAMIUQp/HgC3AAATAAIIfgl5CQBxAAAAAA==.',['太乙']='太乙假人:BAAAKgAECgYIBQAAAA==.',['太难']='太难得的回忆:BAAAKgAFFAEIAQAAAA==.',['失名']='失名者:BAAAKgAECggICAAAAA==.',['奔跑']='奔跑的拉条子:BAAAKgAFFAQIBAAAAA==.',['奕剑']='奕剑十五:BAAAKgAECgMIAwAAAA==.',['奥蕾']='奥蕾塞丝:BAAAKgADCgYIBgAAAA==.',['女旦']='女旦己:BAAAKgAECgIIAgAAAA==.',['好男']='好男人老婆造:BAAAKgAECgIIAgAAAA==.',['妖靈']='妖靈:BAAAKgAECgYIDAAAAA==.',['妮雅']='妮雅:BAAAKgADCgEIAQAAAA==.',['姿伊']='姿伊:BAABKgAFFH8GAAIfAAYI8BjlBQB2AQAfAAYI8BjlBQB2AQAAAA==.',['婲開']='婲開糀謝:BAAAKgAECgEIAQAAAA==.',['嫂嫂']='嫂嫂请住手:BAABKgAFFH8IAAIMAAIIQggLLQBTAAAMAAIIQggLLQBTAAAAAA==.',['嫖哥']='嫖哥又来了:BAAAKgAFFAgIBAAAAA==.',['安娜']='安娜:BAAAKgAECgMIAwAAAA==.',['安森']='安森:BAAAKgAECgQIBAAAAA==.',['安玲']='安玲:BAABKgAECn8UAAMDAAgISx0VSgDhAQADAAcIhiEVSgDhAQAEAAEI6AMRYgAHAAAAAA==.',['安静']='安静:BAAAKgAECggICAAAAA==.',['实习']='实习小护士:BAAAKgAECgEIAQAAAA==.',['宽大']='宽大的坟场:BAACKgAFFH8pAAIZAAUIRhXgCgAyAQAZAAUIRhXgCgAyAQAqAAQKfxcAAhkACAhFGwMeAO0BABkACAhFGwMeAO0BAAAA.',['小多']='小多俪:BAABKgAFFH8IAAIUAAgIRxPnBQDOAQAUAAgIRxPnBQDOAQAAAA==.',['小小']='小小聋人:BAAAKgAECgcICQAAAA==.',['小山']='小山猪:BAAAKgADCgEIAQAAAA==.',['小帝']='小帝大人:BAAAKgAECgcICwAAAA==.',['小浪']='小浪蹄子:BAAAKgAECgYICQAAAA==.',['小爆']='小爆炸:BAAAKgAFFAQIBAAAAA==.',['小牛']='小牛一号丶:BAAAKgADCggICAAAAA==.小牛马:BAABKgAFFH8GAAIDAAYIbwsgLgAvAQADAAYIbwsgLgAvAQABKgAFFAgIBAAOAAAAAA==.',['小狐']='小狐:BAACKgAFFH8MAAIUAAMI7Qd1OgCaAAAUAAMI7Qd1OgCaAAAqAAQKfx4AAhQACAhCGccTAKIBABQACAhCGccTAKIBAAAA.小狐仙:BAAAKgAECgUIBQAAAA==.',['小羊']='小羊肖恩:BAAAKgAECgUIBQAAAA==.',['小肘']='小肘子:BAAAKgADCggIEAAAAA==.',['小芋']='小芋:BAAAKgAECgIIAgAAAA==.',['小豆']='小豆丁:BAAAKgAECgQIBAAAAA==.',['小软']='小软软:BAAAKgADCgEIAQAAAA==.',['小鼠']='小鼠大浪:BAAAKgAECgQIBAAAAA==.',['就是']='就是来玩玩:BAAAKgAECgUICAAAAA==.',['山下']='山下忠秀:BAABKgAFFH8IAAIDAAgIAR1FBQB9AgADAAgIAR1FBQB9AgAAAA==.',['嵿级']='嵿级太子:BAAAKgAFFAQIBAAAAA==.',['巧克']='巧克力棒棒:BAAAKgAECgUIBQAAAA==.',['布林']='布林顿九千:BAACKgAFFH8kAAIdAAYI7xmEDABtAQAdAAYI7xmEDABtAQAqAAQKfz4AAh0ACAgBIz0EALcCAB0ACAgBIz0EALcCAAAA.',['布甲']='布甲:BAABKgAFFH8GAAIDAAYI4BKBKQBBAQADAAYI4BKBKQBBAQAAAA==.',['布絡']='布絡克斯:BAAAKgAECggICAAAAA==.',['布鲁']='布鲁特斯:BAAAKgAFFAgIAwAAAA==.',['帝靈']='帝靈:BAAAKgAECgYICAAAAA==.',['带土']='带土:BAAAKgAECgMIAwAAAA==.',['幻影']='幻影刺客:BAAAKgAECgUICQAAAA==.',['弓墨']='弓墨景頁长:BAAAKgADCgcICAAAAA==.',['张学']='张学友:BAAAKgAFFAQIBAAAAA==.',['張莽']='張莽漢:BAABKgAECn8XAAMfAAYIpBVaNAAsAQAfAAYIpBVaNAAsAQAVAAQIWRIqbgCYAAAAAA==.',['强手']='强手裂颅:BAABKgAFFH8HAAMBAAQIiw9sFQChAAABAAQI3QtsFQChAAAbAAMIew9rRwCDAAAAAA==.',['影灬']='影灬:BAAAKgAECgQIBAAAAA==.',['往往']='往往复复:BAAAKgAFFAgIBAAAAA==.',['心生']='心生万法:BAAAKgAFFAIIAgAAAA==.',['心碎']='心碎往事:BAABKgAECn8oAAIKAAgIsyLPBADIAgAKAAgIsyLPBADIAgAAAA==.',['快奶']='快奶我:BAAAKgAECggICAAAAA==.',['怀念']='怀念往事:BAABKgAFFH8IAAIBAAgINg+SBACoAQABAAgINg+SBACoAQAAAA==.',['怒风']='怒风丶清:BAAAKgAECgMIAwAAAA==.',['性感']='性感牛牛:BAABKgAFFH8LAAIEAAMIuAJAJwBVAAAEAAMIuAJAJwBVAAAAAA==.',['惊飞']='惊飞羽:BAAAKgAECgQIBAAAAA==.',['慈父']='慈父纳垢:BAAAKgAECgYIBwAAAA==.',['憨嘀']='憨嘀啦憨:BAABKgAFFH8KAAIUAAYI4QhYGAAgAQAUAAYI4QhYGAAgAQAAAA==.',['我不']='我不挑食:BAAAKgAECgcIBwAAAA==.',['我只']='我只会微笑:BAAAKgADCgIIAgAAAA==.',['我心']='我心里:BAAAKgAFFAMIBAAAAA==.',['抢财']='抢财神:BAABKgAFFH8HAAIMAAQIOh8MEwBuAQAMAAQIOh8MEwBuAQAAAA==.',['摩诃']='摩诃毗卢遮那:BAABKgAFFH8GAAIYAAYIqQ2YEAAoAQAYAAYIqQ2YEAAoAQAAAA==.',['救世']='救世萨杨永信:BAAAKgAECgYIBwAAAA==.',['断掌']='断掌:BAAAKgAECgcIBwAAAA==.',['斯莱']='斯莱马博:BAABKgAFFH8IAAIgAAgI8gGPBAAgAQAgAAgI8gGPBAAgAQAAAA==.',['无双']='无双的王者:BAAAKgAFFAQIBAAAAA==.',['无敌']='无敌小可爱:BAAAKgAECgIIAgAAAA==.无敌萌法神:BAAAKgADCggICAAAAA==.',['无言']='无言之境:BAAAKgAECggIEAAAAA==.',['星期']='星期三:BAAAKgADCggICAAAAA==.',['晓晓']='晓晓圣神:BAABKgAFFH8GAAIEAAYI7xOjDAAuAQAEAAYI7xOjDAAuAQAAAA==.',['晨拥']='晨拥:BAAAKgAFFAIIAgAAAA==.',['晨曦']='晨曦将至:BAAAKgADCgQIBAAAAA==.',['智慧']='智慧三角:BAABKgAFFH8IAAIQAAgIbRCvBQDbAQAQAAgIbRCvBQDbAQAAAA==.',['暗夜']='暗夜兽神:BAAAKgAECgEIAQAAAA==.',['暗川']='暗川:BAAAKgAECgEIAQAAAA==.',['暴躁']='暴躁小牛牛:BAAAKgADCgMIAwAAAA==.',['暴鲤']='暴鲤龙:BAAAKgAFFAIIAgAAAA==.',['最后']='最后一个骑士:BAAAKgADCgUIBQAAAA==.',['最完']='最完美的孤独:BAAAKgADCggICAAAAA==.',['月亮']='月亮宇宙:BAAAKgAECgUIBQAAAA==.',['月儛']='月儛云漪:BAABKgAFFH8GAAMbAAQISRmEKgDiAAAbAAQISRmEKgDiAAABAAIIHAb+MABGAAAAAA==.',['有个']='有个人:BAABKgAFFH8GAAIQAAYIOhkbDABhAQAQAAYIOhkbDABhAQAAAA==.',['杀财']='杀财神:BAABKgAECn8vAAIDAAgILibPAgAXAwADAAgILibPAgAXAwAAAA==.',['李小']='李小雨:BAAAKgAFFAgIAwAAAA==.李小龍:BAAAKgADCgYIBgAAAA==.',['林克']='林克时间:BAACKgAFFH8UAAIhAAUI0R5CAQAiAQAhAAUI0R5CAQAiAQAqAAQKfy8AAiEACAhmJdQBAOQCACEACAhmJdQBAOQCAAAA.',['林北']='林北卖番薯:BAAAKgADCgQIBAAAAA==.',['果然']='果然多多鱼:BAAAKgAECgIIAgAAAA==.',['柏少']='柏少:BAABKgAFFH8IAAIFAAgI6xWTBwAoAgAFAAgI6xWTBwAoAgAAAA==.',['柳如']='柳如烟:BAAAKgAECgIIAgAAAA==.',['森林']='森林德:BAAAKgAECgYICgAAAA==.森林骑士:BAABKgAFFH8GAAICAAYI/h5PAADuAQACAAYI/h5PAADuAQAAAA==.',['榴莲']='榴莲千层:BAAAKgADCggICAAAAA==.',['樱桃']='樱桃小丸犊子:BAABKgAFFH8GAAIMAAYIjQ1CHAAkAQAMAAYIjQ1CHAAkAQAAAA==.',['止戦']='止戦之殇:BAAAKgAFFAQIBAAAAA==.',['死亡']='死亡旋涡:BAACKgAFFH8KAAILAAMIKRsKGwDpAAALAAMIKRsKGwDpAAAqAAQKfxgAAgsACAgnHI0cAC4CAAsACAgnHI0cAC4CAAAA.死亡绽放丶:BAAAKgAECgEIAQAAAA==.',['殲滅']='殲滅卿:BAAAKgADCgIIAQAAAA==.',['段杖']='段杖袭明:BAACKgAFFH8LAAIQAAMI8Rv6HgDNAAAQAAMI8Rv6HgDNAAAqAAQKfxsAAhAACAgpIr0IAJkCABAACAgpIr0IAJkCAAAA.',['比尔']='比尔:BAAAKgAECgMIBAAAAA==.',['水晶']='水晶叶子:BAAAKgAECgYICgAAAA==.',['江流']='江流:BAAAKgAECgMIAwAAAA==.',['汤姆']='汤姆阿:BAAAKgAECgMIAQAAAA==.',['沫寒']='沫寒的小德:BAAAKgAECggICAAAAA==.',['泫嘢']='泫嘢尐:BAAAKgAECgIIAgAAAA==.',['泽卷']='泽卷小雨:BAABKgAFFH8LAAIBAAYIwxE0DgA4AQABAAYIwxE0DgA4AQAAAA==.',['浴紫']='浴紫而存:BAAAKgAECgQIBAAAAA==.',['海棉']='海棉体:BAAAKgAECgIIAgAAAA==.',['海问']='海问香丶:BAAAKgAECgYIBgAAAA==.',['海鲜']='海鲜小馄饨:BAAAKgAFFAQIBAAAAA==.',['消失']='消失的永恒:BAAAKgAFFAIIAgAAAA==.',['清蒸']='清蒸蚰蜢虎:BAAAKgADCggICAAAAA==.',['清风']='清风怒只为橙:BAAAKgAECgUIBgAAAA==.',['源氏']='源氏:BAAAKgAECggICgAAAA==.',['潘达']='潘达利亚:BAACKgAFFH8OAAQUAAQIPxU4LADFAAAUAAMIPxU4LADFAAAiAAQIhAuwDgCvAAAjAAMIyAzCGACCAAAqAAQKfzIAAyIACAgeHSkgAO0BACIACAgeHSkgAO0BABQABAgIDMWkAFsAAAAA.',['潶黯']='潶黯亡战:BAABKgAFFH8KAAIgAAIIMBWfCQB1AAAgAAIIMBWfCQB1AAAAAA==.',['灬殇']='灬殇城灬:BAAAKgAECgMIAwAAAA==.',['灬沐']='灬沐小雪灬:BAABKgAFFH8GAAMCAAYI5wYNBAAJAQACAAUIYAYNBAAJAQADAAEIewcwTABRAAAAAA==.',['炒菜']='炒菜抓宠物:BAAAKgADCggICAAAAA==.',['炸掉']='炸掉男厕所:BAAAKgADCggIEAAAAA==.',['炼天']='炼天魔尊:BAAAKgAECgYIBgAAAA==.',['热丶']='热丶砂舞瘫:BAAAKgAECgMIAwAAAA==.',['热心']='热心市民小杰:BAAAKgADCggICAABKgADCggIEAAOAAAAAA==.',['無惧']='無惧者丶无影:BAAAKgAFFAQIBAAAAA==.',['燕三']='燕三十娘:BAAAKgAECgEIAQAAAA==.',['爱布']='爱布拉娜:BAABKgAFFH8IAAIJAAgIHRVYCAD5AQAJAAgIHRVYCAD5AQAAAA==.',['爱神']='爱神:BAAAKgADCggICAAAAA==.',['牛啤']='牛啤:BAAAKgADCgIIAgAAAA==.',['牧師']='牧師丶:BAACKgAFFH8SAAIRAAYIXxqDFQDoAAARAAYIXxqDFQDoAAAqAAQKfyEAAxEACAgzG3wlAKQBABEACAgzG3wlAKQBAAYAAwixFLE/ALkAAAAA.',['狂野']='狂野:BAAAKgAECgQIBQAAAA==.',['狐白']='狐白:BAAAKgADCgEIAQAAAA==.',['独上']='独上西楼:BAABKgAFFH8KAAISAAYIIRR2DQB3AQASAAYIIRR2DQB3AQAAAA==.',['猪猪']='猪猪拯救世界:BAABKgAFFH8GAAMBAAQILxPJEAC6AAABAAQItBLJEAC6AAAbAAIItBY7JgCNAAAAAA==.',['猫咪']='猫咪很疯狂:BAAAKgAECgIIAgAAAA==.',['琻刚']='琻刚腿:BAAAKgAECgcIBwAAAA==.',['瓦尔']='瓦尔沙拉:BAAAKgADCggICAAAAA==.',['甜软']='甜软软:BAAAKgADCgEIAQAAAA==.',['疯子']='疯子晚餐:BAABKgAFFH8OAAIfAAMIYBozDgDyAAAfAAMIYBozDgDyAAAAAA==.',['疯狂']='疯狂猫咪:BAAAKgAECgIIAgAAAA==.',['痛到']='痛到窒息:BAAAKgAFFAQIBAAAAA==.',['白呼']='白呼呼:BAAAKgAECgUIBQAAAA==.',['盗了']='盗了只柚子:BAAAKgAECgIIBAAAAA==.',['盜卝']='盜卝賊:BAAAKgAECgIIAwAAAA==.',['破碎']='破碎往事:BAABKgAFFH8IAAIVAAgILQ2OCADxAQAVAAgILQ2OCADxAQAAAA==.',['穆涕']='穆涕:BAAAKgAECgYIBgAAAA==.',['立花']='立花正仁:BAACKgAFFH8MAAMBAAgItBSCBQDpAQABAAgIYBSCBQDpAQAbAAMIlRTPEQDcAAAqAAQKfxcAAhsACAiOImEOAJgCABsACAiOImEOAJgCAAAA.',['米兰']='米兰达小新星:BAABKgAFFH8SAAIDAAgI/BxGBwBTAgADAAgI/BxGBwBTAgAAAA==.',['米面']='米面油条:BAAAKgADCgYIBgAAAA==.',['索尔']='索尔格林:BAAAKgADCgcIBwAAAA==.',['红丨']='红丨日:BAAAKgAECgUIBgAAAA==.',['红头']='红头发魔鬼:BAABKgAECn8YAAIHAAgI9A6qLQCBAQAHAAgI9A6qLQCBAQAAAA==.',['纯粮']='纯粮烈酒:BAAAKgAECgYIDQAAAA==.',['绝尘']='绝尘而去:BAAAKgADCggIDgAAAA==.',['缥缈']='缥缈星星:BAAAKgAECgQICwAAAA==.',['罗宾']='罗宾丶妮可:BAABKgAECn8bAAQkAAYIbR87LQCdAAANAAMIXSDMTgCtAAAkAAIISh47LQCdAAAMAAMINRyqgACMAAAAAA==.',['羽裳']='羽裳:BAAAKgAECggIDQAAAA==.',['老爷']='老爷:BAAAKgAECgYIEgAAAA==.',['肌肉']='肌肉:BAABKgAFFH8TAAMHAAQINBxPCAAFAQAHAAQIkxtPCAAFAQAIAAQI0BfVHwDYAAAAAA==.',['肥羊']='肥羊肥羊:BAAAKgAECgcICQAAAA==.',['花落']='花落之幾何:BAABKgAFFH8IAAIWAAgIWQ40DADCAQAWAAgIWQ40DADCAQAAAA==.',['苍崎']='苍崎青子丶:BAABKgAFFH8GAAIdAAYIHhEwDgBaAQAdAAYIHhEwDgBaAQAAAA==.',['苏小']='苏小寒:BAAAKgAFFAQIBAAAAA==.',['苏灼']='苏灼:BAAAKgAECggIDAAAAA==.',['茂茂']='茂茂总:BAAAKgAECgEIAQAAAA==.',['荒天']='荒天骑:BAAAKgAFFAQIBAABKgAFFAgIBgAVAAAUAA==.',['荒野']='荒野飈客:BAAAKgAECggICAAAAA==.',['荣耀']='荣耀的信仰:BAAAKgAFFAEIAQAAAA==.',['莉娜']='莉娜丶依巴斯:BAAAKgAECgYIBgAAAA==.',['莽骑']='莽骑儿:BAAAKgAECggIDQAAAA==.',['萌新']='萌新一枚:BAABKgAECn8YAAILAAgIWAJzbQBZAAALAAgIWAJzbQBZAAAAAA==.',['萨否']='萨否赖你:BAEBKgAFFH8MAAQjAAYI0BZxCABVAQAjAAYIhBJxCABVAQAUAAUIBwFYFADTAAAiAAEIOB7bFgBhAAABKgAFFAgIBgAjAK4TAA==.',['萨灬']='萨灬满:BAAAKgAECgcIBwAAAA==.',['萨迩']='萨迩:BAAAKgAFFAMIAwAAAA==.',['萨鲁']='萨鲁法克丶丶:BAAAKgAECgIIAgABKgAFFAgICAAUALsbAA==.',['葬靈']='葬靈魂:BAABKgAFFH8nAAMGAAYITAVLDAD7AAAGAAYITAVLDAD7AAAQAAQIJBLMJgCnAAAAAA==.',['蒲公']='蒲公英奶茶:BAAAKgAECgMIAwAAAA==.',['蓖麻']='蓖麻:BAAAKgAECgMIAwAAAA==.',['蓝胖']='蓝胖子乄:BAABKgAFFH8GAAIbAAYIfQuaGwBBAQAbAAYIfQuaGwBBAQAAAA==.',['蔡妍']='蔡妍丶:BAAAKgAECgQIBAAAAA==.',['虾仁']='虾仁:BAAAKgADCggICgAAAA==.',['蛋刀']='蛋刀的忧伤:BAAAKgAECgYIBgAAAA==.',['蛮大']='蛮大人:BAAAKgADCgMIAwAAAA==.',['蜡烛']='蜡烛骑士:BAAAKgAECgMIAwAAAA==.',['血色']='血色灬轩辕:BAAAKgAECgQIBAAAAA==.',['西木']='西木:BAACKgAFFH8MAAIWAAMI4AvuGgC5AAAWAAMI4AvuGgC5AAAqAAQKfxkAAyUACAgBFkoRABoBACUABgjwEkoRABoBABYABwgNElQmABYBAAAA.',['读来']='读来过倒才牛:BAACKgAFFH8PAAMKAAQIYh8nEwDrAAAKAAMIcRwnEwDrAAALAAQITh9hHADjAAAqAAQKfxUAAwsACAheH18pAOYBAAsABwgRHF8pAOYBAAoABQiBGlYpAG8BAAAA.读来过倒才犇:BAAAKgAFFAMIAwAAAA==.',['谜之']='谜之霜灼:BAABKgAFFH8IAAMdAAgI9hCnDgBVAQAdAAYIQxCnDgBVAQAVAAIIthLnLwCkAAABKgAFFAgIRwAdADUlAA==.',['谨年']='谨年丶:BAAAKgAECgYIBgAAAA==.',['豆子']='豆子:BAAAKgADCgEIAQAAAA==.',['貂蝉']='貂蝉丨骑吕布:BAAAKgADCgUIBQAAAA==.',['贝西']='贝西西:BAAAKgAFFAQIBAAAAA==.',['贵阳']='贵阳马东锡丶:BAAAKgAECgYIBwAAAA==.',['走过']='走过倒一片:BAAAKgAECggICAAAAA==.',['软九']='软九五:BAAAKgAECggICAAAAA==.',['软萌']='软萌萌:BAAAKgADCgEIAgAAAA==.',['软软']='软软大美女:BAAAKgADCgEIAQAAAA==.软软美:BAAAKgADCgEIAQAAAA==.软软萌萌:BAAAKgADCgEIAQAAAA==.',['轶小']='轶小宝:BAACKgAFFH8IAAMSAAMItAs+DADgAAASAAMItAs+DADgAAAcAAEIVwaFEgA+AAAqAAQKfykAAxIACAjsG74SAAkCABIACAhQGL4SAAkCABwACAhMGJoOAP8BAAAA.',['辛德']='辛德穆拉丶:BAABKgAFFH8MAAMUAAQIZCL/CQAHAQAUAAQIZCL/CQAHAQAjAAQIlw8UCwD4AAABKgAFFAgICAAUAO0XAA==.',['辤殤']='辤殤德:BAAAKgAFFAMIAwAAAA==.',['达纳']='达纳督斯:BAAAKgAFFAEIAQAAAA==.',['追萧']='追萧:BAAAKgADCgEIAQAAAA==.',['那个']='那个法狮:BAAAKgAECgUICgAAAA==.',['酒一']='酒一卮:BAAAKgADCggICAAAAA==.',['酷丶']='酷丶鬼:BAAAKgAFFAQIBAAAAA==.',['野蛮']='野蛮的圣光:BAAAKgAECgQIBAAAAA==.野蛮的灵魂:BAABKgAECn8WAAIbAAgIGA3oSQBKAQAbAAgIGA3oSQBKAQAAAA==.',['铁头']='铁头功:BAABKgAFFH8OAAIBAAQI9AiGJwB5AAABAAQI9AiGJwB5AAAAAA==.',['银塔']='银塔蛮:BAAAKgADCgIIAgAAAA==.',['锅碗']='锅碗瓢盆缸:BAACKgAFFH8WAAIXAAMIjgxqCACGAAAXAAMIjgxqCACGAAAqAAQKfxYAAhcACAhRDdcTABMBABcACAhRDdcTABMBAAAA.',['长天']='长天孤鹜:BAAAKgADCgIIAgAAAA==.',['開雲']='開雲長:BAABKgAFFH8IAAIDAAgI0g9+DgDwAQADAAgI0g9+DgDwAQAAAA==.',['闇之']='闇之子:BAABKgAECn8UAAIWAAgIeyN6CADJAgAWAAgIeyN6CADJAgABKgAFFAgIAgAOAAAAAA==.',['阳光']='阳光下的小猪:BAAAKgADCggICAAAAA==.',['阿浩']='阿浩有德:BAAAKgADCgUIBwAAAA==.',['陈无']='陈无敌:BAAAKgAECgIIAgAAAA==.',['随缘']='随缘妙用:BAAAKgAECgQIBAAAAA==.',['随随']='随随便便吧:BAAAKgADCgEIAQAAAA==.',['雅修']='雅修特拉:BAAAKgAECgMIAwAAAA==.',['雪痕']='雪痕追命:BAAAKgADCggIDgAAAA==.',['雪祤']='雪祤:BAAAKgAECgcIBwAAAA==.',['零的']='零的传说术:BAAAKgAFFAMIAwAAAA==.',['雷勃']='雷勃:BAABKgAFFH8dAAIgAAcIUBWIAwBpAQAgAAcIUBWIAwBpAQAAAA==.',['霸王']='霸王茶姬:BAAAKgADCggICAAAAA==.',['青史']='青史几行名姓:BAAAKgADCgMIAwAAAA==.',['青歌']='青歌:BAAAKgAECgEIAgAAAA==.',['静静']='静静:BAAAKgAECgQIBAAAAA==.静静香:BAAAKgAECggICgAAAA==.',['静香']='静香:BAACKgAFFH8QAAIMAAYIcyKSAwCJAQAMAAYIcyKSAwCJAQAqAAQKfxYAAg0ACAhLGGgaALABAA0ACAhLGGgaALABAAEqAAUUCAgWAAwA6BIA.',['额你']='额你莫捏我手:BAAAKgADCgIIAgAAAA==.',['风傻']='风傻傻:BAAAKgAFFAEIAQAAAA==.',['风舞']='风舞痕:BAAAKgAECgYIDQAAAA==.',['飒蛮']='飒蛮:BAAAKgAFFAQIAwABKgAFFAgIBAAOAAAAAA==.',['飙龙']='飙龙妙影:BAAAKgADCgUIBQAAAA==.',['饕餮']='饕餮的小暴牙:BAABKgAFFH8IAAMFAAgIThKMDAC2AQAFAAcIdxCMDAC2AQAeAAEIeAEpGQA0AAAAAA==.',['香蕉']='香蕉不呐呐:BAACKgAFFH8QAAIIAAMITxm+LgDOAAAIAAMITxm+LgDOAAAqAAQKfxUAAggACAifGcJEAJUBAAgACAifGcJEAJUBAAAA.',['骑猪']='骑猪去瓢:BAABKgAFFH8RAAMHAAYI3yFxCgCvAQAHAAYIcSFxCgCvAQAIAAQIjxxEEQAIAQAAAA==.',['魂体']='魂体三分:BAAAKgAFFAYIBAAAAA==.',['魔法']='魔法小龟:BAACKgAFFH8iAAMdAAgITB/PAQBxAgAdAAgITB/PAQBxAgAVAAQINxU/GwALAQAqAAQKfyYABB0ACAibI1wYAGICAB0ACAiMIFwYAGICABUABwi6H/UhAOYBAB8ABghEGnhfAO0AAAAA.',['鸣珩']='鸣珩:BAAAKgADCgMIAwAAAA==.',['鸭皇']='鸭皇归来:BAAAKgAFFAYIAgAAAA==.',['黑牛']='黑牛陆七八:BAAAKgAECgYIBwAAAA==.',['黑翎']='黑翎:BAABKgAFFH8cAAMbAAgIfSGTAgCqAgAbAAgIfSGTAgCqAgABAAEIAAALOAAAAAAAAA==.',['龙皇']='龙皇异次元:BAAAKgAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end