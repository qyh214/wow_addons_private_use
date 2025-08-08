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
 local lookup = {'Monk-Mistweaver','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Warrior-Arms','Warrior-Fury','Warrior-Protection','Paladin-Retribution','Paladin-Protection','Priest-Discipline','Priest-Holy','Shaman-Restoration','DeathKnight-Blood','Druid-Balance','Monk-Windwalker','Mage-Arcane','Hunter-Marksmanship','Shaman-Enhancement','DeathKnight-Unholy','Mage-Fire','Druid-Restoration','Druid-Feral','Shaman-Elemental','Priest-Shadow','DemonHunter-Havoc','Mage-Frost','Hunter-BeastMastery','Druid-Guardian','DemonHunter-Vengeance','Rogue-Assassination','Unknown-Unknown','Evoker-Devastation','Monk-Brewmaster','DeathKnight-Frost','Hunter-Survival','Evoker-Preservation','Rogue-Subtlety','Rogue-Outlaw','DeathKnight-Melee','Paladin-Holy',}; local provider = {region='CN',realm='戈提克',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ad='Ado:BAABKgAFFH8OAAIBAAYIgiFqBwDAAQABAAYIgiFqBwDAAQAAAA==.',An='Angieashfor:BAAAKgAFFAMIBAAAAA==.Anrors:BAAAKgAECgMIAwAAAA==.',Ar='Ardbeg:BAACKgAFFH8aAAMCAAMICwwlCgCtAAACAAMICwwlCgCtAAADAAMI0wYxOACQAAAqAAQKfyEABAQACAhmEOwcAAcBAAQABwiOD+wcAAcBAAIABgi2BtZFAMsAAAMAAwhxCb2GAH0AAAAA.Artaxe:BAABKgAFFH8TAAQFAAYIfBvMCAB9AQAGAAYIkBQzDACIAQAFAAYINRrMCAB9AQAHAAQIohHFEAAAAAAAAA==.',As='Ashenone:BAACKgAFFH8LAAIIAAMIsSCXMwAbAQAIAAMIsSCXMwAbAQAqAAQKfxwAAwgACAi2IQUnAIACAAgACAi2IQUnAIACAAkABAg8DdxDAH4AAAAA.',Be='Beckinsale:BAACKgAFFH8GAAMKAAQINRkrCgAEAQAKAAQINRkrCgAEAQALAAIIjQXaOQBZAAAqAAQKfyIAAgsACAiQGXMLANkBAAsACAiQGXMLANkBAAEqAAUUCAgSAAoAZBoA.Benares:BAABKgAFFH8IAAIMAAgIgAkBCQC3AQAMAAgIgAkBCQC3AQAAAA==.',Bi='Biggestmagic:BAAAKgAECgcIBwAAAA==.',Bl='Bluess:BAAAKgAFFAQIBAAAAA==.Bluex:BAAAKgAECggICAABKgAFFAgICAANAL0eAA==.Bluexx:BAABKgAFFH8IAAIDAAgIyxbbFwBFAQADAAgIyxbbFwBFAQAAAA==.',Ca='Cake:BAAAKgAFFAEIAQAAAA==.',Ch='Change:BAAAKgAFFAYIAQAAAA==.Cheney:BAAAKgAECgEIAQAAAA==.',Ci='Cirilla:BAAAKgADCggICAAAAA==.',Co='Coreorange:BAABKgAFFH8IAAIOAAgIjwakDgCIAQAOAAgIjwakDgCIAQAAAA==.',Cr='Crazyhammer:BAABKgAFFH8KAAMBAAYI5BYFDABmAQABAAYI5BYFDABmAQAPAAQI+AogDgDKAAAAAA==.',Da='Darker:BAAAKgAECgQIBQAAAA==.',Di='Dispirited:BAAAKgAECgUIAQAAAA==.',Dw='Dwyanewade:BAAAKgAECggICAAAAA==.',Ea='Eagleeye:BAAAKgAECgUIBQAAAA==.',Es='Esmex:BAABKgAFFH8JAAIIAAUI1xy+DQAdAQAIAAUI1xy+DQAdAQAAAA==.',Et='Eternalmagic:BAABKgAFFH8IAAIQAAgIdgnGCQDNAQAQAAgIdgnGCQDNAQAAAA==.',Gr='Grimmjow:BAABKgAFFH8KAAMFAAYI+RHmCQBtAQAFAAYI+RHmCQBtAQAGAAQIVAc3KwBGAAAAAA==.',Gu='Guang:BAAAKgADCgcIBwAAAA==.',Hz='Hzag:BAAAKgADCgMIAwAAAA==.Hzalchemist:BAAAKgADCgQIBAAAAA==.Hzbeastmaste:BAABKgAFFH8IAAIRAAgIgg1QBwDPAQARAAgIgg1QBwDPAQAAAA==.Hzcreolopus:BAABKgAFFH8GAAISAAYIsRk3BgCXAQASAAYIsRk3BgCXAQAAAA==.Hzpuppy:BAAAKgAECgEIAQAAAA==.Hzshendelzar:BAABKgAFFH8IAAITAAgIyxf1BABXAgATAAgIyxf1BABXAgAAAA==.',Je='Jesfen:BAABKgAFFH8GAAIJAAYI3RR4DAAwAQAJAAYI3RR4DAAwAQAAAA==.',Ju='Julyhunter:BAAAKgADCggICAAAAA==.',La='Larry:BAABKgAECn8ZAAMQAAUIKRk6RgAnAQAQAAUIKRk6RgAnAQAUAAQI2gIvkgBQAAAAAA==.',Lh='Lhianna:BAAAKgAECgcIBwAAAA==.',Lu='Ludiwg:BAAAKgAECgYICQAAAA==.',Lv='Lvpaul:BAAAKgAFFAQIBAAAAA==.',Ma='Madkid:BAAAKgAECgEIAQAAAA==.',Mc='Mc:BAAAKgADCggICAAAAA==.',My='Mydaughterid:BAAAKgADCgYIBgAAAA==.',Ne='Nemole:BAAAKgADCgMIAwAAAA==.Neroclaudius:BAACKgAFFH8yAAIIAAgI0SKfBgBfAgAIAAgI0SKfBgBfAgAqAAQKfykAAggACAgjJYkNAOMCAAgACAgjJYkNAOMCAAAA.',Ni='Nicotine:BAAAKgAECgIIAgAAAA==.',Ol='Ollopopollo:BAABKgAFFH8IAAIGAAMIpwajFQC2AAAGAAMIpwajFQC2AAAAAA==.',On='Onlyfens:BAABKgAFFH8UAAMTAAMIZxEmGQCdAAATAAIInxkmGQCdAAANAAEI9QA4FQAVAAAAAA==.',Ov='Overture:BAAAKgAECgMIAwAAAA==.',Pl='Playerpmplme:BAAAKgAECgIIAgAAAA==.Playerwdqcwn:BAAAKgAECgEIAQAAAA==.',Sa='Sansha:BAABKgAFFH8MAAIRAAYImSOOBgAAAgARAAYImSOOBgAAAgAAAA==.',Sc='Scania:BAABKgAFFH8HAAIJAAMIsQWuEQBpAAAJAAMIsQWuEQBpAAAAAA==.',Sh='Sharkx:BAACKgAFFH8bAAQVAAUISBL6EwAAAQAVAAQISBL6EwAAAQAWAAIISxdCBQCnAAAOAAMIYQ05LACDAAAqAAQKfysABBYACAjbG6MNAM8BABYABwipG6MNAM8BAA4ABQhYHZ1gAD4BABUABAjsFTlEANIAAAAA.',St='Starryfall:BAAAKgAFFAYIBAAAAA==.',Su='Superman:BAABKgAFFH8GAAIJAAYIzwHuDwCCAAAJAAYIzwHuDwCCAAAAAA==.',Sw='Swisse:BAAAKgAECgQIBAAAAA==.',Th='Theshy:BAAAKgADCgMIAwAAAA==.',Ti='Timeismoney:BAAAKgAECggICAAAAA==.',To='Tob:BAABKgAFFH8oAAMMAAgIMCVLAADsAgAMAAgIMCVLAADsAgAXAAIIAgUUIwBnAAAAAA==.',Wa='Waagh:BAABKgAFFH8KAAMNAAYIXhhTCwBcAQANAAYIXhhTCwBcAQATAAQIOxCCMwDIAAABKgAFFAYIEwARANQcAA==.',Yo='Youthsoul:BAABKgAFFH8KAAMVAAYIKhviBwCPAQAVAAYIKhviBwCPAQAOAAQIaCKAJwD3AAAAAA==.',['Ãä']='Ãäãäãäãä:BAAAKgAECggICAAAAA==.',['âã']='âãäåæçâãäåæl:BAAAKgADCgIIAgAAAA==.',['一勺']='一勺三花淡奶:BAAAKgAECggICAAAAA==.',['一希']='一希瓦娜斯一:BAAAKgAECgQIBAAAAA==.',['一念']='一念永恒:BAAAKgAFFAUIBAAAAA==.',['一纸']='一纸荒年:BAAAKgAECggIDwAAAA==.',['一颗']='一颗大白兔:BAABKgAFFH8FAAIIAAMIMQffZQCiAAAIAAMIMQffZQCiAAAAAA==.',['一骑']='一骑绝尘:BAABKgAECn8bAAIMAAYIAhsxRgBwAQAMAAYIAhsxRgBwAQAAAA==.',['丁瑶']='丁瑶:BAABKgAFFH8OAAMYAAYImBW+CwBCAQAYAAYImBW+CwBCAQAKAAQIhBymCQAJAQAAAA==.',['七十']='七十块麻辣烫:BAABKgAFFH8GAAISAAYIGwTEBwAEAQASAAYIGwTEBwAEAQAAAA==.',['七月']='七月爱吃西瓜:BAAAKgAFFAIIAgAAAA==.',['上学']='上学不逃学:BAACKgAFFH8IAAMVAAcI5A7UGgDLAAAVAAMIUBLUGgDLAAAOAAQIpgWnIgCrAAAqAAQKfxUAAhUACAhTFaAkAKcBABUACAhTFaAkAKcBAAEqAAUUCAgUABkAnBkA.',['不会']='不会变身:BAABKgAFFH8IAAMVAAQIJCK0EAAaAQAVAAQIJCK0EAAaAQAOAAIIchvjWwBEAAAAAA==.',['不偷']='不偷袭你也死:BAAAKgAECgUIBQAAAA==.',['不变']='不变树杈子:BAAAKgAECgQIBAAAAA==.',['不想']='不想丸辣:BAABKgAFFH8jAAMQAAcIOhksCAD3AQAQAAcIOhksCAD3AQAaAAYI2BEjBgD/AAAAAA==.',['不搞']='不搞偷袭:BAAAKgAECgQIBAAAAA==.',['丑丑']='丑丑的样子:BAABKgAFFH8GAAIbAAYI8hMNFgBHAQAbAAYI8hMNFgBHAQAAAA==.',['两百']='两百多只柯基:BAACKgAFFH8HAAIOAAMI8RXTLwDUAAAOAAMI8RXTLwDUAAAqAAQKfxgAAw4ACAgeGipPAHMBAA4ACAgeGipPAHMBABwABAgSCIUuAHwAAAAA.',['丨摩']='丨摩托罗拉丨:BAABKgAFFH8LAAIBAAYImRCjBABuAQABAAYImRCjBABuAQAAAA==.',['丨空']='丨空丶白丨:BAAAKgADCgUIBQAAAA==.',['丨铁']='丨铁灬:BAAAKgAECgcICAAAAA==.',['丨青']='丨青柠:BAAAKgAECgQIBAAAAA==.',['临光']='临光:BAABKgAFFH8MAAIJAAYIXCVOBQDnAQAJAAYIXCVOBQDnAQAAAA==.',['丶丶']='丶丶牧诗:BAAAKgAECgYIBwAAAA==.',['丶陆']='丶陆小凤丶:BAAAKgADCgMIAwAAAA==.',['丹娜']='丹娜丶:BAAAKgAECggICAAAAA==.',['为了']='为了伊利达雷:BAAAKgAECgIIAgAAAA==.',['丿浮']='丿浮生丶若梦:BAAAKgADCggIBAAAAA==.',['乀刀']='乀刀来:BAABKgAFFH8UAAIZAAYIjR5NCgAjAQAZAAYIjR5NCgAjAQAAAA==.',['乌鸡']='乌鸡白缝丸:BAAAKgAECgQIBAAAAA==.',['乌鹃']='乌鹃:BAAAKgAECgUIBgAAAA==.',['乔治']='乔治克鲁尼丶:BAAAKgAECgIIAgAAAA==.',['乔碧']='乔碧萝乔斯塔:BAAAKgAECgMIAwAAAA==.',['九尾']='九尾灵狐:BAAAKgAECgUIDAAAAA==.',['九幽']='九幽荒梦:BAAAKgAECgIIAgAAAA==.九幽黄光:BAAAKgAECgYIBgAAAA==.',['乱步']='乱步天下:BAAAKgAECgEIAQAAAA==.',['亂神']='亂神者拉斯:BAAAKgAECgIIAgAAAA==.',['了事']='了事了了:BAAAKgAECgYICAAAAA==.',['二十']='二十一丶:BAAAKgADCggICgAAAA==.',['云旗']='云旗:BAACKgAFFH8nAAIGAAQILh2+DQAEAQAGAAQILh2+DQAEAQAqAAQKfxkAAgYABAjYIQIyAGUBAAYABAjYIQIyAGUBAAAA.',['云过']='云过长空:BAABKgAFFH8MAAQKAAYI+x35AADpAQAKAAYIdRr5AADpAQALAAUIgCAXEAAyAQAYAAEIViMpJwBYAAAAAA==.',['五五']='五五开彦祖:BAAAKgAECggICwAAAA==.',['五十']='五十块大肠面:BAAAKgAFFAQIBAAAAA==.',['些许']='些许期待:BAAAKgADCgcIBwAAAA==.',['亡语']='亡语:BAAAKgAECggICAABKgAFFAgIDQAIAOEYAA==.',['仿生']='仿生泪滴:BAABKgAECn8UAAMZAAcIxBfdPgCtAQAZAAcIxBfdPgCtAQAdAAMIrhHUUwB1AAAAAA==.',['会炒']='会炒蛋炒饭:BAAAKgAFFAMIAwAAAA==.',['伤情']='伤情绝唱:BAABKgAFFH8NAAIMAAgI4ws6CACTAQAMAAgI4ws6CACTAQAAAA==.',['佐维']='佐维:BAABKgAFFH8GAAIeAAYIMwpYDwBcAQAeAAYIMwpYDwBcAQAAAA==.',['余晓']='余晓曼:BAACKgAFFH8SAAMGAAQIuCZMEwDrAAAGAAMI+SZMEwDrAAAFAAEIOCa5FABuAAAqAAQKfycAAwYACAhJJjMoAOwBAAYABgh7JjMoAOwBAAUAAwjQJf8tAE0BAAAA.',['你不']='你不要呱呱叫:BAABKgAECn8lAAMTAAgITRhzDQClAQATAAgI4RVzDQClAQANAAgIaBWlCACiAQAAAA==.',['你家']='你家张三爷:BAAAKgAECgEIAQAAAA==.',['你是']='你是猪儿虫吧:BAABKgAFFH8IAAIJAAgIvwQODgAcAQAJAAgIvwQODgAcAQAAAA==.',['佰捌']='佰捌恼風:BAAAKgAFFAIIAgAAAA==.',['侑点']='侑点小变态:BAAAKgAECgQIBQAAAA==.',['依然']='依然丶非死的:BAACKgAFFH8JAAMbAAUIQB6/DQAYAQAbAAQIzSK/DQAYAQARAAEIlxDRTABLAAAqAAQKfykAAxEACAjPGgcNAP8BABEACAjPGgcNAP8BABsABQjvDXS1ALkAAAAA.',['依莫']='依莫:BAAAKgAECgcIBwAAAA==.',['便便']='便便牛:BAAAKgAFFAIIBAAAAA==.',['假装']='假装很牛:BAAAKgAECgEIAQAAAA==.',['傳説']='傳説中的魚:BAABKgAFFH8YAAMaAAYIFSMxAwDQAQAaAAYIFSMxAwDQAQAQAAYIxRk7FABDAQAAAA==.',['傻意']='傻意:BAAAKgAECggICAAAAA==.',['像風']='像風一样自由:BAAAKgADCgIIAgAAAA==.',['光影']='光影之沫:BAAAKgAECgQIBAAAAA==.',['兰斯']='兰斯洛特:BAABKgAFFH8IAAIIAAgIEQmdEgDIAQAIAAgIEQmdEgDIAQAAAA==.',['再闹']='再闹我弄你哦:BAAAKgAFFAYIBAAAAA==.',['冥海']='冥海无岸:BAAAKgAECggIDwAAAA==.',['冰镇']='冰镇口辣:BAAAKgAECgIIAgAAAA==.',['冷若']='冷若霜:BAAAKgAECgMIAwAAAA==.',['凉森']='凉森玲梦:BAAAKgAFFAIIAgAAAA==.',['凶猛']='凶猛肥宅:BAACKgAFFH8IAAIFAAMIBwyTGgC2AAAFAAMIBwyTGgC2AAAqAAQKfx8AAgUACAgdFLEjAJkBAAUACAgdFLEjAJkBAAAA.',['刀锋']='刀锋偏冷:BAAAKgAFFAgIBAAAAA==.',['初代']='初代彦祖:BAAAKgAECgEIAQAAAA==.',['别来']='别来春半:BAAAKgAECgIIAgAAAA==.',['劣人']='劣人丶:BAAAKgAECgEIAQAAAA==.',['北灬']='北灬风:BAAAKgAFFAMIAwAAAA==.',['北风']='北风之阁:BAABKgAFFH8IAAIFAAgI9hLIAwAXAgAFAAgI9hLIAwAXAgAAAA==.',['十九']='十九号还房贷:BAAAKgADCgEIAQAAAA==.',['千鹤']='千鹤:BAAAKgAECgMIAwAAAA==.',['卅鲁']='卅鲁法尔大王:BAAAKgAECgEIAQAAAA==.',['半夏']='半夏长卿:BAAAKgAECgMIBAAAAA==.',['半盏']='半盏烟火:BAAAKgADCggICAAAAA==.',['单庸']='单庸:BAAAKgAFFAQIBAABKgAFFAgICAAQAHYJAA==.',['南征']='南征北戦灬:BAABKgAFFH8GAAISAAIIWxTQEgCYAAASAAIIWxTQEgCYAAABKgAFFAgIFQAXAEUeAA==.',['厕所']='厕所真有蚊子:BAAAKgAECggICAAAAA==.',['厚礼']='厚礼蟹:BAAAKgAECgQIBwAAAA==.',['去哪']='去哪儿浪:BAAAKgAECgYIBwAAAA==.',['双刀']='双刀在手:BAAAKgADCggIEgAAAA==.',['只会']='只会惩击:BAABKgAFFH8GAAIKAAYIqxDOCwBYAQAKAAYIqxDOCwBYAQAAAA==.',['可可']='可可格鲁:BAABKgAFFH8LAAIOAAUIkxqzGgBEAQAOAAUIkxqzGgBEAQAAAA==.',['叶师']='叶师父:BAACKgAFFH8XAAIMAAMIXxrDEwDZAAAMAAMIXxrDEwDZAAAqAAQKfx8AAgwACAhFECBfACIBAAwACAhFECBfACIBAAAA.',['吃口']='吃口小肥:BAAAKgAECgEIAQAAAA==.',['后知']='后知后觉的:BAAAKgAFFAQIBAAAAA==.',['君一']='君一:BAABKgAFFH8MAAMLAAYIiBKDCwAUAQALAAYIiBKDCwAUAQAYAAIINCPlHgBxAAAAAA==.',['听君']='听君一席话:BAAAKgADCgEIAQAAAA==.',['启下']='启下:BAAAKgADCgQIBAAAAA==.',['吴彦']='吴彦組:BAABKgAFFH8GAAIZAAYI4xNTEgBqAQAZAAYI4xNTEgBqAQAAAA==.',['咆哮']='咆哮丶讚歌:BAAAKgAECgYIBgAAAA==.咆哮的薇薇安:BAABKgAFFH8FAAIIAAQIkhWNIwDZAAAIAAQIkhWNIwDZAAAAAA==.',['咔滋']='咔滋脆鸡腿堡:BAAAKgAFFAIIAwAAAA==.',['咕咕']='咕咕茶:BAABKgAFFH8KAAMOAAYIFxwoEwCDAQAOAAYIFxwoEwCDAQAVAAQIWAnTJwCGAAABKgAFFAgIBAAfAAAAAA==.',['咕噜']='咕噜咕噜牛:BAABKgAECn8YAAIbAAcImBDrdgBQAQAbAAcImBDrdgBQAQAAAA==.',['咻就']='咻就是一箭:BAAAKgAECggIDAAAAA==.',['哈基']='哈基米快上啊:BAAAKgAECgUICQAAAA==.',['哥哥']='哥哥好痛啊:BAAAKgAECgYIBgAAAA==.',['唐有']='唐有虞:BAAAKgAECgUIBQAAAA==.',['唔得']='唔得翻顺德:BAACKgAFFH8UAAMOAAUIXBeEFAB2AQAOAAUIXBeEFAB2AQAVAAMI0BKyDgCmAAAqAAQKfxoAAw4ABwj4GfY2AN0BAA4ABwj4GfY2AN0BABUAAQj+EtiEADYAAAEqAAUUCAgGACAAhwwA.',['啊呜']='啊呜喵:BAACKgAFFH8eAAMGAAQI+RN0DwD9AAAGAAQI+RN0DwD9AAAHAAMIaQbHEAB3AAAqAAQKfyEAAgcACAjWDlgfAAgBAAcACAjWDlgfAAgBAAAA.',['啊尔']='啊尔肥诺:BAACKgAFFH8eAAIgAAgI8BuVDACbAQAgAAgI8BuVDACbAQAqAAQKfxwAAiAACAi6JHsCAMcCACAACAi6JHsCAMcCAAAA.',['喜欢']='喜欢夜的黑:BAAAKgAECgQIBAAAAA==.',['嗜酒']='嗜酒乄淡淡:BAAAKgAECggICAAAAA==.',['嗨土']='嗨土豆:BAABKgAECn8bAAQPAAgIcBJIMQBlAQAPAAcIbhRIMQBlAQABAAMIEQpGbwCLAAAhAAII+QZBJQA8AAAAAA==.',['噗噗']='噗噗:BAAAKgAFFAEIAQAAAA==.',['嚣张']='嚣张小熊喵:BAABKgAFFH8SAAMBAAYIlSOGBQD2AQABAAYIlSOGBQD2AQAPAAQIuwTVEACqAAAAAA==.',['四不']='四不像:BAABKgAFFH8VAAMOAAYIHR+qEQCRAQAOAAYIHR+qEQCRAQAVAAYIMQsKEgAPAQABKgAFFAgIUAAOABcmAA==.',['因迪']='因迪斯:BAAAKgADCgMIAwAAAA==.',['国服']='国服第一女警:BAAAKgAECgMIAwAAAA==.',['圣丶']='圣丶光神:BAAAKgAFFAQIBAAAAA==.',['圣光']='圣光关我屁事:BAAAKgAECgUIBQAAAA==.',['地域']='地域咆哮钢蹦:BAABKgAECn8eAAIGAAYI2RzaNQCoAQAGAAYI2RzaNQCoAQAAAA==.',['地板']='地板小飞机:BAACKgAFFH8IAAMTAAQIYBUnMwDJAAATAAQIYBUnMwDJAAANAAEI9QLQNQAcAAAqAAQKfxkAAhMABwhpGi9CAKkBABMABwhpGi9CAKkBAAAA.',['夏目']='夏目友人:BAAAKgAFFAQIBAAAAA==.',['多多']='多多良小傘:BAACKgAFFH8eAAQLAAQI4x3JFgD/AAALAAMI4x3JFgD/AAAKAAQIdQJyLQBhAAAYAAIIvwQQGABWAAAqAAQKfyIAAgsACAimGi4gAMMBAAsACAimGi4gAMMBAAAA.',['夜幕']='夜幕进行曲:BAAAKgADCggICAAAAA==.',['夜空']='夜空的寂寞:BAAAKgAECgcIDgAAAA==.',['夜紫']='夜紫:BAACKgAFFH8IAAIBAAMIKAw2IwCWAAABAAMIKAw2IwCWAAAqAAQKfxoAAgEACAhPFnwyAIIBAAEACAhPFnwyAIIBAAAA.',['夢路']='夢路步:BAABKgAECn8WAAMKAAYIsCVKFgASAgAKAAYIsCVKFgASAgALAAEIkh1/iABOAAABKgAFFAMIFAABAC8kAA==.',['大仙']='大仙幺幺:BAAAKgADCgUIBQAAAA==.',['大壮']='大壮牛:BAAAKgAECggIEgAAAA==.',['大天']='大天二:BAABKgAFFH8RAAMRAAYIGR0sDACVAQARAAYIGR0sDACVAQAbAAYI7wv9GgApAQAAAA==.',['大耳']='大耳后知慕斯:BAAAKgAFFAYIBAAAAA==.',['大跳']='大跳释放:BAAAKgAFFAEIAQAAAA==.',['天雪']='天雪之楠:BAABKgAFFH8GAAIgAAYIVw/dEwAyAQAgAAYIVw/dEwAyAQAAAA==.',['太寿']='太寿鸠毛:BAAAKgAFFAQIBAAAAA==.',['奈飞']='奈飞天:BAABKgAFFH8FAAIMAAUIwgNOGgClAAAMAAUIwgNOGgClAAAAAA==.',['奔放']='奔放小靑年丶:BAAAKgAECgMIAwAAAA==.',['奥利']='奥利波斯猎:BAABKgAFFH8TAAMRAAYI1By9AADSAQARAAYIzhu9AADSAQAbAAQIexrXFQD3AAAAAA==.',['奥术']='奥术哀嚎:BAAAKgADCgUIBQAAAA==.',['奥黛']='奥黛丽丶赫夲:BAAAKgADCgQIBAAAAA==.',['奶瓶']='奶瓶:BAAAKgAECgQIBAAAAA==.',['奶的']='奶的全过量:BAAAKgAECgUIBgAAAA==.',['妖四']='妖四四:BAABKgAECn8pAAMRAAgIrCaHAAAbAwARAAgIrCaHAAAbAwAbAAIIrR8QvACsAAAAAA==.',['妖肆']='妖肆肆:BAABKgAECn8bAAMTAAgI4COYFACFAgATAAgIqCGYFACFAgAiAAgILiHrCgD3AQABKgAFFAgIDQAIAOEYAA==.',['姬哥']='姬哥:BAAAKgAECgcIBwAAAA==.',['娜宝']='娜宝宝:BAABKgAECn8VAAIGAAgIRRKjKQCUAQAGAAgIRRKjKQCUAQAAAA==.',['嫣外']='嫣外月:BAAAKgAFFAgIBAAAAA==.',['孤魂']='孤魂祭长夜:BAAAKgAECgYIEQAAAA==.',['守夜']='守夜冠军:BAAAKgADCgMIAwAAAA==.',['安西']='安西路:BAABKgAFFH8IAAIOAAgIaBSnCQD7AQAOAAgIaBSnCQD7AQAAAA==.',['完颜']='完颜红猎:BAAAKgADCgYIBgAAAA==.',['宵暗']='宵暗的镇魂歌:BAAAKgADCgUIBQAAAA==.',['寂寞']='寂寞丶小強:BAACKgAFFH8KAAIbAAMIzxw3FgDdAAAbAAMIzxw3FgDdAAAqAAQKfysAAxsACAieJAwHAOkCABsACAieJAwHAOkCACMAAwg7EdESALsAAAAA.',['富贵']='富贵喀拉峻:BAAAKgAECggIDAAAAA==.',['寒涵']='寒涵喊憨汗旱:BAABKgAFFH8GAAITAAYIbxnSEACVAQATAAYIbxnSEACVAQAAAA==.',['寒風']='寒風亂舞:BAAAKgAECggICAAAAA==.',['小兰']='小兰妞:BAAAKgAECgQIBAAAAA==.',['小小']='小小审判:BAAAKgADCggICAAAAA==.',['小巴']='小巴哥咯:BAAAKgAECggICAAAAA==.',['小柚']='小柚子:BAAAKgAECgUICwAAAA==.',['小泰']='小泰泰迪丶:BAAAKgAECgYIDAAAAA==.',['小猫']='小猫猫:BAAAKgAECgIIAgABKgAFFAMIDwAMAKcQAA==.',['小胸']='小胸器:BAAAKgAECggICAAAAA==.',['小茶']='小茶狐:BAAAKgAECggIBwAAAA==.',['尐乊']='尐乊寶:BAABKgAFFH8IAAIVAAQI9w+cDQDDAAAVAAQI9w+cDQDDAAAAAA==.',['尤迪']='尤迪利丹:BAAAKgAECgIIAgAAAA==.',['尸主']='尸主有礼:BAACKgAFFH8aAAQbAAMIaQsbRwCGAAAbAAMI6wgbRwCGAAAjAAIISQOQAwBqAAARAAII0QuqIQBlAAAqAAQKfyAABBsACAilDSh8AEEBABsABwivDih8AEEBACMAAwgHCfQSAI4AABEAAwjJCIWAAEoAAAAA.',['山啊']='山啊边是海:BAAAKgADCgEIAQAAAA==.',['山德']='山德鲁:BAAAKgAECgYIBgAAAA==.',['岁月']='岁月不催人:BAAAKgAECgUIBQAAAA==.',['巨无']='巨无霸丶:BAAAKgAECgEIAQAAAA==.',['布洛']='布洛芬的悲伤:BAABKgAECn8aAAIIAAcIwBe5MwBBAQAIAAcIwBe5MwBBAQAAAA==.',['帅克']='帅克虎:BAAAKgAECgYICAAAAA==.',['帅到']='帅到被人狂抡:BAABKgAFFH8KAAIHAAYIJRE0BgARAQAHAAYIJRE0BgARAQAAAA==.',['帝血']='帝血乄弑天:BAABKgAFFH8PAAQiAAYIOh7XAgCeAQAiAAYIex3XAgCeAQATAAQIwhpnLQDZAAANAAUIoxLRJACFAAAAAA==.',['年糕']='年糕是大魔王:BAAAKgAECgQIBAAAAA==.',['庐山']='庐山升龙霸:BAAAKgAFFAgIAQAAAA==.',['张八']='张八百:BAABKgAFFH8JAAIZAAMIhgvvGgC5AAAZAAMIhgvvGgC5AAAAAA==.',['张尔']='张尔摩斯:BAAAKgAECgYIBgAAAA==.',['张锦']='张锦小笨蛋:BAAAKgAFFAQIBAAAAA==.',['弥生']='弥生:BAABKgAFFH8LAAIJAAYIwBpyCQBpAQAJAAYIwBpyCQBpAQABKgAFFAgIAgAfAAAAAA==.',['德罗']='德罗玛萨:BAAAKgAECgMIAwAAAA==.',['心怀']='心怀热爱:BAAAKgADCggICAAAAA==.',['心自']='心自飘零:BAAAKgADCgUIBQAAAA==.',['性感']='性感小姨妈:BAAAKgAECgQIBwAAAA==.性感小牛奶:BAAAKgAECgQIBAAAAA==.',['怼死']='怼死你:BAAAKgAFFAMIAwAAAA==.',['恶魔']='恶魔七世:BAAAKgAFFAEIAQAAAA==.',['情人']='情人节限定版:BAABKgAECn8YAAIDAAgIwRaCHgC1AQADAAgIwRaCHgC1AQAAAA==.',['惊奇']='惊奇脆皮哥:BAAAKgAECgMIAwAAAA==.',['惊鸿']='惊鸿第一僧:BAAAKgAECgYIBgAAAA==.惊鸿第一术:BAAAKgAECgQIBgAAAA==.惊鸿第一瞎:BAAAKgAECgQIBAAAAA==.',['愇心']='愇心:BAAAKgADCgEIAQAAAA==.',['我叫']='我叫陈九九:BAAAKgAECggICAAAAA==.',['我想']='我想想办法:BAABKgAECn8fAAMZAAgIJhrwKQAPAgAZAAgIJhrwKQAPAgAdAAIITBU+UwB3AAAAAA==.',['我爱']='我爱蓝色:BAABKgAFFH8GAAIJAAYIcRVrCwBBAQAJAAYIcRVrCwBBAQAAAA==.',['战十']='战十年:BAABKgAFFH8GAAIdAAQIDBI/CADFAAAdAAQIDBI/CADFAAAAAA==.',['战神']='战神小狼:BAAAKgAECggIEAAAAA==.',['戰無']='戰無不勝:BAABKgAFFH8KAAMNAAgIYw5yBACvAQANAAgIhQtyBACvAQATAAIIxhHePwCeAAAAAA==.',['所爱']='所爱隔山海:BAAAKgAECgYIBgAAAA==.',['扎西']='扎西顿珠:BAAAKgAECgIIAgAAAA==.',['承遥']='承遥:BAAAKgAFFAIIAgAAAA==.',['把妹']='把妹王:BAABKgAFFH8MAAIPAAYI3grMBwBJAQAPAAYI3grMBwBJAQAAAA==.',['抰教']='抰教授之吻:BAAAKgADCgEIAQAAAA==.',['拉粑']='拉粑粑小摸仙:BAABKgAECn8UAAMRAAgISRENKgCVAQARAAgIyRANKgCVAQAbAAIIBAYe9ABMAAAAAA==.',['拉面']='拉面大师:BAAAKgAECgEIAQAAAA==.',['探手']='探手花丛间:BAABKgAFFH8HAAIeAAYIcRBzCQDAAQAeAAYIcRBzCQDAAQAAAA==.',['搞哥']='搞哥:BAABKgAFFH8VAAIMAAgIqxSmDACBAQAMAAgIqxSmDACBAQAAAA==.',['撸死']='撸死人不偿命:BAAAKgAECgcICAAAAA==.',['放个']='放个治疗链:BAACKgAFFH8JAAMMAAUIMBWJDwAHAQAMAAUIMBWJDwAHAQAXAAEIUwdoGAAxAAAqAAQKfxoAAgwACAgTJLsCAMUCAAwACAgTJLsCAMUCAAAA.',['敖隐']='敖隐:BAAAKgAFFAgIBAAAAA==.',['散不']='散不开的雾:BAAAKgAFFAQIBAAAAA==.',['斥吼']='斥吼:BAAAKgAECggICAAAAA==.',['断禁']='断禁舞步:BAAAKgAECgcICwABKgAECgcIFAAZAMQXAA==.',['斯卡']='斯卡布罗集市:BAAAKgAECgIIAgAAAA==.',['无敌']='无敌炉石哈哈:BAAAKgAECgIIAgAAAA==.',['无知']='无知的哈士奇:BAAAKgAECgcICgAAAA==.',['无量']='无量天尊:BAAAKgADCgEIAQAAAA==.',['日落']='日落肆拾肆:BAAAKgADCgcIBwAAAA==.',['时机']='时机已到:BAAAKgAFFAMIAwAAAA==.',['明弦']='明弦音:BAAAKgADCgYIBgAAAA==.',['星之']='星之守护者:BAAAKgADCgIIAgAAAA==.',['星痕']='星痕若雪:BAAAKgAECggICQABKgAFFAMIDwAMAKcQAA==.',['春日']='春日部小新:BAAAKgAECggICAAAAA==.',['是非']='是非不成:BAABKgAECn8dAAIIAAYIUB7+KQB7AQAIAAYIUB7+KQB7AQAAAA==.',['晓星']='晓星:BAACKgAFFH8SAAMLAAUIkhN6FAAQAQALAAUIkhN6FAAQAQAKAAEIKQjkNAAxAAAqAAQKfxgAAwsACAjyIKcOAFYCAAsACAhLIKcOAFYCAAoACAiXFqUhAL0BAAAA.',['晨与']='晨与橙与城:BAAAKgAFFAgIAgAAAA==.',['暗尘']='暗尘随去:BAABKgAECn8WAAIbAAgIlRdkMwDaAQAbAAgIlRdkMwDaAQAAAA==.',['暗矛']='暗矛追猎者:BAAAKgADCgUIBQAAAA==.',['暴打']='暴打小朋友丶:BAAAKgAECgMIAwAAAA==.暴打幼儿园丶:BAAAKgAECggIEAAAAA==.暴打柠檬茶:BAAAKgADCggICAAAAA==.',['暴躁']='暴躁可乐:BAAAKgAFFAIIBAAAAA==.暴躁天秤座:BAAAKgADCgYIBgAAAA==.暴躁太极:BAAAKgAECgQIBQAAAA==.暴躁茶杯:BAAAKgAECgEIAQAAAA==.暴躁诗人心:BAAAKgAECgMIAwAAAA==.暴躁阎王:BAAAKgAFFAEIAQAAAA==.',['曲奇']='曲奇餅乾:BAABKgAFFH8KAAIQAAgIghnZBABQAgAQAAgIghnZBABQAgAAAA==.',['月下']='月下花魂:BAAAKgAECgIIAwAAAA==.',['月遇']='月遇从云:BAABKgAFFH8IAAITAAYIrhqwCQDxAQATAAYIrhqwCQDxAQAAAA==.',['月雅']='月雅儿:BAAAKgAFFAQIAgABKgAFFAgIIAALADMhAA==.',['月音']='月音瞳:BAAAKgAECggIDwAAAA==.',['朗姆']='朗姆酒:BAAAKgAFFAIIAgAAAA==.',['朝廷']='朝廷心腹大患:BAABKgAECn8eAAMRAAgIWR4KGAAQAgARAAgIYx0KGAAQAgAbAAYIdh6MZgB+AQAAAA==.',['末曰']='末曰审判丶:BAAAKgAECgYIBgAAAA==.',['本子']='本子:BAAAKgAECgMIAwAAAA==.',['朵拉']='朵拉斯丶怒风:BAAAKgAECgMIBQAAAA==.',['束缚']='束缚枷锁:BAAAKgADCgEIAQAAAA==.',['来个']='来个猛的哈:BAAAKgAFFAQIBAABKgAFFAgICAAOACwLAA==.',['枫岚']='枫岚:BAAAKgADCgcIBwAAAA==.',['枫猫']='枫猫:BAAAKgAECgEIAQAAAA==.',['柯基']='柯基摇輪椅:BAABKgAFFH8MAAINAAgIbxHuBgC5AQANAAgIbxHuBgC5AQAAAA==.',['梓涵']='梓涵酱爱吃糖:BAAAKgAECgMIAwAAAA==.',['樱花']='樱花好看不:BAAAKgAFFAQIBAAAAA==.',['橙汁']='橙汁三分糖:BAAAKgAECgEIAQAAAA==.',['橙色']='橙色八月:BAAAKgAFFAEIAQAAAA==.',['欢乐']='欢乐河马:BAAAKgADCgYIBgAAAA==.',['正义']='正义阿婆杀手:BAAAKgAECgYIBgAAAA==.',['武二']='武二娘:BAAAKgAFFAMIAwAAAA==.',['歪嘞']='歪嘞歪嘞:BAABKgAFFH8GAAIDAAYIPQ+lFwBHAQADAAYIPQ+lFwBHAQAAAA==.',['死亡']='死亡天降:BAABKgAFFH8GAAMTAAQIQhJnHgAsAQATAAQIEBBnHgAsAQANAAIIEwtaJgB9AAAAAA==.',['死后']='死后迷万人:BAAAKgAECgQIBQAAAA==.',['残尸']='残尸败蜕:BAAAKgAECgYIBgAAAA==.',['毁灭']='毁灭死灵:BAABKgAFFH8LAAIEAAYIvB5vAQCzAQAEAAYIvB5vAQCzAQAAAA==.',['毒奶']='毒奶很贴心:BAAAKgAECgUIBgAAAA==.',['毕方']='毕方之炎:BAABKgAFFH8FAAIIAAMIIhuoXwCxAAAIAAMIIhuoXwCxAAAAAA==.',['氵昆']='氵昆氵屯之主:BAAAKgAFFAgIBAAAAA==.',['污垢']='污垢女王的胸:BAABKgAFFH8JAAITAAQI3hs2EQD0AAATAAQI3hs2EQD0AAAAAA==.',['沉锋']='沉锋:BAAAKgADCgYIBgAAAA==.',['没事']='没事吃芒果:BAAAKgAECggICgAAAA==.',['没落']='没落的小牛:BAAAKgAECgYIDwAAAA==.',['沫柠']='沫柠:BAAAKgAFFAYIBAAAAA==.',['泡沫']='泡沫:BAAAKgAECgcIBwAAAA==.',['波比']='波比大王:BAABKgAFFH8MAAIeAAgIcR4dBQAvAQAeAAgIcR4dBQAvAQAAAA==.',['泰蘭']='泰蘭德語風:BAABKgAFFH8IAAIbAAgIlhGOBwAGAgAbAAgIlhGOBwAGAgAAAA==.',['流風']='流風回雪:BAAAKgAECgYIBgAAAA==.',['浅夏']='浅夏王:BAAAKgADCgMIAwAAAA==.',['浮光']='浮光初槿花落:BAAAKgAFFAQIBAAAAA==.',['涵酱']='涵酱:BAAAKgAECgMIBgAAAA==.',['淡淡']='淡淡红印:BAAAKgADCggICAAAAA==.',['淡然']='淡然若水丶:BAABKgAFFH8GAAIIAAYIORJgIABuAQAIAAYIORJgIABuAQAAAA==.',['深寒']='深寒魇魔:BAAAKgAFFAgIAgAAAA==.',['深蓝']='深蓝梦境:BAAAKgADCgYIBgAAAA==.',['混口']='混口丨饭吃丶:BAACKgAFFH8QAAIRAAMIORfGFAC+AAARAAMIORfGFAC+AAAqAAQKfz4AAhEACAgaJPoCANACABEACAgaJPoCANACAAAA.',['清桐']='清桐晖:BAABKgAECn8aAAIIAAgIqiNrGQCyAgAIAAgIqiNrGQCyAgAAAA==.',['温皇']='温皇丶任飘渺:BAACKgAFFH8iAAMVAAYI6BMkCgBlAQAVAAYI6BMkCgBlAQAOAAEIuwt1OABBAAAqAAQKfxkAAxUACAhUG8keANABABUACAhUG8keANABAA4ABAj9FZxpACABAAAA.',['湛蓝']='湛蓝灬书恒:BAAAKgAECgQIEgAAAA==.湛蓝犄角:BAAAKgAECggIDwAAAA==.',['溜溜']='溜溜球:BAAAKgAFFAIIAwAAAA==.',['满地']='满地都是烟火:BAAAKgAECgYIBgAAAA==.',['演起']='演起来:BAAAKgAECgIIAgAAAA==.',['潶色']='潶色天空:BAACKgAFFH8IAAIaAAMIBAi3FwB6AAAaAAMIBAi3FwB6AAAqAAQKfx8AAxoACAhfGXwoANoBABoACAhfGXwoANoBABQAAgjeDypKADAAAAAA.',['火烧']='火烧云:BAAAKgAECgMIAwAAAA==.',['火靈']='火靈児丶:BAABKgAECn8fAAIeAAgImB33CgBXAgAeAAgImB33CgBXAgAAAA==.',['火鸡']='火鸡味大锅巴:BAABKgAFFH8GAAMgAAMIhwwIFgC4AAAgAAMIhwwIFgC4AAAkAAII8gioBgBaAAAAAA==.',['烟雨']='烟雨苍穹:BAAAKgAECggICAAAAA==.',['熊了']='熊了个猫咪:BAAAKgAECgYIBgAAAA==.',['爆了']='爆了丶香蕉:BAACKgAFFH8ZAAQEAAQIIyFPBwDuAAAEAAMIUyBPBwDuAAACAAIIYSWUDwBoAAADAAEIVh98RwBMAAAqAAQKfycAAwQACAhfImcGABACAAQABgiAIGcGABACAAIABggaHmwfAIcBAAAA.',['爱吃']='爱吃大白兔:BAAAKgADCgYIBgAAAA==.',['爱插']='爱插才会赢:BAAAKgAECgIIAgAAAA==.',['牛奶']='牛奶年糕:BAAAKgAECgIIAgAAAA==.',['牛德']='牛德一哔:BAAAKgAECgUIBQAAAA==.',['牛村']='牛村保安经理:BAAAKgAFFAIIAgAAAA==.',['牛油']='牛油果骑士:BAABKgAECn8VAAIIAAgISRcIUQDLAQAIAAgISRcIUQDLAQAAAA==.',['特勆']='特勆普:BAAAKgAECgYIBgAAAA==.',['狂野']='狂野的阿昆达:BAAAKgAECggICAAAAA==.',['狂風']='狂風向前:BAAAKgAECgQIBAAAAA==.',['狂鳯']='狂鳯:BAAAKgAECgQICAAAAA==.',['狩云']='狩云霄:BAACKgAFFH8fAAIbAAUIvxe+FgD0AAAbAAUIvxe+FgD0AAAqAAQKfz0AAhsACAiVIZcmAFkCABsACAiVIZcmAFkCAAAA.',['独步']='独步圣光:BAABKgAFFH8IAAIIAAgIQhqZBQBrAgAIAAgIQhqZBQBrAgAAAA==.',['独行']='独行小牧:BAAAKgAECgMIBAAAAA==.',['猎麻']='猎麻人:BAAAKgAFFAIIAwAAAA==.',['猫丶']='猫丶熊:BAAAKgADCgIIAgAAAA==.',['玖月']='玖月沉沦:BAABKgAECn8bAAQLAAgINR3CHgDmAQALAAcIbR3CHgDmAQAKAAQIQxVtXACtAAAYAAII9Ro4VwCPAAAAAA==.',['玛咔']='玛咔巴卡:BAAAKgAECgEIAQAAAA==.',['瑞奇']='瑞奇:BAACKgAFFH8xAAIMAAcIqhmsBgC5AQAMAAcIqhmsBgC5AQAqAAQKf3gAAgwACAgHJXcFAMoCAAwACAgHJXcFAMoCAAAA.',['瑞莲']='瑞莲皇后:BAABKgAFFH8GAAIIAAYI6h3IFQCtAQAIAAYI6h3IFQCtAQAAAA==.',['甜妹']='甜妹也是咸的:BAAAKgAECgQIBAAAAA==.',['甜蜜']='甜蜜梦境:BAAAKgADCggICAAAAA==.',['生命']='生命之树:BAAAKgAECgQIBAAAAA==.',['疯狂']='疯狂灬打唔死:BAABKgAFFH8LAAMaAAYIcBnsBgBZAQAaAAYIcBnsBgBZAQAQAAMI/g5nKQC9AAAAAA==.',['白牙']='白牙哼哼:BAABKgAFFH8IAAIMAAgIFRTcBQD1AQAMAAgIFRTcBQD1AQAAAA==.',['白石']='白石优杞菜:BAAAKgAECggICAAAAA==.',['皮皮']='皮皮莽我们飞:BAAAKgADCggICAAAAA==.',['祐天']='祐天寺喵梦:BAAAKgAFFAEIAwABKgAFFAMIFAABAC8kAA==.',['神不']='神不知:BAAAKgAECgQIBgAAAA==.',['神幻']='神幻羽:BAAAKgADCgMIAwAAAA==.',['神志']='神志不清:BAABKgAECn8fAAMgAAgIdRPGLgBGAQAgAAgIdRPGLgBGAQAkAAEIogXKLAAfAAAAAA==.',['神珏']='神珏:BAAAKgAECggIEAAAAA==.',['神龍']='神龍大侠:BAABKgAECn8VAAIMAAgIUBX3YgACAQAMAAgIUBX3YgACAQAAAA==.',['福瑞']='福瑞控:BAAAKgADCggICAAAAA==.',['离骚']='离骚:BAAAKgADCgUIBQAAAA==.',['穆丿']='穆丿黑:BAAAKgADCggICAAAAA==.',['穿裙']='穿裙子跳芭蕾:BAABKgAECn8VAAIcAAgI8hINFwBIAQAcAAgI8hINFwBIAQAAAA==.',['童帝']='童帝:BAAAKgAECggICAAAAA==.',['笑到']='笑到死:BAAAKgADCgMIAwAAAA==.',['米吉']='米吉多拉翁:BAABKgAFFH8MAAIDAAgI1BEYBgASAgADAAgI1BEYBgASAgAAAA==.',['粗心']='粗心大意司机:BAABKgAFFH8KAAIOAAMIrwW6JACUAAAOAAMIrwW6JACUAAAAAA==.',['糊里']='糊里糊涂:BAAAKgAECggICAAAAA==.',['糖油']='糖油果子之怒:BAABKgAECn8dAAIMAAgIWRsxJwDjAQAMAAgIWRsxJwDjAQAAAA==.',['糖色']='糖色:BAAAKgAECgYIBgAAAA==.',['糖醋']='糖醋小排骨:BAAAKgAFFAgIAgAAAA==.',['紅茶']='紅茶獵師:BAAAKgAECgUIBwAAAA==.紅茶薔薇:BAAAKgAECgIIAgAAAA==.',['紫薯']='紫薯蛋挞:BAAAKgAECgcIBwAAAA==.',['红樱']='红樱:BAABKgAFFH8IAAITAAgI3hH5BgAkAgATAAgI3hH5BgAkAgAAAA==.',['红牌']='红牌妹:BAACKgAFFH8KAAIIAAUIpwwxJwBMAQAIAAUIpwwxJwBMAQAqAAQKfxQAAggACAhXGFdrAMIBAAgACAhXGFdrAMIBAAAA.',['红茶']='红茶流香:BAAAKgADCgEIAQAAAA==.',['纯屬']='纯屬虚构:BAAAKgAECgYIBQAAAA==.',['纸芮']='纸芮姐姐丶:BAAAKgADCgYIBgAAAA==.',['结城']='结城梨斗:BAABKgAECn8rAAMlAAgIjCH0AAB6AgAlAAgIjCH0AAB6AgAeAAMIVhcGMADcAAAAAA==.',['继续']='继续大号:BAAAKgAECgIIAgAAAA==.继续征程:BAAAKgAECggIDQAAAA==.',['维以']='维以不永伤:BAAAKgADCggICAAAAA==.',['羊刀']='羊刀加冰眼:BAAAKgAECgQIBQAAAA==.',['美滋']='美滋滋丶:BAAAKgAECgIIAgAAAA==.',['翎丨']='翎丨羽:BAABKgAFFH8FAAIbAAMIDg+7OwCtAAAbAAMIDg+7OwCtAAAAAA==.',['翔龍']='翔龍伏虎:BAAAKgAECggICAAAAA==.',['翡翠']='翡翠狮子:BAABKgAFFH8KAAIHAAYIOxq9AwBtAQAHAAYIOxq9AwBtAQAAAA==.',['联盟']='联盟首席萨满:BAAAKgADCggICAAAAA==.',['胆大']='胆大心细:BAAAKgADCgMIAwAAAA==.',['胖吨']='胖吨:BAAAKgAECgYIBgAAAA==.',['自由']='自由的小号:BAAAKgADCggIEAAAAA==.自由龙:BAAAKgAECgQIBAAAAA==.',['自闭']='自闭:BAAAKgAECgMIAwAAAA==.',['臭屁']='臭屁大王:BAACKgAFFH8vAAITAAgI9x9DAwBuAgATAAgI9x9DAwBuAgAqAAQKfygAAhMACAhZI+URAJcCABMACAhZI+URAJcCAAAA.臭屁小王子:BAAAKgADCggIDwAAAA==.',['至尊']='至尊圣牛士:BAABKgAECn8fAAIIAAgICRtuMwAxAgAIAAgICRtuMwAxAgAAAA==.',['至高']='至高:BAABKgAFFH8GAAISAAYILgd6DAADAQASAAYILgd6DAADAQAAAA==.',['艾小']='艾小乂:BAAAKgAFFAEIAQAAAA==.',['花槿']='花槿夜:BAAAKgAFFAQIBAAAAA==.',['苏苏']='苏苏的大胖子:BAABKgAFFH8GAAIRAAYIbwhXGwATAQARAAYIbwhXGwATAQAAAA==.',['苗条']='苗条的周医生:BAABKgAFFH8IAAIIAAgI6RV7CwAQAgAIAAgI6RV7CwAQAgAAAA==.',['若邪']='若邪:BAAAKgAECggICAAAAA==.',['范迪']='范迪塞尔牛能:BAAAKgAFFAQIBAAAAA==.',['茜茜']='茜茜小可爱:BAAAKgAFFAQIBAAAAA==.',['荒野']='荒野之枭:BAAAKgADCggICAAAAA==.',['荔枝']='荔枝沟游侠:BAAAKgAFFAEIAQAAAA==.荔枝沟阿龙:BAABKgAFFH8OAAIgAAUIYyGAEABZAQAgAAUIYyGAEABZAQAAAA==.',['荼蘼']='荼蘼:BAAAKgAECgQIAwAAAA==.',['莉絲']='莉絲:BAABKgAFFH8YAAIcAAMIUQn6CQBxAAAcAAMIUQn6CQBxAAAAAA==.',['莱欧']='莱欧斯利:BAABKgAFFH8GAAMYAAMICRcLFwCrAAAYAAMICRcLFwCrAAALAAEIPh3JIABSAAAAAA==.',['菌株']='菌株宝宝:BAAAKgAECgUIBQAAAA==.',['菜鸡']='菜鸡阿婆杀手:BAAAKgAFFAIIAwAAAA==.',['菲尔']='菲尔云娜灬:BAAAKgAECgYIDwAAAA==.',['菲菲']='菲菲霏霏:BAAAKgADCggIEAAAAA==.',['萌丶']='萌丶呆呆:BAABKgAFFH8GAAIJAAYI4RjQCQBhAQAJAAYI4RjQCQBhAQAAAA==.',['萤扰']='萤扰:BAACKgAFFH8hAAQVAAYIbRJ/DwAkAQAVAAYIbRJ/DwAkAQAOAAMI3AjaQACoAAAcAAIIKgxwBwBTAAAqAAQKfyEAAhUACAgBIiILAHwCABUACAgBIiILAHwCAAAA.',['萧雯']='萧雯:BAABKgAFFH8KAAMDAAYIaxgnEgB3AQADAAYIaxgnEgB3AQAEAAEIAAB1KQAAAAAAAA==.',['萨满']='萨满开英勇:BAAAKgAFFAgIBAAAAA==.',['落叶']='落叶灬舞:BAABKgAFFH8JAAMlAAYIYxFABwD2AAAlAAQI4xRABwD2AAAeAAUIuA8AAAAAAAABKgAFFAgICAAeAP8VAA==.落叶红秋丶:BAAAKgAFFAIIAgAAAA==.',['葉师']='葉师父:BAABKgAFFH8KAAIBAAgImxPMBwC3AQABAAgImxPMBwC3AQAAAA==.',['葬爱']='葬爱灬殺少:BAAAKgAFFAIIAgAAAA==.',['葬送']='葬送的芙莉莲:BAAAKgAECggIDQAAAA==.',['蒂血']='蒂血哀嚎:BAAAKgAECggICQAAAA==.',['蓝印']='蓝印雨:BAAAKgAECggICAAAAA==.',['蓝梅']='蓝梅尔:BAACKgAFFH8iAAMeAAgIuR/LEQA1AQAeAAYIOiDLEQA1AQAlAAMIwBnQCgCvAAAqAAQKfyoABCUACAitJBMTAL4BACUABQg8IRMTAL4BAB4ABQhuI2QeAIwBACYAAQhdFyUZAEYAAAAA.',['薛定']='薛定谔的熊德:BAAAKgAFFAIIAgAAAA==.',['血疾']='血疾:BAAAKgAECgUIBQAAAA==.',['血色']='血色娇花:BAAAKgAECgQIBAAAAA==.血色尾巴:BAAAKgAECgQIBAAAAA==.',['被光']='被光晕气晕:BAAAKgADCggICAAAAA==.',['调皮']='调皮的一个人:BAAAKgAECgYIDgAAAA==.',['赤壁']='赤壁怀古:BAAAKgADCgEIAQAAAA==.',['赤手']='赤手破空拳:BAABKgAFFH8GAAIBAAYIIA7eDwAvAQABAAYIIA7eDwAvAQAAAA==.',['赤水']='赤水断苍山:BAABKgAFFH8JAAIZAAYI4xXCAgC9AQAZAAYI4xXCAgC9AQABKgAFFAgIDAAZADUhAA==.',['赵旺']='赵旺:BAAAKgAECgEIAQAAAA==.',['起床']='起床不叠被子:BAABKgAFFH8GAAIaAAYIhhsOBAClAQAaAAYIhhsOBAClAQAAAA==.',['超强']='超强力嘲讽脸:BAAAKgAECgMIBAAAAA==.',['超科']='超科学电磁炮:BAAAKgAECgcIDQAAAA==.',['超级']='超级变变:BAAAKgAECgEIAQAAAA==.',['趾高']='趾高气杨:BAABKgAFFH8IAAIIAAQI1Rc5FwD+AAAIAAQI1Rc5FwD+AAABKgAFFAgICgAIAK0lAA==.',['跟风']='跟风练的:BAAAKgADCgMIAwAAAA==.',['跨越']='跨越七海的风:BAAAKgAFFAQIBAAAAA==.',['轻奢']='轻奢嘶吼:BAAAKgAECgIIAgAAAA==.',['轻盈']='轻盈小胖子:BAABKgAFFH8qAAMDAAgIgSNpAwCQAQADAAgIgSNpAwCQAQAEAAUI4hvRAwBSAQAAAA==.',['轻风']='轻风细語:BAAAKgAFFAgIBAAAAA==.',['近战']='近战转目标:BAABKgAFFH8QAAIIAAMI+RMaUQDNAAAIAAMI+RMaUQDNAAAAAA==.',['这是']='这是个啥:BAAAKgADCgMIAwAAAA==.',['这条']='这条街最凉仔:BAAAKgAECgEIAQAAAA==.',['进击']='进击的皮卡丘:BAABKgAECn8cAAMFAAgIZyBcEwAcAgAFAAcIBSFcEwAcAgAGAAEIshykhgBRAAAAAA==.',['迪奥']='迪奥斯战:BAAAKgAECgUIBAABKgAFFAgICAAQAHYJAA==.',['逐风']='逐风猎手:BAAAKgADCgUIBQAAAA==.',['邦桑']='邦桑迪之怒:BAAAKgADCggICAAAAA==.',['邪神']='邪神之殇:BAAAKgADCgQIBAAAAA==.',['郑秀']='郑秀妍我老婆:BAAAKgAECgQIBAAAAA==.',['都零']='都零:BAAAKgAECgIIAgAAAA==.',['酸萝']='酸萝卜鳖吃:BAAAKgADCggIDgAAAA==.',['释放']='释放灵魂:BAAAKgAECggIDQABKgAFFAgIHgAgAPAbAA==.',['野原']='野原向日葵:BAAAKgAECgIIBAAAAA==.',['铁血']='铁血真汉籽:BAAAKgAECgMIAwAAAA==.',['長腿']='長腿李敏鎬:BAAAKgAFFAEIAQAAAA==.',['闪光']='闪光卡比:BAAAKgADCggICAAAAA==.',['阿凡']='阿凡达他麻麻:BAAAKgADCgcIBwAAAA==.',['阿尔']='阿尔肥諾:BAACKgAFFH8JAAIOAAYIgxJMIQAYAQAOAAYIgxJMIQAYAQAqAAQKfxwAAw4ACAh4ImYmACoCAA4ACAh4ImYmACoCABwAAQgZCqY3ABoAAAEqAAUUCAgeACAA8BsA.阿尔肥诺:BAABKgAECn8VAAIKAAgI0BsXEgA2AgAKAAgI0BsXEgA2AgABKgAFFAgIHgAgAPAbAA==.',['阿辛']='阿辛:BAAAKgADCggIDAAAAA==.',['阿钢']='阿钢乄:BAABKgAFFH8GAAITAAYIVwlkGgBKAQATAAYIVwlkGgBKAQAAAA==.',['阿鲁']='阿鲁蒂霸王:BAAAKgAECgMIBAAAAA==.阿鲁迪巴丶:BAAAKgAFFAQIBAAAAA==.',['随便']='随便的大叔:BAAAKgAECgMIAwAAAA==.',['雨狂']='雨狂醉:BAABKgAECn8VAAIbAAcITRZgTAB5AQAbAAcITRZgTAB5AQAAAA==.',['雪域']='雪域之光:BAABKgAECn8+AAIMAAgIqBANGgBiAQAMAAgIqBANGgBiAQAAAA==.',['雷霆']='雷霆黑牛:BAABKgAECn8iAAIIAAgIASSwDQDiAgAIAAgIASSwDQDiAgAAAA==.',['雾非']='雾非雾:BAAAKgADCgMIAwAAAA==.',['雾风']='雾风喵:BAAAKgAFFAgIBAAAAA==.',['霜之']='霜之矮伤:BAABKgAFFH8IAAInAAQIZR4AAAAAAAATAAQIZR4AAAAAAAAAAA==.',['霸霸']='霸霸丶:BAAAKgAFFAEIAQAAAA==.',['靈灵']='靈灵:BAABKgAECn8WAAIdAAgI7QVgOwDVAAAdAAgI7QVgOwDVAAAAAA==.',['靑头']='靑头仔:BAABKgAFFH8RAAQQAAMIrgr7LgCoAAAQAAMIRgn7LgCoAAAUAAIIxge0NAB1AAAaAAEImgcbLQA1AAAAAA==.',['青橘']='青橘柠檬:BAAAKgAFFAQIBAAAAA==.',['青眼']='青眼之亚白:BAABKgAECn9ZAAIQAAgImSTGBQDdAgAQAAgImSTGBQDdAgAAAA==.',['青笋']='青笋:BAAAKgAECgcIBwAAAA==.',['预见']='预见:BAAAKgAECggICAAAAA==.',['風哭']='風哭葉:BAAAKgAFFAEIAQABKgAFFAgIKQAOAGQbAA==.',['風騷']='風騷灬埃姆提:BAAAKgADCgIIAgAAAA==.',['风吹']='风吹哀傷:BAAAKgAECgUIBQAAAA==.',['风哭']='风哭叶:BAAAKgAFFAEIAQAAAA==.',['飘柔']='飘柔大领主:BAAAKgAECgQIBAAAAA==.',['飞奔']='飞奔的大骑士:BAABKgAFFH8cAAMIAAYI8h0LCQA2AQAIAAYI8h0LCQA2AQAoAAIIxAk3GgBiAAAAAA==.飞奔的大鹌鹑:BAABKgAFFH8ZAAIOAAgIjx5SDADRAQAOAAgIjx5SDADRAQAAAA==.',['马齿']='马齿苋:BAAAKgAECgYIBgAAAA==.',['高松']='高松灯:BAABKgAECn8uAAILAAgITx9jEQA7AgALAAgITx9jEQA7AgAAAA==.',['鬼哭']='鬼哭血散斬:BAABKgAFFH8JAAITAAYIRBR4FAB3AQATAAYIRBR4FAB3AQAAAA==.',['鬼泣']='鬼泣丶:BAABKgAFFH8FAAIZAAMINg0TPgCFAAAZAAMINg0TPgCFAAAAAA==.',['魁峰']='魁峰风暴烈酒:BAACKgAFFH8VAAMPAAMINCGDCwAlAQAPAAMINCGDCwAlAQAhAAEIAwHuDAAeAAAqAAQKfyEAAyEACAjZGJkPAEYBACEABwj3E5kPAEYBAA8AAwhfIVA3AAIBAAEqAAUUCAgaABMATCEA.',['魂魄']='魂魄梦魇:BAAAKgAECgEIAQAAAA==.',['魔牛']='魔牛牛:BAAAKgAECgMIAwAAAA==.',['魚游']='魚游淺水:BAABKgAFFH8MAAMdAAYIZx4XAwC2AQAdAAYIZx4XAwC2AQAZAAYI2AxWGQAyAQAAAA==.',['鱼爷']='鱼爷:BAABKgAFFH8gAAMGAAgIKB2UAgChAgAGAAgIKB2UAgChAgAHAAIIdRTuDwB/AAAAAA==.',['鵰毛']='鵰毛叫我靓仔:BAAAKgADCgEIAQAAAA==.',['麝赦']='麝赦猞:BAAAKgAFFAIIAgAAAA==.',['黑暗']='黑暗夜刃:BAAAKgAECgQIBgAAAA==.',['黑檀']='黑檀之寒:BAAAKgAECggICAAAAA==.',['黑色']='黑色的雪:BAAAKgAECgEIAQAAAA==.',['黑铁']='黑铁传说:BAAAKgAECggICAAAAA==.',['鼬发']='鼬发歌:BAAAKgAECgcIEwAAAA==.',['龌龊']='龌龊的倪主任:BAAAKgAECggICAAAAA==.',['龍飛']='龍飛鳳舞:BAAAKgAECggIDgAAAA==.',['龙傲']='龙傲雪:BAAAKgAFFAYIBAABKgAFFAgIBQAeALUFAA==.',['龙凤']='龙凤之姿:BAAAKgAECgIIBAAAAA==.',['龙哥']='龙哥丶死骑:BAABKgAFFH8GAAINAAYIqwR1HAC+AAANAAYIqwR1HAC+AAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end