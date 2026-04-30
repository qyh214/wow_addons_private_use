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

local lookup = {'Rogue-Subtlety','Shaman-Elemental','DemonHunter-Devourer','DemonHunter-Havoc','Unknown-Unknown','Priest-Holy','Warrior-Protection','DeathKnight-Unholy','Mage-Frost','Warrior-Fury','Druid-Balance','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Warlock-Demonology','Priest-Discipline','Priest-Shadow','Paladin-Retribution','DeathKnight-Frost',}
local provider = {region='CN',realm='元素之力',name='CN',type='weekly',zone=46,date='2026-04-25',data={Av='Avrillavigne:BAAALgAECgYJCgAAAA==.',
Ay='Ayanamirei:BAACLgAFFH8HAAIBAAIJkRc2EgC4AAABAAIJkRc2EgC4AAAuAAQKfxcAAgEACAn4FXMVAGUCAAEACAn4FXMVAGUCAAAA.',
Ca='Cass:BAAALgADCgEJAQAAAA==.',
Cc='Cchk:BAAALgAECgYJEAAAAA==.Ccone:BAAALgAECgQJBAAAAA==.',
Da='Daniel:BAAALgADCgUJBQAAAA==.',
De='Devilkin:BAAALgAECgYJCQAAAA==.',
Hy='Hymen:BAAALgAFFAEJAQAAAA==.',
Ji='Jiwoopal:BAAALgAECgcJEQAAAA==.',
Jt='Jto:BAAALgAFFAQJBAAAAA==.',
No='Norton:BAAALgAECgYJCQAAAA==.',
Sa='Sakurada:BAAALgAECgQJBQAAAA==.Sar:BAAALgAFFAMJAgAAAA==.',
Su='Summer:BAABLgAFFH8FAAICAAUJ3hTABACVAQACAAUJ3hTABACVAQAAAA==.',
['一拳']='一拳超狐秒杀:BAAALgADCgYJCwAAAA==.',
['一身']='一身白毛:BAAALgAECgIJAgAAAA==.',
['上帝']='上帝地意志:BAAALgADCgIJAgAAAA==.',
['下冰']='下冰雹了吗:BAABLgAFFH8IAAMDAAMJVQ7/HADsAAADAAMJVQ7/HADsAAAEAAEJPAEDEABAAAABLgAFFAUJBAAFAAAAAA==.',
['不老']='不老亡魂:BAABLgAECn8ZAAIGAAgJThyrCwCWAgAGAAgJThyrCwCWAgAAAA==.',
['且随']='且随风行:BAAALgAECgEJAwAAAA==.',
['东方']='东方烧饼:BAAALgAECgEJAQABLgAECgYJCQAFAAAAAA==.',
['乌疯']='乌疯子:BAAALgAECgYJDAAAAA==.',
['乔克']='乔克阿姨:BAAALgAECgEJAwAAAA==.',
['克洛']='克洛:BAAALgADCgEJAQAAAA==.',
['兵哥']='兵哥家的妞妞:BAAALgAECgQJBAAAAA==.',
['养牛']='养牛专业户:BAAALgAFFAIJBAAAAA==.',
['冬至']='冬至雪未至:BAAALgADCgEJAQAAAA==.',
['凌晨']='凌晨一点钟:BAAALgAECgEJAgAAAA==.',
['凡天']='凡天:BAAALgAECgYJDQAAAA==.',
['凡泠']='凡泠僧:BAAALgAECgUJBAAAAA==.',
['出土']='出土文物:BAAALgAECgkJCQABLgAFFAUJEgAHAJshAA==.',
['刘教']='刘教兽:BAAALgADCgUJBQAAAA==.',
['剑布']='剑布衣:BAAALgAECgYJCwAAAA==.',
['勇敢']='勇敢的虫虫:BAAALgAECgEJAQAAAA==.',
['勇猛']='勇猛的饺子:BAAALgADCgEJAQAAAA==.',
['匿影']='匿影藏形:BAAALgAECgYJAwAAAA==.',
['千荷']='千荷亦:BAAALgADCgMJAwAAAA==.千荷壹:BAAALgAECgUJBwAAAA==.',
['半冥']='半冥伤:BAAALgAECgYJBgAAAA==.半冥痕:BAAALgAECgYJBgAAAA==.',
['卖火']='卖火柴的朮丗:BAAALgAFFAEJAQAAAA==.卖火柴的欧皇:BAAALgADCgMJAwAAAA==.卖火柴的熊熊:BAAALgADCgUJBQAAAA==.',
['卡米']='卡米拉:BAABLgAECn8ZAAIIAAgJWRLrUQD8AQAIAAgJWRLrUQD8AQAAAA==.',
['吴钩']='吴钩似雪:BAAALgADCgIJAgAAAA==.',
['咕咕']='咕咕不咕:BAAALgADCgEJAQAAAA==.',
['哆啦']='哆啦誒喵:BAAALgAECgIJAgAAAA==.',
['哈基']='哈基米:BAAALgAECgcJDQAAAA==.',
['回归']='回归:BAAALgADCgkJGAAAAA==.',
['团长']='团长我躺哪儿:BAABLgAFFH8HAAIJAAMJ/hmmJgAYAQAJAAMJ/hmmJgAYAQABLgAFFAUJBwAJAMcZAA==.',
['园田']='园田海未:BAAALgAFFAIJAgAAAA==.',
['地狱']='地狱小吼:BAABLgAECn8UAAIKAAcJxRIsNwDLAQAKAAcJxRIsNwDLAQAAAA==.',
['堕落']='堕落的雨:BAAALgAECgYJBgAAAA==.',
['夜子']='夜子寒:BAAALgAECgQJBwAAAA==.',
['夜魔']='夜魔苍穹:BAAALgADCgEJAQAAAA==.',
['大佬']='大佬黑:BAAALgAECgEJAQAAAA==.',
['大狼']='大狼:BAAALgAECgYJBgAAAA==.',
['大白']='大白兔奶牛:BAAALgAECgkJEAABLgAFFAYJGQALAMQgAA==.',
['天有']='天有四时:BAAALgADCgUJBQAAAA==.',
['天机']='天机丶蒂尼:BAAALgAECgIJAgAAAA==.',
['天棒']='天棒:BAAALgADCgYJBgAAAA==.',
['太乙']='太乙真人:BAAALgADCgEJAQAAAA==.',
['太白']='太白星君:BAAALgAECgEJAQAAAA==.',
['奇希']='奇希莉卡:BAAALgAECgkJEAABLgAFFAIJAQAFAAAAAA==.',
['好想']='好想睡觉呀:BAAALgAECgUJBQAAAA==.',
['好拽']='好拽的蒙蒙:BAAALgAECgMJAwAAAA==.',
['婷婷']='婷婷:BAAALgADCgEJAQAAAA==.',
['安静']='安静的大懒猫:BAAALgAECgcJEAAAAA==.',
['寒舞']='寒舞寂:BAABLgAECn8YAAMMAAcJABuRGgBoAgAMAAcJABuRGgBoAgANAAIJUw+DdwBhAAABLgAFFAMJCQAGANAPAA==.',
['小汪']='小汪睡不醒:BAAALgAECggJDQAAAA==.',
['小猫']='小猫扑风铃:BAAALgAECgIJAgAAAA==.',
['小矮']='小矮子:BAAALgADCgEJAQAAAA==.',
['小路']='小路漫漫:BAAALgAECggJCQAAAA==.',
['少年']='少年王之怒:BAABLgAECn8ZAAMOAAgJHBKVGwBxAQAOAAcJrBCVGwBxAQAIAAEJwRovEgFQAAAAAA==.',
['希尔']='希尔小娜斯:BAAALgADCgYJBgAAAA==.',
['希露']='希露菲叶特:BAAALgAFFAIJAQAAAA==.',
['帝殒']='帝殒:BAAALgAFFAMJAwAAAA==.',
['席尔']='席尔瓦纳斯:BAABLgAECn8ZAAIPAAgJCxZVLwBPAgAPAAgJCxZVLwBPAgAAAA==.',
['幽泉']='幽泉:BAAALgAECgcJBwAAAA==.',
['弗拉']='弗拉明戈舞步:BAAALgAECgkJAgAAAA==.',
['德神']='德神:BAAALgAECgYJBQAAAA==.',
['怎么']='怎么也睡不够:BAAALgAFFAEJAQAAAA==.',
['悟嗳']='悟嗳慲訫:BAACLgAFFH8JAAMGAAMJ0A+xCQDLAAAQAAMJJwuqBgDmAAAGAAMJ+QixCQDLAAAuAAQKfyMABBAACQntELQbALgBABAACQnrDrQbALgBAAYABgn5EWUxAHsBABEAAwlmBOtTAHUAAAAA.',
['慕白']='慕白:BAAALgAECgMJBAAAAA==.',
['我就']='我就是我的:BAAALgAECgYJEAAAAA==.',
['我比']='我比你高:BAAALgAECgIJAwAAAA==.',
['我的']='我的小可爱丶:BAAALgADCgEJAQAAAA==.',
['我知']='我知道要进潜:BAAALgAECgkJCQAAAA==.',
['戴蒙']='戴蒙黑火:BAAALgAFFAEJAQAAAA==.',
['扶阿']='扶阿奶闯红灯:BAAALgAECggJEgAAAA==.',
['抽象']='抽象:BAAALgAECgQJBAAAAA==.',
['撒哈']='撒哈拉哟吼:BAAALgADCgcJCQAAAA==.',
['新手']='新手中的大神:BAAALgADCgIJAgAAAA==.',
['无人']='无人知晓:BAAALgADCgYJBgAAAA==.',
['无敌']='无敌砍王:BAAALgAFFAEJAQAAAA==.',
['日川']='日川纲版:BAACLgAFFH8OAAISAAQJ2SPcBACjAQASAAQJ2SPcBACjAQAuAAQKfyEAAhIACAm6IqUOABkDABIACAm6IqUOABkDAAAA.',
['明玉']='明玉小可爱:BAAALgAECgQJBQAAAA==.',
['星汉']='星汉天空:BAAALgAECgEJAQAAAA==.',
['月牙']='月牙天冲:BAAALgADCgYJBgAAAA==.',
['月璃']='月璃牧梦:BAAALgADCgUJBQAAAA==.',
['李知']='李知恩:BAAALgADCgcJDQAAAA==.',
['柑橘']='柑橘乌云:BAAALgAFFAEJAQAAAA==.',
['柠檬']='柠檬树下:BAAALgAECgYJBwAAAA==.',
['梦中']='梦中的浮空城:BAAALgAECgYJDAAAAA==.',
['梨涡']='梨涡浅笑:BAAALgAECgUJBQAAAA==.',
['椰子']='椰子水:BAABLgAFFH8GAAISAAMJmQx5FwDyAAASAAMJmQx5FwDyAAAAAA==.',
['此螺']='此螺非彼狼:BAAALgAECgIJAgAAAA==.',
['油老']='油老师狂热粉:BAAALgAECgcJEgAAAA==.',
['油面']='油面筋:BAAALgAECgcJEQAAAA==.',
['清寒']='清寒仙君:BAAALgAECgEJAQAAAA==.',
['清衣']='清衣晚风:BAAALgAFFAIJAwAAAA==.',
['潙沵']='潙沵箛啴:BAAALgAECgEJAgAAAA==.',
['灰常']='灰常:BAAALgAECgUJBQAAAA==.',
['烟雨']='烟雨伊风:BAAALgAECgYJDgAAAA==.',
['热狗']='热狗将军口牙:BAAALgAECgUJCwAAAA==.',
['熬夜']='熬夜怪很困:BAAALgAECgMJAwAAAA==.',
['爱你']='爱你魔:BAAALgAECgIJBAAAAA==.',
['爱沵']='爱沵妹旳情:BAAALgAECgkJCQAAAA==.',
['牧起']='牧起一坨:BAAALgADCgMJAwAAAA==.',
['猎户']='猎户星座:BAAALgAFFAIJAgAAAA==.',
['猫迩']='猫迩葉:BAAALgAECgkJBgAAAA==.',
['珞珈']='珞珈梵音:BAAALgAECgYJBgAAAA==.',
['琳琳']='琳琳带你飞:BAAALgADCgUJFwAAAA==.',
['电梯']='电梯战神:BAAALgAECgMJAwAAAA==.',
['电疗']='电疗皮卡丘:BAAALgADCgEJAgAAAA==.',
['疯狂']='疯狂太子:BAAALgAECgMJAwAAAA==.疯狂恶魔:BAAALgADCgUJBgAAAA==.',
['百叶']='百叶窗:BAAALgAECgYJBgABLgAECgcJEQAFAAAAAA==.',
['百撕']='百撕吥得骑姐:BAAALgAECgYJBwAAAA==.',
['睡觉']='睡觉呀:BAAALgAECgEJAgAAAA==.',
['筱晓']='筱晓:BAAALgADCgEJAQAAAA==.',
['紫毛']='紫毛精灵:BAAALgAECgUJBQAAAA==.',
['红楼']='红楼梦靥:BAAALgAECgIJAgABLgAECgYJCQAFAAAAAA==.',
['美味']='美味肉夹馍:BAAALgADCgUJBQAAAA==.',
['老大']='老大:BAACLgAFFH8IAAMIAAQJ5RimFAC2AAAIAAQJ5RimFAC2AAAOAAEJ0gDPCgAnAAAuAAQKfx4ABAgACAk6HCU5AFICAAgACAk6HCU5AFICAA4ABAmxCFQyAK0AABMAAgnZA3IVAD4AAAAA.',
['艾莉']='艾莉丝:BAAALgAECgcJBwABLgAFFAIJAQAFAAAAAA==.',
['艾莲']='艾莲:BAABLgAFFH8GAAIJAAIJ9hmJOQC3AAAJAAIJ9hmJOQC3AAAAAA==.',
['花开']='花开在离别:BAAALgAECgkJCQAAAA==.',
['莎拉']='莎拉格雷拉特:BAAALgAECgcJDAABLgAFFAIJAQAFAAAAAA==.',
['莫里']='莫里娅蒂教授:BAAALgAECgIJAgAAAA==.',
['菲林']='菲林洛骑天:BAABLgAECn8bAAISAAYJdBY9ewCEAQASAAYJdBY9ewCEAQAAAA==.',
['萌新']='萌新小萨:BAAALgAFFAMJAwAAAA==.',
['萨米']='萨米术格:BAAALgADCgEJAQAAAA==.萨米法:BAAALgADCgYJBwAAAA==.',
['萨萨']='萨萨里安:BAAALgADCgMJAwAAAA==.',
['蛇床']='蛇床子:BAAALgADCgMJAwAAAA==.',
['裴钱']='裴钱:BAAALgAECgEJAgAAAA==.',
['资深']='资深读书人:BAAALgAECgkJAQAAAA==.',
['赞达']='赞达拉之手:BAAALgADCgUJBQAAAA==.',
['这个']='这个人有点冷:BAAALgAFFAEJAQAAAA==.',
['邪恶']='邪恶小猫:BAAALgAECgQJBwAAAA==.',
['酒酿']='酒酿:BAAALgAECgEJAQAAAA==.',
['锦瑟']='锦瑟丸子:BAAALgAECgEJAQAAAA==.',
['阿发']='阿发古:BAAALgAECgEJAQAAAA==.',
['青焰']='青焰:BAAALgADCgUJBQAAAA==.',
['非诚']='非诚勿扰:BAAALgAFFAQJBAAAAA==.',
['预见']='预见死亡:BAAALgADCgcJBwAAAA==.',
['颠覆']='颠覆妖兽:BAAALgADCgcJDAAAAA==.颠覆小妖:BAAALgADCgEJAQAAAA==.颠覆恶魔:BAAALgADCgIJAgAAAA==.',
['风岚']='风岚儿:BAAALgAFFAIJAwAAAA==.',
['魔法']='魔法莉莉丝:BAAALgAECgIJAwAAAA==.',
['鸟白']='鸟白菜:BAAALgADCgYJBgAAAA==.',
['黄瓜']='黄瓜切片:BAAALgADCgEJAQAAAA==.',
['黑铁']='黑铁圣焰:BAAALgADCgEJAQAAAA==.',
['黑黑']='黑黑猫警长:BAAALgAECgEJAQAAAA==.',
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
