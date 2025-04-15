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
 local lookup = {'Mage-Fire','Mage-Frost','Warrior-Arms','Druid-Balance','Druid-Restoration','Paladin-Retribution','Unknown-Unknown','Shaman-Enhancement','Monk-Brewmaster','Druid-Feral','Rogue-Subtlety','Rogue-Assassination','DemonHunter-Havoc','Warrior-Fury','Monk-Windwalker','Monk-Mistweaver','Paladin-Holy','Warlock-Demonology','Warlock-Destruction','Paladin-Protection','Hunter-BeastMastery','Shaman-Restoration','Evoker-Devastation','Shaman-Elemental',}; local provider = {region='CN',realm='地狱之石',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Allendk:AwAECAQABRQAAA==.',Aq='Aqu:AwAICAYABAoAAA==.',Bo='Bottlelnn:AwADCAUABRQDAQADAQgFGwAi3c0ABRQAAQADAQgFGwAf6s0ABRQAAgABAQgeFAAWLUkABRQAAA==.',Cr='Crushon:AwACCAMABRQCAwAHAQiMFgA9PtYBBAoAAwAHAQiMFgA9PtYBBAoAAA==.',Eu='Euphoria:AwADCAkABRQDBAADAQjlGQBC4aAABRQABAACAQjlGQBBtaAABRQABQACAQg8EQAj33oABRQAAA==.',Gr='Grit:AwADCAMABAoAAA==.',La='Lala:AwAECAgABRQCBgAEAQjDCABTGB4BBRQABgAEAQjDCABTGB4BBRQAAQcAAAAGCAQABRQ=.',Le='Lemondonk:AwADCAYABRQCCAADAQiMCgAhKMAABRQACAADAQiMCgAhKMAABRQAAA==.',Ma='Maxgic:AwAICAgABAoAAA==.',Pu='Pudding:AwAGCA0ABAoAAA==.',Re='Reda:AwACCAIABRQAAA==.',Sa='Sabre:AwAECAYABRQCCQAEAQhsAwAoo7IABRQACQAEAQhsAwAoo7IABRQAAA==.',Sh='Shersonw:AwAHCAcABAoAAA==.',Va='Varied:AwACCAQABRQCCgAGAQiLCwBV6s8BBAoACgAGAQiLCwBV6s8BBAoAAA==.',['�']='一誓灬者一:AwAGCAYABAoAAA==.不卡基本无敌:AwACCAIABRQAAA==.丨阿尒萨斯丨:AwAFCAcABAoAAA==.',['�']='九寒丶:AwAECAQABRQAAA==.',['�']='五月:AwAICAgABAoAAQcAAAAGCAQABRQ=.京常飞盾:AwACCAIABRQAAA==.',['�']='任五郎:AwADCAMABAoAAA==.',['�']='你是我的眼儿:AwABCAEABAoAAA==.',['�']='元素天罡:AwAGCAYABAoAAA==.元素寂灭:AwAECAQABRQAAA==.',['�']='凶梦的残影:AwAICAgABAoAAA==.',['�']='别卜楞我:AwACCAIABRQAAA==.',['�']='南风知我意:AwAFCAYABAoAAA==.',['�']='司马天命:AwADCAgABRQDCwADAQj9BwAbd+IABRQACwADAQj9BwAbd+IABRQADAABAQhDEgASjEgABRQAAA==.',['�']='吃我劈头灵:AwAICAIABAoAAA==.吧嗒嘣:AwAICAgABAoAAA==.吳三桂:AwAICAgABAoAAA==.',['�']='呼哈一声吼:AwAECAgABRQCDQAEAQj8DwAvFe0ABRQADQAEAQj8DwAvFe0ABRQAAA==.',['�']='哥很淡定:AwAICAgABAoAAA==.',['�']='国安牛逼:AwABCAEABAoAAA==.',['�']='大地之父:AwACCAIABRQAAA==.天霸横空烈轰:AwAICB0ABAoDAwAIAQhmFAA50+sBBAoAAwAIAQhmFAAzq+sBBAoADgAIAQjvKgAt1L4BBAoAAA==.',['�']='姓葚茗誰:AwAGCAoABAoAAA==.',['�']='宁小闲:AwAGCBEABRQDDwAGAQiOBQAzeAkBBRQADwADAQiOBQBDsAkBBRQAEAADAQg+EQA4rcMABRQAAA==.守擭:AwABCAEABRQAAA==.宫野志保:AwAICAMABAoAAA==.',['�']='寂寥:AwABCAEABAoAAA==.寒雨紫烟:AwAHCAgABAoAAA==.',['�']='小浪妞呀:AwAECAQABRQAAA==.',['�']='山里灵活的狗:AwADCAMABAoAAA==.',['�']='帝狱:AwADCAkABRQCCQADAQh4AgA4ZswABRQACQADAQh4AgA4ZswABRQAAA==.帝道赤霄:AwABCAIABRQCEQAGAQiuIgAt9xABBAoAEQAGAQiuIgAt9xABBAoAAA==.',['�']='幸福的小霸王:AwACCAQABRQCAwAGAQjHGgBF5K8BBAoAAwAGAQjHGgBF5K8BBAoAAA==.',['�']='得意地飘:AwAECAQABAoAAA==.',['�']='怒蹄南帝:AwADCAMABAoAAA==.',['�']='我是喵大人:AwACCAQABRQDEgAIAQj2EABHKrwBBAoAEwAIAQiWHgA65/gBBAoAEgAHAQj2EAA+wrwBBAoAAA==.',['�']='托莉娜的锋刃:AwADCAcABRQCDgADAQgnCQBJYAoBBRQADgADAQgnCQBJYAoBBRQAAA==.',['�']='拔丝地瓜:AwAICAMABAoAAA==.',['�']='教灬练:AwAICAgABAoAAA==.',['�']='斯蒂芬刘:AwAECAIABRQAAA==.',['�']='暴躁小黑胖子:AwAECAQABRQAAA==.',['�']='杀噫来袭:AwAECAUABAoAAA==.',['�']='樱桃小公主:AwADCAYABRQCDgADAQgxEAAT09kABRQADgADAQgxEAAT09kABRQAAA==.',['�']='毁琳:AwAHCAYABAoAAA==.',['�']='洮儿河:AwAGCAYABAoAAA==.',['�']='淡色艾尔:AwABCAEABAoAAA==.深黑色:AwAECAQABRQAAA==.',['�']='灬莫娜灬:AwAECAUABAoAAA==.',['�']='煎饼乄初心:AwAHCBAABAoAAA==.',['�']='牧一:AwACCAIABAoAAA==.',['�']='犯二小王子:AwAGCAYABAoAAA==.',['�']='理性:AwAECAgABAoAAA==.',['�']='番茄炒蛋:AwAHCAoABAoAAA==.',['�']='白月教主丶:AwADCAoABRQCFAADAQiUCgAWIo4ABRQAFAADAQiUCgAWIo4ABRQAAA==.',['�']='盐酸小檗碱:AwAGCAYABAoAAA==.',['�']='破坏月神:AwACCAIABRQAAA==.',['�']='秦坦造物:AwADCAgABRQCFQADAQiyDAA/ZQgBBRQAFQADAQiyDAA/ZQgBBRQAAA==.',['�']='稻戝:AwABCAEABRQAAA==.',['�']='空訫糖果丶:AwADCAYABRQDBgADAQjZGQAtX94ABRQABgADAQjZGQAtX94ABRQAEQABAQhNEgAEqzMABRQAAA==.',['�']='章鱼哥丶:AwAGCAoABRQCDwAGAQh9AABJ+gwCBRQADwAGAQh9AABJ+gwCBRQAAA==.',['�']='紫色职业:AwAHCBkABAoCDQAHAQggKQBDoO8BBAoADQAHAQggKQBDoO8BBAoAAA==.',['�']='脆脆丶小红手:AwADCAcABRQDDwADAQgEBQBJhxABBRQADwADAQgEBQBJhxABBRQAEAACAQj+GQAYEogABRQAAA==.',['�']='花气袭人丶:AwACCAIABRQAAA==.',['�']='萨总:AwAGCAcABAoAAA==.萨满嗜血起:AwACCAQABRQCFgAGAQiKOgBJ5XQBBAoAFgAGAQiKOgBJ5XQBBAoAAA==.',['�']='誓约之剑:AwAICAsABAoAAA==.',['�']='谜之熊猫人:AwAICAgABAoAAA==.',['�']='贰非:AwACCAMABRQCFwAHAQgvIAA27HsBBAoAFwAHAQgvIAA27HsBBAoAAA==.',['�']='踏疯:AwAICAsABAoAAA==.',['�']='速度速度速度:AwABCAEABAoAAA==.',['�']='都挺无力的:AwADCAMABAoAAA==.',['�']='铁锅炖溜达鸡:AwABCAEABAoAAA==.',['�']='阿坤复仇:AwAICAgABAoAAA==.',['�']='雷索:AwADCAkABRQDEgADAQhEAQBNDhEBBRQAEgADAQhEAQBNDhEBBRQAEwADAQg4DwAjLc4ABRQAAA==.',['�']='风带走了什么:AwACCAQABRQCAQAHAQg+NwAyo6IBBAoAAQAHAQg+NwAyo6IBBAoAAA==.风暴之拥:AwAFCAoABAoAAA==.风歌:AwACCAYABRQCBgACAQhPLQAn+IoABRQABgACAQhPLQAn+IoABRQAAA==.风笛:AwADCAUABRQCGAADAQiQBwAoXd4ABRQAGAADAQiQBwAoXd4ABRQAAA==.',['�']='黑猫:AwAECAQABAoAAQ4ASWADCAcABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end