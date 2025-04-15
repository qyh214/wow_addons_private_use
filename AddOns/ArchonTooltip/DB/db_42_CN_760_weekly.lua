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
 local lookup = {'Hunter-Marksmanship','Shaman-Restoration','Paladin-Retribution','Mage-Fire','Shaman-Elemental','Druid-Balance','Druid-Restoration','Paladin-Holy','Priest-Shadow','Hunter-Survival','Hunter-BeastMastery','Monk-Mistweaver',}; local provider = {region='CN',realm='玛瑟里顿',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ed='Edinburgh:AwAECAgABRQCAQAEAQhqAgBVByEBBRQAAQAEAQhqAgBVByEBBRQAAA==.',Ev='Evangel:AwABCAEABRQAAA==.',Gr='Gracey:AwAICBAABAoAAA==.',Ho='Holylight:AwAECAIABRQAAA==.',In='Infiltration:AwAICCMABAoCAgAIAQgvDgBQNG4CBAoAAgAIAQgvDgBQNG4CBAoAAA==.',Mo='Momosr:AwAGCAwABAoAAA==.',Na='Naiolo:AwAGCAcABRQCAwAFAQj4AQA9VnIBBRQAAwAFAQj4AQA9VnIBBRQAAA==.',Or='Orcwarrior:AwAICAkABAoAAA==.',Pu='Purelove:AwAECAQABRQAAA==.',Ro='Ronaldio:AwACCAIABRQAAA==.',Si='Sick:AwAECAQABRQAAA==.',Wq='Wqzyyds:AwACCAIABAoAAA==.',Xj='Xj:AwABCAEABRQAAA==.',['�']='上帝之手:AwAFCAgABAoAAA==.丑萌:AwAFCAEABAoAAA==.专踹瘸子好腿:AwAICCAABAoCAwAIAQhMJQBMVWsCBAoAAwAIAQhMJQBMVWsCBAoAAA==.丶终景:AwACCAIABRQAAA==.',['�']='亲爱滴鬼鬼:AwABCAEABRQAAQQAI/sECAYABRQ=.',['�']='低端熊猫:AwAHCAsABAoAAA==.',['�']='元素恢复增强:AwADCAQABAoAAA==.先祖忽悠了你:AwAGCAgABAoAAA==.',['�']='冷艳冰焰:AwAECAQABRQAAA==.冷艳流星锤:AwAECAgABRQDAgAEAQhfDQAj2N4ABRQAAgAEAQhfDQAj2N4ABRQABQABAQj0FgAFszoABRQAAA==.冷静莫冲动丶:AwAGCAQABRQAAA==.',['�']='呀吼:AwACCAIABRQAAA==.',['�']='夕凌雪翊:AwAGCAYABAoAAA==.夜影之歌:AwAECAYABRQDBgAEAQjoFAAfRsYABRQABgAEAQjoFAAfRsYABRQABwABAQhDHwABvCUABRQAAA==.大劈叉:AwAFCAUABAoAAA==.天涯若风:AwAICBMABAoAAA==.',['�']='奎师那:AwABCAIABRQCAwAIAQhxEABZksYCBAoAAwAIAQhxEABZksYCBAoAAA==.奥古西斯:AwAECAQABRQAAA==.奥能烧卖:AwAICAMABAoAAA==.',['�']='宋轶:AwAICAgABAoAAA==.',['�']='小小帅种子:AwAFCAIABAoAAA==.小幸运丷:AwAECAQABAoAAA==.',['�']='弹道亦是道:AwAGCAwABAoAAA==.',['�']='德克撒斯:AwAICAMABAoAAA==.',['�']='恶梦猎手:AwAECAQABRQAAA==.',['�']='成功入水:AwAECAQABRQDAwAEAQiiFQA0lO0ABRQAAwADAQiiFQA0lO0ABRQACAABAQjsEgAAAAAABRQAAA==.我考不会吧:AwAICBAABAoAAA==.',['�']='无铭:AwAFCBAABAoAAA==.',['�']='明茉:AwAHCAcABAoAAA==.',['�']='死者意志:AwAGCAsABAoAAA==.死鱼越梦海:AwAICAgABAoAAA==.',['�']='残乂翼:AwAICAgABAoAAA==.',['�']='毛茸毛茸:AwAECAQABRQAAA==.',['�']='泄露天鸡:AwAGCAgABAoAAA==.',['�']='潘爷:AwAECAQABRQAAA==.',['�']='热情随雨:AwAECAQABRQAAA==.',['�']='熊猫创可贴:AwABCAEABAoAAA==.',['�']='牛壮壮丶:AwAECAQABRQAAA==.',['�']='狼里个浪:AwAHCAEABAoAAA==.',['�']='电之殇:AwAECAYABAoAAA==.',['�']='破补丁:AwAICAsABAoAAA==.',['�']='祸害联盟二号:AwAECAQABRQAAA==.',['�']='秋窗风雨夕:AwAGCAUABRQCCQACAQhWFgAqzYEABRQACQACAQhWFgAqzYEABRQAAA==.',['�']='织梦人:AwABCAIABRQAAA==.',['�']='艾斯贝尔:AwAECAQABRQAAA==.',['�']='萌光小蹄子:AwAGCAIABRQAAA==.落叶的安宁:AwAECAQABAoAAA==.',['�']='蒙朱清云:AwAECAQABRQAAA==.',['�']='蓝沢润:AwAECAQABRQAAA==.',['�']='蕾姆:AwAGCAkABAoAAA==.',['�']='薇尔莉特:AwACCAIABRQAAA==.',['�']='超级大兲:AwAECAQABAoAAA==.越狱丶:AwABCAIABRQEAQAIAQj4DABSjUoCBAoAAQAIAQj4DABSjUoCBAoACgAEAQirDwA1gMMABAoACwACAQhV5QAyyTgABAoAAA==.',['�']='跳河淹死的鱼:AwACCAIABRQAAA==.',['�']='迷雾之道:AwAECAQABRQAAQUAVZkICAIABRQ=.',['�']='逗豆:AwAECAoABRQCDAAEAQjdBwBITgkBBRQADAAEAQjdBwBITgkBBRQAAA==.',['�']='醉丶千觞:AwABCAEABAoAAA==.醉丶骑:AwADCAQABRQCAwAIAQgqWgA/AcUBBAoAAwAIAQgqWgA/AcUBBAoAAA==.醉拳高手:AwAICAEABAoAAA==.',['�']='银杏出墙:AwAHCAgABAoAAA==.',['�']='隐姓埋名:AwABCAEABAoAAA==.',['�']='飞高点:AwAGCAYABAoAAA==.',['�']='鸡腿消灭者:AwAICAgABAoAAA==.',['�']='龙卷:AwAECAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end