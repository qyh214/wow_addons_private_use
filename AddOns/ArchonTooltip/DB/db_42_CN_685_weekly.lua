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
 local lookup = {'Paladin-Retribution','DemonHunter-Havoc','Mage-Fire','Rogue-Assassination','Rogue-Subtlety','Priest-Shadow','Unknown-Unknown','Druid-Restoration','DeathKnight-Blood','Priest-Holy','Warlock-Destruction','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Unholy','Shaman-Elemental','Shaman-Enhancement','Shaman-Restoration','Warrior-Fury','Warrior-Arms','Evoker-Devastation',}; local provider = {region='CN',realm='扎拉赞恩',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ae='Aerarion:AwAICBsABAoCAQAIAQjGHABSuI4CBAoAAQAIAQjGHABSuI4CBAoAAA==.',Bl='Bluebones:AwAHCAYABAoAAA==.',Ha='Hayex:AwAICBEABAoAAA==.',Im='Imm:AwAECAQABRQAAA==.',Jm='Jmm:AwABCAEABRQAAA==.',Md='Mdem:AwAICAgABAoAAA==.Mdlee:AwAECAQABRQAAA==.',St='Stonegarlic:AwAECAYABAoAAA==.',Ve='Veux:AwAICAgABAoAAA==.',Vi='Vikenn:AwAECAIABRQAAA==.',['�']='万木纷秀挺:AwAECAQABRQAAQIAMf0GCA4ABRQ=.不吃爆壳蟹:AwACCAEABRQAAA==.不爱吃竹叶:AwAFCAcABAoAAA==.丨射丨咪丨咪:AwACCAQABRQAAA==.丶我才是大猫:AwAECAQABRQAAA==.',['�']='二哥的幻影:AwAECAQABRQAAA==.人生猎手:AwAICAYABAoAAA==.',['�']='今晚不做饭:AwACCAIABAoAAA==.今朝陌路单:AwAICAsABAoAAA==.',['�']='伊人丶红妆:AwAICAwABAoAAQMASekGCAwABRQ=.伊利蛋丶怒疯:AwAGCAYABAoAAA==.伊利蛋的咆哮:AwAGCAMABAoAAA==.',['�']='佰仕达:AwAECAQABRQAAA==.',['�']='兀自笑春風:AwAECAQABRQAAA==.先杀那个贼:AwAICAgABAoAAA==.光明与黄昏:AwAFCAYABAoAAA==.',['�']='冰火两重天:AwAFCAoABAoAAA==.',['�']='凛冬冰封:AwAFCAUABAoAAA==.凡尔赛提斯:AwABCAEABAoAAA==.',['�']='势不可挡:AwAHCAoABAoAAA==.',['�']='千早爱音丨:AwAICAEABAoAAA==.半熟榴莲:AwADCAMABAoAAA==.',['�']='君醉为红颜:AwAECAQABAoAAA==.',['�']='咖啡猎手:AwACCAIABAoAAA==.',['�']='哇卡卡:AwABCAEABRQAAA==.',['�']='嘸極:AwAICAEABAoAAA==.',['�']='在干嘛:AwABCAEABRQAAA==.',['�']='墨小鱼:AwAICBcABAoDBAAIAQjmDQBDPRcCBAoABAAIAQjmDQBDPRcCBAoABQAIAQgEDwA4APYBBAoAAA==.',['�']='夏璐璐:AwAGCAYABAoAAA==.外特水:AwAECAQABRQAAQYAN6oGCAgABRQ=.夜怀寻:AwACCAMABAoAAA==.夜羽龙帝:AwABCAIABRQAAA==.天一命:AwABCAEABRQAAA==.太阳神:AwAECAQABRQAAA==.',['�']='孤儿单扮演者:AwAECAEABRQAAQMATgYGCAgABRQ=.',['�']='安蕾莉雅:AwAGCAYABAoAAA==.',['�']='小小的熊猫:AwAICAYABAoAAQcAAAAICAMABRQ=.',['�']='岛田卢西奥:AwABCAEABAoAAA==.',['�']='巨牧蘸酱:AwAGCAgABAoAAA==.差很多同学:AwAGCAUABAoAAA==.',['�']='帝小羽灬:AwADCAQABAoAAQgAHlQBCAUABRQ=.常驻嘉宾:AwAECAQABRQAAA==.',['�']='庭前雨后:AwAECAQABAoAAA==.',['�']='德中我最牛:AwAGCAYABAoAAA==.德古喵大王:AwAECAQABRQCCQAIAQhcFgA3f74BBAoACQAIAQhcFgA3f74BBAoAAA==.',['�']='心梦梦幻:AwAICAQABAoAAA==.',['�']='恋世浮曲:AwABCAEABRQAAA==.',['�']='悠哉小桃子:AwAFCAcABAoAAA==.',['�']='惑丶琰:AwAICAgABAoAAA==.',['�']='慕容姗姗:AwAECBEABRQCCgAEAQj3BgAzPuQABRQACgAEAQj3BgAzPuQABRQAAA==.',['�']='我怕开水烫:AwAICAgABAoAAA==.',['�']='抓住一只悦悦:AwAGCAYABRQCCwAEAQgmBgBNIRABBRQACwAEAQgmBgBNIRABBRQAAA==.',['�']='拉风的庸医:AwAICAoABAoAAA==.',['�']='提里奥抚丁:AwAECAQABRQAAA==.',['�']='放着你来:AwAGCAQABRQCAgAEAQj5DwAy/u0ABRQAAgAEAQj5DwAy/u0ABRQAAA==.',['�']='无尽梦魇:AwADCAMABRQDDAAIAQiiGgAyKMEBBAoADAAIAQiiGgAyGMEBBAoADQAGAQi/fwAfIgMBBAoAAA==.旧梦时光不语:AwACCAIABRQAAA==.',['�']='暗黑之影:AwAHCAkABAoAAA==.',['�']='朗仕:AwABCAEABRQAAA==.',['�']='梦幻小熊猫:AwAICAQABRQAAA==.',['�']='椿庭梦澜:AwAHCAEABAoAAA==.',['�']='楼蓝壹飘壳:AwAFCAgABAoAAA==.',['�']='榕耀星光:AwAECAIABRQAAA==.',['�']='橙橙狮:AwACCAIABAoAAA==.',['�']='殇之剑:AwAGCAYABAoAAA==.',['�']='波哥彡:AwAECAQABAoAAA==.泰袒丶欧萨:AwAECAQABRQAAA==.',['�']='流云战歌:AwACCAMABRQAAA==.流离指沙间:AwAHCAcABAoAAA==.海瑟薇安妮:AwAICAgABAoAAA==.海门刘德华:AwAECAQABAoAAA==.',['�']='淼厸:AwAGCAUABAoAAA==.',['�']='清蒸贝鱼:AwAGCAUABAoAAA==.渔叉仙道:AwABCAEABRQAAA==.',['�']='灬火翼灬:AwABCAEABRQDDgAIAQh3HABLDi8CBAoADgAIAQh3HABLDi8CBAoACQACAQiSTQAkFlkABAoAAA==.灬皮包切割者:AwAICAgABAoAAA==.灰太郞:AwACCAIABAoAAA==.',['�']='热门战舰:AwAHCBgABAoDDwAHAQiBIgBEjakBBAoADwAHAQiBIgA79qkBBAoAEAAFAQg6KwBL5kABBAoAAA==.',['�']='無尽的雨:AwAGCAYABAoAAA==.',['�']='爱喵喵的可乐:AwACCAIABRQAAA==.',['�']='猪猪宝:AwAICAsABAoAAA==.',['�']='疯狂麦辣鸡:AwAECAQABRQAAA==.',['�']='百里流光:AwAICAgABAoAAQwAYNYGCAIABRQ=.',['�']='盜愺亾:AwABCAEABRQAAA==.',['�']='矮要坦荡荡丶:AwADCAMABAoAAA==.',['�']='福噗噗:AwAFCAUABAoAAA==.',['�']='秦半仙:AwAGCAYABAoAAA==.',['�']='窃格瓦拉丶:AwAECAQABRQAAA==.',['�']='米莉娅:AwAICAEABAoAAA==.',['�']='精神科主任:AwABCAEABRQAAA==.',['�']='网瘾治疗专家:AwAECA0ABRQDDwAEAQjhAgBWexoBBRQADwAEAQjhAgBWexoBBRQAEQABAQiJKwAMwjQABRQAAA==.',['�']='肝不动:AwABCAEABRQAAA==.',['�']='臭宝贝:AwACCAIABAoAAA==.臭粑粑丶:AwAFCAIABAoAAA==.',['�']='艾弗森:AwADCAUABRQCDQADAQhSCgBIoxUBBRQADQADAQhSCgBIoxUBBRQAAA==.',['�']='茂挺独先觉:AwAECAQABRQAAA==.',['�']='軍团火眼狻猊:AwAICAgABAoAAA==.',['�']='轻荡涟漪丶:AwABCAEABRQAAA==.',['�']='邪恶召唤:AwAECAQABAoAAA==.',['�']='郭芙榕啊:AwACCAIABRQAAA==.',['�']='键来:AwAECAQABRQAAA==.',['�']='阿芙罗蒂特:AwABCAEABRQAAA==.',['�']='雨皇:AwABCAEABAoAAA==.',['�']='青玉案:AwAGCAYABAoAAA==.',['�']='顾小桑:AwAICBEABAoAAA==.',['�']='额米陀佛:AwAHCAYABAoAAA==.風揚:AwAICAUABAoAAA==.',['�']='风一般怪蜀黍:AwAGCA8ABRQDEgAGAQjzBABSrSkBBRQAEgAEAQjzBABV4SkBBRQAEwADAQjeBQBN384ABRQAAA==.',['�']='马歇尔蒂奇:AwADCAMABAoAAA==.',['�']='骑遍世界:AwAHCBMABAoAAA==.',['�']='龙行有雨:AwAGCAQABRQAARQAD08ICAUABRQ=.龙裔:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end