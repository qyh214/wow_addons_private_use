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
 local lookup = {'Warrior-Fury','Shaman-Restoration','Unknown-Unknown','Paladin-Retribution','Monk-Windwalker','Monk-Mistweaver','Warrior-Protection','DeathKnight-Blood','DeathKnight-Unholy','DeathKnight-Frost','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','Druid-Restoration','Mage-Fire','Warlock-Destruction',}; local provider = {region='CN',realm='死亡熔炉',name='CN',type='weekly',zone=42,date='2025-04-14',data={Es='Escanor:AwAECAQABRQAAA==.',Na='Naremdul:AwAECAQABRQAAA==.',To='Tom:AwAECAQABRQAAA==.',Zh='Zhaybabtu:AwABCAEABAoAAA==.',['�']='不会放电:AwAECAQABRQAAA==.丨小黄花丨:AwACCAIABRQAAA==.',['�']='亚托克斯:AwAICAgABAoAAA==.',['�']='你石哥:AwABCAEABRQAAA==.',['�']='侠之幻影:AwAECAQABRQAAA==.',['�']='养猪丨丨大户:AwAECAYABRQCAQAEAQhICgBDzwQBBRQAAQAEAQhICgBDzwQBBRQAAA==.',['�']='单曲灬循环:AwAECAQABRQAAA==.',['�']='双鱼座小牛:AwAICAEABAoAAA==.古明地作:AwAFCAYABAoAAA==.叫峰哥:AwAICBUABAoCAgAIAQhOEgBHtU4CBAoAAgAIAQhOEgBHtU4CBAoAAA==.可爱的蓝精灵:AwAICAQABAoAAA==.',['�']='吱炙脂:AwAECAQABRQAAQMAAAAICAEABRQ=.',['�']='哪个名字能用:AwAGCAYABAoAAA==.',['�']='啊啊噢哦阿:AwABCAIABRQAAA==.',['�']='如此肆意妄为:AwAECAQABRQAAQMAAAAGCAQABRQ=.',['�']='寡人之怒:AwACCAUABRQCBAACAQhtIwBQI6gABRQABAACAQhtIwBQI6gABRQAAA==.',['�']='尐样儿:AwAGCAkABAoAAA==.尼姑妹妹:AwADCAcABRQCBQADAQiUCgAe8MwABRQABQADAQiUCgAe8MwABRQAAA==.',['�']='帅伟:AwAGCAYABRQCBgAGAQiBAABTXf8BBRQABgAGAQiBAABTXf8BBRQAAA==.',['�']='开车不保养:AwAICAUABAoAAA==.',['�']='怎么梳都倦:AwAICAgABAoAAA==.怎么梳都卷:AwADCAIABRQDAQAIAQgPOQAt4GsBBAoAAQAGAQgPOQA1sGsBBAoABwAFAQhHIgAddroABAoAAA==.',['�']='放着俺来:AwACCAIABAoAAA==.',['�']='星星会变羊:AwAICBAABAoAAA==.星期仈:AwAFCAoABAoAAA==.',['�']='智爷:AwAFCAUABAoAAA==.',['�']='武断乾坤:AwACCAIABRQAAA==.死不了一点:AwACCAIABRQAAA==.死亡凋零灬:AwAECAQABRQAAA==.',['�']='毛奶奶:AwAFCAUABAoAAA==.',['�']='油她:AwAICAcABRQCCAAFAQguBgAfPAEBBRQACAAFAQguBgAfPAEBBRQAAA==.',['�']='流云开一朵丶:AwABCAEABRQAAQMAAAAGCAIABRQ=.流雲:AwAECAQABRQAAA==.',['�']='渊武:AwABCAEABAoAAA==.',['�']='源烨:AwACCAUABRQDCQACAQgdGgAVKIcABRQACQACAQgdGgAVKIcABRQACgABAQgpCAAIHTAABRQAAA==.',['�']='滴滴的弟弟:AwABCAEABRQAAA==.',['�']='狂妃紫月:AwACCAUABRQCBAACAQh7NQAGVWUABRQABAACAQh7NQAGVWUABRQAAA==.',['�']='疯出气质:AwACCAIABRQAAA==.',['�']='皇家时尚顾问:AwAECAQABRQAAA==.',['�']='芃芃灬其麦:AwAFCAQABAoAAA==.',['�']='草履虫:AwAHCAEABAoAAA==.',['�']='蜘蛛侦探:AwADCAoABRQDCwADAQhnBwA+2uoABRQACwADAQhnBwA3d+oABRQADAACAQhHIABPHaIABRQAAA==.',['�']='蝎子萊萊:AwAECAgABRQCCQAEAQjrAwBZUC4BBRQACQAEAQjrAwBZUC4BBRQAAA==.',['�']='蟑螂惡霸:AwAICAgABAoAAQ0ARgAHCAcABRQ=.',['�']='西冷七分熟:AwAICAgABAoAAA==.',['�']='请叫我詹姆斯:AwAECAgABRQCBAAEAQjEBwBRSiMBBRQABAAEAQjEBwBRSiMBBRQAAA==.',['�']='贝尔小纪:AwACCAMABRQCDgAIAQjvLgAc4T0BBAoADgAIAQjvLgAc4T0BBAoAAA==.',['�']='超超级赛亞人:AwAFCAsABAoAAA==.',['�']='野生的死骑:AwAECAcABAoAAA==.',['�']='长春丶吴彦祖:AwAGCBYABAoCAQAGAQi7OwA2N1sBBAoAAQAGAQi7OwA2N1sBBAoAAA==.长春丶徐志胜:AwAICAgABAoAAA==.',['�']='隨風:AwADCAcABRQDDwADAQgOFwArZN4ABRQADwADAQgOFwArZN4ABRQADQABAQgfGwAZijEABRQAAA==.',['�']='骑兵:AwAICAwABAoAAA==.',['�']='高贵的冰迪克:AwAICA8ABAoAAA==.',['�']='默默不语:AwADCAkABRQCEAADAQhYCgAxXO0ABRQAEAADAQhYCgAxXO0ABRQAAA==.',['�']='龍大号:AwACCAcABRQCBAACAQg/IQA4yLQABRQABAACAQg/IQA4yLQABRQAAA==.龍小号:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end