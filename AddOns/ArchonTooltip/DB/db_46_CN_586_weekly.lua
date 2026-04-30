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

local lookup = {'Warrior-Fury','Evoker-Devastation','Evoker-Preservation','DeathKnight-Unholy','DeathKnight-Frost','Rogue-Subtlety','Mage-Frost','Priest-Holy','Warlock-Demonology','Shaman-Elemental','Warrior-Protection','Monk-Brewmaster','Druid-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Unknown-Unknown','Paladin-Retribution','Paladin-Holy','DeathKnight-Blood','Shaman-Restoration','DemonHunter-Devourer','Hunter-Survival','Mage-Arcane',}
local provider = {region='CN',realm='凯恩血蹄',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alxamuren:BAAALgAECgYJCwAAAA==.',
Am='Ame:BAAALgAECgEJAQAAAA==.',
Bb='Bbt:BAABLgAFFH8GAAIBAAMJHhC4EwDhAAABAAMJHhC4EwDhAAAAAA==.',
Bl='Blacksun:BAAALgADCgMJAwAAAA==.',
Ch='Christao:BAAALgAECgQJCAAAAA==.',
Du='Dullahan:BAAALgAECgYJCQAAAA==.',
Fl='Fliedmiles:BAABLgAECn8WAAICAAgJwBXgAAD7AQACAAgJwBXgAAD7AQAAAA==.',
In='Iniani:BAABLgAFFH8FAAIDAAQJMwhBDAAkAQADAAQJMwhBDAAkAQAAAA==.',
Ir='Irelia:BAABLgAECn8YAAMEAAYJZBpQcwCgAQAEAAYJZBpQcwCgAQAFAAIJrw1/EgBpAAAAAA==.',
Jj='Jjenqiaxmhgd:BAAALgAFFAIJAgABLgAFFAQJDgAGAPsdAA==.',
Ki='Kikoru:BAAALgAFFAEJAQAAAA==.',
Ly='Lyerch:BAAALgAECgYJCgAAAA==.',
Mv='Mv:BAAALgAECgYJCwAAAA==.',
Ni='Nian:BAAALgAECgQJBAAAAA==.',
Su='Sulascarlet:BAABLgAFFH8FAAIHAAMJ+Ap8EwD5AAAHAAMJ+Ap8EwD5AAAAAA==.',
Wo='Wooblackhoof:BAAALgADCgIJAQAAAA==.',
['一脚']='一脚爆蛋:BAACLgAFFH8GAAIIAAQJbiAnAgCSAQAIAAQJbiAnAgCSAQAuAAQKfxUAAggABwm4I7AKAKICAAgABwm4I7AKAKICAAAA.',
['与众']='与众不瞳:BAAALgAECgYJBwAAAA==.',
['丘彼']='丘彼特射你臀:BAAALgADCgEJAQAAAA==.',
['丨不']='丨不练剑了丨:BAAALgAECgYJBgAAAA==.',
['丨明']='丨明混大帝丨:BAAALgAECgYJBgABLgAFFAQJCQAJAJYUAA==.',
['丨远']='丨远征丨:BAAALgAECgEJAQAAAA==.',
['中指']='中指朝天立:BAAALgAECgIJAgAAAA==.',
['丶丨']='丶丨朮師:BAAALgAECgYJBgAAAA==.',
['丶初']='丶初见:BAAALgAECgYJCAAAAA==.',
['丶时']='丶时倾:BAAALgAFFAIJAwAAAA==.',
['为你']='为你而来:BAAALgAECgYJBwAAAA==.',
['乂根']='乂根基丷:BAAALgAECgIJAgAAAA==.',
['乔乔']='乔乔飞天潴:BAAALgAECgEJAQAAAA==.',
['乖乖']='乖乖满宝:BAAALgADCgUJBQAAAA==.',
['九重']='九重:BAAALgAECgEJAwAAAA==.',
['了布']='了布德:BAAALgAFFAIJAwAAAA==.',
['事了']='事了拂身去:BAAALgAECgEJAQAAAA==.',
['二四']='二四零下铺:BAAALgAECgEJAQAAAA==.',
['云隐']='云隐雷霆:BAABLgAFFH8GAAIKAAMJFQSXGQCKAAAKAAMJFQSXGQCKAAAAAA==.',
['什么']='什么砖家:BAAALgAECgYJDQAAAA==.',
['你充']='你充币没:BAAALgAECgYJCwAAAA==.',
['俊克']='俊克总总:BAAALgAFFAIJBAAAAA==.',
['偶心']='偶心飞翔:BAAALgAECgYJCQAAAA==.',
['冰冰']='冰冰有火:BAAALgAFFAIJAgAAAA==.',
['冰绫']='冰绫之光:BAAALgAECggJCAAAAA==.',
['决明']='决明:BAAALgAFFAQJBAAAAA==.',
['凯兰']='凯兰崔尔:BAAALgADCgIJAgAAAA==.',
['初南']='初南:BAAALgAECgkJCQABLgAECgkJFwALAMAcAA==.',
['口亨']='口亨:BAAALgAECgIJAgAAAA==.',
['古饵']='古饵丹丨远征:BAAALgAECgEJAgAAAA==.',
['可爱']='可爱的神奇:BAAALgADCgIJAgAAAA==.',
['史蒂']='史蒂夫考:BAAALgADCgYJBgAAAA==.',
['吴风']='吴风:BAAALgAECgIJAgAAAA==.',
['味淡']='味淡得卤一下:BAAALgAECgcJCgAAAA==.',
['咬卵']='咬卵犟丶:BAAALgAECgMJBQAAAA==.',
['哀仇']='哀仇:BAAALgAECgQJCAAAAA==.',
['哟西']='哟西:BAAALgADCgcJCgAAAA==.',
['唯有']='唯有青灯伴:BAAALgAECgcJBAAAAA==.',
['善战']='善战乄右手:BAAALgADCgEJAQAAAA==.',
['圣意']='圣意女神娟娟:BAAALgAECgEJAQAAAA==.',
['圣殿']='圣殿丶流星:BAAALgAECggJEAAAAA==.',
['坦白']='坦白:BAABLgAFFH8LAAIMAAQJoxycAgBfAQAMAAQJoxycAgBfAQAAAA==.',
['壹米']='壹米捌叁:BAAALgAECgEJAQAAAA==.壹米捌柒:BAAALgAECgYJBwAAAA==.',
['夜小']='夜小柒:BAAALgAECgcJBwAAAA==.',
['大力']='大力川川:BAAALgAECgUJBwAAAA==.',
['大棒']='大棒槌:BAAALgAECgYJCgAAAA==.',
['天佑']='天佑晨曦:BAAALgAECgEJAQAAAA==.',
['天堂']='天堂的蓝调:BAAALgAECgYJEwAAAA==.',
['天王']='天王盖地虎丨:BAAALgAECgEJAgAAAA==.',
['奎尔']='奎尔萨拉之怒:BAAALgADCgYJBgAAAA==.',
['奔放']='奔放的小番茄:BAABLgAFFH8FAAIEAAIJCBG4RwCVAAAEAAIJCBG4RwCVAAAAAA==.',
['好运']='好运:BAAALgAECgQJBAABLgAFFAQJDgAHAHAPAA==.',
['如法']='如法炮制:BAAALgAECgUJBQAAAA==.',
['宇众']='宇众不佟:BAAALgADCgYJBgAAAA==.',
['宇智']='宇智波卡卡西:BAAALgAECggJDQAAAA==.',
['安布']='安布罗休:BAAALgAECgYJCgAAAA==.',
['宝宝']='宝宝很凶:BAAALgAFFAEJAQAAAA==.',
['审判']='审判:BAAALgAECgYJDgAAAA==.',
['审核']='审核通过:BAABLgAFFH8HAAIMAAQJ2xQHBAA/AQAMAAQJ2xQHBAA/AQAAAA==.',
['小哥']='小哥来也:BAAALgAECgYJCgAAAA==.',
['小小']='小小怪:BAAALgADCgIJAgAAAA==.',
['小弟']='小弟:BAAALgAECgcJCAAAAA==.',
['小熊']='小熊:BAAALgAECgYJCQAAAA==.',
['小牛']='小牛儿娟娟:BAAALgAECgIJAgAAAA==.',
['小磊']='小磊:BAAALgADCgEJAQAAAA==.',
['小舒']='小舒术:BAABLgAECn8nAAIJAAgJoSDQAwBQAgAJAAgJoSDQAwBQAgAAAA==.',
['尼酱']='尼酱的乖宝宝:BAACLgAFFH8UAAINAAYJwxLDAgDDAQANAAYJwxLDAgDDAQAuAAQKfyEAAg0ACQmtIMoKAOwCAA0ACQmtIMoKAOwCAAAA.',
['屠龙']='屠龙者:BAABLgAECn8dAAMOAAcJMx1GCADkAQAOAAcJMx1GCADkAQAPAAMJwwcJcAB+AAAAAA==.',
['嵿岌']='嵿岌心语:BAAALgADCgYJCwAAAA==.',
['工具']='工具人:BAAALgAECgcJCwABLgAFFAYJFAANAMMSAA==.',
['帝保']='帝保罗:BAAALgAECgEJAgAAAA==.',
['平安']='平安喜乐:BAAALgADCgUJBQAAAA==.',
['幽冥']='幽冥媚影:BAAALgAECgEJAQAAAA==.',
['弥离']='弥离:BAAALgAFFAQJBAAAAA==.',
['彭哥']='彭哥哥好帅:BAABLgAFFH8NAAIIAAQJHhD7BwDqAAAIAAQJHhD7BwDqAAABLgAFFAYJFAANAMMSAA==.',
['德莱']='德莱不是德鲁:BAAALgAFFAIJAgAAAA==.',
['怒空']='怒空残月:BAAALgAECgMJAwAAAA==.',
['思念']='思念丶果果:BAAALgAECgkJCQAAAA==.',
['恶之']='恶之煞:BAAALgAECgUJBwAAAA==.',
['愤怒']='愤怒的阿昆达:BAAALgAECgEJAQAAAA==.',
['我愛']='我愛壹條柴:BAAALgAECgIJAgAAAA==.',
['我是']='我是圣光牛:BAAALgADCgUJBQAAAA==.我是小明:BAAALgAECgIJAgAAAA==.我是牛吗:BAABLgAECn8VAAMNAAcJBwwZXgA3AQANAAcJBwwZXgA3AQAQAAQJJQ1PcgBXAAAAAA==.',
['我的']='我的锅儿:BAAALgADCgIJAgAAAA==.',
['戴尔']='戴尔李斯阿卡:BAAALgAECgYJCQAAAA==.戴尔菲娜:BAAALgAECgYJCgAAAA==.',
['拉粑']='拉粑粑小魔仙:BAAALgAECgQJBAAAAA==.',
['捕风']='捕风汉子:BAAALgAECgEJAQAAAA==.',
['掏你']='掏你裆间:BAAALgAECgcJCwAAAA==.',
['斗拱']='斗拱:BAAALgAECgYJBgAAAA==.',
['方向']='方向:BAAALgADCgEJAQAAAA==.',
['无上']='无上的圣光啊:BAAALgADCgUJBQAAAA==.',
['无尽']='无尽的苍穹:BAABLgAECn8VAAIHAAYJDyKBSABeAgAHAAYJDyKBSABeAgAAAA==.',
['无往']='无往不利:BAAALgADCgYJBgAAAA==.',
['无意']='无意风起:BAAALgAECgIJAgAAAA==.',
['昊凬']='昊凬:BAAALgAECgQJBQAAAA==.',
['星云']='星云:BAAALgAECgEJAQAAAA==.',
['星星']='星星偷我酒:BAAALgADCgYJBgAAAA==.',
['星绫']='星绫:BAAALgAECgEJAQAAAA==.',
['星陨']='星陨凡天:BAAALgAECgEJAQAAAA==.',
['是美']='是美雅呢:BAAALgAECgkJCQAAAA==.',
['晖梅']='晖梅之萨:BAAALgADCgcJBwAAAA==.',
['晴天']='晴天漠漠:BAAALgAECgQJCQAAAA==.',
['暮光']='暮光阿凡达:BAAALgAECgMJAgAAAA==.',
['曳曳']='曳曳风情:BAAALgAECgcJBwAAAA==.',
['月蚀']='月蚀的假面:BAAALgADCgUJBQAAAA==.',
['有种']='有种嫁给我:BAAALgADCgUJAgAAAA==.',
['木木']='木木夕丿:BAAALgAECgYJBgAAAA==.木木夕丿丨冫:BAAALgAECgYJBgAAAA==.',
['木犀']='木犀:BAAALgAECgcJBwABLgAFFAQJBAARAAAAAA==.',
['林雷']='林雷之梦:BAABLgAFFH8FAAMSAAIJJARBEgCOAAASAAIJJARBEgCOAAATAAEJTQEQIQAxAAAAAA==.',
['果师']='果师傅三:BAAALgAECgkJCQAAAA==.果师傅九:BAAALgAECgkJEAAAAA==.果师傅五:BAAALgAECgkJDQAAAA==.果师傅八:BAAALgAECgkJCAAAAA==.果师傅六:BAAALgAECgMJAQAAAA==.果师傅十七:BAAALgAECgcJBwAAAA==.果师傅十三:BAAALgAECgcJBwAAAA==.果师傅十五:BAAALgAECgkJDwAAAA==.果师傅十六:BAAALgAECgcJBwAAAA==.果师傅十四:BAAALgAECgkJCQAAAA==.果师傅四:BAAALgAECgkJCQAAAA==.',
['枫叶']='枫叶红了:BAAALgAECgcJEAAAAA==.',
['柠檬']='柠檬可乐:BAAALgAECgYJBgAAAA==.柠檬酸酸冰:BAAALgAECgYJBwAAAA==.柠檬酸铝:BAAALgAECgYJCgAAAA==.',
['核丨']='核丨桃:BAAALgAECgEJAQAAAA==.',
['格哥']='格哥:BAAALgAECgYJCAAAAA==.',
['梦回']='梦回珞珈:BAAALgAECgYJBgAAAA==.',
['梦幻']='梦幻神兜兜:BAAALgAECgYJBwAAAA==.',
['梧攸']='梧攸:BAAALgAECgcJAQAAAA==.',
['森林']='森林之心:BAAALgADCgcJBwABLgAFFAMJBgAKABUEAA==.',
['楽山']='楽山大佛:BAAALgAECgkJCQAAAA==.',
['死在']='死在天真里:BAAALgAECgEJAQAAAA==.',
['殇殇']='殇殇丶迪凯:BAABLgAECn8ZAAMEAAcJjA/OfwCDAQAEAAcJjA/OfwCDAQAUAAEJyQSQSgAhAAAAAA==.',
['殺戮']='殺戮机器:BAAALgAECgQJBAAAAA==.',
['毛了']='毛了个惩戒:BAAALgADCgcJBwAAAA==.',
['水樱']='水樱宮葵:BAAALgAECgkJAgABLgAFFAYJCgAVAHYKAA==.',
['沐少']='沐少爷丶拳师:BAAALgAECgUJBgAAAA==.沐少爷丶稀瓜:BAAALgAECgYJBgAAAA==.',
['波风']='波风皆人:BAAALgAECgEJAQAAAA==.',
['泥艾']='泥艾希我奶妈:BAAALgAECgMJAwAAAA==.',
['泰二']='泰二迪:BAAALgAECgEJAQAAAA==.',
['淼淼']='淼淼脆皮肠:BAAALgAECgUJBgABLgAFFAIJBAARAAAAAA==.',
['火影']='火影小肥朵:BAAALgAFFAMJBAAAAA==.火影摇摆龙王:BAACLgAFFH8NAAIBAAQJXCRpAACgAQABAAQJXCRpAACgAQAuAAQKfxQAAgEABwkrH2MbAHECAAEABwkrH2MbAHECAAAA.',
['炮灰']='炮灰向前冲:BAAALgADCgcJDQAAAA==.',
['炼狱']='炼狱兽兽:BAAALgAECgYJBgAAAA==.',
['烂木']='烂木头:BAAALgAECgEJAQAAAA==.',
['烟行']='烟行媚视:BAAALgAECgYJBgAAAA==.',
['焰之']='焰之曙光:BAABLgAECn8cAAISAAkJdhG8PwAnAgASAAkJdhG8PwAnAgAAAA==.',
['燕羽']='燕羽丶汗:BAAALgADCgEJAQAAAA==.',
['牛僧']='牛僧:BAAALgAECgEJAQAAAA==.',
['牛叉']='牛叉叉:BAAALgADCgQJBQAAAA==.',
['牛哈']='牛哈:BAAALgADCgMJAwAAAA==.',
['牛战']='牛战:BAAALgAECgMJAwAAAA==.',
['牢天']='牢天:BAAALgADCgIJAgAAAA==.',
['猎魔']='猎魔人:BAABLgAFFH8FAAIWAAUJygBEGQAFAQAWAAUJygBEGQAFAQAAAA==.',
['猫太']='猫太丶撼地柱:BAAALgADCgEJAQAAAA==.',
['猫脸']='猫脸雷公嘴丶:BAAALgAECgEJAgAAAA==.',
['玛奇']='玛奇玛:BAAALgAFFAEJAQABLgAFFAYJFAANAMMSAA==.',
['玛法']='玛法力奥撸风:BAAALgAECgEJAQAAAA==.',
['玛莎']='玛莎喇蒂:BAABLgAFFH8JAAISAAUJZAx/BgCHAQASAAUJZAx/BgCHAQAAAA==.',
['玫瑰']='玫瑰柳叶刀:BAAALgAECgEJAQAAAA==.',
['珀西']='珀西瓦尔:BAAALgAECgEJAgAAAA==.',
['癌丘']='癌丘:BAAALgAFFAIJAgAAAA==.',
['白刀']='白刀子进去:BAAALgAECgMJCQAAAA==.',
['百脉']='百脉:BAAALgAECgcJBwABLgAFFAQJBAARAAAAAA==.',
['祝丶']='祝丶踏风:BAAALgAECgEJAQAAAA==.',
['秀虎']='秀虎巉瀺:BAAALgAECgYJCAAAAA==.',
['科比']='科比布莱恩特:BAAALgAECgQJCwAAAA==.',
['秒雾']='秒雾:BAAALgAECgEJAQAAAA==.',
['笑丨']='笑丨傲天:BAAALgADCgEJAQABLgAECgQJBAARAAAAAA==.',
['筱莳']='筱莳光:BAAALgADCgUJBQAAAA==.',
['米迦']='米迦勒:BAAALgAFFAQJBAAAAA==.',
['素主']='素主:BAAALgAFFAIJBAABLgAFFAYJFAANAMMSAA==.',
['紫漪']='紫漪鱼儿飞:BAAALgADCgQJBAAAAA==.',
['红山']='红山哥布林:BAAALgAECgUJBQAAAA==.',
['终相']='终相忘:BAAALgADCgMJAwAAAA==.',
['维维']='维维安凯恩:BAAALgADCgUJBQAAAA==.',
['翘边']='翘边模子:BAABLgAECn8XAAISAAcJ6RObcgCWAQASAAcJ6RObcgCWAQAAAA==.',
['老板']='老板凳丶:BAAALgAECgYJDAAAAA==.',
['老鼠']='老鼠打师傅:BAAALgADCgEJAQAAAA==.',
['聖光']='聖光将熄:BAAALgAECgQJCQAAAA==.',
['腋毛']='腋毛:BAAALgAECgYJBgAAAA==.',
['自来']='自来火:BAAALgAECgIJAgABLgAFFAYJFAANAMMSAA==.自来火会飞:BAAALgAFFAIJBAABLgAFFAYJFAANAMMSAA==.',
['自由']='自由镇的狂魔:BAAALgAFFAEJAQAAAA==.',
['茜饭']='茜饭:BAAALgAECgYJCQAAAA==.',
['萧瑟']='萧瑟:BAAALgAECgEJAQAAAA==.',
['蓝胖']='蓝胖子噜噜:BAAALgAECgQJBAAAAA==.',
['蓝色']='蓝色瘟疫:BAAALgADCgEJAQAAAA==.',
['薛八']='薛八一:BAACLgAFFH8UAAINAAQJahOiBAA8AQANAAQJahOiBAA8AQAuAAQKfxkAAw0ABgmiJJoFACECAA0ABgmiJJoFACECABAAAQn0AU6OAB8AAAEuAAUUBgkUAA0AwxIA.',
['血猎']='血猎:BAABLgAECn8dAAMOAAkJMhxwBgAmAwAOAAkJMhxwBgAmAwAXAAIJxwp+KQBlAAAAAA==.',
['行歌']='行歌:BAAALgADCgEJAQAAAA==.',
['让我']='让我来摸:BAABLgAFFH8GAAIVAAQJcARtDAATAQAVAAQJcARtDAATAQABLgAFFAYJFAANAMMSAA==.',
['诺亚']='诺亚:BAAALgAECgYJBwAAAA==.',
['谋电']='谋电游王:BAAALgAECgcJDAAAAA==.',
['贝斯']='贝斯凯彬:BAAALgAECgMJAwAAAA==.',
['超级']='超级飞侠:BAAALgAECgMJBQAAAA==.',
['路卡']='路卡利欧:BAACLgAFFH8cAAIEAAcJRCFFAACuAgAEAAcJRCFFAACuAgAuAAQKfyEAAgQACQlxJlkCALcDAAQACQlxJlkCALcDAAAA.',
['辰妹']='辰妹:BAACLgAFFH8OAAIQAAYJuBhpAQATAgAQAAYJuBhpAQATAgAuAAQKfykAAhAACQltJAwCAKgDABAACQltJAwCAKgDAAAA.',
['进口']='进口奶牛:BAAALgADCgUJBQAAAA==.',
['追个']='追个风:BAAALgADCgEJAQAAAA==.',
['追地']='追地暴暴龙:BAAALgADCgEJAQAAAA==.',
['遮没']='遮没没币:BAAALgAECgEJAQAAAA==.',
['那只']='那只小怪:BAAALgAECgQJCwAAAA==.',
['那时']='那时的疯狂:BAABLgAFFH8GAAIVAAIJChrIFgCiAAAVAAIJChrIFgCiAAAAAA==.',
['里奥']='里奥丨牛奶:BAAALgADCgIJAgAAAA==.',
['闪伯']='闪伯利恒之星:BAAALgADCgEJAgAAAA==.',
['问号']='问号:BAAALgAECgcJDQAAAA==.',
['阿依']='阿依夏沐:BAAALgAECgIJAgAAAA==.',
['阿兰']='阿兰蒂恩:BAAALgAECgEJAQAAAA==.',
['阿拉']='阿拉蕾:BAAALgAECgUJDgAAAA==.',
['陌路']='陌路狂花:BAAALgAECgQJBAAAAA==.',
['隐藏']='隐藏:BAABLgAFFH8OAAIHAAQJcA/aHABYAQAHAAQJcA/aHABYAQAAAA==.',
['雅少']='雅少:BAAALgADCgYJBwAAAA==.',
['雪之']='雪之下雪乃:BAAALgAECgEJAQAAAA==.',
['雾丑']='雾丑丑:BAAALgAECgYJBwAAAA==.',
['风云']='风云逆天:BAAALgAECgEJAQAAAA==.',
['风暴']='风暴丨烈酒:BAAALgAECgEJAQAAAA==.',
['风雷']='风雷电火:BAAALgAECgEJAQAAAA==.',
['香菸']='香菸的餘味:BAAALgADCgEJAgAAAA==.',
['鬼扯']='鬼扯丶:BAAALgAECgEJAQAAAA==.',
['魔力']='魔力熊猫:BAACLgAFFH8MAAIHAAQJpRr6FQBxAQAHAAQJpRr6FQBxAQAuAAQKfyQAAwcACAnRHvAqAMcCAAcACAnRHvAqAMcCABgAAgkYFzcSAKEAAAEuAAUUBAkOAAcAcA8A.',
['魔狼']='魔狼兽战:BAAALgADCgUJBQAAAA==.',
['魔王']='魔王大人:BAAALgADCgEJAQAAAA==.',
['鲨鱼']='鲨鱼巨人:BAAALgAECgEJAQAAAA==.',
['鳳山']='鳳山門外:BAAALgAECgYJEgAAAA==.',
['麻三']='麻三缺一将:BAAALgAECgEJAQAAAA==.',
['黄老']='黄老爷的腿:BAAALgAFFAIJAgAAAA==.',
['黑雨']='黑雨翼:BAAALgAECgkJEAAAAA==.',
['鼓岛']='鼓岛花児开:BAAALgADCgQJBAAAAA==.',
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
