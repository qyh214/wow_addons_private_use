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
 local lookup = {'Druid-Balance','Priest-Shadow','Warlock-Destruction','Evoker-Preservation','Evoker-Devastation','Paladin-Retribution','Monk-Mistweaver','DeathKnight-Unholy','Unknown-Unknown','Hunter-BeastMastery','Mage-Fire','DeathKnight-Frost','Monk-Windwalker','Shaman-Elemental','Shaman-Restoration','Paladin-Holy','Priest-Discipline','DeathKnight-Blood','Warrior-Arms','Shaman-Any','Druid-Restoration','Rogue-Subtlety','Rogue-Assassination','Mage-Frost',}; local provider = {region='CN',realm='熵魔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Do='Doken:AwAICBEABAoAAQEAVtkGCAcABRQ=.',Dr='Drail:AwABCAEABRQCAgAIAQgDFgBAtQwCBAoAAgAIAQgDFgBAtQwCBAoAAA==.',Je='Jesse:AwADCAYABRQCAwADAQizEAAfKcQABRQAAwADAQizEAAfKcQABRQAAA==.',Ko='Kous:AwACCAIABRQAAA==.',Lm='Lmn:AwAGCAoABRQCBAAEAQgmAwAw7MsABRQABAAEAQgmAwAw7MsABRQAAQUAD08ICAUABRQ=.',Lo='Losointa:AwAGCBEABAoAAA==.',Ni='Nishizhu:AwABCAEABRQAAA==.',Uz='Uzi:AwAGCAIABRQAAA==.',['�']='一个奶爸:AwABCAEABRQAAA==.一亚瑟王一:AwAECAgABRQCBgAEAQjgGgAjJtoABRQABgAEAQjgGgAjJtoABRQAAA==.一刀掌死你:AwAICAEABAoAAA==.一大波茄子:AwAHCAcABAoAAA==.一脚不小心:AwAICBYABAoCBwAIAQjsIgAyRroBBAoABwAIAQjsIgAyRroBBAoAAA==.三角函数嫖哥:AwAECAcABRQCBgAEAQi2DQBOvgkBBRQABgAEAQi2DQBOvgkBBRQAAA==.不洁至高王:AwAICA0ABAoAAQgAO04GCBAABRQ=.严禁期待:AwAFCAwABAoAAA==.',['�']='你愁啥:AwAICBAABAoAAQkAAAAICAEABRQ=.',['�']='公牛的血:AwAECAEABRQAAQkAAAAICAIABRQ=.',['�']='准备脱战:AwADCAMABAoAAA==.',['�']='北门教父:AwADCAMABAoAAA==.',['�']='卓文君:AwAECAQABAoAAA==.卡列乌斯:AwAECAQABRQAAQkAAAAICAIABRQ=.',['�']='叔叔的果粒橙:AwAGCAcABAoAAA==.只会乱射打怪:AwACCAIABRQAAA==.只会睡觉的鱼:AwAFCBIABRQCBwAFAQhkAQBYw6oBBRQABwAFAQhkAQBYw6oBBRQAAA==.',['�']='吴不在:AwADCAMABRQAAA==.',['�']='呀呜一口:AwADCAMABRQAAA==.呂布:AwACCAMABRQAAA==.',['�']='夜听云海:AwAICBAABAoAAA==.夜鼠子:AwADCAMABAoAAA==.大木老師:AwABCAEABRQAAA==.大爱仙尊:AwADCAMABRQCCgADAQjIKAAW2osABRQACgADAQjIKAAW2osABRQAAA==.大羊肖恩:AwADCAMABAoAAA==.太难得的回忆:AwABCAEABRQAAA==.',['�']='奔跑的拉条子:AwAECAQABRQAAA==.女旦己:AwACCAIABAoAAA==.好男人老婆造:AwACCAIABAoAAA==.',['�']='婲開糀謝:AwABCAEABAoAAA==.',['�']='小狐:AwABCAEABRQAAA==.小羊肖恩:AwAFCAMABAoAAA==.',['�']='布林顿九千:AwAICBYABAoCCwAIAQglIwA/JBICBAoACwAIAQglIwA/JBICBAoAAA==.',['�']='张学友:AwAECAQABRQAAA==.',['�']='影灬:AwAECAQABAoAAA==.',['�']='心生万法:AwAFCAgABAoAAA==.快奶我:AwAICAgABAoAAA==.',['�']='怒气总不够:AwAICAgABAoAAA==.性感牛牛:AwAICAkABAoAAA==.',['�']='无双的王者:AwAECAQABRQAAA==.',['�']='春生夏长:AwAECAQABAoAAA==.',['�']='暴鲤龙:AwACCAIABRQAAA==.',['�']='替罪羔羊:AwAICA8ABAoAAA==.',['�']='枕大哥:AwAECAQABAoAAA==.林克时间:AwAECAkABRQCDAAEAQgSAQBG2B8BBRQADAAEAQgSAQBG2B8BBRQAAA==.果然多多鱼:AwACCAIABAoAAA==.',['�']='森林骑士:AwADCAMABAoAAA==.',['�']='止戦之殇:AwAECAQABRQAAQ0AWZcGCBkABRQ=.死亡绽放丶:AwABCAEABAoAAA==.',['�']='江流:AwABCAEABAoAAA==.',['�']='海鲜小馄饨:AwAECAQABRQAAA==.',['�']='潘达利亚:AwABCAEABRQDDgAIAQgeHwAziMMBBAoADgAIAQgeHwAziMMBBAoADwABAQhBpgAdODQABAoAAA==.',['�']='灬沐小雪灬:AwAGCAYABRQDEAAGAQg+AgARhRYBBRQAEAAFAQg+AgAQHBYBBRQABgABAQhxNwAT+FUABRQAAA==.',['�']='燕三十娘:AwABCAEABAoAAA==.',['�']='爱布拉娜:AwAICAEABAoAAA==.爱莉希雅:AwAICAIABAoAAA==.',['�']='牧師丶:AwABCAIABRQCEQAIAQgYHgA24K4BBAoAEQAIAQgYHgA24K4BBAoAAA==.',['�']='狂野:AwADCAEABAoAAA==.',['�']='猪猪拯救世界:AwAECAYABRQDEgAEAQhhCwAxGbwABRQAEgAEAQhhCwAv1rwABRQACAACAQgBGAA6QZQABRQAAA==.',['�']='疯狂猫咪:AwACCAIABAoAAA==.',['�']='盗了只柚子:AwABCAEABAoAAA==.',['�']='红头发魔鬼:AwAICAoABAoAAA==.',['�']='罗宾丶妮可:AwAGCAYABAoAAA==.',['�']='肌肉:AwAECAQABRQAAA==.',['�']='艾姆谢特:AwAECAQABRQAARMAS5IGCBAABRQ=.',['�']='苍崎青子丶:AwAECAcABAoAAA==.',['�']='茂茂总:AwABCAEABAoAAA==.',['�']='荒天骑:AwAECAQABRQAAQsAVEsICBAABRQ=.',['�']='莉凤:AwAGCAYABAoAAA==.',['�']='萨否赖你:AwAGCAYABRQDFAAGAAgAAABaSwAABRQADgABAAgAAABNXAAABRQADwAFAAgAAAACpAAABRQAAA==.萨鲁法克丶丶:AwACCAIABAoAARUAOkwGCAUABRQ=.',['�']='葬靈魂:AwACCAIABRQAAA==.',['�']='蔡妍丶:AwAECAQABAoAAA==.',['�']='蜡烛骑士:AwADCAMABAoAAA==.',['�']='血染过的凶器:AwAGCBAABAoAAA==.血色灬轩辕:AwACCAIABAoAAA==.',['�']='读来过倒才牛:AwAICBMABAoAAA==.读来过倒才犇:AwAFCAYABAoAAA==.',['�']='谨年丶:AwAGCAYABAoAAA==.',['�']='走过倒一片:AwAICAgABAoAAA==.',['�']='轶小宝:AwADCAIABRQDFgAIAQhCDQBF+xACBAoAFgAIAQhCDQA+JBACBAoAFwAIAQjoFAAuA7UBBAoAAA==.',['�']='辛德穆拉丶:AwAECAQABRQAAA==.达纳督斯:AwABCAEABRQAAA==.',['�']='野蛮的圣光:AwADCAEABAoAAA==.',['�']='锅碗瓢盆缸:AwACCAIABRQAAA==.',['�']='闇之子:AwACCAIABRQAAA==.',['�']='零食的包装袋:AwAICAMABAoAAA==.',['�']='青歌:AwABCAIABAoAAA==.',['�']='风傻傻:AwABCAEABRQAAA==.风舞痕:AwAGCA0ABAoAAA==.',['�']='骑猪去瓢:AwAECAYABRQCCgAEAQh0CgBJOBQBBRQACgAEAQh0CgBJOBQBBRQAAQkAAAAICAQABRQ=.',['�']='魂体三分:AwAECAQABRQAAA==.魔法小龟:AwAGCAQABRQDCwAIAQjJEgBRMXkCBAoACwAIAQjJEgBQ0HkCBAoAGAAGAQgEUAAyq/QABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end