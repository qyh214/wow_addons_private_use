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

local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','DeathKnight-Unholy','DeathKnight-Frost','Paladin-Retribution','Paladin-Holy','Warlock-Demonology','Druid-Balance','Shaman-Restoration','Evoker-Preservation','Mage-Fire','Warlock-Affliction','Warlock-Destruction','Druid-Restoration','Warrior-Arms','Warrior-Fury','Unknown-Unknown','Monk-Brewmaster','Priest-Discipline','Priest-Shadow','Priest-Holy','Paladin-Protection','DemonHunter-Devourer','Rogue-Subtlety','Rogue-Assassination','DemonHunter-Havoc','Mage-Arcane','Druid-Feral','Monk-Mistweaver','Hunter-Survival',}
local provider = {region='CN',realm='黑翼之巢',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abupaladin:BAAALgAECgEJAQAAAA==.',
An='Anya:BAAALgAECgYJBgAAAA==.',
Aw='Awaf:BAAALgAFFAEJAQAAAA==.',
Az='Azuresong:BAAALgAECgYJEgAAAA==.',
Ba='Babyju:BAAALgAECgkJEAAAAA==.',
Bo='Bohemian:BAAALgADCgEJAQAAAA==.',
Ce='Celica:BAAALgAFFAIJAgAAAA==.',
Cs='Cszk:BAAALgAECgYJBgAAAA==.Cszt:BAABLgAECn8XAAMBAAkJaBoeHQA7AgABAAcJCRseHQA7AgACAAMJrRUmdgAEAQAAAA==.',
Da='Darkforever:BAAALgAECgYJBgAAAA==.',
De='Deliciousy:BAAALgAECgIJBAAAAA==.',
Fa='Fairladyz:BAAALgAECgEJAgAAAA==.',
Ff='Ffied:BAAALgAFFAEJAQAAAA==.',
Fi='Fishtoucher:BAAALgAFFAQJAwAAAA==.',
Ge='Gemino:BAAALgAFFAEJAQAAAA==.Genjiow:BAAALgAECgYJBgAAAA==.',
Ha='Hakunamtat:BAAALgAECgEJAQAAAA==.',
Hi='Hickey:BAACLgAFFH8JAAIDAAQJ0gNQIgAzAQADAAQJ0gNQIgAzAQAuAAQKfxkAAgMABwk8FwGCAM0BAAMABwk8FwGCAM0BAAAA.',
Hu='Huniik:BAAALgAFFAcJAQAAAA==.',
Ku='Kusoul:BAAALgAFFAIJAgAAAA==.',
Ma='Magicjack:BAAALgAECgEJAQAAAA==.Matthew:BAAALgADCgEJAQAAAA==.',
Mi='Miata:BAAALgAECgUJBwAAAA==.Mirrorsshard:BAAALgAECgIJAgABLgAECgcJFwADAFQfAA==.Missu:BAAALgAECgUJBQAAAA==.',
Ni='Nieve:BAAALgAECgQJBAAAAA==.',
Pl='Playerhxujwa:BAAALgAECgUJBQAAAA==.',
Pr='Prelude:BAAALgAECgYJCwAAAA==.',
Re='Remiel:BAAALgAECgEJAQAAAA==.',
Ro='Royalflare:BAAALgAECgEJAQAAAA==.',
Se='Sende:BAAALgAFFAMJBAAAAA==.',
Sh='Shady:BAAALgAECgMJAgAAAA==.Shifty:BAACLgAFFH8TAAIEAAYJGiAaAQAyAgAEAAYJGiAaAQAyAgAuAAQKfzIAAwQACQk7JqgAAOYDAAQACQkhJqgAAOYDAAUABQklIhMBAPsBAAAA.',
Ss='Ssuika:BAAALgAECgEJAQAAAA==.',
Ta='Tangg:BAAALgAECgYJCAAAAA==.',
To='Tom:BAABLgAFFH8FAAIDAAMJYwWaMADwAAADAAMJYwWaMADwAAAAAA==.',
Wh='Whocare:BAAALgAECgMJAwAAAA==.Whyumad:BAAALgAECgIJBAAAAA==.',
Xq='Xqcagain:BAAALgAECgcJDgAAAA==.',
Ym='Ymage:BAAALgAECgkJDgAAAA==.',
['一个']='一个橘子:BAAALgAECgEJAQAAAA==.',
['一只']='一只穿云箭:BAAALgAECgYJBgAAAA==.',
['一吕']='一吕布一:BAABLgAECn8fAAMGAAcJrwnXlgBPAQAGAAcJrwnXlgBPAQAHAAcJRAj2GwDUAAAAAA==.',
['一嘬']='一嘬山羊胡:BAAALgADCgEJAQAAAA==.',
['一奸']='一奸如故:BAAALgAECgEJAQAAAA==.',
['一念']='一念丶桃花:BAAALgAECgcJDQAAAA==.',
['一碗']='一碗都没有:BAAALgAECgEJAgAAAA==.',
['一绿']='一绿向西:BAABLgAFFH8GAAIIAAIJQQwBIQClAAAIAAIJQQwBIQClAAAAAA==.',
['一颗']='一颗橙:BAABLgAFFH8JAAIDAAUJEBILDQCzAQADAAUJEBILDQCzAQAAAA==.',
['七上']='七上八下丶:BAAALgAFFAQJBAAAAA==.',
['七归']='七归:BAABLgAFFH8FAAIJAAUJNACjFgCOAAAJAAUJNACjFgCOAAAAAA==.',
['三心']='三心:BAAALgAECgEJAgAAAA==.',
['三月']='三月纸鸢:BAAALgADCgMJAwAAAA==.',
['三气']='三气归来:BAAALgAECgIJAgAAAA==.',
['三疯']='三疯:BAAALgAECggJEwAAAA==.',
['三盘']='三盘饺子:BAAALgAECgYJBgAAAA==.',
['三颗']='三颗橙:BAAALgAECgYJEQAAAA==.',
['三鹿']='三鹿豆奶:BAABLgAFFH8GAAIKAAMJRhvEDAAOAQAKAAMJRhvEDAAOAQAAAA==.',
['不想']='不想爬山:BAAALgAECgYJBgAAAA==.',
['不戒']='不戒烟:BAAALgAECgYJBQAAAA==.',
['不见']='不见得:BAAALgAECgEJAQAAAA==.',
['不过']='不过闹茹此:BAAALgADCgMJAwAAAA==.',
['且听']='且听丰银:BAABLgAECn8ZAAIHAAYJNCCMHgAjAgAHAAYJNCCMHgAjAgAAAA==.',
['世间']='世间始终你好:BAAALgAFFAEJAQAAAA==.',
['东川']='东川:BAAALgAECgYJDAAAAA==.',
['东方']='东方店铺:BAAALgADCgYJBwAAAA==.',
['东风']='东风五:BAAALgAFFAQJBAAAAA==.',
['两个']='两个大眼睛:BAAALgAECgYJBgAAAA==.两个大鼻孔:BAAALgAECgUJCAAAAA==.',
['两颗']='两颗橙:BAAALgAECgYJDAAAAA==.',
['丨尘']='丨尘归尘丨:BAAALgAECgkJEAAAAA==.',
['丨念']='丨念奴娇丨:BAAALgADCgYJBgAAAA==.',
['丶坠']='丶坠星:BAAALgAECgcJBwAAAA==.',
['丶小']='丶小白丶丶:BAAALgAECgIJAgAAAA==.丶小黑:BAAALgAECgcJBwAAAA==.',
['丶曦']='丶曦落灬:BAAALgAECgEJAgAAAA==.',
['丹妮']='丹妮莉丝趴下:BAABLgAFFH8IAAIDAAQJmxP8GgBfAQADAAQJmxP8GgBfAQAAAA==.',
['乂沫']='乂沫子乂:BAAALgAECgYJBgAAAA==.',
['乂蕾']='乂蕾克萨缌乂:BAAALgAECgUJBQAAAA==.',
['乂血']='乂血莎乂:BAAALgAECgQJAwAAAA==.',
['乄别']='乄别惹我乄:BAAALgAECgQJBgAAAA==.',
['九山']='九山八海:BAAALgAECgYJDgAAAA==.',
['九牛']='九牛一毛丶:BAAALgAFFAUJBAAAAA==.',
['二阶']='二阶堂希罗:BAABLgAFFH8NAAILAAQJ2hYCBABVAQALAAQJ2hYCBABVAQAAAA==.',
['云妮']='云妮洛普:BAAALgAECgYJBgAAAA==.',
['云漾']='云漾无忧:BAAALgADCgUJBQAAAA==.',
['云落']='云落天泱:BAAALgAECgYJCwAAAA==.云落天钖:BAAALgAECgEJAgAAAA==.云落天飏:BAAALgADCgEJAQAAAA==.',
['五阿']='五阿哥:BAAALgADCgMJAwAAAA==.',
['交叉']='交叉执法:BAAALgAECgcJBwAAAA==.',
['人造']='人造人九十九:BAAALgADCgQJBwAAAA==.',
['从小']='从小就很可怜:BAAALgAECgYJEQAAAA==.从小就很可气:BAAALgADCgUJBQAAAA==.',
['企鹅']='企鹅逃跑计划:BAAALgAECgEJAQAAAA==.',
['余余']='余余:BAAALgAECgMJAwAAAA==.',
['佩露']='佩露薇利:BAAALgADCgEJAQAAAA==.',
['佳华']='佳华:BAAALgAFFAEJAQAAAA==.佳华的骑士:BAAALgAECgYJBgAAAA==.',
['俺头']='俺头上有犄角:BAAALgAECgEJAQAAAA==.',
['元気']='元気森林丶:BAAALgAECgMJAwAAAA==.',
['光之']='光之所在:BAABLgAFFH8JAAIGAAQJwwX/DwAnAQAGAAQJwwX/DwAnAQAAAA==.',
['光徽']='光徽:BAAALgAECgEJAgAAAA==.',
['光辉']='光辉小母牛:BAAALgAFFAEJAQAAAA==.',
['入戏']='入戏:BAAALgAECgcJDwAAAA==.',
['八号']='八号里的男人:BAAALgAECgMJAwAAAA==.',
['兰溪']='兰溪谷:BAAALgADCgIJAgAAAA==.',
['冥刃']='冥刃潜踪:BAAALgAFFAcJAgAAAA==.',
['冰上']='冰上梅露露:BAAALgADCgQJBAAAAA==.',
['冰糖']='冰糖丿小龙虾:BAAALgAECgEJAQAAAA==.',
['冷酷']='冷酷反派小马:BAAALgAECgEJAQAAAA==.',
['凑崎']='凑崎纱夏丶:BAABLgAECn8VAAMDAAcJEybrBQBzAgAMAAYJZiSQAQCHAgADAAcJ0yXrBQBzAgAAAA==.',
['凯恩']='凯恩丶怒风:BAAALgADCgIJAgAAAA==.',
['力克']='力克暗牧:BAAALgADCgMJAwAAAA==.',
['北斗']='北斗魔理沙:BAAALgAECgkJDwAAAA==.',
['十九']='十九停:BAAALgAECgIJAgAAAA==.',
['十字']='十字军打鸡:BAAALgAECgEJAQAAAA==.',
['千丝']='千丝万缕:BAAALgAECgYJBgAAAA==.',
['千年']='千年如斯:BAAALgAECgEJAgAAAA==.',
['午安']='午安:BAAALgADCgEJAQAAAA==.',
['华东']='华东肖自在:BAAALgAFFAEJAgAAAA==.',
['卡皮']='卡皮巴拉的玖:BAAALgAECgQJBwAAAA==.',
['又兴']='又兴奋了:BAAALgAECgEJAQAAAA==.',
['又受']='又受惊了:BAAALgAECgEJAQAAAA==.',
['又耍']='又耍宝了:BAACLgAFFH8FAAIIAAMJ7gHiGwC5AAAIAAMJ7gHiGwC5AAAuAAQKfxUABAgABwkJE6uBAFcBAAgABgliEquBAFcBAA0AAQlJFporAEcAAA4AAQkAAP19AB4AAAAA.',
['叒又']='叒又:BAAALgAECggJBgAAAA==.',
['变动']='变动的风象:BAAALgAECgYJBwAAAA==.',
['叛逆']='叛逆游少轩:BAAALgAECgYJBwAAAA==.叛逆游轩少:BAAALgADCgIJAgAAAA==.',
['叶子']='叶子:BAAALgADCgQJBAAAAA==.',
['吉利']='吉利灬:BAAALgADCgEJAQAAAA==.',
['吉尔']='吉尔及其舒坦:BAABLgAECn8VAAMPAAcJlBndKwAAAgAPAAcJlBndKwAAAgAJAAEJUgzVgwAsAAAAAA==.',
['后式']='后式自走人偶:BAAALgAECgUJBQAAAA==.',
['君行']='君行四海:BAAALgAECgYJDgAAAA==.',
['和光']='和光同尘丶:BAAALgAECgcJBwAAAA==.',
['咕咕']='咕咕牛:BAAALgAECgYJDgAAAA==.',
['品客']='品客最好吃:BAAALgAECgYJBwAAAA==.',
['哈密']='哈密爪爪:BAABLgAFFH8FAAIDAAUJsR0vBwDtAQADAAUJsR0vBwDtAQAAAA==.',
['喵喵']='喵喵是猫猫:BAABLgAFFH8HAAMQAAIJFx/yBADLAAAQAAIJFx/yBADLAAARAAEJQAdSJABMAAAAAA==.',
['嗜悦']='嗜悦王:BAAALgAFFAIJAgAAAA==.',
['嘉廷']='嘉廷尔德:BAAALgADCgMJAwAAAA==.',
['嘿丶']='嘿丶帅尧:BAAALgAECgUJCAABLgAECgUJDAASAAAAAA==.',
['四盘']='四盘饺子:BAAALgAECgYJBgAAAA==.',
['圖灬']='圖灬騰:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光帕帕:BAAALgAECgkJBwAAAA==.圣光术:BAAALgAECgMJAwAAAA==.圣光永在:BAABLgAFFH8GAAIGAAQJRgUlEQAcAQAGAAQJRgUlEQAcAQAAAA==.',
['在下']='在下没道德:BAAALgAECgYJBwAAAA==.',
['型男']='型男:BAAALgAECgYJBwAAAA==.',
['埃辛']='埃辛诺斯丨苏:BAAALgAECgYJEgAAAA==.',
['城门']='城门上晒腊肉:BAAALgADCgQJBAAAAA==.',
['塔利']='塔利波波:BAAALgADCgEJAQAAAA==.',
['墓后']='墓后煮尸:BAAALgAECgIJAgAAAA==.',
['夏日']='夏日涂六神:BAAALgAECgUJCwAAAA==.',
['夜不']='夜不归术:BAAALgADCgQJBAAAAA==.',
['夜深']='夜深沉:BAAALgAECgQJBAAAAA==.',
['大地']='大地花:BAAALgAECgYJBwAAAA==.',
['大怪']='大怪兽豪总:BAAALgAECgcJCgAAAA==.',
['大漠']='大漠孤烟丶:BAABLgAFFH8JAAIGAAUJlgdwDwAtAQAGAAUJlgdwDwAtAQAAAA==.',
['大虎']='大虎哨子:BAAALgAECgYJBwAAAA==.',
['大领']='大领主奥丁:BAAALgAECgQJBwAAAA==.',
['天在']='天在水:BAAALgAECgUJCAAAAA==.',
['天灬']='天灬殇:BAAALgAECgMJAwAAAA==.',
['天蝎']='天蝎坐:BAAALgAFFAQJBAAAAA==.',
['奈姿']='奈姿嗒丶:BAAALgAECgEJAQAAAA==.',
['奈法']='奈法利安之魂:BAAALgAECgEJAQAAAA==.',
['奥术']='奥术安那:BAAALgAECgIJAgABLgAFFAUJBAASAAAAAA==.',
['奶僧']='奶僧:BAAALgAECgEJAQAAAA==.',
['奶油']='奶油炸糕:BAAALgAECgcJBwAAAA==.',
['妙蛙']='妙蛙种子丶:BAAALgAECgUJBwAAAA==.',
['威少']='威少:BAAALgAECgEJAQAAAA==.',
['娘儿']='娘儿丶:BAAALgADCgIJAgAAAA==.',
['宋嫂']='宋嫂鱼羹:BAAALgAECgcJAQAAAA==.',
['宋宋']='宋宋:BAAALgAECgQJAwAAAA==.',
['宝宝']='宝宝先上:BAAALgAECgMJAwAAAA==.',
['宝贝']='宝贝开心:BAAALgADCgYJBgAAAA==.',
['寒冰']='寒冰宝珠:BAAALgAECgYJBgAAAA==.',
['射手']='射手坐:BAAALgAECgUJBQAAAA==.',
['小卜']='小卜丁:BAAALgAFFAQJBAAAAA==.',
['小又']='小又:BAAALgADCgMJAwAAAA==.',
['小布']='小布顶:BAAALgAFFAIJBAAAAA==.',
['小弟']='小弟丶芣棄:BAAALgAECgYJCgAAAA==.',
['小武']='小武师傅:BAAALgAECgQJBAAAAA==.',
['小猫']='小猫咪大坏蛋:BAABLgAECn8hAAQIAAcJwx1YUgDQAQAIAAcJUhpYUgDQAQAOAAQJMw37NQDeAAANAAEJAABKKgBLAAAAAA==.小猫雄:BAAALgAECgYJDAAAAA==.',
['小白']='小白不白:BAAALgAECgYJBgAAAA==.小白丶丶:BAAALgAECgYJBwAAAA==.',
['小米']='小米糕灬:BAAALgAECgIJAgAAAA==.小米速七:BAAALgAECgEJAgAAAA==.',
['小美']='小美家灬辅助:BAAALgAECgEJAQAAAA==.',
['小胡']='小胡渣:BAAALgAECgEJAQAAAA==.',
['小酸']='小酸奶大聪明:BAAALgAECgQJBQAAAA==.',
['小魔']='小魔妹妹:BAAALgADCgEJAQAAAA==.',
['小鲤']='小鲤鱼吐泡泡:BAAALgAECgMJAwAAAA==.',
['小黑']='小黑丶:BAAALgADCgEJAQAAAA==.小黑花:BAAALgADCgYJDQAAAA==.',
['就特']='就特么扒拉你:BAAALgAECgcJBwAAAA==.',
['尼古']='尼古拉斯大维:BAABLgAFFH8JAAIGAAQJDxZIBABjAQAGAAQJDxZIBABjAQAAAA==.',
['尼格']='尼格劳碧登:BAAALgADCgYJBgAAAA==.尼格罗尼:BAAALgAFFAIJAgAAAA==.',
['山杏']='山杏花满庭:BAAALgAFFAQJBAAAAA==.',
['山河']='山河入鞘:BAAALgADCgEJAQAAAA==.',
['山药']='山药炖粉条:BAAALgADCgMJAwAAAA==.',
['左手']='左手丶寫寂寞:BAAALgAECgUJBQAAAA==.',
['帅就']='帅就是罪:BAAALgAECgMJAwAAAA==.',
['干啥']='干啥呢:BAAALgAECgEJAQAAAA==.',
['庞吹']='庞吹吹:BAAALgAECgQJBAAAAA==.',
['庞培']='庞培奥:BAAALgAECgYJEQAAAA==.',
['康湿']='康湿傅:BAACLgAFFH8PAAMBAAYJ0g5QBQDVAQABAAYJWAVQBQDVAQACAAIJDxwRDgDLAAAuAAQKfyMAAwEACQk1IYgYAGQCAAEACAkBHYgYAGQCAAIACAm9HSEXAGUBAAAA.',
['异性']='异性只为繁衍:BAAALgAECgEJAgAAAA==.',
['张梦']='张梦溪:BAAALgAFFAcJAQAAAA==.',
['張梦']='張梦溪:BAABLgAFFH8KAAIDAAYJ5QONCwDAAQADAAYJ5QONCwDAAQAAAA==.',
['当晓']='当晓家:BAAALgAECgEJAQABLgAECgIJAwASAAAAAA==.',
['影踪']='影踪派小明:BAABLgAECn8ZAAITAAcJbBeeDABJAQATAAcJbBeeDABJAQAAAA==.',
['微笑']='微笑练习:BAAALgAECgEJAQAAAA==.',
['忆如']='忆如水:BAACLgAFFH8NAAIUAAQJ/hmjBwBiAQAUAAQJ/hmjBwBiAQAuAAQKfxoABBQABwlzF1caAMUBABQABwlzF1caAMUBABUABgnuGikkALYBABYAAwkjEPdjAJ4AAAAA.',
['快跑']='快跑宝贝:BAAALgADCgEJAQAAAA==.',
['慕思']='慕思丶:BAAALgAECgMJAwAAAA==.',
['戏中']='戏中人:BAAALgAFFAMJAwAAAA==.',
['我会']='我会盾反:BAAALgAFFAQJBAAAAA==.',
['我很']='我很抗揍:BAAALgADCgUJBQAAAA==.',
['我是']='我是奶龙:BAAALgADCgUJBQAAAA==.',
['我的']='我的源氏没刀:BAAALgAECgYJDAAAAA==.',
['戒酒']='戒酒:BAAALgAECgYJAwAAAA==.',
['战神']='战神李富强:BAAALgAECgYJBgAAAA==.战神马加七:BAAALgADCgUJAwAAAA==.',
['扑克']='扑克小猫:BAAALgAECgUJBQAAAA==.',
['技术']='技术三:BAAALgAFFAMJAwAAAA==.',
['拾叁']='拾叁丷:BAAALgAFFAQJBAAAAA==.',
['排骨']='排骨妹:BAAALgADCgEJAQAAAA==.',
['揍敌']='揍敌客丶圣:BAAALgAECgIJAwAAAA==.',
['插棒']='插棒子拉链子:BAAALgAFFAMJAwAAAA==.',
['放开']='放开让我来:BAABLgAECn8UAAMGAAcJYxRYcQCZAQAGAAcJnRFYcQCZAQAXAAQJMAsQMACTAAAAAA==.',
['敬个']='敬个丶礼:BAAALgAECgYJBwAAAA==.',
['文文']='文文静静的我:BAAALgAECgEJAgAAAA==.',
['无为']='无为丶:BAAALgAECgEJAgAAAA==.',
['无证']='无证驾驶:BAAALgAFFAEJAwAAAA==.',
['无边']='无边海:BAAALgADCgYJBgAAAA==.',
['明明']='明明老师:BAAALgAECgMJAwAAAA==.',
['星影']='星影:BAAALgAECgcJBwAAAA==.',
['春夏']='春夏秋苳:BAAALgAFFAEJAQAAAA==.',
['暗狱']='暗狱小丶五儿:BAAALgADCgUJBgAAAA==.暗狱小五儿:BAAALgAECgcJCAAAAA==.暗狱小五儿灬:BAAALgADCgEJAQAAAA==.',
['暗裔']='暗裔:BAAALgADCgUJAgAAAA==.',
['暗诡']='暗诡封喉:BAAALgAFFAEJAQAAAA==.',
['暮色']='暮色先手:BAAALgADCgYJBgAAAA==.暮色归途:BAAALgAECgIJAgAAAA==.暮色探手:BAAALgAECgEJAQAAAA==.暮色触手:BAAALgAECgUJBQAAAA==.暮色骑手:BAAALgADCgUJBgAAAA==.',
['月代']='月代雪:BAAALgAECgQJBAAAAA==.',
['朋友']='朋友你掉的锅:BAAALgADCggJCAAAAA==.',
['望了']='望了远乡:BAAALgADCgYJBgAAAA==.',
['权不']='权不懂:BAAALgAECgEJAQAAAA==.',
['李尔']='李尔王丶:BAABLgAECn8ZAAIIAAgJLBp4KgBmAgAIAAgJLBp4KgBmAgAAAA==.',
['村里']='村里的野猪:BAAALgAECgEJAQAAAA==.',
['杨总']='杨总:BAABLgAFFH8FAAIYAAIJwhifIwCxAAAYAAIJwhifIwCxAAAAAA==.',
['杨枝']='杨枝甘露:BAAALgAECgMJAwAAAA==.',
['枫叶']='枫叶阳阳:BAAALgAECgEJAQAAAA==.',
['枯坐']='枯坐:BAAALgADCgYJBgAAAA==.',
['某家']='某家:BAAALgADCgEJAQAAAA==.',
['柠檬']='柠檬威士忌:BAAALgAECgQJBAAAAA==.',
['柳生']='柳生飘雪:BAAALgAECgUJCQAAAA==.',
['树式']='树式丶:BAAALgAECgEJAQAAAA==.',
['格拉']='格拉法:BAAALgAECgUJBQAAAA==.',
['桃花']='桃花影落:BAAALgAECgYJAQAAAA==.',
['梦中']='梦中的少女:BAAALgAECgYJCgAAAA==.',
['梦为']='梦为鱼:BAAALgAECgIJAgAAAA==.',
['梨花']='梨花寂寂:BAAALgAECgYJBgAAAA==.',
['梵云']='梵云天降:BAAALgAECgYJDQAAAA==.梵云狩猎:BAAALgAECgcJCAAAAA==.梵云迦镜:BAABLgAECn8ZAAMZAAcJLBgwHgALAgAZAAcJGxgwHgALAgAaAAUJiRFMDABfAQAAAA==.',
['樱羽']='樱羽艾玛:BAAALgAFFAIJAgAAAA==.',
['樱花']='樱花散落:BAAALgAECgkJDwAAAA==.',
['橙味']='橙味冰可乐:BAAALgAECgcJEgAAAA==.橙味冰拿铁:BAABLgAFFH8JAAIDAAUJphj0CADZAQADAAUJphj0CADZAQAAAA==.橙味冰阔落:BAAALgAECgYJBgAAAA==.橙味古巴:BAAALgAECgYJBgAAAA==.橙味果酱:BAABLgAFFH8HAAIDAAUJ5xXdCwC+AQADAAUJ5xXdCwC+AQAAAA==.橙味莫吉托:BAAALgAFFAQJBAAAAA==.',
['橙子']='橙子味的果酱:BAABLgAFFH8VAAIDAAYJfR75AAD2AQADAAYJfR75AAD2AQAAAA==.',
['歌丶']='歌丶诗图:BAABLgAFFH8OAAIZAAQJGQ5qCADqAAAZAAQJGQ5qCADqAAAAAA==.',
['正妹']='正妹妹:BAEBLgAFFH8GAAIKAAQJgRvVBQBtAQAKAAQJgRvVBQBtAQAAAA==.',
['武器']='武器帕帕:BAAALgAECgcJBwAAAA==.',
['武藏']='武藏:BAAALgAECgUJBwAAAA==.',
['毒龙']='毒龙:BAAALgAECgUJCgAAAA==.',
['毛灬']='毛灬豆:BAAALgAECgEJAgAAAA==.',
['水元']='水元素快跑:BAAALgAECgQJBQAAAA==.',
['水牧']='水牧灬年华:BAAALgADCgEJAQAAAA==.',
['水瓶']='水瓶坐:BAAALgAFFAEJAQAAAA==.',
['永远']='永远喜欢夏天:BAAALgAECgIJAgAAAA==.',
['江西']='江西教官:BAAALgAECgYJBwAAAA==.',
['沃萨']='沃萨理斯:BAAALgAECgYJBwAAAA==.沃萨里斯:BAAALgAECgYJAQAAAA==.',
['沉默']='沉默祷言:BAAALgAECgkJEgAAAA==.',
['沐雲']='沐雲春術:BAAALgAECggJCAAAAA==.',
['没染']='没染:BAAALgAECgYJBgAAAA==.',
['法天']='法天相地:BAABLgAECn8cAAIDAAcJNxe7YgAUAgADAAcJNxe7YgAUAgAAAA==.',
['法爷']='法爷跑路了:BAABLgAFFH8EAAIIAAMJNQutJADwAAAIAAMJNQutJADwAAAAAA==.',
['浅葱']='浅葱的绿耀:BAAALgAECgkJBwABLgAFFAQJBQACAIMMAA==.',
['浣花']='浣花剑雨:BAAALgAECgEJAgAAAA==.',
['浮生']='浮生箬梦:BAAALgAFFAQJBAAAAA==.浮生若梦:BAABLgAFFH8JAAIGAAUJ4wUaCAAuAQAGAAUJ4wUaCAAuAQAAAA==.',
['浮笙']='浮笙若夢:BAAALgAECgkJDwAAAA==.',
['海以']='海以南不再蓝:BAAALgAECgEJAQAAAA==.',
['深了']='深了:BAAALgAFFAQJBAAAAA==.',
['深念']='深念:BAAALgAECgYJCwAAAA==.',
['深海']='深海咲豹:BAAALgADCgQJBwAAAA==.',
['深渊']='深渊之燕:BAAALgAFFAEJAQAAAA==.',
['清一']='清一色丷:BAAALgAFFAIJAgAAAA==.',
['清新']='清新丶小胡渣:BAABLgAECn8aAAIGAAkJbRUeJQCTAgAGAAkJbRUeJQCTAgAAAA==.清新小胡渣:BAAALgAFFAIJAgAAAA==.清新小胡渣丶:BAAALgAECgcJBwAAAA==.清新的小胡渣:BAAALgAECgYJCgAAAA==.',
['游戏']='游戏读条中:BAAALgAECgMJAwAAAA==.',
['溜溜']='溜溜骑:BAAALgAECgMJAwAAAA==.',
['炉石']='炉石跑路:BAAALgAECgcJCAAAAA==.',
['炎魂']='炎魂:BAAALgAECgcJBwAAAA==.',
['烟烟']='烟烟雁眼:BAAALgAFFAUJAwAAAA==.',
['然然']='然然:BAAALgAFFAEJAQABLgAFFAQJBgAVAAcWAA==.',
['爱吃']='爱吃维他命:BAAALgADCgUJBQABLgAECgIJAwASAAAAAA==.',
['爱喝']='爱喝冰红茶:BAAALgAECgIJAgAAAA==.',
['爱意']='爱意随风岂:BAAALgAECggJDQAAAA==.',
['爱薅']='爱薅猴尾巴:BAACLgAFFH8JAAMbAAMJiRZnBQAGAQAbAAMJiRZnBQAGAQAYAAIJlgMYHQCFAAAuAAQKfxcAAxsABwnCIIoOAHoCABsABwnCIIoOAHoCABgAAwmEFba6AI8AAAAA.',
['牛乳']='牛乳奶茶:BAAALgADCgEJAQAAAA==.',
['牛油']='牛油果咖啡:BAAALgAECggJBAAAAA==.',
['狐狐']='狐狐王:BAAALgAECgYJBgAAAA==.',
['独舞']='独舞小春:BAAALgAECgEJAQAAAA==.',
['猪鹿']='猪鹿蝶:BAAALgAECgcJCgAAAA==.',
['猫的']='猫的画笔:BAAALgAECgUJDQAAAA==.',
['玉术']='玉术临疯:BAACLgAFFH8IAAIIAAMJKBHeIQD8AAAIAAMJKBHeIQD8AAAuAAQKfxYABAgABgloIgA8AB0CAAgABgloIgA8AB0CAA4AAQm9DVdxADQAAA0AAQkAAAw3ACcAAAAA.',
['王元']='王元我鸟:BAAALgADCgYJBgAAAA==.',
['王钢']='王钢蛋丶:BAAALgAECgkJCQAAAA==.',
['玖叁']='玖叁捌陆:BAABLgAECn8UAAITAAcJbB/1DwCdAgATAAcJbB/1DwCdAgAAAA==.',
['玛祖']='玛祖鲁:BAAALgAECgMJAgAAAA==.',
['玩什']='玩什么迪凯:BAAALgAECgYJCQAAAA==.',
['理智']='理智的星语梦:BAAALgAFFAEJAwAAAA==.',
['瑾年']='瑾年丨木子:BAAALgAECgIJAgAAAA==.',
['瓦拉']='瓦拉哇啦:BAAALgADCgYJBwAAAA==.',
['疯狂']='疯狂扥玻璃球:BAAALgAFFAEJAQAAAA==.',
['疾风']='疾风泽:BAAALgAFFAEJAQAAAA==.',
['神奇']='神奇的炖吨吨:BAAALgADCgEJAQAAAA==.神奇绿猪:BAAALgAFFAIJAwAAAA==.神奇黑猪:BAAALgADCgMJAwAAAA==.',
['空条']='空条徐纶:BAAALgAECgIJAgAAAA==.',
['第八']='第八章:BAAALgAECgUJBAAAAA==.',
['笼中']='笼中雀:BAABLgAFFH8FAAIIAAQJGxtJDAB5AQAIAAQJGxtJDAB5AQAAAA==.',
['簡單']='簡單的愛:BAAALgADCgkJCwAAAA==.',
['粑粑']='粑粑是绿色:BAAALgAECgYJCwAAAA==.',
['粪海']='粪海狂虫:BAAALgAECgcJDwAAAA==.',
['紅尘']='紅尘帝王朝:BAAALgADCgEJAgAAAA==.',
['素心']='素心若水:BAAALgAECgIJAwAAAA==.',
['约格']='约格:BAAALgAECgkJBgAAAA==.',
['纯洁']='纯洁的小白花:BAAALgAECgcJDQAAAA==.',
['纳岚']='纳岚飞雪:BAABLgAECn8fAAMIAAgJfA/DfgBdAQAIAAYJyhHDfgBdAQAOAAMJQQIqSwCMAAAAAA==.',
['纵火']='纵火爱好者:BAAALgAFFAEJAQAAAA==.',
['绫小']='绫小路清隆:BAACLgAFFH8JAAIDAAMJjR+pIQA6AQADAAMJjR+pIQA6AQAuAAQKfyIAAwMACAmRI1sTADQDAAMACAmRI1sTADQDABwAAgnVHacSAJoAAAAA.',
['维大']='维大维:BAAALgAFFAEJAQAAAA==.',
['维尔']='维尔莉丝:BAAALgAECgUJBgAAAA==.',
['绿叔']='绿叔:BAABLgAFFH8FAAIIAAMJOxjFEAAKAQAIAAMJOxjFEAAKAQAAAA==.',
['绿皮']='绿皮小人:BAACLgAFFH8JAAIKAAMJ/hiUCADzAAAKAAMJ/hiUCADzAAAuAAQKfxkAAgoABwnmGNcoAOwBAAoABwnmGNcoAOwBAAAA.',
['美杜']='美杜莎之眼:BAAALgAECgkJCQAAAA==.',
['羲和']='羲和:BAAALgAECgYJBgAAAA==.',
['翠影']='翠影狂舞:BAAALgAECgYJCAAAAA==.',
['翻滚']='翻滚的树精:BAAALgAECgcJAQAAAA==.',
['老查']='老查猎:BAAALgAFFAMJAwAAAA==.',
['老汉']='老汉子:BAAALgAECgIJAQAAAA==.',
['职场']='职场里的井野:BAAALgAECgEJAQABLgAECggJIwAdAJMWAA==.',
['致死']='致死一刀:BAAALgAECgMJAwAAAA==.',
['花季']='花季护航:BAAALgADCgYJBgAAAA==.',
['花幺']='花幺幺:BAAALgADCgIJAgAAAA==.',
['花花']='花花丶:BAAALgAECgIJAgAAAA==.',
['花酒']='花酒不藏遗:BAABLgAFFH8KAAIGAAMJKRXTFAACAQAGAAMJKRXTFAACAQAAAA==.',
['苏跳']='苏跳跳:BAAALgAECgQJBAAAAA==.',
['范牛']='范牛牛:BAAALgAECgMJAwAAAA==.',
['莫兰']='莫兰蒂:BAAALgAECgEJAQAAAA==.',
['莽僧']='莽僧:BAAALgAECgMJAwABLgAFFAUJCQATAH0fAA==.',
['莽村']='莽村李宏伟:BAAALgAECgIJAgAAAA==.',
['萌二']='萌二:BAAALgAECgYJDgAAAA==.',
['萨拉']='萨拉班德:BAAALgAECgcJBwAAAA==.萨拉邦德:BAAALgAECgMJAwAAAA==.',
['落叶']='落叶飞飞:BAAALgAECgIJAgAAAA==.',
['葡萄']='葡萄冰萃丶:BAAALgAFFAEJAgAAAA==.',
['蒂埃']='蒂埃驰:BAAALgADCgUJBQAAAA==.',
['蓝凌']='蓝凌雨:BAEALgAFFAUJBAAAAA==.',
['薄荷']='薄荷小牛妞:BAAALgAECgEJAQAAAA==.薄荷汤力:BAAALgAFFAQJAwAAAA==.',
['蝎勒']='蝎勒虎子:BAABLgAFFH8FAAILAAIJuRIIEgCfAAALAAIJuRIIEgCfAAAAAA==.',
['血帝']='血帝魔:BAAALgAECgUJBQAAAA==.',
['被冤']='被冤枉的秋风:BAAALgAFFAQJAgAAAA==.',
['要你']='要你命:BAAALgADCgUJBQAAAA==.',
['讲道']='讲道理:BAAALgAECgkJBgABLgAFFAUJAwASAAAAAA==.',
['诡影']='诡影噬魂:BAAALgAFFAQJBAAAAA==.',
['豆豆']='豆豆丶丶:BAAALgAECgYJBgAAAA==.',
['贾森']='贾森黄:BAAALgAECgYJBwAAAA==.',
['起灵']='起灵:BAAALgAFFAIJAgAAAA==.',
['超爱']='超爱卷心菜:BAAALgAECgYJBAAAAA==.',
['跳楼']='跳楼机:BAAALgAECgYJAwAAAA==.',
['轻影']='轻影:BAAALgAECgYJEgAAAA==.',
['达不']='达不溜:BAAALgADCgQJBAAAAA==.',
['迪小']='迪小迦:BAAALgAECgYJAwAAAA==.',
['郐跑']='郐跑:BAAALgADCgEJAQAAAA==.',
['酷蛮']='酷蛮疯子:BAAALgADCgUJBgAAAA==.',
['野猪']='野猪妮妮:BAABLgAECn8dAAMGAAcJJxV/ZQC2AQAGAAcJJxV/ZQC2AQAXAAUJ3AerLQCiAAAAAA==.野猪宝宝:BAAALgAECgMJAwAAAA==.野猪崽崽:BAABLgAECn8YAAMBAAcJuRnkLQC/AQABAAcJuRnkLQC/AQACAAQJhRYJeAD/AAAAAA==.',
['野生']='野生古尔的蛋:BAAALgAECgYJAwAAAA==.',
['钟止']='钟止意难平:BAAALgAECggJAwAAAA==.',
['铜锅']='铜锅涮肉:BAAALgAECgcJAQAAAA==.',
['长岛']='长岛氷茶:BAAALgAECgYJDAAAAA==.',
['門徒']='門徒灬無湮:BAAALgAECgEJAQAAAA==.',
['闪丨']='闪丨电:BAAALgAECgYJBgAAAA==.',
['闪电']='闪电伍连鞭:BAACLgAFFH8FAAIeAAQJHRwEBwDvAAAeAAQJHRwEBwDvAAAuAAQKfxUAAh4ABwlwIEUOAHMCAB4ABwlwIEUOAHMCAAAA.闪电咕咕:BAAALgAECgYJBwAAAA==.',
['阳子']='阳子:BAAALgAECgcJDQAAAA==.',
['阿凡']='阿凡达刷怪:BAAALgAECgQJCQAAAA==.',
['阿奇']='阿奇佐尔缇:BAAALgAECgQJBAAAAA==.',
['阿尔']='阿尔萨思:BAAALgAECgkJCAAAAA==.',
['阿强']='阿强射满:BAACLgAFFH8NAAQCAAQJTRRiBABUAQACAAQJ7w5iBABUAQABAAQJ1hB3DgA/AQAfAAIJ4QvwBACkAAAuAAQKfxcABB8ACAlyHcgPAMcBAB8ABwkUF8gPAMcBAAEABQkJGw02AI0BAAIAAQkuHDxJAFYAAAAA.阿强玩火:BAAALgAECgYJBgAAAA==.',
['阿文']='阿文:BAAALgAECgcJCAAAAA==.',
['阿瓦']='阿瓦隆丶风暴:BAAALgADCgUJBQAAAA==.',
['阿纳']='阿纳斯塔西亚:BAAALgAECgEJAQAAAA==.',
['阿莱']='阿莱珂丝塔萨:BAAALgAECgEJAQAAAA==.',
['阿郎']='阿郎:BAAALgAECgYJBgAAAA==.',
['雁过']='雁过留痕:BAAALgAECgYJBgAAAA==.',
['零一']='零一:BAAALgAFFAEJAQAAAA==.',
['零零']='零零:BAAALgADCgUJBQAAAA==.',
['雷击']='雷击哈德:BAAALgAECgQJBwAAAA==.',
['雷霆']='雷霆击碎黑暗:BAAALgAFFAEJAQAAAA==.',
['雾里']='雾里看花:BAAALgAECgEJAQAAAA==.',
['霸气']='霸气糊涂尧:BAAALgAECgUJDAAAAA==.',
['靖逸']='靖逸:BAAALgAFFAIJAwAAAA==.',
['非常']='非常大富婆:BAAALgAECgUJCQAAAA==.非常富婆:BAACLgAFFH8JAAMCAAMJ/CKzCQALAQACAAMJwyKzCQALAQABAAIJahzNGQC2AAAuAAQKfxYAAwIABwn6I8QSAKECAAIABwn6I8QSAKECAAEAAwkEFwplAKsAAAAA.非常邦桑迪:BAAALgAECgYJCwAAAA==.',
['面包']='面包牛奶:BAAALgAECgMJAwAAAA==.',
['风拂']='风拂流年:BAAALgAECgcJBwAAAA==.',
['飘逸']='飘逸的选手:BAAALgAECgEJAQAAAA==.',
['飞奔']='飞奔的小闹闹:BAAALgAECgYJBgAAAA==.',
['饭团']='饭团丶:BAAALgAECgYJBwAAAA==.',
['饮酒']='饮酒醉千愁:BAAALgAECgEJAQAAAA==.',
['骑神']='骑神托尔丹:BAAALgADCgcJBwAAAA==.',
['高原']='高原:BAAALgAECgUJBgAAAA==.',
['魔瘾']='魔瘾上来了:BAABLgAECn8XAAIDAAYJBBEvuABwAQADAAYJBBEvuABwAQAAAA==.',
['魔蝎']='魔蝎坐:BAAALgAECggJBgAAAA==.',
['鱼幼']='鱼幼薇丿:BAAALgAECgYJCwAAAA==.',
['鲨鱼']='鲨鱼宝宝:BAAALgAECgMJBgAAAA==.',
['麦片']='麦片牛奶:BAAALgAECgUJCAAAAA==.',
['黑影']='黑影噬心:BAAALgAFFAQJAQAAAA==.',
['黑色']='黑色丿曼陀铃:BAAALgADCgIJAgAAAA==.',
['黛真']='黛真知子:BAAALgADCgYJBgAAAA==.',
['黯影']='黯影木尸:BAABLgAECn8bAAMVAAkJYSB2BABOAwAVAAkJYSB2BABOAwAWAAkJLRpbCQC2AgABLgAFFAUJBQAUADwhAA==.',
['龙七']='龙七对丷:BAABLgAFFH8IAAIKAAQJMxHjBQArAQAKAAQJMxHjBQArAQAAAA==.',
['龙龙']='龙龙查:BAAALgAFFAMJAwAAAA==.',
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
