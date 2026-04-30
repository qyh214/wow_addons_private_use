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

local lookup = {'Warlock-Destruction','Warlock-Demonology','DeathKnight-Unholy','Mage-Frost','Mage-Fire','Evoker-Augmentation','Evoker-Preservation','Evoker-Devastation','Druid-Restoration','Monk-Windwalker','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Devourer','Warrior-Fury','Rogue-Subtlety','Rogue-Assassination','Priest-Shadow','Priest-Holy','Priest-Discipline','Shaman-Restoration','Paladin-Retribution','Druid-Balance','DeathKnight-Blood','Mage-Arcane',}
local provider = {region='CN',realm='奈萨里奥',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Angelcat:BAAALgAECgUJCQAAAA==.',
As='Ashly:BAAALgAECgEJAQAAAA==.',
Bl='Bloodwarlock:BAABLgAECn8VAAMBAAcJcB1UEwCxAQABAAYJ4xtUEwCxAQACAAUJVhv1JwDxAAAAAA==.',
Dc='Dcsakura:BAAALgAFFAEJAQAAAA==.',
De='Degeneracy:BAAALgADCgUJBQAAAA==.',
Ev='Even:BAAALgAECgYJBwAAAA==.',
Fa='Fatalviolet:BAAALgAECgEJAQAAAA==.',
Gj='Gj:BAAALgAFFAIJBAAAAA==.',
Gr='Grimrak:BAABLgAECn8YAAIDAAgJPg5QXwDVAQADAAgJPg5QXwDVAQAAAA==.',
Hg='Hgjericho:BAACLgAFFH8KAAIEAAMJeBEpKwAJAQAEAAMJeBEpKwAJAQAuAAQKfyAAAwQABwnuHVRTAD4CAAQABwn8HFRTAD4CAAUAAwmAG4AHAAgBAAAA.',
Kk='Kkomi:BAAALgAECgYJBgAAAA==.Kkomin:BAAALgAECgkJDwAAAA==.Kkonin:BAAALgAECgYJBgAAAA==.',
Ku='Kungsa:BAAALgAECgUJBQAAAA==.',
La='Lancelots:BAAALgAECgEJAQAAAA==.',
Li='Lilia:BAAALgAECgUJCAAAAA==.',
Lu='Lucien:BAAALgAECggJEQAAAA==.',
Ma='Maximilia:BAAALgAECgUJBQAAAA==.',
Me='Mercurial:BAAALgADCgcJBwAAAA==.',
Ml='Mlplm:BAAALgAECgYJBgAAAA==.',
Mo='Mondialito:BAAALgADCgcJBwAAAA==.',
Ol='Oldgun:BAAALgAECgkJCQAAAA==.',
Qe='Qerer:BAAALgAECgQJAwAAAA==.',
Se='Selene:BAAALgAECgEJAQAAAA==.',
Sh='Shixui:BAAALgADCgYJBgAAAA==.',
Sz='Szeretlek:BAAALgAECgQJBAAAAA==.',
Ti='Tiefang:BAAALgAECgQJBwAAAA==.',
To='Tomorrow:BAAALgAECgMJAwAAAA==.',
Va='Vaxiya:BAAALgAECgYJCwAAAA==.',
['一之']='一之黑亚梨子:BAAALgADCgMJAwAAAA==.',
['一修']='一修哥:BAAALgAFFAEJAQAAAA==.',
['一刀']='一刀流:BAAALgAECggJEwAAAA==.',
['一心']='一心一教:BAACLgAFFH8FAAIGAAMJ6AFtFQC9AAAGAAMJ6AFtFQC9AAAuAAQKfxgABAcACAmeCFgnADkBAAcABwm6BlgnADkBAAYABQn4CZ5CANcAAAgAAQkAAKM7AD8AAAAA.',
['万剑']='万剑归宗:BAAALgAECgYJBgAAAA==.',
['不落']='不落酸牛牛:BAAALgAECgMJAQAAAA==.',
['亦尧']='亦尧:BAABLgAECn8XAAIJAAkJBCP6AQCAAwAJAAkJBCP6AQCAAwAAAA==.',
['亦瑤']='亦瑤:BAABLgAECn8eAAIJAAkJoSBSBABKAwAJAAkJoSBSBABKAwAAAA==.',
['人间']='人间指南:BAAALgAECgEJAQAAAA==.',
['伊芙']='伊芙蕾妮:BAAALgADCgEJAQAAAA==.',
['何处']='何处惹尘埃:BAABLgAECn8WAAIKAAYJDB48HAD6AQAKAAYJDB48HAD6AQAAAA==.',
['修拉']='修拉哈特:BAACLgAFFH8NAAIJAAQJVROiCwAmAQAJAAQJVROiCwAmAQAuAAQKfyEAAgkACAmSGDsqAAkCAAkACAmSGDsqAAkCAAAA.',
['倒霉']='倒霉的熊:BAAALgADCgMJBQAAAA==.',
['傅风']='傅风雪丶:BAAALgAFFAEJAQABLgAFFAQJBAACALkRAA==.',
['克伦']='克伦薇尔:BAAALgAECgEJAQAAAA==.',
['兰斯']='兰斯洛特:BAAALgAECgcJCwABLgAFFAIJAgALAAAAAA==.',
['凑凑']='凑凑来留:BAAALgAECgYJCAAAAA==.',
['凰之']='凰之游侠潇洒:BAAALgAECgkJCQAAAA==.',
['剑秀']='剑秀凌云:BAAALgAECgEJAQAAAA==.',
['北门']='北门丧彪:BAAALgAECgEJAgAAAA==.',
['千层']='千层纸:BAAALgADCgEJAQAAAA==.',
['卡西']='卡西亚托马斯:BAAALgAECgQJBAAAAA==.',
['印度']='印度理发师:BAAALgADCgcJBwAAAA==.',
['厄姆']='厄姆流丝:BAAALgADCgEJAQAAAA==.',
['可乐']='可乐香蕉:BAAALgAECgEJAQAAAA==.',
['可怕']='可怕的小宝宝:BAAALgAECgEJAQAAAA==.',
['可楽']='可楽加牛奶:BAAALgAFFAQJAwABLgAFFAYJAwALAAAAAA==.',
['可樂']='可樂加牛奶:BAAALgAFFAIJAgAAAA==.',
['叶枫']='叶枫哥:BAACLgAFFH8LAAIMAAQJURQaBABeAQAMAAQJURQaBABeAQAuAAQKfx4AAwwACAkVHycPAMICAAwACAkVHycPAMICAA0AAgmZCg57AFYAAAAA.',
['司马']='司马仙:BAAALgAECgQJBgAAAA==.',
['后知']='后知后绝:BAAALgAECgEJAQAAAA==.',
['咸鱼']='咸鱼抽脸:BAAALgAECgUJCQAAAA==.',
['咻咻']='咻咻棉糀餹:BAAALgAECgUJCAAAAA==.',
['啵啵']='啵啵萨:BAAALgAECgYJBgAAAA==.',
['国宝']='国宝:BAAALgADCgEJAQAAAA==.',
['地狱']='地狱一刀:BAAALgAECgQJBAAAAA==.',
['埃波']='埃波利耶塔:BAACLgAFFH8HAAIEAAMJsQuILgD8AAAEAAMJsQuILgD8AAAuAAQKfx4AAgQACAkgHyYoANICAAQACAkgHyYoANICAAAA.',
['夜之']='夜之愿:BAAALgAECgUJCQAAAA==.',
['夢幻']='夢幻鯨靈:BAAALgAFFAEJAQAAAA==.',
['大名']='大名叫上帝:BAAALgAECgMJAwAAAA==.',
['天之']='天之藍:BAABLgAFFH8GAAIEAAMJNA9tQwCoAAAEAAMJNA9tQwCoAAAAAA==.',
['天南']='天南星:BAAALgAECgUJBwAAAA==.',
['天宫']='天宫丨蓝:BAAALgAECgYJDgAAAA==.',
['奥丁']='奥丁丶:BAAALgAECgQJBAAAAA==.',
['安静']='安静的咸鱼:BAAALgADCgMJAwAAAA==.',
['小块']='小块强光碎片:BAAALgAECgEJAQAAAA==.',
['小怪']='小怪兽丶:BAAALgADCgcJCAAAAA==.',
['小红']='小红手:BAAALgAECgQJBAAAAA==.',
['小萌']='小萌兜:BAAALgADCgUJBQAAAA==.',
['小贝']='小贝:BAAALgADCgkJCQAAAA==.',
['山岚']='山岚之梦:BAAALgAECgcJBwAAAA==.',
['工藤']='工藤峰子:BAAALgAECggJEwAAAA==.工藤锋子:BAAALgAECgYJCgAAAA==.',
['布洛']='布洛克:BAAALgAECggJCAABLgAECggJGAADAD4OAA==.',
['幻灭']='幻灭梦想:BAAALgAECgUJCQAAAA==.',
['心梦']='心梦无痕:BAAALgAECgIJBAAAAA==.',
['心若']='心若随風:BAAALgADCgEJAQAAAA==.',
['忘了']='忘了离开:BAAALgAECgUJCwAAAA==.',
['怒及']='怒及吾命:BAAALgADCggJCAAAAA==.',
['恶魔']='恶魔姬:BAAALgAECgEJAQAAAA==.',
['我来']='我来抗揍的:BAAALgAECgEJAQAAAA==.',
['明日']='明日:BAAALgAECgQJBgAAAA==.',
['暮晓']='暮晓春来迟丶:BAABLgAFFH8EAAICAAQJuRGCBgBUAQACAAQJuRGCBgBUAQAAAA==.',
['暮色']='暮色渐浓:BAAALgADCgYJBgAAAA==.',
['最上']='最上川:BAAALgADCgcJDgAAAA==.',
['最下']='最下流:BAAALgAFFAEJAQAAAA==.',
['月言']='月言夕:BAAALgAECgYJBgAAAA==.',
['木哆']='木哆哆:BAABLgAFFH8GAAIOAAIJ+BPVJgClAAAOAAIJ+BPVJgClAAAAAA==.',
['柊祈']='柊祈:BAAALgAECgMJAQAAAA==.',
['柊镜']='柊镜:BAAALgAFFAQJBAABLgAFFAYJAQALAAAAAA==.',
['柏拉']='柏拉齐:BAAALgADCgYJBgAAAA==.',
['栩意']='栩意阑珊:BAAALgAFFAIJAgAAAA==.',
['桃白']='桃白白:BAAALgAECgUJBQAAAA==.',
['梳烨']='梳烨:BAAALgAECgQJBAAAAA==.',
['橙色']='橙色大野猫:BAAALgAFFAEJAQAAAA==.',
['欧皇']='欧皇战神:BAAALgAECgUJBQAAAA==.',
['毘沙']='毘沙门天:BAAALgAECgYJBwAAAA==.',
['永春']='永春张天志:BAAALgADCgEJAQAAAA==.',
['永生']='永生信仰:BAAALgAECgcJCwAAAA==.',
['永远']='永远铭记:BAAALgAECgUJBQAAAA==.',
['沪深']='沪深熊股:BAAALgAECgIJAgAAAA==.',
['注意']='注意拿我面包:BAAALgAFFAEJAQAAAA==.注意翻我江水:BAAALgAECgEJAQAAAA==.',
['海之']='海之狸:BAAALgAECgkJDwAAAA==.',
['清风']='清风徐徐:BAABLgAFFH8GAAIPAAMJ+xh0CAC8AAAPAAMJ+xh0CAC8AAABLgAFFAUJBQADAPoVAA==.',
['滅天']='滅天使一焚天:BAAALgAECgYJBgAAAA==.',
['漫珠']='漫珠莎华:BAAALgAECgUJCQAAAA==.',
['潜行']='潜行的怪叔叔:BAABLgAECn8dAAMQAAgJGxLDBQCXAQAQAAgJGxLDBQCXAQARAAEJRAJ1IgAhAAAAAA==.',
['濒死']='濒死之瞳:BAAALgAECgUJCQAAAA==.',
['灬烈']='灬烈日:BAAALgAECgQJBQAAAA==.',
['灵妖']='灵妖妖:BAAALgAFFAEJAgAAAA==.',
['烏鴉']='烏鴉:BAAALgAECgEJAQAAAA==.',
['照花']='照花台:BAAALgAECgMJAwAAAA==.',
['燃烧']='燃烧的诛妖:BAAALgAECgEJAQAAAA==.',
['爖七']='爖七:BAAALgAECgYJDQAAAA==.',
['牧有']='牧有小咪:BAABLgAECn8jAAQSAAkJEhgKCgDhAgASAAkJEhgKCgDhAgATAAgJZhTqHQDvAQAUAAMJHQMRSQB1AAAAAA==.',
['狂野']='狂野不死鸟:BAAALgAECgYJBgAAAA==.',
['狸呜']='狸呜嗷:BAACLgAFFH8JAAIVAAMJpxQqEADnAAAVAAMJpxQqEADnAAAuAAQKfyEAAhUACAnKHiwLAMsCABUACAnKHiwLAMsCAAAA.',
['狼狸']='狼狸咯狼:BAAALgADCgMJAwAAAA==.',
['猎户']='猎户座丶:BAAALgAECgMJAQAAAA==.',
['玛丽']='玛丽亚贝尔:BAAALgAECgYJBwAAAA==.',
['珊珊']='珊珊宝贝:BAAALgAECgQJBwAAAA==.',
['由语']='由语:BAAALgAECgUJBgAAAA==.',
['痛在']='痛在呼吸:BAABLgAFFH8FAAIWAAIJIw9+IwClAAAWAAIJIw9+IwClAAAAAA==.',
['痞子']='痞子乐手:BAAALgAECgcJDQAAAA==.',
['皇亲']='皇亲国戚:BAAALgADCgQJBAAAAA==.',
['相泽']='相泽南:BAAALgADCgEJAQAAAA==.',
['眼泪']='眼泪中的鱼:BAAALgAECgEJAQAAAA==.',
['神圣']='神圣的弥赛亚:BAAALgAECgIJBAAAAA==.',
['神裂']='神裂火织:BAAALgAECgkJBgABLgAFFAYJFwATANsRAA==.',
['禁止']='禁止敲打喂食:BAAALgAECgcJBwABLgAECgcJGwAXAGcJAA==.',
['究极']='究极大美女:BAAALgAECgYJBgAAAA==.究极小美女:BAAALgAECgMJAgAAAA==.究极狼外婆:BAAALgAECgIJAgAAAA==.究极美少女:BAAALgAECgQJBQAAAA==.',
['空天']='空天:BAAALgAECgEJAQAAAA==.',
['箭秀']='箭秀凌云:BAAALgAECgEJAQAAAA==.',
['米小']='米小柒:BAAALgADCgUJCAAAAA==.',
['粉红']='粉红人字拖:BAAALgADCgMJAwAAAA==.',
['紫月']='紫月緋雪:BAAALgAECgYJBgAAAA==.',
['红糖']='红糖珍珠奶茶:BAAALgADCgIJAgAAAA==.',
['纳兹']='纳兹个林:BAAALgAECgMJAwAAAA==.',
['绝对']='绝对小丸子:BAAALgAECgEJAQAAAA==.绝对球星四号:BAAALgADCgcJBwAAAA==.',
['绣气']='绣气的瀦:BAAALgAECgMJAwAAAA==.',
['绯红']='绯红的亚里亚:BAAALgAFFAEJAQABLgAFFAUJEwADAEwlAA==.',
['肉肉']='肉肉崽:BAAALgADCgUJBQAAAA==.',
['胖面']='胖面包:BAAALgAECgcJCgAAAA==.',
['艾鸭']='艾鸭鸭:BAAALgAFFAIJAgAAAA==.',
['艿白']='艿白的雪子:BAAALgADCgYJBgAAAA==.',
['范尼']='范尼是徳鲁伊:BAACLgAFFH8FAAIXAAMJlQMNEQDKAAAXAAMJlQMNEQDKAAAuAAQKfxQAAhcACAm2D/YnAL4BABcACAm2D/YnAL4BAAAA.',
['菲谢']='菲谢尔:BAAALgAFFAIJAgABLgAFFAUJAQALAAAAAA==.',
['落梅']='落梅饮雪:BAABLgAECn8bAAMXAAcJZwm6RAAcAQAXAAcJZwm6RAAcAQAJAAcJJgDf7AATAAAAAA==.',
['蕾欧']='蕾欧娜丶:BAAALgAECgMJAwAAAA==.',
['蝶梦']='蝶梦花酣:BAAALgAFFAEJAQAAAA==.',
['血染']='血染樱飞:BAAALgADCgUJBAAAAA==.',
['言灵']='言灵:BAABLgAFFH8LAAIOAAQJxiF1AwByAQAOAAQJxiF1AwByAQAAAA==.',
['许银']='许银锣:BAAALgADCgcJBwAAAA==.',
['诗尧']='诗尧:BAABLgAECn8WAAIJAAkJNCWWAADDAwAJAAkJNCWWAADDAwAAAA==.',
['诚挚']='诚挚的欺骗:BAAALgAECgYJCwAAAA==.',
['豆锅']='豆锅一:BAAALgADCgEJAQAAAA==.',
['迪迦']='迪迦:BAAALgAECgQJAwAAAA==.',
['遛弯']='遛弯的小白:BAAALgAECgEJAgAAAA==.',
['醉生']='醉生夢死:BAACLgAFFH8NAAIYAAQJoAHCCwC9AAAYAAQJoAHCCwC9AAAuAAQKfyEAAhgACAksCuEfAEYBABgACAksCuEfAEYBAAAA.',
['钉宫']='钉宫理惠:BAAALgAECgcJBgAAAA==.',
['铁骑']='铁骑无痕:BAAALgAECgYJBgAAAA==.',
['铜锣']='铜锣湾扛把子:BAAALgAFFAIJAgAAAA==.',
['镁锂']='镁锂子:BAAALgAFFAIJAwAAAA==.',
['闻香']='闻香識美人:BAAALgADCgEJAQAAAA==.',
['随便']='随便狂男:BAAALgADCgYJBgAAAA==.',
['随风']='随风小德:BAAALgAFFAIJAwAAAA==.随风澹淡:BAAALgAFFAIJAwABLgAFFAIJAwALAAAAAA==.',
['隼蛇']='隼蛇:BAABLgAECn8bAAMCAAgJIBINegBoAQACAAYJqhENegBoAQABAAIJ6hTCTgCBAAAAAA==.',
['雪花']='雪花肥牛:BAAALgAECgEJAgAAAA==.',
['雷一']='雷一雷:BAAALgADCgUJBQAAAA==.',
['霜火']='霜火之怒:BAABLgAFFH8RAAIEAAUJ9xwxFAB6AQAEAAUJ9xwxFAB6AQAAAA==.',
['霞之']='霞之丘诗羽:BAACLgAFFH8RAAMEAAUJkw8SDQCzAQAEAAUJkw8SDQCzAQAFAAIJNAbsAACaAAAuAAQKfxgAAwQACAmmHN89AIACAAQACAmVHN89AIACABkAAQk/HyIYAFgAAAAA.',
['青莲']='青莲宝色旗:BAAALgAECgQJBAAAAA==.',
['順徳']='順徳雙皮奶:BAAALgAECgUJCQAAAA==.',
['风暴']='风暴九叔:BAAALgAECgQJBAAAAA==.',
['魔王']='魔王灬先锋:BAAALgAECgYJCwAAAA==.',
['齋藤']='齋藤飛鳥:BAAALgAECgQJBgAAAA==.',
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
