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
 local lookup = {'Paladin-Retribution','Unknown-Unknown','Mage-Fire','Mage-Frost','Warlock-Destruction','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Fury','DemonHunter-Havoc','Druid-Balance','DemonHunter-Vengeance','Druid-Guardian','Paladin-Holy','Paladin-Protection','DeathKnight-Frost','Shaman-Enhancement','Monk-Mistweaver','Monk-Brewmaster',}; local provider = {region='CN',realm='刺骨利刃',name='CN',type='weekly',zone=42,date='2025-04-14',data={Af='Afdjhl:AwACCAYABRQCAQACAQjpJgA7wpwABRQAAQACAQjpJgA7wpwABRQAAA==.',Al='Alstar:AwAGCA8ABAoAAA==.',Ap='Appstore:AwABCAEABAoAAA==.',Cc='Ccrazy:AwAECAEABAoAAA==.',Cl='Clince:AwAECAQABRQAAQIAAAAFCAQABRQ=.',Cr='Crazybird:AwAICBMABAoAAA==.',De='Demonlane:AwAGCAwABRQDAwAGAQi/FQAqFeMABRQAAwAGAQi/FQAiYeMABRQABAACAQjQEgAjFFQABRQAAA==.',Dr='Drow:AwACCAcABRQCBQACAQhGFwAwfJAABRQABQACAQhGFwAwfJAABRQAAA==.',Ho='Homelander:AwAECAgABRQDBgAEAQhKCAA6pgIBBRQABgAEAQhKCAA6pgIBBRQABwAEAQi6EQARDYsABRQAAA==.',Ju='Junne:AwAICAgABAoAAA==.',Ms='Mshadows:AwAECAcABRQCCAAEAQgABwBN1hgBBRQACAAEAQgABwBN1hgBBRQAAA==.',Ni='Nishuo:AwAHCAkABAoAAA==.',Nu='Nuclear:AwAECAIABAoAAA==.',Ta='Takachiko:AwAECAoABRQCCQAEAQiQBQBXOi4BBRQACQAEAQiQBQBXOi4BBRQAAA==.',Wh='Whyzd:AwAICAYABAoAAA==.',Xi='Xiaofdly:AwEECA4ABRQCCgAEAQhKBQBZ0SYBBRQACgAEAQhKBQBZ0SYBBRQAAA==.',['�']='七月的云:AwABCAEABRQAAA==.',['�']='云柒:AwAFCAQABAoAAA==.',['�']='以圣光之名:AwAICAgABAoAAA==.',['�']='伊箭傾心:AwACCAIABRQAAA==.伦落街尾:AwACCAQABRQAAA==.',['�']='你家叁哥:AwAFCAQABAoAAA==.',['�']='克里斯提娜丶:AwAGCAYABAoAAA==.',['�']='冰雪飛灵:AwACCAIABRQAAA==.冰霜死骑:AwAGCAIABAoAAA==.',['�']='南风知我忆:AwAICAEABAoAAA==.',['�']='只求一胜:AwAECAQABRQAAA==.',['�']='吞天:AwACCAIABRQAAA==.',['�']='周三下午茶:AwADCAUABAoAAA==.',['�']='囯产零零久:AwAHCCAABAoDBgAHAQjSHABTcy0CBAoABgAHAQjSHABTcy0CBAoABwABAQivYwAAAAAABAoAAA==.',['�']='國产零零久:AwAICCMABAoDCwAIAQjXCABN5mgCBAoACwAIAQjXCABN5mgCBAoACQAIAQgyLQA63NoBBAoAAA==.地狱维纳斯:AwAFCAUABAoAAA==.',['�']='天佑昕辰:AwACCAIABRQAAA==.',['�']='奥戳胩:AwABCAEABRQAAA==.',['�']='如丿初:AwAECAQABAoAAA==.',['�']='害羞的番茄:AwAECAgABAoAAA==.',['�']='尐白杨:AwAGCAYABAoAAA==.尒寶赑:AwAFCAEABAoAAA==.',['�']='帝月晨风:AwACCAMABRQCCAAIAQihBQBaidgCBAoACAAIAQihBQBaidgCBAoAAA==.',['�']='库巴:AwABCAEABRQAAA==.',['�']='彳亍:AwACCAIABAoAAA==.',['�']='我当然是法神:AwACCAYABRQCAwACAQiaIwA1PpYABRQAAwACAQiaIwA1PpYABRQAAA==.',['�']='抱着你冲锋:AwABCAEABAoAAA==.',['�']='斷點:AwAICBkABAoCDAAIAQhyDgAi6SEBBAoADAAIAQhyDgAi6SEBBAoAAA==.',['�']='无所谓好与坏:AwABCAIABRQAAA==.无敌嘲讽:AwAICBYABAoEAQAIAQiINgBMzioCBAoAAQAIAQiINgBMzioCBAoADQAGAQgTJAA7WQQBBAoADgABAAgAAAABAAAABAoAAA==.',['�']='暗夜之明月:AwADCAQABAoAAA==.暮雨亦成诗:AwAICAgABAoAAA==.',['�']='曝光:AwAECAQABRQAAA==.',['�']='柒暮:AwAGCAYABAoAAA==.',['�']='桃枝妖妖安妮:AwAICAgABAoAAA==.',['�']='武器大师断角:AwAICBIABAoAAA==.死亡代理者:AwAICBQABAoCDwAIAQhNCAA/lgwCBAoADwAIAQhNCAA/lgwCBAoAAA==.死肥仔:AwACCAIABRQCEAAIAQiiEQA+4DACBAoAEAAIAQiiEQA+4DACBAoAAA==.',['�']='毕业季的忧桑:AwAGCAYABAoAAA==.',['�']='汐墨:AwAECAQABRQAAA==.',['�']='沐筱筱:AwAFCAUABAoAAA==.',['�']='淡定的法:AwAGCAYABAoAAA==.',['�']='炫舞逸尘:AwAECAcABAoAAA==.',['�']='烅皇:AwAECAgABRQCEQAEAQh7CwA1fOwABRQAEQAEAQh7CwA1fOwABRQAAA==.',['�']='版本之子:AwAHCAsABAoAAA==.牛哞哞灬:AwAECAQABRQAAQIAAAAICAIABRQ=.牛眼流牛油:AwAECAQABRQAAQIAAAAGCAQABRQ=.物华依旧:AwADCAMABAoAAA==.',['�']='瑪维斯:AwAICAEABAoAAA==.',['�']='睡也无聊:AwAGCAwABAoAAA==.',['�']='窠樂:AwAECAQABRQAAA==.',['�']='繁花梦落:AwAHCAcABAoAAA==.',['�']='翻滚屁屁:AwAECAQABRQCEgAIAQhrDAAzalgBBAoAEgAIAQhrDAAzalgBBAoAAA==.',['�']='胖胖的糯米鸡:AwADCAMABAoAAA==.',['�']='落阿昆达:AwAFCAUABAoAAA==.',['�']='蓝羽浅葱:AwAICAgABAoAAA==.',['�']='藽吻:AwAGCAYABAoAAA==.',['�']='虫二:AwAECAQABAoAAA==.',['�']='西瓜和我们:AwAECAQABRQAAA==.',['�']='超雄患者老胡:AwACCAIABRQAAA==.',['�']='跳跃之咒:AwACCAIABRQAAA==.',['�']='轻语:AwAHCAsABAoAAA==.',['�']='雨中邂逅:AwAICA8ABAoAAA==.',['�']='霜冷爱上:AwABCAEABRQAAA==.',['�']='靁电法王:AwADCAQABAoAAA==.',['�']='飞翔的蚂蚁:AwAECAQABRQAAQYATVQGCAoABRQ=.',['�']='黄梅天的黄昏:AwAHCAsABAoAAA==.黑锋领主:AwABCAIABRQAAA==.',['�']='齐命:AwAECAkABRQCCAAEAQhwBABYzy8BBRQACAAEAQhwBABYzy8BBRQAAA==.',['�']='龍丿貓:AwAICAEABAoAAQIAAAACCAIABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end