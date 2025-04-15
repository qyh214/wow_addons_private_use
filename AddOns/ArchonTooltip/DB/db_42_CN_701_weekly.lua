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
 local lookup = {'DeathKnight-Blood','Monk-Brewmaster','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Druid-Feral','Druid-Balance','Druid-Restoration','Paladin-Retribution','Mage-Frost','Warrior-Protection','Mage-Fire','Priest-Holy','DemonHunter-Havoc','Shaman-Restoration','Unknown-Unknown','Paladin-Protection','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Elemental','Hunter-Survival','DemonHunter-Vengeance',}; local provider = {region='CN',realm='普罗德摩',name='CN',type='weekly',zone=42,date='2025-04-14',data={Bl='Bloodseeker:AwAHCAgABAoAAA==.',Dk='Dk:AwACCAcABRQCAQACAQiqGAAIxU8ABRQAAQACAQiqGAAIxU8ABRQAAA==.',Fo='Forwhen:AwAICAgABAoAAA==.',Gt='Gtol:AwACCAIABAoAAA==.',Le='Letmexd:AwAECAQABAoAAA==.',Lo='Lowo:AwAECAQABAoAAA==.',Mo='Mone:AwACCAIABAoAAA==.',Pi='Pippinsnout:AwACCAIABRQAAA==.',Sa='Saaber:AwACCAMABRQAAA==.',Wo='Wowhh:AwAFCAEABAoAAA==.',['�']='一一得伊:AwACCAIABRQAAA==.一一点点:AwAECAMABRQAAA==.一个小德:AwABCAEABAoAAA==.一嘀嘀:AwAICAgABAoAAA==.一米五八:AwAECAQABRQAAA==.一路顺发旺:AwAICBAABAoAAA==.一颠颠:AwAECAQABRQAAA==.三分归元气:AwAECAQABRQAAA==.不会汪汪:AwAECAQABRQAAA==.不动熊猫:AwACCAcABRQCAgACAQixBAA6EpAABRQAAgACAQixBAA6EpAABRQAAA==.不动神无:AwABCAEABAoAAA==.不葙:AwACCAEABRQEAwAIAQiDFABP7jkCBAoAAwAIAQiDFABFvDkCBAoABAADAQh6PgBOp6QABAoABQACAQjRJgBJQ54ABAoAAA==.中老妇女偶像:AwADCAMABAoAAA==.丿橋本侑菜灬:AwAICAgABAoAAA==.',['�']='云啓丶丨:AwABCAEABAoAAA==.',['�']='偶蕾蕾:AwAECAIABAoAAA==.',['�']='傲视天下:AwAGCAQABAoAAA==.',['�']='元素:AwACCAcABRQEBgACAQjaAwBF9KUABRQABgACAQjaAwA2zqUABRQABwABAQg+IwBMZ1oABRQACAABAQh1GAA6+UEABRQAAA==.光兄:AwAECAIABRQCCQAHAQjzPQBMChICBAoACQAHAQjzPQBMChICBAoAAA==.光脚:AwADCAsABRQCCgADAQj8AwBLdQUBBRQACgADAQj8AwBLdQUBBRQAAA==.兜兜里有糖:AwAECAQABAoAAA==.兰帝子:AwAECAQABRQAAA==.',['�']='划船不用桨:AwAICA4ABAoAAA==.',['�']='劈色特弄:AwAECAUABAoAAA==.',['�']='匿迹:AwACCAIABRQAAA==.',['�']='卡其的小布藕:AwACCAMABRQCCwAIAQi9EgAoc1sBBAoACwAIAQi9EgAoc1sBBAoAAA==.',['�']='名字不太长:AwAECAUABRQCCQAEAQgJGwAjoNkABRQACQAEAQgJGwAjoNkABRQAAA==.吴名英雄:AwAECAIABRQAAA==.',['�']='咔忙呗比:AwAICAIABRQCDAACAQiKHQBPb7wABRQADAACAQiKHQBPb7wABRQAAA==.',['�']='哀木涕劣人:AwAICAgABAoAAA==.',['�']='啊对对對:AwAGCAYABAoAAA==.',['�']='圣光之触:AwADCAcABRQCDQADAQi6DwAlho0ABRQADQADAQi6DwAlho0ABRQAAA==.',['�']='壹伍零壹:AwACCAMABRQCDgAIAQgoEQBPMIwCBAoADgAIAQgoEQBPMIwCBAoAAA==.',['�']='复仇者丶:AwAECAQABRQAAA==.夏目:AwACCAIABAoAAA==.多龙巴鲁托:AwAICAgABAoAAA==.夜之祈愿:AwAECAQABAoAAA==.大郎该喝药啦:AwAGCAIABRQAAA==.天呐你真高:AwACCAIABAoAAA==.头上带点绿:AwADCAkABRQCDgADAQjlAwBfTkUBBRQADgADAQjlAwBfTkUBBRQAAA==.',['�']='女神的宝宝:AwACCAMABRQCCAAIAQjWFgA/d+QBBAoACAAIAQjWFgA/d+QBBAoAAA==.奶酪猪猪:AwADCAMABAoAAA==.',['�']='威朗普:AwADCAMABAoAAA==.',['�']='小饭团:AwAFCAYABAoAAA==.尐吖頭:AwABCAMABRQCDwAIAQgpFgBI9jECBAoADwAIAQgpFgBI9jECBAoAAA==.尤娜娜:AwABCAEABAoAAA==.',['�']='康某北鼻:AwABCAEABAoAAA==.',['�']='御神光同在:AwACCAMABRQCCQAIAQhvFwBW9aYCBAoACQAIAQhvFwBW9aYCBAoAAA==.',['�']='忠于纯粹:AwACCAYABRQCDAACAQj7JAAihpEABRQADAACAQj7JAAihpEABRQAAA==.',['�']='怒风早乙女:AwAICA4ABAoAAA==.',['�']='成败尽东流:AwAECAQABRQAAA==.我不是伟人:AwABCAEABRQAAA==.我來劫財:AwABCAIABRQDCgAIAQgoHwA4+ewBBAoACgAIAQgoHwA4+ewBBAoADAABAQjajgApDTgABAoAAA==.我有欧洲梦:AwAGCAYABAoAARAAAAAGCAQABRQ=.',['�']='抓个德做宝宝:AwABCAEABAoAAA==.',['�']='搞樂:AwAECAQABRQAAA==.',['�']='无聊猎:AwAECAQABAoAAREASPYBCAMABRQ=.无聊骑:AwABCAMABRQCEQAIAQgpCgBI9kACBAoAEQAIAQgpCgBI9kACBAoAAA==.',['�']='星辰兔巴哥:AwAICA8ABAoAAA==.',['�']='普罗提诺:AwACCAMABRQAAA==.',['�']='暮色灬晨曦:AwAICAgABAoAAA==.暮雨菲菲:AwAECAQABAoAAA==.暴风:AwABCAEABRQDEgAIAQgDFABGnP8BBAoAEgAIAQgDFAA/BP8BBAoAEwAIAQi4YQAlRVsBBAoAAA==.',['�']='曾经的萌德:AwAICAgABAoAAA==.',['�']='最爱吐司边儿:AwAFCAkABAoAAA==.會喊六的鹹魚:AwAECAQABRQAAA==.月袭人:AwAHCAkABAoAAA==.',['�']='李小黑:AwAECAQABAoAAA==.来一拳:AwAECAQABRQAAA==.',['�']='格子:AwACCAQABRQDDwAIAQjCGwBAqAsCBAoADwAIAQjCGwBAqAsCBAoAFAABAQgncgAJ+SwABAoAAA==.格鐳瑪燍:AwAFCAQABAoAAA==.',['�']='桑葚:AwADCAwABRQCDQADAQg8CAAp+toABRQADQADAQg8CAAp+toABRQAAA==.',['�']='梦一样自由:AwADCAMABAoAAA==.',['�']='武汉欢欢:AwADCAwABRQCAQADAQj2EQASV4gABRQAAQADAQj2EQASV4gABRQAAA==.',['�']='殇烦:AwABCAEABRQAAA==.',['�']='比利大魔王:AwABCAEABAoAAA==.毛兄:AwABCAEABAoAAA==.',['�']='洛克丹莫:AwAGCA8ABAoAAA==.洛洛白:AwADCAoABRQDAwADAQi6DgAzxNEABRQAAwADAQi6DgAs5tEABRQABAABAQhTDQBBvFEABRQAAA==.',['�']='淘气小熊:AwABCAIABRQDDAAIAQh4EQBRn4ECBAoADAAIAQh4EQBRn4ECBAoACgAEAQgsXQBTLcUABAoAAA==.',['�']='游鱼与星辰:AwAICAgABAoAAA==.',['�']='溪清:AwABCAEABAoAAA==.',['�']='灬呱呱灬:AwADCAMABRQAAA==.灰凉凉:AwAECAUABAoAAA==.灰常荡:AwAGCAIABAoAAA==.',['�']='爱上王老吉:AwACCAIABAoAAA==.',['�']='牛糊螂:AwAFCAUABAoAAA==.牛魔牛:AwABCAEABAoAAA==.',['�']='狂魔自尊:AwAECAgABAoAAA==.独孤肥天:AwACCAIABAoAAA==.',['�']='猫猫嘴里的鱼:AwAECAQABRQAAA==.',['�']='盏茶浅抿:AwACCAcABRQCCQACAQh9KAAslZcABRQACQACAQh9KAAslZcABRQAAA==.盐水凤梨:AwAECAEABRQDEgAIAQizBABZP70CBAoAEgAIAQizBABZP70CBAoAFQABAQjqHQAAAAAABAoAAA==.盖尔丶加朵:AwAECAQABRQAAA==.',['�']='真无霜:AwACCAIABRQAARMAQU0GCAUABRQ=.',['�']='禅院丨织姬:AwAECAQABRQAAA==.',['�']='秃头老宝贝:AwAHCBwABAoCDAAHAQjDPAAr0oQBBAoADAAHAQjDPAAr0oQBBAoAAA==.秋风之刃:AwACCAgABRQCDQACAQiDEgAgv34ABRQADQACAQiDEgAgv34ABRQAAA==.',['�']='米亚:AwACCAIABRQAAA==.米瑞特之阻碍:AwADCAoABRQDAwADAQh5DAA4S94ABRQAAwADAQh5DAA4S94ABRQABAABAQh3EQAxGEMABRQAAA==.',['�']='絕鈑灬壞壞:AwABCAEABRQAAA==.絮絮叨叨的旭:AwAECAgABRQCCQAEAQiPCQBTwRoBBRQACQAEAQiPCQBTwRoBBRQAARIAWpYGCAgABRQ=.',['�']='纯情的狗公腰:AwAICBMABAoAAA==.纯情的鸡屁股:AwAGCAcABAoAAA==.',['�']='终末之箭:AwACCAgABRQCEwACAQh3HQBFMa8ABRQAEwACAQh3HQBFMa8ABRQAAA==.给你套军体拳:AwABCAEABRQAAA==.',['�']='老衲法号流氓:AwAECAQABAoAAA==.老衲法号颓废:AwACCAIABAoAAA==.',['�']='胖头陀:AwAFCAcABAoAAA==.',['�']='苦行僧猪猪:AwAECAQABAoAAA==.',['�']='萨满开嗜血:AwADCAMABAoAAA==.',['�']='蓝色油腻奶瓶:AwACCAMABRQCDwAIAQggRgAcz0gBBAoADwAIAQggRgAcz0gBBAoAAA==.',['�']='蕾丷蕾:AwADCAMABAoAAA==.',['�']='謸呜:AwACCAgABRQCAwACAQibDQBeYtgABRQAAwACAQibDQBeYtgABRQAAA==.',['�']='该丶隐:AwAICBUABAoCDgAIAQhbPgAklocBBAoADgAIAQhbPgAklocBBAoAAA==.',['�']='贝斯特拉:AwAECAQABRQAAA==.贫道法号贼尼:AwADCAkABRQCAwADAQjbDAAyTdwABRQAAwADAQjbDAAyTdwABRQAAA==.费纳希雅:AwAECAIABRQAAA==.贾斯丁盾墙:AwAICA0ABAoAAA==.',['�']='超硬的文少爷:AwAGCAwABAoAAA==.',['�']='轻松熊:AwAFCAUABAoAAA==.',['�']='辰星:AwADCAMABAoAAA==.',['�']='这一拳会上天:AwAECAQABRQAAA==.迪古拉斯:AwAECAQABRQAAA==.',['�']='郁闷小恶:AwACCAMABRQCDgAIAQh/JgA8D/4BBAoADgAIAQh/JgA8D/4BBAoAAA==.',['�']='酒劍:AwACCAMABRQDEgAIAQitCgBN0WgCBAoAEgAIAQitCgBN0WgCBAoAEwAEAQjxpwAb+acABAoAAA==.',['�']='阿立与你同在:AwAECAgABRQCEQAEAQjjCAAjpaIABRQAEQAEAQjjCAAjpaIABRQAAA==.',['�']='随风领主:AwAECAQABRQAAA==.',['�']='香炸牧羊犬:AwAECAIABRQAAA==.',['�']='鱼丸:AwAECAYABRQDDgAEAQivDQA+0fcABRQADgAEAQivDQA+0fcABRQAFgABAQhSFQAPZy4ABRQAAA==.鱼柳柳:AwACCAIABAoAAA==.',['�']='龍嘯丶傲天:AwAGCAYABAoAAA==.龍戰騎士:AwABCAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end