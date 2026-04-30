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

local lookup = {'Paladin-Retribution','Unknown-Unknown','Rogue-Subtlety','Warlock-Demonology','DemonHunter-Devourer','Priest-Holy','DeathKnight-Unholy','Warrior-Protection','DeathKnight-Frost','Shaman-Elemental','Shaman-Restoration','Paladin-Holy','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Destruction','Priest-Shadow','Priest-Discipline','Monk-Windwalker','Mage-Frost',}
local provider = {region='CN',realm='千针石林',name='CN',type='weekly',zone=46,date='2026-04-25',data={Az='Azzinoth:BAAALgAECgIJAgAAAA==.',
Ce='Celecoxib:BAAALgAECgYJCQAAAA==.',
Ch='Chrees:BAAALgADCgIJAgAAAA==.',
De='Dechaos:BAAALgAECgYJCgAAAA==.',
Do='Dobi:BAAALgAECgEJAQAAAA==.',
Fo='Forsakesoul:BAAALgADCgUJBQAAAA==.',
Gj='Gjzz:BAAALgAECgYJBwAAAA==.',
Ho='Holysprite:BAAALgAFFAMJAwAAAA==.',
Je='Jervis:BAAALgAECgEJAQAAAA==.Jerviss:BAAALgAECgUJCgAAAA==.',
Ka='Kaniya:BAAALgAECgYJCgAAAA==.',
Ke='Kepller:BAAALgADCgIJAgAAAA==.',
Ki='Kirafreed:BAAALgAFFAIJAwAAAA==.',
La='Laputa:BAAALgAECgEJAQAAAA==.',
Le='Leondavinc:BAABLgAECn8UAAIBAAYJhQ7IoQA8AQABAAYJhQ7IoQA8AQAAAA==.',
Li='Littles:BAAALgAECgEJAQABLgAFFAUJBAACAAAAAA==.',
Ma='Maybehappy:BAAALgAECgEJAQAAAA==.',
Mi='Mifiles:BAAALgADCgUJBQAAAA==.',
Oi='Oioioioioi:BAAALgADCgQJBAAAAA==.',
Sa='Sacredhealer:BAAALgAECgQJBAAAAA==.',
Sh='Shadowdance:BAACLgAFFH8IAAIDAAIJfRiKEADHAAADAAIJfRiKEADHAAAuAAQKfxwAAgMACQmpGwwHAB8DAAMACQmpGwwHAB8DAAAA.',
Si='Sixbaby:BAABLgAECn8ZAAIEAAkJch/pDwD6AgAEAAkJch/pDwD6AgABLgAFFAUJBAACAAAAAA==.Sixxbaby:BAABLgAFFH8GAAIFAAQJKARiGAAMAQAFAAQJKARiGAAMAQAAAA==.',
Ta='Tallrashy:BAAALgAECgQJBgAAAA==.',
Th='Thislaypain:BAAALgADCgEJAQAAAA==.',
Tr='Treasure:BAAALgAECgYJBgAAAA==.',
Yl='Yll:BAAALgAECgEJAQAAAA==.',
['一枕']='一枕江风梦:BAAALgADCgEJAQAAAA==.',
['三聚']='三聚氰胺:BAAALgAECgIJAgAAAA==.',
['不一']='不一样的哀伤:BAAALgAECgYJCQAAAA==.',
['不胖']='不胖不瘦:BAAALgAECgcJEQAAAA==.',
['不落']='不落传说:BAAALgADCgUJBQAAAA==.',
['不锈']='不锈钢漠漠:BAAALgADCgEJAQAAAA==.',
['丨和']='丨和光同尘丨:BAAALgAFFAEJAwAAAA==.',
['丨贝']='丨贝丨壳丨:BAAALgAECgEJAQAAAA==.',
['丨黯']='丨黯月丨:BAAALgAECgcJCwAAAA==.',
['临赫']='临赫烁熙:BAAALgAECgQJBAAAAA==.',
['丶昭']='丶昭:BAAALgAFFAIJAwAAAA==.',
['久保']='久保带人:BAAALgAECgYJBgAAAA==.',
['乌托']='乌托邦蜗牛:BAAALgAECgEJAQAAAA==.',
['乌鸦']='乌鸦不是鸭:BAAALgAFFAIJBAAAAA==.',
['乍见']='乍见之欢:BAAALgAFFAIJAgAAAA==.',
['乔布']='乔布斯的诺言:BAAALgAECgUJBgAAAA==.',
['二仙']='二仙桥大爷:BAAALgAECgMJAwAAAA==.',
['二月']='二月安:BAAALgAECgEJAgAAAA==.',
['二阶']='二阶堂真红:BAAALgAECgcJEgAAAA==.',
['云欣']='云欣:BAAALgAECgEJAQAAAA==.',
['五行']='五行之力:BAAALgAECgEJAQAAAA==.',
['亚空']='亚空瘴气丶:BAAALgAECgYJCAAAAA==.',
['仙人']='仙人板板:BAAALgADCgQJBAAAAA==.',
['以爱']='以爱之名斩杀:BAAALgAFFAIJAgAAAA==.',
['伊芙']='伊芙蕾妮:BAAALgAECgQJBQAAAA==.',
['会施']='会施魔法的猫:BAAALgADCgYJCQAAAA==.',
['你不']='你不要慌啊:BAAALgAFFAIJAwAAAA==.',
['克里']='克里斯叮:BAAALgAFFAIJAgAAAA==.',
['兔斯']='兔斯拉:BAAALgAECgYJEgABLgAECgcJGQADAAIhAA==.',
['兜兜']='兜兜自摸人:BAAALgAECgEJAQAAAA==.',
['全世']='全世界只为我:BAAALgADCgUJBQAAAA==.',
['全是']='全是泡沫:BAAALgAECgEJAgAAAA==.',
['全部']='全部释放:BAAALgAECgUJBQAAAA==.',
['八二']='八二年的雪碧:BAAALgAECgYJCAAAAA==.',
['八仟']='八仟流:BAAALgADCgUJBQAAAA==.',
['兴宇']='兴宇扬幡:BAAALgAECgYJCwAAAA==.',
['兹拉']='兹拉坦丶伊布:BAAALgAECgEJAQAAAA==.',
['兽性']='兽性撕裂青春:BAAALgAECgMJAwAAAA==.',
['冰河']='冰河解冻:BAAALgAECgEJAQAAAA==.',
['冰火']='冰火二重天:BAAALgAECgYJDgAAAA==.',
['冰霜']='冰霜紫菱:BAAALgAECgQJBAAAAA==.',
['冷眉']='冷眉:BAAALgAECgQJBQAAAA==.',
['冻冰']='冻冰冰:BAAALgAECgYJDwAAAA==.',
['凤凰']='凤凰龙神丸:BAAALgAECgcJBwAAAA==.',
['剑锋']='剑锋未寒:BAAALgADCgUJBQAAAA==.',
['北大']='北大路花火:BAAALgAECgEJAQAAAA==.',
['千香']='千香:BAABLgAFFH8HAAIGAAMJJRezBwDwAAAGAAMJJRezBwDwAAAAAA==.',
['南葑']='南葑:BAAALgAECgUJCwAAAA==.',
['又见']='又见小百事:BAABLgAECn8WAAIHAAcJjxnJTgAGAgAHAAcJjxnJTgAGAgAAAA==.',
['叫俺']='叫俺尹志平:BAAALgADCgEJAQAAAA==.',
['史伊']='史伊坨:BAAALgADCgUJBQAAAA==.',
['吃货']='吃货阿迅:BAAALgAECgQJBAAAAA==.',
['名字']='名字可以不吃:BAAALgAECgEJAQAAAA==.名字可以吃麽:BAAALgAECgMJBQAAAA==.',
['吟慧']='吟慧:BAABLgAECn8XAAIHAAgJyhDCWgDhAQAHAAgJyhDCWgDhAQAAAA==.',
['吹吹']='吹吹:BAAALgAECgEJAQAAAA==.',
['咆啸']='咆啸夂:BAAALgADCgYJBgAAAA==.',
['哎呀']='哎呀我的飞飞:BAAALgADCgIJAgAAAA==.哎呀灬有联盟:BAAALgAECgEJAQAAAA==.',
['哦吼']='哦吼耶:BAAALgAECgYJCwAAAA==.',
['喂升']='喂升经:BAAALgAECgYJCQAAAA==.',
['善丶']='善丶果:BAAALgAFFAEJAQAAAA==.',
['国风']='国风:BAAALgAECgMJAwAAAA==.',
['图拉']='图拉羊:BAAALgAECgcJBgAAAA==.',
['塔嘶']='塔嘶汀枸丶:BAAALgAECgEJAgAAAA==.',
['塔格']='塔格奥丶瑞文:BAAALgADCgMJAwAAAA==.',
['壹沙']='壹沙壹天堂:BAAALgADCgYJCgAAAA==.',
['夏无']='夏无声:BAAALgAECgYJBgAAAA==.',
['夏末']='夏末未至:BAAALgAECgcJBwAAAA==.',
['夏至']='夏至天蓝:BAAALgAECgYJBgAAAA==.',
['多汁']='多汁的酱油:BAAALgADCgUJBQAAAA==.',
['夜羽']='夜羽星河:BAAALgAECgcJDgAAAA==.',
['大可']='大可:BAAALgAECgEJAQAAAA==.大可乐:BAAALgADCgIJAgAAAA==.',
['大大']='大大的二号:BAAALgAECgYJBgAAAA==.',
['大殺']='大殺四方:BAAALgAFFAMJAwAAAA==.',
['大猪']='大猪:BAAALgADCgYJBwAAAA==.',
['大白']='大白兔奶糖:BAAALgADCgIJAgAAAA==.',
['大相']='大相无形:BAAALgADCgQJBAAAAA==.',
['大青']='大青龙汤:BAAALgAECgQJBgAAAA==.',
['天地']='天地悠悠:BAAALgAECgQJBAAAAA==.',
['天天']='天天旺仔:BAAALgAFFAIJAwAAAA==.',
['天災']='天災:BAAALgAECgYJBAAAAA==.',
['天生']='天生博爱:BAAALgAECgEJAQAAAA==.',
['天道']='天道丶:BAAALgAECgIJAgAAAA==.',
['太子']='太子妃:BAAALgAECgcJCAAAAA==.',
['奇行']='奇行种:BAAALgAECgcJEwAAAA==.',
['奇迹']='奇迹与你丶:BAAALgAECgMJAwAAAA==.',
['奥义']='奥义:BAAALgAECgQJBwAAAA==.',
['奶酪']='奶酪:BAAALgAECgEJAgAAAA==.',
['好茶']='好茶不好酒:BAAALgADCgEJAQAAAA==.',
['威少']='威少:BAAALgAFFAEJAQAAAA==.',
['宠物']='宠物比我强:BAAALgADCgUJBQAAAA==.',
['小兔']='小兔洛洛:BAAALgAECgQJBAAAAA==.',
['小可']='小可乐不听话:BAAALgADCgEJAQAAAA==.',
['小呜']='小呜咪:BAAALgAFFAIJAwAAAA==.',
['小圈']='小圈圈锤胸口:BAAALgAECgEJAgAAAA==.',
['小宝']='小宝雅雅:BAAALgAECgUJBQAAAA==.',
['小秀']='小秀才:BAAALgAECgQJBAAAAA==.',
['小红']='小红牛:BAAALgADCgcJBQAAAA==.',
['小脚']='小脚芭芭拉:BAAALgADCgUJBQAAAA==.',
['小趴']='小趴菜:BAAALgAECgUJBwAAAA==.',
['小野']='小野塚小町:BAAALgADCgYJCwAAAA==.',
['小队']='小队长灬啊:BAAALgAECgEJAQAAAA==.',
['少女']='少女榨汁机:BAAALgAECgEJAQAAAA==.',
['巅峰']='巅峰时刻:BAAALgADCgIJAgAAAA==.',
['巴萨']='巴萨诺瓦:BAAALgAFFAIJAgABLgAFFAcJDQAIAM4ZAA==.',
['布兰']='布兰克斯:BAAALgAECgEJAQAAAA==.',
['带带']='带带我听到没:BAAALgAECgYJBwAAAA==.',
['常熟']='常熟伍佰:BAAALgADCgIJAgAAAA==.',
['干了']='干了你之后:BAAALgADCgEJAQAAAA==.',
['干掉']='干掉小白兔:BAAALgAECgYJBAAAAA==.',
['异形']='异形:BAAALgAECgYJDAAAAA==.',
['式神']='式神:BAAALgADCgYJBgAAAA==.',
['张鳗']='张鳗鱼:BAAALgAECgkJEAABLgAFFAkJAQACAAAAAA==.',
['强壮']='强壮的熊宝宝:BAAALgADCgUJBQAAAA==.',
['彩色']='彩色的黒:BAAALgAFFAIJAwAAAA==.',
['影流']='影流丶劣人:BAAALgAECgEJAgAAAA==.',
['影煭']='影煭:BAAALgADCgQJBAAAAA==.',
['影靓']='影靓:BAAALgAECggJCAAAAA==.',
['往前']='往前有座宝山:BAAALgAECgIJAQAAAA==.',
['忘归']='忘归人:BAAALgAECgUJBQAAAA==.',
['怎么']='怎么肥事老弟:BAAALgADCgUJCgAAAA==.',
['思琪']='思琪迪凯:BAACLgAFFH8QAAMHAAUJ4xFaCgB/AQAHAAUJ4xFaCgB/AQAJAAEJbgHXBAA7AAAuAAQKfx8AAgcACQmoHq8OACYDAAcACQmoHq8OACYDAAAA.',
['怪鸡']='怪鸡鲍勃:BAABLgAECn8XAAIBAAgJCB9GIwCcAgABAAgJCB9GIwCcAgAAAA==.',
['总有']='总有往事回味:BAAALgAECgQJBQAAAA==.',
['恍若']='恍若微凉灬:BAABLgAECn8XAAIFAAYJNRH3HwALAQAFAAYJNRH3HwALAQAAAA==.',
['恒星']='恒星:BAAALgAECgMJAwAAAA==.',
['恶魔']='恶魔城影魂曲:BAAALgAECgQJBgAAAA==.',
['惩罚']='惩罚者:BAAALgADCgcJCgAAAA==.',
['想你']='想你的每一天:BAAALgADCgUJBQAAAA==.',
['我即']='我即圣光:BAAALgAECgIJAgAAAA==.',
['我是']='我是亮仔:BAAALgAECgcJBgAAAA==.我是只猪才怪:BAAALgAECgYJCQAAAA==.',
['我的']='我的野蛮酸奶:BAAALgAFFAIJAgAAAA==.',
['抑郁']='抑郁的屠夫:BAAALgADCgUJBQAAAA==.',
['拔娜']='拔娜娜:BAAALgAECgUJBAAAAA==.',
['提多']='提多罗吒:BAAALgAECgEJAQAAAA==.',
['摆烂']='摆烂小鱼:BAAALgAECgIJAgAAAA==.',
['摇摆']='摇摆小雪鱼:BAAALgADCgQJBAAAAA==.',
['放开']='放开那正太:BAAALgADCgEJAQAAAA==.',
['新巴']='新巴克:BAAALgAECgMJAwAAAA==.',
['无敌']='无敌法王:BAABLgAECn8WAAMKAAYJtRy8CABzAQAKAAYJtRy8CABzAQALAAQJrRHiaADrAAAAAA==.',
['无界']='无界空宇:BAACLgAFFH8FAAIBAAMJqxZ6EgASAQABAAMJqxZ6EgASAQAuAAQKfxgAAwwACQlGIZ8BAGkDAAwACQlGIZ8BAGkDAAEACQnhFTJAACUCAAAA.',
['旺仔']='旺仔天天:BAAALgAECgQJBAAAAA==.',
['是个']='是个问题:BAAALgAECgIJBQAAAA==.',
['晚上']='晚上的太阳:BAAALgAECgMJAwAAAA==.',
['晨光']='晨光之愈:BAAALgAECgUJBwAAAA==.',
['普雷']='普雷尔踢:BAAALgAECgYJBgAAAA==.',
['暗夜']='暗夜妖艳:BAACLgAFFH8GAAMNAAMJwwU3GADQAAANAAMJwwU3GADQAAAOAAEJ5wGFGABKAAAuAAQKfxUAAg0ABwmBEMozAJoBAA0ABwmBEMozAJoBAAAA.暗夜救世主:BAAALgAECgMJBQAAAA==.',
['暗黑']='暗黑大祥子:BAAALgADCgEJAQAAAA==.',
['暴暴']='暴暴术爷:BAAALgADCgYJBgAAAA==.',
['月疏']='月疏影:BAABLgAFFH8FAAMOAAMJ+Qq/DgCnAAAOAAMJ+Qq/DgCnAAANAAIJOAqdIACRAAAAAA==.',
['木儿']='木儿弯弯:BAABLgAFFH8LAAIBAAQJ3h2hAgBuAQABAAQJ3h2hAgBuAQAAAA==.',
['李九']='李九仔:BAAALgAECgYJBgAAAA==.',
['李唐']='李唐李糖糖丶:BAAALgAFFAIJBAAAAA==.',
['杰神']='杰神大妈:BAAALgAECgkJCwAAAA==.',
['林兒']='林兒:BAAALgAECgYJCwAAAA==.',
['枪火']='枪火流星:BAAALgAECgQJBAAAAA==.',
['枫吟']='枫吟月华:BAAALgAECggJEgAAAA==.',
['枫雅']='枫雅颂:BAAALgAFFAEJAQAAAA==.',
['柿丶']='柿丶子不软:BAAALgAECgQJBAAAAA==.',
['根本']='根本不赢:BAAALgAECgcJCwAAAA==.',
['梦行']='梦行云:BAAALgAECgQJBQAAAA==.',
['梧桐']='梧桐丶揍敌客:BAABLgAFFH8JAAINAAMJ7CW9DABRAQANAAMJ7CW9DABRAQAAAA==.',
['森海']='森海飞霞:BAAALgAECgEJAQAAAA==.',
['橙丶']='橙丶猎:BAAALgAFFAQJAgAAAA==.',
['此情']='此情可待追忆:BAAALgAFFAUJBAAAAA==.',
['武学']='武学真髓:BAAALgADCgQJBAAAAA==.',
['残酷']='残酷天使:BAAALgAFFAEJAQAAAA==.',
['比奇']='比奇堡奶瓶:BAAALgAFFAQJBAAAAA==.',
['水墨']='水墨靑:BAAALgAECgcJBwAAAA==.',
['水月']='水月:BAAALgAECggJEwAAAA==.',
['汐水']='汐水如墨:BAACLgAFFH8IAAMEAAQJVQo0OACjAAAEAAMJ7Qg0OACjAAAPAAEJjQ5JFQBUAAAuAAQKfx0AAwQACAnSGJANAKgBAAQACAnSGJANAKgBAA8AAwllDNxBAK0AAAEuAAUUAwkDAAIAAAAA.',
['沙恩']='沙恩萨斯特:BAAALgAECgIJAgAAAA==.',
['泡沫']='泡沫要破了:BAAALgADCgEJAQAAAA==.',
['洒满']='洒满一路财富:BAAALgADCgIJAgAAAA==.',
['流浪']='流浪战神:BAAALgADCgEJAQAAAA==.',
['浅羽']='浅羽桐:BAAALgAECgYJBgAAAA==.',
['浓缩']='浓缩:BAAALgAECgMJBQAAAA==.',
['海洋']='海洋不是羊:BAAALgAFFAIJAgAAAA==.',
['海的']='海的胖女婿:BAAALgAECgQJBAAAAA==.',
['海豹']='海豹大王:BAACLgAFFH8GAAMGAAIJ5ReHCgC8AAAGAAIJ5ReHCgC8AAAQAAEJuRMFFABUAAAuAAQKfxUABAYABwlMIK0dAPEBAAYABwlTGa0dAPEBABEABQlcHYsHAHcBABAAAQknC5VdAD4AAAAA.',
['清淵']='清淵煙寂:BAAALgAFFAIJBAAAAA==.',
['渐行']='渐行渐远灬:BAACLgAFFH8IAAIHAAMJxBrgJAACAQAHAAMJxBrgJAACAQAuAAQKfxoAAgcACAl1JEsTAAcDAAcACAl1JEsTAAcDAAEuAAUUBQkFABIApBUA.',
['渺小']='渺小人生:BAAALgADCgQJBAAAAA==.',
['滚滚']='滚滚向前冲:BAAALgAECgEJAQAAAA==.',
['满庭']='满庭芳:BAABLgAECn8YAAITAAYJTBx+lwClAQATAAYJTBx+lwClAQABLgAFFAUJCAATAKsfAA==.',
['漫步']='漫步撒哈拉:BAAALgADCgEJAQAAAA==.',
['炎发']='炎发灼眼:BAAALgAECgMJBQAAAA==.',
['烈灬']='烈灬焰:BAAALgAECgEJAQAAAA==.',
['热血']='热血猎神:BAAALgAFFAIJBAAAAA==.',
['爱丽']='爱丽丝妮:BAAALgADCgEJAQAAAA==.',
['牧云']='牧云暗:BAAALgAECgcJBgAAAA==.',
['狂暴']='狂暴小鹿:BAAALgAECgEJAQAAAA==.',
['狐狸']='狐狸猫:BAAALgADCgQJBQAAAA==.',
['狱火']='狱火涅槃:BAAALgAFFAEJAQAAAA==.',
['猫不']='猫不理咕咕:BAAALgAECgYJBgAAAA==.',
['獒獒']='獒獒:BAAALgAECgEJAgAAAA==.',
['玲儿']='玲儿响叮当:BAAALgAFFAMJAwAAAA==.',
['痛风']='痛风者:BAAALgAFFAIJAwAAAA==.',
['皇家']='皇家橡樹:BAAALgAECgEJAQAAAA==.',
['看我']='看我锤子:BAAALgAFFAEJAQAAAA==.',
['瞬丶']='瞬丶千書:BAAALgADCgYJBwAAAA==.',
['神圣']='神圣惩戒龙:BAAALgAECgYJCAAAAA==.',
['秋葵']='秋葵紫紫:BAAALgADCgUJBQAAAA==.',
['米兔']='米兔不是兔:BAAALgAFFAIJBAAAAA==.',
['米凯']='米凯拉的王:BAAALgAECgEJAQAAAA==.',
['糖果']='糖果纸丶:BAAALgAECgMJAwAAAA==.',
['糯米']='糯米兮兮:BAAALgAFFAEJAQAAAA==.',
['純純']='純純欲動:BAAALgAECgIJAgAAAA==.',
['紫菱']='紫菱:BAAALgADCgIJAgAAAA==.',
['紫霞']='紫霞一仙子:BAABLgAFFH8FAAITAAMJzQ0TLQACAQATAAMJzQ0TLQACAQAAAA==.',
['繁花']='繁花落尽清风:BAAALgAECgMJBAAAAA==.',
['红尘']='红尘小奶瓶:BAAALgAECgcJBwAAAA==.',
['红眼']='红眼打火:BAAALgAECgYJDAAAAA==.',
['给你']='给你一猫鞭:BAAALgADCgcJCwAAAA==.',
['罗小']='罗小賔:BAAALgAFFAEJAQAAAA==.',
['美式']='美式大王:BAAALgAECgEJAQAAAA==.',
['老玖']='老玖:BAAALgAFFAEJAQAAAA==.',
['肥橙']='肥橙吃不饱:BAAALgAECgUJBwABLgAECgYJBgACAAAAAA==.',
['胸肌']='胸肌碎大石:BAAALgAECgQJBAAAAA==.',
['艾思']='艾思泥:BAAALgAECgcJBwAAAA==.',
['花摇']='花摇裤儿:BAAALgAECgEJAgAAAA==.',
['苏茜']='苏茜雅:BAAALgAECgEJAQAAAA==.',
['茜茜']='茜茜莉娅:BAAALgAECgQJBAAAAA==.',
['菜籽']='菜籽的老湿:BAAALgADCgUJBQAAAA==.',
['菜菜']='菜菜丶遥:BAAALgAECgYJCwAAAA==.',
['萦岚']='萦岚:BAAALgAECgMJAwAAAA==.',
['蒙迪']='蒙迪欧尐奈斯:BAAALgAECgIJAwAAAA==.',
['蒜头']='蒜头炒洋葱:BAACLgAFFH8IAAITAAMJ+yALIQA/AQATAAMJ+yALIQA/AQAuAAQKfyEAAhMACAnTHewZABADABMACAnTHewZABADAAAA.',
['蔓囨']='蔓囨經惢:BAAALgADCgYJBgAAAA==.',
['蔓越']='蔓越莓的月光:BAAALgAECgQJBAAAAA==.',
['虎妞']='虎妞子:BAAALgAECgYJBQAAAA==.',
['虚妄']='虚妄之心:BAAALgAECgMJAwAAAA==.',
['虚空']='虚空之触:BAABLgAFFH8FAAMRAAIJDhIfFQCMAAARAAIJDhIfFQCMAAAGAAEJ3wEoGAAzAAAAAA==.虚空影子猎手:BAAALgADCgUJBQAAAA==.',
['蚀龙']='蚀龙:BAAALgAECgMJAwAAAA==.',
['蜂蜜']='蜂蜜熊:BAAALgAECgcJBwAAAA==.',
['蜗牛']='蜗牛揣包烟:BAAALgAECgIJAgAAAA==.',
['血之']='血之挽歌:BAAALgAFFAIJAwAAAA==.',
['血色']='血色荣耀:BAAALgADCgUJBQAAAA==.',
['血蹄']='血蹄村村长:BAAALgADCgEJAQAAAA==.',
['被秒']='被秒杀的帅哥:BAAALgAFFAIJAwAAAA==.',
['见到']='见到你很高兴:BAAALgADCgEJAQAAAA==.',
['言承']='言承旭:BAAALgAECgkJCQAAAA==.',
['言殇']='言殇:BAABLgAFFH8HAAIMAAMJwByJDAAUAQAMAAMJwByJDAAUAQAAAA==.',
['许多']='许多多:BAAALgAECgYJCwABLgAECgcJGQADAAIhAA==.',
['豚豚']='豚豚:BAAALgAECgMJAwAAAA==.',
['豪情']='豪情叒弱:BAAALgADCgIJAgAAAA==.',
['贝丨']='贝丨壳:BAAALgAECgYJBQAAAA==.',
['贝塔']='贝塔乄:BAACLgAFFH8QAAIBAAQJcSPhBACiAQABAAQJcSPhBACiAQAuAAQKfyUAAgEACAkMJVUMACsDAAEACAkMJVUMACsDAAAA.',
['贰月']='贰月贰龙抬头:BAAALgADCgIJAgAAAA==.',
['赛娜']='赛娜:BAAALgADCgIJAgAAAA==.',
['赛巴']='赛巴斯:BAAALgADCgYJBwAAAA==.',
['赞丨']='赞丨达丨拉:BAAALgADCgEJAQAAAA==.',
['这只']='这只猫有点凶:BAAALgADCgQJBAAAAA==.',
['迷茫']='迷茫的羔羊:BAAALgADCgYJCAAAAA==.',
['透心']='透心凉灬:BAAALgAECgYJBwAAAA==.',
['逐日']='逐日伯爵:BAAALgAECgYJCgAAAA==.',
['遥丶']='遥丶小望:BAAALgAECgUJCAAAAA==.',
['酷娜']='酷娜丝菲:BAAALgAECgMJAwAAAA==.',
['酸萝']='酸萝卜别吃丶:BAAALgADCgEJAQAAAA==.',
['醉梦']='醉梦丶笙歌:BAAALgAECgYJCgAAAA==.',
['野蛮']='野蛮小喵:BAAALgAECgEJAwAAAA==.野蛮小猎:BAAALgAECgEJAwAAAA==.野蛮小猫:BAAALgAECgEJAwAAAA==.',
['金色']='金色聖騎士:BAAALgADCgMJAwAAAA==.',
['钱多']='钱多多:BAAALgAECgYJCQAAAA==.',
['铁臂']='铁臂阿童木:BAAALgAECgMJBAAAAA==.',
['问题']='问题不大:BAAALgAECgIJAgAAAA==.',
['阿飒']='阿飒:BAAALgAECgEJAQAAAA==.',
['陆童']='陆童靴丶:BAAALgAECgEJAQAAAA==.',
['陇上']='陇上张不不:BAAALgAECgEJAQAAAA==.',
['隨風']='隨風而逝:BAAALgAECgcJCQABLgAFFAUJCQANADQcAA==.',
['零玖']='零玖壹柒:BAAALgAECgEJAQAAAA==.',
['雾将']='雾将眠:BAAALgAFFAMJAwAAAA==.',
['霍叁']='霍叁:BAAALgAECgUJDAAAAA==.',
['霓虹']='霓虹杀拳:BAAALgADCgQJBAAAAA==.',
['霜雪']='霜雪漫:BAEALgAFFAIJAwAAAA==.',
['风一']='风一絮:BAAALgADCgMJAwAAAA==.风一芙:BAAALgAECgYJBwAAAA==.',
['风丶']='风丶舞:BAAALgADCgEJAQAAAA==.',
['风之']='风之岚:BAAALgAECgEJAQAAAA==.',
['风雪']='风雪星辰:BAAALgAECgQJBAAAAA==.风雪迹:BAAALgAECgYJEAAAAA==.',
['飘飖']='飘飖兮若流风:BAAALgAECgEJAQAAAA==.',
['飞翔']='飞翔归来:BAAALgAECgYJBgAAAA==.飞翔的刺客:BAAALgADCgUJBQAAAA==.',
['香蕉']='香蕉芒果:BAAALgAECgYJBgAAAA==.',
['骑士']='骑士大可:BAAALgAECgEJAQAAAA==.',
['高坚']='高坚果:BAAALgAECgMJAwABLgAECgYJBgACAAAAAA==.',
['魅力']='魅力复活:BAAALgAECgYJCAAAAA==.魅力扫地僧:BAAALgAECgQJBAAAAA==.魅力狂舞:BAAALgAECgEJAQAAAA==.',
['魅惑']='魅惑菇:BAAALgAECgYJBgAAAA==.',
['鱼小']='鱼小满:BAABLgAECn8ZAAIDAAcJAiGqDwCqAgADAAcJAiGqDwCqAgAAAA==.鱼小蛮:BAAALgAECgIJAgABLgAECgcJGQADAAIhAA==.',
['鸟飞']='鸟飞绝:BAAALgAECgYJCwAAAA==.',
['鹰竟']='鹰竟吃到兔:BAAALgADCgYJBgAAAA==.',
['麦基']='麦基七号:BAAALgAECgUJBwAAAA==.',
['麦芽']='麦芽:BAAALgAECgEJAQAAAA==.',
['黑妹']='黑妹儿:BAAALgAECgQJBAAAAA==.',
['黑手']='黑手妖:BAAALgAECgYJCAAAAA==.黑手弗老爷:BAAALgAECgMJAwAAAA==.',
['黑獄']='黑獄:BAAALgADCgUJBQAAAA==.',
['黒骨']='黒骨髓:BAAALgAECgIJAgAAAA==.',
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
