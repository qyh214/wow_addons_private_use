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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Warrior-Fury','Warrior-Arms','Monk-Windwalker','Hunter-BeastMastery','Evoker-Devastation','Evoker-Preservation','Mage-Fire','Druid-Restoration','Priest-Healing','Hunter-Marksmanship','Monk-Mistweaver','Shaman-Restoration','Priest-Holy','Warlock-Destruction','Unknown-Unknown','Priest-Discipline','Warlock-Demonology',}; local provider = {region='CN',realm='生态船',name='CN',type='weekly',zone=42,date='2025-04-14',data={At='Atyourside:AwABCAQABRQDAQAIAQhcfQAulXIBBAoAAQAHAQhcfQA1i3IBBAoAAgABAQiBYAAE0QUABAoAAA==.',Br='Breezy:AwAHCAcABAoAAA==.',Im='Imperiusa:AwAICAgABAoAAA==.',Ku='Kumomo:AwAECAUABRQDAwACAQjGFABL+awABRQAAwACAQjGFABL+awABRQABAABAQhDEQA7c1UABRQAAA==.',Se='Selenec:AwAICBAABAoAAA==.',Yi='Yijiandh:AwAECAQABRQAAA==.',['�']='七仔:AwAECAQABRQAAQUAWZcGCBkABRQ=.三生猎月:AwAICAgABAoAAA==.临时工丶:AwAICBEABAoAAA==.丿丶浅唱:AwAICAsABAoAAA==.丿灬蕝版妖嘼:AwAECAQABRQAAA==.',['�']='五河琴里丶:AwAECAMABRQAAQYAPf8GCAkABRQ=.',['�']='伊瑞安娜:AwAFCAMABAoAAA==.',['�']='八佰一锤:AwAICBUABAoCAQAIAQj0KwBSSlACBAoAAQAIAQj0KwBSSlACBAoAAA==.',['�']='冰镇蜂蜜:AwADCA0ABRQCBgADAQhACQBVHRwBBRQABgADAQhACQBVHRwBBRQAAA==.',['�']='升腾助我丨来:AwAICAgABAoAAA==.南瓜二米粥:AwAICAgABAoAAA==.',['�']='只想划划氺:AwAGCBQABAoDBwAGAQh/LwAxgvMABAoABwAGAQh/LwAxgvMABAoACAACAQhAGgBOtJkABAoAAA==.',['�']='命运高达:AwAGCAYABAoAAA==.',['�']='哥丶尔赞:AwABCAEABAoAAA==.',['�']='壹转攻势:AwADCAUABRQCCQADAQgOLAAD0GEABRQACQADAQgOLAAD0GEABRQAAA==.',['�']='女神的断翼:AwAECAQABAoAAA==.',['�']='寧靜呢:AwAECBAABRQCCgAEAQiYBABNNQoBBRQACgAEAQiYBABNNQoBBRQAAQsAJskGCAYABRQ=.',['�']='射兽座:AwAECAQABRQAAA==.小佛:AwAICAgABAoAAA==.小十字军:AwAECAQABRQAAA==.',['�']='希厼瓦纳斯:AwAGCAYABRQCDAAGAQh4AAApEIUBBRQADAAGAQh4AAApEIUBBRQAAA==.',['�']='快乐小阿月巴:AwAECAQABRQCDQAIAQh4GwBB6/ABBAoADQAIAQh4GwBB6/ABBAoAAA==.',['�']='拔个垂杨柳:AwADCAQABRQAAA==.拿老公去換糖:AwACCAIABAoAAA==.',['�']='无形之影:AwADCAMABRQAAA==.',['�']='晴岚小涛:AwAICBsABAoCDgAIAQhrSQAbxj0BBAoADgAIAQhrSQAbxj0BBAoAAQ8AGdoBCAEABRQ=.',['�']='曉濤:AwAFCA4ABRQCCgAFAQgYBAAc3BIBBRQACgAFAQgYBAAc3BIBBRQAAA==.',['�']='望舒:AwAGCAEABAoAAA==.',['�']='林木秀:AwAFCAUABAoAAA==.',['�']='森林迷惑:AwAGCAgABAoAAA==.',['�']='歪歪女:AwAGCAEABAoAAA==.',['�']='為你瘋颠:AwAGCAUABAoAAA==.',['�']='爆柠椰奶茶:AwAICAIABAoCEAACAQhjCgAwM4sCBAoAEAACAQhjCgAwM4sCBAoAAREAAAAICAMABRQ=.爱吃爆米花:AwAECA4ABRQDAgAEAQiZCAA7VKYABRQAAgAEAQiZCAAn8KYABRQAAQACAQg4LQBEPIsABRQAAA==.',['�']='牛哥:AwACCAIABRQAAA==.',['�']='瑶池醉酒:AwAGCAYABAoAAA==.',['�']='疯狂老猫:AwAGCAUABAoAAA==.',['�']='白色枫叶:AwAICAgABAoAAA==.',['�']='真的扛不住:AwAECAQABRQAAA==.',['�']='米拉娜:AwAECAQABAoAAA==.',['�']='继清桀如新生:AwAECAQABAoAAA==.',['�']='脑浆炸裂少女:AwAFCAUABAoAAA==.',['�']='自在极意难崩:AwAGCAUABAoAAA==.',['�']='舞娅儿:AwABCAEABRQAAA==.',['�']='艾仒米:AwACCAMABRQAAA==.艾诺辛斯:AwABCAEABAoAAA==.',['�']='荼蘼小涛:AwABCAEABRQDDwAIAQgWNwAZ2jYBBAoADwAIAQgWNwAZTzYBBAoAEgAEAQjmVwAQlJEABAoAAA==.',['�']='萨不满:AwACCAQABRQAAA==.',['�']='謎丶語:AwAICAgABAoAAA==.',['�']='诗人握持:AwADCAMABRQAAA==.',['�']='谁云之思:AwAGCAYABAoAAA==.',['�']='赌毒不共戴天:AwAICAgABAoAAA==.',['�']='轩仔如枫:AwAICAgABAoAAA==.',['�']='邂逅烟寒:AwACCAIABAoAAA==.',['�']='镜华:AwAICBgABAoDEAAIAQg8BgBan7gCBAoAEAAIAQg8BgBZk7gCBAoAEwADAQh7QwBGw5IABAoAAA==.',['�']='雨木:AwAECAgABRQCDQAEAQjHCQA5LvgABRQADQAEAQjHCQA5LvgABRQAAA==.',['�']='青鸟飝鱼:AwAECAQABAoAAA==.',['�']='頑皮西米露:AwAHCA0ABAoAAA==.',['�']='风铃的牧牧:AwADCAMABRQAAA==.',['�']='鱼泪满江:AwADCAMABAoAAA==.',['�']='黑色逆流:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end