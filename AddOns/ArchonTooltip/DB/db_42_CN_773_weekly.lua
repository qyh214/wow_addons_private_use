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
 local lookup = {'Warlock-Demonology','Warlock-Destruction','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Evoker-Devastation','DemonHunter-Havoc','Druid-Balance','Druid-Restoration','Unknown-Unknown','Paladin-Any','Warrior-Protection','Priest-Holy','Priest-Discipline','Monk-Windwalker','DeathKnight-Unholy','DeathKnight-Blood','Rogue-Assassination','Monk-Mistweaver','Warrior-Fury',}; local provider = {region='CN',realm='石爪峰',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ba='Babylikezz:AwACCAUABRQDAQACAQiBDAA0klMABRQAAQABAQiBDABA2VMABRQAAgABAQiCJQAoS0IABRQAAA==.',Bi='Bigorange:AwACCAIABRQAAA==.',Do='Domon:AwAECAQABRQAAA==.Doomss:AwAICAgABAoAAA==.',Dw='Dwake:AwACCAQABRQAAA==.',El='Electronic:AwAECAIABRQAAA==.',Gc='Gcherokee:AwAGCAoABRQDAwAGAQjuEAA1wPUABRQAAwAEAQjuEAAjEfUABRQABAAEAQiDEQBFIIoABRQAAA==.',Gu='Gundamharute:AwAHCA4ABAoAAA==.',Kb='Kbz:AwABCAEABAoAAA==.',La='Lamentinn:AwAICAgABAoAAA==.',Li='Liboo:AwAICAcABAoAAA==.',Lo='Loky:AwAGCAoABRQCBQAGAQhuAABGTu4BBRQABQAGAQhuAABGTu4BBRQAAQYAXZEICAwABRQ=.',Ma='Margarete:AwAICAgABAoAAA==.',Ne='Nevermind:AwAGCAYABRQCAgAGAQhGEgAdNLcABRQAAgAGAQhGEgAdNLcABRQAAA==.',No='Nong:AwABCAEABAoAAA==.',Sh='Shuke:AwAECAYABAoAAA==.',Wi='Windwalker:AwACCAIABRQAAA==.',['�']='一根都没有了:AwADCAUABRQCAwADAQjsGgAQQsEABRQAAwADAQjsGgAQQsEABRQAAA==.一粒优卡丹:AwACCAUABRQCBwACAQhTHAA3W5kABRQABwACAQhTHAA3W5kABRQAAA==.七宗罪:AwAFCAMABAoAAA==.丨丨口:AwAFCAUABAoAAA==.丨丨萨:AwABCAEABAoAAA==.丶刀枪炮:AwAICAgABAoAAA==.丶咪哚児:AwAGCA8ABAoAAA==.丶在下無情:AwAECAQABRQAAA==.丶尛尛枫:AwAECAQABRQAAA==.丶柳岩:AwAECAQABRQAAA==.丶陆叁玖捌柒:AwACCAIABAoAAA==.丷筱乄影:AwAECAcABAoAAA==.',['�']='乔小木:AwAICAgABAoAAA==.',['�']='五龙铡:AwAECAQABAoAAA==.亲闺女来也:AwAGCAkABAoAAA==.人品总至上:AwADCAEABRQAAA==.人熊鸡唲不短:AwAECAQABRQAAA==.',['�']='伊林:AwABCAEABRQAAA==.会爆炸的毛:AwABCAEABAoAAA==.',['�']='信仰咕咕不咯:AwAECAUABRQDCAAEAQjXHwAOjYAABRQACAADAQjXHwAVfoAABRQACQABAQiZHwAA4R8ABRQAAA==.信仰圣光不呢:AwAECAEABRQAAA==.俩大犄角:AwAICAcABAoAAA==.',['�']='冥影:AwABCAIABRQAAA==.',['�']='劍無惜:AwADCAYABRQCBQADAQhcFgArx+oABRQABQADAQhcFgArx+oABRQAAQoAAAAICAMABRQ=.',['�']='勇敢的贝塔:AwACCAIABRQAAA==.',['�']='包豪斯:AwACCAIABRQAAA==.',['�']='午夜的花裤衩:AwAICA0ABAoAAA==.单色冰激凌:AwADCAMABRQAAA==.卡罗琳丶圣歌:AwAICA4ABAoAAA==.',['�']='变形战神金刚:AwABCAEABRQAAA==.台河大老李:AwAICAUABAoAAA==.',['�']='君甚吊:AwAFCAUABAoAAA==.吾朋贼孙子也:AwAFCAMABRQAAQsANLAGCAYABRQ=.',['�']='咆哮的帕拉丁:AwAECAYABRQCBQAEAQiuHAAoetAABRQABQAEAQiuHAAoetAABRQAAA==.',['�']='啊姆斯特朗炮:AwAECAkABRQCAwAEAQh+EgA6H+8ABRQAAwAEAQh+EgA6H+8ABRQAAA==.',['�']='喵喵光骑士:AwAECAQABRQAAQMASuEGCAgABRQ=.',['�']='国大宝:AwACCAIABAoAAA==.',['�']='圣光不加血:AwAECAQABAoAAA==.圣光裁决着:AwACCAIABAoAAA==.',['�']='墨尤奈:AwAECAYABRQCBQAEAQijEwA7XPMABRQABQAEAQijEwA7XPMABRQAAA==.墨染瑬雲:AwAECAQABRQAAA==.',['�']='夜光喵:AwAGCAgABAoAAA==.夜宵呢:AwACCAEABAoAAA==.夜樱明綉:AwAECAgABRQCDAAEAQhYBAAeAK0ABRQADAAEAQhYBAAeAK0ABRQAAA==.夜羽赤枫:AwAICAgABAoAAA==.夢魇追獵者丶:AwAICAgABAoAAA==.天野远子:AwAGCBYABRQCBQAGAQgxAABXcRQCBRQABQAGAQgxAABXcRQCBRQAAA==.',['�']='奶丶爹:AwAHCAEABAoAAA==.',['�']='妙妙喵:AwAICAkABAoAAA==.',['�']='娜仁:AwAICBMABAoAAA==.',['�']='孤星浪子:AwACCAIABRQAAA==.',['�']='守护丶平衡:AwAICIkBBAoCCQAIAQgyBQBctK0CBAoACQAIAQgyBQBctK0CBAoAAA==.',['�']='小奶包:AwAHCAMABAoAAA==.小小河豚:AwAECAQABRQAAA==.小小牧猫猫:AwAECAgABRQDDQAEAQiVCgAlaMMABRQADQAEAQiVCgAca8MABRQADgAEAQglDgAYsr8ABRQAAA==.小猎猫猫:AwAFCAUABRQDAwAFAQgkFAA6H+kABRQAAwADAQgkFAAuaOkABRQABAACAQi2FABdQm0ABRQAAA==.小玉米:AwADCAUABAoAAA==.尐烂鱼:AwAECAQABRQAAQUAKaQHCAgABRQ=.',['�']='崛起吧土元素:AwAGCA0ABAoAAA==.',['�']='巴衞:AwACCAIABRQAAA==.',['�']='帅小僧:AwAFCAcABAoAAA==.',['�']='幻一樂:AwACCAMABRQAAA==.',['�']='弹弹乐:AwAGCAYABRQCDwAGAQjVAABAduEBBRQADwAGAQjVAABAduEBBRQAAA==.',['�']='我的旋律:AwACCAIABRQAAA==.战争领主挽歌:AwAECAQABRQAARAASVsFCAUABRQ=.战斗爽:AwAICAwABAoAAA==.',['�']='托尼不带水:AwABCAIABRQAAA==.',['�']='挥刀的厚老板:AwAICAgABAoAAA==.',['�']='掂掂低低:AwAICAgABAoAAA==.',['�']='摩摩利尔:AwAECAYABAoAAA==.',['�']='无敌罗圈胸肌:AwABCAEABAoAAA==.日央:AwAECAQABRQAAA==.旺仔牛马:AwADCAMABAoAAA==.',['�']='暴力沟通:AwAECAQABRQAAA==.暴躁白牛:AwAECAQABRQAAA==.',['�']='朔月:AwAECAQABRQAAA==.末日之光:AwAECAQABRQAAA==.末日圣手:AwAICAkABAoAAA==.末曰戰歌:AwAICAgABAoAAA==.',['�']='村大傻:AwACCAIABRQAAA==.',['�']='核心丶电能:AwAFCAoABAoAAA==.',['�']='欺诈者挽歌:AwAECAwABRQCBwAEAQiuBgBR4yMBBRQABwAEAQiuBgBR4yMBBRQAAA==.',['�']='正当撤退:AwAICBIABAoAAA==.',['�']='沐熙:AwAFCAQABAoAAA==.',['�']='浪漫乂尛尛:AwAECAQABAoAAA==.',['�']='満目皆星辰:AwAECAQABRQAAA==.',['�']='灬弖灬:AwAECAQABRQAAA==.灬阿苟灬:AwAGCAEABAoAAA==.灵魂丶绑匪:AwAGCAoABRQCEAAGAQjBAABAr8gBBRQAEAAGAQjBAABAr8gBBRQAAREAQCkICAUABRQ=.',['�']='狐莉:AwACCAIABAoAAA==.狮吼功:AwACCAEABAoAAA==.',['�']='王惊梦:AwAECAgABRQCEgAEAQjZBwAZJdsABRQAEgAEAQjZBwAZJdsABRQAAA==.王记饱饱:AwAICAIABAoAAA==.',['�']='珂珂奥义:AwAICAYABAoAAA==.',['�']='白眉影王:AwAICAEABAoAAA==.',['�']='皓月:AwAFCAEABRQAAA==.',['�']='目镖庶士:AwAICBYABAoDAQAIAQhkCABBYi4CBAoAAQAIAQhkCAA/4S4CBAoAAgAGAQhyUAAoNQQBBAoAAA==.',['�']='眼里有片海:AwAICAgABAoAAA==.',['�']='短腿跑得快:AwAECAMABRQAAA==.',['�']='碧昂丝:AwAGCAEABRQAAA==.',['�']='福禄寿喜财:AwABCAEABAoAAA==.',['�']='秋天的风:AwAICAgABAoAAQUAQjEGCAkABRQ=.',['�']='等我回个蓝:AwAECAgABRQCEwAEAQiSEQAZIsAABRQAEwAEAQiSEQAZIsAABRQAAQoAAAAGCAQABRQ=.',['�']='米鲁克大泽泽:AwAICAgABAoAAA==.',['�']='粉条丶:AwAICBIABAoAAA==.',['�']='糊糊涂涂:AwABCAEABRQCBQAIAQjVSAA/5fIBBAoABQAIAQjVSAA/5fIBBAoAAA==.糖渔猪寳:AwAECAQABRQCBQAIAQghMgBNKToCBAoABQAIAQghMgBNKToCBAoAAA==.',['�']='罪之优雅:AwAECAQABRQAAA==.',['�']='翘楚:AwAECAQABRQAAA==.',['�']='老钱帮:AwAGCAQABRQAAA==.耶比耶比耶:AwAICAcABAoAAA==.',['�']='节能主翼:AwAECAUABRQDCAAEAQgkFgA5MLsABRQACAADAQgkFgBR27sABRQACQABAQgjGAAvtUMABRQAAA==.',['�']='苍曜石:AwACCAIABRQAAA==.苏积:AwAECAUABRQDEQAEAQhbAwBa1jgBBRQAEQAEAQhbAwBa1jgBBRQAEAABAQhVJwABNSAABRQAAA==.苏酥蘇:AwAECAQABRQAAA==.',['�']='萌萌的火法:AwAICAgABAoAAA==.萌萌道哒:AwAECAgABRQDBAAEAQgSBQBH5QABBRQABAAEAQgSBQBH5QABBRQAAwAEAQhEFwAr9NsABRQAAQoAAAAICAIABRQ=.',['�']='蜻蜓队长:AwAECAYABRQCFAAEAQivDgAulOoABRQAFAAEAQivDgAulOoABRQAAA==.',['�']='费列罗巧克力:AwABCAEABRQCBgAIAQgdEgBMxA8CBAoABgAIAQgdEgBMxA8CBAoAAA==.',['�']='逆天改命:AwAECAQABAoAAA==.',['�']='那别打了:AwAGCAQABRQAAA==.邪剑龙煞:AwAGCA0ABAoAAA==.',['�']='醉了灬:AwADCAEABAoAAA==.',['�']='鈊迷离:AwAICAEABAoAAA==.',['�']='鋼之鍊釿术師:AwAECAQABAoAAA==.',['�']='铜锣湾抗把:AwABCAEABAoAAA==.',['�']='阿拉贡罗兰:AwAICAgABAoAAA==.',['�']='陆伊喜:AwAICAcABAoAAA==.',['�']='隔壁家老舅:AwABCAEABRQAAA==.',['�']='雾藤兰:AwACCAIABRQAAA==.',['�']='青眼白龙丶:AwAICA4ABAoAAA==.青谷:AwAICAEABAoAAA==.',['�']='韩墩墩:AwACCAIABRQAAA==.',['�']='风吹乃两边甩:AwAECAQABRQAAA==.',['�']='香辣黄花鱼:AwABCAEABAoAAA==.',['�']='魔玉:AwACCAQABRQDEQAIAQiZIQApv08BBAoAEQAIAQiZIQAoDE8BBAoAEAAFAQj3dwAcea0ABAoAAA==.',['�']='鱼肉包仔:AwAECAYABRQDBAAEAQipCgAsLNIABRQABAAEAQipCgAm4dIABRQAAwACAQgmKQAvJooABRQAAQMAShkGCA4ABRQ=.',['�']='麗香:AwAECAQABRQAAA==.',['�']='黛娅丶:AwAICAsABAoAAA==.',['�']='齐德隆咚镪:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end