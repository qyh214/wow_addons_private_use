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
 local lookup = {'Priest-Holy','Druid-Restoration','Druid-Balance','DeathKnight-Unholy','Hunter-Marksmanship','Priest-Shadow','Priest-Discipline','Monk-Windwalker','Evoker-Devastation','Mage-Arcane','Mage-Fire','Mage-Frost','Shaman-Enhancement','Warlock-Destruction','Hunter-BeastMastery','Paladin-Holy','Paladin-Retribution','Paladin-Protection','Unknown-Unknown','Monk-Mistweaver',}; local provider = {region='CN',realm='冬拥湖',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ac='Acemoglu:AwAECAQABAoAAA==.',Bu='Burgundy:AwAICAgABAoAAA==.',Cl='Clipperslove:AwACCAIABAoAAA==.',Ho='Holyheart:AwAGCAQABAoAAA==.',Mi='Missrobin:AwADCAkABRQCAQADAQjWAQBWgy4BBRQAAQADAQjWAQBWgy4BBRQAAA==.',Ra='Rainmbow:AwACCAMABRQAAA==.',Re='Reona:AwAECAgABRQDAgAEAQgvBABE0xABBRQAAgAEAQgvBABE0xABBRQAAwABAQhaJAA1qVIABRQAAA==.',['S�']='Sè:AwABCAMABRQAAA==.',['�']='七个隆小恰恰:AwAICA4ABAoAAA==.七月:AwAICAwABAoAAA==.东京闹五鼠:AwACCAQABRQAAA==.丨小小筱亭丶:AwAFCAEABAoAAA==.丶尛尛佳:AwAFCAYABAoAAA==.丶白芷:AwAECAQABRQAAA==.为了菇妖王:AwADCAMABAoAAA==.丿血刃灬:AwAFCAUABAoAAA==.',['�']='予君:AwAECAUABAoAAA==.',['�']='你多小:AwABCAEABAoAAA==.',['�']='光明纯牜奶:AwAICA4ABRQCBAAIAQgFAABWOOkCBRQABAAIAQgFAABWOOkCBRQAAA==.全村的希望:AwAFCAUABAoAAA==.',['�']='几田莉拉:AwAGCAQABRQAAA==.',['�']='北丶岛:AwAECAgABRQCBQAEAQheBgBFiPQABRQABQAEAQheBgBFiPQABRQAAA==.北冥先生:AwAICAsABAoAAA==.北海道的樱花:AwABCAEABRQAAA==.',['�']='叮个隆咚镪:AwAGCAgABAoAAA==.',['�']='咆哮回忆:AwAICAgABAoAAA==.',['�']='嗜血角斗士:AwAECAQABAoAAA==.',['�']='圣型尤物丷:AwAECAQABRQEAQAIAQhYAgBfrNoCBAoAAQAIAQhYAgBfrNoCBAoABgAIAQiTBwBZvq0CBAoABwADAQglRAA5ntgABAoAAQYAO50GCA4ABRQ=.地铁叁号:AwACCAMABRQAAA==.地铁四号:AwABCAEABRQAAA==.',['�']='大主教:AwADCAMABRQAAA==.',['�']='好无丶奈:AwACCAMABRQAAA==.好运常在:AwABCAEABRQAAA==.',['�']='宣告者的神巫:AwABCAIABRQCBgAIAQgZCgBUb4wCBAoABgAIAQgZCgBUb4wCBAoAAA==.',['�']='小城往事:AwABCAEABRQCCAAHAQi3GgBKPOEBBAoACAAHAQi3GgBKPOEBBAoAAA==.小斑斑:AwAICAgABAoAAA==.小牙嘎嘣脆:AwAGCAYABAoAAQkAD08ICAUABRQ=.小饼:AwAGCAwABAoAAA==.',['�']='很迷茫:AwABCAIABRQAAA==.',['�']='扯线木偶:AwAECAQABRQAAA==.',['�']='抃風儛润:AwAICAsABAoAAA==.',['�']='木三丶:AwAICAgABAoCAQAIAQhKDgA3qkECBAoAAQAIAQhKDgA3qkECBAoAAA==.木三丶德:AwAICAsABAoAAA==.',['�']='樱岛麻衣:AwACCAEABRQECgAIAQiWAQBhJYkCBAoACwAIAQivDgBedpYCBAoACgAGAQiWAQBhIIkCBAoADAADAQiTVQBHzOAABAoAAA==.',['�']='武林盟主:AwAECAQABRQAAA==.',['�']='每天都要开心:AwAICAEABAoAAA==.',['�']='波涛使者:AwAGCAcABAoAAA==.',['�']='流浪猫丶:AwABCAEABRQAAA==.',['�']='湮灭的爱:AwAECAQABRQAAA==.',['�']='潴小薰:AwABCAEABRQAAA==.',['�']='灵狐灬踏银砂:AwAICBEABAoAAQ0AM3YICAkABRQ=.',['�']='牵着晓猪漫步:AwAECAQABRQAAA==.',['�']='狂戦灬二锅头:AwAFCAYABAoAAQ4AIi4ICBgABAo=.',['�']='王者赞歌:AwAICA8ABAoAAA==.玻酱:AwAGCAMABAoAAA==.',['�']='琪心甄美:AwAICAEABAoAAA==.',['�']='白芷:AwAICAgABAoAAA==.',['�']='码头搞点男大:AwAFCAUABAoAAA==.破空之矢:AwAECAgABRQCDwAEAQiOFgAms94ABRQADwAEAQiOFgAms94ABRQAAA==.',['�']='碧瞳妖妖:AwABCAEABRQAAA==.',['�']='织朵蛀小牙:AwAICAgABAoAAA==.',['�']='美式蛇吻:AwAICAkABAoAAA==.',['�']='肉丸儿:AwAICNcABAoEEAAIAQgqAABi2RcDBAoAEAAIAQgqAABi2RcDBAoAEQADAQi+/gAi5Y0ABAoAEgACAQhESwAVOkQABAoAAA==.',['�']='花果山悍匪:AwACCAIABAoAAA==.芸梦之州:AwAICAIABAoAARMAAAAGCAMABRQ=.',['�']='草莓:AwAGCAYABAoAAA==.',['�']='菲欧亚娜:AwACCAQABRQCFAAIAQiZIQA198IBBAoAFAAIAQiZIQA198IBBAoAAA==.',['�']='落叶冰锋:AwAECAQABRQAARMAAAAGCAIABRQ=.',['�']='葛力娒乔:AwABCAEABAoAAA==.',['�']='赤道雨:AwAGCAMABRQAAA==.',['�']='远房大舅子:AwAICAEABAoAAA==.',['�']='键盘上的烟灰:AwABCAEABRQCEQAIAQhdWgA2qsUBBAoAEQAIAQhdWgA2qsUBBAoAAA==.',['�']='阿博:AwAECAQABRQAAA==.',['�']='韩波:AwAICAIABAoAAA==.',['�']='風至踏來:AwACCAMABRQAAA==.',['�']='风霜任漂泊:AwABCAEABRQAAA==.',['�']='魔贼一二三:AwAECAQABRQAAA==.',['�']='鸽子王小港:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end