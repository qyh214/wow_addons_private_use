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

local lookup = {'Warlock-Demonology','Warlock-Destruction','Mage-Frost','Priest-Holy','Priest-Shadow','Unknown-Unknown','Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Holy','DeathKnight-Unholy','DeathKnight-Blood','Druid-Balance','Paladin-Retribution','Warrior-Protection','Druid-Restoration','Evoker-Preservation','Shaman-Restoration','DemonHunter-Havoc','Warrior-Fury','Warrior-Arms','Monk-Brewmaster','DemonHunter-Devourer','DeathKnight-Frost','Shaman-Elemental','Monk-Windwalker','Evoker-Augmentation','Hunter-Survival',}
local provider = {region='CN',realm='风暴之怒',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ap='Apple:BAAALgADCgEJAQAAAA==.',
Ar='Aragakiyui:BAABLgAFFH8GAAMBAAMJ3wkzJgDnAAABAAMJ3wkzJgDnAAACAAEJ5ABBGwA8AAAAAA==.Archaos:BAAALgAECgcJBwAAAA==.',
As='Asmodai:BAAALgAECgEJAQAAAA==.',
Au='Auramooth:BAAALgAECgYJDAAAAA==.',
Bi='Biubiu:BAAALgAECgcJCAAAAA==.',
Ch='Cherryww:BAAALgAECgcJBgAAAA==.',
Cl='Clairdelune:BAAALgAFFAIJAgAAAA==.',
Cr='Crush:BAAALgAECgYJBwAAAA==.',
Da='Dazz:BAAALgAECgIJAgAAAA==.',
De='Devilsign:BAAALgAECgYJCwAAAA==.Devisigms:BAAALgAFFAEJAQAAAA==.',
Do='Dodge:BAAALgAECgEJAQAAAA==.',
En='Endlessdread:BAAALgAECgYJBwAAAA==.',
Fo='Fondness:BAAALgAECgYJBgAAAA==.',
Ga='Gazz:BAAALgAECgUJCQABLgAFFAcJBQADANERAA==.',
Ha='Hardy:BAAALgAECgcJBwAAAA==.',
He='Heartanjing:BAAALgAECgIJAgAAAA==.Hellbound:BAAALgAECgEJAQAAAA==.Hewasaboy:BAAALgADCgcJCAAAAA==.',
Ho='Honey:BAAALgAECgYJBwAAAA==.',
In='Insidious:BAAALgAECgUJCAAAAA==.',
Ja='Jane:BAAALgAECgIJAwAAAA==.',
Ji='Jills:BAAALgAECgcJEwAAAA==.',
Kb='Kbz:BAAALgAFFAEJAgAAAA==.',
Kk='Kkhk:BAAALgAFFAIJAgAAAA==.',
Kt='Ktcxwg:BAABLgAECn8YAAIEAAYJdRtWCACnAQAEAAYJdRtWCACnAQAAAA==.',
Ky='Kyogre:BAAALgAECgQJAwAAAA==.Kyogree:BAAALgAECgQJBQAAAA==.',
Le='Leoncoeur:BAAALgAECgEJAQAAAA==.',
Li='Lipper:BAAALgAECgkJDAAAAA==.',
Lo='Lovelyberry:BAAALgAECgMJAwAAAA==.',
Ma='Maplee:BAAALgAECgYJBgAAAA==.Mapleea:BAAALgAECgcJBwAAAA==.Mapleeb:BAAALgAECgkJCQAAAA==.Mapleec:BAAALgAECgkJBgAAAA==.Mapleeg:BAAALgAECgkJDAAAAA==.Mapleer:BAABLgAECn8fAAIBAAkJ7RzXCwAcAwABAAkJ7RzXCwAcAwAAAA==.Mapleet:BAAALgAECgkJEAAAAA==.Mapleev:BAABLgAECn8XAAIBAAkJCB0oDwAAAwABAAkJCB0oDwAAAwAAAA==.Mapleey:BAABLgAECn8VAAIBAAkJHBPXLABbAgABAAkJHBPXLABbAgAAAA==.',
Me='Mem:BAABLgAFFH8HAAMEAAIJVxObBwCQAAAEAAIJVxObBwCQAAAFAAEJjgYmFABUAAABLgAFFAcJCgADAO4cAA==.',
Mo='Mover:BAAALgAECgEJAQAAAA==.',
My='Mythic:BAAALgAECgYJBgAAAA==.Mythology:BAAALgADCgEJAQAAAA==.',
Na='Nauticalbull:BAAALgAECgYJBwAAAA==.',
Ne='Nexten:BAABLgAECn8WAAIEAAYJ1BwhJADGAQAEAAYJ1BwhJADGAQAAAA==.',
Or='Oriana:BAAALgAFFAIJBAAAAA==.',
Pa='Papermoon:BAAALgAECggJBgABLgAFFAQJBAAGAAAAAA==.',
Pi='Picco:BAAALgAECgUJBwAAAA==.',
Ra='Ranbo:BAAALgADCgYJBgAAAA==.',
Ro='Rolex:BAAALgAECgYJBgAAAA==.',
Sa='Sanakan:BAAALgAECgUJBQAAAA==.',
Se='Seya:BAAALgADCgEJAQAAAA==.',
Sh='Shewasagirl:BAAALgAECgUJBQAAAA==.',
So='Solidus:BAAALgAECgIJAwAAAA==.',
St='Stag:BAAALgAECgEJAgAAAA==.',
Su='Supershawn:BAAALgAECgYJDQAAAA==.',
Ud='Udian:BAAALgAFFAIJAwAAAA==.',
Ve='Vei:BAAALgADCgYJBgAAAA==.',
Vl='Vlad:BAAALgADCgEJAQAAAA==.',
Vv='Vvallopriest:BAACLgAFFH8HAAIEAAMJvBVVCADjAAAEAAMJvBVVCADjAAAuAAQKfyQAAwQABwm7HUESAE4CAAQABwm7HUESAE4CAAcABAm7EN87AMsAAAAA.',
Wi='Willaw:BAAALgAECgcJDAAAAA==.Wish:BAAALgAECgUJBgAAAA==.',
Yi='Yiyiqiqi:BAAALgAECgkJCAAAAA==.',
Yo='Yokii:BAAALgAECgQJBAAAAA==.',
Yz='Yzztf:BAAALgAFFAMJAwAAAA==.',
Za='Zaku:BAAALgAECgUJBQAAAA==.',
['一怒']='一怒吼韧一:BAACLgAFFH8VAAMIAAUJ3Rm1CgAMAQAIAAMJuRq1CgAMAQAJAAIJSRcQHACmAAAuAAQKfyUAAwgACQnTIFsTAJwCAAgABwnyIFsTAJwCAAkACAnPFVIqANYBAAAA.',
['一根']='一根讼棍:BAAALgAECgYJBwAAAA==.',
['一渡']='一渡鸦一:BAAALgAECgIJBAAAAA==.',
['一百']='一百里玄策一:BAAALgAECgYJBgAAAA==.',
['一碗']='一碗粥:BAAALgAECgIJAgAAAA==.',
['一诺']='一诺休轻许:BAABLgAFFH8FAAIKAAIJiSb6DgDnAAAKAAIJiSb6DgDnAAAAAA==.',
['一颗']='一颗草莓酱:BAABLgAECn8aAAILAAcJ5B3MOABTAgALAAcJ5B3MOABTAgAAAA==.',
['丂迪']='丂迪克:BAABLgAECn8WAAIMAAgJ8BBOFgCwAQAMAAgJ8BBOFgCwAQAAAA==.',
['七星']='七星彩:BAAALgAECgEJAgAAAA==.',
['万三']='万三六九:BAAALgAFFAEJAQAAAA==.',
['三二']='三二一二三:BAAALgAECgMJAwAAAA==.',
['三位']='三位一体德:BAAALgADCgEJAQAAAA==.',
['三十']='三十几个死骑:BAAALgAECggJEAAAAA==.',
['三貝']='三貝勒丶:BAAALgAECgQJBAAAAA==.',
['上杉']='上杉绘梨衣:BAAALgAECgQJBAAAAA==.上杉谦信:BAAALgAECgYJCQAAAA==.',
['下弦']='下弦月天空:BAAALgAECgMJAwAAAA==.',
['不二']='不二林:BAAALgAECgcJCAAAAA==.',
['不变']='不变的惦念:BAAALgAECgEJAQAAAA==.',
['不太']='不太会说话:BAABLgAFFH8FAAIBAAMJvQ0nFQDxAAABAAMJvQ0nFQDxAAAAAA==.',
['不懂']='不懂的小保安:BAAALgAFFAIJAgAAAA==.',
['不拒']='不拒绝者:BAAALgADCgEJAQAAAA==.',
['不用']='不用慌不要慌:BAAALgAFFAIJAgAAAA==.',
['不羁']='不羁的風:BAAALgAECgYJDAAAAA==.',
['不要']='不要太风骚:BAAALgADCgMJAwAAAA==.',
['不蹭']='不蹭了:BAAALgAFFAIJAgAAAA==.',
['丘比']='丘比特一箭:BAAALgAECgQJBAAAAA==.',
['东方']='东方不行:BAAALgAECgYJCAAAAA==.东方不错:BAAALgAECgYJBgAAAA==.',
['丨团']='丨团团灬丨:BAAALgAECgMJAwAAAA==.',
['丨困']='丨困兽之斗丨:BAAALgAECgYJBgAAAA==.',
['丨英']='丨英雄丨:BAAALgAFFAIJBAAAAA==.',
['临终']='临终关怀:BAAALgADCgEJAQAAAA==.',
['丶乌']='丶乌龟的黑头:BAAALgAECgQJBgAAAA==.',
['丶女']='丶女村长:BAAALgAECgMJAwAAAA==.',
['丶普']='丶普罗米斯:BAAALgADCgEJAQAAAA==.',
['丶炒']='丶炒饭加蛋:BAAALgADCgYJCAAAAA==.',
['丶福']='丶福尔迪哥德:BAAALgADCgMJBAAAAA==.',
['丶糖']='丶糖醋蚊子丶:BAAALgAECgIJAwAAAA==.',
['丶紫']='丶紫菜团子:BAAALgAFFAIJAgAAAA==.',
['丶蘭']='丶蘭痞鼠:BAAALgAECgYJBgAAAA==.',
['乄菊']='乄菊:BAAALgAECgEJBAAAAA==.',
['乌力']='乌力力咔咔丶:BAAALgAECggJBwAAAA==.',
['九思']='九思蜀黍:BAAALgAECgQJBQAAAA==.',
['九翼']='九翼幻爵:BAAALgADCgYJBgAAAA==.',
['五乘']='五乘四扫地僧:BAAALgAFFAEJAQAAAA==.',
['亚尔']='亚尔特留斯丶:BAAALgADCgcJBwABLgAFFAMJBQABAL0NAA==.',
['亚萨']='亚萨:BAAALgAECgUJBQABLgAECggJHAANAPceAA==.',
['人间']='人间失格:BAAALgAECgEJAQAAAA==.',
['亿万']='亿万少女的儚:BAAALgADCgMJAwAAAA==.',
['仨蟃']='仨蟃:BAAALgAECggJCQAAAA==.',
['伊洛']='伊洛克希:BAAALgAECgYJCQAAAA==.',
['伍器']='伍器戦:BAAALgADCgIJAgAAAA==.',
['会飞']='会飞的牛:BAAALgAECgEJAQAAAA==.',
['传奇']='传奇的列巴:BAAALgAFFAMJBAAAAA==.',
['低调']='低调小发丝:BAAALgAECgIJAgAAAA==.',
['佐手']='佐手拈花:BAAALgAECgQJBwAAAA==.',
['你特']='你特么劈我瓜:BAAALgAECgQJBAAAAA==.',
['你真']='你真贴心:BAAALgADCgUJBQAAAA==.',
['佩恩']='佩恩:BAAALgADCgIJAgAAAA==.',
['佩萝']='佩萝娜:BAAALgADCgEJAQAAAA==.',
['依然']='依然的阿瑟斯:BAACLgAFFH8PAAIOAAQJORezBQBRAQAOAAQJORezBQBRAQAuAAQKfxcAAg4ACQmIHE0hAKUCAA4ACQmIHE0hAKUCAAAA.',
['假面']='假面人:BAAALgAECgYJCwAAAA==.',
['偶尔']='偶尔躲躲乌云:BAAALgAECgQJBQAAAA==.',
['傲世']='傲世皇妃:BAAALgAFFAEJAQAAAA==.',
['元亨']='元亨利贞:BAAALgAECgQJBAAAAA==.',
['元始']='元始天尊:BAAALgAECgEJAgAAAA==.',
['克罗']='克罗米:BAAALgAECgEJAQAAAA==.',
['兰斯']='兰斯博顿:BAAALgAECgkJBwABLgAFFAcJBAAGAAAAAA==.',
['兽群']='兽群合水泥:BAAALgAECgYJDAAAAA==.',
['冒险']='冒险家:BAAALgAECgYJCQAAAA==.',
['冰奥']='冰奥之子:BAAALgAECgUJDAAAAA==.',
['冰封']='冰封战舞:BAAALgAECgYJCwABLgAFFAcJDQAPAM4ZAA==.冰封暧恋:BAAALgADCgQJBAAAAA==.',
['冰箱']='冰箱里的火腿:BAAALgAECgMJAwAAAA==.',
['冲锋']='冲锋扫堂腿:BAAALgAECgQJBAAAAA==.',
['凫地']='凫地魔:BAAALgAECgkJBQAAAA==.',
['刘羽']='刘羽禅:BAAALgAFFAYJBAAAAA==.',
['功夫']='功夫河马:BAAALgAECgEJAQAAAA==.',
['加冰']='加冰可乐:BAAALgAECgEJAQAAAA==.',
['加藤']='加藤惠:BAABLgAFFH8KAAIDAAMJzBv9JAAgAQADAAMJzBv9JAAgAQAAAA==.',
['劣人']='劣人夹死:BAAALgAECgEJAgAAAA==.',
['动物']='动物园捕猎者:BAAALgAECgUJCgAAAA==.',
['劲松']='劲松六中往事:BAAALgADCgEJAgAAAA==.',
['勿语']='勿语灬:BAAALgAECgIJAgAAAA==.',
['北国']='北国的雪:BAAALgADCgEJAQAAAA==.',
['北客']='北客:BAAALgAECgQJBAAAAA==.',
['北海']='北海龍王:BAAALgAFFAMJBAAAAA==.',
['匪徒']='匪徒先生:BAAALgAECgQJAgAAAA==.',
['十年']='十年起步:BAAALgAECgcJBwAAAA==.十年饮冰:BAAALgAFFAIJAgAAAA==.',
['十步']='十步一煞灬:BAAALgAFFAIJBAAAAA==.',
['半截']='半截的诗:BAAALgAECgYJDAAAAA==.',
['卡莉']='卡莉奥丝特罗:BAAALgAECgkJDgAAAA==.',
['双皮']='双皮奶:BAAALgAECgIJAgAAAA==.',
['变形']='变形春元:BAAALgAECgYJCwAAAA==.',
['叫哥']='叫哥哥:BAAALgAECgMJAwAAAA==.',
['合欢']='合欢宗三师姐:BAAALgAECgEJAQAAAA==.合欢宗小师妹:BAAALgAFFAEJAQAAAA==.',
['吐司']='吐司:BAAALgAECgEJAgAAAA==.',
['君莫']='君莫惜:BAAALgAECgYJDAAAAA==.',
['听琴']='听琴:BAAALgAECgQJBwAAAA==.',
['吮指']='吮指原味基:BAABLgAECn8aAAIQAAgJQxrKJAAnAgAQAAgJQxrKJAAnAgAAAA==.',
['吴月']='吴月娘:BAAALgAECgEJAQAAAA==.',
['吹夢']='吹夢到西洲:BAAALgADCgMJAwABLgADCgYJBgAGAAAAAA==.',
['呆毛']='呆毛守护者:BAAALgAECgcJBwAAAA==.',
['哈妹']='哈妹:BAAALgAECgQJBQAAAA==.',
['哈根']='哈根大师:BAAALgAECgcJEAAAAA==.',
['哞哞']='哞哞酱:BAAALgAECgIJAgAAAA==.',
['唯一']='唯一的狼:BAABLgAFFH8HAAIOAAMJxxXVDAD+AAAOAAMJxxXVDAD+AAAAAA==.',
['喀拉']='喀拉马盖之心:BAAALgADCgQJBAAAAA==.',
['嗜殺']='嗜殺者乄不懂:BAAALgAECgEJAQAAAA==.',
['嘎啦']='嘎啦给木糕手:BAAALgAFFAIJAwABLgAFFAMJCgADAMwbAA==.',
['嘴哥']='嘴哥火:BAAALgAECgEJAQAAAA==.',
['四四']='四四幺幺:BAAALgAFFAIJAgAAAA==.四四幺柒:BAAALgAFFAIJBAAAAA==.',
['国人']='国人上上:BAAALgAECgYJBgAAAA==.',
['土地']='土地局一把:BAAALgAECgUJBQAAAA==.',
['圣光']='圣光忽悠着伱:BAAALgAECgkJDgAAAA==.圣光闪耀:BAAALgADCgIJAgAAAA==.',
['圣玲']='圣玲珑:BAABLgAECn8XAAMEAAkJLx1VBQD7AgAEAAkJLx1VBQD7AgAHAAEJ1BM4UwA8AAAAAA==.',
['圣翼']='圣翼之影:BAAALgAECgYJBgAAAA==.',
['圣言']='圣言莫莫:BAABLgAECn8VAAIHAAgJAh6nAgBRAgAHAAgJAh6nAgBRAgAAAA==.',
['块五']='块五过八:BAAALgAFFAEJAQAAAA==.',
['坚强']='坚强的小蚂蚁:BAAALgADCgEJAQAAAA==.',
['基尼']='基尼太美:BAAALgAECgEJAQAAAA==.',
['基迩']='基迩珈丹:BAAALgAECgcJDQAAAA==.',
['塞纳']='塞纳利恩:BAAALgAECgcJDQAAAA==.',
['墨镜']='墨镜小王子:BAAALgADCgEJAQAAAA==.',
['夏弥']='夏弥:BAABLgAFFH8FAAIRAAUJmRuoAwDKAQARAAUJmRuoAwDKAQAAAA==.',
['夏德']='夏德:BAAALgAECgIJAgAAAA==.',
['夏晴']='夏晴天:BAAALgAECgIJAwAAAA==.夏晴天萨:BAABLgAFFH8FAAISAAMJlRJ0CQDkAAASAAMJlRJ0CQDkAAAAAA==.',
['夏洛']='夏洛克丶:BAAALgADCgYJBgAAAA==.',
['夜店']='夜店一哥:BAAALgAECgIJAgAAAA==.',
['夜生']='夜生白露:BAAALgAECgkJCQAAAA==.',
['夜空']='夜空丶牛牛:BAAALgAECgIJAgAAAA==.',
['大卫']='大卫高怕飞:BAAALgAECgEJAQAAAA==.',
['大和']='大和尚喝小酒:BAAALgAECggJEAAAAA==.',
['大喇']='大喇叭:BAABLgAECn8VAAMKAAkJoh06CgDQAgAKAAkJoh06CgDQAgAOAAEJ9wUmggAjAAAAAA==.',
['大德']='大德:BAABLgAECn8UAAIQAAYJ/BYpVQBUAQAQAAYJ/BYpVQBUAQAAAA==.',
['大桔']='大桔:BAAALgAECgYJBgAAAA==.',
['大爪']='大爪哥:BAAALgAECgQJBAAAAA==.',
['大爷']='大爷来玩会啊:BAAALgAECgEJAQAAAA==.',
['大白']='大白鸭:BAAALgAFFAIJBAAAAA==.',
['大粗']='大粗哥:BAAALgAFFAEJAQAAAA==.',
['大胖']='大胖鱼:BAAALgAECgEJAQAAAA==.',
['天南']='天南韩跑跑:BAAALgADCgIJAgAAAA==.',
['天在']='天在山之外:BAABLgAECn8VAAILAAgJaRU9FwBzAQALAAgJaRU9FwBzAQAAAA==.',
['天官']='天官赐福:BAAALgAFFAIJAwAAAA==.',
['奥能']='奥能残渣:BAABLgAECn8XAAIDAAcJTR8ISABfAgADAAcJTR8ISABfAgAAAA==.',
['奥蒂']='奥蒂卡:BAAALgAFFAEJAQAAAA==.',
['她城']='她城旧诗丶:BAAALgAECgQJBAAAAA==.',
['好吃']='好吃的奶疙瘩:BAAALgAECgEJAQAAAA==.',
['好好']='好好的奶爸:BAAALgAECgMJBAAAAA==.好好的爸爸:BAAALgAECgUJCQAAAA==.',
['妲己']='妲己不是妖:BAAALgAECgMJAgAAAA==.',
['孤独']='孤独为伍:BAAALgADCgQJBAAAAA==.孤独天下:BAAALgADCgIJAgAAAA==.',
['学习']='学习前十五名:BAAALgADCgEJAQAAAA==.学习好身体好:BAAALgADCgEJAgAAAA==.',
['学医']='学医无法救国:BAAALgAECgMJAwAAAA==.',
['宝贝']='宝贝狼:BAAALgAECgYJBgAAAA==.',
['寂寞']='寂寞灬无理:BAAALgAECgMJAwAAAA==.',
['寥落']='寥落已成回憶:BAAALgAECgEJAwAAAA==.',
['封之']='封之冬:BAAALgAECgEJAQAAAA==.',
['将进']='将进酒君莫停:BAAALgADCgUJBQAAAA==.',
['小丹']='小丹妮:BAAALgAECgMJBgAAAA==.',
['小二']='小二浪:BAAALgAFFAIJAgAAAA==.',
['小别']='小别别:BAAALgAECgYJBgAAAA==.',
['小北']='小北零柒:BAAALgADCgUJAQAAAA==.',
['小喇']='小喇叭小:BAAALgAECgMJAgAAAA==.',
['小埋']='小埋丶酱:BAABLgAFFH8HAAIJAAcJ5hQnAAAlAgAJAAcJ5hQnAAAlAgAAAA==.小埋大人:BAAALgAECgIJAgAAAA==.',
['小壊']='小壊蛋:BAAALgADCgIJAgAAAA==.小壊蛋丶丿:BAAALgADCgMJBQAAAA==.',
['小奶']='小奶瓶儿:BAAALgAECgEJAQAAAA==.',
['小小']='小小牛牛德:BAAALgADCgUJBQAAAA==.',
['小师']='小师弟先进:BAAALgAECgYJCAAAAA==.',
['小徳']='小徳:BAAALgAECgYJDAAAAA==.',
['小手']='小手灬乱摸:BAAALgAECgYJDAAAAA==.',
['小时']='小时候可懒啦:BAAALgAECgMJBgAAAA==.',
['小棍']='小棍子:BAAALgAFFAEJAQAAAA==.',
['小淘']='小淘气丶丨:BAAALgAECgEJAQAAAA==.',
['小狗']='小狗子丶:BAAALgAFFAIJAgAAAA==.',
['小狼']='小狼大魔王:BAAALgADCgEJAQAAAA==.',
['小球']='小球萨满:BAAALgAECgYJCwABLgAECggJGQACACEkAA==.',
['小胖']='小胖墩:BAAALgAECgIJAgAAAA==.',
['小菊']='小菊花菠萝茶:BAAALgADCgMJAwAAAA==.',
['小雨']='小雨润如稣:BAAALgADCgEJAQAAAA==.',
['小鸟']='小鸟嗷嗷菜:BAAALgAFFAIJBAAAAA==.',
['小龘']='小龘人:BAAALgAFFAIJAgAAAA==.',
['少女']='少女狼:BAAALgAECgYJCQAAAA==.',
['尛别']='尛别别:BAAALgAECgIJAgAAAA==.',
['尼古']='尼古拉斯炸雷:BAABLgAFFH8MAAITAAQJkxsiAgBzAQATAAQJkxsiAgBzAQAAAA==.',
['山东']='山东大壮汉:BAAALgADCgUJBQAAAA==.',
['岚蓝']='岚蓝:BAAALgADCgEJAQAAAA==.',
['島田']='島田半藏:BAAALgAECgYJDgAAAA==.',
['崇高']='崇高必堕落:BAAALgADCgYJBgAAAA==.',
['工具']='工具头头:BAAALgAECgYJBgAAAA==.',
['巫喵']='巫喵王冲鸭:BAAALgAECgYJDwAAAA==.',
['巭乄']='巭乄小弟:BAAALgAECgQJBAAAAA==.',
['布尔']='布尔丶猫:BAAALgAECgQJBgAAAA==.',
['希龙']='希龙尔:BAAALgAECgMJAwAAAA==.',
['帕拉']='帕拉桀:BAAALgAECgYJEQAAAA==.',
['年轻']='年轻的小牛犊:BAAALgAECgQJBAAAAA==.',
['并不']='并不是锅:BAAALgAECggJDgAAAA==.',
['幸福']='幸福牛牛:BAAALgADCgYJBgAAAA==.',
['幻丶']='幻丶战:BAAALgAECgYJCwABLgAFFAQJCQAUALkKAA==.',
['幻倩']='幻倩倩:BAAALgAFFAQJBAAAAA==.',
['幻火']='幻火:BAAALgAFFAQJBAAAAA==.',
['幻萌']='幻萌萌:BAAALgAECgYJBgAAAA==.',
['幽魂']='幽魂灬祭:BAAALgAFFAMJBAAAAA==.',
['开怀']='开怀墨汁:BAAALgADCgUJBQAAAA==.',
['彪大']='彪大个儿:BAAALgAECgMJAwAAAA==.',
['得乌']='得乌昂:BAAALgAECgEJAQAAAA==.',
['微笑']='微笑的眼睛:BAAALgADCgYJBgAAAA==.',
['德玛']='德玛拉:BAAALgADCgIJAgAAAA==.',
['心之']='心之悄悄丶:BAAALgAECgYJBgAAAA==.',
['忧伤']='忧伤的小绵羊:BAAALgADCgIJAgAAAA==.',
['忧郁']='忧郁得白衬衫:BAAALgAFFAMJAwAAAA==.',
['快乐']='快乐密码:BAAALgAFFAIJAgAAAA==.',
['快跑']='快跑我奶不住:BAAALgAECgMJAwAAAA==.',
['念牙']='念牙隹:BAAALgADCgIJAgAAAA==.',
['思念']='思念的月光丶:BAAALgAECgcJCAAAAA==.',
['恶兔']='恶兔:BAAALgAECgcJCQAAAA==.',
['恶魔']='恶魔乐章:BAAALgAECgYJBgAAAA==.恶魔灬猎手:BAAALgAECgQJBAAAAA==.',
['恶龙']='恶龙丶咆哮:BAAALgAECgEJAQAAAA==.',
['惜玥']='惜玥不负流年:BAAALgAECgEJAQAAAA==.',
['想得']='想得开挺得住:BAABLgAFFH8QAAMUAAYJMSOtAACbAQAUAAQJaiStAACbAQAVAAIJTR4LBgBnAAAAAA==.',
['我不']='我不是扫地僧:BAAALgAECgEJAQAAAA==.我不是治疗:BAAALgAECgEJAQAAAA==.我不谈恋爱:BAAALgAECgEJAQAAAA==.',
['我之']='我之小白:BAAALgAECgcJDQAAAA==.',
['我劝']='我劝你别买:BAAALgAECgEJAQAAAA==.',
['我咋']='我咋死了呢:BAAALgAECgcJAgAAAA==.',
['我家']='我家的狐狸啊:BAAALgAECgQJBAAAAA==.',
['我来']='我来组成腿部:BAAALgAECgYJEAAAAA==.',
['战神']='战神的剑:BAAALgADCgEJAQAAAA==.',
['手一']='手一拉死一哒:BAAALgAECgQJDwAAAA==.',
['打断']='打断鬼才:BAAALgADCgQJBAAAAA==.',
['扛扛']='扛扛:BAAALgAECgIJBAAAAA==.',
['指上']='指上叹冰:BAAALgAFFAIJBAAAAA==.',
['搞笑']='搞笑法:BAABLgAFFH8NAAIDAAQJPB+vBQB/AQADAAQJPB+vBQB/AQAAAA==.',
['摇洲']='摇洲:BAAALgADCgIJAgAAAA==.',
['摇舟']='摇舟:BAACLgAFFH8FAAIBAAMJExQmIAADAQABAAMJExQmIAADAQAuAAQKfxQAAwEABgnQH/1aALcBAAEABQnQH/1aALcBAAIAAwm9AbpUAHAAAAAA.',
['攸乄']='攸乄墨桃:BAAALgADCgUJBQAAAA==.',
['放下']='放下你的黄瓜:BAAALgADCgMJBAAAAA==.',
['数钱']='数钱数到抽筋:BAAALgAECgQJBAAAAA==.',
['斗牛']='斗牛丶奶龙:BAAALgADCgUJBQAAAA==.',
['斯芠']='斯芠:BAAALgAECgkJCQAAAA==.',
['新手']='新手喵:BAAALgADCgQJAwAAAA==.',
['无光']='无光阿宝阿库:BAAALgAFFAIJAgAAAA==.',
['无力']='无力涛涛:BAAALgADCgQJBAAAAA==.',
['无根']='无根大帝:BAAALgAECgEJAQAAAA==.',
['无畏']='无畏的宝宝:BAAALgAECgcJCQAAAA==.',
['既定']='既定之天命:BAAALgADCgcJBwAAAA==.',
['时晴']='时晴时雨:BAAALgAECgYJBgABLgAFFAUJAgAGAAAAAA==.',
['旺仔']='旺仔小笼包:BAAALgAECgYJCQAAAA==.',
['晚分']='晚分吹行舟:BAABLgAFFH8FAAIIAAMJnRIODQD5AAAIAAMJnRIODQD5AAAAAA==.',
['暗夜']='暗夜星辰:BAAALgAECgYJBgAAAA==.',
['最美']='最美:BAAALgAECggJAQABLgAFFAYJAQAGAAAAAA==.',
['月之']='月之守望:BAAALgAECgQJBAAAAA==.',
['月光']='月光徘徊丶:BAAALgAECggJDQAAAA==.',
['月影']='月影孤锋:BAABLgAECn8cAAILAAcJWBrTFgB1AQALAAcJWBrTFgB1AQAAAA==.',
['月玲']='月玲珑:BAAALgAECgcJCgABLgAFFAYJBgAWAJALAA==.',
['朝朝']='朝朝行止丶:BAAALgAFFAUJAgAAAA==.',
['朝阳']='朝阳区吴彦祖:BAAALgAECgUJBQAAAA==.',
['木不']='木不识丁:BAAALgAFFAMJBAAAAA==.',
['木乃']='木乃姨夫:BAAALgAECgEJAQAAAA==.',
['木兰']='木兰档库失:BAAALgAECgIJAgAAAA==.',
['木南']='木南:BAABLgAFFH8FAAIEAAMJ2xEdCADnAAAEAAMJ2xEdCADnAAABLgAFFAcJBAAGAAAAAA==.',
['未光']='未光:BAAALgAECgMJAwAAAA==.',
['本镇']='本镇唯一补头:BAAALgADCgYJBgAAAA==.',
['朴哥']='朴哥:BAAALgAECgYJDAABLgAFFAIJAgAGAAAAAA==.',
['李大']='李大帅:BAAALgAECgUJBgAAAA==.',
['李灬']='李灬团:BAABLgAFFH8HAAMUAAIJlR08FwCsAAAUAAIJEhw8FwCsAAAPAAEJ4CAzDgBkAAAAAA==.',
['李镇']='李镇德李贼贼:BAAALgADCgUJBQAAAA==.',
['来抓']='来抓灵魂兽:BAAALgADCgEJAQAAAA==.',
['松坂']='松坂砂糖:BAAALgAFFAEJAQAAAA==.',
['林深']='林深时雾起:BAAALgAECgYJDAAAAA==.',
['林老']='林老板饺子馆:BAAALgAECgEJAgAAAA==.',
['枪在']='枪在手跟我走:BAAALgAECgcJBwAAAA==.',
['枫夜']='枫夜随影:BAAALgAECgEJAQAAAA==.',
['枯骨']='枯骨成沙:BAAALgADCgUJBQAAAA==.',
['柴门']='柴门闻犬吠:BAAALgAECgYJBgAAAA==.',
['根哥']='根哥:BAAALgAFFAEJAQAAAA==.',
['桀拉']='桀拉斯:BAABLgAFFH8FAAIXAAUJHg68CQAyAQAXAAUJHg68CQAyAQAAAA==.',
['梦中']='梦中的婚礼:BAAALgAECgIJAgAAAA==.',
['梦想']='梦想世界和平:BAAALgAECgEJAQAAAA==.',
['楊家']='楊家怪萝莉:BAAALgADCgYJBgAAAA==.',
['楓月']='楓月清弦:BAAALgADCgUJBQAAAA==.',
['欧露']='欧露媞宁雅:BAAALgADCgEJAgAAAA==.',
['正义']='正义的一方:BAAALgAECgYJBgAAAA==.',
['武器']='武器栈:BAAALgAECgYJBgAAAA==.',
['残乁']='残乁梦:BAACLgAFFH8OAAIUAAQJTxKHAwBTAQAUAAQJTxKHAwBTAQAuAAQKfx0AAhQACQlMGuAhAEUCABQACQlMGuAhAEUCAAAA.',
['比奇']='比奇堡大魔王:BAAALgAECgYJBgAAAA==.',
['毛毛']='毛毛德:BAAALgAECgYJBQAAAA==.',
['气球']='气球:BAAALgAECgIJAgABLgAECgEJAgAGAAAAAA==.',
['沄汐']='沄汐丶:BAABLgAFFH8NAAMEAAQJlBQhBABIAQAEAAQJlBQhBABIAQAHAAMJNQYdCQDYAAAAAA==.',
['没听']='没听说过:BAAALgAECgEJAQAAAA==.',
['法不']='法不累加死:BAAALgAECgUJCgAAAA==.',
['法師']='法師麵包:BAAALgADCgMJAwAAAA==.',
['泷麒']='泷麒麟:BAABLgAFFH8JAAILAAQJwwtiHgAlAQALAAQJwwtiHgAlAQAAAA==.',
['洒家']='洒家要吃酒:BAAALgAECgYJCgAAAA==.',
['派大']='派大吐沫星子:BAAALgAECgIJAwAAAA==.',
['流星']='流星乂蝴蝶劍:BAAALgAECgYJCAAAAA==.',
['涅澜']='涅澜俐:BAAALgAFFAIJBAAAAA==.',
['消失']='消失的她:BAAALgAECgYJCAAAAA==.',
['淡淡']='淡淡丶渢:BAAALgAECgEJAQAAAA==.',
['淮然']='淮然:BAAALgAECgIJAgAAAA==.',
['渃曉']='渃曉貝:BAAALgAECgEJAQAAAA==.',
['清启']='清启尤嫣姬:BAAALgAECgMJBgAAAA==.',
['温水']='温水佳树:BAAALgAFFAEJAQABLgAFFAMJCgADAMwbAA==.',
['澄橙']='澄橙橙:BAAALgAECgMJAwAAAA==.',
['火炮']='火炮轰鸣:BAAALgADCgEJAQAAAA==.',
['火车']='火车驶向云外:BAAALgAFFAIJAgAAAA==.',
['灬猎']='灬猎心:BAAALgAECgQJBwAAAA==.',
['灬花']='灬花辞树灬:BAAALgADCgEJAQAAAA==.',
['灭世']='灭世丶暗:BAAALgADCgEJAQAAAA==.',
['灭日']='灭日圣骑:BAABLgAFFH8JAAIOAAMJiw1XDQD6AAAOAAMJiw1XDQD6AAAAAA==.',
['灰烬']='灰烬合稀泥:BAAALgAFFAEJAQAAAA==.',
['灵动']='灵动八方:BAABLgAECn8UAAMYAAcJtRY0BQDwAQAYAAcJtRY0BQDwAQALAAEJagGaPAEZAAAAAA==.',
['烈霸']='烈霸天:BAAALgAECgIJAgAAAA==.',
['烟雨']='烟雨遥:BAAALgAECgQJBAAAAA==.',
['烧烤']='烧烤的兔子:BAAALgAFFAEJAQAAAA==.',
['焦糖']='焦糖玛奇朵:BAAALgAFFAIJAgAAAA==.',
['熊大']='熊大熊:BAAALgADCgUJBQAAAA==.',
['熊貓']='熊貓酒仙:BAAALgAFFAEJAQAAAA==.',
['燕小']='燕小妮:BAAALgADCgEJAQAAAA==.',
['牛仔']='牛仔仔:BAAALgADCgEJAQAAAA==.',
['牛肉']='牛肉披萨:BAAALgAECgEJAQAAAA==.',
['牛黄']='牛黄安宫:BAAALgAECgEJAQAAAA==.',
['牦灬']='牦灬牛:BAAALgADCgEJAQAAAA==.',
['犀利']='犀利小球:BAABLgAECn8ZAAMCAAgJISQhAADeAgACAAgJISQhAADeAgABAAEJhg7/CwFFAAAAAA==.',
['狂之']='狂之刃:BAAALgAECgEJAQAAAA==.',
['狂徒']='狂徒灬:BAAALgADCgIJAgAAAA==.',
['狂暴']='狂暴思密达:BAAALgAECgcJCAAAAA==.狂暴打鸟工:BAAALgAECgQJBgAAAA==.',
['狂野']='狂野追猎者:BAAALgAFFAEJAQAAAA==.',
['狡猾']='狡猾滴狐狸:BAAALgAECgYJEQAAAA==.',
['狸猫']='狸猫追小羽毛:BAAALgAECgEJAQAAAA==.',
['猎手']='猎手丶大尧:BAAALgADCgUJBQAAAA==.',
['王爆']='王爆炸:BAAALgAECgMJAwAAAA==.',
['玖月']='玖月贰拾九:BAAALgAFFAIJAgAAAA==.',
['玩转']='玩转大风车:BAABLgAFFH8FAAIUAAIJ8hAUDACuAAAUAAIJ8hAUDACuAAAAAA==.',
['玫斯']='玫斯特拉:BAAALgADCgYJBgAAAA==.',
['玲一']='玲一歼灭天使:BAAALgAECgEJAQAAAA==.',
['甜食']='甜食姐姐:BAAALgAFFAIJAgAAAA==.',
['电解']='电解质:BAABLgAFFH8GAAIZAAIJ1hRIFwCaAAAZAAIJ1hRIFwCaAAAAAA==.',
['男神']='男神归来:BAAALgAECgEJAQAAAA==.',
['画漫']='画漫画的:BAAALgADCgcJCgAAAA==.',
['疯枫']='疯枫:BAAALgAECgMJAwAAAA==.',
['疯狂']='疯狂的乔乔:BAAALgAECgIJAwAAAA==.疯狂的德鲁:BAAALgAECgEJAQAAAA==.疯狂的玖哥:BAAALgAECgEJAQAAAA==.',
['疾风']='疾风天降:BAAALgADCgEJAQAAAA==.',
['白丶']='白丶:BAAALgAFFAIJBAAAAA==.',
['白白']='白白胖胖:BAABLgAFFH8IAAIBAAMJRw5bFQDwAAABAAMJRw5bFQDwAAAAAA==.',
['白羊']='白羊阿释密达:BAAALgAECgcJBwAAAA==.',
['白芝']='白芝麻熊:BAAALgAECgkJDwAAAA==.',
['的胆']='的胆固醇:BAAALgAECgMJAwAAAA==.',
['盗圣']='盗圣白玉汤:BAAALgAECgQJBQAAAA==.',
['相父']='相父:BAAALgADCgcJBwAAAA==.',
['破晓']='破晓辰星:BAAALgADCgUJBQAAAA==.',
['神奇']='神奇大老爷:BAAALgAECgYJBgAAAA==.神奇海螺:BAAALgAECgYJBwAAAA==.',
['私奔']='私奔到月球:BAAALgAECgEJAwAAAA==.',
['秋雅']='秋雅丶:BAAALgAECgEJAQAAAA==.',
['空想']='空想森林:BAAALgAECgEJAQAAAA==.',
['笨大']='笨大个儿:BAAALgAECggJCQAAAA==.',
['第二']='第二个死人:BAAALgAECgcJCQAAAA==.',
['筱丶']='筱丶梦:BAAALgAFFAIJAwAAAA==.',
['箐雨']='箐雨:BAABLgAECn8YAAMWAAcJGRTzCQB2AQAWAAcJFhDzCQB2AQAaAAQJNBa5OgAyAQAAAA==.',
['箛謸']='箛謸迋:BAABLgAFFH8JAAIZAAQJUxZQCQBKAQAZAAQJUxZQCQBKAQAAAA==.',
['箫瑟']='箫瑟流光:BAAALgADCgYJBgAAAA==.',
['箭之']='箭之泪:BAAALgAECgEJAQAAAA==.',
['米拉']='米拉娜干妈酱:BAAALgAECgMJBAAAAA==.米拉贝勒:BAAALgAECgUJBQAAAA==.',
['精奇']='精奇比目鱼:BAAALgADCgEJAQAAAA==.',
['精灵']='精灵丨冰冰:BAAALgADCgkJCAAAAA==.精灵丨喵喵:BAAALgADCgkJAQAAAA==.精灵丨萌萌:BAAALgAECgYJBgAAAA==.精灵丨韵韵:BAAALgADCgcJBwAAAA==.精灵牛牛:BAAALgAECgYJBgAAAA==.',
['索尼']='索尼克:BAAALgAFFAIJBAAAAA==.',
['紫电']='紫电法熊:BAAALgAECgkJCAAAAA==.',
['紫魂']='紫魂泽:BAAALgAFFAIJAgAAAA==.',
['絕对']='絕对寶貝:BAAALgAECgYJBgAAAA==.',
['红叶']='红叶初雨:BAABLgAFFH8FAAIKAAMJyRFXCADpAAAKAAMJyRFXCADpAAAAAA==.',
['红鲤']='红鲤鱼:BAAALgAECgcJDQAAAA==.',
['纸墨']='纸墨清鸢:BAAALgAFFAEJAQAAAA==.',
['绝代']='绝代智谋:BAAALgAECgUJBQAAAA==.',
['美卡']='美卡琪:BAAALgAECgYJCwAAAA==.',
['翎熙']='翎熙萌萌哒:BAAALgAECgYJCQAAAA==.',
['老莽']='老莽夫:BAAALgAECgkJBwABLgAFFAYJBAAGAAAAAA==.',
['背叛']='背叛者丶安逸:BAACLgAFFH8FAAISAAMJ7hkECgDcAAASAAMJ7hkECgDcAAAuAAQKfxUAAhIACAlfFusiAA0CABIACAlfFusiAA0CAAAA.',
['自由']='自由自在丶:BAAALgAECgUJCgAAAA==.',
['舒克']='舒克:BAAALgADCgUJBQAAAA==.',
['色空']='色空玄瞳:BAAALgAFFAIJAgAAAA==.',
['艺静']='艺静亦初:BAAALgAECgEJAQAAAA==.',
['芋泥']='芋泥啵啵:BAAALgAECgEJAQAAAA==.',
['芬罗']='芬罗德丶迅刃:BAAALgADCgEJAQAAAA==.',
['芬达']='芬达拌饭:BAAALgAECgIJAgAAAA==.',
['花木']='花木喃:BAAALgAECgUJBQAAAA==.',
['花生']='花生了什么树:BAAALgAECgEJAQAAAA==.',
['花臂']='花臂白雪:BAAALgAECgQJBAAAAA==.',
['芷儿']='芷儿:BAAALgAECgcJCgAAAA==.',
['苍白']='苍白丶:BAAALgADCgUJBQAAAA==.苍白丶狂暴战:BAAALgADCgEJAQAAAA==.',
['苏小']='苏小楼:BAAALgAECgYJBgAAAA==.',
['苞米']='苞米牛牛:BAAALgAECgYJCgAAAA==.',
['若初']='若初见:BAAALgAECgEJAQAAAA==.',
['苹果']='苹果兔:BAAALgADCgYJBgAAAA==.苹果嘉儿:BAAALgAECgYJBwAAAA==.',
['荣耀']='荣耀牛牛:BAAALgAECgMJAwAAAA==.',
['莫丶']='莫丶:BAAALgAECgIJAgAAAA==.',
['莫格']='莫格萊尼:BAAALgAECgEJAQAAAA==.',
['菝葜']='菝葜:BAAALgAECgYJBwAAAA==.',
['菲莉']='菲莉丶:BAAALgAECggJEgAAAA==.',
['萌宝']='萌宝不闹:BAAALgAECgQJBAAAAA==.',
['萌萌']='萌萌哒的绿豆:BAAALgAECgYJCAAAAA==.',
['萧瑟']='萧瑟的雨:BAAALgAECgEJAQAAAA==.',
['萨满']='萨满鸡丝:BAABLgAFFH8GAAISAAMJEws4EQDeAAASAAMJEws4EQDeAAAAAA==.',
['萨菲']='萨菲罗灬斯:BAABLgAECn8WAAMOAAcJHR0oOABCAgAOAAcJHR0oOABCAgAKAAMJ+AKYgAB2AAAAAA==.',
['萨鲁']='萨鲁法尔丶李:BAAALgAECgIJAgAAAA==.',
['落笔']='落笔画秋风:BAAALgAECgIJAgAAAA==.',
['葱宝']='葱宝贴贴:BAAALgAECgUJBQABLgAECgYJBgAGAAAAAA==.',
['蓝火']='蓝火哒哒:BAAALgADCgEJAQAAAA==.',
['藏月']='藏月一趙子龍:BAAALgAECgEJAgAAAA==.',
['虫子']='虫子一号:BAAALgAECgcJBwAAAA==.虫子二号:BAAALgAECgkJBwAAAA==.',
['蜡笔']='蜡笔新之助:BAAALgADCgMJAwAAAA==.',
['蝎子']='蝎子莱来:BAAALgAECggJBgAAAA==.',
['血兽']='血兽救我丨:BAAALgAECgUJBQAAAA==.',
['血洗']='血洗幼儿圆:BAAALgAECggJDgAAAA==.',
['血燚']='血燚:BAAALgAECgQJCgAAAA==.',
['西科']='西科尔斯基:BAAALgAECgMJAwAAAA==.',
['誓月']='誓月灬查理斯:BAAALgADCgEJAQAAAA==.',
['諸神']='諸神喜樂:BAAALgAECgYJBgAAAA==.',
['诸顺']='诸顺遂:BAAALgAECgQJBgAAAA==.',
['豆豆']='豆豆猫:BAAALgAECgUJBQAAAA==.豆豆行者:BAAALgADCgEJAQAAAA==.',
['贪杯']='贪杯:BAAALgAFFAEJAgAAAA==.',
['贰贰']='贰贰三四:BAAALgAFFAIJAwAAAA==.',
['贼特']='贼特么飒:BAAALgAECgMJAwAAAA==.',
['赛达']='赛达丶:BAAALgAECgYJBwAAAA==.',
['赤脚']='赤脚妹:BAAALgADCgYJBgAAAA==.',
['趣多']='趣多多丿:BAABLgAECn8fAAMJAAgJOB0FAwCnAQAJAAgJYhcFAwCnAQAIAAYJVx70XwBIAQAAAA==.',
['路西']='路西法悠悠:BAAALgAECgcJDQAAAA==.',
['踢裆']='踢裆选手:BAABLgAECn8VAAMWAAkJoQ8LIQD5AQAWAAkJoQ8LIQD5AQAaAAYJKAAAAAAAAAAAAA==.',
['轒轀']='轒轀:BAAALgAECgIJAwAAAA==.',
['转角']='转角遇丶熊:BAAALgAFFAUJBAAAAA==.',
['轻启']='轻启尤嫣姬:BAAALgAECgYJCwAAAA==.',
['辛多']='辛多雷的崛起:BAAALgAECgQJBAAAAA==.',
['还有']='还有这种騲作:BAAALgAECgMJAwAAAA==.',
['迷你']='迷你大熊:BAAALgAFFAIJAgAAAA==.',
['追憶']='追憶似水容顏:BAAALgAECgEJAQAAAA==.',
['送你']='送你个电疗:BAAALgADCgQJBAAAAA==.',
['送雨']='送雨晨:BAAALgAFFAMJAQAAAA==.',
['速度']='速度灭下一把:BAAALgAECgYJBgAAAA==.',
['進化']='進化的小秃豆:BAAALgAFFAIJBAAAAA==.',
['逸舞']='逸舞:BAAALgAECggJEgAAAA==.',
['那个']='那个斩士:BAABLgAECn8ZAAILAAkJ4BjWIQC5AgALAAkJ4BjWIQC5AgAAAA==.',
['那些']='那些年一起走:BAAALgAFFAIJAgAAAA==.',
['邪恶']='邪恶天才:BAACLgAFFH8KAAIDAAMJJBjlFAAOAQADAAMJJBjlFAAOAQAuAAQKfxYAAgMABglJIQVkABECAAMABglJIQVkABECAAAA.邪恶小菜包:BAAALgADCgQJBAAAAA==.',
['邪魅']='邪魅:BAAALgAECgYJCQAAAA==.',
['酒仙']='酒仙小王子:BAAALgAECgUJBwAAAA==.',
['酥鱼']='酥鱼:BAAALgAECgEJAQAAAA==.',
['醉十']='醉十叁:BAABLgAFFH8FAAIWAAMJwQvxFADOAAAWAAMJwQvxFADOAAAAAA==.',
['醉酩']='醉酩酊:BAAALgAECgEJAQAAAA==.',
['醒醒']='醒醒:BAAALgAECgIJAgAAAA==.',
['重生']='重生之当动物:BAAALgADCgUJBQAAAA==.',
['鐡血']='鐡血:BAAALgAECgUJBwAAAA==.',
['针王']='针王苹果:BAAALgAFFAIJAwABLgAFFAMJBQABAL0NAA==.',
['铁根']='铁根大帝:BAAALgAFFAMJBAAAAA==.',
['锅包']='锅包呦:BAAALgAFFAIJAwAAAA==.',
['锅巴']='锅巴沾奶粉:BAAALgADCgEJAQAAAA==.',
['锟铻']='锟铻:BAAALgAECgEJAwAAAA==.',
['长月']='长月如歌:BAAALgADCgYJBgAAAA==.',
['长歌']='长歌行丶:BAAALgAECgQJBAAAAA==.',
['长耳']='长耳贼:BAABLgAECn8ZAAIIAAcJzSIJGAB5AgAIAAcJzSIJGAB5AgABLgAFFAQJDwALALcmAA==.',
['闪亮']='闪亮的黎明:BAAALgAECgQJBAAAAA==.',
['阿佳']='阿佳:BAACLgAFFH8FAAILAAUJpBK7BQCnAQALAAUJpBK7BQCnAQAuAAQKfxQAAgsACQl7DgNLABICAAsACQl7DgNLABICAAAA.',
['阿克']='阿克玛:BAAALgAECgEJAQAAAA==.',
['阿咪']='阿咪是我的狗:BAAALgAFFAQJBAAAAA==.',
['阿咬']='阿咬:BAABLgAECn8aAAMRAAgJzRv+CwB1AgARAAgJzRv+CwB1AgAbAAYJdhTvIwCeAQAAAA==.',
['阿尒']='阿尒托莉雅:BAAALgAECgkJAgAAAA==.',
['阿尔']='阿尔妮哆奇:BAAALgAECgcJBQAAAA==.',
['阿尼']='阿尼亚喵:BAAALgADCgYJBgAAAA==.',
['阿特']='阿特萌德:BAAALgAECgYJDQAAAA==.',
['陌上']='陌上有青鸢:BAAALgAFFAIJAgAAAA==.',
['随风']='随风飘散:BAABLgAFFH8GAAILAAIJpxT/IQCcAAALAAIJpxT/IQCcAAAAAA==.',
['隼人']='隼人红:BAAALgAECgUJBgAAAA==.',
['雪域']='雪域之水:BAABLgAFFH8GAAIDAAIJFRUdOgC2AAADAAIJFRUdOgC2AAAAAA==.雪域萨其玛:BAAALgAECgUJBQAAAA==.',
['露珠']='露珠蒸发香气:BAAALgAFFAEJAQAAAA==.',
['霹雳']='霹雳小牛:BAAALgAECgUJCAAAAA==.',
['靈魂']='靈魂守衛:BAAALgADCgYJBgAAAA==.',
['青枳']='青枳:BAABLgAECn8cAAMNAAgJ9x7jDwCkAgANAAgJ9x7jDwCkAgAQAAEJxACo7QAMAAAAAA==.',
['青栀']='青栀琉璃裙:BAAALgAECgEJAQAAAA==.',
['青青']='青青慢老登:BAACLgAFFH8QAAIQAAUJjRkvAgCoAQAQAAUJjRkvAgCoAQAuAAQKfxkAAhAABwmcI4sRAKoCABAABwmcI4sRAKoCAAAA.青青草原拳王:BAAALgADCgMJAwAAAA==.',
['顾问']='顾问:BAAALgAFFAEJAQAAAA==.',
['風旅']='風旅之人:BAAALgAECgQJBAAAAA==.',
['风暴']='风暴奋激隐士:BAAALgAECgQJBAAAAA==.风暴烈酒武:BAAALgADCgUJBQAAAA==.',
['风歌']='风歌雨颂:BAAALgAECgYJCwAAAA==.',
['风色']='风色灬幻想:BAACLgAFFH8PAAIPAAQJtRMlAwAaAQAPAAQJtRMlAwAaAQAuAAQKfxcAAg8ACQmqHJoEAPwCAA8ACQmqHJoEAPwCAAAA.风色的纪念:BAAALgAECgQJBAABLgAFFAQJDwAPALUTAA==.',
['飒丶']='飒丶飒:BAAALgAECgcJCAAAAA==.',
['飘渺']='飘渺梦魔:BAAALgADCgEJAgAAAA==.',
['飞沙']='飞沙走石:BAAALgAECgkJDwAAAA==.',
['飞雪']='飞雪:BAAALgAECgEJAQAAAA==.',
['饭还']='饭还是得吃的:BAAALgAFFAIJBAABLgAFFAcJBQADANERAA==.',
['香草']='香草星冰乐:BAAALgAECgEJAQAAAA==.',
['馨鈅']='馨鈅:BAAALgADCgUJBQAAAA==.',
['馬一']='馬一:BAAALgADCgIJAgAAAA==.',
['马保']='马保国丶:BAAALgAECgUJBQAAAA==.',
['驯受']='驯受女王:BAAALgAECgYJDAAAAA==.',
['骑到']='骑到死:BAAALgAFFAEJAQAAAA==.',
['骑士']='骑士的荣光:BAAALgAECgIJAgAAAA==.',
['魔欣']='魔欣儿:BAABLgAECn8WAAMBAAgJLxIvRgD5AQABAAgJLxIvRgD5AQACAAIJCAcWWgBgAAAAAA==.',
['鱼香']='鱼香榴莲:BAAALgAECgcJBwAAAA==.鱼香肉斯:BAAALgAFFAEJAQAAAA==.',
['鲨鱼']='鲨鱼辣椒丶:BAAALgAECgEJAQAAAA==.',
['鳝饿']='鳝饿终有鲍:BAAALgAECgEJAgAAAA==.',
['鹰猎']='鹰猎:BAAALgAFFAIJAgAAAA==.',
['黄丶']='黄丶老邪:BAAALgAECgEJAQAAAA==.',
['黑暗']='黑暗杀戮:BAAALgAECgEJAQAAAA==.',
['鼻涕']='鼻涕可好吃了:BAAALgAFFAIJBAAAAA==.',
['龙哥']='龙哥啊:BAABLgAFFH8KAAIcAAQJ8gyjAQA6AQAcAAQJ8gyjAQA6AQAAAA==.',
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
