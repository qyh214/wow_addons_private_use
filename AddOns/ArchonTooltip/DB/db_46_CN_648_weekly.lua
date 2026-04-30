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

local lookup = {'Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','Druid-Restoration','Druid-Balance','Monk-Brewmaster','Paladin-Holy','Evoker-Preservation','Mage-Frost','Warrior-Protection','Evoker-Augmentation','DeathKnight-Unholy','DeathKnight-Blood','Priest-Discipline','Warrior-Arms','Priest-Holy','Hunter-Marksmanship','Paladin-Retribution','DemonHunter-Devourer',}
local provider = {region='CN',realm='安其拉',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ba='Babyya:BAAALgADCgMJAwAAAA==.',
Dr='Dreamer:BAAALgAECgQJBAAAAA==.',
Ko='Kobus:BAABLgAFFH8HAAIBAAMJdSMXBgBBAQABAAMJdSMXBgBBAQAAAA==.',
Lo='Locer:BAABLgAECn8ZAAMCAAcJ7Rv1UQDSAQACAAYJ7Rv1UQDSAQADAAMJWRH7PgC5AAAAAA==.',
Mo='Monstr:BAAALgAECgQJAwAAAA==.',
Sl='Slava:BAAALgADCgIJAgAAAA==.',
Ty='Typhus:BAACLgAFFH8FAAIEAAIJ+QqLDQCAAAAEAAIJ+QqLDQCAAAAuAAQKfxQAAwQABgn9GhY9AK8BAAQABgn9GhY9AK8BAAUAAgm1DVVxAFoAAAAA.',
['一只']='一只呼呼:BAAALgAECgQJBAAAAA==.',
['一夫']='一夫当关:BAABLgAFFH8FAAIGAAIJDRynFwCyAAAGAAIJDRynFwCyAAAAAA==.',
['万物']='万物归一:BAAALgAECgUJBQAAAA==.',
['万能']='万能的排叫兽:BAAALgADCgQJBAAAAA==.',
['三圈']='三圈布鲁根:BAAALgAECgEJAgAAAA==.',
['不好']='不好吃啊:BAAALgAECgkJBgAAAA==.',
['专家']='专家:BAACLgAFFH8FAAIHAAIJPyX/DwDZAAAHAAIJPyX/DwDZAAAuAAQKfxYAAgcABwluIzIOAKYCAAcABwluIzIOAKYCAAAA.',
['世泣']='世泣:BAAALgADCgEJAgAAAA==.',
['亚莉']='亚莉亚:BAAALgAECgEJAQAAAA==.',
['亡口']='亡口月贝凡:BAAALgAECgEJAQAAAA==.',
['人间']='人间造:BAAALgAECgEJAQAAAA==.',
['今夏']='今夏:BAAALgAECgQJBAAAAA==.',
['从圣']='从圣洁到光明:BAAALgAECgEJAQAAAA==.',
['伊蓝']='伊蓝:BAAALgAECgQJBQAAAA==.',
['传说']='传说中的鱼:BAAALgAECgEJAQAAAA==.',
['偷懒']='偷懒的牛:BAAALgADCgYJBgAAAA==.',
['光之']='光之祭丶:BAAALgAECgYJCgAAAA==.',
['兔斯']='兔斯基:BAAALgAECgEJAQAAAA==.',
['兜兜']='兜兜里有糖糖:BAAALgADCgUJBQAAAA==.',
['八奈']='八奈见:BAAALgAFFAIJAwABLgAFFAMJBwAIABQbAA==.',
['功夫']='功夫熊猫:BAAALgAECgQJBAAAAA==.',
['勇敢']='勇敢的心:BAAALgAECgYJBQAAAA==.',
['十八']='十八铜人:BAAALgAECgIJBAAAAA==.',
['半神']='半神的救赎:BAAALgADCgQJBAAAAA==.',
['可爱']='可爱小白兔:BAAALgAECgEJAQAAAA==.',
['吉姆']='吉姆格琳:BAAALgAFFAIJBAAAAA==.吉姆格霖:BAAALgAFFAEJAQAAAA==.',
['吉米']='吉米:BAAALgAECgcJCgAAAA==.',
['咖啡']='咖啡加点糖:BAAALgAECgMJBAAAAA==.',
['哇哇']='哇哇叫:BAAALgAECgYJBgAAAA==.',
['啥都']='啥都想试试:BAAALgAFFAIJAwAAAA==.',
['善仔']='善仔:BAAALgAECgYJBgAAAA==.',
['嘉文']='嘉文四世:BAAALgAECgQJBgAAAA==.',
['嘚吧']='嘚吧嘚吧:BAAALgADCgQJBAAAAA==.',
['嘿丶']='嘿丶嘿嘿:BAAALgAECgEJAgAAAA==.',
['噬魂']='噬魂之灵:BAAALgAECgYJBgAAAA==.',
['嚎呦']='嚎呦跟:BAAALgAECgYJDAAAAA==.',
['圣光']='圣光的罪孽:BAAALgADCgEJAQAAAA==.',
['圣歌']='圣歌乐章:BAAALgAECgEJAQAAAA==.',
['坦格']='坦格利安:BAAALgAECgcJDwAAAA==.',
['堕落']='堕落金刚:BAAALgADCgQJBAAAAA==.',
['塞斯']='塞斯恨:BAAALgAECgcJCwAAAA==.',
['墨尘']='墨尘熙:BAAALgADCgIJAgAAAA==.',
['夏日']='夏日漱石:BAACLgAFFH8HAAICAAMJwB+jGgAeAQACAAMJwB+jGgAeAQAuAAQKfxYAAwIABwlFHtskAH8CAAIABwlFHtskAH8CAAMAAQn4GlRhAEsAAAAA.',
['夏颉']='夏颉:BAAALgAECgMJAwAAAA==.',
['大地']='大地守护者:BAAALgADCgEJAQAAAA==.',
['大妖']='大妖兽:BAAALgAECgYJCQAAAA==.',
['大气']='大气上档次:BAAALgAECggJCAAAAA==.',
['大聪']='大聪明殿下:BAAALgAECgIJAgAAAA==.',
['天使']='天使神兵:BAAALgAECgEJAQAAAA==.',
['天殛']='天殛血影:BAAALgAECgYJBgAAAA==.',
['天空']='天空的畅想:BAAALgAECgEJAQAAAA==.',
['天道']='天道有眷:BAAALgAFFAEJAQAAAA==.',
['契尔']='契尔年科:BAAALgADCgEJAQAAAA==.',
['奥德']='奥德斯:BAAALgAFFAIJAgAAAA==.',
['媾合']='媾合:BAAALgAECgMJAwAAAA==.',
['嫩嫩']='嫩嫩:BAAALgAECgYJDQAAAA==.',
['子君']='子君乔:BAAALgAECgIJAgAAAA==.',
['富婆']='富婆的奇趣蛋:BAAALgAECgkJCQAAAA==.',
['小动']='小动物终结者:BAAALgAECgYJEgAAAA==.',
['小妖']='小妖魔:BAAALgAECgcJDQAAAA==.',
['小德']='小德花样多:BAAALgAECgYJCgAAAA==.',
['小牛']='小牛来救你:BAAALgAECgIJAgAAAA==.',
['小薰']='小薰:BAAALgADCgYJCAAAAA==.',
['小鸡']='小鸡迪克:BAAALgADCgEJAQAAAA==.',
['尐七']='尐七:BAABLgAECn8lAAIJAAgJdxlNSABeAgAJAAgJdxlNSABeAgAAAA==.',
['尐柒']='尐柒:BAAALgAECgYJEwAAAA==.',
['尘墨']='尘墨池:BAAALgAECgIJBAAAAA==.',
['尘封']='尘封的旋律:BAABLgAFFH8FAAIKAAIJJwWkDQBwAAAKAAIJJwWkDQBwAAAAAA==.',
['尤娜']='尤娜塔斯:BAACLgAFFH8HAAIIAAMJFBt1DAAgAQAIAAMJFBt1DAAgAQAuAAQKfyUAAwgACAmjI5UDACYDAAgACAmjI5UDACYDAAsAAQkAAGRZAFgAAAAA.',
['就说']='就说大不大:BAAALgADCgQJBAAAAA==.',
['岁岁']='岁岁:BAAALgAFFAIJAgAAAA==.',
['岸然']='岸然狼哥:BAAALgAECgEJAQAAAA==.',
['希尔']='希尔佤那斯:BAAALgADCgYJBwAAAA==.',
['开颅']='开颅术:BAAALgADCgUJBgAAAA==.',
['情敌']='情敌靠边闪:BAAALgAECgYJBgAAAA==.',
['慕容']='慕容灬冷月:BAAALgAECgQJBAAAAA==.',
['战世']='战世:BAAALgADCgEJAQAAAA==.',
['托尔']='托尔:BAAALgAECgkJBwAAAA==.',
['扼魔']='扼魔之刃:BAAALgADCgEJAQAAAA==.',
['拿铁']='拿铁加冰:BAAALgAECgMJAwAAAA==.',
['无星']='无星的夜空:BAACLgAFFH8KAAIJAAQJiRvqBAB6AQAJAAQJiRvqBAB6AQAuAAQKfxoAAgkABwlRJFsxAK0CAAkABwlRJFsxAK0CAAAA.',
['星云']='星云叹:BAAALgADCgQJBAAAAA==.',
['會發']='會發光的黑手:BAAALgAECgMJAwAAAA==.',
['杨喵']='杨喵喵:BAAALgAECgYJBQAAAA==.',
['柒絕']='柒絕鬼牧:BAAALgAFFAIJAwAAAA==.',
['欧叶']='欧叶:BAAALgAFFAIJAgAAAA==.',
['武升']='武升:BAAALgADCgEJAgAAAA==.',
['残暴']='残暴的番茄:BAAALgADCgYJBQAAAA==.',
['残隠']='残隠殇丶玥:BAABLgAFFH8NAAIJAAQJYSEYDQCzAQAJAAQJYSEYDQCzAQABLgAFFAUJBwAJAMcZAA==.',
['比邻']='比邻星:BAABLgAECn8ZAAIMAAcJbBDafgCFAQAMAAcJbBDafgCFAQAAAA==.',
['水的']='水的结晶:BAAALgAECgcJBwAAAA==.',
['洛丹']='洛丹伦的公牛:BAAALgADCgYJBgAAAA==.',
['洛丽']='洛丽塔:BAAALgAECgYJBgAAAA==.',
['灵魂']='灵魂的触摸:BAAALgAECgIJAgAAAA==.',
['煭人']='煭人:BAAALgADCgEJAwAAAA==.',
['牛中']='牛中的战斗牛:BAAALgAECgQJBAAAAA==.',
['牛小']='牛小鑫:BAAALgADCgEJAQAAAA==.',
['牛氓']='牛氓界扛把子:BAAALgAECgEJAQAAAA==.',
['狐战']='狐战:BAAALgAECgYJDAAAAA==.',
['独饮']='独饮心上秋:BAAALgAECgEJAQAAAA==.',
['猎兔']='猎兔犬:BAAALgAECgIJAgAAAA==.',
['猎小']='猎小猎:BAAALgAECgYJEQAAAA==.',
['猪丫']='猪丫头:BAAALgAECgEJAQAAAA==.',
['玩好']='玩好就去学习:BAAALgAFFAIJAgAAAA==.玩好立刻学习:BAAALgAFFAEJAwABLgAFFAYJDAANABkYAA==.',
['玩手']='玩手电的黑猫:BAAALgAECgEJAQAAAA==.',
['甜不']='甜不辣:BAAALgAECgYJBgAAAA==.',
['盜戝']='盜戝:BAAALgADCgEJAQAAAA==.',
['眷墨']='眷墨:BAABLgAFFH8IAAIMAAIJohhlFgCuAAAMAAIJohhlFgCuAAAAAA==.',
['睡不']='睡不醒的乙醇:BAAALgAECgcJBwAAAA==.',
['石原']='石原里美:BAAALgAFFAIJAgAAAA==.',
['破丷']='破丷破:BAAALgAECggJEQAAAA==.',
['神德']='神德小妞妞:BAAALgAECgEJAQAAAA==.',
['穆光']='穆光:BAAALgADCgUJAQAAAA==.',
['空白']='空白人生:BAAALgADCgYJBgAAAA==.',
['窝窝']='窝窝四三:BAABLgAFFH8FAAIOAAUJOQ5fBQCRAQAOAAUJOQ5fBQCRAQAAAA==.窝窝四二:BAAALgAFFAUJAwAAAA==.窝窝四四:BAAALgAFFAUJAQAAAA==.窝窝四零:BAAALgAFFAQJBAAAAA==.',
['粥润']='粥润发:BAACLgAFFH8GAAMKAAUJHQL+BwDcAAAKAAQJXQL+BwDcAAAPAAEJXQE0DgArAAAuAAQKfxcAAgoABwnHCS4jACUBAAoABwnHCS4jACUBAAAA.',
['绝恋']='绝恋枫色:BAAALgAECgUJBgAAAA==.',
['群尸']='群尸玩过界:BAABLgAECn8XAAIQAAgJrxQAGQAUAgAQAAgJrxQAGQAUAgAAAA==.',
['肃世']='肃世:BAAALgADCgEJAgAAAA==.',
['胧夜']='胧夜:BAAALgAECgcJDQAAAA==.',
['腰基']='腰基老损:BAAALgAECgQJBAAAAA==.',
['舍弃']='舍弃的刀锋:BAAALgADCgEJAQAAAA==.',
['芡甩']='芡甩尒崬覀:BAAALgADCgEJAQAAAA==.',
['芹泽']='芹泽多摩熊:BAAALgAECgMJAwAAAA==.',
['落星']='落星丶末世:BAAALgAECgIJAwAAAA==.',
['虾人']='虾人不眨眼:BAACLgAFFH8FAAMRAAIJzQdjIACTAAARAAIJxQdjIACTAAABAAEJ0gzrKQBOAAAuAAQKfxsAAxEACQnCFgoYAGoCABEACQmfEwoYAGoCAAEABglqHGgYADgBAAAA.',
['说晚']='说晚安:BAAALgAFFAEJAQAAAA==.',
['贝露']='贝露丹蒂:BAAALgAECgkJBAAAAA==.',
['超级']='超级筋头巴脑:BAAALgAFFAEJAQAAAA==.',
['辰曦']='辰曦:BAABLgAECn8XAAISAAcJFhNWYQDBAQASAAcJFhNWYQDBAQAAAA==.',
['近战']='近战图腾:BAAALgAFFAEJAgAAAA==.',
['这是']='这是个国宝:BAAALgAECgMJAwAAAA==.',
['迪俪']='迪俪热巴:BAAALgAECgYJCgAAAA==.',
['逍遥']='逍遥梦魇:BAAALgAECgMJAwAAAA==.',
['通幽']='通幽骑士:BAAALgAECgMJAgAAAA==.',
['邪恶']='邪恶烙印:BAAALgADCgEJAQAAAA==.',
['金刚']='金刚护体:BAAALgAFFAQJBAAAAA==.',
['银月']='银月:BAAALgAECgcJDAAAAA==.',
['陶英']='陶英英:BAAALgADCgEJAQAAAA==.',
['随机']='随机:BAAALgAECgYJBwAAAA==.',
['非言']='非言非:BAAALgAECgEJAQAAAA==.',
['风月']='风月无常:BAAALgAECgYJCQAAAA==.',
['飞天']='飞天遁地:BAAALgADCgEJAQAAAA==.',
['香蕉']='香蕉怪兽:BAAALgAECgEJAQAAAA==.',
['驱灵']='驱灵人:BAACLgAFFH8FAAIQAAIJQhBqDACbAAAQAAIJQhBqDACbAAAuAAQKfxcAAxAABwnDGFceAOwBABAABwlpGFceAOwBAA4AAglHGB0RAJQAAAEuAAUUBQkFABMA3xoA.',
['骑猪']='骑猪去流浪:BAAALgAECgUJCQAAAA==.',
['鳌峰']='鳌峰:BAAALgAECgYJCgAAAA==.',
['鸡腿']='鸡腿好香:BAAALgAECgEJAgAAAA==.',
['黑暗']='黑暗阿尔法:BAAALgAECgMJBAAAAA==.',
['龙血']='龙血之刃:BAAALgAECgcJBwAAAA==.',
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
