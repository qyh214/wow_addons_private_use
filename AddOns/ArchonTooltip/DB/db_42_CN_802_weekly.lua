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
 local lookup = {'DeathKnight-Blood','Unknown-Unknown','Hunter-Marksmanship','Druid-Feral','Monk-Mistweaver','Paladin-Retribution','Mage-Frost','Mage-Fire','Hunter-BeastMastery','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','DeathKnight-Unholy','Druid-Balance','Shaman-Elemental','Shaman-Restoration','Priest-Shadow',}; local provider = {region='CN',realm='艾莫莉丝',name='CN',type='weekly',zone=42,date='2025-04-15',data={Ca='Carryorange:AwACCAIABRQAAA==.',Cr='Crimanal:AwABCAEABRQAAA==.',Dz='Dzsz:AwACCAIABRQAAA==.',Ma='Mageslayer:AwACCAMABRQAAA==.Marex:AwAECAQABRQAAA==.',Pk='Pknight:AwAECAQABRQAAA==.',Ti='Timoa:AwAFCA0ABAoAAA==.',To='Toyly:AwAICAcABAoAAA==.',['�']='一一萌萌哒:AwAGCAYABAoAAA==.一不行:AwABCAEABRQAAA==.一鹿向前:AwAECAYABAoAAA==.上官月半核心:AwADCAMABRQAAA==.东京的夏天热:AwADCAMABAoAAA==.丨五彩凉山丶:AwACCAMABRQAAA==.丶羊过小龙女:AwAICAgABAoAAA==.丷天若澜丷:AwAHCAcABAoAAA==.',['�']='人形自走图腾:AwAICA4ABAoAAA==.',['�']='信仰丶默默:AwAECAQABRQAAA==.',['�']='假若时光有眼:AwAGCAYABAoAAA==.',['�']='内陆帝国:AwAECAgABRQCAQAEAQj/CwA0xsIABRQAAQAEAQj/CwA0xsIABRQAAQIAAAAGCAQABRQ=.',['�']='准备受死吧:AwAECAQABRQAAQMAU0MECAoABRQ=.',['�']='利爪之傲:AwACCAIABRQCBAAIAQhoCAA7ySoCBAoABAAIAQhoCAA7ySoCBAoAAA==.刹风:AwAECAQABRQAAQUAOigGCAoABRQ=.刹风之神:AwAECAIABRQAAA==.',['�']='北丧:AwABCAIABRQAAA==.',['�']='卡诺:AwAGCAUABAoAAA==.',['�']='双木林:AwABCAEABRQAAA==.',['�']='哈尔扎克:AwAGCAMABRQAAA==.',['�']='圣光橡皮擦:AwAECAoABRQCBgAEAQhHBABfaEcBBRQABgAEAQhHBABfaEcBBRQAAA==.圣光的彼岸:AwAFCAUABAoAAA==.圣族丨騎丶:AwAECAQABRQAAA==.圣殿铁骑:AwAICAgABAoAAA==.',['�']='城与诚:AwACCAIABAoAAA==.城南花已开:AwAECAQABRQAAA==.',['�']='墨咖啡:AwACCAIABRQAAA==.',['�']='夕照神灬:AwABCAEABRQAAA==.夜丨狐妖:AwAECAUABRQDBwAIAQhWFgBGJjICBAoABwAIAQhWFgBGJjICBAoACAAGAQjdXQAWreQABAoAAA==.夜幕殺手:AwAECAQABRQAAA==.夜灬你妹:AwAECAoABRQDAwAEAQiHAgBTQygBBRQAAwAEAQiHAgBTQygBBRQACQACAQiHLwAjVoIABRQAAA==.',['�']='奶糖爸爸:AwAECAQABRQAAA==.',['�']='姑娘有点儿虎:AwAFCAYABAoAAA==.',['�']='安由心生:AwAECAgABAoAAA==.',['�']='寒舞清玥:AwAECAQABRQAAA==.',['�']='小太孑奶:AwAECAMABRQAAQIAAAAICAIABRQ=.小子不要走:AwACCAIABRQAAA==.小小斯温:AwAECAQABRQAAA==.小易生:AwAFCAoABAoAAA==.小莲:AwAFCAoABAoAAA==.小青椒灬:AwAECAYABRQDAwAEAQhfBQBWAgUBBRQAAwAEAQhfBQBWAgUBBRQACQACAQgcMwAVGHMABRQAAA==.尛杏杏:AwABCAEABRQAAA==.',['�']='山与:AwAFCAwABRQECgAEAQi1AgBOFx0BBRQACgAEAQi1AgBOFx0BBRQACwAEAQhbEwAcS78ABRQADAABAQg5GAAAAAAABRQAAA==.',['�']='幻梦之晓:AwAICAgABAoAAA==.',['�']='惩罚者古儿麻:AwAICAgABAoAAA==.',['�']='我没有奶水:AwACCAcABRQCBgACAQg+NwAVVXcABRQABgACAQg+NwAVVXcABRQAAA==.我肥来了:AwAICAgABAoAAA==.',['�']='撵鸡斗狗:AwAICAgABAoAAA==.',['�']='显卡克星:AwAECAQABRQAAA==.',['�']='枪杆:AwABCAEABRQAAA==.',['�']='楊戬:AwACCAIABAoAAA==.楽伊禮:AwAECAQABRQAAA==.',['�']='橘子妹妹最乖:AwAFCAkABAoAAA==.橙子耍牛虻:AwAHCAcABRQCDQAHAQhvAAAjufsBBRQADQAHAQhvAAAjufsBBRQAAA==.',['�']='欣谣:AwAICAgABAoAAA==.',['�']='死小骑:AwAICAMABAoAAA==.',['�']='毛毛哒:AwABCAEABRQCCQAIAQjiJgBI/kQCBAoACQAIAQjiJgBI/kQCBAoAAA==.',['�']='涅槃火鳳:AwABCAEABRQAAA==.',['�']='清水无鱼:AwAECAQABRQAAA==.',['�']='灬兔子兔灬:AwAICAgABAoAAA==.',['�']='爱笑的朵拉:AwAECAQABRQAAQ4AMF4GCAwABRQ=.',['�']='王小样:AwADCAMABAoAAA==.',['�']='真羽千夜:AwAICA0ABAoAAA==.',['�']='碧萝黄泉:AwAHCA0ABAoAAA==.',['�']='神戟:AwAICAgABAoAAA==.',['�']='空谷乌龙青:AwACCAIABRQAAA==.',['�']='筱丿凯凯:AwAICAgABAoAAA==.',['�']='纯爱牛骑士:AwAICAkABAoAAA==.',['�']='羊排盖浇面:AwAICAgABAoAAA==.',['�']='翠咖啡:AwABCAEABRQAAA==.',['�']='艾克丶:AwABCAEABRQAAA==.',['�']='菟牙:AwAECAQABRQCCwAEAQiDAwBgg0QBBRQACwAEAQiDAwBgg0QBBRQAAA==.',['�']='萧柒月:AwAECAQABRQAAA==.',['�']='表酱紫看我:AwAECAQABRQAAQYANhoGCAYABRQ=.',['�']='西溪吼吼:AwAICAIABAoAAA==.',['�']='转身后微笑:AwABCAEABRQAAA==.',['�']='都别理我:AwAECAEABAoAAA==.',['�']='酌酒揽清秋:AwACCAIABRQAAA==.酩酊奥特曼:AwAECAQABRQAAA==.',['�']='阿鬼教你电:AwAECAgABRQDDwAEAQjuBwA0AuIABRQADwAEAQjuBwA0AuIABRQAEAAEAQh6FwAGHqgABRQAAREANl0GCAoABRQ=.',['�']='青潇潇易水寒:AwAHCA4ABAoAAA==.',['�']='颍月:AwAECAQABRQAAA==.',['�']='风向之水瓶:AwAHCAoABAoAAA==.飘飘熊:AwAICAgABAoAAA==.',['�']='餐桌术卷轴:AwAICBkABAoCCAAIAQgaMAAyLNEBBAoACAAIAQgaMAAyLNEBBAoAAA==.',['�']='齐逼白衬衫:AwAICBcABAoCBwAIAQjzIQA2B+EBBAoABwAIAQjzIQA2B+EBBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end