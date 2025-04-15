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
 local lookup = {'Rogue-Assassination','Shaman-Elemental','Hunter-BeastMastery','Druid-Restoration','Paladin-Retribution','Monk-Mistweaver','Shaman-Restoration','Paladin-Holy','Priest-Holy','Priest-Shadow','Priest-Discipline','Monk-Windwalker','DeathKnight-Unholy','DeathKnight-Frost','Mage-Frost','Unknown-Unknown','Druid-Balance','Mage-Fire','Hunter-Marksmanship','Monk-Brewmaster',}; local provider = {region='CN',realm='石锤',name='CN',type='weekly',zone=42,date='2025-04-14',data={Au='Aurror:AwAHCBwABAoCAQAHAQhAGQAslIIBBAoAAQAHAQhAGQAslIIBBAoAAA==.',Fa='Fannys:AwAFCAEABAoAAA==.',Kl='Klklkl:AwAHCAcABAoAAA==.',Kr='Krisodl:AwAGCAwABAoAAA==.',Mm='Mmei:AwACCAIABAoAAA==.',Po='Pogback:AwACCAQABRQAAQIAQJgCCAgABRQ=.',Te='Teackertony:AwADCAMABAoAAA==.',Wo='Wonalicuole:AwAHCAcABAoAAA==.',Xi='Xidian:AwAGCAkABAoAAA==.',['�']='一只小小从:AwAHCAcABAoAAA==.三个球砸死你:AwADCAMABAoAAA==.上汽大众:AwAECAQABRQAAA==.不善言辞:AwAECAMABRQAAQMAIV4GCAYABRQ=.丶小萌:AwAECAgABRQCBAAEAQibAwBKcR0BBRQABAAEAQibAwBKcR0BBRQAAA==.丶阿獠:AwADCAIABAoAAA==.',['�']='乌拉乌拉萨满:AwAECAEABRQAAA==.',['�']='余烬佳酿:AwAHCA0ABAoAAA==.你小妈:AwACCAIABRQAAA==.',['�']='偸鈊賊丶剴:AwAGCAYABAoAAA==.',['�']='冰火奥秘:AwACCAIABAoAAA==.',['�']='几亿光年:AwAHCA8ABAoAAA==.',['�']='切茜娅之手:AwAGCAYABAoAAA==.刘啫喱:AwABCAEABAoAAA==.',['�']='千寻:AwAECAQABRQAAA==.半条咸鱼丶:AwACCAIABRQAAA==.华丽的一刀:AwACCAIABRQAAA==.卷王:AwAECAQABAoAAA==.',['�']='吖丷頭:AwAICAgABAoAAA==.吖灬頭:AwAICAgABAoAAA==.',['�']='呼拉小子:AwAECAUABRQCBQAEAQh2LABLqI0ABRQABQAEAQh2LABLqI0ABRQAAA==.',['�']='哒哒是冠军:AwAECAQABRQAAA==.哔哩哔哔:AwAICAIABAoAAA==.哥本哈根拳师:AwAGCBYABAoCBgAGAQheMgA9CmIBBAoABgAGAQheMgA9CmIBBAoAAA==.',['�']='嗜血的叛逆:AwAICAgABAoAAA==.',['�']='图图真好玩:AwAECAYABRQCBwAEAQgZCwAx/OoABRQABwAEAQgZCwAx/OoABRQAAA==.',['�']='土地公:AwAHCAEABAoAAA==.',['�']='坏蛋:AwACCAIABRQAAA==.',['�']='壹箭灬封情:AwAICAgABAoAAA==.壹箭灬风情:AwAGCAYABAoAAA==.',['�']='夏天飘的雪:AwACCAgABRQDAgACAQi3DQBAmJIABRQAAgACAQi3DQBAmJIABRQABwACAQiFGwAkGooABRQAAA==.大山队长:AwAECAQABRQAAA==.大斧典韦:AwAHCAEABAoAAA==.天涯灬若熙:AwACCAIABAoAAA==.天蠍座:AwADCAMABAoAAA==.失梦:AwAICAgABAoAAA==.',['�']='奇佐:AwACCAIABRQDBQAHAQjjRABI2P0BBAoABQAHAQjjRABI2P0BBAoACAAFAQhwKgA0jtEABAoAAA==.套盾大天使:AwAGCBcABAoCCQAGAQizPAAyjRoBBAoACQAGAQizPAAyjRoBBAoAAA==.奶奶熊的奶茶:AwACCAEABRQAAA==.',['�']='宇智波牧:AwAHCB0ABAoCCgAHAQhUDABbknQCBAoACgAHAQhUDABbknQCBAoAAA==.宗成风:AwAICBoABAoCBwAIAQhuRwAgkEQBBAoABwAIAQhuRwAgkEQBBAoAAA==.',['�']='將丶:AwAGCAgABAoAAA==.小木头的怒火:AwABCAEABAoAAA==.小灬曼:AwABCAIABRQAAA==.小猎手:AwAGCAkABAoAAA==.小百灵鸟:AwAICAgABAoAAA==.小豆梓:AwADCAkABRQCCwADAQgPAgBixVcBBRQACwADAQgPAgBixVcBBRQAAA==.小豚:AwACCAIABRQAAA==.小马快走:AwAICAgABAoAAA==.少林功夫好:AwAECAoABRQCDAAEAQh6BABNWxkBBRQADAAEAQh6BABNWxkBBRQAAQEAOhQGCAYABRQ=.尘封忆:AwAFCAUABAoAAA==.尹瑟拉灬腥夜:AwACCAIABAoAAA==.',['�']='帅是一辈子的:AwACCAIABRQDCQAIAQhjRQAavvMABAoACQAHAQhjRQAaBPMABAoACwAGAQiYRwAYFcoABAoAAA==.',['�']='彦祖玩龙喷:AwABCAIABRQDDQAIAQg+PgAleYMBBAoADQAIAQg+PgAleYMBBAoADgAEAQhSIQAUs44ABAoAAA==.',['�']='心语芯愿:AwAHCBsABAoCDwAHAQjOMwAucHYBBAoADwAHAQjOMwAucHYBBAoAAA==.',['�']='托尔:AwAICAgABAoAARAAAAAGCAMABRQ=.',['�']='新人旧酒:AwAECAQABRQAAA==.新兵克林:AwAECAgABRQCCAAEAQj6AgBOWgcBBRQACAAEAQj6AgBOWgcBBRQAAA==.',['�']='早饭吃什么呢:AwAECAQABRQAAA==.旭丨风暴烈酒:AwAGCAcABAoAAA==.',['�']='星空夜殇:AwAICAYABAoAAA==.',['�']='暴风之眼:AwAICAIABAoAAA==.',['�']='枕砚:AwADCAMABRQAAA==.',['�']='樱井丶莉亞:AwADCAMABAoAAA==.樱络:AwAECAQABRQAAA==.',['�']='汐涵:AwAECAQABRQAAA==.',['�']='沐叁槍:AwACCAQABRQAAA==.沧灬桑:AwAICAgABAoAAA==.沾花:AwAHCBIABAoAAA==.',['�']='混沌岁月:AwAGCA4ABAoAAA==.淸緢淡冩:AwAECAQABRQAAA==.',['�']='灌县刘玄德:AwAGCA4ABAoAAA==.',['�']='熊猫提提米:AwACCAIABAoAAA==.',['�']='物尽天择:AwADCAUABAoAAA==.',['�']='甜甜的忧伤:AwADCAcABRQCAwADAQhjCABUbSEBBRQAAwADAQhjCABUbSEBBRQAAA==.',['�']='瘦瘦猫:AwAECAQABAoAAA==.',['�']='白彧瑾:AwAICAIABAoAAA==.',['�']='看渝可:AwAECAQABRQAAA==.',['�']='粉小满:AwAGCAkABAoAAA==.',['�']='绯血玉沙:AwAECAYABAoAAA==.',['�']='胧夜:AwAHCBwABAoCCQAHAQh9LQA1pWYBBAoACQAHAQh9LQA1pWYBBAoAAA==.',['�']='芊摩:AwAECAQABRQAAA==.芊沫:AwAECAgABRQCEQAEAQhkAgBhYlABBRQAEQAEAQhkAgBhYlABBRQAAA==.芒果星冰乐:AwAFCAsABAoAAA==.',['�']='蕾依莎:AwAICAgABAoAAA==.',['�']='誮訫囖啵:AwACCAQABAoAAA==.',['�']='诸葛天涯:AwAGCAkABAoAAA==.',['�']='谁的眼泪:AwAECAQABAoAAQIAQJgCCAgABRQ=.',['�']='赵精神:AwAFCAQABAoAAA==.',['�']='踏岚风:AwAICAkABAoAAA==.',['�']='阿贫:AwABCAIABRQDDwAIAQiCLABSF50BBAoAEgAHAQhxKwBJ4eIBBAoADwAHAQiCLAA4a50BBAoAAA==.',['�']='雪落吟:AwADCAMABAoAAA==.',['�']='霞之丘诗雨:AwAHCBkABAoDEwAHAQhpGQBDNMwBBAoAEwAHAQhpGQBDNMwBBAoAAwAFAQhVoAAic7cABAoAAA==.',['�']='青椒炒肉:AwADCAQABAoAAA==.',['�']='韩小樱:AwABCAEABRQAAA==.',['�']='魔灬由心生:AwAICBAABAoAAA==.',['�']='鸳鸳相抱:AwAHCBwABAoCFAAHAQjIEQAb2fYABAoAFAAHAQjIEQAb2fYABAoAAA==.',['�']='默灬:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end