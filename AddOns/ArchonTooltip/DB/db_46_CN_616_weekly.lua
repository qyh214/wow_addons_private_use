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

local lookup = {'Mage-Frost','Rogue-Subtlety','Monk-Windwalker','Monk-Mistweaver','DeathKnight-Unholy','Unknown-Unknown','Monk-Brewmaster','Paladin-Retribution','Warrior-Protection','DemonHunter-Devourer','Shaman-Restoration','Druid-Restoration','Hunter-BeastMastery','Druid-Balance','DeathKnight-Frost','Paladin-Protection','Warrior-Fury','Priest-Discipline',}
local provider = {region='CN',realm='埃克索图斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aeraely:BAAALgAECgYJCAAAAA==.',
Af='Afraid:BAAALgAECgcJEwAAAA==.',
Ap='Applle:BAAALgAECgEJAQAAAA==.',
Ce='Cello:BAACLgAFFH8TAAIBAAUJHiRgBQAQAgABAAUJHiRgBQAQAgAuAAQKfyAAAgEACAlJJUUMAGIDAAEACAlJJUUMAGIDAAAA.',
Co='Comiz:BAAALgAECgcJCwAAAA==.',
Ev='Evelucky:BAAALgAECgcJEwAAAA==.',
Hu='Huulk:BAAALgAECgYJCgAAAA==.',
La='Lavitoyaya:BAAALgADCgcJDAAAAA==.',
Mo='Moayan:BAAALgAFFAQJBAAAAA==.',
Or='Orangebones:BAABLgAECn8ZAAICAAcJVRDGJwC6AQACAAcJVRDGJwC6AQAAAA==.',
Ov='Overlord:BAAALgAECgYJEAAAAA==.',
Re='Rengarzz:BAAALgAECgEJAQAAAA==.',
Sa='Salvatorer:BAAALgAFFAMJBAAAAA==.',
['一个']='一个人的曾经:BAAALgAECgcJDQAAAA==.',
['一刀']='一刀冰打:BAAALgAFFAUJAwAAAA==.',
['一宝']='一宝:BAAALgAECgYJDAAAAA==.',
['三余']='三余无梦生:BAABLgAFFH8IAAMDAAMJURw5CQDeAAADAAIJoCU5CQDeAAAEAAEJchTtFABWAAAAAA==.',
['三刀']='三刀冰打:BAABLgAECn8UAAIFAAkJ6CDNAwCZAwAFAAkJ6CDNAwCZAwABLgAFFAQJCAAFABcaAA==.',
['上啊']='上啊来福:BAAALgAFFAEJAQAAAA==.',
['上帝']='上帝归来:BAAALgAECgQJBQAAAA==.',
['不眠']='不眠邪神:BAAALgAECgYJCgAAAA==.',
['不知']='不知稻:BAAALgAECgEJAQAAAA==.',
['不能']='不能这么做:BAAALgAECgMJBAAAAA==.',
['两刀']='两刀冰打:BAAALgAFFAQJAQABLgAFFAQJCAAFABcaAA==.',
['丶嗯']='丶嗯哼:BAAALgADCgYJBQAAAA==.',
['丸惹']='丸惹:BAAALgAFFAIJAwAAAA==.',
['九刀']='九刀冰打:BAAALgAFFAIJAgAAAA==.',
['云七']='云七七:BAAALgAECgUJBQAAAA==.',
['五刀']='五刀冰打:BAAALgAFFAUJAgAAAA==.',
['人豹']='人豹喜欢不:BAAALgAECgEJBAAAAA==.',
['他他']='他他丶塔子哥:BAABLgAECn8ZAAIFAAgJgBqnMwBoAgAFAAgJgBqnMwBoAgAAAA==.',
['仙女']='仙女不吃糖:BAAALgAECgQJDAAAAA==.',
['伐克']='伐克尤:BAAALgAECgkJCQAAAA==.',
['佑缇']='佑缇艾沫:BAAALgAECgEJAQAAAA==.',
['使劲']='使劲打用力抽:BAAALgAECgEJAQAAAA==.',
['信仰']='信仰选手:BAAALgAECgYJCQAAAA==.',
['倒霉']='倒霉的小胖牛:BAAALgAECgUJBQAAAA==.',
['元宵']='元宵:BAAALgAECgEJAQAAAA==.',
['克丨']='克丨劳丨德:BAAALgAECgkJCQAAAA==.',
['全麦']='全麦面包包:BAAALgAECgEJAQAAAA==.',
['八刀']='八刀冰打:BAAALgAFFAQJAQABLgAFFAQJCAAFABcaAA==.',
['六刀']='六刀冰打:BAAALgAFFAQJAwABLgAFFAQJCAAFABcaAA==.六刀天打:BAAALgAFFAQJAgAAAA==.',
['六神']='六神合体:BAAALgAECgEJAQAAAA==.',
['兽神']='兽神演武:BAAALgADCgEJAQAAAA==.',
['冰风']='冰风不朽:BAAALgAECgMJBAAAAA==.',
['凡尘']='凡尘忆梦:BAAALgAECgEJAQABLgAECgQJBAAGAAAAAA==.',
['刀疤']='刀疤进行曲:BAAALgAECgEJAQAAAA==.',
['别叫']='别叫我刷智力:BAAALgAECgEJAgABLgAECgQJBAAGAAAAAA==.',
['别礼']='别礼:BAAALgAFFAQJBAAAAA==.',
['剑心']='剑心通明:BAAALgAECgcJCgAAAA==.',
['剑舞']='剑舞飞扬:BAAALgAECgIJAwAAAA==.',
['功夫']='功夫母猫:BAABLgAFFH8GAAIHAAMJuwRjFwC1AAAHAAMJuwRjFwC1AAAAAA==.',
['十刀']='十刀冰打:BAAALgAFFAUJAQAAAA==.',
['千羽']='千羽冰怡:BAAALgAFFAIJAgAAAA==.',
['千里']='千里走单骑:BAAALgADCgEJAQAAAA==.',
['卡加']='卡加萨拉:BAAALgAECgUJBQAAAA==.',
['只会']='只会滚键盘:BAAALgAFFAEJAQAAAA==.',
['呼噜']='呼噜:BAAALgAECgQJBQAAAA==.',
['呼小']='呼小胖:BAAALgAECgUJCwAAAA==.',
['哎呦']='哎呦不是吧:BAAALgADCgEJAQAAAA==.',
['哦耶']='哦耶王小明:BAAALgADCgQJBAAAAA==.',
['唐龙']='唐龙无道:BAAALgAECgEJAQAAAA==.',
['喵喵']='喵喵如此美妙:BAAALgAECgQJBAAAAA==.',
['喵王']='喵王:BAAALgAECgYJDAAAAA==.',
['嗜血']='嗜血灬狂暴:BAAALgADCgEJAQAAAA==.',
['囚鸟']='囚鸟不知海:BAAALgAECgIJAgAAAA==.囚鸟出笼:BAAALgADCgEJAQAAAA==.',
['四刀']='四刀冰打:BAAALgAFFAQJAgABLgAFFAQJCAAFABcaAA==.',
['四季']='四季美:BAAALgADCgEJAQAAAA==.',
['圣光']='圣光丶地球:BAAALgAECgcJBQAAAA==.圣光忽悠着你:BAABLgAECn8XAAIIAAcJdBrLQwAZAgAIAAcJdBrLQwAZAgAAAA==.',
['坠落']='坠落星:BAAALgAECgQJBgAAAA==.',
['垃圾']='垃圾大超哥:BAAALgAECgIJAgAAAA==.',
['增辉']='增辉铠甲:BAAALgAECgYJBwAAAA==.',
['壹宝']='壹宝:BAAALgAECgcJBgAAAA==.',
['夕颜']='夕颜花开:BAAALgAECgYJBgAAAA==.',
['夜灵']='夜灵:BAAALgAECgQJCAAAAA==.',
['夜颜']='夜颜星辰:BAAALgAECgQJAwAAAA==.',
['大牛']='大牛小牛:BAAALgAECgYJCQAAAA==.',
['大郎']='大郎该吃药了:BAAALgAFFAEJAQAAAA==.',
['天堂']='天堂的刑具:BAAALgAECgkJBwABLgAFFAcJDQAJAM4ZAA==.',
['天年']='天年:BAAALgADCgEJAgAAAA==.',
['太寿']='太寿鸠毛:BAAALgAECgYJBgAAAA==.',
['太难']='太难德丶:BAAALgAECgYJDQAAAA==.',
['奥塔']='奥塔里斯:BAAALgAECgYJCgAAAA==.',
['孤山']='孤山远影:BAAALgAECgQJBQAAAA==.',
['宁静']='宁静的月夜:BAAALgAECgQJBAAAAA==.',
['守望']='守望猎手:BAABLgAFFH8HAAIKAAMJsxF3KwCYAAAKAAMJsxF3KwCYAAAAAA==.',
['安莉']='安莉大将军:BAAALgADCgcJDQAAAA==.',
['小堕']='小堕姬:BAAALgADCgMJAwAAAA==.',
['小欢']='小欢乐:BAAALgAECgYJCQAAAA==.',
['小红']='小红花:BAABLgAECn8WAAILAAcJsh2nFgBhAgALAAcJsh2nFgBhAgAAAA==.',
['小肥']='小肥牛:BAABLgAFFH8LAAIMAAQJ9RitAwBbAQAMAAQJ9RitAwBbAQAAAA==.',
['小萌']='小萌猎:BAAALgAECgcJAgAAAA==.',
['小鸟']='小鸟伏特加:BAAALgAFFAIJBAAAAA==.',
['尐瀦']='尐瀦瀦:BAAALgADCgEJAQAAAA==.',
['少侠']='少侠留步:BAAALgAECgQJEQAAAA==.少侠闪开:BAAALgAECgYJDAAAAA==.',
['尘归']='尘归尘:BAAALgAFFAMJBAAAAA==.',
['尛乖']='尛乖:BAAALgAECgUJCgAAAA==.',
['就爱']='就爱优乐美:BAAALgADCgcJBwAAAA==.',
['尼克']='尼克:BAAALgAECgEJAQABLgAECgcJGQACAFUQAA==.',
['巨龙']='巨龙撞击:BAAALgADCgIJAgAAAA==.',
['帅气']='帅气的鲨鱼:BAAALgAECgYJBQAAAA==.',
['帕那']='帕那的奶瓶:BAAALgAECgcJBwAAAA==.',
['弯弓']='弯弓满月丶:BAAALgAECgIJAgAAAA==.',
['当心']='当心你的背后:BAAALgAECgEJAQAAAA==.',
['形单']='形单影只灬:BAAALgAECgEJAQAAAA==.',
['影丶']='影丶刃:BAAALgAECgUJBQAAAA==.',
['彼此']='彼此的牵绊:BAAALgAFFAEJAQABLgAFFAQJDQANAJsNAA==.',
['德莱']='德莱文:BAAALgAECgYJDAAAAA==.',
['念小']='念小妞:BAAALgAECgUJBQAAAA==.',
['恋床']='恋床的木头:BAAALgADCgEJAQAAAA==.',
['恶魔']='恶魔的左耳:BAAALgAECgEJAgAAAA==.恶魔韦宝宝:BAAALgAECgIJAgAAAA==.',
['悟空']='悟空與八戒:BAAALgADCgIJAgAAAA==.',
['悲丶']='悲丶蓝:BAAALgAECgUJBAAAAA==.',
['惊鸟']='惊鸟之弓:BAAALgAECgcJCAAAAA==.',
['愤怒']='愤怒的小鳥:BAAALgAECgEJAgAAAA==.',
['成长']='成长生命幸福:BAACLgAFFH8FAAMOAAIJXgEcCgBzAAAOAAIJXgEcCgBzAAAMAAEJgx43IgBUAAAuAAQKfxQAAwwABwkGIR4ZAG8CAAwABwkGIR4ZAG8CAA4AAQkdCcAjAC8AAAAA.',
['我偌']='我偌无梦:BAAALgAECgMJAwAAAA==.',
['我台']='我台必归:BAAALgADCgUJBgAAAA==.',
['我的']='我的小宝贝:BAAALgADCgIJAQAAAA==.',
['执笔']='执笔偌相思丶:BAAALgAECgYJCgAAAA==.',
['挖坑']='挖坑:BAAALgAECgMJBgAAAA==.挖坑六号:BAAALgADCgMJAwAAAA==.',
['摸鱼']='摸鱼:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌中龙:BAAALgAECgQJBAAAAA==.无敌小龙:BAAALgAFFAIJAgAAAA==.',
['是凡']='是凡凡吖:BAAALgAECgEJAQAAAA==.',
['晚宁']='晚宁:BAAALgAECgEJAQAAAA==.',
['普罗']='普罗米修乄龍:BAAALgADCgMJAwAAAA==.',
['曰尔']='曰尔曼战车:BAAALgAFFAUJBAABLgAFFAYJAgAGAAAAAA==.',
['最后']='最后的怒吼:BAAALgAFFAIJAgAAAA==.',
['月翼']='月翼猫头鹰:BAAALgAFFAYJBAAAAA==.',
['東北']='東北一米九丶:BAAALgAECgQJBAAAAA==.',
['栗子']='栗子很爱我:BAAALgAECgEJAgAAAA==.',
['梦境']='梦境丶地球:BAAALgADCgEJAQABLgAFFAUJBAAGAAAAAA==.',
['橙色']='橙色预警:BAAALgAECgEJAQAAAA==.',
['武艺']='武艺高强:BAAALgAECgYJCwAAAA==.',
['死亡']='死亡丶地球:BAAALgAFFAIJAgAAAA==.',
['水墨']='水墨青花:BAABLgAFFH8GAAIIAAMJQiKEDgA2AQAIAAMJQiKEDgA2AQAAAA==.',
['江南']='江南烟雨楼:BAAALgAFFAEJAQAAAA==.',
['油炸']='油炸蔷薇:BAAALgAECgEJAQABLgAFFAUJCwAPAKMeAA==.',
['法力']='法力炉灰:BAAALgADCgMJAwAAAA==.',
['法可']='法可鱿里:BAAALgAECgQJBAAAAA==.',
['浙耳']='浙耳:BAAALgAECgEJAQAAAA==.',
['浥芝']='浥芝:BAAALgAECgEJAQAAAA==.',
['浮世']='浮世記夢:BAAALgAECgcJBwABLgAFFAcJBQABANIGAA==.',
['淸湶']='淸湶眏玥:BAAALgAECgMJAwAAAA==.',
['清焱']='清焱凝雪:BAAALgAFFAEJAQAAAA==.',
['清翎']='清翎飘雪:BAAALgAFFAIJAwAAAA==.',
['清风']='清风笑烟雨:BAAALgAECgUJBwAAAA==.',
['潇洒']='潇洒丿哥:BAAALgAECgYJDwAAAA==.',
['澡子']='澡子姐:BAAALgAECgkJDgAAAA==.',
['灰色']='灰色丶预言:BAAALgADCgEJAQAAAA==.',
['焦喘']='焦喘的邦桑迪:BAAALgAFFAEJAQAAAA==.',
['然而']='然而偶尔:BAAALgAECgEJAQAAAA==.',
['熊熊']='熊熊能凶熊:BAAALgAECgIJAgAAAA==.',
['牛奶']='牛奶德:BAAALgAECgEJAQAAAA==.',
['牛德']='牛德狠丶:BAACLgAFFH8MAAIMAAQJcRNnCwApAQAMAAQJcRNnCwApAQAuAAQKfxwAAwwACAnLHbcGAAICAAwACAnLHbcGAAICAA4AAQl1D+YgADoAAAAA.',
['牛牛']='牛牛大牛牛:BAAALgAFFAIJAgAAAA==.',
['特大']='特大号天狼星:BAAALgAECgMJAwAAAA==.',
['特矮']='特矮特快:BAAALgAECgEJAQAAAA==.',
['犀利']='犀利犀利:BAAALgADCgMJAwAAAA==.',
['狂舞']='狂舞手术刀:BAAALgAECgYJEAAAAA==.',
['狴丨']='狴丨犴:BAAALgAECgEJAQAAAA==.',
['猫小']='猫小橙:BAAALgAFFAIJAgABLgAFFAQJDgAHAMYaAA==.',
['玥玥']='玥玥的德德:BAAALgADCgEJAQAAAA==.',
['珀尔']='珀尔修斯:BAAALgADCgIJAgAAAA==.',
['珍娜']='珍娜:BAAALgAECgcJBwAAAA==.',
['琦梦']='琦梦:BAABLgAECn8YAAMQAAcJ5wQTKgC6AAAQAAYJYAUTKgC6AAAIAAEJjAJRUQErAAAAAA==.',
['瓦里']='瓦里安:BAAALgAECgIJAwAAAA==.',
['痛覚']='痛覚残留:BAAALgAFFAEJAgAAAA==.',
['真爱']='真爱似血:BAAALgAECgYJCwAAAA==.',
['祖格']='祖格斯图卡:BAACLgAFFH8IAAIRAAQJaweeAwA2AQARAAQJaweeAwA2AQAuAAQKfyIAAxEABwkLG2w/AKcBABEABgnxGmw/AKcBAAkAAQmKGxlAAFEAAAAA.',
['神啊']='神啊赐個妞吧:BAAALgAECgEJAQAAAA==.',
['简白']='简白:BAAALgAECgYJCgAAAA==.',
['米唐']='米唐:BAAALgAECggJCwAAAA==.',
['糯米']='糯米圆子:BAAALgADCgMJAwAAAA==.',
['紅塵']='紅塵印像:BAAALgAECgYJAwAAAA==.',
['索尔']='索尔迦雷欧:BAAALgAECgEJAQAAAA==.',
['紫日']='紫日:BAAALgAECgUJDAAAAA==.',
['紫水']='紫水晶丶:BAAALgAECgcJAQAAAA==.',
['紫罗']='紫罗幻灵:BAAALgAECgcJBwAAAA==.',
['纪念']='纪念逝去的你:BAAALgAECgYJDQAAAA==.',
['织女']='织女星:BAAALgAECgQJBAAAAA==.',
['继续']='继续的理由:BAAALgAECgEJAQAAAA==.',
['绿绿']='绿绿丶太阳:BAAALgAFFAEJAQAAAA==.',
['老司']='老司机超叔:BAAALgAECgYJDgAAAA==.',
['股二']='股二蛋:BAAALgAECgQJBAAAAA==.',
['胡作']='胡作非为的胡:BAAALgAECgYJCgAAAA==.',
['臨淵']='臨淵:BAAALgAECgQJBAAAAA==.',
['自由']='自由哥:BAAALgAECgEJAQAAAA==.',
['致命']='致命之罚:BAAALgAECgQJBAAAAA==.',
['艾蒂']='艾蒂蒂:BAAALgAECgcJDQAAAA==.',
['芜罗']='芜罗亭魔梨威:BAAALgAFFAEJAQAAAA==.',
['芜铭']='芜铭弑:BAABLgAECn8ZAAICAAcJuhqdHwD9AQACAAcJuhqdHwD9AQAAAA==.',
['芬达']='芬达可乐:BAAALgADCgcJBwAAAA==.',
['花小']='花小狸:BAAALgAECgUJBQAAAA==.',
['若叶']='若叶睦:BAAALgAFFAIJAQABLgAFFAUJAgAGAAAAAA==.',
['范宝']='范宝宝:BAAALgAFFAIJAgAAAA==.',
['草莓']='草莓啵啵:BAAALgAECgEJAQAAAA==.',
['莉丽']='莉丽丝:BAAALgAECgkJCAAAAA==.',
['菲克']='菲克大魔王灬:BAAALgAECgYJCwAAAA==.',
['蔚蓝']='蔚蓝星星:BAAALgAECgMJAwAAAA==.',
['虚空']='虚空丶地球:BAAALgAECgEJAQAAAA==.',
['西兰']='西兰花:BAAALgAECgUJBQAAAA==.',
['西门']='西门癫疯:BAAALgAECgEJAwAAAA==.',
['见面']='见面躺过:BAAALgADCgUJBQAAAA==.',
['解臾']='解臾:BAAALgAECgEJAQAAAA==.',
['败柳']='败柳一枝:BAAALgAECgEJAQAAAA==.',
['路人']='路人灵修:BAAALgAECgYJCwAAAA==.',
['路满']='路满繁星:BAAALgADCgYJBgAAAA==.',
['转瞬']='转瞬即逝:BAAALgADCgEJAQAAAA==.',
['达雯']='达雯西:BAAALgADCgIJAgAAAA==.',
['迷糊']='迷糊兔:BAAALgAECgEJAQAAAA==.',
['那一']='那一眸的战栗:BAAALgAECgUJBQAAAA==.',
['邪能']='邪能波比:BAAALgAECgMJAwAAAA==.',
['酷炫']='酷炫微龙:BAAALgAECgIJAgABLgAFFAcJEgASAEEVAA==.',
['醉靚']='醉靚訫欣:BAAALgAECgYJBgAAAA==.',
['里飞']='里飞沙:BAAALgAECgYJBgAAAA==.',
['银狐']='银狐孤雀:BAAALgAECgcJDAAAAA==.',
['闲狼']='闲狼赫萝丶:BAABLgAECn8UAAMIAAYJXh78YgC8AQAIAAYJ4hb8YgC8AQAQAAQJaRg7IgD2AAAAAA==.',
['队长']='队长我打瞌睡:BAAALgADCgEJAQAAAA==.',
['阿杉']='阿杉发大财:BAAALgAECgMJAwAAAA==.',
['阿梅']='阿梅达物语:BAAALgADCgEJAQAAAA==.',
['随便']='随便拽拽:BAAALgAECgYJDQAAAA==.随便盖姚明:BAAALgAECgEJAQAAAA==.',
['随风']='随风儿:BAAALgAECgYJCwAAAA==.',
['雪山']='雪山飞牛:BAAALgADCgYJBgAAAA==.',
['零号']='零号机:BAABLgAFFH8FAAIMAAUJ5wrKBgBqAQAMAAUJ5wrKBgBqAQAAAA==.',
['露娜']='露娜丶:BAAALgAECgYJBgAAAA==.',
['青春']='青春翻涌成她:BAABLgAECn8YAAIBAAYJ9CSXQgBwAgABAAYJ9CSXQgBwAgAAAA==.',
['青絲']='青絲如煙:BAAALgAECgEJAQAAAA==.',
['非你']='非你莫薯:BAAALgAFFAUJAQAAAA==.',
['鞠婧']='鞠婧祎:BAAALgAECgYJCgAAAA==.',
['鞭妇']='鞭妇侠候恩:BAAALgAECgQJBQAAAA==.',
['须臾']='须臾:BAAALgADCgEJAQAAAA==.',
['飓风']='飓风之牛:BAAALgAECgIJAgAAAA==.',
['飞流']='飞流:BAAALgAECgEJAQAAAA==.',
['飞雷']='飞雷神:BAAALgADCgEJAQAAAA==.',
['香蕉']='香蕉不啦啦:BAAALgAECgQJBAAAAA==.',
['马场']='马场大恶人:BAAALgAECgkJEAAAAA==.',
['鮮血']='鮮血乄凝聚:BAAALgADCgcJDgAAAA==.',
['鱼摆']='鱼摆摆了不起:BAAALgAECgYJCgABLgAFFAIJBQAIAP0kAA==.',
['鲜果']='鲜果粒:BAAALgAECgQJBQAAAA==.',
['鳌丶']='鳌丶少丶保:BAAALgAFFAIJAgAAAA==.',
['黑巧']='黑巧麻薯薯:BAAALgAECgQJBQAAAA==.',
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
