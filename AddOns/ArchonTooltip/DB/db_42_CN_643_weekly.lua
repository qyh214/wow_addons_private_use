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
 local lookup = {'Rogue-Subtlety','Mage-Fire','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Evoker-Devastation','Paladin-Retribution','DemonHunter-Havoc','Paladin-Protection',}; local provider = {region='CN',realm='奥斯里安',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Anubisreaper:AwAICBgABAoCAQAIAQirCwBHoyoCBAoAAQAIAQirCwBHoyoCBAoAAA==.',Au='Austonmartin:AwAFCAoABAoAAA==.',Ma='Maomaoshaman:AwADCAMABAoAAA==.',['�']='丿吻灬别:AwAECAQABRQAAA==.',['�']='乔艾莉波妮:AwAICA4ABAoAAA==.',['�']='二楼经理:AwAECAQABRQAAA==.人間失格丶:AwAICAgABAoAAA==.',['�']='似惊雷丶:AwAICBYABAoCAgAIAQh2MQAtzMIBBAoAAgAIAQh2MQAtzMIBBAoAAA==.',['�']='克洛克达尔:AwAICAgABAoAAA==.',['�']='叶問:AwAECAQABRQAAA==.',['�']='含泪加入:AwAECA0ABRQCAQAEAQiiAQBgr0oBBRQAAQAEAQiiAQBgr0oBBRQAAA==.吾王丨:AwAECAQABRQAAA==.',['�']='唵嘛呢叭哞吽:AwAICAgABAoAAA==.',['�']='多弗朗明哥:AwAECAIABRQAAA==.',['�']='娴熟的荒凉丶:AwACCAEABRQAAA==.',['�']='尨樧銀狼:AwAECAQABRQAAA==.',['�']='怂得一批:AwAICAcABAoAAA==.',['�']='我不够持久:AwACCAIABAoAAQMAAAAGCAIABRQ=.我头上有犄角:AwAICAgABAoAAA==.',['�']='执着的铁锤:AwACCAIABAoAAA==.',['�']='掌上老虎:AwAECAwABRQDBAAEAQjjAgBPmhkBBRQABAAEAQjjAgBPNBkBBRQABQAEAQjiEABDwvYABRQAAA==.',['�']='斯文的:AwAECAQABRQAAQMAAAAICAQABRQ=.',['�']='旅店老板娘:AwAECAQABRQAAA==.',['�']='昕诚:AwAICAUABAoAAA==.',['�']='橙色:AwAECAQABAoAAA==.',['�']='没脑袋:AwAFCAUABRQCBgAFAQgwAgBA5G0BBRQABgAFAQgwAgBA5G0BBRQAAA==.',['�']='流氓兔斯基:AwACCAQABRQAAA==.',['�']='清晨点根烟:AwAICBYABAoCBwAIAQjNaABBV6IBBAoABwAIAQjNaABBV6IBBAoAAA==.',['�']='漫步灬云端:AwAICBgABAoCCAAIAQjxEwBO93YCBAoACAAIAQjxEwBO93YCBAoAAA==.',['�']='火炏焱:AwADCAMABAoAAA==.',['�']='烈咬路鲨:AwAECAMABRQAAA==.',['�']='燃烧的可乐:AwAICBAABAoAAA==.',['�']='牛儿响叮当:AwAHCAcABAoAAA==.',['�']='獠丶牙:AwAFCAUABAoAAA==.',['�']='盐味拉面:AwABCAEABAoAAA==.',['�']='真的是你呀:AwAGCAUABAoAAA==.',['�']='硕大无朋:AwACCAIABRQAAA==.',['�']='秦百胜:AwABCAIABAoAAA==.',['�']='绫零:AwAHCAsABAoAAA==.',['�']='翻滚吧三月半:AwAICAgABAoAAA==.',['�']='自恋长发飘:AwAHCBEABAoAAA==.至臻小德:AwAECAQABRQAAA==.至臻牧司:AwABCAEABAoAAA==.',['�']='芋泥厚厚牛奶:AwAGCAYABRQCCQAGAQiNDQBMqWoABRQACQAGAQiNDQBMqWoABRQAAA==.',['�']='誓约胜利之剑:AwAGCAQABRQAAA==.',['�']='超越纣王:AwAGCAsABAoAAA==.',['�']='钴毛头:AwAECAIABRQAAA==.',['�']='镍毛头:AwAFCAIABAoAAQMAAAAECAIABRQ=.',['�']='零多:AwAICAgABAoAAA==.',['�']='鬼鬼:AwAECAIABRQAAA==.',['�']='麦咪和熊熊:AwAFCAQABRQAAA==.',['�']='龙战于野:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end