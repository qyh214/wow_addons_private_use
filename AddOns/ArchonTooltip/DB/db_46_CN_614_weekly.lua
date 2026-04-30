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

local lookup = {'Warlock-Demonology','Warlock-Destruction','Shaman-Elemental','Shaman-Restoration','Unknown-Unknown','Monk-Mistweaver','Paladin-Holy','Paladin-Any','Paladin-Retribution','Warrior-Fury','Warrior-Arms','Warrior-Protection','Priest-Holy','Priest-Shadow','Priest-Discipline','Evoker-Preservation','Evoker-Augmentation','DeathKnight-Unholy','Mage-Frost','DeathKnight-Blood','Evoker-Devastation',}
local provider = {region='CN',realm='地狱之石',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Agreas:BAAALgAECgEJAQAAAA==.',
Am='Amerie:BAAALgADCgEJAQAAAA==.',
Ao='Aogutala:BAAALgAFFAMJAwAAAA==.',
Bo='Bottleln:BAACLgAFFH8KAAIBAAMJbSNJFwA2AQABAAMJbSNJFwA2AQAuAAQKfyIAAwEACAnrJWwMABcDAAEACAnaJWwMABcDAAIABAmTJMMWAJQBAAAA.',
Ca='Caoguiruisb:BAAALgAECgcJBwAAAA==.',
Co='Colorful:BAAALgAECgQJBAAAAA==.',
De='Decondestiny:BAABLgAECn8fAAIBAAcJ8CM5FgDQAgABAAcJ8CM5FgDQAgAAAA==.',
Ev='Evil:BAAALgAECgYJDgAAAA==.',
Ey='Eyven:BAAALgAECgYJBgAAAA==.',
Ki='Kiwi:BAAALgAECgMJAwAAAA==.',
La='Lala:BAAALgAFFAEJAQAAAA==.',
Mo='Momomua:BAAALgAECgcJEAAAAA==.',
Re='Reda:BAAALgAECgYJCQAAAA==.',
Sh='Shersonw:BAAALgAECgEJAQAAAA==.',
To='Toread:BAAALgAECgYJDgAAAA==.',
['七丁']='七丁念佛:BAAALgAECgEJAQAAAA==.',
['丨阿']='丨阿尒萨斯丨:BAAALgAECgIJAgAAAA==.',
['丰川']='丰川祥子:BAAALgAECgYJCgAAAA==.',
['临渊']='临渊:BAAALgAECgQJAwAAAA==.',
['丶鲁']='丶鲁鲁丨:BAAALgADCgEJAQAAAA==.',
['丿一']='丿一丨丶:BAAALgADCgIJAgAAAA==.',
['乐坛']='乐坛永远的神:BAAALgAFFAIJAwAAAA==.',
['九寒']='九寒丶:BAAALgAECgkJEgAAAA==.',
['伊利']='伊利丹小怪:BAAALgAECgYJBgAAAA==.',
['偷看']='偷看你:BAAALgADCgEJAQAAAA==.',
['像风']='像风一样:BAAALgAFFAEJAQAAAA==.',
['元龙']='元龙战魂:BAAALgAFFAEJAQAAAA==.',
['克兰']='克兰蒂尔:BAAALgAECgcJDAAAAA==.',
['凯瑟']='凯瑟琳娜:BAAALgAECgcJEAAAAA==.',
['凶梦']='凶梦的残影:BAABLgAFFH8GAAMDAAIJBwkrGACVAAADAAIJBwkrGACVAAAEAAIJVgQgHACHAAAAAA==.',
['凸六']='凸六六:BAAALgADCgEJAQAAAA==.',
['刘戒']='刘戒葎:BAAALgAECgIJAgAAAA==.',
['南石']='南石哥哥:BAAALgAECgIJAgAAAA==.',
['取星']='取星河为礼:BAAALgAECgcJBwAAAA==.',
['只拉']='只拉怪不拉风:BAAALgAECgYJDAAAAA==.',
['吃我']='吃我劈头灵:BAAALgAECgcJDAAAAA==.',
['咪哥']='咪哥:BAAALgAECgcJEAAAAA==.',
['哥很']='哥很淡定:BAAALgAECgcJBQAAAA==.',
['唐三']='唐三葬:BAAALgAECgQJBAAAAA==.',
['回复']='回复术:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光伽蓝:BAAALgAECgQJBAAAAA==.',
['地狱']='地狱一咆哮:BAAALgAECgIJAgAAAA==.',
['壹命']='壹命不凡:BAAALgAECgEJAQAAAA==.',
['壹月']='壹月:BAAALgAECgUJBQAAAA==.',
['夏季']='夏季的惆怅:BAAALgAECgYJDwAAAA==.',
['夙渊']='夙渊情缘:BAAALgAECgQJBQAAAA==.',
['夜殇']='夜殇丶幻灭:BAAALgADCgYJBgAAAA==.',
['大元']='大元帅:BAAALgAECgEJAgAAAA==.',
['大灰']='大灰大灰:BAAALgAECgkJBAABLgAFFAUJAgAFAAAAAA==.',
['奈蒂']='奈蒂莉:BAAALgAECgQJBAAAAA==.',
['孙小']='孙小静丶:BAAALgADCgUJBQAAAA==.',
['孙舞']='孙舞空:BAAALgAECgQJBAAAAA==.',
['宁小']='宁小闲:BAACLgAFFH8PAAIGAAYJvyKkAAAHAgAGAAYJvyKkAAAHAgAuAAQKfxwAAgYACAlHI7ADADwDAAYACAlHI7ADADwDAAEuAAUUBAkJAAcAcB0A.',
['宫野']='宫野志保:BAAALgAECgcJBgABLgAFFAcJBgAIANsXAA==.',
['寒雨']='寒雨紫烟:BAAALgAECgYJBgAAAA==.',
['小坏']='小坏狼:BAAALgADCgEJAQAAAA==.',
['小小']='小小猎试玩:BAAALgAECgYJDgAAAA==.小小萌新:BAAALgADCgQJBAAAAA==.',
['小火']='小火车王来喽:BAAALgAECgEJAQAAAA==.',
['小聋']='小聋女丶:BAAALgAECgYJBgABLgAFFAQJCAAJAJEaAA==.',
['小黑']='小黑孩儿:BAAALgAECgQJBQAAAA==.',
['岑卿']='岑卿吖:BAAALgADCgEJAQAAAA==.',
['巨鲨']='巨鲨天王:BAAALgAECgcJBwAAAA==.',
['巴德']='巴德洛:BAAALgAFFAEJBAAAAA==.',
['帝道']='帝道赤霄:BAABLgAECn8bAAIJAAcJ7xQbYQDBAQAJAAcJ7xQbYQDBAQAAAA==.',
['幸福']='幸福的小霸王:BAACLgAFFH8IAAIKAAMJoxiZEAACAQAKAAMJoxiZEAACAQAuAAQKfyMABAoACAncHAsQANICAAoACAncHAsQANICAAsAAwkmEPEkAMUAAAwAAQkAABdNACMAAAAA.',
['张之']='张之维:BAAALgAECgQJBAAAAA==.',
['张敏']='张敏:BAABLgAECn8VAAIDAAgJYR0BBwCYAQADAAgJYR0BBwCYAQAAAA==.',
['张爱']='张爱闫爱张:BAAALgAECgEJAQAAAA==.',
['德伊']='德伊鲁:BAAALgAECgYJDwAAAA==.',
['悯瑟']='悯瑟圣光:BAAALgAFFAIJAgAAAA==.',
['我救']='我救个毛啊:BAAALgADCgEJAQAAAA==.',
['我是']='我是喵大人:BAABLgAFFH8IAAIBAAMJwAmDJwDdAAABAAMJwAmDJwDdAAAAAA==.',
['我这']='我这小红手:BAAALgAECgIJAgAAAA==.',
['把酒']='把酒成疯:BAAALgAECgUJCwAAAA==.',
['摩根']='摩根勒菲:BAAALgAECgQJBgAAAA==.',
['支支']='支支:BAAALgAECgYJCAAAAA==.',
['无畏']='无畏勇士:BAABLgAFFH8FAAIKAAMJKwRdFADOAAAKAAMJKwRdFADOAAAAAA==.',
['星星']='星星亮了:BAAALgAECgMJAwAAAA==.',
['暖宝']='暖宝宝:BAABLgAECn8UAAIEAAcJhQ7sQAB9AQAEAAcJhQ7sQAB9AQAAAA==.',
['暗影']='暗影炎魔:BAAALgAECgMJAwAAAA==.',
['暴躁']='暴躁的小龙人:BAAALgADCgYJBgAAAA==.',
['暴风']='暴风的愿望:BAAALgADCgMJBAAAAA==.',
['最爱']='最爱飞飞:BAAALgAECgQJBAAAAA==.',
['杀噫']='杀噫来袭:BAAALgAECgUJBwAAAA==.',
['极地']='极地灬血骑士:BAAALgAECgEJBAAAAA==.',
['析木']='析木林语:BAAALgAECgIJAgAAAA==.',
['梅坎']='梅坎特隆:BAAALgAECgIJAgAAAA==.',
['楠丶']='楠丶阿萨斯:BAAALgAFFAEJAQAAAA==.',
['樱桃']='樱桃泡泡:BAAALgADCgEJAQAAAA==.',
['橘枝']='橘枝:BAAALgAFFAIJAgAAAA==.',
['橘织']='橘织:BAAALgAECgUJAwAAAA==.',
['橙噔']='橙噔噔:BAAALgADCgcJBwAAAA==.',
['欣有']='欣有萌虎:BAAALgAECgkJEQAAAA==.',
['欧德']='欧德曼:BAAALgAECgYJBgAAAA==.',
['永恒']='永恒的风行者:BAAALgADCgcJBwAAAA==.',
['沁白']='沁白灬昨天:BAABLgAECn8VAAQNAAkJaxNkMQB7AQANAAYJxRhkMQB7AQAOAAgJqAeJLgBtAQAPAAQJMA8VPwC2AAAAAA==.',
['油爆']='油爆大虾:BAABLgAFFH8MAAMQAAQJSRJfDgDxAAAQAAQJSRJfDgDxAAARAAMJIwv0EgDnAAAAAA==.',
['波西']='波西:BAAALgAECgEJAQAAAA==.',
['泰蕾']='泰蕾兹:BAAALgADCgYJBgAAAA==.',
['泰雷']='泰雷苟萨:BAAALgAECgMJBQAAAA==.',
['浓缩']='浓缩蓝鲸:BAAALgAECgEJAQAAAA==.',
['淡淡']='淡淡的红色:BAAALgADCgYJAQAAAA==.淡淡的蓝色:BAAALgAECgYJBgAAAA==.',
['深汝']='深汝浅出:BAAALgAECgEJAgAAAA==.',
['源秀']='源秀一:BAACLgAFFH8IAAISAAMJVSDUHgAiAQASAAMJVSDUHgAiAQAuAAQKfxUAAhIABgnxJMYvAHkCABIABgnxJMYvAHkCAAAA.',
['火车']='火车王给我冲:BAAALgAFFAIJAwAAAA==.',
['灬莫']='灬莫娜灬:BAAALgAECgEJAQAAAA==.',
['灰暗']='灰暗凝视:BAAALgAECgMJAwAAAA==.',
['烟火']='烟火里的尘埃:BAAALgAECgEJAQAAAA==.',
['爱情']='爱情的模样:BAAALgAECgEJAgAAAA==.',
['爻老']='爻老五爻:BAAALgAECgEJAgAAAA==.',
['牛奶']='牛奶咖啡先生:BAAALgAECgUJBQAAAA==.',
['牛森']='牛森森:BAAALgAECgYJCwAAAA==.',
['犯二']='犯二小火烧:BAAALgADCgEJAQAAAA==.',
['玛露']='玛露希尔:BAACLgAFFH8KAAITAAMJVSaTHwBKAQATAAMJVSaTHwBKAQAuAAQKfyIAAhMACAl9JGYcAAQDABMACAl9JGYcAAQDAAAA.',
['琦玉']='琦玉老师:BAAALgAECgQJBQAAAA==.',
['甩你']='甩你一大坨:BAAALgADCgEJAQAAAA==.',
['盐酸']='盐酸小檗碱:BAAALgAECgYJDgAAAA==.',
['真冬']='真冬之雪:BAABLgAFFH8IAAIUAAUJQxOpAwAMAQAUAAUJQxOpAwAMAQAAAA==.',
['真希']='真希波:BAAALgADCgYJBgAAAA==.',
['睡不']='睡不醒的喵:BAAALgAECgYJCQAAAA==.',
['破坏']='破坏天神:BAAALgAECgcJCgAAAA==.破坏月神:BAAALgAECgQJBQAAAA==.破坏猎神:BAAALgAECgEJAQAAAA==.',
['神仙']='神仙石头:BAAALgADCgkJDwAAAA==.',
['神圣']='神圣小西瓜:BAAALgAECgUJBQAAAA==.',
['神龙']='神龙斗士:BAAALgADCgUJBQAAAA==.',
['秩序']='秩序兵刃:BAAALgAECgQJBAAAAA==.',
['空訫']='空訫糖果丶:BAABLgAECn8UAAIJAAcJuSOtIACpAgAJAAcJuSOtIACpAgAAAA==.',
['精灵']='精灵男:BAAALgAECgEJAQAAAA==.',
['绫清']='绫清竹:BAAALgAECgUJBQAAAA==.',
['翅膀']='翅膀下的灵魂:BAAALgAECgYJBgAAAA==.',
['老铁']='老铁六溜溜:BAAALgAECgYJBwAAAA==.',
['聆听']='聆听雨声:BAAALgAECgQJCgAAAA==.',
['聆夜']='聆夜:BAAALgAECggJDwAAAA==.',
['膨润']='膨润土猫砂:BAACLgAFFH8GAAIRAAMJBhwQEAACAQARAAMJBhwQEAACAQAuAAQKfyIAAxEACAmmIcoKAMkCABEACAmmIcoKAMkCABAAAQmkAxlHADoAAAAA.',
['舒肤']='舒肤佳香皂:BAAALgAECgQJCgAAAA==.',
['蓝白']='蓝白双马尾丶:BAAALgAECgIJAgAAAA==.',
['蓝色']='蓝色雪:BAAALgAECgEJAQAAAA==.',
['蕾姆']='蕾姆蕾姆:BAAALgAECgQJBAAAAA==.',
['螃蟹']='螃蟹宝宝:BAAALgADCgEJAQAAAA==.',
['血契']='血契旋风:BAAALgADCgUJBQAAAA==.血契猎心:BAAALgADCgYJBgAAAA==.',
['血骑']='血骑:BAAALgAECgUJCgAAAA==.',
['衣以']='衣以候丶:BAAALgAECgEJAQABLgAECgYJBgAFAAAAAA==.',
['西出']='西出玉菛:BAAALgAECgEJAQAAAA==.西出玉门:BAAALgAECgEJAQAAAA==.',
['誓约']='誓约之剑:BAAALgAECgYJDgAAAA==.',
['譕法']='譕法譕天:BAAALgADCgEJAQAAAA==.',
['诺斯']='诺斯莉:BAAALgAECgYJCgAAAA==.',
['谛听']='谛听丶:BAAALgAECgIJAwAAAA==.',
['贝尔']='贝尔蒙多:BAAALgAECgYJBwAAAA==.',
['贝恩']='贝恩血蹄:BAAALgADCgEJAQAAAA==.',
['贫僧']='贫僧劫个色:BAAALgAFFAIJAgAAAA==.',
['贰非']='贰非:BAACLgAFFH8IAAMRAAMJ5g6KEgDrAAARAAMJow6KEgDrAAAVAAEJCxl4CABcAAAuAAQKfyMAAxEACAlGHLEXABYCABEABwkIG7EXABYCABUABgmKGvsTAKYBAAAA.',
['超音']='超音速索尼克:BAAALgAECgIJAgAAAA==.',
['轩辕']='轩辕没文化:BAAALgAECgEJAQAAAA==.轩辕血女啊:BAAALgAECgYJCgAAAA==.轩辕雪女:BAAALgAECgYJBgAAAA==.',
['逐风']='逐风之语:BAAALgAECgEJAQAAAA==.',
['道格']='道格拉斯:BAAALgAECgcJDAAAAA==.',
['邪马']='邪马人:BAAALgAECgEJAgAAAA==.',
['醉倚']='醉倚樓聼風雨:BAAALgAECgQJBQAAAA==.',
['钉崎']='钉崎野蔷薇:BAAALgAECgUJBQAAAA==.',
['间歇']='间歇清醒:BAAALgAECgEJAQAAAA==.',
['阿修']='阿修斯:BAAALgAECgEJAQAAAA==.',
['阿克']='阿克曼:BAAALgAECgEJAQAAAA==.',
['陆玲']='陆玲珑:BAAALgAECgUJCgAAAA==.',
['雅达']='雅达干:BAAALgAECgYJCQAAAA==.',
['雨殇']='雨殇:BAAALgAECgYJCgAAAA==.',
['雷索']='雷索:BAAALgAECgcJBwAAAA==.',
['风吹']='风吹云飞:BAAALgADCgQJBAAAAA==.',
['风带']='风带走了什么:BAACLgAFFH8IAAITAAMJXgp/LwD4AAATAAMJXgp/LwD4AAAuAAQKfyMAAhMACAnNGBNHAGICABMACAnNGBNHAGICAAAA.',
['风暴']='风暴使者:BAAALgAECgkJBwAAAA==.风暴烈酒丨陈:BAAALgAECgUJBgAAAA==.',
['饮血']='饮血机:BAAALgADCgEJAQAAAA==.',
['骑师']='骑师傅:BAAALgAECgIJBQAAAA==.',
['鬼脚']='鬼脚七:BAAALgAECgEJAQAAAA==.',
['黑色']='黑色灵柩:BAAALgAECgYJCQAAAA==.',
['默念']='默念丶爱:BAAALgAECgUJCQAAAA==.',
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
