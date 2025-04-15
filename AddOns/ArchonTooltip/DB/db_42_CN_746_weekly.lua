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
 local lookup = {'Warrior-Arms','Unknown-Unknown','Monk-Mistweaver','Shaman-Restoration','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction',}; local provider = {region='CN',realm='烈焰荆棘',name='CN',type='weekly',zone=42,date='2025-04-14',data={El='Elysium:AwACCAIABAoAAA==.',Ji='Jinly:AwABCAIABRQAAA==.',['�']='乐天:AwAICAgABAoAAA==.',['�']='八级狂风:AwABCAEABAoAAA==.',['�']='双木林:AwACCAIABRQAAQEAU8cGCAYABRQ=.',['�']='吴钩霜雪明:AwAECAIABRQAAQIAAAAICAQABRQ=.',['�']='咖喱牛肉人:AwADCAgABRQCAwADAQh3DQAqZuAABRQAAwADAQh3DQAqZuAABRQAAA==.',['�']='哈尔酱:AwACCAQABRQAAA==.',['�']='喷火中水龙:AwAECAgABRQCBAAEAQghDQAnQ98ABRQABAAEAQghDQAnQ98ABRQAAA==.',['�']='天天忝蓝:AwAICAgABAoAAA==.',['�']='孤冷渊:AwACCAIABRQAAA==.',['�']='小宝是坏蛋:AwABCAEABAoAAA==.',['�']='很有兽性:AwABCAIABRQAAA==.',['�']='念十漪:AwACCAIABAoAAA==.',['�']='打亮亮:AwAICAUABAoAAA==.',['�']='是烈火是枯枝:AwABCAEABRQAAA==.',['�']='最后的光之子:AwAECAQABAoAAA==.月曙:AwABCAEABAoAAA==.',['�']='沃洛克:AwAICBsABAoEBQAIAQisBgBYG7QCBAoABQAIAQisBgBXgrQCBAoABgABAQgsVgBGIFQABAoABwABAQjWOQAmUT8ABAoAAA==.',['�']='浅笑浮白:AwABCAEABRQAAA==.',['�']='神鬼迷踪步:AwADCAMABAoAAA==.',['�']='移动炮台:AwABCAEABRQAAA==.',['�']='紫殿流星:AwAICAkABAoAAA==.',['�']='罪恶的夜晚:AwAFCAEABAoAAA==.',['�']='铂爵瓦坎达:AwADCAUABAoAAA==.',['�']='阿郎丶:AwAGCAsABAoAAA==.阿郎来了:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end