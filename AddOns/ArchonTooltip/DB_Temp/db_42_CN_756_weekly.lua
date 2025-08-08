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
 local lookup = {'Hunter-BeastMastery','DemonHunter-Havoc','DemonHunter-Vengeance','Shaman-Restoration','DeathKnight-Unholy','Paladin-Retribution','Mage-Frost','Shaman-Elemental','Evoker-Devastation','Evoker-Preservation','Druid-Guardian','Druid-Restoration','Druid-Balance','Warlock-Destruction','Warrior-Fury','Hunter-Marksmanship','Hunter-Survival','Monk-Mistweaver','Paladin-Protection','Mage-Fire','Priest-Discipline','Warrior-Arms','Monk-Brewmaster','Warlock-Affliction','Warlock-Demonology','DeathKnight-Blood','Priest-Shadow','Monk-Windwalker','Mage-Arcane','Priest-Holy','DeathKnight-Frost','Warrior-Protection','Paladin-Holy',}; local provider = {region='CN',realm='玛多兰',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aiilly:BAAAKgADCgQIBAAAAA==.',Ak='Akido:BAAAKgAECgYIBgAAAA==.',Al='Alexchow:BAAAKgAECggIEwAAAA==.',Am='Amon:BAAAKgADCgIIBAAAAA==.',Ar='Arale:BAABKgAFFH8IAAIBAAMIlAkRIAChAAABAAMIlAkRIAChAAAAAA==.',As='Asuna:BAAAKgAFFAgIBAAAAA==.',Ba='Bansheeoi:BAACKgAFFH8pAAICAAgIIh/wCQDuAQACAAgIIh/wCQDuAQAqAAQKfzcAAwIACAgUJZoFAPECAAIACAgUJZoFAPECAAMAAQgAAG57AAAAAAAA.Bansheeoo:BAAAKgAECggIEgAAAA==.',Be='Beowulf:BAAAKgAECgUIBQAAAA==.',Bi='Bigsmock:BAAAKgADCggICAAAAA==.Bilili:BAABKgAFFH8JAAICAAUI6iPAEwBcAQACAAUI6iPAEwBcAQAAAA==.',Cx='Cx:BAACKgAFFH8MAAIEAAQIChduFwC5AAAEAAQIChduFwC5AAAqAAQKf20AAgQACAgeJScGAMMCAAQACAgeJScGAMMCAAAA.',Da='Darkdk:BAAAKgADCggICAAAAA==.',Er='Erico:BAAAKgADCgUIBQAAAA==.',Fu='Fusing:BAABKgAFFH8FAAIFAAMITQpCFwCsAAAFAAMITQpCFwCsAAAAAA==.',Ha='Harlots:BAABKgAFFH8GAAIGAAYILBdGHACDAQAGAAYILBdGHACDAQAAAA==.',He='Hebe:BAABKgAECn8VAAIHAAgIsAlGGAAIAQAHAAgIsAlGGAAIAQAAAA==.Hermes:BAAAKgAFFAQIBAAAAA==.',Hi='Hilda:BAAAKgAECgcIEwAAAA==.',Im='Imperius:BAAAKgAECgQIBAAAAA==.',Kk='Kkabcdefghi:BAABKgAECn86AAIBAAgI7RfLEgD4AQABAAgI7RfLEgD4AQAAAA==.',Mf='Mfyc:BAAAKgAECgUIBQAAAA==.Mfydru:BAAAKgAECgUIBQAAAA==.Mfyf:BAAAKgAECgYICgAAAA==.Mfyw:BAAAKgAECgcIBgAAAA==.',Ne='Neverbekiled:BAAAKgAFFAYIBAAAAA==.',Pa='Parra:BAAAKgADCggICAAAAA==.',Po='Poweriful:BAAAKgAFFAMIAwAAAA==.',Re='Readtea:BAAAKgAECgIIAgAAAA==.',Rp='Rpman:BAAAKgAECgQIBAAAAA==.',Sa='Saints:BAABKgAFFH8HAAMDAAQILB2eAwAOAQADAAMILB2eAwAOAQACAAQI3hNQMQC5AAAAAA==.',Se='Sevenmangos:BAACKgAFFH80AAIEAAUIkyPlCACDAQAEAAUIkyPlCACDAQAqAAQKfzsAAwQACAhVIqURAGwCAAQACAhVIqURAGwCAAgACAi/CjZBAAUBAAAA.',Sh='Sheepknit:BAAAKgAFFAQIBAAAAA==.',Ti='Tidy:BAAAKgADCggICAAAAA==.Tinnyz:BAABKgAFFH8OAAMJAAQIzxwGDADtAAAJAAQIzxwGDADtAAAKAAMI6xgZBADUAAAAAA==.',Un='Unicorno:BAAAKgAECgEIAQAAAA==.',Ve='Verlassen:BAAAKgAECggIEAAAAA==.',Vo='Volaliy:BAAAKgADCgUIBQAAAA==.',Vr='Vrose:BAABKgAECn8ZAAQLAAgIPhI2EABJAQALAAcIqxI2EABJAQAMAAYIfgq5TQDVAAANAAEIrg8rwgA/AAAAAA==.',Wa='Warlocksoul:BAAAKgAECgYIBgAAAA==.',Wo='Woho:BAABKgAECn8bAAIOAAgIhB7RDQBCAgAOAAgIhB7RDQBCAgAAAA==.',Wu='Wuho:BAAAKgAECgYIDAAAAA==.',Ya='Yaho:BAAAKgADCggICAAAAA==.',Yo='Yoho:BAAAKgAECgYIBgAAAA==.',['一一']='一一妖妖:BAAAKgADCggICQAAAA==.',['一吨']='一吨乱射:BAAAKgAECgcIDgAAAA==.',['三五']='三五尊者:BAABKgAECn8bAAIGAAgIPRxpMwAxAgAGAAgIPRxpMwAxAgAAAA==.三五王牌:BAABKgAECn8vAAIPAAgI3Bu8CQATAgAPAAgI3Bu8CQATAgAAAA==.',['世界']='世界大聪明:BAAAKgAFFAUIAgAAAA==.',['丘八']='丘八比目泪牛:BAAAKgAECggICAAAAA==.',['中美']='中美:BAACKgAFFH8ZAAQQAAQIah9lDgB4AQAQAAQIah9lDgB4AQARAAIIcxMJAwCbAAABAAIIYgk5TQA9AAAqAAQKfxgAAxAACAgIHeMrAIsBABAABgghHuMrAIsBAAEABghIEAqfAOkAAAAA.',['为爱']='为爱嗜魔:BAAAKgADCgEIAQAAAA==.',['久久']='久久哥:BAACKgAFFH8GAAIBAAYIwhZvDwCBAQABAAYIwhZvDwCBAQAqAAQKf1cAAgEACAgTJIMJANYCAAEACAgTJIMJANYCAAAA.',['乖乖']='乖乖德:BAAAKgAECgUICAAAAA==.乖乖猎手:BAAAKgADCggICAAAAA==.',['九龙']='九龙先锋:BAAAKgADCggIDwAAAA==.',['云幕']='云幕遮:BAACKgAFFH8aAAISAAUIyRXcDQD2AAASAAUIyRXcDQD2AAAqAAQKfzIAAhIACAj6H5cOAHYCABIACAj6H5cOAHYCAAAA.',['云梦']='云梦泽:BAABKgAECn8aAAITAAgIvw3JLADzAAATAAgIvw3JLADzAAAAAA==.',['五夜']='五夜屠猪男:BAAAKgAECgEIAQAAAA==.',['亚瑟']='亚瑟王:BAAAKgAFFAMIAQAAAA==.',['人比']='人比黄瓜受:BAAAKgAECgIIAgAAAA==.',['伊瑟']='伊瑟琳语风:BAAAKgADCggICAAAAA==.',['传说']='传说中的白菜:BAAAKgAECggIDAAAAA==.传说中的花菜:BAAAKgAECgEIAQAAAA==.',['你妹']='你妹的联盟:BAAAKgADCgIIAgAAAA==.',['佩奇']='佩奇吃饱了:BAABKgAFFH8GAAIUAAYIuxWkDQBgAQAUAAYIuxWkDQBgAQAAAA==.',['依丶']='依丶然:BAAAKgADCggICAAAAA==.',['信仰']='信仰圣光吧:BAAAKgAFFAQIBAAAAA==.',['俺是']='俺是吗:BAAAKgAECgIIAgABKgAFFAcIBwAVAEgXAA==.',['偷拐']='偷拐抢骗:BAAAKgADCgEIAQAAAA==.',['元素']='元素玲玲:BAAAKgAECggICAABKgAFFAgIEAAEACIVAA==.',['八零']='八零九室:BAAAKgADCggICAAAAA==.',['冥月']='冥月:BAAAKgAECgIIAgAAAA==.',['冰封']='冰封之舞:BAAAKgADCgQIBAAAAA==.',['凤求']='凤求凰:BAABKgAFFH8MAAIGAAgIQRZwCQArAgAGAAgIQRZwCQArAgAAAA==.',['劣人']='劣人美屡:BAAAKgAECgQIBgAAAA==.',['勿相']='勿相忘:BAAAKgAFFAgIBAAAAA==.',['十一']='十一:BAAAKgADCgEIAQAAAA==.',['十无']='十无畏十:BAAAKgAECgQICAAAAA==.',['卖糖']='卖糖术神:BAABKgAFFH8VAAIOAAQIRCRKDACEAQAOAAQIRCRKDACEAQAAAA==.',['南河']='南河:BAAAKgAECgUIBQAAAA==.',['卷烟']='卷烟:BAAAKgADCgcIBwAAAA==.',['去年']='去年的红叶:BAABKgAECn8WAAMWAAgIqxWBHADPAQAWAAgI7xOBHADPAQAPAAYIbRfuMwBaAQAAAA==.',['叁叁']='叁叁两两:BAAAKgAECgYIBQAAAA==.',['又大']='又大又白:BAABKgAECn8fAAIXAAgIahhQCQC5AQAXAAgIahhQCQC5AQABKgAFFAgIBQATAKwgAA==.',['又白']='又白又大:BAAAKgAECgcIDQAAAA==.',['发狂']='发狂哥:BAAAKgADCgcIBwAAAA==.',['古谚']='古谚久:BAAAKgAECgcIBwAAAA==.',['吉安']='吉安那那:BAABKgAECn8fAAIFAAgI0iONFwBQAgAFAAgI0iONFwBQAgAAAA==.',['吕布']='吕布曰貂蝉丶:BAABKgAFFH8GAAIFAAMIbAr5OAC4AAAFAAMIbAr5OAC4AAAAAA==.',['啊吉']='啊吉:BAABKgAFFH8JAAQOAAYIRBAXGwAtAQAOAAYIRBAXGwAtAQAYAAEIjgy4GQBUAAAZAAEIXgL/GQBHAAAAAA==.',['啊多']='啊多给:BAAAKgAECgcIDAAAAA==.',['喵之']='喵之哀熵:BAAAKgAECggIDwAAAA==.',['喵咪']='喵咪酱:BAAAKgADCgYIBgAAAA==.',['喵姬']='喵姬咪:BAAAKgAECgYIDAAAAA==.',['四大']='四大名柱:BAACKgAFFH8kAAMIAAUI/RqdCgAiAQAIAAUI/RqdCgAiAQAEAAII0xnULgBVAAAqAAQKfyYAAwgACAiYIOIRAEQCAAgACAiYIOIRAEQCAAQACAhlHeJKAE8BAAAA.',['土猎']='土猎:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光战:BAABKgAFFH8GAAIGAAYI0R55GACZAQAGAAYI0R55GACZAQAAAA==.圣光永动机:BAAAKgAECgIIAgAAAA==.圣光闪耀我心:BAAAKgADCgEIAQAAAA==.',['基尔']='基尔加个蛋:BAAAKgADCgIIAwAAAA==.',['夏末']='夏末丶将至:BAABKgAFFH8XAAMTAAYIjBj8AwA0AQATAAYIjBj8AwA0AQAGAAQIxxJOXQC2AAABKgAFFAgIIQAaAP4VAA==.',['夏雨']='夏雨荷:BAAAKgAECggICAAAAA==.',['夜光']='夜光丶:BAABKgAECn8rAAMQAAgIrSH9DwBXAgAQAAgINh39DwBXAgABAAgIsR7qKABPAgAAAA==.',['夜的']='夜的第七章:BAABKgAECn8UAAIGAAYICB31dgCpAQAGAAYICB31dgCpAQAAAA==.夜的第柒章:BAACKgAFFH8GAAIZAAMIzg2DEgCtAAAZAAMIzg2DEgCtAAAqAAQKfxYAAw4ABwg0GPUSAHsBAA4ABwgLFfUSAHsBABkABggJGZMyABwBAAAA.',['大卫']='大卫高栢飞:BAAAKgAECgYIDQAAAA==.',['大雷']='大雷:BAAAKgADCgUIBQAAAA==.',['大龄']='大龄老人:BAAAKgAECgIIAgAAAA==.',['天堂']='天堂浪人:BAAAKgADCggIFQAAAA==.',['天灰']='天灰:BAABKgAFFH8SAAMOAAgIux69BwAUAgAOAAgIBBy9BwAUAgAYAAIIKCCrCwDOAAAAAA==.',['头顶']='头顶椰树:BAAAKgAECgYICAAAAA==.',['奈厄']='奈厄:BAAAKgAECgQIBgAAAA==.',['奈阿']='奈阿:BAABKgAFFH8HAAMBAAUI4xmlEABzAQABAAQI4xmlEABzAQAQAAEIAAA8WQAAAAAAAA==.',['奥术']='奥术师:BAAAKgAECgcIBwAAAA==.',['如果']='如果是龙也好:BAACKgAFFH8FAAIJAAUIwQ0HFACxAAAJAAUIwQ0HFACxAAAqAAQKfxsAAgkACAhPGsYcANUBAAkACAhPGsYcANUBAAEqAAUUCAgSAA0AayMA.',['家条']='家条:BAAAKgADCgIIAwAAAA==.',['小小']='小小无双:BAAAKgAECggIEwAAAA==.',['小我']='小我:BAABKgAECn8aAAMEAAgIEBI6UwBFAQAEAAgIEBI6UwBFAQAIAAcIyAjpXgB/AAAAAA==.',['小桂']='小桂头:BAAAKgAECgcIDgAAAA==.',['已经']='已经爱了好么:BAAAKgADCggIDgAAAA==.',['布雷']='布雷斯塔:BAAAKgAFFAEIAQAAAA==.',['帅的']='帅的那么过分:BAABKgAECn8dAAMMAAgIqRhVFwDmAQAMAAgIqRhVFwDmAQANAAIISwg7zwApAAAAAA==.',['年老']='年老色衰:BAAAKgAECgUIBQAAAA==.',['库提']='库提供:BAAAKgAECggICAAAAA==.',['彼岸']='彼岸烟火流年:BAAAKgAFFAQIBAAAAA==.',['惊艳']='惊艳之猎:BAABKgAFFH8UAAIBAAMIKhfpFgDYAAABAAMIKhfpFgDYAAAAAA==.惊艳如初:BAABKgAFFH8HAAIGAAMImhICbQCRAAAGAAMImhICbQCRAAAAAA==.',['慕丶']='慕丶丹:BAAAKgADCgQIBAAAAA==.',['我不']='我不会影遁:BAAAKgAECgcIEQAAAA==.',['我爱']='我爱一根柴柴:BAAAKgADCggICAAAAA==.',['我的']='我的猫很粘人:BAACKgAFFH8SAAMNAAQIayO2FwDfAAANAAQIayO2FwDfAAAMAAIIZg+iGAB4AAAqAAQKfzEAAg0ACAj6JCQIAOICAA0ACAj6JCQIAOICAAAA.',['把鉨']='把鉨壳给吓没:BAAAKgAECggICAAAAA==.',['掌管']='掌管猝死的神:BAAAKgAECgUIBQAAAA==.',['掏胃']='掏胃狂魔:BAAAKgADCgQIBAAAAA==.',['散华']='散华礼弥:BAABKgAECn8cAAIFAAgI4SL1FwBwAgAFAAgI4SL1FwBwAgAAAA==.',['无上']='无上正等正觉:BAAAKgAECgYIDwAAAA==.',['无双']='无双小小:BAAAKgAECgQIBgAAAA==.',['无小']='无小小:BAAAKgADCggICAAAAA==.',['明月']='明月照沟渠:BAAAKgADCggICAAAAA==.',['昔我']='昔我往矣:BAAAKgAFFAYIBAAAAA==.',['星玲']='星玲珑:BAACKgAFFH8cAAMNAAgIqRXJCAANAgANAAgIqRXJCAANAgAMAAgIjBIfBQDUAQAqAAQKfxYAAw0ABgjBGb1QAHUBAA0ABgjBGb1QAHUBAAwABgieFUU7ACcBAAAA.',['是俺']='是俺吗:BAABKgAFFH8HAAMVAAcISBcICgB3AQAVAAQIOR0ICgB3AQAbAAMI/Qm4HACfAAAAAA==.',['晴天']='晴天丶羽:BAAAKgADCgcIBwAAAA==.晴天玉:BAAAKgADCgMIAwAAAA==.晴天雨:BAAAKgAFFAQIBAAAAA==.',['暮光']='暮光救赎:BAACKgAFFH8aAAIGAAgI0xynBwBLAgAGAAgI0xynBwBLAgAqAAQKfzEAAgYACAhQJdIRAMQCAAYACAhQJdIRAMQCAAAA.',['曦丶']='曦丶晚秋月明:BAAAKgADCgIIAgAAAA==.',['曲终']='曲终人散:BAAAKgAECgYIDAAAAA==.',['月下']='月下无霜:BAAAKgAFFAgIBAAAAA==.',['月之']='月之灵魂:BAAAKgADCggICAAAAA==.',['木易']='木易石:BAAAKgADCgcIBwAAAA==.',['朵尔']='朵尔衮:BAAAKgAECgUIBQAAAA==.',['板栗']='板栗盾击:BAAAKgAECggIEQAAAA==.',['林飞']='林飞雪:BAAAKgADCgQIBAAAAA==.',['柰阿']='柰阿:BAAAKgAFFAQIBAAAAA==.',['栗山']='栗山酱未来:BAABKgAECn8bAAMDAAcIBhu0GwCcAQADAAcIBhu0GwCcAQACAAcIRg8VYwAbAQAAAA==.',['格德']='格德米斯:BAAAKgADCgMIAwAAAA==.',['桃李']='桃李春风:BAAAKgAECgUIBQAAAA==.',['樱雨']='樱雨绵绵:BAAAKgAECgIIAgAAAA==.',['橘彩']='橘彩星光:BAABKgAFFH8OAAIGAAgIxBv+BQBsAgAGAAgIxBv+BQBsAgAAAA==.',['歪嘴']='歪嘴龙王:BAAAKgAECggIDgAAAA==.',['毛毛']='毛毛小肥猪:BAAAKgAECgEIAQAAAA==.',['水晶']='水晶晶:BAAAKgAECggIDgAAAA==.',['沉沉']='沉沉:BAAAKgADCggICAAAAA==.',['法尼']='法尼瓦伦泰:BAAAKgAECgYIEgAAAA==.',['泪珠']='泪珠儿:BAAAKgAECgEIAQAAAA==.',['泰瑞']='泰瑞尔风行者:BAAAKgAECgQIBAAAAA==.',['温蕾']='温蕾萨:BAAAKgAECggIEQAAAA==.温蕾萨风行者:BAAAKgAECggICAAAAA==.',['漫步']='漫步一云端:BAABKgAECn8cAAMCAAgIPBF6TQBxAQACAAgIWQ56TQBxAQADAAgIcgvPNgDfAAAAAA==.',['灌汤']='灌汤水饺:BAAAKgADCgEIAQAAAA==.',['灬德']='灬德灬道灬:BAAAKgAECggIEAAAAA==.',['灬道']='灬道法自然灬:BAAAKgADCgcIBwAAAA==.',['炙热']='炙热圣光:BAABKgAFFH8GAAIGAAYIvRriIQBmAQAGAAYIvRriIQBmAQABKgAFFAgIFAAGALoRAA==.',['炜少']='炜少在此:BAAAKgAECgUICAAAAA==.',['無上']='無上正等正觉:BAAAKgAECgMIAwAAAA==.',['焰灵']='焰灵:BAAAKgAFFAQIBAAAAA==.',['爱之']='爱之煞:BAABKgAECn8WAAMcAAcIxBZUKwBNAQAcAAYIAxhUKwBNAQASAAYI4RBCSwAPAQAAAA==.',['爱的']='爱的魔力:BAABKgAFFH8GAAIdAAYI0xX7EABhAQAdAAYI0xX7EABhAQAAAA==.',['牧旻']='牧旻:BAABKgAFFH8SAAIbAAcIQBgHAgDDAQAbAAcIQBgHAgDDAQAAAA==.',['狐狸']='狐狸酱:BAAAKgADCggIDgAAAA==.',['王哥']='王哥哥诶:BAACKgAFFH8FAAITAAUIrCByCACCAQATAAUIrCByCACCAQAqAAQKfyIAAhMACAiCG1kOABQCABMACAiCG1kOABQCAAAA.',['王灬']='王灬小灬胖:BAABKgAFFH8LAAIBAAMIsRIiMADLAAABAAMIsRIiMADLAAAAAA==.',['珊蒂']='珊蒂影歌:BAAAKgAECggICAAAAA==.',['琥珀']='琥珀光:BAAAKgAECgMIAwAAAA==.',['甄夏']='甄夏琉:BAAAKgADCggICAAAAA==.',['白银']='白银之须:BAAAKgADCggICAAAAA==.',['百合']='百合愁:BAAAKgAECggICAAAAA==.',['盐州']='盐州小趴菜:BAAAKgAFFAQIBAAAAA==.',['神射']='神射手紫樱枫:BAAAKgAECgYIBgAAAA==.',['空酒']='空酒杯:BAAAKgAECgEIAQAAAA==.',['窄宽']='窄宽强:BAABKgAECn8aAAMFAAgIOx8zGABLAgAFAAgIOx8zGABLAgAaAAgI2xFCLwAaAQAAAA==.',['米龙']='米龙:BAABKgAECn8VAAMHAAcI3g5KTQAwAQAHAAcIFw1KTQAwAQAUAAYIewp6YQDsAAAAAA==.',['紫月']='紫月玲:BAAAKgADCgQIBAAAAA==.',['紫色']='紫色信仰:BAAAKgAECgcIBwAAAA==.紫色信念:BAABKgAECn8eAAMGAAgIeCJqHACmAgAGAAgIeCJqHACmAgATAAEICQS2awANAAAAAA==.紫色凤凰:BAAAKgADCgUIBwAAAA==.紫色堕落:BAAAKgADCggICQAAAA==.',['约翰']='约翰史密斯:BAACKgAFFH8LAAIXAAYIZxp8AgBOAQAXAAYIZxp8AgBOAQAqAAQKfxUAAxcACAjkFdsOAFMBABcACAjkFdsOAFMBABIABwgMDHxVAOUAAAAA.',['细雨']='细雨繁花:BAABKgAECn8sAAIeAAgIlBdmIwCtAQAeAAgIlBdmIwCtAQAAAA==.',['老烟']='老烟:BAAAKgADCggICAAAAA==.',['自摸']='自摸九条:BAAAKgADCgMIAwAAAA==.',['芙蓉']='芙蓉王源:BAAAKgAECggICAAAAA==.',['花仙']='花仙女:BAAAKgAECggIEQAAAA==.',['花火']='花火:BAAAKgAFFAQIBAAAAA==.',['英雄']='英雄归来:BAAAKgADCgQIBAAAAA==.',['茜舞']='茜舞飞扬:BAABKgAFFH8OAAMfAAQIcRcvAwDqAAAfAAQIgxIvAwDqAAAaAAQIcRfmEwCpAAAAAA==.',['莱弦']='莱弦:BAAAKgAECgcIDQAAAA==.',['萨其']='萨其玛:BAABKgAECn8dAAIEAAgIuQs+YQAHAQAEAAgIuQs+YQAHAQAAAA==.',['萨格']='萨格啦斯风语:BAAAKgAECggICAAAAA==.萨格斯蒙德:BAAAKgADCggICAAAAA==.',['萨琪']='萨琪玛:BAABKgAFFH8gAAMEAAgIQSH2AQBjAgAEAAgIQSH2AQBjAgAIAAYI9xZVBgCFAQAAAA==.',['蓝精']='蓝精龙:BAAAKgAECggICgAAAA==.',['蔚蓝']='蔚蓝星辰:BAAAKgAECggICAAAAA==.',['薄荷']='薄荷玲玲:BAAAKgADCggICAAAAA==.',['虾仁']='虾仁不虾仁:BAAAKgAECgEIAQAAAA==.',['蚩尤']='蚩尤:BAACKgAFFH8UAAIBAAYI1hMaEwBdAQABAAYI1hMaEwBdAQAqAAQKfysAAgEACAgKIRIaAJECAAEACAgKIRIaAJECAAAA.',['蛋刀']='蛋刀拿来吧:BAAAKgAECgYIEQAAAA==.',['蜡笔']='蜡笔小王子:BAAAKgADCgEIAQAAAA==.',['西神']='西神西神西神:BAACKgAFFH8SAAQHAAMIwCTUCwDPAAAdAAII+CNSJADRAAAHAAMIZiTUCwDPAAAUAAIIMSMSIAC1AAAqAAQKf0MABAcACAjJJhwBABgDAAcABwjCJhwBABgDABQABwhYJawTAIACAB0ABgh4JTUeAAECAAEqAAUUBQgVAA4ARCQA.',['詞不']='詞不达意丶:BAACKgAFFH8IAAIWAAgIdBXfAgBAAgAWAAgIdBXfAgBAAgAqAAQKfzAABBYACAhLFj0KAK4BABYACAgcFj0KAK4BAA8ACAgqDocyAGIBACAABgj0EMcRAPsAAAAA.詞不達意丶:BAACKgAFFH8UAAMGAAgIuhGFDQD5AQAGAAgIgBGFDQD5AQATAAgIswxUBgCFAQAqAAQKfxUAAwYACAinDzh3AGQBAAYACAinDzh3AGQBACEAAwiACfcbAHIAAAAA.',['豆芽']='豆芽菜丶:BAACKgAFFH8PAAIUAAYIiRarBQCqAQAUAAYIiRarBQCqAQAqAAQKfxsAAhQACAh7JR4OAKYCABQACAh7JR4OAKYCAAAA.',['贫僧']='贫僧略懂拳脚:BAAAKgAFFAQIBAAAAA==.',['踏星']='踏星行:BAAAKgAECgMIAwAAAA==.',['踏浪']='踏浪逐风:BAABKgAFFH8IAAISAAgIZBpzAwBDAgASAAgIZBpzAwBDAgAAAA==.',['运一']='运一:BAAAKgADCgEIAgAAAA==.',['运三']='运三:BAAAKgADCgEIAQAAAA==.',['运二']='运二:BAAAKgADCgEIAgAAAA==.',['运四']='运四:BAAAKgADCgEIAgAAAA==.',['运武']='运武:BAAAKgADCgEIAQAAAA==.',['远程']='远程法系:BAAAKgAECgEIAQAAAA==.',['遇见']='遇见狐狸:BAABKgAECn8wAAIeAAgI+hi8IgCxAQAeAAgI+hi8IgCxAQAAAA==.遇见黑铁:BAABKgAECn8XAAMSAAcIWQIscgCBAAASAAYIRwIscgCBAAAXAAEI9AEAAAAAAAAAAA==.',['邪气']='邪气笨叔叔:BAAAKgADCgQIBAAAAA==.',['银狐']='银狐猎:BAAAKgAECgYIBgAAAA==.',['阿兰']='阿兰若若:BAAAKgAECggIDwAAAA==.',['阿尔']='阿尔萨丝:BAAAKgADCgUIBgAAAA==.',['陆奥']='陆奥无幻:BAABKgAFFH8IAAIBAAQILw6fHwDZAAABAAQILw6fHwDZAAAAAA==.',['陆小']='陆小果:BAAAKgADCgIIAgAAAA==.',['雁城']='雁城雪:BAABKgAFFH8FAAIJAAUIMxxNEABcAQAJAAUIMxxNEABcAQAAAA==.',['雅兒']='雅兒贝德:BAAAKgAFFAIIAgAAAA==.',['雪花']='雪花茄子:BAAAKgAECggICAAAAA==.',['靑灬']='靑灬冥:BAAAKgAECgIIAgAAAA==.',['风月']='风月舞:BAAAKgADCgIIAgAAAA==.',['风的']='风的颜色:BAAAKgAECgQIBAAAAA==.',['飘零']='飘零:BAAAKgAFFAYIAgAAAA==.',['饭鱼']='饭鱼蛋:BAABKgAFFH8IAAIBAAQI1h0lFAD9AAABAAQI1h0lFAD9AAAAAA==.',['香织']='香织:BAACKgAFFH8qAAMOAAgILRi4EACHAQAOAAYIDhm4EACHAQAZAAII5xJHJwBKAAAqAAQKfxkAAw4ACAjzInkOAHUCAA4ACAjzInkOAHUCABgAAQh6DzVCAD4AAAAA.',['香辣']='香辣蓝莓皮:BAABKgAFFH8RAAIHAAMIrRcDEwDNAAAHAAMIrRcDEwDNAAAAAA==.',['高级']='高级妞妞:BAAAKgAECgQIBAAAAA==.',['鬼语']='鬼语者:BAABKgAECn8YAAIFAAgIfhifMgCsAQAFAAgIfhifMgCsAQAAAA==.',['麻小']='麻小虾:BAAAKgADCgcIBwAAAA==.',['麻辣']='麻辣冬瓜皮:BAAAKgADCgYIBgAAAA==.',['麽麽']='麽麽香:BAABKgAFFH8IAAIOAAgInhZtCQD1AQAOAAgInhZtCQD1AQAAAA==.',['黄河']='黄河之水:BAAAKgADCggICAAAAA==.',['默数']='默数繁华:BAABKgAECn8WAAMHAAgI9RkZHQDIAQAHAAgI9RkZHQDIAQAUAAEIcw0ToAAvAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end