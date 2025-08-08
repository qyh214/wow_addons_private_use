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
 local lookup = {'Paladin-Retribution','Rogue-Assassination','DemonHunter-Havoc','Mage-Fire','Mage-Arcane','Mage-Frost','Warlock-Destruction','Warlock-Demonology','Druid-Balance','DeathKnight-Unholy','DeathKnight-Frost','DeathKnight-Blood','Druid-Restoration','Warrior-Fury','Warrior-Protection','Warrior-Arms','Unknown-Unknown','Priest-Holy','Hunter-Marksmanship','Hunter-Survival','Shaman-Restoration','Paladin-Protection','Priest-Discipline','DemonHunter-Vengeance','Hunter-BeastMastery','Monk-Mistweaver','Monk-Windwalker','Warlock-Affliction','Paladin-Holy','Priest-Shadow','Rogue-Outlaw','Druid-Guardian','Shaman-Enhancement','Monk-Brewmaster','Shaman-Elemental',}; local provider = {region='CN',realm='刺骨利刃',name='CN',type='weekly',zone=42,date='2025-08-08',data={Af='Afdjhl:BAACKgAFFH8GAAIBAAIIURfuNwCZAAABAAIIURfuNwCZAAAqAAQKfxoAAgEACAgnGWRkANIBAAEACAgnGWRkANIBAAAA.',Al='Alstar:BAAAKgAECgYIDwAAAA==.',An='Antho:BAAAKgAECgEIAQAAAA==.',Ap='Appstore:BAAAKgAECgEIAQAAAA==.',As='Asassin:BAABKgAFFH8IAAICAAQIEBqcCQD5AAACAAQIEBqcCQD5AAAAAA==.Asus:BAAAKgAECgIIAgAAAA==.',Ay='Ayije:BAABKgAFFH8GAAIBAAYIKh1DGACbAQABAAYIKh1DGACbAQABKgAFFAgIDwABAMkcAA==.',Cl='Clince:BAAAKgAFFAcIBAABKgAFFAgIDAADAMMaAA==.',Cr='Crazybird:BAABKgAECn8ZAAIEAAgIRwgxKQDpAAAEAAgIRwgxKQDpAAAAAA==.',De='Demonlane:BAABKgAFFH8XAAQFAAcI4yAGAAAsAgAFAAcI4CAGAAAsAgAEAAYIjQ0/CAB/AQAGAAQIViTWDQD2AAAAAA==.',Dr='Drow:BAACKgAFFH8XAAMHAAQI6h6oEQDfAAAHAAMI6h6oEQDfAAAIAAIIDBs3KgBGAAAqAAQKfyAAAwcACAgIGZYkAOsBAAcACAjjGJYkAOsBAAgAAwisHTFBAO4AAAAA.',Ei='Eileen:BAAAKgAECggIEAAAAA==.',El='Elohims:BAAAKgAECgIIAgAAAA==.Elunen:BAABKgAFFH8KAAIJAAYIzB6+CwDIAQAJAAYIzB6+CwDIAQAAAA==.',Ep='Epictroll:BAAAKgADCggICAAAAA==.',Es='Esc:BAAAKgADCggICAAAAA==.',Fa='Fade:BAABKgAFFH8JAAMKAAQImxWqIAAcAQAKAAQI7BGqIAAcAQALAAMImBDqCQDNAAAAAA==.',Fu='Funkystyle:BAABKgAFFH8JAAICAAYIixISEwAiAQACAAYIixISEwAiAQAAAA==.',Ha='Handsome:BAABKgAECn8YAAIBAAgImxhNQwAlAgABAAgImxhNQwAlAgAAAA==.Hardcandy:BAAAKgAECgUIBQAAAA==.',He='Helianthus:BAAAKgADCggICAAAAA==.',Ho='Homelander:BAABKgAFFH8IAAMKAAQI5RZCEQD0AAAKAAQI5RZCEQD0AAAMAAQIhAZoGQCJAAAAAA==.',Ju='Junne:BAABKgAFFH8MAAIHAAYIXhEdDQByAQAHAAYIXhEdDQByAQABKgAFFAgICAAHAPUYAA==.',La='Lanbao:BAAAKgAECgcIBwAAAA==.',Le='Leeken:BAAAKgAFFAQIAwAAAA==.Legendary:BAAAKgAECgYIBgAAAA==.',Li='Lingren:BAABKgAFFH8IAAIFAAQIHRKJFgDIAAAFAAQIHRKJFgDIAAAAAA==.',Lm='Lmsailcq:BAABKgAECn8uAAMNAAgIDhQkIwCFAQANAAgIDhQkIwCFAQAJAAcIKAe+iQDGAAAAAA==.',Lo='Lonely:BAAAKgAECggIDwAAAA==.',Ma='Marleiarlee:BAAAKgAECgQIBwAAAA==.',Ms='Mshadows:BAACKgAFFH8LAAMOAAQIZx5GCwAPAQAOAAQIZx5GCwAPAQAPAAQIvBHYBADCAAAqAAQKfx4AAw4ACAgXI7IMAKECAA4ACAgXI7IMAKECABAABAg2E9tAANMAAAEqAAUUCAgCABEAAAAA.',Na='Namco:BAAAKgAECgYIBgAAAA==.Namcou:BAAAKgAECgEIAQAAAA==.',Ni='Nishuo:BAABKgAECn8XAAISAAcIahkhKwCcAQASAAcIahkhKwCcAQAAAA==.',Nu='Nuclear:BAACKgAFFH8HAAINAAMIHxCRJQCPAAANAAMIHxCRJQCPAAAqAAQKfx8AAg0ACAhhGtwgAJcBAA0ACAhhGtwgAJcBAAAA.',Ol='Oliverquinn:BAABKgAECn8dAAMTAAcIWx8EIgDxAQATAAcIsR0EIgDxAQAUAAMItBeODwDWAAAAAA==.',Pe='Persephone:BAAAKgADCgcIBwAAAA==.',Ra='Raion:BAAAKgADCggICwAAAA==.',Rt='Rt:BAAAKgAECgcICgAAAA==.',Se='Serein:BAAAKgAECgYIBgAAAA==.',Si='Simon:BAAAKgAECggICgAAAA==.',Sp='Sprog:BAAAKgAECgMIAwAAAA==.',Ta='Takachiko:BAABKgAFFH8OAAIDAAQIGCKgCgAgAQADAAQIGCKgCgAgAQAAAA==.',Ti='Titanrich:BAAAKgAECgcIBwAAAA==.',Ur='Ursoeasy:BAAAKgADCgMIAwAAAA==.',Wh='Whyzd:BAABKgAECn8YAAISAAgISBhiHAD2AQASAAgISBhiHAD2AQABKgAFFAgICAAVAO0XAA==.',Xi='Xiaofdly:BAECKgAFFH84AAIJAAgIuRrSBQBcAgAJAAgIuRrSBQBcAgAqAAQKfz8AAgkACAgrJqkCAAgDAAkACAgrJqkCAAgDAAAA.Xiaofdragon:BAEAKgADCggICAABKgAFFAgIOAAJALkaAA==.',Xm='Xmas:BAABKgAFFH8FAAMMAAUIKRFQDAC2AAAMAAQIqxJQDAC2AAAKAAEIpAxsUQBOAAAAAA==.',Yo='Yoyoian:BAAAKgAECggICAAAAA==.',Ze='Zeva:BAABKgAECn8dAAIKAAgIOR2BFwBQAgAKAAgIOR2BFwBQAgAAAA==.',Zx='Zxp:BAABKgAECn8fAAMBAAgI+hMqJQCYAQABAAgI+hMqJQCYAQAWAAEIKA/FVQAtAAAAAA==.',['一月']='一月黑风高一:BAABKgAFFH8FAAIEAAUIohUoFQD6AAAEAAUIohUoFQD6AAAAAA==.',['一沙']='一沙一天堂:BAABKgAFFH8IAAIXAAgICBfcAgBCAgAXAAgICBfcAgBCAgAAAA==.',['一路']='一路德百:BAAAKgADCggICAAAAA==.',['一身']='一身仙女味丶:BAAAKgADCgMIAwAAAA==.',['七月']='七月的云:BAACKgAFFH8PAAIDAAMI+iLqGgAnAQADAAMI+iLqGgAnAQAqAAQKfxoAAgMACAi6IaEdAFICAAMACAi6IaEdAFICAAAA.',['七窍']='七窍已通六窍:BAAAKgAECgMIAwAAAA==.',['下班']='下班之后玩:BAAAKgADCgEIAQAAAA==.下班归来:BAABKgAFFH8GAAIVAAYIKxNdEQBKAQAVAAYIKxNdEQBKAQAAAA==.',['不可']='不可结缘:BAAAKgADCgYIBgAAAA==.',['东山']='东山莨菪:BAAAKgAECggICAAAAA==.',['丨变']='丨变压器丨:BAAAKgAECgYIBgAAAA==.',['丨岚']='丨岚丨:BAABKgAFFH8IAAIXAAQIOgO4JgCAAAAXAAQIOgO4JgCAAAAAAA==.',['丨未']='丨未至丨:BAAAKgADCgMIAwAAAA==.',['丨陛']='丨陛丶下丨:BAAAKgAECgIIAgAAAA==.',['乌龟']='乌龟满天飞:BAAAKgAECgcIBwAAAA==.',['乐高']='乐高乐高:BAAAKgADCggICAAAAA==.',['乖啵']='乖啵啵:BAAAKgAFFAIIAgAAAA==.',['乱舞']='乱舞的旋律:BAAAKgAECggIDwAAAA==.',['二丶']='二丶六:BAAAKgAECggICAAAAA==.',['云岸']='云岸净空:BAAAKgAECgYICAAAAA==.',['云柒']='云柒:BAABKgAFFH8HAAMDAAQIvA8gOgCWAAADAAQIngcgOgCWAAAYAAMIlhI+HgBrAAAAAA==.',['从小']='从小就黑:BAAAKgAECgQIBAAAAA==.',['以圣']='以圣光之名:BAAAKgAECggIBwAAAA==.',['伊箭']='伊箭傾心:BAABKgAFFH8SAAMTAAgIVhtPBABDAgATAAgIJxlPBABDAgAZAAgIWBXODgA9AQAAAA==.',['伊莎']='伊莎珼菈:BAAAKgADCgcIBwAAAA==.',['休丶']='休丶杰克曼:BAAAKgAECgQIBQAAAA==.',['伦落']='伦落街尾:BAACKgAFFH8TAAIHAAMIXxixEwDWAAAHAAMIXxixEwDWAAAqAAQKfxoAAwcACAg9Fvk1AJcBAAcACAg9Fvk1AJcBAAgAAggTBgtsAFYAAAAA.',['伯瓦']='伯瓦尔丶神明:BAAAKgADCgUIBQAAAA==.',['你不']='你不行的:BAAAKgADCgYIBgAAAA==.',['你家']='你家叁哥:BAABKgAECn8aAAIDAAgIuRnUJwDNAQADAAgIuRnUJwDNAQAAAA==.',['你爱']='你爱我做的事:BAAAKgADCgQIBAAAAA==.',['你睇']='你睇我唔到:BAAAKgAFFAMIAwAAAA==.',['修煤']='修煤气灶:BAABKgAFFH8YAAMaAAgIJRiXBAAUAgAaAAgIJRiXBAAUAgAbAAgI0Af3BgCbAQAAAA==.',['做你']='做你我爱的事:BAAAKgAECgEIAQAAAA==.做你爱我的事:BAAAKgAECgEIAQAAAA==.',['偷心']='偷心贼:BAAAKgAECgUIBQAAAA==.',['偷猎']='偷猎恶魔:BAAAKgADCgEIAQAAAA==.',['先森']='先森不调情:BAABKgAFFH8GAAITAAYI9B2hDACOAQATAAYI9B2hDACOAQAAAA==.',['光明']='光明蛋:BAAAKgADCgIIAwAAAA==.',['克斯']='克斯里娜:BAAAKgAECggIDwAAAA==.',['克里']='克里斯提娜丶:BAAAKgAECgYIBwAAAA==.',['再无']='再无朝夕:BAAAKgAECgIIAgAAAA==.',['冰封']='冰封之炎:BAACKgAFFH8LAAMMAAgIYRPOAwDSAQAMAAgIYRPOAwDSAQALAAMIiwupCgDBAAAqAAQKfx4AAgsACAgXHkwFAEoCAAsACAgXHkwFAEoCAAAA.冰封璀璨:BAACKgAFFH8RAAIZAAgIWRIPBwATAgAZAAgIWRIPBwATAgAqAAQKfycAAhkACAjeHRUeAEsCABkACAjeHRUeAEsCAAAA.',['冰雪']='冰雪飛灵:BAAAKgAFFAIIAgAAAA==.',['冰霜']='冰霜死骑:BAAAKgAECgYIBgAAAA==.',['冷卻']='冷卻旳承諾:BAAAKgAECgYIDwAAAA==.',['凯撒']='凯撒大帝:BAAAKgAECgUIBgAAAA==.',['刀把']='刀把:BAAAKgADCgMIAwAAAA==.',['刘玄']='刘玄德:BAAAKgAECgUIBQAAAA==.',['刹那']='刹那雪音:BAAAKgAECgQIBAAAAA==.',['功夫']='功夫熊猫:BAAAKgAECgQIBAAAAA==.',['劳资']='劳资数到三:BAAAKgAECgEIAQAAAA==.',['千雪']='千雪千月:BAAAKgADCggICAAAAA==.',['南风']='南风知我忆:BAAAKgAECggICQAAAA==.',['卡特']='卡特玲娜:BAAAKgAECggICgABKgAFFAUIGwAWAH8JAA==.',['叁队']='叁队骑士:BAAAKgAECggICwAAAA==.',['双刀']='双刀猫:BAABKgAFFH8IAAIBAAgImxvpBQBvAgABAAgImxvpBQBvAgAAAA==.',['叔叔']='叔叔要冲刺了:BAAAKgAFFAIIAgAAAA==.',['古德']='古德里安:BAAAKgADCgMIAwAAAA==.',['只求']='只求一胜:BAAAKgAFFAQIBAAAAA==.',['叫啥']='叫啥来的:BAAAKgADCggIEAAAAA==.',['可可']='可可熊的哀伤:BAAAKgADCgIIAwAAAA==.可可熊的火舞:BAAAKgADCgEIAQAAAA==.可可熊的爱恋:BAAAKgADCggIBQAAAA==.可可熊的舞者:BAAAKgADCggICAAAAA==.可可熊的馄饨:BAAAKgADCggICAAAAA==.',['叽叽']='叽叽歪歪小妈:BAABKgAFFH8HAAIWAAcIFQyGDgAWAQAWAAcIFQyGDgAWAQAAAA==.',['吃鱼']='吃鱼的猫猫:BAAAKgAECggICAAAAA==.',['吉吉']='吉吉崩:BAAAKgADCgYIBgAAAA==.',['吞天']='吞天:BAAAKgAFFAIIAgAAAA==.',['周三']='周三下午茶:BAAAKgAECggIEAAAAA==.',['咱的']='咱的爸:BAAAKgAECgUIBQAAAA==.',['咸鱼']='咸鱼大王:BAAAKgADCggIDAAAAA==.',['哀木']='哀木涕乄:BAABKgAFFH8GAAIKAAMIqxJiMADQAAAKAAMIqxJiMADQAAAAAA==.',['哈斯']='哈斯卡觉醒者:BAAAKgADCgcIBwAAAA==.',['哥灬']='哥灬霸气侧漏:BAAAKgAECggIDgAAAA==.',['啦丶']='啦丶啦:BAABKgAFFH8GAAIBAAMIlA92KADFAAABAAMIlA92KADFAAAAAA==.',['喂喂']='喂喂我花生:BAAAKgAECgEIAQAAAA==.',['喃愀']='喃愀:BAAAKgAECgYIBgAAAA==.',['噜噜']='噜噜啦啦:BAAAKgAECgQIBAAAAA==.',['囯产']='囯产零零久:BAABKgAECn8+AAMKAAgI+SKhCgDIAgAKAAgI+SKhCgDIAgAMAAEIAAD+cgAAAAAAAA==.',['国产']='国产零零久:BAABKgAECn8XAAIXAAgIpAtjOwAAAQAXAAgIpAtjOwAAAQAAAA==.',['图哆']='图哆哆:BAAAKgAFFAMIAwAAAA==.',['國产']='國产零零久:BAABKgAECn80AAMYAAgIZSDoCACKAgAYAAgIZSDoCACKAgADAAgIARfUNgDQAQAAAA==.',['圣光']='圣光千缕:BAAAKgAECgQICAAAAA==.圣光回响:BAAAKgADCggICAAAAA==.',['地狱']='地狱维纳斯:BAACKgAFFH8SAAMFAAgIDRhvBQBKAgAFAAgIDRhvBQBKAgAGAAMIqBJiFQDBAAAqAAQKfyIAAwYACAgnHcoFAGQCAAYACAgnHcoFAGQCAAQABQgUBTyHAG8AAAAA.',['夏士']='夏士莲:BAABKgAFFH8MAAQIAAYIyBbYAABYAQAIAAUIqxnYAABYAQAcAAQI/wtdEAC2AAAHAAEIPwtILABXAAAAAA==.',['夜色']='夜色的祷言:BAAAKgAECgQIBgAAAA==.夜色的锋刃:BAAAKgAECgYICAAAAA==.夜色的风:BAAAKgAECgcIBwAAAA==.',['夢落']='夢落繁花:BAAAKgADCgYIBgAAAA==.',['大元']='大元帅:BAAAKgADCgMIAwAAAA==.',['大唐']='大唐:BAAAKgAECgYICgAAAA==.',['大江']='大江:BAAAKgAECgYIBgAAAA==.',['天佑']='天佑昕辰:BAABKgAFFH8KAAIBAAgItxDwDAAAAgABAAgItxDwDAAAAgAAAA==.',['天地']='天地悠悠笑易:BAAAKgAECgcIDAAAAA==.',['天晴']='天晴丷:BAAAKgADCgMIAwAAAA==.',['失恋']='失恋很伤心:BAAAKgAFFAMIAwABKgAFFAgICAAZAKoYAA==.',['奇衡']='奇衡三:BAAAKgAFFAIIAgAAAA==.',['奈伊']='奈伊祖特:BAAAKgAECgEIAQAAAA==.',['奥戳']='奥戳胩:BAAAKgAFFAIIBAAAAA==.',['奥沙']='奥沙利亚:BAABKgAFFH8GAAIOAAMIAgeRFQC3AAAOAAMIAgeRFQC3AAAAAA==.',['奶紧']='奶紧你啊:BAAAKgADCgIIAgAAAA==.',['如丿']='如丿初:BAABKgAFFH8IAAIKAAMIDxE8MgDLAAAKAAMIDxE8MgDLAAAAAA==.',['如果']='如果哀:BAAAKgADCggICwAAAA==.',['妍熙']='妍熙:BAAAKgADCgMIBQAAAA==.',['姐夫']='姐夫是叁哥:BAABKgAECn8pAAMdAAgIehVNGwCHAQAdAAgIehVNGwCHAQABAAIIZgc9WwFPAAAAAA==.',['威龙']='威龙圣骑:BAAAKgAECgEIAQAAAA==.',['婉若']='婉若游龙:BAAAKgAECggICAAAAA==.',['子岸']='子岸子岸:BAABKgAECn8gAAIBAAgIWxeAWQCxAQABAAgIWxeAWQCxAQAAAA==.',['宅男']='宅男心不宅:BAAAKgAFFAMIAwAAAA==.',['宏宇']='宏宇宙天魔:BAAAKgADCggICAAAAA==.',['宫爆']='宫爆鸡丁:BAAAKgADCggICAAAAA==.',['寶貝']='寶貝各种抱:BAABKgAECn8VAAIJAAYIkwyegQDbAAAJAAYIkwyegQDbAAAAAA==.',['寻山']='寻山小妖:BAAAKgAFFAMIAwAAAA==.',['射击']='射击屁屁:BAABKgAFFH8IAAIZAAgIWxrLBABbAgAZAAgIWxrLBABbAgAAAA==.',['小宝']='小宝天使:BAAAKgAECgIIAgAAAA==.',['小时']='小时候很萌:BAAAKgADCggICAAAAA==.',['小老']='小老弟:BAAAKgAECgYIBgAAAA==.',['小马']='小马哥来咯:BAAAKgAECgIIAgAAAA==.',['尐白']='尐白杨:BAAAKgAECgYIBwAAAA==.',['尒寶']='尒寶赑:BAABKgAECn8ZAAMSAAgIGRc8DQC2AQASAAgIGRc8DQC2AQAXAAEI7BDRlAArAAAAAA==.',['巴温']='巴温:BAAAKgADCgUIBQAAAA==.',['布莱']='布莱恩钢须:BAAAKgAECgcIBwAAAA==.',['布鲁']='布鲁叽叽:BAABKgAECn8XAAIVAAgIwAMzNACrAAAVAAgIwAMzNACrAAAAAA==.',['希尔']='希尔佤娜斯:BAAAKgAECgQIBgAAAA==.',['帕拉']='帕拉梅猪:BAAAKgAECgIIAgAAAA==.',['帝月']='帝月晨风:BAACKgAFFH8HAAIOAAIISCMJFwDNAAAOAAIISCMJFwDNAAAqAAQKfzYAAg4ACAiIJRkFAOcCAA4ACAiIJRkFAOcCAAAA.',['帮紧']='帮紧你啊:BAAAKgADCgYIBgAAAA==.',['常州']='常州小笼包:BAAAKgADCggICAAAAA==.',['幻灵']='幻灵丶猎:BAAAKgAECgYIBgAAAA==.',['幽幽']='幽幽鱼儿:BAABKgAFFH8GAAMSAAYI8wgjHwDMAAASAAUIXwgjHwDMAAAeAAEIKQE2MQAyAAAAAA==.',['库巴']='库巴:BAABKgAFFH8IAAIBAAQIZRlSSQDcAAABAAQIZRlSSQDcAAAAAA==.',['弎柒']='弎柒灬尒丗哵:BAAAKgAECgYIEAAAAA==.',['弑鼪']='弑鼪辙:BAAAKgAECgMIAwAAAA==.',['张女']='张女郎灬水仙:BAAAKgAECgUIBQAAAA==.',['彳亍']='彳亍:BAAAKgAECgIIAgAAAA==.',['御坂']='御坂妹妹:BAAAKgAFFAgIBAAAAA==.',['微笑']='微笑的幸福:BAAAKgAECgUICwAAAA==.',['德国']='德国骨科丶:BAAAKgAECgQIBAAAAA==.',['心惢']='心惢:BAABKgAFFH8GAAIfAAMICxEPBADLAAAfAAMICxEPBADLAAAAAA==.',['心潮']='心潮人不潮:BAAAKgADCgcICQAAAA==.',['忧郁']='忧郁的颜色:BAAAKgAECgYICAAAAA==.',['忽悠']='忽悠:BAAAKgADCggICAAAAA==.',['恋上']='恋上寒若雨:BAABKgAECn8WAAQNAAgI0B99OQADAQANAAUICRt9OQADAQAJAAUI2wlKnACOAAAgAAEIvwtJNAAiAAABKgAFFAgIEAAhAMcjAA==.恋上筱小雨:BAAAKgAECggIEgAAAA==.恋上雪无痕:BAAAKgAECgQIBAAAAA==.',['恐惧']='恐惧达灵毛:BAAAKgAECgcICQAAAA==.',['恶霊']='恶霊之手绝色:BAAAKgAECgMIAwAAAA==.',['恶靈']='恶靈之手漂泊:BAAAKgADCggICAAAAA==.',['懒惰']='懒惰:BAAAKgAECgcIBwAAAA==.',['懵智']='懵智:BAABKgAFFH8MAAIaAAIIfATpLwBWAAAaAAIIfATpLwBWAAAAAA==.',['我叫']='我叫腾格尔:BAAAKgAECgYIBgAAAA==.',['我就']='我就是新手吧:BAAAKgAECgEIAQAAAA==.',['我当']='我当然是法神:BAABKgAFFH8GAAIEAAIIzxTHLgCPAAAEAAIIzxTHLgCPAAAAAA==.',['我的']='我的圣光啊:BAAAKgAECgMIAwAAAA==.我的小红帽呢:BAABKgAFFH8GAAILAAMIvheNCQDWAAALAAMIvheNCQDWAAAAAA==.',['我还']='我还活者:BAAAKgADCgIIAgAAAA==.',['抱着']='抱着你冲锋:BAAAKgAFFAEIAQAAAA==.',['抹小']='抹小茶:BAAAKgAFFAMIAwAAAA==.',['拂晓']='拂晓的黎明:BAABKgAFFH8GAAIDAAMIewXnHgCcAAADAAMIewXnHgCcAAAAAA==.',['拉风']='拉风:BAAAKgAECgUIBQAAAA==.',['拳拳']='拳拳到肉:BAAAKgAECgQIBAAAAA==.',['放开']='放开那个黄瓜:BAAAKgAECgYIBgAAAA==.',['斷點']='斷點:BAACKgAFFH8QAAMNAAMIBRlSGgDPAAANAAMIBRlSGgDPAAAJAAEIrAORMgAuAAAqAAQKfxoAAiAACAilDRoTABwBACAACAilDRoTABwBAAAA.',['无头']='无头三速怪:BAAAKgADCggICAAAAA==.',['无所']='无所谓好与坏:BAAAKgAFFAEIAgAAAA==.',['无敌']='无敌嘲讽:BAABKgAECn8WAAQBAAgIBB5nSQAUAgABAAgIBB5nSQAUAgAdAAYIHxdlKwADAQAWAAEIZAAAAAAAAAAAAA==.无敌盾牌:BAAAKgADCgYIBgAAAA==.',['明月']='明月爱赏咪:BAAAKgAECgUIBQAAAA==.明月爱赏喵:BAAAKgAECgYIBgAAAA==.',['星之']='星之圣痕:BAAAKgAFFAIIAgAAAA==.',['晴丶']='晴丶天:BAAAKgAECgIIAgAAAA==.',['晶风']='晶风:BAABKgAFFH8GAAINAAYIhwLQDwCaAAANAAYIhwLQDwCaAAAAAA==.',['暗夜']='暗夜之明月:BAABKgAECn8UAAIdAAcIgx6NHAB+AQAdAAcIgx6NHAB+AQAAAA==.',['暮雨']='暮雨亦成诗:BAAAKgAECggICwAAAA==.',['曌灆']='曌灆:BAAAKgADCggICAABKgAFFAgICQAaAHQWAA==.',['曝光']='曝光:BAABKgAFFH8OAAMJAAQIwRQUGwDTAAAJAAQIwRQUGwDTAAANAAMIJwXxMQBQAAAAAA==.',['月下']='月下孤舞:BAABKgAECn8eAAIZAAgIWhSBNwDHAQAZAAgIWhSBNwDHAQAAAA==.月下星雨:BAAAKgADCgIIAgAAAA==.',['朔風']='朔風飛揚:BAABKgAFFH8LAAIOAAYIkBegCwCRAQAOAAYIkBegCwCRAQAAAA==.',['木易']='木易天涯:BAAAKgADCggICAAAAA==.木易小点:BAABKgAFFH8IAAIBAAgIhgg7FAC6AQABAAgIhgg7FAC6AQAAAA==.',['术赤']='术赤:BAAAKgADCgcIBwAAAA==.',['李小']='李小鬼:BAAAKgADCggIEAAAAA==.',['极限']='极限壁垒:BAABKgAECn8sAAIBAAgIICEcCgChAgABAAgIICEcCgChAgAAAA==.',['树先']='树先生丶:BAAAKgAECgIIAgAAAA==.',['桃枝']='桃枝妖妖安妮:BAAAKgAFFAcIBAAAAA==.',['桐崎']='桐崎千棘:BAAAKgAECgYIBgAAAA==.',['梧桐']='梧桐相持老:BAAAKgAFFAYIBAAAAA==.',['橘花']='橘花瓜瓜煤钱:BAAAKgADCgcIBwAAAA==.',['正義']='正義絕不遲到:BAABKgAECn8UAAIBAAgIhxwlMwAyAgABAAgIhxwlMwAyAgAAAA==.',['步步']='步步花恋雨:BAABKgAECn8UAAIBAAgINCWVNQBPAgABAAgINCWVNQBPAgAAAA==.步步花雨:BAAAKgAECggIDwAAAA==.',['武器']='武器大师断角:BAABKgAECn8aAAIQAAgIcQA8bgAjAAAQAAgIcQA8bgAjAAAAAA==.',['死亡']='死亡代理者:BAABKgAECn8cAAILAAgIkBqRCQAXAgALAAgIkBqRCQAXAgAAAA==.',['死肥']='死肥仔:BAACKgAFFH8GAAIhAAIIewviEgCXAAAhAAIIewviEgCXAAAqAAQKfxkAAiEACAiPGAoWABwCACEACAiPGAoWABwCAAAA.',['殇之']='殇之暗伤:BAAAKgADCggICAAAAA==.殇之殇:BAAAKgADCggIDAAAAA==.',['毕业']='毕业季的忧桑:BAAAKgAECgYIBgAAAA==.',['氵夭']='氵夭全:BAAAKgAECgMIAgAAAA==.',['汽泡']='汽泡咖啡:BAAAKgAECgIIAgAAAA==.',['沐清']='沐清影:BAAAKgADCgQIBAAAAA==.',['沐竹']='沐竹:BAAAKgADCgEIAQAAAA==.',['沐筱']='沐筱筱:BAABKgAECn8bAAIGAAgI0BEqEQBlAQAGAAgI0BEqEQBlAQAAAA==.',['沙海']='沙海:BAAAKgAECgMIAwAAAA==.',['沙罗']='沙罗娇娇:BAAAKgADCgIIAgAAAA==.',['没教']='没教养的兔子:BAAAKgAECgMIAwAAAA==.',['淡定']='淡定的法:BAAAKgAECgYIBgAAAA==.淡定的騎士:BAAAKgAECgEIAQAAAA==.',['淡淡']='淡淡哋劃濄:BAAAKgAECggIEAAAAA==.',['温柔']='温柔一笑:BAABKgAECn8WAAIZAAgI4RlKKgAHAgAZAAgI4RlKKgAHAgAAAA==.',['漫展']='漫展蓝龙牧:BAAAKgAECgYIBgAAAA==.',['漫步']='漫步在雨季:BAAAKgAECgEIAQAAAA==.',['灿烂']='灿烂男孩:BAAAKgAECgMIAwAAAA==.',['炫舞']='炫舞逸尘:BAAAKgAECgcIEwAAAA==.',['烅皇']='烅皇:BAACKgAFFH8WAAMaAAgIvg9hBgDeAQAaAAgIvg9hBgDeAQAbAAIIwBbrDQDMAAAqAAQKfxcAAxsACAiXIzUHALECABsACAidIjUHALECACIABwiIG28OAFsBAAAA.',['爆发']='爆发者深度:BAAAKgAECggIEQAAAA==.',['爱你']='爱你我做的事:BAAAKgAECggICAAAAA==.',['爱尚']='爱尚:BAAAKgAECgQIBwAAAA==.',['爱是']='爱是种信仰:BAAAKgAECgIIAgAAAA==.',['爱纠']='爱纠结的猫:BAAAKgADCgIIAgAAAA==.',['版本']='版本之子:BAABKgAECn8XAAIVAAgIEBVoLADYAQAVAAgIEBVoLADYAQAAAA==.',['牛哞']='牛哞哞灬:BAAAKgAFFAYIBAABKgAFFAgIBAARAAAAAA==.',['牛眼']='牛眼流牛油:BAAAKgAFFAQIBAAAAA==.',['牛腩']='牛腩炖冬瓜:BAAAKgAECgQIBAAAAA==.',['牧天']='牧天下:BAABKgAFFH8KAAMSAAYIRhtxEgAeAQASAAUILRtxEgAeAQAeAAEIRgxCLABDAAAAAA==.',['物华']='物华依旧:BAAAKgAECgQIBQAAAA==.',['猎影']='猎影:BAAAKgADCggIDAAAAA==.',['猪头']='猪头中队长:BAAAKgADCggICAAAAA==.',['猫阿']='猫阿不:BAAAKgAECgQIBAAAAA==.',['玉蝴']='玉蝴蝶:BAAAKgAECgMIBAAAAA==.',['玉麒']='玉麒麟卢俊义:BAAAKgADCggICAAAAA==.',['理查']='理查德深:BAAAKgAECgMIAwAAAA==.',['琥珀']='琥珀时光:BAAAKgADCgEIAQAAAA==.',['瑾小']='瑾小主:BAAAKgADCggICAAAAA==.',['瓦莉']='瓦莉拉丶神明:BAAAKgADCggICAAAAA==.',['瓦蘭']='瓦蘭尼爾:BAAAKgAECgUIBQAAAA==.',['甜蜜']='甜蜜超人:BAABKgAFFH8KAAIOAAYIXxAbDQB9AQAOAAYIXxAbDQB9AQAAAA==.',['癫狂']='癫狂半仙:BAAAKgAFFAIIAgAAAA==.',['白日']='白日梦想家:BAAAKgAECggICAAAAA==.',['白羊']='白羊座小小雨:BAAAKgAECggIDwAAAA==.白羊座小雨:BAAAKgAECggIDwAAAA==.',['皇家']='皇家执法者:BAACKgAFFH8GAAIHAAYISRx1FQBYAQAHAAYISRx1FQBYAQAqAAQKfxoAAxwACAjwE7YHAFIBABwACAiKELYHAFIBAAgABAihFMo9APwAAAAA.',['皇小']='皇小束:BAAAKgAFFAQIBAABKgAFFAgIBgAcAGobAA==.',['皮卡']='皮卡牛:BAAAKgADCggIDwAAAA==.',['盗帅']='盗帅夜留香:BAAAKgADCggIEAAAAA==.',['相以']='相以沫:BAAAKgAECggIEQAAAA==.',['盾牌']='盾牌:BAAAKgADCggICAAAAA==.',['睡也']='睡也无聊:BAAAKgAECgYIDAAAAA==.',['睡越']='睡越如梭:BAAAKgADCggICAAAAA==.',['硫斯']='硫斯:BAAAKgADCgQIBAAAAA==.',['秒秒']='秒秒妙妙喵喵:BAAAKgAFFAgIBAAAAA==.',['窠樂']='窠樂:BAABKgAFFH8OAAMVAAYI6Rm2AADeAQAVAAYI6Rm2AADeAQAjAAMIeAs4DQDCAAAAAA==.',['笑着']='笑着流泪:BAAAKgADCgIIAgAAAA==.',['笑赞']='笑赞丶紅顔:BAAAKgAFFAQIBAAAAA==.',['索莉']='索莉娅:BAAAKgAECgEIAQAAAA==.',['繁花']='繁花梦落:BAAAKgAECgcIBwAAAA==.',['终生']='终生不渝丶:BAABKgAFFH8FAAISAAUIeQ2FFwD6AAASAAUIeQ2FFwD6AAAAAA==.',['翟星']='翟星星:BAAAKgAFFAMIAwAAAA==.',['翻滚']='翻滚吧萌子:BAABKgAFFH8IAAIMAAgI5Bz2AQBTAgAMAAgI5Bz2AQBTAgAAAA==.翻滚屁屁:BAACKgAFFH8KAAIaAAYI9xg2DQBRAQAaAAYI9xg2DQBRAQAqAAQKfxUAAiIACAgQFIEPAEcBACIACAgQFIEPAEcBAAAA.',['老刀']='老刀把子:BAAAKgADCgMIAwAAAA==.',['肚腩']='肚腩男:BAABKgAECn8VAAIHAAgIRBAlTAA4AQAHAAgIRBAlTAA4AQAAAA==.',['胖胖']='胖胖的糯米鸡:BAAAKgAECgMIAwAAAA==.',['脱脂']='脱脂鲜奶:BAABKgAFFH8GAAINAAYIExvIBwCRAQANAAYIExvIBwCRAQAAAA==.',['自体']='自体脂肪丰面:BAAAKgAECgYIBgAAAA==.',['艾维']='艾维娜丶:BAAAKgADCgMIAwABKgAFFAIIBwAOAEgjAA==.',['花开']='花开花落:BAAAKgAECgEIAQAAAA==.',['英雄']='英雄城二师兄:BAAAKgADCgYIBgAAAA==.英雄城厨子:BAAAKgAECgEIAQAAAA==.英雄城游侠:BAAAKgADCggICAAAAA==.',['荒野']='荒野:BAAAKgADCgEIAQAAAA==.',['荷辛']='荷辛橙:BAAAKgAECgQIBAAAAA==.',['莊生']='莊生夢蝶:BAABKgAFFH8SAAMMAAYI4yXtAwAbAgAMAAYI4yXtAwAbAgAKAAYIWRc6FAB5AQAAAA==.',['莫呈']='莫呈袔:BAAAKgADCgEIAQAAAA==.',['莱恩']='莱恩狮:BAAAKgAFFAMIAwAAAA==.',['菊花']='菊花护卫者:BAAAKgAECgMIAwAAAA==.菊花电击者:BAAAKgADCgUIBQAAAA==.菊花碾碎者:BAAAKgADCggICAAAAA==.',['菜狗']='菜狗纳命来丶:BAAAKgADCgYIBgABKgAFFAIIBwAOAEgjAA==.',['菡萏']='菡萏兜兜:BAAAKgAECgMIAwAAAA==.',['萌萌']='萌萌哒灬呆毛:BAAAKgAECgUIBQAAAA==.',['落阿']='落阿昆达:BAAAKgAECgUIBQAAAA==.',['蓝羽']='蓝羽浅葱:BAAAKgAFFAQIBAAAAA==.',['藽吻']='藽吻:BAAAKgAECgYIBgAAAA==.',['虫二']='虫二:BAABKgAFFH8HAAMGAAMIbgjvIgB2AAAGAAIImQvvIgB2AAAFAAII+QFtQQBQAAAAAA==.',['血嗔']='血嗔:BAABKgAFFH8LAAMKAAgIdBEzCwBhAQAKAAQIaRUzCwBhAQAMAAYIpQnQFwDiAAAAAA==.',['被狗']='被狗带:BAABKgAFFH8IAAITAAgI5RZjBwDsAQATAAgI5RZjBwDsAQAAAA==.',['装逼']='装逼总是被打:BAAAKgADCggICAAAAA==.',['裘德']='裘德洛:BAAAKgAFFAIIAgAAAA==.',['覅侬']='覅侬了:BAAAKgADCgIIAgAAAA==.',['观铃']='观铃:BAAAKgADCgIIAgAAAA==.',['言笑']='言笑晏晏小柒:BAAAKgAFFAYIAwAAAA==.',['诛无']='诛无能:BAAAKgAECgEIAQAAAA==.',['貌似']='貌似無聊:BAABKgAFFH8IAAIHAAgIAQdwCgCtAQAHAAgIAQdwCgCtAQAAAA==.',['贰拾']='贰拾肆伏:BAAAKgAECgcIDQAAAA==.',['贰页']='贰页:BAAAKgAECgYIBgAAAA==.',['赏明']='赏明月的呜:BAAAKgAECgUIBQAAAA==.',['起舞']='起舞:BAAAKgAECgUIBgAAAA==.',['超雄']='超雄患者老胡:BAABKgAFFH8LAAIXAAgI4hlmAwAtAgAXAAgI4hlmAwAtAgAAAA==.',['跳跃']='跳跃之咒:BAAAKgAFFAIIAgAAAA==.',['躺牛']='躺牛:BAAAKgADCgEIAQAAAA==.',['輕輕']='輕輕飘过:BAAAKgAECgMIAwAAAA==.',['轻装']='轻装前行:BAAAKgAECggICAAAAA==.',['轻语']='轻语:BAAAKgAECgcIDAAAAA==.',['轻风']='轻风之语丶:BAABKgAECn8sAAIJAAgIxyElEgCZAgAJAAgIxyElEgCZAgABKgAFFAIIBwAOAEgjAA==.',['这把']='这把放速度灭:BAAAKgADCgYIBgAAAA==.',['违规']='违规人物:BAAAKgADCgYIBgAAAA==.',['迪斯']='迪斯奈特:BAAAKgAECgEIAQAAAA==.',['逆袭']='逆袭的夏亚:BAAAKgADCgEIAQAAAA==.',['逗逼']='逗逼:BAAAKgADCggICAAAAA==.',['逝水']='逝水无痕丨:BAAAKgAFFAQIBAAAAA==.',['速速']='速速寿司叭:BAAAKgAECgMIAwAAAA==.',['道具']='道具:BAAAKgADCgQIBAAAAA==.',['醉璀']='醉璀璨:BAACKgAFFH8JAAIDAAMI/xC0FwDOAAADAAMI/xC0FwDOAAAqAAQKfxUAAgMACAj1HCQaADECAAMACAj1HCQaADECAAAA.',['鑫森']='鑫森淼焱圭:BAAAKgAECggIEQAAAA==.',['锦玛']='锦玛影蒂琦:BAAAKgADCgEIAQAAAA==.',['闪亮']='闪亮小辣椒:BAAAKgAECgYICgAAAA==.',['闪电']='闪电神龙:BAAAKgAECgIIAgAAAA==.',['闲潭']='闲潭梦落花:BAAAKgAECgMIAwAAAA==.',['阳澄']='阳澄湖老王:BAABKgAFFH8FAAMfAAMISQtSBQB4AAACAAMIRgk2IACmAAAfAAIIUQZSBQB4AAAAAA==.',['阿喀']='阿喀硫斯:BAAAKgADCgYIBQAAAA==.',['陌生']='陌生丸子:BAAAKgAFFAgIBAAAAA==.',['隆美']='隆美尔:BAAAKgADCggICAAAAA==.',['随风']='随风起舞:BAAAKgAECgEIAgAAAA==.',['隨地']='隨地大小变:BAAAKgAECgQIBQAAAA==.',['雨中']='雨中邂逅:BAACKgAFFH8HAAMZAAMITAhnQQCaAAAZAAMI1QdnQQCaAAATAAMIsgcuOwCLAAAqAAQKfyIAAxMACAh/HT4nANABABMACAjuGT4nANABABkABwj1HUlIAIcBAAAA.',['雨分']='雨分飞:BAAAKgADCgIIAgAAAA==.',['雨花']='雨花落:BAAAKgAECgYIDQAAAA==.',['雪域']='雪域冰封:BAACKgAFFH8LAAIBAAMIWhrpHgDvAAABAAMIWhrpHgDvAAAqAAQKfxUAAgEACAgwISEdAI4CAAEACAgwISEdAI4CAAAA.',['霜冷']='霜冷爱上:BAAAKgAFFAEIAQAAAA==.',['靁电']='靁电法王:BAAAKgAECgMIBAAAAA==.',['青龍']='青龍:BAAAKgAFFAgICAAAAA==.',['非常']='非常忧郁射神:BAAAKgAFFAYIBAAAAA==.',['靥丶']='靥丶:BAAAKgADCggICwAAAA==.',['风之']='风之德:BAAAKgADCgcIBwAAAA==.',['风暴']='风暴啤酒桶:BAAAKgAECgQIBAAAAA==.',['风起']='风起长林:BAAAKgADCgYIBwAAAA==.',['飞翔']='飞翔的蚂蚁:BAAAKgAFFAQIBAAAAA==.',['馬東']='馬東錫:BAABKgAFFH8LAAIaAAYIZBGUBABxAQAaAAYIZBGUBABxAQAAAA==.',['马歇']='马歇尔:BAAAKgAECgUIBwAAAA==.',['魔法']='魔法注意事项:BAAAKgAECgUIBQAAAA==.',['魷魚']='魷魚筒:BAAAKgAECggIEgAAAA==.',['麦克']='麦克阿瑟:BAABKgAFFH8FAAIVAAUIuwgxFQDLAAAVAAUIuwgxFQDLAAAAAA==.',['黑暗']='黑暗涅槃:BAAAKgAECgYIDAAAAA==.黑暗男爵:BAAAKgAECgYICwAAAA==.',['黑翼']='黑翼灬大魔:BAAAKgAECgQIBgAAAA==.',['黑锋']='黑锋领主:BAACKgAFFH8ZAAILAAMIdw7OCwC9AAALAAMIdw7OCwC9AAAqAAQKfxoAAgsACAjwF0URAJQBAAsACAjwF0URAJQBAAAA.',['黯魔']='黯魔:BAAAKgAFFAMIAwAAAA==.',['齐命']='齐命:BAABKgAFFH8TAAIOAAYIIiWmBwDmAQAOAAYIIiWmBwDmAQAAAA==.',['龍丿']='龍丿貓:BAABKgAECn8tAAQXAAgIoCVEAgDlAgAXAAgIoCVEAgDlAgAeAAgIEB1kEABgAgASAAgIfxdjIgDQAQABKgAFFAgIJwAhAMQjAA==.',['龍城']='龍城狂霸拽:BAAAKgADCgYIBgAAAA==.',['龙贝']='龙贝贝:BAAAKgAECgIIAgAAAA==.',['龙魂']='龙魂雨风:BAAAKgAFFAQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end