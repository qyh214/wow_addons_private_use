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
 local lookup = {'Rogue-Subtlety','Rogue-Assassination','Paladin-Retribution','DemonHunter-Havoc','Evoker-Devastation','Evoker-Preservation','Unknown-Unknown','Warlock-Destruction','Hunter-Marksmanship','Paladin-Holy','Shaman-Restoration','Hunter-BeastMastery','Warrior-Fury','Warrior-Arms',}; local provider = {region='CN',realm='阿比迪斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ab='Absolution:AwACCAMABRQDAQAIAQgMEABHVOcBBAoAAQAHAQgMEAA/OecBBAoAAgAFAQg+GQBDTZEBBAoAAA==.',Bi='Bighammer:AwAECAQABRQAAA==.Bimmer:AwAECAQABRQAAA==.',Ei='Eiysony:AwACCAMABRQAAA==.',Jo='Joycee:AwADCAIABAoAAA==.',Ma='Magicfaint:AwAECAQABRQAAA==.',Pa='Papiyas:AwAICAsABAoAAA==.Paramour:AwAECAUABRQCAwADAQg9EQA8rQMBBRQAAwADAQg9EQA8rQMBBRQAAA==.',So='Somaxx:AwAHCAEABAoAAA==.',Ti='Tiamol:AwAECAQABRQAAA==.',['�']='丁达尔迅贤:AwAECAQABRQAAA==.三横一竖的人:AwAECAIABAoAAA==.东北大仙:AwAICAEABAoAAA==.丶会暖床:AwACCAIABRQAAA==.丶加尓鲁什:AwABCAEABRQAAA==.丶宁采臣:AwAECAQABRQAAA==.丶柴郡猫:AwAECAQABAoAAA==.丿芜灬訫丨:AwABCAEABRQAAA==.',['�']='以撒:AwADCAsABRQCBAADAQhBCQBIghMBBRQABAADAQhBCQBIghMBBRQAAA==.以言:AwAECBAABRQDBQAEAQioCABD4PIABRQABQAEAQioCABD4PIABRQABgACAQjdBgAgyHEABRQAAQcAAAAGCAQABRQ=.',['�']='传说中的逗逼:AwAICBIABAoAAA==.',['�']='再也不熬夜:AwAICAgABAoAAA==.',['�']='凉小戒:AwAECAIABAoAAA==.',['�']='别削弱我:AwAICAgABAoAAA==.别德亿:AwABCAEABRQAAA==.',['�']='前田香織:AwAICAIABAoAAA==.',['�']='半岛晴空:AwACCAUABRQCCAACAQj/HQAiTnsABRQACAACAQj/HQAiTnsABRQAAA==.南风入弦:AwAECAYABRQCCQAEAQgkBwBHC/YABRQACQAEAQgkBwBHC/YABRQAAA==.卡油豆:AwABCAEABRQAAA==.',['�']='叫我辉哥就好:AwAICAoABAoAAA==.',['�']='吃泡面送火箭:AwAICAgABAoAAA==.',['�']='哥就是李刚:AwACCAUABRQCCgACAQgeCgAyWZ4ABRQACgACAQgeCgAyWZ4ABRQAAA==.',['�']='嘎嘎土:AwAGCAYABAoAAA==.',['�']='地狱土豆:AwAFCAkABAoAAA==.',['�']='复兴路吴彦祖:AwAECAQABRQAAA==.天武茶道:AwACCAIABAoAAA==.',['�']='小霸王乐吴琼:AwACCAQABRQCCwAIAQgqSQAfTUUBBAoACwAIAQgqSQAfTUUBBAoAAA==.小馋猫丶:AwAECAQABRQAAA==.',['�']='岁月翩跹:AwAECAQABRQAAA==.',['�']='弗洛一德:AwAICAgABAoAAQcAAAACCAIABRQ=.',['�']='我的确萌新:AwAHCAoABAoAAA==.',['�']='打裆:AwADCAMABAoAAA==.',['�']='散桦礼弥:AwAECAQABAoAAA==.敲钟牛:AwADCAMABAoAAA==.',['�']='无双一箭:AwABCAEABRQAAA==.无尽的冰霜:AwAHCBMABAoAAA==.无尽的咆哮:AwADCAgABRQCDAADAQhZBwBdCjIBBRQADAADAQhZBwBdCjIBBRQAAA==.无尽的浪漫:AwACCAIABRQAAA==.无尽的翅膀:AwAHCBMABAoAAQwAXQoDCAgABRQ=.',['�']='明月之心:AwACCAIABRQAAA==.',['�']='李火旺:AwAECAQABAoAAA==.松落叶:AwACCAcABRQDDQACAQiQHAAPoYMABRQADQACAQiQHAAPKIMABRQADgABAQhaFgARtUMABRQAAA==.',['�']='极夜使者:AwAICAIABAoAAA==.',['�']='柠檬味的橙子:AwAHCAcABAoAAA==.',['�']='桃华我老婆:AwAECAQABRQAAA==.桃白白丶:AwAECAQABRQAAA==.',['�']='梦落红尘:AwAHCA0ABAoAAA==.',['�']='棺柩裁缝师:AwAICBAABAoAAA==.',['�']='汐顔:AwABCAIABRQAAA==.',['�']='波妞出去玩:AwAECAYABRQCCwAEAQhWCABKFwYBBRQACwAEAQhWCABKFwYBBRQAAA==.波比锤子大:AwACCAIABRQAAA==.',['�']='涟漪泛泛:AwAICAgABAoAAA==.',['�']='湮丶羽轩:AwADCAwABRQDDAADAQgwIABB2bAABRQADAACAQgwIABJ0rAABRQACQABAQhBGgAx6E4ABRQAAA==.',['�']='滿是纏綿:AwAECAQABRQAAA==.',['�']='熬过每个夜:AwABCAEABRQAAA==.',['�']='爱睡觉的橙子:AwAICAQABAoAAA==.',['�']='狼铛:AwABCAEABRQAAA==.',['�']='猪腰子丶:AwAECAIABRQAAA==.猫熊猫熊:AwAECAQABRQAAA==.',['�']='白夜圈圈:AwAICAIABAoAAA==.',['�']='瞎湖闹:AwAGCAYABAoAAA==.瞎猫丶:AwAECAQABRQAAA==.',['�']='神牛骑将:AwAECAQABRQAAA==.',['�']='科学养猪丶:AwAECAMABAoAAA==.',['�']='空城空梦:AwAICAgABAoAAA==.',['�']='花香清新:AwACCAIABAoAAA==.',['�']='莫克莱尼:AwABCAEABRQAAA==.莫逐燕:AwAGCAQABRQAAA==.',['�']='萌新小白兔:AwACCAIABRQAAA==.萌萌哒刚背牛:AwACCAEABRQAAA==.',['�']='蓝啵兔:AwACCAcABRQCAwACAQhDLQAum5UABRQAAwACAQhDLQAum5UABRQAAA==.',['�']='贾丶克丶斯:AwAICAgABAoAAA==.',['�']='超笙天下:AwAICA8ABAoAAA==.',['�']='轩辕老鬼:AwAFCAUABAoAAA==.',['�']='追魂:AwACCAIABRQAAA==.',['�']='那个法士:AwAECAQABRQAAA==.',['�']='阿咒:AwAGCAYABAoAAA==.',['�']='雾殇雨:AwACCAYABRQCAwACAQgMIwBK9rwABRQAAwACAQgMIwBK9rwABRQAAA==.',['�']='领闲主演:AwAGCAwABAoAAA==.',['�']='飯飯:AwADCAMABAoAAA==.',['�']='驹驹:AwAECAQABRQAAA==.驹驹大人:AwAECAQABRQAAA==.',['�']='麦卡农:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end