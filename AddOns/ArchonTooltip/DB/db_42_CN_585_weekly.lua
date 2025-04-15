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
 local lookup = {'Paladin-Retribution','Paladin-Holy','Priest-Discipline','Unknown-Unknown','Shaman-Enhancement','Shaman-Restoration','Priest-Holy','DeathKnight-Unholy','DeathKnight-Blood','Rogue-Outlaw','DeathKnight-Frost','Mage-Frost','Monk-Windwalker','Warlock-Destruction','Mage-Fire','Monk-Brewmaster','Monk-Mistweaver','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Shaman-Elemental','Druid-Guardian','Evoker-Devastation','Evoker-Preservation',}; local provider = {region='CN',realm='凯尔萨斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ac='Acane:AwADCAkABRQDAQADAQhzDgA93wYBBRQAAQADAQhzDgA93wYBBRQAAgABAQjvDwA9EUYABRQAAA==.',An='Angelcat:AwAECAcABAoAAA==.',Ar='Archangel:AwACCAMABRQAAA==.',Ch='Christianus:AwAGCAkABRQCAwAGAQi+AQAVv2oBBRQAAwAGAQi+AQAVv2oBBRQAAA==.',Da='Darkkratos:AwAGCAYABAoAAA==.',Di='Divinecomedy:AwAICBAABAoAAQQAAAAGCAQABRQ=.',Do='Doufu:AwABCAIABRQDBQAIAQiAIAA76aMBBAoABQAHAQiAIAA7R6MBBAoABgACAQhWqQAINy4ABAoAAA==.',Ed='Eden:AwACCAgABRQDBwACAQjeDABE+qYABRQABwACAQjeDABE+qYABRQAAwABAQj7IQALRzIABRQAAA==.',Et='Eternalfire:AwAECAQABAoAAA==.Eternalstar:AwAGCAYABAoAAA==.',Li='Lightcow:AwAECAQABAoAAA==.',Mo='Monicacmm:AwACCAIABAoAAA==.',Pa='Palatinus:AwAECAQABRQAAA==.',Se='Sebastian:AwACCAIABRQAAA==.',Sk='Skyla:AwADCAsABRQCBgADAQipCABF0PoABRQABgADAQipCABF0PoABRQAAA==.',So='Solomid:AwAGCBgABAoCCAAGAQj4SwA4Zk0BBAoACAAGAQj4SwA4Zk0BBAoAAA==.',St='Stiferz:AwAGCAYABAoAAA==.',Wi='Wilburunlce:AwAGCBEABAoAAA==.',['�']='一剑倾橙:AwAICA4ABAoAAA==.三千:AwACCAIABAoAAA==.三千圣焰:AwAICAgABAoAAA==.三点三啦喂:AwABCAEABAoAAA==.不羁灬清春:AwAECAQABAoAAA==.丨微醺丨:AwAECAQABAoAAA==.临风载兮:AwAICA8ABAoAAA==.',['�']='九阴埋:AwADCAgABRQDCQADAQgaDgAnDKgABRQACQADAQgaDgAjp6gABRQACAACAQhoFgAx4pwABRQAAA==.',['�']='二水:AwAGCA4ABAoAAA==.亨德列克:AwAGCAcABAoAAA==.',['�']='以狼之名:AwAGCAoABAoAAA==.',['�']='伊鲁鲁德:AwAICAEABAoAAA==.',['�']='低调羊肉串:AwAECAQABRQAAA==.何物为真:AwABCAEABRQCCgAIAQhGBABBuSECBAoACgAIAQhGBABBuSECBAoAAA==.何静恩:AwAGCAQABRQAAA==.',['�']='保留至今:AwAECAQABRQAAA==.',['�']='冥界猎魂:AwACCAQABRQAAA==.冰冰丶神圣:AwAICA4ABAoAAA==.',['�']='凶残的大白兔:AwAICAgABAoAAA==.',['�']='北斗神犬:AwAHCA4ABAoAAA==.',['�']='千叶浅草:AwAGCAkABAoAAA==.千早爱音:AwAICA0ABAoAAA==.南鸢北笙:AwAICBYABAoDCAAIAQiIRQAzSmYBBAoACAAIAQiIRQAkkGYBBAoACwAFAQhsGgA3RNMABAoAAA==.',['�']='原来都是夢:AwAGCAYABAoAAA==.',['�']='叫我挘人:AwADCAMABAoAAA==.叶落清风丶:AwACCAIABRQAAA==.',['�']='吉侒娜:AwAICBcABAoCDAAIAQi1HwA7H+kBBAoADAAIAQi1HwA7H+kBBAoAAA==.吗喽:AwAGCAYABAoAAA==.',['�']='哟呵:AwAECAQABAoAAA==.',['�']='唯闻玉磬依旧:AwADCAMABAoAAQ0ALecICBYABAo=.',['�']='埃鲁妮恩:AwACCAIABAoAAA==.',['�']='夏饭团:AwACCAIABAoAAA==.大领主:AwAICAgABAoAAA==.天魂葬爱:AwADCAMABAoAAA==.',['�']='小猎的圣骑:AwAECAQABAoAAA==.',['�']='巴列:AwACCAEABAoAAA==.',['�']='帝璐:AwADCAcABAoAAA==.',['�']='幸运鹅:AwAECAQABAoAAA==.',['�']='成分复杂:AwAGCAQABRQCDgAIAQiDAQBevP0CBAoADgAIAQiDAQBevP0CBAoAAQ4ATegICAYABRQ=.我有无敌:AwAGCAoABAoAAA==.',['�']='斯吉亚娜:AwAICA4ABAoAAA==.',['�']='无聊的薯条:AwAECAQABRQAAA==.',['�']='春牯咕:AwADCAMABAoAAA==.春风如故人:AwAICAgABAoAAA==.',['�']='普琳:AwADCAMABAoAAA==.',['�']='望月寻梦:AwAECAgABAoAAA==.朵洛希海娅特:AwAFCAIABRQAAA==.',['�']='李春宇:AwAFCAYABAoAAA==.杭州小伙:AwAECAQABAoAAA==.',['�']='格温德林:AwAICAwABAoAAA==.',['�']='梦回吹角连营:AwADCAMABAoAAA==.',['�']='河乌宝宝:AwAECAQABRQAAA==.',['�']='法你老味:AwAICBQABAoCDwAIAQhuNwAoAKEBBAoADwAIAQhuNwAoAKEBBAoAAA==.',['�']='洋贝溪:AwAECAcABAoAAA==.',['�']='清月如默笙:AwAICBYABAoEDQAIAQjZIQAt56YBBAoADQAIAQjZIQAt56YBBAoAEAAFAQirFwAO9JsABAoAEQAEAQjbYwA7dI8ABAoAAA==.',['�']='灵逸:AwAECAQABRQAAA==.',['�']='烈风小睡神:AwABCAEABRQAAA==.',['�']='爱丘雷儿:AwAECAUABAoAAA==.爱的猪头:AwACCAIABRQDEgAIAQh/EQA3COQBBAoAEgAIAQh/EQA3COQBBAoAEwAGAQgSJAAMi9kABAoAAA==.',['�']='狂猎:AwACCAMABRQAAA==.狼铛:AwABCAQABRQCCgABAQg8BQAZ7kIABRQACgABAQg8BQAZ7kIABRQAAQoAI0gDCAkABRQ=.',['�']='珂儿:AwAICAgABAoAAA==.珏影:AwAGCAwABAoAAA==.',['�']='白露为晞:AwAGCAQABRQAAA==.',['�']='看热闹的小伙:AwAFCAEABAoAAA==.',['�']='神明不负我丶:AwAFCAgABAoAAA==.神灵之怒:AwABCAEABRQAAA==.',['�']='红色小萌龙:AwAICBMABAoAAA==.纳米激素:AwAGCAoABAoAAA==.',['�']='老撕鸡小护士:AwAHCAcABAoAAQQAAAAICAYABAo=.老撕鸡小龙人:AwAGCAYABAoAAQQAAAAICAYABAo=.老撕鸡带带我:AwAICAYABAoAAA==.',['�']='艳儿爱吃草莓:AwAECAQABRQAAA==.',['�']='花花天下:AwAICBkABAoCFAAIAQiBIgBG0RUCBAoAFAAIAQiBIgBG0RUCBAoAAA==.芳華絕代:AwADCAMABAoAAA==.',['�']='菊花一朵朵:AwAICA0ABAoAAA==.',['�']='萝莉蕾姐:AwAFCAUABAoAAA==.',['�']='蒂朵:AwAECAIABAoAAA==.蒙查查:AwAGCAoABAoAAA==.蒹葭萋萋:AwAECAQABRQAAA==.',['�']='薇塔克洛提德:AwACCAIABRQAAA==.',['�']='血舞半雲天:AwAECAQABAoAAA==.',['�']='豐川祥子:AwAECAQABRQAAA==.',['�']='迁亿:AwAICBcABAoCDgAIAQjaTgAQPAoBBAoADgAIAQjaTgAQPAoBBAoAAA==.',['�']='逆鳞:AwAGCAYABAoAAA==.進寶丶:AwACCAMABRQDBgAIAQgrNgArMIcBBAoABgAIAQgrNgArMIcBBAoAFQAIAQiNKAAjAnsBBAoAAA==.',['�']='那年明月:AwAECAQABRQAAA==.',['�']='醉裡挑燈看劍:AwABCAEABRQAAA==.',['�']='问就是子刊:AwAECAQABRQAAA==.',['�']='阡陌芊芊:AwAGCAQABRQAAQQAAAAICAQABRQ=.阿古茹:AwADCAMABAoAAA==.',['�']='随风之悠:AwACCAIABAoAAA==.',['�']='雷妮拉:AwAECAQABAoAAA==.雷泽基尔:AwAECAQABAoAAA==.',['�']='青山七海:AwACCAMABRQCBgAIAQhiRwAZCUQBBAoABgAIAQhiRwAZCUQBBAoAAA==.青春染指悲殇:AwAGCAYABAoAAA==.青柠养乐多:AwADCAMABAoAAA==.青狱公子:AwAICAIABAoAAA==.青鸿公子:AwAICBgABAoCFgAIAQgjDQAo6zkBBAoAFgAIAQgjDQAo6zkBBAoAAA==.面团零零二:AwAICAIABAoAAA==.',['�']='风声:AwACCAMABRQAAA==.风月大欧皇:AwAECAYABRQDFwAEAQj2CwAfi8sABRQAFwAEAQj2CwAfi8sABRQAGAACAQjjAwBYObAABRQAAA==.飞天大咕咕:AwAECAQABAoAAA==.',['�']='骑马打豆豆:AwABCAEABAoAAA==.',['�']='魔法少女乔杉:AwAICAgABAoAAA==.',['�']='黄泉永坠:AwAICAgABAoAAA==.黄泉葬:AwACCAIABRQCAQAIAQhVEABcEscCBAoAAQAIAQhVEABcEscCBAoAAA==.黑曜石小熊猫:AwADCAYABAoAAA==.黑白羽翼:AwAHCAkABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end