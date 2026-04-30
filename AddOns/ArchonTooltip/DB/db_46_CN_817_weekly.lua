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

local lookup = {'Evoker-Devastation','Evoker-Augmentation','Hunter-BeastMastery','Shaman-Restoration','Unknown-Unknown','Warlock-Demonology','Druid-Restoration','Paladin-Retribution','Warrior-Fury','Monk-Mistweaver','DeathKnight-Unholy','Rogue-Subtlety','Mage-Frost','Priest-Holy','Druid-Feral','Druid-Balance','Warrior-Arms','Priest-Discipline','Priest-Shadow','Warlock-Destruction','Warlock-Affliction','Hunter-Survival','Warrior-Protection','DemonHunter-Devourer','Hunter-Marksmanship','Paladin-Holy',}
local provider = {region='CN',realm='萨格拉斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alazif:BAAALgAFFAIJAgAAAA==.',
Bw='Bwonsamdi:BAAALgAECgYJEgAAAA==.',
Fe='Fenlix:BAAALgAECgYJEQAAAA==.',
Fi='Fin:BAABLgAECn8gAAMBAAgJMB6FAABhAgABAAgJMB6FAABhAgACAAEJGxPxYgAxAAAAAA==.',
Go='Gouter:BAAALgAECgYJBwAAAA==.',
Ha='Hardtosay:BAAALgAECgEJAQAAAA==.',
Im='Imghost:BAAALgAECgYJBgAAAA==.',
Kl='Klight:BAAALgAFFAQJBAAAAA==.',
Li='Link:BAABLgAFFH8GAAIDAAMJnBrVCQATAQADAAMJnBrVCQATAQAAAA==.',
Lo='Lookmyeyes:BAAALgAECgEJAQAAAA==.',
Ma='Majesty:BAAALgAECgYJDAAAAA==.',
Mo='Moonlightfly:BAAALgADCgEJAQAAAA==.',
Pe='Pepperoni:BAAALgAECgMJBAAAAA==.Perplex:BAAALgADCgYJBgAAAA==.',
Pl='Playerntdqqg:BAAALgADCgEJAQAAAA==.',
Ri='Riddle:BAACLgAFFH8KAAIEAAMJzyEhBgAmAQAEAAMJzyEhBgAmAQAuAAQKfyIAAgQACQkOIUgFAB0DAAQACQkOIUgFAB0DAAAA.',
Ro='Romeo:BAAALgAECgYJBgABLgAECgcJBAAFAAAAAA==.',
Se='Seo:BAAALgAECgEJAQAAAA==.',
Sp='Splatoon:BAABLgAECn8aAAIGAAgJRBfaBwAVAgAGAAgJRBfaBwAVAgAAAA==.',
Te='Tenfreedom:BAAALgADCgYJBgAAAA==.Teresse:BAAALgAECgMJAwAAAA==.',
Za='Zafir:BAAALgAECgEJAQAAAA==.Zatanna:BAAALgAECgkJBgAAAA==.',
['一千']='一千念:BAAALgAECgEJAQAAAA==.',
['上单']='上单不给就送:BAAALgADCgEJAQAAAA==.',
['不吃']='不吃猪肉:BAAALgAECgcJEAAAAA==.',
['世界']='世界真惊悚:BAAALgADCgEJAQAAAA==.',
['人间']='人间荒糖:BAAALgAECgEJAwAAAA==.',
['从何']='从何说起:BAAALgAECgEJAQAAAA==.',
['伊利']='伊利豆:BAAALgAECgYJDAAAAA==.',
['伊莎']='伊莎贝拉之眸:BAAALgAECgMJAgAAAA==.',
['你二']='你二姨:BAAALgAECgUJBQAAAA==.',
['你们']='你们不用奶我:BAAALgAECgcJBwAAAA==.',
['俊秀']='俊秀小瀦:BAAALgAECgEJAgAAAA==.',
['兜大']='兜大师:BAAALgAFFAIJBAAAAA==.',
['八云']='八云橙橙:BAABLgAFFH8KAAIHAAQJ1xh0CgAzAQAHAAQJ1xh0CgAzAQAAAA==.',
['冰灵']='冰灵之刺:BAAALgAECgEJAQAAAA==.',
['冰阔']='冰阔落:BAAALgADCgEJAQAAAA==.',
['冷夜']='冷夜熙雨:BAAALgAECgEJAQAAAA==.',
['凌凌']='凌凌七:BAAALgAECgYJBwAAAA==.',
['凯崬']='凯崬:BAAALgAECgEJAQAAAA==.',
['凯撒']='凯撒君:BAAALgAFFAIJAgAAAA==.凯撒风:BAAALgAECgYJCgAAAA==.',
['凯特']='凯特莉娜:BAABLgAECn8gAAIIAAgJ3iCnBABxAgAIAAgJ3iCnBABxAgAAAA==.',
['出云']='出云八重垣:BAAALgAECggJBwAAAA==.',
['刀剑']='刀剑剑非道:BAAALgAECgYJBgAAAA==.',
['前面']='前面有光:BAAALgADCgYJDQAAAA==.',
['动物']='动物园主任:BAAALgAECgIJAgAAAA==.',
['北宫']='北宫毛妹:BAAALgAFFAEJAQAAAA==.北宫毛球:BAACLgAFFH8FAAIJAAQJRwO+EgDvAAAJAAQJRwO+EgDvAAAuAAQKfxYAAgkABgl1GBA8ALUBAAkABgl1GBA8ALUBAAAA.',
['北極']='北極星的夜:BAABLgAFFH8JAAIKAAQJ6SRsBACfAQAKAAQJ6SRsBACfAQAAAA==.',
['华莱']='华莱士:BAAALgAECgQJBgAAAA==.',
['博麗']='博麗霊夢:BAAALgAECgQJAwABLgAFFAcJFQALABEcAA==.',
['吊州']='吊州聖騎士:BAAALgAFFAQJBAAAAA==.',
['含影']='含影:BAAALgAECgEJAQAAAA==.',
['咕咕']='咕咕嘎嘎:BAAALgADCgEJAQAAAA==.',
['哈库']='哈库啦玛塔塔:BAAALgAECgYJBgAAAA==.',
['哈比']='哈比:BAAALgAECgcJDQAAAA==.',
['啊困']='啊困困了:BAAALgADCgYJBgAAAA==.',
['嘎牛']='嘎牛哦:BAAALgADCgEJAQAAAA==.',
['图拉']='图拉揚:BAAALgAECgEJAgAAAA==.',
['塞勒']='塞勒涅丨晨星:BAAALgAECgEJAgAAAA==.',
['壹兌']='壹兌羊:BAAALgAECgIJAgAAAA==.',
['壹只']='壹只小德:BAAALgAFFAEJAQAAAA==.',
['夙愿']='夙愿之牧:BAAALgADCgYJAwAAAA==.',
['夜空']='夜空下的牛:BAAALgAECgcJAwAAAA==.',
['夜雪']='夜雪丶初霁:BAAALgAECgYJDAAAAA==.',
['天煞']='天煞孤风:BAABLgAECn8UAAIMAAYJ9REKLwCLAQAMAAYJ9REKLwCLAQAAAA==.',
['套龙']='套龙的汉子:BAACLgAFFH8FAAINAAIJUB0/HQDIAAANAAIJUB0/HQDIAAAuAAQKfxgAAg0ABglXJHdAAHcCAA0ABglXJHdAAHcCAAAA.',
['妖风']='妖风潇潇:BAAALgADCgEJAQAAAA==.妖风瑟瑟:BAAALgAECgIJAgAAAA==.',
['妹没']='妹没蓝来拿蓝:BAAALgADCgUJBQAAAA==.',
['家缘']='家缘小祭:BAAALgAECgQJBAAAAA==.',
['小十']='小十一:BAAALgAECgcJAwAAAA==.',
['小小']='小小波:BAAALgAFFAQJBAAAAA==.',
['小法']='小法丝丶:BAAALgAECgUJBQAAAA==.',
['小花']='小花丶:BAAALgAECgQJBAAAAA==.',
['左狼']='左狼右狈:BAACLgAFFH8OAAIOAAQJ3CSdAAC5AQAOAAQJ3CSdAAC5AQAuAAQKfx4AAg4ABwmOJZcFAPYCAA4ABwmOJZcFAPYCAAAA.',
['布劳']='布劳缪克丝:BAABLgAECn8mAAILAAgJuhV8FgB4AQALAAgJuhV8FgB4AQABLgAFFAcJDQALAGUkAA==.',
['幻彩']='幻彩心德:BAAALgAFFAEJAQAAAA==.',
['幽默']='幽默小登:BAAALgAECgYJCwABLgAFFAQJCQAHANofAA==.',
['延续']='延续:BAAALgAECgYJCgAAAA==.',
['弘一']='弘一法師:BAAALgAECgcJDQAAAA==.',
['德了']='德了个小德:BAABLgAECn8VAAIPAAcJABqgCQA4AgAPAAcJABqgCQA4AgAAAA==.',
['忧落']='忧落丶:BAAALgAECgcJDgAAAA==.忧落的小德:BAAALgAECgYJBwAAAA==.',
['怒风']='怒风艾斯:BAAALgAECgYJDAAAAA==.',
['悄悄']='悄悄不说话:BAAALgAECgEJAQAAAA==.',
['我反']='我反对:BAAALgAECgYJBgAAAA==.',
['我是']='我是一条龙:BAAALgAECgkJCQAAAA==.',
['我欲']='我欲成仙:BAABLgAECn8VAAILAAcJ4xl+bwCqAQALAAcJ4xl+bwCqAQAAAA==.',
['打老']='打老师:BAAALgADCgUJBQAAAA==.',
['拉斯']='拉斯塔哈大王:BAAALgAECgYJBgAAAA==.',
['掂過']='掂過碌蔗:BAAALgAFFAMJAwAAAA==.',
['提里']='提里奥丶弗丁:BAAALgAECgEJAQAAAA==.',
['搓药']='搓药咕:BAABLgAECn8gAAIQAAgJ/RhdBAD5AQAQAAgJ/RhdBAD5AQAAAA==.',
['携酒']='携酒寻芳去:BAAALgAECgEJAgAAAA==.',
['放生']='放生:BAAALgADCgEJAQAAAA==.',
['无尘']='无尘寺:BAAALgAECgEJAQAAAA==.',
['无胆']='无胆僧:BAAALgADCgYJBgAAAA==.',
['无量']='无量感觉:BAAALgAECgYJBgAAAA==.',
['星宿']='星宿老仙:BAAALgAECgUJBgAAAA==.',
['是也']='是也非耶:BAAALgAFFAIJAgAAAA==.',
['是耶']='是耶非也:BAAALgAECgIJAgAAAA==.是耶非耶术:BAAALgAECgYJCQAAAA==.是耶非耶魔:BAAALgAECgcJBwAAAA==.',
['時廿']='時廿以後:BAACLgAFFH8HAAIJAAMJXx9CDgAhAQAJAAMJXx9CDgAhAQAuAAQKfxcAAwkABgnfGUY4AMYBAAkABgnfGUY4AMYBABEAAQnrCXJDADIAAAAA.',
['暮色']='暮色迷离:BAAALgAFFAIJAgAAAA==.',
['林猩']='林猩鸽:BAAALgAECgcJEQAAAA==.',
['林落']='林落葵:BAABLgAECn8gAAQOAAgJ1x2zBAANAgAOAAgJaxyzBAANAgASAAYJrRpZGQDPAQATAAEJNA3zZAAvAAAAAA==.',
['核桃']='核桃酥:BAAALgADCgYJAwAAAA==.',
['桑德']='桑德汉雷手:BAAALgAECgYJCQAAAA==.',
['樱子']='樱子:BAAALgAECggJDgAAAA==.',
['橙色']='橙色葡萄酱:BAAALgAFFAIJAwABLgAFFAcJBQANANIGAA==.',
['欧巴']='欧巴桑:BAAALgAECgQJBAAAAA==.',
['死神']='死神少女:BAAALgADCgEJAQAAAA==.',
['水煮']='水煮夜鳞鱼:BAAALgADCgEJAQAAAA==.',
['水粒']='水粒:BAAALgAECgQJAwAAAA==.',
['沉默']='沉默的爵银龙:BAAALgAECgQJBgAAAA==.',
['法尔']='法尔肯:BAABLgAECn8fAAQGAAgJMyDTCwDfAQAGAAcJMyDTCwDfAQAUAAMJKwqnPgC6AAAVAAEJHBi2CABSAAABLgAFFAUJDAAGAK0mAA==.',
['波士']='波士顿龙虾:BAAALgAECgEJAgAAAA==.',
['泼天']='泼天富贵:BAAALgAECgEJAQAAAA==.',
['浅若']='浅若夏沫:BAAALgAECgEJAgAAAA==.',
['消融']='消融的白雪:BAAALgAECgQJBAAAAA==.',
['湖光']='湖光丹:BAAALgAFFAEJAQAAAA==.',
['無心']='無心:BAABLgAFFH8FAAIGAAUJdwLmFgDkAAAGAAUJdwLmFgDkAAAAAA==.',
['牛啃']='牛啃菠萝:BAAALgAECgEJAQAAAA==.',
['狂暴']='狂暴亚马逊:BAAALgAECgEJAQAAAA==.',
['独倚']='独倚丨烟花笑:BAAALgAECgEJAQAAAA==.',
['璟瑜']='璟瑜:BAAALgAECgEJAQAAAA==.',
['瓦里']='瓦里安烏瑞恩:BAAALgADCgUJBQAAAA==.',
['百年']='百年孤獨:BAAALgAECgEJAQAAAA==.',
['皮皮']='皮皮王王:BAABLgAFFH8GAAICAAQJ8xEQBQBQAQACAAQJ8xEQBQBQAQAAAA==.',
['神秘']='神秘小登:BAACLgAFFH8JAAIHAAQJ2h+yAgCUAQAHAAQJ2h+yAgCUAQAuAAQKfx0AAgcACAmNIT4KAPECAAcACAmNIT4KAPECAAAA.',
['窝要']='窝要验牌:BAABLgAECn8hAAIOAAgJNiM6AQDGAgAOAAgJNiM6AQDGAgAAAA==.',
['简简']='简简单单的:BAABLgAFFH8JAAMSAAMJTBfIDQDvAAASAAMJNxTIDQDvAAAOAAEJlRwLCgBXAAAAAA==.',
['篆愁']='篆愁君:BAAALgAECgEJAQAAAA==.',
['紫炎']='紫炎幻舞:BAAALgAECgIJAwAAAA==.',
['红中']='红中老大:BAAALgAFFAEJAQAAAA==.',
['罹天']='罹天烬:BAAALgAECgYJCwAAAA==.',
['羞花']='羞花闭曰:BAAALgAECgUJBgAAAA==.',
['自在']='自在仙:BAAALgAECgEJAgAAAA==.',
['至尊']='至尊无敌痞子:BAAALgADCgUJCwAAAA==.',
['花舞']='花舞舞:BAABLgAECn8gAAMWAAgJKx8UAgAvAgAWAAcJvyEUAgAvAgADAAEJrw9fWwA2AAAAAA==.',
['苍崎']='苍崎青子:BAAALgAECgYJBgAAAA==.',
['苍白']='苍白之祝:BAAALgAECgUJBQAAAA==.',
['萝莉']='萝莉易推倒:BAAALgADCgEJAQAAAA==.',
['萨穆']='萨穆罗:BAAALgADCgIJAgAAAA==.萨穆罗火刃:BAAALgAECgEJAQAAAA==.',
['蒙奇']='蒙奇三:BAAALgADCgcJBwAAAA==.',
['蔑绝']='蔑绝:BAAALgAECgEJAQAAAA==.',
['薛定']='薛定谔的猫:BAAALgAECgYJEQAAAA==.',
['虾饺']='虾饺王:BAAALgAECgEJAQAAAA==.',
['血色']='血色暗影步:BAAALgADCgcJBwAAAA==.',
['诺亚']='诺亚之子:BAAALgAECgYJBgAAAA==.诺亚风语者:BAABLgAECn8dAAIXAAgJgBDuBQB3AQAXAAgJgBDuBQB3AQABLgAFFAYJFwAOANsRAA==.',
['豆豆']='豆豆的豆豆:BAABLgAFFH8IAAIHAAMJdg1hDADEAAAHAAMJdg1hDADEAAAAAA==.',
['贱剑']='贱剑:BAAALgAFFAIJAgAAAA==.',
['赫利']='赫利斯:BAAALgADCgUJBQAAAA==.',
['超燃']='超燃真红毛熊:BAAALgAFFAIJAwAAAA==.',
['超级']='超级吉利蛋:BAAALgAECgEJAQABLgAECgYJCgAFAAAAAA==.',
['迷人']='迷人的反派:BAACLgAFFH8RAAIYAAUJJBFiCgCHAQAYAAUJJBFiCgCHAQAuAAQKfyYAAhgACAmfIL4VANQCABgACAmfIL4VANQCAAAA.',
['迷雾']='迷雾天堂:BAAALgAFFAIJAgAAAA==.',
['逆天']='逆天邪神:BAAALgAECgEJAQAAAA==.',
['逆熵']='逆熵:BAAALgADCgEJAQAAAA==.',
['逐風']='逐風:BAAALgADCgEJAQAAAA==.',
['遛狗']='遛狗老登:BAAALgAECgUJBQAAAA==.',
['邻家']='邻家小妹:BAAALgAECgkJCQABLgAFFAUJCAAHAEQOAA==.',
['野生']='野生小泡芙:BAAALgAECgEJAQAAAA==.',
['长街']='长街:BAAALgAECgYJEAAAAA==.',
['闷闷']='闷闷牛:BAAALgAECgEJAQAAAA==.',
['阿克']='阿克罗尔:BAAALgAECgkJBwAAAA==.',
['阿尔']='阿尔托俐雅:BAAALgADCgMJAwAAAA==.',
['阿斯']='阿斯忒里亚:BAABLgAFFH8HAAMDAAQJ/hypBwAoAQADAAMJohupBwAoAQAZAAEJDyEfJABYAAAAAA==.',
['阿迩']='阿迩萨斯:BAAALgADCgQJBAAAAA==.',
['陈一']='陈一发:BAAALgAECgEJAQAAAA==.',
['随风']='随风葬魂:BAAALgAECgcJCgAAAA==.',
['雾岛']='雾岛葵乃香:BAAALgAECgYJDwAAAA==.',
['霉优']='霉优岚:BAAALgAECgQJBAAAAA==.',
['霓红']='霓红:BAABLgAECn8oAAMaAAgJAQixSQBRAQAaAAcJ0waxSQBRAQAIAAcJXRQxJQA8AQAAAA==.',
['霜乂']='霜乂狼:BAAALgAFFAEJAQAAAA==.',
['青麟']='青麟丶法斯:BAAALgADCgEJAgAAAA==.青麟丶麟:BAAALgAECgQJBwAAAA==.',
['鞑靼']='鞑靼:BAAALgAECggJEgAAAA==.',
['风吹']='风吹雪如棉:BAAALgAECgYJBwAAAA==.',
['高等']='高等大吉:BAAALgADCgcJCgAAAA==.',
['鹦鹉']='鹦鹉铃:BAAALgAECgEJAQAAAA==.',
['黎洛']='黎洛安安:BAAALgAECgIJAgAAAA==.',
['黑夜']='黑夜玫瑰:BAAALgAECgcJDgAAAA==.',
['齐刘']='齐刘海灬:BAAALgAECgUJBQAAAA==.',
['龍拳']='龍拳:BAAALgAECgIJAgAAAA==.',
['龙王']='龙王丸:BAAALgAECgQJCAAAAA==.',
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
