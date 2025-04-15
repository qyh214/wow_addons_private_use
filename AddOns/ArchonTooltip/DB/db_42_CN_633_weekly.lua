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
 local lookup = {'Warlock-Destruction','Warlock-Affliction','Mage-Frost','DemonHunter-Havoc','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','Mage-Fire','Priest-Shadow','Unknown-Unknown','Warlock-Demonology','Warrior-Fury','Paladin-Retribution','Druid-Balance','Druid-Restoration','Paladin-Protection','Evoker-Devastation','Druid-Feral','Shaman-Restoration','Shaman-Enhancement','Shaman-Elemental','Warrior-Arms','Warrior-Protection','Hunter-BeastMastery','Paladin-Any','Druid-Guardian','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','DeathKnight-Blood',}; local provider = {region='CN',realm='天空之墙',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adah:AwAECAQABRQAAA==.',Ar='Arlinna:AwADCAMABRQAAA==.',Bi='Biabiabia:AwAECAMABRQAAA==.',Br='Brutal:AwAICAQABRQAAA==.',Bu='Bubble:AwACCAIABRQAAA==.',Ca='Callmewhy:AwAECAQABRQAAA==.',Co='Coisini:AwAGCAYABRQDAQAEAQgfDwAqtc4ABRQAAQAEAQgfDwAqtc4ABRQAAgACAQgGEQAfd30ABRQAAA==.',Cr='Crazystory:AwAHCAcABAoAAA==.Cream:AwABCAEABRQCAwAIAQgfEQBKHVYCBAoAAwAIAQgfEQBKHVYCBAoAAA==.',Di='Diie:AwABCAEABAoAAA==.',El='Electricicn:AwAECAQABAoAAA==.Elvesordinar:AwAICAgABAoAAA==.',Er='Eric:AwAECAQABRQAAA==.Erichsen:AwAECAkABRQDAQAEAQgZAwBe6DwBBRQAAQAEAQgZAwBe6DwBBRQAAgAEAQgOBgAxGu8ABRQAAA==.',Ev='Evellynn:AwAGCAYABAoAAA==.Everglow:AwAFCAkABAoAAA==.',Hs='Hsy:AwAICAgABAoAAA==.',Is='Issoulss:AwAECAQABRQAAA==.',Ke='Kennen:AwAICAgABAoAAA==.',Ku='Kururugi:AwACCAIABRQAAA==.',La='Lansdry:AwAGCAwABAoAAA==.',Le='Letmebiu:AwACCAIABRQAAA==.',Lu='Lululaibao:AwACCAIABRQAAA==.',Lw='Lww:AwAGCAIABRQAAA==.',Ma='Mallory:AwACCAIABRQAAA==.Malphitee:AwAICBIABAoAAQQAKt4GCA4ABRQ=.Martinus:AwACCAIABRQAAA==.Max:AwACCAIABRQAAA==.',Mi='Misuuta:AwAHCAQABAoAAA==.',Mo='Mondlicht:AwADCAIABRQAAA==.',Op='Opa:AwACCAMABRQCBQAIAQiMFgBDq+UBBAoABQAIAQiMFgBDq+UBBAoAAA==.',Ou='Ouhang:AwAICAgABAoAAA==.',Pr='Prewar:AwADCAIABAoAAA==.Prontfrogin:AwABCAEABAoAAA==.',Sa='Sammael:AwAICAwABAoAAA==.',Sm='Smilever:AwAECAQABRQAAA==.',Ta='Takiku:AwACCAIABRQAAA==.',Th='Theseu:AwAICBAABAoAAA==.',Ve='Veyra:AwAHCAYABAoAAA==.',Zh='Zhangg:AwACCAIABAoAAA==.Zhangthree:AwAECAQABRQAAA==.',['�']='一吻别一:AwAGCAcABAoAAA==.一头老母牛:AwAGCAgABAoAAA==.一生所盼:AwAECAYABRQDBgAEAQgnDAALpq8ABRQABgAEAQgnDAALpq8ABRQABwABAQgHJAAmgj8ABRQAAA==.一米八:AwADCAMABAoAAA==.一米高:AwAECA0ABRQDAwAEAQiBAQBbFy4BBRQAAwAEAQiBAQBbFy4BBRQACAABAQgwNQAWdDcABRQAAA==.一颗小坚果:AwAHCAcABRQCCQAHAQhwAAAyLQACBRQACQAHAQhwAAAyLQACBRQAAA==.三百克:AwAICAgABAoAAA==.上吧皮卡皮卡:AwADCAMABRQAAA==.下水道里的僧:AwAECAgABRQCBwAEAQj4BwBHSAgBBRQABwAEAQj4BwBHSAgBBRQAAQoAAAAGCAQABRQ=.不啦牛仔:AwADCAIABRQAAA==.不死骑士灬:AwABCAEABRQAAA==.不爱挠痒的牛:AwAICBIABAoAAA==.不能喝就回家:AwAECAMABRQAAA==.东北一米九丶:AwAECAUABAoAAA==.东方有奶丶:AwAECAQABRQAAA==.东方灬澄澄:AwAICAgABAoAAA==.东门龙王:AwAICA4ABAoAAA==.丨何欣橙灬:AwACCAIABRQAAA==.丨夜雨声烦:AwAECAQABRQAAA==.丨張翼德丨:AwAECAQABRQAAA==.丨詩情畫意丨:AwAICA8ABAoAAA==.丶俺不会武丶:AwABCAEABAoAAA==.丶噬丨灵:AwAICAgABAoAAA==.丶式微:AwAGCAwABRQDAQAEAQgwBwBG/gUBBRQAAQAEAQgwBwBG/gUBBRQACwABAQiaFgAAAAAABRQAAA==.丶怒羽:AwABCAEABAoAAA==.丶慕霖夕:AwABCAEABRQAAA==.丶無法釋懷:AwADCAoABRQCDAADAQiiDAArcvgABRQADAADAQiiDAArcvgABRQAAA==.丶爱晴天:AwAECAYABRQCDQAEAQhsFwArxecABRQADQAEAQhsFwArxecABRQAAA==.丶鸾辂音尘:AwACCAIABRQAAA==.丹羽之泪:AwAICAgABAoAAA==.丹羽之涙:AwAICAgABAoAAA==.丿癫疯:AwADCAMABRQAAQcAIA0ICAMABRQ=.',['�']='乄大灰狼:AwAHCAcABAoAAA==.乌夕夕:AwAICAgABAoAAA==.九重嘤:AwADCAMABRQAAA==.乞丐包:AwABCAEABAoAAA==.',['�']='云梦点星河:AwAFCAUABAoAAA==.亚兰德隆:AwABCAIABRQDDgAIAQiPGwBKukMCBAoADgAIAQiPGwBKukMCBAoADwADAQjtdAAENzcABAoAAA==.',['�']='今晚九点睡:AwAGCAQABAoAAA==.以此为念:AwAECAgABRQDDQAEAQg+DQBP8AsBBRQADQAEAQg+DQBP8AsBBRQAEAAEAQhQCgAW25EABRQAAA==.',['�']='会点拳脚:AwAFCAUABAoAAA==.伤心小勺子:AwADCAMABRQAAA==.',['�']='佐手丶:AwAICBEABAoAAA==.何以为戰:AwACCAIABRQAAA==.',['�']='依楼丶听雨:AwAGCAUABAoAAA==.依然小七:AwAECAQABRQAAA==.',['�']='倾心丨一箭灬:AwACCAIABRQAAA==.',['�']='側耳倾听:AwAECAQABRQAAA==.',['�']='全都不会玩:AwAECAIABRQAAA==.全麻脑子坏特:AwAECAcABAoAAA==.八卦定乾坤:AwAGCAEABAoAAA==.六边形武僧:AwACCAMABRQAAA==.',['�']='冰焦糖玛奇朵:AwACCAMABRQAAA==.冰鎮檸檬:AwAICAgABAoAAA==.',['�']='减肥五十斤:AwAGCA4ABRQDAwAGAQhnAQA5cjABBRQAAwAEAQhnAQBZwzABBRQACAAGAQjiFAAk6+YABRQAAA==.',['�']='刀锋女皇萧:AwADCAMABRQAAA==.刘德滑:AwAECAQABRQAAA==.别想太多丶:AwAECAQABRQAAA==.',['�']='前日之后:AwAICAgABAoAAA==.',['�']='力中暴力:AwACCAIABRQAAA==.',['�']='千鹤:AwAECAQABRQAAA==.半夜缺氧:AwAICAgABAoAAA==.单手插兜:AwAICBEABAoAAA==.卖萌的蛮王:AwAGCAcABAoAAA==.卿淺吻:AwAECAQABRQCEAAEAQiqDAALsHQABRQAEAAEAQiqDAALsHQABRQAAA==.',['�']='厚礼小小谢:AwAECAQABAoAAA==.',['�']='双剑华斩:AwAFCAQABRQAAA==.双鱼理灬:AwAICAEABAoAAA==.发财:AwAICAgABAoAAA==.口可口乐:AwAECAQABAoAAA==.古拉加丝:AwACCAIABRQAAA==.叫我壮壮:AwAECAMABAoAAQoAAAAICAgABAo=.',['�']='吃我星涌术:AwACCAEABAoAAA==.吉川爱美:AwADCAUABAoAAA==.吨吨小脑斧:AwABCAEABRQAAA==.吨吨楠:AwABCAMABRQAAA==.吾为天帝:AwAHCAIABAoAAA==.吾乃你奶娘:AwAECAQABRQAAA==.',['�']='告死天使:AwADCAEABAoAAREALMQBCAMABRQ=.呼噜瓦:AwABCAEABRQAAA==.',['�']='咕咕大萌德:AwAECAQABRQAAA==.',['�']='善良的大胖熊:AwADCAMABRQAAA==.',['�']='噩梦的小德:AwAECAQABRQAAA==.',['�']='四妹:AwADCAMABRQAAA==.',['�']='圣光保佑你:AwAICCAABAoDEAAIAQjuIwAY1wQBBAoAEAAIAQjuIwAY1wQBBAoADQAIAQiu0QAKsMwABAoAAA==.',['�']='塔比酱丶:AwAECAQABRQAAA==.塞弗斯:AwAICAgABAoAAA==.塞恩特:AwACCAIABRQAAA==.',['�']='墨雨轩:AwAECAQABRQAAA==.',['�']='夏始仁:AwAECAQABRQAAA==.大屁屁丫丫:AwAGCAMABAoAAA==.大屁屁提莫:AwAICAgABAoAAA==.大香批:AwAICAgABAoAAA==.天才中年人:AwAICA4ABAoAAA==.天牛下凡:AwADCAUABRQCEgADAQhaAgAlBd4ABRQAEgADAQhaAgAlBd4ABRQAAA==.天空没有极限:AwAECAQABRQAAQgATAYICA0ABRQ=.天蓝赞歌:AwACCAMABRQAAA==.太空喵:AwACCAQABRQAAA==.',['�']='奈白的鳕子:AwAECAgABRQCCAAEAQjqEAA/sfMABRQACAAEAQjqEAA/sfMABRQAAA==.女神的爱子:AwAECAQABRQAAA==.奺亿少女的梦:AwAGCAQABRQAAA==.',['�']='婷儿宝宝:AwAGCAYABRQCBwAGAQhMAQAp3bABBRQABwAGAQhMAQAp3bABBRQAAA==.',['�']='孤睾索尼克:AwAICA8ABAoAAA==.',['�']='宁德时代:AwAICAgABAoAAA==.宁静一夏:AwAGCAgABAoAAA==.宝藏男孩坤坤:AwAECAQABRQAAA==.',['�']='小丶单车:AwAECAsABRQCBgAEAQhtAwBRSS0BBRQABgAEAQhtAwBRSS0BBRQAAA==.小丶娘子:AwAGCAwABRQDEAAGAQjhAAA+iJUBBRQAEAAGAQjhAAA76ZUBBRQADQAEAQi7HAAwldAABRQAAA==.小安安一号:AwACCAQABRQAAA==.小神龙:AwAFCAUABAoAAA==.小萨满灬:AwABCAEABRQAAA==.小鹿萌萌:AwAHCAEABAoAAA==.尼沫:AwAGCAsABAoAAA==.',['�']='川丨宝:AwAECAQABRQAAA==.工作称职务:AwAICAgABAoAAA==.左岸浅析:AwAICAgABAoAAA==.',['�']='布乄丁:AwAICAgABAoAAA==.',['�']='幻影丨:AwAGCAYABAoAAA==.广末凉子丶:AwABCAEABAoAAA==.',['�']='庶民之罪:AwACCAQABRQCEwAHAQhfIABLvvABBAoAEwAHAQhfIABLvvABBAoAAA==.',['�']='当胖胖:AwAGCAUABAoAAA==.彦祖:AwAHCAcABAoAAA==.彩笔冰血包:AwAGCAcABAoAAA==.彩笔木丝包:AwACCAIABRQAAA==.',['�']='得撸你:AwABCAIABRQDFAAIAQhRGgAxIdwBBAoAFAAIAQhRGgAxIdwBBAoAFQABAQhRfgAAAAAABAoAAA==.微醺弹头:AwABCAEABAoAAA==.德小晓:AwAICAoABAoAAA==.',['�']='恐怖的地狱火:AwAGCAYABAoAAA==.恶梦的开始:AwABCAEABRQAAA==.',['�']='悲伤辣莫大丶:AwACCAMABAoAAA==.',['�']='愤怒的小鸭子:AwAICAgABAoAAA==.',['�']='戏如人生灬:AwABCAEABRQAAA==.我赌他是个屁:AwAECAoABRQCEgAEAQiAAQA+AhABBRQAEgAEAQiAAQA+AhABBRQAAA==.我黑切呐:AwAECAYABRQDDAAEAQihEAA4qdMABRQADAAEAQihEAASj9MABRQAFgACAQg7CgBMgKMABRQAAA==.戒网:AwAECAQABRQAAA==.战斗小子:AwAECAQABRQAAA==.',['�']='手刃队友:AwAECAQABRQAAA==.打会儿大眯眯:AwAICAgABAoAAA==.',['�']='折戟丶沉沙:AwAICAgABAoAAA==.',['�']='拉斐尔:AwAFCAkABAoAAA==.',['�']='捏你蛋蛋痛:AwAECAIABRQAAA==.',['�']='插灬棍棍:AwAGCA4ABAoAAA==.',['�']='摩卡丶:AwAECAQABRQAAA==.摩卡星冰乐:AwAECAQABRQAARYAN/gGCAoABRQ=.',['�']='攻强卷轴丶:AwAGCAYABRQDDAAGAQgxAQBBxJsBBRQADAAFAQgxAQBGn5sBBRQAFgABAQiGDwAuW14ABRQAAA==.',['�']='无名指的戒:AwAICAgABAoAAA==.',['�']='星星的男朋友:AwACCAIABAoAAA==.星野真理:AwAICAgABAoAAA==.是只小咕咕:AwAECAcABAoAAA==.是富贵吖:AwAECBEABRQDDAAEAQj6AwBXPjUBBRQADAAEAQj6AwBXPjUBBRQAFwABAQi/CwAMlzAABRQAAA==.是福栗吖:AwAICAgABAoAAA==.',['�']='暖男排狗后边:AwAECAsABRQCBQAEAQiXBQBNxfwABRQABQAEAQiXBQBNxfwABRQAAA==.暮雨灬潇潇:AwAGCAYABAoAAA==.暴躁橘子皮:AwAECAwABRQCGAAEAQh/CgBVQhQBBRQAGAAEAQh/CgBVQhQBBRQAAQoAAAAICAQABRQ=.',['�']='曼彻斯特丶联:AwACCAIABAoAAA==.',['�']='最爱娇娇:AwAICBQABAoCDQAIAQhAIgBShXcCBAoADQAIAQhAIgBShXcCBAoAAA==.月城雪兔:AwACCAIABRQAAA==.月影天涯一号:AwABCAEABRQAAA==.有德必有尸丷:AwAGCAYABAoAAA==.有毒图腾:AwABCAEABAoAAA==.朕的大清呢:AwAFCAUABAoAAA==.未央丷:AwADCAMABRQAAA==.末藍朶児:AwAECAgABRQCGQAEAAgAAABX7AAABRQADQAEAAgAAABX7AAABRQAAA==.本宫:AwAECAQABRQAAA==.',['�']='杨小丽光头:AwAGCAIABAoAAA==.',['�']='柠檬撞可乐:AwACCAQABAoAAA==.柠檬花扣:AwAECAQABRQAAA==.',['�']='核聚变打击:AwADCAoABRQCEwADAQj4AgBXFzQBBRQAEwADAQj4AgBXFzQBBRQAAA==.格羅瑪什:AwACCAIABAoAAA==.',['�']='梦游梦回:AwABCAEABRQAAA==.',['�']='棒棒呼叫洞洞:AwAICAsABAoAAA==.',['�']='氮磷砷锑铋:AwACCAIABRQAAA==.水煮鸡胸肉:AwACCAIABRQAAA==.',['�']='汉堡王:AwABCAEABRQAAA==.池子丶:AwAICBgABAoCDQAIAQjjKABbW10CBAoADQAIAQjjKABbW10CBAoAAQgAXAQGCAEABRQ=.污夭亡吖:AwAICBAABAoAAA==.',['�']='河北吴彦祖:AwAGCAcABAoAAA==.',['�']='波普艺术家:AwAECAQABRQAAA==.泰瑞利亚:AwAECAIABRQAAA==.',['�']='浩宇哥哥:AwAECAQABRQAARgAPf8GCAkABRQ=.海香君:AwABCAEABRQDGAAIAQjMBQBg1PICBAoAGAAIAQjMBQBgzfICBAoABQAEAQg9MwBYexkBBAoAAA==.',['�']='消失的玛雅:AwAECAQABRQAAA==.',['�']='深渊小姿:AwAICAcABAoAAA==.',['�']='温柔的大锤像:AwADCAMABRQAAA==.',['�']='溜溜梅灬:AwAECAQABRQAAA==.溟之绯雨:AwAECAQABRQAAA==.溪溪:AwAICBYABAoFDgAIAQi+JABLUQoCBAoADgAIAQi+JABLUQoCBAoAEgAEAQhrGwAwkrYABAoADwACAQhQVQA+YJEABAoAGgACAQjuHgBBamkABAoAAA==.',['�']='潇洒沋能打:AwAICAoABAoAAA==.',['�']='灬七尺美髯公:AwAGCAsABAoAAA==.灬傲娇灬:AwADCAgABRQDAwADAQi0AQBVBSoBBRQAAwADAQi0AQBVBSoBBRQACAABAQj/NgAEiS0ABRQAAA==.灬晓风残月灬:AwAICAoABAoAAA==.灬香消玉损:AwAICA0ABAoAAA==.灭绝师太:AwAICA8ABAoAAA==.',['�']='烟雨清寒:AwAECAQABRQAAA==.',['�']='無輌壽仏:AwAICAoABAoAAA==.',['�']='煎饼小辣椒:AwAGCAIABRQAAA==.',['�']='熊小小:AwAICA4ABAoAAQoAAAAICAQABRQ=.熊懋:AwACCAIABRQAAA==.',['�']='爆炒萝卜丝:AwAFCAEABAoAAA==.爱上牛妞:AwABCAEABRQAAA==.爱莉希雅丶:AwAICAgABAoAAA==.爽歪歪:AwAFCAUABAoAAA==.',['�']='狐先锋丶:AwAECAQABRQAAA==.狐步舞者:AwAECAQABAoAAA==.狗子的大宝:AwADCAMABRQAAA==.狡猾:AwACCAIABRQAAA==.独山玉:AwABCAEABRQAAA==.狮心勇士:AwADCAgABRQCDAADAQhxDQAoAvMABRQADAADAQhxDQAoAvMABRQAAA==.',['�']='王老爷子:AwAICAgABAoAAA==.',['�']='瑞斯坦福:AwADCAMABRQAAA==.',['�']='瓦娜斯丶逐风:AwAICAgABAoAAA==.',['�']='瘦浣熊:AwAICAsABAoAAQoAAAABCAIABRQ=.',['�']='白米饭:AwAGCAIABRQAAA==.白雷丶:AwAICAIABAoAAA==.白露丨未晞:AwABCAEABAoAAA==.',['�']='皇家礼炮丶:AwABCAEABAoAAA==.皮一蛋:AwACCAYABRQCBgACAQhRDwAr6JEABRQABgACAQhRDwAr6JEABRQAAA==.',['�']='盲人世界:AwADCAMABRQAAA==.',['�']='真理:AwAECAQABRQAAA==.眾生無冥:AwAICAgABAoAAA==.',['�']='瞎子尔曼:AwAICAgABAoAAA==.',['�']='矬子一个:AwAGCAwABAoAAA==.',['�']='神棍德灬:AwABCAIABRQAAA==.神避:AwAECAQABRQAAA==.',['�']='竹剑豪:AwAICAkABAoAAQoAAAAICAQABRQ=.',['�']='第七正义:AwADCAMABAoAAA==.',['�']='等两天咯:AwAICAkABAoAAA==.等我搞哈幻化:AwAECAEABRQAAA==.',['�']='箭射硬汉:AwACCAQABRQAAA==.',['�']='糖仁:AwAGCAcABAoAAA==.',['�']='紫咖啡:AwACCAIABRQDGwAGAQh2SQAb0OMABAoAGwAGAQh2SQAabeMABAoAHAAFAQiDVwAYiJIABAoAAA==.',['�']='红灬紫:AwAGCAYABRQDAQAGAQgcAgA80FgBBRQAAQAFAQgcAgBBklgBBRQACwABAQiSCgApyFsABRQAAA==.红紫:AwAICAcABAoAAA==.',['�']='给我点时间丶:AwADCAMABRQAAA==.绝代芳华:AwAECAQABRQAAA==.绝对旋律:AwABCAEABRQAAA==.绯翊:AwAICBsABAoCGAAIAQg7IABLwlsCBAoAGAAIAQg7IABLwlsCBAoAAA==.维斯塔潘:AwADCAMABAoAAA==.绿瘦:AwAFCAUABAoAAA==.',['�']='罙丶爱:AwAECAcABRQDHQAEAQiNDAA4secABRQAHQADAQiNDAA4secABRQAHgAEAQikDQAmEawABRQAAA==.',['�']='美人鱼戰士:AwAECAUABAoAAA==.',['�']='老米丶:AwAICAYABAoAAQoAAAAICAQABRQ=.',['�']='联盟大机炮:AwAECAQABAoAAA==.聖丶骑:AwAHCAIABAoAAA==.',['�']='胖娃也能飞:AwAECAQABRQAAA==.胡子牛:AwADCAQABAoAAA==.',['�']='脸型帕鲁:AwAICAgABAoAAA==.',['�']='艾克朴:AwAECAYABRQCDAAEAQilDQAvuvEABRQADAAEAQilDQAvuvEABRQAAA==.艾缌米达:AwACCAMABRQDDwAIAQgmDgBO6zsCBAoADwAIAQgmDgBO6zsCBAoADgAEAQixWgA6lBIBBAoAAA==.艾雅丨萌太奇:AwACCAMABRQAAA==.',['�']='芝士碧螺春:AwADCAMABAoAAA==.芭芙姬丶:AwACCAIABRQAAA==.',['�']='萌萌的晓耳朵:AwAICAgABAoAAA==.萌薪:AwAICBAABAoAAA==.萝莉丶:AwAICAgABAoAAA==.萨达哈噜:AwADCAcABRQDAQADAQhGEABbccgABRQAAQACAQhGEABbRcgABRQAAgACAQiKCgBBCrUABRQAAA==.落叶丨随风起:AwADCAMABRQAAA==.',['�']='蒙牛之牛:AwAICAEABAoAAA==.',['�']='蓝蒂芙蓉王:AwAICBAABAoAAA==.',['�']='藕总:AwADCAMABAoAAA==.',['�']='虛靈之刃:AwAHCAkABAoAAA==.',['�']='蛮丨德:AwAECAIABRQAAA==.',['�']='蜥蜴人:AwAICAgABAoAAA==.',['�']='行屍赱肉:AwACCAIABRQAAA==.',['�']='裂歌丶格雷:AwAICBAABAoAAA==.',['�']='西瓜二号:AwAICAYABAoAAA==.',['�']='言情喜剧丶:AwAICAwABAoAAA==.',['�']='詹姆士:AwABCAEABRQAAA==.',['�']='诛恶:AwAGCAYABAoAAA==.',['�']='豆豉蒸柳丁:AwAICA4ABAoAAA==.',['�']='赵丶本山:AwAECAwABRQDHgAEAQjeBABRsBoBBRQAHgADAQjeBABRsBoBBRQAHQACAQglJQADJjUABRQAAA==.',['�']='跳动的音符儿:AwAECAQABAoAAA==.',['�']='踏血邪法:AwAECAQABRQAAA==.',['�']='运气选手:AwAICAgABAoAAA==.',['�']='逆我者变羊:AwAICAgABAoAAA==.逆风之翼:AwAHCBIABAoAAA==.',['�']='邪恶波比:AwAECAwABRQECwAEAQipAQBJPQIBBRQACwAEAQipAQA/XgIBBRQAAgADAQhjBQBIFPUABRQAAQAEAQgxDQAxMtoABRQAAQEAXx8ICAUABRQ=.邪灵天降:AwAECAQABRQAAA==.',['�']='酸菜牛:AwAICAwABAoAAA==.',['�']='重案组之狼:AwADCAMABRQAAA==.',['�']='钢炮:AwAECAQABAoAAA==.钦点的武举人:AwACCAcABRQCHQACAQjIDgBbs9cABRQAHQACAQjIDgBbs9cABRQAAA==.',['�']='锂钠钾铷铯钫:AwACCAIABRQAAA==.',['�']='长衫罩子龙:AwAHCAEABAoAAA==.',['�']='雨落纱幔:AwAECAQABAoAAA==.雨落飞剑:AwAGCAEABAoAAA==.雪落丶千寒:AwAICAMABAoAAA==.',['�']='霜殇:AwAICA0ABAoAAA==.霜火之忆:AwAGCAQABAoAAA==.',['�']='青妤:AwAICAgABAoAAA==.青岚:AwAICAgABAoAAA==.非洲老酋长:AwAECAgABRQCDAAEAQjVAgBeVEkBBRQADAAEAQjVAgBeVEkBBRQAAA==.',['�']='风大咪眯晃:AwAGCAQABRQCEAAEAQiwBABGh/MABRQAEAAEAQiwBABGh/MABRQAAA==.风浅:AwAGCAUABRQCGAAEAQhPDgBUVwEBBRQAGAAEAQhPDgBUVwEBBRQAAA==.飞花:AwACCAIABAoAAA==.',['�']='香草星冰乐:AwAGCAgABRQCDgAEAQhzEwArdtIABRQADgAEAQhzEwArdtIABRQAAQoAAAAICAIABRQ=.',['�']='马踏樱花:AwACCAMABAoAAA==.',['�']='高阶圣殿骑士:AwAICAgABAoAAA==.',['�']='魔咕:AwABCAIABRQDDgAIAQg/IQBDQiACBAoADgAIAQg/IQBDQiACBAoADwACAQibgAADhCMABAoAAA==.魔心:AwAGCAoABAoAAQoAAAAICAgABAo=.魔鈊:AwAICAgABAoAAA==.',['�']='鱿鱼大侠丶光:AwAECAQABRQAAA==.',['�']='鲨鱼辣椒乂:AwACCAIABRQAAA==.',['�']='黄油啤酒灬:AwAHCAYABAoAAQcAYnUECBIABRQ=.黑天:AwAFCAUABAoAAA==.黑暗来者:AwABCAEABAoAAA==.黯翼飞宵:AwADCAEABAoAAA==.',['�']='龟龟成功入水:AwAFCAUABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end