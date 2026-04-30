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

local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Devastation','Evoker-Preservation','Unknown-Unknown','Paladin-Holy','Paladin-Retribution','Mage-Frost','Druid-Feral','Evoker-Augmentation','DeathKnight-Unholy','DeathKnight-Blood','DemonHunter-Devourer','DemonHunter-Havoc','Priest-Discipline','Monk-Mistweaver','Druid-Restoration','Shaman-Restoration','Warlock-Demonology','Priest-Holy','Rogue-Subtlety','Priest-Shadow','Druid-Balance','Shaman-Elemental','DeathKnight-Frost','Mage-Arcane','Mage-Fire','Monk-Windwalker','Monk-Brewmaster','Warrior-Protection','Druid-Guardian','Warlock-Destruction','Warlock-Affliction','Warrior-Fury','Warrior-Arms','Paladin-Protection','Hunter-Survival',}
local provider = {region='CN',realm='利刃之拳',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akiravv:BAAALgAECgcJCwAAAA==.',
Al='Aleksib:BAAALgAECgkJCQAAAA==.',
Am='Americe:BAAALgADCgQJAgAAAA==.',
An='Annya:BAAALgAECgcJDwAAAA==.Anyaforger:BAAALgAECgkJDwAAAA==.',
Ar='Arrowdeath:BAABLgAECn8WAAMBAAcJlRqIMgDlAQABAAcJlRqIMgDlAQACAAEJYAD1mgAWAAAAAA==.',
Az='Azurastar:BAAALgAECgEJAQAAAA==.',
Ba='Bahamutej:BAAALgAECgQJBAAAAA==.',
Ca='Cadian:BAAALgAFFAQJBAAAAA==.',
Co='Conrinue:BAAALgADCgUJBQAAAA==.Cortanal:BAAALgAECgQJBQAAAA==.',
De='Deathwalker:BAAALgADCgEJAQAAAA==.Delores:BAAALgAECgYJCQAAAA==.Demilichw:BAAALgAECgYJCwAAAA==.',
Di='Diodiodiodio:BAAALgAFFAEJAQAAAA==.',
Do='Donk:BAABLgAECn9+AAMDAAkJ5RYpBgCUAgADAAkJ5RYpBgCUAgAEAAcJCRnKFAD7AQABLgAFFAQJBAAFAAAAAA==.',
['Dò']='Dòpe:BAAALgAECgEJAQAAAA==.',
Ea='Easonhu:BAAALgAECgEJAQAAAA==.',
Eu='Euroone:BAAALgAFFAMJAwAAAA==.',
Go='Gobins:BAAALgAECgEJAQAAAA==.',
He='Healde:BAAALgAFFAQJBAAAAA==.Heat:BAAALgAECgUJBgAAAA==.',
Ho='Horrorsword:BAAALgAECgMJBgAAAA==.',
Im='Imfine:BAAALgADCgUJBQAAAA==.',
Ja='Janneflus:BAABLgAFFH8QAAIGAAUJgCTUAQDrAQAGAAUJgCTUAQDrAQAAAA==.',
Kd='Kddi:BAABLgAECn8VAAIHAAYJhQ/fmABMAQAHAAYJhQ/fmABMAQAAAA==.',
Ku='Kunny:BAAALgAECgQJBAAAAA==.',
La='Lalabu:BAAALgAECgIJAgAAAA==.',
Lo='Lonevely:BAAALgAECgYJCQAAAA==.Lonewolf:BAAALgAECgEJAQAAAA==.Lonewolfc:BAAALgAECgMJBQAAAA==.',
Lu='Luciferyf:BAAALgAECgMJAgAAAA==.',
Ma='Mackinderjoy:BAAALgADCgMJAwAAAA==.',
Me='Mecraches:BAAALgAECgcJBwABLgAFFAQJAwAFAAAAAA==.',
Mo='Moneyorange:BAABLgAECn8UAAIIAAcJ8CJ0CQASAgAIAAcJ8CJ0CQASAgAAAA==.',
My='My:BAAALgADCgQJBAAAAA==.',
Na='Nastykikoz:BAAALgAECgQJAgAAAA==.',
No='Nongshali:BAAALgAECgcJDQABLgAFFAEJAQAFAAAAAA==.',
Or='Oreoman:BAAALgAECgYJDQAAAA==.',
Ou='Ouou:BAAALgAECgYJDQAAAA==.',
Po='Poohboy:BAAALgADCgEJAQAAAA==.',
Re='Ress:BAAALgAECgIJAwAAAA==.',
Ro='Ropz:BAAALgAECgEJAQABLgAFFAQJBAAFAAAAAA==.',
Sa='Sanparker:BAACLgAFFH8OAAIJAAQJixl8AABsAQAJAAQJixl8AABsAQAuAAQKfxoAAgkABgn9IvUHAGUCAAkABgn9IvUHAGUCAAAA.Sarahllosa:BAACLgAFFH8QAAMBAAQJAyVDAACsAQABAAQJAyVDAACsAQACAAMJsx1UEgAVAQAuAAQKfx4AAwEACAkuJnoCAHEDAAEACAm3JXoCAHEDAAIABgnnIhkiABICAAAA.Sarre:BAAALgAECgEJAQAAAA==.',
Se='Senky:BAAALgAFFAEJAQAAAA==.',
Si='Sivalancedk:BAAALgAECgQJBgAAAA==.',
Sm='Smash:BAAALgAECgkJCQAAAA==.',
So='Sosick:BAAALgAECgUJBQAAAA==.',
Su='Succubia:BAAALgAFFAEJAQAAAA==.',
Va='Vasilisa:BAACLgAFFH8HAAMKAAUJARNNEgDtAAAKAAQJARNNEgDtAAADAAEJAADcAwAAAAAuAAQKfyEAAwoACQm2HukJANcCAAoACQm2HukJANcCAAMABgnPFUEdAEQBAAAA.',
Wo='Wowhh:BAAALgADCgUJBwAAAA==.',
Yi='Yinle:BAAALgAECgEJAQAAAA==.',
Yj='Yjjpaopao:BAAALgAFFAIJAgAAAA==.',
Yu='Yudy:BAAALgADCgMJAwAAAA==.',
Zy='Zylla:BAAALgAECgcJBQAAAA==.',
Zz='Zzywoo:BAAALgAECgkJDwAAAA==.',
['一个']='一个踏风:BAAALgADCggJCwAAAA==.',
['一倾']='一倾丶:BAAALgAFFAIJAwAAAA==.',
['一勺']='一勺三花淡奶:BAAALgADCgUJBQAAAA==.',
['一千']='一千纸鹤:BAAALgAECgEJAQAAAA==.',
['一只']='一只小梨花丶:BAAALgADCgYJBgAAAA==.',
['一叶']='一叶之秋:BAAALgADCgUJBQAAAA==.',
['一梦']='一梦险神:BAAALgAECgQJBQAAAA==.',
['一棍']='一棍子顶死你:BAAALgAECgcJBwAAAA==.',
['一瓶']='一瓶牛二:BAAALgAFFAIJAgAAAA==.',
['一竿']='一竿子顶傻你:BAAALgAFFAEJAQAAAA==.',
['一纸']='一纸行书:BAAALgAECgYJBgAAAA==.',
['七岁']='七岁:BAAALgADCgEJAQAAAA==.',
['七海']='七海渡风:BAACLgAFFH8GAAILAAIJgSONMADLAAALAAIJgSONMADLAAAuAAQKfyIAAwsACAlVJpQGAG8DAAsACAlVJpQGAG8DAAwABAnQARk6AHIAAAEuAAUUBQkEAAUAAAAA.',
['三个']='三个酒仙:BAAALgAECgcJDwAAAA==.',
['下顿']='下顿我吃:BAAALgAFFAMJAwABLgAFFAUJEgADAKohAA==.',
['不奶']='不奶薛迪凯吗:BAAALgAFFAIJAgAAAA==.',
['不辛']='不辛苦命苦:BAAALgAECgEJAQAAAA==.',
['不锝']='不锝不爱:BAAALgAECgYJEQAAAA==.',
['世壹']='世壹僧:BAAALgAFFAQJAwAAAA==.',
['东城']='东城莉奥丶:BAAALgAECgYJBwAAAA==.',
['东方']='东方圣:BAAALgAECgUJBwAAAA==.',
['东船']='东船:BAAALgAECgMJAwAAAA==.',
['両儀']='両儀丿式:BAACLgAFFH8NAAMNAAQJAhErEwA4AQANAAQJAhErEwA4AQAOAAEJlxLGDABUAAAuAAQKfyIAAw4ACAnyIBEMAKACAA0ACAlcHTkZAL0CAA4ACAnPIBEMAKACAAAA.',
['两瓶']='两瓶牛二:BAAALgAECgMJAwAAAA==.',
['丨志']='丨志平啊志平:BAAALgADCgkJDQAAAA==.',
['丨思']='丨思念灬:BAAALgADCgIJAgAAAA==.',
['丨暮']='丨暮色丨:BAAALgAECgIJAgAAAA==.',
['中二']='中二的橙汁:BAAALgAECgcJBgAAAA==.',
['丶保']='丶保熟的瓜:BAAALgAECgUJDQAAAA==.',
['丶妙']='丶妙妙:BAABLgAFFH8GAAIPAAMJ4Q8ZDgDrAAAPAAMJ4Q8ZDgDrAAAAAA==.',
['丶礼']='丶礼弥:BAAALgAECgIJAwAAAA==.',
['丶萌']='丶萌娜丽莎:BAAALgAECgYJCgAAAA==.丶萌娜莉莎:BAAALgAECgMJBAAAAA==.',
['丶遨']='丶遨游四海:BAAALgAFFAQJAQAAAA==.',
['丷晴']='丷晴晴:BAAALgAECgcJBwABLgAFFAkJBgAQALgTAA==.',
['丸辣']='丸辣:BAAALgADCgYJCgAAAA==.',
['举高']='举高高:BAAALgADCgEJAQAAAA==.',
['丿灬']='丿灬戮灬:BAACLgAFFH8IAAILAAMJ0Q/BDwD6AAALAAMJ0Q/BDwD6AAAuAAQKfxgAAgsABglKH0pnAL8BAAsABglKH0pnAL8BAAAA.',
['乌啦']='乌啦:BAAALgAECgkJEAAAAA==.',
['乔克']='乔克力哒:BAAALgAECgUJBwAAAA==.',
['二阶']='二阶堂希罗:BAAALgAECgUJCQAAAA==.',
['云中']='云中鹤:BAAALgAECgUJBgAAAA==.',
['云无']='云无月:BAABLgAFFH8GAAIIAAMJ2yR4IABEAQAIAAMJ2yR4IABEAQABLgAFFAUJEgAIAKYZAA==.',
['云踪']='云踪:BAAALgADCgUJBQAAAA==.',
['五岁']='五岁就很帅:BAAALgAFFAIJBAABLgAFFAQJBwABAGoRAA==.',
['五红']='五红土松:BAAALgAECgYJAQAAAA==.',
['亲亲']='亲亲我的脸蛋:BAAALgADCgUJBQAAAA==.',
['仰战']='仰战圣光:BAAALgAECgEJAgAAAA==.',
['伊丽']='伊丽:BAAALgAECgEJAQAAAA==.',
['伊利']='伊利旦丶怒风:BAAALgADCgUJBQAAAA==.',
['伊力']='伊力老窖:BAAALgAECgMJBAAAAA==.',
['伊萊']='伊萊客斯:BAAALgAECgEJAQAAAA==.',
['伍佰']='伍佰锤锤:BAAALgAECgYJBgAAAA==.',
['伏黑']='伏黑甚尔:BAAALgAECgIJAgABLgAFFAMJBQANAA0YAA==.',
['余额']='余额丨不足:BAAALgAECgEJAQAAAA==.余额丶囧囧:BAAALgADCgcJDAAAAA==.',
['佛主']='佛主打豆豆:BAAALgADCgEJAQAAAA==.',
['你是']='你是猪:BAAALgADCgEJAQAAAA==.',
['你男']='你男票真好用:BAAALgADCgcJDAAAAA==.',
['你耳']='你耳龙吗:BAAALgAECgYJBgABLgAFFAQJBwARAJYmAA==.',
['依然']='依然乄尐盟:BAACLgAFFH8NAAISAAQJYCJiBACLAQASAAQJYCJiBACLAQAuAAQKfxoAAhIACQksITsDAEcDABIACQksITsDAEcDAAAA.',
['俺似']='俺似娇花儿:BAAALgADCgEJAQAAAA==.',
['僷舞']='僷舞:BAAALgAECgQJBAAAAA==.',
['元宝']='元宝的臭臭蛋:BAAALgAECgIJAwAAAA==.',
['元芳']='元芳:BAAALgAECgcJDAAAAA==.',
['先吃']='先吃饭吧:BAAALgADCgcJBwABLgADCgcJBwAFAAAAAA==.',
['克州']='克州多情拐:BAAALgAECgEJAQAAAA==.',
['全民']='全民燒锅炉:BAAALgAECgMJBAAAAA==.',
['全真']='全真猫猫教:BAAALgAECgYJCwAAAA==.',
['八云']='八云乄火烁虫:BAAALgAECgEJAQAAAA==.',
['八色']='八色鸫:BAABLgAFFH8FAAITAAIJJRA4NACqAAATAAIJJRA4NACqAAAAAA==.',
['关于']='关于小熊:BAAALgAECgUJBQAAAA==.',
['冰淇']='冰淇淋丶:BAABLgAFFH8LAAIKAAQJ7hPuCgBHAQAKAAQJ7hPuCgBHAQAAAA==.',
['冰火']='冰火大颗粒:BAAALgADCgEJAQAAAA==.',
['冲锋']='冲锋小瓜:BAAALgADCgEJAQAAAA==.冲锋是种信仰:BAAALgAECgcJEQAAAA==.',
['冻住']='冻住不洗澡:BAAALgAECgcJBwAAAA==.',
['凛冽']='凛冽之心:BAAALgAECgIJAgAAAA==.',
['几梦']='几梦华胥舞:BAABLgAFFH8HAAIGAAQJkA3RCgAwAQAGAAQJkA3RCgAwAQAAAA==.',
['凯瑞']='凯瑞甘:BAAALgADCgMJAwABLgADCgMJAwAFAAAAAA==.',
['刀锋']='刀锋浪子:BAAALgAECgcJDgAAAA==.',
['刘丶']='刘丶海柱:BAAALgAECgEJAQAAAA==.',
['刘嗨']='刘嗨柱:BAAALgAECgkJEAAAAA==.',
['初衷']='初衷生:BAACLgAFFH8FAAIRAAIJAhcWGQCZAAARAAIJAhcWGQCZAAAuAAQKfxQAAhEABgkMIFwkACkCABEABgkMIFwkACkCAAAA.',
['初见']='初见:BAAALgAECgEJAQAAAA==.',
['利刃']='利刃矮法:BAAALgAECgYJCgAAAA==.',
['利维']='利维坦:BAAALgAECgYJBgAAAA==.',
['别情']='别情遥:BAAALgAECgIJAgAAAA==.',
['剑抵']='剑抵心扉:BAAALgAECgQJBAAAAA==.',
['剩蛋']='剩蛋老人:BAAALgAECgkJCgAAAA==.',
['加尔']='加尔兽什:BAAALgAECgcJBwAAAA==.',
['十六']='十六缸发动机:BAACLgAFFH8HAAILAAMJ7RUsKQD0AAALAAMJ7RUsKQD0AAAuAAQKfxQAAgsABwlgF7hbAN8BAAsABwlgF7hbAN8BAAAA.',
['十胜']='十胜石旁泪:BAABLgAECn8fAAIHAAgJGSSvDAAoAwAHAAgJGSSvDAAoAwAAAA==.',
['十里']='十里秦淮:BAAALgAECgEJAgAAAA==.',
['半夏']='半夏微凉:BAAALgAECgEJAQAAAA==.',
['半岛']='半岛丶:BAAALgAECgQJBAAAAA==.',
['单刷']='单刷虎:BAAALgAECgEJAQAAAA==.',
['南北']='南北绿豆:BAAALgAECgQJAwAAAA==.南北绿豆汤:BAAALgAECgIJAwAAAA==.',
['南墙']='南墙的回响:BAAALgAFFAIJAgAAAA==.南墙的安宝:BAAALgAECgkJBwAAAA==.',
['南风']='南风蘸酱:BAAALgADCgMJAwAAAA==.',
['博熙']='博熙宝贝:BAAALgAECgUJCQAAAA==.',
['卤煮']='卤煮:BAAALgADCgQJBAAAAA==.',
['厚牛']='厚牛皮:BAAALgADCgcJBwAAAA==.',
['双马']='双马尾:BAAALgADCgIJAgAAAA==.',
['发牌']='发牌员鲍勃:BAAALgAECgUJBwAAAA==.',
['只想']='只想去浪:BAAALgAECgEJAQAAAA==.',
['叫我']='叫我二姐夫:BAAALgAECgEJAQAAAA==.叫我威龙:BAAALgAECgUJCwAAAA==.',
['叮叮']='叮叮小橙子:BAAALgAECgEJAQAAAA==.',
['叮噹']='叮噹喵:BAAALgAECgEJAwAAAA==.',
['可丶']='可丶乐要加冰:BAAALgADCgYJBgAAAA==.',
['可乐']='可乐丶要加冰:BAABLgAFFH8HAAIRAAIJ2SBGFQC5AAARAAIJ2SBGFQC5AAAAAA==.可乐要加冰丶:BAACLgAFFH8HAAISAAMJZx4+DAAWAQASAAMJZx4+DAAWAQAuAAQKfxgAAhIACAkIIKkBAJ0CABIACAkIIKkBAJ0CAAAA.',
['可怜']='可怜的小四:BAAALgAECgkJCQAAAA==.',
['台笑']='台笑大方:BAAALgAECgkJCgAAAA==.',
['史诗']='史诗圣光旌旗:BAABLgAFFH8FAAILAAQJsyHNFQBMAQALAAQJsyHNFQBMAQAAAA==.',
['叶当']='叶当当丶:BAACLgAFFH8OAAISAAQJRwksCwAmAQASAAQJRwksCwAmAQAuAAQKfyMAAhIACAk5Gu4bADkCABIACAk5Gu4bADkCAAAA.',
['吉井']='吉井玲:BAABLgAFFH8HAAIUAAMJ6ROFCADgAAAUAAMJ6ROFCADgAAAAAA==.',
['同归']='同归殊途之吟:BAAALgAECgQJBAAAAA==.',
['同葬']='同葬无光之愿:BAAALgAECggJAwAAAA==.',
['后知']='后知后覚:BAABLgAFFH8NAAMPAAUJoB+oAgDoAQAPAAUJoB+oAgDoAQAUAAEJdQj5EgBNAAAAAA==.',
['吕玲']='吕玲绮:BAAALgAFFAQJAQAAAA==.',
['吻舞']='吻舞双全:BAAALgADCgYJBgAAAA==.',
['吼爷']='吼爷:BAAALgAECgcJDQAAAA==.',
['吾重']='吾重:BAAALgAECgYJCQAAAA==.',
['呆呆']='呆呆喵呢喵:BAAALgAECgQJBQAAAA==.',
['味大']='味大熏:BAAALgADCgIJAgAAAA==.',
['哈妮']='哈妮克孜:BAAALgAECgYJEAAAAA==.',
['哈无']='哈无搞:BAAALgAFFAIJAgAAAA==.',
['响叮']='响叮当:BAAALgAFFAEJAQAAAA==.',
['唤雨']='唤雨者:BAAALgAECgQJBAAAAA==.',
['啊圣']='啊圣光:BAAALgADCgEJAgAAAA==.',
['嗨曦']='嗨曦:BAAALgAECgYJCwAAAA==.',
['嗷呜']='嗷呜喵:BAAALgAECgMJAwAAAA==.',
['图图']='图图公主:BAAALgAECgcJDQAAAA==.图图无敌啦丶:BAAALgAECgYJCgAAAA==.',
['圈圈']='圈圈小法:BAAALgAECgkJBwAAAA==.',
['圣光']='圣光土豆:BAAALgAFFAIJAwAAAA==.圣光护佑你:BAABLgAECn8UAAIHAAYJwxVGawCoAQAHAAYJwxVGawCoAQAAAA==.圣光猎魔:BAAALgADCgMJAwAAAA==.',
['城下']='城下之盟:BAACLgAFFH8MAAIPAAUJzQqhBgB2AQAPAAUJzQqhBgB2AQAuAAQKfx4AAhQACAnUIawFAPUCABQACAnUIawFAPUCAAAA.',
['堪忧']='堪忧踹:BAAALgAFFAIJBAAAAA==.',
['墨漓']='墨漓:BAAALgAECgEJAQAAAA==.',
['壮骨']='壮骨粉:BAAALgAECgIJAgAAAA==.',
['壹条']='壹条龍服務:BAAALgAECgEJAQAAAA==.',
['夏夜']='夏夜萤火虫:BAAALgADCgcJBwAAAA==.',
['夏天']='夏天暴风雪:BAAALgAECgMJAgAAAA==.',
['夏沫']='夏沫丶烟雨:BAAALgAFFAIJBAAAAA==.',
['多啦']='多啦爱萌:BAAALgAECgYJAwAAAA==.',
['夜想']='夜想曲:BAAALgAECgMJAwAAAA==.',
['夜曲']='夜曲:BAAALgAECgQJBgAAAA==.',
['夜月']='夜月追风:BAAALgAECgQJAwAAAA==.',
['夜落']='夜落狐狐:BAAALgAECgkJEQAAAA==.',
['大丶']='大丶地瓜:BAAALgAFFAIJAgAAAA==.',
['大嗨']='大嗨晒的圣主:BAAALgADCgEJAQAAAA==.',
['大捻']='大捻晒的射手:BAAALgADCgEJAQAAAA==.',
['大梦']='大梦想家乘凉:BAAALgADCgcJBwAAAA==.',
['大橘']='大橘大橘呢:BAABLgAECn8ZAAMUAAcJPBOeKQClAQAUAAcJPBOeKQClAQAPAAIJzgnvTABgAAAAAA==.大橘猫:BAAALgAECgYJDAAAAA==.大橘猫不吃鱼:BAAALgAECgYJCAAAAA==.',
['大漠']='大漠补给站:BAAALgAECgIJAgAAAA==.',
['大超']='大超老师:BAAALgAFFAQJBAAAAA==.',
['天上']='天上白玉京:BAAALgAFFAQJBAAAAA==.',
['天下']='天下一丑:BAAALgADCgUJBQAAAA==.',
['天天']='天天翻车:BAABLgAFFH8LAAIQAAYJFBuGAQAlAgAQAAYJFBuGAQAlAgAAAA==.',
['天授']='天授唱诗人:BAAALgADCgUJBgAAAA==.',
['天氣']='天氣晴:BAAALgAECgYJCgABLgAECgcJBgAFAAAAAA==.',
['天火']='天火烈焰:BAAALgAECgcJBgAAAA==.',
['天苍']='天苍澪:BAAALgAECgEJAgAAAA==.',
['太阳']='太阳肩并肩:BAAALgAECgEJAgAAAA==.',
['奈何']='奈何桥边喝茶:BAAALgAECgEJAQAAAA==.',
['奔雷']='奔雷手成雄:BAAALgAECgYJBwAAAA==.奔雷手陈熊丶:BAABLgAFFH8HAAIVAAMJYSF2CwAuAQAVAAMJYSF2CwAuAQAAAA==.奔雷手陳熊:BAAALgAECgIJAgAAAA==.',
['奥术']='奥术大王丶:BAABLgAFFH8FAAIIAAIJhx6uNADFAAAIAAIJhx6uNADFAAAAAA==.',
['女一']='女一号:BAAALgAECgYJBgAAAA==.',
['奶牛']='奶牛的奶:BAAALgAECgEJAgAAAA==.',
['奶香']='奶香萨摩耶:BAAALgAFFAUJAwAAAA==.',
['好客']='好客的亚楠人:BAACLgAFFH8LAAIWAAQJmRWmBgBcAQAWAAQJmRWmBgBcAQAuAAQKfxUAAhYABwk6H8ASAGECABYABwk6H8ASAGECAAAA.',
['如意']='如意最可爱丶:BAAALgADCgEJAQAAAA==.',
['妮瑟']='妮瑟:BAAALgAECgEJAQAAAA==.',
['姘头']='姘头就是朕:BAAALgAECgEJAQAAAA==.',
['娜仁']='娜仁图亚:BAAALgAECgUJBQAAAA==.',
['孙尚']='孙尚香妹妹:BAAALgAECgYJBwAAAA==.',
['孤独']='孤独的熊猫:BAABLgAECn8YAAMUAAcJHBtCBgC0AQAUAAcJHBtCBgC0AQAWAAMJ0whsTwCTAAAAAA==.',
['宅灬']='宅灬尐玥:BAAALgAECgcJBwABLgAFFAUJBQAOAP4TAA==.',
['宇宙']='宇宙小饼干:BAAALgAECgYJCwAAAA==.',
['安娜']='安娜杰:BAAALgAECgMJBAAAAA==.安娜科穆宁:BAAALgAECgEJAQAAAA==.',
['安静']='安静的小木瓜:BAAALgAFFAEJAQAAAA==.安静的库仑力:BAAALgAFFAMJBAAAAA==.',
['宋老']='宋老板:BAACLgAFFH8FAAMWAAIJtwX7EACcAAAWAAIJtwX7EACcAAAPAAEJlAH2DAA4AAAuAAQKfxgABBYABwnpF0UgANYBABYABwnpF0UgANYBAA8AAwk8EzM9AMIAABQAAQmpE2l8ADcAAAAA.',
['害怕']='害怕校园暴力:BAAALgAFFAEJAgAAAA==.',
['寶兒']='寶兒:BAAALgAECgQJBQAAAA==.',
['封雅']='封雅蜜:BAAALgAFFAEJAQAAAA==.',
['小兰']='小兰飞天:BAAALgAECgMJAwAAAA==.',
['小博']='小博哥:BAAALgAECgYJBgAAAA==.',
['小娃']='小娃娃丶:BAAALgAECgEJAQAAAA==.',
['小小']='小小子博:BAAALgAECgYJBgAAAA==.小小法爷:BAAALgAECgIJAQAAAA==.小小洒满:BAAALgAECgQJBAAAAA==.',
['小屁']='小屁猫崽子:BAAALgADCgEJAQAAAA==.',
['小德']='小德是萌新啊:BAACLgAFFH8IAAIXAAQJcQgpDAAlAQAXAAQJcQgpDAAlAQAuAAQKfxsAAxcACQkPGuYaACwCABcACAlVGOYaACwCABEACAkjEvMTACkBAAAA.',
['小旼']='小旼旼:BAAALgADCgcJBwAAAA==.',
['小涛']='小涛涛:BAABLgAFFH8GAAIXAAMJCBC/EgCtAAAXAAMJCBC/EgCtAAAAAA==.',
['小熊']='小熊小熊:BAAALgADCgUJBQABLgAECgcJDgAFAAAAAA==.小熊猎人:BAABLgAFFH8FAAICAAUJ+AIuDgBCAQACAAUJ+AIuDgBCAQAAAA==.小熊骑士:BAAALgAECgcJDgAAAA==.',
['小牛']='小牛的天空:BAAALgAECgQJBAAAAA==.',
['小白']='小白又暴力:BAAALgADCgcJBwAAAA==.',
['小翠']='小翠:BAAALgAECgEJAQAAAA==.',
['小花']='小花生:BAAALgAECgMJAwAAAA==.',
['小苞']='小苞米:BAAALgAFFAEJAQAAAA==.',
['小贺']='小贺锐气:BAAALgAECgkJEAABLgAFFAUJAgAFAAAAAA==.',
['小龙']='小龙宝:BAACLgAFFH8MAAIYAAQJThrOBwBdAQAYAAQJThrOBwBdAQAuAAQKfyIAAxgACAnUH0kMANcCABgACAnUH0kMANcCABIACAmiF9ElAP0BAAAA.',
['尐灬']='尐灬熊猫:BAAALgAECgYJCgAAAA==.',
['尛龙']='尛龙人:BAAALgAFFAQJBAAAAA==.',
['尤朵']='尤朵拉丨尼克:BAAALgAECgEJAQAAAA==.',
['就不']='就不想带宝宝:BAAALgAECgYJBgAAAA==.',
['就甩']='就甩图腾:BAABLgAECn8YAAMSAAgJoRJ5CwCGAQASAAgJoRJ5CwCGAQAYAAEJ+APjkQAlAAAAAA==.',
['尹恩']='尹恩惠:BAAALgAECgQJBAAAAA==.',
['尼亚']='尼亚还有大家:BAAALgAECgQJCAAAAA==.',
['尼莫']='尼莫茜妮:BAAALgAFFAIJAwAAAA==.',
['尼飛']='尼飛比特:BAAALgAECgcJAQAAAA==.',
['山子']='山子:BAAALgAECgEJAQAAAA==.',
['山河']='山河无恙:BAABLgAFFH8FAAIIAAIJgBH2OwCzAAAIAAIJgBH2OwCzAAAAAA==.',
['山鸡']='山鸡:BAAALgAECgYJBgABLgAECgcJBgAFAAAAAA==.',
['岚呌']='岚呌哩噶:BAACLgAFFH8JAAILAAQJ0RuVDQBtAQALAAQJ0RuVDQBtAQAuAAQKfxoAAwsACAmpHmQnAJ0CAAsACAmpHmQnAJ0CABkAAQlBCwAAAAAAAAEuAAUUBgkVAAwAThAA.',
['峰沟']='峰沟戰:BAAALgAECgMJAwAAAA==.',
['川渝']='川渝暴龙:BAAALgADCgMJAwAAAA==.',
['帅沈']='帅沈家铭:BAAALgAECgcJCQAAAA==.',
['希娜']='希娜狄雅:BAAALgAECgEJAQAAAA==.',
['帝国']='帝国丶茗人:BAAALgAECgEJAQAAAA==.',
['幻世']='幻世:BAAALgADCgIJAgAAAA==.',
['幻月']='幻月破魔:BAAALgAECgEJAQAAAA==.',
['幼稚']='幼稚园殺手丶:BAAALgAECgQJBAAAAA==.',
['幽兰']='幽兰黛爾:BAAALgAECgMJAwAAAA==.',
['广东']='广东蜥蜴人:BAAALgAECgQJCAAAAA==.',
['弄啥']='弄啥哩:BAAALgAECgcJBgABLgAFFAEJAQAFAAAAAA==.',
['张百']='张百万:BAAALgAFFAIJAgAAAA==.',
['张知']='张知秋啊:BAAALgAECgkJCQAAAA==.',
['强力']='强力开僿露:BAAALgAFFAEJAQAAAA==.',
['彭于']='彭于晏丶丶:BAAALgADCgIJAgAAAA==.',
['影殇']='影殇丶:BAAALgAECgQJBAAAAA==.',
['影灭']='影灭:BAAALgAFFAEJAgAAAA==.',
['征衣']='征衣似雪:BAAALgAECgQJBAAAAA==.',
['御剑']='御剑影:BAAALgAECgUJBAAAAA==.',
['微光']='微光:BAAALgADCgYJBgAAAA==.',
['德德']='德德小牧:BAAALgAECgUJCAAAAA==.',
['德玛']='德玛西亚:BAAALgAECgQJBQAAAA==.',
['心月']='心月流火:BAAALgAECgQJBQAAAA==.',
['忧伤']='忧伤的壮壮:BAAALgAECgIJAgAAAA==.',
['忧郁']='忧郁得大香蕉:BAAALgAECgYJCAAAAA==.',
['忻遇']='忻遇丶雪花:BAAALgADCgIJAgAAAA==.',
['性感']='性感土豆:BAABLgAECn8YAAIIAAcJLhAhkgCvAQAIAAcJLhAhkgCvAQAAAA==.性感榴芒:BAAALgAECgcJDAAAAA==.性感罡椒:BAABLgAFFH8GAAISAAIJ0hIACwCXAAASAAIJ0hIACwCXAAAAAA==.性感苦瓜:BAAALgAFFAEJAQAAAA==.性感莲雾:BAAALgADCgYJBgAAAA==.性感葡萄:BAAALgAECgUJBQAAAA==.性感青瓜:BAAALgAECgEJAQAAAA==.',
['怪人']='怪人王:BAAALgAECgcJEwAAAA==.',
['恶魔']='恶魔沈家铭:BAAALgAECgYJBgAAAA==.',
['情迷']='情迷洛丽塔:BAAALgAFFAQJBAAAAA==.',
['惡魔']='惡魔领主:BAAALgAECgEJAQAAAA==.',
['懊柏']='懊柏伦马泰尔:BAAALgAECgEJAQAAAA==.',
['懒虫']='懒虫影遁:BAAALgAECgcJDAAAAA==.',
['我又']='我又不会玩:BAAALgAECgMJAwAAAA==.我又开始无敌:BAAALgAFFAEJAQAAAA==.',
['我在']='我在呼唤你妹:BAAALgAECgMJAwAAAA==.',
['我宝']='我宝宝呢:BAAALgAECgMJAwAAAA==.',
['我常']='我常扇赵子龙:BAAALgADCgEJAQAAAA==.',
['我德']='我德妈呀:BAAALgAECgYJBgAAAA==.',
['我想']='我想养灬个猴:BAAALgAECgUJBQAAAA==.',
['我是']='我是近战:BAAALgADCgUJBQAAAA==.',
['我的']='我的双刀没了:BAAALgADCgYJBgAAAA==.',
['我真']='我真的想睡:BAAALgAECgUJBgAAAA==.我真的想笑:BAAALgAFFAEJAQAAAA==.',
['我给']='我给你说锤子:BAAALgAECgEJAQAAAA==.',
['执着']='执着的小香趴:BAAALgADCgcJDQAAAA==.',
['扭曲']='扭曲的疏逺:BAAALgAFFAIJAgAAAA==.',
['折心']='折心沐火:BAABLgAFFH8GAAITAAIJ1h36LAC6AAATAAIJ1h36LAC6AAAAAA==.',
['拳脚']='拳脚型英雄:BAAALgAECgUJBQAAAA==.',
['指尖']='指尖上跳舞丶:BAABLgAFFH8FAAIGAAIJIRcjFQCXAAAGAAIJIRcjFQCXAAAAAA==.',
['挥手']='挥手呀:BAAALgAECgQJBAAAAA==.挥手啊:BAAALgAFFAEJAQAAAA==.',
['摩尼']='摩尼西亚:BAAALgAECgEJAQAAAA==.',
['播种']='播种与收获啊:BAAALgAECgEJAQAAAA==.',
['敖蕾']='敖蕾莉亚大姐:BAAALgAFFAEJAQAAAA==.',
['文天']='文天坑:BAAALgAECgEJAQAAAA==.',
['斩杀']='斩杀老闭灯:BAAALgAECgEJAQAAAA==.',
['斯坦']='斯坦科维奇:BAACLgAFFH8IAAIIAAMJyB7UIwAoAQAIAAMJyB7UIwAoAQAuAAQKfxgAAggACAkEIsQeAPoCAAgACAkEIsQeAPoCAAAA.',
['旅行']='旅行的意义:BAAALgAECgcJCAAAAA==.',
['无双']='无双沐丝:BAAALgAFFAIJBAAAAA==.',
['无情']='无情的小矮子:BAAALgAECgEJAgAAAA==.',
['无拘']='无拘之魂:BAAALgADCgEJAQAAAA==.',
['无用']='无用之人:BAABLgAECn8WAAILAAcJbxvuTQAJAgALAAcJbxvuTQAJAgAAAA==.',
['无责']='无责任神:BAAALgAECgcJBwAAAA==.',
['时节']='时节不居:BAAALgAECgYJCQAAAA==.',
['旺崽']='旺崽:BAABLgAFFH8IAAMBAAMJFhqIIgBbAAABAAIJaxqIIgBbAAACAAEJaxnPJABVAAAAAA==.',
['明世']='明世因:BAAALgAECgMJAwAAAA==.',
['明天']='明天的向日葵:BAAALgAECgIJAwAAAA==.',
['明月']='明月不夜羽:BAACLgAFFH8JAAIIAAMJzh55DwATAQAIAAMJzh55DwATAQAuAAQKfx4ABAgABwnLIQleACACAAgABwnLIQleACACABoAAQn/I3YWAGcAABsAAglXDPIMAFsAAAAA.',
['明珠']='明珠求瑕:BAABLgAFFH8GAAIIAAIJng87PQCxAAAIAAIJng87PQCxAAAAAA==.',
['明镜']='明镜止水:BAAALgADCgEJAQAAAA==.',
['星星']='星星也会追梦:BAAALgAECgMJAwAAAA==.',
['春光']='春光与你同在:BAAALgADCgEJAQAAAA==.',
['景元']='景元:BAAALgAECgEJAQAAAA==.',
['暖合']='暖合田:BAAALgADCgcJCQAAAA==.',
['暖她']='暖她芯:BAAALgAECgEJAQAAAA==.',
['暗夜']='暗夜破晓:BAAALgAFFAEJAgAAAA==.暗夜騎士:BAAALgAECgUJBgABLgAECgYJEQAFAAAAAA==.',
['暗矛']='暗矛大祭司:BAAALgADCgIJAgAAAA==.',
['暗错']='暗错错:BAAALgAECgUJBQAAAA==.',
['暴力']='暴力丶玛里奥:BAABLgAECn8dAAMGAAgJrRvzHgAgAgAGAAcJYBvzHgAgAgAHAAYJYgvhmgBIAQAAAA==.',
['暴风']='暴风骑士:BAABLgAECn8fAAILAAgJ+hrFCADxAQALAAgJ+hrFCADxAQAAAA==.',
['曼巴']='曼巴:BAAALgAECgQJCAAAAA==.',
['最后']='最后一种快乐:BAAALgADCgEJAQAAAA==.',
['最爱']='最爱养肉肉:BAAALgAECgQJBQAAAA==.',
['月圣']='月圣:BAAALgAECgkJCgAAAA==.',
['月梦']='月梦辰曦:BAAALgADCgEJAQABLgAECgUJBQAFAAAAAA==.',
['有奶']='有奶的小矮子:BAAALgAFFAIJBAABLgAFFAYJBgAQADsWAA==.',
['有才']='有才有德:BAAALgAECgIJAgAAAA==.',
['有栖']='有栖:BAAALgADCgEJAQAAAA==.',
['有辣']='有辣条也有你:BAAALgAECgYJCgAAAA==.',
['机智']='机智的阳阳:BAAALgAECgQJBAAAAA==.',
['杀仁']='杀仁来袭:BAAALgADCgEJAQAAAA==.',
['杂地']='杂地头都没:BAACLgAFFH8IAAIcAAMJdxyXAgAYAQAcAAMJdxyXAgAYAQAuAAQKfxUAAhwACAmCGigPAIsCABwACAmCGigPAIsCAAAA.',
['杂德']='杂德头都没:BAAALgAFFAEJAQABLgAFFAMJCAAcAHccAA==.',
['权志']='权志龙:BAAALgADCgYJCgAAAA==.',
['杰克']='杰克丨斯派罗:BAAALgADCgcJEAAAAA==.',
['极寒']='极寒领主:BAAALgAECgIJBAAAAA==.',
['极炫']='极炫卖鱼强:BAAALgADCgEJAQAAAA==.',
['林风']='林风儿:BAAALgADCgEJAQAAAA==.',
['格非']='格非:BAAALgAECgYJCgAAAA==.',
['栾师']='栾师傅:BAACLgAFFH8KAAIdAAQJBiJLBACVAQAdAAQJBiJLBACVAQAuAAQKfxkAAh0ACAnUIQwJAPcCAB0ACAnUIQwJAPcCAAAA.',
['梦游']='梦游骑士:BAAALgADCgEJAQAAAA==.',
['梦龙']='梦龙丶丶:BAAALgAFFAEJAQAAAA==.',
['楠木']='楠木森林:BAAALgAECgQJBwAAAA==.',
['樱吹']='樱吹雪:BAAALgAECgYJBwAAAA==.',
['橘猫']='橘猫不吃鱼:BAAALgAECgMJBgAAAA==.',
['橙三']='橙三:BAAALgAFFAQJBAAAAA==.',
['橙九']='橙九:BAAALgAECgQJBAAAAA==.',
['橙二']='橙二:BAABLgAFFH8IAAIIAAQJ9wvAHQBTAQAIAAQJ9wvAHQBTAQAAAA==.',
['橙八']='橙八:BAAALgAECgYJBgAAAA==.',
['橙六']='橙六:BAAALgAECgYJBgAAAA==.',
['橙十']='橙十:BAAALgAECgYJBgAAAA==.',
['橙四']='橙四:BAAALgAECgYJCwAAAA==.',
['橙橙']='橙橙十六:BAAALgAFFAUJAQAAAA==.',
['橙色']='橙色小熊:BAAALgAECgMJAwABLgAECgcJDgAFAAAAAA==.橙色猎绅:BAAALgADCgUJBQAAAA==.橙色苹果:BAAALgAFFAIJAgAAAA==.',
['欲之']='欲之初:BAAALgAECgQJBAAAAA==.',
['歹匕']='歹匕礻申:BAAALgAECgYJBgAAAA==.',
['残暴']='残暴的大渣渣:BAAALgADCgYJBgAAAA==.',
['殺神']='殺神一虎牙爷:BAAALgAECgMJAwAAAA==.',
['毁逸']='毁逸丶:BAAALgAECgEJAQAAAA==.',
['母流']='母流猎:BAAALgAECgYJCQAAAA==.',
['永尾']='永尾丸治:BAAALgAECgcJDwAAAA==.',
['永雏']='永雏塔菲:BAACLgAFFH8GAAMEAAQJIwsYCwA5AQAEAAQJIwsYCwA5AQAKAAIJtwFNHQCFAAAuAAQKfyYAAgoABwl4GloaAPgBAAoABwl4GloaAPgBAAAA.',
['没得']='没得哈术:BAAALgAECggJCAAAAA==.',
['没有']='没有冰箱:BAAALgAECgEJAQAAAA==.',
['波士']='波士顿烤娃:BAABLgAFFH8FAAIGAAQJYhc2CABOAQAGAAQJYhc2CABOAQAAAA==.',
['波波']='波波一世:BAABLgAFFH8JAAIGAAUJoyEOAgDhAQAGAAUJoyEOAgDhAQAAAA==.波波开光环:BAABLgAFFH8NAAIGAAUJvx8xAwC4AQAGAAUJvx8xAwC4AQAAAA==.波波抡大锤:BAABLgAFFH8IAAIGAAQJShkpCABPAQAGAAQJShkpCABPAQAAAA==.波波要圣疗:BAABLgAFFH8JAAIGAAUJmB2CAgDNAQAGAAUJmB2CAgDNAQAAAA==.波波要牺牲:BAABLgAFFH8KAAIGAAUJIyDcAQDqAQAGAAUJIyDcAQDqAQAAAA==.',
['泰瑞']='泰瑞宝丶:BAAALgAECgIJAgAAAA==.',
['泱洋']='泱洋氧恙:BAAALgAECgcJEgAAAA==.',
['流火']='流火:BAACLgAFFH8NAAIeAAQJpQq7BgD7AAAeAAQJpQq7BgD7AAAuAAQKfx8AAh4ACQmdEl4NADUCAB4ACQmdEl4NADUCAAAA.',
['流绪']='流绪微梦:BAACLgAFFH8FAAIPAAIJPBWtEgCgAAAPAAIJPBWtEgCgAAAuAAQKfxkABA8ABwn6HrMNAF4CAA8ABwmJHrMNAF4CABYABQmIITUcAPoBABQAAQkJHJB3AEsAAAAA.',
['浖雯']='浖雯丶:BAAALgAECgQJBAAAAA==.',
['浮生']='浮生一梦:BAAALgAECgEJAgAAAA==.',
['海马']='海马:BAAALgAECgEJAQAAAA==.',
['涟涟']='涟涟:BAAALgAECgIJAgAAAA==.',
['混子']='混子:BAAALgAECgkJBwAAAA==.',
['渣渣']='渣渣灰:BAAALgAECgQJAgAAAA==.',
['温水']='温水:BAAALgAECgEJAQAAAA==.',
['溪鱼']='溪鱼:BAAALgAFFAIJAgAAAA==.',
['滚滚']='滚滚:BAAALgAECgMJAwAAAA==.滚滚更健康:BAAALgADCgIJAgAAAA==.滚滚更舒坦:BAAALgAFFAEJAQAAAA==.',
['滚门']='滚门糖:BAAALgAECgYJCgAAAA==.',
['演技']='演技不够浮夸:BAAALgAECgEJAQAAAA==.',
['潇洒']='潇洒的老骨头:BAAALgAECgYJBgAAAA==.',
['潘达']='潘达利亚功夫:BAAALgADCgEJAQAAAA==.',
['火之']='火之高兴丶:BAAALgAECgQJBgAAAA==.',
['火山']='火山轮椅王:BAAALgAECgcJBwAAAA==.',
['火鷄']='火鷄味鍋巴:BAAALgAECgIJAgAAAA==.',
['灬咖']='灬咖啡豆灬:BAACLgAFFH8IAAIfAAMJkQr0AQCyAAAfAAMJkQr0AQCyAAAuAAQKfxUAAh8ACAluE0QMAMYBAB8ACAluE0QMAMYBAAAA.',
['灬喵']='灬喵大:BAAALgADCgcJBwAAAA==.',
['灬志']='灬志平啊:BAAALgADCgIJAgAAAA==.',
['灬扯']='灬扯淡:BAABLgAECn8UAAILAAcJeR6uPwA6AgALAAcJeR6uPwA6AgAAAA==.',
['灬绿']='灬绿豆灬:BAAALgAECgcJBwABLgAFFAMJCAAfAJEKAA==.',
['灵魂']='灵魂丶行走:BAAALgAFFAIJAgAAAA==.',
['炭烤']='炭烤小灵魂:BAAALgAECgEJAQAAAA==.',
['点电']='点电都掂:BAAALgAECgEJAQAAAA==.',
['爆浆']='爆浆鸡米花:BAAALgAECgEJAQAAAA==.',
['爆疯']='爆疯:BAAALgAECgMJAwAAAA==.',
['爆破']='爆破精英:BAAALgAECgYJDQAAAA==.',
['爱丽']='爱丽希恩:BAAALgAECgQJBAAAAA==.',
['爱人']='爱人:BAACLgAFFH8GAAILAAMJWhCtDgABAQALAAMJWhCtDgABAQAuAAQKfxQAAgsACAlEGDBQAAECAAsACAlEGDBQAAECAAAA.',
['爷爷']='爷爷不泡茶:BAAALgAECgQJBgAAAA==.',
['牛奶']='牛奶的咖啡:BAAALgAECgUJBQABLgAFFAUJDQAPAKojAA==.牛奶磨白:BAAALgADCgEJAQAAAA==.',
['牛牛']='牛牛面面哒丶:BAABLgAFFH8IAAIGAAMJzCIGBQAaAQAGAAMJzCIGBQAaAQAAAA==.',
['牛麦']='牛麦兜:BAAALgAECgYJEQAAAA==.',
['牧友']='牧友治疗:BAAALgAECgQJAwAAAA==.',
['狂炫']='狂炫富婆画饼:BAEBLgAFFH8FAAIEAAUJ8x7DBQCZAQAEAAUJ8x7DBQCZAQABLgAFFAQJBgAIALASAA==.',
['狂风']='狂风:BAAALgADCgYJAQAAAA==.',
['独倚']='独倚望江楼:BAAALgAFFAQJBAAAAA==.',
['猎影']='猎影追风:BAAALgAECgYJBgAAAA==.',
['猪凸']='猪凸猛進:BAAALgAECgYJBgAAAA==.',
['猫宅']='猫宅罪:BAAALgAECgUJBQAAAA==.',
['王潘']='王潘达:BAABLgAFFH8FAAMYAAIJPQ7tCgCSAAAYAAIJPQ7tCgCSAAASAAEJlQKrJgA7AAAAAA==.',
['玛莲']='玛莲妮娅:BAACLgAFFH8FAAITAAIJWg5UNQCoAAATAAIJWg5UNQCoAAAuAAQKfx4ABBMABgkWIEs9ABcCABMABgkWIEs9ABcCACAAAwl0A11OAIIAACEAAQkAAIgzADYAAAAA.',
['玮玮']='玮玮的小术:BAAALgAECgkJCQAAAA==.玮玮的皮皮虾:BAAALgAECgcJCAAAAA==.玮玮的霜噬:BAABLgAFFH8GAAILAAMJoBuwEgDJAAALAAMJoBuwEgDJAAAAAA==.',
['珍惜']='珍惜丶:BAACLgAFFH8IAAIVAAMJziKqAwBAAQAVAAMJziKqAwBAAQAuAAQKfxUAAhUACAmTIo0GACcDABUACAmTIo0GACcDAAAA.',
['琪莎']='琪莎拉:BAAALgAECgYJCAAAAA==.',
['瑞原']='瑞原明奈丶:BAABLgAFFH8PAAMSAAUJ5BcsAgB4AQASAAUJ5BcsAgB4AQAYAAIJjhH7FQChAAAAAA==.',
['瑞尔']='瑞尔:BAAALgAECgYJDgAAAA==.',
['瑞瑞']='瑞瑞:BAAALgAECgQJBAAAAA==.',
['瑾枳']='瑾枳流年:BAAALgAFFAIJAQAAAA==.',
['璟宝']='璟宝胖墩墩:BAAALgAECgEJAQAAAA==.',
['瓜老']='瓜老汉:BAAALgAECgEJAQAAAA==.',
['生存']='生存还是射击:BAAALgAECgcJAgAAAA==.',
['画饼']='画饼大王:BAAALgAFFAEJAQAAAA==.',
['疯狂']='疯狂傻撸:BAAALgADCgEJAQAAAA==.',
['痒就']='痒就挠呗:BAAALgAECgQJBwAAAA==.',
['白凤']='白凤凤翔丶:BAACLgAFFH8LAAIPAAQJ3BpUCABWAQAPAAQJ3BpUCABWAQAuAAQKfxUAAw8ACQmOGNwJAJwCAA8ACQmOGNwJAJwCABQAAQn/BZaDAC0AAAAA.',
['白日']='白日做梦丶:BAAALgAECgUJCgAAAA==.',
['白色']='白色木偶:BAAALgAECgcJDAAAAA==.',
['百华']='百华月咏:BAABLgAFFH8HAAIIAAIJzBxVNADGAAAIAAIJzBxVNADGAAAAAA==.',
['百年']='百年星光:BAAALgADCggJDgAAAA==.',
['盲女']='盲女:BAAALgAFFAIJAwAAAA==.',
['眼冒']='眼冒冷光:BAAALgADCgYJBgABLgAECgQJBwAFAAAAAA==.',
['睿智']='睿智的海豹:BAAALgAFFAMJAQABLgAFFAUJDQABAOsUAA==.',
['瞌睡']='瞌睡蟲灬夢:BAABLgAECn8UAAMBAAcJchYYQACvAQABAAYJJxoYQACvAQACAAIJ5wN4fQBPAAAAAA==.',
['矢车']='矢车菊:BAAALgADCgMJAwAAAA==.',
['破雾']='破雾:BAAALgAECgEJAgAAAA==.',
['祈咔']='祈咔:BAAALgAECgEJAQAAAA==.',
['神光']='神光欺骗了你:BAAALgAECgYJBgAAAA==.',
['福原']='福原爱:BAAALgAECgcJCAAAAA==.',
['离我']='离我远点丶:BAAALgAECgUJBQAAAA==.',
['科斯']='科斯莫利基德:BAAALgAECgMJAwAAAA==.',
['秒符']='秒符爱你:BAAALgAFFAIJAgAAAA==.',
['空了']='空了个城:BAAALgADCgMJAwAAAA==.',
['空条']='空条丶徐伦:BAAALgAECgcJBwABLgAFFAUJAwAFAAAAAA==.',
['站起']='站起来蹬:BAAALgAECgQJBQAAAA==.',
['笨笨']='笨笨:BAAALgAFFAEJAQAAAA==.笨笨灬小猎:BAAALgAECgIJAgAAAA==.笨笨灬牛德:BAAALgAECgYJDQAAAA==.',
['糖醋']='糖醋溜丸子:BAAALgADCgYJBgAAAA==.',
['紫殇']='紫殇丶:BAAALgAECgEJAwAAAA==.',
['紫药']='紫药水:BAAALgAECgYJBgAAAA==.',
['綯愾']='綯愾灬嘟嘟:BAAALgAECgUJAQAAAA==.',
['织炎']='织炎之翼:BAAALgAFFAEJAgAAAA==.',
['绛天']='绛天:BAAALgAECgYJBgAAAA==.',
['维尔']='维尔哈伦:BAAALgADCgcJBwAAAA==.',
['绿叔']='绿叔:BAAALgADCgUJBQAAAA==.',
['缺牙']='缺牙老鼠:BAAALgAECgcJBwAAAA==.',
['羊葱']='羊葱騎士:BAAALgAECgEJAQABLgAECgYJBgAFAAAAAA==.',
['羊酱']='羊酱:BAAALgAECgMJBQABLgAFFAcJGQAdAP4WAA==.',
['翩若']='翩若惊鸿影:BAAALgAECgEJAQAAAA==.',
['老杜']='老杜:BAAALgAECgQJBAAAAA==.',
['老汾']='老汾酒:BAAALgAECgEJAQAAAA==.',
['老紫']='老紫数到叁:BAAALgAECgMJAwAAAA==.',
['老肩']='老肩巨滑乀:BAAALgAECgYJBgAAAA==.',
['耳朵']='耳朵龙:BAABLgAFFH8SAAMDAAUJqiFFAAAAAgADAAUJqiFFAAAAAgAKAAEJyx0XIABSAAAAAA==.',
['肖无']='肖无敌:BAAALgAFFAEJAwAAAA==.',
['肥逹']='肥逹可:BAAALgAECgYJBgAAAA==.',
['肾虚']='肾虚行者:BAAALgAECgYJCAAAAA==.',
['胆小']='胆小如鼠标:BAABLgAECn8aAAMiAAgJyiBbDwDYAgAiAAgJyiBbDwDYAgAjAAQJYxbLGQAlAQAAAA==.',
['胡恩']='胡恩旺仔:BAAALgAECgYJBgAAAA==.',
['胡艺']='胡艺莲:BAACLgAFFH8OAAMUAAQJ7h21AwDkAAAPAAQJtw49CgA7AQAUAAIJ9SW1AwDkAAAuAAQKfx0AAw8ACAkrGQISACUCAA8ACAkRFwISACUCABQAAwkPG/QYAGUAAAAA.',
['胸毛']='胸毛锅丶:BAAALgAECgEJAQAAAA==.',
['能力']='能力圣斗士:BAAALgAECgQJBAAAAA==.',
['腐蚀']='腐蚀光环:BAAALgAECgYJCwAAAA==.',
['膜髪']='膜髪丝:BAAALgADCgUJBQAAAA==.',
['至臻']='至臻沐丝:BAAALgAECgEJAQAAAA==.',
['舞朱']='舞朱雀马克兔:BAAALgAECgEJAwAAAA==.',
['艾丁']='艾丁丶逐日者:BAAALgAECgEJAQAAAA==.',
['艾利']='艾利桑德丶:BAAALgAECgEJAQAAAA==.',
['芙莉']='芙莉莲丶:BAABLgAECn8UAAIIAAgJ1xlOPwB7AgAIAAgJ1xlOPwB7AgABLgAFFAQJCwAKAO4TAA==.',
['芙露']='芙露德莉丝:BAAALgAECgEJAQAAAA==.',
['芮星']='芮星:BAAALgAECgEJAQAAAA==.',
['芮雪']='芮雪:BAAALgADCgEJAgAAAA==.',
['若水']='若水轻鸿:BAABLgAFFH8KAAMUAAMJ2iJqBQAuAQAUAAMJ2iJqBQAuAQAWAAMJcwyOEwBXAAAAAA==.',
['英雄']='英雄丶不朽:BAAALgAECgYJBwAAAA==.',
['茄子']='茄子炮:BAAALgAECgkJBAAAAA==.',
['茶猪']='茶猪大牛牛:BAAALgAECgcJBwAAAA==.',
['草哥']='草哥:BAAALgAECggJBwAAAA==.草哥很猛:BAACLgAFFH8MAAMLAAUJgQ9IGgA8AQALAAQJgQ9IGgA8AQAMAAEJAABzHAAfAAAuAAQKfycAAgsACQmOHRwTAAkDAAsACQmOHRwTAAkDAAAA.',
['荼蘼']='荼蘼:BAABLgAFFH8IAAIGAAQJrSGCBQCEAQAGAAQJrSGCBQCEAQAAAA==.',
['莫莉']='莫莉丶:BAAALgAECgEJAgAAAA==.',
['莱格']='莱格拉丝:BAAALgAECgMJAwAAAA==.',
['菜鸟']='菜鸟擀面杖:BAAALgAECgYJEgAAAA==.',
['菲林']='菲林斯:BAAALgADCgIJAgAAAA==.',
['菲莉']='菲莉嘉:BAAALgAECgUJBwAAAA==.',
['萌德']='萌德:BAAALgAFFAQJAQAAAA==.',
['萨拉']='萨拉曼陀:BAABLgAECn8bAAMZAAgJsRYlAgBpAQALAAgJsRY7VAD1AQAZAAYJ6xQlAgBpAQAAAA==.',
['萨满']='萨满丶靓妹:BAAALgAECgYJDQAAAA==.',
['萨瓦']='萨瓦敌卡:BAAALgADCgIJAgAAAA==.',
['萨鲁']='萨鲁法尔老王:BAAALgAFFAEJAQAAAA==.',
['萬能']='萬能爹地:BAAALgAECgMJAwAAAA==.',
['萬鬼']='萬鬼:BAAALgAECgcJAQAAAA==.',
['落叶']='落叶心德:BAAALgADCgYJBgAAAA==.落叶心悲凉:BAAALgAECgMJAwAAAA==.',
['落雪']='落雪眠霜:BAAALgAECgMJAwAAAA==.',
['葱香']='葱香小嫩牛:BAAALgADCgEJAQAAAA==.',
['蔡徐']='蔡徐鲲:BAAALgADCgEJAQAAAA==.',
['蕾米']='蕾米娜:BAAALgAECgcJCQAAAA==.',
['蘇格']='蘇格丶拉圖:BAAALgAECgQJCAAAAA==.',
['虎牙']='虎牙猎手哥:BAAALgADCgEJAQAAAA==.',
['虎纹']='虎纹大鲨鱼:BAAALgAECgMJAwAAAA==.',
['虔诚']='虔诚丶:BAABLgAFFH8HAAIRAAQJliZsAgDPAQARAAQJliZsAgDPAQAAAA==.虔诚大魔王:BAAALgAECgcJCQABLgAFFAQJBwARAJYmAA==.',
['蛋仔']='蛋仔黄:BAAALgAECgQJBwAAAA==.',
['蛮蛮']='蛮蛮是静静:BAAALgAFFAIJAgAAAA==.',
['血契']='血契德乌恩:BAAALgADCgEJAQAAAA==.血契瘟疫之星:BAAALgAECgQJBAAAAA==.',
['西索']='西索克丶奔袭:BAAALgAECgcJBgAAAA==.',
['要不']='要不散了吧:BAAALgAECggJEQAAAA==.',
['见龍']='见龍卸甲:BAAALgAECgUJBQAAAA==.',
['言午']='言午爱基基:BAABLgAFFH8HAAMRAAMJMh/VDAAYAQARAAMJMh/VDAAYAQAXAAEJlwR7HABEAAAAAA==.',
['话梅']='话梅糖小豚:BAAALgAFFAIJAgAAAA==.',
['诶有']='诶有誒誒:BAAALgAECgYJBwAAAA==.',
['请侬']='请侬切尼光:BAAALgADCgIJAgAAAA==.',
['诺兰']='诺兰玟:BAAALgADCgYJBgAAAA==.',
['贞德']='贞德:BAAALgAECgcJBwABLgAFFAUJBQAIAGkYAA==.',
['贫道']='贫道夜探青樓:BAABLgAECn8VAAIjAAcJYhYQDADgAQAjAAcJYhYQDADgAQAAAA==.',
['贴贴']='贴贴你的蛋蛋:BAAALgADCgUJBQAAAA==.',
['赛博']='赛博拉斯挽歌:BAAALgAECgUJBwAAAA==.',
['赫尔']='赫尔纳拉克:BAAALgAECgcJCAAAAA==.',
['起名']='起名综合症:BAAALgAECgcJCQAAAA==.',
['越空']='越空行者:BAAALgAECgQJBAAAAA==.',
['足疗']='足疗纳入医保:BAAALgAECgIJAgAAAA==.',
['趴趴']='趴趴:BAAALgAECgEJAQAAAA==.',
['路人']='路人甲的司机:BAAALgAECgMJAwAAAA==.路人甲的秘友:BAAALgAECgMJAwAAAA==.',
['踏月']='踏月风行:BAAALgAECgUJBQAAAA==.',
['身本']='身本忧:BAAALgAFFAIJAwAAAA==.',
['躺尸']='躺尸老坂:BAAALgAECgYJCgAAAA==.躺尸老板一号:BAAALgAECgIJAgAAAA==.',
['软软']='软软丶丶:BAAALgAFFAIJAwAAAA==.',
['辉煌']='辉煌豆豆:BAAALgADCgEJAQAAAA==.',
['迎风']='迎风亮胯:BAAALgAECgYJBgAAAA==.',
['进击']='进击小肚纸:BAAALgAECggJEwAAAA==.',
['追魂']='追魂夺魄:BAACLgAFFH8FAAIBAAIJFA/5GACjAAABAAIJFA/5GACjAAAuAAQKfxkAAwEABwlPIdsTAJgCAAEABwlPIdsTAJgCAAIAAwmOCe5tAIcAAAAA.',
['逆行']='逆行:BAAALgAECgYJDQAAAA==.',
['逐枫']='逐枫的爸爸:BAAALgAECgEJAQAAAA==.',
['邦桑']='邦桑迪之殇:BAAALgAECgQJBQAAAA==.',
['都是']='都是混子:BAAALgAFFAIJBAAAAA==.',
['酱油']='酱油再临:BAAALgAFFAEJAQAAAA==.',
['醉拳']='醉拳不醉心:BAAALgAECgYJCwAAAA==.',
['醉是']='醉是凡:BAAALgAFFAQJBAAAAA==.',
['醉酒']='醉酒耍醉拳:BAAALgAFFAEJAQAAAA==.',
['针头']='针头剑八:BAABLgAFFH8EAAITAAIJ+yKjEgDVAAATAAIJ+yKjEgDVAAAAAA==.',
['针灸']='针灸推拿:BAAALgAECgQJBgABLgAECgYJCgAFAAAAAA==.',
['铁盾']='铁盾黎明:BAAALgAECgMJAwAAAA==.',
['阴天']='阴天晴朗:BAAALgAECgQJCAAAAA==.',
['阿姆']='阿姆罗雷:BAAALgAFFAIJAwAAAA==.',
['阿莫']='阿莫比:BAAALgAECgcJBwAAAA==.',
['隐有']='隐有王霸之氣:BAAALgADCggJDgAAAA==.',
['雪战']='雪战舞:BAAALgAECgYJBwAAAA==.',
['雪茄']='雪茄:BAAALgAECgMJAwAAAA==.',
['雪葬']='雪葬:BAAALgAECgMJAwAAAA==.',
['零落']='零落萌音丶:BAAALgAFFAIJAwAAAA==.',
['雷虎']='雷虎:BAAALgAECgEJAQAAAA==.',
['雷電']='雷電芽衣:BAAALgAECgEJAgAAAA==.',
['霜灬']='霜灬白:BAAALgAECgEJAQAAAA==.',
['霜雨']='霜雨:BAAALgAECgYJBgAAAA==.',
['靑龍']='靑龍:BAACLgAFFH8IAAIdAAMJsQSxCQDBAAAdAAMJsQSxCQDBAAAuAAQKfxUAAh0ACAnwCuk2AHABAB0ACAnwCuk2AHABAAAA.',
['青花']='青花盏:BAAALgADCgIJAQAAAA==.',
['青霜']='青霜丶丶:BAAALgADCgYJBgAAAA==.',
['非常']='非常不动如山:BAACLgAFFH8JAAIMAAMJshCyBQC3AAAMAAMJshCyBQC3AAAuAAQKfxUAAgwABwkfGBoYAJoBAAwABwkfGBoYAJoBAAAA.非常不讲道理:BAAALgAECgYJCAAAAA==.非常吆姬:BAAALgAFFAEJAQAAAA==.非常妖桡:BAAALgAECgMJAwAAAA==.非常宝宝:BAACLgAFFH8JAAMXAAMJuBQeBQAJAQAXAAMJuBQeBQAJAQARAAIJ6Rg0GACfAAAuAAQKfxwAAxcABwlrHjIXAFICABcABwlrHjIXAFICABEABAmfHV5UAFYBAAAA.非常无理取闹:BAAALgAECgEJAQAAAA==.非常有德:BAAALgAECgYJBgABLgAFFAgJAQAFAAAAAA==.非常淡鼎:BAAALgADCgIJAgAAAA==.非常淤泥:BAABLgAFFH8GAAIQAAMJGSK0CAAvAQAQAAMJGSK0CAAvAQAAAA==.非常溜:BAAALgAECgYJBgAAAA==.非常爷们:BAACLgAFFH8JAAIHAAMJuCTpBABHAQAHAAMJuCTpBABHAQAuAAQKfxUAAwcABwkYJMc0AE8CAAcABgkPJcc0AE8CAAYABgk6I14eACQCAAAA.非常爽爽:BAAALgAECgEJAQAAAA==.非常的人头木:BAAALgAFFAQJAQABLgAFFAYJDgAjANUkAA==.非常神马:BAAALgAFFAEJAQAAAA==.非常秘书:BAACLgAFFH8JAAIkAAMJgAZlBACNAAAkAAMJgAZlBACNAAAuAAQKfyAAAiQACAm4F8IKACECACQACAm4F8IKACECAAAA.非常篮瘦:BAAALgAECgMJAwAAAA==.非常能射:BAAALgAECgEJAQAAAA==.非常蓝瘦:BAAALgAECgYJBgAAAA==.',
['顶级']='顶级炫果奶:BAAALgAECgYJBgAAAA==.',
['风之']='风之蝶彩:BAAALgAECgEJAgAAAA==.',
['风吹']='风吹裤儿荡:BAAALgAECgIJAgAAAA==.',
['风在']='风在树梢:BAAALgAFFAQJBAAAAA==.',
['风暴']='风暴之银:BAAALgAECgEJAQAAAA==.风暴狂啸:BAACLgAFFH8IAAIiAAMJDA5RBgD+AAAiAAMJDA5RBgD+AAAuAAQKfxoAAx4ACQkVIW8FAOUCAB4ACAm4Hm8FAOUCACIACQk7GtwOANwCAAEuAAUUBQkKAB4AdRIA.风暴狂魔:BAABLgAECn8cAAINAAkJAhxyFQDWAgANAAkJAhxyFQDWAgAAAA==.风暴的使者:BAAALgAECgYJCQAAAA==.',
['飘仙']='飘仙人:BAAALgAECgIJBAAAAA==.',
['飞行']='飞行雪绒:BAAALgAECgIJAgAAAA==.',
['骑着']='骑着猪狂飙:BAAALgAECgUJBQAAAA==.',
['高宫']='高宫茉莉丶:BAAALgAFFAIJAgAAAA==.',
['魏武']='魏武帝四:BAAALgAFFAQJBAAAAA==.',
['魔九']='魔九丶:BAAALgAECgYJBgAAAA==.',
['魔力']='魔力宝贝:BAAALgAECgEJAQAAAA==.',
['魔法']='魔法加點冰:BAAALgAECgYJEQAAAA==.',
['鱼忆']='鱼忆七秒灬:BAAALgAECgIJAgAAAA==.',
['鱼鱼']='鱼鱼儿:BAAALgAECgEJAQAAAA==.',
['鸳鸯']='鸳鸯锅:BAAALgAECgEJAQAAAA==.',
['鹿鹿']='鹿鹿子:BAAALgAECgcJBgAAAA==.',
['麻辣']='麻辣小火锅:BAAALgADCgMJAwAAAA==.',
['黄前']='黄前久美子:BAAALgAECgIJAgAAAA==.',
['黄色']='黄色闪光:BAAALgAECgUJDQAAAA==.',
['黎明']='黎明之心:BAAALgAECgcJCAAAAA==.',
['黑冠']='黑冠贤者:BAACLgAFFH8GAAMUAAIJlBYZEQBjAAAUAAIJlBYZEQBjAAAWAAIJAROnEgBjAAAuAAQKfyIAAxQABwk1JbkGAOICABQABwk1JbkGAOICABYABgm6HhAYACICAAAA.',
['黑暗']='黑暗狩猎:BAABLgAECn8UAAQBAAgJNx05FACVAgABAAgJNx05FACVAgACAAEJ0g9HiAAzAAAlAAEJBAe6MQAtAAAAAA==.',
['黑魔']='黑魔:BAAALgADCgMJAwAAAA==.',
['黔北']='黔北扛把子:BAAALgAECgQJBwAAAA==.',
['齐格']='齐格龙咚强:BAAALgAFFAQJBAAAAA==.',
['龘龘']='龘龘厵厵:BAAALgAECgYJBgAAAA==.',
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
