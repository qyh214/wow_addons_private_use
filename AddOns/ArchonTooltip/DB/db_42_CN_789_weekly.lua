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
 local lookup = {'Warrior-Arms','Paladin-Retribution','Monk-Mistweaver','Mage-Frost','Mage-Fire','Warlock-Destruction','Priest-Discipline','Shaman-Elemental','Druid-Restoration','Warrior-Fury','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Druid-Balance','Shaman-Restoration','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Frost','Druid-Guardian','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Priest-Shadow',}; local provider = {region='CN',realm='织亡者',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Along:AwAECAQABAoAAA==.',Ar='Aris:AwAICBIABAoAAQEAN/gGCAoABRQ=.',El='Elitaeca:AwAICBoABAoCAgAIAQg0DABdCd8CBAoAAgAIAQg0DABdCd8CBAoAAA==.',Fa='Fattytuna:AwAECAQABRQCAwAEAQhbEwAPQcIABRQAAwAEAQhbEwAPQcIABRQAAA==.',Ic='Icywind:AwAECAYABRQDBAAEAQhqCAArbtMABRQABAAEAQhqCAArbtMABRQABQACAQjQLQAbJXIABRQAAA==.',Jo='Joker:AwAICBoABAoCBgAIAQjlEgBIrkkCBAoABgAIAQjlEgBIrkkCBAoAAA==.',Lu='Luckyxing:AwAFCAcABAoAAA==.',St='Strelitzia:AwAECAYABRQCBwAEAQjdBgBBWQwBBRQABwAEAQjdBgBBWQwBBRQAAA==.',Th='Theworld:AwAICAQABAoAAA==.',To='Tot:AwAECAgABRQCCAAEAQgsCAAyk+AABRQACAAEAQgsCAAyk+AABRQAAQkAOkwGCAUABRQ=.Toxwind:AwAECAYABRQCCgAEAQhRCgBMbQgBBRQACgAEAQhRCgBMbQgBBRQAAQoAN1IICAkABRQ=.',Ve='Venom:AwAECAYABRQDCwAEAQiXBQBMewUBBRQACwAEAQiXBQBHhgUBBRQADAACAQiHDAAtk40ABRQAAA==.',Vi='Viento:AwAECAYABRQCDQAEAQgnGAAekssABRQADQAEAQgnGAAekssABRQAAA==.',Wi='Windflower:AwAECAQABRQAAA==.',Xo='Xoo:AwAECAQABRQCDgAEAQhgEAA4hesABRQADgAEAQhgEAA4hesABRQAAA==.',['�']='丶颜颜丶:AwAGCAgABAoAAA==.',['�']='倾颜笑:AwAICAgABAoAAA==.',['�']='元素诅咒:AwAECAQABAoAAA==.',['�']='冰冷的骑士:AwADCAEABAoAAA==.',['�']='十二月的猫猫:AwABCAIABRQAAA==.',['�']='又挨骂咯:AwAICAEABAoCDwABAQjXrAAa3S8ABAoADwABAQjXrAAa3S8ABAoAARAAAAAICAIABRQ=.',['�']='吱毛:AwACCAIABAoAAA==.',['�']='哇传说:AwAECAoABRQCDwAEAQhyBgBULBUBBRQADwAEAQhyBgBULBUBBRQAAA==.',['�']='喊我去睡觉:AwAICAgABAoAAA==.',['�']='圣旺旺:AwABCAEABRQAAA==.地精萨满:AwABCAEABRQAAA==.',['�']='坤哥:AwACCAUABRQCEQACAQhtGwAkuZAABRQAEQACAQhtGwAkuZAABRQAAA==.',['�']='基督山伯爵:AwAGCAoABAoAAA==.',['�']='夜的第七章丶:AwABCAEABAoAAA==.大雨过后:AwABCAIABRQAAA==.',['�']='小小神:AwAECAQABRQAAA==.小毛毛熊:AwADCAMABAoAAA==.小病人丶:AwAICBAABAoAAA==.小舅:AwAFCAoABAoAAA==.',['�']='巴洛斯:AwAGCAsABAoAAA==.',['�']='市井小贼:AwAICAgABAoAAA==.带我去流浪:AwADCAMABAoAAA==.',['�']='张能能:AwAECAQABAoAAA==.',['�']='往佑走打怪兽:AwAICBYABAoCEgAIAQhUDgAjjZIBBAoAEgAIAQhUDgAjjZIBBAoAAA==.',['�']='怒风丶左耳:AwADCAcABRQECQADAQjrCwAWpLUABRQACQADAQjrCwAWpLUABRQADgACAQgsIAAmUpAABRQAEwABAQj7BQAsLjEABRQAAA==.怵歪:AwAECAgABAoAAA==.',['�']='愿圣光照死你:AwAFCAcABAoAAA==.',['�']='搞不懂吧:AwADCAIABAoAAA==.',['�']='无敌嘉宝:AwAFCAcABAoAAA==.',['�']='晨舸:AwAECAQABAoAAA==.',['�']='暴力的美学:AwAGCAwABAoAAA==.',['�']='最后的磐石:AwAICAoABAoAAA==.',['�']='枫叶:AwAICBMABAoAAA==.',['�']='柳如烟丶:AwADCAMABAoAAA==.',['�']='死灵战骑:AwAICA8ABAoAAA==.',['�']='法誓:AwABCAEABRQAAA==.泰瑞利亚:AwADCAIABAoAAA==.',['�']='深丶蓝:AwAICAEABAoAAA==.',['�']='清风之浩泽:AwAHCAwABAoAAA==.清风之铭浩:AwADCAMABAoAAA==.',['�']='痞子锋:AwABCAEABRQAAA==.',['�']='白菜的驯兽思:AwAICBYABAoDFAAIAQg9VQApa5EBBAoAFAAIAQg9VQApa5EBBAoAFQABAQhtfAATOx0ABAoAAA==.',['�']='盾白菜:AwACCAUABAoAAA==.',['�']='真谛:AwAECAQABRQAAA==.',['�']='祭灬祀:AwAGCAoABAoAAA==.',['�']='糖果屋的幽灵:AwAECAIABRQCBwACAQhlGQAddn4ABRQABwACAQhlGQAddn4ABRQAAA==.',['�']='紫旺旺:AwAFCA0ABAoAAA==.',['�']='纏綿丶丶:AwAFCAUABAoAAA==.',['�']='给你一瓶可乐:AwAECAcABRQDFQAEAQgkBQBG5wcBBRQAFQAEAQgkBQBG5wcBBRQAFAADAQhjMAAyCn8ABRQAARYAPuAGCAcABRQ=.',['�']='耕不死的牛:AwAICBAABAoAAA==.',['�']='胖胖小盼:AwABCAEABRQAAA==.',['�']='花间酒:AwAECAEABAoAAA==.',['�']='英语龙:AwAFCAUABAoAAQ8AVCwECAoABRQ=.',['�']='蕉太狼:AwABCAEABRQAAA==.蕉太狼二号:AwABCAEABRQAAA==.',['�']='贝拉:AwAHCAcABAoAAA==.',['�']='达闻稀:AwAGCAYABAoAAA==.',['�']='退堂鼓大王:AwAICAoABAoAAA==.速度射掉:AwADCAMABAoAAA==.',['�']='那瓜那潴那鳖:AwAICBYABAoCDwAIAQisOAAtloMBBAoADwAIAQisOAAtloMBBAoAAA==.',['�']='随风的细尘:AwADCAMABRQAAA==.',['�']='雨歇微凉:AwAGCAoABAoAAA==.',['�']='风吹乱了你我:AwAGCA8ABAoAAA==.风吹半夏:AwAECAQABAoAAA==.',['�']='饭饭猫:AwABCAEABAoAAA==.',['�']='魑魅波:AwABCAEABRQAAA==.',['�']='黑色的猫:AwACCAQABRQEFwAIAQiiHQA0oM0BBAoAFwAIAQiiHQA0oM0BBAoABwADAQjsZAAjXHMABAoAFgACAQjKgwAV1jUABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end