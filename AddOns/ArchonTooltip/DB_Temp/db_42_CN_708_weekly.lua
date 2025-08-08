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
 local lookup = {'Mage-Arcane','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Blood','Monk-Windwalker','Monk-Mistweaver','Paladin-Retribution','Warrior-Fury','DeathKnight-Unholy','Shaman-Restoration','Shaman-Elemental','Warrior-Protection','Hunter-Marksmanship','Druid-Restoration','Druid-Balance','Rogue-Outlaw','Rogue-Assassination','Unknown-Unknown','Mage-Fire','Warlock-Destruction','Hunter-Survival','Warrior-Arms','Priest-Discipline','Priest-Shadow','Priest-Holy','Paladin-Protection','Evoker-Preservation','Evoker-Devastation','Mage-Frost','Hunter-BeastMastery','Monk-Brewmaster','Warlock-Demonology','Warlock-Affliction','Rogue-Subtlety','DeathKnight-Frost','Shaman-Enhancement','Paladin-Holy','Evoker-Augmentation','Druid-Guardian',}; local provider = {region='CN',realm='月神殿',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alfrend:BAABKgAFFH8GAAIBAAYILx4nDQCTAQABAAYILx4nDQCTAQAAAA==.',Ap='Aphradite:BAABKgAFFH8IAAMCAAQIUBN8IgCqAAACAAQIUBN8IgCqAAADAAQIbQO9EAB8AAAAAA==.',Ar='Arc:BAABKgAFFH8GAAIEAAYIIBY5DQBCAQAEAAYIIBY5DQBCAQAAAA==.Arcturis:BAAAKgAFFAIIAgAAAA==.',Ba='Banamaster:BAABKgAECn8XAAMFAAcIDB7ZHAD3AQAFAAcIDB7ZHAD3AQAGAAYIIA+wUwDsAAAAAA==.',Bi='Bianlin:BAAAKgAECggICAAAAA==.',Bo='Borlar:BAACKgAFFH8RAAIHAAMIQQdgLwCoAAAHAAMIQQdgLwCoAAAqAAQKfyAAAgcABwiQFI6OADABAAcABwiQFI6OADABAAAA.',Ca='Caliil:BAABKgAFFH8KAAIIAAQIrxggDQAHAQAIAAQIrxggDQAHAQAAAA==.',Ch='Chudatou:BAAAKgAECggICAAAAA==.',Cj='Cjq:BAAAKgAECgEIAQAAAA==.',Cl='Clarins:BAAAKgADCggICAAAAA==.',Da='Dawn:BAAAKgAECgUICAAAAA==.',Df='Dfgh:BAAAKgADCgIIAgAAAA==.',Dk='Dkt:BAAAKgAECgIIAgAAAA==.',Do='Doingxd:BAAAKgAFFAMIAwAAAA==.',Dr='Dryad:BAAAKgADCgEIAQAAAA==.',Ei='Eileener:BAAAKgAECgUICAAAAA==.',En='Enya:BAAAKgADCgIIAgAAAA==.',Ev='Evilknight:BAAAKgAECggICAAAAA==.',Ez='Eziodaf:BAAAKgAECgYICAAAAA==.',Fa='Falin:BAAAKgAFFAYIBAAAAA==.Fantasyning:BAABKgAFFH8MAAMJAAYIvxlHAwCoAQAJAAYIuhJHAwCoAQAEAAYInRhHCQCBAQAAAA==.',Fo='Fofofofofo:BAAAKgAFFAYIBAAAAA==.Forpandaria:BAABKgAFFH8IAAMKAAgIOxP+CgBOAQAKAAYI1BD+CgBOAQALAAIIuQgEFABqAAAAAA==.',Go='Gosunny:BAAAKgAECgUIDgAAAA==.',Ho='Hobby:BAAAKgAECgUIDAAAAA==.',Ic='Icy:BAAAKgAFFAgIBAAAAA==.',In='Influenza:BAACKgAFFH8IAAMIAAUIDQ39DwBWAQAIAAUIDQ39DwBWAQAMAAEIEwQeGQAfAAAqAAQKfxYAAggACAjZGL4eAN0BAAgACAjZGL4eAN0BAAEqAAUUCAgPAAoASSEA.',Ir='Irises:BAAAKgAFFAQIBAAAAA==.',Je='Jett:BAABKgAFFH8NAAINAAUIeR3jBAAmAQANAAUIeR3jBAAmAQAAAA==.',Kr='Krsae:BAABKgAFFH8QAAIBAAgILAZ6CwChAQABAAgILAZ6CwChAQAAAA==.',Ku='Kujojotaroe:BAABKgAFFH8HAAIKAAQIGRHpFwDFAAAKAAQIGRHpFwDFAAAAAA==.',La='Laladin:BAAAKgADCgEIAQAAAA==.',Le='Lelelele:BAABKgAFFH8GAAIOAAYIIB5UBgCzAQAOAAYIIB5UBgCzAQAAAA==.',Me='Meshinning:BAAAKgAECgMIAwAAAA==.Metrogoose:BAAAKgAECgYICAAAAA==.',My='Mynewdream:BAABKgAECn8WAAMOAAgIjxZgKgCCAQAOAAgIjxZgKgCCAQAPAAEI+AfhxgA2AAAAAA==.',Ni='Nightingale:BAAAKgAECgIIAgAAAA==.',Nu='Nullms:BAAAKgAECgIIAwAAAA==.',Pa='Paint:BAAAKgAFFAQIAgABKgAFFAgIBgABALAdAA==.Pandia:BAABKgAFFH8JAAMPAAQI0BWtLACBAAAPAAMIsQ2tLACBAAAOAAEIRxZMIABFAAAAAA==.',Pe='Peace:BAAAKgADCggICAAAAA==.',Ph='Pharah:BAABKgAFFH8TAAMOAAYIfRZMCACFAQAOAAYIfRZMCACFAQAPAAIIkxTRSACNAAAAAA==.',Po='Portofino:BAAAKgAFFAEIAQAAAA==.',Qw='Qwoto:BAAAKgAECgEIAQAAAA==.',Sa='Sacasaca:BAAAKgAECgQIBAAAAA==.Samule:BAABKgAFFH8GAAIHAAYIzwWxMQAiAQAHAAYIzwWxMQAiAQAAAA==.Sanson:BAACKgAFFH8GAAIQAAYI2ApQAgA+AQAQAAYI2ApQAgA+AQAqAAQKfxgAAxAACAghGrQFABYCABAACAghGrQFABYCABEACAjoDSkbAKsBAAAA.',Se='Senson:BAAAKgAECgcIBwAAAA==.',Tr='Trash:BAAAKgAECgYIBgAAAA==.',Un='Unwilling:BAAAKgAFFAQIBAABKgAFFAgIBAASAAAAAA==.',Up='Upup:BAAAKgAECgEIAQAAAA==.',Wh='Whisperer:BAABKgAFFH8IAAIHAAgImAdiDwCsAQAHAAgImAdiDwCsAQAAAA==.',Za='Zangiefu:BAABKgAFFH8OAAMPAAYIzBCpGgBEAQAPAAYIzBCpGgBEAQAOAAQIUhBCHwCvAAAAAA==.',['一个']='一个路人突然:BAAAKgAFFAIIAgAAAA==.',['一只']='一只橘喵:BAAAKgAFFAQIBAAAAA==.',['一猎']='一猎羽一:BAAAKgAECggICgAAAA==.',['一箭']='一箭入梦:BAAAKgAECgEIAQAAAA==.',['一米']='一米八二:BAABKgAFFH8MAAITAAYIChU7DQBkAQATAAYIChU7DQBkAQABKgAFFAgIAgASAAAAAA==.',['一袋']='一袋米扛几楼:BAAAKgAECggICAABKgAFFAgICAAJAL8WAA==.',['上九']='上九天揽月:BAAAKgAECggICgAAAA==.',['上山']='上山去修道:BAAAKgAFFAgIBAAAAA==.',['下五']='下五洋捉鼈:BAAAKgAECggIEgAAAA==.',['不会']='不会净化:BAABKgAFFH8GAAIUAAYIvQ05GQA6AQAUAAYIvQ05GQA6AQAAAA==.',['不动']='不动行光:BAAAKgAECgYIBgAAAA==.',['不学']='不学吾术:BAAAKgAECggICgAAAA==.',['不知']='不知从哪来:BAAAKgADCgUIBQAAAA==.',['不许']='不许老公碰你:BAAAKgAECgIIAgAAAA==.',['世末']='世末凉子:BAABKgAECn8eAAMVAAgIYyOIAQDDAgAVAAgIYyOIAQDDAgANAAQItRpBTQDnAAAAAA==.',['丘比']='丘比特之贱:BAABKgAFFH8IAAINAAgIFhk+BgAHAgANAAgIFhk+BgAHAgAAAA==.',['业业']='业业:BAAAKgADCggICAAAAA==.',['两串']='两串羊肉串:BAAAKgAFFAMIAwAAAA==.',['两手']='两手一攤:BAAAKgAFFAYIBAAAAA==.',['丨赫']='丨赫灬夕丨:BAAAKgAFFAQIBAAAAA==.',['丫丫']='丫丫槌:BAABKgAECn8oAAIHAAgIaB60EABUAgAHAAgIaB60EABUAgAAAA==.',['丶所']='丶所谓:BAAAKgAFFAEIAQAAAA==.',['丶曲']='丶曲罢:BAABKgAFFH8NAAIWAAYI0yBrAAD9AQAWAAYI0yBrAAD9AQAAAA==.',['为爱']='为爱丶如果:BAAAKgADCgEIAQAAAA==.为爱丶爸爸:BAAAKgADCgUIBQAAAA==.',['乔治']='乔治:BAAAKgAFFAYIBAAAAA==.',['乖乖']='乖乖站好丶:BAACKgAFFH9NAAMXAAgICyGyAADGAgAXAAgICyGyAADGAgAYAAEINQz8MAAzAAAqAAQKfx0AAxcACAg0IogLAHUCABcACAg0IogLAHUCABkAAgi/B1qFAFYAAAAA.',['九个']='九个九:BAAAKgAECgEIAQAAAA==.',['九成']='九成九:BAAAKgAECgMIBwAAAA==.',['九点']='九点九:BAABKgAECn8XAAMHAAgI/hrJPQALAgAHAAgI/hrJPQALAgAaAAEIZAAAAAAAAAAAAA==.九点睡:BAAAKgAECgIIAgAAAA==.',['九转']='九转回锅肉:BAABKgAFFH8IAAIUAAQIjRulEADkAAAUAAQIjRulEADkAAAAAA==.',['九零']='九零丶咕咕:BAABKgAFFH8QAAMPAAgI2QySCgDnAQAPAAgI2QySCgDnAQAOAAEI5gETGQA1AAAAAA==.',['五更']='五更瑠璃:BAABKgAFFH8GAAIBAAYIYhDbEgBPAQABAAYIYhDbEgBPAQABKgAFFAgICgABAAsNAA==.',['亚瑟']='亚瑟丶摩根:BAABKgAFFH8FAAIJAAUIURaFEQCPAQAJAAUIURaFEQCPAQAAAA==.',['京东']='京东配送员:BAAAKgAECgcICAAAAA==.',['亲爱']='亲爱的酒蒙子:BAABKgAFFH8JAAMbAAYIgRRPBADtAAAbAAQI5hRPBADtAAAcAAMIEA6ZNABAAAABKgAFFAgICAAPAEQVAA==.',['人造']='人造人九号:BAAAKgADCgIIAgAAAA==.',['人间']='人间无骨:BAAAKgAECgMIAwAAAA==.人间無骨:BAABKgAECn8nAAIIAAgIcBKdLADVAQAIAAgIcBKdLADVAQAAAA==.',['今夜']='今夜我目田:BAAAKgADCggICAAAAA==.',['仙迪']='仙迪的耳朵:BAAAKgADCggICAAAAA==.',['令羽']='令羽支羽:BAAAKgAECgcICQAAAA==.',['会打']='会打针的美妹:BAAAKgADCgEIAQAAAA==.',['传承']='传承玛格:BAAAKgAFFAgIBAAAAA==.',['伯牙']='伯牙:BAABKgAFFH8FAAIJAAQI5xP+FgDbAAAJAAQI5xP+FgDbAAAAAA==.',['你是']='你是最棒的咕:BAAAKgAFFAgIBAAAAA==.',['依依']='依依小雪:BAAAKgADCggICAAAAA==.',['偌只']='偌只如初见:BAAAKgAECggICAAAAA==.',['催奈']='催奈何:BAABKgAECn8oAAIdAAgIdR7EDQBlAgAdAAgIdR7EDQBlAgAAAA==.',['光之']='光之使者:BAAAKgAECgYICQAAAA==.',['兔兔']='兔兔大坏蛋:BAAAKgAECgcICwAAAA==.',['全场']='全场两分钱:BAACKgAFFH82AAQNAAgIVSPLAwBXAgANAAgI/SHLAwBXAgAeAAcIWRyyBACKAQAVAAEI1BFEBABNAAAqAAQKfxoAAx4ACAhFIDM7AAoCAB4ACAhFIDM7AAoCAA0AAgjYF2ZlAJEAAAAA.',['六个']='六个六:BAABKgAECn8hAAIZAAgIaxR6EgBlAQAZAAgIaxR6EgBlAQAAAA==.',['六道']='六道武动:BAAAKgAECgcIAgAAAA==.',['兰法']='兰法:BAAAKgAECgIIAgAAAA==.',['兽兵']='兽兵乙:BAAAKgADCggIDAAAAA==.',['兽灵']='兽灵行者:BAABKgAFFH8IAAIHAAgIUQrBDQDGAQAHAAgIUQrBDQDGAQAAAA==.',['冈仁']='冈仁波齐:BAACKgAFFH8iAAIIAAcI0BLkDACAAQAIAAcI0BLkDACAAQAqAAQKfywAAggACAjGHsAaADkCAAgACAjGHsAaADkCAAAA.',['军团']='军团宇:BAAAKgADCggICAAAAA==.',['冫曲']='冫曲罢:BAABKgAFFH8MAAMPAAQIVSWUEgCIAQAPAAQIVSWUEgCIAQAOAAEISgQAAAAAAAAAAA==.',['冲锋']='冲锋拦截:BAAAKgADCgQIBAAAAA==.',['凝眉']='凝眉笑想思:BAABKgAECn8xAAQZAAgIQhppDADEAQAZAAgIcRdpDADEAQAXAAgIexfWGwC6AQAYAAMIhgEVdgAvAAAAAA==.',['凤图']='凤图:BAABKgAECn8tAAIIAAgIoxt5BwBKAgAIAAgIoxt5BwBKAgAAAA==.',['刁七']='刁七七:BAAAKgADCggICAAAAA==.',['刁柒']='刁柒柒:BAAAKgADCgYIBgAAAA==.',['刘鹏']='刘鹏啊:BAAAKgAECgIIAgAAAA==.',['剑神']='剑神一笑:BAAAKgAECgMIAwAAAA==.',['勝天']='勝天半子:BAAAKgAECggICQAAAA==.',['北落']='北落丿:BAAAKgAFFAMIBAAAAA==.',['匚丶']='匚丶东方树叶:BAAAKgAECgcICQAAAA==.匚丶元气森林:BAAAKgAECggICQAAAA==.匚丶寒溪柠水:BAAAKgAECggIDwAAAA==.匚丶山楂树下:BAACKgAFFH8WAAMMAAMIEAgsEAB9AAAMAAMIEAgsEAB9AAAIAAMITgHdMQBpAAAqAAQKfyEAAwwACAgQDcodABUBAAgACAicBixKAD0BAAwACAgEDModABUBAAAA.匚丶崂山可乐:BAAAKgAFFAMIAwAAAA==.匚丶果粒橙:BAAAKgAECgYIDQAAAA==.匚丶水晶葡萄:BAAAKgAECgQIBAAAAA==.',['十三']='十三月末:BAABKgAFFH8IAAMWAAQIBx6WCwBTAQAWAAQIMByWCwBTAQAIAAQIRBIeEgA3AQAAAA==.',['十二']='十二福:BAAAKgADCggICAAAAA==.',['十大']='十大名器之首:BAAAKgADCggICAAAAA==.',['千面']='千面之月:BAAAKgAFFAQIBAAAAA==.',['半墓']='半墓尘沙:BAAAKgADCgEIAQAAAA==.',['半度']='半度纯色:BAABKgAFFH8GAAIHAAYIoAisLQAxAQAHAAYIoAisLQAxAQAAAA==.',['半节']='半节黄瓜:BAABKgAFFH8MAAIRAAYI4RWXFgDyAAARAAYI4RWXFgDyAAAAAA==.',['卡徳']='卡徳加:BAAAKgAECgYICwAAAA==.',['卡班']='卡班哈:BAAAKgAECgUIBQAAAA==.',['厦吉']='厦吉丶布朗:BAAAKgAFFAEIAQAAAA==.',['又见']='又见风华:BAAAKgADCgEIAQAAAA==.',['古尓']='古尓丹:BAACKgAFFH8QAAIUAAMIZgkgHgCUAAAUAAMIZgkgHgCUAAAqAAQKfyEAAhQACAhEHEgGAEoCABQACAhEHEgGAEoCAAAA.',['只为']='只为娱乐:BAABKgAFFH8KAAIaAAYImA30EQDvAAAaAAYImA30EQDvAAAAAA==.',['可乐']='可乐冰冰凉:BAABKgAFFH8JAAIHAAMI1hTOVwDBAAAHAAMI1hTOVwDBAAAAAA==.',['可可']='可可卡纸:BAAAKgAECgEIAQAAAA==.',['吃饱']='吃饱撑的:BAAAKgADCggICAAAAA==.',['吉吉']='吉吉国王陆宇:BAABKgAECn8aAAIHAAgIgiJYGAC2AgAHAAgIgiJYGAC2AgAAAA==.',['吖啼']='吖啼:BAAAKgAFFAEIAQAAAA==.',['呀灭']='呀灭带:BAAAKgAFFAgIAgAAAA==.',['呆丶']='呆丶穆頭:BAAAKgAECgIIAgAAAA==.',['呕吼']='呕吼:BAACKgAFFH8OAAIfAAQIuCBJAwAiAQAfAAQIuCBJAwAiAQAqAAQKfywAAx8ACAhuJOMBAL4CAB8ACAhuJOMBAL4CAAUAAQjACeR4ADIAAAEqAAUUBQgVABoAohsA.',['周一']='周一也要玩:BAAAKgAECgYIBwAAAA==.',['周二']='周二也要玩:BAAAKgAECgEIAQAAAA==.',['呱呱']='呱呱:BAAAKgAFFAMIAwAAAA==.',['咕咕']='咕咕大王:BAABKgAFFH8KAAMPAAYIwAqVKgDoAAAPAAUIQAyVKgDoAAAOAAUIQwqcGgDMAAAAAA==.',['咩咩']='咩咩羊羊:BAAAKgADCgEIAQABKgADCgIIAgASAAAAAA==.',['咸鱼']='咸鱼的小菊花:BAABKgAFFH8KAAIJAAYIaRV9DAA9AQAJAAYIaRV9DAA9AQAAAA==.',['哈基']='哈基龙:BAACKgAFFH8SAAMcAAYI9BOBDgB4AQAcAAYI9BOBDgB4AQAbAAEI5wAGDQAlAAAqAAQKfxYAAxwACAhdFx0fAMEBABwACAhdFx0fAMEBABsABAg7BpEaALUAAAAA.',['哈库']='哈库珀:BAABKgAECn8rAAMdAAgILCMyCwCrAgAdAAgILCMyCwCrAgATAAEIsAoyogArAAAAAA==.',['哈集']='哈集美:BAAAKgAFFAQIBAAAAA==.',['哎呀']='哎呀又胖惹:BAAAKgAFFAMIAwAAAA==.',['唐迪']='唐迪克:BAAAKgAECgcIDwAAAA==.',['唔姆']='唔姆唔姆:BAAAKgAECgMIBQAAAA==.',['唧唧']='唧唧复唧唧:BAAAKgAECgYIEAAAAA==.',['啊哈']='啊哈呀:BAABKgAECn8WAAMIAAgIuRC7TgAmAQAIAAgIuRC7TgAmAQAWAAUIbwcESQCpAAAAAA==.',['啦乄']='啦乄啦:BAACKgAFFH8FAAIUAAUIUCR2EACLAQAUAAUIUCR2EACLAQAqAAQKfzAABBQACAh8JZABAOECABQACAiiJJABAOECACAACAh5JFoHAH0CACEAAQjdHeFAAEIAAAAA.啦乄轰:BAABKgAECn8UAAIHAAgIGSF4HQCNAgAHAAgIGSF4HQCNAgABKgAFFAgIBQAUAFAkAA==.',['喜哩']='喜哩哩:BAABKgAFFH8IAAIHAAQInB1dEwAJAQAHAAQInB1dEwAJAQAAAA==.',['喵喵']='喵喵多狸:BAAAKgAFFAIIAgAAAA==.',['嗜杀']='嗜杀者丨枯骨:BAABKgAFFH8IAAIJAAgI9hNdBgAwAgAJAAgI9hNdBgAwAgAAAA==.',['嘟嘟']='嘟嘟花虾米:BAAAKgAFFAQIBAAAAA==.',['四阿']='四阿哥:BAAAKgAECggIEgAAAA==.',['回忆']='回忆精灵:BAABKgAECn8hAAIUAAgItRDvEwBvAQAUAAgItRDvEwBvAQAAAA==.',['圆滚']='圆滚滚雷滚滚:BAABKgAFFH8GAAIKAAQIcQh5GADCAAAKAAQIcQh5GADCAAABKgAFFAgIAwASAAAAAA==.',['圣光']='圣光之怒火:BAAAKgADCggIEAAAAA==.圣光之灵:BAAAKgAECgEIAQAAAA==.圣光奶嘴:BAAAKgAECggIDwAAAA==.圣光忽忧着你:BAACKgAFFH8VAAIaAAUIoht2CwBAAQAaAAUIoht2CwBAAQAqAAQKfyQAAhoACAhkJcMBAPQCABoACAhkJcMBAPQCAAAA.圣光老流氓:BAAAKgAFFAMIAwAAAA==.圣光道标:BAABKgAFFH8GAAIHAAYI7wcUKwA7AQAHAAYI7wcUKwA7AQAAAA==.',['圣武']='圣武堂帕拉丁:BAAAKgAFFAYIBAAAAA==.',['地狱']='地狱宠尔:BAAAKgAECggICAAAAA==.',['坷垃']='坷垃熊猫:BAAAKgADCggICAAAAA==.',['堅持']='堅持就會崩潰:BAAAKgADCggIEAAAAA==.',['塞勒']='塞勒斯汀:BAABKgAFFH8IAAIHAAgIKRyeBACFAgAHAAgIKRyeBACFAgAAAA==.',['壯士']='壯士執鞭:BAAAKgAECgIIAgAAAA==.',['夜丶']='夜丶墓:BAACKgAFFH8MAAIgAAMIMRk3CgDlAAAgAAMIMRk3CgDlAAAqAAQKfyIAAiAACAgLHw0KAFQCACAACAgLHw0KAFQCAAAA.夜丶睦:BAAAKgAECgMIAwAAAA==.',['夜墓']='夜墓丶:BAAAKgAFFAIIAgAAAA==.',['夜暮']='夜暮丶:BAAAKgAECgYIBgAAAA==.',['夜牧']='夜牧丶:BAAAKgAECgUIBQAAAA==.',['夜雨']='夜雨渡寒鸦:BAAAKgAFFAgIBAAAAA==.',['夢遊']='夢遊:BAAAKgADCggICAAAAA==.',['大丷']='大丷吉:BAAAKgAECgIIAgABKgAECgQIBAASAAAAAA==.',['大刀']='大刀:BAAAKgADCgIIAgAAAA==.',['大器']='大器晚成:BAAAKgAECgcIEgAAAA==.',['大战']='大战光与影:BAABKgAFFH8JAAMZAAcITA2ADQDyAAAZAAUIZhCADQDyAAAXAAQIKwcPJACRAAAAAA==.',['大方']='大方无隅:BAAAKgAECgQIBAAAAA==.',['大白']='大白免:BAABKgAFFH8IAAQUAAYITxq+FwBGAQAUAAYIbhe+FwBGAQAgAAEIEBCdKQBHAAAhAAEIwwH/IwA+AAAAAA==.',['大米']='大米团:BAAAKgAECgUIBwAAAA==.',['大萝']='大萝卜:BAAAKgAECggIEAAAAA==.',['天下']='天下睿行:BAABKgAECn8uAAIIAAgI2Rq0CQATAgAIAAgI2Rq0CQATAgAAAA==.',['天天']='天天中彩票:BAAAKgAECgMIAwAAAA==.天天戰晚班:BAABKgAFFH8IAAIWAAgIKAYHBgC/AQAWAAgIKAYHBgC/AQAAAA==.',['天添']='天添:BAAAKgAFFAQIAgAAAA==.',['天空']='天空城:BAAAKgADCggIGgAAAA==.',['天罡']='天罡北斗阵:BAAAKgADCggICAAAAA==.',['天蓝']='天蓝魔音:BAAAKgAECgYIBgAAAA==.',['太猛']='太猛了太猛了:BAABKgAFFH8IAAMMAAQIVAk2BwCcAAAIAAQIygcnFwDMAAAMAAQI4wY2BwCcAAAAAA==.',['奈何']='奈何月咏:BAAAKgAFFAgIAQAAAA==.',['奔跑']='奔跑的肉夹馍:BAAAKgAECgMIAwAAAA==.',['奶萨']='奶萨:BAAAKgAECgMIAwAAAA==.',['她说']='她说她愿意灬:BAAAKgAECgIIAgAAAA==.',['如如']='如如之心:BAAAKgADCggIEAAAAA==.',['妈妈']='妈妈:BAAAKgAFFAQIBAAAAA==.',['姓字']='姓字半藏半显:BAAAKgAFFAYIAgAAAA==.',['孫悟']='孫悟空:BAAAKgAFFAYIBAABKgAFFAgIDwAGAO4LAA==.',['安杰']='安杰:BAAAKgAECggICAAAAA==.',['宝宝']='宝宝冲锋:BAAAKgAECgcIEwABKgAECggIJQAZAKgZAA==.',['寒凝']='寒凝露:BAAAKgAFFAYIBAAAAA==.',['小二']='小二喜:BAABKgAFFH8GAAMLAAQI5Bc/CQDlAAALAAQI5Bc/CQDlAAAKAAEIAADHVgAAAAAAAA==.',['小伙']='小伙子跳跳蹦:BAAAKgADCgYIBgAAAA==.',['小半']='小半半:BAABKgAFFH8TAAIFAAQIbRnKDQDNAAAFAAQIbRnKDQDNAAAAAA==.',['小宝']='小宝栗子:BAAAKgAECggIDgAAAA==.',['小尾']='小尾巴萌萌哒:BAABKgAFFH8QAAIHAAcIQxtVCgAfAgAHAAcIQxtVCgAfAgAAAA==.',['小布']='小布尔乔亚:BAACKgAFFH8IAAIaAAMIyg5XDgCaAAAaAAMIyg5XDgCaAAAqAAQKfxwAAhoACAiCGoEWALsBABoACAiCGoEWALsBAAAA.',['小德']='小德嘚嘚:BAAAKgAECggICAAAAA==.',['小枕']='小枕头你别跑:BAAAKgAECgEIAQAAAA==.',['小玲']='小玲珑:BAAAKgAFFAIIBAAAAA==.',['小白']='小白兔怕脏:BAAAKgADCggICAAAAA==.',['小福']='小福腻:BAAAKgAFFAgIAQAAAA==.',['小老']='小老弟:BAAAKgADCgIIAgAAAA==.小老温:BAAAKgADCggICAABKgADCggIDwASAAAAAA==.',['小被']='小被子盖头:BAAAKgADCgIIAgAAAA==.小被子蒙头:BAAAKgAECgIIAgAAAA==.',['小蹄']='小蹄:BAABKgAECn8ZAAIKAAgItxAjSgBiAQAKAAgItxAjSgBiAQAAAA==.',['小钱']='小钱钱买烤串:BAAAKgAECgMIAwAAAA==.小钱钱存银行:BAAAKgAECgIIAgAAAA==.',['尤志']='尤志志:BAACKgAFFH8cAAIDAAQImyM+BwAsAQADAAQImyM+BwAsAQAqAAQKfykAAwMACAhxJoIBAP8CAAMACAhxJoIBAP8CAAIAAgiJGAh5AIAAAAEqAAUUBQgVABoAohsA.',['就是']='就是当兵:BAACKgAFFH8nAAQRAAMIyxr3FAAEAQARAAMIyxr3FAAEAQAQAAMIYwoXBwCfAAAiAAEI/wZNEgBAAAAqAAQKfy8ABBEACAj3HC8PABQCABEACAjUHC8PABQCABAABAh2FcQPAAcBACIABggeDkwPAHkAAAAA.',['屠龙']='屠龙小子:BAAAKgAECgYICwAAAA==.',['山水']='山水相逢:BAAAKgAECgUICgAAAA==.',['巧芙']='巧芙乐:BAAAKgAECgIIAgAAAA==.',['巨象']='巨象纵横:BAAAKgADCgIIAgAAAA==.',['布劳']='布劳缪克斯:BAAAKgAECgYICwAAAA==.',['布林']='布林:BAAAKgADCgcIBwAAAA==.',['布瑞']='布瑞克铁炉:BAACKgAFFH8mAAMWAAYI+Q/yDgAiAQAWAAYIPQ/yDgAiAQAIAAEIQQVFNwBDAAAqAAQKfycAAhYACAjWG4MZAOcBABYACAjWG4MZAOcBAAAA.',['布莱']='布莱恩铜须:BAAAKgAECgIIAgAAAA==.',['希兹']='希兹克俐芙:BAAAKgAECgMIAwAAAA==.希兹克利夫:BAABKgAECn8fAAMHAAgILhtJUgD9AQAHAAgILhtJUgD9AQAaAAIIeAlSTwBDAAAAAA==.',['帝娜']='帝娜的耳朵:BAAAKgADCggIEAAAAA==.',['干锅']='干锅小烧卖:BAACKgAFFH9AAAMTAAgIVh6GAwBzAgATAAgIVh6GAwBzAgABAAUIwAkaIQDjAAAqAAQKfzAAAhMACAgkH+0eADoCABMACAgkH+0eADoCAAAA.',['平方']='平方:BAABKgAFFH8RAAMYAAgIxwyfBQDdAQAYAAgIxwyfBQDdAQAZAAMI3BQ2FACeAAAAAA==.',['并非']='并非法人:BAAAKgADCgEIAQAAAA==.',['幻丶']='幻丶格拉墨:BAAAKgAECgQIBAAAAA==.',['康斯']='康斯:BAAAKgAECgUIBQAAAA==.',['引雷']='引雷针:BAAAKgAECgQIBAAAAA==.',['张小']='张小贤:BAAAKgADCggICAAAAA==.',['影子']='影子神话:BAAAKgAECgEIAQAAAA==.',['影月']='影月之月:BAAAKgAECgUIBQAAAA==.',['很想']='很想回到从前:BAABKgAECn8zAAMeAAgIJBbhFwDAAQAeAAgIJBbhFwDAAQANAAIIXAjcnQBBAAAAAA==.',['徒手']='徒手丶搓天雷:BAAAKgAFFAIIAgAAAA==.',['德莱']='德莱不费功夫:BAABKgAFFH8wAAIHAAgICBgmDwDpAQAHAAgICBgmDwDpAQAAAA==.',['心丶']='心丶跳:BAAAKgAECgYIBgAAAA==.',['心怀']='心怀圣光:BAAAKgADCggIEAAAAA==.',['心跳']='心跳:BAAAKgAECgcIBwAAAA==.',['忘嘚']='忘嘚芙:BAAAKgAFFAYIBAABKgAFFAgICAAeABcdAA==.',['忘尘']='忘尘一凡:BAABKgAECn8bAAIHAAgIIAGpYAFIAAAHAAgIIAGpYAFIAAAAAA==.',['思乡']='思乡的浪子:BAAAKgAFFAEIAgAAAA==.',['恐山']='恐山安娜:BAAAKgADCggICAAAAA==.',['恨天']='恨天无环:BAAAKgAECgcIEAAAAA==.',['恶魔']='恶魔十三:BAAAKgAFFAYIBAABKgAFFAgICAAeAHkgAA==.',['慕仁']='慕仁:BAAAKgAFFAgIBAAAAA==.',['慕晓']='慕晓:BAABKgAFFH8IAAMXAAgIlBImDgA3AQAXAAQIzA0mDgA3AQAZAAQI9BguHwDMAAAAAA==.',['慕魇']='慕魇:BAABKgAFFH8GAAMhAAYIXhkBCQCsAAAUAAQIUh5WKQDJAAAhAAII8REBCQCsAAAAAA==.',['成功']='成功支付:BAAAKgADCgIIAgAAAA==.',['我不']='我不这么认为:BAABKgAFFH8IAAIPAAQIMSF9KwDkAAAPAAQIMSF9KwDkAAAAAA==.',['我是']='我是德鲁乙:BAAAKgAFFAIIAgAAAA==.',['我来']='我来自传说:BAAAKgAECgYIEAAAAA==.',['我爱']='我爱长发飘飘:BAACKgAFFH8XAAIJAAMIsxciLQDaAAAJAAMIsxciLQDaAAAqAAQKfy0AAwkACAjwHW8dACYCAAkACAj1HG8dACYCACMABggWGKsVAFcBAAAA.',['扎西']='扎西桑悟:BAAAKgAECgUIBQAAAA==.',['打嗰']='打嗰锤吇:BAAAKgAFFAQIAgAAAA==.',['折尽']='折尽风前柳:BAAAKgAFFAEIAgAAAA==.',['拂晓']='拂晓之光:BAABKgAFFH8GAAIaAAYIIRPLDgATAQAaAAYIIRPLDgATAQAAAA==.',['拉克']='拉克斯:BAAAKgADCggICAAAAA==.',['拉風']='拉風男人丶:BAAAKgAECgMIAwAAAA==.',['拾一']='拾一:BAABKgAFFH8JAAMgAAUIZBEfFgCWAAAUAAIIgBFkNACeAAAgAAMIUhEfFgCWAAAAAA==.',['持靓']='持靓行凶:BAABKgAFFH8RAAIJAAYIHCSOCAAGAgAJAAYIHCSOCAAGAgABKgAFFAgIDgAHACocAA==.',['挽魂']='挽魂之歌:BAAAKgAECgMIAwAAAA==.',['提拉']='提拉斯丶夜翼:BAABKgAECn8aAAIPAAgIRCONEAClAgAPAAgIRCONEAClAgABKgAFFAgIDgABACQgAA==.',['提里']='提里奥佛丁:BAAAKgAECgEIAQAAAA==.',['撒爽']='撒爽英姿:BAAAKgAECgYIBgAAAA==.',['文斯']='文斯莫克:BAAAKgAFFAYIAgAAAA==.',['文艺']='文艺复兴:BAAAKgAECgYIBwAAAA==.',['斩风']='斩风雷:BAAAKgAFFAQIBAAAAA==.',['旅寒']='旅寒兮:BAAAKgAECgcIAgAAAA==.',['旋舞']='旋舞:BAAAKgAFFAYIBAABKgAFFAgIDwAkAC4bAA==.',['无野']='无野:BAABKgAECn8fAAQHAAgIeRQXagCFAQAHAAcIZhUXagCFAQAaAAgIiQvWOgCkAAAlAAMIrQ/COwCaAAAAAA==.',['既定']='既定之天命:BAAAKgADCggICAAAAA==.',['早坂']='早坂爱:BAAAKgADCgUIBQAAAA==.',['早邪']='早邪是冰:BAAAKgAECgcICgAAAA==.',['明日']='明日香蕉:BAAAKgAFFAYIBAAAAA==.',['明月']='明月醉雪颜:BAAAKgAECgIIAgAAAA==.',['春拂']='春拂:BAAAKgADCggICAAAAA==.',['春翼']='春翼盎然:BAAAKgAECgQIBAAAAA==.',['晕晕']='晕晕小公主:BAABKgAFFH8FAAIeAAMINQvJOACFAAAeAAMINQvJOACFAAAAAA==.',['晚来']='晚来风:BAABKgAECn8dAAQdAAcI/SNsCAAWAgAdAAYI4SNsCAAWAgABAAYI6hiUEADJAQATAAUIYByUBQBZAQAAAA==.',['暗色']='暗色萃取:BAAAKgADCggICAAAAA==.',['暴走']='暴走的棉花糖:BAAAKgAFFAQIBAABKgAFFAgICgACAAIRAA==.',['暴躁']='暴躁土拨鼠:BAABKgAECn8jAAIdAAgIzxV/KwDLAQAdAAgIzxV/KwDLAQAAAA==.',['曲罢']='曲罢:BAABKgAFFH8KAAITAAcIGyHRBgCXAQATAAcIGyHRBgCXAQAAAA==.曲罢丶:BAABKgAFFH8RAAMJAAYIKiNiDADJAQAJAAYIKiNiDADJAQAEAAYIgRGFEQAXAQAAAA==.',['月冷']='月冷千山:BAAAKgAECgYICQAAAA==.',['月夜']='月夜佳人:BAAAKgAECgQIBAAAAA==.月夜殇:BAABKgAFFH8GAAIQAAYITgawAwD1AAAQAAYITgawAwD1AAAAAA==.',['月映']='月映沟渠:BAAAKgAECgYIBgAAAA==.月映流光:BAAAKgAFFAMIAwAAAA==.月映流韵:BAAAKgADCgIIAgAAAA==.月映浮萍:BAABKgAFFH8GAAICAAMINwN7IgCCAAACAAMINwN7IgCCAAAAAA==.月映海角:BAAAKgAECgQIBAAAAA==.',['月见']='月见酒:BAAAKgADCgYIBgAAAA==.',['月霰']='月霰:BAABKgAFFH8HAAIUAAcINhBhDQC2AQAUAAcINhBhDQC2AQAAAA==.',['有猫']='有猫在裙角:BAAAKgADCggIDgAAAA==.',['木木']='木木开:BAAAKgADCggICAAAAA==.',['机器']='机器之血:BAACKgAFFH8FAAIdAAMI0AafDwCVAAAdAAMI0AafDwCVAAAqAAQKfywAAh0ACAhzFvQjAJQBAB0ACAhzFvQjAJQBAAAA.',['束手']='束手无策:BAABKgAFFH8FAAMgAAQIDiRiAQBBAQAgAAQIDiRiAQBBAQAUAAEIdQrxTwAzAAAAAA==.',['来根']='来根胡萝卜:BAAAKgADCggIEAAAAA==.',['杰森']='杰森布莱克:BAAAKgAECggIAQAAAA==.',['柏晨']='柏晨:BAABKgAFFH8PAAMeAAcIaRzAFwA8AQAeAAcIQRrAFwA8AQANAAQI0R6PJQDWAAAAAA==.',['格桑']='格桑花:BAABKgAFFH8QAAIZAAgIVQo2BwCFAQAZAAgIVQo2BwCFAQAAAA==.',['桃花']='桃花面:BAAAKgAECgUIBQAAAA==.',['梅花']='梅花:BAAAKgAECggICAAAAA==.',['梦见']='梦见月瑞希:BAAAKgAFFAYIAwAAAA==.',['梧叶']='梧叶:BAABKgAECn8WAAMNAAgIBhLuRAA9AQAeAAgIjw9nUgBlAQANAAgIcw7uRAA9AQAAAA==.',['欣仔']='欣仔:BAACKgAFFH8aAAIJAAUIwh15GABaAQAJAAUIwh15GABaAQAqAAQKfyQAAwkACAjcGnssAMkBAAkACAjcGnssAMkBACMABAhYE3snAIMAAAAA.',['欣欣']='欣欣心心:BAABKgAECn8vAAIGAAgIPxsTEAAbAgAGAAgIPxsTEAAbAgAAAA==.',['欧迪']='欧迪瑞科:BAAAKgAECgEIAQAAAA==.',['歌肥']='歌肥:BAAAKgAECgEIAQAAAA==.',['正弦']='正弦:BAABKgAFFH8HAAImAAcIiwwzAQD8AAAmAAcIiwwzAQD8AAABKgAFFAgIEQAYAMcMAA==.',['正義']='正義:BAAAKgAFFAgIBAAAAA==.',['武锦']='武锦:BAAAKgAECggICAAAAA==.',['比利']='比利陈:BAABKgAFFH8YAAMGAAgI7xVQBQD9AQAGAAgI7xVQBQD9AQAFAAQIpwN0FACQAAAAAA==.',['氨酚']='氨酚守己:BAAAKgADCgMIAwAAAA==.',['水兽']='水兽:BAAAKgADCgIIAgAAAA==.',['水闸']='水闸行动带我:BAABKgAFFH8MAAIZAAYIOiH3AgAzAQAZAAYIOiH3AgAzAQAAAA==.',['池本']='池本莉莉娅:BAAAKgADCggICAAAAA==.',['沐丷']='沐丷苒:BAAAKgAECgIIAgAAAA==.',['河北']='河北彩伽:BAAAKgAECggIAgAAAA==.',['沽名']='沽名学霸王:BAAAKgADCgcICwAAAA==.',['波特']='波特兰:BAABKgAFFH8KAAQaAAYIhAa1FwC6AAAaAAYIwQS1FwC6AAAlAAMIAQiNEAB9AAAHAAEIgwxeTQBOAAAAAA==.',['泰莉']='泰莉娅:BAAAKgAECggICgAAAA==.',['泰蘭']='泰蘭德語風:BAAAKgAECgYIBgABKgAFFAgIBgAUAO4XAA==.',['泽村']='泽村玲子:BAAAKgAECgEIAQAAAA==.',['洁世']='洁世一:BAAAKgADCgMIAwAAAA==.',['流火']='流火七月:BAAAKgADCgYIBgAAAA==.',['浅夏']='浅夏蝶舞:BAAAKgAECgEIAQAAAA==.',['淡若']='淡若青栀:BAAAKgAFFAEIAQAAAA==.',['淡薄']='淡薄了流年:BAABKgAFFH8pAAMNAAgIgh2aBQAbAgANAAgIgh2aBQAbAgAeAAcINRCzGQAwAQAAAA==.',['深渊']='深渊凝望丶:BAAAKgAECgIIAwAAAA==.',['清风']='清风流花语:BAAAKgAECgIIAgAAAA==.',['温大']='温大德:BAAAKgADCggIDwAAAA==.',['溷囿']='溷囿:BAACKgAFFH8sAAMPAAgIEiWvBACCAgAPAAcILyavBACCAgAOAAEIQAqMFwBDAAAqAAQKfzEAAw8ACAjkHxc1AOUBAA8ACAjkHxc1AOUBAA4AAgjcGK9hAJAAAAAA.',['潇洒']='潇洒神鹰:BAAAKgADCggIGwAAAA==.',['潜伏']='潜伏帷幕:BAAAKgADCgYIBgAAAA==.',['澄幽']='澄幽丶:BAABKgAFFH8IAAIPAAgIeQkUDADBAQAPAAgIeQkUDADBAQAAAA==.',['火光']='火光带闪电:BAAAKgAECgUICQAAAA==.',['火舞']='火舞寒霜:BAABKgAFFH8GAAIEAAYI6AbKGgDMAAAEAAYI6AbKGgDMAAAAAA==.',['火鸡']='火鸡炖锅巴:BAAAKgAECgQIBgAAAA==.',['灬麦']='灬麦孖哥灬:BAABKgAECn8bAAMeAAgIkxqgPgCrAQAeAAcISxygPgCrAQANAAQIFQwkkQBYAAAAAA==.',['炽丶']='炽丶格拉墨:BAAAKgAECggICAAAAA==.',['煌辉']='煌辉:BAAAKgADCgcIBwAAAA==.',['熊无']='熊无主菊自开:BAAAKgAECggICAAAAA==.',['熊猫']='熊猫武皇:BAAAKgADCggICAAAAA==.',['熔岩']='熔岩之刃:BAAAKgAECgIIAgAAAA==.',['爆兵']='爆兵:BAAAKgAFFAQIBAAAAA==.',['爆率']='爆率真的很高:BAAAKgAECgcIBwAAAA==.',['爱丽']='爱丽斯威震天:BAAAKgAECgMIBAAAAA==.',['牛曦']='牛曦:BAABKgAFFH8GAAIRAAYIEAfrEABCAQARAAYIEAfrEABCAQAAAA==.',['狂戦']='狂戦:BAAAKgAECgQIBAAAAA==.',['狛枝']='狛枝凪斗:BAAAKgADCgEIAQAAAA==.',['独孤']='独孤幻湮:BAABKgAFFH8FAAMjAAII3APfDwBbAAAjAAIIegPfDwBbAAAJAAII1QGfUABTAAAAAA==.独孤幻灭:BAAAKgAECgQIBAAAAA==.',['猎魔']='猎魔人安妮:BAAAKgADCgUIBQAAAA==.',['猫猫']='猫猫的小德:BAABKgAFFH8MAAMOAAgInBePDgAsAQAOAAQIpRGPDgAsAQAPAAQI/RosGADnAAAAAA==.',['獭耳']='獭耳獭洛斯:BAACKgAFFH8LAAIcAAII5RCgGQCDAAAcAAII5RCgGQCDAAAqAAQKfzMAAhwACAjWG40TACwCABwACAjWG40TACwCAAAA.',['王炸']='王炸:BAAAKgAECgMIBAAAAA==.',['玩童']='玩童:BAABKgAFFH8LAAIIAAYIARGUCgB8AQAIAAYIARGUCgB8AQAAAA==.',['珂珂']='珂珂守护者:BAAAKgAECgUICgAAAA==.',['班婕']='班婕妤:BAACKgAFFH8UAAIUAAMIghSeKgDDAAAUAAMIghSeKgDDAAAqAAQKfykAAhQACAgHIRwRAGECABQACAgHIRwRAGECAAAA.',['琳德']='琳德莉亚:BAAAKgAECgQIBAAAAA==.',['瑞丶']='瑞丶放逐之刃:BAAAKgADCgUIBQAAAA==.',['瑾年']='瑾年丨小铭:BAAAKgAECgcIBwAAAA==.',['瓜皮']='瓜皮和尚:BAABKgAFFH8IAAIGAAMIMBbvGwC+AAAGAAMIMBbvGwC+AAAAAA==.瓜皮牧:BAABKgAFFH8JAAIZAAMIHxGeKACgAAAZAAMIHxGeKACgAAAAAA==.',['生死']='生死看蛋:BAABKgAECn8fAAIHAAgIMhQXZADTAQAHAAgIMhQXZADTAQAAAA==.',['电一']='电一下没网瘾:BAAAKgADCgIIAgAAAA==.',['界赵']='界赵云:BAAAKgAFFAEIAQAAAA==.',['疾风']='疾风怒涛之嗷:BAAAKgAECgQICAAAAA==.',['白色']='白色疤痕:BAAAKgAECggIEAABKgAFFAgIHwAHAO8aAA==.',['神木']='神木盾:BAAAKgAECgMIAwAAAA==.',['祥云']='祥云锦绣火鹰:BAAAKgAFFAIIAgAAAA==.',['福乐']='福乐的雕毛:BAAAKgADCgMIAwAAAA==.',['素裳']='素裳:BAAAKgAFFAQIBAAAAA==.',['紫诏']='紫诏天音:BAAAKgAFFAQIBAAAAA==.',['织月']='织月:BAAAKgAECgQIBAAAAA==.',['绿色']='绿色蔬菜:BAAAKgADCgUIBQAAAA==.',['罗兰']='罗兰乌瑞恩:BAAAKgADCggIDAAAAA==.',['羊枝']='羊枝甘鹿:BAABKgAFFH8GAAIeAAYIkB/FDQCWAQAeAAYIkB/FDQCWAQABKgAFFAgICAAeAHkgAA==.',['美团']='美团:BAABKgAFFH8FAAIEAAQIqw4wEwCsAAAEAAQIqw4wEwCsAAABKgAFFAgICwAEADMTAA==.',['老姚']='老姚不上班:BAAAKgAFFAMIBAAAAA==.',['老温']='老温丶:BAAAKgADCggICAABKgADCggIDwASAAAAAA==.老温哦:BAAAKgADCgIIAgABKgADCggIDwASAAAAAA==.',['老衲']='老衲要還俗:BAAAKgAFFAEIAQAAAA==.',['聆听']='聆听丨故事:BAAAKgAFFAgIBAAAAA==.',['聊天']='聊天一字六毛:BAABKgAFFH8JAAIHAAQImiSYBgBMAQAHAAQImiSYBgBMAQAAAA==.',['自带']='自带光环:BAAAKgAFFAYIBAAAAA==.',['芒果']='芒果蛋糕:BAAAKgADCgEIAQAAAA==.',['花开']='花开锦绣:BAABKgAFFH8IAAMKAAQIARV1EADiAAAKAAQIARV1EADiAAALAAEIGwi0GwBAAAAAAA==.',['花无']='花无媸:BAAAKgAFFAYIBAABKgAFFAgIEAAkAMcjAA==.',['花月']='花月:BAABKgAFFH8JAAIHAAMIxxptPwDzAAAHAAMIxxptPwDzAAAAAA==.',['苍师']='苍师傅:BAAAKgAECgcIBwAAAA==.',['苍流']='苍流:BAABKgAFFH8HAAIDAAQISRrMBgDsAAADAAQISRrMBgDsAAAAAA==.',['苍闻']='苍闻:BAAAKgAFFAQIBAAAAA==.',['苞苞']='苞苞冲锋:BAAAKgAECgQIBwABKgAECggIJQAZAKgZAA==.',['若星']='若星汉的猎痕:BAAAKgAECgIIAgAAAA==.',['若是']='若是风华:BAAAKgAECgcIDAAAAA==.',['苦苦']='苦苦咖啡:BAAAKgADCggIDAAAAA==.',['莫淇']='莫淇洛:BAAAKgAFFAIIAgAAAA==.',['莺歌']='莺歌丽斯:BAAAKgADCggICAAAAA==.',['菜鸟']='菜鸟坟墓:BAAAKgADCgYIBgAAAA==.',['菱灬']='菱灬璃:BAABKgAFFH8GAAIEAAYINxQYDwAuAQAEAAYINxQYDwAuAQAAAA==.',['萦空']='萦空惭夕照:BAAAKgAECgcIBwAAAA==.',['萨拉']='萨拉斯瓦蒂:BAAAKgADCgIIAgAAAA==.',['葡萄']='葡萄:BAACKgAFFH8IAAIgAAIIARlLFwCPAAAgAAIIARlLFwCPAAAqAAQKfyAAAiAACAibFWYXAL0BACAACAibFWYXAL0BAAAA.',['葱烧']='葱烧小糌粑:BAABKgAFFH8IAAIXAAgIlg/aBAD3AQAXAAgIlg/aBAD3AQAAAA==.',['蓓蓓']='蓓蓓冲锋:BAABKgAECn8lAAIZAAgIqBkBHwDlAQAZAAgIqBkBHwDlAQAAAA==.',['蓝月']='蓝月:BAAAKgAECgcIBwAAAA==.',['蓝色']='蓝色就会放电:BAAAKgAECgYIBgAAAA==.蓝色芸雨:BAAAKgADCgEIAQAAAA==.蓝色药姬:BAAAKgADCgcIBwAAAA==.',['蓝黑']='蓝黑之翼:BAAAKgAECgQIBAABKgAECggIJQAZAKgZAA==.',['蕾姆']='蕾姆碳:BAAAKgAECgcICwAAAA==.',['薄冰']='薄冰盛绿云:BAAAKgAECgEIAQAAAA==.',['虎虎']='虎虎摘星辰:BAAAKgADCggICAAAAA==.',['虔诚']='虔诚小猎:BAAAKgADCgQIBAAAAA==.',['虚空']='虚空法皇:BAAAKgADCggIDQAAAA==.',['血肉']='血肉畸变:BAAAKgAECgYIBgAAAA==.',['血色']='血色小猪:BAAAKgAECgIIAgAAAA==.',['衰暮']='衰暮思红颜:BAABKgAFFH8IAAIYAAYIYh6CAQDaAQAYAAYIYh6CAQDaAQABKgAFFAgIBAASAAAAAA==.',['装帅']='装帅好难:BAAAKgAECgMIAwAAAA==.',['装逼']='装逼的小女孩:BAAAKgAECggICAAAAA==.',['装龙']='装龙作雅:BAAAKgADCggIEAAAAA==.',['西门']='西门红袖:BAAAKgAECggICAAAAA==.',['要饭']='要饭小能手:BAEBKgAFFH8WAAMXAAcIQBpAAgCdAQAXAAcIQBpAAgCdAQAYAAEIPwtuJQBJAAAAAA==.',['记忆']='记忆精灵:BAAAKgAECggIEwAAAA==.',['许愿']='许愿:BAAAKgAFFAQIBAAAAA==.',['话痨']='话痨牛:BAAAKgAFFAQIBAAAAA==.',['谛丶']='谛丶格拉墨:BAAAKgAECggIDAAAAA==.',['谟涅']='谟涅摩叙涅:BAAAKgADCgcIBwAAAA==.',['豌豆']='豌豆芽:BAABKgAECn8lAAIHAAgIliGHGACkAgAHAAgIliGHGACkAgABKgAFFAYIBgAPAOkUAA==.',['贝思']='贝思柯德:BAAAKgAECgEIAQAAAA==.',['赛博']='赛博死骑:BAAAKgADCggICAAAAA==.',['赤瞳']='赤瞳丶:BAAAKgAFFAEIAQAAAA==.',['赵立']='赵立春:BAAAKgADCggIBQAAAA==.',['輕云']='輕云蔽月:BAABKgAECn8WAAIGAAcIuAymFADfAAAGAAcIuAymFADfAAAAAA==.',['轻歌']='轻歌月神:BAABKgAECn8aAAInAAgIlhPUEwBxAQAnAAgIlhPUEwBxAQAAAA==.',['轻程']='轻程:BAAAKgADCggIGAAAAA==.',['轻装']='轻装简萨:BAACKgAFFH8TAAIKAAQITSTgFgAnAQAKAAQITSTgFgAnAQAqAAQKfyAAAgoACAhvH2kWAEICAAoACAhvH2kWAEICAAEqAAUUBgghAAYAXSMA.轻装简行:BAAAKgAECggIDgABKgAFFAYIIQAGAF0jAA==.',['达克']='达克斯:BAAAKgAECgYIBgAAAA==.',['迪娜']='迪娜的耳朵:BAAAKgAECgMIAwAAAA==.',['迷人']='迷人的保险柜:BAACKgAFFH8VAAMNAAgIohhhBAA0AgANAAgIohhhBAA0AgAeAAYIMgkBGQA0AQAqAAQKfyIAAh4ACAhpGvZAAPUBAB4ACAhpGvZAAPUBAAAA.',['追风']='追风呆子:BAAAKgADCgUIBgAAAA==.',['逍遥']='逍遥汤圆:BAABKgAFFH8KAAMeAAUITxIzGgDqAAAeAAUITxIzGgDqAAANAAQIRglpFgCuAAAAAA==.',['逼兜']='逼兜由子:BAABKgAECn8bAAQPAAgIegzsZQAsAQAPAAgIegzsZQAsAQAOAAUIHBBCUADMAAAnAAEIYgX6OwANAAAAAA==.',['邪骑']='邪骑士之王:BAAAKgADCgIIAgAAAA==.',['释情']='释情:BAAAKgAECgQIAgAAAA==.',['野生']='野生小咕咕:BAAAKgAECgUICAAAAA==.',['钢铁']='钢铁老直男:BAACKgAFFH8PAAIMAAQI6R/cBQAaAQAMAAQI6R/cBQAaAQAqAAQKfzMAAgwACAgIJS4CAOICAAwACAgIJS4CAOICAAEqAAUUBQgVABoAohsA.',['铁北']='铁北十三太保:BAAAKgAFFAEIAQAAAA==.铁北喝到南关:BAAAKgAECgUIBQAAAA==.铁北酒蒙子:BAACKgAFFH8GAAIKAAIIzBH7IgCNAAAKAAIIzBH7IgCNAAAqAAQKfxsAAgoACAjpE/09AI4BAAoACAjpE/09AI4BAAAA.',['银河']='银河骑士:BAAAKgADCggICQAAAA==.',['锅炉']='锅炉工:BAAAKgAECgQIBQAAAA==.',['长得']='长得像人:BAAAKgAFFAQIBAAAAA==.',['阿佶']='阿佶:BAABKgAFFH8GAAIHAAQIDBrKFAAEAQAHAAQIDBrKFAAEAQAAAA==.',['阿卡']='阿卡回归了:BAAAKgAECgYIBgAAAA==.',['阿古']='阿古斯之心:BAABKgAFFH8IAAIHAAIIthn4cQCGAAAHAAIIthn4cQCGAAAAAA==.',['阿哩']='阿哩喜:BAABKgAFFH8IAAIIAAQIGybwBABMAQAIAAQIGybwBABMAQAAAA==.',['阿塔']='阿塔利娅:BAAAKgADCgQIBAAAAA==.',['阿奥']='阿奥呜丶丢:BAABKgAFFH8KAAMdAAQIIA/YGgCpAAAdAAQIIA/YGgCpAAABAAEICQpEKAA8AAAAAA==.',['阿曼']='阿曼:BAAAKgAECgQIBAAAAA==.',['陆仁']='陆仁贾:BAAAKgAECgUIBQAAAA==.',['陌小']='陌小独:BAAAKgADCgIIAgAAAA==.',['难熬']='难熬的夜夜:BAAAKgAFFAQIBAAAAA==.',['难过']='难过不要说:BAAAKgAECgMIAwAAAA==.',['雪域']='雪域晴空:BAAAKgAECgIIAgAAAA==.',['雪碧']='雪碧晶晶亮:BAAAKgAFFAIIAgAAAA==.',['雷霆']='雷霆浩荡:BAABKgAFFH8IAAIdAAQIEx2mBQAEAQAdAAQIEx2mBQAEAQAAAA==.',['雾尾']='雾尾词:BAAAKgAECgQIBAAAAA==.',['青阳']='青阳:BAABKgAFFH8GAAIeAAYIjBzcCwCyAQAeAAYIjBzcCwCyAQABKgAFFAgICAAeABcdAA==.',['须臾']='须臾芳华:BAAAKgAFFAQIBAAAAA==.',['顾逸']='顾逸:BAAAKgAFFAIIAgAAAA==.',['顿图']='顿图斯特:BAAAKgADCggICAAAAA==.',['颓废']='颓废囡囡:BAAAKgADCgEIAQAAAA==.',['風丶']='風丶:BAAAKgAECgYIBgAAAA==.',['風刀']='風刀霜劍:BAAAKgADCgMIAwAAAA==.',['风云']='风云煜:BAAAKgADCggICAAAAA==.',['风华']='风华依然:BAAAKgADCgIIAgAAAA==.风华霜年:BAAAKgADCgEIAQAAAA==.',['风吻']='风吻之歌:BAAAKgADCgYIBgAAAA==.',['风在']='风在凝思:BAABKgAECn8yAAQJAAgIZwaWIAC4AAAJAAgIZwaWIAC4AAAjAAcIggOqLgBkAAAEAAUIGQI7UQAzAAAAAA==.',['风斫']='风斫:BAAAKgAECgYIBgAAAA==.',['风过']='风过飘蓝:BAAAKgAFFAQIBAABKgAFFAgICAAKAO0XAA==.',['风雷']='风雷之羽:BAAAKgAFFAYIBAAAAA==.',['飞丶']='飞丶杨:BAACKgAFFH8iAAIEAAQIXyKACQD/AAAEAAQIXyKACQD/AAAqAAQKf0kAAwQACAgtJj4BAAkDAAQACAgtJj4BAAkDAAkAAQgGCFe5ACoAAAEqAAUUBQgVABoAohsA.',['飞花']='飞花如雪:BAAAKgAECgcIDgAAAA==.',['首席']='首席牛马官:BAAAKgAFFAIIAgAAAA==.',['香脆']='香脆奶油泡芙:BAAAKgAECgIIAgAAAA==.',['香菇']='香菇香菇:BAAAKgADCgEIAQAAAA==.',['骑德']='骑德龙咚强:BAABKgAFFH8GAAIHAAMIwgo5KwC6AAAHAAMIwgo5KwC6AAAAAA==.',['骑猪']='骑猪漫步:BAABKgAFFH8GAAINAAYI7gubHwD4AAANAAYI7gubHwD4AAABKgAFFAgIDQANAHkdAA==.',['鬽魅']='鬽魅魍魉:BAABKgAFFH8NAAMgAAUIBh43BAA1AQAgAAMIFCM3BAA1AQAUAAIIcBZONwCTAAAAAA==.',['魔王']='魔王鑫鑫:BAAAKgAECgMIAwAAAA==.',['魚十']='魚十柒丶:BAAAKgADCgUIBQAAAA==.',['鸣女']='鸣女:BAAAKgAECgQIBAAAAA==.',['鹿丶']='鹿丶:BAABKgAFFH8FAAIYAAUIuhtGCQBcAQAYAAUIuhtGCQBcAQAAAA==.',['鹿溪']='鹿溪:BAABKgAFFH8IAAMHAAgIrxt1LAA1AQAHAAQIbxx1LAA1AQAlAAQI7x1HCQAUAQAAAA==.',['黑人']='黑人上咬他:BAAAKgADCggICAAAAA==.',['黑手']='黑手:BAAAKgAECgQIBwAAAA==.',['黑暗']='黑暗丷森林:BAABKgAECn8bAAILAAgIkBwfJACtAQALAAgIkBwfJACtAQAAAA==.',['龖齉']='龖齉齾:BAAAKgADCgIIAgAAAA==.',['龙的']='龙的传人:BAAAKgADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end