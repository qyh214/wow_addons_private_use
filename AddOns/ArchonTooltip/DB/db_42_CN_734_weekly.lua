local V2_TAG_NUMBER = 3

---Parse a single set of spec data from `state`
---@param decoder BitDecoder
---@param state ParseState
---@param lookup table<number, string>
---@return ProviderProfileSpec
local function parseSpecData(decoder, state, lookup)
	local result = {}
	result.spec = decoder.decodeString(state, lookup)
	result.progress = decoder.decodeInteger(state, 1)
	result.partition = decoder.decodeInteger(state, 1)
	result.total = decoder.decodeInteger(state, 1)
	result.rank = decoder.decodeInteger(state, 3)
	result.average = decoder.decodeFixedFloat(state, 1, 1)
	result.asp = decoder.decodeInteger(state, 2)
	result.difficulty = decoder.decodeInteger(state, 1)
	result.size = decoder.decodeInteger(state, 1)

	local encounterCount = decoder.decodeInteger(state, 1)
	result.encounters = {}
	for i = 1, encounterCount do
		local id = decoder.decodeInteger(state, 4)
		local kills = decoder.decodeInteger(state, 2)
		local best = decoder.decodeInteger(state, 1)

		result.encounters[id] = { kills = kills, best = best }
	end
	return result
end

---Parse a binary-encoded data string into a ProviderProfile
---@param decoder BitDecoder
---@param content string
---@param lookup table<number, string>
---@return ProviderProfile|nil
local function parse(decoder, content, lookup) -- luacheck: ignore 211
	---@type ParseState
	local state = { content = content, position = 1 }

	local tag = decoder.decodeInteger(state, 1)
	if tag ~= V2_TAG_NUMBER then
		return nil
	end

	local result = {}

	-- user data
	result.subscriber = decoder.decodeInteger(state, 1)
	-- overall data
	result.progress = decoder.decodeInteger(state, 1)
	result.total = decoder.decodeInteger(state, 1)
	result.totalKillCount = decoder.decodeInteger(state, 2)
	result.difficulty = decoder.decodeInteger(state, 1)
	result.size = decoder.decodeInteger(state, 1)
	result.perSpec = {}

	local specCount = decoder.decodeInteger(state, 1)
	if specCount > 0 then
		result.anySpec = parseSpecData(decoder, state, lookup)

		for _i = 1, specCount - 1 do
			local spec = parseSpecData(decoder, state, lookup)
			table.insert(result.perSpec, spec)
		end
	end

	local hasMainCharacter = decoder.decodeBoolean(state)

	if hasMainCharacter then
		local main = {}
		main.spec = decoder.decodeString(state, lookup)
		main.average = decoder.decodeFixedFloat(state, 1, 1)
		main.progress = decoder.decodeInteger(state, 1)
		main.total = decoder.decodeInteger(state, 1)
		main.totalKillCount = decoder.decodeInteger(state, 2)
		main.difficulty = decoder.decodeInteger(state, 1)
		main.size = decoder.decodeInteger(state, 1)
		result.mainCharacter = main
	end

	return result
