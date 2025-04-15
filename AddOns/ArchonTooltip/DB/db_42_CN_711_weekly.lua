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
 local lookup = {'Monk-Mistweaver','Unknown-Unknown','Paladin-Retribution','Priest-Shadow','Paladin-Protection','Monk-Windwalker','Warrior-Fury','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Restoration','Shaman-Enhancement','Mage-Fire','Evoker-Preservation','Warlock-Destruction','DemonHunter-Havoc','Warrior-Arms','Rogue-Outlaw','Rogue-Assassination','Rogue-Subtlety','Druid-Restoration',}; local provider = {region='CN',realm='朵丹尼尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ca='Cardiologo:AwAICAgABAoAAA==.',Co='Corrosion:AwAICAgABAoAAA==.',De='Deephole:AwAECAQABRQAAQEAQnAHCAwABRQ=.',Di='Dieline:AwAECAIABRQAAQIAAAAICAQABRQ=.',Ev='Evemoon:AwAECAQABRQAAQMATkoGCAYABRQ=.',Go='Gossip:AwACCAIABRQAAA==.',Ja='Jade:AwACCAYABRQCBAACAQjIFgAXn30ABRQABAACAQjIFgAXn30ABRQAAA==.',Mi='Minecraft:AwAECAQABRQAAA==.',Ne='Neurologist:AwACCAIABRQAAA==.',Sh='Shasixiaog:AwADCAMABAoAAA==.',St='Stefani:AwAECAQABRQAAA==.',Tu='Turpin:AwADCAIABRQDBQAIAQjVEwA7SKsBBAoABQAIAQjVEwA64asBBAoAAwAIAQgjbgAn+ZYBBAoAAA==.',Un='Unlucky:AwAICAkABAoAAA==.',['�']='一只萌咕咕:AwAICAgABAoAAA==.一夜鱼龙舞:AwAGCAYABAoAAQYAXgAICAQABRQ=.三七八十一:AwAECAQABRQCBwAIAQjUFgBCJjwCBAoABwAIAQjUFgBCJjwCBAoAAA==.三出阙:AwAECAYABRQCAwAEAQg2EwAwJvUABRQAAwAEAQg2EwAwJvUABRQAAA==.三氧化硫:AwAICAEABAoAAA==.不奇怪:AwACCAIABRQAAA==.与逗逼有染:AwAECAQABRQAAA==.丑八怪哎哎:AwAFCA4ABAoAAA==.',['�']='伤心丶哲别:AwAECAUABRQDCAAEAQiXDAAbZL8ABRQACAAEAQiXDAAbZL8ABRQACQABAQjaOgAElkIABRQAAA==.',['�']='佛说要侑光:AwAFCAYABAoAAQIAAAAICAgABAo=.',['�']='值得一战:AwAFCAgABAoAAA==.',['�']='光头暴击萨:AwAECAwABRQDCgAEAQgkDAArjuQABRQACgAEAQgkDAArjuQABRQACwAEAQjfCQAuHNgABRQAAQsAPL4GCAYABRQ=.',['�']='冰封圣龙:AwACCAIABAoAAA==.',['�']='凤凰流沙包:AwADCAUABRQCAwADAQiBHQAm2ssABRQAAwADAQiBHQAm2ssABRQAAA==.凹凸熊:AwAICAgABAoAAA==.',['�']='初夏之菡:AwAFCAEABAoAAA==.别急慢点说:AwABCAEABAoAAA==.',['�']='十一月的雨:AwAECAQABRQAAA==.十里丶懿文:AwAGCAYABAoAAA==.半生不术:AwAFCAUABAoAAQIAAAAICAgABAo=.卡布奇喏:AwAECAQABAoAAA==.',['�']='又高又硬:AwAHCAcABAoAAA==.叶慕:AwAICAgABAoAAA==.',['�']='哈尼江:AwAFCAoABAoAAA==.哈库呐玛踏踏:AwAECAQABRQAAA==.哥德密斯:AwACCAIABRQAAA==.',['�']='喵了个喵咪:AwADCAMABAoAAA==.',['�']='嗜血喵喵怪:AwAECAUABRQCDAAEAQgbGwAhD80ABRQADAAEAQgbGwAhD80ABRQAAA==.',['�']='噂嘟假嘟:AwAHCAMABAoAAA==.',['�']='囿于昼夜:AwAICAgABAoAAA==.',['�']='堕落审判:AwAICAcABAoAAA==.',['�']='夜月丶弦音:AwAECAQABRQAAA==.大瑞:AwADCAYABAoAAA==.天使嫣然:AwABCAEABRQAAA==.',['�']='安娜斯西娅:AwAICBEABAoAAA==.',['�']='小宝贝儿:AwACCAIABRQAAA==.小树苗的愿望:AwAGCAYABAoAAA==.小欣:AwAECAQABRQAAA==.小空儿:AwAECAQABRQAAA==.小饼干:AwAECAgABRQCDQAEAQizAgA06dYABRQADQAEAQizAgA06dYABRQAAA==.',['�']='巨岩之拳:AwABCAEABRQAAA==.',['�']='帝啼:AwAGCAYABAoAAA==.',['�']='幻城新月:AwAECAQABAoAAA==.',['�']='德来德往:AwACCAIABRQAAA==.',['�']='总之就是壹刀:AwABCAEABRQAAA==.',['�']='恶魔:AwAICAwABAoAAA==.',['�']='悠悠球:AwAICAgABAoAAA==.',['�']='我心永恒十二:AwAECAIABAoAAA==.我选姿势好吗:AwACCAIABRQAAA==.',['�']='扎姆比迪斯:AwACCAIABRQAAA==.托尔丶奥丁森:AwAECAQABAoAAA==.',['�']='拖到黑处打:AwAFCAcABAoAAA==.',['�']='挽枫乀:AwAICA4ABAoAAA==.',['�']='新街圈圈:AwACCAQABRQCDgAHAQjyPQAmGFQBBAoADgAHAQjyPQAmGFQBBAoAAA==.',['�']='无奸不摧之李:AwAICAgABAoAAA==.无情的贼贼:AwAECAEABRQAAA==.无谓新体验:AwACCAQABRQAAA==.',['�']='明月栞那:AwADCAMABRQAAA==.春水向东流:AwAECAQABRQAAA==.显上堵场:AwAICAgABAoAAA==.',['�']='曼曼老母亲:AwABCAEABRQAAA==.',['�']='本来很霸道:AwAICBIABAoAAA==.朱七七:AwADCAMABAoAAA==.',['�']='枪炮师:AwAECAQABRQAAA==.枫林唱晚:AwADCAEABAoAAA==.',['�']='柠檬百香菓:AwAECAMABRQAAA==.',['�']='梦梦柚子猫:AwACCAIABRQAAQIAAAADCAMABRQ=.梦魇怪盗:AwAECAgABRQCDwAEAQiTBwBM6hsBBRQADwAEAQiTBwBM6hsBBRQAAA==.梨小落:AwAECAIABRQAAA==.',['�']='橘外人:AwACCAIABRQAAA==.橙仟上萬:AwAICA4ABAoAAA==.橙千上萬:AwAICAgABAoAAA==.橙小果:AwAECAgABRQCBwAEAQh7CQBCywgBBRQABwAEAQh7CQBCywgBBRQAAA==.橙橙饭:AwAICAYABAoAAA==.',['�']='死亡悍匪:AwACCAIABRQAAA==.',['�']='气泡糖:AwAECAQABRQAAQIAAAAGCAIABRQ=.',['�']='沉默之伤:AwAICAIABAoAAA==.',['�']='法外张三:AwAECAEABRQAAA==.泪宇:AwADCAMABAoAAA==.',['�']='洗吹剪:AwAHCA0ABAoAAA==.',['�']='浮世千寻沫:AwAECAsABAoAAA==.',['�']='混沌游戏:AwACCAMABRQCCgAIAQgyDwBQwGYCBAoACgAIAQgyDwBQwGYCBAoAAA==.',['�']='湘菇:AwAICAYABAoAAA==.',['�']='火焰獠牙:AwAICA4ABAoAAA==.灵央遗老:AwAECAQABRQAAA==.',['�']='点卡马扁子:AwAICAkABAoAAA==.',['�']='爱意随钟起:AwACCAIABRQAAQIAAAAICAQABRQ=.',['�']='犀牛哥:AwADCAMABAoAAA==.',['�']='狂暴坦爷:AwADCAMABRQAAA==.狐力大仙:AwAICBoABAoCCgAIAQifJwBDCMkBBAoACgAIAQifJwBDCMkBBAoAAA==.',['�']='猜猜看:AwAFCAgABAoAAA==.猪大力:AwAECAgABRQCCQAEAQg/CgBF7hUBBRQACQAEAQg/CgBF7hUBBRQAAA==.',['�']='王二妞:AwAHCAcABAoAAA==.玛卡巴卡:AwAICAkABAoAAA==.玫瑰蛋黄酥:AwADCAMABRQAAA==.',['�']='瓜牛:AwABCAEABRQDBwAIAQh0CABY+bgCBAoABwAIAQh0CABY+bgCBAoAEAAFAQgWOgAuab8ABAoAAA==.',['�']='甜桃:AwABCAIABRQAAQIAAAAICAIABRQ=.',['�']='疯狂小朱迪:AwAFCAgABAoAAA==.',['�']='痛觉残留:AwAGCAYABAoAAA==.',['�']='相遇即有缘:AwAGCAYABAoAAA==.',['�']='眷思量灬:AwACCAUABRQCDgACAQjfGAA124cABRQADgACAQjfGAA124cABRQAAA==.',['�']='神鹤引颈踢:AwAECAQABRQAAA==.神龙再现:AwAECAgABRQDEQAEAQgFAgAVissABRQAEQAEAQgFAgAVissABRQAEgAEAQiLDQAIc5QABRQAAA==.',['�']='离我远点:AwABCAIABRQAAA==.',['�']='符娃瓜瓜:AwACCAIABRQAAA==.',['�']='粉色大苍蝇:AwAGCAgABAoAAQIAAAAICAkABAo=.',['�']='维吉尔丶:AwAFCAQABAoAAA==.',['�']='缥缈小波:AwABCAEABRQAAA==.',['�']='美若黎明:AwADCAMABAoAAA==.',['�']='肆搂利:AwAICAMABAoAAA==.肥恐龙:AwAICAkABAoAAA==.',['�']='舞笙缇:AwADCAcABRQCBAADAQhiCgA4q+wABRQABAADAQhiCgA4q+wABRQAAA==.',['�']='艾瑞吧迪:AwABCAEABRQAAA==.',['�']='芥末布丁:AwAECAQABRQAAA==.',['�']='茶拉明:AwAHCAcABAoAAA==.',['�']='荒原箭歌:AwACCAIABRQCCAAIAQjKHAAxWrABBAoACAAIAQjKHAAxWrABBAoAAA==.',['�']='落羽:AwACCAIABRQAAA==.',['�']='葵司:AwADCAMABAoAAA==.',['�']='血雨残夜:AwAHCBQABAoDCAAHAQgwKwA3z00BBAoACAAHAQgwKwAy6U0BBAoACQADAQg9zAA6I2gABAoAAA==.衣阿华:AwAGCAwABAoAAA==.',['�']='讲个笑话你听:AwAICAgABAoAAA==.',['�']='诗婧益源:AwAICAgABAoAAA==.',['�']='谷风天音:AwACCAMABRQEEgAIAQg0CgBZo04CBAoAEgAHAQg0CgBX304CBAoAEwAFAQhZEgBQ98UBBAoAEQACAQh7EABFrJ8ABAoAAQIAAAAECAEABRQ=.',['�']='贱不虚发:AwABCAEABAoAAA==.',['�']='赤豆酒酿:AwAFCAEABAoAAA==.',['�']='达尔达尼央:AwABCAEABRQAAA==.',['�']='还是少年:AwAICAgABAoAAA==.迷梦天涯:AwACCAIABRQAAA==.',['�']='那个嘟嘟:AwABCAEABRQAAA==.那年荼靡:AwAICAYABAoAAA==.',['�']='郎教授:AwAHCAgABAoAAA==.部落最帅武僧:AwAECAQABRQAAA==.',['�']='酸漿果:AwAICAgABAoAAA==.',['�']='闪电暴龙兽:AwADCAQABAoAAA==.闲人:AwADCAcABRQCFAAIAQjvBABW8LECBAoAFAAIAQjvBABW8LECBAoAAA==.',['�']='阿比斯深渊:AwABCAIABRQAAA==.',['�']='雷神砣尔:AwAFCAkABAoAAA==.',['�']='饭团臭袜子:AwAECAUABAoAAA==.',['�']='騎師:AwAICBQABAoCBwAIAQhiNwAU8HUBBAoABwAIAQhiNwAU8HUBBAoAAA==.',['�']='骰子的第柒面:AwACCAIABRQAAA==.',['�']='黑夜千只眼:AwACCAUABRQCBwACAQiBGgATKIcABRQABwACAQiBGgATKIcABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end