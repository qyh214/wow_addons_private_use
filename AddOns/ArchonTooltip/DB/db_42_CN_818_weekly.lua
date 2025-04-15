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
 local lookup = {'Warrior-Arms','Warrior-Fury','Rogue-Assassination','Mage-Fire','Mage-Frost','Priest-Discipline','Warrior-Protection','DeathKnight-Unholy','Druid-Balance','DemonHunter-Havoc','DeathKnight-Blood','Shaman-Restoration','Shaman-Elemental','Unknown-Unknown','Shaman-Enhancement','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Druid-Guardian','Monk-Brewmaster','Paladin-Holy','DemonHunter-Vengeance','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Monk-Windwalker','Monk-Mistweaver','Priest-Shadow','Paladin-Retribution',}; local provider = {region='CN',realm='萨菲隆',name='CN',type='weekly',zone=42,date='2025-04-15',data={An='Antinoame:AwABCAEABRQAAA==.',Ch='Cherryswish:AwAECAQABRQAAA==.Chris:AwAECAQABRQAAA==.',De='Denfender:AwADCAoABRQDAQADAQgwCgBE2q4ABRQAAQACAQgwCgBCkq4ABRQAAgABAQhUHwBJa14ABRQAAA==.',Er='Erevus:AwAICCEABAoCAwAIAQjWEQBOfO0BBAoAAwAIAQjWEQBOfO0BBAoAAA==.',Ez='Eziod:AwADCAMABRQAAA==.',Fo='Foggyblood:AwACCAQABRQDBAAIAQiBKgA4iu4BBAoABAAIAQiBKgA4H+4BBAoABQAEAQjhYQAp+b8ABAoAAA==.',Gi='Gimme:AwAECAgABRQCBgAEAQjRBwBJqwIBBRQABgAEAQjRBwBJqwIBBRQAAA==.',Ji='Jiantan:AwABCAEABAoAAA==.',Lu='Lustasmodeus:AwAFCAUABAoAAA==.',Ma='Marsleo:AwAGCAgABAoAAA==.',Mo='Mojitoo:AwAGCAYABAoAAA==.Mordor:AwAICAsABAoAAA==.',Mt='Mtgo:AwABCAEABAoAAA==.',Ni='Nineteen:AwAECAgABRQDBwAEAQh6AgBBtu4ABRQABwAEAQh6AgBBtu4ABRQAAgAEAQguEAAhcegABRQAAA==.',Ri='Rich:AwAECAQABAoAAA==.',Sc='Schwinger:AwAECAQABRQAAA==.',Tr='Tracy:AwABCAEABRQAAA==.Trumpets:AwACCAIABAoAAA==.',Wh='Whitered:AwACCAQABRQAAA==.',Xi='Xihah:AwAHCAcABAoAAA==.',['�']='一悠悠一:AwAECAcABAoAAA==.一时无两:AwABCAEABRQAAA==.一根淀粉肠:AwAECAcABRQCCAAEAQifBwBIKg4BBRQACAAEAQifBwBIKg4BBRQAAA==.一顾丶倾城:AwAICAgABAoAAA==.丁度巴拉斯:AwACCAMABRQAAQkANzwECAkABRQ=.三丶小丶姐:AwAICAgABAoAAA==.不熬夜:AwAICAgABAoAAA==.不知火:AwAICB0ABAoDBAAIAQiXCABZ2MgCBAoABAAIAQiXCABZ2MgCBAoABQACAQiwegBZJH8ABAoAAA==.丑的有特点:AwAGCAYABAoAAA==.且听丨风吟:AwAECAQABRQAAA==.丞相:AwABCAEABAoAAA==.丨圣德太子丨:AwAICA8ABAoAAA==.丨小丶贝丨:AwAICAgABAoAAA==.',['�']='九条贵利矢:AwACCAUABRQCCgACAQgQHwAz0ZcABRQACgACAQgQHwAz0ZcABRQAAA==.',['�']='云岚:AwAGCAQABRQAAA==.亦叶丈牧:AwABCAEABAoAAA==.人中极品:AwAECAQABAoAAA==.',['�']='介个就是爱情:AwAICAoABRQCCwAIAQiVBwApkvgABRQACwAIAQiVBwApkvgABRQAAA==.从不辜负女人:AwAICAwABAoAAA==.仰望圣光:AwAECAQABRQAAA==.',['�']='佐手一牵右手:AwAICBIABAoAAA==.佑手一牵左手:AwAECAYABRQCDAAEAQibCgBDQ/YABRQADAAEAQibCgBDQ/YABRQAAQwAL2AGCAYABRQ=.佛珠沙加:AwAECAQABRQAAA==.你哪儿错了:AwACCAIABRQAAA==.你看帅不:AwADCAEABAoAAA==.',['�']='元素之魂:AwABCAEABAoAAA==.光明淡定牛:AwACCAQABRQDDQAIAQj0MAAaIFQBBAoADQAIAQj0MAAaIFQBBAoADAAIAQjJSQAdKEIBBAoAAA==.光辉光辉重生:AwADCAIABAoAAA==.',['�']='内个惩戒骑:AwAECAQABAoAAA==.再回到从前:AwAICAoABAoAAA==.',['�']='刘奈奈:AwADCAEABAoAAA==.别摸尾巴:AwAICAIABAoAAA==.',['�']='努力小子:AwAHCAgABAoAAA==.',['�']='勇敢牛汼:AwABCAEABAoAAA==.',['�']='北京丶法爷:AwAECAQABAoAAA==.',['�']='千羽圣堂:AwAGCAYABAoAAA==.千羽葳葳壹号:AwAFCAYABAoAAA==.千贺丶:AwAGCAYABAoAAA==.午灵丶艾斯娜:AwACCAIABAoAAQ4AAAAGCAQABRQ=.半生缘:AwADCAMABAoAAA==.华笙:AwAHCA8ABAoAAA==.华笙的骑士:AwABCAEABAoAAA==.单刀流:AwAECAQABAoAAA==.卖萌的酱油君:AwACCAQABRQAAQkASBUGCBAABRQ=.卡多瑞:AwADCAMABAoAAA==.',['�']='双树下的妖果:AwADCAMABAoAAA==.发展改革:AwADCAMABAoAAA==.',['�']='各种杀戮:AwADCAEABRQAAA==.吉吉怡怡:AwAGCAcABAoAAA==.名剑丶:AwAHCAsABAoAAQkAVtkGCAcABRQ=.向奈尔:AwAGCAoABAoAAA==.',['�']='咚東冬咚:AwAGCAwABRQDDAAGAQhyBwBB+Q0BBRQADAAEAQhyBwBIHw0BBRQADwACAQgrDAAg97MABRQAAA==.',['�']='哈库娜玛塔塔:AwAECAQABRQAAA==.',['�']='啊炳:AwAICAwABAoAAQcANDYCCAMABRQ=.',['�']='团长让我来:AwAICAgABAoAAA==.',['�']='圣光乌瑟尔:AwAGCAYABAoAAA==.',['�']='壮烈成仁丨:AwABCAEABRQAAA==.',['�']='夜丶疯魔灬:AwAICCcABAoEEAAIAQhWFwAi4YwBBAoAEAAIAQhWFwAiiowBBAoAEQADAQjNLQATDnwABAoAEgACAQi0pQATBykABAoAAA==.大地奶妈:AwAECAQABRQAAA==.大神德的小牛:AwAECAQABRQAAA==.大表哥:AwABCAEABAoAAA==.大西几:AwACCAUABRQCEwACAQgVBAAUXlgABRQAEwACAQgVBAAUXlgABRQAARQAIYEDCAUABRQ=.大雷波波:AwACCAIABRQAAA==.天天不吃饭:AwAFCAEABRQCAQABAQgDEABZGmoABRQAAQABAQgDEABZGmoABRQAAA==.天师:AwAGCAYABAoAAA==.天生就是爆:AwACCAcABRQCAgACAQiLFwA9IqMABRQAAgACAQiLFwA9IqMABRQAAA==.',['�']='奥利奥扭不开:AwAECAQABRQAAA==.女娃爱男娃:AwACCAIABAoAAA==.',['�']='妮可尼克:AwABCAEABRQCDAAIAQhIPQAoXnEBBAoADAAIAQhIPQAoXnEBBAoAAA==.',['�']='守鶴楓:AwAICAMABAoAAA==.',['�']='密州出猎:AwACCAIABAoAAA==.寕宁儜:AwAECAUABRQCCwAEAQhnDQAtw7cABRQACwAEAQhnDQAtw7cABRQAAA==.',['�']='小丶少爺灬:AwABCAEABRQAAA==.小小发丝:AwAECAYABRQDBQAEAQjUBABPBwEBBRQABQAEAQjUBABPBwEBBRQABAACAQiuJQBAIZoABRQAAA==.小枫丶风行者:AwACCAcABRQCFQACAQjuBQBjW+IABRQAFQACAQjuBQBjW+IABRQAAA==.小红手半夏丶:AwACCAIABAoAAA==.',['�']='巫毒晴天:AwAGCA4ABRQCCgAGAQi+AQA1gLwBBRQACgAGAQi+AQA1gLwBBRQAAA==.',['�']='幸运的奥伯伦:AwACCAcABRQCFgACAQgfDAAxnYQABRQAFgACAQgfDAAxnYQABRQAAA==.',['�']='库靼:AwABCAEABRQAAA==.',['�']='彪彪必达:AwAICAgABAoAAA==.影魔必须死:AwAGCAcABRQCBAAGAQiHAwA0UKwBBRQABAAGAQiHAwA0UKwBBRQAAQQAQ8QICAcABRQ=.彼岸花开似海:AwAICAkABAoAAA==.',['�']='忆随风:AwABCAIABRQAAA==.忍不住:AwACCAUABRQDFwACAQgBMwAPDHMABRQAFwACAQgBMwAPDHMABRQAGAABAQjrIQAM4isABRQAAA==.快乐牛仔:AwAGCAYABAoAAA==.',['�']='成长生命幸福:AwAHCAwABAoAAA==.我不挑食:AwAHCAcABAoAAA==.我变你猜:AwAICAoABAoAAA==.我爱吃泡面:AwAICBsABAoCCQAIAQjyHQBGPT0CBAoACQAIAQjyHQBGPT0CBAoAAA==.',['�']='找不着北:AwAICCIABAoCGQAIAQh2AwBbWMkCBAoAGQAIAQh2AwBbWMkCBAoAAA==.',['�']='拽拽的花生:AwAECAQABRQAAA==.',['�']='放个二踢脚:AwAGCAYABAoAAA==.放學別走:AwAGCAkABRQDGAAGAQiBAABD9KQBBRQAGAAGAQiBAAA24qQBBRQAFwADAQjQGgBgvNUABRQAAA==.放學別跑:AwAECAEABRQDGgAIAQi1JwAkd4UBBAoAGgAIAQi1JwAkd4UBBAoAGwAFAQgXbAAKJnwABAoAARgAQ/QGCAkABRQ=.',['�']='无望蜒:AwACCAUABRQCGwACAQggFQBJlbEABRQAGwACAQggFQBJlbEABRQAAA==.无望言:AwACCAIABRQAAA==.',['�']='星吟幻梦:AwAECAYABRQDCgAEAQhAEAAzYO4ABRQACgAEAQhAEAAzYO4ABRQAFgACAQgTDQAse30ABRQAAA==.',['�']='晓娘子:AwACCAIABRQAAA==.晚晴:AwACCAMABRQCBwAIAQicDQA0NrUBBAoABwAIAQicDQA0NrUBBAoAAA==.',['�']='暗夜潜行者:AwAHCAkABAoAAA==.暗暗重生:AwADCAUABRQCFAACAQhdBgAhgWsABRQAFAACAQhdBgAhgWsABRQAAA==.暮光灬羞涩:AwAFCAUABAoAAA==.',['�']='曾曾的大爸:AwABCAIABRQAAA==.',['�']='月光如盐丶:AwAHCA8ABAoAAA==.有才哥:AwACCAQABRQAAA==.有才姐:AwAECAQABAoAAA==.有点味儿:AwACCAYABRQDHAACAQjWGAAqxXkABRQAHAACAQjWGAAqxXkABRQABgACAQiSGwAMGG4ABRQAAA==.本地游戏:AwAICAgABAoAAA==.',['�']='杜隆塔爾壹哥:AwABCAEABRQCHQAIAQiDUAA5MucBBAoAHQAIAQiDUAA5MucBBAoAAA==.来抓我:AwACCAIABRQAAA==.',['�']='果粒橙:AwAECAQABRQAAA==.',['�']='柯德:AwAECAgABRQCCgAEAQjWDABIrf4ABRQACgAEAQjWDABIrf4ABRQAAA==.',['�']='欧丶啦:AwADCAMABAoAAA==.欧洲橙椎椎:AwAICBQABAoCFwAIAQgOVAA695UBBAoAFwAIAQgOVAA695UBBAoAAA==.欧皇白学家:AwACCAMABRQAAA==.欧阳成枫:AwAFCAUABAoAAA==.欧阳毛毛:AwAFCAUABAoAAA==.欲买桂花载酒:AwAFCAIABAoAAA==.',['�']='歐帝:AwAECAUABAoAAA==.',['�']='毁灭我吧:AwACCAMABRQAAA==.',['�']='氪金小胖几:AwAFCAUABAoAAA==.',['�']='没影遁咋玩啊:AwAHCAcABAoAAA==.',['�']='活死人四:AwACCAcABRQCGQACAQjdDQBSTqsABRQAGQACAQjdDQBSTqsABRQAAA==.',['�']='浪花亿朵朵:AwACCAIABAoAAA==.',['�']='消失的光芒:AwAGCAcABAoAAA==.',['�']='深情必坠死海:AwAHCAcABAoAAA==.',['�']='游我误你:AwAECAUABAoAAA==.',['�']='湖人:AwAFCAUABAoAAA==.',['�']='漟主:AwACCAIABRQCDAAIAQigBABfaswCBAoADAAIAQigBABfaswCBAoAAA==.',['�']='潘森:AwAECAYABRQDGAAEAQjtBQBTDgABBRQAGAAEAQjtBQBTDgABBRQAFwACAQhSLABEDYsABRQAAQ4AAAAICAQABRQ=.',['�']='激战沙巴克:AwAICAgABAoAAA==.',['�']='火不高兴:AwACCAIABRQAAA==.',['�']='焱月冷钢:AwAICAwABAoAAA==.',['�']='熊吉吉:AwACCAIABAoAAA==.',['�']='爱的双氧水:AwAECAkABRQCCQAEAQhDEAA3POwABRQACQAEAQhDEAA3POwABRQAAA==.爱的嘤嘤:AwAECAQABRQAAA==.',['�']='狂飈的蜗牛:AwAGCA0ABRQCCgAGAQi1AABOmAcCBRQACgAGAQi1AABOmAcCBRQAAA==.独步天下:AwACCAIABAoAAA==.',['�']='猝死而亡:AwADCAMABAoAAA==.',['�']='瓦尒基里:AwACCAIABRQAAA==.',['�']='电竞李寻欢丶:AwAGCAYABAoAAA==.',['�']='皇家大厨电鳗:AwAICAgABAoAAA==.',['�']='碧波行者:AwACCAIABAoAAA==.',['�']='祝您早生贵子:AwABCAIABRQCHQAIAQi9EQBdcsUCBAoAHQAIAQi9EQBdcsUCBAoAAA==.',['�']='稚茗千初:AwAICAsABAoAAA==.',['�']='笑看丨浮生:AwACCAQABRQDGAAIAQibBwBcX5cCBAoAGAAIAQibBwBRLJcCBAoAFwAHAQiJVABMipMBBAoAAA==.笨小絯:AwAECAQABRQAAA==.',['�']='等到那一天:AwACCAIABRQAAA==.',['�']='精致小女人:AwAGCAoABAoAAA==.',['�']='素月墨羽:AwAICAYABAoAAQ4AAAAECAQABRQ=.',['�']='终极鸽子大王:AwACCAQABAoAAA==.绫灯水月:AwACCAEABAoAAA==.',['�']='罄竹:AwACCAcABRQCCAACAQg2FABUqLkABRQACAACAQg2FABUqLkABRQAAA==.罗辑:AwAECAQABRQAAQQAMkEGCAgABRQ=.',['�']='翻滚吧小宇宙:AwADCAMABAoAAA==.',['�']='老汉牵着牛:AwAGCAIABRQAAA==.',['�']='职业:AwAICA0ABAoAAA==.',['�']='腿不高兴:AwACCAQABRQAAA==.',['�']='艾露莎陛下:AwACCAUABRQCHQACAQg1LgAyq5IABRQAHQACAQg1LgAyq5IABRQAAA==.',['�']='花翎:AwAFCAUABAoAAA==.',['�']='苍月冰霜:AwADCAMABAoAAA==.苗老祖:AwAGCAsABAoAAA==.',['�']='荭阿荭阿:AwAGCAIABRQCEQACAQjCEwBaN2QABRQAEQACAQjCEwBaN2QABRQAAA==.',['�']='莫慢待:AwAECAQABRQAAA==.莫相离:AwACCAUABRQCHQACAQjtLwAwUo4ABRQAHQACAQjtLwAwUo4ABRQAAA==.',['�']='萌萌的水香:AwAICAkABAoAAA==.',['�']='蒙面鸽王:AwACCAQABRQAAA==.',['�']='蓝丶田:AwAGCAkABRQDGwAGAQicCwAolPQABRQAGwAFAQicCwAvsPQABRQAGgACAQhPDQAkL7IABRQAAA==.蓝博:AwADCAMABAoAAA==.蓝灬田:AwAGCAYABRQCCgACAQiuIQAosowABRQACgACAQiuIQAosowABRQAAQ4AAAAICAIABRQ=.蓝田丶:AwAECAIABRQAAA==.',['�']='虎子喝凉的:AwAGCAoABAoAAA==.',['�']='蟹老闆的死騎:AwAICAgABAoAAA==.',['�']='装修扰民:AwAICA0ABAoAAA==.',['�']='西索:AwAECAgABRQDFwAEAQhABwBcSDMBBRQAFwAEAQhABwBcSDMBBRQAGAACAQiMFwAxa2wABRQAARcATFUICAwABRQ=.',['�']='解放巴嘞斯坦:AwADCAMABAoAAA==.',['�']='言周孝文瑡:AwAICAwABAoAAA==.許願的魔瓶:AwAICAcABAoAAA==.',['�']='诸葛白:AwABCAEABRQCFwAIAQj2FwBQYowCBAoAFwAIAQj2FwBQYowCBAoAAA==.',['�']='谦虚市民:AwAICAgABAoAAA==.',['�']='路西法丶晨星:AwABCAEABRQAAA==.',['�']='辰丶冰封灬:AwAHCA8ABAoAAA==.辻柒:AwAICAgABAoAAA==.',['�']='迅猛的牛牛:AwAECAQABRQAAA==.',['�']='铁块:AwAECAgABRQCAgAEAQguBABTrToBBRQAAgAEAQguBABTrToBBRQAAQEAN/gGCAoABRQ=.',['�']='阴邪:AwAFCAkABRQCAwAFAQjKAQA7nHcBBRQAAwAFAQjKAQA7nHcBBRQAAA==.阿啾:AwACCAIABAoAAA==.阿萨姆:AwAECAYABAoAAA==.',['�']='陌雪:AwACCAcABRQCCgACAQgUJAAaFoIABRQACgACAQgUJAAaFoIABRQAAA==.',['�']='雨天里变身:AwEBCAEABRQAAQ4AAAAICAMABRQ=.',['�']='青年艺术家:AwACCAIABRQAAA==.',['�']='领地爆壳蟹:AwAICAgABAoAAA==.',['�']='风影:AwAGCAYABAoAAA==.飒飒南风:AwAGCAIABAoAAA==.',['�']='马拉丁达:AwACCAQABRQCCQAIAQgKEABVOJgCBAoACQAIAQgKEABVOJgCBAoAAA==.',['�']='魔方:AwACCAcABRQDEgACAQjqFwBCNJ0ABRQAEgACAQjqFwBCNJ0ABRQAEAABAQifEQAvbUsABRQAAA==.',['�']='鱼欲遇雨:AwAECAQABRQAAA==.',['�']='黄胶鞋七分裤:AwAICAgABAoAAA==.黎明的星星:AwACCAMABRQAAA==.黑镜无限:AwAICAkABAoAAA==.默默无闻:AwADCAkABRQCHQADAQipHwAgMdEABRQAHQADAQipHwAgMdEABRQAAA==.',['�']='龙珠丶悟空:AwAICBAABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end