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

local lookup = {'Mage-Frost','Unknown-Unknown','Shaman-Elemental','Monk-Brewmaster','Warrior-Fury','Warrior-Arms','Druid-Any','Druid-Balance','Shaman-Restoration','Warrior-Protection','Rogue-Subtlety','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Monk-Mistweaver','Shaman-Enhancement','DemonHunter-Havoc','Priest-Discipline','Priest-Holy','Priest-Shadow','Warlock-Demonology','Paladin-Protection','Evoker-Augmentation','DemonHunter-Devourer','Monk-Windwalker','DeathKnight-Unholy','DemonHunter-Vengeance',}
local provider = {region='CN',realm='伊萨里奥斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alxx:BAAALgAECgYJCAAAAA==.',
Ci='Cityhunter:BAAALgAECgMJAwAAAA==.',
Da='Dantsty:BAAALgAFFAEJAQABLgAFFAcJBQABANIGAA==.',
De='Demhon:BAAALgADCgEJAQAAAA==.Demonfire:BAAALgAECgEJAQAAAA==.',
Di='Diablic:BAAALgAECgQJBAAAAA==.',
Do='Doingyang:BAAALgAECgcJDgAAAA==.',
El='Elza:BAAALgADCgUJBQAAAA==.',
Fl='Flamered:BAAALgAECgQJDAAAAA==.',
Gu='Guilia:BAAALgAECgUJCQAAAA==.',
Hc='Hcavalier:BAAALgAECgIJAgAAAA==.',
He='Hellomrcxy:BAAALgAECgQJBAABLgAFFAEJAgACAAAAAA==.',
Ho='Holypeanut:BAAALgADCgcJBwAAAA==.',
Hu='Humble:BAAALgAECgEJAgAAAA==.',
Ja='Jayden:BAAALgAECgIJAgAAAA==.',
Ji='Jieshi:BAAALgAECgYJCwAAAA==.',
Jo='Joyjoy:BAAALgAECgcJBwAAAA==.',
Lo='Lokiodin:BAAALgADCgcJBwAAAA==.',
Mo='Moonkoir:BAAALgAECgcJCQAAAA==.',
My='Mydes:BAAALgAFFAIJAgAAAA==.',
Re='Rearso:BAAALgAECgkJCQABLgAFFAQJBAACAAAAAA==.',
Sd='Sdfsgfsf:BAAALgAECgYJDQAAAA==.',
So='Soiree:BAAALgAECgcJBwAAAA==.',
Sq='Squid:BAAALgAECgkJCQAAAA==.',
Ss='Ssriverns:BAAALgAECgkJEgABLgAFFAYJFgADAMUZAA==.',
St='Stellan:BAAALgAECgEJAQAAAA==.',
Su='Suanily:BAAALgAECgEJAgAAAA==.',
Ti='Timetodie:BAAALgAECgcJDgAAAA==.Timetogo:BAAALgAFFAEJAQAAAA==.Timetogongfu:BAABLgAFFH8OAAIEAAQJMwlhDwAIAQAEAAQJMwlhDwAIAQAAAA==.Timetolight:BAAALgAECgYJBwAAAA==.Timetoshot:BAAALgAECgEJAQAAAA==.',
Tr='Trinidy:BAAALgAECgQJBAAAAA==.',
Wn='Wnbanyama:BAAALgAECgMJAwAAAA==.',
Wq='Wqwes:BAAALgAFFAIJAgAAAA==.',
Xi='Xiaoxiaobdk:BAAALgAECgcJEgAAAA==.',
Yu='Yukirito:BAABLgAECn8bAAMFAAcJ+R3SGwBuAgAFAAcJNxzSGwBuAgAGAAEJHxiMOQBKAAAAAA==.',
['一副']='一副魈熊样:BAABLgAFFH8FAAIHAAUJZRoAAAAAAAAIAAUJZRoAAAAAAAAAAA==.',
['一米']='一米八:BAAALgAFFAIJAgAAAA==.',
['七星']='七星灯丶:BAAALgAECgQJBQAAAA==.',
['七相']='七相大宗师:BAAALgADCgUJBQABLgAECgYJBwACAAAAAA==.',
['下次']='下次我请:BAAALgADCgQJAQAAAA==.',
['不安']='不安的虫虫:BAAALgAECgMJAwAAAA==.',
['不小']='不小破:BAAALgAECgcJEAAAAA==.',
['不知']='不知强不强力:BAABLgAECn8WAAIJAAcJvSYGBQAhAwAJAAcJvSYGBQAhAwABLgAFFAQJBAACAAAAAA==.',
['不良']='不良懵智:BAAALgADCgYJBgAAAA==.不良教父:BAACLgAFFH8QAAIKAAUJhx4cAwBnAQAKAAUJhx4cAwBnAQAuAAQKfxUAAgoABwl8G/QQAPkBAAoABwl8G/QQAPkBAAAA.不良武僧:BAAALgAFFAIJAgAAAA==.',
['不要']='不要战猎萨啦:BAACLgAFFH8JAAIJAAMJWhmQFwCdAAAJAAMJWhmQFwCdAAAuAAQKfyEAAwkABwmuINoTAHYCAAkABwmuINoTAHYCAAMAAgkhD9t6AFgAAAAA.',
['丛林']='丛林舞者:BAAALgAECgYJBgAAAA==.',
['东方']='东方红拖拉机:BAAALgAECgQJBAAAAA==.东方红推土机:BAAALgAECgYJCQAAAA==.',
['丨汞']='丨汞丨:BAABLgAECn8VAAILAAgJphE0HgALAgALAAgJphE0HgALAgAAAA==.',
['丶空']='丶空:BAAALgAECgYJDQAAAA==.',
['丶黑']='丶黑:BAABLgAECn8UAAMMAAYJUBQmYgBBAQAMAAUJxhQmYgBBAQANAAYJmgfmUgAAAQAAAA==.',
['丸子']='丸子跳跳:BAAALgAECgMJAwAAAA==.',
['举手']='举手示清白:BAABLgAFFH8LAAMMAAQJeB1zBwArAQANAAQJcxQXDgBDAQAMAAMJchtzBwArAQAAAA==.',
['之后']='之后以后:BAEALgAFFAIJBAAAAA==.',
['九大']='九大王:BAAALgAECgYJDQAAAA==.',
['九色']='九色煞:BAAALgAECgEJAQAAAA==.',
['九莲']='九莲灯:BAAALgAECgYJBgAAAA==.',
['云韵']='云韵:BAAALgAFFAEJAQAAAA==.',
['人矮']='人矮心眼小:BAAALgAECgcJBwAAAA==.',
['伊布']='伊布:BAAALgAFFAEJAQAAAA==.',
['传统']='传统五子棋:BAAALgAECgYJDAAAAA==.',
['伯瓦']='伯瓦爾公爵:BAAALgAECggJDQAAAA==.',
['你随']='你随意我无敌:BAAALgAFFAIJBAAAAA==.',
['依梦']='依梦由天:BAAALgAECgEJAgAAAA==.',
['停止']='停止吃药:BAAALgAECgcJEQAAAA==.',
['光降']='光降雪飘:BAAALgADCgcJBwAAAA==.',
['克劳']='克劳迪乌斯:BAAALgADCgYJBgAAAA==.',
['八倍']='八倍镜:BAACLgAFFH8FAAIOAAMJGRQlFAAHAQAOAAMJGRQlFAAHAQAuAAQKfxsAAg4ABwlwH7wuAGgCAA4ABwlwH7wuAGgCAAAA.',
['公主']='公主必死:BAAALgAECgEJAgAAAA==.',
['公子']='公子素:BAAALgAECgYJCQAAAA==.',
['兮凩']='兮凩:BAAALgADCgQJBQAAAA==.',
['冥界']='冥界看门人:BAAALgAECgEJAgAAAA==.',
['冰麒']='冰麒麟奶茶:BAAALgADCgUJBQAAAA==.',
['凋零']='凋零火:BAAALgADCgIJAgAAAA==.',
['医学']='医学家陈二迅:BAAALgAECgQJBAAAAA==.',
['南屏']='南屏丶晚钟:BAAALgADCgYJCAAAAA==.',
['南貓']='南貓露西艾拉:BAAALgAECgQJBAAAAA==.',
['卸武']='卸武:BAABLgAFFH8FAAIEAAUJLgnBCABIAQAEAAUJLgnBCABIAQAAAA==.',
['厉倾']='厉倾城:BAAALgAECgUJBQAAAA==.',
['又白']='又白又粉:BAAALgAFFAMJBAAAAA==.',
['友戎']='友戎:BAAALgAECgEJAQAAAA==.',
['双曜']='双曜冰璃:BAABLgAFFH8FAAIBAAIJ+Q+yHACkAAABAAIJ+Q+yHACkAAAAAA==.',
['双面']='双面猫:BAACLgAFFH8LAAILAAQJ2x1LBgB7AQALAAQJ2x1LBgB7AQAuAAQKfxcAAgsABwleJIUMANACAAsABwleJIUMANACAAAA.',
['只嗳']='只嗳傻傻的:BAAALgAECgUJAQAAAA==.',
['叫我']='叫我啊乃:BAAALgAECgEJAgAAAA==.',
['可爱']='可爱的咿利丹:BAAALgAECgEJAQAAAA==.可爱的帕拉丁:BAAALgAECgUJBQAAAA==.可爱的恶魔:BAAALgAECgYJCAAAAA==.可爱的毛毛:BAAALgAECgIJAgAAAA==.',
['名字']='名字真难想:BAAALgADCgEJAQAAAA==.',
['告辞']='告辞:BAAALgAECgcJDQABLgAFFAUJAgACAAAAAA==.',
['咀嚼']='咀嚼片:BAAALgAECggJDgAAAA==.',
['和风']='和风之弦:BAAALgAECgcJBAAAAA==.',
['哇啊']='哇啊有鬼:BAAALgAECgEJAgAAAA==.',
['哔哩']='哔哩哔哩:BAAALgAECgkJCQAAAA==.',
['唤星']='唤星者米娅:BAAALgAECgQJBAAAAA==.',
['四公']='四公主:BAABLgAECn8ZAAMMAAgJ5BF8MwDhAQAMAAcJ7hN8MwDhAQANAAQJuAdyYwCyAAAAAA==.',
['回头']='回头無岸:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光小木锤:BAAALgAECgUJBwAAAA==.',
['堕落']='堕落猫猫:BAABLgAECn8aAAIBAAgJrR67KADQAgABAAgJrR67KADQAgAAAA==.',
['夜影']='夜影溯風:BAAALgAFFAEJAgAAAA==.',
['夜猎']='夜猎潘:BAABLgAFFH8MAAINAAQJyxseDABZAQANAAQJyxseDABZAQAAAA==.',
['夜的']='夜的梦想:BAAALgAECgcJBwAAAA==.',
['夜髌']='夜髌:BAAALgADCgIJAgAAAA==.',
['大宇']='大宇宙:BAAALgAECgkJCQABLgAFFAYJAwACAAAAAA==.',
['大领']='大领主棒子:BAAALgAFFAEJAQAAAA==.',
['天道']='天道丷总司:BAAALgAECgQJBAAAAA==.天道总司丷法:BAAALgAECgYJCQAAAA==.',
['奕德']='奕德:BAABLgAECn8fAAIPAAgJDxfbGQDtAQAPAAgJDxfbGQDtAQAAAA==.',
['妃红']='妃红女凰:BAAALgAECgMJAwAAAA==.',
['妇科']='妇科主任:BAAALgAECgYJCgAAAA==.',
['妈祖']='妈祖:BAAALgAFFAIJAwAAAA==.',
['妖哥']='妖哥哥的那个:BAABLgAECn8VAAMQAAcJLQ8yEgCTAQAQAAcJLQ8yEgCTAQADAAMJNQhtHwBlAAAAAA==.',
['孙桂']='孙桂芬:BAAALgAECgIJAgAAAA==.',
['安文']='安文五号机:BAAALgAFFAQJBAABLgAFFAUJBQARAP4TAA==.',
['寒星']='寒星:BAAALgADCgQJAgAAAA==.',
['射到']='射到冇晒符:BAAALgAECgYJBgAAAA==.',
['射射']='射射死你:BAAALgAFFAIJAgAAAA==.',
['小兵']='小兵传奇会长:BAAALgAECgMJAwAAAA==.',
['小法']='小法爱大米:BAAALgAECgEJAQAAAA==.',
['小狗']='小狗快跑:BAAALgAFFAEJAQAAAA==.',
['少侠']='少侠跑慢点:BAAALgAFFAEJAQAAAA==.',
['尔等']='尔等凡人:BAAALgAECgcJBwAAAA==.',
['尛尛']='尛尛周:BAAALgADCgEJAQAAAA==.尛尛园:BAAALgAECgEJAwAAAA==.',
['布鲁']='布鲁斯壳:BAAALgAECgkJEgABLgAFFAQJBAACAAAAAA==.',
['帅气']='帅气唐哒哒:BAABLgAFFH8HAAIBAAMJSxKrNgC9AAABAAMJSxKrNgC9AAAAAA==.',
['幽灵']='幽灵公主:BAABLgAECn8VAAIRAAYJkxo4GwDoAQARAAYJkxo4GwDoAQAAAA==.',
['弗塔']='弗塔根:BAAALgADCgEJAgAAAA==.',
['很菜']='很菜的人:BAAALgAECgcJDAAAAA==.',
['恐怖']='恐怖沉默:BAAALgAECgMJAwAAAA==.',
['愤怒']='愤怒的杏鲍菇:BAAALgAECgkJEAAAAA==.',
['慌的']='慌的一批:BAAALgADCgcJBwAAAA==.',
['我不']='我不是萌萌:BAAALgAECgEJAwAAAA==.',
['我是']='我是个卧底:BAAALgADCgUJBQAAAA==.',
['戴娜']='戴娜碧桑:BAAALgAECgYJCgAAAA==.',
['折翼']='折翼灬天使:BAAALgAECgcJEwAAAA==.',
['拽根']='拽根:BAAALgADCgQJBAAAAA==.',
['揺滚']='揺滚:BAAALgADCgUJBQAAAA==.',
['攒劲']='攒劲的小节目:BAAALgADCgYJBgAAAA==.',
['放弃']='放弃治疗:BAACLgAFFH8PAAMSAAQJxiZjAwDIAQASAAQJHCZjAwDIAQATAAMJ9CZsAwBeAQAuAAQKfx0ABBMABwnYJtcDABoDABMABwnYJtcDABoDABIABwlKJngEABQDABQAAQkSFAAAAAAAAAAA.',
['敷衍']='敷衍堕落的伢:BAAALgADCgMJAwAAAA==.敷衍堕落的心:BAAALgAECgYJBgAAAA==.',
['旅行']='旅行者丽丽:BAAALgAECgEJAQAAAA==.',
['无捷']='无捷:BAAALgAECgIJBAAAAA==.',
['时之']='时之主雷斯林:BAAALgAECgYJCAAAAA==.',
['星之']='星之卡车:BAAALgAFFAEJAQAAAA==.',
['星痕']='星痕翼:BAAALgAECgYJCgAAAA==.',
['春是']='春是叫出来的:BAAALgAECgEJAQAAAA==.',
['晨雨']='晨雨初听:BAAALgAECgYJCgAAAA==.',
['暴法']='暴法:BAABLgAFFH8EAAIVAAMJlgtQEgDaAAAVAAMJlgtQEgDaAAAAAA==.',
['月光']='月光池猎:BAAALgAECgMJBAAAAA==.',
['月满']='月满拦江:BAAALgAECgMJBAAAAA==.',
['有尾']='有尾巴的人:BAAALgAECggJCAAAAA==.',
['未知']='未知:BAAALgAECgMJBAAAAA==.',
['杨戬']='杨戬:BAAALgAECgQJBAAAAA==.',
['枯枼']='枯枼随風:BAACLgAFFH8GAAIBAAMJTw0zPACzAAABAAMJTw0zPACzAAAuAAQKfyAAAgEABwnoIB00AKICAAEABwnoIB00AKICAAAA.',
['柠萌']='柠萌檬:BAAALgAECgYJEgAAAA==.',
['格格']='格格牧:BAAALgAECgMJBAAAAA==.',
['桀骜']='桀骜斯达瑞:BAACLgAFFH8HAAIFAAMJzhyHDwAOAQAFAAMJzhyHDwAOAQAuAAQKfxMAAgUABwlVHUceAF0CAAUABwlVHUceAF0CAAEuAAUUBgkSAAUAMSMA.',
['桃羞']='桃羞杏让:BAACLgAFFH8OAAIWAAQJWA/jAQACAQAWAAQJWA/jAQACAQAuAAQKfxkAAhYABwniEnkaADsBABYABwniEnkaADsBAAAA.',
['桜吹']='桜吹雪:BAAALgAECgYJDAAAAA==.',
['桶木']='桶木饭长胡子:BAAALgAECgYJBgAAAA==.',
['森宫']='森宫苍乃:BAAALgAECgEJAgAAAA==.',
['楼外']='楼外青楼:BAAALgAFFAIJAgAAAA==.',
['欧皇']='欧皇爸爸:BAAALgAECgQJBgAAAA==.',
['正经']='正经猎人:BAAALgAECgMJAwAAAA==.',
['歧路']='歧路安在:BAAALgADCgcJBwAAAA==.',
['歺狼']='歺狼氚説:BAACLgAFFH8FAAILAAMJyAt/FQCjAAALAAMJyAt/FQCjAAAuAAQKfxoAAgsABwmIF8wKACcBAAsABwmIF8wKACcBAAAA.',
['死骑']='死骑的信仰:BAAALgAFFAQJBAAAAA==.',
['残阳']='残阳破碎:BAAALgAECgcJCAAAAA==.',
['毛人']='毛人男贾:BAAALgAECgYJBgAAAA==.',
['永无']='永无止境的夜:BAAALgAECgEJAgAAAA==.',
['汢杜']='汢杜:BAACLgAFFH8QAAIPAAUJ+h0RAwDOAQAPAAUJ+h0RAwDOAQAuAAQKfxYAAg8ABwn8I4kLAJoCAA8ABwn8I4kLAJoCAAAA.',
['没得']='没得意思:BAAALgAFFAIJAgABLgAFFAQJBwAXAP8cAA==.',
['没有']='没有密码猎手:BAAALgAECgQJBgAAAA==.',
['沫沫']='沫沫哒:BAAALgAECgYJDQAAAA==.沫沫茶:BAAALgAECgYJCQAAAA==.',
['油爆']='油爆鹌鹑:BAABLgAFFH8IAAIIAAMJ8AjPBgDgAAAIAAMJ8AjPBgDgAAAAAA==.',
['法力']='法力残渣:BAAALgAFFAMJBAAAAA==.',
['泛泛']='泛泛:BAAALgAECgYJCgAAAA==.',
['泰森']='泰森:BAAALgAFFAIJAgAAAA==.',
['洁最']='洁最美:BAAALgAECgcJCQAAAA==.',
['洅洄']='洅洄獸:BAAALgAECgEJAQAAAA==.',
['流年']='流年厶浮生:BAAALgAECgQJBAAAAA==.',
['浑身']='浑身肉乎乎:BAAALgADCgUJBQAAAA==.',
['游离']='游离:BAAALgAECgUJBQAAAA==.',
['游龍']='游龍:BAAALgAFFAUJBAAAAA==.',
['火火']='火火恍恍:BAAALgAFFAIJBAAAAA==.',
['灬芙']='灬芙兰彡:BAAALgAECgkJEAAAAA==.',
['灬蒂']='灬蒂剋灬:BAAALgAECgMJAwAAAA==.',
['烈焰']='烈焰审判:BAAALgAECgYJBgAAAA==.',
['熊熊']='熊熊我啊:BAAALgADCggJDQAAAA==.',
['爱蓝']='爱蓝莓酱辰辰:BAAALgAFFAMJAwAAAA==.',
['牛肉']='牛肉面丶:BAAALgAECgEJAQAAAA==.',
['牛魔']='牛魔亡:BAAALgAECgcJDwAAAA==.',
['特雷']='特雷丝汀:BAAALgAECgYJCwAAAA==.',
['狂魔']='狂魔之圣:BAAALgADCgEJAQAAAA==.',
['猎影']='猎影怒风:BAAALgAECgYJEwAAAA==.',
['猫南']='猫南北:BAABLgAFFH8FAAIYAAIJ5yGqIQDDAAAYAAIJ5yGqIQDDAAAAAA==.',
['玉爪']='玉爪:BAAALgAECgMJAwAAAA==.',
['王缇']='王缇:BAAALgAECgYJCgAAAA==.',
['玫瑰']='玫瑰异探:BAAALgAECgcJBwABLgAFFAEJAQACAAAAAA==.',
['瑶琴']='瑶琴一曲:BAAALgAECgcJDgAAAA==.',
['甜甜']='甜甜圈:BAABLgAFFH8LAAIBAAQJ1xobDwAWAQABAAQJ1xobDwAWAQAAAA==.',
['皮皮']='皮皮圣光盾:BAAALgAFFAEJAQAAAA==.皮皮水灵灵:BAAALgAECgcJCQAAAA==.',
['真是']='真是闹麻了:BAAALgAFFAEJAQAAAA==.',
['禾火']='禾火:BAAALgADCgMJAwAAAA==.',
['秋末']='秋末:BAAALgAECgMJBAAAAA==.',
['秋水']='秋水一寒:BAAALgAECgEJAQAAAA==.',
['章小']='章小三:BAAALgAECgYJCAAAAA==.章小山:BAAALgAECgYJBgAAAA==.',
['笑剑']='笑剑钝:BAAALgAECgUJBgAAAA==.',
['答案']='答案:BAAALgADCgEJAQAAAA==.',
['糯米']='糯米多排骨:BAAALgAECgcJBwAAAA==.',
['索利']='索利达尔:BAAALgAECgEJAgAAAA==.',
['索拉']='索拉卡法戒:BAAALgAECgYJCAAAAA==.',
['繁花']='繁花乍现:BAABLgAFFH8LAAISAAYJeR+tAgDnAQASAAYJeR+tAgDnAQAAAA==.',
['终焉']='终焉梦魇:BAAALgADCgcJCwAAAA==.',
['维克']='维克顿:BAAALgADCgEJAQAAAA==.',
['绿旋']='绿旋风:BAAALgAECgIJAgAAAA==.',
['绿色']='绿色保护你:BAAALgAECgMJAwAAAA==.',
['羁绊']='羁绊半伴:BAAALgAECgYJBgAAAA==.',
['羽依']='羽依:BAAALgAECgEJAQAAAA==.',
['羽沐']='羽沐:BAAALgAECgYJCwAAAA==.',
['肃杀']='肃杀小小:BAABLgAECn8bAAMZAAcJ1BwIFwAuAgAZAAcJ1BwIFwAuAgAEAAIJiAfdfgBMAAAAAA==.',
['胡子']='胡子七佛:BAAALgADCgMJBAAAAA==.',
['腿短']='腿短毛长:BAAALgAECgQJBwAAAA==.',
['致命']='致命诅咒:BAAALgAECgIJAwAAAA==.',
['舞蝶']='舞蝶之殇:BAAALgAECgUJBQAAAA==.',
['艾格']='艾格希尔:BAAALgAECggJCAAAAA==.',
['花月']='花月正春风:BAACLgAFFH8PAAIaAAQJ5RuxEQBaAQAaAAQJ5RuxEQBaAQAuAAQKfxQAAhoABwnSIFUwAHcCABoABwnSIFUwAHcCAAAA.',
['花间']='花间风雅:BAAALgAECgIJAgAAAA==.',
['英崽']='英崽子:BAAALgAECgEJAQAAAA==.',
['草莓']='草莓二:BAAALgAECgQJBwAAAA==.草莓战:BAAALgAECgYJAQAAAA==.草莓术:BAAALgAECgYJCgAAAA==.',
['荣耀']='荣耀埋葬:BAABLgAECn8UAAIYAAYJYxCtdABHAQAYAAYJYxCtdABHAQAAAA==.',
['莎娜']='莎娜希斯:BAAALgADCgEJAQAAAA==.',
['菊花']='菊花嘲弄者:BAAALgAECgYJBgAAAA==.',
['菜丫']='菜丫:BAAALgAECgYJDAABLgAECgkJCQACAAAAAA==.',
['落叶']='落叶飘扬:BAAALgAECgkJCgAAAA==.',
['蕾丝']='蕾丝灬花边:BAAALgADCgEJAQAAAA==.',
['薛丁']='薛丁格的猫:BAAALgAECgYJBwAAAA==.',
['薛宝']='薛宝琴:BAAALgAECgUJBQAAAA==.',
['血刃']='血刃潘:BAAALgAFFAMJBAAAAA==.',
['血色']='血色训犬师:BAAALgAECgIJAgAAAA==.',
['行行']='行行丶:BAAALgAECgYJDgAAAA==.',
['触摸']='触摸阳光:BAAALgAECgYJBwAAAA==.',
['请先']='请先追我队友:BAAALgADCgUJBQAAAA==.',
['貓貓']='貓貓不是喵:BAAALgADCgEJAQAAAA==.',
['费亚']='费亚尔:BAAALgADCgEJAQAAAA==.',
['超大']='超大豆芽菜:BAAALgAECgcJAQAAAA==.',
['超级']='超级丶玛丽:BAAALgAECgIJAgAAAA==.',
['辉煌']='辉煌骑士:BAAALgAECgEJAQAAAA==.',
['迅捷']='迅捷的阿昆达:BAAALgAECggJEwAAAA==.',
['还是']='还是那个棍子:BAAALgADCgYJBgAAAA==.',
['那个']='那个小德:BAAALgADCgEJAQAAAA==.那个战室:BAABLgAECn8eAAIbAAcJzyPvAgC7AgAbAAcJzyPvAgC7AgAAAA==.',
['铁胆']='铁胆翻车侠:BAAALgAECgkJDgAAAA==.',
['闻人']='闻人绮雪:BAAALgADCgMJAwAAAA==.',
['阿尔']='阿尔卡卡:BAAALgAECgEJAQAAAA==.阿尔卡帝雅:BAAALgAECgIJAgAAAA==.',
['陨落']='陨落的双面猫:BAAALgAECgYJCQAAAA==.',
['雙雙']='雙雙:BAAALgADCgUJBQAAAA==.',
['雨夜']='雨夜丄风:BAAALgAECggJDAAAAA==.雨夜带刀不带:BAAALgAECgkJCgAAAA==.',
['霍恩']='霍恩海姆:BAAALgAECgIJAgAAAA==.霍恩莉亚:BAACLgAFFH8IAAIMAAMJaR4KDgDlAAAMAAMJaR4KDgDlAAAuAAQKfxwAAwwACAlZJHgIAAoDAAwABwl3JXgIAAoDAA0ABQnOFhdHADcBAAAA.',
['霸气']='霸气雄图:BAAALgAECgYJAwAAAA==.',
['青莲']='青莲神尼:BAAALgADCgEJAQAAAA==.',
['静默']='静默火花:BAAALgAECgEJAQAAAA==.',
['风之']='风之灵泣:BAAALgAECgcJDQAAAA==.',
['风刺']='风刺刃:BAAALgAECgQJBAAAAA==.',
['风过']='风过流殇:BAAALgAECgMJAwAAAA==.',
['飒拉']='飒拉塔斯丶:BAAALgADCgEJAQAAAA==.',
['飞鸟']='飞鸟入怀:BAAALgAECgEJAQAAAA==.',
['食不']='食不食油饼:BAAALgAECgEJAQAAAA==.',
['饭木']='饭木桶蒸桑拿:BAAALgAFFAEJAQAAAA==.',
['香椿']='香椿头:BAAALgAECgcJEgAAAA==.',
['马宝']='马宝宝:BAAALgAECgEJAQAAAA==.',
['高少']='高少三:BAAALgAECgQJBAAAAA==.',
['魄断']='魄断:BAAALgAECggJCQAAAA==.',
['鸽子']='鸽子菇菇叫:BAACLgAFFH8GAAIOAAMJqiHyGADiAAAOAAMJqiHyGADiAAAuAAQKfyQAAg4ABwmDJQYVAOwCAA4ABwmDJQYVAOwCAAAA.',
['黄昏']='黄昏之时:BAABLgAFFH8GAAIOAAQJahuTGgDLAAAOAAQJahuTGgDLAAAAAA==.',
['龙行']='龙行天下武:BAAALgAECgQJBwAAAA==.',
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
