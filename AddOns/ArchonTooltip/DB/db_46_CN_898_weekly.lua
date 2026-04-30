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

local lookup = {'DeathKnight-Unholy','Priest-Discipline','Paladin-Retribution','Evoker-Preservation','Rogue-Subtlety','Unknown-Unknown','Warlock-Demonology','Warlock-Destruction','Priest-Shadow','Priest-Holy','DeathKnight-Frost','DeathKnight-Blood','Mage-Frost','Paladin-Holy','Paladin-Protection','Monk-Windwalker','Monk-Brewmaster','Warrior-Fury','Warrior-Arms','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','DemonHunter-Devourer','Druid-Restoration','Evoker-Augmentation','Evoker-Devastation','Shaman-Restoration','Rogue-Outlaw','Monk-Mistweaver','Shaman-Elemental','Warrior-Protection',}
local provider = {region='CN',realm='黑暗魅影',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bi='Biggie:BAAALgAECggJEQAAAA==.Bingdkai:BAABLgAFFH8FAAIBAAIJqRhnHgCmAAABAAIJqRhnHgCmAAAAAA==.',
Co='Coralgay:BAABLgAFFH8HAAICAAIJnBKrEwCYAAACAAIJnBKrEwCYAAAAAA==.Coralover:BAABLgAFFH8FAAIDAAIJsyUBGgDTAAADAAIJsyUBGgDTAAAAAA==.',
De='Deathtalon:BAAALgAECgkJDwAAAA==.Dedede:BAAALgAECgMJBQAAAA==.',
Dr='Dragolon:BAAALgAECgUJCAAAAA==.',
Fa='Fallansky:BAAALgAECgUJBQAAAA==.',
Ft='Fta:BAAALgAECgMJAwAAAA==.',
Ho='Howe:BAAALgAFFAEJAgAAAA==.',
Ja='Jaunszc:BAAALgAECgYJDAAAAA==.',
Lo='Locoloco:BAAALgAECgQJBgAAAA==.',
Me='Meteion:BAAALgADCgUJBQAAAA==.',
Mi='Mingevoaa:BAAALgAFFAYJAgAAAA==.Mingevobb:BAABLgAFFH8IAAIEAAQJoyUMBgCTAQAEAAQJoyUMBgCTAQAAAA==.Mingevocc:BAABLgAFFH8RAAIEAAYJByU9AABYAgAEAAYJByU9AABYAgABLgAFFAcJGQAEACUmAA==.Mingevodd:BAABLgAFFH8OAAIEAAYJciUWAACEAgAEAAYJciUWAACEAgABLgAFFAcJGQAEACUmAA==.',
No='Nothing:BAACLgAFFH8HAAIFAAMJ3xGvBwABAQAFAAMJ3xGvBwABAQAuAAQKfyEAAgUACAmzFJQVAGQCAAUACAmzFJQVAGQCAAAA.',
Pr='Profane:BAAALgAECgEJAQABLgAFFAYJBAAGAAAAAA==.',
Ri='Riaven:BAAALgAECgcJCgAAAA==.',
['一一']='一一过来:BAAALgAECgIJAgAAAA==.',
['七月']='七月半:BAAALgADCgMJAwAAAA==.',
['万叶']='万叶:BAAALgAECgcJDwAAAA==.',
['不死']='不死鈈滅一:BAABLgAFFH8IAAMHAAQJkw5HIwD3AAAHAAMJGxBHIwD3AAAIAAEJ+wkGFwBRAAAAAA==.',
['东多']='东多鲁玛:BAAALgADCgYJBgAAAA==.',
['东方']='东方姑娘丶:BAABLgAECn8gAAQJAAgJLRI0GAAhAgAJAAgJLRI0GAAhAgACAAYJ3hyrFgDsAQAKAAEJ1Q48ewA7AAAAAA==.东方精灵:BAAALgAECgkJEgAAAA==.',
['东海']='东海帝皇:BAACLgAFFH8FAAIBAAIJuSGdMgC+AAABAAIJuSGdMgC+AAAuAAQKfx0ABAEACAndHtwjAK8CAAEACAndHtwjAK8CAAsAAQltG40JAFIAAAwAAQm1GrZCAD8AAAEuAAUUAwkKAA0A/xkA.',
['丨丶']='丨丶忧郁:BAAALgAFFAIJAwAAAQ==.',
['丨聖']='丨聖光無用丨:BAAALgAFFAIJAwAAAA==.',
['中江']='中江江:BAAALgAECgEJAQAAAA==.',
['丰川']='丰川祥子:BAACLgAFFH8KAAINAAMJ/xlSFQAMAQANAAMJ/xlSFQAMAQAuAAQKfxcAAg0ABwlFIgk5AJECAA0ABwlFIgk5AJECAAAA.',
['丷小']='丷小西:BAAALgADCgYJBgAAAA==.',
['为了']='为了联盟:BAABLgAECn8RAAMIAAgJ8RWqKAAgAQAHAAYJGRhkkgA0AQAIAAQJWBKqKAAgAQAAAA==.',
['乱舞']='乱舞死神:BAAALgAFFAIJAgAAAA==.',
['亚卿']='亚卿:BAAALgAECgIJAwAAAA==.',
['他还']='他还得谢谢咱:BAABLgAECn8aAAMOAAgJcBlcGQBIAgAOAAgJcBlcGQBIAgAPAAQJkgmQEACBAAAAAA==.',
['以一']='以一贯之:BAAALgAFFAEJAQAAAA==.',
['以壹']='以壹贯之:BAABLgAFFH8GAAIQAAMJ2htnBgAVAQAQAAMJ2htnBgAVAQAAAA==.',
['低调']='低调衬托奢华:BAAALgAECgEJAgAAAA==.',
['元始']='元始天尊:BAAALgADCgcJBwAAAA==.',
['光与']='光与影的平衡:BAABLgAECn8eAAMKAAcJkhBfOwBNAQAKAAYJBhFfOwBNAQACAAUJygtmNQD5AAAAAA==.',
['八神']='八神去一:BAACLgAFFH8HAAIBAAMJ3B0kJAAFAQABAAMJ3B0kJAAFAQAuAAQKfx0AAgEACAlGH9EMANMBAAEACAlGH9EMANMBAAAA.',
['冥界']='冥界晓晓:BAAALgAECgEJAQAAAA==.',
['冰与']='冰与火之格格:BAABLgAFFH8FAAINAAUJIw1rEgCDAQANAAUJIw1rEgCDAQAAAA==.',
['凤凰']='凤凰天使:BAAALgAECgEJAQAAAA==.',
['凤舞']='凤舞丨轩儿:BAACLgAFFH8FAAIBAAIJZRuvOACqAAABAAIJZRuvOACqAAAuAAQKfyIAAgEACAmgHtIoAJcCAAEACAmgHtIoAJcCAAAA.',
['刀圣']='刀圣丶断天:BAAALgAECgcJDwAAAA==.',
['勇敢']='勇敢的神灵大:BAAALgAECgYJCQAAAA==.',
['十一']='十一月生:BAAALgAECgQJBAAAAA==.',
['午安']='午安丶:BAAALgAFFAMJBAAAAA==.',
['卡布']='卡布奇诺灬:BAAALgAFFAEJAQAAAA==.',
['压迫']='压迫众生:BAABLgAFFH8FAAIBAAIJlxBSPgCiAAABAAIJlxBSPgCiAAAAAA==.',
['厚德']='厚德在无:BAAALgAECgcJDAAAAA==.',
['原神']='原神大王周张:BAAALgADCgMJAwAAAA==.',
['双魚']='双魚理:BAAALgAFFAMJAgABLgAFFAYJCwANAMUbAA==.',
['发射']='发射点发大水:BAAALgAECgcJCgAAAA==.',
['发苗']='发苗功:BAAALgAECgYJCgAAAA==.',
['只会']='只会寒冰箭:BAAALgAECgQJBAAAAA==.',
['可乐']='可乐丶:BAABLgAFFH8MAAINAAQJ2R4aEgCFAQANAAQJ2R4aEgCFAQAAAA==.',
['右左']='右左耳:BAAALgAECgQJBAABLgAECgIJBAAGAAAAAA==.',
['咿呀']='咿呀咿呀吆:BAAALgAECgYJBgAAAA==.',
['哈米']='哈米吉:BAAALgAECgYJDAAAAA==.',
['唐大']='唐大叔:BAAALgAECgUJBQAAAA==.',
['啊我']='啊我的小乖乖:BAAALgAECgUJCAAAAA==.',
['四月']='四月初三:BAAALgADCgEJAQAAAA==.',
['圣光']='圣光吃了你:BAAALgAECgUJCgAAAA==.',
['地牢']='地牢一刻:BAABLgAFFH8GAAIBAAIJdBU0PQCkAAABAAIJdBU0PQCkAAAAAA==.',
['壹玖']='壹玖零零:BAAALgAECgQJBwAAAA==.',
['多乐']='多乐麦披萨:BAAALgAECgYJAwAAAA==.',
['多听']='多听五月天:BAAALgAECgQJBAAAAA==.',
['大哥']='大哥来咯:BAAALgAECgQJBAAAAA==.',
['大学']='大学物理:BAAALgAECgcJDwAAAA==.',
['大松']='大松狮:BAABLgAFFH8GAAIRAAMJlxHLEwDaAAARAAMJlxHLEwDaAAAAAA==.',
['大濕']='大濕兄:BAAALgAECgEJAQAAAA==.',
['大胆']='大胆:BAAALgAECgEJAQAAAA==.',
['天道']='天道大圆满:BAAALgAECgcJCwAAAA==.',
['奶牛']='奶牛杀手:BAABLgAECn8UAAMSAAkJxxd+LQD9AQASAAgJshh+LQD9AQATAAMJ8xKCCgDoAAAAAA==.',
['奶茶']='奶茶果果:BAAALgAECgYJBgAAAA==.',
['好韵']='好韵来:BAAALgAECgUJCAAAAA==.',
['妳的']='妳的名字:BAAALgAECgUJBQABLgAFFAMJCQADALwcAA==.',
['婉若']='婉若游龙:BAAALgAECgQJAQAAAA==.',
['宇宙']='宇宙和音:BAAALgAECgYJEQAAAA==.',
['宝宝']='宝宝的宝贝:BAAALgAECgEJAQAAAA==.',
['宝爷']='宝爷同款:BAAALgADCgYJBgAAAA==.',
['寂寞']='寂寞的可乐:BAAALgADCgEJAQAAAA==.',
['导演']='导演:BAACLgAFFH8JAAIUAAMJfg4hDQD4AAAUAAMJfg4hDQD4AAAuAAQKfxcABBUACAlLGFoUAIABABUABgmQFloUAIABABQABAkxGcRjADwBABYAAQkAAKScAAMAAAAA.',
['小诺']='小诺诺:BAAALgAECgYJCQAAAA==.',
['小麦']='小麦:BAACLgAFFH8GAAIXAAMJAhG7GwD0AAAXAAMJAhG7GwD0AAAuAAQKfxUAAhcACAlPE9BCAOkBABcACAlPE9BCAOkBAAAA.',
['就武']='就武器还不行:BAAALgAECggJCQABLgAFFAUJCAASAIweAA==.',
['岩井']='岩井宗久:BAAALgAECgcJBwAAAA==.',
['岳绮']='岳绮罗:BAAALgAECgUJCwAAAA==.',
['巭嘦']='巭嘦孬灬嫑粜:BAAALgAFFAEJAQAAAA==.',
['幻影']='幻影光灵:BAAALgADCgEJAQAAAA==.',
['弑冰']='弑冰:BAAALgAECgcJCwAAAA==.',
['影之']='影之冰鱼:BAAALgAECgkJBwAAAA==.',
['恶子']='恶子:BAAALgADCgEJAQAAAA==.',
['恶魔']='恶魔玩具:BAAALgAECgIJAwAAAA==.',
['悬壶']='悬壶济世灬:BAAALgAECgUJBwAAAA==.',
['我只']='我只会功夫:BAAALgAECgMJBAAAAA==.',
['我是']='我是个打工的:BAACLgAFFH8JAAIDAAMJvBykCAAlAQADAAMJvBykCAAlAQAuAAQKfxsAAwMACAlcHdEjAJkCAAMACAlcHdEjAJkCAA8AAQmLDdtFACkAAAAA.',
['我有']='我有点紧张:BAACLgAFFH8LAAMUAAMJiCOzBgA2AQAUAAMJiCOzBgA2AQAWAAEJeAsxKgBHAAAuAAQKfx0AAxQACQn6H4UOAMcCABQABwmGIIUOAMcCABYABgmLH40pANwBAAAA.',
['把爱']='把爱带回家:BAACLgAFFH8FAAIYAAMJkAeSEQCBAAAYAAMJkAeSEQCBAAAuAAQKfxkAAhgACAkhFL8zANoBABgACAkhFL8zANoBAAAA.',
['拜月']='拜月者:BAAALgADCgIJAgAAAA==.',
['换跳']='换跳舞化工:BAAALgAECgQJBAAAAA==.',
['提狸']='提狸奥丶狐丁:BAAALgAECgkJEAAAAA==.',
['提里']='提里奥丶扶丁:BAAALgAECgYJDAAAAA==.',
['摸鱼']='摸鱼小能手:BAAALgAECgUJAwAAAA==.',
['放弃']='放弃再来:BAAALgADCgcJBwAAAA==.',
['早安']='早安丶:BAAALgAECgYJBgAAAA==.',
['晨星']='晨星:BAAALgAFFAEJAQAAAA==.',
['暴力']='暴力男的:BAAALgAECgIJAgAAAA==.',
['曦和']='曦和:BAAALgAECgkJDgAAAA==.',
['最爱']='最爱玩戰士:BAAALgAECgYJCQAAAA==.',
['月黄']='月黄泉:BAAALgADCgQJBAAAAA==.',
['朝紫']='朝紫柏:BAAALgADCgUJBQAAAA==.',
['木有']='木有武德:BAAALgAECgcJBwAAAA==.',
['木木']='木木小魚:BAAALgAECgEJAQAAAA==.木木小鱼:BAACLgAFFH8HAAICAAMJ7BhTDAAQAQACAAMJ7BhTDAAQAQAuAAQKfxgAAwIACAk7GzMQADwCAAIACAk7GzMQADwCAAkABAlKE15BAO4AAAEuAAQKAQkBAAYAAAAA.木木枭:BAAALgAECgYJEAABLgAECggJCAAGAAAAAA==.',
['木頭']='木頭秂:BAAALgAECgEJAQAAAA==.',
['来根']='来根华子:BAAALgAECgEJAQAAAA==.',
['柒鴿']='柒鴿鴿:BAAALgAECgYJCAAAAA==.',
['格兰']='格兰蒂亚之魂:BAAALgADCgcJDQAAAA==.',
['桃师']='桃师姐:BAABLgAFFH8IAAIYAAQJoxKmBwAYAQAYAAQJoxKmBwAYAQAAAA==.',
['梦游']='梦游娃娃:BAAALgAECgYJEQAAAA==.',
['梵天']='梵天厶忄:BAAALgADCgMJBAAAAA==.梵天米:BAAALgAECgEJAQAAAA==.',
['橘子']='橘子焦糖丶:BAAALgAFFAEJAQAAAA==.',
['欢喜']='欢喜就好:BAAALgAECgQJBQAAAA==.',
['死的']='死的快:BAAALgAECgMJAwAAAA==.',
['没所']='没所谓:BAAALgAECgEJAQAAAA==.',
['河合']='河合律:BAAALgADCgEJAQAAAA==.',
['洪兴']='洪兴老干妈:BAAALgAECgUJBQAAAA==.',
['流天']='流天类星龙:BAABLgAECn8UAAMZAAYJwBa0DQAwAQAaAAYJeQ/sHQA/AQAZAAYJMhW0DQAwAQABLgAFFAIJAgAGAAAAAA==.',
['海豹']='海豹:BAAALgAECgUJAQABLgAECgYJEQAGAAAAAA==.',
['潘妮']='潘妮希琳:BAAALgAECgEJAQAAAA==.',
['潮人']='潮人的红肚兜:BAAALgAECgEJAQAAAA==.',
['灬阿']='灬阿强灬:BAAALgAECgIJBAAAAA==.',
['点点']='点点小雨滴:BAAALgAECgQJCQAAAA==.',
['烮人']='烮人:BAAALgAECgEJAgAAAA==.',
['煉獄']='煉獄丶死神:BAAALgAECgYJEAAAAA==.',
['熊霸']='熊霸牛牛:BAAALgAECgYJCAAAAA==.',
['爱上']='爱上小鬼:BAABLgAFFH8IAAMIAAQJ5CO4AgCCAQAIAAQJmR64AgCCAQAHAAQJeSIAAAAAAAAAAA==.',
['爱在']='爱在西元前:BAAALgAECgUJBQAAAA==.',
['爱意']='爱意随枫:BAAALgAECgIJAgAAAA==.',
['牛奔']='牛奔的神:BAAALgAECgQJCAAAAA==.',
['牛宫']='牛宫妃那:BAAALgAECgYJCwAAAA==.',
['牧王']='牧王之王:BAAALgAECgQJAQAAAA==.',
['狐一']='狐一媚:BAAALgADCgUJBQAAAA==.',
['狐暴']='狐暴烈酒:BAAALgAECgUJBAAAAA==.',
['猛牛']='猛牛丸:BAAALgAECgYJEQAAAA==.',
['猫老']='猫老大:BAAALgAECgEJAQAAAA==.',
['玄阿']='玄阿:BAAALgADCgEJAQAAAA==.',
['玩累']='玩累歇一会儿:BAAALgADCgMJAwAAAA==.',
['生下']='生下来就死了:BAAALgAECgQJBAAAAA==.',
['番茄']='番茄饭饭:BAAALgAFFAMJAwAAAA==.',
['白菜']='白菜术术:BAAALgAECgQJBAAAAA==.',
['看上']='看上去很硬:BAAALgADCgcJBwAAAA==.',
['矮江']='矮江江:BAACLgAFFH8KAAIbAAMJbhGAEQDcAAAbAAMJbhGAEQDcAAAuAAQKfyIAAhsACAnPEhkuANEBABsACAnPEhkuANEBAAAA.',
['碎雨']='碎雨:BAAALgAECgYJCQAAAA==.',
['神圣']='神圣失格:BAAALgAECgQJBAAAAA==.',
['秦端']='秦端雨:BAABLgAFFH8FAAIbAAIJwha2FQCqAAAbAAIJwha2FQCqAAAAAA==.',
['精灵']='精灵小术:BAABLgAFFH8FAAIHAAIJXSS3FwDdAAAHAAIJXSS3FwDdAAAAAA==.',
['索利']='索利达尔:BAAALgAECgYJBwAAAA==.',
['紫色']='紫色天使:BAAALgAECgYJEQAAAA==.',
['终极']='终极吹牛:BAAALgAECgcJBwAAAA==.',
['维他']='维他奶:BAACLgAFFH8HAAIRAAMJyR4IDwALAQARAAMJyR4IDwALAQAuAAQKfxQAAhEABwnlGxUfAAkCABEABwnlGxUfAAkCAAAA.',
['老衲']='老衲启能容你:BAAALgADCgYJBgAAAA==.',
['耿鬼']='耿鬼大王:BAAALgAECgYJCAAAAA==.',
['聖丶']='聖丶光:BAAALgAECgIJAgAAAA==.',
['胡牛']='胡牛腰:BAAALgAECgMJAwAAAA==.',
['脸滚']='脸滚的荣光:BAAALgAECgQJBQAAAA==.',
['腥红']='腥红马库斯:BAAALgAECgMJAwAAAA==.',
['苍月']='苍月星辰:BAAALgADCgYJBgAAAA==.',
['苍穹']='苍穹的血骑士:BAAALgADCgcJBwAAAA==.',
['英俊']='英俊的神灵大:BAAALgADCgEJAQAAAA==.',
['草枝']='草枝百:BAABLgAECn8kAAMDAAgJvRVWHQBlAQADAAgJvRVWHQBlAQAOAAYJRAm8WQAVAQAAAA==.',
['药药']='药药丷切克闹:BAACLgAFFH8FAAMcAAMJHwyMAQCkAAAFAAIJ5AmOFACsAAAcAAMJ0AuMAQCkAAAuAAQKfxUAAgUACAm2ErgcABkCAAUACAm2ErgcABkCAAAA.',
['萌小']='萌小蹄:BAAALgAECgcJEgAAAA==.',
['薄荷']='薄荷味的夏天:BAAALgAECgUJBQAAAA==.',
['血之']='血之守护者:BAABLgAFFH8MAAIDAAQJVhSPDABHAQADAAQJVhSPDABHAQAAAA==.血之灬蜀黍:BAAALgAFFAIJAwAAAA==.',
['血染']='血染暗夜:BAAALgAFFAIJAgAAAA==.',
['西虹']='西虹市富婆:BAAALgAECgMJBAAAAA==.',
['西西']='西西克:BAAALgAECgIJAgAAAA==.',
['諸訷']='諸訷灬黃昏:BAABLgAFFH8IAAISAAMJchSwEAABAQASAAMJchSwEAABAQAAAA==.諸訷黃昏:BAAALgAECgcJDAABLgAFFAMJCAASAHIUAA==.',
['诶鸡']='诶鸡哥不在:BAAALgAECgUJBQAAAA==.',
['谋刹']='谋刹似水年华:BAAALgAECgcJCwAAAA==.',
['赤之']='赤之彗星:BAAALgAECgYJDAABLgAECgYJEQAGAAAAAA==.',
['赤犬']='赤犬:BAABLgAFFH8FAAINAAMJYQixSgCUAAANAAMJYQixSgCUAAAAAA==.',
['起舞']='起舞旋律:BAAALgAECgkJBAAAAA==.',
['超级']='超级江江:BAABLgAFFH8FAAIdAAUJIAOUBwBEAQAdAAUJIAOUBwBEAQAAAA==.',
['辣条']='辣条就晚饭:BAAALgAFFAIJAgABLgAFFAIJBQADALMlAA==.',
['辰辰']='辰辰不接:BAACLgAFFH8FAAIeAAMJnyOxCgA7AQAeAAMJnyOxCgA7AQAuAAQKfxwAAh4ACAkjIhEHACIDAB4ACAkjIhEHACIDAAAA.',
['远古']='远古的鹌鹑:BAABLgAFFH8FAAIYAAIJnBFuGgCTAAAYAAIJnBFuGgCTAAAAAA==.',
['逝去']='逝去之魂:BAAALgAECgQJBwAAAA==.',
['遨游']='遨游牛必撒:BAAALgAECgEJAQAAAA==.',
['醉狐']='醉狐:BAAALgAECgMJAwAAAA==.',
['问就']='问就是爱玩:BAAALgADCgEJAQAAAA==.',
['阿丝']='阿丝匹林:BAAALgAECgYJBgAAAA==.',
['阿峰']='阿峰:BAAALgADCgEJAQAAAA==.',
['阿拉']='阿拉贡:BAAALgAECgcJBwAAAA==.',
['阿瑞']='阿瑞莎特:BAAALgAECgMJBQAAAA==.',
['雅脩']='雅脩特拉:BAAALgAECgIJAgAAAA==.',
['霹雳']='霹雳小贱猪:BAAALgAECgEJAQAAAA==.',
['青衫']='青衫忆笙:BAAALgAECgEJAQAAAA==.',
['非酋']='非酋之怒:BAAALgAECgcJCgAAAA==.',
['韭菜']='韭菜:BAAALgAECgcJDgAAAA==.',
['风烈']='风烈梦游:BAAALgAECggJDgAAAA==.风烈火:BAAALgAECgYJBgAAAA==.风烈炎:BAAALgAFFAIJAgAAAA==.风烈焰:BAAALgAECgcJBwAAAA==.风烈焰爆:BAAALgAECgcJBwAAAA==.',
['香蕉']='香蕉拿不拿拿:BAAALgAECggJCAAAAA==.',
['马里']='马里昂:BAAALgAECgEJAQAAAA==.',
['骑子']='骑子:BAAALgAECgYJCQAAAA==.',
['高压']='高压锅:BAABLgAFFH8FAAIfAAIJLg1iDACEAAAfAAIJLg1iDACEAAAAAA==.',
['魔法']='魔法大帅:BAAALgAECgYJCwAAAA==.',
['鱼儿']='鱼儿小小:BAAALgAECgUJBQABLgAECgEJAQAGAAAAAA==.鱼儿莜莜:BAAALgAECgMJBAABLgAECgEJAQAGAAAAAA==.',
['鸡骨']='鸡骨酱拌面:BAAALgAECgkJCAABLgAFFAYJAwAGAAAAAA==.',
['黄昏']='黄昏灬諸訷:BAAALgAFFAIJAgABLgAFFAMJCAASAHIUAA==.',
['黄鹤']='黄鹤楼面包:BAAALgAECgMJAwAAAA==.',
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
