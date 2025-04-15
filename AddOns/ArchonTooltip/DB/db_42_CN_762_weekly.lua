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
 local lookup = {'Mage-Fire','Mage-Frost','Hunter-Marksmanship','Hunter-BeastMastery','Rogue-Subtlety','Unknown-Unknown','Warlock-Demonology','Druid-Balance','Paladin-Retribution','Rogue-Assassination','Druid-Restoration','DeathKnight-Unholy','Warrior-Arms','Paladin-Holy','Druid-Guardian','DeathKnight-Blood','Shaman-Enhancement','Warlock-Destruction','Warlock-Affliction','Warrior-Protection','DemonHunter-Vengeance','DemonHunter-Havoc','Shaman-Elemental','Warrior-Fury','Shaman-Restoration','Monk-Mistweaver','Priest-Shadow','Priest-Holy','Druid-Feral','Priest-Discipline','Hunter-Survival',}; local provider = {region='CN',realm='玛里苟斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adamtosedus:AwAECAQABRQAAA==.',Ba='Baltic:AwAHCBIABAoAAA==.',Ch='Chloe:AwAICBgABAoDAQAIAQiVJABBEgoCBAoAAQAIAQiVJABBEgoCBAoAAgABAQgPoQAQQCAABAoAAA==.',Cr='Crazynuo:AwAECAYABRQDAwAEAQh7CgArbdMABRQAAwAEAQh7CgArbdMABRQABAACAQgCLgAoLnkABRQAAA==.',Fo='Forevercry:AwACCAIABRQAAA==.',Ga='Garlvinland:AwAICBIABAoAAA==.',Ll='Llst:AwAICAgABAoAAA==.',My='Mydearest:AwABCAEABRQAAA==.',No='Nordicmetal:AwADCAMABAoAAA==.',Ob='Obk:AwAHCBMABAoAAA==.',Pe='Pez:AwAICBIABAoAAA==.',Pi='Picasso:AwABCAEABRQDAQAIAQjaGgBPfkMCBAoAAQAIAQjaGgBM7EMCBAoAAgAGAQg8NwBR4mQBBAoAAA==.',Ro='Roses:AwAHCAsABAoAAA==.',Sa='Sallyy:AwAICB4ABAoCBQAIAQgVCgBLSUUCBAoABQAIAQgVCgBLSUUCBAoAAA==.',Ti='Titan:AwACCAIABAoAAQYAAAAGCAIABRQ=.',Tr='Triplesix:AwAECAQABAoAAA==.',Ur='Urminepld:AwACCAIABAoAAA==.',Va='Vanitywarlo:AwABCAEABRQCBwAIAQh4CwA0HwECBAoABwAIAQh4CwA0HwECBAoAAA==.',Vi='Vic:AwADCAMABAoAAA==.',['�']='一只球球丶:AwABCAEABRQAAA==.一条海参:AwACCAQABRQCCAAIAQg+FABROHMCBAoACAAIAQg+FABROHMCBAoAAA==.一颗小草莓:AwAHCAcABAoAAA==.七爺:AwABCAEABRQAAA==.万圣之夜:AwABCAEABRQCCQAIAQgMPQBEjRUCBAoACQAIAQgMPQBEjRUCBAoAAA==.世一克:AwACCAIABAoAAA==.丧钟鸣寂寞:AwABCAEABAoAAA==.丨吴彦祖丨:AwACCAQABRQCCgAIAQjxCgBGgUECBAoACgAIAQjxCgBGgUECBAoAAA==.丨圣丨光丨:AwAECAQABRQAAA==.丶小欣:AwADCAEABRQAAA==.',['�']='九久:AwACCAIABRQAAA==.',['�']='云朵:AwAICAsABAoAAQsAKncGCAoABRQ=.云起兮衣飞扬:AwACCAIABAoAAA==.',['�']='今田美樱:AwADCAwABRQCAQADAQj7DQBJvAABBRQAAQADAQj7DQBJvAABBRQAAA==.仔仔:AwAHCAUABAoAAA==.',['�']='伊莎丶凯希:AwACCAUABRQCDAACAQjEFAA91KUABRQADAACAQjEFAA91KUABRQAAA==.会玩杂技:AwACCAIABAoAAA==.',['�']='你艾希我奶妈:AwAICBAABAoAAA==.',['�']='依然在一起:AwAGCAYABRQCDQAGAQhyAAA0ycgBBRQADQAGAQhyAAA0ycgBBRQAAA==.',['�']='假和尚:AwAECAQABRQAAA==.假肢盖饭:AwAECAQABRQAAA==.',['�']='傲视槑槑:AwAICA0ABAoAAQYAAAAICAIABRQ=.',['�']='光怒战魂:AwAECAQABRQAAA==.兜兜不哭:AwACCAIABRQAAA==.全身战火带槽:AwAFCAcABAoAAA==.六先森:AwAECAQABRQAAQYAAAAICAMABRQ=.兮怜:AwAECAQABRQAAA==.兰斯洛特丶:AwAECAQABRQAAA==.',['�']='冰锋:AwAGCAYABAoAAA==.',['�']='凛冬将至:AwAICBAABAoAAA==.出云天花:AwADCAMABRQAAA==.',['�']='刁爆了丶:AwAECAQABRQAAA==.',['�']='劍絲丶無情:AwAICAkABAoAAA==.力量的代价:AwAECAQABRQAAA==.劣人七号:AwACCAUABRQCDgACAQgJCwAtWpAABRQADgACAQgJCwAtWpAABRQAAA==.',['�']='双蛋瓦斯:AwAICAkABAoAAA==.变身红薯:AwACCAIABRQAAA==.叫我狼外婆:AwADCAwABRQDDwADAQisAwAQOVgABRQADwACAQisAwAW91gABRQACAABAQizLQACvzYABRQAAA==.',['�']='吃米饭丰胸:AwAICAgABAoAAA==.',['�']='咕咕哇呜:AwAFCAQABRQAAA==.',['�']='哨兵:AwAGCAYABAoAAA==.',['�']='商略黄昏雨:AwACCAIABRQAAA==.',['�']='喂丶大灰狼:AwAGCAgABRQDCgAGAQioAQAv2lgBBRQACgAFAQioAQA4AVgBBRQABQABAQinDQAPQVsABRQAAA==.喂丶小乌龟:AwAECAgABRQCEAAEAQifBwA82egABRQAEAAEAQifBwA82egABRQAAA==.喂丶皮卡球:AwAECAsABRQCEQAEAQh/BgBDcAQBBRQAEQAEAQh/BgBDcAQBBRQAAA==.喬伊尐姐:AwAGCAYABAoAAA==.',['�']='嗜血流氓:AwAGCAIABRQAAA==.',['�']='回旋踢:AwAGCAQABRQAAA==.',['�']='圣光小神通:AwAGCAYABAoAAA==.圣辉:AwAGCAYABAoAAA==.',['�']='基安蒂:AwAHCA0ABAoAAA==.',['�']='墓穴之小鬼:AwAICBwABAoDBwAIAQgfGgBAdWgBBAoABwAGAQgfGgA5LGgBBAoAEgAHAQhuPwAr+E0BBAoAAA==.',['�']='夜刃御风:AwAICBAABAoAAQsAQeQICB8ABAo=.夜夜痞子夜夜:AwAECAYABRQDEwAEAQiyAwBHLwkBBRQAEwAEAQiyAwBHLwkBBRQAEgACAQixGwAkS3kABRQAAA==.大村长:AwACCAYABRQCEAACAQjgFgAUuGEABRQAEAACAQjgFgAUuGEABRQAAA==.大漠那啥:AwACCAYABRQCFAACAQiQBwAUSGkABRQAFAACAQiQBwAUSGkABRQAAA==.大米底层逻辑:AwABCAEABAoAAA==.天之落雨:AwABCAEABRQAAA==.天冬氨酸:AwADCAcABRQCBQADAQi6BwAdUOYABRQABQADAQi6BwAdUOYABRQAAA==.夺魂:AwAFCAMABAoAAA==.',['�']='奥佐:AwABCAEABRQAAA==.奥力给:AwAICA8ABAoAAA==.奥斯瑞克丶:AwABCAEABAoAAA==.',['�']='妾藜:AwAICAgABAoAAA==.',['�']='安度因的男宠:AwAGCAsABAoAAA==.',['�']='寂静的日部落:AwACCAUABRQDBAACAQhZHgBEtaoABRQABAACAQhZHgBEtaoABRQAAwABAQifHgAGmywABRQAAA==.富贵儿:AwAICBwABAoCEQAIAQgTFAA9cBcCBAoAEQAIAQgTFAA9cBcCBAoAAA==.',['�']='射手座杀手:AwAICAgABAoAAA==.射爆丶:AwAGCAYABAoAAA==.小丶包德:AwAICBMABAoAAA==.小乖团子:AwAHCAQABAoAAQQANKQBCAEABRQ=.小小圣:AwABCAEABRQAAA==.小懒蛋:AwAGCAcABAoAAA==.小猫:AwAECAEABRQAAA==.小糕点:AwAGCAYABAoAAA==.小蛮腰:AwAICAgABAoAAA==.小谢同学丶:AwAHCA0ABAoAAA==.小驴火烧:AwACCAIABRQAAA==.尼赛亚:AwAECAQABRQDFQAIAQg8BABZPr4CBAoAFQAIAQg8BABZPr4CBAoAFgACAQh+lQBVeWIABAoAAA==.尽蹉跎:AwAICAgABAoAAA==.',['�']='巧克力钱串:AwAICAgABAoAAA==.巴黎瑰二:AwAICC4ABAoCAgAIAQh0IQA2694BBAoAAgAIAQh0IQA2694BBAoAAA==.',['�']='帅哥:AwACCAIABRQAAA==.希尔瓦娜噝:AwAICAgABAoAAA==.',['�']='并非永恒:AwAGCAIABAoAAQYAAAABCAEABRQ=.',['�']='弑夜:AwABCAEABRQAAA==.弹指春水流:AwADCAQABRQAAA==.',['�']='御风毁灭:AwAFCAEABAoAAQsAQeQICB8ABAo=.御龙在天:AwAHCAsABAoAAA==.',['�']='忘詞:AwAHCAYABAoAAA==.忧郁小百合:AwAICAgABAoAAA==.',['�']='性空山:AwAGCAYABAoAAA==.',['�']='恣意妄为:AwAFCAUABAoAAA==.',['�']='慊罹:AwAECAQABRQAARcAQagFCAIABRQ=.',['�']='懂云云:AwAICAUABAoAAA==.懂花花:AwAECAYABRQDCAAEAQgBFgAa3r0ABRQACAAEAQgBFgAa3r0ABRQACwABAQjrGgAebjkABRQAAA==.懂雲雲:AwAECAQABRQAAA==.',['�']='成都铁塔:AwADCAIABAoAAA==.我家老婆最大:AwACCAMABRQAAA==.我要让你心碎:AwACCAYABRQCFgACAQgNGgBC16YABRQAFgACAQgNGgBC16YABRQAAA==.',['�']='折戟壁垒:AwACCAIABAoAAA==.',['�']='拉仇恨的:AwAICAgABAoAAA==.拾壹月初叁:AwABCAIABRQAAA==.',['�']='文西哥:AwACCAYABRQCCQACAQizLgAe3YYABRQACQACAQizLgAe3YYABRQAAA==.斩啥:AwACCAMABRQCGAAIAQhWBABd1OcCBAoAGAAIAQhWBABd1OcCBAoAAA==.',['�']='无尽幻光:AwAICB8ABAoECwAIAQiHFABB5PoBBAoACwAIAQiHFABB5PoBBAoACAAFAQhNcgAobL8ABAoADwACAQi0JwAlAS0ABAoAAA==.',['�']='晚美:AwAICBUABAoCFgAIAQhaRAAdlWwBBAoAFgAIAQhaRAAdlWwBBAoAAA==.',['�']='暗影议会宝贝:AwAECAYABAoAAA==.暴怒的野兽:AwABCAIABRQDCwAIAQhoFgA9hugBBAoACwAIAQhoFgA9hugBBAoACAAFAQjOZgAuYuUABAoAAA==.暴風城國王:AwAICAEABAoAAA==.',['�']='月丶蚀:AwAGCAUABAoAAA==.月舞嫣然:AwACCAYABRQCDgACAQi7CQA1KJoABRQADgACAQi7CQA1KJoABRQAAA==.有我在没意外:AwABCAEABAoAAA==.朵朵芸儿:AwABCAUABRQCFgABAQhUJgA/0k8ABRQAFgABAQhUJgA/0k8ABRQAAA==.',['�']='权志龙:AwAICAgABAoAAA==.李撇希:AwAECAcABAoAAA==.',['�']='林正英:AwADCAUABAoAAA==.枫华绝代:AwAGCBQABAoDEgAGAQguNwBBv3UBBAoAEgAGAQguNwBBv3UBBAoABwACAQiBVAAsQlkABAoAAA==.枫红向晚:AwAECAQABAoAAA==.',['�']='柠檬百香果:AwABCAIABRQAAA==.',['�']='核心太坦带槽:AwAGCAYABAoAAA==.',['�']='棉花烤红薯:AwABCAEABRQAAA==.',['�']='樱花羽:AwAECAEABRQAAA==.',['�']='次奥有点紧:AwAHCAEABAoAAA==.',['�']='步履蹒跚丨:AwAGCAwABAoAAA==.',['�']='毒丶药:AwAGCAQABAoAAA==.毒女乃:AwABCAEABRQAAA==.毛毛虫:AwABCAEABRQAAA==.',['�']='江万理:AwAICAcABAoAAA==.',['�']='沐芸:AwAECAQABRQAAA==.治愈竽笙:AwAECAYABRQCGQAEAQg+CQA8V/YABRQAGQAEAQg+CQA8V/YABRQAAA==.',['�']='法批疯:AwAICCIABAoDAQAIAQg+FgBThGECBAoAAQAIAQg+FgBNG2ECBAoAAgAHAQgJJQBR+MkBBAoAAA==.',['�']='洛克萨斯之爪:AwAECAYABRQCCQAEAQhdHgAnAMYABRQACQAEAQhdHgAnAMYABRQAAA==.活宝钗:AwAGCAYABAoAAA==.',['�']='流氓鸽丶:AwACCAYABRQCGgACAQjPHAAI+nIABRQAGgACAQjPHAAI+nIABRQAAA==.',['�']='淡泊丶野:AwABCAEABRQAAA==.',['�']='清城雪影:AwAGCAgABAoAAA==.',['�']='滋啦啦:AwACCAIABAoAAA==.滢尘:AwADCAMABRQAAA==.',['�']='潘达奶糖:AwABCAEABRQAAA==.',['�']='烧肉:AwAGCAoABAoAAA==.烧麦灬:AwACCAQABRQAAA==.',['�']='爱情买卖:AwAECAgABRQDAwAEAQi7AQBe9y4BBRQAAwAEAQi7AQBZHy4BBRQABAAEAQjVDgBBnv4ABRQAAA==.爱骑狍子:AwADCAQABAoAAA==.',['�']='牛皮术:AwACCAYABRQDBwACAQjHCAA6/2QABRQAEwACAQhZDgAr/pcABRQABwABAQjHCABVHGQABRQAAA==.牧丶牧:AwAGCAkABRQDCwAGAQgIAwARkikBBRQACwAGAQgIAwARkikBBRQACAADAQgnGwA2T5oABRQAAQsAOskICAgABRQ=.牧奶姨:AwABCAEABAoAAA==.牧牧:AwAICAkABAoAAA==.牧牧丶:AwAICBAABAoAAA==.牧牧的复仇者:AwAICAgABAoAAA==.牧牧的幻魔师:AwAICA8ABAoAAQYAAAAGCAQABRQ=.牧牧的援护者:AwAICBAABAoAAA==.牧牧的放逐者:AwAECAIABRQAAA==.牧牧的毁灭者:AwAICBAABAoAAQwAMUoICAgABRQ=.牧牧的泡泡龙:AwAICAgABAoAAA==.',['�']='独奏夜:AwACCAUABRQDGwACAQi1EgBAt50ABRQAGwACAQi1EgBAt50ABRQAHAABAQifHgASkTQABRQAAA==.',['�']='猫主任:AwACCAMABRQAAA==.',['�']='王祖贤十八岁:AwAECAQABRQAAA==.玖鬣:AwAECAQABRQAAA==.玛薇怒风:AwACCAQABRQCFgAIAQgGJwA8afoBBAoAFgAIAQgGJwA8afoBBAoAAA==.',['�']='瓦尔基娅:AwAECAQABRQAAA==.',['�']='生存本能:AwAICBcABAoCHQAIAQgyCABBmCUCBAoAHQAIAQgyCABBmCUCBAoAAA==.由南至北丨:AwAICBcABAoCGAAIAQhIGgA/5iMCBAoAGAAIAQhIGgA/5iMCBAoAAA==.',['�']='痕烬:AwACCAMABRQAAA==.',['�']='百变小英:AwACCAIABAoAAA==.',['�']='皓月影影:AwAGCAUABRQDHAAEAQgtAwBTchUBBRQAHAAEAQgtAwBM6BUBBRQAHgABAQjbGQBWbGQABRQAAA==.',['�']='睡喏喏的喵酱:AwAFCAgABAoAAA==.督军之伤:AwAICAgABAoAAA==.',['�']='短腿很无奈:AwAECAQABRQAAA==.矮矮缅怀:AwAECAQABRQAAA==.',['�']='砕月丶时光:AwAICBUABAoCGAAIAQg0KQApl8cBBAoAGAAIAQg0KQApl8cBBAoAAA==.',['�']='科学超电磁炮:AwAICAgABAoAAA==.',['�']='端木初夏:AwADCAMABAoAAA==.',['�']='筎鸢:AwACCAIABRQAAA==.',['�']='篠田步美:AwAICAgABAoAAA==.',['�']='米兰一九八三:AwACCAIABAoAAA==.',['�']='精灵宝可梦:AwACCAIABAoAAA==.',['�']='紫苏:AwAECAQABAoAAA==.紫萝兰:AwAGCA4ABAoAAA==.紫陌琉璃:AwAICAgABAoAAA==.',['�']='纵月:AwAECA0ABRQCCQAEAQhUDgBGPgcBBRQACQAEAQhUDgBGPgcBBRQAAA==.',['�']='老板蒜苗多些:AwAGCAEABAoAAA==.',['�']='聪明眼袋:AwABCAEABRQCBAAIAQhgPQA0pNkBBAoABAAIAQhgPQA0pNkBBAoAAA==.',['�']='肥美香饭饭:AwABCAEABAoAAA==.',['�']='艮垠:AwAICBgABAoCHgAIAQj0EgBCtwwCBAoAHgAIAQj0EgBCtwwCBAoAAA==.艾尔玛娜:AwACCAYABRQDAwACAQhIEAA895MABRQAAwACAQhIEAA895MABRQAHwABAQgSBAAhNzoABRQAAA==.',['�']='花自飘零:AwAICAgABAoAAA==.',['�']='英勇骑士:AwACCAIABAoAAA==.',['�']='草莓泡芙丶:AwAICAgABAoAAA==.',['�']='莫无命:AwAGCAsABAoAAA==.莹尘:AwACCAMABRQAAA==.',['�']='萌萌滴卡比兽:AwAGCAQABRQCGgAEAQg9BABbXDcBBRQAGgAEAQg9BABbXDcBBRQAAA==.萬万没想到:AwACCAYABRQCCAACAQj3GwAzA5cABRQACAACAQj3GwAzA5cABRQAAA==.落花无情:AwAECAQABRQAAA==.落雁丨沉鱼:AwACCAIABAoAAA==.落雨的暗眠:AwAICAgABAoAAA==.',['�']='蒜苗:AwAICCMABAoCFwAIAQghDABTTncCBAoAFwAIAQghDABTTncCBAoAAA==.',['�']='蓝芯之沫:AwAGCAIABAoAAA==.',['�']='蔚蓝暖阳:AwAECAQABRQAAA==.',['�']='藤原拓海:AwAHCAgABAoAAA==.',['�']='蛋求无愧于胸:AwAICCIABAoCBAAIAQhdKQBFTjACBAoABAAIAQhdKQBFTjACBAoAAA==.',['�']='蝦的爆發力:AwAFCAUABAoAAA==.',['�']='血之战:AwAICBUABAoCFAAIAQivGAAXVhMBBAoAFAAIAQivGAAXVhMBBAoAAA==.血战:AwAGCAsABAoAAA==.血羽永恒:AwAICAgABAoAAA==.衰仔丶究极体:AwAECAQABRQAAA==.',['�']='裴叫兽:AwADCAEABRQAAA==.',['�']='许个訫愿:AwAECAQABRQAAA==.',['�']='贰月拾玖:AwACCAMABRQCAQAIAQhyFQBObWYCBAoAAQAIAQhyFQBObWYCBAoAAA==.',['�']='赶紧洗白白:AwACCAEABRQAAA==.',['�']='超级赛娅喵:AwAECAEABRQAAA==.',['�']='醉爱清风:AwAHCAQABAoAAA==.醉血色:AwADCAEABAoAAA==.',['�']='錵麽菇:AwAICA4ABAoAAA==.',['�']='银行总裁:AwACCAEABAoAAA==.',['�']='长白山老六:AwAFCAUABAoAAA==.',['�']='阮梅:AwABCAEABRQAAA==.阿尔纹的绝望:AwABCAEABAoAAA==.阿胡子:AwACCAYABRQDCgACAQjICwBIH6UABRQACgACAQjICwA0maUABRQABQABAQigDgBOgU4ABRQAAA==.',['�']='雷伯:AwACCAUABRQCEQACAQiIEAAJqGEABRQAEQACAQiIEAAJqGEABRQAAA==.',['�']='青乄灯:AwAICAgABAoAAA==.面包人:AwAGCAQABRQAAA==.',['�']='風吹訩罩飛:AwABCAIABRQAAA==.',['�']='风中追爱:AwAICAEABAoAAA==.风暴要火:AwAICA4ABAoAAA==.风月小雪:AwABCAEABRQAAA==.风行猫影:AwACCAEABRQAAA==.风雪的缩影:AwACCAUABRQCAwACAQgMEwAkyn4ABRQAAwACAQgMEwAkyn4ABRQAAA==.',['�']='骨感是种美:AwACCAIABAoAAA==.骨科卖棒子骨:AwAECAQABRQAAA==.',['�']='高等术学:AwAICBsABAoCBwAIAQgQCABCcTQCBAoABwAIAQgQCABCcTQCBAoAAA==.高级弓兵:AwACCAQABRQCBAAIAQipCwBcocwCBAoABAAIAQipCwBcocwCBAoAAA==.',['�']='魂之哀殇:AwAHCAsABAoAAA==.',['�']='鲜团子丷凊梦:AwAFCAUABAoAAA==.鲜团子丷淸夢:AwADCAgABRQCGQADAQg0AwBXTjEBBRQAGQADAQg0AwBXTjEBBRQAAA==.鲜团子丷清夢:AwAICAwABAoAAA==.',['�']='鸡冻的傻馒:AwAICAgABAoAAA==.',['�']='黑虎阿福:AwACCAIABRQAAA==.黯淡:AwABCAEABRQAAA==.',['�']='龙怜:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end