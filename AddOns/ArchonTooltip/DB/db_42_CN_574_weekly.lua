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
 local lookup = {'Rogue-Assassination','Mage-Fire','Priest-Holy','Monk-Mistweaver','Shaman-Elemental','Monk-Windwalker','DeathKnight-Blood','Warlock-Demonology','Monk-Brewmaster','Druid-Balance','Druid-Restoration','Paladin-Retribution','Hunter-BeastMastery','Unknown-Unknown',}; local provider = {region='CN',realm='元素之力',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ay='Ayanamirei:AwACCAIABRQCAQAIAQjoDQA48hcCBAoAAQAIAQjoDQA48hcCBAoAAA==.',Qi='Qingyi:AwAICBAABAoAAA==.',Sa='Sar:AwAGCAIABRQAAA==.',['�']='一柒柒一:AwAECAQABRQAAQIATgYGCAgABRQ=.丁彡石:AwAGCA8ABAoAAA==.七星静香:AwAGCAQABRQAAA==.不老亡魂:AwAGCBoABAoCAwAGAQhqKQBF1nwBBAoAAwAGAQhqKQBF1nwBBAoAAA==.丕卡虬:AwAFCAUABAoAAA==.',['�']='乔克阿姨:AwAGCAYABAoAAA==.',['�']='伏弦:AwAGCAYABAoAAA==.',['�']='佳期如梦丶:AwAICBoABAoCBAAIAQgdEwBHTDYCBAoABAAIAQgdEwBHTDYCBAoAAA==.',['�']='养牛专业户:AwAGCBYABAoCBQAGAQiwIgBTv6cBBAoABQAGAQiwIgBTv6cBBAoAAA==.',['�']='凉小勾:AwAGCBQABAoCAQAGAQgvIwAk6Q4BBAoAAQAGAQgvIwAk6Q4BBAoAAA==.',['�']='刘老师:AwAICAQABRQAAA==.别怕有冰箱:AwAGCAYABAoAAA==.',['�']='千荷武:AwAGCBYABAoDBgAGAQg8NgAp1RUBBAoABgAGAQg8NgAp1RUBBAoABAAGAQjaVAAUmMMABAoAAA==.南风知我意:AwAECAQABRQAAA==.',['�']='右手黑暗:AwAGCA4ABAoAAA==.',['�']='吕布战三胤:AwACCAIABRQAAA==.听风的蚕:AwADCAEABAoAAA==.',['�']='咸鱼小熊猫:AwADCAMABAoAAA==.',['�']='哈库拉嗨比:AwAICAgABAoAAA==.哞哞蔻小琪:AwAGCAYABAoAAA==.',['�']='团长我躺哪儿:AwADCAIABRQAAA==.图腾霸霸丶:AwACCAIABAoAAA==.',['�']='圣光小罗莉:AwAICAwABAoAAA==.地狱小吼:AwAGCA4ABAoAAA==.',['�']='堕落的雨:AwAECAQABRQAAA==.',['�']='奥卡斯:AwAECAQABRQAAA==.奶爸别担心:AwAICAgABAoAAA==.',['�']='宝批龍:AwAGCAYABAoAAA==.',['�']='小海狗:AwAICBAABAoAAA==.少年王之怒:AwAGCBgABAoCBwAGAQgdJgA5JyoBBAoABwAGAQgdJgA5JyoBBAoAAA==.',['�']='席尔瓦纳斯:AwAGCBoABAoCCAAGAQj+FgBDuYIBBAoACAAGAQj+FgBDuYIBBAoAAA==.',['�']='幻影:AwABCAEABRQAAA==.幽泉:AwAFCAUABAoAAA==.',['�']='弑羽:AwAECAQABRQAAQIAQ8QICAcABRQ=.弗拉明戈舞步:AwAICAgABAoAAA==.',['�']='悟嗳慲訫:AwACCAQABRQAAA==.',['�']='憨老头:AwADCAMABAoAAA==.',['�']='我先端三个:AwAICAgABAoAAA==.我叫胖墩墩:AwABCAEABRQCCQAIAQgtCQA3CagBBAoACQAIAQgtCQA3CagBBAoAAA==.我知道要进潜:AwAECAgABRQDCgAEAQj3GQA6caAABRQACgADAQj3GQBCtKAABRQACwABAQgzHQAL0TIABRQAAA==.',['�']='打望:AwADCAMABAoAAA==.扶阿奶闯红灯:AwAGCBYABAoCDAAGAQgLrgAjYAsBBAoADAAGAQgLrgAjYAsBBAoAAA==.',['�']='撕裂噩梦:AwAICAgABAoAAA==.',['�']='无尽之海:AwACCAEABAoAAA==.无尽之门:AwAICAgABAoAAA==.',['�']='星岩:AwAECAQABRQAAQIAMkEGCAgABRQ=.是风就该自由:AwAICBkABAoCBQAIAQi3HgAx08cBBAoABQAIAQi3HgAx08cBBAoAAA==.',['�']='木头贝贝:AwAECAYABAoAAA==.朴危黎:AwAECAQABAoAAA==.',['�']='梦中的浮空城:AwAECAQABRQAAA==.',['�']='油老师狂热粉:AwAGCAgABAoAAA==.',['�']='泪殤旖旎:AwAICAgABAoAAQ0AShkGCA4ABRQ=.',['�']='清衣晚风:AwABCAEABAoAAA==.',['�']='烟雨伊风:AwAECAQABRQAAA==.',['�']='牌坊老男人:AwABCAEABAoAAA==.',['�']='狄迪迪:AwAECAQABAoAAA==.',['�']='猫迩葉:AwAECAQABRQAAA==.',['�']='琉璃昂:AwABCAEABRQAAA==.',['�']='白光莹:AwAICAcABAoAAA==.白菜:AwAECAQABRQAAA==.',['�']='篱笆菜菜子:AwAECAQABRQAAA==.',['�']='绝命滑铲:AwACCAIABAoAAA==.',['�']='缇啦米酥:AwAECAQABAoAAA==.',['�']='翻地滚:AwAGCAcABAoAAA==.',['�']='老大:AwAHCAsABAoAAA==.',['�']='肥嘟嘟左卫门:AwAFCAUABAoAAA==.',['�']='艾莲:AwAECAQABAoAAA==.',['�']='芙莉莲:AwAECAQABRQAAA==.',['�']='莎拉格雷拉特:AwAICBAABAoAAQ4AAAAGCAQABRQ=.',['�']='萌新小撒:AwAICAwABAoAAA==.',['�']='蒙查查:AwAICAgABAoAAA==.',['�']='蓝猪:AwAECAQABRQAAA==.',['�']='逝水无痕:AwAGCAYABAoAAA==.',['�']='阿发古:AwAICAoABAoAAA==.阿茶:AwAECAUABRQCDQACAQgVHABWwLgABRQADQACAQgVHABWwLgABRQAAA==.',['�']='韭菜鸡蛋:AwAICAUABAoAAA==.',['�']='飞星寻龙:AwAECAQABAoAAA==.',['�']='黑黑猫警长:AwAECAQABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end