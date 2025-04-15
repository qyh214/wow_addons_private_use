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
 local lookup = {'Paladin-Retribution','Hunter-BeastMastery','Unknown-Unknown','Druid-Feral','Druid-Balance','Druid-Restoration','Evoker-Preservation','Evoker-Devastation','Hunter-Marksmanship','Mage-Frost','Warrior-Fury','Mage-Fire','Warlock-Affliction','Warrior-Protection',}; local provider = {region='CN',realm='冬泉谷',name='CN',type='weekly',zone=42,date='2025-04-14',data={Am='Ame:AwABCAEABAoAAA==.',Di='Di:AwABCAEABAoAAA==.',Eb='Ebod:AwAICFIABAoCAQAIAQgXDABcd9wCBAoAAQAIAQgXDABcd9wCBAoAAA==.Ebody:AwAHCBAABAoAAA==.',Lo='Longlongago:AwABCAEABRQAAA==.',Pl='Playerwqhvlt:AwAECAEABRQCAgAIAQh8MQBC0AsCBAoAAgAIAQh8MQBC0AsCBAoAAA==.',Re='Rexg:AwAECAQABRQAAQMAAAAICAIABRQ=.',Sd='Sdffsf:AwACCAEABAoAAA==.',Ta='Tamamdh:AwAECAYABRQEBAAEAQg5BAAukZ4ABRQABAACAQg5BAAqIp4ABRQABQADAQjXHAAtfZIABRQABgABAQhcHQAKajEABRQAAQMAAAAGCAIABRQ=.',Vm='Vmware:AwAFCAcABAoAAA==.',['�']='一朵懒女子:AwAGCAYABAoAAA==.七宗罪丶傲慢:AwABCAEABAoAAA==.七彩街老司机:AwADCAMABAoAAA==.不了不了:AwABCAEABAoAAA==.丨兽灬兽丨:AwAFCAUABAoAAA==.丰川祥子:AwAFCAUABRQDBwAFAQiwAwAYDrgABRQABwAEAQiwAwAcq7gABRQACAABAQhZFQAF9VAABRQAAA==.',['�']='云芗:AwAECAQABAoAAA==.亖亖:AwAHCAcABAoAAA==.人称花哥:AwABCAEABAoAAA==.',['�']='今田美樱:AwAGCAcABAoAAA==.',['�']='传说中的小猎:AwACCAcABRQCCQACAQg6EAA0zpQABRQACQACAQg6EAA0zpQABRQAAA==.',['�']='依然瑷:AwABCAEABAoAAA==.',['�']='初如晴天丶:AwABCAEABAoAAA==.',['�']='双子星嚤羯:AwAECAQABAoAAA==.',['�']='吃货小豆泥:AwAECAQABAoAAA==.君莫邪:AwAECAQABRQAAA==.',['�']='嘦巭深:AwAECAQABAoAAA==.',['�']='四季茶:AwADCAMABRQDCAAIAQgRFAA8EfgBBAoACAAIAQgRFAA8EfgBBAoABwAIAQjYCQAtULwBBAoAAA==.',['�']='圣光属于我们:AwAGCAYABAoAAA==.',['�']='增强增强萨:AwAECAgABRQCCgAEAQj5BgAvs9gABRQACgAEAQj5BgAvs9gABRQAAA==.',['�']='奶不起:AwAICAEABAoAAA==.好运气伴我:AwABCAEABAoAAA==.',['�']='妈妈:AwADCAoABRQDAgADAQiFBwBYBygBBRQAAgADAQiFBwBYBygBBRQACQABAQjyFwAoC0sABRQAAA==.',['�']='季伯初:AwAICAgABAoAAA==.',['�']='小步舞曲:AwAHCAcABAoAAA==.小泽:AwAECAQABAoAAA==.小泽又牧风:AwAECAQABRQAAA==.小疯狂:AwAFCAUABAoAAA==.',['�']='巅峰丿修罗灬:AwAHCAkABAoAAA==.',['�']='平凡的河狸:AwADCAMABAoAAA==.',['�']='徐浩吃嘛果:AwAECAcABRQCBQAEAQgFBABa5jQBBRQABQAEAQgFBABa5jQBBRQAAA==.德资:AwABCAEABAoAAA==.',['�']='我们的时代:AwACCAIABAoAAA==.我是吓大的:AwAECAgABRQCBQAEAQiICwA2lfkABRQABQAEAQiICwA2lfkABRQAAA==.',['�']='挑逗的嘴角:AwABCAEABAoAAA==.',['�']='撒旦之吻:AwACCAIABAoAAA==.',['�']='断角的吃西瓜:AwAECAQABAoAAA==.新一代东东:AwAICA8ABAoAAA==.',['�']='暴力狂:AwAECAUABAoAAA==.暴躁马铃薯:AwAECAUABAoAAA==.',['�']='曜竹:AwAICBkABAoCAgAIAQj5RwAskrEBBAoAAgAIAQj5RwAskrEBBAoAAA==.',['�']='月小半:AwAICAgABAoAAA==.朕羊你勿罪:AwAECAQABAoAAA==.',['�']='杨丶超越:AwACCAIABRQAAA==.',['�']='橙色的牛氓:AwAECAIABRQAAA==.',['�']='武神千千:AwABCAEABAoAAA==.',['�']='毛头小术:AwACCAMABRQAAA==.',['�']='清潼:AwAECAQABAoAAA==.渊博的蜗牛:AwAICAgABAoAAA==.渴死的鱼:AwABCAEABAoAAA==.',['�']='烟花易冷:AwAECAUABAoAAA==.',['�']='狼叔丿:AwAFCAkABAoAAA==.',['�']='猛先圣:AwAECAQABRQAAA==.',['�']='王力量:AwAECAMABAoAAA==.',['�']='瑶光丶:AwAECAQABAoAAA==.',['�']='當夏末無蝉:AwAICBAABAoAAA==.',['�']='白首如新:AwAHCAUABAoAAA==.',['�']='秋天深蓝:AwADCAMABAoAAA==.',['�']='童童:AwABCAEABAoAAA==.',['�']='简单如初:AwADCAcABRQCCwADAQilEQAZhcYABRQACwADAQilEQAZhcYABRQAAA==.',['�']='绝亦:AwADCAMABRQAAA==.',['�']='职业打假人:AwAECAgABRQCAQAEAQhcDQBZIAoBBRQAAQAEAQhcDQBZIAoBBRQAAA==.',['�']='芤曖:AwAHCAgABAoAAA==.花椒:AwAECAQABRQAAA==.花椰菜之心:AwAICAIABAoAAA==.花落:AwAECAQABRQAAA==.',['�']='苏格拉底:AwAHCAkABAoAAQwAUhwHCAwABRQ=.英俊:AwAECAUABAoAAA==.',['�']='茉崔蒂:AwABCAEABRQAAQUAWuYECAcABRQ=.茜公舉殿下丶:AwAECAQABAoAAA==.茨木华扇:AwADCAMABAoAAA==.',['�']='荒野镖猎:AwAHCAcABAoAAA==.',['�']='莉亚迪桑:AwAHCAoABAoAAA==.',['�']='虚空猎杀者:AwACCAIABAoAAA==.',['�']='蚩尤大帝:AwADCAMABAoAAA==.',['�']='诡谲:AwAFCAUABAoAAA==.',['�']='调皮:AwAICBAABAoAAA==.',['�']='超威老炮:AwAECAQABAoAAQMAAAAECAQABAo=.超级袄景王:AwAECAQABRQAAA==.',['�']='那个龙人:AwACCAMABRQDCgAIAQi4BwBXy7kCBAoACgAIAQi4BwBXy7kCBAoADAACAQhogQAkEGEABAoAAA==.邪恶之霸:AwACCAYABRQCDQACAQi8DQAsDZsABRQADQACAQi8DQAsDZsABRQAAA==.',['�']='醉梦无痕:AwAECAQABRQAAA==.醉醉:AwAECAQABAoAAA==.',['�']='鋼鉄韵律:AwAICBkABAoCDgAIAQjqFgAeLyYBBAoADgAIAQjqFgAeLyYBBAoAAA==.',['�']='隋风踏青:AwAHCAYABAoAAA==.随风飘远丶:AwAGCAYABAoAAA==.',['�']='青菜要放葱:AwAFCAUABAoAAA==.',['�']='风风:AwAICA4ABAoAAA==.',['�']='馒萨:AwADCAMABAoAAA==.馬克斯彡肖:AwABCAEABAoAAA==.馬克斯彡萧:AwABCAEABAoAAA==.',['�']='魔兽排队打刀:AwAGCA0ABAoAAA==.',['�']='黑妞:AwAGCAYABAoAAA==.黑檀白榆:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end