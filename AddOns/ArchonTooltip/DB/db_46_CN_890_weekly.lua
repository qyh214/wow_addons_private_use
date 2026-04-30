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

local lookup = {'Mage-Frost','DemonHunter-Devourer','Evoker-Preservation','DemonHunter-Havoc','Warlock-Demonology','Warlock-Destruction','DeathKnight-Unholy','Monk-Brewmaster','Evoker-Augmentation','Priest-Shadow','Priest-Discipline','Priest-Holy','Shaman-Restoration','Paladin-Retribution','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Elemental','Warlock-Affliction','Druid-Restoration','Druid-Balance','Rogue-Subtlety','Rogue-Outlaw',}
local provider = {region='CN',realm='麦姆',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Amvs:BAAALgADCgEJAQAAAA==.',
Ap='Apollow:BAAALgAECgYJCwAAAA==.',
Au='Au:BAAALgAFFAIJAgAAAA==.',
Cu='Cure:BAAALgADCgQJBAAAAA==.',
Dk='Dkjjone:BAAALgAECgIJAgAAAA==.',
Dr='Drlu:BAABLgAFFH8HAAIBAAQJxQpyKgALAQABAAQJxQpyKgALAQAAAA==.',
El='Elowyn:BAAALgAECgYJBgAAAA==.',
Gg='Ggcj:BAAALgAECgcJCgAAAA==.',
Ir='Iris:BAAALgAECgYJCQAAAA==.',
Ko='Kogvs:BAAALgAECgIJAwAAAA==.',
Li='Littie:BAABLgAFFH8LAAICAAQJpBzQBABpAQACAAQJpBzQBABpAQAAAA==.',
Lu='Luckfish:BAAALgAECgUJCgAAAA==.',
Me='Meowdracthyr:BAAALgAFFAEJAQABLgAFFAMJCgADABgkAA==.',
Mo='Moment:BAAALgADCgcJBwAAAA==.',
Ne='Nexxarion:BAAALgADCgYJBwAAAA==.',
Ov='Ovleqiq:BAABLgAECn8VAAMCAAkJPR1CGADEAgACAAkJBh1CGADEAgAEAAYJMhbPKAB8AQAAAA==.',
Qy='Qywarlockg:BAABLgAFFH8IAAMFAAQJuBSeBwBWAQAFAAQJuBSeBwBWAQAGAAEJ2waxFwBPAAABLgAFFAUJCwAFAIAeAA==.',
Re='Regil:BAABLgAECn8ZAAIHAAgJoBxAMgBuAgAHAAgJoBxAMgBuAgAAAA==.',
Sh='Showmelovege:BAAALgAECgYJCQAAAA==.',
Si='Silverdew:BAAALgAECgYJCAAAAA==.',
Wh='Whitsunday:BAAALgAECgkJDAAAAA==.',
['一二']='一二哟:BAAALgAFFAEJAQAAAA==.',
['一生']='一生三生万物:BAAALgAECgMJAwAAAA==.',
['东北']='东北狐:BAAALgADCgQJBAAAAA==.',
['丿丶']='丿丶蓝颜祸水:BAAALgAECgEJAQAAAA==.',
['乘风']='乘风破浪姐姐:BAAALgAECgcJEwAAAA==.',
['二里']='二里半:BAAALgAECgEJAQAAAA==.',
['云来']='云来:BAAALgAECgEJAQAAAA==.',
['京华']='京华:BAAALgAECgMJAwAAAA==.',
['亮晶']='亮晶晶:BAAALgAFFAEJAwAAAA==.',
['人心']='人心薄凉丶伤:BAAALgAECgcJBgAAAA==.',
['传承']='传承套我来了:BAAALgAFFAIJAgABLgAFFAMJBgAIAO4UAA==.',
['佧仒']='佧仒:BAAALgAECgIJAgAAAA==.',
['先打']='先打我小弟:BAAALgAECgEJAQAAAA==.',
['先生']='先生爱笑:BAAALgAECgcJBwAAAA==.',
['兵哥']='兵哥哥:BAAALgAECgYJCQAAAA==.',
['冬天']='冬天的暴风雪:BAAALgADCgEJAQAAAA==.',
['冰火']='冰火风味:BAAALgAECgIJAgAAAA==.',
['初见']='初见小德:BAAALgADCgEJAQAAAA==.初见小萨:BAAALgADCgMJAwAAAA==.',
['别惹']='别惹我胖虎:BAACLgAFFH8GAAIIAAMJ7hRWEgDnAAAIAAMJ7hRWEgDnAAAuAAQKfxQAAggACAn9G+wZADQCAAgACAn9G+wZADQCAAAA.',
['刺刀']='刺刀手枪:BAAALgAECgQJBAAAAA==.',
['北野']='北野:BAAALgAFFAIJAwAAAA==.',
['卑丷']='卑丷鄙:BAAALgAECgMJBAAAAA==.',
['叶落']='叶落落丶:BAAALgAECgQJBQAAAA==.',
['名人']='名人丶小四:BAAALgAECgUJBQAAAA==.',
['吟风']='吟风尿八丈:BAAALgAECgMJAwAAAA==.',
['吾名']='吾名喵喵之翼:BAAALgAFFAIJAgABLgAFFAMJCgADABgkAA==.',
['咕乃']='咕乃乃:BAAALgAFFAIJAgAAAA==.',
['咸恩']='咸恩静:BAAALgAECgYJEAAAAA==.',
['喵萨']='喵萨里奥:BAACLgAFFH8KAAIDAAMJGCQtCwA3AQADAAMJGCQtCwA3AQAuAAQKfxcAAwMACAkIHl0IALUCAAMACAkIHl0IALUCAAkAAwk3FjJJALEAAAAA.',
['夜盈']='夜盈川:BAACLgAFFH8NAAMKAAUJ9RmUAwCwAQAKAAUJ9RmUAwCwAQALAAMJ4RVoDQD1AAAuAAQKfyQABAsACAkMIOoHAMECAAsACAnnH+oHAMECAAoABQnLIY4bAAECAAwABwmRDrwsAJMBAAAA.',
['大胃']='大胃袋良子:BAAALgADCgIJAgAAAA==.',
['小孩']='小孩孩:BAACLgAFFH8GAAMFAAMJ6Q3rIAClAAAFAAIJDRHrIAClAAAGAAEJoAcOGABOAAAuAAQKfxsAAwYACAkRH/8JAB8CAAUABwm3GB86ACMCAAYABgnuHf8JAB8CAAAA.',
['小月']='小月野兔:BAAALgAECgEJAgAAAA==.',
['小米']='小米瓶子:BAABLgAFFH8FAAINAAMJnQtAGQCWAAANAAMJnQtAGQCWAAAAAA==.',
['小美']='小美履风行者:BAAALgAECgcJCwAAAA==.',
['小阿']='小阿狸:BAABLgAFFH8GAAINAAQJFBn5BgBVAQANAAQJFBn5BgBVAQAAAA==.',
['小雪']='小雪茄:BAAALgAECgUJDAAAAA==.',
['少时']='少时月黑:BAAALgAECgIJAgAAAA==.',
['就差']='就差一丢丢儿:BAAALgAFFAQJBAAAAA==.',
['屁带']='屁带汁:BAAALgADCgcJBwAAAA==.',
['巡回']='巡回梦想:BAAALgADCgUJBQAAAA==.',
['幻丶']='幻丶城:BAAALgAECgYJBgAAAA==.',
['开心']='开心马蝼:BAABLgAFFH8FAAIOAAUJsBSBBACpAQAOAAUJsBSBBACpAQAAAA==.',
['弃徒']='弃徒布衣:BAAALgAECgQJBgAAAA==.',
['影月']='影月谷女德:BAAALgAECgQJBAAAAA==.',
['德乙']='德乙:BAAALgAECgEJAQAAAA==.',
['德鲁']='德鲁大仙:BAAALgADCgEJAQABLgAECgMJAwAPAAAAAA==.',
['恩佐']='恩佐斯的使者:BAAALgAECgIJAgAAAA==.',
['战士']='战士:BAAALgAFFAEJAQAAAA==.',
['所愛']='所愛隔山海:BAAALgADCgQJBAAAAA==.',
['折戟']='折戟晨沙:BAAALgADCgcJBQAAAA==.',
['拉普']='拉普兰德:BAABLgAFFH8FAAIEAAMJ0Rf0BAAUAQAEAAMJ0Rf0BAAUAQAAAA==.',
['斯维']='斯维尔德诺夫:BAAALgADCgIJAgAAAA==.',
['时间']='时间门外:BAAALgAECgEJAgAAAA==.',
['明凯']='明凯:BAAALgAECgUJCAAAAA==.',
['明喆']='明喆:BAAALgAECgYJCQAAAA==.',
['星期']='星期一:BAAALgAECgYJCQABLgAFFAUJBAAPAAAAAA==.星期三龙:BAAALgAECgYJBgAAAA==.',
['暴走']='暴走:BAAALgADCgcJDgAAAA==.',
['最长']='最长就这么长:BAAALgADCgEJAQAAAA==.',
['月不']='月不落:BAAALgADCgEJAQAAAA==.',
['朱加']='朱加什维利:BAAALgADCgQJBQAAAA==.',
['枭獍']='枭獍:BAAALgAECgQJBQAAAA==.',
['桂琴']='桂琴吖:BAACLgAFFH8GAAMMAAMJ0xDaDACXAAAMAAIJrRDaDACXAAALAAEJHxHhFwBSAAAuAAQKfx4AAwwABwlXJF4IAMUCAAwABwlXJF4IAMUCAAoAAgkXFDFRAIcAAAAA.',
['森屿']='森屿暮歌:BAAALgAFFAIJBAAAAA==.',
['椋鸟']='椋鸟丿:BAAALgAECgEJAQAAAA==.',
['橙毛']='橙毛黑熊:BAABLgAFFH8FAAMQAAQJPg8aEAAwAQAQAAQJPg8aEAAwAQARAAEJiwVgKQBPAAAAAA==.',
['沐希']='沐希梓:BAAALgAECgUJBgAAAA==.',
['沐曦']='沐曦梓:BAAALgAFFAIJBAAAAA==.',
['洛小']='洛小冰:BAAALgAECgQJBgAAAA==.洛小萌:BAAALgAECgQJDQAAAA==.',
['流波']='流波将月去:BAAALgAFFAQJAQAAAA==.',
['渔家']='渔家傲:BAAALgAECgQJBAAAAA==.',
['烟斗']='烟斗客官:BAAALgAECgQJBAAAAA==.',
['焚混']='焚混灬铅华:BAACLgAFFH8GAAMSAAIJJRuvEgDFAAASAAIJJRuvEgDFAAANAAIJYAN7EQB1AAAuAAQKfxsAAxIACAkKIgMQAKkCABIABwnDIQMQAKkCAA0AAwnoEBZ4ALEAAAAA.',
['熹楽']='熹楽:BAACLgAFFH8IAAIEAAQJNgSuBgDbAAAEAAQJNgSuBgDbAAAuAAQKfx0AAwQACAmZEEQZAPsBAAQACAmZEEQZAPsBAAIABAmzBrmwAKkAAAAA.',
['爆爆']='爆爆成年版:BAAALgAFFAIJAwAAAA==.',
['爱情']='爱情原本样子:BAAALgADCgYJBgAAAA==.',
['爷是']='爷是戦士大王:BAAALgAECgIJAgAAAA==.',
['爸咋']='爸咋黑:BAAALgAECgMJAwAAAA==.',
['独见']='独见你是青山:BAAALgAFFAIJAgAAAA==.',
['猜猜']='猜猜我是谁:BAAALgAECgQJBwAAAA==.',
['珠光']='珠光:BAAALgAFFAEJAQAAAA==.',
['瑄瑄']='瑄瑄:BAAALgAECgYJDQAAAA==.瑄瑄呀:BAAALgAECgYJDgAAAA==.',
['瓶子']='瓶子:BAAALgADCgEJAgAAAA==.',
['用飘']='用飘柔洗脚:BAAALgAECgQJAwAAAA==.',
['疯癫']='疯癫大仙:BAAALgAECgMJAwAAAA==.',
['盛盛']='盛盛:BAAALgAFFAEJAQAAAA==.',
['看我']='看我干嘛看剑:BAAALgAFFAIJAgAAAA==.',
['碎魂']='碎魂小宝宝:BAAALgAECgQJBQAAAA==.碎魂糜糜:BAAALgAECgEJAgAAAA==.碎魂谧谧:BAAALgAECgMJAwAAAA==.碎魂靡靡:BAAALgAECgIJAwAAAA==.',
['神父']='神父忽悠着你:BAAALgAFFAQJBAAAAA==.',
['秋风']='秋风知我心:BAAALgADCgcJBwAAAA==.',
['空刃']='空刃:BAACLgAFFH8MAAIHAAQJ4B4bBwCYAQAHAAQJ4B4bBwCYAQAuAAQKfxQAAgcACAkHHfFDACkCAAcACAkHHfFDACkCAAAA.',
['笑天']='笑天下:BAACLgAFFH8FAAIFAAMJUQNVJQCRAAAFAAMJUQNVJQCRAAAuAAQKfxgABAUACAnwFHNvAIEBAAUABgnMEnNvAIEBAAYAAwlNGsQyAO0AABMAAQkAABEiAGoAAAAA.',
['简单']='简单玩猎:BAABLgAECn8iAAIRAAgJxR8WDADhAgARAAgJxR8WDADhAgAAAA==.简单玩玩:BAAALgAECgIJAwAAAA==.简单玩骑:BAAALgAECggJEwAAAA==.',
['粉嫩']='粉嫩的鲲鹏:BAAALgAECgEJAQAAAA==.',
['聚苯']='聚苯乙烯:BAAALgADCgEJAQAAAA==.',
['肉碎']='肉碎茄子:BAAALgAFFAIJAgAAAA==.',
['艾丽']='艾丽芬:BAAALgAECgEJAQAAAA==.',
['花落']='花落伊人归:BAAALgAFFAIJBAAAAA==.',
['苏牛']='苏牛奶:BAAALgADCgQJBAAAAA==.',
['萨满']='萨满:BAAALgAECgMJAgAAAA==.',
['蓝瓶']='蓝瓶子:BAAALgAECgMJAwAAAA==.',
['蓝色']='蓝色海郁云烟:BAAALgAFFAIJAgAAAA==.',
['赤孔']='赤孔雀:BAAALgAECgEJAQAAAA==.',
['辛萨']='辛萨猫师:BAAALgAFFAIJAwAAAA==.',
['辰庚']='辰庚玄:BAAALgAECgUJBgAAAA==.',
['达不']='达不溜丶圣盾:BAAALgAECgYJDAAAAA==.达不溜丶坠星:BAAALgAECgYJDQAAAA==.达不溜丶戾魔:BAAALgAECgcJBwAAAA==.',
['进击']='进击的小怪兽:BAAALgADCgcJBwAAAA==.',
['邪术']='邪术绿魔:BAAALgAECgEJAQAAAA==.',
['邪能']='邪能信仰圣光:BAAALgAECgYJDgAAAA==.',
['邻家']='邻家大领主:BAAALgADCgIJAgAAAA==.',
['都发']='都发地方:BAACLgAFFH8FAAIUAAIJLwvlHACJAAAUAAIJLwvlHACJAAAuAAQKfxcAAxQABglDHUAzANwBABQABglDHUAzANwBABUAAQmtA1SKACUAAAAA.',
['阿达']='阿达尔伯特:BAAALgAFFAEJAQAAAA==.',
['随风']='随风飘无影:BAAALgADCgEJAQAAAA==.',
['雷电']='雷电瓶子:BAAALgAECgIJAgAAAA==.',
['青彦']='青彦:BAABLgAFFH8IAAIHAAMJ1CGGHgAkAQAHAAMJ1CGGHgAkAQABLgAFFAUJAgAPAAAAAA==.',
['頭上']='頭上长犄角:BAAALgAFFAIJAgABLgAFFAMJBgAIAO4UAA==.',
['顾也']='顾也:BAABLgAECn8VAAMWAAcJGR1oFABwAgAWAAcJGR1oFABwAgAXAAMJLRPBCgCjAAAAAA==.',
['飞行']='飞行雪绒:BAABLgAFFH8JAAIOAAQJ/xZdCQBjAQAOAAQJ/xZdCQBjAQAAAA==.',
['高等']='高等:BAAALgAECgYJDAAAAA==.',
['麻哥']='麻哥自有妙计:BAAALgADCgMJAwAAAA==.',
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
