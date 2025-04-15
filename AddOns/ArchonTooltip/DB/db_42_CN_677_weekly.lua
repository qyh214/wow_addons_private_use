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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Mage-Fire','Mage-Frost','Rogue-Assassination','Druid-Balance','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Holy','Monk-Mistweaver','Warlock-Destruction','DeathKnight-Frost','Warrior-Fury','Unknown-Unknown','Monk-Windwalker','Priest-Discipline','Priest-Shadow','Priest-Holy','Paladin-Retribution','Warlock-Demonology','Paladin-Protection','Druid-Restoration','Shaman-Restoration','Shaman-Elemental','Rogue-Subtlety','Rogue-Outlaw','Hunter-Survival','DemonHunter-Havoc',}; local provider = {region='CN',realm='影牙要塞',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Allenlverson:AwACCAQABRQAAA==.',Ba='Backtrack:AwAECAgABRQDAQAEAQhWAwBPFhMBBRQAAQAEAQhWAwBPFhMBBRQAAgAEAQhdEABEBvgABRQAAA==.',Be='Beastpoi:AwAECAQABRQAAA==.',Ci='Cirilla:AwACCAIABRQAAA==.',Co='Cosmas:AwABCAEABRQAAA==.',De='Deadbody:AwAHCBYABAoDAwAHAQipMgBA0rwBBAoAAwAHAQipMgBA0rwBBAoABAAEAQjsegAcfncABAoAAA==.Dentata:AwACCAIABRQAAA==.',Ev='Evankai:AwABCAEABRQCBQAIAQiFDQBD6BwCBAoABQAIAQiFDQBD6BwCBAoAAA==.Evantatu:AwACCAIABAoAAA==.',Ja='Jameson:AwAICA4ABAoAAA==.',My='Mygirl:AwABCAEABRQAAA==.',Pa='Parkinson:AwAGCAoABRQCBgAGAQhCAABR2QsCBRQABgAGAQhCAABR2QsCBRQAAA==.',Pl='Playmx:AwACCAEABAoAAA==.',Pu='Purpleelf:AwACCAIABRQAAA==.',Re='Redempt:AwAGCAwABRQDBwAGAQjzBgAa0vQABRQABwAGAQjzBgAK8vQABRQACAACAQhJGgA3SoYABRQAAA==.',Sj='Sj:AwABCAEABRQAAA==.',Ts='Tsubaki:AwABCAEABRQAAA==.',Wa='Waterloo:AwAICAgABAoAAA==.',['�']='一秒的安慰:AwAECAQABRQAAA==.一笑丶一尘缘:AwAECAUABRQCCQAEAQiYBQAsBd8ABRQACQAEAQiYBQAsBd8ABRQAAA==.万华未央:AwABCAEABRQAAA==.中年男人:AwAECAQABRQAAA==.丶利刃丶:AwAFCAQABAoAAA==.',['�']='乐乐狂魔:AwAFCAUABAoAAA==.',['�']='二五八:AwAGCBEABAoAAA==.二酱:AwAFCAUABAoAAA==.亚罗:AwAGCAcABAoAAA==.',['�']='他们心跳加快:AwAGCAkABAoAAA==.以橙服人:AwAICA4ABAoAAA==.',['�']='伊敖:AwABCAEABRQAAA==.',['�']='佑曦:AwAGCAYABAoAAA==.你若盛开丶:AwABCAEABAoAAA==.',['�']='依妹儿:AwAICAYABAoAAA==.',['�']='倒了别怨奶:AwAGCAYABRQCCgAGAQiEAQAr+KMBBRQACgAGAQiEAQAr+KMBBRQAAA==.倚楼丶听风雨:AwAICAgABAoAAA==.',['�']='傲笑红尘:AwAECAgABAoAAA==.',['�']='光之圣歌:AwABCAEABAoAAA==.六月得雨:AwAECAQABRQAAA==.',['�']='冬晴:AwACCAQABRQCCwAIAQgiCQBba5kCBAoACwAIAQgiCQBba5kCBAoAAA==.冷眼玛吉:AwAICAMABAoAAA==.',['�']='出笙指南:AwAICBQABAoDCAAIAQjmIgBARgYCBAoACAAIAQjmIgBARgYCBAoADAAIAQhhDwAk7nUBBAoAAA==.',['�']='半夜去偷蛇:AwABCAEABAoAAA==.卫宫士龙:AwABCAEABRQAAA==.',['�']='史德利古尔:AwAECAwABRQCDQAEAQgcBwBPTBcBBRQADQAEAQgcBwBPTBcBBRQAAA==.',['�']='哥胖之翼天:AwAECAgABRQCAwAEAQhTEwA7mOsABRQAAwAEAQhTEwA7mOsABRQAAA==.',['�']='地萨:AwAECAQABRQAAQ4AAAAGCAIABRQ=.',['�']='墨忘道:AwACCAMABRQAAA==.',['�']='夜兰:AwABCAEABAoAAA==.大叔随心:AwAGCAIABAoAAA==.大烦薯:AwADCAMABAoAAA==.大魔导师丽娜:AwAHCAEABAoAAA==.大鼻子猪:AwAECAQABAoAAA==.天神怒罚:AwADCAIABAoAAA==.',['�']='奶父无犬子:AwAICAYABAoAAQoAK/gGCAYABRQ=.',['�']='守护女王:AwAICAwABAoAAA==.',['�']='小步舞曲:AwAECAQABAoAAA==.小破弓:AwACCAQABRQAAA==.小镇的流逝:AwABCAEABRQCBQAIAQigFQAqZK0BBAoABQAIAQigFQAqZK0BBAoAAA==.',['�']='张无基:AwACCAQABRQCDwAIAQiZFABHMBwCBAoADwAIAQiZFABHMBwCBAoAAA==.',['�']='德制翼:AwABCAEABRQEEAAIAQglJgA5bXQBBAoAEAAGAQglJgBGzXQBBAoAEQAHAQhIKAA1UWwBBAoAEgAGAQhzOQA8lyoBBAoAAA==.',['�']='我爱透熊猫:AwAECAQABRQAAA==.我的那个发:AwABCAEABAoAAA==.我腰疼:AwACCAUABRQCAQACAQgTDgBIzawABRQAAQACAQgTDgBIzawABRQAAA==.',['�']='执政少女:AwABCAEABRQAAA==.',['�']='提默斯奥丁:AwABCAIABRQAAA==.',['�']='日高里菜:AwAICAkABAoAAA==.',['�']='昔曰鸣响:AwACCAQABRQDBAAIAQiDIwBPutIBBAoABAAGAQiDIwBXAdIBBAoAAwAGAQjRQwA4cV0BBAoAAA==.',['�']='晨星之翎:AwAGCAgABRQCEwAGAQhxAABLfO0BBRQAEwAGAQhxAABLfO0BBRQAAA==.',['�']='朱雀七宿一張:AwAFCAUABAoAAA==.朱雀七宿一軫:AwABCAEABAoAAA==.',['�']='李老汉:AwACCAIABRQAAA==.',['�']='枫之殇:AwACCAIABAoAAA==.',['�']='柏舟:AwABCAEABRQAAA==.柴可夫斯基:AwABCAIABRQDCwAIAQifFgBRiSoCBAoACwAHAQifFgBStyoCBAoAFAACAQikQABLCJwABAoAAA==.',['�']='桃蜀:AwADCAMABAoAAA==.',['�']='梅琳娜的锋刃:AwAGCAcABAoAAA==.',['�']='榔头镰刀红旗:AwABCAEABRQAAA==.',['�']='欣赏我的呆:AwAFCAUABAoAAA==.欣赏我的蠢:AwAGCAEABAoAAA==.',['�']='武僧伊傲:AwAICAsABAoAAA==.死靈若龍:AwAICAEABAoAAA==.',['�']='毛丫:AwABCAEABRQCAgAIAQggYQAZvl0BBAoAAgAIAQggYQAZvl0BBAoAAA==.',['�']='水杯泡枸杞:AwACCAIABRQAAA==.',['�']='沐雨阑珊:AwACCAIABRQAAA==.',['�']='泉彼方:AwABCAEABRQAAA==.',['�']='淡漠三六九:AwAGCAEABAoAAA==.淡漠之间:AwAECAEABAoAAA==.',['�']='灬龙丨女灬:AwAECAQABRQAAA==.灵珑:AwAECAQABRQAAA==.',['�']='爱丽丝之魂:AwABCAEABRQDCAAIAQi5NwAxyKABBAoACAAIAQi5NwAxyKABBAoABwAHAQipNQASm8gABAoAAA==.爱到飞蛾扑火:AwACCAIABRQAAA==.爱罗:AwABCAEABRQAAA==.',['�']='狼魂之影:AwABCAEABRQEEwAIAQi7fAA48nQBBAoAEwAHAQi7fAA3FHQBBAoAFQAFAQjxLgAb/7kABAoACQABAQj9QwAU/DYABAoAAA==.',['�']='玉琪:AwACCAIABRQAAA==.玲珑魅:AwAICAcABAoAARYAGrUGCAYABRQ=.',['�']='珈百璃:AwADCAMABAoAAA==.',['�']='琅幽殒:AwAECAIABRQAAA==.',['�']='甩手掌柜:AwAICAgABAoAAQ4AAAAGCAQABRQ=.电光俏臀:AwAECAQABRQAAA==.',['�']='疯狂大保健:AwACCAIABAoAAA==.',['�']='皇家十三骑士:AwAGCBoABAoDEwAGAQh2ZwBOv6UBBAoAEwAGAQh2ZwBOv6UBBAoAFQAEAQimNQAq4JUABAoAAA==.',['�']='知音女记者:AwABCAEABRQAAA==.',['�']='神聖贊美詩:AwAECAoABRQEEgAEAQg6BwBDg+IABRQAEgAEAQg6BwAyz+IABRQAEAADAAgAAABetAAABRQAEQABAAgAAABSXwAABRQAAA==.',['�']='糖长老:AwAECAQABRQAAA==.',['�']='繁星丶春水:AwAECAQABRQAAA==.',['�']='美丽大银刀:AwABCAEABRQAAA==.',['�']='肉苁蓉:AwADCAMABRQAAA==.',['�']='自然平衡:AwACCAIABRQAAA==.',['�']='艾丽思的假期:AwAICAgABAoAAQ4AAAAICAMABRQ=.',['�']='芙莉莲:AwADCAwABRQCDwADAQjeAwBWGCQBBRQADwADAQjeAwBWGCQBBRQAAA==.',['�']='菲菲酱:AwAECAYABRQCBgAEAQjXDQAw8u8ABRQABgAEAQjXDQAw8u8ABRQAAA==.',['�']='萌新来啦:AwACCAIABAoAAA==.萌糖喵:AwACCAEABAoAAA==.落入凡间精灵:AwAECAQABRQAAA==.落红尘:AwADCAMABAoAAA==.',['�']='训练有素医生:AwAGCAQABAoAAA==.',['�']='说好的人头呢:AwAECAMABRQAAA==.',['�']='豆腐丨表弟:AwAECAQABAoAAA==.豆腐姐姐:AwABCAEABRQDFwAIAQiAEABOV1wCBAoAFwAIAQiAEABOV1wCBAoAGAAFAQhiRQAu3swABAoAAA==.',['�']='责任感:AwABCAEABAoAAA==.',['�']='路曦法:AwACCAMABRQCBAAIAQiKEQBKE1MCBAoABAAIAQiKEQBKE1MCBAoAAA==.',['�']='迪克小妹:AwAICA0ABAoAAA==.',['�']='遨游天际:AwAFCAgABAoAAA==.',['�']='邓紫棋:AwACCAIABRQDGQAIAQh5DwA2Qe8BBAoAGQAIAQh5DwA1w+8BBAoAGgAFAQhdDQAqXeQABAoAAA==.那年没咖啡:AwADCAgABRQCDQADAQjIEQAL8sQABRQADQADAQjIEQAL8sQABRQAAA==.',['�']='采菱渡头风急:AwACCAIABRQAAQ4AAAAGCAQABRQ=.野兽追猎者:AwABCAEABRQCGwAIAQhFBgA1k8UBBAoAGwAIAQhFBgA1k8UBBAoAAA==.',['�']='鈴鈴:AwAICAgABAoAAA==.',['�']='钵兰街阿劲:AwAICAsABAoAAA==.',['�']='阳光丽影:AwACCAIABRQAAA==.',['�']='雁尘:AwACCAIABRQAAA==.雨中的苦行僧:AwAECAQABRQAAA==.雪百合:AwAFCAUABAoAARAAOW0BCAEABRQ=.雾桜:AwABCAEABRQAAA==.',['�']='靑樓夢:AwAGCAQABAoAAA==.靡漫:AwACCAIABRQAAA==.',['�']='风和辉光:AwABCAEABRQAAA==.',['�']='骑术不精:AwAFCAgABAoAAA==.',['�']='高尔基:AwADCAYABRQCHAADAQj9DwAvXO0ABRQAHAADAQj9DwAvXO0ABRQAAA==.',['�']='魂归悲风丶:AwAECAQABRQDBQAIAQi+CABPp2QCBAoABQAIAQi+CABOgGQCBAoAGQAGAQhpGwA6aEABBAoAAQUAQSQFCA8ABRQ=.魂狩:AwAECAQABRQDGQAIAQjNDgA77fkBBAoAGQAIAQjNDgA77fkBBAoABQABAQgLPAAtw0YABAoAAA==.魂猎:AwAECAQABRQAAA==.',['�']='鹤一:AwAICAgABAoAARcANG8GCAYABRQ=.',['�']='黑色妹:AwACCAIABAoAAA==.',['�']='龙形态爬爬:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end