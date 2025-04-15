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
 local lookup = {'Unknown-Unknown','DemonHunter-Havoc','Paladin-Retribution','Druid-Restoration','Hunter-BeastMastery','Warlock-Destruction','Hunter-Marksmanship','Mage-Frost','DeathKnight-Blood','Priest-Discipline','Priest-Holy','Warlock-Demonology','Monk-Brewmaster','Monk-Windwalker','Druid-Balance','Mage-Fire','Warrior-Fury','Rogue-Assassination',}; local provider = {region='CN',realm='远古海滩',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ch='Chosenson:AwAICA0ABAoAAA==.',Do='Doleni:AwAECAQABRQAAQEAAAAICAIABRQ=.',Fr='Freedom:AwABCAEABRQAAA==.',La='Lazzy:AwAECAQABRQAAA==.',Na='Nani:AwABCAIABRQCAgAIAQiWFwBRIGQCBAoAAgAIAQiWFwBRIGQCBAoAAA==.',Tk='Tkatt:AwAGCAEABAoAAA==.',Wd='Wdeathgo:AwACCAIABRQCAwAIAQgsJgBZ528CBAoAAwAIAQgsJgBZ528CBAoAAA==.',['�']='一风之伤焰一:AwABCAEABRQAAA==.上帝沚手丶:AwACCAIABRQAAQIAGU0ECAoABRQ=.不喝热水:AwAECAcABAoAAA==.不良灬少女:AwAECAoABRQCBAAEAQgmBABL8BsBBRQABAAEAQgmBABL8BsBBRQAAA==.专属伱丨小雄:AwACCAIABAoAAA==.丨半月式:AwAICAoABAoAAA==.丨擎剑术:AwABCAEABAoAAA==.中野二乃:AwADCAQABRQCBQAIAQjRKQBJbjgCBAoABQAIAQjRKQBJbjgCBAoAAA==.丶馬王爷:AwAICBEABAoAAA==.',['�']='今晚打老虎吗:AwADCAMABRQAAA==.',['�']='伊纳瑞斯:AwAICBIABAoAAQYAK74ECAQABRQ=.',['�']='体温叁拾八:AwAECAQABRQAAA==.',['�']='冬雪落浅浅:AwAECAQABRQAAA==.冯大骇:AwAICAgABAoAAA==.冰殇丨大伯:AwAECAQABRQAAA==.冷面刀手:AwAECAoABAoAAA==.',['�']='刘海遮了眼:AwAECAQABRQAAA==.初若有奶:AwADCAQABRQAAA==.',['�']='十文字未来:AwAECAQABRQAAA==.华文:AwADCAgABRQCBwADAQhgCgAuqt8ABRQABwADAQhgCgAuqt8ABRQAAA==.卖萌的小骑士:AwAECAEABRQAAA==.卡皮扒拉:AwAECAQABAoAAA==.',['�']='双椒鱼:AwAECAQABRQAAA==.古娜拉黑暗神:AwAECBEABRQCCAAEAQhqAABijFgBBRQACAAEAQhqAABijFgBBRQAAA==.只为装逼:AwAECAMABAoAAA==.可爱小宝宝:AwACCAIABAoAAA==.叶心安前女友:AwAECAQABRQAAA==.叶心安的妹妹:AwAGCAEABAoAAA==.',['�']='后羿他哥:AwACCAEABAoAAA==.',['�']='咔皮巴拉:AwAFCAcABAoAAA==.咲咲大魔王:AwAECAQABRQAAA==.',['�']='喵猫貓:AwACCAIABAoAAA==.',['�']='在下头很硬:AwADCAUABRQCCQADAQhtCwA3s8gABRQACQADAQhtCwA3s8gABRQAAA==.',['�']='夜魅影:AwADCAcABRQDBwADAQhNDwAfWLUABRQABwADAQhNDwAXLrUABRQABQACAQh2LAAgmosABRQAAA==.大憨憨:AwAICAgABAoAAA==.大牛有点懒:AwAFCAUABAoAAA==.天智:AwADCAUABRQCCAAIAQh8GwBHLQwCBAoACAAIAQh8GwBHLQwCBAoAAA==.',['�']='奎尔扎拉姆:AwAECAQABRQAAA==.',['�']='媚不媚:AwAECAQABRQAAA==.',['�']='小小予:AwACCAQABRQAAA==.',['�']='屠城英雄:AwADCAgABRQCAwADAQjRBgBZli8BBRQAAwADAQjRBgBZli8BBRQAAA==.',['�']='崇唐:AwAECAgABRQCAwAEAQh+CwBQLxcBBRQAAwAEAQh+CwBQLxcBBRQAAA==.',['�']='弑神之箭:AwAECAQABAoAAA==.',['�']='戀上你的唇:AwAECAQABRQAAA==.我就不:AwADCAcABRQCAwADAQhLBwBaAiwBBRQAAwADAQhLBwBaAiwBBRQAAA==.我超级厉害:AwAECAQABRQAAA==.',['�']='收割:AwEICA8ABAoAAQEAAAAICAMABRQ=.放逐:AwADCAEABAoAAA==.',['�']='新地方:AwADCAMABAoAAA==.',['�']='无糖养乐多:AwABCAEABRQAAA==.',['�']='星怒:AwAECAYABAoAAQEAAAAGCAEABRQ=.',['�']='本姑娘贝熙儿:AwAICA8ABAoAAA==.',['�']='杏花春雨江南:AwAECAgABRQCAgAEAQg6FgAeldYABRQAAgAEAQg6FgAeldYABRQAAA==.',['�']='果粒橙艾萌:AwAICA4ABAoAAA==.',['�']='楚涵:AwAICAgABAoAAA==.',['�']='此昵称太帅:AwACCAIABAoAAA==.武毅:AwAICAoABAoAAA==.',['�']='沐沐妮妮:AwAECAwABRQDCgAEAQgKBwBRfgoBBRQACgAEAQgKBwBRfgoBBRQACwACAQgIEgA8n4kABRQAAA==.治疗:AwACCAEABAoAAA==.',['�']='流浪的猫:AwACCAIABRQAAA==.浅霜:AwADCAsABRQCCwADAQgEAQBg10sBBRQACwADAQgEAQBg10sBBRQAAA==.',['�']='烟雨潇湘:AwAGCA0ABAoAAA==.',['�']='燃情小赵:AwACCAIABRQAAA==.燃烧之灭:AwADCAkABRQDBgADAQhYCwBOCO8ABRQABgADAQhYCwA+9u8ABRQADAABAQhAEQBNTkwABRQAAA==.',['�']='爆头属串:AwAECAcABRQDBwAEAQgpBwBLBPYABRQABQADAQi5DwBBWQIBBRQABwAEAQgpBwBFBfYABRQAAA==.',['�']='猫手猫脚:AwAECAcABRQCDQAEAQhEAgBASdwABRQADQAEAQhEAgBASdwABRQAAQ4AKkoICAYABRQ=.',['�']='玖弦:AwADCAMABRQAAA==.',['�']='球球大王:AwACCAIABRQAAQ8ADlAGCA8ABRQ=.',['�']='畩嘫豪氣冲天:AwAICAcABAoAAQQAOkwGCAUABRQ=.',['�']='白芷沅夜:AwACCAMABRQAAA==.',['�']='皇家天狼:AwAICA8ABAoAAA==.',['�']='秋风爱上落叶:AwABCAEABAoAAA==.',['�']='第七季冰河:AwADCAMABAoAAA==.',['�']='精灵之火:AwAICAgABAoAAA==.',['�']='糖醋小姑姑:AwAECAgABAoAAA==.',['�']='绿茶加心机:AwAECAQABRQAAQUAN9MGCAkABRQ=.',['�']='胸肌好看不:AwACCAIABAoAAA==.',['�']='自然卷饼:AwACCAQABRQAAA==.',['�']='苏格儿:AwADCAQABRQDEAAIAQgcFwBQ92ACBAoAEAAIAQgcFwBQ92ACBAoACAAEAQhYcwAvY5AABAoAAA==.',['�']='莞娘:AwAICAgABAoAAA==.',['�']='蓄意欧拉:AwACCAIABAoAAA==.蓝小纱:AwAICAgABAoAAA==.',['�']='號萬軍:AwAGCAYABAoAAA==.',['�']='贝熙儿丶橙多:AwAICAwABAoAAA==.',['�']='跟上跟上:AwAECAQABAoAAA==.',['�']='边城钢:AwACCAIABAoAAA==.',['�']='这是什么邪法:AwADCAQABRQCAgAIAQjCCwBbh7oCBAoAAgAIAQjCCwBbh7oCBAoAAA==.',['�']='那个目什么空:AwAECAQABRQAAA==.',['�']='阿斯顿马飞:AwAECAQABRQAAREAF38HCAgABRQ=.',['�']='陌陌的馒头:AwABCAEABRQAAA==.',['�']='雅典没有娜:AwAECAQABRQAAA==.雪色幻象:AwACCAIABAoAAQkAR0IECAgABRQ=.雪落轻叹:AwAHCAcABAoAAA==.',['�']='飕鰰貔:AwABCAEABRQAAA==.飞飞翔名将:AwABCAEABRQAAA==.',['�']='鬼子驲天:AwAECAQABRQAAA==.',['�']='魔兽之路神奇:AwADCAgABRQCEgADAQiqBQBMmQQBBRQAEgADAQiqBQBMmQQBBRQAAA==.',['�']='龙吟天下:AwAGCAYABAoAAA==.龙煜:AwAGCAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end