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

local lookup = {'Hunter-BeastMastery','Warrior-Protection','Mage-Frost','Shaman-Elemental','Shaman-Restoration','DeathKnight-Unholy','Monk-Mistweaver','Evoker-Preservation','Warlock-Demonology','DemonHunter-Devourer','Priest-Holy','Priest-Discipline','Warlock-Destruction','Paladin-Retribution','Paladin-Holy','Unknown-Unknown','Druid-Restoration','DemonHunter-Havoc','DeathKnight-Blood','DemonHunter-Vengeance','Warrior-Arms','Monk-Brewmaster',}
local provider = {region='CN',realm='阿拉希',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bu='Butters:BAAALgAECgEJAQAAAA==.',
By='Byaneiu:BAABLgAFFH8FAAIBAAMJXhwhEQDAAAABAAMJXhwhEQDAAAAAAA==.',
Ca='Caliban:BAAALgADCgEJAQAAAA==.',
Co='Coco:BAAALgAECgcJCgAAAA==.',
Do='Doomart:BAAALgAECgYJBgAAAA==.',
Du='Duoduozs:BAABLgAECn8aAAICAAkJayCiAQBrAwACAAkJayCiAQBrAwABLgAFFAUJCQACALUOAA==.',
['Dí']='Dísir:BAAALgAECgEJAgAAAA==.',
Es='Esws:BAAALgAECgYJCQAAAA==.',
Fl='Flingduchman:BAAALgAECgYJDAAAAA==.',
Ge='Gervin:BAAALgAECgYJCQAAAA==.',
He='Hellohades:BAAALgADCgEJAQAAAA==.Hetrshy:BAAALgAFFAEJAQAAAA==.',
Ho='Honeyhoney:BAAALgAECgcJBwAAAA==.',
In='Invincibl:BAAALgADCgYJBgAAAA==.',
Ju='Junge:BAAALgAECgQJAgAAAA==.',
Ly='Lyqssr:BAAALgAFFAIJAgAAAA==.',
Ma='Magemichal:BAABLgAFFH8GAAIDAAMJvxhgJwAVAQADAAMJvxhgJwAVAQAAAA==.Martyrx:BAAALgAFFAIJAwAAAA==.',
Mi='Milltina:BAAALgAECgQJBAAAAA==.Mios:BAABLgAFFH8KAAMEAAMJ6BGfDwD3AAAEAAMJ6BGfDwD3AAAFAAMJIBXxCADrAAAAAA==.Missx:BAAALgAFFAIJAwABLgAFFAIJBgAGALcZAA==.',
Ro='Rocveadeelan:BAABLgAFFH8GAAIHAAMJUxzGCQAVAQAHAAMJUxzGCQAVAQAAAA==.',
Sh='Shylily:BAACLgAFFH8IAAIIAAQJARoACABrAQAIAAQJARoACABrAQAuAAQKfyMAAggACAnUIdQFAOsCAAgACAnUIdQFAOsCAAAA.',
Tg='Tgbag:BAAALgAECgEJAQAAAA==.',
Tr='Treesongss:BAABLgAFFH8GAAIJAAIJDB7PLAC7AAAJAAIJDB7PLAC7AAAAAA==.',
Ve='Velen:BAAALgAECgUJDQAAAA==.',
Wi='Windranger:BAAALgAFFAUJBAAAAA==.',
Wo='Wowaxe:BAAALgAFFAEJAQAAAA==.',
Yi='Yihai:BAAALgAECgEJAQAAAA==.',
['一撕']='一撕就得:BAAALgAECgkJAQAAAA==.',
['一术']='一术神一:BAAALgAECgcJBwAAAA==.',
['三战']='三战神三:BAABLgAFFH8GAAMFAAIJShKgFwCdAAAFAAIJShKgFwCdAAAEAAIJoAkPGACWAAAAAA==.',
['上学']='上学威龙:BAAALgAFFAEJAQAAAA==.',
['上弄']='上弄死它:BAAALgAECgcJDgAAAA==.',
['不懂']='不懂灬装懂:BAAALgAFFAEJAQAAAA==.',
['丨小']='丨小丶智丨:BAAALgADCgEJAQAAAA==.',
['丶番']='丶番茄炖牛腩:BAAALgAECgEJAwAAAA==.',
['乄放']='乄放縱鍀遊蕩:BAAALgAFFAQJBAAAAA==.',
['九尾']='九尾:BAAALgAECgEJAQAAAA==.',
['二零']='二零二六无敌:BAAALgAECgcJDgAAAA==.',
['云心']='云心出岫:BAAALgAECgUJBwAAAA==.',
['井中']='井中月:BAAALgAECgkJCQAAAA==.',
['仲商']='仲商为期:BAAALgAECgcJAQAAAA==.',
['伊莉']='伊莉莎怒风:BAAALgADCgEJAQAAAA==.',
['会放']='会放闪电的牛:BAAALgAECgYJBgAAAA==.',
['你人']='你人还怪好嘞:BAAALgAECgkJCQABLgAFFAUJBQAKAN8aAA==.',
['你的']='你的瞳我的影:BAAALgADCgcJCAAAAA==.',
['依希']='依希斯:BAAALgAECgQJCAAAAA==.',
['倒拔']='倒拔杨柳:BAAALgADCgIJAgAAAA==.',
['傲世']='傲世皇妃:BAAALgAECgYJCAAAAA==.',
['傷别']='傷别灕灬逍遥:BAABLgAFFH8FAAIDAAUJ7hGLCgBeAQADAAUJ7hGLCgBeAQAAAA==.',
['克雷']='克雷斯波:BAAALgAECgYJBgAAAA==.',
['全開']='全開哈拉少:BAAALgAECgEJAQAAAA==.',
['六畜']='六畜兴旺:BAAALgADCgIJAgAAAA==.',
['兮兮']='兮兮丶:BAABLgAFFH8GAAMLAAMJtxLTDQCPAAALAAMJtxLTDQCPAAAMAAEJywU5GgBHAAAAAA==.',
['再次']='再次野性生长:BAAALgAECgMJAwAAAA==.',
['冲你']='冲你丫的:BAAALgAECgcJBwAAAA==.',
['凡之']='凡之圣光:BAAALgADCgQJBQAAAA==.',
['凯撒']='凯撒:BAAALgAECgUJBQAAAA==.',
['剑影']='剑影潇湘:BAACLgAFFH8IAAMMAAQJIBu7BgB0AQAMAAQJIBu7BgB0AQALAAEJwBjMEQBXAAAuAAQKfx4AAwwACAkkI4oDADEDAAwACAkHI4oDADEDAAsABQl4IpsmALgBAAAA.',
['剑雨']='剑雨魂:BAAALgAECgEJAQAAAA==.',
['勘探']='勘探队员:BAAALgAECgQJBAAAAA==.',
['千里']='千里快哉風:BAAALgAECgEJAQAAAA==.',
['千魂']='千魂咆哮:BAAALgAECgEJAQAAAA==.',
['卡瓦']='卡瓦普:BAAALgAECgEJAQAAAA==.',
['印第']='印第安老斑鸠:BAAALgAFFAIJBAAAAA==.',
['口麦']='口麦克老狼口:BAAALgAECgEJAQAAAA==.',
['右岸']='右岸右转:BAAALgAECgYJBwAAAA==.',
['吆喝']='吆喝圣光吧:BAAALgAFFAEJAQAAAA==.',
['听不']='听不懂想婆娘:BAABLgAECn8YAAMJAAcJIhghZgCZAQAJAAYJxBohZgCZAQANAAMJPRCgOgDJAAAAAA==.',
['咕叽']='咕叽咕叽牧:BAAALgAECgYJCwAAAA==.',
['善意']='善意的坏:BAAALgADCgEJAQAAAA==.',
['嗲胖']='嗲胖嗲妹:BAAALgAECgEJAQAAAA==.',
['嘟嘟']='嘟嘟囔囔:BAAALgAECgEJAQAAAA==.',
['国士']='国士丶无双:BAABLgAFFH8LAAIDAAMJkhW3GAD7AAADAAMJkhW3GAD7AAAAAA==.',
['圣光']='圣光蛊:BAAALgAECgEJAQAAAA==.',
['塞壬']='塞壬之泣:BAABLgAFFH8FAAIOAAUJ1wkEBwA+AQAOAAUJ1wkEBwA+AQAAAA==.',
['大西']='大西部铁路:BAAALgAFFAUJBAAAAA==.',
['天天']='天天都想摆烂:BAAALgAECgYJCwAAAA==.',
['天涯']='天涯有蔷薇:BAABLgAFFH8GAAIPAAMJgyTXBABEAQAPAAMJgyTXBABEAQAAAA==.',
['奥丁']='奥丁的盛宴:BAAALgAFFAUJBAAAAA==.',
['好丑']='好丑的男人丶:BAABLgAFFH8FAAIDAAIJ+QTISACdAAADAAIJ+QTISACdAAAAAA==.',
['小幻']='小幻彩:BAAALgAFFAQJBAABLgAFFAUJCQAGAGomAA==.',
['小白']='小白牛:BAAALgAECgQJBAAAAA==.',
['小蜗']='小蜗牛快跑:BAAALgAECgcJCAAAAA==.',
['尛貓']='尛貓洗臉:BAAALgAECgQJBAABLgAECgkJDgAQAAAAAA==.',
['崽崽']='崽崽:BAAALgAECgQJBAAAAA==.',
['川厨']='川厨烧菊:BAAALgAFFAIJAwAAAA==.',
['布洛']='布洛琉斯:BAAALgAECgEJAQAAAA==.',
['希尔']='希尔之殇:BAAALgAECgcJEwAAAA==.',
['帝江']='帝江乄亥猪:BAAALgAECgQJBAAAAA==.',
['强的']='强的阔怕:BAAALgADCgUJBQAAAA==.',
['德里']='德里个德:BAABLgAFFH8GAAIRAAMJKgY7DQC5AAARAAMJKgY7DQC5AAAAAA==.',
['心中']='心中恶魔:BAAALgAFFAIJAwAAAA==.心中的恶魔:BAAALgAECgYJBwAAAA==.',
['思路']='思路的小萨:BAAALgAECgEJAgAAAA==.',
['恐虐']='恐虐丶:BAAALgAECgcJBwAAAA==.',
['恰似']='恰似你的温柔:BAAALgAECgUJBQAAAA==.',
['情深']='情深终化蝶:BAAALgAECgYJCwAAAA==.',
['我不']='我不想玩魔瘦:BAAALgAECgQJBAAAAA==.',
['我在']='我在你左边:BAAALgAECgYJCwAAAA==.',
['我心']='我心丶狂野:BAAALgAECgQJBQAAAA==.',
['我感']='我感觉很蓝瘦:BAAALgADCgEJAQAAAA==.',
['我纯']='我纯故我在:BAAALgAFFAUJAwAAAA==.',
['我胖']='我胖古我壮:BAAALgAECgQJBAAAAA==.',
['我还']='我还行吧:BAAALgADCgIJAgAAAA==.',
['战丷']='战丷天:BAAALgADCgEJAQAAAA==.',
['戴面']='戴面罩看姑娘:BAAALgAECgIJAgAAAA==.',
['戾魅']='戾魅:BAAALgAFFAIJBAAAAA==.',
['救祓']='救祓少女:BAAALgAECggJAwABLgAFFAQJBgASAMsdAA==.',
['斜杠']='斜杠:BAAALgAECgIJAwAAAA==.',
['斩月']='斩月飞花:BAAALgAFFAMJBAAAAA==.',
['无马']='无马之车:BAABLgAFFH8FAAIGAAMJYh6XIgANAQAGAAMJYh6XIgANAQAAAA==.',
['是夜']='是夜丶如此寒:BAAALgADCgUJBQAAAA==.',
['晨晨']='晨晨清颖:BAAALgAECgUJBQAAAA==.',
['智商']='智商欠费:BAAALgAECgcJBwAAAA==.',
['有米']='有米巧妇能吹:BAAALgAECgUJCgAAAA==.',
['朱元']='朱元璋:BAAALgAFFAMJAwAAAA==.',
['朱星']='朱星寒:BAAALgAECgYJEgAAAA==.',
['机油']='机油洗澡:BAABLgAFFH8FAAITAAUJuQTyBQDlAAATAAUJuQTyBQDlAAAAAA==.',
['杀戮']='杀戮幻想曲:BAAALgAECgUJCwAAAA==.',
['杜泽']='杜泽尔:BAAALgADCgUJBQAAAA==.',
['来了']='来了老弟:BAAALgAECgQJBQAAAA==.',
['来碗']='来碗沙冰:BAAALgAFFAEJAQAAAA==.',
['松鼠']='松鼠的松果:BAAALgAECgEJAQAAAA==.',
['枫之']='枫之语:BAAALgAECgYJBgAAAA==.',
['枫弓']='枫弓丶落叶箭:BAAALgADCgMJAwAAAA==.',
['枫钥']='枫钥无边:BAAALgAECgEJAQAAAA==.',
['枭熊']='枭熊:BAAALgAECgEJAQAAAA==.',
['柔木']='柔木头:BAAALgAECgYJBgAAAA==.',
['核子']='核子激荡:BAAALgAFFAUJAgAAAA==.',
['梦魇']='梦魇幻魔:BAACLgAFFH8GAAIDAAIJSBnUNgC8AAADAAIJSBnUNgC8AAAuAAQKfxkAAgMACAnDH5suALcCAAMACAnDH5suALcCAAAA.',
['棋盘']='棋盘山老司机:BAAALgAFFAQJAwAAAA==.',
['比丝']='比丝姬:BAAALgAECgUJCAAAAA==.',
['治疗']='治疗欧踢了:BAAALgAECgMJAwAAAA==.',
['法十']='法十三:BAAALgAECgYJDAAAAA==.',
['泰兰']='泰兰徳:BAAALgAECgQJBAAAAA==.',
['洋葱']='洋葱丶:BAAALgAECgUJDwAAAA==.',
['浮生']='浮生半日闲:BAAALgAECgYJEwAAAA==.',
['海盗']='海盗侯爵:BAAALgAFFAEJAQAAAA==.海盗小男爵:BAAALgAECgIJAgAAAA==.',
['淘气']='淘气依旧:BAAALgAECgQJBQAAAA==.',
['混子']='混子中的疯子:BAAALgAECgIJAgAAAA==.',
['温酒']='温酒煮华雄:BAAALgADCgQJBAAAAA==.',
['湛藍']='湛藍的回憶:BAAALgAECgQJCgAAAA==.',
['火山']='火山听风起:BAAALgAECggJAwAAAA==.',
['灬格']='灬格格萨萨灬:BAAALgADCgYJBgAAAA==.',
['灬游']='灬游走边缘灬:BAAALgAECgMJAwAAAA==.',
['灬灬']='灬灬清風:BAAALgAFFAIJAwAAAA==.',
['灬玛']='灬玛莲妮亚灬:BAAALgAECgEJAQAAAA==.',
['烈酒']='烈酒禅心:BAAALgADCgQJBAAAAA==.',
['熊猫']='熊猫小团子:BAAALgADCgEJAQAAAA==.',
['爱与']='爱与救赎:BAAALgAECgcJDwAAAA==.',
['爱丶']='爱丶谁誰:BAAALgAECgEJAQAAAA==.',
['爱琴']='爱琴海中渔:BAABLgAECn8eAAIDAAcJdR3YHQCDAQADAAcJdR3YHQCDAQAAAA==.',
['牛大']='牛大亨:BAAALgAECgYJCwAAAA==.',
['狄阿']='狄阿娜:BAAALgAECgIJBAAAAA==.',
['玛格']='玛格汉猎手:BAAALgAFFAIJBAAAAA==.',
['玩蛋']='玩蛋蛋:BAAALgAECgUJBgAAAA==.',
['男再']='男再有:BAAALgAFFAYJAgAAAA==.',
['白灵']='白灵淼:BAAALgAECgEJAgAAAA==.',
['白狐']='白狐妖姬:BAAALgAECgYJDQAAAA==.',
['盛夏']='盛夏芬德拉:BAAALgAECgEJAQAAAA==.',
['相思']='相思花海:BAAALgAECgMJBQAAAA==.',
['瞄准']='瞄准射击:BAAALgAECgYJBgAAAA==.',
['破晓']='破晓丨铁骑:BAAALgAECgEJAQAAAA==.',
['祈淵']='祈淵:BAAALgAECgUJBQAAAA==.',
['科罗']='科罗纳:BAAALgAECgQJBAAAAA==.',
['窝使']='窝使歪果碰友:BAAALgADCgUJBQAAAA==.',
['简单']='简单绿茶:BAAALgAECgEJAQAAAA==.',
['米彩']='米彩:BAAALgAECgEJAwAAAA==.',
['精神']='精神的铁虎:BAAALgAECgMJAwAAAA==.',
['糟佬']='糟佬头子:BAAALgADCgUJBQAAAA==.',
['紅酒']='紅酒日晒丶:BAAALgAECgEJAQAAAA==.',
['紫荆']='紫荆藤:BAAALgAECgIJAgAAAA==.',
['纯洁']='纯洁的大叔:BAAALgAECgIJAwAAAA==.',
['绝世']='绝世关云长:BAAALgAECgYJCQAAAA==.绝世小辣椒:BAAALgAECgcJCAAAAA==.',
['维尔']='维尔贝利亚:BAAALgADCgEJAQAAAA==.',
['老夫']='老夫让你三招:BAAALgAECgYJBwAAAA==.',
['老牛']='老牛鼻了:BAAALgAECgQJBgAAAA==.',
['老胡']='老胡:BAABLgAFFH8HAAMKAAMJFxGLEgDjAAAKAAMJFxGLEgDjAAAUAAEJYACyBgAgAAAAAA==.',
['职业']='职业弔师:BAAALgAECgUJBQAAAA==.',
['胜利']='胜利之手:BAAALgADCgIJAgAAAA==.',
['腿姐']='腿姐:BAAALgAECgEJAQAAAA==.',
['艾格']='艾格温:BAAALgAECgUJCgAAAA==.',
['艾萨']='艾萨璐:BAAALgAECgcJCwAAAA==.',
['芝麻']='芝麻凛:BAAALgAECgIJAgAAAA==.',
['苍临']='苍临:BAAALgAECgEJAQABLgAECgUJBQAQAAAAAA==.',
['苦根']='苦根:BAAALgAFFAEJAQAAAA==.',
['苹果']='苹果乖不哭:BAAALgAFFAEJAQAAAA==.',
['茉茕']='茉茕:BAAALgAECgcJDgAAAA==.',
['茉莉']='茉莉奶绿:BAAALgAECgUJBwAAAA==.',
['蓝兽']='蓝兽灬香菇:BAAALgAECgUJCAABLgAFFAEJAQAQAAAAAA==.',
['蓝色']='蓝色毒药:BAAALgADCgEJAQAAAA==.',
['蓝若']='蓝若林:BAAALgAECgEJAgAAAA==.',
['血之']='血之哈梅尔:BAAALgADCgUJBQAAAA==.',
['让我']='让我进本吧:BAAALgAECgUJBgABLgAFFAYJCgAVAH4fAA==.',
['诡镇']='诡镇奇谭:BAAALgAFFAUJAwAAAA==.',
['诺克']='诺克图娜迩:BAAALgAECgEJAQAAAA==.',
['贝爷']='贝爷专属厨师:BAAALgADCgYJAQAAAA==.',
['贾百']='贾百万:BAAALgAECgYJDAAAAA==.',
['赛茜']='赛茜莉雅:BAAALgAFFAEJAQAAAA==.',
['超速']='超速的小蜗牛:BAAALgAECgUJBQAAAA==.',
['远行']='远行者:BAAALgAECggJCAAAAA==.',
['迪奥']='迪奥斯库里:BAAALgAECgYJBgAAAA==.',
['迷惑']='迷惑描:BAAALgADCgEJAQAAAA==.',
['迷糊']='迷糊瞄:BAAALgADCgEJAQAAAA==.',
['那么']='那么问题来了:BAAALgADCgUJBQAAAA==.',
['邪月']='邪月苍炎:BAABLgAFFH8CAAIJAAIJiwzCIwCaAAAJAAIJiwzCIwCaAAAAAA==.',
['释永']='释永信打响指:BAAALgADCgYJBgAAAA==.',
['金钢']='金钢牛:BAAALgAECgEJAQAAAA==.',
['锤妹']='锤妹:BAAALgAECgUJBQAAAA==.',
['阴雨']='阴雨的春天:BAAALgAECgkJCgAAAA==.',
['阿拉']='阿拉希德:BAAALgADCgMJAwAAAA==.',
['附魔']='附魔幻象:BAAALgAECgQJBAAAAA==.',
['陈工']='陈工:BAAALgAECgIJAQAAAA==.',
['陈满']='陈满神:BAAALgADCgYJBgAAAA==.',
['随机']='随机奶:BAABLgAFFH8FAAILAAMJRRe2BADkAAALAAMJRRe2BADkAAAAAA==.',
['雨夜']='雨夜轻眉:BAAALgAECgYJDAAAAA==.',
['雪之']='雪之小样:BAAALgAFFAQJBAAAAA==.',
['风霜']='风霜月:BAAALgAECgEJAQAAAA==.',
['马铁']='马铁锤:BAAALgAECgIJAgAAAA==.',
['骑上']='骑上小摩驼:BAAALgADCgEJAQAAAA==.',
['鬼舞']='鬼舞天泉:BAABLgAFFH8FAAIOAAQJgwZlFQD/AAAOAAQJgwZlFQD/AAAAAA==.鬼舞妞妞:BAAALgAFFAEJAgAAAA==.鬼舞少昊:BAAALgAECgEJAgAAAA==.',
['魔王']='魔王降临灬:BAABLgAECn8VAAIWAAgJLwO5SAAfAQAWAAgJLwO5SAAfAQAAAA==.',
['麟听']='麟听:BAAALgAECgEJAQAAAA==.',
['黑不']='黑不流球就行:BAAALgAECgYJCQAAAA==.',
['黑莓']='黑莓:BAAALgADCgMJAwAAAA==.',
['黛箖']='黛箖:BAAALgAECgEJAQAAAA==.',
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
