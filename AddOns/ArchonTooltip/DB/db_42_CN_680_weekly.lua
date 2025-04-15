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
 local lookup = {'DeathKnight-Unholy','Druid-Balance','Druid-Restoration','Druid-Guardian','Hunter-Marksmanship','Monk-Mistweaver','DemonHunter-Havoc','Unknown-Unknown','Paladin-Retribution','Shaman-Restoration','Paladin-Holy','Mage-Frost',}; local provider = {region='CN',realm='恶魔之翼',name='CN',type='weekly',zone=42,date='2025-04-14',data={Fe='Feifei:AwAGCAcABAoAAA==.',Ho='Holy:AwABCAEABRQAAA==.',Ic='Icytail:AwAGCAYABAoAAA==.',Mo='Morals:AwAECAQABRQAAA==.',Sa='Satomi:AwAFCAUABAoAAA==.',Sc='Screaml:AwAGCAYABAoAAA==.',Tw='Twy:AwAGCAoABAoAAA==.',We='Weirdoo:AwAICB8ABAoCAQAIAQh0FwBNZ08CBAoAAQAIAQh0FwBNZ08CBAoAAA==.',Wh='Whosyourdad:AwABCAEABRQAAA==.',['�']='丶玄煞:AwAICAkABAoAAA==.',['�']='充满矛盾的鬼:AwABCAIABRQAAA==.八卦海:AwAECAQABRQAAA==.',['�']='冉冉德:AwAICBQABAoEAgAIAQiOPgAkk4cBBAoAAgAIAQiOPgAkk4cBBAoAAwAFAQhQRQAcis8ABAoABAABAQgmLAAb3xwABAoAAA==.冰糖糖小番茄:AwAFCAoABAoAAA==.',['�']='前程旧梦:AwADCAMABAoAAA==.',['�']='十里水沉烟冷:AwADCAMABAoAAA==.单身奶茶:AwACCAMABRQAAA==.单身屠夫:AwABCAEABRQAAA==.',['�']='原罪之刃:AwAICBEABAoAAA==.',['�']='双持信用卡:AwAHCA4ABAoAAA==.叶子飘飘:AwACCAIABAoAAA==.',['�']='吃素的狼:AwAICAgABAoAAA==.',['�']='呼啦圈:AwABCAEABRQAAA==.',['�']='大谢:AwAFCAUABAoAAA==.天尊皇胤:AwAECAgABRQCBQAEAQjwBABFdAIBBRQABQAEAQjwBABFdAIBBRQAAA==.天灰灰:AwAICAgABAoAAA==.头发掉光了:AwAECAQABRQAAA==.',['�']='悲情木头:AwACCAIABAoAAA==.',['�']='憨憨:AwABCAEABAoAAA==.',['�']='摸鱼拌饭:AwACCAQABRQAAA==.',['�']='方世远:AwAECAQABAoAAA==.',['�']='星辰丶猎魔者:AwABCAEABRQAAA==.',['�']='柏卜正:AwABCAEABRQAAA==.',['�']='桃花恋:AwABCAEABAoAAA==.',['�']='武动石头:AwACCAIABAoAAA==.',['�']='水晶:AwAECA4ABRQCBgAEAQgWDAA4i+kABRQABgAEAQgWDAA4i+kABRQAAA==.水晶北碧:AwAICAgABAoAAQcAMf0GCA4ABRQ=.',['�']='污以丶类聚:AwACCAMABRQAAA==.',['�']='法神张张:AwAECAUABAoAAA==.泡姜:AwAGCAYABAoAAA==.',['�']='流雲行水:AwAHCAcABAoAAA==.浮生流年:AwAGCAYABAoAAA==.',['�']='火不高兴:AwAGCAsABAoAAA==.',['�']='熊贰:AwAHCAgABAoAAA==.',['�']='爲所欲为:AwADCAIABAoAAA==.',['�']='真是悲剧:AwABCAIABRQAAA==.',['�']='秦彻:AwAECAQABRQAAA==.',['�']='稀饭嘎啦:AwADCAUABAoAAA==.',['�']='筱筱布丁:AwAICAgABAoAAA==.',['�']='米拉朵朵:AwAGCAwABAoAAA==.米浴:AwAECAQABRQAAA==.',['�']='粉色海洋:AwAICAEABAoAAA==.',['�']='糖丶德瑞拉:AwABCAIABRQAAA==.',['�']='终于有蛋刀了:AwAECAQABRQAAA==.给你一口毒奶:AwAGCAgABAoAAA==.绿皮书:AwAGCBAABAoAAA==.',['�']='翾語優香:AwAHCAcABAoAAA==.',['�']='胖橘武僧:AwAECAQABRQAAA==.',['�']='腹黑喵:AwAGCAkABAoAAA==.',['�']='艾卜:AwAGCAIABAoAAA==.艾斯:AwABCAEABAoAAA==.',['�']='莉娜兔:AwAHCAcABAoAAA==.',['�']='菠萝头王子:AwACCAIABRQAAA==.',['�']='萌贼吥呆:AwAICAgABAoAAQgAAAAICAQABRQ=.落落:AwAICBwABAoCCQAHAQg+YABEr7YBBAoACQAHAQg+YABEr7YBBAoAAA==.',['�']='贰贰叁肆:AwACCAIABRQCCgACAQjxFABSQ6kABRQACgACAQjxFABSQ6kABRQAAA==.',['�']='轰龙龙:AwAICAkABAoAAA==.',['�']='铁拳张哥:AwADCAMABAoAAA==.',['�']='锅锅:AwACCAIABRQAAA==.',['�']='阿劣劣:AwAECAUABAoAAA==.阿香:AwAECAEABRQCCwAIAQh2CQBFXDACBAoACwAIAQh2CQBFXDACBAoAAA==.',['�']='隋随:AwAICBQABAoCDAAIAQgaFwBD5iYCBAoADAAIAQgaFwBD5iYCBAoAAA==.',['�']='雨天见:AwABCAEABAoAAA==.雷霆捍卫者:AwAGCAIABRQAAA==.',['�']='霜见春潮:AwAGCAYABAoAAA==.',['�']='非法走丝:AwAECAQABAoAAA==.',['�']='骑士的苦楚:AwACCAQABRQAAA==.',['�']='黑夜龙王:AwABCAEABRQAAA==.黑炭:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end