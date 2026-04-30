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

local lookup = {'Priest-Holy','DeathKnight-Unholy','DeathKnight-Frost','DeathKnight-Blood','Druid-Restoration','Warlock-Demonology','Warlock-Affliction','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Shaman-Elemental','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Priest-Discipline','Priest-Shadow','Unknown-Unknown','Monk-Brewmaster','Monk-Windwalker','Mage-Frost','Warrior-Fury','Warrior-Protection','Druid-Balance','Warlock-Destruction','Druid-Guardian','Druid-Feral','DemonHunter-Havoc','DemonHunter-Devourer','Hunter-Survival','Monk-Mistweaver','Paladin-Retribution','Paladin-Holy','Rogue-Subtlety','DemonHunter-Vengeance',}
local provider = {region='CN',realm='萨菲隆',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aiyana:BAAALgAECgYJCAAAAA==.Aiyinsitan:BAAALgADCgUJBQAAAA==.',
Ap='Apollowind:BAABLgAECn8aAAIBAAcJJR4pEQBZAgABAAcJJR4pEQBZAgAAAA==.',
Ca='Candice:BAAALgAECgMJBAAAAA==.Canna:BAAALgADCgMJAwAAAA==.',
Ch='Chamán:BAAALgAECgUJBQAAAA==.Chocolate:BAAALgAECgYJCAAAAA==.Chris:BAAALgAFFAIJAwAAAA==.',
De='Deathduke:BAAALgAFFAEJAQAAAA==.Decesor:BAAALgAECgEJAQAAAA==.',
Do='Doomthyr:BAAALgAECgUJBgAAAA==.',
Dq='Dq:BAAALgAECgYJBwAAAA==.',
Du='Dunhill:BAAALgADCgUJBQAAAA==.',
Ea='Eatyoumom:BAACLgAFFH8JAAMCAAMJLx8YJQABAQACAAMJ9RUYJQABAQADAAIJqxy+AgDAAAAuAAQKfxsABAIACQnzGptXAOsBAAIABwnnFptXAOsBAAQAAwkCG4UqAOoAAAMAAQnoGwAAAAAAAAAA.',
Fa='Fatdevil:BAAALgAECgEJAQAAAA==.',
Fr='Frio:BAABLgAFFH8JAAIFAAMJORCWEgDUAAAFAAMJORCWEgDUAAAAAA==.',
Gd='Gdragon:BAAALgAECgQJBAAAAA==.',
Ha='Harrytruman:BAAALgAECgYJBgAAAA==.',
He='Heyya:BAAALgAECgUJBQAAAA==.',
Is='Isolde:BAAALgAFFAUJBAAAAA==.',
Jo='Jolie:BAAALgAECggJDQAAAA==.',
Ma='Marsleo:BAAALgAECgMJAwAAAA==.Matrix:BAAALgAECgYJBwAAAA==.',
Me='Melini:BAAALgAECgQJBQAAAA==.',
Mo='Mojitoo:BAAALgAFFAEJAQAAAA==.',
Nn='Nnova:BAAALgAECgEJAQAAAA==.',
Oi='Oi:BAAALgAECgEJAQAAAA==.',
Or='Orinna:BAAALgAECgkJAwAAAA==.',
Po='Pokemongo:BAAALgAECgUJBQAAAA==.',
Qs='Qson:BAABLgAECn8VAAMGAAgJqhqSMABKAgAGAAgJARqSMABKAgAHAAIJRSJRGgClAAAAAA==.',
Ri='Rich:BAAALgAECgcJCQAAAA==.',
Sa='Sacerdote:BAAALgADCgYJBgAAAA==.',
Sk='Skr:BAACLgAFFH8FAAICAAQJGAofKgDyAAACAAQJGAofKgDyAAAuAAQKfxgAAgIACAmoFQ9XAOwBAAIACAmoFQ9XAOwBAAAA.',
Sl='Sleepydk:BAAALgAECgIJAQAAAA==.',
Sm='Smallxc:BAABLgAFFH8FAAIIAAMJyxoGCQAZAQAIAAMJyxoGCQAZAQAAAA==.',
St='Starry:BAAALgAECgEJAQAAAA==.',
Um='Umika:BAAALgAECgYJEAAAAA==.',
Vi='Visenya:BAAALgAECgYJBwAAAA==.',
Wa='Warpath:BAAALgAECgcJDQAAAA==.',
Wh='Whitered:BAAALgAFFAEJAQAAAA==.',
Wo='Wonyoung:BAAALgAECgYJDAAAAA==.',
Zh='Zhuifeng:BAAALgAECgUJBQAAAA==.',
['一个']='一个小真真:BAAALgADCgEJAQAAAA==.一个靓仔:BAAALgAECgcJCQAAAA==.',
['一块']='一块西瓜丶:BAAALgAECgMJAwAAAA==.',
['一字']='一字并肩王:BAAALgAECgIJAwAAAA==.',
['一条']='一条龙服務:BAAALgAECgcJDQAAAA==.',
['丁度']='丁度巴拉斯:BAABLgAECn8VAAMIAAYJ5RkgNwDSAQAIAAYJ5RkgNwDSAQAJAAIJUAZJfABTAAAAAA==.',
['三丶']='三丶小丶姐:BAAALgAFFAIJAgAAAA==.',
['三喜']='三喜丶:BAAALgADCgQJBAAAAA==.',
['不会']='不会玩萨满:BAAALgAECgMJAwAAAA==.',
['东北']='东北第一深情:BAAALgADCgQJBAAAAA==.',
['东海']='东海小憨憨:BAAALgAECgYJDgAAAA==.',
['丨圣']='丨圣德太子丨:BAAALgAFFAEJAQAAAA==.',
['丨蓝']='丨蓝田丨:BAABLgAFFH8KAAMKAAQJoxMsDwDuAAAKAAMJlRMsDwDuAAALAAMJAw8DDAChAAAAAA==.',
['丨锤']='丨锤锤丨:BAAALgAECgQJBAAAAA==.',
['丨静']='丨静待:BAAALgADCgIJAgAAAA==.',
['串天']='串天猴:BAAALgAFFAIJAgAAAA==.',
['丶冫']='丶冫氵氵冫丶:BAAALgADCgEJAQAAAA==.',
['丶尛']='丶尛柒:BAAALgAECgEJAQAAAA==.',
['丶弹']='丶弹力鹌鹑:BAAALgAECgYJBgAAAA==.',
['丶月']='丶月笛:BAAALgAECgIJAQAAAA==.',
['丶木']='丶木木夕:BAAALgAECgMJBAAAAA==.',
['丶柒']='丶柒宗罪:BAAALgAECgYJCwAAAA==.',
['丶溴']='丶溴溴:BAAALgAECgcJBwAAAA==.',
['丿虾']='丿虾仁猪心:BAAALgADCgQJBAAAAA==.',
['义妁']='义妁:BAAALgAFFAIJAwAAAA==.',
['九尾']='九尾灬天狐:BAAALgAECgcJDQAAAA==.',
['九韶']='九韶之影:BAAALgAECgMJAwAAAA==.九韶之拳:BAAALgAECgEJAgAAAA==.九韶之灵:BAAALgAECgQJBQAAAA==.九韶之铃:BAAALgAECgEJAQAAAA==.',
['买个']='买个嘚:BAAALgAFFAIJAgAAAA==.',
['乱来']='乱来:BAAALgAECgUJBQAAAA==.',
['二氧']='二氧化糖:BAAALgAECgYJBgAAAA==.',
['二表']='二表叔:BAAALgAECgYJBgAAAA==.',
['二马']='二马路铁棒:BAAALgAECgEJAQAAAA==.',
['享念']='享念成疯:BAAALgAECgYJDAAAAA==.',
['人中']='人中极品:BAAALgADCgcJBwAAAA==.',
['什柒']='什柒:BAAALgAECgEJAQAAAA==.',
['令狐']='令狐冲:BAAALgADCgYJBgAAAA==.',
['任性']='任性小种牛:BAAALgAECgYJCwAAAA==.',
['休闲']='休闲的米大叔:BAABLgAECn8VAAQMAAYJsxu4DwDfAQAMAAYJsxu4DwDfAQANAAUJEA0PTgCXAAAOAAEJmwFQTwAdAAAAAA==.',
['佈藕']='佈藕:BAABLgAFFH8IAAQPAAQJshWoBwD/AAAPAAMJTxOoBwD/AAABAAEJnAfIEgBOAAAQAAEJmginDgBIAAAAAA==.',
['佐手']='佐手一牵右手:BAAALgAECgIJAgAAAA==.',
['你在']='你在狗叫什么:BAAALgAECgcJCgAAAA==.',
['你好']='你好哇塞:BAAALgADCgcJBwAAAA==.',
['俺是']='俺是四骑士:BAAALgADCgYJCAAAAA==.',
['偶然']='偶然的香芋:BAAALgAECgIJAgAAAA==.',
['偷天']='偷天换日:BAAALgAECgYJCQAAAA==.',
['儒雅']='儒雅随和:BAAALgAECgUJBQABLgAFFAIJAwARAAAAAA==.',
['元素']='元素康:BAAALgAFFAEJAQAAAA==.',
['元芳']='元芳的无奈:BAAALgADCgYJBgAAAA==.',
['光明']='光明淡定牛:BAACLgAFFH8GAAIKAAMJDBWVFQCrAAAKAAMJDBWVFQCrAAAuAAQKfx8AAgoACQlzFsETAHcCAAoACQlzFsETAHcCAAAA.',
['克雷']='克雷斯托:BAAALgAFFAEJAQAAAA==.',
['八王']='八王寺:BAAALgAECgcJCgAAAA==.',
['六一']='六一换换:BAAALgADCgYJBgAAAA==.',
['六丑']='六丑:BAACLgAFFH8FAAISAAUJ+CNIAQAOAgASAAUJ+CNIAQAOAgAuAAQKfxQAAhMACAmMGEYRAG8CABMACAmMGEYRAG8CAAAA.',
['兽无']='兽无畏:BAAALgAECgIJAgAAAA==.',
['再回']='再回到从前:BAACLgAFFH8GAAIUAAIJQgs2QwCpAAAUAAIJQgs2QwCpAAAuAAQKfxsAAhQABwkXHbWCAMwBABQABwkXHbWCAMwBAAAA.',
['再快']='再快也是八六:BAAALgAECgEJAQAAAA==.',
['别喝']='别喝我机油:BAAALgAFFAIJAgAAAA==.',
['别来']='别来撩我:BAAALgADCgEJAQAAAA==.',
['剑指']='剑指冰封:BAAALgAECgUJBQAAAA==.',
['勇敢']='勇敢牜牜:BAAALgAECgQJBAAAAA==.',
['匪顽']='匪顽:BAAALgADCgcJAQAAAA==.',
['十丶']='十丶小丶姐:BAACLgAFFH8MAAMVAAQJbxbGAgBkAQAVAAQJbxbGAgBkAQAWAAEJchA5EABCAAAuAAQKfyMAAxUACAljHFUXAJICABUACAnMG1UXAJICABYAAQmnEwdFADgAAAAA.',
['千反']='千反田爱瑠丨:BAAALgADCgQJBAAAAA==.',
['千羽']='千羽圣堂:BAAALgAECggJDQAAAA==.',
['华笙']='华笙:BAAALgAECgEJAQABLgAFFAQJDAAUAL8XAA==.华笙的骑士:BAAALgAECgYJDgAAAA==.',
['华重']='华重楼:BAAALgAFFAIJAgABLgAFFAMJCAACAAIbAA==.',
['卖地']='卖地文:BAAALgAECgYJCgAAAA==.',
['卡迪']='卡迪纳尔:BAAALgADCgQJBAAAAA==.',
['双刀']='双刀儿:BAAALgAECgQJCAAAAA==.',
['双木']='双木思丶清风:BAABLgAECn8VAAMJAAcJchlkOACBAQAJAAYJNBZkOACBAQAIAAMJhxvdgQDiAAAAAA==.',
['可爱']='可爱的花生:BAAALgADCgcJBwAAAA==.',
['同心']='同心同德:BAAALgADCgMJAwABLgAFFAQJDAASAM0HAA==.',
['吴宴']='吴宴祖:BAAALgAECgcJDAAAAA==.',
['呦呦']='呦呦:BAAALgAECgQJBQAAAA==.呦呦扭扭:BAAALgAECgEJAQAAAA==.',
['咚東']='咚東冬咚:BAACLgAFFH8PAAIKAAQJvSErBACQAQAKAAQJvSErBACQAQAuAAQKfyYAAgoACQn8HfQFABMDAAoACQn8HfQFABMDAAAA.',
['哎哟']='哎哟哟:BAAALgAECgUJBQAAAA==.',
['唤地']='唤地者丶桃狼:BAAALgAECgQJBAAAAA==.',
['唯一']='唯一的寂寞:BAAALgAECgUJBQAAAA==.',
['喝酒']='喝酒就上脸:BAAALgAECgYJBQAAAA==.',
['喵丶']='喵丶小起:BAAALgAECggJCgABLgAFFAYJCwAUAL0cAA==.',
['嘚儿']='嘚儿德:BAABLgAFFH8HAAIXAAMJPwJ2EQC/AAAXAAMJPwJ2EQC/AAAAAA==.',
['嘿喂']='嘿喂咣咣:BAAALgAECgEJAgAAAA==.',
['噩兆']='噩兆方舟:BAAALgAECgYJBwAAAA==.',
['回忆']='回忆里死去:BAAALgAECgQJBAAAAA==.',
['团长']='团长让我来:BAACLgAFFH8OAAICAAUJVRv/BgCZAQACAAUJVRv/BgCZAQAuAAQKfx4AAgIACQkHI1wEAI4DAAIACQkHI1wEAI4DAAAA.',
['圣光']='圣光之舞:BAAALgAECgYJBgAAAA==.圣光乌瑟尔:BAAALgAECgQJAwAAAA==.圣光会感谢你:BAAALgAECgUJCAABLgAFFAIJAwARAAAAAA==.圣光被叛了我:BAAALgAFFAIJAwAAAA==.',
['基尔']='基尔榜一:BAAALgADCgEJAQAAAA==.',
['复仇']='复仇者丶米娜:BAAALgADCgEJAQAAAA==.',
['夏沧']='夏沧澜:BAAALgAECgMJAwAAAA==.',
['夜丶']='夜丶疯魔灬:BAABLgAECn82AAQYAAcJpBbDEQC+AQAYAAcJDhTDEQC+AQAGAAYJXwzYlAAvAQAHAAUJPwuwEQASAQAAAA==.',
['大卫']='大卫戴良子:BAAALgAECgYJAwAAAA==.',
['大端']='大端裴杯:BAAALgAECgEJAgAAAA==.',
['大脑']='大脑斧:BAAALgAECgYJCgAAAA==.',
['大西']='大西几:BAACLgAFFH8HAAIZAAMJjgXKAgCVAAAZAAMJjgXKAgCVAAAuAAQKfxkAAxkACAlQD6ARAFwBABkACAlQD6ARAFwBABoABAkFBoIlAKcAAAEuAAUUBAkPABIAxhIA.',
['大雷']='大雷波波:BAABLgAFFH8GAAIUAAIJcwiYRACmAAAUAAIJcwiYRACmAAAAAA==.',
['大领']='大领主丶尼克:BAAALgADCgEJAQAAAA==.',
['大黑']='大黑母牛:BAAALgAECgMJAwAAAA==.',
['天地']='天地斗:BAAALgADCgEJAQAAAA==.',
['天生']='天生就是爆:BAACLgAFFH8MAAMVAAQJjhJZCwBKAQAVAAQJQg9ZCwBKAQAWAAIJVBC9BgCXAAAuAAQKfyUAAxYACQkTHO4HAKcCABYABwkCIe4HAKcCABUACAm7FpAjADkCAAAA.',
['太寿']='太寿鸠茅:BAAALgADCgEJAQAAAA==.',
['奇奇']='奇奇怪乖的:BAAALgAECgQJBAAAAA==.',
['奈何']='奈何明月:BAAALgAECgEJAQAAAA==.',
['奎尔']='奎尔撒斯:BAAALgADCgQJBAAAAA==.',
['奥利']='奥利奥扭不开:BAAALgADCgcJBgAAAA==.',
['奶牛']='奶牛出鲜奶:BAAALgAECgcJCAABLgAFFAQJCQAOAOELAA==.',
['妮娜']='妮娜芙:BAAALgADCgYJBgAAAA==.',
['娟姐']='娟姐的男神:BAAALgADCgIJAgAAAA==.',
['媋丽']='媋丽:BAABLgAECn8VAAIIAAgJxBWWHQBUAgAIAAgJxBWWHQBUAgAAAA==.',
['嫐丶']='嫐丶哥:BAAALgAFFAEJAQAAAA==.',
['孙小']='孙小胖:BAAALgAFFAIJAgAAAA==.',
['孤岛']='孤岛之管子:BAACLgAFFH8FAAIFAAMJzhECCwDWAAAFAAMJzhECCwDWAAAuAAQKfxoAAwUACAkSGroiADICAAUACAkSGroiADICABcAAQn6AZ2QABgAAAAA.',
['安静']='安静的枫:BAAALgAECgEJAQAAAA==.',
['完美']='完美追猎者:BAAALgAECgYJDAAAAA==.',
['宝石']='宝石迷雾:BAAALgAECgEJAgAAAA==.',
['寒雨']='寒雨伤百草:BAACLgAFFH8IAAICAAMJAhvJEwD1AAACAAMJAhvJEwD1AAAuAAQKfyIAAgIACQkcIpIFAHwDAAIACQkcIpIFAHwDAAAA.',
['寳生']='寳生永夢:BAACLgAFFH8FAAIbAAIJzheQCACrAAAbAAIJzheQCACrAAAuAAQKfxQAAxsABwkfIfEKALICABsABwkfIfEKALICABwABQnAFDGAACkBAAAA.',
['小兽']='小兽降临:BAAALgAECgEJAQAAAA==.',
['小刚']='小刚:BAAALgAFFAEJAQAAAA==.',
['小景']='小景:BAAALgAECgYJBgAAAA==.',
['小柴']='小柴:BAAALgAECgQJCQAAAA==.',
['小灬']='小灬稚:BAAALgAECgYJCQAAAA==.',
['小猪']='小猪就是我:BAAALgAECgEJAQAAAA==.',
['小红']='小红手半夏丶:BAAALgAECgUJDwAAAA==.小红手霖霖:BAAALgADCgMJAwAAAA==.',
['小蕾']='小蕾蕾:BAAALgAECgEJAQAAAA==.',
['小阿']='小阿福:BAAALgAECgYJCAAAAA==.',
['就这']='就这味儿:BAABLgAFFH8FAAIUAAIJkwgAJgCiAAAUAAIJkwgAJgCiAAAAAA==.',
['山鬼']='山鬼丶:BAAALgADCgMJAwAAAA==.',
['左眼']='左眼的淚滴:BAAALgADCgcJBwAAAA==.',
['帅与']='帅与俊的结合:BAAALgAECgYJBgAAAA==.',
['希爾']='希爾佤娜斯:BAAALgAECgEJAQAAAA==.',
['幻影']='幻影之巅:BAAALgADCgEJAQAAAA==.',
['幻羽']='幻羽之痕:BAAALgAECgEJAQAAAA==.',
['广源']='广源:BAAALgAECgkJAwAAAA==.',
['库库']='库库的龙:BAAALgAFFAQJBAAAAA==.',
['庞光']='庞光:BAABLgAFFH8JAAQDAAUJ1AoqAQA9AQADAAQJ1AoqAQA9AQACAAQJbQMlHwAgAQAEAAEJAAChEwAAAAAAAA==.',
['弑灵']='弑灵:BAAALgADCgMJAwAAAA==.',
['彪彪']='彪彪必达:BAAALgAECgEJAQAAAA==.',
['影劫']='影劫:BAAALgAECgIJAwAAAA==.',
['影魔']='影魔必须死:BAAALgAECgYJDAAAAA==.',
['後土']='後土载天:BAAALgAECgYJBgAAAA==.',
['循逆']='循逆丶:BAAALgADCgQJBAAAAA==.',
['微凉']='微凉丶:BAAALgAECgEJAQAAAA==.',
['微暖']='微暖丶:BAAALgAECgUJCwAAAA==.',
['忍不']='忍不住:BAABLgAFFH8GAAIIAAIJZBwVFACzAAAIAAIJZBwVFACzAAAAAA==.',
['忘川']='忘川三途:BAAALgAECgEJAQAAAA==.',
['忙着']='忙着死忙着活:BAAALgAECgIJAgAAAA==.',
['怒灬']='怒灬焱:BAAALgAECgMJBgAAAA==.',
['恐怖']='恐怖丧钟:BAAALgAECgQJBQAAAA==.',
['悟能']='悟能:BAABLgAFFH8MAAISAAQJzQc3CAARAQASAAQJzQc3CAARAQAAAA==.',
['慢快']='慢快门:BAAALgAFFAIJBAAAAA==.',
['懵懵']='懵懵懂懂:BAAALgADCgQJBAAAAA==.',
['我妻']='我妻由乃:BAAALgADCgcJDQAAAA==.',
['我要']='我要当猎手:BAAALgAECgEJAQAAAA==.',
['我进']='我进不去游戏:BAAALgADCgEJAQAAAA==.',
['戮星']='戮星云:BAAALgAECgQJBQAAAA==.',
['拉赫']='拉赫家的小三:BAAALgAECgYJBwAAAA==.',
['拒绝']='拒绝完媄:BAAALgADCgMJAwAAAA==.',
['招蜂']='招蜂引蝶:BAAALgADCgYJBgAAAA==.',
['拨皮']='拨皮滚刀肉:BAAALgAECgQJBAAAAA==.',
['拽拽']='拽拽的花生:BAABLgAFFH8KAAMIAAMJ8x6xBwAgAQAIAAMJCBexBwAgAQAJAAMJARYlFAD9AAAAAA==.',
['拾光']='拾光人丨:BAAALgADCgUJBQAAAA==.',
['摆图']='摆图腾星人:BAAALgAECgEJAQAAAA==.',
['攻疼']='攻疼新壹:BAAALgAECgEJAgAAAA==.',
['放學']='放學別走:BAACLgAFFH8PAAMIAAQJzyScAAC5AQAIAAQJzyScAAC5AQAdAAEJrBHXBgBTAAAuAAQKfxgABB0ACAnPHpgGAJQCAB0ACAl8HJgGAJQCAAgAAwmsG7t0AAkBAAkAAQkaBNOUACUAAAAA.放學別跑:BAAALgAFFAMJAwABLgAFFAQJDwAIAM8kAA==.',
['斗徒']='斗徒:BAAALgAECgEJAgAAAA==.',
['断钢']='断钢者丶月笛:BAAALgADCgQJBAAAAA==.',
['斯娜']='斯娜瓦尔希:BAAALgAECgEJAQAAAA==.',
['斯蒂']='斯蒂芬制冰机:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌只三秒:BAAALgAFFAEJAQAAAA==.',
['无望']='无望炎:BAAALgAFFAIJAgAAAA==.',
['无痕']='无痕冬雪:BAAALgAECgUJBgAAAA==.',
['昊天']='昊天大帝:BAAALgAECgEJAQAAAA==.',
['星多']='星多多:BAAALgAECgQJBQAAAA==.',
['晓潘']='晓潘达:BAAALgAECgYJCQAAAA==.',
['晚晴']='晚晴:BAAALgAECgMJBAABLgAFFAQJDAASAM0HAA==.',
['晴天']='晴天瘦猪:BAAALgAECgYJBgAAAA==.',
['暗夜']='暗夜精灵:BAACLgAFFH8KAAMPAAQJsRyLBwBjAQAPAAQJSBuLBwBjAQABAAEJ/RgZFABEAAAuAAQKfxUAAw8ACAkUIzIGAOcCAA8ACAmcHjIGAOcCAAEABAmnH3I7AE0BAAAA.',
['暗暗']='暗暗重生:BAACLgAFFH8PAAISAAQJxhITCAATAQASAAQJxhITCAATAQAuAAQKfx4AAxIACQnUFl8OAK8CABIACQnUFl8OAK8CAB4AAQm4DudpAC4AAAAA.',
['暗法']='暗法魂:BAAALgAECgYJCQAAAA==.',
['暮光']='暮光丶璐璐:BAAALgAECgYJBgAAAA==.暮光丶阿狸:BAABLgAECn8WAAIUAAcJ4xonVAA8AgAUAAcJ4xonVAA8AgAAAA==.',
['暮霭']='暮霭沉楚天阔:BAACLgAFFH8FAAIBAAIJPxq7CgC5AAABAAIJPxq7CgC5AAAuAAQKfxUABAEACQmFFVYWACkCAAEACAkHE1YWACkCABAABgmjGdAaAAcCAA8AAQlqHOpPAE8AAAEuAAUUBQkNAA8AqiMA.',
['月色']='月色妖娆:BAAALgAFFAMJAwAAAA==.',
['月迪']='月迪:BAAALgAECgUJBAAAAA==.月迪丶:BAAALgAECgcJDQAAAA==.',
['有德']='有德必有詩丨:BAAALgAECgYJBgAAAA==.',
['有点']='有点味儿:BAACLgAFFH8KAAMQAAQJOBOfCAA6AQAQAAQJOBOfCAA6AQAPAAEJqQE+HAA6AAAuAAQKfxwAAxAACAmWIXkIAPwCABAACAmWIXkIAPwCAAEABQkIER1KABABAAAA.',
['木林']='木林森森林木:BAAALgADCgEJAQAAAA==.',
['未知']='未知目標:BAAALgAECgMJAwAAAA==.',
['杀戮']='杀戮机器丶:BAACLgAFFH8PAAICAAQJ/xewCABJAQACAAQJ/xewCABJAQAuAAQKfyYAAwIACQmWHNYRABEDAAIACQmWHNYRABEDAAMAAQlEEWAVAD8AAAAA.',
['果冻']='果冻橙:BAAALgAECgMJAwAAAA==.',
['柚柚']='柚柚妹:BAAALgAFFAIJAgAAAA==.',
['梦幻']='梦幻寒冰:BAAALgAECgEJAQAAAA==.',
['梦綄']='梦綄:BAAALgADCgEJAQAAAA==.',
['梧幽']='梧幽:BAAALgAECgMJAQAAAA==.',
['森鸣']='森鸣:BAAALgAECgMJAwAAAA==.',
['楚云']='楚云湘语:BAAALgADCgYJBgAAAA==.',
['欒丶']='欒丶钦樂樂:BAAALgAECgEJAQAAAA==.',
['欧皇']='欧皇白学家:BAAALgADCgYJBgAAAA==.',
['欲买']='欲买桂花载酒:BAABLgAFFH8MAAICAAQJ2h38AwB0AQACAAQJ2h38AwB0AQAAAA==.',
['止戀']='止戀灬峯婷:BAAALgAECgcJDQAAAA==.',
['歸麳']='歸麳:BAAALgADCgEJAQAAAA==.',
['毁灭']='毁灭我吧:BAABLgAFFH8GAAIGAAMJgBSBHwAGAQAGAAMJgBSBHwAGAQAAAA==.',
['汐晔']='汐晔:BAAALgAECgQJBQAAAA==.',
['江湖']='江湖余生:BAAALgAECgEJAQAAAA==.',
['法神']='法神是我:BAAALgAECgYJAQAAAA==.',
['泠衣']='泠衣:BAAALgAECgcJDQAAAA==.',
['洛阿']='洛阿追随者:BAAALgAECgYJBgAAAA==.',
['洞察']='洞察大师丶:BAAALgAECgQJBAAAAA==.',
['活死']='活死人四:BAACLgAFFH8KAAIBAAMJFCC6AwAOAQABAAMJFCC6AwAOAQAuAAQKfxUAAgEACAl4FosZABACAAEACAl4FosZABACAAAA.',
['流儿']='流儿:BAAALgAECgcJBwAAAA==.',
['浓情']='浓情幂意:BAAALgAECgEJAQAAAA==.',
['浪漫']='浪漫浅唱:BAAALgAFFAEJAQAAAA==.浪漫邪吻:BAAALgAECgYJCwAAAA==.',
['浴火']='浴火飞凤:BAAALgADCgEJAQAAAA==.',
['海茵']='海茵里斯:BAAALgAFFAEJAQAAAA==.',
['海蓝']='海蓝丶之谜:BAAALgAECgYJEAAAAA==.',
['涼透']='涼透半盏流年:BAAALgADCgMJAwAAAA==.',
['淮海']='淮海路小佩奇:BAAALgAECgMJAwAAAA==.',
['深夜']='深夜狂欢:BAAALgAECgYJDAAAAA==.',
['深情']='深情必坠死海:BAAALgAECgUJBwAAAA==.',
['渡丶']='渡丶魔:BAAALgAECgUJBgAAAA==.',
['渡圣']='渡圣成光丶:BAAALgAECgMJAwAAAA==.',
['游我']='游我误你:BAAALgAECgcJBwAAAA==.',
['满地']='满地打滚:BAAALgAECgIJAgAAAA==.',
['火萤']='火萤:BAAALgAECgQJBAAAAA==.',
['灬小']='灬小丨胖墩灬:BAAALgAECgEJAQAAAA==.',
['灬理']='灬理想戒了灬:BAAALgAECgUJBQAAAA==.',
['灰烬']='灰烬使者:BAAALgAECgkJDwABLgAFFAYJFwAfAN0fAA==.',
['灼热']='灼热的信仰:BAAALgADCgYJBgAAAA==.',
['烦恼']='烦恼的小叶:BAAALgAECgQJDAAAAA==.',
['烬鬃']='烬鬃迅蹄:BAAALgADCgYJBgAAAA==.',
['热血']='热血麻吉:BAAALgAECgYJBgABLgAFFAQJDAAfAG8gAA==.',
['然然']='然然:BAAALgAFFAEJAQABLgAFFAQJBgAQAAcWAA==.',
['熊熊']='熊熊烈火飒儿:BAAALgAECgMJAwAAAA==.',
['牛徳']='牛徳彪:BAAALgAECgUJCgAAAA==.',
['牛无']='牛无敌:BAAALgADCgkJCQAAAA==.',
['牛牛']='牛牛皮卡:BAAALgADCgUJBQAAAA==.',
['牛牪']='牛牪犇犇牪牛:BAAALgADCgUJBQAAAA==.',
['牧云']='牧云清歌:BAAALgAECgUJBQAAAA==.',
['特产']='特产小银杏:BAAALgADCgIJAgAAAA==.',
['特别']='特别油:BAAALgADCgUJBQAAAA==.',
['狂暴']='狂暴棕牛:BAAALgAECgEJAgAAAA==.狂暴然:BAAALgADCgIJAgAAAA==.',
['狂热']='狂热的猎手:BAAALgAECgQJBAAAAA==.',
['狂飈']='狂飈的蜗牛:BAABLgAFFH8FAAIcAAQJEBYjCQA3AQAcAAQJEBYjCQA3AQAAAA==.',
['狱卒']='狱卒:BAAALgADCgEJAQAAAA==.',
['猎宁']='猎宁宁:BAAALgAECgEJAgAAAA==.',
['猎灵']='猎灵师弟:BAAALgAECgEJAQAAAA==.猎灵师长:BAAALgAECgQJBgAAAA==.',
['猛牛']='猛牛乳业:BAAALgAECgUJCQAAAA==.',
['玄若']='玄若:BAAALgAECgcJBwAAAA==.',
['王甜']='王甜甜:BAAALgAECgEJAQAAAA==.',
['王飒']='王飒:BAAALgAECgYJBQAAAA==.',
['玛格']='玛格汉子丿:BAAALgAECgYJDAAAAA==.',
['玫红']='玫红石头:BAAALgAECgMJAgAAAA==.',
['甜筒']='甜筒殡淇淋:BAAALgAFFAIJBAAAAA==.',
['生之']='生之大祭司:BAABLgAFFH8JAAMOAAQJ4QvqDgDnAAAOAAMJyg3qDgDnAAANAAMJBAMfFQDCAAAAAA==.',
['生来']='生来就为灭你:BAAALgAECgEJAQAAAA==.',
['生活']='生活不能自理:BAAALgAFFAMJAwAAAA==.',
['电子']='电子魅魔:BAAALgAFFAEJAQAAAA==.',
['番茄']='番茄马铃薯:BAAALgAECgEJAQAAAA==.',
['皮卡']='皮卡毕:BAAALgAECgYJCgAAAA==.',
['盲人']='盲人猎手炳妹:BAAALgADCgUJCAAAAA==.',
['直觉']='直觉外科医生:BAAALgAECgQJBgAAAA==.',
['睜眼']='睜眼瞎:BAAALgAFFAQJBAAAAA==.',
['石永']='石永刈:BAAALgADCgYJBgAAAA==.',
['祁连']='祁连幽梦:BAAALgAECgYJBgAAAA==.',
['祝您']='祝您早生贵子:BAABLgAECn8aAAIfAAkJ1x/ICgA6AwAfAAkJ1x/ICgA6AwAAAA==.',
['神圣']='神圣之忍侠:BAACLgAFFH8NAAIBAAQJIBCkBQApAQABAAQJIBCkBQApAQAuAAQKfysAAgEACAlcHoADADcCAAEACAlcHoADADcCAAAA.',
['神行']='神行者丶暮幽:BAAALgAECgYJBgAAAA==.',
['神龙']='神龙鬥士:BAAALgADCgEJAQAAAA==.',
['禅宗']='禅宗烈酒:BAAALgAECgEJAgAAAA==.',
['秋落']='秋落木:BAAALgAECgYJCQAAAA==.',
['竹隐']='竹隐灬寒月:BAABLgAFFH8FAAICAAQJdhjaFgBJAQACAAQJdhjaFgBJAQAAAA==.',
['笑看']='笑看丨浮生:BAAALgAFFAYJAgAAAA==.笑看丶浮生:BAAALgAECgQJBQAAAA==.',
['笨笨']='笨笨牛叉:BAAALgADCgEJAQAAAA==.',
['等到']='等到那一天:BAAALgAECgcJDwAAAA==.',
['素月']='素月墨沅:BAAALgAECgYJBgAAAA==.素月墨羽:BAAALgAECgkJBgAAAA==.',
['红唇']='红唇坐大枪:BAAALgAECgMJAwAAAA==.',
['绫小']='绫小路清隆:BAAALgAECgEJAQAAAA==.',
['绫灯']='绫灯水月:BAAALgADCgMJAwAAAA==.',
['绯英']='绯英:BAACLgAFFH8PAAIgAAQJeCaNAgDLAQAgAAQJeCaNAgDLAQAuAAQKfyYAAiAACQlmJJgAAKgDACAACQlmJJgAAKgDAAAA.',
['维拉']='维拉:BAAALgADCgUJBQAAAA==.',
['缺德']='缺德是种艺术:BAAALgAECgEJAQAAAA==.',
['罗辑']='罗辑:BAABLgAFFH8HAAIUAAMJSBt9GwDiAAAUAAMJSBt9GwDiAAABLgAFFAYJBAARAAAAAA==.',
['美的']='美的无法忘记:BAAALgAECgMJAwAAAA==.',
['翠星']='翠星石:BAAALgAECgcJBAAAAA==.',
['翻滚']='翻滚吧小宇宙:BAAALgAECgIJAgAAAA==.',
['老丈']='老丈人:BAAALgAECgQJBAAAAA==.',
['老汉']='老汉牵着牛:BAABLgAFFH8IAAIhAAMJwySdBAA+AQAhAAMJwySdBAA+AQAAAA==.',
['老登']='老登弓长:BAAALgAECgYJBwAAAA==.',
['背水']='背水一击:BAAALgAECgcJDAAAAA==.',
['脸滚']='脸滚键盘输出:BAABLgAFFH8JAAIfAAQJhxegFAADAQAfAAQJhxegFAADAQAAAA==.',
['腿小']='腿小腿:BAACLgAFFH8IAAIKAAMJ8yFqCgAvAQAKAAMJ8yFqCgAvAQAuAAQKfxoAAgoACQlCH70FABYDAAoACQlCH70FABYDAAAA.',
['腿超']='腿超可爱:BAABLgAECn8UAAMOAAkJjg8aGgC7AQAOAAkJjg8aGgC7AQANAAIJrAHtXQBDAAAAAA==.',
['至尊']='至尊者利亚:BAAALgADCgIJAgAAAA==.',
['致命']='致命优雅:BAAALgADCgEJAQAAAA==.',
['舅爺']='舅爺:BAAALgAFFAIJAgAAAA==.',
['艾夏']='艾夏:BAAALgAECgUJBwAAAA==.',
['艾雅']='艾雅黑掌:BAAALgAECgEJAQAAAA==.',
['艾露']='艾露莎丶猎心:BAAALgADCgEJAQAAAA==.',
['花葬']='花葬:BAABLgAFFH8FAAIGAAIJexB3MwCsAAAGAAIJexB3MwCsAAABLgAFFAYJAQARAAAAAA==.',
['苍星']='苍星绮晶:BAAALgAECgcJCgAAAA==.',
['苏堤']='苏堤春晓:BAAALgADCgEJAQAAAA==.',
['苏醒']='苏醒的墨荻:BAAALgAECgMJAQAAAA==.苏醒的紫鸢:BAAALgAECgYJBgAAAA==.苏醒的龙龙:BAAALgAECgQJBAAAAA==.',
['荡漾']='荡漾:BAAALgAECgIJAgAAAA==.',
['药匣']='药匣子:BAAALgADCgEJAQAAAA==.',
['萌家']='萌家三少:BAAALgAECgMJBAAAAA==.',
['萨師']='萨師傅:BAAALgAFFAIJBAAAAA==.',
['萨满']='萨满小皮皮:BAAALgAECgEJAgAAAA==.',
['落镜']='落镜:BAACLgAFFH8PAAIUAAQJYBuPCABqAQAUAAQJYBuPCABqAQAuAAQKfyIAAhQACAmDJRwKAHMDABQACAmDJRwKAHMDAAEuAAUUAwkIAAIAAhsA.',
['蒙面']='蒙面鸽王:BAAALgAECgcJBgAAAA==.',
['蓁兮']='蓁兮丶小福娃:BAAALgAECgIJAwABLgAFFAUJDwACAE0bAA==.',
['蓄力']='蓄力重击:BAAALgAECgIJAwAAAA==.',
['蓝大']='蓝大胖:BAAALgAFFAQJBAAAAA==.',
['蓝灬']='蓝灬田:BAACLgAFFH8OAAMcAAQJOiKKCACeAQAcAAQJOiKKCACeAQAbAAEJ+iOOCwBgAAAuAAQKfx4AAxwACQkMIPsFAGUDABwACQkAIPsFAGUDABsABglEIVkcAN4BAAEuAAUUBgkFAAIASiQA.',
['蓝田']='蓝田:BAAALgAFFAIJAwAAAA==.蓝田丶:BAABLgAFFH8KAAMIAAQJjyJDAQCHAQAIAAQJSR1DAQCHAQAJAAIJ2ySsFwDYAAAAAA==.',
['蛋黄']='蛋黄:BAAALgAECgEJAgAAAA==.',
['蜡笔']='蜡笔不小心:BAAALgAFFAEJAQAAAA==.蜡笔没良心:BAAALgAECgYJBgAAAA==.',
['蟋蟀']='蟋蟀:BAAALgAECggJDwAAAA==.',
['蟹老']='蟹老板的咕咕:BAAALgAFFAMJAwAAAA==.',
['血染']='血染乄剑千影:BAAALgAECgEJAQAAAA==.血染鳞甲:BAAALgAECgYJEAAAAA==.',
['血液']='血液收藏者:BAABLgAFFH8EAAIIAAIJkhgdFQCwAAAIAAIJkhgdFQCwAAAAAA==.',
['行灬']='行灬止:BAAALgAECgMJAgAAAA==.',
['言周']='言周孝文师:BAACLgAFFH8JAAMIAAUJmhUZAwBlAQAIAAUJmhUZAwBlAQAJAAIJnQoIIACVAAAuAAQKfx8AAggACQngH9cCAGgDAAgACQngH9cCAGgDAAAA.言周孝文瑡:BAAALgAECgYJDAAAAA==.',
['詹姆']='詹姆斯老姜:BAAALgAECgYJCAAAAA==.',
['许喏']='许喏:BAAALgAECgYJCQAAAA==.',
['诸葛']='诸葛白:BAABLgAECn8iAAIIAAgJeiSqBABDAwAIAAgJeiSqBABDAwAAAA==.',
['貓咪']='貓咪毁灭者:BAAALgAFFAIJBAAAAA==.',
['赤红']='赤红风暴:BAAALgAECgYJEAAAAA==.',
['踏破']='踏破虚空:BAAALgAFFAEJAQABLgAFFAUJDQAIAOsUAA==.',
['辣只']='辣只熊猫:BAAALgADCgEJAQAAAA==.',
['辻柒']='辻柒:BAAALgAFFAEJAgABLgAFFAUJBQACAFUTAA==.',
['迪克']='迪克:BAAALgADCgUJBQAAAA==.',
['逝氺']='逝氺流年:BAAALgAECgcJCwAAAA==.',
['那个']='那个锅是我的:BAAALgAECgUJCAAAAA==.那个骑士:BAAALgADCgYJBgAAAA==.',
['邪恶']='邪恶巧克力:BAAALgAECgEJAgAAAA==.',
['部落']='部落吼:BAAALgAFFAIJAgAAAA==.',
['重庆']='重庆森林:BAAALgAECgYJBgAAAA==.',
['钱都']='钱都来我这:BAAALgAECgcJBwAAAA==.',
['银竹']='银竹:BAAALgAECgUJCQAAAA==.',
['长期']='长期素食:BAAALgAECgYJBgAAAA==.',
['阿哒']='阿哒灬香飘飘:BAAALgAECgcJBgABLgAFFAcJBQALANEWAA==.',
['阿萨']='阿萨姆:BAAALgAECgQJBQAAAA==.',
['阿邱']='阿邱:BAABLgAECn8WAAIbAAgJ0hxKCQDOAgAbAAgJ0hxKCQDOAgAAAA==.',
['陈一']='陈一发儿:BAAALgAECgEJAQAAAA==.',
['陌上']='陌上的酱油瓶:BAAALgADCgYJCQAAAA==.',
['陌雪']='陌雪:BAAALgAECgQJCAAAAA==.',
['雨后']='雨后初晴:BAABLgAFFH8HAAIWAAMJCQk8CQC9AAAWAAMJCQk8CQC9AAAAAA==.',
['雨落']='雨落秦殇:BAAALgADCgQJBAAAAA==.',
['雪压']='雪压枝头低:BAAALgAECgEJAQAAAA==.',
['雷姆']='雷姆:BAABLgAECn8fAAMbAAgJFBlHDwBwAgAbAAgJFBlHDwBwAgAiAAEJ1wdLMAAhAAAAAA==.',
['霜冷']='霜冷九洲:BAAALgAECgMJBAAAAA==.',
['霜语']='霜语者:BAAALgAECgEJAgAAAA==.',
['青眼']='青眼白龙:BAAALgAECgQJBAAAAA==.',
['静丶']='静丶待:BAAALgAECgEJAgAAAA==.',
['静待']='静待:BAAALgADCgIJAgAAAA==.',
['韩玉']='韩玉儿:BAAALgAECgYJBwAAAA==.',
['领域']='领域展开:BAAALgADCgYJCwAAAA==.',
['风合']='风合月:BAAALgAECgUJBwAAAA==.',
['风吹']='风吹过来:BAAALgAECgEJAgAAAA==.',
['风度']='风度:BAAALgAECggJEAAAAA==.',
['风有']='风有秋天味道:BAAALgAECgQJBAAAAA==.',
['风骚']='风骚小娅娅:BAAALgAECgYJBgAAAA==.',
['飞雷']='飞雷万寿帝君:BAAALgADCgYJBgAAAA==.',
['马拉']='马拉丁达:BAAALgAECggJDgABLgAFFAIJCQACAOAgAA==.',
['骑士']='骑士武僧:BAAALgAECgEJAQAAAA==.',
['鬼才']='鬼才辉夜:BAAALgAECgIJAwAAAA==.',
['魅之']='魅之殇:BAAALgAECgMJAwAAAA==.',
['魔方']='魔方:BAACLgAFFH8NAAMGAAQJ1h5tBgBgAQAGAAQJ1h5tBgBgAQAYAAEJ0Ql5FwBQAAAuAAQKfyYAAwYACQm7I3ICAKEDAAYACQkAI3ICAKEDABgAAQkJJl1UAHEAAAAA.',
['鱼欲']='鱼欲遇雨:BAABLgAECn8bAAQFAAcJnhtbJQAjAgAFAAcJnhtbJQAjAgAXAAUJxhbGFQDUAAAZAAEJ+AJPFAAYAAAAAA==.',
['鲜血']='鲜血冰法:BAAALgAECgIJAgAAAA==.',
['鲱鱼']='鲱鱼臭豆腐:BAAALgAECgYJBgAAAA==.',
['黄二']='黄二丫:BAAALgAECgIJBAAAAA==.',
['黎明']='黎明的星星:BAAALgAFFAEJAQAAAA==.',
['默默']='默默无闻:BAACLgAFFH8GAAIfAAIJTRpfEgC1AAAfAAIJTRpfEgC1AAAuAAQKfxcAAh8ABglAJJgyAFgCAB8ABglAJJgyAFgCAAAA.',
['黯荭']='黯荭:BAABLgAFFH8MAAIfAAQJbyDQAQCMAQAfAAQJbyDQAQCMAQAAAA==.',
['齐齐']='齐齐怪怪的:BAAALgAECgMJAwAAAA==.',
['龍翔']='龍翔:BAAALgAECgYJBgAAAA==.',
['龙吟']='龙吟:BAAALgAECgYJCQAAAA==.',
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
