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
 local lookup = {'Paladin-Holy','Mage-Fire','Mage-Frost','Unknown-Unknown','Monk-Brewmaster','Monk-Windwalker','Druid-Balance','Druid-Guardian','DemonHunter-Havoc','Warrior-Arms','Hunter-BeastMastery','Priest-Holy','Priest-Shadow','Hunter-Marksmanship','Warrior-Fury','Warlock-Destruction','Paladin-Retribution','Paladin-Protection','DemonHunter-Vengeance','Shaman-Elemental','Shaman-Restoration','DeathKnight-Unholy','Druid-Restoration','Warlock-Affliction',}; local provider = {region='CN',realm='德拉诺',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Alita:AwAICCIABAoCAQAIAQh7CwBCeRICBAoAAQAIAQh7CwBCeRICBAoAAA==.',Ar='Artemis:AwAHCAYABAoAAA==.',As='Astraia:AwABCAEABAoAAA==.',Ch='Chaeles:AwAECAQABAoAAA==.',Da='Darknessun:AwAFCAYABAoAAA==.',De='Desirer:AwAECAQABRQAAA==.',Go='Goffy:AwACCAQABRQAAA==.Gogo:AwAICB4ABAoDAgAIAQjnJQBBegICBAoAAgAIAQjnJQBBMQICBAoAAwAHAQhvPQAtpEMBBAoAAA==.',Mi='Miria:AwAGCA8ABAoAAA==.',Mo='Moonvirgo:AwAGCAsABAoAAA==.',Mu='Murderous:AwAHCAsABAoAAA==.',Ni='Niubi:AwAECAQABRQAAQQAAAAICAEABRQ=.',St='Stinkypig:AwAFCAUABAoAAA==.',Yy='Yyll:AwABCAEABRQAAA==.Yyxx:AwAICAUABAoAAA==.',['�']='不要死小强:AwAECAcABAoAAA==.丨雷三炮丨:AwABCAEABAoAAA==.丶释迦:AwABCAEABRQAAA==.丶青青子衿丶:AwADCAMABAoAAA==.为你熬翔:AwAICAMABAoAAA==.',['�']='久久炎:AwACCAIABAoAAA==.九五:AwAECAQABRQAAA==.',['�']='云中谁忆:AwACCAIABRQAAA==.',['�']='仓井满:AwAGCAwABAoAAA==.',['�']='传承:AwAECAQABRQAAA==.',['�']='你没钱:AwABCAEABAoAAA==.你的小龙女:AwACCAIABAoAAA==.佩佩的小刀:AwAECAQABRQAAA==.',['�']='侠骨丹心:AwAFCAUABAoAAA==.',['�']='偶豆豆喲:AwABCAEABAoAAA==.',['�']='傍晚:AwAFCAoABAoAAA==.',['�']='僧龍大俠:AwAICBsABAoDBQAIAQi6DQAkTjwBBAoABQAIAQi6DQAkTjwBBAoABgABAQiUaAAaCjcABAoAAA==.',['�']='先定个小目标:AwACCAIABRQAAA==.养乐多:AwABCAEABRQAAA==.',['�']='冰凉丶:AwAHCAEABAoAAA==.冰粒十足:AwACCAIABRQAAA==.',['�']='凝香筱筱:AwAECAIABRQAAA==.',['�']='别碰我的豆奶:AwACCAMABRQAAQQAAAAICAEABRQ=.',['�']='北辰明:AwAECAQABRQAAA==.',['�']='单名一个源:AwAECAQABAoAAA==.',['�']='咆哮的鹌鹑:AwABCAIABRQDBwAIAQjuHQBIVTQCBAoABwAIAQjuHQBIVTQCBAoACAABAQjVKwAcFx0ABAoAAQcAQiQGCAoABRQ=.',['�']='唐丶吉坷德:AwACCAQABRQAAA==.',['�']='噼里啪啦:AwAECAQABRQAAA==.',['�']='四夕若若:AwAECAQABRQAAA==.',['�']='圣光赐我男高:AwAECAQABRQAAA==.',['�']='埃辛诺斯戰刃:AwAICBgABAoCCQAIAQjzGwBOAj4CBAoACQAIAQjzGwBOAj4CBAoAAA==.',['�']='墨殇:AwAICAEABAoAAA==.',['�']='夏沐:AwAECAQABRQAAA==.夜月杀:AwADCAUABAoAAA==.大冰:AwABCAEABRQAAA==.大猛战丶:AwAFCAYABAoAAA==.大鱼破雾:AwAGCAkABAoAAA==.天国狼声:AwABCAEABAoAAA==.',['�']='媇你小手:AwAECAQABRQAAA==.',['�']='嫣然晨光:AwAECAQABAoAAA==.嫣然暮光:AwAICAgABAoAAA==.',['�']='宅字当头:AwAFCAsABAoAAA==.',['�']='小小崽:AwAHCAgABAoAAA==.小屁:AwABCAEABRQAAQoAWOkCCAMABRQ=.小德不晓得:AwADCAgABAoAAA==.小牛剑侠:AwAECAQABRQAAA==.小飞机小火车:AwAICBAABAoAAQsAShkGCA4ABRQ=.',['�']='屠戮东少:AwAICAgABAoAAA==.山里的嗦了扎:AwAFCAcABAoAAA==.山里的圆圆:AwACCAIABRQAAA==.山里的尛红人:AwABCAEABRQAAA==.山里的老登:AwACCAIABAoAAA==.',['�']='岸边的狮子:AwADCAEABAoAAA==.',['�']='希尔梅里亚:AwAGCAoABAoAAA==.帝獄孤狼:AwADCAMABAoAAA==.',['�']='库帕城堡:AwAECAQABRQAAA==.',['�']='彦祖:AwAICAkABAoAAA==.',['�']='得鹿梦鱼:AwAECAQABRQCDAAIAQhkCgBQmmoCBAoADAAIAQhkCgBQmmoCBAoAAQ0AO50GCA4ABRQ=.',['�']='恶魔丶杀戮者:AwAICAsABAoAAA==.',['�']='懒得开门:AwAICAgABAoAAA==.',['�']='我有钱:AwAECAQABAoAAA==.我直接射爆:AwAECAMABAoAAA==.',['�']='执手相看泪眼:AwABCAEABAoAAA==.',['�']='捷拉奥拉:AwAECAQABRQAAA==.',['�']='排骨炖萝卜:AwABCAEABRQAAA==.',['�']='放肆丨为红颜:AwAFCAsABRQDDgAFAQizAQAyPi4BBRQADgAFAQizAQAp+C4BBRQACwADAQiKFAAtbegABRQAAA==.',['�']='教育网专区:AwACCAMABRQDCgAIAQiABABY6bICBAoACgAIAQiABABYV7ICBAoADwAIAQgBDgBN1oMCBAoAAA==.',['�']='文艺朮士:AwAECAQABAoAARAAR8AGCBQABRQ=.',['�']='无孪:AwACCAIABRQAAA==.无敌汤圆哥哥:AwAECAQABRQAAA==.早饭吃的啥丶:AwACCAIABRQAAA==.',['�']='暖丶阳:AwADCAIABAoAAA==.',['�']='最爱小粉:AwACCAIABRQAAA==.最瞹之媛:AwABCAEABRQAAA==.月随枫飞:AwAICAgABAoAAA==.有四个棍子:AwABCAEABAoAAA==.',['�']='柒月:AwACCAIABRQAAA==.',['�']='树形闪电:AwAGCAYABAoAAA==.格斗王灵:AwADCAQABAoAAA==.',['�']='梅絍緈:AwAICAYABAoAAA==.',['�']='椰子超甜:AwAICAgABAoAAA==.',['�']='樱辰花落:AwAICAgABAoAAA==.',['�']='欲望战魔:AwAECAQABRQAAA==.',['�']='此刻应有烟火:AwAGCAQABRQAAA==.',['�']='每天酸菜鱼:AwABCAEABAoAAA==.',['�']='永恒太阿星:AwAICCEABAoDEQAIAQheDgBbzNACBAoAEQAIAQheDgBbzNACBAoAEgABAQjJYQAAAAAABAoAAA==.永远的豆子哥:AwAICA8ABAoAAA==.',['�']='法力虚空:AwADCAgABRQCEwADAQjRAABd3UkBBRQAEwADAQjRAABd3UkBBRQAAA==.泡泡二不小心:AwAGCAgABAoAAA==.',['�']='洫傷:AwAFCBQABAoCDAAFAQirVQAiUrYABAoADAAFAQirVQAiUrYABAoAAA==.',['�']='淡淡的稻香:AwACCAMABAoAAA==.深度冻结丶:AwACCAIABRQAAA==.',['�']='清羽潇潇:AwACCAIABRQAAA==.清风月影:AwAICAgABAoAAA==.渺怒:AwAICAYABRQDAgAEAQhqCABUBiYBBRQAAgAEAQhqCABUBiYBBRQAAwABAQiQGAA1bDoABRQAAA==.',['�']='湖人总冠军吖:AwACCAIABAoAAA==.',['�']='火灾:AwAHCAkABAoAAA==.灬尛酒窩灬:AwAGCAQABRQAAA==.',['�']='熊撞树上了:AwAICBAABAoAAA==.',['�']='爱忘东西的我:AwAICAMABAoAAA==.',['�']='狂暴不怕困难:AwAGCAYABAoAAA==.狂踹蒯蛮蛮:AwAICBAABAoAAA==.狐狐大冲撞:AwACCAIABRQAAA==.',['�']='猫胖胖:AwACCAIABRQAAA==.',['�']='王蜀黍:AwAICCIABAoDFAAIAQjpFABB4x0CBAoAFAAIAQjpFABB4x0CBAoAFQADAQgmjgA3MHAABAoAAA==.玖五:AwAGCAYABAoAAA==.',['�']='白熊:AwACCAMABRQCFgAIAQioPQAqcoYBBAoAFgAIAQioPQAqcoYBBAoAAA==.',['�']='看着青春走开:AwAFCAMABAoAAA==.',['�']='磨牙磨牙:AwAFCAUABRQCDAAEAQhLCgAYv8YABRQADAAEAQhLCgAYv8YABRQAAA==.',['�']='祈祷:AwAGCAsABAoAAA==.神之笑:AwAICAkABAoAAA==.神祈:AwABCAEABAoAAA==.祭汐:AwAGCAYABAoAAA==.',['�']='移情丶别恋:AwAECAQABRQAAA==.',['�']='紫色韵味:AwAICBAABAoAAA==.',['�']='绯色月下:AwABCAEABAoAAA==.',['�']='罪爱之爰:AwADCAMABAoAAA==.',['�']='职业萨满:AwAGCAYABAoAAA==.',['�']='艾薇:AwACCAMABRQAAA==.',['�']='苹果熊:AwADCAMABAoAAA==.',['�']='萨萨罗:AwAICBMABAoAAA==.落日几倦:AwAECAgABRQCEgAEAQg+BABIfP8ABRQAEgAEAQg+BABIfP8ABRQAAA==.',['�']='让我绿了你:AwAECAQABAoAAA==.',['�']='谁特麼买小米:AwAECBAABRQDDgAEAQhcBABPqAcBBRQADgAEAQhcBABI4AcBBRQACwAEAQhEEQA9fvQABRQAAA==.',['�']='贫僧法号三葬:AwAFCAUABAoAAA==.',['�']='赤脊山的猪:AwAECAQABAoAAA==.',['�']='辛普雷:AwACCAIABAoAAA==.',['�']='运运:AwAECAcABRQDBwAEAQhlDwA9+ugABRQABwAEAQhlDwA9+ugABRQAFwABAQh+GgAYZjsABRQAAA==.还我爬爬:AwAHCAYABAoAAA==.追寻:AwAICAkABAoAAA==.',['�']='郑氵华仔:AwABCAEABRQAAA==.',['�']='鄙人不善言辞:AwAFCAUABAoAAA==.',['�']='阮中蕐:AwACCAIABRQDEAAIAQitHQBDF/0BBAoAEAAIAQitHQBDF/0BBAoAGAABAQhrPAAs/TcABAoAAA==.阿巴阿巴:AwAICAYABAoAAA==.',['�']='雾殇:AwADCAQABRQDEQAIAQirMABOVD8CBAoAEQAIAQirMABOVD8CBAoAEgAIAQghJgAWpPQABAoAAA==.',['�']='青城山莽撞人:AwABCAEABAoAAA==.青空断翼:AwAICBkABAoCBwAIAQgWIABDfCcCBAoABwAIAQgWIABDfCcCBAoAAA==.',['�']='風灬崭:AwADCAQABAoAAA==.',['�']='飞云:AwACCAIABAoAAA==.',['�']='魔牙魔牙:AwAGCAYABAoAAA==.',['�']='鴩丶灰烬使者:AwACCAIABAoAAA==.',['�']='黎玥儿:AwAFCAUABAoAAA==.黑傻馒:AwAFCAkABAoAAA==.黑喵大侠:AwABCAEABAoAAA==.',['�']='齉齾爩灪纞虋:AwACCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end