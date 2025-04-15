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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Warrior-Fury','Warrior-Arms','Shaman-Elemental','Paladin-Protection','Mage-Fire','Mage-Frost','Evoker-Devastation','Evoker-Preservation','Monk-Windwalker','Druid-Balance','DemonHunter-Havoc','Druid-Restoration','DeathKnight-Unholy','Warlock-Affliction','Druid-Guardian','Priest-Holy','Priest-Shadow','Shaman-Restoration','Paladin-Retribution','Priest-Discipline',}; local provider = {region='CN',realm='哈卡',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Ashkandi:AwAICAgABAoAAA==.',Au='Au:AwAECAcABRQDAQAEAQjdBQBTNRMBBRQAAQADAQjdBQBTNRMBBRQAAgABAQg1FwAAAAAABRQAAA==.Autocad:AwAHCAUABAoAAQMAAAAECAMABRQ=.',Gr='Grimclérigo:AwAICA4ABAoAAA==.',Il='Illustrator:AwACCAYABRQCBAACAQhsEwAkf3sABRQABAACAQhsEwAkf3sABRQAAQUAR6MICAoABRQ=.',La='Lastslayer:AwAICAgABAoAAA==.',Me='Mediocreman:AwABCAEABRQAAA==.',Mi='Michealia:AwABCAEABRQAAA==.',Mo='Monte:AwAECAgABRQCBgAEAQgrDwAYqOUABRQABgAEAQgrDwAYqOUABRQAAQcAN/gGCAoABRQ=.',Pa='Paradisekiss:AwAECAQABAoAAA==.',Qw='Qwert:AwAECAQABRQAAA==.',Ra='Raúl:AwAICAgABAoAAA==.',Ru='Ruigo:AwAECAQABRQAAA==.',Sk='Sketchup:AwACCAQABRQAAQMAAAAECAMABRQ=.',St='Stephentrial:AwAICA4ABAoAAA==.',Sx='Sxdtlw:AwACCAUABRQCBAACAQgOEwAaT34ABRQABAACAQgOEwAaT34ABRQAAA==.',Ul='Ultrasdalian:AwAICAgABAoAAQgAVZkICAIABRQ=.',Zp='Zpr:AwACCAIABRQAAA==.',['�']='一闪靓一:AwACCAUABRQCCQACAQgADwAKtFYABRQACQACAQgADwAKtFYABRQAAA==.三德子:AwAECAMABAoAAA==.丨逐星丨丨:AwAGCA0ABAoAAQMAAAABCAIABRQ=.',['�']='五十六:AwAICAgABAoAAA==.',['�']='传说中的奶骑:AwAICA4ABAoAAA==.',['�']='兔酱:AwACCAIABRQAAA==.',['�']='冰激凌奶茶:AwAGCAQABAoAAA==.',['�']='凌霄:AwAECAQABRQAAA==.',['�']='别西卜:AwAFCAQABAoAAA==.',['�']='化身巨熊:AwAECAQABRQAAA==.',['�']='卖饼的阿花:AwADCAQABRQDCgAIAQhKEQBSNoICBAoACgAIAQhKEQBSNoICBAoACwADAQgqdQAytYQABAoAAA==.',['�']='右手的情诗:AwAICAgABAoAAA==.',['�']='唉你欠骂:AwAGCAkABRQDDAAFAQisBQAzngwBBRQADAAEAQisBQA/LwwBBRQADQADAQj4AQBHaPAABRQAAA==.',['�']='喵薄荷:AwAGCAYABAoAAA==.',['�']='塑料娃娃:AwABCAEABRQAAA==.',['�']='大帝雷德:AwABCAMABRQCDgAIAQhLGwA7R9wBBAoADgAIAQhLGwA7R9wBBAoAAA==.大彪哥哥啊:AwAECAQABRQAAA==.大米职业选手:AwADCAMABRQAAA==.失落伊甸园:AwACCAQABRQDBwAIAQjxEgBTS/oBBAoABwAFAQjxEgBXb/oBBAoABgAHAQiwKgA7DMABBAoAAA==.',['�']='好风凭借力:AwAICAgABAoAAA==.',['�']='姬狐丨庇韄:AwADCAUABRQCDwADAQhPGwAHjJoABRQADwADAQhPGwAHjJoABRQAAA==.',['�']='孤浪大魔王:AwAHCAsABAoAAA==.',['�']='小城大事:AwAICAgABAoAAA==.小椰奶:AwAECAMABRQAAA==.小椰子:AwAICAgABAoAAA==.',['�']='布吉盗:AwAHCAsABAoAAA==.帆婷淇宝宝:AwACCAcABRQCEAACAQgjHwAlrI0ABRQAEAACAQgjHwAlrI0ABRQAAA==.',['�']='开心鱼腩煲:AwAECAIABRQAAA==.',['�']='微光炼狱骑士:AwAECAQABRQAAA==.',['�']='心里有术:AwACCAIABRQAAA==.',['�']='性感母蟑螂丶:AwAGCAcABAoAAA==.',['�']='悠悠麦:AwAICAoABAoAAA==.',['�']='我叫色牛:AwAECAEABRQCEQABAQg9GwAgjzgABRQAEQABAQg9GwAgjzgABRQAAA==.我将点燃星海:AwAICAgABAoAAA==.我还能撑住:AwAICAgABAoAAA==.戒律闪电喵:AwAGCAQABRQAAA==.',['�']='手一挥死一堆:AwAGCAYABAoAAA==.',['�']='接着忽悠:AwAGCAYABAoAAA==.',['�']='收手吧丿阿祖:AwACCAMABRQAAA==.放开那只羊:AwAGCAUABAoAAA==.放羊的老狼:AwACCAEABAoAAA==.',['�']='旺旺大魔神:AwAHCAcABAoAARIASVsFCAUABRQ=.',['�']='昏睡:AwACCAIABRQAAQgAVZkICAIABRQ=.',['�']='晓星尘:AwABCAEABRQAAA==.',['�']='月落丶冬至:AwAECAQABRQAAQMAAAAICAQABRQ=.月落丶圣堂:AwAECAQABRQAAA==.',['�']='李四:AwAECAQABRQAARMAQ1cGCAYABRQ=.杖一挥骨一堆:AwAICAgABAoAAA==.杨二正:AwACCAUABRQCBgACAQjeFQA1EqUABRQABgACAQjeFQA1EqUABRQAAA==.',['�']='林小溪:AwACCAIABRQAAQMAAAAECAQABRQ=.',['�']='欢乐天神:AwAECAgABRQDDwAEAQisBgBGzBkBBRQADwAEAQisBgBGzBkBBRQAEQADAQi6DwAw34IABRQAAQMAAAAGCAIABRQ=.欢喜糖糖:AwAHCAgABAoAAA==.欧泡欧泡:AwAICAgABAoAAA==.',['�']='沙漠萌妹:AwAECAsABRQCBQAEAQhpDwBC+PwABRQABQAEAQhpDwBC+PwABRQAAQMAAAAICAQABRQ=.没有愛的季節:AwAECAYABRQCCwAEAQiDCAAcX78ABRQACwAEAQiDCAAcX78ABRQAAA==.',['�']='潜水员伊鲁米:AwAICAgABAoAAA==.',['�']='灭世魔眼:AwAICAgABAoAAA==.',['�']='焚河:AwACCAEABRQAAA==.',['�']='熊瞎额丨:AwAICA4ABAoAAA==.',['�']='牛轉乾坤:AwAGCAYABAoAAQMAAAAICAgABAo=.',['�']='独猎:AwAICAgABAoAAA==.',['�']='玛德法科:AwAGCAYABAoAAA==.',['�']='田师傅:AwACCAUABRQEDwAIAQiXKwBCXeIBBAoADwAHAQiXKwBHeOIBBAoAEQAIAQhVHgAxHKoBBAoAFAABAQgcJwAreTEABAoAAA==.',['�']='疯狂小恶鸡:AwAECAIABRQAAA==.',['�']='真理所在:AwACCAQABRQAAA==.',['�']='硬梆梆的我:AwADCAgABRQCEgADAQiMAgBe90YBBRQAEgADAQiMAgBe90YBBRQAAA==.',['�']='神小修墨:AwAGCA4ABAoAAA==.神小雨:AwABCAIABRQDFQAIAQiTHwA8JrcBBAoAFQAIAQiTHwA8JrcBBAoAFgAHAQhYIwAxnpQBBAoAAA==.神里绫华:AwAHCA0ABAoAAA==.',['�']='罗大佑丶:AwADCAMABAoAAA==.',['�']='老董:AwAGCA4ABRQCEAAGAQg7AABhPkECBRQAEAAGAQg7AABhPkECBRQAAA==.',['�']='肆海凉生欢:AwAGCAEABAoAAA==.',['�']='苍冥孤心:AwAECAMABRQAAQMAAAAGCAIABRQ=.',['�']='萨斯避雷:AwAECAYABRQDCAAEAQgrBQA+fPcABRQACAADAQgrBQA+fPcABRQAFwABAQhsLQAAAAAABRQAAA==.',['�']='董老师:AwAICAgABAoAAA==.',['�']='蓝巧蓝莓慕斯:AwADCAIABAoAAQoAJ70GCAoABRQ=.',['�']='虎皮鹦鹉:AwAICB4ABAoCGAAIAQjPBgBgdfgCBAoAGAAIAQjPBgBgdfgCBAoAAA==.',['�']='血月狂人:AwADCAIABAoAAA==.血色残锋:AwACCAIABRQAAA==.',['�']='豪玖邀明月:AwAECAQABAoAAA==.',['�']='软绵绵的我:AwABCAEABRQAAA==.',['�']='辣神:AwAECAQABRQAARgAS6QGCAoABRQ=.',['�']='还是费电:AwABCAEABRQAAA==.',['�']='逐星丨:AwAECAMABAoAAQMAAAABCAIABRQ=.逐星猎丶:AwABCAIABRQAAA==.',['�']='野蛮艺术:AwAICBAABAoAAA==.',['�']='铁锅炖自己:AwAECAIABRQAAA==.',['�']='闪电喵变身:AwAECAgABRQCDwAEAQjYBABYASoBBRQADwAEAQjYBABYASoBBRQAAA==.问风:AwACCAIABRQAAA==.',['�']='阿丽塔:AwADCAMABAoAAA==.',['�']='陌下浅眠:AwABCAEABAoAAA==.',['�']='随丨水寒:AwAGCAYABRQDGQAGAQisDwAVE68ABRQAGQACAQisDwAX7a8ABRQAFgAEAQhSEQALb6wABRQAAA==.',['�']='青鸾:AwAGCA4ABAoAAA==.',['�']='风暴之主:AwACCAIABRQAARkANGIGCAcABRQ=.',['�']='鹏程无限:AwAFCAUABAoAAA==.',['�']='龙二:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end