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
 local lookup = {'DeathKnight-Blood','Warlock-Destruction','DemonHunter-Havoc','DeathKnight-Unholy','Shaman-Restoration','Warrior-Protection','Warrior-Fury','Unknown-Unknown','Paladin-Retribution','Paladin-Protection','Mage-Fire','DemonHunter-Vengeance','Rogue-Subtlety','Rogue-Outlaw','Hunter-BeastMastery','Druid-Balance','Druid-Restoration','Priest-Shadow','Hunter-Marksmanship','Mage-Frost','Hunter-Survival','Paladin-Holy',}; local provider = {region='CN',realm='荆棘谷',name='CN',type='weekly',zone=42,date='2025-04-15',data={Bl='Blueslin:AwAECAQABRQAAA==.',Br='Brightxx:AwAICBwABAoCAQAIAQiiJAAlqz8BBAoAAQAIAQiiJAAlqz8BBAoAAA==.',Ca='Caniva:AwAICA8ABAoAAA==.',Fl='Fliedmiles:AwAHCBMABAoAAA==.',Jo='Jojoz:AwAGCAQABRQCAgAEAQjjCABFKgABBRQAAgAEAQjjCABFKgABBRQAAA==.',Ju='Juanz:AwACCAYABRQCAwACAQjhHgAyIZgABRQAAwACAQjhHgAyIZgABRQAAA==.',Li='Lionheart:AwADCAMABAoAAA==.',Mu='Muoupal:AwAICBAABAoAAA==.',So='Soyorin:AwAECAMABRQAAQQAMUoICAgABRQ=.',['�']='上官静儿:AwAHCA0ABAoAAA==.丨白哉:AwAICAgABAoAAA==.丶御弟哥哥:AwACCAMABRQAAA==.丶阿梁:AwAECAQABRQAAA==.丶颜旧人未归:AwAFCAYABAoAAA==.',['�']='乌拉巴拉:AwAECAgABRQCBQAEAQijCQA+9PwABRQABQAEAQijCQA+9PwABRQAAA==.',['�']='以斯帖:AwAICAsABAoAAA==.',['�']='依苔雪:AwAICAQABRQAAA==.',['�']='倾塌之墙:AwAECAgABRQDBgAEAQjuAQBOmw0BBRQABgAEAQjuAQBMUA0BBRQABwAEAQgjDgAxSvQABRQAAA==.',['�']='八鯪後:AwADCAMABRQAAA==.',['�']='南春香丶:AwAECAIABAoAAA==.南极丨小觉:AwAECAQABRQAAQgAAAAGCAIABRQ=.',['�']='右键内涵图:AwAFCAkABRQDCQAFAQhAFQBHVPYABRQACQAEAQhAFQBQbPYABRQACgABAQgeEQAsDk0ABRQAAQkAQX4GCAoABRQ=.',['�']='听风造雨:AwAICBMABAoAAA==.',['�']='呼吸武器:AwADCAMABAoAAA==.',['�']='喵喵小猪:AwACCAIABRQAAA==.',['�']='团长缺德么:AwAECAQABRQAAA==.',['�']='地贰:AwAGCAkABAoAAA==.',['�']='大荒丶应龙:AwAGCAoABAoAAA==.天才魔术师:AwAICBgABAoCCwAIAQibKwA2COkBBAoACwAIAQibKwA2COkBBAoAAA==.天罡星丿:AwACCAIABAoAAA==.',['�']='奶淇琳:AwABCAEABAoAAA==.奶茜茜:AwAECAIABAoAAA==.',['�']='如此明媚婉约:AwAICAgABAoAAA==.',['�']='婳麂:AwAECAQABRQAAA==.',['�']='嬲入口:AwAFCAUABAoAAA==.',['�']='寂涅小雅:AwEICBYABAoCDAAIAQiiHgAtxWEBBAoADAAIAQiiHgAtxWEBBAoAAQgAAAAICAMABRQ=.',['�']='小秘:AwACCAQABRQDDQAIAQjJBABWQKYCBAoADQAIAQjJBABWQKYCBAoADgABAQgcFwAoBzwABAoAAA==.',['�']='山地小紫牛:AwAICAkABAoAAA==.山寨豆浆机:AwAECAcABAoAAA==.',['�']='岚大裳:AwAICAUABAoAAA==.',['�']='崇德尚贤:AwAICAgABAoAAA==.',['�']='平生丶欢:AwAECAQABRQAAA==.平胸也有奶:AwABCAIABRQAAA==.',['�']='弹指奕倾城:AwAGCAkABRQDBAAGAQjbAAA/VdQBBRQABAAGAQjbAAA/VdQBBRQAAQABAQhEIgAAAAAABRQAAA==.',['�']='心有千千欲:AwAECAQABAoAAA==.',['�']='思念定格:AwAECAQABRQAAA==.',['�']='愤怒的圣骑:AwAECAkABRQCCQAEAQhyGAA5VOwABRQACQAEAQhyGAA5VOwABRQAAA==.',['�']='我不知道:AwABCAIABRQCAwAIAQgxIQBDQiYCBAoAAwAIAQgxIQBDQiYCBAoAAA==.我的奋斗:AwACCAEABAoAAA==.戰吊:AwAICAoABAoAAA==.',['�']='拜亚基:AwAICAgABAoAAA==.',['�']='指引:AwACCAUABRQCDwACAQilLQAg74gABRQADwACAQilLQAg74gABRQAAA==.',['�']='捋你命:AwAICBkABAoCBAAIAQigJwA6zPYBBAoABAAIAQigJwA6zPYBBAoAAA==.',['�']='断枫:AwACCAMABRQAAA==.',['�']='时尚古典:AwABCAIABRQAAA==.',['�']='晓晴歌:AwAECAoABRQDEAAEAQgCEwAuzeEABRQAEAAEAQgCEwAuzeEABRQAEQABAQhgHgAN/TUABRQAARIAPEoGCAoABRQ=.',['�']='暗影之巅:AwAICBoABAoCAgAIAQgVGgA+LRkCBAoAAgAIAQgVGgA+LRkCBAoAAA==.',['�']='末日乌伤:AwAGCAgABRQCCwAGAQi0AwAyQacBBRQACwAGAQi0AwAyQacBBRQAAA==.朱科的守护者:AwAICAgABAoAAA==.',['�']='来吧皮卡丘:AwAECAQABRQAAA==.杨提子:AwAECAQABAoAAA==.',['�']='梦莱:AwABCAEABRQAAA==.梧桐叶落:AwAECAQABRQAAA==.',['�']='殘缺:AwAECAQABRQAAA==.',['�']='水灬法:AwAICA8ABAoAAA==.',['�']='沐晨雨夕:AwAECAQABRQAAA==.',['�']='洛楚三千:AwAECAQABRQAAA==.',['�']='满目丶星辰:AwAICBEABAoAAA==.',['�']='漂泊的木头:AwADCAMABRQAAA==.',['�']='火掌:AwAFCAkABAoAAA==.灬灰色旋律灬:AwACCAQABRQCEwAIAQhfBQBe2rgCBAoAEwAIAQhfBQBe2rgCBAoAAA==.灰色旋律灬:AwAECAIABRQAAA==.',['�']='熊孩的下鞭腿:AwAECAYABRQDEwAEAQgCBQBcIwgBBRQAEwAEAQgCBQBBHQgBBRQADwACAQgvHwBWtbYABRQAAA==.熊熊骑士:AwAICAgABAoAAA==.熊的猫的酒:AwAECAQABRQAAA==.',['�']='燕回晴天:AwAGCAYABAoAAA==.',['�']='爆炸果实:AwADCAMABRQAAA==.',['�']='猪头傻乎乎:AwAFCAUABAoAAA==.',['�']='瓦罗兰:AwAICBMABAoAAA==.',['�']='甜心小兔兔丶:AwAICBUABAoCFAAIAQgwFwBFRCoCBAoAFAAIAQgwFwBFRCoCBAoAAA==.生棂涂炭:AwACCAIABRQAAA==.',['�']='疍疍的忧伤:AwAFCA0ABAoAAA==.',['�']='百香里:AwAICAMABAoAAA==.',['�']='秋月:AwAICBYABAoCFQAIAQjjBAA4IwkCBAoAFQAIAQjjBAA4IwkCBAoAAA==.秋风潇潇:AwABCAEABRQAAA==.',['�']='美艳俏小妈:AwACCAIABRQAAA==.',['�']='舞乱了天涯:AwAFCAIABAoAAA==.',['�']='芴岢黢岱:AwABCAEABRQAAA==.',['�']='萨满高级技师:AwAICAgABAoAAA==.',['�']='蔷薇花的邪恶:AwAECAQABAoAAA==.',['�']='行风如龏:AwAICBoABAoCCQAIAQhLRgA6KwMCBAoACQAIAQhLRgA6KwMCBAoAAA==.',['�']='贫僧法号瞎子:AwAICAEABAoAAA==.',['�']='輕橆飛婸:AwAICA4ABAoAAA==.',['�']='辣椒:AwACCAMABAoAAA==.',['�']='过分执著:AwAICAgABAoAAA==.远在天边:AwACCAMABAoAAA==.远在天邊:AwADCAMABAoAAA==.追忆初见:AwABCAEABRQAAA==.',['�']='逐风之汐:AwAICAIABAoAAA==.',['�']='遠在天边:AwAFCAUABAoAAA==.遠在天邊:AwABCAEABRQAAA==.',['�']='醋老陈:AwAECAYABRQDEwAEAQiXDAAvxs8ABRQAEwAEAQiXDAAsW88ABRQADwACAQjPLQAueYcABRQAAA==.',['�']='锦十三:AwAECAQABRQCEAAEAQiaEAA1A+sABRQAEAAEAQiaEAA1A+sABRQAAA==.锦十禅:AwAECAUABRQDFgAEAQgiCwAuX5UABRQAFgADAQgiCwA3ZJUABRQACQACAQjuOgBZMl4ABRQAAA==.',['�']='闻人牧月:AwAICBEABAoAAA==.',['�']='阿比迪斯丶:AwAICAgABAoAAA==.阿翔防骑:AwACCAIABRQAAA==.',['�']='随风无痕:AwACCAIABRQAAQcAF38HCAgABRQ=.',['�']='雨落三月:AwACCAUABRQDCQACAQjxLgAuU5EABRQACQACAQjxLgAlZZEABRQACgACAQgjDgAoQXAABRQAAA==.雷霆末日:AwAICA4ABAoAAA==.',['�']='青橘:AwAHCA0ABAoAAA==.',['�']='风之气息:AwAICBAABAoAAA==.风又飘飘:AwAICBoABAoCCQAIAQiVSwA4NPQBBAoACQAIAQiVSwA4NPQBBAoAAA==.风若年:AwACCAIABRQAAA==.飞舞得燕尾蝶:AwAICA8ABAoAAQgAAAAGCAQABRQ=.',['�']='鼻毛八尺三:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end