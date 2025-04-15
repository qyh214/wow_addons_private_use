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
 local lookup = {'Unknown-Unknown','DemonHunter-Vengeance','Priest-Shadow','Priest-Holy','Shaman-Restoration','Mage-Frost','Mage-Fire','Hunter-BeastMastery',}; local provider = {region='CN',realm='盖斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ke='Keyoo:AwACCAIABAoAAA==.',Lu='Luciferss:AwAGCAYABAoAAA==.',Ma='Maii:AwACCAMABRQAAA==.',Na='Navzul:AwADCAMABRQAAQEAAAAECAQABRQ=.',Pe='Pescado:AwAICBIABAoAAA==.',Ti='Tifa:AwACCAIABRQAAA==.',['�']='一撮大胡子:AwAGCAYABAoAAA==.丶养啥死啥:AwAECAQABRQAAA==.丶隐伤:AwAFCAYABAoAAA==.',['�']='你也想起舞吗:AwACCAIABRQAAA==.',['�']='傲剑寒霜:AwACCAYABRQCAgACAQhvDwAJFFcABRQAAgACAQhvDwAJFFcABRQAAA==.',['�']='光影独行:AwAECAQABRQAAA==.',['�']='冥音:AwACCAIABAoAAA==.冷之追毅:AwAICCEABAoDAwAIAQgdIAAwYq8BBAoAAwAIAQgdIAAwYq8BBAoABAAHAQhEJAA5tZoBBAoAAA==.',['�']='南苑南阳:AwAICA4ABAoAAA==.',['�']='可可酱酱:AwAGCAgABAoAAA==.',['�']='咕咕熊:AwAECAQABRQAAA==.',['�']='哀川和彦:AwAFCAEABAoAAA==.',['�']='地狱夫人:AwACCAUABRQCBAACAQjHFAAKcm4ABRQABAACAQjHFAAKcm4ABRQAAA==.',['�']='塞克熊猫:AwADCAUABRQCBQADAQiyBQBFsxQBBRQABQADAQiyBQBFsxQBBRQAAA==.',['�']='天丶空:AwADCAMABAoAAA==.',['�']='尚香尚武:AwAICAgABAoAAA==.',['�']='巴布罗:AwAFCAUABAoAAA==.',['�']='幽幽黎歌:AwAICAgABAoAAA==.',['�']='强力男:AwAICAgABAoAAA==.',['�']='我媳妇欠揍:AwAICAgABAoAAA==.我选择死亡:AwAECAQABRQAAA==.我頭上有犄角:AwAICAgABAoAAA==.或昱或愚:AwACCAQABRQAAA==.戴子玲:AwAFCAoABAoAAA==.',['�']='抓咕大队长:AwAICAgABAoAAA==.',['�']='救救妮妮吧:AwAICAgABAoAAA==.',['�']='无灬花果:AwACCAIABAoAAA==.',['�']='星丶白:AwABCAEABRQAAA==.',['�']='月下小憩:AwACCAMABRQDBgAIAQiTCgBUY5oCBAoABgAIAQiTCgBUY5oCBAoABwABAQgUoQAAAAAABAoAAA==.月隐:AwAFCAcABAoAAA==.末把椅:AwAFCAUABAoAAQgAVO8GCAkABRQ=.',['�']='梦之舞者:AwAECAIABRQAAQcAQ8QICAcABRQ=.',['�']='森羽丶:AwAECAQABAoAAA==.',['�']='汤圆还是汤团:AwAGCAwABAoAAA==.',['�']='沙滩之子:AwAHCBMABAoAAA==.',['�']='涂抹心情:AwABCAEABAoAAA==.',['�']='灬丨天机丨灬:AwAECAQABRQAAA==.灬無丶趣:AwAICAgABAoAAA==.',['�']='焦面包:AwAECAQABRQAAA==.',['�']='熊阿赳赳:AwAECAQABRQAAA==.熟手啤胶员:AwAHCAgABAoAAA==.',['�']='独孤焕:AwABCAEABRQAAA==.',['�']='玖玖捌拾壹:AwAICAgABAoAAA==.',['�']='短腿地板流:AwABCAEABRQAAA==.',['�']='缓冲:AwACCAIABAoAAA==.缥缈:AwAICAgABAoAAA==.',['�']='老爹:AwABCAEABRQAAA==.',['�']='若水纷飞:AwAGCAMABAoAAA==.',['�']='萨一下满了:AwAHCBAABAoAAQEAAAAICBIABAo=.',['�']='西门吹逼:AwACCAIABAoAAA==.',['�']='话梅糖石头人:AwAHCAcABAoAAA==.',['�']='谋黄忠:AwABCAEABAoAAA==.',['�']='贰拾贰:AwAGCA4ABAoAAA==.费伦事安奴:AwAECAQABAoAAA==.',['�']='遥听风铃语:AwACCAIABRQAAA==.遵义燃毛丹:AwAHCAcABAoAAA==.',['�']='那莳的萨苟:AwAICAwABAoAAA==.',['�']='雪伦盖尔:AwABCAEABRQAAA==.',['�']='青疑雪:AwACCAMABRQAAA==.',['�']='风柒:AwAECAQABAoAAA==.',['�']='高坂桐乃:AwABCAEABRQAAA==.',['�']='黑黑煞:AwAICBIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end