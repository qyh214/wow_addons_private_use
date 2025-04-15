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
 local lookup = {'Priest-Discipline','Shaman-Enhancement','Hunter-Marksmanship','Hunter-BeastMastery','Unknown-Unknown','DeathKnight-Unholy','Paladin-Retribution','DemonHunter-Havoc','Mage-Frost','Monk-Mistweaver','Evoker-Devastation','Warlock-Demonology','Paladin-Protection','Druid-Restoration','Priest-Holy','Shaman-Elemental','Warrior-Arms','DeathKnight-Blood','Warrior-Fury','Druid-Balance','Druid-Guardian','Paladin-Holy','Monk-Brewmaster','Mage-Fire','Priest-Shadow','Druid-Feral','Warlock-Destruction',}; local provider = {region='CN',realm='万色星辰',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Arccher:AwACCAIABRQAAQEAUJsGCA4ABRQ=.',Au='Authentic:AwADCAMABRQAAA==.',Bu='Butwhy:AwAICAgABAoAAA==.',Ce='Centuria:AwAGCAoABRQCAgAGAQjXAAA5M8UBBRQAAgAGAQjXAAA5M8UBBRQAAA==.',Co='Costel:AwAHCAIABAoAAA==.',De='Demii:AwAECAQABRQAAA==.',Lo='Loktarogar:AwAGCAMABRQAAA==.Lorelei:AwACCAIABRQAAA==.',Lv='Lv:AwAECAEABRQAAA==.',Mi='Minotaurus:AwAECAgABRQDAwAEAQinAwBXFA8BBRQABAAEAQgnCwBHVREBBRQAAwAEAQinAwBH8Q8BBRQAAA==.',Oh='Oh:AwADCAMABRQAAQUAAAAECAQABRQ=.',Re='Redstone:AwACCAIABRQAAQQAShkGCA4ABRQ=.',Sa='Saya:AwAICAoABAoAAA==.',Sh='Shekinah:AwADCAMABRQAAA==.',So='Songofdeath:AwAECAYABRQCBgAEAQgCCgA8ifcABRQABgAEAQgCCgA8ifcABRQAAQcAQuUECBEABRQ=.',Ti='Timelessxt:AwAICBYABAoCBwAIAQhtFQBfIa4CBAoABwAIAQhtFQBfIa4CBAoAAA==.',To='Toonagoni:AwAGCAoABAoAAA==.',Wx='Wxw:AwAFCAUABAoAAA==.',Yl='Yl:AwAICAoABAoAAA==.',Yt='Ytdbb:AwABCAEABAoAAA==.',['�']='一群小章鱼:AwAECAIABRQAAA==.七狮群啸:AwAECAYABRQDAwAEAQhYAQBbajkBBRQAAwAEAQhYAQBbajkBBRQABAACAQhDLgAgt3gABRQAAA==.万阙星流:AwAFCAUABAoAAA==.三十六敌:AwAICAkABAoAAA==.三千情诗:AwAFCAoABAoAAA==.三角初音:AwADCAMABRQAAA==.下午茶:AwAGCAcABAoAAA==.不过些许枫霜:AwAGCAoABAoAAA==.东京很热:AwAICBAABAoAAA==.丨星尘丨:AwABCAEABAoAAA==.丨知更鸟丨:AwACCAIABRQDAwAGAQiIHQBP5qoBBAoAAwAFAQiIHQBPuqoBBAoABAAFAQjKlgAs+cwABAoAAA==.丨莫问丨:AwACCAYABRQCCAACAQh7GwA4UpwABRQACAACAQh7GwA4UpwABRQAAA==.丶半仙:AwAECAQABRQAAA==.丷福生:AwAECAQABRQAAA==.',['�']='二十世纪少年:AwAGCAcABAoAAA==.云璃:AwAGCBUABAoCCQAGAQjLFgBgbCgCBAoACQAGAQjLFgBgbCgCBAoAAA==.亮劍:AwACCAEABAoAAA==.亲我叫我老公:AwAICAoABAoAAA==.',['�']='伊吕波:AwAHCAkABAoAAA==.优优鸣天箭:AwAFCAUABAoAAA==.伤害加倍:AwABCAEABRQAAA==.伴你月落星沉:AwAGCAgABAoAAA==.似是故人莱:AwAICAsABAoAAA==.',['�']='余香萦袖:AwAECAQABRQAAA==.',['�']='保国:AwAECAcABRQCCgAEAQhLDAAskOcABRQACgAEAQhLDAAskOcABRQAAQoAH94ICAoABRQ=.',['�']='光影化身:AwAICAEABAoAAA==.光誓者菲娅:AwAGCAoABAoAAA==.克丽丝汀:AwADCAMABAoAAA==.八奈见杏菜:AwAICAYABAoAAA==.',['�']='冰火无双:AwAICAsABAoAAA==.冷光:AwAGCAQABRQAAA==.冷夜旋律:AwAECAQABRQAAQUAAAAGCAQABRQ=.',['�']='初心:AwAHCAcABAoAAA==.别问:AwADCAMABAoAAA==.别问法力残渣:AwAECAQABRQAAQUAAAAGCAQABRQ=.',['�']='十进制:AwAICAkABAoAAA==.',['�']='厌旧:AwAICAgABAoAAA==.原初巴哈姆特:AwAICAsABAoAAQsAGzAECAYABRQ=.',['�']='双疯插芸:AwAICAgABAoAAA==.史尔特尔:AwAICAgABAoAAA==.',['�']='吸我:AwADCAMABAoAAA==.',['�']='咿呀壹:AwAECAQABRQAAA==.',['�']='唐门火锅:AwAICCcABAoCDAAIAQi0LwAateAABAoADAAIAQi0LwAateAABAoAAQsATrEECBMABRQ=.',['�']='喧嚣屮:AwAICAgABAoAAA==.',['�']='嘿丶小刀子:AwAICAgABAoAAA==.',['�']='噬丨影:AwAECAYABRQCBAAEAQglDQBM3wYBBRQABAAEAQglDQBM3wYBBRQAAA==.',['�']='回忆童年:AwAICA0ABAoAAA==.',['�']='圣光照耀我:AwAECBEABRQDBwAEAQi1GwBC5dYABRQABwADAQi1GwBiG9YABRQADQABAQiVFgAEeRYABRQAAA==.圣嘉然:AwAECAQABRQAAA==.',['�']='坠爱红烧又:AwAICBYABAoCBwAIAQjjVwA0T8sBBAoABwAIAQjjVwA0T8sBBAoAAA==.',['�']='壶壶:AwAGCAYABAoAAA==.',['�']='夜灬舞者:AwAGCAYABAoAAA==.夜爲央:AwAICAgABAoAAQ4AGrUGCAYABRQ=.天意四象:AwABCAEABAoAAQUAAAACCAIABRQ=.天真:AwACCAIABRQAAA==.夫子望山非山:AwAICB0ABAoCBgAIAQhtDABbBqUCBAoABgAIAQhtDABbBqUCBAoAAA==.',['�']='奇诺哥哥:AwADCAMABAoAAA==.奎特玛尼斯:AwAFCAYABAoAAA==.奥肥利亚:AwACCAIABAoAAQIAM3YICAkABRQ=.女孩:AwAGCAYABAoAAA==.奶奶也会玩:AwAECAYABAoAAA==.',['�']='妇科圣手:AwAGCAYABAoAAA==.',['�']='娜可璐璐:AwADCAMABAoAAA==.娜露梅亚:AwAFCA8ABRQCCAAFAQh2AgBMI44BBRQACAAFAQh2AgBMI44BBRQAAA==.',['�']='宁静的心灵:AwAICAkABAoAAA==.宇髓天元:AwAFCAUABAoAAA==.',['�']='小嗨僧丶:AwAECAQABRQAAA==.小天彩:AwAGCAMABAoAAA==.小太阳狮子:AwAICAgABAoAAA==.小小酥:AwAECAQABRQAAA==.小星榆:AwAECAUABAoAAA==.小渡鴉:AwAECAQABRQAAA==.小灬蝶:AwAECAQABRQAAA==.小白龙:AwABCAEABRQAAA==.小耳朵图图:AwAICA4ABAoAAA==.小胖次:AwAICA4ABAoAAA==.小辰:AwAECA0ABRQCBwAEAQhlDQBW4goBBRQABwAEAQhlDQBW4goBBRQAAA==.小黄毛:AwACCAIABAoAAA==.小龙猫:AwAICAUABAoAAA==.就这个吧:AwAICBEABAoAAA==.',['�']='巡海:AwAFCAwABRQCCgAFAQhBDgAbO9wABRQACgAFAQhBDgAbO9wABRQAAA==.',['�']='帅就行了:AwAICBcABAoCBgAIAQgUOwAq9ZEBBAoABgAIAQgUOwAq9ZEBBAoAAA==.',['�']='幻影莴苣:AwACCAIABRQAAA==.幻翎灬月影寒:AwAGCAYABAoAAA==.幽儿希卡:AwADCAMABRQCDwAIAQgXEABHVTACBAoADwAIAQgXEABHVTACBAoAAA==.',['�']='弥音:AwABCAEABRQAAQUAAAAGCAIABRQ=.',['�']='御兽:AwABCAEABAoAAA==.御星魔矢:AwACCAIABRQAAA==.微醺龙:AwACCAIABAoAARAAVZkICAIABRQ=.',['�']='思云:AwABCAIABRQAAA==.怡红寺方丈:AwAICAgABAoAAA==.',['�']='恐怖剑刃:AwAICAgABAoAAA==.',['�']='悔罪:AwAGCAIABAoAAA==.',['�']='情深深:AwACCAMABRQAAA==.',['�']='我牧莴苣:AwAECAQABRQAAA==.战疫:AwADCAQABAoAAA==.战鬼:AwAICB4ABAoCEQAIAQggBwBPuIUCBAoAEQAIAQggBwBPuIUCBAoAAA==.',['�']='托尔:AwAHCAMABAoAAA==.承受着痛苦:AwAGCAkABAoAAA==.',['�']='报告魔王:AwAECAEABRQAAA==.',['�']='拉萨多:AwACCAIABAoAAQUAAAAICAsABAo=.',['�']='摇摇薯条:AwAGCA0ABAoAAA==.',['�']='撒满起司:AwACCAIABRQAAA==.',['�']='擢升:AwACCAIABRQAAA==.',['�']='敲硬:AwAICAgABAoAAA==.',['�']='无可奉告丶:AwAGCAsABAoAAA==.无敌修罗女:AwAICAoABAoAAA==.旺旺狗:AwACCAIABRQAAA==.',['�']='星之彩:AwADCA4ABRQDAQADAQj+AgBdMTwBBRQAAQADAQj+AgBdMTwBBRQADwABAQi3HQAq7jgABRQAAA==.星哥:AwAECAQABRQAAA==.昨夜星辰璀璨:AwAICAgABAoAAA==.',['�']='晓红帽:AwAICAoABAoAAA==.晨星对不对:AwAHCAcABAoAAA==.晨曦郑:AwAFCAUABAoAAA==.景辰:AwACCAMABRQAAQcAVuIECA0ABRQ=.晴天吃饱了:AwAECAQABRQAAA==.',['�']='暗瞳丶:AwACCAIABRQAAA==.暮色夜语:AwACCAMABRQAAA==.',['�']='月之星影:AwAGCAYABAoAAA==.月之魔女:AwAECAgABRQCEgAEAQh1DwActp4ABRQAEgAEAQh1DwActp4ABRQAAA==.朔月明心:AwAGCAYABAoAAA==.朝小树丶:AwAECAQABRQAAQQAQe4ICAkABRQ=.术神夜:AwAFCAoABAoAAA==.机场路小鸽子:AwAECAIABRQAAA==.',['�']='李常有:AwAECAQABRQAAQUAAAAICAEABRQ=.条码人:AwADCAcABRQCCgADAQhtDQA0TeEABRQACgADAQhtDQA0TeEABRQAAA==.',['�']='枫靈灬月影寒:AwABCAEABRQDEQAIAQjKKAAqJjYBBAoAEQAFAQjKKAAoljYBBAoAEwAGAQjDRQAmWiQBBAoAAA==.',['�']='梅丽丽:AwABCAEABAoAAA==.梦的远方:AwADCAMABAoAAA==.',['�']='椎名深夏:AwAICAgABAoAAA==.',['�']='概念神:AwAECAQABRQAAA==.',['�']='死灵之殇:AwADCAgABRQCAQADAQgMBgBDBQwBBRQAAQADAQgMBgBDBQwBBRQAAA==.',['�']='残疾军团一号:AwABCAEABAoAAA==.殷夜来丶:AwAECAQABRQAAA==.',['�']='毛拉索:AwADCAkABRQCFAADAQgaAwBgFEIBBRQAFAADAQgaAwBgFEIBBRQAAA==.',['�']='法妮雅:AwAGCAYABAoAAA==.',['�']='洛托姆:AwAGCAIABRQAAA==.洛羽:AwAHCAkABAoAAA==.',['�']='浅浅淡了:AwAECAIABRQAAA==.',['�']='温暖的尸体:AwAICAgABAoAAA==.',['�']='火影大人:AwAGCAoABAoAAA==.火锅肥牛卷:AwADCAMABAoAAA==.灬中毒智深丶:AwACCAIABRQAAA==.灬中毒致深丶:AwACCAEABAoAAA==.',['�']='炼天魔尊:AwAHCBAABAoAAA==.',['�']='热浪:AwADCAMABRQAAA==.烷渼瞬间:AwABCAEABAoAAA==.',['�']='爆力:AwACCAIABRQAAA==.爷们黑武士:AwABCAEABAoAAA==.',['�']='牢辰:AwAICAgABAoAAA==.',['�']='狐坂若藻:AwAECAQABAoAAA==.独行亦如众:AwACCAIABRQAAA==.',['�']='猫猫加油:AwAICAgABAoAAA==.',['�']='琳琳:AwABCAIABRQAAA==.',['�']='瑞德哞丶:AwAICBgABAoDFAAIAQj0HwBPTSgCBAoAFAAHAQj0HwBV4SgCBAoAFQABAQgwJwAn1DEABAoAAA==.',['�']='甜甜宝贝:AwAICAgABAoAAA==.画眉深浅处丶:AwAHCAsABAoAAA==.',['�']='留白乀:AwAICAgABAoAAA==.',['�']='疲倦的眼睛:AwAICAcABAoAAA==.疾风怒涛之计:AwAICAoABAoAAA==.',['�']='相期邈云汉:AwAICBUABAoDBwAIAQgXHgBTdogCBAoABwAIAQgXHgBTdogCBAoAFgAIAQghGQAmf20BBAoAAA==.相看两不厌:AwAHCAcABAoAAA==.相逢何曾相识:AwACCAMABAoAAA==.',['�']='碎碎冰丶:AwAICBwABAoCBwAIAQglGABaqKICBAoABwAIAQglGABaqKICBAoAAA==.',['�']='禁止随地野战:AwAICAgABAoAAQUAAAAGCAIABRQ=.',['�']='穿黑斯不灭团:AwACCAUABRQCBgACAQh0GwAQZnsABRQABgACAQh0GwAQZnsABRQAAA==.',['�']='第一村人:AwAICAgABAoAAA==.',['�']='簡單丶點:AwAECAQABRQAAA==.',['�']='米米牛:AwAGCAUABAoAAA==.',['�']='红莲极意:AwAECAEABRQCFwAIAQhGCABF28QBBAoAFwAIAQhGCABF28QBBAoAAA==.',['�']='结衣丶:AwAECAQABRQAAA==.',['�']='羅莎舞月:AwAICAsABAoAAA==.',['�']='职场大调查:AwAECAQABRQAAA==.',['�']='胧明郑:AwADCAMABAoAAA==.',['�']='自摸:AwAECAgABRQCCAAEAQhKAwBh21YBBRQACAAEAQhKAwBh21YBBRQAAA==.',['�']='芝意:AwAGCAYABAoAAA==.芭娜娜:AwAICAgABAoAAA==.花村大瞎子:AwAICAkABAoAAA==.',['�']='荣耀王德雷克:AwACCAIABRQAARgAVEsICBAABRQ=.',['�']='莉丝缇亚:AwAECAwABRQCGQAEAQgkCQBDQ/cABRQAGQAEAQgkCQBDQ/cABRQAAA==.',['�']='蛇蛇:AwABCAEABRQAAA==.',['�']='蜂蜜杰瑞:AwAGCAYABAoAAA==.',['�']='蟹粉小笼包:AwAICAgABAoAAA==.',['�']='行苇:AwAICAgABAoAAA==.',['�']='豹雪:AwADCAgABRQCGgADAQiwAQBDcQkBBRQAGgADAQiwAQBDcQkBBRQAAA==.',['�']='赛莉艾:AwAGCAYABAoAAA==.',['�']='超级葫芦娃:AwAICAgABAoAAA==.',['�']='轻风低语:AwAICAkABAoAAA==.',['�']='迫曉:AwAICBkABAoDFAAIAQh7JgA48gACBAoAFAAIAQh7JgA48gACBAoAFQABAQjiLwAQKw4ABAoAAA==.',['�']='遗失的足迹:AwAICAkABAoAAA==.遗梦丶精:AwAECAQABRQAAA==.',['�']='邪炎大魔王:AwAECAQABRQAAA==.邪能范小勤:AwAECAQABRQAAA==.',['�']='郁盛:AwACCAQABRQAAA==.部落:AwAECAQABRQAAA==.',['�']='钢子:AwAGCAYABRQDEwAGAQgKCwAt8QABBRQAEwAEAQgKCwAzMgABBRQAEQACAQgZBwAmEL0ABRQAAA==.',['�']='闪光毛线球:AwADCAMABAoAAA==.',['�']='阳光果粒橙:AwAFCAoABAoAAA==.阿伏伽德罗:AwAGCAQABAoAAA==.',['�']='陈悠米:AwAECAgABRQCFAAEAQghDQA8RvIABRQAFAAEAQghDQA8RvIABRQAAA==.',['�']='隐逸之华:AwACCAIABAoAAA==.',['�']='霜寒之翼:AwAICAcABAoAAA==.霜糖啵啵:AwAECAQABRQAAA==.',['�']='领跑:AwABCAEABRQAAA==.',['�']='风吹丹顶鹤:AwAECA0ABRQCCAAEAQi3BABdUjgBBRQACAAEAQi3BABdUjgBBRQAAA==.风娃娃:AwADCAEABAoAAA==.风茗:AwACCAEABAoAAA==.',['�']='饿了么猎手:AwAICAgABAoAAA==.',['�']='鱿鱼小宝贝:AwAHCAcABAoAAA==.',['�']='鸟语花香:AwABCAEABAoAAA==.鸠之钢:AwACCAIABAoAAA==.',['�']='麦迪逊花园:AwACCAcABRQDDwACAQiODQA4/58ABRQADwACAQiODQA4/58ABRQAAQACAQjrGAAMqG8ABRQAAA==.',['�']='黄小发:AwAECAwABRQDGwAEAQgHBQBTOh4BBRQAGwAEAQgHBQBTOh4BBRQADAABAQiaFwAAAAAABRQAAA==.黄磊:AwACCAIABAoAAA==.黎熙丶:AwAECAQABRQAAA==.黑游:AwABCAEABAoAAA==.',['�']='鼠鼠热饮:AwAECAgABRQCCgAEAQhYCABBGAUBBRQACgAEAQhYCABBGAUBBRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end