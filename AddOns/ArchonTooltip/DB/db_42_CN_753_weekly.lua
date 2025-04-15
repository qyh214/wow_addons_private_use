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
 local lookup = {'Shaman-Restoration','Paladin-Retribution','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Frost','Mage-Frost','Mage-Fire','Hunter-BeastMastery','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Paladin-Protection','Hunter-Marksmanship','Unknown-Unknown','Priest-Discipline','Priest-Holy','Rogue-Assassination','DeathKnight-Blood','Priest-Shadow','DeathKnight-Unholy',}; local provider = {region='CN',realm='爱斯特纳',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ai='Aimee:AwAGCAYABAoAAA==.',Bb='Bbnoe:AwAICAYABAoAAA==.',Do='Dopamine:AwAECAMABAoAAA==.',Ho='Hotwoman:AwAICAUABAoAAA==.',Ma='Marcus:AwAFCAUABAoAAA==.Matts:AwADCAQABAoAAA==.',Mk='Mkml:AwAICAgABAoAAA==.',Pi='Pikapika:AwAICAgABAoAAA==.',Sk='Skullheart:AwAICAcABAoAAA==.',['�']='一姬:AwAGCAYABAoAAA==.上班咯:AwACCAIABAoAAA==.东海:AwADCAMABAoAAA==.丶浮生未歇:AwAICAgABAoAAA==.丷烽火连城丷:AwAGCAkABAoAAA==.丿先祖灬指引:AwAECAQABRQAAA==.丿荣耀灬光辉:AwAECAQABRQAAA==.丿风暴灬酿酒:AwAECAQABRQAAA==.',['�']='仙亦慕红尘:AwAGCAYABAoAAA==.',['�']='伊小蛋:AwAHCAwABAoAAA==.会飞的小胖:AwAGCAgABAoAAA==.会飞的许浩:AwAICAkABAoAAA==.',['�']='傻傻的傻馒:AwACCAcABRQCAQACAQjNFQBEO6MABRQAAQACAQjNFQBEO6MABRQAAA==.',['�']='克里斯汀小七:AwACCAUABRQCAgACAQgzLAAkU40ABRQAAgACAQgzLAAkU40ABRQAAA==.兔脚:AwAICAgABAoAAA==.',['�']='凯伦怀特:AwABCAEABAoAAA==.',['�']='创世神话:AwADCAMABAoAAA==.到底有多难玩:AwAGCAQABRQAAA==.',['�']='千年那天:AwAECAQABRQAAA==.',['�']='双瞳三季稻:AwAFCAMABAoAAA==.',['�']='咩哆哆:AwAECAkABRQDAwAEAQjtBABbNTUBBRQAAwAEAQjtBABbNTUBBRQABAADAQjSCAAYt54ABRQAAA==.',['�']='哈牛:AwAFCAUABAoAAA==.',['�']='唾液王:AwAECAEABRQCBQAIAQiVBABO2XoCBAoABQAIAQiVBABO2XoCBAoAAA==.',['�']='啾咪呀:AwAICAgABAoAAA==.',['�']='嘟小宝的熊猫:AwAECAQABRQAAA==.嘟小宝的萨满:AwAECAQABRQAAA==.',['�']='奶你呢别着急:AwAICAgABAoAAA==.',['�']='娜尼雅:AwABCAEABRQCAQAIAQieEgBIrUwCBAoAAQAIAQieEgBIrUwCBAoAAA==.',['�']='安格隆:AwAICA8ABAoAAA==.安沐拜艾克:AwAECAQABRQAAA==.',['�']='寄半分渴望:AwAHCAoABAoAAA==.寒冰碎片:AwACCAQABRQDBgAIAQipGgA+GgsCBAoABgAIAQipGgA+GgsCBAoABwAHAQhORwAf3UkBBAoAAA==.',['�']='小事呵呵哒:AwAECAQABRQCBgAIAQi4JgA9S78BBAoABgAIAQi4JgA9S78BBAoAAA==.小萨儿:AwAGCAYABAoAAA==.',['�']='希尔瓦纳斯:AwAECAQABAoAAA==.',['�']='库拉:AwAECAEABRQAAA==.',['�']='悦妞:AwABCAEABRQAAA==.',['�']='我只吃素:AwAGCAYABAoAAA==.我是鱼鹅:AwADCAMABRQAAA==.我看你看我:AwAECAQABAoAAA==.',['�']='撩汉大婶:AwAGCAYABAoAAA==.撼地神牛:AwACCAIABAoAAA==.',['�']='敏行慎言:AwAFCAkABAoAAA==.',['�']='星罗:AwABCAEABRQCAgAIAQgvUwA1xdcBBAoAAgAIAQgvUwA1xdcBBAoAAA==.',['�']='暗燃小红:AwACCAQABAoAAA==.',['�']='毛利丶兰:AwAICBoABAoCCAAIAQiMIABMsFoCBAoACAAIAQiMIABMsFoCBAoAAA==.',['�']='江北小鸡:AwABCAEABRQCAgAIAQjcCwBd0N0CBAoAAgAIAQjcCwBd0N0CBAoAAA==.',['�']='沈阳制造:AwAGCAYABAoAAA==.',['�']='法神:AwACCAIABRQAAA==.',['�']='海潮贤者托斯:AwABCAEABRQCAQAIAQg/CQBU4psCBAoAAQAIAQg/CQBU4psCBAoAAA==.海豚有海:AwABCAEABRQAAA==.',['�']='清源:AwAGCAYABAoAAA==.',['�']='潶潶:AwADCAYABRQECQADAQj9EAAsJEUABRQACgABAQidFgAoGkwABRQACwABAQg5JAA3t0UABRQACQABAQj9EAAkm0UABRQAAA==.',['�']='烟雨小熊熊:AwABCAEABRQDAgAIAQi8eAAr030BBAoAAgAHAQi8eAAxcH0BBAoADAABAQilXQAKIg0ABAoAAA==.',['�']='熊胸凶:AwAICAgABAoAAA==.',['�']='爆雨梨花:AwAECAwABRQDDQAEAQiOBABNugUBBRQADQAEAQiOBABNugUBBRQACAAEAQhdHQATqbAABRQAAQ4AAAAICAQABRQ=.',['�']='猫哆哆:AwAECAYABRQDDwAEAQjXBwBKsPgABRQADwAEAQjXBwBKsPgABRQAEAABAQiEGABTjUsABRQAAA==.',['�']='瓦蓝三季稻:AwAFCAUABAoAAA==.',['�']='示斤祷:AwAGCAYABRQCEQAGAQiYAAA6wMoBBRQAEQAGAQiYAAA6wMoBBRQAAA==.',['�']='秘书子:AwABCAEABRQAAA==.',['�']='縌不倒翁:AwAFCAUABAoAAA==.',['�']='红烧大鳄鱼:AwAFCAQABAoAAA==.',['�']='绝对鄙视胖子:AwAECAYABRQDBwAEAQiIHAAzFsMABRQABwAEAQiIHAAa+8MABRQABgACAQhaDwA7F30ABRQAAQcAXAQGCAEABRQ=.绮绮猫:AwAFCAUABRQDDwAFAQiCDwAlubAABRQADwACAQiCDwAihbAABRQAEAADAQg8DgAo7ZkABRQAAA==.',['�']='艾尔特斯:AwABCAEABRQCEgAIAQgPEgA/lPIBBAoAEgAIAQgPEgA/lPIBBAoAAA==.艾蕾什基嘉勒:AwAICBwABAoDDwAIAQi8HAAza7gBBAoADwAIAQi8HAAza7gBBAoAEwAGAQjENwAfYP0ABAoAAA==.',['�']='花花牛哞哞:AwAGCAkABAoAAA==.',['�']='莯红尘:AwAECAgABAoAAA==.',['�']='萨斯利尔:AwAICBkABAoCBQAIAQjnBwBMlxgCBAoABQAIAQjnBwBMlxgCBAoAAA==.',['�']='葬爱你崔哥:AwAECAQABRQAAA==.',['�']='蕊仔零号:AwABCAEABAoAAA==.',['�']='负反馈螺旋:AwAICBkABAoEBQAIAQj5DgApIXwBBAoABQAIAQj5DgAk6nwBBAoAFAAGAQhkZQAb8ewABAoAEgAHAQgjMgAYTtsABAoAAA==.',['�']='达娜夜风:AwABCAEABRQCCAAIAQi3TAAosqEBBAoACAAIAQi3TAAosqEBBAoAAA==.',['�']='还珠格格:AwACCAIABAoAAA==.',['�']='铁马红颜:AwAFCAUABAoAAA==.',['�']='雅雅公主:AwAICAgABAoAAA==.雪山上的汪:AwAICAgABAoAAA==.',['�']='霍森布鲁次:AwAICBYABAoCEQAIAQh/FgAmzqMBBAoAEQAIAQh/FgAmzqMBBAoAAA==.霸魃紅:AwAICBAABAoAAA==.',['�']='风灵月影:AwAICAoABAoAAA==.',['�']='黑色的长鼻象:AwAICAoABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end