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

local lookup = {'DeathKnight-Unholy','DemonHunter-Devourer','DemonHunter-Havoc','Evoker-Augmentation','Evoker-Preservation','DemonHunter-Vengeance','Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Blood','Warrior-Protection','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Rogue-Subtlety','Rogue-Assassination','Evoker-Devastation','Mage-Frost','Unknown-Unknown','Warrior-Fury','Warrior-Arms','Warlock-Demonology','Warlock-Destruction',}
local provider = {region='CN',realm='时光之穴',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alexy:BAAALgAECgIJAgAAAA==.',
Ba='Babyjen:BAAALgAECgYJCwAAAA==.',
Bl='Blacktigerfu:BAAALgAECgcJDQAAAA==.Bliss:BAACLgAFFH8RAAIBAAQJ+SXhAwDDAQABAAQJ+SXhAwDDAQAuAAQKfxcAAgEABwmUJMgiALQCAAEABwmUJMgiALQCAAAA.Blisse:BAACLgAFFH8GAAMCAAIJxRnTJACsAAACAAIJxRnTJACsAAADAAEJkwk4DQBRAAAuAAQKfxcAAwIACAnZHGUwADoCAAIABwloGmUwADoCAAMABgm7IR4cAOABAAEuAAUUBAkRAAEA+SUA.',
Br='Broo:BAAALgAECgIJAgAAAA==.',
Cl='Claude:BAACLgAFFH8OAAICAAQJfRp8BwBIAQACAAQJfRp8BwBIAQAuAAQKfxgAAgIACAlgIhIeAJ0CAAIACAlgIhIeAJ0CAAAA.',
Da='Darkzelf:BAAALgAECgYJCAAAAA==.',
Do='Doomsday:BAAALgAECgcJAQAAAA==.',
Fr='Freaky:BAAALgAECgQJBAAAAA==.',
He='Helldiver:BAAALgAFFAEJAQAAAA==.',
Jo='Joonia:BAABLgAFFH8KAAIEAAQJLiGPAgCFAQAEAAQJLiGPAgCFAQABLgAFFAQJDgACAH0aAA==.',
Ku='Kumo:BAABLgAFFH8IAAIBAAUJ+R8JAwDXAQABAAUJ+R8JAwDXAQAAAA==.',
La='Lastshadowx:BAAALgAFFAEJAQAAAA==.',
Li='Liekkas:BAAALgAECgYJBwAAAA==.',
Lu='Luciela:BAAALgAECgMJAwAAAA==.Luolisda:BAAALgADCgEJAQABLgAFFAYJGQAFALEkAA==.',
Mm='Mmbee:BAAALgAECgMJAwAAAA==.',
Mo='Moga:BAACLgAFFH8OAAQCAAQJ2yA1AwCGAQACAAQJdR41AwCGAQADAAMJpR/HBAAcAQAGAAEJWQRoBgAvAAAuAAQKfyIAAwMACQmJHWoGAAEDAAMACAldH2oGAAEDAAIABgmVG2osAPAAAAAA.',
Oo='Ook:BAAALgAECgYJBgAAAA==.',
Pe='Perlica:BAABLgAFFH8IAAMHAAQJKxwABgBoAQAHAAQJKxwABgBoAQAIAAQJKQWUDQATAQAAAA==.',
Po='Poseidon:BAAALgAECgcJBwAAAA==.',
Ra='Rabbit:BAABLgAFFH8JAAIIAAMJjR9YDQAYAQAIAAMJjR9YDQAYAQAAAA==.Raven:BAAALgAECgYJCQAAAA==.',
Si='Sia:BAABLgAFFH8GAAIJAAQJzgw8DQBBAQAJAAQJzgw8DQBBAQAAAA==.',
So='Solar:BAAALgAECgEJAQAAAA==.',
Su='Supervegeta:BAAALgADCgUJBgAAAA==.',
Sy='Sylvana:BAAALgAECgcJBwAAAA==.',
Th='Thinker:BAAALgAECggJDgAAAA==.',
Ti='Timestory:BAAALgAECgEJAQAAAA==.',
To='Tonydariel:BAAALgAECgMJAwAAAA==.',
Wi='Windfury:BAAALgAECgYJBQAAAA==.',
Wr='Wraith:BAAALgAECgEJAQAAAA==.',
['一發']='一發入魂:BAAALgAECgEJAgAAAA==.',
['一看']='一看就是原批:BAAALgAFFAQJBAABLgAFFAUJCQAIANcMAA==.',
['七伤']='七伤拳:BAAALgAECgUJCwAAAA==.',
['三队']='三队那个猎:BAAALgAECgYJBwAAAA==.',
['上升']='上升的故乡:BAAALgAFFAIJAwAAAA==.',
['丝摩']='丝摩奈奈:BAAALgAECgEJAQAAAA==.',
['丶光']='丶光僧:BAAALgAECgEJAgAAAA==.',
['丶烤']='丶烤土豆:BAABLgAECn8WAAIBAAgJkhuHMAB2AgABAAgJkhuHMAB2AgAAAA==.丶烤玉米:BAAALgAFFAMJAwAAAA==.丶烤花菜:BAAALgAFFAEJAQAAAA==.丶烤豆角:BAAALgAFFAQJBAAAAA==.',
['丷轩']='丷轩丷:BAAALgAECgQJBgAAAA==.',
['为了']='为了帝皇:BAAALgAECgMJAwAAAA==.',
['乌尔']='乌尔奇奥拉:BAAALgAECgYJDAAAAA==.',
['二蛤']='二蛤饥渴熊:BAACLgAFFH8OAAMKAAQJZBUhEgAYAQAKAAQJZQwhEgAYAQALAAIJNRQrEQCyAAAuAAQKfx0AAgoACAkpHtEQALICAAoACAkpHtEQALICAAAA.',
['五点']='五点:BAAALgAECgEJAgAAAA==.',
['伊瑞']='伊瑞丝:BAAALgAECgQJBAAAAA==.',
['低调']='低调的猎熊人:BAAALgAECgEJAgAAAA==.',
['何事']='何事四:BAABLgAECn8dAAMBAAkJUx3ZFAD+AgABAAkJUx3ZFAD+AgAMAAIJrAYYQABNAAABLgAFFAQJBgABAL0YAA==.',
['你跺']='你跺你也麻:BAABLgAFFH8FAAINAAQJwQ3DAgApAQANAAQJwQ3DAgApAQAAAA==.',
['光拳']='光拳流:BAABLgAECn8VAAMOAAkJaRgOEACbAgAOAAkJaRgOEACbAgAPAAQJIQCQkAACAAAAAA==.',
['兔兔']='兔兔桃超猛的:BAAALgAECgkJCQAAAA==.',
['全部']='全部治愈术:BAAALgAECgMJAwAAAA==.',
['冬日']='冬日祈愿:BAAALgAECgUJBQAAAA==.',
['冰大']='冰大师寒冰:BAAALgAFFAEJAQAAAA==.',
['冰妹']='冰妹妹:BAAALgAECgQJBwAAAA==.',
['凌波']='凌波丽:BAABLgAECn8UAAMFAAYJDhq0HwCBAQAFAAUJORq0HwCBAQAEAAQJ6A7LRADLAAAAAA==.',
['刘佳']='刘佳神:BAEALgAECgQJBAAAAA==.',
['刘碧']='刘碧诚:BAAALgAFFAIJBAABLgAFFAYJGQAFALEkAA==.',
['功夫']='功夫恰恰:BAABLgAECn8UAAMPAAcJ8BivFwAnAgAPAAcJ8BivFwAnAgAQAAEJwgOALQAiAAAAAA==.',
['劲爆']='劲爆大像:BAABLgAFFH8IAAIDAAQJwiT1AAC2AQADAAQJwiT1AAC2AQAAAA==.',
['医佳']='医佳妍:BAAALgADCgYJBgAAAA==.',
['十分']='十分不理智:BAAALgAFFAEJAgAAAA==.',
['十小']='十小拖鞋十:BAAALgAECgEJAQAAAA==.',
['南瓜']='南瓜二米粥:BAAALgAFFAIJBAAAAA==.',
['卡菈']='卡菈棘语:BAAALgAECgMJAwAAAA==.',
['原批']='原批:BAABLgAFFH8MAAMHAAQJuBJQCQA7AQAHAAQJuBJQCQA7AQAIAAQJQwiUDAAlAQAAAA==.',
['又没']='又没怎么样:BAAALgADCgUJBQAAAA==.',
['古老']='古老的卷轴:BAAALgAFFAEJAQAAAA==.',
['只吃']='只吃香菜:BAAALgAECgMJAwAAAA==.',
['可乐']='可乐半糖:BAAALgAECgYJCAAAAA==.',
['可可']='可可骑士:BAAALgAECgcJDAAAAA==.',
['可怕']='可怕的熊猫:BAAALgAECgEJAQAAAA==.',
['叹息']='叹息夜星无眠:BAACLgAFFH8KAAIRAAQJrBUFBwAKAQARAAQJrBUFBwAKAQAuAAQKfxwAAxEACAmCI1APAK8CABEACAm5IFAPAK8CABIABQmrItgGAAICAAAA.',
['吃肉']='吃肉小怪兽:BAAALgAECgYJBgAAAA==.',
['哇哈']='哇哈哈一:BAAALgAECgQJBAAAAA==.',
['哈基']='哈基喵南北:BAAALgADCgEJAQAAAA==.',
['唐纳']='唐纳德表哥:BAAALgAFFAEJAQAAAA==.',
['唯一']='唯一色彩:BAAALgAECgEJAQAAAA==.',
['唯物']='唯物辩证法则:BAAALgADCgUJBQAAAA==.',
['善战']='善战的狼:BAAALgAECgEJAQAAAA==.',
['喜多']='喜多多丶:BAAALgAECgMJBAAAAA==.',
['喝血']='喝血吼烈酒:BAAALgAFFAEJAQAAAA==.',
['喵伊']='喵伊依:BAAALgADCgQJBAAAAA==.',
['回归']='回归新手:BAAALgADCgUJBQAAAA==.',
['困困']='困困鱼:BAAALgAECgMJAwAAAA==.',
['圣光']='圣光灬德:BAAALgAECgQJAgAAAA==.',
['地痞']='地痞丶狂暴:BAAALgAECgYJCQAAAA==.',
['墨疏']='墨疏影猎:BAAALgAECgUJCAAAAA==.',
['大蹄']='大蹄子牛牛:BAAALgAECgcJEgAAAA==.',
['大飞']='大飞飞:BAAALgAECgkJEQAAAA==.',
['天时']='天时地利人和:BAAALgADCgQJBAAAAA==.',
['天灾']='天灾小妖精:BAAALgAECgYJEQAAAA==.',
['天穹']='天穹仙:BAAALgAECgUJCAAAAA==.',
['太虚']='太虚幻境:BAAALgAECgIJAgAAAA==.',
['娄淩']='娄淩峰:BAAALgAFFAMJAwAAAA==.',
['宇宙']='宇宙不敌小熊:BAABLgAECn8bAAIBAAcJJxwhSwARAgABAAcJJxwhSwARAgAAAA==.宇宙罚泽:BAAALgAECgQJBQAAAA==.',
['宇法']='宇法:BAAALgAECgUJBQAAAA==.',
['宇逸']='宇逸清风:BAAALgAECggJBwAAAA==.',
['安度']='安度阴:BAAALgAECgIJAgAAAA==.',
['宫脇']='宫脇咲良:BAAALgADCgEJAQAAAA==.',
['射射']='射射大家:BAAALgAECgEJAQAAAA==.',
['小于']='小于阀值:BAAALgAECgEJAQAAAA==.',
['小咕']='小咕伊人:BAAALgAECgQJBQAAAA==.',
['小灰']='小灰灰:BAAALgAECgYJCgAAAA==.',
['小胖']='小胖打桩机:BAAALgAECgIJAwAAAA==.',
['小饭']='小饭团:BAAALgADCgEJAQAAAA==.',
['小黑']='小黑好养活:BAAALgAECgYJCgAAAA==.',
['尼卡']='尼卡多利:BAACLgAFFH8JAAINAAMJqBYNBAD5AAANAAMJqBYNBAD5AAAuAAQKfycAAg0ACAmrHzcHALcCAA0ACAmrHzcHALcCAAAA.',
['布吉']='布吉岛:BAAALgAECgEJAQAAAA==.',
['帕劳']='帕劳:BAACLgAFFH8OAAQTAAQJbxWvAgBWAQATAAQJbxWvAgBWAQAEAAIJgBErGgCZAAAFAAEJKQ8DFgBTAAAuAAQKfxgABBMABwmFHSMLACkCABMABgk3HiMLACkCAAUABwlvFVIYANEBAAQAAwkQGYhCANgAAAAA.',
['常山']='常山赵老三:BAAALgAECgQJAQAAAA==.',
['干煸']='干煸肉丝:BAAALgADCgQJBAAAAA==.',
['幽丶']='幽丶术:BAAALgADCgUJBQAAAA==.',
['弑神']='弑神六六:BAAALgAECgMJAwAAAA==.',
['张献']='张献中:BAABLgAECn8eAAIBAAgJZxvyBwAbAgABAAgJZxvyBwAbAgAAAA==.',
['张魅']='张魅力:BAAALgADCgIJAgAAAA==.',
['張百']='張百忍:BAAALgAECgYJCAAAAA==.',
['强运']='强运的回响:BAAALgAECgEJAQAAAA==.',
['影降']='影降:BAAALgAECgQJBQAAAA==.',
['德道']='德道:BAAALgAFFAEJAQAAAA==.',
['思想']='思想上的巨人:BAAALgAECgYJDwAAAA==.',
['怼怼']='怼怼丶:BAAALgADCgEJAQAAAA==.',
['恐惧']='恐惧丶公爵:BAAALgADCgEJAQAAAA==.',
['恩赐']='恩赐解救:BAAALgAECgYJBgABLgAFFAcJCAAEAEYdAA==.',
['恶丶']='恶丶术:BAAALgAECgMJAwAAAA==.',
['恶魔']='恶魔小花:BAABLgAFFH8KAAMLAAMJeiQ0BQBIAQALAAMJeiQ0BQBIAQAKAAEJShW1JwBMAAAAAA==.',
['惊蛰']='惊蛰丶:BAAALgAECgYJCgAAAA==.',
['惜惜']='惜惜的小宝贝:BAAALgAECgQJBAAAAA==.',
['我不']='我不是好人:BAAALgADCgUJBQAAAA==.',
['我会']='我会三段跳:BAAALgADCggJCQAAAA==.',
['我的']='我的刀盾:BAAALgAECgMJAwAAAA==.',
['我还']='我还没瞎透:BAAALgADCgEJAQAAAA==.',
['打起']='打起来更省心:BAABLgAFFH8KAAIUAAMJ4x6TEAAvAQAUAAMJ4x6TEAAvAQABLgAFFAQJEQABAPklAA==.',
['托尼']='托尼丨斯塔克:BAAALgAECgQJAQAAAA==.',
['托马']='托马斯爵士:BAAALgADCgEJAQAAAA==.',
['扫堂']='扫堂尾:BAAALgAFFAEJAgABLgAFFAMJBwAGAAsbAA==.',
['抓猪']='抓猪壮士:BAABLgAECn8XAAMKAAkJvQHnbwB/AAAKAAgJYAHnbwB/AAALAAkJ0wDcuABRAAAAAA==.',
['披星']='披星戴月:BAAALgADCgEJAQAAAA==.',
['拉弥']='拉弥亚丶:BAAALgAFFAIJAwAAAA==.',
['招财']='招财四猫殿下:BAAALgAECgYJDwAAAA==.',
['挚爱']='挚爱灬小天:BAAALgAECgEJAQAAAA==.',
['摩尼']='摩尼:BAAALgAECgIJAwAAAA==.',
['攀硕']='攀硕你一定邢:BAACLgAFFH8KAAIJAAUJuwpiBwB7AQAJAAUJuwpiBwB7AQAuAAQKfxYAAgkACQniFtgkAJQCAAkACQniFtgkAJQCAAAA.',
['无聊']='无聊二至极:BAAALgADCgEJAQAAAA==.',
['无色']='无色禅师:BAAALgADCgEJAQAAAA==.',
['无量']='无量:BAACLgAFFH8HAAIQAAMJCBRrCwDuAAAQAAMJCBRrCwDuAAAuAAQKfyQAAhAACAkII+kIAMYCABAACAkII+kIAMYCAAAA.',
['旺旺']='旺旺碎冰冰丶:BAAALgAECgYJCAAAAA==.',
['明镜']='明镜止水:BAAALgADCgYJCwAAAA==.',
['星光']='星光猫:BAAALgAFFAIJBAABLgAFFAIJBAAVAAAAAA==.',
['星回']='星回隐月:BAAALgAFFAIJAgAAAA==.',
['星尘']='星尘十字军:BAAALgAFFAEJAQAAAA==.',
['星穹']='星穹铁道大王:BAABLgAFFH8IAAIHAAQJUxXaBwBJAQAHAAQJUxXaBwBJAQAAAA==.',
['晨惜']='晨惜惜:BAAALgAECgcJEgAAAA==.',
['晨翕']='晨翕翕:BAAALgAECgYJCAAAAA==.',
['晨铂']='晨铂:BAAALgAECgQJBwAAAA==.',
['暗影']='暗影相随魔:BAAALgADCgcJDgAAAA==.',
['暴龙']='暴龙战神:BAABLgAFFH8MAAIDAAQJtCQCAQCyAQADAAQJtCQCAQCyAQAAAA==.',
['曙丶']='曙丶光:BAAALgAECgYJEwAAAA==.',
['曼哈']='曼哈顿博士:BAAALgADCgUJBQAAAA==.',
['最后']='最后四圈:BAAALgAECgYJBgAAAA==.',
['月隐']='月隐:BAAALgAECgUJBQAAAA==.',
['有怪']='有怪仙人上:BAAALgAECgIJBAAAAA==.',
['杀破']='杀破你:BAAALgAECgEJAQAAAA==.',
['柠萌']='柠萌小牛:BAAALgAECgcJDQAAAA==.',
['梨灬']='梨灬瞳:BAAALgAECgQJCAAAAA==.',
['死亡']='死亡如风:BAAALgADCgMJAQAAAA==.',
['氵白']='氵白夜:BAAALgAECgkJCQAAAA==.',
['永恒']='永恒黎明:BAAALgADCgQJBAAAAA==.',
['汐凤']='汐凤:BAAALgAECgEJAQAAAA==.',
['江楓']='江楓渔火:BAAALgAFFAIJAgAAAA==.',
['泡泡']='泡泡灬僧贰拾:BAABLgAFFH8GAAIOAAQJYRIvBQA/AQAOAAQJYRIvBQA/AQAAAA==.泡泡灬拾伍:BAAALgAFFAUJBAAAAA==.泡泡灬拾叁:BAAALgAFFAQJAgAAAA==.泡泡灬拾玖:BAAALgAFFAQJAQAAAA==.',
['活捉']='活捉李知恩:BAAALgAECgkJDAAAAA==.',
['流曦']='流曦:BAAALgAECgEJAQAAAA==.',
['浩浩']='浩浩丶酱:BAAALgAECgcJBwAAAA==.',
['浮浮']='浮浮众生:BAAALgADCgQJBAAAAA==.',
['海葵']='海葵:BAAALgAFFAQJBAAAAA==.',
['火拳']='火拳流:BAAALgAECgkJEAAAAA==.',
['火爆']='火爆腰花:BAAALgAECgEJAQAAAA==.',
['火花']='火花花火:BAAALgAFFAQJBAAAAA==.',
['灬辣']='灬辣辣灬:BAABLgAFFH8HAAICAAQJKwiuFQAkAQACAAQJKwiuFQAkAQAAAA==.',
['灼眼']='灼眼夏翎娜:BAAALgAECgMJAQAAAA==.',
['烟灰']='烟灰儿:BAAALgAECgEJAQAAAA==.',
['焦糖']='焦糖摩卡:BAAALgAECgcJBgAAAA==.',
['熊武']='熊武有力:BAAALgAECgcJCwAAAA==.',
['爱吃']='爱吃蓝莓:BAAALgAFFAMJAwAAAA==.',
['特龙']='特龙娜米:BAAALgAECgYJCQAAAA==.',
['狂战']='狂战神乐:BAAALgAECgEJAQAAAA==.',
['独孤']='独孤真人:BAAALgADCgQJBAAAAA==.',
['猫猫']='猫猫森丶:BAABLgAFFH8GAAIUAAIJIh/dNADDAAAUAAIJIh/dNADDAAAAAA==.',
['玛尔']='玛尔斯:BAACLgAFFH8HAAIWAAQJYgghDQA1AQAWAAQJYgghDQA1AQAuAAQKfxkAAxYACQkLHAMRAMgCABYACQlZGgMRAMgCABcAAQkCINUzAGIAAAEuAAUUBgkNAAkA2RkA.',
['瓦塔']='瓦塔诺:BAAALgADCgQJBAAAAA==.',
['生于']='生于忧患:BAAALgAECgEJAQAAAA==.',
['疾风']='疾风骑士:BAAALgADCgUJBQAAAA==.',
['白月']='白月光丶:BAAALgAECgQJBAAAAA==.',
['白梦']='白梦妍:BAAALgAECgIJAwAAAA==.',
['白衣']='白衣依旧:BAAALgAECgYJCAAAAA==.白衣如歌:BAAALgADCgQJBAAAAA==.',
['皮卡']='皮卡皮卡:BAAALgAFFAIJAwAAAA==.皮卡超:BAAALgAFFAEJAQAAAA==.',
['碧脸']='碧脸迷人:BAAALgAECgEJAQAAAA==.',
['祖母']='祖母的辣椒油:BAAALgAECgUJBQAAAA==.',
['神乐']='神乐胧月:BAAALgAECgQJBQAAAA==.',
['神木']='神木丽丶:BAABLgAFFH8MAAIJAAQJkiAVAwB1AQAJAAQJkiAVAwB1AQAAAA==.',
['秋序']='秋序丶廿四:BAAALgAECgYJDAAAAA==.',
['秋醉']='秋醉夜向阑丷:BAAALgAECgYJCQAAAA==.',
['秦谷']='秦谷美铃:BAAALgAECgQJCQAAAA==.',
['穆汗']='穆汗穆德:BAAALgADCgUJBQAAAA==.',
['空椅']='空椅子:BAAALgAECgEJAgAAAA==.',
['立冬']='立冬大寒:BAABLgAFFH8FAAIJAAMJAw7jFgD2AAAJAAMJAw7jFgD2AAAAAA==.',
['笨笨']='笨笨的小尾巴:BAAALgAECgEJAgAAAA==.',
['筱筱']='筱筱宇:BAAALgAECgYJBgAAAA==.',
['米哈']='米哈游启动器:BAABLgAFFH8MAAMHAAQJ8Rf0BwBIAQAHAAQJ8Rf0BwBIAQAIAAQJNwioDAAkAQAAAA==.',
['米籣']='米籣的大铁匠:BAAALgADCgUJBgAAAA==.米籣的小铁匠:BAAALgAECgYJDgAAAA==.',
['糊丶']='糊丶糊:BAAALgAECgUJBQAAAA==.',
['红柚']='红柚:BAAALgAECgYJDQAAAA==.',
['纯欲']='纯欲性感小妈:BAAALgAECgUJCAAAAA==.',
['绝区']='绝区零高手:BAABLgAFFH8IAAMHAAQJkxC0CQA3AQAHAAQJkxC0CQA3AQAIAAQJqwlbDAAoAQAAAA==.',
['美妮']='美妮美妮:BAAALgAECgEJAgAAAA==.',
['耀丶']='耀丶璀:BAAALgADCgEJAQAAAA==.',
['老九']='老九:BAAALgAECgIJAgAAAA==.',
['老狼']='老狼孩:BAAALgAECgMJAwAAAA==.',
['肾骑']='肾骑士:BAAALgAECgMJAwAAAA==.',
['背叛']='背叛者伊利达:BAAALgADCgMJAwAAAA==.',
['脏死']='脏死你的圣光:BAABLgAECn8VAAICAAYJkh66QgDpAQACAAYJkh66QgDpAQAAAA==.',
['自由']='自由颂:BAAALgADCgIJAgAAAA==.',
['致命']='致命猎手:BAAALgADCgIJAgAAAA==.',
['舔狗']='舔狗长不高:BAAALgAECgEJAQAAAA==.',
['芭比']='芭比皮皮虾:BAAALgAECgYJBgAAAA==.',
['范达']='范达尔丶锅盔:BAABLgAFFH8FAAIBAAIJLxOsPACkAAABAAIJLxOsPACkAAAAAA==.',
['荒野']='荒野打扑克:BAAALgAECgEJAQAAAA==.',
['菇龙']='菇龙:BAAALgAECgQJBAAAAA==.',
['菜鸡']='菜鸡伍陆柒:BAAALgAECgcJBwAAAA==.',
['萝卜']='萝卜历史:BAAALgAECgMJAwABLgAFFAYJGQAFALEkAA==.',
['萨拉']='萨拉塔斯:BAAALgAECgQJCgAAAA==.',
['萨菲']='萨菲拉格斯:BAAALgADCgIJAgAAAA==.',
['落叶']='落叶惊残梦:BAABLgAFFH8IAAIJAAQJzBr2CABnAQAJAAQJzBr2CABnAQABLgAFFAYJEgABAKckAA==.',
['董小']='董小沫:BAABLgAFFH8JAAICAAMJBxyXDgADAQACAAMJBxyXDgADAQAAAA==.',
['蕾蕾']='蕾蕾闹不住:BAAALgAECgUJDgAAAA==.',
['虹猫']='虹猫:BAAALgADCgEJAQAAAA==.',
['袄糟']='袄糟灬法斯:BAAALgADCgcJBwAAAA==.',
['裂尐']='裂尐君:BAAALgADCgQJBAAAAA==.',
['西瑪']='西瑪:BAAALgAECgYJBgAAAA==.',
['诗情']='诗情:BAAALgADCgUJBQAAAA==.',
['贫僧']='贫僧略懂拳脚:BAAALgAFFAIJAgAAAA==.',
['赫拉']='赫拉纳斯:BAAALgAECgQJBQAAAA==.',
['赶路']='赶路的人:BAAALgADCgMJAwAAAA==.',
['超级']='超级小狼猎:BAAALgAECgEJAQAAAA==.',
['还是']='还是没想好:BAAALgADCgQJBAAAAA==.',
['还有']='还有高手:BAABLgAFFH8IAAICAAQJgA5KEwA3AQACAAQJgA5KEwA3AQAAAA==.',
['迷你']='迷你酱:BAABLgAFFH8IAAMYAAMJyxMtNwClAAAYAAIJgBctNwClAAAZAAEJYQwrFgBSAAAAAA==.',
['道可']='道可道丶:BAAALgAECgYJBgAAAA==.',
['那個']='那個慕师:BAAALgADCgUJBQAAAA==.',
['那只']='那只丶胖熊猫:BAAALgADCgUJBQAAAA==.',
['部龙']='部龙丶术:BAAALgADCgEJAQAAAA==.',
['酒剑']='酒剑随马:BAAALgAECgEJAQAAAA==.',
['重生']='重生天才少女:BAAALgAECgEJAgAAAA==.',
['铁掌']='铁掌风清:BAAALgAECgEJAQAAAA==.',
['铁腿']='铁腿水上漂:BAAALgAECgIJBAAAAA==.',
['长河']='长河落日圆:BAAALgAECgQJBAAAAA==.',
['阿基']='阿基维利:BAAALgADCgEJAgAAAA==.',
['阿尔']='阿尔飒思:BAAALgAECgQJBAAAAA==.',
['阿札']='阿札里斯特咪:BAAALgAECgEJAQAAAA==.',
['阿毛']='阿毛儿:BAAALgAECgYJEQAAAA==.',
['陈平']='陈平安灬:BAAALgAFFAQJBAAAAA==.',
['陶猫']='陶猫猫:BAACLgAFFH8QAAIHAAUJqg8KCgAzAQAHAAUJqg8KCgAzAQAuAAQKfyEAAgcACQndFHUaAEQCAAcACQndFHUaAEQCAAAA.',
['随便']='随便看看:BAAALgAECgEJAQAAAA==.',
['霜之']='霜之哀伤:BAABLgAFFH8FAAIBAAMJ0w1zKgDxAAABAAMJ0w1zKgDxAAAAAA==.',
['霸王']='霸王龙扎克:BAAALgAECgIJAgAAAA==.',
['风拳']='风拳流:BAAALgAECgkJEAAAAA==.',
['风风']='风风酱:BAAALgAECgkJCAABLgAFFAUJBQAOAFgQAA==.',
['飞盾']='飞盾侠杰瑞:BAAALgAECgcJAQAAAA==.',
['饲养']='饲养员灬跟班:BAABLgAECn8VAAIHAAYJISR2FQBqAgAHAAYJISR2FQBqAgAAAA==.',
['馒头']='馒头队长:BAAALgAECgMJAwAAAA==.',
['高手']='高手遇上瞎子:BAAALgAECgUJBgAAAA==.',
['鬊鸟']='鬊鸟:BAAALgAECgcJDwAAAA==.',
['魍魉']='魍魉妖牧:BAAALgAECgUJBQAAAA==.',
['龍騎']='龍騎士:BAAALgAFFAIJBAAAAA==.',
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
