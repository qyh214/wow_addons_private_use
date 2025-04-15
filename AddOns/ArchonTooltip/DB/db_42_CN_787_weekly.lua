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
 local lookup = {'DemonHunter-Vengeance','Monk-Windwalker','Evoker-Devastation','Priest-Shadow','Rogue-Assassination','Rogue-Subtlety','Mage-Fire','Mage-Frost','Monk-Mistweaver','Priest-Discipline','Hunter-BeastMastery','Druid-Balance','Druid-Restoration','Unknown-Unknown','Warlock-Destruction','Warlock-Demonology','Monk-Brewmaster',}; local provider = {region='CN',realm='纳克萨玛斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Angèlia:AwAICAgABAoAAA==.',Ax='Axiaoai:AwABCAEABAoAAA==.',Ha='Hardcandy:AwAICAgABAoAAA==.',Lr='Lrszm:AwACCAEABRQAAA==.',Mo='Morphohelena:AwAICAgABAoAAQEAQYIBCAIABRQ=.',Se='Seath:AwAHCAkABAoAAA==.',Sh='Shootingstar:AwAECAQABAoAAA==.',Te='Terryvit:AwAHCA0ABAoAAA==.',Tn='Tneisnart:AwABCAEABRQAAA==.',['�']='七斤:AwAGCAYABAoAAA==.三代目前男友:AwAECAkABRQCAgAEAQjBCAAsb+UABRQAAgAEAQjBCAAsb+UABRQAAA==.专业卖萌:AwAICAYABAoAAA==.丿酒仙丨傻馒:AwACCAIABAoAAA==.',['�']='二十四个圣骑:AwAHCAcABAoAAA==.二十四个萨满:AwAECAQABRQAAA==.亲爱哒丶:AwAICAgABAoAAA==.',['�']='伊吏丹怒风:AwACCAIABRQAAA==.',['�']='俾面派对:AwACCAIABAoAAA==.',['�']='像疯一样丷:AwAGCAYABAoAAA==.',['�']='元素之舞:AwABCAEABRQAAA==.',['�']='刘老胖:AwACCAIABAoAAA==.',['�']='加糖加醋:AwACCAMABRQCAwAIAQjDFQA2SeUBBAoAAwAIAQjDFQA2SeUBBAoAAA==.',['�']='勇敢的牛仔:AwACCAIABRQAAA==.',['�']='卡布奇诺德:AwAICA8ABAoAAA==.',['�']='呼啦:AwAFCAUABAoAAA==.',['�']='圣光小莉莉:AwABCAEABAoAAA==.',['�']='夏丶目:AwAICAcABAoAAA==.夜尽天明丶丶:AwACCAIABAoAAA==.大白兔刘奶糖:AwAGCAYABRQCBAAGAQhBAgAvB44BBRQABAAGAQhBAgAvB44BBRQAAA==.天气晚来秋丷:AwAECAQABRQAAA==.夺命踢:AwABCAEABAoAAA==.',['�']='姿态决定成败:AwABCAIABRQAAA==.',['�']='小牛翘尾巴:AwACCAIABAoAAA==.小航与大鹏:AwAICAMABAoAAA==.',['�']='我要去远方:AwABCAIABRQAAA==.',['�']='把嘴给我闭上:AwAECAQABRQAAA==.',['�']='拉咘拉多警长:AwAFCAgABRQDBQAFAQhpCgA8ILEABRQABgADAQg9CQAu27oABRQABQACAQhpCgBJZLEABRQAAA==.',['�']='改名会变好运:AwAICA0ABAoAAA==.',['�']='文豪野犬丷:AwAECAQABRQAAA==.斌歌:AwAFCAgABAoAAA==.',['�']='无悔的天使:AwAICAIABAoAAA==.',['�']='林沐儿:AwADCAIABRQAAA==.',['�']='欧文:AwAHCA0ABAoAAA==.',['�']='水灵依素:AwACCAIABRQAAA==.',['�']='没梦想的咸鱼:AwADCAUABRQCBwADAQhoCQBQ+xwBBRQABwADAQhoCQBQ+xwBBRQAAA==.',['�']='法琳娜:AwADCAcABRQCCAADAQi0CAAWfLwABRQACAADAQi0CAAWfLwABRQAAA==.',['�']='浮生万象:AwAGCAYABAoAAA==.',['�']='灬佬龍乤灬:AwABCAEABRQAAA==.灬稀飯灬:AwACCAIABAoAAA==.',['�']='熊先僧:AwAECAcABRQDCQAEAQg2DQAuJ+IABRQACQAEAQg2DQAuJ+IABRQAAgABAQg9GgAESDsABRQAAA==.熊杨:AwAHCAEABAoAAA==.',['�']='牧牧慕慕:AwACCAIABRQAAA==.牧野:AwAECAYABRQCCgAEAQg4AwBaCDcBBRQACgAEAQg4AwBaCDcBBRQAAA==.',['�']='猎猎黑巧:AwACCAIABRQAAA==.猫叔唉:AwACCAUABRQCCwACAQhUIAA5f6IABRQACwACAQhUIAA5f6IABRQAAA==.',['�']='甜甜:AwABCAIABRQAAA==.',['�']='疾風月影:AwAGCAoABRQDDAAGAQhCDQAzM/EABRQADAAGAQhCDQAzM/EABRQADQACAQi/FQAHrFsABRQAAQ4AAAAICAIABRQ=.',['�']='皮皮迪凯:AwABCAEABRQAAA==.',['�']='神圣干涉:AwAICAgABAoAAA==.',['�']='移动奶瓶:AwAECAQABRQAAA==.',['�']='精卫丶:AwAGCAUABRQCAgAFAQhmAgApcUsBBRQAAgAFAQhmAgApcUsBBRQAAA==.',['�']='绫波丽:AwADCAMABAoAAA==.',['�']='聖光祈願:AwACCAIABRQAAA==.',['�']='致命童话:AwAICAgABAoAAA==.',['�']='芒果欧蕾:AwAICA4ABAoAAA==.',['�']='蓉妹:AwAICAYABAoAAA==.',['�']='蚀魂狂魔:AwAICAIABAoAAA==.',['�']='血夜红魔:AwAICB0ABAoDDwAIAQhyKQAy+LkBBAoADwAIAQhyKQAy+LkBBAoAEAABAQjEZgArpy4ABAoAAA==.',['�']='贪婪小宇:AwAICAkABAoAAA==.',['�']='超级小黄人:AwAGCAUABAoAAA==.',['�']='辣目桃子:AwAECAwABRQEAgAEAQi7CQA/vNkABRQAAgAEAQi7CQAkOdkABRQACQADAQiRHgAMZloABRQAEQAEAAgAAAA/vAAABRQAAA==.',['�']='近战五码分散:AwABCAIABRQAAA==.迷迭香:AwAGCAYABRQCDwAGAQguBQA9BxwBBRQADwAGAQguBQA9BxwBBRQAAA==.',['�']='醉卧看斜阳:AwABCAEABRQAAA==.',['�']='釗鋒:AwAICAgABAoAAA==.',['�']='铁蹄黑心:AwABCAEABRQAAA==.',['�']='阿力:AwABCAEABRQAAA==.阿尔萨思:AwAICAkABAoAAA==.阿蒙:AwAICAoABAoAAA==.阿阮丶:AwADCAMABAoAAA==.',['�']='雪飘飘:AwABCAEABRQAAA==.雷霆妞妞:AwABCAEABRQAAA==.',['�']='靓醒的纯天然:AwAGCA8ABAoAAA==.',['�']='風未止战:AwAFCAcABAoAAQ4AAAAECAQABRQ=.',['�']='鲜血毒牙:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end