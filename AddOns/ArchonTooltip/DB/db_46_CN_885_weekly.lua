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

local lookup = {'Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','Druid-Balance','DeathKnight-Unholy','Shaman-Elemental','Priest-Holy','DemonHunter-Devourer','Unknown-Unknown','Mage-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Brewmaster','DemonHunter-Havoc','Paladin-Holy','Rogue-Subtlety','DeathKnight-Blood','Druid-Restoration','Priest-Discipline','Priest-Shadow','Monk-Windwalker','Evoker-Preservation','Warlock-Affliction','Monk-Mistweaver',}
local provider = {region='CN',realm='风暴峭壁',name='CN',type='weekly',zone=46,date='2026-04-25',data={Au='Austinkeeper:BAAALgAECgQJBwAAAA==.',
Cj='Cjlove:BAAALgAECgYJCwAAAA==.',
Cu='Curaplke:BAACLgAFFH8JAAIBAAMJBRjSCADtAAABAAMJBRjSCADtAAAuAAQKfx4AAgEACAmkGA0lAAECAAEACAmkGA0lAAECAAAA.',
Da='Damonssone:BAABLgAFFH8TAAMCAAYJvx5yBADXAQACAAYJ/BtyBADXAQADAAQJwhl0AwBjAQAAAA==.Damonsstwo:BAAALgAFFAQJBAAAAA==.',
El='Elunethra:BAAALgAECgYJCQAAAA==.',
Fi='Firmament:BAABLgAFFH8KAAIEAAQJLRzoAgBhAQAEAAQJLRzoAgBhAQAAAA==.',
Fo='Forgetme:BAAALgADCgIJAgAAAA==.',
Lo='Longdick:BAAALgAFFAEJAQAAAA==.Longgray:BAAALgAFFAEJAQAAAA==.',
Lu='Luolikomng:BAAALgAFFAQJBAAAAA==.',
Ma='Manchester:BAAALgAECgkJCQAAAA==.',
Mi='Minnesangs:BAAALgAECgQJBAAAAA==.',
Ne='Necry:BAAALgADCgMJAwAAAA==.Nextdoor:BAAALgAECgYJCgAAAA==.',
Ng='Ngsw:BAAALgAECgEJAQAAAA==.',
No='Nolan:BAAALgADCgIJAgAAAA==.',
On='Onlyfans:BAAALgAECgQJBAAAAA==.',
Pl='Playervdpywx:BAAALgADCgEJAQAAAA==.',
Pr='Problematic:BAAALgAECgEJAgAAAA==.',
Re='Renée:BAAALgAECgcJDQAAAA==.',
Ro='Roseney:BAAALgAECgIJAgAAAA==.',
Rz='Rzbin:BAAALgAECgIJAgAAAA==.',
Su='Summerbloom:BAAALgAFFAIJBAABLgAFFAQJCgAFACYjAA==.',
Tr='Trance:BAAALgAECgUJBQAAAA==.',
Vi='Vickyz:BAAALgAECgIJBAAAAA==.',
Wh='Whooremaster:BAAALgAFFAIJBAAAAA==.',
Yr='Yrel:BAAALgAECgcJCwAAAA==.',
Zn='Znye:BAABLgAFFH8PAAMGAAQJixvGBgBuAQAGAAQJixvGBgBuAQABAAIJwA28GQCUAAAAAA==.Znyee:BAAALgAECgEJAgABLgAFFAQJDwAGAIsbAA==.',
['一天']='一天多一点:BAAALgAECgYJBwAAAA==.',
['一缕']='一缕圣光:BAAALgADCgUJBQAAAA==.一缕烟尘:BAAALgAECgQJBQAAAA==.',
['一脚']='一脚闷死熊:BAAALgAECgQJBAAAAA==.',
['一花']='一花一世界丶:BAABLgAECn8XAAIHAAcJkCADDACRAgAHAAcJkCADDACRAgAAAA==.',
['七擒']='七擒诸葛亮:BAAALgADCgUJBQAAAA==.',
['万物']='万物皆可盘:BAABLgAECn8VAAIIAAYJwiLARQDcAQAIAAYJwiLARQDcAQAAAA==.',
['三生']='三生三世:BAAALgAECgQJBgAAAA==.',
['不盖']='不盖世的欧皇:BAAALgAECgEJAQABLgAFFAMJBAAJAAAAAA==.',
['不羁']='不羁花火:BAAALgADCgEJAQAAAA==.',
['与你']='与你邂逅那晚:BAAALgADCgEJAgAAAA==.',
['世界']='世界第一萨满:BAAALgAECgcJAwAAAA==.',
['世铭']='世铭:BAAALgAECgEJAQAAAA==.',
['丨骑']='丨骑猪射太阳:BAAALgADCgYJBgAAAA==.',
['丶会']='丶会丨长:BAAALgADCggJCAAAAA==.',
['丶千']='丶千早爱音:BAAALgAFFAEJAQAAAA==.',
['丶君']='丶君沛:BAAALgAECgMJAgAAAA==.',
['丶摩']='丶摩尔迦娜:BAAALgAECggJEgABLgAFFAQJBQAKAF0QAA==.',
['丶火']='丶火车王丶:BAAALgAECgMJAwAAAA==.',
['丶灵']='丶灵魂之火:BAAALgAECgcJBwAAAA==.',
['丶莉']='丶莉丝妲黛:BAAALgAFFAQJBAAAAA==.',
['丶葵']='丶葵香子:BAAALgAECgEJAQAAAA==.',
['丷夜']='丷夜影:BAAALgAECgIJAwAAAA==.',
['么么']='么么战熊:BAAALgAECgYJBgAAAA==.',
['乖乖']='乖乖猪:BAAALgAECggJDQAAAA==.',
['九德']='九德九:BAAALgADCgUJBQAAAA==.',
['书丶']='书丶包:BAAALgAECgQJBQAAAA==.',
['乱武']='乱武丶:BAABLgAFFH8FAAMLAAIJZBvlEgC3AAALAAIJZBvlEgC3AAAMAAEJfQGELQA7AAAAAA==.',
['云飘']='云飘飘:BAAALgAECgEJAQAAAA==.',
['五十']='五十五棵树:BAAALgAECgEJAQAAAA==.',
['交换']='交换:BAAALgAECgQJAwAAAA==.',
['人生']='人生四月:BAAALgAECgYJBgAAAA==.',
['代三']='代三男猛:BAAALgAECgEJAQAAAA==.',
['以彼']='以彼之道:BAAALgAECgcJAwAAAA==.',
['伊瑞']='伊瑞尔的邪焰:BAAALgAECgUJBQAAAA==.',
['似梦']='似梦非夢:BAAALgAECgYJEgAAAA==.',
['低调']='低调的哀伤:BAAALgAECgMJBQAAAA==.',
['你被']='你被牛打过:BAAALgAFFAQJBAAAAA==.',
['你说']='你说啥玩意:BAAALgADCgEJAQAAAA==.',
['依然']='依然不听你的:BAAALgADCgUJBQAAAA==.',
['倒下']='倒下的前一秒:BAAALgAFFAQJBAAAAA==.倒下的前七秒:BAABLgAFFH8IAAIBAAQJnRajBABCAQABAAQJnRajBABCAQAAAA==.倒下的前三秒:BAABLgAFFH8JAAIBAAUJyCGQAQCoAQABAAUJyCGQAQCoAQAAAA==.倒下的前九秒:BAABLgAFFH8FAAIBAAUJARPCAwCYAQABAAUJARPCAwCYAQAAAA==.倒下的前五秒:BAABLgAFFH8FAAIBAAUJxhpKAQC1AQABAAUJxhpKAQC1AQAAAA==.倒下的前六秒:BAABLgAFFH8IAAIBAAUJ3hV4BABFAQABAAUJ3hV4BABFAQAAAA==.倒下的前十秒:BAABLgAFFH8HAAIBAAQJtht7AwBfAQABAAQJtht7AwBfAQAAAA==.倒下的前四秒:BAAALgAFFAQJBAAAAA==.',
['傲世']='傲世无情:BAAALgAECgEJAgAAAA==.',
['傻熊']='傻熊咖啡豆:BAAALgAECgQJCAAAAA==.',
['僤裑']='僤裑贵族:BAAALgAECgEJAQAAAA==.',
['六狂']='六狂战的火猫:BAAALgAECgEJAwABLgAFFAMJBAAJAAAAAA==.',
['再打']='再打我报警:BAAALgAECgQJBAABLgAFFAQJDAANAC8RAA==.',
['冫丶']='冫丶:BAAALgAECgEJAQAAAA==.',
['冬崽']='冬崽:BAACLgAFFH8JAAIIAAQJ4BY0DwBUAQAIAAQJ4BY0DwBUAQAuAAQKfxUAAwgABgm8IbAzACsCAAgABgkrILAzACsCAA4ABAk+HKA5ABwBAAAA.',
['冲锋']='冲锋致死斩杀:BAAALgADCgMJAwAAAA==.',
['冷少']='冷少:BAAALgAECgUJCQABLgAFFAQJCQACAEMbAA==.',
['冷崽']='冷崽:BAACLgAFFH8JAAICAAQJQxtqDAB4AQACAAQJQxtqDAB4AQAuAAQKfxUAAwIABgk9IUhLAOgBAAIABQk9IUhLAOgBAAMABAlNDyEtAAkBAAAA.',
['凄美']='凄美夜:BAAALgAECgEJAgAAAA==.',
['凌子']='凌子涯:BAAALgADCgcJCQAAAA==.',
['凤熙']='凤熙落寞:BAAALgAECgUJBQAAAA==.',
['凶猛']='凶猛大白鲨:BAAALgAECgYJAQAAAA==.',
['切位']='切位离丶:BAAALgAECgYJBgAAAA==.',
['刘令']='刘令飞:BAAALgAECgcJBwAAAA==.',
['初心']='初心逐风:BAABLgAFFH8FAAIFAAMJXw3PFADwAAAFAAMJXw3PFADwAAAAAA==.',
['刻骨']='刻骨茗心:BAAALgAECgYJCwAAAA==.',
['千山']='千山鳥飞绝:BAABLgAECn8aAAMBAAgJHCAbFAB0AgABAAgJHCAbFAB0AgAGAAYJoA51RQAzAQAAAA==.',
['南华']='南华老仙:BAAALgAECgIJAgAAAA==.',
['南宫']='南宫狼王:BAAALgAECgUJCgAAAA==.',
['卡布']='卡布佳:BAAALgAECgYJCgAAAA==.',
['变態']='变態:BAAALgADCgMJAQAAAA==.',
['只会']='只会一点点:BAAALgADCgEJAQAAAA==.',
['叮叮']='叮叮喵喵:BAAALgAECgYJBwAAAA==.',
['叮喵']='叮喵喵:BAAALgAECgEJAQAAAA==.',
['可帥']='可帥丶不可耐:BAAALgADCgMJAwAAAA==.',
['叶小']='叶小凡丶:BAAALgAECgMJAwAAAA==.',
['吉媕']='吉媕娜之吻:BAAALgADCgEJAQAAAA==.',
['吐息']='吐息:BAAALgAECgYJBwAAAA==.',
['听风']='听风追雨辰:BAABLgAFFH8GAAIIAAMJrgYUFQDHAAAIAAMJrgYUFQDHAAAAAA==.',
['命运']='命运的宠儿:BAAALgAECgQJBAAAAA==.',
['咕噜']='咕噜灬丨:BAAALgAECgcJDwABLgAECgcJFwAHAJAgAA==.',
['哇哇']='哇哇哒:BAAALgAECgEJAgAAAA==.',
['唤曲']='唤曲生:BAAALgAECgYJCAAAAA==.',
['商陆']='商陆:BAAALgAECgYJDAAAAA==.',
['喔汣']='喔汣醬:BAAALgAECggJCQAAAA==.',
['嗨丶']='嗨丶萌萌:BAAALgADCgQJBAAAAA==.',
['四小']='四小弦:BAAALgADCgIJAQAAAA==.',
['园园']='园园圆:BAAALgAECgYJBwAAAA==.',
['圣光']='圣光蹄妹:BAAALgAFFAIJAwAAAA==.',
['圣夜']='圣夜祈:BAAALgADCgYJBgAAAA==.',
['在原']='在原地等你:BAAALgAECgIJAwAAAA==.',
['在眼']='在眼泪上雕刻:BAAALgAECgUJBQAAAA==.',
['培培']='培培丶小征子:BAAALgAECgYJCAAAAA==.',
['夏天']='夏天的胡子:BAAALgAECgcJEwAAAA==.',
['夏崽']='夏崽:BAAALgAECgIJAgAAAA==.',
['多重']='多重施法:BAAALgAECgUJBQAAAA==.',
['大奉']='大奉许七安:BAAALgAECgYJBgAAAA==.',
['大浴']='大浴池猫咪:BAAALgAECgYJBwAAAA==.',
['大王']='大王之子:BAAALgADCgEJAQAAAA==.',
['大瑞']='大瑞瑞:BAAALgAECgkJCQAAAA==.',
['大知']='大知闲闲:BAAALgAECgYJBgAAAA==.',
['天降']='天降妮姆芙:BAAALgAECgYJBgAAAA==.',
['头上']='头上有呆毛:BAAALgADCgEJAQABLgAECgYJEgAJAAAAAA==.',
['头脑']='头脑计算:BAAALgAECgEJAQAAAA==.',
['奇想']='奇想天恸:BAABLgAECn8ZAAIPAAgJfhUNKgDhAQAPAAgJfhUNKgDhAQAAAA==.',
['奈萨']='奈萨里蛋:BAAALgADCgEJAQAAAA==.',
['奶不']='奶不了一点:BAAALgADCgEJAQAAAA==.',
['奶盖']='奶盖不加冰:BAAALgAECgIJAQAAAA==.奶盖五分糖:BAAALgAFFAIJBAAAAA==.',
['如丶']='如丶如:BAAALgADCgUJBQAAAA==.',
['如冰']='如冰虽不冻:BAAALgAECgEJAQAAAA==.',
['妖婧']='妖婧姐姐:BAAALgAECgEJAQAAAA==.',
['姜灬']='姜灬伯灬约:BAAALgADCgMJAwAAAA==.',
['姝落']='姝落:BAAALgAECgkJBwAAAA==.',
['娃丶']='娃丶娃:BAAALgAECgYJBgAAAA==.',
['娜塔']='娜塔莉雅:BAAALgAECgIJAgAAAA==.',
['孤独']='孤独丶迪:BAAALgAFFAIJAwAAAA==.',
['守护']='守护女神之战:BAAALgAECgIJAwAAAA==.',
['宙屿']='宙屿:BAAALgAFFAEJAQAAAA==.',
['宝迪']='宝迪:BAAALgAECgEJAQAAAA==.',
['寒丨']='寒丨月:BAAALgADCgcJBwAAAA==.',
['射你']='射你玩:BAAALgAECgYJBgAAAA==.',
['射得']='射得比你狠:BAAALgAECggJCAAAAA==.',
['小古']='小古凉:BAABLgAECn8VAAICAAYJRBfjbACHAQACAAYJRBfjbACHAQAAAA==.',
['小吥']='小吥懂:BAAALgAECgYJBgAAAA==.',
['小吧']='小吧嗒丶:BAABLgAECn8YAAIFAAgJWAa1hwBxAQAFAAgJWAa1hwBxAQAAAA==.',
['小坏']='小坏不坏:BAAALgAECgUJBQAAAA==.',
['小小']='小小熊猫:BAAALgAECgYJBgAAAA==.',
['小时']='小时候救过人:BAAALgAFFAIJBAAAAA==.',
['小朋']='小朋友:BAAALgAECgUJCQAAAA==.',
['小狐']='小狐饼干:BAAALgAECgcJBwAAAA==.',
['小萌']='小萌猎丶:BAAALgADCgYJBgAAAA==.',
['小锅']='小锅块丶:BAAALgADCgcJBwAAAA==.',
['少时']='少时诵诗书啊:BAAALgAECgcJDwAAAA==.',
['尛孟']='尛孟起:BAACLgAFFH8PAAMMAAUJdCHzCgBpAQAMAAQJUh/zCgBpAQALAAMJwiEWDgDLAAAuAAQKfx0AAwwACAmqIzALAPICAAwACAkWIzALAPICAAsAAgnMJpKAAOYAAAAA.',
['尛紅']='尛紅手丶拾卅:BAABLgAFFH8GAAINAAMJaxygDwAFAQANAAMJaxygDwAFAQABLgAFFAQJCAANALATAA==.',
['山之']='山之巅:BAAALgAECggJBwAAAA==.',
['岁月']='岁月的童話:BAAALgADCgMJAwAAAA==.',
['岛田']='岛田家的仗:BAAALgADCgYJBgAAAA==.',
['巃神']='巃神死骑:BAAALgAECgkJCQAAAA==.',
['左手']='左手堕落:BAAALgAECgEJAQAAAA==.',
['布响']='布响丸辣:BAAALgADCgYJBgAAAA==.',
['师太']='师太我还要:BAAALgADCgUJBQAAAA==.',
['幽鬼']='幽鬼逆天:BAAALgAECgYJCwAAAA==.',
['庞然']='庞然小捅:BAAALgAECgQJBAAAAA==.',
['归零']='归零:BAAALgAECgMJAwAAAA==.',
['彩虹']='彩虹:BAAALgADCgEJAQAAAA==.彩虹之桥:BAAALgADCgYJBgAAAA==.',
['從鈊']='從鈊僾祢:BAAALgAECgMJAwAAAA==.',
['忄水']='忄水月飞忄:BAAALgADCgEJAQAAAA==.',
['态态']='态态你好:BAAALgAECgEJAwAAAA==.',
['怜沥']='怜沥丨丶洛夏:BAAALgAECgQJBQAAAA==.',
['怪天']='怪天气:BAAALgAECgcJBwAAAA==.',
['恶必']='恶必斩:BAAALgADCgQJBAAAAA==.',
['恶鬼']='恶鬼羊驼:BAAALgADCgEJAQAAAA==.',
['情深']='情深缘淺丶:BAAALgADCgEJAQAAAA==.',
['惧之']='惧之煞:BAAALgAECgUJBAAAAA==.',
['惩之']='惩之煞:BAAALgAECgYJCQAAAA==.',
['愚蠢']='愚蠢的部落猪:BAAALgAECgMJAwAAAA==.',
['愤怒']='愤怒小娜美:BAAALgADCgIJAgAAAA==.',
['懒得']='懒得打名字:BAAALgAECgIJAgAAAA==.',
['我来']='我来组成美腿:BAAALgAECgEJAQAAAA==.',
['扎德']='扎德雷:BAABLgAECn8UAAILAAcJKR6+FgCCAgALAAcJKR6+FgCCAgAAAA==.',
['散落']='散落的烟灰:BAAALgAECgQJBQAAAA==.',
['敲尼']='敲尼哇:BAAALgAECgUJBgAAAA==.',
['斩杀']='斩杀女神:BAAALgAECgEJAQAAAA==.',
['方元']='方元几何:BAAALgAECgQJBAAAAA==.',
['无心']='无心杂念:BAAALgADCgYJBgAAAA==.',
['无情']='无情的粉碎:BAAALgAECgQJBAAAAA==.',
['无敌']='无敌三娃:BAAALgADCgcJCgABLgAECgYJDAAJAAAAAA==.',
['无瑕']='无瑕:BAAALgAECgkJBAAAAA==.',
['既来']='既来之则安之:BAAALgAECgEJAQAAAA==.',
['旭阿']='旭阿:BAAALgAECgEJAgAAAA==.',
['时光']='时光巨人:BAABLgAFFH8FAAICAAIJEAicOgCeAAACAAIJEAicOgCeAAAAAA==.',
['明镜']='明镜之光:BAAALgAECgQJBAAAAA==.',
['易水']='易水寒丶:BAAALgADCgIJAgAAAA==.',
['昔涟']='昔涟:BAAALgAECgEJAQAAAA==.',
['星之']='星之所往:BAACLgAFFH8LAAIQAAQJFBbJBwBpAQAQAAQJFBbJBwBpAQAuAAQKfxUAAhAACAk1HR8RAJgCABAACAk1HR8RAJgCAAAA.',
['春梦']='春梦了无狠:BAAALgADCgEJAQAAAA==.',
['晓星']='晓星子:BAAALgAFFAQJAQAAAA==.',
['晨光']='晨光丶红蝶:BAAALgAECggJCAAAAA==.',
['暖色']='暖色调丶:BAAALgAECgEJAQAAAA==.',
['暗黑']='暗黑熊:BAAALgAFFAMJBAAAAA==.暗黑虎:BAAALgAECgQJBAAAAA==.',
['暮然']='暮然回首丿歰:BAAALgAECgcJBwAAAA==.',
['暮落']='暮落星尘:BAAALgAECgEJAQAAAA==.',
['暴打']='暴打柠檬:BAAALgAECgUJCgAAAA==.',
['暴特']='暴特斯:BAAALgAECggJDgAAAA==.',
['最萌']='最萌二狗锅:BAAALgAECgMJAwAAAA==.',
['月下']='月下雪:BAAALgAECgEJAQAAAA==.',
['月光']='月光灬疾风灬:BAAALgADCgYJBwAAAA==.',
['有个']='有个兜兜:BAAALgADCgQJBAAAAA==.',
['有医']='有医保随便搞:BAAALgAECgEJAQAAAA==.',
['木有']='木有美眉:BAAALgAECgYJBgAAAA==.',
['未始']='未始已终:BAAALgADCgEJAQAAAA==.',
['术的']='术的秘密:BAAALgAECgUJDgAAAA==.',
['杯具']='杯具也疯狂:BAAALgAECgEJAQAAAA==.',
['杲汖']='杲汖:BAAALgADCgYJCwAAAA==.',
['果扎']='果扎冰:BAAALgAECgcJEwAAAA==.',
['柒心']='柒心嫖虫:BAAALgAECgYJBgAAAA==.',
['梅友']='梅友镜:BAAALgAECgIJAgAAAA==.',
['橙肩']='橙肩橙戒:BAAALgAECgYJBwAAAA==.',
['欧皇']='欧皇丶泰兰徳:BAAALgADCgUJBQAAAA==.欧皇喵喵:BAAALgAFFAQJBAAAAA==.',
['正义']='正义的光:BAAALgAECgYJCQAAAA==.',
['死亡']='死亡之旋舞:BAAALgAECgEJAQAAAA==.',
['气场']='气场两米八:BAAALgADCgkJEwAAAA==.',
['水咲']='水咲萝拉:BAAALgAECgEJAQABLgAFFAMJBAAJAAAAAA==.',
['永远']='永远追随蛋哥:BAAALgAECgcJEgAAAA==.',
['汐玥']='汐玥:BAAALgAECgUJBgAAAA==.',
['江东']='江东小霸王灬:BAACLgAFFH8RAAMLAAUJ0RgACAAcAQAMAAUJaQncCwBdAQALAAMJ9xoACAAcAQAuAAQKfx8AAgwACAn4HKIYAGMCAAwACAn4HKIYAGMCAAAA.',
['没睡']='没睡醒的猫:BAAALgAECgUJBQAAAA==.',
['法夜']='法夜:BAAALgAECgEJAQAAAA==.',
['法爷']='法爷:BAAALgAFFAIJBAAAAA==.',
['法王']='法王艾斯:BAAALgADCgMJAwAAAA==.',
['泡芙']='泡芙虾妮:BAAALgADCgEJAQAAAA==.',
['泰瑞']='泰瑞尔凯文:BAAALgADCgYJBgABLgAECgcJBwAJAAAAAA==.泰瑞尔语风:BAAALgAECgcJBwAAAA==.',
['浅浅']='浅浅的叹息:BAAALgADCgEJAQAAAA==.',
['浊谷']='浊谷山人主:BAAALgAFFAMJAwAAAA==.',
['浮云']='浮云潞安:BAAALgADCgMJAwAAAA==.',
['浮生']='浮生茹梦:BAAALgAECgYJBgAAAA==.',
['海婭']='海婭:BAAALgADCgQJAQAAAA==.',
['淑妮']='淑妮姥姆:BAAALgAECgYJBgAAAA==.',
['淡淡']='淡淡幽香:BAAALgADCgYJBgAAAA==.',
['渣肉']='渣肉蒸饭丶:BAAALgAECgEJAQAAAA==.',
['潘达']='潘达利亚王:BAAALgADCgUJBQAAAA==.',
['灌注']='灌注来咯:BAAALgAECgkJCQAAAA==.',
['灬无']='灬无幽:BAAALgAECgQJBgAAAA==.',
['灬末']='灬末路:BAAALgAECgcJDgAAAA==.',
['灬落']='灬落落灬:BAAALgAECgYJCQAAAA==.',
['灬阿']='灬阿威灬:BAAALgAECgMJAwAAAA==.',
['炸你']='炸你丫的:BAAALgAECgYJCwAAAA==.',
['烈焰']='烈焰灬变又变:BAAALgAECgUJBQAAAA==.',
['热烈']='热烈的马:BAAALgAECgYJBwAAAA==.',
['焦糖']='焦糖麦旋风:BAAALgAECgEJAQAAAA==.',
['爆脆']='爆脆星星堡:BAAALgADCgcJBwAAAA==.',
['爱露']='爱露莎蕾:BAAALgAECgcJDQAAAA==.',
['牛牛']='牛牛乖不哭了:BAAALgAFFAMJAwAAAA==.',
['特伦']='特伦蘇丶:BAAALgAFFAMJAwAAAA==.',
['狂暴']='狂暴的小泥鳅:BAAALgADCgEJAQAAAA==.',
['猫竟']='猫竟然会哭:BAAALgAECgkJCQAAAA==.',
['玛格']='玛格汉犇犇:BAAALgAECgEJAgAAAA==.',
['瑞豪']='瑞豪:BAAALgAECgEJAgAAAA==.',
['电了']='电了个电:BAAALgAECgYJBgABLgAFFAQJBAAJAAAAAA==.',
['疯狂']='疯狂小防骑:BAAALgADCgIJAgAAAA==.',
['疯狐']='疯狐:BAAALgAECgEJAQAAAA==.',
['白發']='白發魔莮:BAAALgAECgYJCwAAAA==.',
['盆盆']='盆盆儿:BAAALgAECgEJAQAAAA==.',
['真心']='真心不懂老湿:BAAALgAFFAIJAwAAAA==.',
['眠羊']='眠羊:BAABLgAECn8VAAIKAAYJFh4rjQC4AQAKAAYJFh4rjQC4AQAAAA==.',
['瞎子']='瞎子很风骚:BAAALgAFFAMJBAAAAA==.瞎子阿饼:BAABLgAFFH8HAAIIAAIJoBR4GQCdAAAIAAIJoBR4GQCdAAAAAA==.',
['祈求']='祈求者:BAAALgAFFAMJBAAAAA==.',
['祖师']='祖师爷上身:BAAALgAECgYJCAAAAA==.',
['神秘']='神秘消失:BAABLgAFFH8FAAIQAAIJAxIyEwCzAAAQAAIJAxIyEwCzAAAAAA==.',
['禁铺']='禁铺又禁盖:BAAALgAECgcJDgAAAA==.',
['空叹']='空叹时:BAAALgADCgIJAgAAAA==.',
['空空']='空空哉:BAAALgAECgEJAQAAAA==.',
['空车']='空车帝三号机:BAAALgAECgcJCgAAAA==.',
['空间']='空间规划速度:BAAALgAECgMJBAAAAA==.',
['红心']='红心番石榴:BAAALgAECgQJBQAAAA==.',
['红色']='红色体育生:BAABLgAFFH8FAAMFAAQJCiKuBgCcAQAFAAQJCiKuBgCcAQARAAEJVg+DFgBAAAAAAA==.',
['红辣']='红辣椒:BAAALgADCgQJBAAAAA==.',
['纵情']='纵情:BAAALgAECgkJCAAAAA==.',
['纵火']='纵火狂丶焰:BAAALgAECgIJAwAAAA==.',
['绀野']='绀野木棉季丶:BAAALgAECgEJAQABLgAFFAMJBQASAC8ZAA==.',
['结城']='结城美柑丶:BAABLgAFFH8FAAITAAIJXhfnEQCnAAATAAIJXhfnEQCnAAABLgAFFAMJBQASAC8ZAA==.',
['缪莹']='缪莹涵:BAAALgAECgYJBgAAAA==.',
['罒冰']='罒冰雨罒:BAAALgAECgYJBgAAAA==.',
['罒午']='罒午夜罒:BAAALgADCgEJAQAAAA==.',
['罒娇']='罒娇花罒:BAAALgAECgYJBgAAAA==.',
['罒舞']='罒舞者罒:BAAALgAECgYJBgAAAA==.',
['美丽']='美丽的大牙:BAABLgAECn8bAAMHAAgJABxTIgDRAQAHAAYJuhxTIgDRAQAUAAUJZBKzDwAiAQAAAA==.',
['羽隹']='羽隹:BAAALgAECgQJBQAAAA==.',
['老冫']='老冫:BAAALgADCgEJAQAAAA==.',
['老紫']='老紫属道山:BAABLgAFFH8JAAILAAQJtRWxAwBcAQALAAQJtRWxAwBcAQAAAA==.',
['聆听']='聆听者丶:BAAALgADCgEJAQAAAA==.',
['职业']='职业打铁:BAAALgAECgcJCAAAAA==.',
['聖光']='聖光忽悠着你:BAAALgAECgYJBgAAAA==.',
['肝出']='肝出二十橙:BAAALgAECgEJAQAAAA==.',
['背后']='背后有尾巴:BAAALgAECgEJAQAAAA==.',
['胖揍']='胖揍小怪兽:BAAALgADCgIJAgAAAA==.',
['臭烂']='臭烂碎鸡者:BAABLgAECn8aAAMVAAgJ3wUEMABnAQAVAAgJ3wUEMABnAQANAAEJVwD2mgASAAAAAA==.',
['艾丽']='艾丽斯:BAABLgAFFH8GAAMEAAMJUAgCFQCcAAAEAAMJUAgCFQCcAAASAAEJ3QGyKgA0AAAAAA==.',
['艾斯']='艾斯卡洛:BAACLgAFFH8NAAIWAAQJIReCCQBRAQAWAAQJIReCCQBRAQAuAAQKfxsAAhYACQkcGnEJAJ8CABYACQkcGnEJAJ8CAAAA.',
['艾森']='艾森娜琳晨雾:BAAALgADCgcJBwAAAA==.',
['花儿']='花儿不会忘记:BAAALgAECgcJBwAAAA==.',
['茗門']='茗門灬主宰:BAAALgAFFAIJAgAAAA==.',
['草原']='草原羊驼:BAAALgAECgEJAQAAAA==.',
['莉娅']='莉娅铂邏:BAAALgAECgkJAQAAAA==.',
['莫幺']='莫幺幺:BAAALgAFFAIJAgAAAA==.',
['莫贤']='莫贤贤:BAAALgADCgQJBAAAAA==.',
['落花']='落花星焰:BAABLgAFFH8FAAIRAAUJbxRvBABlAQARAAUJbxRvBABlAQAAAA==.落花泥香:BAAALgAECgEJAQAAAA==.',
['葫芦']='葫芦大官人:BAAALgADCgQJBAAAAA==.',
['藿香']='藿香花露水:BAAALgADCggJAQAAAA==.',
['行吟']='行吟:BAAALgADCgYJBgAAAA==.',
['要樂']='要樂奈:BAAALgAECgkJEAAAAA==.',
['记忆']='记忆的微笑:BAAALgAECgcJDQAAAA==.',
['请叫']='请叫我土豪:BAAALgAECgEJAgAAAA==.',
['诸因']='诸因解体:BAACLgAFFH8YAAISAAYJRCIxAAB1AgASAAYJRCIxAAB1AgAuAAQKfx4AAhIACQlmIxwCAHwDABIACQlmIxwCAHwDAAAA.',
['谈爱']='谈爱已老:BAAALgAECgMJAwAAAA==.',
['谢尔']='谢尔比丶坤昆:BAAALgAECgYJDwAAAA==.',
['谣妹']='谣妹:BAAALgAECgEJAgAAAA==.',
['貝恩']='貝恩霍克:BAAALgAFFAEJAQAAAA==.',
['赖桑']='赖桑之颅:BAAALgAECgIJAgAAAA==.',
['赤座']='赤座灯外:BAAALgAFFAMJBAAAAA==.',
['路人']='路人乙:BAAALgAECgcJEQAAAA==.',
['路子']='路子涯:BAAALgADCgEJAQAAAA==.',
['身娇']='身娇肉貴:BAAALgAECgIJAgAAAA==.',
['辛灬']='辛灬糯蕾:BAAALgADCgYJBgAAAA==.辛灬诺蕾:BAAALgAECgEJAQAAAA==.',
['这题']='这题我会:BAAALgADCgUJBQAAAA==.',
['逍遥']='逍遥哉:BAAALgAECgUJBQAAAA==.',
['進擊']='進擊的趙小帥:BAAALgAECgkJCQAAAA==.',
['那一']='那一年的風:BAAALgAECgcJBwAAAA==.',
['酱味']='酱味大鸡:BAAALgAECgEJAQAAAA==.',
['酱椒']='酱椒鱼头:BAAALgAECgQJBQAAAA==.',
['酱紫']='酱紫剑:BAAALgAECgQJBgAAAA==.',
['醉丨']='醉丨吟丨剑:BAAALgAECgcJDQAAAA==.',
['醒不']='醒不来的梦:BAAALgADCgYJBgAAAA==.',
['锋芒']='锋芒丶:BAAALgAECgYJBgAAAA==.',
['镜之']='镜之猪猪:BAAALgAECgYJBgAAAA==.',
['阿无']='阿无:BAAALgAECgEJAQAAAA==.',
['陈冠']='陈冠睎:BAACLgAFFH8KAAICAAUJShpQDgBqAQACAAUJShpQDgBqAQAuAAQKfxcABAIABwlAHTEUAJEBAAIABwlAHTEUAJEBAAMAAgmMGXFQAHwAABcAAQkAAAUkAGEAAAAA.',
['降临']='降临丶:BAAALgAFFAQJBAAAAA==.',
['雾丨']='雾丨迷踪:BAAALgADCgIJAgAAAA==.',
['霜火']='霜火漫天:BAAALgAECgIJAwAAAA==.',
['青衣']='青衣冷羽:BAAALgAECgIJAgAAAA==.',
['風吹']='風吹鸡蛋殼:BAAALgADCgIJAgAAAA==.',
['风碑']='风碑:BAAALgAECgYJCAAAAA==.',
['风语']='风语者凯瑟琳:BAACLgAFFH8RAAMMAAYJwxGGBADsAQAMAAYJwxGGBADsAQALAAEJwRJXGwBZAAAuAAQKfx0AAwwACAnFIbwNANQCAAwACAnFIbwNANQCAAsAAQmzFWPIAD0AAAAA.',
['风魔']='风魔传说:BAAALgAECgEJAQAAAA==.',
['飘渺']='飘渺的月亮:BAAALgAECgEJAQAAAA==.',
['飞刀']='飞刀丶:BAAALgAECgIJAgAAAA==.',
['飞跃']='飞跃苏联:BAACLgAFFH8NAAIYAAUJ2hkOAgCmAQAYAAUJ2hkOAgCmAQAuAAQKfyoAAhgACAmGJXICAGUDABgACAmGJXICAGUDAAAA.',
['食野']='食野之萍:BAAALgAECgQJBwAAAA==.',
['馬莎']='馬莎莎丶:BAAALgADCgYJBgAAAA==.',
['骑士']='骑士道:BAAALgAFFAIJAwAAAA==.',
['魔力']='魔力瞎:BAAALgAECgYJBgAAAA==.',
['魔法']='魔法羊驼:BAABLgAECn8VAAIKAAYJDRaKlQCpAQAKAAYJDRaKlQCpAQAAAA==.',
['麦克']='麦克邱:BAAALgAECgEJAQAAAA==.',
['黄的']='黄的琞艳:BAAALgAECgUJBQAAAA==.',
['黑暗']='黑暗小德:BAAALgAECgUJBQAAAA==.黑暗收割者:BAAALgADCgUJBQAAAA==.',
['黯色']='黯色:BAAALgAECgMJAgAAAA==.',
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
