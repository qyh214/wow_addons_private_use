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
 local lookup = {'Unknown-Unknown','Warrior-Fury','Paladin-Retribution','DeathKnight-Blood','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Warlock-Demonology','DeathKnight-Unholy','DeathKnight-Frost','DemonHunter-Havoc','Priest-Holy','Warrior-Arms','Priest-Shadow','Priest-Discipline','Evoker-Devastation','Shaman-Enhancement','Monk-Windwalker','Mage-Frost','DemonHunter-Vengeance','Mage-Fire','Druid-Guardian','Druid-Feral',}; local provider = {region='CN',realm='霍格',name='CN',type='weekly',zone=42,date='2025-04-15',data={Bi='Bigrain:AwAECAQABRQAAQEAAAAICAQABRQ=.',Ch='Christer:AwAECAoABRQCAgAEAQiMDQAypPgABRQAAgAEAQiMDQAypPgABRQAAA==.',Em='Emilye:AwAFCAcABAoAAA==.',Kh='Khrushchev:AwABCAEABRQAAA==.',Ki='Kioe:AwAICAQABAoAAA==.',Pa='Padre:AwAECAgABRQCAwAEAQhWGAA5Iu0ABRQAAwAEAQhWGAA5Iu0ABRQAAA==.Pandoo:AwABCAEABAoAAA==.',Pd='Pdl:AwAICAgABAoAAA==.',Po='Ponyoo:AwAFCAUABAoAAA==.',Qi='Qioe:AwACCAIABAoAAA==.',Sh='Shownor:AwAECAQABRQAAA==.',Sm='Smallrain:AwADCAMABAoAAA==.',Va='Vampirecain:AwAECAgABRQCBAAEAQhCDgAozrEABRQABAAEAQhCDgAozrEABRQAAQQAG0UGCAYABRQ=.Vanhelsing:AwAFCAgABRQCAgAEAQiPBwBRQxgBBRQAAgAEAQiPBwBRQxgBBRQAAQIAMosICAkABRQ=.',['�']='一宸:AwAECAYABRQDBQAEAQgwEgA/NvgABRQABQAEAQgwEgA/NvgABRQABgACAQgcGAAQQmUABRQAAA==.一眼顶真:AwAICAcABAoAAA==.一笑一尘缘:AwAECAYABAoAAA==.七海千秋丶:AwAFCAUABAoAAA==.三木曰一先生:AwAICBYABAoDBwAIAQgJBwBbk7MCBAoABwAIAQgJBwBZjrMCBAoACAAEAQhOLQBKOfoABAoAAA==.三色喵:AwAGCAYABAoAAA==.丰胸圣手:AwAICAoABAoAAA==.',['�']='九成新:AwAECAQABRQAAA==.',['�']='二弟长压弯背:AwAECAQABRQAAA==.',['�']='伈丶梦梦:AwAICAgABAoAAA==.优势在我:AwAICAgABAoAAA==.传奇耐摔王:AwAGCAYABRQCBQAGAQjGAgAsIZgBBRQABQAGAQjGAgAsIZgBBRQAAA==.伤心羊腰子:AwACCAIABRQAAA==.',['�']='你说法爷开门:AwAGCAgABAoAAA==.',['�']='俏莉娜:AwAFCAUABAoAAA==.',['�']='公子丨世无双:AwADCAEABRQDCQAIAQgEKABFQvQBBAoACQAIAQgEKABFQvQBBAoACgABAQh6NgAAAAAABAoAAA==.',['�']='冷水鱼:AwABCAEABAoAAA==.',['�']='凉风起:AwABCAEABAoAAA==.',['�']='刘哒哒:AwADCAQABAoAAA==.',['�']='口嗨可不行:AwABCAEABRQAAA==.',['�']='吊战:AwABCAEABAoAAA==.',['�']='咕咕哒哒:AwAECAEABAoAAA==.',['�']='圣光忽悠着我:AwAGCAcABAoAAA==.',['�']='坐忘道:AwABCAEABRQAAA==.坐牢:AwADCAQABRQAAA==.',['�']='壶兄无敌顶:AwAHCAwABAoAAA==.',['�']='夏树的飞花:AwAFCAUABAoAAA==.夏洛特凯尔:AwACCAQABRQAAA==.',['�']='女尤:AwAECAQABRQAAA==.',['�']='姬丿太美:AwAECAQABAoAAA==.',['�']='宸星:AwAGCAUABAoAAA==.宸龍:AwAECAQABRQAAA==.',['�']='小夜夜:AwAECAYABRQCCwAEAQgyFQAjKtsABRQACwAEAQgyFQAjKtsABRQAAA==.小猪呼噜噜:AwAECAIABRQAAA==.小落落走丢了:AwAGCAoABAoAAA==.',['�']='幽灵灬壁垒:AwACCAIABRQAAA==.',['�']='弹簧钢:AwAICAoABAoAAA==.',['�']='忍冬和月见草:AwAICAgABAoAAA==.忽必劣:AwACCAIABAoAAA==.',['�']='恐怖的奴隶主:AwAECAQABRQAAA==.恐怖老奶:AwAECAQABRQAAA==.',['�']='悦清柠:AwAECAQABAoAAA==.',['�']='我叫小謹:AwAECAQABRQAAA==.我感觉很难瘦:AwACCAIABRQAAQEAAAAICAQABRQ=.',['�']='指尖丶旋律:AwAECAQABRQAAA==.',['�']='掉色人:AwADCAYABAoAAA==.',['�']='新年果子:AwABCAEABAoAAA==.',['�']='无限迷惑:AwAGCAcABAoAAA==.早饭想吃啥:AwACCAIABRQAAA==.',['�']='明月:AwACCAIABRQAAA==.',['�']='晚晚:AwADCAIABRQCDAAIAQgeCQBXXH8CBAoADAAIAQgeCQBXXH8CBAoAAA==.晚里二:AwAICAkABAoCDAAHAQi+GQBJx+gBBAoADAAHAQi+GQBJx+gBBAoAAA==.',['�']='朝霞:AwABCAEABRQAAA==.',['�']='杀马特秀芬:AwAICAYABAoAAA==.',['�']='果子果子:AwAECAQABRQAAA==.',['�']='梅鶸华:AwACCAIABRQAAA==.',['�']='椎名真昼:AwAECAQABRQAAA==.',['�']='橙柚柚:AwAICAgABAoAAA==.',['�']='毛头毛毛:AwABCAEABAoAAA==.',['�']='沃顿皮卡丘:AwADCAEABAoAAA==.',['�']='流光异彩:AwAECAQABAoAAA==.流莺毒:AwAICAYABAoAAA==.浩劫猎:AwADCAMABAoAAQEAAAABCAIABRQ=.浪总:AwAICAYABRQDBQAEAQg7BAAlrl8BBRQABQAEAQg7BAAXBV8BBRQABgABAQj9FwBaAGcABRQAAA==.',['�']='消散:AwAICAgABAoAAA==.涛笙皆浪灬:AwEBCAIABRQAAQ0AM6oECAoABRQ=.',['�']='混子请自重:AwACCAIABRQAAA==.',['�']='清源妙道真君:AwACCAIABAoAAA==.',['�']='溶溶月:AwAICAgABAoAAA==.',['�']='爱吃香菜:AwACCAIABRQAAA==.',['�']='珈小珈:AwAHCAIABAoAAA==.',['�']='甄霓瑪黛静:AwAICAgABAoAAA==.',['�']='白芷动芳馨丶:AwADCAEABRQAAA==.',['�']='盘丝大仙:AwADCAYABRQDDgADAQgCFQA2xJkABRQADgACAQgCFQAms5kABRQADwABAQhXJQACZy4ABRQAAA==.',['�']='真的是白给:AwACCAYABRQDDQACAQjICwAsLqIABRQADQACAQjICwAsLqIABRQAAgABAQg9JAAnx0kABRQAAA==.',['�']='示申茉莉:AwAGCAsABAoAAA==.',['�']='福贵:AwAFCAsABAoAAA==.离人影:AwAICAgABAoAAQEAAAAECAQABRQ=.',['�']='秋水长天:AwAICA8ABAoAAA==.秒伤及格线:AwEDCAMABAoAAQEAAAAICAUABAo=.',['�']='笑语风橙:AwADCAYABRQDBgADAQgiCAA+++4ABRQABgADAQgiCAA+++4ABRQABQABAQifQgAW9jsABRQAAA==.',['�']='米娜刚把得:AwADCAMABAoAAA==.米宥:AwAGCAcABAoAAA==.',['�']='红鲤鱼:AwAICAYABAoAAA==.纯净的眼神:AwAGCAkABAoAAA==.纯棉的兔子猫:AwAECAQABRQAAA==.',['�']='绘羽:AwAECAQABRQAARAAD08ICAUABRQ=.',['�']='网瘾少女:AwAGCA0ABAoAAA==.',['�']='胖胖的咕咕:AwAECAQABRQAAA==.胡桃夹子:AwABCAEABRQAAA==.',['�']='脆皮没仇恨:AwAECAQABRQAAA==.',['�']='芙莉蓮:AwAICAYABAoAAA==.花开若相依:AwAGCAYABRQCDgAGAQhqAwAiPXEBBRQADgAGAQhqAwAiPXEBBRQAAA==.花式呢:AwAECAQABRQAAA==.花式啊:AwAGCA8ABAoAAA==.',['�']='莎莎奥力给:AwABCAEABRQAAA==.莫夫:AwAECAcABRQCAwAEAQgiEQBDNgMBBRQAAwAEAQgiEQBDNgMBBRQAAA==.',['�']='萌萌哒丨牧:AwAGCBcABRQDDwAGAQhPAABZBRoCBRQADwAGAQhPAABZBRoCBRQADgAFAQj9BwAXvAsBBRQAAA==.',['�']='蓝岚丶坠:AwABCAIABRQCEQAIAQiCBABZXNACBAoAEQAIAQiCBABZXNACBAoAAA==.',['�']='蜗牛观光客:AwAECAQABRQAAA==.',['�']='表白:AwADCAQABRQCEgAIAQjBIQAzKLMBBAoAEgAIAQjBIQAzKLMBBAoAAA==.',['�']='谁是木头人:AwAGCAYABAoAAA==.谢哥哥:AwADCAwABRQCAwADAQhJEgA7N/8ABRQAAwADAQhJEgA7N/8ABRQAAA==.',['�']='超级玛丽:AwAECAgABRQCEwAEAQgtAwBPYxYBBRQAEwAEAQgtAwBPYxYBBRQAAA==.',['�']='路过的查拉图:AwAECAQABRQAAA==.',['�']='逆天而行:AwAGCAYABAoAAA==.',['�']='那我问你:AwABCAEABRQAAA==.邪能电风扇:AwACCAYABRQDCwACAQjfGgBO0LIABRQACwACAQjfGgBO0LIABRQAFAACAQiMDgAdiW8ABRQAAA==.',['�']='野人谷的狼:AwAGCAYABAoAAA==.',['�']='银兰水月:AwAGCAoABRQDEwAGAQgeAgA6aCYBBRQAFQAGAQj3BAAic4UBBRQAEwAEAQgeAgBbeCYBBRQAAA==.',['�']='长大不得了丶:AwAICBcABAoDBgAIAQicBABemMQCBAoABQAIAQjtDABZk8gCBAoABgAIAQicBABcmMQCBAoAAA==.长崎素世:AwAGCAYABAoAAA==.',['�']='阿哲学长:AwAECAQABAoAAA==.阿莎曼:AwAICAsABAoAAA==.阿龙:AwACCAcABRQDFgACAQi+AgA4XoEABRQAFwACAQgdBQAZjJIABRQAFgACAQi+AgA4XoEABRQAAA==.',['�']='随风飘流:AwABCAEABRQAAA==.',['�']='雪月剑仙:AwAICBoABAoCAwAIAQjBEwBfjLwCBAoAAwAIAQjBEwBfjLwCBAoAAA==.',['�']='青浦小次佬:AwACCAIABRQAAA==.',['�']='风花雪月:AwAECAQABRQAAA==.风语萨:AwACCAIABRQAAA==.食人鱼:AwAGCAsABAoAAA==.',['�']='饭哆哆:AwAGCAQABRQAAA==.',['�']='麻匪马邦德:AwAICAkABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end