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
 local lookup = {'Paladin-Retribution','Evoker-Devastation','Shaman-Enhancement','Shaman-Elemental','Priest-Shadow','DemonHunter-Vengeance','DemonHunter-Havoc','Druid-Restoration','Paladin-Holy','Paladin-Protection','Druid-Balance','Warlock-Destruction','Mage-Frost','Mage-Fire','Unknown-Unknown','Priest-Discipline','Monk-Mistweaver','Hunter-BeastMastery','DeathKnight-Unholy','Rogue-Assassination','Warrior-Protection','Warrior-Fury','DeathKnight-Frost','DeathKnight-Blood',}; local provider = {region='CN',realm='凯恩血蹄',name='CN',type='weekly',zone=42,date='2025-04-14',data={Aa='Aayden:AwAECAQABRQAAA==.',Ch='Christao:AwAGCAYABAoAAA==.',Fi='Fireblade:AwAECAwABRQCAQAEAQiZCgBXkBUBBRQAAQAEAQiZCgBXkBUBBRQAAA==.',Fl='Flanbranford:AwACCAMABRQAAA==.Fliedmiles:AwABCAMABRQCAgAIAQjWEwA8/fsBBAoAAgAIAQjWEwA8/fsBBAoAAA==.',He='Hela:AwAICAgABAoAAA==.',Mi='Minke:AwABCAEABRQAAA==.',No='Nomainstream:AwAFCAUABAoAAA==.',Ra='Rach:AwAICAgABAoAAA==.',Sa='Saoxingxing:AwADCAgABRQDAwADAQhqCABAFPIABRQAAwADAQhqCAA1rvIABRQABAACAQhCCgBB5LUABRQAAA==.',Th='Thermos:AwACCAIABRQAAA==.',Wt='Wtfly:AwABCAEABAoAAA==.',['�']='一脚爆蛋:AwADCAEABRQAAA==.一饼:AwADCAMABAoAAA==.与众不瞳:AwADCAMABAoAAA==.丨梦灬初醒丨:AwAECAkABRQCBQADAQglDgAf5s8ABRQABQADAQglDgAf5s8ABRQAAA==.丨灬天下:AwAECAQABRQAAA==.丨芃然欣动丨:AwACCAMABAoAAA==.为你而来:AwAICBYABAoDBgAIAQhDKgAl3v0ABAoABgAHAQhDKgAgVf0ABAoABwAGAQj9XwAdk/YABAoAAA==.',['�']='了布德:AwADCAgABRQCCAADAQj2EAAdHXsABRQACAADAQj2EAAdHXsABRQAAA==.云隐雷霆:AwAECAQABAoAAA==.五皮皮:AwAFCAUABAoAAQUAH+YECAkABRQ=.亦云:AwADCAMABAoAAA==.',['�']='俊克总总:AwADCAIABRQAAA==.',['�']='光影丶:AwAHCAcABAoAAA==.光明大师:AwAHCAkABAoAAA==.',['�']='冰冰有火:AwACCAQABRQECQAIAQjACgBI/B0CBAoACQAHAQjACgBROR0CBAoAAQAFAQh+vQBCPu8ABAoACgABAQjRXwAHKwcABAoAAA==.',['�']='凛风剑影:AwAICBAABAoAAA==.凡尔赛玫瑰:AwABCAEABRQAAA==.',['�']='初南:AwAGCAYABAoAAA==.',['�']='动感迷踪拳:AwAFCAgABAoAAA==.',['�']='卅卅:AwAFCAoABAoAAA==.',['�']='原野的呼唤:AwACCAMABRQCCwAIAQhFIgA+fBkCBAoACwAIAQhFIgA+fBkCBAoAAA==.',['�']='可可喝可乐:AwAECAQABRQAAA==.可达鸭鸭:AwAGCAsABAoAAA==.',['�']='吼米:AwAGCAwABAoAAA==.',['�']='哦豁:AwAGCAYABAoAAA==.',['�']='夏天飞雪:AwAECAQABRQAAA==.夜千璃:AwAICAYABAoAAA==.天堂的蓝调:AwABCAIABRQCDAAIAQhmHwA2OvIBBAoADAAIAQhmHwA2OvIBBAoAAA==.天青涩等艳遇:AwADCAMABAoAAA==.天黑心乱:AwABCAEABRQDBwAHAQgoGgBXwEsCBAoABwAHAQgoGgBXwEsCBAoABgABAQjKaQAAAAAABAoAAA==.天黑心慌慌:AwAHCAsABAoAAA==.',['�']='妙蛙种子:AwAECAQABRQAAA==.',['�']='宇智波卡卡西:AwAECAQABRQAAA==.安洁妮:AwACCAIABAoAAA==.',['�']='小哥来也:AwACCAMABRQAAA==.小紅手:AwAGCAYABAoAAA==.少女解剖室:AwAICBAABAoAAA==.就是小哥:AwADCAMABAoAAA==.就问能不能躺:AwAGCBIABAoAAA==.',['�']='布鲁小夫:AwAGCAYABAoAAA==.',['�']='幽灵隐者:AwACCAIABRQDDQAIAQj4IQA58tsBBAoADQAIAQj4IQA58tsBBAoADgABAQjLmAAMViIABAoAAA==.',['�']='弥离:AwAICBUABAoCDAAIAQhdJgBA4soBBAoADAAIAQhdJgBA4soBBAoAAQ8AAAAGCAQABRQ=.',['�']='影曦:AwAECAQABAoAAA==.',['�']='心灵潜行:AwABCAEABRQAAA==.',['�']='怒怒的蛋蛋:AwAICBoABAoCBgAIAQgUIQAnyUABBAoABgAIAQgUIQAnyUABBAoAAA==.怪盗安度因丶:AwAGCAQABRQCEAAEAQipBABRDR4BBRQAEAAEAQipBABRDR4BBRQAAA==.',['�']='懦夫救星丶:AwAGCAYABAoAAA==.',['�']='我是奶龙:AwAECAQABRQAAA==.我是牛吗:AwAGCAIABAoAAA==.我觉得很行:AwAICAYABAoAAA==.我觉得还行:AwAECAQABRQAAA==.',['�']='捌级大狂风:AwACCAUABRQCAQACAQi/JwBFTpkABRQAAQACAQi/JwBFTpkABRQAAA==.',['�']='是美雅哦:AwAECAgABRQCDAAEAQhbAgBhDVABBRQADAAEAQhbAgBhDVABBRQAAA==.是美雅啊:AwAECAQABRQAAQ8AAAAGCAQABRQ=.',['�']='晴天漠漠:AwACCAIABAoAAA==.',['�']='暮雨丶轻风:AwABCAEABAoAAA==.',['�']='松烟竹雾:AwAGCAYABAoAAA==.',['�']='枫叶烙痕:AwAHCA0ABAoAAA==.枫叶红了:AwAGCA4ABAoAAA==.',['�']='橘子丶:AwAECAQABRQCEQAEAQg4EAAXb80ABRQAEQAEAQg4EAAXb80ABRQAAA==.',['�']='水樱宮葵:AwAECAEABRQAAQIAD08ICAUABRQ=.',['�']='波风皆人:AwAECAQABRQAAA==.泥艾希我奶妈:AwACCAIABAoAAA==.泰一迪:AwADCAgABRQCEgADAQhCFAAzN+kABRQAEgADAQhCFAAzN+kABRQAAA==.泰二迪:AwAHCAkABAoAAA==.泰蕾莎:AwAHCAUABAoAAA==.',['�']='流风若雪:AwAICAYABAoAAA==.',['�']='淼淼脆皮肠:AwACCAIABRQCDAAIAQjyAQBehvYCBAoADAAIAQjyAQBehvYCBAoAAA==.',['�']='火影摇摆龙王:AwACCAQABRQAAA==.',['�']='炮灰向前冲:AwAICCUABAoCEwAIAQg8HwBGOR0CBAoAEwAIAQg8HwBGOR0CBAoAAA==.',['�']='牛战:AwADCAMABAoAAA==.牛牛增幅器:AwAICAgABAoAAA==.',['�']='狂暴宥宥:AwADCAMABAoAAA==.',['�']='玛莎喇蒂:AwADCAYABAoAAA==.',['�']='疾跑哥布林:AwAFCAwABAoAAA==.',['�']='真电游王:AwADCAYABAoAAA==.',['�']='矩阵:AwABCAEABAoAAA==.',['�']='破碎小柠:AwABCAEABAoAAA==.',['�']='秋天卫士:AwACCAQABRQAAA==.',['�']='笨蛋猫猫头:AwAICAgABAoAAQ8AAAAGCAIABRQ=.',['�']='米拉波雷亚斯:AwAECAQABRQAAA==.',['�']='红烧蹄子:AwABCAEABRQAAA==.纯爱扭头人:AwAICAgABAoAAA==.',['�']='终相忘:AwAGCAYABAoAAA==.',['�']='老一点的卜:AwAGCAIABRQAAA==.老卜:AwAGCAIABRQAAA==.',['�']='聖光將熄:AwACCAIABAoAAA==.',['�']='自来火:AwACCAMABRQAAA==.',['�']='艾拉蓓徳:AwAICAUABAoAAA==.',['�']='草莓丶圣代:AwADCAMABRQAARQAYaMFCAkABRQ=.',['�']='菊川青钩子:AwAICAIABAoAAA==.菊花真汉子:AwAECAsABRQCCwAEAQjWBABWYCoBBRQACwAEAQjWBABWYCoBBRQAAA==.',['�']='萨厼:AwAGCAQABAoAAQ8AAAAECAQABRQ=.萨髵:AwAGCAIABAoAAA==.',['�']='虎虎牌小饼干:AwADCAUABRQCFQADAQivBAAWEKUABRQAFQADAQivBAAWEKUABRQAAA==.',['�']='蜡筆小旧:AwABCAEABRQAAA==.',['�']='超级大洋芋:AwACCAIABRQCFgAIAQiuIQAzuPMBBAoAFgAIAQiuIQAzuPMBBAoAAA==.',['�']='路卡利欧:AwAFCBsABRQDEwAFAQi3AABi5s0BBRQAEwAFAQi3AABi5s0BBRQAFwABAQicCAAAAAAABRQAAA==.',['�']='错季花開:AwAICAgABAoAAA==.',['�']='阿兰蒂恩:AwAECAUABAoAAA==.阿勀里斯:AwAECAQABAoAAA==.',['�']='陆路通:AwABCAEABRQAAA==.限量版私房钱:AwADCAMABAoAAA==.',['�']='雅少:AwABCAEABAoAAA==.雨慢落:AwABCAEABRQAAA==.',['�']='青铜脆皮姬:AwAGCAYABAoAAA==.靓盗云云:AwADCAUABAoAAA==.',['�']='风暴丨烈酒:AwAGCAkABAoAAA==.飞羽无痕:AwAECAQABAoAAA==.飞舞的刀刃:AwADCAMABAoAAA==.',['�']='骑同伟:AwAGCAEABAoAAA==.',['�']='魔力熊猫:AwAECAQABRQAAA==.',['�']='鲜血玛丽:AwACCAMABRQDFwAIAQilCABC/wECBAoAFwAHAQilCABLjgECBAoAGAABAQg3XQAPoCEABAoAAA==.',['�']='鸟人的未来:AwADCAMABAoAAA==.鸡公加蛋:AwAGCA0ABAoAAQ8AAAAECAQABRQ=.',['�']='麦希子龙:AwAFCAYABAoAAA==.',['�']='黄桃蛋挞:AwACCAIABRQAAA==.默旭魂丶雨:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end