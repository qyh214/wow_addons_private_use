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
 local lookup = {'Unknown-Unknown','DeathKnight-Unholy','DemonHunter-Havoc','DemonHunter-Vengeance','Priest-Discipline','Mage-Frost','Mage-Fire','Hunter-BeastMastery','Druid-Balance','Shaman-Restoration','Shaman-Elemental','Priest-Shadow','Monk-Windwalker','Paladin-Retribution','Priest-Holy','Druid-Restoration','Warlock-Affliction','Monk-Mistweaver','Paladin-Protection','Hunter-Marksmanship','Hunter-Survival','Evoker-Preservation','Evoker-Devastation','Warlock-Destruction',}; local provider = {region='CN',realm='轻风之语',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ap='Applejack:AwAICBAABAoAAQEAAAAICAIABRQ=.',Bo='Bosch:AwAGCAYABAoAAA==.',Ex='Explosion:AwAICA8ABAoAAA==.',Fr='Francisee:AwAICA4ABAoAAA==.',Gi='Giliya:AwADCAkABRQCAgADAQjGCQBFov8ABRQAAgADAQjGCQBFov8ABRQAAA==.',Gr='Greemon:AwADCAkABRQDAwADAQgWEwApOuMABRQAAwADAQgWEwApOuMABRQABAACAQgPEQAJE1QABRQAAA==.',He='Hello:AwAGCAYABAoAAA==.',Ia='Iamdc:AwAICAIABRQAAA==.',Im='Imissyou:AwAGCAYABAoAAA==.',Ko='Konurimaki:AwAGCAQABRQCBQAEAQgYBABZUTMBBRQABQAEAQgYBABZUTMBBRQAAA==.',Mi='Mightnare:AwABCAEABRQDBgAIAQhGCwBVcJcCBAoABgAIAQhGCwBVcJcCBAoABwAEAQiKiQALZk8ABAoAAA==.Mistheway:AwAICAgABAoAAA==.',Ra='Raelag:AwAGCAYABRQCBwAGAQg/AgBJTdYBBRQABwAGAQg/AgBJTdYBBRQAAA==.',Sa='Saramel:AwABCAEABAoAAA==.',So='Sonicadi:AwACCAMABAoAAA==.',Sp='Spike:AwABCAEABAoAAA==.',Tl='Tlo:AwAFCAUABAoAAA==.',Tr='Troubler:AwADCAkABRQCCAADAQidHAAkackABRQACAADAQidHAAkackABRQAAA==.',Yy='Yyxxy:AwAGCAYABAoAAA==.',['�']='一念成殇:AwACCAMABAoAAA==.临时洋流:AwAICAgABAoAAA==.丹妮莉斯:AwAGCAYABAoAAA==.',['�']='九连玉:AwADCAQABAoAAA==.',['�']='五月丶飞华:AwAECAQABRQAAA==.亲亲魅影:AwABCAIABRQAAA==.人间世:AwAECAQABAoAAA==.',['�']='任逍遥依依:AwAECAQABRQAAA==.',['�']='伊塔尼斯:AwAGCAYABAoAAA==.伟少爷:AwABCAEABRQAAA==.传说中的球宝:AwACCAIABAoAAA==.',['�']='余琦:AwADCAYABRQCCQADAQhnBQBVqi0BBRQACQADAQhnBQBVqi0BBRQAAA==.作甚务甚:AwACCAQABRQDCgAIAQg6EABQaGICBAoACgAIAQg6EABQaGICBAoACwABAQg4bgAsSUQABAoAAA==.',['�']='偏向虎山行:AwABCAEABAoAAA==.',['�']='元夕:AwAECAQABRQAAQwAPIYGCAQABRQ=.',['�']='刺猬爱蜗牛:AwAICAgABAoAAA==.',['�']='北方哈士奇:AwAICAYABAoAAA==.',['�']='南影倾寒:AwABCAIABRQAAA==.卡伊落斯:AwAFCAUABAoAAA==.',['�']='启明星的指引:AwADCAMABRQAAA==.',['�']='咕噜咕噜滚:AwACCAIABAoAAA==.',['�']='哇哦打的不错:AwABCAEABAoAAA==.',['�']='啊对対対:AwAECAQABAoAAA==.',['�']='喜力:AwAGCAQABRQAAA==.喜爱姐姐:AwAGCAYABAoAAA==.',['�']='土老帽:AwAFCAUABAoAAA==.圣光忽悠我:AwAICAgABAoAAA==.圣光杀非珑:AwAECAQABRQAAA==.圣园未花:AwAICAkABAoAAA==.在宇宙中歌唱:AwAECAgABRQDBAAEAQjECAAhMKoABRQAAwAEAQjfFAAfMtwABRQABAAEAQjECAAe1qoABRQAAQ0AWZcGCBkABRQ=.',['�']='坚毅如风:AwABCAEABRQCDgAGAQgoogAw1i0BBAoADgAGAQgoogAw1i0BBAoAAA==.',['�']='夏无蝉:AwAECAcABRQCCAAEAQh/EQBK+vsABRQACAAEAQh/EQBK+vsABRQAAA==.大凶熊:AwAECAIABRQAAA==.大劈叉:AwABCAEABRQCDgAIAQiJBgBhKv4CBAoADgAIAQiJBgBhKv4CBAoAAA==.大雪花儿:AwABCAEABRQAAA==.天使之赐:AwAICAgABAoAAA==.天哪您可真高:AwAECAQABAoAAA==.',['�']='奈何花落:AwAECAQABRQAAA==.奶妈真好玩:AwADCAgABRQEBQADAQiRFABKV5YABRQABQACAQiRFABB2pYABRQADwABAQjdFgBbUGwABRQADAABAQjWIgAVlz4ABRQAAA==.',['�']='孙一诺的基友:AwAICBAABAoAAA==.',['�']='宝贝小颖:AwAGCAYABAoAAA==.',['�']='小宁宁:AwAECAUABAoAAA==.小小萱萱:AwAFCAUABAoAAA==.小心心安安:AwACCAIABAoAAA==.小浪蹄子:AwADCAMABAoAAA==.小葱花:AwAICA4ABAoAAA==.',['�']='巨大的菊:AwAGCAgABAoAAA==.',['�']='希丶:AwACCAIABRQAAA==.',['�']='废废:AwAGCBAABAoAAA==.',['�']='弓弦叶:AwABCAEABAoAAA==.张三美丽:AwADCAMABAoAAA==.',['�']='影子豆汁汁:AwAHCBkABAoCCAAHAQgOIABblGMCBAoACAAHAQgOIABblGMCBAoAAA==.',['�']='御馔津:AwACCAIABAoAAA==.',['�']='心雨成湖:AwAGCAcABAoAAA==.快乐星球:AwAGCBgABRQDCQAGAQjGAQAxpZUBBRQACQAGAQjGAQAxpZUBBRQAEAABAQhCIQABZyYABRQAAA==.',['�']='怎么又被冻了:AwACCAIABRQAAQUAMX0HCA0ABRQ=.',['�']='想慑都难:AwAICAwABAoAAA==.想戒都难:AwAICAgABAoAAA==.想死都难:AwADCAMABAoAAA==.',['�']='我是地狱:AwABCAEABRQCCgAIAQj1NQAxI44BBAoACgAIAQj1NQAxI44BBAoAAA==.我是大丑逼:AwABCAEABRQAAA==.我有神经稟丶:AwAECAQABAoAAA==.我要为了部落:AwABCAEABAoAAA==.戕丶格拉墨:AwAECAUABAoAAA==.',['�']='拉德季晨风:AwAICAgABAoAAA==.',['�']='无极元素:AwAECAYABRQCBgAEAQh6BQBIBvcABRQABgAEAQh6BQBIBvcABRQAAA==.',['�']='明镜止水:AwABCAEABAoAAA==.星屑幻想:AwACCAIABAoAAA==.春风细雨:AwABCAEABRQAAA==.是淳罡啊:AwAFCAYABAoAAA==.',['�']='暗影信仰:AwAGCAYABRQCEQAGAQhOAAAfeogBBRQAEQAGAQhOAAAfeogBBRQAAQEAAAAICAIABRQ=.暗歌:AwAGCAYABRQCEQAGAQh8AAAXMWsBBRQAEQAGAQh8AAAXMWsBBRQAAA==.暗黑冬瓜:AwAECAQABAoAAA==.',['�']='最佳主人:AwAICAgABAoAAA==.朴朴酱:AwADCAMABAoAAA==.',['�']='林荫:AwACCAIABAoAAA==.',['�']='桃悠悠丨樱:AwAECAgABAoAAA==.',['�']='椎名立希:AwADCAcABAoAAA==.',['�']='橙冠希:AwAECAQABAoAAA==.',['�']='欠她的太多了:AwAFCAUABAoAAA==.',['�']='毛绒小豆:AwADCAMABAoAAA==.',['�']='沦为神:AwAICAYABAoAAA==.',['�']='泷汐澜:AwACCAIABAoAAA==.',['�']='流云若水:AwAFCAgABAoAAA==.浅沐:AwAICBgABAoCDwAIAQjNAABgAf8CBAoADwAIAQjNAABgAf8CBAoAAA==.浮尘飘洒:AwAICAgABAoAAA==.',['�']='淡淡月光:AwACCAIABAoAAA==.',['�']='湖光山色:AwAICAgABAoAAA==.',['�']='火灬光:AwACCAIABRQAAA==.',['�']='牛牛向前冲:AwAECAQABRQAAA==.',['�']='狂澜:AwABCAEABRQAAA==.',['�']='猎魔者寇丹:AwAICAgABAoAAA==.',['�']='玛格丽特牙花:AwACCAIABRQAAA==.玛沙绿意之触:AwAGCAcABRQCEgAFAQiWAgA/gYgBBRQAEgAFAQiWAgA/gYgBBRQAAA==.',['�']='珊珊丶:AwAICAgABAoAAA==.',['�']='瓦里安蒙斯克:AwACCAIABAoAAA==.',['�']='电臀德:AwAGCAYABAoAAA==.',['�']='疯狂的糖罐:AwAICAgABAoAAA==.',['�']='白銫芒果:AwAFCAUABAoAAA==.白鹤亮翅:AwAGCA8ABAoAAA==.',['�']='真诚的双眸:AwAGCAYABAoAAA==.',['�']='碧玉刀:AwAGCAsABAoAAA==.',['�']='祎然宝宝:AwADCAUABAoAAA==.神恩警长:AwAFCAcABAoAAA==.神机营长:AwAICAwABAoAAA==.神父:AwACCAIABAoAAA==.神骑侍:AwAGCAcABAoAAA==.',['�']='秋雾里:AwAICA0ABAoAAA==.',['�']='米僧:AwADCAgABRQCDQADAQiqCwActcwABRQADQADAQiqCwActcwABRQAAA==.米饭拌骨灰:AwADCAIABAoAAA==.',['�']='粽子君:AwAICBoABAoDDgAIAQhOXQA7SscBBAoADgAHAQhOXQBEQscBBAoAEwABAQh/YwAFdgYABAoAAA==.',['�']='糖果给你一颗:AwACCAMABRQAAA==.糖糖很听话:AwADCAMABAoAAQ4AJ8oDCAgABRQ=.',['�']='维多利雅:AwAECAQABAoAAA==.维罗尼卡:AwAECAQABRQAAQUAQRUGCAYABRQ=.',['�']='罗萨莱斯:AwAECAQABRQAAA==.',['�']='羊羊村村长:AwAECAgABAoAAA==.美国的华莱士:AwAICBQABAoCCQAIAQj9NAAwqr8BBAoACQAIAQj9NAAwqr8BBAoAAA==.',['�']='翻滾吧烏鴉:AwAECAQABAoAAA==.',['�']='聰明的一休:AwAICAgABAoAAA==.',['�']='般若:AwAICAkABAoAAQIAQ3sGCAUABRQ=.',['�']='芸芝:AwABCAEABRQAAA==.',['�']='若不是遇见你:AwAECAQABRQAAA==.若叶牧:AwAHCAcABAoAAA==.苦笑面对世界:AwAECAQABRQAAA==.',['�']='萌月小主:AwABCAEABRQEFAAGAQioMwAwZiYBBAoAFAAGAQioMwAwZiYBBAoAFQACAQgQGgAPiUAABAoACAABAQjh/AAE3xwABAoAAA==.落入你的眼睛:AwAECAgABRQCFgAEAQg7AgA5DvAABRQAFgAEAQg7AgA5DvAABRQAAA==.',['�']='蔚蓝珊瑚海:AwAHCA0ABAoAAA==.',['�']='覀酒:AwAICBAABAoAAA==.',['�']='豌豆芽:AwABCAEABAoAAQEAAAAICBIABAo=.',['�']='贝莉娜:AwAGCAEABRQAAA==.',['�']='走马行酒:AwAICAgABAoAAA==.',['�']='跃迁引擎启动:AwAGCAMABRQCFgADAQgWAwApTNUABRQAFgADAQgWAwApTNUABRQAAA==.',['�']='辞霜生:AwADCAsABRQDFgADAQiLAABfX0sBBRQAFgADAQiLAABfX0sBBRQAFwABAQg5HAAXPTEABRQAAA==.',['�']='邻居灬老刘:AwACCAIABAoAAA==.',['�']='雷殇魂:AwAGCAIABRQAAA==.',['�']='霜天之织:AwAICAgABAoAAA==.霜生:AwADCAMABAoAAA==.露娜切露德:AwAFCAUABAoAAA==.霸王茶鸡:AwAGCAYABAoAAA==.',['�']='青椒啊青椒:AwADCAgABRQCDgADAQjQGgAnyuUABRQADgADAQjQGgAnyuUABRQAAA==.静静的蓝孩纸:AwAFCAcABAoAAA==.',['�']='風雪夜歸人:AwADCAgABRQCGAADAQgtFAAd3bkABRQAGAADAQgtFAAd3bkABRQAAA==.',['�']='飘渺的幽灵:AwADCAMABAoAAA==.飘雨追风:AwAGCAYABAoAAA==.飞凤传玉:AwAECAQABAoAAA==.飞梦小枫猪:AwAFCAUABAoAAA==.',['�']='馨风之舞:AwAECAQABAoAAA==.',['�']='高小琴:AwABCAMABRQAAA==.',['�']='魔女:AwABCAEABRQAAA==.魔神坛斗士:AwAECAQABAoAAA==.魔鬼代言人:AwABCAEABAoAAA==.',['�']='鱼帅英俊:AwAECAQABRQAAA==.',['�']='黑蜗壳:AwAECAQABRQAARAAOkwGCAUABRQ=.默而识之:AwAGCAgABRQDCQAEAQgjEgAtDeQABRQACQAEAQgjEgAtDeQABRQAEAABAQiUIQAA+iEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end