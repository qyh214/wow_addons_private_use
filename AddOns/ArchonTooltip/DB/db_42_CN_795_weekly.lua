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
 local lookup = {'Mage-Frost','Warlock-Destruction','Warlock-Affliction','DeathKnight-Unholy','Shaman-Restoration','Unknown-Unknown','Warrior-Protection','Mage-Fire','Paladin-Retribution','DeathKnight-Blood','DemonHunter-Havoc','Druid-Guardian','Priest-Shadow','Priest-Holy','Rogue-Assassination','Monk-Mistweaver','Hunter-Marksmanship','DemonHunter-Vengeance',}; local provider = {region='CN',realm='耳语海岸',name='CN',type='weekly',zone=42,date='2025-04-15',data={As='Ashane:AwAECAQABRQAAA==.',Co='Cool:AwABCAEABAoAAA==.',De='Deepsea:AwAFCAUABAoAAA==.',Ed='Edinburgh:AwACCAIABRQAAA==.',Fr='Frostnova:AwABCAEABRQCAQAIAQhfDgBVxHYCBAoAAQAIAQhfDgBVxHYCBAoAAA==.',Hu='Hugaga:AwAECAYABRQCAgAEAQiZCwBEFe0ABRQAAgAEAQiZCwBEFe0ABRQAAA==.',Ke='Kensou:AwABCAEABRQAAA==.',Ne='Needherr:AwAECAcABAoAAA==.',No='Noworries:AwAECAQABRQAAA==.',Pa='Pander:AwABCAEABRQAAA==.',Qu='Quantum:AwABCAEABRQAAA==.',Ru='Rubyms:AwAICBEABAoAAA==.',Th='Thoughluck:AwAHCBEABAoAAA==.',Ve='Vectorw:AwAECAIABRQAAA==.',Xi='Xina:AwAECAQABAoAAA==.',Ze='Zerodawn:AwABCAEABRQAAA==.',Zh='Zhyu:AwAECA8ABRQDAwAEAQiBCABhI90ABRQAAwADAQiBCABhct0ABRQAAgACAQhFEgBgM8YABRQAAA==.',Zo='Zoe:AwACCAIABAoAAA==.',['�']='一色彩羽:AwAFCAQABAoAAA==.万法千宗:AwACCAUABRQCBAAIAQjPAwBglfcCBAoABAAIAQjPAwBglfcCBAoAAA==.不动如山丶:AwACCAIABAoAAA==.丨莫淇洛丨:AwADCAkABRQCBQADAQhFBQBToSEBBRQABQADAQhFBQBToSEBBRQAAA==.丶玉景灬天池:AwAECAQABRQAAQYAAAAICAQABRQ=.',['�']='乌龙乌龙茶:AwACCAIABRQAAA==.乱拳:AwAHCAIABAoAAA==.',['�']='人性的背叛者:AwAGCAwABAoAAA==.人道是战神:AwAECAQABRQAAA==.',['�']='休闲东东:AwABCAEABRQAAA==.',['�']='修逻:AwAICCAABAoCBwAIAQglBQBQNHMCBAoABwAIAQglBQBQNHMCBAoAAA==.',['�']='倒影红尘:AwAICBgABAoDAQAIAQjgPwAirEIBBAoAAQAIAQjgPwAesEIBBAoACAAHAQg0TwAXJygBBAoAAA==.',['�']='兔子不会魔法:AwAECAQABRQAAA==.',['�']='几十个猎魔人:AwAHCAwABAoAAA==.凡心凡术二号:AwAECAQABRQAAA==.',['�']='制裁丶:AwAICAgABAoAAA==.',['�']='北大路五月:AwAICAYABAoAAA==.北极没有夏天:AwAECAQABRQAAA==.医德扶人:AwAFCAcABAoAAA==.',['�']='单纯的小暴力:AwAGCAgABAoAAA==.',['�']='参不透:AwAECAQABRQAAA==.只有狂风:AwAICAgABAoAAA==.',['�']='哇啦哇啦:AwAICAgABAoAAA==.哈迪斯:AwAICBIABAoAAA==.',['�']='啦拉啦种太阳:AwAICAcABAoAAA==.',['�']='喷起来丶:AwAECAQABRQAAA==.',['�']='嘚嘚以嘚嘚:AwAECAQABRQAAA==.',['�']='圣光之橙:AwAHCAcABAoAAA==.圣光猫咩咩:AwADCAUABAoAAA==.圣诞袜:AwAECAQABRQAAA==.',['�']='夜鹰之王:AwABCAMABRQCCQAIAQjkdgAlu40BBAoACQAIAQjkdgAlu40BBAoAAA==.大叔的乖萝卜:AwABCAEABRQAAA==.大地忽悠着你:AwAECAQABRQAAA==.天姥:AwAGCAkABAoAAA==.',['�']='奈拉丝特拉:AwAGCAYABAoAAA==.',['�']='安帕赫:AwAICAgABAoAAQMAX4gDCAoABRQ=.宿世:AwAFCAMABAoAAA==.',['�']='封之不死骑士:AwACCAMABRQAAA==.小犄角长尾巴:AwABCAEABRQAAA==.小痴不忧郁:AwAICBMABAoAAA==.',['�']='幸福白勺贝贝:AwAICAgABAoAAA==.',['�']='强力熊:AwABCAIABAoAAA==.',['�']='恐虐神选者:AwADCAwABRQCBAADAQgfCgA+Y/0ABRQABAADAQgfCgA+Y/0ABRQAAA==.',['�']='我要双持蛋刀:AwAECAMABRQAAA==.',['�']='明前:AwABCAEABRQAAQoAHcsBCAIABRQ=.星宇星宇星:AwACCAIABRQAAQsAUFcICAkABRQ=.星曜天月:AwAICAgABAoAAA==.',['�']='暖阳:AwAFCAkABAoAAA==.',['�']='最后一个老千:AwAGCAUABAoAAA==.月夜風暴:AwAECAQABRQAAA==.月如霜:AwAECAQABRQAAA==.',['�']='李丶書文:AwADCAMABAoAAA==.松饼猫酱:AwADCAwABRQCDAADAQj8AgAUN3YABRQADAADAQj8AgAUN3YABRQAAA==.',['�']='梦我的甜甜:AwAGCAIABRQCAgACAQhsFQAalbAABRQAAgACAQhsFQAalbAABRQAAA==.梵丶夜:AwAICAgABAoAAA==.梶猗:AwAGCAYABAoAAA==.',['�']='欺雪凌霜:AwACCAMABRQCBAAIAQiKJABBmQgCBAoABAAIAQiKJABBmQgCBAoAAA==.',['�']='法丝不是很累:AwABCAEABRQCAQAGAQjgJQBUc8sBBAoAAQAGAQjgJQBUc8sBBAoAAA==.泡泡蝴蝶:AwABCAEABRQAAA==.',['�']='流星坠落:AwABCAEABRQAAA==.海伦娜:AwAGCAIABRQAAA==.',['�']='清风明月:AwABCAEABAoAAQoAHcsBCAIABRQ=.渡鸦六九九:AwAGCAYABAoAAA==.',['�']='满江红:AwAICAQABAoAAA==.',['�']='漫天星光:AwACCAIABAoAAA==.',['�']='灬伊卡丶洛斯:AwAECAQABRQAAA==.',['�']='爸爸可以哦:AwAICAgABAoAAA==.',['�']='牧渔人:AwAGCAEABAoAAA==.',['�']='狂风神龍:AwABCAEABRQAAA==.',['�']='玉腿肩上扛:AwAGCAIABRQAAA==.王初初:AwAGCAYABAoAAA==.',['�']='珂朵莉:AwACCAIABAoAAA==.',['�']='神箭丘比特:AwAGCAYABAoAAA==.',['�']='秋季萧雨:AwAECAQABRQAAA==.',['�']='簡匰啲萿著:AwACCAIABRQAAA==.',['�']='米丨小贼:AwAICA4ABAoAAA==.米兰哥三比零:AwAICAkABAoAAQYAAAABCAEABRQ=.',['�']='精灵的德鲁猪:AwABCAEABRQAAA==.',['�']='紫血冰枫:AwACCAIABRQDDQAIAQg5DABPpXoCBAoADQAIAQg5DABPpXoCBAoADgAEAQjvaQAiWnwABAoAAQEAWaQCCAIABRQ=.',['�']='红袖添乱:AwAHCBAABAoAAA==.',['�']='维鲁莎多:AwAFCAUABAoAAA==.',['�']='背元素周期表:AwACCAQABRQAAA==.',['�']='舞尘猫咩咩:AwAECAQABAoAAA==.',['�']='艾露莎:AwAICAYABAoAAA==.',['�']='菊花怪七号:AwAICBkABAoCDwAIAQh7DgA9ohoCBAoADwAIAQh7DgA9ohoCBAoAAA==.',['�']='蒜泥啵啵浆水:AwABCAIABRQCEAAHAQgYFgBUyyQCBAoAEAAHAQgYFgBUyyQCBAoAAA==.',['�']='藤井树:AwADCAgABRQCEQADAQigCQA4yeMABRQAEQADAQigCQA4yeMABRQAAA==.',['�']='诅咒丶:AwAGCAQABRQAAA==.诗歌除外:AwABCAIABRQDCgAHAQjXOAAdy78ABAoACgAHAQjXOAAWF78ABAoABAAEAQi/gwAnfpwABAoAAA==.',['�']='谢尔盖:AwACCAUABRQCEgAIAQjsMgAPrtcABAoAEgAIAQjsMgAPrtcABAoAAA==.',['�']='踏歌冰雪:AwACCAIABRQAAA==.',['�']='这能抓吗:AwAICAkABAoAAA==.',['�']='遠方的約定:AwACCAIABRQAAA==.',['�']='酒笙清栀:AwABCAEABAoAAA==.酒肆梦桃夭:AwAHCAcABAoAAA==.',['�']='野原京香:AwABCAEABRQAAA==.野原啫哩:AwAFCAcABAoAAA==.',['�']='闪电猫:AwABCAEABAoAAA==.',['�']='隔壁丶老钱:AwACCAUABRQCAgAIAQgzLQAxUq4BBAoAAgAIAQgzLQAxUq4BBAoAAA==.',['�']='露蓰翽:AwAFCAEABAoAAA==.霸宋:AwAGCAYABAoAAA==.霸王电影蛋:AwAHCAcABAoAAA==.',['�']='骑马与砍杀:AwAECAQABAoAAA==.',['�']='魔影暗语:AwAGCAQABRQAAA==.',['�']='黑夜问白天:AwACCAIABRQCAQAIAQjmBgBZpMgCBAoAAQAIAQjmBgBZpMgCBAoAAA==.黑色柳丁:AwAICCAABAoDBAAIAQgrKwBDkuQBBAoABAAIAQgrKwA+3uQBBAoACgAIAQi+HgAwXXIBBAoAAQQAPpAGCAgABRQ=.',['�']='龙人之祖:AwAFCAUABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end