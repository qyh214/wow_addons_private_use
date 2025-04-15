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
 local lookup = {'Mage-Fire','Mage-Frost','Priest-Discipline','Priest-Shadow','Warrior-Fury','Warlock-Destruction','Warlock-Affliction','Druid-Balance','Paladin-Holy','Paladin-Retribution','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','Druid-Restoration','Shaman-Restoration','Monk-Windwalker','Monk-Brewmaster','Monk-Mistweaver','Paladin-Protection','Warrior-Protection','Warrior-Arms','Unknown-Unknown',}; local provider = {region='CN',realm='达文格尔',name='CN',type='weekly',zone=42,date='2025-04-15',data={Bi='Biubiubiubiu:AwACCAQABRQDAQAIAQh7HgBIoTMCBAoAAQAIAQh7HgBHAzMCBAoAAgADAQiebwBA3ZkABAoAAA==.',Ch='Christie:AwAGCAcABRQDAwAGAQjwAgAv9E0BBRQAAwAFAQjwAgAvM00BBRQABAACAQi/FAApcJsABRQAAA==.',Fe='Feelfreefly:AwAFCAUABAoAAA==.',Fo='Foan:AwACCAIABRQAAA==.',Fr='Freedoms:AwACCAIABRQAAA==.',Ga='Garnetmoon:AwAECAIABRQAAA==.',La='Labubu:AwADCAQABRQCBQAIAQj4FABNcU8CBAoABQAIAQj4FABNcU8CBAoAAA==.',Pa='Pandawarrior:AwAICAgABAoAAA==.',Sa='Saki:AwADCAIABRQDBgAIAQiUGgBANBYCBAoABgAIAQiUGgBANBYCBAoABwAGAQjeEQA6Y1ABBAoAAA==.',Ut='Utherr:AwAICAgABAoAAQMAL/QGCAcABRQ=.',Xi='Xiangjia:AwAICA4ABAoAAA==.',Xl='Xlm:AwADCAcABRQCCAADAQiyCwBEa/8ABRQACAADAQiyCwBEa/8ABRQAAQMAL/QGCAcABRQ=.',['�']='三界仙:AwAECAQABAoAAA==.',['�']='乌萨奇:AwAHCAsABAoAAA==.',['�']='亚鸡米德:AwAICAgABAoAAA==.',['�']='伊洋:AwAICAgABAoAAA==.',['�']='你拿个杯:AwAGCAYABRQDCQAGAQhICAAXi7oABRQACQADAQhICAAIELoABRQACgADAQjDJgAo/akABRQAAA==.',['�']='八鳷鵺:AwADCAcABRQCCwADAQgiGQARLcQABRQACwADAQgiGQARLcQABRQAAA==.养猪大户春桃:AwABCAIABRQAAA==.',['�']='再眠一小夏:AwACCAIABRQAAA==.冰与光的龙诗:AwABCAEABRQAAA==.冰激凌火锅:AwABCAEABRQCAgAGAQg5IgBYJuABBAoAAgAGAQg5IgBYJuABBAoAAA==.',['�']='制动底板冲孔:AwABCAEABAoAAA==.',['�']='勇敢的芯:AwAICAgABAoAAA==.',['�']='午夜泣雪:AwACCAIABAoAAA==.卡尔塔西亚:AwACCAIABRQAAA==.',['�']='厅局级:AwABCAEABRQAAA==.原神启动:AwADCAMABRQAAA==.',['�']='周末:AwAICAgABAoAAA==.',['�']='哔哩波波浪:AwAICA0ABAoAAA==.',['�']='啊咕:AwAGCAQABRQCCAAEAQiaBQBHhysBBRQACAAEAQiaBQBHhysBBRQAAA==.',['�']='圣光照耀你妹:AwADCAMABAoAAA==.',['�']='多财多亿:AwAFCAEABAoAAA==.',['�']='安玻:AwAFCAUABAoAAA==.定乾坤:AwAECAQABRQAAA==.宝山飞龙锅:AwABCAEABRQAAA==.',['�']='寒山一箭:AwACCAMABRQAAA==.',['�']='小火狐:AwACCAIABAoAAQgAH+AICBQABAo=.',['�']='山村猛妇:AwAICAgABAoAAA==.',['�']='左零右火:AwAGCAMABRQAAA==.',['�']='平安幸福:AwAICAYABAoAAA==.',['�']='拘灵遣将:AwAFCAUABRQDDAAFAQh0BgAwYjsBBRQADAAEAQh0BgAwYjsBBRQADQABAQgiIwAAAAAABRQAAA==.',['�']='摇摆:AwADCAQABRQCDgAIAQiHDgBURJoCBAoADgAIAQiHDgBURJoCBAoAAA==.',['�']='撒爹的小弟:AwABCAEABAoAAA==.',['�']='春风灬暖阳:AwAFCAUABAoAAA==.',['�']='最后一头毛象:AwACCAIABRQAAA==.月見英子:AwADCAcABRQCDwADAQjkAQBi/VkBBRQADwADAQjkAQBi/VkBBRQAAA==.',['�']='来一记:AwAECAQABRQAAA==.',['�']='林深时雾起:AwABCAEABRQAAA==.',['�']='桉叶:AwABCAEABRQAAA==.',['�']='楍峎丶凩戥:AwAGCAsABAoAAA==.',['�']='死人蘑:AwADCAYABRQCDAADAQh3EgA4CPcABRQADAADAQh3EgA4CPcABRQAAA==.',['�']='比那名居天子:AwAICAgABAoAAA==.',['�']='沧海丶怒:AwADCAYABRQCEAADAQhzCwA4tPEABRQAEAADAQhzCwA4tPEABRQAAA==.',['�']='泰岚德羽风:AwAICAoABAoAAA==.',['�']='清水末末:AwAECAoABRQCCgAEAQinBwBNASoBBRQACgAEAQinBwBNASoBBRQAAA==.',['�']='熊心豹胆丶:AwACCAIABRQEEQAIAQhSGQA9a/gBBAoAEQAIAQhSGQA9a/gBBAoAEgABAQi0IwATwSQABAoAEwACAQjYkAABvRMABAoAAA==.',['�']='燃月灬晴:AwABCAEABAoAAA==.',['�']='珺应有语:AwAGCAYABAoAAA==.',['�']='瓦力旭旭:AwABCAEABRQAAA==.',['�']='盘儿靓:AwACCAIABRQAAA==.',['�']='看我这个挫样:AwACCAIABRQAAA==.',['�']='童话哥:AwAGCBIABAoAAA==.',['�']='米兰的粉刷匠:AwAHCAkABAoAAA==.',['�']='絶对零度:AwACCAIABRQAAA==.',['�']='线芯:AwAECAQABAoAAA==.',['�']='绯村:AwAGCAYABAoAAA==.',['�']='胖胖牧羊羊:AwADCAMABAoAAA==.',['�']='至尊大宗师:AwAFCAkABAoAAA==.至尊猪儿虫:AwAECA4ABRQCBQAEAQhwCwA/owIBBRQABQAEAQhwCwA/owIBBRQAAA==.至少一七五:AwADCAYABRQCCgADAQi7HwAXJ9AABRQACgADAQi7HwAXJ9AABRQAAA==.',['�']='花开坢夏丶:AwAGCBAABRQCFAAGAQh+BAAUMQYBBRQAFAAGAQh+BAAUMQYBBRQAAA==.',['�']='菊花想开了:AwAECAQABRQAAA==.菜坬:AwADCAMABAoAAA==.',['�']='虚空乄影:AwAECAQABRQAAA==.',['�']='请叫我撒爹:AwACCAQABRQAAA==.诺妹妹:AwAICBQABAoDCAAIAQgrYwAf4AEBBAoACAAGAQgrYwAgVQEBBAoADwAHAQi/PwAZp/AABAoAAA==.',['�']='谠都档不住:AwABCAEABRQAAA==.谦谦不要太帅:AwACCAMABRQEBQAIAQhoHgA+4A4CBAoABQAIAQhoHgA+4A4CBAoAFQAFAQjpKAAiCZIABAoAFgACAQhrVgAbv0sABAoAAA==.',['�']='这很奈斯:AwAGCAoABRQCEAAGAQgwAABJO+cBBRQAEAAGAQgwAABJO+cBBRQAAA==.迪菲亚顾问:AwAGCAYABAoAAA==.迷糊酱爷爷:AwACCAIABRQAAA==.',['�']='门番红美铃:AwAICAwABAoAARcAAAAICAEABRQ=.闪电宝法:AwAICAkABAoAAA==.',['�']='阿哦:AwAICAcABAoAAA==.阿森西奥:AwADCAcABRQCEAADAQiYDAA1n+sABRQAEAADAQiYDAA1n+sABRQAAA==.阿菇:AwAGCAYABAoAARcAAAAECAMABRQ=.阿里斯门:AwACCAIABRQAAA==.',['�']='院锁清秋:AwAICAgABAoAAA==.',['�']='随便捣捣:AwACCAQABRQAAA==.',['�']='雷霆惊梦:AwACCAQABRQCEAAIAQj5DwBTs2QCBAoAEAAIAQj5DwBTs2QCBAoAAA==.雾切响子:AwABCAEABRQAAA==.',['�']='青花瓷:AwACCAIABRQAAA==.',['�']='风后奇门:AwAECAgABRQCAQAEAQihDwBAPAABBRQAAQAEAQihDwBAPAABBRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end