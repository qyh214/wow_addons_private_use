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
 local lookup = {'Priest-Shadow','Unknown-Unknown','Warlock-Affliction','Warlock-Destruction','DeathKnight-Blood','Hunter-Marksmanship','Hunter-BeastMastery','Priest-Holy','Mage-Frost','Mage-Fire','Rogue-Subtlety','Rogue-Assassination','Druid-Restoration','Monk-Windwalker','Monk-Mistweaver','Shaman-Enhancement','Shaman-Restoration','Shaman-Elemental','Warrior-Protection','DemonHunter-Havoc','Druid-Balance','Mage-Arcane','Evoker-Devastation','Evoker-Preservation','Priest-Discipline','Paladin-Retribution',}; local provider = {region='CN',realm='法拉希姆',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ba='Babyms:AwAECAwABRQCAQAEAQi2BgBbABEBBRQAAQAEAQi2BgBbABEBBRQAAQIAAAAGCAQABRQ=.',Cr='Critcake:AwAECAIABRQAAA==.',De='Devils:AwADCAsABRQDAwADAQiQBwAlUd8ABRQAAwADAQiQBwAlUd8ABRQABAABAQiJKwASGzMABRQAAA==.',Do='Donut:AwACCAQABRQAAA==.',Gr='Grand:AwABCAEABRQAAA==.',Mo='Moodyblues:AwAGCAIABRQAAA==.',Re='Reapel:AwAHCAkABAoAAA==.',Ru='Ruler:AwABCAEABRQAAA==.',Ve='Venusqs:AwACCAQABRQAAA==.',Vv='Vvtanknewbie:AwAICBEABAoAAA==.',Za='Zarya:AwAICAkABAoAAA==.',['�']='一果可爱捏:AwADCAkABRQCBQADAQhSBABT7iUBBRQABQADAQhSBABT7iUBBRQAAQUAY3oICAoABRQ=.一殇:AwADCAMABAoAAA==.丶莉芳:AwACCAIABRQAAA==.丶齐柏林:AwACCAEABRQAAA==.为你活着:AwAECAQABRQAAA==.',['�']='乌瑞尔勋爵:AwACCAIABAoAAA==.乌瑞尔勛爵:AwAICAgABAoAAA==.',['�']='二狗骑士:AwAECAQABRQAAA==.',['�']='伊利双:AwAHCAcABAoAAA==.',['�']='傲视鱼儿:AwACCAMABRQAAA==.',['�']='凹凸曼:AwACCAQABRQAAA==.',['�']='刹那年华:AwACCAYABRQDBgACAQj4DQBU2q0ABRQABgACAQj4DQBU2q0ABRQABwABAQibOABE3kcABRQAAA==.',['�']='势不可挡土灵:AwAHCBAABAoAAA==.',['�']='吉米佩奇:AwABCAEABRQAAA==.吉羽令羽:AwAGCAEABAoAAA==.向曰葵不向曰:AwABCAEABRQCCAAIAQjLLAAoiWoBBAoACAAIAQjLLAAoiWoBBAoAAA==.听罢笛声:AwAECAQABAoAAA==.',['�']='喂我花生:AwAGCAcABAoAAA==.',['�']='囧囧丷:AwABCAEABRQCCQAIAQgbBQBd19oCBAoACQAIAQgbBQBd19oCBAoAAQoAT1sHCAUABRQ=.囧囧灬:AwAGCAYABAoAAA==.',['�']='圣丨骑士:AwAICA4ABAoAAA==.圣光宽恕你:AwAICAgABAoAAA==.',['�']='埃兰之赐:AwACCAIABRQAAA==.',['�']='塔兰克斯:AwACCAUABRQDCwACAQjtDAAJMXsABRQACwACAQjtDAAHeHsABRQADAABAQhoFAAIZDQABRQAAA==.',['�']='夏夕烟:AwAECAIABRQAAA==.夏芽:AwAECAQABRQAAA==.夜影舞:AwACCAMABAoAAA==.夺命牙签:AwACCAMABRQAAA==.',['�']='妮迪塔斯:AwACCAQABRQCCAAIAQhCEABLhC8CBAoACAAIAQhCEABLhC8CBAoAAA==.',['�']='婷婷熊:AwAICAwABAoAAA==.婷熊婷:AwAFCAUABAoAAA==.婷熊熊:AwADCAMABRQAAA==.',['�']='子夜梦:AwAECAQABRQAAQ0APyYICAsABRQ=.',['�']='宝贝人武:AwAECAQABRQDDgAIAQj9EQBGUjcCBAoADgAIAQj9EQBGUjcCBAoADwAHAQjdNgAtMUoBBAoAAQIAAAAGCAQABRQ=.',['�']='寂寞也狂欢:AwACCAIABRQEEAAIAQiYFwA+D/YBBAoAEAAIAQiYFwA8CPYBBAoAEQAGAQiEUgBErh4BBAoAEgACAQghWgAr6H4ABAoAAA==.寥小柒:AwAECAQABRQAAA==.',['�']='小迷途:AwAECAQABRQAAA==.尐乳豬:AwAHCAcABRQDDAAHAQg0AQAhGIoBBRQADAAEAQg0AQAhWYoBBRQACwADAQhKDAAgl4sABRQAAA==.',['�']='幽幽我歆:AwAECAEABAoAAA==.幽幽我芯:AwACCAIABAoAAA==.',['�']='强力迪凯:AwAICAgABAoAAA==.',['�']='影子白菜:AwABCAEABRQAAA==.影炙怒风:AwAFCAsABAoAAA==.',['�']='御坂灬天使:AwACCAgABRQCEgACAQj5BgBhcOMABRQAEgACAQj5BgBhcOMABRQAAA==.德丶兰妮:AwAECAQABRQAARAAM3YICAkABRQ=.德德小浣熊:AwAGCAYABAoAARMALyoICAoABRQ=.',['�']='怒涛卷霜雪:AwEECAQABRQAAQIAAAAICAMABRQ=.',['�']='慧宝宝:AwAECAcABAoAAA==.',['�']='我叫为难:AwACCAMABRQCBQAIAQjsCQBSCGkCBAoABQAIAQjsCQBSCGkCBAoAAA==.我叫牙套姐:AwADCAwABRQCBwADAQg7BwBWgCsBBRQABwADAQg7BwBWgCsBBRQAAA==.',['�']='断桥雪:AwACCAIABRQAARQAUoMGCAgABRQ=.',['�']='星空下的麦田:AwAGCAIABRQAAA==.',['�']='暗夜灬男:AwACCAMABRQDFQAIAQiHLQA4GtgBBAoAFQAIAQiHLQA4GtgBBAoADQADAQh6UgAtCZwABAoAAA==.暴走皮皮虾:AwAFCAUABAoAAA==.',['�']='月亮代表我心:AwABCAIABRQAAA==.术术得氵正:AwAECAQABAoAAA==.',['�']='林佳树:AwACCAEABRQECQAIAQjNGQBGnxACBAoACQAIAQjNGQBCqBACBAoAFgACAQj4EQBBNH4ABAoACgADAQjafAApxG8ABAoAAA==.枫林下线:AwACCAMABRQCDgAIAQhDEQBNIT4CBAoADgAIAQhDEQBNIT4CBAoAAA==.',['�']='橘子汽水丷:AwABCAEABAoAAA==.橘子的邂逅:AwAGCAYABAoAAA==.橙子萱:AwACCAIABAoAAA==.',['�']='死亡之丶毅驴:AwAFCAUABAoAAA==.死亡毅丶毅驴:AwAECAsABRQDFwAEAQjEBgBa8/0ABRQAFwAEAQjEBgBa8/0ABRQAGAACAQjiBQAmanoABRQAAA==.',['�']='残牙:AwAFCAMABAoAAA==.',['�']='氵大司命:AwAGCAsABAoAAA==.氷帝凯:AwAECAQABRQAAA==.',['�']='汪汪鱼鳍:AwACCAIABAoAAA==.',['�']='没断嘚弦:AwAHCAwABAoAAA==.',['�']='泽伊:AwACCAIABRQAAA==.',['�']='流氓包工头:AwAGCAcABAoAAA==.流风幻葬:AwACCAMABRQDBAAIAQitJQBFzs4BBAoABAAHAQitJQBEEc4BBAoAAwABAQjzMgBQO1wABAoAAA==.浮云若逝:AwACCAIABRQAAA==.海因特:AwAECAQABRQAAA==.',['�']='火华:AwAGCAYABAoAAA==.火油:AwAICAIABAoAAA==.',['�']='熊婷婷:AwAFCAYABAoAAA==.',['�']='燕知春:AwAGCA8ABRQDGQAGAQi/AAA7Js8BBRQAGQAGAQi/AAA6us8BBRQACAACAQjACgBYRcEABRQAAA==.',['�']='爱泽咲夜:AwAGCAgABAoAAA==.',['�']='狗得被人砍:AwAGCAUABRQCCgAEAQhGDAA4fAgBBRQACgAEAQhGDAA4fAgBBRQAAA==.',['�']='玛戈火热:AwACCAIABRQAAA==.',['�']='田心:AwAECAQABAoAAA==.',['�']='百夜擦:AwAICA0ABAoAAA==.',['�']='皮蛋配豆腐:AwADCAMABAoAAA==.',['�']='看眯咪:AwADCAwABRQCCAADAQj4BgA3pOQABRQACAADAQj4BgA3pOQABRQAAA==.',['�']='瞄准开炮:AwABCAEABRQAAA==.',['�']='知否知否:AwADCAMABRQAAQ8AIA0ICAMABRQ=.',['�']='神圣的蛋蛋:AwAICAkABAoAAA==.',['�']='纵横杀戮:AwAICAgABAoAAA==.',['�']='耗子欺负喵:AwABCAEABRQAAA==.',['�']='脑瓜子疼:AwACCAIABRQAAA==.',['�']='花海:AwAHCAsABAoAAA==.',['�']='萨满壮壮:AwAICBAABAoAAA==.',['�']='蘸血大黄瓜:AwAICAgABAoAARUARTUHCAcABRQ=.',['�']='蜜铃兰丨梅蒂:AwACCAYABRQCDQACAQhkBwBdx9gABRQADQACAQhkBwBdx9gABRQAAA==.',['�']='贰伍捌壹玖:AwABCAEABAoAAA==.贰柒:AwABCAEABRQAAQoAOHwGCAUABRQ=.',['�']='赶海的咕凉:AwAECAQABAoAAA==.',['�']='轻舞丸子:AwAGCAIABAoAAA==.',['�']='达斯黎各圭孫:AwAICAgABAoAAA==.',['�']='迷你土豆:AwAICAoABAoAAA==.追忆赤信号:AwAFCAIABAoAAA==.',['�']='逍遥仙:AwABCAEABAoAAA==.',['�']='邪眸奥特曼:AwAFCAUABAoAAA==.',['�']='钢铁侠:AwAICAEABAoAAA==.',['�']='银剑:AwABCAEABRQCGgAIAQigdQAjroQBBAoAGgAIAQigdQAjroQBBAoAAA==.',['�']='门先生:AwAHCAcABAoAAA==.',['�']='阿怪:AwAGCAUABAoAAA==.',['�']='随风而去:AwAECAQABRQAAQIAAAAICAQABRQ=.',['�']='霜印:AwADCAUABRQCCQADAQicBgAq8t0ABRQACQADAQicBgAq8t0ABRQAAA==.',['�']='靓晓蔚:AwAECAIABAoAAA==.',['�']='风轩大盗:AwAFCAIABRQAAA==.',['�']='饵丝:AwAGCAUABAoAAA==.',['�']='魔魚祈:AwAECAQABRQAAA==.',['�']='鲨氵钦:AwAECAIABAoAAA==.',['�']='黑皇哈特:AwAECAQABRQAAA==.黑鍋丨我来背:AwABCAIABRQCCAAIAQhNOAAd3TABBAoACAAIAQhNOAAd3TABBAoAAA==.',['�']='龙之召唤:AwACCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end