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
 local lookup = {'Mage-Fire','Shaman-Elemental','Druid-Restoration','Rogue-Subtlety','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Priest-Shadow','Mage-Frost','Paladin-Protection','Shaman-Restoration','Warrior-Fury','Warrior-Protection','Unknown-Unknown','Warlock-Destruction','Monk-Windwalker','DemonHunter-Havoc',}; local provider = {region='CN',realm='勇士岛',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ay='Ayse:AwABCAEABAoAAA==.',Gr='Grill:AwAECAQABRQAAA==.',In='Inori:AwAICAgABAoAAQEAU70GCAYABRQ=.',Ka='Kamehameha:AwAICAgABAoAAA==.',Kh='Khuntoria:AwACCAUABRQCAgACAQi6CQBNqb4ABRQAAgACAQi6CQBNqb4ABRQAAA==.',Ky='Kyo:AwAICAgABAoAAA==.',Ml='Mlss:AwAGCAYABRQCAQAGAQgUAQBTvQICBRQAAQAGAQgUAQBTvQICBRQAAA==.Mlsslovee:AwADCAMABRQAAA==.',Rl='Rlyeh:AwADCAMABRQAAA==.',So='Sosai:AwAICBgABAoCAwAIAQi8EQBCwhUCBAoAAwAIAQi8EQBCwhUCBAoAAA==.',['�']='一直:AwAGCAYABAoAAA==.一直都还在:AwAECAQABRQAAA==.一翩若惊鸿一:AwABCAEABAoAAA==.丄弑神者丄:AwACCAIABRQAAA==.三号小菜鸡:AwABCAEABAoAAA==.三条腿:AwAICA8ABAoAAA==.上帝的人:AwAECAQABAoAAA==.不会飞的鱼:AwAECAQABAoAAA==.不約兒童丶:AwAECAEABAoAAA==.丨一哥丨:AwACCAIABRQAAA==.丶獵:AwACCAIABAoAAA==.丶谢幕:AwAECAYABRQCBAAEAQimCAAe4NMABRQABAAEAQimCAAe4NMABRQAAA==.为了联盟灬:AwAECAQABRQAAA==.',['�']='也非也:AwABCAEABRQDBQAIAQjgbAAdIzkBBAoABQAHAQjgbAAggDkBBAoABgAIAQgvNgAQqggBBAoAAA==.',['�']='伊姆什霍格:AwAFCAUABAoAAA==.',['�']='佐佐慕曦:AwABCAEABAoAAA==.',['�']='借网贷去推由:AwACCAIABRQAAA==.',['�']='傲天大兵:AwABCAEABAoAAA==.',['�']='关云长:AwAECAIABRQAAA==.',['�']='别哔哔:AwAECAEABRQCBwABAQiiNgBJBFsABRQABwABAQiiNgBJBFsABRQAAQgANl0GCAoABRQ=.别进去:AwADCAMABAoAAA==.',['�']='割肉大师:AwACCAIABRQAAA==.',['�']='力个表:AwADCAMABAoAAA==.',['�']='卢饮溪:AwAECAQABRQAAA==.',['�']='只抽华子:AwACCAIABAoAAA==.史蒂芬霍津:AwAGCAMABAoAAA==.',['�']='吹毛求毛:AwAECAYABRQCCQAEAQj0AwA8JwUBBRQACQAEAQj0AwA8JwUBBRQAAA==.',['�']='周肥錀:AwAGCAYABAoAAA==.',['�']='咪类个喵:AwAECAQABRQAAA==.咸鱼罐头:AwABCAEABAoAAA==.',['�']='哀求:AwABCAEABRQAAA==.哈哩咕噜几:AwADCAMABAoAAA==.',['�']='喜之郎:AwAFCAUABAoAAA==.',['�']='埃尔文薛定谔:AwACCAUABRQCCgACAQhHCwA1kIQABRQACgACAQhHCwA1kIQABRQAAA==.',['�']='壮鱼儿:AwAFCAUABAoAAA==.壹生所愛:AwAECAQABAoAAA==.',['�']='夜月追风:AwACCAYABRQCAQACAQhqKAAUiIIABRQAAQACAQhqKAAUiIIABRQAAA==.大兵:AwADCAMABAoAAA==.大沐沐:AwAECAUABAoAAA==.大牛追小牛:AwABCAEABRQAAA==.大眼小馒头:AwAECAgABRQCBAAEAQiiBgAwsfIABRQABAAEAQiiBgAwsfIABRQAAA==.',['�']='孤城不危:AwAICBUABAoCCwAIAQiyNwApJ4ABBAoACwAIAQiyNwApJ4ABBAoAAA==.',['�']='寻风脚步:AwACCAIABRQAAA==.',['�']='小宝贝儿:AwABCAEABRQAAA==.小小仔仔:AwAHCAEABAoAAA==.',['�']='帅哥在此:AwABCAEABRQAAA==.',['�']='影心:AwAICAgABAoAAA==.',['�']='得非所求:AwAHCAcABAoAAA==.徘徊月:AwACCAIABRQAAQwAF38HCAgABRQ=.',['�']='恋上酒的猫:AwACCAIABAoAAA==.',['�']='情迷大自然:AwAHCAkABAoAAA==.',['�']='我热:AwABCAEABRQAAA==.戰岚破海:AwABCAEABRQAAA==.',['�']='掌心丶:AwACCAIABRQAAA==.',['�']='提里奥胖丁:AwABCAEABAoAAA==.',['�']='断线远飞:AwAECAQABAoAAA==.斷臂維納斯:AwAHCAcABAoAAA==.',['�']='月半亓亓:AwAECAQABRQAAA==.月蚀之舞:AwACCAUABRQCDQACAQhXBwAUGW0ABRQADQACAQhXBwAUGW0ABRQAAA==.',['�']='李逍遙:AwABCAEABRQAAA==.杜甫丶:AwAICAYABAoAAA==.',['�']='枫叶飘落:AwAECAQABAoAAA==.',['�']='正宗诸葛亮:AwAECAQABRQAAA==.',['�']='比歌迪克:AwADCAcABRQDBgADAQjiCAAteuAABRQABgADAQjiCAAteuAABRQABQABAQhqNwA8ZEkABRQAAA==.',['�']='沐小雅:AwADCAMABAoAAA==.没有点卡:AwABCAEABAoAAA==.',['�']='爆弹狂鼠:AwAICAkABAoAAA==.爱意随钟起:AwADCAMABAoAAA==.',['�']='狼之嚎叫:AwADCAMABAoAAA==.',['�']='猫咪大王:AwAICAYABAoAAA==.',['�']='目童:AwAGCAIABRQAAA==.',['�']='破墟玄玄:AwAICBEABAoAAA==.',['�']='社会平爷:AwAFCAIABRQCAwACAQj/EQAmQnUABRQAAwACAQj/EQAmQnUABRQAAQ4AAAAICAIABRQ=.',['�']='米卡莎丷:AwAGCAQABRQAAA==.',['�']='紫柏:AwABCAEABAoAAA==.',['�']='绿筱配青竹:AwAGCAYABAoAAA==.',['�']='翁雪:AwAGCAYABAoAAQ4AAAAGCAQABRQ=.',['�']='胖哒:AwADCAUABAoAAA==.胖奶:AwACCAIABAoAAA==.',['�']='腼腆小野孩:AwACCAEABAoAAA==.',['�']='芮斯拜:AwAICAgABAoAAA==.花落:AwADCAMABAoAAA==.',['�']='苏酥头号粉丝:AwAICAkABAoAAA==.',['�']='莱恩家的天神:AwAECAQABAoAAA==.',['�']='蔷薇之溅:AwABCAEABRQAAA==.',['�']='薄雾幽幽:AwACCAIABRQAAA==.',['�']='蜡笔小新的笔:AwAECAMABRQAAA==.',['�']='蝦米:AwAECAMABAoAAA==.',['�']='裤子都脱了:AwAHCAcABAoAAA==.',['�']='谁为天使忧愁:AwAHCA4ABAoAAA==.',['�']='超甜软男:AwAICAcABAoAAA==.',['�']='辣白菜:AwAICAgABAoAAA==.',['�']='还是那个老板:AwAGCAQABRQAAA==.',['�']='遥远的救世主:AwADCAMABAoAAA==.',['�']='那年的春夏:AwABCAEABRQAAA==.邪能乆乆:AwAECAgABRQCDwAEAQhjBgBPnA4BBRQADwAEAQhjBgBPnA4BBRQAAA==.',['�']='醉梦浮生:AwADCAMABAoAAA==.',['�']='长期术世:AwACCAIABAoAAA==.长角的美女:AwAICAgABAoAAA==.',['�']='閃耀:AwACCAIABAoAAA==.',['�']='阝灬熊熊彡:AwAGCAsABAoAAA==.阿尔达:AwAGCAoABAoAAA==.',['�']='陈佳佳:AwABCAEABRQCEAAIAQhYIwAqV5oBBAoAEAAIAQhYIwAqV5oBBAoAAA==.陈壮壮:AwAECAQABAoAAA==.',['�']='风之猎影:AwABCAEABAoAAA==.',['�']='骑士魅影:AwAFCAUABAoAAA==.',['�']='魅小影:AwACCAgABRQCEQACAQj5GgBDqp8ABRQAEQACAQj5GgBDqp8ABRQAAA==.魔幻棒棒:AwAECAQABRQAARAAXgAICAQABRQ=.',['�']='黑暗中的骑士:AwAECAQABAoAAA==.黑神话耗子:AwAECAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end