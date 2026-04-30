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

local lookup = {'Shaman-Restoration','Shaman-Elemental','Warrior-Protection','Priest-Shadow','Rogue-Subtlety','Priest-Holy','Priest-Discipline','Monk-Brewmaster','Mage-Frost','Unknown-Unknown','DeathKnight-Unholy','Hunter-BeastMastery','Monk-Windwalker','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','Evoker-Augmentation','Evoker-Devastation','Druid-Restoration','Druid-Balance','Paladin-Holy','Hunter-Marksmanship','Rogue-Assassination','Paladin-Retribution',}
local provider = {region='CN',realm='火焰之树',name='CN',type='weekly',zone=46,date='2026-04-25',data={Be='Be:BAAALgAFFAIJAgAAAA==.',
Bu='Build:BAAALgAECgYJCQAAAA==.',
Da='Dante:BAABLgAECn8VAAMBAAgJERRcUwA4AQABAAcJkxNcUwA4AQACAAUJqhT/RwAoAQAAAA==.',
De='Deadlight:BAAALgAECgcJDAAAAA==.',
Em='Ember:BAAALgAECgQJBAAAAA==.',
Ha='Hammerx:BAAALgAECgEJAgAAAA==.',
Im='Immortlis:BAAALgAECgYJBwABLgAECgkJFwADAMAcAA==.',
Ka='Kaidohouse:BAAALgAECgcJDwAAAA==.Kaneli:BAAALgAFFAMJBAAAAA==.',
Ki='Kinico:BAAALgAECgIJAgAAAA==.',
Ma='Mary:BAABLgAFFH8NAAIEAAUJbx3tBwBIAQAEAAUJbx3tBwBIAQAAAA==.Maëlle:BAAALgAECgcJBwABLgAFFAUJEAAFAC8lAA==.',
Me='Meleys:BAAALgAFFAQJBAAAAA==.Melisa:BAABLgAFFH8IAAIEAAQJ0BUICQAwAQAEAAQJ0BUICQAwAQAAAA==.',
Pl='Playerfyyutf:BAAALgADCgYJCQAAAA==.Playergcyqre:BAAALgADCgUJBgAAAA==.Pluviophile:BAACLgAFFH8KAAIGAAMJQCSRBAA9AQAGAAMJQCSRBAA9AQAuAAQKfyAAAwYABwlcJTUHANkCAAYABwlcJTUHANkCAAcAAwnqFWk/ALMAAAAA.',
Qi='Qiovo:BAAALgAECgYJEQAAAA==.',
Re='Resistance:BAAALgAECgMJAwAAAA==.',
Ry='Ryusakyamuni:BAABLgAFFH8FAAIIAAMJvRYrEgDqAAAIAAMJvRYrEgDqAAAAAA==.',
Sk='Skyliner:BAAALgAECgEJAQAAAA==.',
So='Soapshamans:BAAALgAECggJDQAAAA==.',
Su='Sumail:BAAALgAFFAMJAwAAAA==.',
Th='Thalorian:BAABLgAFFH8JAAIJAAQJFRlBBgBuAQAJAAQJFRlBBgBuAQAAAA==.',
Xl='Xll:BAAALgAECgMJBQAAAA==.',
['一冰']='一冰刺定江山:BAAALgAECgQJBAAAAA==.',
['一刀']='一刀灬见血:BAAALgAECgEJAQAAAA==.',
['一叶']='一叶障牧:BAAALgAECgYJBgAAAA==.',
['一品']='一品先橙:BAAALgADCgMJAwAAAA==.',
['一破']='一破天一:BAAALgAECgEJAQAAAA==.',
['一缕']='一缕微风:BAAALgAECgEJAQAAAA==.',
['一色']='一色日和:BAAALgAECgUJBQAAAA==.',
['丶年']='丶年华易逝丶:BAAALgAFFAIJBAABLgAFFAIJBAAKAAAAAA==.',
['丶我']='丶我是刹那:BAAALgAECgcJCAAAAA==.',
['丶执']='丶执念:BAAALgAECgEJAQAAAA==.',
['丶畏']='丶畏灬:BAAALgAECgYJBwAAAA==.',
['丶阿']='丶阿丁灬:BAAALgAECgYJBAABLgAECgcJBgAKAAAAAA==.',
['丶黑']='丶黑胡子:BAAALgADCgYJBgAAAA==.',
['丶龍']='丶龍灬:BAAALgADCgIJAgAAAA==.',
['乜许']='乜许会有日落:BAAALgAECgEJAQAAAA==.',
['二阶']='二阶堂希罗:BAAALgAFFAQJBAAAAA==.',
['亡魂']='亡魂雇佣军:BAABLgAECn8UAAILAAYJWx09hgB1AQALAAYJWx09hgB1AQAAAA==.',
['人间']='人间仁爱:BAAALgADCgEJAQAAAA==.',
['亿万']='亿万少女的梦:BAABLgAFFH8LAAILAAQJQCAOCwB7AQALAAQJQCAOCwB7AQAAAA==.',
['你我']='你我相爱相杀:BAAALgADCgEJAQAAAA==.',
['俊少']='俊少爷:BAABLgAFFH8GAAIMAAMJ5hSbCwAFAQAMAAMJ5hSbCwAFAQAAAA==.',
['免费']='免费:BAAALgAECgYJCgAAAA==.',
['全效']='全效眼睛光线:BAABLgAFFH8FAAILAAUJIgPrFQBMAQALAAUJIgPrFQBMAQAAAA==.',
['兩手']='兩手揣兜:BAAALgAECgYJCwAAAA==.',
['别打']='别打这个萨满:BAAALgAECgYJBwAAAA==.',
['别样']='别样情怀:BAAALgAECgEJAQAAAA==.',
['动圈']='动圈:BAABLgAFFH8IAAMNAAMJbw0HCQDkAAANAAMJbw0HCQDkAAAOAAIJ1gOuEwB1AAAAAA==.',
['动铁']='动铁:BAAALgAECgcJEgABLgAFFAMJCAANAG8NAA==.',
['十贰']='十贰嗰:BAAALgAECgEJAQAAAA==.',
['卩丶']='卩丶紫:BAAALgAECgEJAwAAAA==.',
['历历']='历历在牧:BAAALgADCgcJBwABLgADCgcJBwAKAAAAAA==.',
['双层']='双层猪柳蛋:BAAALgAFFAQJBAABLgAFFAUJEAAFAC8lAA==.',
['叮先']='叮先生:BAACLgAFFH8HAAILAAMJwiS6FgBJAQALAAMJwiS6FgBJAQAuAAQKfyMAAgsACAn6I1AOACgDAAsACAn6I1AOACgDAAAA.',
['叮当']='叮当乱响:BAAALgAECgYJCAAAAA==.',
['吗喽']='吗喽丶:BAAALgAFFAIJAwAAAA==.',
['含光']='含光:BAAALgAFFAMJBAAAAA==.',
['呼噜']='呼噜噜丶:BAAALgAECgIJAgAAAA==.',
['和中']='和中:BAAALgAECgYJBgABLgAFFAMJCAANAG8NAA==.',
['咕嘟']='咕嘟:BAABLgAFFH8FAAIJAAIJNRYVPwCvAAAJAAIJNRYVPwCvAAAAAA==.咕嘟嘟:BAAALgAECgIJAgAAAA==.',
['品茗']='品茗丶:BAAALgAECgYJBwAAAA==.',
['哈基']='哈基米德:BAACLgAFFH8JAAICAAMJ4gptEQDhAAACAAMJ4gptEQDhAAAuAAQKfxkAAgIABgkoIMYfABECAAIABgkoIMYfABECAAAA.',
['唯爱']='唯爱无言:BAAALgAECgEJAQAAAA==.',
['喝酸']='喝酸奶忝瓶蓋:BAAALgAECgUJBQAAAA==.',
['嘟米']='嘟米咔:BAAALgAFFAEJAQAAAA==.',
['国丶']='国丶家电网:BAAALgADCgEJAQAAAA==.',
['堕落']='堕落领袖:BAAALgAFFAIJAgAAAA==.',
['壹碗']='壹碗嘎巴菜:BAAALgAECgIJAgAAAA==.',
['多谢']='多谢帝骑哥:BAAALgAECgkJCQAAAA==.',
['夜半']='夜半星光:BAAALgAECgcJDAAAAA==.',
['夜幕']='夜幕涎鬼:BAAALgAECgQJBAAAAA==.',
['大宗']='大宗师丨柒爷:BAAALgAECgcJDAAAAA==.',
['大耳']='大耳牛:BAAALgAECgUJBQAAAA==.',
['天命']='天命行者:BAAALgAECgUJBQAAAA==.',
['天天']='天天好心情:BAACLgAFFH8GAAIPAAMJJApHAgCXAAAPAAMJJApHAgCXAAAuAAQKfx0AAw8ACAmsFiACAIEBAA8ACAmsFiACAIEBABAAAQnCDS8YATYAAAAA.',
['天谴']='天谴:BAAALgAFFAIJAgAAAA==.',
['太眞']='太眞:BAAALgAECgQJCAAAAA==.',
['奥绝']='奥绝之飝:BAAALgAFFAIJBAAAAA==.',
['妈妈']='妈妈:BAABLgAFFH8LAAIHAAUJGAzYBQCHAQAHAAUJGAzYBQCHAQAAAA==.',
['姐夫']='姐夫再用力:BAAALgAECgcJAwAAAA==.',
['娜贝']='娜贝的塔臭娜:BAABLgAECn8UAAMRAAcJYSFGEAB0AgARAAcJYSFGEAB0AgASAAEJAAChNABvAAAAAA==.',
['婉若']='婉若惊鸿:BAAALgAECgcJCwAAAA==.',
['孤心']='孤心赏月:BAAALgAECgkJCQABLgAFFAcJCwAIAM0PAA==.',
['安小']='安小米:BAAALgAECgMJBgAAAA==.',
['宝安']='宝安:BAAALgADCgMJAwAAAA==.',
['小小']='小小兰德:BAAALgAECgYJBgAAAA==.',
['小毛']='小毛驴儿:BAABLgAFFH8KAAIOAAUJLhLsBQBwAQAOAAUJLhLsBQBwAQAAAA==.',
['小点']='小点点:BAABLgAECn8UAAMHAAcJdBngHgCdAQAHAAcJQBDgHgCdAQAGAAUJGRqzMQB5AQAAAA==.小点点丨:BAAALgAFFAEJAQAAAA==.',
['尤莉']='尤莉卡:BAABLgAFFH8GAAILAAIJrAw/RACbAAALAAIJrAw/RACbAAAAAA==.',
['就不']='就不加你:BAAALgADCgEJAQAAAA==.',
['就叫']='就叫德丶:BAABLgAFFH8KAAITAAMJURC7EgDTAAATAAMJURC7EgDTAAAAAA==.',
['就差']='就差一丢丢儿:BAAALgAFFAIJAgAAAA==.',
['尹艾']='尹艾茜:BAAALgAECgUJBQAAAA==.',
['尼古']='尼古拉斯赵四:BAAALgAECgcJEwAAAA==.',
['山岳']='山岳:BAAALgAECgIJAgAAAA==.',
['山有']='山有扶蘇:BAACLgAFFH8KAAMTAAMJ+RQhEgDYAAATAAMJ+RQhEgDYAAAUAAIJ5QtSFQCaAAAuAAQKfyIAAxMACAkbHzQoABQCABMACAkbHzQoABQCABQABAn/EvlIAAgBAAAA.',
['山竹']='山竹炒月饼:BAAALgAECgYJBgAAAA==.',
['巳升']='巳升升:BAAALgAFFAIJAgAAAA==.',
['市南']='市南五月的丰:BAAALgAECgYJAQAAAA==.',
['帅的']='帅的莫名其妙:BAAALgAFFAIJAgAAAA==.',
['年华']='年华已逝:BAAALgAFFAIJAwABLgAFFAIJBAAKAAAAAA==.年华易逝:BAAALgAFFAIJBAAAAA==.年华易逝丶:BAAALgAFFAIJAwABLgAFFAIJBAAKAAAAAA==.年华易逝丿:BAAALgAFFAIJAgABLgAFFAIJBAAKAAAAAA==.',
['幽儿']='幽儿希卡:BAABLgAFFH8IAAIFAAQJQR5IBwBuAQAFAAQJQR5IBwBuAQABLgAFFAUJEAAFAC8lAA==.',
['幽暗']='幽暗毁灭者:BAAALgAECgYJEAAAAA==.',
['广寒']='广寒宫:BAAALgAECgYJDgAAAA==.',
['弥时']='弥时:BAAALgAFFAIJAgAAAA==.',
['彩云']='彩云牛牛:BAAALgAFFAIJAgAAAA==.',
['影丨']='影丨翳:BAACLgAFFH8IAAILAAMJGA8NKgDyAAALAAMJGA8NKgDyAAAuAAQKfyMAAgsACAlrG700AGQCAAsACAlrG700AGQCAAAA.',
['影子']='影子满天星:BAAALgAECgUJBQAAAA==.',
['彼岸']='彼岸的守护:BAAALgADCgMJAwAAAA==.',
['德隆']='德隆:BAAALgADCgEJAgAAAA==.',
['心中']='心中的火焰:BAAALgADCgMJAQAAAA==.',
['恶天']='恶天使:BAAALgAFFAMJBAAAAA==.',
['恶魔']='恶魔小巫师:BAAALgAECgQJBAAAAA==.',
['戈壁']='戈壁沙漠:BAAALgAECgEJAQAAAA==.',
['我丨']='我丨回来了:BAAALgAFFAIJAwAAAA==.',
['我们']='我们的祖先:BAAALgAECgMJAwAAAA==.',
['我的']='我的脸特白:BAAALgAECgQJBAAAAA==.',
['战争']='战争龍头:BAAALgAECgcJCQAAAA==.',
['抹茶']='抹茶麻糬:BAACLgAFFH8QAAIBAAUJ7xSmBwBLAQABAAUJ7xSmBwBLAQAuAAQKfx8AAwEACQkXIcUCAFQDAAEACQkXIcUCAFQDAAIAAQnHBr+NACoAAAAA.',
['拉面']='拉面加肉:BAABLgAFFH8IAAINAAQJaQHWBAC7AAANAAQJaQHWBAC7AAAAAA==.',
['敏捷']='敏捷:BAAALgADCgEJAQAAAA==.',
['斋藤']='斋藤飞袅:BAAALgADCgEJAQAAAA==.',
['旋律']='旋律影子:BAAALgAECgkJAwAAAA==.',
['无为']='无为:BAAALgAECgUJBAAAAA==.',
['无亟']='无亟之旅:BAAALgAFFAEJAQAAAA==.',
['无痕']='无痕的圣光:BAAALgAECgMJAwAAAA==.',
['无糖']='无糖芬达:BAAALgAFFAQJBAABLgAFFAUJEAAFAC8lAA==.',
['时代']='时代在召唤:BAAALgAECgEJAwAAAA==.',
['昔日']='昔日的贵族:BAAALgAECgYJBgAAAA==.',
['星光']='星光:BAAALgAECgIJAQAAAA==.',
['星鹤']='星鹤:BAAALgAECgYJBgAAAA==.',
['普特']='普特雷斯:BAAALgAECgYJAgAAAA==.',
['景久']='景久:BAACLgAFFH8HAAIGAAMJUByXCgC7AAAGAAMJUByXCgC7AAAuAAQKfyMAAwYACAkUHFAbAAICAAYACAnIGVAbAAICAAcABgkzEkMnAFsBAAAA.',
['智慧']='智慧面包怪:BAAALgAECgEJAQAAAA==.',
['暗悔']='暗悔:BAACLgAFFH8IAAMEAAMJ3xc5DwCrAAAEAAIJSBc5DwCrAAAGAAIJuxJJDACdAAAuAAQKfyMAAwQACAn/GScTAFwCAAQACAn/GScTAFwCAAYABAl5GsRKAA0BAAAA.',
['暗黑']='暗黑丸山彩:BAAALgAECgMJAwAAAA==.',
['暮雨']='暮雨:BAAALgAFFAEJAQAAAA==.',
['暴躁']='暴躁杨二伯:BAAALgAECgEJAQAAAA==.',
['月代']='月代雪:BAAALgAFFAQJBAAAAA==.',
['月梨']='月梨:BAAALgAECgUJBQAAAA==.',
['月舞']='月舞轻扬:BAAALgADCgMJAwAAAA==.',
['木槿']='木槿:BAAALgAECgUJCAAAAA==.',
['木雨']='木雨木田:BAACLgAFFH8JAAITAAQJdBJwEQDeAAATAAQJdBJwEQDeAAAuAAQKfxUAAhMACQlYGigYAHUCABMACQlYGigYAHUCAAAA.',
['杰夫']='杰夫老祭司:BAAALgAECgMJCQAAAA==.',
['東雪']='東雪莲:BAAALgAECgQJBgAAAA==.',
['林深']='林深见鹿:BAAALgAECgQJCAAAAA==.',
['枫道']='枫道:BAAALgAECgcJBwABLgAFFAgJAgAKAAAAAA==.',
['桀骜']='桀骜之冰:BAAALgAECgIJAgAAAA==.',
['桃之']='桃之夭夭:BAAALgAECgEJAQAAAA==.',
['梦的']='梦的磐涅:BAAALgAFFAQJBAABLgAFFAcJDQADAM4ZAA==.',
['樱羽']='樱羽艾玛:BAAALgAFFAQJBAAAAA==.',
['橘雪']='橘雪莉:BAAALgAFFAQJBAAAAA==.',
['橙鲸']='橙鲸鱼:BAAALgAECgEJAQAAAA==.',
['欺诈']='欺诈面具:BAAALgAECgcJBQAAAA==.',
['武僧']='武僧不会武:BAAALgAECgQJBAAAAA==.',
['水水']='水水渔渔:BAAALgAECgEJAgAAAA==.',
['法瑟']='法瑟布拉德:BAAALgAECgMJBQAAAA==.',
['流浪']='流浪苍穹:BAAALgAECggJCAAAAA==.',
['海拉']='海拉尔:BAAALgAECgIJAQAAAA==.',
['渡你']='渡你眉川:BAAALgAECgMJAwAAAA==.',
['滿月']='滿月:BAAALgAECgEJAgAAAA==.',
['火焰']='火焰刀锋出鞘:BAAALgADCgcJBwAAAA==.',
['灬影']='灬影子灬:BAACLgAFFH8KAAIVAAMJhhnjDQD5AAAVAAMJhhnjDQD5AAAuAAQKfyIAAhUACAlwG54gABYCABUACAlwG54gABYCAAAA.',
['灬脉']='灬脉动灬:BAAALgAECgYJEwAAAA==.',
['灬风']='灬风暴之眼灬:BAAALgAECgYJCgAAAA==.',
['灭零']='灭零:BAAALgAECgEJAgAAAA==.',
['灵感']='灵感老祭司:BAAALgAECgEJAgAAAA==.',
['烂木']='烂木头:BAAALgAFFAIJAwAAAA==.',
['熊小']='熊小德丶:BAAALgADCgYJCQAAAA==.',
['熊柒']='熊柒丶:BAAALgADCgYJCQAAAA==.',
['爱与']='爱与雷霆:BAAALgAECggJDgAAAA==.',
['牛大']='牛大力:BAAALgAECgQJBAAAAA==.',
['牛魔']='牛魔大力王:BAAALgAECgYJEAAAAA==.',
['牧秀']='牧秀于林:BAAALgADCgcJBwAAAA==.',
['独孤']='独孤尚恋:BAAALgAECgYJBgAAAA==.',
['獨孤']='獨孤尙戀:BAAALgAECgQJBAAAAA==.',
['珠娜']='珠娜:BAAALgADCgUJBgAAAA==.',
['瑾年']='瑾年丨随风:BAAALgAECgIJAgAAAA==.',
['生蚝']='生蚝:BAAALgADCgEJAQAAAA==.',
['疯狂']='疯狂闪电牛:BAAALgAECgEJAQAAAA==.',
['痛砼']='痛砼痛撒户辣:BAAALgAECgYJDwAAAA==.',
['白羊']='白羊:BAABLgAFFH8LAAMCAAUJlh7tAgDEAQACAAUJlh7tAgDEAQABAAQJ1x6pBACGAQAAAA==.',
['看我']='看我眼神开怪:BAAALgAECgMJAwAAAA==.',
['睡不']='睡不醒的兽:BAAALgAECgYJCQAAAA==.',
['矮萨']='矮萨哟:BAAALgAECgkJBAAAAA==.',
['石头']='石头梦想圣:BAAALgAFFAEJAgABLgAFFAMJDAAMAJQgAA==.石头梦想娃:BAACLgAFFH8MAAIMAAMJlCDcBgAzAQAMAAMJlCDcBgAzAQAuAAQKfxQAAwwACAlAH6kYAHUCAAwACAlAH6kYAHUCABYAAgmRBxN9AFAAAAAA.石头梦想法:BAABLgAECn8VAAIJAAcJcREaoACWAQAJAAcJcREaoACWAQABLgAFFAMJDAAMAJQgAA==.石头梦想萨:BAABLgAFFH8GAAIBAAMJ5hV0CgCfAAABAAMJ5hV0CgCfAAABLgAFFAMJDAAMAJQgAA==.',
['破晓']='破晓前忘掉丶:BAAALgAECgYJBgAAAA==.',
['神的']='神的传说:BAAALgAECgQJBQAAAA==.',
['福星']='福星高照:BAAALgAFFAIJAwAAAA==.',
['稻秧']='稻秧:BAAALgAFFAIJAgAAAA==.',
['章知']='章知白的香吻:BAAALgAECgQJBAAAAA==.',
['箭客']='箭客:BAAALgAECgEJAQAAAA==.',
['繧姰']='繧姰:BAAALgAECgEJAgAAAA==.',
['纞戦']='纞戦狼哥:BAAALgAFFAEJAQAAAA==.',
['耳濡']='耳濡牧染:BAAALgAFFAUJBAABLgAFFAcJEAARAHgaAA==.',
['聖方']='聖方濟各:BAABLgAECn8WAAMGAAgJAB8EEgBRAgAGAAcJmSAEEgBRAgAHAAcJ0hvBDgBPAgAAAA==.',
['肉熊']='肉熊猫不好吃:BAAALgAFFAMJBAAAAA==.',
['胖胖']='胖胖的老公:BAACLgAFFH8MAAIJAAcJchg6AQCtAgAJAAcJchg6AQCtAgAuAAQKfxYAAgkACAlqISITADUDAAkACAlqISITADUDAAAA.',
['舒克']='舒克:BAAALgAFFAIJAwAAAA==.',
['花脸']='花脸博迪:BAAALgAECgIJAgAAAA==.',
['花落']='花落半秋:BAAALgADCgYJBgAAAA==.',
['花螺']='花螺:BAAALgAECgIJAQAAAA==.',
['若蒺']='若蒺若藜:BAACLgAFFH8GAAIMAAMJhRYPCQAZAQAMAAMJhRYPCQAZAQAuAAQKfxoAAwwABwkwIV0cAFwCAAwABwkwIV0cAFwCABYAAQm7CWqMAC8AAAAA.',
['菊丶']='菊丶希尔芬:BAAALgAFFAIJAgAAAA==.',
['落花']='落花黯然:BAAALgADCgYJBgAAAA==.',
['蜜蜂']='蜜蜂公爵:BAAALgAECgEJAQAAAA==.',
['血灵']='血灵儿:BAAALgAECgYJBgAAAA==.',
['行云']='行云流水:BAAALgAECgEJAQAAAA==.',
['补药']='补药哇哇叫:BAAALgAECgUJBQAAAA==.',
['觉妹']='觉妹:BAAALgAECgYJBgAAAA==.',
['訷龍']='訷龍大俠:BAAALgAECgEJAQAAAA==.',
['试玩']='试玩一夏:BAAALgAECgYJEQAAAA==.',
['败家']='败家玩意:BAAALgADCgcJBwAAAA==.',
['输入']='输入错误:BAAALgAECgEJAQAAAA==.',
['辣鸡']='辣鸡噬灭:BAAALgAECgYJBgAAAA==.',
['这招']='这招就很厉害:BAAALgADCgYJCAAAAA==.',
['逐风']='逐风者:BAAALgADCgYJCAAAAA==.',
['逸凤']='逸凤光辉:BAABLgAFFH8GAAIVAAIJUB+6EQDAAAAVAAIJUB+6EQDAAAAAAA==.',
['遗忘']='遗忘的魂:BAAALgAECgYJBgAAAA==.',
['钟声']='钟声:BAACLgAFFH8IAAIXAAMJxArNAgAAAQAXAAMJxArNAgAAAQAuAAQKfxwAAhcACAkuII4DAIwCABcACAkuII4DAIwCAAAA.',
['钢筋']='钢筋:BAAALgAECgYJCwAAAA==.',
['铁甲']='铁甲你懂的:BAACLgAFFH8HAAIDAAMJ0gikCQC1AAADAAMJ0gikCQC1AAAuAAQKfxYAAgMABwltDjgcAGgBAAMABwltDjgcAGgBAAAA.',
['队友']='队友都是部落:BAAALgAECgYJBgAAAA==.',
['阿尔']='阿尔巴菲卡:BAAALgAECgYJEAAAAA==.',
['陆十']='陆十五:BAAALgAECgIJAwABLgAFFAQJBAAKAAAAAA==.',
['陆筱']='陆筱凤:BAACLgAFFH8KAAIYAAMJiglTGADqAAAYAAMJiglTGADqAAAuAAQKfyIAAhgACAmsGY9FABMCABgACAmsGY9FABMCAAAA.',
['陌生']='陌生人的故事:BAAALgAECgYJBgAAAA==.',
['隔壁']='隔壁家的喵大:BAAALgAFFAIJAgAAAA==.',
['雪舞']='雪舞:BAAALgADCgYJBgAAAA==.',
['雷尐']='雷尐狼:BAAALgAFFAEJAQAAAA==.',
['霉霉']='霉霉的汤圆:BAABLgAFFH8FAAITAAIJziEFFADIAAATAAIJziEFFADIAAAAAA==.',
['霰雪']='霰雪凝香:BAAALgAFFAMJBAAAAA==.',
['颓废']='颓废丨死骑:BAAALgADCgYJBQAAAA==.',
['风吹']='风吹纸片人:BAAALgAECgEJAQAAAA==.',
['飞月']='飞月:BAACLgAFFH8PAAIJAAUJSRSuCgDJAQAJAAUJSRSuCgDJAQAuAAQKfxkAAgkABwkkHm5YADACAAkABwkkHm5YADACAAAA.',
['高胖']='高胖帅:BAAALgADCgEJAQAAAA==.',
['魔法']='魔法之羊:BAABLgAFFH8FAAIMAAMJzhKDBwALAQAMAAMJzhKDBwALAQAAAA==.',
['魔灵']='魔灵娃娃:BAAALgAECgQJBAAAAA==.',
['鲁拉']='鲁拉里:BAAALgAECgYJCgAAAA==.',
['麦粥']='麦粥粥:BAAALgADCgEJAQAAAA==.',
['黑禮']='黑禮服:BAAALgADCgYJBgAAAA==.',
['黑色']='黑色卷云:BAAALgAECgEJAQAAAA==.',
['黑鎽']='黑鎽:BAAALgAFFAEJAQAAAA==.',
['黑锋']='黑锋:BAAALgAFFAEJAgABLgAFFAUJAQAKAAAAAA==.',
['黑龙']='黑龙王子:BAAALgAECgUJBQAAAA==.',
['黯月']='黯月小牛:BAAALgADCgMJAwAAAA==.',
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
