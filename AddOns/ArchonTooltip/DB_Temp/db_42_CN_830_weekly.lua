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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Frost','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Vengeance','Shaman-Restoration','Shaman-Enhancement','Shaman-Elemental','Warrior-Fury','Priest-Holy','Druid-Balance','Warlock-Destruction','Warlock-Affliction','Warrior-Arms','Hunter-BeastMastery','Warrior-Protection','Evoker-Devastation','Mage-Frost','Rogue-Subtlety','Rogue-Assassination','DeathKnight-Blood','Druid-Restoration','Monk-Mistweaver','Priest-Discipline','Priest-Shadow','Warlock-Demonology','Mage-Fire','Mage-Arcane','Hunter-Marksmanship','Evoker-Augmentation','Evoker-Preservation','Monk-Windwalker','Druid-Guardian',}; local provider = {region='CN',realm='诺森德',name='CN',type='weekly',zone=42,date='2025-08-08',data={Af='Affliclock:BAAAKgADCgcIBwAAAA==.',Ak='Akiraa:BAAAKgAECgEIAQAAAA==.',Bi='Big:BAAAKgAFFAYIAgAAAA==.',Br='Brush:BAAAKgAECgYIAQAAAA==.',Ch='Chann:BAAAKgAECgIIAgAAAA==.Charlter:BAACKgAFFH8eAAMBAAQIIRsiEQDkAAABAAQIIRsiEQDkAAACAAQIqRFiCQDTAAAqAAQKfysAAgEACAgEImUWAHoCAAEACAgEImUWAHoCAAAA.',Cr='Crzayhb:BAABKgAECn8ZAAQDAAgIqRIWfgCbAQADAAcIfxUWfgCbAQAEAAcI8hHkIgBKAQAFAAEIowG4YwAEAAAAAA==.',Di='Diaz:BAAAKgADCggICAABKgAFFAgIBAAGAAAAAA==.',Ef='Efran:BAAAKgADCgUICAAAAA==.',Em='Emmons:BAAAKgAECggICAAAAA==.',Fr='Frostmournne:BAAAKgADCgcIBwAAAA==.',Ga='Gaea:BAABKgAECn8qAAMHAAgIuBzzCwA9AgAHAAgIuBzzCwA9AgAIAAEI9gSDbQAPAAAAAA==.',Gl='Globefish:BAAAKgAECggICAAAAA==.',Ho='Hownewbee:BAAAKgADCggICAAAAA==.',Ja='Janekin:BAACKgAFFH8jAAIJAAgI0x9MAQCkAgAJAAgI0x9MAQCkAgAqAAQKf5EABAkACAifH/AYADICAAkACAifH/AYADICAAoABQhmCB00AK8AAAsAAQgAADuHAAAAAAAA.',Ka='Kanemx:BAABKgAFFH8GAAIJAAYIAAacMQCzAAAJAAYIAAacMQCzAAABKgAFFAgIDwAKAC4bAA==.',Kk='Kklcen:BAABKgAFFH8RAAIBAAQIBR8BIwALAQABAAQIBR8BIwALAQAAAA==.',Ku='Kuloolo:BAAAKgAECgMIAwAAAA==.',La='Layomoeet:BAAAKgADCggICAAAAA==.',Ma='Masked:BAAAKgADCgIIAgAAAA==.',Na='Nan:BAAAKgAECgYIBgAAAA==.',Ni='Nickcave:BAABKgAFFH8OAAIMAAYIFhVOCgCnAQAMAAYIFhVOCgCnAQAAAA==.',Po='Poppy:BAACKgAFFH8iAAINAAYIXRKwBwD6AAANAAYIXRKwBwD6AAAqAAQKf0YAAg0ACAgaH/gRAEECAA0ACAgaH/gRAEECAAAA.',Pp='Ppbeir:BAAAKgADCgYIBgAAAA==.',Re='Redemption:BAAAKgAFFAUIBAABKgAFFAgIKQAOAGQbAA==.Resafe:BAAAKgAECgUIBQAAAA==.Rewallis:BAAAKgAFFAIIAgAAAA==.',Ru='Runningman:BAABKgAFFH8GAAIPAAYIgRqVEgBzAQAPAAYIgRqVEgBzAQAAAA==.',Si='Sinly:BAAAKgAFFAYIBAABKgAFFAgIBgAQAJkUAA==.',Sk='Sktic:BAAAKgAECggIDQAAAA==.',So='Soulenter:BAAAKgAECgYIBgAAAA==.',St='Stormr:BAAAKgADCggICAAAAA==.Stormsnow:BAAAKgADCggIEAAAAA==.',Sy='Sylviaheng:BAABKgAFFH8WAAMRAAYISiI+AQC+AQARAAYIHh4+AQC+AQAMAAQIpCBtBwAqAQAAAA==.',Te='Teslar:BAAAKgAECgIIAgAAAA==.',Vc='Vc:BAABKgAFFH8OAAISAAYITA+uDQBYAQASAAYITA+uDQBYAQAAAA==.',Vo='Voidembrace:BAAAKgAECggIBwAAAA==.',We='Wellplayed:BAABKgAFFH8YAAMJAAYIbR33CAC3AQAJAAYIbR33CAC3AQAKAAYIyg+RAgCZAQABKgAFFAgICAAJALsbAA==.',Wi='Willburx:BAABKgAFFH8IAAMMAAQIYBGGEgDvAAAMAAQIYBGGEgDvAAATAAMIIQfmCwBTAAABKgAFFAgIHQAUALQTAA==.',Yi='Yibanetlos:BAAAKgAECgMIBAAAAA==.',Yu='Yukirin:BAABKgAFFH8GAAIJAAYITxHtDQAaAQAJAAYITxHtDQAaAQABKgAFFAgICAAJAO0XAA==.',Zh='Zhai:BAABKgAFFH8NAAIVAAYIhh6pBQADAQAVAAYIhh6pBQADAQAAAA==.',Zu='Zuman:BAAAKgADCgIIAwAAAA==.Zumrat:BAAAKgADCggICAAAAA==.',['一啊']='一啊尔萨斯一:BAAAKgAECggICAAAAA==.',['一朵']='一朵五花肉:BAAAKgAECgUIBQAAAA==.一朵奇葩:BAAAKgAECgEIAQAAAA==.一朵福狸:BAABKgAECn8aAAIJAAgI2Rw/GgAqAgAJAAgI2Rw/GgAqAgAAAA==.',['一格']='一格式化一:BAAAKgAFFAEIAQAAAA==.',['一梦']='一梦华胥:BAABKgAFFH8MAAINAAMICB2LIADFAAANAAMICB2LIADFAAAAAA==.',['一辉']='一辉丶:BAAAKgAECggIEAAAAA==.',['七小']='七小淼幸运鹅:BAAAKgAECgQIBAAAAA==.',['丄諦']='丄諦啲仇魜:BAAAKgADCgYIBgAAAA==.',['不会']='不会演戏柯南:BAAAKgAFFAIIAgAAAA==.',['不可']='不可泄漏:BAACKgAFFH8VAAILAAYIRQzsDAAEAQALAAYIRQzsDAAEAQAqAAQKfxwAAgsABwivGoM0AEgBAAsABwivGoM0AEgBAAAA.',['不服']='不服哥练了:BAAAKgADCgEIAQAAAA==.',['不死']='不死幽灵:BAAAKgADCggICAAAAA==.',['不能']='不能懂:BAABKgAECn8dAAMWAAgIASJcAQCnAgAWAAgIKSFcAQCnAgAXAAgIAxkfEAAnAgAAAA==.',['丛容']='丛容:BAAAKgAECgcICQAAAA==.',['东岳']='东岳路:BAACKgAFFH8JAAIBAAMInw9dGACkAAABAAMInw9dGACkAAAqAAQKfyUAAwEACAjOGxgwAPIBAAEACAjOGxgwAPIBABgAAQhLBudtABgAAAAA.',['东门']='东门雨月:BAAAKgAECgYIDQAAAA==.',['丝瓜']='丝瓜裹手:BAABKgAFFH8HAAMOAAYIdBu5CgAZAQAOAAQIIB+5CgAZAQAZAAIIrBXRDADJAAAAAA==.',['丨乊']='丨乊口乊丨:BAABKgAFFH8IAAIaAAQItBZqHAC7AAAaAAQItBZqHAC7AAAAAA==.',['丨果']='丨果果妈丨:BAACKgAFFH8jAAIbAAQIvh9IEgAKAQAbAAQIvh9IEgAKAQAqAAQKfx4AAxsACAhLG2ceAKgBABsACAhLG2ceAKgBABwAAQgwDLE4ACgAAAAA.',['丶惡']='丶惡作劇:BAABKgAECn8YAAIaAAcIgiMXEgBYAgAaAAcIgiMXEgBYAgAAAA==.',['丶慕']='丶慕思思:BAABKgAFFH8GAAIbAAYIjwrcDgAvAQAbAAYIjwrcDgAvAQAAAA==.丶慕瑶:BAABKgAFFH8KAAMFAAYIdRMTEwDjAAAFAAYI1AoTEwDjAAADAAQIZBl7VQDFAAABKgAFFAgIDQADAOEYAA==.',['丶求']='丶求别闹:BAAAKgAFFAQIBAAAAA==.',['丶燎']='丶燎原百斩:BAABKgAFFH8IAAISAAQIqhGqHgDcAAASAAQIqhGqHgDcAAAAAA==.',['九公']='九公子:BAABKgAFFH8FAAIdAAQICiQXBgAYAQAdAAQICiQXBgAYAQAAAA==.',['九漏']='九漏鱼:BAAAKgAFFAIIAgAAAA==.',['乱我']='乱我红尘路:BAAAKgADCgQIBAAAAA==.',['乱絮']='乱絮飞花:BAAAKgADCgMIBAAAAA==.',['二楼']='二楼的理财妹:BAACKgAFFH8HAAISAAIIiiChJQC8AAASAAIIiiChJQC8AAAqAAQKfx8AAhIACAjCI2QNAM8CABIACAjCI2QNAM8CAAAA.',['二泉']='二泉映月:BAABKgAECn8gAAIHAAgIXh9wFwB5AgAHAAgIXh9wFwB5AgAAAA==.',['于晏']='于晏:BAAAKgADCgMIAwAAAA==.',['仁慈']='仁慈的锤子:BAAAKgAECgQIBAAAAA==.',['今天']='今天刀没带:BAAAKgADCggICAAAAA==.',['仗剑']='仗剑人生:BAAAKgAECgEIAQAAAA==.',['仙水']='仙水无人像我:BAAAKgAECgEIAQAAAA==.',['以吻']='以吻封缄:BAAAKgADCgMIAwAAAA==.',['以无']='以无德服人:BAABKgAFFH8IAAIOAAQI6xqLDwD9AAAOAAQI6xqLDwD9AAAAAA==.',['任凭']='任凭风浪起:BAAAKgAECgUIBQAAAA==.',['伊利']='伊利斯丹:BAAAKgADCgQIBAAAAA==.',['伊姆']='伊姆帕里斯:BAABKgAFFH8MAAIDAAQIDBb6HADwAAADAAQIDBb6HADwAAAAAA==.',['伊瑟']='伊瑟推:BAABKgAFFH8GAAIUAAYIpyQFBwAdAgAUAAYIpyQFBwAdAgAAAA==.',['传说']='传说有条龙:BAABKgAFFH8ZAAIUAAgIywnWCgCcAQAUAAgIywnWCgCcAQAAAA==.',['佑引']='佑引号:BAAAKgAECgcICQAAAA==.',['佛山']='佛山无影擦:BAAAKgAECgUIDAAAAA==.',['佝偻']='佝偻:BAAAKgAECgYICQAAAA==.',['你亲']='你亲舅舅突然:BAABKgAFFH8JAAMCAAYIhR47AgDOAQACAAYIhR47AgDOAQABAAMIuQQxQQCZAAAAAA==.',['你会']='你会玩增强吗:BAAAKgAECggIDQAAAA==.你会玩风怒吗:BAAAKgAECgcIBwAAAA==.',['你家']='你家的白菜:BAAAKgAECgYIDgAAAA==.',['依然']='依然诺尔:BAAAKgADCgEIAQAAAA==.',['侠之']='侠之大者:BAABKgAFFH8IAAIXAAgI2w9pBgAdAgAXAAgI2w9pBgAdAgAAAA==.',['侠影']='侠影之谜:BAABKgAECn8eAAIDAAgI5AF1GwFOAAADAAgI5AF1GwFOAAAAAA==.',['信仰']='信仰丶尘埃:BAABKgAFFH8FAAIMAAQIfCI+BwAsAQAMAAQIfCI+BwAsAQAAAA==.',['僧敲']='僧敲月下门:BAAAKgAECggICQAAAA==.',['克里']='克里斯胧:BAAAKgADCggICAAAAA==.',['八六']='八六下山了:BAABKgAFFH8IAAIYAAQIuQ7+EwCoAAAYAAQIuQ7+EwCoAAABKgAFFAgIDgABAIsMAA==.',['八月']='八月火:BAAAKgAECgcIBwAAAA==.',['冰块']='冰块姐:BAAAKgAECggIDAAAAA==.',['冰封']='冰封夜雪:BAAAKgAFFAEIAQAAAA==.冰封大地:BAACKgAFFH8PAAMDAAUIkwl5YQCtAAADAAQIrAp5YQCtAAAFAAEISQYDKwA2AAAqAAQKfxcAAwUACAjdC+8sAPIAAAUABwgfDO8sAPIAAAMAAQhWCmRzATYAAAAA.',['冰川']='冰川下的挽歌:BAAAKgAECgMIAwAAAA==.',['冰指']='冰指丶绕微凉:BAABKgAFFH8IAAIYAAgIOwUjBwA7AQAYAAgIOwUjBwA7AQAAAA==.',['冰霜']='冰霜哥布林:BAABKgAECn8VAAIJAAgIfRiKLADJAQAJAAgIfRiKLADJAQAAAA==.',['凤凰']='凤凰的姐姐:BAAAKgADCgEIAQAAAA==.',['凯兰']='凯兰丶崔尔:BAABKgAFFH8ZAAIOAAYIeiBRDADRAQAOAAYIeiBRDADRAQABKgAECggIGAAHAPQhAA==.',['凯尼']='凯尼血蹄:BAAAKgAFFAgIBAAAAA==.',['凰月']='凰月亮:BAACKgAFFH8mAAINAAQIHhSJJACxAAANAAQIHhSJJACxAAAqAAQKfzsAAg0ACAieEyI1AGsBAA0ACAieEyI1AGsBAAAA.',['出门']='出门没带图腾:BAAAKgAECgYIDAABKgAFFAMIEwAEAEwTAA==.',['刀刀']='刀刀砍到身:BAAAKgAECgQIBAAAAA==.',['刘海']='刘海柱:BAABKgAFFH8HAAMeAAQIpgHcCwBsAAAeAAQIkgHcCwBsAAAVAAMIzAGCFgA1AAAAAA==.',['初恋']='初恋似焱:BAAAKgAECgQIBwAAAA==.',['别怕']='别怕我来了:BAACKgAFFH8qAAMBAAgIBxshDQC+AQABAAgIBxshDQC+AQACAAIIJRgBDgCXAAAqAAQKfx8ABAEACAgnITwdAFICAAEACAhsHzwdAFICABgABwhwGVQJAIwBAAIAAQgmHhAxAFUAAAAA.',['到处']='到处溜达:BAAAKgAECgQIBAAAAA==.',['刺青']='刺青:BAAAKgAECgYIBgAAAA==.',['加爾']='加爾魯什:BAACKgAFFH8IAAIMAAYIBxnYDACAAQAMAAYIBxnYDACAAQAqAAQKfxoAAgwACAjDHXkSAEcCAAwACAjDHXkSAEcCAAEqAAUUCAgOABIAQh8A.',['動感']='動感超牛:BAAAKgADCgEIAQAAAA==.',['北极']='北极小妖:BAAAKgAECgQIBAAAAA==.北极尛妖:BAAAKgAECggICgAAAA==.',['千变']='千变者贾修:BAAAKgAECggICAAAAA==.',['卅木']='卅木:BAAAKgAECggIEgAAAA==.卅木丶:BAAAKgADCgYIBgAAAA==.',['午间']='午间新闻:BAAAKgADCgIIAgAAAA==.',['华优']='华优冰其斯:BAAAKgADCggICAAAAA==.',['单刷']='单刷黑暗神殿:BAAAKgAECggICAAAAA==.',['卖鹌']='卖鹌鹑的女孩:BAACKgAFFH8PAAIOAAQIIx7oEwDrAAAOAAQIIx7oEwDrAAAqAAQKfykAAg4ACAhkJaMHAN8CAA4ACAhkJaMHAN8CAAAA.',['卜酷']='卜酷塔丶:BAAAKgADCgIIAgAAAA==.',['卡姿']='卡姿兰大眼棱:BAAAKgAECggIEAAAAA==.',['卡布']='卡布奇诺:BAAAKgADCgMIAwAAAA==.',['卤牛']='卤牛肉:BAACKgAFFH8WAAQRAAYIfRhdBQAOAQARAAQITh5dBQAOAQATAAYI/BBhBgAMAQAMAAMIqQ//EQDgAAAqAAQKfxUAAhEABwhBHLIsAFYBABEABwhBHLIsAFYBAAAA.',['叁柱']='叁柱子丶:BAAAKgAECggICAAAAA==.',['友德']='友德:BAAAKgADCgcIBwAAAA==.',['古蘭']='古蘭森:BAAAKgAECggIDgAAAA==.',['吃点']='吃点啥呢:BAABKgAFFH8MAAMDAAYImhNVIADoAAADAAYI9Q9VIADoAAAFAAIIagzXDwCHAAAAAA==.',['吃饭']='吃饭不讲李:BAAAKgAECgQIBgAAAA==.',['后来']='后来想过我嘛:BAAAKgAECgYIBgAAAA==.',['向我']='向我一样:BAAAKgAECgMIBAAAAA==.向我冲锋:BAAAKgADCgQIBgAAAA==.',['吴彦']='吴彦祖传贴膜:BAAAKgAECgcIDgAAAA==.',['呀哈']='呀哈哈:BAAAKgAFFAQIAgAAAA==.',['呆呆']='呆呆遛宠:BAAAKgAFFAgIBAAAAA==.',['咕噜']='咕噜咕噜噜:BAABKgAFFH8GAAMZAAMIbBIBHQC8AAAZAAMIbBIBHQC8AAAOAAMIGAuVHwC1AAAAAA==.',['哇噢']='哇噢打得不错:BAAAKgADCggICAAAAA==.',['哈基']='哈基冰:BAAAKgAECgcIBwAAAA==.',['哥本']='哥本哈根:BAAAKgAFFAgIBAAAAA==.',['哲里']='哲里:BAAAKgAFFAYIBAABKgAFFAgIGgABAEwhAA==.',['啊德']='啊德:BAAAKgAFFAEIAQAAAA==.',['喏兹']='喏兹多姆:BAAAKgAFFAgIBAAAAA==.',['囡囝']='囡囝婧儿:BAAAKgAFFAIIAgAAAA==.',['圣光']='圣光失败了:BAAAKgAECgEIAQAAAA==.',['圣魔']='圣魔之泪:BAABKgAFFH8GAAIFAAYI5BCkDgAVAQAFAAYI5BCkDgAVAQAAAA==.',['在座']='在座的都是渣:BAAAKgAECgIIAgAAAA==.',['墨阳']='墨阳:BAAAKgAECggICQAAAA==.',['壹月']='壹月丶:BAAAKgAECggIEAAAAA==.',['夏暖']='夏暖:BAAAKgAFFAUIAQAAAA==.',['夏珂']='夏珂琦:BAABKgAFFH8IAAIfAAgIkiMzAQDeAgAfAAgIkiMzAQDeAgAAAA==.',['多喝']='多喝开水:BAAAKgADCgUIBQAAAA==.',['夜神']='夜神木木:BAAAKgAFFAYIAgABKgAFFAgIFgABAGsZAA==.夜神龙一:BAAAKgAFFAQIBAAAAA==.',['大势']='大势至菩萨:BAAAKgADCgMIAwAAAA==.',['大寒']='大寒:BAABKgAECn8YAAIgAAgIVRYADwDeAQAgAAgIVRYADwDeAQAAAA==.',['大湾']='大湾区酋长:BAAAKgAECgIIAwAAAA==.',['大肉']='大肉先生:BAAAKgADCgcIBwAAAA==.大肉酱:BAAAKgAECgYICQAAAA==.',['大腿']='大腿码二腿:BAACKgAFFH8TAAMEAAMITBNKBwDdAAAEAAMITBNKBwDdAAADAAMIexafTQDUAAAqAAQKfysAAwMACAiQHuAuAEQCAAMACAiQHuAuAEQCAAQACAgBG0gVAMcBAAAA.',['大鲨']='大鲨鱼吃小鱼:BAABKgAFFH8OAAIDAAgIMyHGAwCjAgADAAgIMyHGAwCjAgAAAA==.',['天机']='天机:BAAAKgADCggICQAAAA==.',['天灾']='天灾将领:BAAAKgAECgIIAgAAAA==.',['失憶']='失憶可樂:BAAAKgAECgIIAgAAAA==.',['妳的']='妳的样子:BAABKgAFFH8GAAIBAAYILAqfGQBQAQABAAYILAqfGQBQAQAAAA==.',['娜美']='娜美美:BAACKgAFFH8GAAMDAAMIFxIIXAC5AAADAAMIFxIIXAC5AAAEAAII0AMOFgA6AAAqAAQKfxkAAwQACAg1GQsfAGkBAAQABwicGQsfAGkBAAMAAwikEUgEAbAAAAAA.',['季博']='季博初:BAABKgAFFH8IAAIDAAQI8Qm2LgCrAAADAAQI8Qm2LgCrAAAAAA==.季博粗:BAAAKgAECggIBwAAAA==.',['孤独']='孤独与清酒丶:BAACKgAFFH8GAAIYAAYIlhJrBgAsAQAYAAYIlhJrBgAsAQAqAAQKfxgAAwEACAiyIosOAKwCAAEACAiyIosOAKwCABgABghvCGxGAKMAAAEqAAUUCAgMAAEA9REA.',['守护']='守护信仰:BAABKgAFFH8aAAQTAAYIPSAlBQAsAQAMAAYIPSDkBwDiAQATAAYIZhMlBQAsAQARAAEIsQ6HKQBIAAAAAA==.守护梦琦之宝:BAAAKgADCgUIBQAAAA==.',['安吉']='安吉利:BAAAKgAECgYICwAAAA==.',['安妮']='安妮妮:BAAAKgAECgYICAAAAA==.',['宝宝']='宝宝:BAABKgAECn8vAAIeAAgIhyMOAwDUAgAeAAgIhyMOAwDUAgAAAA==.',['宠老']='宠老婆会发财:BAABKgAFFH8FAAICAAMI5QsKCwC7AAACAAMI5QsKCwC7AAABKgAFFAMIEwAEAEwTAA==.',['家烧']='家烧青头菌:BAABKgAFFH8SAAQNAAYIMxp1CgApAQANAAYIhRZ1CgApAQAbAAYIAhL9IACfAAAcAAEIFwUvLgA9AAAAAA==.',['宸心']='宸心宸意:BAAAKgADCgEIAQAAAA==.',['射的']='射的准:BAAAKgADCgYIBgAAAA==.',['小太']='小太子奶:BAABKgAECn8fAAIJAAgIZBj/JgDyAQAJAAgIZBj/JgDyAQAAAA==.',['小姜']='小姜果:BAABKgAFFH8OAAIHAAYIVx1DCAA3AQAHAAYIVx1DCAA3AQAAAA==.',['小小']='小小的师牧:BAAAKgAECgYIDQABKgAFFAcIGgAbAMwcAA==.小小的牛魔:BAABKgAECn8gAAMBAAgIMhoPQQCtAQABAAcIShsPQQCtAQAYAAEIpBMkZAA2AAABKgAFFAcIGgAbAMwcAA==.小小的萨满:BAAAKgADCgcIBwAAAA==.小小的龙人:BAAAKgAECgMIBAABKgAFFAcIGgAbAMwcAA==.',['小德']='小德丶:BAAAKgAECgIIAgABKgAECggIDAAGAAAAAA==.',['小掀']='小掀女:BAAAKgAECgcICgAAAA==.',['小海']='小海豚:BAABKgAFFH8QAAMbAAgIwwsRBQCNAQAbAAgIxggRBQCNAQANAAQICRNvEgCxAAAAAA==.',['小爱']='小爱酱:BAAAKgAECgQIBQAAAA==.',['小狐']='小狐涂神:BAABKgAFFH8OAAMSAAgIWBaGEAB1AQASAAcIlBCGEAB1AQAgAAYIYhdLDwBuAQAAAA==.',['小白']='小白不白丶:BAAAKgAECgYIBgAAAA==.',['小礼']='小礼包:BAAAKgADCgQIBAAAAA==.',['小福']='小福音:BAABKgAFFH8MAAMNAAYI1hHnHADZAAANAAUIgA3nHADZAAAcAAIInR6kGQCxAAABKgAFFAgIBgANAKsLAA==.',['小野']='小野莉莎:BAAAKgADCggICAAAAA==.',['小马']='小马先生:BAACKgAFFH8jAAMfAAYIIRtHEgBVAQAfAAYIIRtHEgBVAQAeAAQIRQ66IADTAAAqAAQKf0YABB4ACAgcJdQLALUCAB4ACAhVItQLALUCAB8ABQj4JakrAKkBABUABgjAFxJVABEBAAAA.',['小黑']='小黑不白丶:BAAAKgAECggIAgAAAA==.',['小龍']='小龍馨:BAAAKgAECggIDQAAAA==.',['尐迪']='尐迪兒:BAAAKgAECggICAAAAA==.',['少特']='少特:BAAAKgAFFAIIAgAAAA==.',['尕峦']='尕峦:BAABKgAECn8fAAMDAAgI5CG7EgA7AgADAAgI5CG7EgA7AgAFAAEIfgfGXAAZAAAAAA==.',['巴啦']='巴啦啦小奶仙:BAAAKgAECgQIBAAAAA==.',['布狗']='布狗:BAAAKgADCgYICQAAAA==.',['布莱']='布莱克哈特:BAABKgAFFH8GAAIDAAYI0BXaGACXAQADAAYI0BXaGACXAQAAAA==.',['帅比']='帅比伊利蛋:BAAAKgAECgEIAQAAAA==.',['帅贼']='帅贼:BAABKgAFFH8OAAIDAAMIvAr2XgCzAAADAAMIvAr2XgCzAAAAAA==.',['师承']='师承壹拾叁:BAAAKgADCggICAAAAA==.',['希斯']='希斯莱洁:BAAAKgAFFAQIBAAAAA==.',['希望']='希望皇迪迦:BAAAKgADCggIDQAAAA==.',['幻世']='幻世靈歆:BAABKgAFFH8IAAIDAAgI2Q7aCwDlAQADAAgI2Q7aCwDlAQAAAA==.',['幻影']='幻影刃怒风:BAABKgAECn8dAAMIAAgInQmANQDnAAAIAAgInQmANQDnAAAHAAEI/AEBpwAYAAAAAA==.',['幻月']='幻月黯然:BAAAKgAECgUIBQAAAA==.',['幽冥']='幽冥蓝焰:BAABKgAFFH8NAAMdAAQIUwlYEgCuAAAdAAQIUwlYEgCuAAAQAAIIpwIXEABSAAAAAA==.',['幽明']='幽明孽灵:BAAAKgADCgEIAQAAAA==.',['座杀']='座杀博徒:BAAAKgAFFAEIAQABKgAECggIGgABABQkAA==.',['弹性']='弹性胖胖:BAAAKgADCgEIAQAAAA==.',['当我']='当我们宅一起:BAAAKgADCggICAAAAA==.',['德德']='德德快跑:BAAAKgAECgYIBgAAAA==.',['心软']='心软脾气爆:BAABKgAFFH8PAAQdAAgIsSF1AQCfAQAPAAgIDRhuCQDDAQAdAAUI1CJ1AQCfAQAQAAEIRSJcGwBnAAAAAA==.',['快来']='快来吃糖:BAAAKgAFFAIIAgAAAA==.',['快躲']='快躲开:BAAAKgAECggIDQAAAA==.',['怀特']='怀特卖点分:BAAAKgAFFAIIAgAAAA==.',['恶魔']='恶魔鹿:BAAAKgAECgIIAwAAAA==.',['悪魔']='悪魔猟手:BAACKgAFFH8GAAMHAAQILAecPACLAAAHAAIIEAmcPACLAAAIAAIISAVlIwBJAAAqAAQKfx8AAggACAgMDWkvAAsBAAgACAgMDWkvAAsBAAAA.',['悲酒']='悲酒独酌:BAABKgAFFH8FAAMPAAUIaAzqKwC+AAAPAAMIVg3qKwC+AAAdAAIIoAncLgA9AAAAAA==.',['惯性']='惯性伤情:BAAAKgAECgcIEAAAAA==.',['想你']='想你就天晴:BAAAKgAFFAIIAgAAAA==.',['想入']='想入菲菲:BAAAKgAFFAQIBAABKgAFFAgICAAXAMYWAA==.',['意中']='意中人:BAAAKgAECgYIBgAAAA==.',['意大']='意大利教父:BAAAKgAECgYIBgAAAA==.',['意迟']='意迟迟:BAAAKgAECgMIBAAAAA==.',['愛已']='愛已堔埋:BAAAKgAECggIEQAAAA==.',['愿圣']='愿圣光忽悠你:BAAAKgAFFAQIBAABKgAFFAgIDAADABAkAA==.',['慕羽']='慕羽陌浅浅:BAAAKgAECgQIBwAAAA==.',['懒人']='懒人:BAAAKgAECgYICAAAAA==.',['懒觉']='懒觉比像大:BAAAKgAFFAMIAwAAAA==.',['戀戀']='戀戀訫談談愛:BAABKgAFFH8IAAIfAAgIlhP3BgAdAgAfAAgIlhP3BgAdAgAAAA==.',['我是']='我是杀猪的哦:BAAAKgAECgEIAQAAAA==.',['我没']='我没有嗜血:BAAAKgAECgYICgAAAA==.',['我爱']='我爱你呀:BAACKgAFFH8NAAMLAAUI3R6mCQD6AAALAAQIIhymCQD6AAAKAAEIECcCGgB1AAAqAAQKfzUAAgsACAgMJloBAAoDAAsACAgMJloBAAoDAAAA.',['我的']='我的坦穿布甲:BAABKgAFFH8IAAIDAAgIyiAFGACdAQADAAgIyiAFGACdAQAAAA==.我的小小法:BAAAKgAFFAEIAQABKgAFFAcIGgAbAMwcAA==.我的小小牛:BAAAKgADCggICAAAAA==.',['我看']='我看的见:BAACKgAFFH8LAAIHAAQI5BpPDgAIAQAHAAQI5BpPDgAIAQAqAAQKfx0AAgcACAjgHSwgAAMCAAcACAjgHSwgAAMCAAAA.',['打小']='打小就壮:BAAAKgADCggICAAAAA==.打小就猛:BAABKgAECn8pAAMLAAgIdheAJgDAAQALAAgIdheAJgDAAQAKAAYIUA4iNAAiAQAAAA==.',['扛最']='扛最惨的揍:BAAAKgAECggICAAAAA==.',['抓个']='抓个癞克包:BAAAKgAFFAQIBAAAAA==.',['抗还']='抗还是打:BAABKgAFFH8IAAIHAAQIBQOKIgCCAAAHAAQIBQOKIgCCAAAAAA==.',['护国']='护国神牛:BAAAKgAECgIIAgAAAA==.',['抹茶']='抹茶柠檬:BAAAKgAFFAEIAQAAAA==.抹茶芒果:BAAAKgAECgMIBQAAAA==.抹茶苹果:BAAAKgAECgQIBAAAAA==.抹茶香蕉:BAAAKgAECgEIAQAAAA==.',['拉克']='拉克丝克莱因:BAABKgAFFH8SAAMcAAgINhliBQDoAQAcAAcIHRpiBQDoAQANAAYIIxwoCQCSAQAAAA==.',['提莫']='提莫大魔王:BAABKgAECn8WAAIbAAgImhIpJACAAQAbAAgImhIpJACAAQAAAA==.',['提醒']='提醒我补智力:BAAAKgAECgMIBAAAAA==.',['插得']='插得紧:BAAAKgAFFAEIAQAAAA==.',['摁恩']='摁恩嗯:BAAAKgAECgcICQAAAA==.',['敌法']='敌法不出狂战:BAAAKgADCgIIAgAAAA==.',['敲敲']='敲敲咪丶咪:BAAAKgADCgIIAgAAAA==.',['斩飏']='斩飏:BAAAKgADCgUIBwAAAA==.',['旋风']='旋风小雄:BAAAKgAECgQIBAAAAA==.',['无仙']='无仙道宸丶:BAAAKgAECgQIBAAAAA==.',['无忧']='无忧:BAAAKgADCggICwAAAA==.',['无情']='无情黑寡妇:BAAAKgADCgUIBQAAAA==.',['无穷']='无穷碧:BAAAKgADCgIIAwAAAA==.',['明月']='明月幾時有:BAAAKgADCgcIBwAAAA==.',['普化']='普化:BAAAKgAECgIIAgAAAA==.',['暗夜']='暗夜魔王:BAABKgAECn8XAAIDAAgImxY5KgB5AQADAAgImxY5KgB5AQAAAA==.',['暮雨']='暮雨听蝉:BAACKgAFFH8dAAIUAAYItBMeDwBuAQAUAAYItBMeDwBuAQAqAAQKfyUABBQACAicGCYeAMgBABQACAicGCYeAMgBACEAAwh+BlAIAD0AACIAAQjRAVosACAAAAAA.暮雨寒烟:BAAAKgAECggIEgAAAA==.暮雨寒煙:BAAAKgAECgMIAwAAAA==.',['曾經']='曾經的祸氺:BAAAKgAFFAgIBAAAAA==.',['最好']='最好的丶我們:BAAAKgAFFAQIBAAAAA==.',['月下']='月下小红娘:BAAAKgADCggICAAAAA==.',['月夜']='月夜风灵:BAAAKgAFFAMIAwABKgAFFAQIGAASANUTAA==.',['月漾']='月漾:BAAAKgADCgMIAwAAAA==.',['木有']='木有粗面:BAAAKgAECgMIAwAAAA==.',['术术']='术术安扣:BAAAKgADCgEIAQAAAA==.',['朴国']='朴国昌:BAAAKgAECggIDgAAAA==.',['李二']='李二虎:BAAAKgAFFAgIBAAAAA==.',['杏仁']='杏仁冰淇淋:BAAAKgAFFAQIAgAAAA==.',['来杯']='来杯冰可乐嘛:BAAAKgAECgIIAgAAAA==.',['枸杞']='枸杞泡茶:BAAAKgAECgYICAAAAA==.',['栗丨']='栗丨子:BAACKgAFFH8HAAMSAAIIdROJNACPAAASAAIIdROJNACPAAAgAAEIHwT7KwA1AAAqAAQKfxoAAyAACAgoGFw4AHcBACAACAiVFFw4AHcBABIABAgrF5GbAJAAAAAA.',['桑酒']='桑酒:BAABKgAFFH8QAAIHAAYIzhWZDgAGAQAHAAYIzhWZDgAGAQAAAA==.',['梦惊']='梦惊雨:BAAAKgAECggICQAAAA==.',['梦行']='梦行者:BAACKgAFFH8iAAIaAAUITCCRCwBuAQAaAAUITCCRCwBuAQAqAAQKfzwAAxoACAiMI6cLAJACABoACAiMI6cLAJACACMAAQjOEKNjADYAAAAA.',['横浜']='横浜桥小爷叔:BAAAKgADCgQIBAAAAA==.',['橙皇']='橙皇喵:BAABKgAECn8YAAIHAAgIdBQ8NgDTAQAHAAgIdBQ8NgDTAQAAAA==.',['正义']='正义的圣光:BAAAKgAECgIIAgAAAA==.',['武器']='武器大师丶:BAAAKgAECgQIBAAAAA==.',['死寂']='死寂:BAAAKgAFFAQIBAAAAA==.',['氯化']='氯化钠:BAAAKgADCgMIAwAAAA==.',['永泰']='永泰辣仔鹏:BAAAKgAFFAMIAwAAAA==.',['永罚']='永罚大剑:BAABKgAECn8cAAMBAAgIJx5vIQA6AgABAAgIihxvIQA6AgAYAAUIWx2vJwBNAQAAAA==.',['江户']='江户小川:BAAAKgAECgYIBwAAAA==.',['沐语']='沐语沫芊芊:BAAAKgAECgQIBAAAAA==.',['没有']='没有名字:BAABKgAFFH8GAAISAAIIOBF3NQCNAAASAAIIOBF3NQCNAAAAAA==.',['沧浪']='沧浪之水:BAABKgAFFH8RAAMYAAQIyBjYDQDRAAABAAQIbxMUFQDkAAAYAAQI6RTYDQDRAAAAAA==.',['法拉']='法拉夏利:BAACKgAFFH8NAAIDAAMIDhrKTADVAAADAAMIDhrKTADVAAAqAAQKfxgAAwMACAjBIx4tAEsCAAMACAjoIR4tAEsCAAUABQilE3QuAOcAAAAA.',['泡泡']='泡泡糖:BAABKgAFFH8IAAISAAQI2B/BJAD0AAASAAQI2B/BJAD0AAAAAA==.泡泡鱼:BAABKgAFFH8IAAMDAAQI7R22DwAVAQADAAQI7R22DwAVAQAFAAQIqhUBGwChAAAAAA==.',['波风']='波风丶水门:BAAAKgADCgQIBAAAAA==.',['泰蕾']='泰蕾狗萨:BAABKgAFFH8IAAIJAAgI+wVFCgBhAQAJAAgI+wVFCgBhAQAAAA==.',['洋西']='洋西米:BAAAKgAECggIEAAAAA==.',['洛丹']='洛丹伦丶觞挽:BAABKgAFFH8RAAICAAgIyAlVAwDiAQACAAgIyAlVAwDiAQAAAA==.',['洛兮']='洛兮:BAACKgAFFH8VAAIDAAQIExucKADQAAADAAQIExucKADQAAAqAAQKfyQAAgMACAh1GR1bAOgBAAMACAh1GR1bAOgBAAAA.洛兮丿:BAAAKgAECggICAAAAA==.',['流星']='流星归来:BAAAKgAFFAQIBAAAAA==.',['海棠']='海棠丶:BAABKgAECn8dAAISAAgIyiT9AgDwAgASAAgIyiT9AgDwAgAAAA==.',['深渊']='深渊漫步者:BAAAKgAFFAIIAgAAAA==.',['混乱']='混乱军士:BAAAKgAECgMIAwAAAA==.',['混吃']='混吃灬等死:BAABKgAFFH8GAAIeAAYI7BgyDQBkAQAeAAYI7BgyDQBkAQAAAA==.',['清玥']='清玥:BAAAKgAECgYIBgAAAA==.',['溺水']='溺水丶三天:BAABKgAFFH8RAAIOAAYIER7iAQDCAQAOAAYIER7iAQDCAQAAAA==.',['潆绕']='潆绕:BAAAKgAECggICAAAAA==.',['灬小']='灬小胖胖灬:BAAAKgAECgMIBQAAAA==.',['灬暴']='灬暴躁小熊灬:BAAAKgADCgMIAwAAAA==.',['無情']='無情丶怒刃:BAAAKgAECggICQAAAA==.',['無畏']='無畏之盾:BAAAKgAECgMIAwAAAA==.',['焱火']='焱火:BAAAKgAECggIEAAAAA==.',['焱炀']='焱炀:BAAAKgAECgYIBgAAAA==.',['熊牧']='熊牧猫师:BAACKgAFFH8RAAINAAUIRAogEgC0AAANAAUIRAogEgC0AAAqAAQKfyUAAg0ACAjBFBk3AGIBAA0ACAjBFBk3AGIBAAAA.',['熊猫']='熊猫人之谜:BAAAKgAECgUIBQAAAA==.',['熏悟']='熏悟空:BAAAKgAECgQIBAAAAA==.',['爱的']='爱的飞行日记:BAAAKgAFFAMIAwAAAA==.',['爵士']='爵士圣光:BAAAKgADCgcIBwAAAA==.',['牛妞']='牛妞青青:BAAAKgAECggICAAAAA==.',['牧清']='牧清凤:BAACKgAFFH8VAAIJAAgIvRX4BwDIAQAJAAgIvRX4BwDIAQAqAAQKfyYAAwkACAipJG8HALoCAAkACAipJG8HALoCAAsABgj/Bw1RALgAAAAA.牧清枫:BAAAKgAECgYIBgAAAA==.',['狐坦']='狐坦:BAAAKgAECgIIAgAAAA==.',['猎影']='猎影苍穹灬:BAAAKgADCgIIAgAAAA==.',['猎阳']='猎阳:BAAAKgAECgcIBwAAAA==.',['猎食']='猎食王者:BAAAKgAECgQIBQAAAA==.',['猛牛']='猛牛冰绿茶:BAAAKgAECgUIBwAAAA==.',['獨舞']='獨舞丶月影:BAACKgAFFH8kAAIkAAYIJQo2AwCRAAAkAAYIJQo2AwCRAAAqAAQKf0AAAiQACAiMGZkIAO8BACQACAiMGZkIAO8BAAAA.',['王大']='王大鸡:BAAAKgAFFAYIBAAAAA==.',['王小']='王小丫:BAABKgAFFH8HAAQQAAQINSJcBwDuAAAQAAMIgiBcBwDuAAAPAAMIYSR1EwDXAAAdAAEIAABoJAAAAAABKgAFFAgIEwAPAPIiAA==.王小鸭:BAAAKgAECggICAAAAA==.',['珍妮']='珍妮玛尖:BAAAKgAECgYIBwAAAA==.珍妮玛水:BAAAKgAECgQICAABKgAFFAgIDQALAN0eAA==.',['珞珈']='珞珈:BAABKgAFFH8GAAIPAAYIbxmyAgCqAQAPAAYIbxmyAgCqAQAAAA==.',['田馥']='田馥甄:BAABKgAFFH8PAAIXAAYIag0tCABwAQAXAAYIag0tCABwAQAAAA==.',['电磁']='电磁炉:BAAAKgAECgMIAwAAAA==.电磁炉高手:BAAAKgAFFAMIAwAAAA==.',['痛太']='痛太痛了:BAAAKgAFFAEIAQAAAA==.',['痛苦']='痛苦不痛苦:BAAAKgAECgUIBQAAAA==.',['發財']='發財哥哥:BAAAKgAECgQIBAAAAA==.發財妹妹:BAAAKgADCgQIBAAAAA==.',['白月']='白月梵星:BAABKgAFFH8JAAMCAAUIbhZZBABMAQACAAUIDBJZBABMAQAYAAQIMhPNEAAeAQABKgAFFAgIIQAYAP4VAA==.',['白板']='白板妹妹:BAAAKgAECgUIBQAAAA==.',['白靈']='白靈:BAAAKgAECgIIAgAAAA==.',['皓腕']='皓腕凝霜雪:BAACKgAFFH8HAAIVAAMIlAwVDQDDAAAVAAMIlAwVDQDDAAAqAAQKfywABBUACAi3H4sRAHICABUACAi3H4sRAHICAB8ABQiFEzQXAO0AAB4ABAhmCHp0AKYAAAAA.',['看吾']='看吾眼神行事:BAAAKgAECgUIBwAAAA==.',['看我']='看我有两个头:BAABKgAECn8iAAMDAAgIehgKYACgAQADAAgIehgKYACgAQAFAAEI7QO7bAALAAAAAA==.',['眼神']='眼神杀死你:BAAAKgAECgMIBQAAAA==.',['砍起']='砍起来伐是拧:BAAAKgAECgMIAwAAAA==.',['硬又']='硬又长:BAAAKgADCggICwAAAA==.',['硬得']='硬得很:BAAAKgAECggIDgAAAA==.',['碎碎']='碎碎小恶魔:BAAAKgAFFAgIBAAAAA==.',['神龍']='神龍大侠:BAAAKgADCggICAAAAA==.',['离落']='离落:BAAAKgAECgEIAgAAAA==.',['空降']='空降师:BAAAKgADCgQIBAAAAA==.',['竹蜻']='竹蜻蜓的擦肩:BAABKgAECn8YAAMRAAgI9APwSACFAAARAAcI6ALwSACFAAATAAYIlQPcHwBNAAAAAA==.',['米开']='米开朗琪罗丶:BAABKgAFFH8JAAIOAAMICBB3NwDCAAAOAAMICBB3NwDCAAAAAA==.',['米雪']='米雪丶大人:BAABKgAECn8YAAMHAAgI9CGkKQAQAgAHAAgIHCGkKQAQAgAIAAgIBxcfGQDCAQAAAA==.',['粘大']='粘大辣生气士:BAAAKgADCgMIAwAAAA==.',['糖渍']='糖渍冬樱花:BAABKgAFFH8NAAIDAAgIzQotDQDPAQADAAgIzQotDQDPAQAAAA==.',['糖门']='糖门棍术:BAAAKgAFFAIIAgAAAA==.',['约格']='约格莫夫意志:BAABKgAFFH8GAAMdAAYIABdvAAB6AQAdAAUI1BpvAAB6AQAPAAEIsQe4LABUAAAAAA==.',['纵有']='纵有离别意:BAAAKgAECggIEwAAAA==.',['结城']='结城亚丝娜:BAABKgAFFH8FAAIcAAUIUQk9CAAlAQAcAAUIUQk9CAAlAQAAAA==.',['缱绻']='缱绻感:BAABKgAFFH8IAAIHAAQIHAw6NACwAAAHAAQIHAw6NACwAAAAAA==.',['缺德']='缺德的组上我:BAABKgAFFH8KAAMOAAYIxBYGNADJAAAOAAQIgxQGNADJAAAZAAUIwg+MGwDGAAAAAA==.',['美不']='美不美先看腿:BAAAKgADCgcIBwAAAA==.',['翾翾']='翾翾:BAAAKgAECgcIBgABKgAFFAgIBAAGAAAAAA==.翾翾牛肉人:BAAAKgAFFAQIBAAAAA==.',['老丶']='老丶爹:BAAAKgAECgMIAwAAAA==.',['聆听']='聆听星的低语:BAAAKgAECgQIBwAAAA==.聆听月的心事:BAACKgAFFH8QAAIDAAMIcRuEPgD2AAADAAMIcRuEPgD2AAAqAAQKfx4AAgMACAiLIrwXAKgCAAMACAiLIrwXAKgCAAAA.聆听血的哀嚎:BAAAKgAECgIIAgAAAA==.',['聖者']='聖者爲王:BAACKgAFFH8QAAISAAMIqBBWNADBAAASAAMIqBBWNADBAAAqAAQKfx8AAhIACAiTGI41AM8BABIACAiTGI41AM8BAAAA.',['肉蛋']='肉蛋冲击:BAAAKgAECgIIAgAAAA==.',['肥龙']='肥龙在天:BAAAKgAECgYIBgAAAA==.',['背后']='背后甩狙:BAAAKgAECgQIBAAAAA==.',['胡椒']='胡椒:BAAAKgAECggIEAAAAA==.',['胤曌']='胤曌:BAAAKgAFFAgIAQAAAA==.',['脏脏']='脏脏牧:BAAAKgAECgYICAAAAA==.',['腌菜']='腌菜膏:BAAAKgADCgcIBwAAAA==.',['臂弯']='臂弯:BAAAKgAECggIDQAAAA==.',['自来']='自来也哦:BAAAKgAECgYIBgAAAA==.',['芒种']='芒种:BAAAKgAECggIEAAAAA==.',['芜湖']='芜湖土佬比:BAAAKgAECggICAAAAA==.',['花痴']='花痴的白纸:BAAAKgADCgMIAwAAAA==.',['花缘']='花缘毅:BAACKgAFFH89AAMaAAgIniGlAQB+AgAaAAgIniGlAQB+AgAjAAIIWwYAHwByAAAqAAQKfxoAAhoACAiOI7gLAI8CABoACAiOI7gLAI8CAAAA.',['苟屁']='苟屁:BAAAKgADCggIEAAAAA==.',['苦做']='苦做连:BAAAKgADCgIIAgAAAA==.',['荔枝']='荔枝肉:BAABKgAFFH8HAAIgAAQI+g/KEgDJAAAgAAQI+g/KEgDJAAAAAA==.',['莱莎']='莱莎蕾尔:BAABKgAFFH8IAAIgAAIIsB50FwCmAAAgAAIIsB50FwCmAAABKgAFFAgIEgAfAJEXAA==.',['華灯']='華灯丶初上:BAACKgAFFH8gAAIgAAYIjRvaCAABAQAgAAYIjRvaCAABAQAqAAQKfzwAAiAACAiLI+4GALcCACAACAiLI+4GALcCAAAA.',['萌小']='萌小宝:BAAAKgAECgUIBQAAAA==.',['萌珑']='萌珑夜雨:BAAAKgAFFAQIBAAAAA==.',['萌货']='萌货汪星人:BAAAKgAFFAEIAQAAAA==.',['董天']='董天棒:BAAAKgADCgYIBgAAAA==.',['蒙奇']='蒙奇璐飞:BAAAKgAFFAgIAgAAAA==.',['蘭斯']='蘭斯洛特:BAAAKgAECggICwAAAA==.',['蛋白']='蛋白也酥稣:BAAAKgADCggICAAAAA==.',['街边']='街边听雨:BAAAKgAECggIEgAAAA==.',['被狗']='被狗追的小牛:BAAAKgADCggICAAAAA==.',['被遗']='被遗忘者大梨:BAABKgAFFH8KAAIgAAYI4h5OCACxAQAgAAYI4h5OCACxAQAAAA==.',['西崽']='西崽四号:BAAAKgAECgMIBQAAAA==.',['西瓜']='西瓜丶:BAAAKgAECggIDAAAAA==.西瓜恶魔:BAACKgAFFH8GAAMHAAII6Q0CQgB3AAAHAAII6Q0CQgB3AAAIAAEIsgAbHQAdAAAqAAQKfx0AAwgACAh3CYVCALYAAAgABwhUCYVCALYAAAcAAQhECrydACwAAAAA.西瓜水果:BAACKgAFFH8NAAIPAAUI3Bp+JQDeAAAPAAUI3Bp+JQDeAAAqAAQKfxMAAg8ACAhaGKEpANEBAA8ACAhaGKEpANEBAAEqAAUUBwgGAAcA6Q0A.西瓜水果四号:BAAAKgAECgcICAABKgAFFAcIBgAHAOkNAA==.',['談談']='談談訫戀戀愛:BAABKgAFFH8GAAIHAAQI3x/6FQBLAQAHAAQI3x/6FQBLAQAAAA==.',['许大']='许大霞:BAABKgAFFH8KAAMPAAcIBBPzEACFAQAPAAYIXhTzEACFAQAdAAMIEAcBFACkAAAAAA==.',['该名']='该名字不可用:BAAAKgAECggIDAAAAA==.',['谢布']='谢布柔:BAAAKgAFFAQIBAAAAA==.',['豆浆']='豆浆浆:BAAAKgAECgUIBQAAAA==.',['豚骨']='豚骨拉麺:BAABKgAECn8tAAMMAAgI1iCiEACBAgAMAAgI1iCiEACBAgARAAIIzhRVUwB+AAAAAA==.',['贪睡']='贪睡的乌鸦:BAAAKgAFFAMIAwAAAA==.',['贰柱']='贰柱子丶:BAAAKgAECgQIBgABKgAFFAgICAAJALsbAA==.',['赤狐']='赤狐:BAAAKgADCgEIAQAAAA==.',['起开']='起开:BAAAKgAECgcIEgAAAA==.',['超迷']='超迷你烧机:BAAAKgAECgEIAQAAAA==.',['轻沙']='轻沙路马尘:BAAAKgADCgQIBAABKgAECggIDAAGAAAAAA==.',['辣仔']='辣仔永泰鹏:BAAAKgADCgUIBQAAAA==.',['还要']='还要更多:BAAAKgAECgEIAQAAAA==.',['迪皮']='迪皮艾斯:BAABKgAECn8hAAIgAAgI6SPwDwB7AgAgAAgI6SPwDwB7AgAAAA==.',['迷失']='迷失幻境:BAAAKgAFFAQIBAABKgAFFAgIDwAZAJ4TAA==.迷失月夜:BAAAKgAECgYICAAAAA==.迷失月洸:BAAAKgAECgQIBAAAAA==.迷失月色:BAAAKgAECgEIAQAAAA==.',['逆风']='逆风好渢:BAABKgAFFH8KAAIXAAYIPxa9AQC8AQAXAAYIPxa9AQC8AQAAAA==.',['那个']='那个奶骑:BAAAKgADCgEIAQAAAA==.',['邪法']='邪法:BAABKgAFFH8GAAIVAAIIsxNeIgB5AAAVAAIIsxNeIgB5AAAAAA==.',['酒酿']='酒酿元宵:BAAAKgAECgYIBgAAAA==.',['酸辣']='酸辣土豆丝丶:BAAAKgAFFAgIBAAAAA==.',['醉扶']='醉扶归:BAABKgAFFH8MAAMOAAgIvhzXDwD7AAAOAAYIiSDXDwD7AAAZAAMI3xkhHgC2AAAAAA==.',['采蘑']='采蘑菇的提莫:BAAAKgAFFAgIAwAAAA==.',['野兽']='野兽啊:BAAAKgAFFAgIBAAAAA==.',['钢钉']='钢钉雨:BAAAKgAFFAcIAQAAAA==.',['铁柱']='铁柱哥哥:BAAAKgAFFAIIAgAAAA==.',['长安']='长安靓仔:BAACKgAFFH8KAAQVAAYIzBYoBgD+AAAVAAQIbBooBgD+AAAfAAQIKRGyLQCtAAAeAAII5A0YJgCKAAAqAAQKfxQAAhUACAijHBEVABQCABUACAijHBEVABQCAAAA.',['长月']='长月烬明:BAABKgAFFH8MAAMRAAgILhc4AgBZAgARAAgI+hY4AgBZAgAMAAQIcxXLIADQAAAAAA==.',['问你']='问你一个问题:BAAAKgADCgEIAQAAAA==.',['闲听']='闲听落花:BAAAKgAFFAEIAgAAAA==.',['阿克']='阿克居多:BAAAKgAECgcIDQAAAA==.',['阿司']='阿司匹林:BAAAKgAECgQIBQAAAA==.',['阿城']='阿城:BAAAKgAECgMIAwAAAA==.',['阿嫩']='阿嫩:BAABKgAFFH8GAAIDAAYI3R9SGQCUAQADAAYI3R9SGQCUAQAAAA==.',['阿拉']='阿拉贡丶:BAABKgAFFH8GAAMMAAQIRRgYEQBEAQAMAAQIvxcYEQBEAQATAAIIXRYEBQC/AAAAAA==.',['阿撒']='阿撒托斯:BAAAKgAECgEIAwAAAA==.',['阿泰']='阿泰尔:BAAAKgAFFAIIAgAAAA==.',['阿西']='阿西达卡:BAAAKgAFFAEIAQAAAA==.',['陪你']='陪你慢慢老去:BAAAKgAECgMIAwAAAA==.',['随欲']='随欲而安:BAAAKgAECggICAAAAA==.',['雨夜']='雨夜葬花:BAAAKgAECgYIEAAAAA==.',['零丶']='零丶霖壹:BAABKgAFFH8MAAQJAAYIVRc7DwBgAQAJAAYIVRc7DwBgAQALAAQIFhsnBgABAQAKAAII7iDJFQCiAAABKgAFFAgIAgAGAAAAAA==.零丶霖拾:BAAAKgAFFAQIBAAAAA==.零丶霖捌:BAABKgAFFH8FAAIPAAUIlw2gEQAXAQAPAAUIlw2gEQAXAQAAAA==.零丶霖玖:BAABKgAFFH8OAAMbAAYIjhWsCQAJAQANAAYI5A7ZEAArAQAbAAQIwxqsCQAJAQABKgAFFAgILQANADsVAA==.零丶霖鹉:BAABKgAFFH8SAAIOAAgIKCKCAgC9AgAOAAgIKCKCAgC9AgAAAA==.',['霂詩']='霂詩:BAAAKgADCggICAAAAA==.',['青雾']='青雾风鸣:BAABKgAFFH8SAAMiAAYITxc+AQA5AQAiAAUICRo+AQA5AQAUAAUI5RkDCQALAQAAAA==.',['韩宝']='韩宝宝:BAABKgAECn83AAQeAAgIMCRuBACzAgAeAAgIMCRuBACzAgAVAAQIiwmoigB5AAAfAAIIvh//hQBZAAABKgAFFAgICAAfALoSAA==.',['韩政']='韩政:BAAAKgADCggICAAAAA==.',['風歌']='風歌一夜曲:BAAAKgAECgcICQAAAA==.',['風水']='風水輪牛灷:BAACKgAFFH8GAAIDAAIIUwi2egBzAAADAAIIUwi2egBzAAAqAAQKfzkAAgMACAg4FyhNANcBAAMACAg4FyhNANcBAAAA.',['风魔']='风魔:BAABKgAFFH8GAAIVAAYISRxxBgBnAQAVAAYISRxxBgBnAQAAAA==.',['飞盾']='飞盾人:BAABKgAECn8UAAIDAAgIHyNGKwBxAgADAAgIHyNGKwBxAgAAAA==.',['飞絮']='飞絮游丝:BAABKgAECn8dAAIDAAcIFxfkfABWAQADAAcIFxfkfABWAQAAAA==.',['香菜']='香菜芝芝梅梅:BAABKgAFFH8OAAIIAAgIsRPQAwCQAQAIAAgIsRPQAwCQAQAAAA==.',['香蕉']='香蕉:BAAAKgAECgQIBAAAAA==.',['马哲']='马哲补考:BAABKgAFFH8IAAIFAAQIvxvLBgD3AAAFAAQIvxvLBgD3AAAAAA==.',['鬼小']='鬼小生:BAAAKgADCgQIBwAAAA==.',['魂归']='魂归何处:BAAAKgAFFAUIAgAAAA==.',['魔幻']='魔幻的第一章:BAAAKgADCgEIAQAAAA==.',['鱼不']='鱼不知:BAAAKgAFFAMIAwAAAA==.',['鲜血']='鲜血与雷鳴:BAAAKgADCgYIBgAAAA==.',['鲤鱼']='鲤鱼王:BAAAKgAFFAQIBAAAAA==.',['鸣濑']='鸣濑白羽:BAAAKgAECgIIAgAAAA==.',['鹏城']='鹏城靓仔:BAABKgAFFH8JAAIJAAcIYRVzCwCQAQAJAAcIYRVzCwCQAQAAAA==.',['麦萌']='麦萌的小丑:BAAAKgADCgQIBgAAAA==.',['黄昏']='黄昏落叶愁:BAABKgAFFH8JAAIDAAYIcx/WHwBxAQADAAYIcx/WHwBxAQAAAA==.',['黄色']='黄色歪头小熊:BAAAKgAECggIDQAAAA==.',['黎苏']='黎苏苏:BAABKgAFFH8KAAIVAAYIFyRhAgD3AQAVAAYIFyRhAgD3AQAAAA==.',['黑暗']='黑暗深处的影:BAABKgAECn8iAAIjAAgIeSPXBADWAgAjAAgIeSPXBADWAgABKgAFFAgICQADAHMfAA==.',['龙井']='龙井虾仁:BAAAKgAECgEIAQAAAA==.',['龙萨']='龙萨:BAAAKgADCgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end