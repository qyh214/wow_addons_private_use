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
 local lookup = {'Unknown-Unknown','Druid-Balance','Shaman-Restoration','Shaman-Elemental','Warlock-Affliction','Hunter-BeastMastery','Mage-Frost','Paladin-Retribution',}; local provider = {region='CN',realm='埃雷达尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ai='Aiout:AwAFCAMABAoAAA==.',Ph='Phantasos:AwAECAQABAoAAA==.',Sl='Slowdive:AwAECAQABRQAAA==.',Vo='Voovvo:AwADCAUABAoAAA==.',['�']='似慵懒乖猫:AwAICAgABAoAAQEAAAAGCAQABRQ=.',['�']='你来打我啊:AwAHCA4ABAoAAA==.',['�']='冲锋倒:AwAECAQABRQAAA==.',['�']='加尔的长发:AwACCAYABRQCAgACAQhDIQAhMHMABRQAAgACAQhDIQAhMHMABRQAAA==.',['�']='叁成味火锅:AwAECAgABRQCAwAEAQjpBwBGYAEBBRQAAwAEAQjpBwBGYAEBBRQAAA==.又到芒种时:AwAICAgABAoAAQEAAAAECAQABRQ=.',['�']='吹风机:AwAICAIABAoAAQEAAAAICAEABRQ=.',['�']='墜落之羽:AwAECAQABRQAAA==.',['�']='大吉岭茶:AwADCAQABRQCBAAIAQh7AQBhjv4CBAoABAAIAQh7AQBhjv4CBAoAAA==.',['�']='奔跑的小猪:AwAICAEABAoAAA==.',['�']='寒羽良辰:AwAGCAYABAoAAA==.',['�']='幽灵特使:AwAHCAcABAoAAA==.',['�']='抓了只大咕咕:AwACCAIABRQAAA==.',['�']='星野诗羽:AwAFCAUABAoAAA==.',['�']='暗月风华:AwADCAMABAoAAA==.',['�']='最后一葉:AwAECAQABRQAAA==.',['�']='東東龍:AwAECAQABRQAAA==.',['�']='歸途過愘:AwAFCAEABAoAAA==.',['�']='洋卜卜:AwAICBIABAoAAA==.',['�']='浪火夺:AwACCAQABRQCBQAIAQi8CAA0ssUBBAoABQAIAQi8CAA0ssUBBAoAAA==.',['�']='温蕾萨:AwACCAIABRQAAA==.',['�']='盒子萨:AwADCAMABAoAAA==.',['�']='硬扎:AwADCAMABAoAAA==.',['�']='米定论:AwACCAIABRQAAA==.',['�']='芒种小小:AwAICBYABAoCBgAIAQjUGwBPLnICBAoABgAIAQjUGwBPLnICBAoAAA==.',['�']='路上的盒子:AwABCAIABRQCBwAIAQgKCQBfQ6sCBAoABwAIAQgKCQBfQ6sCBAoAAA==.',['�']='这波没我:AwAGCAYABAoAAA==.',['�']='铸之魂:AwAHCAIABAoAAA==.',['�']='雨之昊天:AwAICBUABAoCCAAIAQhYcwAnGIkBBAoACAAIAQhYcwAnGIkBBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end