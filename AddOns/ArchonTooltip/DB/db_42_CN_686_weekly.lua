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
 local lookup = {'Hunter-BeastMastery','DeathKnight-Unholy','Hunter-Marksmanship','Unknown-Unknown','Monk-Mistweaver','Evoker-Devastation','Druid-Restoration','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Rogue-Subtlety','Rogue-Assassination','DeathKnight-Blood','Shaman-Restoration','Evoker-Preservation','Warrior-Arms','Warrior-Fury','Monk-Brewmaster','Mage-Frost','Warlock-Destruction','DemonHunter-Vengeance','Paladin-Retribution','Monk-Windwalker',}; local provider = {region='CN',realm='托塞德林',name='CN',type='weekly',zone=42,date='2025-04-14',data={Bl='Blackblood:AwAGCAcABAoAAA==.',Ex='Exx:AwAECAQABRQAAA==.',Fl='Flurry:AwAICAgABAoAAA==.',Gr='Grimreaper:AwAECAcABRQCAQAEAQhaCgBPZhUBBRQAAQAEAQhaCgBPZhUBBRQAAA==.',He='Helplee:AwAICA0ABAoAAQIAPpAGCAgABRQ=.',Jl='Jlm:AwAECAEABRQAAA==.',Ki='Kikikukukaka:AwAECAQABRQAAA==.',Lr='Lr:AwAECAgABRQDAQAEAQisCwBanw4BBRQAAQAEAQisCwBanw4BBRQAAwABAQghFwBAME8ABRQAAQQAAAAICAQABRQ=.',Ma='Marimo:AwACCAQABRQAAA==.',Mi='Minivince:AwEECAQABRQAAA==.',Re='Reniya:AwAICA4ABAoAAA==.',Va='Vartuên:AwACCAIABAoAAA==.',Vo='Voldemortlol:AwACCAIABRQAAA==.',['�']='一个九妹:AwAGCAYABAoAAA==.一拳一个:AwAECAUABRQCBQAEAQiOBABYlzEBBRQABQAEAQiOBABYlzEBBRQAAA==.一瞬千躺:AwAECAQABRQAAA==.一笔雕凿:AwAGCAIABRQAAQYAD08ICAUABRQ=.一缕青丝:AwAHCAcABAoAAA==.丶沈凤昱:AwABCAEABRQAAA==.',['�']='你如温阳丶:AwAHCBEABAoAAA==.',['�']='八苦:AwAGCAwABAoAAQcAWWYFCBAABRQ=.',['�']='冰棒:AwAECA8ABRQDAwAEAQjRBgBBxfAABRQAAwADAQjRBgBAB/AABRQAAQADAQhiKAA8H4wABRQAAA==.',['�']='十六耶:AwAFCAUABRQCCAAFAQjUAwAnkUYBBRQACAAFAQjUAwAnkUYBBRQAAA==.千秋雪:AwADCAMABAoAAA==.博君一笑:AwAGCAcABAoAAA==.卿欢:AwAECAgABRQDCQAEAQgPBwBQowABBRQACQAEAQgPBwBQowABBRQACgAEAQhwEgAILKAABRQAAA==.',['�']='台风交个消失:AwAICB8ABAoDCwAIAQhdBABXla4CBAoACwAIAQhdBABXla4CBAoADAADAQgPKQAtQ9EABAoAAA==.',['�']='后会无期:AwAICBAABAoAAA==.',['�']='周郎:AwAGCAoABAoAAA==.',['�']='哀木涕:AwACCAIABAoAAA==.',['�']='喜欢下雨天:AwAECAQABAoAAA==.',['�']='夏天小熊猫:AwAECAQABRQAAA==.天气预报:AwAICA8ABAoAAA==.',['�']='姬魅蓝:AwAECAMABRQAAQcAPyYICAsABRQ=.',['�']='寒少充电宝:AwADCAUABAoAAA==.',['�']='小狐狸米纱:AwAECAQABAoAAA==.小红手灬:AwAICA4ABAoAAA==.小红手王哥:AwAECAQABRQAAA==.尤缇安娜:AwAECAQABRQAAA==.',['�']='山山而川:AwAFCAYABAoAAA==.',['�']='待敌:AwAECAIABRQAAA==.微笑骑士:AwAGCA0ABRQCAgAGAQgxAABVpAsCBRQAAgAGAQgxAABVpAsCBRQAAA==.',['�']='心火牧:AwAHCAoABAoAAA==.',['�']='我在冲了你呢:AwAECAYABRQCDQAEAQjTCgAxHcEABRQADQAEAQjTCgAxHcEABRQAAQQAAAAGCAIABRQ=.',['�']='抱抱:AwAFCAUABRQCDgAFAQjvAABBaHIBBRQADgAFAQjvAABBaHIBBRQAAA==.',['�']='敖丙:AwAECAgABRQDDwAEAQjsAQA60/IABRQADwAEAQjsAQA60/IABRQABgABAQj+FwAcLD0ABRQAAQcAWWYFCBAABRQ=.',['�']='斬殺型:AwAGCAoABRQDEAAGAQh4AABAocMBBRQAEAAGAQh4AAA0T8MBBRQAEQAEAQhpBgBQFBwBBRQAAA==.',['�']='无名小德:AwAECAYABAoAAA==.无火余晖:AwAGCAYABAoAAA==.',['�']='有梦想的咸鱼:AwAHCAYABAoAAA==.',['�']='李老酒:AwADCAgABRQCEgADAQgiBAAf2KEABRQAEgADAQgiBAAf2KEABRQAAA==.',['�']='枕头:AwACCAMABRQCEwAIAQi6CABW5K4CBAoAEwAIAQi6CABW5K4CBAoAAA==.',['�']='梦烬:AwAGCAwABAoAARQANMgGCAYABRQ=.',['�']='棒棒哒:AwACCAIABRQAAA==.',['�']='欧皇灬小哥哥:AwADCAMABAoAAA==.',['�']='殢无伤:AwAECAQABRQAAA==.',['�']='水蓝色天空:AwAECAQABRQAAA==.',['�']='油焖大虾:AwAECAQABAoAAA==.',['�']='洛丹伦的秋天:AwAICA8ABAoAAA==.洛克塔尔:AwABCAEABRQAAA==.',['�']='犀利不解释:AwAFCAwABAoAAA==.',['�']='猴师傅丶:AwAICAgABAoAAA==.',['�']='玛夏多:AwACCAIABAoAAA==.环绕太阳:AwAECAQABAoAAA==.',['�']='瑞克克阿阿:AwACCAMABRQAAA==.',['�']='盲眼猎手卡恩:AwACCAgABRQCFQACAQiHEAAD90kABRQAFQACAQiHEAAD90kABRQAAA==.',['�']='第一时间甩锅:AwACCAUABRQCFAACAQi4GAA04IgABRQAFAACAQi4GAA04IgABRQAAA==.',['�']='箫瑟:AwAGCAIABRQAAA==.',['�']='米尼亨特:AwACCAYABRQCAQACAQg+JAA2tJcABRQAAQACAQg+JAA2tJcABRQAAA==.',['�']='粉碎噩梦:AwAICBAABAoAAA==.',['�']='紫苏桃子:AwADCAMABAoAAA==.',['�']='翟老师:AwAECAQABRQAAA==.',['�']='肥肚肚左卫门:AwADCAoABRQCFgADAQhjEwA8LfQABRQAFgADAQhjEwA8LfQABRQAAA==.',['�']='荞麦面:AwAECAEABRQAAQQAAAAGCAQABRQ=.',['�']='萌萌的康子:AwAECAgABRQCFgAEAQjvBgBbQigBBRQAFgAEAQjvBgBbQigBBRQAAQQAAAAICAQABRQ=.落花无言:AwADCAEABRQAAA==.',['�']='葛东骏:AwAICAkABAoAAA==.',['�']='藿藿:AwAGCAQABRQAAA==.',['�']='血雨探花刂:AwACCAIABRQCEQAIAQiTLAAnqLUBBAoAEQAIAQiTLAAnqLUBBAoAAA==.',['�']='订卡小李一号:AwAICA4ABAoAAA==.',['�']='贝如塔:AwAECAQABRQAAA==.贝莉尔:AwAICBAABAoAAA==.贫穷的阿昆达:AwAICAgABAoAAA==.',['�']='赤红符文武器:AwADCAMABAoAAA==.走吧风儿:AwAECAQABAoAAA==.',['�']='轻装上阵:AwAGCAwABAoAAA==.',['�']='辰月之狐:AwAICBIABAoAAA==.',['�']='这个是雨天:AwAFCAgABRQDFwAEAQi9BgA+UfsABRQAFwAEAQi9BgA+UfsABRQABQAEAQhuDAAwhecABRQAAA==.',['�']='部落子龙:AwAFCAYABAoAAA==.',['�']='酥茶儿:AwAGCAYABRQCFAAGAQgxAABRVR8CBRQAFAAGAQgxAABRVR8CBRQAAA==.',['�']='醉梦璑訫:AwADCAQABAoAAA==.醉梦訫德:AwAICBEABAoAAA==.醉落夕风丶:AwACCAMABRQAAA==.',['�']='野獣初號機:AwAECAEABRQAAA==.',['�']='阳光宅牛:AwABCAEABAoAAA==.阿布达雷:AwADCAMABRQCAgAIAQjRGgBXPzkCBAoAAgAIAQjRGgBXPzkCBAoAAA==.',['�']='陈风暴醉酒:AwAECAQABRQAAA==.',['�']='难受想哭:AwABCAEABRQCAgAIAQgLGABN/0sCBAoAAgAIAQgLGABN/0sCBAoAAA==.',['�']='青鹭狂想曲:AwAICAgABAoAAA==.',['�']='风语如歌:AwAHCAYABAoAAA==.',['�']='麻辣姬丝:AwACCAIABAoAAA==.麻辣鸡棒棒:AwADCAIABAoAAA==.',['�']='黄昏圣痕:AwAECAYABRQCFgAEAQjSHAAhXs8ABRQAFgAEAQjSHAAhXs8ABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end