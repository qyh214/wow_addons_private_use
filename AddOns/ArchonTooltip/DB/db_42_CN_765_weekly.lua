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
 local lookup = {'Unknown-Unknown','DemonHunter-Havoc',}; local provider = {region='CN',realm='瓦丝琪',name='CN',type='weekly',zone=42,date='2025-04-14',data={La='Lash:AwAGCAYABAoAAA==.',Vi='Violent:AwAFCAUABAoAAA==.',['�']='丨眼眸丨:AwABCAEABRQAAA==.',['�']='你狐吗:AwAICA4ABAoAAA==.',['�']='劈头士帅牛:AwADCAMABAoAAA==.',['�']='圣光忽悠悠:AwACCAIABRQAAA==.',['�']='复仇女神:AwABCAEABAoAAA==.',['�']='小痴躲猫猫:AwABCAEABRQAAA==.',['�']='张三秒:AwABCAEABAoAAA==.',['�']='怪叁叔:AwAFCAgABAoAAA==.怪贰嫂:AwABCAEABRQAAA==.怪骑骑:AwACCAIABAoAAA==.',['�']='无心的航海:AwAICAgABAoAAQEAAAAICAEABRQ=.',['�']='潇潇:AwADCAIABAoAAA==.',['�']='牧殇小痴:AwAICA4ABAoAAA==.',['�']='玛卡巴卡卜:AwABCAEABRQAAA==.',['�']='白银之爹:AwAFCAkABAoAAA==.',['�']='老李六号:AwACCAIABRQAAA==.',['�']='菊花棒棒糖:AwAECAUABRQCAgAEAQhkDQA3wvgABRQAAgAEAQhkDQA3wvgABRQAAA==.',['�']='送葬的霍霍:AwABCAEABAoAAA==.',['�']='飙车男:AwADCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end