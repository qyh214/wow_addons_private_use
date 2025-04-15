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
 local lookup = {'Priest-Shadow','Warrior-Arms','Mage-Frost','Mage-Fire','Rogue-Assassination','Mage-Arcane','DeathKnight-Unholy','Paladin-Retribution','Warrior-Fury','DeathKnight-Blood','Priest-Holy','Priest-Discipline','Druid-Restoration','Warlock-Destruction','Warlock-Demonology','Evoker-Devastation','Paladin-Protection','Unknown-Unknown','Warrior-Protection',}; local provider = {region='CN',realm='羽月',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ad='Addoil:AwABCAEABRQAAA==.',Ai='Aisha:AwAECAQABRQAAA==.',Aq='Aqua:AwAECAYABRQCAQAEAQhdEAAgb8UABRQAAQAEAQhdEAAgb8UABRQAAQIAS5IGCBAABRQ=.',Cr='Crazyseven:AwAFCAcABAoAAA==.',El='Ella:AwADCAMABAoAAA==.',Gl='Glamdring:AwAECAwABRQDAwAEAQjqBQBDk/IABRQABAAEAQjtEgBDk/MABRQAAwAEAQjqBQA9SvIABRQAAA==.',Ma='Mareeta:AwAECAYABRQCBQAEAQj+BwAptOoABRQABQAEAQj+BwAptOoABRQAAA==.',Mi='Miia:AwAFCAUABAoAAA==.',Pr='Prometheus:AwACCAUABRQDBAACAQgaKwAZ1YQABRQABAACAQgaKwAZ1YQABRQABgABAQjgAwAZFzsABRQAAA==.',Se='Serein:AwACCAQABRQAAA==.',St='Steven:AwAICAgABAoAAA==.',['�']='三指弹天:AwAECAQABRQAAA==.下狼:AwABCAEABAoAAA==.不可撼动:AwAFCAoABAoAAA==.丶乐无忧丶:AwAICAMABAoAAA==.为了成就三:AwAECAgABRQCBwAEAQiMBgBJ6RgBBRQABwAEAQiMBgBJ6RgBBRQAAA==.',['�']='也许没有也许:AwAICA4ABAoAAA==.',['�']='伊瑞尔丶:AwAICA0ABAoAAA==.',['�']='你你我我他他:AwAECAcABAoAAA==.',['�']='依能:AwAICCIABAoCCAAIAQhiDABc8t8CBAoACAAIAQhiDABc8t8CBAoAAA==.',['�']='冰鲜柠檬水:AwACCAEABAoAAA==.',['�']='凉拌见手青:AwADCAMABAoAAA==.',['�']='剣聖:AwAGCAYABAoAAQkAYnwGCAIABRQ=.',['�']='千帆舞影:AwAECAEABAoAAA==.千早爱音:AwADCAQABAoAAA==.南京龙:AwAHCAcABAoAAQoAL/MICB8ABAo=.南河:AwADCAIABAoAAA==.卡米奇亚:AwAECAIABRQAAA==.',['�']='双手插兜儿:AwAECAoABRQDBAAEAQhmCgBbkCIBBRQABAAEAQhmCgBVMiIBBRQAAwACAQiJCwBaZaYABRQAAQQATGUGCAoABRQ=.',['�']='吉村车钛:AwABCAEABAoAAA==.',['�']='哔哩哔哩丶战:AwAHCAcABAoAAA==.',['�']='嘟小牧:AwAGCAoABRQDCwAGAQhhBQA/q/4ABRQACwAEAQhhBQA7qv4ABRQADAACAAgAAABFrgAABRQAAA==.',['�']='四季发财:AwACCAIABRQAAA==.',['�']='圣光永不灭:AwAHCAsABAoAAA==.',['�']='壹頁书:AwAECAwABRQCAwAEAQiJAwBLaREBBRQAAwAEAQiJAwBLaREBBRQAAA==.',['�']='夜之於:AwAFCAoABAoAAQgAXlYICBwABAo=.夜之语:AwAICBwABAoCCAAIAQgPCgBeVuoCBAoACAAIAQgPCgBeVuoCBAoAAA==.大主教伊瑞尔:AwAICAgABAoAAA==.大雁南飞:AwAGCAYABAoAAQoAL/MICB8ABAo=.大鷲伊迪丝:AwACCAYABRQCDQACAQj3EQAp5H8ABRQADQACAQj3EQAp5H8ABRQAAA==.夹克:AwAFCAUABAoAAA==.',['�']='奶白色雪子:AwACCAIABAoAAA==.',['�']='妇科手术大夫:AwABCAEABRQDDgAIAQjfFgBMvC0CBAoADgAIAQjfFgBKry0CBAoADwADAQjpQABHRqcABAoAAA==.',['�']='寂寞灬宿命:AwAHCAwABAoAAA==.',['�']='小加诺:AwAGCAgABAoAAA==.小爱心:AwACCAIABAoAAA==.小牧點儿:AwAECAQABRQAAA==.小舒不想输:AwAHCAsABAoAAA==.小钢炮:AwACCAQABAoAAA==.小龙人高达:AwAGCAEABRQCEAABAQhNHAAHXjEABRQAEAABAQhNHAAHXjEABRQAAA==.',['�']='已经摆烂了:AwAICAgABAoAAA==.',['�']='帮你打官司:AwAECAQABRQAAA==.',['�']='幕后凋零:AwABCAEABRQAAA==.幺儿幺幺:AwABCAEABRQAAA==.幻想的可乐:AwAECAgABRQDAgAEAQgzAwBP+hYBBRQAAgAEAQgzAwBKKhYBBRQACQAEAQg/DQA1VfkABRQAAA==.',['�']='张四十一岁:AwAGCAoABRQCCQAGAQiNAAAwoMkBBRQACQAGAQiNAAAwoMkBBRQAAA==.',['�']='惡魔小寶:AwAICAQABAoAAA==.',['�']='我就是小丑:AwAGCAIABRQDBwAIAQgiEwBUrXYCBAoABwAIAQgiEwBQ63YCBAoACgAFAQhJOgAzbLgABAoAAA==.',['�']='折戟沉沙:AwABCAEABRQAAA==.',['�']='时间:AwAHCBgABAoCEQAHAQiLLQATkcsABAoAEQAHAQiLLQATkcsABAoAAA==.',['�']='晓丶点点:AwAHCAsABAoAAA==.晓月圜舞曲:AwAICAgABAoAAA==.',['�']='杀气十足:AwAICBAABAoAAA==.杀气的骑士:AwAICAkABAoAAA==.来日方长:AwACCAQABRQAAA==.',['�']='枼月紗蘭:AwABCAEABAoAAA==.',['�']='歧途悲歌:AwABCAIABRQCDwAIAQhrAgBWi7cCBAoADwAIAQhrAgBWi7cCBAoAAA==.',['�']='渴望长高:AwAGCAsABAoAAA==.',['�']='炽舞之翼:AwABCAEABRQAAA==.',['�']='無法無天:AwAICAgABAoAARAANPkGCA4ABRQ=.',['�']='爱情小坦克:AwAECAQABRQAAA==.',['�']='版本之子:AwAGCAsABAoAAA==.牛里牛气:AwAECAcABAoAAA==.特洛伊悍马:AwABCAEABAoAAA==.',['�']='狂乱中年母鸡:AwAFCAIABAoAAA==.',['�']='猎萌新:AwADCAMABAoAAA==.猫猫九:AwAICAgABAoAAA==.',['�']='生生:AwAGCAYABAoAARIAAAACCAIABRQ=.',['�']='神圣的伪君子:AwAICAsABAoAAA==.',['�']='笑嘻嘻:AwAGCAsABAoAAA==.',['�']='等不到天亮:AwACCAQABRQAAA==.',['�']='红鸳:AwAGCAYABAoAAA==.纳兰若曦:AwAECAQABRQAAA==.',['�']='缪雪:AwACCAUABRQCBwACAQiOGQApbZkABRQABwACAQiOGQApbZkABRQAAA==.',['�']='苏苏:AwADCAMABAoAAA==.',['�']='莎莎沙沙:AwAICAYABAoAAA==.',['�']='蜜儿:AwACCAIABAoAAA==.蜜拉底儿:AwAFCAEABAoAAA==.',['�']='诸神之城:AwAECAQABRQAAA==.',['�']='豌豆芽:AwAFCAUABAoAARIAAAAICBIABAo=.',['�']='赏心悦牧:AwAECAQABRQAAA==.走来走去:AwAECAQABRQAARIAAAAICAQABRQ=.',['�']='达利园:AwAECAQABRQAAA==.',['�']='逍遥无涯:AwAGCAYABAoAAA==.',['�']='遇见八月:AwAICB8ABAoCCgAIAQiFHQAv830BBAoACgAIAQiFHQAv830BBAoAAA==.',['�']='钱前乾:AwABCAEABAoAAA==.',['�']='阿瓦达啃大瓜:AwAHCAIABAoAAA==.',['�']='霸月魅魂:AwAECAQABAoAAA==.',['�']='顾北辰:AwABCAIABRQEAgAIAQgRGQA9LskBBAoAAgAHAQgRGQBChskBBAoACQAEAQhZcQAZcXkABAoAEwACAQglNwAbkUUABAoAAA==.',['�']='香菇炖鸡煲:AwAECAQABRQAAA==.',['�']='骑蜗牛上天:AwAECAQABRQCCAAIAQidFABa+7kCBAoACAAIAQidFABa+7kCBAoAAA==.',['�']='黄风大圣:AwACCAIABAoAAA==.',['�']='齐道临:AwAICB8ABAoCAwAIAQhuGQBFxBsCBAoAAwAIAQhuGQBFxBsCBAoAAA==.',['�']='龙女打野:AwAICAgABAoAAA==.龙晨燚:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end