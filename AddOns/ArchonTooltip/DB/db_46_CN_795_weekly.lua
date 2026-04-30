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

local lookup = {'DeathKnight-Unholy','Mage-Frost','Hunter-BeastMastery','Priest-Holy','Priest-Shadow','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','Shaman-Restoration','Shaman-Elemental','Paladin-Holy','Hunter-Marksmanship','Unknown-Unknown','Paladin-Retribution','Warlock-Affliction','Priest-Discipline','Warrior-Protection','Monk-Brewmaster','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','Warrior-Arms','DemonHunter-Havoc','Monk-Mistweaver','Monk-Windwalker','Druid-Balance','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','Druid-Restoration','Druid-Guardian','Warrior-Fury','DemonHunter-Devourer',}
local provider = {region='CN',realm='耳语海岸',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Arthur:BAAALgAECgEJAQAAAA==.Arthurmorgan:BAABLgAECn8aAAIBAAYJ5iDrRQAjAgABAAYJ5iDrRQAjAgAAAA==.',
Ba='Badbadbunnie:BAAALgAFFAQJBAAAAA==.',
Bi='Bige:BAAALgAECgYJCwAAAA==.',
Bu='Bulkhead:BAAALgAECgEJAwAAAA==.',
Ce='Celestia:BAAALgADCggJCAAAAA==.',
Dy='Dyew:BAAALgADCgQJBAAAAA==.',
Fr='Frostnova:BAABLgAECn8aAAICAAgJyR+FHgD7AgACAAgJyR+FHgD7AgAAAA==.',
Gh='Ghy:BAAALgAFFAIJBAAAAA==.',
Go='Good:BAAALgAECgIJAgAAAA==.',
Hu='Hugaga:BAAALgAFFAIJAwAAAA==.',
Ke='Kensou:BAABLgAFFH8KAAIDAAQJjRkdAwBlAQADAAQJjRkdAwBlAQAAAA==.',
Lc='Lchen:BAAALgAFFAIJBAAAAA==.',
Mi='Milenio:BAAALgAFFAEJAgAAAA==.',
Mo='Mondy:BAAALgAECgQJBgAAAA==.',
Ne='Neranger:BAAALgAECgIJAgAAAA==.',
Ns='Nsqaq:BAAALgAECgYJCwAAAA==.',
Pa='Pander:BAAALgAECgYJBgAAAA==.',
Qu='Quantum:BAABLgAFFH8IAAMEAAQJGBhpAwBeAQAEAAQJGBhpAwBeAQAFAAMJDxPWCgAGAQAAAA==.',
Re='Realy:BAAALgAECgUJBgAAAA==.',
Ri='Rilakkuma:BAABLgAECn8UAAMGAAYJoh+JVgDEAQAGAAUJoh+JVgDEAQAHAAIJYiFXPwC3AAAAAA==.',
Ru='Rubyms:BAAALgAFFAEJAgAAAA==.',
Sa='Sai:BAAALgAECgYJBgAAAA==.',
Sw='Sweeptosho:BAABLgAFFH8JAAIIAAQJ8wviBAAEAQAIAAQJ8wviBAAEAQAAAA==.',
Th='Thoughluck:BAABLgAFFH8HAAMJAAMJbQo2EQDeAAAJAAMJbQo2EQDeAAAKAAEJfQcTEgBMAAAAAA==.',
Ve='Vectorw:BAAALgAECgUJBQAAAA==.',
Vo='Voron:BAAALgAECgQJBAAAAA==.',
Xi='Xiaoorion:BAAALgAECgYJCgAAAA==.',
Zh='Zhyu:BAACLgAFFH8PAAMGAAQJxSFAHAAUAQAGAAMJLiFAHAAUAQAHAAEJiiMEBQBfAAAuAAQKfyUAAwYACAnoJLYUANkCAAYABwmiJLYUANkCAAcABQmgH8UQAMgBAAAA.',
['一宿']='一宿一:BAAALgAECgIJAgAAAA==.',
['一色']='一色彩羽:BAAALgAFFAMJBAABLgAFFAQJCgALAIUZAA==.',
['一路']='一路西菲尔一:BAAALgADCgUJBQAAAA==.',
['三分']='三分糖少冰:BAAALgADCgUJBQAAAA==.',
['丨莫']='丨莫淇洛丨:BAAALgAFFAIJAgAAAA==.',
['丨隔']='丨隔壁老钱丨:BAACLgAFFH8JAAIDAAQJkBOFBABaAQADAAQJkBOFBABaAQAuAAQKfxYAAwMABwl3Ghs0AN8BAAMABgleHBs0AN8BAAwABAlnESpfAMQAAAAA.',
['丶玉']='丶玉景灬天池:BAAALgAECgYJBwABLgAFFAYJAwANAAAAAA==.',
['乂莎']='乂莎:BAABLgAECn8XAAIOAAgJWQewfgB9AQAOAAgJWQewfgB9AQAAAA==.',
['乌龙']='乌龙不夜侯:BAAALgAECgYJBgAAAA==.',
['乱拳']='乱拳:BAAALgAECgUJBQAAAA==.',
['二哈']='二哈迪奥迪:BAAALgAECgIJAgAAAA==.',
['二次']='二次元:BAACLgAFFH8KAAICAAQJxxvDEwB8AQACAAQJxxvDEwB8AQAuAAQKfyEAAgIACQnoItUIAIADAAIACQnoItUIAIADAAAA.',
['云既']='云既无心出迶:BAAALgAECgYJCgAAAA==.',
['云树']='云树绕堤沙:BAABLgAECn8dAAQGAAcJUCCbKABvAgAGAAcJUCCbKABvAgAHAAIJaRGTTgCCAAAPAAEJAAC5LwA/AAABLgAFFAUJEgAQANQXAA==.',
['人道']='人道是战神:BAAALgAECgIJAwAAAA==.',
['仙山']='仙山木龙:BAAALgADCgcJDgAAAA==.',
['休闲']='休闲东东:BAAALgAFFAQJBAAAAA==.',
['修逻']='修逻:BAABLgAECn8kAAIRAAgJISbFAQBlAwARAAgJISbFAQBlAwAAAA==.',
['倒影']='倒影红尘:BAACLgAFFH8HAAICAAMJ7hI6KgAMAQACAAMJ7hI6KgAMAQAuAAQKfxcAAgIABwkjGkRjABMCAAIABwkjGkRjABMCAAAA.',
['偷你']='偷你苦茶子:BAAALgADCgEJAQAAAA==.',
['光棍']='光棍奶萨:BAAALgAECgIJAwAAAA==.',
['兰茵']='兰茵蔽月:BAAALgADCgcJBwAAAA==.',
['冰灬']='冰灬奥:BAAALgAECgIJAgAAAA==.',
['冷血']='冷血一刀:BAAALgAECgYJBgAAAA==.',
['几十']='几十个术仕:BAAALgAECgEJAQAAAA==.几十个武神:BAABLgAECn8bAAISAAgJWBfGBwCgAQASAAgJWBfGBwCgAQAAAA==.几十个猎魔人:BAAALgADCgcJEgABLgAECggJGwASAFgXAA==.',
['凤凰']='凤凰使者:BAAALgADCgMJAwAAAA==.',
['凶猛']='凶猛小桃:BAAALgAFFAEJAQAAAA==.',
['出云']='出云天花:BAABLgAFFH8GAAIBAAMJ8w3lFADvAAABAAMJ8w3lFADvAAAAAA==.',
['制裁']='制裁丶:BAAALgAECggJCQAAAA==.',
['刺骨']='刺骨寒寒:BAAALgAECgUJBQAAAA==.',
['加盾']='加盾男爵:BAAALgAECgYJBQAAAA==.',
['劲工']='劲工坊:BAAALgAECgQJBAAAAA==.',
['北大']='北大路五月:BAAALgAECgUJBwAAAA==.',
['北极']='北极没有夏天:BAAALgAFFAEJAQAAAA==.',
['只会']='只会划水:BAAALgADCgEJAQAAAA==.',
['叮叮']='叮叮咚:BAABLgAFFH8YAAMTAAYJdRRYAwBhAQATAAUJOhlYAwBhAQAUAAEJZAEdBABIAAAAAA==.',
['叮咚']='叮咚叮:BAABLgAFFH8KAAITAAQJphL1CABeAQATAAQJphL1CABeAQAAAA==.',
['叮铛']='叮铛叮:BAAALgAFFAQJBAAAAA==.',
['可爱']='可爱多:BAAALgAECgYJBgAAAA==.',
['叶叶']='叶叶:BAAALgAECgQJBAABLgAECggJJAAVAIkkAA==.',
['吃小']='吃小牛一拳:BAAALgAECgUJBQAAAA==.',
['告别']='告别:BAAALgAECgcJEgAAAA==.',
['呛口']='呛口小火锅:BAAALgAECgEJAgAAAA==.',
['哇真']='哇真的是你呀:BAABLgAFFH8GAAIWAAMJ0w8dAwD1AAAWAAMJ0w8dAwD1AAAAAA==.',
['哈喉']='哈喉的老腊肉:BAAALgADCgEJAQAAAA==.',
['哈基']='哈基咪咕:BAAALgAECgYJBgAAAA==.',
['哈妮']='哈妮:BAAALgAFFAQJBAAAAA==.',
['哈迪']='哈迪斯的怒吼:BAABLgAFFH8KAAMHAAQJXiIUCQDIAAAHAAIJbyIUCQDIAAAGAAIJTSJ6KwDCAAAAAA==.',
['唠啦']='唠啦丶氪唠馥:BAAALgAECgEJAQAAAA==.',
['喝着']='喝着百事想你:BAAALgAECgEJAgABLgAECgUJBgANAAAAAA==.',
['圣光']='圣光悠忽着你:BAAALgAECgEJAQAAAA==.',
['地藏']='地藏魔:BAAALgAECgUJBQAAAA==.',
['坏心']='坏心眼雷达:BAAALgAECgEJAQAAAA==.',
['坐看']='坐看雲起:BAAALgADCgEJAQAAAA==.',
['基维']='基维思:BAAALgAFFAEJAQAAAA==.',
['夏爾']='夏爾:BAAALgADCgYJBgAAAA==.',
['夏荷']='夏荷春香:BAAALgAECgcJBwAAAA==.',
['外比']='外比巴卜:BAAALgADCgMJAwAAAA==.',
['夜过']='夜过子:BAACLgAFFH8NAAIKAAQJxRlDCABXAQAKAAQJxRlDCABXAQAuAAQKfxcAAgoACAmVIJgJAPgCAAoACAmVIJgJAPgCAAAA.',
['夜鹰']='夜鹰之王:BAAALgAECgYJCwAAAA==.',
['大王']='大王叫我巡山:BAAALgAECgYJDQAAAA==.',
['大耳']='大耳朵波波:BAACLgAFFH8KAAIIAAQJugMaCwDLAAAIAAQJugMaCwDLAAAuAAQKfxQAAggABwnlBmsqAOsAAAgABwnlBmsqAOsAAAAA.',
['大蕉']='大蕉丶:BAAALgAECgEJAwAAAA==.',
['天王']='天王:BAAALgADCgEJAQAAAA==.',
['天界']='天界神龙:BAAALgADCgEJAQAAAA==.',
['奶爆']='奶爆:BAACLgAFFH8IAAMQAAMJrA8xCADxAAAQAAMJrA8xCADxAAAFAAIJhhDHDwCnAAAuAAQKfxQAAgUABwmiGm0dAO8BAAUABwmiGm0dAO8BAAAA.',
['奶萨']='奶萨:BAABLgAECn8bAAIJAAgJCCT1BAAiAwAJAAgJCCT1BAAiAwAAAA==.',
['妖子']='妖子不乖:BAAALgAECgQJBAAAAA==.',
['嫣嘫']='嫣嘫若夕:BAAALgAECgMJAwAAAA==.',
['封之']='封之不死噩魔:BAABLgAECn8VAAIXAAkJLwYREQCnAAAXAAkJLwYREQCnAAAAAA==.封之不死小德:BAAALgAECgYJCwAAAA==.封之不死骑士:BAABLgAFFH8FAAIOAAIJZBHyIwCkAAAOAAIJZBHyIwCkAAAAAA==.',
['小波']='小波:BAAALgAFFAIJAgAAAA==.',
['小犄']='小犄角长尾巴:BAACLgAFFH8JAAIJAAQJ5RiOBwBNAQAJAAQJ5RiOBwBNAQAuAAQKfxYAAgkABwnYIeoRAIcCAAkABwnYIeoRAIcCAAAA.',
['小琛']='小琛琛爷爷:BAAALgADCgUJBQAAAA==.',
['小痴']='小痴不忧郁:BAAALgAECgEJAQAAAA==.',
['小章']='小章鱼:BAAALgAECgQJBQAAAA==.',
['小脑']='小脑斧:BAAALgAECgcJCgAAAA==.',
['小茑']='小茑依依:BAAALgADCgcJCQAAAA==.',
['小锤']='小锤捶你胸口:BAAALgAFFAIJAwAAAA==.',
['小鸽']='小鸽:BAACLgAFFH8LAAMYAAQJ4SMKBACqAQAYAAQJ4SMKBACqAQAZAAIJjSGvBQDOAAAuAAQKfyAAAxkACAl0JDAHAAoDABkABwkRJjAHAAoDABgACAnHI80FAAQDAAAA.',
['席德']='席德格勒斯:BAAALgAECgMJBQAAAA==.',
['干瘪']='干瘪老头:BAAALgAECgUJBgAAAA==.',
['幸福']='幸福白勺泡泡:BAAALgAECgkJCAAAAA==.幸福白勺米米:BAAALgAECgMJAwAAAA==.幸福白勺贝贝:BAAALgAECgYJBwAAAA==.',
['幻丶']='幻丶月:BAAALgAFFAEJAQAAAA==.',
['弈殇']='弈殇:BAAALgADCgEJAQAAAA==.',
['强力']='强力熊:BAAALgAECgYJBgAAAA==.',
['强尼']='强尼银手:BAAALgADCgYJBgAAAA==.',
['得闲']='得闲剪鼻毛:BAAALgAECgMJAwAAAA==.',
['徽墨']='徽墨:BAAALgAECgYJDQABLgAFFAQJCQASAGILAA==.',
['恋恋']='恋恋的宝宝:BAAALgAECggJCAAAAA==.',
['恐虐']='恐虐神选者:BAACLgAFFH8NAAMBAAUJdx49CACOAQABAAQJdx49CACOAQAIAAEJAAAvFABRAAAuAAQKfxgAAgEACAkeJaoPACADAAEACAkeJaoPACADAAAA.',
['慕思']='慕思沙曼:BAAALgADCgUJBQAAAA==.',
['慕雨']='慕雨先生:BAAALgAECgYJBgAAAA==.',
['戈拉']='戈拉:BAAALgAECgUJBgAAAA==.',
['我家']='我家的小璐璐:BAABLgAFFH8GAAIDAAIJ5h5YDgDIAAADAAIJ5h5YDgDIAAAAAA==.',
['打不']='打不过就跑吧:BAAALgAECgUJDAAAAA==.',
['拉切']='拉切尔:BAAALgADCgEJAQABLgAECgUJBgANAAAAAA==.',
['招招']='招招猎猎:BAAALgAECgUJDwAAAA==.',
['捌幺']='捌幺伍:BAABLgAFFH8OAAITAAUJWRG6AwBaAQATAAUJWRG6AwBaAQAAAA==.',
['放下']='放下就不纠结:BAAALgAECgYJEgAAAA==.',
['文鸯']='文鸯:BAAALgADCgEJAQAAAA==.',
['斗宗']='斗宗:BAACLgAFFH8KAAITAAQJFCYSAwDMAQATAAQJFCYSAwDMAQAuAAQKfxUAAhMABwnSI1wPAK4CABMABwnSI1wPAK4CAAAA.',
['方羽']='方羽墨:BAAALgAECgcJDQAAAA==.方羽然:BAAALgAECgYJBgAAAA==.方羽萌:BAAALgAECgMJBAAAAA==.',
['无能']='无能的妻子:BAAALgAECgcJDAAAAA==.',
['昔涟']='昔涟:BAAALgAECgYJEQABLgAFFAEJAQANAAAAAA==.',
['晓之']='晓之狼:BAAALgAECgYJDQAAAA==.',
['曌楽']='曌楽梓:BAAALgAECgYJBgAAAA==.',
['曼陀']='曼陀罗的记忆:BAABLgAFFH8FAAIaAAMJjwT+CADYAAAaAAMJjwT+CADYAAAAAA==.',
['最后']='最后坦格利安:BAAALgAECgYJDgAAAA==.',
['月夜']='月夜風暴:BAAALgAFFAIJAgAAAA==.',
['月满']='月满梢:BAABLgAFFH8IAAIaAAMJbxxiBgAQAQAaAAMJbxxiBgAQAQAAAA==.',
['月神']='月神的忽悠:BAAALgAECgYJBgAAAA==.',
['机灵']='机灵小不懂:BAAALgAECgMJAwAAAA==.',
['李丶']='李丶書文:BAABLgAFFH8GAAIYAAIJ9ANoEwB6AAAYAAIJ9ANoEwB6AAAAAA==.',
['杰赛']='杰赛索:BAAALgAECgQJBAAAAA==.',
['松饼']='松饼猫酱:BAAALgAFFAIJAgAAAA==.',
['柯拉']='柯拉德:BAAALgAFFAEJAQAAAA==.',
['树林']='树林间小猪猪:BAAALgAECgkJCQAAAA==.',
['核电']='核电皮卡丘:BAAALgAFFAEJAQAAAA==.',
['梦溪']='梦溪笔谭:BAAALgAECgcJDgABLgAFFAQJBgACAAIYAA==.',
['梵丶']='梵丶夜:BAABLgAECn8aAAICAAYJWxofGwCTAQACAAYJWxofGwCTAQAAAA==.',
['梶猗']='梶猗:BAABLgAFFH8IAAQbAAMJPQoHFADaAAAbAAMJuQYHFADaAAAcAAEJ9A3kAgBZAAAdAAEJdASlGAA9AAAAAA==.',
['楽鸽']='楽鸽:BAACLgAFFH8KAAICAAQJzAlAIgA0AQACAAQJzAlAIgA0AQAuAAQKfxQAAgIABwmtDNClAI0BAAIABwmtDNClAI0BAAAA.',
['樱雨']='樱雨桥:BAAALgAECgQJBQAAAA==.',
['欺雪']='欺雪凌霜:BAAALgAECgcJEgAAAA==.',
['正义']='正义审判者:BAAALgAECgMJBAAAAA==.',
['正道']='正道滄桑:BAAALgAECgIJAgAAAA==.',
['歪嘴']='歪嘴战神:BAAALgADCgQJBgAAAA==.',
['汤汤']='汤汤水水:BAAALgADCgUJBQAAAA==.',
['法丝']='法丝不是很累:BAAALgAECgcJCwAAAA==.',
['法師']='法師丶:BAAALgADCgIJAgAAAA==.',
['泡泡']='泡泡小小:BAAALgADCgEJAQABLgAFFAMJCAAEAOwTAA==.泡泡蝴蝶:BAABLgAFFH8IAAIEAAMJ7BNeCADiAAAEAAMJ7BNeCADiAAAAAA==.',
['流星']='流星坠落:BAABLgAFFH8KAAQaAAQJUQm8CADhAAAaAAMJPgq8CADhAAAeAAMJjgtwEgDVAAAfAAEJigYaBwA2AAAAAA==.',
['浅醉']='浅醉:BAAALgAECgEJAQAAAA==.',
['浣花']='浣花洗剑:BAABLgAECn8aAAQRAAcJTw7sHwBCAQARAAcJIQ7sHwBCAQAWAAQJhBAADADOAAAgAAMJ5wpMkwBxAAABLgAFFAQJCQASAGILAA==.',
['深海']='深海海鲜:BAACLgAFFH8GAAMbAAMJehdaEAD/AAAbAAMJehdaEAD/AAAdAAEJxwoAGABCAAAuAAQKfxkAAxsABwkgGuUYAAgCABsABwkgGuUYAAgCAB0ABgmjHXQWAOcBAAEuAAUUAwkIABAArA8A.',
['清风']='清风明月:BAABLgAFFH8JAAISAAQJYgv3EAD3AAASAAQJYgv3EAD3AAAAAA==.',
['温水']='温水:BAAALgAECgUJCAAAAA==.',
['溧阳']='溧阳凤凰公园:BAAALgAECgQJBAAAAA==.',
['滕子']='滕子京:BAABLgAECn8eAAIDAAcJIR+dHwBIAgADAAcJIR+dHwBIAgAAAA==.',
['灬九']='灬九歌灬:BAACLgAFFH8HAAILAAMJRxjBEgCyAAALAAMJRxjBEgCyAAAuAAQKfxkAAgsACAl3FL4HAO0BAAsACAl3FL4HAO0BAAAA.',
['灬伊']='灬伊卡丶洛斯:BAAALgAECgEJAQAAAA==.',
['灵月']='灵月馨香:BAAALgAECgYJBgAAAA==.',
['炎之']='炎之审判:BAAALgAECgQJBAAAAA==.',
['爆炸']='爆炸妹:BAAALgAECgYJDAAAAA==.',
['爱丶']='爱丶悦:BAAALgAECgEJAgAAAA==.',
['爸爸']='爸爸可以哦:BAABLgAFFH8HAAIIAAMJhAXfBwCiAAAIAAMJhAXfBwCiAAAAAA==.',
['牛哒']='牛哒哒:BAAALgAECgQJBAAAAA==.',
['牛妖']='牛妖丸辣:BAAALgAECgEJAgABLgAECgUJBgANAAAAAA==.',
['狂风']='狂风冷寂:BAAALgAECgQJBAAAAA==.狂风神龍:BAAALgAFFAEJAQAAAA==.',
['猫丸']='猫丸:BAABLgAECn8XAAMSAAgJuh4fEQCPAgASAAgJuh4fEQCPAgAYAAUJOQZNSwCrAAAAAA==.',
['玉腿']='玉腿肩上扛:BAAALgAFFAMJAwAAAA==.',
['王初']='王初初:BAAALgAECgYJDAAAAA==.',
['玖哒']='玖哒哒:BAAALgAECgEJAQAAAA==.',
['玛莲']='玛莲妮娅:BAAALgAECgUJBwAAAA==.',
['瓦尔']='瓦尔基丽雅:BAAALgAECgQJBAAAAA==.',
['甜心']='甜心奶兔酱:BAAALgAECgYJCwAAAA==.',
['盲剑']='盲剑客:BAAALgAFFAIJBAAAAA==.',
['真白']='真白花音丶:BAAALgAFFAQJBAAAAA==.',
['磁力']='磁力棒:BAAALgAFFAEJAQAAAA==.',
['神乐']='神乐:BAAALgAECgYJBgABLgAFFAYJCgAEAEkcAA==.',
['神圣']='神圣星星:BAABLgAFFH8JAAIEAAMJyyDKBQAlAQAEAAMJyyDKBQAlAQAAAA==.',
['神箭']='神箭丘比特:BAAALgAECgYJDgAAAA==.',
['神隐']='神隐的八云紫:BAAALgAECgMJAwAAAA==.',
['穷困']='穷困潦倒:BAAALgAECgEJAQAAAA==.',
['米丨']='米丨小贼:BAAALgAECgkJCQAAAA==.',
['米丶']='米丶乐乐:BAAALgAECgMJAwAAAA==.',
['米乐']='米乐乐丶:BAABLgAECn8UAAQYAAcJJwozOwD8AAAYAAcJJwozOwD8AAASAAQJ4Q/KGwChAAAZAAQJRAWFYgCFAAAAAA==.',
['米拉']='米拉杰:BAAALgAFFAEJAgAAAA==.',
['糖三']='糖三角:BAAALgAECgcJBQAAAA==.',
['素衣']='素衣风尘:BAAALgAFFAMJAwAAAA==.',
['索拉']='索拉卡的救赎:BAAALgAECgEJAQAAAA==.',
['紫色']='紫色幽林:BAAALgAECgEJAQAAAA==.',
['紫苏']='紫苏红袖:BAAALgADCgcJBwAAAA==.紫苏青柠:BAAALgAECgQJBAAAAA==.',
['紫血']='紫血冰枫:BAACLgAFFH8FAAMFAAMJnBjEBwDPAAAFAAIJOyLEBwDPAAAEAAEJ5RXqEQBWAAAuAAQKfxYAAwUABwk6IPUOAJQCAAUABwk6IPUOAJQCAAQABAm9GS1GACABAAEuAAUUBAkGAAIAAhgA.',
['给桃']='给桃子的信:BAAALgADCgEJAQAAAA==.',
['罗祖']='罗祖:BAACLgAFFH8GAAIGAAMJ/wsYIwCdAAAGAAMJ/wsYIwCdAAAuAAQKfx0AAwYACAlGFRpOAN4BAAYABwlGFRpOAN4BAAcAAgnXDulMAIcAAAAA.',
['美丽']='美丽加芬:BAAALgAECgYJDwAAAA==.',
['翡翠']='翡翠之末:BAAALgAECgEJAwAAAA==.',
['自摸']='自摸双翻东:BAAALgAECgQJBAAAAA==.',
['色眯']='色眯眯的小德:BAAALgAECgEJAQAAAA==.',
['艾尔']='艾尔玛:BAAALgAECgkJCQAAAA==.',
['艾艾']='艾艾:BAAALgAECgcJDQAAAA==.',
['艾莉']='艾莉尔:BAAALgAECgYJDAAAAA==.',
['花芽']='花芽堇:BAACLgAFFH8KAAILAAQJhRnyAwBdAQALAAQJhRnyAwBdAQAuAAQKfxcAAwsACAkoIowSAH4CAAsABwnGIowSAH4CAA4AAwmcEH/vALEAAAAA.',
['茉之']='茉之祭礼:BAAALgAECgcJDwAAAA==.',
['莫淇']='莫淇洛:BAAALgAECgIJAwAAAA==.',
['菊花']='菊花怪七号:BAAALgAFFAEJAQAAAA==.',
['萌萌']='萌萌的菠萝包:BAAALgAECgIJAgABLgAFFAQJBAAGABkXAA==.萌萌的菠蘿包:BAAALgAFFAEJAQABLgAFFAQJBAAGABkXAA==.',
['蒂雅']='蒂雅波尔:BAAALgAECgUJBAAAAA==.',
['蒜蓉']='蒜蓉甜胚子:BAACLgAFFH8MAAILAAMJfRI0DgDzAAALAAMJfRI0DgDzAAAuAAQKfxoAAgsACQm7FwIOAKgCAAsACQm7FwIOAKgCAAAA.',
['藤井']='藤井树:BAAALgAFFAIJAwABLgAFFAYJFQAhAG4VAA==.',
['藤田']='藤田琴音:BAAALgAECgYJBgAAAA==.',
['藥師']='藥師兜:BAAALgADCgEJAQAAAA==.',
['蛇皮']='蛇皮皮虾:BAAALgAFFAIJBAAAAA==.',
['蛋神']='蛋神:BAAALgAECgEJAgAAAA==.',
['血战']='血战到底:BAAALgAECgUJCAAAAA==.',
['血月']='血月殇:BAAALgAECgQJBQAAAA==.',
['被圣']='被圣光灌注惹:BAAALgAFFAIJAwAAAA==.',
['西门']='西门小雪:BAAALgAECgYJCwAAAA==.',
['诅咒']='诅咒丶:BAACLgAFFH8KAAMGAAQJahZEIQD/AAAGAAMJaxREIQD/AAAHAAEJaBy/EQBcAAAuAAQKfxQAAwYABwkqGidjAKEBAAYABgkYGCdjAKEBAAcAAwmUFbk7AMUAAAAA.',
['诗意']='诗意江山:BAAALgAFFAQJBAAAAA==.',
['读到']='读到对白:BAAALgAECgcJDQAAAA==.',
['谢尔']='谢尔盖:BAAALgADCgQJBAAAAA==.',
['豊川']='豊川祥子:BAAALgAFFAIJAgAAAA==.',
['超级']='超级变便便:BAAALgAECgYJBQAAAA==.',
['踏雪']='踏雪寻魔:BAAALgAECgEJAQAAAA==.',
['达摩']='达摩佛咯:BAAALgADCgUJBQAAAA==.',
['迅雷']='迅雷疾风:BAABLgAECn8aAAMSAAYJAyJnCgBuAQASAAUJmSFnCgBuAQAYAAEJwAyobAAqAAAAAA==.',
['远江']='远江听叶:BAAALgAECgYJCQAAAA==.',
['迪剋']='迪剋牛仔:BAAALgADCgYJBwAAAA==.',
['迷人']='迷人小祖宗:BAAALgAECgYJBgAAAA==.',
['迷糊']='迷糊的麋鹿吖:BAAALgAFFAIJAgABLgAFFAMJCAAEAOwTAA==.',
['逍遥']='逍遥若汐:BAABLgAECn8aAAMeAAYJRBQrFQBKAQAeAAUJOhYrFQBKAQAfAAEJzgTjNAAiAAAAAA==.',
['逐风']='逐风者之箭:BAAALgADCgMJAwAAAA==.',
['逝风']='逝风痕:BAAALgAECgEJAQAAAA==.',
['進姬']='進姬:BAAALgAECgEJAwAAAA==.',
['遠方']='遠方的約定:BAACLgAFFH8HAAIgAAMJMyHVDQApAQAgAAMJMyHVDQApAQAuAAQKfxYAAxYABwl6HVsFAF8BACAABgmUHForAAkCABYABQmYHlsFAF8BAAAA.',
['那里']='那里不可以:BAAALgAFFAIJAgAAAA==.',
['酒肆']='酒肆梦桃夭:BAAALgAECgQJAQABLgAECgYJGQAWAKodAA==.',
['醉光']='醉光阴:BAAALgAECgQJBAAAAA==.',
['醉后']='醉后缠眠:BAACLgAFFH8KAAMGAAQJGB3zDQAfAQAGAAQJdRvzDQAfAQAHAAEJ2BV6EwBXAAAuAAQKfxsAAwYABwkXHmIxAEcCAAYABwmGHGIxAEcCAAcABAmJHYYbAHEBAAAA.',
['钅盏']='钅盏椛:BAAALgAECgEJAQAAAA==.',
['铁汉']='铁汉也柔情:BAAALgAECgUJCAAAAA==.',
['银痕']='银痕羽迹:BAAALgADCgIJAgAAAA==.',
['长命']='长命:BAAALgADCgUJBQAAAA==.',
['阿尔']='阿尔塔夏:BAAALgAECgcJBwAAAA==.',
['阿白']='阿白白丶:BAACLgAFFH8VAAMhAAYJbhXjBgC1AQAhAAYJcQ3jBgC1AQAXAAQJzxmfAgBlAQAuAAQKfx0AAxcACQnCISIFACEDABcACAlXIyIFACEDACEABgncE2taAJIBAAAA.',
['雅儿']='雅儿贝德丶:BAAALgAFFAEJAQAAAA==.',
['青树']='青树湖都:BAAALgAECgYJDgAAAA==.',
['静谧']='静谧之声:BAAALgAECgUJBQAAAA==.',
['风中']='风中樱:BAAALgAECgIJAgAAAA==.',
['风滢']='风滢:BAAALgADCgQJBAAAAA==.',
['饶孙']='饶孙弟:BAAALgAECgYJDAAAAA==.',
['香草']='香草可颂:BAAALgAECgEJAQAAAA==.',
['马丽']='马丽莲梦呓:BAABLgAECn8aAAILAAYJJgmFGQDyAAALAAYJJgmFGQDyAAAAAA==.',
['骤雨']='骤雨初歇:BAABLgAFFH8FAAIYAAMJ+huBDQDLAAAYAAMJ+huBDQDLAAAAAA==.',
['高不']='高不成低不就:BAAALgAECgEJAQAAAA==.',
['高大']='高大得白菜:BAAALgAECgYJBgAAAA==.',
['魔之']='魔之殤:BAAALgAECgYJBgAAAA==.',
['魔影']='魔影暗语:BAABLgAFFH8DAAIGAAMJHCKnGgAeAQAGAAMJHCKnGgAeAQAAAA==.',
['魔法']='魔法西瓜:BAAALgADCgEJAQAAAA==.',
['鲁鲁']='鲁鲁:BAAALgADCgUJBQAAAA==.',
['黄衣']='黄衣的阿肥:BAAALgAFFAMJAwAAAA==.',
['黑夜']='黑夜问白天:BAABLgAFFH8GAAICAAQJAhgkEgAgAQACAAQJAhgkEgAgAQAAAA==.',
['黑鐵']='黑鐵丶戰士:BAAALgADCgUJBQAAAA==.',
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
