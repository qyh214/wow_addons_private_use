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
 local lookup = {'DemonHunter-Vengeance','Mage-Fire','Mage-Frost','Paladin-Retribution','Paladin-Holy','Evoker-Devastation','Evoker-Preservation','DeathKnight-Unholy','DemonHunter-Havoc','Monk-Mistweaver','Priest-Discipline','Warlock-Destruction','Warlock-Affliction','Unknown-Unknown','Rogue-Assassination','Shaman-Enhancement','Shaman-Elemental','DeathKnight-Frost','Priest-Holy','Shaman-Restoration','Druid-Balance','Priest-Shadow','Hunter-BeastMastery',}; local provider = {region='CN',realm='达尔坎',name='CN',type='weekly',zone=42,date='2025-04-15',data={Cu='Cuteyile:AwAECAQABAoAAA==.',De='Dermi:AwACCAMABRQAAA==.',Ku='Kumashi:AwAECAQABRQAAA==.',My='Mycc:AwABCAEABAoAAA==.',Pe='Perula:AwACCAUABRQCAQAIAQgEAwBcsNoCBAoAAQAIAQgEAwBcsNoCBAoAAA==.',Pl='Playerjzhykn:AwACCAIABAoAAA==.',Ra='Rainbowmiss:AwAECAQABRQAAA==.',Te='Teentine:AwABCAEABRQAAA==.',To='Topjiji:AwABCAEABAoAAA==.',Vt='Vturn:AwAICA0ABAoAAA==.',['�']='一则驴:AwABCAEABRQAAA==.一杯美式:AwAGCAYABAoAAA==.一点三:AwAECAQABRQAAA==.一米曙光:AwAECAgABRQCAgAEAQiYFQA8T+oABRQAAgAEAQiYFQA8T+oABRQAAA==.不死坠灬天心:AwABCAEABAoAAA==.丨回忆如风丨:AwAGCAQABRQAAA==.丨天罚丨:AwAECAIABAoAAA==.丶神避:AwAECAQABRQAAA==.',['�']='乃青交融:AwABCAEABRQCAwAIAQjUGABFbB8CBAoAAwAIAQjUGABFbB8CBAoAAA==.',['�']='二狗子三精:AwAECAgABRQDBAAEAQhSDwBBeAkBBRQABAAEAQhSDwBBeAkBBRQABQAEAQj4AwBC3f0ABRQAAA==.',['�']='伊露维塔:AwACCAUABRQDBgAIAQjbIQAmYX0BBAoABgAIAQjbIQAmYX0BBAoABwAFAQhUGQAb8KwABAoAAA==.',['�']='你想跟我拼枪:AwABCAEABAoAAA==.佳能照相机:AwAECAQABRQAAA==.',['�']='冰封的心:AwAGCAkABAoAAA==.',['�']='凉风青叶:AwAICAgABAoAAA==.凌波丽丶:AwAECAgABRQCCAAEAQh3CwBEKvUABRQACAAEAQh3CwBEKvUABRQAAA==.凌雲:AwAICAgABAoAAA==.',['�']='切茜娅:AwACCAIABRQAAA==.别见星光:AwAECAQABRQAAA==.',['�']='功夫喘:AwAECAMABRQAAA==.',['�']='十鬼神王马:AwAGCAsABRQCBAAGAQgqAQA3xL8BBRQABAAGAQgqAQA3xL8BBRQAAA==.',['�']='叫我小浪就好:AwAICBIABAoAAA==.',['�']='吾去脱她依:AwAICAgABAoAAA==.',['�']='喝喝酒:AwAICAgABAoAAA==.喵与荆芥:AwACCAMABRQCCQAIAQj3NwAvDbABBAoACQAIAQj3NwAvDbABBAoAAA==.',['�']='大雾怪:AwAGCAsABAoAAA==.天神下瀿:AwACCAIABAoAAA==.',['�']='威風堂堂:AwAICBMABAoAAA==.',['�']='孖桶洗衣机:AwAHCAcABAoAAA==.',['�']='宇宙骑士利箭:AwAGCAcABAoAAA==.守心:AwABCAEABRQAAA==.',['�']='尤古朵拉:AwAICAgABAoAAA==.',['�']='山海觀霧:AwAGCAkABRQCAgAFAQjrBABXGYYBBRQAAgAFAQjrBABXGYYBBRQAAA==.',['�']='巧克力麻薯:AwAGCAYABAoAAA==.巫洛丶克:AwAGCAwABRQCCgAGAQgsAgArS5gBBRQACgAGAQgsAgArS5gBBRQAAA==.',['�']='希尔瓦纳斯:AwAECAQABRQAAA==.',['�']='幺鸡小一条:AwAECAQABRQAAQsAMX0HCA0ABRQ=.',['�']='张呣呣:AwACCAIABRQAAA==.',['�']='当铺丶:AwAGCAoABRQDDAAGAQiwAgAy3F0BBRQADAAGAQiwAgATPF0BBRQADQADAQjSAwBQPw0BBRQAAQ4AAAAICAIABRQ=.影仕:AwACCAUABRQCDwACAQiyDQApVqIABRQADwACAQiyDQApVqIABRQAAA==.',['�']='慎独:AwAFCAUABAoAAA==.',['�']='我爱潇洒哥:AwADCAMABAoAAA==.',['�']='拂晓神丫:AwABCAEABRQCCgAIAQgODgBOo2wCBAoACgAIAQgODgBOo2wCBAoAAA==.',['�']='持斧大只佬:AwAGCAIABRQCEAACAQhmDwApApUABRQAEAACAQhmDwApApUABRQAAA==.',['�']='放肆丶那纠结:AwACCAQABRQAAA==.',['�']='方丈的娇师太:AwAGCAYABRQCAgAGAQjVAwA3O6QBBRQAAgAGAQjVAwA3O6QBBRQAAA==.',['�']='晓羽丅蕾姆:AwAICAgABAoAAA==.普拉普拉灰:AwAFCAYABAoAAA==.',['�']='暴富牛:AwAECAQABAoAAA==.',['�']='曾经我野清纯:AwAHCAcABAoAAA==.',['�']='木兰没及:AwADCAMABAoAAA==.机器人:AwAICAgABAoAAA==.',['�']='柒号花茗册:AwAECAQABRQAAA==.',['�']='油焖秋芛:AwAFCAUABAoAAA==.',['�']='洋葱葱:AwACCAIABRQAAA==.',['�']='灰灰:AwAICAYABAoAAREAOx8GCAQABRQ=.灰灰的小雨天:AwAHCBgABAoDCAAHAQgKKwBLZeUBBAoACAAHAQgKKwBLZeUBBAoAEgADAQgeHwBHyakABAoAAA==.灰烬:AwAICAcABAoAAA==.',['�']='炖菜:AwAGCAgABAoAAA==.',['�']='烈烈:AwAICAwABAoAAA==.',['�']='熊猫人:AwAGCAsABRQCCgAGAQhxAQA3eLkBBRQACgAGAQhxAQA3eLkBBRQAAA==.',['�']='爱丽斯菲尔:AwAECAQABAoAAA==.',['�']='牛某某:AwAECAIABRQAAA==.',['�']='猎手丶卢米安:AwABCAEABRQAAA==.',['�']='甜蜜兒:AwACCAIABRQAAA==.',['�']='眼子寒:AwAECAQABRQAAA==.',['�']='碇真嗣丶:AwACCAQABRQAAA==.',['�']='神牧娜娜:AwACCAgABRQDEwACAQizDgBNUKMABRQAEwACAQizDgBNUKMABRQACwACAQjYGwAN/GwABRQAAA==.',['�']='突然范特西:AwAICA4ABAoAAA==.',['�']='紹興老酒:AwACCAUABRQDFAAIAQgpGgBMfRwCBAoAFAAIAQgpGgBMfRwCBAoAEQAGAQg1QAAY3voABAoAAA==.',['�']='红茶黑巧拿铁:AwAICAUABAoAAA==.纳格兰花:AwAICAgABAoAAA==.',['�']='织田七海:AwADCAMABAoAAA==.',['�']='耀眼牧:AwAICAYABAoAAA==.',['�']='脑袋砸核桃:AwAECAcABAoAAA==.',['�']='舞艷:AwABCAEABAoAAA==.',['�']='茶冻乌龙:AwADCAgABRQDEQADAQgnCgAWVccABRQAEQADAQgnCgAWVccABRQAFAACAQhFHAAxDpEABRQAAA==.',['�']='莉莉雅:AwAGCAsABAoAAA==.',['�']='萨刃如麻:AwACCAIABRQAAA==.',['�']='蕃茄:AwACCAQABRQAAA==.',['�']='薛敌忾:AwABCAEABAoAAA==.',['�']='虚空鲶鱼:AwAHCAEABAoAAA==.',['�']='血鸣:AwABCAEABRQAAA==.',['�']='言不由衷丶:AwAECAQABRQAAA==.言无不禁:AwACCAQABRQAAA==.',['�']='语兰枫:AwAECAQABAoAAA==.',['�']='豆柿辣鸡:AwAGCAgABAoAAA==.',['�']='贪吃猪猪:AwABCAIABRQCFQAIAQjENwAtGrIBBAoAFQAIAQjENwAtGrIBBAoAAA==.',['�']='赞达拉非酋:AwACCAUABRQDBAAIAQgeUAAz5ugBBAoABAAIAQgeUAAz5ugBBAoABQAIAQhYEAA44d0BBAoAAA==.',['�']='遮沙避风了:AwADCAUABRQECwAIAQhuHgBNRrQBBAoACwAHAQhuHgA/DrQBBAoAEwAGAQhjJwBF+pABBAoAFgACAQiCXgAvUVYABAoAAA==.',['�']='镇丶岳:AwABCAEABRQAAA==.',['�']='陈嘉轩:AwAGCAQABRQAAA==.',['�']='雪山飞侠:AwAECAcABRQCFwAEAQhsEgBEC/cABRQAFwAEAQhsEgBEC/cABRQAAA==.零度久战:AwABCAEABAoAAA==.',['�']='韦小宝丶圣:AwAECAQABRQAAA==.',['�']='颠倒:AwAGCAQABAoAAA==.',['�']='骤雨不终日:AwAICAsABAoAAA==.',['�']='魁丶拔:AwAHCAgABAoAAA==.',['�']='鲨鱼丨:AwADCAMABAoAAA==.',['�']='麦麦薯条:AwAECAQABRQAAA==.',['�']='黑暗左手:AwACCAMABRQAAA==.',['�']='龍飛鳳舞丶:AwADCAMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end