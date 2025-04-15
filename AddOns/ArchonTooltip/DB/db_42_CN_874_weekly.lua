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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Warrior-Fury','Mage-Frost','Evoker-Devastation','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Monk-Mistweaver','Evoker-Preservation','DeathKnight-Unholy','Priest-Shadow','Priest-Holy','Shaman-Restoration','Priest-Discipline','Mage-Fire','Unknown-Unknown','Shaman-Elemental','Shaman-Enhancement','DeathKnight-Blood','DemonHunter-Havoc','Druid-Balance','Hunter-BeastMastery','DeathKnight-Frost','Rogue-Subtlety','Rogue-Assassination','Monk-Windwalker','Hunter-Marksmanship','Druid-Guardian','Paladin-Holy','Druid-Restoration','DemonHunter-Vengeance','Monk-Brewmaster',}; local provider = {region='CN',realm='雷克萨',name='CN',type='weekly',zone=42,date='2025-04-15',data={Al='Alucarde:AwACCAIABAoAAA==.',Ba='Baladin:AwAICB0ABAoDAQAIAQhWEwBhhr4CBAoAAQAIAQhWEwBhhr4CBAoAAgABAQgGXwAKdxIABAoAAA==.',Bt='Btm:AwAICBgABAoCAwAIAQgqCwBW76ICBAoAAwAIAQgqCwBW76ICBAoAAA==.',Bu='Buffret:AwAECAwABRQCAQAEAQjNAwBiPk0BBRQAAQAEAQjNAwBiPk0BBRQAAA==.',Ca='Capricornus:AwAECAQABAoAAA==.',Co='Corrections:AwAGCAIABAoAAA==.',Da='Darkbreath:AwAGCAYABAoAAA==.Darkterror:AwAICAgABAoAAA==.Darkterrora:AwACCAIABAoAAA==.',De='Deathflost:AwAECAQABRQAAA==.Dempsey:AwADCAYABRQCBAADAQgoBgBBr+8ABRQABAADAQgoBgBBr+8ABRQAAA==.Devlce:AwADCA4ABRQCBQADAQg+CQA9zO0ABRQABQADAQg+CQA9zO0ABRQAAA==.',Do='Doloreshaze:AwAFCAUABAoAAA==.',Du='Durant:AwAICAwABAoAAA==.',Dv='Dva:AwAHCA4ABAoAAA==.',Et='Ethel:AwAFCAUABAoAAA==.',Fa='Fabiola:AwAFCAkABAoAAA==.',Ga='Garricktm:AwAICAgABAoAAA==.',Gy='Gyrozeppeli:AwAECBEABRQEBgAEAQhRAQBh9hsBBRQABwADAQiRAwBh9kMBBRQABgAEAQhRAQBH7BsBBRQACAABAQhlFwBOdE4ABRQAAA==.',Hi='Hierophantr:AwAECAQABRQAAA==.',Hu='Huggingface:AwAFCBUABRQCCQAFAQjBAwA+ilUBBRQACQAFAQjBAwA+ilUBBRQAAA==.',Kc='Kcheetah:AwADCAoABRQCCgADAQhkAQBNUhQBBRQACgADAQhkAQBNUhQBBRQAAA==.',Ko='Koldira:AwAECAwABRQCCwAEAQgyBgBSwxsBBRQACwAEAQgyBgBSwxsBBRQAAA==.',Li='Lipper:AwADCAgABRQCDAADAQg6BgBP7SEBBRQADAADAQg6BgBP7SEBBRQAAA==.',Lo='Lokilo:AwAICAgABAoAAQcAUnQHCAcABRQ=.',Lu='Lunatism:AwAICAgABAoAAA==.',Ma='Magisk:AwACCAMABRQCDQAIAQgzFgBEMAMCBAoADQAIAQgzFgBEMAMCBAoAAA==.',Me='Mesiahchetah:AwAICAgABAoAAA==.',Na='Nashata:AwAGCAoABRQCDgAGAQjMAAAvB5wBBRQADgAGAQjMAAAvB5wBBRQAAA==.',No='Nothingwy:AwACCAMABAoAAA==.',On='Oneplusvable:AwADCAMABAoAAA==.',Pl='Playerlkdsys:AwAICAgABAoAAA==.',Po='Powehi:AwADCAsABRQCDwADAQjJBABX3ycBBRQADwADAQjJBABX3ycBBRQAAA==.',Ra='Rainyice:AwAICAkABAoAAA==.Ralzarek:AwADCAYABRQCEAADAQg4IgBHxqwABRQAEAADAQg4IgBHxqwABRQAAA==.',Ro='Rosé:AwAGCAoABAoAAA==.',Sc='Scav:AwAECBAABRQCEAAEAQjGDABQhBABBRQAEAAEAQjGDABQhBABBRQAAA==.',Se='Serendipity:AwACCAIABRQAAA==.',Sk='Skyze:AwAECAQABRQAAREAAAAGCAIABRQ=.',So='Soloman:AwACCAIABRQAAA==.',Su='Supervisionj:AwAECAQABAoAAA==.',Ti='Tinysuperman:AwAGCAYABAoAAQsAQ3QGCA0ABRQ=.',Un='Undyne:AwAGCAYABAoAAA==.',Vi='Vivir:AwACCAQABRQDDgAIAQiGGwBFYxQCBAoADgAIAQiGGwBFYxQCBAoAEgABAQikeQAedyQABAoAAA==.',Ye='Yearnlq:AwAECAQABRQAAA==.',Zb='Zbybr:AwAICAwABAoAAA==.',['�']='一力降十会:AwABCAEABAoAAA==.一壹一壹:AwABCAEABAoAAA==.一缕魂:AwAECAQABAoAAA==.三鹿经销商:AwAFCAUABAoAAA==.不是酒鬼:AwADCAEABRQAAA==.不知道取名:AwADCAMABAoAAA==.丨阿良丨:AwAECA0ABRQCEwAEAQhHBgBAbwwBBRQAEwAEAQhHBgBAbwwBBRQAAA==.中分头:AwAICAgABAoAAA==.丿灬冷冷:AwACCAIABRQAAA==.丿麦克丶信田:AwAECAQABRQAAA==.',['�']='乀丶辣辣:AwAECAQABRQCEAAIAQh8LgBOR9kBBAoAEAAIAQh8LgBOR9kBBAoAAREAAAAICAIABRQ=.乔娜范布伦塔:AwAICBIABAoAAA==.九折:AwAICAgABAoAAA==.也不是不可以:AwAECAQABRQDFAAIAQizFwA++rkBBAoAFAAIAQizFwA++rkBBAoACwACAQgqlAAnDXMABAoAAA==.',['�']='了不起的香香:AwAECAQABRQAAA==.云顶奶茶:AwAECAIABAoAAA==.五演祖:AwACCAEABRQCCwAIAQipDgBWEZkCBAoACwAIAQipDgBWEZkCBAoAAA==.五演祖丶:AwADCAMABAoAAA==.亚豆的抱抱枕:AwAICA8ABAoAAA==.',['�']='仲间由纪绘:AwAICAgABAoAAA==.',['�']='伊利优酸达雷:AwAGCAYABAoAAA==.伊莉佳尔:AwAECAQABRQAAA==.伊莉恬尔:AwAECAQABRQAAREAAAAICAMABRQ=.',['�']='你乜料啊:AwADCAQABAoAAA==.你喵的蛋蛋:AwADCAMABAoAAA==.你好王哥丶:AwAGCAYABRQCEAAGAQhFBQAf8XsBBRQAEAAGAQhFBQAf8XsBBRQAAA==.',['�']='做自己的赵云:AwAICBUABAoCCwAIAQg4DABUHq0CBAoACwAIAQg4DABUHq0CBAoAAA==.',['�']='光伏大师:AwAFCAoABAoAAA==.兮乐:AwAHCBEABAoAAA==.养魚:AwABCAEABRQAAA==.',['�']='军之守卫者:AwAFCAUABAoAAA==.冬泥大牧:AwAGCAMABRQCDwADAQiBEwBIrZ4ABRQADwADAQiBEwBIrZ4ABRQAAA==.冰之咏叹:AwAICAgABAoAAA==.冰羽飘然:AwAECAgABRQCAQAEAQiEBABftUQBBRQAAQAEAQiEBABftUQBBRQAAA==.',['�']='凸凸:AwAECAwABRQDAgAEAQifBQBKwesABRQAAgAEAQifBQBEcOsABRQAAQAEAQj0GABEB+sABRQAAA==.',['�']='刃语者辛娜:AwAECAwABRQCFQAEAQgxEwArzuMABRQAFQAEAQgxEwArzuMABRQAAA==.',['�']='包包儿:AwADCAMABRQAAA==.',['�']='千乄幻:AwAECBAABRQCCwAEAQhcAwBgCkMBBRQACwAEAQhcAwBgCkMBBRQAAA==.升腾好了:AwABCAEABAoAAA==.卡皮巴拉猪:AwABCAEABRQAAA==.',['�']='变过去变过来:AwACCAMABRQAAA==.只会无脑按一:AwADCAQABRQAAA==.叮叮咚咚匠:AwAECAQABAoAAA==.',['�']='吃我一闷锤:AwAICAQABAoAAA==.吔咩啦你:AwADCAMABAoAAA==.吥讲武德:AwAICAgABAoAAA==.',['�']='呕吼:AwAGCAQABRQDDAAEAQhIFQAQKpcABRQADAACAQhIFQAHlJcABRQADwACAQiaFwAtaIcABRQAAA==.命运之传说:AwAGCAYABRQDAgAEAQgBCQAqeasABRQAAgAEAQgBCQAqeasABRQAAQACAQh4PAALrVQABRQAAA==.命运之牌:AwACCAIABRQAAA==.',['�']='咕哒之子:AwEDCA0ABRQCFgADAQhlBQBX+S0BBRQAFgADAQhlBQBX+S0BBRQAAA==.',['�']='哇丶熊猫武僧:AwABCAEABRQAAA==.哈密瓜是猪:AwAGCBgABRQCEAAGAQgbBwBfqEsBBRQAEAAGAQgbBwBfqEsBBRQAAA==.哭作包:AwAHCAIABAoAAA==.',['�']='喊我妙脆角:AwAFCAUABAoAAA==.喝酒不如跳舞:AwAFCAUABAoAAA==.喵小丢丢:AwAICAgABAoAAA==.喵小丢吖:AwAFCAUABAoAAA==.喵小月:AwAICB4ABAoCFwAIAQjIcwASKDIBBAoAFwAIAQjIcwASKDIBBAoAAA==.',['�']='嗦仔:AwACCAQABAoAAA==.',['�']='嘿哈:AwAECAQABRQAAA==.',['�']='嚣丨星光:AwACCAIABAoAAA==.',['�']='四保一阿巴瑟:AwAHCBAABAoAAA==.',['�']='圣光大领主:AwABCAEABRQAAA==.圣洁列斯:AwAFCAUABAoAAA==.',['�']='塞勒沃:AwACCAIABRQAAA==.塞巴斯甜:AwACCAUABRQCEgACAQhaCwBTiLQABRQAEgACAQhaCwBTiLQABRQAAA==.',['�']='夏雪丶:AwAGCAQABRQAAA==.夏雪仪:AwABCAIABRQAAA==.夜丶魔:AwADCA4ABRQDCwADAQiqBABeEC0BBRQACwADAQiqBABYJS0BBRQAGAABAQitBgBfWEkABRQAAA==.大光头加暴击:AwABCAEABRQAAA==.大尾巴狼:AwACCAIABAoAAA==.大胡子蜀黍:AwACCAIABRQAAA==.天之翼:AwAGCAsABAoAAA==.天亡盖地虎:AwAECAQABRQAAA==.',['�']='如涞灬神掌:AwAFCAMABRQAAA==.',['�']='威廉波罗蜜多:AwAECAUABAoAAA==.',['�']='孙义疾风再步:AwAGCAIABAoAAA==.孙脐橙:AwACCAIABRQAAA==.',['�']='安卿鱼:AwAECAgABRQDGQAEAQiHBABUhAkBBRQAGQAEAQiHBAA7tgkBBRQAGgAEAQiXBgA++fsABRQAAA==.家伙僧:AwAECAQABAoAAA==.',['�']='小吖小年糕:AwADCAMABRQAAA==.少文:AwAICA4ABAoAAA==.',['�']='居丶小龙:AwAICAgABAoAAA==.',['�']='岁安:AwABCAEABAoAAA==.岄魂:AwAICAgABAoAAA==.岑丶风暴烈酒:AwACCAIABAoAARsAKkoICAYABRQ=.',['�']='島村抱月:AwAECAQABRQAAQ0AP+IICAUABRQ=.',['�']='州亲亲:AwABCAEABRQAAA==.巧克力维他奶:AwAECAUABRQDBAAEAQgpAwBHJBYBBRQABAADAQgpAwBHJBYBBRQAEAABAQhqOwAAAAAABRQAARAAQ8QICAcABRQ=.',['�']='师爷苏:AwAHCAsABAoAAA==.帕米尔:AwABCAEABRQDFwAIAQhbWwAlCn4BBAoAFwAIAQhbWwAhnX4BBAoAHAAGAQjRQAAald4ABAoAAA==.',['�']='弃置渠:AwAECAQABAoAAA==.张美美:AwAGCAoABRQDGwAGAQjoAABAPOYBBRQAGwAGAQjoAABAPOYBBRQACQAEAQj1CgBDuPgABRQAAA==.弾指红颜老:AwAGCAEABAoAAA==.',['�']='影月宿魂:AwADCA0ABRQCHQADAQhkAgAoOZEABRQAHQADAQhkAgAoOZEABRQAAA==.影灬红:AwACCAIABAoAAA==.影訫:AwAICBAABAoAAA==.',['�']='心辰:AwAICAoABAoAAA==.忆梦:AwADCBAABRQDAgADAQiwDAARNIAABRQAAgADAQiwDAARNIAABRQAHgABAQiPEwACiCoABRQAAA==.',['�']='恋爱的酸臭味:AwACCAIABAoAAA==.',['�']='懒懒空余恨:AwAHCAcABAoAAA==.',['�']='我在放水:AwAECAQABAoAAA==.战复木板:AwAFCAkABAoAAA==.戰天下:AwACCAIABAoAAA==.',['�']='拉芙希妮:AwAFCAYABAoAARUAGqwGCAcABRQ=.',['�']='揭開帷幕:AwAICAgABAoAAA==.',['�']='摯愛:AwAECAQABRQAAA==.摸鱼王阿凯:AwAHCAcABAoAAA==.',['�']='擎天小骑:AwAGCAYABRQCAQAGAQhpBAAgGUUBBRQAAQAGAQhpBAAgGUUBBRQAAA==.',['�']='文文你肿么啦:AwAHCAcABAoAAA==.',['�']='无所做为:AwACCAIABAoAAA==.',['�']='明堂小青龙:AwAICAgABAoAAA==.春风不语:AwABCAEABAoAAA==.',['�']='晨光之怒:AwACCAIABRQAAA==.晨曦载耀:AwADCAkABRQCHwADAQgwBABQ/hoBBRQAHwADAQgwBABQ/hoBBRQAAR8AOskICAgABRQ=.晴空想念:AwAGCAYABAoAAA==.',['�']='暗影贞德:AwAECAQABRQAAA==.暴食:AwAICBAABAoAAA==.',['�']='曹达华:AwAGCAYABAoAAREAAAAICAEABRQ=.',['�']='月现狼嚎:AwAHCAoABAoAAA==.月神:AwAICAgABAoAAA==.',['�']='桀骜斯达瑞:AwADCA0ABRQCAwADAQgqBABfjDsBBRQAAwADAQgqBABfjDsBBRQAAA==.',['�']='梦云千幻:AwAGCAgABRQDDQAEAQhWBABLDwsBBRQADQAEAQhWBABLDwsBBRQADwAEAQhcDgAjBswABRQAAA==.',['�']='樱桃寿司:AwAECBAABRQDAQAEAQiUCwBaxxcBBRQAAQAEAQiUCwBaxxcBBRQAAgABAQiLGAABkRIABRQAAA==.',['�']='橙血骑士:AwAECAgABRQCAQAEAQjbBgBbRi8BBRQAAQAEAQjbBgBbRi8BBRQAAA==.橡树果:AwAECAQABRQAAA==.',['�']='死丶瑞文戴尔:AwAGCAsABAoAAA==.死骑死骑哟:AwADCAsABRQDCwADAQgyGQAyF5sABRQACwACAQgyGQAssZsABRQAFAACAQgVFgAnWngABRQAAA==.',['�']='水月天:AwAICAgABAoAAA==.',['�']='汐丶咲:AwADCAsABRQCFAADAQjBFAALxYIABRQAFAADAQjBFAALxYIABRQAARwAWREGCBcABRQ=.江上听风:AwAICAgABAoAAA==.江烟万缕:AwADCAwABRQDGwADAQiyAgBhVFMBBRQAGwADAQiyAgBhVFMBBRQACQABAQgVIwAeTkkABRQAAA==.',['�']='波音:AwAICA4ABAoAAA==.泰岚德:AwAICAsABAoAAA==.',['�']='流年丨缥缈:AwAECAQABAoAAA==.海上钢琴诗:AwADCAQABAoAAA==.海绵祖宗:AwABCAEABRQAAA==.',['�']='添乐蚂蚱:AwAECAIABRQAAA==.',['�']='渺渺兮予怀:AwADCAcABRQDEAADAQi5CwBVjxcBBRQAEAADAQi5CwBUjhcBBRQABAABAQjIFwBeukMABRQAAA==.',['�']='湮灭老毕登:AwEICAoABAoAARYAV/kDCA0ABRQ=.',['�']='溏悠悠:AwAFCAUABAoAAA==.',['�']='潇洒哥来了:AwACCAQABRQCDQAIAQgpHQA13s8BBAoADQAIAQgpHQA13s8BBAoAAA==.',['�']='灰黑的白:AwABCAEABRQCAQAIAQhuXAA0j8oBBAoAAQAIAQhuXAA0j8oBBAoAAA==.灵幻风影:AwADCAcABRQDDAADAQi9CwA3EeoABRQADAADAQi9CwA3EeoABRQADQABAQi6IAASkTQABRQAAA==.灵犀之芸:AwABCAEABAoAAA==.',['�']='無邪:AwAGCAYABAoAAREAAAAGCAQABRQ=.',['�']='爬爬鸭:AwAFCAUABAoAAA==.爱水群的阿懒:AwABCAEABRQAAA==.',['�']='特里:AwADCAQABRQCHwAIAQj+EgBG4xICBAoAHwAIAQj+EgBG4xICBAoAAA==.',['�']='玄天宗:AwAICA4ABAoAAA==.玛琪玛:AwABCAIABRQDGQAHAQj/EwBFYa4BBAoAGQAHAQj/EwBD+a4BBAoAGgACAQg0NABFQIYABAoAAA==.',['�']='球球麻麻:AwAECAoABRQDEgAEAQhLBABMIQoBBRQAEgAEAQhLBABMIQoBBRQADgACAQgIIwAHC2wABRQAAA==.',['�']='疯狂原始人:AwADCAMABAoAAA==.疯狂屠夫:AwADCAEABAoAAA==.疯狂屠戮者:AwADCAMABAoAAA==.',['�']='皓匀京墨:AwAICAIABAoAAA==.',['�']='眀空:AwADCAkABRQCDwADAQgJBgBSoBYBBRQADwADAQgJBgBSoBYBBRQAAA==.真的好贱丶:AwAECAQABRQAAA==.眩暈:AwAECAQABAoAAA==.眼瞎瞎:AwAFCBUABRQCIAAFAQj1CQAEhJ0ABRQAIAAFAQj1CQAEhJ0ABRQAAA==.',['�']='破冰之炎:AwAECAQABRQAARAAMkEGCAgABRQ=.',['�']='神之净土:AwAHCAkABAoAAA==.神圣忽悠:AwAECAQABAoAAQMAM3kDCA0ABRQ=.神奇小猫咪:AwAGCAIABRQAAA==.',['�']='秀兰:AwAGCAYABAoAAA==.秋雨:AwAFCAYABAoAAA==.',['�']='稀硫酸:AwAGCAIABAoAAA==.',['�']='筱竹雨荷:AwAICAwABAoAAA==.筷子毓毓:AwAICA4ABAoAAREAAAAGCAQABRQ=.',['�']='米尼:AwABCAEABAoAAA==.',['�']='精灵宅女:AwAICBsABAoDHAAIAQhYNQBKmxsBBAoAHAAGAQhYNQBSExsBBAoAFwAIAQiH6ABExD4ABAoAAA==.',['�']='素月乄墨羽:AwABCAEABAoAAA==.',['�']='维多利亚秘密:AwAICAgABAoAAA==.绿毛虫:AwABCAEABRQCAwAIAQjACwBZcZwCBAoAAwAIAQjACwBZcZwCBAoAAA==.绿眼怪:AwADCAEABAoAAA==.',['�']='羊肉粉汤:AwAHCAUABAoAAA==.美美张:AwAECAQABRQAAREAAAAICAQABRQ=.',['�']='老衲醉了:AwAGCAoABRQCFAAGAQjVAQAr2GgBBRQAFAAGAQjVAQAr2GgBBRQAAA==.',['�']='聒噪小教主:AwAECAQABRQAAA==.',['�']='肥尼科斯:AwADCA8ABRQCFwADAQiFCgBVNxsBBRQAFwADAQiFCgBVNxsBBRQAAA==.肯德基爷爷:AwAGCAwABAoAAA==.',['�']='胖大力:AwADCAgABRQCGwADAQhNCAA5Z/EABRQAGwADAQhNCAA5Z/EABRQAAA==.能量灌注丶:AwAFCAcABAoAAA==.',['�']='芊芊小妹:AwAECAQABAoAAA==.',['�']='苹果萌狼:AwAECAQABRQAAA==.',['�']='莫格萊昵:AwAECAQABRQAAA==.',['�']='蒂蒂:AwAICAMABAoAAA==.蒙蒂丶怒语:AwAICAgABAoAAA==.',['�']='蓝希尔:AwAFCAMABAoAAA==.',['�']='蔷薇雨夜潇湘:AwACCAEABAoAAA==.',['�']='薛棣凯:AwAECAUABRQCFAAEAQhWDAAyhb8ABRQAFAAEAQhWDAAyhb8ABRQAAA==.',['�']='虎哇虎哇噜:AwADCBAABRQDGgADAQhYAgBe/UoBBRQAGgADAQhYAgBe/UoBBRQAGQABAQgjEQApnEAABRQAAA==.',['�']='蜜汁烤翅:AwAICAgABAoAAA==.',['�']='血龙吟:AwAGCAYABAoAAA==.',['�']='西红柿丨红手:AwACCAQABRQAAA==.西维尔丶星辰:AwAICA4ABAoAAA==.',['�']='踏风揽云:AwADCAsABRQDGwADAQiCBwBS7voABRQAGwADAQiCBwBFCPoABRQAIQADAQjBAgBEqMsABRQAAA==.',['�']='迷途猫:AwADCAMABAoAAA==.',['�']='逗逗豆豆:AwABCAEABRQAAA==.',['�']='遇术临疯:AwAECAoABRQDCAAEAQh4BwA5P+cABRQACAAEAQh4BwAtB+cABRQABwAEAQjJDAAy3uUABRQAAREAAAAGCAQABRQ=.',['�']='那个灬胖纸:AwAECAIABRQAAA==.',['�']='部落来了:AwAICAgABAoAAA==.',['�']='酒墩墩:AwADCAEABRQAAA==.',['�']='重生的小天歌:AwAECAQABAoAAA==.',['�']='鈞鈞:AwAECAgABRQDFwAEAQglCgBZ/h0BBRQAFwAEAQglCgBReR0BBRQAHAAEAQi/BwA2yfEABRQAAA==.',['�']='铁锅炖大讷:AwABCAEABRQAAA==.',['�']='阿凯:AwAGCAYABAoAAA==.阿卜:AwAECAUABAoAAA==.阿泽瑞:AwAICAgABAoAAA==.',['�']='陈嘉:AwAGCAEABAoAAA==.陈掌柜:AwAICAYABAoAAA==.陈文锦丿:AwADCAwABRQDDQADAQhLBwBEAugABRQADQADAQhLBwBEAugABRQADwACAQiiHAAGL2EABRQAAA==.',['�']='雅戈布丶:AwADCAsABRQCEgADAQieBwA3DOUABRQAEgADAQieBwA3DOUABRQAAA==.雨之露:AwAFCAUABAoAAA==.雪风:AwAGCAcABRQCFQAGAQglAwAarIgBBRQAFQAGAQglAwAarIgBBRQAAA==.雷柯娜:AwAGCAYABAoAAA==.雾夜战神:AwAFCAUABAoAAA==.',['�']='霜雪成坛:AwABCAEABRQAAA==.霸气雨露:AwACCAIABRQAAA==.',['�']='青玄僧:AwAFCAUABAoAAA==.',['�']='风中沙:AwAECAIABAoAAA==.风丶暴:AwAECAUABAoAAA==.风元:AwAECAQABAoAAA==.飞天猴子:AwAECAQABRQAAA==.飞鱼:AwADCAMABAoAAA==.',['�']='香菜一生推:AwAECAkABRQCBwAEAQjHBgBSsRMBBRQABwAEAQjHBgBSsRMBBRQAAA==.',['�']='鬼魅灬落落:AwAHCAcABAoAAA==.鬼魅灬颖:AwAICAYABAoAAA==.',['�']='鸡哥一直饮:AwAECAQABAoAAA==.',['�']='鹏抟九万:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end