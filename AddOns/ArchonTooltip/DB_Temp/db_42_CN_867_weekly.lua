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
 local lookup = {'Hunter-BeastMastery','Warrior-Fury','Shaman-Restoration','Shaman-Elemental','Shaman-Enhancement','Warlock-Demonology','Warlock-Destruction','DemonHunter-Havoc','DeathKnight-Blood','Warrior-Protection','Paladin-Retribution','Mage-Arcane','Mage-Frost','Evoker-Devastation','Evoker-Preservation','Paladin-Protection','Evoker-Augmentation','Priest-Holy','Priest-Discipline','Priest-Shadow','Hunter-Marksmanship','Warrior-Arms','DemonHunter-Vengeance','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Mage-Fire','Warlock-Affliction',}; local provider = {region='CN',realm='阿斯塔洛',name='CN',type='weekly',zone=42,date='2025-08-03',data={Eo='Eo:BAABKgAFFH8IAAIBAAQIkBjCLADUAAABAAQIkBjCLADUAAAAAA==.Eoii:BAAAKgAECgcICgAAAA==.Eooe:BAAAKgAFFAcIAwAAAA==.',La='Lanan:BAAAKgAECgUIBQAAAA==.',Mi='Misery:BAAAKgADCgQIBAAAAA==.',Zz='Zzsaki:BAAAKgADCgQIBAAAAA==.',['一楚']='一楚楚一:BAAAKgAECgEIAQAAAA==.',['一箭']='一箭终情:BAAAKgADCggIDwAAAA==.',['一锅']='一锅炖不下丶:BAAAKgADCgIIAgAAAA==.',['丁尛']='丁尛寧:BAAAKgAECgEIAQAAAA==.',['万叔']='万叔叔:BAABKgAFFH8GAAICAAYIyApAEQBCAQACAAYIyApAEQBCAQAAAA==.',['万小']='万小婉:BAAAKgAECggICAAAAA==.万小雨:BAAAKgAFFAIIAgAAAA==.',['下流']='下流的阿伯:BAAAKgADCgQIBAAAAA==.',['丨皮']='丨皮皮灬:BAACKgAFFH8QAAMDAAMIlw3RGgC3AAADAAMIlw3RGgC3AAAEAAEIVwERKwApAAAqAAQKfysABAMACAhJE380ALQBAAMACAhJE380ALQBAAUABwgjBX02ABEBAAQABQhNBYtZAJUAAAAA.',['丷霜']='丷霜無:BAAAKgADCgcIAgAAAA==.',['乌鲁']='乌鲁木齐:BAAAKgADCgQIBAAAAA==.',['五月']='五月丨:BAAAKgAECgMIBQAAAA==.',['伊夫']='伊夫利特之祭:BAACKgAFFH8GAAIGAAMIJgcNDACXAAAGAAMIJgcNDACXAAAqAAQKfxkAAwYACAgFF7EGAOUBAAYACAgFF7EGAOUBAAcABAgQCquSAGUAAAAA.',['你有']='你有牙线吗:BAABKgAFFH8GAAIIAAYIagqRHAAcAQAIAAYIagqRHAAcAQAAAA==.',['你艾']='你艾希我奶吗:BAAAKgAFFAQIBAABKgAFFAgICAAJAL0eAA==.',['倒反']='倒反天罡:BAACKgAFFH8QAAIKAAMIRwwdDgCPAAAKAAMIRwwdDgCPAAAqAAQKfykAAgoACAh2E9UWAI0BAAoACAh2E9UWAI0BAAAA.',['傲骨']='傲骨天生:BAAAKgAECgQIBAAAAA==.',['全能']='全能选手:BAACKgAFFH8lAAILAAUIwCAGIABwAQALAAUIwCAGIABwAQAqAAQKfxsAAgsACAjTIHVBACsCAAsACAjTIHVBACsCAAAA.',['冯晓']='冯晓明:BAAAKgAFFAMIAwAAAA==.',['冰蓝']='冰蓝椰奶慕斯:BAAAKgAECgQIBAAAAA==.',['凌晨']='凌晨:BAABKgAFFH8MAAMMAAgITRQnBgAzAgAMAAgITRQnBgAzAgANAAQINBaMFwC4AAAAAA==.',['减减']='减减丶:BAACKgAFFH8lAAMOAAYIdSTGCwCsAQAOAAUILCXGCwCsAQAPAAQIghRnAwDlAAAqAAQKfxQAAg4ACAisH08QAEsCAA4ACAisH08QAEsCAAAA.',['凯撒']='凯撒:BAABKgAECn8WAAMLAAYIURnLnwBYAQALAAYIURnLnwBYAQAQAAIIjw3PUgBNAAAAAA==.',['加尔']='加尔撸死:BAAAKgADCggIDwAAAA==.',['加拉']='加拉白垒:BAAAKgADCgMIAwAAAA==.',['千羽']='千羽:BAAAKgAFFAQIBAAAAA==.',['卓耿']='卓耿:BAACKgAFFH8lAAQOAAcI/BVGCgCtAQAOAAcI/BVGCgCtAQARAAIIGA0zAwBxAAAPAAII8gBOCAASAAAqAAQKfyIABA8ACAgVGcsIAPEBAA8ACAgVGcsIAPEBAA4ABQjwG1QXAAwBABEAAQifGL0PAEcAAAAA.',['咔咘']='咔咘踑诺:BAAAKgADCgIIAgAAAA==.',['唄儿']='唄儿:BAAAKgAECgQIBQAAAA==.',['囡囡']='囡囡丶:BAACKgAFFH8ZAAQSAAQI5yUOAgBGAQASAAQI5yUOAgBGAQATAAIIlh8xFQC2AAAUAAMI4Re0HQCZAAAqAAQKfycAAxIACAiGJkcDAN8CABIACAiGJkcDAN8CABMABgiIF4M3AD4BAAAA.',['土娃']='土娃:BAABKgAFFH8YAAMHAAYI2SI4AQDvAQAHAAYI2SI4AQDvAQAGAAUIBhyxBAArAQAAAA==.',['圣夜']='圣夜鹰:BAAAKgAECggICAAAAA==.',['壮牛']='壮牛水牛奶:BAAAKgAECgQIBQAAAA==.',['夏之']='夏之沫:BAAAKgAECgUICAAAAA==.',['夜无']='夜无晴:BAAAKgADCggICAAAAA==.',['大叔']='大叔:BAAAKgAFFAEIAQAAAA==.',['大师']='大师兄:BAAAKgAFFAIIAwAAAA==.',['大的']='大的一批:BAABKgAFFH8GAAICAAYIgw+/DgBoAQACAAYIgw+/DgBoAQAAAA==.',['太平']='太平郎:BAAAKgADCgEIAQAAAA==.',['她逼']='她逼我说咸的:BAABKgAFFH8IAAMBAAUI2RJSCABEAQABAAUICRFSCABEAQAVAAMIihDYEgDIAAAAAA==.',['好一']='好一朵娇花:BAABKgAFFH8MAAMWAAgI1hHQAgAvAgAWAAgI/BDQAgAvAgACAAQIBxHsEQDyAAAAAA==.',['宇文']='宇文数学:BAAAKgAECggICAAAAA==.',['安娜']='安娜普尔纳:BAAAKgAECgEIAQAAAA==.',['宝丶']='宝丶萨满:BAAAKgADCggICAAAAA==.',['小东']='小东西是你吗:BAAAKgAECgUIAwAAAA==.',['小啊']='小啊薇:BAAAKgAFFAEIAQAAAA==.',['小坑']='小坑坑:BAAAKgAFFAIIAQAAAA==.',['小杰']='小杰要变强:BAAAKgAFFAIIAgAAAA==.',['小狗']='小狗大王:BAAAKgAECggICwAAAA==.',['小鸡']='小鸡蒸蘑菇:BAABKgAFFH8GAAQSAAYIzRzcHQDTAAASAAII2CTcHQDTAAATAAMI1xQwGACfAAAUAAEIUxcoIgBTAAABKgAFFAgIBgAUAHQcAA==.',['心相']='心相印:BAAAKgAECgQIBAAAAA==.',['性别']='性别男爱好女:BAABKgAECn8gAAIFAAgIGhpkFwAQAgAFAAgIGhpkFwAQAgAAAA==.',['总是']='总是在混水:BAAAKgAECgMIAwAAAA==.',['成若']='成若:BAAAKgAECggICAAAAA==.',['我只']='我只说一次:BAABKgAFFH8RAAIXAAMI8ANRHgBqAAAXAAMI8ANRHgBqAAAAAA==.',['战五']='战五渣小阿丁:BAABKgAFFH8HAAMVAAQI6h0gBwAOAQAVAAMI6xwgBwAOAQABAAQI3R1jKADkAAAAAA==.',['扑天']='扑天雕:BAAAKgADCgEIAQAAAA==.',['抹茶']='抹茶白巧慕斯:BAAAKgAFFAQIBAAAAA==.',['撒旦']='撒旦之鞭:BAAAKgADCgEIAQAAAA==.',['放开']='放开那女女:BAAAKgAECgEIAQAAAA==.',['放肆']='放肆的黄瓜:BAAAKgAECgMIAwAAAA==.',['旋木']='旋木:BAAAKgAECgUIBgAAAA==.',['无上']='无上仙:BAAAKgAFFAEIAQAAAA==.',['无极']='无极剑神易:BAAAKgAECgMIAwAAAA==.',['无聊']='无聊的菊花:BAACKgAFFH8UAAIQAAMISglqDwCHAAAQAAMISglqDwCHAAAqAAQKfysAAxAACAhuDe8mAB4BABAACAg0De8mAB4BAAsAAQhRCxk4AS4AAAAA.',['暮色']='暮色兮凉城:BAAAKgAFFAMIAwAAAA==.',['未丶']='未丶:BAAAKgAFFAQIBAAAAA==.',['机智']='机智的阿狗铎:BAAAKgAFFAMIAQAAAA==.',['杨云']='杨云凡:BAAAKgAFFAgIBAAAAA==.',['梦开']='梦开始的地方:BAACKgAFFH8uAAMBAAYIlhQhGQAzAQABAAUINhEhGQAzAQAVAAQI5BaOFAC/AAAqAAQKfygAAwEACAhuIRwiAG0CAAEACAgWIBwiAG0CABUAAwjgIFtSAAcBAAAA.',['椰子']='椰子菜菜:BAAAKgAFFAQIBAAAAA==.',['水丿']='水丿水:BAAAKgADCgMIAwAAAA==.',['水乄']='水乄水:BAAAKgAECgIIAgAAAA==.',['氵未']='氵未:BAAAKgAFFAQIBAAAAA==.',['没遮']='没遮拦:BAAAKgADCgEIAgAAAA==.',['涅槃']='涅槃信诺:BAAAKgAECgEIAQAAAA==.',['潘嘟']='潘嘟嘟:BAABKgAECn8sAAQYAAgISRz2BQAhAgAYAAgISRz2BQAhAgAZAAcI+A1LMgAgAQAaAAUIywFwgwBSAAAAAA==.',['火野']='火野龍馬:BAAAKgADCgcIBwAAAA==.',['灬歡']='灬歡丨:BAAAKgAECggIDQAAAA==.',['灬阿']='灬阿德灬:BAABKgAFFH8FAAMVAAMI1hjPHQCDAAABAAIICxZ1NwCJAAAVAAMIuBTPHQCDAAAAAA==.',['灵魂']='灵魂燃烧:BAAAKgAFFAgIAgAAAA==.',['煌火']='煌火无明:BAAAKgAECgQIBAAAAA==.',['熊有']='熊有大智:BAAAKgAECggICAAAAA==.',['爱吃']='爱吃披萨:BAABKgAECn8pAAIDAAgISBWJFgCBAQADAAgISBWJFgCBAQAAAA==.',['牛二']='牛二:BAABKgAECn8YAAIDAAgI7B4wGgA3AgADAAgI7B4wGgA3AgAAAA==.',['猎光']='猎光光:BAAAKgAECgMIAwAAAA==.',['皮灬']='皮灬皮:BAABKgAFFH8IAAMFAAgItQ3/BQCeAQAFAAcIzQ3/BQCeAQADAAEI/A/mTgBKAAAAAA==.',['皮皮']='皮皮丶:BAAAKgADCgQIBAAAAA==.',['空间']='空间上看到你:BAAAKgAECgQIBAAAAA==.',['笑面']='笑面虎:BAAAKgADCgEIAgAAAA==.',['绿巨']='绿巨人之焚神:BAAAKgADCgEIAQAAAA==.',['胖乎']='胖乎乎:BAAAKgAECgUICQAAAA==.',['莫老']='莫老啊:BAAAKgADCggICAAAAA==.',['蓝桉']='蓝桉:BAACKgAFFH8OAAQNAAMIAxNCGAB1AAANAAII7RdCGAB1AAAMAAIIKgV1QQBPAAAbAAEIagVIQAA3AAAqAAQKfyYABA0ACAgLG6cmAOQBAA0ACAhoGqcmAOQBABsABwgXDxdRADcBAAwABQi6E4oeAKIAAAAA.',['被窝']='被窝里的射手:BAAAKgAECgUIBQAAAA==.',['西柚']='西柚佳得乐:BAAAKgAFFAYIBAAAAA==.',['西西']='西西里之风:BAAAKgAFFAQIBAAAAA==.',['费斯']='费斯莉:BAAAKgAFFAYIBAAAAA==.',['钢管']='钢管儿夺蜻蛙:BAAAKgAFFAEIAgAAAA==.',['铁头']='铁头娃:BAAAKgAECgMIAwAAAA==.',['铲开']='铲开心灵:BAACKgAFFH8eAAQHAAYI5RPTFADRAAAHAAQIvhfTFADRAAAcAAIISxIiFgCMAAAGAAMIYweLGwB4AAAqAAQKfx0ABAcACAgSGqksAMIBAAcABwgtG6ksAMIBAAYAAQhuE3B0AEQAABwABAh6B/JDADkAAAAA.',['阿戈']='阿戈瑞斯:BAAAKgAFFAIIBAAAAA==.',['陌熙']='陌熙:BAAAKgAECgcICwAAAA==.',['雷电']='雷电法王:BAAAKgAECggICAAAAA==.',['霸氣']='霸氣丨飛龍:BAABKgAFFH8NAAILAAgIlCXuAAAIAwALAAgIlCXuAAAIAwAAAA==.',['非洲']='非洲大酋长:BAAAKgAECgUIBQAAAA==.',['飞舞']='飞舞的雪花:BAAAKgAECggIDgAAAA==.',['龍王']='龍王爷搬家:BAABKgAFFH8HAAMMAAII2wskIgBvAAAMAAII2wskIgBvAAANAAIIgwQiKABTAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end