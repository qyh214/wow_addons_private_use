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
 local lookup = {'Priest-Discipline','Druid-Restoration','DeathKnight-Unholy','Rogue-Assassination','Rogue-Subtlety','Warrior-Arms','Unknown-Unknown','Warrior-Fury','Warlock-Destruction','Druid-Balance','Druid-Guardian','Druid-Feral','Paladin-Retribution','Priest-Holy','Paladin-Holy','Mage-Frost','Mage-Fire','Shaman-Restoration','DeathKnight-Frost','Hunter-BeastMastery','DeathKnight-Blood',}; local provider = {region='CN',realm='符文图腾',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ac='Acelyydd:AwAECAQABRQAAA==.',Bo='Borrl:AwADCAYABAoAAA==.',Br='Bruce:AwABCAEABRQAAA==.',Do='Doctere:AwACCAIABRQCAQAIAQi1DwBFii0CBAoAAQAIAQi1DwBFii0CBAoAAA==.',Gu='Guff:AwAECAQABRQAAA==.',He='Heavensgate:AwABCAEABRQAAA==.',Ne='Necrolyte:AwAECAQABRQAAA==.',Um='Umika:AwADCAMABAoAAA==.',Us='Usiel:AwACCAMABRQAAA==.',Vt='Vtargaryen:AwAFCAkABAoAAA==.',Ze='Zealot:AwAECAYABAoAAA==.',['�']='一七月一:AwAICBgABAoCAgAIAQjFCwBMu1YCBAoAAgAIAQjFCwBMu1YCBAoAAA==.一西毒一:AwABCAEABAoAAA==.七五五:AwAFCAEABAoAAA==.不高兴丶释槐:AwAICAgABAoAAA==.两口奶满:AwAECAQABRQAAA==.丨火锅丨:AwAECAQABAoAAA==.丨燈萢大叔丨:AwAECAMABRQAAA==.临海:AwAECAQABRQAAQMAQ3QGCA0ABRQ=.丶尐夜:AwAECAQABAoAAA==.',['�']='乔治基维斯:AwABCAEABRQDBAAHAQg9CgBVo00CBAoABAAHAQg9CgBVo00CBAoABQAEAQhqKQAbsp8ABAoAAA==.',['�']='二世丨英豪:AwAGCAYABAoAAA==.',['�']='以歌:AwAGCAYABAoAAA==.',['�']='何物似情浓丶:AwACCAIABAoAAA==.',['�']='侏侏与儒儒:AwAGCAoABAoAAA==.依旧飞到火星:AwAICAgABAoAAQYAIZ4GCAoABRQ=.',['�']='俄赛里斯:AwADCAMABAoAAQcAAAABCAEABRQ=.俗名小强:AwAECAQABAoAAA==.',['�']='勥氼:AwACCAYABRQCCAACAQgoFwA0rJ4ABRQACAACAQgoFwA0rJ4ABRQAAA==.',['�']='千金买邻:AwAGCAYABAoAAA==.单蓝色:AwABCAEABRQAAA==.卡卡干:AwAECAQABRQAAA==.',['�']='双刀贼:AwAECAUABRQCCQAEAQjkBwBLoAABBRQACQAEAQjkBwBLoAABBRQAAA==.',['�']='听歌的希瓦:AwADCAMABAoAAA==.',['�']='喵突突:AwABCAEABRQAAA==.',['�']='嘚比嘚的德:AwAECAIABRQECgAIAQjyEQBazoMCBAoACgAIAQjyEQBazoMCBAoACwAIAQhCCwAskmMBBAoADAACAQgSHwAoJ5AABAoAAA==.',['�']='因为所以:AwAGCAYABAoAAA==.',['�']='地狱鬼嚎:AwAECAYABRQDBgADAQh4CwArrZkABRQABgACAQh4CwAomZkABRQACAABAQg1HgAx1lkABRQAAA==.',['�']='夜丨夢姨:AwACCAIABAoAAA==.天车上搞锤子:AwACCAMABRQAAA==.',['�']='奈芙蒂斯:AwABCAEABRQAAA==.奕傷:AwACCAIABRQAAA==.奶锤:AwACCAMABRQAAA==.她摸我:AwABCAEABRQAAA==.',['�']='安舍:AwACCAUABRQCDQAIAQiWDABa4NkCBAoADQAIAQiWDABa4NkCBAoAAA==.',['�']='射穿他的心脏:AwABCAEABAoAAA==.小呆爷爷:AwAECAQABAoAAA==.小呵呵:AwABCAEABRQAAA==.小屋的倆人:AwAECAUABAoAAA==.小汤圆软软:AwADCAMABRQAAA==.小胖沐沐:AwAECAMABRQAAA==.小黄杏拿铁:AwAICAgABAoAAA==.尸宴:AwACCAIABRQAAA==.尹月行:AwABCAEABAoAAA==.',['�']='山前:AwAICBIABAoAAQcAAAAICAIABRQ=.',['�']='崽崽:AwABCAEABAoAAA==.',['�']='帅气野牛:AwAGCAsABAoAAA==.希尔妲:AwADCAQABAoAAA==.',['�']='廢黯:AwACCAQABRQCDQAHAQi2RQBNiPsBBAoADQAHAQi2RQBNiPsBBAoAAA==.',['�']='快驱散:AwADCAMABAoAAA==.',['�']='我怎能不變態:AwAFCAUABAoAAA==.',['�']='旺财小吗:AwABCAEABRQDDgAIAQiJFABAFgkCBAoADgAIAQiJFABAAAkCBAoAAQAGAQjqNAAzXh8BBAoAAA==.',['�']='昆仑镜:AwABCAEABRQCDwAIAQgdAgBbMMQCBAoADwAIAQgdAgBbMMQCBAoAAA==.是大叔啊:AwAICA0ABAoAAA==.',['�']='暗夜猎者:AwAHCA8ABAoAAA==.',['�']='杀死蛋蛋:AwAGCAgABAoAAA==.杀破无敌:AwAHCAcABAoAAA==.村头大美丽:AwAFCAgABAoAAA==.',['�']='柠檬奶油包:AwACCAIABRQDEAAIAQhkCwBXK5ECBAoAEAAIAQhkCwBTv5ECBAoAEQAHAQh/JABJXwoCBAoAAA==.',['�']='栗子球:AwABCAEABRQAAA==.',['�']='桃夭:AwAECAQABAoAAA==.',['�']='梦灵画银潭:AwAGCAYABAoAAA==.梦醒人未觉丶:AwAFCAUABAoAAA==.',['�']='榴莲果酱丶:AwAICAgABAoAAQcAAAAGCAIABRQ=.',['�']='橙熟:AwACCAQABRQAAA==.',['�']='淡看江湖丶:AwAHCAcABAoAAA==.淮南良好市民:AwAGCAYABAoAAA==.混世星雨留年:AwADCAMABAoAAA==.淺倉北北:AwACCAIABRQAAA==.',['�']='漠烟烟:AwAECAEABRQDEQAIAQiAIgBD1xUCBAoAEQAIAQiAIgBCuhUCBAoAEAADAQjsdwA/fX4ABAoAAA==.',['�']='灬风:AwADCAMABAoAAA==.灭亡迅雷:AwAICAgABAoAAA==.灵异之血:AwAGCAEABAoAAA==.',['�']='点子王:AwAECAQABRQAAA==.',['�']='烤牛排:AwACCAIABRQCEQAIAQh/AwBgrfYCBAoAEQAIAQh/AwBgrfYCBAoAAA==.',['�']='爱思唯尔:AwAICAsABAoAAA==.爱神丘比特:AwAECAQABRQAAA==.',['�']='狼兄:AwABCAEABRQAAA==.',['�']='玩咩啊:AwAECAQABRQAAA==.',['�']='瓜天蛆影:AwABCAEABRQAAA==.',['�']='男神你山哥:AwAECAYABRQCEgAEAQjQCQA7r/IABRQAEgAEAQjQCQA7r/IABRQAAA==.',['�']='病毒疫苗:AwACCAIABRQAAA==.痞子丶笨蛋:AwAHCAcABAoAAA==.',['�']='砍爆:AwABCAEABAoAAA==.',['�']='神丨殇:AwAICCAABAoCDQAIAQi7OABTZSMCBAoADQAIAQi7OABTZSMCBAoAAREAJ70GCAoABRQ=.神小棍:AwAGCAsABAoAAA==.',['�']='突突斩:AwACCAIABRQAAA==.',['�']='米宝儿:AwAICBIABAoAAQcAAAAGCAQABRQ=.米菲小麒:AwAGCAYABAoAAA==.',['�']='糊涂塌客:AwAHCAcABAoAAA==.',['�']='素裕:AwAECAQABRQAAA==.',['�']='红唇高跟鞋:AwABCAEABAoAAA==.红肠九块肌:AwACCAQABRQAAA==.',['�']='终誓骑士:AwAICBgABAoDDQAIAQieVQA2TNEBBAoADQAIAQieVQA2TNEBBAoADwABAQgqSwAEggkABAoAAA==.',['�']='老登你要起舞:AwABCAEABAoAAA==.老陈绵绵冰:AwAICA0ABAoAAA==.',['�']='苍白之翼:AwAFCAIABAoAAA==.',['�']='荒堂:AwAGCAoABAoAAA==.',['�']='菲楽:AwAECAUABRQCDQAEAQh7BQBb0jEBBRQADQAEAQh7BQBb0jEBBRQAAA==.',['�']='萨菲:AwAFCAUABAoAAA==.',['�']='蛋蛋的忧伤啊:AwAHCAkABAoAAA==.',['�']='血祭苍天:AwACCAIABRQAAQ4AQcAGCAoABRQ=.',['�']='西红柿炒饭:AwACCAIABAoAAA==.',['�']='誓守山河多娇:AwAHCAkABAoAAA==.',['�']='诗与胡说:AwACCAIABRQAAA==.',['�']='豆浆油条:AwADCAIABRQAAA==.',['�']='踢你噢哞丁:AwAECAQABRQAAA==.',['�']='追光:AwAICAgABAoAAA==.',['�']='重机枪:AwABCAEABRQAAA==.野性驻铁使者:AwABCAEABAoAAA==.',['�']='鋑梭浚焌埈俊:AwAICA4ABAoAAA==.',['�']='钩吻:AwAECAQABAoAAQcAAAACCAQABRQ=.',['�']='长手加鲁鲁:AwAECAQABRQAAA==.',['�']='闲音散曲:AwAFCAYABAoAAA==.',['�']='阴天晒太阳:AwAICAgABAoAAA==.',['�']='陈厂长冰冰冻:AwAICAgABAoAAA==.陈厂长喝奶酒:AwADCAMABAoAAA==.陈汉生:AwAICAgABAoAAA==.除心魔:AwABCAEABAoAAA==.',['�']='雷霆牛:AwABCAEABRQCEwAIAQgzBwBDgywCBAoAEwAIAQgzBwBDgywCBAoAAA==.',['�']='震天怒:AwABCAEABAoAAA==.',['�']='青羊区射神:AwACCAQABRQAAA==.靓坤:AwAECAYABRQCDQAEAQhXEwA1lvQABRQADQAEAQhXEwA1lvQABRQAAA==.非楽:AwAECAYABRQCFAAEAQgyBwBbdysBBRQAFAAEAQgyBwBbdysBBRQAAA==.',['�']='风中奇原:AwAICAMABAoAAA==.风暴龙王:AwAICA4ABAoAAA==.飘落秋叶:AwAHCAcABAoAAA==.',['�']='魂霜:AwACCAQABRQCFQAIAQjnGQAytZgBBAoAFQAIAQjnGQAytZgBBAoAAA==.',['�']='黑锋之花:AwAECAQABRQEEwAIAQgVBABXVIsCBAoAEwAIAQgVBABXVIsCBAoAAwAGAQjGRgBCIWEBBAoAFQADAQg/QABQ9pMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end