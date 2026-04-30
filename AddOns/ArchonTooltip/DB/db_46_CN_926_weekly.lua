local V2_TAG_NUMBER = 4

---@param v2Rankings ProviderProfileV2Rankings
---@return ProviderProfileSpec
local function convertRankingsToV1Format(v2Rankings, difficultyId, sizeId)
	---@type ProviderProfileSpec
	local v1Rankings = {}
	v1Rankings.progress = v2Rankings.progressKilled
	v1Rankings.total = v2Rankings.progressPossible
	v1Rankings.average = v2Rankings.bestAverage
	v1Rankings.spec = v2Rankings.spec
	v1Rankings.asp = v2Rankings.allStarPoints
	v1Rankings.rank = v2Rankings.allStarRank
	v1Rankings.difficulty = difficultyId
	v1Rankings.size = sizeId

	v1Rankings.encounters = {}
	for id, encounter in pairs(v2Rankings.encountersById) do
		v1Rankings.encounters[id] = {
			kills = encounter.kills,
			best = encounter.best,
		}
	end

	return v1Rankings
end

---Convert a v2 profile to a v1 profile
---@param v2 ProviderProfileV2
---@return ProviderProfile
local function convertToV1Format(v2)
	---@type ProviderProfile
	local v1 = {}
	v1.subscriber = v2.isSubscriber
	v1.perSpec = {}

	if v2.summary ~= nil then
		v1.progress = v2.summary.progressKilled
		v1.total = v2.summary.progressPossible
		v1.totalKillCount = v2.summary.totalKills
		v1.difficulty = v2.summary.difficultyId
		v1.size = v2.summary.sizeId
	else
		local bestSection = v2.sections[1]
		v1.progress = bestSection.anySpecRankings.progressKilled
		v1.total = bestSection.anySpecRankings.progressPossible
		v1.average = bestSection.anySpecRankings.bestAverage
		v1.totalKillCount = bestSection.totalKills
		v1.difficulty = bestSection.difficultyId
		v1.size = bestSection.sizeId
		v1.anySpec = convertRankingsToV1Format(bestSection.anySpecRankings, bestSection.difficultyId, bestSection.sizeId)
		for i, rankings in pairs(bestSection.perSpecRankings) do
			v1.perSpec[i] = convertRankingsToV1Format(rankings, bestSection.difficultyId, bestSection.sizeId)
		end
		v1.encounters = v1.anySpec.encounters
	end

	if v2.mainCharacter ~= nil then
		v1.mainCharacter = {}
		v1.mainCharacter.spec = v2.mainCharacter.spec
		v1.mainCharacter.average = v2.mainCharacter.bestAverage
		v1.mainCharacter.difficulty = v2.mainCharacter.difficultyId
		v1.mainCharacter.size = v2.mainCharacter.sizeId
		v1.mainCharacter.progress = v2.mainCharacter.progressKilled
		v1.mainCharacter.total = v2.mainCharacter.progressPossible
		v1.mainCharacter.totalKillCount = v2.mainCharacter.totalKills
	end

	return v1
end

---Parse a single set of rankings from `state`
---@param decoder BitDecoder
---@param state ParseState
---@param lookup table<number, string>
---@return ProviderProfileV2Rankings
local function parseRankings(decoder, state, lookup)
	---@type ProviderProfileV2Rankings
	local result = {}
	result.spec = decoder.decodeString(state, lookup)
	result.progressKilled = decoder.decodeInteger(state, 1)
	result.progressPossible = decoder.decodeInteger(state, 1)
	result.bestAverage = decoder.decodePercentileFixed(state)
	result.allStarRank = decoder.decodeInteger(state, 3)
	result.allStarPoints = decoder.decodeInteger(state, 2)

	local encounterCount = decoder.decodeInteger(state, 1)
	result.encountersById = {}
	for i = 1, encounterCount do
		local id = decoder.decodeInteger(state, 4)
		local kills = decoder.decodeInteger(state, 2)
		local best = decoder.decodeInteger(state, 1)
		local isHidden = decoder.decodeBoolean(state)

		result.encountersById[id] = { kills = kills, best = best, isHidden = isHidden }
	end

	return result
end

