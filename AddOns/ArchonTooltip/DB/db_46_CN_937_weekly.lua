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

local lookup = {'Mage-Frost','Warlock-Demonology','Paladin-Holy','DeathKnight-Unholy','DeathKnight-Frost','Unknown-Unknown','Druid-Balance','Druid-Restoration','Druid-Feral','Warlock-Destruction','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Windwalker','Monk-Brewmaster','Shaman-Restoration','Monk-Mistweaver','Paladin-Retribution','Paladin-Protection','Priest-Shadow','Priest-Discipline','Priest-Holy','Rogue-Subtlety',}
local provider = {region='CN',realm='罗曼斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ba='Bananaxq:BAAALgAECgUJEAAAAA==.',
Ca='Caffrey:BAAALgAECgMJAwAAAA==.',
In='Infiniternal:BAAALgAECgEJAQAAAA==.',
Lo='Lostzhe:BAAALgAFFAIJAgABLgAFFAQJCgABAEgYAA==.',
Ot='Otiamo:BAAALgAECgIJAgAAAA==.',
Pa='Paladowow:BAAALgAECgQJCgAAAA==.',
Pe='Peterwl:BAABLgAECn8VAAICAAcJuxAfGQBuAQACAAcJuxAfGQBuAQAAAA==.',
Qv='Qvq:BAAALgAECgYJDAAAAA==.',
Re='Relax:BAAALgAECgYJCAAAAA==.',
Sh='Shadowless:BAAALgAECgQJBgAAAA==.',
Ty='Tyder:BAAALgADCgEJAQAAAA==.',
Yo='Youkinyouca:BAAALgAECgQJBQAAAA==.',
['一兽']='一兽栏宝宝:BAAALgAECgEJAQAAAA==.',
['一棒']='一棒子怼死:BAAALgADCgIJAgABLgAFFAQJDQADABchAA==.',
['一秋']='一秋又一秋丶:BAAALgAECgYJCQAAAA==.',
['一顿']='一顿兔兔:BAAALgAECgcJEwAAAA==.',
['不爱']='不爱说话:BAAALgAFFAEJAQAAAA==.',
['丫典']='丫典娜:BAAALgADCgEJAQAAAA==.',
['丶女']='丶女巫:BAAALgAECgQJBAAAAA==.',
['丶妖']='丶妖莲:BAAALgAFFAQJBAAAAA==.丶妖蓮:BAABLgAFFH8FAAIEAAUJMBYjBQCvAQAEAAUJMBYjBQCvAQAAAA==.',
['丶小']='丶小丸子:BAAALgAECgYJEwAAAA==.',
['丶微']='丶微光:BAAALgAECgIJAQAAAA==.',
['丶猛']='丶猛牛代言人:BAAALgAFFAQJBAAAAA==.',
['丶阿']='丶阿猛:BAABLgAFFH8GAAMEAAMJ1BRdJwD6AAAEAAMJ1BRdJwD6AAAFAAEJMwtkBQBPAAABLgAFFAQJBAAGAAAAAA==.',
['举报']='举报甲方:BAAALgAECgYJCgABLgAFFAQJDgACAGQXAA==.',
['丿京']='丿京酱肉丝:BAAALgAECgEJAQAAAA==.',
['丿惊']='丿惊酱肉丝:BAAALgAECgEJAgAAAA==.',
['乌丶']='乌丶拉:BAAALgAECgYJCQAAAA==.',
['云初']='云初丶:BAAALgAFFAMJBAAAAA==.',
['五星']='五星好市民:BAAALgAFFAIJBAAAAA==.',
['亲亲']='亲亲子衿:BAAALgADCgEJAQAAAA==.',
['傍晚']='傍晚的思念:BAAALgAECgQJBQAAAA==.',
['光头']='光头虐人:BAAALgAECgcJBwAAAA==.',
['光明']='光明村打手:BAAALgAECgEJAQABLgAFFAMJBgAHAPQQAA==.光明村村花:BAAALgAECggJDQABLgAFFAMJBgAHAPQQAA==.光明村村长:BAACLgAFFH8GAAMHAAMJ9BCKDgD3AAAHAAMJ9BCKDgD3AAAIAAEJhwdiJABIAAAuAAQKfxUAAwcACAmLG94QAJgCAAcACAmLG94QAJgCAAgAAQkRFRPDAEIAAAAA.',
['六月']='六月寒:BAAALgAECgUJBQAAAA==.',
['兰斯']='兰斯洛丶特:BAAALgAECgcJBwAAAA==.',
['内个']='内个麒士丶:BAAALgAECgEJAQAAAA==.',
['凋零']='凋零之弑:BAAALgAECgEJAQAAAA==.',
['十种']='十种神镜阵:BAAALgAFFAIJBAAAAA==.',
['南宫']='南宫雁:BAAALgAECgIJAwABLgAFFAQJBAAGAAAAAA==.',
['又小']='又小又硬:BAAALgAFFAEJAQAAAA==.又小又硬丨术:BAAALgAFFAIJAgAAAA==.',
['可爱']='可爱菜菜子:BAAALgAECgMJBgAAAA==.',
['右转']='右转右行:BAAALgADCgEJAQAAAA==.右转左行:BAAALgADCgYJBgAAAA==.',
['叶穆']='叶穆:BAAALgAECgIJAgAAAA==.',
['吆西']='吆西:BAAALgAECgQJBAAAAA==.',
['和气']='和气生财:BAAALgAECgIJAgAAAA==.',
['咬你']='咬你就两口:BAACLgAFFH8FAAIJAAMJfgnaAgD/AAAJAAMJfgnaAgD/AAAuAAQKfx0AAgkACQmMHAwEAOUCAAkACQmMHAwEAOUCAAAA.',
['啾啾']='啾啾法:BAAALgADCgEJAQAAAA==.啾啾萨:BAAALgAECgkJCQAAAA==.',
['嘤嘤']='嘤嘤怪:BAAALgAECgYJBwAAAA==.',
['噬元']='噬元兽:BAABLgAECn8hAAMCAAcJeiNrHgChAgACAAcJ4yJrHgChAgAKAAUJjxp/HABqAQAAAA==.',
['墨無']='墨無痕:BAABLgAFFH8GAAMLAAMJjSYlDgDhAAAMAAIJ0SYpFgDpAAALAAIJzSUlDgDhAAAAAA==.',
['大绫']='大绫主:BAAALgAFFAQJBAAAAA==.',
['天使']='天使逐鹿中原:BAAALgAECgMJAwAAAA==.',
['天宇']='天宇:BAAALgADCgUJBQAAAA==.天宇大宗师:BAAALgAECgEJAQAAAA==.天宇瞎:BAAALgAFFAEJAQAAAA==.',
['天霜']='天霜牙:BAAALgAECgUJAwAAAA==.',
['天龙']='天龙道祖:BAABLgAECn8cAAMNAAgJ8hNXIADUAQANAAcJ9hVXIADUAQAOAAUJqQozHACeAAAAAA==.',
['奕剑']='奕剑十三:BAAALgAFFAQJBAAAAA==.',
['奥利']='奥利维亚维利:BAAALgAECgQJBQAAAA==.',
['好家']='好家伙哦:BAAALgAECgYJDAAAAA==.',
['如果']='如果那是真的:BAAALgAECgcJCwAAAA==.',
['妖莲']='妖莲:BAABLgAFFH8GAAIEAAYJDxqcAADnAQAEAAYJDxqcAADnAQAAAA==.妖莲叮:BAAALgAFFAQJBAAAAA==.妖莲叹:BAEALgAFFAQJBAABLgAFFAUJBAAGAAAAAA==.妖莲啊:BAAALgAFFAQJBAAAAA==.',
['妖蓮']='妖蓮叮:BAAALgAECgkJCQAAAA==.妖蓮吖:BAAALgAFFAQJBAAAAA==.妖蓮吗:BAABLgAFFH8FAAIEAAUJ5BCMBwCUAQAEAAUJ5BCMBwCUAQAAAA==.妖蓮呀:BAAALgAFFAQJBAAAAA==.妖蓮呗:BAAALgAFFAEJAQAAAA==.妖蓮呢:BAABLgAFFH8GAAIEAAYJoRVMAQCzAQAEAAYJoRVMAQCzAQAAAA==.妖蓮咧:BAAALgAFFAQJBAAAAA==.妖蓮哈:BAABLgAFFH8FAAIEAAUJexqqBABqAQAEAAUJexqqBABqAQAAAA==.妖蓮哒:BAAALgAFFAcJAgAAAA==.妖蓮哟:BAAALgAFFAUJAQAAAA==.',
['娇气']='娇气包张大发:BAAALgAECgkJBgAAAA==.',
['对付']='对付:BAAALgAECgEJAQAAAA==.',
['小乖']='小乖宝:BAAALgAECgMJBQAAAA==.',
['小小']='小小胖墩:BAAALgAECgEJAQAAAA==.小小芒果:BAAALgADCgcJDgAAAA==.',
['小帅']='小帅丶:BAAALgAECgIJAgAAAA==.',
['小师']='小师弟:BAAALgAECgkJEQAAAA==.',
['小火']='小火法:BAAALgAECgYJBgAAAA==.',
['屠尽']='屠尽日寇:BAABLgAFFH8IAAIOAAQJEw68DQAWAQAOAAQJEw68DQAWAQAAAA==.',
['帅帅']='帅帅大芒果:BAAALgADCgcJBwAAAA==.',
['师爷']='师爷苏:BAAALgADCgIJAgAAAA==.',
['希力']='希力咕:BAAALgAECgkJCQAAAA==.',
['帕吉']='帕吉哥:BAABLgAFFH8HAAIPAAMJgRJrDwDsAAAPAAMJgRJrDwDsAAAAAA==.',
['帕珠']='帕珠珠:BAAALgAECgcJDwAAAA==.',
['应渊']='应渊大叔:BAAALgAECgEJAQAAAA==.',
['德彪']='德彪:BAAALgADCgYJBwAAAA==.',
['心伤']='心伤咕咕:BAAALgADCgMJAwAAAA==.心伤奶爹:BAAALgAFFAIJAwAAAA==.',
['性感']='性感老光头:BAABLgAECn8jAAIQAAgJ4x7dCQC2AgAQAAgJ4x7dCQC2AgAAAA==.',
['怪人']='怪人细胞瓜:BAAALgAECgIJAgAAAA==.',
['恶狼']='恶狼奶糖:BAAALgADCgIJAgAAAA==.',
['惜玉']='惜玉灬斩风:BAAALgAECgMJAwAAAA==.',
['惜羽']='惜羽灬大神:BAAALgAECgQJCAAAAA==.',
['意父']='意父:BAAALgAECgcJDAAAAA==.',
['慕艾']='慕艾:BAABLgAECn8WAAMLAAkJ5yK7AAC6AwALAAkJ5yK7AAC6AwAMAAYJ4BsFOgB3AQABLgAFFAYJBwAMAIMYAA==.',
['懒大']='懒大王:BAAALgAFFAQJBAAAAA==.',
['我找']='我找到你了:BAACLgAFFH8PAAIQAAUJSxGhBACXAQAQAAUJSxGhBACXAQAuAAQKfyMAAhAACAkNG1APAGQCABAACAkNG1APAGQCAAAA.',
['我最']='我最龙:BAAALgAECgcJBwAAAA==.',
['战上']='战上风胡总:BAAALgAFFAIJAwAAAA==.',
['战逆']='战逆天:BAAALgAECgQJBAAAAA==.',
['戦死']='戦死啲丨眫子:BAAALgAECgUJCQAAAA==.',
['星小']='星小狐:BAABLgAECn8cAAMRAAgJdxo1MwBVAgARAAgJdxo1MwBVAgASAAEJkA5mRQAqAAAAAA==.',
['暴躁']='暴躁的虾米:BAAALgAECgYJCgAAAA==.',
['柯西']='柯西:BAAALgAECgMJAwAAAA==.',
['武井']='武井咲:BAAALgAECgQJBQAAAA==.',
['歪歪']='歪歪大魔王:BAAALgADCgEJAQAAAA==.歪歪小恶魔:BAAALgADCgQJBAAAAA==.',
['死亡']='死亡丶阴影:BAAALgAECgYJBwAAAA==.',
['沐沐']='沐沐沫沫:BAAALgADCgYJDAAAAA==.',
['沐浴']='沐浴龙血:BAAALgAECgQJBAAAAA==.',
['沐风']='沐风:BAAALgAECgUJBAAAAA==.',
['泡泡']='泡泡牧风:BAAALgAECgYJBgAAAA==.',
['波塞']='波塞冬丶:BAAALgAECgYJEAAAAA==.',
['泰蕾']='泰蕾苟萨丶:BAAALgAECgUJBQAAAA==.',
['灬芽']='灬芽间灬:BAACLgAFFH8PAAMTAAUJ7x0xAQCDAQATAAQJ7x0xAQCDAQAUAAEJYw2AFwBWAAAuAAQKfycAAxMACAkGJT8FADwDABMACAkGJT8FADwDABQABwlFFxsXAOcBAAAA.',
['灬路']='灬路遇尘埃灬:BAAALgADCgUJBQAAAA==.',
['灰烬']='灰烬觉醒:BAAALgAECgUJBQAAAA==.',
['烽火']='烽火洋流:BAAALgAFFAEJAgAAAA==.',
['然然']='然然:BAAALgAECgkJEAABLgAFFAQJBgATAAcWAA==.',
['熠阿']='熠阿宝:BAAALgAECgYJDQAAAA==.',
['爆炒']='爆炒圣骑:BAAALgADCgcJCAAAAA==.',
['牛晓']='牛晓德:BAAALgAECgIJAQAAAA==.',
['狡诈']='狡诈饿茹:BAAALgAECgEJAQABLgAECgMJBQAGAAAAAA==.',
['玛法']='玛法里傲怒风:BAABLgAFFH8FAAIIAAMJEwdyEQCDAAAIAAMJEwdyEQCDAAAAAA==.',
['珍妮']='珍妮玛黛劲:BAAALgAECgEJAQABLgAFFAcJBAAGAAAAAA==.',
['生命']='生命的缚誓者:BAAALgAECgIJBAAAAA==.',
['疗爷']='疗爷:BAAALgAECgMJBgAAAA==.',
['百思']='百思骑姐:BAAALgAECgEJAQAAAA==.',
['盐酥']='盐酥鸡:BAAALgAECgIJAgAAAA==.',
['睡眠']='睡眠艺术家:BAAALgAECgkJCQAAAA==.',
['磐石']='磐石不动:BAAALgAECggJBwAAAA==.',
['神选']='神选的英雄:BAAALgAECgEJAQAAAA==.',
['福尔']='福尔马林:BAAALgAFFAEJAQAAAA==.',
['索林']='索林铜须:BAAALgAECgQJBAAAAA==.',
['红莲']='红莲业火:BAAALgAECgcJDAAAAA==.红莲圣骑:BAAALgAECggJCwAAAA==.',
['红鲷']='红鲷鱼:BAAALgAECgEJAQAAAA==.',
['纨绔']='纨绔结局丶:BAAALgAECgYJCAAAAA==.',
['肉个']='肉个蛋蛋:BAAALgAECgYJBwAAAA==.',
['胖蛟']='胖蛟:BAAALgADCgUJBQAAAA==.',
['芝麻']='芝麻酥糖:BAAALgAECgQJBAAAAA==.',
['芳泽']='芳泽堇:BAAALgAECgQJBwAAAA==.',
['苹果']='苹果很甜:BAAALgAECgYJCQAAAA==.',
['茴香']='茴香打卤面:BAAALgAECgkJCAABLgAFFAUJEAABAFIlAA==.',
['荣耀']='荣耀即生命:BAAALgADCgYJBgAAAA==.',
['萨满']='萨满和猫:BAAALgAECgEJAQAAAA==.',
['蒜香']='蒜香鸡翅:BAAALgAECgQJBAAAAA==.',
['薄西']='薄西山:BAAALgAECgEJAQAAAA==.',
['藤原']='藤原千花:BAAALgAECgQJBwAAAA==.',
['虾仁']='虾仁三鲜:BAAALgAECgMJBQAAAA==.',
['血色']='血色绯月:BAAALgADCgEJAQAAAA==.',
['被召']='被召唤的死骑:BAAALgAECgUJBQAAAA==.',
['訫若']='訫若葙依:BAAALgADCgEJAQAAAA==.',
['诅咒']='诅咒甲方:BAACLgAFFH8OAAICAAQJZBczBwBZAQACAAQJZBczBwBZAQAuAAQKfxsAAwIABwmUJFUXAMgCAAIABwmUJFUXAMgCAAoAAQkAAK9mAEIAAAAA.',
['诊所']='诊所鸽鸽:BAAALgAECgcJBwAAAA==.',
['请甲']='请甲方洗脚:BAAALgAECgcJEAABLgAFFAQJDgACAGQXAA==.',
['豆四']='豆四:BAAALgAECgIJBAAAAA==.',
['豆神']='豆神:BAAALgADCgQJBAAAAA==.',
['跳跳']='跳跳舞刹刹人:BAAALgADCgUJBQAAAA==.',
['达达']='达达里奥:BAAALgAECgMJAwAAAA==.',
['迪斯']='迪斯菲洛亚:BAAALgAFFAEJAQAAAA==.',
['迷莉']='迷莉:BAAALgADCgQJBAAAAA==.',
['追憶']='追憶思雨:BAAALgAECgUJCAAAAA==.',
['那个']='那个奶森:BAAALgAECgEJAQAAAA==.',
['锦琪']='锦琪儿:BAACLgAFFH8JAAIVAAMJrxCfCADeAAAVAAMJrxCfCADeAAAuAAQKfyIAAhUACAnYG0cDAEQCABUACAnYG0cDAEQCAAAA.',
['阿尔']='阿尔兽斯:BAAALgAECgYJBgAAAA==.',
['阿溪']='阿溪:BAABLgAFFH8HAAIWAAMJmxCoDQAQAQAWAAMJmxCoDQAQAQABLgAFFAUJAgAGAAAAAA==.',
['陌上']='陌上:BAAALgAECgEJAgAAAA==.',
['韩立']='韩立:BAAALgAECgcJCgAAAA==.',
['風行']='風行者的诺言:BAAALgAECgUJDgAAAA==.',
['风清']='风清:BAAALgAECgYJCQAAAA==.',
['飘逸']='飘逸凌风:BAAALgAECgcJCwAAAA==.',
['飘雪']='飘雪兜风:BAABLgAFFH8GAAIBAAIJASJzMwDNAAABAAIJASJzMwDNAAAAAA==.',
['香菇']='香菇炖鸡面:BAAALgAECgQJBAAAAA==.',
['鲨人']='鲨人男孩:BAAALgADCgUJBQAAAA==.',
['鸡蛋']='鸡蛋灌饼:BAAALgAECgEJAQAAAA==.',
['龍燐']='龍燐:BAAALgAFFAEJAQAAAA==.',
['龙墨']='龙墨墨呦:BAABLgAFFH8GAAMMAAIJhRr9HgCaAAAMAAIJVw39HgCaAAALAAEJeB+fGABhAAAAAA==.',
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
