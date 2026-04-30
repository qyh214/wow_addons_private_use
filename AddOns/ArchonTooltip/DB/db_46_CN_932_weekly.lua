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

local lookup = {'Unknown-Unknown','Druid-Restoration','Warlock-Demonology','Mage-Frost','Monk-Mistweaver','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Druid-Balance','Paladin-Retribution','Priest-Holy','DeathKnight-Unholy','Warrior-Fury','Hunter-BeastMastery','DeathKnight-Blood',}
local provider = {region='CN',realm='塞纳留斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aeonight:BAAALgADCgQJBAAAAA==.',
Ar='Arthase:BAAALgAFFAIJAwABLgAFFAQJAQABAAAAAA==.',
Br='Brozhang:BAAALgAFFAEJAQAAAA==.',
Cl='Climacool:BAAALgAECgQJBQAAAA==.',
Da='Darkvampire:BAAALgADCgMJAwAAAA==.',
Fa='Fatepaul:BAAALgAECgEJAQAAAA==.',
Fe='Feiyuyi:BAAALgAECgcJAQAAAA==.',
Ko='Kolla:BAAALgADCgEJAQAAAA==.',
Le='Legends:BAAALgAECgcJCgAAAA==.',
Ma='Mayo:BAABLgAFFH8FAAICAAIJXR2gFQC2AAACAAIJXR2gFQC2AAAAAA==.',
Mi='Midnight:BAAALgADCgEJAQAAAA==.',
Ni='Nightmarejay:BAAALgAECgkJEgABLgAFFAcJBwADANgSAA==.',
Or='Ordeomh:BAAALgAECgEJAgAAAA==.',
Pl='Playerqwjsrd:BAAALgAECgEJAQAAAA==.',
Sh='Sharess:BAAALgADCgkJBgAAAA==.',
Wa='Wanda:BAABLgAECn8bAAIEAAgJ8QkzKABQAQAEAAgJ8QkzKABQAQAAAA==.',
Wz='Wzzyy:BAAALgAECgEJAQAAAA==.',
Yv='Yvonne:BAAALgADCgYJBwAAAA==.',
Ze='Zerogunner:BAAALgAFFAEJAQAAAA==.',
Zl='Zlzyhy:BAAALgADCgEJAQAAAA==.',
['一剑']='一剑霜寒:BAAALgAECgEJAQAAAA==.',
['不怪']='不怪她丶:BAAALgADCgUJBQAAAA==.',
['今天']='今天星期十:BAAALgAECgcJBwAAAA==.',
['仚屳']='仚屳屲冚:BAAALgAECgQJBQAAAA==.',
['修罗']='修罗紫衣:BAAALgAECgUJBQAAAA==.',
['傲笑']='傲笑灬紅尘:BAAALgAECgEJAQAAAA==.',
['光明']='光明流浪者:BAAALgADCgEJAQAAAA==.',
['再生']='再生丶:BAABLgAECn8WAAIFAAgJYRmQEwAwAgAFAAgJYRmQEwAwAgAAAA==.',
['再见']='再见孙悟空:BAAALgAECgIJAwAAAA==.',
['冻结']='冻结黎明:BAAALgAECgQJBAAAAA==.',
['凯瑟']='凯瑟琳泰勒:BAAALgADCgMJAwAAAA==.',
['努力']='努力奋斗:BAAALgAECgYJBgAAAA==.',
['千秋']='千秋真一:BAAALgAECgkJCQAAAA==.',
['午夜']='午夜丨圣光:BAAALgADCgcJBwAAAA==.',
['南风']='南风吹北巷:BAAALgADCgIJAgAAAA==.',
['去来']='去来自由:BAAALgAECgEJAQAAAA==.',
['叫我']='叫我大爺:BAAALgAECgQJBQAAAA==.',
['可乐']='可乐加辣椒:BAAALgAFFAMJAwAAAA==.',
['叶舞']='叶舞霜:BAAALgAECgQJBAAAAA==.',
['司徒']='司徒稥儿:BAAALgADCgcJDQAAAA==.司徒香儿:BAAALgAECgcJBwAAAA==.',
['吡吡']='吡吡:BAAALgAECgYJEAAAAA==.',
['和你']='和你没关系:BAAALgAECgUJCQAAAA==.',
['咕咕']='咕咕是一只猫:BAAALgAECgUJAwAAAA==.',
['咯噔']='咯噔:BAAALgAECgQJBQAAAA==.',
['哈基']='哈基米德:BAAALgAFFAMJAwAAAA==.',
['哔哔']='哔哔:BAAALgAFFAEJAQAAAA==.',
['四十']='四十二章京:BAAALgADCgYJBgAAAA==.',
['土拨']='土拨鼠护士:BAAALgAECgQJBAAAAA==.',
['圣光']='圣光牛牛:BAAALgAECgEJAQAAAA==.',
['圣塞']='圣塞勒斯汀:BAAALgAECgIJAgAAAA==.',
['圣的']='圣的力量:BAAALgAECgEJAQAAAA==.',
['均瑶']='均瑶牛奶:BAAALgAECgYJBgAAAA==.',
['坚硬']='坚硬巧酷力:BAAALgAFFAEJAQAAAA==.坚硬蘑菇头:BAAALgAECgkJCQAAAA==.',
['塔木']='塔木德:BAAALgAECgEJAQAAAA==.',
['塞纳']='塞纳摆摆:BAAALgAECgcJAQAAAA==.',
['墨無']='墨無訫:BAAALgAECgQJBAAAAA==.',
['墨色']='墨色轻纱:BAAALgAECgEJAQAAAA==.',
['夏灬']='夏灬天:BAAALgAECgEJAQAAAA==.',
['外卖']='外卖小哥:BAAALgAECgIJAwAAAA==.',
['多拉']='多拉贡:BAACLgAFFH8JAAMGAAMJLxp+BQC6AAAGAAIJbB9+BQC6AAAHAAIJnRHHGACfAAAuAAQKfxoABAYABwl4HxgFALACAAYABwl4HxgFALACAAcABAkvHO8yADMBAAgAAglUBlJCAFoAAAAA.',
['大侠']='大侠西北风:BAAALgAECgYJBgAAAA==.',
['天启']='天启随风:BAAALgAECgYJBwAAAA==.',
['天真']='天真的避风港:BAAALgAECgQJBAAAAA==.',
['奥黛']='奥黛丽缪斯:BAAALgADCgIJAgAAAA==.',
['如影']='如影之术:BAAALgAECgIJAgAAAA==.',
['姆丝']='姆丝加奥:BAAALgAECgEJAgABLgAFFAIJAgABAAAAAA==.',
['娜塔']='娜塔莎:BAAALgADCgIJAgAAAA==.',
['宇宙']='宇宙大帝:BAAALgAECgYJBgAAAA==.',
['宇文']='宇文浩劫:BAAALgAECgIJAQAAAA==.',
['将军']='将军白发:BAAALgADCgYJBgAAAA==.',
['小农']='小农棱:BAAALgAECgcJBwAAAA==.',
['小爱']='小爱苟萨:BAACLgAFFH8IAAIHAAQJ2ArZEgDoAAAHAAQJ2ArZEgDoAAAuAAQKfxcAAwcACAnCGmYPAIECAAcACAnCGmYPAIECAAYAAQnMCJVBAC0AAAAA.',
['小琑']='小琑儿:BAAALgAECgkJBAAAAA==.',
['小翻']='小翻小小:BAAALgAECgQJBAAAAA==.',
['小菊']='小菊头蝠:BAACLgAFFH8LAAIEAAQJQxapCgBeAQAEAAQJQxapCgBeAQAuAAQKfxcAAgQABgleJKNFAGcCAAQABgleJKNFAGcCAAAA.',
['小飒']='小飒雪:BAAALgAECgQJBgAAAA==.',
['库胖']='库胖:BAAALgAECgIJBAAAAA==.',
['开心']='开心丶泡泡:BAAALgAECgUJCQAAAA==.开心咕咕喵:BAAALgAECgEJAgAAAA==.开心哈籁尔:BAAALgAECgIJBQAAAA==.开心大领主:BAAALgAECgMJBgAAAA==.开心小宗师:BAAALgAECgEJAQAAAA==.开心旋律曲:BAAALgAECgEJAQAAAA==.',
['德鲁']='德鲁丨豆:BAAALgAECgUJBQAAAA==.',
['心随']='心随你动:BAAALgADCgEJAQAAAA==.',
['恶魔']='恶魔闹闹:BAAALgAECgYJCQAAAA==.',
['想要']='想要控制:BAAALgAECgYJCwAAAA==.',
['成龙']='成龙:BAAALgAECgQJBgAAAA==.',
['我是']='我是神圣牧师:BAAALgAECgIJAwAAAA==.',
['我要']='我要洋人死:BAAALgAECgkJCwAAAA==.',
['执筆']='执筆畵紅尘丶:BAAALgAECgEJBAAAAA==.',
['扯拐']='扯拐猫:BAAALgAECgUJBgAAAA==.',
['护夜']='护夜娜娜:BAAALgAECgQJBAAAAA==.',
['护法']='护法天尊:BAAALgAECgYJBwAAAA==.',
['摆摆']='摆摆更健康:BAAALgADCgYJBgAAAA==.',
['撸疯']='撸疯:BAAALgADCgEJAQAAAA==.',
['整治']='整治顽瘴痼疾:BAAALgADCgQJBAABLgAECgEJAQABAAAAAA==.',
['斩月']='斩月:BAAALgAECgMJAwAAAA==.',
['无忧']='无忧有律:BAAALgAFFAIJAgAAAA==.',
['无明']='无明逆流:BAAALgAECgQJBQAAAA==.',
['无言']='无言即言:BAAALgAFFAQJAgAAAA==.',
['时光']='时光丶聆听:BAACLgAFFH8JAAIJAAMJgBCoDgD2AAAJAAMJgBCoDgD2AAAuAAQKfxcAAwkABwkyG/YbACICAAkABwkyG/YbACICAAIAAglVAQ7XACoAAAAA.',
['昂剑']='昂剑:BAAALgAECgYJBgAAAA==.',
['月夜']='月夜独殇:BAAALgADCgEJAQAAAA==.',
['月影']='月影随形:BAAALgAECgEJAgAAAA==.',
['朱双']='朱双宝宝:BAAALgAECgcJCwAAAA==.',
['朱蒼']='朱蒼:BAAALgAECgYJBgAAAA==.',
['条条']='条条:BAAALgAFFAQJBAAAAA==.',
['来福']='来福二点零:BAAALgAECgcJCAAAAA==.',
['林二']='林二吆吆:BAACLgAFFH8MAAIKAAUJ2RGoBQCVAQAKAAUJ2RGoBQCVAQAuAAQKfx0AAgoACAljIOcZAM4CAAoACAljIOcZAM4CAAAA.',
['林语']='林语唐:BAAALgADCgcJBwAAAA==.',
['枪杰']='枪杰克:BAAALgAECgcJEgAAAA==.',
['梦伴']='梦伴:BAACLgAFFH8XAAIEAAYJ6SSYAQCRAgAEAAYJ6SSYAQCRAgAuAAQKfx4AAgQACAmAJX4OAFMDAAQACAmAJX4OAFMDAAEuAAUUCAkaAAQAfCYA.',
['楓訫']='楓訫標簽:BAAALgADCgYJBgAAAA==.',
['欢腾']='欢腾居士:BAAALgADCgIJAgAAAA==.欢腾萨:BAAALgADCgUJBwAAAA==.',
['死骑']='死骑闹闹:BAAALgAECgMJAwAAAA==.',
['水盼']='水盼兰晴:BAAALgADCgYJBgAAAA==.',
['水若']='水若兮:BAAALgADCgUJBwABLgADCgYJBgABAAAAAA==.',
['沙娜']='沙娜亿:BAAALgADCgYJBgAAAA==.',
['流星']='流星陨落:BAAALgAFFAIJAwAAAA==.',
['游叁']='游叁念:BAAALgAECgcJBwAAAA==.',
['湿滑']='湿滑巧酷力:BAAALgAFFAMJAwAAAA==.',
['炽天']='炽天使的吟唱:BAAALgAECgQJBAAAAA==.',
['熊喵']='熊喵人:BAAALgAFFAIJAgAAAA==.',
['爱上']='爱上猫地鱼:BAAALgAECgEJAQAAAA==.',
['片片']='片片血宁静:BAAALgAECgMJCAAAAA==.片片血灵灵:BAAALgAECgMJAQAAAA==.',
['狂磨']='狂磨天使:BAAALgAECgEJAgAAAA==.',
['猫猫']='猫猫爱唱歌:BAACLgAFFH8JAAILAAMJaSOkBAA8AQALAAMJaSOkBAA8AQAuAAQKfxgAAgsABwnoJKYGAOQCAAsABwnoJKYGAOQCAAAA.',
['玄学']='玄学不救非酋:BAAALgAFFAEJAQAAAA==.',
['琉璃']='琉璃眸娃娃:BAAALgAECgQJBQAAAA==.',
['瑟琳']='瑟琳娜:BAAALgAECgIJAgAAAA==.',
['生生']='生生所资:BAAALgAECgEJAQAAAA==.',
['甲贺']='甲贺忍:BAAALgAECgQJBAAAAA==.',
['电疗']='电疗一下:BAAALgADCgcJBwABLgAFFAMJCQAJAIAQAA==.',
['盛大']='盛大登场:BAAALgAECgEJAQAAAA==.',
['目中']='目中无人:BAAALgAECgkJCQAAAA==.',
['看我']='看我七十二变:BAABLgAECn8UAAICAAgJoiMHCQAAAwACAAgJoiMHCQAAAwABLgAFFAYJDgACAKceAA==.',
['真实']='真实伤害:BAAALgADCgUJBgAAAA==.',
['禁止']='禁止投喂:BAAALgAECgIJAwAAAA==.',
['简单']='简单点:BAAALgAECgUJCAAAAA==.',
['米思']='米思兰迪:BAAALgADCgUJCAAAAA==.',
['米祺']='米祺:BAAALgAECgQJBAAAAA==.',
['粒粒']='粒粒皆辛苦:BAAALgADCggJCAABLgAFFAYJFgAMAMUiAA==.',
['索尼']='索尼:BAAALgADCgEJAQAAAA==.',
['紫眉']='紫眉毛:BAAALgADCgIJAgABLgAECgEJAQABAAAAAA==.',
['紫龙']='紫龙闹闹:BAAALgAECgYJBgAAAA==.',
['红烧']='红烧大咕咕:BAAALgADCgUJBQAAAA==.',
['终焉']='终焉萨萨:BAAALgAECgQJBAAAAA==.',
['缘筱']='缘筱天:BAAALgADCgQJBAAAAA==.',
['老骨']='老骨头:BAAALgAECgYJDgAAAA==.',
['肤白']='肤白大波浪:BAABLgAECn8YAAIEAAgJdBUtGgCYAQAEAAgJdBUtGgCYAQAAAA==.',
['能不']='能不能长点心:BAAALgAECgYJCgAAAA==.',
['艾席']='艾席拉的弯刀:BAAALgADCgYJCAAAAA==.',
['花常']='花常在:BAAALgADCgQJBAAAAA==.',
['荷鲁']='荷鲁斯:BAAALgAECgEJAQAAAA==.',
['莱耶']='莱耶斯:BAAALgAECgYJCAAAAA==.',
['菜刀']='菜刀火车侠:BAABLgAECn8UAAINAAcJsxfpJgAkAgANAAcJsxfpJgAkAgAAAA==.',
['萨满']='萨满闹闹:BAAALgAECgMJAwAAAA==.',
['葛温']='葛温德林:BAAALgAECgQJCwAAAA==.',
['薄荷']='薄荷糖微凉:BAAALgAECgQJBAAAAA==.',
['虚空']='虚空:BAAALgADCgUJBQAAAA==.',
['蝴蝶']='蝴蝶兰:BAAALgAECgYJBwAAAA==.',
['血舞']='血舞蝶殇:BAAALgAECgQJBAAAAA==.',
['让我']='让我康康:BAAALgAECgQJBAAAAA==.',
['谓我']='谓我何求:BAAALgADCgEJAQAAAA==.',
['賈薾']='賈薾震撼源:BAAALgAFFAIJAgAAAA==.',
['贺兰']='贺兰豆:BAABLgAECn8YAAIKAAcJ1yDnMQBbAgAKAAcJ1yDnMQBbAgAAAA==.',
['逃命']='逃命专家:BAAALgAECgEJAwAAAA==.',
['逆行']='逆行天下贰号:BAAALgAECgYJCAAAAA==.',
['那边']='那边的狼人:BAABLgAECn8WAAIOAAkJ6whELwD0AQAOAAkJ6whELwD0AQAAAA==.',
['邪恶']='邪恶四炎:BAAALgAECgUJBwAAAA==.',
['郝思']='郝思嘉嘉:BAAALgAECgQJBAAAAA==.',
['金灯']='金灯剑客:BAAALgAECgQJBAAAAA==.',
['铁锅']='铁锅炖大鹅:BAAALgAECgEJAQAAAA==.',
['铠冢']='铠冢霙:BAACLgAFFH8GAAIEAAMJuw08GQD4AAAEAAMJuw08GQD4AAAuAAQKfxQAAgQABgnTH5VuAPcBAAQABgnTH5VuAPcBAAAA.',
['长点']='长点心吧:BAAALgAECgUJBwAAAA==.',
['阴阳']='阴阳摆渡:BAAALgAECggJCQABLgAFFAUJBQAPAKgLAA==.',
['阿宝']='阿宝:BAAALgAECgYJBgAAAA==.',
['阿布']='阿布霍斯:BAAALgAECgIJAgAAAA==.',
['随意']='随意猎:BAAALgAECgQJBQAAAA==.',
['雄魄']='雄魄:BAAALgADCgUJBQAAAA==.',
['雪丨']='雪丨吻:BAAALgADCgEJAQAAAA==.',
['雪乂']='雪乂吻:BAAALgAECgUJBQAAAA==.',
['震荡']='震荡波:BAAALgAECgEJAQAAAA==.',
['静香']='静香:BAAALgAECgQJBAAAAA==.',
['风暴']='风暴之怒:BAAALgAECgQJBQAAAA==.',
['风起']='风起沧海:BAAALgADCgEJAQAAAA==.',
['首席']='首席骑士:BAAALgADCgYJBgAAAA==.',
['香甜']='香甜巧酷力:BAAALgAECgkJCQAAAA==.',
['魅鱼']='魅鱼:BAAALgAFFAEJAQAAAA==.',
['魔法']='魔法闹闹:BAAALgAECgcJCAAAAA==.',
['魔物']='魔物獵人:BAAALgADCgYJBgAAAA==.',
['麝香']='麝香葡萄:BAAALgAFFAIJAgAAAA==.',
['黄胖']='黄胖恶魔之子:BAAALgADCgUJBQAAAA==.黄胖胖的小德:BAAALgAECgEJAQAAAA==.黄胖胖的战士:BAAALgAECgUJBQAAAA==.黄胖胖的术士:BAAALgAECgQJBAAAAA==.黄胖胖的猎人:BAAALgAECgYJBQAAAA==.',
['黑暗']='黑暗之门:BAAALgADCgIJAgAAAA==.',
['黛绮']='黛绮丝:BAAALgAECgEJAQAAAA==.',
['龙鱼']='龙鱼:BAAALgAFFAIJAwAAAA==.',
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
