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
 local lookup = {'Priest-Shadow','Priest-Discipline','Priest-Holy','Unknown-Unknown','Shaman-Enhancement','Monk-Mistweaver','Warrior-Arms','Paladin-Retribution','Warrior-Fury','DeathKnight-Blood','DeathKnight-Unholy','Druid-Guardian','Druid-Restoration','Mage-Fire','Mage-Frost','Druid-Balance','DemonHunter-Havoc','DeathKnight-Frost','Warlock-Destruction','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Holy','Rogue-Subtlety','Rogue-Assassination',}; local provider = {region='CN',realm='洛萨',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Aliqs:AwAICBMABAoAAA==.Alliswell:AwAHCAkABAoAAA==.',Am='Am:AwABCAIABRQEAQAIAQgRIQBF36cBBAoAAQAHAQgRIQBLqacBBAoAAgAEAQg4MwBXhygBBAoAAwACAQjVZgA1Q30ABAoAAA==.',An='Anglela:AwAGCAYABAoAAA==.',Az='Azir:AwAFCAwABAoAAA==.',De='Designer:AwAICAgABAoAAA==.',Gr='Grosfairy:AwEGCAwABAoAAQQAAAAGCAIABRQ=.',Hi='Hibao:AwADCAEABRQAAA==.',Jo='Johnjrambo:AwADCAMABRQAAA==.',La='Larethian:AwAICAgABAoAAQUAM3YICAkABRQ=.',Le='Leemo:AwAICBAABAoAAA==.',Lu='Luluc:AwAECAQABRQAAA==.',Ma='Matildav:AwAGCAYABAoAAA==.',Mo='Moxxi:AwAECAQABAoAAA==.',Ms='Mssjws:AwADCAYABRQCBgADAQjeCAA6cwABBRQABgADAQjeCAA6cwABBRQAAA==.',My='Mykka:AwEICBMABAoAAQQAAAAGCAIABRQ=.',Ou='Our:AwAICAIABAoAAA==.',Pa='Painter:AwAICAgABAoAAA==.Paynebig:AwAGCAIABAoAAA==.',Qu='Quixel:AwAICAgABAoAAA==.',Ra='Raguel:AwAECAQABRQAAA==.',Sa='Salamender:AwACCAEABRQAAQcAS5IGCBAABRQ=.',Se='Sephroth:AwACCAIABAoAAA==.',Ty='Tysck:AwAHCAMABAoAAA==.',Za='Zales:AwADCAQABAoAAA==.',['�']='一西瓜瓤一:AwAECAQABRQAAA==.丶暴走十三姨:AwAECAUABAoAAA==.为臊妮子而站:AwACCAYABRQCCAACAQjyHQBUpsgABRQACAACAQjyHQBUpsgABRQAAA==.',['�']='买辣椒也用券:AwAGCAgABAoAAA==.',['�']='仗剑丶:AwAFCAUABAoAAA==.付出与希望:AwAECAQABAoAAA==.仲夏夜丶情歌:AwAECAYABRQCCQAEAQhzAgBiQFcBBRQACQAEAQhzAgBiQFcBBRQAAA==.',['�']='伊织丶:AwAECAcABAoAAA==.优思明:AwAICAwABAoAAA==.会长缺德吗:AwAICAgABAoAAA==.',['�']='你的小命根:AwAHCAYABAoAAA==.',['�']='八云青:AwADCAEABRQAAA==.公牛插头:AwAGCAcABAoAAA==.',['�']='册那:AwAICAgABAoAAA==.冰魄傲魂:AwABCAEABAoAAA==.冰魄圣魂:AwAECAQABRQAAA==.冰魄神魂:AwAECAYABRQCAgAEAQggBABYvyYBBRQAAgAEAQggBABYvyYBBRQAAA==.冷雨随风:AwABCAEABRQAAA==.',['�']='刺参苏轼:AwACCAIABAoAAA==.',['�']='北海岸:AwAGCAYABAoAAA==.',['�']='十年未见的妳:AwACCAIABRQAAA==.十柒:AwAGCAkABAoAAA==.午夜的凋零:AwACCAMABRQDCgAIAQi7EQBCAfYBBAoACgAIAQi7EQA/L/YBBAoACwAIAQgvQAAncHsBBAoAAA==.半截硬:AwAICAgABAoAAA==.',['�']='变态史莱姆:AwAECAQABRQAAA==.只是一场戏丶:AwAICAYABAoAAQUAM3YICAkABRQ=.可爱:AwADCAQABRQAAA==.',['�']='吉姆利:AwABCAEABAoAAA==.',['�']='呼叫转移:AwACCAIABRQAAA==.命莲寺圣白莲:AwABCAEABRQAAA==.',['�']='咖啡:AwACCAIABAoAAA==.咸鱼战呀:AwAICA4ABAoAAA==.',['�']='啾丶啾啾:AwAICAgABAoAAA==.',['�']='四队萨满:AwADCAMABAoAAA==.',['�']='地狱宣告:AwAICAYABAoAAA==.',['�']='墨丨祁:AwABCAIABRQAAA==.',['�']='夜魅罗:AwACCAMABRQAAA==.天引:AwACCAYABRQCDAACAQgaAwAn8WgABRQADAACAQgaAwAn8WgABRQAAA==.',['�']='奥兹华尔德:AwAICBYABAoCCwAIAQiAOgAlPZMBBAoACwAIAQiAOgAlPZMBBAoAAA==.奥利波斯猎:AwACCAIABAoAAA==.奥术弹幕:AwAICBsABAoCCwAIAQgHBABdxvECBAoACwAIAQgHBABdxvECBAoAAA==.',['�']='妞大:AwAECAQABRQAAQ0APyYICAsABRQ=.',['�']='季伯徜:AwACCAIABAoAAA==.',['�']='宇喆:AwAGCAgABAoAAA==.宇宙小飞熊:AwAFCAIABAoAAA==.宝庆西区大帅:AwACCAQABRQAAA==.家有只百威:AwACCAQABRQAAQgAVKYCCAYABRQ=.',['�']='小豪快跑:AwADCAMABAoAAA==.小鸟哔哔:AwABCAEABRQAAA==.尤贝尔的幻影:AwAICAgABAoAAA==.',['�']='左撇子:AwAFCAYABAoAAA==.',['�']='干洗脸:AwAICAgABAoAAA==.幺鳕:AwAHCAsABAoAAA==.幻魅之铃:AwABCAEABRQAAA==.',['�']='开朗的憨憨:AwABCAEABAoAAA==.',['�']='彻底疯狂:AwAFCAQABRQAAA==.',['�']='恶魔法则:AwAECAkABRQDDgAEAQg+FQA2QeQABRQADgAEAQg+FQA1J+QABRQADwADAQh2DwAnOHwABRQAAA==.恶魔苏醒:AwAFCAUABAoAAA==.',['�']='惹晒来都杀了:AwAGCAYABRQDEAAGAQiVDQAm8vAABRQAEAADAQiVDQAnH/AABRQADQADAQhvDAAn0qIABRQAAA==.',['�']='愤怒的哈密瓜:AwADCAMABAoAAA==.',['�']='懂道法会拳脚:AwAECAYABAoAAA==.',['�']='我们要发财了:AwACCAIABRQAAA==.我怎么有把刀:AwAICAgABAoAAA==.战无誨:AwAECAIABRQAAA==.',['�']='打企鹅的豆豆:AwAECAkABRQCEQAEAQiMCABIlhQBBRQAEQAEAQiMCABIlhQBBRQAAA==.',['�']='抓根寳:AwABCAEABRQAAA==.',['�']='招牌沫沫:AwAECAUABRQCCAAEAQiTEAA+5/4ABRQACAAEAQiTEAA+5/4ABRQAAA==.',['�']='携琴舞剑行:AwAICAIABRQAAA==.',['�']='断罪:AwAICAsABAoAAA==.',['�']='星曦:AwAICBQABAoCDwAIAQhGIwA/n9QBBAoADwAIAQhGIwA/n9QBBAoAAA==.星际超混混:AwAICAgABAoAAA==.昨天灬再见:AwAECAQABAoAAA==.',['�']='晒黑的阳仔:AwABCAEABRQAAA==.',['�']='暗之剌牙:AwADCAUABAoAAA==.暴走的小瞎比:AwAECAgABRQCEQAEAQhdEQAtrecABRQAEQAEAQhdEQAtrecABRQAAREANgcGCAwABRQ=.',['�']='月兑:AwAICAgABAoAAA==.未闻花铭:AwACCAIABAoAAA==.',['�']='杨长老:AwAECAQABRQAAA==.',['�']='柠檬很萌:AwAICAgABAoAAA==.',['�']='格格悟:AwAECAQABRQAAA==.',['�']='楓兰:AwAICAwABAoAAA==.',['�']='橙德避暑山庄:AwADCAMABAoAAA==.',['�']='次元小番茄:AwABCAIABRQCEgAIAQjtCQA3/eABBAoAEgAIAQjtCQA3/eABBAoAAQQAAAACCAIABRQ=.',['�']='此梦经年丶:AwAFCAMABRQAAA==.',['�']='汪兜兜:AwADCAMABAoAARMAPTQECAsABRQ=.',['�']='法力余烬:AwACCAUABRQDDgACAQgYJAA0LpQABRQADgACAQgYJAA0LpQABRQADwABAQhoGwAZIDAABRQAAA==.泷一圣骑:AwABCAEABAoAAQQAAAABCAEABRQ=.泷一龙人:AwABCAEABRQAAA==.',['�']='浅唱丶小情歌:AwAGCAYABAoAAA==.浅沫相思:AwADCAMABAoAAA==.浅浅泡沫:AwABCAEABRQAAA==.浮生丿若梦:AwAICBwABAoDDwAIAQisDwBWBGMCBAoADwAIAQisDwBWBGMCBAoADgAIAQjILQA6AdYBBAoAAQsAQcoGCAYABRQ=.',['�']='渡边麻友丶:AwACCAIABRQDFAAIAQgOBQBZgbgCBAoAFAAHAQgOBQBW8bgCBAoAFQAFAQhFcgBaHSkBBAoAAA==.温狄鹰羽:AwACCAIABAoAARMAPTQECAsABRQ=.',['�']='潇天若:AwAGCAYABAoAAA==.',['�']='灼炎之蝶:AwACCAIABRQAAA==.',['�']='無可奈何:AwAGCAkABAoAAA==.',['�']='爱丁堡:AwAECAQABRQAAA==.爱吃肉的小七:AwABCAIABRQCEAAIAQh9MAA188oBBAoAEAAIAQh9MAA188oBBAoAAA==.爱喜:AwAECAYABRQCCAAEAQjTGgAkVtoABRQACAAEAQjTGgAkVtoABRQAAA==.',['�']='牛德冲冲:AwAICAgABAoAAA==.牛汁巨人:AwAGCAYABRQCEwAGAQjRAAA8574BBRQAEwAGAQjRAAA8574BBRQAAA==.牧之王者十一:AwAECAQABRQAAA==.',['�']='狂之力:AwAECAQABRQAAA==.',['�']='珍娜:AwAGCAcABAoAAA==.',['�']='璨若辰星:AwACCAIABAoAAA==.',['�']='申吉尊:AwACCAIABRQAAA==.',['�']='疯狂的三娃:AwAICAgABAoAAA==.',['�']='白毛福瑞:AwACCAUABRQCCgACAQjhFgATcmEABRQACgACAQjhFgATcmEABRQAAA==.',['�']='盾盾不想被砍:AwAHCAsABAoAAA==.',['�']='真丶纳什男爵:AwABCAEABRQAAA==.',['�']='神之木鱼:AwAICAoABAoAAA==.神圣怪蜀黍:AwAECAQABRQAAA==.',['�']='福大妞:AwAECAQABRQAAA==.',['�']='秋歌:AwAFCAgABRQCDgAEAQgyEABDLvYABRQADgAEAQgyEABDLvYABRQAAA==.秋艳落落:AwAFCA8ABRQDCwAFAQj0AgA92z0BBRQACwAFAQj0AgAs1D0BBRQACgAEAQhACQA3RdIABRQAAQoAUMoICAcABRQ=.',['�']='稿纸闯天下:AwAECAMABAoAAA==.',['�']='空条徐伦:AwACCAIABRQAAA==.',['�']='精灵飞飞:AwACCAIABRQAAA==.',['�']='糯米蹄子:AwABCAEABRQAAA==.',['�']='紫桐:AwACCAIABRQDCAAIAQjYVQA7qtABBAoACAAGAQjYVQBQztABBAoAFgAHAQhtGAAw/nUBBAoAAA==.',['�']='红烧苏轼:AwAECAUABRQDFwAEAQhACAAZk90ABRQAFwAEAQhACAAZk90ABRQAGAABAQhSFQAAAAAABRQAAQQAAAAGCAQABRQ=.',['�']='羽咲绫乃:AwAECAQABAoAAA==.',['�']='翎羽:AwACCAIABAoAAA==.翼域天豪:AwABCAEABRQCGAAIAQi6CQBKu1UCBAoAGAAIAQi6CQBKu1UCBAoAAA==.',['�']='老西门龙王:AwAICBAABAoAAA==.',['�']='肉弹戦车:AwADCAMABAoAAA==.肥羊跋扈:AwACCAQABRQDFwAIAQiuCgBGETsCBAoAFwAIAQiuCgBBwzsCBAoAGAACAQhNPAA/pEUABAoAAA==.',['�']='脏牧专精:AwACCAQABRQAAA==.',['�']='芦忆晗星:AwAECAQABAoAAA==.',['�']='茶几的幻想:AwADCAMABRQAAA==.',['�']='萌萌的蕾姆:AwAECAgABRQCEAAEAQjoBABS8CkBBRQAEAAEAQjoBABS8CkBBRQAARAAQiQGCAoABRQ=.萨牧专精:AwAFCAkABAoAAA==.',['�']='蒂法使:AwAECAQABAoAAA==.',['�']='蔡森:AwAECAQABRQAAA==.',['�']='诺兹姆多:AwADCAMABAoAAA==.',['�']='贝瑟芬妮:AwAICAgABAoAAA==.',['�']='起门拉人:AwACCAIABRQAAA==.',['�']='路西欧:AwAECAQABRQAAA==.',['�']='轲特丶揍敌客:AwACCAIABRQAAA==.',['�']='输出美如畫:AwAECAQABRQAAA==.辣堡吃到饱:AwACCAIABAoAAA==.',['�']='逝去的捌零后:AwAECAQABRQCCAAIAQhFeAAt4n4BBAoACAAIAQhFeAAt4n4BBAoAAA==.',['�']='邪恶大姨妈:AwACCAIABRQAAA==.',['�']='郁闷的灵灵:AwAICAIABAoAAA==.',['�']='铁头丶娃:AwAECAQABRQAAA==.',['�']='门清杠开:AwADCAMABAoAAA==.',['�']='阿墨:AwADCAEABRQAAA==.阿脆:AwAHCBYABAoCBgAHAQgVPwAjaiIBBAoABgAHAQgVPwAjaiIBBAoAAA==.阿门汤普森:AwAECAUABAoAAA==.',['�']='陪夕阳看海:AwAECAEABRQAAA==.',['�']='零下十八度:AwACCAIABRQAAA==.',['�']='风导星歌:AwACCAIABRQAAA==.风战:AwAGCAYABAoAAA==.飘飘个飘丶:AwAECAQABRQAAA==.',['�']='饿死色:AwACCAQABRQAAA==.',['�']='马兰坡坡姐:AwAICBAABAoAAA==.',['�']='鲜血之力:AwAECAMABRQDCwAIAQhqGQBRNUICBAoACwAIAQhqGQBRNUICBAoACgAIAQhYIwAwmEABBAoAAA==.',['�']='鸦鸦:AwACCAIABAoAAA==.',['�']='黄宗泽:AwAGCAkABRQCDgAEAQghDgBKu/8ABRQADgAEAQghDgBKu/8ABRQAAA==.黑夜之妖:AwAICAgABAoAAA==.黯灭使徒:AwAICAgABAoAAA==.',['�']='龍牌酱油:AwAGCAMABAoAAA==.龘华富贵:AwAICAYABAoAAQQAAAABCAEABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end