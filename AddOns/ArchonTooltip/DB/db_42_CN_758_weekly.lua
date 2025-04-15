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
 local lookup = {'Paladin-Retribution','Warrior-Arms','Monk-Mistweaver','Monk-Windwalker','DeathKnight-Unholy','DeathKnight-Frost','Mage-Fire','Mage-Frost','Paladin-Protection','Unknown-Unknown','Druid-Balance','Paladin-Holy','Shaman-Restoration','Shaman-Elemental','Priest-Holy','Warlock-Destruction','Warlock-Affliction','Hunter-BeastMastery','Druid-Restoration','Hunter-Marksmanship',}; local provider = {region='CN',realm='玛法里奥',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Angelina:AwAGCAoABAoAAA==.',Ch='Christina:AwAFCAUABAoAAA==.',Dj='Djkiller:AwAHCAcABAoAAA==.',Ka='Katherina:AwACCAMABRQCAQAIAQitXAA6Ur8BBAoAAQAIAQitXAA6Ur8BBAoAAA==.',Mu='Mushroom:AwAGCAcABAoAAA==.',St='Stormfish:AwAGCAgABAoAAA==.',Wa='Wangzd:AwAECAoABAoAAA==.',Wi='Wildhydnose:AwAICAgABAoAAA==.',Zd='Zd:AwACCAYABRQCAgACAQhoCwAm8JkABRQAAgACAQhoCwAm8JkABRQAAA==.',['�']='一路奶粉:AwACCAQABRQDAwAIAQjbEQBJkEICBAoAAwAIAQjbEQBJkEICBAoABAACAQjOZgAT0jwABAoAAA==.两千次全胜:AwACCAMABRQDBQAIAQgxDwBTsY0CBAoABQAIAQgxDwBTsY0CBAoABgADAQiOIAAUTZQABAoAAA==.丶溜肉段:AwAFCAkABAoAAA==.丶随风:AwAGCAYABAoAAA==.',['�']='了无痕迹:AwAECAQABRQAAA==.五十多个死骑:AwACCAIABRQAAA==.',['�']='代表圣光:AwADCAMABAoAAA==.',['�']='俦牛:AwAICAgABAoAAA==.',['�']='六翼使徒:AwABCAEABRQCAQAIAQggVQA5dtIBBAoAAQAIAQggVQA5dtIBBAoAAA==.',['�']='冰箱里的胖丁:AwAECAUABRQCBwAEAQgaDwA9dvoABRQABwAEAQgaDwA9dvoABRQAAA==.冲锋者肆型:AwADCAYABRQDCAADAQiRDAAzgZEABRQACAACAQiRDAAx8pEABRQABwACAQgnJQAu2JAABRQAAA==.',['�']='力量与荣耀啊:AwADCAUABAoAAA==.',['�']='单吊九条:AwAECAYABAoAAA==.',['�']='周杰伦:AwABCAEABRQCAwAGAQgWTAAfZeYABAoAAwAGAQgWTAAfZeYABAoAAA==.',['�']='咖啡不加冰:AwAHCAEABAoAAA==.',['�']='嗨嗨人生:AwACCAMABRQCCQAIAQiNIgAarg8BBAoACQAIAQiNIgAarg8BBAoAAA==.',['�']='圣丶殇:AwAECAQABAoAAA==.圣壂骑士:AwAFCAUABAoAAA==.圣糖刺客:AwABCAEABRQAAQMAXfYFCA8ABRQ=.',['�']='均衡之镰:AwACCAMABRQAAQoAAAADCAMABRQ=.',['�']='夜月渐蓝:AwAECAQABRQAAQsARTUHCAcABRQ=.天驱圣骑:AwAICBAABAoAAA==.太空人丶旋转:AwAHCAcABAoAAA==.',['�']='奈非天:AwAECAQABRQAAA==.',['�']='如约而至丶:AwABCAEABAoAAA==.',['�']='威風堂堂:AwAECAoABRQEDAAEAQjwAQBMRB0BBRQADAAEAQjwAQBMRB0BBRQACQAEAQgaBwAuOb4ABRQAAQACAQiDMAAv34EABRQAAA==.娜宝宝:AwAGCAYABAoAAA==.',['�']='孤城逢甘霖:AwADCAEABAoAAA==.',['�']='寂静的汐儿:AwACCAIABRQAAA==.',['�']='尉迟丶敬德:AwAECAQABRQAAA==.小锤锤捶你:AwAICAgABAoAAA==.小静:AwACCAIABAoAAA==.',['�']='工程骑士:AwAGCAYABAoAAA==.左岸涟漪:AwAGCAYABAoAAA==.',['�']='幻影星辰:AwAECAQABRQAAA==.',['�']='张小弟:AwADCAEABRQAAA==.',['�']='心照一生:AwACCAMABRQDDQAIAQjIHgBG2foBBAoADQAIAQjIHgBG2foBBAoADgAGAQi2PAAkS/gABAoAAA==.',['�']='慈悲渡魂落:AwAGCAgABRQCAwAGAQg4AgAcV4IBBRQAAwAGAQg4AgAcV4IBBRQAAA==.慕荷:AwADCAMABAoAAA==.',['�']='我心已绝:AwAECAUABAoAAA==.',['�']='所念皆星河:AwAGCAIABRQCDwACAQg5FAAWs3IABRQADwACAQg5FAAWs3IABRQAAA==.',['�']='拾祎:AwAGCAQABRQAAA==.',['�']='昂寇:AwAECAMABRQAAA==.',['�']='晓梦清秋:AwABCAEABAoAAA==.',['�']='暗影精灵:AwAGCAYABAoAAA==.暮酒:AwACCAMABRQAAA==.',['�']='树林里的毛球:AwADCAMABRQAAA==.',['�']='欧玛吉利曼波:AwAECA8ABRQCBwAEAQiFGAArbdgABRQABwAEAQiFGAArbdgABRQAAA==.',['�']='正义的沈沈:AwAFCAUABAoAAA==.',['�']='江晴:AwAICBoABAoCDQAIAQi5NgAr24UBBAoADQAIAQi5NgAr24UBBAoAAA==.',['�']='油炸冰淇淋:AwABCAEABAoAAA==.',['�']='渺小坦克车:AwAICAoABAoAAA==.',['�']='火火炎:AwAECAMABRQAAA==.灬爱喝咖啡灬:AwACCAIABAoAAA==.灵儿疯丫头:AwABCAEABAoAAA==.',['�']='炙热的花生:AwADCAMABAoAAA==.',['�']='爱莎莉:AwADCAsABRQDEAADAQgcEAAfgMgABRQAEAADAQgcEAAfgMgABRQAEQABAQhAGgAJgD8ABRQAAA==.',['�']='猪猪爱吃瓜:AwAECAgABRQCEgAEAQjMCABdjR4BBRQAEgAEAQjMCABdjR4BBRQAAA==.猫咔不咔:AwACCAIABAoAAA==.',['�']='秋月无边:AwAECAsABRQCAwAEAQhXCwA5je0ABRQAAwAEAQhXCwA5je0ABRQAAA==.',['�']='羊羊:AwAFCAUABAoAAA==.',['�']='肯塔基波旁:AwABCAEABRQCEAAIAQgAEgBO6kwCBAoAEAAIAQgAEgBO6kwCBAoAAA==.',['�']='虎视眈眈:AwAECAQABRQAARMAPyYICAsABRQ=.',['�']='请嫑打我:AwABCAIABRQAAA==.诸神丶心雨:AwAECAgABRQCFAAEAQgoAQBbdz8BBRQAFAAEAQgoAQBbdz8BBRQAAA==.',['�']='豪猪仔:AwAGCAoABAoAAA==.',['�']='贰路奶粉:AwACCAIABAoAAA==.',['�']='迪肯大爷:AwAICAgABAoAAA==.',['�']='逝去的秦春:AwAFCAUABAoAAA==.',['�']='飘雪清风月朗:AwADCAMABRQAAA==.飞舞的苹果:AwAHCAsABAoAAA==.飞鸟和游鱼:AwAICAgABAoAAA==.',['�']='魂歌:AwACCAEABRQAAQEAS6QGCAoABRQ=.',['�']='鸢蓝:AwACCAIABRQAAA==.',['�']='黑角行者:AwAECAgABAoAAA==.黑铁元素萨:AwAECAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end