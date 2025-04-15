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
 local lookup = {'Unknown-Unknown','Druid-Restoration','Mage-Fire','DeathKnight-Unholy','DeathKnight-Blood','Monk-Windwalker','Warrior-Fury','Paladin-Retribution','Shaman-Restoration','Shaman-Enhancement','Warrior-Arms','Priest-Holy','Paladin-Holy','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','Druid-Feral','Druid-Balance','Hunter-Marksmanship','Hunter-BeastMastery',}; local provider = {region='CN',realm='玛洛加尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ae='Aenaiu:AwAECAQABRQAAA==.',An='Anemone:AwAICAgABAoAAA==.Animone:AwAICAgABAoAAA==.',Be='Beyourmyth:AwAECAQABRQAAA==.',Ch='Cherles:AwAGCAYABAoAAA==.',Da='Daylight:AwAICAgABAoAAQEAAAAGCAMABRQ=.',Fi='Fiercewind:AwAICAgABAoAAA==.',Ga='Gayi:AwAHCAgABAoAAA==.',Ge='Geminorum:AwAHCAgABAoAAA==.',Ih='Ihsekat:AwAECAQABRQAAQIAGW4GCAoABRQ=.',Ji='Jimmorrison:AwAICAgABAoAAA==.',Kr='Krizy:AwAICA8ABAoAAA==.',Li='Liepriest:AwAICA8ABAoAAA==.',Ma='Magerong:AwAFCAgABRQCAwAFAQjeBgA4iTkBBRQAAwAFAQjeBgA4iTkBBRQAAA==.',Nb='Nbstar:AwAECAMABRQAAA==.',Ol='Olivine:AwAECAIABRQAAA==.',Re='Revolutionar:AwAICAgABAoAAA==.',St='Stellar:AwAECAQABRQAAQEAAAAICAEABRQ=.Struers:AwAFCAUABAoAAA==.',Ul='Ula:AwAICA8ABAoAAA==.',Wi='Wicky:AwACCAIABRQAAA==.',['�']='丶小残暴:AwAECAYABRQDBAAEAQiiBwBANQcBBRQABAAEAQiiBwBANQcBBRQABQACAQhREwA4xn4ABRQAAA==.丶豆豆:AwAECAMABAoAAA==.丿弑神丶地震:AwAECAgABRQCBgAEAQguBwA43/YABRQABgAEAQguBwA43/YABRQAAA==.',['�']='亚瑟丶兰斯洛:AwAECAQABRQAAA==.亦如:AwAECAQABAoAAA==.',['�']='伊集院隼人:AwADCAMABAoAAA==.',['�']='低头思故鄕:AwAGCAQABRQAAA==.你贩剑嘛:AwAECAcABRQCBwAEAQg6CgA8BAQBBRQABwAEAQg6CgA8BAQBBRQAAA==.',['�']='依然飯特稀丶:AwAHCAcABAoAAA==.',['�']='元素萨满:AwACCAIABRQAAA==.光头墙:AwADCAgABRQCCAADAQilFgA4wuoABRQACAADAQilFgA4wuoABRQAAA==.光明黑牛:AwADCAMABAoAAA==.',['�']='冰镇菊花茶:AwAGCAYABAoAAA==.',['�']='加肥猫:AwACCAIABAoAAA==.',['�']='北纬四十七度:AwAGCAYABAoAAA==.',['�']='十足十梁朝伟:AwAICAgABAoAAA==.卡加德之滣:AwABCAEABRQAAA==.',['�']='叶临渊:AwAGCAIABRQAAA==.',['�']='名字很头痛:AwAECAQABRQAAA==.',['�']='呆萌丶亨特:AwAECAQABAoAAA==.',['�']='哇哈哈嘻嘻:AwABCAEABRQCCQAIAQgbLgAzyKkBBAoACQAIAQgbLgAzyKkBBAoAAA==.哪个丶戦士:AwAFCAUABAoAAA==.',['�']='唐牛:AwACCAIABRQAAA==.',['�']='埃辛诺思:AwACCAIABRQAAA==.埴安神袿姫:AwADCAMABRQCCgAIAQiQAQBgbP4CBAoACgAIAQiQAQBgbP4CBAoAAA==.',['�']='大猩猩:AwABCAEABRQAAA==.大鼻子绿脑袋:AwAECAIABRQAAA==.太默默被遗忘:AwACCAMABRQAAA==.',['�']='宾利也将就:AwADCAsABRQCCwADAQg6AwBA4A0BBRQACwADAQg6AwBA4A0BBRQAAA==.',['�']='小丑勿语:AwAFCAEABAoAAA==.小丶幸運:AwAECAQABRQAAA==.小囧囧兔:AwAFCAkABAoAAA==.小宝吃火锅:AwABCAEABRQCDAAIAQg4HwAz6boBBAoADAAIAQg4HwAz6boBBAoAAA==.',['�']='崔丞相觐见:AwACCAIABRQAAA==.',['�']='巨滑大:AwABCAEABAoAAA==.巴拉巴巴拉:AwAECAgABRQDCAAEAQixDwBGuAIBBRQACAAEAQixDwBGuAIBBRQADQADAQjMCgAwhpIABRQAAA==.',['�']='帝罗:AwABCAEABAoAAA==.',['�']='德的奶也有毒:AwAECAQABRQAAA==.',['�']='恰雪来故:AwAICAgABAoAAA==.',['�']='情傷:AwAICBQABAoCCQAIAQiwPgApJWQBBAoACQAIAQiwPgApJWQBBAoAAA==.',['�']='愢愢丨嘂嘂:AwABCAEABRQAAA==.',['�']='抓只小德:AwAGCAgABAoAAA==.',['�']='斋藤飛鸟:AwADCAMABAoAAA==.方钰清沙遍:AwAECAoABRQDBwAEAQheCQA/ZgkBBRQABwAEAQheCQA/ZgkBBRQACwACAQiUDgAPymgABRQAAA==.',['�']='昂桃酱酱:AwAICAgABAoAAA==.',['�']='晚晚折风:AwAECAQABRQAAA==.',['�']='月醉颜:AwAICAYABAoAAA==.',['�']='李二狗:AwAICAgABAoAAA==.来自阴影:AwAGCAcABAoAAA==.',['�']='柒麻麻:AwAFCAUABAoAAA==.',['�']='栀子扇掩笑颜:AwACCAIABRQAAA==.栤雙兒:AwABCAEABAoAAA==.',['�']='楸兲的玩偶:AwAECAYABRQCBwAEAQgFDgAkXe8ABRQABwAEAQgFDgAkXe8ABRQAAQsAN/gGCAoABRQ=.',['�']='欸泽拉斯:AwABCAEABRQAAA==.',['�']='死亦若丹丶:AwACCAMABAoAAA==.歼灭灬战:AwACCAIABRQAAA==.',['�']='每天吃低保:AwAECAQABRQAAQEAAAAICAQABRQ=.毫秒华语:AwAECAQABRQAAQ4AIA0ICAMABRQ=.',['�']='沐橙橙:AwAECAQABAoAAQEAAAABCAEABRQ=.',['�']='流氓在哪飘:AwAFCAkABAoAAA==.',['�']='深海葬麋鹿丶:AwABCAEABAoAAA==.混元无极仙:AwABCAEABRQAAA==.',['�']='牛爷:AwACCAIABAoAAA==.',['�']='獣人丶武僧:AwAICBAABAoAAA==.獣命于天:AwAECAIABRQAAA==.',['�']='生闷气大王:AwAECAEABRQAAA==.',['�']='看鸽养猪:AwAECAQABAoAAA==.',['�']='破势:AwAICAgABAoAAA==.',['�']='碧螺春虾仁:AwAICAYABAoAAA==.',['�']='祈风:AwAECAQABRQAAA==.',['�']='穆德:AwACCAEABRQAAQEAAAAECAQABRQ=.',['�']='笨啦啦:AwAECAQABRQAAA==.笨笨丶酱:AwAECAYABRQDDwAEAQhtEwAT+q4ABRQADwAEAQhtEwAR2a4ABRQAEAABAQhAEgATTz8ABRQAAA==.',['�']='糕手凡凡:AwAGCAMABAoAAA==.',['�']='老板喜欢地板:AwABCAEABRQAAA==.',['�']='聆风吟:AwACCAIABRQDBwAIAQh9FABIh04CBAoABwAIAQh9FABIh04CBAoACwACAQhwRQApqocABAoAAA==.',['�']='肇事咕儿:AwAECAgABRQDEQAEAQg/AgAiwuYABRQAEQAEAQg/AgAdaOYABRQAEgAEAQhXEgAfyNoABRQAARMAVdsICAgABRQ=.',['�']='脆脆鲨:AwAECAQABRQAAA==.',['�']='苗木丶诚:AwACCAIABRQAAA==.',['�']='莉雅丶夜翼:AwAGCA4ABAoAAA==.',['�']='萨满开嗜血:AwAECAQABAoAAA==.落叶风:AwAICAgABAoAAA==.落花雨:AwAECAQABRQCCAAIAQiC2QATfcAABAoACAAIAQiC2QATfcAABAoAAA==.',['�']='葡萄酱酱:AwAICAgABAoAAA==.葫芦酒仙:AwACCAIABRQAAA==.',['�']='蓝星:AwADCAUABAoAAA==.',['�']='藤林杏丶:AwAECAMABRQAAA==.',['�']='蜜桃四季春:AwAICAsABAoAAA==.',['�']='表弟丶:AwAHCAQABRQAAA==.',['�']='退休后现状:AwAECAgABRQCFAAEAQiEDwBFbvsABRQAFAAEAQiEDwBFbvsABRQAAA==.',['�']='重紫:AwAFCAUABAoAAA==.',['�']='镜子骑士:AwAECAQABRQAAA==.长城炮:AwABCAEABRQAAA==.长期素食:AwAECAQABRQAAA==.长沟流月:AwACCAMABRQAAA==.',['�']='阿痛木:AwACCAQABAoAAA==.',['�']='雪丨月:AwAECAQABRQAAA==.',['�']='顶住我掩护:AwADCAgABRQDFAADAQg4EgBAGPEABRQAFAADAQg4EgBAGPEABRQAEwABAQg+GQBCcUYABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end