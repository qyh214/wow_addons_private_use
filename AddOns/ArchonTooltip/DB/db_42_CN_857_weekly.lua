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
 local lookup = {'DeathKnight-Unholy','Priest-Holy','Priest-Discipline','Hunter-BeastMastery','Warlock-Destruction','Warlock-Affliction','Mage-Frost','Rogue-Assassination','DemonHunter-Havoc','Shaman-Enhancement','Shaman-Elemental','Shaman-Restoration','Paladin-Retribution','Druid-Guardian','Druid-Balance','Paladin-Holy','Mage-Fire','Evoker-Preservation','Evoker-Devastation','Unknown-Unknown','Rogue-Outlaw','Rogue-Subtlety','Monk-Brewmaster','Warrior-Protection','Hunter-Marksmanship','DeathKnight-Blood','Monk-Mistweaver','Monk-Windwalker','Druid-Restoration','Warlock-Demonology','DeathKnight-Frost','Warrior-Fury','Warrior-Arms',}; local provider = {region='CN',realm='银松森林',name='CN',type='weekly',zone=42,date='2025-04-15',data={Aa='Aasuka:AwAICAMABAoAAA==.',Ad='Aduntoridas:AwABCAMABRQCAQAIAQjdFgBND10CBAoAAQAIAQjdFgBND10CBAoAAA==.',Az='Azreally:AwAICAYABAoAAA==.',Ba='Bacon:AwABCAEABRQAAA==.Bambookill:AwAFCAYABAoAAA==.',Da='Darksaber:AwAECAUABAoAAA==.',Di='Diesirae:AwABCAMABRQDAgAIAQhLEgBLSCQCBAoAAgAIAQhLEgBLSCQCBAoAAwAFAQg5ZAAVbXUABAoAAA==.',El='Elisia:AwAFCAEABAoAAA==.',Fr='Frostiron:AwACCAIABAoAAA==.',Go='Goldwind:AwACCAEABAoAAA==.',Ic='Ice:AwAECAUABRQCAQAEAQh9DgAqk+UABRQAAQAEAQh9DgAqk+UABRQAAA==.',Im='Impossible:AwAECAQABAoAAA==.',Ix='Ixkxn:AwACCAMABRQAAA==.',Ke='Ken:AwADCAEABAoAAA==.',Kh='Khr:AwAGCAoABAoAAA==.',Kr='Krakatoa:AwAICAgABAoAAA==.',Ma='Maogehfghfyd:AwAICBgABAoCBAAIAQhMKABElT8CBAoABAAIAQhMKABElT8CBAoAAA==.',Me='Medlife:AwAHCAoABAoAAA==.',Mi='Minxu:AwADCAgABRQDBQADAQgsFgA7l6sABRQABQACAQgsFgBJ6asABRQABgACAQjkDwAhEZQABRQAAA==.',Po='Ponponpon:AwABCAIABRQCBwAIAQieGwBHXwsCBAoABwAIAQieGwBHXwsCBAoAAA==.',Qj='Qjpo:AwAECAgABAoAAA==.',Ra='Rayna:AwAECAQABAoAAA==.',Ro='Robot:AwABCAEABAoAAA==.',Sa='Saberwang:AwACCAMABRQAAA==.',Sh='Shoqky:AwAFCAMABAoAAA==.',Un='Untik:AwAECAQABRQAAA==.',Xx='Xxsrk:AwADCAMABAoAAA==.',Yo='Yosuke:AwAGCA4ABRQCCAAGAQgaAQAwsLUBBRQACAAGAQgaAQAwsLUBBRQAAA==.',['�']='一上去就嘎了:AwAECAgABRQCCQAEAQjIEAA4AuwABRQACQAEAQjIEAA4AuwABRQAAA==.一叶琳:AwAECAQABRQAAA==.一条小鲇鱼:AwAGCBIABRQECgAGAQjSAAA7Q9IBBRQACgAGAQjSAAA5HdIBBRQACwAEAQg7CQA14tQABRQADAAEAQixEgASjcoABRQAAA==.七星龙渊:AwABCAEABRQAAA==.万恶寅为首:AwAFCAIABAoAAA==.三鹿丨牛奶:AwAECAQABRQAAA==.不吃丶香菜:AwABCAEABRQAAA==.不悔:AwAICBsABAoCCQAIAQjeEQBR0Y4CBAoACQAIAQjeEQBR0Y4CBAoAAA==.不滅初心:AwADCAMABAoAAA==.专业烤嫩洋:AwAICBoABAoCDQAIAQgWVAA16t4BBAoADQAIAQgWVAA16t4BBAoAAA==.世一战:AwAGCAIABRQAAA==.丶小鬼:AwABCAIABRQDDgAIAQirCQA0hpcBBAoADgAIAQirCQA0hpcBBAoADwABAQjAsAAkyjAABAoAAA==.丶羽:AwABCAEABAoAAA==.丶雪碧:AwABCAEABAoAAA==.丹羽长秀:AwABCAEABAoAAA==.',['�']='之三四狼:AwADCAQABAoAAA==.',['�']='亀仙人丶:AwAFCAEABAoAAA==.二同:AwAECAgABRQCDQAEAQhBGgAvmucABRQADQAEAQhBGgAvmucABRQAAA==.五晨老白干:AwAICAgABAoAAA==.',['�']='伊莱克斯之刃:AwAECAYABAoAAA==.估计难打:AwACCAYABRQCBwACAQgAEAAl9oYABRQABwACAQgAEAAl9oYABRQAAA==.',['�']='你好丶宋杰:AwABCAEABRQCBQAHAQgkRQAlKzsBBAoABQAHAQgkRQAlKzsBBAoAAA==.你是对的:AwABCAEABAoAAA==.佳少:AwAGCAYABAoAAA==.',['�']='偶尔躲躲乌云:AwAGCAcABAoAAA==.',['�']='元首:AwAFCAEABAoAAA==.先生望北:AwACCAUABRQCBwACAQgGDABDWqEABRQABwACAQgGDABDWqEABRQAAA==.光铸宋慧乔:AwABCAIABRQAAA==.克兰纳德:AwAGCAoABRQDDQAGAQiDAgBEs3kBBRQADQAFAQiDAgBPcXkBBRQAEAAEAQg8BwAKi84ABRQAAA==.全团速度灭:AwAECAEABRQDEQAIAQhtFgBT12UCBAoAEQAIAQhtFgBP1mUCBAoABwAIAQi1GgBKHxECBAoAAA==.',['�']='冰封雪舞:AwAGCAYABAoAAA==.',['�']='刀刀烈火:AwAICAYABAoAAA==.划过天空的鑫:AwAECAoABRQCDAAEAQirCwA7T+8ABRQADAAEAQirCwA7T+8ABRQAAA==.刘波的龙傲天:AwABCAMABRQDEgAIAQiFEgAQnhcBBAoAEgAIAQiFEgAQnhcBBAoAEwABAQieVwAEnRkABAoAAA==.',['�']='剑天舞:AwAICA0ABAoAAA==.',['�']='北上南下:AwAICAgABAoAAQwAL0oGCAYABRQ=.',['�']='千里萌:AwAICAcABAoAAA==.卑鄙小紫人:AwAICAgABAoAAA==.',['�']='历战王摇曳鳗:AwAICBEABAoAAA==.原来啪啪哒:AwAECAEABRQAAA==.',['�']='古手川千莎:AwACCAIABRQAAA==.可德了吧:AwAICAgABAoAAA==.叶与星辰:AwAICA8ABAoAAA==.',['�']='吃货与饿梦:AwABCAIABRQCBAAIAQgVPwA/NN4BBAoABAAIAQgVPwA/NN4BBAoAAA==.',['�']='呐丶小惊雷:AwABCAEABRQAAA==.',['�']='咬他:AwABCAEABRQAAA==.咬你丫的:AwABCAMABRQCDwAIAQjeIwBHNhoCBAoADwAIAQjeIwBHNhoCBAoAAA==.',['�']='哈利路大旋风:AwABCAEABRQAAQcAR18BCAIABRQ=.',['�']='嗐嘿特勒:AwAICAgABAoAAA==.',['�']='囯家电网:AwAECAgABRQCCgAEAQglBABPICYBBRQACgAEAQglBABPICYBBRQAAA==.',['�']='土狗丸子:AwACCAIABRQAAA==.',['�']='坚挺的牛牛:AwABCAEABRQAAA==.',['�']='埃尔克的死骑:AwAECAQABRQAAA==.埃尔克的龙人:AwACCAMABRQAARQAAAAECAQABRQ=.',['�']='壺壺:AwABCAMABRQCDQAIAQjkSAA5zPwBBAoADQAIAQjkSAA5zPwBBAoAAA==.',['�']='夕阳夜影:AwABCAEABRQDCAAIAQj5EABBZfkBBAoACAAIAQj5EABBZfkBBAoAFQABAQhzGgAC0BAABAoAAA==.多大:AwAICA8ABAoAAA==.夜丶空星:AwADCAMABAoAAA==.大哥莂杀我:AwADCAMABAoAAA==.大姨妈甩马尾:AwADCAMABAoAAA==.天边丶:AwAICAEABAoAAA==.太一丶暗夜:AwAGCAYABAoAAA==.太子:AwAGCAgABRQDCAAGAQgAAgA5BmgBBRQACAAFAQgAAgBBf2gBBRQAFgABAQj5DQAXIV0ABRQAAA==.',['�']='奶奶要出来了:AwAICA8ABAoAAA==.好像在哪见妮:AwAICA0ABAoAAA==.',['�']='妙脆角斗士:AwAICAQABRQAAA==.',['�']='婷婷丶玉立:AwACCAEABAoAAA==.',['�']='安馨児:AwACCAIABRQAAA==.',['�']='寂寞的流星:AwADCAMABAoAAA==.密魔:AwAECAQABAoAAA==.寒烟柔:AwAHCAcABAoAAA==.',['�']='小奋:AwAFCAQABAoAAA==.小新的熊宝宝:AwACCAMABAoAARQAAAAHCAUABAo=.小科比肘妈妈:AwABCAMABRQAAA==.小红手掉线:AwAGCAEABRQCFwAIAQikCgAxe40BBAoAFwAIAQikCgAxe40BBAoAARgALyoICAoABRQ=.小麒麟:AwAHCAoABAoAAA==.就决定是你了:AwAGCAEABAoAAA==.',['�']='崔斯锭:AwADCAMABRQAAA==.',['�']='希尔达:AwAFCAkABAoAAA==.希望的挽歌:AwACCAUABRQCAQACAQhqFgBFMKkABRQAAQACAQhqFgBFMKkABRQAAA==.',['�']='幻月冰璃:AwAICBoABAoCBAAIAQijbgAaVEEBBAoABAAIAQijbgAaVEEBBAoAAA==.',['�']='弑神的玛奇朵:AwABCAEABAoAAA==.张大饼:AwAICAoABAoAAQUAYXsICAcABRQ=.张小邪:AwADCAMABAoAAA==.强效奥能排骨:AwAICAgABAoAAA==.',['�']='当你丷:AwACCAIABRQAAA==.影子小说家:AwAECAQABRQAAA==.',['�']='得人畏:AwADCAMABAoAAA==.微微玖:AwAICAgABAoAAA==.徳莉莎:AwAECAQABRQAAA==.德鲁贰:AwAFCAEABAoAAA==.',['�']='怡周冉:AwADCAQABRQAAA==.',['�']='恢复战:AwAHCAcABAoAAA==.',['�']='我心飞翔同行:AwAFCAIABAoAAA==.我胡恩堵门:AwAICAgABAoAAA==.我长寿无灾:AwACCAMABAoAAA==.',['�']='拜德:AwAFCAUABAoAAA==.',['�']='挑逗你:AwACCAUABRQCEAACAQjPBwBWwsQABRQAEAACAQjPBwBWwsQABRQAAA==.',['�']='摩托哥:AwAGCAYABAoAAA==.',['�']='文刂:AwABCAEABRQAAA==.斯布兰蒂得:AwAHCAIABAoAAA==.',['�']='无奈的兔斯基:AwADCAYABRQCBQADAQg+DgAyLN0ABRQABQADAQg+DgAyLN0ABRQAAA==.无数梦境:AwABCAIABRQAAA==.',['�']='明天增肌:AwAECAgABRQCDQAEAQj+DwBQtAcBBRQADQAEAQj+DwBQtAcBBRQAAA==.星空科技会长:AwAICAUABAoAAA==.',['�']='晕晕吖:AwACCAIABRQAAA==.晨露:AwAECAUABAoAAA==.',['�']='暗舞血灵:AwAECAQABRQAAA==.暗黑圣教军:AwACCAUABRQCDQACAQigNwAbknUABRQADQACAQigNwAbknUABRQAAA==.暝灭:AwAFCAcABAoAAA==.暮月:AwADCAgABRQCBAADAQg3HQAYC8QABRQABAADAQg3HQAYC8QABRQAAA==.',['�']='曼波呢:AwAECAEABAoAAA==.',['�']='机械堡批龙:AwAGCAgABAoAAA==.',['�']='杀肉不留名:AwAGCAkABAoAAA==.束音花:AwACCAIABRQAARQAAAAECAIABRQ=.来困麻辣竹笋:AwAICAcABAoAAA==.',['�']='枂玥:AwAICAoABAoAAA==.枫雨漪漪:AwAECAkABAoAAA==.',['�']='棅念:AwAICCQABAoDGQAIAQhnEABH1SwCBAoAGQAIAQhnEABH1SwCBAoABAAGAQjMfwAvShABBAoAAA==.',['�']='橘子有点甜:AwAICAgABAoAAA==.',['�']='欧皇大人:AwAICAcABAoAAA==.',['�']='武大娘:AwAHCAcABAoAAA==.',['�']='沉睡的煜胭:AwAGCAYABAoAAA==.',['�']='法比安:AwACCAUABRQCBwACAQhWCgBOpbUABRQABwACAQhWCgBOpbUABRQAAA==.法洛恩:AwABCAMABRQCGgAIAQg2IAAsMGUBBAoAGgAIAQg2IAAsMGUBBAoAAA==.波利维亚大公:AwAECAQABRQAAA==.',['�']='浅陌:AwAICBAABAoAAA==.海尔辛:AwAFCAUABAoAAA==.',['�']='清雪若霜:AwAICAEABAoAAA==.清风蓝月:AwAECAQABAoAAA==.游侠卡伦西雅:AwAECAgABAoAAA==.',['�']='炁机:AwAICAQABAoAAA==.',['�']='烙殇:AwAGCAYABAoAAA==.',['�']='煜胭:AwABCAIABRQDGwAIAQggCwBQzIgCBAoAGwAIAQggCwBQzIgCBAoAHAADAQgnOwBOxQYBBAoAAA==.',['�']='爱蜜莉亚:AwAECAUABRQCGwAEAQhvDQAzAukABRQAGwAEAQhvDQAzAukABRQAAA==.',['�']='牢大:AwAICAgABAoAAA==.牧濑红莉西:AwABCAEABAoAAA==.',['�']='狂狮堂岛:AwAECAQABRQCHQAEAQjBCQApEMkABRQAHQAEAQjBCQApEMkABRQAAA==.',['�']='猎丶杀:AwAGCAgABAoAAA==.猎狗:AwAHCBMABAoAAQcAR18BCAIABRQ=.猪头苟萨:AwAICAgABAoAAA==.',['�']='玖寒丶:AwACCAIABRQAAA==.玲娜贝儿:AwADCAYABRQDBQADAQiZEwAa2b0ABRQABQADAQiZEwAa2b0ABRQAHgABAQgHFAAYukIABRQAAA==.',['�']='琉璃花火:AwABCAEABAoAAA==.',['�']='白开掺可乐:AwAECAkABRQCHwAEAQi2AABYpzQBBRQAHwAEAQi2AABYpzQBBRQAAA==.',['�']='碎风:AwAICBoABAoDCwAIAQiiIABALsgBBAoACwAHAQiiIABGc8gBBAoADAAIAQiIPQApqm8BBAoAAA==.',['�']='祖先全是鱼人:AwAICAgABAoAAA==.祝允:AwADCAIABAoAAA==.祝間蒼:AwAHCAcABAoAAA==.',['�']='福阿月:AwAICAEABAoAAA==.',['�']='秋逝孤魂:AwAFCAoABAoAAA==.',['�']='等等酱丶:AwAICAgABAoAAA==.筱灬鋼盔:AwACCAMABRQDDgAHAQikFgAhp8QABAoADwAHAQiqaAAWU+4ABAoADgAGAQikFgAg+cQABAoAAA==.',['�']='紫丨唄:AwAICA8ABAoAAA==.紫丶若水:AwAECAgABRQDBQAEAQhsBwBFpg0BBRQABQAEAQhsBwBDZQ0BBRQABgAEAQiSCQAWVM8ABRQAAQUATegICAYABRQ=.',['�']='纸风铃:AwAFCA4ABAoAAA==.',['�']='终极猎手:AwAFCAUABAoAAA==.维什戴尔:AwABCAEABRQCGQAHAQhbEABYgiwCBAoAGQAHAQhbEABYgiwCBAoAAA==.',['�']='耶路撒冷的神:AwAECAgABRQDIAAIAQhFGABGUzgCBAoAIAAIAQhFGABGUzgCBAoAIQACAQigUAAPQmIABAoAASEAN/gGCAoABRQ=.',['�']='聪明的肉肉:AwACCAMABRQAAA==.',['�']='胖胖不胖:AwAGCAYABAoAAA==.胡里胡:AwAICAYABAoAAA==.',['�']='至尊宝:AwAECAgABRQDAQAEAQjlCABFigUBBRQAAQAEAQjlCABFigUBBRQAGgAEAQhLDgAosrEABRQAAQkAKXMGCAYABRQ=.',['�']='艾莉吉亚:AwABCAMABRQCDwAIAQiLOAAs4a4BBAoADwAIAQiLOAAs4a4BBAoAAA==.',['�']='花炎巧雨:AwACCAQABRQAAA==.',['�']='苍狼噬魂:AwAHCAUABAoAAA==.苍风发此弦:AwAICAgABAoAAA==.',['�']='菜兽魑魅:AwAFCAEABAoAAA==.',['�']='蓝夜翱天:AwACCAUABRQDBgACAQjkDAA9hagABRQABgACAQjkDAA9hagABRQABQABAQhLKgAivD4ABRQAAA==.',['�']='薇氵尔莉特:AwAICAgABAoAARsATzwGCAYABRQ=.薛定谔之喵:AwABCAEABRQAAA==.',['�']='血兽来了:AwAECAIABRQAAA==.血色薔薇:AwAICAcABAoAAA==.街角魔族:AwACCAIABRQAAA==.',['�']='裆内丨有杀气:AwAECAQABRQAAA==.',['�']='赞达拉皮卡丘:AwAHCAUABAoAAA==.',['�']='超级大拇指:AwACCAIABRQAAA==.超萌食史者:AwACCAUABRQCCQAIAQh0HwBClzACBAoACQAIAQh0HwBClzACBAoAAA==.',['�']='跳姐超捣蛋:AwAICAEABAoAAA==.',['�']='这就受不了了:AwACCAIABAoAAA==.',['�']='速度灭丨:AwACCAIABRQAAA==.',['�']='铁血铜人:AwABCAIABRQCIAAIAQjiJQAxG+IBBAoAIAAIAQjiJQAxG+IBBAoAAA==.铲你龟儿耳使:AwAECAQABRQAAQkANygGCAYABRQ=.',['�']='闪现送人头:AwAECAQABRQAAA==.闪现送头:AwAICAYABAoAAA==.',['�']='雁鹫雕狸狮狒:AwAECAQABAoAAA==.雕兄:AwAICAgABAoAAA==.雷之律者:AwAECAQABRQAAA==.雷普苟斯:AwAGCBEABAoAAQ8ARzYBCAMABRQ=.雷電法王:AwAICAcABAoAAA==.',['�']='青鸢:AwADCAQABAoAAA==.面包好吃嘛:AwACCAQABRQAAA==.',['�']='風澟花:AwAECAQABRQAARoANY4GCAYABRQ=.',['�']='骑驴撞火星:AwAICAgABAoAAA==.',['�']='魔宝的细刀:AwAGCBIABAoAAA==.',['�']='麦子:AwABCAMABRQCCwAIAQgXDgBOjW0CBAoACwAIAQgXDgBOjW0CBAoAAA==.',['�']='黑心火龙果:AwADCAkABRQCBwADAQicAgBS2h4BBRQABwADAQicAgBS2h4BBRQAAA==.黑鋒哈士奇:AwAECAQABRQAAA==.黑铁萨:AwAGCAMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end