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
 local lookup = {'Paladin-Retribution','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Arcane','Mage-Fire','Mage-Frost','Paladin-Protection','Warrior-Fury','Druid-Balance','DeathKnight-Unholy','Monk-Brewmaster','Priest-Shadow','Priest-Discipline','Priest-Holy','Rogue-Assassination','Rogue-Outlaw','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','DemonHunter-Havoc',}; local provider = {region='CN',realm='鹰巢山',name='CN',type='weekly',zone=42,date='2025-04-15',data={As='Asdestiny:AwAGCAYABAoAAA==.',Ch='Chrisp:AwADCAcABRQCAQADAQimGwAmh+IABRQAAQADAQimGwAmh+IABRQAAA==.',Fl='Flyingeggegg:AwAECAQABRQAAQIAAAAICAMABRQ=.',Ge='Genius:AwADCAMABAoAAA==.',Ha='Handwin:AwAECBEABRQDAwAEAQiUFQArsH4ABRQABAACAQh3LAAyZosABRQAAwADAQiUFQAYin4ABRQAAA==.',Ka='Kapa:AwAFCAYABAoAAA==.',La='Lansseax:AwACCAIABRQAAA==.',Mc='Mcga:AwACCAQABRQEBQAIAQiABwBE+nkBBAoABgAIAQgHNgA5v7IBBAoABQAGAQiABwA8y3kBBAoABwAFAQgKRQA8wCoBBAoAAQIAAAAECAQABRQ=.',Ms='Msuqq:AwAFCAQABRQAAA==.',Po='Polaris:AwAECAgABRQCAQAEAQggBgBUJTQBBRQAAQAEAQggBgBUJTQBBRQAAA==.',Re='Reiayanami:AwABCAEABRQAAA==.',Sa='Sawa:AwAICAQABRQAAA==.Sawatani:AwACCAIABAoAAA==.',To='Tobacoo:AwACCAIABRQAAA==.',['�']='不就你一个么:AwAFCAsABAoAAA==.不必等天晴:AwAICAgABAoAAA==.丨秋乌磊丨:AwAECAcABRQCCAAEAQiuBABLpgIBBRQACAAEAQiuBABLpgIBBRQAAQgANSIGCAYABRQ=.丶灬尐寳:AwAFCAUABAoAAA==.',['�']='乐乐茶:AwAECAgABRQCAwAEAQgiDgAow8IABRQAAwAEAQgiDgAow8IABRQAAA==.',['�']='仙本那:AwACCAIABRQAAA==.',['�']='伊斯:AwAECAQABRQAAA==.众生万物之父:AwAICAgABAoAAQIAAAAECAQABRQ=.',['�']='侠义天下:AwABCAEABAoAAA==.',['�']='八福子:AwAECAkABRQCCQAEAQh8BwBGfBkBBRQACQAEAQh8BwBGfBkBBRQAAA==.',['�']='冰之青雉丶:AwACCAIABRQAAA==.冷冷的冰鱼:AwAECAQABRQAAA==.',['�']='划船看雪落:AwAFCBEABRQCBgAFAQjuBwAz6z8BBRQABgAFAQjuBwAz6z8BBRQAAA==.',['�']='十一境武夫:AwADCAMABAoAAA==.华亭海小商贩:AwABCAEABRQAAA==.',['�']='呀唛德:AwAHCBcABAoCCgAHAQgTHQBTbEICBAoACgAHAQgTHQBTbEICBAoAAA==.呆呆丶小囡:AwAECAQABRQAAA==.呆德瞎:AwAHCAcABAoAAA==.呆德骑:AwAICAgABAoAAA==.呦丶宋威:AwABCAEABRQCBwAIAQjDEQBLEFYCBAoABwAIAQjDEQBLEFYCBAoAAA==.命運的落葉:AwAECAUABRQCAQAEAQgFGAAtWe0ABRQAAQAEAQgFGAAtWe0ABRQAAA==.',['�']='图样:AwAFCAQABAoAAA==.',['�']='坚持动态清零:AwADCAMABAoAAA==.坚持接种疫苗:AwAECAMABRQAAA==.',['�']='大猫哥:AwAFCAgABAoAAA==.大苹果:AwAECAQABAoAAA==.大酒缸:AwAICBAABAoAAA==.天火丶天火:AwACCAIABRQAAA==.',['�']='套住唔好玩:AwAFCAMABAoAAA==.',['�']='小游猪猪:AwACCAIABRQAAA==.尛虾米:AwADCAcABRQCBwADAQhvAwBT1BMBBRQABwADAQhvAwBT1BMBBRQAAA==.',['�']='康斯坦汀:AwAECAgABRQCAQAEAQg1EABDywYBBRQAAQAEAQg1EABDywYBBRQAAA==.',['�']='强力混子:AwADCAUABAoAAA==.',['�']='彬少:AwAECAUABAoAAA==.影兰:AwAECA0ABRQCBwAEAQhwAgBXDCEBBRQABwAEAQhwAgBXDCEBBRQAAA==.',['�']='怠惰丶:AwAGCAIABRQCCwACAQjzFQBLS6wABRQACwACAQjzFQBLS6wABRQAAA==.',['�']='恋爱高手:AwAECAYABRQCDAAEAQhwBAAkNaEABRQADAAEAQhwBAAkNaEABRQAAA==.',['�']='我有一个特长:AwADCAEABRQAAA==.',['�']='无语丨灬橙子:AwAECAwABRQDBgAEAQiyFQBObuoABRQABgAEAQiyFQA6DuoABRQABQAEAAgAAABH0gAABRQAAA==.旧得很好看:AwAECAgABRQEDQAEAQjfDgAj39MABRQADQAEAQjfDgAj39MABRQADgACAQiHHAAKNWMABRQADwABAQj5IgAAAAAABRQAAA==.',['�']='星光灭绝:AwAECAQABRQCAQAIAQjbCQBdq+wCBAoAAQAIAQjbCQBdq+wCBAoAAA==.星宸:AwACCAIABAoAAA==.星空下的幻想:AwAGCAgABRQCAQAEAQh9CwBVNxcBBRQAAQAEAQh9CwBVNxcBBRQAAA==.',['�']='暴暴熊:AwAICAgABAoAAA==.',['�']='木子星辰:AwACCAIABAoAAA==.',['�']='橘阳菜丶:AwAECAQABRQAAA==.橙心丶:AwADCAMABRQAARAAVl0FCBEABRQ=.',['�']='欢乐树的喷友:AwAGCAgABAoAAA==.',['�']='毒菇猫猫:AwAECAQABRQAAA==.',['�']='沐沐丨丶:AwAGCAUABRQDDgAFAQhmBwA/HAUBBRQADgAEAQhmBwBDNQUBBRQADQABAQi0GgA3pGAABRQAAQ0AMzEICAQABRQ=.',['�']='泉鸽:AwADCAIABAoAAA==.泣雷:AwABCAEABAoAAA==.',['�']='漠漠摸鱼:AwACCAIABAoAAA==.',['�']='潜行的奈亚子:AwADCAgABRQCEAADAQjOBQA+NgMBBRQAEAADAQjOBQA+NgMBBRQAAA==.',['�']='灾难狂欢丶:AwAECAQABRQAAA==.',['�']='煜柯宝贝:AwABCAEABAoAAA==.',['�']='牛哥向前冲:AwABCAEABAoAAA==.牛德一塌糊涂:AwADCAMABAoAAA==.',['�']='獨奏悲歌:AwAECAQABRQAAA==.',['�']='癞皮狗:AwAICAcABAoAAA==.',['�']='睡梦罗汉拳:AwABCAEABRQAAA==.',['�']='碧火青天:AwAECAQABAoAAA==.',['�']='秋丶秋:AwAECAgABRQCCwAEAQi/BABb2CwBBRQACwAEAQi/BABb2CwBBRQAAA==.',['�']='索马里渔夫:AwAICAcABAoAAA==.',['�']='红肚兜丶:AwACCAIABRQDEAAIAQjdAwBczr4CBAoAEAAIAQjdAwBczr4CBAoAEQACAQiqFwAQDTQABAoAAA==.',['�']='维莱里奥:AwAGCAYABAoAAA==.绿皮鬼:AwACCAQABRQEEgAIAQgAMQBEypoBBAoAEgAIAQgAMQAyXpoBBAoAEwAEAQiHKwBCswMBBAoAFAABAQiGNQBN0lgABAoAAA==.',['�']='翔里有毒:AwAICAgABAoAAQYAJ70GCAoABRQ=.',['�']='肉弹丶:AwABCAEABRQAAA==.',['�']='脆皮甜甜圈:AwAGCAQABRQCAQAIAQiPKABUoWcCBAoAAQAIAQiPKABUoWcCBAoAAA==.',['�']='花村清洁工:AwAGCAYABAoAAA==.',['�']='蒹丶葭:AwAECAgABRQCBgAEAQjWFAA7qe0ABRQABgAEAQjWFAA7qe0ABRQAAA==.',['�']='蛋蛋不太傲娇:AwAFCAcABAoAAA==.',['�']='蠢胖子:AwAGCAoABRQCFQAGAQjUAABNU/0BBRQAFQAGAQjUAABNU/0BBRQAAA==.',['�']='西雅図夜未眠:AwAHCA4ABAoAAA==.',['�']='贰魃垨丶咕天:AwAGCAYABRQCCAAGAQg8AQA1IosBBRQACAAGAQg8AQA1IosBBRQAAA==.',['�']='路在丶何方:AwACCAIABRQAAA==.',['�']='都是泪:AwAGCAYABAoAAA==.',['�']='采矿学训练师:AwAGCAYABAoAAA==.',['�']='钉崎丶野蔷薇:AwAGCAYABRQCCwAGAQhiAABSIQACBRQACwAGAQhiAABSIQACBRQAAA==.',['�']='阿弥陀佛:AwAECAQABAoAAA==.阿路灬:AwAECAMABRQAAA==.',['�']='领萨:AwAECAQABRQAAA==.風雲啸:AwACCAIABAoAAA==.',['�']='风一样飘:AwADCAgABRQCAQADAQj8IAAbo8kABRQAAQADAQj8IAAbo8kABRQAAA==.风舞惊雷:AwADCAMABAoAAA==.飞过苍海:AwAHCAkABAoAAA==.',['�']='麦子茶:AwAICAgABAoAAA==.',['�']='黛朵的悲歌:AwAECAQABRQAAQIAAAAICAEABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end