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
 local lookup = {'Priest-Discipline','Warrior-Fury','Warrior-Arms','Shaman-Elemental','Shaman-Restoration','Unknown-Unknown','Hunter-BeastMastery','Evoker-Devastation','Evoker-Preservation','Shaman-Enhancement','Monk-Mistweaver','Monk-Brewmaster','Priest-Holy','DeathKnight-Unholy','Priest-Shadow','Rogue-Assassination','Paladin-Retribution','Mage-Frost','Hunter-Marksmanship','Warlock-Destruction','Warlock-Affliction','Paladin-Protection','Druid-Guardian','Hunter-Survival',}; local provider = {region='CN',realm='通灵学院',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Alraune:AwAFCAUABAoAAA==.',An='Ancient:AwABCAIABRQAAA==.Annewalksky:AwAICAIABAoAAA==.',Bi='Biubiuubiuu:AwAECAQABRQCAQAEAQhOCQBD8vMABRQAAQAEAQhOCQBD8vMABRQAAA==.',Ch='Chilam:AwAGCAUABAoAAA==.',De='Depot:AwAFCAUABRQDAgAFAQibAgAevmUBBRQAAgAEAQibAgAj72UBBRQAAwABAQiaEQAJ91sABRQAAA==.',Dr='Dragon:AwADCAUABRQDBAADAQikAwBLLxMBBRQABAADAQikAwBLLxMBBRQABQABAQh7KAA3qEQABRQAAA==.',Er='Erastar:AwAICA4ABAoAAQIAMYAICAsABRQ=.',Fl='Flynnz:AwAICAoABAoAAQYAAAAECAEABRQ=.',Gi='Ginxf:AwADCAMABAoAAA==.',Hk='Hknmatata:AwABCAEABRQAAA==.',Ky='Kyneraan:AwACCAIABAoAAA==.',Me='Mekina:AwAECAEABRQAAA==.',Mi='Missfate:AwADCAMABRQAAA==.',Mo='Motorhead:AwADCAsABRQCBwADAQiDEgA9/PcABRQABwADAQiDEgA9/PcABRQAAA==.',Ro='Rolanmina:AwAFCAUABAoAAA==.',Sa='Sarama:AwAECAEABRQAAQYAAAAGCAEABRQ=.',Se='Severus:AwABCAEABAoAAA==.',Sw='Swol:AwAICAgABAoAAA==.',Wh='Whitechapel:AwAECAQABRQAAA==.',Xb='Xbaoo:AwAGCAYABAoAAA==.',['�']='一世倾城泪:AwAICAgABAoAAA==.一岁就恋爱:AwAGCAYABAoAAA==.一档上山:AwAICAgABAoAAA==.一级葱师:AwAICAgABAoAAA==.一超级奶爸一:AwABCAEABRQAAA==.七安:AwABCAEABRQAAA==.三月七:AwAGCAgABRQDCAAGAQjgAQAqPJ8BBRQACAAGAQjgAQAqPJ8BBRQACQACAQjwBwAMn14ABRQAAA==.下头:AwAHCAEABAoAAA==.不是九五:AwABCAEABRQAAA==.不死小漒:AwACCAIABRQAAA==.个都跑不脱:AwAICA0ABAoAAA==.中年少龄码农:AwACCAIABAoAAQYAAAABCAEABRQ=.丶名木丶:AwADCAMABAoAAQYAAAAICA4ABAo=.丶咒丶:AwAFCAUABAoAAA==.丶若依:AwAFCAUABAoAAA==.丶轩儿丶:AwAFCAIABAoAAA==.丶队长给我球:AwACCAMABRQAAA==.丿橙王拜叩:AwAICAgABAoAAA==.',['�']='乌黑的雨云:AwABCAEABRQAAA==.',['�']='五月十五晴:AwAICBEABAoAAA==.人性本恶:AwADCAMABAoAAA==.人渣推土机:AwABCAEABRQDBQAIAQgYTQAaxTcBBAoABQAIAQgYTQAaxTcBBAoACgAEAQgXNQA2kPwABAoAAA==.人随己愿:AwAECAQABAoAAA==.',['�']='似醉踏雾起:AwAGCAYABRQCCwAGAQjQAgAcB4ABBRQACwAGAQjQAgAcB4ABBRQAAA==.',['�']='你仔细听:AwAECAIABRQAAA==.你痛苦我狂欢:AwACCAIABAoAAA==.',['�']='俺村我最好:AwACCAMABRQAAA==.',['�']='假米米:AwACCAIABRQAAA==.',['�']='傲世皇太子:AwABCAEABAoAAA==.',['�']='先生:AwACCAIABRQDDAAHAQgwDQA+xFIBBAoADAAHAQgwDQA+xFIBBAoACwAHAQiHTAASw+0ABAoAAA==.八兩:AwADCAIABAoAAQYAAAAGCAsABAo=.',['�']='冈崎溪:AwAGCAYABAoAAA==.冰淇霖:AwACCAEABAoAAA==.',['�']='利刃魔:AwABCAEABAoAAA==.别管我自己回:AwAFCAgABAoAAA==.',['�']='北极胖熊:AwAHCAcABAoAAA==.北海有墓碑:AwAICAgABAoAAA==.',['�']='十三妹妹好:AwAECAMABRQAAA==.千姬:AwAGCAQABRQCDQACAQjZCwBT2MMABRQADQACAQjZCwBT2MMABRQAAA==.南枫:AwABCAEABAoAAA==.',['�']='双刀斩日:AwABCAEABAoAAA==.只是一死骑:AwADCAUABRQCDgADAQhWBgBRbRoBBRQADgADAQhWBgBRbRoBBRQAAA==.',['�']='名字超难取啊:AwAICAMABAoAAA==.',['�']='命运多舛:AwAECAgABRQDDwAEAQgwDQAqKOAABRQADwAEAQgwDQAqKOAABRQADQAEAQiWDQAV6q8ABRQAAA==.',['�']='咳嗽:AwACCAIABRQAAA==.',['�']='哀伤:AwACCAIABRQAAA==.哎哟嗬:AwACCAMABRQCEAAIAQj6FgAkQqsBBAoAEAAIAQj6FgAkQqsBBAoAAA==.',['�']='喝汤麽:AwAGCAYABAoAAA==.喷嚏:AwAICAgABAoAAA==.',['�']='团长组我爸:AwAICAgABAoAAA==.国之重器:AwACCAIABAoAAA==.',['�']='圓滚滚:AwAFCAYABAoAAA==.',['�']='埃斯:AwADCAMABAoAAA==.',['�']='塔格:AwAICAwABAoAAA==.',['�']='夏秋:AwACCAIABAoAAA==.夜哭鬼:AwAICA4ABAoAAA==.大师吟诗:AwACCAIABRQAAA==.大灰狼:AwABCAEABRQAAA==.',['�']='奥奶骑:AwAECAQABRQAAA==.女乃马奇:AwAICA8ABAoAAA==.好出骑阿:AwABCAIABRQAAA==.',['�']='导轨敲击者:AwACCAIABRQAAA==.',['�']='小小甘蔗:AwAECAQABRQAAA==.小小的然然:AwABCAEABAoAAA==.小尾巴崽:AwACCAIABAoAAA==.小帆帆:AwADCAMABRQAAQIAMosICAkABRQ=.小德很硬:AwAECAIABRQAAA==.小糸侑:AwABCAEABRQCCwAIAQibJAAy8rgBBAoACwAIAQibJAAy8rgBBAoAAA==.小霖:AwAECAQABRQCEQAIAQhUUAA83+cBBAoAEQAIAQhUUAA83+cBBAoAAQIAF38HCAgABRQ=.尖头曼:AwAECAMABAoAAA==.',['�']='山寨叶问:AwAHCBUABAoCDAAHAQgQCQBBG7gBBAoADAAHAQgQCQBBG7gBBAoAAA==.',['�']='布丁橘子:AwADCAEABAoAAA==.布里起司:AwACCAIABRQAAA==.希瓦纳斯:AwAGCAYABRQCBwAGAQhJAwAbS4YBBRQABwAGAQhJAwAbS4YBBRQAAA==.',['�']='广州打击:AwACCAMABAoAAA==.',['�']='开飞机的舒克:AwAECAQABAoAAA==.弑神零零柒:AwACCAMABRQAAA==.',['�']='影子治疗师:AwACCAIABRQAAA==.彼岸之光:AwAHCAsABAoAAA==.',['�']='慕之:AwAICBYABAoCDQAIAQgJEgBA2SYCBAoADQAIAQgJEgBA2SYCBAoAAA==.',['�']='战神無雙:AwAGCAYABAoAAA==.',['�']='无力的蛋蛋:AwADCAMABAoAAA==.旧岛看月亮:AwAECAQABRQAAA==.',['�']='晨曦:AwAECAQABRQAAA==.',['�']='暴力滴批哎斯:AwAGCAYABAoAAA==.',['�']='曹清華:AwABCAIABRQAAA==.曾经最美:AwAFCAUABAoAAA==.',['�']='最机智小飞:AwABCAEABRQAAA==.月亮猫:AwAICBoABAoCDQAIAQjRKQAqqIIBBAoADQAIAQjRKQAqqIIBBAoAAA==.有女畵朱红:AwABCAEABAoAAA==.',['�']='李奥瑞克丶:AwAICAgABAoAAA==.李雷:AwAGCAwABAoAAA==.村口王师傅丶:AwAECAoABAoAAA==.',['�']='林俊杰:AwAECAYABRQDDQAEAQjjBQA+WPgABRQADQAEAQjjBQA+WPgABRQAAQABAQiLIAAtmkIABRQAAA==.枪机:AwAFCAEABAoAAA==.枭雄:AwABCAEABRQAAA==.',['�']='柔情小鹿:AwADCAMABAoAAA==.',['�']='梅柳齐娜:AwAECAQABRQAAA==.',['�']='楼区吴彦祖:AwACCAIABRQAAA==.',['�']='死骑大笨象:AwAFCAUABAoAAA==.',['�']='毛办法:AwABCAEABRQAAA==.毛真的疼:AwAFCAkABRQCAgAIAQiFIgAyZfUBBAoAAgAIAQiFIgAyZfUBBAoAAA==.毛胖球:AwAECA8ABRQDAQAEAQjtBABV+iUBBRQAAQAEAQjtBABV+iUBBRQADQABAQhDGwBZ80UABRQAAA==.',['�']='汪苏泷:AwAFCAQABAoAAQ0APlgECAYABRQ=.',['�']='洛言丷:AwACCAMABRQAAA==.',['�']='混仔丨射:AwAECAMABRQAAA==.',['�']='湿纸巾:AwACCAQABRQCEgAIAQirAQBhYgsDBAoAEgAIAQirAQBhYgsDBAoAAA==.',['�']='潇洒哥:AwACCAMABRQAAA==.',['�']='濑挞:AwABCAEABAoAAA==.',['�']='灭团:AwAHCAYABAoAAA==.灰呔狼:AwAGCAYABAoAAA==.',['�']='爱猫的兔子:AwAICAYABAoAARMAQc0GCAYABRQ=.爹帝:AwAGCAYABAoAAA==.',['�']='牛仔掋裤:AwAGCAkABAoAAA==.牛牛是头牛:AwAECAUABAoAAA==.',['�']='狂歡:AwAECAYABRQDFAAEAQh5EQAmScsABRQAFAAEAQh5EQAmScsABRQAFQABAQhxGgAae0UABRQAAA==.狐贼狸:AwACCAIABAoAAA==.',['�']='玉脸擒獣:AwADCAMABRQAAA==.',['�']='琅琊灵:AwAECAEABAoAAQYAAAAECAQABRQ=.',['�']='瑺媙:AwAICAwABAoAAA==.',['�']='由乃的玖:AwAECAQABAoAAA==.',['�']='白菜开大了:AwAECAQABRQAAA==.',['�']='盐汁糕杏:AwAICA8ABAoAAQ0APlgECAYABRQ=.盖棉被纯聊天:AwAGCAYABAoAAA==.',['�']='知秋一叶:AwAGCAkABAoAAA==.石头猪:AwAECAQABRQAAA==.',['�']='碎人鸟:AwAGCAYABAoAAQYAAAAGCAQABRQ=.碰花碰草:AwAECAQABAoAAA==.',['�']='神之熊猫:AwAECAgABRQCCwAEAQjnCABMWQgBBRQACwAEAQjnCABMWQgBBRQAAA==.神圣发丝:AwAGCAcABRQCEQAGAQhWAgAhOIIBBRQAEQAGAQhWAgAhOIIBBRQAAA==.神圣闪光:AwAGCAEABAoAAA==.',['�']='秋之:AwAECAQABAoAAA==.秋水月缘:AwAICAIABAoAAA==.',['�']='符文百合:AwADCAMABAoAAA==.',['�']='糖晓歌:AwAECAQABRQAAA==.',['�']='紅豆:AwABCAEABRQAAA==.',['�']='红色铁骑:AwAICAgABAoAAA==.纯白波斯猫:AwABCAEABAoAAA==.纸巾丶:AwABCAEABAoAAA==.',['�']='绒绒毛:AwAGCAYABAoAAA==.绿豆麻薯:AwAECAQABRQAAA==.',['�']='老爷爷的愤怒:AwADCAMABAoAAA==.',['�']='脸上小眼罩:AwAFCAYABAoAAA==.',['�']='膤軕飝瓠:AwAECAgABRQCFgAEAQhCDAAUFYYABRQAFgAEAQhCDAAUFYYABRQAAA==.',['�']='舌诊医生:AwAGCAYABAoAAA==.',['�']='艾琳达:AwABCAEABAoAAA==.',['�']='花妃子:AwABCAEABAoAAA==.芽芽几:AwAECAIABRQAAA==.',['�']='若曦:AwAECAQABAoAAA==.',['�']='范德彪:AwACCAMABRQCFwAIAQjCBABFqDMCBAoAFwAIAQjCBABFqDMCBAoAAA==.茶茶么么哒:AwABCAEABRQAAA==.',['�']='荷鲁斯爱可乐:AwAGCAsABAoAAA==.',['�']='萨默海尔德:AwAECAQABAoAAA==.',['�']='血骑士:AwAGCAwABAoAAA==.',['�']='西红柿拌红糖:AwAICAMABAoAAA==.西门吹膤:AwAICBEABAoAARYAFBUECAgABRQ=.',['�']='言欢:AwABCAEABRQAAA==.記號:AwACCAYABRQCBwACAQiXIQBK9KkABRQABwACAQiXIQBK9KkABRQAAA==.',['�']='请叫我演员:AwAECAQABRQAAA==.',['�']='贝勒里恩:AwAECAQABRQAAA==.',['�']='辞暮:AwAECAQABRQAAA==.边渡有次子:AwABCAIABRQAAA==.',['�']='部落的驱逐者:AwAICAgABAoAAA==.',['�']='醉醉么么哒:AwADCAMABAoAAA==.',['�']='铁血奥尔芬斯:AwAICCYABAoCEQAIAQj0KwBHR1oCBAoAEQAIAQj0KwBHR1oCBAoAAA==.',['�']='锕莱克丝塔萨:AwAGCAwABAoAAA==.',['�']='闪电噼里啪:AwAECAMABRQAAA==.',['�']='阿莉塔:AwAGCAcABAoAAA==.',['�']='陈妍希:AwABCAEABAoAAA==.',['�']='雷闪嗞嗞:AwAECAcABRQCBQAEAQjGDAAygeoABRQABQAEAQjGDAAygeoABRQAAA==.',['�']='飘渺小轩轩:AwADCAMABAoAAA==.',['�']='餛飩麵:AwACCAIABRQEBwAIAQinGQBQdIMCBAoABwAIAQinGQBQdIMCBAoAEwAGAQhEQQAtRNwABAoAGAABAQhCHAASKCwABAoAAA==.',['�']='香贯花:AwAECAEABRQAARQAHjAICAYABRQ=.',['�']='黑上丨:AwAICA4ABAoAAA==.黛懵:AwAICAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end