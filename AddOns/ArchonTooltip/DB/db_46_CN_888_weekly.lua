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

local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Paladin-Retribution','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Monk-Brewmaster','Evoker-Augmentation','Evoker-Preservation','Druid-Balance','Mage-Frost','Druid-Restoration','Shaman-Restoration','Warlock-Demonology','Priest-Discipline','Druid-Guardian','Unknown-Unknown',}
local provider = {region='CN',realm='鲜血熔炉',name='CN',type='weekly',zone=46,date='2026-04-25',data={Aa='Aarn:BAAALgADCgQJBAAAAA==.',
Al='Alessandrroo:BAAALgAECgMJAwAAAA==.',
Bl='Blingknight:BAAALgAECgYJCQAAAA==.',
Bo='Bobo:BAAALgAFFAIJAwAAAA==.',
By='Byakuya:BAACLgAFFH8NAAMBAAUJkR1UCACOAQABAAQJkR1UCACOAQACAAEJAACyEwAAAAAuAAQKfycAAgEACQm3IcgGAGwDAAEACQm3IcgGAGwDAAAA.',
Da='Darktang:BAAALgAECgYJBwAAAA==.',
De='Desoxynn:BAAALgAFFAQJAwAAAA==.',
Ev='Evidrannor:BAAALgAECgYJBwAAAA==.',
Fl='Flymdh:BAAALgADCgIJAgAAAA==.',
Gi='Gildarts:BAAALgAECgcJDwAAAA==.',
Gr='Grincess:BAAALgAECgYJBgAAAA==.',
Ho='Holyknight:BAAALgAECgEJAQAAAA==.',
Id='Idoraemonl:BAAALgAECgQJBAAAAA==.',
Ka='Kakarotto:BAAALgAFFAIJAgAAAA==.',
Li='Linchua:BAACLgAFFH8RAAIDAAUJUCSGAQAPAgADAAUJUCSGAQAPAgAuAAQKfygAAgMACAl7JjUGAGoDAAMACAl7JjUGAGoDAAAA.',
Lo='Louder:BAAALgAECgEJAgAAAA==.',
Na='Natsu:BAAALgAECgQJCwAAAA==.',
No='Nonamer:BAAALgAECggJCAAAAA==.',
Ob='Oblivionis:BAAALgAECgkJEAAAAA==.',
Pe='Peppapig:BAAALgAECggJCQAAAA==.',
Ra='Raito:BAAALgAECgYJDAAAAA==.',
Si='Silvanuswild:BAAALgAECgYJBgAAAA==.',
So='Sohee:BAABLgAECn8VAAMEAAcJchvfMQCmAQAEAAYJOhjfMQCmAQAFAAQJURw1bwAaAQAAAA==.',
St='Starrover:BAAALgAECgUJCAAAAA==.',
Ta='Tako:BAAALgAECgYJCwAAAA==.',
Ti='Tirpitz:BAAALgAFFAIJAgAAAA==.',
Tr='Triplehunter:BAAALgAECgEJAQAAAA==.',
Xb='Xbzz:BAAALgAECgYJEQAAAA==.',
Zi='Zimomo:BAAALgADCgcJBwAAAA==.',
['一个']='一个四七:BAAALgADCgEJAQAAAA==.',
['一队']='一队的骑士:BAAALgAECgIJAgAAAA==.',
['不要']='不要慌:BAABLgAECn8WAAMGAAYJZh0oIAC0AQAGAAUJiSAoIAC0AQAHAAYJCSBGCQCCAQAAAA==.',
['不辱']='不辱使命:BAAALgADCgEJAQAAAA==.',
['丨尘']='丨尘封丨:BAAALgAECgcJBwAAAA==.',
['丨死']='丨死侍丶:BAAALgAECgcJCAAAAA==.',
['丨绯']='丨绯红女巫丶:BAAALgAFFAEJAQAAAA==.',
['丶丶']='丶丶:BAAALgAFFAQJAwAAAA==.丶丶一:BAAALgAFFAUJBAAAAA==.丶丶二:BAAALgAFFAQJBAAAAA==.',
['丶木']='丶木头懒人:BAAALgAECgUJCgAAAA==.',
['丶萨']='丶萨鲁法尔:BAAALgAECgMJAwAAAA==.',
['乂木']='乂木头懒人乂:BAAALgAECgEJAQAAAA==.',
['九红']='九红哥哥:BAAALgADCgIJAgAAAA==.',
['二手']='二手芫荽:BAAALgAECgEJAQAAAA==.',
['五六']='五六七八:BAAALgADCgMJAwAAAA==.',
['佐贝']='佐贝伊德:BAAALgADCgEJAQAAAA==.',
['何事']='何事七:BAABLgAECn8bAAMBAAkJcBz5AgCXAgABAAkJ0Rv5AgCXAgACAAkJgBOADQA2AgABLgAFFAQJBgABAL0YAA==.',
['佬涩']='佬涩毗:BAAALgAECgYJCQAAAA==.',
['兮颜']='兮颜丷:BAAALgAECgkJEQAAAA==.',
['冷烟']='冷烟丶鈊鋙:BAAALgAFFAMJAwAAAA==.',
['凤卷']='凤卷残云:BAAALgAECgUJCQAAAA==.',
['华兰']='华兰股份涨停:BAAALgAECgkJBwAAAA==.',
['卿武']='卿武非佯:BAAALgAECgYJBgAAAA==.',
['古陈']='古陈九:BAAALgAECgYJBgAAAA==.',
['只擅']='只擅谈冰:BAAALgAECgIJAwAAAA==.',
['可乐']='可乐味弱匕:BAAALgAECggJDwAAAA==.',
['吃奶']='吃奶之力:BAAALgADCgcJBwAAAA==.',
['吃饭']='吃饭时不饿:BAAALgAECgUJBQAAAA==.',
['合欢']='合欢老魔:BAAALgAECgYJCgAAAA==.',
['咲夜']='咲夜十六夜:BAAALgAECgYJBgAAAA==.',
['哈鸡']='哈鸡米:BAAALgADCgEJAQAAAA==.',
['商盟']='商盟三十一:BAAALgAECgUJCQAAAA==.',
['嘟嘟']='嘟嘟骑士:BAAALgAECgUJCAAAAA==.',
['四喜']='四喜:BAAALgAECgQJBAAAAA==.',
['因为']='因为无聊:BAAALgAECgkJEQAAAA==.',
['埃斯']='埃斯蒂尼安:BAABLgAFFH8GAAMIAAIJ5AaPGwCSAAAIAAIJ5AaPGwCSAAAJAAEJOyGoCgBkAAABLgAFFAIJBgAKAKQRAA==.',
['多喝']='多喝水少生气:BAAALgAECgEJAQAAAA==.',
['大号']='大号榴炮:BAAALgADCgMJAwAAAA==.',
['大白']='大白五一:BAAALgAECgMJCAAAAA==.',
['大薇']='大薇薇吖:BAAALgAECgEJAQAAAA==.',
['天行']='天行客:BAAALgAECgYJDgAAAA==.',
['威震']='威震天的酸奶:BAAALgAECgEJAQAAAA==.',
['季博']='季博炒长:BAAALgAECgQJBQAAAA==.季博超嗒:BAAALgAECgQJBAAAAA==.季博超达:BAAALgAECgQJBAAAAA==.季博超醋:BAAALgAECgEJAQAAAA==.季博超黑:BAAALgAECgYJBgAAAA==.季博达:BAAALgAECgYJBwAAAA==.',
['容木']='容木:BAAALgADCgYJBgAAAA==.',
['寂兮']='寂兮寥兮:BAAALgAECgcJEAAAAA==.',
['寒花']='寒花:BAAALgAFFAEJAgAAAA==.',
['寒霜']='寒霜夜雨:BAAALgAFFAIJAwAAAA==.',
['小世']='小世界末日:BAAALgAECgMJAgAAAA==.',
['小丫']='小丫白兔:BAAALgADCgEJAQAAAA==.',
['小宝']='小宝栗子:BAABLgAFFH8LAAILAAQJJRJRGgBhAQALAAQJJRJRGgBhAQAAAA==.',
['小汐']='小汐汐丶:BAAALgAFFAQJBAABLgAECggJFQAJALUjAA==.',
['少年']='少年大宝:BAAALgADCgQJBAAAAA==.',
['尛辉']='尛辉:BAAALgAECgUJBQAAAA==.',
['就加']='就加一小口:BAAALgADCgYJBgAAAA==.',
['带带']='带带弟弟好吗:BAAALgAECgQJCAAAAA==.',
['幸福']='幸福本是毒奶:BAAALgAECgEJAQAAAA==.',
['幻境']='幻境丶:BAAALgAECgQJBgAAAA==.',
['幽影']='幽影残雲:BAAALgADCgUJCAAAAA==.',
['德天']='德天赌后:BAAALgAECgUJBwAAAA==.',
['德手']='德手:BAAALgAECgMJAwAAAA==.',
['恶魔']='恶魔城冥王:BAAALgADCgMJAwAAAA==.恶魔城阎王:BAAALgAECgIJAQAAAA==.',
['悠悠']='悠悠世间:BAAALgADCgEJAQAAAA==.',
['戈壁']='戈壁老王:BAAALgAECgIJAQAAAA==.',
['我不']='我不脆的:BAAALgAECgIJAgAAAA==.',
['我家']='我家乖乖:BAAALgAECgYJDgAAAA==.我家小乖:BAAALgAECgEJAgAAAA==.',
['我是']='我是法斯:BAAALgAECgYJCQAAAA==.',
['我的']='我的好厚米:BAAALgAECgYJDQAAAA==.',
['战风']='战风噬魂者:BAAALgADCgYJBgAAAA==.',
['批特']='批特惹里健踩:BAAALgAECgEJAQAAAA==.',
['斩龍']='斩龍:BAAALgADCgQJBAAAAA==.',
['无形']='无形无忌:BAAALgAFFAIJAwAAAA==.',
['时风']='时风曰:BAAALgAECgcJBgAAAA==.',
['星宿']='星宿老仙:BAAALgADCgUJBQAAAA==.',
['普莉']='普莉希拉:BAAALgAFFAIJAgAAAA==.',
['暗夜']='暗夜飞翔:BAAALgAECgYJCwAAAA==.',
['木木']='木木他老子:BAAALgAECgIJAgAAAA==.木木季博超达:BAAALgAECgMJAwAAAA==.木木的季博达:BAAALgAECgYJBgAAAA==.木木的宝宝:BAAALgAECgIJAgAAAA==.木木的鸡脖:BAAALgAFFAIJAgAAAA==.',
['果冻']='果冻布丁:BAABLgAECn8eAAMKAAkJcB6uBABXAwAKAAkJcB6uBABXAwAMAAgJWSIhEwCdAgAAAA==.',
['柠檬']='柠檬糖:BAAALgAECgEJAgAAAA==.',
['桀骜']='桀骜血:BAAALgAECgYJDAAAAA==.',
['椰子']='椰子叶子:BAABLgAFFH8MAAIBAAQJTBtrDQBtAQABAAQJTBtrDQBtAQAAAA==.',
['楠木']='楠木:BAAALgAECgIJAwAAAA==.楠木之灵:BAAALgAECgQJBAAAAA==.楠木凌风:BAAALgAECgEJAQAAAA==.',
['極智']='極智的雅痞:BAAALgAECgUJAwAAAA==.',
['欧皇']='欧皇血统:BAAALgAECgEJAQAAAA==.',
['毙除']='毙除:BAABLgAFFH8GAAINAAYJHRGxAADcAQANAAYJHRGxAADcAQAAAA==.',
['江山']='江山如此多骄:BAAALgAECgcJBwAAAA==.',
['流星']='流星白羽:BAAALgAECgYJDAAAAA==.',
['浅雾']='浅雾微凝:BAAALgAECgEJAQAAAA==.',
['浩劫']='浩劫後的重生:BAABLgAFFH8JAAIOAAQJPh90AwCFAQAOAAQJPh90AwCFAQAAAA==.',
['浮生']='浮生辛诺:BAABLgAFFH8IAAIBAAMJ3AjoFgDhAAABAAMJ3AjoFgDhAAAAAA==.',
['海皮']='海皮牛耶尔:BAAALgAECgIJAgAAAA==.',
['混乱']='混乱风暴:BAAALgADCgIJAgAAAA==.',
['清辉']='清辉月凝:BAABLgAFFH8HAAIPAAYJExB4AQDiAQAPAAYJExB4AQDiAQAAAA==.',
['清风']='清风乂璟暄:BAAALgAECgkJEQAAAA==.清风乂萨其马:BAAALgAECgEJAQAAAA==.',
['溜溜']='溜溜球:BAABLgAFFH8RAAILAAQJjR+2FQBzAQALAAQJjR+2FQBzAQAAAA==.',
['灬飞']='灬飞羽灬:BAAALgAECgUJBQAAAA==.',
['然然']='然然:BAAALgAFFAEJAQAAAA==.',
['熊猫']='熊猫符文:BAAALgADCgEJAQAAAA==.',
['牛仔']='牛仔酷:BAAALgADCgcJBwAAAA==.',
['牛波']='牛波一:BAAALgAFFAEJAQAAAA==.',
['玉轩']='玉轩:BAAALgADCgcJDQAAAA==.',
['瑞穆']='瑞穆:BAAALgAFFAIJAgAAAA==.',
['璀璨']='璀璨之猎:BAAALgAECgEJAQAAAA==.',
['瓦蛙']='瓦蛙哇哦:BAAALgADCgYJBgAAAA==.',
['疾风']='疾风旋舞:BAAALgAECgEJAQAAAA==.',
['白屿']='白屿:BAAALgAECgYJBgAAAA==.',
['知酒']='知酒温:BAAALgAECgYJDQAAAA==.',
['碳烤']='碳烤鹌鹑:BAACLgAFFH8GAAMKAAIJpBEsEwCqAAAKAAIJpBEsEwCqAAAMAAEJKyE9FABjAAAuAAQKfxYABAoABwkoG88jAN8BAAoABgnFH88jAN8BAAwABAmoDgCHAMgAABAAAgmKCWcrAEoAAAAA.',
['禁忌']='禁忌热血:BAAALgAECgQJBwAAAA==.',
['糖果']='糖果萢萢:BAAALgAFFAIJAwAAAA==.',
['紫巅']='紫巅彡翎:BAAALgADCgEJAQAAAA==.',
['紫月']='紫月夜:BAAALgAECgcJBwAAAA==.',
['終極']='終極灬大錶姐:BAAALgAECgcJDAAAAA==.',
['絕對']='絕對風流:BAAALgAECgYJBwAAAA==.',
['羊宫']='羊宫妃那:BAABLgAFFH8FAAIPAAIJdSaKDgDlAAAPAAIJdSaKDgDlAAAAAA==.',
['老刘']='老刘:BAAALgAECgEJAgAAAA==.',
['老抖']='老抖:BAAALgADCgYJBgAAAA==.',
['考拉']='考拉六斤六:BAAALgADCgYJBgAAAA==.',
['耐肘']='耐肘王:BAAALgAECgcJDAAAAA==.',
['船长']='船长丶:BAAALgAECgIJAwAAAA==.',
['芒果']='芒果超甜:BAAALgADCgEJAQAAAA==.',
['莉卡']='莉卡:BAAALgAECgcJBwABLgAFFAIJBQAPAHUmAA==.',
['莫摩']='莫摩达:BAAALgAECgkJEQAAAA==.',
['萨奇']='萨奇尔:BAAALgADCgIJAgAAAA==.',
['萨帝']='萨帝罗娜:BAAALgAECgEJAgAAAA==.',
['血骑']='血骑士:BAAALgAECgEJAQAAAA==.',
['衰男']='衰男博崽:BAAALgAECgIJAgAAAA==.',
['誓约']='誓约漫月:BAAALgAECggJEAAAAA==.誓约烁玉:BAAALgAECgIJAgABLgAECggJEAARAAAAAA==.誓约落雪:BAAALgAECgEJAQABLgAECggJEAARAAAAAA==.',
['进屋']='进屋暖和暖和:BAAALgAECgUJDAAAAA==.',
['遇见']='遇见我是福气:BAAALgAECgEJAQAAAA==.',
['郭芭']='郭芭比:BAAALgAFFAEJAQAAAA==.',
['采集']='采集高手:BAAALgADCgEJAQAAAA==.',
['野德']='野德灬新之助:BAAALgAECgQJBAABLgAECggJFQAJALUjAA==.',
['铁血']='铁血兽心:BAAALgAECgcJBwAAAA==.',
['铃鹿']='铃鹿:BAACLgAFFH8KAAIPAAMJySG/CgAyAQAPAAMJySG/CgAyAQAuAAQKfxoAAg8ABwmnJIMGAOACAA8ABwmnJIMGAOACAAAA.',
['银骠']='银骠玄解:BAAALgAECgQJBAAAAA==.',
['镁铝']='镁铝猎:BAAALgAECgEJAQAAAA==.',
['阿喵']='阿喵喵:BAAALgADCgIJAgAAAA==.',
['阿武']='阿武:BAAALgAECgYJBwAAAA==.',
['随机']='随机摩卡卡:BAAALgAECgEJAQAAAA==.',
['雨夜']='雨夜我带刀:BAAALgAECgMJAwAAAA==.',
['霸天']='霸天雷:BAAALgADCgEJAQABLgAFFAIJAgARAAAAAA==.',
['飘逸']='飘逸的腿毛:BAAALgAECgQJBQAAAA==.',
['鲜血']='鲜血符文:BAAALgADCgEJAQAAAA==.',
['麻辣']='麻辣香锅牛肉:BAAALgAFFAEJAQAAAA==.',
['黑色']='黑色内酷:BAAALgAECgEJAQAAAA==.',
['黯龍']='黯龍藏乀夔獂:BAAALgAECgQJBAAAAA==.',
['龙湖']='龙湖灬吴彦祖:BAAALgAECgIJAgAAAA==.',
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
