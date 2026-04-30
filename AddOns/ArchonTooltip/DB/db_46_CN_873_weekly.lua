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

local lookup = {'Warlock-Demonology','Unknown-Unknown','Warrior-Fury','Warrior-Arms','Rogue-Subtlety','DeathKnight-Unholy','Paladin-Protection','Paladin-Holy','Hunter-BeastMastery','Mage-Frost','Evoker-Preservation','Priest-Holy','Monk-Brewmaster','Hunter-Marksmanship','Druid-Restoration','Shaman-Restoration','Shaman-Elemental','DemonHunter-Devourer','DemonHunter-Havoc','Rogue-Outlaw','Rogue-Assassination',}
local provider = {region='CN',realm='雏龙之翼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ah='Ahkunda:BAAALgADCgIJAgAAAA==.',
Ap='Apurple:BAABLgAFFH8HAAIBAAIJIRH2NQCnAAABAAIJIRH2NQCnAAAAAA==.',
Bl='Blackmage:BAAALgAECgQJBQAAAA==.',
Bu='Bugmt:BAAALgADCgIJAgAAAA==.Buther:BAAALgAECgkJCQAAAA==.',
Da='Dabaozi:BAAALgADCgMJBQAAAA==.Daxmix:BAAALgAECgYJCQAAAA==.',
De='Deadlines:BAAALgAECgQJBwAAAA==.',
Gr='Greendht:BAAALgAFFAIJAgAAAA==.',
Ho='Hotch:BAAALgADCgQJBAAAAA==.',
In='Inn:BAAALgAECgcJDgAAAA==.',
Je='Jetal:BAAALgAECgIJAgAAAA==.',
Ji='Jinxx:BAAALgAECgMJAwAAAA==.',
Kr='Kristian:BAAALgAECgYJBgAAAA==.',
Li='Lii:BAAALgAECgMJAwAAAA==.',
Ma='Manum:BAAALgAECgMJAwABLgAFFAIJAwACAAAAAA==.Mazil:BAAALgAECgYJDwAAAA==.',
Mu='Mucher:BAABLgAECn8bAAMDAAgJPxlsJQAtAgADAAcJ5xhsJQAtAgAEAAQJexZjHAANAQAAAA==.',
Oi='Oioiol:BAAALgAECgIJBAAAAA==.',
Pa='Panda:BAAALgAECgYJBgAAAA==.',
Pi='Pinkblood:BAAALgAECgUJBQAAAA==.',
Pl='Playerjuvcqr:BAAALgAECgQJBAAAAA==.',
Ro='Robenst:BAAALgAECgMJAwAAAA==.',
Sl='Slience:BAAALgAFFAIJAwAAAA==.',
Sm='Smileedol:BAAALgAECgYJCwAAAA==.',
Sp='Spexia:BAAALgAECgEJAQAAAA==.',
Sw='Swordthrust:BAACLgAFFH8LAAIFAAQJAiI+AgB0AQAFAAQJAiI+AgB0AQAuAAQKfxYAAgUACQlnIMACAHoDAAUACQlnIMACAHoDAAAA.',
Un='Unidaddy:BAAALgAECgYJBwAAAA==.',
Va='Vamprose:BAABLgAECn8mAAIGAAgJsiNSAgCwAgAGAAgJsiNSAgCwAgAAAA==.',
Vi='Viva:BAAALgAECgQJBQAAAA==.',
Ya='Yangbaby:BAAALgAECgcJCwAAAA==.',
Ye='Yell:BAAALgADCgEJAQAAAA==.',
['一个']='一个耳环:BAAALgAECgUJBgAAAA==.',
['一剑']='一剑破苍芎:BAAALgAECgQJBAAAAA==.',
['一叶']='一叶枝秋:BAAALgAECgMJBAABLgAECgYJBQACAAAAAA==.',
['一层']='一层一尘:BAAALgAECgMJBAAAAA==.',
['七百']='七百龙:BAAALgAECgIJBAAAAA==.',
['万物']='万物归一者:BAAALgAECgQJBAAAAA==.',
['不灭']='不灭的刀魂:BAAALgADCgYJBgAAAA==.不灭的灵魂:BAAALgAECgUJCQAAAA==.',
['不要']='不要噶啦:BAAALgADCgUJBQAAAA==.',
['丶呶']='丶呶呶丶:BAAALgAFFAEJAgAAAA==.',
['丶火']='丶火乄炮:BAAALgADCgEJAQAAAA==.',
['丶花']='丶花萌萌:BAAALgAECgEJAQAAAA==.',
['乌梅']='乌梅丸:BAAALgAECgIJAgAAAA==.',
['九刀']='九刀:BAAALgAFFAEJAQAAAA==.',
['五何']='五何事:BAAALgAECgcJDQAAAA==.',
['五味']='五味子:BAAALgAECgQJBAAAAA==.',
['亚丝']='亚丝娜:BAAALgAECgEJAwAAAA==.',
['亲爸']='亲爸:BAAALgAECgUJAgAAAA==.',
['优迪']='优迪安路疯:BAAALgAECgUJBQAAAA==.',
['会飞']='会飞的裹脚娜:BAAALgADCgEJAQAAAA==.',
['你好']='你好好哦:BAAALgAECgEJAQAAAA==.',
['你的']='你的丨名字:BAAALgADCgYJBgAAAA==.',
['侬则']='侬则赤佬模子:BAAALgAECgYJBwAAAA==.',
['修罗']='修罗此猎有毒:BAAALgAECgUJCgAAAA==.',
['光圈']='光圈:BAAALgAECgYJBgAAAA==.',
['六合']='六合布武:BAAALgAECgcJCwAAAA==.',
['内侧']='内侧袋:BAAALgAECgQJBAAAAA==.',
['再来']='再来一桶酒:BAAALgAECgEJAQAAAA==.',
['冰冰']='冰冰广寒月:BAAALgAECgUJBQAAAA==.',
['冰封']='冰封白菜:BAAALgAFFAIJAwAAAA==.',
['冰灬']='冰灬洢壹:BAAALgAECgEJAgAAAA==.',
['凌昆']='凌昆:BAAALgAECgEJAQAAAA==.',
['击败']='击败二号:BAAALgAECgYJDQAAAA==.',
['剩骑']='剩骑士:BAAALgADCgIJAgAAAA==.',
['加油']='加油素素:BAAALgAECgUJCQAAAA==.',
['北风']='北风南方吹:BAAALgAECgUJBgAAAA==.',
['十三']='十三香:BAAALgAECgYJBgAAAA==.',
['十彡']='十彡香:BAAALgAECgQJBwAAAA==.',
['口袋']='口袋里有图腾:BAAALgAECgYJAQAAAA==.',
['只是']='只是执念作祟:BAABLgAFFH8GAAMHAAMJzSBnAQAnAQAHAAMJzSBnAQAnAQAIAAEJ4xG4DwBXAAAAAA==.',
['咏歌']='咏歌:BAAALgAECgYJBgAAAA==.',
['咕咕']='咕咕嘎嘎:BAAALgADCgUJBQAAAA==.',
['咱的']='咱的老父亲:BAAALgAECgYJCAAAAA==.',
['哈库']='哈库呐玛塔塔:BAAALgAECgcJCQAAAA==.',
['哔哔']='哔哔吡吡:BAAALgAFFAQJBAAAAA==.',
['善良']='善良的小幸福:BAAALgAECgEJAQAAAA==.',
['嗜血']='嗜血宝宝:BAAALgAECgMJAwAAAA==.',
['圣光']='圣光救救我:BAAALgADCgcJMQAAAA==.圣光有你:BAAALgAECgYJBwAAAA==.圣光牛扒:BAAALgAECgkJCQAAAA==.',
['垣根']='垣根帝督:BAAALgAECgMJAwAAAA==.',
['堂小']='堂小小:BAABLgAFFH8JAAIJAAMJIhtICQAXAQAJAAMJIhtICQAXAQAAAA==.',
['壹念']='壹念壹輪回:BAAALgAECgIJAgAAAA==.',
['大少']='大少爷会长:BAAALgADCgUJBQAAAA==.',
['大慈']='大慈大悲:BAAALgAECgYJBgAAAA==.',
['大橙']='大橙小柚:BAAALgAECgcJDQAAAA==.',
['大白']='大白牛:BAAALgAECgEJAQAAAA==.',
['大耳']='大耳猫:BAAALgAECgUJCQAAAA==.大耳骑:BAAALgAECgQJBAAAAA==.',
['大酋']='大酋长雷德:BAAALgAECgQJBgAAAA==.',
['天真']='天真的云:BAAALgAFFAUJBAAAAA==.',
['奔狼']='奔狼:BAAALgADCgIJAgAAAA==.',
['奶我']='奶我:BAAALgAECgcJBQAAAA==.',
['好什']='好什么啊:BAAALgADCgYJDAAAAA==.',
['妳嘚']='妳嘚欧尼酱:BAAALgAECgYJCwAAAA==.',
['娘娘']='娘娘驾到:BAAALgAECgIJAgAAAA==.',
['婷姐']='婷姐请回答:BAAALgAECgkJCQAAAA==.',
['宁萌']='宁萌:BAAALgAECgMJBQAAAA==.',
['安迪']='安迪斯怒风:BAAALgADCgYJBgAAAA==.',
['宠臣']='宠臣:BAAALgAECgEJAQAAAA==.',
['寂寞']='寂寞的丶想你:BAAALgAECgUJBgAAAA==.',
['寒婉']='寒婉君:BAACLgAFFH8HAAIKAAIJ9xdsOwC0AAAKAAIJ9xdsOwC0AAAuAAQKfxcAAgoABgkfIUNhABgCAAoABgkfIUNhABgCAAAA.',
['寒武']='寒武纪小法:BAAALgAECgEJAQAAAA==.',
['小乔']='小乔不会戦士:BAAALgAECgUJCAAAAA==.小乔不会死骑:BAAALgAECgYJCgAAAA==.',
['小医']='小医仙:BAABLgAFFH8IAAIKAAMJ7gutGQD1AAAKAAMJ7gutGQD1AAAAAA==.',
['小啤']='小啤酒:BAAALgAECgQJBQAAAA==.',
['小怪']='小怪兽奥特慢:BAAALgADCgYJBgAAAA==.',
['小晴']='小晴晴:BAAALgAECgYJBgAAAA==.',
['小法']='小法拉:BAAALgAECgYJBgAAAA==.',
['小狐']='小狐人:BAAALgADCgcJBwAAAA==.',
['小猫']='小猫钓鱼:BAAALgAECgYJCQAAAA==.',
['小胡']='小胡:BAAALgAECgEJAQAAAA==.',
['小铁']='小铁锤锤:BAAALgAFFAEJAQAAAA==.',
['小龙']='小龙翅膀:BAAALgAECgUJCwAAAA==.',
['尘埃']='尘埃丶落:BAAALgAECggJCQAAAA==.',
['尤涅']='尤涅若:BAAALgAFFAIJAwAAAA==.',
['就喝']='就喝二两:BAAALgADCgUJBQAAAA==.',
['帕瑟']='帕瑟妮丶影歌:BAAALgAECgYJDQAAAA==.',
['幻术']='幻术:BAAALgAECgkJDwAAAA==.',
['库卡']='库卡隆精英:BAAALgAECgUJBQAAAA==.',
['库库']='库库的拉文:BAAALgAFFAEJAQAAAA==.',
['庞赛']='庞赛阿莱克斯:BAAALgADCgUJBQAAAA==.',
['德尔']='德尔蹄:BAAALgAECgYJEAABLgAFFAQJDAALAOkMAA==.',
['心有']='心有光明:BAABLgAFFH8JAAIMAAMJuw7DCADcAAAMAAMJuw7DCADcAAAAAA==.',
['怀愫']='怀愫:BAAALgAECgQJCQAAAA==.',
['怎能']='怎能没有我:BAAALgADCgEJAQAAAA==.',
['惊蛰']='惊蛰丶:BAAALgAFFAEJAQAAAA==.',
['想飞']='想飞的炮弹:BAAALgADCgcJBwAAAA==.',
['惹人']='惹人爱:BAAALgAECgEJAQAAAA==.',
['感动']='感动狗狗:BAAALgAECgYJCwAAAA==.',
['我叫']='我叫小茶树菇:BAAALgAECgEJAQAAAA==.',
['战丶']='战丶神:BAAALgAECgcJBwAAAA==.',
['抹了']='抹了油的居:BAAALgADCgMJAwAAAA==.',
['捶就']='捶就完事了:BAAALgAECgQJBAAAAA==.',
['提线']='提线木偶丶:BAAALgAFFAEJAQAAAA==.',
['新奥']='新奥尔良之翼:BAAALgAFFAcJAwAAAA==.',
['旁观']='旁观三爷:BAAALgAECgQJBAAAAA==.',
['昔年']='昔年锦瑟:BAAALgAECgMJAwAAAA==.',
['星铸']='星铸:BAAALgAECgUJBwAAAA==.',
['晴天']='晴天小米:BAAALgAECgEJAQAAAA==.晴天放风筝:BAAALgAECgUJBQAAAA==.',
['暗魂']='暗魂之殇:BAAALgADCgIJAgAAAA==.',
['暮行']='暮行:BAAALgADCgEJAQAAAA==.',
['曼波']='曼波:BAAALgAECgQJBwAAAA==.',
['最爱']='最爱水瓶座:BAAALgAECgEJAQAAAA==.',
['望骇']='望骇扬:BAAALgAECgYJBgAAAA==.',
['末世']='末世苍穹:BAAALgADCgYJBgAAAA==.',
['术佬']='术佬头:BAAALgADCgQJBAAAAA==.',
['来歼']='来歼我:BAAALgAECgYJDQAAAA==.',
['果赖']='果赖:BAAALgAECgYJCQAAAA==.',
['枫镟']='枫镟飞:BAAALgAECgIJAgAAAA==.',
['格林']='格林丶怒风:BAAALgAFFAEJAQAAAA==.',
['梦里']='梦里灬小酒:BAACLgAFFH8FAAINAAIJFhYOGwCSAAANAAIJFhYOGwCSAAAuAAQKfyIAAg0ACAmzF4QdABYCAA0ACAmzF4QdABYCAAAA.',
['樱桃']='樱桃老丸子:BAACLgAFFH8OAAMJAAUJpBXqEwC0AAAOAAQJmhLpFgDiAAAJAAIJIBTqEwC0AAAuAAQKfy0AAw4ACAmuI74CALUBAAkABwnKILUdAFQCAA4ACAm4H74CALUBAAAA.',
['欣想']='欣想事橙:BAAALgADCgYJBgAAAA==.',
['欧根']='欧根亲王:BAAALgAECgEJAgAAAA==.',
['残荷']='残荷闻雨声:BAAALgADCgEJAQAAAA==.',
['殷血']='殷血修罗:BAAALgAECgcJBgAAAA==.',
['毁灭']='毁灭之刃:BAAALgAECgUJBQAAAA==.',
['毒奶']='毒奶怕不怕:BAAALgAECgcJBwAAAA==.',
['没刺']='没刺仙人掌:BAAALgAECgEJAQAAAA==.',
['泥螺']='泥螺大王:BAAALgADCgMJBAAAAA==.',
['洗痒']='洗痒痒:BAAALgAECgYJBgAAAA==.',
['流云']='流云:BAAALgAECgEJAQAAAA==.',
['流氓']='流氓尐猪:BAAALgAECgQJCwAAAA==.',
['浪里']='浪里一杆枪:BAAALgAFFAEJAQAAAA==.',
['清凉']='清凉石少:BAAALgAECgQJBAAAAA==.',
['潇湘']='潇湘:BAAALgAECgUJBQAAAA==.',
['火炮']='火炮:BAAALgAECgQJBQAAAA==.',
['灬姑']='灬姑姑灬:BAAALgAECgcJCgAAAA==.',
['灬小']='灬小玖灬:BAABLgAECn8VAAIPAAcJkw2qGwAQAQAPAAcJkw2qGwAQAQAAAA==.',
['熊貓']='熊貓阿宝:BAAALgAECgMJBQAAAA==.',
['牧哓']='牧哓哓:BAAALgAFFAIJAgAAAA==.',
['狗儿']='狗儿蛋:BAAALgAECgMJAwAAAA==.',
['狗狗']='狗狗感动了:BAAALgAECgYJBwAAAA==.',
['甘小']='甘小雅:BAAALgADCgEJAQAAAA==.',
['电量']='电量不足:BAAALgAFFAQJBAAAAA==.',
['的的']='的的得德:BAAALgAECgUJBQAAAA==.',
['省外']='省外来颗呆萌:BAAALgAECgYJEQAAAA==.',
['真湖']='真湖:BAAALgAFFAIJAwAAAA==.',
['神话']='神话巫师:BAAALgAECgQJCAABLgAFFAMJBwAGAKkLAA==.神话怒风:BAAALgADCgIJAgABLgAFFAMJBwAGAKkLAA==.神话步兵:BAAALgAECgYJCwABLgAFFAMJBwAGAKkLAA==.神话熊猫:BAACLgAFFH8HAAIGAAMJqQvbFwDZAAAGAAMJqQvbFwDZAAAuAAQKfxsAAgYABwnsFTJmAMIBAAYABwnsFTJmAMIBAAAA.',
['祭司']='祭司:BAAALgAFFAEJAQAAAA==.',
['离开']='离开的真相:BAAALgAECgIJBAAAAA==.',
['秋澍']='秋澍:BAAALgAECgkJEQAAAA==.',
['空空']='空空丶:BAAALgAECgUJBQAAAA==.',
['空竹']='空竹幽兰:BAAALgADCgQJBAAAAA==.',
['笑三']='笑三邪:BAAALgAECgQJBwAAAA==.',
['笑笑']='笑笑圣骑:BAAALgADCgEJAQAAAA==.',
['第七']='第七天:BAAALgADCgUJBQAAAA==.',
['第九']='第九夜:BAAALgAECgMJAwAAAA==.',
['米斯']='米斯特汀:BAAALgAECgcJCwAAAA==.',
['糖门']='糖门高手:BAAALgAECgYJBwAAAA==.',
['索兰']='索兰尼亚:BAAALgAECgMJBQAAAA==.',
['紫弦']='紫弦月:BAAALgAECggJCwAAAA==.',
['紫日']='紫日魔:BAAALgAECgMJBQAAAA==.',
['红发']='红发有娜:BAAALgAFFAIJAgAAAA==.',
['红叶']='红叶:BAABLgAFFH8FAAINAAMJ6wlSFQDLAAANAAMJ6wlSFQDLAAAAAA==.',
['纥那']='纥那:BAAALgAECgcJEwAAAA==.',
['纱布']='纱布尼古拉斯:BAAALgADCgIJAgAAAA==.',
['缘缘']='缘缘丷:BAABLgAFFH8MAAIQAAQJWCA5AwBnAQAQAAQJWCA5AwBnAQABLgAFFAUJBAACAAAAAA==.',
['耗子']='耗子萎汁:BAAALgAECgUJBgABLgAECgYJBQACAAAAAA==.',
['腹黑']='腹黑的猫:BAAALgAECgkJBwAAAA==.',
['自在']='自在极意功:BAAALgADCgIJAgAAAA==.',
['致命']='致命:BAAALgAFFAMJBAAAAA==.',
['艾星']='艾星守护者:BAAALgAFFAEJAQAAAA==.',
['芙宁']='芙宁娜:BAAALgAECgQJBQAAAA==.',
['花楼']='花楼丷轩:BAAALgAECgEJAQAAAA==.',
['若曦']='若曦:BAAALgAECgQJBAAAAA==.',
['苯酚']='苯酚奶:BAAALgAECgIJAgAAAA==.',
['苹果']='苹果嘉儿:BAAALgAECgQJBAAAAA==.',
['荷女']='荷女:BAAALgAECgMJAwAAAA==.',
['萨洛']='萨洛瑞恩:BAAALgAECgYJDgAAAA==.',
['落雨']='落雨无声:BAAALgADCgQJBAAAAA==.',
['蓝皮']='蓝皮鼠:BAAALgAECgYJBgAAAA==.',
['蓝色']='蓝色记忆:BAAALgADCgYJDgAAAA==.',
['薛定']='薛定谔仙人掌:BAAALgAECgYJBgAAAA==.',
['虞濛']='虞濛濛:BAAALgAECgEJAQAAAA==.',
['蜥蜴']='蜥蜴人啊啊:BAAALgADCgMJAwAAAA==.',
['蠍子']='蠍子莱莱:BAAALgADCgEJAQAAAA==.',
['血丶']='血丶姬:BAAALgAECgcJBwAAAA==.',
['血蹄']='血蹄之牛:BAABLgAFFH8JAAMQAAQJ7x0SBQB+AQAQAAQJ7x0SBQB+AQARAAEJ7yKcGgBpAAAAAA==.',
['西爷']='西爷:BAAALgAFFAIJAgAAAA==.',
['订书']='订书机:BAAALgAECgMJAwAAAA==.',
['试玩']='试玩亿分钟:BAAALgAECgQJBgAAAA==.',
['请伊']='请伊切桑活:BAAALgADCgIJAgAAAA==.',
['贫替']='贫替:BAAALgAECgYJDQAAAA==.',
['费大']='费大包:BAAALgAECgkJCQAAAA==.',
['费小']='费小包:BAAALgAECgkJCQAAAA==.',
['跑路']='跑路小能手:BAAALgADCgEJAQAAAA==.',
['轻水']='轻水远林:BAAALgAECgYJCAAAAA==.',
['远山']='远山菰蒲:BAAALgAFFAMJBAAAAA==.',
['追丶']='追丶风:BAABLgAECn8aAAIJAAYJoSB1IABCAgAJAAYJoSB1IABCAgAAAA==.',
['追光']='追光:BAAALgADCgYJDwABLgADCgcJMQACAAAAAA==.',
['适宜']='适宜丷:BAABLgAFFH8GAAIQAAMJKyA/BwAQAQAQAAMJKyA/BwAQAQAAAA==.',
['逃不']='逃不出舒适圈:BAAALgADCgEJAQAAAA==.',
['遇见']='遇见初春:BAAALgAECgEJAQAAAA==.遇见夏至:BAAALgAECgQJBgAAAA==.',
['邪钉']='邪钉横辉:BAAALgAECgMJAwAAAA==.',
['酒鬼']='酒鬼丶:BAAALgAECgQJCQAAAA==.',
['醉酒']='醉酒叁仟落:BAAALgAECgEJAQAAAA==.',
['重阳']='重阳:BAAALgAECgUJDQAAAA==.',
['銑錢']='銑錢鏟鋰鎰鑊:BAAALgAECgYJAQAAAA==.',
['钢铁']='钢铁猫咪:BAABLgAECn8UAAMSAAcJjAFrWABGAAATAAYJRgEuZwBHAAASAAcJzgBrWABGAAAAAA==.',
['银月']='银月梓冉:BAAALgADCgcJBwAAAA==.',
['闪光']='闪光仙人掌:BAAALgAECgYJBgAAAA==.',
['阿匹']='阿匹斯:BAAALgAFFAEJAQAAAA==.',
['阿哈']='阿哈先生:BAAALgADCgEJAQAAAA==.',
['阿斯']='阿斯莫代:BAABLgAECn8UAAIGAAcJFgsokABgAQAGAAcJFgsokABgAQAAAA==.',
['阿比']='阿比耶斯:BAAALgADCgIJAgAAAA==.',
['阿雕']='阿雕:BAAALgADCgEJAQAAAA==.',
['陈阿']='陈阿丸儿:BAAALgAECgUJCAAAAA==.',
['陌上']='陌上君如雪:BAAALgAECgcJBwAAAA==.',
['隔壁']='隔壁丶王叔:BAAALgAECgcJCgAAAA==.',
['雾刀']='雾刀:BAAALgAFFAIJAgAAAA==.',
['靠人']='靠人品吃饭:BAAALgAECgEJAQAAAA==.',
['韩婉']='韩婉君:BAABLgAECn8UAAQFAAcJgg95JADVAQAFAAcJaQ95JADVAQAUAAMJTwtDBACzAAAVAAIJDxEDDABBAAAAAA==.',
['顭潴']='顭潴:BAAALgADCgUJBQAAAA==.',
['顶级']='顶级官僚逼:BAAALgAECgYJBgAAAA==.',
['颅筑']='颅筑王座:BAAALgAECgYJCAAAAA==.',
['颯嵐']='颯嵐:BAAALgAECgYJBgAAAA==.',
['风之']='风之流殇:BAAALgAFFAEJAgAAAA==.',
['风流']='风流夜夜浪:BAAALgAECgkJBwABLgAFFAcJBwABANgSAA==.',
['飞行']='飞行的牛:BAAALgAECgIJBAABLgAECgcJCwACAAAAAA==.',
['骄花']='骄花:BAAALgAECgMJAwAAAA==.',
['骑鸵']='骑鸵鸟的小猫:BAAALgAECgYJBgAAAA==.',
['魂牵']='魂牵夜里:BAAALgAECgYJDAAAAA==.',
['魔法']='魔法大耳兽:BAAALgAECgYJCQAAAA==.魔法王:BAAALgAECgEJAQAAAA==.',
['麻辣']='麻辣鸡:BAAALgAECgUJBwAAAA==.',
['龍骧']='龍骧:BAAALgAECgYJDQAAAA==.',
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
