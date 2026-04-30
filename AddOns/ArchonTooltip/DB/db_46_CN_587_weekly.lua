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

local lookup = {'DeathKnight-Unholy','DemonHunter-Devourer','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Elemental','Unknown-Unknown','DemonHunter-Havoc','Druid-Restoration','Rogue-Subtlety','Hunter-Survival','Druid-Guardian','Druid-Balance','Paladin-Retribution','Warlock-Demonology','Warlock-Destruction','Monk-Brewmaster','Evoker-Augmentation','Monk-Mistweaver','Monk-Windwalker','Mage-Frost','Druid-Feral','Evoker-Devastation','Warrior-Arms','Warrior-Fury','Warrior-Protection',}
local provider = {region='CN',realm='刀塔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Aghanim:BAAALgAECgQJBAAAAA==.',
An='Anxinw:BAAALgADCgYJBwAAAA==.',
Ar='Artimus:BAAALgAFFAQJBAAAAA==.',
At='Athena:BAAALgAECgQJBAAAAA==.',
Bm='Bmk:BAAALgAFFAEJAwAAAA==.',
De='Deathcomin:BAAALgAFFAMJAwAAAA==.Deathnight:BAACLgAFFH8GAAIBAAQJIBTNEQBaAQABAAQJIBTNEQBaAQAuAAQKfxUAAgEACQnLFwBAADgCAAEACQnLFwBAADgCAAAA.Demonvariant:BAABLgAFFH8FAAICAAQJ6BYVDAD/AAACAAQJ6BYVDAD/AAAAAA==.',
Dt='Dtfkk:BAAALgAECgMJAwAAAA==.',
Eu='Euphoria:BAAALgAECgYJCgAAAA==.',
Fo='Forsake:BAAALgADCgEJAQAAAA==.',
Fr='Freya:BAABLgAFFH8GAAMDAAQJrQd8GgCcAAADAAIJdgV8GgCcAAAEAAIJ4wlXHwCYAAAAAA==.Frigga:BAABLgAFFH8MAAMEAAUJnxE+BQCmAAAEAAIJBBg+BQCmAAADAAMJOQu/GACkAAAAAA==.',
Fy='Fy:BAACLgAFFH8MAAIFAAUJ6RUwBACjAQAFAAUJ6RUwBACjAQAuAAQKfxsAAgUACAn8I6IHABgDAAUACAn8I6IHABgDAAAA.',
Gt='Gtfkk:BAAALgAECgcJCgAAAA==.',
Gu='Gusta:BAAALgAECgQJBgAAAA==.',
He='Hellalleria:BAAALgAECgEJAQAAAA==.Hellmedivh:BAAALgAECgUJCAAAAA==.',
Ho='Holyfire:BAAALgAECgYJBwABLgAFFAQJCwABADUjAA==.',
Ke='Keepcalm:BAAALgAECgEJAQAAAA==.',
Kt='Ktfkk:BAAALgADCgEJAQABLgAFFAEJAwAGAAAAAA==.',
Mi='Mikufufu:BAABLgAECn8iAAICAAgJGBxYIwB+AgACAAgJGBxYIwB+AgAAAA==.',
Mo='Morgaladriel:BAAALgAFFAMJBAAAAA==.',
Mt='Mtfkk:BAAALgAECgEJAgAAAA==.',
Mu='Muranyu:BAAALgADCgIJAgAAAA==.',
Or='Orphea:BAAALgADCgYJBgAAAA==.',
Rh='Rhea:BAAALgAFFAIJAgAAAA==.',
Si='Sif:BAABLgAFFH8JAAMDAAQJbw6eGAClAAADAAIJCAqeGAClAAAEAAIJ1hKBHACkAAAAAA==.',
Sm='Smilence:BAAALgAECgcJBgAAAA==.',
St='Stiliiu:BAABLgAECn8jAAMHAAYJxRzsHADZAQAHAAYJFRjsHADZAQACAAYJExmPHQAaAQAAAA==.Stormhit:BAACLgAFFH8LAAIBAAQJNSN6CwB4AQABAAQJNSN6CwB4AQAuAAQKfxkAAgEACAlBI30PACEDAAEACAlBI30PACEDAAAA.',
Su='Suga:BAAALgAECgYJCwAAAA==.Sumail:BAABLgAFFH8JAAIIAAMJeww5EgDYAAAIAAMJeww5EgDYAAAAAA==.',
Th='Themis:BAAALgAFFAQJBAAAAA==.',
Vu='Vurtne:BAAALgAECgEJAQAAAA==.',
Wa='War:BAAALgADCgQJBAAAAA==.',
Wh='Whisperer:BAAALgADCgYJBgAAAA==.',
Ye='Yep:BAAALgAECgIJAwAAAA==.',
['三角']='三角初华:BAAALgAECgcJEAAAAA==.',
['不丢']='不丢:BAAALgAECgEJAQAAAA==.',
['东油']='东油二叉树:BAAALgAECgcJCQAAAA==.',
['丰满']='丰满的女女:BAAALgAFFAQJBAAAAA==.',
['丶周']='丶周杰伦:BAAALgADCgEJAQAAAA==.',
['丶泡']='丶泡泡大王:BAAALgADCgYJBgAAAA==.',
['丶猫']='丶猫祭:BAAALgAECgYJCAAAAA==.',
['丶程']='丶程少商:BAAALgAECgYJBgAAAA==.',
['丶阿']='丶阿瓦达肯瓜:BAAALgAECgcJCAAAAA==.',
['主力']='主力:BAAALgAECgEJAQAAAA==.',
['久露']='久露:BAAALgAECgcJDQAAAA==.',
['乌兰']='乌兰巴托:BAAALgADCgUJBQAAAA==.',
['亚瑟']='亚瑟特莉丝:BAAALgADCgYJBwAAAA==.',
['伊利']='伊利蛋怒风:BAAALgAECgQJBAAAAA==.',
['伽罗']='伽罗皇后:BAAALgAECgMJBAAAAA==.',
['余火']='余火之烬:BAAALgAFFAEJAQAAAA==.',
['你猜']='你猜我多重:BAAALgAECgUJDQAAAA==.',
['俠鵺']='俠鵺:BAABLgAFFH8GAAIJAAMJ3g4WDgAMAQAJAAMJ3g4WDgAMAQAAAA==.',
['八级']='八级大狂風:BAAALgAFFAIJBAAAAA==.',
['兰伊']='兰伊奥娜:BAAALgADCgYJCQAAAA==.',
['兰梦']='兰梦心雪:BAAALgAECgMJAwAAAA==.',
['再睡']='再睡三十分钟:BAAALgAFFAQJBAAAAA==.',
['冻手']='冻手:BAAALgAFFAEJAQAAAA==.',
['刀塔']='刀塔大魔王:BAAALgAECgEJAQAAAA==.',
['刀锋']='刀锋意志:BAAALgAECgcJBwAAAA==.',
['十谏']='十谏征君:BAAALgADCgEJAQAAAA==.',
['千秋']='千秋:BAAALgADCggJCAAAAA==.',
['卖糖']='卖糖果的:BAAALgAECgMJBQAAAA==.',
['南宫']='南宫:BAAALgAECgYJDAAAAA==.',
['卡卡']='卡卡大魔王:BAABLgAFFH8KAAMDAAQJ7RKhAwBQAQADAAQJ5A+hAwBQAQAEAAIJfhl5GgCvAAAAAA==.',
['压力']='压力马斯内:BAAALgAECggJDgAAAA==.',
['可愛']='可愛刀:BAABLgAFFH8HAAMDAAQJ2A0oGwCWAAAEAAIJPhTJHACjAAADAAIJcwcoGwCWAAAAAA==.',
['可达']='可达鸭:BAAALgAECgEJAgAAAA==.',
['周六']='周六快乐一下:BAAALgAECgYJEwAAAA==.',
['喵妮']='喵妮克希亚:BAAALgAFFAIJAgAAAA==.',
['嘉贝']='嘉贝莉娜:BAAALgAECgQJBAAAAA==.',
['嘿哟']='嘿哟嘿哟嘿:BAAALgAECgUJBQAAAA==.',
['团本']='团本的王:BAACLgAFFH8OAAQDAAQJ7B/pDgDUAAAEAAMJrxf6EwD/AAADAAIJhiPpDgDUAAAKAAIJNB7hBQB3AAAuAAQKfxYAAwQABwkNI5sdADcCAAQABgn/IpsdADcCAAMAAgmCJMyGANQAAAAA.',
['在下']='在下毛毛雨:BAAALgAECggJCAAAAA==.',
['在逃']='在逃强劫饭:BAAALgAECgIJAwAAAA==.',
['增粗']='增粗增大增强:BAAALgAECgEJAQAAAA==.',
['夏利']='夏利巴黎春雪:BAACLgAFFH8PAAQLAAQJfAWwAQDWAAAMAAQJdgM+DQALAQALAAQJfAWwAQDWAAAIAAEJaANCKgA2AAAuAAQKfxUABAsABwkdExUVACABAAwABglCE41AAC8BAAsABQkRFhUVACABAAgAAgkVBV+/AEgAAAAA.',
['大怪']='大怪兽志总:BAAALgAECgkJCQAAAA==.大怪兽豪总:BAABLgAECn8ZAAICAAkJoBYTIACRAgACAAkJoBYTIACRAgAAAA==.大怪兽陈总:BAABLgAECn8ZAAICAAkJPxhYJwBnAgACAAkJPxhYJwBnAgAAAA==.',
['大肉']='大肉丸:BAAALgAECgIJAwAAAA==.',
['天真']='天真的橡皮:BAAALgAECgYJBgAAAA==.',
['太寿']='太寿鸠毛:BAACLgAFFH8MAAINAAUJSRroAwC0AQANAAUJSRroAwC0AQAuAAQKfyAAAg0ACQmII5UEAIMDAA0ACQmII5UEAIMDAAAA.',
['奶块']='奶块救我:BAAALgAECgQJBwAAAA==.',
['奶快']='奶快救我:BAAALgAECgQJBQAAAA==.',
['奶浓']='奶浓:BAAALgADCgQJBAAAAA==.',
['奶牛']='奶牛刺身:BAAALgAECgQJBgAAAA==.',
['奶白']='奶白的学子:BAAALgAECgcJBwAAAA==.',
['寄风']='寄风尘:BAAALgADCgMJAwAAAA==.',
['小勇']='小勇士:BAAALgAFFAEJAQAAAA==.',
['小小']='小小猎:BAAALgAECgEJAQAAAA==.',
['小怪']='小怪兽志志:BAAALgAECgkJEwAAAA==.小怪兽豪儿:BAAALgAECgMJAwAAAA==.小怪兽豪豪:BAAALgAECgYJBgAAAA==.小怪兽陈陈:BAAALgAECgkJEQAAAA==.',
['小白']='小白剑士:BAACLgAFFH8FAAINAAIJZhldIACtAAANAAIJZhldIACtAAAuAAQKfxUAAg0ABwnIHDQLAN4BAA0ABwnIHDQLAN4BAAAA.',
['小野']='小野术:BAAALgAECgMJAwAAAA==.',
['尼古']='尼古拉丝赵四:BAAALgAECgIJAgAAAA==.',
['带土']='带土哥:BAAALgAECgQJBAAAAA==.',
['弗雷']='弗雷德里克尔:BAAALgADCgYJBgAAAA==.',
['强尼']='强尼马托斯:BAAALgADCgMJAwAAAA==.',
['心渊']='心渊魔角:BAAALgAFFAIJAgABLgAFFAUJBAAGAAAAAA==.',
['心若']='心若琉璃:BAAALgAECgEJAgAAAA==.',
['性感']='性感小锤:BAABLgAFFH8IAAIOAAQJzBQZHwAHAQAOAAQJzBQZHwAHAQAAAA==.',
['悲伤']='悲伤火腿鸡:BAAALgAFFAUJBAAAAA==.',
['我就']='我就信了:BAAALgADCgQJBAAAAA==.',
['我是']='我是你老汉:BAAALgAECgYJDAAAAA==.',
['我有']='我有两个密秘:BAAALgAECgUJBQAAAA==.',
['戴拿']='戴拿个杯:BAAALgAECgQJBAAAAA==.',
['承接']='承接各项工程:BAAALgADCgEJAQAAAA==.',
['折光']='折光:BAAALgAECgYJBQABLgAFFAIJAgAGAAAAAA==.',
['拉菲']='拉菲加冰:BAAALgAECggJDgABLgAFFAQJBAAGAAAAAA==.',
['挽鸽']='挽鸽:BAAALgAECgMJAwAAAA==.',
['撼地']='撼地神牛:BAAALgADCgkJDAAAAA==.',
['救救']='救救我救救我:BAABLgAFFH8IAAMOAAMJzRwHGgAiAQAOAAMJzRwHGgAiAQAPAAEJkxfzEwBWAAAAAA==.',
['旱地']='旱地牛牛:BAAALgAFFAEJAgAAAA==.',
['旺德']='旺德发:BAAALgAECgcJCgAAAA==.',
['星之']='星之歇比:BAAALgADCgEJAQAAAA==.',
['星辰']='星辰丶圣焰:BAAALgAECgUJBgAAAA==.星辰丶枭熊:BAAALgAECgMJAwAAAA==.',
['春天']='春天的跳动:BAAALgAECgcJDAAAAA==.',
['暗叶']='暗叶:BAABLgAECn8UAAIQAAcJJCA7GABDAgAQAAcJJCA7GABDAgABLgAFFAIJAgAGAAAAAA==.',
['暗夜']='暗夜龙:BAAALgADCggJCAABLgAFFAIJAgAGAAAAAA==.',
['暴力']='暴力站桩:BAAALgAECgUJBgAAAA==.',
['曼波']='曼波的牡蛎:BAAALgAECgIJAgAAAA==.',
['月下']='月下绮梦:BAAALgADCgEJAQAAAA==.',
['朋友']='朋友来只鹅:BAAALgAECgUJBQAAAA==.',
['武曽']='武曽:BAAALgAECgcJBgABLgAFFAIJBQARAKkNAA==.',
['永带']='永带妹:BAABLgAECn8YAAMSAAcJfh+WEgA8AgASAAcJfh+WEgA8AgATAAMJrguNWwCiAAAAAA==.',
['沃兹']='沃兹沃斯:BAAALgAECgEJAQAAAA==.',
['沉江']='沉江警告:BAAALgAECgQJBAAAAA==.',
['沙兜']='沙兜拽根:BAAALgAECgcJCAAAAA==.',
['波士']='波士疯牛:BAAALgAECgEJAgAAAA==.',
['流苏']='流苏无名:BAAALgAECgQJBAAAAA==.',
['浪荡']='浪荡小公主:BAAALgADCgIJAgAAAA==.浪荡小野兽:BAAALgADCgIJAgAAAA==.',
['满穗']='满穗良人:BAABLgAFFH8GAAICAAQJUBFhEwA2AQACAAQJUBFhEwA2AQABLgAFFAQJCgAUAFQbAA==.满穗良仁:BAACLgAFFH8KAAIUAAQJVBtTFAB5AQAUAAQJVBtTFAB5AQAuAAQKfxUAAhQABwkRIrktALsCABQABwkRIrktALsCAAAA.',
['灌注']='灌注工具人:BAAALgADCgYJBgAAAA==.',
['火箭']='火箭龟:BAABLgAFFH8JAAIVAAMJGiIbAgAoAQAVAAMJGiIbAgAoAQAAAA==.',
['炎舞']='炎舞仇樱:BAAALgADCgEJAQAAAA==.',
['爱吃']='爱吃米饭:BAABLgAFFH8LAAISAAUJ7x3iAQCcAQASAAUJ7x3iAQCcAQAAAA==.',
['独啸']='独啸狂风:BAAALgAECgUJBgAAAA==.',
['猎魂']='猎魂者丶凛:BAAALgAECgYJBgAAAA==.',
['玛烈']='玛烈嘉临光:BAAALgAECgMJBAAAAA==.',
['瑾年']='瑾年丨蒼瞳:BAAALgAECgQJCQAAAA==.',
['瓦大']='瓦大叔:BAAALgAECgcJDQAAAA==.',
['生如']='生如芥子:BAAALgADCgIJAgAAAA==.',
['盖亚']='盖亚复仇:BAAALgAECgEJAQAAAA==.',
['瞎玩']='瞎玩:BAABLgAECn8YAAIWAAgJzhNiDgD0AQAWAAgJzhNiDgD0AQAAAA==.',
['神父']='神父:BAAALgAECgkJEQAAAA==.',
['科比']='科比布莱恩特:BAAALgAECgEJAQAAAA==.',
['第一']='第一神拳:BAAALgADCgEJAQAAAA==.',
['米奈']='米奈希尔夫人:BAAALgAECgEJAgAAAA==.',
['素颜']='素颜七分姿色:BAAALgAFFAEJAQAAAA==.',
['紫霞']='紫霞小魔仙:BAAALgAECgQJAwAAAA==.',
['约等']='约等于麟:BAAALgAECgEJAQAAAA==.',
['纳尼']='纳尼莫诺:BAAALgAECgMJBgAAAA==.',
['绿薯']='绿薯:BAAALgAECgUJBQAAAA==.',
['美国']='美国人:BAAALgAFFAIJAwABLgAFFAMJCQAVABoiAA==.',
['翻滚']='翻滚的荷包蛋:BAAALgADCgYJBgAAAA==.',
['翼德']='翼德丶:BAACLgAFFH8QAAIBAAQJ/yGdAQCdAQABAAQJ/yGdAQCdAQAuAAQKfxYAAgEABwm8JNQnAJsCAAEABwm8JNQnAJsCAAAA.',
['老孙']='老孙头:BAAALgAECgkJBgAAAA==.',
['肖申']='肖申克的回忆:BAAALgAECgYJDAAAAA==.',
['胖虎']='胖虎:BAAALgAECgUJBgAAAA==.',
['脑中']='脑中弹:BAAALgAECgEJAQAAAA==.',
['至尊']='至尊奶妈:BAAALgAECgcJEwAAAA==.',
['至高']='至高荣耀:BAAALgAECgcJBwAAAA==.',
['芝士']='芝士牦牛:BAAALgAECgUJCAAAAA==.',
['茉艾']='茉艾拉:BAAALgAECgIJAgAAAA==.',
['莫甘']='莫甘娜:BAAALgAECgkJCQAAAA==.',
['萤火']='萤火虫:BAAALgAECgQJBAAAAA==.',
['蒂花']='蒂花之秀:BAAALgADCgEJAQAAAA==.',
['虚天']='虚天一方:BAAALgAECgEJAQAAAA==.',
['虚空']='虚空恶魔猎手:BAAALgAECgMJAwAAAA==.',
['血色']='血色百夫长:BAAALgAECgEJAQAAAA==.',
['见绮']='见绮鸣丶:BAAALgAFFAIJAgABLgAFFAQJCgAXAAAUAA==.',
['认怪']='认怪不认人:BAAALgADCgQJAQAAAA==.',
['谜团']='谜团:BAAALgAFFAIJAgAAAA==.',
['谭雅']='谭雅丶:BAACLgAFFH8KAAQXAAQJABTUBQC2AAAYAAMJERNSEQD9AAAXAAIJNhfUBQC2AAAZAAEJBBEnEABDAAAuAAQKfx4ABBgACAlFItkPANQCABgACAnQINkPANQCABkABgk7H3MVALUBABcABAlxGwwVAFkBAAAA.',
['过期']='过期:BAAALgAECgYJCAAAAA==.过期的梦:BAAALgADCgQJBAAAAA==.',
['逆乾']='逆乾坤:BAAALgADCgcJBwAAAA==.',
['邪恶']='邪恶降临:BAAALgAECgYJBwAAAA==.',
['部落']='部落小混混:BAAALgAECgIJAwAAAA==.',
['错觉']='错觉消战:BAAALgAECgYJDgAAAA==.',
['闻言']='闻言:BAAALgAECgYJBwAAAA==.',
['隨性']='隨性发挥:BAAALgAECgIJAgAAAA==.',
['露西']='露西:BAAALgADCgEJAQAAAA==.',
['风车']='风车骑士:BAAALgAFFAIJAgAAAA==.',
['香蕉']='香蕉奶皮:BAAALgADCgYJBgAAAA==.',
['马嘉']='马嘉祺:BAAALgAECgUJBwAAAA==.',
['马国']='马国成:BAAALgADCgYJBgAAAA==.',
['高小']='高小宝丶:BAAALgAECgYJDAAAAA==.',
['高松']='高松老灯:BAAALgAFFAIJAgAAAA==.',
['魏期']='魏期有病毒:BAAALgAECgQJBQAAAA==.',
['魔法']='魔法坚果:BAAALgADCgMJAwAAAA==.',
['黄亦']='黄亦玫:BAAALgAFFAIJAwAAAA==.',
['黄昏']='黄昏落叶时:BAAALgAECgIJAgAAAA==.',
['黄油']='黄油女主:BAAALgAECgcJBwAAAA==.',
['龙叔']='龙叔:BAAALgAFFAEJAgAAAA==.',
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
