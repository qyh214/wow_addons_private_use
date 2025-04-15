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
 local lookup = {'Shaman-Elemental','Shaman-Enhancement','Evoker-Preservation','Evoker-Devastation','Warlock-Destruction','Warlock-Affliction','Hunter-BeastMastery','Paladin-Protection','Monk-Mistweaver','Mage-Frost','Warlock-Demonology','DemonHunter-Havoc','Priest-Discipline','Priest-Holy',}; local provider = {region='CN',realm='巴纳扎尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Fr='Freakypastor:AwAECAQABAoAAA==.Freakyweek:AwAICAgABAoAAA==.',Ko='Kouww:AwACCAMABRQDAQAIAQjiHABWwdUBBAoAAgAHAQiDGABHMe0BBAoAAQAHAQjiHABJ0dUBBAoAAA==.',Sh='Showfreely:AwABCAEABRQAAA==.',Wi='Windcall:AwAGCAEABRQCAwAIAQgHBABKMVcCBAoAAwAIAQgHBABKMVcCBAoAAQQAD08ICAUABRQ=.',['�']='丶晚秋:AwAICA8ABAoAAA==.',['�']='乌鸦:AwAICB0ABAoDBQAIAQgjBQBaAcYCBAoABQAIAQgjBQBaAcYCBAoABgACAQjWIgBSrrgABAoAAA==.',['�']='五晨寺主持:AwAECAQABRQAAA==.',['�']='伤魄:AwAECAQABRQAAA==.',['�']='俺寻思之力:AwAGCAYABAoAAA==.',['�']='剑廿三:AwABCAIABRQAAA==.',['�']='北船:AwAHCAsABAoAAA==.',['�']='哥是老中医:AwABCAEABRQAAA==.',['�']='唯一的选择:AwAICAEABAoAAA==.',['�']='喵里奥:AwABCAEABAoAAA==.',['�']='大佬带带我呀:AwAHCAsABAoAAA==.大妈一抬腿:AwACCAIABRQAAA==.大西瓜呀:AwAFCAUABAoAAA==.',['�']='奥飞飞:AwABCAIABRQAAA==.',['�']='季末残阳:AwAECAgABAoAAA==.',['�']='小兰:AwAICHkABAoCBwAIAQiaDQBiC8ACBAoABwAIAQiaDQBiC8ACBAoAAA==.小帅:AwAECAQABRQAAA==.小老虎星冰乐:AwAGCAMABRQAAA==.',['�']='张罗魔:AwAGCAMABAoAAA==.',['�']='很难拉得住:AwAICBkABAoCCAAIAQhzCwBF8CoCBAoACAAIAQhzCwBF8CoCBAoAAA==.',['�']='我不是花生:AwAFCAUABAoAAQkAPfAGCAwABRQ=.我是个秘密:AwAICAgABAoAAA==.我本爱你:AwACCAEABAoAAA==.战骑:AwAECAQABRQAAA==.戴安娜:AwABCAEABRQCCgABAQilHAAIjCYABRQACgABAQilHAAIjCYABRQAAA==.',['�']='日报头版明星:AwAGCAYABAoAAA==.',['�']='星辰丶陨落:AwAGCAEABAoAAA==.',['�']='暗靈:AwAICHkABAoEBgAIAQh7BQBMGAwCBAoABgAIAQh7BQBMGAwCBAoACwAGAQgZJwA7Qg8BBAoABQAGAQiOXgAP4NAABAoAAA==.',['�']='果涩棠棠:AwADCAMABAoAAA==.',['�']='灿灿魔王:AwAFCAEABAoAAA==.',['�']='王者一梦:AwAECAQABRQAAA==.',['�']='白水:AwACCAMABRQCDAAIAQjwHABFTzcCBAoADAAIAQjwHABFTzcCBAoAAA==.',['�']='皮蛋丶:AwABCAEABRQCAQAIAQikCwBWdHwCBAoAAQAIAQikCwBWdHwCBAoAAA==.',['�']='秘密的小猎:AwAICAgABAoAAA==.',['�']='素夙:AwAICAgABAoAAA==.',['�']='红莲盾盾:AwAECAYABRQDDQAEAQioCgAuZt0ABRQADQAEAQioCgAuZt0ABRQADgACAQiVGAATZkoABRQAAA==.',['�']='艾萨不撒:AwAFCAUABAoAAA==.',['�']='萬伏高压灬電:AwAECAQABAoAAA==.',['�']='虔诚的老六:AwAICAgABAoAAA==.',['�']='赤狐青槐:AwAICAgABAoAAA==.',['�']='那些往事:AwAECAQABAoAAA==.那骑士:AwACCAIABRQAAA==.',['�']='零点零零幺:AwAFCAUABAoAAA==.',['�']='风中小百合:AwAICAkABAoAAA==.',['�']='默风冥:AwAGCAYABRQCCQAGAQhEAgAeA4ABBRQACQAGAQhEAgAeA4ABBRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end