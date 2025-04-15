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
 local lookup = {'Druid-Guardian','Mage-Fire','Shaman-Restoration','Shaman-Elemental','Monk-Mistweaver','Hunter-Survival','Evoker-Preservation','Evoker-Devastation','Unknown-Unknown',}; local provider = {region='CN',realm='艾维娜',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ca='Cappuc:AwAFCAUABAoAAA==.',Cl='Closer:AwAGCAoABAoAAA==.',Dd='Ddhmy:AwAGCAQABAoAAA==.',Ph='Phr:AwABCAEABAoAAA==.',Ro='Rose:AwAECAQABRQAAA==.',Su='Suzu:AwAECAQABRQAAA==.',Un='Unossy:AwACCAIABRQAAA==.',['�']='今汐:AwAECAQABAoAAA==.',['�']='凤凰山下:AwAECAQABRQAAA==.',['�']='卡卡诺斯:AwABCAEABRQAAA==.',['�']='叶律云:AwAECAQABRQAAA==.',['�']='吮指原味咕:AwACCAIABRQCAQAIAQjFBgA/+PABBAoAAQAIAQjFBgA/+PABBAoAAA==.',['�']='大天使夜叉:AwADCAMABRQAAA==.天才靓仔萧萧:AwACCAIABRQAAA==.',['�']='奥斯卡丶尊龙:AwACCAIABRQAAA==.好脾气的我:AwACCAIABRQAAA==.',['�']='妳的样子:AwAECAQABRQAAA==.',['�']='守护阿梅:AwACCAIABAoAAA==.',['�']='小兔吃狼:AwAICAwABAoAAA==.尾随伏击骑:AwAICBAABAoAAA==.',['�']='想站在彩虹上:AwAGCAUABRQCAgAEAQhvHAAk1tIABRQAAgAEAQhvHAAk1tIABRQAAA==.',['�']='我不信圣光:AwAECAQABAoAAA==.我爱小罗卜:AwAECAQABRQDAwAIAQjhKwBYArsBBAoAAwAIAQjhKwBYArsBBAoABAACAQi4bQASB0UABAoAAA==.',['�']='托夫:AwABCAEABAoAAA==.',['�']='棉花糖的爱:AwAHCAoABAoAAA==.',['�']='潇洒姿态:AwAECAQABAoAAA==.',['�']='瓜宝:AwADCAMABRQAAA==.',['�']='禾木:AwAFCAUABAoAAA==.',['�']='窗外的梦:AwADCAgABRQCBQADAQjrBwBGOBABBRQABQADAQjrBwBGOBABBRQAAA==.',['�']='管仲:AwACCAQABRQCBgAIAQgXAwBQfVoCBAoABgAIAQgXAwBQfVoCBAoAAA==.',['�']='耀光改二甲:AwACCAUABRQDBwACAQg5BgAoL3sABRQABwACAQg5BgAoL3sABRQACAABAQjEGAAm4kQABRQAAA==.',['�']='舒畅:AwAGCAYABAoAAA==.',['�']='还是坏蛋:AwABCAEABAoAAQkAAAAECAQABRQ=.',['�']='醉里挑燈看箭:AwAECAQABRQAAA==.',['�']='锅子:AwAGCAYABAoAAA==.',['�']='阿道夫洗发水:AwAECAQABAoAAA==.',['�']='陆文希灬万万:AwAHCAoABAoAAA==.陈陈风暴烈酒:AwACCAIABAoAAA==.',['�']='黄牛:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end