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
 local lookup = {'Paladin-Retribution','Warlock-Destruction','Warlock-Demonology','Monk-Windwalker','Unknown-Unknown','Rogue-Subtlety','Warrior-Protection','DemonHunter-Havoc','Shaman-Restoration','Hunter-Marksmanship','Rogue-Assassination','Priest-Shadow','Priest-Discipline','Priest-Holy','Warrior-Fury','Paladin-Protection','Druid-Restoration','Warlock-Affliction',}; local provider = {region='CN',realm='希雷诺斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ag='Agonist:AwAFCAUABAoAAA==.',Ch='Chromie:AwAECAQABRQAAA==.',Cq='Cq:AwABCAEABRQAAA==.',De='Deathknigh:AwAECAQABAoAAA==.',Er='Erukidu:AwAHCAcABAoAAA==.',Ge='Gelina:AwABCAEABRQAAA==.',Lt='Lt:AwAICA0ABAoAAA==.',Md='Mdsg:AwADCAUABAoAAA==.',Mo='Morewant:AwAECAQABRQAAA==.',Pa='Pano:AwABCAEABAoAAA==.',Re='Rexsar:AwACCAEABAoAAA==.',We='Wealth:AwADCAYABRQCAQADAQihBwBOXiMBBRQAAQADAQihBwBOXiMBBRQAAA==.',Zl='Zlatan:AwAICAIABAoAAA==.',['�']='一小唯一:AwAECAEABRQDAgAIAQg/IwBHi9wBBAoAAgAHAQg/IwBFWtwBBAoAAwADAQhGLwBFM+IABAoAAA==.一根儿葱:AwACCAIABAoAAA==.一种数值的美:AwAICAwABAoAAA==.七夜狂风:AwABCAEABRQAAA==.七肆贰:AwABCAEABRQAAA==.不变的爱:AwACCAIABRQAAA==.专业吻戏演员:AwABCAEABAoAAA==.丨欧麦尬德丨:AwAICAgABAoAAA==.丨燃烧语灵丨:AwABCAEABRQAAQQAUdcBCAIABRQ=.丨燃烧语风丨:AwABCAIABRQCBAAIAQjkDwBR10wCBAoABAAIAQjkDwBR10wCBAoAAA==.丨罹梦丨:AwADCAIABRQAAA==.丨陸丨:AwABCAEABRQAAQUAAAADCAIABRQ=.丶王怼怼:AwABCAEABRQAAA==.',['�']='伤心小蜘蛛:AwAECAQABRQAAA==.',['�']='全球变暖:AwAECBIABRQCBgAEAQiTAgBXqicBBRQABgAEAQiTAgBXqicBBRQAAA==.公子小宝:AwAHCAsABAoAAA==.',['�']='努力的小阿依:AwAHCAcABAoAAA==.',['�']='勃艮第:AwAGCAYABAoAAA==.',['�']='北極星的眼淚:AwAGCAMABAoAAQUAAAAHCAQABRQ=.',['�']='千岚逐枫者:AwACCAIABAoAAA==.',['�']='只有中杯大杯:AwAICA4ABAoAAA==.',['�']='呼吸衰竭:AwAECAQABRQAAA==.',['�']='哎呦我肾掉了:AwAICAgABAoAAA==.',['�']='四六炮灬:AwABCAEABRQCAgAIAQg6HgA+dfoBBAoAAgAIAQg6HgA+dfoBBAoAAA==.回忆之刃:AwACCAUABRQCBwACAQhNCAAIg1gABRQABwACAQhNCAAIg1gABRQAAA==.',['�']='圣光之刃:AwABCAEABRQAAA==.',['�']='大菊观丶:AwAECAQABRQAAA==.',['�']='如汤沃雪:AwAGCBIABRQCCAAGAQjfAABDtOYBBRQACAAGAQjfAABDtOYBBRQAAA==.',['�']='宝矿力:AwADCAMABRQAAA==.',['�']='小乖:AwABCAEABAoAAA==.小小胡丶:AwACCAEABRQAAA==.小小萨来也:AwACCAIABRQCCQAIAQgqDgBQAm8CBAoACQAIAQgqDgBQAm8CBAoAAA==.小胡莉:AwAHCAYABAoAAA==.小萨鲁法尔:AwAGCAIABAoAAA==.小雪碧丶:AwAECAQABRQCCgAIAQiWDgBZjTYCBAoACgAIAQiWDgBZjTYCBAoAAA==.尼古丁男爵:AwAFCAcABAoAAA==.尼古丁针:AwADCAMABAoAAA==.',['�']='屁屁看这裏:AwAECBAABRQDCwAEAQgSAgBffz4BBRQACwAEAQgSAgBYej4BBRQABgADAQjfAQBdyDsBBRQAAA==.',['�']='岑风暴烈久:AwACCAEABAoAAA==.',['�']='巧巧妈妈:AwAICA0ABAoAAA==.',['�']='幽灵菇传说:AwADCAEABAoAAA==.',['�']='弗拉基米尔:AwACCAIABRQAAA==.',['�']='心思云梦:AwACCAIABRQAAA==.快乐的小母牛:AwAECAQABRQAAA==.',['�']='想抓个小德:AwAICAEABRQAAA==.',['�']='憨憨德:AwAICAQABAoAAA==.',['�']='手提酱油:AwADCAIABAoAAA==.',['�']='抗怪专用:AwAICAUABAoAAA==.',['�']='摩挲楚殇:AwAGCAoABRQDDAAGAQhSAgAsWYoBBRQADAAGAQhSAgAsWYoBBRQADQAEAQjABABIfR0BBRQAAQ0AUX4ICAMABRQ=.',['�']='暖暖幸福:AwABCAEABRQCAQAIAQj+EwBcpbUCBAoAAQAIAQj+EwBcpbUCBAoAAA==.暗夜小牧:AwAECAgABRQCDgAEAQj/AwBDZgkBBRQADgAEAQj/AwBDZgkBBRQAAA==.',['�']='木婉清:AwAECAQABRQAAA==.',['�']='来几个:AwAFCAUABAoAAA==.杭州小笼包:AwAHCAEABAoAAA==.',['�']='汐釉乄:AwAECAYABRQCAQAEAQidEgBEHfcABRQAAQAEAQidEgBEHfcABRQAAA==.',['�']='泡泡味进口糖:AwAECAQABRQAAQUAAAAICAQABRQ=.',['�']='流云乱:AwACCAIABRQAAA==.浪哩个狼:AwABCAEABAoAAA==.',['�']='漠漠暗香如云:AwADCAMABRQAAA==.',['�']='焚寂诀:AwACCAIABRQAAA==.然懿:AwACCAMABRQDDwAIAQhaCQBcCq8CBAoADwAIAQhaCQBcCq8CBAoABwACAQitJgBCYZkABAoAAA==.',['�']='牛牛也圣光:AwAFCAMABAoAAA==.',['�']='王安全:AwAECAQABRQAAA==.',['�']='秋咪不吃鱼:AwAGCAEABAoAAA==.',['�']='米米大魔王:AwAICBUABAoDAQAIAQjmIQBSoXgCBAoAAQAIAQjmIQBSoXgCBAoAEAABAQjiXQAKAQ0ABAoAAA==.',['�']='繁华丶若梦:AwAICAMABAoAAA==.繁花:AwACCAIABRQAAA==.',['�']='美少年萨满:AwAECAQABRQAAREAOkwGCAUABRQ=.',['�']='舒肝解郁:AwAICAgABAoAAA==.舞夜灬妙音:AwACCAIABAoAAA==.',['�']='虹霁:AwAECAQABRQAAA==.',['�']='言夏:AwAGCAYABAoAARIAQvcGCAkABRQ=.',['�']='诛心:AwAECAQABRQAAA==.',['�']='超大只哈吉米:AwAICAEABAoAAA==.足疗纳入医保:AwAGCAYABAoAAA==.',['�']='轻云蔽月:AwAECAQABRQAAA==.',['�']='达叔还没上车:AwAICA0ABAoAAA==.',['�']='近战核弹:AwAGCAkABAoAAA==.进击的圣骑:AwACCAIABRQAAA==.',['�']='醉酒红尘:AwADCAQABRQAAA==.',['�']='釨鏶鈼鉒:AwAFCAEABAoAAA==.',['�']='铁树该鷥:AwABCAEABRQAAA==.',['�']='锋锋:AwABCAIABRQAAA==.',['�']='阿兰:AwABCAEABRQAAA==.',['�']='霹雳五连鞭:AwAECAQABRQAAA==.',['�']='青青西红柿:AwACCAIABRQAAA==.',['�']='风岚飞雪:AwAECAUABRQCDAAEAQiNCQA95/QABRQADAAEAQiNCQA95/QABRQAAA==.风暴滋生:AwADCAMABRQAAA==.风魔:AwABCAEABRQAAA==.',['�']='香草七:AwAFCAUABAoAAA==.',['�']='齐德龙东强:AwAECAQABAoAAQUAAAAGCAEABAo=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end