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
 local lookup = {'Mage-Frost','Mage-Fire','DemonHunter-Havoc','DeathKnight-Unholy','Evoker-Devastation','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Paladin-Protection','Priest-Discipline','Warrior-Arms','Warrior-Protection','Monk-Mistweaver','DeathKnight-Frost','Monk-Brewmaster','Priest-Shadow','Druid-Restoration','Druid-Balance','Priest-Holy','Shaman-Enhancement','Paladin-Holy','Warrior-Fury','Warlock-Affliction','Rogue-Subtlety','Monk-Windwalker','Shaman-Elemental','Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Shaman-Restoration','Druid-Guardian','Evoker-Preservation','Evoker-Augmentation','Rogue-Outlaw','Rogue-Assassination','Hunter-Survival','DeathKnight-Blood',}; local provider = {region='CN',realm='加兹鲁维',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Asukar:AwAICAkABAoAAA==.',Bl='Blameauxlady:AwAFCAYABAoAAA==.',Da='Darthvade:AwACCAQABRQCAQAIAQjrCwBTyosCBAoAAQAIAQjrCwBTyosCBAoAAA==.',Di='Divus:AwAECAQABRQAAA==.',Dr='Druidoftclaw:AwAGCAYABAoAAA==.',Fl='Flyingmage:AwAICBkABAoCAgAIAQijHwBCqiYCBAoAAgAIAQijHwBCqiYCBAoAAA==.',Ga='Gazingfs:AwAECAQABRQAAA==.',Ha='Harutya:AwAGCA0ABAoAAA==.',Ju='Judy:AwACCAYABRQCAwACAQgMIQAbDYQABRQAAwACAQgMIQAbDYQABRQAAA==.',Ku='Kusa:AwACCAMABRQAAA==.',Li='Littlekngr:AwAICBUABAoCBAAIAQjsCwBYxqkCBAoABAAIAQjsCwBYxqkCBAoAAA==.',Lu='Lualexcky:AwAECAQABAoAAA==.',Me='Melfice:AwAECAQABRQAAA==.',Mo='Most:AwAECAQABRQAAA==.',Pe='Peaks:AwAICA8ABAoAAA==.',St='Sthdracthyr:AwADCAwABRQCBQADAQiDAwBZ4jgBBRQABQADAQiDAwBZ4jgBBRQAAA==.',Yi='Yingccf:AwABCAEABAoAAA==.',Yo='Yourmaboom:AwAECAQABRQAAA==.',['�']='一个刃的世界:AwAGCBIABAoAAA==.一位父亲:AwAICAgABAoAAA==.一只小脑斧丶:AwADCAkABRQDBgADAQhODgBBWgEBBRQABgADAQhODgBBWgEBBRQABwADAQhyCwAkEssABRQAAA==.一把小木槌:AwAGCAgABRQDCAAEAQhkBwBbOCUBBRQACAAEAQhkBwBbOCUBBRQACQAEAQh1CwAS+4IABRQAAA==.一颗大鱼卵:AwABCAEABRQCCgAIAQjtFABAefkBBAoACgAIAQjtFABAefkBBAoAAA==.一饮一啄:AwADCAYABRQDCwADAQiyAgBPNhcBBRQACwADAQiyAgBO2hcBBRQADAABAQgFCQBTAkgABRQAAA==.不开锋的刀:AwAICBQABAoCDAAIAQiREgAngF0BBAoADAAIAQiREgAngF0BBAoAAA==.不羁:AwAECAYABRQCAgAEAQjXEgA++OwABRQAAgAEAQjXEgA++OwABRQAAA==.专属宠爱:AwAHCAcABAoAAA==.专踢瘸子好腿:AwAGCAoABRQCDQAGAQjvAAA9GMwBBRQADQAGAQjvAAA9GMwBBRQAAA==.丨柠檬丨:AwAHCA0ABAoAAA==.丨雅儿贝德丨:AwAGCA4ABAoAAA==.丶潸然:AwAICAwABAoAAA==.丷忆银丷:AwAECAYABRQCAwAEAQgGFwAxqMQABRQAAwAEAQgGFwAxqMQABRQAAA==.为了坐骑:AwAFCAQABAoAAA==.',['�']='予生:AwAICCUABAoCDgAIAQhoBQBQoWACBAoADgAIAQhoBQBQoWACBAoAAA==.二两酒:AwAICAgABAoAAA==.云舒澍:AwAICBgABAoCAQAIAQhPOgAX81MBBAoAAQAIAQhPOgAX81MBBAoAAA==.人生尔尔:AwAECAQABRQAAA==.',['�']='仙尘:AwACCAYABRQDDwACAQihBgAPclwABRQADwACAQihBgAPclwABRQADQABAQgRIwANa0IABRQAAA==.',['�']='伐木机:AwAHCA8ABAoAAA==.伯瓦尔弗塔根:AwAICAgABAoAAA==.',['�']='你们缺德嗎:AwAFCAsABAoAAA==.',['�']='元素牛牛:AwAGCAYABAoAAQQAWMYICBUABAo=.光吹不要钱:AwAECAQABRQAAA==.八爪鱼:AwAICAwABAoAAA==.',['�']='农夫山泉:AwACCAIABRQAAA==.冰心本燃:AwAICA4ABAoAAA==.',['�']='初恋秦淮:AwAFCAcABAoAAA==.初露抹茶泡芙:AwACCAIABRQAAA==.别拿我打火机:AwAECAQABRQAAA==.别跑啊小姑娘:AwACCAIABRQAAA==.',['�']='北有麋鹿:AwAECAQABRQAAA==.',['�']='千与千寻:AwAECAQABRQAAA==.半夕蝶梦:AwAGCAYABRQCEAAGAQglAQA97sEBBRQAEAAGAQglAQA97sEBBRQAAA==.南曦丶寒笙:AwABCAEABAoAAA==.南熙丶寒笙:AwAECAYABRQDEQAEAQg9DgArBY8ABRQAEQADAQg9DgA1n48ABRQAEgABAQhqKQAJl0MABRQAAQYAShkGCA4ABRQ=.印第安纳:AwABCAEABRQAAA==.卷毛尐猪头:AwAHCAcABRQCDAAHAQg4AABI0MMBBRQADAAHAQg4AABI0MMBBRQAAA==.卷睫盼:AwABCAEABRQAAA==.',['�']='厄欧斯微风:AwAICCkABAoDCgAIAQj/CQBPrm4CBAoACgAIAQj/CQBOwW4CBAoAEwAHAQhUMwAz7EgBBAoAAA==.厌倦了吗:AwAICAgABAoAAA==.',['�']='参丶商:AwAFCAUABAoAAA==.可乐丶:AwABCAEABAoAAA==.',['�']='名侦探柯镇恶:AwACCAIABRQAAA==.后会无期丶:AwAICAsABAoAAA==.吾辈何以为戦:AwADCAMABAoAAA==.',['�']='呵呵大魔王:AwADCAMABAoAAQUANcsBCAEABRQ=.',['�']='哇好靓啊:AwAICA4ABAoAAA==.',['�']='嗷呜灬嗷呜:AwAICA8ABAoAARQAPEQGCAgABRQ=.',['�']='嘘丶安静:AwAHCAoABAoAAA==.嘟嘟的小肉包:AwABCAIABRQAAA==.',['�']='圣灵:AwADCAcABRQDCAADAQisHgBMAsQABRQACAADAQisHgBMAsQABRQAFQACAQi/CAA2OqcABRQAAA==.',['�']='坏血:AwAECAQABRQAAA==.',['�']='塔兰纳:AwACCAIABAoAAA==.',['�']='复活的怕辣丁:AwAFCAUABAoAAA==.多多:AwAICBIABAoAAA==.夜莺:AwAHCAwABAoAAA==.夜霜之哀:AwAICAgABAoAAA==.大奋:AwAICBEABAoAAA==.',['�']='奔雷:AwAFCAcABAoAAA==.',['�']='如故:AwABCAUABRQCBgABAQg4NABCvFEABRQABgABAQg4NABCvFEABRQAAA==.妖力:AwABCAEABRQAAA==.',['�']='姚姚者乎:AwAFCAEABAoAAA==.',['�']='嫡公主:AwABCAEABAoAAA==.',['�']='子璐:AwAICAwABAoAAA==.孑涩丶军师:AwADCAgABRQCCAADAQhVEwA0D/QABRQACAADAQhVEwA0D/QABRQAAA==.孔连顺:AwAHCAcABAoAAA==.',['�']='宇宙猎:AwAICBEABAoAAA==.安歆:AwAFCA0ABRQCFgAFAQiYAQA8rIYBBRQAFgAFAQiYAQA8rIYBBRQAAA==.安缘:AwACCAcABRQCFwACAQhzCgBM57cABRQAFwACAQhzCgBM57cABRQAAA==.完全受不鸟:AwAICBUABAoCCAAIAQhTLQBF+0wCBAoACAAIAQhTLQBF+0wCBAoAAA==.宙星辰:AwAGCAsABAoAAA==.',['�']='小喵的喵喵:AwADCAMABRQAAA==.小战愁:AwAHCA0ABAoAAA==.小瑜宝宝:AwAECAQABRQAAA==.小肥棍:AwAICCcABAoDCAAIAQhITQA/RuYBBAoACAAHAQhITQBIJeYBBAoACQABAQiVXgAKDQsABAoAAA==.',['�']='开到荼蘼:AwAHCA0ABAoAAA==.张小瑜牧:AwAGCAYABRQCCgAGAQhMAABYWg0CBRQACgAGAQhMAABYWg0CBRQAAA==.',['�']='徐尔丹:AwAHCAcABAoAAA==.',['�']='心鸽:AwAGCAYABAoAAA==.快乐的南小鸟:AwAHCBAABAoAAA==.快奶我一下:AwADCAMABAoAAA==.念颖:AwABCAEABRQAAA==.',['�']='怕辣丁同学:AwACCAIABRQAAA==.',['�']='悦之守护者:AwAICBAABAoAAA==.悦悦:AwAICAQABAoAAA==.悲酥淸风:AwAGCAIABRQCGAACAQgpEAAFvEMABRQAGAACAQgpEAAFvEMABRQAAA==.',['�']='成都必吃榜:AwAGCAYABRQCGQAGAQjuAAA+ENYBBRQAGQAGAQjuAAA+ENYBBRQAAA==.我就是明明:AwAICAgABAoAAA==.我摸摸不干嘛:AwABCAEABRQAAA==.我是你丁哥:AwAECAIABAoAAA==.我的老黑:AwAECAUABRQCGgAEAQgJBQBOiPkABRQAGgAEAQgJBQBOiPkABRQAAQYAKokICAIABRQ=.戢羽寒条:AwAGCAIABRQEGwAIAQhgBgBcUbcCBAoAGwAIAQhgBgBcUbcCBAoAFwABAQgUNQBKzlIABAoAHAABAQjWVgBTwlIABAoAAA==.',['�']='打击萨:AwACCAIABAoAAA==.打瞌睡的牛牛:AwAGCAYABAoAAA==.打瞌睡的猫猫:AwAECAUABAoAAA==.',['�']='撸王:AwAHCAEABAoAAA==.',['�']='敌敌丶畏:AwAECAQABRQAAA==.',['�']='文刀牛猎:AwAFCAYABAoAAA==.文心雕龙:AwAGCAYABAoAAA==.',['�']='无卝风月:AwAICBgABAoCDQAIAQiJJgAxlqUBBAoADQAIAQiJJgAxlqUBBAoAAA==.无敌了草:AwAGCAYABRQCEAAGAQiZAgAeNnwBBRQAEAAGAQiZAgAeNnwBBRQAAA==.无敌悦悦:AwAECAQABRQAAA==.',['�']='星星点点黑牛:AwAGCAYABAoAAA==.',['�']='晓晓亓:AwAICAgABAoAAR0AAAAICAQABRQ=.晚安尐敏:AwAGCAQABRQAAA==.',['�']='暗之浊:AwAECAQABRQAAA==.暗黑大菠萝:AwAICBAABAoAAA==.',['�']='有太多无奈:AwAICA0ABAoAAA==.有钱伤害是高:AwABCAEABAoAAA==.朕射啵:AwAICBIABAoAAA==.',['�']='李斯:AwAGCAYABAoAAA==.来网恋吖:AwAECAQABRQAAA==.杰杰的龙宝宝:AwADCAMABAoAAA==.',['�']='柒之拥:AwAFCAUABAoAAA==.查拉图斯特拉:AwABCAEABRQAAA==.柯里昂丶:AwABCAEABAoAAA==.',['�']='树静风息:AwADCAQABRQAAA==.',['�']='桃子哇哇叫:AwAECAQABRQAAA==.桃桃乐茜:AwAICCcABAoDHgAIAQjhAwBavNQCBAoAHgAIAQjhAwBavNQCBAoAGgAFAQjDLgBIUU8BBAoAAA==.',['�']='橦橦充满黑暗:AwABCAEABRQCBQAIAQhVFwA1y9MBBAoABQAIAQhVFwA1y9MBBAoAAA==.',['�']='欧洲皇室:AwAHCBEABAoAAA==.',['�']='武仙:AwAHCAQABAoAAA==.歼三五:AwAECAQABRQAARsAXx8ICAUABRQ=.',['�']='残月泣血:AwAICBgABAoCBAAIAQikBABfXesCBAoABAAIAQikBABfXesCBAoAAA==.',['�']='毅德服人:AwADCAUABRQDEgADAQhCIQAXUXMABRQAEgACAQhCIQAOXXMABRQAHwABAQj0BQApOi0ABRQAAA==.',['�']='水月:AwACCAIABRQCCAAIAQg6VQA6TtIBBAoACAAIAQg6VQA6TtIBBAoAAA==.水管潇洒哥:AwAGCAYABAoAAA==.水贼:AwAECAQABRQAAA==.水银丶燈:AwAGCAEABRQAAA==.',['�']='沐雨橙風:AwAICBoABAoDAQAIAQjnJwBI77gBBAoAAQAIAQjnJwA4zLgBBAoAAgAHAQjqMwA9grUBBAoAAA==.',['�']='法力虚空:AwAECAQABRQAAA==.',['�']='洛之骑:AwAICAgABAoAAA==.洛克斯基:AwAGCAYABAoAAA==.',['�']='温暖的僵尸:AwACCAIABRQAAA==.温温飞机:AwAGCAQABRQAAA==.游荡者:AwAICCkABAoCBwAIAQjCGgA1zcABBAoABwAIAQjCGgA1zcABBAoAAA==.',['�']='灬大師兄灬:AwAGCAgABAoAAA==.灬玳灬:AwAHCBYABAoCCAAHAQiwXwA45bcBBAoACAAHAQiwXwA45bcBBAoAAA==.灵魂连接:AwADCAgABRQDGgADAQgOBwAz7+MABRQAGgADAQgOBwAvt+MABRQAFAACAQjpDgAqyI4ABRQAAA==.',['�']='点点最可爱:AwAECAoABRQCHgAEAQgUCABFPv8ABRQAHgAEAQgUCABFPv8ABRQAAA==.',['�']='爱丽丝琳娜:AwAECAQABRQAAA==.爱吃豆皮:AwAHCAkABAoAAA==.爱吃豆皮儿:AwAHCBgABAoCBQAHAQj4EABO/xwCBAoABQAHAQj4EABO/xwCBAoAAA==.爷爷:AwABCAEABRQAAA==.',['�']='牧修缘:AwAECAgABRQCCgAEAQiQBABWNB8BBRQACgAEAQiQBABWNB8BBRQAAA==.',['�']='狂傲的小龙人:AwABCAEABAoAAA==.狂野叶:AwAECAgABRQCAgAEAQidCwBFpg0BBRQAAgAEAQidCwBFpg0BBRQAAA==.狐噜:AwAGCAYABAoAAA==.狐妖王之路:AwAECAQABRQAAA==.狩猎十年:AwABCAEABRQAAA==.',['�']='猕猴桃丶可可:AwADCAsABRQDAgADAQgBDABIiAoBBRQAAgADAQgBDABIiAoBBRQAAQABAQhAGwAbOjEABRQAAA==.',['�']='珂朵莉:AwABCAEABRQAAA==.',['�']='瑟兰迪尼斯:AwAICCcABAoEIAAIAQg3BwA6OP0BBAoAIAAIAQg3BwA6OP0BBAoAIQAGAQgLAQBT1uQBBAoABQAHAQiFHQBTBJYBBAoAAA==.',['�']='瓦尔基里灵歌:AwAFCAUABAoAAA==.',['�']='甘露寺风纪委:AwAGCAYABAoAAA==.',['�']='白丶浅:AwAFCAEABAoAAA==.',['�']='第七军团萨满:AwAFCAoABAoAAA==.第七军团骑士:AwABCAEABRQAAA==.第九次初恋丶:AwADCAMABAoAAA==.',['�']='米卡艾丽斯:AwAHCAcABAoAAA==.米斯兰迪尔:AwAICA8ABAoAAA==.',['�']='粉拳为谁握:AwADCAUABRQCGQADAQizBgA5dfsABRQAGQADAQizBgA5dfsABRQAAA==.粑粑上有牙印:AwAECAQABRQAAA==.',['�']='素颜丶裕:AwAHCAkABAoAAA==.紫夜殇逝:AwAGCBEABAoAAA==.',['�']='纳西妲:AwAICCkABAoDEQAIAQhLAABhjxYDBAoAEQAIAQhLAABhjxYDBAoAEgAIAQjlAwBghvYCBAoAAA==.',['�']='绽放狂锈:AwADCAoABRQCHgADAQjEDAAuLeEABRQAHgADAQjEDAAuLeEABRQAAA==.',['�']='缇里西庇俄丝:AwAGCAoABRQDEAAGAQiUBAAl0TMBBRQAEAAFAQiUBAAp3jMBBRQAEwAEAQhPBwAuyOEABRQAAA==.',['�']='罗斯邓肯:AwADCAsABRQEIgADAQg3AQBKdgMBBRQAIgADAQg3AQBELAMBBRQAIwABAQivEABE4lYABRQAGAABAQjTDwA72EUABRQAAA==.',['�']='胖菟子丶捌捌:AwAHCAcABAoAAA==.胖菟子丶贰贰:AwAECAQABRQAAA==.',['�']='自由的风:AwAECAQABRQAAA==.',['�']='苏打:AwAGCAYABAoAAA==.',['�']='草叢裏啲蛤蟆:AwABCAIABRQAAA==.',['�']='菲伦:AwAECAgABRQDGwAEAQheAwBZqTYBBRQAGwAEAQheAwBZqTYBBRQAHAABAQjyFwAAAAAABRQAAA==.',['�']='萌萌的皮蛋:AwAICCMABAoCBAAIAQgLHwBBdx4CBAoABAAIAQgLHwBBdx4CBAoAARkATFAGCAsABRQ=.萨瓦迪卡:AwAECAQABRQAAA==.',['�']='蒜仔:AwAECAQABAoAAA==.',['�']='蓝神:AwAICAoABAoAAR0AAAAICAEABRQ=.',['�']='虎兔牛:AwAICAgABAoAAA==.',['�']='血夜灵猎:AwABCAEABRQDBgAIAQj2MgBCGwQCBAoABgAIAQj2MgBCGwQCBAoABwABAQjHbAA69TUABAoAAA==.血夜龙魔:AwAFCAUABAoAAA==.',['�']='西琼艾儿:AwAICA0ABAoAAA==.西瓜汁:AwAICBgABAoDCAAIAQiCXQAv6rwBBAoACAAIAQiCXQAseLwBBAoACQAHAQgDIgAirhMBBAoAAA==.',['�']='觉主:AwADCAMABAoAAA==.',['�']='變形金剛:AwADCAcABRQCEQADAQhmAwBTICIBBRQAEQADAQhmAwBTICIBBRQAAA==.',['�']='语歌:AwADCAsABRQCBAADAQjWCgBIOvIABRQABAADAQjWCgBIOvIABRQAAR0AAAAICAEABRQ=.',['�']='贪吃丶猫:AwAICAsABAoAAA==.',['�']='赫羅:AwAICBIABAoAAA==.赵丶云:AwAGCAUABRQCFgAEAQhHCwAyWf8ABRQAFgAEAQhHCwAyWf8ABRQAAA==.起名那会正烦:AwAICBcABAoCDgAIAQgwBwBEIywCBAoADgAIAQgwBwBEIywCBAoAAA==.',['�']='过来萝卜:AwADCAMABAoAAA==.过渡期丶:AwABCAEABRQCCAAIAQiXQQBMxQcCBAoACAAIAQiXQQBMxQcCBAoAAQgAW5EECAMABRQ=.迗潶潶:AwABCAEABAoAAA==.迦丷叶:AwACCAIABAoAAA==.追风大侠:AwADCAMABAoAAA==.',['�']='送葬者伊:AwAHCAcABAoAAA==.逆袭之力:AwAFCAgABAoAAA==.逆袭之风:AwAECAQABAoAAA==.',['�']='郭嘉丶奥特曼:AwAECAoABRQDFwAEAQgaBgBAqO8ABRQAFwAEAQgaBgA2Pe8ABRQAGwAEAQj3DAA3F9wABRQAAA==.',['�']='酒一素光:AwABCAEABAoAAA==.',['�']='醉红尘:AwAICAgABAoAAA==.',['�']='鋼鐵俠:AwAECAQABAoAAA==.',['�']='钢板丶:AwAICBAABAoAAA==.',['�']='闪现打击:AwACCAQABRQCBAAIAQjQHABMci0CBAoABAAIAQjQHABMci0CBAoAAA==.闪电五连鞭:AwAECAEABRQAAA==.问远:AwAICBsABAoDCwAIAQjADQBH7TECBAoACwAIAQjADQBG/TECBAoAFgABAQjUdwBN4VgABAoAAA==.',['�']='防骑:AwAICBIABAoAAA==.阿尓忒尼斯:AwAECAQABRQEBwAIAQgoCQBSYHsCBAoABwAIAQgoCQBR9nsCBAoABgAGAQgzbwA9ljIBBAoAJAAEAQgtFAAlM4EABAoAAA==.阿莉雅:AwACCAIABRQAAA==.',['�']='陌夏残年:AwADCAMABAoAAA==.陶雷雷霆号角:AwABCAEABAoAAA==.',['�']='雨阳:AwABCAEABAoAAA==.雪蝶宿秋风:AwACCAIABAoAAA==.零号猎:AwAECAQABRQAAA==.',['�']='霹雳豆仔:AwAECAgABRQDEwAEAQhEBgA8Q+oABRQAEwAEAQhEBgA6EuoABRQACgAEAQj/DgAYUrYABRQAAA==.',['�']='非洲萨满:AwAECAQABAoAAA==.',['�']='马什么梅:AwAFCAUABAoAAA==.马尾菇菇:AwACCAIABAoAAA==.',['�']='魅影郎邪:AwAECAQABRQAAA==.',['�']='鲁小师:AwAFCAUABAoAAA==.',['�']='鸡肉味的旋律:AwAICB0ABAoDGwAIAQiqKgAzCLQBBAoAGwAIAQiqKgAtfbQBBAoAHAAFAQjDIwAu6SQBBAoAAA==.',['�']='黑暗骑士丢丢:AwACCAMABRQCJQAIAQhIIQAsDFIBBAoAJQAIAQhIIQAsDFIBBAoAAA==.默的龙希尔:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end