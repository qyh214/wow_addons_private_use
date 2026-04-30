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

local lookup = {'Unknown-Unknown','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','Hunter-Marksmanship','Druid-Restoration','Rogue-Outlaw','Warlock-Demonology','Priest-Discipline','Priest-Holy','Monk-Brewmaster','Shaman-Restoration','Paladin-Holy','Paladin-Retribution','Monk-Windwalker','DemonHunter-Havoc','Hunter-BeastMastery','DeathKnight-Frost','Druid-Balance','Warrior-Fury','Warrior-Arms',}
local provider = {region='CN',realm='永夜港',name='CN',type='weekly',zone=46,date='2026-04-25',data={As='Asahi:BAAALgADCgIJAgAAAA==.',
Cr='Crescent:BAAALgAECgMJAwAAAA==.',
Ec='Echo:BAAALgADCgcJBwABLgAECgEJAQABAAAAAA==.',
Ge='Gertrude:BAAALgAECgUJBQAAAA==.',
Jy='Jyona:BAACLgAFFH8NAAQCAAQJshn+AQB1AQACAAQJshn+AQB1AQADAAMJDBuEBgDAAAAEAAEJcgW/IwBEAAAuAAQKfxsAAwMACAlNH2IHAMgCAAMACAlNH2IHAMgCAAIABAmvHUcdAEQBAAAA.',
Ka='Kairosoth:BAAALgAECgYJBgAAAA==.',
Kr='Kraven:BAAALgAECgkJCQAAAA==.',
Li='Littlecob:BAAALgADCgUJBQAAAA==.Littleflare:BAAALgAECgcJEwAAAA==.Littleflurry:BAAALgADCgMJAwAAAA==.Littlefowler:BAAALgADCgYJCgAAAA==.Littlemoon:BAAALgAECgYJCAAAAA==.',
Lo='Loveoath:BAAALgAECgIJAgAAAA==.',
Oa='Oarmilk:BAAALgAECgQJBQAAAA==.',
Te='Tethys:BAAALgADCgcJBwAAAA==.',
Ya='Yaphetschen:BAAALgAECgQJBQAAAA==.',
Zh='Zhounuer:BAAALgAFFAIJAgAAAA==.',
Zo='Zorya:BAAALgAECgUJBwAAAA==.',
['丿蘩']='丿蘩丶:BAAALgAECgkJBgAAAA==.',
['久份']='久份:BAAALgAECgYJBgAAAA==.',
['九牛']='九牛二库:BAAALgAECgcJBwAAAA==.',
['云曦']='云曦:BAAALgADCgEJAQAAAA==.',
['云淡']='云淡风静:BAAALgAECgkJBwAAAA==.',
['代价']='代价是什么呢:BAAALgAFFAEJAQAAAA==.',
['伊诺']='伊诺鲁克:BAAALgAECgYJBgAAAA==.',
['伏戎']='伏戎于莽:BAAALgADCgEJAQAAAA==.',
['信仰']='信仰之盾:BAAALgADCgYJBgAAAA==.',
['兜兜']='兜兜有溏丶:BAAALgAECgYJBgAAAA==.',
['六福']='六福:BAAALgAECgQJBAAAAA==.',
['冬兴']='冬兴晓枫:BAAALgADCgEJAQAAAA==.',
['冷小']='冷小若:BAABLgAFFH8KAAIFAAMJLw0aFwDgAAAFAAMJLw0aFwDgAAAAAA==.',
['凄惶']='凄惶丶圣祈:BAAALgADCgEJAQAAAA==.',
['剑河']='剑河:BAAALgADCgEJAQAAAA==.',
['剑绣']='剑绣清风十三:BAAALgAFFAIJAgAAAA==.',
['勿小']='勿小怪:BAAALgADCgEJAQAAAA==.',
['北夢']='北夢吖:BAAALgAECgMJAwAAAA==.',
['千山']='千山丷鳥飛絕:BAAALgADCgEJAQAAAA==.千山灬鸟飞絕:BAAALgAECgUJBQAAAA==.千山鸟飞绝:BAAALgAECgEJAQAAAA==.',
['卖胸']='卖胸甲的小德:BAABLgAECn8bAAIGAAYJFiDrBgD8AQAGAAYJFiDrBgD8AQABLgAECgYJCQABAAAAAA==.',
['双角']='双角速高:BAAALgADCgMJAwAAAA==.',
['叶序']='叶序:BAABLgAECn8kAAIHAAgJiSQlAACdAgAHAAgJiSQlAACdAgAAAA==.',
['吹雪']='吹雪哥哥:BAAALgAECgIJAwAAAA==.吹雪老哥:BAAALgADCgUJBQAAAA==.',
['吾皇']='吾皇万睡:BAAALgAECgYJCgAAAA==.',
['哆啦']='哆啦美:BAAALgAECgIJAgAAAA==.',
['喜阳']='喜阳阳:BAAALgADCgQJBAAAAA==.',
['噬兽']='噬兽之弦:BAAALgAECgYJBQAAAA==.',
['囚鹤']='囚鹤:BAAALgAECgUJBwAAAA==.',
['埃克']='埃克斯:BAAALgAECgYJDAAAAA==.',
['墨君']='墨君武:BAAALgAECgYJBgAAAA==.',
['复生']='复生的胖球:BAAALgADCgUJBwAAAA==.',
['夏丶']='夏丶小浅:BAAALgADCgcJDAAAAA==.',
['夏色']='夏色吹雪:BAAALgADCgEJAQAAAA==.',
['夜君']='夜君:BAABLgAFFH8GAAIIAAMJ1gixJgDkAAAIAAMJ1gixJgDkAAAAAA==.',
['夜空']='夜空之歌:BAAALgAECgEJAQAAAA==.',
['大兵']='大兵之恋:BAAALgADCgMJAwAAAA==.',
['天使']='天使爱人间:BAAALgAECgMJBQAAAA==.',
['好运']='好运的妃妃:BAAALgADCgUJBQAAAA==.',
['如沐']='如沐清风:BAAALgADCgUJBQAAAA==.',
['宴影']='宴影:BAAALgAECgYJCwAAAA==.',
['寅汐']='寅汐:BAAALgAECgQJCQAAAA==.',
['小狐']='小狐未济:BAAALgAECgQJBAAAAA==.',
['小盆']='小盆友参上:BAAALgAECgcJDAAAAA==.',
['小鸟']='小鸟小德:BAAALgADCgIJAgAAAA==.',
['少女']='少女的脸红:BAAALgADCgcJBwAAAA==.',
['尼古']='尼古拉撕死骑:BAAALgAECgIJAgAAAA==.',
['崔克']='崔克西:BAAALgAFFAEJAQAAAA==.',
['巍之']='巍之松:BAAALgAECggJCAAAAA==.',
['川大']='川大统领:BAAALgAECgUJBQAAAA==.',
['帅气']='帅气大兵:BAAALgADCgQJBQAAAA==.',
['幽寂']='幽寂:BAACLgAFFH8NAAIJAAQJPCQPBQCZAQAJAAQJPCQPBQCZAQAuAAQKfx4AAwkACAlrI20DADQDAAkACAlrI20DADQDAAoAAQnlA2+EACwAAAAA.',
['律翎']='律翎:BAAALgAECgIJAgAAAA==.',
['微笑']='微笑的廸妮莎:BAAALgADCgMJAwAAAA==.',
['心复']='心复酥:BAAALgAECgIJAwAAAA==.',
['念念']='念念丶:BAAALgADCgQJBAAAAA==.',
['恶魔']='恶魔小婷:BAAALgADCgMJAwAAAA==.',
['我不']='我不是步兵:BAAALgAECgEJAQAAAA==.',
['我们']='我们还行吧:BAAALgAECgEJAQAAAA==.',
['我的']='我的刀盾:BAAALgAECgYJBgAAAA==.',
['戒律']='戒律牧:BAAALgADCgQJBAAAAA==.',
['战魔']='战魔牛:BAAALgAECgYJEQAAAA==.',
['手旺']='手旺先锋丶:BAAALgAECgEJAQAAAA==.',
['执子']='执子之魂:BAAALgAECgYJBgAAAA==.',
['扯淡']='扯淡的态度:BAAALgADCgUJBQAAAA==.',
['摩瑞']='摩瑞亚:BAAALgAECgcJDAAAAA==.',
['放开']='放开那姑娘:BAAALgAECgEJAQAAAA==.',
['敏菲']='敏菲利亚:BAAALgAECgQJCAAAAA==.',
['新垣']='新垣结依:BAAALgAECgMJAwAAAA==.',
['无名']='无名异端:BAAALgAECgkJCAAAAA==.',
['明月']='明月:BAAALgAFFAEJAQAAAA==.',
['星河']='星河甜栀:BAACLgAFFH8KAAILAAQJNBsAAwBUAQALAAQJNBsAAwBUAQAuAAQKfxYAAgsACAn6H+4LAM8CAAsACAn6H+4LAM8CAAAA.',
['星辰']='星辰之月:BAAALgAECgcJCAAAAA==.星辰之秋:BAAALgAECgcJBwAAAA==.',
['昨夜']='昨夜星辰不离:BAAALgAECgcJBwAAAA==.',
['暗夜']='暗夜大兵:BAAALgAECgQJBAAAAA==.暗夜幽灵:BAAALgAECgQJBAAAAA==.暗夜战神:BAAALgAECgQJBwAAAA==.',
['暮色']='暮色苍狼:BAAALgAECgMJAwAAAA==.',
['月夕']='月夕江:BAAALgAECgMJBQAAAA==.',
['月影']='月影星痕:BAAALgADCgEJAQAAAA==.',
['月色']='月色:BAAALgAECggJEQABLgAFFAgJHgAHAOEdAA==.',
['有生']='有生之莲:BAAALgAECgEJAgAAAA==.',
['木谷']='木谷石:BAAALgADCgYJBgAAAA==.',
['杀戮']='杀戮之末:BAAALgADCgMJAwAAAA==.',
['柴郡']='柴郡喵:BAABLgAECn8bAAIMAAgJew1mNACyAQAMAAgJew1mNACyAQAAAA==.',
['树的']='树的苗:BAAALgAFFAEJAQAAAA==.',
['桐桐']='桐桐和阿童木:BAAALgAECgEJAQAAAA==.',
['梅西']='梅西:BAAALgADCgcJBgAAAA==.',
['楠萌']='楠萌部落丫头:BAAALgADCgEJAQAAAA==.',
['武大']='武大爷:BAAALgADCgEJAQAAAA==.',
['水官']='水官解厄:BAAALgADCgcJBwABLgAFFAIJAwABAAAAAA==.',
['氵小']='氵小西瓜味儿:BAAALgAECgEJAQAAAA==.',
['沉鱼']='沉鱼落雁丶:BAAALgADCgMJAwAAAA==.',
['沙音']='沙音:BAAALgAECggJDAAAAA==.',
['没我']='没我不行:BAABLgAFFH8GAAMNAAMJ8woFEQDLAAANAAMJ8woFEQDLAAAOAAEJqA0/MwBQAAAAAA==.',
['法盲']='法盲:BAAALgAECgYJDwAAAA==.',
['活的']='活的紫色仙子:BAAALgAECgMJAwAAAA==.',
['浅浅']='浅浅的小熊:BAAALgADCgcJBwAAAA==.',
['淘气']='淘气的爸爸:BAAALgAECgMJAwAAAA==.',
['深渊']='深渊宸:BAAALgAECgUJCwAAAA==.',
['清风']='清风有信:BAAALgADCgEJAQAAAA==.',
['渊狱']='渊狱火:BAAALgADCgUJBQAAAA==.',
['温暖']='温暖的小熊:BAABLgAFFH8IAAIPAAQJNxeOAwBkAQAPAAQJNxeOAwBkAQABLgAFFAUJBQAQAOsQAA==.',
['满穗']='满穗:BAAALgADCgcJDAAAAA==.',
['灬之']='灬之舞:BAAALgAECgEJAQAAAA==.',
['灬魅']='灬魅生灬:BAAALgADCgYJCwAAAA==.',
['灾音']='灾音:BAAALgADCgEJAQAAAA==.',
['熊小']='熊小胖:BAAALgADCgcJBwAAAA==.',
['爱夏']='爱夏:BAAALgAECgUJBQAAAA==.',
['狂暴']='狂暴战:BAAALgAECgIJAgAAAA==.',
['狂野']='狂野囚徒:BAAALgAECgYJBAAAAA==.',
['狸叽']='狸叽米:BAAALgAECgYJBgAAAA==.',
['狸追']='狸追丶:BAAALgAECgUJBQAAAA==.',
['猪彬']='猪彬彬:BAAALgAECgEJAQAAAA==.',
['琥珀']='琥珀年华:BAAALgAECgUJBQAAAA==.',
['疏影']='疏影残月:BAAALgAECggJAQAAAA==.',
['白水']='白水豆腐:BAAALgAECgYJDwAAAA==.',
['白色']='白色苍狼:BAAALgADCgMJAwAAAA==.',
['看看']='看看了:BAAALgADCgMJAwAAAA==.',
['知世']='知世:BAABLgAFFH8IAAIIAAUJfxSNEQBXAQAIAAUJfxSNEQBXAQAAAA==.',
['矮市']='矮市晚苗:BAAALgAECgMJAwAAAA==.',
['破碎']='破碎吧凛酱:BAAALgADCgEJAQAAAA==.',
['神圣']='神圣缪夫:BAAALgAECgEJAQAAAA==.',
['祢豆']='祢豆子:BAAALgAECgYJBgAAAA==.',
['第八']='第八日的蝉:BAAALgAECgEJAwAAAA==.',
['糖门']='糖门丨:BAAALgADCgQJBAAAAA==.',
['紫式']='紫式部:BAAALgAFFAEJAgAAAA==.',
['紫苏']='紫苏:BAACLgAFFH8NAAMRAAQJcBYGBABfAQARAAQJcBYGBABfAQAFAAEJowLOLAA/AAAuAAQKfxQAAxEABwn0HQAkAC4CABEABwl2HQAkAC4CAAUAAwkhFPpkAKwAAAAA.',
['红太']='红太浪:BAAALgADCgUJCAAAAA==.',
['红红']='红红的小熊:BAABLgAFFH8HAAISAAQJwBtJAAB/AQASAAQJwBtJAAB/AQABLgAFFAUJBQAQAOsQAA==.',
['红魔']='红魔馨慧:BAAALgAECggJAQAAAA==.',
['结实']='结实的五花肉:BAAALgADCgQJBAAAAA==.',
['绣冬']='绣冬:BAAALgAECgYJBwAAAA==.',
['美丽']='美丽的倩:BAABLgAFFH8GAAITAAMJRxABEADiAAATAAMJRxABEADiAAAAAA==.',
['美洋']='美洋洋桑:BAAALgADCgIJAgAAAA==.',
['老男']='老男人:BAAALgAECgUJBQAAAA==.',
['自己']='自己人:BAAALgAECgEJAQAAAA==.',
['艾司']='艾司唑仑:BAAALgAECgkJCQAAAA==.',
['芥末']='芥末绿:BAAALgADCgEJAQAAAA==.',
['草稿']='草稿抄了:BAAALgAECgEJAQAAAA==.',
['莉莉']='莉莉:BAABLgAECn8bAAIOAAgJciDtFwDZAgAOAAgJciDtFwDZAgAAAA==.莉莉雅:BAAALgADCgcJBwAAAA==.莉莉雨:BAAALgAECgUJBQAAAA==.',
['莉迪']='莉迪亚:BAAALgAECgIJAgAAAA==.',
['莎士']='莎士比亚:BAAALgADCgEJAQAAAA==.',
['菲比']='菲比酒佬:BAAALgAECgIJAgAAAA==.菲比酒保:BAAALgADCgUJBQAAAA==.',
['萨拉']='萨拉托加:BAAALgAECgYJCgAAAA==.',
['落雨']='落雨飘飘:BAAALgAECgcJDQAAAA==.',
['薄暮']='薄暮:BAAALgADCgUJBQAAAA==.',
['行者']='行者无界:BAAALgAECgYJBQAAAA==.',
['西子']='西子挽轻纱:BAAALgADCgEJAQAAAA==.',
['西尔']='西尔维亚:BAAALgADCgEJAQAAAA==.',
['西门']='西门哥哥:BAAALgADCgUJBQAAAA==.',
['角海']='角海:BAAALgAFFAEJAQAAAA==.',
['豆丫']='豆丫:BAAALgAECgYJDgAAAA==.',
['起司']='起司猫:BAAALgAECgUJCgAAAA==.',
['轩辕']='轩辕凤:BAAALgAECgMJAwAAAA==.',
['轻舞']='轻舞的雏田:BAAALgAECgYJBgAAAA==.',
['达克']='达克尼斯:BAAALgAECgYJCAAAAA==.',
['迷梦']='迷梦沉沦:BAAALgAECgcJCQAAAA==.',
['那个']='那个奶德:BAAALgAECgEJAgAAAA==.那个暗牧:BAAALgAECgEJAQAAAA==.那个毁伤贼:BAAALgAECgEJAgAAAA==.',
['重新']='重新来过:BAAALgADCgEJAQAAAA==.',
['锦绣']='锦绣之曳:BAAALgAECgEJAQAAAA==.',
['長耳']='長耳朵:BAAALgAECgEJAgAAAA==.',
['队长']='队长别开槍:BAAALgADCgIJAgAAAA==.',
['陆军']='陆军:BAAALgAECgYJDQAAAA==.',
['随地']='随地大小变:BAAALgAECgMJAwAAAA==.',
['雷钢']='雷钢须世理:BAAALgAECgUJCQAAAA==.',
['震泽']='震泽:BAAALgAECgIJAgAAAA==.',
['风里']='风里雨里丶:BAAALgAECgQJBAAAAA==.',
['飞早']='飞早:BAAALgAECgEJAQAAAA==.',
['飞霄']='飞霄:BAAALgADCgEJAQAAAA==.',
['饮月']='饮月君:BAAALgAECgIJAgAAAA==.',
['马莲']='马莲尼娅:BAABLgAECn8ZAAIIAAcJFhivQQAIAgAIAAcJFhivQQAIAgAAAA==.',
['魂灬']='魂灬舞:BAABLgAECn8TAAIIAAgJrheZMwA+AgAIAAgJrheZMwA+AgAAAA==.',
['鲜榨']='鲜榨紫薯汁:BAAALgAECgYJBwAAAA==.',
['黑塞']='黑塞船长:BAAALgAECgUJCAAAAA==.',
['默然']='默然毁毁:BAAALgAECgEJAgAAAA==.',
['龍火']='龍火琉璃:BAAALgAECgEJAQAAAA==.',
['龙之']='龙之骄子:BAABLgAECn8UAAMUAAYJZA4hVQBWAQAUAAYJZA4hVQBWAQAVAAQJoQfyJQC+AAAAAA==.',
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
