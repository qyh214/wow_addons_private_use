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
 local lookup = {'Paladin-Any','Paladin-Retribution','Paladin-Protection','Unknown-Unknown','Druid-Restoration','Priest-Shadow','Mage-Fire','Priest-Holy','Priest-Discipline','Hunter-BeastMastery','Monk-Brewmaster',}; local provider = {region='CN',realm='奥妮克希亚',name='CN',type='weekly',zone=42,date='2025-04-14',data={Bo='Boxbaby:AwAECAQABRQAAA==.',Ju='Justalex:AwAICAkABAoAAQEANLAGCAYABRQ=.',Oi='Oissii:AwABCAIABRQAAA==.',To='Torukmakto:AwACCAYABRQDAgACAQhvJQA9faAABRQAAgACAQhvJQA9faAABRQAAwABAQgXFgABYB4ABRQAAA==.',Up='Uprising:AwACCAYABRQCAgACAQgLKwAlLZAABRQAAgACAQgLKwAlLZAABRQAAA==.',['�']='一尛尛益一:AwAICAgABAoAAQQAAAAGCAQABRQ=.一朵小红花:AwACCAIABAoAAA==.上我奶你:AwADCAIABAoAAA==.',['�']='么么牧:AwAICA8ABAoAAA==.乌蒙圣骑:AwACCAIABAoAAA==.乐乐:AwABCAEABRQAAA==.',['�']='以德扶人:AwABCAEABAoAAA==.',['�']='你这个老六:AwACCAIABRQAAA==.',['�']='冰糖拿铁:AwAECAQABAoAAA==.',['�']='凸勒拔姬:AwADCAMABAoAAA==.',['�']='剧毒皮卡丘:AwAECAQABRQAAA==.',['�']='北斗五指裂弹:AwAHCAcABAoAAA==.',['�']='千城:AwACCAYABRQCAgACAQjGIgA6gawABRQAAgACAQjGIgA6gawABRQAAA==.千尾离鸢:AwAECAQABRQAAA==.卡迪恩:AwAFCAsABAoAAA==.',['�']='可乐真好喝:AwACCAcABRQCAgACAQhJJQBOZaEABRQAAgACAQhJJQBOZaEABRQAAA==.可青可:AwAGCAYABAoAAA==.',['�']='喻文波:AwAGCAYABAoAAA==.',['�']='塞巴斯帝安:AwAECAQABRQCBQAEAQjvBABC2wMBBRQABQAEAQjvBABC2wMBBRQAAA==.',['�']='夏沫星辰:AwABCAIABRQCAgAGAQi14QAKhrMABAoAAgAGAQi14QAKhrMABAoAAA==.夏熙路:AwABCAEABRQAAA==.大德无形:AwAECAQABRQAAQYAN1QGCAYABRQ=.',['�']='奉西:AwABCAEABRQAAA==.',['�']='小小沫娴:AwAECAQABRQAAA==.小春惠美纪:AwAHCAcABAoAAA==.小白龍:AwACCAIABRQAAA==.小螺号嘀嘀吹:AwADCAEABAoAAA==.',['�']='巨熊守峦峰:AwAGCAwABAoAAA==.',['�']='忌弑安魂曲:AwAGCAkABAoAAA==.',['�']='急速萝卜:AwAECAYABRQCBwACAQglJQAuWpEABRQABwACAQglJQAuWpEABRQAAA==.',['�']='春熙路丶:AwAFCAUABAoAAA==.',['�']='普罗塔斯:AwAGCAYABAoAAA==.',['�']='最终之守望:AwAECAQABRQAAA==.月落凝霜:AwAECAQABRQAAA==.有种下课单挑:AwAFCA0ABAoAAA==.朋友萨缺吗:AwAGCAYABAoAAA==.望明月:AwABCAEABAoAAA==.本间芽衣子:AwAICA4ABAoAAA==.',['�']='梵净山:AwAGCBUABAoDCAAGAQi6UAAeuMgABAoACAAGAQi6UAAbKsgABAoACQAFAQgsXAAPBYUABAoAAA==.',['�']='橙子菠萝汁:AwADCAMABAoAAA==.橙鱼零度空间:AwACCAMABRQAAA==.',['�']='欧豆豆们哟:AwACCAQABRQAAA==.',['�']='死饥魔:AwAICAcABAoAAA==.',['�']='涅槃芬芳:AwACCAIABAoAAA==.',['�']='熙熙:AwAECAQABRQAAA==.',['�']='甘甘:AwAECAEABRQAAA==.',['�']='箭男春:AwAGCAoABAoAAA==.',['�']='背叛者之赐:AwAICAgABAoAAA==.胖达圆圆:AwACCAIABAoAAA==.',['�']='舞丶僧:AwABCAEABAoAAA==.',['�']='艾瑞莉娅:AwABCAIABRQAAA==.',['�']='蓝之殇:AwAECAYABAoAAA==.',['�']='薩拉祈尔:AwAFCAUABAoAAA==.',['�']='西风岚:AwAECAQABRQAAA==.',['�']='言宁:AwAICAgABAoAAA==.言宁宝宝:AwACCAIABRQCCgACAQj7JgA22pAABRQACgACAQj7JgA22pAABRQAAA==.',['�']='请叫我达文西:AwABCAEABRQAAA==.',['�']='这是一个小号:AwABCAEABAoAAA==.迪迪大领主:AwAECAwABRQCAgAEAQj7DwBFawABBRQAAgAEAQj7DwBFawABBRQAAA==.',['�']='逐风之心:AwAGCAEABAoAAA==.',['�']='野蠻神話:AwAICAUABAoAAA==.',['�']='闪闪的你:AwAICAgABAoAAA==.',['�']='阳光男高丿:AwAFCAUABAoAAA==.阿布哒:AwACCAIABAoAAA==.阿斯拉:AwAECBEABRQCCwAEAQjtAABWdCwBBRQACwAEAQjtAABWdCwBBRQAAA==.',['�']='风雨丶:AwAHCAcABAoAAA==.风雨呢喃丶:AwAECAQABAoAAA==.风雨呢難:AwACCAIABAoAAA==.飞寳呼呼呀:AwACCAIABRQAAA==.',['�']='黯淡地圣光:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end