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
 local lookup = {'Warlock-Demonology','Warlock-Affliction','Mage-Fire','Warlock-Destruction','Hunter-Marksmanship','DeathKnight-Blood','DemonHunter-Havoc','DeathKnight-Unholy','Druid-Balance','Druid-Restoration','Paladin-Retribution','Shaman-Restoration','Monk-Mistweaver','Monk-Windwalker','Unknown-Unknown','Hunter-BeastMastery','Druid-Guardian','Hunter-Survival','Paladin-Holy','Warrior-Arms','Warrior-Fury','DemonHunter-Vengeance','Mage-Frost','Shaman-Elemental','Rogue-Assassination','Evoker-Devastation',}; local provider = {region='CN',realm='红云台地',name='CN',type='weekly',zone=42,date='2025-04-14',data={Am='Amitus:AwAECAQABRQAAA==.',Ar='Areyoumad:AwAHCBQABAoDAQAHAQh3FgBIuIcBBAoAAQAGAQh3FgBLLocBBAoAAgABAQhKOAA8aUMABAoAAA==.Armageddon:AwAICAEABAoAAA==.',Av='Avalon:AwAGCAYABAoAAA==.',Ba='Babiwaibu:AwAECAQABRQAAA==.',Bu='Burningsoul:AwAICAgABAoAAA==.',Ch='Chicano:AwACCAIABRQAAA==.Cholo:AwAICA8ABAoAAA==.',Da='Darkbeat:AwAECAUABRQCAwAEAQiiEwA21uoABRQAAwAEAQiiEwA21uoABRQAAA==.',Di='Dilios:AwAECAYABAoAAA==.',Do='Dogz:AwADCAMABRQAAA==.Dovahkiin:AwAGCAoABAoAAA==.',Dr='Drugapple:AwAGCAYABAoAAA==.',Ea='Eakshell:AwAICA4ABAoAAA==.',Em='Emptydh:AwABCAEABAoAAA==.',Es='Estellee:AwABCAEABAoAAA==.',Fi='Fishdk:AwAICAgABAoAAA==.',Fo='Fox:AwAGCAYABAoAAA==.',Gu='Guld:AwAGCAEABAoAAA==.',Hc='Hcce:AwAECAQABAoAAA==.Hctf:AwAECAQABRQAAA==.',Hu='Hurt:AwACCAIABAoAAA==.',Il='Illidansr:AwACCAIABRQAAA==.',Kk='Kkid:AwABCAEABRQEAQAIAQh1BQBf4WMCBAoAAQAHAQh1BQBThGMCBAoABAAFAQjnOQBXOGcBBAoAAgADAQjPFABbpSsBBAoAAA==.',Ky='Kyogre:AwACCAIABAoAAA==.',Ma='Malande:AwAICBAABAoAAA==.',Me='Mehone:AwADCAEABAoAAA==.',Mi='Mieya:AwAGCBcABAoCBQAGAQjSEgBfQwoCBAoABQAGAQjSEgBfQwoCBAoAAA==.Mimomimo:AwAECAcABRQCBgAEAQjwCgA0Wb8ABRQABgAEAQjwCgA0Wb8ABRQAAA==.',My='Mystra:AwAECAgABRQCBwAEAQhtEwAjkN4ABRQABwAEAQhtEwAjkN4ABRQAAQcAK2YGCAYABRQ=.Mythic:AwAECAQABRQAAA==.',Ol='Oldbbee:AwAHCAwABAoAAA==.Oldbeepriest:AwAICA4ABAoAAA==.',Pa='Paradisekis:AwACCAIABRQDBgAIAQj1JwAhHh0BBAoABgAIAQj1JwAdLh0BBAoACAADAQgFkgAng2UABAoAAA==.',Pr='Prisoner:AwAECAQABAoAAA==.',Ra='Rancid:AwAGCAYABAoAAA==.',Re='Redspark:AwABCAIABRQDCQAIAQhPHQBFtDgCBAoACQAHAQhPHQBQhDgCBAoACgAIAQjTKgAt8VQBBAoAAA==.',Sa='Saadiyax:AwABCAEABRQAAA==.',Sh='Shallow:AwAGCAYABAoAAA==.',Sn='Sniper:AwAECAQABRQAAA==.',Th='Throne:AwAGCAsABAoAAA==.',Ti='Ti:AwACCAIABRQAAA==.',Ws='Wst:AwAICAgABAoAAA==.',Ze='Zerond:AwACCAIABAoAAA==.',['�']='一个狗:AwAGCA8ABRQCAwAGAQjLAQBLHdYBBRQAAwAGAQjLAQBLHdYBBRQAAA==.一冰魄一:AwACCAIABAoAAQoAOkwGCAUABRQ=.一只小海龟:AwAGCAoABAoAAA==.一诺倾清:AwACCAIABAoAAA==.七酱:AwAECAQABRQAAA==.三国丶阿斗:AwACCAIABAoAAA==.三角形:AwAICAoABAoAAA==.丶且行且珍惜:AwAFCAUABAoAAA==.丶子墨:AwAICAoABAoAAA==.丶子秋:AwAFCAUABAoAAA==.丶容嬷嬷:AwAECAQABRQAAA==.丶郭源潮:AwABCAEABRQAAA==.丶钢蛋丶:AwAECAQABRQAAA==.丷念老师:AwAECAcABRQCCwAEAQj1FQA9ROwABRQACwAEAQj1FQA9ROwABRQAAA==.为爱情鼓掌:AwAFCAkABAoAAA==.丿訥嗰誰灬:AwACCAIABAoAAA==.',['�']='今天一般般:AwAGCAYABAoAAA==.今晚吃鸡:AwACCAIABAoAAA==.',['�']='伊利雷怒风:AwAFCAQABAoAAA==.',['�']='低语行者:AwABCAEABAoAAA==.佐丹伮:AwAGCAcABAoAAA==.佑佑天天:AwABCAEABAoAAA==.余呆宝:AwAICAgABAoAAA==.你怕是個妖怪:AwADCAEABAoAAA==.你等级没了:AwAECAQABAoAAA==.佳佳哦:AwAICAgABAoAAA==.',['�']='倒拔垂杨柳:AwACCAIABAoAAA==.',['�']='八一零:AwAICBEABAoAAA==.六闪闪三号:AwAECAgABRQCDAAEAQi9BQBIJxQBBRQADAAEAQi9BQBIJxQBBRQAAA==.兰色鸢尾:AwAGCAYABAoAAA==.关你嘛事:AwAECAQABAoAAA==.养乐多:AwAECAQABRQAAA==.兽兽凤舞九天:AwAFCAYABAoAAA==.',['�']='再也不见:AwAGCAYABAoAAA==.冰与果汁哥:AwAHCBAABAoAAA==.冰月黯然:AwABCAEABRQCDAAIAQiNDgBPuWsCBAoADAAIAQiNDgBPuWsCBAoAAA==.冰爽小妖:AwAECAgABRQCAwAEAQj3GAAhUdcABRQAAwAEAQj3GAAhUdcABRQAAA==.',['�']='凸皿凸:AwAECAQABRQAAA==.',['�']='别动那个菜菜:AwAHCBIABAoAAA==.刺日:AwAECAQABRQAAA==.',['�']='剑魔谢云流:AwAICAgABAoAAA==.',['�']='勾魂大宝贝:AwAHCBoABAoCCQAHAQidMQBEgMQBBAoACQAHAQidMQBEgMQBBAoAAA==.',['�']='包纸酱:AwAECAQABRQAAA==.',['�']='千变万化牛:AwAFCAkABAoAAA==.午夜蹈花香:AwAFCAUABAoAAA==.卖艺小栗子:AwAECAIABRQAAA==.',['�']='又何妨:AwAICAgABAoAAQMAVEsICBAABRQ=.口休口休口休:AwAFCAUABAoAAA==.古伊尔丶:AwADCAMABRQAAA==.',['�']='吃个佛跳强:AwAICBEABAoAAA==.君莫言丶:AwABCAEABAoAAA==.吸血:AwEDCAoABRQCDQADAQgxBwBLYA4BBRQADQADAQgxBwBLYA4BBRQAAA==.',['�']='呂师傅:AwAGCA8ABAoAAA==.呜啦哇咔咔丶:AwAECAQABAoAAA==.',['�']='咔咔萌萌哒丶:AwAHCBkABAoDDgAHAQimJQAzQ4cBBAoADgAHAQimJQAzQ4cBBAoADQAEAQjnZQAvnYkABAoAAA==.咸鱼术:AwAECAgABRQDAgAEAQi4EAA094EABRQAAgAEAQi4EAA094EABRQABAACAQjcHgAZ8WYABRQAAQ8AAAAGCAIABRQ=.',['�']='喵了个咪:AwABCAEABAoAAA==.喵喵兽:AwAGCAIABRQAAA==.喵喵紫豆:AwAECAQABRQAAA==.',['�']='四月谎言丶:AwAECAMABRQDEAAIAQgpMgBMUAcCBAoAEAAIAQgpMgBMUAcCBAoABQABAQi3bwAoDS0ABAoAAA==.因幡帝丶:AwAECAQABRQAAA==.',['�']='墨染幽:AwABCAEABAoAAA==.墨雨烟云:AwABCAEABAoAAA==.',['�']='夜枭丶达摩:AwACCAEABAoAAA==.夜薄樱:AwAFCAUABAoAAA==.大中之争:AwAECAUABAoAAA==.大耳朵胡妮:AwAICAgABAoAAA==.大表哥灬阿凌:AwABCAEABRQAAA==.天然灬呆:AwABCAMABRQECQAIAQifQwAybHIBBAoACQAHAQifQwA0RHIBBAoAEQAFAQgbGQAhyp0ABAoACgAEAQj0UwAujpYABAoAAA==.头顶一朵花:AwADCAMABAoAAA==.夹心酱本酱丶:AwAICAYABAoAAA==.',['�']='奈斯丶:AwABCAEABRQAAA==.',['�']='妳太善良:AwACCAIABAoAAA==.',['�']='子路的路人:AwADCAMABAoAAA==.',['�']='宋恩彩:AwABCAEABAoAAA==.宝钟玛琳:AwAGCBAABAoAAA==.',['�']='射丶汇摇:AwAECAQABRQDBQAHAQgZGQBJac4BBAoABQAHAQgZGQBI9M4BBAoAEgAEAQhhEgBAWpUABAoAAA==.射鸡猎:AwACCAIABRQAAA==.小乌龟啊:AwAICAgABAoAAA==.小依露:AwAHCAoABAoAAA==.小奶牛姐姐:AwAGCAoABAoAAA==.小心:AwAFCAUABAoAAA==.小猎豹一个鑫:AwAICAwABAoAAA==.小红手传人:AwAGCAYABAoAAA==.',['�']='岁月静好:AwAFCAYABAoAAA==.',['�']='左手冰右手火:AwAGCAoABRQCAwAGAQi4AgA2Sa0BBRQAAwAGAQi4AgA2Sa0BBRQAAA==.',['�']='布丁萨满:AwAICBUABAoCDAAIAQgbNAA16Y8BBAoADAAIAQgbNAA16Y8BBAoAARMAVfAICBkABRQ=.帝波:AwACCAIABRQAAA==.',['�']='弓腰驼背灬:AwAECAQABRQAAA==.弗乌尔:AwAECAQABAoAAA==.张歆艺:AwAHCAcABAoAAA==.张解放:AwAICA4ABAoAAA==.强了吧唧的兽:AwAICAMABAoAAA==.',['�']='彼方丶阿修羅:AwAECAQABRQAAA==.彼静阅兮:AwAICAEABAoAAA==.',['�']='得意地小德:AwAICAgABAoAAA==.德斧纵享撕划:AwAHCAgABAoAAA==.',['�']='忆尘:AwAFCAUABAoAAA==.志村新八:AwAGCAYABRQCAwAGAQi0AQBExdoBBRQAAwAGAQi0AQBExdoBBRQAAA==.',['�']='恰似一抹柔情:AwAICA0ABAoAAA==.恶魔审判庭:AwAGCAYABRQCBwAGAQivAQAtNa4BBRQABwAGAQivAQAtNa4BBRQAAA==.',['�']='悔恨边缘:AwAGCAYABAoAAA==.',['�']='惩戒野怪:AwAFCAEABAoAAA==.想得美:AwACCAMABAoAAA==.',['�']='愤怒的图腾:AwAECAQABRQAAA==.',['�']='慕丶颜颜:AwAECAQABRQAAA==.慕容丶雪:AwAGCAYABAoAAA==.',['�']='懒得偷懒得:AwADCAgABRQCDAADAQgXAgBdd0QBBRQADAADAQgXAgBdd0QBBRQAAA==.',['�']='我叫森哥:AwAFCAQABAoAAA==.我想呼风唤雨:AwAECAMABRQAAA==.我是豆子:AwAFCAUABAoAAQ8AAAAHCBEABAo=.我有尼哥:AwAICAgABAoAAA==.我要喝奶茶:AwACCAIABAoAAA==.我遭不住佬:AwAICAwABAoAAA==.战丶:AwAICAgABAoAAA==.戥丶待:AwAECAQABAoAAA==.',['�']='抱抱丶别走:AwAICAoABAoAAA==.抱抱丶宝宝:AwAICBAABAoAAA==.',['�']='撕点纸给我:AwAGCAYABRQCFAAGAQhIAABA9N4BBRQAFAAGAQhIAABA9N4BBRQAAA==.撮把子:AwACCAYABAoAAA==.',['�']='断念骑士:AwAHCAEABAoAAA==.',['�']='旋风龙卷风:AwACCAMABRQCFQAIAQgvKwAmc70BBAoAFQAIAQgvKwAmc70BBAoAAA==.无事过一日:AwAECAQABRQAAA==.无厌:AwADCAMABAoAAQ8AAAAECAQABRQ=.无尽狂怒:AwAECAQABAoAAA==.无敌软绵绵丶:AwAGCAYABAoAAA==.无聊分子:AwAGCAsABAoAAQ8AAAABCAIABRQ=.日子过上了:AwAECAYABRQDBwAEAQg/EwAjbN8ABRQABwAEAQg/EwAjbN8ABRQAFgACAQjcDgAPjV4ABRQAAQ4AWZcGCBkABRQ=.',['�']='春丽丶降龙掌:AwAICAgABAoAAA==.是我惹不起:AwABCAEABRQAAA==.',['�']='曲非烟:AwAFCAMABAoAAA==.曾经的法神:AwABCAEABRQDAwAIAQg/LQA6uNkBBAoAAwAIAQg/LQA3FtkBBAoAFwAGAQgYSwAypQgBBAoAAA==.',['�']='朵黎:AwAFCAUABAoAAQ8AAAAGCAYABAo=.',['�']='根本吃不饱呀:AwACCAQABRQAAA==.',['�']='桂言葉:AwAICBEABAoAAA==.',['�']='梦聆听雪:AwAICAgABAoAAA==.梦魇血铃舞:AwAICBAABAoAAQ8AAAAICBAABAo=.',['�']='樱岛麻衣:AwAFCAYABAoAAA==.',['�']='橙蝶衣:AwAICAcABAoAAA==.',['�']='此生丶逍遥:AwABCAIABRQDAgAIAQi6GgAkLfYABAoAAgAGAQi6GgAfCvYABAoABAAGAQhIVgAb2e8ABAoAAA==.武穆:AwAGCAkABAoAAA==.武豪:AwAGCAcABAoAAA==.歹歹:AwAICBYABAoCCAAIAQgJMwAydrQBBAoACAAIAQgJMwAydrQBBAoAAA==.死亡与我同行:AwAECAQABRQAAA==.',['�']='殉葬者:AwAFCA0ABAoAAA==.',['�']='毋忘我:AwABCAEABRQCFQAIAQgDHgA79AoCBAoAFQAIAQgDHgA79AoCBAoAAA==.',['�']='汉阳苏有朋:AwABCAEABRQAAA==.',['�']='没门走窗:AwABCAIABRQAAA==.沧笙踏歌:AwAGCA4ABAoAAA==.',['�']='泷宵:AwAECAQABRQAAA==.',['�']='洗墨鲲锋:AwAECAQABRQAAA==.',['�']='浴血伯爵:AwAECAQABRQAAA==.海狸丶欧:AwAICAgABAoAAA==.',['�']='淡然审判:AwAECAQABRQAAA==.深海星渊:AwAECAUABAoAAA==.',['�']='清纯男高中生:AwAHCAcABAoAAA==.游离三界:AwACCAMABRQCBAAIAQhJEQBHEFICBAoABAAIAQhJEQBHEFICBAoAAA==.',['�']='灬訥嗰誰灬:AwABCAEABRQAAA==.灭世极光:AwADCAcABRQCFwADAQiaBQA14ewABRQAFwADAQiaBQA14ewABRQAAA==.',['�']='烈日阳阳:AwAGCAoABAoAAA==.',['�']='無憎:AwAFCAcABRQCDQAFAQiCAgA9T3IBBRQADQAFAQiCAgA9T3IBBRQAAA==.',['�']='熊大师:AwACCAYABRQCDgACAQisDQBAcp0ABRQADgACAQisDQBAcp0ABRQAAA==.',['�']='燚焱丨炎火:AwAFCAUABAoAAA==.',['�']='爪爪蛤:AwAHCBIABAoAAA==.爱你很认真:AwAFCAgABAoAAA==.爱莉:AwAICBMABAoAAA==.爻灬爻:AwACCAEABRQAAA==.',['�']='版本答案:AwAICAgABAoAAA==.牛盾丶血蹄:AwADCAMABAoAAA==.牛草花:AwAECAYABAoAAA==.牧薯粉:AwAHCAcABAoAAA==.',['�']='犹大的杀戮:AwAICA4ABAoAAA==.',['�']='猛牛乳酸酸:AwAECAYABAoAAA==.',['�']='玉剑传说:AwACCAIABRQAAA==.王哈哈丶:AwAECAYABRQCAwAEAQhoEwA95uoABRQAAwAEAQhoEwA95uoABRQAAA==.',['�']='瓶邪:AwAICAIABAoAAA==.',['�']='男不听七友丶:AwABCAEABAoAAA==.',['�']='留技能抢人头:AwAICAgABAoAAA==.略颦轻笑:AwADCAMABAoAAA==.',['�']='白允:AwABCAEABAoAAA==.',['�']='睡神修普诺斯:AwABCAEABAoAAA==.',['�']='矮小的狐狐:AwAICBcABAoDGAAIAQj0EABZGkQCBAoAGAAIAQj0EABZGkQCBAoADAAIAQgNPwAqcGMBBAoAAA==.',['�']='碎梦星河:AwAGCAcABAoAAA==.碑林区红手王:AwABCAEABAoAAA==.',['�']='神皇:AwACCAIABAoAAA==.',['�']='箐谛丶:AwABCAEABAoAAA==.箫别离:AwAECAwABRQCBgAEAQj+BwA5vuIABRQABgAEAQj+BwA5vuIABRQAAA==.',['�']='米凯拉的锋刃:AwAHCAcABAoAAA==.米凯菈的锋刃:AwAECAQABRQAAA==.米线锅锅:AwAGCAYABAoAAA==.',['�']='糖豆包:AwAECAQABAoAAQ8AAAAGCAYABAo=.',['�']='紫轩丶小贱:AwAECAQABRQAAA==.',['�']='絕對領域大師:AwABCAEABAoAAA==.',['�']='练习了两年半:AwAGCAYABAoAAA==.织雾:AwABCAEABAoAAA==.终极老大:AwACCAMABAoAAA==.给你四刀:AwAECAgABRQCGQAEAQg8AwBUzx4BBRQAGQAEAQg8AwBUzx4BBRQAAA==.',['�']='罗什巴赫:AwABCAEABRQAAA==.',['�']='老猫大夫:AwACCAEABRQAAA==.',['�']='肥胖光环:AwACCAIABAoAAA==.肺里痒痒的:AwACCAIABAoAAA==.',['�']='胸胸惹人爱:AwACCAIABRQAAQoAOkwGCAUABRQ=.',['�']='致命红色苍蝇:AwAFCAUABAoAAA==.致命胸器:AwAGCAYABRQCDQAGAQgHAgAdiooBBRQADQAGAQgHAgAdiooBBRQAAA==.',['�']='舞动的旋律:AwAECAQABAoAAA==.',['�']='艾尼德尤:AwAECAEABRQAAA==.',['�']='芃芃其晨:AwACCAEABAoAAA==.花稚的男朋友:AwAECAQABRQAAA==.',['�']='莲之深海姐妹:AwACCAIABRQAAA==.',['�']='萧萧瑟:AwAECAUABRQCAwAEAQgGFwA6c94ABRQAAwAEAQgGFwA6c94ABRQAAA==.萨小蛮:AwAICBIABAoAAA==.落丶梦:AwACCAIABRQAAA==.',['�']='蒙牛乳酸酸:AwAICAwABAoAAA==.蒲公英的缱绻:AwAICBgABAoDBgAIAQh6DwBRfxMCBAoABgAIAQh6DwBN1xMCBAoACAAHAQiWKgBHVtwBBAoAAA==.',['�']='蕉小蛙:AwAHCBQABAoCEwAHAQh7BABhCo0CBAoAEwAHAQh7BABhCo0CBAoAAA==.',['�']='血兽来了:AwACCAQABRQAAA==.行了你别说了:AwADCAMABAoAAA==.街角的小歆:AwAECAQABRQAAQ8AAAAGCAQABRQ=.',['�']='裂人丶:AwAICA4ABAoAAA==.',['�']='謎謎糊糊:AwAICA0ABAoAAA==.',['�']='诗桃:AwABCAEABRQAAA==.该隐的左手:AwADCAMABAoAAA==.说哀木踢在哪:AwAICAgABAoAAA==.请叫我阿喵:AwABCAEABRQCBwAIAQgOKgA2keoBBAoABwAIAQgOKgA2keoBBAoAAA==.',['�']='贝伦赛丽:AwABCAEABRQAAA==.贪吃的牛小心:AwAHCAcABAoAAA==.',['�']='赵丽颖:AwAFCAUABAoAAA==.',['�']='超大屁屁酱:AwAICAgABAoAAA==.超爱吃可丽饼:AwAICAkABAoAAA==.',['�']='踏血至山巅:AwAICAgABAoAAA==.',['�']='蹬足特:AwAGCAYABAoAAA==.',['�']='过去已过去:AwAICAsABRQDBQAIAQg1AABV0sABBRQABQAEAQg1AABcysABBRQAEAAEAQjmEABMh/UABRQAAA==.进击的奶萨:AwACCAIABAoAARoAD08ICAUABRQ=.',['�']='逆天小西瓜:AwABCAEABAoAAA==.选择丶萨满:AwAECAQABRQAAA==.逍遥肖云:AwAGCAoABAoAAA==.',['�']='那个七十:AwACCAIABAoAAA==.',['�']='野猪:AwAICAIABAoAAA==.',['�']='银河:AwABCAEABAoAAA==.',['�']='闪现踩香蕉:AwACCAQABRQAAA==.',['�']='阿僧:AwABCAEABRQAAA==.阿克懵德:AwAGCAcABAoAAA==.阿凌灬法:AwAFCAQABAoAAA==.阿初:AwADCAMABRQAAA==.阿尔伊莉斯:AwAHCBEABAoAAA==.阿尔哞莉斯:AwAECAQABAoAAA==.阿尔影莉斯:AwACCAIABAoAAA==.阿尔撒尿:AwACCAIABAoAAA==.阿拉斯加海湾:AwAFCAUABAoAAA==.阿灬河:AwABCAEABRQAAA==.阿狸塔:AwAECAIABRQAAA==.阿莫西林法特:AwADCAMABAoAAA==.阿蛮:AwACCAIABRQAAA==.',['�']='陆扶光:AwAECAQABRQAAQ8AAAAFCAMABRQ=.陈陈噜:AwADCAMABAoAAA==.陪你看流星雨:AwACCAIABAoAAA==.',['�']='隂天快乐:AwAICA4ABAoAAA==.',['�']='雪小潴:AwAECAQABAoAAA==.',['�']='青涩灵魂:AwABCAEABRQAAQ0AIA0ICAMABRQ=.',['�']='风中花絮:AwABCAEABAoAAA==.',['�']='高大智:AwAECAQABRQAAA==.髙圆圆:AwAGCAcABAoAAA==.',['�']='鸢尾花:AwAGCAYABAoAAA==.鸭儿抹花椒:AwAGCAUABAoAAA==.',['�']='黑喵警长:AwAICAoABAoAAQoAOskICAgABRQ=.',['�']='龙泽萝拉:AwACCAIABRQAAA==.龙猫饺子:AwAECAQABRQAAA==.龟壳假死:AwAECAIABRQAAQ8AAAAICAIABRQ=.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end