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
 local lookup = {'Paladin-Retribution','Shaman-Restoration','Shaman-Enhancement','Priest-Discipline','Priest-Shadow','Warrior-Arms','Warrior-Protection','Unknown-Unknown','Druid-Restoration','Mage-Fire','Warlock-Destruction','Paladin-Holy','Priest-Holy','DeathKnight-Blood','Hunter-Marksmanship','DeathKnight-Unholy','Evoker-Devastation','Warrior-Fury','Hunter-BeastMastery','Warlock-Affliction','Warlock-Demonology','Evoker-Preservation',}; local provider = {region='CN',realm='芬里斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ai='Ailton:AwAICAgABAoAAA==.',An='Anberlin:AwACCAQABRQAAA==.',Ao='Aoey:AwACCAIABRQAAA==.',Ap='Apptt:AwAFCAUABAoAAA==.',Bl='Blws:AwAECAUABAoAAA==.Blxd:AwAGCA4ABAoAAA==.',Bs='Bsp:AwAICBIABAoAAA==.',Je='Jetaime:AwACCAIABRQCAQAIAQirDgBcSdMCBAoAAQAIAQirDgBcSdMCBAoAAA==.',La='Ladderfour:AwACCAIABAoAAA==.',Le='Leslie:AwAGCAYABRQCAgAGAQjtAAAmRZQBBRQAAgAGAQjtAAAmRZQBBRQAAQMAM3YICAkABRQ=.',Re='Redback:AwAECAQABRQAAA==.',St='Stirke:AwAGCA4ABAoAAA==.',['�']='三羧酸循环:AwAICAkABAoAAA==.上去就一镐把:AwAGCAkABRQCAQAGAQhhAQAvIrcBBRQAAQAGAQhhAQAvIrcBBRQAAA==.上善丶若水:AwAECAcABRQDBAAEAQhQBABc+i8BBRQABAAEAQhQBABc+i8BBRQABQABAQhZIgAIzj8ABRQAAA==.不乛晓得:AwABCAEABAoAAA==.丨徳玛西亚:AwABCAEABRQAAA==.丨徳玛酉亚:AwACCAIABRQAAA==.中二粥:AwABCAEABAoAAA==.丶天朝战神:AwAICAgABAoAAA==.为了馒头:AwAECAQABAoAAA==.',['�']='二四年的尾巴:AwABCAEABAoAAA==.五琼浆:AwAGCAoABAoAAA==.人可擎天:AwAICAYABAoAAA==.',['�']='众淼竞技灬圣:AwAICA8ABAoAAA==.',['�']='佳期若梦丶:AwAECAQABAoAAA==.',['�']='偶尔玩:AwAICBgABAoCAQAIAQgBQwA/Cw0CBAoAAQAIAQgBQwA/Cw0CBAoAAA==.偶看好你哟:AwAICAgABAoAAA==.',['�']='六酱真香:AwAGCAcABAoAAA==.',['�']='冷混:AwACCAIABAoAAA==.冷风狂舞:AwABCAIABRQDBgAIAQj4KgAoDDMBBAoABgAGAQj4KgAx3zMBBAoABwAIAQgLIAANpdcABAoAAA==.',['�']='则瑞的帽子:AwACCAIABRQAAA==.利群:AwACCAMABRQAAA==.刹那间的闪:AwAICAsABAoAAA==.',['�']='劣小猎:AwAICAMABAoAAA==.',['�']='印象若泽:AwACCAMABRQCAgAIAQhpGgBHfhsCBAoAAgAIAQhpGgBHfhsCBAoAAA==.',['�']='叁爺灬:AwAGCAkABAoAAA==.',['�']='君莫笑:AwAGCAMABAoAAQgAAAAGCAIABRQ=.',['�']='咕咕鼓鼓:AwACCAIABRQAAA==.',['�']='哎木五和德:AwADCAYABRQCCQADAQjoBABDOQ0BBRQACQADAQjoBABDOQ0BBRQAAA==.',['�']='唏哩呼噜:AwAECAQABAoAAA==.',['�']='土曾强萨木耳:AwACCAQABRQAAA==.圣帝撒奥瑟:AwAECAIABRQAAA==.',['�']='塚灬铭记:AwABCAEABAoAAA==.',['�']='夜色丶龙幽:AwAECAQABRQAAA==.大力士:AwAECAQABRQAAA==.',['�']='奶圈:AwABCAEABAoAAA==.好湿:AwAICAgABAoAAA==.',['�']='嫖指导:AwAICAIABAoAAA==.',['�']='家有小樣:AwAFCAUABAoAAA==.',['�']='寒慕晨:AwACCAIABAoAAA==.寒樱似雪:AwAICAwABAoAAA==.',['�']='小初夏:AwACCAIABAoAAA==.小德练习生:AwAECAQABRQAAA==.小池塘:AwAGCAgABAoAAA==.',['�']='岌岌:AwABCAEABRQAAA==.',['�']='左小雪:AwAICAgABAoAAA==.',['�']='布鲁兹老爷:AwACCAIABAoAAA==.师太请放开手:AwACCAIABAoAAA==.',['�']='幽默小龙人:AwAHCAEABAoAAA==.',['�']='御箭飞龍:AwAECAIABRQAAA==.德艺雙馨:AwAECAQABRQAAA==.',['�']='心照不宣:AwAECAQABAoAAA==.必胜客:AwAECAQABAoAAA==.',['�']='想念莫离丶:AwAGCAQABRQAAQoAUhwHCAwABRQ=.',['�']='我来偷茄子的:AwACCAIABRQAAA==.',['�']='技艺精甚:AwABCAEABRQAAA==.折灵丶:AwAICAgABAoAAA==.',['�']='擦边女主播:AwAICA4ABAoAAA==.',['�']='新兵:AwACCAIABRQAAA==.方合:AwAGCAQABRQAAA==.',['�']='旺仔小葡萄:AwAECAQABRQAAQgAAAAICAIABRQ=.',['�']='晨曦之主:AwAGCBAABAoAAA==.',['�']='暮色寂然:AwAECAQABRQAAQsAQ24GCAkABRQ=.',['�']='月夕:AwAHCAkABAoAAA==.朴的桓:AwADCAMABAoAAA==.机器喵:AwAECAQABAoAAA==.',['�']='李查德:AwACCAIABAoAAA==.',['�']='柚子茶丶:AwAICAEABAoAAA==.',['�']='梅间雪无痕:AwAICAwABAoAAA==.梦若:AwACCAQABRQCDAAIAQjWGQAv3XEBBAoADAAIAQjWGQAv3XEBBAoAAQ0AP+IICAUABRQ=.',['�']='椰椰的星星:AwAECAgABRQCCwAEAQjVDwAoMtQABRQACwAEAQjVDwAoMtQABRQAAA==.',['�']='樱花树下:AwADCAMABAoAAA==.',['�']='死亡丶浮铭:AwACCAUABRQCDgACAQh9GAAYH2YABRQADgACAQh9GAAYH2YABRQAAA==.',['�']='残酷灏神纲领:AwAICAgABAoAAA==.',['�']='永生的发丝:AwAECAQABRQAAA==.永生的大肥鸡:AwAECAQABRQAAA==.',['�']='江湖百晓生:AwAECAoABRQCDwAEAQhEDAAqG9IABRQADwAEAQhEDAAqG9IABRQAAA==.',['�']='沐小雅丶:AwACCAIABRQAAA==.',['�']='浮生丿若梦:AwAHCAcABAoAAA==.',['�']='清风丶霁月:AwAICAgABAoAAA==.温暖的茜:AwABCAEABRQAAA==.渲染街角:AwACCAMABRQAAA==.',['�']='潇潇:AwAICAgABAoAAA==.',['�']='灰烬丶黄泉:AwADCAMABAoAAA==.灰烬戼天堂:AwAICAgABAoAAA==.灰烬老九:AwAICAgABAoAAA==.灰烬老铁柱:AwADCAMABAoAAA==.灰烬觉醒丶:AwAICAYABAoAAA==.',['�']='烈焰灼心:AwAGCAcABAoAAA==.烈风之殇:AwABCAEABAoAAQgAAAAECAQABRQ=.烛龙九阴:AwAECAUABAoAAA==.',['�']='爱美丽斯丶:AwAICAgABAoAAA==.爸爸:AwAICAgABAoAAA==.',['�']='牛太白:AwAECAQABRQAAA==.牛爷爷:AwAECAUABAoAAA==.牛里牛气:AwAECAgABRQCAQAEAQj0EQBDYwABBRQAAQAEAQj0EQBDYwABBRQAAA==.',['�']='狼王:AwAGCAYABAoAAA==.',['�']='猛牛丶:AwACCAIABRQAAA==.',['�']='獄火重生:AwAECAgABAoAAA==.',['�']='班策达根:AwAFCAcABAoAAA==.',['�']='白嫩滑弹:AwAECAYABRQCEAAEAQiMDQA2FuoABRQAEAAEAQiMDQA2FuoABRQAAA==.白嫩滑弹翘挺:AwAICBAABAoAAA==.',['�']='的确很难搞:AwAFCAUABAoAAA==.',['�']='盒子哥的骑士:AwABCAEABRQAAREAJhIDCAkABRQ=.盗跖:AwAHCA0ABAoAAA==.',['�']='瞄准:AwAECAQABRQAAQgAAAAGCAMABRQ=.瞬间的永恒:AwAICCAABAoCEAAIAQhTHQBPETQCBAoAEAAIAQhTHQBPETQCBAoAAA==.',['�']='磷纹:AwACCAIABRQAAA==.',['�']='純情的小豬:AwAICAgABAoAAA==.索尔迦雷欧:AwAECAYABAoAAA==.',['�']='红烧牛腩:AwADCAsABRQDEgADAQipDQA3ePcABRQAEgADAQipDQAvUvcABRQABgABAQgLEQBNhF8ABRQAAA==.纣王:AwAECAgABRQDDwAEAQiiDAAqIc8ABRQADwAEAQiiDAAlm88ABRQAEwAEAQhcHgAXKbsABRQAAA==.',['�']='缺耐者:AwAECAQABRQAAA==.',['�']='肉豆豆:AwAECAQABRQAAA==.',['�']='花若云裳:AwAICAgABAoAAA==.',['�']='苹果大兄弟:AwAGCAwABAoAAA==.',['�']='茉莉味小飞象:AwAHCAkABAoAAA==.',['�']='萨满之王:AwAECAQABRQAAA==.',['�']='葛斑玛:AwACCAYABRQCEQACAQj4DwBF3KkABRQAEQACAQj4DwBF3KkABRQAAA==.',['�']='蔷薇乱舞:AwAHCAkABAoAAA==.',['�']='虬髯天佑:AwAECAIABRQAAA==.',['�']='蜜汁山芋:AwAICAwABAoAAA==.',['�']='衤果奔是种美:AwAFCAwABAoAAA==.',['�']='语光无敌啦:AwAICAgABAoAAA==.',['�']='豆哥:AwAECAEABRQAAA==.',['�']='貝殼里的海:AwAGCAgABRQEFAAGAQj1AgBSKhkBBRQAFAADAQj1AgBYgxkBBRQACwAEAQgdBwBLGhABBRQAFQABAQjJFwAAAAAABRQAAA==.',['�']='辣是我亮哥哎:AwAICAgABAoAAA==.辰梦夜:AwAECAQABRQAAA==.',['�']='追月无痕:AwAECAQABRQAAA==.',['�']='逆蝶重生:AwAGCAIABRQCFgACAQiqBgAev3QABRQAFgACAQiqBgAev3QABRQAAA==.',['�']='道无:AwAECAQABRQAAA==.',['�']='重返一百六:AwACCAIABAoAAA==.',['�']='鉴茶师:AwAGCAgABRQCCgAEAQjYFQA6nuoABRQACgAEAQjYFQA6nuoABRQAAA==.',['�']='锅里有饭:AwAECAEABAoAAA==.',['�']='阿爾托莉雅:AwAICAgABAoAAA==.',['�']='随性:AwAGCAcABAoAAA==.',['�']='零九年的贰猎:AwAHCAEABAoAAA==.雾雨之刃:AwAECAQABRQAAA==.',['�']='霸气全漏:AwAECAQABRQAAA==.',['�']='风城烟雨:AwAECAcABRQCCgAEAQg8EwBBMPIABRQACgAEAQg8EwBBMPIABRQAAA==.风干的微笑:AwAICA4ABAoAAA==.',['�']='骑小奇:AwAHCAYABAoAAA==.',['�']='鲫鱼:AwAECAIABRQAAA==.',['�']='鸟牛:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end