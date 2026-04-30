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

local lookup = {'Monk-Mistweaver','Druid-Balance','Rogue-Subtlety','Unknown-Unknown','Mage-Frost','Warlock-Demonology','Paladin-Retribution','DeathKnight-Unholy','Warlock-Destruction','Evoker-Preservation','Evoker-Augmentation','Priest-Discipline','Priest-Shadow','Priest-Holy','Paladin-Holy','Warrior-Protection','Warrior-Fury','Hunter-Ranged','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','DemonHunter-Havoc','Monk-Brewmaster','Druid-Restoration','Shaman-Restoration',}
local provider = {region='CN',realm='巴瑟拉斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ev='Evangel:BAABLgAFFH8GAAIBAAMJuiAXCQAnAQABAAMJuiAXCQAnAQAAAA==.',
Fo='Foreverwind:BAAALgAECgcJBwAAAA==.',
Ga='Galhad:BAAALgAECgcJBwAAAA==.',
Ha='Hannuoye:BAAALgAECgIJAgAAAA==.',
Im='Immortality:BAAALgAECgEJAQAAAA==.',
Ju='Jubileus:BAAALgAECgYJBgAAAA==.Justin:BAABLgAFFH8HAAICAAIJLCAFEQDKAAACAAIJLCAFEQDKAAAAAA==.Juyt:BAAALgAECgcJBwAAAA==.',
Mc='Mccev:BAAALgAECgUJBgAAAA==.',
Mg='Mglrmglmg:BAAALgADCgQJBAAAAA==.',
Mo='Monk:BAAALgAECgUJBQAAAA==.',
Mp='Mpdwrbtabutf:BAAALgAECgcJDAABLgAFFAQJDgADAPsdAA==.',
My='Mystic:BAAALgAECgMJAwABLgAECgUJBgAEAAAAAA==.',
Ob='Obelix:BAAALgAECgEJAQAAAA==.',
On='Onecallaway:BAAALgAECgEJAwAAAA==.',
Pl='Playerfeukvy:BAAALgAECgMJAwAAAA==.',
Sw='Sweelbbnmb:BAAALgAFFAIJAgAAAA==.',
Ti='Tizen:BAAALgADCgEJAQAAAA==.',
Vi='Virgohunter:BAAALgAECgEJAwAAAA==.',
Yo='Yolwas:BAAALgAECgYJBgAAAA==.',
['一代']='一代一库:BAAALgAECgEJAQAAAA==.',
['一坨']='一坨:BAAALgAECgUJCwAAAA==.',
['一月']='一月五号:BAAALgAECgMJAwAAAA==.',
['一步']='一步禅空:BAAALgADCgEJAQAAAA==.',
['一直']='一直爱睿恩:BAAALgAECgYJCgAAAA==.',
['七尺']='七尺男儿:BAAALgAECgMJBQAAAA==.',
['丈母']='丈母娘复活了:BAAALgAECgYJBwABLgAFFAMJBwAFAJ0PAA==.',
['三天']='三天没洗:BAAALgAECgEJAQAAAA==.',
['三斤']='三斤六两:BAAALgADCgcJBwAAAA==.',
['上台']='上台拿衣服:BAAALgAECgkJEgAAAA==.',
['上尉']='上尉太寿鸠毛:BAAALgADCgQJBAAAAA==.',
['不了']='不了好:BAAALgAECgIJAgAAAA==.',
['不睡']='不睡觉的熠:BAAALgAFFAEJAQAAAA==.',
['东古']='东古诺:BAAALgAECgEJAgAAAA==.',
['严冬']='严冬的鹅卵石:BAAALgAECgUJBQAAAA==.',
['丶诺']='丶诺诺:BAAALgADCgEJAQAAAA==.',
['丹儿']='丹儿:BAAALgADCgUJBQAAAA==.',
['举火']='举火烧天:BAABLgAFFH8FAAIGAAIJbBdALAC+AAAGAAIJbBdALAC+AAAAAA==.',
['乐莲']='乐莲:BAAALgAECgYJBwAAAA==.',
['九个']='九个远方:BAAALgADCgUJBQAAAA==.',
['五岁']='五岁半:BAAALgADCgEJAQAAAA==.',
['交幻']='交幻姬:BAAALgAECgcJCAAAAA==.',
['人王']='人王帝辛:BAAALgADCgMJAwAAAA==.',
['伊利']='伊利丝翠:BAABLgAFFH8GAAIHAAQJeRpUAwBjAQAHAAQJeRpUAwBjAQAAAA==.',
['伊芙']='伊芙丶:BAAALgADCgIJAgAAAA==.',
['伊莉']='伊莉丝翠:BAAALgAECgMJBAAAAA==.',
['伊莎']='伊莎多拉:BAAALgAECgEJAQAAAA==.',
['休闲']='休闲宝宝:BAAALgAFFAIJAgAAAA==.休闲白:BAAALgAFFAEJAQAAAA==.休闲萌:BAAALgAECgQJBAAAAA==.',
['传说']='传说中丶小龙:BAAALgAECgUJBQAAAA==.',
['伯牙']='伯牙绝弦丶:BAAALgAFFAUJBAAAAA==.',
['你这']='你这是病得电:BAAALgAECgYJDAAAAA==.',
['依影']='依影:BAAALgAECgYJDQAAAA==.',
['修纙']='修纙道:BAAALgAECgEJAQAAAA==.',
['偶原']='偶原来不帅:BAAALgAECgYJDgAAAA==.',
['傲月']='傲月残枫:BAAALgAECgEJAgAAAA==.傲月残枫醉:BAAALgAECgYJCwAAAA==.',
['儍德']='儍德尔:BAAALgADCgEJAQAAAA==.',
['兜兜']='兜兜里有根烟:BAAALgAECgUJBgAAAA==.',
['全身']='全身帮帮硬:BAAALgAECgQJBAAAAA==.',
['其疾']='其疾如風:BAAALgAECgYJCQAAAA==.',
['再摸']='再摸鱼就剁手:BAAALgAECgEJAQAAAA==.',
['冰天']='冰天动地:BAACLgAFFH8HAAIFAAIJ+BCgOwC0AAAFAAIJ+BCgOwC0AAAuAAQKfxYAAgUACQnFGD4mANkCAAUACQnFGD4mANkCAAAA.',
['冰爽']='冰爽:BAAALgAECgUJBwAAAA==.',
['凋谢']='凋谢:BAAALgAECgEJAQAAAA==.',
['凯西']='凯西:BAAALgAECgEJAQAAAA==.',
['刀劈']='刀劈长空:BAAALgAECgUJBwAAAA==.',
['勇敢']='勇敢旳牛牛:BAAALgAECgYJCwAAAA==.',
['卡路']='卡路迪亚:BAACLgAFFH8GAAIIAAMJ1A3NKgDwAAAIAAMJ1A3NKgDwAAAuAAQKfxgAAggACAk2GZVDACsCAAgACAk2GZVDACsCAAAA.',
['可莉']='可莉不知道吖:BAAALgAECgMJAwAAAA==.可莉不知道呢:BAAALgAECgYJBgAAAA==.可莉不知道啊:BAAALgAECgMJAgAAAA==.可莉不知道捏:BAAALgAECgIJAgAAAA==.',
['司辰']='司辰:BAAALgAECgYJCwABLgAECgcJCQAEAAAAAA==.',
['咕咕']='咕咕老王:BAAALgAECgEJAQAAAA==.',
['咕猫']='咕猫奶熊:BAAALgADCgcJBAAAAA==.',
['哈基']='哈基米哈基:BAAALgADCgUJDAAAAA==.',
['哈鸡']='哈鸡米:BAAALgAFFAMJAwAAAA==.',
['喜多']='喜多多:BAAALgAECgEJAQAAAA==.',
['嗜血']='嗜血护术宝:BAAALgAECgEJAQAAAA==.',
['四锅']='四锅韭黄:BAAALgAFFAMJAQAAAA==.',
['图拉']='图拉羊:BAAALgAECgMJAwAAAA==.',
['圣光']='圣光染发剂:BAAALgAECgEJAQAAAA==.圣光群殴:BAAALgAECgIJAgAAAA==.',
['塞莉']='塞莉西亚:BAAALgAECgEJAgAAAA==.',
['墨灵']='墨灵:BAAALgAECgYJCQAAAA==.',
['夏小']='夏小沫:BAAALgADCgEJAQAAAA==.',
['夜无']='夜无笙:BAAALgAECgUJBQAAAA==.',
['夜炎']='夜炎:BAAALgAECgQJBAAAAA==.',
['夜神']='夜神君:BAAALgAECgYJCQAAAA==.',
['大榴']='大榴莲:BAAALgADCgMJBwAAAA==.',
['大甜']='大甜梨:BAAALgADCgYJEwAAAA==.',
['天权']='天权:BAABLgAECn8VAAMGAAcJrBmUNgAyAgAGAAcJrBmUNgAyAgAJAAUJdxHgKgAVAQAAAA==.',
['天爙']='天爙劫火:BAAALgAECgMJAwAAAA==.',
['天琁']='天琁:BAAALgAECgUJBQAAAA==.',
['好像']='好像很好玩:BAAALgADCgUJBQAAAA==.',
['好名']='好名字都没啦:BAAALgAECgYJCAAAAA==.',
['妮丫']='妮丫:BAAALgAECgUJBQAAAA==.',
['姬野']='姬野星奏:BAAALgAECgQJBQAAAA==.',
['完辣']='完辣:BAAALgAFFAEJAQAAAA==.',
['宛君']='宛君若在:BAAALgAECgEJAQAAAA==.',
['对不']='对不起我想你:BAAALgAECgEJAQAAAA==.对不起我爱你:BAAALgAECgUJBAAAAA==.',
['小小']='小小福:BAAALgAECgEJAQAAAA==.',
['小废']='小废废丶:BAAALgAECgYJBQAAAA==.',
['小福']='小福狸:BAAALgADCgcJBwABLgAFFAMJCgAKADsaAA==.',
['小糖']='小糖菜:BAAALgAECgUJBwAAAA==.',
['小龙']='小龙吟:BAACLgAFFH8KAAIKAAMJOxp1DQAGAQAKAAMJOxp1DQAGAQAuAAQKfxcAAwsABwnNFxoaAPoBAAsABwnNFxoaAPoBAAoABgl3ElkiAGcBAAAA.',
['尛犬']='尛犬児:BAAALgAECgYJCwAAAA==.',
['就是']='就是这么牛:BAAALgAECgEJAQAAAA==.',
['屁桃']='屁桃:BAAALgAFFAIJAgAAAA==.',
['属七']='属七降十三:BAAALgAECgUJDwAAAA==.',
['左手']='左手之间:BAAALgAECgkJBwAAAA==.',
['幕月']='幕月岚枫:BAAALgAECgQJBAAAAA==.',
['幽酷']='幽酷:BAAALgAFFAIJAwAAAA==.',
['影依']='影依:BAACLgAFFH8MAAIMAAQJwgZfDAAPAQAMAAQJwgZfDAAPAQAuAAQKfyUABAwACAkQE4saAMMBAAwACAkQE4saAMMBAA0ABwmuB3sxAFkBAA4AAwnGDFBnAJAAAAAA.',
['影玄']='影玄风:BAAALgADCgQJBAAAAA==.',
['德川']='德川沐妇:BAAALgAECgEJAQAAAA==.',
['忒龌']='忒龌龊了点儿:BAAALgAECgEJAQAAAA==.',
['忘乎']='忘乎所以:BAABLgAFFH8LAAIIAAQJQwzHHAAvAQAIAAQJQwzHHAAvAQAAAA==.',
['念雪']='念雪慕鸿:BAAALgAFFAIJAwAAAA==.',
['怎么']='怎么拌鸭:BAAALgAFFAIJAgAAAA==.',
['想选']='想选熊猫人:BAAALgAECgUJBQAAAA==.',
['愤怒']='愤怒的猪猪:BAAALgAECgIJAgAAAA==.',
['我可']='我可莉害呐:BAABLgAFFH8FAAIPAAQJ7RruBwBSAQAPAAQJ7RruBwBSAQAAAA==.',
['我来']='我来打小怪:BAAALgAECgEJAQAAAA==.',
['打弓']='打弓崽:BAAALgAECggJCAAAAA==.',
['抹茶']='抹茶麻薯丶:BAAALgAFFAIJAgAAAA==.',
['拾行']='拾行:BAAALgADCgYJBwAAAA==.',
['教主']='教主万紫千橙:BAAALgAFFAIJAgAAAA==.',
['斩真']='斩真死:BAAALgAFFAEJAQAAAA==.斩真狼牙:BAABLgAFFH8LAAMQAAMJ7wWrBAC0AAAQAAMJkwSrBAC0AAARAAIJdAb2GwCXAAAAAA==.斩真豪:BAAALgAFFAIJAwAAAA==.',
['斯灵']='斯灵:BAAALgAECgQJBAAAAA==.',
['无心']='无心无伤:BAAALgAECgIJAgAAAA==.无心无竹:BAAALgAECgIJAgAAAA==.',
['无比']='无比的纠结:BAAALgAFFAIJAwAAAA==.',
['无聊']='无聊的鹌鹑:BAAALgAECgYJDAAAAA==.',
['时光']='时光扭曲:BAAALgAECgMJAwABLgAECgYJDAAEAAAAAA==.',
['星空']='星空灬死骑:BAAALgADCgIJAQAAAA==.',
['是的']='是的没错:BAAALgAECgcJBwAAAA==.',
['暴走']='暴走的芙兰:BAAALgAECgQJCQAAAA==.',
['最爱']='最爱吃兽奶:BAAALgAECgYJDQAAAA==.',
['枫枼']='枫枼:BAACLgAFFH8LAAICAAQJkxoMBQAMAQACAAQJkxoMBQAMAQAuAAQKfx0AAgIABwnOIg0NAMgCAAIABwnOIg0NAMgCAAAA.',
['树欲']='树欲静凨不止:BAABLgAFFH8FAAIHAAQJlg9GDABJAQAHAAQJlg9GDABJAQAAAA==.',
['桃小']='桃小妖夭:BAAALgAECgUJBQAAAA==.',
['桃猎']='桃猎:BAAALgADCgEJAQAAAA==.',
['梦雪']='梦雪璃琪:BAAALgADCgEJAQAAAA==.',
['椰子']='椰子奶冻丶:BAABLgAFFH8FAAISAAUJFhcAAAAAAAATAAUJFhcAAAAAAAAAAA==.',
['武僧']='武僧还魂:BAAALgAECgUJBQAAAA==.',
['武田']='武田信玄:BAAALgAECggJEwAAAA==.',
['残德']='残德灬界静:BAAALgAECgYJCQAAAA==.',
['殷剑']='殷剑平:BAAALgAECgQJBQAAAA==.',
['比狗']='比狗强一点:BAAALgAECgEJAQAAAA==.比狗还要菜:BAAALgAECgcJBwAAAA==.',
['永恒']='永恒封冰:BAAALgAFFAIJAwAAAA==.',
['汹涌']='汹涌的烧酒:BAAALgADCgUJBQAAAA==.',
['法丝']='法丝洛洛:BAAALgADCgMJAwAAAA==.',
['浮云']='浮云骑神马:BAAALgAFFAIJAwAAAA==.',
['浮生']='浮生未歇:BAAALgADCgUJBQAAAA==.',
['混世']='混世浮屠:BAAALgAECgQJBAAAAA==.',
['清川']='清川:BAAALgAECgEJAQAAAA==.',
['清风']='清风玲音:BAAALgAECgYJBAAAAA==.',
['湮灭']='湮灭:BAAALgAECgUJBQAAAA==.',
['漂夜']='漂夜以落:BAAALgADCgEJAgAAAA==.',
['灼眼']='灼眼的夏娜:BAAALgADCgMJAwAAAA==.',
['炉石']='炉石萌新别打:BAABLgAFFH8GAAIHAAIJkh4mGwDGAAAHAAIJkh4mGwDGAAAAAA==.',
['烟丶']='烟丶瘾:BAAALgAECgEJAQAAAA==.',
['热血']='热血奶爸:BAAALgADCgEJAQABLgAFFAIJAgAEAAAAAA==.',
['爆浆']='爆浆麻薯:BAAALgAECgUJBgAAAA==.',
['爱在']='爱在双刀前:BAAALgAECgQJBAAAAA==.',
['爱憎']='爱憎的罗克珊:BAAALgAECgMJBAAAAA==.',
['爱我']='爱我的昆:BAABLgAFFH8FAAIIAAIJxgjORgCWAAAIAAIJxgjORgCWAAAAAA==.',
['爱美']='爱美女的菠萝:BAABLgAFFH8LAAMTAAMJkg1oCAACAQATAAMJkg1oCAACAQAUAAMJEwohFwDgAAAAAA==.',
['狂龍']='狂龍:BAAALgAECgMJBgAAAA==.',
['狮子']='狮子座流星:BAAALgAECgQJCAAAAA==.',
['猎祖']='猎祖猎宗:BAAALgAFFAEJAQAAAA==.',
['猫空']='猫空之城:BAAALgAECgMJAwAAAA==.',
['王天']='王天泉:BAABLgAECn8UAAIMAAcJOSESCgCYAgAMAAcJOSESCgCYAgAAAA==.',
['玛丽']='玛丽罗斯:BAABLgAFFH8FAAIVAAQJ9geoCQDrAAAVAAQJ9geoCQDrAAAAAA==.',
['生椰']='生椰拿铁丶:BAABLgAFFH8FAAISAAUJlhUAAAAAAAATAAUJlhUAAAAAAAAAAA==.',
['疯狂']='疯狂丶菠菜籽:BAAALgAECgUJBgAAAA==.疯狂的丫头:BAAALgAECgEJAQAAAA==.',
['白家']='白家美小妞:BAAALgADCgEJAQAAAA==.',
['白巽']='白巽羽:BAAALgAECgEJAQAAAA==.',
['白衣']='白衣未央:BAAALgAECggJAgAAAA==.',
['盐汽']='盐汽水的威力:BAAALgADCgcJBwAAAA==.',
['盛夏']='盛夏之夜:BAAALgADCgIJAgAAAA==.',
['睡不']='睡不醒的撒旦:BAAALgAECgQJBAAAAA==.',
['睿恩']='睿恩不要怕:BAAALgAECgQJBAAAAA==.',
['矜持']='矜持丶先森:BAAALgAECgYJDQAAAA==.',
['破哥']='破哥:BAAALgAECgIJAgAAAA==.',
['破鲁']='破鲁尔法:BAAALgAECgcJDQAAAA==.',
['神奇']='神奇的德哥:BAAALgADCgEJAQAAAA==.',
['神锋']='神锋无影:BAABLgAECn8ZAAIHAAcJOyKNHgC0AgAHAAcJOyKNHgC0AgAAAA==.',
['秋月']='秋月续琴心:BAAALgAECgUJCgAAAA==.',
['稥楓']='稥楓丶智乃:BAAALgAECgQJBQAAAA==.',
['笨笨']='笨笨丶有块糖:BAAALgAECgUJBQAAAA==.',
['等风']='等风来:BAAALgAECgUJBgAAAA==.',
['筱凌']='筱凌儿:BAACLgAFFH8LAAIOAAQJxg0ABgAfAQAOAAQJxg0ABgAfAQAuAAQKfxkAAg4ACAn9GHAUADoCAA4ACAn9GHAUADoCAAAA.',
['简单']='简单旋律:BAAALgAECgUJDwAAAA==.',
['糖果']='糖果小妮子:BAAALgADCgEJAQAAAA==.',
['紗夏']='紗夏:BAAALgAFFAIJAwAAAA==.',
['紫祺']='紫祺:BAAALgAECgYJBgAAAA==.',
['紫色']='紫色棉花糖:BAAALgAECgEJAQAAAA==.',
['絶蝂']='絶蝂锋少:BAAALgAFFAIJAgAAAA==.',
['纯爱']='纯爱战神:BAAALgADCgUJBQAAAA==.',
['纯真']='纯真丁一郎:BAAALgADCgEJAQAAAA==.',
['给力']='给力有木有:BAABLgAFFH8LAAIIAAQJkRW4FQBNAQAIAAQJkRW4FQBNAQAAAA==.',
['给色']='给色个:BAAALgADCgMJAwAAAA==.',
['缺德']='缺德:BAAALgAECgYJBgABLgAECgYJDAAEAAAAAA==.',
['老司']='老司机的阴谋:BAABLgAFFH8GAAIUAAMJ3BPGFAD3AAAUAAMJ3BPGFAD3AAAAAA==.',
['老牛']='老牛在腰間:BAAALgADCgYJBgAAAA==.',
['老衲']='老衲擅解人衣:BAAALgADCgUJBQAAAA==.',
['肥肉']='肥肉减伤:BAAALgADCgYJBgAAAA==.',
['背叛']='背叛:BAAALgAECgQJAgAAAA==.',
['花花']='花花:BAAALgAECgEJAQAAAA==.',
['苦逼']='苦逼的他:BAABLgAFFH8FAAIRAAMJrw/0CAC1AAARAAMJrw/0CAC1AAAAAA==.',
['茉莉']='茉莉绿雪丶:BAAALgAECgkJBwAAAA==.',
['萌萌']='萌萌小宝宝:BAAALgAFFAIJBAAAAA==.',
['葳蕤']='葳蕤自生光:BAAALgAECgIJAQAAAA==.',
['薩菲']='薩菲羅斯丶:BAABLgAECn8UAAIWAAcJUx01DwBwAgAWAAcJUx01DwBwAgAAAA==.',
['虚妄']='虚妄:BAAALgAFFAMJAwAAAA==.',
['蜀道']='蜀道山:BAAALgAECgQJBAAAAA==.',
['蜜桃']='蜜桃乌龙丶:BAAALgAFFAMJAwAAAA==.',
['蜡笔']='蜡笔丨小刚:BAABLgAFFH8FAAIFAAIJuQJPSwCPAAAFAAIJuQJPSwCPAAAAAA==.蜡笔丨小新:BAABLgAFFH8GAAIXAAIJMANcIQBrAAAXAAIJMANcIQBrAAAAAA==.蜡笔丨小旧:BAAALgAECgYJCAAAAA==.蜡笔丨小牧:BAAALgAECgIJAwAAAA==.蜡笔丨小猎:BAAALgAECgQJBAAAAA==.',
['血色']='血色灰壗:BAAALgAFFAIJBAAAAA==.',
['裂指']='裂指:BAAALgAECgIJAgAAAA==.',
['西瓜']='西瓜啵啵丶:BAAALgAECgkJBwAAAA==.',
['要死']='要死仍活:BAAALgAECgEJAQAAAA==.',
['谁爱']='谁爱上你的醉:BAAALgADCgYJCwAAAA==.',
['调皮']='调皮的小饼干:BAAALgAECgYJCAAAAA==.',
['谷鸽']='谷鸽:BAAALgAFFAMJBAABLgAFFAUJFQAYAJAXAA==.',
['贞德']='贞德:BAAALgADCgIJAgAAAA==.',
['超级']='超级牛魔王:BAAALgAECgYJCQAAAA==.',
['越祁']='越祁:BAAALgAECgEJAQAAAA==.',
['蹦嚓']='蹦嚓蹦嚓:BAAALgAECgQJBAAAAA==.',
['远古']='远古巨龙:BAAALgADCgUJDQAAAA==.',
['迷雾']='迷雾:BAAALgADCgEJAQAAAA==.',
['逍遥']='逍遥珑珠:BAAALgAECgEJAQAAAA==.',
['遗忘']='遗忘的白开水:BAABLgAFFH8FAAIIAAMJpAybQACfAAAIAAMJpAybQACfAAAAAA==.',
['那个']='那个劣仁:BAAALgAECgEJAQAAAA==.',
['邪正']='邪正人鬼:BAAALgAECgkJCgABLgAFFAUJFAAVAJoaAA==.',
['酒剑']='酒剑仙:BAAALgADCgEJAQAAAA==.',
['酸萝']='酸萝卜丶别吃:BAAALgAECgYJBgAAAA==.',
['野生']='野生丶凹凸曼:BAAALgADCgEJAQAAAA==.',
['鎻定']='鎻定:BAAALgAECgEJAQAAAA==.',
['银河']='银河星尘:BAAALgAECgEJAQAAAA==.',
['键来']='键来:BAAALgAECgEJAQAAAA==.',
['阿可']='阿可蒙德之眼:BAAALgAECgQJBAAAAA==.',
['阿尔']='阿尔托筣亚:BAAALgAECgEJAQAAAA==.',
['阿爾']='阿爾托麗雅:BAAALgAECgUJCQAAAA==.',
['阿狸']='阿狸爱吃鸡:BAAALgAECgcJCAAAAA==.',
['陆江']='陆江仙:BAAALgAECgEJAgAAAA==.',
['雪夜']='雪夜寒枫:BAAALgAECgMJAwAAAA==.',
['雪梅']='雪梅花:BAAALgADCgEJAQAAAA==.',
['雪舞']='雪舞依:BAAALgAECgUJBQAAAA==.',
['雷霆']='雷霆嘎嘎:BAAALgAECgEJAQAAAA==.',
['青提']='青提茉莉丶:BAAALgAFFAQJBAAAAA==.',
['静修']='静修之猎刃:BAAALgAFFAEJAQAAAA==.',
['静谧']='静谧之手:BAAALgAECgcJBwAAAA==.',
['面摊']='面摊老板:BAABLgAFFH8IAAIQAAQJfhSjBAAyAQAQAAQJfhSjBAAyAQAAAA==.',
['風主']='風主霜城:BAAALgAECgcJBwAAAA==.',
['风之']='风之悠贤:BAAALgAFFAMJBAAAAA==.',
['风白']='风白羽:BAAALgADCgYJBgAAAA==.',
['馒头']='馒头泡:BAAALgAECgYJCwAAAA==.',
['香蕉']='香蕉柠檬桔:BAAALgAECgcJCgAAAA==.',
['驯狐']='驯狐师:BAAALgAFFAEJAQAAAA==.',
['骑墙']='骑墙看戏:BAAALgAECgcJEwAAAA==.',
['鬼怪']='鬼怪魔妖:BAAALgAECgIJAgAAAA==.',
['魂淡']='魂淡儿:BAAALgADCgMJAwAAAA==.',
['魔兽']='魔兽拽拽神爷:BAAALgAECgkJCQAAAA==.',
['鹤仙']='鹤仙问鹿仙:BAABLgAECn8UAAIZAAcJ5Rk9MgC9AQAZAAcJ5Rk9MgC9AQAAAA==.',
['鹿茸']='鹿茸小绷带:BAAALgAECgYJCQAAAA==.',
['麒耀']='麒耀黑锋:BAAALgAECgkJCgAAAA==.',
['黑丶']='黑丶牛:BAACLgAFFH8GAAICAAQJ2wlxFwCDAAACAAQJ2wlxFwCDAAAuAAQKfxQAAgIABgnYE143AFwBAAIABgnYE143AFwBAAAA.',
['黑墩']='黑墩墩:BAAALgAECgIJAgAAAA==.',
['黑夜']='黑夜笙歌:BAAALgAECgUJDAAAAA==.',
['黑骑']='黑骑也风骚:BAAALgAFFAMJAwAAAA==.',
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
