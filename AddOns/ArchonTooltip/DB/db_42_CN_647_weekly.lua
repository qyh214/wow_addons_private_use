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
 local lookup = {'Warlock-Destruction','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Retribution','DemonHunter-Vengeance','DemonHunter-Havoc','Warrior-Arms','Warrior-Fury','Mage-Frost','Mage-Fire','Druid-Balance','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Warrior-Protection','Priest-Discipline','DeathKnight-Blood','DeathKnight-Unholy','Shaman-Enhancement','Druid-Restoration','Warlock-Demonology','Druid-Feral','Warlock-Affliction',}; local provider = {region='CN',realm='守护之剑',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Always:AwAFCAkABAoAAA==.',Bo='Boykises:AwAICAIABAoAAA==.',Eg='Egoo:AwAECAQABRQAAQEAXXgGCAwABRQ=.',El='Ellis:AwAGCAgABAoAAA==.',Fo='Foraiur:AwAICAkABAoAAA==.',Ha='Hack:AwADCAgABRQDAgADAQijDQBHybEABRQAAgACAQijDQBMTbEABRQAAwACAQiiHwBMvaUABRQAAA==.',Ke='Kemical:AwAECAQABRQAAA==.',Mu='Musee:AwAHCB8ABAoCBAAHAQjWXAA/Eb4BBAoABAAHAQjWXAA/Eb4BBAoAAA==.',Pi='Pinkmerry:AwACCAIABAoAAA==.',Pl='Playerdlpqkl:AwAICBAABAoAAA==.',Re='Renascence:AwADCAUABAoAAA==.',Vi='Viva:AwAFCAcABAoAAA==.',Xx='Xxspec:AwAICA4ABAoAAA==.',['�']='一同天下:AwAECAQABRQAAA==.一心不乱:AwAGCAYABAoAAA==.一点冷:AwADCAMABAoAAA==.',['�']='乌蝇哥:AwAGCAoABRQDBQAEAQi7BQAx3cQABRQABQAEAQi7BQAwiMQABRQABgACAQgCHQA+KpYABRQAAA==.',['�']='伊莉达蕾:AwABCAEABAoAAA==.',['�']='克罗斯:AwADCAMABAoAAA==.八坂神柰子:AwAGCAoABAoAAA==.',['�']='冰封小阿:AwABCAEABRQAAA==.',['�']='凉森玲梦:AwAFCAQABAoAAA==.出来吧皮卡丘:AwADCAMABRQAAA==.',['�']='加卡:AwAECAoABRQDBwAEAQgyBQApSt0ABRQACAAEAQgQDgAl2O4ABRQABwAEAQgyBQAaut0ABRQAAA==.劲哥哥:AwAGCAgABAoAAA==.',['�']='十岁:AwAECAQABAoAAA==.南渡:AwAICAgABAoAAA==.卯之花千流:AwAGCAYABAoAAA==.',['�']='君丶天下:AwAHCBoABAoDBwAHAQg6IQBNDncBBAoABwAFAQg6IQBRcncBBAoACAAFAQgePQBHjFMBBAoAAA==.吾爱有三:AwACCAIABAoAAA==.',['�']='哈喽比比熊:AwAFCAgABAoAAA==.哎哟薇:AwAFCAUABAoAAA==.',['�']='嘟嘟噜:AwACCAIABAoAAA==.',['�']='噩梦降临:AwAGCAgABAoAAA==.',['�']='回荡的回忆:AwADCAkABRQDCQADAQikBgAvQt0ABRQACQADAQikBgAvQt0ABRQACgACAQieLAAGB1gABRQAAA==.',['�']='土肥圆圆:AwAECAgABRQCCwAEAQjeDQA3zO8ABRQACwAEAQjeDQA3zO8ABRQAAA==.',['�']='坟凹无限装殖:AwACCAIABAoAAA==.',['�']='墨白色块:AwAECAIABRQAAA==.',['�']='复仇:AwABCAEABAoAAA==.夏天的小幂幂:AwAICAgABAoAAA==.夜幕下的游魂:AwAECAgABRQEDAAEAQhFAgBRrNUABRQADAAEAQhFAgA5htUABRQADQACAQh1CgBX0c4ABRQADgACAQgqHwA3EVEABRQAAA==.天昏:AwADCAQABAoAAA==.',['�']='妖韵:AwAECAoABRQCCwAEAQiWEwAb29EABRQACwAEAQiWEwAb29EABRQAAA==.',['�']='安享晚年:AwAGCAwABAoAAA==.安美拉:AwACCAIABRQAAA==.',['�']='小小的凡凡:AwAICAgABAoAAA==.小曦哥哥:AwACCAIABRQAAA==.小猪猪的传说:AwADCAMABAoAAA==.小猫晃悠悠:AwAGCAkABAoAAA==.小飞棍来啰:AwACCAIABAoAAA==.小魔无敌:AwAECAcABAoAAA==.尖沙咀十三妹:AwAGCAYABAoAAA==.',['�']='布莱克哈德:AwACCAIABRQAAA==.帮助伱帮助我:AwAHCAcABAoAAA==.',['�']='广结善缘:AwACCAMABRQAAA==.',['�']='弟荙洞洞荙荙:AwAICAIABRQAAA==.张灬海旺:AwACCAIABRQAAA==.',['�']='心上:AwAGCAYABRQDAgAGAQhyAABCHYwBBRQAAgAFAQhyAABLGowBBRQAAwABAQhrMgAeK1sABRQAAQoALZoICAUABRQ=.',['�']='情流感:AwADCAEABAoAAA==.情系吾人:AwADCAEABAoAAA==.',['�']='我是花哥:AwABCAEABRQAAA==.我狗瘾犯啦:AwABCAEABAoAAA==.我的天呐:AwAFCAIABRQAAQ8ALyoICAoABRQ=.戒贤:AwADCAQABRQAAA==.战术核显卡:AwAHCAQABAoAAA==.戦丶魍:AwAHCB0ABAoCBAAHAQg6TQBFjOYBBAoABAAHAQg6TQBFjOYBBAoAAA==.',['�']='执笔书生:AwADCAMABAoAAA==.执笔画黛眉:AwAECAEABRQAAA==.',['�']='报丧女妖丶:AwAICAgABAoAAA==.',['�']='拉糖起门告辞:AwAICAgABAoAAA==.',['�']='指尖嘚律动:AwAICAgABAoAAA==.',['�']='搞子:AwAGCAYABAoAAA==.',['�']='收手吧阿祖:AwADCAMABAoAAA==.',['�']='无尽暗牧:AwAECAgABRQCEAAEAQiXBQBIZxEBBRQAEAAEAQiXBQBIZxEBBRQAAA==.无敌中登:AwABCAEABRQCAQAIAQimDgBRrGYCBAoAAQAIAQimDgBRrGYCBAoAAA==.无敌篮球战神:AwAECAQABAoAAA==.',['�']='星屑:AwABCAMABRQAAA==.星辰物语:AwAICAEABAoAAA==.',['�']='晖晖再现:AwAICA0ABAoAAA==.晚安喵:AwAECAQABRQAAQsAQiQGCAoABRQ=.景元元:AwABCAEABAoAAA==.',['�']='暗翼狼魂:AwAICBYABAoCEQAIAQg0FABE7dYBBAoAEQAIAQg0FABE7dYBBAoAARIAQ3QGCA0ABRQ=.暴虐的灬山君:AwACCAIABRQAAA==.',['�']='曦哥小跟班:AwACCAIABRQAAA==.',['�']='木叶医院:AwAICAgABAoAAA==.',['�']='杨威利:AwAECAQABRQAAA==.',['�']='林同学:AwAECAQABRQAAA==.',['�']='樱花乌龙茶:AwAECAIABRQAAA==.',['�']='欧若因:AwAGCAYABAoAAA==.',['�']='毒格拉斯:AwAGCAYABAoAAA==.',['�']='气德龙东强:AwAFCAUABAoAAA==.水木生炏:AwAFCAEABAoAAA==.',['�']='沙琪玛:AwAICAgABAoAAA==.',['�']='洛丽塔:AwAICAcABAoAAA==.',['�']='流氓要逆袭:AwAICAgABAoAAA==.',['�']='火车王:AwAECAcABRQCBgAEAQihCwBLxAEBBRQABgAEAQihCwBLxAEBBRQAAA==.',['�']='炉火纯青:AwAECAoABRQCBAAEAQjoEABIbf0ABRQABAAEAQjoEABIbf0ABRQAAA==.',['�']='爬开老子来射:AwADCAIABAoAAA==.',['�']='狖夜鸣:AwABCAEABRQCEwAIAQjvGAA25OgBBAoAEwAIAQjvGAA25OgBBAoAAA==.独一无二:AwACCAQABRQAAA==.',['�']='猎彧:AwADCAMABRQAAA==.猫的魔法密林:AwABCAEABAoAAA==.',['�']='玉树丨临风:AwAFCAQABAoAAA==.',['�']='班尼:AwAICAcABAoAAA==.',['�']='琛心如月:AwAHCAEABAoAARQAPyYICAsABRQ=.',['�']='疯狂璐飞:AwAICAgABAoAAA==.',['�']='白色秃鹫:AwABCAEABRQAAA==.',['�']='皮皮:AwAICAgABAoAAA==.',['�']='盖世丹妮莉丝:AwADCAMABAoAAA==.',['�']='看丨灰机:AwAECAQABRQAAA==.眼不见心不念:AwAECAQABRQAAA==.',['�']='知妇宝:AwAHCAcABAoAAA==.',['�']='空袭巴格达:AwAGCAcABRQDFQAEAQgPAQBT1xsBBRQAFQAEAQgPAQBT1xsBBRQAAQADAQj8EgBKgbEABRQAAA==.',['�']='简短:AwACCAIABRQAAA==.',['�']='米诺绯:AwACCAMABRQAAA==.',['�']='紫竉:AwADCAYABRQCBAADAQhjCABRZiABBRQABAADAQhjCABRZiABBRQAAA==.紫龍:AwACCAIABRQAAA==.',['�']='红祭司:AwAECAQABRQAAA==.',['�']='绝黛:AwAFCAkABAoAAA==.',['�']='美麗的錯過:AwAFCAUABAoAAA==.',['�']='胖胖不怕胖:AwAGCAUABAoAAA==.',['�']='腼腆的柳如烟:AwACCAIABRQAAA==.',['�']='舞风弄月:AwABCAIABAoAAA==.',['�']='艾欧泽亚:AwAICAUABAoAAA==.',['�']='芒果鸭:AwAFCAUABAoAAA==.花脸猫丶:AwAICCAABAoDFgAIAQj5BABKx3UCBAoAFgAIAQj5BABKx3UCBAoACwACAQjMrgAEbicABAoAAA==.花靥:AwAICAcABAoAAA==.',['�']='英雄之魂:AwABCAEABRQAAA==.',['�']='草莓胖次:AwAFCAUABAoAAA==.',['�']='莹天辛:AwAGCAIABRQAAA==.',['�']='菲牟尼欣:AwAECAQABAoAAA==.',['�']='萌系先生:AwAHCAoABAoAAA==.萌萌哒灬老爬:AwAFCAUABAoAAA==.',['�']='蒂罗亚斯:AwAHCBsABAoCEgAHAQi1HgBNbSACBAoAEgAHAQi1HgBNbSACBAoAAA==.蒋稻礼:AwACCAIABAoAAA==.',['�']='蜗牛大魔王:AwAICCAABAoDAQAIAQgAKQBFMLsBBAoAAQAHAQgAKQBAMbsBBAoAFwAEAQjmFQA70yABBAoAAA==.',['�']='蝇火:AwACCAIABRQAAA==.',['�']='螃蟹必须滚啊:AwAFCAUABAoAAA==.',['�']='血手:AwAECAQABRQAAA==.血脸三哥:AwACCAIABAoAAA==.',['�']='赞美愚者:AwADCAMABRQAAA==.',['�']='路婭:AwAHCBsABAoCDwAHAQhnHAAX0+4ABAoADwAHAQhnHAAX0+4ABAoAAA==.跳起来射膝盖:AwADCAMABRQAAA==.',['�']='银眸邪瞳:AwAFCAYABAoAAA==.',['�']='闪电拳:AwACCAIABAoAAA==.',['�']='阿布是紫狗:AwAECAQABRQAAA==.阿木丨牧:AwAECAoABRQCEAAEAQjwAgBbQz0BBRQAEAAEAQjwAgBbQz0BBRQAAA==.阿法:AwAFCAUABAoAAA==.阿芙萝蒂娜:AwAECA4ABRQCBAAEAQg2FgBANusABRQABAAEAQg2FgBANusABRQAAA==.',['�']='除暴安良:AwAECAQABRQAAA==.',['�']='随风宝宇:AwAICAgABAoAAA==.',['�']='静谧:AwAGCAcABRQCDgAEAQigCgA2nfEABRQADgAEAQigCgA2nfEABRQAAA==.',['�']='顾小桑:AwACCAIABRQAAA==.',['�']='風導星歌:AwACCAIABRQAAA==.',['�']='风动:AwAICAgABAoAAA==.',['�']='鬼泣:AwAHCAsABAoAAA==.',['�']='鱼丸粗面:AwAHCB4ABAoCEQAHAQjNMwAV2tIABAoAEQAHAQjNMwAV2tIABAoAAA==.',['�']='鲨鱼小小:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end