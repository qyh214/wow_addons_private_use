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
 local lookup = {'Unknown-Unknown','Paladin-Protection','Paladin-Retribution','Shaman-Enhancement','Rogue-Assassination','Rogue-Subtlety','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Mage-Fire','Priest-Shadow','Druid-Balance','Druid-Restoration','Priest-Holy','Priest-Discipline','Paladin-Holy','Mage-Frost','DeathKnight-Blood','DeathKnight-Unholy','Warrior-Protection','Hunter-Marksmanship','Hunter-BeastMastery','Warrior-Fury','DemonHunter-Havoc','Monk-Mistweaver','Druid-Guardian','Shaman-Restoration',}; local provider = {region='CN',realm='战歌',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ad='Adicj:AwAECAQABRQAAA==.',Al='Alexstra:AwAECAUABAoAAA==.',An='Anticlimax:AwAECAQABAoAAA==.',Aw='Aw:AwABCAIABRQAAA==.',De='Deepwinter:AwAGCAoABAoAAA==.',Eg='Ego:AwAICAQABAoAAA==.',Fr='Frubick:AwABCAEABRQAAA==.',La='Ladly:AwABCAEABRQAAQEAAAAECAQABRQ=.',No='Nozzlewhite:AwAECAQABRQAAA==.',Ti='Tirionfordin:AwAICBYABAoDAgAIAQiuCQBQdEgCBAoAAgAIAQiuCQBNMkgCBAoAAwAIAQh7agA/pp4BBAoAAA==.',['�']='一只豆饼:AwAECAQABRQAAA==.一戈大香蕉:AwAICAgABAoAAA==.一颗牛奶糖:AwADCAMABRQAAQQAM3YICAkABRQ=.丁晓旭:AwACCAEABRQAAA==.七海娜娜米:AwAGCAYABRQDBQACAQgDDAAvcqMABRQABQACAQgDDAAvcqMABRQABgACAQgGDAAXgI8ABRQAAA==.三十六季稻:AwAICAgABAoAAA==.上丄谛:AwAICAgABAoAAA==.不准念诗:AwABCAEABAoAAA==.不知秋冬:AwAICAgABAoAAA==.东北纯爷们:AwACCAIABAoAAA==.东南西北风:AwACCAQABRQAAA==.丨喜喜丨:AwAICAgABAoAAA==.丨忘语丨:AwADCAMABRQAAA==.丨救赎:AwABCAEABRQAAA==.丨某某人丨:AwADCAMABAoAAA==.丨焱丨:AwAICAgABAoAAA==.丨相忘:AwACCAIABAoAAA==.丶乖乖不闹了:AwAHCAkABAoAAA==.丶方长:AwAECAQABAoAAA==.丶辣个劣人丶:AwAECAIABRQAAA==.丶阿灵:AwAICAQABRQAAA==.丶风云破晓:AwACCAIABRQAAA==.丷圆滚滚:AwAICAEABAoAAA==.为你褪去衣裳:AwAECAQABRQAAA==.',['�']='乐动魔方:AwABCAEABRQAAA==.',['�']='争取早日三修:AwAGCAoABAoAAA==.二队萨满:AwAICAgABAoAAA==.于博野父:AwAECAQABRQAAA==.云丶:AwADCAMABAoAAA==.五月夏木:AwAECAQABRQAAA==.',['�']='仰中的怒风:AwAGCAQABAoAAA==.',['�']='伊利牛奶蛋蛋:AwAECAQABAoAAA==.伍子之歌:AwAECAQABRQAAA==.',['�']='你或像你的人:AwAGCAkABAoAAA==.',['�']='假面骑士剑:AwAHCAcABAoAAA==.',['�']='全职小德:AwAICAgABAoAAA==.',['�']='冰乂皇:AwAGCAYABAoAAA==.冰冻我心:AwAGCA8ABRQCAwAGAQjPAABCy8MBBRQAAwAGAQjPAABCy8MBBRQAAA==.冲锋的猪仔:AwAECAYABRQEBwAEAQgJEgA0XrkABRQABwADAQgJEgAV1rkABRQACAACAQiiCwBDTaoABRQACQABAQj5FQAAAAAABRQAAA==.',['�']='刀剑如梦:AwAGCAcABAoAAA==.别人叫我肥猪:AwABCAEABRQAAA==.',['�']='叁嵗就很拽:AwADCAUABRQCAwADAQifHQAUc8oABRQAAwADAQifHQAUc8oABRQAAA==.古月方源:AwABCAEABRQAAA==.叮铃铃当:AwAECAQABRQAAA==.史丨老丨板:AwAICAoABAoAAQoAPU4ICAkABRQ=.',['�']='吉米暴德血骑:AwAICAgABAoAAA==.吟唱黑暗:AwAFCAYABAoAAA==.听话:AwACCAIABRQAAQsAS+0GCAYABRQ=.',['�']='呆毛王:AwACCAIABRQDAgAIAQgAEABFk+EBBAoAAgAIAQgAEAA9heEBBAoAAwAHAQiIiQA2pFYBBAoAAA==.呈呈子:AwAECAUABRQDDAADAQh6DwAt5+gABRQADAADAQh6DwAt5+gABRQADQACAQgqFwAC80wABRQAAA==.',['�']='咩咩欣:AwAGCAQABRQAAA==.咪兰多琳娜:AwACCAMABRQAAA==.',['�']='喵丶十一:AwAECAQABRQAAA==.',['�']='嘿丶牛魔:AwACCAIABRQAAA==.',['�']='园园:AwAICBAABAoAAA==.',['�']='地精萨满萨:AwABCAEABAoAAA==.',['�']='夜旅人:AwAGCAgABAoAAA==.大公:AwAECAQABRQAAA==.大故事家丶:AwABCAEABAoAAA==.大梓蜀黍:AwACCAIABAoAAA==.大红手欢少:AwABCAEABRQAAA==.大臭丶:AwABCAEABAoAAA==.天下无双:AwAHCBEABAoAAA==.天空的城:AwAICAgABAoAAA==.',['�']='奥拉维亚:AwAECAQABRQAAA==.',['�']='子夜烟花:AwAICAgABAoAAA==.学走猫步滴鱼:AwADCAkABRQCDgADAQhEBwA9NuEABRQADgADAQhEBwA9NuEABRQAAA==.',['�']='宏晔大魔王:AwAECAQABRQAAQwAVtkGCAcABRQ=.宫胁咲良:AwAGCAYABAoAAA==.',['�']='小丶软:AwAGCBEABAoAAA==.小双辫:AwACCAQABRQAAA==.小奶橘:AwAICA4ABRQCDwAGAQh3AQBNRYMBBRQADwAGAQh3AQBNRYMBBRQAAA==.小情伤:AwADCAMABRQAAA==.小情调:AwAECAIABRQAAQwAQiQGCAoABRQ=.小暗人:AwABCAEABAoAAA==.小桐妹妹丶:AwAICA4ABAoAAA==.小清欢:AwAGCAYABAoAAA==.小爱:AwAHCAcABAoAAA==.小牛蹄:AwACCAIABRQAAA==.小猫灵:AwACCAQABRQAAA==.小瓶起儿:AwAGCAYABAoAAA==.小米灬:AwAICAgABAoAAA==.小萨吉米:AwACCAIABRQAAQEAAAAGCAQABRQ=.小蟲丶:AwAECAgABRQDEAAEAQh7BgAcfNEABRQAEAAEAQh7BgAcfNEABRQAAwACAQjdOAAeuU4ABRQAAA==.小豆瓣:AwACCAIABRQAAA==.尼莫来咯:AwAECAQABRQAAA==.',['�']='山口山:AwAICAYABAoAAA==.',['�']='库瑞儿:AwAICAgABAoAAA==.',['�']='弄你一身血:AwACCAIABRQAAA==.强效面包精华:AwAICBYABAoDCgAIAQj7MQBDaL8BBAoACgAIAQj7MQAvb78BBAoAEQAGAQjVOABI+FsBBAoAAA==.',['�']='微笑的迪妮莎:AwAECAQABRQDEgAIAQgHHgA2tG8BBAoAEgAIAQgHHgA2tG8BBAoAEwAGAQgvdQAOwLYABAoAARIAY3oICAoABRQ=.德云社灬:AwAECAQABRQAAA==.',['�']='感受这啊:AwABCAEABAoAAA==.愤怒的绵羊丶:AwAGCAkABAoAAA==.愤怒的英子:AwAICAgABAoAAA==.',['�']='我想宠宠你:AwAICAgABAoAAA==.我爱丁丁宁:AwADCAMABAoAAA==.戒律:AwABCAIABRQEDgAIAQihHwA6UbcBBAoADgAIAQihHwA5VrcBBAoACwAHAQiJIQA106IBBAoADwADAQjXXgAXKHwABAoAAA==.战复冲钅释放:AwAICBYABAoCFAAIAQhOEgAovmEBBAoAFAAIAQhOEgAovmEBBAoAAA==.',['�']='所罗门:AwAECAQABRQCAwAIAQgnKQBT+lwCBAoAAwAIAQgnKQBT+lwCBAoAAA==.',['�']='抄底英特尔:AwAECAQABRQAAA==.披这凉皮的糖:AwAECAQABRQAAA==.',['�']='挑灯摸蛋:AwAECAQABRQAAA==.',['�']='摸鱼专用一号:AwAECAQABRQAAA==.',['�']='故事比酒多:AwAICBUABAoCEQAIAQguHwA2buwBBAoAEQAIAQguHwA2buwBBAoAAA==.',['�']='新大陆的白风:AwADCAYABRQDFQADAQjdCgAw+dAABRQAFQADAQjdCgAvdtAABRQAFgABAQi9OQAhcEUABRQAAA==.新菊苣:AwAGCAYABAoAAA==.',['�']='无名的魂:AwAGCAwABAoAAA==.',['�']='昭宇:AwAICA8ABAoAAQEAAAAGCAIABRQ=.',['�']='晓曼:AwAICAgABAoAAA==.',['�']='木槿:AwADCAoABRQDFAADAQicAgA68d8ABRQAFAADAQicAgA68d8ABRQAFwABAQhCJgAQwTsABRQAAA==.术业丿有专攻:AwAGCAQABRQAAQEAAAAICAIABRQ=.',['�']='杨贝贝:AwAICAgABAoAAA==.東方餡掛炒飯:AwAECAQABRQAAA==.',['�']='果子果:AwAICBAABAoAAA==.枫桥灬:AwACCAMABRQAAA==.枫魅:AwACCAQABRQCAwAIAQh8GQBX650CBAoAAwAIAQh8GQBX650CBAoAAA==.枯梧桐:AwAGCAYABRQCDwAGAQgNAQAzhKoBBRQADwAGAQgNAQAzhKoBBRQAAA==.',['�']='某某人乀:AwACCAQABRQAAA==.某某人摸鱼版:AwAECAEABAoAAA==.',['�']='桃子几两:AwACCAQABRQAAA==.',['�']='毒丨药:AwACCAIABRQAARIAUMoICAcABRQ=.比列海灵顿:AwAICAgABAoAAA==.',['�']='水哥不语:AwAICAMABAoAARgAEAgECAYABRQ=.永强:AwAECAUABRQDEwAEAQh8BQBJdRoBBRQAEwAEAQh8BQBJdRoBBRQAEgABAQi+GwAbojYABRQAAA==.永濑唯:AwAGCAYABAoAAA==.',['�']='汉地神牛:AwACCAIABRQAAA==.',['�']='沉着专注冷静:AwAICBAABAoAAA==.沙漠蔷薇:AwAICBsABAoCFwAIAQhKIgBFDO8BBAoAFwAIAQhKIgBFDO8BBAoAAA==.没菜扣肉:AwAGCAQABRQCGQAEAQjkDAAt2uQABRQAGQAEAQjkDAAt2uQABRQAAA==.没错就是我:AwAICAgABAoAAA==.沧月冰心:AwAECAQABRQAAA==.',['�']='泥巴巴:AwAGCAkABAoAAA==.',['�']='洛丹伦的钟声:AwADCAMABAoAAA==.',['�']='深海守护者:AwAECA0ABRQCGQAEAQicBQBWBSEBBRQAGQAEAQicBQBWBSEBBRQAAA==.淼淼灬:AwACCAIABAoAAA==.',['�']='清雅龙吟:AwABCAIABRQAAA==.',['�']='湖北第一深情:AwAECAQABRQAAQEAAAAICAQABRQ=.',['�']='溯海:AwADCAMABAoAAA==.',['�']='灬大肘子灬:AwAFCAUABAoAAA==.灵威仰:AwADCAMABRQAAA==.灵魂之力量:AwAICBAABAoAAA==.',['�']='焱焱:AwAICAMABAoAAA==.',['�']='熊小猫:AwABCAEABRQAAA==.',['�']='犹二:AwAGCAEABAoAAA==.',['�']='狂乱的小鸟:AwADCAwABRQCGgADAQhlAgAdoYcABRQAGgADAQhlAgAdoYcABRQAAA==.狂猛萨神:AwADCAMABAoAAA==.狂飙的蜗牛:AwAICAgABAoAAA==.独唱悲伤:AwAECAEABRQCGwAIAQiSKgA37rsBBAoAGwAIAQiSKgA37rsBBAoAAA==.',['�']='猎隐:AwAECAQABRQAAQEAAAAICAIABRQ=.猫婉:AwADCAMABAoAAA==.猫斯拉:AwAHCAkABAoAAA==.',['�']='王子面:AwAFCAEABRQAAA==.',['�']='球球的爸爸:AwAECAQABAoAAA==.琅琊一恶:AwAECAQABRQAAA==.理想之殇:AwACCAIABRQAAA==.琉璃灬:AwAGCAYABAoAAA==.',['�']='璎珞流苏丶:AwAECAMABRQAAA==.',['�']='瓦隆:AwAGCAYABRQCEgAGAQjfAAA7Kp4BBRQAEgAGAQjfAAA7Kp4BBRQAAA==.',['�']='白茉茉:AwAECAMABAoAAA==.',['�']='盛灬开:AwAICAEABAoAAA==.',['�']='破天斩月:AwAICAgABAoAAQEAAAAGCAQABRQ=.',['�']='神圣救赎:AwACCAEABAoAAA==.',['�']='福报小骑妹:AwAICAoABAoAAA==.',['�']='秘密搜查官:AwACCAIABRQAAA==.',['�']='空白四:AwAICBQABAoCAwAIAQjzLwBJNEICBAoAAwAIAQjzLwBJNEICBAoAAA==.',['�']='窝德跌:AwABCAEABRQAAA==.',['�']='第五个魔方:AwAGCAYABAoAAA==.',['�']='米宝风暴烈酒:AwACCAIABRQAAA==.米拉侨沃维奇:AwAECAQABAoAAA==.米迦勒之界:AwAGCAYABRQDDAAGAQhwCwA3TvoABRQADAAEAQhwCwA7UPoABRQADQACAQgoCgAxSrkABRQAAA==.',['�']='红色:AwAECAQABAoAAA==.纪亿琳的时光:AwAGCAEABAoAAA==.',['�']='罪木蜜柑丶:AwACCAcABRQCDgACAQjrDQA77JwABRQADgACAQjrDQA77JwABRQAAA==.',['�']='老山羊:AwAECAQABRQAAA==.',['�']='聖丶小龍:AwAGCA4ABAoAAA==.',['�']='肥鸟:AwACCAIABRQAAA==.',['�']='胖子丶血邪:AwABCAEABRQAAA==.',['�']='芸如:AwAGCAYABRQCDAAGAQgEAQAs6KMBBRQADAAGAQgEAQAs6KMBBRQAAA==.',['�']='苍蓝之野:AwAICBAABAoAAA==.苦涩的奶油:AwAGCAgABAoAAA==.',['�']='荒芜之影:AwAICAEABAoAAA==.荣耀:AwAICAgABAoAAA==.',['�']='菠萝灬吹雪:AwAGCAYABAoAAA==.',['�']='萨小满:AwABCAIABRQAAA==.落叶随风:AwACCAIABAoAAA==.',['�']='蒂福斯基:AwACCAMABRQAAA==.',['�']='蓶媄洏醉:AwAGCAYABAoAAA==.',['�']='蔑魔巴风特:AwAFCAkABAoAAA==.',['�']='血色女法:AwAHCAkABAoAAA==.',['�']='袭刃乱击真君:AwAICAEABAoAAA==.',['�']='裁决女神:AwACCAIABRQAAA==.裂锋:AwAGCAQABRQAAA==.',['�']='西八儿:AwAECAIABAoAAQEAAAAICAQABAo=.西格弗洛德:AwADCAcABRQDCQADAQgLBAA00bQABRQACQACAQgLBABKv7QABRQABwACAQiFGgAaiX8ABRQAAA==.',['�']='见叶知秋:AwAECAQABRQAAA==.',['�']='贫道丶姓许:AwAICA4ABAoAAQEAAAAGCAMABRQ=.贫道从不食素:AwACCAIABRQAAA==.费恩:AwADCAMABRQAAA==.',['�']='路路饿了:AwAICAgABAoAAA==.',['�']='转来转去:AwACCAIABRQAAA==.轸水蚓:AwAGCAsABAoAAA==.',['�']='迪文:AwAECAQABRQAAA==.',['�']='那个男人来了:AwABCAEABAoAAA==.那你报警吧:AwAICAIABAoAAA==.',['�']='锤子抡不动:AwAECAcABAoAAA==.',['�']='闪耀的苍蓝星:AwAECAYABRQDBwAEAQiGEQAer70ABRQABwAEAQiGEQAZA70ABRQACAABAQhcGAAe10cABRQAAA==.',['�']='阿薩斯的救赎:AwAECAQABRQAAA==.',['�']='隔壁王叔叔:AwABCAEABRQAAA==.隔壁王老铁:AwABCAIABRQAAA==.',['�']='雷加蒂娅:AwAICBoABAoDAgAIAQjMEAA/8NQBBAoAAgAIAQjMEAA8TtQBBAoAAwAIAQincgAtSIsBBAoAAA==.雷神乔帮主:AwAGCAwABAoAAA==.雾屿寒川丶:AwAGCAYABAoAAA==.',['�']='静待:AwACCAMABRQAAA==.',['�']='风来:AwACCAIABRQAAA==.飞翔的牛牛:AwAICAgABAoAAA==.',['�']='饮马渡秋水:AwACCAIABRQAAA==.饮马瀚海:AwACCAIABRQAAA==.饿了奶奶:AwAHCBMABAoAAA==.',['�']='骑士丅:AwAICBIABAoAAA==.',['�']='魔法披风:AwAGCAgABAoAAA==.',['�']='鱼圆椰奶冻丶:AwACCAMABRQAAA==.',['�']='麒麟沫沫:AwACCAIABAoAAA==.',['�']='黃金閃光:AwAGCAgABRQCAgAEAQhSBwAuJ7oABRQAAgAEAQhSBwAuJ7oABRQAAA==.黄队长:AwAICAgABAoAAA==.黒暗遊俠:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end