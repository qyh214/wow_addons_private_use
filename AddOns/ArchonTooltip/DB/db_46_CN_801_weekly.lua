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

local lookup = {'DeathKnight-Unholy','Warrior-Protection','Warrior-Fury','Shaman-Restoration','Shaman-Elemental','Priest-Holy','Priest-Discipline','Unknown-Unknown','Rogue-Subtlety','Warlock-Demonology','Mage-Frost','Priest-Shadow','Warlock-Destruction','Warlock-Affliction','Paladin-Retribution',}
local provider = {region='CN',realm='艾苏恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Cl='Clinch:BAAALgAECgcJAgAAAA==.',
Do='Dolphins:BAAALgADCgQJBAAAAA==.',
Dr='Dribbler:BAAALgADCgIJAgAAAA==.',
Ei='Eishaddai:BAAALgAECgkJAgAAAA==.',
Ic='Icecruise:BAAALgAFFAEJAQABLgAFFAMJBwABAC4eAA==.',
Ni='Nikola:BAAALgAECgQJCAAAAA==.',
Sh='Shakira:BAAALgAECgkJCQAAAA==.',
Su='Suva:BAAALgAECgMJBQAAAA==.',
To='Tokiki:BAAALgAECgEJAQAAAA==.',
Wm='Wmedic:BAAALgADCgUJBQAAAA==.',
['一千']='一千年的爱恋:BAAALgAECgQJBAAAAA==.',
['世界']='世界和平:BAAALgAECgkJEQAAAA==.',
['东华']='东华:BAAALgAECgEJAQAAAA==.',
['两条']='两条咸鱼王:BAAALgAECgEJAQAAAA==.',
['丨一']='丨一龙丨:BAAALgAECgYJDwAAAA==.',
['丨漩']='丨漩灬木:BAAALgAECgEJAQAAAA==.',
['丨璇']='丨璇灬木:BAAALgAECgEJAgAAAA==.',
['丶魔']='丶魔神丶:BAAALgAECgQJCAAAAA==.',
['乌萨']='乌萨奇:BAAALgAFFAEJAQAAAA==.',
['乱了']='乱了夏天的海:BAAALgAFFAEJAQAAAA==.',
['云汐']='云汐:BAAALgAECgEJAQAAAA==.',
['今宵']='今宵有美酒:BAACLgAFFH8HAAICAAIJxQIxDgBkAAACAAIJxQIxDgBkAAAuAAQKfx4AAwIABwl5DXkiACoBAAIABwmTCXkiACoBAAMABQnkDTNrAAkBAAAA.',
['伏魔']='伏魔小熊:BAAALgAECgYJBgAAAA==.',
['休利']='休利耶尔:BAAALgADCgQJBAAAAA==.',
['似狐']='似狐似猫:BAABLgAECn8ZAAMEAAYJQhCBVAA0AQAEAAYJQhCBVAA0AQAFAAQJQAQIbQCPAAAAAA==.',
['低保']='低保困难户:BAAALgAECgcJAwAAAA==.',
['佩恩']='佩恩:BAAALgAECgcJDQAAAA==.',
['假装']='假装不加:BAAALgAECgcJEAAAAA==.',
['凛岚']='凛岚:BAAALgADCgIJAgAAAA==.',
['别摸']='别摸我的背:BAAALgAECgEJAgAAAA==.',
['加布']='加布兽:BAAALgAFFAMJAQAAAA==.',
['千裏']='千裏煙:BAABLgAECn80AAMGAAkJNR3+CAC8AgAGAAkJNR3+CAC8AgAHAAEJFQfDWwArAAAAAA==.',
['华熊']='华熊猫:BAAALgAECgkJCgABLgAFFAUJAQAIAAAAAA==.',
['南希']='南希:BAAALgAECgYJDAAAAA==.',
['叁鞑']='叁鞑剥流:BAAALgAECgYJDgAAAA==.',
['双魂']='双魂瓦达莉亚:BAAALgADCgUJBQAAAA==.',
['可丨']='可丨楽:BAAALgADCgUJBQAAAA==.',
['史昂']='史昂丶:BAAALgADCgEJAQABLgADCgkJCQAIAAAAAA==.',
['各种']='各种受不鸟:BAAALgAECgEJAQAAAA==.',
['图拉']='图拉扬:BAAALgAECgQJBgAAAA==.',
['圣枪']='圣枪小修女:BAAALgAFFAEJAQAAAA==.',
['地狱']='地狱吼:BAAALgAECgkJBwAAAA==.地狱里的幽灵:BAAALgAECgEJAQAAAA==.',
['塞帕']='塞帕斯:BAAALgADCgEJAQAAAA==.',
['复仇']='复仇的魔女:BAAALgAECgYJBwAAAA==.',
['夏夜']='夏夜微凉:BAAALgAECgEJAQAAAA==.',
['大叔']='大叔大度:BAAALgAECgEJAgAAAA==.',
['大天']='大天狼星:BAAALgAECgEJAQAAAA==.',
['大雷']='大雷子:BAAALgAECgMJAwAAAA==.',
['大鼻']='大鼻噶:BAAALgADCgIJAgAAAA==.',
['好心']='好心肠的胖子:BAABLgAFFH8JAAIJAAMJNRRTDQATAQAJAAMJNRRTDQATAQAAAA==.',
['孜然']='孜然老牛排:BAAALgAECgEJAgAAAA==.',
['守护']='守护者伊瑞尔:BAAALgAECgEJAQAAAA==.守护者艾维娜:BAAALgAECgcJBwAAAA==.',
['寒风']='寒风无泪:BAAALgADCgEJAQAAAA==.',
['小瑶']='小瑶宝贝:BAAALgAECgIJAwAAAA==.',
['小精']='小精神:BAAALgAECgcJEgAAAA==.',
['小豆']='小豆豆的痘:BAABLgAECn8UAAIGAAkJSxpVCADGAgAGAAkJSxpVCADGAgAAAA==.',
['小酒']='小酒馆说书人:BAAALgAECgEJAQAAAA==.',
['小鬼']='小鬼乱跑:BAABLgAFFH8LAAIKAAQJvgseFgA+AQAKAAQJvgseFgA+AQAAAA==.',
['尘埃']='尘埃丶:BAAALgAFFAEJAQAAAA==.',
['差不']='差不多:BAAALgAECgEJAQAAAA==.',
['幻樱']='幻樱缭乱:BAAALgADCgYJBgAAAA==.',
['幽涯']='幽涯岚:BAAALgADCgUJBQAAAA==.',
['幽魂']='幽魂之殇:BAAALgADCgcJBwAAAA==.',
['床前']='床前明月:BAAALgAECgcJDQAAAA==.',
['心晨']='心晨:BAAALgAECgEJAQAAAA==.',
['心碎']='心碎无言:BAABLgAECn8XAAIDAAcJJRkGLwD0AQADAAcJJRkGLwD0AQAAAA==.',
['忆霜']='忆霜:BAAALgAECgYJBgAAAA==.',
['快乐']='快乐长生:BAAALgADCgYJBwAAAA==.',
['情海']='情海千花:BAAALgAECgYJBgAAAA==.',
['愤怒']='愤怒小壹贰:BAAALgAECgEJAQAAAA==.',
['懵逼']='懵逼且伤脑:BAAALgAECgEJAQAAAA==.',
['我是']='我是奶茶:BAAALgAFFAIJAwAAAA==.',
['捣蛋']='捣蛋兔:BAAALgADCgMJAwAAAA==.',
['提拉']='提拉娅:BAAALgAECgUJCgAAAA==.',
['日久']='日久生卿:BAAALgAECgMJAwAAAA==.',
['时予']='时予:BAAALgAECgQJBAAAAA==.',
['明天']='明天你好:BAAALgAECgEJAQAAAA==.',
['星辰']='星辰碎片:BAAALgAECgYJDgAAAA==.',
['暖暖']='暖暖布丁:BAAALgAFFAMJBAAAAA==.',
['最后']='最后的祈祷:BAAALgAECgYJDQAAAA==.',
['月色']='月色映凌烟:BAAALgAFFAIJAgAAAA==.',
['木木']='木木灵儿:BAAALgAECgUJCQAAAA==.',
['机械']='机械暴龙兽:BAAALgAFFAIJAgAAAA==.',
['杀你']='杀你就半刀:BAAALgAECgYJDAAAAA==.',
['来者']='来者不拒:BAAALgAECgYJBgABLgAFFAUJBQADAD8PAA==.',
['柳飞']='柳飞扬:BAAALgAECgYJEgAAAA==.',
['栋哥']='栋哥不是东哥:BAAALgAECgIJAgAAAA==.',
['桔子']='桔子不是橘子:BAAALgAECggJBgAAAA==.',
['梦淑']='梦淑颖:BAAALgADCgEJAQAAAA==.',
['榕城']='榕城大虾:BAAALgAECgEJAQAAAA==.',
['橙千']='橙千上万:BAAALgAECgEJAQAAAA==.',
['毕宿']='毕宿:BAAALgADCgIJAgAAAA==.',
['水果']='水果沙拉:BAAALgAECgEJAQAAAA==.',
['汉娜']='汉娜死亡之刃:BAAALgAECgQJBQAAAA==.',
['沙尘']='沙尘蕉蕉:BAAALgADCgUJBQAAAA==.',
['泰瑞']='泰瑞达:BAAALgAECgEJAQAAAA==.',
['满仓']='满仓:BAAALgADCgYJBgAAAA==.',
['炽天']='炽天使洛洛:BAAALgADCgYJBgAAAA==.',
['熙沄']='熙沄:BAAALgAECgQJCAAAAA==.',
['燕十']='燕十三:BAAALgAECgEJAwAAAA==.',
['牛板']='牛板筋:BAAALgAECgMJAwAAAA==.',
['牧羊']='牧羊小小:BAAALgAECgUJBQAAAA==.',
['狐言']='狐言无忌:BAAALgAECgUJDQAAAA==.',
['独丶']='独丶角兽:BAAALgADCgYJBgAAAA==.',
['狼人']='狼人加鲁鲁兽:BAAALgAFFAQJBAAAAA==.',
['猛攻']='猛攻鼠鼠:BAAALgAECgkJDAAAAA==.',
['玛丽']='玛丽奥特曼:BAAALgAECgIJAgABLgAFFAMJCgALAOEQAA==.',
['生吞']='生吞葫芦娃:BAAALgAECgYJBgAAAA==.',
['电不']='电不死你:BAAALgAECgUJCAAAAA==.',
['畾畾']='畾畾:BAAALgADCgEJAQAAAA==.',
['盐开']='盐开水:BAAALgAECgcJBwAAAA==.',
['矮柯']='矮柯基:BAAALgAECgEJAQAAAA==.',
['神龙']='神龙大侠阿宝:BAAALgAECgQJBQAAAA==.',
['简墨']='简墨:BAACLgAFFH8FAAIHAAUJSSEAAgAKAgAHAAUJSSEAAgAKAgAuAAQKfxQABAcABgnGGuoZAMoBAAcABgk2GOoZAMoBAAYABAnJDLNbAMQAAAwABAk+DMBHAMIAAAAA.',
['納尔']='納尔克:BAAALgAECgcJBwAAAA==.',
['紫丶']='紫丶小电:BAAALgAECgYJDgAAAA==.',
['繻爧']='繻爧:BAAALgAECgMJAwAAAA==.',
['繻靈']='繻靈:BAAALgAFFAIJAgAAAA==.',
['红透']='红透晚烟青:BAAALgAFFAEJAQAAAA==.',
['终极']='终极死亡召唤:BAAALgAECgIJAwAAAA==.',
['绿豆']='绿豆配芝麻:BAAALgADCgUJBgAAAA==.',
['肥肥']='肥肥受不鸟:BAAALgAECgEJAQAAAA==.',
['胖牛']='胖牛:BAAALgADCgEJAQAAAA==.',
['脱缰']='脱缰的野狗:BAAALgAECgYJBgAAAA==.',
['艾丽']='艾丽杰:BAAALgAECgMJAwAAAA==.',
['若飞']='若飞于:BAAALgAECgYJBgAAAA==.',
['莫问']='莫问:BAAALgADCgEJAQAAAA==.',
['莱丝']='莱丝:BAAALgAECgIJAgAAAA==.',
['菲奥']='菲奥娜姨:BAAALgADCgUJCAAAAA==.',
['萌萌']='萌萌哒路过丶:BAAALgAECggJBQAAAA==.',
['落幕']='落幕:BAAALgAECgEJAQAAAA==.',
['落雪']='落雪缤纷:BAAALgAECgEJAQAAAA==.',
['葬送']='葬送的芙莉莲:BAACLgAFFH8TAAMKAAUJhxyuBgBeAQAKAAUJhRyuBgBeAQANAAIJbRJ4DACoAAAuAAQKfx0ABAoACAkTI+gNAAoDAAoACAkTI+gNAAoDAA0ABAkaGugjADoBAA4AAglHJE4WAM8AAAAA.',
['西楼']='西楼哥哥:BAAALgAECgkJAgABLgAFFAYJEwAPAMggAA==.',
['西虹']='西虹市猎魔人:BAAALgAFFAEJAQAAAA==.',
['變身']='變身小丑:BAAALgAECgQJBAAAAA==.',
['豫西']='豫西大圣:BAAALgAECgEJAQAAAA==.',
['赢学']='赢学大宗师:BAAALgADCgEJAQAAAA==.',
['起个']='起个中文名:BAAALgAECgIJAwAAAA==.',
['超级']='超级高水平:BAAALgAFFAEJAQAAAA==.',
['转角']='转角遇甜瓜:BAACLgAFFH8HAAIPAAMJ/AnHDwDXAAAPAAMJ/AnHDwDXAAAuAAQKfxwAAg8ABwnSFXBdAMsBAA8ABwnSFXBdAMsBAAAA.',
['那个']='那个萨满丶:BAAALgAFFAUJBAAAAA==.',
['鑐爧']='鑐爧:BAACLgAFFH8JAAIEAAMJ/RvXDAANAQAEAAMJ/RvXDAANAQAuAAQKfxsAAwQACAlTFQ0qAOYBAAQACAlTFQ0qAOYBAAUABwmtFtgPAC4BAAAA.',
['鑫森']='鑫森淼焱磊:BAAALgAECgQJBAAAAA==.',
['银发']='银发大叔:BAAALgADCgEJAQAAAA==.',
['阁壁']='阁壁老王:BAAALgAECgEJAQAAAA==.',
['阿福']='阿福满足:BAAALgAFFAIJBAAAAA==.',
['阿门']='阿门:BAAALgAECgYJDwAAAA==.',
['陌生']='陌生:BAAALgAECgUJBgAAAA==.',
['雷刃']='雷刃:BAACLgAFFH8GAAILAAMJOSAGIgA2AQALAAMJOSAGIgA2AQAuAAQKfxQAAgsABwl1GlpcACUCAAsABwl1GlpcACUCAAAA.',
['露露']='露露:BAAALgADCgEJAQAAAA==.',
['青鸢']='青鸢:BAAALgAECgYJBgAAAA==.',
['风与']='风与自由:BAAALgAFFAIJBAAAAA==.',
['风渐']='风渐渐:BAAALgAFFAIJAgAAAA==.',
['风骚']='风骚伯起棍:BAAALgADCgIJAgAAAA==.',
['鸟德']='鸟德:BAAALgAECgEJAQAAAA==.',
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
