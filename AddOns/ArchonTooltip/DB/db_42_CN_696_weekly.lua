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
 local lookup = {'Paladin-Retribution','Priest-Holy','Priest-Discipline','Warrior-Fury','Warrior-Arms','Monk-Windwalker','Warlock-Destruction','Warlock-Demonology','Unknown-Unknown','Hunter-BeastMastery','Hunter-Survival','Mage-Fire','Shaman-Elemental','Druid-Balance','Hunter-Marksmanship','Mage-Frost','Shaman-Enhancement','Shaman-Restoration','Monk-Mistweaver','DeathKnight-Blood','Druid-Restoration','Rogue-Outlaw','Paladin-Protection','Druid-Feral','DeathKnight-Unholy','Warrior-Protection','Monk-Brewmaster','Druid-Guardian',}; local provider = {region='CN',realm='斯坦索姆',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adavak:AwAICAgABAoAAA==.',As='Asaki:AwAGCAYABAoAAA==.',Bj='Bjdd:AwAECAQABRQCAQAIAQj4KABU8FwCBAoAAQAIAQj4KABU8FwCBAoAAA==.',Bl='Blight:AwAGCAYABAoAAA==.',Ca='Cartethyia:AwACCAQABRQDAgAIAQiNDABTZFICBAoAAgAIAQiNDABQ+FICBAoAAwAFAQhPLAA4SE4BBAoAAA==.',Co='Coastbreaker:AwAICBAABAoAAA==.',Da='Damforce:AwACCAIABRQDBAAIAQg/IAAujPwBBAoABAAIAQg/IAAujPwBBAoABQAEAQilSgASc3AABAoAAA==.',Em='Emwow:AwACCAEABAoAAA==.',En='Enzo:AwABCAEABRQAAA==.',Fu='Fukklol:AwACCAIABRQAAA==.',Gr='Grayhowl:AwAGCAYABAoAAA==.',Hm='Hmt:AwADCAMABAoAAA==.',Ho='Hoey:AwADCAUABRQCBgADAQivCAAtKOUABRQABgADAQivCAAtKOUABRQAAA==.Horuss:AwAGCAoABAoAAA==.',Ji='Jienne:AwAFCAEABAoAAA==.',Ka='Kathera:AwAFCAQABAoAAA==.',Ma='Magician:AwAECAgABRQDBwAEAQiIBwBEbAIBBRQABwAEAQiIBwBEbAIBBRQACAABAQhLFgAAAAAABRQAAQkAAAAGCAQABRQ=.Mayuyu:AwAFCAUABAoAAA==.',Mi='Mirala:AwAHCAYABAoAAA==.',Na='Nainainaiss:AwAECAQABRQAAA==.',Nm='Nmdandan:AwAECAMABRQAAA==.',Pe='Pekka:AwACCAQABRQAAA==.',Po='Po:AwACCAIABAoAAA==.',['�']='丁香與醋栗:AwAGCA4ABAoAAA==.七伏:AwAHCAsABAoAAA==.三十张呼啦:AwADCAQABAoAAA==.不再驼背了:AwAICAgABAoAAA==.不吃泡面:AwADCAYABRQDCgAIAQjBGgBay3cCBAoACgAIAQjBGgBay3cCBAoACwADAQicFgBCDGAABAoAAA==.专杀左右:AwABCAEABAoAAA==.丛林王:AwAECAQABAoAAA==.丝碧涅:AwAECAQABRQAAA==.丶夜刃豹:AwAGCAYABAoAAA==.丶思议:AwABCAEABAoAAA==.丶诗雨:AwAECAQABRQAAA==.丶路飞:AwAGCAYABAoAAA==.',['�']='乱舞:AwAECAQABRQAAQYAKkoICAYABRQ=.',['�']='二锅头突然间:AwACCAIABRQAAA==.于晏的鸡腿:AwAECAQABRQAAA==.京爷儿:AwAECAQABRQAAA==.',['�']='优雅的双手:AwEGCAgABRQCBwAEAQhKAwBeYjcBBRQABwAEAQhKAwBeYjcBBRQAAQkAAAAICAMABRQ=.会飞的棺材:AwABCAEABAoAAA==.',['�']='何馨澄:AwAGCAsABRQCDAAGAQieAQBCLd4BBRQADAAGAQieAQBCLd4BBRQAAA==.',['�']='保濟丸:AwADCAcABRQCAQAIAQg7EwBbg7kCBAoAAQAIAQg7EwBbg7kCBAoAAA==.',['�']='兜里的小红颜:AwACCAIABAoAAA==.',['�']='冰雪凋零:AwAICAgABAoAAA==.',['�']='凛冬将至丨:AwAICBAABAoAAA==.',['�']='刘大佳:AwACCAMABRQAAA==.别慌给你盾:AwAGCAgABAoAAA==.刹那小小猫:AwAGCAYABAoAAA==.刺客女:AwAFCAIABAoAAA==.',['�']='剑志天下:AwAECAUABAoAAA==.',['�']='功夫喵喵:AwAICAwABAoAAA==.',['�']='北海道起司:AwAECAQABRQAAA==.',['�']='原皮:AwAECAQABRQAAA==.',['�']='口袋饱饱:AwAGCAcABAoAAA==.古丹吴彦祖:AwADCAEABAoAAA==.',['�']='咯咖什幽灵狼:AwAECAcABAoAAA==.',['�']='唉声叹气:AwACCAIABAoAAA==.',['�']='噔里个噔:AwAECAYABAoAAA==.',['�']='回忆一百分:AwAECAQABRQAAA==.',['�']='土丄土:AwAECAQABRQAAA==.圣光制裁:AwACCAIABRQAAA==.圣者归来:AwAECAsABRQCAQAEAQjpFQBC3+wABRQAAQAEAQjpFQBC3+wABRQAAA==.',['�']='夜行游侠:AwAICAkABAoAAA==.大烧刚:AwAICAgABAoAAA==.天生无聊牛:AwAICAkABAoAAA==.天选欧皇:AwAICAgABAoAAA==.天野遠子:AwAICAgABAoAAA==.',['�']='女人的秘密:AwAICBcABAoCDAAIAQiUGABMTVICBAoADAAIAQiUGABMTVICBAoAAA==.',['�']='姑姑爱过儿:AwACCAIABAoAAA==.',['�']='威武大能猫:AwABCAEABRQAAA==.',['�']='寂寞的甜甜:AwAECAQABRQAAA==.寂寞的米米:AwAECAQABRQAAA==.寂寞的考拉:AwAECAQABRQAAA==.寂寞的豆豆:AwAICAYABAoAAQ0AVZkICAIABRQ=.寂寞的趴趴:AwAECAYABRQCDgAEAQjcDgAxsuoABRQADgAEAQjcDgAxsuoABRQAAA==.',['�']='小潶跳大:AwAFCAkABAoAAA==.小萝莉:AwAECAEABAoAAA==.少勇哥之妾:AwAECAQABRQAAA==.',['�']='帅气的老公:AwACCAIABRQAAA==.',['�']='往事清風:AwAHCA0ABAoAAA==.微微威武:AwAICA4ABAoAAA==.',['�']='悠蛋:AwAECAgABRQDDwAEAQhxAwBLCxIBBRQADwAEAQhxAwBK9RIBBRQACgAEAQhVGAAh89UABRQAAA==.',['�']='愤怒的小皮鞭:AwAICAgABAoAAA==.',['�']='我开怪:AwACCAIABAoAAA==.我是洒满:AwABCAEABAoAAA==.',['�']='打开时空之门:AwACCAUABRQCEAACAQgUDABaNZQABRQAEAACAQgUDABaNZQABRQAAA==.打死不奶:AwABCAEABRQDEQAIAQgNGwArJ9QBBAoAEQAIAQgNGwArJ9QBBAoAEgAEAQj5bgAf4MIABAoAAA==.打死你:AwAGCAoABRQCEwAGAQgzAQA6LLYBBRQAEwAGAQgzAQA6LLYBBRQAAA==.',['�']='指不定能行:AwABCAEABAoAAA==.指定能行:AwACCAIABAoAAA==.',['�']='攻强机器:AwAFCAUABAoAAA==.放开那根茄子:AwAECAQABAoAAA==.',['�']='教练我想打求:AwAICBAABAoAAA==.',['�']='无人生还:AwAGCAcABRQCFAAGAQgoAQA4uYIBBRQAFAAGAQgoAQA4uYIBBRQAAA==.',['�']='明澄吖:AwAECAQABRQAAA==.明静止水:AwAICAgABAoAAA==.',['�']='暮色冲锋:AwADCAMABAoAAA==.',['�']='最爱洗面奶:AwABCAEABRQAAA==.月影乄:AwACCAIABRQDFQAIAQjCCgBO0mMCBAoAFQAIAQjCCgBO0mMCBAoADgAIAQgmHgBW1TMCBAoAAA==.木之芽风:AwAECAQABRQAAA==.',['�']='李尐龍:AwAGCAgABAoAAA==.李狗蛋:AwAICBUABAoCFgAIAQikAQBRz60CBAoAFgAIAQikAQBRz60CBAoAAA==.',['�']='林北很生气:AwABCAEABRQAAA==.',['�']='桃乐丝灬:AwACCAMABAoAAA==.',['�']='欸嘿:AwAGCAYABAoAAA==.',['�']='水墨轻歌:AwACCAIABAoAAA==.',['�']='没有迷:AwAECAwABRQCFwAEAQhNCQAhvZ0ABRQAFwAEAQhNCQAhvZ0ABRQAAA==.',['�']='海天丶盛筵:AwADCAMABAoAAQYAOH8DCAkABRQ=.',['�']='混沌的兰舞:AwAECAIABAoAAA==.',['�']='清越:AwAICAsABAoAAA==.清越轻悦:AwAICBAABAoAAA==.游戏要啸着玩:AwAGCAQABRQAAA==.',['�']='漆黑噤默:AwACCAUABRQCAwACAQhTFQAkc4cABRQAAwACAQhTFQAkc4cABRQAAA==.',['�']='澳嗷嗷:AwABCAEABAoAAA==.',['�']='炎夔:AwADCAMABAoAAA==.',['�']='燃烧火热:AwAFCAUABAoAAA==.燃烧的恶魔:AwAICAgABAoAAA==.燃烧的花生米:AwAICAUABAoAAA==.',['�']='牛肉人盗賊:AwABCAEABRQAAA==.物理易伤:AwAFCAkABAoAAA==.',['�']='独孤风:AwAECAQABRQAAA==.',['�']='猎之风:AwAECAgABRQCDwAEAQjCDgAQn6MABRQADwAEAQjCDgAQn6MABRQAAA==.猫头嘤:AwABCAIABRQCGAAHAQi+CABMXBgCBAoAGAAHAQi+CABMXBgCBAoAAA==.',['�']='玉爧瓏:AwAECAQABRQAAA==.玉藻前灬:AwAGCAYABRQCEwAGAQi/AQAn3pcBBRQAEwAGAQi/AQAn3pcBBRQAAA==.玫瑰豆沙包:AwAFCAUABAoAAA==.',['�']='破晓丶激流:AwACCAIABRQAAA==.',['�']='碧淇:AwAGCAYABAoAAA==.',['�']='秋月丶星空:AwACCAEABAoAAA==.',['�']='窈窕猫娘:AwACCAcABRQCEwACAQibEABX8MoABRQAEwACAQibEABX8MoABRQAAA==.',['�']='索纳奇:AwACCAIABRQAAA==.',['�']='纯洁的大叔:AwAECAQABAoAAA==.',['�']='群儿子陈凡:AwADCA0ABRQCFAADAQgcEwANAoAABRQAFAADAQgcEwANAoAABRQAAA==.',['�']='肥嘟嘟左卫们:AwACCAIABRQAAA==.',['�']='艾琳塞克:AwADCAUABAoAAA==.艾莎丶:AwACCAIABAoAAA==.',['�']='芷若:AwAHCAgABAoAAA==.',['�']='苍蝇王:AwAHCAgABAoAAA==.',['�']='莽夫也有春天:AwAICAkABAoAAA==.',['�']='葫芦娃呼噜:AwACCAIABAoAAA==.',['�']='蔑世灬:AwACCAIABAoAAA==.',['�']='蜗牛的春天:AwAGCAYABRQCFQAGAQh9AQAUGV4BBRQAFQAGAQh9AQAUGV4BBRQAAA==.',['�']='血舞江寒:AwAICBUABAoCFAAIAQiiAQBggP4CBAoAFAAIAQiiAQBggP4CBAoAAA==.',['�']='褪色的记忆:AwACCAIABAoAAA==.',['�']='西内玛丽亚:AwAICAgABAoAAQkAAAAICAMABRQ=.',['�']='覅俄方:AwACCAIABRQAAA==.',['�']='貔貅之灵:AwAICAwABAoAAA==.',['�']='贼娃子娃娃:AwACCAIABRQAAA==.',['�']='赤山茶之恋:AwAICAgABAoAAA==.',['�']='超级大蜗牛:AwABCAEABAoAAA==.',['�']='输不起就别玩:AwAECAgABAoAAA==.',['�']='那个小德丶:AwAECAIABRQAAA==.那个武僧丶:AwAGCAYABAoAAA==.那个萨满丶:AwAGCAYABAoAAA==.邪恶灬之源:AwABCAEABRQAAA==.',['�']='部落小黄鱼:AwACCAMABRQAAA==.',['�']='野蛮祝福:AwAICBMABAoAAA==.',['�']='铃铛:AwAECAQABRQAAA==.铝泡:AwADCAMABRQAAA==.',['�']='销魂一射:AwACCAYABRQCCgACAQjiKQAi/YgABRQACgACAQjiKQAi/YgABRQAAA==.锈刃又锋:AwAHCAwABAoAAA==.锐雯丶戴尔:AwAICBkABAoCGQAIAQiEGwBKrDUCBAoAGQAIAQiEGwBKrDUCBAoAARkAPpAGCAgABRQ=.',['�']='闪光小狮纸:AwABCAEABRQAAA==.',['�']='阿斯达迪:AwAHCAkABAoAAA==.阿瑞安赫德:AwABCAEABRQDAgAIAQghDwBNrzkCBAoAAgAIAQghDwBNrzkCBAoAAwAGAQhbUgARxaMABAoAAA==.',['�']='陈伟霆:AwAGCAoABAoAAA==.',['�']='雨聻:AwAECAQABRQAAA==.雪碧会发光:AwAECAIABRQAAA==.',['�']='霸吧:AwAECAQABRQAAA==.',['�']='青柠晾茶:AwACCAIABAoAAA==.',['�']='顾北宁:AwADCAsABRQDGgADAQhwAwAu9MIABRQAGgADAQhwAwArpMIABRQABQACAQigCgA0zqAABRQAAA==.顾城:AwAECAwABRQEEwAEAQiSDgAiENoABRQAEwAEAQiSDgAiENoABRQAGwAEAQiwAgA11cUABRQABgAEAQhpCwAXQrwABRQAAA==.',['�']='风尘中人:AwAGCAYABAoAAA==.',['�']='魂丢梦再:AwAGCAYABRQDFwAEAQjYBgAxcsMABRQAFwAEAQjYBgAxcsMABRQAAQACAQiVMgAoXHgABRQAAQkAAAAICAQABRQ=.魔幻:AwACCAYABRQCHAACAQhzAwAdWl8ABRQAHAACAQhzAwAdWl8ABRQAAA==.魔法龙咪:AwAFCAUABAoAAA==.',['�']='鲁卡:AwABCAMABRQDBwAIAQi0HABC2wMCBAoABwAIAQi0HABC2wMCBAoACAABAQguZAAUuTUABAoAAA==.',['�']='黑化:AwACCAMABRQAAA==.黑色羽翼:AwAECAQABRQAAA==.默念陌念:AwAFCAcABAoAAA==.',['�']='龍傲地:AwAECAQABAoAAA==.龙闻道:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end