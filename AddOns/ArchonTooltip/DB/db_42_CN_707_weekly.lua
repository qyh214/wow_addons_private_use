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
 local lookup = {'Druid-Restoration','Paladin-Retribution','DeathKnight-Blood','Priest-Shadow','Mage-Fire','Priest-Holy','Priest-Discipline','Unknown-Unknown','Warlock-Demonology','Shaman-Restoration','Warlock-Destruction','DeathKnight-Frost','Evoker-Preservation','DeathKnight-Unholy','Shaman-Elemental','Monk-Windwalker','Hunter-Marksmanship','Shaman-Enhancement','Rogue-Subtlety','Warlock-Affliction','Hunter-BeastMastery','Hunter-Survival','Paladin-Protection','Warrior-Protection','Warrior-Fury','Warrior-Arms','Paladin-Holy','Monk-Mistweaver','Druid-Balance','Rogue-Assassination','DemonHunter-Havoc','DemonHunter-Vengeance','Monk-Brewmaster','Warlock-Ranged','Evoker-Devastation',}; local provider = {region='CN',realm='月光林地',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ab='Absolone:AwAHCAMABAoAAA==.',Ar='Artoderias:AwAECAQABAoAAA==.',Ch='Chensha:AwACCAMABRQAAA==.',Co='Cocopriest:AwAICAgABAoAAA==.',Dk='Dkhalo:AwAECAQABRQAAA==.',El='Electricee:AwAGCAkABAoAAA==.Elleshar:AwAECAEABRQAAA==.',Fa='Fatefake:AwACCAIABRQAAA==.',Fi='Fita:AwACCAEABRQCAQAIAQgMBwBUKJMCBAoAAQAIAQgMBwBUKJMCBAoAAA==.',Fo='Formercy:AwAHCAgABAoAAA==.',Go='Gokoururi:AwAGCAsABAoAAQIAU8UICBcABAo=.',Hy='Hyxj:AwACCAIABAoAAA==.',In='Infinityk:AwADCAMABAoAAA==.',Iq='Iqdk:AwAECAwABRQCAwAEAQi0AgBct0QBBRQAAwAEAQi0AgBct0QBBRQAAQQANEsICAgABRQ=.',Ka='Kahiwii:AwAECAQABRQAAA==.Karlz:AwAECAYABRQCBQAEAQhSEwA6sOsABRQABQAEAQhSEwA6sOsABRQAAA==.',Ko='Kodomo:AwAHCAkABAoAAA==.Koeus:AwACCAIABRQCAgAIAQjJCwBfUt0CBAoAAgAIAQjJCwBfUt0CBAoAAA==.Konstantin:AwAECAQABAoAAA==.',Le='Leonevoker:AwAECAQABRQAAA==.',Lu='Lumiere:AwABCAEABRQDBgAIAQjCLAAqzGoBBAoABgAIAQjCLAAp12oBBAoABwACAQhybwAwJlEABAoAAA==.',Ly='Lynne:AwAICAgABAoAAA==.',Mi='Minazuki:AwAICAoABAoAAA==.Mirabelle:AwAICAoABAoAAA==.',Pl='Playerixhrkp:AwAECAIABAoAAA==.',So='Southqian:AwACCAIABRQAAA==.',Su='Sususu:AwAHCAcABAoAAA==.',Ta='Taka:AwACCAIABRQCAgAIAQi7IABTDH0CBAoAAgAIAQi7IABTDH0CBAoAAA==.',Vi='Victoriawang:AwAECAQABAoAAA==.',Xk='Xkjm:AwAGCAsABAoAAQgAAAAHCBAABAo=.',['�']='一新一意:AwAHCA0ABAoAAA==.一曲月倾城:AwAECAQABRQAAA==.一颗柑橘:AwAGCAUABRQCBgAFAQjEBwAEl90ABRQABgAFAQjEBwAEl90ABRQAAA==.万兽无疆:AwAGCAYABAoAAA==.三味书屋:AwACCAUABRQCCQACAQgdBABKUbIABRQACQACAQgdBABKUbIABRQAAA==.三国志:AwADCAMABAoAAA==.三水之潮:AwAECAQABRQAAA==.上德若谷丶:AwADCAcABRQCCgADAQjxEQAPS8AABRQACgADAQjxEQAPS8AABRQAAA==.不乖的乖乖:AwABCAEABAoAAA==.不吃内脏:AwAGCAYABAoAAA==.不行就分:AwAFCAUABAoAAA==.东方筱则:AwAFCAgABAoAAA==.两眼一抹黑:AwAECAIABRQAAQgAAAAGCAQABRQ=.丨荆轲刺秦王:AwAICBAABAoAAA==.个人哎好:AwAECAYABAoAAA==.中年散修:AwAHCAoABAoAAA==.丶武小僧:AwAECAEABRQAAA==.丶沐沐曦:AwAICAIABAoAAA==.丶阿阿给我闹:AwAFCAcABAoAAA==.为此春酒:AwAICBwABAoCBAAIAQiQGgA46uABBAoABAAIAQiQGgA46uABBAoAAA==.',['�']='久久:AwAECAQABRQAAQgAAAAICAIABRQ=.久远飞鸟:AwACCAIABRQCCwAIAQi6CQBXfpICBAoACwAIAQi6CQBXfpICBAoAAA==.义父:AwACCAQABAoAAA==.九紫离火:AwAICAYABAoAAA==.',['�']='亡月之光:AwACCAIABRQCDAAIAQghCQA/aPMBBAoADAAIAQghCQA/aPMBBAoAAA==.交叉电磁炮:AwACCAIABAoAAA==.京城小白龙:AwAICA8ABAoAAA==.人无在少年:AwAECAQABRQAAA==.',['�']='仁无幻:AwACCAIABAoAAA==.以敖以游:AwAHCBIABAoAAA==.',['�']='会飞的锤子:AwAGCAcABAoAAA==.',['�']='你们闪我来抗:AwAECAQABRQAAA==.你再叫我报警:AwAFCAEABAoAAA==.你在狗叫什么:AwACCAIABAoAAA==.你笑了:AwAGCAYABAoAAQgAAAAICAMABRQ=.',['�']='倒影:AwAECAcABRQDBwAEAQiJBwBNTfsABRQABwAEAQiJBwBNTfsABRQABAACAQi9GgA291EABRQAAA==.倚窗听落雨:AwAECAQABRQAAQQAO50GCA4ABRQ=.',['�']='元柳斋重国:AwAECAQABRQAAA==.光明指引你:AwAFCAgABRQCAgAFAQiGAgA6u1gBBRQAAgAFAQiGAgA6u1gBBRQAAA==.克洛塔之陨:AwAGCA8ABAoAAQgAAAAGCBIABAo=.全都是幻觉:AwAICBEABAoAAA==.八爪小鱼:AwAECAQABRQAAA==.公会大表哥:AwAFCAUABAoAAA==.兰斯桑克斯:AwAECA0ABRQCDQAEAQiqAQBMBP0ABRQADQAEAQiqAQBMBP0ABRQAAA==.其疾如风丶:AwAFCAUABAoAAA==.',['�']='冬至:AwAECAYABRQDAwAEAQjsBwBCXeMABRQAAwAEAQjsBwBCXeMABRQADgACAQhcHQAP5mMABRQAAA==.冰琉璃:AwACCAIABAoAAA==.冷傲影:AwADCAMABAoAAA==.',['�']='凌峰拂云:AwAICAMABAoAAA==.凌楚楚:AwAECAQABRQAAA==.凹凸法:AwAGCAIABRQAAA==.',['�']='利爪与爱抚:AwADCAMABRQAAA==.别忘达不溜叉:AwACCAIABRQCDQAIAQgRBwA7HwICBAoADQAIAQgRBwA7HwICBAoAAA==.',['�']='医保打欠费:AwAECAQABRQAAA==.',['�']='十年一品:AwAGCAYABAoAAA==.千与千寻的梦:AwAICAYABAoAAA==.半仙:AwAHCA8ABAoAAA==.卢博士:AwAECAQABRQAAA==.卧推一百八:AwAECAUABAoAAA==.',['�']='原来还在这里:AwAHCAcABAoAAA==.',['�']='又棉秋雨:AwAECAEABAoAAA==.发光的猫须:AwAFCAoABAoAAA==.叨叨:AwAECAQABRQCDwAIAQisFABEoCACBAoADwAIAQisFABEoCACBAoAAQ8AXG4ICAgABRQ=.可天:AwAICAgABAoAAQgAAAAECAQABRQ=.',['�']='吃典韦哥再上:AwABCAEABRQCEAAIAQhfJAArLJEBBAoAEAAIAQhfJAArLJEBBAoAAA==.吃糖糖:AwACCAIABAoAAA==.各牛牛:AwAECAYABAoAAA==.君陌是也:AwACCAIABRQAAA==.听科比打球:AwAECAcABAoAAA==.',['�']='咆哮的小福:AwACCAMABRQCCgAIAQgqEwBP20cCBAoACgAIAQgqEwBP20cCBAoAAA==.',['�']='哪里来的圣光:AwAICA0ABAoAAA==.',['�']='唯一米兰:AwAECBAABRQCCgAEAQhiAgBcPz4BBRQACgAEAQhiAgBcPz4BBRQAAA==.',['�']='喜哩滑啦:AwAECAQABRQAAREAVdsICAgABRQ=.',['�']='因幡月夜:AwAICBgABAoCBQAIAQhnDgBUdpcCBAoABQAIAQhnDgBUdpcCBAoAAA==.',['�']='圣光不死鸟:AwAGCAIABRQAAA==.圣光之镰:AwAHCBQABAoCAgAHAQjbnwAXoSUBBAoAAgAHAQjbnwAXoSUBBAoAAA==.圣光啊啊:AwAHCBsABAoCAgAHAQiDSgBLkO4BBAoAAgAHAQiDSgBLkO4BBAoAAA==.圣光小宝:AwAGCAYABAoAAA==.圣祭司:AwADCAUABRQCEgADAQijCQAX/98ABRQAEgADAQijCQAX/98ABRQAAA==.在下螃蟹王:AwACCAIABAoAAA==.地獄之焰:AwAECAgABRQCAwAEAQhxBABVUSIBBRQAAwAEAQhxBABVUSIBBRQAAA==.',['�']='埃塔塻斯:AwAGCAQABRQCEwAEAQjwBwAakeMABRQAEwAEAQjwBwAakeMABRQAAA==.埋葬:AwAHCAEABAoAAQgAAAAICAQABRQ=.',['�']='塞丽勒芙:AwAECAcABAoAAA==.塞尔赫不答应:AwAECAQABRQAAA==.',['�']='夏日的柠檬茶:AwAECAgABRQECQAEAQiYBAA9I6oABRQACwAEAQgJEAAgbMkABRQACQADAQiYBABMx6oABRQAFAABAQg7GAAd2kcABRQAAA==.夕颜若雪:AwAICAgABAoAAA==.夜不能寐嗎:AwAGCAYABAoAAA==.夜雨随星曜:AwAECAQABRQAAA==.大力水手帝凯:AwABCAEABRQAAA==.大力水手欧凯:AwAICAcABAoAAA==.大妖精:AwAGCAQABRQAAA==.大脸喵:AwADCAMABRQAAREAVdsICAgABRQ=.天啊:AwADCAMABRQAARUAShkGCA4ABRQ=.天梁:AwAECAYABAoAAA==.央月华:AwADCAMABRQAAA==.夸幻之父:AwAFCAUABAoAAA==.',['�']='女皇之刃:AwAICA4ABAoAAQMAUMoICAcABRQ=.',['�']='如果只是如果:AwAECAQABRQAAA==.如果命运是风:AwAHCAYABAoAAA==.妃咲:AwACCAIABAoAAQgAAAAGCAIABRQ=.妖狐小九:AwAECAQABRQAAA==.妮妮是妮妮:AwACCAMABRQDFQAIAQi/SwA7UqQBBAoAFQAIAQi/SwA04qQBBAoAFgADAQiXDQA4JusABAoAAA==.',['�']='学而不思则罔:AwAECAYABAoAAA==.',['�']='安德尔斯:AwACCAMABRQCFwAIAQi3EQA63scBBAoAFwAIAQi3EQA63scBBAoAAA==.',['�']='小七:AwAGCAgABAoAAQgAAAAHCAkABAo=.小丑丿:AwAECAQABRQAARgALyoICAoABRQ=.小居:AwAHCAcABAoAAA==.小母牛饲养员:AwACCAIABRQAAA==.小毒头丶飞飞:AwACCAIABRQAAQgAAAAGCAQABRQ=.小牛外卖员:AwACCAIABRQAAA==.小瓜德:AwACCAIABRQAAA==.小白芨:AwAICBwABAoDBgAIAQiGEQBK7yMCBAoABgAIAQiGEQBK7yMCBAoABwAGAQgBKQA/smEBBAoAAA==.小药儿:AwAFCA0ABAoAAA==.少女的小表弟:AwAECAgABRQCAgAEAQifBABXijkBBRQAAgAEAQifBABXijkBBRQAAA==.尤柯:AwAGCAQABRQCEQAEAQjcBwBDN+cABRQAEQAEAQjcBwBDN+cABRQAAQgAAAAICAIABRQ=.尼古拉斯蔡明:AwADCAMABRQAAA==.',['�']='川粉:AwAICAgABAoAAA==.左壮壮:AwACCAIABAoAAA==.左大壮:AwAFCAUABAoAAA==.巧克力脆香塔:AwAECAQABAoAAA==.',['�']='希望你开心:AwADCAgABRQDGQADAQiZBwBWnBMBBRQAGQADAQiZBwBPQRMBBRQAGgACAAgAAABgqQAABRQAAA==.',['�']='干亼皃:AwACCAMABRQDEQAIAQgKLgA4HjoBBAoAFQAHAQhPYQAzs1wBBAoAEQAFAQgKLgAu5ToBBAoAAA==.平明寻白羽:AwADCAUABRQCCgADAQhiCgA22u4ABRQACgADAQhiCgA22u4ABRQAAA==.',['�']='康师傅绿茶:AwAHCA0ABAoAAA==.',['�']='张国立:AwAECAMABRQDGQAIAQhQLgAzh6sBBAoAGQAHAQhQLgA4easBBAoAGAABAQgcPAAV3SMABAoAAA==.',['�']='德洛丽斯:AwABCAEABRQAAA==.德鲁丨依依:AwABCAEABAoAAA==.',['�']='心机之蛙:AwADCAMABAoAAA==.快扶我起来:AwAECAQABRQAAA==.',['�']='怒三娘:AwADCAMABAoAAA==.',['�']='恋爱丿嘉年华:AwAGCAoABRQCAwAGAQicBwAKl+kABRQAAwAGAQicBwAKl+kABRQAAA==.恶魔降临辣:AwAGCAYABAoAAA==.',['�']='惊呆的小伙伴:AwAGCAwABAoAAA==.',['�']='愛相誼:AwAECAcABRQEFwAEAQgZCABCTa0ABRQAFwADAQgZCABLKa0ABRQAGwADAQj0CQA6C5gABRQAAgABAQi8NwA3sFQABRQAAA==.',['�']='憨憨杰尼龟:AwADCAMABAoAAA==.',['�']='我去打麻将了:AwAECAQABRQAAA==.我心飛翔:AwACCAIABRQAAA==.我是变态:AwACCAIABAoAAA==.',['�']='抹茶灬小饼干:AwADCAgABRQCDQADAQhgAwAu+MUABRQADQADAQhgAwAu+MUABRQAAA==.',['�']='拨楞你行不:AwACCAEABAoAAA==.',['�']='摩丶尔:AwAGCAYABAoAAA==.',['�']='撕脱怂勋爵:AwACCAIABRQAAA==.',['�']='斯里兰卡:AwAICAMABAoAAA==.新手划水:AwAFCAUABAoAAA==.',['�']='旋风腿韵德:AwAECAIABRQCHAACAQhxEwA5W64ABRQAHAACAQhxEwA5W64ABRQAAA==.无尽寒霜:AwAICAgABAoAAA==.无情的小刀郎:AwAGCAgABAoAAA==.无敌小雪怪丶:AwAICAgABAoAAA==.无敌矮子猎:AwABCAEABRQAAA==.',['�']='明夜:AwAICAIABAoAAA==.明月照黄河:AwAICAgABAoAAA==.是染不是柒:AwAGCA4ABAoAAA==.',['�']='晖鈅:AwAGCAoABAoAAA==.晚饭吃苹果:AwAFCA8ABAoAAA==.',['�']='暗影圣光:AwAFCAYABAoAAA==.暮光城女:AwAFCAUABAoAAA==.暮雨尘封:AwAICAgABAoAAQgAAAAICAQABRQ=.暴风血:AwACCAIABAoAAA==.',['�']='最后的劣人:AwAICA0ABAoAAA==.月丫唲:AwACCAIABRQCAgAIAQhULABOHE8CBAoAAgAIAQhULABOHE8CBAoAAA==.月夜踏雪:AwAECAQABAoAAA==.月影标枪:AwAGCAUABAoAAA==.月酌:AwAICBUABAoDHQAIAQhJBgBadeACBAoAHQAIAQhJBgBadeACBAoAAQAIAQjUFwA9adwBBAoAAA==.',['�']='杜隆奶:AwAGCBcABAoCAQAGAQihQAAmr+MABAoAAQAGAQihQAAmr+MABAoAAA==.杯酒斩红尘:AwAHCAcABAoAAA==.',['�']='林风眠:AwAECAEABRQAAA==.枫小鱼:AwAICAgABAoAAA==.',['�']='梁山大王:AwACCAEABRQDEwAIAQheCwBOay4CBAoAEwAIAQheCwBCuy4CBAoAHgAEAQgwGgBPwHcBBAoAAA==.梦中的思念:AwAICAgABAoAAA==.',['�']='橙戒骑:AwAGCBIABAoAAA==.',['�']='武雄之狮:AwACCAMABRQCAgAIAQjwHgBVmoUCBAoAAgAIAQjwHgBVmoUCBAoAAA==.',['�']='水寒间离:AwAICBAABAoAAA==.永世神选:AwAGCAYABAoAAA==.',['�']='江门落雪:AwAGCAYABRQCAwAEAQhcBgBIU/4ABRQAAwAEAQhcBgBIU/4ABRQAAA==.',['�']='没尾巴:AwADCAMABRQAAA==.',['�']='法号净空:AwAHCAcABAoAARgALyoICAoABRQ=.泰岚德丶疯语:AwAGCAoABAoAAA==.泰温兰尼斯特:AwADCAMABRQAAA==.',['�']='洛曦:AwADCAMABAoAAA==.活的虽认真:AwAHCAcABAoAAA==.',['�']='浅暮流觞:AwAHCAYABAoAAA==.',['�']='淡紫色:AwACCAMABRQAAR0AJL8GCBIABRQ=.混世生:AwAECAQABAoAAA==.',['�']='湖畔镇的初夏:AwADCAMABAoAAA==.',['�']='溪鹭月:AwAECAMABRQAAA==.',['�']='潋阙:AwAGCAsABAoAAA==.',['�']='火月冰阳:AwAECAQABRQAAA==.火舞天:AwAICAgABAoAAA==.',['�']='焰柳树丛:AwAECAQABAoAAA==.',['�']='照君临:AwAFCAQABAoAAA==.',['�']='燃烧的胖克斯:AwAGCAYABRQCGQAGAQhKAAA+ftkBBRQAGQAGAQhKAAA+ftkBBRQAAA==.',['�']='牧远巨石:AwACCAIABRQAAA==.',['�']='猎手小多:AwAICAgABAoAAA==.猫大爷:AwAECAQABRQAAA==.猫巷拾青柠:AwAFCAUABAoAAA==.',['�']='王大咖:AwAECAQABRQAAA==.玛里奥丶怒风:AwAECAQABAoAAA==.',['�']='瑱圭:AwAFCAwABAoAAA==.',['�']='甜崽:AwAGCAIABRQAAA==.电池兔:AwAHCBYABAoDEQAHAQjsHgA4fqABBAoAEQAHAQjsHgA4fqABBAoAFQABAQg54QAe+j8ABAoAAA==.',['�']='留星闪呀闪:AwABCAEABAoAAA==.',['�']='疋杀地藏:AwAECAQABAoAAA==.疏香:AwACCAIABRQDGgAIAQisEQA5rgcCBAoAGgAIAQisEQA5rgcCBAoAGAACAQjcMgASpVIABAoAAA==.疯狂的狐狸哥:AwAICAMABAoAAA==.',['�']='痛丶风:AwABCAEABRQAAA==.痴断肠:AwACCAIABAoAAA==.',['�']='破伤风:AwACCAIABRQAAA==.',['�']='硬郞:AwADCAkABRQCHwADAQhnFQAd+tIABRQAHwADAQhnFQAd+tIABRQAAA==.',['�']='神佑哇:AwAGCAYABRQCBAAGAQiGAABKuPIBBRQABAAGAQiGAABKuPIBBRQAAA==.神佑索索:AwAICAgABAoAAA==.神力恩泽:AwAHCAcABAoAAQgAAAAHCBAABAo=.神秘萨满:AwAICAQABAoAAA==.神笔丶:AwACCAUABRQCDwACAQjkCQBOqLsABRQADwACAQjkCQBOqLsABRQAAA==.祤然:AwAECAUABRQCAwAEAQhVEwALwn4ABRQAAwAEAQhVEwALwn4ABRQAAA==.祭司之树:AwADCAIABRQAAA==.',['�']='秭归啼:AwAGCAYABAoAAA==.',['�']='童妻:AwACCAEABRQAAA==.',['�']='米兰之光:AwAICA4ABAoAAA==.米色邦尼兔:AwAECAQABRQAAA==.',['�']='糖糖爱学习:AwADCAcABRQCFAADAQhkBwAoROIABRQAFAADAQhkBwAoROIABRQAAA==.',['�']='素色风盏:AwAECAQABAoAAA==.紫焰螺旋:AwAHCB0ABAoCIAAHAQhQKQAgQQQBBAoAIAAHAQhQKQAgQQQBBAoAAA==.紫雨心衣丶:AwAECAQABRQAAA==.',['�']='綉春刀:AwACCAIABAoAAA==.',['�']='纠结小德:AwAGCAYABAoAAR0ARTUHCAcABRQ=.',['�']='绫枫:AwAECAQABRQAAA==.维雅媞斯:AwAGCAYABAoAAA==.',['�']='缘来是妮:AwAHCA4ABAoAAA==.',['�']='罪恶之花张三:AwADCAQABAoAAA==.',['�']='美式咖啡:AwAICAgABAoAAA==.羽川翼:AwAICBEABAoAAA==.',['�']='翟心如月:AwAGCAYABAoAAA==.翠花来找淑芬:AwACCAIABAoAAA==.翻滚的柴犬:AwACCAIABRQCIQAIAQhwCwAr5m0BBAoAIQAIAQhwCwAr5m0BBAoAARkAM4cECAMABRQ=.',['�']='老坛山菜:AwAGCAgABAoAAA==.老头丶:AwABCAEABAoAAA==.老游戏:AwABCAEABAoAAA==.',['�']='聖光在胸:AwADCAMABAoAAA==.聖光騎仕:AwAHCAcABAoAAA==.',['�']='肥太狼熊德:AwAFCAUABAoAAA==.肥太狼玛猎:AwAECAUABRQCFQAEAQhSEgBC6fAABRQAFQAEAQhSEgBC6fAABRQAAA==.肥菜一号粉丝:AwADCAgABRQDHQADAQghGQBVnqQABRQAHQADAQghGQBVnqQABRQAAQABAQg4FwAipEwABRQAAA==.',['�']='自牧帰荑:AwAICAgABAoAAA==.臭桃:AwAFCAMABAoAAQgAAAAHCAkABAo=.',['�']='舞娘希里斯:AwAICAEABAoAAA==.',['�']='芒果百事:AwADCAwABRQCBgADAQihBQA46fIABRQABgADAQihBQA46fIABRQAAA==.芝士酸奶修狗:AwAICAsABAoAAA==.',['�']='萍山练峨眉:AwAICBgABAoCEAAIAQjKIAAzGa4BBAoAEAAIAQjKIAAzGa4BBAoAAA==.萨如满:AwAFCAgABAoAAA==.萨满快开嗜血:AwACCAMABRQAAA==.萨瓦图恩:AwAGCBIABAoAAA==.',['�']='葛革:AwACCAIABRQAAA==.',['�']='蒂娜公主:AwACCAIABAoAAA==.蒙丶奇奇:AwAECAYABAoAAA==.',['�']='蕾賽:AwAICAYABAoAAQgAAAAICAEABRQ=.',['�']='薄荷生巧:AwAECAgABRQCEQAEAQhyBQBQg/0ABRQAEQAEAQhyBQBQg/0ABRQAAA==.',['�']='藏原走:AwAHCAcABAoAAA==.',['�']='虎癡:AwADCAMABAoAAA==.',['�']='西索莫罗:AwADCAMABAoAAA==.',['�']='诡术妖僧:AwAHCBMABAoAAA==.诸界漫步者:AwACCAIABAoAAA==.',['�']='豆乳玉麒麟:AwABCAIABRQCHQAIAQi2DABY+asCBAoAHQAIAQi2DABY+asCBAoAAA==.',['�']='贰叁肆伍壹:AwAECAQABAoAAA==.贵样尊者:AwADCAQABRQDCQAIAQjZCABCISYCBAoACQAIAQjZCABBGSYCBAoACwACAQgfdwBFTIYABAoAAA==.',['�']='赤道与北極:AwAFCAYABAoAAA==.',['�']='超雄野狼:AwAICAcABAoAAA==.超震声波:AwAHCBAABAoAAA==.',['�']='跳跳回锅肉:AwAHCB0ABAoDIAAHAQiyJAAn2SQBBAoAIAAHAQiyJAAn2SQBBAoAHwACAQgbpwALKzgABAoAAA==.',['�']='达叔的回归:AwAHCAcABAoAAA==.',['�']='鄙人会法术:AwAGCAYABAoAAA==.',['�']='醉酒戏红颜:AwAGCA4ABAoAAA==.醉酒棕熊:AwAECAgABRQCBQAEAQgDEgA87e8ABRQABQAEAQgDEgA87e8ABRQAAA==.',['�']='鐵甲安在:AwAICAgABAoAARoAOrkDCAMABRQ=.',['�']='钓鱼老:AwAGCAYABAoAAA==.钱立仙:AwADCAkABRQCEQADAQhJCAAzH+QABRQAEQADAQhJCAAzH+QABRQAAA==.',['�']='银色玄雷:AwAECAQABAoAAA==.',['�']='阿拉贡:AwAFCAUABAoAAR0AVtkGCAcABRQ=.阿洁塔:AwAGCAYABAoAAA==.阿瓦隆之怒:AwAHCAkABAoAAA==.阿西達卡:AwAECAQABRQAAA==.',['�']='雪玉辞心:AwAHCAYABAoAAA==.雾隠酌莲华:AwACCAMABRQDHAAIAQibKgAueowBBAoAHAAIAQibKgAueowBBAoAEAAIAQjuKwAawVkBBAoAAA==.',['�']='霜之大地:AwAECAUABRQCCgAEAQhhAgBcKz4BBRQACgAEAQhhAgBcKz4BBRQAAA==.霜凝火舞:AwAECAQABRQAAA==.',['�']='青峰总攻:AwACCAMABRQCBgAIAQhqGABBM+oBBAoABgAIAQhqGABBM+oBBAoAAA==.',['�']='风姿一众星:AwAECAQABRQAAA==.飒蕾雅:AwACCAIABAoAAA==.',['�']='鱼叉机关炮:AwAICAgABAoAAA==.鱼池胭脂:AwAFCAUABAoAAA==.',['�']='黄后我最大:AwACCAIABRQAAA==.黑人巨大:AwAECAYABRQDBAAEAQisCwAvhOIABRQABAAEAQisCwAvhOIABRQABgACAQh3EwAWXHgABRQAAA==.黑松白鹿:AwAICA8ABAoAAA==.黑皮白虾:AwACCAQABRQDBgAIAQigCQBXznQCBAoABgAIAQigCQBXznQCBAoABAADAQhiTAAoSpEABAoAAA==.黑皮肌肉菀菀:AwAGCAEABRQCIgABAAgAAAAFlwAABRQACwABAAgAAAAFlwAABRQAAA==.默示录丶:AwACCAMABRQCDgAIAQgzJgBCp/MBBAoADgAIAQgzJgBCp/MBBAoAAA==.',['�']='齐桓公:AwADCAIABAoAAA==.',['�']='龍丼:AwACCAIABRQAARIAM3YICAkABRQ=.龙民工:AwAICBMABAoAAA==.龙神净空:AwAHCBYABAoDIwAHAQj5EgBRaAQCBAoAIwAHAQj5EgBRaAQCBAoADQACAQgJHABAC4QABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end