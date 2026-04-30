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

local lookup = {'DeathKnight-Unholy','Shaman-Elemental','Evoker-Augmentation','DemonHunter-Devourer','Unknown-Unknown','Monk-Brewmaster','Warrior-Protection','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Paladin-Holy','Shaman-Restoration','Monk-Windwalker','Monk-Mistweaver','Warrior-Arms','Warrior-Fury','Evoker-Devastation','Paladin-Retribution','Warlock-Demonology','Priest-Holy','Rogue-Subtlety','DemonHunter-Vengeance','DemonHunter-Havoc','Mage-Fire','Druid-Restoration','Rogue-Assassination','Rogue-Outlaw','Druid-Feral','Druid-Balance','Druid-Guardian','Warlock-Destruction','Warlock-Affliction',}
local provider = {region='CN',realm='洛萨',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abocide:BAAALgAECgMJAwAAAA==.',
Ai='Aiflexingmk:BAAALgADCgYJBgAAAA==.',
Am='Amylee:BAAALgAECgEJAQAAAA==.',
An='Anglela:BAAALgAECgEJAQAAAA==.',
Bi='Biiubiu:BAAALgAECgQJAgAAAA==.',
Bl='Bluefilm:BAAALgADCgMJBgAAAA==.',
Ca='Capaldi:BAAALgAECgEJAQAAAA==.Cathèrine:BAAALgAECgYJBgAAAA==.Cathérine:BAAALgAECgYJBgAAAA==.Cayser:BAAALgAECgcJBwAAAA==.',
Ch='Cheesns:BAAALgAECgQJBAAAAA==.',
Co='Coherence:BAAALgAECgYJDgABLgAFFAIJBwABALARAA==.',
Fa='Faithss:BAAALgAECgIJAgAAAA==.',
Fe='Felicitous:BAAALgAECgQJAgAAAA==.',
Ga='Gaara:BAAALgADCgYJBgAAAA==.',
Hi='Hime:BAAALgAECgcJEgAAAA==.',
Hy='Hyperioneye:BAAALgAECgYJCgAAAA==.',
La='Larethian:BAAALgAFFAIJAgABLgAFFAYJFgACAMUZAA==.',
Lo='Longzmj:BAAALgAECgUJBQABLgAFFAQJCAADAM8QAA==.',
Ma='Madetohealer:BAAALgAECgIJAgAAAA==.Man:BAAALgAECgcJBgAAAA==.Mangototo:BAAALgAECgcJCQAAAA==.',
Mf='Mfeyes:BAAALgAECgEJAQAAAA==.',
Mi='Mirandda:BAAALgAECgcJBwAAAA==.',
Ms='Mssjlr:BAAALgAFFAEJAQAAAA==.',
My='Mykka:BAEBLgAFFH8IAAIEAAQJBgsZFAAxAQAEAAQJBgsZFAAxAQAAAA==.',
Ne='Neil:BAAALgADCgEJAQAAAA==.',
Ni='Ninja:BAAALgAECgEJAQAAAA==.',
Pr='Pray:BAAALgAFFAQJBAAAAA==.',
Qu='Quixel:BAAALgADCgEJAQAAAA==.',
Ro='Rockordie:BAAALgADCgcJBwAAAA==.Ronery:BAAALgAECgMJBAAAAA==.Roninc:BAAALgADCgYJBgAAAA==.',
Ru='Ruru:BAAALgAECgcJCQAAAA==.',
Ry='Ryze:BAAALgAECgMJAwAAAA==.',
Sa='Salamender:BAAALgAFFAEJAgABLgAFFAMJAwAFAAAAAA==.',
Se='Sephroth:BAAALgAECgEJAQAAAA==.',
Sp='Spiritoffire:BAAALgAECgYJDgAAAA==.',
Su='Suwajo:BAABLgAECn8ZAAIBAAcJSBj8YADQAQABAAcJSBj8YADQAQAAAA==.',
Sw='Swifty:BAAALgAECgYJEQAAAA==.',
Vi='Vincentm:BAAALgADCgYJBgAAAA==.',
Xi='Xiaolu:BAAALgAFFAIJAgAAAA==.',
Ye='Yeahlo:BAAALgAECgYJCAAAAA==.',
Za='Zales:BAAALgAFFAMJAwAAAA==.',
['一不']='一不讲武德一:BAABLgAFFH8FAAIGAAMJcg1jCwCcAAAGAAMJcg1jCwCcAAAAAA==.',
['一休']='一休丶:BAAALgAECgcJBwAAAA==.',
['一月']='一月未央:BAABLgAECn8XAAIHAAgJ9xWxEgDeAQAHAAgJ9xWxEgDeAQAAAA==.',
['一杯']='一杯小可乐:BAAALgAECgkJAwAAAA==.',
['一枪']='一枪射死你:BAAALgADCgIJAgAAAA==.',
['一西']='一西瓜瓤一:BAAALgAECgkJBwAAAA==.',
['一路']='一路存孤胆:BAAALgADCgQJBQAAAA==.',
['七点']='七点丶起床:BAAALgAECgYJBgAAAA==.',
['上官']='上官红泪:BAAALgAECgkJBwAAAA==.',
['不会']='不会加血西八:BAAALgAECgIJAgAAAA==.',
['不信']='不信奉圣光:BAAALgAECgEJAgAAAA==.',
['不吃']='不吃饭不洗碗:BAAALgAECgMJAwAAAA==.',
['东欧']='东欧:BAAALgAECgEJAQAAAA==.',
['丢了']='丢了薇笑:BAAALgAECgYJCQABLgAECgcJEgAFAAAAAA==.',
['两难']='两难:BAAALgADCgYJBgAAAA==.',
['丧钟']='丧钟镇镇长:BAAALgAECgUJDQAAAA==.',
['丶丨']='丶丨五漏鱼:BAAALgAFFAQJBAAAAA==.丶丨六漏鱼:BAABLgAFFH8OAAICAAcJuBTqAABFAgACAAcJuBTqAABFAgAAAA==.丶丨四漏鱼:BAABLgAFFH8FAAICAAQJcQ3dFwCXAAACAAQJcQ3dFwCXAAAAAA==.',
['丶拉']='丶拉布布:BAAALgAECgYJCwAAAA==.',
['丶方']='丶方世玉:BAAALgAECgEJAgAAAA==.',
['丶月']='丶月弦:BAABLgAECn8pAAMIAAgJPBkEHgBSAgAIAAgJPBkEHgBSAgAJAAYJXA8VRgA8AQAAAA==.',
['丶苗']='丶苗翠花:BAAALgAECgMJAwAAAA==.',
['丶魂']='丶魂淡:BAAALgAECgEJAgAAAA==.',
['乱洗']='乱洗澡的皂皂:BAAALgAECgEJAgAAAA==.',
['二师']='二师兄:BAAALgAECgEJAQAAAA==.',
['二阶']='二阶:BAAALgAECgUJBwAAAA==.',
['云陌']='云陌若:BAAALgAFFAEJAQAAAA==.',
['亚撒']='亚撒:BAAALgADCgcJBwAAAA==.',
['亲亲']='亲亲不下火线:BAAALgAECgcJAQAAAA==.',
['今夕']='今夕又何年:BAAALgAECgQJBgAAAA==.',
['伊织']='伊织丶:BAAALgAECgEJAgAAAA==.',
['优思']='优思明:BAAALgAFFAEJAQAAAA==.',
['你的']='你的小命根:BAABLgAFFH8FAAIKAAIJPxD8PACyAAAKAAIJPxD8PACyAAAAAA==.',
['依旧']='依旧战神:BAAALgAECgYJCwABLgAFFAcJHAAKAKwbAA==.',
['傩舞']='傩舞:BAAALgAFFAQJBAAAAA==.',
['僾歆']='僾歆覚纙:BAAALgADCgQJBAAAAA==.',
['元素']='元素之星:BAAALgADCgcJBwAAAA==.',
['光歌']='光歌醚誓:BAAALgAECgEJAgAAAA==.',
['克罗']='克罗托:BAAALgAECgIJAgAAAA==.',
['兜兜']='兜兜里有爱情:BAAALgAECgIJAwAAAA==.兜兜里莫有糖:BAAALgAECgcJEwAAAA==.',
['共枕']='共枕秋风:BAAALgAECgYJBgAAAA==.',
['关云']='关云裳:BAEALgAECgcJDgAAAA==.',
['冥月']='冥月:BAAALgAECgUJBwAAAA==.',
['冬月']='冬月:BAAALgAFFAQJBAAAAA==.',
['冰可']='冰可乐:BAAALgAECgYJBgAAAA==.',
['冷面']='冷面三千:BAAALgAECgQJBAAAAA==.',
['凭虚']='凭虚御风:BAABLgAECn8UAAILAAYJuRtHOQCVAQALAAYJuRtHOQCVAQAAAA==.',
['别人']='别人家的奶牛:BAAALgAECgMJAwAAAA==.',
['别来']='别来沾边丶:BAAALgAECgYJBgAAAA==.',
['削个']='削个榴莲皮:BAAALgADCgcJBwAAAA==.',
['加拉']='加拉赫:BAAALgAECggJBwABLgAFFAUJBQABAFUTAA==.',
['加西']='加西奥斯:BAAALgADCgEJAQAAAA==.',
['千千']='千千大祭司:BAACLgAFFH8LAAIMAAQJkh8QBAAzAQAMAAQJkh8QBAAzAQAuAAQKfxkAAwwABwnoH3wXAFoCAAwABwnoH3wXAFoCAAIAAQlIAamXABcAAAAA.',
['南溟']='南溟:BAAALgAECgMJAwAAAA==.',
['博尔']='博尔纳:BAAALgAECgMJAwAAAA==.',
['卡喵']='卡喵姨:BAAALgADCgQJBAAAAA==.',
['卡嘉']='卡嘉莉:BAAALgAECgMJAwAAAA==.',
['双刀']='双刀老太公:BAAALgAECgIJAgAAAA==.',
['取什']='取什么名字好:BAAALgAECgYJCQAAAA==.',
['古今']='古今凶兆:BAAALgAFFAEJAQAAAA==.',
['古尔']='古尔惮:BAAALgAECgUJBQAAAA==.',
['可以']='可以不可以:BAAALgAFFAIJBAAAAA==.',
['可爱']='可爱的小憨憨:BAAALgAFFAEJAQAAAA==.',
['叶子']='叶子:BAAALgAECgIJAgAAAA==.',
['叶诗']='叶诗灵:BAAALgAECgYJCQAAAA==.',
['吉伊']='吉伊:BAABLgAFFH8OAAIEAAUJTyOhAwD+AQAEAAUJTyOhAwD+AQAAAA==.',
['君临']='君临一天下:BAAALgAECgIJAwAAAA==.',
['君希']='君希何惜兮:BAAALgAFFAUJAQAAAA==.',
['吨丶']='吨丶吨吨:BAAALgAECggJCQAAAA==.',
['启蒙']='启蒙者斯文:BAAALgAECgIJAQAAAA==.',
['吹雪']='吹雪樱:BAAALgAECgUJBQAAAA==.',
['周润']='周润发:BAAALgAECggJBwAAAA==.',
['咪嘞']='咪嘞个喵丶:BAAALgAECgQJBAAAAA==.',
['咸鱼']='咸鱼酱:BAAALgAECgMJBQAAAA==.',
['哈皮']='哈皮落苏:BAAALgAFFAIJAwAAAA==.',
['哈酷']='哈酷呐玛塔塔:BAAALgAFFAIJAwAAAA==.',
['哼哼']='哼哼:BAAALgAECgEJAQAAAA==.',
['善良']='善良之法:BAAALgAECgYJEQAAAA==.善良的野子路:BAAALgAFFAQJBAAAAA==.',
['喵咪']='喵咪丶:BAAALgAECgIJAgAAAA==.',
['喵喵']='喵喵悍匪德:BAAALgAECgYJBgAAAA==.喵喵悍匪法:BAAALgAECgYJDAAAAA==.',
['嘿你']='嘿你的溢达:BAAALgAECgUJBQAAAA==.',
['四枫']='四枫院夜一:BAAALgAECgUJCAAAAA==.',
['图图']='图图大魔王:BAAALgAECgEJAgAAAA==.',
['土行']='土行僧丨:BAABLgAFFH8FAAMNAAIJvAqwDQCWAAANAAIJvAqwDQCWAAAOAAIJHA/OCACMAAAAAA==.',
['圣光']='圣光忽悠你:BAAALgAECgYJCQAAAA==.',
['圣旋']='圣旋风:BAAALgAECgIJAgAAAA==.',
['圣殿']='圣殿大领主:BAAALgAECgEJAQAAAA==.',
['圣白']='圣白莲:BAAALgAECggJBwAAAA==.',
['坦格']='坦格尼安:BAAALgAECgYJBgAAAA==.',
['垫背']='垫背狂人:BAAALgAECgUJBwAAAA==.',
['埃辛']='埃辛诺斯蛋刀:BAAALgADCgEJAQAAAA==.',
['基草']='基草勿六:BAACLgAFFH8QAAMCAAUJTxbRBACUAQACAAUJTxbRBACUAQAMAAMJBxI4IABRAAAuAAQKfyYAAwIACAmtIhgKAPICAAIACAmtIhgKAPICAAwAAwlQIZdnAPAAAAAA.',
['堕落']='堕落的狒狒:BAAALgAECgMJAwAAAA==.',
['墨丨']='墨丨祁:BAAALgAECgUJBQAAAA==.',
['墨德']='墨德雷恩:BAAALgADCgEJAQAAAA==.',
['墨者']='墨者丨战:BAAALgAECgUJBQAAAA==.',
['夏日']='夏日星辉:BAAALgADCgQJBAAAAA==.',
['夕丨']='夕丨灵:BAAALgAECgEJAQAAAA==.',
['多肉']='多肉青提乌龙:BAAALgAFFAIJAwAAAA==.',
['夜丶']='夜丶休止符:BAAALgAECgYJDQAAAA==.',
['夜静']='夜静静:BAAALgAECgUJCAAAAA==.',
['夜魅']='夜魅罗:BAAALgAFFAIJAwAAAA==.',
['大只']='大只牛:BAAALgADCgEJAQAAAA==.',
['大角']='大角懵牛:BAAALgAECgYJCQAAAA==.',
['大馍']='大馍:BAAALgAECgYJBwAAAA==.',
['天云']='天云之颠:BAAALgAECgUJCAAAAA==.',
['天命']='天命工具人:BAAALgAECgUJBQAAAA==.',
['天天']='天天想不出:BAABLgAFFH8IAAIKAAMJhRRxEgAAAQAKAAMJhRRxEgAAAQAAAA==.',
['天引']='天引:BAAALgAECgcJBwAAAA==.',
['天手']='天手让叶:BAAALgAFFAEJAQAAAA==.',
['天灾']='天灾骨锺:BAAALgAECgcJDAAAAA==.',
['天狐']='天狐十三幺:BAAALgAECgcJDgAAAA==.',
['天知']='天知遥:BAAALgADCgYJBgABLgAECgEJAQAFAAAAAA==.',
['天賦']='天賦乂曦:BAAALgAECgEJAQAAAA==.天賦乂熈:BAAALgAECgYJBwAAAA==.天賦乂熙:BAAALgAECgEJAgAAAA==.',
['天赐']='天赐的礼物:BAAALgAECgEJAgAAAA==.',
['天选']='天选之战:BAAALgAECgkJCQABLgAECgkJFwAHAMAcAA==.',
['奈斯']='奈斯天引:BAAALgAECgYJCwAAAA==.',
['奥兹']='奥兹华尔德:BAAALgAFFAIJAgAAAA==.',
['女王']='女王的口水歌:BAAALgAECgEJAQAAAA==.',
['妖月']='妖月斌斌:BAAALgADCgUJBQAAAA==.',
['妞大']='妞大:BAAALgAECgkJDAAAAA==.',
['妤丶']='妤丶:BAAALgAECgUJCAAAAA==.',
['学儿']='学儿食媳汁:BAAALgADCgEJAQAAAA==.',
['守护']='守护灬之光:BAAALgAECgYJEgAAAA==.',
['守正']='守正:BAAALgADCgEJAQAAAA==.',
['安碧']='安碧拉:BAAALgADCgUJBQAAAA==.',
['定冬']='定冬:BAAALgAECgYJBgAAAA==.',
['宝宝']='宝宝奶有毒:BAAALgAECgYJDAAAAA==.',
['寒冬']='寒冬已至:BAAALgAECgMJBQAAAA==.',
['小卡']='小卡尔:BAABLgAFFH8GAAMPAAMJXxRUCABsAAAQAAIJ6gw/GgCgAAAPAAEJRyNUCABsAAAAAA==.',
['小李']='小李杜:BAAALgAECgYJDAAAAA==.',
['小柒']='小柒不玩坦:BAAALgAECgYJCgAAAA==.',
['小汶']='小汶:BAAALgAECgEJAQAAAA==.',
['小溜']='小溜子:BAAALgAECgIJAgAAAA==.',
['小爱']='小爱无言:BAAALgADCgcJBwABLgAFFAQJBwABAO0eAA==.',
['小白']='小白心里软:BAAALgADCgEJAQAAAA==.',
['小胖']='小胖嘟:BAABLgAFFH8FAAIMAAIJuRxjFwCeAAAMAAIJuRxjFwCeAAAAAA==.',
['小豪']='小豪快跑:BAAALgAECgEJAQAAAA==.',
['小野']='小野冢小町:BAACLgAFFH8GAAIDAAIJrwWBDgCNAAADAAIJrwWBDgCNAAAuAAQKfyIAAwMACAnSFDcJAFQBABEABgnQFI4ZAGgBAAMACAmWEjcJAFQBAAAA.',
['小鸟']='小鸟哔哔:BAAALgAECgEJAgAAAA==.',
['少绾']='少绾:BAABLgAECn8XAAMLAAcJpyL3DQCpAgALAAcJpyL3DQCpAgASAAEJPQV0VwEnAAAAAA==.',
['尛申']='尛申:BAAALgAECgEJAwAAAA==.',
['峨眉']='峨眉:BAAALgAFFAEJAQAAAA==.',
['左手']='左手恩珑:BAAALgAECgMJAwAAAA==.',
['巧克']='巧克力梦梦:BAAALgADCgIJAgAAAA==.巧克力饼饼:BAAALgADCgIJAgAAAA==.',
['布侍']='布侍戈门:BAAALgAECgYJCQAAAA==.',
['帮那']='帮那拼了:BAABLgAECn8iAAMIAAgJlx9THgBQAgAIAAcJ1R1THgBQAgAJAAcJmBo8IgARAgAAAA==.',
['年过']='年过半摆:BAAALgADCgYJBgAAAA==.',
['幻亦']='幻亦幻:BAAALgAECgQJBAAAAA==.',
['幻影']='幻影法杖:BAAALgAECgEJAQAAAA==.',
['康斯']='康斯坦叮:BAAALgADCgIJAgAAAA==.',
['开朗']='开朗的憨憨:BAAALgAFFAMJBAAAAA==.',
['张鱼']='张鱼小丸子:BAAALgADCgYJBgAAAA==.',
['当納']='当納的盛宴:BAAALgAECgEJAgAAAA==.',
['当纳']='当纳的盛宴:BAAALgAECgEJAgAAAA==.',
['彼岸']='彼岸的云端:BAAALgAECgYJBgAAAA==.',
['很困']='很困惑的浪漫:BAAALgADCgUJBgAAAA==.',
['很黑']='很黑很强壮:BAAALgAECgEJAQAAAA==.',
['徒有']='徒有羡鱼情:BAAALgAECgEJAQAAAA==.',
['德妹']='德妹:BAAALgADCgUJBQAAAA==.',
['心无']='心无断念:BAABLgAFFH8FAAIBAAMJhRO1QgCdAAABAAMJhRO1QgCdAAAAAA==.',
['快扶']='快扶朕起来:BAAALgAECgMJAwAAAA==.',
['急耳']='急耳假蛋:BAAALgAECgUJCAAAAA==.',
['恶魔']='恶魔伙伴:BAABLgAECn8UAAITAAYJmRTzcwB2AQATAAYJmRTzcwB2AQAAAA==.恶魔憨:BAAALgAECgEJAQAAAA==.恶魔法则:BAAALgAFFAIJBAAAAA==.',
['悲画']='悲画扇:BAABLgAECn8aAAIUAAcJCyNcDACOAgAUAAcJCyNcDACOAgAAAA==.',
['愤怒']='愤怒的奶油猪:BAAALgAECgMJBQAAAA==.',
['憨憨']='憨憨圣骑:BAAALgAECgEJAQAAAA==.',
['戊己']='戊己庚辛壬癸:BAAALgAECgUJCwAAAA==.',
['战无']='战无歇:BAAALgAECgcJDQAAAA==.',
['战豆']='战豆鸡:BAABLgAFFH8FAAIVAAMJPBktDAAgAQAVAAMJPBktDAAgAQAAAA==.',
['手抓']='手抓肉:BAAALgAECgYJCwAAAA==.',
['打企']='打企鹅的豆豆:BAAALgAECggJCwAAAA==.',
['打得']='打得一拳开:BAAALgADCgUJBQAAAA==.',
['抓根']='抓根寳:BAACLgAFFH8JAAMIAAMJnx3yBwAlAQAIAAMJnx3yBwAlAQAJAAIJuRC+HQCfAAAuAAQKfyEAAwgABwkLJXMJAP4CAAgABwkFJXMJAP4CAAkABgljHvUvALMBAAAA.',
['招牌']='招牌小猎:BAAALgAFFAQJBAAAAA==.招牌小萨:BAAALgAECgcJBwAAAA==.招牌德德:BAAALgAECgcJBwAAAA==.',
['捕鱼']='捕鱼之海:BAABLgAFFH8IAAIKAAQJzg0VHQBWAQAKAAQJzg0VHQBWAQAAAA==.',
['提咔']='提咔:BAAALgAECgMJAwAAAA==.',
['摩登']='摩登大圣:BAABLgAECn8WAAIIAAcJGxVqOADMAQAIAAcJGxVqOADMAQAAAA==.',
['支付']='支付鸨:BAAALgAECgQJBgAAAA==.',
['收割']='收割猛如虎:BAAALgAECgIJAgAAAA==.',
['新雨']='新雨晴:BAAALgADCgUJBQAAAA==.',
['施南']='施南不夜侯:BAAALgAECgIJAgAAAA==.',
['无想']='无想:BAABLgAFFH8IAAIEAAUJHRHnEQBAAQAEAAUJHRHnEQBAAQAAAA==.',
['无敌']='无敌小火龙:BAAALgADCgIJAgAAAA==.',
['无眠']='无眠乄夜:BAAALgAFFAEJAQAAAA==.',
['无睡']='无睡意:BAAALgAECgcJCQAAAA==.',
['既定']='既定之天命:BAAALgADCgEJAQAAAA==.',
['时间']='时间的灰尘:BAAALgAECgEJAQAAAA==.',
['明不']='明不祥:BAAALgAECgYJBAAAAA==.',
['星如']='星如雨:BAAALgAECgUJBgAAAA==.',
['星曦']='星曦:BAAALgAECgcJDQAAAA==.',
['星级']='星级瞎混混:BAAALgAECgYJCQAAAA==.',
['晓树']='晓树快跑:BAAALgAECgIJAgAAAA==.',
['晴空']='晴空万里:BAAALgAECgIJAwAAAA==.',
['暗影']='暗影议会主任:BAAALgAECgUJAgAAAA==.',
['暗胧']='暗胧:BAAALgAFFAQJBAAAAA==.',
['暗黑']='暗黑风暴大妈:BAAALgAECgYJBgAAAA==.',
['曾经']='曾经疾風:BAAALgAECgIJAwAAAA==.曾经疾风:BAAALgAECgQJBQAAAA==.',
['最初']='最初的自己:BAAALgAECgcJBgAAAA==.',
['最好']='最好的你:BAAALgAECgIJAgAAAA==.',
['月桂']='月桂女神:BAAALgAECgQJBAAAAA==.',
['有信']='有信仰的咸鱼:BAAALgAECgEJAQAAAA==.',
['有吾']='有吾不缺德:BAAALgADCgEJAQAAAA==.',
['有理']='有理想的咸鱼:BAAALgAECgEJAwAAAA==.',
['朕涩']='朕涩你无罪:BAAALgAECgIJAwAAAA==.',
['木香']='木香:BAAALgAECgEJAQAAAA==.',
['未闻']='未闻花期:BAAALgAECgYJBgAAAA==.未闻花葬:BAAALgAFFAIJAwAAAA==.',
['机智']='机智的弔丝:BAAALgAECgYJDgAAAA==.',
['杀伐']='杀伐:BAAALgAECgEJAQAAAA==.',
['李空']='李空城:BAAALgADCgYJBgAAAA==.',
['村长']='村长小卡卡:BAAALgAECgkJCQAAAA==.',
['杨威']='杨威利:BAAALgAECgMJBQAAAA==.',
['杰笑']='杰笑天:BAAALgADCgUJBQAAAA==.',
['果汁']='果汁满满:BAAALgAECgEJAQAAAA==.',
['柠檬']='柠檬頭:BAAALgAECgMJBAAAAA==.',
['梦付']='梦付丶:BAAALgAECgcJBwABLgAFFAQJDAAGAMIUAA==.梦付丶丶:BAACLgAFFH8MAAIGAAQJwhRCEAD/AAAGAAQJwhRCEAD/AAAuAAQKfyQAAwYACAlrG+YWAFACAAYACAlrG+YWAFACAA4ABQnrDWYOAPwAAAAA.梦付丶丿:BAABLgAECn8aAAMWAAcJDBILDQCHAQAWAAcJDBILDQCHAQAXAAEJmgN+egApAAABLgAFFAQJDAAGAMIUAA==.梦付丿:BAABLgAFFH8MAAIHAAQJZyAaAwBoAQAHAAQJZyAaAwBoAQABLgAFFAQJDAAGAMIUAA==.梦付灬丿:BAAALgAFFAEJAQABLgAFFAQJDAAGAMIUAA==.',
['梧桐']='梧桐秋雪:BAAALgAECgEJAgAAAA==.',
['楚门']='楚门:BAAALgAECgEJAQAAAA==.',
['次元']='次元小番茄:BAABLgAFFH8HAAIBAAIJsBEaGQCjAAABAAIJsBEaGQCjAAAAAA==.',
['欧壹']='欧壹酱:BAAALgAFFAUJAgAAAA==.',
['欧洲']='欧洲钢琴师:BAAALgAFFAIJAgABLgAFFAMJCAAKAIUUAA==.',
['欧贝']='欧贝:BAAALgAECgIJAgAAAA==.',
['欧阳']='欧阳喳喳:BAAALgAECgUJCAAAAA==.',
['武丶']='武丶僧丶:BAAALgAECgcJEQAAAA==.',
['殊途']='殊途路人:BAAALgADCgEJAQAAAA==.',
['残心']='残心:BAAALgAFFAQJBAAAAA==.',
['残月']='残月:BAABLgAFFH8GAAMXAAUJlw+TDABVAAAXAAEJbQ6TDABVAAAEAAUJmg4AAAAAAAAAAA==.',
['毛球']='毛球:BAAALgADCgYJBgAAAA==.',
['永不']='永不切坦:BAAALgAECgcJEwAAAA==.',
['永远']='永远在搔动:BAAALgAFFAEJAQAAAA==.',
['沐沐']='沐沐么沐沐:BAAALgAECgYJEAAAAA==.',
['沸腾']='沸腾鱼片:BAAALgADCgYJBgAAAA==.',
['油炸']='油炸团子:BAAALgAECgYJBwAAAA==.油炸洋芋:BAAALgAECgEJAQAAAA==.',
['泉拓']='泉拓人:BAAALgAECgEJAQAAAA==.',
['法力']='法力余烬:BAABLgAECn8hAAMKAAcJuSJILQC9AgAKAAcJuSJILQC9AgAYAAEJkBNsDgBBAAAAAA==.',
['泷一']='泷一龙人:BAACLgAFFH8IAAIDAAQJzxBqDAA4AQADAAQJzxBqDAA4AQAuAAQKfxcAAwMABglHHJ0aAPUBAAMABgkJHJ0aAPUBABEABQlEG0IdAEQBAAAA.',
['流年']='流年沫苏:BAAALgAECgcJDgAAAA==.',
['浅唱']='浅唱丶小情歌:BAAALgAECgkJCQAAAA==.',
['浪哩']='浪哩个浪:BAAALgAFFAEJAQAAAA==.',
['海鸥']='海鸥:BAAALgAECgMJBAAAAA==.',
['清水']='清水烏鱼:BAAALgAECgYJCwABLgAECgcJIQAKALkiAA==.',
['渡边']='渡边麻友丶:BAAALgAECgQJBQABLgAFFAMJBgARAFYZAA==.',
['渣渣']='渣渣莉:BAAALgAECgEJAgAAAA==.',
['温柔']='温柔藏匿于心:BAAALgAFFAIJAwAAAA==.',
['漓纱']='漓纱:BAAALgAECgUJBgAAAA==.',
['漫天']='漫天飛雪:BAAALgAECgQJCgAAAA==.',
['漺歪']='漺歪歪:BAAALgAECgEJAgAAAA==.',
['潘达']='潘达天引:BAACLgAFFH8MAAIGAAQJOiVmBACTAQAGAAQJOiVmBACTAQAuAAQKfx0AAwYACAndJEQEAEgDAAYACAndJEQEAEgDAA0AAQljExl0AEQAAAAA.',
['火山']='火山唐太宗:BAAALgAECgkJCQAAAA==.',
['炉石']='炉石无敌:BAAALgAECgcJEQAAAA==.',
['焦糖']='焦糖不甜:BAAALgAECgYJCQAAAA==.',
['煊赫']='煊赫门:BAAALgADCgEJAQAAAA==.',
['熊霸']='熊霸丶天下:BAAALgAECgYJCgAAAA==.',
['爆奶']='爆奶通:BAAALgAECgEJAQAAAA==.',
['爱丁']='爱丁堡:BAAALgAECgEJAQAAAA==.',
['爱吃']='爱吃肉的小七:BAABLgAECn8cAAIZAAgJZh+pBgADAgAZAAgJZh+pBgADAgAAAA==.',
['爱喷']='爱喷的火龙:BAAALgAECgUJCAAAAA==.',
['爱洗']='爱洗澡的皂皂:BAAALgAECgEJAQAAAA==.',
['爱炸']='爱炸的大鞭炮:BAAALgAECgIJAwAAAA==.',
['爽妹']='爽妹:BAAALgAECgYJCgAAAA==.',
['牧浴']='牧浴:BAAALgAECgUJBwAAAA==.',
['猥灬']='猥灬琐灬小法:BAAALgAECgEJAQABLgAFFAcJBAAFAAAAAA==.',
['猪猪']='猪猪包:BAABLgAECn8UAAMSAAgJGx2BZgCzAQASAAYJihmBZgCzAQALAAcJWg6IOQCUAQAAAA==.',
['王多']='王多鱼:BAAALgAECgYJDAAAAA==.',
['珍娜']='珍娜:BAAALgAECgcJDAAAAA==.',
['甜芽']='甜芽樱桃:BAAALgAECgIJAwAAAA==.',
['甲辰']='甲辰冬月:BAAALgADCgUJBQAAAA==.',
['疯狂']='疯狂胖墩:BAAALgAECgQJBAAAAA==.',
['癫狂']='癫狂的牛:BAAALgAECgEJAQAAAA==.',
['白天']='白天卖烧烤:BAAALgADCgMJAwAAAA==.',
['白鸟']='白鸟七丶:BAAALgAECgYJBQAAAA==.',
['皮卡']='皮卡车:BAAALgAECgQJBQAAAA==.',
['真亦']='真亦真:BAAALgAECgYJBwAAAA==.',
['破碎']='破碎:BAAALgAFFAQJBAAAAA==.',
['硫代']='硫代硫酸钠:BAAALgAECgYJBgAAAA==.',
['碱式']='碱式碳酸铜:BAAALgAECgYJCQAAAA==.',
['神丶']='神丶不佑我:BAAALgAECgUJBQAAAA==.',
['神之']='神之末路:BAABLgAFFH8JAAIIAAQJJhZbBABbAQAIAAQJJhZbBABbAQAAAA==.',
['神圣']='神圣怪蜀黍:BAAALgAFFAQJBAAAAA==.',
['离祷']='离祷:BAAALgAECgIJAgAAAA==.',
['秋乾']='秋乾家沙发:BAAALgAECgcJAQAAAA==.秋乾家电脑桌:BAAALgAECgMJAQAAAA==.秋乾家饮水机:BAAALgAECgcJAQAAAA==.',
['空条']='空条徐伦:BAAALgAECgIJAgAAAA==.',
['空水']='空水漫漫:BAAALgAECgYJCAAAAA==.',
['空空']='空空:BAAALgAECgMJBwAAAA==.',
['笙灵']='笙灵月茹:BAABLgAECn8ZAAIGAAgJ9xsPEwB5AgAGAAgJ9xsPEwB5AgAAAA==.',
['笼中']='笼中雀:BAABLgAECn8cAAMEAAgJghohJQB0AgAEAAgJghohJQB0AgAXAAQJoA22SwDAAAAAAA==.',
['米修']='米修丶:BAAALgAECgEJAQAAAA==.',
['精灵']='精灵飞飞:BAAALgAECgkJCwAAAA==.',
['糸岩']='糸岩:BAACLgAFFH8RAAMQAAQJIhg4CgBUAQAQAAQJIhg4CgBUAQAHAAEJyASIEQA3AAAuAAQKfxYAAxAABwncHkshAEkCABAABgnpI0shAEkCAAcAAwmRGaEoAPoAAAAA.',
['素雪']='素雪猩红:BAAALgAECgYJBgAAAA==.',
['紫色']='紫色犹郁:BAAALgADCgUJBgAAAA==.',
['红莲']='红莲劫焰丶:BAAALgAECgEJAQAAAA==.红莲劫焱:BAAALgAECgMJAwAAAA==.',
['纳塔']='纳塔利亚:BAAALgADCgEJAQAAAA==.',
['绝影']='绝影丶:BAABLgAFFH8MAAIEAAUJJBTuEQBAAQAEAAUJJBTuEQBAAQAAAA==.',
['翎羽']='翎羽:BAAALgAECgkJEgABLgAFFAUJBAAFAAAAAA==.',
['翼之']='翼之圣光:BAAALgAECgQJBgAAAA==.',
['老休']='老休闲:BAAALgADCgIJAgAAAA==.',
['老弗']='老弗丁:BAABLgAFFH8IAAIQAAQJDAWUDwAOAQAQAAQJDAWUDwAOAQAAAA==.',
['肉弹']='肉弹戦车:BAAALgAFFAIJAwAAAA==.',
['肥羊']='肥羊跋扈:BAACLgAFFH8LAAMVAAUJDBkvBgB9AQAVAAQJDBkvBgB9AQAaAAEJAABNBwBQAAAuAAQKfygABBUACAmZIhwIAA4DABUACAmZIhwIAA4DABoABAk2G08PAB0BABsABQmAD4ECAAkBAAAA.',
['胧闪']='胧闪:BAAALgAFFAQJBAAAAA==.',
['脏牧']='脏牧专精:BAAALgAFFAEJAQAAAA==.',
['自由']='自由德心:BAAALgAECgkJDQABLgAFFAQJEAAcAOsiAA==.',
['芒果']='芒果椰奶:BAAALgADCgMJAwAAAA==.',
['芙兰']='芙兰贝尔琦:BAAALgAECgMJAwAAAA==.',
['花心']='花心大少爷:BAAALgAECgEJAQAAAA==.',
['花香']='花香满人间:BAAALgAECgUJBQAAAA==.',
['苦涩']='苦涩花开:BAAALgAECgUJBQAAAA==.',
['英姿']='英姿安犹在:BAAALgAECgUJBgAAAA==.',
['草薙']='草薙:BAAALgAFFAQJBAAAAA==.',
['莎莎']='莎莎亖:BAAALgAECgYJBgAAAA==.',
['菈乌']='菈乌玛:BAACLgAFFH8FAAMdAAMJIxb4EQC2AAAdAAIJSRz4EQC2AAAZAAEJcBsAAAAAAAAuAAQKfxcAAxkABgk/JaAWAIECABkABgk/JaAWAIECAB0ABQm2I5gqAKsBAAAA.',
['菠萝']='菠萝面包:BAAALgAECgQJBwAAAA==.',
['菲尔']='菲尔迦纳:BAABLgAECn8gAAIVAAgJgwowIwDfAQAVAAgJgwowIwDfAQAAAA==.',
['萌新']='萌新小公举:BAAALgAFFAYJAwAAAA==.',
['萌萌']='萌萌的蕾姆:BAABLgAFFH8GAAIeAAQJrBTGAQAyAQAeAAQJrBTGAQAyAQAAAA==.',
['萨满']='萨满:BAAALgAECgYJCAABLgAECgcJEAAFAAAAAA==.',
['蒂法']='蒂法使:BAAALgAECgEJAQAAAA==.',
['蛋疼']='蛋疼致癌:BAAALgAECgQJBQAAAA==.',
['蝴蝶']='蝴蝶的梦:BAAALgADCgYJBgAAAA==.',
['血狼']='血狼:BAAALgAECgYJDAAAAA==.',
['血色']='血色乱舞:BAAALgAECgMJBwAAAA==.',
['裂鸟']='裂鸟爆蛋拳:BAAALgAECgUJBgAAAA==.',
['装糖']='装糖阴他一手:BAAALgADCgEJAQAAAA==.',
['角角']='角角在哪里:BAAALgAECgMJAwAAAA==.',
['请你']='请你吃花生:BAAALgADCgEJAQAAAA==.',
['豆芽']='豆芽张:BAAALgAFFAEJAgAAAA==.',
['豆豆']='豆豆:BAAALgAFFAIJAgAAAA==.豆豆的痘痘:BAAALgAECgEJAQAAAA==.',
['贼莫']='贼莫莫丶:BAAALgAECgEJAQAAAA==.',
['赤兔']='赤兔:BAAALgAFFAIJAgAAAA==.',
['赤月']='赤月屠魔:BAAALgAECgMJAwAAAA==.',
['起门']='起门拉人:BAAALgAFFAQJBAAAAA==.',
['轲特']='轲特丶揍敌客:BAAALgAECgQJCAAAAA==.',
['辣条']='辣条鲜人:BAAALgAECgEJAQAAAA==.',
['达泊']='达泊西汀:BAAALgAECgcJDgAAAA==.',
['过千']='过千山:BAAALgAECgcJCQAAAA==.',
['追忆']='追忆:BAAALgAECgcJDAAAAA==.',
['逆天']='逆天橘子:BAAALgADCgYJBgAAAA==.',
['逐风']='逐风者灬秦:BAAALgAECgYJCAAAAA==.',
['逼人']='逼人:BAAALgADCgEJAQAAAA==.',
['逼王']='逼王曹达华:BAAALgAECgYJBgAAAA==.',
['郁闷']='郁闷的灵灵:BAAALgAFFAEJAQAAAA==.',
['醉猫']='醉猫大侠:BAAALgADCgQJBAAAAA==.',
['针目']='针目缝:BAABLgAECn8aAAMTAAkJLBM8PQAYAgATAAgJLBM8PQAYAgAfAAIJahOmSQCRAAAAAA==.',
['钢宗']='钢宗霍子:BAAALgAFFAEJAgAAAA==.',
['钦州']='钦州第一柔情:BAAALgAECgYJBQAAAA==.',
['闪电']='闪电波比:BAAALgAECgYJCwABLgAFFAQJCwAMAJIfAA==.',
['阿墨']='阿墨:BAACLgAFFH8RAAMTAAUJ8iSTBwCsAQATAAQJgySTBwCsAQAfAAIJsiV8CADZAAAuAAQKfyYABBMACAlEJSgnAHUCABMACAkxHSgnAHUCAB8ABAkZJmURAMEBACAAAQkAADs4ABkAAAAA.',
['阿奴']='阿奴比:BAAALgAECgYJCQAAAA==.',
['阿脆']='阿脆:BAAALgAECgYJBwAAAA==.',
['降龙']='降龙伏虎:BAAALgADCgEJAQAAAA==.',
['雕文']='雕文五千好贵:BAAALgAFFAMJAwAAAA==.',
['雪洛']='雪洛洛:BAAALgAECgYJBgAAAA==.',
['雪花']='雪花勇闯天涯:BAAALgAFFAIJBAAAAA==.雪花纯生:BAABLgAFFH8GAAIGAAIJrgS/IABxAAAGAAIJrgS/IABxAAAAAA==.',
['雾切']='雾切:BAABLgAFFH8JAAMXAAYJsRVRAAAAAgAXAAYJsRVRAAAAAgAEAAEJAAAcIgAAAAAAAA==.',
['霉变']='霉变的木头:BAABLgAECn8ZAAMCAAYJ2BoxJgDgAQACAAYJ2BoxJgDgAQAMAAYJkh6mKwDeAQABLgAECgcJIQAKALkiAA==.',
['霉霉']='霉霉的大聪明:BAAALgAECgIJAwAAAA==.',
['霸气']='霸气橙子:BAAALgADCgEJAQAAAA==.',
['静灵']='静灵:BAAALgAECgYJEQAAAA==.',
['非法']='非法:BAAALgAECgcJBwAAAA==.',
['韭菜']='韭菜丨發財:BAABLgAECn8fAAILAAgJDRzOEQCEAgALAAgJDRzOEQCEAgAAAA==.',
['领主']='领主波波:BAAALgAECgEJAQAAAA==.',
['风导']='风导星歌:BAAALgAFFAIJAgAAAA==.',
['风暴']='风暴烈酒:BAAALgAECgEJAQAAAA==.',
['飞云']='飞云的骑士:BAAALgAECgMJBAABLgAECgUJBwAFAAAAAA==.',
['飞奔']='飞奔的小钻风:BAAALgAECgcJDQAAAA==.',
['飞翔']='飞翔的萨满:BAABLgAFFH8GAAICAAIJZRr9EwCtAAACAAIJZRr9EwCtAAAAAA==.',
['饭哆']='饭哆嘻:BAAALgAECggJEAAAAA==.',
['高坂']='高坂桐乃:BAAALgAECgEJAQAAAA==.',
['魂语']='魂语者阿卡德:BAAALgAECgEJAQAAAA==.',
['魔力']='魔力强:BAAALgAECgEJAQAAAA==.',
['魔化']='魔化炎狱核心:BAAALgADCgEJAQAAAA==.',
['魔域']='魔域伊利:BAAALgAECgMJAwAAAA==.',
['鲱鱼']='鲱鱼罐头熬粥:BAAALgADCgcJDQAAAA==.',
['鸡冠']='鸡冠頭:BAAALgADCgEJAQAAAA==.',
['鹅摸']='鹅摸列首:BAAALgAECgYJCwAAAA==.',
['麦麦']='麦麦射:BAAALgAECgQJBAAAAA==.',
['麻酱']='麻酱豆花:BAAALgAECgEJAQAAAA==.',
['麻醬']='麻醬:BAAALgAECgcJEwAAAA==.',
['黄宗']='黄宗泽:BAABLgAFFH8FAAIKAAUJohMQBwBoAQAKAAUJohMQBwBoAQAAAA==.',
['黄河']='黄河救生圈:BAABLgAECn8eAAIKAAgJlxnjPwB5AgAKAAgJlxnjPwB5AgAAAA==.',
['黑蚊']='黑蚊子多:BAAALgAECggJDgAAAA==.',
['黑角']='黑角许褚:BAAALgAECgYJCAAAAA==.',
['黒炎']='黒炎弾:BAACLgAFFH8IAAITAAMJNxksHQAQAQATAAMJNxksHQAQAQAuAAQKfyMAAhMACQnBIsoLABwDABMACQnBIsoLABwDAAAA.',
['黛比']='黛比克拉拉:BAAALgAECgkJCgAAAA==.',
['龍牌']='龍牌酱油:BAAALgAECgUJBgAAAA==.',
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
