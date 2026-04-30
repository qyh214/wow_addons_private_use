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

local lookup = {'Paladin-Retribution','Druid-Restoration','Druid-Balance','Shaman-Restoration','Mage-Frost','DeathKnight-Unholy','DemonHunter-Havoc','DemonHunter-Vengeance','Unknown-Unknown','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','DemonHunter-Devourer','Priest-Holy','Priest-Shadow','Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Brewmaster','Shaman-Elemental',}
local provider = {region='CN',realm='蓝龙军团',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Addiction:BAABLgAFFH8NAAIBAAQJkBqLAwBtAQABAAQJkBqLAwBtAQAAAA==.',
Al='Aldrich:BAABLgAECn8VAAICAAgJNxU7JQAkAgACAAgJNxU7JQAkAgAAAA==.',
As='Ascot:BAABLgAFFH8PAAMCAAQJ9CIPAwCHAQACAAQJ9CIPAwCHAQADAAMJFByiDAAZAQAAAA==.',
Bl='Blooddiamond:BAAALgADCgcJBwAAAA==.',
Ce='Cenariusy:BAAALgADCgMJAwAAAA==.',
Cl='Clemm:BAAALgAECgYJCAABLgAFFAIJBwAEAGYmAA==.',
Cr='Cr:BAAALgAECgUJBQAAAA==.',
Do='Donk:BAAALgADCgcJBwAAAA==.',
Go='Goodwater:BAAALgADCgYJBgAAAA==.',
Ka='Kachikin:BAAALgAECgEJAQAAAA==.',
Ma='Mamakoto:BAABLgAECn8VAAIFAAgJqBdXUwA+AgAFAAgJqBdXUwA+AgAAAA==.',
Me='Memory:BAAALgAECgQJAwAAAA==.',
Mi='Milos:BAAALgAECgQJBQAAAA==.',
No='Nobrains:BAAALgAFFAEJAQABLgAFFAQJDwACAPQiAA==.',
Pa='Pararon:BAAALgAECgIJAgAAAA==.',
Ru='Ruthless:BAAALgADCgUJBQAAAA==.',
Sa='Sagergesaer:BAAALgAECgYJCAAAAA==.',
Si='Sideanilafoi:BAAALgADCgEJAgAAAA==.',
Sm='Smartmoon:BAAALgAECgYJCAAAAA==.',
Yo='Yolo:BAAALgAECgcJEgAAAA==.',
Zf='Zfocean:BAAALgAFFAEJAgAAAA==.',
['一二']='一二零:BAAALgAECgEJAQAAAA==.',
['一碰']='一碰就倒:BAAALgAECgYJCgAAAA==.',
['一肆']='一肆:BAAALgAECgEJAQAAAA==.',
['三好']='三好生:BAAALgADCgEJAQAAAA==.',
['三碗']='三碗不过岗:BAABLgAECn8bAAIGAAgJ6xQ4SAAbAgAGAAgJ6xQ4SAAbAgAAAA==.',
['不公']='不公平的世界:BAAALgAECgEJAQAAAA==.',
['两发']='两发入魂:BAAALgAECgQJBAAAAA==.',
['丶小']='丶小馒頭:BAAALgAECgcJDQAAAA==.',
['丶月']='丶月光馒头:BAAALgAECgUJBQAAAA==.',
['乃二']='乃二:BAAALgAECgEJAQABLgAFFAUJCwADAAgHAA==.',
['乌瑞']='乌瑞亚斯:BAAALgADCgYJBAAAAA==.',
['五月']='五月雨:BAAALgAECgkJCQAAAA==.',
['会遗']='会遗憾吗:BAACLgAFFH8JAAIFAAQJTRHqFgAEAQAFAAQJTRHqFgAEAQAuAAQKfxQAAgUACAnqGHQ4AJMCAAUACAnqGHQ4AJMCAAAA.',
['但丁']='但丁说灬:BAAALgAECgMJAwAAAA==.',
['依然']='依然那么牛:BAAALgADCgEJAQAAAA==.',
['偌只']='偌只如初見:BAAALgAFFAIJAgAAAA==.',
['全体']='全体起立:BAABLgAECn8UAAMHAAgJeBtwDQCMAgAHAAgJeBtwDQCMAgAIAAIJRRU8IgBxAAAAAA==.',
['八月']='八月秋风:BAAALgAECgIJAgAAAA==.',
['关芝']='关芝琳:BAABLgAFFH8GAAIBAAQJ4xWbDQD4AAABAAQJ4xWbDQD4AAABLgAFFAQJCgAFAGIcAA==.',
['冬幕']='冬幕节咭安娜:BAAALgAECgYJBgAAAA==.',
['别担']='别担心名字长:BAAALgADCgEJAQAAAA==.',
['北城']='北城巛雲战天:BAAALgAECgkJCgABLgAFFAUJBAAJAAAAAA==.',
['半夏']='半夏:BAAALgAECgMJAwAAAA==.',
['卡希']='卡希乌斯:BAAALgAECgQJAwAAAA==.',
['卡戴']='卡戴珊:BAAALgAFFAQJBAAAAA==.',
['却冬']='却冬:BAAALgAECgIJAgABLgAFFAIJBAAJAAAAAA==.',
['古丽']='古丽塞露塔:BAAALgADCgUJAgAAAA==.',
['古力']='古力娜扎:BAAALgAECgEJAQABLgAFFAQJCgAFAGIcAA==.',
['吃有']='吃有文化的亏:BAAALgADCgQJBAAAAA==.',
['吃没']='吃没文化的亏:BAAALgAECgYJEAAAAA==.',
['名侦']='名侦探兔美:BAACLgAFFH8IAAQKAAQJ0BHoAABrAAALAAIJrQ5vNQCoAAAKAAEJgyLoAABrAAAMAAEJYwdiFwBQAAAuAAQKfxQABAsACAl1GDRqAI4BAAsABQk7HDRqAI4BAAwAAwkGD708AMEAAAoAAQnjG3MoAE8AAAAA.',
['呼啸']='呼啸而过:BAAALgAECgQJBwAAAA==.',
['咕噜']='咕噜咕咕:BAAALgADCgIJAgAAAA==.',
['唯獨']='唯獨的德:BAAALgAECgEJAQAAAA==.',
['喵手']='喵手回春:BAAALgAECgYJCQAAAA==.',
['嗲猫']='嗲猫猫:BAAALgAECgYJCgAAAA==.',
['嗷唔']='嗷唔派大星:BAAALgADCgEJAQAAAA==.',
['国泰']='国泰民安:BAAALgADCgQJBAAAAA==.',
['圆圆']='圆圆的大肚纸:BAAALgAECgEJAQAAAA==.',
['土灵']='土灵圣骑:BAAALgAECgMJBAAAAA==.',
['土豆']='土豆毅:BAAALgAECgcJEwAAAA==.',
['圣光']='圣光霹雳:BAAALgAECgQJCAAAAA==.',
['圣太']='圣太少:BAAALgADCgQJBAAAAA==.',
['地图']='地图鱼:BAAALgAECgIJAgAAAA==.',
['夜苌']='夜苌箜:BAAALgAECgQJCAAAAA==.',
['夜长']='夜长空:BAAALgAECgQJCQAAAA==.',
['大明']='大明星王祖贤:BAAALgAECgQJBwABLgAFFAQJCgAFAGIcAA==.',
['大罗']='大罗顾小桑:BAAALgAECgQJBAAAAA==.',
['大高']='大高个:BAABLgAFFH8GAAINAAMJlQXUDACkAAANAAMJlQXUDACkAAAAAA==.',
['天启']='天启睿:BAAALgAFFAEJAgAAAA==.',
['天狼']='天狼心:BAAALgADCgMJAwAAAA==.',
['天祺']='天祺领主:BAAALgAECgQJBAAAAA==.',
['奈克']='奈克赛斯:BAABLgAECn8gAAMOAAgJqRqYDgC6AQAOAAgJqRqYDgC6AQAHAAEJ/RVdbwA2AAAAAA==.',
['奶娘']='奶娘:BAAALgAECgQJBAAAAA==.',
['妙手']='妙手空空:BAAALgAECgUJCQAAAA==.',
['威小']='威小灰:BAAALgADCgcJBwAAAA==.',
['娃娃']='娃娃:BAAALgAECgQJBwAAAA==.',
['守护']='守护者阿洛迪:BAACLgAFFH8HAAIPAAMJ2h4yBAD5AAAPAAMJ2h4yBAD5AAAuAAQKfxQAAw8ACAnmJCwCAE4DAA8ACAnmJCwCAE4DABAAAgnYCFBVAG0AAAAA.',
['安娜']='安娜贝丽:BAACLgAFFH8SAAIDAAUJtxDwBQCIAQADAAUJtxDwBQCIAQAuAAQKfxkAAgMACQmYG7wRAIwCAAMACQmYG7wRAIwCAAAA.',
['安德']='安德妮海瑟薇:BAAALgAECgcJBwAAAA==.',
['宓惠']='宓惠:BAAALgAECgkJDgAAAA==.',
['小光']='小光:BAACLgAFFH8PAAMRAAUJaSG1AQDSAQARAAUJ8iC1AQDSAQAPAAEJMBe1EQBYAAAuAAQKfxwABBEACAloIu4FAO0CABEABwlPJO4FAO0CAA8ABQlJHtApAKQBABAAAwnWHOo/APcAAAAA.',
['小天']='小天后孙燕姿:BAAALgAECgcJDQABLgAFFAQJCgAFAGIcAA==.',
['小艾']='小艾芙:BAAALgAECgIJAgAAAA==.',
['小韶']='小韶涵:BAACLgAFFH8KAAIFAAQJYhxNBwByAQAFAAQJYhxNBwByAQAuAAQKfx8AAgUABwn4IGhDAG4CAAUABwn4IGhDAG4CAAAA.',
['少帅']='少帅寇仲:BAAALgAECgYJDQAAAA==.',
['就是']='就是这么浪:BAAALgAECgQJBAAAAA==.',
['山内']='山内鈴蘭:BAAALgADCgEJAQAAAA==.',
['差不']='差不多先生灬:BAAALgAECgEJAQAAAA==.',
['希尔']='希尔娜娜斯:BAAALgAECgQJBAAAAA==.',
['希格']='希格文:BAAALgAFFAEJAQAAAA==.',
['帝国']='帝国纯爷们:BAAALgAECgEJAQAAAA==.',
['幻法']='幻法:BAAALgADCggJCAAAAA==.',
['影子']='影子狼:BAAALgAECgQJBQAAAA==.',
['德国']='德国妮子:BAAALgAECgYJCQAAAA==.',
['德鲁']='德鲁零:BAAALgADCgEJAQABLgAFFAIJBAAJAAAAAA==.',
['急行']='急行的猎豹:BAACLgAFFH8IAAISAAMJpQ/sCwADAQASAAMJpQ/sCwADAQAuAAQKfx0AAxIACAnUGhkWAIcCABIACAnUGhkWAIcCABMABAlkFGVWAO8AAAAA.',
['悠悠']='悠悠残月:BAAALgAECgQJCgAAAA==.',
['悲哀']='悲哀的小松鼠:BAAALgAECgMJBAAAAA==.',
['感触']='感触生灵:BAAALgAECgMJAwAAAA==.',
['戀愛']='戀愛:BAABLgAECn8VAAMPAAcJhQsEPABKAQAPAAcJgAoEPABKAQARAAUJ1Qb4OwDKAAAAAA==.',
['戀蕊']='戀蕊:BAAALgAECgYJCAAAAA==.',
['戀魚']='戀魚:BAAALgAECgYJBgAAAA==.',
['成就']='成就一萨:BAAALgAECgYJDgAAAA==.',
['我真']='我真的跑不动:BAAALgAFFAIJBAAAAA==.',
['戳泡']='戳泡泡龙:BAAALgADCgYJBgAAAA==.',
['手抓']='手抓屁制造者:BAAALgADCgUJBQAAAA==.',
['打大']='打大雷:BAAALgAECgUJBQAAAA==.',
['打来']='打来玩的贰:BAAALgAECgQJBAAAAA==.',
['折翼']='折翼的圣光:BAAALgAECgQJCQAAAA==.折翼的狐狸:BAAALgAECgUJBgAAAA==.',
['拓跋']='拓跋砡儿:BAAALgAECgQJBQABLgAECgQJCgAJAAAAAA==.',
['散打']='散打九段:BAAALgAECgcJDQAAAA==.',
['无尺']='无尺灬:BAAALgAECgUJBQAAAA==.',
['星野']='星野梦夏树:BAACLgAFFH8GAAICAAQJbhnyBwBTAQACAAQJbhnyBwBTAQAuAAQKfxcAAgIABwnAJF8NANECAAIABwnAJF8NANECAAAA.',
['是个']='是个泡泡:BAABLgAECn8dAAIUAAgJ4xK5KADCAQAUAAgJ4xK5KADCAQAAAA==.',
['暖暖']='暖暖的微笑:BAAALgAFFAEJAQAAAA==.',
['月夜']='月夜雪纷飞:BAAALgAECgQJBQABLgAECgQJCgAJAAAAAA==.',
['机智']='机智的筱白:BAAALgAECgEJAgAAAA==.',
['杰斯']='杰斯塞索:BAAALgAECgQJBAAAAA==.',
['杰西']='杰西卡女士:BAAALgAECgYJEwAAAA==.',
['枫小']='枫小雨:BAAALgAECgEJAQAAAA==.',
['栋栋']='栋栋:BAAALgAECgUJBQAAAA==.',
['梦月']='梦月影:BAAALgAECgkJBwAAAA==.',
['毛装']='毛装小红手呆:BAAALgAECgYJBgAAAA==.',
['水调']='水调歌头:BAAALgAECgkJCwAAAA==.',
['氷鎖']='氷鎖:BAAALgADCgkJEAAAAA==.',
['永不']='永不缺席:BAAALgAECgUJBQAAAA==.',
['永胤']='永胤:BAAALgAECgYJDAAAAA==.',
['洛苏']='洛苏涵:BAAALgADCgUJBQAAAA==.',
['浮戌']='浮戌:BAAALgAECgMJAwAAAA==.',
['海盗']='海盗旗他哥:BAAALgADCgIJAgAAAA==.',
['海胆']='海胆:BAABLgAECn8aAAIVAAgJVCAwCgDxAgAVAAgJVCAwCgDxAgAAAA==.',
['溅射']='溅射满天:BAAALgADCgcJBwAAAA==.',
['火焰']='火焰爆轰:BAAALgAECgUJCQAAAA==.',
['灬猫']='灬猫児灬:BAAALgAECgkJCAABLgAFFAYJBAAJAAAAAA==.',
['炎爆']='炎爆羊肉拌面:BAAALgAECgEJAQAAAA==.',
['炫蓝']='炫蓝之森:BAAALgADCgEJAQAAAA==.',
['熊了']='熊了个猫:BAAALgAECgYJBgAAAA==.',
['熊喵']='熊喵呜王:BAAALgAECgEJAQABLgAFFAIJBwAEAGYmAA==.',
['爱如']='爱如潮水:BAAALgAECgYJBgAAAA==.',
['牧濑']='牧濑红莉栖:BAAALgAECgEJAgAAAA==.',
['狼六']='狼六爷:BAAALgADCgUJBQAAAA==.',
['猩红']='猩红王子:BAAALgAECgMJAwAAAA==.',
['猪崽']='猪崽儿:BAAALgAECgYJBgAAAA==.',
['王富']='王富贵丶:BAAALgAECgYJCAAAAA==.',
['王思']='王思聪:BAABLgAECn8VAAIBAAgJ0Q8PYADEAQABAAgJ0Q8PYADEAQAAAA==.',
['玛琪']='玛琪果果:BAAALgAECgEJAgAAAA==.',
['生掘']='生掘坊主:BAAALgAECgYJAQAAAA==.',
['生生']='生生不息:BAAALgAECgYJCwAAAA==.',
['男技']='男技师:BAAALgAECgMJAwAAAA==.',
['福蕾']='福蕾雅:BAAALgADCgEJAQAAAA==.',
['笨笨']='笨笨荣儿:BAAALgAECgUJBQAAAA==.',
['筱樱']='筱樱:BAAALgAECgcJEQAAAA==.',
['粉条']='粉条昭昭:BAAALgAECgEJAQAAAA==.粉条眠眠:BAAALgADCgUJBQAAAA==.',
['糖水']='糖水绿洲:BAABLgAECn8eAAMVAAgJVhLqMACbAQAVAAcJFBPqMACbAQAEAAUJ5xy2PwCBAQAAAA==.',
['紧那']='紧那罗王:BAAALgADCggJDAAAAA==.',
['绯夜']='绯夜苍穹:BAAALgAECgkJCwABLgAECgkJFwALANEcAA==.',
['绯红']='绯红玫瑰:BAAALgAECgMJAwAAAA==.',
['维生']='维生素片:BAAALgAECgQJCgAAAA==.',
['缘浅']='缘浅缘深:BAAALgAECgQJCQAAAA==.',
['老叁']='老叁老肆:BAAALgAFFAEJAQAAAA==.',
['肥嘟']='肥嘟嘟右门卫:BAAALgADCgYJCQAAAA==.',
['膝盖']='膝盖忒想中箭:BAAALgAECgUJBgAAAA==.',
['舍得']='舍得分手:BAAALgAECgcJDAAAAA==.',
['色系']='色系:BAAALgAECgUJBQAAAA==.',
['花落']='花落莫相离:BAAALgAECgcJBAAAAA==.',
['苍山']='苍山如海:BAAALgAECgcJBwABLgAFFAYJBwAOAGYTAA==.',
['苍穹']='苍穹之光:BAAALgAECgYJCQAAAA==.',
['苹果']='苹果小笨:BAAALgAECgUJAwAAAA==.苹果牛:BAAALgAECgMJAwAAAA==.',
['落叶']='落叶晨魂:BAAALgADCgUJBQAAAA==.落叶邪魅:BAAALgAECgEJAQAAAA==.',
['蒜苗']='蒜苗:BAABLgAECn8nAAIEAAgJtR1qBwD8AQAEAAgJtR1qBwD8AQAAAA==.',
['蟹子']='蟹子大坏蛋:BAAALgADCgEJAQAAAA==.',
['血沸']='血沸:BAAALgAECgQJBAAAAA==.',
['西门']='西门冰修:BAAALgAECgEJAQAAAA==.',
['读条']='读条三十秒:BAABLgAECn8dAAIFAAYJSiUzOACUAgAFAAYJSiUzOACUAgAAAA==.',
['越獄']='越獄:BAAALgAECgQJBgAAAA==.',
['逞风']='逞风隐:BAABLgAECn8bAAIUAAgJahxIDwClAgAUAAgJahxIDwClAgAAAA==.',
['逸柔']='逸柔:BAAALgAECgIJAgAAAA==.',
['道友']='道友蹦两步:BAAALgAECgEJAQAAAA==.',
['醉丶']='醉丶酒仙:BAAALgADCgEJAQAAAA==.',
['重铸']='重铸的王小明:BAAALgAECgEJAQAAAA==.',
['门杠']='门杠清一色:BAAALgAECgYJBwABLgAFFAcJCgAFAO4cAA==.',
['阿尔']='阿尔赛利娅:BAAALgAECgYJBgAAAA==.',
['陌上']='陌上丶猫児:BAAALgAECgYJDwAAAA==.',
['除惡']='除惡務盡:BAAALgAECgYJCQAAAA==.',
['雷尼']='雷尼:BAAALgAECgEJAQAAAA==.',
['霹雳']='霹雳:BAAALgAECgQJBQAAAA==.',
['飘雪']='飘雪无痕:BAAALgAFFAEJAQAAAA==.',
['首席']='首席魔法丨师:BAAALgAECgEJAQAAAA==.',
['马修']='马修:BAAALgAFFAIJBAAAAA==.',
['鱼兹']='鱼兹多姆:BAAALgAECgkJEgAAAA==.',
['鱼利']='鱼利丹:BAABLgAECn8aAAMOAAcJjCMAHACqAgAOAAcJjCMAHACqAgAHAAYJBhPCMABLAQAAAA==.',
['鴨扂']='鴨扂葒簰:BAAALgAECgUJCQAAAA==.',
['黃飛']='黃飛鴻:BAAALgADCgEJAQAAAA==.',
['鼠鼠']='鼠鼠:BAAALgADCgEJAQAAAA==.',
['龙之']='龙之楚天:BAAALgAECgkJDgAAAA==.龙之炎:BAAALgAECgMJAwAAAA==.',
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
