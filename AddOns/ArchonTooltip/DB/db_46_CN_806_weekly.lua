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

local lookup = {'Evoker-Devastation','Evoker-Augmentation','Warrior-Fury','Warrior-Protection','Unknown-Unknown','Paladin-Retribution','Shaman-Elemental','Evoker-Preservation','Warlock-Demonology','Monk-Mistweaver','DemonHunter-Devourer','Hunter-BeastMastery','DeathKnight-Unholy','Rogue-Subtlety','Priest-Holy','Priest-Discipline','Shaman-Restoration','Shaman-Enhancement','Monk-Brewmaster','Mage-Frost','Hunter-Marksmanship','Warlock-Destruction','DemonHunter-Havoc','DeathKnight-Blood','Druid-Restoration',}
local provider = {region='CN',realm='苏塔恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adamove:BAACLgAFFH8NAAMBAAUJCRU9BAACAQABAAMJURY9BAACAQACAAMJtRL+EgDnAAAuAAQKfyMAAwEACAnyGUgNAAQCAAIABwnyGRMYABICAAEABwmKFUgNAAQCAAAA.',
Be='Beautiful:BAAALgAECgEJAQAAAA==.',
Bm='Bmanforever:BAACLgAFFH8GAAMDAAMJIBnWDwALAQADAAMJIBnWDwALAQAEAAIJcgqUDQBxAAAuAAQKfx8AAwQABwmkGNEGAFkBAAQABwmYE9EGAFkBAAMABAmUGsRiACcBAAAA.',
Co='Cohiba:BAAALgAECgEJAQAAAA==.Coisini:BAAALgADCgEJAQAAAA==.Coolove:BAAALgAECgYJDAAAAA==.',
Do='Donk:BAAALgAFFAMJAgABLgADCgcJBwAFAAAAAA==.',
Er='Ericming:BAAALgAFFAEJAQAAAA==.',
Ex='Exelero:BAABLgAECn8VAAIGAAgJhRuONQBMAgAGAAgJhRuONQBMAgABLgAFFAUJCQAHANcMAA==.',
He='Hesitation:BAACLgAFFH8KAAIIAAQJ4h0NBgCTAQAIAAQJ4h0NBgCTAQAuAAQKfx4ABAgACAl7I/UCADoDAAgACAl7I/UCADoDAAIABAkcG5AtAFUBAAEAAQm9FNE6AEQAAAAA.',
Hu='Hueter:BAAALgAECgQJBQAAAA==.Hunterlc:BAAALgAECgUJDwAAAA==.',
Jo='Jolin:BAAALgAECgEJAQAAAA==.',
Ju='Judyø:BAAALgADCgcJBwAAAA==.',
Kn='Knice:BAAALgAFFAEJAwAAAA==.',
Kr='Krakend:BAAALgAECgIJAgABLgAFFAIJAgAFAAAAAA==.Krakene:BAAALgAECgYJBgAAAA==.Krakenx:BAAALgAFFAIJAgAAAA==.',
Lo='Loarry:BAAALgAECgYJEAAAAA==.',
Lu='Luna:BAAALgAFFAEJAQAAAA==.',
Ma='Mazy:BAAALgAFFAIJAgAAAA==.',
Me='Memorialize:BAAALgAECgYJDgAAAA==.',
Mo='Momososo:BAAALgADCgIJAgAAAA==.',
Mu='Mummy:BAAALgADCgMJAwAAAA==.',
Re='Rexstyle:BAAALgAECgMJAwAAAA==.',
Rn='Rnmpp:BAAALgAECgkJCQAAAA==.',
Sp='Spontaneous:BAAALgADCgEJAQAAAA==.',
St='Starfiregoo:BAAALgAFFAEJAQABLgAECgkJFwAJANEcAA==.Starset:BAAALgAFFAQJBAAAAA==.Statham:BAAALgAECgYJCgAAAA==.',
Su='Sunabcd:BAABLgAFFH8JAAIDAAMJ/xeeBgAPAQADAAMJ/xeeBgAPAQAAAA==.Sunabcde:BAABLgAFFH8FAAIKAAMJPQvXDADYAAAKAAMJPQvXDADYAAAAAA==.',
Te='Temujin:BAAALgAECgQJAwAAAA==.',
Th='Thunder:BAABLgAFFH8GAAILAAMJdw0dHQDrAAALAAMJdw0dHQDrAAAAAA==.',
Va='Vantage:BAAALgAFFAEJAQAAAA==.',
Ve='Venturi:BAAALgAECgEJAgAAAA==.',
Wi='Willhope:BAAALgAFFAEJAQAAAA==.',
Xx='Xxm:BAAALgAECgcJBwAAAA==.',
['一一']='一一半神一一:BAAALgAECgMJAwAAAA==.',
['一毫']='一毫升眼泪:BAAALgAFFAIJAwAAAA==.',
['一笑']='一笑倾城丶:BAAALgAECgEJAgAAAA==.',
['一览']='一览众山小:BAAALgAECgcJBwAAAA==.',
['七月']='七月子音:BAAALgAECgIJAgAAAA==.',
['三修']='三修騎士:BAAALgAECgYJCAAAAA==.',
['丛林']='丛林卡拉猫:BAAALgADCgIJAgAAAA==.',
['丨夕']='丨夕:BAAALgAECgcJBwAAAA==.',
['为啥']='为啥要改名字:BAAALgAECgEJAQAAAA==.',
['为阿']='为阿门祈祷:BAAALgAECgQJBAAAAA==.',
['九爷']='九爷:BAAALgAECgQJBQAAAA==.',
['二等']='二等兵伟健:BAAALgAFFAIJAgAAAA==.',
['云无']='云无月:BAAALgAECgEJAQAAAA==.',
['互相']='互相傷害阿:BAAALgAFFAEJAQAAAA==.',
['五号']='五号坦克:BAAALgAECgIJBQAAAA==.',
['任劳']='任劳任怨:BAAALgADCgYJBgAAAA==.',
['伊莎']='伊莎贝儿:BAAALgADCgkJCQAAAA==.',
['伊莲']='伊莲宝贝:BAAALgAECgEJAgAAAA==.',
['似氺']='似氺灬蓅哖:BAAALgAFFAMJAwAAAA==.',
['你若']='你若安好:BAAALgAECgYJBwAAAA==.',
['你还']='你还好吗:BAAALgAECgUJCAABLgAFFAUJEgAIALMgAA==.',
['俺寻']='俺寻思基里馒:BAACLgAFFH8IAAIGAAMJNRDqFgD2AAAGAAMJNRDqFgD2AAAuAAQKfycAAgYACAk6IpoDAI0CAAYACAk6IpoDAI0CAAAA.',
['健丶']='健丶风暴烈酒:BAAALgADCgMJAwAAAA==.',
['六饼']='六饼:BAAALgADCgEJAQAAAA==.',
['冰丶']='冰丶羽:BAAALgAFFAIJAwAAAA==.',
['冰霜']='冰霜老怪:BAAALgAECgkJCQAAAA==.冰霜芝华士:BAAALgAECgYJCwAAAA==.',
['刘等']='刘等等不失误:BAAALgAECgcJAwAAAA==.刘等等的劣人:BAAALgAFFAQJAgAAAA==.',
['剑九']='剑九:BAAALgADCgIJAgAAAA==.',
['勿忘']='勿忘我神:BAAALgAECgEJAwAAAA==.',
['北晨']='北晨:BAABLgAECn8XAAIMAAgJax+MAgCVAgAMAAgJax+MAgCVAgAAAA==.',
['医用']='医用毓婷:BAAALgADCgIJAgAAAA==.',
['半缘']='半缘君:BAAALgAECgEJAQAAAA==.',
['卡蒙']='卡蒙贝尔:BAABLgAECn8dAAINAAgJriSZDQAtAwANAAgJriSZDQAtAwAAAA==.',
['卡門']='卡門灬芝士:BAABLgAECn8YAAIOAAgJ3RekJADUAQAOAAgJ3RekJADUAQAAAA==.',
['卧槽']='卧槽丨法师耶:BAAALgAECgkJBwAAAA==.',
['卧江']='卧江子:BAAALgAFFAIJAgAAAA==.',
['呜喵']='呜喵王:BAAALgAECgYJBgAAAA==.',
['哈吉']='哈吉米:BAAALgAECgYJAgAAAA==.',
['唐加']='唐加三勺:BAAALgAECgEJAQAAAA==.',
['喳喳']='喳喳:BAAALgAECgEJAQAAAA==.',
['噜噜']='噜噜呼:BAAALgAECgEJAQAAAA==.',
['噬咩']='噬咩:BAAALgAFFAIJBAAAAA==.',
['噬喵']='噬喵:BAAALgAECgUJBgAAAA==.',
['四队']='四队戦士:BAAALgAECgIJAwAAAA==.',
['国宝']='国宝级大叔丶:BAAALgADCgEJAQAAAA==.',
['圣傲']='圣傲天:BAAALgADCgUJBQAAAA==.',
['圣光']='圣光与农药:BAAALgAECgcJBgAAAA==.圣光木寒烟:BAAALgAECgUJDwAAAA==.圣光老浴霸:BAAALgAECgEJAQAAAA==.',
['圣言']='圣言术:BAAALgAECgEJAwAAAA==.',
['地精']='地精老人:BAAALgAECgMJAwAAAA==.',
['坚挺']='坚挺的豆腐:BAAALgADCgcJBwAAAA==.',
['塔哒']='塔哒塔娜:BAAALgAECgEJAQAAAA==.',
['塞克']='塞克拉迦:BAAALgAFFAEJAQAAAA==.',
['壊壊']='壊壊牧:BAAALgADCgIJAgAAAA==.',
['多奶']='多奶的公牛:BAAALgADCgYJBgAAAA==.',
['夜里']='夜里有风:BAAALgAFFAIJBAAAAA==.',
['夜风']='夜风:BAAALgAFFAIJAgAAAA==.',
['大原']='大原娜娜子:BAAALgAECgEJAwAAAA==.',
['大圣']='大圣:BAAALgAECgYJDwAAAA==.',
['大木']='大木师:BAACLgAFFH8QAAMPAAQJAB5aAQB6AQAPAAQJAB5aAQB6AQAQAAQJPwX8CwAYAQAuAAQKfycAAw8ACAl3IOUDACkCAA8ACAl3IOUDACkCABAACAlyEl4VAPwBAAAA.',
['大齙']='大齙牙:BAABLgAFFH8IAAIMAAQJ0xGcBABYAQAMAAQJ0xGcBABYAQAAAA==.',
['天国']='天国星坠:BAAALgAECgcJEwAAAA==.',
['天堂']='天堂娇花:BAAALgAFFAQJBAAAAA==.',
['天赐']='天赐发疯:BAACLgAFFH8OAAMHAAQJWxnlAwBEAQAHAAQJWxnlAwBEAQARAAIJ3gX9GwCIAAAuAAQKfx0ABAcABwn5Ik8SAJACAAcABwn5Ik8SAJACABEAAgmSHNODAIQAABIAAQmeD8csADMAAAAA.',
['天魔']='天魔狂杀:BAAALgAECgMJAwAAAA==.',
['太阳']='太阳骑士:BAAALgAECgYJCgAAAA==.',
['头孢']='头孢呋辛氵娜:BAAALgADCgEJAQAAAA==.',
['奥莉']='奥莉薇亚:BAAALgADCgUJBQAAAA==.',
['女施']='女施主留步:BAAALgAECgYJBgAAAA==.',
['奶昔']='奶昔兔兔酱:BAAALgAECgQJBQAAAA==.',
['奶茶']='奶茶不加糖:BAAALgAECgcJCAAAAA==.',
['妈妈']='妈妈:BAABLgAFFH8JAAIQAAUJRBWrAwC8AQAQAAUJRBWrAwC8AQAAAA==.',
['妹妹']='妹妹:BAAALgADCgYJCQAAAA==.',
['妹子']='妹子加我战网:BAAALgAECgcJBwAAAA==.',
['姊丶']='姊丶風婇依舊:BAAALgAECgEJAQAAAA==.',
['宇宇']='宇宇:BAAALgAECgEJAQAAAA==.',
['安迪']='安迪巴特:BAAALgAFFAIJBAAAAA==.',
['宮永']='宮永咲:BAAALgAECggJCQAAAA==.',
['宿醉']='宿醉在花间:BAAALgADCgEJAQAAAA==.',
['小九']='小九流香:BAAALgAECgYJBgAAAA==.',
['小偷']='小偷一一号:BAAALgAFFAQJBAAAAA==.小偷三三号:BAAALgAECgkJEwAAAA==.小偷九号:BAAALgAFFAQJBAAAAA==.小偷二二号:BAABLgAFFH8IAAMCAAQJux0zEAABAQACAAMJ1hozEAABAQABAAEJayZHAgBvAAAAAA==.小偷二号:BAAALgAECgUJBQAAAA==.小偷十二号:BAAALgAFFAQJBAAAAA==.小偷十号:BAAALgAECgkJCQAAAA==.小偷四四号:BAAALgAECgcJBwAAAA==.',
['小婲']='小婲笙:BAAALgAFFAQJBAAAAA==.',
['小小']='小小偷二号:BAAALgAECgcJBwAAAA==.小小偷四号:BAAALgAECgkJDwAAAA==.',
['小柒']='小柒月:BAAALgAFFAIJAgAAAA==.',
['小熙']='小熙熙笑嘻嘻:BAAALgAFFAEJAgAAAA==.',
['小苏']='小苏:BAAALgAFFAIJAgAAAA==.',
['小虎']='小虎牙丢丢:BAAALgAECgEJAQAAAA==.',
['小野']='小野宝宝:BAAALgAECgMJAwAAAA==.',
['小鼻']='小鼻嘎:BAAALgAECgYJDAAAAA==.',
['尛筱']='尛筱冰:BAAALgADCgEJAQABLgAFFAIJBAAFAAAAAA==.',
['岂能']='岂能无牌:BAAALgAECgQJBwAAAA==.',
['岢薆']='岢薆啲菇凉:BAAALgAECgEJAQAAAA==.',
['巴拉']='巴拉焦:BAAALgAECgYJDQAAAA==.',
['帅气']='帅气的罗少:BAAALgAECgcJAQABLgAFFAYJAwAFAAAAAA==.',
['帝辛']='帝辛:BAAALgAECgEJAQAAAA==.',
['幸福']='幸福的便便:BAAALgADCgYJBgAAAA==.',
['幺鸡']='幺鸡:BAABLgAFFH8FAAMPAAIJihZVDACdAAAQAAIJ1xOJCgCkAAAPAAIJ0hNVDACdAAABLgAFFAIJCAARACsgAA==.',
['广志']='广志不要哭:BAAALgAECgQJAwAAAA==.',
['康康']='康康宝贝:BAAALgAECgEJAgAAAA==.',
['弥灬']='弥灬珈:BAAALgAECgEJAQAAAA==.',
['往昔']='往昔热络:BAAALgAECgEJAQAAAA==.',
['心上']='心上有人:BAABLgAECn8XAAITAAcJ5R+jHAAdAgATAAcJ5R+jHAAdAgAAAA==.',
['心灵']='心灵丶震撼:BAAALgAECgcJCAAAAA==.',
['怒风']='怒风怒雷:BAAALgAECgUJBQAAAA==.',
['怶怶']='怶怶:BAAALgAECgEJAgAAAA==.',
['恶魔']='恶魔腾飞:BAAALgAECgEJAQAAAA==.',
['想要']='想要两颗西柚:BAAALgAECgYJDAAAAA==.',
['愣愣']='愣愣:BAAALgADCgIJAgAAAA==.',
['懒懒']='懒懒的番茄:BAAALgAECgYJDwAAAA==.',
['我不']='我不是个秃子:BAAALgADCgYJBgAAAA==.',
['战轶']='战轶心:BAAALgAECgIJAwABLgAFFAIJBAAFAAAAAA==.',
['戦獵']='戦獵:BAAALgAECgQJBAAAAA==.',
['扁担']='扁担哥们:BAAALgAECgkJCgAAAA==.',
['批批']='批批:BAABLgAECn8UAAIMAAcJ/hvUIgA1AgAMAAcJ/hvUIgA1AgAAAA==.',
['拼点']='拼点没输过:BAACLgAFFH8KAAMIAAMJKCUlCgBGAQAIAAMJKCUlCgBGAQABAAIJ7QnRBgCiAAAuAAQKfyQAAwEACAlQGCsMABgCAAEABwnZGSsMABgCAAgABQm1GiIdAJsBAAAA.',
['捕风']='捕风的大叔:BAAALgAECgQJCwAAAA==.',
['提拉']='提拉米苏:BAAALgAECgYJBgAAAA==.',
['揽月']='揽月归:BAAALgADCgEJAgAAAA==.',
['搓个']='搓个大气球:BAABLgAECn8YAAIUAAgJNBtGCwAZAgAUAAgJNBtGCwAZAgAAAA==.',
['摩洛']='摩洛哥炒饼:BAAALgAECgUJBQAAAA==.',
['支棱']='支棱起来:BAAALgAECgIJAgAAAA==.',
['放着']='放着我来丶:BAAALgAECgYJBgABLgAFFAMJAwAFAAAAAA==.',
['无敌']='无敌小恺:BAAALgAECgcJBwAAAA==.',
['无耻']='无耻之徒丶:BAAALgAECgUJCwAAAA==.',
['暖棍']='暖棍常相伴:BAAALgAECgQJBAAAAA==.',
['曾經']='曾經只是浮雲:BAAALgAECgEJAgAAAA==.',
['最初']='最初的信仰:BAAALgAFFAIJAgAAAA==.',
['月之']='月之阴暗面:BAAALgAECgYJDgABLgAFFAMJAwAFAAAAAA==.',
['月神']='月神之爱:BAABLgAFFH8MAAIRAAQJDSA8BQB7AQARAAQJDSA8BQB7AQAAAA==.',
['木白']='木白:BAABLgAECn8UAAMVAAkJIxpJDgDOAgAVAAkJIxpJDgDOAgAMAAQJbBA9jADFAAAAAA==.',
['杀幻']='杀幻月白:BAAALgADCgYJBwAAAA==.',
['杠纠']='杠纠纠:BAAALgAECgEJAgAAAA==.',
['杨仔']='杨仔:BAAALgAECgUJBQAAAA==.',
['极限']='极限尕流氓:BAAALgAECgEJAQAAAA==.',
['柠檬']='柠檬吃柑橘丶:BAAALgAECgkJDwAAAA==.',
['核心']='核心骑士:BAAALgAECgEJAQAAAA==.',
['梦境']='梦境之子:BAAALgAECgEJAgAAAA==.',
['楓嫣']='楓嫣月:BAACLgAFFH8HAAMJAAQJrxD+EwBKAQAJAAQJOxD+EwBKAQAWAAEJSwR6GQBKAAAuAAQKfx4AAwkACAmAHnMgAJYCAAkACAmAHnMgAJYCABYAAgkbGNxMAIcAAAAA.',
['横艾']='横艾:BAAALgAECgEJAgAAAA==.',
['樱花']='樱花飘雪:BAAALgAECgYJBwAAAA==.',
['橙雙']='橙雙橙對丶:BAAALgAECgYJBwAAAA==.',
['欧皇']='欧皇小恐龙:BAAALgAECgcJBwAAAA==.',
['武修']='武修宁姚丶:BAAALgAECgMJAwAAAA==.',
['毛毛']='毛毛术:BAAALgAFFAIJAgAAAA==.毛毛猪:BAAALgAECgMJBwAAAA==.',
['气得']='气得龙咚墙:BAAALgAECgcJBwAAAA==.',
['没冇']='没冇病:BAACLgAFFH8LAAILAAQJBhOjEgA8AQALAAQJBhOjEgA8AQAuAAQKfx4AAwsACAnzG+YjAHoCAAsACAnpGuYjAHoCABcAAQkpFDdmAEsAAAAA.',
['泰裤']='泰裤辣:BAAALgAECgQJCQAAAA==.',
['流光']='流光飞舞丶:BAABLgAECn8ZAAIPAAYJliYrDACQAgAPAAYJliYrDACQAgAAAA==.',
['淡淡']='淡淡的忧:BAAALgAFFAIJAgAAAA==.',
['深刻']='深刻思想:BAAALgAECgQJBAAAAA==.',
['淼燚']='淼燚焱炎:BAAALgADCgUJBQAAAA==.',
['渐渐']='渐渐伤感:BAAALgAECgYJDAAAAA==.',
['满目']='满目星辰:BAAALgAECgcJBwAAAA==.',
['潜龍']='潜龍五用:BAAALgAECgIJAwAAAA==.',
['激光']='激光生成器:BAAALgAFFAEJAQAAAA==.',
['火车']='火车头:BAAALgAECgcJBwABLgAECgkJFwAEAMAcAA==.',
['火锅']='火锅英雄:BAAALgAECgEJAQAAAA==.',
['灬虾']='灬虾米龍灬:BAAALgADCgEJAgABLgAFFAUJBQAYADcPAA==.',
['灭霸']='灭霸的响指:BAAALgADCgEJAQAAAA==.',
['炎焱']='炎焱燚淼:BAAALgAECgUJDAAAAA==.',
['炎爆']='炎爆:BAAALgAECgIJBgAAAA==.',
['炭烧']='炭烧脆皮肠:BAAALgAECgYJBgAAAA==.',
['烷胺']='烷胺:BAAALgAECgUJEAAAAA==.',
['熙熙']='熙熙笑嘻嘻:BAAALgAECgQJBAAAAA==.',
['爬爬']='爬爬熊与猪头:BAAALgAECgEJAQAAAA==.',
['爱与']='爱与希望:BAAALgAECgEJAgAAAA==.',
['爹地']='爹地不姓李:BAAALgAECgYJDwAAAA==.',
['爹爹']='爹爹:BAAALgAECgcJDAAAAA==.',
['牙儿']='牙儿张背投:BAAALgADCgQJBAAAAA==.',
['牛有']='牛有缺:BAAALgAFFAIJAgAAAA==.',
['牛狩']='牛狩猎:BAAALgAECgIJAgAAAA==.',
['牛腩']='牛腩腌面:BAAALgAECgUJBQAAAA==.',
['狂龙']='狂龙贝勒:BAACLgAFFH8JAAIIAAQJcyG3AgCKAQAIAAQJcyG3AgCKAQAuAAQKfxkAAggACAk4HtoIAKoCAAgACAk4HtoIAKoCAAAA.',
['独狼']='独狼咆哮:BAAALgAECgEJAQAAAA==.',
['猎户']='猎户者:BAAALgAECgEJAgAAAA==.',
['玛格']='玛格汉步兵:BAAALgAECgUJBQAAAA==.',
['班集']='班集体的小丑:BAABLgAFFH8HAAIRAAMJJw95EADlAAARAAMJJw95EADlAAAAAA==.',
['現代']='現代也有神:BAAALgAFFAIJAgAAAA==.',
['琉心']='琉心:BAAALgADCgMJAwAAAA==.',
['琴冉']='琴冉:BAAALgADCgEJAQAAAA==.',
['瑞灬']='瑞灬萌萌:BAAALgAFFAMJAwAAAA==.',
['甘甘']='甘甘:BAAALgAECgQJBAAAAA==.',
['甜唇']='甜唇:BAAALgADCgEJAQAAAA==.',
['电哥']='电哥打电钻:BAAALgAECgMJBQAAAA==.',
['疾风']='疾风迅雷:BAAALgAECgUJBQAAAA==.',
['睁眼']='睁眼看世界:BAAALgAECgEJAQAAAA==.',
['短尾']='短尾蝮:BAABLgAFFH8GAAINAAIJwxVgPQCkAAANAAIJwxVgPQCkAAAAAA==.',
['砍瓜']='砍瓜切菜:BAAALgAFFAEJAQAAAA==.',
['礼公']='礼公:BAAALgAECgcJBwAAAA==.',
['神奈']='神奈備命:BAABLgAECn8YAAIUAAgJCxuRUABGAgAUAAgJCxuRUABGAgAAAA==.',
['神尾']='神尾觀鈴:BAABLgAECn8eAAIZAAkJnhSYDgCbAQAZAAkJnhSYDgCbAQAAAA==.',
['秋名']='秋名山山神:BAABLgAFFH8JAAIKAAUJ7xeeAwC2AQAKAAUJ7xeeAwC2AQABLgAFFAcJBgAGANsXAA==.',
['童子']='童子尿:BAAALgAECgUJBQAAAA==.',
['笛敏']='笛敏特:BAAALgADCgEJAQAAAA==.',
['符华']='符华:BAAALgAECgEJAgAAAA==.',
['等待']='等待你的是我:BAAALgAECgYJCAAAAA==.',
['筱鑫']='筱鑫鑫:BAAALgAECgkJCQAAAA==.',
['米小']='米小苏:BAAALgAECgYJDAAAAA==.',
['紫枫']='紫枫残泪:BAABLgAFFH8FAAIGAAUJvAxwCABuAQAGAAUJvAxwCABuAQAAAA==.',
['紫颖']='紫颖小满妞:BAAALgAECgYJBgAAAA==.',
['红辣']='红辣椒:BAAALgAECgYJDgAAAA==.',
['红颜']='红颜祸氺:BAAALgAECgEJAQAAAA==.',
['绝对']='绝对不冷:BAAALgAECgEJAQAAAA==.',
['肚里']='肚里有墨:BAAALgAECgcJCgABLgAECgcJFwATAOUfAA==.',
['肥身']='肥身的召唤:BAAALgAECgkJCQAAAA==.',
['背叛']='背叛自我:BAAALgAECgIJAQAAAA==.',
['腹黑']='腹黑嘟嘟兔:BAAALgAECgQJBAAAAA==.',
['舅婆']='舅婆的小苦瓜:BAAALgAECgEJAQAAAA==.舅婆的小青菜:BAABLgAFFH8IAAIRAAIJKyA1FAC6AAARAAIJKyA1FAC6AAAAAA==.',
['艳罗']='艳罗镜典:BAAALgAECgEJAQAAAA==.',
['艾斯']='艾斯德斯:BAAALgAECgEJAgAAAA==.',
['花拳']='花拳细腿:BAABLgAFFH8GAAITAAMJmhbYDgCfAAATAAMJmhbYDgCfAAAAAA==.',
['花落']='花落又一季:BAAALgAECgYJCQAAAA==.花落犹念:BAABLgAFFH8FAAINAAIJMg0yQQCfAAANAAIJMg0yQQCfAAAAAA==.',
['芽衣']='芽衣:BAAALgAECgEJAQAAAA==.',
['若英']='若英冰封:BAAALgAECgQJBQAAAA==.',
['荒野']='荒野夜羽:BAAALgAFFAIJAgAAAA==.',
['药水']='药水店:BAAALgAECgQJBAAAAA==.',
['萨克']='萨克买迪克:BAABLgAFFH8FAAIHAAMJnQ9YCADvAAAHAAMJnQ9YCADvAAAAAA==.',
['萩水']='萩水悠悠:BAAALgADCgEJAQAAAA==.',
['萩风']='萩风烈烈:BAAALgAECgMJAwAAAA==.',
['落叶']='落叶飘:BAAALgAECgMJAwAAAA==.',
['落月']='落月飞雪:BAAALgAECgEJAQAAAA==.',
['葡萄']='葡萄喵喵:BAAALgAECgQJBAAAAA==.',
['葫芦']='葫芦鱼:BAAALgADCgEJAQAAAA==.',
['蒜鸟']='蒜鸟丶:BAAALgAECgEJAgAAAA==.',
['薄荷']='薄荷喵喵:BAAALgADCgYJBgAAAA==.',
['薛闲']='薛闲:BAAALgAECgQJBAAAAA==.',
['蝉衣']='蝉衣:BAAALgAFFAEJAQAAAA==.',
['蝶唲']='蝶唲丶:BAAALgADCgQJBAAAAA==.',
['血占']='血占戈:BAAALgAECgEJAQABLgAFFAUJCQAKAGgbAA==.',
['裁决']='裁决湍流:BAAALgAECgkJEgAAAA==.',
['记忆']='记忆里的岁月:BAAALgAFFAIJAwAAAA==.',
['许云']='许云卿:BAAALgADCgMJAwAAAA==.',
['贫血']='贫血术师:BAAALgAECgQJBAAAAA==.',
['赶快']='赶快还我钱:BAAALgAFFAIJBAAAAA==.',
['輪回']='輪回依然:BAAALgAECgEJAQAAAA==.',
['辛巴']='辛巴酋长:BAAALgAECgUJBQAAAA==.',
['近视']='近视的射浪:BAAALgAFFAQJAQAAAA==.',
['还是']='还是熊啊:BAAALgAECgYJDAAAAA==.',
['追忆']='追忆乂鵬:BAAALgADCgQJBAAAAA==.',
['還苛']='還苛以:BAAALgAECgkJDwAAAA==.',
['钱公']='钱公子:BAAALgAECgEJAQAAAA==.',
['银白']='银白铠甲:BAAALgAECgIJAgAAAA==.',
['键盘']='键盘毁灭者:BAAALgADCgEJAQAAAA==.',
['闷声']='闷声作大死:BAAALgADCgMJAwAAAA==.',
['闷骚']='闷骚瘦骨爹:BAAALgAFFAIJBAAAAA==.',
['阿奶']='阿奶奶:BAAALgAECgMJAwAAAA==.',
['阿替']='阿替卡因:BAAALgAECgQJBgAAAA==.',
['阿格']='阿格拉玛:BAAALgADCgEJAQAAAA==.',
['陆郗']='陆郗:BAAALgAECgYJCgAAAA==.',
['陈韵']='陈韵如:BAAALgAECgUJBQAAAA==.',
['陌上']='陌上悠然:BAAALgAECgQJBAAAAA==.',
['隆科']='隆科多丶:BAABLgAFFH8FAAINAAIJ/STwLgDcAAANAAIJ/STwLgDcAAAAAA==.',
['青砚']='青砚:BAAALgAECgYJDAAAAA==.',
['风之']='风之岚:BAAALgAECgEJAQAAAA==.风之盐酸:BAAALgAECgYJBgAAAA==.',
['风暴']='风暴烈酒小陈:BAAALgADCgEJAQAAAA==.',
['风语']='风语岚:BAAALgAECgEJAQAAAA==.',
['饱嗝']='饱嗝:BAAALgAFFAEJAQAAAA==.',
['马保']='马保国:BAAALgAECgUJBwAAAA==.',
['马勺']='马勺:BAAALgAECgUJBQAAAA==.',
['鬼剑']='鬼剑:BAAALgAECgUJBQAAAA==.',
['魔幻']='魔幻儛歩:BAAALgAECgEJAQAAAA==.',
['鮮血']='鮮血騎士灬:BAAALgAECgEJAQAAAA==.',
['黄沙']='黄沙丶落叶:BAAALgADCgIJAgAAAA==.',
['黎明']='黎明的光辉:BAABLgAECn8VAAIGAAcJ7BZ2UQDtAQAGAAcJ7BZ2UQDtAQAAAA==.',
['黑太']='黑太黑了:BAAALgADCgUJBQAAAA==.',
['黑暗']='黑暗魔骑:BAAALgAFFAIJAgAAAA==.',
['黑烟']='黑烟圈:BAAALgAECgUJCAAAAA==.',
['龙武']='龙武:BAAALgAECgcJBwAAAA==.',
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
