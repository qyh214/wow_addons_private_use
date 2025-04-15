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
 local lookup = {'Unknown-Unknown','Priest-Holy','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Destruction','DeathKnight-Blood','Warrior-Protection','Mage-Fire','Rogue-Assassination','Rogue-Subtlety','Druid-Restoration','Evoker-Augmentation','Evoker-Devastation','Mage-Frost','DemonHunter-Havoc','DeathKnight-Unholy','Paladin-Retribution','Paladin-Protection','Monk-Mistweaver','Warrior-Fury','Warrior-Arms','Priest-Discipline','Druid-Balance','Warlock-Affliction','DemonHunter-Vengeance','Paladin-Holy','Monk-Windwalker',}; local provider = {region='CN',realm='菲拉斯',name='CN',type='weekly',zone=42,date='2025-04-15',data={Co='Coosan:AwAICAkABAoAAA==.',Cr='Crystalydk:AwACCAQABRQAAA==.',Di='Diediediedie:AwAECAYABAoAAQEAAAAECAQABRQ=.',El='Ellen:AwAFCAEABRQAAA==.Elsie:AwACCAUABRQCAgACAQiFFQAXvnYABRQAAgACAQiFFQAXvnYABRQAAA==.',Ga='Gaarai:AwAECAQABAoAAA==.',Hu='Huh:AwAGCAQABRQAAA==.',Ia='Iamzheswarm:AwAHCA0ABAoAAA==.',Mi='Mina:AwACCAUABRQDAwACAQgREQBGzqAABRQAAwACAQgREQBGzqAABRQABAABAQhMQAAvOUAABRQAAA==.',Pi='Pitt:AwAGCAEABAoAAA==.',Sn='Snakegming:AwAECAQABRQAAA==.',Yu='Yukingisme:AwAICAwABAoAAQEAAAAICAMABRQ=.',['�']='一万个熊熊:AwACCAIABRQAAA==.一个人的图腾:AwAICAgABAoAAA==.一个字丶射:AwAHCAgABAoAAA==.一古又:AwADCAMABRQAAA==.一天一天丶:AwAGCAkABRQCBQAEAQhHEgAmNMYABRQABQAEAQhHEgAmNMYABRQAAA==.一醉轻王侯:AwAICBAABAoAAA==.丁丁术:AwAICAgABAoAAA==.七寸钉:AwAGCAMABAoAAA==.万一一:AwACCAIABRQAAQYAJNIGCA0ABRQ=.上帝保佑丶:AwAECAQABRQAAA==.不服我练一个:AwAICBAABAoAAA==.丨刃丨:AwAICAUABAoAAA==.丨牛骑:AwACCAIABAoAAA==.为忘却而战斗:AwAGCAoABAoAAA==.',['�']='乖乖小熊熊:AwAICAIABAoAAA==.',['�']='云德:AwACCAIABRQCBwAIAQibEgArH2kBBAoABwAIAQibEgArH2kBBAoAAA==.云海漫步:AwADCAMABAoAAA==.云深缘浅:AwAGCAYABAoAAA==.',['�']='仴亮起雾了:AwABCAEABRQAAA==.',['�']='伊蕾瑟拉:AwACCAIABAoAAA==.伊谢尔伦红茶:AwAICBAABAoAAA==.会法术的木头:AwAECAYABRQCCAAEAQhpCQBWBiwBBRQACAAEAQhpCQBWBiwBBRQAAA==.',['�']='你在苟叫什么:AwAGCAIABRQAAA==.',['�']='僧丶:AwAECAEABAoAAA==.',['�']='八千流时雨:AwAECAYABRQDCQAEAQjyBABLdg0BBRQACQAEAQjyBABIzw0BBRQACgACAQiXCgA5KqUABRQAAA==.六少:AwAECAYABRQCCwAEAQgdCgAlJcYABRQACwAEAQgdCgAlJcYABRQAAA==.兰提雅西:AwAHCBgABAoDDAAHAQg3BAAdra4ABAoADQAHAQjUMgAP9e4ABAoADAAEAQg3BAAh4a4ABAoAAA==.关灯:AwADCAEABAoAAA==.',['�']='冈巴爹:AwAICAgABAoAAA==.再爱丶还是伤:AwAICAsABAoAAA==.冥月恶魔:AwACCAMABRQDDgAHAQhWIgBGed8BBAoADgAHAQhWIgBGed8BBAoACAABAQg+pAAAAAAABAoAAA==.',['�']='凶狠的德:AwAICA8ABAoAAA==.',['�']='刑天:AwAECAQABRQAAQkATFAGCAYABRQ=.',['�']='加百列丶:AwAICAUABAoAAA==.',['�']='半夏花開:AwABCAEABRQAAA==.卡得家:AwAECAUABRQDCAAEAQimEgBGffQABRQACAAEAQimEgBGffQABRQADgABAQjwFQBD5koABRQAAA==.',['�']='发疯:AwADCAMABAoAAA==.古迩丹之怒:AwAGCAkABAoAAA==.叫我钢躯:AwAHCBAABAoAAA==.可你又甜又软:AwABCAEABRQCDwAIAQhUEQBaiZECBAoADwAIAQhUEQBaiZECBAoAAA==.叼到受不了:AwAFCAoABAoAAA==.',['�']='吉利蛋丶:AwAECAQABRQAAA==.吕布起貂蝉:AwABCAEABRQAAA==.',['�']='呀呀咪:AwAECAQABAoAAA==.',['�']='哈巴奇:AwAFCAUABAoAAA==.',['�']='啊寳:AwACCAIABAoAAA==.',['�']='嗚喵王之怒:AwADCAYABRQCEAADAQiRFAAXBbYABRQAEAADAQiRFAAXBbYABRQAAA==.',['�']='嘎里给给:AwAFCAQABAoAAA==.',['�']='四妹:AwACCAQABRQAAA==.',['�']='均衡教派:AwAECAQABRQAAA==.坤派掌教:AwAECAQABRQAAQQAKokICAIABRQ=.',['�']='埃吉尔:AwABCAEABRQAAA==.埃辛诺斯丶:AwAICAgABAoAAA==.',['�']='堕落长门:AwACCAMABRQAAA==.',['�']='够格:AwAFCAEABAoAAA==.大哥非常快:AwAECAcABAoAAA==.大强乄:AwAHCAgABAoAAA==.天启骑士:AwAECAQABRQAAA==.天才进化版:AwAGCAYABAoAAQUATegICAYABRQ=.天气不似预期:AwAECAQABRQAAA==.太烂的不要:AwAGCAYABRQCBQAGAQiGAABGXv0BBRQABQAGAQiGAABGXv0BBRQAAA==.',['�']='奶娘真可爱丶:AwACCAIABRQAAQYANXYDCAoABRQ=.奶茶加冰:AwAFCAUABAoAAA==.',['�']='如烟:AwAICAgABAoAAA==.妖灬客:AwAICAgABAoAAA==.妙一一:AwACCAIABAoAAA==.',['�']='婷婷守护者:AwACCAIABRQAAA==.',['�']='完全丶搞不懂:AwADCAIABRQDEQAIAQjSRwBLhf8BBAoAEQAIAQjSRwBLhf8BBAoAEgABAQgrWQADfiEABAoAAA==.',['�']='对面辣个鹌鹑:AwAICA4ABAoAAA==.',['�']='小壮:AwAGCAsABAoAAA==.尐爱乄:AwAICAwABAoAAA==.',['�']='山田奈:AwAICAMABAoAAA==.',['�']='岑佩斯:AwAECAQABAoAAA==.岑胖胖:AwAECAQABRQAAQEAAAAGCAQABRQ=.',['�']='希昀:AwAECAUABAoAAA==.',['�']='康奎斯特:AwADCAMABAoAAA==.庸医:AwAICAgABAoAAA==.',['�']='德彪丶:AwAECAQABAoAAA==.德爷丶:AwAFCAYABAoAAA==.',['�']='念夕空:AwAECAQABRQAAA==.',['�']='恐怖得:AwAECAQABRQAAA==.恐怖法:AwAECAQABRQAAA==.',['�']='我叫走走:AwAFCAEABAoAAA==.我把梦丢了:AwAICAwABAoAAA==.',['�']='拂晓自由:AwAICAoABAoAAA==.拜仁:AwAECAQABRQAAQ4AMpgGCAYABRQ=.',['�']='挨批:AwABCAEABRQAAA==.',['�']='掐指算命:AwAECAQABRQAAQkAS3YECAYABRQ=.',['�']='摇摇虎丶:AwAECAQABRQAAA==.',['�']='无双小妲己:AwADCAQABRQAAA==.早已无敌:AwAGCAIABRQCEgACAQiZDQAGEHYABRQAEgACAQiZDQAGEHYABRQAAA==.',['�']='晓风残月:AwAICAgABAoAAA==.景迈山:AwAICAoABAoAAA==.晴歌:AwAECAQABRQAAA==.',['�']='暖暖爱熊猫:AwACCAIABRQCEwAIAQgkGABGDxICBAoAEwAIAQgkGABGDxICBAoAAA==.',['�']='曜空蒂誒哧:AwACCAQABRQAAQ8AEAgECAYABRQ=.曾经的阿超:AwAECAQABRQAAA==.',['�']='木乃伊丶:AwAECAEABAoAAA==.朵多千岁:AwAECAQABRQAAA==.',['�']='杀猫牛:AwACCAIABRQAAA==.',['�']='柒雄:AwABCAEABRQDFAAIAQjoIgBFIvIBBAoAFAAIAQjoIgBDI/IBBAoAFQAGAQg/LQA0kyIBBAoAAQEAAAAGCAIABRQ=.',['�']='桃亚亚:AwAFCAcABRQCFgAFAQjWAwA13DcBBRQAFgAFAQjWAwA13DcBBRQAAA==.',['�']='梅菲萨里奥:AwADCAcABRQCEgADAQjRDAAQXn4ABRQAEgADAQjRDAAQXn4ABRQAAA==.梆球硬:AwABCAEABRQAAA==.梦魇乄:AwAICBAABAoAAA==.',['�']='欧派大星:AwADCAgABRQCFwADAQgnEQAvQOgABRQAFwADAQgnEQAvQOgABRQAAA==.',['�']='气氛组:AwAHCA8ABAoAAA==.',['�']='沐瞳丶:AwAGCAYABAoAAA==.',['�']='法拉第丶:AwAICBIABAoAAA==.',['�']='浪丶:AwAFCAUABAoAAA==.海因克斯:AwACCAIABRQAAA==.海棉体宝宝:AwADCAgABRQDAwADAQhKFAAlyIgABRQABAACAQigKgArFI8ABRQAAwACAQhKFAAfLogABRQAAA==.海鲜老板:AwAECAgABRQCEgAEAQhOBABOdgsBBRQAEgAEAQhOBABOdgsBBRQAAA==.',['�']='清风兰雪:AwAGCAgABRQCCQAGAQhQAQAofaYBBRQACQAGAQhQAQAofaYBBRQAAA==.',['�']='满月安安:AwAGCAkABAoAAA==.满月神裁:AwACCAQABRQCEQAGAQg0QwBeMgwCBAoAEQAGAQg0QwBeMgwCBAoAAA==.满月羞钕:AwAECAIABRQAAA==.满月詠衡:AwACCAEABRQAAQEAAAAGCAIABRQ=.满月飘雪:AwAICAsABAoAAA==.',['�']='灞柳风雪:AwAGCAYABAoAAA==.',['�']='炭烤鸡翅丶:AwAICA8ABAoAAA==.',['�']='烟雨故人归:AwABCAEABRQDAwAIAQhEFwBC6OkBBAoAAwAIAQhEFwBC6OkBBAoABAAEAQgMuwArk5AABAoAAA==.烧釖子:AwACCAIABRQAAA==.',['�']='熊叔玩小德:AwAFCAIABAoAAA==.',['�']='燕窝不怂:AwAICAwABAoAAA==.',['�']='玉米卷卷:AwACCAIABAoAAA==.王德法克:AwAICAgABAoAAA==.王心凌男孩:AwAICAgABAoAAA==.王钢蛋:AwABCAEABRQAAA==.',['�']='番薯大王:AwABCAEABRQAAA==.',['�']='神圣之影:AwAFCAgABAoAAA==.神圣之骑:AwABCAEABRQAAA==.神秘丶人:AwAICBgABAoCBgAIAQiDEQBFawICBAoABgAIAQiDEQBFawICBAoAAA==.',['�']='福至心灵:AwAECAQABRQAAA==.',['�']='秀秀老公:AwACCAIABRQAAA==.秋香:AwAGCAYABAoAAA==.',['�']='索蓝莉安:AwAECAgABRQDGAAEAQgkAgBXpSgBBRQAGAAEAQgkAgBXpSgBBRQABQAEAQhbEQAqVcwABRQAAA==.',['�']='终末之冬:AwAECAQABRQAAA==.绿色生命:AwAHCAcABAoAAA==.',['�']='羲云:AwAGCAYABAoAAA==.',['�']='老叫花:AwABCAIABAoAAA==.老妹羞涩了:AwAECAQABRQAAA==.老子很哇塞:AwAECAQABRQAAA==.',['�']='胸毛在燃烧:AwAICAoABAoAAA==.',['�']='脆爽肌肉人:AwAGCAIABRQCBQACAQjdGwA/TIUABRQABQACAQjdGwA/TIUABRQAAA==.',['�']='自动氵攻击:AwAICAwABAoAAA==.',['�']='艾尔希:AwACCAIABRQAAA==.',['�']='花儿対我笑:AwACCAIABAoAAA==.花落丶水无痕:AwAGCAYABAoAAA==.',['�']='英勇的导演:AwACCAMABRQAAA==.',['�']='莉娅德琳:AwAICBAABAoAAA==.',['�']='菜鸟飞:AwACCAIABRQAAA==.',['�']='蠢蠢欲动:AwADCAQABAoAAA==.',['�']='血花村少:AwAECAQABRQAAA==.',['�']='见龙在耕田:AwAECAQABAoAAA==.',['�']='言射哥:AwACCAIABRQAAA==.',['�']='誰引我入明火:AwABCAEABRQDDwAIAQjCGwBLeEkCBAoADwAIAQjCGwBKGEkCBAoAGQAFAQg2GwBIvoEBBAoAAA==.',['�']='谁引我入明火:AwAECAYABRQCEgAEAQj0BgA3o80ABRQAEgAEAQj0BgA3o80ABRQAAA==.',['�']='贰贰叁肆丶:AwADCAoABRQCBgADAQiECwA1dscABRQABgADAQiECwA1dscABRQAAA==.',['�']='足浴技师:AwAECAQABRQAAA==.',['�']='远神惠赐:AwAICAgABAoAAA==.追寻者:AwACCAIABAoAAA==.',['�']='野丶爷:AwAECAQABAoAAA==.金戈鐵馬:AwACCAIABRQAAA==.',['�']='长空烟雨:AwAECAIABAoAAA==.',['�']='阿荼骑士:AwAGCAYABAoAAA==.',['�']='陈言蹊小朋友:AwAECAEABRQAAA==.',['�']='隔壁:AwAGCAQABRQAAA==.',['�']='雯尐貓:AwAICAYABAoAAA==.雲何:AwAICBYABAoEEQAIAQhScwAyS5UBBAoAEQAIAQhScwAyS5UBBAoAGgAHAQgcGQAwhnkBBAoAEgABAQh8WwARkRwABAoAAA==.',['�']='音乄哲:AwAICAgABAoAAA==.',['�']='顺丰不退货丶:AwAECAUABRQCCQAEAQh8BgBKj/wABRQACQAEAQh8BgBKj/wABRQAAA==.',['�']='風止丶:AwAICBkABAoCDwAIAQjeEwBSj34CBAoADwAIAQjeEwBSj34CBAoAAA==.',['�']='风景圆子:AwAICAsABAoAAA==.飛雪香蓮:AwAGCAcABAoAAA==.',['�']='香辣小奶娘丶:AwAECAQABAoAAQYANXYDCAoABRQ=.',['�']='马上甲鸟:AwAECBAABRQDEwAEAQg/BABfQUgBBRQAEwAEAQg/BABfQUgBBRQAGwADAQi0CQArEOMABRQAAA==.马玲:AwAFCAUABAoAAA==.',['�']='魂兮來歸:AwAHCAIABAoAAA==.',['�']='鸡二夹蛋:AwAFCAkABAoAAA==.',['�']='黑暗虚空:AwAHCAsABAoAAA==.黑骑士丶:AwAECAQABRQAAA==.',['�']='龍頭戲畫:AwAECAIABRQAAA==.龙头四:AwAGCAwABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end