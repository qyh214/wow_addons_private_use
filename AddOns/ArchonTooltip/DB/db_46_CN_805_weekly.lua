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

local lookup = {'Paladin-Retribution','DemonHunter-Devourer','Unknown-Unknown','Evoker-Preservation','Evoker-Augmentation','Mage-Frost','Druid-Balance','Druid-Guardian','Rogue-Subtlety','Warrior-Protection','Warlock-Demonology','Warlock-Affliction','Shaman-Restoration','Shaman-Elemental','Druid-Restoration','Priest-Shadow','Priest-Discipline','DemonHunter-Havoc','DeathKnight-Unholy','Monk-Brewmaster','Mage-Arcane','Evoker-Devastation','Paladin-Holy','Paladin-Protection','Mage-Fire','Priest-Holy','Warlock-Destruction','Monk-Mistweaver','DemonHunter-Vengeance','Hunter-BeastMastery',}
local provider = {region='CN',realm='芬里斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ar='Arisy:BAAALgAECgMJAwAAAA==.',
As='Aspirit:BAAALgAFFAIJAgAAAA==.',
Be='Beyonding:BAAALgAFFAEJAQAAAA==.',
Bl='Blackforest:BAABLgAFFH8GAAIBAAYJ5ReDAADSAQABAAYJ5ReDAADSAQAAAA==.Blacktemplar:BAAALgAECgYJBgAAAA==.Blws:BAAALgADCgIJAgAAAA==.Blxd:BAAALgADCgYJBgAAAA==.',
Ca='Calliope:BAAALgAECgQJBgAAAA==.',
Ch='Chenxi:BAAALgADCgMJAwAAAA==.',
Da='Darknight:BAAALgAFFAIJAgAAAA==.',
De='Deathspectre:BAAALgAECgQJBAAAAA==.Deepsoul:BAAALgAECgEJAQAAAA==.Devilmaycry:BAAALgAECggJDAAAAA==.',
Du='Dumplings:BAAALgAECgYJCQAAAA==.',
Fl='Flamingblade:BAABLgAFFH8FAAICAAIJoRq0GAChAAACAAIJoRq0GAChAAAAAA==.',
Gi='Giraffe:BAAALgAECgYJCAABLgAFFAEJAQADAAAAAA==.',
Gl='Glaty:BAAALgAECgYJBgAAAA==.',
Ho='Hotpp:BAAALgAECgYJCAAAAA==.',
Ja='Jackylonely:BAAALgAECgcJCgAAAA==.',
Ki='Kissy:BAAALgAECgYJBgAAAA==.',
La='Ladderfour:BAAALgAECgYJDAAAAA==.',
Le='Leokii:BAABLgAFFH8OAAMEAAUJ3CPdAQAVAgAEAAUJ3CPdAQAVAgAFAAUJMxksBQCxAQAAAA==.',
Mi='Mibous:BAAALgAECgMJAwAAAA==.Mino:BAAALgADCgEJAQAAAA==.',
Mj='Mjdd:BAAALgAFFAMJAwAAAA==.',
Ne='Nelly:BAABLgAECn8bAAIGAAgJABeNUgBAAgAGAAgJABeNUgBAAgAAAA==.',
Ol='Olin:BAAALgAFFAEJAQAAAA==.Olinmye:BAAALgAECgEJAQAAAA==.',
Ph='Phobos:BAAALgAFFAIJAgAAAA==.',
Re='Redback:BAAALgAECgEJAQAAAA==.',
Sh='Shmily:BAAALgAECgEJAQAAAA==.',
St='Stefaniesun:BAAALgAECgYJDgAAAA==.',
Su='Suge:BAACLgAFFH8HAAICAAMJTxKBEgDkAAACAAMJTxKBEgDkAAAuAAQKfxcAAgIACAnPHP8WAMwCAAIACAnPHP8WAMwCAAAA.Superdruid:BAABLgAECn8bAAMHAAgJOSQkBgA3AwAHAAgJOSQkBgA3AwAIAAEJfyHuDQBfAAAAAA==.',
Sy='Sylvanaas:BAAALgAECgEJAQAAAA==.',
Tx='Txrupservxaf:BAACLgAFFH8GAAIJAAQJbxMGCABnAQAJAAQJbxMGCABnAQAuAAQKfx8AAgkACQlaG2YRAJUCAAkACQlaG2YRAJUCAAAA.',
Un='Undestroy:BAABLgAECn8ZAAIKAAgJoAyHGQCFAQAKAAgJoAyHGQCFAQAAAA==.',
Ve='Vemage:BAABLgAFFH8JAAIGAAQJ+xKkCgBeAQAGAAQJ+xKkCgBeAQAAAA==.',
Zh='Zhutoro:BAAALgAECgYJBgAAAA==.',
['一囤']='一囤乱搞:BAAALgAECgEJAgAAAA==.',
['一摸']='一摸姬:BAAALgAECgUJBQAAAA==.',
['一百']='一百块都不给:BAAALgAECgYJBgAAAA==.',
['一见']='一见晨曦:BAAALgAECgQJBgAAAA==.一见繁星:BAAALgAECgMJAwAAAA==.',
['一队']='一队小猎:BAAALgADCgEJAQAAAA==.一队武僧:BAAALgAECgYJDgAAAA==.',
['不乛']='不乛晓得:BAAALgAECgYJBgAAAA==.',
['不学']='不学无术丶:BAAALgADCgYJCAAAAA==.',
['丘处']='丘处机:BAAALgADCgEJAQAAAA==.',
['丶墨']='丶墨绿:BAAALgAECgkJAQABLgAFFAcJDQAEANggAA==.',
['丶米']='丶米米:BAAALgAECgYJBwAAAA==.',
['丶零']='丶零點点:BAAALgAECgQJBAAAAA==.',
['丶饭']='丶饭饭:BAAALgAECgYJDAAAAA==.',
['丶骑']='丶骑士之殇:BAAALgAECgcJBwAAAA==.',
['丷米']='丷米饭:BAAALgADCggJCAAAAA==.',
['乱太']='乱太郎:BAAALgAECgEJAQAAAA==.',
['二五']='二五年的滚滚:BAAALgAECgUJBQAAAA==.',
['二条']='二条园子:BAABLgAECn8UAAMLAAgJcBAITwDbAQALAAgJcBAITwDbAQAMAAEJAABEMwA3AAAAAA==.',
['二相']='二相乐园:BAAALgADCgUJBQAAAA==.',
['亡冥']='亡冥之骑:BAAALgAECggJDgAAAA==.',
['人可']='人可擎天:BAAALgAFFAEJAQAAAA==.',
['仁智']='仁智勇:BAAALgADCgQJBAAAAA==.',
['今戈']='今戈:BAAALgAFFAEJAQAAAA==.',
['价值']='价值时光:BAAALgADCgQJAQAAAA==.',
['众淼']='众淼竞技灬僧:BAAALgAECgYJCQAAAA==.众淼竞技灬圣:BAAALgAECgUJBgAAAA==.',
['会游']='会游泳的真猪:BAABLgAECn8XAAMNAAgJ5BSmKADtAQANAAgJ5BSmKADtAQAOAAUJTA85WADkAAAAAA==.',
['传承']='传承护甲二:BAAALgAECgUJCAAAAA==.',
['余生']='余生陪你:BAAALgAECgEJAQAAAA==.',
['你上']='你上我殿后:BAAALgAECgYJBAAAAA==.',
['你说']='你说的都不对:BAAALgAECgYJDgAAAA==.',
['信仰']='信仰喵喵:BAAALgAFFAQJAgAAAA==.',
['六丁']='六丁六甲:BAAALgADCgEJAQAAAA==.',
['农夫']='农夫卷:BAAALgAECgEJAQAAAA==.',
['冷风']='冷风狂舞:BAAALgAECgYJDQAAAA==.',
['凯尔']='凯尔血蹄:BAABLgAFFH8KAAIPAAMJVxsBDwD3AAAPAAMJVxsBDwD3AAAAAA==.',
['刀盾']='刀盾狗:BAAALgADCgUJBQAAAA==.',
['刘个']='刘个坑丶:BAABLgAECn8YAAMQAAcJXBoQFwAtAgAQAAcJXBoQFwAtAgARAAcJuxwrEgAjAgAAAA==.',
['则瑞']='则瑞的帽子:BAAALgAFFAEJAQAAAA==.',
['剑随']='剑随风:BAAALgAECgUJBQAAAA==.',
['劣小']='劣小猎:BAAALgAECgQJBgAAAA==.',
['勁樂']='勁樂牛頭人:BAAALgAECgYJCAAAAA==.',
['勒布']='勒布郎詹姆斯:BAAALgAECgUJBgAAAA==.',
['十二']='十二路谭腿:BAAALgAECgMJAwAAAA==.',
['单刷']='单刷女寝:BAAALgAECgcJDgAAAA==.',
['南小']='南小希:BAAALgAECgQJBAAAAA==.',
['双马']='双马尾小可爱:BAABLgAECn8aAAMSAAkJaiTyAAC9AwASAAkJaiTyAAC9AwACAAQJVRVXlAD1AAAAAA==.',
['反者']='反者道之动:BAAALgAFFAEJAwAAAA==.',
['古尒']='古尒蛋:BAAALgAFFAIJAgAAAA==.',
['古风']='古风月影:BAAALgADCgIJAgAAAA==.',
['只是']='只是有点像:BAAALgAECgEJAwAAAA==.',
['可爱']='可爱的憨憨:BAAALgAECgQJBAAAAA==.',
['史泰']='史泰龙:BAAALgAECgcJCgAAAA==.',
['吃了']='吃了:BAAALgAECgkJCQAAAA==.',
['合欢']='合欢宗门圣女:BAABLgAFFH8GAAINAAIJdhzNDQCiAAANAAIJdhzNDQCiAAAAAA==.',
['周星']='周星星:BAABLgAFFH8IAAITAAQJYxLxFgBIAQATAAQJYxLxFgBIAQAAAA==.',
['命运']='命运之手:BAAALgAECgYJCgAAAA==.',
['咕咕']='咕咕鼓鼓:BAAALgADCgYJBgAAAA==.',
['哎木']='哎木九和牛:BAAALgAFFAEJAQAAAA==.哎木五和德:BAABLgAFFH8GAAIPAAMJRRqtDgCiAAAPAAMJRRqtDgCiAAAAAA==.哎木五和法:BAAALgAECgMJBQAAAA==.',
['哚桃']='哚桃桃:BAAALgAECgEJAQAAAA==.',
['哦我']='哦我丢了:BAAALgAFFAMJAwAAAA==.',
['唏哩']='唏哩呼噜:BAABLgAFFH8GAAIUAAIJhgAPFABYAAAUAAIJhgAPFABYAAAAAA==.',
['啊呜']='啊呜呜:BAAALgAECgYJBgAAAA==.',
['啊噗']='啊噗:BAAALgAECgYJCwAAAA==.',
['啸清']='啸清锋:BAAALgAFFAEJAQAAAA==.',
['圈圈']='圈圈面包:BAAALgAECgIJAgAAAA==.',
['土豆']='土豆儿脑袋:BAAALgADCgQJBAAAAA==.',
['圣光']='圣光酸奶:BAAALgAECgYJDAAAAA==.',
['圣吉']='圣吉列斯:BAAALgADCgEJAQAAAA==.',
['圣堂']='圣堂新月:BAAALgAECgIJBAAAAA==.',
['圣帝']='圣帝撒奥瑟:BAAALgAECgQJBQAAAA==.',
['圣斗']='圣斗士:BAAALgAECgEJAQAAAA==.',
['在哪']='在哪里搞笑:BAAALgADCgMJAwAAAA==.',
['城市']='城市酒仙:BAAALgADCgQJBAAAAA==.',
['基纳']='基纳:BAAALgADCgcJBwAAAA==.',
['堕落']='堕落的暗风:BAAALgAECgQJBgAAAA==.',
['壊柠']='壊柠檬:BAAALgAECgQJBgAAAA==.',
['夏弥']='夏弥:BAAALgAFFAIJAgAAAA==.',
['多博']='多博士:BAAALgADCgEJAQAAAA==.',
['多重']='多重射鸡:BAAALgAECgYJBwAAAA==.',
['夜骑']='夜骑之子:BAABLgAFFH8JAAITAAMJLSJQCwA1AQATAAMJLSJQCwA1AQABLgAFFAQJDAAGAOAhAA==.',
['大枣']='大枣橙子:BAAALgAECgMJBQAAAA==.',
['大眼']='大眼芭比:BAAALgAFFAIJAwAAAA==.',
['大红']='大红手阿宗:BAAALgAECgUJCAAAAA==.',
['大腿']='大腿转转:BAAALgADCgEJAQAAAA==.',
['天堂']='天堂里的橙砖:BAAALgAECgIJAgAAAA==.',
['天花']='天花板:BAAALgAECgcJCwAAAA==.',
['奈徳']='奈徳丽:BAAALgAFFAIJAwAAAA==.',
['奔放']='奔放亲老汉:BAAALgAECgEJAQAAAA==.',
['媛嘟']='媛嘟嘟:BAAALgADCgEJAQAAAA==.',
['孟林']='孟林:BAAALgAECgQJBgAAAA==.',
['宇多']='宇多熊光:BAABLgAECn8YAAMGAAYJHx0IHgCCAQAGAAYJHx0IHgCCAQAVAAEJxhItHQA4AAAAAA==.',
['宗门']='宗门天骄:BAAALgAECgQJBwAAAA==.宗门老六:BAAALgAECgIJAgAAAA==.',
['寂寞']='寂寞海上玥:BAAALgAECgYJDAAAAA==.寂寞的汤包:BAAALgADCgUJBQAAAA==.',
['对我']='对我可以乱来:BAABLgAFFH8GAAIUAAIJDgb5HwB3AAAUAAIJDgb5HwB3AAAAAA==.',
['射你']='射你上天:BAAALgAECgQJBAAAAA==.',
['小丘']='小丘怒风:BAAALgAECgYJCQAAAA==.',
['小乖']='小乖怪:BAAALgAECgYJBwAAAA==.',
['小予']='小予妹子:BAAALgAECgYJEgAAAA==.',
['小小']='小小奶萨:BAAALgADCgcJDAAAAA==.',
['小池']='小池塘:BAAALgAECgEJAgAAAA==.',
['小煎']='小煎花鲢:BAAALgAFFAEJAQAAAA==.',
['小玫']='小玫玫:BAAALgAFFAEJAQAAAA==.',
['小萌']='小萌娇花:BAAALgADCgYJBgAAAA==.',
['小马']='小马君丶:BAAALgAECgUJBQAAAA==.',
['尛北']='尛北丶:BAABLgAECn8cAAQEAAgJAxIpFgDqAQAEAAgJAxIpFgDqAQAFAAMJ0g4aSgCsAAAWAAEJRwkBQgAsAAAAAA==.',
['尛魚']='尛魚児丶:BAAALgAECgYJCAAAAA==.',
['布鲁']='布鲁兹老爷:BAAALgAECgEJAQAAAA==.',
['希尔']='希尔瓦莉拉:BAAALgAECgUJBwABLgAFFAQJCQABAIgSAA==.',
['带带']='带带猎猎吧:BAAALgAFFAIJAwAAAA==.',
['库卡']='库卡:BAAALgAECgkJCQAAAA==.',
['库洛']='库洛洛:BAAALgAECgEJAQAAAA==.',
['异想']='异想记:BAABLgAECn8WAAIXAAcJ7RlMCwCrAQAXAAcJ7RlMCwCrAQAAAA==.',
['弥塞']='弥塞亚:BAAALgAECgYJCQAAAA==.',
['弱水']='弱水一瓢:BAAALgAFFAEJAQAAAA==.',
['弹指']='弹指舞飞雪:BAAALgAECgIJAgAAAA==.',
['强效']='强效治疗波:BAAALgADCgEJAQAAAA==.',
['影武']='影武武:BAAALgAECgcJDgAAAA==.',
['御箭']='御箭飞龍:BAAALgAECgEJAQAAAA==.',
['德意']='德意治:BAAALgADCgYJBgAAAA==.',
['德罪']='德罪不起:BAABLgAFFH8IAAMPAAMJZgZvHwB8AAAPAAMJZgZvHwB8AAAHAAIJTQHrDAB7AAAAAA==.',
['快雪']='快雪时晴:BAAALgADCgUJBQAAAA==.',
['恬悠']='恬悠优:BAAALgADCgIJAwAAAA==.',
['恶魔']='恶魔奴役:BAAALgAECgEJAQAAAA==.恶魔练习生:BAAALgAECgQJBQAAAA==.',
['想玩']='想玩就玩:BAAALgAECgIJAgAAAA==.',
['我叫']='我叫高帅富:BAAALgADCggJCAAAAA==.',
['我震']='我震死你:BAAALgAECgYJCAAAAA==.',
['打电']='打电话问功课:BAAALgAECgcJEgAAAA==.',
['托遗']='托遗响于悲风:BAAALgAECgkJDwAAAA==.',
['技艺']='技艺精甚:BAABLgAFFH8GAAIJAAMJ5A07CwCsAAAJAAMJ5A07CwCsAAAAAA==.',
['撞墙']='撞墙上的猪:BAAALgAECgYJCQAAAA==.',
['撸出']='撸出血:BAAALgAECgcJBwAAAA==.',
['擺渡']='擺渡人:BAAALgADCgYJBgAAAA==.',
['断风']='断风:BAAALgAECgEJAQAAAA==.',
['新兵']='新兵:BAABLgAFFH8JAAIYAAMJBhhBAgDrAAAYAAMJBhhBAgDrAAAAAA==.',
['方合']='方合秘书:BAAALgAECgcJDwAAAA==.',
['於嗣']='於嗣砼:BAAALgAECgEJAQAAAA==.',
['无聊']='无聊到头:BAAALgAECgQJBAAAAA==.',
['时光']='时光鎏年:BAABLgAECn8ZAAMZAAcJghA8AQB0AQAZAAcJghA8AQB0AQAGAAIJ2AN+WQFNAAAAAA==.',
['明若']='明若心诚:BAAALgADCgEJAQAAAA==.',
['易上']='易上当的小孩:BAAALgAECgEJBAAAAA==.',
['晴天']='晴天小财迷:BAAALgAECgUJBQAAAA==.',
['曼尼']='曼尼:BAAALgAECgYJDQAAAA==.',
['月之']='月之余烬:BAAALgAECgMJAwAAAA==.',
['月夕']='月夕:BAAALgAFFAEJAgAAAA==.',
['月栖']='月栖梧桐:BAAALgAECgQJAQAAAA==.',
['月落']='月落苍阙:BAAALgAECgUJBQAAAA==.',
['有点']='有点肉:BAAALgAECgEJAQAAAA==.',
['朝霖']='朝霖有点亏:BAAALgADCgEJAQAAAA==.',
['朴正']='朴正幻:BAAALgAECgIJAgAAAA==.',
['枫之']='枫之忆:BAAALgAECgcJDwAAAA==.',
['栗子']='栗子馒头啊:BAAALgAECgEJAQAAAA==.',
['桂畔']='桂畔里吊烧猪:BAAALgADCgMJAwAAAA==.',
['梦想']='梦想歌:BAAALgADCgEJAQAAAA==.',
['樊大']='樊大圣:BAAALgAECgEJAQAAAA==.',
['欧洲']='欧洲小母牛:BAAALgAECgYJCQAAAA==.',
['武灵']='武灵:BAAALgAECgYJDAAAAA==.',
['死亡']='死亡丶浮铭:BAAALgAECgUJBQAAAA==.',
['殇灬']='殇灬鬼魅:BAAALgAECgUJBwAAAA==.',
['母牛']='母牛有三好:BAAALgAECgQJBwAAAA==.',
['毕福']='毕福剑:BAAALgAECgQJCQAAAA==.',
['永生']='永生的发丝:BAAALgAECgkJBQAAAA==.',
['沉默']='沉默的风语者:BAAALgADCgYJBgAAAA==.',
['浮生']='浮生叹红颜:BAAALgAECgQJCAAAAA==.浮生婼梦:BAAALgAECgQJBAAAAA==.',
['海豚']='海豚的微笑:BAAALgAFFAIJAwAAAA==.',
['清风']='清风丶霁月:BAAALgAFFAIJBAAAAA==.',
['温暖']='温暖的茜:BAAALgAECgEJAQABLgAFFAUJBAADAAAAAA==.',
['潇潇']='潇潇:BAAALgAFFAIJAgAAAA==.',
['火山']='火山下的熔岩:BAAALgAFFAIJAwAAAA==.',
['火花']='火花:BAABLgAECn8VAAMaAAYJKSLsAgBSAgAaAAYJKSLsAgBSAgARAAQJqglUQgChAAAAAA==.',
['灬小']='灬小丑灬:BAAALgAECgcJDwAAAA==.',
['灬楓']='灬楓:BAAALgADCgUJBQAAAA==.',
['灰烬']='灰烬丶皀皃:BAAALgAECgIJAgAAAA==.灰烬灬天堂:BAAALgAECgMJAgAAAA==.灰烬老九:BAABLgAFFH8FAAIGAAMJfgsMGQD5AAAGAAMJfgsMGQD5AAAAAA==.',
['灼眼']='灼眼夏娜:BAAALgAECgYJBgAAAA==.',
['灾贼']='灾贼:BAAALgAFFAIJAwAAAA==.',
['炽热']='炽热寒寒术:BAAALgAECgYJCAAAAA==.炽热灵凌:BAAALgAECgUJCAAAAA==.炽热灵灵:BAAALgAECgIJAgAAAA==.',
['烙印']='烙印开幕:BAAALgAECgIJAgAAAA==.',
['烟雨']='烟雨如风:BAAALgAECgYJBgAAAA==.',
['無色']='無色輪回:BAAALgADCgMJAwAAAA==.',
['燃烧']='燃烧吧生命:BAAALgADCgMJAgAAAA==.',
['爸爸']='爸爸:BAABLgAFFH8MAAITAAQJESNJAgCTAQATAAQJESNJAgCTAQAAAA==.',
['爽咩']='爽咩咩:BAAALgAECgEJAQAAAA==.',
['狩猎']='狩猎与生存:BAAALgAECgIJAgAAAA==.',
['猛大']='猛大山:BAAALgAECgEJAQAAAA==.',
['现在']='现在已夜深:BAABLgAFFH8FAAILAAIJbA7zOgCdAAALAAIJbA7zOgCdAAAAAA==.现在是去哪里:BAAALgAECgYJDAAAAA==.',
['班策']='班策达根:BAAALgAECgMJAwAAAA==.',
['瑟里']='瑟里晓基极:BAAALgAECgEJAQAAAA==.',
['瓜子']='瓜子中毒:BAAALgAECgQJBAAAAA==.',
['由心']='由心及物:BAAALgAFFAIJAgAAAA==.',
['电到']='电到啦啦酥:BAAALgAECgEJAgAAAA==.',
['疯狂']='疯狂星期四:BAAALgAECgQJBQAAAA==.',
['瘦弱']='瘦弱:BAAALgAECgYJBwABLgAECggJGQAKAKAMAA==.',
['皇家']='皇家恐怖卫士:BAAALgAECgIJAgAAAA==.',
['皮皮']='皮皮喵:BAAALgAECgMJAwAAAA==.',
['盗跖']='盗跖:BAAALgAFFAIJAgAAAA==.',
['真丶']='真丶酒仙:BAAALgAECgEJAQAAAA==.',
['石更']='石更氵又丶:BAABLgAFFH8GAAIBAAQJyhtcBwB7AQABAAQJyhtcBwB7AQAAAA==.',
['秦莳']='秦莳明月:BAAALgAECgYJDwAAAA==.',
['精灵']='精灵小水滴:BAAALgAECgYJBgAAAA==.',
['糖筱']='糖筱灬懮:BAAALgADCgUJBQAAAA==.',
['糖醋']='糖醋酱排骨:BAAALgAFFAIJAgAAAA==.',
['純情']='純情的小豬:BAAALgAECgYJCwAAAA==.',
['素年']='素年千斤:BAAALgAECgcJEAAAAA==.',
['红烧']='红烧牛腩:BAAALgAFFAEJAQAAAA==.',
['红美']='红美玲:BAAALgAECgEJAQAAAA==.',
['纱菱']='纱菱羽翼:BAACLgAFFH8HAAILAAIJFiLFKwDAAAALAAIJFiLFKwDAAAAuAAQKfxIAAxsACAmfHaIcAGkBAAsABQnbG1RnAJYBABsABAkyHaIcAGkBAAEuAAUUBgkWAAsA+SAA.',
['练习']='练习生:BAAALgAECgMJBQAAAA==.',
['维也']='维也纳灬猪猪:BAABLgAFFH8IAAIcAAQJ6BxMAwByAQAcAAQJ6BxMAwByAQAAAA==.',
['维尔']='维尔卡:BAAALgAECgYJDQAAAA==.',
['美男']='美男子:BAAALgADCgEJAQAAAA==.',
['聪明']='聪明吼小可爱:BAAALgAECgkJEQAAAA==.',
['胸口']='胸口碎大石:BAAALgADCgEJAQAAAA==.',
['胸毛']='胸毛飘飘:BAAALgADCgIJAgAAAA==.',
['脚拿']='脚拿开我不吃:BAAALgADCgEJAQAAAA==.',
['至死']='至死不渝丶:BAAALgAECgEJAgAAAA==.',
['至莫']='至莫夜月明丶:BAABLgAECn8ZAAMdAAgJnhq4BgAjAgAdAAgJnhq4BgAjAgACAAMJ/AttQACXAAAAAA==.',
['艾叶']='艾叶土鸡脚:BAAALgAECgUJBQAAAA==.',
['芬里']='芬里斯顿:BAAALgAECgEJAwAAAA==.',
['花开']='花开在离别:BAAALgAECgUJDQAAAA==.',
['花生']='花生中毒:BAAALgAECgQJBQAAAA==.花生中毒丶丶:BAAALgAECgQJBAAAAA==.花生生中毒:BAAALgAECgMJBAAAAA==.',
['花辞']='花辞树丶:BAAALgADCgQJBAAAAA==.',
['花雷']='花雷精:BAAALgAECgEJAQAAAA==.',
['苡德']='苡德服人:BAAALgAECgUJBQAAAA==.',
['草原']='草原英雄:BAAALgAECgIJAgAAAA==.',
['草莓']='草莓奶嘴:BAAALgAECgYJBgAAAA==.',
['莫邳']='莫邳邪:BAAALgAECgYJBgAAAA==.',
['萌萌']='萌萌紫宝宝:BAAALgAFFAIJAgAAAA==.萌萌黑宝宝:BAACLgAFFH8MAAIGAAQJ4CE/BwByAQAGAAQJ4CE/BwByAQAuAAQKfyIAAwYACAm4IYMeAPsCAAYACAkwIYMeAPsCABkABgkqIogAAPYBAAAA.',
['萨拉']='萨拉塔斯:BAAALgAECgIJAwAAAA==.',
['蓝染']='蓝染偬右介:BAAALgAECgIJAgAAAA==.',
['虚空']='虚空传说:BAAALgAECgYJBwAAAA==.',
['虬髯']='虬髯天佑:BAAALgAECgcJEAAAAA==.',
['謝謝']='謝謝祢嘚溫媃:BAAALgADCgEJAQAAAA==.',
['讹兲']='讹兲使:BAABLgAFFH8GAAISAAIJjRABCQCnAAASAAIJjRABCQCnAAAAAA==.',
['诺拉']='诺拉丶萌僧:BAAALgAECgkJCQABLgAFFAcJBAADAAAAAA==.',
['贼猫']='贼猫之手:BAABLgAFFH8FAAIKAAMJnAQVBgCuAAAKAAMJnAQVBgCuAAAAAA==.贼猫贼猫:BAAALgAFFAIJAwAAAA==.',
['足道']='足道也是道:BAAALgAECgEJAQAAAA==.',
['轻嗅']='轻嗅石楠:BAAALgAECgQJCAAAAA==.',
['辣是']='辣是我亮哥术:BAAALgADCgMJAwAAAA==.',
['这个']='这个冬天好冷:BAAALgAECgIJAgAAAA==.',
['遗忘']='遗忘:BAAALgAECgEJAQABLgAFFAUJCwATAIwTAA==.',
['那个']='那个:BAAALgAECgQJBwAAAA==.那个哈提别跑:BAAALgAECgkJCQAAAA==.',
['郝瀚']='郝瀚祇垙:BAAALgAECgUJBQAAAA==.',
['部落']='部落娇花:BAAALgAECgEJAQAAAA==.',
['酒过']='酒过三旬:BAAALgAECgYJBgAAAA==.',
['酒醸']='酒醸小圆子:BAAALgADCgUJBQAAAA==.',
['鉴茶']='鉴茶师:BAAALgAFFAIJAwABLgAFFAYJHAAGADMjAA==.',
['闪光']='闪光男爵:BAAALgAECgIJAgAAAA==.',
['阿爾']='阿爾托莉亚:BAAALgAECgEJAQAAAA==.',
['阿西']='阿西巴卡:BAAALgAECgYJCQAAAA==.',
['随性']='随性:BAAALgAECgQJBQAAAA==.',
['雨丶']='雨丶丛林之彩:BAAALgAECgEJAQAAAA==.',
['雪花']='雪花哪个飘:BAAALgADCgEJAQAAAA==.',
['零九']='零九年的贰猎:BAAALgAECgYJCAAAAA==.',
['雷电']='雷电道长:BAAALgADCgIJAgAAAA==.',
['霜烬']='霜烬:BAAALgAECgUJBQAAAA==.',
['青春']='青春哥:BAAALgAECgEJAQAAAA==.',
['青鸟']='青鸟丶飞鱼:BAAALgAECgQJBAAAAA==.',
['韩立']='韩立:BAAALgAECgMJAwAAAA==.',
['风之']='风之岚歌:BAAALgAECgQJBwAAAA==.',
['风流']='风流奥特曼:BAAALgAECgEJAQAAAA==.',
['风行']='风行绝刃:BAAALgAECgIJAgAAAA==.',
['飚丶']='飚丶血:BAAALgAECgEJAgAAAA==.',
['饭饭']='饭饭丶:BAAALgAECgYJBgAAAA==.',
['騎老']='騎老狗曰學舞:BAABLgAFFH8GAAIeAAMJaQT6EADBAAAeAAMJaQT6EADBAAABLgAFFAYJEwABAMggAA==.',
['马小']='马小姨子:BAABLgAECn8YAAMSAAgJzByyFwAKAgASAAYJTB2yFwAKAgAdAAYJyRaUDgBpAQAAAA==.',
['骑小']='骑小奇:BAAALgAECgQJBAAAAA==.',
['魔苟']='魔苟斯:BAAALgAECgUJCQAAAA==.',
['鱼香']='鱼香肉丝:BAAALgAECgQJBAAAAA==.',
['鲜椒']='鲜椒龙凤球:BAAALgAECgMJBAAAAA==.',
['鲜血']='鲜血之荣耀:BAAALgAECgcJCgAAAA==.鲜血骑士:BAAALgADCgQJBAAAAA==.',
['鸟牛']='鸟牛:BAAALgAECgYJBgAAAA==.',
['麥辣']='麥辣冰激凌:BAAALgAECgYJCAAAAA==.',
['麦兜']='麦兜兜:BAAALgAFFAEJAQAAAA==.',
['麻仓']='麻仓果:BAAALgAECgQJBAAAAA==.',
['麼有']='麼有感情:BAAALgAECgMJAgAAAA==.',
['黄尐']='黄尐姐:BAAALgAECgMJAwAAAA==.',
['黑铁']='黑铁之手:BAAALgAECgYJCwAAAA==.',
['齐天']='齐天大圣:BAAALgADCgYJBgAAAA==.',
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
