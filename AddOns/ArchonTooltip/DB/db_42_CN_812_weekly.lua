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
 local lookup = {'Shaman-Elemental','Mage-Frost','Priest-Holy','Priest-Discipline','Druid-Balance','Druid-Restoration','Warlock-Destruction','Warlock-Demonology','Monk-Mistweaver','Hunter-BeastMastery','Hunter-Marksmanship','Unknown-Unknown','Evoker-Devastation','Paladin-Retribution','DemonHunter-Vengeance','Evoker-Preservation',}; local provider = {region='CN',realm='莱索恩',name='CN',type='weekly',zone=42,date='2025-04-15',data={Gr='Groms:AwAECAQABRQAAA==.',Lz='Lzo:AwAICBAABAoAAA==.',Qi='Qir:AwAGCAMABAoAAQEAVZkICAIABRQ=.',So='Sora:AwAHCAkABAoAAA==.',St='Strawberryz:AwACCAIABRQAAA==.',['�']='一曲震魂:AwAECAgABRQCAgAEAQi1AQBWwC4BBRQAAgAEAQi1AQBWwC4BBRQAAA==.一样的夜:AwAFCAUABAoAAA==.一神牧一:AwADCAoABRQDAwADAQiJCwBVnsYABRQAAwACAQiJCwBfFMYABRQABAABAQixHQBCslIABRQAAA==.丶長生:AwAGCAUABAoAAA==.',['�']='伊利达雷之怒:AwAECAQABRQAAA==.会夢之圈:AwADCAIABRQDBQAIAQjUMQA0k88BBAoABQAIAQjUMQA0k88BBAoABgAHAQgHTQAOeLgABAoAAA==.会梦之圈:AwACCAMABRQAAA==.',['�']='先森:AwAECAQABRQAAA==.',['�']='冷月丄凝霜:AwAGCAYABAoAAA==.冷酷的泪:AwADCAUABAoAAA==.',['�']='前列缐碎击者:AwAGCAYABAoAAA==.剑潇潇风呼呼:AwAICA0ABAoAAA==.',['�']='单小龙:AwAGCAEABRQAAA==.南歌:AwACCAEABAoAAA==.',['�']='变一手:AwAICAkABAoAAA==.叶丿无双:AwABCAEABRQAAA==.叶丿晓霜:AwABCAIABRQAAA==.',['�']='君不见云之夏:AwACCAIABRQAAA==.',['�']='周生:AwAICAMABAoAAA==.',['�']='咕哒子本咕:AwAECAgABAoAAA==.',['�']='喵喵:AwAICAMABAoAAA==.',['�']='圣光丨透心凉:AwABCAEABRQAAA==.地狱术弑:AwAHCBgABAoCBwAHAQgLSQAeeSoBBAoABwAHAQgLSQAeeSoBBAoAAA==.',['�']='墨丘利丶:AwAECAcABRQDCAAEAQh5AwA25NcABRQABwADAQi/CwA25OwABRQACAAEAQh5AwAVPdcABRQAAA==.',['�']='大尐姐啊:AwAICAgABAoAAA==.',['�']='小小蛆:AwACCAIABAoAAA==.',['�']='张灬翼德:AwACCAIABRQAAA==.',['�']='我也滄海:AwAECAQABRQAAA==.',['�']='撩蔭手王五:AwACCAEABRQAAQkAQnAHCAwABRQ=.',['�']='无良小僧:AwABCAEABRQAAA==.日兔侠:AwAICAMABAoAAA==.',['�']='晨曦炛爻:AwACCAIABRQAAA==.',['�']='暨鈅:AwACCAIABRQAAA==.暴躁小喵:AwAGCAYABRQDCgAGAQi8HwAmQbIABRQACgACAQi8HwArWrIABRQACwAEAQjcEAAi3KMABRQAAA==.',['�']='最後的夏天:AwACCAEABRQAAA==.',['�']='李一桐:AwAECAQABRQAAA==.',['�']='柠萌尐姐:AwAECAQABRQAAQwAAAAICAIABRQ=.',['�']='梦丶点滴五世:AwABCAEABRQAAA==.',['�']='残阳灬月落:AwABCAEABRQAAA==.',['�']='水晶晶:AwAECAQABRQAAA==.',['�']='波铭拳:AwAECAQABRQAAA==.',['�']='浅浅:AwAICAgABAoAAA==.海苔饭团:AwADCA0ABRQCDQADAQhjBgBGkQ0BBRQADQADAQhjBgBGkQ0BBRQAAA==.',['�']='淡烟流水:AwAECAQABRQAAQYAOkwGCAUABRQ=.',['�']='烈焰灼天:AwAICBMABAoAAA==.',['�']='爱吃回锅肉:AwACCAIABRQAAA==.',['�']='独角兽吃豆芽:AwACCAIABAoAAA==.',['�']='疑是银河:AwABCAEABRQAAA==.疯狂的灬骑:AwAGCAYABAoAAA==.',['�']='盾牌护菊花:AwAECAQABRQAAA==.',['�']='真墨丘利:AwADCAoABRQCDgADAQjmHQAketoABRQADgADAQjmHQAketoABRQAAA==.真夜灬随风:AwACCAIABRQAAA==.',['�']='瞎球哔哔:AwABCAIABRQCDwAIAQgbHwArEl0BBAoADwAIAQgbHwArEl0BBAoAAA==.',['�']='罪恶痕迹:AwAGCAYABAoAAA==.',['�']='脏了的雪:AwAICAIABAoAAA==.',['�']='西鎍:AwAHCAoABAoAAA==.',['�']='譕顔:AwAGCAEABRQAAA==.',['�']='贼快乐:AwAECAQABRQAAA==.贾小白:AwAICA4ABAoAAA==.',['�']='邪念:AwAECAQABRQAAA==.',['�']='醉爱杀戮:AwABCAIABRQAAA==.醉风行:AwAECAQABAoAAA==.',['�']='鐵心:AwACCAIABAoAAA==.',['�']='長生:AwAECAMABRQAAA==.',['�']='阿洛伊斯塔萨:AwABCAIABRQDDQAIAQjWDgBWST4CBAoADQAIAQjWDgBWST4CBAoAEAABAQiPJgAaai8ABAoAAQUAQpoDCAYABRQ=.',['�']='颜汐:AwABCAEABAoAAA==.',['�']='马玉凤:AwAICAgABAoAAA==.',['�']='鸳鸯傲骨:AwAHCAcABAoAAA==.',['�']='龍丶熙熙:AwACCAcABRQDAwACAQhPFgAZh3EABRQAAwACAQhPFgAZh3EABRQABAABAQiMIAAsb0IABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end