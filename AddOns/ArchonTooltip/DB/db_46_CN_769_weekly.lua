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

local lookup = {'Paladin-Retribution','DemonHunter-Havoc','DemonHunter-Devourer','Shaman-Elemental','Shaman-Restoration','DeathKnight-Unholy','Evoker-Preservation','Evoker-Augmentation','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Warlock-Demonology','Druid-Restoration','Druid-Balance','Unknown-Unknown','Warrior-Fury','Monk-Mistweaver','Warlock-Destruction','Paladin-Holy','Warrior-Protection','Shaman-Enhancement','Priest-Discipline','Priest-Shadow','Priest-Holy','Warlock-Affliction','DemonHunter-Vengeance',}
local provider = {region='CN',realm='生态船',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Angrysj:BAAALgAECgcJDgAAAA==.',
At='Atyourside:BAACLgAFFH8MAAIBAAQJ4xF2CwBQAQABAAQJ4xF2CwBQAQAuAAQKfxYAAgEACAlmIOEZAM4CAAEACAlmIOEZAM4CAAAA.',
Ba='Barnettll:BAAALgAECgcJBwAAAA==.',
De='Defeat:BAAALgADCgIJAgAAAA==.',
Do='Downpour:BAAALgAECgYJBwAAAA==.',
Fo='Fortheallian:BAAALgAECgEJAgAAAA==.',
Gl='Gloriatang:BAAALgAECgYJCAAAAA==.',
Im='Imperiusa:BAAALgAFFAIJAgAAAA==.',
Mi='Mineras:BAAALgAECgMJAwAAAA==.',
On='Onne:BAAALgAECgEJAQAAAA==.',
Pl='Playerimvlzq:BAAALgAECgYJBgAAAA==.',
Qi='Qirry:BAAALgAFFAEJAgAAAA==.',
Va='Vanitylost:BAAALgADCgUJBQAAAA==.',
Ve='Vectorchange:BAABLgAECn8aAAMCAAcJMBiHGAACAgACAAcJMBiHGAACAgADAAEJOgNm7wAjAAAAAA==.',
Vi='Vitality:BAAALgAECgIJAgAAAA==.',
Wo='Workhard:BAAALgADCgQJBAAAAA==.',
Zi='Zimomo:BAAALgAFFAEJAgAAAA==.',
['一坨']='一坨超人:BAAALgADCgIJAgAAAA==.',
['一片']='一片情天:BAAALgAECgUJBQAAAA==.',
['不中']='不中嘞:BAABLgAFFH8NAAMEAAUJbgz+BQB7AQAEAAUJbgz+BQB7AQAFAAQJWx/wBQBqAQAAAA==.',
['不吃']='不吃香菇丶:BAAALgAECgYJBgAAAA==.',
['东凸']='东凸西凹:BAAALgAECgcJAgAAAA==.',
['临时']='临时工丶:BAAALgAECgUJCAAAAA==.临时抱佛脚:BAAALgAECgUJBQAAAA==.',
['丶夜']='丶夜凉如水:BAAALgAECgMJAwAAAA==.',
['丿灬']='丿灬蕝版妖嘼:BAAALgAECgkJCQAAAA==.',
['云彩']='云彩儿:BAAALgAFFAIJAwAAAA==.',
['云水']='云水游:BAAALgAECgEJAQAAAA==.',
['五河']='五河琴里丶:BAAALgAFFAEJAQAAAA==.',
['人参']='人参公坤:BAABLgAFFH8KAAIGAAQJeB7YBQBfAQAGAAQJeB7YBQBfAQAAAA==.',
['人老']='人老手残玩贼:BAAALgAECgYJBgAAAA==.',
['仁展']='仁展老板:BAAALgADCgYJBgAAAA==.',
['仅有']='仅有的姿态:BAAALgAECgQJBAAAAA==.',
['伊瑞']='伊瑞安娜:BAABLgAECn8cAAMHAAgJNhm0GADMAQAHAAgJNhm0GADMAQAIAAEJ3hZ+YgAyAAAAAA==.',
['你被']='你被牛打过:BAAALgAFFAQJBAAAAA==.',
['修罗']='修罗神斩:BAAALgAECgEJAQAAAA==.',
['偷偷']='偷偷喝汽水:BAAALgAFFAEJAQAAAA==.',
['八二']='八二年的辣条:BAAALgAFFAIJAgAAAA==.',
['关谷']='关谷神奇丶:BAAALgAECgMJAgAAAA==.',
['冰凛']='冰凛暗月:BAAALgAECgYJBgAAAA==.',
['冰镇']='冰镇蜂蜜:BAACLgAFFH8VAAMJAAUJViM+AQCWAQAJAAUJViM+AQCWAQAKAAMJeRPCFQDtAAAuAAQKfyAAAwkACQkoI2YLAOgCAAkACAlfJGYLAOgCAAoABwmlHBAmAPUBAAAA.',
['千古']='千古魔尊:BAACLgAFFH8FAAILAAIJMwk5QwCpAAALAAIJMwk5QwCpAAAuAAQKfxUAAgsACAlfFXNdACICAAsACAlfFXNdACICAAAA.',
['南瓜']='南瓜二米粥:BAABLgAFFH8HAAIMAAQJXQ2ZFABHAQAMAAQJXQ2ZFABHAQAAAA==.',
['収鈊']='収鈊懩性:BAAALgADCgcJBwAAAA==.',
['叶灬']='叶灬傾云:BAAALgAECgQJBAAAAA==.',
['后街']='后街少女:BAAALgADCgEJAQAAAA==.',
['吥丢']='吥丢:BAAALgAECgcJBwAAAA==.',
['呆瓜']='呆瓜小贼:BAAALgADCgUJBQAAAA==.',
['哇袄']='哇袄:BAAALgAFFAQJAgABLgAFFAUJDgAEAJYiAA==.',
['嘤雄']='嘤雄:BAAALgADCgQJBAAAAA==.',
['四字']='四字哥哥:BAACLgAFFH8RAAMNAAUJbiMsAgCpAQANAAQJdiMsAgCpAQAOAAQJBR+KBgB7AQAuAAQKfy0AAw4ACAnrJXcDAHYDAA4ACAnrJXcDAHYDAA0ACAkRIUwBAAEDAAAA.',
['国足']='国足团团:BAAALgAECgYJCwAAAA==.',
['堕落']='堕落小小猪:BAAALgAECgcJCAAAAA==.',
['墨染']='墨染丶青衣颜:BAAALgAECgQJBAAAAA==.',
['墨生']='墨生:BAAALgAECgkJCgAAAA==.',
['夕阳']='夕阳舞步:BAAALgAECgMJBAAAAA==.',
['大宅']='大宅一子:BAAALgAECgcJBwABLgAFFAYJBAAPAAAAAA==.',
['大少']='大少奶奶:BAAALgAECgEJAQAAAA==.',
['奔波']='奔波尔蛋:BAAALgAECgIJAgAAAA==.',
['嫩嫩']='嫩嫩嘚:BAAALgAECgYJBgAAAA==.',
['安舒']='安舒雅:BAAALgADCgEJAQAAAA==.',
['寒冰']='寒冰丶骑士:BAAALgAFFAQJBAAAAA==.',
['小了']='小了兔了白:BAAALgADCgMJAwAAAA==.',
['小圆']='小圆只吃不圆:BAAALgAECgUJBQAAAA==.',
['小坏']='小坏蛋丶么:BAAALgAECgYJBgAAAA==.',
['小小']='小小丶骑:BAAALgADCgYJBgAAAA==.小小百合:BAAALgAECgkJDgAAAA==.小小的兔子:BAAALgAECgIJAwAAAA==.',
['小尛']='小尛鳄鱼:BAAALgAECgIJAgAAAA==.',
['小沛']='小沛沛十二号:BAAALgAECgQJBAAAAA==.',
['小脸']='小脸红扑扑丶:BAAALgAECgYJCQAAAA==.',
['小鱼']='小鱼很忙:BAAALgAECgcJBwAAAA==.',
['小鸡']='小鸡屠戮者:BAAALgAECgEJAQAAAA==.',
['小黄']='小黄油拿铁:BAAALgAECgkJCQAAAA==.',
['屁桃']='屁桃:BAAALgAECgYJBgAAAA==.',
['希厼']='希厼瓦纳斯:BAAALgAECgcJCAAAAA==.',
['幽冥']='幽冥鬼主:BAAALgAECgUJBwAAAA==.',
['库洛']='库洛艾:BAAALgAFFAEJAQAAAA==.',
['开始']='开始杀:BAAALgADCgIJAgAAAA==.',
['影幽']='影幽:BAAALgAECgMJAwAAAA==.',
['惠美']='惠美:BAAALgAECgEJAQAAAA==.',
['慧能']='慧能:BAAALgAECgUJCAAAAA==.',
['憨憨']='憨憨德:BAAALgADCgUJBQAAAA==.憨憨猎:BAAALgAECgUJBgAAAA==.',
['我会']='我会出手丶:BAAALgAECgEJAQAAAA==.',
['战嘤']='战嘤嘤:BAAALgAECgEJAQAAAA==.',
['招财']='招财进宝丿:BAABLgAECn8bAAIFAAcJmxdkNACyAQAFAAcJmxdkNACyAQAAAA==.',
['拼少']='拼少少:BAAALgAFFAIJAgAAAA==.',
['提刀']='提刀来见你:BAAALgADCgcJBwAAAA==.',
['摇光']='摇光:BAACLgAFFH8IAAMFAAQJCRo9BwBRAQAFAAQJCRo9BwBRAQAEAAQJ7QlUDAAoAQAuAAQKfxQAAgUABwmHFAI+AIkBAAUABwmHFAI+AIkBAAAA.',
['摩卡']='摩卡心冰乐:BAAALgADCgYJBgAAAA==.',
['摸鱼']='摸鱼大王:BAABLgAECn8VAAIQAAgJyhOrBgDZAQAQAAgJyhOrBgDZAQAAAA==.',
['撒蛮']='撒蛮:BAAALgAECgYJCQAAAA==.',
['文狗']='文狗:BAABLgAFFH8GAAIRAAQJ9BcFBgBtAQARAAQJ9BcFBgBtAQAAAA==.',
['斯嘉']='斯嘉丽叁号:BAAALgAECgYJAwAAAA==.',
['无路']='无路塞:BAAALgAECgUJBQAAAA==.',
['早蕨']='早蕨之舞:BAAALgAECgMJAwAAAA==.',
['明月']='明月姬:BAAALgAECgkJCQAAAA==.',
['晏一']='晏一:BAAALgAFFAQJAQAAAA==.',
['晏四']='晏四:BAAALgAFFAUJBAAAAA==.',
['暗夜']='暗夜灬:BAAALgAFFAIJAwAAAA==.',
['暗月']='暗月玫瑰刀:BAAALgAECgMJAwAAAA==.',
['曉濤']='曉濤:BAACLgAFFH8GAAINAAQJYAW3DgD8AAANAAQJYAW3DgD8AAAuAAQKfyUAAw0ACQl+Gs8GACcCAA0ACQl+Gs8GACcCAA4AAQlQGWJ2AEoAAAAA.',
['月贤']='月贤者:BAAALgAECgEJAwAAAA==.',
['木青']='木青:BAAALgAECgEJAgAAAA==.',
['本宫']='本宫本宫:BAAALgAECgIJAgAAAA==.',
['术十']='术十一郎:BAABLgAFFH8GAAMMAAUJTiGsCQBGAQAMAAQJuCOsCQBGAQASAAEJEBqPBABhAAABLgAFFAYJDwAMALsgAA==.',
['杨丶']='杨丶老湿:BAAALgAECgYJDgAAAA==.',
['枸杞']='枸杞加大枣:BAABLgAECn8UAAIGAAcJsBzjOwBIAgAGAAcJsBzjOwBIAgAAAA==.',
['桀驁']='桀驁小涛:BAABLgAECn8UAAITAAkJ1gbRNACpAQATAAkJ1gbRNACpAQABLgAFFAQJBgANAGAFAA==.',
['桃子']='桃子上的血:BAAALgAECgYJDAAAAA==.',
['桔子']='桔子苏打水:BAAALgAECgYJCQAAAA==.',
['梦境']='梦境里的算法:BAACLgAFFH8UAAINAAUJ+BruAwCkAQANAAUJ+BruAwCkAQAuAAQKfxkAAg0ACQkaHWYLAOYCAA0ACQkaHWYLAOYCAAAA.',
['森林']='森林迷惑:BAAALgAFFAEJAQAAAA==.',
['歪丫']='歪丫女:BAAALgAECgUJBQAAAA==.',
['歪歪']='歪歪女:BAAALgAFFAEJAQAAAA==.',
['歪比']='歪比巴波:BAAALgAECgEJAQAAAA==.',
['死神']='死神明白了:BAAALgAECgEJAQAAAA==.',
['残小']='残小龙:BAAALgAECgYJBgAAAA==.',
['殘魂']='殘魂斷:BAAALgADCgIJAgAAAA==.',
['水四']='水四号:BAAALgAECgkJEgAAAA==.',
['水树']='水树奈奈桑:BAAALgAECgQJAwAAAA==.',
['永恒']='永恒丶祈咒者:BAAALgADCgMJAwAAAA==.',
['没事']='没事玩术师:BAAALgAECgUJCgAAAA==.',
['泰蘭']='泰蘭德尐妹:BAAALgADCgEJAQAAAA==.',
['泼天']='泼天富贵:BAAALgAFFAQJAwAAAA==.',
['涕尼']='涕尼魅:BAACLgAFFH8MAAMUAAQJ1AnWAwABAQAUAAQJ1AnWAwABAQAQAAEJWAJNJQBIAAAuAAQKfxUAAhQACQlNEcgSAN0BABQACQlNEcgSAN0BAAAA.',
['清风']='清风孤寂:BAAALgADCgEJAQAAAA==.',
['火雨']='火雨法:BAACLgAFFH8KAAMMAAQJHBkbEwBPAQAMAAQJThAbEwBPAQASAAIJkBleAgCyAAAuAAQKfxQAAxIABwmKFGMYAIgBABIABgnZF2MYAIgBAAwABQmdEEaxAPYAAAAA.',
['灬搁']='灬搁浅:BAAALgAECgYJBwAAAA==.',
['灵魂']='灵魂舞动:BAAALgAECgcJDAAAAA==.',
['灼热']='灼热凶器:BAAALgAECgQJBQAAAA==.',
['為你']='為你瘋颠:BAAALgAECgUJCQAAAA==.',
['牙牙']='牙牙叁:BAAALgAECgUJBgAAAA==.',
['狐图']='狐图图:BAAALgAECgEJAQAAAA==.',
['狩猎']='狩猎律动:BAAALgADCgIJAgAAAA==.',
['玉衡']='玉衡:BAABLgAFFH8NAAMEAAUJpQq3BQCAAQAEAAUJpQq3BQCAAQAFAAQJkhLqCAA+AQAAAA==.',
['王大']='王大福:BAABLgAECn8cAAQFAAcJqRA/PACQAQAFAAcJqRA/PACQAQAVAAIJVAQSKABbAAAEAAEJrQZ6jAAsAAAAAA==.',
['琻子']='琻子:BAAALgADCgQJBAAAAA==.',
['瑶池']='瑶池醉酒:BAAALgAFFAIJAgAAAA==.',
['生死']='生死之骑士:BAAALgAECgEJAQAAAA==.',
['白石']='白石龙深情:BAAALgAECgcJAgAAAA==.',
['白色']='白色枫叶:BAAALgAECgEJAgAAAA==.',
['神隐']='神隐藏的少女:BAAALgAECgIJAgAAAA==.',
['禅雅']='禅雅塔:BAAALgAECgYJBgAAAA==.',
['福力']='福力方司:BAAALgAFFAMJAwAAAA==.',
['稚子']='稚子无言:BAAALgADCgcJBwAAAA==.',
['红色']='红色闪电:BAABLgAECn8UAAIGAAkJtR8HEgAPAwAGAAkJtR8HEgAPAwABLgAFFAMJBwADAJEbAA==.',
['红豆']='红豆很忙:BAAALgAECgcJDgAAAA==.',
['给我']='给我擦皮鞋:BAAALgAECgYJEAAAAA==.',
['继清']='继清桀如新生:BAAALgADCgUJBQAAAA==.',
['胖红']='胖红豆:BAAALgAECgMJBQAAAA==.',
['胡多']='胡多多:BAAALgAECgEJAgAAAA==.',
['脑浆']='脑浆炸裂少女:BAAALgAFFAIJBAABLgAFFAcJGQAWANshAA==.',
['苦集']='苦集灭道:BAAALgADCgMJAwAAAA==.',
['苹果']='苹果和烟:BAAALgAFFAIJAgAAAA==.',
['茶小']='茶小涛:BAAALgAFFAEJBAABLgAFFAQJBgANAGAFAA==.',
['荼蘼']='荼蘼小涛:BAAALgAFFAIJAgABLgAFFAQJBgANAGAFAA==.',
['莫里']='莫里亚:BAAALgAECgMJBAAAAA==.',
['菁菁']='菁菁小女:BAABLgAECn8sAAILAAkJVR7JJgDXAgALAAkJVR7JJgDXAgAAAA==.',
['菊花']='菊花就是任性:BAAALgAECgEJAQAAAA==.',
['萌三']='萌三太子:BAAALgAECgEJAQAAAA==.',
['蒙古']='蒙古野驴:BAAALgAECgIJAwAAAA==.',
['薄荷']='薄荷伏特加:BAAALgAECgcJDAAAAA==.薄荷红茶:BAAALgAECgIJAwAAAA==.',
['讲丶']='讲丶者:BAAALgAECgYJBgAAAA==.',
['诗人']='诗人握持:BAAALgAECgkJCQABLgAFFAUJCQAGAGomAA==.',
['贰仟']='贰仟贰佰:BAAALgADCgQJBAAAAA==.',
['赤伶']='赤伶:BAAALgAECgEJAQAAAA==.',
['辰光']='辰光风影:BAABLgAECn8XAAIFAAcJtwhmUQA/AQAFAAcJtwhmUQA/AQAAAA==.',
['边竹']='边竹:BAAALgAFFAEJAwAAAA==.',
['迷失']='迷失森林:BAAALgAECgUJBgAAAA==.',
['迷途']='迷途小可爱:BAAALgADCgEJAQAAAA==.',
['遥看']='遥看青山依旧:BAAALgAECgYJBgAAAA==.',
['那一']='那一炮的温柔:BAAALgAECgMJBwAAAA==.',
['钢琴']='钢琴里的猫:BAABLgAECn8bAAMXAAcJRRh9HwDcAQAXAAcJRRh9HwDcAQAYAAcJNhIvLQCRAQABLgAFFAQJBgAXAAcWAA==.',
['铁翼']='铁翼丨雄风:BAAALgAECgEJAQAAAA==.',
['镜华']='镜华:BAACLgAFFH8JAAMMAAQJrRuIHgAKAQAMAAMJ8RiIHgAKAQASAAIJ6xoqCgC4AAAuAAQKfx8ABBIABwlcImgQAMsBAAwABgkBIdU6ACECABIABglyF2gQAMsBABkAAQmUJaEgAG8AAAAA.',
['长崎']='长崎丨素世:BAAALgADCgEJAQAAAA==.',
['闪电']='闪电疯子:BAAALgADCgMJAwAAAA==.',
['隔夜']='隔夜蒜苔:BAAALgAECgEJAQAAAA==.',
['雨木']='雨木:BAAALgADCgEJAQAAAA==.',
['雪中']='雪中帆:BAAALgAFFAEJAQAAAA==.',
['雪糕']='雪糕刺客:BAAALgADCgcJBwAAAA==.',
['雾来']='雾来信:BAAALgAECgIJAgAAAA==.',
['青春']='青春微微:BAAALgADCgUJBQAAAA==.',
['青梧']='青梧:BAAALgAECgYJCgAAAA==.',
['青藤']='青藤茶:BAAALgAECgMJAwAAAA==.',
['風之']='風之哀伤:BAABLgAFFH8KAAIBAAQJ2hg8CQBkAQABAAQJ2hg8CQBkAQAAAA==.',
['风铃']='风铃术:BAABLgAFFH8FAAIMAAUJ0BTuBgC0AQAMAAUJ0BTuBgC0AQAAAA==.',
['风驰']='风驰天下:BAAALgADCgEJAQAAAA==.',
['骑猪']='骑猪看风景:BAAALgAECgMJBAAAAA==.',
['骨魂']='骨魂:BAAALgAFFAIJAgAAAA==.',
['魂狩']='魂狩:BAACLgAFFH8GAAIDAAMJeCVSFQDDAAADAAMJeCVSFQDDAAAuAAQKfxcABAMACAkUIh8UAN8CAAMACAkUIh8UAN8CAAIAAQkAAO1yADIAABoAAQnPA8QuACUAAAAA.',
['鱼泪']='鱼泪满江:BAAALgAECgYJDgAAAA==.',
['黏黏']='黏黏宝:BAAALgAECgYJDgAAAA==.',
['黑桃']='黑桃丶:BAAALgADCgYJBgAAAA==.',
['黑色']='黑色逆流:BAAALgAECgMJAQAAAA==.',
['黯淡']='黯淡刀锋:BAAALgADCgkJCQAAAA==.',
['龍小']='龍小涛:BAAALgAECgEJAQABLgAFFAQJBgANAGAFAA==.',
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
