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
 local lookup = {'Mage-Fire','Hunter-Marksmanship','Hunter-BeastMastery','Rogue-Subtlety','Unknown-Unknown','Druid-Balance','DemonHunter-Havoc','Paladin-Retribution','Warrior-Fury','Priest-Holy','Priest-Discipline','Warrior-Arms','Druid-Restoration',}; local provider = {region='CN',realm='埃克索图斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ac='Acer:AwACCAIABRQAAA==.',Ae='Aeraely:AwAICAgABAoAAA==.',Ce='Cello:AwACCAYABRQCAQACAQjLHQBXU7oABRQAAQACAQjLHQBXU7oABRQAAA==.',De='Demonkid:AwAICAYABAoAAA==.',Di='Dik:AwAHCAMABAoAAA==.',Ne='Nelthario:AwABCAEABRQDAgAIAQgBFgBTD+oBBAoAAgAGAQgBFgBPruoBBAoAAwAFAQi5mQA/JsUABAoAAA==.',Pa='Palapala:AwACCAIABRQAAA==.',Ro='Robbergirl:AwACCAIABRQCBAAIAQjLCwA+uCgCBAoABAAIAQjLCwA+uCgCBAoAAA==.',So='Sour:AwAECAQABRQAAA==.',Xk='Xkingt:AwAECAQABRQAAQUAAAAICAQABRQ=.',['�']='一枪一爆头:AwAECAQABRQAAQMAShkGCA4ABRQ=.三瑞咕咕:AwACCAIABRQAAA==.不敢吹牛了:AwAECAQABAoAAA==.东方丶馆长:AwAECAQABRQAAA==.',['�']='二号首长丶:AwAECAIABRQAAA==.',['�']='你吃了吗:AwADCAMABAoAAA==.使劲打用力抽:AwAGCAEABAoAAA==.',['�']='倒霉的小胖牛:AwACCAIABRQAAA==.',['�']='冰丶媛:AwAECAQABAoAAQUAAAAFCAUABAo=.',['�']='凡尘忆梦:AwAGCAYABAoAAA==.',['�']='刁骑:AwAECAQABRQAAA==.',['�']='功夫丶地球:AwACCAIABRQAAA==.',['�']='勒勒布:AwACCAIABRQAAA==.',['�']='吃饱皮:AwAECAQABRQAAA==.',['�']='哈基米德:AwACCAIABAoAAA==.哈库拉玛塔塔:AwAGCAoABRQCBgAGAQiIBgBH3RoBBRQABgAGAQiIBgBH3RoBBRQAAA==.',['�']='图腾之祖:AwAFCAUABAoAAA==.',['�']='圣光丶地球:AwABCAEABRQAAA==.',['�']='夢幻球球:AwADCAMABAoAAA==.天堂的刑具:AwAECAQABRQAAA==.天降正义丶:AwAECAQABRQAAA==.',['�']='好哥哥带带我:AwACCAIABAoAAA==.',['�']='娜可露露丶:AwAECAQABRQAAA==.',['�']='小欢乐:AwACCAIABAoAAA==.小甜心:AwAFCAUABAoAAA==.尘默:AwAECAQABRQAAA==.',['�']='布萊克:AwAICAYABAoAAA==.',['�']='急冻河童:AwAFCAIABAoAAA==.',['�']='恶魔球球:AwABCAEABRQCBwAIAQjsHQBMtTECBAoABwAIAQjsHQBMtTECBAoAAA==.',['�']='有言悦于耳边:AwACCAIABRQAAA==.未来终结者:AwAECAQABAoAAA==.',['�']='桜流:AwABCAEABRQCCAAIAQgQOQBSgyICBAoACAAIAQgQOQBSgyICBAoAAA==.',['�']='橙色预警:AwAICAUABAoAAA==.',['�']='沃尼犸:AwAICB0ABAoCCAAIAQhDHQBaIIwCBAoACAAIAQhDHQBaIIwCBAoAAA==.',['�']='泷谷源治:AwACCAMABRQCCQAIAQjwCwBTcpcCBAoACQAIAQjwCwBTcpcCBAoAAA==.',['�']='浅伤丶眠:AwAFCAUABAoAAA==.',['�']='焦喘的邦桑迪:AwAICAgABAoAAA==.',['�']='玩偶好萌啊:AwAICAoABAoAAA==.',['�']='电动小野野:AwAGCAYABAoAAA==.',['�']='粥阿粥:AwAECAYABRQCCgAEAQgJBQA7kvoABRQACgAEAQgJBQA7kvoABRQAAA==.',['�']='紫罗幻灵:AwAECAQABAoAAA==.',['�']='纪念逝去的你:AwAICAgABAoAAA==.',['�']='老约翰:AwAICAQABAoAAA==.',['�']='芜罗亭魔梨威:AwACCAQABRQDCgAIAQjnEgA+qRcCBAoACgAIAQjnEgA+qRcCBAoACwABAQjLfwATZSwABAoAAA==.',['�']='角落玩泥巴:AwAECAQABRQAAA==.',['�']='费七万:AwACCAIABRQAAQEAQ8QICAcABRQ=.',['�']='还我初液:AwAICAEABAoAAA==.追求完美:AwABCAEABRQDDAAIAQhoJQAiulMBBAoADAAHAQhoJQAmZ1MBBAoACQAGAQhRTQAacf4ABAoAAA==.',['�']='阿梅达物语:AwABCAEABRQAAA==.',['�']='霜小猪:AwAICAgABAoAAA==.',['�']='青春翻涌成她:AwABCAIABRQAAA==.',['�']='风的记忆:AwAECAsABRQDBgAEAQhOEgAph9oABRQABgAEAQhOEgAph9oABRQADQAEAQh7CwAUAasABRQAAA==.飞驰:AwABCAEABRQAAA==.',['�']='鱼摆摆了不起:AwABCAEABRQAAA==.',['�']='鼓小浅:AwADCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end