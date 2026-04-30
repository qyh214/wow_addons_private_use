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

local lookup = {'Evoker-Preservation','Hunter-Marksmanship','Hunter-BeastMastery','Warrior-Fury','Rogue-Assassination','Mage-Frost','Druid-Restoration','Paladin-Retribution','Evoker-Augmentation','Evoker-Devastation','Unknown-Unknown','DemonHunter-Devourer','Monk-Mistweaver','Monk-Windwalker','DeathKnight-Unholy','Rogue-Subtlety','Priest-Holy','Monk-Brewmaster','Warrior-Protection','Shaman-Restoration',}
local provider = {region='CN',realm='暗影迷宫',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Artemisdao:BAAALgAECgMJAwAAAA==.',
As='Asasins:BAAALgAECgMJAwAAAA==.',
Av='Avenger:BAAALgAECgQJBgAAAA==.',
Bi='Bigd:BAAALgAECgEJAgAAAA==.',
Bu='Bucket:BAAALgAECgIJAgAAAA==.',
Ca='Callmemt:BAAALgADCgYJCAAAAA==.',
Co='Collapser:BAAALgADCgEJAQAAAA==.',
Cw='Cwj:BAAALgAFFAIJAwAAAA==.',
Cy='Cyka:BAAALgAECgcJDAAAAA==.',
De='Demonslee:BAAALgAECgQJBQAAAA==.',
Di='Diickbutt:BAAALgAECgEJAgAAAA==.',
Fe='Felknight:BAAALgAECgEJAgAAAA==.',
Fr='Frémir:BAAALgAFFAEJAQAAAA==.',
Gi='Gio:BAAALgAECgcJBgAAAA==.',
Ic='Iceweaver:BAAALgAECgEJAgAAAA==.',
Le='Leetomas:BAAALgAECgUJBQAAAA==.',
No='Noanswerfs:BAAALgAECgYJBgAAAA==.',
Ro='Ropz:BAAALgAFFAMJBAAAAA==.',
Se='Seed:BAAALgAECgQJCAAAAA==.',
Sh='Shirley:BAAALgAECgEJAQAAAA==.',
St='Steins:BAAALgAECgEJAQAAAA==.',
Ty='Tyro:BAACLgAFFH8cAAIBAAcJDiMuAAC0AgABAAcJDiMuAAC0AgAuAAQKfxwAAgEACQkuIywBAIADAAEACQkuIywBAIADAAAA.',
Va='Valkyrie:BAAALgAFFAQJBAAAAA==.',
Wx='Wxianren:BAAALgAECgYJEgAAAA==.',
Ya='Yaygaga:BAAALgAECgUJCwAAAA==.',
Zh='Zhhc:BAAALgAECgMJAwAAAA==.',
['一刀']='一刀了:BAAALgADCgEJAQAAAA==.',
['一只']='一只小小熊:BAAALgAECgUJBQAAAA==.',
['一意']='一意菇行:BAAALgAECgEJAQAAAA==.',
['一稚']='一稚:BAABLgAFFH8FAAMCAAMJexD9JgBOAAACAAEJpw/9JgBOAAADAAIJ5RAAAAAAAAAAAA==.',
['三丫']='三丫:BAAALgAECgUJBwAAAA==.',
['东城']='东城故人:BAAALgADCgEJAQAAAA==.',
['东方']='东方嗯啊嘤噢:BAABLgAECn8UAAIEAAYJxxXDQAChAQAEAAYJxxXDQAChAQAAAA==.',
['丫丫']='丫丫花:BAAALgAECgEJAQAAAA==.',
['乂粒']='乂粒蛋:BAAALgAECgQJBAAAAA==.',
['云朮']='云朮士:BAAALgAFFAIJBAAAAA==.',
['人间']='人间武媚娘:BAAALgAECgUJBAAAAA==.',
['仁慈']='仁慈:BAAALgAECgUJBwAAAA==.',
['伊斯']='伊斯坦卜的猫:BAAALgADCgIJAgAAAA==.',
['休闲']='休闲混子:BAAALgAECgUJBQAAAA==.',
['你碰']='你碰就躺下:BAAALgADCgYJBgAAAA==.',
['侽冋']='侽冋:BAAALgAECgIJAgAAAA==.',
['俺寻']='俺寻思:BAAALgADCgMJAwAAAA==.',
['先天']='先天领周天:BAAALgAECgYJBgAAAA==.',
['光铸']='光铸骑:BAAALgAECgYJDQABLgAFFAMJBwAFAKkkAA==.',
['六百']='六百号:BAAALgAECgUJBQAAAA==.',
['凌风']='凌风而舞:BAAALgADCgMJAwAAAA==.',
['刘正']='刘正正:BAABLgAFFH8FAAIGAAMJlQoILgD+AAAGAAMJlQoILgD+AAAAAA==.',
['剑来']='剑来:BAAALgADCgEJAQAAAA==.',
['千霖']='千霖:BAAALgAECgQJBAAAAA==.',
['半夜']='半夜洗屁屁:BAAALgAECgEJAQAAAA==.',
['卡牛']='卡牛寺:BAAALgADCgIJAgAAAA==.',
['卡鲁']='卡鲁克特:BAABLgAFFH8FAAIHAAMJtRpWDgABAQAHAAMJtRpWDgABAQAAAA==.',
['双湾']='双湾居士:BAAALgADCgEJAQAAAA==.',
['古兒']='古兒丹:BAAALgADCgIJAgAAAA==.',
['古杖']='古杖技奇人:BAAALgAECgMJAwAAAA==.',
['古都']='古都宝宝:BAAALgAFFAMJBAAAAA==.',
['吃布']='吃布丁的虎:BAAALgAECgYJBgAAAA==.',
['吉你']='吉你一下:BAAALgAECgIJAgAAAA==.',
['同福']='同福阿宝二世:BAAALgAFFAEJAQAAAA==.',
['名侦']='名侦探兔美:BAAALgAECgMJAwAAAA==.',
['君唇']='君唇为谁红:BAAALgAECgYJCAAAAA==.',
['呉朙']='呉朙丨十七:BAAALgAFFAUJBAAAAA==.',
['和联']='和联胜:BAAALgADCggJCAAAAA==.',
['咩趸']='咩趸:BAAALgADCgEJAQAAAA==.',
['哀伤']='哀伤之猎:BAAALgAECgUJCQAAAA==.',
['哈哈']='哈哈我笑了啊:BAAALgAECgUJBwAAAA==.',
['哼哼']='哼哼大熊:BAAALgADCgEJAQAAAA==.',
['嘟嘟']='嘟嘟奶茶:BAAALgADCgEJAQAAAA==.',
['团长']='团长载嫖:BAAALgAECgYJDwAAAA==.',
['埃洛']='埃洛伊丝:BAAALgADCgEJAQAAAA==.',
['埃蒙']='埃蒙:BAABLgAECn8gAAIIAAcJwyEuHwCwAgAIAAcJwyEuHwCwAgAAAA==.',
['塔露']='塔露拉:BAABLgAFFH8KAAQBAAMJmg/MDgDpAAABAAMJmg/MDgDpAAAJAAIJrwktEgBOAAAKAAEJjgAGDABDAAABLgAFFAYJAwALAAAAAA==.',
['塞伯']='塞伯鲁斯:BAAALgADCgEJAQAAAA==.',
['塞莱']='塞莱斯汀:BAABLgAFFH8KAAIEAAQJTxYLCgBWAQAEAAQJTxYLCgBWAQAAAA==.',
['塞蕾']='塞蕾娅:BAAALgADCgMJAwAAAA==.',
['夜神']='夜神泷月:BAAALgADCgcJBwAAAA==.',
['大主']='大主教伊瑞尔:BAAALgAECgEJAQAAAA==.',
['大地']='大地的密酿:BAAALgAFFAIJAgAAAA==.',
['大概']='大概是离黎:BAAALgAECgYJCAAAAA==.',
['大红']='大红袍:BAAALgAECgMJAwAAAA==.',
['大老']='大老鼠人:BAABLgAFFH8HAAMDAAMJDhYRBwAPAQADAAMJjBQRBwAPAQACAAEJ9g5jJwBNAAAAAA==.',
['天綪']='天綪色等烟雨:BAAALgAECgQJBAAAAA==.',
['天蝎']='天蝎座守护:BAAALgAECgkJCQAAAA==.',
['奇袭']='奇袭:BAAALgADCgEJAQAAAA==.',
['奶白']='奶白旳雪子:BAACLgAFFH8OAAIMAAQJLBGnCQAdAQAMAAQJLBGnCQAdAQAuAAQKfyAAAgwACAkZHIwqAFYCAAwACAkZHIwqAFYCAAAA.',
['她已']='她已经嫁人了:BAAALgAECgEJAgAAAA==.',
['如霜']='如霜:BAAALgADCgEJAQAAAA==.',
['妃丨']='妃丨英理:BAAALgAECgYJCAAAAA==.',
['妮妮']='妮妮:BAAALgAECgYJCAAAAA==.',
['妮莉']='妮莉艾露:BAAALgAECgYJCQAAAA==.',
['宇宙']='宇宙无敌威猛:BAAALgAECgYJBgAAAA==.',
['寂丶']='寂丶静:BAAALgAECgEJAQAAAA==.',
['寻求']='寻求正义丶丶:BAAALgAECgMJBAAAAA==.',
['小小']='小小泪光:BAAALgADCgUJBQAAAA==.小小淑娟:BAAALgAECgQJBQAAAA==.',
['小弥']='小弥:BAAALgAECgUJBgAAAA==.',
['小沙']='小沙子:BAAALgAFFAQJBAAAAA==.',
['小泪']='小泪光:BAAALgAECgcJCAAAAA==.',
['小浣']='小浣熊扫刃舞:BAAALgAECgYJCgAAAA==.',
['巫王']='巫王的罪歌丨:BAAALgAECgcJEQAAAA==.',
['希尔']='希尔瓦娜心:BAAALgAECgIJAgAAAA==.',
['带带']='带带大天启:BAAALgAFFAMJAwAAAA==.',
['年糕']='年糕麻花:BAAALgAECgEJAQAAAA==.',
['幼稚']='幼稚园的淑娟:BAAALgAECgMJAwAAAA==.',
['弥弥']='弥弥:BAAALgADCgcJDQAAAA==.',
['德不']='德不劳累:BAAALgADCgMJAwAAAA==.',
['德尔']='德尔海伦娜:BAAALgAECgcJBgABLgAFFAUJAQALAAAAAA==.',
['快使']='快使用军体拳:BAABLgAECn8UAAMNAAYJiBcuLABXAQANAAUJXRsuLABXAQAOAAIJxQpKbwBUAAAAAA==.',
['念原']='念原额:BAAALgAFFAIJAwAAAA==.',
['性感']='性感老耗子:BAAALgAECgYJDQAAAA==.',
['愚者']='愚者先生:BAABLgAECn8UAAIPAAYJShiJcQCkAQAPAAYJShiJcQCkAQAAAA==.',
['慢慢']='慢慢亦漫漫:BAAALgAECgEJAQAAAA==.',
['我断']='我断紫菱:BAAALgAECgcJCQAAAA==.',
['我直']='我直接一刀:BAACLgAFFH8HAAMFAAMJqSTeAQBAAQAFAAMJwyDeAQBAAQAQAAIJ4SJYBwDFAAAuAAQKfxcAAxAACAlEJKgNAMICABAABwloJKgNAMICAAUAAgkVHd8YAGgAAAAA.我直接一削凿:BAAALgAECgUJBQABLgAFFAMJBwAFAKkkAA==.',
['把把']='把把空车:BAAALgAECgYJCQAAAA==.',
['抠脚']='抠脚大汗:BAAALgAFFAIJAgAAAA==.',
['抽空']='抽空打点输出:BAABLgAECn8UAAIRAAYJJx1OJQC/AQARAAYJJx1OJQC/AQAAAA==.',
['撒撒']='撒撒小红豆:BAAALgAECgQJBgAAAA==.',
['放开']='放开那个大姐:BAAALgAECgYJCgAAAA==.',
['无相']='无相樽:BAAALgADCgEJAgAAAA==.',
['无菇']='无菇的人:BAAALgAECgQJBAAAAA==.',
['旺旺']='旺旺掀被:BAAALgAECgMJAwAAAA==.',
['晚妹']='晚妹妹:BAAALgAECgEJAQAAAA==.',
['普罗']='普罗德莫尔:BAAALgAECgYJCgABLgAFFAMJBwAJAPoUAA==.',
['智法']='智法三:BAAALgAECgYJBAAAAA==.智法二:BAAALgAFFAQJBAAAAA==.智法四:BAAALgAECggJAgAAAA==.',
['杭州']='杭州湾宋仲基:BAAALgAFFAEJAQAAAA==.',
['林巧']='林巧希:BAAALgADCgEJAQAAAA==.',
['柚子']='柚子与樱桃:BAAALgAECgYJDAAAAA==.柚子与橙子:BAAALgADCgQJBAAAAA==.',
['柠檬']='柠檬味嘎嘣脆:BAAALgADCgUJBQAAAA==.柠檬烧酒:BAAALgAECgYJCwAAAA==.',
['梨涡']='梨涡浅笑:BAAALgAECgYJDAAAAA==.',
['森塞']='森塞的玩具箱:BAAALgAECgEJAQAAAA==.',
['楚丶']='楚丶枫:BAAALgAECgYJAQAAAA==.',
['槲叶']='槲叶:BAACLgAFFH8HAAMJAAMJ+hTNEQDyAAAJAAMJ+hTNEQDyAAABAAEJiw7LFwBDAAAuAAQKfxgABAEABwnKF64TAAkCAAEABwnKF64TAAkCAAkABgmDElQQAOkAAAoAAQk4I401AGgAAAAA.',
['武偃']='武偃文修:BAAALgAECgYJBgAAAA==.',
['死亡']='死亡大牛角:BAAALgADCgQJBAAAAA==.',
['死神']='死神利箭:BAABLgAECn8XAAIDAAYJChk2PAC+AQADAAYJChk2PAC+AQAAAA==.',
['河南']='河南彭于晏:BAAALgAECgMJAwAAAA==.',
['泡儿']='泡儿鱼:BAAALgAECgYJCgAAAA==.',
['活蹦']='活蹦乱跳:BAAALgAECgUJCQAAAA==.',
['流油']='流油的牛油果:BAAALgAECgQJBAAAAA==.',
['淑娟']='淑娟吖:BAAALgAECgUJBQAAAA==.淑娟娟丫:BAAALgAECgYJCwAAAA==.',
['深爱']='深爱如长风丶:BAAALgAECgIJAgAAAA==.',
['温七']='温七:BAAALgAECgYJBgAAAA==.',
['滚滚']='滚滚丶:BAABLgAFFH8GAAISAAIJihDhCwCWAAASAAIJihDhCwCWAAABLgAFFAMJBwADAA4WAA==.',
['灵光']='灵光无限:BAAALgAECgkJCQAAAA==.',
['炁体']='炁体丨源流:BAAALgAECgMJAwAAAA==.',
['烈焰']='烈焰燃心:BAAALgAECgUJAwAAAA==.',
['熱闹']='熱闹:BAAALgAECgIJAgAAAA==.',
['牛牪']='牛牪犇:BAAALgAECgQJAQAAAA==.',
['独灬']='独灬半吨:BAAALgAECgUJCQAAAA==.',
['珍燕']='珍燕:BAAALgAECgYJCgAAAA==.',
['甘露']='甘露寺蜜璃:BAAALgAECgEJAQAAAA==.',
['疯癫']='疯癫和尚:BAAALgAECgIJAgAAAA==.',
['痞佬']='痞佬板:BAAALgAECgQJBQAAAA==.',
['白云']='白云谷李娇娇:BAAALgADCgMJAwAAAA==.',
['白日']='白日梦夜里吊:BAAALgAECgIJAgAAAA==.',
['白玫']='白玫瑰夜里香:BAAALgAECgEJAQAAAA==.',
['白色']='白色气球漂移:BAAALgAECgMJBQAAAA==.',
['白衣']='白衣祸事:BAAALgAECgYJBgAAAA==.',
['百年']='百年好合:BAAALgAECgYJCAAAAA==.',
['皮佬']='皮佬板:BAAALgADCgcJBwAAAA==.',
['皮老']='皮老圣:BAAALgAECgMJAwAAAA==.',
['看看']='看看侃栞栞刊:BAABLgAFFH8JAAIGAAIJUCRSMgDaAAAGAAIJUCRSMgDaAAAAAA==.',
['知易']='知易行:BAAALgAECgcJCAAAAA==.',
['短咦']='短咦巴兔:BAAALgAECgcJEgAAAA==.',
['短衣']='短衣巴褚:BAAALgADCgUJBQAAAA==.',
['神圣']='神圣的天使:BAAALgAECgMJAwAAAA==.',
['神秘']='神秘噬灭:BAAALgAFFAIJBAAAAA==.',
['离黎']='离黎:BAAALgAECgUJBQAAAA==.',
['粉红']='粉红色柜头:BAAALgAECgEJAQAAAA==.',
['红莲']='红莲三三:BAAALgAECgEJAQAAAA==.',
['细戏']='细戏:BAAALgADCgEJAQAAAA==.',
['给我']='给我圣疗:BAAALgAECgIJAgAAAA==.',
['绵羊']='绵羊萨守:BAAALgAECgEJAwAAAA==.',
['老六']='老六:BAABLgAECn8cAAITAAYJqA5rIQAzAQATAAYJqA5rIQAzAQABLgAECgcJBwALAAAAAA==.',
['老兵']='老兵安帕赫:BAAALgADCgEJAQAAAA==.',
['聖光']='聖光大嶺主:BAAALgAECgUJBwAAAA==.',
['胖弥']='胖弥:BAAALgAECgMJAwAAAA==.',
['脚滑']='脚滑的骑士:BAAALgADCgYJBgAAAA==.',
['脚震']='脚震震:BAAALgAECgYJDAAAAA==.',
['自然']='自然之糖:BAAALgAECgQJBAAAAA==.',
['舒适']='舒适:BAAALgAECgEJAQAAAA==.',
['艾克']='艾克塞琳:BAAALgAECgcJDAAAAA==.',
['艾雅']='艾雅玛亚:BAAALgADCgEJAQAAAA==.',
['芙柠']='芙柠娜足下犬:BAAALgAFFAIJAgAAAA==.',
['花雨']='花雨落:BAAALgAECgYJCQAAAA==.',
['苏沐']='苏沐橙丶:BAAALgADCgEJAQAAAA==.',
['茅茅']='茅茅虫:BAABLgAECn8XAAIGAAcJfhkzYAAbAgAGAAcJfhkzYAAbAgAAAA==.',
['莲花']='莲花小娘子:BAAALgAECgEJAQAAAA==.',
['菜狗']='菜狗之怒:BAAALgAECgYJDwAAAA==.',
['萌新']='萌新老奶狗丶:BAAALgAECgEJAwAAAA==.',
['西布']='西布克:BAAALgAECgMJAwAAAA==.',
['西门']='西门子:BAAALgAECgUJAQAAAA==.',
['贝七']='贝七:BAAALgAECgIJAwAAAA==.',
['走鸡']='走鸡丶:BAAALgAECgMJAwAAAA==.',
['车离']='车离卿:BAAALgAFFAIJAgAAAA==.',
['这是']='这是一个恶人:BAACLgAFFH8GAAIGAAIJahQLOgC2AAAGAAIJahQLOgC2AAAuAAQKfxcAAgYACAmkH/gmANcCAAYACAmkH/gmANcCAAAA.',
['这瓜']='这瓜多钱一斤:BAAALgAECgcJEAAAAA==.',
['追风']='追风筝人:BAAALgAECgEJAQAAAA==.',
['野原']='野原一心:BAAALgAECgYJBgAAAA==.',
['钢钢']='钢钢:BAAALgAECgUJBQAAAA==.',
['闪耀']='闪耀盔甲:BAAALgAECgIJAgAAAA==.',
['闪闪']='闪闪丶:BAAALgAECgIJAgAAAA==.',
['防风']='防风备备:BAAALgAECgIJAgAAAA==.',
['阿修']='阿修:BAAALgADCgQJBAAAAA==.阿修罗霸凰拳:BAAALgAECgYJBgAAAA==.',
['阿尔']='阿尔薩斯王子:BAABLgAECn8UAAIIAAgJ5BpMNgBJAgAIAAgJ5BpMNgBJAgAAAA==.',
['阿牧']='阿牧灬:BAAALgAFFAIJAgAAAA==.',
['阿莱']='阿莱莎:BAAALgAECgMJBAAAAA==.',
['雪白']='雪白的柰子:BAAALgAECgMJBQAAAA==.',
['雷加']='雷加大地之怒:BAABLgAFFH8GAAIUAAMJcgrwEgDKAAAUAAMJcgrwEgDKAAAAAA==.',
['霸王']='霸王龍:BAAALgAECgQJBQAAAA==.',
['霹雳']='霹雳小飞侠:BAABLgAFFH8GAAMJAAQJ9gVpCgDTAAAJAAMJrgVpCgDTAAABAAIJWxvQEQChAAAAAA==.',
['青灯']='青灯伴佳人:BAAALgAECgIJAgAAAA==.',
['静之']='静之杺烔:BAAALgADCgQJBAAAAA==.',
['飞行']='飞行专家:BAAALgAECgUJCAAAAA==.',
['鬼灬']='鬼灬鬼:BAAALgAECgQJBAAAAA==.',
['魃魈']='魃魈魑魅魍魉:BAAALgAECgcJDAAAAA==.',
['魔鏡']='魔鏡號:BAAALgAECgEJAQAAAA==.',
['黑指']='黑指甲油:BAAALgADCgEJAQAAAA==.',
['黑棒']='黑棒:BAAALgAECgEJAQAAAA==.',
['黑渊']='黑渊白花:BAAALgAECgYJBwAAAA==.',
['黑狗']='黑狗萨满:BAAALgAECgYJBgAAAA==.',
['鼑鬡']='鼑鬡:BAAALgADCgEJAQAAAA==.',
['龙姬']='龙姬妮娜:BAAALgAECgYJDAAAAA==.',
['龙悄']='龙悄悄:BAAALgAECgMJAwAAAA==.',
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
