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
 local lookup = {'Mage-Fire','Warlock-Demonology','Warlock-Destruction','Mage-Frost','Monk-Brewmaster','Monk-Windwalker','DeathKnight-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Affliction','Unknown-Unknown','Warrior-Arms','Warrior-Fury','Warrior-Protection','Paladin-Holy','Shaman-Enhancement','Monk-Mistweaver','Druid-Balance','Shaman-Elemental','Shaman-Restoration','Priest-Discipline','Priest-Holy','Druid-Restoration','Druid-Guardian','Paladin-Retribution','Paladin-Protection',}; local provider = {region='CN',realm='末日祷告祭坛',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Andy:AwACCAIABRQAAA==.',Bi='Biteme:AwAECAYABRQCAQAEAQj0CwBDqQsBBRQAAQAEAQj0CwBDqQsBBRQAAA==.',Dr='Dreamsuperma:AwABCAEABRQAAA==.',Fa='Fallenstar:AwABCAEABRQAAA==.',Mo='Morphinee:AwAICAsABAoAAA==.',Pr='Prionailurus:AwAICAgABAoAAA==.',Sh='Shallowdream:AwACCAMABRQDAgAIAQgEBgBQUVgCBAoAAgAIAQgEBgBQUVgCBAoAAwABAQgbqwASChQABAoAAA==.Shiron:AwAICA0ABAoAAA==.',St='Strive:AwAHCAUABAoAAA==.',Wa='Warglaive:AwACCAQABRQAAA==.',['�']='一刀一咕咕:AwAECAQABRQAAA==.一只豆沙包灬:AwABCAEABAoAAA==.一恐菊花漏:AwAGCAMABAoAAA==.一茉星星一:AwAFCAEABAoAAA==.一锅烧肉:AwAHCAcABAoAAA==.三角初华:AwAICAkABAoAAA==.不干活的瘸子:AwABCAEABRQAAA==.丨天火丨:AwABCAEABRQAAA==.',['�']='云漓:AwAFCAUABAoAAA==.亦丶如歌:AwACCAYABRQCBAACAQiqCABIgbwABRQABAACAQiqCABIgbwABRQAAA==.亲灬爱灬的:AwABCAEABAoAAA==.',['�']='今宵别梦寒:AwACCAMABRQDBQAIAQitCAA57LgBBAoABQAIAQitCAA20bgBBAoABgAHAQh1JAA0D5ABBAoAAA==.',['�']='佛前一朵青莲:AwAECAYABAoAAA==.',['�']='冲天大宝剑:AwAECAQABAoAAA==.',['�']='凭负轻狂丶:AwAFCAUABAoAAA==.',['�']='划伤天空的泪:AwAICBYABAoCBwAIAQiCBQBNFFwCBAoABwAIAQiCBQBNFFwCBAoAAA==.别云涧:AwAICAgABAoAAA==.',['�']='加茂宪纪:AwACCAIABRQAAA==.',['�']='卑鄙的北鼻:AwAFCAUABAoAAA==.博文丶风行者:AwAECAYABRQDCAAEAQi+GAAikdMABRQACAAEAQi+GAAikdMABRQACQABAQjkGAAuyEcABRQAAA==.卡西莫哆:AwAECAQABRQAAQoANmYGCAYABRQ=.',['�']='叮咣凿:AwADCAEABAoAAA==.',['�']='咸鱼草莓:AwAECAEABRQAAA==.',['�']='喵哆哩:AwADCAIABRQAAA==.',['�']='图坦咔门:AwAFCAUABAoAAA==.',['�']='圆周率:AwADCAMABAoAAQsAAAADCAYABAo=.',['�']='坐观惊涛骇浪:AwAECAQABRQAAA==.坠茵落溷:AwADCAsABRQEDAADAQhTCgAgtKIABRQADAACAQhTCgAsJKIABRQADQACAQjDGAAYvJQABRQADgACAQgSCAAMU10ABRQAAA==.',['�']='士大夫机械:AwABCAEABRQAAA==.',['�']='小夜骑士:AwABCAIABRQCDwAIAQgvCABI8kUCBAoADwAIAQgvCABI8kUCBAoAAA==.尙丶小德:AwACCAIABRQCCAAIAQjGQQAvpcgBBAoACAAIAQjGQQAvpcgBBAoAARAARZsICAUABRQ=.',['�']='屠戮:AwAICBkABAoCDQAIAQhBEgBHq14CBAoADQAIAQhBEgBHq14CBAoAAQwAN/gGCAoABRQ=.',['�']='左端:AwABCAEABRQAAA==.',['�']='撒娇艳后:AwABCAEABAoAAA==.',['�']='教堂丶:AwAICAgABAoAAA==.',['�']='春俪:AwAECAQABRQAAA==.',['�']='暮生阿雷亚:AwAICAwABAoAAA==.',['�']='有我一口吃的:AwAECAkABRQDCQAEAQhPBgBRsfQABRQACAAEAQg2DwBEEf0ABRQACQADAQhPBgBCYfQABRQAAA==.有点逼术:AwAICA4ABAoAAA==.',['�']='杀部落:AwADCAYABAoAAA==.',['�']='水無月白:AwABCAEABRQCBgAIAQhQFQBEhBUCBAoABgAIAQhQFQBEhBUCBAoAAA==.',['�']='沙弓哒啰:AwACCAIABRQAAA==.',['�']='洛花听雨:AwACCAMABRQCEQAIAQglBgBalLoCBAoAEQAIAQglBgBalLoCBAoAAA==.',['�']='淋漓尽致丶:AwACCAEABRQAAA==.',['�']='满意大将军:AwAGCAYABAoAAA==.',['�']='火锅仙人:AwAGCAYABRQCEQAGAQgIAgAc6YoBBRQAEQAGAQgIAgAc6YoBBRQAAA==.',['�']='烫最靓的头:AwAECAQABRQAAA==.',['�']='牛哇:AwAECAUABRQCEgAEAQjMDwArc+YABRQAEgAEAQjMDwArc+YABRQAAQkAVdsICAgABRQ=.',['�']='玛格汉纯爷们:AwADCAIABAoAAA==.',['�']='男科故大夫:AwAHCAcABAoAAA==.',['�']='白铁氏族天使:AwAGCAYABAoAAA==.白铁氏族法爷:AwADCAUABRQCEwADAQgBAwBUexcBBRQAEwADAQgBAwBUexcBBRQAAA==.',['�']='硬核六十级:AwAGCA0ABAoAAA==.',['�']='笑笑小奶狸:AwAECAYABRQDEwAEAQg4BQBQ6vcABRQAEwAEAQg4BQBQ6vcABRQAFAACAQgAHgAWIH0ABRQAAA==.第九艺术:AwABCAEABRQAAA==.',['�']='紫羽精灵:AwACCAMABRQDFQAIAQgDEgBBlhUCBAoAFQAIAQgDEgBBdhUCBAoAFgAGAQiDSAAiZOcABAoAAA==.',['�']='肉蚌冲击:AwAECAQABRQAAA==.',['�']='花小惩:AwABCAEABRQAAA==.',['�']='草丛一只胖:AwAGCAgABRQDAQAEAQjcGAAdgNcABRQAAQADAQjcGAALrNcABRQABAACAQhyDgAtaIQABRQAAA==.',['�']='萌面凹凸曼:AwACCAQABRQCAQAGAQivKABZF/IBBAoAAQAGAQivKABZF/IBBAoAAA==.落笔成殇:AwAECAQABRQAAA==.',['�']='蔡需坤:AwAICAsABAoAAA==.',['�']='虚空丶彼岸花:AwAICAgABAoAAA==.虚空丶残星泪:AwAICAoABAoAAA==.虚空丶藏功名:AwACCAIABRQAAA==.',['�']='诗灬歌:AwACCAQABRQAAA==.诸葛高兴:AwAECAcABAoAAA==.',['�']='起始亦是终:AwAECAQABRQAAA==.',['�']='轻雨涟漪:AwACCAIABRQAAA==.',['�']='铁血狂小撸:AwABCAEABAoAAA==.',['�']='雾非雾花非花:AwACCAIABRQAAA==.',['�']='飞娥子:AwAECAIABRQAAA==.',['�']='鲨骑马:AwAFCAIABAoAAA==.',['�']='黑猩猩队长:AwABCAIABRQEEgAIAQhKIwBGVxMCBAoAEgAIAQhKIwBGVxMCBAoAFwAHAQgaNgAY/BYBBAoAGAABAQj9LQAUDxUABAoAAA==.',['�']='龍尛嗨:AwAICBQABAoDGQAIAQgFdAA0sIgBBAoAGQAGAQgFdAA8MIgBBAoAGgAGAQiGPQALDnMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end