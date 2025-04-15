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
 local lookup = {'Unknown-Unknown','Paladin-Holy','Mage-Fire','Mage-Frost','Priest-Holy','Hunter-BeastMastery','Paladin-Retribution','Druid-Restoration','DeathKnight-Unholy','DeathKnight-Blood','DemonHunter-Vengeance','Monk-Brewmaster','Warlock-Destruction','DemonHunter-Havoc','Warlock-Affliction','Warrior-Fury','Warrior-Arms','DeathKnight-Frost','Shaman-Elemental','Druid-Balance','Paladin-Protection','Shaman-Enhancement','Shaman-Restoration','Priest-Discipline','Priest-Shadow','Monk-Mistweaver','Monk-Windwalker','Hunter-Survival','Evoker-Devastation','Evoker-Preservation','Warlock-Demonology',}; local provider = {region='CN',realm='铜龙军团',name='CN',type='weekly',zone=42,date='2025-04-15',data={An='Angleagain:AwAICAgABAoAAQEAAAAECAQABRQ=.',Ch='Chrismax:AwAHCAwABAoAAA==.',Do='Dorara:AwACCAIABAoAAA==.',Dr='Dreamh:AwADCAUABAoAAA==.Dreamwriter:AwADCAoABRQCAgADAQgsBwAibtAABRQAAgADAQgsBwAibtAABRQAAA==.',Hi='Hillamaris:AwAECAQABAoAAA==.',Ic='Icymaple:AwAFCAUABAoAAA==.',Ki='Kire:AwADCAUABAoAAA==.',Kk='Kkye:AwAHCAYABAoAAA==.',La='Laiban:AwABCAEABAoAAA==.',Le='Leo:AwADCAMABAoAAA==.',Lm='Lmmdz:AwAICAgABAoAAA==.Lmmfs:AwAGCAQABRQDAwAIAQhKCwBgKrQCBAoAAwAIAQhKCwBgKrQCBAoABAACAQinXgBaVcoABAoAAA==.',Ly='Lycan:AwAICAgABAoAAA==.',Mi='Mistiness:AwADCAwABRQCBQADAQjCBwA5rOQABRQABQADAQjCBwA5rOQABRQAAA==.',Mu='Muldermonk:AwABCAEABAoAAA==.',Ni='Niubiglass:AwAICAgABAoAAA==.',Oc='Oceciliao:AwAICBwABAoCBQAIAQh2PQAVPx8BBAoABQAIAQh2PQAVPx8BBAoAAA==.',Sa='Sarlly:AwADCAMABAoAAA==.Sasa:AwAGCAMABRQAAA==.',Sh='Shadowsoul:AwACCAIABRQAAA==.',Si='Silver:AwAECAQABRQAAA==.',Sn='Snooplr:AwADCAgABRQCBgADAQhZBABjJFwBBRQABgADAQhZBABjJFwBBRQAAA==.',So='Sologsy:AwAECAgABRQCBwAEAQi5IAATPMsABRQABwAEAQi5IAATPMsABRQAAA==.Soulchaos:AwAFCAoABAoAAA==.',['�']='一血小分队:AwAHCAgABAoAAA==.万恶的陈师傅:AwACCAIABAoAAA==.不说话装高手:AwAICAgABAoAAA==.专业战复:AwABCAEABAoAAA==.丨贱咗萌丨:AwAFCAUABAoAAA==.丨贱袏萌丨:AwAICBwABAoCBwAIAQjqhAAhOm0BBAoABwAIAQjqhAAhOm0BBAoAAA==.丰饶孤屿:AwADCAEABAoAAA==.丰饶孤岛:AwAECAQABRQAAA==.丶南吕九:AwAHCAcABAoAAA==.丶牧野灬留姬:AwAICAgABAoAAA==.丶猎手:AwABCAEABRQAAA==.丷大汪丷:AwAECAQABAoAAA==.',['�']='什么赛博酷刑:AwABCAEABAoAAA==.今晚吃什么呢:AwAICAgABAoAAA==.',['�']='佑逝:AwAICCcABAoCBQAIAQi/IAAuW7gBBAoABQAIAQi/IAAuW7gBBAoAAA==.你的男爵:AwACCAQABRQAAA==.',['�']='做什么好呢:AwACCAIABAoAAA==.',['�']='光灬耀:AwACCAIABAoAAA==.光铸十八籽:AwAICA4ABAoAAA==.兔缺缺:AwADCA4ABRQCCAADAQh9AwBRpygBBRQACAADAQh9AwBRpygBBRQAAA==.六六爸的劣人:AwAFCAUABAoAAA==.',['�']='冰瓜:AwACCAMABRQDCQAIAQjuDgBUj5cCBAoACQAIAQjuDgBUj5cCBAoACgABAQhLXQAVeicABAoAAA==.',['�']='凌汐丶:AwAECAQABRQAAA==.凸毕呐波丸:AwAGCAwABAoAAA==.',['�']='勇敢的蚊子:AwAGCAgABAoAAA==.',['�']='十五码上树:AwACCAIABAoAAA==.卡达恰恰:AwAICA8ABAoAAA==.',['�']='原味贝果:AwAFCAUABAoAAA==.',['�']='叶湘伦:AwAECAQABRQAAA==.',['�']='噌丶风暴假酒:AwABCAEABRQCCwAIAQgLDgBD8B4CBAoACwAIAQgLDgBD8B4CBAoAAQwAT1EDCAsABRQ=.',['�']='土司:AwACCAUABRQCBAACAQh0DwAieIkABRQABAACAQh0DwAieIkABRQAAA==.圣彼得:AwAGCAkABAoAAA==.地獄丘比特:AwAGCAYABAoAAA==.',['�']='坠碧简殇映:AwADCAMABAoAAA==.',['�']='复苏之风:AwABCAEABRQAAA==.大山弯弯:AwAECAQABRQAAA==.大角牛历险记:AwABCAEABRQAAA==.天台云水:AwAICAgABAoAAA==.',['�']='奈茶的雪:AwACCAIABRQAAA==.女民兵队长:AwAFCAQABAoAAA==.好叻没丶哥:AwACCAIABRQCDQAIAQh2GwA9hhACBAoADQAIAQh2GwA9hhACBAoAAA==.',['�']='孤勇者:AwAHCAQABAoAAA==.孤雨随风:AwABCAEABAoAAA==.',['�']='宝宝大人:AwAICAgABAoAAA==.',['�']='富态武僧:AwAECAQABRQAAA==.寒潭雁渡:AwAECAoABRQCDgAEAQidCABWVRcBBRQADgAEAQidCABWVRcBBRQAAA==.',['�']='小井丿丹丹:AwADCAcABRQDDwADAQi0DgAujZwABRQADwACAQi0DgAwN5wABRQADQACAQgOHQAoCYAABRQAAA==.小小熊水果糖:AwADCAMABAoAAA==.小猫咪丫:AwAECAQABAoAAA==.小紫苏:AwAHCAMABAoAAA==.小车车:AwACCAIABRQAAA==.小鸡嚼:AwAFCAUABAoAAA==.',['�']='巧乐兹六块五:AwAFCAkABAoAAA==.',['�']='希尔丶佳丽斯:AwADCAwABRQCEAADAQgdCgA9bAkBBRQAEAADAQgdCgA9bAkBBRQAAA==.',['�']='年少雪吻:AwADCAMABRQAAA==.幽梦影:AwACCAIABRQAAA==.幽灵鲨:AwADCAUABAoAAA==.',['�']='强韧无敌最强:AwAICBEABAoAAREAPEoDCAUABRQ=.',['�']='影之愤怒:AwAICB4ABAoCDgAIAQhODwBTmaACBAoADgAIAQhODwBTmaACBAoAAA==.',['�']='徐总牛逼:AwAECAQABRQAAA==.德德鲁的逆袭:AwAGCAsABAoAAA==.',['�']='恶魔之歌:AwACCAIABAoAAA==.恶魔破晓:AwABCAQABRQCDgAHAQh1LwBDhtgBBAoADgAHAQh1LwBDhtgBBAoAAA==.',['�']='我将带头冲釒:AwADCAUABRQCEQADAQiABAA8SgEBBRQAEQADAQiABAA8SgEBBRQAAA==.我就是小红:AwADCAkABRQCEgADAQh1AgAwNO0ABRQAEgADAQh1AgAwNO0ABRQAAA==.我非落花:AwACCAIABRQAAA==.战争大师黑角:AwABCAEABAoAAA==.戦颜丶雪伊:AwABCAEABAoAAA==.',['�']='拉奥:AwAICAkABAoAAA==.',['�']='文姜:AwACCAIABAoAAA==.文钞钞:AwAICA8ABAoAARMAT2YGCAIABRQ=.',['�']='无情的大哥:AwAECAQABAoAAA==.无情的梅子:AwACCAIABRQAAA==.无情的梨子:AwADCAwABRQCFAADAQg9BABeWz0BBRQAFAADAQg9BABeWz0BBRQAAA==.无花果:AwAICAgABRQCCQAIAQgKAAAyXpcCBRQACQAIAQgKAAAyXpcCBRQAAA==.',['�']='晨光牧:AwAHCAkABAoAAA==.',['�']='暗炉堡钢蛋儿:AwAECAQABAoAAA==.暮雪海棠:AwADCAMABAoAAA==.',['�']='曦月情:AwACCAIABRQAARUAKwUGCAYABRQ=.',['�']='极度砖砖:AwAGCBAABAoAAA==.林深不知处:AwADCAMABRQAAA==.',['�']='柚酱:AwAFCAUABAoAAA==.柳北奥沙利文:AwACCAIABAoAAA==.',['�']='格琳希尔:AwAHCBEABAoAAA==.',['�']='桑贾尔:AwAGCBIABAoAAA==.',['�']='榴芒:AwAGCAMABRQAAA==.',['�']='殇玥:AwAECAgABRQDFgAEAQhCCAA93foABRQAFgAEAQhCCAA93foABRQAFwAEAQj6EQAauc8ABRQAAA==.',['�']='没法捏脸啊:AwADCAsABRQEGAADAQgEGAAgB4UABRQAGAACAQgEGAAf/4UABRQAGQABAQhuIwAF4zwABRQABQABAQj9IQABqy0ABRQAAA==.河莉秀:AwACCAIABAoAAA==.',['�']='泡馍:AwAICAkABAoAAA==.',['�']='洗猫:AwAICBEABAoAAA==.洛妮卡:AwAFCA0ABAoAAA==.洛德曼:AwADCAMABAoAAA==.',['�']='流光斜:AwAGCAYABAoAAA==.流萤:AwAGCA8ABAoAAA==.',['�']='消失的锤子:AwAECAQABAoAAA==.',['�']='演丶丶员:AwAICA0ABAoAAA==.',['�']='爬墙看美女:AwAECAQABRQAAA==.',['�']='牧牧姐:AwACCAIABRQAAA==.',['�']='狐人总冠军:AwAGCBIABAoAAA==.独爱小宝:AwABCAEABAoAAA==.',['�']='玛尔斯:AwADCAsABRQCBwADAQgJBwBTkS4BBRQABwADAQgJBwBTkS4BBRQAAA==.',['�']='瓦丨解:AwAECAQABAoAAA==.',['�']='當归:AwAECAMABAoAAA==.',['�']='白天做梦:AwAFCAkABAoAAA==.白木公主:AwAICA8ABAoAAA==.',['�']='硬玩火法:AwAICAcABAoAAA==.',['�']='祝踏岚:AwAGCBgABAoDGgAGAQibIQBR1MsBBAoAGgAGAQibIQBR1MsBBAoAGwACAQgIVgA6/IYABAoAAA==.',['�']='笨笨的小熊:AwAHCAgABAoAAA==.第亿代死神:AwAECAQABRQAARMAVZkICAIABRQ=.第十类危险品:AwAICAIABAoAAA==.',['�']='紫妮:AwADCAsABRQDHAADAQixAAA4gQgBBRQAHAADAQixAAA4gQgBBRQABgACAQhaMAAqoX8ABRQAAA==.紫色猫灵:AwAECAgABRQCCAAEAQh1DAAT67AABRQACAAEAQh1DAAT67AABRQAAA==.',['�']='给我三百块:AwADCAMABAoAAA==.',['�']='羊驼大仙:AwAICAQABAoAAA==.',['�']='老白丶:AwAGCBQABAoCBAAGAQiPLwBKY5UBBAoABAAGAQiPLwBKY5UBBAoAAA==.',['�']='肉粉:AwADCAMABAoAAA==.',['�']='脱水水:AwAICAYABAoAAA==.',['�']='芒果很黄:AwAICAgABAoAAA==.',['�']='苏暖暖:AwAGCAoABRQDHQAGAQigAABPUfcBBRQAHQAGAQigAABPUfcBBRQAHgAEAQigBAAM1KUABRQAAA==.',['�']='草莓小熊软糖:AwAFCAEABAoAAA==.荻荻:AwAHCAoABAoAAA==.',['�']='萝莉骑士:AwAECAgABRQCBwAEAQhXEAA+6gYBBRQABwAEAQhXEAA+6gYBBRQAAA==.落九天:AwADCAgABRQDCQADAQjDCgA3pPkABRQACQADAQjDCgA3pPkABRQACgABAQjlHQAlLjcABRQAAA==.',['�']='蓝色悠闲:AwAECAUABAoAAA==.',['�']='蕾娜菈丶:AwABCAEABRQAAA==.',['�']='薄暮回风:AwADCAEABAoAAA==.',['�']='蘑菇爆:AwADCAwABRQCFwADAQj6BwBGqQkBBRQAFwADAQj6BwBGqQkBBRQAAA==.',['�']='虎跑梦泉:AwACCAIABAoAAA==.虚空布丁:AwACCAIABAoAAA==.',['�']='蛇喰梦子:AwAGCAIABAoAAA==.',['�']='见悉牡师:AwAHCAcABAoAAA==.',['�']='贱佑萌:AwABCAEABRQCBQAIAQjJMgAiIlIBBAoABQAIAQjJMgAiIlIBBAoAAA==.贱宥萌:AwAGCAkABAoAAA==.贱贱的蛋炒饭:AwAICAgABAoAAA==.',['�']='超炸的文少爷:AwACCAIABRQAAA==.',['�']='进击的涛砸丶:AwAGCAYABAoAAA==.迷提布莉姆:AwAFCA8ABAoAAA==.',['�']='邝恭:AwAGCAcABAoAAA==.',['�']='醉意流年丶:AwAICAgABAoAAR0AD08ICAUABRQ=.',['�']='长门丶有希:AwACCAMABRQDBAAIAQh7CABcarUCBAoABAAIAQh7CABcarUCBAoAAwABAQg4kAAvQDwABAoAAA==.',['�']='闵行孙一峰:AwAGCAcABAoAAA==.',['�']='阿加洛斯:AwACCAIABAoAAA==.阿抽:AwAGCAYABAoAAA==.',['�']='陈丶风暴假酒:AwADCAsABRQCDAADAQhpAQBPUQ8BBRQADAADAQhpAQBPUQ8BBRQAAA==.陈丶风暴烈酒:AwACCAMABRQAAA==.',['�']='雪风楼柳如烟:AwACCAIABAoAAA==.雪风楼花魁:AwACCAUABRQDFwAIAQjjCABVRqACBAoAFwAIAQjjCABVRqACBAoAEwAIAQheEQBOr0wCBAoAAA==.雲柚雪:AwAECAQABAoAAA==.',['�']='青衣灬羽毛:AwAGCAkABRQDEQAGAQjxAAAxHqsBBRQAEQAGAQjxAAAph6sBBRQAEAADAQjZFgAvcqgABRQAARAAN1IICAkABRQ=.',['�']='风来吴山:AwAICBwABAoCAwAIAQiYIgBESxsCBAoAAwAIAQiYIgBESxsCBAoAAA==.',['�']='马中卢布:AwACCAUABRQCBwACAQhFLQAxOpUABRQABwACAQhFLQAxOpUABRQAAA==.',['�']='骁瑪:AwAFCAkABRQEDQAFAQj0AgA3UVQBBRQADQAEAQj0AgA8SFQBBRQADwABAQgYGAAjdkwABRQAHwABAQhcEwA23EUABRQAAA==.',['�']='鬼秋:AwAFCAoABAoAAA==.',['�']='魅影巫术:AwAFCAwABAoAAA==.魅影影风:AwAHCAoABAoAAA==.',['�']='鸡屁股的马仔:AwADCAwABRQCHQADAQjfBgBLMwcBBRQAHQADAQjfBgBLMwcBBRQAAA==.',['�']='默苍离:AwAECAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end