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
 local lookup = {'Paladin-Retribution','Unknown-Unknown','DemonHunter-Havoc','DeathKnight-Blood','Shaman-Enhancement','Shaman-Elemental','Druid-Balance','Monk-Brewmaster','Monk-Mistweaver','Druid-Guardian','Druid-Feral','Hunter-Marksmanship','Priest-Shadow','Priest-Holy','Paladin-Protection','Mage-Fire','Druid-Restoration','Warlock-Destruction','Warlock-Affliction','Hunter-BeastMastery','DeathKnight-Unholy','Shaman-Restoration','Mage-Frost','DeathKnight-Frost','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Warrior-Protection','Rogue-Assassination','Mage-Arcane',}; local provider = {region='CN',realm='菲米丝',name='CN',type='weekly',zone=42,date='2025-04-15',data={Am='Ambitions:AwACCAIABRQAAQEANhoGCAYABRQ=.',Da='Dababy:AwACCAIABRQAAA==.',Do='Dogthing:AwABCAEABRQAAA==.',Fl='Flowerleaf:AwAICAwABAoAAA==.',Ki='Kiwi:AwACCAIABAoAAA==.',Lu='Luckycrystal:AwABCAEABRQAAQIAAAAICAQABRQ=.',Me='Mediocre:AwAICAwABAoAAA==.Merciless:AwAFCAUABAoAAA==.',Mu='Much:AwAFCAYABAoAAA==.',Ra='Raywind:AwAECAQABRQAAA==.',Wk='Wkyel:AwAECAQABAoAAA==.',['�']='一个狗两个末:AwAECAQABAoAAA==.一个这么帅:AwAGCBIABAoAAA==.丶冷骨头:AwADCAYABRQCAwADAQgWDABC8wIBBRQAAwADAQgWDABC8wIBBRQAAQQAV3UICAgABRQ=.丶弄潮儿:AwACCAIABRQAAA==.丹妮莉丝:AwADCAMABAoAAA==.',['�']='五晨寺憨憨:AwACCAIABAoAAA==.',['�']='傲天狂少:AwADCAYABRQDBQADAQiJCgA7TdwABRQABQADAQiJCgAgKtwABRQABgACAQgKDgA3J5gABRQAAA==.',['�']='克拉蒙托:AwABCAEABAoAAA==.全部丢翻:AwAECAQABRQAAA==.六叔跌摩托:AwAGCBUABAoCBwAGAQgFPgBQBJYBBAoABwAGAQgFPgBQBJYBBAoAAA==.六眼飞鱼:AwAGCA8ABAoAAA==.',['�']='冷在骨子里丶:AwAGCAcABAoAAA==.',['�']='卧槽帅狗:AwADCAMABRQCBQAIAQhaAwBfL+ICBAoABQAIAQhaAwBfL+ICBAoAAA==.',['�']='只杀不渡:AwAFCAUABAoAAA==.可以丶可以:AwAECA4ABRQDCAAEAQjABAAX4pkABRQACAADAQjABAAX4pkABRQACQACAQgyIwAck0kABRQAAA==.可牛了:AwADCAQABAoAAA==.叶子:AwAECAQABAoAAA==.叶知秋:AwACCAQABAoAAA==.',['�']='呆河:AwADCAYABRQCBAADAQgtCABFNPEABRQABAADAQgtCABFNPEABRQAAA==.呜喵:AwADCAkABRQECgADAQgdAQBJP9sABRQACgADAQgdAQA9R9sABRQACwACAQjyAwBCD6oABRQABwACAQgXIgAUP4YABRQAAA==.呲莮孓未緡:AwAECAgABRQCDAAEAQi5BgBC/voABRQADAAEAQi5BgBC/voABRQAAA==.',['�']='咆哮斩杀者:AwADCAMABAoAAA==.',['�']='四时沐无心:AwAGCAcABRQDDQAIAQizHQAu5c0BBAoADQAIAQizHQAu5c0BBAoADgABAQiZkwAAAAAABAoAAA==.因吹斯汀:AwADCAMABAoAAA==.国清寺方丈:AwABCAIABAoAAQIAAAABCAEABRQ=.',['�']='地雪天痕之骸:AwACCAIABRQAAA==.',['�']='坐忘道丶:AwAICBAABAoAAQIAAAAICAIABRQ=.',['�']='夏沫浅浅:AwACCAIABRQAAA==.夜太美:AwAICAgABAoAAA==.大男孩:AwAFCAUABAoAAA==.天命:AwAGCAYABAoAAQkAOigGCAoABRQ=.',['�']='学长:AwACCAQABRQCDwAIAQhvKQAQaOcABAoADwAIAQhvKQAQaOcABAoAAA==.学长不坏:AwADCAQABAoAAA==.',['�']='寒羽洋:AwADCAYABRQCEAADAQiDEwA3+fEABRQAEAADAQiDEwA3+fEABRQAAA==.',['�']='小柔柔:AwAFCAMABAoAAA==.小黑嘿潶:AwADCAkABRQCEQADAQjxAwBK1SABBRQAEQADAQjxAwBK1SABBRQAAA==.',['�']='岩七七:AwADCAcABRQDEgADAQhcGgA0DI0ABRQAEgACAQhcGgA73I0ABRQAEwABAQhjGAAka0sABRQAAA==.',['�']='希尔瓦娜女王:AwAGCAoABRQDDAAGAQgZAABKivEBBRQADAAGAQgZAABKivEBBRQAFAAEAQjRGQAundoABRQAAA==.',['�']='幽默多拉贡:AwACCAIABAoAAA==.',['�']='强灬干丶:AwAFCAUABAoAAA==.',['�']='御灵:AwAECAQABRQAAA==.德一只:AwABCAEABRQAAA==.',['�']='愤怒的小妖:AwACCAIABRQAAA==.',['�']='我的二哈呢:AwADCAkABRQDFAADAQjAGwAfcdAABRQAFAADAQjAGwAastAABRQADAACAQhmFQAbU38ABRQAAA==.',['�']='打工人丶:AwAHCA8ABAoAAA==.',['�']='抬手打冲拳:AwADCAUABRQCFAADAQhoFAA6CfEABRQAFAADAQhoFAA6CfEABRQAAA==.',['�']='拔丝土豆:AwABCAEABRQCDgAIAQibCgBM1m8CBAoADgAIAQibCgBM1m8CBAoAAA==.',['�']='擦擦二号:AwAHCAgABAoAAA==.',['�']='放开那娘们:AwAFCAUABAoAAA==.放开那阿婆:AwAFCAUABAoAAA==.',['�']='无面者:AwABCAEABRQCAwAIAQg6OwAokaEBBAoAAwAIAQg6OwAokaEBBAoAAA==.',['�']='春夏丶秋冬:AwADCAUABRQCFQADAQi2DAA8Ye8ABRQAFQADAQi2DAA8Ye8ABRQAAA==.',['�']='暗夜紫煌:AwAECAQABRQAAA==.',['�']='村绯绯:AwADCAMABAoAAA==.杰尼杰尼:AwAHCAcABAoAAA==.',['�']='林江仙丶:AwAICA4ABAoAAA==.',['�']='柠檬薄荷:AwADCAkABRQCFgADAQhtBgBDJxYBBRQAFgADAQhtBgBDJxYBBRQAAA==.',['�']='森木多:AwAECAQABRQAAA==.',['�']='椰子君:AwAICAEABAoAAA==.',['�']='楓爵:AwABCAEABAoAAA==.',['�']='气旋魂破:AwAFCAoABAoAAA==.',['�']='沙德沃克:AwAGCAQABRQCEQAEAQjaBQA7+f0ABRQAEQAEAQjaBQA7+f0ABRQAAA==.',['�']='流浪的王富贵:AwAGCAgABRQDEAAGAQhyBAAyqZQBBRQAEAAGAQhyBAAuIZQBBRQAFwACAQj0CwBN2aIABRQAAA==.流用:AwABCAEABRQDAQAIAQj6ZgBAabABBAoAAQAHAQj6ZgBD7rABBAoADwAHAQjRHQAuYEUBBAoAAA==.浪子:AwAGCAYABAoAAA==.',['�']='满满丶:AwAECAgABRQCBwAEAQgkGAAm7L8ABRQABwAEAQgkGAAm7L8ABRQAAA==.',['�']='潞過傷人:AwAICAkABAoAAA==.',['�']='爱你的猫:AwABCAEABRQAAA==.',['�']='牛气十足:AwADCAkABRQCFgADAQjNEAAeg9YABRQAFgADAQjNEAAeg9YABRQAAA==.牛气骁德:AwABCAEABAoAAA==.牛頓:AwACCAMABAoAAA==.牡丹丶:AwAECAQABRQAAA==.牵手丶:AwAICBMABAoAAA==.',['�']='狂奔不回头:AwADCAkABRQDFQADAQhwDwAlCt8ABRQAFQADAQhwDwAlCt8ABRQAGAABAQiGCAANzzIABRQAAA==.',['�']='猩红王子:AwACCAQABRQEGQAIAQjtEgBJ2xACBAoAGQAIAQjtEgBJ2xACBAoAGgADAQhnBQAsUXUABAoAGwABAQiXKwAAAAAABAoAAA==.',['�']='王者降临:AwADCAkABRQCHAADAQhbAgBFefUABRQAHAADAQhbAgBFefUABRQAAA==.',['�']='甄能电:AwAECAQABAoAAA==.甄能砍:AwAECAQABAoAAA==.由我来平衡丶:AwACCAIABRQCGwAIAQhUDgAhFmQBBAoAGwAIAQhUDgAhFmQBBAoAAA==.',['�']='瘋狂的帽商:AwAECA0ABRQDEwAEAQinAQBgZzMBBRQAEwADAQinAQBUSzMBBRQAEgAEAQj6CQA+HvgABRQAAA==.',['�']='相思何愁:AwAECAQABAoAAA==.',['�']='石原里美:AwAICAgABAoAAA==.',['�']='神经骑天下:AwAICAgABAoAAA==.',['�']='米迦勒的裁决:AwAECAQABAoAAA==.',['�']='红灬莲:AwAGCAYABAoAAA==.',['�']='老呆河马:AwAICAgABAoAAA==.',['�']='肚子丨:AwAICBUABAoCCwAIAQjIBwA7SzcCBAoACwAIAQjIBwA7SzcCBAoAAA==.',['�']='胭珈凌雪:AwABCAEABRQDEAAIAQicNgAqlK8BBAoAEAAIAQicNgAqDK8BBAoAFwACAQjxiAA01V4ABAoAAA==.',['�']='芳心纵火犯:AwAFCAUABAoAAA==.',['�']='苹果贼:AwADCAMABAoAAA==.',['�']='莉莉安:AwAFCAwABAoAAA==.',['�']='菜奶:AwAFCAwABAoAAA==.菲胡:AwABCAEABAoAAA==.',['�']='萌丶米迦勒:AwAFCAUABAoAAA==.萌小僧:AwABCAEABAoAAA==.',['�']='薇儿丶:AwAHCAMABAoAAA==.',['�']='蘇丶:AwAICBQABAoDBAAIAQiFCQBRTXYCBAoABAAIAQiFCQBRTXYCBAoAFQAIAQgNwgAAkgAABAoAAA==.',['�']='蜻蜓队长:AwADCAoABRQCAQADAQgsBABgzEgBBRQAAQADAQgsBABgzEgBBRQAAA==.',['�']='蟹中蟹:AwAGCBcABAoCAQAGAQhOOgBh6ygCBAoAAQAGAQhOOgBh6ygCBAoAAA==.',['�']='血灵狂魔:AwAICBEABAoAAA==.',['�']='西索:AwAFCAYABAoAAA==.',['�']='让你三招:AwAGCAYABRQCHQAGAQjwAAA0j8IBBRQAHQAGAQjwAAA0j8IBBRQAAA==.',['�']='诠释东锅锅:AwABCAEABRQAAA==.',['�']='贫尼光天化日:AwAECAQABRQAAA==.',['�']='赞达拉狂少:AwAGCAYABAoAAA==.',['�']='路西法晨星:AwACCAIABAoAAA==.',['�']='踮脚吃个个:AwAECAUABRQCDwAEAQg7CwAd2ZAABRQADwAEAQg7CwAd2ZAABRQAAA==.',['�']='邓不利少:AwADCAYABRQDEAADAQibGgAh5doABRQAEAADAQibGgAhM9oABRQAHgABAQhoAwAQlUMABRQAAA==.',['�']='雪影影雪:AwACCAIABRQAAA==.雪月风花:AwAGCAYABAoAAA==.',['�']='领灬主:AwAICAgABAoAAA==.',['�']='风入疏竹:AwABCAEABRQAAA==.风行长空:AwADCAMABAoAAA==.',['�']='香蕉酱:AwAHCAoABAoAAA==.',['�']='高科技:AwAECAQABRQAAA==.',['�']='黑得出奇:AwADCAMABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end