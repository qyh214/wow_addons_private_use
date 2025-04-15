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
 local lookup = {'Paladin-Retribution','Paladin-Holy','Paladin-Protection','Monk-Mistweaver','Priest-Discipline','Unknown-Unknown','Hunter-Marksmanship','Druid-Balance','Druid-Restoration','Druid-Guardian','DeathKnight-Unholy','Shaman-Restoration','Warlock-Affliction','Warlock-Destruction','Warrior-Fury','Monk-Windwalker','Monk-Brewmaster','Mage-Fire','Warrior-Arms','Shaman-Elemental',}; local provider = {region='CN',realm='能源舰',name='CN',type='weekly',zone=42,date='2025-04-15',data={An='Anubis:AwAHCBAABAoAAA==.',Cl='Claudias:AwAECAQABRQAAA==.',Cy='Cyanripple:AwAGCAwABAoAAA==.',De='Deepha:AwACCAMABRQAAA==.',Je='Jenniemantra:AwAGCAQABRQAAA==.',Re='Reolyujin:AwAICA4ABAoAAA==.',Se='Seraphine:AwAFCAYABAoAAA==.',Sh='Shakurass:AwAGCAcABAoAAA==.',Th='Thread:AwAICAgABAoAAA==.',Xu='Xuxutv:AwAECAQABRQAAA==.',Zx='Zxdfghujio:AwACCAIABAoAAA==.',['�']='一只大老鼠:AwACCAIABRQAAA==.一只耳:AwABCAEABRQAAA==.一粒丹丹:AwAECAQABRQAAA==.一语轻尘:AwAHCAcABAoAAA==.一醉浮生:AwAECAQABAoAAA==.三只小熊:AwAECAQABAoAAA==.三月七:AwAGCAcABAoAAA==.世界之灾:AwAGCAIABAoAAA==.临风:AwAGCAEABAoAAA==.丶轩辕凝听丶:AwAGCAYABAoAAA==.丸子烧饼:AwABCAIABRQEAQAIAQifNgBMoDQCBAoAAQAHAQifNgBUBTQCBAoAAgAHAQhEJQAR9QYBBAoAAwABAQhpXAAMahkABAoAAA==.',['�']='九紫离火:AwACCAMABRQAAA==.九老:AwACCAQABAoAAA==.',['�']='亚洲图片:AwAHCAcABAoAAA==.',['�']='伊德莉拉:AwAGCAoABAoAAA==.休闲佬:AwAICAgABAoAAA==.',['�']='光影行者艾琳:AwAECAQABRQAAA==.兜兜里有奶瓶:AwAECAQABAoAAA==.',['�']='冷凌霜彡:AwABCAEABAoAAA==.',['�']='凤凰飛飛:AwAECAQABRQAAA==.',['�']='力道大尼:AwAGCAYABAoAAQQAQnAHCAwABRQ=.',['�']='十三影:AwAICAUABAoAAA==.卖小孩的火柴:AwAFCA0ABAoAAA==.南飞的雁:AwAGCAkABAoAAA==.',['�']='咕噜咕噜咚咚:AwAFCBMABRQCBQAFAQgWAgBFpnUBBRQABQAFAQgWAgBFpnUBBRQAAQUAQRUGCAYABRQ=.',['�']='嚣聋人:AwAFCAUABAoAAA==.',['�']='回收废旧电瓶:AwAICBAABAoAAQYAAAAGCAMABRQ=.园园酱丶:AwAECAUABRQCBwAEAQjkAgBWMCIBBRQABwAEAQjkAgBWMCIBBRQAAA==.国服小骑士丶:AwABCAEABRQCAQAIAQgHOgBE8CgCBAoAAQAIAQgHOgBE8CgCBAoAAA==.',['�']='土灬豆君:AwAECAQABRQAAQgAVtkGCAcABRQ=.圣光背叛了我:AwAFCAcABAoAAA==.圣光跳:AwAGCAYABAoAAA==.圣光陶洛斯:AwAECAQABRQAAA==.地主:AwACCAIABAoAAA==.',['�']='壹八七靓仔:AwADCAMABAoAAA==.',['�']='夜灬微眠:AwAICAgABAoAAA==.天道花憐:AwAECAQABAoAAA==.',['�']='孙菜炖粉条:AwAHCA0ABAoAAA==.孤独与背叛:AwAECAgABRQDCAAEAQg8EQAyx+gABRQACAAEAQg8EQAyx+gABRQACQAEAQgIDAAZjrQABRQAAA==.',['�']='寒芒壹点:AwAGCAYABAoAAA==.寒芒点点:AwAGCAoABAoAAA==.',['�']='小猪丶乔治:AwAECAQABRQAAA==.小血僧:AwABCAEABRQCBAAIAQjgNgAhfFMBBAoABAAIAQjgNgAhfFMBBAoAAA==.尖尖的小耳朵:AwAECAUABRQCBwAEAQg2DQAnr8oABRQABwAEAQg2DQAnr8oABRQAAA==.',['�']='川井:AwABCAEABAoAAQYAAAAGCAYABAo=.',['�']='德不倒得了:AwACCAUABRQCCgAIAQgNCwAwLHkBBAoACgAIAQgNCwAwLHkBBAoAAA==.',['�']='戒赌者旭东:AwAHCAgABAoAAA==.',['�']='打麻将从不输:AwADCAMABAoAAA==.打麻将最牛:AwAGCAYABAoAAA==.',['�']='拖鞋:AwADCAMABAoAAA==.拜山华:AwAECAQABRQAAQYAAAAICAEABRQ=.',['�']='挽歌:AwACCAUABRQCCwACAQjfFgBPVaYABRQACwACAQjfFgBPVaYABRQAAA==.',['�']='新手保护期:AwAECAQABRQAAA==.',['�']='无天无夜:AwAGCAYABAoAAA==.无敌搓炉石:AwABCAIABAoAAA==.',['�']='星空落:AwAECAQABRQCAQAIAQgmMQBKJkcCBAoAAQAIAQgmMQBKJkcCBAoAAA==.星鳗天妇罗:AwAECAQABRQCDAAEAQg3DAAqzu0ABRQADAAEAQg3DAAqzu0ABRQAAA==.是我冒饭了:AwAICBQABAoCAQAIAQjDTAA8dfEBBAoAAQAIAQjDTAA8dfEBBAoAAA==.是觉觉呀:AwADCAMABRQAAA==.',['�']='普拉:AwAICAEABAoAAA==.',['�']='曼陀罗夜来袭:AwAECAQABAoAAA==.',['�']='杰灬小克:AwACCAIABAoAAA==.',['�']='果家的胡萝卜:AwAHCAcABAoAAA==.',['�']='核桃核桃:AwAGCAcABAoAAA==.',['�']='梦玲珑:AwAGCAYABAoAAA==.梦魇丶躺尸侠:AwAECAYABRQDDQAEAQg9BABA8QcBBRQADQAEAQg9BABA8QcBBRQADgACAQhsJQASUE4ABRQAAA==.',['�']='椰丝觅洛:AwAICAgABAoAAA==.',['�']='死骑士:AwAFCAUABAoAAA==.',['�']='江小帅:AwAECAQABRQAAA==.',['�']='沫羽儿:AwAECAQABRQAAA==.',['�']='洛天依:AwADCAMABAoAAA==.',['�']='浅浅初荷嵐:AwAGCAwABAoAAA==.',['�']='清欢:AwABCAEABAoAAA==.',['�']='灬我是传奇:AwAICBQABAoCDwAIAQhqMwAaaZYBBAoADwAIAQhqMwAaaZYBBAoAAA==.灬铁铁灬:AwAHCBEABAoAAA==.灵动哈哈:AwACCAIABRQAAA==.',['�']='熊抓鱼么:AwAICBQABAoDEAAIAQgfCgBWdJQCBAoAEAAIAQgfCgBWdJQCBAoAEQAGAQg9FQAuc8gABAoAARIAMkEGCAgABRQ=.',['�']='爽脆牛肉丝:AwABCAIABRQAAA==.',['�']='牛牛两只角:AwABCAEABRQAAA==.',['�']='狂奔的圣骑:AwACCAMABRQAAA==.狂奔的戰牛:AwACCAIABRQDEwAIAQg/CQBSv28CBAoAEwAIAQg/CQBK3m8CBAoADwAIAQjOGgBM0iUCBAoAAA==.狂奔的骑士:AwACCAUABRQCCwACAQj+GQAmUZcABRQACwACAQj+GQAmUZcABRQAAA==.',['�']='猎骨者巴托:AwAECAgABRQCBwAEAQiACQA7euQABRQABwAEAQiACQA7euQABRQAAA==.',['�']='男人猫:AwAICAgABAoAAA==.',['�']='疯狂的红包:AwADCAMABAoAAA==.',['�']='白色黑裤衩:AwAICAcABAoAAA==.',['�']='相濡以沫:AwAECAcABRQCEgAEAQgOHAAeV9QABRQAEgAEAQgOHAAeV9QABRQAAA==.',['�']='砍人的人:AwADCAMABAoAAA==.',['�']='神偷小颂可:AwAECAQABRQAAA==.神帝:AwAICAwABAoAARIAMkEGCAgABRQ=.',['�']='离开离开:AwACCAIABAoAAA==.',['�']='笑嘻嘻骑士:AwACCAIABAoAAA==.',['�']='粉粉的烧饼:AwADCAMABAoAAA==.',['�']='糖藏蛮娜:AwAECAQABAoAAA==.',['�']='索菲亚的复苏:AwAFCAUABAoAAA==.索西娅红莲:AwAFCAUABAoAAA==.',['�']='红色体育生:AwAGCAYABAoAAA==.',['�']='终末之冬:AwAFCAUABAoAAA==.',['�']='聖光丶妙脆角:AwAGCAYABAoAAA==.',['�']='肥肠侠:AwAICAwABAoAAA==.',['�']='航海家:AwAECAQABAoAAA==.',['�']='草莓布丁:AwACCAIABRQAAA==.',['�']='莉丽安:AwAICAgABAoAAA==.莳绱的調調:AwAECAQABAoAAA==.',['�']='菜鸟保护期:AwABCAEABAoAAA==.',['�']='萌乄哒哒的牛:AwACCAIABAoAAA==.',['�']='血兽爱我:AwAECAQABRQAAA==.',['�']='赤之新月:AwAFCAUABAoAAA==.赤月:AwAECAUABAoAAA==.',['�']='辛德维拉:AwAHCAYABAoAAA==.',['�']='遗忘的悲伤:AwAHCAcABAoAAA==.',['�']='都敏俊丶:AwAICAgABAoAAA==.',['�']='酒醒香满怀:AwADCAsABRQCAQADAQghDwBHLwoBBRQAAQADAQghDwBHLwoBBRQAAA==.酷酷的小骑士:AwACCAIABAoAAA==.',['�']='闪电帕丁熊:AwAGCA4ABRQDFAAGAQgXAABA7+4BBRQAFAAGAQgXAABA7+4BBRQADAAEAQgoDAA2M+0ABRQAAA==.',['�']='阿布罗蒂:AwAFCAUABAoAAA==.',['�']='雨无情:AwAECAQABAoAAA==.雷电法皇永信:AwAECA8ABRQCDAAEAQhQBQBUOSABBRQADAAEAQhQBQBUOSABBRQAAA==.',['�']='風中的獸王:AwAICA0ABAoAAA==.',['�']='风之叹息:AwAICA4ABAoAAA==.风叶无痕:AwAGCAYABAoAAA==.风吹蛋碎一地:AwACCAIABAoAAA==.',['�']='馨神龙:AwACCAIABRQAAA==.',['�']='黯嘚识邓:AwAFCAUABAoAAA==.',['�']='龙之吻:AwAECAQABRQAAQYAAAAGCAQABRQ=.龙飞凤舞:AwAICBwABAoCAQAIAQgfEgBZ6cMCBAoAAQAIAQgfEgBZ6cMCBAoAAA==.龙鹤双形:AwAFCAEABRQAAREAKpAGCAwABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end