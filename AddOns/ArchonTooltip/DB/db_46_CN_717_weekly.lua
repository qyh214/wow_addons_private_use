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

local lookup = {'Priest-Discipline','Unknown-Unknown','DemonHunter-Havoc','Priest-Holy','Shaman-Restoration','Paladin-Retribution','Rogue-Subtlety','Rogue-Assassination','Paladin-Holy','Mage-Frost','Priest-Shadow','Druid-Restoration','Druid-Balance','Monk-Brewmaster','Warrior-Protection','Druid-Feral','DeathKnight-Blood','DeathKnight-Unholy','DeathKnight-Frost','Shaman-Elemental','Monk-Mistweaver','Monk-Windwalker','Hunter-Marksmanship','Warrior-Arms','Hunter-BeastMastery','Evoker-Preservation','Paladin-Protection','DemonHunter-Devourer','Evoker-Devastation',}
local provider = {region='CN',realm='梅尔加尼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Amia:BAAALgAECgkJDQABLgAFFAUJEwABAE0hAA==.',
Ba='Balerion:BAAALgAECggJCAAAAA==.',
Be='Beo:BAAALgAECgEJAQAAAA==.',
Bl='Blackscreen:BAAALgADCgYJBgABLgAECgQJBAACAAAAAA==.',
Ca='Carpediem:BAAALgAFFAEJAQAAAA==.',
Da='Damonlol:BAAALgAECgkJCQAAAA==.',
Di='Diank:BAAALgAECgYJEAAAAA==.',
Do='Dokur:BAAALgAECgYJBgAAAA==.',
El='Elirice:BAAALgAECgEJAQAAAA==.',
Fi='Fionaspring:BAAALgAECgcJBwAAAA==.',
Ga='Gadeeses:BAAALgAECgQJBgAAAA==.',
Gi='Gigigirl:BAAALgAECgQJBQAAAA==.',
Ha='Haku:BAAALgAECgEJAQAAAA==.',
He='Hesher:BAAALgAECgMJAwAAAA==.',
Ho='Holyassasin:BAAALgAECgcJBwAAAA==.Holywar:BAAALgAECgkJDgAAAA==.',
Im='Imnmnmn:BAAALgAECgYJBgABLgAFFAUJAQACAAAAAA==.',
Is='Isawyou:BAAALgAECgIJAwAAAA==.',
Ji='Jie:BAACLgAFFH8IAAIDAAQJhwv1AwBBAQADAAQJhwv1AwBBAQAuAAQKfxkAAgMACAliHTAKAL8CAAMACAliHTAKAL8CAAAA.',
Ka='Kanbekotori:BAAALgAECgYJDQAAAA==.Katharine:BAAALgAECgUJBQAAAA==.Katrinal:BAAALgAECgYJBwAAAA==.Katrnad:BAAALgAECgUJBQAAAA==.',
La='Largrange:BAAALgADCgIJAgAAAA==.',
Le='Lemov:BAAALgAECgYJCAAAAA==.',
Li='Littlelolita:BAAALgAECgQJBAAAAA==.',
Lu='Lucelly:BAACLgAFFH8IAAMEAAMJ+BAjCADmAAAEAAMJ+BAjCADmAAABAAEJ5glOGgBGAAAuAAQKfxYAAwQABwmqHkMRAFgCAAQABwmYHkMRAFgCAAEABglMGXggAJABAAAA.',
Ma='Magicion:BAAALgAECgYJBgAAAA==.',
Mi='Michaelbay:BAAALgADCgkJCQAAAA==.Mischievous:BAABLgAECn8UAAIFAAYJRBtCKgDlAQAFAAYJRBtCKgDlAQAAAA==.Mishundare:BAABLgAFFH8FAAIBAAMJoQ/FBgDjAAABAAMJoQ/FBgDjAAAAAA==.',
Mo='Mozarto:BAAALgAECgYJBgAAAA==.',
Mu='Musthunt:BAAALgADCgEJAQAAAA==.',
Ne='Neverdie:BAAALgAECgEJAwAAAA==.',
Pa='Pantsy:BAAALgAFFAUJAQAAAA==.',
Ph='Phoenixxixi:BAAALgADCgMJAwAAAA==.',
Pm='Pmdg:BAAALgAECgUJCgAAAA==.',
Pu='Pupicat:BAAALgAFFAIJBAAAAA==.',
Qu='Quinck:BAAALgAECgUJDgAAAA==.',
Ra='Rapper:BAAALgAECgUJBQAAAA==.',
Ro='Ronnie:BAAALgAECgQJBAAAAA==.',
Se='Secretxcsy:BAAALgAECgEJAgAAAA==.',
Sh='Shunsui:BAAALgAECgEJAQAAAA==.',
Sk='Skeletor:BAAALgADCgQJBAAAAA==.',
So='Sorceress:BAAALgAECgYJEQAAAA==.',
Sp='Sparkel:BAAALgAECgMJAwAAAA==.',
St='Stormer:BAAALgADCgIJAgAAAA==.',
Ti='Tirly:BAAALgAFFAIJAgAAAA==.',
Tr='Trickstercat:BAAALgADCgUJBQAAAA==.',
Va='Varamyr:BAAALgAECgYJBgABLgAECggJCAACAAAAAA==.',
Vi='Vigger:BAAALgAECgQJBQAAAA==.Vinibear:BAAALgAECgQJBQAAAA==.',
Wu='Wuyang:BAAALgAECgEJAgAAAA==.',
['一天']='一天通:BAAALgAECgIJAgAAAA==.',
['一小']='一小淇一:BAAALgADCgIJAgAAAA==.',
['一点']='一点点:BAAALgAECgIJAgAAAA==.',
['一问']='一问一世界:BAAALgADCgUJBQAAAA==.',
['一零']='一零七三:BAAALgAECgEJAgAAAA==.',
['七圣']='七圣印:BAAALgAECgQJBAAAAA==.',
['七夜']='七夜乄雪:BAAALgAECgMJBAAAAA==.',
['七彩']='七彩泡泡糖:BAAALgAECgkJCQAAAA==.',
['万宝']='万宝路薄荷糖:BAAALgAECgcJBgAAAA==.',
['万生']='万生:BAAALgAECgQJBAAAAA==.',
['三花']='三花巨萌:BAAALgAECgkJCQAAAA==.',
['下壹']='下壹站天後:BAAALgAFFAEJAQAAAA==.',
['不死']='不死的齐格菲:BAABLgAFFH8HAAIGAAMJFRKXFQD+AAAGAAMJFRKXFQD+AAAAAA==.',
['不知']='不知名的酱某:BAACLgAFFH8GAAIHAAMJkB1eCwAwAQAHAAMJkB1eCwAwAQAuAAQKfxwAAwcABwkLIwQMANcCAAcABwkLIwQMANcCAAgABQnKFrcJAJ8BAAAA.',
['东北']='东北银河豹:BAAALgAECgYJDgAAAA==.',
['东耳']='东耳呢喃:BAAALgAECgUJBwAAAA==.',
['丨云']='丨云虎丨:BAAALgADCgcJCAAAAA==.',
['丶全']='丶全体起立:BAAALgAFFAIJAwAAAA==.',
['丶夏']='丶夏侯:BAAALgAECgIJAgAAAA==.',
['丿小']='丿小猎丨:BAAALgADCgUJCQAAAA==.',
['丿御']='丿御坂灬美琴:BAAALgAECgYJDAAAAA==.',
['乄游']='乄游白海乄:BAAALgAECgUJBQAAAA==.',
['乘风']='乘风破浪:BAAALgAECgQJBgAAAA==.',
['九十']='九十九由基:BAAALgAECgQJBwAAAA==.',
['九转']='九转修罗丨斩:BAAALgAECgEJAQAAAA==.九转修罗法:BAAALgAECgEJAQAAAA==.',
['乱乱']='乱乱大王:BAAALgADCgEJAQAAAA==.',
['人间']='人间清欢:BAAALgAECgEJAgAAAA==.人间烟火:BAAALgAECgUJCAAAAA==.',
['仙女']='仙女龙:BAAALgADCgcJBwAAAA==.',
['伊蕾']='伊蕾娜:BAAALgAECgYJDAAAAA==.',
['低语']='低语丶小明:BAABLgAFFH8GAAIJAAIJEyQREgC8AAAJAAIJEyQREgC8AAAAAA==.',
['你能']='你能不动么:BAAALgADCgYJAgAAAA==.',
['佰哥']='佰哥丶无敌:BAAALgAECgYJBwAAAA==.佰哥会升腾:BAAALgAECgMJBAAAAA==.',
['促狭']='促狭鬼:BAAALgAECgEJAQABLgAECgYJCAACAAAAAA==.',
['修囉']='修囉王一平:BAAALgAECgQJBAAAAA==.',
['倒档']='倒档漂移:BAAALgAECgEJAQAAAA==.',
['光散']='光散落地方:BAAALgAFFAEJAQAAAA==.',
['兔尐']='兔尐宝:BAAALgADCgYJCgAAAA==.',
['入间']='入间:BAAALgADCgcJBwAAAA==.',
['全服']='全服第一萨满:BAAALgAFFAEJAQAAAA==.',
['八十']='八十:BAAALgAECgQJCAAAAA==.',
['八鸡']='八鸡大狂疯:BAAALgADCgcJBwAAAA==.',
['兰希']='兰希欧:BAAALgAECgQJBgAAAA==.',
['兽兽']='兽兽不当受:BAAALgAECgIJAgAAAA==.',
['冥道']='冥道残月:BAAALgAECgUJBQAAAA==.',
['冰之']='冰之圣:BAAALgAECgYJBgAAAA==.',
['冰雪']='冰雪大白猫:BAAALgAECgMJAwAAAA==.冰雪小白猫:BAAALgADCgUJBQAAAA==.冰雪欢欢:BAECLgAFFH8RAAIKAAUJzBuKBAB+AQAKAAUJzBuKBAB+AQAuAAQKfxQAAgoABgnKIdJvAPQBAAoABgnKIdJvAPQBAAAA.',
['冲锋']='冲锋艺术家:BAAALgAECgEJAQAAAA==.',
['凌乱']='凌乱伤痕:BAABLgAECn8XAAMEAAYJyiSCDwBrAgAEAAYJyiSCDwBrAgALAAUJkQYKSADAAAAAAA==.',
['凌风']='凌风:BAAALgAECgcJDAAAAA==.',
['凛丶']='凛丶夜:BAAALgADCgEJAQAAAA==.',
['凝若']='凝若紫晗:BAAALgAECgEJAQAAAA==.',
['刀削']='刀削芒果:BAACLgAFFH8GAAMMAAMJqRyZDAAbAQAMAAMJqRyZDAAbAQANAAEJTRS3GQBRAAAuAAQKfxUAAw0ABgmaGw4lANUBAA0ABgmaGw4lANUBAAwABgmMG6k8ALEBAAAA.',
['别喊']='别喊了正在搓:BAAALgAECgkJBQAAAA==.',
['剑刃']='剑刃疯爆:BAAALgAECgYJBgAAAA==.',
['剑锋']='剑锋所指:BAABLgAFFH8GAAIJAAIJWhgPFQCYAAAJAAIJWhgPFQCYAAAAAA==.',
['劳缪']='劳缪克斯:BAAALgADCgUJBQAAAA==.',
['北六']='北六代:BAAALgAECgEJAgAAAA==.',
['北冥']='北冥冇鱼:BAACLgAFFH8FAAIGAAMJIBh7DADGAAAGAAMJIBh7DADGAAAuAAQKfx8AAgYABwlcIvcgAKcCAAYABwlcIvcgAKcCAAAA.',
['十四']='十四行诗:BAAALgAECgQJCQAAAA==.',
['千里']='千里丶冰封:BAAALgADCgMJAwAAAA==.',
['华子']='华子哥灬:BAAALgADCgQJBAAAAA==.',
['华隆']='华隆一:BAABLgAECn8VAAIOAAcJCBfTJADcAQAOAAcJCBfTJADcAQABLgAECgkJIwAOAGIeAA==.华隆三十一:BAAALgAECgEJAQABLgAECgkJIwAOAGIeAA==.华隆八:BAAALgAECgYJBgABLgAECgkJIwAOAGIeAA==.华隆十一:BAABLgAECn8XAAIOAAcJCRKfLwCYAQAOAAcJCRKfLwCYAQABLgAECgkJIwAOAGIeAA==.华隆呀:BAABLgAECn8jAAIOAAkJYh6qBQAtAwAOAAkJYh6qBQAtAwAAAA==.',
['卑微']='卑微的原批:BAAALgAECgUJBgAAAA==.',
['单手']='单手搓炉石:BAAALgAECgMJAwAAAA==.',
['卡卡']='卡卡丶罚:BAAALgADCgcJBwAAAA==.卡卡洛:BAAALgAECgEJAgAAAA==.',
['印第']='印第安奶僧:BAAALgAECgYJBAAAAA==.',
['原神']='原神高手:BAAALgAECgYJBgAAAA==.',
['双刀']='双刀的刀:BAAALgAECgEJAQAAAA==.',
['可爱']='可爱就完事了:BAAALgAECgYJBgAAAA==.',
['吉丶']='吉丶祥:BAAALgAECgQJBwAAAA==.',
['听说']='听说你叫萌:BAAALgAECgUJBQAAAA==.',
['吴彦']='吴彦尔丹:BAAALgADCgYJBgAAAA==.',
['吼血']='吼血啊:BAAALgAECgYJBgAAAA==.',
['和风']='和风轻舞:BAABLgAECn8WAAIGAAkJbSLwBAB8AwAGAAkJbSLwBAB8AwABLgAFFAUJCgAPAHUSAA==.',
['咒怨']='咒怨阎魔:BAAALgAECgUJDAAAAA==.',
['咕身']='咕身走暗巷:BAAALgAECgEJAQAAAA==.',
['咚咔']='咚咔嘁克崩:BAAALgAECgIJAgAAAA==.',
['哒哒']='哒哒打撒擦:BAAALgAECgcJDgAAAA==.',
['喵喵']='喵喵琴絃:BAABLgAECn8YAAIFAAkJ8R6qBQAXAwAFAAkJ8R6qBQAXAwAAAA==.',
['嘟嘟']='嘟嘟灬丨熊丨:BAAALgAECgEJAQAAAA==.',
['噬魂']='噬魂摄魄:BAAALgAECgMJBwAAAA==.',
['噼里']='噼里啪啦黄:BAAALgADCgUJBQAAAA==.',
['回忆']='回忆丶精灵:BAAALgAECgUJBQAAAA==.',
['圣光']='圣光将灭:BAAALgAECgcJBwAAAA==.',
['地狱']='地狱苦痛:BAAALgAECgYJCAAAAA==.',
['地面']='地面最强:BAAALgAECgYJAwAAAA==.',
['基罗']='基罗基罗:BAAALgAECgYJBgAAAA==.',
['墓前']='墓前有圣光:BAAALgAECgEJAQAAAA==.',
['墨染']='墨染涵霜丶:BAAALgADCgEJAQAAAA==.',
['夏亚']='夏亚阿兹纳布:BAAALgAECgEJAQAAAA==.',
['多梅']='多梅拉斯:BAAALgAECgEJAQAAAA==.',
['夜幕']='夜幕美美:BAAALgADCgUJAgAAAA==.',
['夜月']='夜月礼赞:BAAALgAECgkJBwAAAA==.',
['夜灬']='夜灬殺:BAAALgAECgUJBQAAAA==.',
['大佬']='大佬修脚么:BAAALgAECgEJAQAAAA==.',
['大军']='大军来临丶:BAAALgAFFAQJBAAAAA==.',
['大方']='大方无隅:BAAALgAECggJBgABLgAFFAQJEAAQAOsiAA==.',
['大泽']='大泽的德:BAACLgAFFH8IAAMNAAMJMhniBAAPAQANAAMJMhniBAAPAQAMAAEJ+wozJwBAAAAuAAQKfyIAAw0ABwmkH30YAEUCAA0ABwmkH30YAEUCAAwABglLHcgwAOgBAAAA.',
['大玉']='大玉姐狂饮:BAAALgAFFAIJAgAAAA==.',
['大红']='大红手:BAAALgADCgIJAgAAAA==.',
['天堂']='天堂小人物:BAABLgAFFH8IAAIRAAQJahJHBwAcAQARAAQJahJHBwAcAQAAAA==.',
['天煞']='天煞丶堕落:BAAALgADCgQJBAAAAA==.',
['奥术']='奥术冲姬:BAACLgAFFH8FAAISAAIJFBlKOgCoAAASAAIJFBlKOgCoAAAuAAQKfxgAAhIABwnXHVE1AGECABIABwnXHVE1AGECAAAA.奥术涌动:BAAALgAFFAIJBAAAAA==.',
['妍紫']='妍紫丶惩罚者:BAAALgAECgEJAQAAAA==.',
['娜玛']='娜玛丶梨梨:BAAALgAFFAIJAwAAAA==.',
['孟根']='孟根巴特:BAAALgAECgYJCwAAAA==.',
['孤狼']='孤狼浪:BAAALgAECgYJDQAAAA==.',
['安渡']='安渡丶:BAAALgAECgMJAwAAAA==.',
['安西']='安西香十四号:BAAALgAFFAUJAgABLgAFFAYJEgALADAaAA==.',
['安逸']='安逸:BAAALgAECgcJDAAAAA==.',
['寂灭']='寂灭至尊:BAAALgAECgEJAQAAAA==.',
['寂静']='寂静之音:BAAALgAECgYJBwAAAA==.',
['密码']='密码迷城:BAABLgAFFH8HAAISAAQJGxYcEgBZAQASAAQJGxYcEgBZAQAAAA==.',
['富婆']='富婆追猎者:BAAALgAECgEJAQAAAA==.',
['寻找']='寻找裤衩子:BAAALgAECgYJDQAAAA==.',
['小宝']='小宝丛林:BAAALgADCgYJBgAAAA==.',
['小对']='小对钩:BAAALgADCgEJAQAAAA==.',
['小希']='小希尔:BAAALgADCgEJAQAAAA==.',
['小树']='小树暖暖:BAACLgAFFH8VAAIBAAUJuiYhAQBHAgABAAUJuiYhAQBHAgAuAAQKfyYAAwEACAkdJt4BAGgDAAEACAkdJt4BAGgDAAsACAnrIy8KAN8CAAAA.',
['小汉']='小汉堡:BAAALgAECgMJBAAAAA==.',
['小沐']='小沐沐:BAAALgAECgcJBgAAAA==.',
['小灬']='小灬骨丶:BAAALgAECgYJBwAAAA==.',
['小白']='小白的胖子:BAAALgADCgcJCgAAAA==.',
['小耀']='小耀哥:BAAALgAECgEJAQAAAA==.',
['小萌']='小萌老师:BAAALgAECgIJAgAAAA==.',
['少司']='少司命护佑:BAAALgAECgEJAQAAAA==.',
['就你']='就你了皮卡丘:BAAALgAECgQJBAAAAA==.',
['就是']='就是不拉怪:BAAALgAFFAIJAwABLgAFFAMJBgAMAKkcAA==.',
['尾戒']='尾戒:BAAALgADCgUJBQAAAA==.',
['岑丶']='岑丶雪花啤酒:BAAALgAECgEJAQAAAA==.',
['崶忄']='崶忄鎻鑀:BAAALgAFFAQJBAAAAA==.',
['巨人']='巨人法姆雷:BAAALgAECgcJBwAAAA==.',
['巴图']='巴图毕力格:BAAALgAECgEJAQAAAA==.',
['布和']='布和巴雅尔:BAAALgAECgEJAQAAAA==.',
['帅元']='帅元:BAACLgAFFH8IAAISAAQJsSLnBgCaAQASAAQJsSLnBgCaAQAuAAQKfycAAxIACAlDJNAKAEUDABIACAlDJNAKAEUDABMABgkPFw0CAHEBAAAA.',
['师父']='师父再打我下:BAAALgAECgYJBgAAAA==.',
['帕拉']='帕拉叮:BAAALgAECgUJBgAAAA==.',
['帝国']='帝国之耀:BAAALgADCgcJCgAAAA==.',
['幽宿']='幽宿:BAAALgAFFAEJAQAAAA==.',
['幽默']='幽默小紫:BAAALgAECgEJAQAAAA==.幽默红色小人:BAAALgAFFAQJBAAAAA==.',
['开心']='开心小辣椒:BAAALgAECgcJEwAAAA==.',
['弯道']='弯道超车:BAAALgAECgYJCQAAAA==.',
['弹你']='弹你脑瓜蹦:BAAALgADCgQJBAAAAA==.',
['强势']='强势职业:BAAALgAECgcJCwAAAA==.',
['影打']='影打:BAAALgAECgEJAQAAAA==.',
['得力']='得力蘸酱阿黄:BAAALgADCgEJAQAAAA==.',
['微疯']='微疯:BAAALgADCgEJAQAAAA==.',
['德偿']='德偿所失:BAAALgADCgQJBAAAAA==.',
['忘了']='忘了开了:BAAALgAECgcJBwAAAA==.',
['快乐']='快乐圣骑:BAAALgADCgYJBgAAAA==.',
['恐怖']='恐怖隐身人:BAAALgAECgYJBgAAAQ==.',
['恶魔']='恶魔小肉松:BAAALgAECgEJAQAAAA==.',
['情義']='情義灬永恒:BAAALgAECgEJAgAAAA==.',
['情若']='情若惜君:BAAALgAECgIJAwAAAA==.',
['惊瑟']='惊瑟狂风:BAAALgAECgMJAwAAAA==.',
['我不']='我不想上班:BAAALgAFFAMJBAAAAA==.',
['我与']='我与秦彻:BAAALgAECgYJDAAAAA==.',
['我想']='我想凿你:BAAALgAECgEJAgAAAA==.',
['我滴']='我滴圣光啊:BAAALgAECgEJAgAAAA==.',
['战雪']='战雪梦千城:BAAALgAECgEJAQAAAA==.',
['戦斧']='戦斧牛排:BAAALgAECgUJBQAAAA==.',
['手欠']='手欠:BAAALgAECgEJAgAAAA==.',
['打那']='打那个猎爹:BAAALgAECgYJBgAAAA==.',
['把你']='把你刻在掌心:BAABLgAFFH8HAAINAAMJbyFgDAAgAQANAAMJbyFgDAAgAQAAAA==.',
['把泪']='把泪寄給海:BAACLgAFFH8JAAIUAAQJOSb/AgDCAQAUAAQJOSb/AgDCAQAuAAQKfxQAAhQABwmqJkUOAL8CABQABwmqJkUOAL8CAAAA.',
['把酒']='把酒临风:BAAALgAFFAIJBAAAAA==.',
['撑灬']='撑灬哥:BAAALgADCgEJAQAAAA==.',
['文一']='文一路术神:BAAALgAECgEJAgAAAA==.',
['星期']='星期壹:BAABLgAECn8XAAIMAAcJWRlSKAATAgAMAAcJWRlSKAATAgAAAA==.',
['昨夜']='昨夜清风:BAAALgAECgYJCgAAAA==.',
['智将']='智将:BAAALgAECgYJEAAAAA==.',
['暗影']='暗影国度:BAAALgAECgcJDgAAAA==.',
['暴血']='暴血亲女儿:BAAALgAECgEJAQAAAA==.',
['月光']='月光下的沉静:BAAALgAECgcJDQAAAA==.',
['月音']='月音瑚奈奈:BAAALgAECgEJAQAAAA==.',
['有钱']='有钱灬没处花:BAAALgAECgcJBwAAAA==.',
['有馬']='有馬公生:BAAALgADCgEJAQAAAA==.',
['木瓜']='木瓜星灵:BAAALgAECgYJCwAAAA==.',
['术业']='术业有砖攻:BAAALgADCgEJAQAAAA==.',
['术大']='术大招疯:BAAALgAECgEJAQAAAA==.',
['杜拉']='杜拉罕:BAAALgAECgMJAwABLgAFFAMJBwALACslAA==.',
['来包']='来包辣条压惊:BAAALgAECgEJAQAAAA==.',
['松子']='松子丶:BAACLgAFFH8FAAMOAAIJbA2ZHQCFAAAOAAIJbA2ZHQCFAAAVAAEJ8QGkGQA0AAAuAAQKfxYABA4ABgmGEbZCADgBAA4ABgmGEbZCADgBABUABAmUFk02ABgBABYABAmJC9FWALQAAAAA.',
['极速']='极速风云:BAAALgAECgEJAQAAAA==.',
['林小']='林小四丶:BAAALgAECgYJBwAAAA==.',
['枫与']='枫与铃:BAABLgAFFH8FAAIGAAIJ4yPICwDZAAAGAAIJ4yPICwDZAAABLgAFFAQJEQAXAPsfAA==.',
['柳词']='柳词妤梦:BAABLgAFFH8HAAIVAAQJ7BJuBwBIAQAVAAQJ7BJuBwBIAQAAAA==.',
['柴火']='柴火妞儿:BAAALgAECgEJAgAAAA==.',
['梦回']='梦回蝶恋:BAAALgAFFAIJAwAAAA==.',
['楚荀']='楚荀拉风:BAAALgAECgcJBwAAAA==.',
['樱丨']='樱丨桃:BAAALgAECgYJBQAAAA==.',
['橫練']='橫練宗師:BAABLgAFFH8HAAIOAAMJexRTEgDoAAAOAAMJexRTEgDoAAAAAA==.',
['欧兹']='欧兹那克:BAAALgAECgcJDQAAAA==.',
['歡喜']='歡喜佛:BAAALgAECgYJDwAAAA==.',
['死亡']='死亡执政官:BAABLgAECn8UAAISAAkJ+CDeCQBNAwASAAkJ+CDeCQBNAwABLgAFFAUJCQASAGomAA==.',
['死归']='死归寂:BAAALgADCgMJAwAAAA==.',
['死球']='死球:BAACLgAFFH8HAAISAAIJHybBEQDfAAASAAIJHybBEQDfAAAuAAQKfxcAAhIABgnIJOIvAHgCABIABgnIJOIvAHgCAAAA.',
['死雾']='死雾:BAAALgADCgUJBQAAAA==.',
['残小']='残小忍:BAAALgAECgYJBgAAAA==.',
['水姬']='水姬:BAAALgAECgYJDAAAAA==.',
['水龙']='水龙吟:BAAALgAECgIJAgAAAA==.',
['汪汪']='汪汪琴絃:BAAALgAECggJBQABLgAFFAUJBQAYADUPAA==.',
['沁园']='沁园春丶:BAAALgAECgMJAwAAAA==.',
['沐雨']='沐雨澄风:BAAALgADCgMJAwAAAA==.',
['没事']='没事打听打听:BAAALgAECgYJBgAAAA==.',
['泛舟']='泛舟当歌:BAAALgAECgUJBgAAAA==.',
['泷秋']='泷秋:BAEALgAFFAIJBAAAAA==.',
['浑身']='浑身伤硬梆梆:BAAALgAECgcJDwAAAA==.',
['浣熊']='浣熊妞妞:BAAALgAECgEJAQAAAA==.',
['淡色']='淡色艾尔:BAAALgADCgEJAQAAAA==.',
['深森']='深森丶:BAACLgAFFH8PAAIKAAQJ/xlbFgBwAQAKAAQJ/xlbFgBwAQAuAAQKfx8AAgoACAnWIVQdAAADAAoACAnWIVQdAAADAAAA.',
['混卷']='混卷:BAAALgAECgYJBgAAAA==.',
['游隼']='游隼:BAAALgAECgUJBgAAAA==.',
['溜溜']='溜溜琴絃:BAABLgAECn8nAAIEAAkJKyMuAABXAwAEAAkJKyMuAABXAwABLgAFFAcJAgACAAAAAA==.',
['漫天']='漫天灬飙血:BAAALgAECgkJAQAAAA==.',
['潘二']='潘二伯:BAAALgAECgIJAgAAAA==.',
['灬无']='灬无名氏灬:BAAALgAECgIJAgAAAA==.',
['灬皮']='灬皮卡丘灬:BAAALgADCgEJAQAAAA==.',
['灰灰']='灰灰狐:BAAALgADCgcJCAAAAA==.',
['灰烬']='灰烬之末:BAAALgAECgEJAQAAAA==.',
['烟花']='烟花一瞬:BAAALgAECgcJBwAAAA==.',
['烟雨']='烟雨丶:BAAALgAECgEJAQAAAA==.',
['烧火']='烧火棍子:BAAALgAECgIJAgAAAA==.',
['热爱']='热爱大自然:BAAALgADCgkJCQAAAA==.',
['焦太']='焦太狐:BAAALgAECgQJBAAAAA==.',
['熊猫']='熊猫橙大橙:BAAALgAFFAIJAgAAAA==.',
['爱忘']='爱忘忧:BAAALgAECgEJAQAAAA==.',
['物理']='物理易伤:BAAALgADCgQJBAAAAA==.',
['狂暴']='狂暴之力:BAAALgAECggJCAAAAA==.',
['狂紫']='狂紫三琪丶:BAACLgAFFH8FAAIKAAQJqwjkIABAAQAKAAQJqwjkIABAAQAuAAQKfx0AAgoACAmYHSM2AJsCAAoACAmYHSM2AJsCAAAA.',
['狮三']='狮三百:BAAALgADCgEJAQAAAA==.',
['猎魔']='猎魔狂徒:BAAALgAECgcJDgAAAA==.',
['猫没']='猫没有头:BAABLgAFFH8NAAISAAQJIyREBQCtAQASAAQJIyREBQCtAQAAAA==.',
['王者']='王者乐天:BAAALgAECgMJAwAAAA==.',
['珍珍']='珍珍:BAAALgAECgQJCAAAAA==.',
['琴月']='琴月陽:BAACLgAFFH8UAAIXAAcJDhigAgAyAgAXAAcJDhigAgAyAgAuAAQKfxoAAxcACAlGI7AIABMDABcACAkMI7AIABMDABkAAQlFJnaoAHQAAAAA.',
['瓒瓒']='瓒瓒没吃饱:BAAALgAECgQJBAAAAA==.',
['田木']='田木儿:BAAALgAECgYJDAAAAA==.',
['疏琉']='疏琉月影:BAAALgADCgEJAQABLgAFFAIJAwACAAAAAA==.',
['疯狂']='疯狂的切糕:BAAALgADCgUJAwAAAA==.',
['病了']='病了也是神:BAAALgADCgEJAQAAAA==.',
['白云']='白云:BAAALgAFFAIJBAAAAA==.',
['白毛']='白毛狐狸水:BAAALgAECgcJDwAAAA==.',
['白羊']='白羊朵池:BAAALgAECgMJAwABLgAFFAYJDQAaAGMNAA==.',
['白胡']='白胡子老爷爷:BAAALgAECgEJAQAAAA==.',
['直通']='直通天命:BAAALgAECgIJAgAAAA==.',
['相澤']='相澤南:BAAALgAFFAQJBAAAAA==.',
['知挚']='知挚:BAAALgAECgcJCQAAAA==.',
['破釜']='破釜沉舟:BAAALgAECgcJBwAAAA==.',
['碎雪']='碎雪映瞳:BAAALgAECgYJBgAAAA==.',
['神速']='神速的大狼犬:BAAALgAECgcJCgAAAA==.',
['神鬼']='神鬼回来了:BAAALgAECgYJBwAAAA==.',
['禅院']='禅院熊大:BAAALgAECgQJBAAAAA==.',
['秃噜']='秃噜皮:BAAALgAECgIJAgAAAA==.',
['笑看']='笑看风起:BAAALgAECgIJAgAAAA==.',
['第五']='第五个季节:BAAALgAECgUJBgAAAA==.',
['米莉']='米莉娅:BAAALgADCgEJAgAAAA==.',
['糖门']='糖门不要滚:BAAALgAECgYJCAAAAA==.',
['红小']='红小术:BAAALgAECgkJBwAAAA==.',
['纯刘']='纯刘莱:BAAALgAECgMJAwAAAA==.',
['缥缈']='缥缈如烟:BAAALgAECgEJAgAAAA==.',
['羽落']='羽落:BAAALgAECgYJCgAAAA==.',
['老娘']='老娘跟你拼啦:BAAALgAECgMJBAAAAA==.',
['聊一']='聊一聊:BAAALgAECgEJAgAAAA==.',
['肩胛']='肩胛骨:BAAALgAECgcJBwAAAA==.',
['胡桃']='胡桃大王:BAAALgAECgYJBgAAAA==.',
['脱脂']='脱脂龙奶:BAAALgAFFAIJAwAAAA==.',
['腐蚀']='腐蚀之剑:BAAALgAECgYJCAAAAA==.',
['腿短']='腿短真无奈:BAAALgAECgYJCgAAAA==.',
['致死']='致死压制:BAAALgAECgUJBQAAAA==.',
['艾丝']='艾丝卡诺:BAAALgADCgEJAQAAAA==.',
['花拳']='花拳绣腿丶:BAAALgAECgUJCAAAAA==.',
['花鳥']='花鳥风月:BAAALgAECgEJAQAAAA==.',
['苍白']='苍白圣光:BAAALgAECgEJAQAAAA==.',
['苏菲']='苏菲索玛:BAAALgAECgUJBwAAAA==.',
['茯苓']='茯苓酸奶:BAAALgAFFAEJAQAAAA==.',
['草台']='草台班子核心:BAAALgAECgMJBAAAAA==.',
['草莓']='草莓队长:BAAALgAECgYJBQAAAA==.',
['荼蘼']='荼蘼婲事了:BAAALgAECgQJCAAAAA==.',
['菈冬']='菈冬:BAAALgADCgEJAQAAAA==.',
['菲莉']='菲莉雅月蝕:BAABLgAECn8cAAIDAAcJ6yH7CwChAgADAAcJ6yH7CwChAgAAAA==.',
['萤火']='萤火照夜空:BAAALgAFFAIJAgAAAA==.',
['落天']='落天歌:BAAALgAECgQJBgAAAA==.',
['落日']='落日弥漫的橘:BAAALgADCgYJCwAAAA==.',
['蓁桢']='蓁桢爸:BAAALgAECgEJAQAAAA==.',
['虚幻']='虚幻无优:BAAALgAECgcJBwAAAA==.',
['蛮鼠']='蛮鼠皮卡丘:BAABLgAFFH8RAAMXAAQJ+x9zCgBxAQAXAAQJ8h9zCgBxAQAZAAIJih0lEgBlAAAAAA==.',
['血之']='血之咆哮:BAAALgAECgYJCAAAAA==.',
['西城']='西城黃昏:BAAALgAECgEJAQAAAA==.西城黄昏:BAAALgAECgMJAwAAAA==.',
['西塞']='西塞罗德:BAACLgAFFH8HAAILAAMJKyVhBwBRAQALAAMJKyVhBwBRAQAuAAQKfx8AAgsABwkcJYsIAPsCAAsABwkcJYsIAPsCAAAA.',
['诛头']='诛头骑士:BAAALgAECgYJCAAAAA==.',
['调戏']='调戏熊猫妹子:BAAALgAECgcJBwAAAA==.',
['豆包']='豆包儿:BAAALgAECgYJDAAAAA==.',
['赤兔']='赤兔:BAAALgAECgMJAwAAAA==.',
['赵日']='赵日天:BAAALgAECgQJDAAAAA==.',
['起名']='起名我不擅长:BAAALgAECgYJEwAAAA==.',
['跳起']='跳起躲冰环:BAAALgAECgMJBAAAAA==.',
['辛多']='辛多雷摄政王:BAAALgADCgUJCQAAAA==.',
['辛巴']='辛巴:BAAALgAECgYJDAAAAA==.',
['辰歌']='辰歌:BAAALgAECgQJBgAAAA==.',
['还要']='还要多久:BAAALgAECgEJAgAAAA==.',
['逆乱']='逆乱星空:BAAALgADCgMJAwAAAA==.',
['逆向']='逆向冲锋:BAAALgAECgQJBwAAAA==.',
['逍遥']='逍遥小哲:BAAALgAECgIJAgAAAA==.',
['避协']='避协套:BAAALgAECgkJCQAAAA==.',
['那个']='那个熊猫奶萨:BAAALgAECgEJAQAAAA==.',
['邪刃']='邪刃屠灵:BAAALgAECgEJAQAAAA==.',
['酒懵']='酒懵子:BAAALgAECgMJBAAAAA==.',
['錦繡']='錦繡:BAAALgAECgkJBwAAAA==.',
['钟无']='钟无梦:BAAALgADCgcJBwAAAA==.钟无艳丶:BAAALgAECgEJAQAAAA==.',
['铁锤']='铁锤哥哥:BAAALgAFFAQJBAAAAA==.',
['银月']='银月城的新娘:BAAALgAFFAIJBAAAAA==.',
['银渐']='银渐层丶:BAAALgAECgYJBgAAAA==.',
['银鳞']='银鳞与胸甲:BAAALgAECgYJEgAAAA==.',
['闪电']='闪电巧克力:BAAALgAFFAIJAgAAAA==.',
['闪血']='闪血:BAAALgAECgIJAgAAAA==.',
['闪雷']='闪雷:BAAALgAECgcJBwAAAA==.',
['阳光']='阳光灿烂丶:BAACLgAFFH8PAAIHAAQJ/xpcAQCDAQAHAAQJ/xpcAQCDAQAuAAQKfxsAAgcACAlnILcIAAYDAAcACAlnILcIAAYDAAAA.',
['阿玛']='阿玛忒拉斯:BAAALgAECgYJDgAAAA==.',
['阿瑟']='阿瑟比:BAAALgAECgQJBAAAAA==.',
['阿苏']='阿苏葱油饼:BAABLgAECn8XAAMbAAgJxxjfEQCrAQAbAAYJthzfEQCrAQAGAAIJ8Q76AwGOAAABLgAFFAMJBwAOAHsUAA==.',
['陌丶']='陌丶尕成:BAAALgAECgYJBgAAAA==.',
['隐身']='隐身药水:BAAALgADCgEJAQAAAA==.',
['雪尐']='雪尐糕:BAABLgAFFH8FAAIcAAIJLBmMIwCyAAAcAAIJLBmMIwCyAAAAAA==.',
['雪琛']='雪琛琛:BAAALgADCgIJAgAAAA==.',
['雪落']='雪落乄晚晚:BAAALgADCgEJAQAAAA==.雪落乄沫沫:BAAALgAECgYJDwAAAA==.',
['霜刃']='霜刃影歌:BAAALgADCgUJCQAAAA==.',
['霜火']='霜火追忆:BAABLgAECn8ZAAIKAAgJECaGCwBnAwAKAAgJECaGCwBnAwABLgAFFAUJAQACAAAAAA==.',
['霜烬']='霜烬挽歌:BAAALgAECgYJCwAAAA==.',
['露从']='露从今夜白:BAAALgAECgYJBwAAAA==.',
['霸气']='霸气豪情:BAAALgAECgcJCgAAAA==.',
['霸粑']='霸粑:BAAALgAECgYJBgABLgAFFAMJBwAOAHsUAA==.',
['青鸟']='青鸟之翼:BAAALgAECgYJBwAAAA==.',
['青龍']='青龍:BAAALgAECgcJDQAAAA==.',
['风残']='风残血:BAAALgAECgYJBgAAAA==.',
['飘仙']='飘仙:BAAALgAECgkJDAAAAA==.',
['飘寰']='飘寰冰释:BAAALgADCgYJCQAAAA==.',
['飘帅']='飘帅:BAAALgAECgEJAQAAAA==.',
['飞翔']='飞翔的大蒜:BAAALgADCgUJBQAAAA==.',
['飞魂']='飞魂乂落尽:BAAALgADCgUJBQAAAA==.',
['香蕉']='香蕉大恶魔:BAAALgAECgkJBwAAAA==.',
['馨悅']='馨悅:BAAALgAECgIJAgAAAA==.',
['骑乐']='骑乐无穷:BAAALgADCgYJBgAAAA==.',
['骚气']='骚气灬蓬勃:BAAALgAECgQJAwAAAA==.',
['魂刃']='魂刃:BAAALgAECgYJBgAAAA==.',
['魔幻']='魔幻神话:BAAALgAECgkJCQAAAA==.',
['鸡佬']='鸡佬灭霸:BAAALgAECgUJBQAAAA==.',
['鸡歪']='鸡歪怪马桶漏:BAAALgAECgYJDwAAAA==.',
['鹰月']='鹰月:BAAALgAECgcJBwAAAA==.',
['麦趣']='麦趣鸡盒:BAACLgAFFH8HAAIDAAIJYyHtBgDLAAADAAIJYyHtBgDLAAAuAAQKfyAAAgMABwnRIlkIAN0CAAMABwnRIlkIAN0CAAEuAAUUBAkRABcA+x8A.',
['黎羽']='黎羽晨:BAAALgAECgIJAgAAAA==.',
['黑布']='黑布:BAAALgADCgcJBwAAAA==.',
['黑心']='黑心秃头怪:BAAALgAECgIJBQAAAA==.',
['黑暗']='黑暗旋死:BAAALgAECgQJBgAAAA==.',
['黑渊']='黑渊白花:BAAALgAECgYJCQAAAA==.',
['黑长']='黑长直带钩子:BAAALgADCgYJBgAAAA==.',
['默然']='默然忘世:BAACLgAFFH8SAAISAAUJiCD2BACyAQASAAUJiCD2BACyAQAuAAQKfyEAAhIACAlsJC4PACMDABIACAlsJC4PACMDAAAA.',
['龙三']='龙三老大:BAABLgAFFH8KAAIaAAMJ5QojDwDiAAAaAAMJ5QojDwDiAAAAAA==.',
['龙鸣']='龙鸣羊:BAABLgAFFH8GAAMaAAQJuxWPBgC/AAAaAAQJuxWPBgC/AAAdAAEJ9hM6AgBdAAAAAA==.',
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
