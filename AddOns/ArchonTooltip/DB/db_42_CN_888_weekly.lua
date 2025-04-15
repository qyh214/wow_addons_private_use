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
 local lookup = {'Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Frost','DemonHunter-Havoc','Priest-Discipline','DemonHunter-Vengeance','Priest-Holy','Hunter-Marksmanship','Monk-Brewmaster','Paladin-Retribution','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Druid-Balance','Druid-Restoration','Warrior-Arms','Mage-Fire','Evoker-Preservation','Shaman-Restoration','Hunter-BeastMastery','Monk-Mistweaver','DeathKnight-Blood',}; local provider = {region='CN',realm='鲜血熔炉',name='CN',type='weekly',zone=42,date='2025-04-15',data={Aa='Aarn:AwAECAQABRQAAA==.',Ah='Ahsir:AwADCAMABAoAAQEAAAABCAEABRQ=.',Ar='Ardth:AwAICCQABAoCAgAIAQhkFABPRm4CBAoAAgAIAQhkFABPRm4CBAoAAA==.',Bl='Blingknight:AwACCAIABRQAAA==.',By='Byakuya:AwADCAQABRQDAgAIAQhyIABGFiACBAoAAgAIAQhyIABGFiACBAoAAwAFAQhdGwA4n9AABAoAAA==.',Ca='Carcharodon:AwAHCAwABAoAAA==.',De='Desoxynn:AwAECAEABRQAAA==.',Fl='Flymdh:AwAFCA8ABAoAAA==.',Ka='Kakarotto:AwACCAYABRQCBAACAQiTHwAus5UABRQABAACAQiTHwAus5UABRQAAA==.',Ko='Konpakuyoumu:AwAFCAUABAoAAA==.Kopite:AwAECAgABRQCAgAEAQimDAA01+8ABRQAAgAEAQimDAA01+8ABRQAAA==.',Lo='Loiuytrew:AwAFCAkABAoAAQUAPiAICA4ABRQ=.',So='Somnus:AwAECAQABRQAAA==.',Xb='Xbaa:AwAGCAYABAoAAA==.Xbzz:AwAICAkABAoAAA==.',Ye='Yeeroy:AwACCAYABRQCBgACAQglEAANmF4ABRQABgACAQglEAANmF4ABRQAAA==.',Yu='Yuka:AwABCAIABRQAAA==.',['�']='一队的骑士:AwAECAQABRQAAA==.三队骑士:AwAGCA0ABAoAAA==.',['�']='乂木头懒人乂:AwAECAMABRQAAA==.九筒:AwABCAEABAoAAA==.',['�']='五个糖豆:AwABCAEABAoAAA==.',['�']='你么慌:AwACCAIABAoAAA==.你瞅啥:AwAECAQABAoAAA==.',['�']='削肾客的九叔:AwAECAQABRQAAA==.',['�']='加德斯:AwACCAQABRQAAA==.',['�']='原神:AwACCAYABRQCBwACAQg2DgBAXagABRQABwACAQg2DgBAXagABRQAAA==.',['�']='哲别风尘:AwACCAcABRQCCAACAQivEQBHTZoABRQACAACAQivEQBHTZoABRQAAA==.',['�']='囗他:AwACCAYABRQCCQACAQj5BQAkX3QABRQACQACAQj5BQAkX3QABRQAAA==.国宝:AwAECAQABRQAAA==.',['�']='夕相待:AwAECAQABRQAAA==.大块儿头:AwAICAgABAoAAA==.',['�']='宝可梦上啊:AwAICAkABAoAAA==.',['�']='寒冰王座:AwAECAQABAoAAA==.',['�']='小坨坨儿:AwACCAUABRQCCAACAQhsFQAZmn8ABRQACAACAQhsFQAZmn8ABRQAAA==.小程:AwAFCA0ABRQCCgAFAQgfAQA6Q8EBBRQACgAFAQgfAQA6Q8EBBRQAAA==.',['�']='山岚:AwADCAUABRQECwAIAQgXBgBfpQQCBAoACwAFAQgXBgBdWwQCBAoADAAFAQgOKgBhB70BBAoADQACAQiIVABYQmQABAoAAA==.',['�']='巜丷尐黑灬:AwAHCAsABAoAAA==.',['�']='希徳嘞丶:AwACCAIABRQAAA==.帖拉所翼朵:AwADCAYABRQDDgADAQh8GABCmrwABRQADgACAQh8GABSsLwABRQADwACAQiWEQAz8YEABRQAAA==.',['�']='快乐牌刀片:AwACCAIABRQAAA==.',['�']='恶魔城冥王:AwACCAEABAoAAA==.',['�']='愤怒的绿皮儿:AwABCAMABRQCEAAIAQjjDQBIADgCBAoAEAAIAQjjDQBIADgCBAoAAA==.',['�']='拓真二:AwACCAIABAoAAA==.',['�']='斯大箖丶:AwABCAEABAoAAA==.',['�']='无形无忌:AwADCAMABAoAAA==.无忧醑:AwACCAIABAoAAA==.时风曰:AwACCAYABRQCCgACAQjHKQA2JJ4ABRQACgACAQjHKQA2JJ4ABRQAAA==.',['�']='星陨丶逐日者:AwABCAEABRQCEQAHAQhjQwAqH2kBBAoAEQAHAQhjQwAqH2kBBAoAAA==.星雨:AwABCAEABRQAAA==.',['�']='普莉希拉:AwACCAYABRQCEgACAQiPBwAP3mYABRQAEgACAQiPBwAP3mYABRQAAA==.晴天有雲:AwABCAEABAoAAA==.',['�']='暗夜小猎手:AwAGCAYABAoAAA==.暴力黑风:AwAECAQABRQAAA==.暴走小妞:AwAECAgABRQCCgAEAQhZBgBTWDIBBRQACgAEAQhZBgBTWDIBBRQAAA==.',['�']='果冻布丁:AwADCAMABRQAAA==.',['�']='梅小赖児:AwAECAoABRQCEwAEAQh5EgAaq8wABRQAEwAEAQh5EgAaq8wABRQAAQ8AOkwGCAUABRQ=.',['�']='氤氲之雾:AwABCAEABRQAAA==.',['�']='浮生辛诺:AwADCAMABRQAAA==.',['�']='消逝的温柔:AwAFCAYABAoAAA==.',['�']='淡忘星宇:AwACCAUABRQCAwACAQj6BAAZbowABRQAAwACAQj6BAAZbowABRQAAA==.',['�']='溜溜球:AwAICAgABAoAAA==.',['�']='炽热之辉:AwACCAIABAoAAA==.',['�']='热情的风斗:AwADCAcABRQCBAADAQjdFgAXVtMABRQABAADAQjdFgAXVtMABRQAAA==.',['�']='熠皛僧:AwACCAIABRQAAA==.',['�']='猴子:AwACCAEABRQAAA==.',['�']='玉轩:AwABCAIABRQAAA==.',['�']='琉璃丶筱杺:AwAGCAcABAoAAA==.',['�']='瑞穆:AwADCAIABAoAAA==.',['�']='璀璨之猎:AwADCAQABAoAAA==.',['�']='盘头大姨:AwAFCAgABAoAAA==.',['�']='碳烤鹌鹑:AwACCAQABRQCDwAIAQgBCwBMdGcCBAoADwAIAQgBCwBMdGcCBAoAAA==.',['�']='祢豆子:AwAECAgABAoAAA==.',['�']='禁忌热血:AwAICBIABAoAAA==.离洛流尘:AwACCAIABAoAAA==.',['�']='第二套广播:AwADCAMABAoAAA==.',['�']='終極灬大錶姐:AwAECAcABAoAAA==.',['�']='纪念冷血毕爷:AwAICAMABAoAARQAN9MGCAkABRQ=.',['�']='给我一个胶带:AwAECAUABRQCFQAEAQh9AwA4V18BBRQAFQAEAQh9AwA4V18BBRQAAA==.',['�']='肥猫先生:AwAGCAEABAoAAA==.',['�']='自由行走的葩:AwAECAgABAoAAA==.',['�']='芒果爆爆豆:AwACCAIABRQAAA==.',['�']='英普瑞斯:AwAECAYABRQCCgAEAQjwCwBGjRYBBRQACgAEAQjwCwBGjRYBBRQAARAAIZ4GCAoABRQ=.',['�']='蠢蠢欲动:AwACCAMABRQDAgAIAQgCLQBGfNsBBAoAAgAGAQgCLQBTudsBBAoAFgAIAQgAIAAvUGcBBAoAAA==.',['�']='血色未来:AwAECAQABAoAAA==.',['�']='西格玛:AwACCAYABRQCEAACAQjtCABB2rgABRQAEAACAQjtCABB2rgABRQAAA==.',['�']='要啥嗜血:AwAECAEABAoAAA==.',['�']='逆潮丨小崔:AwAFCAUABAoAAA==.',['�']='铃鹿:AwAFCAQABRQCBwAIAQgZEwBGmxwCBAoABwAIAQgZEwBGmxwCBAoAAA==.',['�']='锁甲收集者:AwAECAQABRQAAA==.',['�']='随机摩卡卡:AwABCAEABRQAAA==.',['�']='青丝蘸白雪:AwADCAYABAoAAA==.青笋:AwACCAYABRQCAgACAQh/FgBCs6gABRQAAgACAQh/FgBCs6gABRQAAA==.',['�']='高手:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end