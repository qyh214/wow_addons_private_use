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

local lookup = {'Warrior-Protection','Warrior-Arms','Hunter-BeastMastery','Unknown-Unknown','DemonHunter-Devourer','DemonHunter-Havoc','Rogue-Subtlety','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','Monk-Windwalker','DeathKnight-Unholy','Monk-Brewmaster','Shaman-Restoration','Mage-Frost','Warlock-Demonology','DemonHunter-Vengeance','DeathKnight-Blood','Hunter-Marksmanship','Druid-Balance','Paladin-Retribution','DeathKnight-Frost','Shaman-Elemental','Druid-Restoration','Priest-Holy','Priest-Discipline','Priest-Shadow',}
local provider = {region='CN',realm='布莱恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alina:BAAALgAECgIJBAAAAA==.Alive:BAAALgADCgQJBAAAAA==.Altria:BAABLgAECn8XAAMBAAgJghAEFQC9AQABAAgJ2Q8EFQC9AQACAAUJnA7nGgAaAQAAAA==.',
Bu='Buff:BAAALgAECgEJAQAAAA==.',
Ca='Caesar:BAABLgAFFH8FAAIDAAIJhyMEDwDSAAADAAIJhyMEDwDSAAAAAA==.Casilas:BAAALgAECgYJBgAAAA==.',
Da='Danisal:BAAALgAECgEJAQAAAA==.',
Fi='Fingerto:BAAALgAECgcJDAAAAA==.',
Fl='Fluffy:BAAALgADCgYJBgABLgAFFAIJBAAEAAAAAA==.Fluky:BAAALgAECgMJAwABLgAFFAIJBAAEAAAAAA==.',
Ga='Gamahada:BAACLgAFFH8MAAMFAAUJURMRCQCYAQAFAAUJURMRCQCYAQAGAAEJiAG7DwBDAAAuAAQKfyMAAwUACAl1IOAZALkCAAUACAnvH+AZALkCAAYABgm5G8wpAHYBAAAA.',
Gi='Gifty:BAAALgAECgcJBwAAAA==.',
Ha='Hasasin:BAABLgAECn8WAAIHAAcJDBYVIQDwAQAHAAcJDBYVIQDwAQAAAA==.',
Jc='Jchc:BAAALgAFFAEJAQAAAA==.',
Ka='Kakamie:BAACLgAFFH8TAAMIAAUJOSKRDQAoAQAIAAMJdiGRDQAoAQAJAAMJdSBCBQDFAAAuAAQKfyoABAgACAkZI4gPAH8CAAgABwnSHYgPAH8CAAoABwmLF00VAPUBAAkACAn0Iv0OAOsBAAAA.Kakamis:BAABLgAECn8ZAAILAAcJwyI1DAC2AgALAAcJwyI1DAC2AgABLgAFFAUJEwAIADkiAA==.',
Me='Mewtwo:BAAALgAECgYJCgAAAA==.',
Ni='Nightrevan:BAAALgAECgUJDgAAAA==.',
Nm='Nm:BAAALgAECgMJAwAAAA==.',
Sa='Sansa:BAAALgAECgYJCQAAAA==.',
Sh='Sherry:BAAALgAECgMJAwAAAA==.',
Sn='Snakeql:BAAALgAECgEJAQAAAA==.',
Ss='Ssqq:BAAALgADCgIJAgAAAA==.',
Sy='Sylarr:BAAALgAECgYJDQAAAA==.',
Ti='Titahk:BAAALgADCgEJAQABLgAFFAUJDAAMAMohAA==.',
Tt='Tt:BAAALgAECgYJDAAAAA==.',
Um='Umbreon:BAAALgADCgYJBgAAAA==.',
Va='Valentino:BAAALgAFFAIJBAAAAA==.',
Ya='Yakihu:BAABLgAECn8ZAAINAAgJCSCfEQCIAgANAAgJCSCfEQCIAgAAAA==.Yakiihu:BAACLgAFFH8VAAINAAUJ+iDEAQDwAQANAAUJ+iDEAQDwAQAuAAQKfyYAAg0ACAl+IYIIAP8CAA0ACAl+IYIIAP8CAAAA.',
Zc='Zcy:BAAALgAECgkJDwAAAA==.',
['一个']='一个低手:BAAALgAFFAIJAgAAAA==.',
['一叶']='一叶随风:BAAALgADCgMJAwAAAA==.一叶飘零:BAAALgAECgYJCAAAAA==.',
['一月']='一月光:BAAALgAECgUJBQAAAA==.',
['一路']='一路哀愁:BAAALgAECgEJAQAAAA==.',
['一颗']='一颗小菠菜:BAAALgAECgkJCwAAAA==.',
['七七']='七七:BAAALgAECgYJCgAAAA==.',
['三月']='三月:BAAALgAECgMJAQAAAA==.',
['三聚']='三聚氰胺:BAAALgAFFAQJAwAAAA==.',
['不死']='不死战神:BAABLgAECn8XAAIMAAgJ+A4JaQC7AQAMAAgJ+A4JaQC7AQAAAA==.',
['不许']='不许喂猫呀丶:BAAALgADCgEJAQAAAA==.',
['与妳']='与妳立黄昏丶:BAABLgAFFH8GAAIOAAMJhg8uEADnAAAOAAMJhg8uEADnAAAAAA==.',
['东东']='东东昌:BAAALgAECgQJBAAAAA==.',
['中岛']='中岛由贵:BAAALgAECgYJDAAAAA==.',
['丶喵']='丶喵呜喵呜:BAAALgAECgYJDgAAAA==.',
['丶头']='丶头上有犄角:BAAALgAECgMJAwAAAA==.',
['丷爱']='丷爱似水仙丷:BAABLgAECn8aAAIGAAgJGxv0EgBAAgAGAAgJGxv0EgBAAgAAAA==.',
['乛乛']='乛乛:BAAALgAECgIJAgAAAA==.',
['二嫂']='二嫂:BAAALgAECgYJBgAAAA==.',
['伊天']='伊天洛儿:BAAALgADCgEJAQAAAA==.',
['伊栗']='伊栗丹:BAAALgAECgYJDQAAAA==.',
['传火']='传火:BAAALgAECgQJBQAAAA==.',
['保护']='保护留给主坦:BAAALgAECgEJAQAAAA==.',
['倚树']='倚树听风:BAAALgAECgQJBwAAAA==.',
['借风']='借风吻你:BAAALgADCgcJBwAAAA==.',
['克里']='克里斯滕丽特:BAAALgAFFAEJAQAAAA==.',
['八命']='八命切奥克托:BAAALgAFFAIJAwAAAA==.',
['军爺']='军爺:BAAALgAECgQJAwAAAA==.',
['冰结']='冰结傀儡丶:BAAALgADCgIJAgAAAA==.',
['冲天']='冲天炮:BAAALgAECgEJAQAAAA==.',
['凤吹']='凤吹三花开:BAAALgADCgYJBgAAAA==.',
['凯鲨']='凯鲨:BAABLgAECn8bAAIPAAgJMhuvKgDIAgAPAAgJMhuvKgDIAgAAAA==.',
['刘德']='刘德璋:BAAALgAFFAEJAQABLgAFFAMJBAAEAAAAAA==.',
['刺客']='刺客尼克:BAAALgAFFAEJAgAAAA==.',
['刺探']='刺探你的温柔:BAAALgAECgQJBAAAAA==.',
['剑破']='剑破长风:BAAALgAECgYJCwAAAA==.',
['剡溟']='剡溟:BAAALgAFFAIJAgAAAA==.',
['加摩']='加摩尔:BAAALgAECgYJCAAAAA==.',
['勇敢']='勇敢的火柴:BAAALgAECgcJCgAAAA==.',
['十一']='十一棵刺槐树:BAAALgADCgYJBgAAAA==.',
['十年']='十年术木:BAABLgAFFH8FAAIQAAIJzBsrKwDDAAAQAAIJzBsrKwDDAAAAAA==.',
['卡卡']='卡卡罗:BAAALgAECgUJBwAAAA==.',
['叶随']='叶随风:BAAALgAECgYJCQAAAA==.',
['听风']='听风不是雨啊:BAAALgAFFAQJAQAAAA==.',
['哀木']='哀木涕拉好怪:BAAALgAECgEJAQAAAA==.',
['哒哒']='哒哒大领主:BAAALgAECgYJBgAAAA==.',
['嘉世']='嘉世一:BAAALgAFFAIJBAAAAA==.',
['图拉']='图拉扬:BAAALgAFFAEJAQABLgAFFAQJCAAMAOYXAA==.',
['地狱']='地狱不是天堂:BAAALgAECgYJCQAAAA==.',
['坑爹']='坑爹的氯化银:BAAALgAECgIJAgAAAA==.',
['城市']='城市套路深:BAAALgAECgEJAQAAAA==.',
['复仇']='复仇:BAACLgAFFH8MAAIPAAUJNB0QCADiAQAPAAUJNB0QCADiAQAuAAQKfx8AAg8ACAnuI8QPAEoDAA8ACAnuI8QPAEoDAAAA.',
['多琳']='多琳:BAAALgAECgQJBAAAAA==.',
['多莉']='多莉的擁抱:BAACLgAFFH8VAAIRAAUJ4x0yAADDAQARAAUJ4x0yAADDAQAuAAQKfyUAAhEACAmGJNwBAPYCABEACAmGJNwBAPYCAAAA.',
['大屁']='大屁:BAABLgAECn8eAAISAAgJBRqlCgBtAgASAAgJBRqlCgBtAgAAAA==.',
['大藏']='大藏里想奈:BAAALgAECgEJAQABLgAECgQJBAAEAAAAAA==.',
['天剑']='天剑绝刀:BAAALgADCgYJBAAAAA==.',
['天堂']='天堂的幽默:BAAALgAFFAIJAwAAAA==.',
['天风']='天风永佑:BAAALgAECgEJAQAAAA==.',
['奶糖']='奶糖人:BAAALgAECgYJCgAAAA==.奶糖的复仇:BAAALgAECgEJAQAAAA==.',
['好吃']='好吃懒做:BAACLgAFFH8MAAMMAAUJyiGeBwCUAQAMAAQJyiGeBwCUAQASAAEJAABbGQA3AAAuAAQKfx4AAgwACAnoIjAUAAIDAAwACAnoIjAUAAIDAAAA.',
['好汣']='好汣不見:BAAALgADCgEJAQAAAA==.',
['如烟']='如烟丶:BAABLgAFFH8GAAMTAAMJeRV4HACkAAATAAIJARN4HACkAAADAAEJaRqBHwBiAAAAAA==.',
['妇女']='妇女之友:BAAALgAECgMJBQAAAA==.',
['嬛嬛']='嬛嬛:BAAALgADCggJEAAAAA==.',
['安格']='安格纳:BAAALgAECgQJBQAAAA==.',
['安静']='安静丶丶:BAAALgAECgMJAwAAAA==.安静丶喵喵:BAAALgAECgYJCwAAAA==.',
['家伙']='家伙事贼大:BAAALgADCgYJBgAAAA==.',
['小丑']='小丑龙:BAABLgAFFH8KAAIJAAUJkiUbAAAtAgAJAAUJkiUbAAAtAgAAAA==.',
['小手']='小手火热热丶:BAAALgADCgQJBAAAAA==.',
['小狐']='小狐狸丶丶:BAAALgADCgYJBgAAAA==.',
['小米']='小米粥丶:BAAALgAECgMJBQAAAA==.',
['少管']='少管我:BAAALgAFFAIJAwAAAA==.',
['尼禄']='尼禄:BAABLgAECn8gAAIMAAgJGxY7VwDsAQAMAAgJGxY7VwDsAQABLgAFFAUJFQAUADMRAA==.',
['岚心']='岚心云岫:BAAALgAFFAIJAgAAAA==.',
['左龙']='左龙武卫:BAABLgAECn8aAAIVAAgJfxmuKwB1AgAVAAgJfxmuKwB1AgABLgAFFAYJBwAFAGYTAA==.',
['巫妖']='巫妖王:BAACLgAFFH8IAAIMAAQJ5hcRBgBcAQAMAAQJ5hcRBgBcAQAuAAQKfxwAAwwACAmwHKQiALUCAAwACAmwHKQiALUCABYAAQmdCxIJADoAAAAA.',
['帅气']='帅气尼克:BAAALgADCgUJBQAAAA==.',
['弯弓']='弯弓射贱:BAAALgAECgUJCwAAAA==.',
['彩丨']='彩丨虹:BAAALgAECgkJEAAAAA==.',
['彩虹']='彩虹之梦:BAAALgAECgcJBwABLgAFFAUJBQARAFMlAA==.',
['徐公']='徐公明丶:BAAALgAECgIJAgAAAA==.',
['忽悠']='忽悠忽悠猎:BAAALgAECgEJAQAAAA==.',
['怒灿']='怒灿:BAABLgAFFH8KAAIBAAMJMRuxBgD7AAABAAMJMRuxBgD7AAAAAA==.',
['悠悠']='悠悠德野性:BAAALgAECgUJCAABLgAECgkJCwAEAAAAAA==.',
['感到']='感到圣:BAAALgAECgEJAQAAAA==.',
['慕梓']='慕梓鸢:BAAALgAECgIJAgAAAA==.',
['我是']='我是一个演员:BAAALgAECgEJAQAAAA==.我是日蚀丷:BAAALgAFFAEJAQAAAA==.',
['我沒']='我沒有鬍子:BAAALgAECgQJBAAAAA==.',
['戰魂']='戰魂丶小雄:BAAALgADCgYJCgAAAA==.',
['拉块']='拉块:BAAALgAFFAIJAwAAAA==.',
['提里']='提里奥弗丁丶:BAAALgAECgUJBgAAAA==.',
['揷哥']='揷哥来了:BAAALgAECgUJCAAAAA==.',
['擎潮']='擎潮主:BAACLgAFFH8HAAIOAAQJLgmnEQDaAAAOAAQJLgmnEQDaAAAuAAQKfyMAAw4ACAn3HO4RAIcCAA4ACAn3HO4RAIcCABcAAQk8CemEADcAAAAA.',
['斩恋']='斩恋:BAAALgAECgEJAQAAAA==.',
['斯卡']='斯卡蒂:BAAALgAECgUJCwAAAA==.',
['无奈']='无奈的小精灵:BAAALgAECgQJBAAAAA==.',
['昕魔']='昕魔:BAAALgAECgcJAQABLgAFFAgJGgAPAHwmAA==.',
['星野']='星野闭上眼:BAAALgAECgQJBAABLgAFFAIJAgAEAAAAAA==.',
['是眼']='是眼子啊:BAAALgAECgIJAgAAAA==.',
['暗黑']='暗黑丶幽魂:BAAALgAECgUJCgAAAA==.',
['曹阿']='曹阿瞒:BAAALgAECgEJAQAAAA==.',
['有事']='有事稳李锐:BAABLgAECn8UAAIMAAYJGx5bZwC/AQAMAAYJGx5bZwC/AQAAAA==.',
['木依']='木依:BAAALgAFFAMJBAAAAA==.',
['木宁']='木宁馨:BAABLgAFFH8HAAISAAUJGxH9BABVAQASAAUJGxH9BABVAQAAAA==.',
['杀生']='杀生院祈荒:BAAALgAECgQJBwAAAA==.',
['杨桃']='杨桃子:BAAALgAFFAIJAgAAAA==.',
['枫哥']='枫哥奶你一脸:BAAALgADCgYJBgAAAA==.枫哥熊你一脸:BAAALgADCgcJBwAAAA==.枫哥锤你一脸:BAAALgAFFAEJAgAAAA==.',
['柒丶']='柒丶零:BAAALgAECgYJEAAAAA==.',
['柳木']='柳木詩夢:BAAALgAFFAMJBAAAAA==.',
['橙紅']='橙紅年代:BAAALgAECgYJBQAAAA==.',
['武汉']='武汉特色小吃:BAABLgAECn8XAAMUAAgJFhq4HAAbAgAUAAgJFhq4HAAbAgAYAAQJGByJXgA2AQABLgAFFAQJDAAYAF4bAA==.',
['殇纟']='殇纟佷:BAAALgAECgEJAgAAAA==.',
['流風']='流風回雪:BAAALgAFFAIJAwAAAA==.',
['涼舟']='涼舟:BAAALgAECgEJAQAAAA==.',
['淳简']='淳简拉基兹德:BAAALgADCgEJAQAAAA==.',
['淺墨']='淺墨未央:BAACLgAFFH8OAAIHAAQJTQO0CwAoAQAHAAQJTQO0CwAoAQAuAAQKfyMAAgcACAnmEicfAAECAAcACAnmEicfAAECAAAA.',
['湫湫']='湫湫:BAAALgAFFAQJBAAAAA==.',
['炼狱']='炼狱修罗斩:BAAALgAECgYJBgAAAA==.',
['烈海']='烈海王:BAACLgAFFH8IAAILAAMJuR5gBgAVAQALAAMJuR5gBgAVAQAuAAQKfxsAAgsACAmPIpcIAPACAAsACAmPIpcIAPACAAAA.烈海皇:BAAALgAECgYJDAAAAA==.',
['烟丶']='烟丶絈:BAAALgAECgkJCgAAAA==.烟丶茉:BAABLgAECn8XAAIPAAkJeRdeTwBJAgAPAAkJeRdeTwBJAgAAAA==.',
['焰天']='焰天火雨:BAAALgADCgEJAQAAAA==.',
['燃烧']='燃烧的开心果:BAAALgAECgYJBgAAAA==.',
['狄瑞']='狄瑞吉:BAAALgAECgQJBgAAAA==.',
['玩原']='玩原神玩的:BAAALgAECgYJDAAAAA==.',
['男神']='男神你雨果:BAABLgAECn8bAAIZAAgJXCIzBgDsAgAZAAgJXCIzBgDsAgAAAA==.',
['矮老']='矮老头:BAAALgAECgUJBQAAAA==.',
['神丶']='神丶欧皇:BAAALgAECgYJBgAAAA==.',
['秋水']='秋水:BAAALgAECgYJDgAAAA==.',
['笨呼']='笨呼呼:BAAALgAECgEJAQAAAA==.',
['米奇']='米奇亚:BAAALgADCgYJBgAAAA==.',
['粥酱']='粥酱丶:BAAALgAECgUJCAAAAA==.',
['索利']='索利达尔:BAAALgAECgEJAQAAAA==.',
['紫曦']='紫曦小米粥:BAABLgAFFH8KAAMaAAQJfhJEDQD4AAAaAAMJuRdEDQD4AAAZAAIJhQmAEwBIAAAAAA==.',
['绯樱']='绯樱闲:BAABLgAECn8ZAAIQAAYJOiGTLwBOAgAQAAYJOiGTLwBOAgAAAA==.',
['老灯']='老灯:BAACLgAFFH8HAAIMAAIJpiDhMwC5AAAMAAIJpiDhMwC5AAAuAAQKfxkAAgwACQnzI2wFAH4DAAwACQnzI2wFAH4DAAAA.',
['肥皂']='肥皂奶糖:BAAALgAECgQJBAAAAA==.',
['脆脆']='脆脆角:BAAALgAECgcJEAABLgAFFAUJCgAJAJIlAA==.',
['脎鸸']='脎鸸:BAAALgAECgcJDwAAAA==.',
['艳梅']='艳梅:BAAALgAFFAQJBAAAAA==.',
['艾尔']='艾尔莉亚:BAAALgAECgcJBwABLgAFFAQJEwAYADEgAA==.',
['艾露']='艾露恩:BAAALgAECgYJBgAAAA==.',
['芯魔']='芯魔:BAAALgAECgYJBwAAAA==.',
['草莓']='草莓炒饭:BAAALgAFFAEJAQAAAA==.',
['萧瑟']='萧瑟寒风:BAAALgAECgIJBQAAAA==.',
['落叶']='落叶归风:BAAALgAECgQJBwAAAA==.落叶是我的:BAABLgAFFH8JAAQaAAMJ9hrSDAADAQAaAAMJ9hrSDAADAQAbAAEJrwPTFgBGAAAZAAEJhw/rFQA+AAAAAA==.',
['葱头']='葱头:BAAALgAECgYJCgAAAA==.',
['蓝染']='蓝染惣右介:BAAALgAECgYJDwAAAA==.',
['虎面']='虎面笑:BAAALgAECgYJBwAAAA==.',
['让我']='让我砍:BAAALgAFFAEJAQAAAA==.',
['许仲']='许仲康:BAAALgAECgEJAgAAAA==.',
['诡秘']='诡秘侍女:BAAALgADCgYJBgAAAA==.',
['豆腐']='豆腐炒西瓜:BAAALgAECgYJCgAAAA==.',
['路卡']='路卡利欧:BAAALgAECgcJBwAAAA==.',
['踏雪']='踏雪無痕:BAABLgAFFH8FAAINAAMJzRLACwCXAAANAAMJzRLACwCXAAAAAA==.',
['输出']='输出为零:BAAALgAECgQJBAAAAA==.',
['辛月']='辛月舞:BAAALgAECggJCQAAAA==.',
['达克']='达克赛德:BAAALgAECgcJEQAAAA==.',
['达到']='达到燃放:BAAALgAECgYJBwAAAA==.',
['远浪']='远浪:BAAALgAECgEJAQAAAA==.',
['远野']='远野星河:BAAALgAFFAIJAwAAAA==.',
['迷离']='迷离:BAAALgAECgcJCgAAAA==.',
['迷麟']='迷麟:BAAALgAECgcJCAAAAA==.',
['逐枫']='逐枫:BAAALgADCgEJAQAAAA==.',
['郁灵']='郁灵:BAAALgADCgYJBgAAAA==.',
['郭小']='郭小涵:BAAALgAECgYJCgAAAA==.',
['银狐']='银狐狸:BAAALgAECgMJAQAAAA==.',
['锥子']='锥子骑士:BAAALgAFFAMJAwAAAA==.',
['闹闹']='闹闹桑:BAABLgAECn8bAAIOAAgJexHKKgDiAQAOAAgJexHKKgDiAQAAAA==.',
['阴影']='阴影鬼魅:BAAALgAECgQJBAAAAA==.',
['阿克']='阿克萌德:BAAALgAECgEJAgAAAA==.',
['阿菲']='阿菲:BAAALgAECgEJAQAAAA==.',
['隔叶']='隔叶听风:BAAALgADCgMJAwAAAA==.',
['雪狐']='雪狐狸:BAAALgAECgMJBgAAAA==.',
['雾酒']='雾酒雷霆:BAAALgAECgQJBwABLgAFFAEJAQAEAAAAAA==.',
['青青']='青青草:BAAALgAFFAIJAgAAAA==.',
['风中']='风中的传说:BAAALgAECgYJEwAAAA==.',
['飞马']='飞马小幻想:BAAALgAECgIJAwAAAA==.飞马梦想:BAAALgAECgUJBQAAAA==.',
['马老']='马老魔:BAAALgAFFAIJAgAAAA==.',
['魅影']='魅影无形:BAACLgAFFH8HAAIbAAMJxBiLBAACAQAbAAMJxBiLBAACAQAuAAQKfxQAAxsABwmDG9oRAG0CABsABwmDG9oRAG0CABoAAwncHf40APwAAAAA.',
['魔霭']='魔霭缠绕:BAAALgAECgIJAwABLgAFFAEJAQAEAAAAAA==.',
['龙炎']='龙炎火球:BAAALgAFFAEJAQAAAA==.',
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
