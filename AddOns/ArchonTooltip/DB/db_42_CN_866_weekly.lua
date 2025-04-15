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
 local lookup = {'DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Monk-Windwalker','Rogue-Subtlety','Warrior-Fury','Warrior-Protection','Warrior-Arms','Warlock-Destruction','DemonHunter-Havoc','DemonHunter-Vengeance','Priest-Holy','Hunter-BeastMastery','Paladin-Retribution','Paladin-Holy','Monk-Mistweaver','Druid-Restoration','Rogue-Assassination',}; local provider = {region='CN',realm='阿拉索',name='CN',type='weekly',zone=42,date='2025-04-15',data={An='Angelamerkel:AwADCAQABAoAAA==.',Da='Davinci:AwAECAQABRQAAA==.',En='Eni:AwAECAQABAoAAA==.',Gh='Ghorn:AwADCAMABAoAAA==.',Gu='Gunpla:AwAICBQABAoEAQAIAQh/EwAt5DkBBAoAAQAGAQh/EwA2ODkBBAoAAgAGAQgUPQATT6oABAoAAwAFAQi4gQAW5qIABAoAAA==.',Hi='Hideonbush:AwAICAgABAoAAA==.',Ho='Holylight:AwACCAEABAoAAA==.',Ka='Kandr:AwAICAgABAoAAA==.',Le='Legendseeker:AwAECAIABRQAAA==.',Lu='Lunara:AwAECAQABRQAAQQATEgICAkABRQ=.',Mi='Misskidney:AwACCAYABRQCBQAIAQi9CABKTl8CBAoABQAIAQi9CABKTl8CBAoAAA==.',Na='Naowh:AwAECAQABRQAAA==.',Pa='Paladinlpc:AwAECAQABRQAAA==.',Ro='Rockin:AwAECAQABRQAAA==.',['�']='一圣王一:AwACCAMABRQAAA==.三修神棍:AwAECAQABRQAAA==.丨柚如何丶:AwAECAQABRQAAA==.丶西瓜粥:AwACCAIABRQAAA==.丷噜噜:AwAECAcABAoAAA==.丷噜班:AwAECAQABAoAAA==.主攻下三路:AwAFCAUABAoAAA==.',['�']='何田田丶:AwABCAEABAoAAA==.',['�']='信仰战神:AwACCAIABRQEBgAIAQiRHQBCKxMCBAoABgAIAQiRHQA/ShMCBAoABwABAQjsNQBCjUoABAoACAABAQgQWQAy1EIABAoAAA==.',['�']='冰山无角:AwACCAIABRQCCQAHAQiUHgBRi/0BBAoACQAHAQiUHgBRi/0BBAoAAA==.冰美式:AwADCAEABAoAAA==.冷冷酱:AwACCAQABRQAAA==.',['�']='凉凉哟:AwACCAIABAoAAA==.',['�']='别烦夏天丶:AwACCAMABRQAAA==.',['�']='千与:AwAICA4ABAoAAA==.卡尼贰:AwAICAgABAoAAA==.',['�']='呆萌杭特:AwADCAUABRQDCgADAQgtJAAOqYEABRQACgACAQgtJAAU2oEABRQACwABAQj0FwACRyEABRQAAA==.呦佑:AwABCAEABAoAAA==.',['�']='咸蛋蛋灬:AwAECAQABRQAAA==.',['�']='哇哦我超凶:AwAICAgABAoAAA==.哑童:AwADCAMABAoAAA==.哼哼就饱了:AwACCAIABAoAAA==.',['�']='啊菇云:AwAECAQABRQAAA==.',['�']='喜欢后射:AwAECAYABAoAAA==.',['�']='囡囡大魔王:AwAGCAYABAoAAA==.',['�']='圣光之影:AwABCAEABRQAAA==.',['�']='埃塞俄丶比亚:AwACCAIABRQAAA==.',['�']='塔娜托斯:AwAECAEABAoAAA==.',['�']='夜鸣丶:AwABCAEABAoAAA==.大名丨鼎鼎:AwACCAEABAoAAA==.大師:AwAGCAkABAoAAA==.大盘鸡下饭:AwACCAQABRQAAA==.天使在歌唱:AwAICBAABAoAAA==.太古抠脚天尊:AwAICAQABRQAAA==.',['�']='奉圣灵之名:AwACCAMABRQAAA==.奥蕾莉:AwABCAIABRQAAA==.奶小僧:AwADCAMABRQAAA==.奶爆:AwAGCAYABAoAAA==.奶骑:AwAICAgABAoAAQYAF38HCAgABRQ=.她不值得思念:AwAECAQABAoAAA==.',['�']='如光似影:AwADCAUABAoAAA==.',['�']='小嘴香香:AwADCAIABAoAAA==.小孩的恋爱:AwAHCAgABAoAAA==.小小色调:AwAECAQABAoAAA==.',['�']='左丶翼:AwAICAgABAoAAA==.',['�']='市一中林志玲:AwAECAQABRQAAA==.',['�']='当仁不让:AwAICAgABAoAAA==.',['�']='怀特邁恩:AwAICBAABAoAAA==.',['�']='恶魔宝宝:AwACCAIABAoAAA==.',['�']='感觉要到位:AwACCAUABRQCDAACAQiaEAA/nJIABRQADAACAQiaEAA/nJIABRQAAA==.',['�']='我以為:AwAHCAEABAoAAA==.我是灵牙:AwADCAMABAoAAA==.我没瞎:AwAICAgABAoAAA==.',['�']='星星:AwACCAIABRQAAA==.',['�']='晓哓德:AwADCAMABAoAAA==.',['�']='暴力福娃:AwAGCAcABAoAAA==.',['�']='有点味道:AwAGCAQABAoAAA==.有辱斯文:AwACCAMABRQAAA==.',['�']='杀手二号:AwAFCAYABAoAAA==.',['�']='楪祈公主:AwAECAUABAoAAA==.',['�']='死魂灵:AwAGCAwABAoAAA==.',['�']='永恒的二十:AwACCAIABAoAAA==.',['�']='汤姆克噜斯:AwAFCAcABAoAAA==.汪小猪:AwAECAQABRQAAA==.',['�']='沒心沒肺:AwAICAYABAoAAA==.',['�']='浪漫无用:AwAHCAYABAoAAA==.',['�']='潇湘风笛:AwAHCBsABAoDBgAHAQjGPwApgU8BBAoABgAGAQjGPwAnnk8BBAoACAAFAQhiPwAY9bAABAoAAA==.',['�']='烟火:AwACCAIABAoAAA==.',['�']='無氧旅人:AwADCAMABAoAAA==.焮燃:AwACCAYABRQCAwACAQiJHQAVfIQABRQAAwACAQiJHQAVfIQABRQAAA==.',['�']='熊大蛋:AwAGCAYABAoAAA==.',['�']='特斯拉:AwAECAQABRQAAA==.特萨维斯邪刃:AwABCAEABRQAAA==.',['�']='狼外婆啊灬:AwABCAEABAoAAA==.',['�']='猫小白:AwAECAEABRQCDQAIAQgtJgBIPUgCBAoADQAIAQgtJgBIPUgCBAoAAA==.猫猫:AwAECAgABAoAAQ0ASD0ECAEABRQ=.',['�']='珠仙剑阵决:AwACCAIABAoAAA==.',['�']='癫龘:AwABCAEABAoAAA==.白眉毛:AwACCAEABRQAAA==.',['�']='秋池渊:AwACCAIABAoAAA==.',['�']='笣俎婆:AwAICAgABAoAAA==.',['�']='紫月音:AwAGCAcABAoAAA==.',['�']='羅賓漢:AwAECAQABRQAAA==.羲和:AwADCAYABRQDDgADAQggIAAYCs4ABRQADgADAQggIAAYCs4ABRQADwABAQirDwBD4VEABRQAAA==.',['�']='胥高:AwAICA0ABAoAAA==.',['�']='艾丽娅娜:AwAHCAoABAoAAA==.',['�']='荣誉即好命:AwAHCAQABAoAAA==.',['�']='薛紫夜丶:AwAGCAYABRQCEAAGAQikAgAftoUBBRQAEAAGAQikAgAftoUBBRQAAA==.',['�']='蛇喰梦子丨:AwAICBYABAoCCgAIAQhkJQBE6A0CBAoACgAIAQhkJQBE6A0CBAoAAA==.',['�']='解语花:AwAFCAYABAoAAA==.',['�']='调野太祥:AwABCAEABRQAAA==.',['�']='迷路的风筝:AwAECAQABAoAAA==.',['�']='醉春烟:AwAGCAYABAoAAA==.',['�']='野性的鹌鹑:AwACCAIABRQAAREAKLMICAEABRQ=.',['�']='阿斯蒂芬丶谌:AwABCAEABAoAAA==.',['�']='雪后初晴:AwAECAQABRQAAA==.零星叶:AwADCAMABAoAAA==.',['�']='顽强的凯瑟琳:AwAFCAUABAoAAA==.',['�']='马维影之歌:AwAICBYABAoDEgAIAQhQBgBX5pICBAoAEgAIAQhQBgBTpZICBAoABQAIAQjfBgBRRH8CBAoAAA==.',['�']='龍仔史:AwAICAgABAoAAA==.龍少:AwACCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end