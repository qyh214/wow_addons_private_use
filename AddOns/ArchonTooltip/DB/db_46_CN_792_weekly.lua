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

local lookup = {'Hunter-Survival','Warlock-Demonology','DemonHunter-Devourer','Paladin-Holy','DeathKnight-Blood','Unknown-Unknown','Mage-Frost','Shaman-Elemental','Druid-Restoration','Paladin-Retribution','Priest-Discipline','Priest-Holy','Priest-Shadow','Warrior-Arms','Warrior-Fury','Warrior-Protection','Monk-Mistweaver','Druid-Balance','Druid-Guardian','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Unholy','Warlock-Affliction','Warlock-Destruction','Shaman-Enhancement','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Shaman-Restoration','DeathKnight-Frost','Monk-Brewmaster','Monk-Windwalker','Mage-Fire','Rogue-Subtlety','Rogue-Assassination','DemonHunter-Havoc',}
local provider = {region='CN',realm='翡翠梦境',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Allblue:BAAALgAFFAIJAgAAAA==.',
An='Antifragile:BAAALgAECgEJAQAAAA==.',
Ar='Ariette:BAAALgAECgQJAgAAAA==.',
Bl='Blackfish:BAAALgAECgUJCgAAAA==.',
Cd='Cdfish:BAAALgADCgEJAQAAAA==.',
Da='Daico:BAAALgAECgYJBgAAAA==.',
Dq='Dqd:BAAALgAECgcJEwAAAA==.',
El='Elenion:BAAALgAFFAEJAQAAAA==.',
Fa='Fastcontrol:BAAALgAECgIJAwAAAA==.',
Ha='Haruka:BAABLgAECn8aAAIBAAgJeiBPAwD1AgABAAgJeiBPAwD1AgAAAA==.',
He='Healwolf:BAAALgAECgMJAwAAAA==.',
Hi='Hikaruex:BAAALgAECgcJEwAAAA==.Hitpipi:BAABLgAFFH8GAAICAAIJoyE4KQDPAAACAAIJoyE4KQDPAAAAAA==.',
Ho='Ho:BAAALgAECgcJBwAAAA==.',
Ic='Icaros:BAAALgAFFAEJAQABLgAFFAIJBgACAAQPAA==.Icecold:BAAALgAECgQJBQAAAA==.',
Ir='Ironwoman:BAAALgAECgcJEQAAAA==.',
Ja='Jaina:BAAALgAECgYJDAAAAA==.',
Je='Jeanned:BAAALgAECgcJDQAAAA==.',
Ki='Kise:BAABLgAFFH8HAAIDAAMJkRsTGAAPAQADAAMJkRsTGAAPAQAAAA==.',
Li='Lionhearts:BAACLgAFFH8MAAIEAAQJCBZrBwBdAQAEAAQJCBZrBwBdAQAuAAQKfx4AAgQACQnBHiYGAAkDAAQACQnBHiYGAAkDAAAA.',
Me='Meeres:BAABLgAECn8WAAIFAAYJER78EgDdAQAFAAYJER78EgDdAQAAAA==.Meowthird:BAEALgAECgEJAQABLgAECgkJCgAGAAAAAA==.Merodach:BAAALgAECgYJBgAAAA==.',
Mi='Minji:BAAALgAECgcJDwABLgAFFAMJAgAGAAAAAA==.Missq:BAAALgAECgYJDwAAAA==.',
Mo='Molière:BAAALgAECgYJBgAAAA==.Moonstars:BAAALgADCgYJBgAAAA==.',
My='Myyt:BAAALgAFFAIJAgAAAA==.',
Na='Nabiki:BAAALgAECgUJCQAAAA==.Nafa:BAAALgAECgkJCgAAAA==.Nassul:BAAALgADCgcJBwABLgAECgYJBgAGAAAAAA==.',
Ne='Nefarin:BAAALgAECgcJDgAAAA==.Nekoryo:BAABLgAFFH8IAAIHAAMJ0AoCLgD+AAAHAAMJ0AoCLgD+AAAAAA==.',
On='Onepunchman:BAABLgAECn8VAAIEAAYJUiU6EgCBAgAEAAYJUiU6EgCBAgAAAA==.',
Ro='Robin:BAAALgAECgIJAwAAAA==.',
Sa='Sapphire:BAACLgAFFH8FAAIIAAIJTRMAFQCmAAAIAAIJTRMAFQCmAAAuAAQKfxUAAggACAnTHt4LANwCAAgACAnTHt4LANwCAAAA.',
Se='Serafim:BAAALgAECgYJDAAAAA==.Setusna:BAAALgAFFAIJAwAAAA==.',
Ta='Taurean:BAAALgADCgEJAQAAAA==.',
Td='Tdliche:BAAALgAECgEJAQAAAA==.',
Th='Thoopos:BAABLgAFFH8FAAIJAAMJSCDPBwAVAQAJAAMJSCDPBwAVAQAAAA==.',
Uu='Uuni:BAAALgAECgQJBwAAAA==.',
Vi='Victhor:BAAALgAECgUJBQAAAA==.Virystle:BAABLgAECn8UAAIKAAcJihh4EwCqAQAKAAcJihh4EwCqAQAAAA==.',
Xl='Xlssod:BAAALgAECgYJBgAAAA==.',
Xm='Xmpriest:BAACLgAFFH8LAAMLAAQJwx1bBgB7AQALAAQJwx1bBgB7AQAMAAEJwBblFABBAAAuAAQKfxQABAsACQkzHTwLAIQCAAsABwnkHTwLAIQCAAwABglrGFYyAHcBAA0AAQkECmxlAC4AAAAA.',
Yk='Ykzs:BAACLgAFFH8SAAMOAAUJSyOdAQBMAQAPAAQJECAQBwB7AQAOAAQJTCSdAQBMAQAuAAQKfxMABA8ABgkKJngrAAgCAA8ABQmAJXgrAAgCAA4AAgnOJQEkAM0AABAAAQl6EHBGADQAAAAA.',
Yu='Yukinovo:BAAALgAFFAIJAgABLgAFFAYJFwARAJclAA==.',
Zh='Zhenzaiyumen:BAAALgAECgMJBAAAAA==.',
['一只']='一只国宝:BAAALgAECgEJAQAAAA==.一只小爪子:BAAALgAECgEJAwAAAA==.一只鬼:BAAALgAECgcJDQAAAA==.',
['一可']='一可可洛一:BAAALgAECgcJDAAAAA==.',
['一叶']='一叶轻舟:BAAALgAECgYJBgAAAA==.',
['一朵']='一朵小白花:BAAALgAECgYJDQAAAA==.',
['一良']='一良伴一:BAAALgAECgYJBgAAAA==.',
['七海']='七海海:BAAALgAECggJCQAAAA==.',
['三个']='三个太阳:BAAALgADCgQJAwAAAA==.',
['三减']='三减一等于几:BAAALgAECgQJBwAAAA==.',
['三地']='三地鼠:BAAALgAECgcJCgAAAA==.',
['三笠']='三笠艾克曼:BAAALgAECgYJBgAAAA==.',
['上山']='上山打小鸟:BAAALgAECgcJEAAAAA==.',
['上帝']='上帝每每:BAAALgAECgcJBwAAAA==.',
['下午']='下午停水:BAAALgAECgEJAQAAAA==.',
['不够']='不够成熟:BAAALgADCgMJAwAAAA==.',
['不想']='不想变成熊豹:BAAALgADCgEJAQABLgAFFAUJCwASAAgHAA==.',
['不灭']='不灭月神:BAAALgAECgYJDwAAAA==.不灭龙神:BAAALgAECgUJBgAAAA==.',
['不爱']='不爱吃芥末:BAAALgADCgkJCQAAAA==.',
['丞丞']='丞丞丶:BAAALgAECgYJBgAAAA==.',
['丨安']='丨安和昴丨:BAAALgAECgEJAQAAAA==.',
['丨木']='丨木丨木:BAAALgADCgUJBQAAAA==.',
['丨萨']='丨萨满丨:BAAALgADCgcJBwAAAA==.',
['个头']='个头不高啊:BAAALgADCgEJAQAAAA==.',
['丰川']='丰川祥子:BAAALgAECgkJCwAAAA==.',
['临安']='临安袭初雨:BAAALgAECgYJDAAAAA==.',
['丶但']='丶但丁:BAAALgAECgIJAwAAAA==.',
['丶君']='丶君子不救:BAAALgAECgEJAQAAAA==.',
['丶嗜']='丶嗜酒成性:BAAALgAFFAQJBAAAAA==.',
['丶水']='丶水果刀:BAAALgAECgkJDgAAAA==.',
['丶秩']='丶秩序:BAAALgADCggJCAAAAA==.',
['丶逍']='丶逍遥:BAAALgAFFAQJBAAAAA==.',
['为了']='为了圣光丶:BAAALgAECgQJBAAAAA==.',
['为遇']='为遇见你伏笔:BAAALgADCgEJAgAAAA==.',
['丿晓']='丿晓:BAABLgAFFH8GAAITAAMJngfnAwCdAAATAAMJngfnAwCdAAAAAA==.',
['乂稀']='乂稀飯你的笑:BAAALgAECgcJBwAAAA==.',
['乄稀']='乄稀飯你的筱:BAAALgAECgQJBAAAAA==.',
['久遠']='久遠寺有珠:BAABLgAECn8aAAIHAAcJqRcUZQAOAgAHAAcJqRcUZQAOAgAAAA==.',
['乌鸦']='乌鸦坐飞鸡:BAAALgAECgIJAgAAAA==.',
['乍幺']='乍幺包:BAAALgADCgEJAQAAAA==.',
['乔七']='乔七世:BAABLgAFFH8FAAIUAAQJ6AI3BAD2AAAUAAQJ6AI3BAD2AAAAAA==.',
['九天']='九天鸣雷:BAAALgAECgYJDAAAAA==.',
['书香']='书香年华:BAAALgAECgIJAwAAAA==.',
['乾为']='乾为天:BAAALgAECgkJEAAAAA==.',
['二话']='二话不说就干:BAAALgAECgMJBgAAAA==.二话圣骑:BAAALgAECgIJAgAAAA==.二话战吊:BAAALgAECgEJAQAAAA==.',
['云白']='云白:BAAALgAECgcJCAAAAA==.',
['云鬓']='云鬓乱:BAAALgAECggJDgAAAA==.',
['五龙']='五龙抱柱:BAAALgADCgcJBwAAAA==.',
['亚麦']='亚麦灬呆:BAAALgAECgUJDAAAAA==.',
['从来']='从来吃不胖:BAAALgAECgYJDQAAAA==.',
['传丶']='传丶说:BAABLgAFFH8GAAIIAAIJyyJdCgDCAAAIAAIJyyJdCgDCAAAAAA==.',
['佟主']='佟主任:BAAALgAECgkJDgAAAA==.',
['你听']='你听我解释:BAABLgAECn8WAAMVAAcJghU2MgDnAQAVAAcJghU2MgDnAQABAAUJewecIADYAAAAAA==.',
['佳佳']='佳佳爱:BAAALgAFFAEJAQAAAA==.',
['依修']='依修托利:BAABLgAFFH8IAAIWAAQJTx83DgBpAQAWAAQJTx83DgBpAQAAAA==.',
['俏宝']='俏宝小公主:BAAALgADCgIJAgAAAA==.',
['倾听']='倾听之喃:BAAALgAECgQJAwAAAA==.',
['傲寒']='傲寒丶:BAABLgAFFH8OAAMWAAYJtR62AADYAQAWAAUJtR62AADYAQAFAAEJAABaDwAAAAAAAA==.',
['傲风']='傲风:BAAALgAECgIJAgAAAA==.',
['元乄']='元乄宝:BAAALgAECgkJCQABLgAFFAUJBAAGAAAAAA==.',
['元婴']='元婴一术:BAABLgAECn8aAAMCAAcJuh4/DwC5AQACAAcJmB4/DwC5AQAXAAQJeRTBFADkAAAAAA==.',
['先生']='先生您要的糖:BAACLgAFFH8GAAICAAIJBA+FNQCoAAACAAIJBA+FNQCoAAAuAAQKfx0ABAIABwmbIq4bAK8CAAIABwmbIq4bAK8CABcAAglfG9IbAJUAABgAAQkAABt8ACQAAAAA.',
['兜儿']='兜儿里有糖:BAAALgAECgQJBwAAAA==.',
['养猪']='养猪妹:BAAALgAECgMJAwAAAA==.',
['养鸡']='养鸡妹:BAAALgAECgUJBQAAAA==.',
['内心']='内心的怒吼:BAAALgAECgUJBgAAAA==.',
['军机']='军机老萌:BAAALgAFFAYJAwAAAA==.',
['冥兵']='冥兵:BAAALgADCgEJAQAAAA==.',
['冬天']='冬天的神牧:BAAALgAECgYJBgAAAA==.',
['冬暖']='冬暖丨夏凉:BAAALgAFFAIJAgABLgAFFAQJDAACAIUXAA==.',
['冯将']='冯将军:BAAALgAECgEJAQAAAA==.',
['冰火']='冰火奥随机:BAAALgAFFAQJBAAAAA==.',
['冰钰']='冰钰倾城:BAAALgADCgIJAgAAAA==.',
['冷萃']='冷萃浮乐朵:BAAALgAECgkJEQAAAA==.',
['冻不']='冻不死的牛:BAAALgAECgYJDQAAAA==.',
['准备']='准备生气:BAAALgAECgEJAQAAAA==.',
['凡人']='凡人修贤:BAAALgAFFAIJAgAAAA==.',
['刘羽']='刘羽菲:BAABLgAFFH8GAAIFAAMJ8BdfBQD4AAAFAAMJ8BdfBQD4AAAAAA==.',
['别礼']='别礼:BAAALgAECgUJBQAAAA==.',
['别过']='别过丶:BAAALgAFFAEJAQAAAA==.',
['前方']='前方之光:BAAALgADCgcJBwAAAA==.',
['剑来']='剑来丶:BAABLgAFFH8FAAMUAAQJGxMyDgBCAQAUAAQJGxMyDgBCAQAVAAEJGQX6HgBPAAAAAA==.',
['勇敢']='勇敢牛牪犇:BAAALgAECgUJBQAAAA==.',
['北月']='北月丶:BAAALgADCgEJAQAAAA==.',
['十七']='十七月葬:BAAALgAFFAEJAQAAAA==.',
['十二']='十二夜堕天使:BAAALgADCgcJBwABLgAFFAIJAgAGAAAAAA==.',
['千代']='千代智咲:BAAALgAECgQJCAAAAA==.千代沙季:BAAALgAECgMJBAAAAA==.千代真尋:BAAALgAECgIJAgAAAA==.千代結衣:BAAALgADCgUJBQAAAA==.千代絵美里:BAAALgAECgQJBwAAAA==.',
['千兆']='千兆:BAABLgAFFH8GAAIIAAMJtxiwDgACAQAIAAMJtxiwDgACAQAAAA==.',
['千山']='千山我独行:BAAALgADCgEJAQAAAA==.千山暮雪:BAAALgADCgQJBAAAAA==.',
['半夏']='半夏青空:BAAALgADCgUJBQAAAA==.',
['南僧']='南僧一灯:BAAALgAECgkJEgAAAA==.',
['南头']='南头村:BAAALgADCgQJBAAAAA==.',
['南星']='南星丶:BAAALgADCgcJBwAAAA==.',
['卡比']='卡比兽:BAAALgAECgYJDQABLgAFFAMJAwAGAAAAAA==.',
['叁毛']='叁毛:BAAALgAECgIJAwAAAA==.',
['发魅']='发魅魔啦:BAAALgAECgQJBAAAAA==.',
['只奶']='只奶妹妹:BAAALgAECgcJBwAAAA==.',
['可乐']='可乐曜曜:BAAALgADCgYJBgAAAA==.',
['叶绪']='叶绪先:BAABLgAFFH8PAAIJAAUJ+RHHBQB9AQAJAAUJ+RHHBQB9AQAAAA==.',
['吃了']='吃了魔:BAAALgAECgYJBgAAAA==.',
['吉尔']='吉尔瓦伦丁:BAAALgAECgIJAgAAAA==.',
['吉浜']='吉浜千代:BAAALgAECgQJAwAAAA==.',
['吕秀']='吕秀才:BAAALgAECgEJAQAAAA==.',
['君子']='君子蘭:BAABLgAFFH8IAAMVAAMJpSSjBQBJAQAVAAMJpSSjBQBJAQAUAAEJIgObLABAAAAAAA==.',
['吴彦']='吴彦丹:BAAALgAECgQJAQAAAA==.',
['呀丶']='呀丶魔鬼:BAAALgADCgEJAQAAAA==.',
['告别']='告别的时代:BAAALgAECgQJBQAAAA==.',
['咕咕']='咕咕叫:BAAALgAECgUJBgAAAA==.咕咕嘎嘎丶:BAACLgAFFH8OAAMIAAQJogwoBgAYAQAIAAQJBggoBgAYAQAZAAMJoguIAwDyAAAuAAQKfx4AAxkACAk4H4MFAK0CABkACAmOHoMFAK0CAAgAAgkYFgZtAI8AAAAA.',
['咲良']='咲良歌:BAAALgAFFAEJAQABLgAFFAUJDAARAFsjAA==.',
['哈吉']='哈吉米:BAAALgADCgEJAQAAAA==.',
['哈白']='哈白想:BAAALgAECgYJDQAAAA==.哈白瞎:BAAALgAECgYJCwAAAA==.',
['唐贰']='唐贰牛:BAAALgAECgYJDwABLgAECgcJBwAGAAAAAA==.',
['唯此']='唯此一心:BAAALgAECgYJBwAAAA==.',
['唱歌']='唱歌跑调:BAAALgAECgUJBwAAAA==.',
['啦文']='啦文:BAABLgAECn8UAAIVAAcJNh1IHQBWAgAVAAcJNh1IHQBWAgAAAA==.',
['喵三']='喵三:BAEALgAECgkJCgAAAA==.',
['喵喵']='喵喵虫:BAAALgAFFAMJAwAAAA==.',
['喵眠']='喵眠月下:BAAALgAECgYJCwAAAA==.',
['嗜血']='嗜血星光宝:BAAALgAECgcJCAAAAA==.',
['嗨炸']='嗨炸:BAAALgAECgEJAQAAAA==.',
['嗷呜']='嗷呜王:BAAALgAECgMJCAAAAA==.',
['嘟妹']='嘟妹:BAAALgAECgQJBgAAAA==.',
['团灭']='团灭小能手:BAAALgAECgEJAQAAAA==.',
['圆头']='圆头耄耋:BAAALgAECgUJBQAAAA==.',
['圆滚']='圆滚滚土豆德:BAAALgADCgUJBQAAAA==.',
['土豆']='土豆小恶魔:BAAALgAECgEJAQABLgAECgQJBgAGAAAAAA==.',
['圣一']='圣一卡西:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光牛乳茶:BAABLgAECn8dAAMKAAkJfRjVGgDIAgAKAAkJfRjVGgDIAgAEAAcJPBIYPACJAQAAAA==.',
['圣斗']='圣斗士:BAACLgAFFH8LAAIEAAQJBBZOCQBAAQAEAAQJBBZOCQBAAQAuAAQKfyEAAgQACQk2Fb4dACgCAAQACQk2Fb4dACgCAAAA.',
['圣爱']='圣爱贝贝:BAAALgAECgcJCAAAAA==.',
['地底']='地底恶魔:BAAALgAECgEJAQAAAA==.',
['地藏']='地藏:BAAALgAECgYJBgAAAA==.',
['坚持']='坚持不上班:BAABLgAECn8YAAMaAAcJyRzJFgCHAQAaAAYJeg7JFgCHAQAbAAUJFhvVJwB+AQAAAA==.',
['埋了']='埋了埋了:BAABLgAFFH8GAAINAAMJJR1gCQAmAQANAAMJJR1gCQAmAQAAAA==.',
['壹粒']='壹粒蛋丶乐疯:BAAALgADCgMJAwAAAA==.',
['夏微']='夏微凉:BAAALgAECgEJAgAAAA==.',
['夕月']='夕月:BAACLgAFFH8SAAIJAAUJmyMzAQAVAgAJAAUJmyMzAQAVAgAuAAQKfyUAAgkACQk7I6ABAIsDAAkACQk7I6ABAIsDAAAA.',
['多多']='多多肉肉:BAAALgADCgEJAQAAAA==.',
['多拉']='多拉格尼尔:BAAALgAECgQJBgAAAA==.',
['大屁']='大屁墩:BAAALgADCgEJAQAAAA==.',
['大熊']='大熊崽:BAAALgADCgYJBgAAAA==.大熊猫:BAAALgAECgEJAQAAAA==.',
['大红']='大红熊:BAAALgAECgEJAQAAAA==.',
['大老']='大老千:BAAALgADCgEJAQAAAA==.',
['大胖']='大胖只玩奶萨:BAAALgAFFAIJAgAAAA==.',
['大跳']='大跳扑街:BAAALgAECgcJBwAAAA==.',
['大雷']='大雷童鞋:BAAALgAECgkJAgABLgAFFAYJDgAOANUkAA==.',
['大龙']='大龙人:BAAALgADCgUJBwAAAA==.',
['天堂']='天堂之拳:BAAALgADCgIJAgAAAA==.天堂圣礼:BAAALgADCgcJBwAAAA==.天堂洗礼:BAAALgADCgcJBwAAAA==.天堂灵能:BAAALgAECgYJEQAAAA==.',
['太白']='太白云灭:BAABLgAFFH8GAAICAAIJqCMvKgDJAAACAAIJqCMvKgDJAAAAAA==.',
['奇遇']='奇遇:BAAALgAECgUJBQAAAA==.',
['奔放']='奔放的蔬菜:BAAALgAECgMJAwAAAA==.',
['奔跑']='奔跑的奶骑:BAABLgAFFH8GAAIKAAMJIxGVDQD4AAAKAAMJIxGVDQD4AAAAAA==.',
['奥利']='奥利奥麦旋风:BAAALgAECgcJCgAAAA==.',
['女拳']='女拳大帝:BAAALgAFFAIJAgAAAA==.女拳師:BAAALgAECgEJAQAAAA==.女拳糕手:BAABLgAFFH8XAAIRAAYJlyWiAACEAgARAAYJlyWiAACEAgAAAA==.',
['奶糖']='奶糖菟菟:BAABLgAECn8XAAICAAcJuBJyWwC2AQACAAcJuBJyWwC2AQAAAA==.',
['奶茶']='奶茶不加奶:BAAALgAECgEJAQAAAA==.奶茶丶:BAAALgAFFAUJBAAAAA==.',
['奶萌']='奶萌兔兔:BAAALgAECgYJBwAAAA==.',
['好哥']='好哥哥:BAAALgADCgIJAgAAAA==.',
['好孩']='好孩纸:BAAALgAECgQJCAAAAA==.',
['妙峰']='妙峰山:BAAALgAECgcJCwAAAA==.',
['妙果']='妙果素月天尊:BAAALgAECgEJAQAAAA==.',
['妹抖']='妹抖龙:BAAALgAECgkJCwAAAA==.',
['子时']='子时已到:BAAALgAECgYJCgABLgAFFAIJAgAGAAAAAA==.',
['孟春']='孟春之月:BAAALgAECgEJBAAAAA==.',
['宇宙']='宇宙幻影:BAAALgADCgMJAwAAAA==.',
['安丷']='安丷安:BAAALgAECgEJAQAAAA==.',
['安娜']='安娜丶:BAAALgAECgEJAQAAAA==.',
['宛若']='宛若初见:BAAALgADCgkJDwAAAA==.',
['宝通']='宝通雷脉:BAAALgAECgkJEwAAAA==.',
['实力']='实力开门:BAAALgAECgEJAQAAAA==.实力非酋:BAAALgAECgEJAQAAAA==.',
['富贵']='富贵杏仁虾:BAAALgAECgYJBgAAAA==.',
['寒乀']='寒乀夜:BAABLgAFFH8HAAIWAAMJ0iJGDwAPAQAWAAMJ0iJGDwAPAQAAAA==.',
['寒灬']='寒灬夜:BAAALgAECgEJAQAAAA==.',
['小丿']='小丿熠伟:BAACLgAFFH8HAAMcAAMJihzYDAAWAQAcAAMJihzYDAAWAQAbAAEJmgnJIgBIAAAuAAQKfxoABBwACAkNDwQZAMgBABwACAkNDwQZAMgBABoABQleFz4dAEUBABsABAnMGhczADIBAAAA.',
['小小']='小小战车:BAAALgAECgMJAwAAAA==.小小的天空:BAAALgAECgQJBAAAAA==.',
['小崧']='小崧薯:BAAALgAECgQJBwAAAA==.',
['小德']='小德战车:BAACLgAFFH8FAAIQAAIJuQ47DACHAAAQAAIJuQ47DACHAAAuAAQKfxoAAxAABwlUGiYRAPUBABAABwlUGiYRAPUBAA8AAQniAk+wACoAAAAA.',
['小时']='小时侯可淘了:BAAALgAECgcJEwAAAA==.',
['小星']='小星回:BAAALgAECgEJAQAAAA==.小星的大笨喵:BAAALgAECggJBwAAAA==.',
['小晴']='小晴:BAAALgADCgEJAQAAAA==.',
['小林']='小林未来:BAACLgAFFH8MAAIRAAUJWyPCAQAWAgARAAUJWyPCAQAWAgAuAAQKfxUAAhEACAkDIeUCAF0CABEACAkDIeUCAF0CAAAA.',
['小浣']='小浣熊丶:BAAALgAECgEJAgAAAA==.',
['小火']='小火龙:BAABLgAECn8ZAAIUAAcJmh8CFQCIAgAUAAcJmh8CFQCIAgABLgAECgcJFgAKACwhAA==.',
['小狐']='小狐仙:BAAALgADCgIJAgAAAA==.',
['小狮']='小狮子鱼:BAACLgAFFH8FAAITAAIJqgWaAwBiAAATAAIJqgWaAwBiAAAuAAQKfxcAAhMACAl6FRoKAPkBABMACAl6FRoKAPkBAAAA.',
['小猪']='小猪胖:BAABLgAFFH8FAAINAAMJhSEzCwACAQANAAMJhSEzCwACAQAAAA==.',
['小猴']='小猴子玩神碑:BAAALgAECgEJAQAAAA==.',
['小美']='小美女李哼哼:BAAALgAECgMJBwAAAA==.',
['小舒']='小舒:BAAALgAECgIJAgAAAA==.',
['小重']='小重山:BAAALgAECgEJAQAAAA==.',
['小魔']='小魔女露易丝:BAAALgAFFAEJAQAAAA==.',
['小鸟']='小鸟丶神月:BAAALgAECgcJCgAAAA==.小鸟丶花月:BAAALgAECgcJEwAAAA==.',
['尛乖']='尛乖乖:BAAALgAFFAEJAQAAAA==.',
['居家']='居家大猪:BAAALgAECgYJBgAAAA==.',
['山鬼']='山鬼:BAAALgAECgYJCwABLgAFFAIJAwAGAAAAAA==.',
['岚風']='岚風:BAAALgAECgEJAQAAAA==.',
['嵐姬']='嵐姬:BAAALgAECgUJBgAAAA==.',
['嶺上']='嶺上開花:BAABLgAFFH8EAAICAAMJhBAiGwC+AAACAAMJhBAiGwC+AAAAAA==.',
['已确']='已确定的目标:BAAALgADCgIJAgAAAA==.',
['巴德']='巴德海尔:BAACLgAFFH8GAAIKAAIJCBiTHQC3AAAKAAIJCBiTHQC3AAAuAAQKfxgAAgoACAkHGwMnAIoCAAoACAkHGwMnAIoCAAAA.',
['并非']='并非骑士:BAACLgAFFH8JAAIEAAQJqSWJBACXAQAEAAQJqSWJBACXAQAuAAQKfy8AAgQACAleJfIAAPICAAQACAleJfIAAPICAAAA.',
['幸运']='幸运的小崽儿:BAAALgADCgUJCgAAAA==.',
['幽猫']='幽猫:BAABLgAECn8WAAITAAcJ1RZPCwDcAQATAAcJ1RZPCwDcAQAAAA==.',
['庞羽']='庞羽佳:BAAALgAECgYJDwAAAA==.庞羽佳的乖乖:BAAALgAECgYJBwAAAA==.庞羽佳的娃娃:BAAALgAECgQJAgAAAA==.',
['建材']='建材王总:BAAALgAECgcJBwAAAA==.',
['开天']='开天:BAAALgADCgEJAQAAAA==.',
['弐熊']='弐熊:BAAALgAECgUJBAAAAA==.',
['弗洛']='弗洛洛:BAAALgAECgMJAwAAAA==.',
['强尼']='强尼傲森:BAAALgADCgEJAgAAAA==.',
['强风']='强风吹拂:BAAALgAFFAEJAQAAAA==.',
['彩蛋']='彩蛋儿:BAAALgAECgcJBwAAAA==.',
['影月']='影月谷之歌:BAAALgAECgIJAgAAAA==.',
['征伐']='征伐丶:BAAALgADCgUJBQABLgAFFAgJGQARAMQkAA==.',
['德乳']='德乳伊丶:BAAALgADCgIJAgAAAA==.',
['心事']='心事全在脸上:BAAALgAECgQJBQAAAA==.',
['心容']='心容大海:BAAALgAECgEJAwAAAA==.',
['必出']='必出坐骑:BAAALgAECgcJEwAAAA==.',
['忘川']='忘川丶:BAAALgAECgUJBQAAAA==.',
['念慈']='念慈薇薇安:BAAALgAECgYJDwAAAA==.',
['怕不']='怕不是猪猪呦:BAAALgAECgEJAgAAAA==.',
['悠然']='悠然一熊猫:BAABLgAFFH8IAAIdAAMJcApIEQDdAAAdAAMJcApIEQDdAAAAAA==.',
['悦刻']='悦刻五代:BAABLgAFFH8LAAIKAAQJ1yQWAQCoAQAKAAQJ1yQWAQCoAQAAAA==.',
['悬溺']='悬溺丶:BAAALgAECgYJBgAAAA==.',
['想见']='想见不如怀念:BAACLgAFFH8HAAIMAAMJrR8+BgAbAQAMAAMJrR8+BgAbAQAuAAQKfxUAAwwACAmjHigMAJACAAwACAmjHigMAJACAAsAAQmfCGNZAC8AAAAA.',
['想飞']='想飞的风:BAAALgADCgEJAgAAAA==.',
['愛莉']='愛莉杏菜:BAAALgAECgcJCwAAAA==.',
['愤怒']='愤怒的肉包:BAAALgAECgEJAQAAAA==.',
['慕容']='慕容飞羽:BAAALgADCgEJAQAAAA==.',
['慢慢']='慢慢丶:BAAALgAECgEJAQAAAA==.',
['我不']='我不会武僧:BAAALgAFFAEJAgAAAA==.',
['我去']='我去睡觉啦丶:BAABLgAECn8aAAMWAAgJXR1hLwB6AgAWAAgJAR1hLwB6AgAeAAMJ6xhLDQDZAAAAAA==.',
['我又']='我又没药了:BAABLgAFFH8FAAICAAIJnBX1MgCtAAACAAIJnBX1MgCtAAAAAA==.我又没钱了:BAABLgAFFH8GAAIWAAIJwAsIIwCZAAAWAAIJwAsIIwCZAAAAAA==.我又睡着了:BAAALgAFFAEJAQAAAA==.我又闪现了:BAAALgAECgEJAQAAAA==.',
['我奶']='我奶你个熊:BAACLgAFFH8KAAIfAAQJRx0gBwBhAQAfAAQJRx0gBwBhAQAuAAQKfx8AAx8ACAlOH4IOAK4CAB8ACAlOH4IOAK4CACAAAQmCASSPAA0AAAAA.',
['我差']='我差点笑出声:BAABLgAECn8XAAIKAAcJbiFuIgCgAgAKAAcJbiFuIgCgAgAAAA==.',
['我才']='我才是大空翼:BAAALgADCgIJAgAAAA==.',
['我是']='我是一个小德:BAAALgAECgYJDAAAAA==.我是真的皮:BAAALgADCgUJBgAAAA==.',
['我棱']='我棱多:BAAALgAECgIJAgAAAA==.',
['我爱']='我爱吃火锅:BAAALgADCgUJBQAAAA==.',
['我闪']='我闪我狂闪:BAAALgADCgYJBgAAAA==.',
['战龍']='战龍希尔:BAAALgAECgQJBwAAAA==.',
['戳心']='戳心胖达:BAAALgAECgYJEwAAAA==.',
['执笔']='执笔丶写红尘:BAAALgAECgUJBwAAAA==.',
['抡起']='抡起大锤:BAAALgADCgEJAgAAAA==.',
['抹茶']='抹茶拿铁:BAAALgAECgEJAQABLgAECggJGAAhAJ4WAA==.抹茶红豆卷儿:BAABLgAECn8VAAIiAAcJvhGdLQCUAQAiAAcJvhGdLQCUAQAAAA==.',
['拉琪']='拉琪安:BAAALgADCgEJAQAAAA==.',
['拎壶']='拎壶冲:BAAALgAECgUJBgAAAA==.',
['拥抱']='拥抱的温暖:BAAALgAECgEJAgAAAA==.',
['拿锅']='拿锅:BAAALgAECgQJBAAAAA==.',
['指尖']='指尖沙:BAAALgAECgIJAgABLgAFFAUJDwAEADUiAA==.',
['挖土']='挖土豆的浣熊:BAAALgAECgEJAwAAAA==.',
['掸子']='掸子:BAAALgAECgIJAgAAAA==.',
['提拉']='提拉米苏呀:BAAALgAECgcJEAAAAA==.',
['摩云']='摩云洞小可爱:BAAALgAECggJBwABLgAFFAcJBQAJAMsVAA==.',
['摸鱼']='摸鱼高手:BAAALgAECgYJBgAAAA==.',
['故事']='故事小黄花:BAAALgAECgIJAgAAAA==.',
['故勒']='故勒顿:BAACLgAFFH8IAAMbAAMJHAndEwDdAAAbAAMJHAndEwDdAAAcAAIJdhFfEgCbAAAuAAQKfxYABBwACQnSGQIUAAUCABwABwnOGAIUAAUCABsACAmGDsUeAM0BABoAAwn4C4kuAKQAAAAA.',
['敬汐']='敬汐:BAAALgADCgEJAQAAAA==.',
['敬莹']='敬莹:BAAALgAECgYJDwAAAA==.',
['旋风']='旋风冲锋牛牛:BAAALgAECgQJBAAAAA==.',
['无情']='无情怒火:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌灵牧:BAAALgAECgYJBwAAAA==.',
['无风']='无风丶:BAAALgAECgUJCAAAAA==.',
['时崎']='时崎狂三:BAAALgAECgUJBQAAAA==.',
['明镜']='明镜丶:BAAALgAECgQJBQAAAA==.',
['易山']='易山:BAAALgAECgEJAQAAAA==.',
['星光']='星光猫:BAAALgAECgYJBwAAAA==.',
['星海']='星海丿龙:BAABLgAFFH8FAAIbAAQJtQsdDQAvAQAbAAQJtQsdDQAvAQAAAA==.',
['星陨']='星陨丶月落:BAAALgAECgYJDwAAAA==.',
['星黛']='星黛露:BAAALgAECgcJEwAAAA==.',
['春水']='春水向东流:BAAALgAECgYJCQAAAA==.',
['春雨']='春雨荷露:BAABLgAECn8XAAIcAAkJGR9ZAwAtAwAcAAkJGR9ZAwAtAwABLgAFFAgJGQARAMQkAA==.',
['春风']='春风不相识:BAAALgADCgEJAQAAAA==.',
['晓雪']='晓雪蓝璃:BAAALgAECgYJCwAAAA==.',
['晚上']='晚上烤野猪:BAACLgAFFH8OAAMVAAQJARcMCwAAAQAUAAMJzBOkEwADAQAVAAMJ3RQMCwAAAQAuAAQKfxsAAhQACAmPILMOAMkCABQACAmPILMOAMkCAAAA.',
['晚风']='晚风二十七:BAAALgAFFAQJBAAAAA==.晚风二十三:BAAALgAFFAQJBAAAAA==.晚风二十二:BAABLgAFFH8NAAIJAAUJtSSEAAAoAgAJAAUJtSSEAAAoAgAAAA==.晚风二十五:BAABLgAFFH8JAAIJAAUJRiQfAQAeAgAJAAUJRiQfAQAeAgAAAA==.晚风二十六:BAABLgAFFH8JAAIJAAUJgyXmAAAyAgAJAAUJgyXmAAAyAgAAAA==.晚风二十四:BAAALgAFFAQJBAAAAA==.晚风二号:BAACLgAFFH8IAAIJAAQJmSZ9AQDMAQAJAAQJmSZ9AQDMAQAuAAQKfxUAAgkACQnJIOEGAB4DAAkACQnJIOEGAB4DAAAA.晚风十一:BAABLgAFFH8JAAIJAAUJrSSHAAAlAgAJAAUJrSSHAAAlAgAAAA==.晚风十号:BAABLgAFFH8FAAIJAAQJeyXQAgDCAQAJAAQJeyXQAgDCAQAAAA==.晚风十四:BAABLgAFFH8JAAIJAAUJpSXiAAAzAgAJAAUJpSXiAAAzAgAAAA==.',
['晨曦']='晨曦如初恋:BAEBLgAFFH8GAAIKAAIJryDUGwDBAAAKAAIJryDUGwDBAAAAAA==.晨曦如初见:BAAALgAFFAEJAQAAAA==.晨曦如寒冬:BAEALgAFFAIJAgABLgAFFAIJBgAKAK8gAA==.',
['晨露']='晨露:BAAALgAECgYJBgAAAA==.',
['景清']='景清:BAAALgADCgcJBwAAAA==.',
['晴渡']='晴渡空:BAAALgAECgIJAgABLgAFFAUJDAARAFsjAA==.',
['暗影']='暗影二胖:BAACLgAFFH8GAAINAAMJuhuBCQAiAQANAAMJuhuBCQAiAQAuAAQKfxQAAw0ACAkKHl0RAHMCAA0ABwluHV0RAHMCAAsAAQk7AwxbACwAAAAA.暗影女王:BAAALgADCgcJCAAAAA==.',
['最后']='最后一页:BAAALgAFFAMJBAAAAA==.最后的轻语:BAAALgADCgYJBgAAAA==.',
['月下']='月下兄弟:BAAALgADCgcJBwAAAA==.月下虫虫飞:BAAALgAECgkJCgAAAA==.',
['有机']='有机女孩:BAAALgAECgYJCgAAAA==.',
['木木']='木木枭:BAAALgAECgEJAQAAAA==.',
['未名']='未名:BAAALgADCgcJDgAAAA==.',
['朴彩']='朴彩英:BAABLgAFFH8WAAIEAAYJyCFVAAAsAgAEAAYJyCFVAAAsAgAAAA==.',
['杀一']='杀一是为罪:BAAALgAECgkJCQAAAA==.',
['李小']='李小猪哼哼:BAAALgAECgYJBwAAAA==.',
['杰尼']='杰尼龟:BAABLgAECn8WAAIKAAcJLCHEKQB+AgAKAAcJLCHEKQB+AgAAAA==.',
['极巨']='极巨化流风:BAAALgAECgQJBgAAAA==.',
['林翩']='林翩翩:BAAALgAECgYJDgAAAA==.',
['果味']='果味的钉子:BAAALgADCgEJAQABLgAECgEJAQAGAAAAAA==.',
['枫元']='枫元素:BAAALgAECgEJAQAAAA==.',
['枯华']='枯华:BAAALgAECgcJCwAAAA==.',
['枯法']='枯法者:BAAALgAECgMJBAAAAA==.',
['枳实']='枳实:BAAALgAECgEJAQAAAA==.',
['柒柒']='柒柒德:BAAALgAECgEJAQAAAA==.柒柒骑:BAAALgAECgQJBAABLgAFFAcJBAAGAAAAAA==.',
['柴头']='柴头不是蜀黍:BAAALgAECgkJCQABLgAFFAcJBAAGAAAAAA==.',
['桀骜']='桀骜奶糖:BAABLgAECn8YAAILAAcJ1xWXGwC5AQALAAcJ1xWXGwC5AQAAAA==.',
['桃白']='桃白伯:BAABLgAFFH8HAAMOAAMJYxCMBgCrAAAOAAIJSA6MBgCrAAAPAAIJnxROGACoAAAAAA==.桃白白丶:BAAALgAFFAMJAwAAAA==.',
['桃蓬']='桃蓬蓬:BAAALgAECgkJCQABLgAFFAUJDwASAHsmAA==.',
['梦回']='梦回零五:BAAALgADCgYJBgAAAA==.',
['棉悠']='棉悠悠:BAACLgAFFH8FAAIPAAQJhAwNDABCAQAPAAQJhAwNDABCAQAuAAQKfxkAAxAACAkMIA8FAJUBAA8ABgkPIckjADgCABAABgkcGw8FAJUBAAAA.',
['椒盐']='椒盐丶:BAAALgADCgEJAgAAAA==.',
['横扫']='横扫千军:BAAALgAECgYJCQAAAA==.',
['樱散']='樱散华:BAACLgAFFH8KAAIJAAQJGwqrDAAaAQAJAAQJGwqrDAAaAQAuAAQKfxcAAgkACAlJGLAhADgCAAkACAlJGLAhADgCAAAA.',
['橘子']='橘子咕咕:BAAALgADCgUJBQAAAA==.',
['橘猫']='橘猫:BAAALgADCgQJBAAAAA==.',
['橙德']='橙德:BAAALgADCgYJBgAAAA==.',
['欲海']='欲海饥民:BAAALgAECgYJCwAAAA==.',
['死亡']='死亡从天而降:BAAALgAECgkJEAAAAA==.',
['死欲']='死欲速朽:BAACLgAFFH8FAAICAAMJAiLpFwAxAQACAAMJAiLpFwAxAQAuAAQKfx0AAwIACAmBJMESAOYCAAIABwmBJMESAOYCABgABQliFxQdAGYBAAAA.',
['死神']='死神骑兵:BAAALgAECgUJDwAAAA==.',
['歼星']='歼星丶:BAAALgAECgEJAQABLgAFFAcJBQAJAMsVAA==.',
['毛怪']='毛怪要用力:BAAALgAECgYJAgAAAA==.',
['毛毛']='毛毛熊火:BAAALgAECgkJEQAAAA==.',
['毛线']='毛线球:BAAALgAECgEJAQAAAA==.',
['水晶']='水晶奶一步:BAAALgAECgcJBgAAAA==.',
['水果']='水果刀丶:BAAALgAECgYJDQAAAA==.',
['水火']='水火既济:BAAALgAECgEJAQAAAA==.',
['沐潆']='沐潆淺:BAAALgADCgYJBgAAAA==.',
['沙皮']='沙皮皮一:BAABLgAFFH8IAAIdAAIJYBDUGACYAAAdAAIJYBDUGACYAAAAAA==.',
['没得']='没得酱:BAABLgAECn8XAAIiAAcJfRb+HQAOAgAiAAcJfRb+HQAOAgAAAA==.',
['波枫']='波枫水門:BAAALgAECgMJBQAAAA==.波枫水门:BAAALgAECgIJBAAAAA==.',
['洛丽']='洛丽嗒:BAAALgAECgIJAgAAAA==.',
['活力']='活力鱼串:BAAALgAECgIJAwABLgAECgQJBgAGAAAAAA==.',
['活着']='活着开门:BAAALgAECgYJCQAAAA==.',
['流浪']='流浪过客:BAAALgADCgYJBgAAAA==.',
['浅夏']='浅夏微凉:BAAALgAECgYJDgAAAA==.',
['浣浣']='浣浣熊熊:BAAALgADCgMJAwAAAA==.',
['浪漫']='浪漫胖墩:BAAALgAFFAIJAwAAAA==.',
['浮生']='浮生:BAABLgAECn8YAAMNAAcJUhfoHAD0AQANAAcJUhfoHAD0AQAMAAQJkQ4IWwDHAAAAAA==.浮生丶:BAAALgAECgUJBQAAAA==.',
['浴火']='浴火狂刀:BAAALgADCgMJAwAAAA==.',
['海桐']='海桐:BAAALgAECgQJBQAAAA==.',
['海盗']='海盗熊:BAAALgAECgMJAQAAAA==.',
['海边']='海边看雪落:BAAALgAECgIJAwAAAA==.',
['海鳴']='海鳴館熊優:BAAALgAECgUJBQAAAA==.',
['涂涂']='涂涂丫:BAACLgAFFH8GAAIKAAMJcQxJFwDzAAAKAAMJcQxJFwDzAAAuAAQKfxYAAgoACQkYGwIaAM0CAAoACQkYGwIaAM0CAAAA.涂涂德:BAAALgAECgUJBQAAAA==.',
['涅茧']='涅茧利:BAAALgADCgQJBAAAAA==.',
['消逝']='消逝的诅咒:BAAALgADCgYJBgAAAA==.',
['淡笑']='淡笑橙橙:BAAALgAECgUJBQAAAA==.淡笑红颜:BAAALgAFFAIJAgAAAA==.',
['深海']='深海阳平:BAAALgAECgYJDAABLgAECgkJKQAHAK4iAA==.',
['深责']='深责之切:BAAALgAFFAEJAgAAAA==.',
['清梦']='清梦压星河:BAAALgAECgEJAQAAAA==.',
['渊行']='渊行:BAABLgAECn8XAAMiAAcJxR24GABAAgAiAAcJAh24GABAAgAjAAMJiBCCEwDIAAAAAA==.',
['渡山']='渡山川:BAAALgAECgYJCwAAAA==.',
['渺万']='渺万裏层雲:BAAALgAFFAEJAQAAAA==.',
['湍汾']='湍汾:BAABLgAFFH8FAAIVAAQJywGTDAD+AAAVAAQJywGTDAD+AAAAAA==.',
['溪白']='溪白守静:BAABLgAFFH8HAAIWAAQJ3BUyEgBZAQAWAAQJ3BUyEgBZAQAAAA==.',
['演定']='演定了我说的:BAAALgAFFAEJAQAAAA==.',
['演的']='演的你发幌:BAAALgADCgIJAgAAAA==.',
['澜澜']='澜澜丶:BAAALgAECgMJAwAAAA==.',
['激昂']='激昂:BAAALgAECgUJBQAAAA==.',
['激进']='激进的防御塔:BAAALgAECgYJCgAAAA==.',
['灌汤']='灌汤包:BAAALgAFFAEJAgAAAA==.',
['火花']='火花带闪电丶:BAAALgAFFAIJAwAAAA==.',
['灬战']='灬战灬熊灬:BAAALgADCgYJBgAAAA==.',
['灭星']='灭星丶:BAAALgAECgkJAgABLgAFFAcJBQAJAMsVAA==.',
['炎炎']='炎炎夏日:BAAALgAECgQJDAAAAA==.',
['点个']='点个夜宵吧:BAACLgAFFH8VAAINAAYJPR+BAACBAgANAAYJPR+BAACBAgAuAAQKfykAAg0ACQmfJbgAANkDAA0ACQmfJbgAANkDAAAA.',
['烈火']='烈火炙冰:BAAALgADCgIJAgAAAA==.',
['烧荒']='烧荒:BAAALgAECgUJCAAAAA==.',
['焚天']='焚天利刃:BAAALgAECgcJBwAAAA==.焚天赤狐:BAABLgAECn8eAAQRAAcJ3hb9DQA0AQARAAcJ3hb9DQA0AQAgAAUJewFpLQAsAAAfAAEJAAAAAAAAAAAAAA==.',
['熊不']='熊不睡:BAAALgAECgMJAwAAAA==.',
['熊千']='熊千言:BAAALgAFFAEJAgAAAA==.',
['熊崽']='熊崽子:BAAALgAECgIJAgAAAA==.',
['熊戰']='熊戰士:BAAALgAECgcJEwAAAA==.',
['熊淼']='熊淼:BAAALgADCgEJAQAAAA==.',
['熊熊']='熊熊爱打滚:BAAALgAECgYJBAAAAA==.熊熊院长:BAAALgAECgkJAwAAAA==.',
['熊猫']='熊猫人:BAAALgADCgYJBgABLgAFFAYJGAAbACkgAA==.熊猫是猫:BAAALgAECgYJDwAAAA==.',
['熊药']='熊药水:BAAALgADCgEJAQAAAA==.',
['燃烧']='燃烧机甲:BAAALgADCgYJBgAAAA==.',
['爱优']='爱优薇:BAAALgAECgQJBQAAAA==.',
['爱尔']='爱尔莎:BAAALgAFFAEJAQAAAA==.',
['物理']='物理超度:BAACLgAFFH8IAAIfAAMJQAwTFQDNAAAfAAMJQAwTFQDNAAAuAAQKfxYAAh8ACQk1EGofAAYCAB8ACQk1EGofAAYCAAAA.',
['牵绊']='牵绊丶:BAAALgAECgcJDQAAAA==.',
['犇犇']='犇犇的猎:BAAALgAECgUJCwAAAA==.',
['狂暴']='狂暴番茄:BAAALgAECgEJAQAAAA==.狂暴的小可乐:BAAALgAECgUJCgAAAA==.',
['狂牛']='狂牛骑士:BAAALgAECgEJAQAAAA==.',
['狡诈']='狡诈的联盟僧:BAAALgAECgMJCQAAAA==.',
['狼牙']='狼牙土豆氵:BAAALgAECgcJDQAAAA==.',
['猎开']='猎开:BAABLgAFFH8FAAIUAAMJ0SEIEAAxAQAUAAMJ0SEIEAAxAQAAAA==.',
['猩红']='猩红深渊之嘲:BAAALgADCgEJAQAAAA==.',
['猫咪']='猫咪:BAABLgAECn8XAAIHAAkJDiXwAQDgAwAHAAkJDiXwAQDgAwAAAA==.',
['玉面']='玉面鬼丨竖:BAAALgAFFAIJAwAAAA==.',
['玖贰']='玖贰九:BAAALgAECgUJBQAAAA==.',
['琪姬']='琪姬:BAAALgAECgEJAQAAAA==.',
['瑞士']='瑞士飞鸟:BAAALgAFFAEJAQAAAA==.',
['瑞木']='瑞木:BAAALgAECgQJCAAAAA==.',
['瑪法']='瑪法里奧怒風:BAAALgAECgEJAQAAAA==.',
['瓜大']='瓜大猛:BAAALgAECgQJBAAAAA==.',
['瓦伦']='瓦伦迪亚王子:BAAALgAECgYJDQAAAA==.',
['瓶装']='瓶装闪电:BAAALgAECgUJCAAAAA==.',
['甜橙']='甜橙夫人:BAAALgAECgcJBwAAAA==.',
['生吞']='生吞小龙虾:BAAALgAECgMJBQAAAA==.',
['电方']='电方块:BAAALgAECgEJAgAAAA==.',
['疯魔']='疯魔:BAAALgAECgEJAQAAAA==.',
['病态']='病态:BAABLgAECn8WAAIcAAcJzh7uCwB2AgAcAAcJzh7uCwB2AgAAAA==.',
['白扒']='白扒皮:BAAALgADCgYJBgAAAA==.',
['白日']='白日就是做梦:BAAALgAFFAIJAwAAAA==.',
['白熊']='白熊猫:BAACLgAFFH8IAAICAAMJVhDCIgD5AAACAAMJVhDCIgD5AAAuAAQKfx8AAgIACAn4F7AuAFICAAIACAn4F7AuAFICAAAA.',
['皮卡']='皮卡熊:BAAALgAECgQJCAAAAA==.',
['皮皮']='皮皮法:BAAALgAECgYJCgAAAA==.',
['盛世']='盛世大猫:BAAALgAECgcJBwAAAA==.',
['盛夏']='盛夏:BAAALgAECgEJAgAAAA==.',
['督督']='督督:BAAALgAECgYJDQAAAA==.',
['瞳果']='瞳果果:BAAALgAECgMJAwAAAA==.',
['知世']='知世丶:BAAALgAECgEJAQAAAA==.',
['知识']='知识牛:BAAALgAECgkJCQAAAA==.',
['矮子']='矮子皮:BAAALgAECgYJCgAAAA==.',
['砰砰']='砰砰大猪:BAAALgADCgYJBgAAAA==.',
['硬蛆']='硬蛆:BAAALgAECgMJAwAAAA==.',
['碧空']='碧空清影:BAAALgAECgcJEAAAAA==.',
['碳水']='碳水戒断症:BAAALgADCgUJBQAAAA==.',
['神圣']='神圣的熊叔:BAABLgAECn8WAAIKAAcJryHAIACoAgAKAAcJryHAIACoAgAAAA==.',
['神奇']='神奇的小喵:BAAALgAECgMJAwAAAA==.',
['神家']='神家小冢:BAAALgADCgEJAQAAAA==.',
['秋水']='秋水随风:BAAALgAECgMJBAAAAA==.',
['秘制']='秘制红烧肉:BAAALgAFFAEJAQAAAA==.',
['秩序']='秩序的湮灭:BAAALgAECgYJCQAAAA==.',
['程龙']='程龙:BAAALgAECgYJBgAAAA==.',
['空之']='空之湛蓝:BAAALgADCgcJBwAAAA==.',
['空巢']='空巢长月老贼:BAAALgAECgQJBAAAAA==.',
['竹久']='竹久伦莺胸:BAAALgAECgIJBAAAAA==.',
['笨笨']='笨笨的小少主:BAAALgAECgIJAgAAAA==.',
['第四']='第四天灾:BAAALgAECgcJDgAAAA==.',
['管你']='管你这个那个:BAACLgAFFH8RAAMCAAYJKiIWAQBCAgACAAYJKiIWAQBCAgAYAAMJUhmuBgAGAQAuAAQKfyQAAwIACQn3JTIHAE4DAAIACQn3JTIHAE4DABgAAwn4Gz0oACIBAAAA.',
['米德']='米德拉什:BAAALgAECggJEwAAAA==.',
['糯米']='糯米:BAAALgAECgcJBwAAAA==.',
['紫月']='紫月红唇:BAAALgADCgMJBQAAAA==.',
['红发']='红发龙葵:BAAALgAECgYJBgAAAA==.',
['红烧']='红烧牛肉丶懿:BAAALgAFFAEJAQAAAA==.',
['纯血']='纯血火鹰大神:BAABLgAECn8gAAIHAAgJYB5MCABGAgAHAAgJYB5MCABGAgAAAA==.',
['纯输']='纯输出:BAAALgADCgcJBwAAAA==.',
['纳米']='纳米流风:BAABLgAFFH8FAAIMAAMJfApTCQDRAAAMAAMJfApTCQDRAAAAAA==.',
['终老']='终老:BAAALgAECgEJAQAAAA==.',
['经典']='经典熊猫:BAAALgAFFAMJAwAAAA==.',
['绘世']='绘世之梦丶:BAAALgAECgUJBgABLgAFFAMJBwADAJEbAA==.',
['绳艺']='绳艺大师:BAAALgAECgYJCgAAAA==.',
['绿皮']='绿皮体育生:BAAALgADCgEJAQAAAA==.',
['缥缈']='缥缈孤鸿影丷:BAACLgAFFH8ZAAIRAAgJxCQRAABNAwARAAgJxCQRAABNAwAuAAQKfyUAAhEACQkSJjMAAO8DABEACQkSJjMAAO8DAAAA.',
['罗烧']='罗烧锅:BAAALgADCgMJAwAAAA==.',
['羊只']='羊只死于脱发:BAABLgAFFH8GAAIgAAMJ2gZkCQDZAAAgAAMJ2gZkCQDZAAAAAA==.',
['美丽']='美丽的大红牛:BAAALgAECgYJBwAAAA==.美丽的岩岩:BAAALgADCgUJBQAAAA==.',
['羽翀']='羽翀:BAAALgAECgMJAwAAAA==.',
['翠芸']='翠芸山小甜甜:BAAALgAECgkJBwABLgAFFAQJCAAcAHYZAA==.',
['翡翠']='翡翠小葫芦:BAACLgAFFH8KAAIVAAQJ8x58AgBuAQAVAAQJ8x58AgBuAQAuAAQKfxcAAhUACAnbI30KAPMCABUACAnbI30KAPMCAAAA.',
['老玖']='老玖:BAAALgADCgQJBAAAAA==.',
['考拉']='考拉王:BAAALgAECgYJCwAAAA==.',
['肖晓']='肖晓笑:BAACLgAFFH8LAAMWAAUJGxrZEQD/AAAWAAQJGxrZEQD/AAAFAAMJ+QiaDACqAAAuAAQKfyYAAxYACQmeIm8UAAADABYACQmeIm8UAAADAAUAAwkDEVk1AJYAAAAA.',
['胖大']='胖大熊丶:BAAALgAECgEJAQAAAA==.',
['胖小']='胖小義丶:BAAALgAECgEJAgAAAA==.',
['自己']='自己来哈:BAAALgAECgcJDAAAAA==.',
['臻望']='臻望:BAAALgADCggJCAAAAA==.',
['臻臻']='臻臻的王子:BAAALgAECgMJAwAAAA==.',
['色孽']='色孽:BAAALgADCgEJAQAAAA==.',
['艶舞']='艶舞:BAAALgAFFAMJAwABLgAFFAYJBgALAGgbAA==.',
['艾丽']='艾丽塔:BAAALgAECgEJBAAAAA==.',
['艾瑞']='艾瑞达叔叔:BAAALgAECgYJDwAAAA==.',
['芋圆']='芋圆葡萄:BAAALgAECgYJCAAAAA==.',
['芬达']='芬达不加冰:BAAALgAECgMJAwAAAA==.',
['花未']='花未眠丶:BAAALgADCgEJAQAAAA==.',
['花落']='花落无悔:BAABLgAFFH8JAAIEAAQJER0TBQCMAQAEAAQJER0TBQCMAQAAAA==.',
['苍穹']='苍穹之舞:BAAALgADCgEJAQAAAA==.',
['茶白']='茶白丶莓莓:BAAALgAECgYJBwAAAA==.',
['莉娜']='莉娜丶星月:BAAALgAECgcJCgAAAA==.',
['莫愁']='莫愁芙梦:BAAALgAECgkJCQAAAA==.',
['莫莫']='莫莫拉莫拉:BAACLgAFFH8GAAIVAAMJ5Ro5CQAXAQAVAAMJ5Ro5CQAXAQAuAAQKfxoAAxUACAnCH2ALAOgCABUACAnCH2ALAOgCABQAAQmTF+CHADQAAAAA.',
['莺歌']='莺歌兰德语风:BAAALgAECgYJBwAAAA==.',
['菊花']='菊花香:BAAALgAECgIJBAAAAA==.',
['菜中']='菜中有光:BAABLgAFFH8GAAIEAAMJ+yMmBQA8AQAEAAMJ+yMmBQA8AQAAAA==.',
['菜兰']='菜兰德:BAAALgAFFAIJBAAAAA==.',
['菜菜']='菜菜:BAAALgAECgQJBAAAAA==.',
['萌咕']='萌咕咕:BAAALgAECgcJEQAAAA==.',
['萌德']='萌德熊:BAAALgADCgIJAgAAAA==.',
['萌萌']='萌萌哒圆圆宝:BAAALgAECgYJBgAAAA==.萌萌哒钢铁侠:BAAALgAECgkJCQAAAA==.萌萌的吉祥物:BAAALgADCgEJAQAAAA==.萌萌的豚鼠:BAAALgADCgEJAQAAAA==.',
['萍萍']='萍萍院长:BAAALgAECgcJDQAAAA==.',
['萨满']='萨满技师:BAACLgAFFH8IAAIIAAQJmBwlBgB5AQAIAAQJmBwlBgB5AQAuAAQKfxUAAggACAnbHm0PALACAAgACAnbHm0PALACAAAA.萨满祭司:BAABLgAECn8XAAIdAAgJORK4MgC6AQAdAAgJORK4MgC6AQAAAA==.',
['落姜']='落姜姜:BAAALgAECgYJBgAAAA==.',
['落幕']='落幕丶挽歌:BAAALgADCgQJBAAAAA==.',
['落空']='落空空:BAAALgAECgYJBgAAAA==.',
['落颜']='落颜颜:BAAALgAECgcJBQAAAA==.',
['蒙娜']='蒙娜丽:BAAALgADCgYJBgAAAA==.',
['蒲厷']='蒲厷煐:BAAALgAECgEJAQAAAA==.',
['蓝色']='蓝色熊猫:BAAALgAECgEJAQAAAA==.',
['薛定']='薛定谔之喵:BAAALgAECgIJAwAAAA==.薛定谔滴熊:BAAALgAECgQJBQAAAA==.',
['虎虎']='虎虎:BAAALgAECgYJBgAAAA==.',
['虚空']='虚空空:BAAALgAECgEJAQAAAA==.',
['虛神']='虛神:BAAALgADCgIJAgAAAA==.',
['蛋小']='蛋小粉:BAABLgAECn8cAAIHAAgJ/wrShwDCAQAHAAgJ/wrShwDCAQAAAA==.',
['蜂窝']='蜂窝煤发电机:BAAALgAFFAEJAQAAAA==.',
['蟹黄']='蟹黄:BAAALgAECgcJDwAAAA==.',
['血黯']='血黯残阳:BAAALgAECgYJBgAAAA==.',
['衍涔']='衍涔:BAAALgAECgQJCgAAAA==.',
['补丁']='补丁一:BAAALgAECgIJAQAAAA==.补丁一百:BAAALgAECgUJCQAAAA==.',
['袁天']='袁天罡:BAAALgAECgQJBAABLgAFFAYJBgAIAPsJAA==.',
['裤毛']='裤毛毛求交易:BAABLgAFFH8FAAIDAAUJpw+fEQDqAAADAAUJpw+fEQDqAAAAAA==.',
['要乐']='要乐奈:BAAALgADCgMJAwAAAA==.',
['覆灯']='覆灯火:BAAALgADCgcJBwAAAA==.',
['观世']='观世音:BAAALgAECgYJDgAAAA==.',
['許久']='許久未見:BAAALgAECgIJAgAAAA==.',
['誓约']='誓约胜利之槌:BAABLgAECn8VAAIKAAcJohV7UwDnAQAKAAcJohV7UwDnAQAAAA==.',
['警戒']='警戒区:BAABLgAECn8WAAIKAAcJhxpxQAAkAgAKAAcJhxpxQAAkAgAAAA==.',
['让你']='让你们退钱:BAAALgAECgYJCQAAAA==.',
['让痛']='让痛陪我过夜:BAAALgAECgYJCQAAAA==.',
['试炼']='试炼之光:BAAALgAECgMJAwAAAA==.',
['诛伏']='诛伏赐死:BAAALgAECgMJBgAAAA==.',
['谁喊']='谁喊我:BAAALgAFFAEJAwAAAA==.',
['谁誰']='谁誰谁小疯子:BAAALgAECgYJCAAAAA==.',
['谦诚']='谦诚:BAABLgAFFH8LAAIKAAQJ6hxGBwB8AQAKAAQJ6hxGBwB8AQAAAA==.',
['豌豆']='豌豆嬷嬷:BAAALgAECgcJEQAAAA==.',
['贝木']='贝木泥舟:BAAALgAECgMJAwAAAA==.',
['贰贰']='贰贰叁:BAAALgAECgYJAgAAAA==.',
['赞美']='赞美哈密瓜:BAAALgADCgMJAwAAAA==.',
['赤髯']='赤髯:BAABLgAECn8WAAIWAAcJExYsaAC9AQAWAAcJExYsaAC9AQAAAA==.',
['赵子']='赵子星:BAAALgAECgcJBwAAAA==.',
['趣味']='趣味生煎丶:BAAALgADCgEJAQABLgAFFAIJBgAIAMsiAA==.',
['跟我']='跟我鬼:BAAALgAECgUJBQAAAA==.',
['蹦子']='蹦子:BAACLgAFFH8VAAMDAAYJ4RICBwCzAQADAAYJzRECBwCzAQAkAAQJuA6kAwBMAQAuAAQKfyYAAyQACQn+HesHAOUCACQACQnmHOsHAOUCAAMABwmNE5kXAGYBAAAA.',
['转运']='转运锦鲤鱼王:BAAALgAECgcJEAAAAA==.',
['轻轻']='轻轻听:BAAALgADCgIJAgAAAA==.轻轻风之语:BAAALgAECgcJBwAAAA==.',
['轻风']='轻风逸雲:BAAALgAFFAQJBAAAAA==.',
['达芬']='达芬奇:BAAALgAECgQJBAAAAA==.',
['过期']='过期的虾酱:BAAALgAFFAEJAQABLgAFFAMJBQARAJAXAA==.',
['造梦']='造梦先生:BAACLgAFFH8QAAMfAAYJtw8UDwAKAQAfAAUJ/wkUDwAKAQARAAEJ/wI/DwBEAAAuAAQKfxQAAh8ACQmWCI4zAIIBAB8ACQmWCI4zAIIBAAAA.',
['遗忘']='遗忘的記憶:BAAALgAECgEJAQAAAA==.',
['那个']='那个:BAAALgAECgYJBwABLgAECgcJFgAcAM4eAA==.',
['那月']='那月酱:BAAALgAECgYJBwAAAA==.',
['邪斗']='邪斗士:BAABLgAECn8YAAMkAAcJFBnHEwA1AgAkAAcJFBnHEwA1AgADAAIJWwRTVABRAAAAAA==.',
['邪神']='邪神大熊:BAAALgAECgYJDAAAAA==.',
['邪贺']='邪贺守:BAAALgAECgcJDAAAAA==.',
['郁术']='郁术屮临疯:BAACLgAFFH8MAAICAAQJhRfqDgBmAQACAAQJhRfqDgBmAQAuAAQKfx0AAwIACAmaHlAvAFACAAIABwnIH1AvAFACABgABAnCF+QpABoBAAAA.',
['酒中']='酒中仙:BAABLgAFFH8MAAIRAAYJ2AlUAwDCAQARAAYJ2AlUAwDCAQAAAA==.',
['酒仙']='酒仙踏风行:BAAALgAECgUJBQAAAA==.',
['酒桶']='酒桶二胖:BAAALgADCgYJBgAAAA==.',
['酸菜']='酸菜牛肉面:BAAALgAECgMJAwAAAA==.',
['重整']='重整奶萨荣光:BAAALgAECgQJBQAAAA==.',
['野兽']='野兽灵魂:BAAALgADCgEJAQAAAA==.',
['野猪']='野猪:BAAALgAECgYJCAAAAA==.',
['野蛮']='野蛮丶小猎:BAAALgAECgIJAgAAAA==.',
['量子']='量子蛆:BAAALgAECgUJBQAAAA==.',
['钻洞']='钻洞高手:BAAALgAECgQJBAAAAA==.',
['锈蚀']='锈蚀的钉子:BAAALgAECgEJAQAAAA==.',
['长耳']='长耳朵兔兔:BAAALgAFFAEJAQAAAA==.',
['长谷']='长谷川白:BAABLgAECn8YAAMhAAgJnhY1AwDvAQAhAAcJVxg1AwDvAQAHAAgJdw0/oQCVAQAAAA==.',
['闪子']='闪子:BAAALgADCggJCAAAAA==.',
['闲得']='闲得蛋疼:BAAALgADCgMJAwAAAA==.',
['阎炎']='阎炎:BAAALgAECgEJAQAAAA==.',
['阴阴']='阴阴月色:BAACLgAFFH8FAAIVAAMJvw06GwCWAAAVAAMJvw06GwCWAAAuAAQKfx8AAxUACAlaG/cjAC4CABUACAlaG/cjAC4CABQABgm1EMNLACIBAAAA.',
['阿哈']='阿哈美尼斯:BAAALgADCgEJAQAAAA==.',
['阿珥']='阿珥忒弥斯:BAABLgAFFH8HAAIJAAUJwwq6BABVAQAJAAUJwwq6BABVAQAAAA==.',
['阿耶']='阿耶精华:BAAALgAECgIJAwAAAA==.',
['阿薩']='阿薩斯之淚:BAEBLgAFFH8FAAIWAAUJqh5RAwDQAQAWAAUJqh5RAwDQAQABLgAECgkJEQAGAAAAAA==.',
['阿里']='阿里巴:BAABLgAECn8kAAQCAAgJiB0TIACYAgACAAgJiRwTIACYAgAYAAQJrxWxJAA2AQAXAAEJaRtRKgBLAAAAAA==.',
['随便']='随便起一个:BAAALgAECgYJDAAAAA==.',
['随地']='随地放电:BAAALgAECgUJBQAAAA==.',
['随风']='随风缘尽:BAAALgADCgYJBgAAAA==.',
['隔壁']='隔壁的大佬:BAAALgAECgUJBQAAAA==.',
['隻影']='隻影嚮誰去:BAAALgADCgMJBQAAAA==.',
['雅原']='雅原:BAAALgAECgEJAQAAAA==.',
['雨儿']='雨儿:BAAALgAECgcJEAAAAA==.',
['雲薺']='雲薺:BAAALgAECgkJBwAAAA==.',
['零丁']='零丁:BAAALgAFFAIJAwAAAA==.',
['零丨']='零丨散场:BAAALgAECgEJAQAAAA==.',
['零度']='零度无糖可乐:BAAALgAECgIJAwAAAA==.',
['零时']='零时:BAABLgAFFH8KAAIWAAQJSQyZIAAXAQAWAAQJSQyZIAAXAQAAAA==.',
['零翎']='零翎:BAAALgAECgUJBQAAAA==.',
['雷姬']='雷姬:BAAALgAECgcJBwAAAA==.',
['雷引']='雷引:BAAALgAECgcJDQAAAA==.',
['霜狼']='霜狼首席萨满:BAAALgADCgUJBQAAAA==.',
['露露']='露露缇耶:BAACLgAFFH8IAAIbAAQJhAm2DQAlAQAbAAQJhAm2DQAlAQAuAAQKfxwAAhsACAkIGocOAI0CABsACAkIGocOAI0CAAAA.',
['青冬']='青冬:BAAALgADCgUJBQAAAA==.',
['青雀']='青雀:BAAALgAECgQJBAAAAA==.',
['青龙']='青龙巫师乙:BAAALgAFFAIJAgAAAA==.青龙巫师甲:BAAALgAECgIJAwAAAA==.',
['非专']='非专业魅魔:BAAALgADCgYJBgABLgAFFAYJEQARANshAA==.',
['非想']='非想天则丨:BAAALgAECgYJBgAAAA==.',
['非酋']='非酋:BAAALgAECgYJCAAAAA==.',
['靠落']='靠落叶针:BAAALgAECgMJBAAAAA==.',
['面包']='面包圈酱:BAAALgAECgYJAgAAAA==.',
['風定']='風定落花深:BAAALgAECgQJDwAAAA==.',
['风中']='风中之神:BAAALgAECgcJBAAAAA==.',
['风迹']='风迹:BAAALgAECgEJAQAAAA==.',
['风风']='风风超可爱:BAAALgADCgUJAQAAAA==.',
['飘渺']='飘渺轻风:BAAALgAECgIJAgAAAA==.',
['飘雪']='飘雪艾儿:BAAALgADCgEJAQAAAA==.',
['飞天']='飞天茜茜:BAAALgAECgYJBwAAAA==.',
['饭饭']='饭饭子:BAAALgAECgMJAwAAAA==.',
['饭骑']='饭骑士:BAAALgADCgMJAwAAAA==.',
['香残']='香残玉簟秋:BAAALgADCgYJBgAAAA==.',
['香辣']='香辣烤鹌鹑:BAABLgAECn8VAAMSAAcJjQ4gOQBTAQASAAcJjQ4gOQBTAQAJAAEJtw4iSQAtAAABLgAFFAQJDgAVAAEXAA==.',
['骑士']='骑士洛洛:BAAALgAFFAEJAQAAAA==.',
['骑猪']='骑猪去巡山:BAAALgAECgMJBAAAAA==.',
['高烧']='高烧不断来了:BAAALgAECgYJDgAAAA==.',
['鬼盅']='鬼盅:BAAALgAECgIJAgAAAA==.',
['鬼舞']='鬼舞姬:BAACLgAFFH8FAAIWAAIJBxkSMwC8AAAWAAIJBxkSMwC8AAAuAAQKfxgAAxYABwnuICU2AF4CABYABwnuICU2AF4CAAUAAQmcERNHACwAAAAA.',
['魔力']='魔力圈圈:BAAALgAECggJBwAAAA==.',
['鱼叔']='鱼叔丷:BAAALgAECgcJBwAAAA==.',
['麦芽']='麦芽雪冷萃:BAABLgAECn8gAAMLAAkJXyB1AgBTAwALAAkJ5R91AgBTAwAMAAgJuBURGAAbAgAAAA==.',
['麻轩']='麻轩芸小六:BAAALgADCggJCAAAAA==.',
['麻雀']='麻雀丶:BAAALgADCgYJBgAAAA==.',
['黄九']='黄九郎:BAAALgADCgUJBQAAAA==.',
['黄闪']='黄闪闪:BAAALgAECgYJDAAAAA==.',
['黑皮']='黑皮退伍狼犬:BAAALgAECgYJBgAAAA==.',
['黑铁']='黑铁贞子:BAECLgAFFH8JAAIVAAMJWyA+BwAuAQAVAAMJWyA+BwAuAQAuAAQKfyUAAxUACAn4Ip4GACQDABUACAn4Ip4GACQDABQAAgluGZVwAHwAAAEuAAUUAgkGAAoAryAA.',
['龙族']='龙族少女土豆:BAAALgAECgQJBQABLgAECgQJBgAGAAAAAA==.',
['龙道']='龙道子:BAAALgAFFAEJAQAAAA==.',
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
