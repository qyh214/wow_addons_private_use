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

local lookup = {'Priest-Shadow','Druid-Balance','Mage-Frost','Shaman-Elemental','Warrior-Fury','Rogue-Subtlety','Evoker-Preservation','Hunter-Survival','Paladin-Retribution','DemonHunter-Devourer','DemonHunter-Havoc','Druid-Restoration','Warlock-Demonology','Warlock-Affliction','Shaman-Restoration','Warlock-Destruction','Monk-Brewmaster','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Protection','Paladin-Holy','DeathKnight-Blood','DeathKnight-Unholy','Monk-Windwalker','Monk-Mistweaver','Priest-Discipline','Priest-Holy','Evoker-Devastation',}
local provider = {region='CN',realm='达文格尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Av='Avrillavign:BAAALgAFFAEJAQAAAA==.',
Bi='Bigfly:BAAALgADCgcJCwAAAA==.',
Ch='Christie:BAABLgAECn8bAAIBAAcJ4RzkFABGAgABAAcJ4RzkFABGAgABLgAFFAUJDwACAL8VAA==.',
Co='Comeonbaby:BAAALgADCgYJBgAAAA==.',
Fr='Freedoms:BAABLgAFFH8LAAIDAAQJ1SFiAwCdAQADAAQJ1SFiAwCdAQAAAA==.',
Gr='Greennestea:BAAALgADCgEJAQAAAA==.',
Ka='Kari:BAAALgAECgUJBQABLgAFFAMJBwAEACYcAA==.',
La='Labubu:BAACLgAFFH8MAAIFAAUJggWsBwBxAQAFAAUJggWsBwBxAQAuAAQKfykAAgUACQkKGBkVAKQCAAUACQkKGBkVAKQCAAAA.Lapras:BAAALgAECgYJCQAAAA==.',
Lu='Luckydcc:BAAALgAECgQJBgABLgAFFAUJDgAGAAUZAA==.',
Mi='Mingevoe:BAAALgAFFAQJBAAAAA==.Mingevof:BAABLgAFFH8KAAIHAAUJsSRHAgABAgAHAAUJsSRHAgABAgABLgAFFAcJGQAHACUmAA==.Mingevog:BAAALgAFFAMJAgABLgAFFAcJGQAHACUmAA==.',
Pa='Parado:BAAALgAECgcJBwAAAA==.',
Pl='Playerfamclw:BAAALgADCgYJBgAAAA==.',
Ro='Roger:BAAALgAECgQJBAAAAA==.',
Ut='Utherr:BAAALgADCgEJAQABLgAFFAUJDwACAL8VAA==.',
Xi='Xiwana:BAAALgADCgMJBQAAAA==.',
Xl='Xlm:BAACLgAFFH8PAAICAAUJvxUUBQCZAQACAAUJvxUUBQCZAQAuAAQKfyUAAgIABwlSIkEQAJ8CAAIABwlSIkEQAJ8CAAAA.',
['一五']='一五五的人生:BAAALgAECgQJBwAAAA==.',
['一箭']='一箭冲天:BAABLgAFFH8FAAIIAAMJoh+dBACrAAAIAAMJoh+dBACrAAABLgAFFAMJBwAEACYcAA==.',
['三界']='三界仙:BAAALgAFFAQJBAAAAA==.',
['不堪']='不堪一鸡:BAAALgAECgYJBgAAAA==.',
['丨奈']='丨奈德丽丶:BAAALgAECgQJBAAAAA==.',
['丨落']='丨落羽恋尘丨:BAAALgAECgcJDAAAAA==.',
['什么']='什么什么龍囧:BAAALgAECgQJBQAAAA==.',
['你们']='你们都好细呀:BAAALgAFFAIJBAAAAA==.',
['侍琴']='侍琴:BAABLgAECn8ZAAIJAAYJMiD3SgACAgAJAAYJMiD3SgACAgAAAA==.',
['元气']='元气少女李逵:BAAALgADCgMJAwAAAA==.',
['八鳷']='八鳷鵺:BAACLgAFFH8KAAMKAAQJsgbPIADMAAAKAAMJpAbPIADMAAALAAIJ5gP7CgCLAAAuAAQKfyUAAwoABwl4E0JaAJMBAAoABwl4E0JaAJMBAAsABglDCV46ABgBAAAA.',
['冰封']='冰封的大地:BAAALgAECgIJAgAAAA==.',
['冰激']='冰激凌火锅:BAAALgAECgYJDwAAAA==.',
['冲锋']='冲锋的背影:BAAALgAECgYJBgAAAA==.',
['冷夜']='冷夜风:BAAALgAECgUJBgAAAA==.',
['冷静']='冷静的刺豚:BAAALgAECgEJAwAAAA==.',
['凉城']='凉城薄梦:BAAALgAECgIJAwAAAA==.',
['凯尔']='凯尔萨丝:BAAALgAECgUJBQAAAA==.',
['刀哥']='刀哥追忆:BAAALgAECgUJEQAAAA==.',
['制动']='制动你好:BAAALgAECgUJBQAAAA==.制动底板:BAAALgAECgUJBQAAAA==.制动底板冲孔:BAAALgAECgIJAgAAAA==.制动底板切边:BAAALgAECgIJAQAAAA==.制动底板总承:BAAALgAECgMJAwAAAA==.制动底板成形:BAAALgAECgQJBgAAAA==.制动底板翻边:BAAALgAECgQJBwAAAA==.制动汽修店:BAAALgADCgUJAwAAAA==.制动瑧好:BAAALgADCgIJAgAAAA==.',
['勇敢']='勇敢的芯:BAACLgAFFH8IAAICAAQJ8Qu6BAA+AQACAAQJ8Qu6BAA+AQAuAAQKfyIAAwIABwmkHVMWAFwCAAIABwmkHVMWAFwCAAwAAQkHA+PlAB8AAAAA.',
['千幻']='千幻燁舞:BAAALgAECgIJAgAAAA==.',
['午夜']='午夜泣雪:BAAALgAFFAEJAQAAAA==.',
['卡位']='卡位:BAABLgAECn8UAAMNAAYJFhovcQB9AQANAAUJFhovcQB9AQAOAAEJAABJKQBNAAAAAA==.',
['厅局']='厅局级:BAAALgAFFAEJAQAAAA==.',
['原神']='原神启动:BAAALgAECgMJAwAAAA==.',
['吉伊']='吉伊:BAABLgAFFH8FAAIPAAMJrRa+CQDgAAAPAAMJrRa+CQDgAAAAAA==.',
['名字']='名字难得取:BAAALgAECgcJDgAAAA==.',
['咦咦']='咦咦吆吆:BAAALgAECgEJAQAAAA==.',
['咸鱼']='咸鱼轨道炮:BAAALgAFFAUJAQAAAA==.',
['哔哩']='哔哩波波浪:BAAALgAECgcJCAAAAA==.',
['啊菇']='啊菇:BAACLgAFFH8NAAINAAUJExyIBQDGAQANAAUJExyIBQDGAQAuAAQKfxwAAw0ABwkZJMQhAI8CAA0ABwkZJMQhAI8CABAAAQkAAMBgAE0AAAEuAAUUBwkHAA0AOhwA.',
['回天']='回天推拿:BAAALgAECgYJDAAAAA==.',
['圣光']='圣光照耀你妹:BAAALgADCgYJAwAAAA==.',
['塞牙']='塞牙缝:BAABLgAECn8bAAMLAAgJSB1jCQDMAgALAAgJSB1jCQDMAgAKAAUJGg+2jgAEAQAAAA==.',
['墨染']='墨染云烟:BAAALgADCgQJBAAAAA==.',
['夏午']='夏午:BAAALgAECgEJAQAAAA==.',
['夏天']='夏天的西瓜皮:BAAALgAFFAIJAwAAAA==.',
['多财']='多财多亿:BAAALgAFFAEJAQAAAA==.',
['大板']='大板鲫大鲤鱼:BAAALgAECgYJBQAAAA==.',
['天罡']='天罡战歌:BAAALgAFFAEJAQAAAA==.',
['天遣']='天遣者:BAAALgAECggJEAAAAA==.',
['天霆']='天霆号:BAABLgAFFH8NAAIRAAUJkQz5CABFAQARAAUJkQz5CABFAQAAAA==.',
['女王']='女王的骑士:BAAALgAECgYJBgAAAA==.',
['奶你']='奶你妹:BAAALgAECgUJBQAAAA==.',
['如遇']='如遇天堂:BAAALgADCgEJAQAAAA==.',
['妍嘟']='妍嘟嘟:BAAALgAECgEJAQAAAA==.',
['妮可']='妮可火月:BAAALgADCgEJAQAAAA==.',
['孔雀']='孔雀东南飞:BAAALgAECgEJAQAAAA==.',
['宸宝']='宸宝:BAAALgAECgEJAQAAAA==.',
['寒山']='寒山一箭:BAAALgAECgEJAQABLgAECgQJBQASAAAAAA==.',
['寒烟']='寒烟胧月:BAAALgAECgYJCQAAAA==.',
['小姿']='小姿芊:BAAALgAECgUJBQAAAA==.',
['小小']='小小丶骑士:BAAALgADCgUJBQAAAA==.',
['小明']='小明圣疗:BAAALgAECgEJAQAAAA==.',
['小汤']='小汤包:BAAALgAFFAIJAgAAAA==.',
['尐稀']='尐稀有动物尐:BAAALgAECgQJBAAAAA==.尐稀有小跟班:BAAALgAECgYJCgAAAA==.',
['山花']='山花泡泡:BAAALgAECgEJAgAAAA==.山花骑骑:BAAALgADCgEJAgAAAA==.',
['巧儿']='巧儿:BAAALgAECgcJCwAAAA==.',
['巴啦']='巴啦啦小魔仙:BAAALgAECgYJBwAAAA==.',
['布吉']='布吉岛:BAAALgAECgcJBgAAAA==.',
['帅的']='帅的不明显:BAAALgAECgQJDQAAAA==.',
['开心']='开心:BAAALgADCgUJBQAAAA==.',
['恰恰']='恰恰祺:BAAALgAECgQJBAAAAA==.',
['恶魔']='恶魔术快加强:BAAALgAECgIJAQAAAA==.',
['悲伤']='悲伤的香蕉:BAAALgAECgQJBAAAAA==.',
['惊天']='惊天一条蛆:BAAALgAECgEJBAAAAA==.',
['慕容']='慕容月颜:BAAALgAECgEJAQAAAA==.',
['我就']='我就是奶龙:BAAALgAECgYJCQAAAA==.',
['我未']='我未杀伯仁:BAAALgAECgEJAQAAAA==.',
['我辣']='我辣一记:BAABLgAFFH8GAAIPAAMJwh5mDAATAQAPAAMJwh5mDAATAQAAAA==.',
['拳拳']='拳拳:BAACLgAFFH8OAAIGAAUJBRkkAgB2AQAGAAUJBRkkAgB2AQAuAAQKfyEAAgYABwlaGoEbACUCAAYABwlaGoEbACUCAAAA.',
['携子']='携子之手:BAAALgAECgYJBgAAAA==.',
['撒爹']='撒爹的小弟:BAAALgAECgQJBAABLgAFFAQJCgATAEkYAA==.',
['时光']='时光之梦:BAAALgAECgYJBgAAAA==.',
['旺旺']='旺旺小苏:BAAALgAECgMJAwAAAA==.',
['是的']='是的大王:BAAALgAECgYJBgAAAA==.',
['暗黑']='暗黑破坏神:BAAALgADCgIJAgAAAA==.',
['曰後']='曰後再说:BAAALgAECgEJAQAAAA==.',
['月咏']='月咏几斗:BAAALgAECgMJAwAAAA==.',
['月心']='月心:BAAALgAECgIJAgAAAA==.月心颜:BAAALgAECgEJAQAAAA==.',
['柳岩']='柳岩:BAAALgAECgcJCAAAAA==.',
['树先']='树先生:BAAALgAECgEJAQAAAA==.',
['格劳']='格劳克斯:BAAALgAFFAEJAQAAAA==.',
['格尔']='格尔嘉特:BAAALgAECgEJAQAAAA==.',
['桂妮']='桂妮薇娅:BAAALgAECgQJBwAAAA==.',
['梅子']='梅子黃時雨:BAAALgADCgEJAQAAAA==.',
['梦泽']='梦泽:BAAALgAFFAEJAQAAAA==.',
['死了']='死了都是骑士:BAAALgADCgUJBQAAAA==.',
['沈欺']='沈欺霜:BAAALgAECgYJBgAAAA==.',
['沐风']='沐风同雨:BAAALgAECggJCQAAAA==.',
['沧海']='沧海丶怒:BAACLgAFFH8JAAMPAAUJqRIcCQA9AQAPAAUJqRIcCQA9AQAEAAEJ6gGcHwBEAAAuAAQKfyYAAw8ACQknHq4bADsCAA8ABwnJH64bADsCAAQAAgnIBvcjAHAAAAAA.',
['流浪']='流浪之心:BAAALgAECgYJCgAAAA==.',
['混言']='混言术一蚊:BAAALgAECgkJBgAAAA==.',
['清水']='清水末末:BAAALgAECgcJAwAAAA==.',
['清源']='清源妙道真君:BAAALgADCgIJAgAAAA==.',
['火大']='火大:BAAALgADCgEJAgAAAA==.',
['灬妖']='灬妖孽:BAAALgAECgUJBwAAAA==.',
['灬小']='灬小法悠哉灬:BAAALgAECgUJCAAAAA==.',
['灬肉']='灬肉嘟嘟灬:BAAALgAECgEJAQAAAA==.',
['灬龙']='灬龙骑将灬:BAAALgAECgYJBgAAAA==.',
['爵奏']='爵奏:BAAALgAECgEJAQAAAA==.',
['狡猾']='狡猾的栗子:BAACLgAFFH8HAAMNAAQJ2hgoIQD/AAANAAQJUhYoIQD/AAAQAAEJcw9vFQBUAAAuAAQKfyAAAw0ACQlMHlgKAPIBAA0ACQlwHVgKAPIBABAABAnmHKogAE4BAAAA.',
['珊瑚']='珊瑚猎:BAAALgAECgEJAQAAAA==.',
['瓦力']='瓦力旭旭:BAABLgAFFH8HAAITAAQJSBeiCgANAQATAAQJSBeiCgANAQAAAA==.',
['白雪']='白雪公子:BAAALgAECgYJBwAAAA==.',
['真不']='真不会取名:BAAALgAECgEJAQAAAA==.',
['砰砰']='砰砰啪啪:BAACLgAFFH8LAAMTAAUJlxdeEgC5AAAUAAMJnRT1FQDrAAATAAIJkhpeEgC5AAAuAAQKfx8AAxQACAkAHiMYAGkCABQACAkAHiMYAGkCABMAAQliHAG8AEsAAAAA.',
['碎影']='碎影舞月:BAABLgAECn8UAAIMAAcJkBZHMgDhAQAMAAcJkBZHMgDhAQAAAA==.',
['神游']='神游太虚:BAAALgAECgYJDgAAAA==.',
['神话']='神话哥:BAAALgADCgcJDgAAAA==.',
['米奇']='米奇法神:BAAALgAECgUJBQAAAA==.',
['米奈']='米奈希爾:BAABLgAFFH8FAAIJAAMJdiDODwApAQAJAAMJdiDODwApAQAAAA==.',
['糖公']='糖公主:BAAALgAECgYJCwAAAA==.',
['糖糖']='糖糖公主:BAAALgAECgEJAQAAAA==.',
['紫夜']='紫夜冰:BAAALgAECgIJAgAAAA==.紫夜枫:BAAALgAECgQJBAAAAA==.紫夜离:BAAALgAECgYJBwAAAA==.紫夜雪月:BAAALgAECgUJBQAAAA==.',
['线芯']='线芯:BAAALgAFFAEJAQAAAA==.',
['终不']='终不似少年游:BAAALgAECgIJAgAAAA==.',
['维达']='维达尔:BAAALgAECgcJDAAAAA==.',
['网事']='网事如枫:BAAALgAECgcJDwAAAA==.',
['美美']='美美小狐理:BAAALgADCgEJAQAAAA==.',
['老公']='老公:BAAALgAECgYJCgAAAA==.',
['肥雪']='肥雪:BAAALgADCgMJAwAAAA==.',
['胖胖']='胖胖暗影掌控:BAAALgAECgQJBAAAAA==.',
['至尊']='至尊大宗师:BAAALgAECggJEwAAAA==.至尊猪儿虫:BAACLgAFFH8TAAMVAAUJ7CImAQCDAQAVAAQJ7CImAQCDAQAFAAEJAAAJJwA9AAAuAAQKfxoAAhUACAkQIy8EAAcDABUACAkQIy8EAAcDAAAA.',
['至少']='至少一七五:BAABLgAFFH8IAAIJAAQJNAejDwArAQAJAAQJNAejDwArAQAAAA==.',
['艾克']='艾克莉西娅:BAAALgADCgcJBwAAAA==.',
['苍穹']='苍穹二鸦:BAAALgAECgYJDAAAAA==.苍穹夜鸦:BAAALgAECgEJAQAAAA==.',
['英酱']='英酱:BAACLgAFFH8QAAIWAAUJXCEUAgDgAQAWAAUJXCEUAgDgAQAuAAQKfy8AAhYACQm7JEYAAMgDABYACQm7JEYAAMgDAAAA.',
['英雄']='英雄德:BAAALgAECgEJAQAAAA==.',
['荣耀']='荣耀依然黯淡:BAAALgAECgcJEAAAAA==.',
['萌彩']='萌彩游门:BAABLgAECn8iAAIXAAkJpRliCQCIAgAXAAkJpRliCQCIAgAAAA==.',
['萬千']='萬千寵愛:BAAALgAECgQJBQAAAA==.',
['虚空']='虚空乄影:BAAALgADCgIJAgAAAA==.',
['裤裤']='裤裤:BAAALgAECgYJCAAAAA==.',
['襄阳']='襄阳丶彭于晏:BAACLgAFFH8HAAIYAAMJwBaREgD7AAAYAAMJwBaREgD7AAAuAAQKfxUAAhgABwn7G3w8AEUCABgABwn7G3w8AEUCAAAA.',
['要么']='要么你带我飞:BAAALgAECgYJBwAAAA==.',
['谦谦']='谦谦妈妈:BAAALgAECgUJBgAAAA==.',
['躺不']='躺不平卷不赢:BAAALgAECgIJAgAAAA==.',
['这比']='这比魔法好用:BAAALgAECgYJCQAAAA==.',
['迪菲']='迪菲亚顾问:BAAALgAECgQJBgAAAA==.',
['酒舞']='酒舞贰妻:BAAALgAECgQJBwAAAA==.',
['銭丶']='銭丶先生:BAAALgAFFAEJAQAAAA==.',
['钙琪']='钙琪叮丝:BAAALgAECgcJBwAAAA==.',
['铁锤']='铁锤妹妹:BAAALgADCgEJAQAAAA==.',
['长得']='长得乖该我歪:BAAALgADCgMJAwAAAA==.',
['门番']='门番红美铃:BAECLgAFFH8LAAQRAAMJVB4GCAAUAQARAAMJdBsGCAAUAQAZAAIJNSKbCQDPAAAaAAEJLBr5FQBKAAAuAAQKfxQAAxkACAnGFSQbAAQCABkABwlpFCQbAAQCABoABgk8G44gALABAAAA.',
['闪电']='闪电宝法:BAAALgAECgcJAQAAAA==.',
['问题']='问题少女:BAAALgAECgIJAwAAAA==.',
['阿儿']='阿儿萨斯:BAAALgADCgQJBAAAAA==.',
['阿摩']='阿摩罗:BAAALgAECgMJAwAAAA==.',
['阿森']='阿森西奥:BAACLgAFFH8QAAIPAAUJjxPqAwCVAQAPAAUJjxPqAwCVAQAuAAQKfyoAAg8ACQkCFgkWAGUCAA8ACQkCFgkWAGUCAAAA.',
['阿比']='阿比迪斯:BAAALgAECgYJEwAAAA==.',
['阿里']='阿里兰:BAACLgAFFH8NAAMNAAUJFSIrCwCCAQANAAQJnCErCwCCAQAQAAEJgCNPEABlAAAuAAQKfxgAAxAACQn4IOUFAHQCABAABwkPIOUFAHQCAA0ACAk4HbEyAEECAAAA.',
['陌上']='陌上谁家年少:BAABLgAECn8aAAQOAAgJ3BYLDwBAAQAOAAQJERsLDwBAAQAQAAMJlhF4NgDdAAANAAMJLxf8SACGAAAAAA==.',
['院锁']='院锁清秋:BAAALgAECgkJBgAAAA==.',
['随便']='随便捣捣:BAABLgAFFH8KAAITAAQJSRjwAQB3AQATAAQJSRjwAQB3AQAAAA==.随便谈谈:BAABLgAFFH8FAAIVAAIJwwNhCABjAAAVAAIJwwNhCABjAAAAAA==.',
['雨季']='雨季还会来:BAAALgAECgEJAQAAAA==.',
['零柒']='零柒壹玖:BAAALgAECgEJAQAAAA==.',
['雷霆']='雷霆惊梦:BAACLgAFFH8KAAIPAAQJbgiyCwAdAQAPAAQJbgiyCwAdAQAuAAQKfxsAAg8ABwlpEAg9AI0BAA8ABwlpEAg9AI0BAAAA.',
['雾切']='雾切响子:BAAALgAFFAEJAQAAAA==.',
['霜飘']='霜飘飘:BAAALgADCgIJAwAAAA==.',
['露思']='露思:BAAALgAECgUJBgAAAA==.',
['青花']='青花瓷:BAACLgAFFH8QAAIbAAUJhiJ5AgDyAQAbAAUJhiJ5AgDyAQAuAAQKfyYAAxsACAnZHz0FAP4CABsACAnZHz0FAP4CABwAAQkSG3J4AEgAAAAA.',
['飛花']='飛花逐影:BAAALgAECgMJAwAAAA==.',
['饭搭']='饭搭子:BAABLgAECn8gAAIdAAgJxxVGCgA5AgAdAAgJxxVGCgA5AgAAAA==.',
['饺子']='饺子就酒:BAAALgADCgEJAQAAAA==.',
['香辣']='香辣鸭脖:BAAALgAFFAIJAgAAAA==.',
['魔鬼']='魔鬼中的天使:BAAALgAECgEJAQAAAA==.',
['鱼跃']='鱼跃:BAAALgAECgYJBgAAAA==.',
['龙共']='龙共虎应声裂:BAACLgAFFH8HAAIEAAMJJhxWEQDiAAAEAAMJJhxWEQDiAAAuAAQKfxkAAgQABwnjJD4FAOoBAAQABwnjJD4FAOoBAAAA.',
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
