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
 local lookup = {'Hunter-BeastMastery','Druid-Balance','Druid-Restoration','Hunter-Marksmanship','Mage-Fire','Paladin-Retribution','Priest-Shadow','Paladin-Holy','Warrior-Fury','DeathKnight-Unholy','DeathKnight-Blood',}; local provider = {region='CN',realm='奈萨里奥',name='CN',type='weekly',zone=42,date='2025-04-14',data={La='Lancelots:AwAICAYABAoAAA==.',Ma='Mana:AwAICAgABAoAAA==.',Mi='Mill:AwAICAcABAoAAA==.',Ol='Oldgun:AwAGCAYABRQCAQAGAQhzAQA5mboBBRQAAQAGAQhzAQA5mboBBRQAAA==.',Ra='Rayfs:AwAICAgABAoAAA==.',Ro='Royle:AwAECAQABRQAAA==.',Se='Selene:AwAECAcABAoAAA==.',So='Soloshow:AwAECAQABRQAAA==.',Ti='Tiefang:AwAICBIABAoAAA==.',We='Welen:AwAFCAUABAoAAA==.',Xu='Xue:AwAICAgABAoAAA==.',['�']='一心一教:AwAHCA0ABAoAAA==.一次插四根:AwAGCAsABAoAAA==.不落小莱妹:AwAGCAwABAoAAA==.丽萨丶岩心:AwAECAIABRQAAA==.丽蒂丶墨菲斯:AwAECAIABRQAAA==.',['�']='八十八号伎师:AwAECAQABRQAAA==.六环至圣斩:AwAGCAYABAoAAA==.',['�']='凌梦露:AwAHCAcABAoAAA==.凑凑来留:AwAFCAUABAoAAA==.',['�']='可樂加牛奶:AwAECAgABRQDAgAEAQjjBABTxikBBRQAAgAEAQjjBABTxikBBRQAAwAEAQjvCwAVIqcABRQAAQMAPyYICAsABRQ=.叶枫哥:AwADCAoABRQDAQADAQjKCQBL9hgBBRQAAQADAQjKCQBL9hgBBRQABAABAQhZGQAYW0YABRQAAA==.',['�']='咻咻棉糀餹:AwAECAQABRQAAA==.',['�']='唐牛才是食神:AwAFCAMABAoAAA==.',['�']='埃波利耶塔:AwADCAcABRQCBQADAQjAHAAWOcIABRQABQADAQjAHAAWOcIABRQAAA==.',['�']='夜之愿:AwACCAIABAoAAA==.大米包租婆:AwAECAUABAoAAA==.大米打工萨:AwACCAMABAoAAA==.天之藍:AwABCAEABRQAAA==.天诡:AwABCAEABAoAAA==.',['�']='奶萨:AwADCAMABAoAAA==.',['�']='孤独的旅者:AwAFCAYABAoAAA==.',['�']='宋你一颗芽芽:AwAGCAYABAoAAA==.',['�']='小红手:AwAECAQABAoAAA==.小萌兜:AwAGCAYABAoAAA==.小贝:AwAICAgABAoAAA==.就是菜:AwADCAMABAoAAA==.',['�']='山岚之梦:AwACCAEABAoAAA==.',['�']='崔瀺:AwAGCAYABAoAAA==.',['�']='工藤峰子:AwABCAEABRQAAA==.工藤疯子:AwAFCBAABAoAAA==.',['�']='往后余生:AwAICA4ABAoAAA==.很深:AwAICAgABAoAAQEAShkGCA4ABRQ=.',['�']='怪叔叔的逆袭:AwABCAEABRQCBgAIAQipSQA8S/ABBAoABgAIAQipSQA8S/ABBAoAAA==.',['�']='旺旺仙贝:AwAFCAQABRQCBgAIAQivBABhOgUDBAoABgAIAQivBABhOgUDBAoAAA==.',['�']='月神湖浮尸:AwAICAgABAoAAQcAN1QGCAYABRQ=.',['�']='柊祈:AwAECAQABRQAAA==.柊镜:AwACCAIABRQAAA==.柏拉图的灵魂:AwAICAgABAoAAA==.',['�']='樱吹雪:AwACCAIABAoAAA==.',['�']='永铭于心:AwAECAQABRQAAQQAWpYGCAgABRQ=.',['�']='法力残渣:AwACCAIABAoAAA==.',['�']='洒洒水了:AwABCAEABAoAAA==.',['�']='浩南哥:AwABCAEABAoAAA==.海之狸:AwAGCAwABRQDBgAGAQibAQBOOYwBBRQABgAFAQibAQBW1YwBBRQACAAEAQiHBQAcEeAABRQAAA==.',['�']='消逝的雪:AwACCAIABRQAAA==.',['�']='清风徐徐:AwAGCAYABRQCCQAGAQiWAAAn/rgBBRQACQAGAQiWAAAn/rgBBRQAAA==.',['�']='滚不莱:AwADCAMABAoAAA==.',['�']='灵妖妖:AwACCAIABRQAAA==.灵岩大师:AwAFCAQABAoAAA==.',['�']='牛奶加咖啡:AwACCAIABRQAAA==.牛肉面三元:AwAGCAwABAoAAA==.',['�']='狸呜嗷:AwAGCAYABAoAAA==.',['�']='瓦德拉肯盾卫:AwAECAQABRQAAA==.',['�']='盖亚的愤怒:AwAFCAUABAoAAA==.',['�']='祖达萨圣眷者:AwAECAQABAoAAA==.',['�']='紫月緋雪:AwAECAQABRQAAA==.',['�']='红牌伎师:AwADCAYABRQCCgADAQgoDAAqVukABRQACgADAQgoDAAqVukABRQAAA==.',['�']='绯红的亚里亚:AwAGCAYABAoAAA==.',['�']='缘来是小强:AwACCAIABRQAAA==.',['�']='胖面包:AwAECAQABRQAAA==.',['�']='范尼是徳鲁伊:AwAICBsABAoCAgAIAQj3KwA5gOABBAoAAgAIAQj3KwA5gOABBAoAAA==.',['�']='莺歌燕舞:AwACCAIABAoAAA==.',['�']='萌萌小小龙:AwAFCAUABAoAAA==.萨拉丶晨星:AwACCAQABRQAAA==.',['�']='轩哥不新轩:AwAICAgABAoAAA==.',['�']='遛弯的小白:AwADCAMABAoAAA==.',['�']='醉生夢死:AwACCAYABRQCCwACAQj2GQAElUEABRQACwACAQj2GQAElUEABRQAAA==.',['�']='野性的守护:AwACCAYABRQDAwACAQjUDwAsDYIABRQAAwACAQjUDwAsDYIABRQAAgABAQjxLgANfC8ABRQAAA==.',['�']='隔壁小王子:AwAICAgABAoAAA==.',['�']='霞之丘诗羽:AwADCAcABRQCBQADAQgqFgApzeIABRQABQADAQgqFgApzeIABRQAAA==.',['�']='风行者丶痴念:AwAFCAgABAoAAA==.',['�']='饭饭崽:AwACCAIABAoAAA==.',['�']='香辛料:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end