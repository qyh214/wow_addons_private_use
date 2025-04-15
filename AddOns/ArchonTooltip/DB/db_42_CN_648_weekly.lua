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
 local lookup = {'Warrior-Fury','Warrior-Protection','Unknown-Unknown','Monk-Mistweaver','Shaman-Enhancement','Druid-Restoration','Mage-Frost','DemonHunter-Vengeance','DemonHunter-Havoc','Mage-Fire','Druid-Balance','Shaman-Restoration',}; local provider = {region='CN',realm='安其拉',name='CN',type='weekly',zone=42,date='2025-04-14',data={Co='Copycat:AwAECAQABRQAAA==.',Du='Dualsnse:AwABCAEABRQAAA==.',Fa='Fastrong:AwACCAIABAoAAA==.',Ka='Kadenz:AwAGCAYABAoAAA==.',Ko='Kobus:AwAECAQABRQAAA==.',Mi='Mischievous:AwAICAoABAoAAA==.',Py='Pyke:AwAFCAUABAoAAA==.',Re='Red:AwACCAIABAoAAA==.',Wi='Withered:AwABCAIABAoAAA==.',Yc='Ycy:AwAICA4ABAoAAA==.',['�']='一身排骨:AwAICB0ABAoDAQAIAQiPMwAeYI0BBAoAAQAIAQiPMwAeYI0BBAoAAgAFAQiQJQAZnqEABAoAAA==.三千玉龙:AwACCAIABRQAAA==.上帝就是个兽:AwAICA4ABAoAAA==.丨姐夫丶壊蛋:AwABCAEABAoAAA==.',['�']='乄棍歐巴:AwAECAQABRQAAA==.',['�']='伊俐蛋蛋:AwADCAMABAoAAA==.',['�']='光之末裔:AwADCAMABAoAAA==.八奈见:AwAHCAcABAoAAQMAAAABCAEABRQ=.',['�']='凯恩丶血蹄:AwAICBAABAoAAA==.',['�']='卜露露:AwAICAgABAoAAA==.',['�']='啥都想试小德:AwAHCA0ABAoAAA==.啥都想试试:AwABCAIABRQCBAAIAQgtHQA6m+MBBAoABAAIAQgtHQA6m+MBBAoAAA==.',['�']='圣骑小妹:AwAECAcABAoAAA==.',['�']='坦格利安:AwABCAEABRQAAA==.',['�']='壹贰叁:AwAICAgABAoAAA==.',['�']='复活节酒桶:AwACCAMABRQAAA==.夏日清凉:AwAFCAcABAoAAA==.天涯帅帅:AwAECAQABRQAAA==.天空的畅想:AwADCAUABAoAAA==.天道有眷:AwAECAQABAoAAA==.天隙流光:AwACCAIABAoAAA==.',['�']='学习与实践:AwEDCAkABRQCBQADAQhpBgA9OgUBBRQABQADAQhpBgA9OgUBBRQAAQMAAAAICAMABRQ=.学术混子:AwACCAIABRQAAA==.',['�']='宝儿姐:AwAECAQABRQAAA==.',['�']='尘封的旋律:AwAECAQABRQAAA==.尤娜塔斯:AwABCAEABRQAAA==.尼可罗罗:AwABCAEABAoAAA==.',['�']='帝皇的猎魔人:AwAECAQABAoAAA==.',['�']='扒蒜老洪:AwACCAIABAoAAA==.',['�']='改名五十:AwABCAEABAoAAA==.',['�']='星月迷途:AwAECAIABRQAAA==.',['�']='會發光的黑手:AwAECAcABAoAAA==.',['�']='杨喵喵:AwACCAIABAoAAA==.',['�']='柒芯海棠:AwAECAQABRQAAA==.',['�']='森林里的椰子:AwAGCAQABRQAAA==.森林里的风铃:AwAECAQABRQAAA==.',['�']='武学研究员:AwAFCAUABAoAAQYAOToBCAEABRQ=.',['�']='残隠殇丶玥:AwACCAQABRQCBwAIAQh1EABRLV0CBAoABwAIAQh1EABRLV0CBAoAAA==.',['�']='永无止境:AwAECAQABAoAAA==.',['�']='泪无痕:AwABCAEABAoAAA==.',['�']='灭杀:AwAHCAUABAoAAA==.',['�']='玖怜:AwAFCAsABAoAAA==.玩好就去学习:AwAICAgABAoAAA==.玩手电的黑猫:AwAGCAYABAoAAA==.',['�']='甜妹妹:AwAECAgABRQDCAAEAQjoBQAuIMIABRQACQAEAQjmEgAjNuAABRQACAAEAQjoBQAs8cIABRQAAA==.',['�']='白骑大队长:AwAFCAcABAoAAA==.',['�']='眷恋咖啡:AwAICAgABAoAAA==.',['�']='粥润发:AwAICA0ABAoAAA==.',['�']='群尸玩过界:AwAGCAIABAoAAA==.',['�']='翎丨苹果派:AwAGCAYABAoAAQoAMkEGCAgABRQ=.翎兰:AwAECAQABRQAAA==.翡翠捕梦者:AwABCAEABRQCCwAIAQiBCABb884CBAoACwAIAQiBCABb884CBAoAAA==.',['�']='老孟:AwAECAQABAoAAA==.',['�']='聖贤:AwAGCAYABAoAAA==.',['�']='英雄的心恶魔:AwACCAIABAoAAA==.',['�']='莉亚德琳丶:AwABCAEABRQAAA==.',['�']='血腥飝非飛:AwABCAIABRQCBwAIAQhIDgBQm3ACBAoABwAIAQhIDgBQm3ACBAoAAA==.',['�']='親爱灬德:AwAGCAEABAoAAA==.',['�']='辰曦:AwAICAkABAoAAA==.',['�']='迪俪热巴:AwACCAUABRQCDAACAQi/FwA3KpgABRQADAACAQi/FwA3KpgABRQAAA==.',['�']='锐雯:AwAHCBIABAoAAA==.',['�']='阿仁开无敌:AwAICAgABAoAAA==.阿布集团总裁:AwAICAgABAoAAA==.',['�']='雪融融:AwAECAYABAoAAA==.',['�']='風行者的挽歌:AwADCAMABAoAAA==.',['�']='驱灵人:AwAICAgABAoAAA==.',['�']='骑猪去流浪:AwAECAQABAoAAA==.',['�']='鬼迷日眼:AwAGCAYABAoAAA==.',['�']='鱼丸粗面:AwADCAQABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end