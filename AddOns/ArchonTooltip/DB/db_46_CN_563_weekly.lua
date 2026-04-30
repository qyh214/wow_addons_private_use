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

local lookup = {'Mage-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','DemonHunter-Havoc','DemonHunter-Vengeance','DemonHunter-Devourer','DeathKnight-Unholy','Warlock-Demonology','Unknown-Unknown','Paladin-Holy','Paladin-Retribution','Monk-Mistweaver','Priest-Holy','Priest-Shadow','Warrior-Fury','Druid-Restoration','Monk-Windwalker','Warrior-Protection','Druid-Balance','Priest-Discipline','Warlock-Destruction','Warlock-Affliction','Evoker-Preservation',}
local provider = {region='CN',realm='丹莫德',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ag='Ageless:BAAALgAECgQJBAAAAA==.',
Ay='Ayanami:BAAALgAECgQJBAAAAA==.',
Ba='Baku:BAAALgAECgEJAgAAAA==.',
Be='Beetomb:BAAALgAECgEJAQAAAA==.',
Br='Brokenpoint:BAAALgAECgEJAQAAAA==.',
Ca='Cantchatws:BAAALgAECggJCAAAAA==.Caotama:BAAALgAECgUJCgAAAA==.',
Da='Danny:BAAALgAECgQJBwAAAA==.',
De='Deathblow:BAAALgAECgYJBgABLgAFFAUJBwABAMcZAA==.Destinyy:BAABLgAECn8WAAQCAAcJhxl/EgBoAQACAAcJthZ/EgBoAQADAAUJEhDlTQAYAQAEAAIJzgYUKgBfAAAAAA==.Devinbo:BAABLgAECn8VAAQFAAYJ4QdZOgAYAQAFAAYJxQdZOgAYAQAGAAYJ+gLoBgCrAAAHAAEJbAB1+AAIAAAAAA==.',
Do='Doublekiki:BAAALgAECgYJBwAAAA==.',
Dr='Dragontec:BAAALgAECgYJBgAAAA==.',
Dw='Dwarves:BAAALgAECgEJAgAAAA==.',
El='Eliilol:BAAALgAFFAIJBAAAAA==.',
Gu='Guerdan:BAAALgAECgcJAQABLgAFFAQJBwAIAOAIAA==.',
Hb='Hbend:BAABLgAFFH8KAAIJAAQJmheeBQBeAQAJAAQJmheeBQBeAQAAAA==.',
Hr='Hrunting:BAAALgAECgMJAwAAAA==.',
Hu='Hurr:BAAALgAECgEJAQAAAA==.',
Ku='Kumo:BAAALgAFFAUJBAABLgAFFAcJBAAKAAAAAA==.',
Ly='Lyudmila:BAAALgADCgMJAwAAAA==.',
Mo='Moo:BAAALgAECgYJDAAAAA==.',
Or='Orcship:BAAALgAECgQJBAAAAA==.',
Pu='Punchme:BAAALgAECgYJCQAAAA==.',
Re='Reverend:BAAALgAECgQJBAAAAA==.',
Sa='Sanmizi:BAAALgAECgEJAQAAAA==.',
Sn='Snotra:BAAALgAECgEJAQAAAA==.',
Sp='Spark:BAAALgAECgQJBwAAAA==.Springmao:BAAALgAECgYJBgAAAA==.',
Wh='Whitewwk:BAAALgAECgEJAQABLgAECgkJDAAKAAAAAA==.',
['一丿']='一丿瀬志希:BAACLgAFFH8TAAMLAAUJKhSdCQA8AQALAAUJKhSdCQA8AQAMAAIJSQ1HKACXAAAuAAQKfx8AAwsACAk+IqUHAPMCAAsACAk+IqUHAPMCAAwAAwlfGGzLAPIAAAEuAAUUBgkIAA0AHQwA.',
['一大']='一大波骑士:BAAALgAECgIJAwAAAA==.',
['一生']='一生香伴:BAAALgADCggJCAAAAA==.',
['一箭']='一箭穿心丶:BAAALgAECgQJBAAAAA==.',
['三叉']='三叉络腮胡:BAAALgAFFAEJAQAAAA==.',
['上原']='上原美凉:BAAALgAECgEJAQAAAA==.',
['两小']='两小儿辩曰:BAAALgADCgMJAwAAAA==.',
['丨三']='丨三色堇丨:BAAALgAECgEJAQAAAA==.',
['丶月']='丶月神:BAAALgAFFAEJAQAAAA==.',
['丶菠']='丶菠萝:BAAALgAECgYJCwAAAA==.',
['丿清']='丿清欢丶牛灬:BAAALgAECgEJAQAAAA==.',
['乃乃']='乃乃个熊:BAAALgAECgUJBQAAAA==.',
['习惯']='习惯衝動:BAAALgAECgQJBQAAAA==.',
['二四']='二四年底入坑:BAAALgAECgEJAQAAAA==.',
['云深']='云深不知处:BAAALgADCgcJBwAAAA==.',
['云熠']='云熠甜粥铺:BAAALgAECgkJEAAAAA==.',
['云紫']='云紫幽兰:BAAALgADCgIJAgAAAA==.',
['五十']='五十已到:BAAALgADCgMJAwAAAA==.',
['亿叮']='亿叮定乾坤:BAAALgAECgcJCQAAAA==.',
['今夜']='今夜浪漫:BAAALgADCgIJAgAAAA==.',
['伊利']='伊利达瑞尔:BAAALgADCgMJAwAAAA==.',
['伐要']='伐要太难看:BAAALgAECgYJCQAAAA==.',
['你缺']='你缺肾骑士吗:BAAALgAFFAEJAQAAAA==.',
['俺要']='俺要吃蜂蜜:BAAALgAECgYJBgAAAA==.',
['倚西']='倚西楼:BAAALgAECgcJBwAAAA==.',
['偷你']='偷你大毕斗:BAAALgADCgUJBQAAAA==.',
['先祖']='先祖之父:BAAALgAECgkJBwAAAA==.',
['光至']='光至皆净土:BAAALgAECgEJAQAAAA==.',
['克里']='克里斯丶:BAAALgAECgYJBgAAAA==.',
['兜兜']='兜兜木有豆豆:BAABLgAECn8cAAMOAAkJZyBsAgBEAwAOAAkJZyBsAgBEAwAPAAcJyBOxKACUAQAAAA==.',
['入戯']='入戯丶冭深:BAAALgADCgUJBgAAAA==.',
['六点']='六点帅四点德:BAAALgADCgIJAgAAAA==.',
['兽人']='兽人:BAAALgADCgMJAwAAAA==.',
['再嘘']='再嘘也要社:BAABLgAECn8XAAMCAAcJZBdHOwDBAQACAAcJZBdHOwDBAQADAAEJ2wNjlwAgAAAAAA==.',
['冰姬']='冰姬:BAAALgAECgIJAgAAAA==.',
['冰炎']='冰炎傲义:BAAALgAECgEJAQAAAA==.',
['冰颜']='冰颜雪魄:BAAALgADCgcJDAAAAA==.',
['况猫']='况猫人之谜:BAAALgADCgEJAQAAAA==.',
['净火']='净火明神:BAAALgADCgEJAQAAAA==.',
['凝光']='凝光斩星:BAAALgADCgEJAQAAAA==.',
['凡人']='凡人青:BAAALgAECgYJCAAAAA==.',
['凤翔']='凤翔歧水:BAAALgAECgYJCwAAAA==.',
['刀锋']='刀锋无痕:BAAALgAECgYJBgAAAA==.',
['刻于']='刻于星月之铭:BAAALgAFFAEJAgAAAA==.',
['化古']='化古:BAAALgAECgQJCgAAAA==.',
['北川']='北川杏树:BAAALgAFFAIJAgAAAA==.',
['北辰']='北辰丶林:BAAALgAECgYJBAABLgAFFAQJBQAQAOwGAA==.',
['十二']='十二兽龙枪:BAAALgADCgEJAQAAAA==.',
['十米']='十米未蓝:BAAALgAECgIJAgAAAA==.',
['午夜']='午夜乖乖:BAABLgAECn8UAAMDAAcJRhdjTwARAQADAAUJYhljTwARAQACAAQJ+RKThQDXAAAAAA==.',
['卡拉']='卡拉季:BAAALgAECgQJBQAAAA==.',
['卫生']='卫生金:BAAALgAECgEJAQAAAA==.',
['只会']='只会变咕咕:BAAALgAECgUJBQAAAA==.',
['叭叭']='叭叭啦叭叭丶:BAAALgAFFAMJBAAAAA==.',
['可乐']='可乐:BAAALgAECgQJBAAAAA==.',
['可靠']='可靠的女人:BAAALgADCgUJBQAAAA==.',
['吃瓜']='吃瓜:BAAALgADCgMJAwAAAA==.',
['听雨']='听雨居:BAAALgAECgQJBQAAAA==.',
['吾氖']='吾氖周康帥:BAAALgAECgYJBgAAAA==.',
['周七']='周七七:BAAALgAECgcJDgAAAA==.',
['咆哮']='咆哮哥:BAAALgAECgQJBgAAAA==.',
['咋真']='咋真紧张:BAAALgAFFAIJAwAAAA==.',
['哇丶']='哇丶你的鸡丁:BAAALgAECgUJBgAAAA==.',
['哟丶']='哟丶切克闹:BAAALgADCgEJAQAAAA==.',
['唯恋']='唯恋灬尐尐豚:BAAALgAECgEJAQAAAA==.',
['啤梨']='啤梨巴馬:BAAALgAECgYJDAAAAA==.',
['喝邪']='喝邪能睡觉:BAAALgAFFAIJAgAAAA==.',
['嘉心']='嘉心糖:BAAALgADCgEJAQABLgAFFAIJAwAKAAAAAA==.',
['囧猎']='囧猎囧:BAAALgAFFAQJAgAAAA==.',
['圣伪']='圣伪娘:BAAALgAECgYJDAAAAA==.',
['圣光']='圣光幻想:BAAALgAECgEJAgAAAA==.',
['在下']='在下迪咳:BAAALgAFFAQJBAAAAA==.',
['堕落']='堕落者的疯狂:BAAALgAECgcJDgAAAA==.',
['墨染']='墨染红尘:BAAALgAECgYJCwAAAA==.',
['夜刃']='夜刃:BAAALgADCgMJAwAAAA==.',
['夜未']='夜未央:BAABLgAECn8VAAIRAAcJJRimQwCTAQARAAcJJRimQwCTAQAAAA==.',
['大哥']='大哥丿大:BAAALgADCgUJBQAAAA==.',
['大崎']='大崎娜娜:BAAALgAECgYJBgAAAA==.',
['大料']='大料:BAAALgAECgYJAgAAAA==.',
['大桥']='大桥丶未久:BAAALgAECgEJAgAAAA==.',
['大牛']='大牛仔:BAACLgAFFH8JAAIMAAMJFyJVEAAkAQAMAAMJFyJVEAAkAQAuAAQKfx4AAwsABwntG3cdACoCAAsABwntG3cdACoCAAwABAmYIGO0ABsBAAEuAAUUBAkLABIAexcA.',
['大神']='大神凉子:BAAALgADCgEJAQAAAA==.',
['大雪']='大雪无痕:BAAALgAECgQJBAAAAA==.',
['天呐']='天呐你可真帅:BAAALgAECgIJAgAAAA==.天呐您真猛:BAAALgAECgYJBgAAAA==.',
['天海']='天海春香:BAACLgAFFH8IAAINAAYJHQyLBACaAQANAAYJHQyLBACaAQAuAAQKfxUAAw0ACAnCH2oKAKwCAA0ABwkzJGoKAKwCABIAAwmCA5VwAFAAAAAA.',
['天灾']='天灾小蚊香:BAAALgAECgUJBwAAAA==.',
['天线']='天线爆爆:BAAALgAECgkJCQAAAA==.',
['奋斗']='奋斗章鱼哥:BAAALgAFFAEJAQAAAA==.',
['奘頭']='奘頭晓晓:BAAALgAFFAEJAQAAAA==.',
['奥蓝']='奥蓝多:BAAALgAECgQJBAAAAA==.',
['女团']='女团:BAACLgAFFH8JAAITAAMJuAa/CQCzAAATAAMJuAa/CQCzAAAuAAQKfxcAAhMABgkXFXkbAG8BABMABgkXFXkbAG8BAAAA.',
['好狐']='好狐狸:BAAALgAECgYJDwAAAA==.',
['如沐']='如沐丶春风:BAAALgADCgEJAQABLgAECgcJFQARACUYAA==.',
['宅阿']='宅阿霏:BAAALgAECgYJBwAAAA==.',
['宝批']='宝批龙:BAAALgAFFAQJBAAAAA==.',
['害怕']='害怕母铁鸡:BAABLgAFFH8HAAIHAAMJKhitGgD7AAAHAAMJKhitGgD7AAAAAA==.',
['寒蕊']='寒蕊:BAAALgAECgQJBgAAAA==.',
['射后']='射后圣如佛:BAAALgADCgEJAQAAAA==.',
['射灬']='射灬射灬射灬:BAABLgAFFH8HAAICAAMJ/SUhBQArAQACAAMJ/SUhBQArAQAAAA==.',
['小乔']='小乔流丶水:BAAALgAECgEJAQAAAA==.',
['小伙']='小伙伴在哪里:BAAALgAFFAEJAQAAAA==.',
['小子']='小子真帅:BAAALgAECgYJBQAAAA==.小子蛮坏:BAABLgAFFH8FAAICAAMJLBgzCgAQAQACAAMJLBgzCgAQAQAAAA==.',
['小小']='小小萨鲁法尔:BAAALgAFFAIJBAAAAA==.',
['小怪']='小怪兽凹凸曼:BAAALgADCgEJAQAAAA==.',
['小禽']='小禽獸丷:BAAALgAECgYJEAAAAA==.',
['小粟']='小粟:BAAALgAECgUJBgAAAA==.',
['小菇']='小菇娘丶快跑:BAAALgAECgIJAgAAAA==.',
['小飞']='小飞哥哥:BAAALgADCgIJAgAAAA==.',
['尛哆']='尛哆哆:BAAALgADCgEJAQAAAA==.',
['就要']='就要在一起:BAAALgAFFAQJBAAAAA==.',
['尾巴']='尾巴甩甩:BAAALgADCgYJBgAAAA==.',
['岁月']='岁月兮无痕:BAAALgAECgcJBwAAAA==.',
['巅峰']='巅峰一猎银:BAAALgAECgIJAwAAAA==.',
['巧克']='巧克力柠萃:BAAALgAECgkJCQAAAA==.',
['布莱']='布莱克丶圣蹄:BAAALgAECgQJBAAAAA==.',
['希崎']='希崎樱木凛:BAAALgAECgEJAQAAAA==.',
['帕秋']='帕秋莉喏蕾姬:BAAALgAFFAIJAgAAAA==.',
['帚星']='帚星:BAAALgAFFAIJBAAAAA==.',
['带带']='带带大魔王:BAAALgAECgEJAQAAAA==.',
['带我']='带我飞:BAAALgAECgIJAQAAAA==.',
['平日']='平日上去:BAAALgADCgQJCAAAAA==.',
['幻世']='幻世沧海:BAABLgAECn8YAAMLAAcJ0RXiMQC4AQALAAcJ0RXiMQC4AQAMAAQJ2hjcugAQAQAAAA==.',
['幽光']='幽光:BAAALgAFFAIJAwAAAA==.幽光星星丶:BAAALgAFFAEJAQAAAA==.',
['异鬼']='异鬼:BAAALgAECgMJAQAAAA==.',
['弄土']='弄土堆纪念你:BAAALgAFFAEJAQAAAA==.',
['弹幕']='弹幕屏障:BAAALgADCgYJBgAAAA==.',
['强哥']='强哥带你灰:BAAALgADCgUJBQAAAA==.',
['影刃']='影刃:BAAALgAECgYJEgABLgAECgYJFQABAGwgAA==.',
['微风']='微风吹:BAAALgAECgcJDAABLgAECgcJFQARACUYAA==.',
['德之']='德之我幸:BAAALgAECgYJBgABLgAFFAQJBAAKAAAAAA==.',
['心之']='心之猖狂如龙:BAAALgAECgEJAQAAAA==.',
['心灵']='心灵纵火犯:BAAALgAECgUJBQAAAA==.',
['快乐']='快乐面具:BAAALgADCgUJBQAAAA==.',
['快得']='快得很:BAAALgAECgcJBwAAAA==.',
['念戰']='念戰之觴:BAAALgADCgEJAQAAAA==.',
['惟馀']='惟馀莽莽:BAAALgAECgQJAwAAAA==.',
['惩戒']='惩戒的力量:BAAALgADCgEJAQAAAA==.',
['我想']='我想打兜兜:BAAALgAECggJEAAAAA==.',
['我接']='我接得嘎笑笑:BAAALgAECgIJAgAAAA==.',
['我热']='我热烈得马:BAAALgAECgMJBAAAAA==.',
['房中']='房中術:BAAALgAECgEJAQAAAA==.',
['房裹']='房裹窝:BAAALgAFFAUJBAAAAA==.',
['打土']='打土豪分田地:BAAALgADCgYJBQAAAA==.',
['托米']='托米小粗腿耶:BAAALgAECgYJCQAAAA==.',
['扛霸']='扛霸:BAAALgADCgcJBwAAAA==.',
['拔丝']='拔丝紫薯:BAAALgAECgQJBAAAAA==.',
['拼命']='拼命三郎:BAAALgAECgEJAQAAAA==.',
['指尖']='指尖微涼:BAAALgADCgIJAgAAAA==.指尖流年:BAAALgAECgQJDQAAAA==.',
['摸鱼']='摸鱼的阿昆达:BAAALgAECgEJAQAAAA==.',
['故地']='故地重游:BAAALgADCgIJAgAAAA==.',
['救死']='救死扶桑:BAAALgAECgUJBQAAAA==.',
['敲你']='敲你烂番茄:BAAALgAECgUJBQAAAA==.',
['施华']='施华洛世骑:BAAALgAECgcJAQAAAA==.',
['施法']='施法距离为零:BAAALgAFFAQJAgAAAA==.',
['无人']='无人似花依旧:BAAALgAECgEJAQAAAA==.',
['无敌']='无敌大波浪:BAAALgAECgQJBAAAAA==.',
['星野']='星野丶瑞羽凉:BAAALgAFFAMJBAAAAA==.',
['春春']='春春牛:BAAALgAECgYJBgAAAA==.',
['昼奈']='昼奈儿丶:BAAALgAECgYJCQABLgAFFAMJBgASAN4VAA==.',
['暖暖']='暖暖爱你:BAAALgAECgcJEQAAAA==.',
['暗玥']='暗玥之瞳:BAAALgAECgUJBwAAAA==.',
['暮色']='暮色千秋:BAAALgAECgYJCgAAAA==.',
['曦寳']='曦寳:BAAALgAECgcJBwAAAA==.',
['曦寶']='曦寶:BAAALgAECggJCQAAAA==.',
['曼陀']='曼陀沙华:BAAALgAECgcJCAABLgAFFAUJBQARAJkcAA==.',
['最终']='最终天堂:BAAALgAFFAIJAgAAAA==.',
['月风']='月风魔:BAAALgAFFAEJAQAAAA==.',
['有一']='有一种酒独醉:BAAALgAECgIJAgAAAA==.',
['术术']='术术里斯:BAAALgADCgMJAwAAAA==.',
['杨乔']='杨乔治丶:BAAALgAFFAEJAQAAAA==.',
['柒肆']='柒肆带我飞:BAAALgAECgMJAwAAAA==.',
['柚木']='柚木缇娜:BAAALgAFFAEJAQAAAA==.',
['桃田']='桃田賢斗:BAAALgAECgkJAQAAAA==.',
['橙南']='橙南:BAABLgAFFH8FAAIIAAIJ/SDJMADJAAAIAAIJ/SDJMADJAAAAAA==.',
['正在']='正在战斗中:BAAALgAFFAEJAQAAAA==.正在送餐:BAAALgAFFAQJBAAAAA==.',
['此时']='此时彼刻之人:BAAALgADCgYJBgAAAA==.',
['殛奶']='殛奶德:BAAALgADCgYJBgAAAA==.',
['毁灭']='毁灭旋律:BAAALgAECggJAQAAAA==.',
['毛酒']='毛酒:BAAALgAECgUJCQAAAA==.',
['江苏']='江苏吴彦祖丶:BAAALgAECgIJAgAAAA==.',
['油炸']='油炸带鱼:BAAALgADCgYJBQAAAA==.',
['法丶']='法丶丶神:BAAALgAECgUJBQAAAA==.',
['法师']='法师拉个桌子:BAAALgADCgIJAgAAAA==.',
['泥巴']='泥巴球:BAAALgAECgYJBgAAAA==.',
['洛洛']='洛洛丶:BAAALgAECgYJCwAAAA==.',
['淳风']='淳风:BAAALgAECgYJBgAAAA==.',
['混世']='混世灬眼眸:BAAALgAECgEJAQAAAA==.',
['漂浮']='漂浮群岛:BAAALgAECgIJAwAAAA==.',
['潮汕']='潮汕手打牛丸:BAAALgAFFAQJBAAAAA==.',
['火山']='火山娃儿:BAAALgADCgQJBAAAAA==.',
['火锅']='火锅一号:BAAALgADCgMJAwAAAA==.',
['火锤']='火锤:BAAALgADCgQJBAAAAA==.',
['灬丨']='灬丨拜拜:BAAALgAECgEJAQAAAA==.',
['灰蹄']='灰蹄丶怒风:BAAALgAECgYJBgAAAA==.',
['灵魂']='灵魂:BAAALgAECgEJAgAAAA==.',
['烈火']='烈火咕咕:BAAALgADCgYJBgAAAA==.',
['烦侬']='烦侬娘西撇:BAAALgAECgkJCQABLgAECgkJFwATAMAcAA==.',
['熊二']='熊二哥:BAAALgAECgcJCwAAAA==.',
['熊型']='熊型小饼干:BAAALgAECgYJDAAAAA==.',
['熊妈']='熊妈妈爱你哟:BAAALgAECgQJBAAAAA==.',
['熊小']='熊小孩:BAAALgAECgEJAQAAAA==.',
['燃血']='燃血阿瑞斯:BAAALgAECgQJBAAAAA==.',
['爆炸']='爆炸的石头:BAAALgADCgUJBQAAAA==.',
['爬牆']='爬牆頭等紅杏:BAAALgAFFAEJAQAAAA==.',
['爱丽']='爱丽德:BAAALgAECgUJBgAAAA==.',
['爸爸']='爸爸乔一乔:BAAALgAECgUJCgAAAA==.',
['牛盾']='牛盾:BAAALgAECgQJBgAAAA==.',
['特工']='特工小八:BAAALgADCgkJBQAAAA==.',
['狂朝']='狂朝:BAAALgAECgYJAgAAAA==.',
['王二']='王二哇:BAAALgAECgQJAwAAAA==.',
['玖玖']='玖玖德德:BAAALgADCgIJAgAAAA==.',
['玩原']='玩原神玩的:BAAALgAECgcJAgAAAA==.',
['玲珑']='玲珑:BAAALgAECgEJAQAAAA==.',
['甜甜']='甜甜圈丶:BAAALgADCgEJAQAAAA==.',
['番茄']='番茄炖牛腩:BAAALgAECgcJEAAAAA==.',
['白不']='白不白:BAABLgAECn8VAAIGAAcJExitCQDSAQAGAAcJExitCQDSAQAAAA==.',
['白夜']='白夜寒星:BAAALgAECgcJBwAAAA==.',
['白翼']='白翼誓约:BAAALgAECgQJDwAAAA==.',
['皮皮']='皮皮夏:BAAALgAECgMJBAAAAA==.',
['盒子']='盒子猫:BAAALgAECgYJCAAAAA==.',
['盲僧']='盲僧戴天牧:BAAALgADCgMJAwAAAA==.',
['相公']='相公丶:BAAALgAECgQJBQAAAA==.',
['看海']='看海:BAAALgAFFAIJAwAAAA==.',
['眸年']='眸年眸衵:BAAALgADCgYJBgAAAA==.',
['睡佛']='睡佛:BAAALgAECgIJAgAAAA==.',
['瞄咪']='瞄咪:BAAALgAECgcJCwAAAA==.',
['瞎了']='瞎了眼的胖几:BAABLgAFFH8IAAIHAAQJaBnqDwBPAQAHAAQJaBnqDwBPAQAAAA==.瞎了眼的胖纸:BAABLgAECn8aAAIHAAkJzRHXMwAqAgAHAAkJzRHXMwAqAgAAAA==.',
['瞎指']='瞎指挥:BAAALgAECgQJBwAAAA==.',
['矿泉']='矿泉水:BAAALgADCgIJAgAAAA==.',
['硬是']='硬是巴适耶:BAAALgADCgQJBAAAAA==.',
['硬笔']='硬笔的正反面:BAAALgADCgYJBgAAAA==.',
['示岁']='示岁:BAAALgAECgMJAwABLgAFFAIJBQAIAP0gAA==.',
['笑萨']='笑萨满:BAAALgAECgUJBQAAAA==.',
['第八']='第八术师:BAAALgADCgcJAgAAAA==.',
['米汀']='米汀:BAAALgADCgMJAwAAAA==.',
['紫色']='紫色魅影:BAAALgADCgYJBgAAAA==.',
['红姨']='红姨:BAAALgADCgUJBQAAAA==.',
['纵地']='纵地摘星:BAAALgAECgEJAgAAAA==.',
['结冰']='结冰的太阳:BAAALgAECgEJAQAAAA==.',
['给我']='给我过来添添:BAAALgADCgEJAQAAAA==.',
['绝世']='绝世糖门术:BAABLgAFFH8FAAIJAAIJ+hNfMgCuAAAJAAIJ+hNfMgCuAAAAAA==.',
['绿皮']='绿皮专抓圣女:BAAALgADCgUJBQAAAA==.',
['羊不']='羊不假:BAAALgAECgYJCQAAAA==.',
['聖鬥']='聖鬥释:BAAALgAECgcJAwAAAA==.',
['肉包']='肉包不信圣光:BAAALgAECgkJEAAAAA==.',
['胸毛']='胸毛入:BAAALgAECgQJBQAAAA==.',
['致命']='致命之剑丶:BAABLgAFFH8IAAIQAAMJ+BjoFwCpAAAQAAMJ+BjoFwCpAAAAAA==.',
['艾格']='艾格忟:BAABLgAECn8VAAIBAAYJbCDAYQAXAgABAAYJbCDAYQAXAgAAAA==.',
['芝华']='芝华士:BAAALgAECgkJCgAAAA==.',
['花木']='花木兰丶:BAABLgAFFH8GAAICAAIJjybrDQDoAAACAAIJjybrDQDoAAAAAA==.',
['芳砖']='芳砖叔:BAAALgAECgcJCwAAAA==.',
['苍蝇']='苍蝇坐飞机:BAAALgAFFAQJBAAAAA==.',
['荧惑']='荧惑之辉:BAAALgAECgYJEgAAAA==.',
['莫枫']='莫枫:BAAALgAECgkJDwAAAA==.',
['菟菟']='菟菟丶:BAAALgADCgMJAwAAAA==.',
['萌萌']='萌萌小米粒:BAAALgAECgYJBgABLgAFFAUJHgAUACEjAA==.',
['萨塔']='萨塔里安:BAAALgADCgcJDgAAAA==.',
['落叶']='落叶叹秋冷:BAAALgAECgQJBgAAAA==.',
['葡萄']='葡萄好吃吗:BAAALgAECgEJAQAAAA==.',
['蒂诺']='蒂诺丶戈尔贡:BAABLgAECn8WAAMVAAcJch+xCwB9AgAVAAcJER+xCwB9AgAOAAUJ/R7TMQB5AQAAAA==.',
['蓝烟']='蓝烟灰:BAAALgAECgYJCwAAAA==.',
['蕾拉']='蕾拉丶:BAAALgAECgYJBgAAAA==.',
['虾不']='虾不来虫:BAAALgAECgUJCAAAAA==.',
['蜗擦']='蜗擦灬你好牛:BAAALgAECgEJAQAAAA==.',
['裂人']='裂人:BAAALgAECgMJBgAAAA==.',
['襄铃']='襄铃:BAABLgAECn8aAAQWAAcJ8wwJIgBFAQAJAAcJgglYfgBeAQAWAAcJTQwJIgBFAQAXAAMJlQUHHwB4AAAAAA==.',
['西方']='西方辣椒:BAAALgAECgUJCAAAAA==.',
['西瓜']='西瓜两块一斤:BAAALgAECgYJAQAAAA==.',
['说出']='说出我的名字:BAAALgAECgYJCQAAAA==.',
['豆腐']='豆腐园子汤:BAABLgAFFH8FAAIYAAUJTxVjAQC0AQAYAAUJTxVjAQC0AQAAAA==.',
['豌豆']='豌豆颠颠:BAAALgAECgEJAQAAAA==.',
['负犬']='负犬墨汁丶:BAAALgAECgQJBAAAAA==.',
['赤脚']='赤脚大佬汉:BAAALgAECgQJBwAAAA==.',
['赤鬼']='赤鬼:BAABLgAFFH8HAAIBAAcJDRkZAQC2AgABAAcJDRkZAQC2AgAAAA==.',
['赫刄']='赫刄萝:BAAALgAECgcJDQAAAA==.',
['起司']='起司堡:BAAALgAECgYJDgAAAA==.起司面包:BAAALgAFFAEJAQAAAA==.',
['路下']='路下生笼粑:BAAALgAECgYJCQAAAA==.',
['躲丶']='躲丶猫猫:BAAALgAECgEJAgAAAA==.',
['躺倒']='躺倒之龙:BAAALgAECgQJBAAAAA==.',
['轩辕']='轩辕灬若龙:BAAALgAECgQJCAAAAA==.',
['软软']='软软的你:BAAALgAECgEJAQAAAA==.',
['辰伶']='辰伶之殇:BAAALgAECgYJCwAAAA==.',
['达芬']='达芬奇画鸡蛋:BAAALgADCgYJBQAAAA==.',
['道无']='道无量天尊:BAAALgADCgMJAwAAAA==.',
['邪恶']='邪恶章鱼哥:BAAALgAECgUJBQAAAA==.',
['醉知']='醉知己灬蜗牛:BAABLgAFFH8FAAIMAAMJcw14DwCpAAAMAAMJcw14DwCpAAAAAA==.',
['醉陵']='醉陵不作诗:BAAALgAECgIJAgAAAA==.',
['醒目']='醒目仔:BAAALgADCgQJBAAAAA==.',
['重生']='重生之战:BAAALgAECgYJCQAAAA==.',
['野德']='野德新之助:BAAALgAECgMJAwAAAA==.',
['銘丶']='銘丶秋風似水:BAAALgAECgEJAQAAAA==.',
['钢铁']='钢铁猛猛兽:BAAALgAECgEJAQAAAA==.',
['铂金']='铂金荣耀:BAAALgAECgUJBQAAAA==.',
['闲散']='闲散玩家丶:BAAALgAECgQJBQAAAA==.',
['阿不']='阿不思的落胤:BAAALgAECgkJBAAAAA==.',
['阿博']='阿博茨德:BAAALgAECgEJAgAAAA==.',
['阿尓']='阿尓萨斯:BAABLgAFFH8LAAIMAAYJ6Qi8CwBOAQAMAAYJ6Qi8CwBOAQAAAA==.',
['陸七']='陸七七:BAAALgADCgEJAQAAAA==.',
['雨雪']='雨雪纷飞:BAAALgAECgYJBgAAAA==.',
['雪尘']='雪尘映月:BAAALgADCggJCAAAAA==.',
['雪月']='雪月枫:BAAALgADCgcJCgAAAA==.',
['雪菲']='雪菲儿:BAAALgADCgIJAgAAAA==.',
['雪落']='雪落霜如玉:BAAALgADCgYJBgAAAA==.',
['霜悼']='霜悼者:BAAALgAECgQJBQAAAA==.',
['霸业']='霸业风暴:BAAALgAECgEJAQAAAA==.',
['霸王']='霸王别基:BAAALgAFFAIJAwAAAA==.',
['霹雳']='霹雳弦惊:BAAALgAECgQJBAAAAA==.',
['青椒']='青椒炒肉片:BAAALgAECgEJAQAAAA==.',
['青花']='青花:BAAALgAECgcJCAAAAA==.',
['靛烽']='靛烽绛:BAAALgADCgcJBwAAAA==.',
['韩圆']='韩圆圆:BAAALgAECgUJBgAAAA==.',
['风流']='风流剑:BAAALgAECgEJAQAAAA==.',
['骨头']='骨头是啊固:BAAALgAECgkJCAAAAA==.',
['高垣']='高垣枫:BAAALgADCgUJBQAAAA==.',
['高手']='高手:BAAALgADCggJCAAAAA==.',
['高登']='高登:BAAALgAECgIJBQAAAA==.',
['鬼伍']='鬼伍十柒:BAAALgAECgMJAwAAAA==.',
['鬼王']='鬼王达:BAAALgAFFAIJBAAAAA==.鬼王達:BAAALgAECgYJBgAAAA==.',
['麒麟']='麒麟的痕迹:BAABLgAECn8aAAIBAAYJaCFCaQAEAgABAAYJaCFCaQAEAgAAAA==.',
['黑暗']='黑暗的世界:BAAALgAECgYJBwAAAA==.',
['黯之']='黯之大胖:BAAALgAECgEJAQAAAA==.',
['黯姬']='黯姬黎娜:BAAALgADCgEJAQAAAA==.',
['齐格']='齐格隆:BAAALgAECgUJBQAAAA==.',
['龍傲']='龍傲天:BAAALgAECgQJBAAAAA==.',
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
