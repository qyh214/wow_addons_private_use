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
 local lookup = {'DemonHunter-Havoc','DemonHunter-Vengeance','Paladin-Retribution','Warrior-Fury','Warrior-Arms','Shaman-Enhancement','Shaman-Restoration','Shaman-Elemental','Druid-Balance','Unknown-Unknown','Mage-Fire','Priest-Shadow','Priest-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Paladin-Holy',}; local provider = {region='CN',realm='血顶',name='CN',type='weekly',zone=42,date='2025-04-15',data={Da='Darkgabriel:AwACCAIABRQAAQEAPtMGCAoABRQ=.',Di='Discogirl:AwAGCAIABAoAAA==.',Gi='Ginights:AwADCAUABRQCAgADAQgrCwAORY4ABRQAAgADAQgrCwAORY4ABRQAAA==.',Lz='Lzz:AwACCAEABAoAAA==.',Ro='Rockrabbit:AwAECAQABAoAAA==.',Sq='Squirrel:AwACCAMABRQAAA==.',Za='Zaiaa:AwACCAIABRQAAA==.',['�']='丶方枪枪:AwAECAQABRQAAA==.丶时之砂:AwADCAMABAoAAA==.丶空白格:AwAECAQABRQAAA==.',['�']='云想衣裳:AwAICBgABAoCAwAIAQhdbwA4B54BBAoAAwAIAQhdbwA4B54BBAoAAA==.',['�']='佳猫:AwAGCAYABAoAAA==.',['�']='兮兮:AwAECAQABRQDBAAIAQiCLQA+d7gBBAoABAAHAQiCLQA+SLgBBAoABQADAQj2MwA8N/MABAoAAA==.',['�']='冒泡儿:AwAICAgABAoAAA==.冥十三:AwACCAMABRQEBgAIAQiFEABIbEACBAoABgAIAQiFEABIbEACBAoABwABAQhpowBGr0cABAoACAABAQiegQAAAAAABAoAAA==.冰之末裔:AwAICAgABAoAAA==.',['�']='别龙马:AwAECAQABRQAAA==.',['�']='剑神李淳罡:AwAHCA8ABAoAAA==.',['�']='勤俭丶持家:AwAECAgABRQCCQAEAQhcDABISfwABRQACQAEAQhcDABISfwABRQAAA==.',['�']='医师:AwAECAQABRQAAA==.',['�']='吃醋的胡萝卜:AwEICA4ABAoAAQoAAAAICAMABRQ=.',['�']='天神下凡:AwAHCAcABAoAAA==.',['�']='安捷伦:AwABCAEABRQAAA==.',['�']='小可爱牛牛:AwAECAQABAoAAA==.小爷阿超:AwACCAIABAoAAA==.',['�']='山风眷眷:AwADCAYABRQCBwADAQi7DgAlS+AABRQABwADAQi7DgAlS+AABRQAAA==.',['�']='左手已致残:AwADCAIABAoAAA==.',['�']='彼岸幽茗:AwAECAQABRQAAA==.',['�']='恐惧中毁灭:AwAGCAQABRQAAA==.',['�']='情义丶:AwAICAwABAoAAQsAVtMGCAsABRQ=.',['�']='我女朋友呢:AwAECAQABAoAAA==.战无天:AwAECAQABRQAAA==.',['�']='拉钩不说谎:AwABCAEABRQAAA==.拽的一比:AwAGCAcABAoAAA==.',['�']='旺仔球球糖:AwAGCAIABRQAAA==.',['�']='星橙:AwABCAEABRQAAA==.是正经骑士:AwAFCAcABAoAAA==.',['�']='枝哥:AwAECAQABRQAAA==.',['�']='楚悬黎:AwAGCAgABRQDDAAGAQgqAQBBYM8BBRQADAAGAQgqAQBBYM8BBRQADQACAQi/DwA9DpkABRQAAA==.',['�']='武之禅:AwAGCBEABAoAAA==.',['�']='沃德发:AwAECAgABRQDDgAEAQgWHgAVMr0ABRQADgAEAQgWHgAOcb0ABRQADwACAQjYFQAWY3wABRQAAA==.',['�']='洛汉:AwABCAEABAoAAA==.',['�']='灬无灬聊灬:AwAICAEABAoAAA==.',['�']='烈女不怕死:AwADCAwABRQDBQADAQiHCQA4KrMABRQABQACAQiHCQBEz7MABRQABAACAQg7HAATb4YABRQAAA==.',['�']='熊本熊:AwAGCAkABAoAAA==.熊猫爱吃虾:AwABCAEABAoAAQoAAAACCAIABAo=.',['�']='珊妮当空照:AwACCAIABAoAAA==.',['�']='盈浦三霸:AwACCAIABRQAAA==.',['�']='神密嘉嘉:AwADCA4ABRQCEAADAQgfAgBYGyYBBRQAEAADAQgfAgBYGyYBBRQAAA==.',['�']='红灬双囍:AwAECAQABRQAAA==.',['�']='绝世狂战:AwAICBYABAoCBAAIAQgcHQBA9RYCBAoABAAIAQgcHQBA9RYCBAoAAA==.',['�']='肥米滴狐狐:AwACCAYABRQCBwACAQgSGQBI4p4ABRQABwACAQgSGQBI4p4ABRQAAA==.',['�']='脆弱的身板:AwAICAgABAoAAA==.',['�']='自闭:AwAICAgABAoAAA==.',['�']='良辰丶好景:AwAECAIABAoAAA==.',['�']='芝士墨鱼烧:AwAFCAYABRQCCwAFAQjwCQAhPCYBBRQACwAFAQjwCQAhPCYBBRQAAQMAKaQICAgABRQ=.',['�']='莜默:AwADCAMABAoAAA==.',['�']='虾哥归来:AwAECAQABRQAAA==.',['�']='蛋刀的危害:AwAICAgABAoAAQoAAAAGCAMABRQ=.蛋天帝:AwAECAQABRQAAA==.',['�']='血渍:AwAECAYABRQCDgAEAQipGAAg/eAABRQADgAEAQipGAAg/eAABRQAAQ4AN9MGCAkABRQ=.血色黄昏:AwAECAEABRQDAwAIAQhsRwBIiQACBAoAAwAIAQhsRwBIiQACBAoAEQAGAQjoFQBcz5wBBAoAAREAY34FCBMABRQ=.',['�']='西瓜西瓜:AwAGCAwABRQCCwAEAQitGAAx++EABRQACwAEAQitGAAx++EABRQAAA==.',['�']='观云丶端:AwAECAQABRQAAA==.',['�']='试玩近战:AwAICAgABAoAAA==.',['�']='身上有虾在爬:AwAECAQABRQAAA==.',['�']='迷失之泪:AwAFCAUABRQCDAAFAQiJBAAnSEQBBRQADAAFAQiJBAAnSEQBBRQAAQoAAAAGCAIABRQ=.',['�']='那武僧:AwADCAMABAoAAA==.',['�']='酒醉误事:AwAECAQABAoAAA==.',['�']='金坷垃的逆袭:AwAGCAkABAoAAA==.',['�']='闪亮丶朵朵:AwACCAIABRQAAA==.',['�']='阿丶拉蕾:AwAECAQABRQAAA==.阿米子:AwAGCAQABRQAAA==.',['�']='雪姨:AwAGCAQABRQAAA==.',['�']='霸都财子:AwABCAEABRQCBAAIAQgPQgAVokMBBAoABAAIAQgPQgAVokMBBAoAAA==.',['�']='非布司他:AwAICAkABAoAAA==.',['�']='饭岛小丶爱:AwAECAcABRQCAwAEAQhuCwBUpBgBBRQAAwAEAQhuCwBUpBgBBRQAAA==.',['�']='鹿森森丶:AwAECAQABRQAAA==.',['�']='黑牛宝宝:AwABCAEABRQCBAAIAQhtGQA9YC8CBAoABAAIAQhtGQA9YC8CBAoAAA==.默写丶你的歌:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end