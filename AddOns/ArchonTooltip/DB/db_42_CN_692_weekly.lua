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
 local lookup = {'Warrior-Fury','Rogue-Assassination','Unknown-Unknown','Monk-Mistweaver','Paladin-Retribution','Warlock-Destruction','Druid-Restoration','Paladin-Protection','Hunter-Marksmanship','DemonHunter-Havoc','Shaman-Restoration','Shaman-Elemental','Mage-Fire','Mage-Frost',}; local provider = {region='CN',realm='提尔之手',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Alexanderamy:AwABCAEABAoAAA==.',Ba='Baga:AwACCAQABRQCAQAIAQjHEwBHKlMCBAoAAQAIAQjHEwBHKlMCBAoAAA==.',Di='Disappeared:AwAGCAkABAoAAA==.',Do='Doubble:AwAICBAABAoAAA==.',Ki='Kinfe:AwAECAEABAoAAA==.Kinfezs:AwAGCAsABAoAAA==.',Li='Liadrinian:AwAGCAcABAoAAA==.',Oo='Ooningoo:AwAICA0ABAoAAA==.',Op='Opai:AwAGCAQABRQAAA==.',Sc='Scarletwitch:AwAGCAUABAoAAA==.',Su='Sunriver:AwADCAMABAoAAA==.',['�']='七夜狼君:AwAICA4ABAoAAA==.丨素还真丨:AwAICAgABAoAAA==.丶滔咪:AwABCAEABRQAAA==.主力治疗:AwAICAgABAoAAA==.丿小灬橘子:AwAGCAYABAoAAA==.',['�']='五晨寺炎掌门:AwAGCAYABAoAAA==.',['�']='伊什塔尔:AwACCAIABAoAAA==.',['�']='余生:AwABCAEABAoAAA==.佛罗伦娜:AwAHCBAABAoAAA==.',['�']='假装高手:AwAICAgABAoAAA==.',['�']='冰冷之海:AwAFCAUABAoAAA==.冷淡的英雄:AwABCAEABRQAAA==.',['�']='南昌出口空运:AwAECAQABRQAAA==.',['�']='后门口扛把子:AwADCAMABAoAAA==.',['�']='咖喱给给:AwAGCAQABRQCAgAEAQiBBABBygwBBRQAAgAEAQiBBABBygwBBRQAAA==.咣咣就是两拳:AwAECAQABRQAAQMAAAAGCAQABRQ=.',['�']='嚣张不解释:AwAHCAgABAoAAA==.',['�']='四层吉士汉堡:AwAGCAoABAoAAA==.',['�']='圣舞:AwAGCAoABAoAAA==.',['�']='坎谱拉:AwAICAsABAoAAA==.',['�']='大尾巴鱼:AwAECAQABRQAAA==.大滋水枪:AwAECAQABRQAAA==.',['�']='如是自来也:AwAFCAYABAoAAA==.',['�']='实在是小:AwAFCAUABAoAAA==.',['�']='小倩乖:AwAICA0ABAoAAA==.小呆守护者:AwAECAQABRQAAA==.小小芳芳:AwACCAQABRQCBAAIAQjcBQBYdL4CBAoABAAIAQjcBQBYdL4CBAoAAA==.小汤圆丶:AwAGCAYABAoAAA==.小滋水枪:AwAECAQABAoAAA==.小花非花:AwAICAYABAoAAA==.小角色的我:AwAICAgABAoAAQMAAAAGCAQABRQ=.',['�']='布鲁欧曼德:AwADCAMABAoAAA==.',['�']='幽雅:AwABCAEABRQAAA==.',['�']='弑丿雨落星辰:AwAICAgABAoAAA==.',['�']='归灬墟:AwAECAQABRQAAA==.',['�']='怀瑾握瑜:AwAFCAsABAoAAA==.',['�']='我来组成头部:AwAECAgABRQCBQAEAQiBGAAxMOMABRQABQAEAQiBGAAxMOMABRQAAA==.我爱赤石:AwAECAQABRQAAA==.',['�']='普通牛:AwABCAEABAoAAQMAAAAGCAYABAo=.',['�']='月亮与六便士:AwAECAQABAoAAA==.',['�']='枸杞:AwABCAEABRQAAA==.',['�']='正义的伙伴:AwADCAMABAoAAA==.',['�']='法涅斯:AwACCAIABRQAAA==.',['�']='浮士德二夫人:AwABCAEABRQAAA==.',['�']='消单乐:AwAICAYABAoAAQYAXx8ICAUABRQ=.',['�']='深蓝苦茶子:AwADCAMABAoAAA==.',['�']='清楼探花:AwAICAgABAoAAA==.清风:AwAECAgABAoAAA==.温格萝琳:AwAGCAYABAoAAA==.',['�']='灵荫:AwAECAQABRQCBwAIAQjgBgBVo5UCBAoABwAIAQjgBgBVo5UCBAoAAA==.',['�']='爱小潘:AwAECAQABRQAAA==.',['�']='牛牛犇犇:AwAECAQABRQCAQAIAQjRBgBexcoCBAoAAQAIAQjRBgBexcoCBAoAAA==.特兰奇亚:AwAICBsABAoCCAAIAQi5DABEtRQCBAoACAAIAQi5DABEtRQCBAoAAA==.',['�']='瓦塔西:AwAICAgABAoAAA==.',['�']='盾御天下:AwABCAEABAoAAA==.',['�']='瞬间爆表:AwAHCAoABAoAAA==.',['�']='知心波波丶:AwAECAcABRQCCQAEAQiSAQBc5jIBBRQACQAEAQiSAQBc5jIBBRQAAA==.',['�']='神猎手:AwACCAQABRQCCgAHAQhGRgAtmmIBBAoACgAHAQhGRgAtmmIBBAoAAA==.',['�']='粉色苦茶子:AwADCAUABRQCBQADAQigEgBCfvcABRQABQADAQigEgBCfvcABRQAAA==.',['�']='糖玉叉烧丶:AwAGCAMABRQDCwADAQimHwAkuW8ABRQACwACAQimHwAGM28ABRQADAABAQg4EgA+eE0ABRQAAA==.',['�']='紫蝴蝶:AwAHCAcABAoAAA==.',['�']='红尘客栈:AwADCAYABAoAAA==.',['�']='绝不意气用事:AwAECAQABRQAAQ0APU4ICAkABRQ=.绝对核心:AwACCAUABRQDDQACAQidHABSh8MABRQADQACAQidHABSh8MABRQADgACAQhYEQAhsWgABRQAAA==.',['�']='老父亲:AwAGCAYABAoAAA==.',['�']='脚丫曾被亵渎:AwAFCAkABAoAAA==.',['�']='艾瑞达:AwADCAMABAoAAA==.',['�']='花香小叶:AwAECAQABAoAAQMAAAACCAIABRQ=.',['�']='苍天已死:AwAHCAcABAoAAA==.',['�']='萧晓筱:AwABCAEABAoAAA==.',['�']='薄雾:AwACCAIABAoAAQMAAAAGCAYABAo=.薛定谔的厨子:AwAGCBIABRQCBAAGAQhyAABLAAUCBRQABAAGAQhyAABLAAUCBRQAAA==.',['�']='蜜桃雪糕:AwAICAgABAoAAA==.',['�']='貓吢詠恆:AwAICAgABAoAAA==.',['�']='起名小天才:AwAECAQABRQAAA==.',['�']='部落大表哥:AwAFCAUABAoAAA==.',['�']='铁锤骑士:AwACCAIABAoAAA==.',['�']='锅巴的义祖父:AwAICAgABAoAAA==.',['�']='阿巴瑟瑟:AwAFCA0ABAoAAA==.',['�']='零度幻想:AwAFCAgABAoAAA==.',['�']='風不停息:AwAECAIABRQAAA==.',['�']='鬼神轨道炮:AwAHCAgABAoAAA==.',['�']='鸭头肉:AwADCAMABAoAAA==.',['�']='麦姬珂:AwAFCAEABAoAAA==.',['�']='黑姬结灯丶:AwAECAQABRQAAA==.默默不玩:AwAFCAUABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end