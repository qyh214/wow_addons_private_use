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

local lookup = {'Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Evoker-Augmentation','Evoker-Preservation','Priest-Discipline','Priest-Shadow','Monk-Mistweaver','DeathKnight-Frost','DeathKnight-Unholy','Monk-Brewmaster','Rogue-Assassination','Rogue-Subtlety','Druid-Restoration','Mage-Frost','Hunter-Marksmanship','Hunter-BeastMastery','Priest-Holy','Paladin-Holy','Paladin-Retribution','Druid-Balance','Warrior-Arms','Warrior-Fury','DemonHunter-Devourer','DeathKnight-Blood','Shaman-Elemental','DemonHunter-Havoc','Evoker-Devastation','Druid-Guardian','Warrior-Protection',}
local provider = {region='CN',realm='海达希亚',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ac='Achoxo:BAAALgAFFAIJBAAAAA==.',
Ag='Agua:BAAALgADCgUJBwAAAA==.',
Ar='Arths:BAAALgAECgIJAgAAAA==.',
As='Asder:BAAALgAFFAMJBAAAAA==.',
Ci='Circulation:BAAALgAECgcJBwAAAA==.',
Di='Disfrutar:BAABLgAFFH8FAAMBAAUJGx3fBQARAQABAAMJFxvfBQARAQACAAIJJyOEKgDHAAABLgAFFAcJAQADAAAAAA==.',
Dk='Dktank:BAAALgAECgcJEgAAAA==.',
Do='Dolores:BAABLgAFFH8MAAMEAAQJ6g/fEAD6AAAEAAQJ6g/fEAD6AAAFAAIJYQD/FABrAAAAAA==.',
Fl='Flyleaf:BAAALgAECgUJCAAAAA==.',
Fr='Freedom:BAAALgAECgEJAgAAAA==.',
Iv='Ivanna:BAACLgAFFH8OAAIGAAYJsB0RAQBNAgAGAAYJsB0RAQBNAgAuAAQKfyQAAwYACQkBIa4BAG8DAAYACQkBIa4BAG8DAAcAAQmiDcVfADkAAAAA.',
Ly='Lyi:BAAALgAECgEJAQAAAA==.',
Me='Meowpriest:BAAALgAECgcJEQAAAA==.',
Re='Remkilito:BAAALgADCgMJAwAAAA==.Rerves:BAABLgAFFH8LAAMCAAQJ+BtdGQAmAQACAAMJDh9dGQAmAQABAAEJthKUEwBXAAAAAA==.',
Ro='Rootlessd:BAAALgAFFAEJAgAAAA==.',
Sa='Samsara:BAACLgAFFH8UAAIIAAcJhxyvAAB7AgAIAAcJhxyvAAB7AgAuAAQKfxwAAggACQloI6QBAIUDAAgACQloI6QBAIUDAAAA.Santamina:BAACLgAFFH8OAAIFAAcJwR54AACMAgAFAAcJwR54AACMAgAuAAQKfxgAAgUACAmOJU0CAFEDAAUACAmOJU0CAFEDAAAA.',
So='Souldkk:BAABLgAFFH8JAAMJAAQJ/x5qAAB2AQAJAAQJbRhqAAB2AQAKAAMJsSKQHAAwAQAAAA==.',
St='Stonn:BAABLgAFFH8OAAILAAQJxAqZDwAFAQALAAQJxAqZDwAFAQAAAA==.',
Th='Thewitches:BAAALgAECgMJAQAAAA==.',
To='Tortville:BAAALgAECgYJCAAAAA==.',
Vi='Vitruvius:BAACLgAFFH8WAAMMAAUJhSNrAAD2AQAMAAUJZSBrAAD2AQANAAQJbB3ABgB0AQAuAAQKfxwAAwwACQm3JNgAAFEDAAwACAk2I9gAAFEDAA0ACAk0JHgHABgDAAAA.',
Ya='Yasmin:BAABLgAECn8VAAIOAAgJQRolGgBoAgAOAAgJQRolGgBoAgAAAA==.',
['一度']='一度迷失:BAAALgADCgMJAwAAAA==.',
['一粒']='一粒丶仙丹:BAAALgAECgkJEgAAAA==.',
['不甜']='不甜也不咸:BAABLgAECn8kAAIPAAgJsxNXZQANAgAPAAgJsxNXZQANAgAAAA==.',
['丘比']='丘比特之神射:BAACLgAFFH8WAAMQAAcJRRbzAgAjAgAQAAYJ0RfzAgAjAgARAAQJWhOQBwAKAQAuAAQKfxcAAxAACQkBI+IGACsDABAACQkBI+IGACsDABEAAQnTDjq4AFIAAAAA.',
['东邪']='东邪:BAAALgADCgUJBQAAAA==.',
['丢了']='丢了又丢丢:BAAALgAFFAEJAQAAAA==.',
['两发']='两发和平卫士:BAAALgAECgIJAgAAAA==.',
['丨鼻']='丨鼻涕虫丨:BAAALgADCgYJDAAAAA==.',
['中原']='中原一点游侠:BAAALgADCgcJDQAAAA==.',
['丹莫']='丹莫罗的烈酒:BAAALgADCgEJAQAAAA==.',
['乂永']='乂永恒乂:BAABLgAECn8aAAIRAAYJAhg5WQBcAQARAAYJAhg5WQBcAQAAAA==.',
['久久']='久久:BAAALgAECgQJBwAAAA==.',
['二见']='二见原莉莉子:BAACLgAFFH8NAAIGAAQJuCW+AwC6AQAGAAQJuCW+AwC6AQAuAAQKfxwAAwYACAlZJYgHAMkCAAYABwkyJYgHAMkCAAcAAQkNHeZYAFgAAAAA.',
['伊邪']='伊邪娜美:BAAALgAECgcJCAAAAA==.',
['你沐']='你沐什么霂:BAAALgAECgQJBQAAAA==.',
['修波']='修波呗:BAAALgAECgQJBQAAAA==.',
['光明']='光明之影:BAABLgAECn8aAAMSAAcJYgkjPABKAQASAAcJYgkjPABKAQAGAAUJwAKgEACfAAAAAA==.',
['光脚']='光脚的踏风:BAAALgAECgYJCAAAAA==.',
['全球']='全球的闪电链:BAAALgAECgYJBgAAAA==.',
['八百']='八百斤大橘猫:BAAALgADCgEJAQAAAA==.',
['冬青']='冬青:BAABLgAFFH8GAAMTAAMJ6hZmDgDwAAATAAMJ6hZmDgDwAAAUAAEJPQ9oMgBRAAABLgAFFAQJDQAEAHIWAA==.',
['凤雅']='凤雅玲:BAAALgAFFAIJAgABLgAFFAQJCQAVADsVAA==.',
['刘橙']='刘橙橙:BAABLgAFFH8JAAMWAAQJnBU4AQBNAQAWAAQJnBU4AQBNAQAXAAIJYg1gGQCjAAAAAA==.',
['华梅']='华梅丶李:BAAALgAECgYJCgAAAA==.',
['占台']='占台:BAAALgADCgIJAgAAAA==.',
['卡伦']='卡伦西:BAAALgAECgYJBwAAAA==.',
['卡斯']='卡斯汀:BAAALgAECgEJAQAAAA==.',
['卡比']='卡比又隐身了:BAACLgAFFH8KAAMNAAQJfxcIBwBwAQANAAQJfxcIBwBwAQAMAAEJdxJfBgBbAAAuAAQKfxsAAw0ACQk2IscFADUDAA0ACQkAIccFADUDAAwAAwnNIO0OACYBAAAA.',
['叠嶂']='叠嶂:BAAALgAECgEJAwAAAA==.',
['可口']='可口可乐:BAAALgAECgIJBAAAAA==.',
['可恶']='可恶:BAAALgAECgcJDwAAAA==.',
['台台']='台台:BAAALgADCgkJCgAAAA==.',
['吃麻']='吃麻麻香:BAAALgAECgEJAQAAAA==.',
['吉米']='吉米卡咖:BAAALgAECgEJAQAAAA==.',
['名字']='名字太难想了:BAAALgAECgMJAwAAAA==.',
['含笑']='含笑凋零:BAABLgAFFH8GAAIYAAMJ7RalGQADAQAYAAMJ7RalGQADAQAAAA==.',
['吹角']='吹角连营:BAAALgAECgkJCQAAAA==.',
['咏春']='咏春:BAAALgADCgEJAQAAAA==.',
['咏玖']='咏玖略略:BAAALgADCgIJAgAAAA==.咏玖阳雪:BAABLgAFFH8JAAIOAAQJXBnzAwBTAQAOAAQJXBnzAwBTAQAAAA==.',
['咕肉']='咕肉与熊掌:BAAALgAECgIJAgAAAA==.',
['咸鱼']='咸鱼大作战:BAACLgAFFH8GAAIPAAIJZSNFNADHAAAPAAIJZSNFNADHAAAuAAQKfxQAAg8ACAlvJIkdAP8CAA8ACAlvJIkdAP8CAAAA.咸鱼小神龙:BAACLgAFFH8aAAIEAAgJ1hxAAAA4AwAEAAgJ1hxAAAA4AwAuAAQKfxwAAgQACQmtJBkCAJUDAAQACQmtJBkCAJUDAAAA.',
['哎呀']='哎呀丶啊呀:BAABLgAFFH8JAAIUAAQJmBWXCwBPAQAUAAQJmBWXCwBPAQAAAA==.',
['嗨門']='嗨門幽:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光小萍萍:BAAALgADCgcJBwAAAA==.圣光武器战:BAAALgAECgQJBgAAAA==.',
['地狱']='地狱蛮妞:BAAALgADCgYJBwAAAA==.',
['壹零']='壹零贰肆丶:BAAALgAECgEJAQAAAA==.',
['夏和']='夏和小:BAACLgAFFH8eAAIGAAgJwiIQAABBAwAGAAgJwiIQAABBAwAuAAQKfyMAAwYACQk5JAYBAJYDAAYACQk5JAYBAJYDAAcAAQmRHa5YAFkAAAAA.',
['大头']='大头坏猫:BAAALgAECgkJCQABLgAFFAYJBQAVAMIYAA==.',
['大白']='大白兔奶糖:BAAALgAFFAEJAQAAAA==.',
['天一']='天一剑魔:BAAALgADCgYJBgAAAA==.',
['天天']='天天胡萝卜:BAAALgAECgYJBgAAAA==.',
['天气']='天气不错:BAABLgAECn8cAAIVAAgJBhwpFQBoAgAVAAgJBhwpFQBoAgAAAA==.',
['天籁']='天籁小痕:BAABLgAFFH8HAAIPAAQJPQ9gCgBLAQAPAAQJPQ9gCgBLAQAAAA==.',
['天语']='天语清音:BAAALgAECgYJCAAAAA==.',
['天选']='天选魔眼:BAAALgAECgYJBgAAAA==.',
['太平']='太平骑士:BAAALgADCggJDwAAAA==.',
['奔波']='奔波尔灞:BAAALgAECgQJBQAAAA==.',
['宝宝']='宝宝皮:BAAALgADCgUJBQAAAA==.',
['寂寞']='寂寞的图腾:BAAALgAECgQJBgAAAA==.',
['射死']='射死伱的温柔:BAAALgAECgIJAgAAAA==.',
['小亚']='小亚雄:BAAALgAECgYJCwAAAA==.',
['小嘎']='小嘎豆:BAAALgAECgcJDAAAAA==.小嘎豆二:BAAALgAECgcJBgAAAA==.小嘎豆四:BAAALgAECgkJEwAAAA==.',
['小小']='小小赖:BAAALgAFFAIJBAAAAA==.小小钟:BAAALgAFFAIJAgAAAA==.',
['小猪']='小猪存钱罐:BAACLgAFFH8PAAIPAAYJIh6eAgBeAgAPAAYJIh6eAgBeAgAuAAQKfygAAg8ACAkyJjsJAHwDAA8ACAkyJjsJAHwDAAAA.',
['小赖']='小赖赖:BAAALgAECgMJBAAAAA==.',
['岁数']='岁数小凭次数:BAAALgAECgQJBAAAAA==.',
['巨人']='巨人:BAABLgAFFH8FAAIZAAIJjQxhEABuAAAZAAIJjQxhEABuAAAAAA==.',
['幸运']='幸运的范范:BAAALgAECgIJAgAAAA==.',
['异族']='异族:BAAALgAECgEJAQAAAA==.异族灬:BAAALgAECgMJAwAAAA==.',
['弗里']='弗里德曼:BAAALgAECgUJBQAAAA==.',
['弯犄']='弯犄角:BAAALgAECgEJAQAAAA==.',
['强势']='强势菇凉:BAAALgAECgYJCQAAAA==.',
['德古']='德古拉埃尔:BAAALgADCgEJAQAAAA==.',
['恋恋']='恋恋迷蝶:BAAALgADCgIJAwAAAA==.恋恋迷迭:BAAALgAECgEJAQAAAA==.',
['悠悠']='悠悠丶铁骑:BAAALgAECgEJAQAAAA==.',
['愿泪']='愿泪止:BAAALgAECgMJBAAAAA==.',
['战丶']='战丶凡尘:BAAALgAECgYJCQAAAA==.',
['抽风']='抽风电电萨:BAAALgAECgUJBQAAAA==.',
['数星']='数星星的枭熊:BAAALgADCgcJBwAAAA==.',
['斯狄']='斯狄安娜:BAAALgAECgIJAgAAAA==.',
['无相']='无相之月:BAAALgAECgcJCgAAAA==.',
['明月']='明月栞那:BAAALgAECgIJAgAAAA==.',
['星川']='星川莉莉:BAAALgADCgUJBQAAAA==.',
['是梦']='是梦:BAABLgAFFH8GAAIGAAQJ9wMuDAATAQAGAAQJ9wMuDAATAQABLgAFFAQJDAAEAOoPAA==.',
['晕船']='晕船海盗:BAAALgAECgYJDQAAAA==.',
['暮雨']='暮雨晨风:BAAALgAECgYJBgAAAA==.',
['暴走']='暴走本子:BAABLgAECn8ZAAIaAAgJhRo6FAB9AgAaAAgJhRo6FAB9AgAAAA==.',
['朝朝']='朝朝长相守:BAAALgAECgEJAQAAAA==.',
['杖剑']='杖剑走天涯:BAAALgADCgEJAQAAAA==.',
['来个']='来个术士呗:BAAALgADCgYJBgAAAA==.',
['杨星']='杨星月:BAAALgAECgkJDgAAAA==.',
['柒片']='柒片:BAAALgADCgIJAgAAAA==.',
['梦伴']='梦伴:BAACLgAFFH8HAAIPAAIJyR+fNQDAAAAPAAIJyR+fNQDAAAAuAAQKfxcAAg8ABgmmJIBXADICAA8ABgmmJIBXADICAAAA.',
['梨花']='梨花白三:BAAALgAECgYJBgAAAA==.梨花白五:BAAALgAECgQJBAAAAA==.',
['沫柒']='沫柒:BAAALgAECgIJAgAAAA==.',
['沫灬']='沫灬沫:BAAALgADCgQJBAAAAA==.',
['海月']='海月诗澜:BAAALgADCgMJAwAAAA==.',
['清晨']='清晨的风:BAAALgAECgEJAQAAAA==.',
['渤海']='渤海香猪:BAAALgADCggJCAAAAA==.',
['漂浮']='漂浮炸弾:BAABLgAFFH8JAAIVAAQJOxUsAgBhAQAVAAQJOxUsAgBhAQAAAA==.',
['漫天']='漫天飞射:BAAALgAECgYJDAABLgAFFAQJBAADAAAAAA==.',
['漫步']='漫步晴天:BAAALgAFFAEJAQAAAA==.',
['灬小']='灬小土豆灬:BAAALgAECgIJAgAAAA==.',
['烈烈']='烈烈丨風中:BAAALgAECggJBAAAAA==.',
['烮刄']='烮刄:BAAALgAECgMJAwAAAA==.',
['然然']='然然:BAABLgAFFH8MAAIHAAQJCRl8AgBFAQAHAAQJCRl8AgBFAQABLgAFFAQJBgAHAAcWAA==.',
['熊萨']='熊萨:BAABLgAFFH8VAAMVAAUJ8xMvBACqAQAVAAUJ8xMvBACqAQAOAAUJghc7BgB0AQABLgAFFAYJBgAUABUCAA==.',
['熵裔']='熵裔:BAABLgAECn8VAAIbAAgJqBjbFQAdAgAbAAgJqBjbFQAdAgAAAA==.',
['牛大']='牛大棒:BAAALgAECgUJBQAAAA==.',
['特色']='特色啊:BAAALgAECgUJBAAAAA==.',
['狼贼']='狼贼:BAAALgAECgEJAQAAAA==.',
['猪蛋']='猪蛋蛋:BAABLgAECn8UAAIPAAgJsB/HTQBNAgAPAAgJsB/HTQBNAgAAAA==.',
['王凯']='王凯:BAAALgAECgIJBQAAAA==.',
['瑟莱']='瑟莱德丝:BAAALgAECgQJBAAAAA==.',
['百薇']='百薇:BAACLgAFFH8NAAQEAAQJcha2CgBJAQAEAAQJ4hS2CgBJAQAcAAIJGhJcBgCpAAAFAAIJSRShEQCkAAAuAAQKfycABAUACQkYGpsGANgCAAUACQkYGpsGANgCAAQABgnxHwcYABICABwABQmPH68VAJMBAAAA.',
['石头']='石头小哥哥:BAAALgAECgEJAQAAAA==.',
['破戒']='破戒僧:BAAALgAECgEJAQAAAA==.',
['破灭']='破灭:BAABLgAFFH8HAAIKAAQJABEQEwBVAQAKAAQJABEQEwBVAQAAAA==.',
['神圣']='神圣防御者:BAAALgAECgMJAgAAAA==.',
['神王']='神王宙斯:BAAALgAECgcJCwAAAA==.',
['离别']='离别电影:BAAALgAECgEJAQABLgAFFAQJCAACACImAA==.',
['粿条']='粿条超人:BAABLgAECn8UAAIOAAkJvxwBEAC5AgAOAAkJvxwBEAC5AgAAAA==.',
['糖豆']='糖豆多多:BAAALgAECgEJAQAAAA==.',
['糯米']='糯米妹妹:BAAALgAECgQJBAAAAA==.',
['紫色']='紫色梦境:BAAALgAECgMJAwAAAA==.紫色雨季:BAAALgAECgIJAgAAAA==.',
['紫辕']='紫辕璇艨:BAAALgADCgIJAQAAAA==.',
['红龙']='红龙奇洛:BAACLgAFFH8OAAIFAAQJoxc2CABnAQAFAAQJoxc2CABnAQAuAAQKfx0AAwUACQmkHuoDABwDAAUACQmkHuoDABwDAAQABglODTY5AA8BAAAA.',
['老衲']='老衲唐三藏:BAAALgAECgUJBAAAAA==.',
['聖光']='聖光闪现:BAAALgAECgIJAgAAAA==.',
['艾尔']='艾尔猫丶垃法:BAAALgAECgcJBwAAAA==.',
['花晨']='花晨月夕:BAAALgADCgYJBgAAAA==.',
['花间']='花间未眠:BAABLgAECn8iAAIPAAgJIBlXQgBxAgAPAAgJIBlXQgBxAgAAAA==.',
['芸梦']='芸梦飘雨:BAAALgAECgcJEQAAAA==.',
['范德']='范德薩:BAAALgADCgcJBwAAAA==.',
['萌萌']='萌萌哒:BAABLgAFFH8GAAMCAAQJHQSSKADUAAACAAMJWgWSKADUAAABAAEJZAB3GwA0AAAAAA==.',
['萧瑟']='萧瑟灬:BAABLgAFFH8MAAIEAAUJWRfbBQChAQAEAAUJWRfbBQChAQAAAA==.',
['萨满']='萨满:BAAALgAECgIJAgAAAA==.',
['蓝瑟']='蓝瑟犹豫:BAACLgAFFH8HAAIdAAQJZgQuBACQAAAdAAQJZgQuBACQAAAuAAQKfxcAAh0ACQnLE6sKAOwBAB0ACQnLE6sKAOwBAAAA.',
['蔚然']='蔚然橙风:BAAALgAECggJCgABLgAFFAIJAgADAAAAAA==.',
['蜻蜓']='蜻蜓飞:BAAALgADCgYJBgAAAA==.',
['西毒']='西毒:BAAALgADCgEJAQAAAA==.',
['讨厌']='讨厌:BAACLgAFFH8eAAIHAAcJCyQjAADeAgAHAAcJCyQjAADeAgAuAAQKfyAAAwcACQkTJgIBAMwDAAcACQkTJgIBAMwDAAYAAwl2AqtHAIAAAAAA.',
['豆三']='豆三包丶:BAAALgAECgYJBAABLgAECgkJCQADAAAAAA==.',
['豪正']='豪正雄:BAAALgAECgQJBAAAAA==.',
['赖小']='赖小小:BAAALgAECgQJBAAAAA==.',
['赛塔']='赛塔洛斯:BAABLgAFFH8IAAIUAAQJ+RjlAwBaAQAUAAQJ+RjlAwBaAQAAAA==.',
['超元']='超元气萌你妹:BAABLgAFFH8JAAIeAAQJHwgfAwD+AAAeAAQJHwgfAwD+AAAAAA==.',
['迈出']='迈出第二步:BAAALgAFFAQJBAAAAA==.',
['迟到']='迟到的下午:BAABLgAECn8rAAISAAkJMh88AgBLAwASAAkJMh88AgBLAwAAAA==.',
['迷乱']='迷乱耀阳:BAAALgAECgkJCgAAAA==.',
['遥望']='遥望光年:BAAALgAECgYJCgAAAA==.',
['醉梦']='醉梦忆生:BAABLgAFFH8IAAICAAQJIibrAADHAQACAAQJIibrAADHAQAAAA==.',
['野性']='野性植物:BAAALgADCgYJCwAAAA==.',
['野枫']='野枫:BAAALgAECgEJAQAAAA==.',
['银河']='银河的小不:BAAALgAECgYJBwAAAA==.',
['闲云']='闲云:BAAALgADCgEJAQABLgAFFAQJCQAVADsVAA==.',
['阿七']='阿七:BAABLgAECn8VAAMZAAgJ8xQhBwAqAQAKAAcJdhPIeQCRAQAZAAYJRxchBwAqAQAAAA==.',
['阿亿']='阿亿克:BAAALgAECgcJCAAAAA==.',
['阿史']='阿史那杜尔:BAAALgADCgEJAQAAAA==.',
['阿瓦']='阿瓦达啃大瓜:BAAALgAECgkJCgAAAA==.',
['阿萨']='阿萨姆德萨:BAAALgAECgYJDAAAAA==.',
['陆芝']='陆芝:BAAALgAECgMJAwAAAA==.',
['随机']='随机嗨姓刷子:BAAALgAECgYJBgAAAA==.',
['雲烟']='雲烟过眼:BAAALgADCgYJBgAAAA==.',
['露丶']='露丶娜:BAAALgAECggJAwAAAA==.',
['青青']='青青兰若:BAAALgAECgcJBwAAAA==.',
['非著']='非著名财主:BAAALgAECgQJBQAAAA==.',
['风中']='风中花火:BAAALgAECgEJBAAAAA==.',
['风之']='风之天香:BAAALgAECgMJAwAAAA==.',
['风暴']='风暴萨:BAAALgAFFAIJAwAAAA==.',
['麻糊']='麻糊糊小肉包:BAAALgAECgkJEwAAAA==.',
['黑索']='黑索协奏曲:BAAALgAECgUJBQAAAA==.',
['黑长']='黑长直:BAAALgADCgEJAQAAAA==.',
['黒莲']='黒莲:BAAALgAECgIJAgAAAA==.',
['龙陵']='龙陵牧:BAAALgAECgEJAgAAAA==.',
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
