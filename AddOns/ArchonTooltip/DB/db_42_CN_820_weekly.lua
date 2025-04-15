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
 local lookup = {'Priest-Holy','Warrior-Fury','Shaman-Elemental','Unknown-Unknown','Druid-Balance','Monk-Windwalker','Shaman-Enhancement','Mage-Frost','Mage-Fire','Paladin-Holy','Paladin-Retribution','DemonHunter-Havoc','Shaman-Restoration','Rogue-Subtlety','Warrior-Protection','Warrior-Arms','Monk-Mistweaver','Rogue-Assassination','Druid-Restoration','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Priest-Shadow','Paladin-Protection',}; local provider = {region='CN',realm='藏宝海湾',name='CN',type='weekly',zone=42,date='2025-04-15',data={Bl='Bloodyfox:AwACCAUABRQCAQACAQh+EwAfOYIABRQAAQACAQh+EwAfOYIABRQAAA==.',Ch='Chaos:AwABCAIABRQCAgAIAQh0GQBGsi8CBAoAAgAIAQh0GQBGsi8CBAoAAA==.',Li='Liliths:AwAICAgABAoAAQMAT2YGCAIABRQ=.',Pa='Paul:AwACCAIABRQAAA==.',Ru='Runan:AwACCAIABRQAAA==.',Sc='Scarletty:AwAICAQABAoAAA==.',Tr='Trnt:AwAICAgABAoAAA==.',Va='Valkyrie:AwABCAEABRQAAQQAAAAGCAQABRQ=.',['�']='一念成魔:AwAICAsABAoAAA==.一条恶龙:AwABCAEABRQAAA==.一狩猎一:AwAECAQABAoAAA==.',['�']='二十年:AwAHCAkABAoAAA==.二队小德:AwAECAQABRQAAA==.云朵团团:AwAECA4ABRQCAQAEAQjCAwBObBMBBRQAAQAEAQjCAwBObBMBBRQAAA==.',['�']='保卫室郭大爷:AwAICAgABAoAAA==.',['�']='八雲蓝:AwAICAUABAoAAA==.',['�']='别聊了奶我:AwAECAQABRQAAA==.',['�']='千里同风:AwAECAQABRQAAA==.千重:AwAHCAwABAoAAA==.午后悠怡:AwAECAQABRQAAQMAVZkICAIABRQ=.',['�']='另壶葱:AwAECAYABAoAAA==.',['�']='吊儿啷当紫静:AwAICAgABAoAAA==.含丶笑:AwAECAQABAoAAQQAAAACCAQABRQ=.',['�']='周浦内马尔:AwAECAQABRQAAQUADlAGCA8ABRQ=.',['�']='咕德猫咛:AwAECAkABAoAAA==.',['�']='喵咩咩:AwABCAEABRQCBgAIAQimGgA4We0BBAoABgAIAQimGgA4We0BBAoAAA==.',['�']='因幡月夜:AwABCAEABRQAAA==.',['�']='地狱公爵:AwAECAQABRQAAA==.',['�']='墨燊:AwACCAQABRQAAA==.',['�']='娴熟虎:AwAECAUABRQDBwAEAQj9BQA9pw4BBRQABwAEAQj9BQA9pw4BBRQAAwABAQjPGQAIsDMABRQAAA==.',['�']='小云之痛苦:AwABCAEABRQDCAAIAQjYNgAhsnABBAoACAAIAQjYNgAhaHABBAoACQAFAQgqXAAphuwABAoAAA==.小力飞道:AwAHCAYABAoAAA==.小呀小么牛:AwAICAsABAoAAA==.小唐不糖:AwAFCAUABAoAAA==.小小修修:AwABCAIABRQAAA==.小能猫:AwAFCAUABAoAAA==.小陆:AwACCAQABRQAAA==.',['�']='左岸咖啡:AwAECAgABRQDCgAEAQgpDQAzboYABRQACgADAQgpDQAeSoYABRQACwABAQiWQwAE4kIABRQAAA==.',['�']='幻海梦蝶:AwABCAIABRQCDAAIAQgkJQBCUA4CBAoADAAIAQgkJQBCUA4CBAoAAA==.',['�']='当当小红手儿:AwAECAQABRQAAA==.当当很满意:AwAGCAYABAoAAA==.',['�']='後會丶無期:AwAICAgABAoAAA==.',['�']='慕容馨児:AwAECAEABRQCCQAIAQiiGgBKjEsCBAoACQAIAQiiGgBKjEsCBAoAAA==.',['�']='我有小跟班:AwAGCAYABAoAAA==.战挚:AwAFCA8ABAoAAA==.战魂:AwABCAIABRQCDQAIAQiJGABHeicCBAoADQAIAQiJGABHeicCBAoAAA==.',['�']='扎西德:AwABCAEABAoAAA==.',['�']='拉图修斯:AwACCAIABAoAAA==.',['�']='指尖:AwAICA0ABAoAAA==.',['�']='插标卖首之徒:AwAICAsABAoAAA==.',['�']='时光徽章:AwAGCAgABAoAAA==.旺旺牙牙:AwAECAYABRQCDgAIAQgkCQBKJ1gCBAoADgAIAQgkCQBKJ1gCBAoAAA==.',['�']='晓晓鹿:AwECCAEABRQAAQQAAAAICAMABRQ=.',['�']='暗之狂奔:AwAICBEABAoAAA==.暗夜银湾:AwADCAIABAoAAQQAAAAFCAcABAo=.',['�']='最豆的时光:AwAECAQABAoAAA==.',['�']='来快点:AwADCAMABAoAAA==.',['�']='欧贝利斯:AwABCAEABRQEDwAIAQgVCgBGNfgBBAoADwAIAQgVCgA+6fgBBAoAAgAHAQhRKgBEyskBBAoAEAAEAQivNwAsRt0ABAoAAA==.',['�']='死噬:AwAICAgABAoAAA==.',['�']='毒奶十八式:AwAICAgABAoAAREAQnAHCAwABRQ=.',['�']='水月大师:AwACCAIABRQAAA==.',['�']='沙扬娜拉:AwABCAIABRQDEgAIAQhEAQBgD/kCBAoAEgAIAQhEAQBe5fkCBAoADgAIAQiBAwBZl8ECBAoAAA==.沫絔:AwACCAIABAoAAA==.',['�']='淡墨:AwACCAIABRQAAA==.',['�']='牛啦仆:AwAFCAcABAoAAA==.牛啦梦:AwABCAIABRQCEwAIAQhJDABNnlcCBAoAEwAIAQhJDABNnlcCBAoAAA==.',['�']='狐假虎哥威:AwABCAEABRQAAA==.',['�']='看我眼神行事:AwACCAIABAoAAA==.',['�']='短尾巴:AwABCAIABRQDFAAIAQjXEgBFNxQCBAoAFAAIAQjXEgBETBQCBAoAFQADAQjowQA2lIUABAoAAA==.',['�']='祖师婆:AwABCAIABRQEFgAIAQhTHgBVWf8BBAoAFgAHAQhTHgBTbv8BBAoAFwAFAQieGgBQy3IBBAoAGAABAQj2QAAx1jAABAoAAA==.',['�']='秋之残云:AwAECAQABAoAAA==.',['�']='穷少爷:AwAECAQABRQAAA==.',['�']='红栾炮:AwABCAEABRQAAA==.红红双囍:AwABCAEABRQCEQAIAQjSOAAc8UoBBAoAEQAIAQjSOAAc8UoBBAoAAA==.',['�']='老陳:AwABCAEABRQAAA==.',['�']='花葬无暇:AwAECAUABRQDCQAEAQjoGAAsG+AABRQACQAEAQjoGAAsG+AABRQACAABAQi1HQAIjy8ABRQAAA==.',['�']='莉亚德琳:AwABCAEABRQAAA==.',['�']='菲尼克丝:AwABCAEABRQAAA==.',['�']='落叶残阳:AwACCAIABAoAAA==.',['�']='蓝黑色的忧伤:AwABCAIABRQCGQAIAQhJFgA/GRECBAoAGQAIAQhJFgA/GRECBAoAAA==.',['�']='蜜糖橙:AwABCAIABRQDCwAIAQi1PgBFDxoCBAoACwAHAQi1PgBOqRoCBAoAGgABAQhQXgALeBQABAoAAA==.',['�']='術爷:AwADCAYABRQCGAADAQidBAA82QMBBRQAGAADAQidBAA82QMBBRQAAA==.',['�']='西瓜的皮:AwAICBcABAoDFQAIAQjeHABUMnMCBAoAFQAIAQjeHABRiHMCBAoAFAABAQjjYQBUnGIABAoAAA==.',['�']='言叶之森:AwAECAQABAoAAA==.',['�']='这次射哪里:AwACCAIABRQAAA==.迷了路的鹿:AwABCAIABRQDCQAIAQjPJgA8ggMCBAoACQAIAQjPJgA8ggMCBAoACAAFAQhBYQAsr8EABAoAAA==.',['�']='青螭:AwACCAEABAoAAA==.',['�']='颓废的史哥:AwACCAIABRQAAA==.',['�']='风走过的天空:AwAECAQABRQAAA==.',['�']='麦崖:AwABCAEABRQCCwAIAQi6NABEmTsCBAoACwAIAQi6NABEmTsCBAoAAA==.麦麦噱鳕:AwABCAEABRQAAA==.',['�']='默默的玥岚:AwABCAIABRQCEQAIAQhSIgA9f8YBBAoAEQAIAQhSIgA9f8YBBAoAAA==.黯丨岚:AwAECAQABRQAAA==.',['�']='龙魂之最:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end