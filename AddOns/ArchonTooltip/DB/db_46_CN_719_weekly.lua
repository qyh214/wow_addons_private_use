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

local lookup = {'Priest-Discipline','Unknown-Unknown','Hunter-BeastMastery','Warrior-Arms','Hunter-Marksmanship','Warrior-Fury','DemonHunter-Devourer','Warlock-Demonology','Mage-Frost','Priest-Holy','DeathKnight-Unholy','Priest-Shadow','Shaman-Elemental','Shaman-Restoration','Evoker-Preservation',}
local provider = {region='CN',realm='森金',name='CN',type='weekly',zone=46,date='2026-04-25',data={Az='Azure:BAAALgADCgcJBwAAAA==.',
Co='Coco:BAAALgAECgYJBgABLgAFFAUJEwABAE0hAA==.',
Fa='Fashia:BAAALgADCgEJAQAAAA==.',
Ib='Ibiubiu:BAAALgADCgQJBAAAAA==.',
Ku='Kun:BAAALgADCgUJBQAAAA==.',
Lo='Longaotian:BAAALgAECgIJAgABLgAECgYJCAACAAAAAA==.',
Lu='Luokeke:BAAALgAECgEJAQAAAA==.',
Lv='Lv:BAABLgAFFH8GAAIDAAMJtBSaCwAFAQADAAMJtBSaCwAFAQAAAA==.',
No='Nolog:BAAALgAECgYJBgAAAA==.',
Rk='Rko:BAABLgAFFH8HAAIEAAQJAABzBwAAAAAEAAQJAABzBwAAAAAAAA==.',
['Ré']='Rémy:BAAALgADCgQJBAAAAA==.',
['Rë']='Rëmi:BAAALgADCgUJBQAAAA==.',
Si='Silvanus:BAABLgAECn8VAAMFAAcJFB0uIAAhAgAFAAcJchsuIAAhAgADAAQJDRxBHgAOAQAAAA==.',
Za='Zangelia:BAAALgADCgEJAQAAAA==.Zangxixi:BAAALgAECgQJCgABLgAECgkJDgACAAAAAA==.',
['一飞']='一飞:BAAALgAECgQJBgAAAA==.',
['万丷']='万丷疆:BAAALgAECgYJCAAAAA==.',
['上头']='上头有人:BAAALgAECgIJAwAAAA==.',
['东兽']='东兽祭:BAAALgAECgEJAQAAAA==.',
['丢瑟']='丢瑟诺伊:BAAALgAECgUJBQAAAA==.',
['丨李']='丨李小花丨:BAAALgAECgYJDgAAAA==.',
['中石']='中石:BAAALgAECgYJEAAAAA==.',
['中际']='中际旭创:BAAALgAECgQJBQAAAA==.',
['丶冰']='丶冰彻:BAAALgAECgEJAQAAAA==.',
['丶加']='丶加尔鲁什:BAAALgAECgUJBQAAAA==.',
['丿璐']='丿璐璐丿:BAAALgAECgEJAgAAAA==.',
['二仙']='二仙桥走成华:BAAALgAECgEJAQAAAA==.',
['五月']='五月天爱雨:BAAALgAECgYJCQAAAA==.',
['亲爱']='亲爱的霸霸:BAAALgAECgcJDwAAAA==.',
['人形']='人形钢板:BAAALgAECgYJBAAAAA==.',
['人皆']='人皆寻梦:BAAALgAECgIJAgAAAA==.',
['兙勥']='兙勥:BAAALgAFFAIJBAAAAA==.',
['兜里']='兜里有糖:BAAALgAECgMJAwAAAA==.',
['六磅']='六磅海鲜:BAAALgAECgEJAgAAAA==.',
['冰峰']='冰峰火凰:BAAALgAECgUJAwAAAA==.',
['凤玉']='凤玉罗:BAAALgAECgkJEQABLgAFFAUJBQAGAGALAA==.',
['出云']='出云丶:BAEALgAFFAIJAgABLgAFFAQJBgAHABUSAA==.',
['初橙']='初橙乄:BAAALgAECgUJBQAAAA==.',
['功夫']='功夫孬嫑找死:BAAALgAECgYJDgAAAA==.功夫灬熊貓:BAAALgAECgYJBgAAAA==.',
['南天']='南天门:BAAALgAECgEJAQAAAA==.',
['吱吱']='吱吱:BAAALgAECggJAgAAAA==.',
['哈妮']='哈妮露牙:BAAALgAECgYJBwAAAA==.',
['噬魂']='噬魂之楓:BAAALgADCgEJAgAAAA==.',
['圈圆']='圈圆圆:BAAALgAECgYJCgAAAA==.',
['圣光']='圣光爆裂:BAAALgAECgEJAQAAAA==.圣光芭比丶:BAAALgAECgYJBgAAAA==.',
['圣影']='圣影炽翼:BAAALgAECgcJBwAAAA==.',
['圣骑']='圣骑侍:BAAALgAECgEJAQAAAA==.',
['培丶']='培丶帅:BAAALgAECgEJAQAAAA==.',
['堕落']='堕落法拉:BAAALgAECgYJCwAAAA==.堕落的圣人:BAAALgAECgYJDgAAAA==.',
['复仇']='复仇者:BAAALgAFFAIJAgAAAA==.',
['大宝']='大宝来了:BAAALgAECgUJBQAAAA==.',
['大耐']='大耐:BAAALgADCgQJBAAAAA==.',
['大肉']='大肉包:BAAALgAECgMJAwAAAA==.',
['大胡']='大胡子:BAAALgAECgEJAQAAAA==.',
['天照']='天照炙炎:BAAALgAECgIJAwAAAA==.',
['天衍']='天衍道缺:BAAALgAECgYJCwAAAA==.',
['好看']='好看:BAAALgAECgUJCAAAAA==.',
['守光']='守光历战:BAAALgAECgEJAQAAAA==.',
['宝总']='宝总小护士:BAAALgAECgYJCwAAAA==.',
['小丶']='小丶点:BAAALgAECgUJBQAAAA==.',
['小狐']='小狐哩莉:BAAALgADCgEJAQAAAA==.',
['小雯']='小雯驿:BAAALgAECgcJCwAAAA==.',
['尔尔']='尔尔丶:BAEBLgAFFH8DAAIIAAIJnRIKMwCsAAAIAAIJnRIKMwCsAAABLgAFFAQJBgAHABUSAA==.',
['巛幻']='巛幻想:BAAALgAECgYJBgAAAA==.',
['布洛']='布洛克斯希加:BAAALgAECgIJAgAAAA==.',
['幽幽']='幽幽暗暗:BAAALgAECgMJAwAAAA==.',
['弑灬']='弑灬殇:BAAALgAECgcJCAAAAA==.',
['强强']='强强:BAAALgAECgcJBwAAAA==.',
['德鲁']='德鲁:BAAALgAECgUJBgAAAA==.',
['忘魂']='忘魂天堂:BAAALgAECgcJCAAAAA==.',
['忧郁']='忧郁的坦克:BAAALgAECgUJBQAAAA==.',
['慑魂']='慑魂的随便果:BAAALgAECgUJBgAAAA==.',
['慢慢']='慢慢急不要来:BAAALgAECgEJAQAAAA==.',
['憾天']='憾天:BAAALgAECgMJAwAAAA==.',
['戰丨']='戰丨将:BAAALgAECgEJAQAAAA==.',
['戴绮']='戴绮斯:BAAALgAECgEJAQAAAA==.',
['打滚']='打滚儿卖萌:BAAALgAECgkJCQAAAA==.',
['抬头']='抬头看看天:BAACLgAFFH8LAAIJAAUJcxgODQCzAQAJAAUJchgODQCzAQAuAAQKfxYAAgkACAknImYfAPcCAAkACAknImYfAPcCAAAA.',
['指间']='指间旋律:BAAALgAECgMJAgAAAA==.',
['搔劈']='搔劈:BAAALgAECgQJBAAAAA==.',
['救赎']='救赎肀审判:BAAALgAECgQJBQAAAA==.',
['斑驳']='斑驳丶:BAEALgAECgEJAQABLgAFFAQJBgAHABUSAA==.',
['时光']='时光么:BAAALgAECgQJAwAAAA==.时光吧:BAAALgADCgEJAQAAAA==.',
['时雨']='时雨丶:BAEALgAFFAIJBAABLgAFFAQJBgAHABUSAA==.',
['明星']='明星灬魂:BAAALgAECgEJAgAAAA==.',
['暴金']='暴金之妖孽:BAABLgAFFH8FAAIKAAIJxg9uDQCSAAAKAAIJxg9uDQCSAAAAAA==.',
['曲终']='曲终秂散:BAAALgAECgYJDAAAAA==.',
['月嗜']='月嗜:BAAALgADCgYJBgAAAA==.',
['朗姆']='朗姆酒:BAAALgAECgIJBAAAAA==.',
['木瓜']='木瓜儿:BAABLgAFFH8JAAIIAAUJGBMuBwCwAQAIAAUJGBMuBwCwAQAAAA==.',
['术三']='术三绝:BAAALgAECgUJBQAAAA==.',
['枯树']='枯树年华:BAAALgADCgkJAQAAAA==.',
['楸木']='楸木浸清寒:BAAALgAECgEJAQAAAA==.',
['欧萌']='欧萌哒:BAAALgAECgYJCwAAAA==.',
['欲语']='欲语泪先流:BAAALgADCgMJAwAAAA==.',
['死丨']='死丨騎:BAABLgAFFH8FAAILAAUJaQEgGwA4AQALAAUJaQEgGwA4AQAAAA==.',
['死礻']='死礻申:BAAALgAECgUJCAAAAA==.',
['沐沐']='沐沐阳阳:BAAALgAFFAEJAQAAAA==.',
['沐雨']='沐雨言诗:BAAALgAECggJBwAAAA==.',
['法号']='法号给力:BAABLgAFFH8FAAIJAAMJzQf5UgBXAAAJAAMJzQf5UgBXAAAAAA==.',
['泷囍']='泷囍:BAAALgAFFAMJAwAAAA==.',
['泽西']='泽西:BAAALgADCgYJBgAAAA==.',
['活络']='活络小胖子:BAAALgAECgIJAgAAAA==.',
['流行']='流行风无敌:BAAALgAECgQJBQAAAA==.',
['浪味']='浪味大仙:BAABLgAFFH8XAAMKAAUJlxgxAwBnAQABAAUJMxRlBACoAQAKAAQJFB0xAwBnAQAAAA==.',
['浪子']='浪子噜噜:BAAALgAECgYJEgAAAA==.',
['浪德']='浪德酒仙:BAAALgAECgQJBAAAAA==.',
['浴火']='浴火赞歌:BAAALgAECgEJAQAAAA==.',
['瀚海']='瀚海阑丈冰:BAABLgAFFH8HAAILAAQJAwleCQAwAQALAAQJAwleCQAwAQAAAA==.',
['火正']='火正重黎:BAAALgAECgYJBwAAAA==.',
['灵晞']='灵晞:BAABLgAECn8VAAMKAAkJKRgXBAAAAgAKAAkJKRgXBAAAAgAMAAIJ4yPLRQDPAAAAAA==.',
['炽阳']='炽阳丨枫:BAAALgAECgYJCAAAAA==.',
['無人']='無人區玫瑰:BAAALgAECgQJBAAAAA==.',
['熊猫']='熊猫罐头:BAAALgAFFAIJAgAAAA==.',
['爱吃']='爱吃烤五花:BAAALgADCgEJAgAAAA==.',
['牛叁']='牛叁哥:BAAALgAECgEJAQAAAA==.',
['牛马']='牛马大仙:BAAALgAECgQJCQAAAA==.',
['物十']='物十二:BAAALgAECgEJAQAAAA==.',
['狂野']='狂野元素:BAAALgAECgcJBwAAAA==.',
['猩红']='猩红丶:BAEALgAFFAMJAwABLgAFFAQJBgAHABUSAA==.',
['猫缠']='猫缠小:BAAALgAECgEJAQAAAA==.',
['王豆']='王豆豆:BAAALgAECgEJAQAAAA==.',
['瓦莉']='瓦莉拉:BAAALgAFFAEJAQAAAA==.',
['留恋']='留恋忘返:BAAALgAECgYJCgAAAA==.',
['疯狂']='疯狂无边:BAAALgADCgcJDAAAAA==.',
['相熊']='相熊熊:BAAALgAFFAIJAwAAAA==.',
['短腿']='短腿老崔:BAABLgAFFH8MAAILAAUJWBUDBgCkAQALAAUJWBUDBgCkAQAAAA==.',
['神圣']='神圣止戈:BAAALgAECgIJAgAAAA==.',
['神说']='神说喓有光:BAAALgAECgYJDgAAAA==.',
['禅宗']='禅宗者:BAAALgAECgYJBQAAAA==.',
['简约']='简约而不简单:BAACLgAFFH8NAAMNAAUJXAnKBgBuAQANAAUJXAnKBgBuAQAOAAEJxQF/EwA0AAAuAAQKfxkAAw0ACAn5EpAmAN0BAA0ABgkEGJAmAN0BAA4ABgnIGNQ3AKMBAAAA.简约而且简单:BAAALgAECgMJBQAAAA==.',
['紫扬']='紫扬天下:BAAALgAFFAQJBAAAAA==.',
['绱婼']='绱婼:BAAALgAECgkJCQAAAA==.',
['缀音']='缀音:BAAALgAECgUJBQAAAA==.',
['羙丶']='羙丶兮兮:BAAALgAECgUJAgAAAA==.',
['聋傲']='聋傲天:BAAALgAECgYJBgAAAA==.',
['胡子']='胡子哥:BAAALgAECgEJAQAAAA==.',
['至圣']='至圣斩:BAABLgAFFH8FAAIPAAMJtRluDQAHAQAPAAMJtRluDQAHAQABLgAFFAUJCwAJAHMYAA==.',
['花语']='花语霓裳:BAACLgAFFH8IAAIIAAQJvgiKGgAfAQAIAAQJvgiKGgAfAQAuAAQKfycAAggACAnqHjcXAMkCAAgACAnqHjcXAMkCAAAA.',
['莱杰']='莱杰罗:BAAALgAECgkJCgABLgAFFAUJBAACAAAAAA==.',
['菠菜']='菠菜焖红蹄:BAAALgAECgMJAwAAAA==.',
['萌雯']='萌雯驿:BAAALgAECgUJCAAAAA==.',
['蛋皇']='蛋皇派:BAAALgAECgcJCwAAAA==.',
['蛮兽']='蛮兽冲锋:BAAALgADCgMJAwAAAA==.',
['血色']='血色神圣:BAAALgAECgEJAQAAAA==.',
['西西']='西西不嘻嘻:BAAALgAECgQJBAAAAA==.',
['谢沧']='谢沧行:BAAALgAECgcJDwAAAA==.',
['豬氏']='豬氏会社:BAAALgADCgcJBwAAAA==.',
['趴趴']='趴趴老崔:BAAALgAECgcJBwABLgAFFAUJDAALAFgVAA==.',
['蹦迪']='蹦迪治大病:BAAALgAECgYJCQAAAA==.',
['躺赢']='躺赢的路人甲:BAAALgAECgEJAQAAAA==.',
['辰辰']='辰辰奶爸:BAAALgAECgQJBgAAAA==.',
['达那']='达那拖斯:BAAALgAECgQJAwAAAA==.',
['迈豆']='迈豆:BAAALgAECgQJBAAAAA==.',
['迷途']='迷途:BAAALgAECgEJAQAAAA==.',
['逐静']='逐静丶:BAEBLgAFFH8GAAIHAAQJFRJiEQBEAQAHAAQJFRJiEQBEAQAAAA==.',
['逗比']='逗比怪兽:BAAALgAECgcJAwAAAA==.',
['遗忘']='遗忘海角:BAAALgAECgYJCAAAAA==.遗忘角落:BAAALgAECgQJBQABLgAECgYJCAACAAAAAA==.',
['部落']='部落游善者:BAAALgAECgUJCAAAAA==.部落猎殺者:BAAALgAECgYJAQAAAA==.',
['重返']='重返波塞冬:BAAALgAECgEJAQAAAA==.',
['野百']='野百合的春天:BAAALgAECgIJAgAAAA==.',
['钉子']='钉子戳小强:BAAALgAECgcJBwAAAA==.',
['银月']='银月之月:BAAALgAECgUJBwAAAA==.',
['门卫']='门卫大爷:BAAALgAECgQJBQAAAA==.',
['雪中']='雪中摇曳:BAAALgAECgYJEQAAAA==.',
['雯萌']='雯萌萌:BAAALgAECgEJAwAAAA==.',
['雾中']='雾中遗忘:BAAALgAFFAIJBAAAAA==.',
['霸气']='霸气爷们儿牛:BAAALgADCgcJBwAAAA==.',
['青岛']='青岛吴彦祖:BAAALgAFFAIJAwAAAA==.',
['风之']='风之逆襲:BAAALgAECggJBgABLgAFFAgJAQACAAAAAA==.',
['风清']='风清扬:BAAALgAECgUJBQAAAA==.',
['骑士']='骑士难搏万:BAAALgAECgIJBAAAAA==.',
['骑着']='骑着牛私奔:BAAALgAECgEJAQAAAA==.',
['鸡毛']='鸡毛换妞妞:BAAALgAECgEJAgAAAA==.',
['龙的']='龙的旋律:BAAALgADCgcJCAAAAA==.',
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
