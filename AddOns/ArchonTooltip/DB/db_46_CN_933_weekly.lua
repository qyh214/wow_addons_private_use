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

local lookup = {'Mage-Frost','DeathKnight-Unholy','DeathKnight-Blood','Evoker-Devastation','Evoker-Augmentation','Priest-Holy','DeathKnight-Frost','Paladin-Holy','DemonHunter-Devourer','Evoker-Preservation','Monk-Brewmaster','DemonHunter-Havoc','Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','Rogue-Subtlety',}
local provider = {region='CN',realm='暗影裂口',name='CN',type='weekly',zone=46,date='2026-04-25',data={Br='Brewmaster:BAAALgAECgYJBwAAAA==.',
Da='Dahlia:BAAALgAECgMJAwAAAA==.',
Gu='Guodonoo:BAABLgAFFH8GAAIBAAQJsBGvCwBYAQABAAQJsBGvCwBYAQAAAA==.',
Li='Lihyo:BAAALgAECgMJAwAAAA==.',
Ls='Lssggh:BAAALgAECgEJAQAAAA==.Lsszxc:BAAALgAECgEJAQAAAA==.',
Lu='Lucky:BAAALgAECgYJBgAAAA==.',
Ma='Maidiwen:BAAALgADCgQJBAAAAA==.',
Mo='Mortis:BAAALgAFFAQJBAAAAA==.',
Sh='Shdjsa:BAAALgAECgEJAQAAAA==.',
Sk='Skiy:BAAALgAECgcJDwAAAA==.',
St='Stuffy:BAAALgAECgkJBwABLgAFFAQJCAACABcaAA==.Stuffydk:BAABLgAECn8UAAMCAAgJbhePbACxAQACAAgJwhaPbACxAQADAAYJkxT1HgBPAQABLgAFFAQJCAACABcaAA==.Stuffyws:BAAALgAECgkJBgABLgAFFAQJCAACABcaAA==.Stuffyxd:BAAALgAECgEJAQABLgAFFAQJCAACABcaAA==.',
To='Tornado:BAABLgAFFH8FAAIDAAIJZAZGEQBoAAADAAIJZAZGEQBoAAAAAA==.',
Uh='Uhkddr:BAAALgAECgEJAQAAAA==.',
Wz='Wzq:BAAALgADCgcJBwAAAA==.',
Zi='Zifei:BAAALgAECgEJAQAAAA==.',
['一米']='一米九:BAAALgADCgQJAwAAAA==.',
['不羁']='不羁普拉:BAAALgAECgYJAwAAAA==.',
['丶丿']='丶丿雪碧刂:BAAALgAFFAIJAgAAAA==.',
['仁术']='仁术仁心:BAAALgAECgYJBgAAAA==.',
['傻不']='傻不啦叽:BAAALgAECgYJCgAAAA==.',
['凯瑞']='凯瑞甘:BAAALgAECgEJAQAAAA==.',
['剑星']='剑星:BAAALgAECgcJBwAAAA==.',
['南栀']='南栀微凉:BAAALgAECgYJBwAAAA==.',
['压力']='压力龙:BAABLgAECn8aAAMEAAcJ+hd+AwBEAQAFAAcJfRZeIwCiAQAEAAYJSRV+AwBEAQAAAA==.',
['又开']='又开始了:BAAALgADCgUJBQAAAA==.',
['向天']='向天际吧:BAAALgAECgMJAwABLgAFFAIJBQAGAN8kAA==.',
['向蒙']='向蒙哥冲锋:BAAALgADCgYJBQAAAA==.',
['周丶']='周丶烈风:BAAALgAECgMJAQAAAA==.',
['哥么']='哥么也能治疗:BAAALgADCgIJAgAAAA==.',
['喵喵']='喵喵人:BAACLgAFFH8JAAMCAAQJpB97CQCFAQACAAQJpB97CQCFAQAHAAIJGhvrAgC3AAAuAAQKfxoAAgIACAl+I1IOACgDAAIACAl+I1IOACgDAAAA.',
['四队']='四队萨满:BAAALgADCgQJBAAAAA==.',
['圣灵']='圣灵:BAAALgAECgEJAQAAAA==.',
['大爱']='大爱仙尊:BAAALgAFFAQJAQAAAA==.',
['大猛']='大猛壹:BAAALgAECgkJCQAAAA==.',
['天才']='天才龙:BAABLgAECn8WAAIFAAgJBBn4EABqAgAFAAgJBBn4EABqAgAAAA==.',
['失恋']='失恋有根据:BAAALgADCgUJBQAAAA==.',
['奥尔']='奥尔麦特:BAAALgAECgkJCQAAAA==.',
['如水']='如水丶:BAAALgAECgQJBgAAAA==.',
['娜塔']='娜塔莎丶丶:BAAALgAECgEJAQAAAA==.',
['宝宝']='宝宝楠:BAAALgAFFAIJAgAAAA==.宝宝鹏:BAAALgADCgQJBAAAAA==.',
['宝贝']='宝贝妮妮:BAAALgADCgUJBQAAAA==.',
['寒冰']='寒冰丨胜七:BAAALgAECgMJAwAAAA==.',
['小小']='小小梦点:BAAALgADCgUJBwAAAA==.',
['小愿']='小愿望:BAAALgAECgkJEQAAAA==.',
['小手']='小手一摊:BAAALgAECgEJAQAAAA==.',
['小树']='小树开花:BAAALgAECgkJCQAAAA==.',
['小熊']='小熊叔:BAAALgAECgYJCgAAAA==.',
['巨人']='巨人:BAAALgAECgMJBgAAAA==.',
['巴巴']='巴巴博一:BAAALgAECgYJDAAAAA==.',
['帅吡']='帅吡超人:BAAALgAFFAEJAQAAAA==.',
['带狼']='带狼共舞:BAAALgADCgYJCQAAAA==.',
['年轻']='年轻人吹得神:BAAALgAECgEJAQAAAA==.',
['强力']='强力奶叁:BAAALgAFFAUJAwAAAA==.强力奶壹:BAABLgAFFH8IAAIIAAQJBA1HBgAhAQAIAAQJBA1HBgAhAQABLgAFFAYJCgAIALAIAA==.强力奶贰:BAAALgAFFAQJBAABLgAFFAYJCgAIALAIAA==.强力神圣骑叁:BAABLgAFFH8HAAIIAAUJ6AyJBQCDAQAIAAUJ6AyJBQCDAQABLgAFFAYJCgAIALAIAA==.强力神圣骑肆:BAABLgAFFH8KAAIIAAYJsAhEAQDKAQAIAAYJsAhEAQDKAQAAAA==.强力骑士叁:BAAALgAFFAUJBAABLgAFFAYJCgAIALAIAA==.强力骑士肆:BAABLgAFFH8FAAIIAAUJ7gzGBQB/AQAIAAUJ7gzGBQB/AQABLgAFFAYJCgAIALAIAA==.强力骑士贰:BAAALgAFFAUJAQABLgAFFAYJCgAIALAIAA==.',
['怀疑']='怀疑龙:BAAALgAECgcJEwAAAA==.',
['怒翼']='怒翼龙:BAAALgAECgkJEAAAAA==.',
['恋如']='恋如雨止丶:BAAALgAECgYJEQAAAA==.',
['惊吓']='惊吓龙:BAABLgAECn8mAAMFAAkJYhC+JgCGAQAFAAcJcxW+JgCGAQAEAAkJeQRhLgCmAAAAAA==.',
['愿望']='愿望龙:BAABLgAECn8ZAAMFAAkJQhuGCgDNAgAFAAkJQhuGCgDNAgAEAAIJ6BHOMgB/AAAAAA==.',
['摩根']='摩根勒菲:BAABLgAFFH8MAAIJAAQJpxp2CwAjAQAJAAQJpxp2CwAjAQAAAA==.',
['攻心']='攻心:BAAALgAECgMJBgAAAA==.',
['无力']='无力龙:BAAALgAECgcJBwAAAA==.',
['日伱']='日伱嘛优:BAAALgAECgEJAQAAAA==.',
['星光']='星光龙:BAABLgAECn8cAAMEAAkJJRDCEADRAQAEAAkJwg/CEADRAQAFAAcJPREVLABfAQAAAA==.',
['星星']='星星小圣骑:BAAALgAECgEJAQAAAA==.',
['星辉']='星辉与你:BAAALgADCgcJBwAAAA==.',
['普洱']='普洱人家:BAAALgAECgEJAQAAAA==.普洱派对:BAAALgAECgEJAQAAAA==.',
['暗蓝']='暗蓝之夜:BAAALgADCgcJBwAAAA==.',
['有容']='有容丶:BAAALgAECgYJBgAAAA==.',
['木岛']='木岛理生:BAAALgADCgMJAwAAAA==.',
['来不']='来不及了:BAAALgAECgIJAgAAAA==.',
['杨老']='杨老八丶:BAAALgAECgQJBAAAAA==.',
['榨干']='榨干一滴不剩:BAABLgAFFH8HAAMKAAQJbBI/EwCSAAAKAAIJkAo/EwCSAAAFAAQJfAkVIgBKAAAAAA==.',
['欧气']='欧气满满:BAAALgAFFAQJAgAAAA==.',
['永夜']='永夜将至:BAAALgAECgIJBAAAAA==.',
['海棠']='海棠不寐:BAAALgAFFAIJAgAAAA==.',
['游戏']='游戏真难丶:BAAALgAECgQJBAAAAA==.',
['灵魂']='灵魂使者:BAAALgAECgIJAgAAAA==.',
['爱吃']='爱吃狮子头:BAABLgAFFH8FAAILAAIJmwyQEACNAAALAAIJmwyQEACNAAABLgAFFAcJGQALAP4WAA==.爱吃糖醋排骨:BAAALgAECgUJBQAAAA==.爱吃糖醋里脊:BAAALgAECgUJBgAAAA==.',
['瓦萨']='瓦萨其:BAAALgAECgEJAQAAAA==.',
['百货']='百货杨师傅:BAAALgAECgQJBgAAAA==.',
['盗火']='盗火车头:BAAALgAECgMJAwAAAA==.',
['矢吹']='矢吹守:BAABLgAECn8VAAMJAAcJUQ40cABUAQAJAAcJ8Qw0cABUAQAMAAMJGw7eVACVAAAAAA==.',
['知北']='知北游:BAAALgAECgQJBAAAAA==.',
['童虎']='童虎:BAAALgAECgQJBAAAAA==.',
['笑白']='笑白龙:BAAALgAECgIJAQAAAA==.',
['紫色']='紫色苍蝇:BAAALgAECgcJDQAAAA==.',
['绵绵']='绵绵小软糖:BAAALgAECgUJBgAAAA==.',
['美得']='美得冒泡:BAABLgAECn8YAAMGAAgJ4hyACwCYAgAGAAgJ4hyACwCYAgANAAQJ/QIWTwBTAAAAAA==.',
['老子']='老子心情不爽:BAAALgAECgYJCgAAAA==.',
['老年']='老年人玩游戏:BAAALgAECgIJAgAAAA==.',
['自由']='自由国小术:BAAALgAECgkJCQAAAA==.',
['自责']='自责龙:BAAALgAECgcJDQAAAA==.',
['菈妮']='菈妮:BAAALgAFFAIJBAABLgAFFAIJBwAKAHIdAA==.',
['蚩尤']='蚩尤:BAACLgAFFH8GAAIOAAMJNhDICwAEAQAOAAMJNhDICwAEAQAuAAQKfx0AAw4ACAlyH1cRAK4CAA4ACAlyH1cRAK4CAA8AAgkfEeV0AGoAAAAA.',
['蟹蟹']='蟹蟹没有钳:BAAALgAFFAIJAwAAAA==.',
['血之']='血之狂潮:BAAALgADCgEJAQAAAA==.',
['血祭']='血祭呼啦啦:BAAALgADCgUJBQAAAA==.',
['质疑']='质疑龙:BAAALgAECgkJEQAAAA==.',
['赤色']='赤色轨迹:BAACLgAFFH8JAAIQAAUJMiCRAQDzAQAQAAUJMiCRAQDzAQAuAAQKfx4AAhAACQmVJewAAMgDABAACQmVJewAAMgDAAAA.',
['辉冭']='辉冭郞:BAAALgAECgUJCAAAAA==.',
['逆傅']='逆傅立叶变换:BAAALgAECgQJBAABLgAFFAQJCQACAKQfAA==.',
['遗忘']='遗忘血海:BAAALgAECgQJBAAAAA==.',
['邪恶']='邪恶小契约:BAAALgAECggJCwAAAA==.',
['邵超']='邵超:BAAALgADCgYJBgAAAA==.',
['银河']='银河龙:BAABLgAECn8VAAIFAAkJQA4xKwBmAQAFAAkJQA4xKwBmAQAAAA==.',
['锅巴']='锅巴:BAAALgAFFAIJAwAAAA==.',
['锅里']='锅里炖条鱼:BAAALgADCgUJBQAAAA==.',
['阿司']='阿司匹林:BAAALgADCgcJBwAAAA==.',
['陈家']='陈家洛:BAAALgAECgMJAwAAAA==.',
['陈近']='陈近南丶:BAAALgAFFAIJAwAAAA==.',
['雷霆']='雷霆沙赞:BAAALgADCgEJAQAAAA==.',
['霜杀']='霜杀百草:BAAALgAECgUJBgAAAA==.',
['飞鸟']='飞鸟:BAABLgAFFH8HAAMKAAIJch05EQCtAAAKAAIJch05EQCtAAAFAAEJVw8XIQBOAAAAAA==.',
['鱼丸']='鱼丸丶:BAAALgADCgcJBwAAAA==.',
['鲎蠡']='鲎蠡蟹:BAAALgAECgEJAQAAAA==.',
['黑夜']='黑夜传说郎:BAAALgAECgUJCAAAAA==.',
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
