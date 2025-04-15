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
 local lookup = {'DemonHunter-Havoc','Shaman-Restoration','Evoker-Preservation','Evoker-Devastation','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Paladin-Protection','Druid-Balance','Druid-Restoration','Unknown-Unknown','DeathKnight-Unholy','Paladin-Retribution','Priest-Shadow','DeathKnight-Frost','DeathKnight-Blood','Mage-Frost','Mage-Fire','Warlock-Destruction',}; local provider = {region='CN',realm='玛多兰',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ba='Bansheeoi:AwADCAkABRQCAQADAQgYCABOThcBBRQAAQADAQgYCABOThcBBRQAAA==.',Cx='Cx:AwAICAEABAoAAA==.',Se='Sevenmangos:AwABCAMABRQCAgAIAQh2DQBTsXQCBAoAAgAIAQh2DQBTsXQCBAoAAA==.',Sh='Sheepa:AwAECAQABRQAAA==.Sheepknit:AwAECAQABRQAAA==.',Ti='Tinnyz:AwAECAoABRQDAwAEAQi2AgA/8dYABRQAAwADAQi2AgA/8dYABRQABAADAQjHDgBQGaMABRQAAA==.',Wo='Woho:AwAFCAUABAoAAA==.',['�']='中美:AwABCAEABRQDBQAIAQjUHwA+8JkBBAoABQAGAQjUHwA/35kBBAoABgAGAQjRiQAppesABAoAAA==.',['�']='久久哥:AwAICB8ABAoCBgAIAQibLwA/8BMCBAoABgAIAQibLwA/8BMCBAoAAA==.乖乖德:AwAFCAIABAoAAA==.',['�']='云幕遮:AwAECBEABRQCBwAEAQgNCQBHrf4ABRQABwAEAQgNCQBHrf4ABRQAAA==.',['�']='佩奇吃饱了:AwAICAgABAoAAA==.',['�']='卖糖术神:AwACCAIABRQAAA==.',['�']='啊吉:AwAICAsABAoAAA==.',['�']='喵之哀熵:AwAICAgABAoAAA==.',['�']='四大名柱:AwACCAQABRQAAA==.',['�']='夏末丶将至:AwAECAgABRQCCAAEAQhSAgBdIToBBRQACAAEAQhSAgBdIToBBRQAAQgALesGCAoABRQ=.夜光丶:AwAICB0ABAoDBgAIAQheJABN1EgCBAoABgAIAQheJABJkUgCBAoABQADAQjMQQAyA8sABAoAAA==.天灰:AwAICAYABAoAAA==.',['�']='如果是龙也好:AwAICAIABRQAAA==.',['�']='库提供:AwAICAgABAoAAA==.',['�']='我的猫很粘人:AwAGCAYABRQDCQAEAQicDQBZgvAABRQACQAEAQicDQBZgvAABRQACgACAQhGEQAnnXoABRQAAQsAAAAICAIABRQ=.',['�']='散华礼弥:AwAECAQABRQCDAAIAQg+EQBZSXwCBAoADAAIAQg+EQBZSXwCBAoAAA==.',['�']='星玲珑:AwAECAwABRQDCQAEAQhhAwBbaz4BBRQACQAEAQhhAwBbaz4BBRQACgACAQgOEgAflHUABRQAAA==.',['�']='暮光救赎:AwACCAYABRQCDQACAQgXJwA4w5sABRQADQACAQgXJwA4w5sABRQAAA==.',['�']='月下无霜:AwAHCAgABAoAAA==.',['�']='板栗盾击:AwAICAgABAoAAA==.',['�']='橘彩星光:AwAICAgABAoAAA==.',['�']='法尼瓦伦泰:AwAGCA4ABAoAAA==.',['�']='爱的魔力:AwAHCAcABAoAAA==.',['�']='牧旻:AwAGCAsABRQCDgAGAQjMAABDdtcBBRQADgAGAQjMAABDdtcBBRQAAA==.',['�']='狄奥布斯:AwAICAEABAoAAA==.',['�']='王灬小灬胖:AwAHCAUABAoAAA==.',['�']='盐州小趴菜:AwAECAQABRQAAA==.',['�']='约翰史密斯:AwAECAQABRQAAA==.',['�']='芙蓉王源:AwAICAgABAoAAA==.',['�']='茜舞飞扬:AwAECAoABRQDDwAEAQj7AQA0n/cABRQADwAEAQj7AQAvUvcABRQAEAAEAQjFDQAjoqsABRQAAQwAPpAGCAgABRQ=.',['�']='萨琪玛:AwAICAgABAoAAA==.',['�']='蔚蓝星辰:AwAICAgABAoAAA==.',['�']='薄荷薄荷薄荷:AwAECAQABAoAAA==.',['�']='蚩尤:AwACCAIABRQCBgAIAQghGQBQqH8CBAoABgAIAQghGQBQqH8CBAoAAA==.',['�']='蛋刀拿来吧:AwACCAIABAoAAA==.',['�']='西神西神西神:AwACCAQABRQDEQAIAQiFAABjKyIDBAoAEQAHAQiFAABilyIDBAoAEgAHAQgMEABfmIwCBAoAAA==.',['�']='豆芽菜丶:AwAGCA8ABRQCEgAGAQh2AgA5trkBBRQAEgAGAQh2AgA5trkBBRQAAA==.',['�']='阿尔尤拉诺斯:AwACCAIABAoAAA==.',['�']='陆奥无幻:AwAECAQABRQAAA==.',['�']='雁城雪:AwAICAgABAoAAA==.雪花茄子:AwAICAgABAoAAA==.',['�']='饭鱼蛋:AwAECAgABRQCBgAEAQgFDABMZgwBBRQABgAEAQgFDABMZgwBBRQAAA==.',['�']='香织:AwADCAoABRQCEwADAQi8CQBO0/EABRQAEwADAQi8CQBO0/EABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end