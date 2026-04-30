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

local lookup = {'Hunter-Marksmanship','DemonHunter-Devourer','Hunter-BeastMastery','Paladin-Retribution','Paladin-Protection','DeathKnight-Unholy','Druid-Restoration','Druid-Balance','Unknown-Unknown','Rogue-Subtlety','Warrior-Protection','Mage-Frost','Warlock-Demonology','Priest-Holy','Warlock-Destruction','Hunter-Survival','Warlock-Affliction','DemonHunter-Havoc','Shaman-Elemental',}
local provider = {region='CN',realm='远古海滩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aijj:BAAALgADCgMJAwAAAA==.',
Ba='Barbilo:BAAALgAECgYJDgAAAA==.',
Be='Benjor:BAAALgAECgUJBwAAAA==.Benta:BAAALgADCgQJBAAAAA==.',
De='Deidi:BAAALgAECgYJCAAAAA==.',
Di='Divano:BAAALgADCgEJAQAAAA==.',
Em='Emechris:BAAALgAECgYJEgAAAA==.',
Ev='Evar:BAAALgAECgQJBAAAAA==.',
Ex='Exsaber:BAAALgAECgMJBgAAAA==.',
Fl='Flyangle:BAABLgAFFH8IAAIBAAQJryNhCACUAQABAAQJryNhCACUAQAAAA==.',
Gu='Gulldan:BAAALgAECgMJBAAAAA==.',
Ha='Hamtrio:BAAALgAECgYJBgAAAA==.',
Ke='Kelaker:BAAALgAECgYJDAAAAA==.Kewei:BAAALgAECgEJAQAAAA==.',
Ki='Kiwi:BAAALgAECgkJCQAAAA==.',
La='Lastac:BAAALgAECgYJBgAAAA==.',
Li='Liliith:BAAALgAFFAEJAgAAAA==.',
Lr='Lrechris:BAAALgAECgUJBQAAAA==.',
Ma='Mami:BAAALgAECgIJAwAAAA==.Marling:BAAALgADCgEJAQAAAA==.',
Mi='Miraitowa:BAAALgAECgYJBwAAAA==.',
Na='Nani:BAABLgAECn8pAAICAAgJXxvzBQBEAgACAAgJXxvzBQBEAgAAAA==.',
Pl='Playerqajfso:BAAALgADCgYJBgAAAA==.',
Po='Polarismoon:BAAALgADCgUJBQAAAA==.',
Pr='Promiselol:BAAALgAECgYJDgAAAA==.',
Ps='Psalm:BAAALgADCgEJAQAAAA==.',
So='Solomon:BAAALgAECgMJAwAAAA==.',
Th='Thea:BAAALgAECgQJBgAAAA==.',
Tk='Tkatt:BAAALgAECgQJBAAAAA==.',
Uo='Uoer:BAAALgAECgQJBgAAAA==.',
Ve='Vesemir:BAAALgAECgYJBwAAAA==.',
Wi='Wishtoday:BAAALgADCgYJBgAAAA==.',
Ws='Wsechris:BAAALgAECgYJBwAAAA==.',
['一一']='一一:BAAALgADCgYJBgAAAA==.',
['一份']='一份麻辣烫灬:BAAALgAECgcJBwAAAA==.',
['一叶']='一叶不知秋丶:BAAALgAECgYJBgAAAA==.',
['上原']='上原瑞穗:BAAALgAECgIJAwAAAA==.',
['不吃']='不吃香菜:BAAALgAECgQJBAAAAA==.',
['专属']='专属伱丨小雄:BAAALgAFFAIJAgAAAA==.',
['丨大']='丨大聪明丨:BAAALgAECgkJCwAAAA==.',
['丨奶']='丨奶油丨:BAAALgAECgEJAQAAAA==.',
['丨康']='丨康康丨:BAAALgAECgcJCwAAAA==.',
['丫头']='丫头小菇凉:BAAALgAECgEJAQAAAA==.',
['中野']='中野二乃:BAACLgAFFH8IAAMBAAQJgxnEFQDtAAABAAMJNBbEFQDtAAADAAEJciM8HQBsAAAuAAQKfyUAAgEACQnFHDEJAAwDAAEACQnFHDEJAAwDAAAA.',
['丶火']='丶火火:BAABLgAFFH8FAAMEAAQJ6gMmEgAUAQAEAAQJ8AImEgAUAQAFAAEJ+QUJCQArAAAAAA==.丶火火德:BAAALgADCgMJAwAAAA==.',
['久久']='久久知:BAAALgAECgYJBwAAAA==.',
['乱噬']='乱噬戦魂:BAAALgADCgcJBwAAAA==.',
['云治']='云治的分身:BAAALgAECgcJBgAAAA==.',
['今晚']='今晚我来掂锅:BAAALgAECgcJDAAAAA==.今晚打老虎吗:BAABLgAFFH8IAAIGAAIJtB+lGQDCAAAGAAIJtB+lGQDCAAAAAA==.',
['伍克']='伍克拉:BAAALgAECggJCAAAAA==.',
['伤心']='伤心鱼罐头:BAAALgAECgUJCAAAAA==.',
['体温']='体温叁拾八:BAAALgAECgMJBAAAAA==.',
['你喝']='你喝酒吗:BAAALgAECgEJAgAAAA==.',
['你被']='你被牛打过:BAAALgAFFAQJBAAAAA==.',
['修罗']='修罗神:BAAALgAECgEJAQAAAA==.',
['元素']='元素听我号令:BAAALgAECgEJAQAAAA==.',
['写你']='写你衣不染尘:BAAALgAECgQJBAAAAA==.',
['军德']='军德:BAABLgAFFH8LAAIHAAUJPxkTBgB3AQAHAAUJPxkTBgB3AQAAAA==.',
['冬雪']='冬雪落浅浅:BAAALgAFFAEJAgAAAA==.',
['冰殇']='冰殇丨大伯:BAAALgAECgYJBgAAAA==.',
['冰翼']='冰翼炫鬻:BAABLgAFFH8FAAIIAAUJ9xAhBQCYAQAIAAUJ9xAhBQCYAQAAAA==.',
['前面']='前面有狼啊:BAAALgADCgEJAQAAAA==.',
['加肉']='加肉煎饼丶:BAAALgAFFAEJAQAAAA==.',
['加肥']='加肥之怒:BAAALgADCgcJBwAAAA==.加肥之熵:BAAALgADCgUJBgAAAA==.',
['劣跌']='劣跌:BAAALgAECgYJBgABLgAFFAIJAgAJAAAAAA==.',
['卓里']='卓里奇的数分:BAAALgAECgUJCAAAAA==.',
['卖萌']='卖萌的小骑士:BAAALgAECgYJBgABLgAFFAYJEwAEAMggAA==.',
['叁克']='叁克拉:BAAALgAECgIJAQAAAA==.',
['古娜']='古娜拉黑暗神:BAAALgAECgQJBwAAAA==.',
['可乐']='可乐好运:BAABLgAFFH8GAAIGAAMJyBhOIAChAAAGAAMJyBhOIAChAAAAAA==.',
['叶叶']='叶叶:BAAALgAECgMJAwAAAA==.',
['叶心']='叶心安前女友:BAAALgAECgUJBwAAAA==.叶心安的右手:BAAALgADCgYJBgAAAA==.叶心安的妹妹:BAAALgAECgQJBAAAAA==.',
['咕噜']='咕噜宝宝:BAAALgADCgUJBQAAAA==.',
['啥都']='啥都切:BAAALgAECgEJAQAAAA==.',
['四影']='四影:BAAALgAECgIJAgAAAA==.',
['因为']='因为我是德:BAAALgAECgQJBAAAAA==.',
['因吹']='因吹斯汀:BAAALgAECgYJCQAAAA==.',
['团团']='团团:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光丨:BAAALgADCgMJAwAAAA==.',
['墨丶']='墨丶魂:BAAALgADCgUJBQAAAA==.',
['墨魂']='墨魂灬:BAAALgAECgYJEQAAAA==.',
['壹克']='壹克拉:BAAALgAECgkJDAAAAA==.',
['夜幕']='夜幕寒影:BAABLgAECn8eAAIKAAgJvx/NDwCpAgAKAAgJvx/NDwCpAgAAAA==.',
['夜魅']='夜魅影:BAAALgAECgcJEQAAAA==.',
['大夫']='大夫不用睡觉:BAAALgADCgIJAgAAAA==.',
['大斩']='大斩宏屠:BAAALgADCgEJAQAAAA==.',
['大胖']='大胖子哟:BAAALgAECgcJEQAAAA==.',
['大衮']='大衮:BAAALgAECgYJCAAAAA==.',
['天亮']='天亮休息七:BAABLgAECn8UAAIGAAYJTxrQawCzAQAGAAYJTxrQawCzAQABLgAFFAQJCQAIAC0BAA==.',
['天使']='天使之狂:BAAALgAECgEJBAAAAA==.',
['天奕']='天奕:BAAALgAECgEJAQAAAA==.',
['天娱']='天娱:BAAALgAECgcJBwAAAA==.',
['天棒']='天棒:BAAALgAFFAIJAwAAAA==.',
['天煞']='天煞丨奥法:BAAALgAFFAIJAgAAAA==.',
['头戴']='头戴牛角:BAAALgAECgEJAQAAAA==.',
['奎尔']='奎尔扎拉姆:BAAALgAFFAIJAgAAAA==.',
['奥司']='奥司他韦:BAAALgAECgUJBgAAAA==.',
['奶骑']='奶骑好嘢:BAAALgAECgcJDwAAAA==.',
['好叫']='好叫好伐额:BAAALgAECgQJCQAAAA==.',
['孤踴']='孤踴者:BAAALgAECgcJEgAAAA==.',
['安克']='安克雷奇:BAAALgAECgMJAwAAAA==.',
['官人']='官人吃一口嘛:BAAALgADCgYJBgAAAA==.',
['宝小']='宝小格:BAAALgAECgMJAwAAAA==.',
['审判']='审判之刄:BAAALgAECgQJBAAAAA==.',
['尊贵']='尊贵的双马尾:BAABLgAFFH8OAAILAAUJSA8UBABCAQALAAUJSA8UBABCAQAAAA==.',
['小天']='小天真:BAAALgAECgcJBwAAAA==.',
['小晨']='小晨诚丶:BAAALgAECgIJAwAAAA==.',
['小浪']='小浪蹄子灬丶:BAAALgAFFAEJAQAAAA==.',
['小皮']='小皮很无聊:BAAALgADCgUJBQAAAA==.',
['小花']='小花生糖:BAAALgAECgIJAgAAAA==.',
['小阮']='小阮:BAAALgAECgYJBgAAAA==.',
['就合']='就合宇宙术叮:BAAALgAFFAEJAQAAAA==.',
['就是']='就是喜欢你灬:BAAALgADCgEJAQAAAA==.',
['就玩']='就玩冰法:BAAALgAECgYJBgAAAA==.',
['崇唐']='崇唐:BAAALgAFFAQJBAABLgAFFAUJDAAIADIeAA==.',
['巅峰']='巅峰灬风行者:BAAALgAECgYJCwAAAA==.',
['帮你']='帮你解开:BAAALgADCgUJBQAAAA==.',
['幸运']='幸运之裤:BAAALgADCgEJAQAAAA==.',
['幽桐']='幽桐:BAAALgADCgEJAQAAAA==.',
['当我']='当我牵手那刻:BAAALgAECgIJAgAAAA==.',
['彩虹']='彩虹爸爸:BAAALgAFFAIJAgAAAA==.',
['往汐']='往汐青尺:BAAALgAECgUJCgABLgAFFAUJBAAJAAAAAA==.',
['快乐']='快乐星球:BAAALgAECgEJAQAAAA==.',
['怂的']='怂的一匹:BAAALgAFFAIJAgAAAA==.',
['悦厦']='悦厦:BAAALgAECgQJCAAAAA==.',
['情殒']='情殒殇悲:BAAALgAFFAIJAgAAAA==.',
['戀上']='戀上你的唇:BAAALgAFFAEJAQAAAA==.',
['我是']='我是剩骑士:BAAALgAFFAEJAQABLgAFFAIJCAAGALQfAA==.',
['我能']='我能胖:BAAALgAFFAEJAQAAAA==.',
['戳憋']='戳憋大魔王丶:BAAALgAECgEJAQAAAA==.',
['所谓']='所谓永恒:BAABLgAFFH8HAAIMAAMJ/RRiKgALAQAMAAMJ/RRiKgALAQAAAA==.',
['打一']='打一瓶酱油:BAAALgADCgEJAQAAAA==.',
['拉科']='拉科:BAAALgAECgQJBwAAAA==.',
['捌克']='捌克拉:BAAALgAECgkJCQAAAA==.',
['摩伊']='摩伊拉:BAAALgAFFAIJAwAAAA==.',
['放手']='放手就好:BAAALgAECgUJBQAAAA==.',
['文昌']='文昌兄:BAAALgADCgIJAgAAAA==.',
['旅途']='旅途终章:BAAALgAECgMJBAAAAA==.',
['无敌']='无敌丶炉石:BAAALgAECgEJAQAAAA==.',
['智娶']='智娶威虎山:BAAALgAECgcJDAAAAA==.',
['暂时']='暂时没想好:BAAALgAECgQJBwAAAA==.',
['暴匪']='暴匪:BAAALgAECgQJBwAAAA==.',
['暴躁']='暴躁好嘢:BAAALgAECgUJBQAAAA==.',
['月夜']='月夜高歌:BAAALgADCgYJBgAAAA==.',
['本姑']='本姑娘贝熙儿:BAAALgAECgYJBgAAAA==.',
['术沭']='术沭术:BAACLgAFFH8KAAINAAQJcBlWEABeAQANAAQJcBlWEABeAQAuAAQKfxwAAg0ACAmIJngEAHQDAA0ACAmIJngEAHQDAAAA.',
['朴实']='朴实的农民:BAAALgADCgUJBQAAAA==.',
['来一']='来一块面包:BAAALgAECgEJAwAAAA==.',
['枫恋']='枫恋之伊:BAAALgADCgMJAwAAAA==.枫恋之歌:BAAALgAFFAIJAgAAAA==.',
['柒克']='柒克拉:BAAALgAECgYJBgAAAA==.',
['格小']='格小宝:BAAALgAECgEJAgAAAA==.',
['楚涵']='楚涵:BAAALgAECgcJCwAAAA==.',
['武奶']='武奶好嘢:BAAALgAECgIJAgAAAA==.',
['残月']='残月丶汪:BAAALgAECgYJDAAAAA==.',
['沈一']='沈一一:BAAALgAECgcJBwAAAA==.',
['治疗']='治疗:BAAALgAECgcJAQAAAA==.',
['流浪']='流浪的猫:BAAALgADCgQJBAAAAA==.',
['浅水']='浅水戏锦鲤灬:BAAALgAECgEJAQAAAA==.',
['浅霜']='浅霜:BAACLgAFFH8LAAIOAAQJ+SUvAQDCAQAOAAQJ+SUvAQDCAQAuAAQKfx8AAg4ACAlFJagCADwDAA4ACAlFJagCADwDAAAA.',
['淡忘']='淡忘随风去:BAAALgAFFAIJAwAAAA==.',
['混沌']='混沌狐猎:BAABLgAECn8YAAIDAAgJ8Q6LMADuAQADAAgJ8Q6LMADuAQAAAA==.',
['游侠']='游侠之心:BAAALgAECgEJAQAAAA==.',
['灀月']='灀月:BAAALgAECgIJAgAAAA==.',
['灰烬']='灰烬光之伊瑞:BAAALgAECgEJAQAAAA==.',
['灵魂']='灵魂吸引:BAAALgADCgUJBQAAAA==.',
['炫彩']='炫彩喵喵:BAAALgAFFAIJBAAAAA==.',
['烟雨']='烟雨潇湘:BAAALgAECgYJBwAAAA==.',
['烧继']='烧继:BAABLgAECn8dAAIGAAgJTBukMAB1AgAGAAgJTBukMAB1AgAAAA==.',
['烬头']='烬头:BAAALgAECgUJDAAAAA==.',
['烬歌']='烬歌:BAAALgAECgUJBQAAAA==.',
['照穿']='照穿镜子:BAAALgAECgEJAQAAAA==.',
['燃烧']='燃烧之灭:BAACLgAFFH8JAAINAAQJVh6PDAB3AQANAAQJVh6PDAB3AQAuAAQKfxgAAw0ACQkrIRlTAM4BAA0ACAkrIRlTAM4BAA8ABAnAETEqABgBAAAA.',
['爱唯']='爱唯一:BAAALgAECgkJAgAAAA==.',
['猪丶']='猪丶小勇:BAAALgAECgUJBQAAAA==.',
['猪猪']='猪猪小:BAAALgAECgcJCQAAAA==.',
['玉修']='玉修罗:BAAALgAECgEJAQAAAA==.',
['王康']='王康丶:BAAALgAECgYJCAAAAA==.王康的呆毛:BAAALgAECgYJBgAAAA==.',
['瑞思']='瑞思拜:BAAALgAECgQJBgAAAA==.',
['田曦']='田曦薇:BAAALgAECgYJDQAAAA==.',
['畩嘫']='畩嘫豪氣冲天:BAAALgAFFAIJAgAAAA==.',
['痛苦']='痛苦丶压制:BAAALgADCgIJAwAAAA==.',
['白井']='白井黒子:BAAALgAECgMJAwAAAA==.',
['白狼']='白狼哥:BAAALgADCgYJBgAAAA==.',
['白虎']='白虎猎:BAABLgAECn8XAAIQAAcJ9SHrBQCoAgAQAAcJ9SHrBQCoAgAAAA==.',
['皇家']='皇家天狼:BAAALgAECgEJAgAAAA==.',
['知名']='知名不惧:BAAALgAECgEJAQAAAA==.',
['神仙']='神仙采香蕉:BAACLgAFFH8MAAINAAUJnB4FBQBvAQANAAUJnB4FBQBvAQAuAAQKfx8AAw0ACAmlIU0dAKYCAA0ACAmlIU0dAKYCABEAAQkAAEonAFQAAAAA.',
['精灵']='精灵之火:BAAALgAFFAIJAwAAAA==.',
['维爷']='维爷:BAABLgAFFH8KAAIEAAMJOxPbCwAFAQAEAAMJOxPbCwAFAQAAAA==.',
['罪与']='罪与罚的挽歌:BAAALgAECgQJBAAAAA==.',
['老螃']='老螃蟹:BAAALgAECgkJCQAAAA==.',
['肆克']='肆克拉:BAAALgAECgcJDgAAAA==.',
['背带']='背带裤:BAAALgAFFAIJAgAAAA==.',
['胖八']='胖八爷:BAAALgAECgYJBgAAAA==.',
['胡壮']='胡壮壮:BAAALgAECgYJCwAAAA==.',
['自豪']='自豪:BAAALgAECgYJBgAAAA==.',
['致爱']='致爱丽丝:BAACLgAFFH8FAAIKAAIJRRVUEgC3AAAKAAIJRRVUEgC3AAAuAAQKfxoAAgoACAk4HOYLANgCAAoACAk4HOYLANgCAAAA.',
['艾勒']='艾勒蒙特:BAAALgAECgQJBAAAAA==.',
['艾路']='艾路雷朵:BAAALgAECgkJCAAAAA==.',
['芸啾']='芸啾:BAAALgAECgUJCwAAAA==.',
['苏冉']='苏冉冉:BAAALgAECgYJCAAAAA==.',
['苏格']='苏格儿:BAAALgAFFAIJAgAAAA==.',
['莞镁']='莞镁啲主题曲:BAAALgAECgEJAQAAAA==.',
['莫名']='莫名好嘢:BAAALgAECgYJBgAAAA==.',
['莫宁']='莫宁丶:BAAALgAECgYJBgAAAA==.',
['菲菲']='菲菲雪儿:BAAALgAECgUJBgAAAA==.',
['萌萌']='萌萌丶抵消灰:BAABLgAFFH8FAAIHAAUJLABLFABiAAAHAAUJLABLFABiAAAAAA==.萌萌哒:BAAALgAECgkJCQAAAA==.',
['萨满']='萨满好嘢:BAAALgADCgUJBQAAAA==.',
['落笔']='落笔畵永恒:BAAALgAECgYJBgAAAA==.',
['落花']='落花留水:BAAALgAECgMJAwAAAA==.',
['蓝山']='蓝山咖啡:BAAALgADCgEJAQAAAA==.',
['虚空']='虚空之饭:BAAALgAECgQJBAAAAA==.',
['詤大']='詤大霞丶:BAAALgAECgEJAQAAAA==.',
['记行']='记行云梦影丶:BAAALgAECgIJAgAAAA==.',
['许多']='许多多:BAAALgAECgEJAgAAAA==.',
['贝熙']='贝熙儿丶橙多:BAAALgAECgkJDwAAAA==.',
['财财']='财财:BAAALgAECgEJAQAAAA==.',
['路德']='路德维希:BAAALgAECgcJBwAAAA==.',
['这是']='这是什么邪法:BAACLgAFFH8NAAMCAAQJOR2mDQBiAQACAAQJ7BWmDQBiAQASAAIJ7hyyBwC1AAAuAAQKfyQAAxIACAm1Ib4JAMYCAAIACAlHHzYTAOYCABIACAngH74JAMYCAAAA.',
['醉医']='醉医生:BAAALgADCgYJBgAAAA==.',
['铁汁']='铁汁:BAAALgAFFAMJAwAAAA==.',
['问归']='问归期丶:BAAALgAECgUJBwAAAA==.',
['阿尔']='阿尔卑斯:BAAALgADCgEJAQAAAA==.',
['阿苏']='阿苏焉:BAAALgADCgcJBwABLgAFFAUJDAAIADIeAA==.',
['阿诺']='阿诺牛瓦辛格:BAAALgADCgEJAQAAAA==.',
['陆克']='陆克拉:BAAALgAECgMJAwAAAA==.',
['雄丶']='雄丶赳赳:BAAALgAECgEJAQAAAA==.',
['雅琪']='雅琪萝贝:BAAALgAECgUJBgAAAA==.',
['雙子']='雙子星號:BAAALgAECgkJCQAAAA==.',
['雨後']='雨後小故事:BAAALgAECgEJAQABLgAECgYJBgAJAAAAAA==.',
['雪狐']='雪狐狂刀:BAAALgAECgQJBAAAAA==.',
['雪碧']='雪碧凤梨酥:BAAALgAECgMJAwAAAA==.',
['雷电']='雷电法神:BAAALgADCgEJAQAAAA==.',
['雷米']='雷米尔:BAAALgAECgYJDAAAAA==.',
['雷雨']='雷雨时若:BAAALgAECgQJAQAAAA==.',
['霖泽']='霖泽天枢啸啸:BAAALgAECgcJDQAAAA==.',
['青铜']='青铜逗逗:BAAALgAECgYJBgAAAA==.',
['顾清']='顾清涵:BAAALgADCgQJBAAAAA==.',
['飘逸']='飘逸鳯舞:BAAALgADCgQJBAAAAA==.',
['香喷']='香喷喷的咕咕:BAAALgADCgEJAQAAAA==.',
['香飘']='香飘飘玉绮肜:BAAALgADCgUJBQAAAA==.',
['骇人']='骇人鲸:BAABLgAFFH8GAAMHAAIJUhSKDwCUAAAHAAIJUhSKDwCUAAAIAAEJYwA0HQBAAAABLgAFFAUJEwATAHIWAA==.',
['魔爪']='魔爪莫小莫:BAAALgAECgEJAQAAAA==.',
['鱼摆']='鱼摆摆了不起:BAAALgADCgkJCQAAAA==.',
['麽麽']='麽麽哒丶:BAAALgAECgEJAQAAAA==.',
['黄妹']='黄妹妹:BAAALgAECgEJAQAAAA==.',
['龙龙']='龙龙不说再见:BAAALgAECgYJBwAAAA==.',
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
