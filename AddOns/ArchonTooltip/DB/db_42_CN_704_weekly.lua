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
 local lookup = {'Evoker-Devastation','Evoker-Preservation','Unknown-Unknown','Druid-Balance','Hunter-Marksmanship','Warrior-Fury','Rogue-Outlaw','Rogue-Subtlety','Priest-Discipline','Priest-Holy','Priest-Shadow','Druid-Restoration',}; local provider = {region='CN',realm='暗影迷宫',name='CN',type='weekly',zone=42,date='2025-04-14',data={Cy='Cyka:AwACCAMABRQAAA==.',He='Hellow:AwAFCAUABAoAAA==.',Je='Jean:AwABCAEABRQAAA==.',La='Laa:AwADCAMABAoAAA==.',Os='Oshero:AwAGCAQABRQAAA==.',Sa='Saberr:AwADCAMABAoAAA==.',St='Stella:AwABCAEABRQAAA==.',Ty='Tyro:AwADCBAABRQDAQADAQgXCQA6muYABRQAAQADAQgXCQA6muYABRQAAgADAQjfAwAfELAABRQAAA==.',Vl='Vladivostok:AwAGCAYABAoAAA==.',Zh='Zhhc:AwACCAEABAoAAA==.',['�']='一夢灬絕塵:AwAGCAcABAoAAA==.一得阁拉米:AwAICAEABAoAAQMAAAABCAEABRQ=.一锤捣似:AwADCAQABRQAAA==.不看书的康纳:AwACCAIABRQAAA==.两仪未娜:AwAFCAUABAoAAA==.两炮泯恩仇:AwAECAsABAoAAA==.丨素小匠丨:AwABCAEABAoAAA==.丿闪丨:AwAICAgABAoAAA==.',['�']='乂粒蛋:AwACCAIABRQAAA==.也许是离黎:AwAFCAUABAoAAA==.',['�']='八宝琉璃:AwACCAEABAoAAA==.',['�']='刀丢了我找找:AwAGCAMABAoAAA==.初代千手柱间:AwAICAgABAoAAA==.',['�']='北野武:AwAECAQABRQAAA==.',['�']='半夜洗屁屁:AwAFCAUABAoAAA==.卡鲁克特:AwAECAQABAoAAA==.',['�']='历久成絮:AwACCAQABRQAAA==.',['�']='古杖技奇人:AwACCAEABAoAAA==.',['�']='吉你一下:AwACCAIABRQAAA==.君唇为谁红:AwADCAEABAoAAA==.君子言:AwAICA8ABAoAAA==.',['�']='塔露拉:AwAECAQABRQAAA==.',['�']='大花生:AwACCAIABRQAAA==.',['�']='宿命仑回:AwAICAwABAoAAA==.',['�']='小弥:AwACCAIABRQAAA==.小德仑回:AwACCAIABAoAAA==.小汤圆:AwACCAIABRQAAA==.小泪光:AwAFCAUABAoAAA==.小浣熊搓火球:AwAECAQABRQAAA==.尛童泶:AwABCAEABAoAAA==.',['�']='巫王的罪歌:AwAECAQABAoAAA==.',['�']='帕拉斯:AwAECAUABRQCBAAEAQjGCABI5goBBRQABAAEAQjGCABI5goBBRQAAQUAVdsICAgABRQ=.',['�']='快使用军体拳:AwABCAEABRQAAA==.',['�']='我不会奶啊:AwAGCAwABAoAAA==.我断紫菱:AwACCAQABRQCBgAIAQgZKAAsos0BBAoABgAIAQgZKAAsos0BBAoAAA==.我直接一刀:AwAICBgABAoDBwAIAQjlAABamuACBAoABwAIAQjlAABamuACBAoACAAGAQipFgBE7IQBBAoAAA==.我网真的很卡:AwAHCAcABAoAAA==.',['�']='打野给个蓝:AwAECAQABRQAAA==.',['�']='把把空车:AwAHCA0ABAoAAA==.抽空打点输出:AwAECAQABAoAAA==.',['�']='暗夜黑山:AwACCAIABRQAAA==.',['�']='木木不木:AwAICAgABAoAAA==.',['�']='梨涡浅笑:AwAGCAkABAoAAA==.',['�']='武僧之王:AwAGCAYABAoAAA==.',['�']='泽岚:AwACCAIABRQAAA==.',['�']='派大行:AwAECAQABAoAAA==.',['�']='淑娟:AwAFCAcABAoAAA==.',['�']='火盆烧烤:AwADCAMABAoAAA==.',['�']='牛春兰:AwADCAMABAoAAA==.',['�']='独孤小猎:AwAGCAYABAoAAA==.狼族狂中狂:AwAICAsABAoAAA==.',['�']='玉指擒龙:AwAGCAwABAoAAA==.',['�']='白衣天使:AwAGCAoABRQECQAGAQh+EgA+25YABRQACQADAQh+EgA/N5YABRQACgAEAQgGFAAXpHMABRQACwACAQgXGwAbHE8ABRQAAA==.',['�']='皮老木反:AwACCAIABAoAAA==.',['�']='索林丶橡木盾:AwAGCAwABAoAAA==.',['�']='给我圣疗:AwABCAEABRQAAA==.',['�']='背后大人:AwADCAEABAoAAA==.',['�']='脚滑的骑士:AwABCAEABAoAAA==.',['�']='艾克塞琳:AwACCAMABRQAAA==.',['�']='芋圆:AwAECAQABRQAAA==.',['�']='萌新大头虎:AwAFCAQABAoAAA==.萧瑟仙贝:AwADCAMABAoAAA==.落佑:AwABCAEABRQAAA==.',['�']='西布克:AwAICA4ABAoAAA==.',['�']='赛博企鹅:AwADCAQABAoAAQMAAAAICAwABAo=.起名是真费劲:AwACCAIABAoAAA==.',['�']='踏马德:AwABCAEABRQAAA==.',['�']='蹦蹦跳跳糖:AwABCAEABRQAAA==.',['�']='这瓜多钱一斤:AwAICCMABAoCDAAIAQgAAwBboNECBAoADAAIAQgAAwBboNECBAoAAA==.',['�']='阿寳小將軍:AwAICAYABAoAAA==.',['�']='霹雳小飞侠:AwACCAQABRQAAA==.',['�']='青灯伴佳人:AwACCAIABAoAAA==.',['�']='鬼多是重:AwAECAQABRQAAA==.',['�']='魃魈魑魅魍魉:AwACCAMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end