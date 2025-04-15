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
 local lookup = {'Monk-Brewmaster','Priest-Discipline','Priest-Holy','Mage-Frost','Mage-Fire','DeathKnight-Blood','Rogue-Assassination','Rogue-Subtlety','Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','Warrior-Fury','DeathKnight-Unholy','DeathKnight-Frost','DemonHunter-Havoc','DemonHunter-Vengeance','Unknown-Unknown','Warrior-Arms','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Paladin-Protection','Evoker-Preservation',}; local provider = {region='CN',realm='太阳之井',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ai='Ainzy:AwADCAUABRQCAQADAQixAwAkNq0ABRQAAQADAQixAwAkNq0ABRQAAA==.',Al='Alexstraza:AwABCAEABRQAAA==.',Ev='Evildoers:AwAECAQABRQAAA==.',Fa='Fannes:AwADCAMABRQAAA==.',Gi='Gina:AwAECAQABRQAAA==.',It='Ithilwen:AwAECAUABRQDAgAEAQgyCQA1fusABRQAAgAEAQgyCQA1fusABRQAAwABAQiOIAAAAAAABRQAAA==.',Li='Littlepuppe:AwAFCAUABAoAAA==.',Ma='Magictata:AwAECAgABRQDBAADAQiWDAA5GJAABRQABAADAQiWDAA5GJAABRQABQACAQipKQAP+XoABRQAAA==.',Pr='Protect:AwAHCAcABAoAAA==.',Qc='Qck:AwACCAIABAoAAA==.',Ri='Ririsuamano:AwAFCAUABAoAAA==.',Sm='Smoms:AwAHCAcABAoAAA==.',Sp='Spica:AwAECAQABRQAAA==.',Su='Sunbiood:AwAICBkABAoCBAAIAQiKJAA2VMwBBAoABAAIAQiKJAA2VMwBBAoAAA==.',Ta='Tarotlin:AwACCAIABRQAAA==.',Ul='Ulorion:AwACCAIABRQAAA==.',Un='Unmilk:AwADCAMABRQAAA==.',Zh='Zhaobenshan:AwAECAYABRQCBgAEAQj3BgBELvQABRQABgAEAQj3BgBELvQABRQAAA==.',Zi='Zibuyu:AwAECAQABRQAAA==.',['�']='一个贝宁萨:AwAICAoABAoAAA==.一双大眼镜:AwACCAIABRQAAA==.一粟麦子:AwAGCAsABAoAAA==.七月之祭:AwABCAEABRQDBwAHAQhsDwBOygECBAoABwAHAQhsDwBOygECBAoACAABAQhcNgAi8TQABAoAAA==.三十八号拖鞋:AwADCAMABAoAAA==.不懂事大嘻嘻:AwAFCAUABAoAAA==.丨酸梅汤:AwADCAMABAoAAA==.丶情若:AwAICAoABAoAAA==.丶艾米莉亚:AwAECAQABRQAAQUARzEGCAkABRQ=.丶苍穹:AwAICAEABAoAAA==.为了脸瞢:AwACCAIABRQAAA==.丿宝哥别闹:AwACCAUABRQDCQACAQiBHgAPgHkABRQACQACAQiBHgAPgHkABRQACgACAQhBEQAECVkABRQAAA==.丿晓海:AwAECAcABAoAAA==.',['�']='乌拉罗格塑山:AwADCAMABAoAAA==.乖豬:AwAECAQABRQAAA==.',['�']='似梦丶非梦:AwAGCAgABAoAAA==.',['�']='借我清风一缕:AwAICAgABAoAAQUAVEsICBAABRQ=.',['�']='傲娇丶忘忧雪:AwAECAQABRQAAA==.傻漫:AwAFCAUABAoAAA==.',['�']='像风:AwAECAQABAoAAA==.',['�']='六千里丿:AwAECAQABRQAAA==.',['�']='别装逼:AwACCAIABAoAAA==.',['�']='加满怡泉桃子:AwAECAQABRQAAA==.加鲁鲁丶:AwACCAIABRQAAA==.',['�']='医生姐姐来了:AwAECAQABRQAAA==.',['�']='千龙锤子:AwABCAIABRQCCwAHAQiUkQAmBUMBBAoACwAHAQiUkQAmBUMBBAoAAA==.半条毛毛虫:AwAGCAYABAoAAA==.卡坦精:AwAICBcABAoCDAAIAQi8LAAi6rQBBAoADAAIAQi8LAAi6rQBBAoAAA==.卡塞尔村雨:AwAICAIABAoAAA==.卷中红尘:AwAECAMABRQEDQAIAQjJFwBSzkwCBAoADQAIAQjJFwBSHkwCBAoADgAEAQgDFQAzNhgBBAoABgACAQhlPQBP0KIABAoAAA==.',['�']='叁拾柒度陆:AwAGCAYABAoAAA==.叫我丶小肉肉:AwABCAEABAoAAA==.叶亿聚花:AwAHCBIABAoAAA==.',['�']='吃熊猫的小竹:AwAFCAUABAoAAA==.吴老板真身:AwAGCAUABAoAAA==.',['�']='嘟嘟小头:AwABCAEABAoAAA==.',['�']='圈圈灬熊:AwAECBEABRQDCQAEAQhLEgAMbb4ABRQACQAEAQhLEgAMbb4ABRQACgABAQi+EwAgc0YABRQAAA==.圣兮:AwAECAcABRQCCwAEAQhUCgBLuhcBBRQACwAEAQhUCgBLuhcBBRQAAA==.圣鸽:AwAICAgABAoAAA==.',['�']='塞纳河曾小野:AwAICAQABAoAAA==.',['�']='夏娜:AwEICAgABAoAAA==.夜舞灬小莎:AwAICA4ABAoAAA==.夜间随风去:AwACCAIABRQAAA==.天使猎魔人:AwABCAEABRQDDwAIAQhCQgAeBHUBBAoADwAIAQhCQgAds3UBBAoAEAAFAQg1PgAbxJYABAoAAA==.天启神圣:AwACCAMABRQAAA==.天堂制造:AwAECAMABAoAAREAAAAHCAcABAo=.',['�']='奈茶的雪:AwAFCAUABAoAAA==.套你猴子丶:AwABCAEABRQAAA==.奥术冰晶:AwAICAkABAoAAA==.奶酪菌丶:AwAICAgABAoAAA==.',['�']='如你默认:AwADCAMABAoAAA==.妘轩:AwADCAUABAoAAA==.妞比闪电:AwACCAUABRQCCQACAQhuGAArHpUABRQACQACAQhuGAArHpUABRQAAA==.',['�']='娘子请自重:AwAICA8ABAoAAA==.',['�']='季災:AwAECAQABRQAAA==.',['�']='小小狐喵:AwAECAQABRQAAA==.小木怕风吹:AwAGCAcABAoAAA==.小清风:AwAECAQABRQAAA==.小角白牛骑士:AwAICBYABAoCCwAIAQjZXwAu8rcBBAoACwAIAQjZXwAu8rcBBAoAAA==.小阿他姐:AwAECAUABAoAAA==.',['�']='山东小红:AwABCAEABRQAAA==.',['�']='巴比伦女王:AwAGCAYABAoAAA==.',['�']='希爾法:AwAECAQABRQAAA==.',['�']='幽媚蛰兰:AwABCAEABAoAAA==.幽空:AwAHCAsABAoAAA==.',['�']='张科長:AwAGCBEABRQDDAAGAQiQAABQ/LkBBRQADAAFAQiQAABWALkBBRQAEgABAQgbDwA862EABRQAAA==.',['�']='徒手劈活德:AwAICAUABAoAAA==.',['�']='怕娃落地:AwAICAYABAoAAA==.',['�']='惊声尖笑:AwABCAEABRQAAA==.',['�']='愤怒的米卡:AwAECAQABRQAAA==.',['�']='懒觉猫:AwACCAQABRQAAA==.',['�']='我叫高小法:AwAECAQABRQAAA==.我很残暴:AwACCAIABRQAAQUAPU4ICAkABRQ=.战陨圣:AwAICA8ABAoAAA==.',['�']='排干体液:AwAGCAYABAoAAA==.',['�']='提婆达多:AwAICA0ABAoAAA==.',['�']='放牧寂寞:AwAGCAoABAoAAA==.',['�']='断剣:AwACCAUABRQDEwACAQihJAAyNJYABRQAEwACAQihJAAyNJYABRQAFAABAQiRGwAXJT0ABRQAAA==.',['�']='旅馆大掌柜:AwACCAMABRQEEwAIAQgARABKy8ABBAoAEwAHAQgARABJZcABBAoAFAAEAQiARwA7+rAABAoAFQABAQjEGQA8PToABAoAAA==.旖旎血影:AwAECAQABRQAAREAAAAGCAIABRQ=.旷野狼:AwAECAcABAoAAA==.',['�']='星丨光:AwAGCAcABAoAAA==.星灬空:AwAECAgABRQDFAAEAQjYBABS0gIBBRQAFAAEAQjYBABP2wIBBRQAEwAEAQgIDwBPNP0ABRQAARQAVdsICAgABRQ=.',['�']='暗域丶神谕者:AwAHCAcABAoAAA==.暗蓝之月:AwAHCAcABAoAAA==.暗行逍遥:AwAFCAIABAoAAA==.暴躁的输出:AwAECAUABAoAAA==.',['�']='最矮的:AwAGCAYABAoAAA==.月性阑珊:AwAECAQABRQAAQUATgYGCAgABRQ=.未來未曾來:AwACCAIABAoAAA==.未灬泱:AwAECAQABRQAAA==.',['�']='李娅君:AwACCAMABRQDCwAHAQjrgQA3JGgBBAoACwAGAQjrgQA8k2gBBAoAFgAGAQhvPAALNncABAoAAA==.',['�']='极个别同学:AwABCAEABRQAAA==.极度的小红:AwACCAQABRQCEgAIAQjgCwBGzEgCBAoAEgAIAQjgCwBGzEgCBAoAAA==.',['�']='梦幻泡影:AwABCAEABAoAAA==.梦影锋:AwAICAgABAoAAA==.梦醉清风:AwAHCA8ABAoAAA==.',['�']='正义王王:AwAICAgABAoAAA==.武状元丷:AwADCAMABAoAAA==.死亡的牛:AwADCAIABAoAAA==.',['�']='残月升风:AwAGCAYABAoAAA==.',['�']='沐泽小木:AwACCAIABRQAAA==.',['�']='法客油丶:AwAHCAQABAoAAA==.',['�']='涉猎星辰:AwAECAQABRQAAA==.',['�']='灬咔咔罗特灬:AwACCAIABAoAAA==.灬安吉:AwACCAIABRQAAA==.灬桃乐丝灬:AwAICAgABAoAAA==.灭世哀伤:AwAGCAYABAoAAA==.',['�']='無情乄杀戮:AwAECAQABRQAAA==.',['�']='犀利丶归来:AwAFCAkABAoAAA==.',['�']='甜兒丶很嗳妳:AwADCAIABAoAAA==.甜奶茶:AwAHCAUABAoAAA==.',['�']='留念人间法:AwAECAQABRQAAA==.',['�']='癸巳:AwAGCAEABAoAAA==.',['�']='相似:AwAHCAkABAoAAA==.',['�']='站那不准动丶:AwABCAEABRQAAA==.',['�']='筱灬筱:AwAICBsABAoCAwAIAQgBKQAoeX4BBAoAAwAIAQgBKQAoeX4BBAoAAA==.',['�']='绚丽之战:AwADCAMABAoAAA==.绚丽圣光:AwAGCAkABAoAAA==.绚丽百变:AwADCAMABAoAAA==.',['�']='缚魂者:AwAICAgABAoAAA==.',['�']='肤浅丶六道:AwAICA4ABAoAAA==.',['�']='自摸造物带槽:AwAICAgABAoAAA==.',['�']='芙莱雅:AwAFCAUABAoAAA==.',['�']='苟苟狗丶:AwACCAIABRQAAA==.若浮烟:AwAECAQABRQAAA==.',['�']='莫得感情喵:AwAICAgABAoAAA==.',['�']='菲利克斯七七:AwAECAsABRQCCQAEAQjKBwBDZgEBBRQACQAEAQjKBwBDZgEBBRQAAA==.',['�']='蔡咕:AwAECAQABRQAARcAGncGCAUABRQ=.',['�']='蕾丝小晴晴:AwACCAIABAoAAA==.',['�']='藏污纳狗:AwAICBAABAoAAA==.',['�']='衔蝉:AwAICAgABAoAAA==.',['�']='裂膝:AwADCAMABAoAAA==.',['�']='西丁肉丸:AwAECAQABRQAAA==.西门吹牛:AwAICAYABAoAAA==.',['�']='言出法随:AwAECAQABRQAAA==.',['�']='豆芽菜:AwAICB8ABAoDFAAIAQihJAA+oHkBBAoAFAAIAQihJAAv8nkBBAoAEwADAQipjwA7s90ABAoAAA==.',['�']='贝吉塔:AwACCAIABRQAAQ8AEAgECAYABRQ=.',['�']='赤岩:AwAGCAkABAoAAA==.走廊上的琉璃:AwAHCAoABAoAAA==.',['�']='超越者:AwAGCAcABRQCDQAGAQhaAQA0FqEBBRQADQAGAQhaAQA0FqEBBRQAAA==.',['�']='躺尸叁摆手:AwAGCAQABRQAAA==.',['�']='輕雪飛揚:AwACCAIABRQAAA==.',['�']='远看是头牛:AwACCAIABAoAAA==.',['�']='部落铁壁:AwAHCA4ABAoAAA==.都别动让我来:AwAICAgABAoAAA==.',['�']='释果宁:AwAFCAUABAoAAA==.量多了当面霜:AwABCAEABAoAAA==.',['�']='阮软软:AwAICAsABAoAAA==.防寒鞋:AwABCAEABAoAAA==.阳光正好:AwACCAQABRQDEwAIAQhhJABUxkgCBAoAEwAIAQhhJABUQ0gCBAoAFAADAQisOABOxPkABAoAAA==.阿瑞斯的荣耀:AwAICAgABAoAAREAAAAECAQABRQ=.',['�']='随地大小睡:AwACCAIABRQAAA==.隐退后的宿醉:AwAECAQABAoAAA==.',['�']='雷霆司命:AwAGCAYABAoAAA==.',['�']='青华:AwADCAkABRQCFgADAQigAwBO+w8BBRQAFgADAQigAwBO+w8BBRQAAA==.青悦:AwACCAEABRQAAA==.青衫不改:AwAFCAUABAoAAA==.非常无聊:AwABCAEABRQAAA==.非橙勿擾:AwAECAQABRQAAA==.',['�']='风林琳:AwAICAgABAoAAREAAAACCAIABRQ=.风烟:AwACCAQABRQAAA==.风霖霖:AwACCAIABRQAAA==.风骚的蓝霸霸:AwACCAIABRQAAA==.',['�']='饮鸩:AwAICAgABAoAAA==.',['�']='香肩美唇:AwAICBAABAoAAA==.',['�']='鸽子门徒:AwAFCAUABAoAARQAWpYGCAgABRQ=.鸽神:AwAECAQABRQAAA==.',['�']='麻将小王子:AwAICAcABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end