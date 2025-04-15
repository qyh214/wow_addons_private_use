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
 local lookup = {'Warrior-Fury','DemonHunter-Vengeance','DemonHunter-Havoc','Monk-Windwalker','Evoker-Devastation','Evoker-Preservation','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','Mage-Frost','Mage-Fire','Warlock-Destruction','Warlock-Demonology','DeathKnight-Blood','DeathKnight-Unholy','DeathKnight-Frost','Unknown-Unknown','Monk-Mistweaver','Paladin-Retribution','Paladin-Holy','Shaman-Elemental','Shaman-Restoration','Druid-Restoration','Priest-Holy','Warrior-Protection','Paladin-Protection','Warlock-Affliction','Warrior-Arms','Shaman-Enhancement','Rogue-Assassination','Druid-Balance',}; local provider = {region='CN',realm='奥蕾莉亚',name='CN',type='weekly',zone=42,date='2025-04-14',data={Am='Amastacia:AwAHCA0ABAoAAA==.',Ar='Arniwarrior:AwAHCBcABAoCAQAHAQgNOAAnOnEBBAoAAQAHAQgNOAAnOnEBBAoAAA==.',Bl='Blue:AwAECAQABRQAAA==.',Bo='Botak:AwABCAEABAoAAA==.',Ca='Caocaolei:AwAECAgABRQDAgAEAQg+BwAmC7IABRQAAgAEAQg+BwAl6LIABRQAAwACAQhRIAArDIgABRQAAQQAWZcGCBkABRQ=.',Ch='Charizard:AwAGCAoABRQDBQAGAQiEAABMX/QBBRQABQAGAQiEAABMX/QBBRQABgADAQgVBQA1CogABRQAAA==.',Ck='Ckw:AwAICB0ABAoEBwAIAQh1LQBDHB0CBAoABwAIAQh1LQBDHB0CBAoACAABAQhaGwA48S0ABAoACQABAQiicQAjpSkABAoAAA==.',De='Demonhunter:AwAFCAUABAoAAA==.',Do='Doppelmond:AwAECAUABAoAAA==.',Dr='Drarry:AwAECAQABRQAAA==.',Fi='Fission:AwAGCAYABAoAAA==.',Gu='Guihui:AwAECAcABRQDCgAEAQjZAwBOIAcBBRQACgADAQjZAwBOIAcBBRQACwAEAQhbGgAdS9EABRQAAA==.',Li='Linabell:AwABCAEABAoAAA==.',Lu='Lucifercandy:AwAHCBgABAoDDAAHAQhVLgBBSqEBBAoADAAHAQhVLgA9A6EBBAoADQAEAQhxLQBIb+sABAoAAA==.',Ma='Marksmanship:AwAFCAgABAoAAA==.',Om='Omen:AwAGCAoABRQDBgAGAQheAAAyc1MBBRQABgAFAQheAAA1hlMBBRQABQAFAQg2BAApNycBBRQAAA==.',Pe='Pekora:AwAECAIABRQAAA==.',Sd='Sdadczx:AwAICBwABAoEDgAIAQgLEABCsgwCBAoADgAIAQgLEABCAAwCBAoADwAGAQgaTAA6REwBBAoAEAACAQjTLwAQ4ikABAoAAA==.',Sk='Skyarrow:AwAGCAsABAoAAA==.Skypumpkin:AwAFCAUABAoAAA==.Skyriver:AwAFCAUABAoAAA==.',So='Souldrainer:AwACCAIABRQAAA==.Soyorin:AwAECAIABRQAAA==.',Tu='Tudou:AwAHCAoABAoAAA==.',Wa='Warriorr:AwAGCAkABAoAAA==.',Za='Zadwarlock:AwAECAUABRQCDAAEAQjABABY8SIBBRQADAAEAQjABABY8SIBBRQAAA==.',['�']='一月十四日:AwABCAEABAoAAA==.一粒小橙子:AwAICAgABAoAAA==.七个魂儿:AwAHCBcABAoDDgAHAQiqKgAjcwoBBAoADgAHAQiqKgAjBQoBBAoADwAGAQgBYgAcpvgABAoAAA==.七婶:AwACCAIABRQAAA==.三餐事大:AwADCAQABAoAAA==.不是椰椰:AwAFCAUABAoAAA==.东谐孙一峰:AwAGCAYABAoAAQ4AV20GCAgABRQ=.丢猫:AwAECAQABRQAAA==.丶桜雨丶:AwAECAQABRQAAQcAN28GCAYABRQ=.丶醉梦:AwAICAgABAoAAREAAAAICAQABRQ=.丶鸢一折纸:AwAICBAABAoAAA==.',['�']='久远四分之一:AwAGCAYABAoAAA==.乙女解剖:AwAECAsABRQCCwAEAQj2EQA/Qu8ABRQACwAEAQj2EQA/Qu8ABRQAAA==.乱九九:AwAHCBgABAoCAgAHAQiHLgAaxuQABAoAAgAHAQiHLgAaxuQABAoAAA==.',['�']='井中寻月:AwABCAEABAoAAA==.',['�']='以前泡泡鱼:AwABCAEABRQAAA==.任飘渺:AwAICAgABAoAAA==.',['�']='伊达雷斯:AwAECAQABAoAAA==.',['�']='侬则小赤佬:AwABCAEABAoAAA==.',['�']='健身达人:AwADCAMABAoAAA==.',['�']='傲慢的妮儿:AwAGCAYABAoAAA==.',['�']='兜兜里有箭:AwACCAIABAoAAA==.全村人的希望:AwAECAoABRQCCQAEAQi5BQBSWPsABRQACQAEAQi5BQBSWPsABRQAAA==.兰斯洛:AwAGCAkABAoAAREAAAAECAQABRQ=.',['�']='冰法:AwAECA4ABRQCBQAEAQglCQA6MeUABRQABQAEAQglCQA6MeUABRQAAA==.冰火茄子:AwAICAgABAoAAA==.',['�']='凤纤:AwAICBAABAoAAA==.',['�']='刀者隐月:AwAGCAwABAoAAA==.',['�']='功夫小狐狸:AwABCAEABRQCEgAHAQiyIwA/PrYBBAoAEgAHAQiyIwA/PrYBBAoAAA==.加藤娜娜:AwAICAsABAoAAA==.',['�']='半世独殇:AwAECAQABRQAAA==.卡塔莉娜:AwABCAEABRQAAA==.',['�']='厚切吐司:AwAHCBgABAoDEwAHAQi5VwBFEcwBBAoAEwAHAQi5VwBFEcwBBAoAFAAGAQhAJAAi7gMBBAoAAA==.',['�']='名易安前:AwABCAEABRQAAA==.吖棵:AwAGCAYABRQDFQAGAQhiBgA4o+oABRQAFQAEAQhiBgBAieoABRQAFgACAQhkEgA6Ib0ABRQAAA==.吹散的风:AwABCAEABRQAAA==.吹石由衣子:AwAGCAUABAoAAA==.',['�']='咕噜蒙多:AwAICAkABAoAAA==.',['�']='嘲哳:AwAECAQABRQAAA==.',['�']='四系垫底德:AwAICAgABAoAAA==.国宝冲锋:AwAICAkABAoAAA==.',['�']='圣光熊喵:AwACCAIABRQAAA==.',['�']='坏猫:AwAGCAIABRQAAA==.',['�']='墙角:AwAFCAEABAoAAA==.',['�']='夜夜僧:AwABCAEABAoAAA==.夜珞然:AwAHCBAABAoAAA==.大领主:AwADCAQABRQAAREAAAAICAQABRQ=.天命人一:AwAICAgABAoAAREAAAAECAQABRQ=.天胤:AwACCAIABRQAAA==.天赐淡雅香:AwAECAQABRQAAA==.',['�']='奥古斯娜:AwAGCAYABAoAAA==.女人影响上芬:AwACCAIABAoAAA==.她真的是慢热:AwAGCAYABAoAAA==.好姐妹佳代子:AwADCAUABRQCBQADAQitCQAyOOAABRQABQADAQitCQAyOOAABRQAAA==.',['�']='妖糖:AwACCAQABAoAAA==.',['�']='婉清:AwAFCAsABAoAAA==.',['�']='媚舞:AwAFCAoABAoAAA==.',['�']='完美回忆:AwAHCAIABAoAAA==.宫门口馒头:AwAHCAEABAoAAA==.',['�']='寒冰魔女:AwACCAIABRQAAA==.',['�']='小奶龙:AwAGCAQABRQDBQAEAQjIDAAjo8IABRQABQACAQjIDABEIcIABRQABgACAQhQBgAhSHMABRQAAA==.小熊软糖:AwACCAIABAoAAA==.小野寺小咲:AwAECAEABAoAAA==.小马宝莉:AwAICAkABAoAAA==.尛神经:AwAGCAYABAoAAA==.就爱菜菜:AwAFCAkABAoAAA==.',['�']='峰一样的男人:AwAHCBgABAoCCgAHAQiWEABcF1sCBAoACgAHAQiWEABcF1sCBAoAAA==.',['�']='崇高的幻像:AwAICAYABAoAAA==.',['�']='希斯特利亚:AwAHCAcABAoAAA==.带頭大哥:AwAHCAcABAoAAA==.',['�']='幻想:AwACCAEABAoAAA==.广智救我:AwAGCAYABAoAAA==.',['�']='弑天影:AwADCAYABRQCFwADAQgEAgBep0gBBRQAFwADAQgEAgBep0gBBRQAAA==.张某某:AwAICAgABAoAAA==.',['�']='影焰盈月:AwACCAMABAoAAREAAAADCAMABAo=.',['�']='心層麻酔:AwACCAIABRQAAQsAP0IECAsABRQ=.心随风去:AwAECAoABAoAAA==.快乐修熊:AwADCAMABRQAAA==.',['�']='怪很强你先上:AwAGCAYABAoAAA==.',['�']='我是技术员:AwAHCBgABAoDBwAHAQhfTABE5KIBBAoABwAHAQhfTABCz6IBBAoACQAFAQj/LwBH3i4BBAoAAA==.',['�']='抢过银行:AwAFCAEABAoAAA==.',['�']='日游神:AwAICAgABAoAAA==.',['�']='星光阿妮雅:AwABCAIABRQAAA==.',['�']='晨练大爷:AwAHCBUABAoCEwAHAQhNXwA/e7gBBAoAEwAHAQhNXwA/e7gBBAoAAA==.',['�']='暮雨惊鸿:AwAICA4ABAoAAA==.暮雨珊珊:AwAGCAQABRQAAA==.',['�']='曹柔理:AwAICAYABAoAAA==.曽经沧海:AwACCAIABAoAAA==.',['�']='月儿乱喷火:AwAICAgABAoAAA==.月盈云过窗:AwAFCAIABAoAAA==.木伊馨:AwAGCAwABAoAAA==.',['�']='李瓶儿:AwAFCAkABAoAAA==.',['�']='林依宁:AwAECAQABRQAAA==.林深见鹿:AwAGCAYABAoAAA==.果然是他:AwACCAIABRQAAA==.',['�']='柒七:AwABCAEABAoAAA==.柠檬很甜:AwAGCAYABRQCDwAGAQgUAQAtoLIBBRQADwAGAQgUAQAtoLIBBRQAAA==.柯南死神:AwAGCBAABAoAAA==.',['�']='树下吃石榴:AwABCAEABAoAAA==.树下吃葡萄:AwAICBYABAoCEwAIAQilHQBTMIoCBAoAEwAIAQilHQBTMIoCBAoAAA==.',['�']='桃花载酒:AwAECAQABRQAAA==.',['�']='次元战神:AwAECAgABAoAAA==.欢乐上头送:AwAECAQABAoAAA==.',['�']='死亡棋士:AwAFCAsABAoAAA==.',['�']='残卷诉倾城:AwAECAoABRQCGAAEAQiLBwAxF98ABRQAGAAEAQiLBwAxF98ABRQAAA==.',['�']='洛迦山水:AwAFCAUABAoAAA==.活动人偶:AwAECAYABRQCDgAEAQgMBgBMXwMBBRQADgAEAQgMBgBMXwMBBRQAAA==.',['�']='济癫:AwABCAEABRQAAA==.浪人情歌:AwAECAQABRQAAA==.',['�']='清浅:AwAFCAUABAoAAA==.清风拂月留痕:AwAICAsABAoAAA==.温妤宝贝:AwAICAgABAoAAA==.',['�']='源流怀古:AwAECAQABAoAAA==.',['�']='熔炉百相之角:AwACCAIABRQAAA==.',['�']='爱斯基摩狐狸:AwAHCBgABAoCFwAHAQhUFQBIRfIBBAoAFwAHAQhUFQBIRfIBBAoAAA==.',['�']='牛哎:AwADCAoABRQCGQADAQjxBQALx4oABRQAGQADAQjxBQALx4oABRQAAA==.',['�']='玛奇玛骑马:AwAFCAUABAoAAA==.玛薇卡:AwAGCAgABRQDBQAGAQjHAQApL4sBBRQABQAGAQjHAQApL4sBBRQABgACAQjHBgAZDGwABRQAAA==.',['�']='琥珀色晨光:AwADCAUABRQCGgADAQi2DAALL3QABRQAGgADAQi2DAALL3QABRQAAA==.琪亚娜:AwACCAIABAoAAA==.琳玉:AwAHCAcABAoAAA==.',['�']='画沙:AwAECAQABRQAAQQAWZcGCBkABRQ=.',['�']='盖尔:AwAECAQABRQAAA==.',['�']='矜持的老司机:AwEICAsABAoAAREAAAAICAMABRQ=.矢来美羽:AwABCAEABAoAARsAUjgFCA8ABRQ=.矮大妈:AwAICAgABAoAAA==.',['�']='砍王中王:AwADCAQABAoAAA==.',['�']='神样的方世玉:AwABCAEABRQEHAAIAQgTHQA01JsBBAoAHAAHAQgTHQA2SZsBBAoAAQAEAQgGXgAm37QABAoAGQABAQggQQAAAAAABAoAAA==.',['�']='秋枫:AwAECAQABRQAAA==.',['�']='空车达人:AwAECAQABRQAAA==.',['�']='糖糖里的奶昔:AwAFCAkABAoAAA==.',['�']='紫冰载荷:AwAECAIABAoAAA==.',['�']='红豆丷最相思:AwABCAEABRQAAA==.纳兰蛋蛋:AwAECAcABRQCHQAEAQjlBwA57vcABRQAHQAEAQjlBwA57vcABRQAAREAAAAGCAMABRQ=.',['�']='终曲黎明:AwADCAMABAoAAA==.给你一拳得了:AwAFCAUABAoAAA==.',['�']='缱绻几许:AwABCAEABAoAAA==.',['�']='耿鬼:AwAGCA4ABRQCDwAGAQgbAgBaiFUBBRQADwAGAQgbAgBaiFUBBRQAAA==.',['�']='胡团跑的快:AwAGCAYABAoAAA==.',['�']='自伤无色:AwABCAEABRQDHQAIAQhzCwBVfXMCBAoAHQAIAQhzCwBVfXMCBAoAFQADAQjKXwAhamsABAoAAA==.',['�']='舞僧:AwAECAcABAoAAA==.',['�']='芥末兽:AwAECAwABRQEDAAEAQgDAwBgSj0BBRQADAADAQgDAwBgSj0BBRQAGwAEAQgpAwBGOxEBBRQADQAEAAgAAABCMgAABRQAAQsAMkEGCAgABRQ=.花芯里的虫:AwAECAEABRQAAA==.',['�']='苏悠娜:AwAECAIABRQAAA==.若离于爱者:AwAECAQABRQAAA==.',['�']='莉娅琳:AwAGCAYABAoAAA==.',['�']='菜毕雪:AwAECAIABRQAAA==.菜青虫乖乖:AwAICAkABAoAAR0AM3YICAkABRQ=.',['�']='萌萌的玉米粒:AwACCAIABAoAAA==.',['�']='蕾塞:AwAECAcABRQCCwAEAQj/CgBD/xEBBRQACwAEAQj/CgBD/xEBBRQAAA==.',['�']='薄荷冰冰咖:AwAECAIABRQAAA==.',['�']='血蹄凯恩:AwABCAEABAoAAA==.衝動老鬼:AwAECAQABRQAAA==.表情包:AwABCAEABRQAAA==.',['�']='裴秀智:AwAECAQABRQAAA==.',['�']='西瓜棒冰:AwAECAQABRQAAA==.',['�']='觅光:AwAGCAIABRQAAA==.',['�']='貓大师:AwAICAgABAoAAA==.',['�']='贺兰:AwAFCAQABAoAAA==.',['�']='路坎德莱尔:AwAICAgABAoAAA==.',['�']='轻裾丶术:AwAECBAABRQDDAAEAQggBgBJ1xEBBRQADAAEAQggBgBJ1xEBBRQAGwABAQi6HAAAAAAABRQAAA==.',['�']='辰夕:AwAECAgABRQCHgAEAQiJBwAiIuIABRQAHgAEAQiJBwAiIuIABRQAAA==.',['�']='逆雯:AwAICAgABAoAAA==.逗丁丁:AwAECAQABRQAAA==.',['�']='邪媚:AwABCAEABAoAAA==.',['�']='闪电酷仔:AwACCAIABRQAAA==.',['�']='阿啾子:AwACCAEABAoAAREAAAADCAQABRQ=.阿雅娜丶羽翌:AwAECAQABRQAAA==.阿雅娜丶羽翼:AwAHCAcABAoAAA==.',['�']='陈平安:AwAICAwABAoAAA==.',['�']='雨落星荷:AwAICAgABAoAAA==.雪域猎魔:AwAICAgABAoAAA==.雾里丶看花:AwAFCAUABAoAAA==.',['�']='露米娅:AwAECAQABAoAAA==.',['�']='静灵王道:AwAECAgABRQDFwAEAQjQBAA90gYBBRQAFwAEAQjQBAA90gYBBRQAHwAEAQj6EQA1I9wABRQAAR8AQIkGCAUABRQ=.',['�']='顶级射击猎:AwAFCAQABAoAAA==.顾轻萝:AwAGCAkABAoAARkALyoICAoABRQ=.',['�']='风之轻吟:AwAHCA4ABAoAAA==.风在诉说:AwAFCAUABAoAAA==.风暴烈酒陈:AwAECAQABRQAAA==.',['�']='馅饼:AwAGCAYABAoAAA==.',['�']='魔幻武僧:AwAHCAYABAoAAA==.魔幻风:AwAGCAkABAoAAA==.',['�']='黄油茄子:AwAECAQABRQAAA==.黄牛维生素:AwABCAEABAoAAA==.黑店丶老板:AwAGCAIABRQCDwACAQjqGgAvQYEABRQADwACAQjqGgAvQYEABRQAAQ4AQCkICAUABRQ=.黑暗突变:AwAICA4ABAoAAA==.默斯肯:AwAECA8ABRQCHwAEAQj2AQBilVwBBRQAHwAEAQj2AQBilVwBBRQAAA==.',['�']='龍傲天:AwADCAMABAoAAA==.龙妹:AwAGCAcABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end