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
 local lookup = {'DeathKnight-Frost','Shaman-Enhancement','Warlock-Destruction','Druid-Restoration','Mage-Frost','Mage-Fire','Shaman-Elemental','Shaman-Restoration','Priest-Holy','Priest-Discipline','Unknown-Unknown','Paladin-Protection','Paladin-Holy','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Unholy','Paladin-Retribution','Warrior-Arms','Warrior-Fury','DemonHunter-Havoc','Warrior-Protection','Hunter-BeastMastery','Druid-Feral','DeathKnight-Blood','Warlock-Affliction','Evoker-Preservation','Warlock-Demonology','Hunter-Marksmanship','Druid-Balance','Priest-Shadow','DemonHunter-Vengeance','Evoker-Devastation','Mage-Arcane',}; local provider = {region='CN',realm='幽暗沼泽',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ab='Abbido:AwAGCAQABAoAAA==.',Ac='Achilles:AwAECAUABAoAAA==.',Ai='Aim:AwACCAIABRQAAA==.',Ak='Akemihomura:AwABCAEABRQCAQAIAQhBBwBLICoCBAoAAQAIAQhBBwBLICoCBAoAAA==.',Al='Alioe:AwAICAgABAoAAA==.',Ar='Arthur:AwAGCA0ABAoAAA==.',Au='Autumn:AwACCAMABRQCAgAIAQhQEQBOGDMCBAoAAgAIAQhQEQBOGDMCBAoAAQMAK4gECAgABRQ=.',Bb='Bblake:AwAGCAYABAoAAA==.',De='Deyn:AwAECAQABRQAAQQAPyYICAsABRQ=.',El='Elucidate:AwAGCAQABRQAAA==.',Eu='Eulogy:AwAHCB0ABAoDBQAHAQi5EgBWdUoCBAoABQAHAQi5EgBWdUoCBAoABgABAQg9lAAcziwABAoAAA==.',It='Itomcat:AwADCAkABRQDBwADAQi6BwAvkdsABRQABwADAQi6BwAvkdsABRQACAACAQi3EwBVYbMABRQAAA==.',Ja='Jaelia:AwAECAYABRQDCQAEAQg+CAA9+9kABRQACQAEAQg+CAAu2NkABRQACgACAQh7EQBRL54ABRQAAA==.',Ju='Juyo:AwAECAMABAoAAQsAAAAGCAgABAo=.',Mi='Mioricelesta:AwAGCA0ABRQDDAAGAQj1AAA71I4BBRQADAAGAQj1AAA71I4BBRQADQABAQgYEQAdjj4ABRQAAA==.',Mm='Mmortis:AwACCAIABAoAAA==.',Ne='Neekey:AwADCAUABAoAAA==.',Ni='Nightmarey:AwACCAIABRQAAA==.',Pr='Prayicedown:AwAICA8ABAoAAA==.',Qw='Qwq:AwADCAMABAoAAQsAAAAGCAQABAo=.',Ra='Ranmo:AwAECAQABRQAAA==.',Ru='Rustbell:AwACCAIABAoAAA==.',Sw='Sweet:AwABCAIABRQAAA==.',Wa='Watchfish:AwAECAQABAoAAA==.',Wi='Windwalker:AwACCAMABRQEDgAIAQhoBABMCEYCBAoADgAIAQhoBABLXkYCBAoADwABAQh3XwBNgVgABAoAEAADAQj5eAAYo1AABAoAAA==.',Xf='Xfm:AwADCAEABAoAAQsAAAAGCAgABAo=.',Xh='Xhamen:AwAGCBUABAoCCAAGAQjfLQBK3KoBBAoACAAGAQjfLQBK3KoBBAoAAA==.',Ya='Yakult:AwADCAMABAoAAA==.',Yu='Yujo:AwAGCAgABAoAAA==.',Zs='Zsyhqs:AwAECAQABRQAAA==.',['�']='一万八千缘:AwADCAUABAoAAA==.一只酸奶牛:AwACCAIABAoAAA==.一朵小白花:AwAECAQABRQAAA==.一看就是团宠:AwACCAIABAoAAA==.一脸盆糊死你:AwAECAwABRQDBgAEAQiDFwA3ZdwABRQABgAEAQiDFwAputwABRQABQACAQikDQAtfokABRQAAA==.三好小学生:AwABCAIABAoAAA==.三级:AwADCAMABAoAAA==.不醒:AwAECAQABAoAAA==.不髙興:AwAFCBEABRQDEQAFAQjnBwBBz9oABRQAEQAEAQjnBwA/DNoABRQAEgADAQg9CgA+oKUABRQAAA==.与光明同性:AwAFCAsABAoAAA==.东方炒饭:AwAICBwABAoCEwAIAQioKQBDuuABBAoAEwAIAQioKQBDuuABBAoAAQoATHIFCBMABRQ=.丝瓜软泥怪:AwABCAEABAoAAA==.丨浅心丨:AwAECAgABRQCFAAEAQgiDgBJwAgBBRQAFAAEAQgiDgBJwAgBBRQAAA==.丨骑士乐乐丨:AwAICAsABAoAAA==.丫头和丫掌:AwAICBsABAoDAgAIAQirIAAcu6IBBAoAAgAIAQirIAAcu6IBBAoACAAGAQjxXQAkcvcABAoAAA==.丶三温暖丶:AwABCAEABRQAAA==.丶会心一击:AwAFCAUABAoAAA==.丶啦啦酱:AwAECAQABRQAAA==.丶铜贱:AwAECAQABAoAAA==.丶霜之哀傷:AwAICA4ABAoAAA==.',['�']='乂乂软泥怪:AwABCAEABRQAAA==.乖你妹:AwACCAEABAoAAA==.乖宝宝爱抱抱:AwAGCAYABAoAAA==.',['�']='二哥很猛:AwAECAQABRQDFQAIAQiFBgBWPI8CBAoAFQAIAQiFBgBWPI8CBAoAFgAGAQj8PQBEjE4BBAoAAA==.二法大人:AwAICAgABAoAAA==.二队那个暗牧:AwABCAEABAoAAA==.五一:AwACCAIABAoAAA==.',['�']='你们的二哥:AwAICAgABAoAAA==.佩斯莉:AwAECAQABRQAAA==.',['�']='俊呈他叔叔:AwABCAEABRQAAA==.',['�']='傳説梦:AwACCAMABRQAAA==.',['�']='克罗美奈:AwAGCAEABAoAAA==.兔幺哥:AwAECAQABRQAAA==.六月鸢尾:AwABCAEABAoAAA==.',['�']='军团领主:AwAGCAIABAoAAA==.冥府之握:AwAICA4ABAoAAA==.冰糖:AwABCAIABRQAAA==.冲锋偶尔跌倒:AwADCAgABRQDFgADAQhPEQBQDcsABRQAFgACAQhPEQBStcsABRQAFQABAQj7DwBKvVsABRQAAA==.冷夜寒秋雨:AwADCAkABRQCFwADAQgtCwBJfAQBBRQAFwADAQgtCwBJfAQBBRQAAA==.冷小喵:AwAGCAwABAoAAA==.冷珺:AwACCAIABRQAAA==.',['�']='到处打狗:AwAICBQABAoEFQAIAQhBBgBUBJICBAoAFQAIAQhBBgBUBJICBAoAGAABAQhkNgA5hj8ABAoAFgABAQibhAAk+DMABAoAAA==.',['�']='十八而己:AwADCAMABAoAAA==.',['�']='厚礼蟹不肉:AwAICAsABAoAAA==.原谅你了白鸽:AwAECAQABRQAAA==.',['�']='又又:AwADCAYABRQCFgADAQjCDgAqV+kABRQAFgADAQjCDgAqV+kABRQAAA==.叛逆血:AwACCAIABRQAAA==.叫我播音腔:AwAECAQABRQAAQsAAAAICAQABRQ=.叫我贴膜男孩:AwAECAQABRQAAA==.可爱的括约肌:AwAHCAUABAoAAA==.可爱超膘:AwAECAgABRQCFAAEAQgfFwAzJOgABRQAFAAEAQgfFwAzJOgABRQAAA==.叶刃守宫:AwACCAIABAoAAA==.',['�']='君文希:AwAFCAUABAoAAA==.',['�']='周末不喝酒:AwAICAgABAoAAA==.周美灵:AwADCAcABRQCGQADAQh0DwBEDvsABRQAGQADAQh0DwBEDvsABRQAAA==.',['�']='咔噼吧啦:AwACCAIABAoAAA==.',['�']='哟丶猫能:AwABCAEABRQCGgAIAQiSCQA42wMCBAoAGgAIAQiSCQA42wMCBAoAAA==.',['�']='唤霜者艾薇:AwAICAYABRQCGwAEAQhdEAAVUZYABRQAGwAEAQhdEAAVUZYABRQAAA==.',['�']='商务小学生:AwABCAEABRQAAA==.啊七嘿嘿:AwAECAUABRQDHAAEAQiiBABHtP0ABRQAHAAEAQiiBABE2f0ABRQAAwABAQiFIgBKd0wABRQAAA==.',['�']='喵星人会爬树:AwAECAIABRQAAA==.',['�']='噬魂丶臻:AwACCAEABAoAAA==.',['�']='团长不是引的:AwAHCAcABAoAAA==.',['�']='圣光丶冰封:AwAICAcABAoAAA==.圣光裁决者:AwAICAEABAoAAA==.圣辉:AwABCAEABAoAAA==.',['�']='埃克莱尔:AwAGCBMABAoAAA==.',['�']='墨一只:AwAGCAYABAoAAA==.',['�']='夏沫儿:AwAECAIABRQCHQAIAQhABgBELxYCBAoAHQAIAQhABgBELxYCBAoAAA==.夏波利利:AwAECAQABRQAAA==.夜空斑驳:AwAHCA4ABAoAAA==.大传送门:AwAECA0ABRQDAwAEAQiJBABdGSQBBRQAAwAEAQiJBABV/yQBBRQAHAACAQiHCgBT6rYABRQAAA==.大啵啵来嗨了:AwADCAMABAoAAA==.大胃二十五王:AwAECAIABRQAAQsAAAAICAEABRQ=.大西瓜:AwABCAEABRQAAA==.天天像德:AwACCAIABRQAAA==.天打雷劈:AwACCAMABAoAAA==.',['�']='奈影:AwAECAUABRQEHAADAQgEDgAqX5kABRQAHAACAQgEDgAnrpkABRQAAwACAQj9IAAQQFcABRQAHgABAQizFwAAAAAABRQAAA==.奶不住不想奶:AwAECAQABRQAAR8AN+EGCAYABRQ=.奶味蓝很聪明:AwABCAEABAoAAA==.奶萨大帝:AwADCAMABAoAAA==.她与剑皆失:AwACCAIABRQAAA==.好吃不过饺子:AwAECAQABRQAAA==.',['�']='婣尐德征:AwACCAEABAoAAA==.',['�']='孤星雨:AwAFCAUABAoAAA==.',['�']='安德蘿妮:AwAECAQABRQAAA==.',['�']='富小富:AwAECAwABRQCEwAEAQh2AwBcZTQBBRQAEwAEAQh2AwBcZTQBBRQAAA==.',['�']='射手座希希:AwAECAQABAoAAA==.小古月:AwADCAIABAoAAA==.小宇宙:AwACCAIABAoAAA==.小星夜:AwACCAIABRQAAA==.小潴依依:AwABCAIABRQAAA==.小爆蚜:AwAGCAgABAoAAA==.小船鸭子:AwAFCAUABAoAAA==.小譚:AwAICAIABAoAAA==.小队长:AwAECAgABRQCEAAEAQhXBQBOYiUBBRQAEAAEAQhXBQBOYiUBBRQAAA==.尐鉏综:AwADCAMABAoAAA==.尽欢:AwABCAEABRQAAA==.',['�']='工藤灬新一:AwAICBUABAoCGQAIAQgKNgA9kPYBBAoAGQAIAQgKNgA9kPYBBAoAAA==.左夜灰:AwAECAQABRQAAA==.',['�']='师阳:AwABCAEABRQAAA==.希斯特莉娅:AwADCAIABAoAAA==.',['�']='幻影孤月:AwAFCAUABAoAAA==.幽幽小花:AwAHCAkABAoAAA==.',['�']='异端审判会员:AwAFCAgABAoAAA==.',['�']='当年之约:AwABCAEABRQAAA==.彼岸:AwACCAQABRQAAA==.',['�']='待风将她埋葬:AwAGCAoABRQEIAAGAQj3AAAv26cBBRQAIAAGAQj3AAAspKcBBRQAGgABAQhwBgAzOVEABRQABAABAQjiGgAWwTkABRQAAA==.德过且过:AwADCAcABRQDIAADAQhzHgAc5okABRQAIAACAQhzHgAfzokABRQABAABAQiuGAAoDUAABRQAAA==.',['�']='心的微光:AwADCAUABRQCBQADAQhDBwAuwNUABRQABQADAQhDBwAuwNUABRQAAA==.',['�']='性感兽棱发牌:AwAICAQABAoAAA==.',['�']='悠悠贝拉:AwEFCAUABAoAAQIAVRQECAwABRQ=.',['�']='愤怒的三胖:AwAFCAwABAoAAA==.愤怒的陈十一:AwAICAgABAoAAA==.',['�']='憨唓唓:AwAGCAoABAoAAA==.',['�']='成佶思汗:AwAICAwABAoAAA==.我口红呢:AwAGCAUABRQCIQAFAQiLAwAx6k8BBRQAIQAFAQiLAwAx6k8BBRQAAA==.我坑怪我罗:AwACCAIABAoAAA==.我还未离去:AwAECAQABRQEAwAIAQh0FwBUoCQCBAoAAwAIAQh0FwBUoCQCBAoAHAADAQjILQAsWnQABAoAHgABAQi3WwAz+EgABAoAAA==.',['�']='拉糖的阿昆达:AwAICAgABAoAAA==.拐你妹:AwABCAEABRQAAA==.拴住无名指:AwAICA0ABAoAAA==.',['�']='无敌程序猿:AwACCAIABAoAAQsAAAAGCAIABRQ=.无敌空想家:AwACCAIABRQAAA==.无数次夕阳:AwACCAYABRQCFwACAQhYHwAi94wABRQAFwACAQhYHwAi94wABRQAAA==.日落大道:AwAECAQABRQAAA==.',['�']='明骑:AwAECAEABAoAAA==.易方达男孩:AwAHCA8ABAoAAA==.星海孤鲸:AwAICAgABAoAAA==.星辰幻逸:AwAGCA0ABAoAAA==.星野龙之介:AwAFCAUABAoAAA==.春天的梦魇:AwAHCBEABAoAAA==.',['�']='晓天使:AwAGCAEABAoAAA==.晚秋之枫:AwACCAUABRQCEwACAQjiGAAf4Y8ABRQAEwACAQjiGAAf4Y8ABRQAAA==.晴晴:AwACCAIABAoAAA==.智慧的阿昆达:AwAGCAQABAoAAA==.',['�']='暖小喵:AwADCAMABAoAAA==.暗夜盗王:AwAGCAYABAoAAA==.暴走的少先队:AwADCA0ABRQCEQADAQgKBQBDAAYBBRQAEQADAQgKBQBDAAYBBRQAAA==.暴躁小麻瓜:AwAECAQABRQAAA==.',['�']='最近很烦:AwAICAgABAoAAA==.月光下的温柔:AwAFCAUABAoAAA==.月稀:AwAGCAUABAoAAA==.机智老司机:AwAGCAYABAoAAA==.',['�']='李琪薇:AwAICBQABAoCIAAIAQh0GgBKS0kCBAoAIAAIAQh0GgBKS0kCBAoAAA==.来世:AwAECAQABAoAAA==.',['�']='柠檬味的夏天:AwABCAEABRQAAA==.',['�']='校花私人定制:AwAGCAYABAoAAA==.校花闪电一击:AwAECAQABAoAAQIAM3YICAkABRQ=.格丶调:AwAICAgABAoAAA==.',['�']='梧凰:AwAECAQABRQAAA==.',['�']='椰子鸡:AwAGCAoABAoAAA==.',['�']='死骑女王:AwADCAYABRQCGwADAQiUEQASOIwABRQAGwADAQiUEQASOIwABRQAAA==.',['�']='毁灭丷流氓:AwAECAQABRQAAA==.比比骑:AwAGCAUABAoAAA==.',['�']='永远的张宰怙:AwACCAMABRQCBgAIAQjXFwBF71cCBAoABgAIAQjXFwBF71cCBAoAAA==.',['�']='汪汪大魔王:AwAICBcABAoCEwAIAQhGFwBR/FACBAoAEwAIAQhGFwBR/FACBAoAAA==.',['�']='沐呀沐:AwAICAQABAoAAA==.没事走俩步:AwADCAgABRQDHAADAQgUDwArGJEABRQAHAACAQgUDwAYiJEABRQAAwACAQgNGQA2oYYABRQAAA==.没落离殇:AwAICAgABAoAAA==.沫沫猫:AwAICAgABAoAAA==.',['�']='泽德丶:AwAECAQABRQAAA==.',['�']='海東青:AwAECAQABRQAAA==.海鲜泡饭:AwACCAIABRQAAA==.',['�']='温香:AwAICAgABAoAAA==.',['�']='湫山丶澪:AwAICAgABAoAAA==.',['�']='灬天赋帝:AwAGCAYABRQCAwAGAQhzAABJ5PQBBRQAAwAGAQhzAABJ5PQBBRQAAA==.灬洗头用飘柔:AwABCAEABRQAAA==.灬艋钾灬:AwAHCAIABAoAAA==.灰烬女子:AwAGCAcABAoAAA==.',['�']='烮空:AwAICCAABAoCIgAIAQglHwAkalEBBAoAIgAIAQglHwAkalEBBAoAAA==.',['�']='熊熊家的煤球:AwACCAMABAoAAA==.',['�']='燕知春:AwAECAQABRQAAA==.',['�']='爱尔伯蕾丝:AwAECAkABRQCCQADAQgqAQBfsT8BBRQACQADAQgqAQBfsT8BBRQAAA==.爱尔奎特丶:AwAGCAgABRQCHQADAQivAgA8F9YABRQAHQADAQivAgA8F9YABRQAAA==.爱莉丶希雅:AwAECAQABAoAAA==.爱闹的小年糕:AwAICAgABAoAAA==.',['�']='牛编编:AwAICBAABAoAAA==.',['�']='狂王蓝斯:AwAGCAMABAoAAA==.狂野曦:AwABCAEABRQAAA==.狐迪凯:AwAGCAkABAoAAA==.',['�']='猴赛雷啊:AwAFCAUABAoAAA==.',['�']='王老根:AwACCAIABRQAAA==.',['�']='瑞搓比利:AwAECAQABRQAAA==.',['�']='璀璨的烟火:AwADCAkABRQCDAADAQj5CQAbVJUABRQADAADAQj5CQAbVJUABRQAAA==.',['�']='甜桃喵喵:AwAGCAYABAoAAA==.田甜的风:AwAECAUABRQCIgACAQhLDAAi1ngABRQAIgACAQhLDAAi1ngABRQAAA==.',['�']='白俅恩:AwACCAMABAoAAA==.白银之狗腿:AwACCAIABRQAAA==.',['�']='皮纳特:AwAGCAcABAoAAA==.',['�']='看丶有个劣人:AwAECAoABRQDHwAEAQh9CgAxA9MABRQAHwAEAQh9CgAxA9MABRQAGQACAQigLgAbkncABRQAAA==.',['�']='短短:AwABCAEABRQAAQIAPEQGCAgABRQ=.',['�']='碎天破梦:AwAGCAYABRQCEQAGAQh1AAA2KtsBBRQAEQAGAQh1AAA2KtsBBRQAAA==.',['�']='社会你旭爷:AwACCAIABAoAAA==.社会我峰哥:AwAICA0ABAoAAA==.',['�']='祈灬福:AwAHCBsABAoDCQAHAQipFwBM4fABBAoACQAHAQipFwBM4fABBAoACgACAQghXwBEGXsABAoAAA==.',['�']='离离原上草:AwAICAgABAoAAA==.',['�']='空心汤圆:AwACCAIABRQAAA==.空心花少丶:AwAECAQABRQAAQMATegICAYABRQ=.空格当减伤:AwAECAkABAoAAA==.空芯菜:AwAFCAkABAoAAA==.',['�']='笨小猪:AwADCAcABRQDBgADAQgIIQBC5KAABRQABgACAQgIIQA8ZaAABRQABQABAQjuEQBP4l8ABRQAAA==.笨笨的等你:AwACCAMABAoAAA==.',['�']='箜絔格:AwAFCAgABAoAAA==.',['�']='糖宝:AwAGCAcABAoAAA==.',['�']='紫色鸢尾花:AwABCAEABRQAAA==.',['�']='红枫铃:AwAECAIABRQAAA==.纯白信仰:AwAECAUABAoAAA==.',['�']='细雨:AwADCAkABRQCEAADAQgpDgAuR9wABRQAEAADAQgpDgAuR9wABRQAAA==.绝影黑龙:AwAHCAcABAoAAA==.',['�']='缘溪寻梦:AwAGCAkABAoAAA==.',['�']='老子有点颠:AwAICA4ABAoAAA==.耶格骑:AwADCAgABRQCFAADAQhwCABedCABBRQAFAADAQhwCABedCABBRQAAA==.',['�']='肥子:AwACCAIABRQAAA==.肥籽:AwAECAIABRQAAA==.',['�']='胖卵郑猪奇:AwAFCAUABAoAAA==.胸灬伊莱索斯:AwAECAUABAoAAA==.',['�']='脱缰的企鹅:AwADCAMABAoAAA==.脸刷刷白:AwACCAIABRQAAA==.',['�']='致以无瑕之人:AwADCAcABRQCIAADAQgnEQAwK+AABRQAIAADAQgnEQAwK+AABRQAAA==.',['�']='芝士小龙:AwAECAQABRQAASMAD08ICAUABRQ=.花臂少女丶:AwABCAIABRQAAA==.芽儿别打我:AwAGCA4ABRQDIAAGAQgDAQAxr6MBBRQAIAAGAQgDAQAxr6MBBRQABAAEAQgWEAAC4IAABRQAAA==.',['�']='苝亽囟:AwAECAQABRQAAA==.',['�']='茫然骑士:AwAFCAEABAoAAA==.',['�']='荔枝:AwAFCAUABAoAAA==.荣耀萨满:AwAICBEABAoAAA==.',['�']='菜小贱:AwAGCAYABAoAAA==.',['�']='萌萌的尛可爱:AwAECAIABAoAAA==.',['�']='蒜蓉龙虾:AwAECAYABRQCCAAEAQhmCQA/vfUABRQACAAEAQhmCQA/vfUABRQAAA==.',['�']='薄荷冰奶:AwAICAgABAoAAA==.',['�']='藤原千花丶:AwADCAgABRQEBQADAQgtCgBHiqYABRQABQACAQgtCgA+9aYABRQABgABAQinLABVQlcABRQAJAABAQh9AgAoAEwABRQAAA==.',['�']='虚伪的谎言:AwABCAIABRQAAA==.虚空小兔:AwAGCAYABAoAAA==.',['�']='蟹黄小笼包:AwADCAsABRQEFgADAQjGBwBJ2hIBBRQAFgADAQjGBwBJ2hIBBRQAFQABAQjeEAAz+lYABRQAGAABAQg8CwAfBTUABRQAAA==.',['�']='补魔栈:AwAICB0ABAoDBQAIAQgSLwBGrpABBAoABQAHAQgSLwA8yJABBAoABgAGAQinQAA7wW4BBAoAAA==.',['�']='装配行动完美:AwAHCAsABAoAAA==.',['�']='诗和远方:AwAFCAoABAoAAA==.诚实小馒头:AwAECAkABRQCCAAEAQg5BwBClAcBBRQACAAEAQg5BwBClAcBBRQAAA==.请勿喂食:AwADCAMABRQCBAAIAQh5LQAeuEUBBAoABAAIAQh5LQAeuEUBBAoAAA==.',['�']='豆角炖排骨:AwAECAQABRQAAA==.',['�']='贱男村:AwAGCAgABAoAAA==.',['�']='赛弥亚已阵亡:AwACCAIABAoAAA==.',['�']='路斯:AwAICBQABAoCFAAIAQh4OgA+XB0CBAoAFAAIAQh4OgA+XB0CBAoAAA==.',['�']='蹲坑捏蛆玩:AwABCAEABRQAAA==.',['�']='软今天:AwAGCAoABAoAAQsAAAAICAsABAo=.轻且浅:AwAECAQABRQAAA==.',['�']='辉翼:AwADCAEABRQAAQsAAAAGCAQABRQ=.',['�']='迷人的诶灰:AwAGCA0ABAoAAA==.',['�']='送爹霜只哀伤:AwAICBAABAoAAA==.逆袭的年轻人:AwACCAIABRQAAA==.逐梦天涯:AwAGCAoABRQDFgAGAQjRAgAhUUkBBRQAFgAFAQjRAgAoaEkBBRQAFQABAQhAEQAE9FUABRQAAA==.速度与我击剑:AwAICAwABAoAAA==.',['�']='郊眠寺:AwAGCAQABAoAAA==.',['�']='酌酒解君愁:AwAECAQABRQAAA==.',['�']='醉卧煜:AwAECAMABAoAAA==.',['�']='锦绣初战:AwADCAMABAoAAA==.',['�']='长醉不醒的梦:AwABCAEABAoAAA==.',['�']='阿僧波:AwAECAEABRQAAA==.阿姬米德:AwAECAQABRQAAA==.阿巴:AwABCAEABAoAAA==.',['�']='随心剑斩红尘:AwAFCAcABAoAAA==.难以理解:AwAGCAYABRQCIwAGAQhHAQAxUK0BBRQAIwAGAQhHAQAxUK0BBRQAAA==.',['�']='雪哀:AwAGCAYABAoAAA==.',['�']='韓兯餀阚歛:AwAICAgABAoAAA==.',['�']='风的叹息:AwAECAIABRQAAQsAAAAICAQABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end