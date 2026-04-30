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

local lookup = {'DeathKnight-Blood','Monk-Mistweaver','Monk-Windwalker','DeathKnight-Unholy','DemonHunter-Devourer','Unknown-Unknown','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Evoker-Preservation','Mage-Frost','Hunter-BeastMastery','Priest-Discipline','Priest-Holy','Priest-Shadow','Druid-Balance',}
local provider = {region='CN',realm='奎尔萨拉斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Amakusashino:BAACLgAFFH8HAAIBAAMJxR1tBwAZAQABAAMJxR1tBwAZAQAuAAQKfyUAAgEACAm9JJwEAP8CAAEACAm9JJwEAP8CAAAA.',
As='Astralight:BAAALgADCgEJAQAAAA==.',
Bi='Bitoy:BAAALgAECgcJDQAAAA==.Bitoyy:BAACLgAFFH8JAAICAAQJ3BL6CAApAQACAAQJ3BL6CAApAQAuAAQKfxkAAwIACAl9IGcJAL0CAAIACAl9IGcJAL0CAAMABAnWFXtCAA0BAAAA.Bittoy:BAAALgAECgEJAQAAAA==.',
Ch='Chastener:BAAALgAECgIJBAAAAA==.',
Dh='Dhpaopao:BAAALgAECgEJAgAAAA==.',
Gu='Guldar:BAAALgAECgYJEgAAAA==.',
Ha='Haterdwow:BAAALgAECgEJAgAAAA==.',
Ho='Holylight:BAAALgAECgIJAgAAAA==.',
My='Myx:BAAALgAFFAMJAQAAAA==.',
Ro='Rossyl:BAAALgAECgIJAgAAAA==.',
Sp='Spring:BAAALgAFFAIJAgAAAA==.',
Ts='Tsla:BAAALgAECgkJAQAAAA==.',
Xr='Xroguein:BAAALgAECgEJAQAAAA==.',
['一只']='一只甜甜橘丶:BAAALgADCgUJBQAAAA==.',
['一砣']='一砣子:BAACLgAFFH8HAAIEAAMJshiUJAADAQAEAAMJshiUJAADAQAuAAQKfxUAAgQACAlgFz5BADQCAAQACAlgFz5BADQCAAAA.',
['三希']='三希:BAACLgAFFH8GAAIEAAMJOBGwKAD2AAAEAAMJOBGwKAD2AAAuAAQKfygAAgQACAkjHWsFADECAAQACAkjHWsFADECAAAA.',
['下半']='下半蛆职业:BAAALgAECgcJDAAAAA==.',
['两砣']='两砣子:BAABLgAFFH8FAAIFAAIJRwxzKgCbAAAFAAIJRwxzKgCbAAABLgAFFAMJBwAEALIYAA==.',
['乄撒']='乄撒加乄:BAAALgAECgYJBQAAAA==.',
['乄无']='乄无界乄:BAAALgAECgYJCwAAAA==.',
['乄铭']='乄铭孤独:BAAALgAECgYJAQABLgAFFAEJAgAGAAAAAA==.',
['乱披']='乱披风:BAAALgADCgEJAQAAAA==.',
['今天']='今天喝绿茶:BAAALgAECgQJBAAAAA==.',
['从善']='从善如劉先生:BAAALgAECgEJAQAAAA==.',
['仰望']='仰望黎明:BAAALgAECgYJCAAAAA==.',
['你无']='你无敌了:BAAALgAECgYJBgAAAA==.',
['佬捌']='佬捌:BAAALgAECgYJEAAAAA==.',
['傲雪']='傲雪凝香:BAAALgAECggJDQAAAA==.',
['冰镇']='冰镇奶茶:BAAALgAECgYJBgAAAA==.',
['到处']='到处乱插:BAAALgAFFAIJAgAAAA==.',
['勇者']='勇者无畏:BAAALgADCgQJAwAAAA==.',
['勤奋']='勤奋的棒棒:BAAALgAECgYJCAAAAA==.',
['十八']='十八般武艺:BAAALgADCgEJAQAAAA==.',
['又又']='又又不是双:BAAALgADCgYJDwAAAA==.',
['可乐']='可乐可口:BAAALgAECgIJAgAAAA==.',
['哇酷']='哇酷哇酷:BAACLgAFFH8LAAQHAAQJYBymGwAYAQAHAAMJpx2mGwAYAQAIAAEJjRg+AQBgAAAJAAEJzgwXFgBTAAAuAAQKfxUABAcABwm5HvNWAMMBAAcABQm+IfNWAMMBAAkABAlGFLUxAPIAAAgAAQkAAEA1ADEAAAAA.',
['唯美']='唯美丶圣光:BAAALgAECgYJBgAAAA==.唯美丶黯殇:BAAALgAECgQJDAAAAA==.',
['啸男']='啸男蝴:BAAALgAECgIJAwAAAA==.',
['喵一']='喵一咪:BAAALgAECgYJBgAAAA==.',
['嗯灬']='嗯灬莪在呢:BAAALgAECgIJAgAAAA==.',
['噗叽']='噗叽菜菜:BAACLgAFFH8HAAIKAAQJ3yYrAwDZAQAKAAQJ3yYrAwDZAQAuAAQKfxgAAgoABgmMJlYJAKECAAoABgmMJlYJAKECAAAA.',
['圣盾']='圣盾:BAAALgADCgEJAQAAAA==.',
['埋了']='埋了故汰:BAAALgAECgMJAwAAAA==.',
['夏天']='夏天的风雪:BAAALgADCgcJEAAAAA==.',
['大肚']='大肚子:BAAALgAECgMJAwAAAA==.',
['大贤']='大贤良师:BAAALgAECgYJBgAAAA==.',
['夾心']='夾心棉花糖:BAAALgAECgkJEQAAAA==.',
['如果']='如果你冷:BAABLgAFFH8GAAILAAMJbh7oKgAJAQALAAMJbh7oKgAJAQAAAA==.',
['妖精']='妖精的嫙律:BAAALgAECgEJAQAAAA==.',
['娜缇']='娜缇灬洸茗:BAAALgAECgEJAQAAAA==.',
['孤独']='孤独的北极星:BAAALgAFFAEJAQABLgAFFAIJBAAGAAAAAA==.',
['宁爺']='宁爺:BAAALgAECgEJAQAAAA==.',
['安苏']='安苏素质最差:BAAALgAECgYJBgAAAA==.',
['寂寞']='寂寞灬恶魔:BAABLgAFFH8GAAIMAAIJFxqsCwC8AAAMAAIJFxqsCwC8AAAAAA==.寂寞的老鹰:BAAALgAFFAEJAQAAAA==.',
['小兔']='小兔叽:BAAALgADCgEJAQAAAA==.',
['小小']='小小懒虫:BAABLgAFFH8PAAMNAAYJxBTwAwC1AQANAAUJYhTwAwC1AQAOAAEJsBYAAAAAAAAAAA==.',
['小紫']='小紫龙:BAAALgAECgQJBAAAAA==.',
['小脚']='小脚冰凉:BAAALgAECgcJBwAAAA==.',
['小路']='小路:BAAALgAECgUJBQAAAA==.',
['小鱼']='小鱼多多:BAAALgAECgEJAQAAAA==.',
['尐嘴']='尐嘴无虑:BAAALgAECgMJAwAAAA==.',
['屁屁']='屁屁橘丶:BAAALgADCgIJAgAAAA==.',
['屬灬']='屬灬於:BAAALgAECgYJBgAAAA==.',
['峖莘']='峖莘:BAAALgAECgkJBwAAAA==.',
['帅熊']='帅熊冬阳:BAAALgAECgQJBAAAAA==.',
['幕后']='幕后煮屎:BAAALgADCgMJAwAAAA==.',
['幽冥']='幽冥特使:BAAALgAECgQJBQAAAA==.',
['幽幽']='幽幽鹿鳴:BAAALgAECgcJCwAAAA==.',
['弟理']='弟理士多德:BAAALgAFFAEJAQAAAA==.',
['张大']='张大爷:BAAALgAECgEJAgAAAA==.',
['思南']='思南:BAAALgAECgYJCgAAAA==.',
['恶鬥']='恶鬥:BAAALgAECgkJCQAAAA==.',
['想明']='想明白了:BAAALgAECgcJCwAAAA==.',
['拾丶']='拾丶望:BAAALgAFFAIJBAAAAA==.',
['摧灬']='摧灬残:BAAALgAECgYJEQAAAA==.',
['撞得']='撞得像头牛:BAAALgAECgQJBQAAAA==.',
['明枪']='明枪易躲:BAAALgADCgYJCAAAAA==.',
['暗灬']='暗灬慯:BAAALgAECgIJAgAAAA==.',
['暴徒']='暴徒:BAAALgADCgcJHgAAAA==.',
['曙光']='曙光预言者:BAAALgAECgEJAQAAAA==.',
['月光']='月光独角兽:BAAALgAECgMJAwAAAA==.',
['服怒']='服怒娃:BAAALgADCgEJAQAAAA==.',
['木雁']='木雁龙蛇:BAAALgAFFAIJAwAAAA==.',
['杨幂']='杨幂:BAAALgAECgIJAQAAAA==.',
['某某']='某某蝎子:BAAALgAECgEJAQAAAA==.',
['梦中']='梦中来过:BAAALgAECgIJAgAAAA==.',
['梦断']='梦断肯瑞托:BAAALgAECgYJDAAAAA==.',
['橙色']='橙色芷萌:BAAALgAFFAEJAQAAAA==.',
['歪瑞']='歪瑞奈斯:BAAALgAECgYJBgAAAA==.',
['残暴']='残暴者:BAAALgADCgUJBQAAAA==.',
['江老']='江老板劈啪斩:BAAALgAFFAIJAgAAAA==.',
['洋鸟']='洋鸟消夏录:BAAALgAECgYJBwAAAA==.',
['海河']='海河江山:BAAALgADCgUJCAAAAA==.',
['深呼']='深呼吸的吻:BAAALgAECgYJCwAAAA==.',
['混紫']='混紫牧:BAABLgAECn8VAAQOAAgJIiFnCQC1AgAOAAcJXyJnCQC1AgANAAQJDhjDMAAaAQAPAAIJkx/1SQC0AAAAAA==.',
['游学']='游学者周逊:BAAALgADCgUJBQAAAA==.',
['灬熾']='灬熾燑灬:BAAALgAFFAEJAQAAAA==.',
['灬赤']='灬赤曈灬:BAAALgAECgcJBwAAAA==.',
['然然']='然然:BAAALgAFFAQJBAABLgAFFAQJBgAPAAcWAA==.',
['熊熊']='熊熊十六:BAAALgAECgEJAQAAAA==.',
['熏悟']='熏悟空:BAAALgAECgIJBAAAAA==.',
['爆椒']='爆椒牛肉面:BAAALgAFFAIJAgAAAA==.',
['爱莲']='爱莲娜:BAAALgAECgYJBgAAAA==.',
['牛不']='牛不吟马不啸:BAAALgADCgYJAgAAAA==.',
['牛得']='牛得一比:BAABLgAECn8XAAIQAAgJuA/7JgDGAQAQAAgJuA/7JgDGAQAAAA==.',
['狡诈']='狡诈的猎狐者:BAAALgAFFAIJBAAAAA==.',
['琅琊']='琅琊符:BAAALgADCgUJBQAAAA==.',
['理塘']='理塘最强伝説:BAAALgAECgUJBQAAAA==.',
['瓦坎']='瓦坎达否埃瓦:BAAALgAECgIJAgAAAA==.',
['皮卡']='皮卡球:BAAALgAECgQJBQAAAA==.',
['祖先']='祖先忽悠着你:BAAALgAECgcJBgAAAA==.',
['神圣']='神圣女王:BAAALgAECgMJAwAAAA==.',
['穷寇']='穷寇当追:BAAALgADCgQJBQAAAA==.',
['繁华']='繁华遗失:BAAALgAECgcJCAAAAA==.',
['纤纤']='纤纤小妖:BAAALgAECgYJCgAAAA==.',
['练练']='练练级泡泡妞:BAAALgADCgQJAQAAAA==.',
['缺德']='缺德找我:BAAALgAECgEJAQAAAA==.',
['老大']='老大哥:BAAALgAECgEJAQAAAA==.',
['老衲']='老衲也曾挺过:BAAALgAECgQJBwAAAA==.',
['自由']='自由的鸟:BAAALgAFFAEJAQAAAA==.',
['芬达']='芬达:BAAALgAECgEJAQAAAA==.',
['英子']='英子爱人:BAAALgAECgMJAwAAAA==.',
['苼灵']='苼灵:BAAALgAECgcJBQAAAA==.',
['萨拉']='萨拉克斯:BAAALgADCgcJCAAAAA==.萨拉塔斯喵:BAAALgAECggJEwAAAA==.',
['蒜香']='蒜香青豆:BAAALgAECgEJAQAAAA==.',
['蓝雨']='蓝雨光之芙蓉:BAABLgAFFH8KAAILAAQJ9A1SHwBLAQALAAQJ9A1SHwBLAQAAAA==.',
['薛定']='薛定谔的狐:BAAALgAECgYJBQAAAA==.',
['虾丸']='虾丸的雪:BAAALgAECgEJAgAAAA==.',
['血染']='血染斜阳:BAAALgADCgcJCAAAAA==.',
['言其']='言其不语:BAACLgAFFH8MAAIEAAQJuR8rCQCIAQAEAAQJuR8rCQCIAQAuAAQKfxcAAgQACAmrIlMSAA4DAAQACAmrIlMSAA4DAAAA.',
['请叫']='请叫我德大爷:BAAALgAECgEJAQAAAA==.',
['贝塞']='贝塞尔函数:BAAALgAECgEJAgAAAA==.',
['贝洛']='贝洛瓦尔:BAAALgADCgIJAgAAAA==.',
['质控']='质控秘书:BAAALgAECgQJAgAAAA==.',
['赤色']='赤色猎王:BAAALgADCgEJAQAAAA==.',
['远赴']='远赴人间:BAAALgADCgYJBgAAAA==.',
['逢牛']='逢牛就弹琴:BAAALgADCgEJAQAAAA==.',
['酒驾']='酒驾请注意:BAAALgAECgYJBwABLgAFFAIJBAAGAAAAAA==.',
['阿尔']='阿尔德克:BAAALgAECgEJAgAAAA==.',
['阿爾']='阿爾德德:BAAALgADCgEJAQAAAA==.',
['陆哥']='陆哥:BAAALgAECgkJCQAAAA==.',
['随风']='随风无晏:BAAALgAECgEJAQAAAA==.',
['雪夜']='雪夜异乡人:BAAALgAECgYJBgAAAA==.',
['风骚']='风骚的大姨妈:BAAALgADCgMJAwAAAA==.',
['高概']='高概率之王:BAAALgAECgYJBgAAAA==.',
['高端']='高端食材:BAAALgADCgEJAQAAAA==.',
['龙归']='龙归诺尔:BAAALgADCgEJAQAAAA==.',
['龙运']='龙运:BAAALgADCgEJAQAAAA==.',
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
