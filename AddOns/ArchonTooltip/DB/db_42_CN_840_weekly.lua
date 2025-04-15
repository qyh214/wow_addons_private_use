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
 local lookup = {'Shaman-Elemental','Hunter-Marksmanship','Hunter-BeastMastery','Priest-Discipline','DemonHunter-Havoc','Paladin-Retribution','Paladin-Protection','Evoker-Devastation','Mage-Fire','Priest-Holy','Mage-Frost','Warlock-Destruction','Warlock-Demonology','Warrior-Fury','Monk-Mistweaver','Shaman-Restoration','Rogue-Assassination','Rogue-Subtlety','Rogue-Outlaw','Monk-Brewmaster','Unknown-Unknown',}; local provider = {region='CN',realm='达纳斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={Bi='Bility:AwACCAIABAoAAA==.',Ch='Chandlerbing:AwAICAgABAoAAA==.',Et='Ethanz:AwACCAEABAoAAA==.',Hm='Hms:AwAECAQABRQAAQEAVZkICAIABRQ=.',Ji='Jimzoe:AwABCAEABRQDAgAIAQh/KAAmvmwBBAoAAgAIAQh/KAAmvmwBBAoAAwAFAQg8pgAhc7cABAoAAA==.',Jo='Joyelmilk:AwAHCAcABAoAAA==.',Ju='Jude:AwAECAQABAoAAA==.Juliette:AwABCAIABRQAAA==.Juliy:AwABCAEABRQAAA==.',Ma='Maus:AwADCAgABRQCBAADAQg+DAAwGdwABRQABAADAQg+DAAwGdwABRQAAA==.',Mi='Michee:AwABCAMABRQAAA==.Mikolous:AwAECAQABRQAAA==.',Sy='Syou:AwACCAgABRQCBQACAQgeHABDg6gABRQABQACAQgeHABDg6gABRQAAA==.',Th='Thunderbolt:AwAECAQABRQAAA==.',Wi='Wireshark:AwACCAIABRQAAA==.',['�']='一杆大烟枪:AwAICBYABAoDBgAIAQgNiAAfzGcBBAoABgAIAQgNiAAfzGcBBAoABwABAAgAAAAAAAAABAoAAA==.一雪团团一:AwAGCAQABRQCBgAEAQj8FABJa/YABRQABgAEAQj8FABJa/YABRQAAA==.七夜圣光:AwABCAEABRQAAA==.丶南宫:AwABCAEABRQAAA==.',['�']='云霄鶬:AwAHCA0ABAoAAA==.',['�']='伊诺山度:AwAGCAYABAoAAA==.',['�']='你付出了什么:AwADCAQABRQCBQAIAQhJEgBUoIsCBAoABQAIAQhJEgBUoIsCBAoAAA==.你是不是聋鸣:AwAGCAgABRQCCAAGAQiaAgAsFHABBRQACAAGAQiaAgAsFHABBRQAAA==.',['�']='克伦海德公爵:AwABCAEABAoAAA==.兜兜里有糖:AwABCAEABRQAAA==.',['�']='冫疑冫青:AwABCAEABRQAAA==.',['�']='卡林姆的意志:AwAECAgABRQCBgAEAQi7FwA0Qu4ABRQABgAEAQi7FwA0Qu4ABRQAAA==.',['�']='只想用头撞墙:AwAGCAoABAoAAA==.',['�']='哈士骑:AwACCAIABAoAAA==.',['�']='圄圄兔:AwACCAQABRQAAA==.',['�']='坦爷:AwAECAQABAoAAA==.',['�']='塞巴斯蒂安丶:AwAECAgABRQCCQAEAQjeEgBD1PMABRQACQAEAQjeEgBD1PMABRQAAA==.',['�']='壹米陽光:AwACCAIABRQAAA==.',['�']='夏日海滨:AwAICAwABAoAAA==.夢幻丶薄桜:AwABCAEABRQCCgAIAQgFCgBORHUCBAoACgAIAQgFCgBORHUCBAoAAQUAQ4MCCAgABRQ=.大家速度灭:AwAECAQABRQAAA==.大眼睛骑士:AwAFCAUABAoAAA==.大魔导师:AwACCAIABAoAAA==.天堂里的地狱:AwAECAQABRQAAA==.天魔行:AwACCAIABAoAAA==.失业的江南:AwABCAEABRQAAA==.',['�']='子衿灬:AwAECAUABAoAAA==.',['�']='小巧卝朦胧:AwAECAQABRQAAA==.小拳拳锤你哟:AwABCAIABRQAAA==.小牛奶:AwAECAMABRQAAQkALZoICAUABRQ=.小田佩奇:AwAICAwABAoAAQgATrEECBMABRQ=.',['�']='彼岸的风铃:AwAECAoABRQDCwAEAQjhAwBJYw0BBRQACwAEAQjhAwBJYw0BBRQACQACAQhQKwAwwIMABRQAAA==.',['�']='戮之微笑:AwAFCAUABAoAAA==.',['�']='无所谓的飞盾:AwAECAYABAoAAA==.',['�']='晓安:AwACCAIABRQAAA==.晨曦月影:AwABCAEABRQAAA==.',['�']='暮筱:AwAGCAYABAoAAA==.',['�']='曦雲似水:AwACCAIABAoAAA==.',['�']='月半熊:AwAECAgABRQDDAAEAQifBQBXDyEBBRQADAADAQifBQBXDyEBBRQADQABAQhzGQAAAAAABRQAAQwAT7oGCA4ABRQ=.术手巫策:AwADCAMABRQAAA==.',['�']='李娜莉:AwAHCBQABAoCBgAHAQgqWwBGwM0BBAoABgAHAQgqWwBGwM0BBAoAAA==.村里的鸡:AwAGCA0ABAoAAA==.',['�']='武极:AwABCAEABAoAAA==.',['�']='水果沙拉:AwAICAQABAoAAA==.',['�']='汝之所向:AwACCAQABRQAAA==.江南酿造厂长:AwABCAEABRQAAA==.江浸月丶:AwAICAgABAoAAA==.',['�']='浅尝思念:AwACCAQABRQAAA==.浅笑瀡訫:AwAFCAUABAoAAA==.浮生半日:AwABCAMABRQAAA==.',['�']='灵冰:AwAHCAEABAoAAA==.灵魂无畏:AwADCAUABAoAAA==.',['�']='炒年糕:AwAICA8ABAoAAA==.',['�']='玉风:AwACCAIABAoAAA==.',['�']='白河愁:AwABCAIABRQAAA==.白露為霜:AwABCAMABRQAAA==.',['�']='皓月鸣响:AwAECAUABAoAAA==.',['�']='盼盼:AwAFCAUABAoAAA==.',['�']='碉堡了:AwADCAMABAoAAA==.',['�']='神秘壹号演员:AwAECAIABRQCAwACAQiEKwAtWI0ABRQAAwACAQiEKwAtWI0ABRQAAA==.',['�']='红炎海棠:AwADCAkABRQCDgADAQhPBABVfTkBBRQADgADAQhPBABVfTkBBRQAAA==.',['�']='终极皮皮怪:AwACCAIABAoAAA==.',['�']='背叛天使:AwAFCAQABAoAAA==.胖坑酱:AwAICAgABAoAAA==.胖虎偷油吃:AwAECAoABRQCDwAEAQj6BgBKDhsBBRQADwAEAQj6BgBKDhsBBRQAAA==.胖虎打酱油:AwAGCAYABRQCEAAGAQgLAABf2jUCBRQAEAAGAQgLAABf2jUCBRQAAA==.',['�']='脉冲高达:AwABCAEABRQAAA==.',['�']='范塔斯笛:AwAHCAcABAoAAA==.',['�']='草莓熊:AwAICAYABAoAAA==.',['�']='莫贺延碛:AwABCAIABAoAAA==.',['�']='蒹葭:AwAGCAYABAoAAA==.',['�']='蛮三刀:AwACCAIABAoAAA==.',['�']='蝉声无尽:AwACCAIABRQAAA==.',['�']='赫敏格兰杰:AwAECAQABAoAAA==.',['�']='达纳斯小贩:AwAGCAIABRQCBwACAQglCwAmUpEABRQABwACAQglCwAmUpEABRQAAA==.',['�']='郗尔瓦纳斯:AwAICAgABAoAAQwAWXwHCAoABRQ=.',['�']='青枫:AwAECAEABRQAAA==.非常无姜君:AwAECAQABRQAAA==.',['�']='顺水:AwACCAIABRQAAA==.',['�']='风之影傲雪:AwAECAQABRQAAA==.风暴英雄周卓:AwAHCBIABAoAAA==.',['�']='马保国:AwAFCAkABAoAAA==.',['�']='黄色的西瓜:AwAECAQABRQEEQAIAQj4EQBCAOsBBAoAEQAIAQj4EQA+NusBBAoAEgAIAQjwGAAWAWUBBAoAEwAGAQhuDAAx6gYBBAoAAA==.黑色的西瓜:AwAICBYABAoCFAAIAQiZBwBJduIBBAoAFAAIAQiZBwBJduIBBAoAARUAAAAICAIABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end