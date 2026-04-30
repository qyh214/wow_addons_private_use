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

local lookup = {'DeathKnight-Unholy','Unknown-Unknown','Warrior-Arms','DeathKnight-Blood','Warlock-Destruction','Warlock-Affliction','Paladin-Retribution','Druid-Balance','Mage-Frost','Monk-Mistweaver','Monk-Brewmaster','Warlock-Demonology','Paladin-Holy','Priest-Discipline','DemonHunter-Devourer','Warrior-Fury','Hunter-Survival','Hunter-Marksmanship','Shaman-Restoration','Shaman-Elemental',}
local provider = {region='CN',realm='恶魔之翼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alexsyh:BAABLgAECn8WAAIBAAYJXxoCbACzAQABAAYJXxoCbACzAQAAAA==.',
Ca='Carryon:BAAALgAECgcJCAAAAA==.',
Da='Dactkiven:BAAALgADCgYJBgAAAA==.',
Dk='Dk:BAACLgAFFH8OAAIBAAQJUBtrKAD2AAABAAQJUBtrKAD2AAAuAAQKfyEAAgEACQlFHTMTAAgDAAEACQlFHTMTAAgDAAAA.',
Fi='Firefang:BAAALgAECgQJBwAAAA==.Fizz:BAAALgAECgUJBQAAAA==.',
Fs='Fs:BAAALgAECgYJBgABLgAFFAQJDgABAFAbAA==.',
Ho='Holy:BAAALgADCgEJAQABLgAFFAEJAQACAAAAAA==.',
Ic='Icaruslin:BAAALgADCgIJAgAAAA==.',
Ka='Kaism:BAAALgAECgkJCgAAAA==.Kashum:BAAALgAECgYJBgAAAA==.',
Mo='Morals:BAAALgAECgIJAgABLgAFFAUJDwADAHwgAA==.',
Na='Nanimomo:BAAALgADCgQJBAAAAA==.',
Ne='Neurobotdh:BAAALgADCgkJEQAAAA==.',
Re='Retten:BAAALgADCgEJAQAAAA==.',
Sa='Saulh:BAAALgAECggJCAAAAA==.',
Su='Sugardoor:BAAALgAFFAEJAQAAAA==.',
Vo='Voidchug:BAAALgADCgcJCAAAAA==.',
We='Weirdoo:BAABLgAECn8WAAIBAAYJrhaIbwCqAQABAAYJrhaIbwCqAQAAAA==.',
Wo='Worldstyle:BAAALgAFFAIJAgAAAA==.',
Ze='Zelieks:BAAALgAECgYJAQAAAA==.',
['Ää']='Ää:BAAALgAFFAIJAgAAAA==.',
['一口']='一口气全念错:BAAALgAECgYJDgAAAA==.',
['一心']='一心为社团:BAAALgAECgEJAQAAAA==.',
['一路']='一路领先:BAAALgAECgYJBgAAAA==.',
['三月']='三月风:BAAALgAECgQJBAAAAA==.',
['不爱']='不爱吃肉:BAAALgAECgYJCwAAAA==.',
['丝之']='丝之歌:BAAALgAECgUJBQAAAA==.',
['两个']='两个上悠亚:BAAALgAECgMJAwAAAA==.',
['丶菠']='丶菠籮油王孒:BAAALgAECgcJDAAAAA==.',
['今天']='今天吃火鸡面:BAAALgAECgEJAgAAAA==.今天吃罗非鱼:BAAALgAECgQJBgAAAA==.',
['停下']='停下了足迹:BAABLgAFFH8LAAMBAAUJpBmmDQBsAQABAAQJpBmmDQBsAQAEAAEJAACSGgAyAAAAAA==.',
['充满']='充满矛盾的鬼:BAACLgAFFH8FAAMFAAIJ5wTCDgCTAAAFAAIJ5wTCDgCTAAAGAAEJ3gOtBgBQAAAuAAQKfxYAAwUACAl2FN8JACICAAUACAl2FN8JACICAAYAAQnHFHEyADgAAAAA.',
['冉冉']='冉冉德:BAAALgAFFAEJAQAAAA==.',
['冥途']='冥途生花:BAAALgAECgEJAwAAAA==.',
['冬絶']='冬絶纱:BAAALgAECgkJCQAAAA==.',
['冰糖']='冰糖糖小番茄:BAAALgAECgMJBQAAAA==.',
['凌乱']='凌乱:BAAALgADCgUJBQAAAA==.',
['十万']='十万嬉皮:BAAALgAECgEJAwAAAA==.',
['单身']='单身奶茶:BAABLgAFFH8HAAIHAAMJNxtmHgCzAAAHAAMJNxtmHgCzAAAAAA==.单身屠夫:BAABLgAFFH8IAAIIAAMJ8BhEDQALAQAIAAMJ8BhEDQALAQAAAA==.',
['卡拉']='卡拉多格:BAAALgAECgcJDQAAAA==.',
['原罪']='原罪:BAAALgADCgYJBgAAAA==.原罪之刃:BAAALgAFFAEJAQAAAA==.',
['叉烧']='叉烧包:BAAALgADCgIJAgAAAA==.',
['叶子']='叶子飘飘:BAAALgAECgEJAQAAAA==.',
['吕布']='吕布:BAAALgAECgEJAQAAAA==.',
['吱呜']='吱呜猪:BAAALgAFFAMJAwAAAA==.',
['呃啊']='呃啊:BAAALgAFFAIJAwAAAA==.',
['唏嘘']='唏嘘的福渣子:BAAALgAECgQJBAAAAA==.',
['嗨呀']='嗨呀打摩丝:BAAALgAECgYJCwAAAA==.',
['四面']='四面楚歌:BAAALgAECgYJDwAAAA==.',
['圣波']='圣波帝:BAAALgAFFAEJAQAAAA==.',
['堺雅']='堺雅人:BAAALgAECgUJCAAAAA==.',
['夏禾']='夏禾星野:BAABLgAECn8cAAIJAAgJaxmVQgBwAgAJAAgJaxmVQgBwAgAAAA==.',
['天尊']='天尊皇胤:BAAALgAECgcJAQAAAA==.',
['天生']='天生牛马:BAAALgADCgYJBgAAAA==.',
['天罚']='天罚之刃:BAAALgAECgUJCQAAAA==.',
['失语']='失语者:BAABLgAFFH8IAAMBAAUJ8hPQDwBiAQABAAQJ8hPQDwBiAQAEAAEJAAD1GgAwAAAAAA==.',
['奥蕾']='奥蕾莉拉:BAAALgAECgEJAQAAAA==.',
['宝宝']='宝宝小牛:BAAALgAFFAQJBAAAAA==.',
['宿醉']='宿醉到天亮:BAAALgADCgYJBgAAAA==.',
['导演']='导演我躺哪丶:BAAALgAECgYJCwAAAA==.',
['小不']='小不讲理:BAAALgADCgEJAQAAAA==.',
['小喵']='小喵豆豆:BAAALgAECgEJAQAAAA==.',
['小龙']='小龙女过儿:BAAALgAECgYJBQAAAA==.',
['尛丶']='尛丶圣光:BAAALgAECgIJAwAAAA==.',
['巨魔']='巨魔女秉晨:BAAALgAECgIJAgAAAA==.',
['张三']='张三:BAAALgADCgUJBQAAAA==.',
['徘徊']='徘徊之影:BAAALgADCgMJAwAAAA==.',
['德西']='德西娅:BAAALgAECgIJAwAAAA==.',
['心语']='心语星愿:BAAALgADCgEJAQAAAA==.',
['快乐']='快乐之纪年:BAAALgAECgEJAQAAAA==.快乐旅行家:BAAALgAECgYJBgAAAA==.',
['忽然']='忽然遇见你:BAABLgAFFH8LAAMBAAUJZBYxDgBqAQABAAQJZBYxDgBqAQAEAAEJAAAXGgA0AAAAAA==.',
['怎么']='怎么回忆我:BAABLgAFFH8JAAMBAAUJzg8gFwBIAQABAAQJzg8gFwBIAQAEAAEJAADbGwAqAAAAAA==.',
['恋上']='恋上月亮:BAAALgAECgYJDwAAAA==.',
['恶魔']='恶魔韭菜:BAAALgAECgEJAQAAAA==.',
['想念']='想念拟人化:BAABLgAFFH8RAAMBAAYJnh6PAQCfAQABAAUJnh6PAQCfAQAEAAEJAADHGgAxAAAAAA==.',
['我在']='我在啊没掉线:BAAALgADCgEJAQAAAA==.',
['我很']='我很大:BAAALgAECgEJAQAAAA==.',
['拿你']='拿你矛戳你盾:BAAALgADCgEJAQAAAA==.',
['摩卡']='摩卡加冰:BAAALgAFFAEJAQAAAA==.',
['摸鱼']='摸鱼拌饭:BAACLgAFFH8OAAIKAAQJLx7vAgBqAQAKAAQJLx7vAgBqAQAuAAQKfx4AAgoABwnNIT8QAFgCAAoABwnNIT8QAFgCAAAA.',
['星狩']='星狩者:BAAALgAECgUJAgAAAA==.',
['星空']='星空追猎者:BAAALgAECgEJAQAAAA==.',
['星辰']='星辰丶丝丝咩:BAAALgAECgYJBgAAAA==.星辰丶云里:BAAALgAECgQJBAAAAA==.星辰丶侠侣:BAABLgAFFH8IAAILAAMJmgjMFQDGAAALAAMJmgjMFQDGAAAAAA==.星辰丶猎魔者:BAAALgAECgQJBAAAAA==.',
['星骓']='星骓:BAAALgAECgQJBQAAAA==.',
['最伟']='最伟大的作品:BAAALgAECgMJBgAAAA==.',
['月咏']='月咏歌呗:BAABLgAFFH8KAAIMAAUJ8xKjFQBAAQAMAAUJ8xKjFQBAAQAAAA==.',
['朝三']='朝三:BAABLgAFFH8OAAMBAAUJHBSkBgBWAQABAAQJHBSkBgBWAQAEAAEJAAAgGwAvAAAAAA==.',
['末代']='末代隐官:BAAALgAFFAEJAQAAAA==.',
['柏卜']='柏卜正:BAAALgAFFAEJAQAAAA==.',
['桂花']='桂花糕:BAABLgAECn8dAAINAAcJbCUvEACSAgANAAcJbCUvEACSAgAAAA==.',
['樱桃']='樱桃贼:BAAALgAFFAMJAwAAAA==.',
['橙心']='橙心丶:BAABLgAFFH8RAAMBAAUJiRjdAwB1AQABAAQJiRjdAwB1AQAEAAEJAADvGgAwAAAAAA==.',
['橙意']='橙意丶:BAABLgAFFH8OAAMBAAUJPxFzFgBKAQABAAQJPxFzFgBKAQAEAAEJAAC/GgAxAAAAAA==.',
['欢乐']='欢乐全家捅:BAAALgAECgYJDAAAAA==.',
['死亡']='死亡的使者:BAAALgAECgUJCQAAAA==.',
['毛胖']='毛胖球:BAABLgAFFH8JAAIOAAUJVSMwAQDjAQAOAAUJVSMwAQDjAQABLgAFFAUJKgAOAP8kAA==.',
['污以']='污以丶类聚:BAAALgAECgYJDQAAAA==.',
['法修']='法修散打:BAAALgAECgEJAQAAAA==.',
['泪飘']='泪飘乱:BAAALgAECgYJAQAAAA==.泪飘散:BAAALgAECgUJDQAAAA==.',
['浩然']='浩然丶之气:BAAALgADCgEJAQAAAA==.浩然之气丶:BAAALgADCgEJAgAAAA==.',
['浮生']='浮生流年:BAAALgAECgkJCQAAAA==.',
['满满']='满满小萨:BAAALgAECgEJAQAAAA==.',
['火不']='火不高兴:BAAALgAECgcJDQAAAA==.',
['火之']='火之乐出翔:BAAALgADCgQJBAAAAA==.火之高兴拌饭:BAAALgAECgEJAQAAAA==.',
['灬辣']='灬辣辣灬:BAABLgAFFH8IAAIPAAQJzhcsDwBVAQAPAAQJzhcsDwBVAQAAAA==.',
['炎灾']='炎灾丶烬:BAAALgAECgQJBAAAAA==.',
['煙殇']='煙殇:BAAALgAFFAEJAQAAAA==.',
['爱吵']='爱吵吵的闹闹:BAAALgAECgEJAQAAAA==.',
['牛奶']='牛奶不外卖:BAAALgADCgEJAQAAAA==.',
['特供']='特供小红鹰:BAAALgAECgcJBwAAAA==.',
['狸沫']='狸沫:BAAALgAECgcJBwAAAA==.',
['王者']='王者嗜血:BAAALgAECgYJCgAAAA==.',
['琦樂']='琦樂无穷:BAAALgAECgcJDgAAAA==.',
['电光']='电光火石丶沐:BAAALgAECgEJAQAAAA==.',
['畫船']='畫船听雨眠:BAAALgAECgEJAQAAAA==.',
['真是']='真是悲剧:BAACLgAFFH8IAAMQAAMJOR69FgCvAAAQAAIJqiG9FgCvAAADAAEJWBfxCgBXAAAuAAQKfxcAAwMABwl8Ic4QAJABABAABgmRGNUuAPUBAAMABAmrIc4QAJABAAAA.',
['眯眼']='眯眼强者美屡:BAACLgAFFH8JAAMRAAMJ1B/ZAQA5AQARAAMJ1B/ZAQA5AQASAAEJ/AabKABKAAAuAAQKfx4AAxEACAlwGtUJAD8CABEACAmYGdUJAD8CABIABQlTFUlBAFIBAAAA.',
['瞑焱']='瞑焱:BAAALgADCgUJBQAAAA==.',
['碗碗']='碗碗热干面:BAAALgAECgIJAgAAAA==.',
['磅丨']='磅丨礴:BAAALgAECgEJAQAAAA==.',
['神拳']='神拳少女酱捏:BAAALgAECgYJBgAAAA==.',
['神棍']='神棍缺心眼:BAAALgAFFAEJAQABLgAFFAMJBwATAMoVAA==.神棍缺牙巴:BAACLgAFFH8HAAITAAMJyhUVDwDvAAATAAMJyhUVDwDvAAAuAAQKfxsAAhMABwnVIVEPAJ4CABMABwnVIVEPAJ4CAAAA.',
['秋葉']='秋葉飛揚:BAAALgAECgYJDAAAAA==.',
['称砣']='称砣:BAAALgADCgYJBgAAAA==.',
['米拉']='米拉朵朵:BAAALgAFFAEJAQAAAA==.',
['类似']='类似流星:BAABLgAFFH8IAAMBAAUJJhUoEABgAQABAAQJJhUoEABgAQAEAAEJAADmGwAqAAAAAA==.',
['糖丶']='糖丶德瑞拉:BAABLgAFFH8IAAINAAMJzA4gEADXAAANAAMJzA4gEADXAAAAAA==.',
['紧急']='紧急散步:BAAALgAECgYJBgAAAA==.',
['紫炎']='紫炎沧澜:BAAALgAECgUJBQAAAA==.',
['紫颜']='紫颜丿步阡:BAAALgAECgEJAgAAAA==.',
['繁花']='繁花:BAAALgADCgYJBgAAAA==.',
['红双']='红双喜丶:BAABLgAFFH8JAAMBAAUJ8w6iFgBJAQABAAQJ8w6iFgBJAQAEAAEJAAB6GwAtAAAAAA==.',
['绝影']='绝影:BAAALgAECgcJBwAAAA==.',
['老绵']='老绵羊:BAAALgAECgMJBgAAAA==.',
['腹黑']='腹黑喵:BAAALgAFFAEJAQAAAA==.',
['节水']='节水优先:BAAALgAECgEJAgAAAA==.',
['茴暃']='茴暃严乜:BAABLgAFFH8GAAITAAMJnhy8BQAIAQATAAMJnhy8BQAIAQABLgAFFAQJDgAUAHYWAA==.',
['莉娜']='莉娜兔:BAAALgAFFAEJAgAAAA==.',
['葡萄']='葡萄藤:BAAALgAECgYJBgAAAA==.',
['血月']='血月魂殇:BAAALgADCgYJBgAAAA==.',
['西格']='西格玛圣男:BAAALgAECgMJBAAAAA==.',
['西瓜']='西瓜贼:BAAALgAFFAQJBAAAAA==.',
['貂蝉']='貂蝉在腰上:BAAALgAECgUJCQAAAA==.',
['超级']='超级牛:BAAALgAFFAEJAQAAAA==.',
['软白']='软白沙丶:BAABLgAFFH8QAAMBAAYJRBkWEgBZAQABAAUJRBkWEgBZAQAEAAEJAAAzGAA7AAAAAA==.',
['那小']='那小子真帅丶:BAAALgAECgYJBgAAAA==.',
['邪恶']='邪恶韭菜:BAAALgAECgUJBgAAAA==.',
['铁拳']='铁拳张哥:BAAALgADCgYJBgAAAA==.铁拳无敌:BAAALgAECgYJCAAAAA==.',
['银月']='银月哲别:BAAALgAECgEJAQAAAA==.',
['闪电']='闪电侠:BAAALgAECgEJAQAAAA==.',
['闹一']='闹一手好眼子:BAAALgAECgEJAQAAAA==.',
['阿德']='阿德裏亞諾:BAAALgADCgIJAgAAAA==.',
['阿波']='阿波菲斯:BAAALgAECgEJAQAAAA==.',
['隋随']='隋随:BAAALgAFFAEJAQAAAA==.',
['隔壁']='隔壁李哥:BAAALgAECgQJBQAAAA==.',
['雨夜']='雨夜不带桃:BAAALgAECgcJBwAAAA==.',
['雨露']='雨露均沾:BAAALgAECgQJBAAAAA==.',
['雪天']='雪天:BAAALgADCgYJCQAAAA==.',
['雪郁']='雪郁:BAAALgAECgEJAgAAAA==.',
['雪風']='雪風:BAAALgADCgQJBAAAAA==.',
['霜火']='霜火小子:BAAALgADCgYJBgAAAA==.',
['非法']='非法走丝:BAAALgAECgIJAgAAAA==.',
['预言']='预言者:BAAALgAECgMJAwAAAA==.',
['骑士']='骑士不会奶:BAAALgADCgEJAQAAAA==.',
['麻木']='麻木算罪过:BAABLgAFFH8LAAMBAAUJ2RfSDQBrAQABAAQJ2RfSDQBrAQAEAAEJAAAGGwAwAAAAAA==.',
['鼻叔']='鼻叔:BAAALgAECgMJBAAAAA==.',
['鼻塞']='鼻塞:BAABLgAFFH8JAAMBAAUJzQykGQA/AQABAAQJzQykGQA/AQAEAAEJAACyGwArAAAAAA==.',
['龙丶']='龙丶:BAAALgADCgcJBwABLgAFFAIJAwACAAAAAA==.',
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
