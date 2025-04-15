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
 local lookup = {'Mage-Fire','Shaman-Enhancement','Warlock-Destruction','Warlock-Demonology','DeathKnight-Frost','DeathKnight-Unholy','Shaman-Elemental','Shaman-Restoration','Paladin-Holy','DemonHunter-Havoc','Druid-Restoration','Unknown-Unknown','Warrior-Fury','Priest-Healing','Evoker-Devastation','Evoker-Preservation','Monk-Brewmaster','Monk-Windwalker','Paladin-Protection','Druid-Feral','Druid-Guardian','Warlock-Affliction','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Paladin-Retribution','Priest-Shadow','Mage-Frost','Rogue-Subtlety','Rogue-Assassination','Warrior-Arms',}; local provider = {region='CN',realm='米奈希尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Af='Afufua:AwAICAYABAoAAA==.',Ai='Ainy:AwAGCAYABAoAAA==.',Ay='Ayangmage:AwAECAwABRQCAQAEAQgDDABKfwoBBRQAAQAEAQgDDABKfwoBBRQAAA==.Ayangshaman:AwAICBsABAoCAgAIAQj5IwAf8oABBAoAAgAIAQj5IwAf8oABBAoAAA==.',Be='Bellingham:AwAICBgABAoDAwAIAQjdAwBdc9cCBAoAAwAIAQjdAwBdc9cCBAoABAABAQg6YgAmYTkABAoAAA==.',Ch='Chaoticmuch:AwAICBgABAoDBQAIAQjlEQA6tUkBBAoABQAGAQjlEQBEVEkBBAoABgAEAQgxZAAnLfAABAoAAA==.Chaoticmuchs:AwAECAkABRQDAgAEAQieBQBQfg0BBRQAAgADAQieBQBQfg0BBRQABwABAQjiGQAAAAAABRQAAA==.',Co='Coisini:AwAGCAYABRQCCAAGAQh9AAAvuKMBBRQACAAGAQh9AAAvuKMBBRQAAA==.',Cr='Crystallize:AwACCAIABRQAAA==.',Cu='Curesorrow:AwAGCAYABAoAAQkAVFQDCAoABRQ=.',De='Delphine:AwAECAQABRQAAA==.',Do='Doraemon:AwAHCAgABAoAAA==.',Du='Durian:AwACCAQABRQCCgAIAQirGgBLokgCBAoACgAIAQirGgBLokgCBAoAAA==.',Ex='Excellent:AwAECAQABRQAAA==.',Fa='Faye:AwAGCAYABAoAAA==.',Fi='Firo:AwAGCAsABAoAAA==.',Gi='Giko:AwAGCA0ABAoAAA==.',Gu='Guko:AwAGCAwABAoAAA==.',In='Intoxicating:AwAFCAgABAoAAA==.',Li='Lindh:AwADCAkABRQCCgADAQihBABZ8zkBBRQACgADAQihBABZ8zkBBRQAAA==.Linrogue:AwAECAYABAoAAA==.Linshaman:AwAGCAgABAoAAA==.',Lo='Longsoos:AwAICAsABAoAAA==.',Lu='Lumy:AwAICAkABAoAAA==.',Ly='Lyr:AwACCAIABAoAAA==.',Mi='Misaki:AwAECAQABRQAAQsAVBwICAcABRQ=.Miwoo:AwABCAEABRQAAA==.',No='Novoyoona:AwADCAQABAoAAQwAAAAECAQABRQ=.',Ny='Nyankosensei:AwACCAEABRQAAA==.',Pl='Playerpcyclq:AwAFCAUABAoAAA==.',Pp='Ppa:AwAECAMABAoAAA==.',Ro='Ronronner:AwADCAQABRQCDQAIAQj1JgAyadMBBAoADQAIAQj1JgAyadMBBAoAAA==.Royce:AwAICAQABAoAAA==.',Ru='Russo:AwAHCA0ABAoAAA==.',Sp='Spiritwalker:AwAECAEABRQAAA==.',Th='Threesocks:AwACCAIABRQAAQ4AQRUGCAYABRQ=.',Tm='Tmbaby:AwAICBIABAoAAA==.',Vi='Vivo:AwAECAQABAoAAA==.',Wi='Winterfell:AwAECAQABRQAAA==.',Xd='Xdr:AwAECAwABRQDDwAEAQiVDQA+jbUABRQADwADAQiVDQBT5rUABRQAEAABAQhECAA1E0EABRQAAQsAVBwICAcABRQ=.Xdz:AwAICAoABAoAAQsAVBwICAcABRQ=.',Xm='Xms:AwAICAUABAoAAQsAVBwICAcABRQ=.',Xs='Xsm:AwAECAQABRQCCAAIAQhwAABivQ8DBAoACAAIAQhwAABivQ8DBAoAAQsAVBwICAcABRQ=.',Xx='Xxd:AwAICAkABAoCCwAGAQjwKgBUzlQBBAoACwAGAQjwKgBUzlQBBAoAAQsAVBwICAcABRQ=.',['�']='七葉灬:AwAICAgABAoAAQsAOkwGCAUABRQ=.万象澄澈:AwAICBIABAoAAA==.下次一定:AwAFCAIABAoAAA==.不卡基本无敌:AwAECAQABRQAAQsAPyYICAsABRQ=.不讲武德:AwAICBYABAoCEQAIAQhXBwBEWeABBAoAEQAIAQhXBwBEWeABBAoAAA==.不过些许风霜:AwAGCAwABAoAAA==.丨雷电老头子:AwAECAQABRQAAA==.中场拖拉机:AwAICAkABAoAAA==.丶小牧:AwADCAEABRQAAQsAVBwICAcABRQ=.丶白酒一斤癫:AwADCAMABAoAAA==.',['�']='乏力小崔:AwABCAEABAoAAA==.九玥:AwAHCAsABAoAAA==.乱舞之刃:AwACCAIABAoAAA==.',['�']='二月的矮冬瓜:AwADCAMABAoAAA==.于饵:AwAICAkABAoAAA==.井灵儿:AwAFCBIABAoAAA==.交洋:AwAECAQABAoAAA==.',['�']='仼者丶梦迪:AwAECAQABRQAAA==.',['�']='伊津津美:AwAGCBIABAoAAA==.',['�']='克克洛斯大人:AwAICAgABAoAAA==.克拉夫特:AwAGCAYABRQCEgAGAQhjAABPsRcCBRQAEgAGAQhjAABPsRcCBRQAAA==.六里桥:AwAECAQABRQAAA==.',['�']='冥鱼之泪:AwAECAQABRQAAA==.冬至:AwAGCAYABAoAAA==.冰葉格格:AwAGCAcABAoAAA==.冰葉芷若:AwAFCAUABAoAAA==.冰邪血刃:AwACCAIABRQAAA==.',['�']='刘亦菲十八岁:AwAGCAYABAoAAQwAAAAECAQABRQ=.别慌有影遁:AwACCAIABRQAAA==.别装丶:AwAICAgABAoAAA==.',['�']='北落星星:AwABCAEABAoAAA==.',['�']='南半球有个坑:AwAICBgABAoCEwAIAQgICwBHSTECBAoAEwAIAQgICwBHSTECBAoAAA==.',['�']='变熊啦嗷呜:AwAECAQABRQAAA==.古尓丹雯希:AwAICAgABAoAAA==.叮咯咙咚锵:AwAECAQABRQAAA==.可疑的渊咕:AwAICAgABAoAAA==.叶一一:AwADCAMABAoAAA==.叶流云丶:AwAICAgABAoAAA==.叶轻眉丶:AwACCAIABRQAAA==.',['�']='名侦探柯基:AwAICBAABAoAAA==.',['�']='呆萌小怪兽丶:AwAICAgABAoAAA==.呵屮呵:AwAGCAYABAoAAA==.',['�']='和巽:AwAGCAYABAoAAA==.',['�']='哎丫丫:AwAECAQABRQAAA==.',['�']='唐婉秋:AwAECAQABRQAAA==.',['�']='善变的囡囡:AwAICBcABAoDFAAIAQgeCQA4fA4CBAoAFAAIAQgeCQA3uQ4CBAoAFQABAQjfKAAfOSYABAoAAA==.',['�']='四岁会撩妹:AwAECAQABRQAAA==.',['�']='圆圈圈胖嘟嘟:AwAHCAcABAoAAA==.圣诞一八九三:AwADCAYABRQEBAAIAQjzKABDsgQBBAoAAwAGAQhYTgAtcgwBBAoABAAEAQjzKABBwQQBBAoAFgADAQibHABGNeYABAoAAA==.地狱堕天:AwAHCBsABRQCCgAHAQiZAAAj/AMCBRQACgAHAQiZAAAj/AMCBRQAAA==.',['�']='夜半的小骑士:AwAICA0ABAoAAA==.大侦探皮卡丘:AwAICAgABAoAAA==.大吉发:AwAICAkABAoAAA==.大地母亲雯希:AwAICAgABAoAAA==.大能能:AwAICA4ABAoAAA==.天使病号:AwAGCAgABRQDFwAGAQjyDwBB4PkABRQAFwAGAQjyDwBB4PkABRQAGAACAQhoEgBOG4QABRQAAA==.天酷帅财:AwACCAQABRQAAA==.',['�']='奈萨里奥雯希:AwAGCAYABAoAAA==.',['�']='孙少爺:AwABCAEABRQAAA==.',['�']='射的艺术:AwABCAIABRQCFwAIAQhqNgA92PUBBAoAFwAIAQhqNgA92PUBBAoAAA==.小丶单车:AwABCAEABAoAAA==.小哪吒丶:AwAGCAYABAoAAA==.小坎肩:AwAHCA0ABAoAAA==.小害怕:AwAFCAUABAoAAA==.小小蛮:AwADCAEABAoAAA==.小崔:AwAECAQABRQAAA==.小狐仙丶:AwACCAQABRQAAA==.小落:AwAECAEABAoAAA==.小虎:AwAFCAUABAoAAA==.小陀螺丶:AwAFCAUABAoAAA==.尐样儿丶:AwAICAgABAoAAA==.少哔哔:AwABCAEABRQAAA==.尤拉雅:AwAICAgABAoAAQwAAAAECAQABRQ=.',['�']='川久保玲:AwADCAMABAoAAA==.左迪洛斯:AwAICAgABAoAAA==.',['�']='帅鸡:AwAICAQABRQAAA==.帖拉所伊朵:AwAICAgABAoAAA==.帮我关下月亮:AwACCAIABAoAAA==.',['�']='平昌猫:AwAICBkABAoDBgAIAQgHCQBb1MICBAoABgAIAQgHCQBb1MICBAoAGQAIAQiNEQBMTPkBBAoAAA==.幻蘑师:AwAFCAUABAoAAA==.幽丶冥:AwAICAgABAoAAA==.幽冥战神:AwAHCAcABAoAAA==.幽冥猎手:AwAECAQABAoAAA==.',['�']='开心超人:AwAECAgABRQCBgAEAQhSBwBN4AkBBRQABgAEAQhSBwBN4AkBBRQAARkAJNIGCA0ABRQ=.开膛手抓饼:AwAECAIABRQAAA==.',['�']='思卿朝暮:AwAGCAYABAoAAA==.',['�']='悠米:AwAICAIABAoAAA==.',['�']='情敌:AwAECAYABRQCCgAEAQiDCQBA8Q4BBRQACgAEAQiDCQBA8Q4BBRQAAA==.',['�']='愈光:AwADCAkABRQDCQADAQi3BQAoFN0ABRQACQADAQi3BQAoFN0ABRQAGgABAQiSOAAgO1AABRQAAA==.',['�']='慕婉儿:AwAGCAQABRQCAwAIAQhoCgBSxIsCBAoAAwAIAQhoCgBSxIsCBAoAAA==.慕芷晴:AwAECAUABRQCFgAEAQhICAAnMNcABRQAFgAEAQhICAAnMNcABRQAAQwAAAAICAQABRQ=.',['�']='我原地飞升:AwAECAQABRQAAA==.我姓杨丶:AwAECAQABRQAAA==.我是法斯:AwAECAQABRQAAA==.我是葡萄:AwAGCAQABRQAAA==.我的胆子很肥:AwAGCA8ABAoAAA==.战复要收钱:AwABCAEABAoAAA==.',['�']='拉烂摆:AwACCAIABAoAAA==.拾步殺壹人:AwACCAIABAoAAA==.',['�']='搓绿火的囡囡:AwAICBEABAoAAA==.',['�']='撸猫猫:AwAGCAMABRQAAA==.',['�']='方片悠佑:AwAGCAYABRQCEgAGAQjvAAA4i9UBBRQAEgAGAQjvAAA4i9UBBRQAAA==.',['�']='无忧无怖:AwADCAoABRQCCQADAQh9AQBUVCoBBRQACQADAQh9AQBUVCoBBRQAAA==.时光机:AwAECAQABRQAAA==.',['�']='星辰墜落:AwAHCAcABAoAAA==.春日野宆:AwAECAQABRQAAA==.春水煎茶丶:AwAECAQABRQDAgAIAQiRIwAdE4QBBAoAAgAIAQiRIwAdE4QBBAoACAAGAQgNWwA3PAABBAoAAQwAAAAGCAIABRQ=.',['�']='暗影波比:AwACCAQABRQCGwAIAQhQDgBRuF0CBAoAGwAIAQhQDgBRuF0CBAoAAA==.',['�']='曼妙蝶舞:AwADCAMABAoAAA==.',['�']='有德丶有失:AwACCAIABRQAAA==.有马加奈:AwAICAEABAoAAA==.术惋惜:AwACCAIABAoAAA==.朱茵:AwAECAQABRQAAA==.朴昌范:AwAGCAwABRQEAwAGAQgjAABeBSsCBRQAAwAGAQgjAABeBSsCBRQAFgACAQgyEQAfJHoABRQABAABAQh5FgAAAAAABRQAAA==.',['�']='村儿:AwAECAQABRQAAA==.板凳漂移:AwABCAIABRQAAA==.',['�']='林涧新韵:AwAICBAABAoAAA==.',['�']='柔柔爹拨皮:AwAICBMABAoAAA==.',['�']='格锐特:AwACCAIABRQAAA==.格雷邁恩:AwAICA0ABAoAAA==.',['�']='梁朝伟:AwAECAQABRQAAA==.',['�']='棍插四海:AwAICAoABAoAAA==.棒冰:AwACCAUABRQCCgACAQgLFwBW9cQABRQACgACAQgLFwBW9cQABRQAAA==.',['�']='楊幂丶:AwAECAQABRQAAA==.楠木叁迁:AwAICAgABAoAAA==.',['�']='橙色:AwAECAQABRQAAA==.橙色人种:AwAICA8ABAoAAA==.',['�']='武夙夜:AwAICAgABAoAAA==.死亡在敲门丶:AwADCAMABAoAAA==.',['�']='水宝:AwAECAQABAoAAQwAAAAICAMABRQ=.',['�']='没有耐心:AwAGCAgABRQCAQAEAQgKDgBOBv8ABRQAAQAEAQgKDgBOBv8ABRQAAA==.',['�']='泥哥:AwACCAIABRQAAA==.泽川小兔:AwAICAEABAoAAA==.',['�']='洛丹伦的王子:AwAICAgABAoAAA==.活命骑士:AwAECAQABAoAAA==.',['�']='流光飞萤:AwADCAEABRQEGgAHAQjrmAAl+zMBBAoAGgAHAQjrmAAlDzMBBAoACQAEAQg/LgAXWrYABAoAEwAGAQgdNgAO5ZIABAoAAA==.浩剋:AwAICAkABAoAAA==.浪味仙:AwAGCAoABAoAAA==.',['�']='淰汐:AwAGCAkABAoAAA==.',['�']='清宵:AwAICBUABAoCGQAIAQh8DQBGMDECBAoAGQAIAQh8DQBGMDECBAoAAA==.清青:AwAFCAUABAoAAA==.清风云海:AwAECAQABAoAAA==.',['�']='潇羽:AwAICAkABAoAAQkAKBQDCAkABRQ=.潜歼范:AwABCAEABRQAAA==.',['�']='火吻:AwAICAgABAoAAQwAAAAGCAQABRQ=.灬威廉灬:AwAECAQABRQAAA==.灼明之苍蓝星:AwAFCAgABAoAAA==.灿若星辰:AwACCAIABRQAAA==.',['�']='点点:AwADCAMABRQAAA==.',['�']='爱静如梦:AwAECAQABRQAAQMALloHCAYABRQ=.',['�']='狂风骤雨:AwAECAQABAoAAA==.',['�']='猫之愛恋:AwAICAoABAoAAQwAAAAICBAABAo=.猫猫德:AwAECAQABRQAAA==.',['�']='王薯片:AwAECAQABRQAAA==.玛门:AwAECAQABAoAAA==.',['�']='珍娜米奈希尔:AwACCAIABRQAAA==.',['�']='琢光:AwAECAQABRQAAA==.',['�']='甜丝儿丝儿:AwAICA8ABAoAAA==.',['�']='疏通管道:AwAECAYABRQCGgAEAQgZHgAnRMcABRQAGgAEAQgZHgAnRMcABRQAAA==.',['�']='白湘:AwAICAIABAoAAA==.',['�']='皮卡丘乄:AwAICBkABAoEAgAIAQguEwBP3CACBAoAAgAIAQguEwBP3CACBAoABwAEAQiwQQAgAt8ABAoACAADAQjbjAAExnMABAoAAA==.皮皮乐:AwADCAMABRQAAQkAVFQDCAoABRQ=.',['�']='盯盯猫儿:AwAECAEABRQAAQoAQD8GCAoABRQ=.',['�']='眼神忧郁深沉:AwAECAgABRQCGgAEAQirCQBQTRkBBRQAGgAEAQirCQBQTRkBBRQAAA==.',['�']='睦灵云熙:AwAGCAYABAoAAA==.',['�']='瞬发炉石法案:AwACCAIABRQAAA==.',['�']='破晓的败犬:AwAGCAYABAoAAQEAQ8QICAcABRQ=.',['�']='神咬过的苹果:AwAICAgABAoAAA==.神圣的豆浆:AwAGCAUABAoAAA==.神木丽:AwADCAMABAoAAA==.神經刀:AwAECAQABAoAAA==.祥和大师:AwABCAEABAoAAA==.',['�']='秋风物语:AwAGCAoABAoAAA==.积积阳阳德:AwABCAEABRQAAA==.',['�']='竹子与石榴:AwAECAQABAoAAA==.',['�']='糖糖三角:AwAFCAkABRQDFAAFAQjtAQAy0f8ABRQAFAADAQjtAQA6RP8ABRQACwACAQhfCQBBXMIABRQAAA==.',['�']='红泥小火炉:AwAECAUABRQCAQAEAQhkDwA9KfoABRQAAQAEAQhkDwA9KfoABRQAAA==.纯田真奈:AwAECAQABAoAAA==.',['�']='终阳的败犬:AwAGCAgABRQCGgAGAQiRAABIP9oBBRQAGgAGAQiRAABIP9oBBRQAAA==.',['�']='聂小倩丶:AwAECAEABRQAAA==.聖蛋侠:AwADCAMABAoAAA==.',['�']='胖妹儿:AwAFCAYABAoAAA==.胖胖是棒棒:AwACCAQABRQAAA==.胖胖的母熊猫:AwAGCAYABAoAAA==.',['�']='自然守護:AwAICAgABAoAAA==.',['�']='舔狗必须死:AwAICAwABAoAAA==.',['�']='芙宁娜:AwAECAQABRQAAA==.花前月夏:AwAECAgABRQDHAAEAQi9AwBBEQkBBRQAHAAEAQi9AwBAgwkBBRQAAQAEAQivGQAj2NQABRQAAA==.花树:AwAICAgABAoAAA==.',['�']='茉莉雨:AwACCAIABAoAAA==.茶茶子:AwEGCAoABRQCCgAGAQhBDABHOf4ABRQACgAGAQhBDABHOf4ABRQAAA==.',['�']='莉亚德琳雯希:AwAICAgABAoAAA==.莫慌:AwAICBAABAoAAA==.',['�']='菜鸟驿站:AwAECAQABRQAAA==.',['�']='萌你一脸血:AwAECAIABRQAAA==.萌系小毁灭:AwAECAEABRQAAA==.落红逐青裙:AwACCAUABRQDAQACAQgmJABCeZQABRQAAQACAQgmJAAuo5QABRQAHAABAQhhFgBK4EEABRQAAA==.',['�']='蕾赛:AwAECAQABRQAAA==.',['�']='蜜菟:AwADCAMABAoAAA==.',['�']='蝶恋:AwAGCA4ABAoAAA==.',['�']='蟲姬:AwAGCAgABAoAAA==.蟹蟹:AwAECAQABAoAAA==.',['�']='裙下之臣:AwAECAYABRQCGgAEAQjqAgBiVE8BBRQAGgAEAQjqAgBiVE8BBRQAAA==.裸丶刁:AwAECAQABRQAAA==.',['�']='许我在少年:AwAGCAMABAoAAA==.',['�']='豹变之蔚:AwAICCMABAoCEQAIAQhcAgBWu6QCBAoAEQAIAQhcAgBWu6QCBAoAAA==.',['�']='贝利乌鸦嘴:AwAICA0ABAoAAA==.',['�']='超级奶爸:AwAECAQABRQAAA==.',['�']='躺尸老板:AwABCAEABRQCEQAIAQgrAwBYj30CBAoAEQAIAQgrAwBYj30CBAoAARIAWZcGCBkABRQ=.',['�']='辣酱汤:AwAFCAUABAoAAA==.',['�']='送你一朵花:AwAECAQABRQAAA==.逆流六分仪:AwAICA4ABAoAAA==.逆袭丶凝凝:AwACCAIABAoAAREAU0EECAQABRQ=.逆风飞翔:AwAECAQABRQAAA==.',['�']='那咋啦:AwAGCAkABAoAAA==.',['�']='酒花大地精:AwACCAQABRQDAQAIAQgxIQBHFB0CBAoAAQAIAQgxIQA/fx0CBAoAHAAEAQhzSgA72QoBBAoAAA==.',['�']='野火童子:AwAICAgABAoAAA==.',['�']='长命锁:AwAGCAcABAoAAA==.',['�']='阿弥诺斯:AwAECAQABRQAAA==.阿耳:AwAGCAkABRQDHQAGAQisAAAygrABBRQAHQAGAQisAAAkcbABBRQAHgACAQjSCAA8JcYABRQAAA==.阿萨斯雯希:AwAHCAcABAoAAA==.阿飞的小锤子:AwACCAIABAoAAA==.阿鲁卡多:AwAECAQABRQAAA==.',['�']='陆六六:AwAECAQABRQAAA==.限量版灬虾条:AwACCAUABRQDHwACAQgZCwBOEpwABRQAHwACAQgZCwAuIZwABRQADQABAQjmGwBiKHQABRQAAA==.陳初見丶:AwAHCAcABAoAAQwAAAAICAEABRQ=.',['�']='随風潜入:AwAICAgABAoAAQwAAAAGCAMABRQ=.隐凡之路:AwAICA4ABAoAAA==.',['�']='雪涩寒扬:AwAICA8ABAoAAA==.雲烟印象:AwADCAMABAoAAA==.',['�']='青木琉璃:AwAECAQABAoAAA==.青玄:AwAFCAUABAoAARoAYAQECAQABRQ=.青龙场的龙:AwACCAQABAoAAA==.',['�']='風雪夜歸人:AwAICBYABAoCBgAIAQj/EQBPknYCBAoABgAIAQj/EQBPknYCBAoAAA==.',['�']='风华:AwABCAEABRQAAA==.风飞丶沙:AwAECAQABRQAAA==.',['�']='魑魅魍魉:AwACCAIABRQAAA==.魔丸:AwADCAIABRQAAA==.',['�']='麦琳:AwADCAMABRQAARwAUZcECAUABRQ=.',['�']='黑月无影:AwADCAsABRQDHQADAQijBgBXDfIABRQAHQADAQijBgA0I/IABRQAHgACAQgRCgBd4bQABRQAAA==.黑桐月:AwAECAQABRQAAA==.黑龙的使者:AwAICBAABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end