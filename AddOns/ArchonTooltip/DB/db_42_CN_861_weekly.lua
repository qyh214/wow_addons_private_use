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
 local lookup = {'Paladin-Retribution','Paladin-Holy','Unknown-Unknown','Rogue-Subtlety','DemonHunter-Havoc','DemonHunter-Vengeance',}; local provider = {region='CN',realm='阿卡玛',name='CN',type='weekly',zone=42,date='2025-04-15',data={Bl='Blacklink:AwAICAgABAoAAA==.',['�']='一骑当千:AwAGCAgABRQDAQAGAQieAQAqSKoBBRQAAQAGAQieAQAqSKoBBRQAAgABAQjSEgAIJDgABRQAAA==.七月辛:AwADCAMABAoAAA==.丶拉斐埃尔丶:AwAFCAUABAoAAA==.',['�']='亲爱的亲爱的:AwAECAQABRQAAQMAAAAICAIABRQ=.',['�']='你来了:AwAECAgABRQCBAAEAQjnAgBU7CQBBRQABAAEAQjnAgBU7CQBBRQAAA==.',['�']='制杖大帝:AwAGCAYABAoAAA==.',['�']='叢雨:AwAHCAwABAoAAA==.',['�']='圣光狂想曲:AwAECAQABRQAAA==.圣光的长颈鹿:AwACCAIABRQAAA==.',['�']='娘子:AwACCAEABAoAAA==.',['�']='小混大划水:AwACCAIABAoAAA==.',['�']='巨蟹:AwABCAEABAoAAA==.',['�']='希尔瓦纳斯:AwAICAwABAoAAA==.',['�']='很吊很犀利:AwAFCAUABAoAAA==.',['�']='抬头看月又沉:AwAICAgABAoAAA==.',['�']='星期天丶:AwAHCAcABAoAAA==.',['�']='月夜黄昏:AwAECAQABRQAAA==.月轻轻:AwADCAgABRQCBQADAQjpEAApr+sABRQABQADAQjpEAApr+sABRQAAQUAEAgECAYABRQ=.',['�']='柒小柒:AwACCAIABRQAAA==.',['�']='橙多多:AwAECAQABRQAAA==.',['�']='死神来了:AwAICBwABAoDBgAIAQhUKgAmeQgBBAoABgAIAQhUKgAmeQgBBAoABQAEAQj0lgAM22oABAoAAA==.',['�']='没求的名字了:AwACCAMABRQAAA==.',['�']='狂风吹我心:AwADCAMABAoAAA==.',['�']='猫猫侠丶:AwABCAEABRQAAA==.',['�']='聖棋士:AwAGCAYABAoAAA==.',['�']='谋曹丕:AwAECAQABRQAAA==.',['�']='金枝玉叶:AwAFCAUABAoAAA==.',['�']='银月浪漫:AwACCAcABRQCAQACAQifLwAr848ABRQAAQACAQifLwAr848ABRQAAA==.',['�']='阿巴阿巴:AwAICAgABAoAAA==.',['�']='雨落轻尘:AwABCAEABAoAAA==.',['�']='风吹酒醒:AwADCAMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end