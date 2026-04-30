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

local lookup = {'Evoker-Preservation','DemonHunter-Devourer','Priest-Discipline','DeathKnight-Unholy','DeathKnight-Blood','Unknown-Unknown','Priest-Holy','Monk-Mistweaver','Evoker-Augmentation','Warlock-Demonology','Paladin-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Druid-Balance','Druid-Restoration','Priest-Shadow','Paladin-Retribution','Warlock-Destruction','Warrior-Fury','Warrior-Arms','Warlock-Ranged','Monk-Brewmaster','Evoker-Devastation','Warlock-Affliction',}
local provider = {region='CN',realm='托塞德林',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akasoul:BAAALgAECgYJCQAAAA==.',
Al='Alkalmi:BAABLgAFFH8HAAIBAAcJDxLfAABcAgABAAcJDxLfAABcAgAAAA==.',
Aw='Awaken:BAAALgAECgYJDgAAAA==.',
Ba='Bakboon:BAAALgAECgcJDgAAAA==.',
Be='Bera:BAABLgAFFH8FAAICAAUJkAu3CAApAQACAAUJkAu3CAApAQABLgAFFAUJBQACAPUVAA==.',
Bl='Blackblood:BAAALgAECgcJDAAAAA==.',
Cr='Crisy:BAAALgAECgEJAQAAAA==.',
Ec='Eclipsare:BAAALgAFFAQJBAAAAA==.',
Fr='Frieren:BAAALgADCgYJBgAAAA==.',
Fu='Fuze:BAABLgAFFH8KAAIDAAYJBhzbBgByAQADAAYJBhzbBgByAQAAAA==.',
Ho='Horacio:BAAALgAFFAEJAQAAAA==.',
Ku='Kumo:BAABLgAFFH8HAAMEAAUJXxmaDwBjAQAEAAQJXxmaDwBjAQAFAAEJAADvFABJAAAAAA==.',
Nd='Nd:BAAALgAECgcJCgAAAA==.',
Re='Reniya:BAAALgAECgYJCgAAAA==.',
Su='Superbimango:BAAALgAFFAIJAgAAAA==.',
Te='Ternura:BAAALgADCgMJAgABLgAECgYJGAAEACYkAA==.',
Va='Var:BAAALgAECgUJBgABLgAECgcJDAAGAAAAAA==.Vare:BAAALgAECgMJAwABLgAECgcJDAAGAAAAAA==.',
['一只']='一只鹿盔:BAAALgADCgEJAQAAAA==.',
['一拳']='一拳一个:BAAALgAECgQJBQAAAA==.',
['一瞬']='一瞬千擊:BAAALgAFFAQJBAAAAA==.',
['一面']='一面:BAAALgAFFAMJAwAAAA==.',
['丁度']='丁度巴拉斯:BAAALgAECgEJAQAAAA==.',
['上午']='上午睡觉:BAAALgAFFAQJBAABLgAFFAYJCAAHAEYRAA==.',
['世界']='世界悲:BAACLgAFFH8LAAIIAAcJiBixAAB4AgAIAAcJiBixAAB4AgAuAAQKfxcAAggABwlVJI8IAMwCAAgABwlVJI8IAMwCAAEuAAUUCAkZAAEAOSUA.',
['丶云']='丶云迹:BAAALgAECgYJBgABLgAFFAUJAwAGAAAAAA==.',
['丶提']='丶提丰:BAAALgAFFAQJAgABLgAFFAUJAwAGAAAAAA==.',
['丶明']='丶明椒:BAAALgAFFAQJAgABLgAFFAUJAwAGAAAAAA==.',
['丶柳']='丶柳德米拉:BAAALgAFFAUJAwAAAA==.',
['丶海']='丶海霓:BAAALgAFFAQJAQABLgAFFAUJAwAGAAAAAA==.',
['丶玛']='丶玛丽安娜:BAAALgAFFAUJAwABLgAFFAUJAwAGAAAAAA==.',
['丶贝']='丶贝丽尔:BAAALgAFFAQJAQABLgAFFAUJAwAGAAAAAA==.',
['主人']='主人:BAAALgAECgcJBwAAAA==.',
['乂斷']='乂斷乂卝怒麸:BAAALgAECgYJBgAAAA==.',
['乄尐']='乄尐囧:BAABLgAFFH8GAAIIAAYJOxbRAQASAgAIAAYJOxbRAQASAgABLgAFFAYJCgAIAJkZAA==.乄尐雾囧:BAABLgAFFH8JAAIIAAUJuh01AQDQAQAIAAUJuh01AQDQAQABLgAFFAYJCgAIAJkZAA==.乄尐黑囧:BAABLgAFFH8KAAIIAAYJmRlwAAAhAgAIAAYJmRlwAAAhAgAAAA==.',
['乐邦']='乐邦詹士:BAAALgAECgkJAgAAAA==.',
['九幽']='九幽暗魔人:BAAALgADCgMJAwAAAA==.',
['云啃']='云啃山:BAAALgAFFAcJAQAAAA==.',
['你伤']='你伤害呢丷:BAAALgAFFAQJBAABLgAFFAgJFgAJAH0HAA==.',
['你真']='你真难看:BAABLgAFFH8GAAIKAAIJ/xAiGgCfAAAKAAIJ/xAiGgCfAAAAAA==.',
['你给']='你给我果赖:BAAALgAECgUJCAAAAA==.',
['再也']='再也不熬夜了:BAAALgAFFAUJAQAAAA==.',
['冬至']='冬至丷:BAABLgAFFH8LAAILAAUJ7hXfAgDAAQALAAUJ7hXfAgDAAQAAAA==.',
['冰棒']='冰棒:BAACLgAFFH8RAAMMAAUJMx48BwAuAQAMAAQJCCI8BwAuAQANAAMJRRNJFgDoAAAuAAQKfyEAAwwACQkoIQMZAHICAAwACAlqIgMZAHICAA0ABgkUF6s/AFoBAAAA.',
['凯瑟']='凯瑟琳女王:BAAALgAECgQJBAAAAA==.',
['刃舞']='刃舞:BAAALgAECgYJDAAAAA==.',
['初秋']='初秋:BAAALgADCgYJBgAAAA==.',
['北风']='北风那个吹:BAAALgAECgUJBQAAAA==.',
['千羽']='千羽丷:BAAALgAECgEJAgAAAA==.',
['华佗']='华佗:BAAALgAECgYJBgAAAA==.',
['南风']='南风知我意:BAAALgAECgQJBAAAAA==.',
['印象']='印象屮舞步:BAAALgAECgEJAQAAAA==.',
['双魚']='双魚理:BAABLgAFFH8HAAIOAAQJIBo6FQB1AQAOAAQJIBo6FQB1AQABLgAFFAYJCwAOAMUbAA==.',
['叫不']='叫不太醒:BAAALgAFFAQJBAAAAA==.',
['台风']='台风交个消失:BAAALgAFFAQJBAABLgAFFAUJAwAGAAAAAA==.',
['听劝']='听劝:BAAALgAECgQJBgAAAA==.',
['咕咕']='咕咕太拼命了:BAAALgAECgYJCAAAAA==.',
['囡囝']='囡囝囚团:BAABLgAFFH8IAAIPAAQJ1A6CDAAdAQAPAAQJ1A6CDAAdAQABLgAFFAYJCAAHAEYRAA==.',
['土霸']='土霸王:BAAALgAECgkJCQAAAA==.',
['处暑']='处暑丷:BAABLgAFFH8MAAILAAUJNRiUBACWAQALAAUJNRiUBACWAQAAAA==.',
['夏慕']='夏慕槿苏丶:BAABLgAFFH8GAAIKAAMJdQTAJwDbAAAKAAMJdQTAJwDbAAAAAA==.',
['夏梦']='夏梦玫珑:BAAALgAECgkJCwABLgAFFAUJBQAQAJkcAA==.',
['夙琤']='夙琤:BAAALgAFFAQJBAAAAA==.',
['大丨']='大丨爆:BAAALgADCggJCAABLgAECggJHgACAHUXAA==.',
['大爷']='大爷逍遥游:BAAALgAECgQJBQAAAA==.',
['天之']='天之川沙夜:BAACLgAFFH8RAAIRAAUJYSEMAgDtAQARAAUJYSEMAgDtAQAuAAQKfyUAAxEACAnlImAFADoDABEACAnlImAFADoDAAcAAgkcIgAAAAAAAAAA.',
['天堂']='天堂门前的猫:BAAALgAECgEJAgAAAA==.',
['夺命']='夺命剪刀脚:BAAALgAECgkJEgAAAA==.',
['奔跑']='奔跑的那只猫:BAAALgAECgEJAQAAAA==.',
['奥姆']='奥姆尼空洞:BAABLgAFFH8FAAIBAAUJbSC9AgDrAQABAAUJbSC9AgDrAQAAAA==.',
['奶昔']='奶昔:BAAALgAECgEJAQAAAA==.',
['姬魅']='姬魅蓝:BAAALgAECgUJBgABLgAFFAMJAwAGAAAAAA==.',
['子龙']='子龙:BAAALgADCgQJBAAAAA==.',
['季浩']='季浩洋:BAAALgAECgkJDgAAAA==.',
['宁姚']='宁姚:BAAALgAECgQJBQAAAA==.',
['寒辰']='寒辰星少:BAAALgAECgcJCwAAAA==.',
['小小']='小小劣人:BAAALgADCgYJBgAAAA==.小小妖:BAAALgAECgYJBwAAAA==.',
['小狐']='小狐狸米纱:BAAALgAECgYJBgAAAA==.',
['小红']='小红手王哥:BAAALgAFFAMJAwAAAA==.',
['小青']='小青团:BAAALgAFFAIJAwAAAA==.',
['小黄']='小黄手红哥:BAAALgAFFAQJBAAAAA==.',
['尔等']='尔等必软:BAAALgAECgEJAQAAAA==.',
['屠尽']='屠尽日寇:BAAALgAFFAQJBAAAAA==.',
['希尔']='希尔瓦拉斯:BAAALgADCgIJAwAAAA==.',
['希灵']='希灵:BAAALgAECgUJBQAAAA==.',
['希腊']='希腊神话:BAABLgAFFH8IAAIPAAQJRhQ8CQBRAQAPAAQJRhQ8CQBRAQABLgAFFAYJCAAHAEYRAA==.',
['带刺']='带刺百合:BAAALgAECgYJBgAAAA==.',
['年过']='年过古稀:BAABLgAFFH8IAAIPAAQJlxdvCABaAQAPAAQJlxdvCABaAQABLgAFFAYJCAAHAEYRAA==.',
['开门']='开门见喜:BAAALgAECgIJAgAAAA==.',
['待敌']='待敌:BAACLgAFFH8HAAILAAMJ1hTbBQD9AAALAAMJ1hTbBQD9AAAuAAQKfx8AAgsABwmoHKxDAGkBAAsABwmoHKxDAGkBAAAA.',
['徐总']='徐总不是区:BAABLgAFFH8FAAICAAUJJQ7dBwA0AQACAAUJJQ7dBwA0AQABLgAFFAUJBQACAPUVAA==.徐总是不是区:BAABLgAFFH8FAAICAAUJ9RW2BwCoAQACAAUJ9RW2BwCoAQAAAA==.徐总还是区:BAAALgAFFAUJBAABLgAFFAUJBQACAPUVAA==.',
['恋如']='恋如雨止:BAABLgAECn8VAAMSAAgJHR5cQQAhAgASAAcJCR5cQQAhAgALAAIJ3Q69JABAAAAAAA==.',
['恶魔']='恶魔的调掉:BAAALgAECgEJAQAAAA==.',
['懒大']='懒大王:BAAALgAFFAQJBAAAAA==.',
['我在']='我在冲了你呢:BAABLgAFFH8NAAMEAAUJvRhvEgBYAQAEAAQJvRhvEgBYAQAFAAEJAADxEQBjAAAAAA==.我在水里游:BAAALgAECgUJBQAAAA==.',
['我是']='我是奶龙:BAAALgAFFAEJAgAAAA==.',
['战殇']='战殇:BAAALgAECgIJAgAAAA==.',
['拉布']='拉布布:BAAALgAECgMJAwAAAA==.',
['挑灯']='挑灯看剑:BAAALgADCgIJAgAAAA==.',
['摇摇']='摇摇虎:BAABLgAFFH8KAAIFAAUJgwY8CAAIAQAFAAUJgwY8CAAIAQAAAA==.',
['摘星']='摘星:BAAALgAECgYJCgAAAA==.',
['救救']='救救我:BAAALgAECgEJAQAAAA==.',
['救赎']='救赎:BAAALgAECgYJBgAAAA==.',
['敖丙']='敖丙:BAACLgAFFH8ZAAIBAAgJOSUCAABdAwABAAgJOSUCAABdAwAuAAQKfxsAAgEACAlXJfUBAF0DAAEACAlXJfUBAF0DAAAA.',
['无名']='无名小德:BAAALgAFFAEJAQAAAA==.',
['无形']='无形的正义:BAAALgAECgUJCAAAAA==.',
['无牧']='无牧司:BAAALgAECgEJAQAAAA==.',
['旺仔']='旺仔的夜法:BAAALgAECgEJAgAAAA==.',
['星锑']='星锑幻想:BAABLgAFFH8FAAIBAAUJWBoBBADAAQABAAUJWBoBBADAAQAAAA==.',
['昨日']='昨日的世界:BAAALgAFFAMJBAAAAA==.',
['曾辉']='曾辉:BAAALgAECgYJBgAAAA==.',
['末希']='末希:BAAALgADCgEJAgAAAA==.',
['机智']='机智的加菲猫:BAAALgAFFAUJAwAAAA==.',
['朽月']='朽月凝霜:BAAALgAECgYJCAAAAA==.',
['李沁']='李沁:BAAALgAECgYJDgAAAA==.',
['松花']='松花江上:BAABLgAFFH8FAAIPAAUJdw1EBgCCAQAPAAUJdw1EBgCCAQABLgAFFAYJCAAHAEYRAA==.',
['枕头']='枕头:BAABLgAECn8dAAIOAAgJVRzyFQCTAQAOAAgJVRzyFQCTAQAAAA==.',
['林中']='林中白狼:BAABLgAECn8cAAIPAAkJrh+mBwAcAwAPAAkJrh+mBwAcAwAAAA==.',
['果汁']='果汁分她一半:BAAALgADCgUJBQAAAA==.',
['栖川']='栖川:BAABLgAFFH8LAAIBAAcJZht/AACJAgABAAcJZht/AACJAgAAAA==.',
['梦烬']='梦烬:BAABLgAFFH8KAAMKAAQJmSRyBwCtAQAKAAQJmSRyBwCtAQATAAIJoxIGDACrAAAAAA==.',
['棒棒']='棒棒哒:BAAALgAFFAIJAwAAAA==.',
['樱羽']='樱羽艾玛:BAAALgAECgcJCAAAAA==.',
['橋本']='橋本環奈:BAAALgAECgEJAQAAAA==.',
['橙橙']='橙橙丶:BAAALgAECgYJCAAAAA==.',
['殇之']='殇之逝:BAAALgAECgQJBAAAAA==.',
['殢无']='殢无伤:BAAALgAECgYJCwABLgAFFAQJBAAGAAAAAA==.',
['水蓝']='水蓝色天空:BAAALgAECgcJBwAAAA==.',
['污喵']='污喵王:BAAALgAECgQJBAAAAA==.',
['汪利']='汪利丹丶怒风:BAAALgAECgUJCgABLgAFFAMJCAAFAN0CAA==.',
['油焖']='油焖大虾:BAAALgADCgEJAgAAAA==.',
['油爆']='油爆枇杷:BAAALgAECgEJAQAAAA==.',
['泠樾']='泠樾:BAABLgAFFH8GAAIDAAYJcReQAAAiAgADAAYJcReQAAAiAgAAAA==.',
['洛克']='洛克塔尔:BAACLgAFFH8FAAIUAAQJEA9fDAA+AQAUAAQJEA9fDAA+AQAuAAQKfxQAAxQACAmCG18EAPYBABQACAmCG18EAPYBABUAAQnvDGQTAD0AAAAA.',
['流云']='流云蔽日:BAAALgAECgkJDAAAAA==.',
['流雲']='流雲:BAAALgAECgkJCQABLgAFFAQJCAAEAI8bAA==.',
['淦中']='淦中学:BAABLgAFFH8JAAIUAAMJ9xhdDgAfAQAUAAMJ9xhdDgAfAQAAAA==.',
['渣渣']='渣渣:BAAALgAECgQJCAAAAA==.',
['潘安']='潘安:BAAALgAECgEJAQAAAA==.',
['灬福']='灬福罗贝:BAAALgAECgcJBAAAAA==.',
['然然']='然然:BAAALgAECgkJEQABLgAFFAQJBgARAAcWAA==.',
['爱吃']='爱吃小西瓜灬:BAAALgAECgUJBQAAAA==.爱吃小酥肉灬:BAAALgAECgUJBgAAAA==.',
['爽弄']='爽弄晚安好腿:BAAALgAFFAUJAQABLgAFFAUJBQACAPUVAA==.爽弄晚安瘸腿:BAABLgAFFH8FAAICAAUJuA+KDQDwAAACAAUJuA+KDQDwAAABLgAFFAUJBQACAPUVAA==.',
['牛小']='牛小花灬:BAABLgAFFH8OAAILAAYJZhpaBACaAQALAAYJZhpaBACaAQAAAA==.',
['狂摸']='狂摸晚安好腿:BAAALgAFFAUJAwABLgAFFAUJBQACAPUVAA==.',
['猫咪']='猫咪:BAAALgAFFAIJAwAAAA==.',
['猴师']='猴师傅德:BAAALgADCgEJAQAAAA==.',
['玓圷']='玓圷扦:BAABLgAFFH8FAAIBAAUJGBjTBACrAQABAAUJGBjTBACrAQAAAA==.',
['瓦格']='瓦格里:BAACLgAFFH8JAAIHAAQJZh+qAgAaAQAHAAQJZh+qAgAaAQAuAAQKfxkAAwcABwnZIkULAJsCAAcABwnZIkULAJsCAAMAAwkYILcxABMBAAAA.',
['留白']='留白:BAAALgAECgMJAwAAAA==.',
['白露']='白露丷:BAABLgAFFH8GAAILAAUJ0ReNAwCuAQALAAUJ0ReNAwCuAQAAAA==.',
['白鹿']='白鹿:BAAALgADCgUJCgAAAA==.',
['皮卡']='皮卡兵:BAAALgAECgEJAQAAAA==.',
['盲目']='盲目吃鱼之神:BAACLgAFFH8OAAIQAAQJmxeQCQA9AQAQAAQJmxeQCQA9AQAuAAQKfxUAAhAACAmzFjgqAAkCABAACAmzFjgqAAkCAAAA.',
['盲眼']='盲眼猎手卡恩:BAAALgAECgYJBgAAAA==.',
['眉清']='眉清目秀:BAAALgAECgcJDQAAAA==.',
['眉目']='眉目不清:BAABLgAECn8WAAMQAAkJdh+xDQDNAgAQAAcJGCSxDQDNAgAPAAIJQhURYQCdAAAAAA==.',
['神秘']='神秘的加菲猫:BAAALgAFFAUJAgABLgAFFAUJAwAGAAAAAA==.',
['福尔']='福尔德摩特:BAAALgAFFAIJAgAAAA==.',
['立秋']='立秋丷:BAABLgAFFH8PAAILAAYJCh+YAwCtAQALAAYJCh+YAwCtAQAAAA==.',
['章若']='章若楠:BAAALgAECgMJAwABLgAFFAUJBQAWAKQVAA==.',
['第一']='第一时间甩锅:BAACLgAFFH8NAAIKAAQJfhsIDAB8AQAKAAQJfhsIDAB8AQAuAAQKfysAAwoACQllIwYDAJEDAAoACQllIwYDAJEDABMAAgkPEw5KAJAAAAAA.',
['米妮']='米妮薇珂:BAAALgAECgcJBwAAAA==.',
['绾禛']='绾禛:BAAALgAFFAMJAwAAAA==.',
['缄默']='缄默德克萨斯:BAAALgAFFAQJBAABLgAFFAUJAwAGAAAAAA==.',
['美美']='美美哒:BAAALgAECgcJBwAAAA==.',
['翟老']='翟老师:BAABLgAFFH8HAAMNAAQJGg0tEAAvAQANAAQJGg0tEAAvAQAMAAEJQQA4LgAlAAAAAA==.',
['老将']='老将盖乌斯:BAAALgAECgcJBwABLgAFFAgJGQABADklAA==.',
['老白']='老白的哀木提:BAAALgAECgEJAQAAAA==.老白的坦克:BAAALgAECgUJBQAAAA==.老白的狄克:BAAALgADCgMJAwAAAA==.老白的狼人:BAAALgADCgIJAgAAAA==.老白的狼德:BAAALgADCgMJAwAAAA==.老白的骑士:BAAALgADCgEJAQAAAA==.',
['耄耋']='耄耋之年:BAABLgAFFH8JAAIPAAUJGBqTBACiAQAPAAUJGBqTBACiAQABLgAFFAYJCAAHAEYRAA==.',
['耶梦']='耶梦加德:BAAALgAECgcJAgAAAA==.',
['聖園']='聖園未花:BAAALgADCgEJAQABLgAFFAUJEQARAGEhAA==.',
['肥肚']='肥肚肚左卫门:BAACLgAFFH8LAAISAAQJTx25CABrAQASAAQJTx25CABrAQAuAAQKfxoAAhIACAm1H50SAP4CABIACAm1H50SAP4CAAAA.',
['艾丝']='艾丝蒂尔:BAACLgAFFH8FAAIIAAIJNgM0FABpAAAIAAIJNgM0FABpAAAuAAQKfxUAAggABwlcCuw5AAMBAAgABwlcCuw5AAMBAAAA.',
['若舞']='若舞清风丶:BAAALgAFFAIJAgAAAA==.',
['英雄']='英雄挽歌:BAAALgAFFAIJAgABLgAFFAcJCwAXAM0PAA==.',
['茕茕']='茕茕孑立:BAAALgAFFAQJBAABLgAFFAYJCAAHAEYRAA==.',
['草莓']='草莓可丽十:BAAALgAFFAUJBAAAAA==.草莓可丽十二:BAAALgAFFAUJAgABLgAFFAUJBQAJAAMcAA==.草莓可丽十五:BAAALgAFFAQJAgAAAA==.草莓可丽饼一:BAAALgAFFAQJAgABLgAFFAUJBQAJAAMcAA==.草莓可丽饼七:BAAALgAFFAUJAgABLgAFFAUJBQAJAAMcAA==.草莓可丽饼乂:BAAALgAFFAQJBAAAAA==.草莓可丽饼二:BAABLgAFFH8FAAMJAAQJbh4VHwBZAAAJAAEJNiMVHwBZAAABAAQJNx8AAAAAAAABLgAFFAUJBQAJAAMcAA==.草莓可丽饼五:BAAALgAFFAQJAwABLgAFFAUJBQAJAAMcAA==.草莓可丽饼亿:BAAALgAFFAUJAQABLgAFFAUJBQAJAAMcAA==.草莓可丽饼依:BAAALgAFFAQJAQAAAA==.草莓可丽饼八:BAAALgAFFAUJAgABLgAFFAUJBQAJAAMcAA==.草莓可丽饼六:BAAALgAFFAQJAwABLgAFFAUJBQAJAAMcAA==.草莓可丽饼医:BAAALgAFFAUJAQAAAA==.草莓可丽饼壹:BAABLgAFFH8FAAIJAAQJAxwhCABtAQAJAAQJAxwhCABtAQAAAA==.草莓可丽饼零:BAAALgAFFAUJAQABLgAFFAUJBQAJAAMcAA==.',
['荞麦']='荞麦面:BAABLgAECn8cAAQBAAkJcBBNGQDEAQABAAkJcBBNGQDEAQAYAAYJEhMwHQBFAQAJAAIJzwbzVABwAAABLgAECgcJFQATACMWAA==.',
['萌奇']='萌奇帝路飛:BAAALgAECgIJAwAAAA==.',
['蕾伊']='蕾伊丽雅:BAAALgADCgQJBAAAAA==.',
['蘫冰']='蘫冰麟:BAACLgAFFH8VAAQKAAYJ+B+MAQArAgAKAAYJgh2MAQArAgATAAIJHx9uCQDBAAAZAAEJAAABAwBiAAAuAAQKfx4AAwoACQk7JCADAI8DAAoACQnvIyADAI8DABMAAgm1IC4+ALwAAAEuAAUUBwkHAAoAOhwA.',
['街头']='街头王老法:BAABLgAFFH8FAAIOAAIJlRTHOgC1AAAOAAIJlRTHOgC1AAAAAA==.',
['衣酌']='衣酌浅斟:BAAALgAECgYJBgAAAA==.',
['许哥']='许哥是区:BAAALgAFFAQJBAABLgAFFAUJBQACAPUVAA==.',
['话梅']='话梅排骨:BAAALgAFFAQJBAABLgAFFAYJCAAHAEYRAA==.',
['轰鸣']='轰鸣月:BAACLgAFFH8RAAIBAAUJwCWNAQAmAgABAAUJwCWNAQAmAgAuAAQKfx0ABAEABwn7ISgJAKQCAAEABwn7ISgJAKQCABgABglOGqcXAH0BAAkAAwl5Hvs+AO4AAAAA.',
['轻描']='轻描淡写:BAAALgAFFAQJBAAAAA==.',
['辰月']='辰月之狐:BAAALgAFFAEJAwAAAA==.',
['郭小']='郭小鸡:BAAALgAECgYJBQAAAA==.',
['醉落']='醉落夕风丶:BAABLgAFFH8LAAIMAAMJHRlxCgAOAQAMAAMJHRlxCgAOAQAAAA==.',
['长夜']='长夜月:BAAALgAECgEJAQAAAA==.',
['长风']='长风当歌:BAACLgAFFH8LAAIEAAQJxRMmGQBBAQAEAAQJxRMmGQBBAQAuAAQKfxoAAgQACAmTIjggAMECAAQACAmTIjggAMECAAEuAAUUBQkPABIAZiEA.',
['阿布']='阿布达雷:BAAALgAECgYJCgAAAA==.',
['阿达']='阿达米尔:BAAALgADCgUJBQAAAA==.',
['陈小']='陈小北丶:BAAALgAFFAEJAQABLgAFFAcJBQAIAJYfAA==.',
['陈风']='陈风暴醉酒:BAAALgAECgkJEAAAAA==.',
['难受']='难受想哭:BAAALgAECgEJAQAAAA==.',
['雪见']='雪见山青猫:BAABLgAFFH8KAAIPAAQJWA8QBAAqAQAPAAQJWA8QBAAqAQAAAA==.',
['雷声']='雷声普化天尊:BAAALgAECgEJAQAAAA==.',
['霜降']='霜降丷:BAABLgAFFH8LAAILAAUJPRjlAwCmAQALAAUJPRjlAwCmAQAAAA==.',
['青眼']='青眼究极龙:BAAALgAECgYJCQABLgAFFAUJAQAGAAAAAA==.',
['青鹭']='青鹭小红手:BAAALgAECgIJAgAAAA==.',
['风袭']='风袭逍遥:BAAALgAECgQJBAAAAA==.',
['飞飞']='飞飞人:BAAALgAECgYJDAAAAA==.',
['香蕉']='香蕉:BAACLgAFFH8JAAIPAAUJJxF2BgB9AQAPAAUJJxF2BgB9AQAuAAQKfxoAAg8ACQm7HHsHAB4DAA8ACQm7HHsHAB4DAAAA.',
['马洛']='马洛恩:BAAALgADCgYJBgAAAA==.',
['骨质']='骨质疏松:BAABLgAFFH8FAAIPAAUJ6Q5GBgCCAQAPAAUJ6Q5GBgCCAQAAAA==.',
['魂熵']='魂熵:BAAALgAECgUJCQAAAA==.',
['麦麦']='麦麦子:BAAALgAECgcJDwAAAA==.',
['黑瞳']='黑瞳月:BAAALgAECgkJCQAAAA==.',
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
