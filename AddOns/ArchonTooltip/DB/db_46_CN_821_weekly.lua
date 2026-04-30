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
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Warlock-Demonology','Warlock-Destruction','Rogue-Subtlety','Shaman-Restoration','DeathKnight-Blood','Unknown-Unknown','Paladin-Protection','Paladin-Retribution','Mage-Frost','Druid-Guardian','Druid-Feral','Druid-Balance','Warrior-Protection','Hunter-BeastMastery','DemonHunter-Devourer','DeathKnight-Unholy','Evoker-Preservation','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','Evoker-Devastation','Evoker-Augmentation','DeathKnight-Frost','Druid-Restoration','Paladin-Holy','Warrior-Arms','Warrior-Fury','Priest-Discipline','Rogue-Assassination','Priest-Shadow','Priest-Holy','Warlock-Affliction','DemonHunter-Havoc','Shaman-Elemental',}
local provider = {region='CN',realm='蜘蛛王国',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aixiaixiai:BAAALgAECgMJAwAAAA==.',
Al='Aliias:BAAALgAECgYJBgABLgAFFAUJBQABAKQVAA==.',
An='Anya:BAAALgADCgEJAQAAAA==.',
Ar='Artora:BAAALgADCgEJAQAAAA==.',
As='Astinus:BAAALgADCgYJBgAAAA==.',
Av='Avrillavign:BAAALgAECgcJCAAAAA==.',
Ba='Babe:BAAALgAFFAIJAwAAAA==.',
Bi='Biyuntao:BAAALgADCgcJBwAAAA==.',
Ca='Caméllia:BAAALgAECgEJAQAAAA==.',
Cl='Claudepanda:BAABLgAECn8VAAMBAAcJeCG2NAA5AgABAAYJeCG2NAA5AgACAAIJuRLdRwCXAAAAAA==.Clearlove:BAAALgAECgcJBwAAAA==.',
Da='Dande:BAAALgAECgEJAQAAAA==.',
Di='Dililil:BAAALgAECgEJAQABLgAFFAIJCAADAGIeAA==.',
Do='Doubleone:BAABLgAFFH8LAAIEAAQJKBkpBgBlAQAEAAQJKBkpBgBlAQAAAA==.',
Et='Ethan:BAAALgAECgYJAQAAAA==.',
Fi='Firebrand:BAAALgAFFAIJBAAAAA==.',
Fl='Flechazo:BAACLgAFFH8YAAIFAAcJzwz6AQDFAQAFAAcJzwz6AQDFAQAuAAQKfxkAAgUACQmQGZoIAJgCAAUACQmQGZoIAJgCAAAA.',
Gr='Greenhat:BAAALgAECgYJDAAAAA==.',
He='Herdleader:BAAALgAECgEJAQAAAA==.',
Ho='Holyknight:BAAALgAECgIJAgAAAA==.',
Ie='Iefevol:BAAALgAECgkJBwABLgAFFAUJAwAGAAAAAA==.',
Is='Isabella:BAABLgAECn8bAAMHAAgJzhxsAQA5AgAHAAgJzhxsAQA5AgAIAAIJEgomIgFaAAAAAA==.',
Ja='Jayaz:BAABLgAFFH8IAAIJAAQJ7g0xJAAlAQAJAAQJ7g0xJAAlAQAAAA==.',
Jo='Johnnyr:BAAALgAECgEJAQAAAA==.Jormungand:BAAALgAECgIJAwAAAA==.',
Ju='Justfeitian:BAAALgAECgcJDAABLgAFFAUJBAAGAAAAAA==.Justfs:BAAALgAECgcJDQAAAA==.',
Ka='Kaenbyou:BAACLgAFFH8MAAIKAAQJ3xueAABuAQAKAAQJ3xueAABuAQAuAAQKfxYABAoABwk/JRwDAOUCAAoABwk/JRwDAOUCAAsAAQkAAHI2ACwAAAwAAQlsAKCSAAkAAAAA.',
Ki='Kissbear:BAAALgAECgUJAwAAAA==.',
Le='Lerson:BAAALgAECgEJAQAAAA==.',
Li='Liisfkmovie:BAABLgAFFH8HAAINAAMJRQZABwCIAAANAAMJRQZABwCIAAAAAA==.Linuxx:BAAALgAECgQJBgAAAA==.',
Lo='Loki:BAAALgAECgUJCAAAAA==.',
Ma='Marcus:BAAALgAECgEJAQAAAA==.',
Mc='Mcrow:BAAALgAECgIJAwAAAA==.',
Me='Meilingge:BAAALgAFFAQJBAAAAA==.Melody:BAAALgAECgQJBAAAAA==.',
Mw='Mwuhhaha:BAAALgAECgEJAQAAAA==.',
Ne='Nergal:BAAALgAECgIJAgAAAA==.',
No='Noa:BAAALgAECgcJBwAAAA==.',
Op='Opss:BAAALgAECgEJAQAAAA==.',
Pi='Pikichu:BAAALgAECgEJAQAAAA==.',
Pl='Playervdlltv:BAAALgADCgcJCwAAAA==.',
Sd='Sdrop:BAABLgAECn8ZAAIOAAYJ4SSeGwBhAgAOAAYJ4SSeGwBhAgAAAA==.',
Sh='Shengqi:BAAALgAECgMJAwAAAA==.Shinkarev:BAAALgAFFAIJBAAAAA==.',
Sk='Skylock:BAAALgAECgQJBAAAAA==.Skylover:BAAALgADCgMJAwAAAA==.',
Tk='Tk:BAAALgADCgYJBgAAAA==.',
Tr='Trcuied:BAAALgADCgIJAgAAAA==.Treason:BAAALgAECgEJAgAAAA==.',
Uu='Uun:BAAALgAECgEJAgAAAA==.',
Va='Vane:BAABLgAECn8bAAMBAAkJ2w7iRAD9AQABAAkJ2w7iRAD9AQACAAIJVAkEVQBvAAAAAA==.',
Wi='Windflower:BAAALgADCgQJBwAAAA==.Windwaker:BAAALgAECgUJBQAAAA==.Wine:BAABLgAECn8XAAIPAAcJpxamRADhAQAPAAcJpxamRADhAQAAAA==.',
Xy='Xyhanerin:BAAALgAECgYJBgAAAA==.',
Ys='Ys:BAAALgAECgQJBQAAAA==.',
Yu='Yuukiasuna:BAAALgADCgYJBgAAAA==.',
['一笑']='一笑傾絾:BAAALgAECgYJCAAAAA==.',
['一身']='一身平安:BAAALgADCgIJAQAAAA==.',
['一队']='一队部落:BAAALgADCgMJAwAAAA==.',
['一颗']='一颗元素的心:BAAALgAECgcJBwAAAA==.',
['七七']='七七子丶:BAABLgAFFH8YAAIJAAYJOCIgAQDvAQAJAAYJOCIgAQDvAQAAAA==.',
['七寸']='七寸小彩电丶:BAAALgAFFAIJBAAAAA==.',
['七皮']='七皮十杠:BAAALgAECgIJBAAAAA==.',
['三千']='三千世界:BAAALgAECgEJAQAAAA==.',
['三思']='三思:BAAALgADCgQJBAAAAA==.',
['三角']='三角初华:BAACLgAFFH8LAAIQAAQJ+hfrEgBWAQAQAAQJ+hfrEgBWAQAuAAQKfx8AAxAABwl6I9giALQCABAABwl6I9giALQCAAUAAQnSEctEADUAAAAA.',
['三队']='三队防战:BAAALgAECgQJBgAAAA==.',
['上帝']='上帝之手:BAAALgAFFAQJBAAAAA==.',
['不乖']='不乖不怪:BAAALgAECgQJBAAAAA==.',
['不灭']='不灭幽影:BAAALgAECggJDQAAAA==.',
['不落']='不落的星辰:BAAALgAECgYJCgAAAA==.',
['东方']='东方骑魂:BAAALgAECgYJBgAAAA==.',
['丨中']='丨中野梓丨:BAAALgAFFAEJAQAAAA==.',
['丨德']='丨德行丨:BAAALgAFFAIJAwAAAA==.',
['丨总']='丨总裁丨:BAAALgAECgEJAgAAAA==.',
['丨教']='丨教主大人丶:BAAALgADCgEJAQAAAA==.',
['丨甜']='丨甜筒先生丶:BAAALgAECgcJBwAAAA==.',
['丫丫']='丫丫的小酒窝:BAAALgAECgEJAQABLgAFFAQJCAARABsaAA==.',
['中野']='中野薰:BAAALgAFFAIJAQAAAA==.',
['丶丶']='丶丶:BAAALgAECgMJAwAAAA==.',
['丶伊']='丶伊邪那美丶:BAAALgAECgQJBwAAAA==.',
['丶八']='丶八方来财丶:BAAALgAECgYJEQAAAA==.',
['丶童']='丶童话:BAAALgAECgcJDgAAAA==.',
['为我']='为我弹琴灬:BAAALgAECgMJAwAAAA==.',
['乀大']='乀大领主:BAAALgAFFAEJAQAAAA==.',
['乀酒']='乀酒色财气:BAABLgAECn8XAAISAAgJFxf3FQAWAgASAAgJFxf3FQAWAgAAAA==.',
['乀食']='乀食铁兽:BAAALgADCgEJAQAAAA==.',
['乖乖']='乖乖巴迪丶:BAAALgAFFAUJBAAAAA==.',
['乙巳']='乙巳小青龙:BAAALgAECgcJBwAAAA==.',
['九天']='九天玄女:BAAALgAECgYJCAAAAA==.',
['九莲']='九莲宝灯:BAABLgAECn8YAAMTAAcJahg+JQDZAQATAAcJahg+JQDZAQAUAAMJ9Ab5YQCHAAAAAA==.',
['乡下']='乡下人进城:BAAALgAECgMJAwAAAA==.',
['二拐']='二拐的媳妇儿:BAAALgAECgUJBQAAAA==.',
['云中']='云中之神:BAAALgAECgMJBgAAAA==.',
['云边']='云边探竹:BAAALgAECgQJBAAAAA==.',
['五十']='五十已到:BAAALgAECgYJDgAAAA==.',
['亚丝']='亚丝娜丶:BAAALgAECgcJDAAAAA==.',
['人民']='人民的勤务员:BAAALgAECgUJCQAAAA==.',
['人海']='人海一粒渣:BAAALgAECgYJCQAAAA==.',
['人狼']='人狼:BAAALgAECgUJBQAAAA==.',
['伊伊']='伊伊妖妖:BAAALgAECgQJCQAAAA==.',
['伊莎']='伊莎:BAAALgAECgUJBQAAAA==.伊莎佩拉:BAAALgAECgYJCgAAAA==.',
['休闲']='休闲人:BAAALgAECgYJBgAAAA==.',
['伟大']='伟大的格洛:BAAALgAECgYJCQAAAA==.',
['传奇']='传奇大锤:BAAALgAECgQJBQAAAA==.传奇筱:BAAALgADCgUJBQAAAA==.',
['传说']='传说中的二:BAAALgAECgUJBgAAAA==.',
['伯瓦']='伯瓦尔弗塔根:BAAALgADCgUJBQAAAA==.',
['佛山']='佛山叶问:BAAALgAECgMJBAAAAA==.',
['佬肩']='佬肩巨滑:BAAALgAECgQJBAAAAA==.',
['依依']='依依不相随:BAAALgADCgcJCAAAAA==.',
['依旧']='依旧轻风:BAAALgAECgUJBQAAAA==.',
['傲世']='傲世之流年:BAAALgAECgYJBgAAAA==.傲世之羽:BAAALgAECgcJCAAAAA==.傲世狂龙:BAACLgAFFH8RAAMVAAUJDSE8AAAEAgAVAAUJhyA8AAAEAgAWAAIJDheoEwBgAAAuAAQKfxwAAxUACAn5IDQFAK0CABUABwlAIjQFAK0CABYABAmsGD4zADEBAAAA.',
['儒雌']='儒雌櫹溷:BAAALgAECgYJDgAAAA==.',
['光中']='光中之光:BAAALgADCgEJAQAAAA==.',
['兔兔']='兔兔不食草:BAAALgAECgYJCgAAAA==.',
['八月']='八月秋夕:BAAALgAECgcJEAAAAA==.',
['六婆']='六婆:BAAALgAECgcJCQAAAA==.',
['六花']='六花丶:BAABLgAFFH8LAAIJAAYJ+BUKAgDDAQAJAAYJ+BUKAgDDAQAAAA==.',
['养猪']='养猪丨丨大户:BAAALgAFFAEJAQAAAA==.',
['冰冰']='冰冰公主:BAAALgAECgEJAQAAAA==.',
['冰若']='冰若依:BAAALgAECgUJCgAAAA==.',
['冰镇']='冰镇小法:BAAALgADCgEJAQAAAA==.',
['冰霜']='冰霜之路:BAAALgAECgMJAwAAAA==.冰霜涌动之心:BAAALgAECgUJBQAAAA==.',
['冲击']='冲击的第一拳:BAAALgAECgcJDgAAAA==.',
['凛冬']='凛冬德:BAAALgAECgUJBQAAAA==.',
['凝光']='凝光:BAAALgAECgQJBAAAAA==.',
['凝眸']='凝眸泪泪:BAAALgADCgUJBQAAAA==.',
['凤丶']='凤丶别鹤离鸾:BAAALgAECgUJBgABLgAFFAIJBQANAJ4QAA==.',
['凤兮']='凤兮德殂:BAAALgAECgUJBQAAAA==.',
['凯瑟']='凯瑟琳丶米娜:BAAALgAECgYJCQAAAA==.',
['刑天']='刑天之屰:BAAALgAECgEJAQAAAA==.',
['刘涛']='刘涛朱伟文:BAAALgAECgUJBgAAAA==.',
['利姆']='利姆露丶:BAABLgAFFH8WAAIJAAYJxCE1AQDrAQAJAAYJxCE1AQDrAQAAAA==.',
['别怕']='别怕变老:BAAALgADCgUJBQAAAA==.',
['别让']='别让我追到你:BAABLgAFFH8QAAIJAAUJQSPeDwCXAQAJAAUJQSPeDwCXAQAAAA==.',
['劍廿']='劍廿三:BAAALgAECgkJBgAAAA==.',
['力之']='力之斩铁:BAAALgAECgUJBgAAAA==.',
['化成']='化成灰:BAAALgAECgIJAgAAAA==.',
['北凉']='北凉铁骑:BAAALgAECgIJBAAAAA==.',
['北大']='北大村悍妇:BAAALgADCgIJAgAAAA==.',
['北溟']='北溟以北:BAABLgAFFH8IAAIQAAMJuSAECwA4AQAQAAMJuSAECwA4AQAAAA==.',
['十三']='十三椿:BAAALgADCgYJCgAAAA==.',
['千纱']='千纱丶:BAABLgAFFH8GAAIJAAYJDBjoAwA0AgAJAAYJDBjoAwA0AgAAAA==.',
['南帝']='南帝北丐也:BAAALgAECgcJCwAAAA==.',
['卿本']='卿本佳人丶:BAAALgADCgQJBAAAAA==.',
['叛天']='叛天:BAAALgAECgMJAwAAAA==.',
['古树']='古树天敌:BAAALgAECgEJAQAAAA==.',
['古蕾']='古蕾娅:BAAALgAECgEJAQAAAA==.',
['只会']='只会打瞄准:BAAALgAFFAEJAgAAAA==.',
['只恋']='只恋一抹青:BAAALgAFFAIJBAABLgAFFAQJDQAIANchAA==.',
['只手']='只手之声:BAAALgAFFAQJBAAAAA==.只手之德:BAAALgAECgYJBgAAAA==.只手之猎:BAAALgAECgYJCgAAAA==.',
['可爱']='可爱晖:BAAALgADCgEJAgAAAA==.',
['叶师']='叶师傅:BAAALgAECgcJCwAAAA==.',
['吃完']='吃完饭就睡:BAAALgAECgYJCgAAAA==.',
['吃颗']='吃颗糖壮壮胆:BAAALgAECgEJAgAAAA==.',
['吉光']='吉光片羽丶:BAAALgAECgcJBwAAAA==.',
['同盟']='同盟塞爱诶:BAAALgAECgcJCAABLgAFFAUJDQABAF8XAA==.',
['名蒸']='名蒸蛋圣洁:BAAALgADCgcJBwAAAA==.',
['呔呔']='呔呔好实力啊:BAAALgAECgYJBgAAAA==.',
['呢喃']='呢喃大魔王:BAAALgAECgQJBAAAAA==.',
['咕咕']='咕咕灬:BAAALgAFFAIJAwAAAA==.',
['咪吖']='咪吖咪:BAAALgAECgcJDQAAAA==.',
['咲也']='咲也:BAAALgAFFAQJAwAAAA==.',
['哈吉']='哈吉米极霸:BAAALgAECgUJBQABLgAECgYJFwABAOEgAA==.',
['哈赖']='哈赖离:BAABLgAFFH8GAAIBAAQJMxfsBgBcAQABAAQJMxfsBgBcAQAAAA==.',
['哎哟']='哎哟痛:BAAALgADCgcJBwAAAA==.',
['哪都']='哪都通临时工:BAAALgAECgYJBwAAAA==.',
['唱跳']='唱跳:BAAALgAECgMJAwAAAA==.',
['啊啦']='啊啦贡:BAAALgAECgYJDAAAAA==.',
['啪了']='啪了个啪:BAAALgAFFAQJBAAAAA==.',
['喝酒']='喝酒喝酒:BAAALgAECgEJAQAAAA==.',
['喵喵']='喵喵熊:BAAALgAECgEJAQAAAA==.',
['噶啦']='噶啦玛:BAAALgAECgYJDgAAAA==.',
['嚯哈']='嚯哈嘿:BAAALgAECgIJAgAAAA==.',
['固执']='固执:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光再临:BAAALgADCgkJEAAAAA==.圣光抄手:BAAALgAECgQJBAAAAA==.',
['圣可']='圣可可:BAAALgAECgYJCwAAAA==.',
['圣墓']='圣墓守護者:BAAALgAECgIJBgAAAA==.',
['圣洁']='圣洁爱美丽:BAAALgAECgYJDwAAAA==.',
['地狱']='地狱之炎:BAAALgAECgMJBgAAAA==.',
['坤派']='坤派尊者:BAAALgAECgYJBgAAAA==.',
['培提']='培提其乌斯:BAAALgAECgIJAwAAAA==.',
['堕落']='堕落星辰:BAAALgAECgEJAQAAAA==.',
['塔城']='塔城小喵:BAAALgAECgMJAwAAAA==.',
['墨云']='墨云晓月:BAABLgAECn8WAAMQAAcJbyN6IgC2AgAQAAcJbyN6IgC2AgAXAAEJgiRqEwBcAAAAAA==.',
['士土']='士土士土士:BAAALgADCgMJAwAAAA==.',
['夏朽']='夏朽沫苒:BAACLgAFFH8GAAIYAAMJQQZSFADFAAAYAAMJQQZSFADFAAAuAAQKfxcAAhgABwluF5Q2AM0BABgABwluF5Q2AM0BAAAA.',
['夏沫']='夏沫丶小微笑:BAAALgAECgYJCQAAAA==.',
['多龙']='多龙巴鲁托:BAAALgAECgkJCAAAAA==.',
['夜丶']='夜丶尘埃:BAAALgAECgIJAgAAAA==.',
['夜南']='夜南亭:BAAALgAECgcJEgAAAA==.',
['夜合']='夜合釜:BAAALgAECgEJAQAAAA==.',
['夢熙']='夢熙雲:BAAALgAECgEJAwAAAA==.',
['大坏']='大坏狐狸:BAAALgAECgQJBAAAAA==.',
['大尐']='大尐丶姐:BAAALgAECgYJCQAAAA==.',
['大憨']='大憨憨:BAAALgAECgQJBQAAAA==.',
['大漠']='大漠孤雁:BAAALgADCgQJBAAAAA==.',
['大萌']='大萌德胖啊:BAAALgADCgcJBwAAAA==.',
['天上']='天上月水中影:BAAALgAECgUJBQAAAA==.',
['天丨']='天丨神:BAAALgAECgIJAgAAAA==.',
['天呐']='天呐你真高:BAAALgAECgYJCAAAAA==.',
['天朝']='天朝原子蛋:BAAALgAECgYJDQAAAA==.',
['奔跑']='奔跑的灰机:BAABLgAECn8ZAAIQAAcJphE6awC1AQAQAAcJphE6awC1AQAAAA==.',
['好耐']='好耐冇見:BAAALgAECgIJAgAAAA==.',
['妖艳']='妖艳戏法:BAAALgADCgEJAQAAAA==.',
['妮娔']='妮娔丶:BAAALgAECgEJAQAAAA==.',
['妮雅']='妮雅薇儿:BAAALgAECgMJAwAAAA==.',
['妳是']='妳是我的眼:BAAALgADCgMJAwAAAA==.',
['嫂嫂']='嫂嫂腰细腿长:BAAALgAECgIJAgAAAA==.',
['嫣语']='嫣语紫梦:BAAALgAECgQJBAAAAA==.',
['孤心']='孤心:BAAALgAECgYJBwAAAA==.',
['孤独']='孤独心伤:BAAALgAECgYJAgAAAA==.',
['孤魂']='孤魂野鬼:BAAALgAECgMJAwAAAA==.',
['守护']='守护唯一:BAAALgAECgUJBgAAAA==.',
['安吉']='安吉莉娜茱莉:BAAALgAECgQJCAAAAA==.',
['宝儿']='宝儿:BAAALgADCgQJAQAAAA==.',
['小博']='小博士:BAAALgADCgEJAQAAAA==.',
['小呆']='小呆莉:BAEALgAECgUJBQAAAA==.',
['小宇']='小宇哥:BAAALgAECgQJBAAAAA==.',
['小小']='小小会长大:BAAALgAECgQJBwAAAA==.小小奇诺:BAACLgAFFH8IAAIJAAQJmBoQFQB1AQAJAAQJmBoQFQB1AQAuAAQKfxoAAgkACAn+JHgeAPsCAAkACAn+JHgeAPsCAAAA.小小旅者:BAAALgAECgQJBgABLgAECgUJBgAGAAAAAA==.',
['小山']='小山药:BAAALgAECgIJAgAAAA==.',
['小白']='小白鼻:BAAALgAECgEJAQAAAA==.',
['小胖']='小胖墩儿:BAAALgAECgUJBQAAAA==.',
['小财']='小财迷奶团团:BAAALgAECgIJAgAAAA==.',
['小高']='小高的老高:BAAALgAECgQJBAAAAA==.',
['小鸟']='小鸟:BAAALgAECgYJBgAAAA==.',
['小龙']='小龙不要闹:BAAALgAECgYJAwAAAA==.',
['尼铎']='尼铎格尔:BAAALgAECgEJAQAAAA==.',
['山那']='山那边:BAAALgAECgEJAQAAAA==.',
['山阴']='山阴路的夏天:BAAALgAECgYJEgAAAA==.',
['岚丶']='岚丶风暴烈酒:BAAALgAECgQJBAAAAA==.',
['巨物']='巨物:BAAALgAECgQJBAAAAA==.',
['巫幺']='巫幺王:BAAALgADCgcJAgAAAA==.',
['巫毒']='巫毒婆婆:BAAALgAECgUJBQAAAA==.',
['布伦']='布伦诗塔德:BAAALgAECgEJAgAAAA==.',
['帅海']='帅海洋:BAAALgAECgEJAQABLgAFFAIJBwAMAG4GAA==.',
['希望']='希望:BAAALgAECgUJBQAAAA==.',
['希瑞']='希瑞战术:BAAALgAECgEJAQAAAA==.',
['帕姆']='帕姆尼:BAAALgADCgcJBwAAAA==.',
['席尔']='席尔佤拉斯:BAAALgAECgIJAgAAAA==.',
['幺儿']='幺儿健康聪慧:BAAALgAECgYJCAAAAA==.',
['幺六']='幺六斯基:BAAALgADCgYJCwAAAA==.',
['幼儿']='幼儿源:BAAALgAECgEJAQAAAA==.',
['庆豆']='庆豆豆:BAAALgAFFAIJAgAAAA==.',
['康娜']='康娜丶:BAAALgAFFAQJBAAAAA==.',
['弗兰']='弗兰斯:BAAALgAECgEJAQAAAA==.',
['弘树']='弘树:BAAALgAECgkJDQAAAA==.',
['弯腰']='弯腰一样弔:BAAALgAECgQJBAAAAA==.',
['强力']='强力神圣骑壹:BAABLgAFFH8NAAIZAAUJ5hEhAgCdAQAZAAUJ5hEhAgCdAQABLgAFFAYJCwAZAKYLAA==.强力神圣骑贰:BAABLgAFFH8LAAIZAAYJpgsDBwBmAQAZAAYJpgsDBwBmAQAAAA==.',
['影丶']='影丶刻骨铭心:BAAALgAECgYJBwABLgAFFAIJBQANAJ4QAA==.',
['往事']='往事回想:BAAALgAECgIJAgAAAA==.往事梦想:BAAALgAECgQJBAAAAA==.',
['御风']='御风无极:BAAALgAECgUJBQAAAA==.',
['德来']='德来也:BAAALgAECgEJAgAAAA==.',
['心憶']='心憶評:BAAALgAECgcJBQAAAA==.',
['忽忽']='忽忽:BAAALgADCgEJAQAAAA==.',
['怀念']='怀念乖乖:BAAALgAECgIJAgAAAA==.',
['怒风']='怒风咆哮:BAAALgAECgIJAwAAAA==.',
['恐兰']='恐兰钟摆:BAAALgAECgMJAwAAAA==.',
['惜日']='惜日:BAAALgAECgYJCgAAAA==.',
['想吃']='想吃鲸鱼的猫:BAAALgAECgQJBAAAAA==.',
['愣头']='愣头青皮:BAAALgADCgcJBwAAAA==.',
['愤怒']='愤怒之槌:BAAALgAECgYJBwAAAA==.愤怒的小朵朵:BAAALgAECgQJBAAAAA==.',
['慕雨']='慕雨橙鳳:BAAALgAECgIJAgAAAA==.',
['我欲']='我欲成魔:BAAALgAECgcJCQAAAA==.',
['我爱']='我爱奶牛:BAAALgAECgEJAgAAAA==.',
['戦丶']='戦丶無雙:BAAALgAECgIJAgAAAA==.',
['戳笔']='戳笔大羽哥:BAAALgAECgIJBAAAAA==.',
['托尔']='托尔丶:BAABLgAFFH8FAAIJAAUJGhqqBwBvAQAJAAUJGhqqBwBvAQAAAA==.',
['托莲']='托莲娜:BAAALgAECgMJAwAAAA==.',
['抽风']='抽风的小马:BAAALgAECgYJCAAAAA==.',
['拉哈']='拉哈路特:BAAALgAECgcJCQAAAA==.',
['挝绊']='挝绊:BAAALgAECgQJCgAAAA==.',
['挺尸']='挺尸小剑云:BAAALgAECgYJDQAAAA==.',
['探险']='探险家丶:BAAALgADCgIJAgAAAA==.',
['摸鱼']='摸鱼大王:BAACLgAFFH8LAAIZAAQJfyRRAgCWAQAZAAQJfyRRAgCWAQAuAAQKfxUAAhkABwkmJGYLAMMCABkABwkmJGYLAMMCAAAA.',
['撕裂']='撕裂毛毛腿:BAABLgAECn8bAAQaAAcJJR0pBQCOAgAaAAcJJR0pBQCOAgANAAYJ9Q+tJQARAQAbAAEJEQW4rwArAAAAAA==.',
['放逐']='放逐之锋丶:BAAALgAECgUJBQAAAA==.',
['救救']='救救舅舅:BAAALgAECgEJAQAAAA==.',
['斗之']='斗之震裂:BAAALgAECgIJBAAAAA==.',
['断了']='断了的弦:BAAALgAECgIJAgAAAA==.',
['斯托']='斯托克:BAAALgAECgMJAwAAAA==.',
['旧唁']='旧唁虐訫:BAAALgAECgYJBgAAAA==.',
['星之']='星之轨迹:BAAALgAECgQJBQAAAA==.',
['星光']='星光闪耀:BAAALgADCgEJAQAAAA==.',
['星尘']='星尘無極:BAABLgAFFH8FAAIcAAQJkxNlCQBHAQAcAAQJkxNlCQBHAQAAAA==.星尘霈凉:BAAALgAFFAQJBAAAAA==.',
['星韵']='星韵怒风:BAAALgAECgMJAwAAAA==.',
['春逝']='春逝:BAAALgAECgQJBAAAAA==.',
['晓肥']='晓肥嘟嘟:BAAALgAECgIJAgAAAA==.',
['晚來']='晚來天欲雪:BAAALgAECgUJCQAAAA==.',
['晚安']='晚安:BAAALgAECgYJCgAAAA==.',
['暗嗨']='暗嗨骑士:BAAALgAECgUJBQAAAA==.',
['暗影']='暗影禁区:BAAALgAECgYJDgAAAA==.',
['暴走']='暴走的奈奈:BAAALgADCgEJAQAAAA==.',
['曾曾']='曾曾亲:BAAALgADCgIJAgAAAA==.',
['曾經']='曾經啲約顁:BAAALgAECgcJCAAAAA==.',
['曾经']='曾经相识:BAAALgADCgEJAQAAAA==.',
['最后']='最后的狩猎:BAAALgAECggJCAAAAA==.',
['月下']='月下凝眸:BAAALgAFFAIJBAAAAA==.月下饮醉:BAAALgAECgEJAQAAAA==.',
['月光']='月光下的清影:BAAALgAECgEJAQAAAA==.',
['月看']='月看月美:BAAALgAECgEJAQAAAA==.',
['月香']='月香水影:BAAALgAECgMJAwAAAA==.',
['有气']='有气质的人:BAAALgADCgEJAQAAAA==.',
['朕见']='朕见你就晕:BAAALgAECgYJEgAAAA==.',
['朱菜']='朱菜丶:BAABLgAFFH8FAAIJAAUJnQuNDgCkAQAJAAUJnQuNDgCkAQAAAA==.',
['杀君']='杀君:BAAALgAECgEJAQAAAA==.',
['杨术']='杨术:BAAALgAECgYJCwAAAA==.',
['林晚']='林晚:BAAALgADCgcJBwAAAA==.',
['枯叶']='枯叶送到:BAAALgADCgcJBwAAAA==.',
['枯禅']='枯禅:BAAALgADCgEJAQAAAA==.',
['栗子']='栗子三明治:BAAALgAECgcJBQAAAA==.',
['核桃']='核桃哟:BAAALgAFFAQJAwAAAA==.',
['格燃']='格燃德玛蕾格:BAAALgAECgUJBQAAAA==.',
['桶装']='桶装果乐多:BAAALgADCgEJAQAAAA==.',
['梅蒂']='梅蒂雅:BAAALgADCgUJBQAAAA==.',
['梦醒']='梦醒瓜裂开:BAAALgAFFAEJAQAAAA==.',
['梵海']='梵海惊鸿:BAAALgADCgUJCAAAAA==.',
['森萝']='森萝财团:BAAALgAECgIJAgABLgAFFAYJBAAGAAAAAA==.',
['楚风']='楚风人家:BAAALgADCgQJBAAAAA==.',
['榨菜']='榨菜粉丝丶:BAAALgAECgUJCAAAAA==.',
['橙色']='橙色沙尘暴:BAAALgAECgEJAQAAAA==.',
['橤蘂']='橤蘂:BAAALgADCgQJBAAAAA==.',
['歪歪']='歪歪熊猫:BAAALgAFFAMJBAAAAA==.',
['歪瑞']='歪瑞古德:BAAALgAECgkJDgAAAA==.',
['死亡']='死亡之卧:BAAALgADCgUJBQAAAA==.死亡镣铐:BAAALgAECgEJAQAAAA==.',
['死骑']='死骑不死玩啥:BAAALgAECgQJBgAAAA==.',
['比我']='比我低都得练:BAAALgAFFAIJAwAAAA==.',
['水无']='水无射:BAAALgAECgIJAgAAAA==.',
['永恆']='永恆愛你:BAAALgAECgEJAQAAAA==.',
['永恒']='永恒的大水:BAAALgADCgEJAQAAAA==.',
['汐芸']='汐芸:BAAALgAECgEJAQAAAA==.',
['汐西']='汐西:BAAALgAECgkJCAAAAA==.',
['沅兲']='沅兲灞:BAAALgAECgkJDgAAAA==.',
['沐雨']='沐雨橙风:BAAALgAECgEJAQAAAA==.',
['沙姜']='沙姜琪玛:BAAALgAECgQJBwAAAA==.',
['没有']='没有线的风筝:BAAALgAECgQJBAAAAA==.',
['沫夕']='沫夕:BAAALgAECgkJCQAAAA==.',
['沫离']='沫离沫弃:BAAALgADCgEJAQAAAA==.',
['油泼']='油泼小嫩牛:BAAALgAECgYJCQAAAA==.',
['治療']='治療大隊隊長:BAAALgAECgkJCQAAAA==.',
['法术']='法术棱镜:BAAALgAECgkJBwAAAA==.',
['法神']='法神乄:BAAALgAECggJCgAAAA==.',
['洒脱']='洒脱的卡尔:BAAALgAECgEJAQAAAA==.',
['洛丹']='洛丹伦的蚊子:BAAALgADCgEJAQAAAA==.',
['洛水']='洛水秋殇:BAABLgAECn8bAAIJAAYJGSCSYAAZAgAJAAYJGSCSYAAZAgAAAA==.',
['济南']='济南纯爷们:BAAALgAECgQJBAAAAA==.',
['淅沥']='淅沥沥的小雨:BAAALgAECgkJAgAAAA==.',
['淡定']='淡定术六号:BAAALgAFFAEJAQAAAA==.',
['深井']='深井烧鹅:BAAALgAECgcJDQAAAA==.',
['淼燚']='淼燚:BAAALgADCgEJAQAAAA==.',
['渐染']='渐染:BAAALgADCgEJAQAAAA==.',
['温水']='温水煮白菜:BAAALgAECgEJAgAAAA==.',
['温鸡']='温鸡归来:BAAALgAECgcJDwAAAA==.',
['潇洒']='潇洒小猎:BAAALgAECgIJAgAAAA==.',
['潜伏']='潜伏的猎手:BAAALgAECgEJAQAAAA==.',
['潜心']='潜心悠然:BAAALgAECgEJAQAAAA==.',
['濑户']='濑户由衣:BAAALgADCgIJAgAAAA==.',
['火焰']='火焰黑骑麟:BAAALgADCgYJBgAAAA==.',
['灬宁']='灬宁静灬:BAAALgAECgEJAQAAAA==.',
['灭绝']='灭绝一切师太:BAAALgAECgEJAQAAAA==.',
['灰泥']='灰泥迪:BAAALgAECgUJBwAAAA==.',
['焦油']='焦油陷阱:BAABLgAECn8UAAIZAAcJQQ4/EwA7AQAZAAcJQQ4/EwA7AQAAAA==.',
['然汐']='然汐:BAAALgADCgMJAwAAAA==.',
['煌梓']='煌梓凌:BAAALgADCgEJAQAAAA==.',
['煌黑']='煌黑终焉之影:BAACLgAFFH8SAAIDAAUJfQ6SBAClAQADAAUJfQ6SBAClAQAuAAQKfxsAAgMACQl4GhEMANYCAAMACQl4GhEMANYCAAAA.',
['熊主']='熊主任:BAAALgAECgEJAgAAAA==.',
['熊小']='熊小宝丶:BAAALgAECgYJEgAAAA==.',
['熠熠']='熠熠生辉:BAAALgAECgYJDQAAAA==.',
['爖七']='爖七:BAABLgAECn8UAAIEAAYJCAqcHADtAAAEAAYJCAqcHADtAAAAAA==.',
['爱喝']='爱喝饮料:BAABLgAFFH8FAAMIAAMJgxCsDAD/AAAIAAMJgxCsDAD/AAAZAAIJOgqaFwCIAAAAAA==.',
['爱国']='爱国者导弹:BAAALgAECggJCAAAAA==.',
['牛美']='牛美灵:BAAALgAECgcJAQAAAA==.',
['狂龙']='狂龙乱舞:BAAALgAECgEJAQAAAA==.',
['狐掌']='狐掌柜:BAAALgAECgYJBwAAAA==.',
['狮与']='狮与鹰之耀:BAAALgAECgEJAgAAAA==.',
['猫咪']='猫咪软糖:BAAALgAECgEJAQAAAA==.',
['玉环']='玉环大发机械:BAABLgAECn8ZAAMDAAcJ8BlpGgAvAgADAAcJ8BlpGgAvAgAdAAEJNR29HQA+AAAAAA==.',
['玛法']='玛法里澳怒水:BAAALgAECgcJEwAAAA==.',
['玛热']='玛热雅:BAAALgAECgYJEQAAAA==.',
['瑟拉']='瑟拉菲娜:BAAALgAECgYJAgAAAA==.',
['瓦萨']='瓦萨里:BAAALgAECgEJAQAAAA==.',
['瓶中']='瓶中怪:BAAALgAECgMJBAAAAA==.',
['甘九']='甘九真:BAACLgAFFH8JAAIJAAMJjRHiFgAEAQAJAAMJjRHiFgAEAQAuAAQKfxgAAgkABgkWIZ5dACECAAkABgkWIZ5dACECAAAA.',
['番薯']='番薯地瓜:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂的阿拉丁:BAAALgAECgMJAwAAAA==.',
['白手']='白手:BAAALgAECggJDAAAAA==.',
['白桃']='白桃味冰红茶:BAAALgAECgQJCAAAAA==.',
['皓凝']='皓凝霜雪:BAAALgADCgEJAQAAAA==.',
['皓雪']='皓雪殘劍:BAAALgAECgIJAgAAAA==.',
['盐酸']='盐酸达伯西汀:BAAALgAECgYJEAAAAA==.',
['相看']='相看一笑温丶:BAAALgAECgEJAQAAAA==.',
['盾血']='盾血目:BAACLgAFFH8FAAQeAAMJRhK9DQC8AAAeAAIJ+he9DQC8AAAcAAIJOwi3GQBJAAAfAAEJHwb3CwBFAAAuAAQKfxwABBwACAmdF4YQADgCABwACAmdF4YQADgCAB8ABAldEghUAOYAAB4ABQkjES9EANoAAAAA.',
['看无']='看无敌的增辉:BAAALgAECgIJAgAAAA==.',
['真言']='真言术丨日:BAABLgAFFH8GAAIfAAMJtBVpCADiAAAfAAMJtBVpCADiAAAAAA==.',
['眯闭']='眯闭眼合:BAAALgAECgIJAwAAAA==.',
['矜持']='矜持的耗子:BAAALgAFFAIJAgAAAA==.',
['石头']='石头城市:BAAALgAECgEJAQAAAA==.',
['破空']='破空星辰:BAABLgAECn8dAAIEAAcJwCCSDAC6AgAEAAcJwCCSDAC6AgAAAA==.',
['碧海']='碧海蓝天:BAAALgAECgQJBAAAAA==.',
['碧玉']='碧玉无暇:BAAALgAECgYJBgAAAA==.',
['神暗']='神暗灬灬:BAAALgAECgEJAgAAAA==.',
['离过']='离过婚的女人:BAAALgAECggJDwAAAA==.',
['秋山']='秋山黄色:BAAALgAECgEJAQAAAA==.',
['穿上']='穿上我的耐克:BAAALgAECgUJBgAAAA==.',
['穿越']='穿越苍穹:BAAALgAECgEJAQAAAA==.',
['笔墨']='笔墨紙砚:BAAALgAECgkJCQAAAA==.',
['笨德']='笨德可以:BAAALgAECgYJBgAAAA==.',
['第七']='第七把刷:BAAALgAECgUJBQAAAA==.',
['第弍']='第弍天零点:BAAALgADCgYJBgAAAA==.',
['筱锦']='筱锦燕:BAAALgADCgMJAwAAAA==.',
['筱靓']='筱靓妞:BAAALgAECgUJBQAAAA==.',
['米浴']='米浴丶:BAABLgAFFH8FAAIJAAUJyxEbDAC8AQAJAAUJyxEbDAC8AQAAAA==.',
['米莉']='米莉姆丶:BAABLgAFFH8HAAIJAAUJHRSVCwDAAQAJAAUJHRSVCwDAAQAAAA==.',
['精灵']='精灵小暮:BAAALgAECgYJCAAAAA==.',
['糕手']='糕手风月眠:BAAALgADCgUJBQAAAA==.',
['糖门']='糖门搜查官:BAAALgADCgYJBgAAAA==.',
['素素']='素素:BAAALgAECgUJBQAAAA==.',
['索罗']='索罗亚克:BAAALgAECgkJCQAAAA==.',
['紫依']='紫依圣:BAAALgADCgMJAwAAAA==.',
['紫川']='紫川丶宁:BAAALgAECgQJBAAAAA==.',
['紫府']='紫府圣子:BAAALgAECgMJAwAAAA==.',
['紫怨']='紫怨:BAAALgAECgYJCAAAAA==.',
['紫色']='紫色大聪明:BAAALgADCgIJAgAAAA==.',
['紫苑']='紫苑丶:BAAALgAFFAQJBAAAAA==.',
['紫辰']='紫辰心愿:BAAALgAECgMJAwAAAA==.',
['红色']='红色咕咕:BAAALgAFFAMJBAAAAA==.红色斗士:BAAALgAFFAEJAQAAAA==.',
['红隼']='红隼:BAAALgAECgIJAgAAAA==.',
['纱雾']='纱雾丶:BAABLgAFFH8RAAIJAAYJYRp0AQDbAQAJAAYJYRp0AQDbAQAAAA==.',
['绿寶']='绿寶石:BAAALgAECgEJAgAAAA==.',
['缺个']='缺个德:BAAALgAECgUJBgAAAA==.',
['罪唔']='罪唔依:BAAALgAFFAEJAQAAAA==.',
['羊吃']='羊吃狼:BAAALgAECgEJAQAAAA==.',
['美杜']='美杜沙:BAAALgAECgEJAQAAAA==.',
['美美']='美美桑内:BAAALgADCgEJAQAAAA==.',
['羽川']='羽川翼:BAAALgAECgUJBQAAAA==.',
['翻滚']='翻滚吧兄弟:BAAALgAECgEJAQAAAA==.翻滚的酒桶丶:BAAALgAECgYJDgAAAA==.',
['联盟']='联盟会长:BAAALgAECgEJAQAAAA==.联盟克格勃:BAACLgAFFH8NAAMBAAUJXxcvHwAHAQABAAQJtxYvHwAHAQACAAEJ/Rn1EQBbAAAuAAQKfyMABAIABwnRHgsMAAICAAIABglVHQsMAAICAAEABgk/FqBpAJABACAAAQmSIx0nAFUAAAAA.',
['肥圈']='肥圈圈:BAAALgAECgcJBwAAAA==.',
['肯瑞']='肯瑞托:BAAALgAECgcJBwAAAA==.',
['脚滑']='脚滑:BAAALgAFFAEJAQAAAA==.',
['腰身']='腰身一比一:BAABLgAECn8YAAIJAAcJBCX4IADwAgAJAAcJBCX4IADwAgAAAA==.',
['致雨']='致雨:BAAALgAECgkJAwAAAA==.',
['舞之']='舞之领域:BAAALgAFFAEJAQAAAA==.',
['舟远']='舟远山行:BAAALgAECgYJBgAAAA==.',
['良将']='良将郭宝坤:BAAALgAECgcJCgAAAA==.',
['花袭']='花袭寻梦:BAAALgAECgYJBwAAAA==.',
['芸山']='芸山:BAAALgAECgcJBwAAAA==.',
['若你']='若你喜欢怪相:BAAALgAECgYJEAAAAA==.',
['英梨']='英梨梨丶:BAABLgAFFH8JAAISAAMJwA/FDADZAAASAAMJwA/FDADZAAAAAA==.',
['茉茉']='茉茉:BAAALgAECgYJDQAAAA==.',
['药无']='药无医:BAABLgAFFH8DAAIBAAIJ8hC2NgCmAAABAAIJ8hC2NgCmAAAAAA==.',
['莓香']='莓香丶:BAABLgAFFH8SAAIJAAYJZx5tAQDeAQAJAAYJZx5tAQDeAQAAAA==.',
['莫妮']='莫妮卡贝鲁琦:BAAALgAECgUJBQAAAA==.',
['莫小']='莫小胖:BAAALgAECgEJAgAAAA==.',
['莱拿']='莱拿多:BAAALgAECgUJBQAAAA==.',
['菠萝']='菠萝蜜:BAAALgAECgIJAgAAAA==.',
['萌大']='萌大脸:BAAALgAECgEJAQAAAA==.',
['萌面']='萌面咕德啦:BAAALgAECgkJCQAAAA==.萌面大领主:BAAALgAECgkJCQAAAA==.',
['萦舞']='萦舞飞扬:BAAALgAECgMJAwAAAA==.',
['萨拉']='萨拉迈尼:BAAALgAECgEJAQAAAA==.',
['蒲美']='蒲美美:BAAALgAECgIJAgAAAA==.',
['蓝弦']='蓝弦:BAACLgAFFH8FAAIQAAMJkwniLADoAAAQAAMJkwniLADoAAAuAAQKfxYAAhAABwm7F49UAPQBABAABwm7F49UAPQBAAAA.',
['蓝海']='蓝海:BAAALgAECgYJBgABLgAECgcJGAATAGoYAA==.',
['蓝萨']='蓝萨:BAAALgADCgIJAgAAAA==.',
['蕴绣']='蕴绣凌霜:BAAALgAFFAEJAQAAAA==.',
['蕶薍']='蕶薍的绝:BAAALgAECgYJCwAAAA==.',
['蕾咪']='蕾咪莉亚:BAABLgAFFH8HAAIeAAIJ0xfdDgCuAAAeAAIJ0xfdDgCuAAABLgAFFAYJCgAfAEkcAA==.',
['虾爬']='虾爬舞爪:BAAALgAECgQJCQAAAA==.',
['蛆海']='蛆海狂魔:BAAALgAECgQJBAAAAA==.',
['蛋蛋']='蛋蛋的忧伤:BAAALgAECgEJAQAAAA==.',
['蜜桃']='蜜桃甜透了:BAAALgAFFAEJAQAAAA==.',
['血泠']='血泠儿:BAAALgADCgMJAwAAAA==.',
['血牧']='血牧月光:BAAALgAECgIJAgAAAA==.',
['血腥']='血腥玛东:BAAALgAFFAIJAgAAAA==.',
['血魂']='血魂之心:BAAALgAECgEJAgAAAA==.',
['表裱']='表裱我:BAAALgAFFAEJAQAAAA==.',
['被迫']='被迫改名的熊:BAAALgADCgEJAQAAAA==.',
['袭人']='袭人妹妹:BAABLgAFFH8FAAIZAAMJQSF7BgAaAQAZAAMJQSF7BgAaAQAAAA==.',
['西方']='西方猴魂:BAAALgAFFAIJAwAAAA==.',
['西红']='西红柿鸡蛋羹:BAAALgAECgYJCQAAAA==.',
['西门']='西门丶吹水:BAAALgAECgIJAgAAAA==.',
['觉醒']='觉醒镇魂者:BAACLgAFFH8RAAIMAAQJrx7bAgBiAQAMAAQJrx7bAgBiAQAuAAQKfyIABAwACQmVIHoEAFwDAAwACQmVIHoEAFwDABgAAQkyG8a5AFIAAAoAAQkAADM4ABcAAAAA.',
['解锋']='解锋镝:BAAALgAECgYJCgAAAA==.',
['警官']='警官丶:BAAALgAFFAEJAQAAAA==.',
['警探']='警探:BAAALgAECgMJAwAAAA==.',
['该吃']='该吃火锅了:BAAALgAECgMJAwAAAA==.',
['贝贝']='贝贝猫丶:BAAALgAECgUJCAAAAA==.',
['财猫']='财猫:BAAALgAECgEJAQAAAA==.',
['贫僧']='贫僧吥吃素:BAAALgADCgUJBQAAAA==.',
['贰两']='贰两微醺:BAAALgADCgcJCgAAAA==.',
['赞比']='赞比亚吴彦祖:BAAALgADCgEJAQAAAA==.',
['赞美']='赞美太陽:BAAALgAECgMJAwAAAA==.',
['踏风']='踏风王:BAAALgAECgEJAQAAAA==.',
['轩雪']='轩雪飞扬:BAAALgAECgIJAwAAAA==.',
['轰炸']='轰炸东京:BAAALgAECgYJBwAAAA==.',
['迷途']='迷途:BAAALgAECgYJCwAAAA==.',
['追墨']='追墨之问渊:BAAALgAECgEJAQAAAA==.',
['逆伤']='逆伤痕:BAAALgAECgIJBQAAAA==.',
['透露']='透露:BAAALgAECgYJCQABLgAFFAUJBAAGAAAAAA==.',
['逼逼']='逼逼蟹蟹:BAAALgAECgIJAgAAAA==.逼逼象:BAAALgAFFAIJAgAAAA==.',
['遁入']='遁入空门:BAAALgAFFAIJAgAAAA==.',
['邪轩']='邪轩:BAAALgAECgQJBAABLgAECgkJFQAQAPgLAA==.',
['邪门']='邪门:BAAALgAECgYJBwAAAA==.',
['邹身']='邹身硬:BAAALgAECgUJCQAAAA==.',
['郑东']='郑东:BAAALgAECgYJBwAAAA==.',
['野生']='野生包谷粑:BAAALgAECgEJAQAAAA==.',
['鉨爹']='鉨爹:BAAALgAECgIJAgAAAA==.',
['长夜']='长夜月:BAAALgAECgQJBQAAAA==.',
['闪亮']='闪亮亮的火花:BAAALgAECgYJBgAAAA==.',
['阿刃']='阿刃:BAAALgAFFAQJBAAAAA==.',
['阿尔']='阿尔特迷丝:BAABLgAFFH8FAAIOAAMJcBPtCwADAQAOAAMJcBPtCwADAQAAAA==.',
['阿拉']='阿拉钉:BAAALgAECgYJCgAAAA==.',
['阿赖']='阿赖耶识肥鱼:BAAALgAECgYJBwAAAA==.',
['陈小']='陈小草:BAAALgAECgYJCAABLgAECgQJBAAGAAAAAA==.',
['陈欣']='陈欣欣:BAAALgAECgQJBgABLgAECggJGAAJAAQlAA==.',
['陈逸']='陈逸潇:BAAALgAECgIJAgAAAA==.',
['随便']='随便玩玩:BAAALgAECgYJCwAAAA==.',
['随心']='随心飞翔:BAAALgAECgQJBAAAAA==.',
['随风']='随风如梦:BAAALgADCgEJAQAAAA==.',
['隐约']='隐约德意:BAAALgAECgEJAQAAAA==.',
['雀儿']='雀儿上巴颗饭:BAAALgAFFAIJAgAAAA==.',
['雪域']='雪域魔都神:BAAALgAECgEJAwAAAA==.',
['雪玥']='雪玥莎:BAAALgAECgYJDAAAAA==.',
['雪羽']='雪羽丶星枫:BAAALgAFFAEJAgAAAA==.',
['零点']='零点飘零:BAAALgAECgYJBgAAAA==.',
['雷克']='雷克曼克斯顿:BAAALgAECgUJCAAAAA==.',
['霍格']='霍格爾:BAAALgADCgEJAQAAAA==.',
['霸王']='霸王刀:BAAALgAECgYJCgAAAA==.',
['静丶']='静丶风暴烈酒:BAAALgAECgIJAgAAAA==.',
['静安']='静安梧桐:BAAALgAECgcJEgAAAA==.',
['静若']='静若繁花:BAAALgAECgcJBwAAAA==.',
['风丶']='风丶筝:BAAALgAECgYJDAAAAA==.',
['风合']='风合釜:BAAALgAECgEJAQAAAA==.',
['飞老']='飞老鼠:BAAALgAECgUJCAAAAA==.',
['飞鸟']='飞鸟连西东:BAAALgAECgIJAwAAAA==.',
['饰雪']='饰雪:BAABLgAECn8YAAIRAAYJuhNtHwCEAQARAAYJuhNtHwCEAQAAAA==.',
['馒头']='馒头胜哥:BAAALgAECgQJCAAAAA==.',
['香香']='香香醉:BAAALgAFFAIJAgAAAA==.',
['马小']='马小语:BAAALgAECgQJDQAAAA==.',
['马格']='马格拉克:BAAALgAFFAIJAgAAAA==.',
['骑着']='骑着蜗牛开炮:BAAALgADCgEJAQAAAA==.',
['骑蜗']='骑蜗牛跑高速:BAAALgAECgYJDwAAAA==.',
['鬼姐']='鬼姐救一下:BAAALgAFFAQJAwAAAA==.',
['魂哥']='魂哥:BAAALgAECgIJAgAAAA==.',
['魅魂']='魅魂妖姬:BAAALgADCgYJBgAAAA==.',
['魔法']='魔法伊莉雅:BAABLgAFFH8FAAIPAAUJAgHRGQABAQAPAAUJAgHRGQABAQAAAA==.',
['鱼舒']='鱼舒心:BAAALgADCgIJAgAAAA==.',
['鱼香']='鱼香发丝:BAAALgAECgEJAgAAAA==.',
['鲨鱼']='鲨鱼:BAAALgAECgUJBQAAAA==.',
['鸡枞']='鸡枞油的猎亻:BAAALgADCgIJAgAAAA==.',
['鸢陌']='鸢陌雪:BAAALgAECgUJBQAAAA==.',
['鸽子']='鸽子丹:BAAALgAECgYJDAAAAA==.',
['黑无']='黑无光:BAABLgAFFH8HAAIhAAMJcBS4AgD+AAAhAAMJcBS4AgD+AAAAAA==.',
['黑牛']='黑牛的威力:BAAALgAECgEJAQAAAA==.',
['黑风']='黑风的旋律:BAAALgAECgQJBgAAAA==.',
['黑魔']='黑魔仙莉莉:BAAALgAECgcJDQAAAA==.',
['黑鹰']='黑鹰:BAAALgAECgYJBgAAAA==.',
['默默']='默默地射:BAAALgAECgYJCgAAAA==.',
['黯丶']='黯丶初不相识:BAACLgAFFH8FAAINAAIJnhBdBwCFAAANAAIJnhBdBwCFAAAuAAQKfxYAAg0ABwkzG/YQAPgBAA0ABwkzG/YQAPgBAAAA.',
['黯淡']='黯淡神光:BAAALgAECgcJBwAAAA==.',
['龍七']='龍七:BAAALgAECgMJAwAAAA==.',
['龙神']='龙神:BAAALgADCgQJBAAAAA==.',
['龚姿']='龚姿:BAABLgAECn8WAAMEAAcJNxx2KgDkAQAEAAcJNxx2KgDkAQAiAAYJtwjYUAADAQAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
