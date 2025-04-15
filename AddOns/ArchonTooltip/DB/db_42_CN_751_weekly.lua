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
 local lookup = {'DeathKnight-Unholy','DemonHunter-Havoc','Druid-Balance','Druid-Restoration','Paladin-Holy','DeathKnight-Blood','Shaman-Restoration','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','DemonHunter-Vengeance','Monk-Windwalker','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Priest-Shadow','Priest-Holy','Evoker-Devastation','Rogue-Assassination','DeathKnight-Frost','Druid-Feral','Paladin-Protection','Unknown-Unknown','Warrior-Fury','Mage-Frost','Druid-Any','Monk-Mistweaver','Warrior-Protection','Mage-Fire','Shaman-Enhancement','Warrior-Arms',}; local provider = {region='CN',realm='燃烧军团',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ac='Aciy:AwAICAoABAoAAA==.',Am='Amorli:AwAECAQABRQAAA==.',Cl='Clabby:AwABCAEABRQAAA==.',De='Destruction:AwAICA0ABAoAAA==.',Dv='Dvita:AwAICAgABAoAAQEAPpAGCAgABRQ=.',Fa='Fankywork:AwAECAUABAoAAA==.',Ge='Gely:AwAFCAUABAoAAA==.',Hg='Hg:AwABCAEABAoAAA==.',Jm='Jmy:AwACCAIABRQCAgAHAQixFwBaGVwCBAoAAgAHAQixFwBaGVwCBAoAAA==.',Li='Lidstrom:AwAGCAYABAoAAA==.',Mi='Mio:AwAGCAwABAoAAA==.',Or='Origin:AwAHCBYABAoDAwAHAQi1KgBEg+cBBAoAAwAHAQi1KgBEg+cBBAoABAAGAQhiMAA6QjUBBAoAAA==.',Sh='Sheperd:AwAICAgABAoAAA==.',Ze='Zerokt:AwACCAUABRQCBQACAQi/CwAcHIoABRQABQACAQi/CwAcHIoABRQAAA==.',['�']='一大波骑士:AwAGCAsABAoAAA==.一库:AwAICBAABAoAAA==.一起看日落吗:AwAICAoABAoAAA==.上古旱魃:AwAICBQABAoDAQAIAQj1IQBAUQwCBAoAAQAIAQj1IQBAUQwCBAoABgADAQjmSAAneWsABAoAAA==.两横一竖:AwAICBAABAoAAA==.丨無訫倾城丨:AwABCAEABRQAAA==.丨阿娜丨:AwAECAQABRQAAA==.丶嘴角的温度:AwACCAIABRQCBwAIAQiHCwBTJIUCBAoABwAIAQiHCwBTJIUCBAoAAA==.丶魔法少女:AwAECAkABRQECAAEAQiVBABTCSQBBRQACAADAQiVBABHUyQBBRQACQABAQjXFAA+71IABRQACgABAQiRFwAAAAAABRQAAA==.丷水库浪子丷:AwAGCAYABAoAAA==.丷随风丷:AwADCAMABRQAAA==.',['�']='你並非永恆:AwACCAMABRQCBwAIAQiSOwAmsnABBAoABwAIAQiSOwAmsnABBAoAAA==.',['�']='六十五不能退:AwAECAQABRQAAA==.',['�']='冰羽七煌:AwAHCAcABAoAAA==.冲锋即吾命:AwABCAEABAoAAA==.',['�']='几许风雨:AwAECAcABAoAAA==.',['�']='勾勾和丢丢:AwACCAIABRQAAA==.',['�']='北京啤酒:AwAECAUABRQCBgAEAQj+BgBGuvMABRQABgAEAQj+BgBGuvMABRQAAA==.',['�']='卌卌雪卝亓:AwAGCAEABAoAAA==.',['�']='名起丧钟:AwADCAoABRQCBgADAQgzDAAq27YABRQABgADAQgzDAAq27YABRQAAQIAVD4GCAkABRQ=.',['�']='呆毛:AwACCAIABRQAAA==.呆頭灰鸟:AwABCAIABRQAAA==.呦呦鹿鸣丶:AwAFCAUABAoAAA==.呼啦啦小樱桃:AwAECAkABRQDCwAEAQhwBwAib7AABRQACwAEAQhwBwAib7AABRQAAgABAAgAAAAAAAAABRQAAQwAWZcGCBkABRQ=.',['�']='哈撒给灬:AwADCAkABRQCDQADAQgzFgAxWOsABRQADQADAQgzFgAxWOsABRQAAA==.',['�']='唯有杜康丶:AwAGCA0ABAoAAA==.',['�']='啊曦啊曦啊:AwADCAYABRQCDAADAQi5CQAgjNkABRQADAADAQi5CQAgjNkABRQAAA==.',['�']='喵小乐:AwAECA0ABRQDDgAEAQisEwBCXesABRQADgAEAQisEwA+susABRQADwADAQjVDAAh0rwABRQAAA==.',['�']='堕入深海:AwADCAoABRQEEAADAQhmDwBYeLIABRQAEAACAQhmDwBU3bIABRQAEQACAQhLEgA4rKEABRQAEgABAQhXGQAZMkQABRQAAA==.',['�']='夜歌:AwAICAgABAoAAA==.夜穹殉至:AwAFCAYABAoAAA==.天佑残疾人:AwADCAUABRQDCgADAQgtBwAbknQABRQACgACAQgtBwAjjXQABRQACAABAQh2IwALm0cABRQAAA==.天堂灬在左:AwADCAkABRQCDQADAQjmGgAgqNoABRQADQADAQjmGgAgqNoABRQAAA==.天天有有零:AwAFCAUABAoAAA==.天苍谋:AwADCAgABRQDBAADAQgsCQAjKMQABRQABAADAQgsCQAjKMQABRQAAwACAQgcIgAKrWkABRQAAA==.天菩萨:AwAGCAYABAoAAA==.夫妻肺骗:AwADCAMABRQAAA==.',['�']='奈法莱恩:AwAICAgABAoAAA==.奎恩缇丝:AwACCAMABRQCCwAIAQjfIwAiUioBBAoACwAIAQjfIwAiUioBBAoAAA==.奔放丶:AwAECAQABRQAAA==.奔跑小健将:AwAECAQABRQAAA==.奶中第一毛:AwAHCA0ABAoAAA==.',['�']='姐姐你怎么了:AwAICAgABAoAAA==.',['�']='寂鴉:AwACCAEABAoAAA==.',['�']='小丷七:AwADCAoABRQCDgADAQiOEQA6JvMABRQADgADAQiOEQA6JvMABRQAAA==.小熊笨笨:AwAICAgABAoAAA==.小飞龙来咯:AwABCAEABRQCEwAIAQiMDQBLiEUCBAoAEwAIAQiMDQBLiEUCBAoAAA==.尖尖头阿巴顿:AwAICAgABAoAAA==.就叫小橙吧:AwACCAMABRQCFAAIAQgLDwBBLgYCBAoAFAAIAQgLDwBBLgYCBAoAAA==.',['�']='布胖儿:AwAECAQABRQAAA==.',['�']='开朗呆呆魔:AwADCAkABRQCFQADAQjZAQA3a/0ABRQAFQADAQjZAQA3a/0ABRQAAA==.',['�']='彼岸花开半夏:AwAICAoABAoAAA==.',['�']='徳靁克塔尔:AwAFCAUABAoAAA==.',['�']='想去海边:AwAECAYABAoAAA==.想飛别怕摔:AwABCAIABRQEAwAIAQgkHwBU+y0CBAoAAwAIAQgkHwBT8C0CBAoAFgAEAQiSFwBJWucABAoABAACAQi9aQAaVVUABAoAAA==.',['�']='打拳的小蝎子:AwACCAIABAoAAA==.',['�']='折耳团:AwAGCAYABAoAAA==.',['�']='拳如风:AwACCAIABRQCDAAIAQj3BQBZ68ICBAoADAAIAQj3BQBZ68ICBAoAAA==.',['�']='救赎之魂丶:AwACCAIABRQDBQAIAQiyAgBaR7YCBAoABQAIAQiyAgBaR7YCBAoADQABAQjzbQEAAAAABAoAAA==.',['�']='无情灬哈拉少:AwAHCAMABAoAAA==.无邪丶:AwABCAEABRQAAA==.',['�']='暮影旋律:AwACCAMABRQDEAAIAQhsEgBQ9BECBAoAEAAIAQhsEgBDBRECBAoAEgAGAQgzKABQH4MBBAoAAA==.暴食海獭:AwAGCA0ABRQDFwAGAQjTAQBC7k0BBRQAFwAGAQjTAQArt00BBRQADQAEAQg9EABE/f8ABRQAARgAAAAICAQABRQ=.',['�']='月夜忧光:AwABCAEABAoAAA==.月见:AwAECAUABAoAAA==.未央不见丶:AwACCAMABRQCAwAIAQi/DgBVb5wCBAoAAwAIAQi/DgBVb5wCBAoAAA==.',['�']='森森:AwABCAEABRQCGQAHAQgoLQA2o7IBBAoAGQAHAQgoLQA2o7IBBAoAAA==.',['�']='橙仔丶:AwABCAEABAoAAA==.',['�']='歪嘴龙王:AwACCAIABRQAAA==.',['�']='江万理:AwACCAQABRQAAA==.江夏:AwABCAEABRQCDQAHAQibNABSmjECBAoADQAHAQibNABSmjECBAoAAA==.',['�']='法力枯竭:AwACCAIABRQAAA==.',['�']='派派小星:AwACCAMABRQCGgAGAQgEOQA6VFoBBAoAGgAGAQgEOQA6VFoBBAoAAA==.',['�']='浮世清欢:AwADCAMABRQAAA==.',['�']='消失的五月:AwAICAgABAoAAA==.',['�']='潇然随风:AwABCAEABRQECQAHAQhIFABJSy8BBAoACQAFAQhIFABDyC8BBAoACAAFAQj5TwBBuQYBBAoACgADAQhlNwBRpb8ABAoAAA==.',['�']='灰头呆鸟:AwAGCAYABAoAAA==.',['�']='点点丶一级棒:AwABCAEABRQAAA==.',['�']='熊本熊大魔王:AwAICAgABAoAAA==.',['�']='爱似烟火:AwACCAUABRQCGQACAQiAGAAg1JYABRQAGQACAQiAGAAg1JYABRQAAA==.',['�']='牛叉超龄儿童:AwAGCBIABRQDBAAGAQiQAAA4hrQBBRQABAAGAQiQAAA4hrQBBRQAAwAEAQiVFwAby64ABRQAARgAAAAICAIABRQ=.物语:AwACCAIABAoAAA==.',['�']='狂野猩:AwACCAIABRQAAA==.',['�']='白锦无纹:AwAECAoABRQDAgAEAQi3CgA+bwcBBRQAAgAEAQi3CgA+bwcBBRQACwAEAQiJDAAHcncABRQAAQwAIYsICAYABRQ=.白面包呢:AwAECAQABRQAAA==.',['�']='直布罗陀学姐:AwACCAIABRQAAA==.',['�']='看什么我有枪:AwAECAQABRQAAQ4ANu4GCAYABRQ=.真灬怡宝:AwACCAIABRQAAA==.',['�']='知默:AwAGCAkABAoAAA==.',['�']='秀儿很秀:AwAGCAYABAoAAA==.',['�']='空之轨迹:AwAGCAYABRQCGwAGAAgAAAAzuAAABRQAAwAGAAgAAAAzuAAABRQAAA==.空心菜:AwACCAIABRQAAA==.',['�']='窝嫩达爹:AwAICAgABAoAAA==.',['�']='笙笙骑:AwABCAEABRQAAA==.',['�']='红牛能量饮料:AwAECAQABRQAAA==.纯閖灬丒恨:AwABCAEABRQAAA==.纵死侠骨香:AwAECAQABRQAAA==.',['�']='绾青丝丶:AwAECAQABAoAAA==.',['�']='罗小蝶:AwAECAYABRQCBwAEAQhLBQBHoxgBBRQABwAEAQhLBQBHoxgBBRQAAA==.',['�']='老天最爱的崽:AwADCAgABRQCBwADAQhSBQBG8xgBBRQABwADAQhSBQBG8xgBBRQAAA==.',['�']='肉身成圣光:AwACCAIABRQAAA==.',['�']='脸滚带爬:AwACCAUABRQCHAACAQg3FwArT5UABRQAHAACAQg3FwArT5UABRQAAA==.',['�']='舞灬橙多多:AwAECAQABRQAAA==.',['�']='艾丽桑德:AwADCAkABRQCHQADAQiCBQARpJIABRQAHQADAQiCBQARpJIABRQAAA==.艾瑞卡:AwAECAcABRQDBgAEAQisAwBaGTEBBRQABgAEAQisAwBZPDEBBRQAAQACAQj/EwBSZ6kABRQAAA==.',['�']='草鹿八千蓅:AwADCAoABRQCFAADAQgPBABQpBIBBRQAFAADAQgPBABQpBIBBRQAAA==.',['�']='落天星尘:AwABCAIABRQAAA==.',['�']='葬爱灬杀马特:AwAGCAEABRQAAA==.',['�']='蓝毛老头:AwACCAQABRQAAA==.',['�']='蔚蓝海洋:AwAECAQABRQAAA==.蔡建方:AwAICAcABAoAARgAAAAICAMABRQ=.蔷薇时代:AwADCAgABRQDDwADAQhvEgAl2IMABRQADwACAQhvEgAm2YMABRQADgABAQgsOAAj1UgABRQAAA==.',['�']='虚空破灭:AwAHCBQABAoDGgAHAQh8NAA6unMBBAoAGgAHAQh8NAA6unMBBAoAHgAGAQgEWAAX7fQABAoAAA==.',['�']='蚂蚁:AwABCAEABRQAAA==.',['�']='血色一少:AwABCAEABAoAAA==.',['�']='西一欧:AwAGCAgABRQDHwAGAQh5BAA9kBsBBRQAHwAEAQh5BAA5/RsBBRQABwAEAQiIEwAH3rQABRQAAA==.西瓜妈妈:AwAECAQABRQAAA==.',['�']='诛伏赐死:AwAHCAgABAoAAA==.',['�']='走路带风:AwAGCAkABRQCAgAGAQjQAABUPuwBBRQAAgAGAQjQAABUPuwBBRQAAA==.',['�']='超级百变星君:AwABCAEABAoAAA==.',['�']='邪乄冰魔:AwAGCAYABAoAAA==.邪恶栀子花:AwAICAsABAoAAA==.',['�']='部落小钢炮:AwAICAYABAoAAA==.',['�']='重新集结部队:AwABCAEABRQAAA==.',['�']='银鞍照白马:AwAGCAYABAoAAA==.',['�']='锅包肉大成:AwAGCBMABAoAAA==.',['�']='镜中花:AwAICAYABAoAAA==.长岛冰茶丶:AwAECAgABRQCCAAEAQgGCwA8hegABRQACAAEAQgGCwA8hegABRQAAA==.',['�']='開心不開心:AwAECAQABRQAAA==.',['�']='闪电恋:AwACCAcABRQCBwACAQixFQBLYKQABRQABwACAQixFQBLYKQABRQAAA==.',['�']='阿尔图罗:AwAECAQABRQAAA==.阿晨大魔王:AwADCAoABRQDIAADAQgTBQAvIeEABRQAGQADAQgMDgAnJe8ABRQAIAADAQgTBQAdL+EABRQAAA==.',['�']='雷欧灬奥特曼:AwAECAQABRQAAA==.雾中猎手:AwABCAEABRQAAA==.',['�']='骑小骑:AwABCAEABRQAAA==.',['�']='高兴霸霸:AwABCAEABRQAAA==.',['�']='鹏鹏的锅:AwACCAMABAoAAA==.鹏鹏的高压锅:AwAFCAUABAoAAA==.',['�']='黄瓜:AwAECAYABRQDCgAEAQifAQA6tQMBBRQACgADAQifAQA6tQMBBRQACAADAQjhHAAjdHMABRQAAA==.黛丝:AwAHCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end