end
 local lookup = {'Druid-Restoration','Mage-Fire','Priest-Discipline','Rogue-Assassination','Rogue-Subtlety','Hunter-BeastMastery','Warlock-Affliction','Paladin-Retribution','Paladin-Protection','Druid-Balance','Mage-Frost','Warrior-Fury','Warrior-Arms','Priest-Shadow','Monk-Windwalker','Warlock-Demonology','Priest-Holy','DemonHunter-Havoc','Hunter-Marksmanship','Hunter-Survival','DeathKnight-Blood','Unknown-Unknown','Paladin-Holy',}; local provider = {region='CN',realm='海达希亚',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ak='Akoe:AwACCAIABAoAAA==.',Al='Alcoho:AwAICAgABAoAAA==.',Cl='Cloudvzai:AwAECAgABRQCAQAEAQiaAQA+wVgBBRQAAQAEAQiaAQA+wVgBBRQAAA==.',De='Demomine:AwABCAEABRQAAA==.',Im='Imfiredup:AwAECAsABRQCAgAEAQjoCQBT8hkBBRQAAgAEAQjoCQBT8hkBBRQAAA==.',Iv='Ivanna:AwAFCA4ABRQCAwAFAQgsAwAyNjgBBRQAAwAFAQgsAwAyNjgBBRQAAA==.',Sa='Santamina:AwEICA0ABAoAAA==.',Vi='Vitruvius:AwAECA8ABRQDBAAEAQioAgBeYCoBBRQABQAEAQhtAgBXKysBBRQABAAEAQioAgBWbCoBBRQAAA==.',['�']='一句顶一万句:AwAICAgABAoAAQQAOhQGCAYABRQ=.一大主教一:AwAHCAcABAoAAA==.一粒丶仙丹:AwABCAEABRQAAA==.七宗罪一暴怒:AwABCAEABRQAAA==.三磷酸腺苷啊:AwAECAIABRQAAA==.不羡丶仙:AwAECAIABRQAAA==.丘比特之神射:AwAECA4ABRQCBgAEAQh1BAA4A0oBBRQABgAEAQh1BAA4A0oBBRQAAA==.丽桑德拉:AwAICAgABAoAAA==.',['�']='乂永恒乂:AwAECAYABAoAAA==.乱红飞过秋去:AwAECAYABAoAAQcAQvcGCAkABRQ=.',['�']='伊邪娜美:AwAGCA0ABAoAAA==.传承:AwAGCAYABAoAAA==.',['�']='冬青:AwABCAEABRQAAA==.',['�']='凌丶霜:AwAECAgABRQDCAAEAQjQDABHOw0BBRQACAAEAQjQDABHOw0BBRQACQAEAQiSCwAPCIEABRQAAA==.凤雅玲:AwADCAMABAoAAQoAPyMDCA4ABRQ=.',['�']='加里瑟斯:AwACCAgABRQCCAACAQiHJAAxYaMABRQACAACAQiHJAAxYaMABRQAAA==.',['�']='含笑凋零:AwADCAIABRQAAA==.',['�']='咏玖星花火:AwAICA0ABAoAAA==.咸鱼大作战:AwAFCAUABRQCAgAFAQhABQAy11QBBRQAAgAFAQhABQAy11QBBRQAAA==.',['�']='夏和小:AwAGCBwABRQCAwAGAQhLAABXKQ0CBRQAAwAGAQhLAABXKQ0CBRQAAA==.夜月刀歌:AwABCAIABRQAAA==.天一剑魔:AwAGCAYABAoAAA==.天选魔眼:AwAECAQABRQAAA==.',['�']='奇洛:AwABCAEABRQAAA==.',['�']='小猪存钱罐:AwAECAcABRQDCwAEAQhmAgBZIx4BBRQACwAEAQhmAgBUwB4BBRQAAgADAQhzEABSwPUABRQAAA==.小盐巴:AwADCAMABAoAAA==.',['�']='巨人:AwABCAEABRQAAA==.巫山不是云:AwAECAQABRQAAA==.巴布:AwAHCAcABAoAAA==.',['�']='弗里德曼:AwACCAQABRQCCAAIAQj7PwA+lQwCBAoACAAIAQj7PwA+lQwCBAoAAA==.',['�']='律法女娲:AwABCAEABRQAAA==.',['�']='我叫王宝强:AwACCAIABAoAAA==.',['�']='托尼大人:AwABCAIABRQCBgAIAQjQVQAq24IBBAoABgAIAQjQVQAq24IBBAoAAA==.',['�']='折丶戟:AwAECAQABRQDDAAIAQjXGgBQUR8CBAoADAAIAQjXGgBP6R8CBAoADQAGAQgeKgBFzisBBAoAAA==.',['�']='无相之月:AwAICA4ABAoAAA==.',['�']='是梦:AwAECAgABRQCDgAEAQi1BQBVnh8BBRQADgAEAQi1BQBVnh8BBRQAAA==.',['�']='暴走本子:AwACCAIABRQAAA==.',['�']='末日者行:AwAFCAQABAoAAA==.',['�']='杰克妹子:AwAECAQABRQCDwAIAQgtGwA6vd0BBAoADwAIAQgtGwA6vd0BBAoAAA==.',['�']='梅林疏芳:AwABCAEABAoAAA==.',['�']='槑小猎:AwADCAMABAoAAA==.',['�']='此髯故忧伤:AwAICAgABAoAAA==.',['�']='汤姆猫:AwADCAUABAoAAA==.',['�']='漂浮炸弾:AwADCA4ABRQCCgADAQh1DAA/I/UABRQACgADAQh1DAA/I/UABRQAAA==.漫天飞射:AwAICA0ABAoAAA==.',['�']='灵魂鬼火:AwABCAEABRQCEAAIAQitDAA4p/ABBAoAEAAIAQitDAA4p/ABBAoAAA==.',['�']='瑟莱德丝:AwAGCAYABAoAAA==.',['�']='瓦萨骑:AwAFCAMABAoAAA==.',['�']='电闪雷鸣:AwAECAQABAoAAA==.',['�']='神王宙斯:AwACCAUABRQCCAACAQhGMwAPtHQABRQACAACAQhGMwAPtHQABRQAAA==.',['�']='稀丶薄:AwAGCAYABAoAAA==.',['�']='笙落:AwAICAcABAoAAA==.',['�']='粿条超人:AwAICBAABAoAAA==.',['�']='紫色千幻:AwAFCAUABAoAAQoAQiQGCAoABRQ=.紫色幻箭:AwACCAIABRQAAA==.',['�']='纯丨真:AwAECAgABRQDAwAEAQgQBABbfygBBRQAAwAEAQgQBABbfygBBRQAEQAEAQjsBwAsmNwABRQAAA==.',['�']='缘翼比根:AwADCAkABRQCEgADAQgBFQAfs9QABRQAEgADAQgBFQAfs9QABRQAAA==.',['�']='肉蟹煲:AwAECAQABAoAAA==.',['�']='胖子打他:AwACCAIABRQAAA==.',['�']='花间未眠:AwAECAQABRQAAA==.芸梦飘雨:AwABCAEABRQDEwAIAQitEABGViACBAoAEwAIAQitEABGViACBAoAFAACAQgkGAAt3E4ABAoAAA==.',['�']='苏拉呢:AwACCAUABRQCBAACAQh3DAAsAJ4ABRQABAACAQh3DAAsAJ4ABRQAAQgAMWECCAgABRQ=.',['�']='萌萌哒:AwACCAIABRQAAA==.萝之一目:AwACCAEABRQCCwAIAQjcFwBBpyACBAoACwAIAQjcFwBBpyACBAoAAA==.',['�']='蓝瑟犹豫:AwAICBEABAoAAA==.',['�']='蔚然橙风:AwAGCAoABAoAARUAILwICAgABRQ=.',['�']='虚灵之刃丷:AwAICBoABAoCBAAIAQgCDwBQ2QcCBAoABAAIAQgCDwBQ2QcCBAoAAA==.',['�']='訷巠覀覀:AwAGCAkABRQCAgAGAQgoAwBFwp4BBRQAAgAGAQgoAwBFwp4BBRQAAA==.',['�']='讨厌:AwAGCBkABRQCDgAGAQhrAABOdgUCBRQADgAGAQhrAABOdgUCBRQAAA==.',['�']='迪尔梅林:AwADCAMABAoAAQoAPyMDCA4ABRQ=.迷乱耀阳:AwAGCAoABRQCDgAGAQinAQA2XagBBRQADgAGAQinAQA2XagBBRQAAA==.',['�']='阿瓦达啃大瓜:AwAHCAcABAoAAA==.',['�']='陪你去看星星:AwAHCA4ABAoAARYAAAABCAEABRQ=.',['�']='雨終晴天:AwAECAsABRQDFwAEAQgcAQAwlDkBBRQAFwAEAQgcAQAwlDkBBRQACAABAQhSPAAIc0YABRQAAA==.雲烟过眼:AwAFCAUABAoAAA==.零榆:AwACCAQABRQAAA==.',['�']='静葔椛开:AwAICAwABAoAAQcAQvcGCAkABRQ=.',['�']='风月不入眸:AwABCAEABRQAAA==.',['�']='鬼卿:AwACCAQABRQAAA==.',['�']='鲸落于海:AwAICAYABAoAAQIAOeQGCAYABRQ=.',['�']='黑索协奏曲:AwAFCAYABAoAAA==.',['�']='龍龖龘:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end