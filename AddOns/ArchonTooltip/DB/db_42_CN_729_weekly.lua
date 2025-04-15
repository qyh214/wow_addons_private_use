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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Protection','Paladin-Retribution','DeathKnight-Unholy','Druid-Balance','Druid-Feral','Druid-Restoration','Druid-Guardian','Rogue-Assassination','Rogue-Subtlety','Warrior-Fury','Mage-Fire','DeathKnight-Blood','Warrior-Arms','Warlock-Destruction','Unknown-Unknown','Monk-Mistweaver','Priest-Holy','Priest-Discipline','DemonHunter-Havoc','Evoker-Devastation','Evoker-Preservation','Mage-Frost',}; local provider = {region='CN',realm='洛丹伦',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ac='Accord:AwAGCAYABAoAAA==.',Al='Alienware:AwAECAQABAoAAA==.',Fl='Flea:AwAHCAcABAoAAA==.',He='Heisenbergz:AwAFCAUABAoAAA==.',Hf='Hfing:AwAICBgABAoDAQAIAQiXEABaWK4CBAoAAQAIAQiXEABaWK4CBAoAAgAIAQiaGgBIKcEBBAoAAQEAO2AGCBQABRQ=.',Mi='Milliarage:AwAECAYABRQDAwAEAQjsCAA3q6IABRQAAwAEAQjsCAAfwKIABRQABAACAQh7LAA5ao0ABRQAAA==.',My='Mydarling:AwAGCAQABAoAAA==.',Na='Naowh:AwADCAkABRQCBQADAQgVBgBAnxQBBRQABQADAQgVBgBAnxQBBRQAAA==.',No='Nofear:AwAFCAMABAoAAA==.',Un='Untitleddz:AwACCAIABRQAAA==.',Ym='Ymissn:AwABCAEABRQCAQAIAQh8TQA1CZ4BBAoAAQAIAQh8TQA1CZ4BBAoAAA==.',['�']='一只大黄牛:AwACCAMABRQFBgAIAQjzPwA8kYEBBAoABgAGAQjzPwBJdYEBBAoABwAFAQhCEgAuej4BBAoACAAHAQjmLgAuFz0BBAoACQABAQgvKQAeWiUABAoAAA==.一杆枪叫射:AwACCAEABRQAAA==.一起吹晚风吧:AwAHCAYABAoAAA==.一颗朽木:AwADCAYABRQDCgADAQj1CQAzqbYABRQACgACAQj1CQBNIbYABRQACwABAQhNEgAAuiYABRQAAA==.万鬼来朝:AwACCAUABRQCDAACAQh3GwASPnwABRQADAACAQh3GwASPnwABRQAAQwAYIUDCAQABRQ=.三弟灬澄:AwABCAEABRQAAA==.不给透就分手:AwAECAQABRQAAA==.丨小豌豆丨:AwAFCAUABAoAAA==.丨温酒丨:AwAICAEABAoAAA==.丶伊瑞尔灬:AwACCAQABAoAAA==.丶随地大小变:AwAECAQABRQAAA==.丿丶小丶猎:AwAECAQABRQAAA==.',['�']='仙粉:AwABCAEABRQAAQ0ATiAECAgABRQ=.',['�']='伊地知虹夏:AwACCAIABAoAAA==.伊莎贝拉啊:AwADCAkABRQCBAADAQjuGQAmHt4ABRQABAADAQjuGQAmHt4ABRQAAA==.',['�']='你搞不死:AwAICAoABAoAAA==.',['�']='元气轩宝:AwABCAEABRQAAA==.',['�']='冥魄之冽风:AwACCAIABRQAAA==.',['�']='刘小孙:AwADCAMABAoAAA==.',['�']='剧末劣人:AwABCAEABRQAAA==.',['�']='加把劲骑士:AwACCAIABRQAAA==.',['�']='半盏轻风:AwACCAIABRQDAgAIAQg+CgBX420CBAoAAgAIAQg+CgBX420CBAoAAQAEAQihwwAjEncABAoAAA==.',['�']='叶落无关风吹:AwAFCAYABAoAAA==.',['�']='吃柠檬丶:AwAHCA0ABAoAAA==.',['�']='呀个赛罕:AwAECAQABRQAAQ4AY3oICAoABRQ=.',['�']='咖啡酸奶:AwAECAQABRQAAA==.',['�']='哥你真猛:AwAICCAABAoDDAAIAQhhEwBNAlYCBAoADAAIAQhhEwBNAlYCBAoADwAHAQjuKwAcXx4BBAoAAA==.',['�']='嗝屁熊:AwACCAYABRQCCAACAQiBEQAiK3gABRQACAACAQiBEQAiK3gABRQAAA==.',['�']='嘲颅:AwAECAQABRQAARAALloHCAYABRQ=.',['�']='四季清风:AwAGCAkABAoAAA==.回春大宗师:AwAECAgABRQDBgAEAQgsCQBHxAcBBRQABgAEAQgsCQBHxAcBBRQACAACAQhIDABIuqMABRQAAA==.',['�']='圣光的守护者:AwAHCAwABAoAAA==.地獄咆哮丨:AwAICAsABAoAAA==.',['�']='墨丨馨:AwAECAQABRQAAA==.',['�']='夜涩:AwAGCAEABAoAAA==.夜魔内瑟斯:AwAECAMABAoAAA==.大虾饺:AwAECAQABRQAAA==.大馍王:AwABCAEABAoAAA==.天命者:AwADCAMABAoAAA==.天魔鬼神:AwAECAEABRQAAA==.',['�']='奏绝丶莉洁纳:AwAHCAcABAoAAA==.奥利波斯猎:AwACCAIABAoAAA==.',['�']='它咬你:AwAECAQABRQAAA==.安格斯厚牛:AwAECAYABRQDBgAEAQiuEQAixd4ABRQABgAEAQiuEQAixd4ABRQACQABAQiHBQAuIzIABRQAAA==.安踏生活:AwABCAEABRQAAA==.',['�']='小小奶僧:AwABCAEABRQAAA==.小小奶萨:AwAECAYABAoAAA==.小猪八戒:AwAICB0ABAoCBQAIAQipFgBPnVQCBAoABQAIAQipFgBPnVQCBAoAAA==.小皮鞭:AwACCAIABAoAAA==.小象努努:AwAGCAQABRQAAA==.尐龙人:AwAICAgABAoAAREAAAAICAQABRQ=.就是不吊你:AwAICBgABAoCAgAIAQinBwBXzJACBAoAAgAIAQinBwBXzJACBAoAAA==.就是不理你:AwAICAIABAoAAREAAAAICAQABRQ=.尼特罗:AwAECAQABRQAAA==.',['�']='山花烂漫:AwADCAMABAoAAA==.',['�']='巫山青鸾箭:AwAFCAUABAoAAA==.',['�']='希尓瓦娜斯丨:AwAICBAABAoAAA==.',['�']='幸运小熊:AwAGCAQABRQAAA==.',['�']='弑念卟弃:AwACCAIABRQCBgAIAQgOKwA8COUBBAoABgAIAQgOKwA8COUBBAoAAQgAPyYICAsABRQ=.',['�']='快活林主:AwABCAEABAoAAA==.快跑二胖承易:AwACCAIABRQAAA==.',['�']='恬淡虛無:AwAECAQABAoAAA==.',['�']='愛迪生:AwAICAEABAoAAA==.',['�']='我爱霸道:AwAHCAgABAoAAA==.我骑士贼鎏:AwACCAQABRQCBAAIAQjjDABbZNgCBAoABAAIAQjjDABbZNgCBAoAAA==.',['�']='拳打脚踢胖:AwAECAgABRQCEgAEAQjuDwAYN9AABRQAEgAEAQjuDwAYN9AABRQAAA==.',['�']='持箭闯天涯:AwAHCAcABAoAAA==.',['�']='撕裂大地灬:AwAGCAoABAoAAA==.',['�']='故夢:AwAICAYABAoAAREAAAAECAQABRQ=.',['�']='旺仔老奶牛:AwAFCAUABAoAAA==.',['�']='星战:AwAECAQABRQAAA==.星芸:AwAECAQABRQAAA==.',['�']='暴怒之弓:AwAFCAgABAoAAA==.暴躁的邹哥哥:AwAGCAkABAoAAA==.',['�']='最后的单纯:AwAHCAcABAoAAA==.有德有詩:AwABCAEABRQAAA==.有遮:AwABCAEABAoAAA==.术式:AwAGCAIABAoAAA==.',['�']='杀马特的王:AwAECAQABRQAAA==.李可欣:AwACCAYABRQDEwACAQjgDQBEnJwABRQAEwACAQjgDQA2V5wABRQAFAABAQg0GwA67lEABRQAAA==.杯莫停:AwAGCAYABAoAAREAAAAGCAIABRQ=.',['�']='极限雷哥:AwABCAEABRQAAA==.极限雷神:AwAFCAMABAoAAA==.',['�']='格鲁斯:AwACCAIABAoAAA==.',['�']='梅尔暖暖:AwAGCAQABRQAAA==.梦之醉呀:AwABCAIABRQAAA==.',['�']='森下下士:AwAGCAYABAoAAA==.',['�']='樱花一宝儿:AwAICAYABAoAAA==.',['�']='死亡主宰者:AwAHCA0ABAoAAA==.',['�']='残存丶剩光灬:AwAICAQABAoAAA==.',['�']='水龍吟:AwAICAgABAoAAA==.氵去丶礻申:AwAICBUABAoCDQAIAQhVOQAjxpcBBAoADQAIAQhVOQAjxpcBBAoAAA==.',['�']='沃娜:AwADCAwABRQCFQADAQiiEgAhtOEABRQAFQADAQiiEgAhtOEABRQAAA==.沐雨橙枫:AwACCAIABAoAAA==.没事就睡觉么:AwAFCA4ABAoAAA==.',['�']='流年乄奈我何:AwACCAQABRQAAA==.',['�']='灬幻丨想灬:AwAECAQABRQAAA==.灬赤甲红:AwACCAEABAoAAA==.灰昼:AwAECAQABRQAAA==.',['�']='熊色儿:AwABCAEABAoAAA==.',['�']='爆疯丶:AwACCAIABRQCDAAIAQhcFQBKvEcCBAoADAAIAQhcFQBKvEcCBAoAAA==.爱漠世疯年:AwAGCAYABAoAAA==.爸爸丶:AwAICA8ABAoAAA==.',['�']='牛牛在奔跑:AwAICAgABAoAAA==.',['�']='王叁箭:AwAGCAcABAoAAA==.',['�']='生活小妙招灬:AwADCAMABAoAAA==.',['�']='痕墨殇:AwAECAQABRQAAA==.',['�']='白芷青墨:AwAGCAsABAoAAA==.',['�']='福袋:AwAECAQABRQAAA==.',['�']='紫轩丶小贱:AwAECAIABRQAAA==.',['�']='红烧馒头:AwAFCAUABAoAAA==.纯情女高:AwAECAgABRQCBAAEAQgwCABPECEBBRQABAAEAQgwCABPECEBBRQAAA==.',['�']='绯世:AwABCAIABRQCBAAIAQh1FABbOrMCBAoABAAIAQh1FABbOrMCBAoAAA==.绽放的野蔷薇:AwAICA4ABAoAAA==.绿桃:AwACCAIABRQAAA==.',['�']='羊儿咩咩:AwABCAEABRQAAA==.',['�']='老公真舒服:AwAICBAABAoAAA==.',['�']='肉蛋蛋儿:AwAECAQABRQAAA==.',['�']='脚踢敬老院:AwAFCAcABAoAAA==.',['�']='艾萨克:AwAECAQABAoAAA==.',['�']='菲琳:AwABCAEABRQDFgAIAQgeGwBBOawBBAoAFgAGAQgeGwBRQqwBBAoAFwAGAQgLDwA6XU8BBAoAAA==.',['�']='萝卜丶:AwAGCAYABAoAAA==.',['�']='蕾茉妮娅:AwAICBgABAoCAgAIAQhsGQBCnswBBAoAAgAIAQhsGQBCnswBBAoAAA==.',['�']='血匕透心涼:AwAICAMABAoAAA==.表面波澜不惊:AwABCAEABRQAAA==.',['�']='过期杰士邦:AwAECAQABRQAAA==.过期猫罐头:AwAECAQABRQAAA==.远想衣裳:AwAICAgABAoAAA==.',['�']='逗宝的尐奶嘴:AwABCAEABRQAAA==.',['�']='那年似水如年:AwABCAEABRQAAA==.邪能狂刀:AwAECAQABRQAAA==.',['�']='酷酷子:AwAECAUABAoAAA==.',['�']='陈晖洁:AwAECAQABRQAAA==.',['�']='雪狱:AwADCAMABRQDDQAIAQgLFgBRnmICBAoADQAIAQgLFgBLi2ICBAoAGAAIAQgKJQA+MckBBAoAAA==.雪狼洞主:AwAECAQABAoAAA==.',['�']='香辣鸡翅:AwAECAQABAoAAA==.',['�']='骨头蟹子:AwABCAEABRQAAA==.',['�']='魑魅魍魉魉:AwACCAIABAoAAA==.',['�']='鲁智浅:AwAICAgABAoAAA==.',['�']='鹤井闲人:AwACCAIABRQAAA==.',['�']='麦的垛朱尼尔:AwAICAgABAoAAA==.',['�']='齐炫:AwACCAQABRQAAA==.',['�']='龍小瑾:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end