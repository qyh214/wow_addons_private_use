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

local lookup = {'DeathKnight-Unholy','Druid-Balance','DemonHunter-Devourer','DemonHunter-Havoc','Hunter-Marksmanship','Priest-Shadow','Priest-Discipline','Paladin-Retribution','Warlock-Demonology','Evoker-Augmentation','Mage-Frost','Hunter-BeastMastery','Hunter-Survival','Priest-Holy','DeathKnight-Blood','Unknown-Unknown','Evoker-Devastation','Druid-Restoration','Warrior-Fury','Shaman-Elemental','Monk-Brewmaster','Evoker-Preservation','Paladin-Holy',}
local provider = {region='CN',realm='冬拥湖',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ba='Bababala:BAABLgAECn8UAAIBAAYJ2SIXSAAbAgABAAYJ2SIXSAAbAgAAAA==.Ballala:BAAALgAECgYJDQAAAA==.',
Bb='Bballa:BAABLgAECn8UAAICAAYJtB/BHQASAgACAAYJtB/BHQASAgAAAA==.',
Da='Dark:BAAALgAFFAIJAwAAAA==.Davids:BAAALgADCgQJBQAAAA==.',
De='Desperado:BAAALgAFFAEJAQAAAA==.Devilocry:BAACLgAFFH8GAAMDAAMJMAyUFQCUAAADAAIJfAmUFQCUAAAEAAEJmBE1BABZAAAuAAQKfxUAAwMACAmzF5JTAKkBAAMABwm5GZJTAKkBAAQABQlMEywuAFsBAAAA.',
Do='Doubleflick:BAAALgAECgIJAgAAAA==.',
Fo='Foching:BAAALgAECgcJBwAAAA==.',
Hm='Hmw:BAAALgAECgMJBQAAAA==.',
Ki='Kioomi:BAAALgAECgEJAwAAAA==.',
Ku='Kumo:BAAALgAFFAcJBAAAAA==.',
Ma='Macmillan:BAAALgAECgMJBAABLgAECgcJFQAFAFkYAA==.Madelemontea:BAAALgAECgkJCgAAAA==.Maybeam:BAACLgAFFH8FAAIGAAMJZw+YCwD8AAAGAAMJZw+YCwD8AAAuAAQKfxgAAwYABwmpHBEKAE8BAAYABgkpHxEKAE8BAAcAAQkZCvBUADcAAAAA.Maybeams:BAAALgAECgEJAQABLgAFFAMJBQAGAGcPAA==.',
Mi='Mikasaackerm:BAAALgAECgIJAgAAAA==.Missrobin:BAAALgAECgYJCQAAAA==.',
Mo='Moonday:BAABLgAECn8UAAIIAAcJBBxPRQAUAgAIAAcJBBxPRQAUAgAAAA==.',
Mt='Mtt:BAAALgAECgEJAgAAAA==.',
Na='Nature:BAAALgADCgcJCgAAAA==.',
Re='Reginald:BAACLgAFFH8GAAIJAAUJvhpMBQDKAQAJAAUJvhpMBQDKAQAuAAQKfxMAAgkABwnrIHIuAFMCAAkABwnrIHIuAFMCAAAA.',
Se='Sendyouhome:BAAALgAFFAIJBAAAAA==.',
Sh='Shermie:BAAALgADCgEJAQAAAA==.',
['Sè']='Sè:BAAALgAFFAIJBAAAAA==.',
['一只']='一只椛狐狸:BAAALgADCgEJAQAAAA==.',
['一名']='一名女子:BAAALgADCgEJAQAAAA==.',
['专长']='专长诗人:BAABLgAFFH8HAAIKAAQJTRvFCABhAQAKAAQJTRvFCABhAQAAAA==.',
['东京']='东京闹五鼠:BAABLgAFFH8FAAILAAIJ8QuyHgCVAAALAAIJ8QuyHgCVAAAAAA==.',
['东津']='东津湾锅王:BAAALgAECgMJAwAAAA==.',
['丨丨']='丨丨青见:BAABLgAFFH8MAAQMAAQJShmmBwAoAQAMAAQJShmmBwAoAQAFAAIJAAVFIgB/AAANAAIJaAgAAAAAAAAAAA==.',
['丨小']='丨小小筱亭丶:BAAALgAECgIJAgAAAA==.',
['丨迢']='丨迢星丨:BAAALgADCgYJCwAAAA==.',
['丶思']='丶思维窃取丶:BAAALgAECgYJCgAAAA==.',
['丶流']='丶流刃若火丿:BAAALgADCgUJBQAAAA==.',
['丶白']='丶白芷:BAAALgAFFAMJBAAAAA==.',
['乄红']='乄红尘:BAAALgAECgIJAgAAAA==.',
['予君']='予君:BAABLgAFFH8HAAMOAAMJmiGaBQAqAQAOAAMJmiGaBQAqAQAHAAEJVAYLGwBDAAAAAA==.',
['二杠']='二杠五千:BAAALgAECgMJAwAAAA==.',
['云外']='云外镜:BAAALgAECgYJBwAAAA==.',
['以德']='以德报怨:BAAALgAECgIJAgAAAA==.',
['仪玄']='仪玄丶:BAAALgAFFAQJAQAAAA==.',
['任迪']='任迪:BAAALgAECgcJCAAAAA==.',
['何人']='何人不识君:BAAALgAECgcJCAAAAA==.',
['你才']='你才是阿昆达:BAAALgAFFAEJAQAAAA==.',
['你被']='你被牛打过:BAAALgAFFAEJAQAAAA==.',
['佳得']='佳得乐冰柠:BAAALgADCgEJAQAAAA==.佳得乐冰橘:BAAALgAECgMJAwAAAA==.佳得乐冰爽:BAAALgAECgYJBgAAAA==.佳得乐浆果味:BAAALgAECgUJBQAAAA==.',
['佳成']='佳成毛:BAAALgAECgEJAQAAAA==.',
['倒镜']='倒镜里那公路:BAAALgAFFAMJBAAAAA==.',
['全神']='全神出来憩兮:BAAALgADCgEJAQAAAA==.',
['六锅']='六锅韭黄:BAABLgAFFH8HAAIPAAQJDAutCQDqAAAPAAQJDAutCQDqAAAAAA==.',
['冰柠']='冰柠气泡水:BAAALgAECgUJBQAAAA==.',
['凸口']='凸口凸:BAAALgAFFAIJAgAAAA==.',
['刘诗']='刘诗诗:BAAALgAFFAIJAgABLgAFFAUJAQAQAAAAAA==.',
['勤劳']='勤劳的牛:BAAALgAECgYJCgAAAA==.',
['北冥']='北冥先生:BAAALgAECgcJDwAAAA==.',
['北海']='北海道的樱花:BAAALgAFFAEJAQAAAA==.',
['千早']='千早爱音本人:BAAALgAECgYJBgAAAA==.',
['卖萌']='卖萌的傲娇鱼:BAAALgAECgMJAwAAAA==.',
['可爱']='可爱:BAAALgAECgMJAwAAAA==.',
['叱撾']='叱撾屮戢夿:BAAALgAECgkJCQAAAA==.',
['叶瞬']='叶瞬光丶:BAABLgAFFH8FAAIBAAQJGxZvFABRAQABAAQJGxZvFABRAQAAAA==.',
['司马']='司马懿:BAAALgAECgEJAQAAAA==.',
['听风']='听风与我讲你:BAAALgAECgMJAwAAAA==.',
['品品']='品品乳即正义:BAAALgAECgUJCQAAAA==.',
['哎呀']='哎呀你説:BAAALgAECgYJCQAAAA==.',
['嗜鳕']='嗜鳕和尚:BAAALgAECgYJCAAAAA==.',
['嘴强']='嘴强喷斗士:BAAALgAECgYJCQAAAA==.',
['圣骑']='圣骑王者:BAAALgADCgYJBgAAAA==.',
['在原']='在原七海:BAABLgAFFH8KAAIMAAQJfA4tBQAqAQAMAAQJfA4tBQAqAQAAAA==.',
['地铁']='地铁一号:BAAALgAECgYJBgAAAA==.地铁叁号:BAAALgAECgEJAQAAAA==.地铁四号:BAAALgAFFAIJAwAAAA==.地铁肆好:BAAALgAECgUJBQAAAA==.',
['塔式']='塔式:BAAALgAECgMJAwAAAA==.',
['塔拉']='塔拉夏的法理:BAAALgAECgMJAwAAAA==.',
['大凡']='大凡阿牛:BAAALgAECgQJBAAAAA==.',
['太阳']='太阳神妞:BAAALgAECgcJBwAAAA==.',
['奀黑']='奀黑牛:BAAALgAECgYJDwAAAA==.',
['奶孩']='奶孩子的辣妈:BAAALgAECgEJAQAAAA==.',
['好无']='好无奈:BAAALgAECgIJAgAAAA==.',
['威灬']='威灬哥:BAAALgAECgcJAwAAAA==.',
['宣告']='宣告者的神巫:BAACLgAFFH8LAAIGAAQJayO8AwAdAQAGAAQJayO8AwAdAQAuAAQKfxoAAgYACAnXIngIAPwCAAYACAnXIngIAPwCAAAA.',
['小小']='小小龙丶:BAAALgAFFAQJBAAAAA==.',
['小强']='小强同学:BAAALgAECgIJAgAAAA==.',
['小煎']='小煎:BAAALgAECgQJCgAAAA==.',
['小猪']='小猪佩饭:BAAALgAECgEJAQAAAA==.',
['小菊']='小菊:BAAALgAECgUJBwAAAA==.',
['小龙']='小龙娘:BAAALgAECgEJAQABLgAFFAIJAwAQAAAAAA==.',
['岛屿']='岛屿橙与梦:BAAALgAECgUJBQAAAA==.',
['已提']='已提交还不够:BAAALgADCgEJAQAAAA==.',
['巴啦']='巴啦啦小龙人:BAAALgAECgYJCgAAAA==.',
['带翅']='带翅膀的奔驰:BAAALgAECgcJBwAAAA==.',
['幼稚']='幼稚园典狱长:BAABLgAFFH8MAAMRAAYJrx2GAQCWAQARAAQJkxyGAQCWAQAKAAMJkR6BDQApAQAAAA==.',
['很迷']='很迷茫:BAAALgAFFAIJAgAAAA==.',
['忘途']='忘途川:BAAALgAECgUJBQAAAA==.',
['快组']='快组你术爹:BAAALgAECgUJCgAAAA==.',
['性感']='性感的奶龙:BAAALgAECgYJCgAAAA==.',
['我不']='我不入地獄:BAAALgAECgEJAQAAAA==.',
['抽大']='抽大一笔:BAAALgAECgMJAwAAAA==.',
['拿捏']='拿捏圣光吧:BAAALgAECgUJDgABLgAECgYJCgAQAAAAAA==.',
['拿牙']='拿牙当板斧:BAAALgADCgEJAQAAAA==.',
['敢敢']='敢敢丶:BAAALgAECgYJDAAAAA==.',
['斑点']='斑点牛:BAAALgAECgEJAgAAAA==.',
['斯密']='斯密玛赛:BAAALgAFFAMJAwAAAA==.',
['易官']='易官人:BAAALgAECgQJCQAAAA==.',
['昭禾']='昭禾吗:BAAALgADCgEJAQAAAA==.昭禾龙:BAAALgAECgEJAQAAAA==.',
['暧昧']='暧昧:BAAALgAECgUJBQAAAA==.',
['月光']='月光美人:BAAALgAECgYJBgAAAA==.',
['月夜']='月夜下的恶魔:BAAALgAECgMJAwAAAA==.',
['有猹']='有猹偷瓜啦:BAABLgAECn8XAAILAAcJYhJ6bQD6AQALAAcJYhJ6bQD6AQAAAA==.',
['朝廷']='朝廷心腹:BAAALgAECgcJDAAAAA==.',
['朝蕣']='朝蕣:BAAALgAFFAIJBAAAAA==.',
['木三']='木三丶:BAAALgAECgkJEwAAAA==.',
['术十']='术十六郎:BAABLgAFFH8GAAIJAAQJ6RkNEQBaAQAJAAQJ6RkNEQBaAQABLgAFFAYJDwAJALsgAA==.',
['朱鹭']='朱鹭子:BAACLgAFFH8MAAMCAAQJNhMUFQCbAAACAAQJNhMUFQCbAAASAAIJXhZuGQCXAAAuAAQKfxwAAxIACAl0HMEWAIACABIACAl0HMEWAIACAAIABwkbH+8TAHQCAAAA.',
['李思']='李思思:BAAALgADCgcJBwABLgAFFAUJAQAQAAAAAA==.',
['枕星']='枕星河:BAAALgAECgkJBgABLgAFFAUJBQATAIAYAA==.',
['林深']='林深河:BAAALgAECgIJAwAAAA==.',
['枯术']='枯术焚骨:BAAALgADCgUJBgAAAA==.',
['桃乐']='桃乐丝:BAAALgADCgEJAQAAAA==.',
['梦之']='梦之殇神:BAAALgAFFAIJAwAAAA==.',
['欺骗']='欺骗空间:BAAALgAECgEJAQAAAA==.',
['死了']='死了当骑士:BAABLgAECn8XAAIBAAcJxRYjXADeAQABAAcJxRYjXADeAQAAAA==.',
['毛毛']='毛毛球:BAAALgAFFAQJBAABLgAFFAUJKgAHAP8kAA==.',
['永恒']='永恒的笑笑兽:BAAALgAECgUJBQAAAA==.',
['沐雨']='沐雨橙风:BAAALgAECgQJBAAAAA==.',
['法阵']='法阵:BAABLgAFFH8FAAILAAMJpA26LgD8AAALAAMJpA26LgD8AAAAAA==.',
['海水']='海水江崖:BAAALgAECgYJEgAAAA==.',
['海粟']='海粟:BAAALgAFFAIJBAAAAA==.',
['满满']='满满的小法:BAAALgADCgYJAQAAAA==.',
['潴小']='潴小薰:BAAALgAFFAEJAQAAAA==.',
['火焰']='火焰刀:BAAALgAECgUJBQAAAA==.',
['灬爓']='灬爓灬:BAAALgAECgQJAwAAAA==.',
['灵狐']='灵狐灬踏银砂:BAAALgAECgYJBgABLgAFFAYJFgAUAMUZAA==.',
['爱霏']='爱霏霏:BAAALgAECgQJBAAAAA==.',
['牛战']='牛战成王:BAAALgAECgYJDAAAAA==.',
['牵着']='牵着晓猪漫步:BAAALgAECgcJBwAAAA==.',
['玄武']='玄武湖王处:BAAALgAFFAEJAQAAAA==.',
['王冰']='王冰冰:BAAALgAFFAIJAgABLgAFFAUJAQAQAAAAAA==.',
['王帅']='王帅猛:BAAALgAECgMJAwAAAA==.',
['王的']='王的蝙蝠:BAAALgAECgQJBgAAAA==.',
['王者']='王者赞歌:BAAALgAECggJEQAAAA==.',
['班昭']='班昭:BAAALgAECgQJBAAAAA==.',
['琴心']='琴心不染尘:BAAALgAECgUJDwAAAA==.',
['白胖']='白胖子:BAAALgAECgEJAQAAAA==.',
['白芷']='白芷丶:BAABLgAECn8WAAIVAAkJfQxJKADEAQAVAAkJfQxJKADEAQAAAA==.',
['碧绿']='碧绿的池塘:BAAALgADCgEJAQAAAA==.',
['神威']='神威天圣:BAAALgAECgYJCwAAAA==.',
['福瑞']='福瑞小英雄:BAAALgAECgYJBwAAAA==.',
['秋鳴']='秋鳴:BAAALgAECgUJBQAAAA==.',
['窃贼']='窃贼的烟玉:BAAALgAFFAIJAgAAAA==.',
['符丶']='符丶风行烈酒:BAAALgAFFAMJBAAAAA==.',
['等差']='等差数猎:BAAALgAECgQJBAAAAA==.',
['简缇']='简缇娅:BAAALgAECgYJCQAAAA==.',
['粗壮']='粗壮的喵星人:BAAALgAECgEJAwAAAA==.',
['粼风']='粼风:BAAALgAECgQJBAAAAA==.',
['红色']='红色的丝:BAAALgAECgIJAgAAAA==.',
['纷纷']='纷纷情楡:BAABLgAECn8UAAILAAYJFB+mXAAkAgALAAYJFB+mXAAkAgAAAA==.',
['绝不']='绝不过一点:BAAALgAFFAQJBAAAAA==.',
['罒月']='罒月丶丨瞳:BAAALgADCgMJAwAAAA==.',
['罗卡']='罗卡塔利亚:BAAALgADCgcJBwAAAA==.',
['美式']='美式蛇吻:BAAALgAECgcJDQAAAA==.',
['老司']='老司机老王:BAAALgAECgcJBwAAAA==.',
['聖丨']='聖丨血一直下:BAAALgADCgIJAgAAAA==.',
['聪明']='聪明性紊乱:BAAALgAECgcJCAAAAA==.',
['肉丸']='肉丸儿:BAAALgAECgYJBgAAAA==.',
['腤之']='腤之戰殇:BAABLgAECn8gAAITAAgJJBrtIABLAgATAAgJJBrtIABLAgAAAA==.',
['至暗']='至暗之夜:BAAALgADCgcJCAAAAA==.',
['苁今']='苁今以茩:BAAALgAECgUJBgAAAA==.',
['菊花']='菊花有颗痣丶:BAAALgAFFAEJAQAAAA==.',
['落单']='落单被人伦:BAAALgAECgMJBAAAAA==.',
['落尘']='落尘:BAAALgAECgYJDAAAAA==.',
['蓓优']='蓓优妮塔:BAAALgAECgUJBQAAAA==.',
['蕪蓂']='蕪蓂:BAAALgADCgYJBgAAAA==.',
['行道']='行道迟迟:BAAALgAECgEJAQAAAA==.',
['豆花']='豆花烤鱼:BAABLgAECn8YAAITAAkJtgD2kAB6AAATAAkJtgD2kAB6AAAAAA==.',
['赤道']='赤道雨:BAAALgAFFAIJAwAAAA==.',
['轻舞']='轻舞紫霜:BAAALgAFFAEJAQAAAA==.',
['迪丽']='迪丽热粑:BAAALgAECgYJDwAAAA==.',
['追云']='追云影:BAABLgAFFH8PAAIWAAYJuxg9AQA6AgAWAAYJuxg9AQA6AgAAAA==.',
['逆海']='逆海狂龙:BAAALgAFFAMJBAABLgAFFAYJDwAWALsYAA==.',
['邪能']='邪能奥利奥:BAAALgADCgUJBQAAAA==.',
['阿东']='阿东:BAAALgAFFAUJAQAAAA==.',
['阿凡']='阿凡达九号:BAAALgAFFAUJAQAAAA==.阿凡达二号:BAAALgAFFAQJAQAAAA==.阿凡达五号:BAABLgAFFH8IAAILAAYJyhRZGQBlAQALAAYJyhRZGQBlAQAAAA==.阿凡达十号:BAAALgAFFAQJAwAAAA==.阿凡达四号:BAABLgAFFH8HAAILAAQJiRDhGwBcAQALAAQJiRDhGwBcAQAAAA==.',
['阿哩']='阿哩路亚:BAAALgAECgEJAgAAAA==.',
['阿布']='阿布特嘚儿:BAAALgAECgcJBwAAAA==.',
['陀螺']='陀螺精:BAAALgAECgQJBQAAAA==.',
['陟岵']='陟岵陟屺:BAAALgAECgcJDQAAAA==.',
['雪之']='雪之下雪乃:BAAALgAFFAEJAgABLgAFFAUJEwAHAFsTAA==.',
['零冰']='零冰魔妖雪女:BAAALgAECgYJBQAAAA==.',
['霸王']='霸王牛:BAAALgAECgEJAQAAAA==.',
['青灬']='青灬丨鸢:BAAALgAECgYJCQAAAA==.',
['靓仔']='靓仔来不来:BAAALgADCgEJAQAAAA==.',
['風吹']='風吹蛋冷:BAAALgADCgEJAQAAAA==.',
['風至']='風至踏來:BAAALgADCgYJBgAAAA==.',
['风暴']='风暴财团猎手:BAAALgAECgEJAgAAAA==.',
['飞行']='飞行威龙:BAAALgADCgEJAQAAAA==.',
['食道']='食道:BAAALgAECgEJAQAAAA==.',
['骗鬼']='骗鬼子的肉丸:BAAALgAECgEJAQAAAA==.',
['鬼厉']='鬼厉:BAAALgAECgQJBAAAAA==.',
['鲨鱼']='鲨鱼:BAAALgAECgQJBQAAAA==.',
['麻瓜']='麻瓜四季稻:BAAALgAFFAMJAwAAAA==.',
['黄瓜']='黄瓜哥:BAABLgAECn8aAAIXAAgJGBcZAwBZAgAXAAgJGBcZAwBZAgAAAA==.',
['黑色']='黑色的丝:BAAALgAECgIJAgAAAA==.',
['黑鼠']='黑鼠鼠:BAAALgAFFAIJAwAAAA==.',
['默灬']='默灬丨荨:BAAALgADCgEJAQAAAA==.',
['黯夜']='黯夜之舞:BAAALgAECgIJAwAAAA==.',
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
