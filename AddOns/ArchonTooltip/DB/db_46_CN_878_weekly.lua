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

local lookup = {'DemonHunter-Devourer','DemonHunter-Havoc','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Holy','Mage-Frost','DeathKnight-Unholy','DeathKnight-Frost','DemonHunter-Vengeance','Priest-Holy','Unknown-Unknown','Warlock-Demonology','Warlock-Destruction','Shaman-Restoration','Druid-Feral','Evoker-Preservation','Evoker-Devastation','Monk-Brewmaster','Evoker-Augmentation','Monk-Windwalker','Monk-Mistweaver','Druid-Restoration','Shaman-Elemental',}
local provider = {region='CN',realm='雷霆号角',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Andy:BAAALgAECgEJAQAAAA==.',
Co='Cole:BAAALgADCgYJBgAAAA==.',
Fu='Funedk:BAAALgAECgYJCwAAAA==.',
Kl='Klarke:BAAALgAECgYJDgAAAA==.',
Le='Leeyoungsun:BAAALgAECgcJDQAAAA==.',
Oc='Octc:BAAALgAFFAYJAQAAAA==.',
Ok='Ok:BAABLgAFFH8FAAMBAAIJ/w6FGgCYAAABAAIJGw2FGgCYAAACAAEJIAkZDgBNAAAAAA==.',
Pa='Pale:BAAALgADCgEJAQAAAA==.',
Ri='Rita:BAAALgADCgUJBQAAAA==.',
Si='Simpleton:BAACLgAFFH8QAAIDAAYJNiE8AAACAgADAAYJNiE8AAACAgAuAAQKfykAAgMACQlpIh8QAA4DAAMACQlpIh8QAA4DAAAA.Simpletonlol:BAAALgAFFAIJAwAAAA==.',
Sk='Sk:BAAALgADCgcJCwAAAA==.',
Th='Thor:BAAALgAECgMJAwAAAA==.',
['一脸']='一脸懵逼:BAAALgADCgYJBgAAAA==.',
['三少']='三少:BAAALgADCgEJAQAAAA==.',
['不想']='不想滚来滚去:BAAALgAECgEJAQAAAA==.',
['不朽']='不朽之王:BAAALgAECgEJAgAAAA==.不朽的憂傷:BAAALgAECgIJAgAAAA==.',
['二老']='二老肥:BAAALgAECgQJBwAAAA==.',
['云小']='云小星:BAAALgAFFAIJAwAAAA==.云小枫:BAACLgAFFH8IAAIEAAQJGhUlBABdAQAEAAQJGhUlBABdAQAuAAQKfxsAAwQACAlBITUDAHwCAAQACAlBITUDAHwCAAUAAQk4C7SLAC8AAAAA.',
['会飞']='会飞的乌鸦:BAAALgAECgQJBQAAAA==.',
['克利']='克利奥佩特拉:BAAALgAECgEJAQAAAA==.',
['六神']='六神:BAAALgAECgMJBAAAAA==.',
['兰色']='兰色妖姬:BAABLgAFFH8FAAIGAAIJhBMZCwCgAAAGAAIJhBMZCwCgAAAAAA==.',
['凉丶']='凉丶情:BAABLgAFFH8FAAIHAAUJqR2bBgD2AQAHAAUJqR2bBgD2AQAAAA==.',
['刀刀']='刀刀巫喵王:BAAALgAECgYJCAAAAA==.',
['初冬']='初冬:BAACLgAFFH8HAAIIAAQJFwSyHwAcAQAIAAQJFwSyHwAcAQAuAAQKfxsAAwgACAkmGvo9AEACAAgACAkmGvo9AEACAAkAAQl1C8YKAD4AAAAA.',
['动如']='动如雷霆:BAAALgAFFAIJAgABLgAFFAMJBwAKAAsbAA==.',
['劳次']='劳次蜀道山:BAAALgAFFAEJAQAAAA==.',
['博丽']='博丽霊梦:BAAALgAFFAEJAQAAAA==.',
['卡佳']='卡佳利丝:BAABLgAECn8WAAILAAYJIyAUFwAjAgALAAYJIyAUFwAjAgAAAA==.',
['卡多']='卡多尔:BAAALgAECgUJBgAAAA==.',
['古允']='古允:BAAALgAFFAQJBAAAAA==.',
['周纸']='周纸弱:BAAALgAECgYJCwAAAA==.',
['啊库']='啊库娜玛塔塔:BAAALgAFFAIJAwAAAA==.',
['啋啋']='啋啋:BAAALgAECgcJDQAAAA==.',
['喵了']='喵了个咪呀:BAAALgAECgcJCQAAAA==.',
['圣英']='圣英:BAAALgAECgEJAQAAAA==.',
['基尔']='基尔哈特:BAAALgADCgEJAQAAAA==.',
['墨墨']='墨墨乌黑:BAAALgADCgcJBwAAAA==.',
['声色']='声色犬马:BAAALgADCgEJAQAAAA==.',
['大嶋']='大嶋优子:BAAALgADCgIJAwAAAA==.',
['天无']='天无语:BAAALgAECgYJBwAAAA==.',
['奈非']='奈非天:BAAALgAECgQJDAAAAA==.',
['安吉']='安吉拉懵逼:BAAALgADCgMJAwAAAA==.',
['寂寞']='寂寞的烟花:BAAALgAECgEJAQAAAA==.',
['对影']='对影成三人:BAACLgAFFH8KAAICAAQJYgZRBAAxAQACAAQJYgZRBAAxAQAuAAQKfxsAAgIACAnTHx8KAMECAAIACAnTHx8KAMECAAAA.',
['小兔']='小兔米纱:BAAALgAECgYJBwAAAA==.',
['小刀']='小刀:BAAALgAECgMJBQAAAA==.',
['小浣']='小浣熊干脆面:BAAALgAFFAIJBAAAAA==.',
['小竹']='小竹妈:BAAALgAECgUJCgAAAA==.小竹妹:BAAALgAECgYJBgABLgAFFAUJBAAMAAAAAA==.小竹表妹:BAAALgAECgYJCQAAAA==.',
['小红']='小红手菈妮:BAABLgAFFH8HAAIEAAQJegfFBwAnAQAEAAQJegfFBwAnAQAAAA==.',
['小船']='小船不用桨:BAABLgAFFH8HAAIGAAMJ1RMpEwCsAAAGAAMJ1RMpEwCsAAAAAA==.',
['小贝']='小贝:BAAALgADCgIJAgAAAA==.',
['巫祝']='巫祝:BAABLgAFFH8FAAMNAAMJKR7tKwC/AAANAAIJpCLtKwC/AAAOAAEJNBUlFABWAAAAAA==.',
['巴比']='巴比乔:BAAALgADCgEJAQAAAA==.',
['布丽']='布丽吉塔:BAAALgAECgQJBAAAAA==.',
['布束']='布束砥信:BAAALgADCgMJAwAAAA==.',
['幸福']='幸福像花一样:BAACLgAFFH8IAAIPAAQJxwufCgAtAQAPAAQJxwufCgAtAQAuAAQKfxsAAg8ACAnfDX4PAHUBAA8ACAnfDX4PAHUBAAAA.',
['彩色']='彩色的肉弹:BAAALgAECgkJDwAAAA==.',
['影爆']='影爆牛肉:BAAALgAECgcJDwAAAA==.',
['得天']='得天独厚:BAAALgADCgcJBwAAAA==.',
['德发']='德发鲁伊:BAACLgAFFH8KAAIQAAQJVhkSAQCGAQAQAAQJVhkSAQCGAQAuAAQKfxsAAhAACAllIAoBAEgCABAACAllIAoBAEgCAAAA.',
['怀特']='怀特先生:BAAALgAECgEJAQAAAA==.',
['我叫']='我叫死骑:BAAALgAECgUJBQAAAA==.',
['战歌']='战歌嘹亮:BAAALgADCgEJAQAAAA==.',
['折花']='折花之人:BAAALgAFFAIJAgAAAA==.',
['晓晴']='晓晴:BAAALgAECgYJBgAAAA==.',
['暗黯']='暗黯谙闇:BAAALgAECgYJEQAAAA==.',
['會上']='會上树的猫:BAAALgAECgEJAgAAAA==.',
['月倾']='月倾浅丶:BAACLgAFFH8GAAIRAAMJQwjvDgDmAAARAAMJQwjvDgDmAAAuAAQKfxQAAxIACAm7IVcAAJYCABIACAm7IVcAAJYCABEAAwmXEQ83ALMAAAAA.',
['月奥']='月奥:BAAALgAFFAMJBAAAAA==.',
['月瞳']='月瞳灬:BAAALgAECgQJBAAAAA==.',
['朝闻']='朝闻秋风:BAAALgAECgMJAwAAAA==.',
['杨紫']='杨紫琼:BAABLgAFFH8KAAITAAQJkhEwDAAkAQATAAQJkhEwDAAkAQAAAA==.',
['梅基']='梅基丘拉:BAAALgAFFAQJBAAAAA==.',
['死亡']='死亡墓穴:BAAALgAECgYJCQAAAA==.',
['汤圆']='汤圆:BAAALgAECgUJBQAAAA==.',
['泡菜']='泡菜炒面:BAAALgAECgEJAQAAAA==.',
['清酒']='清酒:BAAALgAECgYJEgAAAA==.',
['清风']='清风伴华裳丷:BAAALgAECgEJAQAAAA==.清风环佩:BAAALgADCgQJBAAAAA==.',
['游羽']='游羽入:BAAALgAECgIJAgAAAA==.',
['漫漫']='漫漫亦灿灿:BAACLgAFFH8SAAMSAAUJrxqWAgBbAQASAAQJKhaWAgBbAQAUAAIJbxazDgCtAAAuAAQKfx0ABBIACAnCHXIHAHQCABQACAnfGacOAIsCABIABwn8HXIHAHQCABEABAm5CXMzANMAAAAA.',
['灬樱']='灬樱木花道灬:BAABLgAFFH8IAAIVAAIJKg5dDQCYAAAVAAIJKg5dDQCYAAAAAA==.',
['烈焰']='烈焰灼心:BAAALgAECgEJAwAAAA==.',
['牛牛']='牛牛大帝:BAAALgAECgIJAgAAAA==.',
['狂二']='狂二土豆:BAAALgAECgEJAQAAAA==.',
['猪头']='猪头卖卖提:BAAALgADCgEJAQAAAA==.',
['猪柔']='猪柔:BAAALgAECgIJAgAAAA==.',
['猫猫']='猫猫:BAAALgADCgEJAQAAAA==.',
['王姨']='王姨:BAAALgADCgEJAQAAAA==.',
['璐璐']='璐璐麓:BAAALgAECgYJDQAAAA==.',
['电鱼']='电鱼老:BAAALgAECgQJCwAAAA==.',
['画沙']='画沙:BAAALgAECgYJCgAAAA==.',
['百富']='百富:BAAALgADCgYJBgAAAA==.',
['盛夏']='盛夏:BAAALgADCgYJBgAAAA==.',
['相忘']='相忘于江湖:BAAALgAECgQJBAAAAA==.',
['破心']='破心:BAABLgAFFH8FAAIDAAMJXhIzDQD7AAADAAMJXhIzDQD7AAAAAA==.',
['碧螺']='碧螺春水:BAAALgAECggJDgAAAA==.',
['礻申']='礻申灬禾必:BAAALgAECgIJAgAAAA==.',
['礼手']='礼手一挥:BAAALgAFFAIJAgAAAA==.',
['祁纪']='祁纪:BAACLgAFFH8KAAMNAAQJPSOGFABHAQANAAMJkySGFABHAQAOAAEJPB/iEABeAAAuAAQKfxUAAw0ACAlrJWgQAPcCAA0ABwm3JWgQAPcCAA4AAgmmI5w7AMYAAAAA.',
['秋水']='秋水一泓:BAABLgAECn8UAAQVAAgJph88HAD6AQAVAAYJUCI8HAD6AQAWAAUJVAueQwDSAAATAAgJ8x5oXgDJAAAAAA==.',
['精灵']='精灵之月:BAAALgAECgMJAwAAAA==.',
['索尓']='索尓:BAAALgAECgUJCAAAAA==.',
['紫云']='紫云悠悠:BAABLgAFFH8GAAIXAAMJmhNnEQDeAAAXAAMJmhNnEQDeAAAAAA==.',
['网恋']='网恋骑:BAAALgAECgIJAgAAAA==.',
['艾未']='艾未禄申:BAAALgADCgcJBwAAAA==.',
['艾琳']='艾琳莎尔:BAAALgADCgEJAQAAAA==.',
['芜地']='芜地涅槃:BAAALgAECgEJAQAAAA==.',
['苦命']='苦命鸳鸯:BAAALgADCgIJAgAAAA==.',
['英雄']='英雄:BAAALgADCgEJAQAAAA==.',
['苹果']='苹果哈密瓜派:BAAALgADCgQJBAAAAA==.苹果橘子派:BAAALgADCgUJBQAAAA==.苹果菠萝派:BAAALgADCgIJAgAAAA==.',
['茄咧']='茄咧菲:BAAALgADCgYJBgAAAA==.',
['萌杀']='萌杀一切:BAAALgAECgYJBgAAAA==.',
['蒂玛']='蒂玛:BAAALgADCgMJAwAAAA==.',
['见手']='见手青:BAACLgAFFH8IAAIIAAQJiQZjDQAgAQAIAAQJiQZjDQAgAQAuAAQKfxYAAggACAmxG2ssAIcCAAgACAmxG2ssAIcCAAAA.',
['贱气']='贱气长存:BAAALgAECgMJAwAAAA==.',
['赵露']='赵露思:BAAALgAECgcJBwAAAA==.',
['轻抚']='轻抚板凳腿儿:BAAALgAECgEJAQAAAA==.',
['道法']='道法子然:BAAALgADCgUJBQAAAA==.',
['遥控']='遥控器:BAAALgAECgEJAQAAAA==.',
['采采']='采采:BAAALgAECgEJAQAAAA==.',
['重病']='重病的妈:BAAALgAECgEJAQAAAA==.',
['野狗']='野狗猎手:BAAALgADCgEJAQAAAA==.',
['金小']='金小六:BAAALgAECgYJCAAAAA==.',
['锅里']='锅里没有鱼:BAAALgADCgYJBgAAAA==.',
['集火']='集火炮炮康:BAAALgADCgMJAwAAAA==.',
['青丘']='青丘皮卡丘:BAABLgAECn8rAAMPAAgJyQwjOQCdAQAPAAgJyQwjOQCdAQAYAAEJWQVVMwAuAAAAAA==.',
['青面']='青面包红苹果:BAAALgAFFAEJAgAAAA==.',
['风之']='风之庭:BAAALgAECgIJAgAAAA==.',
['风暴']='风暴大地:BAAALgAFFAIJAwAAAA==.',
['风禅']='风禅雷道:BAAALgADCgIJAgAAAA==.',
['风雪']='风雪:BAAALgADCgUJBQAAAA==.',
['飒飒']='飒飒理安:BAAALgAECgEJAgAAAA==.',
['高举']='高举锤子:BAAALgADCgYJBgAAAA==.',
['高兴']='高兴:BAAALgAFFAIJAwAAAA==.',
['鬼影']='鬼影缠身:BAAALgAFFAIJBAAAAA==.',
['黑夜']='黑夜:BAAALgADCgIJAgAAAA==.',
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
