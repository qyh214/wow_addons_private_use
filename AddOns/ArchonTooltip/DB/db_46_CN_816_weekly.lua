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

local lookup = {'Monk-Brewmaster','Mage-Frost','Priest-Shadow','Priest-Holy','Priest-Discipline','DemonHunter-Devourer','DemonHunter-Havoc','Unknown-Unknown','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Shaman-Restoration','Hunter-BeastMastery','DeathKnight-Blood','Paladin-Retribution','Warlock-Affliction','Warrior-Protection','Rogue-Subtlety','Rogue-Assassination','Druid-Restoration','Warrior-Fury','Hunter-Survival','Shaman-Elemental','Monk-Windwalker','Monk-Mistweaver','DemonHunter-Vengeance','Paladin-Holy','Evoker-Devastation','Evoker-Preservation','Warrior-Arms','Hunter-Marksmanship','Paladin-Protection','Druid-Balance',}
local provider = {region='CN',realm='萨尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Amazon:BAAALgAFFAIJAgAAAA==.Amyli:BAABLgAFFH8FAAIBAAUJ8AobBwAiAQABAAUJ8AobBwAiAQABLgAFFAYJCwACAL0cAA==.',
Ar='Arcaneevoker:BAAALgAECgkJCQAAAA==.Arianrhod:BAABLgAECn8WAAQDAAkJrRvcBQAxAwADAAkJrRvcBQAxAwAEAAUJpx6cKACsAQAFAAIJKiFGPwC0AAABLgAECggJIAAGADcaAA==.',
Au='Aumbanana:BAAALgAECgYJEwAAAA==.',
Br='Brucedd:BAAALgAECgIJAgAAAA==.',
Ca='Callmeshen:BAAALgAECgYJBwAAAA==.Carls:BAABLgAECn8WAAMHAAkJtxmjDQCJAgAHAAkJtxmjDQCJAgAGAAcJ7BHhbgBXAQAAAA==.Carol:BAAALgAECgUJBQAAAA==.',
Ch='Cholee:BAAALgAECgEJAQABLgAECgkJAwAIAAAAAA==.',
Co='Conber:BAAALgAECgYJBwAAAA==.',
Cr='Crawleyhunk:BAAALgAECgYJAgAAAA==.',
Dd='Ddlr:BAAALgADCgYJBgAAAA==.',
De='Deathdecay:BAAALgAECgcJBgAAAA==.Deltalkene:BAAALgAECgEJAQAAAA==.Demoeyes:BAAALgAECgQJBAAAAA==.Demoners:BAAALgADCgEJAQAAAA==.Desperado:BAAALgAECgYJEgAAAA==.Destinyfate:BAAALgAECgYJCgAAAA==.',
Di='Dizzy:BAABLgAFFH8GAAIJAAIJnxfOIACgAAAJAAIJnxfOIACgAAAAAA==.',
Dr='Drablo:BAAALgAFFAQJBAABLgAFFAYJDwAKALsgAA==.',
Ei='Eilidan:BAAALgAECgQJBAAAAA==.',
En='Endlessendin:BAAALgAECgYJCAABLgAFFAcJBwALAE0eAA==.',
Fa='Fab:BAAALgADCgEJAQAAAA==.',
Fo='Forbidings:BAAALgAECgQJBAAAAA==.',
Fr='Frigga:BAAALgADCgYJCgAAAA==.',
Gr='Gress:BAAALgADCgEJAQAAAA==.',
Gu='Guar:BAAALgADCgUJBQAAAA==.Guugu:BAAALgAECgQJBwAAAA==.',
Ha='Hayasakaai:BAAALgADCgIJAgAAAA==.',
Hi='Highnoon:BAAALgAECgUJBQAAAA==.',
Hl='Hlepme:BAAALgAECgYJBgAAAA==.',
Ig='Ignativs:BAAALgAECgkJCQABLgAFFAUJDAAKAGsQAA==.',
Im='Immediater:BAABLgAECn8WAAIMAAcJ3RlLKgDlAQAMAAcJ3RlLKgDlAQAAAA==.',
Ki='Kiricookie:BAAALgAECgEJAQAAAA==.',
Ku='Kunagi:BAAALgADCgEJAQAAAA==.',
Le='Leafushadow:BAABLgAECn8ZAAMLAAgJvx/wGACEAQAKAAUJISDITwDYAQALAAUJNBjwGACEAQAAAA==.Leers:BAAALgADCgUJBQAAAA==.',
Me='Mengli:BAAALgADCgUJCAAAAA==.',
Mi='Miffy:BAAALgAECgQJBAAAAA==.',
Mu='Mulagir:BAAALgAECgIJAwAAAA==.',
No='Notprofane:BAAALgAFFAEJAQAAAA==.',
Op='Openthedoor:BAAALgAFFAEJAQAAAA==.',
Or='Orick:BAAALgAECgcJEQAAAA==.',
Pl='Playerhlwnrj:BAAALgAECgEJAQAAAA==.',
Po='Poppy:BAAALgADCgEJAQAAAA==.Postsusu:BAAALgAECgMJBgAAAA==.',
Qi='Qic:BAAALgAECgMJAwAAAA==.',
Ra='Ragnaroce:BAAALgAECgIJAwAAAA==.',
Re='Reason:BAAALgAECgEJAgAAAA==.Religioux:BAABLgAFFH8EAAINAAIJYSPMDgDVAAANAAIJYSPMDgDVAAAAAA==.Rengeadef:BAAALgAECgMJCQAAAA==.Reo:BAAALgADCgcJBwAAAA==.Rex:BAAALgAECgYJBwAAAA==.',
Sa='Sammimo:BAAALgAECgUJBQAAAA==.',
Sc='Sci:BAAALgAECgUJCQAAAA==.',
Se='Seeyoutomorr:BAAALgAFFAIJAgAAAA==.',
Sh='Shirayuki:BAAALgAECgEJAQAAAA==.',
Si='Sincity:BAAALgADCgQJBAAAAA==.',
Sk='Skyhunter:BAAALgAECgEJAgAAAA==.Skykill:BAAALgAECgcJBwAAAA==.',
So='Souleva:BAABLgAECn8gAAMJAAkJQCPfAwCXAwAJAAkJQCPfAwCXAwAOAAkJNhSNBACqAQABLgAFFAYJCgAPAI8RAA==.',
Su='Sundro:BAAALgAECgYJDgAAAA==.Sunsam:BAAALgAECgEJAQAAAA==.',
Te='Tears:BAABLgAFFH8MAAICAAUJ8BX/CABnAQACAAUJ8BX/CABnAQAAAA==.',
Tu='Tupac:BAAALgAECgMJBgAAAA==.',
Un='Unicron:BAAALgAFFAEJAQABLgAFFAMJCQACAI0RAA==.',
Us='Usaki:BAAALgADCgUJBQAAAA==.',
Ve='Verra:BAABLgAFFH8EAAMQAAMJjg9yAgBpAAAQAAEJcCJyAgBpAAAKAAIJHAYgTQBMAAAAAA==.',
Vi='Violet:BAAALgAECgUJCAAAAA==.Vitoria:BAAALgADCgEJAQAAAA==.',
Vn='Vnida:BAAALgAECgYJDQAAAA==.',
Vo='Vocaloid:BAAALgAECgEJAQAAAA==.',
Wl='Wlrain:BAAALgADCgcJDAAAAA==.',
Wr='Wraith:BAAALgAECgEJAQAAAA==.',
Wz='Wzxw:BAAALgAECgYJBgAAAA==.',
Xi='Xiaobaiam:BAAALgAECgEJAQAAAA==.',
Za='Zaza:BAAALgAECgYJBgAAAA==.',
['Ââ']='Ââãâãââãâ:BAAALgAECgIJAgAAAA==.',
['一代']='一代法神:BAAALgAECgcJBwAAAA==.',
['一千']='一千年一只:BAAALgADCgUJBwAAAA==.',
['一只']='一只酸奶牛:BAAALgAECgUJCQAAAA==.',
['一碗']='一碗白稀饭:BAAALgAECgQJBAAAAA==.',
['一线']='一线副导:BAAALgADCgYJBgAAAA==.',
['一页']='一页:BAAALgADCgEJAQAAAA==.',
['一齐']='一齐天大圣一:BAAALgAECgcJBwAAAA==.',
['七彩']='七彩:BAAALgAECgEJAgAAAA==.',
['七步']='七步亦成诗:BAAALgADCgMJAwAAAA==.',
['三个']='三个坏苹果:BAAALgADCgcJBwAAAA==.',
['下周']='下周必出凤凰:BAABLgAFFH8GAAIRAAMJoQ9XCADTAAARAAMJoQ9XCADTAAAAAA==.',
['不二']='不二:BAAALgAECgcJDAAAAA==.',
['不屈']='不屈的战魂:BAAALgAECgIJAgAAAA==.',
['不稀']='不稀罕:BAAALgAFFAIJAgAAAA==.',
['世间']='世间的糖:BAAALgAECgcJCwAAAA==.',
['东云']='东云名乃:BAAALgADCgYJBgAAAA==.',
['两点']='两点水:BAAALgAECgIJBAAAAA==.',
['丨婷']='丨婷丨:BAAALgAECgUJBgAAAA==.',
['临渊']='临渊火舞:BAAALgAFFAEJAgAAAA==.临渊独舞:BAAALgAECgYJCQAAAA==.',
['丶何']='丶何小萌丶:BAAALgAECgYJDAAAAA==.',
['丶大']='丶大仔:BAAALgAECgEJAQAAAA==.',
['丶幸']='丶幸运之星:BAAALgAECgIJAgAAAA==.',
['丶星']='丶星辰墜落:BAAALgADCgIJAgAAAA==.',
['丶月']='丶月亮:BAAALgAECgQJBgAAAA==.',
['丶清']='丶清风云月影:BAABLgAFFH8GAAIJAAIJ+wWSJgCFAAAJAAIJ+wWSJgCFAAAAAA==.',
['丶点']='丶点到为止:BAAALgAECgIJAgAAAA==.',
['丶王']='丶王大锤:BAAALgAECgMJAwAAAA==.',
['丶白']='丶白华菅兮:BAAALgAECgYJCQAAAA==.',
['丶红']='丶红:BAAALgAECgYJBwAAAA==.',
['丶茜']='丶茜茜:BAAALgAECgYJBgAAAA==.',
['丶蓝']='丶蓝白皮蛋:BAAALgAFFAIJAgAAAA==.',
['丶迪']='丶迪迦奥特曼:BAABLgAFFH8IAAIMAAQJoglECwAkAQAMAAQJoglECwAkAQAAAA==.',
['丹丹']='丹丹小屁猪:BAAALgAECgIJAgAAAA==.',
['丿永']='丿永恒丶:BAAALgAECgEJAQAAAA==.',
['九星']='九星连板:BAAALgADCgUJBQAAAA==.',
['乱国']='乱国木师:BAAALgAECgUJBQAAAA==.',
['云淡']='云淡月疏:BAAALgAECgcJEgAAAA==.',
['五撒']='五撒气:BAAALgAECgcJBAAAAA==.',
['亚德']='亚德瑞斯:BAAALgAECgIJAwAAAA==.',
['人狮']='人狮之鑫:BAAALgADCgEJAQAAAA==.',
['仰手']='仰手接飞猱:BAACLgAFFH8GAAIMAAMJJyL/CQA0AQAMAAMJJyL/CQA0AQAuAAQKfx0AAgwACAn1JVsCAF8DAAwACAn1JVsCAF8DAAAA.',
['伊人']='伊人执手:BAAALgAECgUJBQAAAA==.',
['伊克']='伊克菲鲁斯:BAABLgAECn8iAAMSAAcJpB8vBQDJAQASAAcJpB8vBQDJAQATAAEJCg/tHgA4AAAAAA==.',
['伊利']='伊利单达雷:BAAALgAECgUJBQAAAA==.',
['伊波']='伊波拉:BAAALgADCgkJCQAAAA==.',
['伍思']='伍思春:BAAALgAECgYJCQAAAA==.伍思春兮:BAAALgAECgMJAwAAAA==.',
['伤遍']='伤遍少女心:BAABLgAECn8aAAINAAkJSyKXAQCMAwANAAkJSyKXAQCMAwAAAA==.',
['你找']='你找奶么:BAAALgAFFAIJAwAAAA==.',
['你看']='你看我憨么:BAAALgAFFAEJAQAAAA==.',
['你被']='你被终结了:BAAALgAFFAIJAgAAAA==.',
['信仰']='信仰之星:BAAALgAECgUJBQABLgAFFAQJDAACAOkeAA==.信仰圣光喵:BAAALgAECgYJBgAAAA==.信仰小和尚:BAAALgAECgYJDAAAAA==.',
['做到']='做到极致:BAAALgAECgEJAQAAAA==.',
['傀儡']='傀儡的拥抱:BAAALgAFFAQJBAAAAA==.',
['傲雪']='傲雪出寒梅:BAAALgAECgcJDAAAAA==.',
['儒此']='儒此多交:BAAALgAECgkJDwAAAA==.',
['克里']='克里斯关下灯:BAAALgAECgUJBwAAAA==.',
['八月']='八月的雾:BAAALgAECgcJBwAAAA==.',
['八神']='八神:BAAALgAECgQJBQAAAA==.',
['公主']='公主灬煊煊:BAAALgAECgEJAQAAAA==.',
['六爪']='六爪章鱼:BAAALgADCgMJAwAAAA==.',
['六里']='六里桥小司机:BAAALgADCgUJBQAAAA==.',
['再戦']='再戦:BAAALgAECgIJAgABLgAFFAYJEAAJAC0hAA==.',
['农村']='农村包围城市:BAAALgAFFAIJAwAAAA==.',
['冠希']='冠希像我:BAAALgAECgQJBgAAAA==.',
['冰冷']='冰冷的木木:BAAALgAECgYJDQAAAA==.冰冷的眼泪:BAABLgAECn8ZAAICAAcJVyPuNACfAgACAAcJVyPuNACfAgAAAA==.冰冷的贱贱:BAAALgAECgYJCAAAAA==.',
['冰砜']='冰砜:BAAALgAECgMJAwAAAA==.',
['冰糖']='冰糖:BAAALgAECgEJAQAAAA==.',
['冰雪']='冰雪圣龙:BAAALgAECgUJBQAAAA==.冰雪归尘:BAABLgAFFH8EAAIKAAIJhg5yIACnAAAKAAIJhg5yIACnAAABLgAFFAUJDAAKAK0mAA==.冰雪暴风:BAABLgAFFH8GAAIUAAIJjhEgEQCFAAAUAAIJjhEgEQCFAAAAAA==.冰雪荣耀:BAAALgADCgEJAQAAAA==.冰雪雷霆:BAAALgAFFAIJAgAAAA==.冰雪魔魇:BAAALgAFFAIJAgAAAA==.',
['凉森']='凉森玲梦:BAAALgAECgEJAgAAAA==.',
['凊茗']='凊茗:BAAALgAECgcJBgAAAA==.',
['凌阳']='凌阳:BAAALgAECgkJBgAAAA==.',
['减肥']='减肥:BAABLgAECn8UAAIVAAcJbBlSKwAJAgAVAAcJbBlSKwAJAgAAAA==.减肥长个子:BAAALgAECgcJCwAAAA==.',
['凤翼']='凤翼天翔丶:BAAALgAECgYJCQAAAA==.',
['刃月']='刃月:BAAALgAECgEJAQAAAA==.',
['刘经']='刘经理丶:BAAALgAECgEJAQAAAA==.',
['别摸']='别摸我尸体:BAAALgAECgYJBgAAAA==.',
['别砍']='别砍了小鬼:BAAALgAECgQJBAAAAA==.',
['刺客']='刺客五六七:BAABLgAECn8cAAMNAAgJkhulFgCDAgANAAgJkhulFgCDAgAWAAcJgwtWEgCdAQAAAA==.',
['剑魄']='剑魄:BAAALgAECgQJBgAAAA==.',
['劫掠']='劫掠:BAAALgAECggJCAABLgAFFAUJCQAJAGomAA==.',
['北极']='北极放羊:BAAALgAECgYJCAAAAA==.',
['北调']='北调八觉:BAAALgAFFAIJAgAAAA==.',
['千棘']='千棘:BAAALgAECgEJAQAAAA==.',
['南极']='南极长生大帝:BAAALgAECgUJCAAAAA==.',
['卡罗']='卡罗灬米尔:BAAALgAECgYJBgAAAA==.',
['卡萨']='卡萨西法:BAAALgAECgMJCAAAAA==.',
['卯之']='卯之花八千流:BAAALgAECgEJAQABLgAFFAcJBQAXANEWAA==.卯之花烈:BAAALgAFFAEJAQAAAA==.',
['即非']='即非世界:BAABLgAFFH8JAAIGAAIJ2hySIwCyAAAGAAIJ2hySIwCyAAAAAA==.',
['叁拾']='叁拾:BAAALgAECgYJBgAAAA==.',
['双四']='双四核动力:BAAALgAECgUJBQAAAA==.',
['只为']='只为矫花:BAAALgADCgIJAgAAAA==.',
['叫我']='叫我恶龙就好:BAAALgAFFAIJBAAAAA==.',
['可爱']='可爱夏曦曦:BAAALgADCgEJAQAAAA==.可爱的银叶花:BAAALgAFFAIJBAAAAA==.可爱的馒头:BAAALgAECgEJAQAAAA==.',
['吃我']='吃我一大冰刺:BAAALgAECgYJCQAAAA==.吃我一大更:BAAALgAECgYJEAAAAA==.',
['吃肉']='吃肉长肉啦:BAAALgAECgYJCQAAAA==.',
['名伶']='名伶:BAABLgAFFH8GAAMBAAIJ7AdcEQCDAAABAAIJ4QZcEQCDAAAYAAEJbwwPEgBLAAAAAA==.',
['名木']='名木城小都:BAAALgADCgcJBwAAAA==.',
['君往']='君往何处:BAAALgADCgEJAQAAAA==.',
['听雷']='听雷:BAAALgAFFAIJBAAAAA==.',
['吴二']='吴二狗:BAAALgAFFAQJBAAAAA==.',
['吴先']='吴先生:BAAALgAECgIJBAAAAA==.',
['吴悠']='吴悠:BAAALgADCgUJBQAAAA==.',
['呼册']='呼册册:BAAALgAECgEJAgAAAA==.',
['咩咩']='咩咩羊不喝酒:BAAALgAECgEJAQAAAA==.咩咩羊壮壮:BAAALgAFFAIJBAAAAA==.',
['哆啦']='哆啦梦:BAAALgAECgEJAQAAAA==.',
['哇踏']='哇踏哟嘟吟闹:BAAALgAECgUJCgAAAA==.',
['哈哈']='哈哈俊俏生:BAAALgAECgEJAQAAAA==.',
['哎哟']='哎哟小母牛:BAAALgAECgEJAQAAAA==.哎哟我弑夜啊:BAAALgAFFAIJBAAAAA==.',
['唐寅']='唐寅君:BAAALgAFFAEJAgAAAA==.',
['喜欢']='喜欢夢:BAAALgAFFAMJAwAAAA==.',
['嗜血']='嗜血妖怪:BAAALgAFFAEJAgAAAA==.嗜血的宁神花:BAABLgAFFH8GAAICAAIJ4w9TPwCvAAACAAIJ4w9TPwCvAAAAAA==.嗜血锝牛牛:BAAALgADCgUJCQAAAA==.',
['嗷嗷']='嗷嗷小怪兽:BAAALgAFFAEJAQAAAA==.',
['嘻哈']='嘻哈德神:BAAALgADCgEJAQAAAA==.',
['囡囚']='囡囚囨囚囨図:BAAALgAECgQJBAAAAA==.',
['圆明']='圆明:BAABLgAECn8UAAMZAAgJJxSnGwDcAQAZAAgJJxSnGwDcAQAYAAYJpgwXDgAYAQAAAA==.',
['土地']='土地公:BAAALgAFFAIJAgAAAA==.',
['圣光']='圣光乳牛:BAAALgAFFAIJBAAAAA==.圣光已欠费:BAAALgAECgEJAgAAAA==.圣光的洗礼:BAAALgAECgYJCgAAAA==.',
['圣园']='圣园未花丶:BAAALgAECgEJAQAAAA==.',
['地牌']='地牌面分:BAAALgAECgQJBQAAAA==.',
['坚强']='坚强的点点:BAAALgAFFAEJAQAAAA==.',
['墨鈅']='墨鈅呍殇:BAAALgAECgYJBwAAAA==.',
['壞壞']='壞壞的尒徳:BAAALgADCgEJAQAAAA==.',
['复古']='复古清苑:BAAALgADCgYJBgAAAA==.',
['夏夜']='夏夜清風:BAAALgAECgQJBAAAAA==.',
['多吉']='多吉咖啡:BAAALgAECgMJBAAAAA==.',
['多橙']='多橙装的眼罩:BAAALgAFFAIJBAAAAA==.',
['夜丨']='夜丨无丨殇:BAAALgAECgEJAQAAAA==.',
['夜月']='夜月聆风:BAABLgAECn8UAAMaAAgJwAwoDwBfAQAaAAgJ8QsoDwBfAQAHAAEJDQ6xHAA3AAAAAA==.',
['夜神']='夜神灬月:BAAALgAECgkJEAABLgAFFAMJCAAbAM0MAA==.',
['夜谧']='夜谧:BAAALgAECgUJBwAAAA==.',
['大傻']='大傻春:BAABLgAFFH8HAAIBAAMJ8Q7rCwDUAAABAAMJ8Q7rCwDUAAAAAA==.',
['大噶']='大噶的风格:BAAALgAFFAEJAQAAAA==.',
['大学']='大学生活好:BAAALgADCgIJAgAAAA==.',
['大鍅']='大鍅师:BAAALgAFFAEJAgAAAA==.',
['大顶']='大顶山梁朝伟:BAAALgAECgIJAwAAAA==.',
['天使']='天使屁屁凉:BAAALgAECgYJBwAAAA==.天使柒:BAAALgAECgYJCwAAAA==.天使耍流氓:BAAALgAECgYJDAAAAA==.',
['天天']='天天吃苞字:BAAALgAECgcJBwAAAA==.',
['天菜']='天菜又爱玩:BAAALgAECgQJBQAAAA==.',
['太聪']='太聪明的猪:BAAALgADCgMJAwABLgAECgMJAwAIAAAAAA==.',
['夿倒']='夿倒烫:BAAALgAFFAIJAgAAAA==.',
['奇鲁']='奇鲁莉安:BAAALgAECgIJAwAAAA==.',
['奈何']='奈何:BAAALgAECgEJAQAAAA==.',
['奔波']='奔波儿菠萝:BAAALgAECgYJBgAAAA==.',
['奔腾']='奔腾小野猪:BAAALgAECgQJBAAAAA==.',
['奶白']='奶白地雪子:BAAALgAFFAIJAgAAAA==.奶白牛大叔:BAAALgADCgYJBgAAAA==.',
['奶茶']='奶茶:BAAALgAFFAQJBAAAAA==.',
['她的']='她的比赛不进:BAAALgAECgIJAgAAAA==.',
['妈妈']='妈妈来救你:BAAALgADCgUJBQAAAA==.',
['妖怪']='妖怪当神仙:BAAALgAECgcJDAAAAA==.',
['姚之']='姚之明:BAAALgAFFAEJAQAAAA==.',
['姜无']='姜无望:BAABLgAFFH8GAAIYAAIJexbTCwClAAAYAAIJexbTCwClAAAAAA==.',
['宝爷']='宝爷:BAAALgADCgEJAQAAAA==.',
['宸宸']='宸宸林二:BAAALgAECggJCAAAAA==.',
['寂月']='寂月灭影:BAAALgAECgIJAgAAAA==.',
['寒月']='寒月璃殇羽:BAAALgADCgcJBwAAAA==.',
['寒江']='寒江雪:BAABLgAECn8fAAIGAAkJbyPaAgCiAwAGAAkJbyPaAgCiAwABLgAFFAYJEgAGAFkWAA==.',
['寰宇']='寰宇天罚丶:BAAALgAFFAQJAQAAAA==.',
['将丿']='将丿臣:BAAALgAECgEJAQAAAA==.',
['小哈']='小哈:BAAALgAFFAIJAgAAAA==.',
['小小']='小小一族:BAAALgAECgEJAQAAAA==.小小羊:BAAALgAECgEJAQAAAA==.',
['小布']='小布欧:BAAALgAECgYJBgAAAA==.',
['小牛']='小牛牛飞吧:BAAALgAECgEJAgAAAA==.',
['小疯']='小疯儿宝宝:BAAALgADCgcJBwAAAA==.',
['小白']='小白圣斗士:BAAALgAECgQJBAAAAA==.',
['小笨']='小笨蛋三号:BAACLgAFFH8QAAIMAAUJ+h0GAgCUAQAMAAUJ+h0GAgCUAQAuAAQKfx0AAgwACAnMD0Q2AKoBAAwACAnMD0Q2AKoBAAAA.',
['小米']='小米超强钢:BAAALgAECgUJCQAAAA==.',
['小芳']='小芳猪:BAAALgAECgcJBwAAAA==.',
['小药']='小药丸:BAAALgADCgYJBgAAAA==.',
['小魔']='小魔籹:BAAALgADCgYJBgAAAA==.',
['小鸡']='小鸡要过马路:BAACLgAFFH8XAAIEAAUJxQjgAgBzAQAEAAUJxQjgAgBzAQAuAAQKfysAAwQABwnCE3UoAK0BAAQABwnCE3UoAK0BAAUAAgn+AkJQAE0AAAAA.',
['少林']='少林寺当家:BAAALgAFFAIJAgAAAA==.',
['尛凤']='尛凤仙:BAAALgAFFAEJAQAAAA==.',
['尛焱']='尛焱孨乂:BAAALgADCgYJBgAAAA==.',
['尛鈊']='尛鈊汎:BAAALgADCgYJBgAAAA==.',
['尤斯']='尤斯蒂亚:BAAALgADCgYJBgABLgADCgcJBwAIAAAAAA==.',
['山寨']='山寨萨满:BAAALgAECgQJAwAAAA==.',
['巴利']='巴利斯坦:BAAALgADCgQJBAAAAA==.',
['巴巴']='巴巴丨博一:BAAALgAECgcJAgAAAA==.',
['巴洛']='巴洛特里:BAAALgAECggJCAAAAA==.',
['布劳']='布劳登丶:BAAALgAFFAIJAgAAAA==.',
['布洛']='布洛克斯西伽:BAAALgAECgIJAgAAAA==.',
['帅帅']='帅帅惹人爱丶:BAAALgAFFAIJAwAAAA==.',
['常务']='常务副盔猪:BAAALgADCgUJBQAAAA==.',
['幸运']='幸运无极限:BAAALgAECgIJAgAAAA==.',
['幻刺']='幻刺:BAAALgAFFAIJAwAAAA==.',
['幻灭']='幻灭德:BAAALgAECgEJAQAAAA==.',
['幽灵']='幽灵晓晓丶:BAAALgAECgcJAwABLgAFFAUJEQADAIwhAA==.',
['康师']='康师傅口渴了:BAAALgADCgMJAwAAAA==.',
['开飞']='开飞机的舒克:BAAALgADCgUJAQAAAA==.',
['张翼']='张翼徳:BAAALgADCgYJBgAAAA==.',
['弦断']='弦断有谁听:BAAALgAECgIJAgAAAA==.',
['彩虹']='彩虹恋雨:BAABLgAECn8ZAAMEAAgJ1xArLQCRAQAEAAcJSRIrLQCRAQAFAAQJiAx2EgDEAAAAAA==.',
['彭于']='彭于验:BAABLgAFFH8FAAIRAAMJIwyXDACBAAARAAMJIwyXDACBAAAAAA==.',
['影落']='影落璃:BAAALgAECgEJAQAAAA==.',
['往事']='往事重提:BAAALgAECgEJAgAAAA==.',
['徐旭']='徐旭:BAABLgAECn8XAAMJAAkJvyHdDQAsAwAJAAkJuyHdDQAsAwAOAAYJtRSEJQATAQAAAA==.',
['微笑']='微笑的椰子:BAAALgAECgEJAQAAAA==.',
['微风']='微风的响声:BAAALgAECgMJAwAAAA==.',
['德拉']='德拉萨:BAAALgAECgEJAwAAAA==.',
['心情']='心情愉悦:BAAALgAFFAMJBAAAAA==.',
['心灵']='心灵歌唱家:BAAALgAECgcJCAAAAA==.',
['忘之']='忘之:BAAALgADCgUJBQAAAA==.',
['怀中']='怀中把妹杀:BAAALgADCgEJAQAAAA==.',
['怒风']='怒风之眼:BAAALgADCgIJAgAAAA==.',
['思想']='思想要集中:BAAALgAECgcJBwABLgAFFAEJAgAIAAAAAA==.',
['性灬']='性灬感的母牛:BAAALgAFFAIJBAAAAA==.',
['恋上']='恋上你的人:BAAALgAECgUJBQAAAA==.',
['恰雷']='恰雷姆:BAAALgAECgUJCAAAAA==.',
['悍匪']='悍匪李二小:BAAALgAECggJDAAAAA==.',
['悟空']='悟空大官人:BAAALgAECgEJAQAAAA==.',
['患者']='患者中二:BAAALgAECgUJCAAAAA==.',
['惩戒']='惩戒六:BAAALgAECgUJBQAAAA==.惩戒的荣耀:BAAALgAECgQJBAAAAA==.',
['愤怒']='愤怒的卤鸡蛋:BAAALgAECgYJDQAAAA==.愤怒的瓜子壳:BAAALgAECgEJAQAAAA==.',
['慧眼']='慧眼识猪:BAAALgAECgIJAgAAAA==.',
['懂王']='懂王:BAAALgAECgMJBQAAAA==.',
['懒懒']='懒懒的阿水:BAABLgAECn8YAAMcAAcJHg9YAwBLAQAcAAcJHg9YAwBLAQAdAAYJywNgMQDlAAAAAA==.',
['戊龙']='戊龙阁陈师傅:BAAALgAECgUJBQAAAA==.',
['我上']='我上早八丶:BAAALgAECgIJAwAAAA==.',
['我不']='我不喝假酒:BAAALgADCgEJAgAAAA==.',
['我也']='我也在这儿:BAAALgAECgEJAgAAAA==.',
['我是']='我是你的梦魇:BAAALgAECgEJAQAAAA==.',
['我有']='我有多少秘密:BAAALgADCgEJAQABLgAFFAIJBAAIAAAAAA==.',
['我需']='我需要碰撞:BAAALgADCgMJAwAAAA==.',
['打破']='打破次元壁:BAABLgAECn8WAAMbAAcJfxHDPgB9AQAbAAcJfxHDPgB9AQAPAAEJXAyfTwEsAAAAAA==.',
['托尼']='托尼史塔克:BAAALgAFFAQJBAAAAA==.',
['执著']='执著:BAACLgAFFH8NAAMVAAQJlw5kCQDcAAAVAAMJARBkCQDcAAAeAAIJdga9BwCUAAAuAAQKfxYAAxUABwlxG1o0ANgBABUABgkGHVo0ANgBAB4AAwkGFpokAMgAAAAA.',
['扬帆']='扬帆:BAAALgAECgQJBAABLgAFFAUJEwAbAOEiAA==.',
['拉个']='拉个面:BAAALgAECgQJAgAAAA==.',
['拉格']='拉格纳洛克:BAAALgAECgYJDgAAAA==.',
['拜勒']='拜勒岗少雲:BAAALgAECgEJAQAAAA==.',
['排云']='排云掌:BAAALgAECgYJBgAAAA==.',
['摇了']='摇了摇头:BAAALgAECgUJBgAAAA==.',
['摩卡']='摩卡:BAAALgAECgYJBAAAAA==.',
['摸摸']='摸摸奖:BAAALgAFFAIJAgAAAA==.',
['支棱']='支棱起来:BAAALgADCgIJAgAAAA==.',
['故事']='故事开始了:BAAALgAECgcJDgABLgAFFAEJAgAIAAAAAA==.',
['整点']='整点大肥又:BAAALgAECgUJBQAAAA==.',
['文之']='文之狼:BAAALgAECgQJCAAAAA==.',
['斗鱼']='斗鱼铁人阿瑞:BAABLgAFFH8LAAIJAAQJJxkTEQBdAQAJAAQJJxkTEQBdAQAAAA==.',
['断角']='断角:BAAALgAECgIJAwAAAA==.',
['斯嘉']='斯嘉丽的梦境:BAAALgAECgUJBwAAAA==.',
['无印']='无印一小法:BAAALgAECgEJAQAAAA==.',
['无塔']='无塔:BAAALgADCgYJBwAAAA==.',
['无毀']='无毀的湖光:BAAALgAECgIJAgAAAA==.',
['时廊']='时廊之伤:BAAALgAECgcJEAAAAA==.',
['时肆']='时肆初冬:BAAALgADCgEJAgAAAA==.',
['旷野']='旷野:BAAALgADCgEJAQAAAA==.',
['明月']='明月丶潜行者:BAAALgADCgEJAQAAAA==.',
['星河']='星河夜:BAAALgAECgUJBQAAAA==.',
['星茫']='星茫癫:BAAALgAECgEJAQAAAA==.',
['昭烈']='昭烈帝:BAABLgAFFH8IAAIGAAQJ0xuZBwBGAQAGAAQJ0xuZBwBGAQABLgAFFAUJBQABAEkBAA==.',
['是小']='是小狸花:BAAALgAECgkJEgAAAA==.是小玳瑁:BAAALgAECgkJCQAAAA==.',
['暮色']='暮色回想:BAAALgADCgcJBwAAAA==.',
['暴躁']='暴躁的大熊猫:BAAALgAECgQJBQAAAA==.暴躁面团:BAAALgADCgEJAQAAAA==.',
['曜之']='曜之阑:BAAALgAECgYJBgABLgAFFAUJBAAIAAAAAA==.',
['曼联']='曼联八号:BAAALgAECgUJBwABLgAFFAcJCwABAM0PAA==.曼联十六号:BAAALgAECgYJBgAAAA==.曼联十号:BAAALgAECgYJCwAAAA==.',
['最后']='最后一颗:BAAALgAECgEJAQAAAA==.',
['月之']='月之契约:BAAALgAECgQJBAAAAA==.',
['术也']='术也有专弓:BAAALgAECgYJBgAAAA==.',
['来路']='来路做归途:BAACLgAFFH8IAAQfAAMJDhluGgCvAAAfAAIJkBRuGgCvAAAWAAIJtAi5BgCmAAANAAEJCiLPHQBnAAAuAAQKfysABB8ACAkGIw4NANwCAB8ACAmmIQ4NANwCABYABwm6G0EDAPMBAA0ABAmeI4xKAIoBAAAA.',
['杰瑞']='杰瑞儿:BAAALgAECgQJBQAAAA==.',
['林七']='林七夜:BAAALgADCgEJAQAAAA==.',
['林冲']='林冲骑武松:BAAALgAECgEJAgAAAA==.',
['林晨']='林晨:BAAALgAECgcJCgAAAA==.',
['林海']='林海的神话:BAABLgAFFH8IAAMDAAIJ0h0TDgC3AAADAAIJ0h0TDgC3AAAEAAEJChHmFABBAAAAAA==.',
['柒贰']='柒贰丶壹壹:BAAALgAECgMJBAAAAA==.',
['柠檬']='柠檬茶丶丶:BAAALgADCgEJAQAAAA==.',
['柳叶']='柳叶刀:BAAALgADCgUJBQAAAA==.',
['树叶']='树叶下的阴影:BAAALgAECgcJBwAAAA==.',
['格拉']='格拉西莫夫:BAABLgAECn8fAAIKAAcJEg3cHQBQAQAKAAcJEg3cHQBQAQAAAA==.',
['桃醉']='桃醉:BAAALgADCgEJAQAAAA==.',
['梨园']='梨园青衣:BAAALgAFFAIJAgAAAA==.',
['棒棒']='棒棒糖:BAAALgADCgUJBQAAAA==.',
['森林']='森林守猎者:BAAALgAECgEJAQAAAA==.',
['楚伦']='楚伦娜丨铁蹄:BAAALgAECgEJAQAAAA==.',
['正在']='正在进行加载:BAAALgAECgEJAQAAAA==.',
['死亦']='死亦何惧:BAAALgAECgYJDAAAAA==.',
['残发']='残发:BAAALgADCgYJBgAAAA==.',
['残疾']='残疾:BAAALgAECgkJDwAAAA==.',
['每次']='每次我射给你:BAAALgADCgIJAgAAAA==.',
['永恒']='永恒的紫罗兰:BAABLgAFFH8IAAIGAAQJbg/JEgA7AQAGAAQJbg/JEgA7AQAAAA==.',
['江南']='江南第一深情:BAAALgAFFAIJBAAAAA==.',
['江江']='江江最可爱:BAABLgAECn8aAAMYAAkJIBtrDgCWAgAYAAkJMRdrDgCWAgABAAgJwxoLFABvAgABLgAFFAQJCAABALATAA==.江江超可爱:BAAALgAECgkJDwAAAA==.江江超萌萌:BAAALgAECgkJCQABLgAECgcJFQALACMWAA==.',
['污哒']='污哒哒:BAAALgAECgEJAQAAAA==.',
['汽水']='汽水重来:BAAALgAECgYJBgAAAA==.',
['沐沐']='沐沐徐徐:BAAALgADCgEJAQAAAA==.',
['沐錦']='沐錦:BAABLgAECn8YAAINAAcJAxKqQACtAQANAAcJAxKqQACtAQAAAA==.',
['沙丶']='沙丶滩:BAAALgAECgMJAwAAAA==.',
['沫然']='沫然雨落:BAAALgAECgQJBAAAAA==.',
['河口']='河口陈奕迅:BAABLgAECn8WAAIPAAgJgxugLABxAgAPAAgJgxugLABxAgAAAA==.',
['法灬']='法灬海:BAAALgADCgMJAwAAAA==.',
['法蓝']='法蓝:BAAALgAECgEJAQAAAA==.',
['泡腾']='泡腾片片:BAAALgAECgQJCQAAAA==.',
['泰勒']='泰勒上尉丶:BAAALgAECgYJCwAAAA==.',
['洛璃']='洛璃:BAAALgAECgEJAQAAAA==.',
['洛莉']='洛莉维尔:BAAALgAECgUJBQAAAA==.',
['流刃']='流刃诺火:BAAALgAFFAIJAgAAAA==.',
['浅妆']='浅妆薄黛丶:BAAALgAFFAQJBAAAAA==.',
['浅妝']='浅妝薄黛:BAAALgAFFAEJAQAAAA==.',
['浪琴']='浪琴:BAAALgAECgYJDgAAAA==.',
['浮耀']='浮耀:BAAALgAECgkJAwAAAA==.',
['海军']='海军上将泰勒:BAAALgAECgYJBAAAAA==.',
['消失']='消失的星辰:BAAALgAECgIJAgAAAA==.',
['淼淼']='淼淼:BAAALgAFFAIJAgAAAA==.',
['清玄']='清玄:BAABLgAFFH8FAAIBAAMJegsXFgDDAAABAAMJegsXFgDDAAAAAA==.',
['清茶']='清茶:BAAALgAECgYJCgAAAA==.',
['清风']='清风丶大祭司:BAAALgAECgQJBAAAAA==.',
['渡月']='渡月桥思君:BAAALgADCgEJAQAAAA==.',
['渣渣']='渣渣珲:BAAALgAECgMJAwAAAA==.',
['游侠']='游侠枫:BAAALgAFFAEJAQAAAA==.',
['溜了']='溜了个溜:BAAALgADCgYJBgAAAA==.',
['溜冰']='溜冰兔:BAAALgAECgEJAwAAAA==.',
['滄海']='滄海一聲笑:BAAALgADCgEJAQAAAA==.',
['漆黑']='漆黑之光:BAAALgAECgEJAwAAAA==.',
['潘多']='潘多拉之葉:BAAALgADCgQJBAAAAA==.',
['潼宝']='潼宝宝:BAAALgAECgUJBgAAAA==.',
['澳沙']='澳沙利文:BAAALgAECgUJBgAAAA==.',
['火舞']='火舞不知:BAAALgAECgQJBgAAAA==.',
['灬璇']='灬璇珱丶:BAAALgAFFAIJBAAAAA==.',
['灬盛']='灬盛夏光年灬:BAAALgAECgMJBQAAAA==.',
['灬荭']='灬荭丶丨:BAABLgAFFH8GAAMbAAMJ9hfICgCoAAAbAAMJ9hfICgCoAAAPAAEJDAceNwBKAAAAAA==.',
['灰烬']='灰烬天惩:BAAALgAECgQJBAAAAA==.',
['灰狐']='灰狐狸:BAAALgAFFAEJAQAAAA==.',
['灵魂']='灵魂圣王:BAAALgAECgEJAQAAAA==.灵魂战王:BAAALgADCgEJAQAAAA==.',
['炮兵']='炮兵乙:BAAALgAECgUJCgAAAA==.',
['点到']='点到为止:BAAALgAECgYJEgAAAA==.',
['烈空']='烈空座:BAAALgAFFAQJBAAAAA==.',
['烟在']='烟在指尖旋转:BAAALgADCgQJBAAAAA==.烟在指尖缠绕:BAAALgAECgUJBQAAAA==.烟在指尖飞舞:BAAALgAFFAEJAQAAAA==.',
['烟雨']='烟雨曚昽:BAAALgAECggJCAAAAA==.',
['烧尽']='烧尽:BAAALgAFFAIJAgAAAA==.',
['热心']='热心街坊:BAAALgAECgEJAQAAAA==.',
['然然']='然然:BAAALgAFFAQJAgABLgAFFAQJBgADAAcWAA==.',
['煊煊']='煊煊小公主:BAAALgAECgYJBgAAAA==.',
['煙滅']='煙滅:BAABLgAFFH8GAAIJAAIJXiYOFwDgAAAJAAIJXiYOFwDgAAAAAA==.',
['煞姬']='煞姬:BAAALgADCgUJBQAAAA==.',
['煭吙']='煭吙熊吢:BAAALgAFFAQJBAAAAA==.',
['熊猫']='熊猫武侠:BAAALgAFFAEJAQAAAA==.',
['爱是']='爱是永恒毁灭:BAABLgAFFH8FAAIKAAMJHQa8JgDkAAAKAAMJHQa8JgDkAAAAAA==.',
['爱莉']='爱莉希雅:BAACLgAFFH8RAAIPAAUJaCM9AgDnAQAPAAUJaCM9AgDnAQAuAAQKfxsAAg8ACAkEI0ULADQDAA8ACAkEI0ULADQDAAAA.',
['爱跳']='爱跳蹦叉叉:BAAALgAECgYJBgABLgAFFAIJAgAIAAAAAA==.',
['牛头']='牛头人:BAAALgAECggJDQAAAA==.',
['牛牛']='牛牛贼:BAAALgAECgEJAQAAAA==.',
['牛鼻']='牛鼻龙:BAAALgAECgEJAQAAAA==.',
['牧已']='牧已沉舟:BAAALgAECgMJAwAAAA==.',
['牧无']='牧无王法:BAAALgADCgEJAQAAAA==.',
['特大']='特大反派:BAABLgAFFH8GAAIPAAMJRhOZFgD3AAAPAAMJRhOZFgD3AAAAAA==.',
['特雷']='特雷莎:BAAALgAECgYJCwAAAA==.',
['犀利']='犀利的小猎:BAABLgAFFH8FAAINAAIJqx5uEADFAAANAAIJqx5uEADFAAAAAA==.',
['狂暴']='狂暴女娃子:BAAALgAECgYJBgAAAA==.',
['狂野']='狂野的宁神花:BAAALgADCgMJAwAAAA==.狂野魔法浪涌:BAAALgAECgIJAgAAAA==.',
['狼宝']='狼宝宝:BAAALgAECgYJBgAAAA==.',
['王四']='王四有:BAAALgADCgEJAQAAAA==.',
['王大']='王大锤:BAAALgAECgIJAgAAAA==.',
['玛沙']='玛沙那:BAAALgAECgUJCAAAAA==.',
['球迷']='球迷:BAABLgAFFH8FAAMNAAMJMBmXCQAUAQANAAMJMBmXCQAUAQAfAAEJ1hBsJwBNAAAAAA==.',
['瓦尔']='瓦尔修斯:BAAALgAECgEJAQAAAA==.',
['用完']='用完呢牙膏:BAAALgAECgIJAgAAAA==.',
['甩米']='甩米线丶:BAABLgAECn8SAAMKAAkJUhd6NQA2AgAKAAkJpRJ6NQA2AgALAAUJxRbDGwBvAQAAAA==.',
['田馥']='田馥帧:BAACLgAFFH8IAAIBAAMJaxfbEQDsAAABAAMJaxfbEQDsAAAuAAQKfxcAAgEACAlBHfIaAC0CAAEACAlBHfIaAC0CAAAA.',
['电瓶']='电瓶车:BAAALgADCgEJAQAAAA==.',
['电磁']='电磁骑士:BAAALgAECgEJAgAAAA==.',
['疯狂']='疯狂之萨:BAAALgAECgYJCgAAAA==.疯狂的卤鸡蛋:BAAALgAECgYJEwAAAA==.',
['疾风']='疾风步跳劈:BAABLgAFFH8IAAIeAAQJFhJ+AQBUAQAeAAQJFhJ+AQBUAQABLgAFFAQJCwAJACcZAA==.',
['痞子']='痞子熊:BAAALgAECgcJCgAAAA==.',
['白墨']='白墨离魂:BAAALgAECgIJBQAAAA==.',
['百里']='百里爱:BAABLgAFFH8JAAIZAAMJOwglDQDSAAAZAAMJOwglDQDSAAAAAA==.',
['直到']='直到舒服为止:BAAALgAECgEJAQAAAA==.',
['看什']='看什么看:BAAALgADCgEJAQAAAA==.',
['睁眼']='睁眼说瞎话:BAAALgAECgMJAwAAAA==.',
['睡到']='睡到自然醒:BAAALgAECgYJBgAAAA==.',
['睿珂']='睿珂钠:BAAALgAECgEJAQAAAA==.',
['瞎的']='瞎的不行:BAAALgAECgYJBAABLgAFFAEJAgAIAAAAAA==.',
['知亮']='知亮莫若达:BAAALgAECgQJBgAAAA==.',
['破刃']='破刃之剑:BAAALgAECgEJAgAAAA==.',
['破晓']='破晓流砂:BAAALgAECgYJBgAAAA==.',
['硬汉']='硬汉丶加摩尔:BAAALgAECgEJAgAAAA==.',
['碎碎']='碎碎猪:BAAALgAECgEJAQAAAA==.',
['碎蛋']='碎蛋神手:BAAALgAECgYJCgAAAA==.',
['神一']='神一般的奶:BAAALgAFFAIJAgAAAA==.',
['神狂']='神狂:BAAALgAFFAEJAgAAAA==.',
['神秘']='神秘的肚兜:BAAALgAFFAIJAgAAAA==.',
['禁用']='禁用字符:BAAALgAECgIJAQAAAA==.',
['秋秋']='秋秋小公举:BAAALgADCgYJBgAAAA==.',
['空崎']='空崎日奈丶:BAAALgAECgYJDQAAAA==.',
['空降']='空降神偷:BAAALgADCgIJAgAAAA==.',
['穿拖']='穿拖鞋的羊:BAAALgADCgIJAgAAAA==.',
['窗旁']='窗旁的小豆豆:BAAALgAFFAEJAQAAAA==.',
['筱筱']='筱筱法:BAAALgAECgQJBAAAAA==.',
['米浴']='米浴:BAAALgAFFAEJAQAAAA==.',
['粉红']='粉红色的梦:BAAALgAECgYJCgAAAA==.',
['精锐']='精锐榜眼丶:BAAALgADCgEJAQAAAA==.',
['紅塵']='紅塵客棧:BAAALgAECgEJAQAAAA==.',
['紫骑']='紫骑:BAABLgAECn8VAAIPAAcJECAlJACXAgAPAAcJECAlJACXAgAAAA==.',
['緈諨']='緈諨約锭:BAAALgAECgEJAQAAAA==.',
['红烧']='红烧肋排:BAAALgADCgMJAwAAAA==.',
['红绿']='红绿鲤鱼骑:BAAALgAECgEJAQAAAA==.',
['纯粹']='纯粹配角:BAAALgAFFAEJAgAAAA==.',
['纸糊']='纸糊的奶好我:BAAALgAECgEJAQAAAA==.',
['细嗅']='细嗅蔷薇乀:BAACLgAFFH8FAAIJAAQJIRQ4CgA+AQAJAAQJIRQ4CgA+AQAuAAQKfxUAAgkACAnNHO0JAPwBAAkACAnNHO0JAPwBAAAA.',
['绝杀']='绝杀弑神:BAAALgAFFAEJAgAAAA==.',
['维泽']='维泽:BAAALgAECgYJCgAAAA==.',
['绿皮']='绿皮怪:BAAALgAECgIJAgAAAA==.',
['绿鲤']='绿鲤鱼与驴:BAAALgAECgMJAwAAAA==.',
['网红']='网红磊磊酱:BAAALgADCgMJAwAAAA==.',
['罪生']='罪生梦死:BAAALgAECgEJAQAAAA==.',
['羙丶']='羙丶尐嬌:BAAALgAECgYJBwAAAA==.',
['翡翠']='翡翠南瓜:BAABLgAFFH8GAAIgAAIJNCLqAgDLAAAgAAIJNCLqAgDLAAAAAA==.',
['翻五']='翻五翻:BAAALgAECgEJAQAAAA==.',
['老吴']='老吴重来:BAAALgAECgYJBwAAAA==.',
['老牛']='老牛奶弃圣光:BAAALgAECgYJDQAAAA==.',
['老登']='老登骑士长:BAAALgAECgUJCAAAAA==.',
['老白']='老白干:BAAALgAECgQJBwAAAA==.',
['老硬']='老硬币:BAAALgAECgEJAQAAAA==.',
['肉松']='肉松面条:BAAALgAECgMJBAAAAA==.',
['肥熊']='肥熊萨萨安:BAAALgAFFAEJAgAAAA==.',
['肾光']='肾光之力:BAAALgAFFAEJAQAAAA==.',
['胡豆']='胡豆一枚:BAAALgAFFAEJAQAAAA==.',
['脑袋']='脑袋痒痒的:BAAALgAECgkJDQAAAA==.',
['腥红']='腥红的复仇:BAAALgAECgEJAQAAAA==.',
['舞林']='舞林传说:BAAALgADCgMJAwAAAA==.舞林神話:BAAALgAECgMJBAAAAA==.舞林神话:BAAALgAECgMJBQAAAA==.',
['艾西']='艾西瓦亞蕾:BAAALgAECgYJBgAAAA==.艾西瓦娅蕾:BAAALgAECgYJBgAAAA==.',
['芙洛']='芙洛莉娅:BAAALgADCgcJBwAAAA==.',
['花月']='花月醉雕鞍:BAAALgAFFAIJAgAAAA==.',
['花海']='花海佑芽丶:BAAALgAECgYJDgAAAA==.花海咲季丶:BAAALgAECgYJCAAAAA==.',
['苏芷']='苏芷:BAAALgAECgEJAQAAAA==.',
['若雨']='若雨无痕:BAABLgAECn8gAAMGAAgJNxqzEQCZAQAHAAYJYhPtIwCdAQAGAAgJNxqzEQCZAQAAAA==.',
['苼歌']='苼歌:BAAALgAECgcJDQAAAA==.',
['茸茸']='茸茸羊:BAAALgAECgIJAwAAAA==.',
['荒御']='荒御魂:BAAALgAFFAEJAQAAAA==.',
['莉莉']='莉莉维尔:BAAALgAECgYJBgAAAA==.',
['莎莉']='莎莉韩森:BAAALgAECgEJAgAAAA==.',
['莫拉']='莫拉斯阿瓦隆:BAAALgAFFAEJAQAAAA==.',
['菊击']='菊击手:BAAALgAECgMJBAAAAA==.',
['菜菜']='菜菜玩得欢:BAAALgAECgYJBgAAAA==.',
['菲炎']='菲炎:BAAALgAECgEJAQAAAA==.',
['萌牛']='萌牛小白:BAAALgADCgcJBwAAAA==.萌牛怪蜀黍:BAAALgADCgUJBQAAAA==.',
['萌猫']='萌猫咪:BAAALgAECgEJAQAAAA==.',
['萧丶']='萧丶菱:BAABLgAFFH8JAAMEAAMJwQtADQCUAAAEAAIJqwhADQCUAAAFAAIJzAziCwCMAAAAAA==.',
['落幕']='落幕日后:BAAALgADCgYJBgAAAA==.',
['落红']='落红微飘:BAAALgADCgEJAQAAAA==.',
['葌尸']='葌尸是种艺术:BAAALgADCgEJAQAAAA==.',
['葛城']='葛城莉莉娅丶:BAAALgAECgMJAwAAAA==.',
['葬神']='葬神灬灭:BAAALgAECgkJDAAAAA==.',
['蒙面']='蒙面银魔:BAAALgAECgUJBQAAAA==.',
['蓝海']='蓝海悦:BAAALgADCggJEAAAAA==.',
['蓝色']='蓝色旗旗:BAAALgAECgEJAQAAAA==.',
['薄荷']='薄荷之夏:BAAALgADCgEJAQAAAA==.',
['虎视']='虎视虎子:BAAALgADCgYJBgABLgADCgcJBwAIAAAAAA==.',
['蛊惑']='蛊惑魅影:BAAALgAECgYJBwAAAA==.',
['蜇无']='蜇无敌:BAAALgAECgQJBgAAAA==.',
['血丶']='血丶小葌:BAAALgAECgEJAQAAAA==.',
['血之']='血之风猎:BAAALgAECgIJAgAAAA==.',
['血影']='血影萌德:BAAALgAFFAQJBAAAAA==.血影萌骑骑:BAABLgAFFH8IAAIPAAQJpAxvDQA/AQAPAAQJpAxvDQA/AQAAAA==.',
['血色']='血色蓝调:BAAALgAECgMJAwAAAA==.',
['術曉']='術曉羽:BAAALgAFFAEJAQABLgAFFAUJDAAKAK0mAA==.',
['西决']='西决:BAAALgADCgEJAQAAAA==.',
['訫無']='訫無杂捻:BAACLgAFFH8MAAICAAQJ6R7xEQCGAQACAAQJ6R7xEQCGAQAuAAQKfxwAAgIACAliIfEfAPUCAAIACAliIfEfAPUCAAAA.',
['訫譩']='訫譩灬月惗:BAAALgAECgYJCgAAAA==.',
['训练']='训练家:BAAALgAECgEJAgAAAA==.',
['试玩']='试玩帐号:BAAALgAECgYJCAAAAA==.',
['读书']='读书不顺:BAAALgAECgQJCQAAAA==.',
['谢谢']='谢谢你喵:BAAALgAECgYJCgAAAA==.',
['豆腐']='豆腐吃的烫:BAAALgAECgYJDAAAAA==.',
['豆芽']='豆芽来我身边:BAAALgAECgcJBwAAAA==.',
['贰鍋']='贰鍋頭:BAAALgADCgMJAwAAAA==.',
['贼中']='贼中贼:BAAALgAECgYJDwAAAA==.',
['赞达']='赞达拉擎天柱:BAAALgAECgQJBwAAAA==.',
['赫斯']='赫斯欧塔:BAAALgAECgYJCwABLgAFFAEJAgAIAAAAAA==.',
['赵云']='赵云丶:BAAALgAECgEJAQAAAA==.',
['超级']='超级奶奶牛:BAAALgAECgEJAQAAAA==.',
['趣味']='趣味乐多多:BAAALgAECgQJAwAAAA==.',
['跌迪']='跌迪:BAAALgAECgEJAQAAAA==.',
['路易']='路易斯一斩杀:BAAALgAECgEJAQAAAA==.',
['路西']='路西法大神:BAAALgAECgYJCgAAAA==.',
['路边']='路边的鱼:BAABLgAFFH8FAAIPAAQJMxKnBQBSAQAPAAQJMxKnBQBSAQAAAA==.',
['跳我']='跳我呢左边:BAAALgAECgYJCAAAAA==.',
['跳晕']='跳晕跳晕:BAAALgAECgQJBAAAAA==.',
['身体']='身体倍儿棒:BAAALgAECgQJDwAAAA==.',
['辛洛']='辛洛斯:BAAALgAECgUJDQAAAA==.',
['辰星']='辰星漫雪:BAAALgAECgcJCQABLgAFFAcJDQARAM4ZAA==.',
['过期']='过期锅包肉:BAAALgADCgEJAQAAAA==.',
['还会']='还会再见吗:BAAALgAECgEJAQAAAA==.',
['还好']='还好技高一筹:BAAALgAECgMJBQAAAA==.',
['这奶']='这奶有毒:BAAALgAECgEJAwAAAA==.',
['这就']='这就是羁绊吧:BAAALgAFFAIJAgAAAA==.',
['迪伽']='迪伽丶奥特曼:BAABLgAECn8ZAAIUAAcJkRvwKQAKAgAUAAcJkRvwKQAKAgAAAA==.',
['迪匹']='迪匹埃斯特喇:BAAALgAECgQJBgAAAA==.',
['迪卡']='迪卡普利奥:BAAALgADCgEJAQAAAA==.',
['逗不']='逗不逗糖豆:BAAALgAECgYJCAAAAA==.',
['逼着']='逼着改名:BAAALgAECgEJAQAAAA==.',
['遛狗']='遛狗减肥:BAAALgAFFAEJAQAAAA==.',
['那个']='那个德:BAAALgAECgYJDgAAAA==.那个邪迪凯:BAAALgAECgEJAQAAAA==.',
['那维']='那维莱特:BAAALgAECggJEgAAAA==.',
['邦帮']='邦帮硬:BAAALgAECgMJBAAAAA==.',
['邪域']='邪域幻灵:BAAALgAECgcJBwAAAA==.',
['邪影']='邪影殇:BAAALgADCgMJAwAAAA==.',
['邪恶']='邪恶的小白:BAAALgADCgUJBQAAAA==.',
['邪迪']='邪迪凯灬:BAAALgAECgQJBQAAAA==.',
['重生']='重生的宁神花:BAAALgAFFAIJBAAAAA==.',
['野划']='野划划:BAAALgAECgEJAQAAAA==.',
['野火']='野火压境:BAABLgAECn8UAAMHAAcJhA/1IQCtAQAHAAcJhA/1IQCtAQAGAAYJKARQrQCzAAAAAA==.',
['銮銮']='銮銮:BAAALgAFFAIJAwAAAA==.',
['钟离']='钟离:BAACLgAFFH8QAAIZAAQJhx2zAwBjAQAZAAQJhx2zAwBjAQAuAAQKfxYAAhkACAl9GgUVACACABkACAl9GgUVACACAAAA.',
['钢普']='钢普拉:BAAALgAECgkJCQAAAA==.',
['铁板']='铁板茄子:BAAALgAFFAIJAgAAAA==.',
['铁血']='铁血雄风:BAAALgADCgMJAwAAAA==.',
['铃木']='铃木羽那丶:BAAALgAECgYJCAAAAA==.',
['银月']='银月城保安:BAAALgAECgEJAQAAAA==.',
['闲疯']='闲疯尒丹:BAAALgAECgYJEAABLgAFFAMJBgARAGIMAA==.',
['队长']='队长别开枪:BAAALgAFFAEJAQAAAA==.',
['阿卜']='阿卜杜拉:BAAALgAECgYJEAAAAA==.',
['阿德']='阿德:BAACLgAFFH8FAAMUAAMJDBBbEgDWAAAUAAMJDBBbEgDWAAAhAAEJ8wFWHQA/AAAuAAQKfxgAAxQABgnfC6xwAAMBABQABgnfC6xwAAMBACEABQlnDYtPAOoAAAAA.',
['陈刀']='陈刀仔:BAAALgAECgUJBQAAAA==.',
['陌上']='陌上云霏:BAAALgAECggJDgAAAA==.',
['陌小']='陌小妖:BAAALgAECgQJBAAAAA==.',
['隔壁']='隔壁的海猴:BAAALgAECgcJDQAAAA==.',
['雅十']='雅十兰顿:BAAALgAECgQJBAAAAA==.',
['雨下']='雨下整夜:BAAALgADCgIJAgAAAA==.',
['雨化']='雨化云:BAAALgAECgUJBQAAAA==.',
['雨的']='雨的洗礼:BAAALgAECgYJEQAAAA==.',
['雨迹']='雨迹:BAAALgAECgcJEQABLgAFFAUJBQAGAN8aAA==.',
['雪落']='雪落:BAABLgAFFH8FAAIPAAMJ+SPHDABFAQAPAAMJ+SPHDABFAQAAAA==.',
['霜霜']='霜霜妹妹:BAAALgAECgIJAwAAAA==.',
['霸气']='霸气冲破天:BAAALgAECgYJDgAAAA==.',
['霹城']='霹城吴彦祖丶:BAABLgAECn8ZAAIPAAgJnyDwDwAPAwAPAAgJnyDwDwAPAwAAAA==.',
['靊仐']='靊仐:BAAALgADCgYJBgAAAA==.',
['青丘']='青丘:BAAALgAECgYJBwAAAA==.',
['静夜']='静夜思:BAAALgAECgIJAgAAAA==.',
['静谧']='静谧:BAABLgAFFH8FAAISAAIJSAhJFQClAAASAAIJSAhJFQClAAAAAA==.',
['非洲']='非洲大山雀:BAAALgAFFAEJAQAAAA==.',
['韭菜']='韭菜番茄:BAAALgAECgEJAQAAAA==.',
['韵勾']='韵勾:BAAALgAECgQJCAAAAA==.',
['韵欣']='韵欣:BAAALgADCgYJBgAAAA==.',
['顺遂']='顺遂:BAAALgAECgUJAgAAAA==.',
['领丨']='领丨域:BAAALgAECgcJDQAAAA==.',
['風林']='風林火山:BAAALgAECgcJBwAAAA==.',
['风吟']='风吟鹤舞:BAAALgADCgYJCQAAAA==.',
['风暴']='风暴之拳:BAAALgAECgUJBgAAAA==.',
['风灵']='风灵晓雪:BAAALgADCgUJBQAAAA==.',
['风语']='风语小牧:BAAALgAECgUJBQAAAA==.风语小贝:BAAALgAECgEJAQAAAA==.',
['马超']='马超丶:BAAALgAECgMJAwAAAA==.',
['骄阳']='骄阳:BAAALgAFFAIJBAAAAA==.',
['骑爷']='骑爷爷丶:BAAALgAECgYJCAAAAA==.',
['髙縂']='髙縂:BAAALgAECgEJAQAAAA==.',
['鬼破']='鬼破沙罗:BAABLgAECn8UAAISAAcJOBrSGwAhAgASAAcJOBrSGwAhAgAAAA==.',
['魅魔']='魅魔之魇:BAAALgADCgcJBwAAAA==.',
['魔宴']='魔宴灬丨:BAAALgAECgQJBwAAAA==.',
['魔空']='魔空空:BAAALgADCgUJBQAAAA==.',
['麝月']='麝月追星:BAAALgAECgQJCAAAAA==.',
['黑子']='黑子:BAAALgAECgcJBwABLgAFFAUJCQAJAGomAA==.',
['黑白']='黑白刚刚:BAAALgAECgMJAwAAAA==.黑白狐狸:BAAALgAFFAEJAQAAAA==.',
['鼻毛']='鼻毛天天剪:BAAALgAECgYJBgAAAA==.',
['齐天']='齐天大圣:BAAALgAFFAIJAgAAAA==.',
['龙月']='龙月吟秋风:BAAALgAFFAEJAgAAAA==.',
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
