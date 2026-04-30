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

local lookup = {'Druid-Restoration','Druid-Balance','Paladin-Retribution','Warlock-Demonology','Warlock-Destruction','DeathKnight-Unholy','Shaman-Restoration','Hunter-Marksmanship','Unknown-Unknown','DeathKnight-Blood','Paladin-Holy','Priest-Shadow','Mage-Frost','DemonHunter-Devourer','DemonHunter-Havoc','Priest-Discipline','Hunter-BeastMastery','Warrior-Fury','Warrior-Arms','Warrior-Protection','Evoker-Preservation','Monk-Brewmaster',}
local provider = {region='CN',realm='石锤',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Anysaber:BAAALgAECgEJAgAAAA==.',
As='Ash:BAAALgADCgYJBgAAAA==.',
Be='Bethoes:BAACLgAFFH8JAAMBAAQJpxp9CABKAQABAAQJpxp9CABKAQACAAIJoA6oEwCmAAAuAAQKfxUAAwEABwnHHjEqAAkCAAEABgkQITEqAAkCAAIABAmyF4hAAC8BAAAA.',
Bm='Bmozad:BAAALgAFFAEJAgAAAA==.',
Bu='Bullfighter:BAAALgAECgcJDAAAAA==.',
Cc='Ccstella:BAAALgAECgEJAQAAAA==.',
Di='Diegodie:BAAALgAECgIJAwAAAA==.',
Et='Etch:BAAALgAECgYJDQAAAA==.',
Go='Goodbro:BAAALgAECgQJBAAAAA==.',
Ha='Handsomeman:BAAALgADCgYJBgAAAA==.',
He='Hellride:BAAALgAFFAIJAgAAAA==.',
Ku='Kukumaloos:BAAALgAFFAEJAQAAAA==.',
Ly='Lyaphets:BAAALgAECgEJAQAAAA==.',
Me='Me:BAAALgADCgIJAgAAAA==.Merling:BAAALgADCgMJAwAAAA==.Merlinith:BAAALgAECgYJCwAAAA==.',
Mi='Mirinda:BAAALgAECgEJAQAAAA==.',
Nu='Nutriexpress:BAAALgADCgEJAgAAAA==.',
Pl='Playeriltxvc:BAAALgAFFAEJAQAAAA==.',
Qf='Qfgql:BAAALgAECgEJAQAAAA==.',
Qi='Qi:BAAALgAECgUJBwAAAA==.',
Se='Seoyoon:BAAALgAECgcJDwAAAA==.',
Sh='Shinynt:BAAALgAFFAEJAQAAAA==.',
Sn='Snakeyuki:BAACLgAFFH8MAAIDAAQJSCHhAgB4AQADAAQJSCHhAgB4AQAuAAQKfxkAAgMACAl+IeASAPwCAAMACAl+IeASAPwCAAAA.',
Ts='Tshalulia:BAAALgAECgcJBwAAAA==.',
Va='Vasily:BAAALgAFFAEJAgAAAA==.',
Xi='Xidian:BAAALgAECgYJCQAAAA==.',
['一行']='一行:BAACLgAFFH8FAAIDAAIJ3wqTJwCaAAADAAIJ3wqTJwCaAAAuAAQKfxcAAgMACAkrHkodALsCAAMACAkrHkodALsCAAAA.',
['一霸']='一霸霸一:BAAALgAECgEJAQAAAA==.',
['七鱼']='七鱼:BAAALgAECgYJBgAAAA==.',
['上汽']='上汽大众:BAABLgAECn8ZAAMEAAcJix8+LgBUAgAEAAcJix8+LgBUAgAFAAEJAABVbgA4AAAAAA==.',
['不善']='不善言辞:BAAALgAECgQJBAAAAA==.',
['不萌']='不萌不要钱:BAAALgAECgMJAwAAAA==.',
['不要']='不要停下来啊:BAAALgAECgEJAQAAAA==.',
['专业']='专业圣光打码:BAAALgAFFAIJAwAAAA==.',
['丨戊']='丨戊丨玖丨:BAAALgADCgUJBQAAAA==.',
['丶小']='丶小萌:BAAALgAECgQJCAAAAA==.',
['丶月']='丶月咏丶:BAAALgAECgUJBgAAAA==.',
['丶黑']='丶黑夜:BAAALgADCgEJAQAAAA==.',
['丷梦']='丷梦醒时见你:BAAALgAFFAQJBAAAAA==.',
['乂义']='乂义乂乂义乂:BAAALgAECgUJBgAAAA==.',
['乌瑞']='乌瑞恩之风:BAAALgAECgYJBgAAAA==.',
['乌瑟']='乌瑟尔:BAAALgAFFAEJAQAAAA==.',
['乌龟']='乌龟快跑:BAAALgAECgEJAQAAAA==.',
['乐百']='乐百弑:BAAALgAECgYJBgAAAA==.',
['以此']='以此证明:BAAALgAECgYJBgAAAA==.',
['以武']='以武犯禁:BAAALgAECgcJAQAAAA==.',
['以洞']='以洞滋精:BAAALgAECgQJBwAAAA==.',
['低调']='低调嘴严:BAABLgAFFH8FAAIGAAUJSiQ6AwDTAQAGAAUJSiQ6AwDTAQAAAA==.',
['余生']='余生与你:BAAALgAECgEJAQAAAA==.',
['佛系']='佛系中年大叔:BAAALgAECgEJAgAAAA==.',
['你们']='你们别跑了:BAAALgADCgMJAwAAAA==.',
['傻妞']='傻妞丶:BAAALgAECgEJAQAAAA==.',
['六月']='六月烈焰:BAAALgAECgEJAQAAAA==.',
['切茜']='切茜娅之手:BAAALgAECgkJBwAAAA==.切茜娅之祈:BAAALgAECgkJDAABLgAFFAYJCgAHAHYKAA==.',
['别骂']='别骂我小白:BAAALgADCgIJAgAAAA==.',
['剑心']='剑心通明:BAABLgAFFH8FAAIGAAUJSRP9BQCkAQAGAAUJSRP9BQCkAQABLgAFFAYJBQAGAEokAA==.',
['剑破']='剑破虚空:BAAALgAFFAQJAQABLgAFFAYJBQAGAEokAA==.',
['劲爆']='劲爆鸡米花:BAAALgAECgcJBgAAAA==.',
['北风']='北风知舞:BAAALgADCgEJAgAAAA==.',
['千寻']='千寻:BAAALgAECgEJAQAAAA==.',
['半条']='半条咸鱼丶:BAAALgAECgkJEAAAAA==.',
['卡卡']='卡卡龙:BAAALgAECgYJBgAAAA==.',
['卿雅']='卿雅辛:BAAALgADCgYJBgAAAA==.',
['原味']='原味阿瓜:BAAALgAECgYJBgAAAA==.',
['双椒']='双椒牛腩:BAAALgADCgEJAQAAAA==.',
['叶红']='叶红魚:BAAALgAECgEJAQAAAA==.',
['吖灬']='吖灬頭:BAAALgAECgYJBgAAAA==.',
['君不']='君不弃:BAAALgADCgEJAQAAAA==.',
['君君']='君君:BAAALgAECgEJAgAAAA==.',
['哈基']='哈基牧:BAAALgAECgYJBwAAAA==.',
['哔哩']='哔哩哔哔:BAAALgAFFAIJAgAAAA==.',
['哥本']='哥本哈根拳师:BAAALgAECgYJEgAAAA==.哥本哈根拳狮:BAAALgADCgMJAwAAAA==.',
['唯灬']='唯灬她命:BAABLgAFFH8FAAIIAAMJJR0kEgAXAQAIAAMJJR0kEgAXAQAAAA==.',
['喵小']='喵小猎:BAAALgAECgEJAQAAAA==.',
['嗜血']='嗜血的叛逆:BAAALgAECgkJAQAAAA==.',
['嗯造']='嗯造大米饭:BAAALgAECgYJDgAAAA==.',
['嘻哈']='嘻哈小桃:BAAALgAFFAEJAQABLgAFFAIJBAAJAAAAAA==.嘻哈小梨:BAAALgAECgIJAgABLgAFFAIJBAAJAAAAAA==.',
['圣光']='圣光灬之名:BAAALgAECgYJBgAAAA==.圣光照饭盆:BAAALgAECgMJBAAAAA==.圣光的风采:BAAALgAECgIJAgAAAA==.',
['地沟']='地沟油:BAAALgADCgYJBgAAAA==.',
['地法']='地法:BAAALgADCgIJAgAAAA==.',
['地瓜']='地瓜也有爱:BAAALgAECgYJCwAAAA==.',
['堕落']='堕落瓦里安:BAAALgAECgQJAQAAAA==.',
['壁虎']='壁虎漫步:BAAALgAECgcJDwAAAA==.',
['壹箭']='壹箭灬风情:BAAALgAECgYJCwAAAA==.',
['夜喵']='夜喵喵:BAABLgAECn8YAAIKAAcJjQS5KgDoAAAKAAcJjQS5KgDoAAAAAA==.',
['大佛']='大佛:BAAALgAECgIJAgAAAA==.',
['大员']='大员外:BAAALgAECgEJAQAAAA==.',
['大葱']='大葱:BAAALgAECgEJAQAAAA==.',
['天涯']='天涯灬若熙:BAAALgAECgQJBAAAAA==.',
['天蠍']='天蠍座:BAAALgAECgQJBAAAAA==.',
['头硬']='头硬吃人丶丶:BAAALgAECgcJBwAAAA==.',
['奇佐']='奇佐:BAABLgAECn8ZAAMLAAcJgB32GABLAgALAAcJgB32GABLAgADAAQJFBO7wgACAQAAAA==.',
['套盾']='套盾大天使:BAAALgAECgUJBQAAAA==.',
['奶大']='奶大力出奇迹:BAAALgADCgcJDAABLgAFFAEJAQAJAAAAAA==.',
['奶绿']='奶绿:BAAALgADCgUJBwAAAA==.',
['委屈']='委屈的吃手手:BAAALgAECgEJAQAAAA==.',
['孤岛']='孤岛的鲸:BAAALgADCgUJCAAAAA==.',
['宇智']='宇智波牧:BAABLgAECn8ZAAIMAAcJFiJuDAC8AgAMAAcJFiJuDAC8AgAAAA==.',
['安度']='安度因乌瑞恩:BAAALgAECgYJBgAAAA==.',
['將丶']='將丶:BAABLgAECn8UAAIDAAgJ/RlTMwBVAgADAAgJ/RlTMwBVAgAAAA==.',
['小丶']='小丶粉:BAAALgAECgEJAgAAAA==.',
['小啄']='小啄木鸟:BAAALgAECgYJBgABLgAFFAQJBAAJAAAAAA==.',
['小天']='小天才滑喜:BAAALgAECgIJAgABLgAECgQJBAAJAAAAAA==.',
['小妹']='小妹回来吧:BAAALgADCgUJBQAAAA==.',
['小火']='小火烈鸟:BAAALgAECgYJBgAAAA==.',
['小猫']='小猫猫丶:BAAALgAECgYJCQAAAA==.',
['小矮']='小矮:BAAALgAECgUJBQAAAA==.',
['小艾']='小艾同学:BAAALgAECgIJAgAAAA==.',
['小苍']='小苍兰花:BAAALgAFFAMJBAAAAA==.',
['小蕊']='小蕊:BAAALgADCgcJBwAAAA==.',
['小锤']='小锤捶你胸口:BAAALgAECgQJBwABLgAFFAEJAQAJAAAAAA==.',
['小雪']='小雪团雀:BAAALgAFFAQJBAAAAA==.',
['尤瑟']='尤瑟夫卡:BAABLgAECn8UAAMFAAcJ0RZ1IgBDAQAFAAUJpBJ1IgBDAQAEAAUJbBkBjQA/AQAAAA==.',
['就是']='就是辣么帅:BAACLgAFFH8GAAIHAAMJzxpKFQCvAAAHAAMJzxpKFQCvAAAuAAQKfx4AAgcABwntI44LAMYCAAcABwntI44LAMYCAAAA.',
['尹瑟']='尹瑟拉灬腥夜:BAAALgAECgEJAQAAAA==.',
['巫狸']='巫狸狸:BAAALgAECgIJAgAAAA==.',
['巴黎']='巴黎世家:BAAALgAECgQJBgAAAA==.',
['布德']='布德奇冥:BAAALgAECgEJAQAAAA==.',
['帅逼']='帅逼:BAABLgAECn8VAAIGAAkJAxkzHQDQAgAGAAkJAxkzHQDQAgAAAA==.',
['弓兵']='弓兵:BAAALgAECgEJAgAAAA==.',
['张诺']='张诺妍:BAAALgAECgYJBgAAAA==.',
['彦祖']='彦祖玩龙喷:BAABLgAFFH8IAAIGAAMJARWiKgDwAAAGAAMJARWiKgDwAAAAAA==.',
['徘徊']='徘徊在星空:BAAALgAECgYJDgAAAA==.',
['德玛']='德玛熙亞:BAAALgADCgYJBgAAAA==.',
['德苓']='德苓:BAAALgAFFAIJAgAAAA==.',
['德菱']='德菱:BAAALgAECgcJDwAAAA==.',
['德鲁']='德鲁伊德天下:BAAALgAECgUJBQAAAA==.',
['心语']='心语芯愿:BAABLgAECn8ZAAINAAcJyBIdigC+AQANAAcJyBIdigC+AQAAAA==.',
['忘夜']='忘夜的星星:BAAALgAECgEJAQAAAA==.',
['念念']='念念很拉风:BAAALgAECgEJAQAAAA==.',
['恶灵']='恶灵骑士:BAAALgAECgYJBgAAAA==.',
['恶魔']='恶魔:BAAALgAECgIJAgAAAA==.',
['情受']='情受丶:BAAALgAECgYJCwAAAA==.',
['战天']='战天使阿丽塔:BAAALgAECgYJCQAAAA==.',
['折戟']='折戟宸歃:BAAALgAFFAIJAwAAAA==.折戟釒:BAAALgAECgMJAwAAAA==.',
['挽晚']='挽晚:BAAALgADCgMJAwAAAA==.',
['摸鸡']='摸鸡校尉:BAAALgAFFAUJAQAAAA==.',
['新月']='新月千夜:BAAALgAECgYJCQAAAA==.',
['无双']='无双神将潘凤:BAAALgAECgMJAwAAAA==.',
['旧书']='旧书:BAABLgAECn8WAAMCAAYJUR4xIQDzAQACAAYJUR4xIQDzAQABAAMJcBokgwDSAAAAAA==.',
['旺仔']='旺仔牛逼糖:BAAALgAECgEJAgAAAA==.',
['星空']='星空夜殇:BAAALgAECgkJBwAAAA==.',
['是真']='是真滴虚:BAAALgAFFAQJBAAAAA==.',
['晚安']='晚安灬哒哒:BAABLgAFFH8LAAIBAAQJfQ8aCwAsAQABAAQJfQ8aCwAsAQAAAA==.',
['暮色']='暮色小同学:BAAALgAECgEJAQAAAA==.',
['有德']='有德沒德:BAAALgAECgMJBAAAAA==.',
['木须']='木须肉饭:BAAALgAECgMJAwAAAA==.',
['未竟']='未竟:BAABLgAECn8XAAILAAcJTRkFIgAOAgALAAcJTRkFIgAOAgAAAA==.',
['末丶']='末丶洛:BAABLgAECn8WAAIDAAkJWSA6DAAsAwADAAkJWSA6DAAsAwABLgAFFAUJDgADAE4mAA==.',
['术师']='术师好混:BAAALgAECgUJBQAAAA==.',
['条纹']='条纹甜西瓜:BAAALgAECgcJCwAAAA==.',
['格兰']='格兰:BAAALgAECgEJAgAAAA==.',
['桜丷']='桜丷珞:BAAALgAECgkJCQAAAA==.',
['桜洛']='桜洛:BAAALgAFFAMJBAAAAA==.',
['梦中']='梦中谦:BAAALgAECgMJAwAAAA==.',
['棒呆']='棒呆的一棵松:BAAALgAECgYJCAAAAA==.',
['楚菲']='楚菲雨:BAACLgAFFH8OAAINAAUJSBfuDABQAQANAAUJSBfuDABQAQAuAAQKfxgAAg0ACAnpHY80AKECAA0ACAnpHY80AKECAAAA.',
['橡皮']='橡皮糖:BAAALgADCgUJBQAAAA==.',
['檬是']='檬是柠檬的檬:BAAALgAFFAEJAQAAAA==.',
['欢乐']='欢乐雷爆:BAAALgAECgEJAQAAAA==.',
['比克']='比克提尼:BAACLgAFFH8PAAIOAAUJViWDAQC4AQAOAAUJViWDAQC4AQAuAAQKfxYAAw4ACAmQJD4LACgDAA4ACAmQJD4LACgDAA8AAQm5IKRnAEUAAAAA.',
['毛概']='毛概要学好:BAABLgAECn8YAAIGAAcJyhCTeQCRAQAGAAcJyhCTeQCRAQAAAA==.',
['毛毛']='毛毛球:BAABLgAFFH8JAAIQAAUJjx9sAgD1AQAQAAUJjx9sAgD1AQABLgAFFAUJKgAQAP8kAA==.',
['氵寿']='氵寿司氵:BAAALgAECgYJDgAAAA==.',
['氵聋']='氵聋:BAAALgAECgYJBgAAAA==.',
['氵色']='氵色颜氵:BAAALgAECgQJAQAAAA==.',
['汉尼']='汉尼拔新月:BAAALgAECgYJCQAAAA==.',
['江南']='江南花满楼:BAAALgAECgUJCgAAAA==.',
['沐叁']='沐叁槍:BAABLgAFFH8HAAIRAAQJpw2QBQBKAQARAAQJpw2QBQBKAQAAAA==.',
['沐阳']='沐阳:BAAALgAECgMJAwAAAA==.',
['沸腾']='沸腾的咖啡:BAAALgAECgEJAQAAAA==.',
['流火']='流火灬拾壹:BAAALgAECgEJAgAAAA==.',
['流里']='流里流气:BAAALgAECgIJBAAAAA==.',
['浅巷']='浅巷墨离:BAAALgAECgUJCQAAAA==.',
['浅殇']='浅殇搁笑:BAAALgAFFAEJAgAAAA==.',
['涂山']='涂山弘弘:BAAALgADCgQJBAAAAA==.',
['深蓝']='深蓝之域:BAAALgAECgEJAQAAAA==.',
['混沌']='混沌岁月:BAAALgAFFAEJAQAAAA==.',
['清月']='清月無夢:BAAALgAECgEJAQAAAA==.',
['温良']='温良:BAAALgAECgEJAQAAAA==.',
['满心']='满心荒凉:BAAALgAECgYJBgAAAA==.',
['灬春']='灬春初灬:BAAALgAECgYJEQAAAA==.',
['灭龙']='灭龙骑士:BAAALgAECgYJCgAAAA==.',
['炮灰']='炮灰向前沖:BAAALgAECgEJAgAAAA==.',
['热吻']='热吻幻魔:BAAALgAFFAIJAwAAAA==.',
['熊威']='熊威浩荡:BAAALgAECgQJBwAAAA==.',
['爱吃']='爱吃小布丁:BAAALgAECgcJBwAAAA==.',
['特盖']='特盖懒人:BAAALgAECgMJAwAAAA==.',
['犇犇']='犇犇丶犇:BAAALgAECgIJAgAAAA==.',
['狸花']='狸花猫七七:BAAALgADCgYJBgAAAA==.',
['猫小']='猫小夜:BAAALgAECgEJAQAAAA==.',
['猫爪']='猫爪下的雨:BAAALgADCgUJBQAAAA==.',
['玄英']='玄英其凛:BAAALgAFFAIJBAAAAA==.',
['球星']='球星:BAAALgAECgQJBAAAAA==.',
['瓦里']='瓦里安烏瑞恩:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂的羊肉串:BAAALgAECgYJCAAAAA==.',
['看我']='看我电不电你:BAAALgADCgcJDAAAAA==.',
['硬汉']='硬汉玛格:BAAALgAECgUJBQAAAA==.',
['硬要']='硬要玩恶魔:BAAALgAECgUJBQAAAA==.',
['神封']='神封:BAAALgAECgYJCwAAAA==.',
['秦霄']='秦霄斬:BAAALgAECgYJBgAAAA==.',
['空中']='空中的梦想家:BAAALgAECgYJEAAAAA==.',
['簡單']='簡單隨意:BAAALgAECgIJAgAAAA==.',
['米拉']='米拉杰:BAACLgAFFH8GAAIEAAIJSR0jKwDEAAAEAAIJSR0jKwDEAAAuAAQKfxkAAgQABwm4H6IiAIsCAAQABwm4H6IiAIsCAAAA.',
['纯情']='纯情的小火球:BAAALgAECgYJBgAAAA==.',
['绯血']='绯血玉沙:BAABLgAFFH8GAAIQAAIJ4g+9EwCXAAAQAAIJ4g+9EwCXAAAAAA==.',
['缝氏']='缝氏之术:BAAALgAECgEJAQAAAA==.缝氏之猎:BAAALgAECgcJDAAAAA==.',
['羅布']='羅布大师:BAAALgADCgUJBQAAAA==.羅布小猎:BAAALgAECgIJAgAAAA==.',
['老兵']='老兵克林很溜:BAAALgAECgUJBwAAAA==.',
['老蔡']='老蔡一碟:BAAALgAFFAQJBAAAAA==.',
['肉丸']='肉丸子滚滚肉:BAAALgAECgYJCgAAAA==.',
['肚腩']='肚腩超人:BAABLgAECn8cAAMSAAgJZRcUHQBlAgASAAgJZRcUHQBlAgATAAQJIRGUIQDgAAAAAA==.',
['胡子']='胡子像大树:BAAALgAECgMJAwAAAA==.',
['胧夜']='胧夜:BAAALgADCgYJBgABLgAECgcJGAAKAI0EAA==.',
['舆世']='舆世界为敌:BAAALgAECgQJAgAAAA==.',
['艺术']='艺术与黄色:BAABLgAECn8dAAMSAAcJKiBrFgCZAgASAAcJKiBrFgCZAgAUAAEJVRj2QgBDAAAAAA==.',
['花凌']='花凌若别离:BAAALgAECgEJAQAAAA==.',
['若熙']='若熙灬若熙:BAAALgAECgQJBwAAAA==.',
['莫小']='莫小德:BAAALgAECgEJAQAAAA==.',
['落霜']='落霜:BAAALgAFFAIJAgABLgAFFAIJAgAJAAAAAA==.',
['葛胖']='葛胖胖丶:BAAALgAECgEJAQAAAA==.',
['蒙牛']='蒙牛丹丶暗刃:BAAALgAECgEJAgAAAA==.',
['蓝灵']='蓝灵落:BAAALgAECgEJAgAAAA==.',
['蜡笔']='蜡笔猪小呆:BAAALgAECgcJCAABLgAFFAUJAQAJAAAAAA==.',
['见死']='见死不救啊:BAACLgAFFH8HAAIVAAMJ7xpYDQAJAQAVAAMJ7xpYDQAJAQAuAAQKfx0AAhUACQldHWMCABgCABUACQldHWMCABgCAAAA.',
['訫鐩']='訫鐩楓影:BAAALgAECgMJBAAAAA==.',
['贰拾']='贰拾捌畵笙:BAAALgAECgYJBgAAAA==.',
['贰零']='贰零零:BAAALgAECgYJCQAAAA==.',
['踏岚']='踏岚风:BAAALgAECgQJBgAAAA==.',
['蹦跶']='蹦跶的头盔:BAAALgAECgEJAQAAAA==.',
['身体']='身体被掏空:BAAALgADCgUJBQAAAA==.',
['辉煌']='辉煌之和:BAAALgAECgIJAgAAAA==.',
['这怎']='这怎么行:BAAALgAECgQJBgAAAA==.',
['迪巴']='迪巴拉:BAAALgADCgMJAwAAAA==.',
['逆戰']='逆戰灬兲漄:BAAALgAECgYJCgAAAA==.',
['道法']='道法灬自然:BAAALgAECgQJBAAAAA==.',
['销魂']='销魂喵:BAAALgADCgIJAgAAAA==.',
['闪光']='闪光的夜囡囡:BAAALgAECgYJBgAAAA==.',
['阿幾']='阿幾米奇:BAAALgAECgIJAgAAAA==.',
['阿龙']='阿龙:BAAALgADCgYJBgAAAA==.',
['风精']='风精之羽:BAAALgAECgYJCAAAAA==.风精恶魔:BAAALgADCgYJBgAAAA==.',
['香香']='香香丶狐宝宝:BAAALgAECgQJBAAAAA==.',
['鸠十']='鸠十三:BAAALgAECgIJAwAAAA==.鸠十五:BAAALgAECgEJAgAAAA==.',
['鸳鸳']='鸳鸳相抱:BAABLgAECn8ZAAIWAAcJ2Q0BOgBhAQAWAAcJ2Q0BOgBhAQAAAA==.',
['麻辣']='麻辣鸡:BAAALgADCgEJAQAAAA==.',
['黄色']='黄色与艺术:BAAALgAECgEJAQAAAA==.',
['龙彩']='龙彩凤:BAAALgAECgEJAQAAAA==.',
['龙痕']='龙痕星尘:BAAALgAECgEJAQAAAA==.龙痕星辰:BAAALgAECgIJAwAAAA==.',
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
