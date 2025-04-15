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
 local lookup = {'Warrior-Arms','Druid-Balance','Druid-Restoration','Priest-Shadow','Priest-Holy','Priest-Discipline','Mage-Frost','Mage-Fire','Shaman-Restoration','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Paladin-Retribution','Paladin-Holy','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','DemonHunter-Havoc','Unknown-Unknown','Monk-Brewmaster','DemonHunter-Vengeance','Monk-Windwalker','Druid-Guardian','DeathKnight-Unholy','Shaman-Enhancement','Monk-Mistweaver','Evoker-Devastation','Warrior-Fury','Paladin-Protection','Evoker-Preservation','Shaman-Elemental','Rogue-Subtlety','Rogue-Assassination',}; local provider = {region='CN',realm='寒冰皇冠',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Arteezyez:AwADCAEABAoAAA==.',As='Ashtray:AwAGCAYABAoAAA==.Asr:AwAECAgABRQCAQAEAQh+BAAybe8ABRQAAQAEAQh+BAAybe8ABRQAAA==.',Au='Audoll:AwAFCAUABAoAAA==.',Ax='Axel:AwAICAgABAoAAA==.',Ba='Barber:AwAECAQABRQAAA==.',Be='Beech:AwAECAQABRQAAA==.',Bl='Bluebubble:AwAICB4ABAoDAgAIAQhVDQBVz6YCBAoAAgAIAQhVDQBVz6YCBAoAAwAGAQgXPgAwTu8ABAoAAA==.',Ch='Chriskie:AwADCAkABRQCBAADAQjyBwA/mQIBBRQABAADAQjyBwA/mQIBBRQAAA==.',Cr='Crasl:AwAECAEABRQAAA==.',Di='Disabled:AwAECAQABRQAAA==.',Es='Esdese:AwAICAoABAoAAA==.',Ex='Excite:AwACCAIABRQEBQAIAQjwDgBO0zoCBAoABQAIAQjwDgBJIDoCBAoABAAGAQhXKQBC4GMBBAoABgACAQhFTwBHE64ABAoAAA==.',Fe='Fern:AwAECAgABRQDBQAEAQjLCwAO07MABRQABQAEAQjLCwAO07MABRQABgACAQgwGgAFuV8ABRQAAA==.',Je='Jermar:AwABCAIABRQAAA==.',Ji='Jimmiecho:AwAICBMABAoAAA==.',Ke='Keymogee:AwAHCAcABAoAAA==.',Ki='Kinjaz:AwAHCAsABAoAAA==.Kira:AwADCAMABAoAAA==.',Ku='Kuromi:AwACCAIABRQDBwAIAQjsKQBFKawBBAoABwAIAQjsKQBA9awBBAoACAAEAQiTYwAsLsMABAoAAA==.',Kw='Kwtcjxws:AwAGCAEABAoAAA==.',Ma='Manmanfatty:AwACCAIABAoAAA==.',Mo='Mozz:AwAECAIABRQAAA==.',Qy='Qyurryus:AwACCAIABAoAAA==.',Rs='Rssa:AwAECAIABRQAAA==.',Sa='Sarr:AwAGCAgABRQCCQAGAQhaAAA3R7QBBRQACQAGAQhaAAA3R7QBBRQAAA==.',Sh='Shadoww:AwAHCAcABAoAAA==.',So='Sone:AwAGCAcABRQECgAGAQiNBwAxb+AABRQACgAEAQiNBwAo0eAABRQACwACAQhBEQA+XMAABRQADAABAQjDCwAZAFYABRQAAA==.',Sr='Sra:AwAICBQABAoDDQAIAQikJgBRiWUCBAoADQAIAQikJgBRiWUCBAoADgAEAQhhKgAkkdIABAoAAA==.',St='Staywithme:AwAGCAIABRQDDwAIAQj3UAA5X5MBBAoADwAIAQj3UAA3cZMBBAoAEAADAQjNPwBCNNUABAoAAA==.Stella:AwADCAcABRQCEQADAQgWEwANrYAABRQAEQADAQgWEwANrYAABRQAAA==.',Su='Sunny:AwADCAMABAoAAA==.',Ul='Ulmtd:AwAECAMABRQCCwAIAQjTEgBPWEYCBAoACwAIAQjTEgBPWEYCBAoAAA==.',Va='Variable:AwAECAQABRQAAQEAS5IGCBAABRQ=.',Vu='Vurtne:AwAGCA4ABRQDBwAEAQg7AwBZPBABBRQACAAEAQgZCQBRoh8BBRQABwAEAQg7AwBQDhABBRQAAA==.',Ze='Zeroa:AwAECAYABRQCEgAEAQgcEAA1PewABRQAEgAEAQgcEAA1PewABRQAAA==.',Zo='Zoomklns:AwACCAMABRQECwAIAQgtIABMhe4BBAoACwAHAQgtIABMZO4BBAoADAAFAQg3HwA+2UEBBAoACgABAQjbOQBB7j8ABAoAAA==.',['�']='一个大柑果:AwACCAIABAoAAA==.七海娜娜米:AwAHCAcABAoAAA==.万达:AwAECAQABRQAAA==.不死红云:AwAGCAsABAoAAA==.为祖国献石油:AwAGCAYABAoAARMAAAAICAgABAo=.丿罐装流氓:AwADCAkABAoAAA==.',['�']='五乘四恶霸:AwABCAEABRQCFAAIAQh0BABSRUUCBAoAFAAIAQh0BABSRUUCBAoAAA==.人狠话不多:AwAGCAUABAoAAA==.',['�']='他丨姑的邪锁:AwAECAUABRQDDAAEAQihBgAd3YMABRQACwADAQjwFwAg+YwABRQADAACAQihBgAZdoMABRQAAA==.他丨爸的领主:AwAECAQABRQAAA==.代代布丁:AwACCAIABRQAAA==.',['�']='伊风:AwACCAMABAoAAA==.伽罗沙曳:AwACCAIABAoAAA==.',['�']='何事秋风:AwADCAMABRQAAA==.你们的大爷:AwEECA4ABRQCCgAEAQh+AABjs1wBBRQACgAEAQh+AABjs1wBBRQAAA==.你只会哇哇叫:AwABCAEABRQAAA==.',['�']='保安大队长:AwAECAQABRQAAA==.',['�']='光芒:AwAECAQABRQAAA==.兲丶黒黒:AwAICBoABAoCDQAIAQgWWwBIDcMBBAoADQAIAQgWWwBIDcMBBAoAAA==.',['�']='冠位欧皇:AwAECAYABRQDCgAEAQjQBQA3bvEABRQACgAEAQjQBQA3bvEABRQACwACAQijHQAd924ABRQAAA==.冲锋陷乱:AwAHCAcABAoAAA==.',['�']='别逼我拿盾:AwAICAgABAoAAA==.刮痧死骑:AwADCAMABAoAAA==.刮碎:AwACCAIABAoAAA==.',['�']='力量与农药丶:AwAICAkABAoAAA==.',['�']='千念霁凉雨:AwAICAgABAoAAA==.半夏的清柠:AwADCAMABAoAAA==.卡士零零七:AwAECAQABRQAARMAAAAGCAIABRQ=.',['�']='叫我微风哥哥:AwAECAQABRQAAA==.右手捏个蛋:AwAECAQABRQAAA==.叶火:AwACCAIABRQAAA==.叶雪枫:AwAECAgABRQDEgAEAQhxEQAoTOcABRQAEgAEAQhxEQAoTOcABRQAFQAEAQhCCwAL14EABRQAARYAIYsICAYABRQ=.',['�']='咘莱克:AwAICBMABAoAAA==.咸鱼翻面:AwABCAIABRQAAA==.',['�']='唐嫣丷:AwAICAcABAoAAA==.',['�']='啤酒灬泡沫:AwAICAgABAoAAA==.',['�']='嗨喂你还好吗:AwADCAcABRQCFwADAQjtAgARoG8ABRQAFwADAQjtAgARoG8ABRQAAA==.',['�']='嘉乐君子:AwAECAYABRQDGAAEAQiCCgBBtvQABRQAGAAEAQiCCgAz+vQABRQAEQACAQjLDABRlLIABRQAARkAS38GCBUABRQ=.',['�']='四枫院夜:AwABCAEABRQAAA==.',['�']='圣光十七:AwAHCAcABAoAAA==.圣光天使:AwAICBEABAoAARoACcIHCAcABRQ=.圣光灌注嫂子:AwACCAIABRQAAA==.圣卡里西西:AwAGCAYABAoAAA==.',['�']='墨英晓:AwAICAQABAoAAA==.',['�']='壕骑:AwAECAQABAoAAA==.',['�']='夏米尔:AwAGCAIABRQAAA==.夜晨:AwACCAIABRQAAA==.大华哥:AwAECAUABRQCDQAEAQg2FwAzdOgABRQADQAEAQg2FwAzdOgABRQAAA==.大屿山丧标:AwAICAgABAoAAA==.大爷来了:AwACCAIABRQAAA==.天字第一毒奶:AwAGCAYABAoAAA==.天痕未现:AwAICAYABAoAAA==.头钟到八十:AwAICBAABAoAAA==.',['�']='奎爷琅琊玥:AwAECAQABRQAAA==.女子骉射队员:AwAHCCAABAoDEAAHAQhdCwBa914CBAoAEAAHAQhdCwBa914CBAoADwABAQh56gBB3S8ABAoAAA==.女射手:AwAICAUABAoAARAAVagCCAIABRQ=.好利来:AwACCAIABAoAAA==.',['�']='如意丶节节高:AwABCAIABAoAAA==.妖妖霊:AwADCAMABAoAAA==.',['�']='姏嘟嘟:AwAICAwABAoAAA==.姚胖:AwACCAIABAoAAA==.',['�']='宇宙湮灭:AwAGCAQABRQAARsAIOMICAUABRQ=.',['�']='小宝与大宝:AwAECAQABRQAAA==.小当家:AwABCAEABRQAAA==.小米椒:AwAICBEABAoAAA==.小香妃丶:AwAICAQABAoAAA==.尕拽侠:AwAECAQABRQAAA==.尤里乌斯丶:AwAECAQABRQAAA==.',['�']='崩摧:AwAECAoABRQCHAAEAQg/CgA6bwQBBRQAHAAEAQg/CgA6bwQBBRQAAA==.',['�']='工藤洗衣机:AwAICA0ABAoAAA==.左圣斧右绝刃:AwAGCAsABRQDDAAGAQiTAgAziNwABRQADAAEAQiTAgAhptwABRQACwADAQjqDgBOW9AABRQAAA==.左梅肯右笛子:AwAGCAQABRQAAQwAM4gGCAsABRQ=.巨鸠霸霸:AwAECAQABRQAAA==.',['�']='布来克:AwADCAUABRQCGAADAQjUBwBH1gUBBRQAGAADAQjUBwBH1gUBBRQAAA==.',['�']='年迈的大爷:AwACCAIABRQAAA==.幽幽的小鱼:AwAICAwABAoAAA==.',['�']='心若熙:AwAECAQABRQAAA==.忘陌路:AwAFCAYABAoAAA==.快乐小柯基:AwADCAgABRQCGAADAQitCQA4w/kABRQAGAADAQitCQA4w/kABRQAAA==.快用力不要停:AwADCAwABRQCDwADAQg8EQBFOPQABRQADwADAQg8EQBFOPQABRQAAA==.',['�']='怡糖:AwACCAIABRQAAA==.',['�']='我一路向北丶:AwACCAYABRQCGAACAQiPFwAsR5YABRQAGAACAQiPFwAsR5YABRQAAA==.',['�']='拉萨瞌睡:AwAHCAcABAoAAA==.拾叁:AwAECAYABAoAAA==.',['�']='摸鱼小术:AwABCAEABRQAAA==.',['�']='无敌小虾条:AwACCAIABRQAAA==.无欢:AwABCAEABAoAAA==.无爪精龙:AwACCAIABRQAAA==.无耻的神韵:AwADCAMABRQAAA==.旺仔丶老馒头:AwAECAgABAoAAA==.',['�']='昆哥:AwAHCAsABAoAAA==.昨晚谢谢你:AwAHCAIABAoAAA==.是非丶:AwABCAIABRQCEAAIAQjXGQA7vMgBBAoAEAAIAQjXGQA7vMgBBAoAAA==.',['�']='晨光沙星:AwACCAIABRQAAA==.',['�']='暗影邪骑:AwABCAEABRQAAA==.暮色挽歌:AwAGCBIABAoAAA==.',['�']='曉丶百花殘:AwAHCAEABAoAAA==.',['�']='月夜语风:AwAFCAcABAoAAA==.月野涂:AwAICAcABAoAAA==.朴亦哖:AwAECAkABRQCHAAEAQjfCAA/3wwBBRQAHAAEAQjfCAA/3wwBBRQAAA==.',['�']='来呗:AwACCAIABRQAAA==.杨蔚萌:AwAGCAQABRQAAA==.松化鸡蛋挞:AwAICAgABAoAAA==.',['�']='枫羽哥:AwACCAUABRQCDQACAQjtLwAYmoMABRQADQACAQjtLwAYmoMABRQAAA==.',['�']='武斗天使:AwAHCAcABRQCGgAHAQhJAQAJwrEBBRQAGgAHAQhJAQAJwrEBBRQAAA==.',['�']='残渣的执着:AwAICAgABAoAAA==.',['�']='毀滅風暴:AwAECAMABAoAAA==.毁灭痛苦恶魔:AwADCAMABRQAARMAAAAECAQABRQ=.',['�']='水微之阅:AwAECAQABRQAAA==.水瓶座圣骑:AwAICAgABAoAARMAAAAGCAQABRQ=.',['�']='波娜娜:AwAECAQABAoAAA==.',['�']='洋葱炒饭:AwAECAIABRQAAA==.洛基劳菲森:AwADCAMABAoAAA==.',['�']='流星咕:AwAECAQABRQAAA==.浪花朵朵飞:AwAICAMABAoAAA==.',['�']='深沉的吗喽:AwAECAQABRQAAA==.',['�']='清风拂柳痕:AwABCAEABAoAAA==.',['�']='溏门滚:AwAGCAsABAoAAA==.',['�']='灬泡芙灬:AwADCAUABRQCEQADAQjkEAAY4ZIABRQAEQADAQjkEAAY4ZIABRQAAA==.灬白浅浅丶:AwAECAQABAoAAA==.灬糯米米丶:AwAECAQABAoAAA==.',['�']='炸天哥:AwAECAgABRQDDQAEAQh+DABW2A4BBRQADQAEAQh+DABUIQ4BBRQAHQAEAQgtBABK6wEBBRQAAA==.',['�']='烈之煞:AwAGCAEABRQAARoACcIHCAcABRQ=.',['�']='無心睡眠:AwACCAIABAoAAA==.',['�']='牛是逼出来地:AwAECAQABRQAAA==.牛民:AwACCAIABAoAAA==.牧佩佩:AwAGCAIABRQAAA==.牧牧垛儿丶:AwAGCAYABAoAAA==.',['�']='狸花库库猫:AwAECAQABRQAAA==.',['�']='猋猋凉茶:AwACCAIABAoAAA==.',['�']='玄冰龙翔:AwAFCAUABAoAAA==.王图图:AwAICAgABRQDGwAIAQjoAQAm9YEBBRQAGwAEAQjoAQAzLoEBBRQAHgAEAQhzAwAjucIABRQAAA==.王牌飞行员:AwAGCAYABAoAAA==.',['�']='琦怪:AwAHCAcABAoAAA==.',['�']='甲鱼炖牛鞭:AwACCAIABRQAAA==.',['�']='疯狂叉烧包:AwAGCAYABAoAAA==.',['�']='白色半透明:AwACCAMABRQAAA==.',['�']='破魂之怒:AwAGCAYABAoAAA==.',['�']='碧蓝的椰椰:AwAECAQABRQAAA==.',['�']='祝桥大佬管:AwADCAUABRQDBgADAQgeFgAhG4IABRQABgACAQgeFgAjDYIABRQABQABAQgfHQAdODkABRQAAA==.',['�']='秋小楓:AwAECAQABRQAAA==.秋津茜:AwAECAQABRQAAA==.',['�']='竹马竹马:AwAECAQABRQAAA==.',['�']='筱嘲笑:AwAECAQABRQAAA==.',['�']='索命梵音:AwAFCAUABAoAAA==.紫色职业巅峰:AwAECAoABRQCEgAEAQihBwBRDRsBBRQAEgAEAQihBwBRDRsBBRQAAA==.',['�']='红豆丶沙:AwACCAIABAoAAA==.',['�']='经常死的骑士:AwAECAQABRQAAA==.绮世:AwAICAgABAoAAA==.',['�']='老术油子:AwAICAgABAoAAA==.老行:AwACCAIABRQAAA==.',['�']='肉包大箭神:AwAICAYABAoAAA==.',['�']='胡闹这怎么行:AwAGCAYABAoAAA==.胸肌发达:AwABCAEABRQDGgAIAQh+RAAYvQgBBAoAGgAIAQh+RAAYvQgBBAoAFgAEAQh2UwAazoQABAoAAA==.',['�']='脚猪子:AwAECAYABRQCAgAEAQiECwA9IPoABRQAAgAEAQiECwA9IPoABRQAAQIAQiQGCAoABRQ=.',['�']='芝士火腿面包:AwAECAQABAoAAA==.',['�']='苏卡布列:AwADCAoABRQCDQADAQiHFgAuAOoABRQADQADAQiHFgAuAOoABRQAAA==.',['�']='茎嗅咸:AwAGCAYABAoAAA==.',['�']='菁灵:AwABCAEABRQAAA==.',['�']='萌丨士:AwAICAgABAoAARoACcIHCAcABRQ=.萌萌哒丨雯雯:AwABCAEABRQAAREAHqIFCBQABRQ=.萎靡:AwAHCAcABAoAAA==.萝卜:AwAECAQABRQAAA==.萨神:AwADCAUABRQCHwADAQjHCAAapM4ABRQAHwADAQjHCAAapM4ABRQAAA==.落霞孤鹜齐飛:AwAECAYABRQDIAAEAQi7BwArGOYABRQAIAAEAQi7BwAnd+YABRQAIQACAQgqDwAdi3sABRQAAQgAOeQGCAYABRQ=.',['�']='蔡文姬:AwAHCBAABAoAAA==.',['�']='蕾米莉亚:AwABCAEABAoAARMAAAAICAkABAo=.',['�']='蛐蛐二世:AwAECAQABRQAAA==.',['�']='血之杀戮:AwABCAEABAoAAA==.',['�']='西王:AwAHCAgABAoAAA==.',['�']='豪个子先生:AwAFCAUABAoAAA==.',['�']='超级小学生丶:AwAGCAYABRQCGQAGAQhpAQAh/JgBBRQAGQAGAQhpAQAh/JgBBRQAAA==.超能大蛤:AwAGCAUABAoAAA==.',['�']='轰水步惊云:AwAECAQABRQAAA==.',['�']='过分里:AwAECAQABRQAAQQAN1QGCAYABRQ=.追逐繁星:AwABCAEABRQCBQAIAQhsCABSxIICBAoABQAIAQhsCABSxIICBAoAAA==.',['�']='逆天恶灵:AwAGCA0ABAoAAA==.逝去尐美女:AwACCAQABRQAAA==.',['�']='道长灬:AwAECAQABRQAAA==.遗歌彻夜:AwACCAUABRQCCwACAQhLFwAyxJAABRQACwACAQhLFwAyxJAABRQAAA==.遮天丶:AwAICAgABAoAAA==.',['�']='邓有才:AwAICAgABAoAAA==.邪堕天使:AwABCAMABRQDFQAIAQg6LgAYUeYABAoAFQAIAQg6LgASA+YABAoAEgADAQgNgAAelpMABAoAAA==.邪殺:AwACCAIABAoAAA==.',['�']='部落丶大混子:AwAECAIABRQAAA==.',['�']='酷酷的天天:AwAECAEABAoAAA==.',['�']='醉悦儒风:AwAECAEABRQAAA==.',['�']='镜泷:AwAFCAUABAoAAA==.',['�']='阿格拉玛之殇:AwAICAgABAoAAA==.',['�']='陈庆之:AwAFCAUABAoAAA==.陈暖树:AwAICAgABAoAAA==.陈盛:AwAECAQABAoAAA==.',['�']='雄哥我来了:AwAGCAUABAoAAA==.零丶鹤川:AwAECAQABRQAAA==.',['�']='露娜瑞尔月蚀:AwAGCAYABRQCCwAGAQiBAABNRukBBRQACwAGAQiBAABNRukBBRQAAA==.',['�']='青色烟雨:AwAGCA0ABAoAAA==.靜聞師太:AwAECAQABRQAAA==.',['�']='颖颖很快乐:AwACCAIABRQAARgAO04GCBAABRQ=.風卷月:AwACCAQABRQAAA==.',['�']='风行者:AwABCAEABAoAAA==.',['�']='饿馍累手:AwACCAIABRQAAA==.',['�']='马扎罗:AwAGCAcABAoAAA==.',['�']='骑着狼的羊:AwAGCAMABAoAAA==.',['�']='魔法少女二病:AwAICAgABAoAAA==.',['�']='黙黙:AwAECAQABRQCBAAEAQh1DAAmgN0ABRQABAAEAQh1DAAmgN0ABRQAAA==.',['�']='龙骑士丶:AwAECAQABAoAAA==.龚磊:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end