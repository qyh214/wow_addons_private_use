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
 local lookup = {'Monk-Mistweaver','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Unknown-Unknown','Paladin-Retribution','Druid-Feral','Druid-Restoration','Druid-Balance','Evoker-Preservation','DeathKnight-Unholy','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Fury','Warrior-Arms','Mage-Frost','Shaman-Enhancement','Shaman-Restoration','Warrior-Protection','Monk-Windwalker','Monk-Brewmaster','Priest-Holy','Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Frost','Hunter-Survival','Priest-Shadow','Evoker-Devastation','Rogue-Subtlety','Rogue-Assassination',}; local provider = {region='CN',realm='戈提克',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Ado:AwAECAgABRQCAQAEAQiVCgA1evIABRQAAQAEAQiVCgA1evIABRQAAA==.',An='Angieashfor:AwAICBIABAoAAA==.Anrors:AwADCAMABAoAAA==.',Ar='Ardbeg:AwAGCBoABAoEAgAGAQhyFgAl/BsBBAoAAgAFAQhyFgAkUxsBBAoAAwAFAQhAPQAQ9agABAoABAADAQhoeAAWcYMABAoAAA==.Artaxe:AwACCAIABAoAAA==.',Be='Beckinsale:AwAECAQABRQAAA==.Benares:AwACCAIABAoAAA==.',Bl='Bluess:AwAECAQABRQAAA==.Bluex:AwAICAgABAoAAQUAAAAICAQABRQ=.Bluexx:AwAECAQABRQAAA==.',Ca='Cake:AwABCAEABRQAAA==.',Da='Darker:AwAECAUABAoAAA==.',Di='Dispirited:AwAFCAEABAoAAA==.',Es='Esmex:AwAECAQABRQAAA==.',Gr='Grimmjow:AwAECAQABRQAAA==.',La='Larry:AwAECAcABAoAAA==.',Lu='Ludiwg:AwACCAIABAoAAA==.',Ne='Neroclaudius:AwADCAwABRQCBgADAQgFBgBXhS4BBRQABgADAQgFBgBXhS4BBRQAAA==.',Ol='Ollopopollo:AwABCAEABAoAAA==.',Ov='Overture:AwADCAMABAoAAA==.',Sh='Sharkx:AwADCAkABRQEBwADAQjKAwApKacABRQABwACAQjKAwA7lacABRQACAABAQgzGQAhiT4ABRQACQABAQgELAAETzsABRQAAA==.',To='Tob:AwADCAMABAoAAQoAS4UICBgABAo=.',['�']='一勺三花淡奶:AwAICAgABAoAAA==.一纸荒年:AwADCAMABAoAAA==.一骑绝尘:AwAGCAwABAoAAA==.丁瑶:AwAECAQABRQAAA==.上学不逃学:AwAECAQABRQCCAAIAQjTHQA2jK0BBAoACAAIAQjTHQA2jK0BBAoAAA==.不偷袭你也死:AwAFCAUABAoAAA==.丨摩托罗拉丨:AwAICAwABAoAAA==.丹娜丶:AwAICAgABAoAAA==.丿尘埃丶:AwAICAUABAoAAA==.',['�']='乀刀来:AwAECAQABRQAAA==.乔碧萝乔斯塔:AwADCAMABAoAAA==.九幽黄光:AwAGCAYABAoAAA==.',['�']='云旗:AwADCAQABRQAAA==.云过长空:AwAICAgABAoAAA==.五五开彦祖:AwAGCAYABAoAAA==.亡语:AwAICAgABAoAAQsAQ3QGCA0ABRQ=.',['�']='仿生泪滴:AwAHCBQABAoDDAAHAQgSNAA81LcBBAoADAAHAQgSNAA81LcBBAoADQADAQgURgAtIXYABAoAAA==.',['�']='会炒蛋炒饭:AwAGCAYABAoAAA==.',['�']='余晓曼:AwADCAcABRQDDgADAQg+DwBbd+QABRQADgACAQg+DwBgaeQABRQADwABAQiWDwBRkl0ABRQAAA==.你家张三爷:AwABCAEABAoAAA==.',['�']='侑点小变态:AwADCAMABAoAAA==.依然丶非死的:AwAECAQABRQAAA==.便便牛:AwAHCAcABAoAAA==.',['�']='傳説中的魚:AwAECAgABRQCEAAEAQiNAgBEfxsBBRQAEAAEAQiNAgBEfxsBBRQAAA==.傻意:AwAICAgABAoAAA==.',['�']='再闹我弄你哦:AwAFCAcABAoAAA==.冥海无岸:AwAFCAUABAoAAA==.',['�']='凶猛肥宅:AwAGCBoABAoCDwAGAQgLIwA6tWcBBAoADwAGAQgLIwA6tWcBBAoAAA==.',['�']='南征北戦灬:AwACCAYABRQCEQACAQjTDQA0T5kABRQAEQACAQjTDQA0T5kABRQAAQUAAAAGCAQABRQ=.',['�']='只会惩击:AwAGCA4ABAoAAA==.叶师父:AwAGCBoABAoCEgAGAQgnWAAwMwoBBAoAEgAGAQgnWAAwMwoBBAoAAA==.',['�']='吃口小肥:AwABCAEABAoAAA==.后知后觉的:AwAECAQABRQAAA==.君一:AwABCAEABRQAAA==.',['�']='咆哮的薇薇安:AwAICA8ABAoAAA==.咔滋脆鸡腿堡:AwACCAMABRQAAA==.咕噜咕噜牛:AwAFCAQABAoAAA==.',['�']='唐有虞:AwAFCAQABAoAAA==.唔得翻顺德:AwAGCBMABAoAAA==.',['�']='啊呜喵:AwAGCBoABAoCEwAGAQgyHQAlkeYABAoAEwAGAQgyHQAlkeYABAoAAA==.',['�']='嗜酒乄淡淡:AwAICAgABAoAAA==.嗨土豆:AwABCAEABRQEFAAIAQhDKAAvLHMBBAoAFAAHAQhDKAA0RnMBBAoAAQADAQhfZAAZu44ABAoAFQACAQivHwAR2D8ABAoAAA==.',['�']='嚣张小熊喵:AwAECAgABRQCAQAEAQhyBwBKGQwBBRQAAQAEAQhyBwBKGQwBBRQAAA==.',['�']='国服第一女警:AwADCAMABAoAAA==.',['�']='圣光关我屁事:AwAFCAUABAoAAA==.地域咆哮钢蹦:AwAGCAoABAoAAA==.地板小飞机:AwAGCBgABAoCCwAGAQikRABDXWoBBAoACwAGAQikRABDXWoBBAoAAA==.',['�']='多多良小傘:AwAGCBoABAoCFgAGAQisNAA5wEEBBAoAFgAGAQisNAA5wEEBBAoAAA==.夜空的寂寞:AwAHCA0ABAoAAA==.夜紫:AwAICBIABAoAAA==.夢路步:AwAGCBYABAoDFwAGAQgBEgBgfRUCBAoAFwAGAQgBEgBgfRUCBAoAFgABAQhCdgBLsVEABAoAAA==.大壮牛:AwACCAIABAoAAA==.大天二:AwAICAgABAoAAA==.大耳后知慕斯:AwAECAQABRQAAA==.太阳王小巴哥:AwACCAIABAoAAA==.',['�']='奥利波斯猎:AwAECAgABRQCGAAEAQghDQBDzQYBBRQAGAAEAQghDQBDzQYBBRQAAA==.奶瓶:AwAECAQABAoAAA==.',['�']='妖四四:AwAICBkABAoDGQAIAQhhAABiLBsDBAoAGQAIAQhhAABiLBsDBAoAGAACAQgiogBRFLMABAoAAA==.妖肆肆:AwAECAQABRQDCwAIAQi7DQBbz5oCBAoACwAIAQi7DQBWIpoCBAoAGgAIAQjyBwBUnxYCBAoAAQsAQ3QGCA0ABRQ=.',['�']='姬哥:AwAHCAcABAoAAA==.',['�']='娜宝宝:AwACCAIABAoAAA==.',['�']='孤魂祭长夜:AwAGCBEABAoAAA==.',['�']='寂寞丶小強:AwAICBYABAoDGAAIAQisawAw2jwBBAoAGAAGAQisawA2WDwBBAoAGwADAQiXDwAsBcUABAoAAA==.富贵喀拉峻:AwAGCAYABAoAAA==.寒風亂舞:AwAICAgABAoAAA==.',['�']='小巴哥咯:AwAICAgABAoAAA==.小柚子:AwABCAEABAoAAA==.小浣熊饼干:AwACCAEABAoAAA==.小胸器:AwAICAgABAoAAA==.尤迪利丹:AwACCAIABAoAAA==.尸主有礼:AwAGCBkABAoDGAAGAQgXfgAkPAgBBAoAGAAGAQgXfgAkPAgBBAoAGQADAQhkZAAWgUsABAoAAA==.',['�']='山德鲁:AwAGCAYABAoAAA==.',['�']='布洛芬的悲伤:AwAGCBEABAoAAA==.帅到被人狂抡:AwAFCAUABAoAAA==.帝血乄弑天:AwACCAIABAoAAA==.',['�']='张锦小笨蛋:AwAECAQABRQAAA==.',['�']='性感小姨妈:AwAECAQABAoAAA==.怼死你:AwABCAEABAoAAA==.',['�']='我想想办法:AwABCAIABRQDDAAHAQhHLwBDV88BBAoADAAHAQhHLwBDV88BBAoADQACAQgNRQA2hHoABAoAAA==.战十年:AwAECAYABRQCDQAEAQhlBQAuOMkABRQADQAEAQhlBQAuOMkABRQAAA==.',['�']='承遥:AwACCAIABRQAAA==.',['�']='拉粑粑小摸仙:AwAGCAcABAoAAA==.拉面大师:AwABCAEABAoAAA==.',['�']='探手花丛间:AwAGCA0ABAoAAA==.',['�']='搞哥:AwAFCAUABAoAAA==.',['�']='撸死人不偿命:AwAHCAgABAoAAA==.',['�']='放个治疗链:AwAICAsABAoAAA==.',['�']='断禁舞步:AwAHCAsABAoAAQwAPNQHCBQABAo=.',['�']='时机已到:AwAICAYABAoAAA==.',['�']='晓星:AwAICAgABAoAAA==.',['�']='暴躁可乐:AwACCAMABRQAAA==.',['�']='月雅儿:AwAECAYABRQCFgAEAQj7CAAyCtMABRQAFgAEAQj7CAAyCtMABRQAARwAMzEICAQABRQ=.月音瞳:AwAHCAcABAoAAA==.朝廷心腹大患:AwABCAIABRQDGQAHAQiPEABWzyICBAoAGQAHAQiPEABT7CICBAoAGAAGAQjlUgBN84wBBAoAAA==.末曰审判丶:AwAGCAYABAoAAA==.',['�']='梨落浅殇:AwAECAQABRQAAA==.',['�']='橙色八月:AwABCAEABRQAAA==.',['�']='正义阿婆杀手:AwAGCAYABAoAAA==.歪嘞歪嘞:AwACCAIABAoAAA==.',['�']='毁灭死灵:AwAECAQABRQAAA==.毕方之炎:AwAHCA0ABAoAAA==.',['�']='污垢女王的胸:AwAECAkABRQCCwAEAQhKCQBHT/sABRQACwAEAQhKCQBHT/sABRQAAA==.',['�']='没事吃芒果:AwAICAoABAoAAA==.没落的小牛:AwAGCA8ABAoAAA==.沫柠:AwAICAgABAoAAA==.',['�']='深寒魇魔:AwAECAIABRQAAA==.混口丨饭吃丶:AwAFCAkABAoAAA==.',['�']='清桐晖:AwAICBoABAoCBgAIAQiLEABbTsUCBAoABgAIAQiLEABbTsUCBAoAAA==.温皇丶任飘渺:AwADCAgABRQDCAADAQhZCAApm80ABRQACAADAQhZCAApm80ABRQACQABAQiaKAAeCEUABRQAAA==.',['�']='湛蓝灬书恒:AwAECAQABAoAAA==.湛蓝犄角:AwAICA4ABAoAAA==.',['�']='溜溜球:AwACCAMABRQAAA==.',['�']='满地都是烟火:AwAGCAYABAoAAA==.',['�']='演起来:AwACCAIABAoAAA==.',['�']='潶色天空:AwABCAEABRQAAA==.',['�']='火靈児丶:AwAICA8ABAoAAA==.',['�']='爆了丶香蕉:AwAECA8ABRQDAgAEAQjBBABHO/wABRQAAgADAQjBBABCDvwABRQAAwACAQhyBwBfr3AABRQAAA==.爱插才会赢:AwACCAIABAoAAA==.',['�']='狂風向前:AwAECAQABAoAAA==.狩云霄:AwADCAgABRQCGAADAQgvEAA2ZfkABRQAGAADAQgvEAA2ZfkABRQAAA==.独步圣光:AwAICAYABAoAAA==.',['�']='猎麻人:AwACCAMABRQAAA==.',['�']='玖月沉沦:AwAICBsABAoEFgAIAQhJFwBKwPMBBAoAFgAHAQhJFwBLU/MBBAoAFwAEAQjYTgA2TbAABAoAHAACAQgUTABFApMABAoAAA==.',['�']='瑞奇:AwACCAgABRQCEgACAQjsEgBQLrgABRQAEgACAQjsEgBQLrgABRQAAA==.瑞莲皇后:AwAGCAYABAoAAA==.',['�']='甜妹也是咸的:AwAECAQABAoAAA==.',['�']='神志不清:AwAGCBoABAoDHQAGAQjtKgAqhhkBBAoAHQAGAQjtKgAqhhkBBAoACgABAQjFKAAOYh8ABAoAAA==.神珏:AwAICAgABAoAAA==.神龍大侠:AwACCAIABRQAAA==.',['�']='福兰丶长沙宁:AwAICAgABAoAAA==.',['�']='笑问客何处来:AwAECAQABRQAAA==.',['�']='粗心大意司机:AwAFCAwABAoAAA==.',['�']='糊里糊涂:AwAICAgABAoAAA==.糖油果子之怒:AwAECAgABAoAAA==.糖色:AwAGCAYABAoAAA==.',['�']='红牌妹:AwAGCA0ABAoAAA==.纯屬虚构:AwAGCAUABAoAAA==.',['�']='结城梨斗:AwAICBsABAoDHgAIAQh0CgBE3j8CBAoAHgAIAQh0CgBE3j8CBAoAHwADAQiIJwA7tuIABAoAAA==.',['�']='羊刀加冰眼:AwAECAUABAoAAA==.',['�']='翔龍伏虎:AwAICAgABAoAAA==.',['�']='胖吨:AwAGCAYABAoAAA==.',['�']='臭屁大王:AwAICBwABAoCCwAIAQiLCwBX3KwCBAoACwAIAQiLCwBX3KwCBAoAAA==.至尊圣牛士:AwAGCAsABAoAAA==.',['�']='若邪:AwAICAgABAoAAA==.',['�']='茜茜小可爱:AwAECAQABRQAAA==.',['�']='荼蘼:AwADCAMABAoAAA==.',['�']='莱欧斯利:AwAFCAIABRQAAA==.',['�']='菜鸡阿婆杀手:AwABCAEABRQAAA==.',['�']='萤扰:AwADCAoABRQCCAADAQhnCAAslMwABRQACAADAQhnCAAslMwABRQAAA==.落叶灬舞:AwAGCAkABRQDHwAGAQjSAAAsXLQBBRQAHwAFAQjSAAAoIbQBBRQAHgAEAQg7BgA1RfYABRQAAA==.落叶红秋丶:AwAHCAgABAoAAA==.',['�']='葬爱灬殺少:AwAHCAcABAoAAA==.葬送的芙莉莲:AwAICAgABAoAAA==.',['�']='蓝印雨:AwAICAgABAoAAA==.蓝梅尔:AwADCAgABRQDHwADAQgtCQBOvsEABRQAHwACAQgtCQBPG8EABRQAHgACAQiXCQA7+q8ABRQAAA==.',['�']='调皮的一个人:AwAGCAYABAoAAA==.',['�']='赤手破空拳:AwAICAgABAoAAA==.赤水断苍山:AwAGCAQABRQAAA==.赵旺:AwABCAEABAoAAA==.',['�']='超强力嘲讽脸:AwABCAEABAoAAA==.趾高气杨:AwAECAQABRQAAA==.',['�']='轻盈小胖子:AwAECAQABRQAAA==.',['�']='进击的皮卡丘:AwAECAQABRQDDwAIAQgpDgBR1CwCBAoADwAHAQgpDgBTPCwCBAoADgABAQjKeABJYVQABAoAAA==.',['�']='都零:AwACCAIABAoAAA==.',['�']='释放灵魂:AwAICAsABAoAAA==.',['�']='長腿李敏鎬:AwABCAEABRQAAA==.',['�']='阿尔肥諾:AwAICBEABAoAAA==.阿尔肥诺:AwAGCAcABAoAAA==.阿鲁蒂霸王:AwABCAEABAoAAA==.',['�']='雨狂醉:AwAECAEABAoAAA==.雷霆黑牛:AwAICAoABAoAAA==.',['�']='霜之矮伤:AwAECAMABRQAAA==.',['�']='靈灵:AwAICAoABAoAAA==.靑头仔:AwACCAIABRQAAA==.青眼之亚白:AwAHCA0ABAoAAA==.',['�']='预见:AwAICAgABAoAAA==.',['�']='风吹哀傷:AwAFCAUABAoAAA==.飘柔大领主:AwAECAQABAoAAA==.飞奔的大骑士:AwAECAYABRQCBgAEAQiSAwBfr0UBBRQABgAEAQiSAwBfr0UBBRQAAA==.飞奔的大鹌鹑:AwAECAQABRQAAA==.',['�']='马齿苋:AwAGCAYABAoAAA==.',['�']='高松灯:AwAHCBIABAoAAA==.',['�']='鱼爷:AwAECAgABRQCDgAEAQjyCQA92gYBBRQADgAEAQjyCQA92gYBBRQAAA==.',['�']='黑檀之寒:AwAICAgABAoAAA==.',['�']='龍飛鳳舞:AwAICA4ABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end