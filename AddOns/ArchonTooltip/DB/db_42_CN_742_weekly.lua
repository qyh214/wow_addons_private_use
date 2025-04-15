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
 local lookup = {'Warlock-Destruction','Priest-Shadow','Priest-Discipline','Hunter-BeastMastery','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','DeathKnight-Unholy','Evoker-Preservation','Evoker-Devastation','Mage-Fire','Priest-Holy','Shaman-Enhancement','Monk-Mistweaver','Warrior-Protection','Druid-Balance','DemonHunter-Havoc','DeathKnight-Blood','Warrior-Fury','DemonHunter-Vengeance','Rogue-Assassination','Warlock-Affliction','Warlock-Demonology',}; local provider = {region='CN',realm='火焰之树',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Anpanman:AwAECAgABRQCAQAEAQg+DgAtM9QABRQAAQAEAQg+DgAtM9QABRQAAA==.',Ev='Evens:AwAICA4ABAoAAA==.',Fo='Foceanusx:AwAECAQABAoAAA==.',Ic='Icaria:AwAECAYABAoAAA==.',Ka='Kaneli:AwAICAgABAoAAA==.',Le='Leonk:AwAICAYABAoAAA==.',Pi='Pikmin:AwAGCAYABAoAAA==.',Pl='Pluviophile:AwAGCAkABRQDAgAGAQg+DQAnddYABRQAAgAEAQg+DQAyQtYABRQAAwAFAQioEQAucJwABRQAAA==.',Sa='Sadaharur:AwAECAQABAoAAA==.',Ss='Ssrank:AwADCAMABAoAAA==.',Su='Sumail:AwAFCAUABAoAAA==.',Ti='Tiger:AwACCAIABAoAAA==.',Xn='Xniuxniu:AwAECAEABAoAAA==.',['�']='一色日和:AwABCAEABAoAAA==.一颗石头:AwAFCAYABAoAAA==.丅絃冄:AwAECAYABRQCBAAEAQjVGgAVgsEABRQABAAEAQjVGgAVgsEABRQAAA==.万人猛张飞:AwABCAEABAoAAA==.上帝审判:AwADCAMABAoAAA==.丨圣骑丨:AwAFCAUABAoAAA==.丶光之刹那:AwAECAQABAoAAA==.丶年华易逝丶:AwACCAIABRQAAQUAAAACCAQABRQ=.丶我是刹那:AwAECAQABRQAAA==.丶阿丁灬:AwAGCAIABRQAAA==.',['�']='乌拉:AwAECAQABRQAAA==.',['�']='亖黑白亖:AwAGCAYABAoAAA==.亚洲舞王赵四:AwAFCAUABAoAAA==.亡魂雇佣军:AwAECAQABAoAAA==.人狠話不多:AwACCAIABRQAAA==.亿万少女的梦:AwAECAQABRQAAA==.亿槍穿雲:AwAGCAUABRQCBAAEAQh3RAA43QAABRQABAAEAQh3RAA43QAABRQAAA==.',['�']='伊泽奈亚子:AwAGCAwABAoAAA==.',['�']='俊少爷:AwAECAQABAoAAA==.',['�']='全场最佳:AwAECAUABAoAAA==.',['�']='内个先别说话:AwAFCAUABAoAAA==.内个来贴贴:AwABCAIABRQDBgAIAQgrIwA1zuABBAoABgAIAQgrIwA1zuABBAoABwABAQhTcwASeykABAoAAA==.冰卝空:AwADCAMABAoAAA==.冰彡空:AwAICA4ABAoAAA==.冰橙子:AwAICAgABAoAAA==.',['�']='出来就很高:AwABCAEABRQAAA==.',['�']='半醉浮世:AwAGCAYABRQCCAAGAQiAAABBkuYBBRQACAAGAQiAAABBkuYBBRQAAA==.半醉餘生:AwAECAQABRQAAA==.卑鄙的外乡人:AwADCAMABAoAAQIAMD4CCAYABRQ=.单身狗召唤术:AwAGCAsABAoAAA==.',['�']='只儿豁阿歹:AwAECAQABAoAAA==.叮先生:AwACCAQABRQCCQAHAQi2EQBdzHkCBAoACQAHAQi2EQBdzHkCBAoAAA==.可乐拿酱油:AwACCAIABAoAAA==.',['�']='吓猴蹲:AwAGCAgABAoAAA==.吾嶽陳雪:AwABCAEABAoAAA==.',['�']='和中:AwAICAYABAoAAA==.',['�']='哭泣的恶魔:AwAICAgABAoAAQgAS6QGCAoABRQ=.',['�']='啸月孤狼:AwAICAoABAoAAA==.',['�']='喜欢摄影姓陈:AwAECAIABRQAAA==.',['�']='囧架架:AwAECAQABRQAAA==.',['�']='圆头耄耋:AwAECAYABRQDCgAEAQiUAgA9R9kABRQACgADAQiUAgA9R9kABRQACwADAQhIEgA7/4EABRQAAA==.',['�']='夜幕涎鬼:AwADCAMABAoAAA==.天天好心情:AwACCAMABRQCAQAHAQheJABBf9UBBAoAAQAHAQheJABBf9UBBAoAAA==.天越高心越小:AwAICAgABAoAAA==.太不好玩了:AwADCAMABAoAAA==.',['�']='奈何桥孟婆:AwABCAEABAoAAA==.好好哥哥:AwAHCA0ABAoAAA==.',['�']='妖媚丶:AwAECAQABAoAAA==.',['�']='姐夫再用力:AwACCAIABRQAAA==.',['�']='婲芯小四:AwADCAMABAoAAA==.',['�']='安東:AwAECAQABRQCCAAIAQhEEgBaX70CBAoACAAIAQhEEgBaX70CBAoAAA==.',['�']='对君酌:AwABCAEABRQAAA==.',['�']='尐妖妖丷:AwAGCAYABRQDAwAGAQgCAgA2n1kBBRQAAwAFAQgCAgA6qVkBBRQAAgABAQjoGwAhnE0ABRQAAA==.',['�']='山有扶蘇:AwAICA8ABAoAAA==.',['�']='崛北真灬希:AwAICAgABAoAAA==.',['�']='巳升升:AwADCAMABRQAAA==.',['�']='布谷鸟儿:AwAGCAYABAoAAA==.',['�']='年华已逝:AwABCAMABRQAAQUAAAACCAQABRQ=.年华易逝:AwACCAQABRQAAA==.广寒宫:AwAECAgABRQCDAAEAQhxGwAaKssABRQADAAEAQhxGwAaKssABRQAAA==.',['�']='御水者:AwAGCBYABAoCDQAGAQjfTQAaUNMABAoADQAGAQjfTQAaUNMABAoAAA==.',['�']='心中的火焰:AwABCAEABRQAAA==.',['�']='总冠军:AwAECAQABRQAAQUAAAAICAIABRQ=.',['�']='愚蠢的地球人:AwAECAQABRQAAA==.',['�']='我是奶骑:AwAGCAUABAoAAA==.战少:AwAICAgABAoAAA==.',['�']='打灰机:AwAECAQABRQAAQUAAAAICAQABRQ=.',['�']='抹茶麻糬:AwACCAYABRQDBgACAQhsGAAxs5UABRQABgACAQhsGAAxs5UABRQADgACAQhQDwAqAokABRQAAA==.',['�']='拉面加肉:AwAGCAsABRQCDwAGAQiUAQAre58BBRQADwAGAQiUAQAre58BBRQAAA==.拾穗行歌:AwAICAgABAoAAA==.',['�']='排骨小贼:AwAFCA4ABAoAAA==.',['�']='摇滚雪姨:AwAECAQABRQAAA==.',['�']='撒旦皮皮:AwAHCAcABAoAAA==.',['�']='无亟之旅:AwACCAUABRQCEAACAQg/CAAHJlkABRQAEAACAQg/CAAHJlkABRQAAA==.',['�']='普特雷斯:AwAHCA8ABAoAAA==.晴山栖谷:AwACCAIABRQCDwAHAQj0HABIuuQBBAoADwAHAQj0HABIuuQBBAoAAA==.',['�']='暗悔:AwACCAQABRQCDQAHAQguCwBd5mICBAoADQAHAQguCwBd5mICBAoAAA==.暗月小法:AwACCAIABRQAAA==.',['�']='李永浩:AwACCAIABAoAAA==.杰夫老祭司:AwAGCAYABAoAAA==.東雪莲:AwAFCAUABAoAAA==.',['�']='枫道:AwAECAMABRQAAQwAXIEGCBIABRQ=.',['�']='桃之夭夭:AwAECAUABAoAAA==.',['�']='梦的磐涅:AwAGCAoABRQCCAAGAQiJAAA/mt4BBRQACAAGAQiJAAA/mt4BBRQAAA==.',['�']='楚天秋:AwAGCAMABRQCEQAHAQgEIgBOQxsCBAoAEQAHAQgEIgBOQxsCBAoAAA==.',['�']='死亡序号:AwAICAgABAoAAA==.',['�']='殇炎:AwADCAEABAoAAA==.',['�']='气球的怨念:AwAECAQABRQAAA==.水无月灬流歌:AwACCAIABRQAAA==.',['�']='汐唐杉禾:AwADCAMABAoAAA==.汪峰:AwADCAsABRQCEgADAQixEAAuDuoABRQAEgADAQixEAAuDuoABRQAAA==.',['�']='法瑟布拉德:AwAFCAUABAoAAA==.泰灡德:AwAECAQABAoAAA==.',['�']='洛丹伦的兲空:AwADCAYABRQDCQADAQixDAAo4OYABRQACQADAQixDAAo4OYABRQAEwABAQj+GgAtnzsABRQAAA==.',['�']='深入荒野:AwAHCAEABAoAAA==.',['�']='温柔的大坑:AwAECAgABRQCEwAEAQgeBwBEsPEABRQAEwAEAQgeBwBEsPEABRQAAA==.',['�']='潇湘亱雨:AwAGCAYABAoAAA==.',['�']='火焰刀锋出鞘:AwACCAIABRQAAA==.灬奔雷剑灬:AwACCAIABAoAAA==.灬羡世丨非灬:AwAFCAQABAoAAA==.',['�']='烂木头:AwACCAIABAoAAA==.',['�']='熊小德丶:AwAFCA4ABAoAAA==.熊柒丶:AwAECAgABAoAAA==.',['�']='牛气十足:AwAGCAYABAoAAA==.牛马:AwAICAgABAoAAA==.',['�']='狂笑的菠萝糖:AwABCAEABAoAAA==.独孤尚恋:AwAICA8ABAoAAA==.狼心娃娃:AwAFCAkABAoAAA==.',['�']='獠牙刘华强:AwACCAIABAoAAA==.獨孤尙戀:AwAICAEABAoAAA==.',['�']='男兽:AwAFCAUABAoAAA==.',['�']='痞子丨柒:AwACCAIABRQAAA==.痞子狼哥:AwABCAIABRQAAA==.',['�']='白羊:AwAECAQABRQAAA==.',['�']='石头梦想圣:AwABCAIABRQAAA==.石头梦想娃:AwACCAQABRQAAA==.',['�']='秤子逐风者:AwAECAQABAoAAA==.',['�']='稗兰:AwABCAEABRQAAA==.',['�']='立花灬千岁:AwACCAIABRQAAA==.',['�']='符娃大哥:AwAECAQABAoAAA==.第二秃:AwAGCAYABAoAAA==.',['�']='纞戦之狼哥:AwABCAEABRQAAA==.',['�']='绝地死战:AwAECAQABRQAAA==.',['�']='羽倾:AwAHCAkABAoAAQUAAAAICA8ABAo=.羽翼之城:AwAFCAUABAoAAA==.',['�']='聖人亞納:AwAGCAgABAoAAA==.聼述說:AwAECAQABRQAAA==.',['�']='肚皮人儿:AwAICBEABAoAARQAP/EHCAYABRQ=.',['�']='花生了什么树:AwAHCBEABAoAAA==.',['�']='莫高雷:AwABCAEABRQAAA==.',['�']='菊丶希尔芬:AwAECAQABRQAAA==.',['�']='萧瑟:AwABCAEABAoAAA==.萨满之心:AwAHCBkABAoDBwAHAQi7IgA8VqcBBAoABwAHAQi7IgA8VqcBBAoABgAFAQiRXQA8gPgABAoAAA==.落花黯然:AwAECAgABRQCAgAEAQjQCQA6QfEABRQAAgAEAQjQCQA6QfEABRQAAA==.',['�']='蒙狼哥:AwABCAEABRQAAA==.',['�']='蓝染惣右介丶:AwAECAIABRQAAA==.',['�']='薩菲羅斯:AwACCAQABRQAAA==.',['�']='虞兮丶虞兮:AwACCAIABRQAAA==.',['�']='西门长海:AwAECAUABRQDFQADAQg0CgAsMYsABRQAEgADAQinFwANTL4ABRQAFQACAQg0CgBADIsABRQAAA==.',['�']='覇気十卒:AwABCAEABRQAAA==.',['�']='观星者:AwAGCBYABAoCCQAGAQhcUwAuhi8BBAoACQAGAQhcUwAuhi8BBAoAAA==.',['�']='远征的雷欧:AwAGCAYABAoAAA==.迪昂德萨巴赫:AwADCAMABRQAAA==.追忆杨毅:AwACCAIABRQAAA==.',['�']='遗忘的红楼:AwACCAIABAoAAA==.',['�']='重釿求子丶:AwACCAIABRQAAA==.',['�']='钟声:AwAICBcABAoCFgAHAQiBCwBSAjkCBAoAFgAHAQiBCwBSAjkCBAoAAA==.',['�']='铁蹄拉风牛:AwAFCAUABAoAAA==.',['�']='问题美美:AwAECAQABRQAAA==.',['�']='阿基米德:AwAECAYABAoAAA==.',['�']='陆筱凤:AwAHCCQABAoCCAAHAQibRwBZRvYBBAoACAAHAQibRwBZRvYBBAoAAA==.',['�']='雷德王:AwAGCAkABAoAAA==.雷托:AwAICAgABAoAAA==.',['�']='须弥芥子:AwAICAYABAoAAA==.',['�']='颤抖吧骚年:AwACCAIABRQDEgAIAQgOGwBOA0UCBAoAEgAIAQgOGwBOA0UCBAoAFQADAQg4SgAXTmgABAoAAA==.',['�']='风一样的勇士:AwAFCAgABAoAAA==.风中魅火:AwABCAEABRQAAA==.风之彼岸婲:AwAECAUABRQEFwAEAQieBABMSP0ABRQAFwADAQieBABMSP0ABRQAGAABAQgOFAAISzAABRQAAQABAQjZLwAAAAAABRQAAA==.',['�']='魔灵娃娃:AwAICAgABAoAAA==.',['�']='黑泽灬纱重:AwACCAIABRQAAA==.黑熊:AwAFCAUABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end