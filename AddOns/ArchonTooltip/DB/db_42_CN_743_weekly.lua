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
 local lookup = {'Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Brewmaster','Monk-Windwalker','Shaman-Restoration','Mage-Fire','Warrior-Fury','Druid-Guardian','Druid-Restoration','Unknown-Unknown','Mage-Frost','Monk-Mistweaver','Paladin-Retribution','Priest-Shadow','Priest-Holy','DeathKnight-Frost','Warrior-Arms','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','DemonHunter-Havoc',}; local provider = {region='CN',realm='火羽山',name='CN',type='weekly',zone=42,date='2025-04-14',data={Cr='Cristina:AwAECAQABRQAAA==.',De='Deepsee:AwADCAMABAoAAA==.',Fr='Franklin:AwAFCAUABAoAAA==.',Je='Jeanerent:AwADCAoABRQCAQADAQiRDQAd08QABRQAAQADAQiRDQAd08QABRQAAA==.',Tm='Tmto:AwADCAMABAoAAA==.',['�']='三戒圣:AwAFCAYABAoAAA==.三系都废:AwAECAQABRQAAA==.不动王座:AwAICAgABAoAAA==.世界斑斑:AwABCAEABRQDAgAHAQhOVwAyEn0BBAoAAgAHAQhOVwAyEn0BBAoAAwAGAQjRPwAjH9UABAoAAA==.世间:AwAHCAUABAoAAA==.两全法:AwADCAYABRQCBAAIAQiHCAA/RL0BBAoABAAIAQiHCAA/RL0BBAoAAQUAOhIICAYABRQ=.丶文老师:AwABCAIABRQCBgAHAQjBNAA3rIwBBAoABgAHAQjBNAA3rIwBBAoAAA==.',['�']='你是我的碗:AwABCAEABRQAAA==.',['�']='冰火奥义:AwAECAQABRQCBwAIAQhoDABZcagCBAoABwAIAQhoDABZcagCBAoAAQcAPU4ICAkABRQ=.',['�']='几味白茶:AwAHCAUABAoAAA==.',['�']='初始丶绮罗香:AwACCAIABRQCCAAIAQi6EgBO91oCBAoACAAIAQi6EgBO91oCBAoAAA==.',['�']='功夫女孩:AwAICAkABAoAAA==.功夫法神:AwAECAQABRQAAA==.',['�']='口函天宪:AwADCAMABAoAAA==.',['�']='喷火龙丶:AwAGCAUABRQCBwAFAQg9AgBf68EBBRQABwAFAQg9AgBf68EBBRQAAA==.',['�']='回忆丶终难忘:AwABCAEABAoAAA==.',['�']='夜影柳柳:AwACCAIABRQDCQAIAQigBgA/leMBBAoACQAIAQigBgA/leMBBAoACgABAQhNfAALhCkABAoAAA==.夜邪:AwABCAEABAoAAA==.天下第一战:AwAECAQABAoAAQsAAAAICAgABAo=.',['�']='姬丝秀忒:AwADCAMABAoAAA==.',['�']='寥若晨汐:AwACCAMABRQCDAAIAQiFDABVJIQCBAoADAAIAQiFDABVJIQCBAoAAA==.',['�']='小狂狂:AwAECAQABRQAAA==.小逢逢:AwAICAgABAoAAA==.',['�']='帅妞:AwADCAMABAoAAA==.',['�']='幸运的萨鲁曼:AwAICAgABAoAAA==.',['�']='库丘林:AwAICA0ABAoAAA==.',['�']='彝族酒仙:AwAHCAgABAoAAA==.',['�']='忧伤不会的:AwAECAEABRQAAA==.',['�']='懿可:AwAECAQABRQAAA==.',['�']='拉帝欧斯:AwAECAgABRQDDQAEAQgMDwAh8tcABRQADQAEAQgMDwAh8tcABRQABAACAQiyBwACukAABRQAAA==.',['�']='无雨恋风:AwAICAgABAoAAA==.',['�']='明懿香:AwAGCAwABAoAAA==.星空下的美好:AwAICAgABAoAAA==.',['�']='晴空无垠:AwABCAEABAoAAA==.',['�']='术猫儿:AwAFCAUABAoAAA==.',['�']='枯法者小杨:AwAECAQABRQAAA==.',['�']='桑妮:AwAHCAcABAoAAA==.',['�']='永远深夜:AwAECAQABRQAAA==.',['�']='滚来滚去香肠:AwABCAEABRQCDgAIAQgRZAAo960BBAoADgAIAQgRZAAo960BBAoAAA==.',['�']='漫天枫痕:AwAICAgABAoAAA==.',['�']='燃烧卡:AwAICBAABAoAAA==.',['�']='爱丝鸡磨人:AwAHCBkABAoCAgAHAQipZQArSE8BBAoAAgAHAQipZQArSE8BBAoAAA==.',['�']='牛肉干的妈妈:AwABCAEABRQAAA==.',['�']='猜猜:AwABCAEABAoAAA==.',['�']='王力宏:AwABCAEABRQEDwAIAQhSGwAzK9kBBAoADwAIAQhSGwAzK9kBBAoAAQAFAQifUwAelJ8ABAoAEAABAQiKewBM6EEABAoAAA==.王宝琛:AwAFCAEABAoAAA==.王靖玟:AwADCAMABAoAAA==.',['�']='痛苦女王:AwAICAgABAoAAA==.',['�']='白生生:AwAICAgABAoAAA==.',['�']='睿爹:AwAICAgABAoAAA==.',['�']='绿豆大的胆:AwACCAQABRQCEQAIAQgpBwBDEy0CBAoAEQAIAQgpBwBDEy0CBAoAAA==.',['�']='聪明的峰峰:AwAECAQABRQAAA==.',['�']='脱色牛仔裤:AwAFCAUABAoAAA==.',['�']='花海:AwACCAMABAoAAA==.花田灬月下:AwAFCAUABAoAAA==.',['�']='莽夫:AwAECAkABRQDCAAEAQiUFAAssq0ABRQACAADAQiUFAA0wa0ABRQAEgACAQjtCwAubpUABRQAAA==.',['�']='萌萌小独孤:AwAECA0ABRQEEwAEAQjxAwBVjAYBBRQAEwADAQjxAwBVjAYBBRQAFAACAQjbFQBLN5oABRQAFQABAQg5FwAAAAAABRQAAA==.萌萌小独孤丶:AwAICBAABAoAAA==.',['�']='蓝翔技工羽毛:AwAICAgABAoAAA==.',['�']='诸葛亮:AwABCAEABRQAAA==.',['�']='辣椒皮皮:AwAICBkABAoCDgAIAQhjKABLel8CBAoADgAIAQhjKABLel8CBAoAAA==.',['�']='连环杀手羽毛:AwAICAgABAoAARYAK2YGCAYABRQ=.',['�']='邪战:AwAECAQABAoAAA==.',['�']='野火:AwAGCAYABAoAAA==.',['�']='钟吾飞雪:AwAICBcABAoCDAAIAQitHQA8ofYBBAoADAAIAQitHQA8ofYBBAoAAA==.',['�']='飞花令:AwAICAgABAoAAA==.飞飞:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end