---Parse a binary-encoded data string into a provider profile
---@param decoder BitDecoder
---@param content string
---@param lookup table<number, string>
---@param formatVersion number
---@return ProviderProfile|ProviderProfileV2|nil
local function parse(decoder, content, lookup, formatVersion) -- luacheck: ignore 211
	-- For backwards compatibility. The existing addon will leave this as nil
	-- so we know to use the old format. The new addon will specify this as 2.
	formatVersion = formatVersion or 1
	if formatVersion > 2 then
		return nil
	end

	---@type ParseState
	local state = { content = content, position = 1 }

	local tag = decoder.decodeInteger(state, 1)
	if tag ~= V2_TAG_NUMBER then
		return nil
	end

	---@type ProviderProfileV2
	local result = {}
	result.isSubscriber = decoder.decodeBoolean(state)
	result.summary = nil
	result.sections = {}
	result.progressOnly = false
	result.mainCharacter = nil

	local sectionsCount = decoder.decodeInteger(state, 1)
	if sectionsCount == 0 then
		---@type ProviderProfileV2Summary
		local summary = {}
		summary.zoneId = decoder.decodeInteger(state, 2)
		summary.difficultyId = decoder.decodeInteger(state, 1)
		summary.sizeId = decoder.decodeInteger(state, 1)
		summary.progressKilled = decoder.decodeInteger(state, 1)
		summary.progressPossible = decoder.decodeInteger(state, 1)
		summary.totalKills = decoder.decodeInteger(state, 2)

		result.summary = summary
	else
		for i = 1, sectionsCount do
			---@type ProviderProfileV2Section
			local section = {}
			section.zoneId = decoder.decodeInteger(state, 2)
			section.difficultyId = decoder.decodeInteger(state, 1)
			section.sizeId = decoder.decodeInteger(state, 1)
			section.partitionId = decoder.decodeInteger(state, 1) - 128
			section.totalKills = decoder.decodeInteger(state, 2)

			local specCount = decoder.decodeInteger(state, 1)
			section.anySpecRankings = parseRankings(decoder, state, lookup)

			section.perSpecRankings = {}
			for j = 1, specCount - 1 do
				local specRankings = parseRankings(decoder, state, lookup)
				table.insert(section.perSpecRankings, specRankings)
			end

			table.insert(result.sections, section)
		end
	end

	local hasMainCharacter = decoder.decodeBoolean(state)
	if hasMainCharacter then
		---@type ProviderProfileV2MainCharacter
		local mainCharacter = {}
		mainCharacter.zoneId = decoder.decodeInteger(state, 2)
		mainCharacter.difficultyId = decoder.decodeInteger(state, 1)
		mainCharacter.sizeId = decoder.decodeInteger(state, 1)
		mainCharacter.progressKilled = decoder.decodeInteger(state, 1)
		mainCharacter.progressPossible = decoder.decodeInteger(state, 1)
		mainCharacter.totalKills = decoder.decodeInteger(state, 2)
		mainCharacter.spec = decoder.decodeString(state, lookup)
		mainCharacter.bestAverage = decoder.decodePercentileFixed(state)

		result.mainCharacter = mainCharacter
	end

	local progressOnly = decoder.decodeBoolean(state)
	result.progressOnly = progressOnly

	if formatVersion == 1 then
		return convertToV1Format(result)
	end

	return result
