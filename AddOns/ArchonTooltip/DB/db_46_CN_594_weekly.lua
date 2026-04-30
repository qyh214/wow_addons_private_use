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

local lookup = {'Unknown-Unknown','Mage-Frost','Priest-Holy','Warrior-Protection','Shaman-Restoration','Monk-Brewmaster','Monk-Windwalker','DeathKnight-Unholy','DeathKnight-Blood','Druid-Balance','Priest-Discipline','Druid-Restoration','Druid-Feral','Druid-Guardian','DemonHunter-Devourer','DemonHunter-Havoc','Rogue-Subtlety','Warrior-Fury','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Demonology','Hunter-Survival','Paladin-Holy','Shaman-Elemental','Priest-Shadow',}
local provider = {region='CN',realm='加里索斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Av='Avmoo:BAAALgAECgMJBAAAAA==.',
Br='Breadx:BAAALgAECgYJCgABLgAFFAIJAwABAAAAAA==.Brrxx:BAAALgADCgEJAQAAAA==.',
Ct='Ctnnmkjg:BAAALgAECgUJBQAAAA==.',
Da='Dandanruirui:BAAALgAFFAIJAwAAAA==.Danevoker:BAAALgAECgEJAQAAAA==.Danmage:BAAALgAECgYJBgAAAA==.',
De='Deepseek:BAAALgAECgEJAgAAAA==.',
Di='Diebin:BAAALgAECgYJBgAAAA==.',
Dr='Drow:BAAALgAECgYJDQAAAA==.',
Em='Emilnem:BAAALgADCgQJBAAAAA==.',
Er='Erebus:BAAALgAFFAEJAQAAAA==.',
Fo='Fordancing:BAAALgAECgUJBQAAAA==.',
Fv='Fvinna:BAAALgAECgQJBQAAAA==.',
He='Headshoot:BAAALgAFFAMJBAAAAA==.',
Il='Ilindays:BAAALgAECgYJDQAAAA==.',
Kl='Kloke:BAAALgAECgEJAQAAAA==.',
Ky='Kykiske:BAAALgAECgcJCAAAAA==.',
Lo='Lottoty:BAAALgAECgQJCAAAAA==.',
No='Nosferatu:BAABLgAECn8VAAICAAcJgR7AbAD8AQACAAcJgR7AbAD8AQABLgAFFAQJBAABAAAAAA==.',
Ra='Radios:BAAALgADCgUJBQAAAA==.',
Ru='Rushman:BAAALgADCgYJBgAAAA==.',
Sa='Saerdnalolz:BAAALgAFFAIJBAAAAA==.',
Si='Sixth:BAAALgAECgcJBwAAAA==.',
Sl='Sloodhound:BAAALgAECgYJBgAAAA==.',
Tw='Twitch:BAAALgAECgUJCAAAAA==.',
Wo='Wobat:BAAALgADCgIJAgAAAA==.',
Xx='Xxiaosm:BAAALgAECgIJAgAAAA==.',
Ya='Yaqovo:BAAALgAECgUJCAAAAA==.',
Ze='Zeus:BAAALgAECgEJAQAAAA==.',
Zh='Zhixuan:BAAALgAFFAEJAQAAAA==.',
Zo='Zovi:BAAALgAFFAIJAgAAAA==.',
['一凌']='一凌一:BAAALgADCgcJDQAAAA==.',
['一只']='一只小德:BAAALgAFFAIJBAAAAA==.一只没有眼睛:BAAALgAFFAQJBAAAAA==.',
['一妖']='一妖月一:BAAALgAECgUJBQAAAA==.',
['一生']='一生所愛:BAAALgAECgEJAQAAAA==.',
['一翼']='一翼雨一:BAAALgAECgMJAwAAAA==.',
['七宝']='七宝宝欺七七:BAABLgAFFH8VAAIDAAUJBScJAABJAgADAAUJBScJAABJAgAAAA==.',
['上上']='上上谦:BAAALgADCgMJAwAAAA==.',
['上官']='上官慕容:BAABLgAFFH8FAAIEAAIJ6ASwEQA1AAAEAAIJ6ASwEQA1AAAAAA==.',
['上帝']='上帝的依恋:BAAALgADCgEJAQAAAA==.',
['不死']='不死变异者:BAAALgAECgYJCwAAAA==.',
['不要']='不要虚就是干:BAAALgAECgMJBAAAAA==.',
['专业']='专业卤鸡蛋:BAAALgAECgYJCwAAAA==.',
['专奶']='专奶勇哥:BAAALgAECgEJAQAAAA==.',
['专猎']='专猎伊宝宝:BAAALgAECgEJAQAAAA==.',
['丛林']='丛林独舞:BAAALgADCgcJBwAAAA==.',
['东门']='东门外狼外婆:BAAALgAECgcJDQAAAA==.',
['丨小']='丨小丶小得:BAAALgAECgQJBAAAAA==.',
['中璍']='中璍美德:BAAALgAECgEJAQAAAA==.',
['丶不']='丶不如吃咸菜:BAAALgAECgEJAQAAAA==.',
['丶尐']='丶尐布点丶:BAAALgAFFAIJAgAAAA==.',
['丶猛']='丶猛虎嗅蔷薇:BAAALgAECgcJCQAAAA==.',
['丶霜']='丶霜刃冰迪凯:BAAALgAECgQJBAAAAA==.',
['乂穆']='乂穆唯屁:BAAALgADCgYJCAAAAA==.',
['乄勺']='乄勺滇滇乄:BAAALgAECgEJAQAAAA==.',
['乄野']='乄野路子乄:BAAALgAECgQJBAAAAA==.',
['二队']='二队牧丝:BAAALgAECgEJAQAAAA==.',
['亚瑟']='亚瑟王一世:BAAALgAECgIJAgAAAA==.亚瑟王三世:BAAALgAECgIJAgAAAA==.亚瑟王二世:BAAALgAECgQJBAAAAA==.',
['亦轩']='亦轩:BAAALgAFFAQJBAAAAA==.',
['亲爸']='亲爸爸:BAABLgAFFH8KAAIFAAQJyBLhBAAgAQAFAAQJyBLhBAAgAQAAAA==.',
['从此']='从此不缺德:BAAALgADCgMJBgAAAA==.',
['他们']='他们喊我小贝:BAAALgAECgUJBQAAAA==.',
['他喵']='他喵的忧伤:BAAALgADCgMJAwAAAA==.',
['会喷']='会喷火的熊:BAABLgAECn8ZAAMGAAgJKBpDFQBhAgAGAAgJHRpDFQBhAgAHAAcJMgbZPQAjAQABLgAFFAcJBAABAAAAAA==.',
['会灵']='会灵打的熊:BAABLgAFFH8JAAMIAAQJZSDBLwDUAAAIAAMJZSDBLwDUAAAJAAEJAAA/EgBgAAAAAA==.',
['会长']='会长爱人:BAAALgADCgIJAgAAAA==.',
['俺不']='俺不是小德:BAAALgAECgEJAgAAAA==.',
['倍儿']='倍儿特么棒:BAAALgAECgYJDgAAAA==.',
['倩女']='倩女幽会:BAAALgAECgIJAgAAAA==.',
['光之']='光之信标:BAAALgAECgMJBAAAAA==.',
['光头']='光头李二爽:BAAALgAECgYJCgAAAA==.',
['兔踏']='兔踏千里:BAAALgAECgEJAQAAAA==.',
['其实']='其实也没:BAAALgADCgIJAgAAAA==.其实我是兔兔:BAAALgAECgEJAQAAAA==.',
['再无']='再无胡豆熊:BAAALgAECgEJAQAAAA==.',
['再说']='再说一遍:BAAALgAECgUJBQAAAA==.',
['冰丶']='冰丶美式:BAAALgAECgUJBQAAAA==.',
['冰棍']='冰棍猫儿:BAAALgAECgEJAQAAAA==.',
['冲出']='冲出去就狗带:BAAALgADCgEJAQAAAA==.',
['冷泠']='冷泠霜:BAAALgAECgYJDgAAAA==.',
['凌丨']='凌丨冰:BAAALgAECgEJAQAAAA==.',
['凤舞']='凤舞一夕:BAAALgAECgEJAQAAAA==.',
['凶兔']='凶兔:BAAALgAECgQJBQAAAA==.',
['划水']='划水的:BAAALgADCgEJAgAAAA==.',
['刨冰']='刨冰机:BAAALgAECgQJBAAAAA==.',
['利刃']='利刃的主宰:BAAALgAECgYJDAAAAA==.',
['别的']='别的熊没我纯:BAAALgAECgcJBgAAAA==.',
['功夫']='功夫老肥猫:BAAALgAECgUJBQAAAA==.',
['努力']='努力奋斗丶:BAAALgAECgEJAQAAAA==.',
['包蓉']='包蓉兴灬:BAAALgAECgYJBgAAAA==.',
['十八']='十八号:BAAALgAFFAIJAwAAAA==.',
['千斤']='千斤:BAAALgAECgIJAwAAAA==.',
['卄玖']='卄玖丶:BAAALgAECgMJAwAAAA==.',
['卅玖']='卅玖:BAAALgADCgMJAwAAAA==.',
['单眼']='单眼皮鱼儿:BAAALgAECgYJCQAAAA==.',
['南宫']='南宫一心:BAAALgAFFAEJAQAAAA==.',
['双魚']='双魚理:BAABLgAFFH8JAAICAAUJYxU5DAC7AQACAAUJYxU5DAC7AQABLgAFFAYJCwACAMUbAA==.',
['古德']='古德猫腻:BAAALgAECgcJBwABLgAECgcJCgABAAAAAA==.',
['咋了']='咋了啊:BAAALgAECgEJAQAAAA==.',
['哈基']='哈基龙:BAAALgAECgYJEwABLgAECggJHwAKAM8jAA==.',
['哑巴']='哑巴:BAAALgAECgcJDAAAAA==.',
['哪呢']='哪呢:BAAALgAECgYJCQAAAA==.',
['商鞅']='商鞅知马力:BAAALgAECgQJBwAAAA==.',
['啵啵']='啵啵爱捣蛋:BAAALgAECgEJAgAAAA==.',
['喵喵']='喵喵咪哈:BAAALgAECgUJCgAAAA==.',
['嗜血']='嗜血嫣然:BAEALgAECgQJBgAAAA==.',
['嘻丶']='嘻丶嘻嘻:BAAALgAFFAIJAgAAAA==.',
['回味']='回味丶那伤痛:BAAALgAECgYJCgAAAA==.',
['圣光']='圣光大侠:BAAALgADCgIJAgAAAA==.圣光督军:BAAALgAECgcJDgAAAA==.',
['地圆']='地圆说创始人:BAAALgAECgQJCAAAAA==.',
['基拉']='基拉祈:BAAALgAECggJBwAAAA==.',
['堕落']='堕落灬摩羯座:BAAALgAFFAQJBAAAAA==.',
['塔拉']='塔拉夏丶:BAAALgAECgQJBQAAAA==.',
['壁立']='壁立千韧:BAAALgADCggJCAAAAA==.',
['壮烈']='壮烈成仁:BAAALgADCgIJAgAAAA==.',
['夏天']='夏天冰西瓜:BAAALgADCgUJBQAAAA==.',
['夏姆']='夏姆榭尔:BAAALgAECgcJDQAAAA==.',
['夜已']='夜已凄凉:BAAALgAECgIJAwAAAA==.',
['夜樱']='夜樱:BAAALgAECgEJAQAAAA==.',
['夜王']='夜王:BAAALgAFFAIJAwAAAA==.',
['夜阑']='夜阑风雨:BAAALgAECgIJAgAAAA==.',
['大中']='大中至正:BAAALgADCgEJAQAAAA==.',
['大丶']='大丶爷:BAAALgAECgIJAgAAAA==.',
['大了']='大了个寂寞:BAAALgAECgEJAQAAAA==.',
['大哥']='大哥真帅:BAAALgADCgMJAwAAAA==.',
['大朗']='大朗喝药:BAAALgAECgIJAgAAAA==.',
['大白']='大白灬:BAAALgAECgkJDgABLgAFFAUJDQALABAfAA==.',
['天上']='天上月:BAABLgAECn8VAAIGAAYJIyK7FwBIAgAGAAYJIyK7FwBIAgAAAA==.',
['天使']='天使灬之拳:BAAALgAECgEJAgAAAA==.天使灬之炎:BAAALgAECgEJAQAAAA==.天使灬之辉:BAAALgAECgEJAQAAAA==.',
['天地']='天地有雪:BAAALgADCgIJAgAAAA==.',
['天星']='天星棱光:BAAALgAECgcJDAAAAA==.',
['奥黛']='奥黛丽账本:BAAALgADCgEJAQAAAA==.',
['好大']='好大一只橘子:BAAALgAECgQJBAAAAA==.',
['妄夜']='妄夜的星星:BAAALgAECgIJAgAAAA==.',
['妄春']='妄春山:BAAALgAFFAIJAgAAAA==.',
['妖妖']='妖妖玖:BAAALgAECgEJAQAAAA==.',
['威瑞']='威瑞奈斯:BAAALgADCgEJAQAAAA==.',
['嫒橹']='嫒橹蒽:BAAALgAECgEJAQAAAA==.',
['宝批']='宝批珑:BAAALgAECgIJAgAAAA==.',
['室户']='室户堇:BAAALgADCgYJBgAAAA==.',
['小乔']='小乔:BAAALgAECgEJAQAAAA==.',
['小店']='小店大厨:BAAALgAECgMJBAAAAA==.',
['小慕']='小慕丶:BAAALgAFFAMJBAABLgAFFAUJCwAMAFUPAA==.',
['小毛']='小毛兔星冰乐:BAAALgAECgEJAQAAAA==.',
['小生']='小生半佛半仙:BAAALgAECgEJAQAAAA==.小生过于自谦:BAAALgAECgIJAgAAAA==.',
['小苹']='小苹果动物园:BAACLgAFFH8LAAINAAQJ2CSwAAC2AQANAAQJ2CSwAAC2AQAuAAQKfxoAAw0ACQnHJJ0AAKYDAA0ACQlEJJ0AAKYDAA4AAQnfF4MrAEoAAAAA.小苹果敲钟人:BAAALgAFFAQJBAAAAA==.',
['小辫']='小辫子:BAAALgAECgYJDQAAAA==.',
['小闪']='小闪电最强:BAAALgAECgEJAQAAAA==.',
['小魔']='小魔女幂柔:BAAALgAECgcJBgAAAA==.',
['小鹿']='小鹿爷:BAAALgAECgIJAgAAAA==.',
['屁糊']='屁糊:BAAALgADCgMJAwAAAA==.',
['崔开']='崔开花:BAAALgAECgEJAQAAAA==.',
['巜巜']='巜巜巛巛:BAACLgAFFH8GAAMDAAMJXBkxCwCwAAADAAIJ6R0xCwCwAAALAAIJPgq6FACQAAAuAAQKfxoAAwMABwkQF1woAK0BAAMABwl9FFwoAK0BAAsABQlHD8wyAAsBAAAA.',
['巧克']='巧克力布玛:BAAALgADCgYJBgAAAA==.',
['巴巴']='巴巴妈妈:BAABLgAECn8YAAIGAAgJLBIsJgDTAQAGAAgJLBIsJgDTAQAAAA==.',
['市丸']='市丸影:BAAALgAECgUJCQABLgAECgYJFgAIACMcAA==.',
['干涸']='干涸的春:BAAALgAECgcJEwAAAA==.',
['幸福']='幸福的追问:BAAALgAECgEJAQAAAA==.',
['幻影']='幻影米莉娅:BAAALgAECgMJBgAAAA==.',
['康震']='康震天:BAAALgAECgEJAwAAAA==.',
['强强']='强强很忙:BAAALgAECgQJBwAAAA==.',
['强爷']='强爷很忙:BAAALgAECgMJAwAAAA==.',
['心想']='心想是橙:BAAALgAECgIJAgAAAA==.',
['恶魔']='恶魔灬之剑:BAAALgAECgEJAgAAAA==.恶魔灬之舞:BAAALgADCgEJAQAAAA==.',
['悲舒']='悲舒青风:BAABLgAECn8ZAAMPAAgJOBs2DgCaAQAPAAgJzRY2DgCaAQAQAAQJJxxHNAA4AQAAAA==.',
['惊山']='惊山丨鸟:BAAALgAECgMJAwAAAA==.惊山鸟:BAAALgADCgEJAQAAAA==.',
['慕梓']='慕梓礼:BAAALgAECgEJAQAAAA==.',
['我叫']='我叫明月儿:BAABLgAECn8UAAIMAAcJzBNfRwCEAQAMAAcJzBNfRwCEAQAAAA==.',
['我有']='我有名字啦:BAAALgAECgEJAgAAAA==.',
['我欲']='我欲乘風归去:BAAALgAECgMJAwAAAA==.',
['我踏']='我踏月光而来:BAAALgADCgIJAgAAAA==.',
['战斧']='战斧:BAAALgAECgYJEQAAAA==.',
['打不']='打不过就叫人:BAAALgAECgYJBgAAAA==.打不过就摆烂:BAAALgAECgUJBQAAAA==.',
['拉啦']='拉啦僧:BAAALgAECgQJBAAAAA==.',
['拳打']='拳打西门庆:BAAALgAECgEJAQAAAA==.',
['挖沙']='挖沙子的西西:BAAALgAECgYJBgAAAA==.',
['捉猪']='捉猪抓猫:BAAALgAECgQJBQAAAA==.',
['掀起']='掀起你的辫子:BAAALgAFFAEJAQAAAA==.',
['揽月']='揽月风尘:BAAALgAECgEJAQAAAA==.',
['散人']='散人干不死:BAAALgAECgQJBAAAAA==.',
['斗战']='斗战神熊:BAAALgAECgYJEgAAAA==.',
['斯人']='斯人若彩虹丶:BAAALgADCgMJBAAAAA==.',
['无与']='无与伦比的美:BAAALgAECgQJBAAAAA==.',
['无光']='无光夜瞳:BAAALgAECgQJBAAAAA==.',
['无敌']='无敌大大哒哒:BAAALgAECgIJAgAAAA==.无敌纯爱男神:BAAALgAFFAQJBAABLgAFFAQJBQARAB8IAA==.',
['时光']='时光之翼:BAAALgAFFAEJAQAAAA==.',
['时绪']='时绪:BAAALgAECgYJCQAAAA==.',
['明月']='明月照影归灬:BAAALgAECgkJCQAAAA==.',
['星挽']='星挽:BAAALgAECgEJAwAAAA==.',
['星术']='星术师:BAAALgAFFAEJAQAAAA==.',
['星辰']='星辰涙:BAABLgAFFH8GAAIDAAMJMA2SCADfAAADAAMJMA2SCADfAAAAAA==.',
['春城']='春城之僧:BAAALgADCgEJAQAAAA==.春城教父:BAAALgAECgcJEgAAAA==.',
['晨峰']='晨峰寒:BAACLgAFFH8PAAIIAAUJeBQaFQBPAQAIAAUJeBQaFQBPAQAuAAQKfxwAAggABwnMJD0gAMACAAgABwnMJD0gAMACAAAA.',
['暗之']='暗之黄泉:BAAALgAECgYJCgAAAA==.',
['暴走']='暴走野人:BAAALgAECgcJBwAAAA==.',
['暴躁']='暴躁小辣椒:BAAALgAECgUJBgAAAA==.',
['最后']='最后的礼物:BAAALgAECgQJBwAAAA==.',
['最爱']='最爱无敌牛:BAAALgAECgEJAQAAAA==.',
['月下']='月下风流:BAAALgAECgUJBgAAAA==.',
['月之']='月之黑夜:BAAALgADCgMJAwAAAA==.',
['月光']='月光熊猫:BAAALgAECgYJCQAAAA==.',
['月咏']='月咏:BAAALgADCgQJBAAAAA==.',
['月影']='月影白沙:BAAALgAECgYJBwAAAA==.',
['月魂']='月魂星眸:BAAALgAECgEJAQAAAA==.',
['有這']='有這麽一個人:BAABLgAECn8WAAMEAAYJ0BGlIgApAQAEAAYJ0BGlIgApAQASAAEJUAmJrQAvAAAAAA==.',
['朱颜']='朱颜白骨:BAAALgADCgcJBwAAAA==.',
['朴国']='朴国昌:BAAALgAECgEJAQAAAA==.',
['李秀']='李秀芹之秀:BAAALgAECgEJAQAAAA==.',
['来我']='来我跟你讲:BAAALgAECgEJAQAAAA==.',
['枯木']='枯木逢春:BAAALgAFFAIJAgAAAA==.',
['柠檬']='柠檬冰:BAAALgAECgEJAwAAAA==.',
['桃丶']='桃丶蘇大粉丝:BAAALgADCgEJAQAAAA==.',
['桃气']='桃气十足:BAAALgAECgUJBwAAAA==.',
['桥本']='桥本环菜菜:BAAALgADCgMJAwAAAA==.',
['桶子']='桶子:BAAALgAECgMJAwAAAA==.',
['棋楠']='棋楠:BAAALgAECgMJAwAAAA==.',
['歪比']='歪比吧布:BAAALgAECgEJAQAAAA==.',
['毁容']='毁容后的帅哥:BAAALgAECgIJAgAAAA==.',
['比恩']='比恩海灵顿:BAAALgADCgIJAgAAAA==.',
['永恒']='永恒之续:BAAALgAECgYJBQAAAA==.',
['氺果']='氺果糖:BAAALgAECgEJAQAAAA==.',
['江東']='江東:BAAALgAECgcJDQAAAA==.',
['沁雪']='沁雪纷飞:BAAALgADCgUJBQAAAA==.',
['沉黙']='沉黙的屠夫:BAAALgADCgEJAQAAAA==.',
['沐瑾']='沐瑾花:BAAALgADCgEJAQAAAA==.',
['沐诗']='沐诗:BAAALgAECgYJBwAAAA==.',
['沙是']='沙是比亚:BAAALgAECgEJAQAAAA==.',
['沙若']='沙若雨裳:BAAALgAECgEJAQAAAA==.',
['没有']='没有云的天空:BAAALgAECgEJAQAAAA==.',
['法制']='法制世界:BAAALgAECgYJCwAAAA==.',
['法力']='法力残渣:BAAALgAECgcJBwABLgAFFAUJEAACAJURAA==.',
['泡泡']='泡泡茶湖:BAAALgAECgYJBgAAAA==.',
['泰丶']='泰丶兰德:BAAALgAFFAEJAQAAAA==.',
['泰瑞']='泰瑞昻:BAAALgAFFAEJAQAAAA==.',
['流云']='流云如水:BAAALgAECgUJDAAAAA==.',
['浅唱']='浅唱灬:BAAALgAECgEJAQAAAA==.浅唱灬悲伤:BAAALgAECgMJAwAAAA==.',
['浦东']='浦东吴彦祖丶:BAAALgAECgEJAQAAAA==.',
['海蓝']='海蓝时见鲸:BAAALgAFFAIJAgAAAA==.',
['清梦']='清梦压星河:BAAALgAECgMJBQAAAA==.',
['清酒']='清酒同学:BAAALgAECgcJCgAAAA==.',
['温博']='温博萨:BAAALgAECgMJAwAAAA==.',
['演武']='演武坪买醉:BAAALgAECgUJBQAAAA==.',
['灬何']='灬何以为战灬:BAAALgADCgYJBQAAAA==.',
['灬帕']='灬帕西瓦尔灬:BAAALgAECgQJBQAAAA==.',
['灬星']='灬星球灬:BAAALgAECgQJBwAAAA==.',
['灾变']='灾变归来:BAAALgAECgUJBQAAAA==.',
['烂烂']='烂烂兰番茄:BAAALgAECgEJAQAAAA==.',
['無魚']='無魚灵灵:BAAALgAECgUJBQAAAA==.',
['熊喵']='熊喵达达:BAAALgAFFAIJAgAAAA==.',
['爷爷']='爷爷:BAAALgADCgEJAQAAAA==.',
['牧施']='牧施:BAAALgAECgcJCQAAAA==.',
['牧菲']='牧菲菲:BAAALgAECgcJEwAAAA==.',
['狂嗦']='狂嗦纳垢玉足:BAAALgAECgMJAwAAAA==.',
['狂暴']='狂暴痞子:BAAALgADCgkJCQAAAA==.',
['猎手']='猎手老猫:BAAALgAECgMJAwAAAA==.',
['猪猪']='猪猪包:BAAALgADCgEJAQAAAA==.',
['王语']='王语琦:BAACLgAFFH8NAAITAAQJvBtnCQBiAQATAAQJvBtnCQBiAQAuAAQKfxQAAhMABwlrH74yAFcCABMABwlrH74yAFcCAAAA.',
['玖玖']='玖玖月:BAAALgADCgQJBAAAAA==.',
['玩情']='玩情丧心:BAAALgAECgcJBwAAAA==.',
['玲小']='玲小猎:BAAALgAECgYJDgAAAA==.',
['珍中']='珍中梦:BAAALgAECgEJAQAAAA==.',
['珍龙']='珍龙:BAABLgAFFH8GAAIMAAIJmx6AFQC3AAAMAAIJmx6AFQC3AAAAAA==.',
['珠芯']='珠芯:BAAALgAECgEJAQAAAA==.',
['琺爺']='琺爺:BAAALgADCgQJBAAAAA==.',
['璇月']='璇月寒星:BAAALgAECgEJAQAAAA==.',
['瓦娜']='瓦娜斯逐风:BAAALgAECgUJDAAAAA==.',
['瓦里']='瓦里基尔:BAAALgAFFAEJAgAAAA==.',
['男上']='男上加男:BAAALgAECgUJBQAAAA==.',
['略略']='略略勒:BAAALgAECgEJAQAAAA==.略略勒略:BAAALgAECgEJAQAAAA==.',
['畫沙']='畫沙:BAAALgAECgEJAQAAAA==.',
['白丶']='白丶桑:BAABLgAFFH8OAAMUAAYJixLYCAAbAQAVAAUJ6AkzCgB1AQAUAAMJdRvYCAAbAQAAAA==.',
['白酒']='白酒归唻:BAAALgAECgYJCwAAAA==.白酒归涞:BAAALgAECgEJAQAAAA==.',
['百变']='百变黑人:BAAALgAECgQJBAAAAA==.',
['皎月']='皎月:BAAALgAECgYJEQAAAA==.',
['盖世']='盖世软糖:BAAALgAECgEJAQAAAA==.',
['真心']='真心人:BAAALgAFFAEJAQAAAA==.',
['真红']='真红稻妻:BAAALgAECgMJAwAAAA==.',
['睡犬']='睡犬:BAAALgAECgIJAgAAAA==.',
['睿秀']='睿秀:BAABLgAFFH8FAAIFAAMJmiIREwDIAAAFAAMJmiIREwDIAAAAAA==.',
['破晓']='破晓:BAAALgAECgYJDAAAAA==.',
['硬汉']='硬汉一号:BAAALgAECgEJAQAAAA==.硬汉月影:BAAALgAECgEJAQAAAA==.',
['神隱']='神隱人间丷:BAAALgAECgcJBwAAAA==.神隱的貓丷:BAAALgAECgcJBwAAAA==.',
['神龙']='神龙魔女:BAAALgAECgYJBwAAAA==.',
['祢豆']='祢豆籽:BAAALgAECgYJCgAAAA==.',
['秋旻']='秋旻:BAAALgAECggJCQAAAA==.',
['稚硕']='稚硕:BAAALgAECgUJBQAAAA==.稚硕等等:BAAALgAECgUJBQAAAA==.',
['空手']='空手接白刃:BAAALgAECgIJAgAAAA==.',
['筱霏']='筱霏妩:BAAALgAECgQJBAABLgAFFAUJBQAIADIKAA==.',
['箭无']='箭无虚发:BAAALgADCgEJAQAAAA==.',
['米克']='米克罗:BAAALgAECgEJAQAAAA==.',
['粉口']='粉口爱的老鼠:BAAALgAECgkJAwABLgAFFAYJCgAFAHYKAA==.',
['粪不']='粪不固身:BAAALgADCgUJBQAAAA==.',
['精华']='精华破碎丶:BAAALgAFFAEJAQABLgAFFAQJBAABAAAAAA==.',
['糖门']='糖门爹:BAAALgAECgEJAgAAAA==.',
['素素']='素素树:BAAALgAECgkJBgABLgAFFAcJBwAWANgSAA==.',
['紫色']='紫色飘絮:BAAALgADCgYJBQAAAA==.',
['紫轩']='紫轩澜竹:BAAALgAECgYJBgAAAA==.',
['繁丨']='繁丨星:BAAALgAECgEJAQAAAA==.',
['红豆']='红豆在哪:BAAALgAECgYJCAAAAA==.红豆汤:BAAALgADCgEJAQAAAA==.',
['红青']='红青春:BAABLgAECn8ZAAIIAAcJ1yK5HgDIAgAIAAcJ1yK5HgDIAgAAAA==.',
['纳西']='纳西妲:BAAALgAECgYJEQAAAA==.',
['细俵']='细俵酱:BAAALgAFFAQJBAAAAA==.',
['绿川']='绿川花:BAACLgAFFH8RAAMUAAUJXyEiAAAAAgAUAAUJXyEiAAAAAgAXAAIJDAl5BQCmAAAuAAQKfxQABBQACQmgGKciADYCABQACAmfGqciADYCABUAAQnOBD6VACQAABcAAgleDwAAAAAAAAAA.',
['缥缈']='缥缈的寸头:BAAALgAFFAEJAQAAAA==.',
['缺德']='缺德吗:BAAALgAECgQJBAAAAA==.',
['老娘']='老娘的大炮:BAAALgAFFAIJAgAAAA==.',
['老酋']='老酋长:BAAALgAECgIJAgAAAA==.',
['聖灮']='聖灮薙刃:BAAALgAECgEJAgAAAA==.',
['肤凉']='肤凉情薄:BAAALgAECgEJAQAAAA==.',
['肥嘟']='肥嘟嘟小鲁伊:BAAALgAECgcJDwAAAA==.肥嘟嘟馋嘴猫:BAAALgAECgcJDwAAAA==.',
['胜魔']='胜魔:BAAALgADCgEJAQAAAA==.',
['致命']='致命旳毐藥:BAAALgAECgQJBAAAAA==.',
['艾尔']='艾尔海森:BAAALgAECgMJAwAAAA==.',
['艾斯']='艾斯戴泰戈:BAAALgADCgMJAwAAAA==.',
['花生']='花生牛戈糖:BAAALgAFFAIJAgAAAA==.',
['花落']='花落待君临:BAAALgADCgYJBgAAAA==.',
['荆棘']='荆棘谷的山:BAAALgAECgYJDQAAAA==.',
['莜雨']='莜雨玲:BAAALgADCgQJBAAAAA==.',
['莞式']='莞式引怪:BAAALgAECgYJCQAAAA==.莞式抗怪:BAAALgAECgIJBAAAAA==.',
['莫邪']='莫邪不邪:BAAALgADCgIJAgAAAA==.',
['莱加']='莱加西:BAAALgAECgMJAwAAAA==.',
['萌萌']='萌萌哒兔子:BAAALgADCgEJAQAAAA==.',
['萝卜']='萝卜萝卜丶:BAAALgAECgcJDgABLgAFFAUJBAABAAAAAA==.',
['葛温']='葛温:BAAALgADCgUJBQAAAA==.',
['蕾鳞']='蕾鳞:BAAALgAECgEJAQAAAA==.',
['藥丸']='藥丸兒:BAAALgAECgYJCQAAAA==.',
['藥媚']='藥媚兒:BAAALgAECgYJBgAAAA==.',
['虎假']='虎假狐威:BAAALgADCgQJBAAAAA==.',
['虚空']='虚空领主:BAAALgADCgkJDwAAAA==.',
['蟑螂']='蟑螂阿强:BAAALgAECgcJBwAAAA==.',
['血月']='血月大鼻子:BAAALgADCgUJBQAAAA==.',
['血腥']='血腥大河马:BAAALgADCgEJAQAAAA==.',
['血龙']='血龙圣骑:BAAALgAECgQJBAAAAA==.',
['衣架']='衣架的跟班:BAAALgAFFAIJBAAAAA==.',
['詮释']='詮释爧:BAAALgAECgEJAgAAAA==.',
['詮釋']='詮釋靈:BAAALgAECgUJBQAAAA==.',
['誓去']='誓去的永远:BAAALgAECgkJDgAAAA==.',
['证道']='证道菩提:BAAALgAECgkJDgAAAA==.',
['说了']='说了不切奶:BAAALgADCgcJCAAAAA==.',
['诺莉']='诺莉斯:BAABLgAFFH8GAAIIAAIJ6B82FgCuAAAIAAIJ6B82FgCuAAAAAA==.',
['赛娜']='赛娜斯:BAAALgAECgEJAQAAAA==.',
['超级']='超级玛丽难兄:BAAALgAECgYJCQAAAA==.',
['足以']='足以慰风尘:BAAALgAECgQJBQAAAA==.',
['跌落']='跌落尘埃丶:BAACLgAFFH8JAAICAAQJMCD7DwCWAQACAAQJMCD7DwCWAQAuAAQKfxsAAgIACAmWIRUnANYCAAIACAmWIRUnANYCAAAA.',
['路人']='路人张:BAAALgAFFAIJAwAAAA==.',
['车南']='车南的沙丁鱼:BAACLgAFFH8PAAIMAAQJRRTECQA6AQAMAAQJRRTECQA6AQAuAAQKfxkAAgwABwnHGeUqAAUCAAwABwnHGeUqAAUCAAAA.',
['远航']='远航星:BAAALgAECgEJAQAAAA==.',
['逢春']='逢春:BAAALgADCgYJBgAAAA==.',
['遗淚']='遗淚棄噯:BAAALgAECgUJBQAAAA==.',
['邦邦']='邦邦:BAAALgAECgEJAQAAAA==.',
['邪刃']='邪刃:BAAALgAECgYJDAAAAA==.',
['邪恶']='邪恶的丹丹:BAAALgAECgIJAgAAAA==.',
['邪瞳']='邪瞳灬:BAAALgAECgYJCgAAAA==.',
['鄧丶']='鄧丶小胖:BAAALgAFFAIJAwAAAA==.',
['酒神']='酒神复归:BAABLgAECn8WAAIIAAcJ2wyMqQAuAQAIAAcJ2wyMqQAuAQAAAA==.酒神归来:BAAALgAECgYJBgAAAA==.',
['醉后']='醉后:BAAALgAFFAEJAQAAAA==.',
['野生']='野生小动物:BAAALgAECgIJAwAAAA==.',
['金色']='金色圣光:BAAALgADCgYJCwAAAA==.',
['钙世']='钙世嘤熊:BAAALgADCgQJBAAAAA==.',
['钩子']='钩子上有血:BAAALgADCgYJCgAAAA==.',
['铁头']='铁头阿童木:BAAALgADCgQJBAAAAA==.',
['银鞍']='银鞍照白马丶:BAAALgAECgMJAgAAAA==.',
['销魂']='销魂匕:BAAALgADCgEJAQAAAA==.',
['长崎']='长崎素世:BAAALgAFFAMJBAAAAA==.',
['长河']='长河落日:BAAALgAECgYJCgAAAA==.',
['阿斯']='阿斯普洛斯:BAACLgAFFH8LAAICAAMJqRNiKQAPAQACAAMJqRNiKQAPAQAuAAQKfxgAAgIABgkRIRVkABECAAIABgkRIRVkABECAAAA.',
['阿蒙']='阿蒙丶神:BAABLgAFFH8GAAMJAAMJnwa/EQBlAAAIAAIJIwiERwCVAAAJAAIJFgW/EQBlAAAAAA==.',
['雪染']='雪染:BAAALgAECgUJCAAAAA==.',
['雷霆']='雷霆之刃:BAAALgADCgEJAQAAAA==.',
['霜天']='霜天月落:BAAALgAECgIJAgAAAA==.',
['霜鸣']='霜鸣:BAAALgAECgQJBQAAAA==.',
['青蔓']='青蔓白霜:BAAALgAECgQJBAAAAA==.',
['面包']='面包会咬人:BAAALgADCgUJBQAAAA==.',
['順时']='順时针:BAACLgAFFH8FAAIYAAIJOxhCCACsAAAYAAIJOxhCCACsAAAuAAQKfxkAAhgABwlKGU0pAOYBABgABwlKGU0pAOYBAAAA.',
['風之']='風之刃:BAAALgAECgQJBAAAAA==.',
['風輕']='風輕雲淡:BAAALgAECgUJBwAAAA==.',
['风之']='风之刃:BAAALgAECgYJBgAAAA==.',
['风卷']='风卷旧时梦:BAAALgADCgIJAgAAAA==.',
['飒娜']='飒娜依萘:BAAALgADCgEJAQAAAA==.',
['飞箭']='飞箭寻花:BAAALgAECgYJCQAAAA==.',
['食叶']='食叶派教主:BAAALgAFFAEJAQAAAA==.',
['香猪']='香猪:BAABLgAECn8UAAIZAAcJ9RxGGABTAgAZAAcJ9RxGGABTAgAAAA==.香猪壹:BAAALgAECgcJEAAAAA==.',
['高岭']='高岭:BAAALgADCgEJAQAAAA==.',
['高龄']='高龄惨夫:BAAALgAECgYJDQAAAA==.',
['鬼影']='鬼影啼魂:BAAALgAECgcJDQAAAA==.',
['鬼灭']='鬼灭之鹿:BAAALgADCgMJAwAAAA==.',
['魔法']='魔法兔子酱:BAAALgADCgcJBwAAAA==.',
['麥格']='麥格納寒霜:BAAALgADCgQJBAAAAA==.',
['麦克']='麦克华斯基:BAAALgAECgQJCAAAAA==.',
['麻痹']='麻痹丐指丶:BAAALgAFFAQJBAAAAA==.',
['黑峰']='黑峰女皇:BAAALgAFFAEJAQAAAA==.',
['黑白']='黑白熊猫:BAABLgAECn8eAAQaAAgJqxH2CQBQAQAaAAcJZxP2CQBQAQALAAQJjArvPADDAAADAAIJ5RGlagCBAAAAAA==.',
['默光']='默光:BAAALgAECgQJBwAAAA==.',
['黯灭']='黯灭:BAAALgADCgcJCAAAAA==.',
['龙星']='龙星魂:BAAALgAECgcJCwAAAA==.',
['龙虎']='龙虎山大王:BAAALgAECgYJCgAAAA==.',
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
