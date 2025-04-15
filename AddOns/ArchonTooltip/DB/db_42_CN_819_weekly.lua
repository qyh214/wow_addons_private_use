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
 local lookup = {'Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Rogue-Assassination','Mage-Frost','Monk-Windwalker','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Priest-Holy','Druid-Balance','Paladin-Holy','Paladin-Retribution','Monk-Mistweaver','Unknown-Unknown','Mage-Fire',}; local provider = {region='CN',realm='蓝龙军团',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ad='Addiction:AwABCAEABRQAAA==.',Ca='Caiono:AwAGCAYABAoAAA==.',Dk='Dkl:AwAECAQABAoAAA==.',My='Mynameispp:AwAECAMABAoAAA==.',No='Nobrains:AwAFCAUABAoAAA==.',Ug='Uglybeauty:AwAGCAYABRQDAQAEAQgQBwA1kusABRQAAQAEAQgQBwApwesABRQAAgACAQhGHgA4znoABRQAAQMAVmAHCAcABRQ=.',Wa='Wadaxi:AwABCAEABAoAAA==.',['�']='三碗不过岗:AwADCAMABAoAAA==.丶小馒頭:AwAICAgABAoAAA==.丶隔壁老王:AwAFCAUABAoAAA==.',['�']='乔木:AwADCAMABAoAAA==.',['�']='他朝:AwABCAEABAoAAA==.',['�']='低调的杀手:AwAHCAoABAoAAA==.',['�']='偌只如初見:AwAHCBQABAoCBAAHAQgaDQBYOCwCBAoABAAHAQgaDQBYOCwCBAoAAA==.',['�']='全体起立:AwAHCAcABAoAAA==.八万:AwAECAQABRQAAA==.',['�']='冰灵之魂:AwAECAgABRQCBQAEAQgkBABJbwoBBRQABQAEAQgkBABJbwoBBRQAAA==.',['�']='原味少女胖次:AwAICBAABAoAAA==.',['�']='名侦探兔美:AwADCAUABRQDAgADAQi0HQAXpX0ABRQAAQACAQgdEgANYH4ABRQAAgACAQi0HQAhPH0ABRQAAA==.',['�']='喜欢猫猫:AwAICBQABAoCAgAIAQiSCQBUYZgCBAoAAgAIAQiSCQBUYZgCBAoAAA==.',['�']='団子:AwACCAQABRQCBgAIAQjKDgBKDGECBAoABgAIAQjKDgBKDGECBAoAAA==.',['�']='圆圆的大肚纸:AwAFCAgABAoAAA==.圣光忽悠:AwAGCAYABAoAAA==.',['�']='大白狗:AwAHCAoABAoAAA==.天使下了凡:AwAHCAcABAoAAA==.',['�']='奈克赛斯:AwACCAMABRQCBwAIAQg/FwBIBGcCBAoABwAIAQg/FwBIBGcCBAoAAA==.',['�']='守护者阿洛迪:AwAGCAoABRQECAAGAQhjDABAftsABRQACAAEAQhjDAAx/tsABRQACQACAQhZDgBYxNcABRQACgAEAQh/DAAPprwABRQAAA==.安娜贝丽:AwADCAoABRQCCwADAQinDwA4Oe4ABRQACwADAQinDwA4Oe4ABRQAAA==.',['�']='小光:AwABCAEABRQAAA==.小狗快跑:AwAECAgABRQDDAAEAQh+BQAz5OcABRQADAAEAQh+BQAz5OcABRQADQACAQipOwBQL1kABRQAAA==.小黑哟:AwAECAQABAoAAA==.',['�']='师傅不要这样:AwAFCAUABAoAAA==.希格文:AwAFCAUABRQCCQAFAQjHAwA4QV0BBRQACQAFAQjHAwA4QV0BBRQAAA==.',['�']='德国妮子:AwAFCAgABAoAAA==.',['�']='恶魔领主:AwADCAMABAoAAA==.',['�']='悠悠残月:AwAGCAcABAoAAA==.',['�']='惟名狸希:AwAFCAQABRQCDgAEAQgzEwAPUsMABRQADgAEAQgzEwAPUsMABRQAAQ4AH94ICAoABRQ=.',['�']='戀愛:AwAFCAYABAoAAA==.戀魚:AwABCAEABAoAAA==.',['�']='折翼的狐狸:AwAFCAoABAoAAA==.',['�']='捞斯特:AwAICAgABAoAAA==.',['�']='放肆的沉默:AwACCAEABAoAAA==.',['�']='星野梦夏树:AwAHCAoABAoAAA==.',['�']='枫舞灬晴空:AwAECAQABRQAAA==.',['�']='永胤:AwAGCAQABRQAAQ8AAAAICAQABRQ=.',['�']='浮戌:AwAGCAUABAoAAA==.',['�']='炎爆羊肉拌面:AwAFCAUABAoAAA==.',['�']='熊了个猫:AwAGCAcABAoAAA==.',['�']='猪咪:AwAECAQABRQAAA==.',['�']='番茄炒鸡蛋:AwAECAQABRQAAA==.',['�']='直人:AwABCAEABAoAAA==.',['�']='窈窕淑狼:AwAECAQABRQAAQIAOowGCAYABRQ=.',['�']='红中:AwAECAQABRQAARAATQoICBAABRQ=.',['�']='绯夜苍穹:AwAICAgABAoAAA==.维生素片:AwABCAEABAoAAA==.',['�']='腿毛黝黑:AwAHCAcABAoAAA==.',['�']='色系:AwADCAMABAoAAA==.',['�']='花虎:AwAECAQABAoAAA==.',['�']='薇尔莉特丶:AwAECAQABRQAAA==.',['�']='读条三十秒:AwAICAgABAoAAA==.',['�']='还是个泡泡:AwAHCAcABAoAAA==.',['�']='阿坎玛星歌:AwAGCAQABRQAAA==.阿萊克丝塔萨:AwACCAIABAoAAA==.',['�']='陌陌芊芊:AwAICAoABAoAAA==.',['�']='飒飒逞风:AwABCAEABAoAAA==.',['�']='鱼普萝德摩尔:AwAECAgABRQCEAAEAQiZDgBJxwUBBRQAEAAEAQiZDgBJxwUBBRQAAA==.',['�']='鼠鼠:AwACCAIABAoAAA==.',['�']='龙之楚天:AwAGCAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end