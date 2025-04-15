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
 local lookup = {'Paladin-Retribution','Paladin-Holy','DeathKnight-Blood','DemonHunter-Havoc','Warlock-Destruction','Paladin-Protection','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','Warrior-Arms','Warrior-Protection','Evoker-Devastation','Druid-Balance','Druid-Restoration','Rogue-Subtlety','DemonHunter-Vengeance','Monk-Windwalker','DeathKnight-Frost','Unknown-Unknown','Druid-Guardian','Warlock-Affliction','Rogue-Assassination','Warrior-Fury','Mage-Fire',}; local provider = {region='CN',realm='白骨荒野',name='CN',type='weekly',zone=42,date='2025-04-14',data={Aa='Aatrox:AwABCAEABRQAAA==.',Ad='Aduntoridas:AwAECAYABRQDAQAEAQixGwAcw9YABRQAAQAEAQixGwAcw9YABRQAAgACAQgbCABMYbIABRQAAA==.',Ga='Gavv:AwAECAcABRQCAQAEAQiMCABRth8BBRQAAQAEAQiMCABRth8BBRQAAA==.',Hi='Highfly:AwAGCAcABAoAAA==.',In='Interstellar:AwAHCA0ABAoAAA==.',Ka='Kabuto:AwAECAQABRQAAA==.',Li='Lichkiller:AwABCAIABRQCAwAIAQiXEQBEBfgBBAoAAwAIAQiXEQBEBfgBBAoAAA==.',Ma='Maxx:AwADCAUABRQCBAADAQiODgAzE/MABRQABAADAQiODgAzE/MABRQAAA==.',Mi='Micallzz:AwAICA0ABAoAAA==.Missterri:AwACCAIABRQCBQAGAQj0OAA/UGwBBAoABQAGAQj0OAA/UGwBBAoAAA==.',Sh='Showpal:AwAECAoABRQDAQAEAQgmHwA4ZMEABRQAAQADAQgmHwBQwcEABRQABgABAQgbFgAHqx4ABRQAAA==.',Te='Teio:AwAECAQABRQAAA==.',To='Tobeapet:AwABCAEABRQAAA==.',Xe='Xezz:AwAECAIABAoAAA==.',Za='Zark:AwAECAQABRQAAA==.',['�']='一粒旦旦丶:AwAICAkABAoAAA==.不知冬:AwACCAIABAoAAA==.不能说的秘密:AwAECAQABRQAAA==.不问余音:AwAICA4ABAoAAA==.丛林猎手:AwAECAUABRQDBwAEAQjZLgAZOHYABRQABwADAQjZLgADjHYABRQACAACAQg6FwBBzE4ABRQAAA==.丶及时行乐:AwACCAMABRQAAA==.丶皮卡丘:AwAICA0ABAoAAA==.丶青青子衿丶:AwAICAgABAoAAA==.',['�']='乃大富:AwACCAIABRQAAA==.么么哒丿:AwAICA8ABAoAAA==.',['�']='二狗战:AwABCAEABRQAAA==.',['�']='仧莘脏:AwACCAQABRQAAA==.',['�']='传说小老头:AwAHCAUABAoAAA==.伤透灬:AwAGCAIABRQAAA==.',['�']='你微笑丶好美:AwAICA8ABAoAAA==.',['�']='依依丶:AwACCAMABRQAAA==.',['�']='信息科:AwAECAYABRQCBgAEAQhFBABL5P8ABRQABgAEAQhFBABL5P8ABRQAAA==.',['�']='倚楼听风雨丶:AwACCAIABRQAAA==.',['�']='光头脸会好:AwAICA0ABAoAAA==.六边形:AwAFCAUABAoAAA==.',['�']='冰丶心:AwAECAcABAoAAA==.',['�']='凝氷统帅:AwAECAoABRQDCQAEAQjoCgAxofIABRQACQAEAQjoCgAxofIABRQAAwACAQiJFwAT41sABRQAAA==.凶残的萝卜:AwADCA4ABRQDCgADAQhqBAAvkvIABRQACgADAQhqBAAvkvIABRQACwABAQhwCgAcmzoABRQAAA==.',['�']='别教:AwAICAgABAoAAA==.刺暗:AwACCAIABRQAAA==.',['�']='半窗残阳:AwAHCAcABAoAAA==.',['�']='反方向的钟:AwAECAQABRQAAA==.古龍:AwACCAIABRQCDAAIAQhJCgBRcW4CBAoADAAIAQhJCgBRcW4CBAoAAA==.古龙弱闪光:AwAGCAYABAoAAA==.',['�']='吃俺一大棒:AwAECAoABRQCDQAEAQiJDQA1+PAABRQADQAEAQiJDQA1+PAABRQAAA==.',['�']='喂吧呀:AwABCAEABRQAAA==.喧嚣的小青春:AwAHCAMABAoAAA==.',['�']='四枫院丨夜一:AwADCAMABAoAAA==.',['�']='坎斯落羽:AwAECAEABAoAAA==.坠入深渊:AwADCAMABRQAAA==.坤坤姬拟钛镁:AwAECAQABRQAAQ4AOskICAgABRQ=.',['�']='堕落的哀号:AwAECAQABRQAAA==.',['�']='大鱼灬:AwACCAIABRQAAQwAXZEICAwABRQ=.天台微凉丶:AwAICAYABAoAAA==.天才:AwAECAQABRQDBwAIAQiZGgBTW3cCBAoABwAIAQiZGgBTW3cCBAoACAAIAQheLAAfQUYBBAoAAA==.',['�']='奈小多:AwABCAEABRQAAA==.奏是那道光:AwAGCAYABAoAAA==.',['�']='如影丶随形:AwACCAIABAoAAA==.妖帝丶:AwAECAgABRQCAQAEAQikCABYOB8BBRQAAQAEAQikCABYOB8BBRQAAA==.',['�']='孽徒空劝:AwAECAQABRQAAA==.',['�']='寒风清扬:AwAICAoABAoAAA==.',['�']='小鱼丶:AwAECAIABRQAAA==.尕丷熙:AwAGCAMABRQAAA==.',['�']='差点諟帥謌:AwABCAEABAoAAA==.',['�']='强良:AwAICBwABAoDCQAIAQjIPAAyeokBBAoACQAIAQjIPAAqW4kBBAoAAwAIAQhrIwAjnD8BBAoAAA==.',['�']='忧伤的小鳖:AwAGCAQABRQAAA==.',['�']='怒丶望月梦寐:AwABCAEABAoAAA==.',['�']='憨包:AwAECAQABAoAAA==.',['�']='我才是真帅:AwAGCAMABAoAAA==.我还没准备好:AwABCAEABRQAAA==.我非杯茶:AwAECAYABRQCDQAEAQh6DQA34PAABRQADQAEAQh6DQA34PAABRQAAA==.',['�']='扎克里亚斯:AwAECAYABRQCBwAEAQh4FwAuatoABRQABwAEAQh4FwAuatoABRQAAA==.',['�']='护叔宝:AwAICBAABAoAAA==.',['�']='提外奥弗丁:AwABCAEABRQAAA==.',['�']='摩莉尔:AwABCAEABRQAAA==.',['�']='无芯眷恋:AwAICAgABAoAAA==.',['�']='昔年种柳:AwABCAEABRQAAQ8AKnMGCAUABRQ=.春江花月:AwAHCAkABAoAAA==.',['�']='晓精灵:AwACCAIABRQAAA==.',['�']='暮丶雨:AwAECAYABRQCEAAEAQjwCwAI5XwABRQAEAAEAQjwCwAI5XwABRQAAREAIYsICAYABRQ=.',['�']='月之斩:AwACCAIABRQAAA==.朽木露琪娅:AwACCAIABRQAAA==.',['�']='条野太郞:AwACCAIABAoAAA==.東芳集团经理:AwAECAQABRQAAA==.',['�']='柠檬海:AwAGCAIABAoAAA==.',['�']='梦鹿非鱼丶:AwABCAIABRQECQAIAQgpNABBrK8BBAoACQAHAQgpNABKh68BBAoAEgAHAQgQEQA211cBBAoAAwADAQiOWAAFNi8ABAoAAA==.',['�']='榴莲胖胖橘:AwACCAIABRQAAA==.',['�']='樱吹诗楟:AwAICAgABAoAAA==.',['�']='武大郎:AwABCAEABAoAAA==.',['�']='泰蕾希雅:AwAECAQABRQAAA==.',['�']='消失的背影:AwAICAIABAoAAA==.',['�']='湖东小蛟龙:AwAICAgABAoAARMAAAAICAgABAo=.',['�']='火鸡煮锅巴:AwABCAEABRQCFAAIAQhaDwAgThMBBAoAFAAIAQhaDwAgThMBBAoAAA==.灰烬:AwAECAQABRQAAA==.',['�']='炎獄:AwAECAQABRQAAA==.炼狱焚天:AwAFCAIABAoAAA==.',['�']='爱吃小汉堡丶:AwADCAUABRQCCQADAQikEAAjKsYABRQACQADAQikEAAjKsYABRQAAA==.',['�']='狐里灬狐涂:AwAECAgABRQDBQADAQhWEgBFubcABRQABQACAQhWEgBO/7cABRQAFQABAQiPFwAzLEkABRQAAA==.',['�']='留歌:AwADCAMABAoAAA==.',['�']='看见温柔了么:AwADCAUABRQCAwADAQjMEQAS/YoABRQAAwADAQjMEQAS/YoABRQAAA==.眼镜哥:AwAICAgABAoAAA==.',['�']='繁华沧桑:AwABCAEABRQAAA==.',['�']='绊倒铁盒:AwAGCAYABRQCBQAGAQh7AQAfz4kBBRQABQAGAQh7AQAfz4kBBRQAAA==.',['�']='老头传说:AwAFCAEABAoAAA==.',['�']='胸肌入云:AwAGCAIABAoAAA==.',['�']='自由号角:AwAECAQABAoAAA==.',['�']='艾米丽:AwACCAEABAoAAA==.',['�']='若海鳞丨:AwAECAQABRQAAA==.若海鳞亅:AwAECAQABRQAAA==.',['�']='莫问笑笑:AwAHCAkABAoAAQMAGBUCCAYABRQ=.',['�']='萌小兽丶:AwADCAIABRQAAA==.萨拉塔斯狱卒:AwAGCAEABAoAAA==.',['�']='蒙萌萌:AwAICBAABAoAAA==.',['�']='薄肌少年:AwAFCAUABAoAAA==.',['�']='藤藤菜小王子:AwABCAEABRQAAA==.',['�']='行军大总管:AwACCAMABRQAAA==.',['�']='被遗忘民工:AwABCAEABRQAAA==.',['�']='西斯缇娜:AwAECAQABAoAAA==.西烈热晒:AwAGCAYABRQDDwAGAQhlAQAp5l4BBRQADwAFAQhlAQAqW14BBRQAFgABAQg9EAAoEl8ABRQAAA==.',['�']='见圣骑就要打:AwAFCAUABRQCAQAFAQg3BQAmbDMBBRQAAQAFAQg3BQAmbDMBBRQAAA==.',['�']='訫筎芷氺:AwABCAEABAoAAA==.',['�']='酒后驾驶:AwAICAgABAoAAA==.酷炫狂霸丶:AwADCAUABAoAAA==.',['�']='金币之怒:AwAGCAEABAoAAA==.',['�']='锵进酒杯莫停:AwABCAEABRQAAA==.',['�']='长安喳喳辉:AwABCAIABRQCBAAIAQiePAAl7Y8BBAoABAAIAQiePAAl7Y8BBAoAAA==.',['�']='阿丶頓:AwACCAQABRQCCQAHAQhoIgBcEQoCBAoACQAHAQhoIgBcEQoCBAoAAA==.阿伊吐蕃公主:AwAECAQABRQAAA==.阿泽的小牛战:AwAICAgABAoAAA==.',['�']='雨中残雪:AwAFCAUABAoAAA==.雨夜故城桥:AwAGCAYABAoAARcAV78DCAMABRQ=.雾中残影:AwAECAQABAoAAA==.',['�']='霸气的小青春:AwAFCAgABAoAAA==.',['�']='顺亡:AwAHCAcABAoAAREATFAGCAsABRQ=.顺天:AwABCAEABAoAAA==.',['�']='鬼影子:AwACCAIABAoAAA==.鬼马丶小汉堡:AwAICAgABAoAAA==.',['�']='鲜虾脆薯盏:AwAECAgABRQCGAAEAQjOEQA6GfAABRQAGAAEAQjOEQA6GfAABRQAAA==.',['�']='鸿运临头:AwAECAMABAoAAA==.鸿鹄之痔:AwAICAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end