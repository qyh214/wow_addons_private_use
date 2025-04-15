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
 local lookup = {'Unknown-Unknown','Monk-Mistweaver','Druid-Restoration','Druid-Balance','Shaman-Restoration','Shaman-Elemental','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Havoc','Priest-Holy','Priest-Discipline','Priest-Shadow','Shaman-Enhancement','Paladin-Retribution','Paladin-Protection',}; local provider = {region='CN',realm='沙怒',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Asl:AwAGCAsABAoAAA==.',Dd='Ddaaxu:AwABCAEABRQAAA==.',Su='Surplus:AwACCAIABRQAAQEAAAAICAQABRQ=.',Vv='Vvca:AwABCAEABRQAAA==.',['�']='一拳小和尚:AwAICAsABAoAAA==.丩零灬大男人:AwAECAQABRQAAA==.丶嫣嫣焉:AwAICAgABAoAAA==.',['�']='义演顶针:AwAGCAEABAoAAA==.乌镇醇酒:AwAHCA4ABAoAAA==.',['�']='凌乱的虫虫:AwAECAQABRQAAA==.',['�']='只会卖萌:AwAECAQABRQAAA==.叶之眼:AwAGCAYABRQCAgAGAQiGAgASJXABBRQAAgAGAQiGAgASJXABBRQAAA==.',['�']='向右看齐丶:AwABCAEABRQAAA==.吮指脆脆基:AwACCAYABRQDAwACAQjKCgBPqLMABRQAAwACAQjKCgBPqLMABRQABAACAQhYIAAahnwABRQAAA==.',['�']='咸鱼萨:AwAECAsABRQDBQAEAQgOAwBZBTMBBRQABQAEAQgOAwBZBTMBBRQABgABAQhdEwAl9UgABRQAAA==.',['�']='地精真坑爹:AwAGCAQABAoAAA==.',['�']='多乐港:AwAECA4ABRQCBwAEAQjWAwBWEC8BBRQABwAEAQjWAwBWEC8BBRQAAA==.',['�']='奶上天:AwAHCAQABAoAAA==.',['�']='如夢:AwAECAQABRQAAQQAVtkGCAcABRQ=.',['�']='宁戮:AwAFCAQABRQDCAAIAQhSLABaySICBAoACAAHAQhSLABU0yICBAoACQAIAQjWFQBQ9usBBAoAAA==.',['�']='小猪苒:AwABCAEABRQAAA==.小猫菲儿:AwAICAMABAoAAA==.',['�']='带妳私奔:AwAICA8ABAoAAA==.',['�']='幻月丶:AwAECAgABRQCCgAEAQgNCgBJigoBBRQACgAEAQgNCgBJigoBBRQAAA==.',['�']='微笑向暖丶:AwAGCAgABAoAAA==.',['�']='戒烟的说丶:AwACCAIABRQAAA==.',['�']='打脑壳:AwAGCAYABAoAAA==.',['�']='拾忆少女的梦:AwAICA0ABAoAAA==.',['�']='无月丶:AwAECAgABRQDCwAEAQhNCAAlnNkABRQACwAEAQhNCAAlnNkABRQADAAEAQjREAAJsaQABRQAAA==.',['�']='暴躁小伙伴:AwAGCAYABAoAAA==.',['�']='最后的风行者:AwAICAgABAoAAQgAPf8GCAkABRQ=.',['�']='杳无音讯丶:AwADCAMABRQAAQEAAAAICAIABRQ=.',['�']='梵门嗔徒:AwAECAQABRQAAQEAAAAICAMABRQ=.',['�']='棒棒的好二萌:AwAECAYABRQDDQAEAQh1DgAo78wABRQADQAEAQh1DgAo78wABRQACwACAQgQEwAb33oABRQAAQgAIV4GCAYABRQ=.',['�']='满山找牛牛:AwABCAEABRQAAA==.',['�']='灰毫:AwAHCAcABAoAAA==.',['�']='烈焰:AwABCAEABRQAAA==.',['�']='玄程:AwAECAIABAoAAA==.',['�']='电动奶瓶:AwACCAEABRQAAA==.',['�']='疯狂虫子:AwAECAQABRQAAQEAAAAGCAIABRQ=.',['�']='禾酒:AwAHCAEABAoAAA==.',['�']='秦心:AwAICAgABAoAAA==.',['�']='终极电疗:AwAGCAYABRQCDgAGAQgxAgAKsV8BBRQADgAGAQgxAgAKsV8BBRQAAA==.',['�']='翎森:AwAFCAUABAoAAA==.',['�']='联盟统帅:AwACCAIABRQAAA==.',['�']='胡椒乌龙茶:AwAFCAUABAoAAA==.',['�']='脑袋还在:AwADCAoABRQCDwADAQjIEgBDePYABRQADwADAQjIEgBDePYABRQAAA==.',['�']='自然风暴:AwAGCAsABAoAAQEAAAAICAgABAo=.',['�']='血兽来了丶:AwAECAQABRQAAA==.',['�']='见习圣光:AwAGCAYABRQCEAAGAQiLAABC5MEBBRQAEAAGAQiLAABC5MEBBRQAAA==.',['�']='辣肉宗师:AwABCAEABRQCAgAIAQhYBQBcVsQCBAoAAgAIAQhYBQBcVsQCBAoAAQEAAAACCAIABRQ=.',['�']='進魤戰熋:AwABCAEABRQAAA==.',['�']='醉拳甘艿迪:AwACCAIABRQAAA==.',['�']='隔壁老黄:AwABCAEABAoAAA==.',['�']='麦克雷:AwAECAQABRQAAA==.',['�']='龍卷:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end