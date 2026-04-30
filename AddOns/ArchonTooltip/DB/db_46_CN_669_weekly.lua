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

local lookup = {'Paladin-Holy','DemonHunter-Devourer','Druid-Restoration','Warrior-Protection','Unknown-Unknown','DeathKnight-Blood','Druid-Balance','DeathKnight-Unholy','Mage-Frost','Rogue-Subtlety','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship',}
local provider = {region='CN',realm='布鲁塔卢斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Af='Afterglow:BAAALgAECgUJBQABLgAFFAUJEAABANIVAA==.',
Bi='Bigsprite:BAABLgAFFH8FAAICAAQJogdFGAANAQACAAQJogdFGAANAQAAAA==.',
En='Endless:BAAALgADCgMJAwAAAA==.',
Fa='Fatpigjoy:BAAALgADCgEJAQAAAA==.',
Fe='Featmellow:BAAALgAECgUJBAAAAA==.',
Gl='Glacia:BAAALgAECgkJEQAAAA==.',
Ha='Harbinger:BAABLgAFFH8GAAIDAAMJhxL+EADhAAADAAMJhxL+EADhAAABLgAFFAUJEAABANIVAA==.',
Ic='Icee:BAAALgAECgQJBwAAAA==.',
Im='Immature:BAAALgADCgMJAwAAAA==.',
Is='Isoisoi:BAACLgAFFH8QAAIBAAUJ0hVzBgBwAQABAAUJ0hVzBgBwAQAuAAQKfxUAAgEACAkSHvUMALICAAEACAkSHvUMALICAAAA.',
Ki='Kidd:BAAALgAECgMJBQAAAA==.',
Ma='Maxholloway:BAABLgAFFH8LAAIEAAQJMBJAAgAqAQAEAAQJMBJAAgAqAQAAAA==.',
Me='Meloser:BAAALgAECgMJAwAAAA==.',
Mi='Miraclelight:BAAALgAECgMJAwAAAA==.',
Ne='Neverslave:BAAALgADCgIJAgAAAA==.',
Ok='Okk:BAAALgAECgMJAwAAAA==.',
Sh='Sher:BAAALgAECgEJAQAAAA==.',
Wi='Wich:BAAALgAECgYJDgAAAA==.',
['一牧']='一牧了燃:BAAALgADCgEJAQAAAA==.',
['一苇']='一苇之所如:BAAALgAECgEJAQAAAA==.',
['一起']='一起去看日出:BAAALgAECgEJAQAAAA==.',
['万灵']='万灵丿:BAAALgAECggJCAABLgAECggJCQAFAAAAAA==.',
['三条']='三条緋路:BAACLgAFFH8FAAIGAAMJcx96BwAYAQAGAAMJcx96BwAYAQAuAAQKfxoAAgYACAntIQcEABEDAAYACAntIQcEABEDAAAA.',
['三重']='三重刘德华:BAAALgAECgEJAQAAAA==.',
['不灭']='不灭徳托:BAAALgADCgMJAwAAAA==.不灭饕餮:BAAALgAFFAMJBAAAAA==.',
['不知']='不知梦:BAAALgAECggJEAAAAA==.',
['东方']='东方白:BAACLgAFFH8PAAIDAAQJWCBTBQCGAQADAAQJWCBTBQCGAQAuAAQKfxoAAgMACAnTJNQFAC8DAAMACAnTJNQFAC8DAAAA.',
['丶上']='丶上善若水:BAAALgAECgQJBQAAAA==.',
['丶烟']='丶烟雨的绸缪:BAAALgAFFAIJAgAAAA==.',
['乀禾']='乀禾木:BAAALgAECgEJAQAAAA==.',
['九条']='九条:BAAALgADCgYJBgAAAA==.',
['二舅']='二舅妈:BAAALgAECgYJBwAAAA==.',
['二队']='二队法湿羊我:BAAALgAECgEJAQAAAA==.',
['仲夏']='仲夏夜之梦:BAAALgAECgQJBQAAAA==.',
['克西']='克西雷姆:BAAALgAECgEJAQAAAA==.',
['六千']='六千里:BAAALgAECggJEAAAAA==.',
['冰檒']='冰檒戦神:BAABLgAFFH8JAAIEAAQJGgYeCADZAAAEAAQJGgYeCADZAAAAAA==.',
['劣人']='劣人:BAAALgAECgYJBgAAAA==.',
['劲暴']='劲暴男人:BAAALgAECgEJAQAAAA==.',
['勇彤']='勇彤:BAAALgAECgYJBgAAAA==.',
['十一']='十一强的可怕:BAAALgAECgQJBAAAAA==.',
['卩厶']='卩厶侽灬紸角:BAAALgAECgMJBAAAAA==.',
['卩灬']='卩灬尐鱼丨:BAAALgAECgMJAwAAAA==.',
['变态']='变态辣米线:BAAALgAECgEJAQAAAA==.',
['叫我']='叫我法爷:BAAALgADCgUJBQAAAA==.',
['吱妞']='吱妞妞:BAAALgAECgEJAQAAAA==.',
['咕德']='咕德猫柠:BAACLgAFFH8HAAIHAAMJQwjvDwDjAAAHAAMJQwjvDwDjAAAuAAQKfxUAAgcABwlvGp0lANABAAcABwlvGp0lANABAAAA.',
['嗡嗡']='嗡嗡的复仇:BAAALgAECgUJBQAAAA==.',
['嘬口']='嘬口泡泡糖:BAAALgADCgcJBwAAAA==.',
['噢呢']='噢呢:BAAALgADCgEJAQAAAA==.',
['回眸']='回眸谁浅笑丶:BAAALgAECgcJCAAAAA==.',
['囧啊']='囧啊囧的夏天:BAAALgADCgEJAQAAAA==.',
['圣戒']='圣戒:BAAALgAECgEJAQAAAA==.',
['塔兹']='塔兹米:BAAALgAECgEJAQAAAA==.',
['夏雨']='夏雨点滴:BAAALgAECgYJCQAAAA==.',
['多忐']='多忐忑的闷闷:BAAALgADCgYJBgAAAA==.',
['天堂']='天堂任鸟飞丶:BAAALgAECgYJEAAAAA==.',
['天灾']='天灾二等兵:BAABLgAECn8WAAIIAAgJhAoOeQCSAQAIAAgJhAoOeQCSAQAAAA==.',
['天蝎']='天蝎座的回忆:BAAALgAECgUJBwAAAA==.',
['奄鸟']='奄鸟亨鸟:BAAALgAFFAIJAwAAAA==.',
['小开']='小开的血圣:BAAALgAECgYJBgAAAA==.',
['小恶']='小恶魔莉莉丝:BAAALgADCgUJBgAAAA==.',
['小旋']='小旋风:BAABLgAECn8bAAIJAAcJyw47nwCYAQAJAAcJyw47nwCYAQAAAA==.',
['小盗']='小盗萌奇:BAAALgAECgEJAgAAAA==.',
['小酋']='小酋长:BAAALgAECgEJAwAAAA==.',
['小野']='小野无敌:BAAALgAECgQJBgAAAA==.',
['尾巴']='尾巴不能吃牛:BAAALgAECgMJAwAAAA==.',
['巨蟹']='巨蟹座霆霆:BAABLgAFFH8LAAICAAYJaRsRAQDFAQACAAYJaRsRAQDFAQAAAA==.',
['巴洛']='巴洛菲:BAAALgAECgEJAQAAAA==.',
['带刀']='带刀炳哥:BAAALgAECgIJAwAAAA==.',
['幽骨']='幽骨御灵:BAAALgADCgkJCQAAAA==.',
['康斯']='康斯坦丁:BAABLgAFFH8FAAIKAAMJowoGDwAAAQAKAAMJowoGDwAAAQAAAA==.',
['开搞']='开搞开搞:BAAALgADCgEJAQAAAA==.',
['弗雷']='弗雷尔络寺:BAAALgAECgUJBgAAAA==.',
['悲剧']='悲剧小牧:BAAALgAECgYJBQAAAA==.',
['愤怒']='愤怒的烟灰:BAAALgADCgEJAQAAAA==.',
['慕克']='慕克白:BAAALgAECgUJBQAAAA==.',
['战刃']='战刃透心凉:BAAALgAFFAEJAQAAAA==.',
['文雅']='文雅适合我:BAAALgAECgcJCAAAAA==.',
['新角']='新角色重复:BAAALgAECgMJAwAAAA==.',
['无尽']='无尽冰霜:BAAALgAECgYJDgAAAA==.',
['暖暖']='暖暖丶莹莹:BAAALgADCgYJCAAAAA==.',
['曼爷']='曼爷:BAAALgAECgEJAQAAAA==.',
['月紳']='月紳埃露蒽:BAAALgADCgEJAQAAAA==.',
['杀猪']='杀猪的神:BAAALgAECgYJCAAAAA==.',
['村口']='村口一蹲:BAAALgAECgQJBAAAAA==.',
['果冻']='果冻快感妹:BAAALgADCgYJBgAAAA==.',
['梦回']='梦回追忆:BAAALgAECgQJBwAAAA==.',
['梦境']='梦境乌鸦:BAAALgAECgkJCwAAAA==.',
['梦霜']='梦霜:BAAALgAECgYJCgAAAA==.',
['死鬼']='死鬼:BAAALgAECgIJAwAAAA==.',
['法网']='法网灰灰:BAAALgAECgkJCQAAAA==.',
['洛里']='洛里山:BAAALgAECgEJAQAAAA==.',
['浮云']='浮云蔽世:BAAALgAECgEJAQAAAA==.',
['淡定']='淡定的肉丝:BAAALgAECgEJAQAAAA==.',
['淡然']='淡然落幕:BAAALgAECgkJEQAAAA==.',
['渣男']='渣男:BAAALgAECgQJBAAAAA==.',
['滚球']='滚球:BAAALgAECgMJAwAAAA==.',
['灰色']='灰色年伦:BAAALgAECgcJDwAAAA==.',
['点子']='点子王:BAAALgAECgEJAQAAAA==.',
['烟酒']='烟酒生哥哥:BAAALgAFFAEJAgAAAA==.',
['皓日']='皓日云瑕:BAAALgAECgIJAgAAAA==.',
['破天']='破天丿:BAAALgAECggJCQAAAA==.',
['神秘']='神秘武林高手:BAAALgAECgYJDwAAAA==.',
['离垢']='离垢:BAAALgAECgYJCwAAAA==.',
['秋千']='秋千:BAAALgAECgQJAQAAAA==.',
['稼轩']='稼轩:BAABLgAECn8WAAQLAAcJciB6KwAGAgAMAAcJJRz1CgAmAgALAAcJrR56KwAGAgANAAEJ6gNykQApAAAAAA==.',
['空山']='空山清雨:BAAALgAECgMJAwAAAA==.',
['站住']='站住不许走:BAAALgAECgYJDQAAAA==.',
['筱隆']='筱隆隆筱:BAAALgADCggJCAAAAA==.',
['管中']='管中窥鲍:BAAALgAECgEJAgAAAA==.',
['索马']='索马里牛肉:BAAALgAECgEJAQAAAA==.',
['紫色']='紫色苍神:BAAALgADCgEJAQAAAA==.',
['缺心']='缺心眼子:BAAALgAECgIJAgAAAA==.',
['群龙']='群龙天下:BAABLgAECn8eAAIJAAcJxBx6dgDlAQAJAAcJxBx6dgDlAQAAAA==.',
['老罗']='老罗丨:BAAALgAECgYJCwAAAA==.老罗丶:BAAALgAECggJCAAAAA==.',
['肥肥']='肥肥的熊缺:BAAALgAECgUJBQAAAA==.',
['艾鑔']='艾鑔:BAAALgADCgEJAQAAAA==.',
['芭比']='芭比姆涅:BAAALgAECgEJAQAAAA==.',
['花石']='花石头:BAAALgAFFAEJAQAAAA==.',
['苏可']='苏可卷:BAAALgAECgkJCwAAAA==.',
['若叶']='若叶睦:BAAALgADCgEJAQAAAA==.',
['若熙']='若熙妈妈:BAAALgAECgYJBgAAAA==.',
['莱昂']='莱昂梅西:BAAALgAFFAIJAwAAAA==.',
['萨旦']='萨旦:BAAALgADCgYJBgAAAA==.',
['蔓草']='蔓草多露:BAAALgAECgEJAQAAAA==.',
['蛮托']='蛮托托:BAAALgAECgYJCwAAAA==.',
['血燕']='血燕:BAAALgAECgYJBgAAAA==.',
['见面']='见面就吼叫:BAAALgAFFAIJAwAAAA==.',
['角斗']='角斗士:BAAALgAFFAQJBAABLgAFFAgJAQAFAAAAAA==.',
['誓约']='誓约的烙印:BAAALgAECgQJCgAAAA==.',
['认真']='认真听课:BAAALgAECgkJCQABLgAFFAQJAwAFAAAAAA==.',
['豆浆']='豆浆不甜:BAAALgAECgYJCQAAAA==.',
['轻锋']='轻锋绕指柔:BAAALgAECgYJBgAAAA==.',
['送你']='送你故事和酒:BAAALgAECgYJEAAAAA==.',
['逆苍']='逆苍兲:BAAALgAECgUJCAAAAA==.',
['逆风']='逆风燎千里:BAAALgAFFAEJAQAAAA==.',
['逝水']='逝水天涯:BAAALgAECgEJAQAAAA==.',
['问心']='问心无愧:BAAALgADCgYJAwAAAA==.',
['防护']='防护员:BAAALgAECggJDwAAAA==.',
['雷古']='雷古鲁斯:BAABLgAFFH8FAAIIAAIJeRPwPQCjAAAIAAIJeRPwPQCjAAAAAA==.',
['露奈']='露奈雅拉:BAAALgAFFAEJAQAAAA==.',
['风小']='风小狐:BAAALgAECgQJBgAAAA==.',
['飞翔']='飞翔的轰炸鸡:BAAALgAECgEJAQAAAA==.',
['魅影']='魅影尔:BAAALgADCgMJAwAAAA==.',
['麻薯']='麻薯师傅:BAAALgADCgMJAwAAAA==.',
['龙骑']='龙骑士:BAAALgADCgEJAQAAAA==.',
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