end
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Paladin-Holy','Paladin-Retribution','Warrior-Protection','DeathKnight-Unholy','Druid-Restoration','Unknown-Unknown','Rogue-Subtlety','Rogue-Assassination','Priest-Shadow','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Demonology','Priest-Holy','Priest-Discipline','Druid-Feral','Druid-Balance','Warlock-Destruction','Shaman-Elemental','Shaman-Restoration','Evoker-Preservation',}
local provider = {region='CN',realm='玛维·影歌',name='CN',type='weekly',zone=46,date='2026-04-25',data={Be='Bellona:BAAALgAECgYJCQAAAA==.',
Bl='Bluegrass:BAABLgAECn8ZAAMBAAkJ7wzeKADoAQABAAkJ7wzeKADoAQACAAEJnBYgLwFEAAABLgAFFAYJEwACAMggAA==.',
Ca='Canaan:BAAALgAECgEJAQAAAA==.',
Cl='Clow:BAAALgAECgcJDQAAAA==.',
Do='Doodmoon:BAAALgAECgEJAQAAAA==.',
Fa='Fake:BAAALgAECgYJCQAAAA==.',
Fr='Fredagain:BAAALgAECgYJBwAAAA==.',
Gs='Gsdfga:BAAALgAECgEJAQAAAA==.',
Li='Lifengzs:BAABLgAFFH8GAAIDAAQJOx70AgBvAQADAAQJOx70AgBvAQAAAA==.',
Lo='Lovey:BAABLgAFFH8QAAIEAAQJ9ySvBQCoAQAEAAQJ9ySvBQCoAQAAAA==.',
Lt='Ltmenethil:BAAALgAECgcJCAAAAA==.',
Sa='Salt:BAAALgAECgQJBAAAAA==.',
Sc='Schaman:BAAALgAFFAEJAQAAAA==.',
Sh='Shuaiy:BAAALgAECgkJCQAAAA==.',
Si='Sita:BAAALgAECgEJAQAAAA==.',
Ti='Tillday:BAAALgAECgYJDAAAAA==.',
Zy='Zy:BAAALgAECgIJAgAAAA==.',
['一个']='一个真正的曼:BAAALgAFFAIJAwAAAA==.',
['一叶']='一叶千花:BAAALgAECgEJAQAAAA==.',
['一棍']='一棍成王:BAAALgAECgYJBwAAAA==.',
['一睡']='一睡不醒:BAAALgAECgEJAQAAAA==.',
['七重']='七重:BAAALgADCgEJAQAAAA==.',
['三枚']='三枚铁罐大马:BAAALgAECgUJBQAAAA==.',
['不嘻']='不嘻嘻:BAAALgADCgYJBgAAAA==.',
['不然']='不然:BAAALgAECgEJAQAAAA==.',
['东边']='东边来的拉马:BAAALgAECgEJAQAAAA==.',
['丶佰']='丶佰小冰:BAABLgAECn8VAAIFAAgJnxu1FQCJAgAFAAgJnxu1FQCJAgAAAA==.',
['丶飘']='丶飘丷灬:BAAALgADCgEJAQAAAA==.',
['丶鳯']='丶鳯灬:BAAALgADCgUJBQAAAA==.',
['丿白']='丿白贲无咎:BAAALgAECgUJBQAAAA==.',
['亲亲']='亲亲怪:BAAALgADCgEJAQAAAA==.',
['人间']='人间四月天:BAAALgAECgYJDQAAAA==.',
['今宵']='今宵酒醒何岸:BAAALgAECgYJDwAAAA==.',
['任大']='任大猫:BAAALgAECgYJDQAAAA==.',
['伊利']='伊利熊:BAAALgADCgIJAgAAAA==.',
['伴阳']='伴阳光飞行:BAAALgAECgQJBAAAAA==.',
['伽拉']='伽拉忒亚:BAAALgADCgcJBwAAAA==.',
['余市']='余市:BAAALgAECggJBwAAAA==.',
['作业']='作业做做完:BAAALgAECgEJAQAAAA==.',
['你在']='你在狗叫什么:BAAALgAECgEJAQAAAA==.',
['你要']='你要几分熟:BAAALgAECgUJBgAAAA==.',
['俺似']='俺似劣人:BAAALgAECgEJAQAAAA==.',
['借你']='借你一只手:BAAALgAECgYJCQAAAA==.',
['元气']='元气橘子猫:BAAALgAECgYJBgAAAA==.',
['光之']='光之回想曲:BAAALgAECgYJBgABLgAECgYJDQAGAAAAAA==.',
['光头']='光头哥哥真棒:BAAALgAECgEJAQAAAA==.',
['克劳']='克劳狄乌斯:BAAALgAECgMJAwAAAA==.',
['六键']='六键可爱萨:BAAALgADCgEJAQAAAA==.',
['关羽']='关羽卖大刀:BAAALgAECgcJEgAAAA==.',
['冈格']='冈格尼尔:BAAALgAECgMJAwAAAA==.',
['冬至']='冬至丶:BAAALgAECgcJEAAAAA==.',
['冰环']='冰环:BAAALgADCgUJBQAAAA==.',
['冷烽']='冷烽:BAAALgAECgEJAQAAAA==.',
['凝视']='凝视繁花丶:BAAALgAECgIJAgAAAA==.',
['刚性']='刚性虚空棱镜:BAAALgAECgEJAQAAAA==.',
['别說']='别說:BAAALgAECgcJAwAAAA==.',
['剑啸']='剑啸九天:BAAALgAECgMJAwAAAA==.',
['北北']='北北:BAAALgAECgYJDgAAAA==.',
['十九']='十九与她:BAAALgAECgEJAQAAAA==.',
['半醒']='半醒半醉:BAAALgAECgEJAgAAAA==.',
['卓尔']='卓尔游侠:BAAALgADCgYJBgAAAA==.',
['危笑']='危笑:BAAALgAECgEJAQAAAA==.',
['厚礼']='厚礼蟹丶:BAAALgAECgMJAwAAAA==.',
['双刀']='双刀捕蝇草:BAABLgAECn8aAAMHAAcJmRw/CgBVAQAHAAYJUR4/CgBVAQAIAAEJABTiCwBCAAAAAA==.',
['双娇']='双娇赵合德:BAAALgAECgYJEQAAAA==.',
['可达']='可达鸭跟班:BAAALgAFFAIJBAAAAA==.',
['司马']='司马西门:BAABLgAFFH8JAAIJAAUJhwAxCwACAQAJAAUJhwAxCwACAQAAAA==.',
['吃我']='吃我一雷:BAAALgAECgQJBAAAAA==.',
['吾心']='吾心即吾眼:BAAALgADCgYJBwAAAA==.',
['咕德']='咕德猫柠:BAABLgAFFH8MAAIEAAQJWQWqDQAdAQAEAAQJWQWqDQAdAQAAAA==.',
['哈籁']='哈籁玫瑰:BAAALgAECgUJBQAAAA==.',
['哈贝']='哈贝特洛特:BAAALgAECgUJCwAAAA==.',
['嘴角']='嘴角的樱桃汁:BAAALgAECgUJBQAAAA==.',
['图拉']='图拉样:BAAALgAECgUJBQAAAA==.',
['地明']='地明星铁笛仙:BAAALgAECgIJAwAAAA==.',
['埃列']='埃列什基伽勒:BAAALgAECgYJBgAAAA==.',
['堀江']='堀江由衣酱:BAAALgAECgIJAgAAAA==.',
['塔烙']='塔烙沙猀:BAAALgADCgEJAQAAAA==.',
['墨颜']='墨颜丶:BAAALgAFFAIJAwAAAA==.',
['外翻']='外翻丶牡丹:BAAALgADCgEJAQAAAA==.',
['多多']='多多辛迪:BAACLgAFFH8HAAIKAAMJESAABwApAQAKAAMJESAABwApAQAuAAQKfyAAAwoACAn2IkcHABsDAAoACAn2IkcHABsDAAsAAgkFC0d6AFkAAAAA.',
['夜行']='夜行我狂:BAAALgAFFAEJAQAAAA==.',
['大雷']='大雷凤:BAAALgAECgQJBAAAAA==.',
['天下']='天下第五:BAAALgAECgUJCwAAAA==.',
['天尊']='天尊:BAAALgAECgEJAQAAAA==.',
['天杀']='天杀星黑旋风:BAAALgAECgMJAwABLgAFFAMJBgAMAL0IAA==.',
['天灾']='天灾军团细作:BAAALgAECgEJAgAAAA==.',
['天真']='天真的云:BAAALgAFFAIJAQAAAA==.',
['天败']='天败星活阎罗:BAABLgAFFH8GAAIMAAMJvQj+FQDrAAAMAAMJvQj+FQDrAAAAAA==.',
['天选']='天选打工人:BAAALgAFFAUJBAAAAA==.',
['妖王']='妖王不演戏:BAAALgAECgQJBQAAAA==.',
['嫬也']='嫬也莫德丶:BAAALgAECgIJAwAAAA==.',
['孤月']='孤月行者:BAAALgAECgEJAQAAAA==.',
['安苏']='安苏陈一发儿:BAAALgAECgEJAQAAAA==.',
['密林']='密林幽影:BAAALgAECgcJDQAAAA==.',
['富士']='富士山麓:BAAALgAECgMJAwAAAA==.',
['寻找']='寻找那页青山:BAAALgAECgQJBAAAAA==.',
['小北']='小北北:BAACLgAFFH8IAAMNAAMJKCAkAwAjAQANAAMJKCAkAwAjAQAOAAEJYACCHAA2AAAuAAQKfyAAAg0ACAkgIkMFAPwCAA0ACAkgIkMFAPwCAAAA.',
['小拳']='小拳拳:BAAALgAECgEJAQAAAA==.',
['小毛']='小毛蛋子儿:BAAALgAFFAEJAQAAAA==.',
['小狗']='小狗乐:BAAALgADCgEJAQAAAA==.',
['小艾']='小艾琳:BAAALgAECgMJBAAAAA==.',
['尛灬']='尛灬晓沫:BAAALgADCgIJAgAAAA==.',
['尼克']='尼克:BAAALgAECgEJAQAAAA==.',
['山丘']='山丘归来:BAAALgAECgEJAQAAAA==.',
['帝丨']='帝丨江:BAAALgAFFAIJBAAAAA==.',
['幽兰']='幽兰浅醉:BAAALgAECgIJBAAAAA==.',
['张一']='张一天:BAAALgAFFAIJAgAAAA==.',
['影歌']='影歌丶舞:BAAALgAECgkJAQAAAA==.',
['微笑']='微笑情人:BAAALgAECgYJBQAAAA==.',
['怺恆']='怺恆哋爾騎:BAAALgAECgMJBQAAAA==.',
['恩賜']='恩賜解脱:BAAALgAFFAIJAwAAAA==.',
['我不']='我不是奶龙:BAAALgAECgYJCwAAAA==.',
['我也']='我也是醉了:BAAALgADCgYJBgAAAA==.',
['我老']='我老公最帅啦:BAAALgADCgYJBwAAAA==.',
['战布']='战布利斤:BAAALgAECgYJBgAAAA==.',
['才哥']='才哥丨德魯伊:BAAALgAECgEJAQAAAA==.',
['打豆']='打豆豆:BAAALgAECgQJBAAAAA==.',
['找寻']='找寻生存意义:BAAALgAECgEJAgAAAA==.',
['把爱']='把爱交给撸神:BAAALgAECgEJAQAAAA==.',
['抗揍']='抗揍喵丶:BAAALgAECgYJBgAAAA==.',
['接近']='接近神的人:BAAALgAECgMJAwAAAA==.',
['摩根']='摩根:BAAALgAECgcJBwAAAA==.',
['擦边']='擦边前行:BAAALgAECgYJDQAAAA==.',
['敬个']='敬个礼握握手:BAAALgAECgEJAQAAAA==.',
['新鲜']='新鲜奶贝:BAAALgAECgcJEwAAAA==.',
['无耻']='无耻的兔子:BAAALgAECgkJCQAAAA==.',
['时空']='时空扭曲丶:BAAALgAECgcJBwAAAA==.',
['易水']='易水寒:BAAALgAECgQJBwAAAA==.',
['星光']='星光:BAAALgADCgcJBwAAAA==.',
['星宸']='星宸回响:BAAALgAFFAIJBAAAAA==.',
['暗夜']='暗夜烏鴉:BAAALgADCgYJBgAAAA==.',
['暗影']='暗影大管家:BAAALgAECgIJAgAAAA==.暗影飘儿:BAAALgAECgkJCAAAAA==.',
['暴躁']='暴躁的兔子:BAAALgAECgEJAQAAAA==.',
['曦月']='曦月:BAAALgAFFAMJBAAAAA==.',
['木兰']='木兰花:BAAALgAECgIJAgAAAA==.',
['术颜']='术颜:BAAALgAECgYJCgAAAA==.',
['机械']='机械铁拳:BAAALgAECgcJCQAAAA==.',
['枪炮']='枪炮与玫瑰:BAAALgADCgUJBQAAAA==.',
['枫秋']='枫秋:BAAALgADCgEJAgAAAA==.',
['格鲁']='格鲁特:BAAALgAECgUJCQAAAA==.',
['橘子']='橘子叔幻境僧:BAAALgAECgEJAQAAAA==.',
['橙妮']='橙妮:BAAALgADCgYJBgAAAA==.',
['欧阳']='欧阳小兰:BAAALgAECgYJBgAAAA==.',
['此妞']='此妞谢绝享受:BAAALgADCgIJAgAAAA==.',
['歪歪']='歪歪三哥:BAAALgADCgEJAQAAAA==.',
['污小']='污小水水:BAABLgAFFH8GAAIEAAIJ4h7RMQDDAAAEAAIJ4h7RMQDDAAAAAA==.',
['流年']='流年:BAAALgAECgEJAQAAAA==.',
['浅浅']='浅浅的霜:BAAALgAECgEJAQAAAA==.',
['清甜']='清甜:BAABLgAECn8gAAMPAAgJThOlBABoAQAQAAcJqhEQMgB6AQAPAAYJOhSlBABoAQAAAA==.',
['火怜']='火怜:BAAALgAECgYJCwAAAA==.',
['灬凯']='灬凯琳灬:BAABLgAFFH8JAAIBAAUJoQgCBABbAQABAAUJoQgCBABbAQAAAA==.',
['热情']='热情的武僧:BAAALgAECgYJDAAAAA==.',
['爬墙']='爬墙和尚:BAAALgAECgYJEQAAAA==.',
['片叶']='片叶听雪:BAAALgAECgcJBwAAAA==.',
['牛头']='牛头德鲁伊:BAAALgAECgEJAQAAAA==.',
['犀利']='犀利之酒:BAAALgAECgEJAQAAAA==.',
['独自']='独自去偸欢:BAAALgAFFAQJBAAAAA==.',
['猎艳']='猎艳之王:BAAALgAECgQJBAAAAA==.',
['猫好']='猫好人坏:BAAALgAECgEJAQAAAA==.',
['玉米']='玉米楼十二:BAAALgAECgMJBgAAAA==.',
['王炳']='王炳曦:BAAALgAECgcJBwABLgAFFAUJCQARANghAA==.',
['王菊']='王菊香:BAAALgAECgYJBgAAAA==.',
['玲珑']='玲珑红月:BAAALgAECgEJBAAAAA==.',
['甜的']='甜的很正经:BAAALgAECgkJAgAAAA==.',
['田中']='田中理惠:BAAALgAECgMJAwAAAA==.',
['百盛']='百盛堂十九号:BAAALgAECgYJBgAAAA==.',
['皆烬']='皆烬:BAAALgAECgEJAQAAAA==.',
['皮皮']='皮皮:BAAALgADCgUJBgAAAA==.',
['真炎']='真炎幸魂:BAAALgAECgUJBQAAAA==.',
['眼睛']='眼睛好亮:BAAALgAECgEJAQAAAA==.',
['眼罩']='眼罩:BAAALgADCgQJBAAAAA==.',
['睡过']='睡过头了:BAAALgAFFAEJAQAAAA==.',
['碎冰']='碎冰:BAAALgAECgYJCAAAAA==.',
['社会']='社会你曦少:BAAALgAECgEJAQAAAA==.',
['神秘']='神秘王子:BAAALgADCgYJBgAAAA==.',
['禁猎']='禁猎亡寄语:BAAALgAECgYJCQAAAA==.禁猎小狮子:BAAALgAECgYJBgAAAA==.',
['秦龙']='秦龙爱:BAAALgAECgUJCQAAAA==.',
['窈窕']='窈窕舞媚:BAAALgAECgUJBgAAAA==.',
['紫毛']='紫毛蛋儿:BAAALgADCgkJCgAAAA==.',
['紫贝']='紫贝贝:BAAALgADCgMJAwAAAA==.',
['纯情']='纯情丶落暮:BAAALgAECgUJCgAAAA==.',
['缺不']='缺不了一点:BAAALgAFFAEJAQAAAA==.',
['联盟']='联盟悍矬:BAAALgAECgYJBgAAAA==.',
['胖叔']='胖叔叔:BAAALgAECgUJBQAAAA==.',
['脸比']='脸比臀大:BAAALgAFFAEJAQAAAA==.',
['芝士']='芝士獐子:BAAALgAECgEJAgAAAA==.',
['花间']='花间酒:BAABLgAECn8VAAIEAAcJcx5bZADHAQAEAAcJcx5bZADHAQAAAA==.',
['芸芸']='芸芸牛儿:BAAALgADCgUJBAAAAA==.',
['若语']='若语思念:BAAALgAECgYJCwAAAA==.',
['萧风']='萧风野德:BAAALgAECgEJAQAAAA==.',
['蒼绿']='蒼绿:BAAALgAECgcJEgAAAA==.',
['血武']='血武魂:BAAALgADCgIJAgAAAA==.',
['血色']='血色羽毛:BAAALgADCgEJAQAAAA==.',
['西宫']='西宫硝子:BAAALgADCgMJAwAAAA==.',
['西风']='西风烈:BAAALgAECgEJAQAAAA==.',
['觸手']='觸手可及丶痛:BAABLgAFFH8IAAIEAAMJ+BYQJgD+AAAEAAMJ+BYQJgD+AAAAAA==.',
['詹士']='詹士夏登:BAABLgAFFH8FAAISAAIJQg5nDACeAAASAAIJQg5nDACeAAAAAA==.',
['诺坎']='诺坎普之神:BAAALgAECgEJAQAAAA==.',
['谜圗']='谜圗灬曉術:BAABLgAFFH8HAAIMAAQJXR1ZDAAuAQAMAAQJXR1ZDAAuAQAAAA==.',
['赵琳']='赵琳儿:BAAALgAECgEJAQAAAA==.',
['跟你']='跟你游戏过吧:BAAALgAECgIJAwAAAA==.',
['路转']='路转溪桥忽见:BAAALgAECgUJCwAAAA==.',
['轩辕']='轩辕雾:BAAALgAECgEJAQAAAA==.',
['边王']='边王:BAAALgAFFAEJAQAAAA==.',
['逐日']='逐日木子:BAAALgAFFAIJAgAAAA==.',
['钊帝']='钊帝大领主:BAAALgAECgcJEwAAAA==.钊帝小德:BAAALgADCgIJAgAAAA==.',
['阿凯']='阿凯:BAACLgAFFH8LAAMIAAQJ0BhhAQB8AQAIAAQJ8hRhAQB8AQAHAAMJ+htcDAAdAQAuAAQKfyAAAwcACQlxIXgGACkDAAcACQkSIXgGACkDAAgABwniGegDAH0CAAAA.',
['陌上']='陌上人如玉:BAAALgADCgYJBgAAAA==.',
['隔壁']='隔壁老樊:BAABLgAECn8bAAITAAgJhBvjFwBXAgATAAgJhBvjFwBXAgAAAA==.',
['雅典']='雅典娜二号:BAAALgAECgMJAwAAAA==.',
['零之']='零之丶妖妖:BAABLgAECn8UAAMQAAcJBBcrMACGAQAQAAcJBBcrMACGAQAFAAcJEhBsRwCEAQAAAA==.',
['鞠婧']='鞠婧祎:BAAALgAECgQJBAAAAA==.',
['风之']='风之大海:BAABLgAECn8WAAIFAAgJyRB3PgCpAQAFAAgJyRB3PgCpAQAAAA==.',
['风兮']='风兮破军:BAABLgAFFH8GAAIEAAIJRwmQRQCZAAAEAAIJRwmQRQCZAAAAAA==.',
['风暴']='风暴图腾:BAAALgAECgcJCQAAAA==.',
['香油']='香油和盐:BAAALgADCgIJAgAAAA==.',
['鬽鬽']='鬽鬽:BAAALgAECgEJAQAAAA==.',
['鲲乐']='鲲乐信仰圣光:BAAALgAECgMJAwAAAA==.鲲乐战很红:BAAALgADCgYJBgAAAA==.鲲乐的红手猎:BAAALgAFFAEJAQAAAA==.',
['鹰眼']='鹰眼儿毛蛋儿:BAAALgAFFAIJAgAAAA==.',
['龙女']='龙女希尔薇:BAABLgAFFH8JAAIUAAUJcgu1BgCFAQAUAAUJcgu1BgCFAQAAAA==.',
['龙希']='龙希尔薇:BAABLgAFFH8FAAIUAAUJmg3/BQCUAQAUAAUJmg3/BQCUAQAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
