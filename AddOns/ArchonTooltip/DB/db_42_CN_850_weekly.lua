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
 local lookup = {'Warlock-Destruction','Warlock-Affliction','DeathKnight-Unholy','Unknown-Unknown','Evoker-Devastation','Evoker-Preservation','Monk-Mistweaver','Druid-Balance','Mage-Frost','Mage-Fire','Paladin-Retribution','Priest-Shadow','Druid-Restoration','Evoker-Augmentation',}; local provider = {region='CN',realm='逐日者',name='CN',type='weekly',zone=42,date='2025-04-15',data={Dr='Drakeedog:AwAGCAYABRQDAQAEAQgnBgBQ1RsBBRQAAQAEAQgnBgBQ1RsBBRQAAgACAQj6DgBDjJoABRQAAA==.',Em='Emmy:AwAICA8ABAoAAA==.',Et='Eternalia:AwAGCAcABAoAAA==.',Ev='Evilddkdming:AwAECAUABRQCAwAEAQhWCABLOggBBRQAAwAEAQhWCABLOggBBRQAAA==.',Lo='Loved:AwAGCAQABRQAAQQAAAAHCAIABRQ=.',Ma='Maxmage:AwAGCAcABAoAAA==.',On='Onion:AwAGCAQABRQDBQAIAQgkJgBZI1YBBAoABQAFAQgkJgBcRlYBBAoABgADAQj9EgBMLw4BBAoAAQQAAAAHCAIABRQ=.',Ph='Phil:AwACCAQABRQAAA==.',Pp='Pphil:AwABCAEABAoAAA==.',Xi='Xingyuganlin:AwAFCAgABAoAAA==.',Ze='Zerting:AwACCAIABAoAAA==.',['�']='丨霸灬霸丨:AwACCAIABRQAAA==.',['�']='二粒蛋:AwAGCAcABAoAAA==.云之呢喃:AwAECAQABRQAAA==.人红手黑:AwAECAQABRQAAA==.',['�']='光羽闪耀:AwACCAIABAoAAA==.八级大狂風:AwAICAYABAoAAA==.',['�']='冈特:AwAGCAYABAoAAA==.',['�']='北城别西城诀:AwACCAUABRQCBwACAQhiHQAiwYEABRQABwACAQhiHQAiwYEABRQAAA==.',['�']='和泉妃爱丶:AwAECAQABRQAAA==.',['�']='土霉素:AwADCAIABAoAAQgARVEHCAcABRQ=.圣光照耀黑暗:AwAHCAoABAoAAA==.',['�']='大猫小猫:AwABCAEABRQAAA==.夹夹两个栗子:AwACCAIABRQAAA==.',['�']='好梦:AwAHCA4ABAoAAA==.',['�']='孤城乱舞:AwAGCAEABAoAAA==.',['�']='小小书童:AwAFCAgABAoAAA==.小工:AwAECAQABRQAAA==.小流氓丶:AwADCAMABAoAAA==.',['�']='川贝枇杷膏:AwAICAgABAoAAA==.',['�']='放火的:AwACCAIABRQAAA==.',['�']='无中灬生有:AwABCAEABAoAAA==.无心回忆:AwACCAIABRQAAA==.',['�']='星丶玥:AwADCAMABRQAAA==.',['�']='晓山瑞希:AwAHCAcABAoAAA==.',['�']='术术口:AwABCAEABRQAAA==.',['�']='永巷丶:AwACCAIABAoAAA==.',['�']='没事吃西瓜:AwAICBgABAoCCQAIAQhLCgBWqaICBAoACQAIAQhLCgBWqaICBAoAAA==.',['�']='泉丶此方:AwABCAEABRQCCgAIAQg1IAA/3SgCBAoACgAIAQg1IAA/3SgCBAoAAA==.',['�']='灼眼的夏丶娜:AwABCAEABRQAAA==.',['�']='牛志达:AwACCAQABRQCCwAIAQiGEwBcsL0CBAoACwAIAQiGEwBcsL0CBAoAAQwANl0GCAoABRQ=.',['�']='王仙芝:AwAFCAEABAoAAA==.',['�']='生如洋葱:AwAICA0ABAoAAQQAAAAHCAIABRQ=.',['�']='知更鸟:AwAECAYABRQDAgAEAQihAwBRJQ8BBRQAAgAEAQihAwBRJQ8BBRQAAQACAQgeHQAzTn8ABRQAAA==.',['�']='绯弹的亚里亚:AwABCAEABAoAAA==.绿色保护着你:AwADCAMABAoAAA==.',['�']='群星间的低语:AwADCAkABRQCCwADAQg9HwAcH9MABRQACwADAQg9HwAcH9MABRQAAA==.',['�']='荆棘十字:AwAICAgABAoAAA==.',['�']='葡萄派:AwACCAcABRQDDQACAQg4GgAs+EEABRQADQABAQg4GgApskEABRQACAABAQjELQAeZUAABRQAAA==.',['�']='薄雾熏熏:AwACCAIABRQAAA==.',['�']='蛐蛐女仕:AwAECAQABAoAAA==.',['�']='谁要男妈妈:AwAECAEABAoAAA==.',['�']='農婦三拳:AwABCAEABRQAAA==.',['�']='邪恶猫猫头:AwAICAgABAoAAA==.',['�']='陈老师:AwADCAQABRQAAA==.',['�']='须臾涧:AwABCAEABRQAAA==.',['�']='风之彩:AwAHCAEABAoAAA==.',['�']='马三娘:AwABCAEABRQAAA==.',['�']='鸿运齐天蛊:AwAFCAEABAoAAA==.',['�']='黎明风暴:AwACCAIABRQAAA==.黑叶:AwAICCUABAoDDQAIAQi7DgBKCTwCBAoADQAIAQi7DgBKCTwCBAoACAAIAQj/JwBAigMCBAoAAA==.',['�']='龍舌蘭寶寶:AwABCAEABRQDBQAHAQjqMQATk/UABAoABQAHAQjqMQATk/UABAoADgABAQgKCQADRQ8ABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end