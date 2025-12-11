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
 local lookup = {'Hunter-BeastMastery','DeathKnight-Frost','Druid-Restoration','Druid-Balance','Hunter-Marksmanship','Warrior-Fury','DeathKnight-Unholy','DeathKnight-Blood','Mage-Arcane','Mage-Frost','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','Warrior-Protection','Evoker-Devastation','Warlock-Destruction','Monk-Windwalker','Rogue-Subtlety','Warlock-Demonology','DemonHunter-Havoc','DemonHunter-Vengeance','Paladin-Retribution','Rogue-Outlaw','Priest-Shadow','Paladin-Protection','Priest-Holy','Priest-Discipline','Rogue-Assassination','Paladin-Holy','Evoker-Preservation','Evoker-Augmentation','Druid-Feral','Hunter-Survival','Warlock-Affliction',}; local provider = {region='CN',realm='厄祖玛特',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alpharius:BAABLAAFFH8GAAIBAAYIVBSCCgDoAQABAAYIVBSCCgDoAQAAAA==.',Ar='Arcane:BAAALAADCgIIAgAAAA==.',Av='Averl:BAAALAAFFAIIAgAAAA==.',Ba='Balmain:BAAALAAECgQIBAAAAA==.',Bl='Bloodrose:BAABLAAFFH8IAAICAAIInRNXbACSAAACAAIInRNXbACSAAAAAA==.',Bo='Bottega:BAAALAAFFAIIBAAAAA==.',Ch='Chanel:BAABLAAFFH8kAAMDAAYIphmZEQCzAQADAAYIphmZEQCzAQAEAAIImgMOPAAwAAAAAA==.Choochoo:BAAALAAECgEIAQAAAA==.',De='Deleted:BAAALAAFFAIIBAAAAA==.',Do='Dotle:BAAALAADCgEIAQAAAA==.',El='Eliot:BAAALAAECgYIDAAAAA==.',Eu='Eurek:BAAALAAECggIEQAAAA==.',Ev='Everpromise:BAAALAADCggICAAAAA==.',Ez='Ezjuice:BAABLAAECn8aAAICAAYI9SFzYgAxAgACAAYI9SFzYgAxAgAAAA==.',Fi='Firstbleedin:BAABLAAFFH8JAAMDAAYIKhI5CwBLAQADAAUIChU5CwBLAQAEAAEICRMDKwBWAAAAAA==.',Ic='Icystar:BAAALAADCgYIBgAAAA==.',Il='Ilonginus:BAAALAADCgEIAQAAAA==.',Jm='Jmemory:BAABLAAECn8eAAMFAAYIqCEDMwD1AQAFAAYI7R0DMwD1AQABAAYIPCDlVACaAQAAAA==.',Js='Jsdfkjshg:BAAALAADCgEIAQAAAA==.',La='Laity:BAABLAAECn8yAAIGAAgI2B/NKwCMAgAGAAgI2B/NKwCMAgAAAA==.',Li='Liquor:BAAALAAECggICAAAAA==.',Lo='Loveqiqi:BAAALAAECgYIBgAAAA==.',Mi='Milaazul:BAAALAADCgIIAgAAAA==.',Ok='Okae:BAAALAADCggIDwAAAA==.Okitatsu:BAABLAAECn8aAAMHAAgI5h+ICQC8AgAHAAgI5h+ICQC8AgAIAAMIGAgkQgBtAAAAAA==.',Pe='Peanuts:BAAALAAECgQIBAAAAA==.',Pl='Playerkkjufs:BAAALAAECgUIBgAAAA==.Playeryjsupt:BAAALAADCgIIAgAAAA==.',Po='Polarisxu:BAAALAAECgYIBwAAAA==.',Re='Res:BAAALAAFFAIIAgAAAA==.',Sa='Sandalwood:BAABLAAFFH8IAAMJAAIIRRiCTwCRAAAJAAIIRRiCTwCRAAAKAAEIswFFIwAwAAAAAA==.',Sv='Svalin:BAAALAAFFAIIAgAAAA==.',Sy='Sylvana:BAAALAAFFAIIAgAAAA==.',Ty='Tyrantzz:BAAALAAECgQIBAAAAA==.',Vi='Vicsanity:BAAALAAECggIAwAAAA==.Victoxics:BAAALAAECgIIAgABLAAECggIAwALAAAAAA==.Vison:BAAALAAFFAIIAgAAAA==.',Xf='Xfk:BAAALAAFFAIIAgAAAA==.',Yo='Yolo:BAAALAAECgYIBgAAAA==.',['一个']='一个死骑:BAAALAAECgIIAgAAAA==.',['一刀']='一刀就超神:BAAALAAECgYIBgABLAAFFAYIJgABAPYgAA==.一刀龙:BAACLAAFFH8mAAMBAAYI9iDEEwDwAQABAAYI9iDEEwDwAQAFAAEIaRODNQA/AAAsAAQKfx0AAwEACAgLIKAwAJcCAAEABwhbIaAwAJcCAAUAAgg1F42aAIYAAAAA.一刀龙爷:BAACLAAFFH8QAAMMAAUI+xuuGACXAQAMAAUI+xuuGACXAQANAAMIexLHNQCGAAAsAAQKfx4AAw0ABghtGhIlAI8BAA0ABghtGhIlAI8BAAwABgh4E2aZAEsBAAEsAAUUBggmAAEA9iAA.',['一杆']='一杆进洞:BAAALAAECggICwAAAA==.',['一杯']='一杯尽风霜:BAAALAAECgYIBgAAAA==.',['一毛']='一毛丶二:BAAALAADCgYICAAAAA==.',['一点']='一点寒芒:BAAALAADCgEIAQAAAA==.',['一箭']='一箭双雕王:BAACLAAFFH8HAAIBAAII0gPQggBWAAABAAII0gPQggBWAAAsAAQKfzEAAgEACAjhFf5mAHQBAAEACAjhFf5mAHQBAAAA.',['万茜']='万茜:BAAALAAECggIBwAAAA==.',['万象']='万象城:BAABLAAFFH8GAAIOAAQINgV2JABZAAAOAAQINgV2JABZAAAAAA==.',['下雨']='下雨天的森林:BAAALAAECgYICwAAAA==.',['不争']='不争春:BAACLAAFFH8RAAIPAAQIthOhDgDzAAAPAAQIthOhDgDzAAAsAAQKfyIAAg8ACAh6HJ8PALwCAA8ACAh6HJ8PALwCAAAA.',['不爱']='不爱吃南瓜:BAABLAAFFH8JAAIBAAIINh4YgQBUAAABAAIINh4YgQBUAAAAAA==.',['不聪']='不聪明:BAABLAAECn8gAAIDAAYIcxZmMwBYAQADAAYIcxZmMwBYAQAAAA==.',['专干']='专干小勺币:BAAALAAECgIIAgAAAA==.',['丘比']='丘比特:BAAALAAECgEIAQAAAA==.',['东京']='东京没东莞热:BAAALAAECgMIAwAAAA==.',['丨丶']='丨丶一抹奶荼:BAABLAAFFH8SAAICAAYI+Bq9HgC6AQACAAYI+Bq9HgC6AQAAAA==.',['丨夕']='丨夕阳丶术:BAABLAAFFH8HAAIQAAMIFiA0IAAkAQAQAAMIFiA0IAAkAQAAAA==.丨夕阳丶渊:BAAALAAECgYIBgAAAA==.',['丨清']='丨清影丨:BAAALAAECgYIBgAAAA==.',['丨醉']='丨醉舞倾城丶:BAABLAAECn8cAAIRAAgI6Rw3EgCMAgARAAgI6Rw3EgCMAgAAAA==.',['中原']='中原一点红:BAAALAAFFAIIAgAAAA==.',['丶妍']='丶妍:BAABLAAFFH8QAAISAAUIqBHxCAAnAQASAAUIqBHxCAAnAQAAAA==.',['丶寻']='丶寻寻:BAAALAAFFAIIAgAAAA==.',['丶敢']='丶敢敢丶:BAAALAAECgMIAwAAAA==.',['乌拉']='乌拉乌拉丶嘿:BAAALAAECgIIAgAAAA==.',['乌索']='乌索普:BAAALAAFFAIIAgAAAA==.',['九丶']='九丶尾:BAAALAAFFAIIAgAAAA==.',['九号']='九号契约:BAABLAAFFH8WAAMQAAUIThscMgBOAQAQAAUIThscMgBOAQATAAEIJhKHKABPAAAAAA==.',['九黎']='九黎:BAABLAAFFH8HAAIJAAMIcBcmQACfAAAJAAMIcBcmQACfAAAAAA==.',['乾坤']='乾坤大天地:BAAALAAECgQIBAAAAA==.',['亦菲']='亦菲姐的保镖:BAAALAADCgIIAgAAAA==.',['人渣']='人渣林:BAABLAAECn8UAAICAAgIPw3WywCIAQACAAgIPw3WywCIAQAAAA==.',['他很']='他很吊:BAAALAAFFAIIAgAAAA==.',['仙之']='仙之左手:BAAALAADCgcICAAAAA==.',['以战']='以战爲名:BAAALAAECgYICQAAAA==.',['伊斯']='伊斯塔露:BAAALAAECgQIBAAAAA==.',['伊立']='伊立蛋语风:BAAALAADCggICgABLAAFFAgIEQAQAJYaAA==.',['伍佑']='伍佑丨卫门:BAABLAAFFH8GAAMUAAIIpQE5bwAeAAAUAAIIfQE5bwAeAAAVAAIIpQGBGwAaAAAAAA==.',['低语']='低语瞄咆哮:BAAALAAECgYIBgAAAA==.',['佐山']='佐山爱雨:BAAALAADCgQIBAAAAA==.',['你到']='你到底会玩吗:BAABLAAFFH8GAAIWAAYI7A2NHwBrAQAWAAYI7A2NHwBrAQAAAA==.',['偶尔']='偶尔躺下:BAABLAAFFH8LAAIOAAYIGRJ2EwAnAQAOAAYIGRJ2EwAnAQAAAA==.',['偷感']='偷感十足:BAACLAAFFH8GAAIQAAQIdALzTgB+AAAQAAQIdALzTgB+AAAsAAQKfxQAAhAACAguFGEsAJ8BABAACAguFGEsAJ8BAAAA.',['光凡']='光凡达:BAABLAAFFH8IAAIWAAIIRBuLKgC0AAAWAAIIRBuLKgC0AAAAAA==.',['光屁']='光屁屁:BAAALAADCgUIBQAAAA==.',['八基']='八基大狂蜂:BAAALAAECgYICgAAAA==.',['八月']='八月初五:BAAALAAFFAIIAgAAAA==.',['公子']='公子阔少:BAAALAAECgYICwAAAA==.',['六十']='六十六号工地:BAAALAADCgEIAQAAAA==.',['其實']='其實我不囧:BAABLAAFFH8GAAMKAAYI5QY9DACUAAAKAAQI/gk9DACUAAAJAAIIsQBzawAhAAAAAA==.其實我不壊:BAABLAAFFH8GAAIXAAYIKxAFAgBMAQAXAAYIKxAFAgBMAQAAAA==.',['冉闵']='冉闵:BAAALAADCgMIAwAAAA==.',['再见']='再见:BAAALAADCgEIAQAAAA==.',['冬寂']='冬寂:BAAALAAECgYIBgABLAAFFAYIDAABAO4YAA==.',['冰岛']='冰岛:BAAALAAFFAIIBAAAAA==.',['冰火']='冰火之间:BAAALAAECgYICgAAAA==.',['净魂']='净魂之刃:BAAALAAFFAIIAwAAAA==.',['几百']='几百个萨蛮:BAACLAAFFH8iAAIMAAcIkQ/xHgBkAQAMAAcIkQ/xHgBkAQAsAAQKfyEAAwwACAheHBghAPQBAAwACAheHBghAPQBAA0AAQgYAxbeAB0AAAAA.',['出入']='出入证:BAAALAADCgcIBwAAAA==.',['刀劍']='刀劍劍:BAAALAAFFAIIAgAAAA==.',['刘财']='刘财主丶:BAAALAAECgIIAgAAAA==.',['到处']='到处插棍棍:BAABLAAFFH8KAAIMAAIIyhnfPwCCAAAMAAIIyhnfPwCCAAAAAA==.',['前行']='前行者:BAAALAAECgYIDQAAAA==.',['加减']='加减法丶:BAAALAADCgYIBgAAAA==.',['加摩']='加摩尔:BAABLAAFFH8KAAICAAIIfhkbSgCmAAACAAIIfhkbSgCmAAAAAA==.',['加鲁']='加鲁地摊咆哮:BAAALAAECgMIAwAAAA==.',['包包']='包包满了:BAAALAADCgYIBgAAAA==.',['午夜']='午夜唉:BAAALAAFFAIIAgAAAA==.',['华尔']='华尔琪:BAAALAAECgYIBgAAAA==.',['卖小']='卖小女孩的糖:BAABLAAFFH8IAAMTAAgIqwDTGgARAAATAAcItQDTGgARAAAQAAEIZAAAAAAAAAAAAA==.',['南波']='南波万:BAAALAAFFAIIAgAAAA==.南波兔:BAAALAAFFAEIAgAAAA==.',['卡乐']='卡乐:BAAALAAFFAIIAwAAAA==.',['卡比']='卡比兽:BAAALAAECgYICAAAAA==.',['双喜']='双喜临:BAAALAAECgYIBgAAAA==.',['变形']='变形大师:BAAALAADCgIIAgAAAA==.',['只干']='只干小勺笔:BAAALAAECgcIEAAAAA==.',['可口']='可口不是百事:BAAALAAECgcICgAAAA==.',['司徒']='司徒千与:BAAALAAECgIIAgAAAA==.司徒千寻:BAAALAAECgMIAwAAAA==.',['司文']='司文人:BAAALAAFFAIIAgAAAA==.',['吃芝']='吃芝士汉堡:BAAALAAECgUIBQAAAA==.',['吉野']='吉野洁:BAABLAAFFH8GAAICAAIINwoOlAA8AAACAAIINwoOlAA8AAAAAA==.',['吼凡']='吼凡达:BAABLAAFFH8GAAIGAAIIBQ++RACGAAAGAAIIBQ++RACGAAAAAA==.',['咕噜']='咕噜咕噜咕噜:BAAALAAECgYIEwAAAA==.',['咪女']='咪女士又饿了:BAAALAAECgMIAwAAAA==.',['咪猪']='咪猪:BAABLAAFFH8JAAICAAMIPRExYACNAAACAAMIPRExYACNAAAAAA==.',['哈侬']='哈侬白侬:BAAALAAECgQIBAAAAA==.',['哈哈']='哈哈嘻嘻:BAAALAAFFAEIAQAAAA==.',['哔哩']='哔哩哔哩叩:BAABLAAECn8ZAAIQAAYIlxfCbgCpAQAQAAYIlxfCbgCpAQAAAA==.',['啥强']='啥强玩啥:BAABLAAECn8jAAICAAYIvCIPVQBNAgACAAYIvCIPVQBNAgAAAA==.',['喝气']='喝气泡水打嗝:BAABLAAECn8gAAIFAAgI7CPnDQDzAgAFAAgI7CPnDQDzAgAAAA==.',['喵丶']='喵丶馨:BAAALAAECgYIBgAAAA==.',['嘿嘿']='嘿嘿:BAAALAAECgYICgAAAA==.',['噬魂']='噬魂杀:BAABLAAFFH8GAAIJAAII+g/PUwCNAAAJAAII+g/PUwCNAAABLAAFFAIICAAYABoYAA==.',['围观']='围观群众丶:BAAALAAECgYIEgAAAA==.',['土里']='土里土气:BAAALAAECgMIAwAAAA==.',['圣丶']='圣丶光:BAACLAAFFH8HAAIZAAIIUQaqHgBiAAAZAAIIUQaqHgBiAAAsAAQKfxYAAxkACAh0FPUTAH0BABkABwgjFvUTAH0BABYAAwhJB7DTAFQAAAAA.',['圣光']='圣光守护者:BAACLAAFFH8GAAIBAAIItwEUwAAjAAABAAIItwEUwAAjAAAsAAQKfx0AAgEABwiVDSmPADEBAAEABwiVDSmPADEBAAAA.圣光牛博一:BAAALAAECgQIBQAAAA==.圣光的挽歌:BAABLAAFFH8kAAICAAYIeyDCGgDMAQACAAYIeyDCGgDMAQAAAA==.',['墨未']='墨未言泽:BAAALAAFFAIIAgAAAA==.',['壹厘']='壹厘蛋:BAAALAAECgYIDgAAAA==.',['夏沫']='夏沫南栀:BAABLAAFFH8LAAIaAAQIEhN8JQAOAQAaAAQIEhN8JQAOAQAAAA==.',['夕阳']='夕阳丨沫:BAAALAAECggIDQAAAA==.',['夜千']='夜千雪:BAAALAAFFAIIAgAAAA==.',['夜夜']='夜夜凯哥:BAAALAAECgYIBgAAAA==.',['大内']='大内高手:BAABLAAFFH8XAAIaAAYIkRWgEwC6AQAaAAYIkRWgEwC6AQAAAA==.',['大概']='大概是好人:BAAALAAECgcIEAAAAA==.',['大空']='大空异:BAABLAAFFH8IAAMbAAII2AztBQBaAAAbAAII2AztBQBaAAAYAAIIHwTcLwA1AAAAAA==.',['天崽']='天崽菌团咆哮:BAAALAAECgYIBgAAAA==.天崽菌团酋长:BAAALAAECggIEAAAAA==.',['女巫']='女巫妞妞:BAAALAAECgUIBQAAAA==.',['女王']='女王的废舞:BAAALAAECgYIBgAAAA==.',['奶不']='奶不住了:BAABLAAFFH8IAAIYAAIIGhj6GwCaAAAYAAIIGhj6GwCaAAAAAA==.',['奶萨']='奶萨:BAABLAAFFH8GAAMMAAIIuAHeeAA5AAAMAAIIuAHeeAA5AAANAAIIDQGRVgAJAAAAAA==.',['如此']='如此霸气:BAAALAAECgYIBgAAAA==.',['妩媚']='妩媚者一魅风:BAAALAADCgIIAgAAAA==.',['姜秀']='姜秀秀:BAAALAAECgYIBgAAAA==.',['威威']='威威丶:BAAALAAECgEIAQAAAA==.',['孤独']='孤独到死:BAABLAAFFH8VAAIBAAYIKA48QgA/AQABAAYIKA48QgA/AQAAAA==.',['宫廷']='宫廷御用采菊:BAAALAAECgUIBwAAAA==.',['射普']='射普琴科:BAAALAAECgYICwAAAA==.',['小伊']='小伊万:BAABLAAFFH8MAAIQAAYISiRxFwDOAQAQAAYISiRxFwDOAQAAAA==.',['小奶']='小奶赛:BAAALAAFFAIIAgAAAA==.',['小小']='小小的死骑:BAAALAAFFAIIAgABLAAFFAIICAAYABoYAA==.小小约德尔:BAABLAAECn8UAAIJAAYIax3hXQDqAQAJAAYIax3hXQDqAQAAAA==.',['小时']='小时候萌着呢:BAABLAAFFH8JAAMEAAYIsw4IFABEAQAEAAYIsw4IFABEAQADAAEITxIgXAA2AAAAAA==.',['小谭']='小谭灬茜荔:BAABLAAECn8uAAMcAAcIYiGLEQCUAgAcAAcIYiGLEQCUAgASAAcIbhhpFwDiAQAAAA==.',['小酌']='小酌怡情浅:BAACLAAFFH8MAAIQAAII9g5aXQBBAAAQAAII9g5aXQBBAAAsAAQKfxsAAhAABghTGi8yAIMBABAABghTGi8yAIMBAAAA.',['小青']='小青橙:BAAALAAECggIAgAAAA==.',['小马']='小马薇红:BAACLAAFFH8YAAIWAAYIfwyRJQBIAQAWAAYIfwyRJQBIAQAsAAQKfxcAAhYACAiJGBovANYBABYACAiJGBovANYBAAAA.',['小鬣']='小鬣人:BAAALAAECggICgAAAA==.',['小鬼']='小鬼望崽:BAAALAAFFAIIAgAAAA==.',['小龙']='小龙人丶:BAAALAAECgYIBgAAAA==.',['尐尐']='尐尐萨:BAABLAAFFH8IAAIMAAIIGRn1UAB5AAAMAAIIGRn1UAB5AAAAAA==.',['山丘']='山丘阿踢泽:BAAALAAECgEIAQAAAA==.',['帅姐']='帅姐:BAABLAAFFH8IAAIGAAgIDwEsYwAqAAAGAAgIDwEsYwAqAAAAAA==.',['年少']='年少的加摩尔:BAABLAAFFH8KAAMBAAIIaho0TACYAAABAAIIaho0TACYAAAFAAIIEQajLgBmAAAAAA==.',['年轻']='年轻的加摩尔:BAABLAAFFH8KAAITAAII6h/YDACtAAATAAII6h/YDACtAAAAAA==.',['年迈']='年迈的加摩尔:BAABLAAFFH8IAAMZAAIIZgoDHgBlAAAZAAIIZgoDHgBlAAAWAAIIeQcZfQAzAAAAAA==.',['幼儿']='幼儿园小班:BAAALAAECgYIBgABLAAFFAgIOQAWAGcgAA==.',['康德']='康德柱:BAAALAAFFAIIAgAAAA==.',['异娘']='异娘欧克:BAABLAAECn8UAAIOAAYINxcXPwCHAQAOAAYINxcXPwCHAQAAAA==.',['弑神']='弑神丶湮灭:BAAALAAFFAEIAQAAAA==.',['弓到']='弓到自然成:BAAALAAECgQIBAAAAA==.',['彬长']='彬长之歌:BAABLAAFFH8KAAMdAAQIyBvUFAC3AAAdAAMIyxnUFAC3AAAWAAEIJwkrZABEAAAAAA==.',['彭彭']='彭彭来了:BAAALAAECgYICwAAAA==.',['彼得']='彼得丶伊里奇:BAABLAAFFH8JAAIBAAUIQA7nUQAHAQABAAUIQA7nUQAHAQAAAA==.',['往事']='往事若茶:BAAALAAECgUIBQAAAA==.',['微醺']='微醺:BAAALAAFFAMIAQAAAA==.',['心疼']='心疼鸽鸽:BAAALAADCgYIBgAAAA==.',['快乐']='快乐河马:BAAALAAECgYIBgAAAA==.',['念影']='念影如丝:BAABLAAFFH8GAAICAAYInSL2EQD/AQACAAYInSL2EQD/AQAAAA==.',['恋爱']='恋爱在晴天:BAAALAAECgYIDAAAAA==.',['悠悠']='悠悠子兮:BAAALAAECgYIBgAAAA==.',['想个']='想个好名难:BAACLAAFFH8zAAIGAAcIcCGqAwBlAgAGAAcIcCGqAwBlAgAsAAQKfysAAgYACAguJvABAIYDAAYACAguJvABAIYDAAAA.',['愤怒']='愤怒丶幻觉:BAAALAAECgYIDAAAAA==.愤怒的烟灰:BAAALAAECgUIBQAAAA==.',['憋打']='憋打我辣:BAAALAADCggIDwAAAA==.',['懒回']='懒回顾:BAAALAAECgYIEQAAAA==.',['懵犇']='懵犇:BAAALAAECgYICwAAAA==.',['懿明']='懿明:BAAALAAFFAIIBAAAAA==.',['懿菲']='懿菲菲:BAAALAAFFAIIBAAAAA==.',['我想']='我想做好人:BAAALAADCgUIBwAAAA==.',['战耀']='战耀天下:BAAALAAECgYIEgAAAA==.',['手段']='手段:BAACLAAFFH9EAAMGAAYIXSTaCQAWAgAGAAYIXSTaCQAWAgAOAAYInhnzCQA2AQAsAAQKf0EAAw4ACAjeJeEHAB0DAA4ACAiwJOEHAB0DAAYABgilJW8YAB8CAAAA.',['打不']='打不中你:BAAALAAECgIIAgAAAA==.',['托马']='托马斯旋:BAABLAAECn8hAAIGAAgInSAoCwCgAgAGAAgInSAoCwCgAgAAAA==.',['扭头']='扭头瞬间丶:BAAALAAECgYIBgAAAA==.',['挚念']='挚念:BAABLAAFFH8GAAICAAIISBmQdgBLAAACAAIISBmQdgBLAAAAAA==.',['掏他']='掏他裆间:BAAALAAECgYIBgAAAA==.',['放开']='放开那个擒兽:BAABLAAECn8dAAMWAAcITw0kagAuAQAWAAcITw0kagAuAQAdAAYILQ28SwApAQAAAA==.',['斗哦']='斗哦:BAAALAADCggICgAAAA==.',['新青']='新青联十八号:BAAALAAECgIIAgAAAA==.新青联十号:BAAALAADCgQIBAAAAA==.',['无与']='无与伦比:BAAALAAFFAIIBAAAAA==.',['无可']='无可匹敌:BAAALAAFFAIIAgAAAA==.',['无心']='无心的火柴:BAABLAAECn8VAAICAAYIOw6dGQEgAQACAAYIOw6dGQEgAQAAAA==.',['无敌']='无敌丶:BAAALAAECgYIDAAAAA==.',['无畏']='无畏:BAAALAAFFAIIAgAAAA==.无畏先锋丶龙:BAABLAAFFH8NAAMGAAQIshpjKwALAQAGAAQIshpjKwALAQAOAAIIFxO9KQBqAAABLAAFFAYIJgABAPYgAA==.',['无聊']='无聊中的媌:BAABLAAECn8XAAIDAAYIVBZoXQB7AQADAAYIVBZoXQB7AQAAAA==.无聊中的猫:BAAALAAECgYIEgAAAA==.',['星辰']='星辰毁:BAAALAAECgYIEAAAAA==.星辰辉:BAAALAAECgYIEgAAAA==.',['晓晓']='晓晓灬牛:BAAALAAECgYIBwAAAA==.晓晓灬骑:BAAALAAECgYIBgAAAA==.',['晖哥']='晖哥真是帅:BAAALAAFFAIIBAAAAA==.',['普罗']='普罗丶最可爱:BAAALAAECgQIBAAAAA==.',['晴空']='晴空:BAAALAAECgIIAgAAAA==.',['暗夜']='暗夜德:BAAALAAECgYIDwAAAA==.',['暗潶']='暗潶破壞神:BAAALAAECgUIBQAAAA==.',['暴力']='暴力者灬落泪:BAAALAAECgYIBgAAAA==.',['暴暴']='暴暴拽得很丶:BAAALAAFFAEIAQAAAA==.',['曼青']='曼青:BAAALAAECgEIAQAAAA==.',['月痕']='月痕思琰:BAAALAAFFAEIAQAAAA==.',['月色']='月色丶:BAAALAAECgEIAQAAAA==.',['月落']='月落子规歇:BAABLAAFFH8GAAMeAAYI5gYpHgBPAAAeAAMI/AApHgBPAAAfAAMIigGcDgBPAAAAAA==.',['术术']='术术数:BAAALAAFFAEIAQABLAAFFAIIAgALAAAAAA==.',['机智']='机智的阿昆达:BAAALAAFFAIIAgAAAA==.',['杨清']='杨清欢:BAABLAAFFH8JAAIMAAMIdw/WQgB8AAAMAAMIdw/WQgB8AAAAAA==.',['某科']='某科学电磁豹:BAAALAAECgYICgAAAA==.',['桂丶']='桂丶言葉:BAAALAAFFAIIBAAAAA==.',['桜花']='桜花的羽根:BAABLAAFFH8LAAIWAAYIgxmqEQC6AQAWAAYIgxmqEQC6AQAAAA==.',['梦山']='梦山狐影:BAAALAAFFAIIAgAAAA==.',['概率']='概率牧:BAAALAAECgYIBgAAAA==.',['死亡']='死亡吞噬:BAAALAAECgYIDgAAAA==.',['残风']='残风凋零剑气:BAAALAAECgQIBAAAAA==.',['毒奶']='毒奶丶敢吃么:BAAALAAECgYIDAAAAA==.',['河蟹']='河蟹杀手:BAAALAAECggICQAAAA==.河蟹杀手大王:BAAALAAECgIIAgAAAA==.',['法法']='法法可游:BAAALAAFFAIIAgAAAA==.',['泪做']='泪做杯中酒:BAAALAAFFAMIAwAAAA==.',['流年']='流年淡漠红尘:BAAALAAFFAMIAwAAAA==.',['淡淡']='淡淡的仙儿:BAAALAAECgMIAwAAAA==.淡淡的痛:BAAALAADCgEIAQAAAA==.',['深海']='深海活鱼:BAABLAAFFH8JAAIWAAYI2RQyCADjAQAWAAYI2RQyCADjAQAAAA==.',['清风']='清风随影剑气:BAAALAADCgEIAQAAAA==.',['清香']='清香:BAABLAAECn8ZAAIQAAcISwkbVQAAAQAQAAcISwkbVQAAAQAAAA==.',['温柔']='温柔的小奶牛:BAABLAAFFH8JAAIdAAMI8BSFFAC5AAAdAAMI8BSFFAC5AAAAAA==.',['火爆']='火爆小腰花:BAAALAAFFAIIAgAAAA==.',['火狐']='火狐星:BAAALAAFFAIIBAAAAA==.',['灬敢']='灬敢敢灬:BAABLAAFFH8OAAIOAAgIyQuICgCXAQAOAAgIyQuICgCXAQAAAA==.',['灵芝']='灵芝孢子油:BAABLAAECn8UAAMgAAcIDRNRJABsAQAgAAcIDRNRJABsAQADAAMIPgIm3ABHAAAAAA==.',['熊摆']='熊摆摆:BAAALAAFFAMIAwAAAA==.',['熊猫']='熊猫丶:BAAALAAECgYIEgAAAA==.熊猫是彩色的:BAAALAAECgYIBwAAAA==.',['熙熙']='熙熙见豆就吃:BAAALAAECgYIBwAAAA==.',['燃烧']='燃烧的柒毛:BAAALAAFFAQIAgAAAA==.燃烧的鸠毛:BAAALAAECgYIBgAAAA==.',['爱恨']='爱恨情仇:BAAALAAECgUIBQAAAA==.',['爱撒']='爱撒点小谎:BAAALAAECgYIBgAAAA==.',['爱灬']='爱灬鹊:BAAALAAECgcIBwAAAA==.',['爲妳']='爲妳灬疯狂:BAABLAAFFH8IAAIOAAMIPxPdIAByAAAOAAMIPxPdIAByAAAAAA==.',['牧凡']='牧凡达:BAABLAAFFH8MAAIaAAIINxSZNACIAAAaAAIINxSZNACIAAAAAA==.',['牵着']='牵着我的口袋:BAAALAAECggICAAAAA==.',['狂暴']='狂暴萨利萨:BAAALAAFFAIIAgAAAA==.',['狐狸']='狐狸狐涂:BAAALAAECgIIAwAAAA==.',['狗子']='狗子:BAABLAAFFH8PAAMBAAMIahyYQgCiAAABAAMIahyYQgCiAAAhAAEIkhU1CABMAAAAAA==.',['狼德']='狼德:BAAALAAFFAIIBAAAAA==.',['珐柯']='珐柯游:BAAALAAECgMIBgAAAA==.',['理塘']='理塘王丁比:BAAALAAFFAMIAwAAAA==.',['瑞什']='瑞什么瑞:BAACLAAFFH8IAAIJAAYIsgH1PwCtAAAJAAYIsgH1PwCtAAAsAAQKfxUAAgkABgiyEpuUAGEBAAkABgiyEpuUAGEBAAEsAAUUCAg3ACAAqB4A.',['瓦帕']='瓦帕努墨姬:BAABLAAFFH8OAAIWAAUIBRQ7KQAzAQAWAAUIBRQ7KQAzAQAAAA==.',['甘木']='甘木槿:BAACLAAFFH8MAAICAAIIzhOHewBIAAACAAIIzhOHewBIAAAsAAQKfx4AAgIACAhxG5VLAGMCAAIACAhxG5VLAGMCAAAA.',['疯油']='疯油經丶:BAAALAAECgYIBgAAAA==.',['疯狂']='疯狂的列人:BAAALAAFFAIIBAAAAA==.',['瘦棍']='瘦棍儿:BAAALAAECgIIAgAAAA==.',['白霪']='白霪之手:BAAALAAECgYIBgAAAA==.',['百里']='百里东君:BAABLAAFFH8ZAAMdAAYIWCD3BQA2AgAdAAYIWCD3BQA2AgAZAAUI5RfGCAAuAQAAAA==.',['看我']='看我摇摇铃:BAABLAAFFH8FAAIBAAUIzhzINwBfAQABAAUIzhzINwBfAQAAAA==.',['瞎子']='瞎子不迷路:BAAALAAECgYIEwAAAA==.',['碎蛋']='碎蛋之击丶:BAABLAAFFH8GAAICAAII3xVjawCTAAACAAII3xVjawCTAAAAAA==.',['碴子']='碴子:BAAALAAECgYIBwAAAA==.',['祁闻']='祁闻冥轩:BAABLAAFFH8UAAMGAAYIvhLwIwBOAQAGAAYIGA3wIwBOAQAOAAUImhWcFgD9AAAAAA==.',['神一']='神一样存在着:BAAALAAFFAIIAgAAAA==.',['神圣']='神圣:BAAALAADCgQIBAAAAA==.',['秀你']='秀你一脸:BAABLAAECn8fAAMEAAcI1BvqNQDjAQAEAAYIdxvqNQDjAQADAAcIjhRYYAByAQAAAA==.',['秋狩']='秋狩月:BAACLAAFFH80AAMcAAYIISWLAwAZAgAcAAYIISWLAwAZAgASAAIIzxxmEACaAAAsAAQKfxgAAxwACAiMImkIAPwCABwACAg+ImkIAPwCABIABQjBHtEbALYBAAEsAAUUBghEAAYAXSQA.',['米乐']='米乐米乐:BAAALAAECgYIBgAAAA==.',['紅蓮']='紅蓮:BAAALAAFFAEIAQAAAA==.',['素笺']='素笺淡墨:BAABLAAFFH8VAAMMAAYI0RcsIwBFAQAMAAUIXxYsIwBFAQANAAUIHBIWJAAkAQAAAA==.',['紧张']='紧张的河马:BAAALAAECgYICQAAAA==.',['繁星']='繁星尚月争荣:BAAALAAECgcIBwAAAA==.',['红茶']='红茶拿铁丶:BAAALAADCgYIBgAAAA==.',['纯属']='纯属丶愚乐:BAAALAAECgYIDAAAAA==.',['纳西']='纳西妲:BAAALAAFFAIIAgAAAA==.',['绿丶']='绿丶巨人:BAACLAAFFH8JAAIMAAIIfQ+aWABpAAAMAAIIfQ+aWABpAAAsAAQKfxoAAgwACAhAE8ExAJkBAAwACAhAE8ExAJkBAAAA.',['老哥']='老哥你好:BAAALAAECgYIEgAAAA==.',['老弓']='老弓:BAAALAAECggIAgABLAAFFAgICwABAHceAA==.',['老强']='老强尼秦腔团:BAAALAAECgYIBgAAAA==.',['老杰']='老杰克京剧团:BAAALAAECgYIBgAAAA==.',['耳朵']='耳朵萌萌哒:BAAALAAECgYIBgAAAA==.',['肆意']='肆意的疯:BAABLAAFFH8GAAICAAIIHAg9jABAAAACAAIIHAg9jABAAAAAAA==.肆意的风:BAACLAAFFH8OAAIBAAMIBh7pZwCWAAABAAMIBh7pZwCWAAAsAAQKfxQAAwEABwjMH5FkABICAAEABwjMH5FkABICAAUAAgg3DxmlAGgAAAAA.',['股市']='股市第一韭菜:BAAALAAFFAIIAgAAAA==.',['肥肥']='肥肥杀神:BAAALAAECgYIDAAAAA==.',['肩膀']='肩膀的忧伤:BAAALAAECgYIDAAAAA==.',['肿么']='肿么肥四:BAAALAADCgEIAQAAAA==.',['臻纯']='臻纯牛奶:BAAALAAECgYIEQAAAA==.',['艳阳']='艳阳天丶:BAABLAAFFH8FAAICAAII5BpkTACkAAACAAII5BpkTACkAAAAAA==.',['艾斯']='艾斯艾斯:BAAALAAECgYIEgAAAA==.艾斯艾沐:BAABLAAECn8ZAAIMAAgIzCJSBQAEAwAMAAgIzCJSBQAEAwAAAA==.',['花凡']='花凡达:BAABLAAFFH8MAAICAAIIAxAsgACHAAACAAIIAxAsgACHAAAAAA==.',['花木']='花木兰:BAABLAAECn8XAAIWAAYIAxx5oAC2AQAWAAYIAxx5oAC2AQAAAA==.',['若风']='若风起时:BAAALAAECggICAAAAA==.',['莫莫']='莫莫伽:BAABLAAFFH8eAAQhAAYIvCKLAADJAQABAAYIvCJMGgDMAQAhAAUIbRWLAADJAQAFAAEIKgVFOQAyAAAAAA==.',['菠萝']='菠萝菠萝蜜丶:BAAALAAECgcIDAAAAA==.',['萌萌']='萌萌德:BAAALAAECgYICgAAAA==.',['萨子']='萨子:BAABLAAFFH8IAAIMAAMINhhKHQDVAAAMAAMINhhKHQDVAAAAAA==.',['萨满']='萨满开嗜血:BAAALAADCgUIBQAAAA==.',['薄暮']='薄暮知秋:BAABLAAFFH8ZAAMDAAYI1BmVDgDVAQADAAYI1BmVDgDVAQAEAAEImwWsOQA0AAAAAA==.',['蛋疼']='蛋疼的名字丶:BAAALAADCgYIBgAAAA==.',['蛮锤']='蛮锤:BAAALAAECgUIBgAAAA==.',['蜜雪']='蜜雪非常奶茶:BAAALAAFFAMIAwAAAA==.',['蟹丶']='蟹丶老板:BAAALAADCgQIBAAAAA==.',['血狼']='血狼芝崛起:BAAALAADCgEIAQAAAA==.',['装逼']='装逼如風:BAABLAAFFH8GAAIGAAIICRSXSwBIAAAGAAIICRSXSwBIAAABLAAFFAUIHQABADQeAA==.',['西瓜']='西瓜牛牛:BAAALAAECggICQAAAA==.',['见过']='见过帅哥啊:BAAALAAECgYIBgAAAA==.',['言多']='言多必失啊:BAABLAAFFH8JAAICAAUIzCP0GgBOAQACAAUIzCP0GgBOAQAAAA==.',['诺艾']='诺艾尔:BAAALAAECgYIBgAAAA==.',['谈笑']='谈笑风声:BAAALAAECgYIEwAAAA==.',['贼甜']='贼甜:BAAALAAFFAIIAgAAAA==.',['起名']='起名字太难了:BAAALAAFFAMIBAAAAA==.',['蹄儿']='蹄儿丶楣:BAAALAAECgcIBwAAAA==.',['辣目']='辣目脚趾:BAAALAAECgQIBAABLAAFFAgIBgAJAJoeAA==.',['这脸']='这脸太靓了:BAAALAADCgEIAQAAAA==.',['进门']='进门看见常威:BAAALAAECgYIDgAAAA==.',['迦壠']='迦壠:BAAALAAFFAIIAgAAAA==.',['迪奥']='迪奥:BAABLAAFFH8KAAIBAAMIJgZgfABgAAABAAMIJgZgfABgAAAAAA==.',['速趴']='速趴塞呀仁:BAAALAAFFAMIAwAAAA==.',['那个']='那个战猎萨:BAAALAADCgYIBgAAAA==.',['酋长']='酋长:BAABLAAFFH8FAAIOAAUIiR52DwBUAQAOAAUIiR52DwBUAQAAAA==.',['酒后']='酒后毒打丈人:BAAALAAECgMIAwAAAA==.',['酷奇']='酷奇:BAABLAAFFH8IAAIUAAIIXxvtSgBOAAAUAAIIXxvtSgBOAAAAAA==.',['酷骑']='酷骑:BAAALAAFFAIIAwAAAA==.',['酸酸']='酸酸梅子酒:BAAALAAECgUIBQAAAA==.',['鑫泽']='鑫泽塔琼斯:BAAALAAECgMIBAAAAA==.',['铁锤']='铁锤儿丶:BAAALAAECgYIBQAAAA==.',['铵屹']='铵屹锣:BAAALAADCggIDAAAAA==.',['锐羽']='锐羽丶:BAABLAAFFH8MAAIBAAYI7hg5NQBnAQABAAYI7hg5NQBnAQAAAA==.',['长颈']='长颈鹿不会跳:BAAALAAECgYIDAAAAA==.',['阿凡']='阿凡达大美妞:BAABLAAFFH8GAAMMAAIIUQwTVwBmAAAMAAIIUQwTVwBmAAANAAEIEgfAVwAAAAAAAA==.',['阿姆']='阿姆斯特朗炮:BAAALAAFFAIIBAAAAA==.',['阿斯']='阿斯蒂芬芬:BAABLAAFFH8RAAIJAAUIMBS2NgAbAQAJAAUIMBS2NgAbAQAAAA==.',['阿男']='阿男:BAAALAAECgYIBgAAAA==.',['陆子']='陆子野:BAABLAAFFH8GAAIaAAQIfQmINgCJAAAaAAQIfQmINgCJAAAAAA==.',['隔壁']='隔壁老板:BAAALAADCgQIBAAAAA==.',['难受']='难受人:BAAALAAECggICAAAAA==.',['離落']='離落:BAABLAAFFH8dAAMDAAYIgRmwFwB1AQADAAUIcxiwFwB1AQAEAAUIbRIzGAAYAQAAAA==.',['雨露']='雨露星辰:BAACLAAFFH8UAAMCAAQIjhhwQACyAAACAAMI0B1wQACyAAAIAAQIpgrSEgCoAAAsAAQKfx8ABAIABgjJI0xOAFwCAAIABgjJI0xOAFwCAAcAAwiMCbVJAJYAAAgAAQhQHLVGAFIAAAAA.',['雪糯']='雪糯米粥:BAABLAAFFH8FAAIMAAIIeh99LACqAAAMAAIIeh99LACqAAAAAA==.',['雪绵']='雪绵豆沙:BAAALAADCggICAAAAA==.',['青涩']='青涩小芒果:BAAALAAECgYIBgAAAA==.',['顾西']='顾西凉狼主:BAAALAAECgYIBgAAAA==.',['風的']='風的气息:BAAALAAECgEIAQAAAA==.',['风吹']='风吹麦浪:BAACLAAFFH8PAAINAAQIdBv3KQDxAAANAAQIdBv3KQDxAAAsAAQKfxwAAg0ABggVIBgaANoBAA0ABggVIBgaANoBAAAA.',['风干']='风干的葡萄:BAAALAADCgUIBQAAAA==.',['风流']='风流爱天下:BAABLAAFFH8JAAMMAAIIVR7dPgCpAAAMAAIIVR7dPgCpAAANAAEI3gMBWAAAAAAAAA==.',['风行']='风行小中褚:BAAALAAECgcIDgAAAA==.',['飒小']='飒小馒:BAAALAAECggICAAAAA==.',['騎小']='騎小豬看夕陽:BAAALAAECgYIEgAAAA==.',['骑千']='骑千人:BAAALAAECgIIAgAAAA==.',['骑小']='骑小猪望夕阳:BAAALAAECgYIDAAAAA==.骑小猪等夕阳:BAAALAAECgYIDAAAAA==.骑小猪追夕阳:BAAALAAECggIBgAAAA==.',['骷髅']='骷髅血法:BAAALAAECgQIBwAAAA==.',['魔法']='魔法炮台:BAACLAAFFH8gAAIQAAYIgxyaJACIAQAQAAYIgxyaJACIAQAsAAQKfzoABBAABwjFJWcVAAYDABAABwjFJWcVAAYDACIABghYGtERAJgBABMAAQh9HEuPAEoAAAAA.',['鲁哈']='鲁哈特丶谷古:BAAALAADCgYIBgAAAA==.',['麥丶']='麥丶克基:BAAALAAECggIAQAAAA==.',['麥克']='麥克丶基:BAACLAAFFH8HAAIGAAYICRxZFAC4AQAGAAYICRxZFAC4AQAsAAQKfxQAAgYACAjMDztoAL8BAAYACAjMDztoAL8BAAAA.',['麻雀']='麻雀:BAAALAAECgYICwAAAA==.',['黄明']='黄明轩单王:BAAALAAECgYIBgAAAA==.',['黑暗']='黑暗遊侠:BAAALAAECgYIBgAAAA==.',['黛尔']='黛尔瑞丶落晨:BAAALAAECgcICAAAAA==.',['黯淡']='黯淡木槿花:BAAALAAECgMIAwAAAA==.',['龙城']='龙城趰熋:BAAALAADCgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end