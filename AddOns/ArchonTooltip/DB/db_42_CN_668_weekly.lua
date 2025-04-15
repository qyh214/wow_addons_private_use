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
 local lookup = {'Evoker-Devastation','DeathKnight-Unholy','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Mage-Fire','Mage-Frost','Priest-Discipline','Priest-Holy','Warrior-Protection','DeathKnight-Blood','Priest-Shadow','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Shaman-Enhancement','Shaman-Restoration','Shaman-Elemental','DemonHunter-Vengeance','DemonHunter-Havoc','Warrior-Arms','Druid-Restoration','Druid-Balance','Unknown-Unknown','Rogue-Assassination','Rogue-Subtlety','Monk-Windwalker','Paladin-Protection','Paladin-Holy','Paladin-Retribution',}; local provider = {region='CN',realm='布莱恩',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ap='Apt:AwAGCAsABAoAAA==.',Ar='Arii:AwABCAEABAoAAA==.',Aw='Awasubaru:AwADCAMABAoAAA==.',Ev='Evazore:AwABCAEABRQAAA==.',Fi='Fingerto:AwAFCAQABAoAAA==.',Jc='Jchc:AwAECAQABAoAAA==.',Ka='Kakamie:AwADCA0ABRQCAQADAQg5CQA58uQABRQAAQADAQg5CQA58uQABRQAAA==.',Po='Pororo:AwAECAQABRQAAA==.',Yi='Yiyiyi:AwADCAMABAoAAA==.',Zh='Zhan:AwACCAIABAoAAA==.',['�']='一只老鸽子:AwACCAMABRQAAA==.一梦一瑾年:AwAICAgABAoAAQIAPpAGCAgABRQ=.一颗油麦菜:AwABCAEABAoAAA==.一骑绝尘风:AwADCAYABRQDAwADAQiwGABV/UgABRQAAwACAQiwGABXHUgABRQABAABAQh0OABTv0cABRQAAA==.三澄美琴:AwAICBcABAoCBQAIAQhmDABOcnYCBAoABQAIAQhmDABOcnYCBAoAAA==.三鹰朝:AwAICA4ABAoAAA==.下水道的光辉:AwABCAEABRQDBgAIAQgfLQBAx9kBBAoABgAIAQgfLQA3qdkBBAoABwACAQhtYgBNpbUABAoAAA==.不喜豚:AwABCAEABAoAAA==.不能算了:AwAGCAYABAoAAA==.不许喂猫呀丶:AwAICCEABAoDCAAIAQg0JQAxHnsBBAoACAAHAQg0JQA2unsBBAoACQABAQhEggAPdTEABAoAAA==.专吃男大学生:AwACCAIABAoAAA==.丰茹丶肥臀:AwABCAEABAoAAA==.丶喵呜喵呜:AwAGCAYABAoAAA==.',['�']='九天战神:AwAICBkABAoCCgAIAQgvCQBBBQECBAoACgAIAQgvCQBBBQECBAoAAA==.',['�']='了然:AwAECAQABAoAAA==.井井丨:AwAECAgABRQDAgADAQjXCAAxZ/4ABRQAAgADAQjXCAAxZ/4ABRQACwACAQiUFgAa5GQABRQAAA==.',['�']='以德服人啊:AwADCAMABAoAAA==.',['�']='伊什塔尔:AwAICAEABAoAAA==.',['�']='倾穹:AwADCAgABRQDCAADAQiTCwBLvdYABRQACAACAQiTCwBfi9YABRQADAABAQhGHwALJEIABRQAAA==.',['�']='克里斯滕丽特:AwACCAIABAoAAA==.',['�']='冰河葬寒心:AwACCAMABRQAAA==.冷色:AwABCAEABAoAAA==.',['�']='凤舞九天:AwAFCAMABRQAAA==.凯鲨:AwAICB0ABAoDBgAIAQh5KQA2W+0BBAoABgAIAQh5KQA2W+0BBAoABwADAQjMdgAjT4EABAoAAA==.',['�']='别打我别打我:AwABCAEABAoAAQEAXu0ICCgABAo=.刺探你的温柔:AwACCAIABAoAAA==.',['�']='剡溟:AwAECAQABRQAAA==.',['�']='勇敢的火柴:AwAFCAUABRQDDQAFAQj3AwAuawYBBRQADQAEAQj3AwA6YQYBBRQADgABAQgeDQAKilIABRQAAA==.',['�']='十年术木:AwAICB0ABAoDDwAIAQj6DwBWTFwCBAoADwAHAQj6DwBY4lwCBAoADgACAQj4VgBGzFEABAoAAA==.十的八次方:AwAGCAoABRQDBwAGAQgXAQBPDTkBBRQABgAGAQj6AgA3u6QBBRQABwAEAQgXAQBcIjkBBRQAAA==.卫宫切嗣:AwAICAgABAoAAA==.',['�']='受死:AwABCAEABRQAAA==.',['�']='哥屋恩滚:AwABCAEABRQAAA==.',['�']='啊灭火啦:AwAECAcABRQEEAAIAQgZHAA9dssBBAoAEAAHAQgZHABAnMsBBAoAEQAHAQgaNAA38o8BBAoAEgAEAQgWPgA1VPEABAoAAA==.',['�']='在吾之下:AwABCAEABRQAAA==.',['�']='复仇:AwAECA0ABRQDBgAEAQg9GAA8H9kABRQABgAEAQg9GAA7GtkABRQABwABAQjoEwAi8ksABRQAAA==.多莉的擁抱:AwADCA8ABRQCEwADAQiNAwBBnucABRQAEwADAQiNAwBBnucABRQAAA==.大藏里想奈:AwAGCAkABAoAAA==.大迪克:AwAGCA0ABAoAAA==.天堂审判:AwACCAIABAoAAA==.',['�']='她真的不一样:AwAGCAcABAoAAA==.',['�']='姑娘你的绿箭:AwAICAgABAoAAA==.',['�']='嬛嬛:AwABCAEABRQAAA==.',['�']='宇宙骑丶磊神:AwAECAQABRQAAA==.安静:AwAECAkABAoAAA==.',['�']='对影:AwAICBAABAoAAA==.',['�']='小丑龙:AwAICCgABAoCAQAIAQg1AwBe7dUCBAoAAQAIAQg1AwBe7dUCBAoAAA==.小小卉卉:AwAGCAwABRQCCAAGAQjaAABCW8YBBRQACAAGAQjaAABCW8YBBRQAAA==.小手火热热丶:AwADCAMABAoAAA==.小龙人没翅膀:AwAICAgABAoAAA==.',['�']='幽璃:AwAGCAwABRQCFAAGAQhSAABafCcCBRQAFAAGAQhSAABafCcCBRQAAA==.',['�']='张三疯:AwAECAEABAoAAA==.',['�']='忽悠忽悠你:AwAGCAYABAoAAA==.忽悠忽悠猎:AwAICAYABAoAAA==.',['�']='怒灿:AwADCA8ABRQDCgADAQiiAQBNABABBRQACgADAQiiAQBNABABBRQAFQACAQjJCwAtJZYABRQAAA==.',['�']='我都影遁了:AwAICBkABAoDAgAIAQg0EwBQ9m0CBAoAAgAIAQg0EwBQ9m0CBAoACwACAQjFTgAd7VQABAoAAA==.战场原黒仪:AwADCA8ABRQDFgADAQi2BwAwmdQABRQAFgADAQi2BwAwmdQABRQAFwACAQgaHwAiyIUABRQAAA==.戰魂丶小雄:AwAGCAYABAoAAA==.',['�']='提里奥弗丁丶:AwAICAgABAoAARgAAAAICAQABRQ=.',['�']='擎潮主:AwADCAsABRQCEQADAQhcBQBIehcBBRQAEQADAQhcBQBIehcBBRQAAA==.',['�']='散夜花影:AwACCAIABAoAARAAPXYECAcABRQ=.',['�']='斩雷:AwAECAQABRQAAA==.方彤彤:AwAECAYABRQCCQAEAQi4CgAVX8EABRQACQAEAQi4CgAVX8EABRQAAA==.',['�']='无玄:AwAECA0ABRQCAgAEAQgkBwBU5QsBBRQAAgAEAQgkBwBU5QsBBRQAAA==.',['�']='是眼子啊:AwAICAgABAoAAA==.',['�']='暴风星辰:AwAECAQABRQAAA==.',['�']='曦风月:AwAGCAYABAoAAA==.',['�']='月罄霊语:AwABCAEABRQAARgAAAAGCAIABRQ=.有事稳李锐:AwABCAEABRQAAA==.木依:AwAECAUABRQEDQAEAQjXFwAwi0gABRQADQABAQjXFwAvkEgABRQADgABAAgAAAA+WQAABRQADwACAAgAAAAjtwAABRQAAA==.木宁馨:AwAECA0ABRQCCwAEAQgTCgA5hMkABRQACwAEAQgTCgA5hMkABRQAAA==.',['�']='杨桃子:AwAFCAkABAoAARIAVZkICAIABRQ=.',['�']='欧皇敏爷:AwAFCAUABAoAAA==.',['�']='武汉特色小吃:AwADCAoABRQCFwADAQheCABNYQwBBRQAFwADAQheCABNYQwBBRQAAQkASqAECAYABRQ=.',['�']='淺墨未央:AwADCA8ABRQDGQADAQi6CQAPVrkABRQAGQADAQi6CQAPVrkABRQAGgABAQhKEgAAxicABRQAAA==.',['�']='炼狱修罗斩:AwAHCAoABAoAAA==.',['�']='烂榜样:AwAICA4ABAoAAA==.烈海王:AwAECBEABRQCGwAEAQg9BABPxx0BBRQAGwAEAQg9BABPxx0BBRQAAA==.热不同:AwAICAIABAoAAA==.',['�']='焰天火雨:AwAICAMABAoAAA==.',['�']='熊熊不怕疼:AwAECAwABRQCHAAEAQg+DQAJEW4ABRQAHAAEAQg+DQAJEW4ABRQAAA==.',['�']='狂热心潮:AwAICA4ABAoAAA==.狩魔人杰洛特:AwAGCAYABAoAAA==.独鹿:AwACCAUABRQCFQACAQhWCQA626oABRQAFQACAQhWCQA626oABRQAAA==.',['�']='玛咔咔酱:AwAICAgABAoAAA==.玩具枪丶:AwAICB8ABAoCEgAIAQgIHAA5OtwBBAoAEgAIAQgIHAA5OtwBBAoAAA==.玩原神玩的:AwAGCAEABAoAAA==.',['�']='疯狂喀秋莎:AwAECAQABRQAAA==.',['�']='盖伦出轻语:AwADCAMABAoAAA==.',['�']='真页孑亥:AwAICBAABAoAAA==.',['�']='神罚:AwAGCA4ABAoAAA==.',['�']='笑里有雨滴:AwAECAMABRQAAA==.',['�']='绘梨依:AwABCAEABRQAAA==.绯樱闲:AwAHCBUABAoDDgAHAQjMFABD9JYBBAoADgAGAQjMFABB4ZYBBAoADwAFAQjBTQA/ug8BBAoAAA==.维尔薇:AwACCAIABAoAAA==.',['�']='脆脆角:AwAICAoABAoAAQEAXu0ICCgABAo=.',['�']='花開丶幻想:AwAGCAYABAoAAA==.',['�']='萤火虫之森:AwAICBQABAoDCAAIAQgFNgAgbBoBBAoACAAHAQgFNgAlKxoBBAoACQABAQi7jAAD8hwABAoAAA==.',['�']='蓅輦丶:AwACCAUABRQCFAACAQgCIAAlUYkABRQAFAACAQgCIAAlUYkABRQAAQIAMIwCCAYABRQ=.',['�']='西宫结弦:AwAECAQABRQAAQsAY3oICAoABRQ=.',['�']='许仲康:AwABCAEABAoAAA==.',['�']='辣个帅锅:AwACCAIABAoAAA==.达克赛德:AwAICAgABAoAAA==.',['�']='这个恐惧奈斯:AwACCAIABRQAAA==.',['�']='醉枪:AwADCAkABRQDAwADAQhUAwBI6xQBBRQAAwADAQhUAwBI6xQBBRQABAABAQhJPAAWjUAABRQAAA==.',['�']='锅盔夹凉粉:AwACCAQABRQDHQAIAQgiDwBD/+MBBAoAHQAIAQgiDwBD/+MBBAoAHgAGAQiogABALWsBBAoAAA==.',['�']='阿伟:AwADCAcABRQCBgADAQjmFAA6huUABRQABgADAQjmFAA6huUABRQAAA==.阿熊:AwAECAgABRQCGQAEAQjyBQA12foABRQAGQAEAQjyBQA12foABRQAAA==.阿菲:AwAFCAYABAoAAA==.',['�']='雨夜听荷:AwADCAMABAoAAA==.',['�']='馨魔:AwACCAIABRQAAA==.',['�']='魑魅丶魍魉:AwACCAYABRQCAgACAQjKFQAwjJ8ABRQAAgACAQjKFQAwjJ8ABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end