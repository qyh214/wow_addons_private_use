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
 local lookup = {'Paladin-Protection','DeathKnight-Blood','DeathKnight-Frost','Shaman-Restoration','Hunter-BeastMastery','Mage-Arcane','Mage-Frost','Paladin-Retribution','Druid-Restoration','Druid-Balance','Warrior-Fury','Warrior-Protection','Priest-Shadow','Warlock-Destruction','Warlock-Demonology','Shaman-Elemental','Paladin-Holy','DemonHunter-Havoc','Mage-Fire','Hunter-Marksmanship','Hunter-Survival','DemonHunter-Vengeance','Monk-Mistweaver','DeathKnight-Unholy','Priest-Holy','Rogue-Assassination','Rogue-Subtlety','Evoker-Preservation','Monk-Brewmaster','Evoker-Devastation',}; local provider = {region='CN',realm='阿迦玛甘',name='CN',type='weekly',zone=44,date='2025-12-09',data={Ai='Aimbot:BAAALAAECgYICQAAAA==.Airage:BAAALAADCgcIBwAAAA==.',Al='Alexce:BAAALAAFFAIIBAAAAA==.',Ao='Aoeiuü:BAACLAAFFH8IAAIBAAIINhcMEQCSAAABAAIINhcMEQCSAAAsAAQKfxgAAgEABghQIFYbABwCAAEABghQIFYbABwCAAAA.',Ar='Aragornn:BAABLAAFFH8QAAMCAAYIERDTDQAvAQACAAYIGwzTDQAvAQADAAIIAhitWgCbAAAAAA==.Arams:BAAALAADCgYIAwAAAA==.',Br='Brainless:BAAALAAECgYIBgAAAA==.',Ce='Celtics:BAAALAAECgYICwAAAA==.',Ch='Chinesepanda:BAAALAADCgcICgAAAA==.',Cm='Cms:BAABLAAFFH8OAAIEAAQIPSPpGwCAAQAEAAQIPSPpGwCAAQAAAA==.',Co='Constantiin:BAABLAAFFH8PAAIFAAYI1h+QUgAMAQAFAAYI1h+QUgAMAQAAAA==.Constantinee:BAABLAAFFH8MAAIGAAIIfgdBYAA8AAAGAAIIfgdBYAA8AAABLAAFFAgICAAHAGwEAA==.Constantinne:BAABLAAFFH8MAAIIAAYIACKDCAAIAgAIAAYIACKDCAAIAgAAAA==.',Cr='Crissangel:BAAALAAECgQIDAAAAA==.',Da='Daeneryst:BAAALAAECgMIAwAAAA==.',De='Demonbringer:BAAALAAECgEIAQAAAA==.',Es='Espeon:BAAALAAECgIIAgAAAA==.',Fi='Firefly:BAAALAAFFAYIAgAAAA==.',Fr='Freedruid:BAACLAAFFH8cAAMJAAYIth1rCwAAAgAJAAYIth1rCwAAAgAKAAMIGgk+KgBpAAAsAAQKfxsAAgkACAhQHU4OAHMCAAkACAhQHU4OAHMCAAAA.',Go='Goodperson:BAAALAADCgEIAQAAAA==.Goodwoman:BAAALAAECgYIBgAAAA==.',['Gó']='Gódiva:BAACLAAFFH8RAAMLAAUIYRe5IgBcAQALAAUIYRe5IgBcAQAMAAII2BcnJgBSAAAsAAQKfxUAAwwABgjBGFkqAAIBAAsABgg6F+uoADEBAAwAAwjKHVkqAAIBAAAA.',Ha='Haibara:BAAALAAECgYIDgAAAA==.',Ho='Hongchen:BAAALAADCgMIAwAAAA==.',Hy='Hydruid:BAAALAAECgYICQABLAAFFAYIMQAHADgaAA==.',Ir='Irina:BAAALAAECgIIAgAAAA==.',Ko='Kotema:BAAALAADCgcIBwAAAA==.',Ku='Kumo:BAABLAAFFH8LAAIDAAgIziL7BAC3AgADAAgIziL7BAC3AgAAAA==.',Le='Leander:BAAALAAECgUIBQAAAA==.',Li='Littlepetal:BAAALAAECgYICQAAAA==.',Lo='Longbow:BAAALAAECgYICgAAAA==.',Ma='Maifa:BAACLAAFFH8RAAMMAAIIjRC1JgBxAAAMAAIIjRC1JgBxAAALAAEIkgB2VgAVAAAsAAQKfzUAAwwABggKGr8gAEEBAAwABggKGr8gAEEBAAsABgjDBgXAAPsAAAAA.Makaria:BAABLAAFFH8KAAMDAAUIGBKpPwBCAQADAAUIGBKpPwBCAQACAAIIygmkHwAkAAAAAA==.Mandy:BAAALAAECgUIBwAAAA==.',Me='Meya:BAAALAAECgQIBAAAAA==.',Mi='Mikey:BAAALAAFFAIIAwAAAA==.',Mo='Molind:BAAALAAECgYICAAAAA==.',Na='Nagrand:BAAALAAECgUIBQAAAA==.',Ph='Phxsuns:BAAALAAECgYIDAAAAA==.',Pr='Priteardrop:BAAALAAECggIAgABLAAFFAgICgAEAO4aAA==.Promises:BAAALAAECgYIBgAAAA==.',Ry='Ryanchu:BAAALAADCgEIAQAAAA==.',Sa='Savowo:BAABLAAFFH8FAAIIAAUIjRDtKwAqAQAIAAUIjRDtKwAqAQAAAA==.',Se='Seraphim:BAABLAAECn8XAAINAAYIaxSpRwCZAQANAAYIaxSpRwCZAQAAAA==.',Sm='Smoggy:BAAALAAECgQIBQAAAA==.',So='Solitaire:BAAALAAFFAIIBAAAAA==.',Ti='Timeless:BAABLAAECn8cAAMOAAgIhw/2QABHAQAOAAgIpw72QABHAQAPAAcIVQY3UAAzAQAAAA==.',Vv='Vvind:BAABLAAFFH8cAAMJAAYINw9lIwAGAQAJAAUINQ9lIwAGAQAKAAUIKxH2GgADAQAAAA==.',['一乐']='一乐逍遥一:BAAALAAECgIIAgAAAA==.',['一只']='一只邪恶熊猫:BAAALAAECgQIBgAAAA==.',['一羽']='一羽雪一:BAABLAAFFH8KAAILAAIIER7xKwCjAAALAAIIER7xKwCjAAAAAA==.',['下巴']='下巴奶:BAAALAAECgYIBgAAAA==.',['不要']='不要总撩妹:BAAALAAFFAIIAgAAAA==.',['两眼']='两眼一抹黑:BAAALAAECgUIBgAAAA==.',['丨三']='丨三十度丨:BAAALAAECgYICAAAAA==.',['丶旺']='丶旺旺雪饼:BAAALAAFFAYIAgAAAA==.',['么么']='么么零:BAAALAAECgQIBQAAAA==.',['乛釖']='乛釖閊:BAABLAAFFH8JAAIMAAYI3gckGADwAAAMAAYI3gckGADwAAAAAA==.',['九天']='九天普化天尊:BAAALAAFFAIIAgAAAA==.',['二師']='二師兄:BAAALAADCgYIBgAAAA==.',['五十']='五十已到:BAAALAAFFAIIBAAAAA==.',['五香']='五香可达鸭:BAAALAADCgIIAgAAAA==.',['亚凯']='亚凯:BAABLAAECn8WAAIIAAYIFhHacQAgAQAIAAYIFhHacQAgAQAAAA==.',['亡者']='亡者之墙:BAAALAAECgcIDAAAAA==.',['人间']='人间小美味:BAAALAAFFAMIAwAAAA==.',['低头']='低头想你:BAAALAADCgEIAQAAAA==.',['何苦']='何苦上青天:BAAALAAECgYICwAAAA==.',['你这']='你这个小傻瓜:BAABLAAFFH8MAAIIAAUIgBAeMwDzAAAIAAUIgBAeMwDzAAAAAA==.',['保安']='保安红薯:BAAALAAECgMIAwAAAA==.',['信仰']='信仰:BAAALAAECgcICQAAAA==.',['倾尐']='倾尐:BAAALAADCgMIAwAAAA==.',['假死']='假死灬小演:BAAALAADCggICAAAAA==.',['八目']='八目:BAABLAAFFH8GAAIGAAIInRYjRgCaAAAGAAIInRYjRgCaAAAAAA==.',['养个']='养个死个:BAAALAAECgQIBAAAAA==.',['冰释']='冰释之尘:BAAALAAECgYIBgAAAA==.',['冲锋']='冲锋灬小演:BAAALAAECgcIEQAAAA==.',['冷月']='冷月强哥:BAAALAADCgIIAgAAAA==.',['凡心']='凡心:BAAALAADCgYIBgAAAA==.',['别扒']='别扒拉我:BAAALAAECgIIAgAAAA==.',['剑舞']='剑舞悲风:BAABLAAFFH8GAAIIAAQIHQfIOQC9AAAIAAQIHQfIOQC9AAAAAA==.',['剑过']='剑过流光:BAAALAAECgYIBgAAAA==.',['加特']='加特林:BAAALAADCgIIAgAAAA==.',['动态']='动态丶:BAAALAAECgcIBwAAAA==.',['十月']='十月夭夭:BAAALAADCgYIBgAAAA==.',['华魔']='华魔英雄:BAAALAAECgEIAQAAAA==.',['南蛇']='南蛇藤:BAAALAAECgYIBgAAAA==.',['印第']='印第安纳:BAAALAADCgQIBAAAAA==.',['变身']='变身灬小演:BAAALAADCgcICAAAAA==.',['叶知']='叶知秋色:BAAALAAECgQIBAAAAA==.',['吱吱']='吱吱:BAAALAADCgYIBgAAAA==.',['唔西']='唔西迪西丶:BAAALAAECgYIBgAAAA==.',['唯壹']='唯壹一天天:BAAALAAECggIDwAAAA==.',['啧啧']='啧啧你好香:BAAALAAECgEIAgAAAA==.',['嗜血']='嗜血天下:BAAALAAECgYIBgAAAA==.',['噬影']='噬影:BAAALAADCgIIAgAAAA==.',['噬渊']='噬渊:BAAALAAFFAIIBAAAAA==.',['噬血']='噬血魔鬼:BAAALAADCgEIAQAAAA==.',['四十']='四十多个萨满:BAABLAAFFH8oAAMQAAYIoxgBFgCQAQAQAAYIoxgBFgCQAQAEAAUIExZLIgDFAAAAAA==.',['四枫']='四枫院里奇奥:BAAALAAECgcIDQAAAA==.',['回忆']='回忆杀灬我:BAAALAAECgYIBgAAAA==.',['图艾']='图艾內万:BAAALAAECgIIAgAAAA==.图艾内万:BAAALAAECgYICgAAAA==.',['圣光']='圣光之主:BAACLAAFFH8LAAQRAAMIlA+DHwCpAAARAAMIlA+DHwCpAAABAAIIbw2HGgBxAAAIAAIIRR6HVgBMAAAsAAQKfx0ABAgABwh+Ih8XAFgCAAgABwh+Ih8XAFgCAAEABgg+F1IZAEsBABEABgiJCDJaAOcAAAAA.圣光催逝员:BAAALAAECgYIEQAAAA==.',['圣艾']='圣艾尔摩之火:BAAALAAECgYIBgAAAA==.',['地獄']='地獄霸王丸:BAACLAAFFH8FAAMIAAMIMAp7aABCAAAIAAIIog17aABCAAABAAEITAPtIQAoAAAsAAQKfxYAAwgACAj2FsVdADACAAgACAj2FsVdADACAAEAAgiSBUt4ADIAAAAA.',['埃塞']='埃塞尔弗莱德:BAAALAAFFAIIAgAAAA==.',['堕落']='堕落的激昂:BAAALAAECgYIDgAAAA==.',['墓碑']='墓碑有名:BAAALAADCgcIBwAAAA==.',['墨月']='墨月丶:BAAALAAFFAIIAgAAAA==.',['夜星']='夜星魂:BAAALAADCgEIAQAAAA==.',['夜色']='夜色染清晨:BAAALAADCgYIBgAAAA==.',['夜骐']='夜骐:BAAALAAECgQIBAAAAA==.',['大将']='大将军:BAAALAAECgYIBgAAAA==.',['大漠']='大漠孤烟:BAAALAADCgYIBgAAAA==.',['大玉']='大玉儿:BAAALAAECgQIBAAAAA==.',['大锤']='大锤丨八十:BAABLAAFFH8JAAIIAAYINx7GAgBOAgAIAAYINx7GAgBOAgAAAA==.',['天台']='天台吹风:BAAALAADCgEIAgAAAA==.',['天命']='天命难违:BAABLAAFFH8IAAIFAAIIUANCvgAtAAAFAAIIUANCvgAtAAAAAA==.',['天蓝']='天蓝蓝:BAACLAAFFH8gAAIOAAcIkBldFADrAQAOAAcIkBldFADrAQAsAAQKfxwAAg4ACAhJHPUUADsCAA4ACAhJHPUUADsCAAAA.',['天边']='天边一抹白:BAAALAADCgQIBAAAAA==.',['天马']='天马流星拳:BAAALAAFFAIIAgAAAA==.',['天鹅']='天鹅绒丶:BAAALAAECgIIAgAAAA==.',['夭夭']='夭夭:BAACLAAFFH8FAAIFAAIIhBCbqAA8AAAFAAIIhBCbqAA8AAAsAAQKfyIAAgUABgjpHKVRAKMBAAUABgjpHKVRAKMBAAAA.',['夹饼']='夹饼不要辣椒:BAABLAAFFH8GAAISAAIIxAz0YQA+AAASAAIIxAz0YQA+AAAAAA==.',['女警']='女警:BAACLAAFFH8GAAIFAAIISA31nwA/AAAFAAIISA31nwA/AAAsAAQKfxkAAgUABgg2HglNAK4BAAUABgg2HglNAK4BAAAA.',['奶凶']='奶凶:BAAALAADCgIIAgAAAA==.',['妖孽']='妖孽般的崛起:BAAALAAECgYIDAAAAA==.',['妖目']='妖目:BAAALAAFFAIIBAAAAA==.',['完美']='完美主角:BAAALAADCgcIBwAAAA==.',['寂沫']='寂沫:BAAALAAFFAIIAgAAAA==.',['寒糖']='寒糖:BAAALAAECgUIBQAAAA==.',['寻找']='寻找传说神器:BAAALAAFFAIIAgAAAA==.',['小新']='小新:BAAALAAECgYIBgAAAA==.',['小演']='小演灬冲锋:BAAALAAECgUIBQAAAA==.',['小红']='小红薯:BAABLAAFFH8IAAIDAAII4BhGUQCgAAADAAII4BhGUQCgAAAAAA==.',['小胖']='小胖豆:BAAALAADCgUIBQAAAA==.',['小阿']='小阿福:BAAALAADCgQIBAAAAA==.',['小飞']='小飞棍:BAAALAAFFAIIAgAAAA==.',['小鹿']='小鹿鹿:BAAALAAECgYIBgAAAA==.',['山河']='山河映东旭:BAAALAAFFAIIAgAAAA==.',['岚妍']='岚妍:BAABLAAFFH8GAAISAAYIPSFyDwDrAQASAAYIPSFyDwDrAQAAAA==.',['峨眉']='峨眉峰:BAAALAAECgYICwAAAA==.',['巨龙']='巨龙风暴:BAAALAADCgYIBgAAAA==.',['希格']='希格雯:BAAALAAECgQIBAAAAA==.',['希诺']='希诺宁:BAAALAAECgQIBwAAAA==.',['干将']='干将墨玄:BAAALAAECgYIDAABLAAFFAYIJgASAAocAA==.干将墨邪:BAABLAAECn8ZAAQHAAcIOxupFACMAQAHAAYIWxupFACMAQATAAYI7BJrBwBEAQAGAAEIVggseAArAAABLAAFFAYIJgASAAocAA==.干将尐墨:BAACLAAFFH8WAAMFAAMI0xPEbwCHAAAFAAMI0xPEbwCHAAAUAAIIFwX7LgBlAAAsAAQKfyQAAwUACAhtHi8dAFACAAUACAjUHS8dAFACABQABgjMF9dXAFkBAAEsAAUUBggmABIAChwA.',['干锅']='干锅胖头驴:BAAALAAECgMIAwAAAA==.',['弑神']='弑神乄归来:BAAALAAECgYICAAAAA==.',['弓月']='弓月:BAACLAAFFH8NAAMVAAQIYg9iAwCoAAAVAAIIchpiAwCoAAAFAAQIrQp2ZwChAAAsAAQKfxYAAwUACAgzGlmeAK4BAAUABwgAHFmeAK4BABUAAgj/Cs8gAHUAAAAA.',['往后']='往后余生:BAABLAAFFH8cAAMJAAYI7x1nCwAAAgAJAAYI7x1nCwAAAgAKAAQIOxPbHwDIAAAAAA==.',['很多']='很多鱼:BAAALAADCgQIBAAAAA==.',['從不']='從不後悔:BAAALAAECgMIAwAAAA==.',['徳刑']='徳刑天下:BAAALAAECgUIBQAAAA==.',['忆清']='忆清晨:BAAALAAECgYICQAAAA==.',['忧郁']='忧郁奶黄包:BAAALAADCggICAAAAA==.',['快乐']='快乐的单身汉:BAAALAAECgYICAAAAA==.',['快去']='快去打豆豆:BAAALAAFFAIIAgAAAA==.',['快叫']='快叫我小可爱:BAAALAAFFAIIAgAAAA==.',['快睡']='快睡觉觉:BAABLAAECn8gAAIDAAgIRhYdYwAwAgADAAgIRhYdYwAwAgAAAA==.',['怎么']='怎么老是你:BAAALAADCgQIBAAAAA==.',['怒烽']='怒烽天下:BAAALAAECgYIBgAAAA==.',['思睿']='思睿:BAAALAADCgQIBAAAAA==.',['惡靈']='惡靈騎士:BAAALAAECgYIEwAAAA==.',['惩戒']='惩戒天下:BAAALAAECgUIBQAAAA==.',['愚者']='愚者:BAAALAAECgYIBgAAAA==.',['戈登']='戈登有名的:BAABLAAFFH8IAAIMAAIIdxXcKwA6AAAMAAIIdxXcKwA6AAAAAA==.戈登盲盲:BAABLAAFFH8IAAIWAAIIshDyEwAzAAAWAAIIshDyEwAzAAAAAA==.戈登貂蝉:BAACLAAFFH8KAAIEAAIIZBmxSACPAAAEAAIIZBmxSACPAAAsAAQKfxYAAgQACAihHnlJAAMCAAQACAihHnlJAAMCAAAA.戈登费小曼:BAABLAAFFH8LAAIXAAIIFBYzFACAAAAXAAIIFBYzFACAAAAAAA==.戈登阿喀琉斯:BAAALAAFFAIIBAAAAA==.戈登雅典娜:BAABLAAFFH8IAAMBAAIIBh+tFABSAAABAAIICxutFABSAAAIAAIIZheTaABCAAAAAA==.',['我叫']='我叫不高兴:BAAALAADCggIEgAAAA==.',['我感']='我感觉很难瘦:BAAALAAECgUIBwAAAA==.',['我算']='我算开了眼了:BAABLAAFFH8nAAMBAAYIXR2RBAClAQABAAYIXR2RBAClAQARAAEIzx2JLQBUAAAAAA==.',['我靓']='我靓我不拽:BAAALAADCgUIBQAAAA==.',['战场']='战场大元帅:BAAALAAECgYIBgAAAA==.',['探姬']='探姬:BAAALAAECgcIEQAAAA==.',['撕捩']='撕捩厄勐:BAAALAADCgQIBAAAAA==.',['斯道']='斯道普:BAAALAAECgUICQAAAA==.',['时光']='时光倒流:BAAALAAECgEIAQAAAA==.',['旺旺']='旺旺雪饼丶:BAABLAAFFH8IAAILAAYI5yLMAQCVAgALAAYI5yLMAQCVAgAAAA==.',['明写']='明写春诗丶:BAABLAAFFH8OAAIOAAMIihK/PACbAAAOAAMIihK/PACbAAAAAA==.',['明月']='明月昭昭:BAABLAAECn8aAAIIAAgISyMDEgAxAwAIAAgISyMDEgAxAwAAAA==.',['易安']='易安居士:BAAALAAECgMIAwAAAA==.',['星屑']='星屑:BAAALAAECgYICgAAAA==.',['星月']='星月菩提:BAAALAADCgcIBwAAAA==.',['星辰']='星辰紫玥:BAAALAAFFAEIAQAAAA==.',['春風']='春風十里:BAAALAAECgYIBwAAAA==.',['晒干']='晒干的小霏霏:BAAALAAECggICAAAAA==.',['晟死']='晟死骑:BAAALAAFFAEIAQAAAA==.',['暗炉']='暗炉议会:BAAALAADCgUIBQAAAA==.',['月影']='月影追猎者:BAAALAADCgYIBgAAAA==.',['月梦']='月梦儿:BAAALAADCgUIBQAAAA==.',['朴灬']='朴灬一宿:BAAALAAFFAIIAgAAAA==.朴灬人王:BAABLAAFFH8NAAIJAAIILRS2PwB2AAAJAAIILRS2PwB2AAAAAA==.',['李三']='李三青:BAAALAADCgEIAQAAAA==.',['来杯']='来杯酒:BAAALAADCgYIBgAAAA==.',['杰兰']='杰兰特:BAAALAAFFAIIAgAAAA==.',['松树']='松树恶霸:BAABLAAFFH8GAAIFAAIIFBICaACGAAAFAAIIFBICaACGAAAAAA==.',['某夜']='某夜丶某街:BAAALAAECgYIBgAAAA==.',['梦中']='梦中残蝶:BAAALAAECgUIBwAAAA==.',['梦见']='梦见月瑞希:BAAALAAECgYIDQAAAA==.',['樱释']='樱释:BAAALAAFFAMIAwAAAA==.',['橙孑']='橙孑骑士:BAABLAAFFH8HAAIIAAMI9B6WOwCvAAAIAAMI9B6WOwCvAAAAAA==.',['欧洲']='欧洲大酋长丶:BAAALAAECgYICAAAAA==.',['武媚']='武媚娘:BAAALAAFFAIIBAAAAA==.',['死临']='死临天下:BAAALAAECgIIAgAAAA==.',['水漾']='水漾涟漪:BAABLAAFFH8KAAIYAAII6SPDCgC/AAAYAAII6SPDCgC/AAAAAA==.',['氵涟']='氵涟漪:BAAALAADCgIIAwAAAA==.',['永恒']='永恒羽翼:BAAALAADCgEIAQAAAA==.',['永远']='永远相信光:BAAALAAECgcIBwAAAA==.',['沙德']='沙德沃克:BAAALAAFFAIIAgAAAA==.',['没那']='没那麽简单:BAAALAADCgYIBgAAAA==.',['油腻']='油腻大爷:BAAALAADCgUIBQAAAA==.',['洒洒']='洒洒水啦:BAABLAAFFH8HAAIEAAMIABFzSACPAAAEAAMIABFzSACPAAAAAA==.',['洛水']='洛水之北:BAAALAAECgYIBgAAAA==.',['浅笑']='浅笑丶轻吟:BAABLAAFFH8OAAISAAIIRRnDVQBGAAASAAIIRRnDVQBGAAAAAA==.',['涅槃']='涅槃丶尤文:BAAALAAFFAIIAgAAAA==.',['溯洄']='溯洄水之湄:BAACLAAFFH8RAAMSAAYI1AYsMQAVAQASAAYI1AYsMQAVAQAWAAIIiQSRGAAlAAAsAAQKfyMAAhIACAjoFxVGAE8CABIACAjoFxVGAE8CAAAA.',['火焰']='火焰紋章:BAACLAAFFH8oAAIOAAYIDBHSGACLAQAOAAYIDBHSGACLAQAsAAQKfykAAg4ACAhQHUEoAKMCAA4ACAhQHUEoAKMCAAAA.',['炎魔']='炎魔堂葫芦:BAAALAAECgYIBgAAAA==.',['烈之']='烈之怒疯:BAAALAAFFAIIAgAAAA==.',['熔岩']='熔岩巧克力:BAAALAAFFAIIAgAAAA==.',['爆炒']='爆炒傻兔子:BAAALAAECgYIBgAAAA==.',['爱到']='爱到你想逃:BAABLAAECn8XAAMIAAYIlhl1SwB9AQAIAAYIlhl1SwB9AQARAAYIoQeVVgD4AAAAAA==.',['爻叶']='爻叶:BAAALAADCgUIBQAAAA==.',['狼族']='狼族絕影:BAAALAAFFAIIAgAAAA==.',['狼魂']='狼魂:BAACLAAFFH8OAAIEAAMIOhmvPQCwAAAEAAMIOhmvPQCwAAAsAAQKfxcAAgQACAhtGAxBABsCAAQACAhtGAxBABsCAAAA.',['猎之']='猎之魄:BAAALAADCggICgAAAA==.',['猛字']='猛字贴胸口:BAAALAAECgYIDgAAAA==.',['猫妞']='猫妞儿:BAAALAAECgYICQAAAA==.',['玛拉']='玛拉妮:BAAALAAECgYICQAAAA==.',['玛薇']='玛薇卡:BAAALAAECgQIBwAAAA==.',['班克']='班克木:BAAALAAECgYIBgAAAA==.',['疯狂']='疯狂的巨人:BAAALAADCgEIAQAAAA==.',['瞅你']='瞅你咋地:BAAALAADCgIIAgAAAA==.',['短暂']='短暂的生涯:BAAALAAECggICAAAAA==.',['砍崽']='砍崽:BAAALAADCgcICQAAAA==.',['碎星']='碎星辰:BAAALAADCgcIBwAAAA==.',['神圣']='神圣的光:BAAALAADCgMIAwAAAA==.',['神里']='神里绫华:BAAALAAECgYIBgAAAA==.',['祢豆']='祢豆子:BAAALAAECgYIEgAAAA==.',['穷寇']='穷寇莫追:BAAALAAECgcIBwAAAA==.',['第九']='第九天堂:BAAALAAECgMIBgAAAA==.',['簌簌']='簌簌微风:BAACLAAFFH8IAAISAAIIhBnSMgClAAASAAIIhBnSMgClAAAsAAQKfyYAAhIACAiPGblAAGACABIACAiPGblAAGACAAAA.',['系俾']='系俾你:BAABLAAFFH8IAAIMAAIIoAsSJQB0AAAMAAIIoAsSJQB0AAAAAA==.',['紅皮']='紅皮體育生:BAAALAAECgEIAQAAAA==.',['红鲤']='红鲤鱼:BAAALAAECgMIAwAAAA==.',['纳川']='纳川:BAAALAAFFAIIBAAAAA==.',['纳西']='纳西妲:BAAALAAECgYICwAAAA==.',['纸包']='纸包鱼:BAAALAAECggIEwAAAA==.',['细雨']='细雨满川:BAAALAAECgYIBgAAAA==.',['终不']='终不似:BAAALAADCgcICQAAAA==.',['缇绫']='缇绫:BAABLAAFFH8KAAMPAAUIkxVUAwAbAQAPAAQICxlUAwAbAQAOAAMI+gesRgC1AAAAAA==.',['翻仓']='翻仓之王:BAAALAADCgIIAgAAAA==.',['老汉']='老汉使劲奶:BAAALAAECgYIBgAAAA==.',['职业']='职业玩家功夫:BAAALAADCgIIAgAAAA==.职业玩家审判:BAAALAADCgYIBgAAAA==.职业玩家浩劫:BAAALAADCgYIBwAAAA==.职业玩家绽放:BAAALAADCgMIBAAAAA==.',['職業']='職業丨漩嵂:BAAALAAECggICgAAAA==.',['肆拾']='肆拾伍喵:BAAALAAFFAIIBAAAAA==.',['胜利']='胜利冲锋:BAAALAAECgYIDAAAAA==.',['胡胡']='胡胡的战式:BAAALAAECgIIAgAAAA==.',['胧幻']='胧幻月:BAABLAAECn8cAAIJAAgISxZ3LQAsAgAJAAgISxZ3LQAsAgABLAAECggIHAAFAIUbAA==.',['脆柿']='脆柿子:BAAALAAECgQICAAAAA==.',['腊味']='腊味丶煲仔饭:BAABLAAFFH8JAAMZAAIIpgF3TABNAAAZAAIIpgF3TABNAAANAAEIzAQeMQAyAAAAAA==.',['自娱']='自娱自乐:BAAALAAECgMIAwAAAA==.',['芒果']='芒果蹄蹄:BAABLAAFFH8UAAIMAAgIJRueAwAuAgAMAAgIJRueAwAuAgAAAA==.',['花下']='花下晒爪子:BAAALAAFFAQIBAAAAA==.',['花无']='花无霜:BAAALAADCgQIBAAAAA==.',['花落']='花落灬莫相离:BAABLAAFFH8KAAIFAAMI5xxDOgCvAAAFAAMI5xxDOgCvAAAAAA==.',['莜茗']='莜茗翾:BAABLAAFFH8JAAIFAAUIJBHuTQAcAQAFAAUIJBHuTQAcAQAAAA==.',['莫问']='莫问归处:BAABLAAFFH8FAAMaAAIIeBYiFwCiAAAaAAIIShAiFwCiAAAbAAEI5Bl5HgA8AAAAAA==.',['萌面']='萌面大盗:BAABLAAECn8YAAIDAAYI4R/nZQAqAgADAAYI4R/nZQAqAgAAAA==.',['虚影']='虚影之殇:BAAALAAECgcIBgAAAA==.',['蜜糖']='蜜糖裹枇霜:BAABLAAFFH8SAAMUAAUIXBI7DADEAAAFAAUIFRHtVAADAQAUAAQIKhA7DADEAAABLAAFFAgIUgAcADMlAA==.',['血染']='血染尘羽:BAABLAAFFH8PAAISAAgICB3zBACcAgASAAgICB3zBACcAgAAAA==.',['謎魜']='謎魜灬曉饕餮:BAAALAAECgIIAgAAAA==.',['赤影']='赤影:BAAALAAECggICQAAAA==.',['軖嘨']='軖嘨兲:BAAALAAFFAMIAwAAAA==.',['轻车']='轻车熟路:BAABLAAFFH8FAAIFAAUI1xaWSQAsAQAFAAUI1xaWSQAsAQAAAA==.',['逆天']='逆天行道:BAAALAAECgYIBgAAAA==.',['逍遥']='逍遥纵横:BAABLAAFFH8OAAIFAAIIKRFQmwBBAAAFAAIIKRFQmwBBAAAAAA==.',['逝水']='逝水千桦:BAAALAAECgYIBgAAAA==.逝水流云:BAAALAAECgQIBAAAAA==.',['邪恶']='邪恶萝卜:BAABLAAFFH8GAAIdAAIImBDBHwA2AAAdAAIImBDBHwA2AAAAAA==.',['邱小']='邱小北:BAABLAAFFH8FAAIOAAUIrxa0OgAiAQAOAAUIrxa0OgAiAQAAAA==.',['郝卷']='郝卷:BAAALAAECgYIDwAAAA==.',['酸辣']='酸辣呆头鹅:BAAALAAECgUIBQAAAA==.',['醉后']='醉后的三哥:BAAALAAECgQIBAAAAA==.',['錒爾']='錒爾灬薩斯:BAAALAAECgUIBQAAAA==.',['錦瑟']='錦瑟無聲:BAABLAAFFH8GAAIDAAYIhwH/awBpAAADAAYIhwH/awBpAAAAAA==.',['长眠']='长眠不醒:BAAALAAFFAIIAgAAAA==.',['闪电']='闪电红薯:BAABLAAFFH8IAAIQAAIIjgzpLgCLAAAQAAIIjgzpLgCLAAAAAA==.',['闪耀']='闪耀的欧洲人:BAAALAAECgYICQAAAA==.',['闷葫']='闷葫芦:BAAALAAFFAIIAwAAAA==.',['阳光']='阳光漫天:BAAALAADCggICwAAAA==.',['阿凡']='阿凡达再临:BAAALAADCgIIAgAAAA==.',['雨丨']='雨丨丨夜:BAAALAADCgUIBQAAAA==.',['雨丶']='雨丶夜:BAAALAADCgYICwAAAA==.',['雨夜']='雨夜:BAAALAADCgMIAwAAAA==.',['雪丶']='雪丶恋:BAABLAAFFH8dAAIEAAUIwxu+GgCKAQAEAAUIwxu+GgCKAQAAAA==.',['雪地']='雪地的蚂蚱:BAAALAAECgYIDgAAAA==.',['雪香']='雪香凝树:BAAALAAECgIIBQAAAA==.',['雾里']='雾里看飞:BAAALAAFFAMIAwAAAA==.',['霜凛']='霜凛月:BAABLAAECn8cAAMFAAgIhRtJRQBZAgAFAAgIhRtJRQBZAgAUAAYINQz5cQAGAQAAAA==.',['青红']='青红皂了个白:BAACLAAFFH8dAAIeAAYI6RP+CwBkAQAeAAYI6RP+CwBkAQAsAAQKfzUAAh4ACAjRHdYTAJECAB4ACAjRHdYTAJECAAEsAAUUCAhSABwAMyUA.',['青龙']='青龙卧墨池:BAAALAAFFAIIAwAAAA==.',['静水']='静水无风:BAAALAAECgYIDwAAAA==.',['静都']='静都:BAABLAAFFH8IAAMSAAQI/Q9YNQDkAAASAAQIYg9YNQDkAAAWAAIIKgvcFwAnAAAAAA==.',['静默']='静默之声:BAAALAAECgcICQAAAA==.',['风云']='风云向北风:BAABLAAFFH8QAAIIAAgIoB6AAgCYAgAIAAgIoB6AAgCYAgAAAA==.',['风行']='风行者飘渺:BAAALAAECgYIBgAAAA==.',['风雨']='风雨潇湘:BAAALAAECgQIBAAAAA==.风雨雪霜:BAAALAADCgYIBgAAAA==.',['飘血']='飘血玫瑰:BAAALAADCgUIBQAAAA==.',['飘雪']='飘雪的海面:BAABLAAFFH8HAAIIAAQIQApjQwCOAAAIAAQIQApjQwCOAAAAAA==.',['食蛇']='食蛇者:BAAALAAECgEIAQAAAA==.',['香菜']='香菜丫:BAACLAAFFH8LAAMDAAQIJhdoUADnAAADAAQIJhdoUADnAAAYAAII0w4iEwCNAAAsAAQKfx4AAxgACAhPIMELAJYCABgACAjwHsELAJYCAAMABQhAH7WfAMcBAAAA.',['马尼']='马尼戈特:BAACLAAFFH8NAAIDAAMI9wm/ZwB+AAADAAMI9wm/ZwB+AAAsAAQKfyUAAgMABwh2ElE/AIYBAAMABwh2ElE/AIYBAAAA.',['魂念']='魂念:BAAALAAECgQIBAAAAA==.',['魅语']='魅语:BAABLAAFFH8IAAIFAAQIhx08TgAbAQAFAAQIhx08TgAbAQAAAA==.',['黎明']='黎明拂晓破晓:BAAALAADCgIIAgAAAA==.',['黑暗']='黑暗的神父:BAAALAAFFAIIAgAAAA==.',['黑珍']='黑珍珠的复仇:BAAALAAFFAIIBAAAAA==.',['龍胆']='龍胆紫:BAAALAADCgQIBAAAAA==.',['龙吸']='龙吸雪花:BAAALAADCgYIBgAAAA==.',['龙葵']='龙葵乱舞:BAABLAAFFH8IAAISAAII8hfhTgBLAAASAAII8hfhTgBLAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end