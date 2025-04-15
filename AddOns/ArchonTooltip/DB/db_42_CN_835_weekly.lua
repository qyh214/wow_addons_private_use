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
 local lookup = {'Evoker-Devastation','Druid-Balance','Druid-Restoration','DemonHunter-Havoc','Mage-Frost','Mage-Fire','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','DemonHunter-Vengeance','Rogue-Subtlety','Rogue-Assassination','Mage-Arcane','DeathKnight-Unholy','DeathKnight-Blood',}; local provider = {region='CN',realm='达克萨隆',name='CN',type='weekly',zone=42,date='2025-04-15',data={Cg='Cgmmi:AwAICAgABAoAAA==.',Co='Conclusion:AwAICAcABAoAAQEAKbkECAgABRQ=.',Li='Lillness:AwAECAgABRQCAQADAQjTDgApuboABRQAAQADAQjTDgApuboABRQAAA==.',Sn='Snakiehollic:AwAICAgABAoAAA==.',Yo='Yokoh:AwABCAIABRQAAA==.',['�']='丶恩赐解脱:AwACCAIABRQAAA==.丶情思转阑珊:AwAICAgABAoAAA==.丶阿宝:AwAGCAoABAoAAA==.',['�']='你的小可爱:AwAICA4ABAoAAA==.',['�']='元素灰烬:AwABCAEABRQAAA==.',['�']='冰中的火焰:AwAGCAUABAoAAA==.',['�']='勇敢的张:AwAGCAYABAoAAA==.',['�']='北洋之狼:AwAFCAUABAoAAA==.',['�']='古今第一喷:AwADCAMABAoAAA==.',['�']='咕咕子:AwAICAkABAoAAA==.',['�']='啊酷呐玛塔塔:AwABCAEABRQAAA==.',['�']='塞萌丶德:AwAGCA8ABRQDAgAGAQg/AwAOUE0BBRQAAgAGAQg/AwAOUE0BBRQAAwAFAQinBQAT1AEBBRQAAA==.',['�']='夏日微寒:AwAICAgABAoAAA==.',['�']='奥客:AwADCAMABAoAAA==.好哥们:AwADCAMABRQAAA==.',['�']='孤存:AwABCAEABRQCBAAIAQg4HgBG2DgCBAoABAAIAQg4HgBG2DgCBAoAAA==.',['�']='小丶旋风:AwADCAMABAoAAA==.小炳:AwACCAIABAoAAA==.就打丶那个德:AwAGCAYABAoAAA==.',['�']='巅峰滑水员:AwAICAoABAoAAA==.',['�']='布兰:AwACCAIABRQAAA==.帕瓦:AwAICBoABAoDBQAIAQjINAAy0XsBBAoABQAIAQjINAAusnsBBAoABgAGAQg4VQAeTAsBBAoAAQcAAAACCAIABRQ=.',['�']='揍你的猫:AwAICAsABAoAAA==.',['�']='无敌小母猫:AwABCAEABAoAAA==.',['�']='朵喵喵丶:AwAHCBUABAoDCAAHAQg4VQAzypEBBAoACAAHAQg4VQAy9pEBBAoACQAEAQjBXwAMFmgABAoAAA==.',['�']='洋河吴彦祖:AwAICAoABAoAAA==.',['�']='火山灰:AwAFCBEABRQCCAAFAQgHCAAnxywBBRQACAAFAQgHCAAnxywBBRQAAQcAAAAICAQABRQ=.',['�']='牦牛:AwADCAMABAoAAA==.',['�']='玄牝之门:AwAICBkABAoCCgAIAQjpEABcE8kCBAoACgAIAQjpEABcE8kCBAoAAA==.',['�']='瑪琉染柒:AwACCAIABRQAAA==.',['�']='素手绾青丝:AwAICBUABAoDCwAIAQjMHQAt12kBBAoACwAIAQjMHQAt12kBBAoABAAFAQhRvwAAAQEABAoAAA==.',['�']='红丶枣:AwABCAEABAoAAA==.',['�']='羽入:AwAECAgABRQDDAAEAQh2CAA6tt8ABRQADAAEAQh2CAAeYd8ABRQADQAEAAgAAAA3twAABRQAAA==.',['�']='苦酒折柳:AwAICCYABAoCDgAIAQiUAwA/5h4CBAoADgAIAQiUAwA/5h4CBAoAAA==.',['�']='萌妙妙:AwAICAYABAoAAA==.萌譁:AwAICAgABAoAAA==.',['�']='谁啊:AwAECAQABRQAAA==.',['�']='逆天逍遥:AwADCAMABAoAAA==.通碧:AwAECAQABAoAAA==.',['�']='青灯佛茶:AwAICBYABAoDDwAIAQjKOgBCEJ8BBAoADwAIAQjKOgA/eJ8BBAoAEAAIAQjqJwAhOCYBBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end