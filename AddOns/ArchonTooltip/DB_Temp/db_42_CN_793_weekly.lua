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
 local lookup = {'Paladin-Protection','Paladin-Retribution','Priest-Discipline','Priest-Holy','Priest-Shadow','DeathKnight-Blood','Unknown-Unknown','DemonHunter-Vengeance','DemonHunter-Havoc','DeathKnight-Frost','Warrior-Fury','Mage-Frost','Mage-Fire','Mage-Arcane','DeathKnight-Unholy','Warrior-Arms','Warrior-Protection','Druid-Balance','Evoker-Devastation','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Destruction','Paladin-Holy','Rogue-Outlaw','Rogue-Assassination','Monk-Mistweaver','Druid-Guardian','Druid-Restoration','Monk-Windwalker','Druid-Feral','Monk-Brewmaster','Warlock-Affliction','Shaman-Restoration','Warlock-Demonology','Rogue-Subtlety','Shaman-Elemental','Shaman-Enhancement','Evoker-Preservation',}; local provider = {region='CN',realm='耐奥祖',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ae='Aerolite:BAAAKgAECggIEAAAAA==.',Al='Alten:BAABKgAECn8mAAMBAAgIPAxGEAASAQABAAgIPAxGEAASAQACAAgIBQctRwDqAAAAAA==.Always:BAABKgAFFH8JAAQDAAYI6w0TGQDJAAADAAMIGRMTGQDJAAAEAAUIKglVIADGAAAFAAEIZQAQMgAuAAAAAA==.',Ao='Aoao:BAABKgAFFH8FAAIEAAMICBHrEwChAAAEAAMICBHrEwChAAAAAA==.',Bi='Bige:BAAAKgAFFAQIBAAAAA==.Bitter:BAABKgAFFH8GAAIGAAYILQjpGADaAAAGAAYILQjpGADaAAAAAA==.',Cl='Clara:BAAAKgADCgIIAgABKgAECgcIBwAHAAAAAA==.Cloudcai:BAAAKgAECgYIBgAAAA==.',Cu='Cuticle:BAABKgAFFH8MAAIEAAQItR2MBgAFAQAEAAQItR2MBgAFAQAAAA==.',De='Deep:BAAAKgAECgEIAQAAAA==.',Di='Dierwo:BAAAKgADCgEIAQAAAA==.Directordk:BAAAKgAECgYIBgAAAA==.Directorms:BAAAKgAECgQIBAAAAA==.Directorqs:BAACKgAFFH8JAAICAAMI/BmcEgALAQACAAMI/BmcEgALAQAqAAQKfx4AAgIACAiMIVYgAJgCAAIACAiMIVYgAJgCAAAA.Distrust:BAAAKgAECgYIBwAAAA==.',Fo='Forestben:BAAAKgAECgEIAQAAAA==.',Ga='Gallagher:BAACKgAFFH8XAAMIAAQILQoOGACLAAAIAAQILQoOGACLAAAJAAMInAG4RABrAAAqAAQKfxwAAwgACAg/FPocAJwBAAgACAg/FPocAJwBAAkAAQhXBISkAB4AAAAA.',Gr='Grandpa:BAAAKgAECgYIDAAAAA==.',Ha='Haohaa:BAAAKgAFFAQIAQAAAA==.',Hd='Hdeyz:BAACKgAFFH8aAAIKAAQIRiHvBQAVAQAKAAQIRiHvBQAVAQAqAAQKfzQAAgoACAh6JR4DAL0CAAoACAh6JR4DAL0CAAAA.Hdyz:BAABKgAFFH8TAAICAAMIfh8uPAD9AAACAAMIfh8uPAD9AAAAAA==.',Ia='Iamchosen:BAABKgAFFH8QAAMDAAYISRxPCACbAQADAAYISRxPCACbAQAFAAMIbA93GwCLAAABKgAFFAgIGAADAOgeAA==.',Im='Imnoone:BAAAKgAECgEIAQAAAA==.',Ka='Kashatriya:BAAAKgAFFAgIBAAAAA==.',Kb='Kboardroller:BAAAKgADCgIIAgAAAA==.',Ku='Kuronii:BAAAKgAFFAgIAgAAAA==.',Lo='Lottery:BAABKgAFFH8IAAIBAAgIURvsAgAlAgABAAgIURvsAgAlAgAAAA==.',Mi='Minotaurs:BAAAKgAFFAQIBAABKgAFFAgICAALAHYKAA==.',Mo='Monikaa:BAABKgAECn8eAAMMAAgIFyUvBQDlAgAMAAgIFyUvBQDlAgANAAYIow1KVQAiAQAAAA==.Monikadk:BAAAKgAFFAQIBAAAAA==.Morteregina:BAAAKgAFFAIIAgAAAA==.',Na='Nandi:BAAAKgAFFAQIBAABKgAFFAgIIwAOAIglAA==.',Ni='Nicebody:BAABKgAFFH8HAAMPAAQIThf+DgD9AAAPAAQIThf+DgD9AAAGAAMIzwQ6MQBFAAAAAA==.',Or='Orangedemon:BAAAKgAECggIEwAAAA==.',Ot='Otco:BAABKgAFFH8GAAIMAAMIawv+HACcAAAMAAMIawv+HACcAAAAAA==.',Ov='Ov:BAAAKgAECggIEgAAAA==.',Pe='Peach:BAAAKgAECggIDwAAAA==.',Ps='Psychy:BAAAKgAECggICwAAAA==.',Sa='Sapagaagonie:BAACKgAFFH85AAQLAAgIvxD2EgAtAQALAAYIZBL2EgAtAQAQAAMIjQp4JwBTAAARAAIIvwLtCwBSAAAqAAQKfzMABAsACAjLGHQuAMwBAAsACAjlFnQuAMwBABAABwiBC6A1ABcBABEAAggtElQ3AGcAAAAA.',Sc='Scarlett:BAABKgAECn9aAAMJAAgIUCGKFQCFAgAJAAgIUCGKFQCFAgAIAAgIoxqJEAATAgABKgAFFAgIDgASAAkdAA==.',Sh='Sheng:BAABKgAFFH8IAAICAAgI2heKCAAlAgACAAgI2heKCAAlAgAAAA==.',Si='Sisyphus:BAACKgAFFH8eAAITAAQIsB8SGQD7AAATAAQIsB8SGQD7AAAqAAQKfyQAAhMACAgzHkoPAFUCABMACAgzHkoPAFUCAAAA.',So='Souryuuasuka:BAAAKgAECgUIBQAAAA==.',Sy='Sylvan:BAACKgAFFH8WAAMJAAQI1CIUHAAfAQAJAAQI1CIUHAAfAQAIAAQIPg7aCgChAAAqAAQKfyYAAwgACAgbG14gAH4BAAkACAh5GYVEAJYBAAgACAgzFF4gAH4BAAAA.',To='Topfive:BAAAKgAECgcIBwAAAA==.Topms:BAAAKgAFFAQIBAAAAA==.',Va='Vanéssa:BAACKgAFFH8KAAMIAAQIlRGvCwCYAAAJAAMI6xCkMAC8AAAIAAQILgyvCwCYAAAqAAQKfyoAAwgACAjYHFwRABgCAAgACAj4GlwRABgCAAkAAwjwDwuWAIgAAAEqAAUUBAgWAAkA1CIA.',Ve='Verysam:BAAAKgAFFAIIAgAAAA==.',Vi='Viczmick:BAAAKgAFFAIIAgAAAA==.Vitaminvc:BAAAKgAECgIIAgAAAA==.',Wi='Wilds:BAAAKgAECgYIDAAAAA==.',Xr='Xrwyda:BAABKgAECn8VAAMUAAgI0xiMIgDuAQAUAAgI0xiMIgDuAQAVAAIIbRCjrwBiAAAAAA==.',Za='Zandalarw:BAAAKgAECgUIBQAAAA==.',Zi='Ziyuzile:BAACKgAFFH8fAAIVAAcIoBx0CADpAQAVAAcIoBx0CADpAQAqAAQKfzQAAhUACAieJfwDANwCABUACAieJfwDANwCAAAA.',['一夜']='一夜知秋:BAAAKgAFFAgIBAAAAA==.',['一布']='一布衣神相一:BAAAKgAECgIIBAAAAA==.',['一熊']='一熊大一:BAAAKgADCgQIBAAAAA==.',['一脚']='一脚踩死你:BAAAKgAFFAIIBAAAAA==.',['一路']='一路天黑:BAAAKgAFFAEIAQAAAA==.',['不嘻']='不嘻嘻弗思:BAAAKgAFFAMIAwABKgAFFAQIHgATALAfAA==.',['丢那']='丢那咩鸡鳖:BAAAKgAECgEIAQAAAA==.',['两笑']='两笑一生:BAABKgAFFH8LAAIJAAYI5B4hCAA5AQAJAAYI5B4hCAA5AQAAAA==.',['两面']='两面三刀:BAAAKgADCggICAAAAA==.',['丨亡']='丨亡命灬:BAAAKgAECgUIBQAAAA==.',['丨朮']='丨朮丶:BAABKgAFFH8IAAIWAAgIWBZlBQBEAgAWAAgIWBZlBQBEAgAAAA==.',['中原']='中原一点红:BAABKgAECn8dAAMPAAgIyAqbbADXAAAPAAYIUQubbADXAAAGAAgI0waCMwC9AAAAAA==.',['丶再']='丶再见孙悟空:BAAAKgAECgIIAgAAAA==.',['丶酸']='丶酸菜土豆丝:BAAAKgAECgIIAgAAAA==.',['丶钱']='丶钱多多:BAABKgAFFH8OAAIPAAcIVR8rEQCSAQAPAAcIVR8rEQCSAQAAAA==.',['丶青']='丶青汁丶:BAAAKgADCgcIAwAAAA==.',['为啥']='为啥要我改名:BAABKgAFFH8GAAIMAAMIABOVCgDSAAAMAAMIABOVCgDSAAAAAA==.',['举杯']='举杯吧朋友:BAACKgAFFH8JAAIBAAMIOgElFABFAAABAAMIOgElFABFAAAqAAQKfxcABAIABwj6Fkt4AGEBAAIABwj6Fkt4AGEBABcABQhOB9pBAIYAAAEABwgaBaEaAHgAAAAA.',['丿墨']='丿墨筱兮:BAAAKgAECgYIBgAAAA==.',['丿灬']='丿灬浊酒壹壶:BAAAKgAFFAQIBAAAAA==.',['九眼']='九眼桥花魁:BAAAKgADCgYIBgAAAA==.',['乾坤']='乾坤道长:BAABKgAFFH8GAAIIAAQIEg97FACgAAAIAAQIEg97FACgAAAAAA==.',['了無']='了無所愛:BAAAKgAECgUIBwAAAA==.',['云朵']='云朵:BAABKgAFFH8UAAMBAAgI7BmLAwA4AgABAAgI7BmLAwA4AgAXAAQIORAMCQDLAAAAAA==.',['亡语']='亡语凋零:BAAAKgAECgEIAQAAAA==.',['仙儿']='仙儿:BAAAKgADCgYIBgAAAA==.',['仙剑']='仙剑李逍遥:BAAAKgAECggICQAAAA==.',['伊利']='伊利牛奶:BAAAKgAECgEIAQAAAA==.',['伊粒']='伊粒蛋:BAABKgAFFH8HAAMJAAMIzAbyHQCjAAAJAAMIkwbyHQCjAAAIAAIIQAeGIQBXAAAAAA==.',['伟大']='伟大的试验:BAABKgAFFH8GAAINAAYIIROODQBgAQANAAYIIROODQBgAQAAAA==.',['何似']='何似在人间:BAABKgAFFH8JAAIEAAMIgAbjLgCKAAAEAAMIgAbjLgCKAAAAAA==.',['佛山']='佛山赵子龙:BAABKgAFFH8XAAISAAUI1hveFQBqAQASAAUI1hveFQBqAQABKgAFFAgIKQABALkgAA==.',['你好']='你好帅:BAAAKgAECgYIBwAAAA==.你好美啊:BAABKgAFFH8IAAMYAAMIKwYOBgCEAAAYAAMIKwYOBgCEAAAZAAIIGgOgJgBpAAAAAA==.你好酷哟:BAAAKgAECgYIBwAAAA==.',['你看']='你看我硬不:BAABKgAFFH8FAAILAAMIvw0tIgDKAAALAAMIvw0tIgDKAAAAAA==.',['保底']='保底一斤半:BAABKgAFFH8IAAIaAAQIhhLIGwC/AAAaAAQIhhLIGwC/AAAAAA==.',['偷腻']='偷腻苦茶子:BAAAKgAECggIDAAAAA==.',['傲气']='傲气领牛:BAAAKgAFFAIIAgAAAA==.',['傷心']='傷心小栈:BAABKgAFFH8IAAICAAMIxQ4FWADBAAACAAMIxQ4FWADBAAAAAA==.',['元素']='元素馒头:BAAAKgADCggICAAAAA==.',['先天']='先天丨无极:BAAAKgADCgYICAAAAA==.',['光头']='光头才有杀气:BAAAKgAECgYIBgAAAA==.',['兜兕']='兜兕宫主:BAAAKgADCggICAAAAA==.',['兜兜']='兜兜打滴滴:BAAAKgADCgYIBgAAAA==.',['冰晶']='冰晶乱流:BAAAKgADCgIIAgAAAA==.',['冰美']='冰美式丶:BAAAKgAFFAMIAwAAAA==.',['冲跳']='冲跳两年半:BAABKgAFFH8LAAILAAMIpR16HQDeAAALAAMIpR16HQDeAAAAAA==.',['冷露']='冷露无声:BAAAKgAFFAgIAgAAAA==.',['准提']='准提道人:BAACKgAFFH8lAAMBAAQIfyOLEQD0AAACAAMIMCJgNQAVAQABAAQIKB6LEQD0AAAqAAQKfygAAwIACAgaJeIKAOgCAAIACAgaJeIKAOgCAAEABAhZJGwJAKABAAAA.',['凌烙']='凌烙風:BAABKgAFFH8IAAICAAgIFSDxBgBZAgACAAgIFSDxBgBZAgAAAA==.',['凌虚']='凌虚:BAABKgAECn8VAAICAAgI1RZJZgDOAQACAAgI1RZJZgDOAQAAAA==.',['凤朝']='凤朝阳:BAABKgAFFH8GAAIBAAYIlB7wBgCsAQABAAYIlB7wBgCsAQAAAA==.',['凤雏']='凤雏:BAAAKgADCgIIAgAAAA==.',['凯瑞']='凯瑞斯:BAAAKgADCgQIBAAAAA==.',['初初']='初初大魔王:BAAAKgAECgUIBQAAAA==.',['删灬']='删灬除:BAABKgAFFH8HAAINAAQIahj6GgDlAAANAAQIahj6GgDlAAABKgAFFAgIRwANADUlAA==.',['删除']='删除灬灬:BAAAKgAECgEIAQAAAA==.',['别摸']='别摸硬了:BAAAKgADCggICAAAAA==.',['别来']='别来恶心我丶:BAAAKgAFFAQIBAAAAA==.',['刹古']='刹古拉:BAAAKgAFFAMIBAAAAA==.',['削着']='削着苹果走:BAAAKgADCggIBgAAAA==.',['劉徳']='劉徳華:BAAAKgADCgUIBQAAAA==.',['劝君']='劝君酌:BAAAKgAFFAQIBAAAAA==.',['功夫']='功夫哈满:BAABKgAFFH8OAAIJAAgIBhp4CQD4AQAJAAgIBhp4CQD4AQAAAA==.功夫猫咪:BAABKgAFFH8OAAIaAAgITRaXBwC8AQAaAAgITRaXBwC8AQAAAA==.',['加里']='加里:BAABKgAFFH8JAAMJAAMIggu+GgC6AAAJAAMIggu+GgC6AAAIAAMILwMzIABgAAAAAA==.',['劣人']='劣人浮游:BAAAKgAECgIIAgAAAA==.',['助祭']='助祭:BAABKgAFFH8MAAMEAAQIYiCWDAACAQAEAAQIYiCWDAACAQAFAAQIqgJUIwBxAAAAAA==.',['勇剑']='勇剑斩天罡:BAAAKgAECgYIDQAAAA==.',['北北']='北北:BAAAKgAECgIIAgAAAA==.',['北尔']='北尔瓦娜斯:BAAAKgAFFAQIBAAAAA==.',['医生']='医生:BAAAKgAECggIEAAAAA==.',['医翻']='医翻都流口水:BAAAKgAECgUIAQAAAA==.',['十岁']='十岁玉米地丶:BAAAKgAECgMIAwAAAA==.',['十月']='十月十八:BAAAKgAECgUICAAAAA==.',['千年']='千年昏:BAABKgAFFH8HAAIZAAQIfh0cCQD8AAAZAAQIfh0cCQD8AAAAAA==.',['午夜']='午夜幽光:BAAAKgAECggIEwABKgAFFAgIUAASABcmAA==.',['南宫']='南宫布欧:BAAAKgADCgYIBgAAAA==.',['南方']='南方小土豆:BAAAKgADCgIIAgAAAA==.',['卡尔']='卡尔萨斯之子:BAAAKgAFFAIIAgAAAA==.',['叉烧']='叉烧啾啾:BAACKgAFFH8IAAMMAAMIZBsGEQDaAAAMAAMIZBsGEQDaAAAOAAEI4APCSAAuAAAqAAQKfyAAAwwACAikINQSAGgCAAwACAikINQSAGgCAA4AAQgqEKMtADoAAAAA.叉烧电电:BAAAKgAECgQICAAAAA==.叉烧行星:BAABKgAFFH8GAAISAAMIIxmaLwDVAAASAAMIIxmaLwDVAAAAAA==.',['发疯']='发疯式丶包包:BAAAKgAECgUIBwAAAA==.',['叕叒']='叕叒双又佛祖:BAAAKgAFFAYIAgAAAA==.',['口少']='口少口少:BAACKgAFFH80AAMbAAUI+xAhAwCTAAAbAAUI+xAhAwCTAAASAAEI2gd7MQA3AAAqAAQKfzMAAxsACAjOFh0NAIIBABsACAjOFh0NAIIBABwAAgipAdOOACYAAAAA.',['古尔']='古尔疍:BAAAKgADCgMIAwAAAA==.',['叫我']='叫我小陀螺:BAABKgAFFH8GAAMaAAYIYSVgCACrAQAaAAUIGyVgCACrAQAdAAEI9QSkJgAzAAAAAA==.',['名字']='名字真棒:BAAAKgADCgMIAwAAAA==.',['后羿']='后羿:BAABKgAFFH8FAAMUAAMIcBHiPQCBAAAUAAMIrAjiPQCBAAAVAAEIpRupVwBNAAAAAA==.',['吨吨']='吨吨噸:BAAAKgAFFAEIAQAAAA==.',['含沙']='含沙射影:BAAAKgADCgcIBwAAAA==.含沙猎影:BAAAKgAECgQIBAAAAA==.',['呵手']='呵手僞伊:BAAAKgAECgEIAQAAAA==.',['咏叹']='咏叹调:BAABKgAECn8cAAMCAAgIgBbTUgDFAQACAAgIgBbTUgDFAQABAAEIEARJawAOAAAAAA==.',['咕咕']='咕咕馒头:BAAAKgAECgQIBAAAAA==.',['咕噜']='咕噜灵波:BAAAKgAECgEIAQAAAA==.',['咖啡']='咖啡丶:BAAAKgAFFAMIAwAAAA==.咖啡丶玫瑰:BAACKgAFFH8WAAMFAAQI9R6PEAAAAQAFAAQI9R6PEAAAAQADAAII+ARPIQB1AAAqAAQKfykAAwUACAgqG/EXABoCAAUACAgqG/EXABoCAAMABAg9DY1yAHEAAAAA.咖啡喵:BAAAKgADCgQIBAAAAA==.',['咚大']='咚大一鸭梨:BAABKgAFFH8IAAIUAAgIpxvuAwBTAgAUAAgIpxvuAwBTAgAAAA==.',['哈斯']='哈斯加特:BAAAKgAECggICAAAAA==.',['哒哒']='哒哒撒:BAAAKgADCggIDAAAAA==.',['哞喵']='哞喵:BAACKgAFFH8TAAQeAAMI7AtQBQDHAAAeAAMIawtQBQDHAAASAAMIZgv0PAC0AAAcAAII0wKxHgBUAAAqAAQKfxgABRwACAjqDRY9APIAABwACAjqDRY9APIAAB4ABAhHE98eALgAABIAAgi/DpC5AE4AABsAAQiQEwQvADgAAAAA.哞喵完了:BAAAKgAFFAMIAwAAAA==.',['啊蕉']='啊蕉老师:BAACKgAFFH8PAAMPAAYIdCKECgDlAQAPAAYIdCKECgDlAQAGAAUIiQwHHADDAAAqAAQKfxgAAg8ACAhWI3AOAK0CAA8ACAhWI3AOAK0CAAEqAAUUCAgWAAsA2RQA.啊蕉老师之箭:BAABKgAFFH8OAAIUAAYIPyMtAQC4AQAUAAYIPyMtAQC4AQAAAA==.',['喵星']='喵星渔:BAABKgAECn8mAAMOAAgINyHXCQBCAgAOAAgIyRzXCQBCAgAMAAgI1x/WFwBBAgAAAA==.',['嗜魂']='嗜魂飚颲:BAAAKgAFFAIIAwAAAA==.',['嘟嘟']='嘟嘟:BAAAKgAECgYIBgAAAA==.',['噬丨']='噬丨魂:BAAAKgAFFAMIBAAAAA==.',['四拾']='四拾:BAABKgAFFH8HAAIfAAMIfgHPCgBTAAAfAAMIfgHPCgBTAAAAAA==.',['四系']='四系图腾:BAAAKgAECgcIDgAAAA==.',['国产']='国产绿巨人:BAAAKgAECggIDAAAAA==.',['国服']='国服第一美:BAAAKgADCgUIBQAAAA==.',['圣僧']='圣僧:BAAAKgAECgIIAgAAAA==.',['圣光']='圣光丨一凡:BAACKgAFFH8pAAMBAAgIuSDiAwAnAgABAAgIdh/iAwAnAgACAAUIAyPXGgCLAQAqAAQKfy0AAwIACAgBJjcMAOgCAAIACAgBJjcMAOgCAAEAAQguDkZfACkAAAAA.',['圣骑']='圣骑与菊魔:BAACKgAFFH8eAAICAAQIDyBWNgARAQACAAQIDyBWNgARAQAqAAQKfyUAAwIACAg2IYMxAFwCAAIACAg2IYMxAFwCAAEAAwgzDchRADsAAAAA.',['地尔']='地尔硫卓:BAABKgAFFH8GAAIWAAYIIhlOEQCBAQAWAAYIIhlOEQCBAQAAAA==.',['地狱']='地狱大酋长:BAAAKgAFFAEIAgAAAA==.地狱金鳞使者:BAAAKgADCggIEAAAAA==.地狱骑士:BAAAKgADCggICAAAAA==.',['堕天']='堕天使小勋勋:BAAAKgADCgQIBAAAAA==.',['堵灵']='堵灵伐灵光:BAAAKgADCggIDQAAAA==.',['夏曰']='夏曰牧歌丶:BAAAKgAECgYIBgAAAA==.',['外乡']='外乡人阿皮:BAAAKgAFFAgIBAAAAA==.',['外太']='外太空滴星星:BAABKgAFFH8MAAMWAAgIDBRhCAAJAgAWAAgIhhNhCAAJAgAgAAQIVgwHDgDFAAAAAA==.',['多拉']='多拉贡波鲁:BAABKgAFFH8IAAIEAAgIxAzVBgCTAQAEAAgIxAzVBgCTAQAAAA==.',['夜里']='夜里夫假面:BAAAKgAECgcICQAAAA==.',['大地']='大地之环:BAABKgAFFH8HAAIhAAMIghFoHACXAAAhAAMIghFoHACXAAAAAA==.',['大壮']='大壮:BAAAKgADCgQIBAAAAA==.',['天上']='天上太白仙:BAABKgAFFH8IAAICAAgI+BABCgAHAgACAAgI+BABCgAHAgAAAA==.',['天琊']='天琊:BAAAKgAECgYIBgAAAA==.',['天空']='天空丨元素:BAAAKgADCgQIBAAAAA==.',['天者']='天者一一怒风:BAAAKgAFFAEIAQAAAA==.',['太原']='太原街大地红:BAAAKgAFFAQIBAAAAA==.太原街大礼炮:BAAAKgADCgQIBAAAAA==.',['奅烦']='奅烦奘指头:BAABKgAFFH8IAAMRAAMIsgkBEAB/AAARAAMIsgkBEAB/AAAQAAEIUwEwHgAqAAAAAA==.',['奇异']='奇异博士:BAABKgAFFH8KAAQiAAMIewh6HgBpAAAWAAMIUgjXIgBrAAAiAAII8gV6HgBpAAAgAAEISwJwKAAlAAAAAA==.',['奔驰']='奔驰的小野马:BAAAKgAECgMIAwAAAA==.',['奶不']='奶不上我就跑:BAAAKgAFFAMIAwAAAA==.',['奶潮']='奶潮链接全开:BAABKgAFFH8GAAIhAAQIKwX+PgCMAAAhAAQIKwX+PgCMAAAAAA==.',['奶白']='奶白龙弟弟:BAAAKgAFFAMIAwAAAA==.',['好人']='好人岁彬:BAAAKgAECggICQAAAA==.',['妖刀']='妖刀姬:BAAAKgAECgQIBAAAAA==.',['威化']='威化饼:BAAAKgADCggICAABKgAFFAIIAwAHAAAAAA==.',['娘每']='娘每晚进我房:BAAAKgADCgYIBgAAAA==.',['嫩哆']='嫩哆哆:BAABKgAFFH8IAAIJAAQIBRoPHgDKAAAJAAQIBRoPHgDKAAAAAA==.',['孙半']='孙半城:BAABKgAECn8UAAIBAAgIkRNZGwCCAQABAAgIkRNZGwCCAQABKgAFFAgIDgASAAkdAA==.',['孙门']='孙门弄换:BAABKgAECn8gAAMPAAgI+xXlCgDZAQAPAAgI+xXlCgDZAQAGAAgIAQwSJwARAQABKgAFFAgIDgASAAkdAA==.',['安兹']='安兹乌尔恭:BAAAKgAECgIIAgAAAA==.',['定逸']='定逸师太:BAABKgAFFH8IAAMEAAQI6A/ODQDNAAAEAAQI6A/ODQDNAAADAAQIRwgvFAC9AAAAAA==.',['富婆']='富婆快乐人:BAABKgAECn9CAAMVAAgIlyEmGwCMAgAVAAgIlyEmGwCMAgAUAAgINxx3DAAJAgAAAA==.',['寒树']='寒树栖鸦:BAABKgAFFH8HAAMjAAYIug0rAwD3AAAjAAMIAhMrAwD3AAAYAAQIYAazBwCQAAAAAA==.',['寒风']='寒风依依:BAAAKgAECggICgAAAA==.',['小小']='小小丶劣人:BAABKgAFFH8RAAMVAAgI0R1mBACRAQAUAAgIoRvIBAA0AgAVAAUIEB1mBACRAQAAAA==.小小女巫:BAAAKgAECgQIDgAAAA==.',['小布']='小布:BAAAKgAFFAgIAgABKgAFFAgIJQAgACEcAA==.',['小拳']='小拳拳砸你:BAAAKgADCgMIAwAAAA==.',['小栈']='小栈:BAAAKgAECgEIAQAAAA==.',['小点']='小点声我恶魔:BAABKgAFFH8IAAIIAAgIGQjwAwBiAQAIAAgIGQjwAwBiAQAAAA==.',['小白']='小白在哪里:BAAAKgADCgQIBAAAAA==.',['小结']='小结子瘦骨骨:BAAAKgAFFAMIAwAAAA==.',['小舞']='小舞:BAABKgAECn8UAAICAAgIfCCGJwBiAgACAAgIfCCGJwBiAgAAAA==.',['小花']='小花宝:BAAAKgAFFAYIBAABKgAFFAgIDAAOACITAA==.',['小萌']='小萌主:BAABKgAFFH8KAAIhAAgIBxytAADjAQAhAAgIBxytAADjAQAAAA==.',['小萝']='小萝卜头:BAAAKgADCgEIAQAAAA==.',['小落']='小落大叶:BAACKgAFFH8dAAICAAUIoyH6JgBMAQACAAUIoyH6JgBMAQAqAAQKfygAAgIACAiAJmQEAA4DAAIACAiAJmQEAA4DAAAA.',['小诸']='小诸葛佩奇:BAAAKgAFFAIIAwAAAA==.',['小铁']='小铁蛋:BAAAKgAECgUIBwAAAA==.',['少冰']='少冰七分甜:BAABKgAFFH8GAAIDAAYIIxa7CgBqAQADAAYIIxa7CgBqAQAAAA==.',['巴巴']='巴巴托斯:BAACKgAFFH8UAAMQAAgIjRwzBAAjAQAQAAcIgR8zBAAjAQALAAMIBRBJJgBXAAAqAAQKfxQAAhAACAjFF6cVAAkCABAACAjFF6cVAAkCAAAA.',['巴扎']='巴扎巴扎黑:BAABKgAFFH8JAAIPAAMIggbZPQCmAAAPAAMIggbZPQCmAAAAAA==.',['布兰']='布兰卡:BAAAKgADCggICwAAAA==.',['布鲁']='布鲁斯特蓝翔:BAAAKgAFFAIIAgAAAA==.',['希雅']='希雅:BAAAKgAECgUIBQAAAA==.',['幻胖']='幻胖:BAAAKgAECgcICwAAAA==.',['幼蛾']='幼蛾:BAABKgAFFH8TAAIZAAgIPBlyBQA4AgAZAAgIPBlyBQA4AgAAAA==.',['幽蓝']='幽蓝紫月:BAACKgAFFH8jAAMUAAQIiBNFHACLAAAUAAQIrQ1FHACLAAAVAAIIYg3iOACFAAAqAAQKfy4AAxQACAiZIqQaACQCABQACAihHKQaACQCABUABgi4IOVWAKwBAAAA.',['廸廸']='廸廸:BAAAKgADCggIEAAAAA==.',['弓虽']='弓虽口阿弓虽:BAABKgAFFH8LAAIJAAQIvBLvKQDPAAAJAAQIvBLvKQDPAAABKgAFFAgIKQABALkgAA==.',['张二']='张二牛:BAACKgAFFH8OAAISAAgICR1BBQBwAgASAAgICR1BBQBwAgAqAAQKfzcAAxIACAizJLoLAMcCABIACAizJLoLAMcCABwAAQg1HLFpAFAAAAAA.',['张天']='张天爱:BAABKgAFFH8OAAMZAAYIIhWjDACDAQAZAAYIIhWjDACDAQAjAAIILxlxBgCIAAAAAA==.',['弯弓']='弯弓馒头:BAAAKgAECgUIBQAAAA==.',['影之']='影之旺财:BAAAKgAECgUIBQAAAA==.',['彼岸']='彼岸花笑:BAAAKgAECgEIAQAAAA==.',['微笑']='微笑的蒂尼沙:BAAAKgADCgMIAwAAAA==.',['德德']='德德戚戚:BAAAKgAFFAQIBAAAAA==.',['德才']='德才兼备灬:BAACKgAFFH8qAAMcAAgI6SCdAgA6AgAcAAcI6SCdAgA6AgASAAIIcg9dXgA9AAAqAAQKfy4AAxwACAhoJYoDANICABwACAhoJYoDANICABIAAQj1GQTHAEgAAAAA.',['德永']='德永生:BAAAKgAECggIEgAAAA==.',['恐怖']='恐怖萝莉:BAABKgAFFH8GAAIgAAYIGBrTAgB0AQAgAAYIGBrTAgB0AQAAAA==.恐怖黑洞人:BAAAKgAECgQIBQAAAA==.',['恶魔']='恶魔的套子:BAAAKgAECgIIAgAAAA==.',['恶龙']='恶龙咆哮丶:BAAAKgAFFAIIAgAAAA==.恶龙咆哮丶丶:BAAAKgAECgYIBQAAAA==.',['悍匪']='悍匪毛哥:BAAAKgAECgMIAwAAAA==.',['悲伤']='悲伤小调:BAAAKgAECgEIAQAAAA==.',['情况']='情况不妙:BAAAKgAFFAYIAgAAAA==.',['想喝']='想喝冰阔落:BAAAKgAECgYICwAAAA==.',['慕雨']='慕雨丶夜:BAABKgAFFH8dAAMBAAgI/BypCAB9AQABAAgI5xGpCAB9AQACAAQIaiRgJABZAQAAAA==.',['戀仩']='戀仩孤獨:BAAAKgAECgEIAQAAAA==.',['成功']='成功劣人:BAAAKgAECggIEAAAAA==.',['我只']='我只会飞:BAABKgAFFH8FAAMIAAMIdBAiEwCqAAAIAAMIdBAiEwCqAAAJAAIIMAPiRQBkAAAAAA==.',['我在']='我在后面掩护:BAABKgAECn8YAAICAAgIlCSdEQDFAgACAAgIlCSdEQDFAgAAAA==.',['我没']='我没蓝了:BAAAKgAFFAMIBAAAAA==.',['我爱']='我爱罗:BAAAKgAECgMIAwAAAA==.',['战无']='战无霜:BAACKgAFFH8aAAMRAAQI4AooDwCGAAARAAQIpQooDwCGAAALAAIIHQjxLwB6AAAqAAQKf0cAAhEACAhYFdUYAHcBABEACAhYFdUYAHcBAAAA.',['战皇']='战皇:BAAAKgAECgEIAQAAAA==.',['手留']='手留余香:BAABKgAECn8qAAMKAAgI2huhBgAgAgAKAAgI2huhBgAgAgAPAAYIBgovfgDpAAAAAA==.',['扬尼']='扬尼斯:BAACKgAFFH8LAAILAAMIzQd7KgCaAAALAAMIzQd7KgCaAAAqAAQKfyYAAgsACAg6EXAtANEBAAsACAg6EXAtANEBAAAA.',['抵御']='抵御抛笑:BAAAKgADCgQIBAAAAA==.',['指尖']='指尖伴流沙丶:BAAAKgAECggICAAAAA==.',['挥翅']='挥翅膀的爷们:BAAAKgAFFAMIAwAAAA==.',['排骨']='排骨:BAAAKgAECggICAAAAA==.',['撒满']='撒满鸡虱:BAABKgAFFH8PAAMkAAMIcw/nFQDDAAAkAAMIcw/nFQDDAAAlAAEIEwY9GgBAAAAAAA==.',['撞死']='撞死四只鸡:BAAAKgAECgYICwAAAA==.',['放弃']='放弃昨天:BAABKgAECn8YAAICAAgIuxS3YQDYAQACAAgIuxS3YQDYAQAAAA==.',['敲个']='敲个锤子:BAAAKgADCgIIAgAAAA==.',['无尽']='无尽的星空:BAAAKgAECgYIBgAAAA==.',['无情']='无情后妈:BAABKgAFFH8GAAICAAYIRg18FABWAQACAAYIRg18FABWAQABKgAFFAgICAAhAO0XAA==.',['无敌']='无敌琪琪:BAAAKgAECggIEAAAAA==.',['无间']='无间小玲玲:BAACKgAFFH8KAAMhAAMIkxRzLADFAAAhAAMIkxRzLADFAAAkAAEI4QGYKgAtAAAqAAQKfxkAAiEACAg5H8IVAEYCACEACAg5H8IVAEYCAAAA.',['日籽']='日籽:BAAAKgADCgMIAwAAAA==.',['时星']='时星星:BAAAKgAECgYIBwAAAA==.',['明月']='明月兮兮:BAAAKgAECgIIAwAAAA==.',['星枢']='星枢呈瑞:BAACKgAFFH8NAAMZAAMIxxRaCQD6AAAZAAMIxxRaCQD6AAAjAAEIfAg0EgBAAAAqAAQKfxoAAxkACAgnGK0cAJ0BABkABggVGa0cAJ0BACMABgimD+8eACABAAAA.',['星诚']='星诚:BAABKgAFFH8IAAMUAAgI/iDWCQC5AQAUAAcI/iDWCQC5AQAVAAEIAAD4VAAAAAAAAA==.',['星貘']='星貘:BAAAKgAFFAQIBAAAAA==.',['星辰']='星辰坠入深海:BAACKgAFFH8xAAIGAAQITyJyBwAdAQAGAAQITyJyBwAdAQAqAAQKfz0ABAYACAgDJLIEALcCAAYACAgDJLIEALcCAA8ABgj3D21sAB8BAAoAAwh9F6smAKEAAAAA.星辰小七:BAAAKgAECgQIBAAAAA==.星辰小飒:BAAAKgAECgQIBgAAAA==.',['春风']='春风十里:BAAAKgAECgIIAgAAAA==.',['晚上']='晚上好:BAABKgAECn8dAAMWAAgIhCBACwBgAgAWAAgIpR9ACwBgAgAiAAQIJx21FgDsAAABKgAFFAgIEQAFALAcAA==.',['暗语']='暗语丶:BAAAKgAECgYIBgAAAA==.',['暧牧']='暧牧之心:BAAAKgAFFAQIBAAAAA==.',['暮雨']='暮雨而桐:BAAAKgAFFAQIBAAAAA==.',['暴力']='暴力牛牛:BAAAKgAECggIEwAAAA==.',['暴走']='暴走呵呵哒:BAAAKgADCggIEAAAAA==.暴走的小宝:BAAAKgAECgYIBwAAAA==.暴走的小柒:BAACKgAFFH8FAAMCAAIIMw+zPgCKAAACAAIISg2zPgCKAAABAAEIDRDcGAA2AAAqAAQKfyYAAwIACAhcFn1mAI8BAAIABwg5GX1mAI8BAAEAAwhpCiRIAG4AAAAA.',['月光']='月光莫里亚:BAAAKgAECgUIBQAAAA==.',['望安']='望安:BAAAKgAECgEIAQAAAA==.',['朝阳']='朝阳吴彦祖:BAAAKgAFFAYIAQAAAA==.',['来抛']='来抛洗晶:BAAAKgAFFAQIBAAAAA==.',['果汁']='果汁糖:BAAAKgAECggIEAABKgAFFAIIAwAHAAAAAA==.',['柚子']='柚子:BAAAKgADCgEIAQAAAA==.',['柚柚']='柚柚:BAAAKgAECgEIAQAAAA==.',['格温']='格温德林:BAAAKgAFFAIIAgABKgAFFAgIFAABAOwZAA==.',['桃谷']='桃谷绘理香:BAABKgAFFH8HAAIhAAQIBQyGFQDPAAAhAAQIBQyGFQDPAAABKgAFFAgICgAhAAccAA==.',['梅克']='梅克拉舞:BAABKgAFFH8IAAMGAAQI/x++EQAVAQAGAAQI/x++EQAVAQAPAAMInQRjHgBjAAAAAA==.',['梅比']='梅比斯:BAAAKgAFFAgIBAAAAA==.',['梦喃']='梦喃:BAABKgAFFH8IAAMXAAQI2xRnDADmAAAXAAQI2xRnDADmAAACAAIIKBd5OQCWAAAAAA==.',['梧桐']='梧桐利威尔:BAABKgAECn8qAAIJAAgI4RohHQAaAgAJAAgI4RohHQAaAgAAAA==.',['森林']='森林格格污丶:BAAAKgAECgIIAgAAAA==.',['樱空']='樱空桃:BAAAKgAFFAYIBAAAAA==.',['檸尛']='檸尛檬灬:BAAAKgAECggIDQAAAA==.',['欧皇']='欧皇小奶牛:BAAAKgAECgYIBgAAAA==.',['正直']='正直小郎君:BAAAKgAECggICAAAAA==.',['此君']='此君非猫:BAAAKgADCggICAAAAA==.',['武浅']='武浅静:BAAAKgAECggICAAAAA==.',['歧路']='歧路唱离歌:BAAAKgAFFAEIAQAAAA==.',['死亡']='死亡纏繞:BAEBKgAFFH8IAAQWAAYI5R74DgCgAQAWAAYI5R74DgCgAQAiAAEIyx1oEQBeAAAgAAEIVhy/GABcAAABKgAFFAgIBgAlAK4TAA==.',['殺法']='殺法果断:BAACKgAFFH8FAAMMAAMIMAbDGABxAAAMAAIIHQnDGABxAAANAAIIegAWPABEAAAqAAQKfx0AAw0ACAgtFfk2ALoBAA0ACAi5Efk2ALoBAAwABgheGnVEAFUBAAAA.',['殿堂']='殿堂级追梦人:BAAAKgAECgIIAgAAAA==.',['每天']='每天做丝帕:BAABKgAFFH8MAAMEAAQItR+BBgAGAQAEAAQIhxuBBgAGAQADAAQIkRUQDgDmAAAAAA==.',['民以']='民以食为天:BAAAKgAFFAgIBAAAAA==.',['水有']='水有意:BAAAKgAECgcIBwAAAA==.',['永远']='永远的圣光:BAAAKgAFFAIIAgAAAA==.',['江南']='江南:BAAAKgAECggIDwAAAA==.',['沉默']='沉默星河:BAABKgAECn8VAAMkAAcIWBeJMgB3AQAkAAcIWBeJMgB3AQAhAAYIywSciwCoAAABKgAFFAgIDwAlAC4bAA==.',['法不']='法不朔及既往:BAAAKgAECggICAAAAA==.',['法力']='法力风暴:BAABKgAECn8ZAAIMAAgIMiP+BgC9AgAMAAgIMiP+BgC9AgAAAA==.',['法外']='法外无情:BAABKgAFFH8HAAIOAAcIAQpkDACJAQAOAAcIAQpkDACJAQAAAA==.',['泡老']='泡老板:BAABKgAFFH8JAAICAAgIZhdWDQD7AQACAAgIZhdWDQD7AQAAAA==.',['洛尔']='洛尔奇:BAAAKgAECgcICQAAAA==.',['流影']='流影照明妃:BAAAKgAECggICAAAAA==.',['浦东']='浦东丨少龙:BAAAKgAFFAIIAgAAAA==.',['浮士']='浮士唐红艳煞:BAAAKgAFFAgIBAAAAA==.',['液态']='液态史莱姆:BAAAKgAECgMIAwAAAA==.',['淡淡']='淡淡浮云:BAAAKgADCgYIBgAAAA==.淡淡的疼:BAAAKgADCggIBgAAAA==.',['深夜']='深夜:BAABKgAFFH8OAAMSAAQIOCLkCwAQAQASAAQIOCLkCwAQAQAcAAQIRQlPEACyAAABKgAFFAgIJQAgACEcAA==.深夜召唤人:BAACKgAFFH8lAAQgAAgIIRzGAgAiAQAgAAQISiHGAgAiAQAWAAYI9hrDCAAeAQAiAAMIECTaEQCxAAAqAAQKfxsABBYACAhyJQ4GAMMCABYACAjaIw4GAMMCACAABghBIgwIAPEBACIAAQjuJCVlAGkAAAAA.深夜熊喵人:BAABKgAECn8gAAMaAAgIwRnyEQAIAgAaAAgIwRnyEQAIAgAdAAcIyBLzKABcAQABKgAFFAgIJQAgACEcAA==.深夜赶尸人:BAABKgAECn8bAAMPAAgI0heQKgDTAQAPAAgI0heQKgDTAQAGAAgIaQW4OwDTAAABKgAFFAgIJQAgACEcAA==.',['清珑']='清珑琐儿:BAAAKgADCggICAAAAA==.',['清羽']='清羽:BAAAKgAECgIIAgAAAA==.',['渔小']='渔小牧:BAAAKgAECgQICAAAAA==.',['湾仔']='湾仔之火车神:BAABKgAFFH8IAAIUAAMIqQh+OACUAAAUAAMIqQh+OACUAAAAAA==.',['满目']='满目星河:BAAAKgAFFAIIAgAAAA==.',['漆黑']='漆黑眼眸:BAAAKgADCgUICAAAAA==.',['漠雨']='漠雨晚歌:BAAAKgAECggIBgAAAA==.',['灌汤']='灌汤牛肉包:BAAAKgAECgQIBAAAAA==.',['火山']='火山林风:BAAAKgAECgQICAAAAA==.',['灬丫']='灬丫丫灬:BAAAKgAFFAcIBAAAAA==.',['灬离']='灬离殇灬:BAABKgAFFH8IAAIDAAgISA/+BADzAQADAAgISA/+BADzAQAAAA==.',['灬萌']='灬萌牙牙灬:BAABKgAFFH8NAAMOAAgIuQ78CgC7AQAOAAcI4Q78CgC7AQANAAYIZwsxEABEAQAAAA==.',['灰烬']='灰烬佐德尔:BAABKgAFFH8YAAMPAAgIBh03AwBwAgAPAAgIJhw3AwBwAgAGAAgI/xSOAwDjAQAAAA==.',['灵羽']='灵羽丶:BAAAKgAECgEIAQAAAA==.',['炮灰']='炮灰四系飞舞:BAACKgAFFH8yAAQSAAYIFxdrCQAjAQASAAUI5RprCQAjAQAbAAIIfBafAwCCAAAcAAMI8QKoFgBLAAAqAAQKf1QAAxIACAjvIh4OALYCABIACAjvIh4OALYCABsACAgtGkQLAPQBAAAA.炮灰练不动:BAAAKgADCgQIBAAAAA==.炮灰飞不动:BAAAKgAFFAMIAwAAAA==.',['烟花']='烟花易冷丶:BAABKgAFFH8HAAIUAAcI0xZFEwBIAQAUAAcI0xZFEwBIAQAAAA==.',['烬锋']='烬锋无赦:BAAAKgAECgUIBQAAAA==.',['然鹅']='然鹅:BAAAKgADCggICAAAAA==.',['爱喝']='爱喝冰阔落:BAAAKgAFFAEIAQAAAA==.',['爱小']='爱小南:BAAAKgAFFAMIBAAAAA==.',['爱德']='爱德华月渎:BAABKgAFFH8IAAIRAAgI5QcPBABWAQARAAgI5QcPBABWAQAAAA==.',['爱心']='爱心唤魔:BAAAKgADCgMIAwAAAA==.爱心嚒嚒:BAAAKgADCgcIBwAAAA==.爱心猎手:BAAAKgAECgcIBwAAAA==.爱心血魔:BAAAKgADCggICQAAAA==.爱心骑士:BAAAKgADCggIEAAAAA==.',['爱斯']='爱斯普莱索:BAAAKgAFFAIIAgAAAA==.',['牛三']='牛三宝:BAAAKgADCgQIBAAAAA==.',['牛奶']='牛奶糖:BAAAKgAFFAIIAwAAAA==.',['牛妞']='牛妞立大功:BAAAKgAECgYIDAAAAA==.',['牛氓']='牛氓:BAAAKgADCgEIAQAAAA==.',['牛舌']='牛舌糖:BAAAKgADCgIIAgABKgAFFAIIAwAHAAAAAA==.',['牛蹄']='牛蹄:BAABKgAECn8dAAMcAAgIeRERJwBtAQAcAAgIeRERJwBtAQASAAgISA/eUgBmAQAAAA==.',['犄角']='犄角有杀气:BAAAKgAFFAQIBAAAAA==.',['犹大']='犹大:BAABKgAFFH8GAAISAAYIzhROFQBvAQASAAYIzhROFQBvAQAAAA==.',['狂燊']='狂燊:BAAAKgAECgUIBQABKgAFFAgIJQAgACEcAA==.',['狂魔']='狂魔骑士:BAAAKgAFFAEIAQAAAA==.',['狐小']='狐小柒:BAAAKgAFFAQIBAAAAA==.',['狼儿']='狼儿:BAAAKgAECgcIAQAAAA==.',['猫德']='猫德:BAAAKgAECgcIDAAAAA==.',['猫猫']='猫猫牛:BAAAKgAECgQIBAAAAA==.',['玛卡']='玛卡巴卡:BAABKgAFFH8IAAIJAAQIKAxwGwDXAAAJAAQIKAxwGwDXAAAAAA==.',['玥玥']='玥玥大月饼:BAACKgAFFH8QAAIUAAQIDx6ABwAKAQAUAAQIDx6ABwAKAQAqAAQKfx8AAxUABwhmIGctAD4CABUABwhmIGctAD4CABQABwgMHGceAN8BAAAA.',['璐家']='璐家大爷:BAABKgAECn8dAAIQAAgI7xm3EQAMAgAQAAgI7xm3EQAMAgAAAA==.',['生不']='生不由己:BAABKgAECn8WAAIZAAcIKxWEGwCKAQAZAAcIKxWEGwCKAQAAAA==.',['画画']='画画的贝贝:BAABKgAFFH8GAAIhAAUIVxHhCgBRAQAhAAUIVxHhCgBRAQAAAA==.',['疋棠']='疋棠嘏旖:BAAAKgAFFAMIAwAAAA==.',['白桃']='白桃兔兔奶冻:BAAAKgAECgMIAwAAAA==.',['白芍']='白芍:BAAAKgAECggIAwAAAA==.',['皇家']='皇家恐怖卫士:BAAAKgAFFAQIBAAAAA==.',['皓燃']='皓燃:BAABKgAFFH8HAAMcAAQI1xEjCgDiAAAcAAMI1xEjCgDiAAASAAIIwyNwMQBdAAAAAA==.',['盆腔']='盆腔共鸣:BAAAKgAFFAQIBAAAAA==.',['盗亦']='盗亦有盗:BAAAKgAECggIDQAAAA==.',['真奶']='真奶不住啊:BAAAKgAECgYIBgAAAA==.',['砍了']='砍了那只鸭:BAAAKgAFFAQIBAAAAA==.',['碧月']='碧月:BAABKgAFFH8GAAMNAAYIPRYwEABEAQANAAUI/hgwEABEAQAMAAEINwuzKwA7AAABKgAFFAgIDgAOAMAhAA==.',['神圣']='神圣的奇酷比:BAAAKgAFFAYIBAABKgAFFAgIDAAEAI4SAA==.神圣风暴:BAAAKgAECgYICAAAAA==.',['神靈']='神靈乄德铖:BAACKgAFFH8QAAISAAgIohc5BwA5AgASAAgIohc5BwA5AgAqAAQKfxoABBwACAh+HZgRADsCABwACAh+HZgRADsCABIAAQgJF6y9AEYAAB4AAQh4C/4sAEAAAAAA.',['秀色']='秀色可参:BAAAKgAFFAIIAgAAAA==.',['稳鸠']='稳鸠你笨七:BAAAKgAECgcICgAAAA==.',['穆西']='穆西西:BAABKgAFFH8GAAICAAYIfQcELwAsAQACAAYIfQcELwAsAQAAAA==.',['窒息']='窒息:BAAAKgAFFAQIBAAAAA==.',['童子']='童子鸡盖饭:BAAAKgADCgQIBAAAAA==.',['笑的']='笑的莂致:BAAAKgAECgcIBwAAAA==.',['笨笨']='笨笨的纯:BAABKgAFFH8IAAIUAAgI9gkvCQCYAQAUAAgI9gkvCQCYAQAAAA==.',['第三']='第三世奶妈:BAABKgAFFH8FAAMEAAIIJhSGMgB7AAAEAAIIJhSGMgB7AAADAAEIIwSoKQA9AAAAAA==.',['第六']='第六条银河:BAAAKgAFFAIIBAAAAA==.',['筱鱼']='筱鱼鱼:BAAAKgAECgIIAwAAAA==.',['箭拔']='箭拔弩张:BAABKgAECn8UAAIVAAgIHBbMPQCuAQAVAAgIHBbMPQCuAQAAAA==.',['米卫']='米卫兵:BAACKgAFFH8ZAAICAAgIbiV+BACRAgACAAgIbiV+BACRAgAqAAQKfyIAAwIACAjgIykaAJwCAAIACAjgIykaAJwCABcAAgjtCFFEAG4AAAAA.',['粉色']='粉色丢丢:BAAAKgAECgUIBwAAAA==.',['糖果']='糖果的爸爸:BAAAKgAFFAMIAwAAAA==.',['紫电']='紫电丶盲眼:BAABKgAFFH8GAAMlAAMITQQhFgCeAAAlAAMITQQhFgCeAAAhAAIIigcWRwBsAAAAAA==.',['紫菜']='紫菜卷:BAAAKgADCgUIBQABKgAFFAIIAwAHAAAAAA==.',['紫酱']='紫酱荳:BAAAKgADCggICAAAAA==.',['红伞']='红伞伞白杆杆:BAAAKgAECgQIBAAAAA==.',['红发']='红发的安:BAABKgAFFH8NAAMUAAMIrRSKNQCdAAAUAAMIrRSKNQCdAAAVAAIIrghdLwA+AAAAAA==.',['红衣']='红衣大主教:BAAAKgAECggIEwAAAA==.',['红运']='红运当头:BAAAKgAECgEIAQAAAA==.',['红颜']='红颜之剑:BAAAKgAECgYIBgAAAA==.',['纯情']='纯情大母猴:BAAAKgAECgIIAgAAAA==.',['纸鹞']='纸鹞:BAAAKgADCgQIBAAAAA==.',['纹身']='纹身噶:BAABKgAFFH8GAAMZAAQIBxHvCgDuAAAZAAQIBxHvCgDuAAAjAAEI6wb3EgA7AAAAAA==.',['给我']='给我回来:BAAAKgAECgMIBQAAAA==.',['绯村']='绯村剑心:BAAAKgAFFAIIAgAAAA==.',['罗克']='罗克西阿斯:BAABKgAFFH8gAAMUAAYI3yMaBgALAgAUAAYI3yMaBgALAgAVAAYI4hpACgAwAQABKgAFFAgICQAhAKUYAA==.',['羞羞']='羞羞的小宋:BAAAKgAECgMIAwAAAA==.',['老付']='老付哟:BAAAKgAFFAEIAQAAAA==.',['老北']='老北币:BAAAKgAECgUIBQAAAA==.',['老罗']='老罗克:BAABKgAFFH8GAAICAAYIbgitHAD/AAACAAYIbgitHAD/AAAAAA==.',['老衲']='老衲能射否:BAABKgAFFH8IAAMVAAQI0xbXKADiAAAVAAQIQBbXKADiAAAUAAQIEgWJIQBmAAAAAA==.',['耐奥']='耐奥柤:BAABKgAECn8eAAMWAAgITBKjMwBAAQAWAAgIdRGjMwBAAQAiAAQI3QzkWACaAAAAAA==.',['耶加']='耶加雪菲:BAAAKgAECgQIBAAAAA==.',['肆十']='肆十:BAAAKgAFFAIIAgAAAA==.',['肾启']='肾启示:BAAAKgAECggICgAAAA==.',['脑电']='脑电波:BAABKgAFFH8GAAICAAYIECQ6GgCPAQACAAYIECQ6GgCPAQAAAA==.',['腐烂']='腐烂的肉肉:BAAAKgAFFAIIBAAAAA==.',['腐蝗']='腐蝗:BAABKgAFFH8LAAQDAAgI4QdFBQCDAQADAAgI4QdFBQCDAQAFAAIIpAIeFQB7AAAEAAEIOAO/HwA7AAAAAA==.',['舂偢']='舂偢嘸義戰:BAAAKgADCgcIBwAAAA==.',['舔狗']='舔狗饲养员:BAAAKgAFFAYIBAAAAA==.',['舞丶']='舞丶:BAABKgAFFH8QAAMSAAYIdSG5CQD5AQASAAYIdSG5CQD5AQAcAAYIXhZYBwCbAQAAAA==.',['舞无']='舞无馒头:BAAAKgAECgYIBgAAAA==.',['舞蹈']='舞蹈的水母君:BAABKgAFFH8IAAICAAgIIgi+FAC2AQACAAgIIgi+FAC2AQAAAA==.',['艾师']='艾师傅:BAAAKgAECgEIAQAAAA==.',['艾琴']='艾琴摩根:BAABKgAECn8cAAMJAAgIZA9FJgAWAQAJAAgIDw9FJgAWAQAIAAII2QwvIgBVAAAAAA==.',['艾莲']='艾莲丶乔:BAAAKgAECgIIAgAAAA==.',['芝士']='芝士条:BAAAKgAECgEIAQABKgAFFAIIAwAHAAAAAA==.',['芝麻']='芝麻糖:BAAAKgADCggICAABKgAFFAIIAwAHAAAAAA==.',['花公']='花公子:BAAAKgADCgMIAwAAAA==.',['花花']='花花最可爱:BAAAKgAFFAIIAwAAAA==.',['芳心']='芳心纵火犯:BAAAKgAECgUIBQAAAA==.',['苍清']='苍清雪:BAABKgAFFH8TAAMPAAgIRRQdEgCJAQAPAAYI8hIdEgCJAQAGAAgIMhAfFQD5AAAAAA==.',['苍白']='苍白介壳鳕:BAAAKgAFFAQIBAAAAA==.',['苦哥']='苦哥哥:BAAAKgAECggICAAAAA==.',['菠萝']='菠萝酱:BAAAKgAECgQIBAAAAA==.',['菲灵']='菲灵:BAAAKgADCggICAAAAA==.',['萌蛮']='萌蛮:BAABKgAFFH8IAAIkAAMImxSsEwDOAAAkAAMImxSsEwDOAAAAAA==.',['萬物']='萬物之源:BAAAKgAECgYIBwAAAA==.',['蔚蓝']='蔚蓝丶破邪祟:BAAAKgAECggIEgAAAA==.',['虞书']='虞书欣:BAAAKgAFFAEIAQAAAA==.',['蛋黄']='蛋黄酥:BAAAKgAFFAIIAgABKgAFFAIIAwAHAAAAAA==.',['蛮牛']='蛮牛先生:BAAAKgAECgUICAAAAA==.',['蜗牛']='蜗牛:BAAAKgAECgYIBgAAAA==.',['蜡笔']='蜡笔老乱:BAAAKgAECgcIBwAAAA==.',['血条']='血条消失战:BAAAKgAECggIEgAAAA==.',['血瑟']='血瑟长弓:BAAAKgADCggICAAAAA==.',['要关']='要关服了:BAABKgAFFH8GAAMmAAMIuwtLBQCOAAAmAAMIuwtLBQCOAAATAAEIbgPEIQAoAAAAAA==.',['言予']='言予丶:BAAAKgADCgYIBgAAAA==.',['记得']='记得我猎过:BAABKgAFFH8JAAIVAAQIzhxmEAALAQAVAAQIzhxmEAALAQAAAA==.',['调理']='调理农务系:BAABKgAFFH8IAAIlAAQInRXcCgD6AAAlAAQInRXcCgD6AAAAAA==.',['谭小']='谭小夕丶:BAAAKgADCgMIAwAAAA==.',['貌美']='貌美如花:BAAAKgAECgYIBgAAAA==.貌美如贺:BAAAKgAECgMIAwAAAA==.',['贡克']='贡克变形大师:BAAAKgAECggIDQAAAA==.',['财神']='财神爷的宝宝:BAAAKgAECgYICgAAAA==.',['贰佰']='贰佰斤的瘦子:BAAAKgAECggIEgABKgAFFAgIJQAgACEcAA==.',['贺宝']='贺宝暴揍六饼:BAAAKgAECgMIAwAAAA==.贺宝暴揍香烟:BAAAKgADCggIDAAAAA==.',['起舞']='起舞弄清影:BAABKgAFFH8FAAIaAAMIQwSaKAB+AAAaAAMIQwSaKAB+AAAAAA==.',['跑得']='跑得非快:BAAAKgADCggIBgAAAA==.',['跟风']='跟风起个龙:BAABKgAFFH8IAAITAAgInwwtCgDQAQATAAgInwwtCgDQAQAAAA==.',['路过']='路过的新车:BAAAKgAFFAMIBAAAAA==.',['躺赢']='躺赢丶:BAAAKgAFFAQIBAAAAA==.',['软姜']='软姜糖:BAAAKgADCgcIBwABKgAFFAIIAwAHAAAAAA==.',['辜戦']='辜戦:BAAAKgAECgMIAwAAAA==.',['边渡']='边渡友茨子:BAAAKgAECgEIAQAAAA==.',['达纳']='达纳托斯:BAAAKgAFFAMIAwAAAA==.',['过期']='过期的毓婷:BAAAKgAECgcIEQAAAA==.',['远山']='远山含黛:BAABKgAFFH8IAAITAAgIUQYRDQCSAQATAAgIUQYRDQCSAQAAAA==.',['迪奥']='迪奥丝女仕:BAAAKgAECgYIBgAAAA==.',['逊纳']='逊纳莫斯:BAAAKgAECgUIBQAAAA==.',['那小']='那小子真险:BAAAKgAECggICwAAAA==.',['部落']='部落猎奇:BAACKgAFFH8XAAIVAAQIwRw+IwD8AAAVAAQIwRw+IwD8AAAqAAQKfyQAAhUACAiBIHwYAG4CABUACAiBIHwYAG4CAAAA.',['酸汤']='酸汤牛肉:BAAAKgAECgEIAQAAAA==.',['醴甘']='醴甘指凉:BAAAKgADCgYIBgAAAA==.',['野火']='野火流云:BAAAKgAFFAgIAwAAAA==.',['野贺']='野贺:BAAAKgADCgMIAwAAAA==.',['鐵甲']='鐵甲依然:BAABKgAFFH8IAAICAAMIBQt9KwC5AAACAAMIBQt9KwC5AAAAAA==.',['钻石']='钻石王老伍:BAABKgAECn8hAAMBAAgI7A34LQDqAAABAAgIYwr4LQDqAAACAAYI8Q6E6wCOAAAAAA==.',['铁蛋']='铁蛋游击队:BAABKgAFFH8QAAITAAMI0wZKKgCPAAATAAMI0wZKKgCPAAAAAA==.',['银河']='银河修理员:BAABKgAECn8VAAIMAAgIxBPMMQCrAQAMAAgIxBPMMQCrAQAAAA==.',['锤子']='锤子当飞镖:BAAAKgAECggIDQAAAA==.',['长虹']='长虹剑主虹猫:BAAAKgAFFAQIBAABKgAFFAgIBAAHAAAAAA==.',['開心']='開心小栈:BAAAKgADCggICAAAAA==.',['闪电']='闪电五连鞭:BAACKgAFFH8tAAMlAAYIOhuxBQCrAQAlAAYIOhuxBQCrAQAkAAEIAACSIAAAAAAqAAQKfygAAiUACAgMI50IAKQCACUACAgMI50IAKQCAAAA.',['阿咩']='阿咩:BAABKgAECn84AAIdAAgI5hxmEAA5AgAdAAgI5hxmEAA5AgAAAA==.',['阿尔']='阿尔萨丝:BAAAKgAECgYIBgAAAA==.',['阿巴']='阿巴阿巴:BAAAKgAECgIIAgAAAA==.',['阿曼']='阿曼达:BAAAKgAECgUIBQAAAA==.',['阿誉']='阿誉:BAAAKgAECgEIAQAAAA==.',['陈墨']='陈墨彤:BAAAKgADCgEIAQAAAA==.',['陈疯']='陈疯豹烈酒:BAAAKgAECggIDgAAAA==.',['陶喆']='陶喆:BAAAKgADCgEIAQAAAA==.',['随风']='随风如雨:BAABKgAFFH8IAAISAAQIEiScBwAzAQASAAQIEiScBwAzAQAAAA==.',['雅柏']='雅柏菲卡:BAABKgAFFH8HAAMPAAMIOw8BFwCuAAAPAAMIOw8BFwCuAAAGAAIIQwKkMgA5AAAAAA==.',['雅雅']='雅雅宝贝:BAAAKgAECgUIBQAAAA==.',['雨花']='雨花:BAABKgAFFH8IAAICAAIIGxHZOQCVAAACAAIIGxHZOQCVAAAAAA==.',['雲飛']='雲飛揚:BAAAKgAECgUIBQAAAA==.',['露娜']='露娜拿蓝难丶:BAAAKgAECggICAAAAA==.',['青丝']='青丝无名:BAEAKgAECggICAAAAA==.',['风云']='风云成章:BAABKgAECn8rAAMCAAgI4RgQRwDrAQACAAgI4RgQRwDrAQAXAAYIzwoJOAC/AAAAAA==.',['风景']='风景依然:BAAAKgAFFAQIAgAAAA==.',['风泣']='风泣:BAAAKgADCgQIBAAAAA==.',['风行']='风行者黑手:BAAAKgAECgEIAQAAAA==.',['香蕉']='香蕉拿铁:BAABKgAFFH8IAAMDAAYIWiOODABMAQADAAUIzCKODABMAQAFAAIIZBDTIQB8AAABKgAFFAgIDQADANocAA==.',['馬克']='馬克吐溫:BAAAKgAECgEIAQAAAA==.',['马奇']='马奇士丶牛:BAAAKgAFFAgIBAAAAA==.',['马德']='马德:BAAAKgAECgMIAwAAAA==.',['骑母']='骑母猪看夕阳:BAABKgAFFH8TAAMOAAYIShUfEABrAQAOAAYIShUfEABrAQAMAAMISgsLDwCdAAAAAA==.骑母猪看日出:BAABKgAFFH8OAAIUAAQIWhbOJQDUAAAUAAQIWhbOJQDUAAAAAA==.骑母猪看日落:BAABKgAFFH8GAAICAAMI6hOJJgDNAAACAAMI6hOJJgDNAAAAAA==.骑母猪看曰出:BAABKgAFFH8HAAQQAAMIuQhcDQC7AAAQAAMIuQhcDQC7AAALAAIIzQMxJABuAAARAAIIGgbSFABUAAAAAA==.',['骷髅']='骷髅人王:BAABKgAFFH8IAAIWAAgIgAW2CwCPAQAWAAgIgAW2CwCPAQAAAA==.',['高启']='高启强:BAABKgAECn8aAAMaAAgIXRuJDwAhAgAaAAgIXRuJDwAhAgAfAAEIBwStJwAKAAABKgAFFAgIDgASAAkdAA==.',['鱼塘']='鱼塘空荡荡:BAACKgAFFH8vAAQYAAgIeB0LAQDdAQAZAAgIbRkwBgAkAgAYAAYIWSALAQDdAQAjAAMIhhhlBgD9AAAqAAQKfy8ABCMACAhRIOoJAEsCACMACAjsHOoJAEsCABkABgjpH+gTANcBABgABghaGQULAHYBAAAA.鱼塘鱼多多:BAACKgAFFH8PAAMYAAYIQhyUAQB5AQAYAAYIaBuUAQB5AQAjAAMIthYJBQC5AAAqAAQKfxgABCMACAj6IWERANYBACMACAiNHWERANYBABgABQhCIrQKAH4BABkABAhgGh4nACABAAAA.',['鲁西']='鲁西飞:BAABKgAECn8oAAILAAgI4hZlDwCqAQALAAgI4hZlDwCqAQAAAA==.',['麦克']='麦克斯:BAAAKgAECgMIAwAAAA==.',['麦麦']='麦麦脆汁鸡:BAABKgAFFH8WAAMSAAgI9BgpBgBTAgASAAgI9BgpBgBTAgAcAAUIyhxhAgB4AQABKgAFFAgIJQAgACEcAA==.',['黑色']='黑色法棍:BAACKgAFFH8iAAMUAAgIXiJ7AgB9AgAUAAgIXR17AgB9AgAVAAgIFxxdDACqAQAqAAQKfxkAAxUACAgAJKwoAFACABUACAh7H6woAFACABQABAi7HrFCAEcBAAAA.',['黯焰']='黯焰邪瞳:BAAAKgADCggICAABKgAFFAQIHgATALAfAA==.',['鼠鼠']='鼠鼠是术术:BAAAKgAFFAMIAwAAAA==.',['龍葵']='龍葵:BAAAKgAFFAEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end