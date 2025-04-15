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
 local lookup = {'Mage-Fire','DeathKnight-Blood','Mage-Frost','Druid-Restoration','Druid-Feral','Druid-Balance','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Paladin-Protection','Evoker-Devastation','Shaman-Any','Shaman-Restoration','Unknown-Unknown','Paladin-Holy','Monk-Mistweaver','Shaman-Elemental','Warlock-Destruction','Rogue-Assassination','Priest-Discipline','Priest-Shadow','Priest-Holy','Shaman-Enhancement','Warlock-Affliction','Monk-Windwalker','Monk-Brewmaster','DemonHunter-Vengeance','Rogue-Subtlety',}; local provider = {region='CN',realm='蜘蛛王国',name='CN',type='weekly',zone=42,date='2025-04-15',data={Bo='Bombly:AwAECAQABRQAAA==.',Di='Dililil:AwACCAIABAoAAA==.',Dr='Drablo:AwAECAQABRQAAA==.',Et='Ethan:AwAFCAkABAoAAA==.',Fl='Flareup:AwAGCA4ABRQCAQAGAQh9AABjFUkCBRQAAQAGAQh9AABjFUkCBRQAAQEATAYICA0ABRQ=.Flechazo:AwADCBEABRQCAgADAQiSEAAhB6IABRQAAgADAQiSEAAhB6IABRQAAA==.',Ha='Hannibalx:AwAGCAQABRQAAA==.',Ic='Icelol:AwAECAQABRQAAA==.',Ja='Jabbawockeez:AwAECAQABRQAAA==.Jayaz:AwACCAUABRQCAwACAQjlDQBCFZMABRQAAwACAQjlDQBCFZMABRQAAA==.',Jo='Johanna:AwAICAgABAoAAA==.Johnnyr:AwABCAIABRQAAA==.',Ju='Justfs:AwAHCAcABAoAAA==.Justmcser:AwAICBAABAoAAA==.',Lr='Lrishmist:AwAICBAABAoAAQQAOkwGCAUABRQ=.',Lu='Luciferzz:AwABCAEABAoAAA==.Luckyfox:AwACCAQABRQEBQAIAQirDgAxMJUBBAoABQAHAQirDgAyXpUBBAoABAAIAQhFMgAcxDIBBAoABgACAQg0ugAFGR0ABAoAAA==.',Ma='Manbb:AwAICAgABAoAAA==.',Pa='Papercut:AwAECAQABRQAAA==.',Sc='Schweppes:AwAECAQABRQAAA==.',Sm='Sms:AwACCAIABAoAAA==.',So='Solaya:AwAICAYABAoAAA==.',Ta='Tail:AwAICA8ABAoAAA==.',Va='Vampiretiger:AwADCAMABRQAAA==.',Zz='Zzn:AwACCAMABRQAAA==.',['�']='一念生杀:AwAECAQABRQAAA==.万枫:AwAICBAABAoAAA==.三角初华:AwAECAQABRQDBwAIAQh7JgBLDf0BBAoABwAIAQh7JgBAoP0BBAoAAgAFAQhTHABH2YkBBAoAAA==.三队防战:AwAICAgABAoAAA==.丝潘迪娜:AwAGCAYABAoAAA==.丨丶亲尕嘴:AwAECAQABRQAAA==.丨冷寒丨:AwAICBAABAoAAA==.丨晨海鱼歌丨:AwACCAIABRQAAA==.丶燃焼囘憶丶:AwAECAQABRQCCAAIAQgZLQBN9SkCBAoACAAIAQgZLQBN9SkCBAoAAQkAQc0GCAYABRQ=.丿大沢佑香:AwADCAMABRQAAA==.',['�']='乀天:AwAECAQABAoAAA==.',['�']='亚谢里德:AwAGCAMABRQCAgADAQj6DQApFbMABRQAAgADAQj6DQApFbMABRQAAA==.',['�']='仆人:AwABCAIABRQAAA==.',['�']='伊莎:AwABCAEABRQAAA==.伊莎佩拉:AwABCAEABRQAAA==.',['�']='你羸得了:AwAICAgABAoAAA==.',['�']='催裤拉嗅:AwAECAQABAoAAA==.傲世狂龙:AwAGCAQABRQAAA==.',['�']='养鱼哥:AwAICAEABAoAAA==.',['�']='再见黑贞德:AwADCAQABAoAAA==.冰若依:AwAICAQABAoAAA==.冲钅小肚子:AwAECAQABAoAAA==.',['�']='刃舞圣光:AwAECAUABAoAAA==.别让我追到你:AwAGCAQABRQAAA==.',['�']='力之斩铁:AwAGCAYABAoAAA==.',['�']='博博苏:AwABCAEABRQAAA==.卡雷莉斯冰歌:AwAICAgABAoAAQcAQ3QGCA0ABRQ=.',['�']='发粪涂墙:AwACCAIABRQAAA==.古蕾娅:AwAECAQABRQAAA==.只手之声:AwACCAIABRQAAA==.可爱丸子:AwAICAgABAoAAA==.',['�']='吴越戏春秋:AwAECAQABAoAAA==.吸澄器:AwAECAQABRQAAA==.',['�']='咕咕灬:AwACCAIABRQDBQAHAQgDCwBDWOoBBAoABQAHAQgDCwBDWOoBBAoABgAGAQhoZQAot/kABAoAAA==.',['�']='啪了个啪:AwABCAEABRQAAA==.',['�']='圣光万丈:AwAECAQABRQAAA==.圣光下的幻想:AwACCAQABRQDCgAIAQh/TgA8UuwBBAoACgAIAQh/TgA8UuwBBAoACwABAQhlYgAHewkABAoAAA==.圣可可:AwADCAIABAoAAA==.圣龙战神:AwAICAgABAoAAA==.',['�']='夜太美:AwAECAgABRQDCQAEAQjwAwBWeBQBBRQACAAEAQhVCwBHpRcBBRQACQAEAQjwAwBTPxQBBRQAAA==.夜星尘:AwABCAEABRQAAA==.',['�']='奥斯卡丶弗丁:AwAFCAEABAoAAA==.她的婕毛:AwABCAEABAoAAA==.',['�']='嫣语紫梦:AwAICA4ABAoAAA==.',['�']='宇智波垫垫:AwAICAgABAoAAA==.安吉莉娜茱莉:AwAHCAsABAoAAA==.',['�']='小可怜:AwAICAgABAoAAQwASTgDCAoABRQ=.小呆莉:AwECCAIABAoAAA==.小小二东:AwAFCAUABAoAAA==.小胖墩儿:AwAICAEABAoAAA==.就是霸气侧漏:AwACCAIABRQAAA==.尸气逼人:AwACCAEABAoAAA==.',['�']='山海观雾:AwAECAQABRQAAA==.',['�']='帕姆尼:AwAECAYABAoAAA==.',['�']='幺儿健康聪慧:AwAFCAQABAoAAA==.',['�']='弘树:AwABCAEABRQAAA==.',['�']='彼岸双生:AwAICAgABAoAAA==.',['�']='待谁共鸣:AwAICAgABAoCDQAIAAgAAABMBQAABAoADgAIAAgAAABMBQAABAoAAA==.',['�']='心憶評:AwAECAQABRQAAA==.',['�']='悠悠丸子:AwAECAQABRQAAA==.',['�']='愛泽里特:AwAECAQABRQAAA==.',['�']='战斗怒吼:AwAFCAUABAoAAA==.',['�']='拉文:AwAGCAgABRQCCgAEAQikEABJAwUBBRQACgAEAQikEABJAwUBBRQAAQIAV3UICAgABRQ=.',['�']='斩戟:AwACCAIABAoAAA==.',['�']='旧唁虐訫:AwAFCAIABAoAAA==.',['�']='星觅丶知鸢:AwACCAIABAoAAA==.春宵何处:AwACCAIABRQAAA==.昼虎:AwEICAgABAoAAQ8AAAAICAMABRQ=.',['�']='暗夜无穹:AwAHCAUABAoAAA==.暮光升腾者:AwABCAEABRQAAA==.',['�']='最爱吃低保:AwACCAMABRQAAA==.最近兽了:AwACCAIABRQAAQ8AAAAICAQABRQ=.月下凝眸:AwACCAQABRQAAA==.朕见你就晕:AwAECAIABAoAAA==.',['�']='杀手皇后丶:AwAECAYABRQDCgAEAQhdGgAv1uYABRQACgAEAQhdGgAv1uYABRQAEAACAQhXDQAgXYUABRQAAREAOigGCAoABRQ=.',['�']='柒夜:AwACCAIABAoAAA==.',['�']='根号二:AwAECAQABAoAAA==.',['�']='欧碧泉:AwAGCAYABAoAAA==.',['�']='歪歪熊猫:AwACCAQABRQAAA==.死亡之卧:AwAICA4ABAoAAA==.',['�']='永恒的大水:AwAHCAcABAoAAA==.',['�']='沐雨橙风:AwACCAIABRQAAA==.没有线的风筝:AwABCAEABRQAAA==.',['�']='泡鲁哒:AwAECAIABAoAAA==.',['�']='洒洒水啦:AwAGCAYABAoAAA==.',['�']='深井烧鹅:AwAGCAcABAoAAA==.',['�']='渡邊麻友丶:AwAGCAYABAoAAA==.',['�']='澄兮:AwADCAUABAoAAA==.',['�']='火焰山:AwAECAQABRQAAA==.灰燼使者丶:AwAICAkABAoAAA==.灵魂低语:AwACCAYABRQDDgACAQgWHwAcoYcABRQADgACAQgWHwAcoYcABRQAEgABAQgBFQAUBEcABRQAAA==.',['�']='熊小宝丶:AwACCAIABAoAAA==.',['�']='燕姿姐姐:AwAGCAYABAoAAA==.',['�']='爱喝饮料:AwAECAcABAoAAA==.爷嘎嘎猛:AwACCAIABRQAAA==.爸爸头很硬:AwACCAIABRQDAgAIAQhvNgAUe8wABAoAAgAIAQhvNgAL58wABAoABwAFAQj4gwAWJZwABAoAAA==.',['�']='牛大灵:AwAECAQABRQAAA==.牛美灵:AwAGCAQABRQCEwAEAQjWCgA/EvIABRQAEwAEAQjWCgA/EvIABRQAAA==.牛顿:AwABCAIABRQAAA==.',['�']='独统天下:AwAICAgABAoAAA==.',['�']='猫的摇篮:AwADCAMABRQAAA==.',['�']='玉环大发机械:AwABCAIABRQCFAAHAQiSDgBL8RkCBAoAFAAHAQiSDgBL8RkCBAoAAA==.玉蹄:AwABCAEABRQAAA==.玛法里澳怒水:AwAGCAsABAoAAQ8AAAAICAMABRQ=.玲娜贝贝猪:AwAGCAgABRQCAQAGAQgUAQBRdAwCBRQAAQAGAQgUAQBRdAwCBRQAAA==.',['�']='疲倦的陈帆:AwAGCAQABRQAAA==.',['�']='盾血目:AwADCAIABRQEFQAIAQgIHAA7ScYBBAoAFQAIAQgIHAA58MYBBAoAFgAGAQgpJgAvqIcBBAoAFwAGAQgaRAAqGQEBBAoAAA==.',['�']='看无敌的增辉:AwAGCAYABAoAAA==.',['�']='矜持的耗子:AwADCAEABRQAAA==.短腿小肚子:AwAICBkABAoCBwAIAQiSLAA9794BBAoABwAIAQiSLAA9794BBAoAAA==.',['�']='神暗灬灬:AwAFCA0ABRQDCgAFAQipBgBa1zABBRQACgAEAQipBgBfRDABBRQACwAFAQh+AwA4lSMBBRQAARgAS9AGCAoABRQ=.',['�']='等雨:AwAECAgABRQCCQAEAQhwCgArRt4ABRQACQAEAQhwCgArRt4ABRQAAA==.筱锦妍:AwAGCAYABAoAAA==.',['�']='糕手风月眠:AwACCAUABRQCGAACAQjPCwBFmLgABRQAGAACAQjPCwBFmLgABRQAAA==.',['�']='红色咕咕:AwADCAIABRQAAA==.纪笑:AwACCAIABAoAAQEASCcFCAwABRQ=.',['�']='结城明衵奈:AwAGCBkABRQDEwAGAQjUAgAwgVcBBRQAEwAEAQjUAgAlvFcBBRQAGQACAQhgEwBblWoABRQAAA==.绿到你发慌:AwAGCAIABRQAAA==.',['�']='羽落凡塵丶:AwAICAgABAoAAA==.',['�']='翡翠捕梦者:AwAECAMABRQAAA==.',['�']='老娘的回合:AwAICAMABAoAAA==.老滚威:AwACCAMABRQCEQAIAQjrIAA2N9ABBAoAEQAIAQjrIAA2N9ABBAoAAA==.',['�']='联盟克格勃:AwAECBEABRQDGQAEAQhQBQBNX/sABRQAGQADAQhQBQBLSPsABRQAEwAEAQhfDQA1VuIABRQAAA==.',['�']='肯瑞托:AwAFCAUABAoAAA==.',['�']='腰身一比一:AwAFCAwABRQCAQAFAQhgFQBIJ+sABRQAAQAFAQhgFQBIJ+sABRQAAA==.',['�']='致雨:AwABCAEABRQAAA==.',['�']='艾多多:AwAECAQABRQAAA==.',['�']='芝麻糊兒:AwACCAYABRQDGgACAQicEgAegIIABRQAGgACAQicEgAegIIABRQAGwACAQjMBwAG8ksABRQAAA==.芭蒂斯图塔:AwAECAQABAoAAA==.芭蕉裳:AwACCAIABRQCHAAIAQjeKgAagAQBBAoAHAAIAQjeKgAagAQBBAoAAA==.',['�']='華丽转身:AwADCAMABAoAAA==.',['�']='萦舞飞扬:AwAGCAkABAoAAA==.',['�']='蓝弦:AwACCAMABRQAAA==.蓝方里:AwABCAEABAoAAA==.蓝海:AwAECAYABAoAAQ8AAAAGCAcABAo=.',['�']='西红柿大侠:AwAECAQABRQAAA==.',['�']='觉醒镇魂者:AwADCAcABRQDBgADAQgICwA6uwMBBRQABgADAQgICwA6uwMBBRQABAACAQiEEAA6BIgABRQAAA==.',['�']='负责帅:AwAICBUABAoCFwAIAQixCwBYB2MCBAoAFwAIAQixCwBYB2MCBAoAAA==.贰两小面:AwAGCAoABAoAAA==.贼萌丶:AwADCAMABRQAAA==.',['�']='路易斯丶魔玲:AwAGCAYABAoAAA==.',['�']='透露:AwAECAIABRQAAA==.逼逼蟹蟹:AwAICAgABAoAAA==.',['�']='那只小猫:AwACCAIABRQAAA==.那碗面的风情:AwACCAIABRQAAA==.',['�']='醒掌天下权:AwAECAQABRQAAA==.',['�']='采花奶牛:AwAGCAUABRQDBgAEAQgPFgAx1dAABRQABgAEAQgPFgAx1dAABRQABAABAQj/GQAwjkMABRQAAA==.',['�']='银花夜照丶:AwACCAQABRQAAA==.',['�']='闷蕉:AwADCAMABRQAAA==.',['�']='阿尔特迷丝:AwACCAQABRQAAA==.阿泼次得:AwABCAEABAoAAA==.阿爾讬莉亞:AwAICAgABAoAAA==.',['�']='雪羽丶星枫:AwACCAMABRQAAA==.',['�']='青菜丸子:AwAECAQABRQAAA==.',['�']='顾大锤:AwAICAwABAoAAA==.',['�']='风雨飘飞:AwADCAYABAoAAA==.飘逸的生活:AwACCAMABRQAAA==.飞机头的兽贼:AwAGCAYABAoAAA==.飞机头的情人:AwAECAsABRQDFAAEAQi/AgBbWzYBBRQAFAAEAQi/AgBYLjYBBRQAHQAEAQiYAgBaOysBBRQAAA==.飞机头的死骑:AwAICA4ABAoAAQ8AAAAICAIABRQ=.',['�']='饱了:AwADCAMABAoAAA==.饼饼不画饼:AwAECAQABRQAAQ8AAAAICAIABRQ=.',['�']='香辣二拐拐:AwACCAIABRQAAQMARe4HCAcABRQ=.馨香帅:AwAICAYABAoAAA==.',['�']='骄阳啊米:AwAICAkABAoAAA==.',['�']='麦乐旋风:AwAGCAUABAoAAA==.',['�']='黄同:AwADCAEABAoAAA==.黑无光:AwAFCAwABAoAAA==.黛安娜丶:AwAICAIABAoAAA==.黯淡神光:AwADCAMABRQAAA==.',['�']='龙人包菜呢:AwAICAgABAoAAA==.龚姿:AwAFCAgABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end