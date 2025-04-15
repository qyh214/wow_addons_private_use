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
 local lookup = {'DeathKnight-Blood','DeathKnight-Unholy','Warrior-Fury','Mage-Frost','Rogue-Assassination','Paladin-Protection','Unknown-Unknown','Druid-Restoration','Druid-Balance','Mage-Fire','Paladin-Retribution','Priest-Shadow','Rogue-Subtlety','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Arms','Shaman-Restoration','Paladin-Holy','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','DemonHunter-Havoc','Rogue-Melee','Priest-Discipline','Shaman-Elemental','Shaman-Enhancement','Evoker-Devastation','Evoker-Preservation','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','DeathKnight-Frost',}; local provider = {region='CN',realm='血羽',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ai='Aiyouou:AwAGCAkABAoAAA==.',Ar='Ardenrena:AwADCAUABAoAAA==.',Bb='Bbudk:AwAECAYABRQDAQAEAQhYFgBe83YABRQAAQACAQhYFgApjXYABRQAAgAEAAgAAABe8wAABRQAAQMAN1IICAkABRQ=.Bbuqs:AwAICBAABAoAAA==.',Bs='Bshadow:AwADCAIABAoAAA==.',Cy='Cyanscream:AwABCAEABRQAAA==.',Gy='Gyugijgy:AwAICBgABAoCBAAIAQhyJgA9g8gBBAoABAAIAQhyJgA9g8gBBAoAAA==.',Ha='Hamburg:AwAICAcABAoAAA==.Haze:AwAGCAcABAoAAA==.',Ji='Jingy:AwAICAgABAoAAA==.',Ka='Katsumi:AwACCAIABRQAAQUAPF8DCAkABRQ=.',Lz='Lzblood:AwAECAoABRQCAQAEAQiNFwAGjG0ABRQAAQAEAQiNFwAGjG0ABRQAAA==.Lzpink:AwAECAwABRQCBgAEAQj8CAALq6sABRQABgAEAQj8CAALq6sABRQAAA==.',Mo='Mourning:AwACCAIABAoAAQUAPF8DCAkABRQ=.',Ta='Tailslide:AwAFCAUABAoAAA==.',Tc='Tc:AwACCAIABAoAAA==.',Xo='Xorn:AwAHCAgABAoAAA==.',['�']='一顿仨馒头:AwAECAQABRQAAA==.一顿俩鸡腿:AwACCAIABRQAAQcAAAAECAQABRQ=.三笠丶阿克曼:AwABCAEABRQAAA==.不会起名字:AwAECAQABAoAAA==.世界停载:AwAECAQABRQAAA==.严直高:AwAECAQABAoAAA==.丨吟灬天丨:AwADCAIABRQAAA==.丶甲甲:AwAICAcABAoAAA==.丶董巴特丶:AwAECAQABRQAAA==.',['�']='乄星刻:AwACCAIABRQAAA==.乌拉辣拉貔貅:AwAECAIABRQDCAAIAQivDgBJLD0CBAoACAAIAQivDgBJLD0CBAoACQAIAQhpSgAs9GMBBAoAAQcAAAAECAQABRQ=.',['�']='伊弉冉尊:AwAFCAUABAoAAA==.伊格尼丝:AwAECAQABRQAAQoAQ8QICAcABRQ=.伊格尼斯:AwAECAQABRQAAA==.伏特加加冰:AwACCAIABRQAAA==.众生同调奥秘:AwAECAwABRQCAgAEAQhQBQBXACUBBRQAAgAEAQhQBQBXACUBBRQAAA==.',['�']='低调是一种罪:AwACCAIABAoAAA==.佐岸丨布丁:AwACCAcABRQCCwACAQh6KwA7Y5oABRQACwACAQh6KwA7Y5oABRQAAA==.你无敌了:AwAECAYABAoAAA==.',['�']='依然萨爽:AwADCAMABAoAAA==.',['�']='停一下别打了:AwADCAMABAoAAA==.',['�']='元宝:AwAGCAkABRQCDAAEAQgRCgA5TfcABRQADAAEAQgRCgA5TfcABRQAAA==.八神嘉儿丶:AwABCAEABRQAAA==.兰卡斯卓尔:AwAECBAABRQCAwAEAQi6BABYvzQBBRQAAwAEAQi6BABYvzQBBRQAAA==.关云短:AwACCAMABAoAAA==.',['�']='冠军不如冠希:AwAGCAYABAoAAA==.冰凝物语:AwAICBAABAoAAA==.',['�']='凝霜雨:AwAECAQABRQAAA==.出溜船船长:AwAGCAYABAoAAA==.',['�']='加拉达:AwAICAgABAoAAA==.',['�']='勾栏听曲儿:AwAGCAIABRQAAA==.',['�']='十二载丶:AwABCAIABRQCBQAIAQjECABPfmwCBAoABQAIAQjECABPfmwCBAoAAA==.博丽:AwAGCAYABAoAAA==.',['�']='只喝无糖可乐:AwABCAEABRQAAA==.可乐老登:AwAECAUABRQCAwAEAQivCQBIvAsBBRQAAwAEAQivCQBIvAsBBRQAAQMAN1IICAkABRQ=.可惜丨不是你:AwAGCAYABAoAAA==.号令八荒:AwAHCAwABAoAAA==.',['�']='呦呦鹿鸣:AwAECAQABAoAAA==.命运云云潮流:AwAGCAgABRQDDQAEAQi5CwAiW5cABRQADQADAQi5CwAuzpcABRQABQACAQhbEQAGFHAABRQAAA==.命运云潮流:AwAICAgABAoAAA==.',['�']='噓噓后的颤抖:AwABCAEABAoAAA==.',['�']='声优都是怪物:AwADCAYABAoAAA==.',['�']='夏虫语冰:AwAGCAgABRQDDgAEAQhxCwBQtxYBBRQADgAEAQhxCwBQtxYBBRQADwAEAQh8DQAiosgABRQAAA==.夜墨如歌:AwAICAgABAoAAA==.大地萨:AwAFCAUABAoAAA==.天晴:AwAICAgABAoAAA==.天降锤神阿狸:AwAGCAkABAoAAA==.天陨星丨银狼:AwADCAMABAoAAA==.天骑士:AwAGCAcABAoAAA==.失落圣光:AwABCAEABAoAAA==.头号大鸟:AwACCAIABRQAAA==.头号白白:AwADCAIABRQAAA==.',['�']='奈法勒姆:AwAICAkABAoAAA==.奥迪大魔王:AwABCAEABRQAAA==.奶一下别看了:AwAFCAoABAoAAA==.',['�']='如梦似幻:AwAICAwABAoAAA==.',['�']='嫣姬:AwAFCAIABAoAAA==.',['�']='安小僧:AwABCAIABRQAAA==.家有萌虎:AwAICAYABAoAAA==.',['�']='对对:AwACCAIABAoAAA==.',['�']='小凌丶:AwACCAIABAoAAA==.小小法佬:AwAICAgABAoAAA==.小瓜瞎:AwAICA8ABAoAAA==.小馬爷:AwABCAEABRQAAA==.尘缘不相误:AwACCAIABAoAAA==.尼奥:AwACCAIABRQAAA==.',['�']='布卡布卡:AwAECAgABRQCDAAEAQieDQAqZd0ABRQADAAEAQieDQAqZd0ABRQAAA==.帅气的藕总:AwACCAIABRQAAA==.',['�']='平衡牧:AwAGCAQABRQAAA==.',['�']='强强战神:AwAICBoABAoDEAAIAQhxDwBIuCcCBAoAEAAHAQhxDwBGTycCBAoAAwADAQg/ZABIDqYABAoAAA==.',['�']='征服王的掠夺:AwAECAQABRQAAA==.',['�']='性感的虾条:AwAECAQABRQAAA==.',['�']='惩戒之刃:AwAICAgABAoAAA==.',['�']='我真的太难了:AwABCAEABRQAAA==.',['�']='扔白的雪子:AwACCAUABRQCEQACAQgxEwBVOMcABRQAEQACAQgxEwBVOMcABRQAAA==.',['�']='捏起來肉肉哒:AwABCAEABRQDEgAIAQg1AQBiH+YCBAoAEgAIAQg1AQBiH+YCBAoACwAFAQigegBSrYUBBAoAAA==.捏起来肉肉哒:AwAFCBUABRQCEwAFAQi5AQBbdKoBBRQAEwAFAQi5AQBbdKoBBRQAAA==.',['�']='放肆的溫柔:AwAECAQABRQAAA==.',['�']='教父:AwAECAQABRQAAA==.',['�']='星界夜鹰:AwAICBAABAoAAA==.星见雅:AwAICAIABAoAARQAU0EECAQABRQ=.是满满呀:AwAECAgABRQCDAAEAQg0DwAf3dEABRQADAAEAQg0DwAf3dEABRQAAA==.',['�']='晴風:AwACCAIABRQAAQsAQ6wGCAcABRQ=.',['�']='木小沫:AwAFCAUABAoAAA==.机智的小满满:AwAHCAcABAoAAQwAH90ECAgABRQ=.',['�']='权倾一世:AwAFCAkABAoAAA==.杜皮和帝皮:AwAGCAYABAoAAA==.来口芥末么:AwAGCA0ABAoAAA==.',['�']='极饿生灵:AwADCAUABRQCDAADAQiNEgBIPq4ABRQADAADAQiNEgBIPq4ABRQAAA==.',['�']='柠檬冰茶:AwACCAIABAoAAA==.',['�']='梦游师:AwAGCAkABAoAAA==.梦逐芭蕉雨丶:AwAICAgABAoAAA==.梦魇破晓:AwAFCBUABRQDFAAFAQglAgBIXuEABRQAFAAEAQglAgBCpeEABRQAFQACAQh0DABLh78ABRQAAA==.',['�']='欧皇灬小王子:AwABCAEABAoAAA==.',['�']='止殇之狂:AwAFCAgABAoAAA==.正经圣光:AwAECAQABRQAAA==.',['�']='永恒飞鸟:AwAICA8ABAoAAA==.',['�']='汤汤:AwACCAIABAoAAA==.',['�']='沐雪微寒:AwADCA0ABRQCFgADAQiGCQBPaBEBBRQAFgADAQiGCQBPaBEBBRQAAA==.沙白填:AwADCAMABRQAAA==.没头脑:AwABCAEABRQAAA==.没想到吧:AwAECAIABRQAAA==.治愈系芒果丶:AwAFCBAABRQDDwAFAQiDAABgjqQBBRQADwAFAQiDAABdYqQBBRQADgAEAQhzCgBYFhsBBRQAAQcAAAAICAIABRQ=.',['�']='泡面丶:AwACCAIABRQAAA==.',['�']='洛丹伦的太阳:AwAGCAYABRQCFwAGAAgAAAAj1wAABRQABQAGAAgAAAAj1wAABRQAAA==.',['�']='海绵瓜瓜:AwAECBAABRQCDAAEAQibBgBOcRwBBRQADAAEAQibBgBOcRwBBRQAAA==.',['�']='清风拂过:AwAECAgABAoAAA==.',['�']='炼狱久久:AwACCAQABRQAAA==.',['�']='熊熊猫了丶:AwADCAYABRQCCwADAQi2LAA5t5YABRQACwADAQi2LAA5t5YABRQAAA==.',['�']='牛多重:AwAFCBMABRQDDwAFAQjMAABRcHYBBRQADwAEAQjMAABRcHYBBRQADgADAQjaJgBNMZkABRQAAA==.特麽劈我瓜:AwAECAYABAoAAA==.',['�']='狂人麦迪:AwACCAYABRQCDgACAQhVMwAVEHEABRQADgACAQhVMwAVEHEABRQAAA==.狐人总冠军:AwAICBQABAoCEQAIAQhYNAA6GZUBBAoAEQAIAQhYNAA6GZUBBAoAAA==.',['�']='王不留行:AwAICAYABAoAAQcAAAABCAEABRQ=.玛薇卡:AwAGCAYABAoAAA==.',['�']='瑞兹:AwAICAsABAoAAA==.瑞驰:AwAECAgABRQCAQAEAQjxAgBdsEoBBRQAAQAEAQjxAgBdsEoBBRQAAA==.',['�']='痞帅:AwAECAgABRQCCwAEAQjLEABKcQQBBRQACwAEAQjLEABKcQQBBRQAAA==.',['�']='白河凶鸟:AwAICAgABAoAAA==.',['�']='皮叽兔:AwAFCBUABRQCGAAFAQhdAgBFL2ABBRQAGAAFAQhdAgBFL2ABBRQAAA==.皮叽叽:AwABCAEABRQAAA==.',['�']='睿翊:AwAECAQABRQAAA==.',['�']='破碎的光明:AwAICAgABAoAAA==.',['�']='碎星:AwAICAgABAoAAA==.',['�']='神之一手:AwAGCAwABAoAAA==.',['�']='秋泠:AwAECAQABRQAAA==.秦妈妈:AwAECAgABRQDGQAEAQj2BQBJFPUABRQAGQAEAQj2BQBJFPUABRQAEQAEAQgzGwAJy5QABRQAAA==.秦媽媽:AwAICAYABAoAAA==.',['�']='究极无敌:AwAECAQABRQAAA==.',['�']='米斯思:AwAFCAsABRQCGgAFAQirAgA13FUBBRQAGgAFAQirAgA13FUBBRQAAQwAOU0GCAkABRQ=.',['�']='糖尸三摆手:AwABCAEABAoAAA==.',['�']='紫云统夜:AwAECAYABRQCDgAEAQgGEQBMg/0ABRQADgAEAQgGEQBMg/0ABRQAAQcAAAAICAQABRQ=.',['�']='续不上龙喷了:AwACCAIABAoAAA==.',['�']='耳龙:AwAECAsABRQDGwAEAQjwDwBLMqoABRQAGwACAQjwDwBBQaoABRQAHAADAQiaBABNiqYABRQAAQgARaYFCAoABRQ=.',['�']='肚皮君:AwAGCAYABRQCEAAGAQi0AAAwlLwBBRQAEAAGAQi0AAAwlLwBBRQAAA==.',['�']='胸小还无脑:AwACCAIABAoAAA==.',['�']='艾黛尔贾特:AwAICAYABAoAAA==.',['�']='芒果呐丶:AwAECAgABRQCAgAIAQgULgA6qdYBBAoAAgAIAQgULgA6qdYBBAoAAA==.花甲:AwAECAMABRQDAwAIAQiQIgA+MfUBBAoAAwAIAQiQIgA+MfUBBAoAEAABAQhVWQA3P0EABAoAAA==.',['�']='若蓠:AwAICAUABAoAAA==.',['�']='茉莉雨:AwAFCAoABRQDCAAFAQhZBgBFpvQABRQACAAEAQhZBgBAr/QABRQACQACAQikHwAtYJMABRQAAA==.',['�']='荳包:AwAGCAYABAoAAA==.',['�']='莳丶緔:AwABCAEABRQAAA==.',['�']='萌了个德呀:AwAGCAcABAoAAA==.',['�']='蔷薇九环:AwADCAYABRQCEwADAQiYDwAjit0ABRQAEwADAQiYDwAjit0ABRQAAA==.',['�']='藕藕总:AwAGCAkABAoAAA==.',['�']='蛊毒修罗:AwACCAIABAoAAA==.',['�']='血中悍刀行:AwADCAQABAoAAA==.',['�']='观心知天下:AwACCAIABAoAAA==.',['�']='说谎丶给你听:AwAICA0ABAoAAA==.',['�']='豪豬吉列姆:AwAFCAkABRQEHQAFAQhWDQBgeuIABRQAHQACAQhWDQBie+IABRQAHgABAQjMEgBhhHIABRQAHwACAQibCQBbbmgABRQAAA==.',['�']='贝簏丹尼:AwAFCAUABAoAAA==.',['�']='赤炎马:AwADCAkABRQDBQADAQj7AwA8XxoBBRQABQADAQj7AwA5ORoBBRQADQACAQgCDQAcIoQABRQAAA==.',['�']='路易斯丶圣光:AwAHCBYABAoCCwAHAQhlRgBVngMCBAoACwAHAQhlRgBVngMCBAoAAA==.',['�']='里芙:AwAGCA4ABRQCHQAGAQiaAABDofYBBRQAHQAGAQiaAABDofYBBRQAAA==.',['�']='铁臀霹雳火:AwACCAIABRQAAA==.',['�']='闷骚的花生:AwADCAMABAoAAA==.',['�']='陌上花开:AwACCAIABAoAAA==.陳皮话梅糖:AwADCAMABAoAAA==.',['�']='雨纷纷:AwAICBkABAoDIAAIAQgxBgBY+lECBAoAIAAIAQgxBgBXclECBAoAAgAIAQhYHgBMAS4CBAoAAQEAEH4GCAwABRQ=.雪悦:AwAFCAUABAoAAA==.零点一卡路里:AwACCAIABRQAAA==.',['�']='风之悲伤:AwAGCAYABAoAAA==.',['�']='饺子就酒:AwAGCAYABAoAAQcAAAAICAgABAo=.',['�']='香蕉老巴巴:AwADCAMABRQAAA==.',['�']='髭男:AwAECA4ABRQEHwAEAQgrAwBi0eQABRQAHwAEAQgrAwAeSeQABRQAHgADAQhmCABiet4ABRQAHQACAQi3FgBF4acABRQAAA==.',['�']='麦酷咚:AwACCAIABAoAAA==.',['�']='黑铁大叔:AwADCAMABAoAAA==.',['�']='龙痰泡面:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end