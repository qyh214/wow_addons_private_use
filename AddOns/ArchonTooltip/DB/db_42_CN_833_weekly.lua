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
 local lookup = {'Unknown-Unknown','Evoker-Devastation','Evoker-Preservation','Mage-Fire','Mage-Frost','Monk-Mistweaver','Shaman-Enhancement','Warrior-Protection','Paladin-Retribution','Hunter-BeastMastery','DeathKnight-Blood','Druid-Balance','Warrior-Arms','DeathKnight-Unholy','Druid-Restoration','Monk-Brewmaster','Druid-Guardian','Warrior-Fury','Hunter-Marksmanship',}; local provider = {region='CN',realm='踏梦者',name='CN',type='weekly',zone=42,date='2025-04-15',data={Be='Beforeafter:AwAICBAABAoAAQEAAAAHCAIABRQ=.',Bi='Bibi:AwAICAEABAoAAA==.Bittergourd:AwAICCAABAoDAgAIAQguFgBLKu4BBAoAAgAHAQguFgBNiu4BBAoAAwADAQg/EwBKyAoBBAoAAQEAAAAHCAIABRQ=.',Bl='Blessing:AwAICAgABAoAAQEAAAAHCAIABRQ=.',Di='Dionysus:AwAECAQABRQAAA==.',El='Elaine:AwAICA0ABAoAAA==.',Em='Emo:AwAICBAABAoAAA==.',Hi='Hillmanq:AwAGCAkABAoAAA==.',Hy='Hydedragon:AwAECAQABRQAAA==.',Lu='Luckymage:AwAECAQABRQAAA==.Luckypaladin:AwAECAQABRQAAA==.',Os='Osnngb:AwABCAEABRQAAA==.',Ro='Roxam:AwADCAMABRQAAA==.',Yr='Yraax:AwACCAMABRQDBAAIAQipOQAywJ8BBAoABAAIAQipOQArBp8BBAoABQAFAQhQXwA0pMgABAoAAA==.',['�']='三月的狮子:AwAICAgABAoAAA==.上官丶呆哔:AwAICA0ABAoAAA==.上帝的右腳:AwACCAMABRQAAA==.丨樂乐楽丨:AwAHCA0ABAoAAA==.丨行不晚丨:AwACCAUABRQCBgACAQirEABbztcABRQABgACAQirEABbztcABRQAAA==.丨黑大帅丨:AwACCAIABRQAAA==.',['�']='亂世小熊:AwAGCAYABAoAAA==.亜菲利欧:AwAECA8ABRQCAgAEAQjRAwBgJEABBRQAAgAEAQjRAwBgJEABBRQAAA==.',['�']='八級大狂風:AwAECAQABRQAAA==.兽血沸腾丶:AwAICAUABAoAAA==.',['�']='冰河:AwAECAQABAoAAA==.',['�']='凉慕凰:AwACCAUABRQCBwACAQgUDABLUrQABRQABwACAQgUDABLUrQABRQAAA==.凉静汐:AwAGCAEABRQAAA==.',['�']='卧草原:AwAGCAYABRQCBAAGAQhSAgBIHNMBBRQABAAGAQhSAgBIHNMBBRQAAA==.',['�']='叁灬月:AwAECAMABRQAAA==.又初恋了:AwAHCAcABAoAAA==.台词而以:AwACCAQABRQAAA==.台词而已:AwACCAYABRQCCAACAQj+BwAYJnAABRQACAACAQj+BwAYJnAABRQAAA==.',['�']='吃货怕饿梦:AwACCAIABAoAAA==.',['�']='呼啸风之灵:AwABCAEABRQAAA==.命运之神:AwAICAgABAoAAA==.',['�']='團滅之星:AwAECBAABRQCCQAEAQgzBgBfNzMBBRQACQAEAQgzBgBfNzMBBRQAAA==.圣域追风:AwAFCAIABAoAAA==.',['�']='夏夜星空:AwAECAQABAoAAA==.夏夜暖风:AwACCAUABRQCCgACAQjuLwAhWYAABRQACgACAQjuLwAhWYAABRQAAA==.夏夜驟雨:AwAICAkABAoAAA==.大弗弗:AwAECA8ABRQCCwAEAQjzBQBN3BMBBRQACwAEAQjzBQBN3BMBBRQAAA==.大水汼:AwAFCAUABAoAAA==.天河雪琼:AwAECAQABAoAAA==.',['�']='奥丽佛:AwAECAQABRQAAA==.奥斯丁:AwAFCAQABAoAAA==.',['�']='宝贝灬咕咕:AwACCAUABRQCDAACAQikIwAST3sABRQADAACAQikIwAST3sABRQAAA==.宝贝灬小佳佳:AwAHCBAABAoAAQwAEk8CCAUABRQ=.宝贝灬神射手:AwAECAQABRQAAQ0AS5IGCBAABRQ=.',['�']='小兔瑞贝卡卡:AwAGCAEABAoAAA==.小欣欣:AwADCAMABAoAAA==.小番茄脸红了:AwAECAQABRQAAA==.',['�']='帝国之心:AwACCAIABAoAAA==.帝国之怒:AwACCAIABAoAAA==.帝国之狼:AwABCAEABRQAAA==.帝国之鹰:AwABCAEABRQAAA==.',['�']='幼稚園殺手:AwAECAgABRQCDgAEAQjoDAA5he4ABRQADgAEAQjoDAA5he4ABRQAAA==.',['�']='拉普兰德:AwADCAMABAoAAA==.',['�']='无非想快乐:AwAICB4ABAoDAgAIAQhBJgBbyVUBBAoAAgAIAQhBJgBbyVUBBAoAAwADAQg2EgBS5h0BBAoAAQEAAAAHCAIABRQ=.',['�']='暮酒:AwACCAIABRQAAA==.',['�']='最后一舞:AwAFCAQABAoAAA==.有种盗我德号:AwAECBIABRQDDAAEAQiOCABVmBMBBRQADAAEAQiOCABVmBMBBRQADwACAQg7FQAXLmwABRQAAA==.朲冭帅:AwAECAQABAoAAA==.',['�']='林七夜:AwAECAQABRQAAA==.枫之耀舞:AwAECAQABRQAAQIAD08ICAUABRQ=.',['�']='格鲁姆地狱吼:AwABCAEABAoAAA==.',['�']='椰果奶绿:AwAECA8ABRQCEAAEAQhZAQBRiRQBBRQAEAAEAQhZAQBRiRQBBRQAAA==.',['�']='楠心慕舞:AwACCAIABRQAAQEAAAAGCAIABRQ=.',['�']='樱小路露娜:AwAECAQABAoAAA==.',['�']='死亡使者小萨:AwAFCAUABAoAAA==.',['�']='没有信仰的牛:AwABCAEABRQAAA==.',['�']='滅團灾星:AwAECAsABRQDDgAEAQhYDABCbfEABRQADgAEAQhYDABCbfEABRQACwABAQhTIgAAAAAABRQAAA==.',['�']='漂邈:AwAFCAUABAoAAA==.演中演:AwAGCAUABAoAAA==.',['�']='潮留美海:AwAICAgABAoAAA==.',['�']='烂棉岁:AwAECAQABAoAAA==.烟花粉黛:AwAGCAYABAoAAA==.',['�']='熊猫盼盼:AwAECAQABRQAAA==.',['�']='狂暴熊仔:AwACCAIABAoAAA==.',['�']='獠牙巨兽:AwAICAoABAoAAA==.',['�']='筱水水:AwAECAQABRQAAA==.',['�']='绒球儿:AwABCAIABRQCEQAIAQhDDgAltzIBBAoAEQAIAQhDDgAltzIBBAoAAA==.绿箭奥利弗:AwACCAUABRQCCgACAQiGMQAVr3oABRQACgACAQiGMQAVr3oABRQAAA==.',['�']='耀嘉音:AwACCAIABAoAAA==.',['�']='花开任平生:AwAGCAYABAoAAA==.',['�']='萨之霊:AwAICAEABAoAAA==.萨菲若丝:AwAFCAUABAoAAA==.萨鲁法尔大王:AwACCAQABAoAAA==.',['�']='镉球:AwAECAQABAoAAA==.',['�']='阿什顿:AwADCAIABRQAARIAGCYICAYABRQ=.阿森:AwAECAcABAoAAA==.',['�']='难民营营长:AwACCAMABRQAAQYAQnAHCAwABRQ=.',['�']='雷多多:AwAFCAkABAoAAA==.',['�']='霸波奔:AwACCAUABRQDEgACAQhfHQANW3sABRQAEgACAQhfHQANW3sABRQACAACAQibCQAGEU4ABRQAAA==.',['�']='青涩后妈:AwAFCAcABAoAAA==.',['�']='飬一只死一只:AwAECAwABRQCEwAEAQh7BgBLsPwABRQAEwAEAQh7BgBLsPwABRQAAA==.',['�']='马佩佩:AwAECA8ABRQDDwAEAQhSAgBeukkBBRQADwAEAQhSAgBeukkBBRQADAABAQjdLAAJrEMABRQAAA==.',['�']='龙希尔唤魔师:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end