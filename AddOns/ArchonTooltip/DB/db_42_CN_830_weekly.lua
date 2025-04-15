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
 local lookup = {'DeathKnight-Unholy','Shaman-Restoration','Priest-Holy','Druid-Balance','Druid-Restoration','Warrior-Arms','Warrior-Fury','Warrior-Protection','DeathKnight-Blood','Priest-Discipline','Monk-Mistweaver','Hunter-BeastMastery','Warlock-Destruction','DemonHunter-Havoc','Unknown-Unknown','Paladin-Holy','Paladin-Retribution','Mage-Fire','DemonHunter-Vengeance','Shaman-Elemental','Evoker-Devastation','Druid-Guardian','Mage-Frost','Priest-Shadow','Monk-Windwalker','Hunter-Marksmanship','Evoker-Preservation',}; local provider = {region='CN',realm='诺森德',name='CN',type='weekly',zone=42,date='2025-04-15',data={Br='Brush:AwAGCAEABAoAAA==.',Ch='Charlter:AwACCAIABRQCAQAIAQj/DwBTUY4CBAoAAQAIAQj/DwBTUY4CBAoAAA==.',Cr='Crzayhb:AwAHCAkABAoAAA==.',De='Devil:AwAECAQABRQAAA==.',Ja='Janekin:AwADCAcABRQCAgADAQjUFQAKIbQABRQAAgADAQjUFQAKIbQABRQAAA==.',Pl='Playerfakmvb:AwAICAgABAoAAA==.',Po='Poppy:AwACCAUABRQCAwACAQjPDgA5ZaIABRQAAwACAQjPDgA5ZaIABRQAAA==.',Re='Redemption:AwAECAQABRQCBAAEAQi/AwBbwEQBBRQABAAEAQi/AwBbwEQBBRQAAQUAOskICAgABRQ=.Resafe:AwAFCAUABAoAAA==.Rewallis:AwACCAIABRQAAA==.',Si='Sinly:AwAECAEABRQAAA==.',Sk='Sktic:AwAGCAgABAoAAA==.',Sw='Sweettyyxd:AwAICAgABAoAAQYAIZ4GCAoABRQ=.',Sy='Sylviaheng:AwAECAgABRQDBgAEAQgaBAA7+gcBBRQABgAEAQgaBAA7+gcBBRQABwACAQhRIQAYfVMABRQAAA==.',Vo='Voidembrace:AwAICAcABAoAAA==.',We='Wellplayed:AwAICBAABAoAAQUAOkwGCAUABRQ=.',Wi='Willburx:AwAECAYABRQDBwAEAQhQDgAstPMABRQABwAEAQhQDgAstPMABRQACAACAQg9CQAE1VYABRQAAA==.',Yi='Yibanetlos:AwADCAQABAoAAA==.',Zh='Zhai:AwABCAEABRQAAA==.',['�']='一朵五花肉:AwAFCAUABAoAAA==.一朵福狸:AwABCAEABAoAAA==.一梦华胥:AwABCAIABRQAAA==.不会演戏柯南:AwAHCAcABAoAAA==.不可泄漏:AwAECAQABAoAAA==.东岳路:AwAICBsABAoDAQAIAQgIKQA/3+8BBAoAAQAIAQgIKQA/3+8BBAoACQABAQhYYgAQIhgABAoAAA==.丨果果妈丨:AwACCAUABRQCCgACAQhXFQAwDJEABRQACgACAQhXFQAwDJEABRQAAA==.丶惡作劇:AwAHCBgABAoCCwAHAQhlDwBa4V8CBAoACwAHAQhlDwBa4V8CBAoAAA==.丶求别闹:AwAECAQABRQAAA==.丶燎原百斩:AwAECAgABRQCDAAEAQiNFwAtS+UABRQADAAEAQiNFwAtS+UABRQAAA==.',['�']='九公子:AwAGCAEABRQAAQ0AXXIHCAcABRQ=.',['�']='二楼的理财妹:AwACCAQABRQAAA==.二泉映月:AwAICBwABAoCDgAIAQiAGQBMg1cCBAoADgAIAQiAGQBMg1cCBAoAAA==.',['�']='以无德服人:AwAICAIABAoAAA==.',['�']='伊姆帕里斯:AwAECAQABRQAAA==.',['�']='佛山无影擦:AwAFCAwABAoAAA==.佝偻:AwADCAMABAoAAA==.你会玩增强吗:AwAICA0ABAoAAA==.你会玩风怒吗:AwAHCAcABAoAAA==.你家的白菜:AwAFCAgABAoAAA==.',['�']='依然女流氓:AwAICAoABAoAAA==.侠之大者:AwAFCAUABAoAAA==.',['�']='信仰丶尘埃:AwAICAUABRQCBwAEAQiEBABYPTYBBRQABwAEAQiEBABYPTYBBRQAAA==.',['�']='僧敲月下门:AwAICAgABAoAAA==.',['�']='八六下山了:AwAECAQABRQAAQ8AAAAICAEABRQ=.',['�']='冰封夜雪:AwABCAEABRQAAA==.冰封大地:AwAICBAABAoAAA==.冰指丶绕微凉:AwAGCAYABAoAAA==.冰霜哥布林:AwAFCAkABAoAAA==.冲冲丶:AwAICAgABAoAAA==.',['�']='凉拌见手青:AwABCAEABAoAAA==.凯尼血蹄:AwAECAQABAoAAA==.凰月亮:AwABCAMABRQCAwAIAQgnMQAnN1sBBAoAAwAIAQgnMQAnN1sBBAoAAA==.',['�']='初雪微凉:AwAHCAcABAoAAA==.别怕我来了:AwADCAcABRQCAQADAQj5BQBSpx0BBRQAAQADAQj5BQBSpx0BBRQAAA==.',['�']='卖鹌鹑的女孩:AwAECAsABRQCBAAEAQiqCwBHr/8ABRQABAAEAQiqCwBHr/8ABRQAAA==.卤牛肉:AwAHCAEABAoAAA==.',['�']='叁柱子丶:AwAICAgABAoAAA==.',['�']='吃不吃薯角:AwAICAYABAoAAA==.吃点啥呢:AwAGCAQABRQAAA==.吴彦祖传贴膜:AwAHCA4ABAoAAA==.',['�']='呀哈哈:AwAECAQABRQAAA==.',['�']='哥本哈根:AwAECAQABRQAAQ8AAAAGCAMABRQ=.',['�']='堕落王者之剑:AwAECAQABRQAAA==.',['�']='壹月丶:AwAICBAABAoAAA==.',['�']='夏暖:AwAICAgABAoAAA==.大湾区酋长:AwACCAMABAoAAA==.大腿码二腿:AwADCAcABRQDEAADAQh+BwAlxMkABRQAEAADAQh+BwAlxMkABRQAEQABAQg8TAAOnzYABRQAAA==.失憶可樂:AwACCAIABAoAAA==.',['�']='娜美美:AwAICBkABAoDEAAIAQg5GgBAwG4BBAoAEAAHAQg5GgBB1G4BBAoAEQADAQiD6gAtD7MABAoAAA==.',['�']='守护信仰:AwAECAcABRQCBwAEAQifCQA6JAwBBRQABwAEAQifCQA6JAwBBRQAAA==.宠老婆会发财:AwAFCAUABAoAAA==.',['�']='寒烟:AwAECAEABAoAAA==.',['�']='小姜果:AwAGCAgABRQCDgAEAQjlBABbbUABBRQADgAEAQjlBABbbUABBRQAAA==.小小的牛魔:AwAICB8ABAoDAQAIAQguPAA/95kBBAoAAQAHAQguPABCSJkBBAoACQABAQg9WQAyFTcABAoAAA==.小福音:AwAECAQABRQAAQwAN9MGCAkABRQ=.小马先生:AwACCAUABRQCEgACAQi0KwAVYYEABRQAEgACAQi0KwAVYYEABRQAAA==.小黑不白丶:AwAICAIABAoAAA==.尐迪兒:AwAICAgABAoAAA==.少特:AwACCAIABRQAAA==.',['�']='希斯莱洁:AwAECAQABRQAAA==.',['�']='幻月黯然:AwAFCAUABAoAAA==.幽冥蓝焰:AwACCAEABAoAAA==.',['�']='快来吃糖:AwACCAIABRQAAA==.快躲开:AwAICA0ABAoAAA==.',['�']='恶魔鹿:AwACCAMABAoAAA==.',['�']='悪魔猟手:AwABCAIABRQCEwAIAQhGLQAVPvUABAoAEwAIAQhGLQAVPvUABAoAAA==.',['�']='想你就天晴:AwAFCAUABAoAAA==.想入菲菲:AwAECAQABRQAAQ8AAAAICAIABRQ=.',['�']='意大利教父:AwAGCAYABAoAAA==.',['�']='慕羽陌浅浅:AwAECAcABAoAAA==.',['�']='懒觉比像大:AwAGCAEABAoAAA==.',['�']='我爱你呀:AwAECAUABRQCFAAEAQhUCQAnOdMABRQAFAAEAQhUCQAnOdMABRQAAA==.我的坦穿布甲:AwAECAQABRQAAA==.我的小小法:AwABCAEABRQAAA==.我看的见:AwAFCAEABRQAAA==.',['�']='打小就猛:AwAICBcABAoCFAAIAQg0HQA3SeMBBAoAFAAIAQg0HQA3SeMBBAoAAA==.',['�']='抓个癞克包:AwACCAIABRQAAA==.抹茶芒果:AwADCAMABAoAAA==.',['�']='插得紧:AwABCAEABRQAAA==.',['�']='暮雨听蝉:AwACCAYABRQCFQACAQi+EgAou40ABRQAFQACAQi+EgAou40ABRQAAQcALLQECAYABRQ=.暮雨寒煙:AwADCAMABAoAAA==.',['�']='曾經的祸氺:AwAICA4ABAoAAA==.',['�']='李二凤:AwAICA4ABAoAAA==.李二虎:AwAECAQABRQAAA==.杏仁冰淇淋:AwACCAIABRQAAA==.来杯冰可乐嘛:AwACCAIABAoAAA==.',['�']='桑酒:AwAECAoABRQCDgAEAQhFCgBNeQwBBRQADgAEAQhFCgBNeQwBBRQAAA==.',['�']='梦行者:AwACCAQABRQCCwAIAQjQCQBTD5YCBAoACwAIAQjQCQBTD5YCBAoAAA==.',['�']='橙皇喵:AwAICBIABAoAAA==.',['�']='欺光:AwADCAMABAoAAA==.',['�']='武器大师丶:AwAECAQABAoAAA==.',['�']='永罚大剑:AwAICAwABAoAAA==.',['�']='沧浪之水:AwAECAoABRQDCQAEAQhMCgA1aNQABRQACQAEAQhMCgA1aNQABRQAAQAEAQhbEQAiaNIABRQAAA==.',['�']='法拉夏利:AwACCAQABRQAAA==.泡泡鱼:AwAECAQABRQCEQAEAQh9CQBMqyABBRQAEQAEAQh9CQBMqyABBRQAAA==.',['�']='洋西米:AwAICBAABAoAAA==.洛兮:AwACCAQABRQCEQAIAQjUSgA8XPYBBAoAEQAIAQjUSgA8XPYBBAoAAA==.',['�']='深渊漫步者:AwAICA8ABAoAAA==.',['�']='清玥:AwAGCAYABAoAAA==.',['�']='灬小胖胖灬:AwADCAQABAoAAA==.',['�']='無情丶怒刃:AwAICAkABAoAAA==.無畏之盾:AwACCAIABAoAAA==.',['�']='熊牧猫师:AwABCAMABRQAAA==.',['�']='牧清凤:AwADCAsABRQCAgADAQgPBwBIQxABBRQAAgADAQgPBwBIQxABBRQAAA==.',['�']='獨舞丶月影:AwACCAUABRQCFgACAQjkAwAbB10ABRQAFgACAQjkAwAbB10ABRQAAA==.',['�']='王大鸡:AwAECAQABRQAAA==.王小丫:AwAECAQABRQAAQ0AWvkGCAQABRQ=.王小鸭:AwAICAgABAoAAA==.',['�']='珍妮玛水:AwABCAEABAoAAA==.珞珈:AwAGCAQABRQAAA==.',['�']='田馥甄:AwABCAEABRQAAA==.',['�']='白靈:AwACCAIABAoAAA==.',['�']='皓腕凝霜雪:AwACCAUABRQCFwACAQiVDwApmIgABRQAFwACAQiVDwApmIgABRQAAA==.',['�']='看吾眼神行事:AwADCAMABAoAAA==.看我有两个头:AwAECAQABRQAAA==.',['�']='米开朗琪罗丶:AwAECAQABAoAAA==.',['�']='约格莫夫意志:AwACCAIABRQAAA==.',['�']='结城亚丝娜:AwAFCAUABRQCGAAFAQiIBQAXsi8BBRQAGAAFAQiIBQAXsi8BBRQAAA==.',['�']='羊崽崽:AwABCAEABAoAAA==.',['�']='翾翾:AwACCAIABAoAAQ8AAAAICAIABRQ=.翾翾牛肉人:AwAECAQABRQAAA==.',['�']='聆听星的低语:AwAECAcABAoAAA==.聆听月的心事:AwAICBAABAoAAA==.',['�']='肉蛋冲击:AwACCAIABAoAAA==.',['�']='胤曌:AwAICAEABRQAAA==.',['�']='花缘毅:AwAFCBEABRQDCwAFAQhjBQBQ9DEBBRQACwAEAQhjBQBRJjEBBRQAGQABAQjwFwANskoABRQAAA==.',['�']='莱莎蕾尔:AwACCAIABRQAARcAQ5MECAwABRQ=.莽妹:AwAECAQABRQAAA==.',['�']='華灯丶初上:AwACCAUABRQCGgACAQipDgBRjLwABRQAGgACAQipDgBRjLwABRQAAA==.',['�']='萌小宝:AwAFCAUABAoAAA==.萌珑夜雨:AwAECAQABRQAAA==.',['�']='蒙奇璐飞:AwAHCAIABRQAAA==.',['�']='蘭斯洛特:AwAICAgABAoAAA==.',['�']='被遗忘者大梨:AwAECAQABRQAAA==.',['�']='西崽四号:AwADCAMABAoAAA==.西瓜恶魔:AwABCAIABRQCEwABAQgOGAABrx4ABRQAEwABAQgOGAABrx4ABRQAAQ8AAAAECAEABRQ=.西瓜水果:AwAECAEABRQAAA==.',['�']='该名字不可用:AwAHCAsABAoAAA==.',['�']='豚骨拉麺:AwABCAEABRQDBwAIAQgiDQBPgJECBAoABwAIAQgiDQBPgJECBAoABgABAQhkYAApAC0ABAoAAA==.',['�']='迪皮艾斯:AwABCAEABRQAAA==.迷失幻境:AwAECAQABRQAAQUAKncGCAoABRQ=.迷失月夜:AwAGCAgABAoAAA==.迷失月色:AwABCAEABAoAAA==.',['�']='逆风好渢:AwAECAQABRQAAA==.',['�']='醉扶归:AwAFCAEABRQAAQUAPyYICAsABRQ=.',['�']='铁柱哥哥:AwACCAIABRQAAA==.',['�']='长安靓仔:AwAECAQABRQAAA==.',['�']='闲听落花:AwABCAIABRQAAA==.',['�']='隔壁灬瓦达发:AwAHCAcABAoAAQcAMYAICAsABRQ=.',['�']='零丶霖壹:AwAICA0ABAoAAA==.零丶霖拾:AwAECAQABRQAAA==.零丶霖玖:AwAECAgABRQCCgAEAQgHBwBEggoBBRQACgAEAQgHBwBEggoBBRQAAA==.',['�']='霁灭:AwAICAgABAoAAA==.',['�']='青雾风鸣:AwAGCAwABRQDGwAEAQjwAgA9w9cABRQAGwAEAQjwAgA9w9cABRQAFQADAQikEABI8KAABRQAAA==.',['�']='韩宝宝:AwAFCAYABAoAAA==.',['�']='風歌一夜曲:AwAFCAUABAoAAA==.風水輪牛灷:AwABCAIABRQCEQAHAQixkQAlgVEBBAoAEQAHAQixkQAlgVEBBAoAAA==.',['�']='黄色歪头小熊:AwAICA0ABAoAAA==.',['�']='龙井虾仁:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end