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

local lookup = {'Unknown-Unknown','Priest-Discipline','Priest-Shadow','Mage-Frost','DeathKnight-Blood','Rogue-Subtlety','Warlock-Demonology','Evoker-Preservation','Shaman-Elemental','Shaman-Restoration','Warrior-Protection','Rogue-Outlaw','Warrior-Arms','DemonHunter-Devourer','Monk-Windwalker','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Mistweaver',}
local provider = {region='CN',realm='火烟之谷',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ah='Ahnqiraj:BAAALgAECgYJDAABLgAFFAQJAwABAAAAAA==.',
Fo='Fourthlk:BAAALgAFFAEJAgAAAA==.',
Hy='Hyperrun:BAAALgAECgEJAQAAAA==.',
Lo='Lorabbit:BAAALgAECgUJBgAAAA==.',
Nt='Ntr:BAAALgADCgUJBQAAAA==.',
Sa='Salute:BAAALgADCgEJAQABLgAFFAUJEgACAD0eAA==.',
Sh='Shadowlover:BAAALgAFFAEJAgAAAA==.',
Vo='Voidelfdh:BAAALgAECgYJBgAAAA==.',
['一不']='一不绝一:BAAALgAECgkJEAAAAA==.',
['一位']='一位演员:BAAALgAECgUJBQAAAA==.',
['丢失']='丢失:BAAALgAECgEJAQAAAA==.',
['中大']='中大渣网速:BAAALgAFFAEJAgAAAA==.中大电击棒:BAAALgAECgMJBgAAAA==.',
['丰川']='丰川祥子:BAAALgAFFAIJBAAAAA==.',
['丶女']='丶女神与爱子:BAAALgAECgUJCgAAAA==.',
['人间']='人间第一流:BAAALgAFFAQJBAAAAA==.',
['仙熊']='仙熊掌和鱼:BAAALgAECgEJAQAAAA==.',
['以德']='以德福人:BAAALgAECgIJAgAAAA==.',
['伊瑞']='伊瑞尔丶德尼:BAAALgAECgQJBAAAAA==.',
['何灬']='何灬必:BAAALgADCgEJAgAAAA==.',
['何物']='何物胡:BAAALgAECgkJDwABLgAFFAQJCwADAOodAA==.',
['偶想']='偶想花花:BAAALgADCgcJBwAAAA==.',
['入夜']='入夜:BAABLgAECn8WAAIEAAkJvxSFPACFAgAEAAkJvxSFPACFAgAAAA==.',
['冰淇']='冰淇淋哭了:BAAALgAECgIJAwAAAA==.',
['割头']='割头者:BAAALgAECgIJAgAAAA==.',
['卡莉']='卡莉丝塔:BAAALgAECgEJAgAAAA==.',
['古伊']='古伊奈:BAAALgAECgMJAwABLgAECgcJFgAFAFoYAA==.',
['古里']='古里古:BAAALgAECgUJCAAAAA==.',
['吾皇']='吾皇公孙:BAAALgAECgQJBAAAAA==.',
['呆贼']='呆贼:BAABLgAFFH8FAAIGAAIJ0QtYFACtAAAGAAIJ0QtYFACtAAAAAA==.',
['唐允']='唐允:BAAALgAECgEJAQAAAA==.',
['嗜血']='嗜血梦魇:BAABLgAECn8aAAIHAAkJNRYZBwAAAgAHAAkJNRYZBwAAAgAAAA==.',
['圆头']='圆头耄耋:BAABLgAFFH8FAAIIAAUJ/Q/FBQCZAQAIAAUJ/Q/FBQCZAQAAAA==.',
['國寶']='國寶乄晕女乃:BAAALgADCgEJAQAAAA==.',
['增辉']='增辉:BAAALgAFFAEJAQAAAA==.',
['夜之']='夜之燧:BAAALgAECgkJDAAAAA==.夜之穗:BAABLgAECn8XAAMDAAkJlBheCgDcAgADAAkJlBheCgDcAgACAAMJTAtFQACuAAAAAA==.夜之邃:BAAALgAECgkJCQAAAA==.夜之韢:BAAALgAECgkJCgAAAA==.夜之颂:BAABLgAECn8ZAAMJAAkJhRYLFgBqAgAJAAkJhRYLFgBqAgAKAAEJlgQAAAAAAAAAAA==.',
['夜的']='夜的渡船:BAAALgAECgkJEAAAAA==.夜的重生:BAAALgAFFAIJAgAAAA==.',
['夜穗']='夜穗:BAABLgAECn8UAAIGAAkJzRToEACaAgAGAAkJzRToEACaAgAAAA==.',
['夜羽']='夜羽:BAAALgAECgkJEQAAAA==.',
['大眼']='大眼瞪小眼:BAAALgAFFAIJAwAAAA==.',
['天道']='天道人和:BAACLgAFFH8HAAIEAAMJ3RSKKgALAQAEAAMJ3RSKKgALAQAuAAQKfxcAAgQACAl9HzMkAOICAAQACAl9HzMkAOICAAAA.',
['太年']='太年轻:BAAALgAECgYJCQAAAA==.',
['女王']='女王不叫:BAAALgAECgIJAwAAAA==.',
['妖不']='妖不狐:BAAALgAECgQJBwAAAA==.',
['孤独']='孤独根号三:BAABLgAFFH8FAAILAAIJVAygDACBAAALAAIJVAygDACBAAAAAA==.',
['孤街']='孤街野猫:BAAALgAECgEJAQAAAA==.',
['宇文']='宇文铁柱:BAAALgADCgYJBgAAAA==.',
['小小']='小小懒河:BAAALgAECgcJAQAAAA==.',
['小屠']='小屠屠逐日者:BAABLgAECn8ZAAIEAAcJShWPFQCWAQAEAAcJShWPFQCWAQAAAA==.',
['小狐']='小狐娘:BAAALgAFFAQJBAAAAA==.',
['小猫']='小猫爱吃醋:BAAALgAECgYJBgAAAA==.',
['小蘿']='小蘿麗:BAAALgAFFAQJBAAAAA==.',
['小说']='小说两句:BAAALgAECgUJBgABLgAFFAYJEwACACwVAA==.',
['小趴']='小趴河:BAAALgAECgcJBQAAAA==.',
['帅气']='帅气小贼:BAABLgAECn8ZAAIMAAcJjSG5AADmAQAMAAcJjSG5AADmAQAAAA==.',
['幽暗']='幽暗的天空:BAAALgAECgMJAwAAAA==.',
['库来']='库来鲁:BAAALgAECgQJAQAAAA==.',
['弗拉']='弗拉迪米尔:BAAALgAECgEJAQAAAA==.',
['张店']='张店小寒羊二:BAAALgAFFAEJAgAAAA==.',
['彼岸']='彼岸丶花:BAAALgADCgEJAQAAAA==.',
['往头']='往头打有保险:BAAALgAECgkJBwAAAA==.',
['德玛']='德玛西亚之翼:BAAALgAECgMJBQAAAA==.',
['恐惧']='恐惧一逼:BAAALgAECgMJAwAAAA==.',
['我可']='我可不是狼:BAAALgAECgYJCAAAAA==.',
['我来']='我来助你:BAABLgAECn8UAAINAAcJaR83BwBMAgANAAcJaR83BwBMAgAAAA==.',
['手打']='手打龙肉丸:BAAALgADCgUJBQAAAA==.',
['抽中']='抽中大奖了噜:BAAALgAECgQJCgAAAA==.',
['挡你']='挡你的虔诚:BAAALgAECgUJBQAAAA==.',
['敖丶']='敖丶灵汐:BAAALgAECgQJBQAAAA==.',
['早睡']='早睡早起大王:BAAALgAECgIJAwAAAA==.',
['星辰']='星辰之怒:BAAALgAECgUJCQAAAA==.',
['晃去']='晃去晃来:BAAALgAECgkJEAAAAA==.',
['暗影']='暗影猎刃:BAAALgAECgYJCwAAAA==.',
['暗殺']='暗殺猎手:BAAALgAECgEJAQAAAA==.',
['曾经']='曾经很小德:BAAALgAECgEJAQAAAA==.',
['李亚']='李亚军:BAAALgAECgMJBgAAAA==.',
['板子']='板子依然在:BAAALgAECgUJBQAAAA==.',
['板都']='板都板不脱:BAAALgAFFAIJBAAAAA==.',
['桃之']='桃之妖妖:BAAALgADCgUJCgAAAA==.',
['梧夜']='梧夜飘逝:BAAALgAECgUJCQAAAA==.',
['梵蒂']='梵蒂冈海豹:BAAALgAECgEJAwAAAA==.',
['極楽']='極楽浄土:BAAALgAECgMJAwAAAA==.',
['榊麯']='榊麯亽無淵:BAAALgAFFAEJAQAAAA==.',
['橘子']='橘子的守護丶:BAAALgAECgUJCgAAAA==.',
['毛丶']='毛丶里求丝:BAAALgADCgUJBQAAAA==.',
['水凼']='水凼凼:BAAALgAECgQJBgAAAA==.',
['沙罗']='沙罗曼蛇:BAAALgAECgIJBAAAAA==.',
['浪里']='浪里小白:BAAALgAECgYJCAAAAA==.',
['淘气']='淘气女孩:BAAALgAECgYJCgAAAA==.',
['深情']='深情的流氓:BAAALgAECgYJEQAAAA==.',
['游侠']='游侠小恶龙:BAAALgADCgUJBQAAAA==.',
['溜溜']='溜溜梅:BAAALgAECgYJCAAAAA==.',
['滚豆']='滚豆豆:BAAALgADCgYJBwAAAA==.',
['漪如']='漪如:BAAALgADCgEJAQAAAA==.',
['炸鱼']='炸鱼薯条:BAAALgAFFAUJAgAAAA==.',
['热辣']='热辣小区:BAAALgAFFAEJAQAAAA==.',
['牛洛']='牛洛:BAAALgAECgYJCgAAAA==.',
['玉碎']='玉碎:BAAALgAECgQJBAAAAA==.',
['瑶琴']='瑶琴:BAABLgAFFH8FAAIOAAIJZxXqKwCWAAAOAAIJZxXqKwCWAAAAAA==.',
['盖亚']='盖亚能量炮:BAAALgAECgEJAQAAAA==.',
['破卿']='破卿:BAABLgAECn8VAAIPAAcJ+g4sCQBCAQAPAAcJ+g4sCQBCAQAAAA==.',
['破晓']='破晓星辰:BAAALgADCgkJDwAAAA==.',
['等待']='等待降临:BAAALgAECgQJBAAAAA==.',
['糊人']='糊人焦比:BAAALgAECgEJAQAAAA==.',
['終末']='終末之時:BAAALgAFFAEJAQAAAA==.',
['纳兹']='纳兹米尔:BAAALgAFFAEJAgAAAA==.',
['纾雨']='纾雨丶:BAAALgAECgUJBwAAAA==.',
['继国']='继国缘一:BAAALgAECgYJBgAAAA==.',
['老奶']='老奶奶过马路:BAAALgAFFAMJBAAAAA==.',
['老船']='老船长二号:BAAALgAECgYJDAAAAA==.',
['胖胖']='胖胖帕拉大王:BAAALgAECgYJBwAAAA==.',
['芽色']='芽色清茶:BAAALgADCgEJAgAAAA==.',
['范德']='范德彪:BAABLgAECn8aAAMQAAcJUSFaBgAIAgAQAAcJUSFaBgAIAgARAAEJLxpcfgBMAAAAAA==.',
['莉莉']='莉莉安:BAABLgAFFH8IAAICAAQJHg5OCgA6AQACAAQJHg5OCgA6AQAAAA==.',
['萌嗒']='萌嗒嗒熊小施:BAAALgADCgEJAQAAAA==.',
['萌新']='萌新小牧:BAAALgAFFAEJAQAAAA==.',
['萌萌']='萌萌德小施:BAAALgADCgYJBgAAAA==.',
['萌迪']='萌迪凯小施:BAAALgAECgYJAwAAAA==.',
['蕾依']='蕾依莉雅:BAAALgAECgYJDQAAAA==.',
['虎先']='虎先锋:BAAALgAECgYJBgAAAA==.',
['血影']='血影舞:BAAALgAECgQJCQAAAA==.',
['血色']='血色丶星辰:BAAALgADCgEJAQAAAA==.',
['诸神']='诸神之夜:BAAALgAECggJDwABLgAFFAIJAgABAAAAAA==.',
['谋勇']='谋勇兼备:BAAALgAECgEJAgAAAA==.',
['贝利']='贝利亚大王:BAAALgAECgcJCAAAAA==.',
['赏你']='赏你个痛快:BAAALgADCgcJDAAAAA==.',
['趴菜']='趴菜小德:BAAALgAECgYJCgABLgAFFAEJAQABAAAAAA==.',
['躲在']='躲在你的衣柜:BAABLgAECn8ZAAISAAcJSxzrEgA4AgASAAcJSxzrEgA4AgAAAA==.',
['辣多']='辣多一点:BAAALgADCgEJAQAAAA==.',
['逛去']='逛去晃来:BAAALgAECgIJAgAAAA==.',
['逛来']='逛来逛去:BAAALgAECgkJBwABLgAFFAcJGQAJAJEdAA==.',
['邪邪']='邪邪笙歌:BAAALgAECgIJAgAAAA==.',
['酋长']='酋长噶结棍:BAAALgAECgEJAQAAAA==.',
['酥小']='酥小小:BAAALgADCgQJBAAAAA==.',
['鑢七']='鑢七实:BAAALgAECgEJAQAAAA==.鑢七花:BAAALgAECgQJBAAAAA==.',
['闪电']='闪电旋风劈:BAABLgAECn8VAAMKAAgJMQr2EwATAQAKAAgJMQr2EwATAQAJAAEJ5Qr2JwA0AAAAAA==.',
['闲月']='闲月:BAAALgAFFAEJAQAAAA==.',
['阿卡']='阿卡的小老婆:BAAALgAECgMJAwAAAA==.',
['阿西']='阿西噶阿西:BAAALgAECgYJBgAAAA==.',
['青柑']='青柑灬普洱:BAAALgADCgUJBQAAAA==.',
['静初']='静初静默:BAAALgADCgEJAQAAAA==.',
['韩跑']='韩跑跑:BAAALgAECgIJAQAAAA==.',
['風过']='風过无心:BAAALgAECgYJCAAAAA==.',
['飛天']='飛天豬寶寶:BAAALgADCgUJBQAAAA==.',
['香酥']='香酥龙腿:BAAALgAECgcJAQAAAA==.',
['高山']='高山一崩:BAAALgAECgYJCwAAAA==.',
['鬼人']='鬼人正邪:BAABLgAECn8WAAIFAAcJWhilAwCuAQAFAAcJWhilAwCuAQAAAA==.',
['鬼砺']='鬼砺:BAAALgAFFAEJAQAAAA==.',
['魔界']='魔界宠儿:BAAALgAECgMJAwAAAA==.',
['麦辣']='麦辣龙腿堡:BAAALgAECgEJAQAAAA==.',
['黑铁']='黑铁之心:BAAALgAECgIJAgAAAA==.',
['黯淡']='黯淡天行者:BAAALgAECgUJBQAAAA==.',
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
