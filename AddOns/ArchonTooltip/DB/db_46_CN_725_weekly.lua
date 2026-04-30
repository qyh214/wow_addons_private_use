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

local lookup = {'Mage-Frost','Warlock-Affliction','Warlock-Demonology','Warrior-Fury','Paladin-Holy','Rogue-Subtlety','Unknown-Unknown','Paladin-Protection','Hunter-BeastMastery','Shaman-Restoration','Evoker-Augmentation','Priest-Discipline','Paladin-Retribution','Warlock-Destruction','Shaman-Elemental','Evoker-Preservation',}
local provider = {region='CN',realm='沙怒',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ao='Aoey:BAAALgAECgcJDQAAAA==.',
Do='Dopa:BAAALgAECgYJAwAAAA==.',
En='Endwordgry:BAABLgAFFH8FAAIBAAIJig/SRQCkAAABAAIJig/SRQCkAAAAAA==.Enzo:BAABLgAECn8gAAMCAAYJKhKVFwDAAAADAAUJHhDhuQDkAAACAAMJ/hOVFwDAAAAAAA==.',
Fu='Fuiny:BAAALgAECgMJAwAAAA==.',
He='Helbeel:BAAALgAECgIJAQAAAA==.',
Il='Ilh:BAAALgAECgEJAQAAAA==.',
Le='Lesyndicat:BAAALgADCgUJBQAAAA==.',
Lo='Loolo:BAAALgAECgYJCQAAAA==.',
Ma='Marsares:BAAALgAECgUJDQAAAA==.',
Ne='Nescafem:BAAALgAECgUJBwAAAA==.',
Qw='Qwesg:BAAALgAFFAIJAwAAAA==.',
Ra='Ralph:BAAALgAECgYJBgAAAA==.',
So='Sorrymaker:BAAALgADCgEJAQAAAA==.',
Ss='Ssevenss:BAAALgAECgQJBAAAAA==.Sseventar:BAAALgAECgQJBAAAAA==.Ssevenuht:BAAALgAECgUJBQAAAA==.',
['Öö']='Ööäöö:BAAALgADCgIJAQAAAA==.',
['一六']='一六指环:BAAALgAFFAIJAgAAAA==.一六指环灬:BAAALgAECgEJAgAAAA==.',
['一碗']='一碗豆腐:BAAALgADCgQJBAAAAA==.',
['一虎']='一虎贲一:BAAALgAECgMJAwAAAA==.',
['丁山']='丁山牧:BAAALgAFFAEJAQAAAA==.',
['七夜']='七夜舍瓦:BAAALgAECgIJAgAAAA==.',
['七月']='七月在野:BAAALgADCgcJDQAAAA==.七月食瓜:BAAALgADCgYJDAAAAA==.',
['下雨']='下雨的伊伊:BAAALgAECgYJBwAAAA==.',
['不要']='不要停下来啊:BAABLgAECn8YAAIEAAcJWR4yGgB6AgAEAAcJWR4yGgB6AgAAAA==.',
['丶墨']='丶墨渊:BAABLgAFFH8HAAIFAAMJHBUADwDmAAAFAAMJHBUADwDmAAAAAA==.',
['丶星']='丶星延:BAABLgAFFH8FAAIBAAIJcgtZQgCqAAABAAIJcgtZQgCqAAAAAA==.',
['乄誓']='乄誓灬约:BAAALgAECgEJAQAAAA==.',
['九尾']='九尾之魂:BAAALgAECgUJBgAAAA==.',
['二舅']='二舅姥爷:BAAALgAECgEJAQAAAA==.',
['五月']='五月螽斯动股:BAAALgADCgYJCgAAAA==.',
['人心']='人心薄凉丶伤:BAAALgAECgkJDQAAAA==.',
['傲娇']='傲娇小伙伴:BAAALgAFFAIJAwAAAA==.',
['傲霊']='傲霊隨風:BAAALgADCgIJAgAAAA==.',
['全区']='全区美男:BAAALgADCgYJBgAAAA==.',
['六六']='六六:BAABLgAFFH8FAAIGAAIJhRBmFACsAAAGAAIJhRBmFACsAAAAAA==.',
['兰尼']='兰尼斯特:BAAALgAECgYJCgAAAA==.',
['兰斯']='兰斯维亚:BAAALgADCgYJBgAAAA==.',
['养家']='养家虎口:BAAALgADCgYJBgABLgAECgcJBQAHAAAAAA==.',
['冰逝']='冰逝风尘:BAAALgAECgEJAwABLgAFFAMJBgAIAEwNAA==.',
['冻顶']='冻顶乌龙:BAAALgAECgcJBwAAAA==.',
['凯特']='凯特琳丶薇:BAABLgAFFH8HAAIJAAQJBg/VBQBGAQAJAAQJBg/VBQBGAQAAAA==.',
['勇敢']='勇敢狗咪:BAAALgAECgEJAQAAAA==.',
['午夜']='午夜镇魂曲:BAAALgAECgEJAQABLgAFFAMJBgAIAEwNAA==.',
['卡布']='卡布达:BAABLgAECn8jAAIKAAgJ6gpMDgBbAQAKAAgJ6gpMDgBbAQAAAA==.',
['叫我']='叫我孙校长:BAAALgAECgUJBwAAAA==.',
['咕咕']='咕咕爱吃香蕉:BAAALgADCgEJAgAAAA==.',
['咖啡']='咖啡猫:BAAALgAECgEJAQAAAA==.',
['哈基']='哈基南北绿豆:BAAALgAECgEJAgAAAA==.',
['哎哟']='哎哟丶丹丹:BAAALgAFFAIJAgAAAA==.',
['哪李']='哪李贵了:BAAALgAECgMJAwAAAA==.',
['喵帕']='喵帕鼠:BAAALgAECgEJAQAAAA==.',
['嗷嗷']='嗷嗷呜呜:BAAALgAECgYJBgAAAA==.',
['圆头']='圆头猫耶:BAAALgAECgEJAwAAAA==.',
['在等']='在等月亮和你:BAAALgAECgcJEwAAAA==.',
['地精']='地精真坑爹:BAAALgAECgYJBgAAAA==.',
['大尾']='大尾鲈鳗:BAAALgAECgUJDQAAAA==.',
['大肉']='大肉肉包:BAAALgAFFAQJBAAAAA==.',
['天使']='天使之泪:BAAALgADCgYJBgAAAA==.',
['天堂']='天堂向右:BAAALgADCgEJAQAAAA==.',
['天晴']='天晴诗雨:BAAALgADCgEJAQAAAA==.',
['天枢']='天枢丨:BAAALgAECgEJAgAAAA==.',
['夺你']='夺你俩哈:BAAALgAECgYJCAAAAA==.',
['奥利']='奥利奥:BAAALgADCgUJBQAAAA==.',
['好运']='好运相伴:BAAALgADCgEJAQAAAA==.',
['姑苏']='姑苏:BAAALgAECgEJAQAAAA==.',
['守护']='守护灬永恒:BAAALgAECgIJAgAAAA==.',
['小咘']='小咘灬爱酱:BAAALgAECgIJAgAAAA==.',
['小夕']='小夕夕:BAAALgADCgQJBAAAAA==.',
['小废']='小废:BAAALgAECgEJAQAAAA==.',
['小把']='小把秧:BAAALgAECgcJDQAAAA==.',
['小明']='小明儿:BAAALgADCgYJBgAAAA==.',
['小期']='小期盼:BAAALgAECgEJAQAAAA==.',
['小猪']='小猪苒:BAAALgAFFAIJBAAAAA==.',
['小猫']='小猫菲儿:BAAALgAECggJEgAAAA==.',
['小的']='小的德德:BAAALgAECgYJBgABLgAFFAMJBgAIAEwNAA==.',
['小短']='小短腿的莱莱:BAAALgAECgEJAQAAAA==.',
['尘世']='尘世遗骸:BAAALgAECgQJBAABLgAECgYJCwAHAAAAAA==.',
['局丶']='局丶:BAAALgAECgYJBQAAAA==.',
['工会']='工会主力小德:BAAALgADCgUJBQAAAA==.',
['巫喵']='巫喵王之谜:BAAALgADCggJCAAAAA==.',
['带妳']='带妳私奔:BAAALgAECgYJBgAAAA==.',
['幸福']='幸福的小强:BAAALgAFFAEJAgABLgAFFAYJGAALALwTAA==.',
['幸运']='幸运大鲤鱼:BAAALgAECgYJCQAAAA==.',
['幻月']='幻月丶:BAAALgAECgcJBwAAAA==.',
['彬彬']='彬彬的:BAAALgAECgEJAgAAAA==.',
['心靈']='心靈捕手:BAAALgAECgcJBwAAAA==.',
['情难']='情难舍:BAAALgADCgQJBAAAAA==.',
['懒大']='懒大王:BAABLgAFFH8IAAIMAAQJXRBjCgA5AQAMAAQJXRBjCgA5AQAAAA==.',
['抹灭']='抹灭:BAAALgAECgIJAgAAAA==.',
['拾忆']='拾忆少女的梦:BAAALgAECgYJBgAAAA==.',
['斩断']='斩断奈何桥:BAAALgAECgcJBwAAAA==.',
['明灬']='明灬:BAAALgAECgYJDQAAAA==.',
['星海']='星海楛:BAAALgADCgEJAQAAAA==.',
['晚来']='晚来一枕月灬:BAAALgAECgIJAgAAAA==.',
['暗淡']='暗淡的矿脉:BAAALgAECgYJCQAAAA==.',
['暗落']='暗落:BAACLgAFFH8JAAIBAAQJBwZQFQDfAAABAAQJBwZQFQDfAAAuAAQKfxYAAgEACAnNFhtFAGgCAAEACAnNFhtFAGgCAAAA.',
['最后']='最后的眼涙:BAAALgAECgkJCwAAAA==.',
['最爱']='最爱吃兽奶:BAAALgAECgYJBgAAAA==.',
['月晴']='月晴歌:BAAALgAECgEJAgAAAA==.',
['朗月']='朗月灬清风:BAAALgAECgEJAQAAAA==.',
['木术']='木术:BAAALgAECgYJDgAAAA==.',
['杰洛']='杰洛士灬:BAAALgAECgUJBQAAAA==.',
['板甲']='板甲辣妹潼:BAABLgAECn8ZAAMFAAgJMBM+KgDgAQAFAAgJMBM+KgDgAQANAAIJewPHLQFGAAAAAA==.',
['林卡']='林卡:BAACLgAFFH8QAAMDAAUJkiKnCwB+AQADAAUJ9CGnCwB+AQAOAAIJOhYZCgC4AAAuAAQKfxoABAMACAnlJMocAKkCAAMABwnlJMocAKkCAA4AAwn/G0UrABMBAAIAAQkAADwgAHEAAAAA.',
['果儿']='果儿佟佟:BAAALgAECgIJAgAAAA==.',
['枫兮']='枫兮云兮:BAAALgAECgEJAgAAAA==.',
['柒为']='柒为你而战:BAAALgAECgUJCgAAAA==.',
['柒柒']='柒柒灬:BAAALgAECgkJBAABLgAFFAUJEAADAOAaAA==.',
['棒棒']='棒棒的好二萌:BAAALgAECgEJAgAAAA==.',
['森西']='森西:BAAALgADCgYJCwABLgAECgYJCwAHAAAAAA==.',
['楚璇']='楚璇:BAABLgAFFH8GAAINAAIJSyKKGgDMAAANAAIJSyKKGgDMAAAAAA==.',
['榛果']='榛果布朗尼:BAAALgAECgEJAQAAAA==.',
['比鲁']='比鲁斯:BAAALgAECgQJDAAAAA==.',
['永恒']='永恒的狩猎:BAAALgADCgEJAQAAAA==.',
['没脸']='没脸猫:BAAALgAFFAQJBAAAAA==.',
['法丶']='法丶十三:BAABLgAFFH8FAAIBAAIJ1gJxSgCWAAABAAIJ1gJxSgCWAAAAAA==.',
['法力']='法力残渣:BAAALgAECgEJAQAAAA==.',
['波雅']='波雅汉库克丶:BAAALgAFFAEJAgAAAA==.',
['涂卡']='涂卡铅笔:BAAALgAECgEJAwAAAA==.',
['涤罪']='涤罪之焰:BAAALgAFFAEJAQAAAA==.',
['清喷']='清喷喷:BAAALgAFFAIJAgAAAA==.',
['清晰']='清晰大自然:BAAALgAECgEJAQAAAA==.',
['清穗']='清穗:BAAALgAECgEJAQAAAA==.',
['灬木']='灬木三:BAAALgAECgEJAgAAAA==.灬木三丶:BAAALgAECgkJAQAAAA==.灬木三丶丶:BAAALgAFFAIJAgAAAA==.',
['灬殇']='灬殇丨残魂:BAAALgAECgQJBAABLgAFFAIJAgAHAAAAAA==.',
['炼狱']='炼狱天使:BAAALgAECgEJAQAAAA==.',
['烈焰']='烈焰:BAAALgAECggJBgAAAA==.',
['热西']='热西丹木:BAAALgADCgUJBQAAAA==.',
['焚城']='焚城:BAAALgAFFAEJAQAAAA==.',
['牛霸']='牛霸:BAAALgAECgEJAgAAAA==.',
['狂卷']='狂卷尼姑庵:BAAALgADCgUJBQAAAA==.',
['狐一']='狐一菲:BAAALgAECgYJBgABLgAFFAMJBgAIAEwNAA==.',
['猎图']='猎图:BAAALgAFFAEJAQAAAA==.',
['玄丶']='玄丶夏有乔木:BAAALgAECgEJAQAAAA==.',
['玄程']='玄程:BAAALgAECgIJAgAAAA==.',
['玉藻']='玉藻十字:BAAALgADCgEJAgAAAA==.',
['疾风']='疾风亂舞:BAAALgADCgcJBgAAAA==.',
['白色']='白色袜熊熊:BAAALgAECgUJCQAAAA==.',
['相亦']='相亦:BAAALgAECgMJAwAAAA==.',
['神圣']='神圣之猫:BAAALgAECgIJBQAAAA==.',
['空弦']='空弦:BAAALgAECgYJCwAAAA==.',
['纯爷']='纯爷们:BAAALgAECgQJAwAAAA==.',
['给你']='给你一老拳:BAAALgAECgEJAQAAAA==.',
['羂索']='羂索:BAAALgAFFAQJBAAAAA==.',
['翩若']='翩若游龙舞:BAAALgAECgUJCQAAAA==.',
['老帥']='老帥:BAABLgAECn8VAAIEAAcJiA+2QQCeAQAEAAcJiA+2QQCeAQAAAA==.',
['脑袋']='脑袋还在:BAABLgAFFH8HAAINAAQJhhl8EQAZAQANAAQJhhl8EQAZAQAAAA==.',
['自然']='自然风暴:BAABLgAFFH8GAAIPAAIJBBaJEwC0AAAPAAIJBBaJEwC0AAABLgAFFAMJBgAIAEwNAA==.',
['花开']='花开叶落:BAAALgAECgcJBQAAAA==.',
['苏伦']='苏伦丿萨满:BAAALgAECgEJAQAAAA==.',
['苏妲']='苏妲己:BAAALgAECgIJAgAAAA==.',
['萌灬']='萌灬小菜瓜:BAAALgAECgQJBgAAAA==.',
['萨满']='萨满四十一号:BAAALgAECgYJBgAAAA==.',
['落花']='落花犹意:BAAALgAECgIJAgAAAA==.',
['蓝色']='蓝色灵感:BAAALgADCgkJCwAAAA==.',
['蓬莱']='蓬莱山輝夜:BAAALgADCgEJAQAAAA==.',
['让我']='让我灬寐一会:BAAALgAECgEJAQAAAA==.',
['诺诺']='诺诺:BAAALgAECgcJDQAAAA==.',
['贵夫']='贵夫人:BAAALgAFFAEJAQAAAA==.',
['跟月']='跟月亮说晚安:BAAALgAECgkJDAAAAA==.',
['这锅']='这锅不背:BAAALgAECgYJBgAAAA==.',
['逐星']='逐星者丿锟叔:BAAALgAECgQJBAAAAA==.逐星者丿锟哥:BAAALgAECgQJBAAAAA==.',
['那一']='那一抹浅笑丶:BAAALgADCgMJAwAAAA==.',
['銀丶']='銀丶歌:BAAALgADCgQJBAAAAA==.',
['锦添']='锦添:BAAALgAFFAIJAgABLgAFFAMJBgAIAEwNAA==.',
['阿尔']='阿尔特留斯:BAAALgAECgYJDQAAAA==.',
['雪舞']='雪舞倾城:BAAALgAECgEJAQAAAA==.',
['雷霆']='雷霆之鄂:BAAALgAECgEJAQAAAA==.',
['雾月']='雾月幻雨:BAAALgAECgUJBQAAAA==.',
['风吹']='风吹稻塔丶:BAAALgADCgQJAgAAAA==.',
['风往']='风往北吹:BAAALgADCgEJAQAAAA==.',
['风雨']='风雨潇潇:BAAALgADCgUJBQAAAA==.',
['风靡']='风靡:BAAALgADCgQJBAAAAA==.',
['飞翔']='飞翔的神:BAAALgAECgkJCQAAAA==.',
['骑猪']='骑猪看日落:BAAALgAECgkJCwAAAA==.',
['鬼才']='鬼才三电:BAAALgAECgQJBQAAAA==.',
['魅魔']='魅魔喝茶:BAAALgADCgQJBAAAAA==.',
['黝黑']='黝黑蜗壳:BAAALgAECgYJCgAAAA==.',
['龙希']='龙希尔薇:BAABLgAFFH8LAAIQAAUJdhCkBQCbAQAQAAUJdhCkBQCbAQAAAA==.',
['龙爷']='龙爷你最牛:BAAALgAFFAQJBAAAAA==.',
['龙笼']='龙笼珑隆:BAAALgAECgQJBAAAAA==.',
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
