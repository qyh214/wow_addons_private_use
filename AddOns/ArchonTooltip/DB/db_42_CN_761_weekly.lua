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
 local lookup = {'DeathKnight-Blood','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Hunter-Marksmanship','Hunter-BeastMastery','Warrior-Fury','Mage-Frost','Priest-Discipline','Priest-Shadow','DemonHunter-Havoc','Shaman-Elemental','Monk-Mistweaver','Druid-Balance','Mage-Fire','Druid-Restoration','Druid-Feral','Paladin-Protection','DeathKnight-Unholy',}; local provider = {region='CN',realm='玛诺洛斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={As='Ash:AwAECAQABRQAAA==.',De='Deathknite:AwAECAQABRQCAQAEAQh2HwAqKAAABRQAAQAEAQh2HwAqKAAABRQAAA==.',Es='Escano:AwACCAIABRQAAA==.',Hi='Himmels:AwAICAgABAoAAA==.',In='Innocenc:AwAICAYABAoAAA==.',Me='Medog:AwABCAMABRQAAA==.',Qh='Qhnc:AwAECA8ABRQEAgAEAQhoCQBL6MQABRQAAgACAQhoCQBTUMQABRQAAwACAQjyFQBIQpkABRQABAABAQi5FgAAAAAABRQAAA==.Qhnw:AwAICAgABAoAAA==.',Ra='Raver:AwAGCA8ABRQDBQAGAQgLAABTQv0BBRQABQAGAQgLAABTQv0BBRQABgAEAQjWFQAxuOIABRQAAA==.',St='Stefe:AwAFCAEABAoAAA==.',Ur='Uria:AwAGCAYABRQCBwAEAQj8CwA25fsABRQABwAEAQj8CwA25fsABRQAAQcAF38HCAgABRQ=.',Wu='Wuxidixi:AwACCAgABRQCBgACAQgzGgBVEscABRQABgACAQgzGgBVEscABRQAAQgALBIDCAYABRQ=.',['�']='一点回忆:AwAECAQABRQAAA==.七叶树之魂:AwAFCAEABAoAAA==.七年光景:AwABCAMABRQDCQAIAQhNBABbuMECBAoACQAIAQhNBABbuMECBAoACgABAQhIWgBQj10ABAoAAA==.世界第一坦:AwADCAYABRQCAQADAQhfEgAPT4UABRQAAQADAQhfEgAPT4UABRQAAA==.世界萨:AwADCAMABAoAAA==.丝般幼滑:AwABCAEABRQAAA==.丨焦爺丨:AwAICAgABAoAAA==.丨蕃茄丨:AwACCAYABRQCCwAEAQi2JgAw/00ABRQACwAEAQi2JgAw/00ABRQAAQsAK2YGCAYABRQ=.为什么要我奶:AwAECAQABRQAAA==.丽贝卡卡哟:AwAECAQABRQAAA==.',['�']='乌瑟尔的左手:AwAICAgABAoAAA==.',['�']='二营长:AwAFCAUABAoAAA==.',['�']='任意豪赌:AwABCAEABRQAAA==.',['�']='佑灬:AwAECAQABRQAAA==.',['�']='修罗氵七宗罪:AwAICAcABAoAAA==.',['�']='元首丶愤怒了:AwAGCAYABAoAAA==.全垒僧:AwAGCAQABRQAAA==.全垒手:AwAICA4ABAoAAA==.',['�']='剑抹天河:AwADCAIABRQAAA==.',['�']='北极村的希望:AwAICAgABAoAAA==.',['�']='华丽打击:AwACCAEABRQAAA==.卑微小帅:AwABCAEABRQAAA==.卡斯比:AwAECAQABRQAAQwAVZkICAIABRQ=.',['�']='可爱的汤包:AwADCAoABRQCDQADAQiADgAlUtoABRQADQADAQiADgAlUtoABRQAAA==.叶子飘然:AwACCAIABAoAAA==.',['�']='土豆骑士:AwAECAQABRQAAA==.圣光与你同在:AwABCAEABAoAAA==.圣光之耀:AwAICAcABAoAAQ4AVtkGCAcABRQ=.',['�']='堂庭:AwAGCAEABRQAAA==.',['�']='墨染丶:AwACCAMABRQCDwAIAQgoIwBC7xICBAoADwAIAQgoIwBC7xICBAoAAA==.墨灬凌:AwACCAIABAoAAA==.',['�']='大叔的荣耀:AwACCAMABRQAAA==.天啊丶你真高:AwAICAgABAoAAA==.天国的倒计时:AwAICAcABAoAAA==.',['�']='将错就错:AwAECAUABAoAAA==.小能貓:AwABCAMABRQAAA==.',['�']='帕雷托:AwAICBIABAoAAA==.帕雷托的骑士:AwAICAkABAoAAA==.',['�']='式部帆夏:AwAECAQABRQAAA==.',['�']='德哩德气:AwAICAgABAoAAA==.',['�']='忠不可言:AwACCAEABRQEDgAIAQg5KQBOd/ABBAoADgAIAQg5KQBOd/ABBAoAEAABAQi3dAApVjgABAoAEQABAQgnLQAEkxEABAoAAA==.',['�']='恋凌凌:AwADCAIABAoAAA==.',['�']='悄悄片:AwACCAIABRQAAA==.',['�']='情丶未央:AwAECAQABRQAAA==.',['�']='星光小鴨:AwACCAQABRQAAA==.星际争霸:AwABCAEABAoAAA==.映射:AwABCAEABRQAAA==.',['�']='晋麒:AwAICAgABAoAAA==.',['�']='暮雨晨曦:AwAFCAQABAoAAA==.暴走小丸子:AwAICAYABAoAAA==.暴躁小小果:AwAECAQABRQAAA==.',['�']='最强地板王:AwAECAQABRQAAA==.最终审判:AwAECAQABRQAAA==.朦朦恶魔:AwAGCA4ABAoAAA==.',['�']='柳炎:AwAECAQABRQAAA==.',['�']='棒棒冰:AwACCAIABRQAAA==.',['�']='水里游的鱼:AwABCAEABRQAAA==.',['�']='江南奶绿:AwACCAIABRQAAA==.江南子:AwAICAgABAoAAA==.',['�']='沉默圣光:AwABCAEABAoAAA==.沉默的懒羊羊:AwAGCAcABAoAAA==.',['�']='浓浓曲奇:AwACCAIABAoAAA==.',['�']='演技派丶:AwABCAEABRQAAA==.',['�']='灬巴哈姆特灬:AwAGCAIABRQAAA==.',['�']='热卤电视机:AwACCAIABRQAAA==.',['�']='熊熊:AwAECAQABAoAAA==.',['�']='牛可:AwAECAQABRQAAA==.',['�']='狼教授:AwAGCA4ABAoAAA==.',['�']='猫也笨笨:AwABCAMABRQAAA==.',['�']='王司徒:AwAGCA4ABRQCCwAGAQjFAQAq3qwBBRQACwAGAQjFAQAq3qwBBRQAAA==.玖月:AwACCAQABRQCEgAIAQjyFQAzkJEBBAoAEgAIAQjyFQAzkJEBBAoAAA==.',['�']='瑪麗婭:AwAGCAIABRQAAA==.',['�']='白附子:AwAICA0ABAoAAA==.',['�']='砍你没商量:AwABCAIABRQAAA==.',['�']='祀溢:AwACCAMABRQAAA==.神罚之箭:AwAGCAIABAoAAA==.祭血关山:AwABCAMABRQAAA==.',['�']='素羽:AwAICAYABAoAAA==.素顔丶:AwADCAIABAoAAA==.',['�']='綠嗏灬:AwAGCA4ABRQCBwAGAQhPAwBQVT8BBRQABwAGAQhPAwBQVT8BBRQAAA==.',['�']='继续么么:AwAECAgABRQDEwAEAQjhCABE+f4ABRQAEwAEAQjhCABEBP4ABRQAAQAEAQg+CwAwW70ABRQAAA==.绿洲星珑:AwACCAIABAoAAA==.',['�']='莎缇拉:AwADCAUABAoAAA==.',['�']='萌萌哒唯一酱:AwAECAQABRQAAA==.萤之光:AwAECAYABRQCBQAEAQiUAwBJOBABBRQABQAEAQiUAwBJOBABBRQAAA==.',['�']='虾仁不眨眼:AwABCAEABRQAAA==.',['�']='血色圣教军:AwAHCAcABAoAAA==.',['�']='诗鸣画妳:AwACCAIABAoAAA==.',['�']='辣鸡尼光:AwAECAYABRQDAQAEAQgQCwAz4b8ABRQAAQAEAQgQCwAyRb8ABRQAEwACAQg4GwAmhH4ABRQAAA==.',['�']='迈扣唐小葶:AwAGCAYABAoAAA==.远山小纱幔:AwAGCAsABAoAAA==.远山要爆发:AwABCAEABAoAAA==.迪菲亚夜行者:AwAECAQABAoAAA==.',['�']='邪恶摇粒绒:AwAECAQABRQAAA==.',['�']='醉爱砂锅鱼头:AwACCAMABRQAAA==.',['�']='野蛮射尊:AwABCAEABRQAAA==.',['�']='闪舞精灵:AwABCAMABRQAAA==.',['�']='阿萨斯的禁脔:AwADCAMABAoAAA==.',['�']='陪小雨看星星:AwAICBAABAoAAQgARgAHCAcABRQ=.',['�']='香辣避雷针:AwAICAgABAoAAA==.',['�']='鸢尾花的回憶:AwAECAQABRQAAQ8AQ8QICAcABRQ=.',['�']='黄昏:AwAECAgABRQCCwADAQg9CgBAqAkBBRQACwADAQg9CgBAqAkBBRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end