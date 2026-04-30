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

local lookup = {'Warlock-Demonology','Warlock-Destruction','DeathKnight-Unholy','Monk-Mistweaver','Unknown-Unknown','Evoker-Preservation','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Elemental','Shaman-Restoration','Paladin-Retribution','Evoker-Augmentation','Paladin-Protection','Mage-Frost','Priest-Discipline','Priest-Holy','Priest-Shadow','DemonHunter-Devourer','DemonHunter-Vengeance','Evoker-Devastation',}
local provider = {region='CN',realm='盖斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Anonyme:BAAALgADCgUJBQAAAA==.',
Ar='Aries:BAAALgAECgUJCwAAAA==.',
Be='Beanzi:BAAALgAFFAEJAQAAAA==.',
Bi='Bikini:BAAALgADCgYJBgAAAA==.',
Ca='Cassandra:BAAALgADCgcJBwAAAA==.',
De='Deco:BAACLgAFFH8FAAMBAAQJoAk0FQDwAAABAAMJBAw0FQDwAAACAAEJdAKuCABBAAAuAAQKfxUAAwIABgnRFDk8AMMAAAEABAm7FtOlAA0BAAIAAwk4ETk8AMMAAAAA.',
Di='Disorder:BAAALgAFFAEJAQAAAA==.',
Fa='Farshore:BAAALgAECgUJBQAAAA==.',
Gr='Grape:BAAALgAECgIJAQAAAA==.',
Hl='Hlkho:BAAALgAFFAEJAQAAAA==.',
Ji='Jingfeng:BAAALgAECgcJDgAAAA==.',
Lu='Luciferss:BAAALgAECgQJBAAAAA==.',
Ma='Maii:BAAALgAECgkJDwAAAA==.Markbs:BAAALgAECgYJBgAAAA==.',
Mi='Mikea:BAAALgADCgEJAQAAAA==.Mikeb:BAAALgADCgcJCAAAAA==.',
Na='Navzul:BAABLgAFFH8FAAIDAAMJSBR+JgD9AAADAAMJSBR+JgD9AAABLgAFFAQJDgAEAFEVAA==.',
Nm='Nmtty:BAAALgAECgkJCAAAAA==.',
Pa='Pandabasi:BAAALgAECgQJBAAAAA==.',
Pe='Pescado:BAAALgADCgQJBAABLgAFFAIJBAAFAAAAAA==.',
Si='Silvan:BAABLgAFFH8QAAIGAAQJgxd6BABKAQAGAAQJgxd6BABKAQAAAA==.',
To='Tom:BAABLgAECn8TAAMHAAgJEx7zIQA5AgAHAAgJEx7zIQA5AgAIAAUJTBc/RgA7AQAAAA==.',
Yi='Yiyo:BAAALgAECgYJBgAAAA==.',
['Íc']='Ícèü:BAAALgAFFAIJAwAAAA==.',
['一只']='一只咸鱼怪:BAAALgAECgcJBwAAAA==.',
['一夜']='一夜仙:BAAALgAECgEJAQAAAA==.',
['一扁']='一扁一:BAAALgAECgYJBgAAAA==.',
['万籁']='万籁俱寂:BAAALgAECgYJCgAAAA==.',
['不困']='不困:BAAALgADCgEJAQAAAA==.',
['不怕']='不怕冷:BAAALgAECgIJAQAAAA==.',
['与欲']='与欲娱余生:BAAALgADCgMJAwAAAA==.',
['丝奇']='丝奇怎么玩丶:BAABLgAECn8dAAIDAAcJERazXQDZAQADAAcJERazXQDZAQAAAA==.',
['丹阳']='丹阳殿下:BAAALgAECgEJAQAAAA==.',
['为爱']='为爱灬鼓掌:BAAALgAECgkJCQAAAA==.',
['九灬']='九灬娘:BAAALgAECgkJCQAAAA==.',
['乩术']='乩术:BAAALgADCgEJAQAAAA==.',
['乱步']='乱步雲端:BAAALgADCgMJAwAAAA==.',
['二少']='二少爺:BAAALgAFFAIJAgAAAA==.',
['云思']='云思悠然:BAAALgAECgUJBQAAAA==.',
['五一']='五一:BAAALgAECgYJCQAAAA==.',
['伊俐']='伊俐砃丶怒風:BAAALgAFFAEJAQAAAA==.',
['伊斯']='伊斯佩尔:BAAALgAECgYJEAAAAA==.',
['众神']='众神谎言:BAAALgAECgQJBQAAAA==.',
['传说']='传说中的三鞭:BAABLgAECn8XAAMJAAcJPghqQQBDAQAJAAcJPghqQQBDAQAKAAMJ0QH2iQBsAAAAAA==.',
['你头']='你头像真牛:BAAALgAECgMJBAAAAA==.',
['你巳']='你巳经:BAAALgAECgUJCAAAAA==.',
['依古']='依古依古:BAAALgAECgEJAQAAAA==.',
['倾城']='倾城丷轩辕:BAAALgAECgYJCwAAAA==.',
['光影']='光影独行:BAAALgAECgYJCwAAAA==.',
['兔兔']='兔兔大魔王丶:BAAALgADCgUJBQAAAA==.',
['八戒']='八戒大官人:BAAALgADCgEJAQAAAA==.',
['其实']='其实我是蛋蛋:BAAALgADCgcJCgAAAA==.',
['农村']='农村非主流:BAAALgAECgEJAQAAAA==.',
['冥音']='冥音:BAAALgAECgEJAgAAAA==.',
['冬枫']='冬枫:BAABLgAECn8XAAILAAcJIBEnZQC2AQALAAcJIBEnZQC2AQAAAA==.',
['冬莉']='冬莉:BAAALgAECgYJBgAAAA==.',
['冰镇']='冰镇西瓜汁:BAAALgADCgEJAQAAAA==.',
['冷吃']='冷吃兔:BAAALgAECgEJAQAAAA==.',
['凤呈']='凤呈风暴烈酒:BAAALgADCgEJAQAAAA==.',
['千娅']='千娅:BAAALgADCgEJAQAAAA==.',
['千岛']='千岛一点红:BAAALgAECgEJAQAAAA==.',
['午夜']='午夜杀鸡:BAAALgADCggJCAAAAA==.',
['卡哇']='卡哇伊宝贝:BAAALgAECgEJAQABLgAFFAQJCAAMAIgKAA==.',
['叁脚']='叁脚:BAAALgAFFAEJAQAAAA==.',
['右灬']='右灬边:BAAALgAECgkJEAAAAA==.',
['后来']='后来再未见过:BAAALgADCgEJAQAAAA==.',
['命运']='命运神骑:BAABLgAECn8UAAMLAAYJvQ8owAAHAQALAAUJbREowAAHAQANAAEJ/Ai5RgAmAAAAAA==.',
['哆啦']='哆啦币梦:BAABLgAECn8UAAIOAAcJ/hTfegDcAQAOAAcJ/hTfegDcAQAAAA==.',
['哥半']='哥半仙:BAAALgAECgcJEQAAAA==.',
['哦在']='哦在这停顿:BAAALgAECgEJAQAAAA==.',
['唐三']='唐三葬:BAAALgAECgcJBwAAAA==.',
['四分']='四分五猎:BAAALgAECgQJBAAAAA==.',
['四喜']='四喜丸师妹:BAAALgAECgUJBgAAAA==.',
['四灬']='四灬灬季:BAAALgAECgkJAQAAAA==.',
['回眸']='回眸依旧:BAAALgADCgYJCQAAAA==.',
['圣灬']='圣灬鍅:BAAALgADCgEJAQAAAA==.',
['地狱']='地狱夫人:BAAALgAECgYJBgABLgAFFAUJEgAPAD0eAA==.',
['基德']='基德:BAAALgAECgEJAQAAAA==.',
['塞克']='塞克熊猫:BAACLgAFFH8HAAIKAAQJURzUBQBtAQAKAAQJURzUBQBtAQAuAAQKfxwAAgoACAmJJO4CAE8DAAoACAmJJO4CAE8DAAAA.',
['天南']='天南盖地虎:BAAALgADCgYJBgAAAA==.',
['失落']='失落的心灵:BAAALgADCgEJAQAAAA==.',
['好硬']='好硬:BAAALgAFFAQJAgAAAA==.',
['好酒']='好酒不溅:BAAALgAECgIJAgAAAA==.',
['妮妮']='妮妮天使:BAAALgAECgYJBgAAAA==.',
['孤二']='孤二蛋治撸:BAAALgAECgYJBwAAAA==.',
['守护']='守护个大怪兽:BAAALgAECgUJCQAAAA==.',
['小奈']='小奈家姐:BAABLgAECn8VAAMQAAYJyBh6MwBxAQAQAAUJ2Bl6MwBxAQARAAYJwQyQOwAWAQAAAA==.',
['小宗']='小宗师:BAAALgAECggJCAABLgAECgcJHgARANwbAA==.',
['小风']='小风:BAAALgAECgIJAgAAAA==.',
['少侠']='少侠好功夫:BAAALgAECgIJAgAAAA==.',
['就是']='就是为了萌:BAAALgAECgIJAgAAAA==.',
['巽完']='巽完二:BAAALgADCgMJAwAAAA==.',
['幽幽']='幽幽黎歌:BAAALgAECgEJAQAAAA==.',
['很美']='很美味:BAAALgAECgYJCwAAAA==.',
['御清']='御清风:BAAALgAECgEJAQAAAA==.',
['德鲁']='德鲁大叔:BAAALgADCgUJBwAAAA==.',
['怕鬼']='怕鬼:BAAALgAECgIJAQAAAA==.',
['怪獣']='怪獣:BAAALgAECgEJAQAAAA==.',
['悲剧']='悲剧战:BAAALgAECgEJAQAAAA==.',
['愛羅']='愛羅丶星矢:BAAALgAECgMJAQAAAA==.',
['我不']='我不认识你:BAAALgAECgUJBQAAAA==.',
['我的']='我的牙齿很尖:BAAALgAECgYJCQAAAA==.',
['我頭']='我頭上有犄角:BAABLgAFFH8FAAISAAMJexfFGQACAQASAAMJexfFGQACAQAAAA==.',
['或昱']='或昱或愚:BAACLgAFFH8PAAIIAAQJdiEtAQCFAQAIAAQJdiEtAQCFAQAuAAQKfx0AAggACAkRI84HAB4DAAgACAkRI84HAB4DAAAA.',
['拯救']='拯救自己:BAAALgADCgEJAQAAAA==.',
['拾贰']='拾贰巴:BAAALgAECgYJBgAAAA==.',
['擘开']='擘开大髀晒夹:BAAALgADCgUJBQAAAA==.',
['斯巴']='斯巴达灬死神:BAAALgADCgUJBQAAAA==.',
['星嵐']='星嵐:BAAALgADCgYJBgAAAA==.',
['春心']='春心一荡漾:BAAALgAECgYJCgAAAA==.',
['是你']='是你的益达:BAAALgAECgYJCwAAAA==.',
['晓碗']='晓碗:BAAALgAFFAEJAQAAAA==.',
['暗影']='暗影圣堂:BAAALgAECgQJBQAAAA==.',
['曰成']='曰成丶:BAABLgAECn8YAAMSAAcJ4BvLRwDUAQASAAcJtRvLRwDUAQATAAUJshKQEABIAQAAAA==.',
['月巴']='月巴:BAAALgAECgIJAgAAAA==.',
['月舒']='月舒:BAABLgAFFH8IAAIEAAQJxgxNBgAKAQAEAAQJxgxNBgAKAQAAAA==.',
['末把']='末把椅:BAAALgADCgYJBgABLgAFFAQJCgAHAEocAA==.',
['杀式']='杀式殇:BAAALgAECgcJDAAAAA==.',
['梦成']='梦成:BAAALgAECgUJBQAAAA==.',
['梦洁']='梦洁:BAAALgAECgYJBgAAAA==.',
['梨花']='梨花妹妹:BAAALgAECgMJAwAAAA==.',
['極樂']='極樂淨土丶:BAAALgAECgYJEQABLgAFFAQJEAAGAIMXAA==.',
['水水']='水水猎:BAAALgAFFAIJBAAAAA==.',
['江月']='江月夜岚:BAAALgAECgIJAgAAAA==.',
['沐雨']='沐雨灵师:BAABLgAECn8gAAMPAAgJvyFdAQCzAgAPAAgJuyFdAQCzAgAQAAIJOiLLXQC7AAAAAA==.',
['沙滩']='沙滩之子:BAAALgAFFAIJBAAAAA==.',
['法力']='法力残渣啊:BAAALgAECgIJAgAAAA==.',
['波一']='波一波:BAAALgADCgcJBwAAAA==.',
['浴火']='浴火圣光:BAAALgADCgEJAQAAAA==.',
['涂抹']='涂抹心情:BAAALgAECgUJBgAAAA==.',
['涵情']='涵情陌陌:BAAALgADCgQJBAAAAA==.',
['灬無']='灬無丶趣:BAAALgAECgQJBAAAAA==.',
['熊猫']='熊猫警长:BAAALgAECgMJAwAAAA==.熊猫警长秘书:BAAALgAECgMJAwAAAA==.',
['熙决']='熙决:BAAALgAECgEJAQAAAA==.',
['熟手']='熟手啤胶员:BAAALgAECgYJBgAAAA==.',
['爱漂']='爱漂流的小鸭:BAAALgAECgQJBgAAAA==.',
['牙齿']='牙齿有点大:BAAALgAECgEJAQAAAA==.',
['猪猪']='猪猪爱哭:BAAALgADCgEJAQAAAA==.',
['甘乃']='甘乃迪:BAAALgAECgYJBgAAAA==.',
['留钱']='留钱玩:BAAALgAECgMJAwAAAA==.',
['神里']='神里绫华:BAAALgAECgIJAgAAAA==.',
['禾禾']='禾禾的老霸:BAAALgAECgEJAQAAAA==.',
['窝的']='窝的蝶:BAAALgADCgUJBQAAAA==.',
['红装']='红装素裹:BAAALgAFFAEJAgAAAA==.',
['绫贰']='绫贰:BAACLgAFFH8IAAIMAAQJiArBBwAkAQAMAAQJiArBBwAkAQAuAAQKfxkAAwwACAk+GP8TAEICAAwACAnsF/8TAEICABQABgnXDfgeADYBAAAA.',
['缓慢']='缓慢呼吸:BAAALgAECgEJAQAAAA==.',
['美洲']='美洲猎龙:BAAALgAECgEJAQAAAA==.',
['舒心']='舒心安然:BAAALgAECgEJAQAAAA==.',
['舟山']='舟山杰尼龟:BAAALgAFFAMJAwAAAA==.',
['艾薩']='艾薩拉斯星魂:BAAALgAECgMJBQAAAA==.',
['苒苒']='苒苒射手:BAAALgADCgIJAgAAAA==.',
['若水']='若水纷飞:BAAALgAFFAIJBAAAAA==.',
['莎尔']='莎尔银沙:BAAALgADCgEJAQAAAA==.',
['萌牛']='萌牛猛妞:BAAALgAECgEJAQAAAA==.',
['葛二']='葛二蛋:BAAALgAECgMJBgAAAA==.',
['葱花']='葱花鱼:BAAALgADCgUJBQAAAA==.',
['裤儿']='裤儿提拉丝:BAAALgAECgYJDAAAAA==.',
['请叫']='请叫我奶德:BAAALgAECgQJBAAAAA==.',
['贰拾']='贰拾巴:BAABLgAECn8eAAMGAAgJ7BuUCQCdAgAGAAgJ7BuUCQCdAgAMAAEJExWZJgBAAAAAAA==.贰拾陆:BAAALgAECgQJBAAAAA==.',
['跨海']='跨海:BAAALgAECgUJBQAAAA==.',
['跳起']='跳起一脚尖:BAAALgAECgcJDwAAAA==.',
['蹄里']='蹄里奥哞叮:BAAALgAECgUJBAAAAA==.',
['迷乱']='迷乱星光:BAAALgAECgMJBQAAAA==.',
['醉阳']='醉阳:BAAALgAECgQJAwAAAA==.',
['锦衣']='锦衣夜行:BAAALgAFFAEJAgAAAA==.',
['长夜']='长夜更漏难眠:BAAALgAECgYJBgAAAA==.',
['问君']='问君几多丑:BAAALgAECgEJAQAAAA==.',
['雪球']='雪球糖糖:BAAALgADCgkJCQAAAA==.',
['静流']='静流:BAAALgAECgYJCAAAAA==.',
['面纱']='面纱:BAAALgAECgYJDAAAAA==.',
['风行']='风行者:BAAALgAECgQJAQAAAA==.',
['骁勇']='骁勇羽毛:BAAALgAFFAEJAQAAAA==.',
['鬼术']='鬼术妖姬:BAAALgADCgQJBAABLgAECgIJAgAFAAAAAA==.',
['鹿大']='鹿大力丶:BAAALgAECgcJBwAAAA==.',
['黑夜']='黑夜逐风:BAAALgAECgIJBAAAAA==.',
['黑萌']='黑萌萌:BAAALgAECgYJBwAAAA==.',
['龙井']='龙井丶:BAAALgAECgEJAQAAAA==.',
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
