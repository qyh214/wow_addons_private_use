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

local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','Paladin-Holy','Monk-Brewmaster','Mage-Frost','DemonHunter-Havoc','DemonHunter-Devourer','Hunter-Marksmanship','Evoker-Augmentation','Evoker-Devastation','Paladin-Retribution','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction',}
local provider = {region='CN',realm='托尔巴拉德',name='CN',type='weekly',zone=46,date='2026-04-25',data={Br='Breach:BAAALgAFFAQJAwAAAA==.',
Cl='Claudiax:BAAALgAECgYJBgAAAA==.Clser:BAAALgAECgQJBAAAAA==.',
Cy='Cyu:BAAALgAECgYJDAAAAA==.',
Ev='Evolit:BAAALgAECgQJBAAAAA==.',
Fl='Fly:BAAALgAECgkJCAAAAA==.',
Ha='Hayabusa:BAAALgAECgEJAQAAAA==.',
Je='Jett:BAAALgAFFAUJAwAAAA==.',
Ka='Kayo:BAAALgAFFAIJAQAAAA==.',
Ku='Kumo:BAAALgAFFAcJAwAAAA==.',
Mi='Michiya:BAAALgAECgEJAQAAAA==.',
Ne='Neon:BAAALgAFFAUJAQAAAA==.',
Re='Redclown:BAABLgAFFH8IAAMBAAQJjAX/AAA3AQABAAQJjAX/AAA3AQACAAMJlAHXMADJAAAAAA==.Remixdzs:BAAALgAECgEJAQAAAA==.Remixsqs:BAAALgAFFAEJAQAAAA==.',
Se='Seleeilee:BAABLgAFFH8KAAIDAAUJDhSRBACWAQADAAUJDhSRBACWAQAAAA==.',
Vi='Viper:BAAALgAFFAQJBAAAAA==.',
['不期']='不期而遇我:BAABLgAECn8XAAICAAcJthpITAAOAgACAAcJthpITAAOAgAAAA==.',
['丶醉']='丶醉莔囧:BAAALgADCgcJBwAAAA==.',
['丿拾']='丿拾捌火:BAAALgAECgQJBQAAAA==.',
['乂氼']='乂氼:BAAALgAECgQJAwAAAA==.',
['九零']='九零後牛油果:BAAALgADCgIJAgAAAA==.',
['人红']='人红橙多:BAAALgADCggJCAAAAA==.',
['伴读']='伴读小书童:BAAALgAECgYJCAAAAA==.',
['佐佐']='佐佐沐希:BAAALgADCgIJAgAAAA==.',
['你的']='你的相好:BAAALgAFFAIJAgAAAA==.',
['凹暖']='凹暖降:BAAALgADCgIJAgAAAA==.',
['剑廿']='剑廿叁:BAAALgAECgYJDAAAAA==.',
['北郡']='北郡气质哥:BAAALgAFFAIJBAAAAA==.',
['十一']='十一月十四:BAAALgAECgcJCgAAAA==.',
['卡在']='卡在名字:BAAALgAECgIJAgAAAA==.',
['卡尼']='卡尼吉亚:BAAALgADCgIJAgAAAA==.',
['厚朴']='厚朴不是候补:BAAALgADCgQJBAAAAA==.',
['可怜']='可怜的小无奈:BAAALgAECgYJBgAAAA==.',
['吼哟']='吼哟:BAAALgAECgcJEgAAAA==.',
['吾道']='吾道即天命:BAAALgAECgMJAwAAAA==.',
['喵念']='喵念:BAAALgAECgMJAwAAAA==.',
['噬魂']='噬魂丶猎:BAAALgAECgYJEAAAAA==.',
['四夕']='四夕丶四夕:BAACLgAFFH8HAAIEAAMJdAUGFwC5AAAEAAMJdAUGFwC5AAAuAAQKfysAAgQACAn0FtAdABMCAAQACAn0FtAdABMCAAAA.',
['圣息']='圣息者爱萝米:BAAALgAECgkJDgAAAA==.',
['夜灬']='夜灬来香:BAAALgAECgMJAwAAAA==.',
['夜舞']='夜舞灬倾城:BAAALgAECgcJCAAAAA==.',
['妖妖']='妖妖雪烟:BAACLgAFFH8IAAIFAAMJxwRZFQDeAAAFAAMJxwRZFQDeAAAuAAQKfxsAAgUABwl7FoWPALQBAAUABwl7FoWPALQBAAAA.',
['对月']='对月而笑:BAAALgAECgYJCgAAAA==.',
['小天']='小天真:BAAALgAECgMJBQAAAA==.',
['小小']='小小矮子小小:BAAALgAECgEJAQAAAA==.',
['小白']='小白是癫狗壹:BAAALgAECgcJDQAAAA==.小白是颠狗拾:BAAALgAECgcJDQAAAA==.小白是颠狗捌:BAABLgAECn8WAAMGAAkJ0wsVKQB6AQAGAAcJsw8VKQB6AQAHAAkJDQAAAAAAAAAAAA==.小白是颠狗柒:BAAALgAECgcJDgAAAA==.小白是颠狗玖:BAAALgAECgcJDQAAAA==.',
['小花']='小花生:BAAALgAECgEJAgAAAA==.',
['布洛']='布洛纯:BAAALgAECgEJAQAAAA==.',
['彻子']='彻子的小狸花:BAAALgAECgYJDgAAAA==.',
['德德']='德德打滴:BAAALgAECgEJAQAAAA==.',
['德欲']='德欲:BAAALgAFFAEJAQAAAA==.',
['悟不']='悟不空:BAAALgAFFAEJAQAAAA==.',
['我是']='我是是彩笔:BAAALgAFFAMJBAAAAA==.',
['托尼']='托尼老死:BAAALgAECgQJBQAAAA==.',
['抗战']='抗战八十周年:BAAALgADCgUJBQAAAA==.',
['拂晓']='拂晓:BAAALgAECgUJBQAAAA==.',
['指尖']='指尖上徘徊:BAAALgAECgEJAQAAAA==.',
['挥舞']='挥舞的大红袍:BAAALgAECgYJBgAAAA==.',
['放肆']='放肆的小飞:BAAALgAFFAQJBAABLgAFFAcJHwAIACIjAA==.',
['无奈']='无奈的小刀:BAAALgAFFAIJBAAAAA==.',
['无敌']='无敌:BAAALgAFFAEJAQAAAA==.',
['日月']='日月吉吉:BAAALgAECgEJAQAAAA==.',
['星河']='星河杳杳:BAAALgAFFAIJAwAAAA==.星河杳杳忄:BAAALgAECgcJCwAAAA==.',
['暴走']='暴走八神:BAAALgAECgEJAgAAAA==.',
['木頭']='木頭朲:BAAALgAECgEJAgAAAA==.',
['末曰']='末曰聽楓:BAAALgAECgcJDwAAAA==.',
['朱鸢']='朱鸢:BAAALgAECgQJBQAAAA==.',
['李保']='李保国:BAACLgAFFH8VAAMJAAUJVCFaAwDwAQAJAAUJVCFaAwDwAQAKAAEJAADqCQBTAAAuAAQKfx0AAwkACAkfH9sMAKgCAAkACAnCHtsMAKgCAAoAAglZIfQuAKAAAAAA.',
['柏拉']='柏拉图式魔醻:BAAALgAFFAEJAQAAAA==.',
['格兰']='格兰蒂亚:BAABLgAECn8bAAILAAcJkQ6pmgBJAQALAAcJkQ6pmgBJAQAAAA==.',
['梁辰']='梁辰:BAAALgAECgYJCAAAAA==.',
['梦露']='梦露的桃子:BAAALgADCgMJAwAAAA==.',
['武僧']='武僧牛:BAAALgADCgIJAgAAAA==.',
['澔子']='澔子:BAAALgAECgYJCgAAAA==.',
['灬辣']='灬辣辣灬:BAAALgAFFAQJBAAAAA==.',
['灵能']='灵能者:BAAALgAECgYJBgAAAA==.',
['灵魂']='灵魂倡导者:BAAALgADCgUJBQAAAA==.',
['烽火']='烽火戏诸侯:BAABLgAECn8WAAIFAAYJ7RuYewDaAQAFAAYJ7RuYewDaAQAAAA==.',
['牛就']='牛就是不解释:BAABLgAECn8VAAICAAkJKhbRIwCvAgACAAkJKhbRIwCvAgAAAA==.',
['牢萨']='牢萨陛:BAAALgAECgQJBQAAAA==.',
['王林']='王林呆:BAAALgADCgUJBQAAAA==.',
['王祖']='王祖贤:BAAALgAECgcJDgAAAA==.',
['王诺']='王诺野:BAAALgADCgUJAQAAAA==.',
['真心']='真心喜欢:BAAALgAECgEJAQAAAA==.',
['秋丨']='秋丨僧:BAAALgAECgMJAwAAAA==.秋丨恶魔:BAAALgAECgYJEAAAAA==.',
['红莲']='红莲铠骑:BAAALgAECgEJAQABLgAFFAMJBQAJAEwPAA==.',
['缘起']='缘起性空:BAAALgAECgEJAQAAAA==.',
['老醋']='老醋灬花生:BAAALgAECgQJBwAAAA==.',
['聖言']='聖言絶心:BAAALgADCgUJBQAAAA==.',
['至暗']='至暗夜之子:BAAALgAECgEJAQAAAA==.',
['航航']='航航:BAAALgAECgQJBgAAAA==.',
['花满']='花满心亦满楼:BAAALgAECgYJBgAAAA==.',
['莣汜']='莣汜沵忲難:BAAALgAECgMJAwAAAA==.',
['落花']='落花血刃:BAAALgAECgUJBQAAAA==.',
['蓝嗖']='蓝嗖嗖:BAACLgAFFH8IAAILAAMJZxNbFQD/AAALAAMJZxNbFQD/AAAuAAQKfxwAAwsABwnQHuk5ADsCAAsABwnQHuk5ADsCAAMAAQm+AdeiACIAAAAA.',
['蕾娜']='蕾娜兰尼斯特:BAABLgAECn8VAAQMAAYJAxDpfQBfAQAMAAYJAxDpfQBfAQANAAIJ3wCWagA9AAAOAAEJHA9BMQA7AAAAAA==.',
['藿藿']='藿藿:BAAALgAECgQJBAAAAA==.',
['血刃']='血刃魅影:BAAALgAECgcJAQAAAA==.',
['讲道']='讲道理的豆:BAAALgAECgEJAQAAAA==.',
['贝奥']='贝奥武夫:BAAALgADCgEJAQAAAA==.',
['趙子']='趙子龍:BAAALgAECgQJBQAAAA==.',
['跳斩']='跳斩一刀:BAAALgAECgYJBgAAAA==.',
['迷人']='迷人迪巴巴:BAAALgAECgYJCAAAAA==.',
['逢人']='逢人斩丶:BAAALgAECgYJBgAAAA==.',
['铁手']='铁手既天命:BAAALgAECgYJCwAAAA==.',
['锦绣']='锦绣无双:BAAALgADCgcJBwAAAA==.',
['陌不']='陌不守:BAAALgAECgYJEQAAAA==.',
['雪梨']='雪梨不加糖:BAAALgADCgEJAQAAAA==.',
['雪蒂']='雪蒂克儿:BAAALgAECgYJBgAAAA==.',
['风吹']='风吹来:BAAALgADCgEJAQAAAA==.',
['飞跃']='飞跃疯人院:BAAALgAECgEJAQAAAA==.',
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
