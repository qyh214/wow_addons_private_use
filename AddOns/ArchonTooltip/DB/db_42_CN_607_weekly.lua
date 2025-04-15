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
 local lookup = {'Monk-Windwalker','Monk-Brewmaster','Monk-Mistweaver','Rogue-Assassination','Rogue-Subtlety','Shaman-Elemental','Druid-Balance','Druid-Restoration',}; local provider = {region='CN',realm='哈兰',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ci='Cicci:AwADCAMABAoAAA==.',De='Devilil:AwAICAgABAoAAA==.',Go='Goodjobs:AwACCAIABAoAAA==.',Ni='Nionjiujiudi:AwAFCAUABAoAAA==.',We='Weiyan:AwAICAgABAoAAA==.',['�']='不能喝酒:AwACCAQABRQDAQAIAQg2DQBTfmkCBAoAAQAIAQg2DQBTGmkCBAoAAgAGAQiWDQBPYz8BBAoAAA==.世界一刘:AwAICA4ABAoAAA==.',['�']='也许是爱:AwAECAQABRQAAA==.',['�']='你还要我怎样:AwAECAQABRQAAA==.',['�']='十字军流浪:AwAHCBUABAoCAwAHAQgPGgBKzvkBBAoAAwAHAQgPGgBKzvkBBAoAAA==.',['�']='吉洝娜娜:AwADCAQABAoAAA==.',['�']='咔咔起:AwAFCAUABRQDBAAFAQiPBwAocuEABRQABAAEAQiPBwAoxeEABRQABQABAQhmDQAneWMABRQAAA==.',['�']='哈士奇丶:AwAECAQABAoAAA==.哈蓝:AwAFCAQABAoAAA==.',['�']='嘦你:AwABCAEABAoAAA==.',['�']='墨颜:AwAGCAQABRQAAA==.',['�']='多多良小伞:AwAGCBAABAoAAA==.',['�']='孟秋之月:AwACCAIABRQAAA==.',['�']='巫索普:AwAHCA0ABAoAAA==.',['�']='幻灬亓:AwABCAEABAoAAA==.',['�']='御天荒神:AwAFCAUABAoAAA==.',['�']='我紧张:AwAGCAYABAoAAA==.',['�']='没奶别找我:AwADCAMABAoAAA==.',['�']='灭团奶德:AwAECAQABRQAAA==.',['�']='疯熊猫:AwADCAsABRQCAwADAQgpBwBNvQ8BBRQAAwADAQgpBwBNvQ8BBRQAAA==.',['�']='相敬灬如宾:AwABCAEABRQCBgAIAQjOKQAflHIBBAoABgAIAQjOKQAflHIBBAoAAA==.',['�']='红心盼:AwAHCAkABAoAAA==.',['�']='老斯特:AwAICAgABAoAAA==.',['�']='色如刮骨钢刀:AwAFCAUABAoAAA==.',['�']='蓝琭琭:AwAGCAYABAoAAA==.',['�']='达司雷玛:AwAFCAUABAoAAA==.',['�']='迪斯路亚:AwABCAEABAoAAA==.追光者:AwACCAIABRQAAA==.',['�']='部落:AwAECAQABAoAAA==.',['�']='铁戛:AwAECAoABRQDBwAEAQgeFAAefs0ABRQABwAEAQgeFAAefs0ABRQACAACAQg7DQBKSZoABRQAAA==.',['�']='静默灬淡颜:AwAECAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end