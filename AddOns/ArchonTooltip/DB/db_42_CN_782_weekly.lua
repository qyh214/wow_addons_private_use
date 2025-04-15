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
 local lookup = {'Shaman-Restoration','Druid-Restoration','Priest-Shadow','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Monk-Mistweaver','Monk-Windwalker','Druid-Balance','Hunter-BeastMastery','Priest-Holy','Paladin-Retribution','Warrior-Fury','Priest-Discipline','Rogue-Assassination',}; local provider = {region='CN',realm='索拉丁',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Anthea:AwAICAIABAoAAA==.',As='Asleeda:AwAGCAQABRQAAA==.',Bi='Bingoyi:AwAECAQABRQAAA==.',Bo='Bobo:AwAECAcABRQCAQAEAQjDDAAoDeEABRQAAQAEAQjDDAAoDeEABRQAAQIAOkwGCAUABRQ=.',Ef='Efrosini:AwAGCAoABAoAAA==.',Lu='Lucifersatan:AwAICAsABAoAAA==.',Ma='Masami:AwACCAYABRQCAwACAQh3EwA3i5cABRQAAwACAQh3EwA3i5cABRQAAA==.',Na='Narcisse:AwAECAQABRQAAA==.',Pr='Proazrael:AwABCAEABAoAAA==.Promising:AwAECAQABRQAAA==.Prowarlock:AwAECAgABRQDBAAEAQjoBABXkh8BBRQABAAEAQjoBABXkh8BBRQABQABAQjfFgAAAAAABRQAAA==.',Se='Serah:AwAECAYABRQCBAAEAQhfEQAap78ABRQABAAEAQhfEQAap78ABRQAAQYANmYGCAYABRQ=.',Th='Thalia:AwAICAgABAoAAA==.',Wo='Wonderlandkk:AwABCAEABRQAAA==.',['�']='一拳穿天:AwAICAgABAoAAA==.七夜小殇君:AwAICAgABAoAAA==.三千阿堵:AwACCAMABRQDBwAIAQjyHwA9j84BBAoABwAHAQjyHwBCAs4BBAoACAAFAQj/PQAmqOcABAoAAA==.',['�']='乐在琦中:AwADCAMABAoAAA==.',['�']='二十一克拉:AwAICA8ABAoAAA==.二班同学:AwAGCAwABAoAAA==.',['�']='休息一下:AwAHCAUABAoAAA==.',['�']='佛法无边无级:AwACCAIABRQAAA==.',['�']='信仰战:AwACCAIABRQAAA==.',['�']='其实我是死骑:AwAGCAYABAoAAA==.',['�']='冰美式一喵喵:AwAECAgABRQCBAAEAQhlBQBPEhkBBRQABAAEAQhlBQBPEhkBBRQAAA==.',['�']='刀斩长腿:AwAECAQABAoAAA==.别打了要碎了:AwACCAIABRQAAA==.',['�']='名字并不重要:AwAICBAABAoAAA==.吴一凡:AwACCAIABRQAAA==.',['�']='咖啡加牛奶:AwAFCAUABAoAAA==.',['�']='回忆从前:AwACCAEABAoAAA==.国宝壹号:AwAHCAwABAoAAA==.',['�']='土拨鼠哑巴了:AwAICAcABAoAAA==.',['�']='坚石萨:AwAECAQABRQAAA==.',['�']='塔奇克码:AwABCAIABRQAAA==.塔奇克马:AwAICA8ABAoAAA==.',['�']='夏咯蒂:AwAECAQABRQAAA==.夏末梧桐:AwAICBwABAoDAgAIAQi9EQBDwhUCBAoAAgAIAQi9EQBDwhUCBAoACQAIAQi5LQBKiNcBBAoAAA==.大地战骑:AwAECAQABRQAAA==.大明一狂人:AwAECAQABAoAAA==.天天锤贴贴:AwACCAIABRQAAA==.天暗星:AwAECAQABRQAAA==.',['�']='奥丁:AwACCAIABRQAAA==.奥蕾利亚:AwACCAIABRQAAA==.好运的小熊:AwADCAUABRQCCgADAQgUFAApLeoABRQACgADAQgUFAApLeoABRQAAA==.',['�']='妖妖凛:AwABCAEABRQAAA==.',['�']='小圣君:AwAICAwABAoAAA==.小灬嘿嘿:AwAICAUABAoAAA==.小红手:AwAECAMABRQAAA==.',['�']='幻缘:AwABCAEABRQAAA==.',['�']='弗洛伦斯:AwAICBoABAoCCwAIAQiSDABLI1ICBAoACwAIAQiSDABLI1ICBAoAAA==.',['�']='往者已矣:AwACCAEABAoAAA==.徳古拉:AwADCAYABRQCDAADAQgVGwAiQNkABRQADAADAQgVGwAiQNkABRQAAA==.',['�']='懵圈界的千语:AwAICAgABAoAAQoAShkGCA4ABRQ=.',['�']='我叫一百六:AwAGCAQABRQCAQAIAQhuFQBPvzYCBAoAAQAIAQhuFQBPvzYCBAoAAA==.我来组成臀部:AwAECAQABRQAAA==.',['�']='搜狐:AwAICAUABAoAAA==.',['�']='梦里浅笑:AwAICAgABAoAAA==.',['�']='樱满集:AwAICAUABAoAAA==.',['�']='橙色脆皮鸡:AwAFCAUABAoAAA==.',['�']='淘浆糊:AwADCAMABAoAAA==.',['�']='清晨丶夜太魅:AwADCAMABAoAAA==.',['�']='湛蓝天空:AwAGCAYABAoAAA==.',['�']='狮心王:AwAECAQABRQAAA==.',['�']='由月与地:AwAICAYABAoAAA==.电梯征服者:AwAHCAsABAoAAA==.',['�']='百倍速的污:AwAICAIABAoAAA==.',['�']='盲人摸骨:AwADCAYABAoAAA==.',['�']='看我眼里有光:AwAECAQABRQAAA==.',['�']='秋水落霞:AwAICBQABAoCDAAIAQjGCABiZO0CBAoADAAIAQjGCABiZO0CBAoAAA==.',['�']='糟老头子:AwAGCAYABAoAAA==.',['�']='紫玉玲珑:AwABCAEABRQAAA==.',['�']='缺啥:AwAECAQABRQAAA==.',['�']='耳朵是不是龙:AwAECAgABRQCBgAEAQi8AABitE4BBRQABgAEAQi8AABitE4BBRQAAA==.',['�']='肉烧饼:AwABCAIABRQCDAAIAQgtOwBHixsCBAoADAAIAQgtOwBHixsCBAoAAA==.肥牛牛:AwAFCAUABAoAAA==.',['�']='芝麻狐:AwAECAQABRQAAA==.',['�']='苞芦馃:AwAFCAUABAoAAA==.',['�']='菊花毁灭者:AwACCAEABAoAAA==.',['�']='蓝色体育生:AwACCAIABAoAAA==.蓝霆:AwAECAQABRQAAA==.',['�']='被風熄滅:AwAFCAgABAoAAQcARBQICBcABAo=.',['�']='赤旗:AwAECAQABRQAAA==.',['�']='踩踩:AwABCAIABRQAAA==.',['�']='辞镜:AwAECAQABRQAAA==.',['�']='锁甲三废:AwADCAUABAoAAA==.',['�']='阴影之刺:AwAECAQABAoAAA==.阿咔莎:AwACCAMABRQAAA==.',['�']='雪河:AwAGCAYABAoAAA==.',['�']='风雨同舟:AwAECAQABAoAAA==.',['�']='魂之明:AwACCAEABRQCDQAIAQg5HAA+6BYCBAoADQAIAQg5HAA+6BYCBAoAAA==.魔兽世界:AwAECAQABRQAAA==.魔鬼咬巫婆:AwAICB4ABAoDCwAIAQhlHgA62L8BBAoACwAIAQhlHgA62L8BBAoADgABAQiViQAKqRwABAoAAA==.',['�']='麻酥糖:AwAICBQABAoCDwAIAQgmGwAZlmsBBAoADwAIAQgmGwAZlmsBBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end