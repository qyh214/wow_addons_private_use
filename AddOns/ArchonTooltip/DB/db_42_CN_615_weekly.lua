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
 local lookup = {'Paladin-Retribution','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Destruction','Monk-Windwalker','Evoker-Preservation','Hunter-BeastMastery','Warrior-Arms','Mage-Fire','Warrior-Fury','Shaman-Restoration','Paladin-Holy','Druid-Balance','Mage-Frost',}; local provider = {region='CN',realm='地狱咆哮',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ba='Banananana:AwAECAwABRQCAQAEAQjYDABUUQ0BBRQAAQAEAQjYDABUUQ0BBRQAAQIAAAAICAMABRQ=.',Be='Beastmaster:AwAECAQABRQAAA==.',Cr='Cruelsummer:AwACCAMABAoAAA==.',Fu='Funnymudpee:AwAECAYABRQDAwAEAQjfAwBbFS8BBRQAAwAEAQjfAwBbFS8BBRQABAACAQiIEgA4FoQABRQAAA==.',Lu='Luminous:AwACCAMABRQCBQAIAQjkBgBccrECBAoABQAIAQjkBgBccrECBAoAAA==.',Me='Meltryllis:AwAECAQABRQAAQMAQ3QGCA0ABRQ=.',No='Noordwolf:AwAGCAYABAoAAA==.',Or='Orion:AwAGCAYABAoAAA==.',Qq='Qqy:AwAFCAUABRQCBgAFAQgTAgAiG1wBBRQABgAFAQgTAgAiG1wBBRQAAA==.',Re='Resdayn:AwAICAwABAoAAA==.',Ro='Rolandy:AwAECAQABRQAAA==.',Su='Sunrise:AwAICAgABAoAAA==.',['�']='不能拳脚相向:AwAGCAEABAoAAA==.不能鲁莽:AwACCAIABAoAAA==.丶大哥找真爱:AwAECAQABRQAAA==.丿灬祈福:AwAECAQABRQAAA==.',['�']='乱世邪恶峎:AwACCAIABAoAAA==.',['�']='二向箔:AwAICAIABAoAAA==.云霆:AwAHCAcABAoAAA==.亡魂密使:AwABCAEABRQAAA==.',['�']='你想不到吧:AwAICBAABAoAAA==.',['�']='修修:AwAGCAsABAoAAA==.',['�']='别灬奶:AwACCAQABRQAAA==.',['�']='半弥残沙丶:AwAGCAIABRQAAA==.',['�']='叶舞之风:AwAECAQABRQAAA==.',['�']='吾辈楷模:AwAHCA0ABAoAAA==.',['�']='咖啡色的喵:AwABCAEABRQAAA==.',['�']='哇噻的小红河:AwAICAkABAoAAA==.',['�']='喷奶龙:AwAECBAABRQCBwAEAQjhAABWbCcBBRQABwAEAQjhAABWbCcBBRQAAA==.',['�']='嘎哈呢你:AwAICAgABAoAAA==.',['�']='大橘为重:AwAGCAsABAoAAA==.天灬籁:AwAECAQABRQAAA==.',['�']='奶油老登:AwAECAQABRQAAA==.',['�']='寂寞的羊羔:AwADCAUABAoAAA==.',['�']='小咕噜:AwAGCAIABRQAAA==.小皮球:AwAECAQABRQAAA==.就我快乐:AwACCAcABRQCCAACAQgyIgA4hJwABRQACAACAQgyIgA4hJwABRQAAA==.尾巴藏不住:AwAFCAQABAoAAA==.',['�']='巨阳小顽童:AwACCAQABRQCCQAIAQitAQBfLfMCBAoACQAIAQitAQBfLfMCBAoAAQoASMYECAoABRQ=.',['�']='心无旁骛丶:AwAECAQABRQAAA==.',['�']='悠带刀:AwAICAMABAoAAA==.',['�']='我叫小妹:AwAICAEABAoAAA==.',['�']='扯通的线裤:AwAECAQABRQAAA==.',['�']='提弓就是射:AwAICBIABAoAAA==.',['�']='敬蚩尤一杯酒:AwAICBAABAoAAQIAAAABCAEABRQ=.',['�']='旋一个:AwAHCAIABAoAAA==.',['�']='晨雾绿:AwAECAkABRQDCwADAQhJAgBjBF4BBRQACwADAQhJAgBjBF4BBRQACQABAQgjDwBZmWAABRQAAA==.',['�']='暗影灵柩:AwACCAIABRQAAQIAAAAGCAQABRQ=.暗矛族长:AwAFCAYABAoAAA==.暴雨来了:AwABCAIABRQAAA==.',['�']='桃失:AwAECAQABAoAAQIAAAABCAEABRQ=.',['�']='梦中的露露:AwAGCAIABRQAAA==.',['�']='極其簡單的:AwACCAIABRQAAA==.',['�']='正统部落萨满:AwAFCAUABAoAAA==.步川地窟:AwACCAcABRQCCAACAQgaIAA+gqMABRQACAACAQgaIAA+gqMABRQAAA==.',['�']='比卡比卡啾:AwAICAgABAoAAA==.',['�']='火照黑云:AwAECAQABRQAAQYAWZcGCBkABRQ=.灬拓风灬:AwAGCAYABAoAAA==.灬邪惡丨蔓延:AwABCAIABRQAAA==.灰流丽丶:AwAICAgABAoAAA==.',['�']='熊猫两千:AwACCAUABRQCDAACAQhmHAAaYYYABRQADAACAQhmHAAaYYYABRQAAA==.',['�']='狼之笑:AwACCAQABRQAAA==.',['�']='玩原神玩的:AwAFCAEABAoAAA==.',['�']='碎了的阳光:AwAECAEABRQCDAABAQhmLQAAAAAABRQADAABAQhmLQAAAAAABRQAAA==.',['�']='神一样小豪总:AwABCAEABRQAAA==.',['�']='禁书:AwAECAQABRQAAQIAAAAICAEABRQ=.',['�']='站吊:AwAECAMABAoAAA==.竹子青:AwAECAIABRQAAA==.',['�']='第七夜丶听雪:AwAICAgABAoAAA==.',['�']='膛线:AwACCAIABRQAAA==.',['�']='落寞丶煙愺菋:AwADCAYABRQDAQADAQi4IAAM0LcABRQAAQADAQi4IAAM0LcABRQADQACAQiBDQAZcXUABRQAAA==.',['�']='葵花点穴手:AwAECAQABRQAAA==.',['�']='虎皮瑞士卷:AwAFCAQABAoAAA==.',['�']='血之魔煞:AwAICAgABAoAAA==.',['�']='请你吃冰糕:AwAICAgABAoAAA==.',['�']='辉煌后的忧伤:AwAECAIABRQAAA==.辛红辣椒:AwAICAIABAoAAA==.',['�']='采药:AwAECAgABRQCDgAEAQgcAwBex0IBBRQADgAEAQgcAwBex0IBBRQAAQ4AQiQGCAoABRQ=.',['�']='铁甲小宝:AwAECAQABRQAAQoAJ70GCAoABRQ=.',['�']='雨中行走:AwACCAIABRQAAA==.',['�']='霜火法:AwABCAEABRQAAA==.露露逗你开心:AwAGCAIABRQAAQIAAAAICAQABRQ=.',['�']='静心:AwAECAoABRQDDwAEAQiCAwBQ+AwBBRQADwAEAQiCAwBQ+AwBBRQACgAEAQgdGgAoDtIABRQAAA==.非崷:AwAICAgABAoAAA==.非洲之心:AwAFCAQABAoAAA==.',['�']='飞翔的甲壳虫:AwABCAEABRQAAA==.',['�']='黄皮耗子:AwAECAIABRQAAA==.',['�']='齐格非:AwADCAMABRQDDwAIAQgJJgBKasMBBAoADwAIAQgJJgBI5sMBBAoACgAGAQhERABBsFoBBAoAAA==.',['�']='龙姐不想黑:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end