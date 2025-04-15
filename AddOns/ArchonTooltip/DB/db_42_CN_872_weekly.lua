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
 local lookup = {'Mage-Fire','Druid-Restoration','Warrior-Protection','Warrior-Arms','Priest-Shadow','Priest-Holy','Priest-Discipline','Druid-Balance','Paladin-Retribution','Hunter-BeastMastery','DeathKnight-Blood','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','Paladin-Protection','Mage-Frost','Hunter-Marksmanship','DeathKnight-Unholy',}; local provider = {region='CN',realm='阿迦玛甘',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ad='Adventure:AwAGCAsABAoAAA==.',Cm='Cms:AwABCAEABRQAAA==.',Da='Daeneryst:AwAECAwABRQCAQAEAQhHDQBOKg0BBRQAAQAEAQhHDQBOKg0BBRQAAA==.',En='Envydurid:AwAICAsABAoAAA==.',Fr='Freedruid:AwADCAcABRQCAgADAQhbCQAp8c0ABRQAAgADAQhbCQAp8c0ABRQAAA==.',Ko='Kormac:AwABCAEABRQAAA==.',Le='Leander:AwAFCAUABAoAAA==.',Ma='Maifa:AwAGCBkABAoDAwAGAQiBHQAk6u4ABAoAAwAGAQiBHQAk6u4ABAoABAABAQiCYQAJaSkABAoAAA==.Mandy:AwABCAEABAoAAA==.',Ph='Phxsuns:AwAFCAUABAoAAA==.',Pr='Priteardrop:AwAECAYABRQEBQAEAQhHEAAa+8YABRQABQAEAQhHEAAa+8YABRQABgABAQieGgBTKEoABRQABwABAQjEIABNfkEABRQAAA==.',Sa='Sarys:AwAGCAYABAoAAA==.',Su='Sun:AwACCAMABRQAAA==.',['�']='一羽雪一:AwAHCAcABAoAAA==.上帝之手:AwAHCAUABAoAAA==.',['�']='久伴独宠丶:AwAGCAYABAoAAA==.',['�']='亡者之墙:AwAGCAsABAoAAA==.',['�']='伪装遗忘:AwAHCAsABAoAAA==.',['�']='低头皇冠掉:AwABCAEABAoAAA==.何飞爱洗澡:AwAGCAYABAoAAA==.',['�']='八目:AwAICAkABAoAAA==.',['�']='别扒拉我:AwAGCAIABAoAAA==.',['�']='包龙星:AwAGCAYABAoAAA==.',['�']='可爱的煎饼:AwAICAgABAoAAQgATkoGCAYABRQ=.',['�']='唯壹一天天:AwAECAgABAoAAA==.',['�']='圣光之主:AwAGCAkABAoAAA==.地獄霸王丸:AwADCAMABAoAAA==.',['�']='塞西娅:AwAICAgABAoAAA==.',['�']='夜猫:AwAECAUABAoAAA==.天亮说晚安:AwAECAQABRQAAA==.天蓝蓝:AwAFCAQABAoAAA==.',['�']='小坤坤:AwAICAgABAoAAA==.小红薯:AwAHCAYABAoAAA==.小袁同学:AwAICB0ABAoCCQAIAQiWOABFXS0CBAoACQAIAQiWOABFXS0CBAoAAA==.小鹿鹿:AwABCAEABAoAAA==.',['�']='干将尐墨:AwAHCAcABAoAAA==.',['�']='弓月:AwACCAUABRQCCgACAQgfMAAYaIAABRQACgACAQgfMAAYaIAABRQAAA==.',['�']='德鲁依死骑:AwAICBcABAoCCwAIAQiuJAAkKT8BBAoACwAIAQiuJAAkKT8BBAoAAA==.',['�']='快睡觉觉:AwAICAwABAoAAA==.',['�']='戈登费小曼:AwAECAQABRQAAQwAH94ICAoABRQ=.戈登阿喀琉斯:AwAICAgABAoAAA==.我就是小德:AwAGCAIABRQAAA==.我算开了眼了:AwACCAMABRQAAA==.',['�']='明月昭昭:AwAECAQABRQAAA==.春日祈小鱼:AwAICAgABAoAAA==.',['�']='晓萨:AwAICAgABAoAAA==.',['�']='有药儿:AwAHCAsABAoAAA==.',['�']='李三青:AwAFCAUABAoAAA==.',['�']='欧格玛:AwAFCAkABAoAAA==.',['�']='涅槃丶尤文:AwAGCAYABAoAAA==.',['�']='溯洄水之湄:AwAICA8ABAoAAA==.',['�']='满满都是奶:AwAGCAYABAoAAA==.',['�']='火焰紋章:AwACCAIABRQAAA==.灬霸唱丶:AwAECAQABRQDDQAIAQjZFQBPFzQCBAoADQAIAQjZFQBPFzQCBAoADgABAQjeYgAmfEIABAoAAA==.',['�']='炎魔堂葫芦:AwAGCAYABAoAAA==.',['�']='爱到你想逃:AwADCAIABAoAAA==.',['�']='狂暴武器战:AwAHCAwABAoAAA==.',['�']='猜丁壳:AwABCAEABRQAAA==.',['�']='王坡大虾:AwABCAEABAoAAA==.',['�']='番茄小强:AwAICAgABAoAAA==.',['�']='神羅天征:AwACCAIABAoAAA==.',['�']='秋风骚落叶:AwAGCAoABAoAAA==.',['�']='箭雨繁花:AwAGCAQABRQAAA==.',['�']='臻小臻:AwAGCAkABAoAAA==.',['�']='莫问归处:AwAGCAYABAoAAA==.',['�']='贪财的唫牛座:AwADCAQABAoAAA==.',['�']='进击的莫莫:AwAECAQABRQAAA==.',['�']='造影师:AwAGCAoABRQCBQAGAQgfAgA6DqQBBRQABQAGAQgfAgA6DqQBBRQAAA==.',['�']='錦瑟無聲:AwAICAgABAoAAA==.',['�']='闪电红薯:AwABCAEABAoAAA==.',['�']='隔壁王大哥:AwAECAgABRQCCQAEAQjnDABXzBIBBRQACQAEAQjnDABXzBIBBRQAAQ8ASbAGCAYABRQ=.',['�']='雾里看飞:AwAHCBUABAoDEAAHAQjYDgBfFXECBAoAEAAHAQjYDgBfFXECBAoAAQAGAQifRgBDDFcBBAoAAA==.',['�']='霜凛月:AwAICBUABAoDCgAIAQgfQgAvmtIBBAoACgAIAQgfQgAvmtIBBAoAEQADAQj9aQAMV0oABAoAAA==.霞儿:AwAICBEABAoAAA==.',['�']='青红皂了个白:AwAECAQABAoAAA==.青龙卧墨池:AwAFCAMABAoAAA==.',['�']='風雨:AwABCAEABAoAAA==.',['�']='风云向北风:AwADCAUABRQCCQADAQgWGgAxfecABRQACQADAQgWGgAxfecABRQAAA==.',['�']='马祖小夜曲:AwABCAEABAoAAA==.',['�']='黑暗幻象:AwAICBQABAoCEgAIAQjuJgA//foBBAoAEgAIAQjuJgA//foBBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end