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
 local lookup = {'Mage-Frost','Mage-Fire','Paladin-Retribution','DeathKnight-Blood','Druid-Balance','Paladin-Holy','Monk-Mistweaver','Priest-Holy','Priest-Discipline',}; local provider = {region='CN',realm='拉文霍德',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Arthasdk:AwABCAEABRQAAA==.',Le='Leogend:AwAECAQABRQDAQAIAQhUAwBervICBAoAAQAIAQhUAwBervICBAoAAgACAQjhmAAJ7CIABAoAAA==.',Pr='Prmsivonn:AwACCAQABRQCAQAIAQiSAwBd8e4CBAoAAQAIAQiSAwBd8e4CBAoAAA==.',Ru='Rua:AwACCAIABAoAAA==.',Ti='Tindomiel:AwAICBEABAoAAA==.',['�']='不能怂赶紧送:AwAICBIABAoAAA==.丨桂言葉丨:AwAHCAkABAoAAA==.',['�']='九五二七:AwAGCAYABAoAAA==.',['�']='五档太阳神:AwAGCAsABAoAAA==.亡红月影:AwACCAIABRQAAA==.',['�']='你最珍贵:AwACCAMABRQAAA==.',['�']='依然寻觅:AwAICA0ABAoAAA==.',['�']='全部停手:AwACCAIABRQAAA==.兰斯彼恩:AwABCAEABAoAAA==.',['�']='华咕咕:AwAECAQABRQAAA==.华碎星:AwAICA8ABAoAAA==.',['�']='可口可乐:AwAGCA0ABAoAAA==.',['�']='咪樂貓:AwAICAYABAoAAA==.',['�']='喵乐咪:AwADCAMABRQAAA==.',['�']='墨离殇:AwAICBgABAoCAwAIAQjyWwBCtcEBBAoAAwAIAQjyWwBCtcEBBAoAAA==.',['�']='小救星小杜:AwAICAcABAoAAA==.',['�']='开着三崩子:AwAECAQABRQAAA==.弃天帝:AwAECAQABRQAAQQAV20GCAgABRQ=.弦上啭春莺:AwAECAQABRQAAA==.',['�']='彩彻区明:AwADCAIABRQAAA==.',['�']='德勒巴妮娅:AwAECAcABRQCBQAEAQiBCgBBlP4ABRQABQAEAQiBCgBBlP4ABRQAAA==.',['�']='心灵种子:AwAGCAUABAoAAA==.',['�']='摩诃迦叶:AwAGCAYABAoAAA==.',['�']='收购幸福:AwADCAQABRQAAA==.',['�']='无情丶玄冰:AwAECAQABAoAAA==.',['�']='殇灬冰鸢:AwAICAsABAoAAA==.殇灬无痕:AwACCAIABRQDAwAIAQjsAgBioxEDBAoAAwAIAQjsAgBioxEDBAoABgAIAQgzCABbfEUCBAoAAA==.',['�']='牛肉帝王:AwAECAgABRQCAgAEAQiWEABHUPQABRQAAgAEAQiWEABHUPQABRQAAA==.',['�']='王富贵:AwAECAQABRQAAA==.',['�']='碧愈疾风:AwAECAwABRQCBwAEAQj3BABWICoBBRQABwAEAQj3BABWICoBBRQAAA==.',['�']='自作多情:AwAICBAABAoAAA==.',['�']='花心:AwAGCAsABAoAAA==.',['�']='落樱纷飞:AwACCAIABRQDCAAIAQhyEwBTTBICBAoACAAIAQhyEwBFAhICBAoACQAIAQgIFQA/JPgBBAoAAA==.',['�']='银铸八极:AwAECAQABRQAAA==.',['�']='雪化凝冰:AwAECAQABAoAAA==.',['�']='香香公主:AwAGCAcABAoAAA==.',['�']='魅雪紫夢:AwAECAQABRQAAA==.',['�']='鸟飞走了:AwAECAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end