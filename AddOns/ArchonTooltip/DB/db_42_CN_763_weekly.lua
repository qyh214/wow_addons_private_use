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
 local lookup = {'Shaman-Enhancement','Paladin-Retribution','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Monk-Windwalker','DemonHunter-Vengeance','Priest-Shadow',}; local provider = {region='CN',realm='瑞文戴尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Bi='Bigmo:AwAECAQABRQAAA==.',Ja='Jacob:AwAICAYABAoAAA==.',Ni='Nightwu:AwAICAcABAoAAA==.',Vi='Vivipig:AwAECAQABAoAAA==.',Wm='Wmmwwmmwwmmw:AwADCAMABAoAAA==.',Xx='Xxffwwq:AwAGCAUABAoAAA==.',Ze='Zeus:AwAHCAIABAoAAA==.',['�']='传说的蛋挞:AwAICAgABAoAAA==.',['�']='你是谁的猴:AwABCAIABRQAAA==.',['�']='倾城无双:AwAECAQABRQAAA==.',['�']='凯兰崔尔:AwAICAgABAoAAA==.',['�']='勇者无畏:AwAECAQABRQAAA==.',['�']='危机:AwAGCAcABAoAAA==.',['�']='唠斯特:AwACCAIABRQAAA==.',['�']='喜茶:AwAECAQABRQAAA==.',['�']='姐夰庅覇氣彡:AwAICAIABAoAAA==.',['�']='小棉袄:AwAECAQABAoAAA==.',['�']='幸福的战神:AwAHCAcABAoAAA==.',['�']='恩赐解脫:AwAECAgABRQCAQAEAQh4BwAw2fwABRQAAQAEAQh4BwAw2fwABRQAAA==.',['�']='惩戒之光:AwACCAUABRQCAgACAQg9KgAo+ZIABRQAAgACAQg9KgAo+ZIABRQAAA==.',['�']='我是地精:AwACCAIABRQAAA==.我本无心:AwAFCAEABAoAAA==.',['�']='擱座揚陸姫:AwAECAQABRQAAQMAAAAECAQABRQ=.',['�']='时光之房御:AwACCAIABAoAAA==.',['�']='暮色记忆:AwAICAgABAoAAA==.',['�']='棒棒:AwACCAQABAoAAA==.',['�']='楓飘棂:AwAGCAsABRQDBAAGAQiWBwA2uygBBRQABAAFAQiWBwAk7ygBBRQABQAEAQiqBwA37+gABRQAAQMAAAAICAQABRQ=.',['�']='水水獭:AwABCAEABRQAAA==.',['�']='泓兮化工:AwAECAYABAoAAA==.',['�']='海蓝蓝:AwABCAEABAoAAA==.',['�']='炎枪素笺鸣:AwAECAQABRQAAA==.',['�']='热气哦:AwAECAgABRQCBgAEAQiDDwAzNegABRQABgAEAQiDDwAzNegABRQAAA==.',['�']='熊猫棒子:AwACCAQABRQAAA==.',['�']='猎天使丶蕉男:AwAECAcABRQCBwAEAQjGCQAhgdkABRQABwAEAQjGCQAhgdkABRQAAA==.猫雷最强:AwAECAQABRQAAA==.',['�']='破碎星光:AwAECAQABAoAAA==.',['�']='秋名山老司机:AwAECAwABRQCAgAEAQiNCQBQZhoBBRQAAgAEAQiNCQBQZhoBBRQAAA==.秋風简夜蓉:AwAECAQABRQAAA==.',['�']='緒方理奈:AwAECAQABRQAAA==.',['�']='肉米:AwADCAgABRQCCAADAQhFBgAnnr4ABRQACAADAQhFBgAnnr4ABRQAAA==.',['�']='茶大潘丿:AwADCAUABRQCCQADAQgICwA0NugABRQACQADAQgICwA0NugABRQAAA==.',['�']='角落的尘埃:AwAHCAcABAoAAA==.',['�']='跟师太抢秃驴:AwABCAEABRQAAA==.',['�']='违规昵称:AwAECAQABRQAAA==.',['�']='队友祭天:AwAGCAQABRQAAA==.阿凡猫毛:AwAGCAkABAoAAA==.',['�']='青神雨:AwAECAQABRQAAA==.',['�']='鲁智深:AwAFCAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end