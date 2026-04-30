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

local lookup = {'Paladin-Retribution','Mage-Frost','Unknown-Unknown','Evoker-Augmentation','Monk-Brewmaster','Evoker-Devastation','Shaman-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Druid-Guardian','Druid-Balance','DeathKnight-Unholy','Druid-Restoration','Priest-Holy',}
local provider = {region='CN',realm='索拉丁',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alexbomm:BAAALgAECgQJBAAAAA==.',
An='Anthea:BAAALgAECgYJDAAAAA==.',
Ca='Captain:BAAALgAFFAQJBAAAAA==.',
Fl='Flamehaze:BAAALgAECgYJBgAAAA==.',
Gp='Gpower:BAAALgAECgcJCAAAAA==.',
He='Helius:BAAALgAECgIJAgAAAA==.',
Hy='Hygeia:BAAALgADCgIJAgAAAA==.',
Ic='Icelancing:BAAALgAECgYJCgAAAA==.',
Le='Leap:BAAALgADCgYJBwAAAA==.',
Lu='Lu:BAAALgADCgUJBQAAAA==.Luda:BAAALgAFFAEJAQAAAA==.',
Na='Narcisse:BAAALgAECgYJCwAAAA==.',
Ni='Nier:BAAALgAECgEJAQAAAA==.',
No='Noble:BAAALgADCgMJCQAAAA==.',
Pl='Playerldfpwf:BAAALgAECgYJBgAAAA==.',
Pr='Promising:BAAALgAECgkJCQAAAA==.Prosperityek:BAAALgAECgMJBQAAAA==.Prrodigal:BAAALgAFFAIJBAAAAA==.',
Ry='Ryze:BAAALgAECgIJAgAAAA==.',
Sp='Spirite:BAAALgAECgYJDwAAAA==.',
Vo='Voyktt:BAAALgAECgYJBgAAAA==.',
['一昕']='一昕哥一:BAAALgADCgMJAwAAAA==.',
['一箭']='一箭穿心:BAAALgAECgYJDAAAAA==.',
['七夜']='七夜晓晓圣君:BAAALgAECggJCwAAAA==.',
['三房']='三房印象:BAAALgAECgYJBgAAAA==.',
['上古']='上古饕餮聖騎:BAAALgAECgYJCAAAAA==.',
['乐在']='乐在琦中:BAAALgAECgYJBgAAAA==.',
['乔尼']='乔尼娜碧扬:BAAALgAECgUJBQAAAA==.',
['乖乖']='乖乖龙地咚:BAAALgAECgYJCQAAAA==.',
['九月']='九月:BAAALgADCgYJBgAAAA==.',
['二月']='二月六日:BAAALgADCgMJAwAAAA==.',
['二班']='二班同学:BAABLgAECn8UAAIBAAcJyxflSQAFAgABAAcJyxflSQAFAgAAAA==.',
['人牛']='人牛逼还美丽:BAAALgADCgcJBwAAAA==.',
['今天']='今天又起早了:BAAALgADCgUJBQAAAA==.',
['以德']='以德扶人:BAAALgAECgUJBQAAAA==.',
['伊笑']='伊笑泯恩仇:BAAALgAECgcJDwAAAA==.',
['佐藤']='佐藤利奈丶:BAAALgAECgQJBQAAAA==.',
['佛法']='佛法无边无级:BAACLgAFFH8FAAICAAUJDhgLCABtAQACAAUJDhgLCABtAQAuAAQKfxwAAgIACAlUIfUZABADAAIACAlUIfUZABADAAAA.',
['你在']='你在这养鱼呢:BAAALgAECgEJAQABLgAFFAQJAgADAAAAAA==.',
['使徒']='使徒丨行者:BAAALgADCgEJAQAAAA==.',
['依然']='依然丶魔君灬:BAAALgAECgMJBAAAAA==.',
['信德']='信德维拉:BAAALgAFFAEJAQABLgAFFAUJEAAEAB0cAA==.',
['光明']='光明圣十字軍:BAAALgADCgIJAgAAAA==.',
['关于']='关于小熊:BAAALgAECgQJBAAAAA==.',
['兽头']='兽头骨气:BAAALgAFFAEJAQAAAA==.',
['冥殇']='冥殇收集者:BAAALgADCggJCAAAAA==.',
['冰美']='冰美式灬貓貓:BAAALgAECgcJBwAAAA==.',
['冰风']='冰风婆婆:BAAALgAECgcJDQAAAA==.',
['刘大']='刘大锤:BAAALgAECgYJDwAAAA==.',
['初露']='初露青提:BAABLgAFFH8GAAICAAMJehUlKQAPAQACAAMJehUlKQAPAQAAAA==.',
['别逼']='别逼我:BAAALgAECgEJAQAAAA==.',
['刺客']='刺客冰心:BAAALgADCgEJAQAAAA==.',
['勥氼']='勥氼慸:BAAALgAECgcJDwAAAA==.',
['半吨']='半吨:BAAALgAECgEJAQAAAA==.',
['卡莲']='卡莲娜:BAAALgAECgYJCgAAAA==.',
['叮咚']='叮咚咚叮:BAAALgAECgYJCAAAAA==.',
['叮噹']='叮噹丶转圈圈:BAAALgADCgEJAQAAAA==.',
['叶辰']='叶辰:BAAALgAECgcJDgAAAA==.',
['叹半']='叹半世浮华:BAAALgAECgQJBQAAAA==.',
['叹菀']='叹菀:BAAALgAECgEJAQAAAA==.',
['吃了']='吃了莓:BAAALgAECgYJBgAAAA==.',
['吉梨']='吉梨德咧:BAAALgAECgYJCwAAAA==.吉梨窕冥:BAAALgAECgMJAwAAAA==.',
['同志']='同志仍需努力:BAAALgAECgMJAwAAAA==.',
['呀哈']='呀哈哈:BAAALgAECgQJBAAAAA==.',
['周末']='周末到河北:BAAALgADCgEJAQAAAA==.',
['咕噜']='咕噜牙牙:BAAALgAECgUJDAAAAA==.',
['哈哈']='哈哈嗨:BAABLgAFFH8GAAIFAAMJlxB6EwDdAAAFAAMJlxB6EwDdAAAAAA==.',
['哭泣']='哭泣希神:BAAALgAECgIJAgAAAA==.哭泣杀神:BAAALgAECgEJAQAAAA==.哭泣菜神:BAAALgAECgMJAwAAAA==.',
['哴偲']='哴偲咩語:BAAALgADCgYJBgAAAA==.',
['啥都']='啥都不缺:BAAALgAECgYJDAAAAA==.',
['嗜杀']='嗜杀冥皇:BAABLgAECn8YAAICAAcJhBdVcgDvAQACAAcJhBdVcgDvAQAAAA==.',
['国宝']='国宝壹号:BAAALgAFFAIJAgAAAA==.',
['土拨']='土拨鼠哑巴了:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光的魔女:BAAALgAECgcJBwAAAA==.圣光重生:BAAALgAECgIJAgAAAA==.',
['在燃']='在燃烧的天空:BAAALgAECgQJBQAAAA==.',
['塔奇']='塔奇可码:BAAALgAECgcJCQAAAA==.',
['塔玛']='塔玛西亚:BAAALgAECgIJBAAAAA==.',
['墨筑']='墨筑:BAAALgADCgEJAQAAAA==.',
['壹貮']='壹貮貮零:BAAALgAECgYJBgAAAA==.',
['夏末']='夏末梧桐:BAAALgADCgEJAQAAAA==.',
['大喵']='大喵使者:BAAALgAECgEJAgAAAA==.',
['大地']='大地战骑:BAAALgAECgkJCAAAAA==.',
['大宝']='大宝和胖胖:BAAALgADCgIJAgAAAA==.',
['大明']='大明一狂徒:BAAALgAECgUJBQAAAA==.',
['大肉']='大肉蚌:BAAALgAECgYJBgAAAA==.',
['天圣']='天圣隼:BAAALgAECgYJCwAAAA==.',
['天天']='天天锤胖子:BAAALgAECgYJBgAAAA==.天天锤龙术:BAAALgAECgcJBwAAAA==.',
['天涯']='天涯一根草:BAAALgADCgEJAgAAAA==.',
['天降']='天降之物:BAAALgAECgYJDAAAAA==.',
['失心']='失心:BAAALgAECgYJCgAAAA==.',
['奥德']='奥德飙:BAABLgAFFH8IAAICAAQJZQ2fDABSAQACAAQJZQ2fDABSAQAAAA==.奥德飙拉香蕉:BAACLgAFFH8IAAICAAQJBAzqHQBTAQACAAQJBAzqHQBTAQAuAAQKfxoAAgIACQkLGiYuALkCAAIACQkLGiYuALkCAAAA.',
['奥蕾']='奥蕾利亚:BAAALgAECgEJAgAAAA==.',
['婉清']='婉清:BAAALgAECgYJCQAAAA==.',
['宁远']='宁远:BAAALgAECgcJEwAAAA==.',
['实心']='实心:BAAALgAECgQJBwAAAA==.',
['密斯']='密斯忒琪:BAAALgADCgYJBgAAAA==.',
['对我']='对我说慌试试:BAAALgADCgMJAwAAAA==.',
['小丨']='小丨猎丨人丨:BAAALgAECgEJAQAAAA==.',
['小圣']='小圣君:BAAALgAFFAEJAQAAAA==.',
['小小']='小小水月:BAAALgADCgYJBgAAAA==.小小萨满:BAAALgAECgYJEwAAAA==.',
['小尐']='小尐:BAAALgADCgIJAgAAAA==.',
['小尒']='小尒:BAAALgADCgIJAgAAAA==.',
['小巷']='小巷俏佳人:BAAALgAECgEJAQAAAA==.',
['小熊']='小熊领主:BAAALgAECgYJBgAAAA==.',
['小米']='小米锅巴:BAAALgAECgUJCgAAAA==.',
['小菜']='小菜依蝶:BAAALgAECgcJBwAAAA==.',
['小蛋']='小蛋挞:BAAALgADCgEJAQAAAA==.',
['小龙']='小龙馒头:BAAALgAECgIJAgAAAA==.',
['年糕']='年糕:BAAALgAECgIJAgAAAA==.年糕丶:BAAALgAECgUJCgAAAA==.',
['幻缘']='幻缘:BAAALgAFFAEJAQAAAA==.',
['幽漓']='幽漓:BAAALgADCgkJCQAAAA==.',
['廾血']='廾血騎歸來廾:BAAALgADCgQJBQAAAA==.',
['开朗']='开朗的哈里斯:BAACLgAFFH8QAAMEAAUJHRyHCABlAQAEAAQJHRyHCABlAQAGAAIJzQmiBgClAAAuAAQKfycAAwQACQlpHgEFADsDAAQACQnhHQEFADsDAAYABglcII0OAPEBAAAA.',
['往者']='往者已矣:BAAALgAECgYJEgAAAA==.',
['德萨']='德萨司:BAABLgAECn8VAAIHAAcJfRGJPwCCAQAHAAcJfRGJPwCCAQAAAA==.',
['恋旧']='恋旧:BAAALgADCgEJAQAAAA==.',
['惠子']='惠子姐:BAAALgADCgIJAgAAAA==.',
['想你']='想你了牢大哥:BAAALgAECgYJBgAAAA==.',
['我叫']='我叫一百六:BAAALgAECgkJCQAAAA==.',
['我愛']='我愛申有娜:BAAALgAFFAEJAQAAAA==.',
['我是']='我是蛆来的:BAAALgAECgQJBwAAAA==.',
['我来']='我来组成臀部:BAAALgAECgkJEAAAAA==.',
['托洛']='托洛西:BAAALgAFFAEJAQAAAA==.',
['扬手']='扬手春落手秋:BAAALgAFFAIJAwAAAA==.',
['承承']='承承小可爱:BAAALgADCgUJBQAAAA==.',
['拉贵']='拉贵尔昔拉:BAAALgAECgYJDAAAAA==.',
['拯救']='拯救苍生:BAAALgAECgYJDAAAAA==.',
['挽清']='挽清风:BAAALgADCgEJAgAAAA==.',
['排骨']='排骨大叔:BAABLgAECn8eAAMIAAcJDhbzOQDHAQAIAAYJNBXzOQDHAQAJAAcJShNzNACXAQAAAA==.',
['搜狐']='搜狐:BAAALgAFFAEJAQAAAA==.',
['搞七']='搞七捻三:BAABLgAECn8VAAICAAcJ4hAMnwCYAQACAAcJ4hAMnwCYAQAAAA==.',
['攬月']='攬月:BAAALgADCgIJAgAAAA==.',
['放开']='放开那胖德:BAAALgADCgUJBQAAAA==.',
['故事']='故事的小黃花:BAAALgADCgEJAQAAAA==.',
['断罪']='断罪之翼:BAAALgAECgcJEAABLgAFFAUJBQACAA4YAA==.',
['无敌']='无敌暴龙兽:BAAALgAECgEJAQAAAA==.',
['星辰']='星辰丶逐夜:BAAALgAECgEJAgAAAA==.',
['春天']='春天里的小德:BAAALgAECgYJDAAAAA==.',
['晨曦']='晨曦雨露:BAAALgAECgUJBQAAAA==.',
['暖阳']='暖阳洋:BAAALgADCgEJAQAAAA==.',
['暮光']='暮光之珵:BAAALgAECgcJCAAAAA==.暮光之莐:BAAALgAECgYJCwAAAA==.',
['書心']='書心墨韵:BAAALgAECgIJAgAAAA==.',
['月光']='月光杀神:BAAALgAECgMJBAAAAA==.',
['月影']='月影無雙:BAAALgAFFAEJAQAAAA==.',
['木野']='木野真琴:BAABLgAECn8ZAAIKAAcJZgYZJwAGAQAKAAcJZgYZJwAGAQAAAA==.',
['机电']='机电实物:BAAALgAECgYJBgAAAA==.',
['杭州']='杭州刘德华:BAAALgAECgEJAgAAAA==.',
['极品']='极品狼王:BAAALgAFFAEJAQAAAA==.',
['楚天']='楚天歌:BAABLgAECn8ZAAICAAYJyyFnUQBDAgACAAYJyyFnUQBDAgAAAA==.',
['橙芯']='橙芯橙忆:BAAALgADCgEJAQAAAA==.',
['歐萊']='歐萊雅:BAAALgADCgEJAQAAAA==.',
['残缺']='残缺依斑娜:BAAALgAECgUJBQABLgAFFAIJAwADAAAAAA==.残缺依班娜:BAAALgAFFAIJAwAAAA==.',
['毛球']='毛球卡皮巴拉:BAABLgAECn8ZAAMLAAcJUhHiFAAjAQAMAAcJahDgNQBlAQALAAcJlw3iFAAjAQAAAA==.',
['水之']='水之心圣:BAAALgAECgYJBwAAAA==.',
['水翦']='水翦影:BAAALgAECgEJAQAAAA==.',
['水蓝']='水蓝色眼睛:BAAALgADCgEJAgAAAA==.',
['沁渊']='沁渊:BAAALgAECgYJEQAAAA==.',
['没想']='没想好叫什么:BAAALgAECgUJBQAAAA==.',
['油豆']='油豆腐:BAAALgAECgYJBgAAAA==.',
['法神']='法神天使:BAAALgADCgIJAgAAAA==.',
['泥虫']='泥虫脆柿红蛋:BAAALgADCgIJAgAAAA==.',
['洋洋']='洋洋宝贝:BAAALgADCgEJAQAAAA==.',
['流响']='流响出疏桐:BAAALgADCgEJAQAAAA==.',
['淘浆']='淘浆糊:BAAALgAECgYJEQAAAA==.',
['清音']='清音雅月:BAAALgAECgYJBgAAAA==.',
['渐渐']='渐渐被你吸引:BAAALgAECgEJAQAAAA==.',
['湛蓝']='湛蓝星空:BAAALgAECgUJCQAAAA==.湛蓝色的苍穹:BAAALgAECgUJBwAAAA==.湛蓝苍穹:BAAALgAECgEJAQAAAA==.',
['溪魃']='溪魃:BAAALgAECgEJAQAAAA==.',
['漓卿']='漓卿:BAAALgAECgcJBwAAAA==.',
['灬酒']='灬酒仙熊猫灬:BAAALgAECgkJCQABLgAFFAYJDgAEAEIXAA==.',
['灰太']='灰太狼我扁你:BAAALgAFFAEJAQAAAA==.',
['灰色']='灰色的魔女:BAAALgAECgcJDgAAAA==.',
['爱吃']='爱吃小米粥:BAAALgAECgMJAgAAAA==.',
['爱情']='爱情海的港湾:BAAALgAECgUJBQAAAA==.',
['狂魔']='狂魔战狼:BAAALgAECggJEgAAAA==.',
['狗不']='狗不玩我玩:BAAALgADCgUJBQAAAA==.',
['猪肚']='猪肚鸡:BAAALgAFFAEJAQAAAA==.',
['玉米']='玉米:BAAALgAECgQJBAAAAA==.',
['由月']='由月与地:BAAALgAECgYJCwAAAA==.',
['白薠']='白薠:BAAALgAECgYJCgAAAA==.',
['百倍']='百倍速的污:BAAALgAECgEJAQAAAA==.',
['神劍']='神劍御雷真訣:BAAALgAECgQJBAAAAA==.',
['福瑞']='福瑞古德:BAAALgAECgkJCQAAAA==.',
['秋水']='秋水落霞:BAAALgAECgIJAwAAAA==.',
['粑粑']='粑粑打麻麻:BAAALgAECgQJBAAAAA==.',
['紫色']='紫色舞蹈生:BAAALgADCgYJCwAAAA==.',
['緣語']='緣語軒:BAAALgADCgYJBgAAAA==.',
['红龙']='红龙:BAAALgAECgYJCQAAAA==.',
['纯洁']='纯洁的团花咪:BAAALgADCgEJAQAAAA==.',
['给你']='给你一角:BAAALgAECgQJBAAAAA==.',
['给我']='给我滚远点:BAAALgAECgMJAwAAAA==.',
['绷带']='绷带灬:BAAALgAECgIJAgAAAA==.',
['绿豆']='绿豆苍蝇:BAAALgAFFAEJAQAAAA==.',
['羊肉']='羊肉藏在书里:BAAALgAECgcJCgAAAA==.',
['耂王']='耂王爱你哦:BAAALgAECgYJCAAAAA==.',
['聚散']='聚散如沙:BAAALgAECgQJBgAAAA==.',
['股神']='股神左安龙:BAAALgAECgcJDAAAAA==.',
['自伤']='自伤无色:BAACLgAFFH8QAAICAAUJjBoQCwDFAQACAAUJjBoQCwDFAQAuAAQKfycAAgIACQm2H1kTADQDAAIACQm2H1kTADQDAAAA.',
['自在']='自在之物:BAAALgAECgUJBQAAAA==.',
['至始']='至始至终:BAAALgAECgkJBwAAAA==.',
['致命']='致命呼吸:BAAALgAECgQJDQAAAA==.',
['芈苏']='芈苏:BAAALgAECgEJAQAAAA==.',
['花开']='花开浅陌丶:BAAALgAFFAEJAQAAAA==.',
['荼蘼']='荼蘼微凉:BAAALgAECgYJDAAAAA==.',
['莫失']='莫失莫忘:BAAALgAECgEJAQAAAA==.',
['菊花']='菊花毁灭者:BAABLgAFFH8FAAINAAIJlhPfPgCiAAANAAIJlhPfPgCiAAAAAA==.',
['萌萌']='萌萌的小欢子:BAAALgAECgIJAgAAAA==.',
['萨幔']='萨幔:BAAALgAECgQJBAAAAA==.',
['萨神']='萨神:BAAALgAECgYJEgAAAA==.',
['落落']='落落的小跟班:BAAALgADCgUJBQAAAA==.',
['蓝凤']='蓝凤皇:BAAALgADCgEJAQAAAA==.',
['蓝水']='蓝水晶天使:BAAALgADCgEJAgAAAA==.',
['蓝色']='蓝色体育生:BAAALgAECgMJAwAAAA==.',
['蓝鳯']='蓝鳯皇:BAAALgAECgQJBwAAAA==.',
['蓝鳳']='蓝鳳凰:BAAALgAECgQJBAAAAA==.',
['薄肌']='薄肌男模:BAAALgADCgIJAgAAAA==.',
['血色']='血色残骸:BAAALgADCgYJBgAAAA==.',
['被風']='被風熄滅:BAAALgAFFAIJAgABLgAFFAQJBAADAAAAAA==.',
['谪世']='谪世黯天使:BAAALgAECgYJBgAAAA==.',
['贝璐']='贝璐酱:BAAALgAECggJEwAAAA==.',
['贤者']='贤者里奥:BAAALgAECgQJBAAAAA==.',
['赛博']='赛博佛祖:BAAALgADCgEJAQAAAA==.',
['赞美']='赞美圣光丶:BAAALgAECgYJBgAAAA==.赞美圣光吧:BAAALgAECgUJBgAAAA==.',
['赢麻']='赢麻的特郎普:BAAALgADCgEJAQABLgAFFAUJEAAEAB0cAA==.',
['软果']='软果果:BAAALgADCgEJAQAAAA==.',
['辰时']='辰时舞:BAAALgAECgEJBAAAAA==.',
['迟到']='迟到的幸福:BAAALgADCggJCAAAAA==.',
['迪皮']='迪皮诶斯:BAACLgAFFH8FAAIMAAMJowU0CQDPAAAMAAMJowU0CQDPAAAuAAQKfxQAAwwACQlzGDsMAEcBAAwABwkDFDsMAEcBAA4ACQmJAhZpABgBAAAA.',
['速溶']='速溶咖啡:BAAALgAECgEJAgAAAA==.',
['道法']='道法自然:BAAALgAECgQJBAAAAA==.',
['那个']='那个近战奶骑:BAAALgAECgIJAgAAAA==.',
['长崎']='长崎术土:BAAALgAECgYJCAABLgAFFAEJAQADAAAAAA==.',
['闳都']='闳都:BAAALgAECgkJAQAAAA==.',
['阿呜']='阿呜喵:BAAALgADCgkJCQAAAA==.',
['阿小']='阿小爸:BAAALgAECgEJAgAAAA==.',
['阿尓']='阿尓托莉雅:BAAALgAECgUJCQAAAA==.',
['阿尔']='阿尔孝斯:BAAALgAECgEJAQAAAA==.阿尔忒米斯:BAAALgAECgYJDAAAAA==.',
['阿晓']='阿晓:BAAALgADCgUJCAAAAA==.',
['阿释']='阿释密达:BAAALgAECgUJBQAAAA==.',
['隐遁']='隐遁战吊:BAAALgAECgEJAQAAAA==.',
['雷鸣']='雷鸣八卦:BAAALgAECgYJEwAAAA==.',
['霎时']='霎时花再开:BAAALgAECgQJBAAAAA==.',
['霜冷']='霜冷九洲:BAAALgAECgYJBwAAAA==.',
['魔法']='魔法少女阿之:BAAALgAECgEJAQAAAA==.',
['魔鬼']='魔鬼咬巫婆:BAABLgAECn8kAAIPAAkJ0R6kAAALAwAPAAkJ0R6kAAALAwAAAA==.',
['鸭梨']='鸭梨球:BAAALgAFFAEJAQAAAA==.',
['黄豆']='黄豆汤:BAAALgADCgUJBQAAAA==.',
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
