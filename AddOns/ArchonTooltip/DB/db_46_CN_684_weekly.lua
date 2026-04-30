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

local lookup = {'Mage-Frost','Shaman-Elemental','Rogue-Subtlety','Paladin-Holy','DemonHunter-Devourer','Warlock-Destruction','Warlock-Demonology','Paladin-Retribution','Evoker-Devastation','Warrior-Protection','Druid-Restoration','Priest-Discipline','Evoker-Augmentation','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Unholy','Warrior-Arms','Warrior-Fury','Hunter-Survival','Druid-Balance','Paladin-Protection','Evoker-Preservation','Unknown-Unknown','Priest-Holy','Druid-Guardian','Shaman-Restoration','DeathKnight-Blood','Evoker-Ranged','Warlock-Affliction',}
local provider = {region='CN',realm='战歌',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abyssofdem:BAAALgADCgUJBQAAAA==.',
Ad='Adicj:BAAALgAECgYJBgAAAA==.',
Aw='Aw:BAAALgADCgMJAwAAAA==.',
Az='Azurblau:BAAALgAECgYJDAABLgAFFAUJEAABAM4dAA==.',
Bu='Buck:BAABLgAFFH8GAAICAAIJbBhCFACrAAACAAIJbBhCFACrAAAAAA==.Bui:BAAALgAFFAUJBAABLgAFFAYJCQADALMQAA==.',
Ca='Capozio:BAAALgAECgYJDAAAAA==.',
Ch='Chyraa:BAAALgAECgkJCQAAAA==.',
Cj='Cj:BAAALgAECgQJAwAAAA==.',
De='Deepwinter:BAAALgAFFAQJAgAAAA==.',
El='Ella:BAAALgAECgMJAwAAAA==.',
Eu='Eui:BAAALgAFFAQJBAABLgAFFAYJCQADALMQAA==.',
Fu='Fui:BAAALgAFFAQJBAABLgAFFAYJCQADALMQAA==.',
Gu='Gui:BAABLgAFFH8IAAIDAAQJbRJYAgBrAQADAAQJbBJYAgBrAQABLgAFFAYJCQADALMQAA==.',
In='Index:BAAALgAFFAEJAQAAAA==.',
Ks='Ksdemons:BAAALgAECgEJAQAAAA==.',
Ku='Kugimiyarie:BAAALgAECgkJCQAAAA==.Kui:BAABLgAECn8VAAIDAAkJyw9EGABFAgADAAkJyw9EGABFAgABLgAFFAYJCQADALMQAA==.',
La='Ladly:BAAALgAECgYJBgAAAA==.',
Mi='Michiko:BAAALgAECgQJBAAAAA==.',
Ml='Mlyx:BAAALgADCgQJBAAAAA==.',
Mo='Momoring:BAABLgAECn8UAAIEAAYJBRqNNACrAQAEAAYJBRqNNACrAQAAAA==.',
Mu='Mui:BAABLgAFFH8JAAIDAAUJQRhKCABkAQADAAUJQRhKCABkAQAAAA==.',
Nu='Nui:BAAALgAFFAQJAwABLgAFFAYJCQADALMQAA==.',
Oc='Oceanlab:BAAALgAECgQJBQAAAA==.',
Pu='Purpleflies:BAABLgAFFH8FAAIFAAMJsA62HADuAAAFAAMJsA62HADuAAAAAA==.',
Ra='Radagon:BAAALgAECgQJBQAAAA==.',
Re='Reborn:BAAALgAECgEJAgAAAA==.',
Ro='Rokhan:BAAALgAECgkJEQAAAA==.',
Se='Searedawabi:BAAALgAECgEJAgAAAA==.Searedburi:BAAALgAECgYJBgAAAA==.Searedtuna:BAAALgAECgEJAQAAAA==.',
So='Sojerboy:BAAALgAECgUJBQAAAA==.Solderjboy:BAAALgAECgIJAwAAAA==.',
Ta='Tall:BAAALgAECgMJAwAAAA==.Tanger:BAAALgAFFAEJAwAAAA==.',
Th='Theanswer:BAAALgADCgYJBgAAAA==.',
Tr='Tracys:BAABLgAECn8ZAAMGAAgJdB+bFACmAQAHAAUJdSCjWQC7AQAGAAUJJx2bFACmAQAAAA==.',
Tu='Tui:BAACLgAFFH8IAAIDAAUJew+LAgBmAQADAAUJew+LAgBmAQAuAAQKfxQAAgMACAkKGagPAKsCAAMACAkKGagPAKsCAAEuAAUUBgkJAAMAsxAA.',
Ul='Ulqudk:BAAALgAECgUJBQAAAA==.',
Vu='Vui:BAAALgAFFAQJBAABLgAFFAYJCQADALMQAA==.',
Xd='Xddh:BAAALgAECgQJBQAAAA==.',
['一个']='一个大雪球:BAAALgAFFAQJBAAAAA==.',
['一米']='一米五:BAAALgAFFAIJAwAAAA==.',
['一龙']='一龙:BAAALgAFFAIJAwAAAA==.',
['丁晓']='丁晓旭:BAAALgAECgYJBAAAAA==.',
['七煞']='七煞挽魂:BAAALgAECgMJAwAAAA==.',
['三十']='三十六季稻:BAAALgAECgMJAwAAAA==.',
['三点']='三点零:BAAALgAECgEJAQAAAA==.',
['不会']='不会开嗜血:BAAALgAECgIJAgAAAA==.',
['不圆']='不圆润盘它:BAAALgAECgQJBAAAAA==.',
['不悦']='不悦:BAAALgAFFAEJAQAAAA==.',
['不行']='不行我要拉了:BAAALgAECgcJDgAAAA==.',
['东北']='东北纯爷们:BAAALgAECgEJAQAAAA==.',
['东南']='东南西北风:BAAALgAECgEJAgAAAA==.',
['东逝']='东逝水:BAAALgAECgYJAgAAAA==.',
['丨不']='丨不离丶不弃:BAAALgADCgYJCQAAAA==.',
['丨冰']='丨冰糖丶雪梨:BAAALgAECgEJAQAAAA==.',
['丨堕']='丨堕落丶华仔:BAAALgAECggJEAAAAA==.',
['丨得']='丨得道高僧丨:BAAALgADCgEJAQAAAA==.',
['丨想']='丨想啥丶来啥:BAAALgADCgYJBgAAAA==.',
['丨死']='丨死亡丶凋零:BAAALgAECgUJCgAAAA==.',
['丨沉']='丨沉浮:BAAALgAECgEJAQAAAA==.',
['丨澄']='丨澄澄丨:BAAALgADCgUJBQAAAA==.',
['丨相']='丨相忘:BAAALgAFFAEJAQAAAA==.',
['丨荣']='丨荣耀灬汎:BAAALgAECgYJCwAAAA==.',
['丨逆']='丨逆鳞:BAAALgAECgEJAQAAAA==.',
['丨陨']='丨陨落丶颩翎:BAAALgAECgEJAQAAAA==.',
['丶乖']='丶乖乖不闹了:BAABLgAFFH8HAAIIAAMJwheAHQC3AAAIAAMJwheAHQC3AAAAAA==.',
['丶南']='丶南城决:BAAALgAECgIJAgAAAA==.',
['丶念']='丶念冰:BAAALgAECgYJCwAAAA==.',
['丶断']='丶断尘:BAAALgAECgQJBAAAAA==.',
['丶洛']='丶洛可:BAAALgAECgMJAwAAAA==.',
['丶该']='丶该隐:BAAALgAECgQJBQAAAA==.',
['丶赤']='丶赤道上的雪:BAAALgADCgEJAQAAAA==.',
['丶辣']='丶辣个劣人丶:BAAALgAECgYJCQAAAA==.',
['丸子']='丸子龍:BAAALgAECgEJAgAAAA==.',
['主城']='主城安保主管:BAAALgAECgIJBAAAAA==.',
['么烦']='么烦恼:BAAALgAECgIJAgAAAA==.',
['乌布']='乌布里克:BAAALgAECgcJCAAAAA==.',
['乙游']='乙游重坦:BAAALgADCgYJBgAAAA==.',
['九剑']='九剑:BAAALgADCgYJBgAAAA==.',
['九滴']='九滴水:BAAALgAECgIJAgAAAA==.',
['亅某']='亅某某人亅:BAAALgADCgcJBwAAAA==.',
['云丶']='云丶:BAAALgAECgYJBgAAAA==.',
['云桩']='云桩瑜:BAAALgAFFAMJAwABLgAFFAQJDwAJAKUlAA==.',
['云连']='云连雁宕仙家:BAAALgADCgYJBgAAAA==.',
['云隼']='云隼:BAAALgAECgIJAgAAAA==.',
['五月']='五月夏木:BAAALgAECgkJEwABLgAFFAcJDQAKAM4ZAA==.',
['亚洲']='亚洲第一德:BAABLgAFFH8FAAILAAMJ1wSsDgBvAAALAAMJ1wSsDgBvAAAAAA==.',
['亲爱']='亲爱的:BAAALgADCgEJAQAAAA==.',
['伊利']='伊利牛奶蛋蛋:BAAALgAFFAEJAQAAAA==.',
['伍子']='伍子之歌:BAAALgAECgIJAgAAAA==.',
['伦家']='伦家也素公举:BAAALgAFFAQJAwAAAA==.',
['低调']='低调尘莫:BAAALgAFFAEJAQAAAA==.低调尘默:BAAALgAECgEJAQAAAA==.',
['你的']='你的老包北:BAAALgAECgEJAQAAAA==.',
['來生']='來生瞳:BAAALgADCgEJAQAAAA==.',
['依然']='依然灬嗳你:BAAALgAECgQJBAAAAA==.',
['修修']='修修:BAAALgAECgYJBwAAAA==.',
['候鸟']='候鸟迁徙:BAAALgADCgEJAQAAAA==.',
['假面']='假面骑士纸:BAAALgADCgEJAQAAAA==.',
['偶豆']='偶豆豆:BAAALgADCgIJAwAAAA==.',
['全职']='全职小骑:BAAALgAECgQJBgAAAA==.',
['八二']='八二年的僧:BAAALgAECgIJAgAAAA==.',
['公鸡']='公鸡开大吧:BAAALgAECgEJAQAAAA==.',
['六魔']='六魔将军:BAAALgAECgIJBQAAAA==.',
['兽痞']='兽痞:BAAALgAFFAEJAQAAAA==.',
['冰乂']='冰乂皇:BAAALgADCgYJCgAAAA==.',
['冰冻']='冰冻我心:BAAALgAECgYJBgAAAA==.',
['冰淇']='冰淇淋:BAABLgAECn8ZAAIEAAgJphwpEACSAgAEAAgJphwpEACSAgABLgAFFAUJEgAMADMmAA==.',
['冰糖']='冰糖栗子喵:BAAALgAFFAMJAwAAAA==.',
['冰美']='冰美式一杯:BAAALgAECgQJBQAAAA==.',
['冲锋']='冲锋的猪仔:BAAALgADCgcJBwAAAA==.',
['冴月']='冴月麟:BAAALgADCgQJBAAAAA==.',
['凡宝']='凡宝宝好可爱:BAAALgAECgUJCgAAAA==.',
['别人']='别人叫我肥猪:BAAALgADCgMJBAAAAA==.',
['刻画']='刻画你容颜:BAAALgADCgYJBgAAAA==.',
['加雷']='加雷斯:BAAALgAECgEJAQAAAA==.',
['动感']='动感超人丶:BAAALgAECgYJBgAAAA==.',
['十一']='十一月不闷热:BAAALgAECgYJCwAAAA==.',
['十二']='十二青衣楼主:BAAALgAECgYJEQAAAA==.',
['十月']='十月天不闷热:BAAALgAFFAEJAQAAAA==.',
['千年']='千年骑士:BAAALgAECgYJAgAAAA==.',
['南衣']='南衣:BAAALgAECgEJAQAAAA==.',
['卡塔']='卡塔玖:BAAALgADCgYJBgAAAA==.',
['又加']='又加班熊熊:BAAALgADCgUJBQAAAA==.',
['叮铃']='叮铃铃当:BAAALgAECgkJBgABLgAFFAYJDgANAEIXAA==.',
['可可']='可可丶亚琛:BAABLgAFFH8IAAIFAAMJ3gIjIQDIAAAFAAMJ3gIjIQDIAAAAAA==.可可是只猫:BAAALgAFFAMJAwAAAA==.',
['吉米']='吉米哐哐硬:BAAALgADCgEJAQAAAA==.',
['吖啊']='吖啊咔:BAAALgAFFAIJAgAAAA==.',
['吟唱']='吟唱黑暗:BAAALgAECgQJBwAAAA==.',
['吲丶']='吲丶领潮流:BAAALgAECgcJBwAAAA==.',
['呱呱']='呱呱公主:BAAALgAECgQJBAAAAA==.',
['命中']='命中注定丶:BAAALgADCgEJAQAAAA==.',
['命运']='命运之初:BAAALgAECgUJBgAAAA==.',
['咕咕']='咕咕奶不奶:BAAALgADCgIJAgAAAA==.',
['咪兰']='咪兰多琳娜:BAAALgAFFAEJAQAAAA==.',
['哇丶']='哇丶嘎嘎:BAAALgAECgEJAQAAAA==.',
['唯见']='唯见月寒日暖:BAABLgAFFH8PAAMOAAUJtRnYBwCdAQAOAAUJ2xfYBwCdAQAPAAIJjxMcEwC2AAAAAA==.',
['喝牛']='喝牛奶会长高:BAAALgADCgYJCAAAAA==.',
['嗑魔']='嗑魔:BAAALgAECgYJCwAAAA==.',
['嗦狠']='嗦狠子最奶了:BAAALgAECgEJAgAAAA==.',
['噗哧']='噗哧:BAAALgAECgYJBgAAAA==.',
['囔囔']='囔囔踹:BAABLgAFFH8GAAIQAAMJohhVJQAAAQAQAAMJohhVJQAAAQAAAA==.',
['囧囧']='囧囧萌萌优:BAAALgAECgcJBwAAAA==.',
['圣光']='圣光宠儿:BAAALgAECgIJAgAAAA==.',
['地板']='地板是我家:BAAALgAECggJAwABLgAFFAcJDQAKAM4ZAA==.',
['地狱']='地狱贱圣:BAAALgADCgUJBQAAAA==.',
['地瓜']='地瓜泥:BAAALgAECgIJAwAAAA==.',
['坏坏']='坏坏韦爵爷:BAAALgADCggJDQAAAA==.',
['基你']='基你太美:BAAALgAFFAIJBAAAAA==.',
['墨白']='墨白丶僧:BAAALgAECgYJCQAAAA==.',
['壯漢']='壯漢:BAAALgAECgYJBwAAAA==.',
['壹碗']='壹碗牛肉湯:BAAALgAECgEJAQAAAA==.',
['夕恋']='夕恋花未央:BAAALgADCgYJBgABLgAFFAUJEgAMADMmAA==.',
['夕颜']='夕颜:BAAALgADCgMJAwAAAA==.',
['多伦']='多伦敦骄傲:BAAALgAECgMJBAAAAA==.',
['夜先']='夜先生:BAAALgAECgYJBwAAAA==.',
['夜北']='夜北北:BAAALgAECgIJBAAAAA==.',
['夜小']='夜小妖:BAAALgAECgMJAwAAAA==.',
['夜旅']='夜旅人:BAAALgAFFAMJAwAAAA==.',
['大别']='大别特子牛:BAAALgADCgEJAQAAAA==.',
['大扑']='大扑棱蛾子:BAAALgADCgcJBwAAAA==.',
['大神']='大神:BAAALgADCgMJAwAAAA==.',
['大红']='大红手欢少:BAAALgAECgQJBgABLgAFFAMJBQAHADsYAA==.',
['大臭']='大臭丶:BAAALgADCgEJAQAAAA==.',
['天使']='天使的低语丶:BAAALgAECgUJCQAAAA==.',
['天外']='天外来物:BAAALgAFFAQJBAAAAA==.',
['天狼']='天狼之吻:BAAALgAFFAIJAgAAAA==.',
['天真']='天真有邪:BAAALgAECgMJBQAAAA==.',
['天罗']='天罗的刀丝:BAAALgAECgEJAQAAAA==.',
['天赐']='天赐容若:BAAALgAFFAMJBAAAAA==.',
['天际']='天际线:BAAALgAECgYJDQAAAA==.',
['失心']='失心疯狂徒:BAAALgAFFAMJBAAAAA==.',
['失落']='失落的地平线:BAAALgAECgEJAQAAAA==.',
['奈露']='奈露基冈忒:BAAALgAECgQJBAAAAA==.',
['奌丶']='奌丶奌:BAAALgADCgEJAQAAAA==.',
['奎蒂']='奎蒂:BAAALgADCgEJAQAAAA==.',
['奔腾']='奔腾热浪:BAAALgAECgQJBAAAAA==.',
['奥数']='奥数:BAAALgADCgQJBAAAAA==.',
['奥术']='奥术星芒:BAABLgAECn8UAAIBAAYJ0BR8nQCbAQABAAYJ0BR8nQCbAQAAAA==.',
['女人']='女人都是小潴:BAAALgAECgkJEgAAAA==.女人都是潴潴:BAAALgAECgkJEQAAAA==.',
['女王']='女王降临丶:BAAALgADCgYJBgAAAA==.',
['奶油']='奶油泡芙喵:BAAALgAECgYJCgAAAA==.',
['奶騎']='奶騎:BAAALgADCgEJAQAAAA==.',
['她是']='她是亦菲啊:BAAALgADCgMJAQAAAA==.',
['她真']='她真的不一样:BAAALgAECgQJBAAAAA==.',
['好几']='好几个牛人头:BAACLgAFFH8FAAILAAIJvxvoFQCzAAALAAIJvxvoFQCzAAAuAAQKfxkAAgsABwloIx0PAMACAAsABwloIx0PAMACAAAA.',
['妈妈']='妈妈大人:BAAALgAECgMJAwAAAA==.',
['妖妖']='妖妖灵来了嘛:BAAALgAECgIJAgAAAA==.',
['妞啊']='妞啊扭:BAAALgADCgcJBwAAAA==.',
['姚紫']='姚紫明血圣:BAAALgADCgIJAgAAAA==.',
['娜塔']='娜塔莉瑟琳:BAAALgAECgkJCAABLgAFFAYJGAANANUeAA==.',
['子贤']='子贤不语:BAAALgAECgIJAgAAAA==.',
['孤独']='孤独的利里:BAAALgAFFAIJAgAAAA==.',
['宏晔']='宏晔大魔王:BAAALgAECgIJAgAAAA==.',
['小双']='小双辫:BAAALgAECgQJBQAAAA==.',
['小口']='小口木:BAAALgAECgYJDgAAAA==.',
['小啊']='小啊淇:BAAALgAFFAIJAgAAAA==.',
['小情']='小情调:BAAALgADCgEJAQAAAA==.',
['小果']='小果丶:BAAALgAECgYJBgAAAA==.',
['小清']='小清欢:BAAALgADCgEJAQAAAA==.',
['小牙']='小牙缝:BAAALgAECgkJCQAAAA==.',
['小肥']='小肥熊:BAAALgADCgEJAQAAAA==.',
['小花']='小花猫飞飞:BAAALgADCgEJAQAAAA==.',
['小菜']='小菜妹:BAAALgAECgIJAgAAAA==.',
['小虎']='小虎战:BAAALgAECgYJBgAAAA==.',
['小锤']='小锤:BAAALgAECgUJCgAAAA==.',
['小龍']='小龍听風:BAABLgAFFH8QAAINAAYJ/hOKAQCgAQANAAYJ/hOKAQCgAQABLgAFFAYJEAANADsiAA==.小龍听风:BAABLgAFFH8QAAINAAYJAxQ9AQCzAQANAAYJAxQ9AQCzAQABLgAFFAYJEAANADsiAA==.小龍聽風:BAABLgAFFH8QAAINAAYJOyJNAAAPAgANAAYJOyJNAAAPAgAAAA==.',
['小龙']='小龙听風:BAABLgAFFH8FAAINAAUJdw+TBgCQAQANAAUJdw+TBgCQAQABLgAFFAYJEAANADsiAA==.小龙聼風:BAABLgAFFH8FAAINAAUJig0QDQAvAQANAAUJig0QDQAvAQABLgAFFAYJEAANADsiAA==.小龙聼风:BAABLgAFFH8FAAINAAUJVBTIBQCiAQANAAUJVBTIBQCiAQABLgAFFAYJEAANADsiAA==.',
['尛龙']='尛龙听風:BAABLgAFFH8LAAINAAYJ/hOBBgCSAQANAAYJ/hOBBgCSAQABLgAFFAYJEAANADsiAA==.',
['巅峰']='巅峰对决:BAAALgAECgYJCAAAAA==.',
['巧手']='巧手定四海:BAAALgAECgIJAgAAAA==.',
['帕尼']='帕尼尼:BAAALgADCgYJBgAAAA==.',
['平衡']='平衡木:BAAALgADCgIJAgAAAA==.',
['年迈']='年迈的猎手:BAAALgAECgcJCAAAAA==.',
['并非']='并非某某人:BAAALgADCgYJBgAAAA==.',
['幻妖']='幻妖言惑:BAAALgAECgEJAQAAAA==.',
['幽灬']='幽灬然:BAAALgAECgUJCwAAAA==.',
['庐山']='庐山升龙霸:BAAALgAECgEJAQAAAA==.',
['废宅']='废宅:BAAALgADCgIJAgAAAA==.',
['开无']='开无敌就跑:BAAALgAECgYJCwAAAA==.',
['张元']='张元英:BAAALgAECgYJCgAAAA==.',
['张楚']='张楚岚:BAAALgAECgEJAQAAAA==.',
['张灵']='张灵玉:BAAALgAECgcJEAAAAA==.',
['徐龙']='徐龙象:BAAALgADCgMJAwAAAA==.',
['微胖']='微胖女孩:BAAALgAECgUJCwAAAA==.',
['微風']='微風拂過:BAAALgAECgEJAgAAAA==.',
['快到']='快到郭里来:BAAALgAECgIJAgAAAA==.',
['忽悠']='忽悠的圣光:BAAALgAECgUJCQAAAA==.',
['恩赐']='恩赐加传送:BAAALgAECgQJBQAAAA==.',
['恶夜']='恶夜之罚:BAAALgAECgcJBwABLgAFFAYJEgAIAAQlAA==.',
['悬月']='悬月:BAAALgADCgIJAgAAAA==.',
['感受']='感受这啊:BAAALgAECgUJAgAAAA==.',
['慕容']='慕容雪:BAAALgAFFAIJAwAAAA==.',
['懒懒']='懒懒的龙:BAAALgADCgUJBQAAAA==.',
['我叫']='我叫赛肯德涕:BAAALgADCgEJAQAAAA==.',
['我想']='我想慧慧:BAAALgAECgQJBAAAAA==.',
['我爱']='我爱丁丁宁:BAAALgAECgcJCQAAAA==.',
['戒律']='戒律牧:BAAALgADCgMJAwAAAA==.',
['战到']='战到死:BAACLgAFFH8HAAIKAAMJkAeDCQC4AAAKAAMJkAeDCQC4AAAuAAQKfxUABBEABgnaE0IWAEsBABIABgnUEVRVAFYBABEABgltDEIWAEsBAAoAAwkyEUM1AJwAAAAA.',
['打呼']='打呼打到狼:BAAALgAFFAIJAgAAAA==.',
['打蠍']='打蠍打到狼:BAAALgAECgEJAQAAAA==.',
['抗战']='抗战二十年:BAAALgAECgEJAQAAAA==.',
['披这']='披这凉皮的糖:BAACLgAFFH8GAAIPAAIJpyUqDgDgAAAPAAIJpyUqDgDgAAAuAAQKfxUAAw8ACAmFGy1JAI4BAA8ABgkZGi1JAI4BAA4ABQn5FwRCAE8BAAAA.',
['挑灯']='挑灯摸蛋:BAAALgAECggJDwAAAA==.',
['撒拉']='撒拉神思:BAAALgADCgIJAgAAAA==.',
['收徒']='收徒:BAAALgAECgQJBAAAAA==.',
['敌羞']='敌羞去脱他衣:BAAALgAECgYJCAAAAA==.',
['整挺']='整挺好:BAAALgAECgEJAQAAAA==.',
['文斯']='文斯莫克蕾玖:BAAALgAECgYJCgAAAA==.',
['斯柯']='斯柯达小姑娘:BAAALgAECgcJEAAAAA==.',
['新世']='新世界萨满:BAAALgADCgEJAQAAAA==.',
['新大']='新大陆的白风:BAACLgAFFH8NAAQOAAUJ1hfgFwDVAAAOAAMJrQ/gFwDVAAATAAIJQQagBQCfAAAPAAIJ/x8THAB1AAAuAAQKfyEABA4ACQk2Hy8RAK4CAA4ACAlAHy8RAK4CABMABgl/ER4GAGUBAA8AAQkiHiuzAF0AAAAA.',
['无名']='无名的魂:BAAALgAECgMJAQAAAA==.',
['明月']='明月照沟渠:BAAALgAECgUJBgAAAA==.',
['易小']='易小只丶灰熊:BAAALgAECgYJDgAAAA==.易小小只灰熊:BAAALgADCgUJBQAAAA==.',
['星弈']='星弈魔灵:BAABLgAECn8UAAIUAAcJDxiyHgAKAgAUAAcJDxiyHgAKAgAAAA==.',
['星梦']='星梦恋儿:BAAALgAECgYJDgAAAA==.',
['晚期']='晚期植物人:BAAALgAECgQJBQAAAA==.',
['普赛']='普赛克伊莉丝:BAAALgAECgUJCgAAAA==.',
['晴儿']='晴儿:BAAALgAECgYJCAAAAA==.',
['暗箭']='暗箭伤不了人:BAAALgADCgYJCwAAAA==.',
['暗若']='暗若霜雪:BAACLgAFFH8FAAIQAAIJchWmOgCnAAAQAAIJchWmOgCnAAAuAAQKfxYAAhAABwmiG8JoALwBABAABwmiG8JoALwBAAAA.',
['暴风']='暴风烈酒王:BAAALgAECgEJAQAAAA==.',
['曜虎']='曜虎:BAACLgAFFH8IAAIIAAMJjBfpEQAWAQAIAAMJjBfpEQAWAQAuAAQKfxUABAgABwmvHQ9IAAsCAAgABwmvHQ9IAAsCAAQABglVHcASABYBABUAAQmwACJMABsAAAAA.',
['曾哥']='曾哥赐我力量:BAAALgADCgEJAQAAAA==.',
['最冷']='最冷:BAAALgADCgUJBQAAAA==.',
['最爱']='最爱媛宝:BAAALgAECgYJCAAAAA==.',
['月儿']='月儿柔如水:BAAALgAECgQJBQAAAA==.',
['月半']='月半女丑儿:BAAALgAECgYJBwAAAA==.',
['月晨']='月晨:BAABLgAECn8UAAIEAAgJHxeaHgAjAgAEAAgJHxeaHgAjAgAAAA==.',
['月詠']='月詠:BAAALgAECgEJAQAAAA==.',
['有派']='有派以被遗忘:BAAALgAECgIJAgAAAA==.',
['杀戮']='杀戮神殇:BAAALgAECgYJCAAAAA==.',
['李阿']='李阿魔:BAAALgAFFAEJAQAAAA==.',
['来煎']='来煎人寿:BAABLgAFFH8NAAIOAAUJ5x0nCACYAQAOAAUJ5x0nCACYAQAAAA==.',
['枫桥']='枫桥灬:BAAALgAECgUJDAAAAA==.',
['枫魅']='枫魅:BAAALgAECgYJCgAAAA==.',
['某某']='某某人乀:BAACLgAFFH8PAAIJAAQJpSX9AADCAQAJAAQJpSX9AADCAQAuAAQKfx8ABAkABwn2JC4GAJQCAAkABglGJi4GAJQCABYABQnTGygdAJsBAA0AAQliHvdYAFoAAAAA.',
['柠檬']='柠檬宝宝:BAAALgAECgQJBAAAAA==.',
['柯南']='柯南:BAAALgAECgIJAgAAAA==.',
['格林']='格林巴利:BAAALgAECgEJAQAAAA==.',
['桥本']='桥本环奈:BAAALgADCgYJBgAAAA==.',
['梦若']='梦若飞花灬:BAABLgAECn8UAAIIAAcJdhuxTwDzAQAIAAcJdhuxTwDzAQAAAA==.',
['棠梨']='棠梨:BAAALgAECgEJAQAAAA==.',
['楠风']='楠风:BAAALgADCgEJAQAAAA==.',
['橙子']='橙子大魔王:BAAALgAECgEJAQAAAA==.',
['欣欣']='欣欣向正:BAAALgAECgMJAwAAAA==.',
['死亡']='死亡魔法師:BAAALgAECggJDQAAAA==.',
['死灭']='死灭回游:BAAALgADCgcJBwAAAA==.',
['水晶']='水晶砵仔糕:BAAALgAECgEJAQAAAA==.',
['水蓝']='水蓝蓝:BAAALgAECgQJBAAAAA==.',
['永强']='永强:BAAALgAECgYJCwABLgAFFAgJCQAGAC0aAA==.',
['永恒']='永恒一老庭:BAAALgAECgEJAgAAAA==.',
['永远']='永远滴丶傀儡:BAAALgAECgUJBQAAAA==.',
['汉子']='汉子婶:BAAALgAFFAEJAgAAAA==.',
['汤姆']='汤姆科鲁兹:BAAALgAECgUJBgABLgAFFAEJAwAXAAAAAA==.',
['沐兮']='沐兮丶:BAAALgAECgMJAwAAAA==.',
['沐子']='沐子:BAAALgAECgYJDQAAAA==.',
['沧月']='沧月冰心:BAAALgAECgYJDAAAAA==.',
['法力']='法力小公主:BAAALgADCgYJBwAAAA==.法力小王子:BAAALgADCgEJAQAAAA==.',
['泡泡']='泡泡玛特丶:BAAALgAECgQJBAAAAA==.',
['洛丹']='洛丹伦的钟声:BAAALgAECgUJBQAAAA==.',
['浅陌']='浅陌陌呀:BAAALgADCgUJBQAAAA==.',
['海底']='海底捞月:BAAALgADCgMJAwAAAA==.',
['海格']='海格拉:BAAALgADCgEJAQAAAA==.',
['深夜']='深夜的温度:BAAALgAECgIJAgAAAA==.',
['深海']='深海守护者:BAAALgAFFAEJAQAAAA==.',
['混分']='混分巨龙:BAAALgAFFAIJAgAAAA==.',
['清酒']='清酒三两三:BAABLgAFFH8IAAIOAAUJchXGFQDsAAAOAAUJchXGFQDsAAAAAA==.',
['渡辺']='渡辺麻友:BAAALgAECgUJBQAAAA==.',
['湛蓝']='湛蓝宝宝:BAAALgAECgIJAgAAAA==.',
['溜溜']='溜溜猴儿:BAAALgAECgcJCQAAAA==.',
['满月']='满月丨祝踏岚:BAAALgAECgUJBQAAAA==.',
['演帝']='演帝:BAACLgAFFH8IAAISAAMJtBaIEQD6AAASAAMJtBaIEQD6AAAuAAQKfyIAAxIACAn5HcIdAGACABIACAlEHcIdAGACAAoAAQmkG61AAE4AAAAA.',
['潇潇']='潇潇梨落:BAAALgADCgUJAQAAAA==.',
['澤野']='澤野弘之:BAAALgAECgYJDAAAAA==.',
['灬丨']='灬丨澄澄丨灬:BAAALgADCgYJBwAAAA==.',
['灬小']='灬小骚蹄子灬:BAAALgAECgYJBwAAAA==.',
['灬无']='灬无敌灬:BAAALgAECgEJAQAAAA==.',
['炒肝']='炒肝:BAAALgAECgEJAQAAAA==.',
['烂在']='烂在泥里:BAAALgADCgIJAgAAAA==.',
['烟氿']='烟氿冷冻訫:BAACLgAFFH8KAAILAAQJqhKwCgAwAQALAAQJqhKwCgAwAQAuAAQKfxwAAgsACAkVFFAtAPkBAAsACAkVFFAtAPkBAAAA.',
['煎饼']='煎饼卷大葱:BAAALgAECgYJBgAAAA==.',
['熔岩']='熔岩爆裂:BAAALgAECgEJAQAAAA==.',
['燎原']='燎原:BAAALgADCgUJBQAAAA==.',
['爱与']='爱与图兰朵:BAAALgAECgQJAgAAAA==.',
['爱丽']='爱丽丝菲尔:BAABLgAECn8jAAIYAAcJRyB+EgBNAgAYAAcJRyB+EgBNAgAAAA==.',
['爱做']='爱做梦的猫:BAAALgADCgcJBwAAAA==.',
['爱吃']='爱吃绿舌头:BAAALgAECgcJBwAAAA==.',
['爷们']='爷们必须慅:BAAALgAFFAIJAwAAAA==.',
['爸爸']='爸爸打我:BAAALgAECgYJCgAAAA==.',
['牛掘']='牛掘机:BAAALgAECgUJCwAAAA==.',
['牛盾']='牛盾力学:BAAALgAECgYJCQAAAA==.',
['狂乱']='狂乱的小鸟:BAABLgAFFH8LAAIZAAQJlwU6AwDCAAAZAAQJlwU6AwDCAAAAAA==.',
['狂猛']='狂猛萨神:BAAALgAECgMJAwAAAA==.',
['狂砍']='狂砍两条街:BAAALgAECgcJCwAAAA==.',
['狐尔']='狐尔豪斯:BAAALgAECgkJCQAAAA==.',
['狩猎']='狩猎天涯:BAAALgAECgEJAQAAAA==.',
['独自']='独自角斗士:BAAALgAECgEJAQAAAA==.',
['猎手']='猎手小神女:BAAALgAECgEJAQAAAA==.',
['猎狐']='猎狐座:BAAALgADCgEJAQAAAA==.',
['猎猎']='猎猎人:BAAALgAECgEJAQAAAA==.',
['猎隐']='猎隐:BAAALgAECgYJDQAAAA==.',
['猩红']='猩红王子:BAAALgAECgMJAwAAAA==.',
['猫可']='猫可可:BAAALgADCgQJBAAAAA==.',
['猫斯']='猫斯拉:BAAALgAECgEJAQAAAA==.',
['猫爬']='猫爬架丶丶:BAAALgADCgEJAgAAAA==.',
['獸戰']='獸戰:BAAALgAECgYJEgAAAA==.',
['玉青']='玉青:BAAALgAECgIJAgAAAA==.',
['王大']='王大美:BAAALgAECgQJBQAAAA==.',
['玖玖']='玖玖魔灵:BAAALgAECgEJAQAAAA==.',
['玩个']='玩个奶骑:BAABLgAECn8XAAIEAAkJWBtSEgCAAgAEAAkJWBtSEgCAAgAAAA==.',
['玩命']='玩命丿嘲讽:BAAALgAECgYJDQAAAA==.',
['琅琊']='琅琊一恶:BAAALgAECgYJCQAAAA==.',
['理想']='理想之殇:BAAALgAECgIJAgAAAA==.',
['瑾年']='瑾年丨光道:BAAALgAECgcJCAAAAA==.',
['璐成']='璐成成:BAAALgADCgEJAQAAAA==.',
['瓦尔']='瓦尔塔:BAAALgAECgIJAgAAAA==.',
['生存']='生存贼:BAAALgAECgIJAgAAAA==.',
['田德']='田德莉娜:BAAALgAECgEJAQAAAA==.',
['白景']='白景归西山:BAAALgADCgIJAgAAAA==.',
['白沫']='白沫沫:BAABLgAFFH8FAAMOAAIJPxezHQCfAAAOAAIJTBKzHQCfAAAPAAEJiiQAAAAAAAAAAA==.',
['百花']='百花丛中过:BAAALgAECgcJEgAAAA==.',
['真丶']='真丶姑射神人:BAAALgADCgIJAgAAAA==.',
['破天']='破天斩月:BAABLgAECn8WAAMSAAgJ4QhYCgB6AQASAAgJ4QhYCgB6AQAKAAEJXAVZSgApAAAAAA==.',
['破碎']='破碎残阳骑士:BAAALgAECgEJAQAAAA==.',
['碧瑶']='碧瑶:BAAALgAECgUJBgABLgAFFAQJEAAaAIklAA==.',
['祈愿']='祈愿狂徒:BAAALgAECgcJDQAAAA==.',
['神丶']='神丶骑:BAAALgAECgkJCQAAAA==.',
['神奇']='神奇六国:BAAALgADCgEJAgAAAA==.',
['神座']='神座出流:BAACLgAFFH8NAAIQAAQJWxtaEQBcAQAQAAQJWxtaEQBcAQAuAAQKfyUAAxAACAnUIioTAAgDABAACAnUIioTAAgDABsABQkZDJ49AFsAAAAA.',
['神经']='神经餅:BAAALgAFFAIJAgAAAA==.',
['神魔']='神魔一念间:BAAALgAECgYJCgAAAA==.',
['科尔']='科尔沁肥牛:BAAALgADCgcJAQAAAA==.',
['秘密']='秘密搜查官:BAAALgAFFAIJAwAAAA==.',
['空空']='空空的壹天:BAAALgADCgIJAgAAAA==.',
['窥源']='窥源:BAAALgAECgIJAwAAAA==.',
['第一']='第一邪皇:BAAALgADCgEJAQAAAA==.',
['筱龍']='筱龍听风:BAABLgAFFH8IAAIcAAYJuh4AAAAAAAANAAYJuh4AAAAAAAABLgAFFAYJEAANADsiAA==.',
['筱龙']='筱龙听风:BAABLgAFFH8IAAINAAYJCBe4AgASAgANAAYJCBe4AgASAgABLgAFFAYJEAANADsiAA==.',
['箭飛']='箭飛:BAAALgAECgIJAgAAAA==.',
['米兰']='米兰达丶可儿:BAAALgADCgIJAgAAAA==.',
['米迦']='米迦勒之世:BAAALgAECgcJDgAAAA==.米迦勒之兽:BAAALgAFFAIJAgAAAA==.米迦勒之混:BAAALgAECgYJCgAAAA==.',
['糖淉']='糖淉:BAAALgADCgYJBgAAAA==.',
['糖醋']='糖醋丶小猫:BAABLgAFFH8GAAIBAAMJmA5BLAAFAQABAAMJmA5BLAAFAQAAAA==.',
['糖门']='糖门滚:BAAALgAECgkJBwAAAA==.',
['索林']='索林:BAAALgAFFAEJAgAAAA==.',
['紫灯']='紫灯水银:BAAALgADCgEJAQAAAA==.',
['繁星']='繁星若尘:BAAALgAECgcJCwAAAA==.繁星若林:BAAALgAECgEJAQAAAA==.',
['红丶']='红丶玫瑰:BAAALgAFFAEJAgAAAA==.',
['红色']='红色:BAAALgAECgUJBAAAAA==.',
['绒球']='绒球球:BAAALgAECgYJBgABLgAFFAUJEgAMADMmAA==.',
['绝精']='绝精的老王:BAAALgAECgUJBQAAAA==.',
['维克']='维克斯:BAAALgAECgcJCwAAAA==.',
['网恋']='网恋被骗五千:BAAALgAECgIJAgAAAA==.',
['罪之']='罪之天使:BAAALgAECgYJDQAAAA==.',
['罪恶']='罪恶与正义:BAAALgADCgEJAQAAAA==.',
['老丶']='老丶庭:BAAALgADCgEJAQAAAA==.',
['老式']='老式表情包:BAAALgAFFAQJBAAAAA==.',
['考拉']='考拉:BAAALgAECgEJAQAAAA==.',
['聖丶']='聖丶小龍:BAAALgAECgYJCQAAAA==.',
['肉肉']='肉肉宝贝球:BAAALgAECgYJBgAAAA==.',
['胖子']='胖子丶盲僧:BAAALgAFFAEJAQAAAA==.胖子丶盲盲:BAAALgADCgYJBgAAAA==.',
['艾尔']='艾尔文隆美尔:BAAALgAECgIJAgAAAA==.',
['艾怡']='艾怡絲黛虂:BAAALgAECgQJBAAAAA==.',
['花开']='花开灬彼岸天:BAAALgADCgEJAQAAAA==.',
['花影']='花影箭风:BAAALgAECgYJEwAAAA==.',
['苏联']='苏联大货司机:BAAALgAECgUJAwAAAA==.',
['若溪']='若溪予依:BAABLgAFFH8GAAILAAIJLh8IFQC8AAALAAIJLh8IFQC8AAAAAA==.',
['苦涩']='苦涩的奶油:BAAALgAECgYJBgAAAA==.',
['英雄']='英雄无畏:BAAALgAECgYJCQAAAA==.',
['荔枝']='荔枝喵喵斩:BAAALgAECgYJCQAAAA==.',
['荣耀']='荣耀的战狼:BAAALgAECgYJBgAAAA==.',
['菜头']='菜头飞:BAAALgAFFAIJAgAAAA==.',
['萧红']='萧红绿:BAAALgADCgcJCAAAAA==.',
['萨瓦']='萨瓦地卡:BAAALgAECgcJCQAAAA==.',
['葡萄']='葡萄大个:BAAALgADCgEJAQAAAA==.',
['蒂福']='蒂福斯基:BAAALgAECgQJBwAAAA==.',
['蒜苗']='蒜苗:BAAALgADCgQJBAAAAA==.',
['蔑魔']='蔑魔巴风特:BAAALgAECgYJDAAAAA==.',
['蔓越']='蔓越莓饼干:BAAALgAECgEJAQAAAA==.',
['薯条']='薯条真是好味:BAAALgAECgUJCQAAAA==.',
['蚂斩']='蚂斩:BAAALgAECgEJAQAAAA==.',
['蚌蚌']='蚌蚌:BAAALgAECgkJEQAAAA==.',
['蜜桃']='蜜桃奶茶:BAAALgAECgYJBwAAAA==.',
['蟑螂']='蟑螂惡爸:BAAALgAECgEJAwAAAA==.',
['血杀']='血杀灬弑神:BAAALgAECgYJAQAAAA==.',
['袖清']='袖清风:BAAALgAECgQJBgAAAA==.',
['裂之']='裂之:BAAALgAFFAIJAgAAAA==.',
['裸漆']='裸漆威震天:BAAALgADCgEJAQAAAA==.',
['西格']='西格弗洛德:BAABLgAFFH8FAAIHAAMJzQyFGQCiAAAHAAMJzQyFGQCiAAAAAA==.',
['要命']='要命丶风骚:BAAALgADCgQJBAAAAA==.',
['见性']='见性志诚:BAAALgAECgIJAgAAAA==.',
['訫之']='訫之哀伤:BAAALgAECgEJAgAAAA==.',
['许丶']='许丶喜力啤酒:BAAALgAECgQJAwAAAA==.',
['诛萸']='诛萸:BAAALgADCgIJAgAAAA==.',
['賊无']='賊无影:BAAALgAECgMJAwAAAA==.',
['贰等']='贰等饼干:BAAALgAFFAIJAgAAAA==.',
['起风']='起风了丶:BAAALgAECgQJBAAAAA==.',
['超杀']='超杀必胜技:BAAALgAECgQJBQAAAA==.',
['路路']='路路饿了:BAAALgAECgIJAgAAAA==.',
['踏歌']='踏歌行:BAAALgAECgEJAQAAAA==.',
['躺尸']='躺尸小老版儿:BAABLgAFFH8FAAIaAAMJvwv3EADgAAAaAAMJvwv3EADgAAAAAA==.',
['车神']='车神:BAAALgADCgYJBgAAAA==.',
['轸水']='轸水蚓:BAAALgAECgYJDAAAAA==.',
['辣灬']='辣灬條:BAAALgAECgQJBAAAAA==.',
['逍遥']='逍遥丨踏风:BAAALgAECgYJBgABLgAFFAQJCQAPADccAA==.',
['那个']='那个死騎:BAAALgAECgEJAQAAAA==.那个父亲:BAAALgAECgYJEAAAAA==.那个爹:BAAALgAECgMJBAAAAA==.',
['邪天']='邪天使:BAAALgAECgYJCwAAAA==.',
['酋长']='酋长:BAAALgADCgUJBQAAAA==.',
['野草']='野草随风:BAAALgAECgQJBwAAAA==.',
['铭刻']='铭刻丶不雨:BAAALgADCgEJAQAAAA==.',
['银河']='银河护卫队:BAAALgADCgcJCwAAAA==.',
['锤子']='锤子抡不动:BAAALgAECgYJBgAAAA==.',
['长腿']='长腿矮子:BAAALgAECgQJBAAAAA==.',
['闗柒']='闗柒:BAAALgAECgYJBgAAAA==.',
['闪耀']='闪耀的苍蓝星:BAACLgAFFH8NAAMHAAQJQx+9DQBuAQAHAAQJQx+9DQBuAQAGAAEJkgmxFwBPAAAuAAQKfyEABAYACAnHHpAPANUBAAYABwnbGpAPANUBAAcABgkkH5sNAKgBAB0AAQk4FjQsAEYAAAAA.',
['阿三']='阿三:BAAALgADCgEJAQAAAA==.',
['阿狩']='阿狩:BAAALgAECgcJCgAAAA==.',
['阿维']='阿维:BAAALgAECgEJAQAAAA==.',
['阿莱']='阿莱克丝塔:BAAALgAFFAEJAQABLgAFFAEJAwAXAAAAAA==.',
['阿藏']='阿藏:BAAALgAECgIJAgAAAA==.',
['陨石']='陨石术:BAAALgAECgEJAQAAAA==.',
['雪伊']='雪伊丶星云:BAAALgADCgIJAgAAAA==.',
['雪夜']='雪夜:BAAALgAECgYJDAAAAA==.',
['雪孤']='雪孤:BAAALgADCgEJAgAAAA==.',
['雷克']='雷克顿:BAAALgAECgYJBwAAAA==.',
['雷加']='雷加蒂娅:BAAALgAECgcJBwAAAA==.',
['雷神']='雷神乔帮主:BAAALgAFFAIJAgAAAA==.',
['青霜']='青霜:BAAALgAECgYJDgAAAA==.',
['静待']='静待黎明:BAAALgADCgEJAQAAAA==.',
['颜值']='颜值即正义:BAAALgAFFAIJAgAAAA==.',
['飞刀']='飞刀小郭:BAAALgADCgIJAgAAAA==.',
['饿了']='饿了奶奶:BAAALgAECgEJAQAAAA==.',
['马化']='马化疼:BAAALgADCgIJAgAAAA==.',
['马尔']='马尔斯:BAAALgAECgUJBQAAAA==.',
['骄纵']='骄纵跋扈:BAAALgAECggJCAAAAA==.',
['鱼丸']='鱼丸培根粗面:BAABLgAFFH8FAAIIAAIJCSJ3GgDMAAAIAAIJCSJ3GgDMAAAAAA==.',
['鱼灬']='鱼灬丶豆腐:BAAALgAECgEJAQAAAA==.',
['鱼香']='鱼香茄子:BAAALgAECgEJAgAAAA==.',
['鹿沫']='鹿沫:BAAALgAECgYJCAAAAA==.',
['麒麟']='麒麟沫沫:BAAALgAECgcJDAAAAA==.',
['黑白']='黑白压脉带:BAAALgADCgMJAwAAAA==.',
['黑面']='黑面鸭要报仇:BAAALgAECgUJBQAAAA==.',
['鼠标']='鼠标:BAAALgAECgYJCAAAAA==.',
['龍丨']='龍丨傲丨天:BAAALgAECgEJAQAAAA==.',
['龍角']='龍角散:BAAALgAECgYJCQAAAA==.',
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
