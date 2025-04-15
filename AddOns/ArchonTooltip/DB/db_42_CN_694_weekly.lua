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
 local lookup = {'Warrior-Fury','Warrior-Arms','Unknown-Unknown','Evoker-Devastation','Hunter-Survival','Hunter-Marksmanship','Priest-Holy','Hunter-BeastMastery','Shaman-Restoration','Warrior-Protection','Druid-Restoration','Druid-Balance','Druid-Guardian','Shaman-Any','Shaman-Enhancement','Mage-Fire','Shaman-Elemental','Paladin-Retribution','DeathKnight-Blood','DemonHunter-Vengeance','DeathKnight-Unholy','Evoker-Preservation',}; local provider = {region='CN',realm='摩摩尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ca='Carlota:AwAICA8ABAoAAA==.',Ce='Cele:AwAICAgABAoAAA==.',Ev='Evilmaster:AwAICBkABAoDAQAIAQjMFABJwksCBAoAAQAIAQjMFABJwksCBAoAAgACAQgLWwA2tjMABAoAAA==.Evilputrefy:AwAICA8ABAoAAA==.',Fe='Feifei:AwAFCAUABAoAAA==.',Fo='Forrest:AwAECAQABRQAAA==.',Rl='Rlo:AwAICAgABAoAAA==.',So='Somnusy:AwADCAMABAoAAA==.',St='Starssea:AwAFCAUABAoAAA==.',Su='Sunwarrior:AwABCAEABRQAAA==.',Wi='Winner:AwAECAQABRQAAA==.',['�']='丨心碎灬丨:AwADCAMABAoAAA==.丨米奈希尓丨:AwAGCAwABAoAAA==.',['�']='伊莉丝:AwAFCAMABAoAAQMAAAAGCAkABAo=.',['�']='侃爷:AwAICAgABAoAAA==.',['�']='俞瑜:AwAGCA0ABAoAAA==.',['�']='冰镇草莓酸奶:AwACCAIABRQAAA==.',['�']='凤凰翎:AwAICAgABAoAAA==.',['�']='南征北战:AwABCAEABRQAAA==.',['�']='叉歪歪:AwAHCAYABAoAAA==.可雕之木:AwAECAQABAoAAA==.右岸:AwABCAEABRQAAA==.',['�']='哟湿幽盅:AwACCAMABAoAAA==.',['�']='唐伯虎猎风:AwABCAIABRQAAA==.',['�']='啤酒肚:AwACCAIABAoAAA==.',['�']='嘉德丽雅:AwAECAgABRQCBAAEAQiJBABXLCIBBRQABAAEAQiJBABXLCIBBRQAAA==.',['�']='夏天的热浪:AwAECAQABRQAAA==.夏娃冰梦缘:AwAICBAABAoAAA==.外瑞咕德:AwAHCAcABAoAAA==.夜深人静想你:AwACCAIABRQAAA==.天啸丶:AwAGCAwABAoAAA==.天堂荣耀:AwAGCAEABAoAAA==.天秤座童虎:AwAGCA4ABAoAAQUALTkCCAgABRQ=.失控的灵魂:AwADCAMABAoAAA==.',['�']='奥尔多安:AwAGCAcABAoAAA==.',['�']='妮尔塔莉:AwAFCAUABAoAAA==.',['�']='室女座释静摩:AwACCAIABRQCBAAIAQhIEABF3iMCBAoABAAIAQhIEABF3iMCBAoAAQUALTkCCAgABRQ=.',['�']='射卜准:AwAECAQABAoAAA==.射手座格式塔:AwACCAgABRQDBQACAQilAgAtOVkABRQABgACAQjpEgAidH8ABRQABQABAQilAgBD31kABRQAAA==.小奶狼死哪了:AwAECAEABAoAAA==.小损样儿:AwABCAEABAoAAA==.小灬龙:AwAICAgABAoAAA==.小铭铭:AwAGCAYABAoAAA==.少琛:AwAICAgABAoAAA==.尼古拉斯凯骑:AwACCAIABRQAAA==.',['�']='希尔瓦娜澌:AwAGCAwABAoAAA==.希希不会飞:AwAICAgABAoAAA==.',['�']='幽默小黄人:AwACCAIABAoAAA==.',['�']='弈秋丶:AwABCAEABAoAAA==.张继科:AwAHCAQABAoAAA==.',['�']='影忄殇:AwAICBEABAoAAA==.影月:AwAICBYABAoCBwAIAQj5GAA8i+YBBAoABwAIAQj5GAA8i+YBBAoAAA==.',['�']='德咕啦:AwAFCA0ABAoAAA==.',['�']='懒惰:AwABCAEABAoAAA==.',['�']='我爱丶娜娜:AwAGCHcABAoCCAAGAQheOABYkO0BBAoACAAGAQheOABYkO0BBAoAAA==.',['�']='拨皮双子:AwAICAoABAoAAA==.',['�']='携秋水揽星河:AwAICAYABAoAAQkAMpYGCAUABRQ=.',['�']='摩可可:AwABCAIABRQAAA==.摩柯柯:AwACCAIABRQAAA==.',['�']='无效快速防秃:AwAICAIABRQAAA==.',['�']='星空泪痕:AwAECAQABRQAAA==.',['�']='晓法:AwABCAEABAoAAA==.',['�']='暴怒丶:AwABCAIABRQCCgAHAQh/FAAtM0UBBAoACgAHAQh/FAAtM0UBBAoAAA==.',['�']='曉宇:AwABCAIABRQECwAHAQi0SAAaDMAABAoACwAGAQi0SAAab8AABAoADAAEAQjcdwAyB64ABAoADQAEAQgAIAAdI2IABAoAAA==.',['�']='木木大魔王:AwAICAgABRQCDgAIAAgAAAA7iAAABRQADwAIAAgAAAA7iAAABRQAAA==.',['�']='杀戮死骑:AwAFCAUABAoAAA==.杀戮骑士:AwAGCAEABAoAAA==.李火旺:AwABCAEABAoAAA==.',['�']='梦追梦:AwACCAIABRQCEAAIAQhfKgA3DekBBAoAEAAIAQhfKgA3DekBBAoAAA==.',['�']='灬妖牧灬:AwAGCAYABAoAAA==.灬妖骑灬:AwAECAQABAoAAA==.灬腾云蛟日灬:AwACCAIABRQAAA==.灵魂丶冰糖:AwADCAMABAoAARAAQ8QICAcABRQ=.灵魂丶彼岸:AwAECAgABRQCCAAEAQgKEwA37+0ABRQACAAEAQgKEwA37+0ABRQAAA==.',['�']='烟鬼:AwACCAIABAoAAA==.',['�']='熊猫灬小妞:AwABCAIABRQCEQAHAQinMAAk7EEBBAoAEQAHAQinMAAk7EEBBAoAAA==.',['�']='爱吃烤红薯:AwAICAgABAoAAA==.',['�']='狸狸原上跑:AwACCAIABRQAAA==.',['�']='猫已经肥了:AwABCAIABRQAAA==.',['�']='瓦莉拉妲己:AwAECAQABAoAAA==.',['�']='白羊丶:AwABCAEABRQAAA==.',['�']='祠梦余生:AwAGCAYABAoAAA==.',['�']='竖丶:AwAECAQABRQAAA==.',['�']='莫莫灬:AwAHCAcABAoAAA==.',['�']='菩提小精灵:AwABCAEABRQCEgAIAQi1FABaP7ICBAoAEgAIAQi1FABaP7ICBAoAAA==.菩提精灵:AwACCAIABRQAAA==.',['�']='落单被抡:AwACCAIABRQAAA==.',['�']='裴珠泫:AwACCAIABRQAAQ8APEQGCAgABRQ=.',['�']='贰爷:AwAFCAYABAoAAA==.',['�']='赟小狐:AwAECAQABAoAAA==.',['�']='辉煌嗳呦喂:AwADCAUABAoAAA==.',['�']='迪菲亚渗透者:AwAGCAUABRQCEwAFAQgjCgAOnMgABRQAEwAFAQgjCgAOnMgABRQAAA==.',['�']='邪能之骑士:AwACCAIABRQCEgAIAQiHVABODdQBBAoAEgAIAQiHVABODdQBBAoAAA==.',['�']='钢丝床:AwACCAYABRQCFAACAQhUCwA3xYEABRQAFAACAQhUCwA3xYEABRQAAA==.',['�']='飞天小女警:AwAHCAcABAoAAA==.',['�']='骑猪泡软妹:AwAECAQABRQAAA==.骑猪看世界:AwADCAMABRQAAQMAAAAECAQABRQ=.骑猪遛大象:AwAHCAcABAoAAQMAAAAECAQABRQ=.',['�']='鬼雨墨山:AwAGCBMABAoAAA==.',['�']='鮮血哀川凜:AwAFCAgABAoAAA==.',['�']='鲨鱼饵丶:AwACCAYABRQCFQACAQjDEwA/eaoABRQAFQACAQjDEwA/eaoABRQAAA==.',['�']='鸡脚男:AwAFCAEABAoAAA==.',['�']='龍希尔:AwAECAgABRQDFgAEAQiQAABb6kABBRQAFgADAQiQAABb6kABBRQABAACAQioGQAcPjQABRQAAA==.龙之随风:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end