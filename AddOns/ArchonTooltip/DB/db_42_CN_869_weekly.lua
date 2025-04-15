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
 local lookup = {'Monk-Windwalker','Evoker-Devastation','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Evoker-Augmentation','Warrior-Protection','Mage-Frost','Mage-Fire','Paladin-Retribution','Unknown-Unknown','Warrior-Fury','Priest-Shadow','Hunter-BeastMastery','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Rogue-Outlaw','Priest-Holy',}; local provider = {region='CN',realm='阿格拉玛',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ad='Adnachiel:AwAGCBIABAoAAA==.',Al='Alberta:AwACCAIABAoAAA==.All:AwACCAIABRQAAA==.',As='Asmodel:AwACCAIABAoAAA==.',Br='Breezing:AwACCAIABAoAAA==.',Co='Cokie:AwAICBAABAoAAA==.Colab:AwAGCAYABAoAAQEAUbUHCAcABRQ=.',Ha='Haerin:AwAECAQABRQCAgAEAQiEBgBCIQsBBRQAAgAEAQiEBgBCIQsBBRQAAA==.',Hi='Hingir:AwACCAMABRQAAA==.',Li='Lisa:AwACCAIABAoAAA==.',Lu='Luxanna:AwABCAEABAoAAA==.',So='Sona:AwACCAMABRQEAwAIAQjEGABAnCECBAoAAwAIAQjEGABAnCECBAoABAABAQhPZgAbFToABAoABQABAQhSPwATOzQABAoAAA==.',Ti='Tifieya:AwABCAEABAoAAA==.',['�']='一队那个洒满:AwAGCAYABAoAAA==.不丨离:AwAECAQABAoAAA==.丶仟年杀:AwADCAMABAoAAA==.',['�']='二九一十八:AwADCAIABRQDAgAIAQjOGQBEhMgBBAoAAgAHAQjOGQA/IcgBBAoABgADAQjTAgBU1gwBBAoAAA==.井中月:AwAECAIABRQAAA==.',['�']='从此不空车:AwACCAIABRQAAA==.仙灵:AwABCAEABRQCAQAIAQjlDABN6XUCBAoAAQAIAQjlDABN6XUCBAoAAA==.',['�']='做死:AwADCAgABRQCBwADAQh5BQAWWKAABRQABwADAQh5BQAWWKAABRQAAA==.',['�']='光与暗之子:AwAECAQABRQAAA==.',['�']='再诞之翼:AwAICAoABAoAAA==.',['�']='刑裁者:AwAFCAkABAoAAA==.',['�']='半只菜鸡:AwAECAQABRQAAA==.卡德减:AwACCAIABRQDCAAHAQhXIABRpOsBBAoACAAHAQhXIABRpOsBBAoACQAFAQgtXAAzf+wABAoAAA==.',['�']='去他马的奥丁:AwACCAIABRQAAA==.去他骂的奥丁:AwAECAQABRQAAA==.',['�']='听雨落花丶:AwACCAIABAoAAA==.',['�']='呆僧:AwAECAQABRQAAA==.',['�']='咕咕丶鸡:AwAICAgABAoAAA==.',['�']='啦啦小魔仙:AwABCAEABAoAAA==.',['�']='喬治阿瑪尼:AwAICAgABAoAAA==.喵弎菇凉:AwAHCAcABAoAAA==.',['�']='圣光照死你:AwAICAwABAoAAA==.圣光麦乐鸡:AwADCAQABRQCCgAIAQg5FABaS7oCBAoACgAIAQg5FABaS7oCBAoAAA==.圣昭灵:AwACCAIABAoAAA==.',['�']='塞林木寄卖:AwAGCAYABAoAAA==.',['�']='多来米:AwAICAsABAoAAA==.大鎏特鎏:AwAICAsABAoAAA==.天河王嘉尔:AwAECAQABRQAAQkAQ8QICAcABRQ=.',['�']='奥利弗奎恩:AwAFCAoABAoAAA==.好吃不如饺子:AwAICAgABAoAAA==.',['�']='安堂丽治:AwAICAgABAoAAQsAAAAECAQABRQ=.宝宝顶上:AwAHCAgABAoAAA==.',['�']='寒慕雨:AwAGCAYABAoAAA==.',['�']='小叮当:AwAGCAMABRQAAA==.小小吼:AwAGCAYABRQCDAAGAQhvAAA8tNsBBRQADAAGAQhvAAA8tNsBBRQAAA==.小猹:AwACCAMABAoAAA==.',['�']='干涉那个小德:AwABCAEABRQAAA==.幻觉:AwACCAQABAoAAA==.',['�']='张疯子:AwAECAQABRQAAA==.',['�']='往事:AwAECAQABRQAAA==.',['�']='心之飞越:AwAGCAYABAoAAA==.',['�']='恐惧脚步:AwABCAIABRQAAA==.',['�']='悔意灬思忆:AwAECAQABRQAAA==.',['�']='承天之佑:AwAECAMABRQAAA==.',['�']='摩卡星冰乐:AwAECAQABRQAAA==.',['�']='斯文敗类:AwAICAgABAoAAA==.',['�']='有心人无名仕:AwAFCAUABAoAAA==.',['�']='板甲三刹:AwAECAQABRQAAA==.',['�']='果果的小巫婆:AwACCAIABAoAAA==.',['�']='柒琪:AwAICAgABAoAAA==.',['�']='格罗玛什:AwACCAIABRQAAA==.',['�']='棂羽衣:AwABCAMABRQAAA==.',['�']='欧皇毛小妹:AwAICAoABAoAAA==.',['�']='水元素:AwAICA0ABAoAAQ0APEoGCAoABRQ=.',['�']='源神:AwACCAQABRQDCAAIAQgKFwBGHiwCBAoACAAIAQgKFwBGHiwCBAoACQACAQhNlgAMNy8ABAoAAA==.',['�']='無敌晓眼睛:AwAECAgABRQCCQAEAQjoBgBgu08BBRQACQAEAQjoBgBgu08BBRQAAQsAAAAICAIABRQ=.',['�']='爪妹醬:AwADCAMABRQCDgAIAQgsPAA5W+kBBAoADgAIAQgsPAA5W+kBBAoAAA==.',['�']='牧流冰:AwACCAIABRQAAA==.物丸大队长:AwACCAIABRQAAA==.物丸小混饭:AwAECAQABRQAAA==.',['�']='犬来八荒:AwAECAQABRQAAQsAAAAECAQABRQ=.',['�']='狐狸镜子:AwACCAMABRQAAA==.',['�']='猎杀麦乐鸡:AwAGCAYABAoAAA==.',['�']='琪琪丶:AwAICAgABAoAAA==.琼妍:AwACCAIABAoAAA==.',['�']='生杀予夺:AwAECAsABRQDDwAEAQj8BQBOwwEBBRQADwAEAQj8BQBKFQEBBRQAEAADAQiLBgBBuvYABRQAAA==.',['�']='瞎来来:AwAECAgABRQCEQAEAQjNDwA5TvAABRQAEQAEAQjNDwA5TvAABRQAAA==.',['�']='神人梅西:AwAFCAQABRQEEAAIAQi+DQBC0wkCBAoAEAAIAQi+DQBBMQkCBAoAEgADAQh8EgA1zoUABAoADwACAQjEPwAiu0AABAoAAA==.神圣的番茄:AwADCAMABAoAAA==.',['�']='糖果丶呆猎:AwAHCAgABAoAAA==.',['�']='红手阿风:AwAICAgABAoAAA==.纯甄土哥:AwAECAQABAoAAA==.纷乱雪月花:AwAECAQABAoAAA==.',['�']='终极节拍:AwAICAgABAoAAQkAUhwHCAwABRQ=.维型生物:AwABCAEABAoAAA==.',['�']='羽霍飞:AwAECAQABAoAAA==.',['�']='胆囊炎:AwAECAQABRQAAA==.',['�']='脚趾很性感:AwAICAgABAoAAA==.',['�']='致盲:AwAECAQABRQAAA==.',['�']='苏州白便:AwAGCBAABAoAAA==.',['�']='茅场晶彦:AwABCAEABAoAAA==.',['�']='萌萌猫:AwAHCAIABAoAAA==.萨鲁法爾大王:AwAHCAcABAoAAQsAAAAGCAQABRQ=.',['�']='葉子辰丶:AwAHCAEABAoAAA==.',['�']='虚锤子方丈:AwAFCAMABAoAAA==.',['�']='血鬼狂人:AwAECAsABRQCCgAEAQjwAgBjnlwBBRQACgAEAQjwAgBjnlwBBRQAAA==.',['�']='西尔瓦娜斯:AwAICAgABAoAAA==.西瓜癫掉:AwAECAQABRQAAA==.',['�']='詸罗:AwAECAQABAoAAA==.',['�']='超想养只猫:AwACCAIABRQAAA==.',['�']='达光贵人:AwADCAQABRQAAA==.',['�']='迷失的辛多雷:AwAECAQABRQAAA==.',['�']='铁扇:AwACCAIABAoAAA==.',['�']='陈平安:AwAICA4ABAoAAA==.',['�']='雪娜蕊斯:AwAGCAoABRQDEwAGAQhrBAAoPAoBBRQAEwAFAQhrBAAd9woBBRQADQACAQhCEwAns6gABRQAAA==.',['�']='风向决定发型:AwAICAYABAoAAA==.风斩冰华:AwAFCAUABAoAAA==.',['�']='香香熊:AwAICAgABAoAAA==.',['�']='骇人鲸:AwAGCAYABRQCDQAGAQjaAABKteQBBRQADQAGAQjaAABKteQBBRQAAA==.',['�']='鬼拳:AwAICAgABAoAAA==.',['�']='黑旋风武松:AwAGCAoABAoAAA==.黯影谜踪:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end