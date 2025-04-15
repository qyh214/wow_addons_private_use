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
 local lookup = {'Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','Unknown-Unknown','DemonHunter-Any','DemonHunter-Havoc','Monk-Brewmaster','Shaman-Elemental','Shaman-Restoration','Priest-Discipline','DeathKnight-Blood','Monk-Windwalker','Druid-Restoration','Evoker-Devastation','Priest-Holy','Paladin-Retribution','Mage-Fire','Mage-Frost','Monk-Mistweaver','Rogue-Assassination','DeathKnight-Unholy',}; local provider = {region='CN',realm='尘风峡谷',name='CN',type='weekly',zone=42,date='2025-04-14',data={Bd='Bdk:AwACCAIABRQAAA==.',Bi='Biuboom:AwACCAEABRQEAQAIAQi3YgAwBFkBBAoAAQAHAQi3YgAweFkBBAoAAgADAQibEAA+T7EABAoAAwADAQjpVwATbHQABAoAAQQAAAAECAQABRQ=.',Ed='Edith:AwAGCAIABRQCBQACAAgAAAAgzwAABRQABgACAAgAAAAgzwAABRQAAA==.',Lo='Loki:AwAICAgABAoAAA==.',Mi='Miriam:AwABCAEABAoAAA==.',Ot='Otz:AwACCAYABRQCBwACAQh4BQArc3gABRQABwACAQh4BQArc3gABRQAAA==.',['�']='不想做好人:AwAECAQABAoAAA==.不扰清梦:AwAICBAABAoAAA==.丶夕語繁花:AwAICAsABAoAAA==.',['�']='傻墁:AwAFCAUABAoAAA==.',['�']='克里斯开下门:AwACCAMABRQAAA==.',['�']='刑诉法年:AwAECAkABRQDCAAEAQiJAwBJ/Q4BBRQACAADAQiJAwBJ/Q4BBRQACQAEAQjvDQAmgtoABRQAAA==.',['�']='动物园园长:AwAECAQABRQAAA==.',['�']='史蒂芬周:AwAECAQABAoAAA==.',['�']='咪嘻拉面:AwAICBAABAoAAA==.咸鱼突刺:AwABCAEABAoAAA==.',['�']='土豪小脚丫:AwAGCAYABAoAAA==.',['�']='堕落灰烬:AwAECAQABRQAAA==.',['�']='复仇乄新:AwAECAYABAoAAA==.多多嘟嘟:AwAECAQABRQAAA==.多多龙:AwAICAYABAoAAA==.',['�']='安娜贝尔的鱼:AwAECAQABRQAAA==.',['�']='寒凛雨荷:AwAFCAIABAoAAQQAAAAGCAcABAo=.',['�']='小妞嘟嘟:AwABCAEABRQCCgAIAQgYBgBVB6UCBAoACgAIAQgYBgBVB6UCBAoAAA==.小小吗喽:AwAFCAYABAoAAQsAY3oICAoABRQ=.小那星人:AwAFCAgABAoAAA==.少昊:AwAICAwABAoAAQwAIjQHCAkABRQ=.',['�']='岔风:AwAFCAUABAoAAQ0APyYICAsABRQ=.',['�']='巴比隆:AwAICAgABAoAAA==.',['�']='幼天爹:AwABCAMABRQCDgAIAQgGGgA+F7cBBAoADgAIAQgGGgA+F7cBBAoAAA==.',['�']='想做哥哥的零:AwAHCAcABAoAAQoAVQcBCAEABRQ=.',['�']='我尽力了:AwAECAQABAoAAA==.',['�']='折木一茶:AwAICAgABAoAAA==.',['�']='月野兔:AwABCAEABRQAAA==.木木:AwACCAUABRQDCgACAQhJFAAuUowABRQACgACAQhJFAAuUowABRQADwABAQiAGAA++UsABRQAAA==.木瓜吃多了:AwAGCAYABAoAAA==.',['�']='杠上开花:AwAECAQABAoAAA==.',['�']='桃乃木香萘:AwAECAgABRQCEAAEAQhjBABcyDwBBRQAEAAEAQhjBABcyDwBBRQAAA==.',['�']='水無月流歌:AwABCAEABAoAAA==.',['�']='海之子:AwAICAgABAoAAA==.',['�']='潇洒公子:AwAICA8ABAoAAREATAYICA0ABRQ=.',['�']='烨星:AwACCAUABRQCEgACAQgvDgAni4YABRQAEgACAQgvDgAni4YABRQAAA==.烬落:AwAECAQABRQAAQQAAAAGCAQABRQ=.',['�']='熊十三:AwABCAEABAoAAA==.',['�']='狂拽酷霸炫:AwACCAIABAoAAA==.',['�']='猫不易:AwABCAEABRQAAA==.猫十三:AwABCAEABAoAAA==.',['�']='碎地:AwAGCAYABAoAAA==.',['�']='纽扣丢了:AwAICAkABAoAAA==.',['�']='能猫:AwAFCAkABAoAAA==.',['�']='艾斯德斯:AwAICAgABAoAAQQAAAACCAIABRQ=.',['�']='莱斯亚:AwACCAIABRQAAA==.',['�']='菲克纽斯:AwABCAEABAoAAA==.',['�']='蓄意轰拳:AwAICAgABAoAAA==.',['�']='薛迪凯是垃圾:AwABCAEABRQAAA==.',['�']='蛋灬蛋:AwACCAIABRQAAA==.',['�']='行万理路:AwACCAIABAoAAA==.',['�']='贝拉的天鹅:AwACCAQABRQCEwAIAQi8BABbR8sCBAoAEwAIAQi8BABbR8sCBAoAAQQAAAAECAQABRQ=.',['�']='赫尔:AwAECAQABRQAAA==.起了毛球:AwABCAEABAoAAA==.',['�']='車路士:AwAGCAkABAoAAA==.',['�']='部落奸细:AwAGCAYABRQCFAAGAQjHAAAwB7gBBRQAFAAGAQjHAAAwB7gBBRQAAA==.',['�']='阿尔萨新:AwAHCBgABAoDCwAHAQhdJAAt2TgBBAoACwAHAQhdJAAt2TgBBAoAFQAFAQiLdgAd+LEABAoAAA==.',['�']='零魂乄惊雪:AwAGCAYABAoAAA==.',['�']='魔丸丸:AwAGCAYABRQCAQAGAQjLAABCCOkBBRQAAQAGAQjLAABCCOkBBRQAAA==.',['�']='黑昼丶:AwAICAgABAoAAQQAAAAICAQABRQ=.',['�']='龙一风暴狂:AwACCAIABRQAAQ0AOkwGCAUABRQ=.龙之召唤:AwADCAMABRQAAA==.龙希尔:AwAECAQABRQAAQQAAAAGCAQABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end