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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Rogue-Assassination','Mage-Fire','Druid-Restoration','Druid-Balance','Unknown-Unknown','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Warrior-Fury','Warrior-Arms','Warrior-Protection','Priest-Holy','Priest-Discipline','Priest-Shadow','Hunter-BeastMastery','DemonHunter-Havoc','Monk-Mistweaver','Evoker-Preservation','Paladin-Holy','Mage-Frost','Shaman-Restoration','Hunter-Marksmanship',}; local provider = {region='CN',realm='卡德罗斯',name='CN',type='weekly',zone=42,date='2025-04-14',data={Al='Alencia:AwADCAMABAoAAA==.',Bo='Boxter:AwAGCAgABRQDAQAGAQjgCAA+oR0BBRQAAQAEAQjgCABTuB0BBRQAAgACAQjICgAe/osABRQAAA==.',Co='Coolukyo:AwAHCAkABAoAAA==.',Ei='Eileen:AwAECAQABRQAAA==.',Ko='Komoechan:AwAICAYABAoAAA==.',Ku='Kuizy:AwAECAYABRQCAwAEAQhrAwBQoRsBBRQAAwAEAQhrAwBQoRsBBRQAAA==.',Mi='Miyo:AwABCAEABRQAAA==.',Ov='Overzki:AwAECAQABRQAAA==.',Pr='Priss:AwAGCAMABRQCBAAIAQi3AgBejwADBAoABAAIAQi3AgBejwADBAoAAQQAX68ICAcABRQ=.',Ti='Timlibin:AwAECAYABRQDBQAEAQh7CAAnC8sABRQABQAEAQh7CAAnC8sABRQABgACAQhsGABCu6gABRQAAA==.',Tr='Treasure:AwAICAIABAoAAA==.',Vy='Vylanic:AwAHCAIABAoAAQcAAAAHCAUABAo=.',We='Wendywolf:AwACCAIABAoAAA==.',Yb='Ybkq:AwAGCAYABAoAAQQAKcAGCAYABRQ=.',Zo='Zodiac:AwACCAMABAoAAA==.',Nt='ntr:AwABCAEABRQAAA==.',['�']='不玩贴吧:AwAGCAgABAoAAA==.丶不炫燿:AwAICAgABAoAAA==.丶不炫耀:AwAICBAABAoAAA==.丶肉蛋:AwAICAgABAoAAA==.丶蛋卷:AwAICAgABAoAAA==.丿初丶一:AwACCAMABRQECAAHAQipFABX5zgCBAoACAAHAQipFABWEjgCBAoACQADAQj9GgBLsfMABAoACgABAQgKbAAENhoABAoAAA==.',['�']='乌槑乌:AwAHCAUABAoAAA==.',['�']='五块钱的悲催:AwAHCA8ABAoAAA==.五朵:AwABCAEABAoAAA==.',['�']='仁箭仁爱:AwABCAMABRQAAA==.',['�']='依然拒绝你:AwACCAIABRQAAA==.',['�']='倾城一剑:AwACCAEABRQECwAIAQgMGgBSeiUCBAoACwAHAQgMGgBQ7iUCBAoADAAEAQjNJgBFw0cBBAoADQADAQjhHQA+GOAABAoAAA==.',['�']='假酒:AwAECAQABRQAAA==.',['�']='光殇:AwACCAIABAoAAA==.',['�']='冻住不许走丶:AwACCAIABAoAAA==.',['�']='单调木头人:AwAGCAUABRQEDgADAQgBFQAz3WwABRQADgACAQgBFQASaWwABRQADwADAAgAAAAz3QAABRQAEAABAAgAAAA2rAAABRQAAA==.',['�']='厶亡靇烒:AwACCAMABAoAAA==.',['�']='古德千:AwAECAQABRQAAA==.叶心薇:AwAFCAYABAoAAA==.',['�']='呾呾:AwAICA4ABAoAAA==.',['�']='咆哮游侠:AwAECAQABRQAAA==.',['�']='唐氏脆皮鸡:AwAGCBAABRQCBgAGAQjdAgBX4kYBBRQABgAGAQjdAgBX4kYBBRQAAA==.',['�']='圆环之理法则:AwAECAwABRQCEQAEAQj1EgA51O4ABRQAEQAEAQj1EgA51O4ABRQAAA==.圭臬:AwACCAMABAoAAA==.',['�']='境界之空:AwADCAcABRQCEgADAQj+GgBDZ58ABRQAEgADAQj+GgBDZ58ABRQAAA==.',['�']='壹天世界:AwAECAQABRQAAA==.',['�']='夏灬天丶:AwACCAIABRQAAA==.夜夜殇:AwABCAEABRQAAA==.大道如青天:AwABCAEABRQCEgAIAQh/IABAqCECBAoAEgAIAQh/IABAqCECBAoAAA==.天神的呐喊:AwAGCAYABAoAAA==.',['�']='奎状闪电:AwAICAgABAoAAQcAAAACCAIABRQ=.奥扎格蕾:AwAECAkABRQCEQAEAQikDABGnwkBBRQAEQAEAQikDABGnwkBBRQAAA==.',['�']='婀娜多姿丶:AwAECAcABRQCEwAEAQgeBgBTgRoBBRQAEwAEAQgeBgBTgRoBBRQAAA==.',['�']='小小大懒猫:AwACCAYABRQCFAACAQiKBQAvFX4ABRQAFAACAQiKBQAvFX4ABRQAAA==.小羊儿丶:AwAICBAABAoAAA==.尤瑞艾莉:AwACCAMABRQAAA==.',['�']='巨炮蜀黍:AwAGCA4ABAoAAA==.',['�']='帅气的宝宝:AwABCAIABRQAAA==.希望赞美诗:AwAGCAYABAoAAA==.',['�']='幼稚园吴老师:AwAHCAcABAoAAA==.',['�']='影哲:AwAFCAUABAoAAA==.',['�']='快乐吃手手:AwAECAQABRQAAA==.',['�']='惜嘻夕希:AwAECAQABRQAAA==.',['�']='我叫硬三彩:AwAGCAQABAoAAA==.我忍不了:AwAICAgABAoAAA==.我爱大飞机:AwAECAgABRQCEQAEAQjKCgBYfhMBBRQAEQAEAQjKCgBYfhMBBRQAAA==.戒不掉的烟:AwAFCAUABAoAAA==.战念:AwAECAcABRQCCwAEAQh8CwAzXf4ABRQACwAEAQh8CwAzXf4ABRQAAA==.戳克:AwADCAMABAoAAA==.',['�']='执念:AwAICBYABAoDAQAIAQhCpwAlYBcBBAoAAQAGAQhCpwAm8BcBBAoAFQAFAQj7KQA13dUABAoAAA==.',['�']='抖乧:AwAHCAEABAoAAQcAAAAHCAUABAo=.',['�']='搁浅丶:AwAFCAcABAoAAA==.搻闼譶:AwAGCAYABAoAAQcAAAAHCAUABAo=.',['�']='放开那哥哥:AwABCAEABRQAAA==.',['�']='救赎与信仰:AwAHCAoABAoAAA==.',['�']='旺达:AwAECAQABRQAAA==.',['�']='晨殇:AwAECAQABRQAAA==.',['�']='曹月香:AwAECAYABRQDFgAEAQhXDwAgF30ABRQABAAEAQiEHgAOzbQABRQAFgACAQhXDwAuwX0ABRQAAA==.',['�']='杺殇:AwAECAQABRQAAA==.',['�']='柠檬味:AwAFCAoABAoAAA==.',['�']='梦灬幻丶:AwAECAQABRQAAA==.',['�']='死亡狐步:AwAECAQABRQAAA==.',['�']='比例喷睡:AwAECA0ABRQCFwAEAQj1CgA0G+sABRQAFwAEAQj1CgA0G+sABRQAAA==.',['�']='永恒地星空:AwAECAQABRQAAA==.',['�']='海潮溟:AwACCAMABRQAAA==.',['�']='涛哥:AwAICA4ABAoAAA==.',['�']='灬尛尛:AwADCAQABRQAAA==.',['�']='烈焰暖阳:AwAGCAYABAoAAA==.烬殇:AwACCAIABRQAAA==.',['�']='爱跳舞的晶晶:AwACCAIABRQAAA==.',['�']='特斯拉:AwAECAQABRQAAA==.',['�']='生活要继续:AwAECAIABAoAAA==.',['�']='疯狂的瓶子:AwAICAgABAoAAA==.',['�']='瘾与深港:AwAECAQABRQAAA==.',['�']='福桥村村花:AwABCAEABAoAAA==.',['�']='绯夜:AwAICA0ABAoAAA==.维岳:AwAGCAkABAoAAA==.维鲁德拉:AwAECA0ABAoAAA==.',['�']='羊百万:AwAECAQABAoAAA==.',['�']='胖点错了吗:AwAGCAYABAoAAA==.',['�']='花间舞:AwABCAEABRQAAA==.',['�']='苏南:AwAHCBEABAoAAA==.',['�']='荼荼:AwAECAQABRQAAA==.',['�']='莲生:AwAICBAABAoAAA==.',['�']='萌狼赫罗酱:AwAGCAIABRQAAQgATegICAYABRQ=.',['�']='蕾贝卡:AwAECAQABRQAAA==.',['�']='蛋疼精英:AwADCAMABAoAAA==.',['�']='要高圆圆亲亲:AwAECAQABRQAAA==.覆灭重生:AwACCAQABRQDEQAIAQi1GgBVJ3cCBAoAEQAIAQi1GgBUfHcCBAoAGAAGAAgAAABEHQAABAoAAA==.',['�']='請勿拍打餵食:AwAECAYABRQDBgAEAQg+FAAwFc0ABRQABgAEAQg+FAAwFc0ABRQABQACAQiqFQAJDVsABRQAAA==.',['�']='诶哟哟丶:AwACCAQABRQCDgAIAQiBHgAwI78BBAoADgAIAQiBHgAwI78BBAoAAA==.',['�']='软床等硬枪:AwAECAQABAoAAA==.',['�']='速度之靴:AwACCAIABAoAAA==.',['�']='邂逅丶猎:AwAGCAEABAoAAA==.邪奎:AwAGCAkABRQECAAGAQjLAQBDbnEBBRQACAAFAQjLAQBJD3EBBRQACQACAQgNEgBgBmsABRQACgABAQjFCgAjGFoABRQAAA==.',['�']='铁首松赞干布:AwACCAQABRQDCwAIAQhsFgBEgz8CBAoACwAIAQhsFgBEgz8CBAoADAABAQgYVQAnQkUABAoAAA==.',['�']='队长丶是我:AwACCAQABRQCCwAIAQhrIQA0lPQBBAoACwAIAQhrIQA0lPQBBAoAAA==.阿特別:AwAECAQABRQAAA==.',['�']='陈一发兒:AwACCAQABRQCEQAIAQjlGABPEIACBAoAEQAIAQjlGABPEIACBAoAAA==.',['�']='雅原姐姐:AwAFCAUABAoAAA==.雨夜不带刀:AwACCAIABAoAAA==.雾行者:AwAECAQABRQAAA==.',['�']='駄菓子屋:AwAECAQABRQAAA==.',['�']='驫龘殇:AwABCAEABRQCCAAIAQjPKQAx/LgBBAoACAAIAQjPKQAx/LgBBAoAAA==.',['�']='骑小士:AwAECAQABRQAAA==.骑着小猪逛街:AwADCAMABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end