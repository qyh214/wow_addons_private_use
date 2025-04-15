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
 local lookup = {'Mage-Fire','Warlock-Affliction','Warlock-Destruction','Paladin-Retribution','Shaman-Elemental','Shaman-Restoration','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Arms','Hunter-BeastMastery','Priest-Discipline','Priest-Shadow','Druid-Balance','Hunter-Marksmanship','Priest-Holy','Unknown-Unknown','Monk-Windwalker','Mage-Frost',}; local provider = {region='CN',realm='弗塞雷迦',name='CN',type='weekly',zone=42,date='2025-04-14',data={Et='Eternalmist:AwAECAgABRQCAQAEAQhXFAA4I+cABRQAAQAEAQhXFAA4I+cABRQAAA==.',Ha='Hatsunemiku:AwAECAEABAoAAA==.',Ix='Ixshishi:AwAFCAUABAoAAA==.',Ja='Jasckrios:AwADCAgABRQDAgADAQguDwAhlpEABRQAAgACAQguDwAgFZEABRQAAwACAQj6HgAUd2UABRQAAA==.',Po='Power:AwAECAgABRQCBAAEAQh+EgBNkPcABRQABAAEAQh+EgBNkPcABRQAAA==.',['�']='一头奶牛:AwABCAEABRQAAA==.丨好多鱼丶:AwABCAEABRQCBAAIAQjWTgA+nuIBBAoABAAIAQjWTgA+nuIBBAoAAA==.丨目无王法丨:AwAGCAYABAoAAA==.丶彦祖:AwAECAYABRQDBQAEAQhxAQBdbjkBBRQABQAEAQhxAQBdbjkBBRQABgACAQhBGABCwZYABRQAAA==.',['�']='云梦瑶:AwAGCAoABRQCBAAGAQhXAABMUP0BBRQABAAGAQhXAABMUP0BBRQAAA==.',['�']='任朝野:AwAICAQABRQAAA==.',['�']='六筒:AwABCAEABAoAAA==.',['�']='凯尔文:AwADCAMABAoAAA==.凶猛小朋友:AwACCAQABRQDBwAIAQg1LAA1qd8BBAoABwAIAQg1LAAzJN8BBAoACAADAQgyPQAwfJsABAoAAA==.',['�']='别看我长得丑:AwABCAEABRQCCQAIAQi4FAAzNOgBBAoACQAIAQi4FAAzNOgBBAoAAA==.别看我长得妖:AwAFCAUABAoAAQkAMzQBCAEABRQ=.别看我长得矮:AwAHCAEABAoAAQkAMzQBCAEABRQ=.',['�']='原始圣骑:AwAECAYABRQCBAAEAQipDwBR0QIBBRQABAAEAQipDwBR0QIBBRQAAA==.',['�']='古月虎:AwACCAQABRQAAA==.',['�']='吃骨头的鱼灬:AwABCAEABRQAAA==.',['�']='四喜丸子:AwABCAEABRQAAA==.回首心远:AwAICAYABAoAAA==.',['�']='夙翼:AwACCAYABRQCCgACAQhKKQAjgIoABRQACgACAQhKKQAjgIoABRQAAA==.大公主的双剑:AwADCAQABRQAAQcAMf0GCA4ABRQ=.大笨牛牛:AwAECAQABRQAAA==.',['�']='奎托斯:AwAECAQABRQAAQoAShkGCA4ABRQ=.',['�']='小鸟游星野:AwABCAEABRQAAA==.',['�']='屠苏:AwAECAcABRQDCwAEAQi6BwBGY/kABRQACwAEAQi6BwBGY/kABRQADAABAQhrHAA4nEsABRQAAA==.',['�']='戒了个律:AwAGCAIABRQAAA==.',['�']='抹茶培根:AwAFCAYABAoAAA==.',['�']='拔起树根然后:AwAECAQABRQAAQ0AQIkGCAUABRQ=.',['�']='星丶空:AwAGCAQABRQAAA==.',['�']='晚桥:AwACCAIABRQAAA==.',['�']='林凤云:AwACCAIABRQAAQkAS5IGCBAABRQ=.',['�']='梦幻芭比:AwADCAMABAoAAQ4ANAgDCAgABRQ=.',['�']='椰风挡不住:AwACCAEABRQAAA==.',['�']='欧吉酱:AwAECAQABRQAAA==.',['�']='法師娃:AwAICBAABAoAAA==.',['�']='滅門聖洸:AwAECAQABRQAAA==.',['�']='灵之仲达:AwAECAQABRQAAA==.',['�']='熊猫滑翔者:AwABCAIABRQAAA==.',['�']='玄灵:AwAECAQABRQAAA==.玛卡巴卡丶:AwAECAQABRQAAA==.',['�']='皇灬诺加娜:AwAICA4ABAoAAA==.',['�']='秋山雪月漠惜:AwABCAEABRQAAA==.',['�']='粉红毛兔兔:AwAECAgABRQDCwAEAQgHCQA+HewABRQACwAEAQgHCQA+HewABRQADwAEAQj+CAArXtMABRQAAA==.',['�']='绝对小猛汉:AwEDCAMABRQAARAAAAAICAMABRQ=.维生素蒂:AwAECAQABRQAAA==.维纳斯的诅咒:AwACCAIABRQAAA==.',['�']='耀西:AwAECAQABRQAAA==.',['�']='胖胖萨满:AwAECAQABRQAAA==.',['�']='艾米斯菲尔:AwACCAIABRQAAA==.',['�']='莫提斯:AwAECAkABRQCEQAEAQgdAwBWwjQBBRQAEQAEAQgdAwBWwjQBBRQAAA==.',['�']='菜鸡互啄:AwAECAQABRQAARAAAAAGCAQABRQ=.',['�']='醉暧馬娓:AwADCAMABRQDEgAIAQisKABDgrMBBAoAEgAIAQisKABDgrMBBAoAAQACAQjdfQAVAGwABAoAAA==.',['�']='钮扣熊:AwAECAQABRQAAA==.',['�']='陈刀崽:AwAECAQABRQAAA==.',['�']='魅塔骑士:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end