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
 local lookup = {'Paladin-Holy','Paladin-Retribution','Priest-Shadow','Rogue-Assassination','Rogue-Subtlety','Hunter-Marksmanship','Paladin-Protection','Priest-Discipline','Priest-Holy','DemonHunter-Havoc','DemonHunter-Vengeance','Evoker-Devastation','Warrior-Fury','Mage-Frost','Mage-Fire','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Druid-Balance','Hunter-BeastMastery','Evoker-Preservation','Shaman-Restoration','Shaman-Enhancement','DeathKnight-Unholy','DeathKnight-Frost','Warrior-Arms','Unknown-Unknown','DeathKnight-Blood','Druid-Restoration','Rogue-Outlaw',}; local provider = {region='CN',realm='银月',name='CN',type='weekly',zone=42,date='2025-04-15',data={Cp='Cpcianes:AwAECAUABAoAAA==.',Ev='Evildora:AwAICBMABAoAAA==.',Fs='Fsugar:AwAGCAoABAoAAA==.',In='Inna:AwADCA8ABRQDAQADAQjiBgBgodUABRQAAQACAQjiBgBe8tUABRQAAgACAQj5JgA9oagABRQAAA==.',Lm='Lminz:AwACCAIABRQAAA==.',Me='Melon:AwAFCBIABRQCAwAFAQiVAgBZHJUBBRQAAwAFAQiVAgBZHJUBBRQAAA==.',Mi='Miakhalifa:AwAHCAcABAoAAA==.',Na='Natasha:AwAGCAsABRQDBAAGAQiOAQAb4o8BBRQABAAGAQiOAQAb4o8BBRQABQABAQjwEgAAAAAABRQAAA==.',Nr='Nryu:AwACCAIABAoAAA==.',Qo='Qoqo:AwAFCAkABAoAAA==.Qoqosfn:AwAGCAYABAoAAA==.',Ra='Radint:AwADCAYABAoAAA==.',Rp='Rpoon:AwACCAIABRQCBgAIAQg8AwBdi9oCBAoABgAIAQg8AwBdi9oCBAoAAA==.',Sw='Swordovo:AwAHCAoABAoAAA==.',Ta='Taren:AwAECAQABRQAAQcASiMGCAYABRQ=.',Vi='Vincentia:AwAECAwABRQDCAAEAQgrAwBePkYBBRQACAAEAQgrAwBePkYBBRQACQABAQixGQBXY1IABRQAAA==.',Wi='Wildfire:AwAICCYABAoDCgAIAQixDgBa6qQCBAoACgAIAQixDgBa6qQCBAoACwAGAQhINgAcJsYABAoAAA==.',Zl='Zlatan:AwAICBgABAoCDAAIAQhrOwAHnLEABAoADAAIAQhrOwAHnLEABAoAAA==.',['�']='一只小泡芙:AwABCAEABRQAAA==.一掌拍死你:AwAGCAUABAoAAA==.七煌宝术:AwABCAEABRQAAA==.三分恶气:AwABCAEABRQAAA==.不要点我名:AwAECAQABRQAAA==.东方丶树叶:AwAECA4ABRQCDQAEAQg/BwBMLBsBBRQADQAEAQg/BwBMLBsBBRQAAA==.东方丶樹葉:AwAICAgABAoAAA==.丨灵狐丨:AwAICBgABAoCBgAIAQh0HABCYLwBBAoABgAIAQh0HABCYLwBBAoAAA==.丶融化:AwAECAUABRQDDgAIAQjfKQA/IrQBBAoADgAIAQjfKQA+h7QBBAoADwAGAQjXSQA6VUUBBAoAAA==.为妇不仁:AwAGCAsABAoAAA==.',['�']='也许不:AwADCAYABRQCBAADAQhHCwAS9LkABRQABAADAQhHCwAS9LkABRQAAA==.',['�']='二手芍药:AwAICAgABAoAAA==.云耀:AwAECAgABRQCAgAEAQgvCgBVdR0BBRQAAgAEAQgvCgBVdR0BBRQAAA==.人一大:AwACCAYABRQDEAACAQgVEgAXJkkABRQAEAABAQgVEgAk20kABRQAEQABAQjoGwAJcT4ABRQAAA==.',['�']='僑風:AwAICB8ABAoEEAAIAQhmEgBQVrgBBAoAEAAGAQhmEgBOJLgBBAoAEgAEAQh7SwA8bCABBAoAEQADAQhjJgAzZKkABAoAAA==.',['�']='元素葱击:AwAGCAYABAoAAA==.',['�']='刷不起来:AwAGCAYABAoAAA==.',['�']='千刃散浮华:AwAECAgABRQCCgAEAQidFAAkBN0ABRQACgAEAQidFAAkBN0ABRQAAA==.千觅:AwACCAMABRQAAA==.半醒半梦之间:AwACCAIABRQAAA==.南璐:AwABCAEABRQAARIANGQECA0ABRQ=.',['�']='双剑闯江湖:AwAICAgABAoAAA==.变体精灵:AwAICAoABAoAARMATccGCA8ABRQ=.司阿莫安:AwABCAEABAoAAA==.',['�']='呆呆小熊甜心:AwAECAQABRQAAA==.',['�']='咬春:AwAHCAkABAoAAA==.',['�']='喂我有麦吗:AwAICBAABAoAAA==.',['�']='四妹:AwACCAIABRQAAA==.',['�']='地爆天星:AwAICAgABAoAAA==.',['�']='埃辛烈焰:AwAGCAsABAoAAA==.',['�']='堕落训兽者:AwABCAEABRQDFAAIAQhHRQBD8ccBBAoAFAAHAQhHRQBGd8cBBAoABgAGAQh7JQA/034BBAoAAA==.',['�']='墨灵:AwABCAEABRQAAA==.',['�']='壹条龍:AwAECAgABRQDDAAEAQgFCQBGse8ABRQADAAEAQgFCQBGse8ABRQAFQABAQg1CQAlfT0ABRQAAA==.',['�']='夏夜晚风:AwAICBwABAoCCQAIAQgTJgArHpcBBAoACQAIAQgTJgArHpcBBAoAAA==.夏天烨:AwABCAEABAoAAA==.天堂之拳:AwAGCAYABAoAAA==.天线宝宝丶:AwAICAwABAoAAA==.',['�']='奈妃妮:AwAECAQABRQAAA==.',['�']='妙龄尼姑:AwAICAgABAoAAA==.',['�']='姥姥:AwACCAQABRQDDgACAQhbDQBVOpYABRQADwACAQgWJgBP0JgABRQADgACAQhbDQBVOpYABRQAAA==.',['�']='婷丫头:AwAICBAABAoAAA==.',['�']='宝贝静静:AwAECAQABAoAAA==.',['�']='寇玛可:AwAICAgABAoAAA==.',['�']='小刀喇皮鼓:AwADCAMABAoAAA==.小码鸽:AwAGCAcABAoAAA==.小超灬:AwACCAUABRQDFgAIAQh5PQAoYXABBAoAFgAIAQh5PQAoYXABBAoAFwAFAQirKQAr7VYBBAoAAA==.少囡榨汁机:AwAHCAcABAoAAA==.',['�']='山野栀子:AwAICAgABAoAAA==.屿誓:AwAICAgABAoAAA==.',['�']='左零右火:AwACCAIABRQAAA==.',['�']='布裴:AwAICBIABAoAAA==.',['�']='幺伍柒叁:AwAICAgABAoAAA==.幻丶海:AwABCAEABRQAAA==.幻影鬼刃:AwAFCAUABAoAAA==.幻心落梦:AwACCAMABRQAAA==.',['�']='张小凡:AwAGCAYABAoAAA==.张罗地:AwAECAYABRQDDAAEAQjlBgBRQwYBBRQADAAEAQjlBgBRQwYBBRQAFQACAQg6BQAzMZIABRQAAA==.',['�']='御天霜:AwABCAEABRQDGAAIAQhUIwA8FQ8CBAoAGAAIAQhUIwA8FQ8CBAoAGQAFAQicGwArUM0ABAoAAA==.',['�']='我爱吃泡芙:AwAICAYABAoAAA==.战歌:AwAHCAcABAoAAA==.战神丶:AwAECAoABRQDDQAEAQi2BwBQ7BcBBRQADQAEAQi2BwBMRBcBBRQAGgACAQg+CgBKma4ABRQAAA==.',['�']='拾指緊扣:AwABCAEABRQAAA==.',['�']='明朝相见:AwAFCAUABAoAARsAAAABCAEABRQ=.',['�']='暗夜无影箭:AwAECAQABAoAAA==.',['�']='月灵银羽:AwACCAUABRQCFAACAQgrKAAsG5UABRQAFAACAQgrKAAsG5UABRQAAA==.木耳五分熟:AwAECAgABRQCFgAEAQgFBABXHC8BBRQAFgAEAQgFBABXHC8BBRQAAA==.',['�']='李政宰:AwAICAgABAoAAA==.杭州大宝剑:AwADCAMABAoAAA==.',['�']='橙子元宵:AwAGCAYABRQCAgAGAQi2AABK7OEBBRQAAgAGAQi2AABK7OEBBRQAAA==.橙子的圣光啊:AwAECAEABRQDCAAIAQiaFgA94PIBBAoACAAIAQiaFgA94PIBBAoACQACAQg5egAVF04ABAoAAA==.',['�']='歌兰蒂斯:AwAICBIABAoAAA==.',['�']='水平如镜:AwAECAQABAoAAA==.',['�']='沃德杨永信:AwAICA8ABAoAAA==.沙棘杀鸡:AwAECAQABRQAAA==.',['�']='洛颉:AwABCAEABRQAAA==.',['�']='漂泊沉沦:AwACCAIABRQAAA==.',['�']='潇洒一七五:AwAHCAgABAoAAA==.',['�']='澹然离言说:AwADCAMABAoAAA==.',['�']='火球来一发:AwAICAgABAoAAA==.灵活死胖纸:AwACCAIABAoAAA==.',['�']='炖咸鱼:AwABCAEABRQAAA==.',['�']='烧酒不甜:AwAECAQABAoAAA==.',['�']='爱吃青苹果:AwAICBYABAoDDQAIAQgWEABfh3YCBAoADQAHAQgWEABconYCBAoAGgAFAQghEQBYlxUCBAoAAA==.',['�']='牙擦擦滴一枪:AwAICAgABAoAAQ4AMpgGCAYABRQ=.牛牛单人饭:AwADCAMABAoAAA==.牧心在野:AwAGCAYABAoAAA==.',['�']='狙擊之王:AwAGCAUABAoAAA==.',['�']='猫尾草:AwAECAQABRQAAQ8AMkEGCAgABRQ=.',['�']='王赢儿:AwACCAIABRQAARsAAAAICAMABRQ=.玖柒:AwAECAQABRQAAA==.',['�']='璎錵:AwABCAEABRQAAA==.',['�']='白子真奶:AwABCAEABRQAARsAAAAECAIABRQ=.白泽丿:AwADCAMABAoAAA==.百变大猫:AwAFCAoABAoAAA==.',['�']='看我干嘛上啊:AwAECAQABAoAAA==.',['�']='社会大宝贝:AwAICAgABAoAAA==.',['�']='素前小狗:AwAECAMABRQAARwALHAGCAkABRQ=.紫魅血兮:AwAICAgABAoAAA==.',['�']='耶梦加德:AwAECAQABRQAAA==.',['�']='胖之煞:AwAFCAQABAoAAA==.',['�']='色霸霸:AwACCAQABRQAAA==.',['�']='花样精:AwAECAwABRQCBgAEAQh8CwAv29cABRQABgAEAQh8CwAv29cABRQAAA==.花花吃手手:AwAECAcABRQCEwAEAQi5CwBB2P8ABRQAEwAEAQi5CwBB2P8ABRQAAR0AKncGCAoABRQ=.',['�']='苏锦浅清颜:AwACCAQABRQCAwAIAQihFwA7TgQCBAoAAwAIAQihFwA7TgQCBAoAAA==.',['�']='荣耀之炫:AwAHCAUABAoAAA==.',['�']='菲奥拉:AwACCAUABRQDAgAIAQhSKgBRR2ACBAoAAgAIAQhSKgBRR2ACBAoABwABAQixWQAb9yAABAoAAA==.',['�']='萨天使:AwACCAIABAoAAA==.萨库拉酱:AwABCAEABRQAAA==.落沫沫:AwAECAgABRQCGAAEAQigEAAeQdgABRQAGAAEAQigEAAeQdgABRQAAA==.',['�']='蒙面虾仁:AwADCAEABAoAAA==.',['�']='血炎丨冰瞳:AwAICAwABAoAAA==.血翼丶恶魔:AwAECAkABRQDDgAEAQgvEQAeZX0ABRQADwAEAQhwIgAI8KoABRQADgACAQgvEQArwH0ABRQAARsAAAAGCAQABRQ=.',['�']='请以我为基点:AwACCAIABRQAAA==.',['�']='贴苏菲显神威:AwABCAEABRQAAA==.',['�']='透明桥:AwADCAgABRQDHgADAQjqAQBDB+MABRQABAADAQiHBwA0PPAABRQAHgADAQjqAQAoUeMABRQAAA==.',['�']='酒杯干碧婷:AwAECAQABRQAAA==.',['�']='锤子剪刀布:AwABCAEABRQAAA==.',['�']='阿弥陀佛:AwAGCAYABAoAAA==.阿舟小牧:AwABCAEABRQAAR0AIO8DCAgABRQ=.阿舟小猎:AwABCAEABRQAAR0AIO8DCAgABRQ=.阿舟小骑:AwAHCAYABAoAAR0AIO8DCAgABRQ=.',['�']='隔壁师兄:AwABCAEABRQAAA==.',['�']='雷霆法王:AwABCAEABRQAAA==.',['�']='露德米拉:AwACCAIABRQAAA==.',['�']='青木:AwAECAQABRQAAQMANEsICAgABRQ=.',['�']='风为:AwAECAgABRQCDwAEAQh+BgBirFcBBRQADwAEAQh+BgBirFcBBRQAAA==.风吹过的夏天:AwADCAMABAoAAA==.风语烟岚:AwACCAIABRQAAA==.风间殇月:AwABCAEABAoAAA==.风鼓玄旌:AwAICAMABAoAAA==.',['�']='高允貞:AwACCAIABRQAAA==.',['�']='鲨手企鹅:AwAGCA4ABAoAAA==.',['�']='黯汐:AwAFCAIABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end