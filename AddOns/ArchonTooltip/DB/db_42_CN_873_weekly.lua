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
 local lookup = {'Mage-Fire','Paladin-Retribution','Unknown-Unknown','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Priest-Shadow','DeathKnight-Unholy','Monk-Windwalker','Shaman-Restoration','Priest-Discipline','Hunter-Marksmanship','Hunter-BeastMastery','Druid-Restoration','Warrior-Fury','Warrior-Arms','Warrior-Protection','Monk-Brewmaster','Priest-Holy','Paladin-Protection','DemonHunter-Vengeance','DemonHunter-Havoc','DeathKnight-Blood',}; local provider = {region='CN',realm='雏龙之翼',name='CN',type='weekly',zone=42,date='2025-04-15',data={De='Decepticons:AwACCAYABRQCAQACAQivJAA7BJ0ABRQAAQACAQivJAA7BJ0ABRQAAA==.Deepsea:AwAICAgABAoAAA==.',Es='Escapist:AwAGCAoABAoAAA==.',In='Inn:AwAECAIABRQAAA==.',Ir='Ira:AwAICBAABAoAAA==.',Je='Jetai:AwAICAIABAoAAA==.',Ji='Jinnx:AwAECAQABRQAAA==.Jinzx:AwAECAEABAoAAA==.',Kr='Kristian:AwAECAQABRQAAA==.',Mo='Mordekaiser:AwAECAQABRQAAA==.',Mu='Mucher:AwABCAEABRQAAA==.',Ra='Rafale:AwACCAIABAoAAA==.',St='Stylite:AwAICAgABAoAAA==.',Su='Sunpsyche:AwAGCAYABAoAAA==.',Sw='Swordthrust:AwACCAQABRQAAA==.',Ti='Tino:AwAECAQABRQAAA==.',Va='Valthonis:AwACCAMABRQCAgAIAQgFRQBC3QcCBAoAAgAIAQgFRQBC3QcCBAoAAA==.',Ya='Yangbaby:AwADCAEABRQAAA==.',Zq='Zqz:AwAICAkABAoAAA==.',['�']='三鹿奶:AwAHCAcABAoAAA==.不是兔子的锅:AwADCAMABAoAAQMAAAABCAEABRQ=.丶静心:AwAGCAoABRQEBAAGAQgpCAA+lwYBBRQABAAEAQgpCABRdgYBBRQABQABAQhuDAA6TloABRQABgACAQgkFgAKQ1IABRQAAA==.',['�']='仲夏叁拾:AwACCAIABAoAAA==.',['�']='伊利蛋丶怒猴:AwADCAMABAoAAA==.',['�']='你的姐姐:AwACCAIABAoAAA==.佩佩有龙猫:AwACCAIABAoAAA==.',['�']='侬是则模子:AwAICAcABAoAAA==.',['�']='信宇:AwABCAEABAoAAA==.信用社郑经理:AwAECAQABRQAAA==.',['�']='元瑶:AwACCAIABAoAAA==.光与暗:AwAFCAoABAoAAA==.兔子的小萨:AwADCAEABRQAAQcATGUGCAoABRQ=.兜十六:AwAICAQABRQAAA==.六合布武:AwAGCAcABAoAAA==.',['�']='再见二丁目啊:AwAICAcABAoAAA==.冰封白菜:AwAGCAoABRQDBQAGAQhDAAA9uXoBBRQABQAFAQhDAABGZHoBBRQABAAFAQibAgBAQ18BBRQAAQQATegICAYABRQ=.',['�']='刀口舔血:AwAECAQABAoAAA==.列兵多斯:AwADCAMABAoAAA==.',['�']='北风南方吹:AwAFCAUABAoAAA==.匣儿哥李宝库:AwAICAgABAoAAA==.',['�']='南瓜:AwACCAIABRQAAA==.',['�']='叁井寿:AwAECAcABRQCCAAEAQjRBwBHCQ0BBRQACAAEAQjRBwBHCQ0BBRQAAA==.司马莽夫:AwAECAQABRQAAA==.',['�']='哈库呐玛塔塔:AwADCAMABAoAAA==.',['�']='啊吊:AwAHCAcABAoAAA==.',['�']='喜多川海梦:AwAECAQABRQAAA==.',['�']='回家找妈:AwAICAgABAoAAA==.',['�']='墓尸妹子:AwAECAQABAoAAA==.',['�']='多多綠少糖:AwACCAIABAoAAQkAUbUHCAcABRQ=.天亮了:AwABCAEABRQCCgAIAQiACgBaApICBAoACgAIAQiACgBaApICBAoAAA==.',['�']='奈因哈特:AwAECAQABAoAAA==.奥罗拉丶血翼:AwAICAkABAoAAA==.',['�']='孤单听雨的猫:AwAECAQABRQAAA==.',['�']='宫下玲奈:AwAECAEABRQCCwABAQi6HQAYUlIABRQACwABAQi6HQAYUlIABRQAAA==.',['�']='射到你叫不敢:AwAECA4ABRQDDAAEAQgHDQAugswABRQADAAEAQgHDQAsT8wABRQADQACAQj4KgAjSY4ABRQAAA==.小丿橙子:AwAICAsABAoAAA==.小乔不会死骑:AwADCAMABAoAAA==.小医仙:AwACCAIABAoAAA==.小堂:AwAGCAYABAoAAA==.小小晨丨:AwAECAQABRQAAA==.小龙翅膀:AwAGCAcABAoAAA==.尕疼疼:AwAECAQABRQAAA==.尘埃丶落:AwAICAIABAoAAA==.',['�']='巷牙山李桂兰:AwABCAEABRQAAA==.',['�']='帅胡:AwABCAEABAoAAA==.帕瑟妮丶影歌:AwAHCAUABAoAAA==.',['�']='微尘:AwAECAIABAoAAA==.微微一笑:AwADCAMABAoAAA==.德尔蹄:AwADCAcABRQCDgADAQijBQBBoAEBBRQADgADAQijBQBBoAEBBRQAAA==.',['�']='快乐的小幸福:AwAFCAUABAoAAA==.',['�']='感动狗狗:AwAICBUABAoEDwAIAQhnKgA/SskBBAoADwAHAQhnKgBGoMkBBAoAEAAFAQhrOQAjH9IABAoAEQABAQjQPgATRiEABAoAAA==.愤怒的奇异果:AwAFCBEABRQCEgAFAQi2AQAjcvwABRQAEgAFAQi2AQAjcvwABRQAAREALyoICAoABRQ=.',['�']='我不会用刀桶:AwAECAYABRQEBgAEAQi2AgBZnh0BBRQABgADAQi2AgBY4R0BBRQABAACAQjUFgBT2aYABRQABQABAQjoFwAAAAAABRQAAA==.我即是暗裔:AwADCAMABAoAAA==.我帅我可以:AwAICAgABAoAAA==.我活在梦里:AwAECAQABRQAAA==.',['�']='扶风:AwAECAIABRQAAA==.',['�']='放心有我:AwABCAEABRQDEwAHAQghKAA/PIwBBAoAEwAHAQghKAA/PIwBBAoACwADAQjHdgAZ8kgABAoAAA==.',['�']='无忧:AwAGCAMABAoAAQ4AOkwGCAUABRQ=.',['�']='星见雅:AwAICAgABAoAAA==.',['�']='曹兔子:AwAICAgABAoAAQcATGUGCAoABRQ=.曼珠灬沙华:AwAICAgABAoAAA==.替身使者:AwAICAgABAoAAA==.',['�']='有德便有奶:AwADCAMABAoAAA==.本草纲目:AwACCAIABAoAAA==.',['�']='杨永信:AwADCAMABRQAAA==.',['�']='枫原万叶:AwAGCAYABRQCCgAGAQjqAAAo/JQBBRQACgAGAQjqAAAo/JQBBRQAAQMAAAAICAIABRQ=.',['�']='格萨拉克:AwADCAMABAoAAA==.',['�']='梅子绿茶:AwAECAQABAoAAA==.梅瑟莫:AwAGCAYABAoAAA==.梦里灬圣光:AwABCAIABRQCFAAHAQiUHwArTjQBBAoAFAAHAQiUHwArTjQBBAoAAA==.梦里灬战嗜:AwAFCAUABAoAAA==.',['�']='欧根亲王:AwAECAQABAoAAA==.',['�']='法兰克福:AwAICBYABAoDFQAIAQgcDQBKESsCBAoAFQAIAQgcDQBHrCsCBAoAFgAHAQjLRAA2G3UBBAoAAA==.',['�']='温酒待故人:AwAICAkABAoAAA==.',['�']='潇湘夜雨:AwAICAoABAoAAA==.潜龙勿用:AwAECAQABAoAAA==.',['�']='灰炎:AwAECAQABRQAARYAKXMGCAYABRQ=.',['�']='牛肉意面:AwAECAYABRQCCAAEAQhcDwAqY+AABRQACAAEAQhcDwAqY+AABRQAAA==.牢大:AwAICBAABAoAAA==.牧奶医丶:AwAICBUABAoCEwAIAQjSFABCJQ4CBAoAEwAIAQjSFABCJQ4CBAoAAA==.',['�']='狄娜:AwADCAMABAoAAA==.',['�']='王者绝非偶然:AwACCAIABAoAAA==.',['�']='白夜守心:AwABCAEABAoAAA==.',['�']='真湖:AwAGCAkABAoAAA==.',['�']='睿睿爱吃肉:AwAHCA4ABAoAAA==.',['�']='祖宗保佑我:AwAGCAYABAoAAA==.神话熊猫:AwAFCAsABAoAAQMAAAAICA8ABAo=.',['�']='禁忌之兰:AwAECAQABRQAARcAH+IGCAYABRQ=.',['�']='米斯特汀:AwAECAcABAoAAA==.',['�']='纥那:AwAICAgABAoAAA==.',['�']='群星陨落:AwAICAgABAoAAA==.',['�']='肖恩康纳朗:AwADCAMABAoAAA==.',['�']='胡来的瞎王:AwACCAIABAoAAA==.能奶能打:AwAHCAgABAoAAA==.',['�']='脸红的发紫:AwACCAIABAoAAA==.',['�']='落霞孤鹜:AwACCAQABAoAAA==.',['�']='蓝皮鼠:AwABCAEABRQAAA==.',['�']='薯条是只猫:AwABCAEABRQAAA==.',['�']='血煞魔君:AwAICBgABAoCDwAIAQhyHgBDFg4CBAoADwAIAQhyHgBDFg4CBAoAAA==.',['�']='西爷:AwACCAEABAoAAA==.',['�']='诗卧妲雕:AwAHCAYABAoAAA==.诺铭丨咻:AwACCAIABAoAAA==.',['�']='踏宴:AwACCAIABRQAAA==.',['�']='辣条是只喵:AwAECAgABRQCFgAEAQhUCgBNrgwBBRQAFgAEAQhUCgBNrgwBBRQAAA==.',['�']='迪娜:AwABCAEABRQAAA==.追丶风:AwACCAQABRQDDQAIAQhIMQBCsxcCBAoADQAIAQhIMQBBmBcCBAoADAAFAQhxQgAygtcABAoAAA==.追光:AwAICBQABAoCDQAIAQj7MwBGUQsCBAoADQAIAQj7MwBGUQsCBAoAAA==.',['�']='逃跑的太阳:AwAGCAsABRQCDAAGAQhnAAA7LrQBBRQADAAGAQhnAAA7LrQBBRQAAA==.',['�']='郑菲翠:AwACCAIABAoAAA==.',['�']='重案组之虎:AwACCAIABRQAAA==.',['�']='银月昊天:AwAICAsABAoAAA==.',['�']='闪避王川噗:AwAGCA4ABRQDBAAGAQhTAgBLC3IBBRQABAAFAQhTAgBZInIBBRQABQACAQiuDgASrVMABRQAAA==.',['�']='阿兜兜:AwAECAQABRQAAA==.',['�']='陌上君如雪:AwAICAsABAoAAA==.',['�']='霧灬無邪:AwAICBAABAoAAA==.',['�']='颅筑王座:AwACCAEABAoAAA==.',['�']='魔云金翅:AwAGCAYABAoAAA==.',['�']='齐大王丶:AwAGCAwABAoAAA==.',['�']='龙龙得意:AwAGCAIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end