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
 local lookup = {'Mage-Fire','Druid-Balance','Druid-Restoration','Warlock-Destruction','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Retribution','Evoker-Devastation','Warrior-Fury','Unknown-Unknown','Hunter-BeastMastery','Mage-Frost','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Druid-Feral','DeathKnight-Frost','Warlock-Affliction',}; local provider = {region='CN',realm='风暴之眼',name='CN',type='weekly',zone=42,date='2025-04-15',data={An='Anyoyol:AwAICAkABAoAAA==.',Er='Erdtree:AwACCAIABRQAAA==.',Eu='Eutopia:AwACCAIABRQAAA==.',Fo='Fov:AwAGCAQABRQCAQAEAQhuFgA5dugABRQAAQAEAQhuFgA5dugABRQAAA==.',Ra='Raichu:AwAICAIABAoAAA==.',['�']='一百多个圣骑:AwAECAQABRQAAA==.万俟小圣:AwAICAEABAoAAA==.万径丨人踪灭:AwAECAQABRQAAA==.三两韭菜鸡蛋:AwAICAIABAoAAA==.上古神德:AwAGCAoABRQDAgAGAQjsAgA0cVUBBRQAAgAFAQjsAgA521UBBRQAAwADAQinFAAZvHAABRQAAA==.不要你提醒我:AwACCAIABAoAAA==.丨鞠婧祎丨:AwAECAQABRQAAA==.串串:AwAFCAUABAoAAA==.丶清皊:AwACCAIABRQAAA==.',['�']='二狗子:AwACCAIABRQAAA==.五色土豆泥:AwAECAQABRQAAA==.',['�']='再来一发少年:AwAHCAYABAoAAA==.',['�']='单体巨兽:AwAECAQABRQAAQQAQ24GCAkABRQ=.',['�']='叫我小德吧:AwAFCAYABAoAAA==.可儿必思嘟嘟:AwAGCAQABRQAAA==.可尔必思多多:AwAGCAoABRQDBQAGAQg4CQAdc+AABRQABgAEAQiWDgAvnOQABRQABQAGAQg4CQAJj+AABRQAAA==.',['�']='咖喱叶:AwAECAQABRQAAA==.',['�']='哲晰:AwAFCAcABAoAAA==.',['�']='啊一唔诶哦:AwAECAQABRQAAA==.啊逼的小怪兽:AwACCAIABRQCBwAIAQh+HQBYTJICBAoABwAIAQh+HQBYTJICBAoAAA==.問問:AwAECAQABAoAAA==.',['�']='四号大菜鸟:AwAHCAwABAoAAA==.',['�']='圆桌骑士:AwAECAgABRQCBwAEAQjABQBczTgBBRQABwAEAQjABQBczTgBBRQAAA==.',['�']='坏天气:AwAGCAMABAoAAA==.',['�']='增的辉常牛逼:AwAECA0ABRQCCAAEAQhYCgA2lOQABRQACAAEAQhYCgA2lOQABRQAAQgAIOMICAUABRQ=.',['�']='壞爺:AwAECAQABAoAAA==.',['�']='多部未华子:AwADCAEABAoAAA==.大地之力:AwADCAkABRQCCQADAQgqEgAPT9MABRQACQADAQgqEgAPT9MABRQAAA==.',['�']='妹子你炉石呢:AwAGCAgABAoAAA==.',['�']='宠物院长丶熠:AwAECAQABRQAAA==.审判者维罗亚:AwAECAQABRQAAA==.宫脇咲良:AwAECAQABRQAAA==.',['�']='小小珺肝:AwAGCAQABAoAAA==.小弱江:AwADCAIABRQAAA==.小酌的老陈:AwAECAQABRQAAA==.',['�']='帅萌萌:AwAECAQABAoAAA==.',['�']='悠悠:AwADCAMABRQAAA==.',['�']='愿圣光照耀:AwAECAQABRQAAA==.',['�']='戈壁滩的凡人:AwACCAIABAoAAA==.我是盲人:AwAICAgABAoAAA==.我来找长明:AwAICAgABAoAAA==.我来找鹏鹏:AwAECAQABRQAAA==.',['�']='护法:AwAICAgABAoAAQYAQ3QGCA0ABRQ=.',['�']='无敌小星星:AwAGCBIABRQCBwAGAQjbAAA/ANQBBRQABwAGAQjbAAA/ANQBBRQAAA==.',['�']='暧美莉:AwAICAgABAoAAA==.',['�']='机油加蛋:AwAFCAUABAoAAA==.',['�']='榕榕:AwAICAgABAoAAA==.',['�']='浅唱丶月舞:AwAHCAoABAoAAA==.浅汐:AwAICA0ABAoAAA==.浅灰灰色:AwAGCAYABAoAAA==.海德林:AwACCAIABRQAAQoAAAAECAQABRQ=.',['�']='液化气大王:AwAGCAcABAoAAA==.',['�']='满穗:AwADCAMABRQAAA==.',['�']='烈火焚天而上:AwADCAUABAoAAQoAAAAFCAoABAo=.',['�']='狂妄之徒:AwABCAEABRQAAA==.狠呆:AwAECAgABRQCCwAEAQinEABGK/4ABRQACwAEAQinEABGK/4ABRQAAA==.狮子座流星雨:AwAECAQABRQAAA==.',['�']='猩红毒针:AwAECAYABRQDAQAEAQgjFABQGO8ABRQAAQAEAQgjFAA9g+8ABRQADAACAQixDABYtpoABRQAAA==.',['�']='玲歼灭:AwAECAQABRQAAA==.',['�']='瘟猪的萌柯基:AwAECAQABRQAAA==.',['�']='白凝冰:AwAECAQABRQAAA==.白尾巴:AwAECAwABRQCCwAEAQhBEQBMgfsABRQACwAEAQhBEQBMgfsABRQAAA==.',['�']='神龙丸:AwAECAQABRQAAA==.',['�']='空手抡大炮:AwAICGIABAoCCQAIAQgBAQBhYhYDBAoACQAIAQgBAQBhYhYDBAoAAA==.',['�']='索尔奥丁森:AwABCAEABAoAAA==.紫幻云:AwADCAMABAoAAA==.',['�']='细雨灬微醉:AwAECAQABRQAAA==.绝舞:AwAICAcABAoAAA==.',['�']='罗莎莉娅:AwAGCAoABRQCDQAGAQhRAABiAkMCBRQADQAGAQhRAABiAkMCBRQAAA==.',['�']='美特奥拉:AwAICAgABAoAAA==.羽丨戎:AwAECAQABRQAAA==.',['�']='翻出墙头:AwAFCAUABAoAAA==.',['�']='老衲法号亂来:AwACCAIABRQAAA==.',['�']='艾媄莉:AwAICAgABAoAAA==.',['�']='苏浅浅:AwAECAgABRQDDgAEAQi2AgBh6lQBBRQADgAEAQi2AgBh6lQBBRQADwABAQhUHAA4F1MABRQAAA==.',['�']='荒鉤爪:AwAECBEABRQDEAAEAQioAABOHjcBBRQAEAADAQioAABOHjcBBRQAAgABAQitNAAAAAAABRQAAA==.',['�']='蓝心丶怒风:AwAECAQABRQAAA==.',['�']='蕾希:AwAICAEABAoAAA==.',['�']='螢火虫:AwAECAIABRQAAA==.',['�']='贝塔:AwAHCAsABAoAAA==.',['�']='跑魂战神:AwADCAMABRQCEQAIAQiPBQBOu2YCBAoAEQAIAQiPBQBOu2YCBAoAAA==.',['�']='软软的小枕头:AwAGCAQABRQAAA==.',['�']='那个翼神回来:AwAECAYABRQDEgAEAQg+BwAw1ekABRQAEgADAQg+BwAw1ekABRQABAADAQixIAAX82wABRQAAA==.邪洛:AwABCAEABRQCDAAIAQjeDABYBocCBAoADAAIAQjeDABYBocCBAoAAA==.',['�']='锌铁锡铅氢:AwAECAQABRQAAA==.',['�']='雷尼丝:AwACCAIABRQAAQgAD08ICAUABRQ=.',['�']='青灵儿:AwAICAoABAoAAA==.',['�']='飞沙走奶:AwAECAQABRQAAA==.',['�']='魅猎:AwAICAEABAoAAA==.',['�']='鲸落:AwACCAIABRQAAA==.',['�']='麻宫雅典娜:AwACCAUABRQCBwACAQgZIABYfc4ABRQABwACAQgZIABYfc4ABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end