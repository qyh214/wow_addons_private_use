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
 local lookup = {'DemonHunter-Havoc','Shaman-Enhancement','Paladin-Retribution','DeathKnight-Blood','DeathKnight-Unholy','Monk-Mistweaver','Priest-Holy','Rogue-Assassination','Mage-Fire','DemonHunter-Vengeance','Warrior-Fury','Rogue-Subtlety','Warlock-Destruction','Warlock-Demonology','Priest-Shadow','Druid-Balance','Druid-Restoration','Unknown-Unknown','Paladin-Holy','Paladin-Protection','Hunter-BeastMastery','Shaman-Restoration','Shaman-Elemental','Warlock-Affliction',}; local provider = {region='CN',realm='山丘之王',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ao='Aoo:AwACCAIABRQAAA==.',Ar='Artano:AwAHCAoABAoAAA==.Artemis:AwAECAQABRQAAA==.',As='Aspro:AwACCAYABRQCAQACAQjtGwA58JoABRQAAQACAQjtGwA58JoABRQAAA==.',Fe='Feybrook:AwAGCAYABAoAAA==.',Gr='Grumbar:AwACCAIABAoAAA==.',Ha='Hathor:AwAECAQABRQAAA==.',Ji='Jiuhencoola:AwAECAQABRQAAA==.',Ju='Juicethekidd:AwAECAQABRQAAQIAM3YICAkABRQ=.',Ki='Kissmeto:AwACCAIABRQAAA==.',Lk='Lklks:AwAECAQABRQAAA==.',My='Myazonokaori:AwAICAIABAoAAA==.',Pa='Paladinn:AwAECAcABRQCAwAEAQgAFAA7XfIABRQAAwAEAQgAFAA7XfIABRQAAA==.',Ra='Rayx:AwADCAwABRQCBAADAQj8BQBKrQQBBRQABAADAQj8BQBKrQQBBRQAAA==.',To='Tooldh:AwAGCAIABRQAAA==.',Xi='Xiaoluobo:AwAECAQABRQAAA==.',['�']='一个牛油果:AwABCAEABRQAAA==.一十一:AwAGCAgABAoAAA==.一手微风:AwABCAEABRQAAA==.一骑绝尘:AwAGCAQABAoAAA==.上泉信纲:AwAECAUABAoAAA==.不会增强萨:AwABCAEABAoAAA==.东风恶:AwAFCAcABAoAAA==.丨落夜秋枫丨:AwAICA4ABAoAAA==.丶一缕阳光:AwAHCAUABAoAAA==.丶繁华尽世人:AwAECAIABAoAAA==.丶荼蘼:AwABCAIABRQAAA==.',['�']='乌鲁蒂娅:AwAECAQABRQAAA==.九条裟罗:AwABCAEABRQAAA==.',['�']='二毕卵仔:AwACCAIABRQAAQQAY3oICAoABRQ=.二队牧師:AwACCAYABRQDBQACAQixHAARYW0ABRQABQACAQixHAAMd20ABRQABAACAQjLFwARYVgABRQAAA==.',['�']='伊莉捷雯:AwABCAEABRQAAA==.伊莉琳德拉:AwAGCAYABAoAAA==.传说迷茫:AwAECAQABRQAAA==.',['�']='但无所求:AwAICAQABAoAAA==.佟痞燕:AwAICAgABAoAAA==.',['�']='假好人:AwAECAQABAoAAA==.',['�']='八重神子:AwABCAEABRQAAA==.六尘灬未了:AwACCAEABRQAAA==.',['�']='冰封爱恋:AwAECAQABRQAAA==.冻结得黎明:AwAECAQABRQAAA==.',['�']='凉凉:AwABCAEABAoAAA==.凨伊:AwABCAIABRQAAA==.',['�']='刹马特:AwAECAMABAoAAA==.',['�']='十二星座射手:AwAICA4ABAoAAA==.十二星座水瓶:AwABCAEABRQAAA==.千手修罗丶:AwACCAMABRQCBgAIAQjsJQA0RKgBBAoABgAIAQjsJQA0RKgBBAoAAA==.单身我能撩吗:AwADCAMABRQAAA==.南宫贝贝:AwABCAIABRQCBwAHAQhpGABKluoBBAoABwAHAQhpGABKluoBBAoAAA==.卡多雷风铃:AwADCAMABAoAAA==.卡夫:AwAICBgABAoCCAAIAQj/GAAgpYUBBAoACAAIAQj/GAAgpYUBBAoAAA==.卵眠眠:AwAICAMABAoAAA==.',['�']='反派:AwACCAIABAoAAA==.只喂丶三鹿奶:AwAECAQABAoAAA==.只拉风不拉怪:AwAECAQABRQAAA==.叫我德彪:AwAHCAEABAoAAA==.',['�']='君莫白:AwAICAgABAoAAA==.',['�']='呀呀多苦啊:AwACCAIABRQAAA==.呆萌一小萨:AwAGCAkABAoAAA==.',['�']='哇哦丶谢谢你:AwAECAQABRQAAA==.哈武镐:AwAECAQABRQAAA==.哈雷丶:AwAECAQABRQAAA==.哲学家:AwACCAMABRQAAA==.',['�']='啾如雪:AwABCAEABRQAAA==.',['�']='喜仔:AwACCAIABRQAAA==.',['�']='圆通快递:AwAECAQABRQAAA==.圣之刃:AwAECAgABRQCAwAEAQgyEAA9QP8ABRQAAwAEAQgyEAA9QP8ABRQAAA==.',['�']='坑队友:AwABCAEABAoAAA==.',['�']='塞尔比兽:AwABCAEABRQAAA==.',['�']='复甦:AwACCAIABRQAAA==.夏了个天:AwAECAQABRQAAA==.夏玻利利:AwAGCAYABRQCCQAGAQjtAQBFVdABBRQACQAGAQjtAQBFVdABBRQAAA==.大尾巴狼:AwADCAcABRQCBAADAQgMFQAG5HAABRQABAADAQgMFQAG5HAABRQAAA==.天丨刃:AwAGCAIABRQCAgACAQjIDABIzKMABRQAAgACAQjIDABIzKMABRQAAA==.天啾星:AwAFCAcABAoAAA==.',['�']='女人是老虎:AwAICAYABAoAAA==.',['�']='孤独狮子:AwAGCAoABRQCAwAGAQhnAABDmPMBBRQAAwAGAQhnAABDmPMBBRQAAA==.',['�']='宇夜:AwACCAUABRQCCgACAQghDAAsRHoABRQACgACAQghDAAsRHoABRQAAA==.安东尼雷克:AwAECAgABRQCCwAEAQipDAAq5vcABRQACwAEAQipDAAq5vcABRQAAA==.',['�']='寒鳴:AwAECAgABRQDCAAEAQgrAgBTcjoBBRQACAAEAQgrAgBTcjoBBRQADAAEAQhABwAk3usABRQAAA==.',['�']='封神蚀刻:AwAECAQABRQAAA==.小呆萌:AwAGCAIABRQAAA==.小土豆:AwAFCAUABRQCCwAFAQhbAQA/TpABBRQACwAFAQhbAQA/TpABBRQAAA==.小术枝丶:AwAECAcABRQDDQAEAQieBABW0CMBBRQADQAEAQieBABW0CMBBRQADgABAQgGGAAAAAAABRQAAA==.小熊猫爱睡觉:AwAICAwABAoAAA==.小米不十三:AwABCAEABRQAAA==.小胖王淑芬:AwAECAoABRQCAwAEAQj5BgBa1ScBBRQAAwAEAQj5BgBa1ScBBRQAAA==.少年芒:AwACCAQABRQAAA==.少年骑:AwACCAIABRQAAA==.',['�']='工具小德:AwACCAIABRQAAA==.工具迪凯:AwAICAgABAoAAA==.工具锄头:AwAICAQABAoAAA==.巧笑嫣然:AwAECAQABRQAAA==.',['�']='年老轻狂:AwAECAQABRQAAQ8ANEsICAgABRQ=.幻行者梅林:AwADCAIABRQAAA==.',['�']='库兹涅塔夫:AwAICAgABAoAAA==.',['�']='影枫:AwABCAEABAoAAA==.',['�']='很大压力:AwAICAcABAoAAA==.徳來全不費巭:AwAECAMABRQDEAAIAQjQIABaPCICBAoAEAAIAQjQIABaPCICBAoAEQABAQgwdwAVFzIABAoAARIAAAAGCAIABRQ=.',['�']='忧郁的蓝:AwACCAIABAoAAA==.',['�']='恐惧冰霜:AwAECAQABRQAAA==.恒生指数:AwAGCAgABAoAAA==.',['�']='抵挡:AwAFCAEABAoAAA==.',['�']='放开那个叔叔:AwAGCAQABRQAAA==.',['�']='敦豪快递:AwAECAQABRQAARIAAAAICAQABRQ=.',['�']='斤团小王子:AwABCAEABAoAAA==.',['�']='无杳:AwAHCAcABAoAAA==.无语倾心:AwAECAIABRQAAREAOkwGCAUABRQ=.无限月读:AwAICAEABAoAAA==.',['�']='明河丶:AwAICA8ABAoAAA==.星河之角:AwAHCAcABAoAAA==.星野:AwAGCA8ABAoAAA==.星野梦美:AwAICBUABAoEEwAIAQgeCgBB7CcCBAoAEwAIAQgeCgBB7CcCBAoAAwABAQj/VAEJ1ysABAoAFAABAQi9YAAEuwUABAoAAA==.',['�']='月一薪:AwABCAIABRQAAA==.未成年面包:AwAFCAUABAoAAA==.',['�']='李嘉图:AwAFCAEABAoAAA==.杜康自饮流觞:AwAFCAYABAoAAA==.松浦果南:AwACCAUABRQCFQACAQjqKwAVoIIABRQAFQACAQjqKwAVoIIABRQAAA==.',['�']='橙橘柚:AwACCAIABRQAAA==.',['�']='欧灬皇:AwAECAgABRQCFgAEAQhYBABUWCIBBRQAFgAEAQhYBABUWCIBBRQAARIAAAAGCAIABRQ=.',['�']='正義審判:AwABCAIABRQAAA==.歪特小恶魔:AwAICAgABAoAAA==.',['�']='汉诺崇高力量:AwACCAIABRQAAA==.',['�']='沐雲:AwACCAQABRQDFwAIAQi8EgBGtTMCBAoAFwAIAQi8EgBGtTMCBAoAFgACAQj8kQAZDGYABAoAAA==.没有减伤:AwAGCAYABRQCCQAGAQjbAQBGLNMBBRQACQAGAQjbAQBGLNMBBRQAAA==.',['�']='波尔图:AwADCAMABAoAAA==.泥鳅呵呵:AwAFCAUABAoAAA==.',['�']='洛洛:AwAECAQABRQAAA==.',['�']='海飏:AwACCAMABRQAAA==.',['�']='清茶浅酌:AwAECAQABRQAAA==.渴望长大:AwAGCA4ABAoAAA==.',['�']='漆黑闪光:AwACCAIABRQAAA==.',['�']='潮汐:AwAFCAYABAoAAA==.',['�']='火点墩墩:AwAECAQABRQAAA==.灬关云长灬:AwADCAUABRQCCwADAQjrCwAs5vwABRQACwADAQjrCwAs5vwABRQAAA==.灬加州旅馆灬:AwACCAIABRQAAA==.灬蓝灬天灬:AwABCAIABRQCAwAIAQjCIABRFX0CBAoAAwAIAQjCIABRFX0CBAoAAA==.灶门祢豆子:AwAICAgABAoAAA==.',['�']='烈焰阿锐:AwAICAIABAoAAA==.',['�']='爷爱吃肉:AwACCAIABAoAAA==.',['�']='牢六:AwAICAgABAoAAA==.特基拉不是酒:AwAICAcABAoAAA==.',['�']='狂暴的高个子:AwABCAEABAoAAA==.狗腿柴的主人:AwAHCAUABAoAAA==.',['�']='玛德纸张:AwAGCAYABAoAAA==.',['�']='珍妮玛德帅丷:AwAICAgABAoAAA==.',['�']='璀璨粉粉嫩:AwAGCAEABRQAAA==.',['�']='生無可:AwADCAMABRQAAA==.用心创造快乐:AwAICA4ABAoAAA==.电疗咕咕翅:AwAHCAoABAoAAA==.',['�']='番茄卫士:AwAFCAQABAoAAA==.',['�']='白衫丶:AwADCAMABAoAAA==.白马醉春风:AwAHCAUABAoAAA==.白鹭夜宿纱:AwACCAIABAoAAA==.',['�']='盒马先生:AwACCAQABRQAAA==.',['�']='真蓝色:AwEICAwABAoAAA==.真香:AwAFCAYABAoAAA==.',['�']='穷则思:AwAGCAkABAoAAA==.',['�']='第七军团先锋:AwAECAQABRQAAA==.',['�']='筱姐姐听说伱:AwADCAMABRQAAA==.筱红龙:AwAGCAYABAoAAA==.',['�']='素素:AwAFCAUABAoAAA==.紫川:AwAECAMABAoAAA==.',['�']='繁星点:AwAECAQABRQAAA==.',['�']='罗林雷蒙:AwAGCAYABAoAAA==.',['�']='羅將神聖姬:AwABCAEABRQAAA==.',['�']='考拉丶:AwAECAQABRQAAA==.',['�']='肥猫:AwAECAQABAoAAA==.',['�']='芮晓芮:AwAFCAUABAoAAA==.',['�']='苏心丶岚掌:AwACCAIABAoAAA==.',['�']='莎莎:AwACCAMABRQCFwAIAQihCABUVJ4CBAoAFwAIAQihCABUVJ4CBAoAAA==.',['�']='菈妮:AwACCAIABRQAAA==.菈妮的布莱泽:AwACCAIABRQAAA==.',['�']='萌音大酋长:AwAFCAUABAoAAA==.萨满不会飞:AwAECAQABAoAAA==.萨菲洛丝:AwAECAQABRQAAA==.',['�']='蒂法洛可哈特:AwAECAQABRQAAA==.',['�']='蕾西恩:AwAICAoABAoAAA==.',['�']='虚空大君:AwACCAIABRQAAA==.虚空柯基:AwAFCAUABAoAAA==.',['�']='血色月儿:AwACCAIABRQAARIAAAAECAQABRQ=.',['�']='贝児格里尔斯:AwACCAIABRQAAA==.负负得正炫迈:AwAGCAIABRQAARIAAAAICAQABRQ=.贰拾玖:AwAICBIABAoAAA==.',['�']='赤豆粽灬:AwABCAEABRQAAA==.赫尔辛基:AwAFCAUABAoAAA==.',['�']='返璞归真:AwABCAEABAoAAA==.',['�']='酒肉佛:AwAECAgABRQDBAAEAQhFAgBf2k4BBRQABAAEAQhFAgBf2U4BBRQABQAEAQiMBQBLzhkBBRQAAA==.',['�']='醉卧红尘梦:AwACCAIABRQAAA==.',['�']='锅碗瓢盆:AwADCAMABAoAAA==.',['�']='阑珊夜色:AwAECAQABRQAAA==.阿斯塔特:AwAECAQABRQAAA==.阿迪玛斯:AwABCAEABRQAAA==.',['�']='随家仓无赖:AwAHCAEABAoAAA==.',['�']='雪嫩的粉头:AwAFCAIABAoAAA==.雪焰:AwACCAIABAoAAA==.',['�']='风丶楽:AwAECAQABRQAAA==.飘忽若神:AwABCAEABRQAAA==.',['�']='高垣枫:AwAICAgABAoAAA==.',['�']='麟珈:AwABCAEABRQAAA==.',['�']='黑奇仕:AwAICAwABAoAAA==.黑暗的召唤:AwAICAcABAoAAA==.黑涩翅膀:AwAHCAkABAoAAA==.黑魔术师:AwAFCA8ABRQCGAAFAQjpAABTbEcBBRQAGAAFAQjpAABTbEcBBRQAAA==.黑龙如意:AwAGCAgABAoAAA==.黯灭:AwAFCAoABAoAAA==.',['�']='龍天堃:AwABCAIABRQCEwAIAQjIIQAN8BkBBAoAEwAIAQjIIQAN8BkBBAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end