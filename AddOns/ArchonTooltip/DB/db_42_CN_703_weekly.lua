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
 local lookup = {'DemonHunter-Vengeance','Druid-Balance','Paladin-Retribution','Mage-Fire','Shaman-Restoration','Priest-Healing','Warrior-Arms','DeathKnight-Unholy','DeathKnight-Frost','Monk-Mistweaver','Unknown-Unknown','DemonHunter-Havoc','Hunter-BeastMastery','DeathKnight-Blood','Shaman-Elemental','Priest-Holy','Priest-Discipline','Warrior-Protection','Warrior-Fury','Monk-Windwalker','Rogue-Assassination','Hunter-Marksmanship',}; local provider = {region='CN',realm='暗影议会',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Andreax:AwABCAEABAoAAA==.',Ao='Aomu:AwADCAMABAoAAA==.',Cr='Crushé:AwAGCAEABAoAAA==.',De='Devilgui:AwAGCAEABRQCAQABAQguEwAnpToABRQAAQABAQguEwAnpToABRQAAA==.',Dr='Drevival:AwAFCAMABRQCAgADAQg8BQBXiCYBBRQAAgADAQg8BQBXiCYBBRQAAA==.',Du='Dusttodust:AwACCAIABRQCAwAIAQgmHQBR2owCBAoAAwAIAQgmHQBR2owCBAoAAA==.',Ei='Eillenials:AwAECAgABRQCBAAEAQglBwBX2jYBBRQABAAEAQglBwBX2jYBBRQAAA==.',Ev='Evergrand:AwACCAIABRQCBQAIAQh/CABYSqICBAoABQAIAQh/CABYSqICBAoAAQYAJskGCAYABRQ=.',Jh='Jhmn:AwABCAIABAoAAA==.',Ju='Justcc:AwACCAIABRQAAA==.',Li='Links:AwAHCAcABAoAAA==.',Ma='Marcovaldo:AwADCAcABRQCBwADAQhNBAAuH/UABRQABwADAQhNBAAuH/UABRQAAA==.',Mi='Milo:AwAECAsABAoAAA==.',Pr='Professorfk:AwAICAgABAoAAA==.',Sc='Scotte:AwADCAMABAoAAA==.',Te='Terrylau:AwACCAMABRQAAA==.',Ti='Tiberius:AwABCAIABRQAAA==.',['V�']='Vájra:AwACCAIABRQAAA==.',Zd='Zdge:AwABCAEABAoAAA==.',['�']='万教之父:AwAECAQABRQAAA==.三鹿奶死你灬:AwAICAIABAoAAA==.不恕:AwAECAQABRQAAA==.丶周杰伦丶:AwACCAIABAoAAA==.丶淘淘:AwACCAQABRQAAA==.丶猎:AwAGCAYABAoAAA==.',['�']='么么羊羊殿:AwADCAwABRQCAwADAQjIBwBX5yMBBRQAAwADAQjIBwBX5yMBBRQAAA==.',['�']='互撸寿:AwABCAEABAoAAA==.',['�']='优菈:AwABCAEABRQAAA==.',['�']='你别怕我:AwACCAMABRQDCAAIAQisJABASfsBBAoACAAIAQisJABASfsBBAoACQABAQhSLQBMSjYABAoAAA==.',['�']='儿等看好:AwAHCAgABAoAAA==.',['�']='冰燕麦拿铁:AwAFCAEABAoAAA==.',['�']='凛音:AwAECAQABRQAAA==.',['�']='初夏微风:AwABCAEABRQAAA==.刺猬圣光球:AwAICAYABAoAAA==.',['�']='北风之刃:AwAGCA0ABAoAAA==.',['�']='南拳拳北腿腿:AwAECAcABRQCCgAEAQiABABXDTIBBRQACgAEAQiABABXDTIBBRQAAA==.卡斯兰娜丶蔚:AwAHCAcABAoAAA==.印第安纳琼斯:AwAECAQABAoAAA==.',['�']='发飙的布尔:AwAFCAUABAoAAA==.',['�']='吖丽:AwAECAEABRQAAA==.',['�']='命里有橙:AwACCAIABRQAAA==.',['�']='噬月魔:AwAFCAUABAoAAA==.',['�']='圣灬灵:AwAGCAYABAoAAA==.',['�']='基情在燃烧:AwACCAIABAoAAQsAAAAFCAUABAo=.',['�']='多多香雪:AwAECAcABAoAAA==.大佬丶咪死住:AwAGCAYABAoAAA==.大明陳公公:AwAECAQABRQAAA==.天罡咆哮:AwACCAMABRQAAA==.天边:AwAECAQABRQAAA==.',['�']='好猫:AwAFCAsABAoAAA==.',['�']='妙趣:AwAICCIABAoCBwAIAQiEBABVfbICBAoABwAIAQiEBABVfbICBAoAAA==.妲瓦安娜:AwABCAEABAoAAA==.',['�']='媛妹:AwACCAYABRQCDAACAQjOIQAT1YAABRQADAACAQjOIQAT1YAABRQAAA==.',['�']='安杰利卡语风:AwAFCAUABAoAAA==.宝宝摔倒了:AwAHCAoABAoAAA==.',['�']='小白菜丶:AwAICAwABAoAAA==.少女共赴何方:AwAICAgABAoAAA==.尛尛猎丶:AwAGCAYABRQCDQAGAQilAABI4vQBBRQADQAGAQilAABI4vQBBRQAAA==.',['�']='山之翁:AwAECAIABRQAAQsAAAAGCAQABRQ=.',['�']='巴尔泽布:AwACCAIABRQAAA==.',['�']='年轻不讲武德:AwADCAYABRQCAwADAQjpDABIxAwBBRQAAwADAQjpDABIxAwBBRQAAA==.幻之击坠王:AwAGCAMABRQAAA==.广州灬渣男:AwAICA0ABAoAAA==.',['�']='弗洛赛斯:AwAFCAUABAoAAA==.',['�']='心想肆橙:AwAGCAYABAoAAA==.',['�']='思念的记忆:AwAECBAABRQCDgAEAQiBBgBFF/sABRQADgAEAQiBBgBFF/sABRQAAA==.',['�']='恶灵涅磐:AwABCAEABAoAAA==.',['�']='拉不能拉多:AwACCAUABRQCBAACAQgfJQAnIpEABRQABAACAQgfJQAnIpEABRQAAA==.',['�']='搓奶和尚:AwAECAQABRQAAA==.',['�']='教主的核弹粉:AwAECAgABRQDBQAEAQjoDQAhstsABRQABQAEAQjoDQAhstsABRQADwABAQi8FQAN9z8ABRQAAA==.',['�']='文森特的:AwADCAIABAoAAA==.',['�']='无谓的莎瓦娜:AwAFCAEABAoAAA==.旺旺与花花:AwACCAIABAoAAA==.',['�']='晓糖:AwAFCAUABRQDEAAFAQjNCAA6TdUABRQAEQACAQhtCwBTSdcABRQAEAADAQjNCAAppNUABRQAAA==.',['�']='暖暖丶:AwACCAIABAoAAA==.暮灬暮:AwAHCAEABAoAAA==.',['�']='最爱血小贱:AwAECAQABRQAAA==.月舞之风:AwAGCAcABRQDEgAGAQg4AQAUGysBBRQAEgAGAQg4AQAUGysBBRQAEwABAQhtJwAGrjEABRQAAA==.有視橙子:AwABCAEABAoAAA==.',['�']='梅轩:AwACCAQABAoAAA==.梦丶:AwAICBAABAoAAA==.',['�']='橙德德:AwAICAcABAoAAA==.',['�']='死盳凋零:AwAICAsABAoAAA==.',['�']='波仑伽:AwAFCAUABAoAAA==.波里个浪:AwAECAQABRQAAA==.',['�']='洛阳:AwAECAQABRQAAA==.',['�']='点指冰兵:AwAICAgABAoAARQAIjQHCAkABRQ=.',['�']='爱德华丶艾伦:AwAGCAYABAoAAA==.',['�']='猫瞳双色:AwAICAwABAoAAA==.',['�']='玉面总钻风:AwAECAQABRQAAQgAPpAGCAgABRQ=.玥涵爹:AwAECAYABRQCBAAEAQhkEABI4vUABRQABAAEAQhkEABI4vUABRQAAA==.',['�']='电鸡小子:AwADCAMABAoAAA==.',['�']='白马义从:AwABCAEABRQAAA==.百潕禁忌:AwAFCAUABAoAAA==.',['�']='离焱:AwACCAIABRQAAA==.',['�']='秋裤猫丶:AwAECAQABRQAAA==.',['�']='稚圭:AwAICAgABAoAAA==.',['�']='粉红刹妈酱:AwAGCAcABAoAAA==.',['�']='緋雪:AwACCAIABRQAAA==.',['�']='纯情小喇叭:AwAICAwABAoAAA==.',['�']='绿蚁新醅酒:AwAECA4ABRQCBQAEAQhqAQBh61QBBRQABQAEAQhqAQBh61QBBRQAAA==.',['�']='老大哥看着你:AwAGCAYABAoAAA==.',['�']='肘鸡小子:AwAICAQABAoAAA==.',['�']='艾妮:AwAECAQABRQAAA==.',['�']='芒果丿咬一口:AwAECAQABRQAAA==.',['�']='苍翼:AwAECAIABRQAAA==.若凡:AwACCAMABRQAAA==.',['�']='萌萌的蛋仔:AwAICA4ABAoAARQAIYsICAYABRQ=.',['�']='蓝影龙:AwAECAQABRQAAA==.',['�']='蕾米莉亞:AwADCAoABRQCCQADAQhnAgAeC+MABRQACQADAQhnAgAeC+MABRQAAA==.',['�']='裴南苇:AwAECAQABRQAAA==.',['�']='诡秘之主:AwAGCAEABAoAAQsAAAAICA4ABAo=.',['�']='賊丶椛俚椛筱:AwAGCAYABRQCFQAGAQgmAABU1gkCBRQAFQAGAQgmAABU1gkCBRQAAA==.',['�']='超凡大师:AwAECAQABRQAAQwAMf0GCA4ABRQ=.超恐怖回旋踢:AwAFCAcABAoAAA==.',['�']='转角遇见沵:AwACCAMABRQDDgAIAQi0KgAZ7QoBBAoADgAIAQi0KgAZ7QoBBAoACAACAQjnoAAM8kAABAoAAA==.轻音:AwABCAEABRQAAA==.',['�']='过去的岁月:AwAFCAUABAoAAA==.',['�']='酱汁排骨:AwAECAQABRQAAA==.',['�']='阝丨小默丨丶:AwAHCAEABAoAAA==.阿尔托莉雅:AwACCAIABRQAAQsAAAACCAIABRQ=.阿尼亚丶艾伦:AwACCAcABRQDDQACAQjWIABIIaAABRQADQACAQjWIABIIaAABRQAFgABAQj8FwBGwUsABRQAAA==.阿鲁迪巴:AwACCAIABRQAAA==.',['�']='雨之馨:AwABCAEABRQAAA==.雷鼓:AwAICA8ABAoAAA==.',['�']='霜丶翎:AwAICAgABAoAAA==.',['�']='青烟绕指柔乄:AwACCAIABRQAAQcAS5IGCBAABRQ=.',['�']='顺势而为丶:AwABCAIABRQAAA==.',['�']='颜叁:AwABCAEABRQAAA==.',['�']='风起云转:AwADCAoABRQCAwADAQjODwA/CAEBBRQAAwADAQjODwA/CAEBBRQAAA==.飞翔的蜘蛛:AwABCAEABAoAAA==.飞霄:AwACCAIABRQAAA==.',['�']='骄阳火影:AwABCAEABRQAAA==.',['�']='高贵冷艳傲娇:AwAECAQABRQAAA==.',['�']='鲁克米:AwAICAcABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end