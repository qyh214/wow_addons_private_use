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
 local lookup = {'Evoker-Preservation','Evoker-Devastation','Warlock-Affliction','DeathKnight-Unholy','Unknown-Unknown','Mage-Fire','Mage-Frost','DeathKnight-Blood','Shaman-Enhancement','Shaman-Elemental','Hunter-BeastMastery','Monk-Mistweaver','Paladin-Retribution','DemonHunter-Havoc','Priest-Holy','Priest-Discipline','Shaman-Restoration','Warrior-Fury','Monk-Windwalker','Warlock-Demonology','Warlock-Destruction','Hunter-Marksmanship','Paladin-Protection','Warrior-Protection','Warrior-Arms','Paladin-Holy','Mage-Arcane','Monk-Brewmaster','Druid-Balance','Druid-Guardian','Druid-Restoration','Rogue-Assassination','Rogue-Outlaw','Priest-Shadow','DeathKnight-Frost','Rogue-Subtlety',}; local provider = {region='CN',realm='踏梦者',name='CN',type='weekly',zone=42,date='2025-08-08',data={Be='Beforeafter:BAABKgAECn8nAAMBAAgIySMaAQDaAgABAAgIySMaAQDaAgACAAgIdiIVDQBsAgABKgAFFAgIBgACAOIiAA==.',Bi='Bibi:BAAAKgAECggICAAAAA==.Bittergourd:BAABKgAECn8uAAMCAAgI2h/LEgAvAgACAAgI2h/LEgAvAgABAAcIvyCtDAAqAQABKgAFFAgIBgACAOIiAA==.',Bl='Blackwarlock:BAABKgAFFH8IAAIDAAgIpAZdAQDLAQADAAgIpAZdAQDLAQAAAA==.Blessing:BAAAKgAECggIDAABKgAFFAgIBgACAOIiAA==.',Ck='Ckk:BAAAKgAECggIEAAAAA==.',Da='Dark:BAAAKgADCgEIAQAAAA==.',Dr='Drss:BAAAKgADCgcIBwAAAA==.',El='Elaine:BAAAKgAECggIDQAAAA==.',Em='Emo:BAABKgAECn8ZAAIEAAgI4h9oEgB2AgAEAAgI4h9oEgB2AgAAAA==.',Ew='Ew:BAAAKgAECgIIAgAAAA==.',Fa='Faiz:BAAAKgADCgQIBAAAAA==.',Ha='Happyys:BAAAKgADCgEIAQAAAA==.',Hi='Hillmanq:BAAAKgAFFAMIAwAAAA==.',Hy='Hydedragon:BAABKgAFFH8GAAMBAAYInBerAwDeAAABAAQIzxSrAwDeAAACAAIIZQOdLwBtAAAAAA==.Hydews:BAAAKgAFFAYIBAABKgAFFAgIBAAFAAAAAA==.',Lu='Luckymage:BAABKgAFFH8GAAMGAAQITx4iEAAVAQAGAAQINR4iEAAVAQAHAAII+BlOIQB+AAAAAA==.Luckypaladin:BAAAKgAFFAYIBAAAAA==.',Ma='Magaleta:BAAAKgAFFAgIBAAAAA==.',Os='Osnngb:BAABKgAFFH8FAAMIAAUI9QgqFwDoAAAIAAQImAoqFwDoAAAEAAEIawIoNQA0AAAAAA==.',Ro='Roxam:BAAAKgAFFAMIAwAAAA==.',Sa='Savage:BAAAKgAECggIDAAAAA==.',Sn='Snll:BAAAKgAECgQIBAAAAA==.',Sp='Sparkuggz:BAAAKgAECgQIBgAAAA==.',Sy='Sylvanasscy:BAAAKgAFFAYIBAAAAA==.',Te='Tehfa:BAAAKgAFFAQIBAAAAA==.',Tm='Tmmz:BAAAKgAECggICQAAAA==.',To='Toki:BAAAKgADCggIDgABKgAFFAgIBAAFAAAAAA==.',Wh='Whitegirl:BAAAKgADCgEIAQAAAA==.',Yo='Youyou:BAAAKgADCgMIAwAAAA==.',Yr='Yraax:BAABKgAECn8XAAMGAAgI2BOdQACJAQAGAAgI0hCdQACJAQAHAAUImhQ8bQDCAAAAAA==.',['一不']='一不小心就:BAAAKgADCgUIBQAAAA==.',['万事']='万事如意菇:BAAAKgAECggICgAAAA==.',['三月']='三月的狮子:BAAAKgAECggICAAAAA==.',['三角']='三角初華:BAAAKgADCggIFwAAAA==.',['三锤']='三锤优雅:BAAAKgAECgIIAgAAAA==.',['上官']='上官丶呆哔:BAABKgAECn8mAAMJAAgIFiSYBQDKAgAJAAgInSOYBQDKAgAKAAcIHSIYEABXAgAAAA==.',['上帝']='上帝的右腳:BAABKgAFFH8GAAILAAMIkhGtHgDcAAALAAMIkhGtHgDcAAAAAA==.上帝的右踋:BAABKgAFFH8GAAILAAMIuQ5LNwC5AAALAAMIuQ5LNwC5AAAAAA==.',['下巴']='下巴草真长:BAAAKgADCggICAAAAA==.',['不是']='不是未知目标:BAAAKgAECgUIBQAAAA==.',['专家']='专家级叫兽:BAAAKgAECgEIAQAAAA==.',['丧彪']='丧彪:BAAAKgAECgcIBwAAAA==.',['丨大']='丨大自在丨:BAABKgAFFH8SAAICAAgIoR5xAwCQAgACAAgIoR5xAwCQAgAAAA==.',['丨樂']='丨樂乐楽丨:BAAAKgAECgcIDQAAAA==.',['丨行']='丨行不晚丨:BAABKgAFFH8RAAIMAAMIuCQ/BgBGAQAMAAMIuCQ/BgBGAQAAAA==.',['丨长']='丨长生天丨:BAAAKgAECgYIBgAAAA==.',['丰兄']='丰兄婲鸡:BAACKgAFFH8SAAINAAMI+xWjRgDhAAANAAMI+xWjRgDhAAAqAAQKfxsAAg0ACAjWFDaIAIcBAA0ACAjWFDaIAIcBAAAA.',['丶至']='丶至死方休丶:BAAAKgAFFAcIAQAAAA==.',['为你']='为你熬翔:BAAAKgAECgcICQAAAA==.',['主人']='主人降临:BAABKgAFFH8NAAIOAAMI9heBJgDdAAAOAAMI9heBJgDdAAAAAA==.',['主打']='主打一个陪伴:BAAAKgAECgMIAwAAAA==.',['丿狂']='丿狂戦如风:BAAAKgADCgEIAQAAAA==.',['乌尔']='乌尔扎戈:BAAAKgADCgYIBgAAAA==.',['亂世']='亂世小熊:BAAAKgAECgYIBgAAAA==.',['事了']='事了拂衣:BAAAKgAECggIDwAAAA==.',['云梦']='云梦谣:BAABKgAFFH8KAAMPAAYI0B0HAwAzAQAPAAUIrR4HAwAzAQAQAAEIWhoFLwBYAAABKgAFFAgICAARAO0XAA==.',['云泽']='云泽:BAAAKgAECggICwAAAA==.',['亚丽']='亚丽雅:BAAAKgAECgcIBAAAAA==.',['亜菲']='亜菲利欧:BAACKgAFFH9BAAICAAgIjybEAQDKAgACAAgIjybEAQDKAgAqAAQKf0IAAgIACAiIJvoBAPsCAAIACAiIJvoBAPsCAAAA.',['亦怒']='亦怒:BAAAKgADCgIIAgAAAA==.',['人间']='人间失格:BAAAKgAECgcIBwAAAA==.',['从良']='从良匪兵:BAAAKgAECgUIBgAAAA==.',['仙剑']='仙剑丶李逍遥:BAAAKgAECgYIBgAAAA==.',['佑赫']='佑赫:BAAAKgADCgQIBAAAAA==.',['你害']='你害我:BAAAKgAFFAIIAgAAAA==.',['先到']='先到先得:BAABKgAFFH8HAAISAAYIIg56DwBdAQASAAYIIg56DwBdAQAAAA==.',['八极']='八极我兮:BAABKgAFFH8KAAITAAYI1BDgCABdAQATAAYI1BDgCABdAQAAAA==.',['八級']='八級大狂風:BAAAKgAFFAQIBAAAAA==.',['兽血']='兽血沸腾丶:BAAAKgAECggIDQAAAA==.',['军体']='军体拳老哥:BAAAKgADCgYICAAAAA==.',['冰之']='冰之梦魇:BAAAKgAECgYICgAAAA==.',['冰河']='冰河:BAAAKgAECgQIBAAAAA==.',['凉慕']='凉慕凰:BAACKgAFFH8TAAMJAAgI0xhIBAD8AQAJAAcI9hxIBAD8AQARAAEIggW6TwBEAAAqAAQKfxQAAgkACAihI5wFAMoCAAkACAihI5wFAMoCAAAA.',['凉静']='凉静汐:BAABKgAECn8WAAQRAAgIthRdPACUAQARAAgIthRdPACUAQAJAAcI6hMiKgByAQAKAAIIIRM/cwBfAAAAAA==.',['分身']='分身无术:BAACKgAFFH8KAAMUAAMI5gKMJQBOAAAVAAMIlAK/PQB3AAAUAAII1QKMJQBOAAAqAAQKfxQAAxQACAhfEo0xADEBABQABgi1D40xADEBABUABQhnFUdDAP4AAAAA.',['创意']='创意无赖:BAAAKgADCgEIAQAAAA==.',['初心']='初心乀:BAAAKgAECgUIBgAAAA==.',['初音']='初音未来:BAABKgAFFH8GAAMWAAYIxhLRHgD9AAAWAAUIohDRHgD9AAALAAEIVBtTWABKAAAAAA==.',['功夫']='功夫小鱼:BAABKgAFFH8HAAINAAQIHBuQPwDyAAANAAQIHBuQPwDyAAAAAA==.',['动物']='动物大王:BAAAKgAECgUIBQAAAA==.',['北风']='北风其凉:BAAAKgAECggICAAAAA==.',['南风']='南风知子义:BAAAKgAECgQIBAAAAA==.',['卡西']='卡西莫多之泪:BAAAKgAFFAgIAQAAAA==.',['卧草']='卧草原:BAABKgAFFH8GAAIGAAYISByCBADAAQAGAAYISByCBADAAQAAAA==.',['卫士']='卫士开道:BAAAKgADCgIIAgAAAA==.',['叁灬']='叁灬月:BAAAKgAFFAQIAwAAAA==.',['又初']='又初恋了:BAAAKgAECgcIBwAAAA==.',['台词']='台词而以:BAABKgAFFH8SAAIXAAMIcgROFgBMAAAXAAMIcgROFgBMAAAAAA==.台词而已:BAACKgAFFH8aAAIYAAQIxQweBwCdAAAYAAQIxQweBwCdAAAqAAQKfxYAAhgACAidFCgTAI8BABgACAidFCgTAI8BAAAA.',['叱咤']='叱咤红人:BAABKgAFFH8RAAINAAMIHhi8QwDnAAANAAMIHhi8QwDnAAAAAA==.',['叶末']='叶末:BAAAKgAECgYICwAAAA==.',['叽叽']='叽叽喳喳:BAAAKgAECggICAAAAA==.',['吃土']='吃土不吃饭:BAAAKgAECgIIAgAAAA==.',['吃货']='吃货怕饿梦:BAAAKgAECgIIAgAAAA==.',['后来']='后来的我们:BAAAKgAECgEIAQAAAA==.',['吞下']='吞下一整根:BAABKgAFFH8GAAIOAAYIlQ/oGAA1AQAOAAYIlQ/oGAA1AQAAAA==.',['呼啸']='呼啸风之灵:BAAAKgAFFAEIAQAAAA==.',['命运']='命运之神:BAABKgAECn8fAAMZAAgI7B/9CwBmAgAZAAcIoh/9CwBmAgASAAMIWxAqMwBXAAAAAA==.',['咗洱']='咗洱聽歌丶牧:BAAAKgAECgcIBwAAAA==.',['哒哒']='哒哒君子丶:BAAAKgAFFAQIBAAAAA==.',['哦小']='哦小点点:BAAAKgAECgMIBAAAAA==.',['唧唧']='唧唧歪歪:BAAAKgAECgEIAQAAAA==.',['喵狐']='喵狐仙:BAAAKgAFFAUIAwAAAA==.',['嗖嗖']='嗖嗖:BAAAKgAECggICAAAAA==.',['嗷嗷']='嗷嗷呜:BAAAKgAECgYIBgAAAA==.',['嘘丶']='嘘丶安静点:BAAAKgAECgMIAwAAAA==.',['嚣张']='嚣张男人:BAAAKgAECgEIAQAAAA==.',['国窖']='国窖典藏:BAAAKgAECgIIAgAAAA==.',['團滅']='團滅之星:BAABKgAFFH8YAAMNAAgIBx5FDAAkAQANAAgIBx5FDAAkAQAaAAQIyBdBBgDpAAAAAA==.',['土坷']='土坷拉:BAAAKgAECgMIAwAAAA==.',['土灵']='土灵牧:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光小鸭哥:BAABKgAFFH8oAAIXAAgIXh3cAwAoAgAXAAgIXh3cAwAoAgAAAA==.',['圣域']='圣域追风:BAAAKgAECggIEgAAAA==.',['圣子']='圣子川:BAABKgAECn8WAAQbAAgI1xZ9NwBsAQAbAAgIRRF9NwBsAQAHAAYIjBjEYgDjAAAGAAYIOQxOLgDBAAAAAA==.',['圣斗']='圣斗士阿牛:BAAAKgAECgYICgAAAA==.',['圣騎']='圣騎仕:BAAAKgADCgIIAgAAAA==.',['地狱']='地狱爆笑:BAAAKgADCgYIBgAAAA==.',['壊丶']='壊丶断角:BAAAKgAFFAQIBAAAAA==.',['夏夜']='夏夜星空:BAABKgAFFH8GAAMcAAMIqQHICgBVAAAcAAMIqQHICgBVAAAMAAEItwt2MwA3AAAAAA==.夏夜星雨:BAABKgAFFH8IAAICAAgIeyHKAQDJAgACAAgIeyHKAQDJAgAAAA==.夏夜暖风:BAABKgAFFH8PAAILAAMIQw9VHwDaAAALAAMIQw9VHwDaAAAAAA==.夏夜疾风:BAAAKgAFFAMIAwAAAA==.夏夜细雨:BAAAKgAFFAYIAgAAAA==.夏夜驟雨:BAAAKgAECggIDAAAAA==.',['夏花']='夏花之绚烂:BAAAKgADCgQIBAAAAA==.',['夜丶']='夜丶耒央:BAAAKgAECgYIBgAAAA==.',['夜的']='夜的第一章:BAAAKgAECggICAAAAA==.夜的第三章:BAAAKgADCggICgAAAA==.',['大哥']='大哥你听我说:BAAAKgADCgIIAwAAAA==.',['大多']='大多数:BAAAKgADCgEIAQAAAA==.',['大弗']='大弗弗:BAACKgAFFH8zAAIIAAgISCJvAQC2AgAIAAgISCJvAQC2AgAqAAQKfywAAggACAgZIQ8IAJ4CAAgACAgZIQ8IAJ4CAAAA.',['大水']='大水汼:BAAAKgAECgUIBQAAAA==.',['大牛']='大牛的裂变:BAAAKgADCgMIAwAAAA==.',['大王']='大王叫我:BAAAKgAECggICAAAAA==.',['天使']='天使的羽翼:BAAAKgAFFAIIAgABKgAFFAgIEQAXAAchAA==.',['天河']='天河雪琼:BAAAKgAECgQIDAAAAA==.',['奥丽']='奥丽佛:BAABKgAFFH8KAAMRAAYIhxamBQAtAQARAAUIThmmBQAtAQAKAAUI6htlBgD/AAAAAA==.',['奥斯']='奥斯丁:BAAAKgAECgUIBAAAAA==.',['她他']='她他:BAAAKgAECgEIAQAAAA==.',['她她']='她她:BAAAKgAECgIIAwAAAA==.',['好久']='好久不见丷:BAAAKgADCgMIAwAAAA==.',['如年']='如年:BAAAKgAECgEIAQAAAA==.',['威格']='威格大领主:BAAAKgAECgYICgAAAA==.',['孤影']='孤影照惊魂:BAAAKgADCggICAAAAA==.',['孤筏']='孤筏客:BAAAKgAECggICAAAAA==.',['安娜']='安娜西丝莉亚:BAAAKgAECgcICQAAAA==.',['安若']='安若清风:BAABKgAFFH8HAAIZAAcIdAvuBAC0AQAZAAcIdAvuBAC0AQAAAA==.',['宝贝']='宝贝灬别摸我:BAAAKgAFFAIIAgABKgAFFAUIIAAbANQXAA==.宝贝灬咕咕:BAACKgAFFH8iAAIdAAQIths+KQDuAAAdAAQIths+KQDuAAAqAAQKfxUAAx0ACAh+HwgWAIMCAB0ACAh+HwgWAIMCAB4AAQjZCL84ABcAAAEqAAUUBQggABsA1BcA.宝贝灬大领主:BAABKgAFFH8YAAINAAQIVh7YNwAMAQANAAQIVh7YNwAMAQABKgAFFAUIIAAbANQXAA==.宝贝灬小佳佳:BAACKgAFFH8gAAIbAAQI1BdHIgDcAAAbAAQI1BdHIgDcAAAqAAQKfx0ABAYACAhPG803ALYBAAYACAhDF803ALYBABsAAwiJGOVbANIAAAcABQitCqFzALAAAAAA.宝贝灬神射手:BAACKgAFFH8pAAIWAAQIyR/qDADoAAAWAAQIyR/qDADoAAAqAAQKfxQAAxYACAgIJPwRAEQCABYACAgIJPwRAEQCAAsAAQiBELgJASsAAAEqAAUUCAgUAB0AVSIA.',['小不']='小不點:BAABKgAFFH8GAAIRAAYIngo5FgAqAQARAAYIngo5FgAqAQAAAA==.',['小兔']='小兔瑞贝卡:BAAAKgAECggIEAAAAA==.小兔瑞贝卡卡:BAABKgAFFH8FAAIRAAMI6gJJQQCDAAARAAMI6gJJQQCDAAAAAA==.小兔瑞贝德:BAAAKgAFFAQIBAAAAA==.',['小冰']='小冰郁:BAAAKgAECgIIAgAAAA==.',['小提']='小提莫可达鸭:BAAAKgAECgIIAgAAAA==.',['小楼']='小楼逢雨月:BAAAKgAFFAQIBAAAAA==.',['小欣']='小欣欣:BAAAKgAECgUICgAAAA==.',['小爹']='小爹地:BAAAKgAECgMIAwAAAA==.',['小牛']='小牛牛来了:BAABKgAFFH8OAAMIAAYIdR/xBwCfAQAIAAYIdR/xBwCfAQAEAAQIYhEsGADUAAAAAA==.',['小瑞']='小瑞在干嘛:BAAAKgADCgIIAgAAAA==.',['小番']='小番茄脸红了:BAABKgAFFH8KAAIdAAYIYyENEQCXAQAdAAYIYyENEQCXAQAAAA==.',['小盆']='小盆友风骚猎:BAAAKgAFFAUIBAAAAA==.',['小算']='小算啦:BAAAKgAECgMIAwAAAA==.',['小锤']='小锤锤你胸口:BAABKgAFFH8XAAINAAUIchmeKgA9AQANAAUIchmeKgA9AQAAAA==.',['小鲁']='小鲁班七号:BAAAKgAECggICAAAAA==.小鲁班八号:BAAAKgAECggICAAAAA==.',['山丘']='山丘之土:BAAAKgAECgYIBgAAAA==.',['巴伐']='巴伐利亚怒风:BAAAKgADCgYIBgAAAA==.',['帝国']='帝国之心:BAABKgAFFH8MAAMXAAgI2gdfDgAYAQAXAAgIbAVfDgAYAQANAAQIwwj4KADOAAAAAA==.帝国之怒:BAAAKgAFFAQIBAAAAA==.帝国之殇:BAABKgAFFH8JAAIOAAYIcg6yFgBFAQAOAAYIcg6yFgBFAQABKgAFFAgIFAAOAGEfAA==.帝国之狼:BAABKgAFFH8FAAIHAAQI6RvZEwDIAAAHAAQI6RvZEwDIAAAAAA==.帝国之翼:BAAAKgAFFAEIAQAAAA==.帝国之鹰:BAABKgAFFH8GAAILAAYIHBiiEAB0AQALAAYIHBiiEAB0AQAAAA==.',['常熟']='常熟阿诺:BAAAKgAECgQIBwAAAA==.',['幼稚']='幼稚園殺手:BAABKgAFFH8UAAMIAAgIhx9XAQCGAgAIAAgIDB9XAQCGAgAEAAgI3hTiHAA3AQAAAA==.',['幽光']='幽光逐星者:BAAAKgAECgEIAQAAAA==.',['开始']='开始的悲哀:BAABKgAECn8fAAINAAgIZiJYIgCQAgANAAgIZiJYIgCQAgAAAA==.',['彩鳞']='彩鳞:BAAAKgADCgQIBAAAAA==.',['影灬']='影灬帝:BAACKgAFFH8JAAINAAMIghTRTADVAAANAAMIghTRTADVAAAqAAQKfyIAAg0ACAjlG8FEACECAA0ACAjlG8FEACECAAAA.',['很萌']='很萌很天真:BAAAKgAECgMIAwAAAA==.',['御天']='御天灬神宗:BAAAKgAECgEIAQAAAA==.',['德一']='德一忘形:BAABKgAFFH8PAAMfAAMIlRCUIACoAAAfAAMIlRCUIACoAAAdAAEIwwDoZQAUAAAAAA==.',['德华']='德华丶:BAAAKgAECgIIAgAAAA==.',['德性']='德性天下:BAAAKgAECgUICgAAAA==.',['心碎']='心碎小牧:BAAAKgAECgcIEwAAAA==.',['心系']='心系梦迦:BAAAKgAECgYIBwAAAA==.',['恭喜']='恭喜发财丷:BAABKgAFFH8qAAMbAAgIwh6MAwB/AgAbAAgIwh6MAwB/AgAGAAQIUw82HQDFAAAAAA==.',['惊恐']='惊恐的鸦熊:BAABKgAFFH8JAAMgAAYIkBLsDQBxAQAgAAYIghHsDQBxAQAhAAII7R+aBQC/AAAAAA==.',['愚妄']='愚妄愚安:BAAAKgAECgEIAQAAAA==.',['愛莉']='愛莉希雅:BAABKgAFFH8gAAQiAAYIiRTICgAkAQAiAAUIjhXICgAkAQAPAAYIwwB6IgC7AAAQAAIImA8IEgBoAAAAAA==.',['懵小']='懵小朵:BAAAKgAECggICAAAAA==.',['懵懵']='懵懵萌:BAAAKgAECggICgAAAA==.',['我叫']='我叫小乖:BAAAKgAECgQIBAAAAA==.',['我爱']='我爱小德:BAAAKgAECggICAAAAA==.',['战来']='战来:BAAAKgAECgUIBQAAAA==.',['打小']='打小不闹:BAAAKgAECggICAAAAA==.',['执迷']='执迷不悟丶:BAAAKgAFFAEIAQAAAA==.',['承山']='承山:BAAAKgAECggIDgAAAA==.',['拉普']='拉普兰德:BAAAKgAECgMIAwAAAA==.',['挥斥']='挥斥方遒:BAAAKgADCgEIAQAAAA==.',['挽風']='挽風:BAACKgAFFH8bAAMSAAQIORnAGQDvAAASAAQIpBbAGQDvAAAZAAIIkxRmDwCfAAAqAAQKfyUAAhIACAhjIUIYAEgCABIACAhjIUIYAEgCAAEqAAUUCAhNAAoA5iMA.',['新的']='新的猎:BAAAKgADCggICAAAAA==.',['无耻']='无耻的我:BAAAKgADCggICAAAAA==.',['无赦']='无赦罪痕:BAAAKgADCgYIBgAAAA==.',['无非']='无非想快乐:BAABKgAECn8nAAMCAAgIUCUoBADZAgACAAgIUCUoBADZAgABAAMIZiCjEwAdAQABKgAFFAgIBgACAOIiAA==.',['昊哥']='昊哥:BAAAKgAECgIIAgAAAA==.',['是个']='是个暗牧:BAAAKgADCgYIBgAAAA==.',['普六']='普六茹豆:BAAAKgAECgEIAQAAAA==.',['暗翼']='暗翼影:BAAAKgAECggICAAAAA==.',['暮酒']='暮酒:BAAAKgAFFAIIAgAAAA==.',['曾经']='曾经那个少年:BAAAKgADCgEIAQAAAA==.',['最后']='最后一舞:BAABKgAFFH8IAAIOAAgIVwPuEQASAQAOAAgIVwPuEQASAQAAAA==.',['有我']='有我石更嚒:BAAAKgAFFAEIAQAAAA==.',['有点']='有点小晕晕:BAAAKgAECgMIBQAAAA==.',['有种']='有种盗我德号:BAABKgAFFH8cAAMdAAYIOCGVCgAZAQAdAAYIOCGVCgAZAQAfAAIIGglwGwBrAAAAAA==.',['木豆']='木豆琥珀糖:BAAAKgAECgYIBgAAAA==.',['朲冭']='朲冭帅:BAAAKgAECgcICAAAAA==.',['林七']='林七夜:BAABKgAFFH8SAAQVAAgI7h0JDADMAQAVAAgIChoJDADMAQADAAUICBIYCAADAQAUAAEINB0+JQBPAAAAAA==.',['枫之']='枫之耀舞:BAABKgAFFH8GAAIQAAYISxkZCwD8AAAQAAYISxkZCwD8AAABKgAFFAgIEwAPAP0gAA==.',['格鲁']='格鲁姆地狱吼:BAAAKgAECgEIAQAAAA==.',['椰果']='椰果奶绿:BAACKgAFFH8dAAMcAAcI7xhnAACJAQAcAAYI2R1nAACJAQAMAAEI6SOmLwBXAAAqAAQKfyQAAhwACAgcJB8CAMQCABwACAgcJB8CAMQCAAAA.',['楓緋']='楓緋雨:BAABKgAFFH8LAAINAAgIwR7DAwCkAgANAAgIwR7DAwCkAgAAAA==.',['楠心']='楠心慕舞:BAAAKgAFFAQIAgABKgAFFAgIBAAFAAAAAA==.',['模糊']='模糊的清香:BAAAKgADCgQIBAAAAA==.',['樱小']='樱小路露娜:BAAAKgAECgcIDgAAAA==.',['歙无']='歙无命:BAAAKgADCgEIAQAAAA==.',['此生']='此生只爱昆:BAAAKgAECgQIBAAAAA==.',['歪瑞']='歪瑞奈斯:BAAAKgAECgUIBwAAAA==.',['死也']='死也要在一起:BAAAKgADCgEIAQAAAA==.',['死亡']='死亡使者小萨:BAABKgAFFH8XAAIjAAMIUxM/CgDPAAAjAAMIUxM/CgDPAAAAAA==.死亡可爱:BAAAKgAECggICAAAAA==.',['江城']='江城灬龍少:BAAAKgADCgEIAQAAAA==.',['池鱼']='池鱼思故淵:BAABKgAFFH8GAAICAAYIexlGEgBCAQACAAYIexlGEgBCAQAAAA==.',['汲魂']='汲魂者:BAAAKgADCgIIAgAAAA==.',['没有']='没有信仰的牛:BAAAKgAFFAEIAQAAAA==.',['法力']='法力残渣:BAAAKgAECggICQAAAA==.',['浪之']='浪之幻影:BAABKgAFFH8GAAINAAYIGyVlDQD6AQANAAYIGyVlDQD6AQAAAA==.',['浮生']='浮生醉清风:BAABKgAFFH8JAAINAAYIRxPNEgBxAQANAAYIRxPNEgBxAQAAAA==.',['海燕']='海燕儿:BAAAKgADCgUIBQAAAA==.',['清秋']='清秋梦离:BAAAKgAFFAIIAgAAAA==.',['滅團']='滅團災星:BAABKgAFFH8MAAMZAAgIQRhSBgAAAQASAAQIshjECgARAQAZAAgIvhRSBgAAAQAAAA==.滅團灾星:BAABKgAFFH8NAAMEAAYIexhBAwCpAQAEAAYIexhBAwCpAQAIAAEIAAAUKgAAAAAAAA==.',['漂邈']='漂邈:BAAAKgAECgUICwAAAA==.',['演中']='演中演:BAAAKgAECgYIBgAAAA==.',['漫步']='漫步丶迷踪:BAAAKgAECgEIAQAAAA==.',['潇然']='潇然尘外:BAABKgAFFH8GAAIHAAIIsxR8IgB4AAAHAAIIsxR8IgB4AAAAAA==.',['潮留']='潮留美海:BAAAKgAECggICAAAAA==.',['灵魂']='灵魂屠戮者:BAAAKgAECgEIAQAAAA==.',['烂棉']='烂棉岁:BAAAKgAECgQIBAAAAA==.',['烈焰']='烈焰咕咕:BAABKgAECn8fAAMeAAgIJw0kHQAFAQAeAAgIJw0kHQAFAQAfAAIIxwWbkQAjAAAAAA==.',['烟月']='烟月离:BAABKgAFFH8OAAICAAgIzhiFBABVAgACAAgIzhiFBABVAgAAAA==.',['烟花']='烟花粉黛:BAABKgAFFH8IAAILAAQIfhohGADwAAALAAQIfhohGADwAAAAAA==.',['烟雨']='烟雨涵:BAAAKgAECggICAAAAA==.',['煲湯']='煲湯牛:BAAAKgAECgEIAQAAAA==.',['熊帝']='熊帝:BAAAKgADCgIIAgAAAA==.',['熊猫']='熊猫盼盼:BAAAKgAFFAQIBAAAAA==.',['爱仕']='爱仕达:BAAAKgAFFAgIBAAAAA==.',['爱如']='爱如潮水:BAAAKgADCgEIAQAAAA==.',['牛奶']='牛奶丶咖啡:BAAAKgADCggICAAAAA==.',['牛德']='牛德花:BAAAKgAECgEIAgAAAA==.',['狂拽']='狂拽霸爆龙:BAAAKgAFFAQIBAAAAA==.',['狂暴']='狂暴熊仔:BAAAKgAECgIIAgAAAA==.',['狐大']='狐大爷:BAAAKgAECggICAAAAA==.',['猫猫']='猫猫在上:BAAAKgAECggICgAAAA==.',['玛里']='玛里苟斯:BAABKgAFFH8JAAMbAAMIThdTIwDWAAAbAAMIThdTIwDWAAAGAAMIywX1IgChAAAAAA==.',['瘋狂']='瘋狂烟雨朦胧:BAAAKgAECgMIAwAAAA==.',['白色']='白色风车:BAABKgAFFH8PAAIOAAgI2QtdCwDRAQAOAAgI2QtdCwDRAQAAAA==.',['白芷']='白芷:BAAAKgAFFAcIAwAAAA==.',['盐焗']='盐焗鸡脚筋:BAAAKgAECggICAAAAA==.',['眸是']='眸是三千嗔:BAAAKgADCgMIAwAAAA==.',['知悉']='知悉:BAABKgAECn8gAAIRAAcIWyUDEAB5AgARAAcIWyUDEAB5AgAAAA==.',['筱水']='筱水水:BAABKgAFFH8WAAMgAAgI7Bi+BABOAgAgAAgI7Bi+BABOAgAkAAQIjQlmCQDaAAAAAA==.',['简阿']='简阿普:BAAAKgAFFAYIAwAAAA==.',['納哥']='納哥大领主:BAAAKgAECgUICgAAAA==.',['红啾']='红啾啾:BAAAKgAFFAQIBAAAAA==.',['绒球']='绒球儿:BAABKgAECn8WAAIeAAgIwg7cEQAvAQAeAAgIwg7cEQAvAQAAAA==.',['绿箭']='绿箭奥利弗:BAACKgAFFH8OAAMWAAMIew9aMgCnAAALAAMINAyqOwCtAAAWAAMIZw1aMgCnAAAqAAQKfyoAAwsACAiXHQErAEcCAAsACAgnHQErAEcCABYABQgbGmZKACYBAAAA.',['群星']='群星萝莉:BAAAKgAECggIDAAAAA==.',['耀嘉']='耀嘉音:BAAAKgAECgIIAgAAAA==.',['老刀']='老刀来了:BAAAKgAECgYICwAAAA==.',['老年']='老年水水波:BAAAKgAECgIIAgAAAA==.',['肥罗']='肥罗:BAAAKgAECgMIAwAAAA==.',['花开']='花开任平生:BAAAKgAECgYIBgAAAA==.',['苏夜']='苏夜:BAAAKgAECggIEwAAAA==.',['苏沫']='苏沫沫:BAAAKgAECgYIBwAAAA==.',['苏简']='苏简简:BAAAKgAFFAYIBAAAAA==.',['英俊']='英俊的庫拉:BAAAKgADCgMIAwAAAA==.',['萨之']='萨之霊:BAACKgAFFH8PAAIRAAQIGReRJQDgAAARAAQIGReRJQDgAAAqAAQKfxcAAhEACAjbFKY7AIcBABEACAjbFKY7AIcBAAAA.',['萨菲']='萨菲噬刃:BAAAKgAECgQIBAAAAA==.萨菲若丝:BAAAKgAFFAMIBAAAAA==.萨菲鼬:BAABKgAFFH8IAAIOAAMIsRAkLADJAAAOAAMIsRAkLADJAAAAAA==.',['萨飒']='萨飒萨:BAAAKgADCgEIAgAAAA==.',['萨鲁']='萨鲁法尔大王:BAABKgAFFH8JAAISAAMIIA9mIgDJAAASAAMIIA9mIgDJAAAAAA==.',['蛋蛋']='蛋蛋不瞎:BAABKgAFFH8IAAIOAAMIfhO9LADHAAAOAAMIfhO9LADHAAAAAA==.',['谁的']='谁的眼泪在飞:BAAAKgADCggICAAAAA==.',['豆豆']='豆豆哟:BAAAKgAECgEIAQAAAA==.',['赤奥']='赤奥尼老牧:BAABKgAFFH8IAAMQAAQIaBh0CwD5AAAQAAQIaBh0CwD5AAAiAAEIGBM+IwBPAAAAAA==.',['超級']='超級大怪獸:BAABKgAFFH8FAAIXAAUIlQexCQAAAQAXAAUIlQexCQAAAQAAAA==.',['超级']='超级吴少:BAAAKgADCggICAAAAA==.',['踏梦']='踏梦天骄:BAABKgAFFH8IAAIbAAgIYQ2jCgDAAQAbAAgIYQ2jCgDAAQAAAA==.踏梦第一人:BAABKgAFFH8GAAILAAMITBGZLwDMAAALAAMITBGZLwDMAAAAAA==.',['轩辕']='轩辕的小圣歌:BAABKgAFFH8IAAQQAAYI7hMhBABWAQAQAAUIlBQhBABWAQAPAAIIKhOXFwCJAAAiAAEIYhgkIgBTAAAAAA==.',['部分']='部分大小:BAAAKgADCggICAAAAA==.',['部落']='部落第一勇士:BAAAKgADCgEIAQAAAA==.',['酱焖']='酱焖鱼杂:BAAAKgADCggICAAAAA==.',['醉后']='醉后一杯喵:BAAAKgAECgcICwAAAA==.',['重燃']='重燃:BAAAKgAECgEIAQAAAA==.',['银叶']='银叶诅咒:BAACKgAFFH8JAAICAAMIJQfiKACWAAACAAMIJQfiKACWAAAqAAQKfxQAAgIACAgaFb4NAJ4BAAIACAgaFb4NAJ4BAAEqAAUUBQgdABEAcBkA.',['铿锵']='铿锵小龙:BAAAKgAECgQIBAAAAA==.',['镉球']='镉球:BAABKgAECn8UAAQTAAgINBMmIACdAQATAAgIKhMmIACdAQAcAAQIjBIkHACUAAAMAAUI1QqoTACMAAAAAA==.',['闪电']='闪电猎手:BAAAKgAECgEIAQAAAA==.',['阿什']='阿什顿:BAABKgAFFH8OAAINAAYIfSQTBwBGAQANAAYIfSQTBwBGAQAAAA==.',['阿卡']='阿卡特:BAAAKgAECggIDQAAAA==.',['阿尔']='阿尔萨亖:BAAAKgAECgcIBwAAAA==.',['阿森']='阿森:BAAAKgAECgYICwAAAA==.',['阿牛']='阿牛:BAAAKgAECgQIBAAAAA==.',['阿西']='阿西巴:BAAAKgAECgYIBgAAAA==.',['随便']='随便瞅瞅:BAABKgAFFH8IAAIVAAgIqwlECQDHAQAVAAgIqwlECQDHAQAAAA==.',['随心']='随心所欲:BAAAKgADCggICAAAAA==.',['难民']='难民营营长:BAACKgAFFH8GAAINAAMIbBmZSgDZAAANAAMIbBmZSgDZAAAqAAQKfxkAAg0ACAgNIxMQAFsCAA0ACAgNIxMQAFsCAAEqAAUUCAgPABAAzhcA.',['雪最']='雪最终会融化:BAAAKgAECgEIAQAAAA==.',['雷多']='雷多多:BAAAKgAECgYIDwAAAA==.',['霸波']='霸波奔:BAACKgAFFH8MAAMSAAMIXQgMJwCwAAASAAMIXQgMJwCwAAAYAAIIdwNVDABLAAAqAAQKfxQAAhIACAgIE+MtAM8BABIACAgIE+MtAM8BAAAA.',['青春']='青春猪头少年:BAAAKgAFFAYIBAAAAA==.',['青涩']='青涩后妈:BAAAKgAECgUIBwAAAA==.',['青空']='青空玄鸟:BAABKgAFFH8IAAMdAAgIZAykDQCdAQAdAAcI9wykDQCdAQAfAAEIkAmhFwBCAAAAAA==.',['非我']='非我莫属:BAABKgAFFH8IAAIRAAgI9A4WBwDZAQARAAgI9A4WBwDZAQAAAA==.',['风中']='风中对牛弹琴:BAAAKgAECgIIBAAAAA==.',['风暴']='风暴雏龙:BAAAKgADCgIIAwAAAA==.',['风牛']='风牛七号:BAAAKgAECgIIAgAAAA==.',['飬一']='飬一只死一只:BAABKgAFFH8SAAMLAAYIbxmYEQAGAQALAAYIJheYEQAGAQAWAAQIhB0HCwDzAAAAAA==.',['马佩']='马佩佩:BAACKgAFFH8+AAMfAAgI4yNCAQCbAgAfAAgI4yNCAQCbAgAdAAYIaBKjEABeAQAqAAQKfzYAAx8ACAgUJgAEAMQCAB8ACAgUJgAEAMQCAB0ACAgBHLQnACQCAAAA.',['魅影']='魅影燃天:BAAAKgAFFAMIAwAAAA==.魅影祖阿玛尼:BAAAKgAFFAIIAgAAAA==.',['麦桐']='麦桐:BAAAKgAECggIDwAAAA==.',['黄昏']='黄昏之歌:BAAAKgAECgYIBgAAAA==.',['黎可']='黎可儿:BAAAKgAECggICQAAAA==.',['龙希']='龙希尔唤魔师:BAAAKgAFFAEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end