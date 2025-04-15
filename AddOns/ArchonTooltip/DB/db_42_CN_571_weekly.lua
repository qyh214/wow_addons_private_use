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
 local lookup = {'Shaman-Restoration','Unknown-Unknown','Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Blood','Evoker-Devastation','Evoker-Preservation','Hunter-BeastMastery','Priest-Shadow','Paladin-Protection','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Warrior-Protection','Warrior-Fury','Druid-Balance','Priest-Holy','Priest-Discipline','Mage-Fire','Warrior-Arms','DeathKnight-Frost','Druid-Guardian','Mage-Frost','Shaman-Enhancement','Rogue-Assassination','Warlock-Demonology','DemonHunter-Havoc','Druid-Feral','Hunter-Marksmanship','Druid-Restoration','Warlock-Destruction','Paladin-Holy','DemonHunter-Vengeance','Warlock-Affliction','Shaman-Elemental',}; local provider = {region='CN',realm='伊瑟拉',name='CN',type='weekly',zone=42,date='2025-04-14',data={An='Andres:AwABCAIABRQCAQAIAQglFABJWT8CBAoAAQAIAQglFABJWT8CBAoAAA==.',Ch='Cheng:AwAHCA0ABAoAAA==.',Do='Doubao:AwABCAEABRQAAA==.',Dr='Dress:AwAECAMABAoAAA==.',Eg='Ego:AwAICAoABAoAAA==.',El='Elevenn:AwAECAQABRQAAQIAAAAGCAIABRQ=.Elevone:AwACCAIABAoAAA==.',Em='Ember:AwACCAYABRQCAwACAQhBLgAeTIgABRQAAwACAQhBLgAeTIgABRQAAA==.',Ff='Ff:AwAICAgABAoAAA==.',Ga='Gawain:AwAICA8ABAoAAA==.',Ha='Havocc:AwACCAIABRQAAA==.',Hi='Hillelena:AwAHCBUABAoCAwAHAQjESwBDgusBBAoAAwAHAQjESwBDgusBBAoAAA==.',Ji='Jinbao:AwAECAQABRQAAA==.',Jo='Jonyy:AwADCAcABRQCAwADAQjmFwAteuUABRQAAwADAQjmFwAteuUABRQAAA==.',La='Lastpraye:AwAGCBAABAoAAA==.',Li='Lilis:AwACCAYABRQCBAACAQgdFwAx2JkABRQABAACAQgdFwAx2JkABRQAAA==.Limbus:AwAECAgABRQDBQAEAQhYBABWbiUBBRQABQAEAQhYBABWbiUBBRQABAAEAQhDEwANfq4ABRQAAQIAAAAGCAQABRQ=.',Ma='Malageb:AwAFCAYABAoAAA==.Marcusfenix:AwACCAIABRQAAA==.',Mi='Midone:AwAICAgABAoAAA==.',Oa='Oac:AwAGCAoABRQDBgAGAQhOAgBBN2QBBRQABgAFAQhOAgBMhGQBBRQABwABAQh3BgBguHEABRQAAQgAKokICAIABRQ=.',Ob='Oblivionis:AwAGCBgABRQCCQAGAQhKAABajhoCBRQACQAGAQhKAABajhoCBRQAAA==.',Pa='Palace:AwAHCBEABAoAAA==.',Re='Respsga:AwAICBYABAoDCgAIAQi9GAApSXABBAoACgAIAQi9GAApSXABBAoAAwABAQjZWwEV1iQABAoAAA==.',Se='Seanat:AwAHCA0ABAoAAA==.',So='Solomom:AwAGCAoABRQDCwAGAQizAABDOfEBBRQACwAGAQizAABDOfEBBRQADAADAQh6DwAf/9MABRQAAA==.Solor:AwACCAIABAoAAA==.',Th='Thorin:AwAGCAEABAoAAQgAKokICAIABRQ=.',Ty='Typhos:AwABCAIABRQAAA==.',Yi='Yingdi:AwAECAQABRQAAA==.',Yu='Yuyuyu:AwAICA8ABAoAAQ0ASg0BCAIABRQ=.',Za='Zartu:AwAECAMABAoAAQ0ASg0BCAIABRQ=.',['�']='一路向北:AwAGCAYABRQCDgAGAQiMAAApIWQBBRQADgAGAQiMAAApIWQBBRQAAA==.专切豆腐:AwAHCAcABAoAAA==.丫头瑟兰迪尔:AwAECAQABRQAAA==.丶云枫:AwAECAQABRQAAA==.丶云碎:AwAECAQABRQAAA==.丿剑客丿:AwAFCAYABAoAAA==.丿甄苾:AwAECAQABRQAAA==.',['�']='乌翰隆:AwAGCAYABAoAAA==.乙醇方丈:AwACCAIABAoAAA==.九阵风:AwADCAMABRQAAQgAWX0DCAoABRQ=.',['�']='人不如故:AwABCAIABRQAAQwAQnAHCAwABRQ=.',['�']='仁芹井菜:AwAHCA0ABAoAAA==.从不奶人:AwABCAIABRQAAA==.',['�']='你呷嘞:AwAECAgABRQCDwAEAQhDCQBAkAoBBRQADwAEAQhDCQBAkAoBBRQAAA==.',['�']='依瑟萨斯:AwABCAIABRQCBQAHAQgeJwAriiMBBAoABQAHAQgeJwAriiMBBAoAAA==.',['�']='信仰圣光吧:AwAICAgABAoAAQQAVm4ECAgABRQ=.',['�']='傲世小春:AwADCAsABRQCEAADAQipHwAgI4EABRQAEAADAQipHwAgI4EABRQAAA==.',['�']='光舞倾城:AwAGCAYABAoAAA==.克里丝汀娜:AwADCAUABAoAAA==.兔美酱:AwACCAYABRQDEQACAQjWGQAnNUIABRQAEQABAQjWGQA7lEIABRQAEgABAQg9HgAS1UAABRQAAA==.入洞吐痰僧:AwABCAEABRQAAA==.八十一锤:AwAICAgABAoAAA==.',['�']='冰若雨:AwAICBcABAoCEwAIAQgxQwArfmABBAoAEwAIAQgxQwArfmABBAoAAA==.冷傲孤霜:AwAECAQABRQAAA==.',['�']='凋零的心:AwADCAQABRQCBAADAQjiEwArpaoABRQABAADAQjiEwArpaoABRQAAA==.凌霄:AwAECAgABRQDDwAEAQjHDAA2U/cABRQADwAEAQjHDAAxmfcABRQAFAACAQhmDAAtzo8ABRQAAA==.',['�']='刚须:AwAICAgABAoAAA==.',['�']='剑光茹虹:AwAGCAkABAoAAA==.',['�']='匆匆灬那年:AwAICBQABAoEBQAIAQiyGAA2BqUBBAoABQAIAQiyGAA2BqUBBAoABAAGAQjkaAAWmt8ABAoAFQABAQhcMAAbZiYABAoAAA==.',['�']='卡雷拉:AwAECAQABRQCAwAIAQhBEgBcI70CBAoAAwAIAQhBEgBcI70CBAoAAA==.',['�']='只说实话:AwADCAMABRQAAA==.可子:AwABCAEABRQAAA==.',['�']='吃瓜的群众:AwADCAkABRQCFgADAQjNAQAqT6gABRQAFgADAQjNAQAqT6gABRQAAA==.吃饱没事做:AwAECAQABRQCFwAIAQi7AwBd++wCBAoAFwAIAQi7AwBd++wCBAoAARMAJ70GCAoABRQ=.吴子敬:AwABCAIABRQCFAAIAQjTCgBNsFUCBAoAFAAIAQjTCgBNsFUCBAoAAA==.吴行的小秘:AwAECAQABRQAAA==.',['�']='咕咕牛:AwACCAIABRQAAA==.',['�']='哈基米德:AwAICBAABAoAAA==.哐哐响:AwABCAEABRQAARgAPUUFCBMABRQ=.',['�']='唐圣骑:AwAICA4ABAoAAA==.',['�']='喂喂:AwAECAQABRQAAA==.',['�']='噵丶戢:AwAECAYABAoAAA==.',['�']='团部副班长:AwAICAgABAoAAA==.',['�']='圣光之歌者:AwACCAIABAoAAA==.圣女贞狄:AwAFCAkABAoAAA==.在职老大爷:AwACCAIABRQAAA==.',['�']='埃斯蒂尼危:AwAGCAcABAoAAQ0ASg0BCAIABRQ=.',['�']='塃弇貓:AwAECAgABRQCGQAEAQjkBABKgggBBRQAGQAEAQjkBABKgggBBRQAARoAOgUGCAgABRQ=.塔罗斯:AwACCAIABAoAAA==.',['�']='墨子丶辰:AwAHCAcABAoAAA==.',['�']='复仇在我:AwABCAMABRQCGwAIAQjnDgBWiJ0CBAoAGwAIAQjnDgBWiJ0CBAoAAA==.夜乌龙:AwAICAgABAoAAQIAAAAECAQABRQ=.夜家阿风:AwAECAQABRQCEAAEAQjfFAAlPMYABRQAEAAEAQjfFAAlPMYABRQAAA==.大家都看见:AwAHCBEABAoAAA==.天未老情难绝:AwABCAEABAoAAA==.天空制裁:AwADCAMABAoAAA==.天赐丶小尤:AwAGCAYABAoAAA==.',['�']='奇摩基:AwABCAIABRQCHAAHAQg2CgBIxvEBBAoAHAAHAQg2CgBIxvEBBAoAAA==.奎尔瑟兰:AwAECAMABAoAARsARvwGCAoABRQ=.奥利弗安德鲁:AwABCAEABAoAAA==.奥勒利亚:AwAFCAUABAoAAA==.女月甩尾:AwAICA4ABAoAAA==.好大的猕猴桃:AwADCAwABRQDCAADAQjwEgBC8u4ABRQACAADAQjwEgA6s+4ABRQAHQABAQiQFQBVfGQABRQAAA==.',['�']='妳猜是谁:AwAECAYABRQDHQAEAQgvCgA6kdUABRQAHQAEAQgvCgAyG9UABRQACAACAQhQJQBBBJQABRQAAA==.',['�']='姆指纤儿:AwAICAgABAoAAA==.',['�']='字母横行:AwAECAcABAoAAA==.',['�']='宝批龙骑士:AwAICA4ABAoAAA==.',['�']='寶貝婷婷:AwAECAgABRQDBAAEAQhIBABWbikBBRQABAAEAQhIBABWbikBBRQABQAEAQhdDAAqQbQABRQAAA==.',['�']='小天鹅洗衣機:AwACCAIABAoAAA==.小姑娘快跑啊:AwAFCAgABAoAAA==.小科比肘妈妈:AwAGCAQABRQAAA==.小虾米:AwABCAIABRQAAA==.小西瓜:AwAECAQABRQAAA==.尛尛沫:AwAECAQABRQAAA==.尼不知道的事:AwAGCAoABAoAAA==.尼古拉斯刘能:AwAECAQABRQAAA==.尼古拉斯维其:AwAFCAUABAoAAA==.尼尤呢矮:AwABCAEABAoAAA==.',['�']='山色有無中:AwAFCA0ABRQCEwAFAQjdBABAr14BBRQAEwAFAQjdBABAr14BBRQAAA==.',['�']='帅夫斯基:AwACCAQABRQCCAAIAQgiLwBG5RYCBAoACAAIAQgiLwBG5RYCBAoAAA==.',['�']='库萨逹欧拉:AwAHCAgABAoAAA==.库萨里奥:AwABCAIABRQAAA==.',['�']='开车的老阿訇:AwACCAQABRQAAA==.弄花香满衣:AwAICAgABAoAAA==.弗甲:AwACCAMABAoAAA==.',['�']='待兼诗歌剧:AwADCAcABRQCAwADAQjnCwBPhBABBRQAAwADAQjnCwBPhBABBRQAAA==.德不偿命:AwAECAgABRQCHgAEAQh4CQAghcEABRQAHgAEAQh4CQAghcEABRQAAA==.',['�']='忧郁的夏天:AwABCAEABRQDAwAIAQiobgAtI5UBBAoAAwAIAQiobgAtI5UBBAoACgAIAQhbLQALt8MABAoAAA==.',['�']='悠然潇洒:AwAECAQABRQAAA==.您不配:AwAGCAYABRQCCQAGAQj7AQAub5kBBRQACQAGAQj7AQAub5kBBRQAAA==.',['�']='慢性哀伤:AwAFCAYABAoAAA==.慧儿:AwAECAQABRQAAA==.',['�']='戴老师:AwAGCAYABAoAAA==.',['�']='打野小萌新:AwABCAEABRQAAA==.',['�']='挽救灵魂之神:AwAECAgABRQCEgAEAQhrBgBPHgYBBRQAEgAEAQhrBgBPHgYBBRQAAA==.',['�']='提里奥弗饼:AwAICAgABAoAAA==.',['�']='收废旧的小猫:AwAICAcABAoAAA==.',['�']='文夕大火:AwACCAIABAoAAA==.新新:AwADCAYABRQCHwADAQi7DwAffMoABRQAHwADAQi7DwAffMoABRQAAA==.方言:AwABCAEABAoAAA==.',['�']='无字天书:AwADCAMABAoAAA==.',['�']='星术无痕:AwAICAgABAoAAA==.星落之武:AwAGCAsABAoAAA==.星落之风:AwABCAEABRQDHgAIAQjbHwA7X54BBAoAHgAHAQjbHwA6b54BBAoAEAAIAQiPQQAha3oBBAoAAA==.星辰降落之歌:AwADCAgABRQDCgADAQj/BQA2edMABRQACgADAQj/BQA2edMABRQAAwACAQiiLgAbQIYABRQAAA==.是爬海啊丶:AwAFCBQABRQDIAAFAQjMAwA/SfkABRQAIAAEAQjMAwAzIfkABRQAAwABAQg8OQAU+k0ABRQAAA==.',['�']='晓月微星:AwAECAoABRQDEAAEAQihCwA+/PkABRQAEAAEAQihCwA+/PkABRQAHgACAQijEQAj5ncABRQAAA==.晨行者伯恩:AwAICBMABAoAAA==.晶晶甜甜虎:AwADCAMABAoAAA==.',['�']='暗影之焱:AwAECAQABRQAAR8ASvQICBMABRQ=.暗雪飘香:AwACCAIABAoAAA==.暴食貓:AwAECAIABRQDEQAIAQjUHAA/scoBBAoAEQAIAQjUHAA7IcoBBAoAEgAHAQikJAA2oH8BBAoAAA==.',['�']='曉辫子:AwAICAgABAoAAA==.曦子:AwADCAUABAoAAA==.',['�']='月小京:AwAECAQABAoAAA==.月落乌啼:AwAECAoABRQCAwAEAQjvGAAwieIABRQAAwAEAQjvGAAwieIABRQAAA==.月飒:AwAFCAYABAoAAA==.望朔:AwAICAgABAoAAA==.朝阳区少年:AwABCAIABRQAARYAKk8DCAkABRQ=.木子:AwAICAwABAoAAA==.',['�']='枕水江南:AwACCAYABRQCCAACAQjRHwBGX6QABRQACAACAQjRHwBGX6QABRQAAA==.林中小雨:AwAHCA4ABAoAAA==.枯焰生花:AwADCAUABRQCHwADAQiJEQAXqL0ABRQAHwADAQiJEQAXqL0ABRQAAA==.',['�']='柔风细雨:AwACCAQABRQAAA==.柠檬味咖啡:AwADCAkABRQCFwADAQj0BAA8DfYABRQAFwADAQj0BAA8DfYABRQAAA==.',['�']='栖息:AwAECA4ABRQDGwAEAQi1BQBX5CwBBRQAGwAEAQi1BQBX5CwBBRQAIQABAQgFFgAGqicABRQAAA==.格乌恩:AwACCAQABRQAAA==.',['�']='歌酒月明前:AwABCAEABRQAAA==.正镔:AwAHCA8ABAoAAA==.',['�']='毛手毛脚:AwADCAMABAoAAA==.',['�']='泰蓝的雨:AwAFCAYABAoAAA==.',['�']='洗洗睡吧丶:AwAHCAsABAoAAA==.',['�']='涂山红红:AwAICAEABAoAAA==.',['�']='淡定自若:AwAECAQABRQAAA==.淡雅观世音:AwAHCAIABAoAAA==.淼洋:AwAECAQABRQAAA==.',['�']='清泉流响丶:AwAICAgABAoAAA==.清风逐影:AwAECAUABRQDHQAEAQiQBgBBmfIABRQAHQAEAQiQBgBBmfIABRQACAABAQgIOQA0tkYABRQAAA==.',['�']='湛蓝丶火羽:AwABCAEABAoAAA==.',['�']='澤拉圖:AwAICAoABAoAAA==.',['�']='灌木丛之心:AwAICBIABAoAAA==.灰月轻:AwADCAMABAoAAA==.',['�']='炀煽:AwAICA4ABAoAAA==.炽翼天使:AwAFCAoABAoAAA==.',['�']='烧烤啤酒:AwAICAgABAoAAQsALVwGCAoABRQ=.',['�']='狂野提里奥:AwAECAQABRQAAA==.',['�']='猎魔一二三:AwAICAgABAoAAA==.猪会飞:AwADCAUABAoAAA==.',['�']='玫瑰骑士:AwAECAQABRQAAA==.',['�']='疼丁狗:AwAFCAUABAoAAA==.',['�']='瘌痢头拉尼子:AwAICBMABAoAAR8AOLwGCAUABRQ=.',['�']='白小凡:AwAECAcABAoAAA==.百思特灬:AwACCAIABRQAAA==.',['�']='碗锅:AwADCAoABRQDCAADAQggCgBZfRYBBRQACAADAQggCgBJiBYBBRQAHQABAQgGFQBa4WoABRQAAA==.',['�']='神之迷茫:AwADCAUABAoAAA==.神圣赞美诗丶:AwAICA0ABAoAAA==.',['�']='离我十一步:AwAGCAYABAoAAA==.',['�']='秋山澪:AwAECAQABRQAAA==.',['�']='空条乁徐伦:AwABCAEABRQAAA==.',['�']='第五词缀:AwADCAMABRQAAA==.',['�']='米子哈:AwABCAIABRQEDQAHAQgQCABKDcoBBAoADQAGAQgQCABTusoBBAoADAAEAQj7QABWYRkBBAoACwABAQiZaAAZqzcABAoAAA==.',['�']='紫蝶灬小魔仙:AwADCAIABAoAAA==.',['�']='红叶老师:AwABCAEABRQAAA==.纵馬江湖畔:AwAHCBcABAoCBAAHAQi0JgBJxfABBAoABAAHAQi0JgBJxfABBAoAAA==.',['�']='经典工艺:AwADCAMABAoAAA==.绚辻词:AwACCAQABRQDHwAIAQg2CQBav5gCBAoAHwAIAQg2CQBav5gCBAoAIgABAQhpNgBEIkwABAoAAA==.',['�']='罗穆露丝:AwAGCAsABAoAAA==.',['�']='艾姬多娜:AwAECA8ABRQDEQAEAQhSDgBAFZgABRQAEgACAQjbDwBUBK0ABRQAEQADAQhSDgAuWpgABRQAAA==.',['�']='芝华士:AwACCAIABRQAAA==.芳心纵火萨:AwACCAYABRQDIwACAQheDQAw/5UABRQAIwACAQheDQAw/5UABRQAAQACAQj6GQArY48ABRQAAA==.',['�']='苹果:AwABCAMABRQEEQAIAQjPDQBOskYCBAoAEQAHAQjPDQBWikYCBAoACQAGAQgFJgA/+34BBAoAEgABAQgejwAAAAAABAoAAA==.',['�']='茱莉娅丶晨星:AwAICAMABAoAAA==.',['�']='莉亚尔:AwAFCAMABRQAAA==.莉法莉亚:AwAICA8ABAoAAA==.莫离:AwABCAEABAoAAA==.',['�']='菊门廷尉:AwAECAQABRQAAA==.菊门提刑:AwAECAgABRQDBQAEAQg5CABAa98ABRQABAAEAQipCgA6K/MABRQABQAEAQg5CABAa98ABRQAAA==.',['�']='蓝海灵:AwACCAMABRQDCAAIAQiLTwA2GpcBBAoACAAIAQiLTwA0YZcBBAoAHQADAQj/QwA9gsEABAoAAA==.蓝色灬星辰:AwAICAgABAoAAA==.',['�']='被告请坐下:AwAECAQABRQAAQIAAAAGCAQABRQ=.',['�']='见鬼哒哦:AwACCAIABAoAAA==.觉醒者:AwABCAEABAoAAA==.',['�']='轻挑带迅:AwAECAQABRQAAA==.',['�']='遥儿:AwACCAQABRQAAA==.',['�']='酥哒姬:AwAHCAwABAoAAA==.',['�']='錦瑟無端:AwAICAsABAoAAR4AKDkGCAYABRQ=.',['�']='钛钽造物阿鲁:AwAICAYABAoAAA==.',['�']='铁炉大锤:AwADCAMABAoAAA==.',['�']='阿图卡:AwABCAIABRQCCAAIAQibJgBDmj0CBAoACAAIAQibJgBDmj0CBAoAAA==.阿尔彼昂:AwABCAEABRQAAA==.阿福:AwACCAEABAoAAA==.',['�']='陈小宝:AwAGCAoABRQCHwAGAQhcAABPcf4BBRQAHwAGAQhcAABPcf4BBRQAAA==.',['�']='雪冢:AwAECAQABRQAAA==.雷斯的迪凯:AwAICAgABAoAAA==.',['�']='霸壩:AwAECAQABAoAAA==.',['�']='顺势而为:AwAICA4ABAoAAA==.',['�']='风梳烟沐:AwAECAoABRQECQAEAQh7BABaJTUBBRQACQAEAQh7BABaJTUBBRQAEQABAQhZGAA0kEwABRQAEgACAQgcHAABZEgABRQAAA==.飘渺龙龙:AwAICAgABAoAAA==.飞走的鸭蛋:AwAICAgABAoAAA==.',['�']='鬼鬼呀:AwAGCAYABAoAAA==.',['�']='鲜血牛牛:AwAGCBUABRQCBQAGAQhlAgAh10sBBRQABQAGAQhlAgAh10sBBRQAAA==.',['�']='鶴見篤四郎:AwAFCAcABAoAAA==.',['�']='黄焖鸡品鉴师:AwAICAYABAoAAQUAIsgGCAYABRQ=.黑旋风铜须:AwAICAgABAoAAA==.黯楿:AwAICBEABAoAAA==.',['�']='龙骑士达维安:AwABCAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end