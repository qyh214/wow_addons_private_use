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

local lookup = {'Mage-Frost','DeathKnight-Blood','Paladin-Holy','Shaman-Restoration','Druid-Balance','Unknown-Unknown','Priest-Discipline','Hunter-Marksmanship','DeathKnight-Unholy','DeathKnight-Frost','Druid-Restoration','DemonHunter-Devourer','Hunter-BeastMastery','Shaman-Elemental','Evoker-Preservation','Evoker-Augmentation','Warlock-Demonology','Paladin-Retribution',}
local provider = {region='CN',realm='地狱咆哮',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aifushi:BAAALgAECgIJAgAAAA==.',
Av='Avalonmoon:BAAALgAECgQJBAAAAA==.',
Bl='Blacktober:BAAALgAFFAIJAQABLgAFFAQJDAABAEUVAA==.',
Co='Cock:BAAALgAECgYJDwAAAA==.',
Cr='Cruelsummer:BAAALgAFFAEJAgAAAA==.',
Da='Daftpunk:BAAALgAECgkJCQAAAA==.',
Em='Embracer:BAAALgAECgYJDAAAAA==.',
Fa='Fayne:BAAALgAECgQJCQAAAA==.',
Fu='Fu:BAAALgAFFAEJAgAAAA==.',
Gi='Gilberta:BAAALgADCgMJAwAAAA==.',
Ke='Kerridry:BAAALgAECgMJAwAAAA==.',
Li='Liubov:BAAALgAECgMJAgAAAA==.',
Lu='Lugekit:BAAALgAFFAMJAwABLgAFFAUJDAABAJUiAA==.Luminos:BAAALgADCgUJBQAAAA==.',
Me='Meltryllis:BAABLgAFFH8GAAICAAIJlxViDQCXAAACAAIJlxViDQCXAAAAAA==.',
Mo='Moly:BAAALgAECgcJBgAAAA==.',
Ne='Nerevar:BAAALgAECgMJBAAAAA==.',
Ra='Ravi:BAABLgAFFH8HAAIDAAIJjB1wEgC3AAADAAIJjB1wEgC3AAAAAA==.',
Re='Reki:BAAALgAFFAEJAQAAAA==.Repairx:BAAALgADCgIJAgAAAA==.',
Sw='Sweetest:BAAALgAECgMJBAAAAA==.',
Ta='Tatyun:BAAALgAECgYJBgAAAA==.',
Yu='Yuchen:BAAALgAECgkJCQAAAA==.',
['一血']='一血色浪漫一:BAAALgAECgEJAQAAAA==.',
['三月']='三月万物苏:BAAALgAFFAEJAQAAAA==.',
['下暴']='下暴雨:BAAALgAFFAIJAwAAAA==.',
['下次']='下次我请:BAAALgADCgEJAgAAAA==.',
['不祥']='不祥焰灵:BAAALgADCgEJAQAAAA==.',
['不能']='不能叫我小德:BAAALgADCgUJBgAAAA==.不能救赎:BAAALgADCgcJBwAAAA==.不能鲁莽:BAAALgAECgQJBAAAAA==.',
['丶皮']='丶皮卡丘:BAABLgAFFH8GAAIEAAMJ7RjwDAAMAQAEAAMJ7RjwDAAMAQAAAA==.',
['丶笨']='丶笨笨丶:BAAALgAFFAIJAgAAAA==.',
['乌夜']='乌夜啼:BAAALgAECgEJAQAAAA==.',
['乐可']='乐可:BAAALgAECgYJCgAAAA==.',
['乖一']='乖一点就抱你:BAAALgADCgEJAQAAAA==.',
['乖小']='乖小乖:BAAALgAECgUJBQAAAA==.',
['二丶']='二丶爺:BAAALgAECgEJAwAAAA==.',
['云丶']='云丶飘飘:BAAALgAECgYJBgAAAA==.',
['亚尔']='亚尔特留斯:BAAALgAECgQJBAAAAA==.',
['今晚']='今晚打大脑斧:BAAALgAECgUJBQAAAA==.',
['佚名']='佚名:BAAALgADCgUJBQAAAA==.',
['你不']='你不要再说了:BAACLgAFFH8IAAIBAAQJNQw0HgBRAQABAAQJNQw0HgBRAQAuAAQKfxYAAgEACQn7GIMkAOACAAEACQn7GIMkAOACAAAA.',
['你想']='你想不到吧:BAAALgAECgYJDAAAAA==.',
['你被']='你被牛打过:BAABLgAFFH8IAAIFAAQJOhiVCABZAQAFAAQJOhiVCABZAQAAAA==.',
['修修']='修修:BAAALgAECgQJAwAAAA==.',
['傲之']='傲之囚牛:BAAALgAECgEJAQAAAA==.',
['元气']='元气满满:BAACLgAFFH8MAAIBAAQJRRWiGgBgAQABAAQJRRWiGgBgAQAuAAQKfxsAAgEACAmaHqUtALsCAAEACAmaHqUtALsCAAAA.',
['军士']='军士:BAAALgAECgcJCgAAAA==.',
['冢虎']='冢虎丨司馬懿:BAAALgAFFAIJAgAAAA==.',
['冯福']='冯福:BAAALgAFFAEJAgAAAA==.',
['冰阔']='冰阔乐:BAAALgAFFAIJAgAAAA==.',
['凡人']='凡人皆需侍奉:BAAALgADCgYJBQABLgAFFAIJAgAGAAAAAA==.',
['凯莉']='凯莉娅丶怒风:BAAALgAECgYJCgAAAA==.',
['前面']='前面欧巴猛熊:BAAALgAECgEJAQAAAA==.前面欧巴猛猪:BAAALgADCgEJAQAAAA==.前面欧巴猛龙:BAAALgAECgYJCQAAAA==.',
['剑在']='剑在人在丶:BAAALgAFFAEJAQAAAA==.',
['劍心']='劍心無痕:BAAALgAFFAIJBAAAAA==.',
['加尓']='加尓鲁什丶:BAAALgADCgIJAgAAAA==.加尓鲁什灬:BAAALgAECgcJDAAAAA==.',
['南笙']='南笙:BAAALgAECgQJBAAAAA==.',
['卡卡']='卡卡子:BAAALgAECgMJBAAAAA==.',
['去明']='去明天看看:BAAALgAECgYJDAAAAA==.',
['另一']='另一种冷艳:BAAALgADCgEJAQAAAA==.',
['只会']='只会圣言术丶:BAAALgADCgIJAgAAAA==.',
['右手']='右手拉着妞:BAAALgADCgQJBAAAAA==.',
['叶十']='叶十七:BAAALgADCgEJAQAAAA==.',
['叶妮']='叶妮芙:BAAALgADCgEJAQAAAA==.',
['司马']='司马懿:BAAALgAECgYJAQAAAA==.',
['吃我']='吃我一击吧丶:BAAALgADCgEJAQAAAA==.',
['吃根']='吃根冰棒吧:BAAALgAECgYJDwAAAA==.',
['吴与']='吴与伦比丶猎:BAAALgADCgYJBQAAAA==.',
['吼克']='吼克:BAAALgADCgEJAQAAAA==.',
['呉朙']='呉朙丨七:BAAALgAFFAQJAgAAAA==.呉朙丨六:BAAALgAFFAUJAgAAAA==.呉朙丨四:BAABLgAFFH8GAAIHAAQJeSF7FACSAAAHAAQJeSF7FACSAAAAAA==.',
['咆哮']='咆哮牛猎:BAAALgAECgQJBQAAAA==.',
['咕噜']='咕噜咕噜咕噜:BAAALgADCgEJAQAAAA==.',
['哈莱']='哈莱尼的哈森:BAAALgAECgUJBwAAAA==.',
['哔卟']='哔卟哩哄丶:BAAALgAECgUJBQAAAA==.',
['哦啦']='哦啦嘿哟:BAAALgAFFAEJAQAAAA==.',
['唯吾']='唯吾知足:BAAALgADCgEJAQAAAA==.',
['嘘丶']='嘘丶别说了:BAAALgAECgcJCgAAAA==.',
['土狗']='土狗蛋子:BAAALgAECgEJAgAAAA==.',
['地狱']='地狱火咔:BAAALgADCgMJAwAAAA==.',
['坚韧']='坚韧不屈:BAAALgAECgYJCgAAAA==.',
['塞尔']='塞尔达:BAAALgAECggJCAAAAA==.',
['墨墨']='墨墨哒:BAAALgAECgUJCQAAAA==.',
['夏夜']='夏夜灬微凉:BAAALgAECgQJBwAAAA==.',
['夏木']='夏木:BAAALgAECgQJBQAAAA==.',
['夜色']='夜色无痕:BAAALgAECgIJAgAAAA==.',
['大笨']='大笨牛啊:BAAALgAECgYJCwAAAA==.',
['大肉']='大肉妞儿:BAABLgAFFH8IAAIIAAMJ9SJXDwA3AQAIAAMJ9SJXDwA3AQABLgAFFAUJCQAEAHoNAA==.',
['大舅']='大舅的大舅:BAAALgAECgYJCwAAAA==.',
['大鼻']='大鼻涕火牛:BAAALgAFFAIJAwAAAA==.',
['天猫']='天猫精灵:BAAALgAECgEJAgAAAA==.',
['天空']='天空无我:BAAALgAECgYJBgAAAA==.',
['奥尔']='奥尔斯帝德:BAAALgADCgYJBgAAAA==.',
['女部']='女部田郁子:BAAALgAECgYJEAAAAA==.',
['奶油']='奶油曲奇:BAAALgADCgEJAQAAAA==.',
['好看']='好看的姑娘:BAAALgAECgYJBgAAAA==.',
['妳給']='妳給的回忆:BAAALgADCgUJBQAAAA==.',
['姑苏']='姑苏四爷:BAAALgAECgEJAQAAAA==.',
['威少']='威少:BAACLgAFFH8IAAMJAAMJjRheIgAOAQAJAAMJ/BdeIgAOAQAKAAEJ/gjQAgBPAAAuAAQKfyMAAgkACAk3IsISAAsDAAkACAk3IsISAAsDAAAA.',
['孢子']='孢子菇牙牙:BAAALgAFFAEJAQAAAA==.',
['小烧']='小烧狗:BAACLgAFFH8GAAILAAIJGCahEADkAAALAAIJGCahEADkAAAuAAQKfygAAgsACAlZJugBAIIDAAsACAlZJugBAIIDAAAA.',
['小耳']='小耳朵猫猫:BAAALgADCgQJBAAAAA==.',
['小雨']='小雨润如酥:BAABLgAFFH8JAAIMAAUJWSPtAwD2AQAMAAUJWSPtAwD2AQAAAA==.',
['小魚']='小魚:BAAALgAECgcJBwAAAA==.',
['小黑']='小黑经纪人:BAAALgAECgEJAQAAAA==.',
['尖牙']='尖牙土豆蘑:BAAALgAECgMJAwAAAA==.',
['尝试']='尝试切中路:BAAALgAECgkJCQAAAA==.',
['就我']='就我快乐:BAAALgAECgMJBgAAAA==.',
['已然']='已然消逝:BAAALgAECgcJCwAAAA==.',
['帅的']='帅的被人砍:BAAALgADCgYJBgAAAA==.',
['师尊']='师尊:BAAALgAECgEJAQAAAA==.',
['平原']='平原追猎者:BAAALgAECgEJAQAAAA==.',
['幻化']='幻化成风:BAAALgADCgcJBwAAAA==.',
['废教']='废教授:BAAALgAFFAEJAQAAAA==.',
['康娜']='康娜:BAAALgADCgYJBgAAAA==.',
['德恩']='德恩菲尔:BAAALgAECgMJAwAAAA==.',
['快龙']='快龙:BAAALgAFFAIJBAAAAA==.',
['怒瘋']='怒瘋:BAAALgADCgEJAQAAAA==.',
['恰北']='恰北北:BAAALgAECgYJBgAAAA==.',
['恶魔']='恶魔领主:BAAALgAECgEJAQAAAA==.',
['悠带']='悠带刀:BAAALgAFFAEJAQAAAA==.',
['悠然']='悠然战鋒:BAAALgADCgEJAQAAAA==.',
['惊蛰']='惊蛰小龙女:BAAALgAFFAIJAgAAAA==.',
['愤怒']='愤怒的少年:BAAALgAECgEJAgAAAA==.',
['慑天']='慑天:BAAALgAECgcJDQAAAA==.',
['我是']='我是圣骑:BAAALgAECgEJAQAAAA==.',
['我的']='我的世界绽放:BAAALgAECgEJAwAAAA==.',
['戦地']='戦地修羅:BAAALgAECgMJAwAAAA==.',
['散落']='散落的烟灰:BAAALgAFFAIJAgAAAA==.',
['旋一']='旋一个:BAAALgAECgcJBgAAAA==.',
['无敌']='无敌牛肉饭:BAAALgADCgUJBQAAAA==.',
['星空']='星空的华尔兹:BAAALgAECgQJBAAAAA==.',
['春兰']='春兰:BAAALgAECgEJAQAAAA==.',
['暗夜']='暗夜火球:BAAALgAECgMJAwAAAA==.',
['有个']='有个点子丶:BAAALgAECgMJAwAAAA==.',
['杨多']='杨多多:BAAALgAFFAEJAQAAAA==.',
['林深']='林深小鹿:BAAALgADCgMJAwAAAA==.',
['枫林']='枫林晚:BAAALgADCgIJAgAAAA==.',
['枼十']='枼十七:BAAALgADCgUJBQAAAA==.',
['柄机']='柄机:BAAALgADCgQJBAAAAA==.',
['格兰']='格兰杰的守护:BAAALgAECgQJBgAAAA==.格兰杰的护法:BAAALgAECgEJAgAAAA==.',
['梅登']='梅登:BAAALgAECgQJAQAAAA==.',
['梧桐']='梧桐:BAAALgAECgQJCwAAAA==.',
['残枫']='残枫秋落:BAAALgAFFAEJAQAAAA==.',
['毁之']='毁之殇:BAAALgAECgEJAQAAAA==.',
['毛头']='毛头笨笨:BAAALgAECgIJAQAAAA==.',
['汉堡']='汉堡配炸鸡:BAAALgAECgcJEAAAAA==.汉堡配薯条:BAAALgAECgYJDQAAAA==.',
['江湖']='江湖夜雨:BAAALgAECgEJAQAAAA==.',
['沐浴']='沐浴春风:BAAALgAECgYJCgAAAA==.',
['沫茉']='沫茉:BAAALgAECgEJAQAAAA==.',
['法師']='法師肆肆幺丶:BAAALgAECgkJEwAAAA==.',
['泰兰']='泰兰德羽月:BAABLgAECn8VAAINAAcJrBUeMQDrAQANAAcJrBUeMQDrAQAAAA==.',
['洃羽']='洃羽傀儡:BAAALgAECgMJBgAAAA==.',
['洗衣']='洗衣龙女:BAAALgADCgEJAQAAAA==.',
['洛丶']='洛丶小球:BAABLgAFFH8HAAIBAAMJTgtNLgD9AAABAAMJTgtNLgD9AAAAAA==.',
['浆糊']='浆糊奥术大师:BAAALgAECgQJBAAAAA==.',
['涮牛']='涮牛肉:BAAALgAFFAQJBAAAAA==.',
['渣女']='渣女一抬腿:BAAALgAECgIJAgAAAA==.',
['温柔']='温柔的小骚年:BAAALgAECgYJDAAAAA==.',
['溪涨']='溪涨清风拂面:BAAALgADCgIJAgAAAA==.',
['漩涡']='漩涡大雄:BAAALgAECgYJBQAAAA==.',
['灌肠']='灌肠高手:BAABLgAFFH8GAAILAAIJzxHfHQCFAAALAAIJzxHfHQCFAAAAAA==.',
['火柴']='火柴:BAAALgAFFAIJBAAAAA==.',
['灬星']='灬星约灬:BAAALgAECggJCAAAAA==.',
['灬铁']='灬铁血战魂灬:BAABLgAECn8gAAMIAAgJfRKANQCQAQAIAAcJXxCANQCQAQANAAQJoREliADQAAAAAA==.',
['炸灌']='炸灌肠儿:BAAALgAECgYJBgAAAA==.',
['焰逐']='焰逐风飞:BAAALgAECgIJAwAAAA==.',
['爱我']='爱我永远:BAAALgAECgQJBAAAAA==.',
['狼之']='狼之笑:BAABLgAFFH8KAAMOAAQJqxJ7CwAyAQAOAAQJqxJ7CwAyAQAEAAEJEgZJIQBMAAAAAA==.',
['猎天']='猎天者:BAAALgADCgMJAwAAAA==.',
['猫的']='猫的哲学:BAAALgAECgYJEQAAAA==.',
['玩笑']='玩笑:BAAALgAECgEJAQAAAA==.',
['珍妮']='珍妮马仕多:BAAALgAECgcJCgAAAA==.',
['瑰夏']='瑰夏:BAAALgAECgYJDQAAAA==.',
['瓦莉']='瓦莉亚:BAAALgAECgYJCAAAAA==.',
['甜桃']='甜桃子:BAAALgAECgcJBwAAAA==.',
['甲乙']='甲乙丙丁:BAABLgAECn8WAAMPAAYJjRhoBQBTAQAPAAYJjRhoBQBTAQAQAAMJzAbUUQCCAAAAAA==.',
['畅想']='畅想在拜姆纳:BAAALgAECgEJAQAAAA==.',
['疯一']='疯一样的女子:BAAALgAECgYJCwAAAA==.',
['疯潇']='疯潇骁丶:BAAALgADCgUJBQAAAA==.',
['疯癫']='疯癫丶晓翼:BAAALgAECgUJCAAAAA==.疯癫丶湮翼:BAAALgAECgcJDQAAAA==.',
['睡着']='睡着的小鱼:BAAALgAECgUJBwAAAA==.',
['破空']='破空长箭:BAAALgAECgMJBgAAAA==.',
['神锣']='神锣天征:BAAALgAECgYJCAAAAA==.',
['禁书']='禁书:BAAALgAECgYJBgAAAA==.',
['筱牙']='筱牙:BAAALgAECgcJBwAAAA==.',
['红尘']='红尘丶二两:BAAALgADCgUJBgAAAA==.',
['翳小']='翳小云:BAAALgADCgUJBAAAAA==.',
['老姬']='老姬奇遇记:BAAALgAECgQJAwABLgAFFAQJDAABAEUVAA==.',
['肥嘟']='肥嘟嘟佐卫门:BAAALgADCgMJAwAAAA==.',
['背叛']='背叛者之歌:BAAALgAECgYJBgAAAA==.',
['胡子']='胡子妈妈:BAAALgAECgYJDAAAAA==.',
['能扛']='能扛:BAAALgAECgIJAQAAAA==.',
['脂虎']='脂虎:BAAALgAECgQJAwAAAA==.',
['艰难']='艰难的抉择:BAAALgAECgEJAQAAAA==.',
['艾木']='艾木蹄:BAAALgAECgQJAQAAAA==.',
['花臂']='花臂东爷:BAAALgAECgYJDAABLgAECggJCAAGAAAAAA==.',
['苍白']='苍白的正义:BAAALgAECgYJCQAAAA==.',
['英雄']='英雄玛卡多:BAAALgAECgYJDgAAAA==.',
['莉莉']='莉莉黄:BAAALgADCgEJAQAAAA==.',
['萨拉']='萨拉托斯:BAAALgAECgYJBgAAAA==.',
['萨魂']='萨魂:BAAALgADCgMJAwAAAA==.',
['落寞']='落寞丶煙愺菋:BAACLgAFFH8KAAIDAAQJwh2SDQAAAQADAAQJwh2SDQAAAQAuAAQKf0sAAgMACAnYGQIgABoCAAMACAnYGQIgABoCAAAA.',
['虎皮']='虎皮巴拉:BAAALgADCgMJAwAAAA==.',
['虚妄']='虚妄丶:BAAALgAECgkJAQAAAA==.',
['蜻蜓']='蜻蜓队长:BAAALgAECgMJBAAAAA==.',
['血月']='血月红莲:BAAALgAECgEJAQAAAA==.',
['被遗']='被遗忘的弦月:BAAALgAECgQJBwAAAA==.',
['西西']='西西丶:BAAALgAFFAEJAQAAAA==.',
['諾森']='諾森德的雪:BAAALgAECgEJAQAAAA==.',
['说屁']='说屁:BAAALgADCgEJAQAAAA==.',
['谷雨']='谷雨:BAAALgAECgcJDgAAAA==.',
['贫穷']='贫穷的丽丽:BAAALgAECgMJAwAAAA==.',
['赵老']='赵老湿:BAAALgAECgEJAgAAAA==.',
['超大']='超大榛果拿铁:BAAALgAECggJDQAAAA==.',
['超级']='超级莼菜:BAAALgAECgUJCAAAAA==.',
['辣鸡']='辣鸡有喜:BAAALgAECggJCAAAAA==.',
['辻詩']='辻詩音:BAAALgADCgUJBQAAAA==.',
['还君']='还君明珠泪:BAAALgAECgIJAgAAAA==.',
['這感']='這感覚好奇怪:BAAALgAECgEJAQAAAA==.',
['速影']='速影:BAAALgAECgQJBAAAAA==.',
['遗忘']='遗忘的傳説:BAAALgADCgEJAQAAAA==.',
['醉后']='醉后一夜:BAAALgADCgEJAQABLgAFFAQJCgADAMIdAA==.',
['醉流']='醉流年:BAAALgAECgMJAwAAAA==.',
['采药']='采药:BAAALgAFFAIJBAAAAA==.',
['量化']='量化研究方法:BAAALgAECgYJBgAAAA==.',
['鍪門']='鍪門麰羰:BAABLgAFFH8FAAIRAAUJxhpCBgC9AQARAAUJxhpCBgC9AQAAAA==.',
['锦宝']='锦宝:BAAALgAECgMJBgAAAA==.',
['间歇']='间歇发疯体:BAABLgAFFH8FAAISAAIJ9hDeKACVAAASAAIJ9hDeKACVAAAAAA==.',
['阳光']='阳光真灿烂:BAAALgAECgkJCQAAAA==.',
['阴影']='阴影暗迹丶:BAAALgADCgYJCAAAAA==.',
['阿尔']='阿尔托莉亞:BAAALgAECgYJCwAAAA==.',
['随风']='随风雾行:BAAALgAECgEJAQAAAA==.',
['雪景']='雪景凌塾:BAAALgAECgEJAQAAAA==.',
['青木']='青木琉璃:BAAALgAECgEJAQAAAA==.',
['非洲']='非洲之心:BAAALgAECgYJCQAAAA==.',
['风暴']='风暴之灵:BAABLgAFFH8KAAMOAAQJng+4CgA6AQAOAAQJng+4CgA6AQAEAAMJGg0YEQDfAAAAAA==.',
['风筝']='风筝与风:BAAALgAECgEJAQAAAA==.',
['飘逸']='飘逸的飞:BAAALgAECgEJAQAAAA==.',
['饭球']='饭球:BAAALgAECgUJBQAAAA==.',
['饼弓']='饼弓纸法:BAAALgAECgEJAQAAAA==.',
['马大']='马大俊:BAABLgAFFH8DAAIRAAMJjyByHgBkAAARAAMJjyByHgBkAAAAAA==.',
['魑魅']='魑魅狐:BAACLgAFFH8FAAIBAAIJ+B3mNADDAAABAAIJ+B3mNADDAAAuAAQKfxQAAgEABgm1IwFaACsCAAEABgm1IwFaACsCAAAA.',
['鱼波']='鱼波波:BAAALgAECgMJAwAAAA==.',
['鱼鲜']='鱼鲜生:BAAALgADCgEJAQAAAA==.',
['鸠地']='鸠地震法:BAAALgAECgEJAQAAAA==.',
['黯灭']='黯灭黯灭:BAAALgAECgYJDgAAAA==.',
['龙源']='龙源:BAAALgAECgQJBgAAAA==.龙源梵:BAAALgAECgIJAgAAAA==.',
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
