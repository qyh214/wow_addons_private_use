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

local lookup = {'Unknown-Unknown','DemonHunter-Devourer','DemonHunter-Vengeance','DeathKnight-Unholy','Priest-Shadow','Druid-Restoration','Rogue-Subtlety','Monk-Mistweaver','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Elemental','Paladin-Retribution','Priest-Discipline','DemonHunter-Havoc','Warlock-Demonology','Priest-Holy','Warrior-Arms','Warrior-Fury','Monk-Brewmaster','Evoker-Devastation','Evoker-Augmentation','Mage-Frost','Shaman-Restoration','Warlock-Affliction','Warlock-Destruction','Paladin-Holy','Warrior-Protection','Druid-Feral','Hunter-Survival','DeathKnight-Blood',}
local provider = {region='CN',realm='霜狼',name='CN',type='weekly',zone=46,date='2026-04-25',data={Am='Amadeus:BAAALgADCgUJBQAAAA==.',
An='Angelagaga:BAAALgAECgYJCgAAAA==.',
Ar='Armedforce:BAAALgAECgQJBAAAAA==.Arthurdk:BAAALgAECgQJBAAAAA==.',
Bi='Bibiwu:BAAALgAECgYJBgAAAA==.',
Bl='Blowingcloud:BAAALgAECgkJDgAAAA==.',
Bu='Bugyellow:BAAALgAECgMJAwAAAA==.',
Ca='Cakes:BAAALgAECgUJBQAAAA==.',
Cb='Cbreezy:BAAALgAECgYJDwAAAA==.',
Ci='Ciao:BAAALgAFFAMJAwAAAA==.',
Da='Darkwish:BAAALgAECgEJAQAAAA==.',
De='Deathknigth:BAAALgAECgMJAwAAAA==.Deron:BAAALgAECgIJAgAAAA==.',
Do='Dodog:BAAALgAECgEJAQAAAA==.',
Dr='Dragonman:BAAALgAECgIJAwABLgAECgcJCQABAAAAAA==.',
Ea='Eagle:BAACLgAFFH8TAAICAAYJmg5wBQDRAQACAAYJmg5wBQDRAQAuAAQKfyEAAwIACQklHsIYAMACAAIACQklHsIYAMACAAMAAQm0BX4PACQAAAAA.',
Eh='Ehco:BAAALgAECgYJBgAAAA==.',
Et='Ethans:BAAALgAECgEJAQAAAA==.',
Ex='Exdruid:BAAALgAECgIJAgAAAA==.',
Fa='Fandog:BAAALgAECgYJDQAAAA==.',
Ff='Ffkt:BAAALgADCgUJBQAAAA==.',
Fr='Frezix:BAAALgAECgYJCwAAAA==.',
Ge='Gettogether:BAAALgAECgYJCAAAAA==.',
Gl='Glasshearts:BAAALgAECgcJCgABLgAFFAQJBAABAAAAAA==.',
Gr='Gressi:BAAALgAECgkJCQAAAA==.',
Ka='Kalye:BAAALgAECgcJDAABLgAFFAQJBAABAAAAAA==.',
Kk='Kkoxoo:BAAALgAFFAEJAQAAAA==.',
Ko='Koi:BAAALgAECgcJCgAAAA==.',
La='Lays:BAAALgAECgUJCAAAAA==.',
Le='Leo:BAAALgAECgcJCAAAAA==.',
Li='Libraz:BAAALgAECgYJCwAAAA==.Lico:BAAALgAECgYJBgAAAA==.Linke:BAAALgAECgIJAwAAAA==.Lisztvon:BAAALgAECgEJAQAAAA==.',
Lo='Lochlin:BAAALgADCgUJAQAAAA==.Loveversm:BAAALgADCgIJAgAAAA==.',
Lu='Lucefer:BAAALgAECgQJBAAAAA==.',
Ma='Maxcom:BAAALgAECggJDwAAAA==.',
Me='Meliora:BAAALgADCgQJBAAAAA==.',
Mi='Miruki:BAAALgAECgYJBAAAAA==.',
Mo='Mournerm:BAABLgAFFH8IAAIEAAMJHh66JAACAQAEAAMJHh66JAACAQAAAA==.',
Pi='Pixle:BAAALgAECgEJAQAAAA==.',
Po='Pomme:BAABLgAFFH8MAAIFAAUJbSH+AACQAQAFAAUJbSH+AACQAQAAAA==.',
Qu='Ququweiwei:BAAALgAECgQJBAAAAA==.',
Ri='Riangy:BAAALgAECgcJBwABLgAFFAUJAQABAAAAAA==.',
Sa='Saberfate:BAAALgAECgIJAgAAAA==.Saberquen:BAAALgAECgQJBAAAAA==.',
Sp='Spell:BAAALgAECgQJBAAAAA==.',
Su='Sugoi:BAAALgAECgIJAwAAAA==.',
Ti='Tieophilus:BAAALgAECgIJAgAAAA==.',
Uk='Uka:BAAALgAECgYJCAAAAA==.',
Un='Unwakiarchon:BAAALgAECgcJEAAAAA==.',
Va='Valamorgulis:BAAALgAECgYJBgAAAA==.',
We='Weicom:BAAALgADCgkJCQAAAA==.',
Yi='Yip:BAAALgAECgkJAQAAAA==.',
Yk='Yk:BAAALgAECgEJAQAAAA==.',
['一个']='一个小晨曦:BAAALgAECgEJAQAAAA==.',
['一刀']='一刀九九久:BAAALgAECgEJAQAAAA==.',
['丁竹']='丁竹筒:BAAALgAECgQJBgAAAA==.',
['七十']='七十二:BAAALgAECgEJAQAAAA==.',
['七月']='七月丶白花:BAAALgAECgYJCAAAAA==.七月白花:BAACLgAFFH8IAAIGAAQJzQNvCgDeAAAGAAQJzQNvCgDeAAAuAAQKfxkAAgYACAleEx88ALQBAAYACAleEx88ALQBAAAA.',
['七根']='七根烟:BAAALgAECgMJAwAAAA==.',
['万象']='万象丶:BAAALgAECgMJAwAAAA==.',
['三丰']='三丰山一心:BAACLgAFFH8HAAIHAAMJZheaDAAbAQAHAAMJZheaDAAbAQAuAAQKfyEAAgcACQk8HIMFADoDAAcACQk8HIMFADoDAAAA.',
['三月']='三月宝宝:BAAALgAECgcJBwAAAA==.',
['三条']='三条烟:BAAALgADCgUJBQAAAA==.',
['上吧']='上吧丶皮卡丘:BAAALgADCgUJBQAAAA==.',
['上官']='上官芸瑶:BAABLgAFFH8LAAIIAAQJYQWFBwDfAAAIAAQJYQWFBwDfAAAAAA==.',
['下身']='下身带电:BAAALgAECgMJCQAAAA==.',
['不再']='不再寂寞了丶:BAACLgAFFH8PAAMJAAUJ2xG6AQCIAQAJAAUJ2xG6AQCIAQAKAAIJxQLTIQCGAAAuAAQKfxwAAwkACAkXIDwUAJUCAAkACAkXIDwUAJUCAAoAAgkOD1x5AFwAAAAA.',
['不接']='不接受反驳:BAAALgAECgYJBgAAAA==.',
['不浪']='不浪漫大明:BAAALgAECgUJCQAAAA==.',
['不玩']='不玩了掀桌子:BAAALgAECgYJEwAAAA==.',
['丝滑']='丝滑的冰脉:BAAALgAFFAEJAQAAAA==.',
['丨咕']='丨咕噜噜:BAAALgAECgIJAQABLgAFFAIJAgABAAAAAA==.',
['丶七']='丶七七和安安:BAAALgAFFAIJAwAAAA==.',
['丶云']='丶云先生:BAABLgAFFH8FAAILAAQJ5hnPBwBdAQALAAQJ5hnPBwBdAQAAAA==.',
['丶尕']='丶尕萍丨:BAAALgAECgEJAQAAAA==.',
['丶我']='丶我滴个乖乖:BAAALgAECgEJAQAAAA==.',
['丶柒']='丶柒月枫:BAACLgAFFH8HAAIMAAMJqxpEEgATAQAMAAMJqxpEEgATAQAuAAQKfx8AAgwACQn7JJkCALADAAwACQn7JJkCALADAAAA.',
['丶芜']='丶芜狐:BAAALgAECgEJAgAAAA==.',
['丶菀']='丶菀菀类卿:BAABLgAFFH8GAAMNAAQJTAI6CADwAAANAAQJTAI6CADwAAAFAAIJGgFEEgCBAAAAAA==.',
['丶遨']='丶遨游四海:BAACLgAFFH8KAAICAAQJYBDWCgAoAQACAAQJYBDWCgAoAQAuAAQKfxgAAwIACQnEHUENABUDAAIACQnEHUENABUDAA4ACQkMD74WABQCAAAA.',
['丿朔']='丿朔月:BAAALgAECgQJBAAAAA==.',
['丿浅']='丿浅叶情丶:BAAALgAECgEJAQAAAA==.',
['乃其']='乃其大:BAAALgAECgEJAwAAAA==.',
['乄夜']='乄夜丨魇:BAAALgAECgEJAQAAAA==.',
['乌龟']='乌龟的黑头儿:BAAALgADCgIJAgAAAA==.',
['九樱']='九樱:BAAALgAECgYJBgAAAA==.',
['乡下']='乡下头人:BAAALgAECgYJBwAAAA==.',
['买小']='买小开大:BAAALgAECgcJDAAAAA==.',
['乳酸']='乳酸菌菌:BAAALgADCgUJBwAAAA==.',
['二五']='二五四月十四:BAAALgAECgQJCQAAAA==.',
['亡者']='亡者勇生:BAAALgAECgEJAQAAAA==.亡者复苏丶灬:BAAALgAFFAEJAQAAAA==.',
['亡语']='亡语行者:BAAALgAECgIJAgAAAA==.',
['亲热']='亲热解毒蕉男:BAAALgAECgYJDAAAAA==.',
['仙路']='仙路尽谁为峰:BAAALgADCgEJAQAAAA==.',
['伊伊']='伊伊酱丷:BAAALgAFFAMJAwAAAA==.',
['伊利']='伊利丷优酸乳:BAAALgAECgEJAQAAAA==.伊利雷达总裁:BAAALgAECgEJAQAAAA==.',
['伊卡']='伊卡洛丶斯:BAAALgAFFAEJAQAAAA==.',
['伍公']='伍公子:BAABLgAFFH8KAAIPAAQJ4gj3DQAfAQAPAAQJ4gj3DQAfAQAAAA==.',
['伐开']='伐开心:BAACLgAFFH8XAAMQAAYJ0xHzAQCaAQAQAAUJEBXzAQCaAQANAAUJnQlEBgAsAQAuAAQKf0MABBAACQk3H/QGAN4CABAACQlhG/QGAN4CAA0ABwkjI/kGANUCAAUAAQksBPpmACsAAAAA.',
['休劳']='休劳瑞:BAAALgAFFAEJAQAAAA==.',
['优熊']='优熊:BAAALgADCgUJBQAAAA==.',
['会后']='会后空翻的猫:BAAALgAECgEJAQAAAA==.',
['伤害']='伤害贼高:BAAALgAECgEJAgAAAA==.',
['伽尔']='伽尔鲁什:BAACLgAFFH8QAAMRAAQJ2RuUAQBPAQASAAQJQhs0CABqAQARAAQJ/g2UAQBPAQAuAAQKfxUAAxIABwmPIEwnACECABIABgmzIEwnACECABEAAwlbISwHAC8BAAAA.',
['伽蓝']='伽蓝:BAAALgAECgEJAQAAAA==.',
['低调']='低调之华丽:BAAALgADCgEJAQAAAA==.',
['你还']='你还相信光吗:BAAALgAECgUJCAAAAA==.',
['你颠']='你颠你先上:BAAALgAECgQJBAAAAA==.',
['保加']='保加利亚吴京:BAAALgAECgMJAwAAAA==.',
['修仙']='修仙三点零:BAAALgAECggJDAAAAA==.',
['倒插']='倒插图腾:BAAALgADCgMJAwAAAA==.',
['元气']='元气橙:BAAALgAECgEJAQAAAA==.',
['光影']='光影双刃:BAAALgAECgEJAgAAAA==.',
['兔美']='兔美与熊吉:BAAALgADCgUJBQABLgAECgQJBQABAAAAAA==.',
['兜兜']='兜兜里有熊:BAAALgAECgEJAwAAAA==.',
['八巟']='八巟:BAAALgAECgEJAQAAAA==.',
['八荒']='八荒:BAAALgAECgMJAwAAAA==.',
['八面']='八面煞星:BAAALgAECgIJAgAAAA==.',
['关中']='关中屠夫:BAAALgAECgYJBwAAAA==.',
['养牛']='养牛的:BAAALgAECgEJAwAAAA==.',
['兽兽']='兽兽哥哥:BAAALgAECgQJBgAAAA==.',
['内个']='内个法湿:BAAALgAECgYJDwAAAA==.',
['内涵']='内涵射手:BAACLgAFFH8JAAIJAAQJgBRbBgA9AQAJAAQJgBRbBgA9AQAuAAQKfycAAwkACQmCHSoHAB0DAAkACQmCHSoHAB0DAAoABgmgCgJRAAkBAAAA.',
['册那']='册那队长:BAAALgAECgEJAQAAAA==.',
['冥渊']='冥渊星:BAABLgAFFH8IAAIEAAIJuhz5HQCnAAAEAAIJuhz5HQCnAAABLgAFFAYJBwAEAEUUAA==.',
['冰凝']='冰凝霜华:BAAALgAECgQJBQAAAA==.',
['冰障']='冰障硬硬哒:BAACLgAFFH8UAAITAAYJgA6NAgDFAQATAAYJgA6NAgDFAQAuAAQKfyAAAhMACQluH8UIAPsCABMACQluH8UIAPsCAAAA.',
['冰風']='冰風丶:BAAALgAECgkJCAAAAA==.',
['列奥']='列奥德罗:BAAALgADCgkJCQAAAA==.',
['刘宝']='刘宝英:BAAALgADCgEJAQAAAA==.',
['刮萨']='刮萨:BAAALgADCgEJAQAAAA==.',
['力苏']='力苏:BAAALgAECgQJCAAAAA==.',
['加拉']='加拉哈德:BAAALgAECgkJDwAAAA==.',
['勿语']='勿语论:BAAALgAECgEJAQAAAA==.',
['十三']='十三巭孬:BAAALgADCgEJAQAAAA==.',
['午时']='午时到没到:BAAALgAECgEJAQAAAA==.',
['半抹']='半抹笑颜灬:BAAALgAFFAIJBAAAAA==.',
['卖糖']='卖糖果的蜀黍:BAAALgAECgYJDwAAAA==.',
['卖萌']='卖萌摩尔丶:BAAALgAFFAEJAQAAAA==.',
['卡尔']='卡尔丶血蹄:BAABLgAECn8dAAMJAAgJ3CJpCAALAwAJAAgJ3CJpCAALAwAKAAYJTQdxVAD4AAAAAA==.',
['卡樂']='卡樂逼:BAAALgAECgQJCAAAAA==.',
['卡薩']='卡薩諾:BAAALgAFFAEJAQAAAA==.',
['卤粉']='卤粉五号:BAAALgADCgUJAQAAAA==.',
['卷土']='卷土再来:BAAALgAECgIJAgAAAA==.',
['原始']='原始部落酋长:BAAALgADCgUJBQAAAA==.',
['叁暧']='叁暧:BAAALgAECgYJBwAAAA==.',
['又快']='又快又强:BAAALgAECgEJAwAAAA==.',
['古德']='古德白:BAABLgAFFH8FAAISAAIJ5hNZGACnAAASAAIJ5hNZGACnAAAAAA==.',
['只因']='只因鲵太美:BAACLgAFFH8SAAMUAAYJPxKuAQCJAQAVAAUJPxLGBQCjAQAUAAUJnAeuAQCJAQAuAAQKfyEAAxUACQnNIHcDAGUDABUACQn/H3cDAGUDABQABwkDIjoGAJICAAAA.',
['叮丶']='叮丶:BAAALgAFFAEJAQAAAA==.',
['可乐']='可乐配辣条:BAABLgAECn8cAAIWAAgJXxZMTQBPAgAWAAgJXxZMTQBPAgAAAA==.',
['可爱']='可爱的小西西:BAABLgAFFH8FAAIXAAIJVANuHACEAAAXAAIJVANuHACEAAAAAA==.可爱萌新:BAAALgAECgcJDQAAAA==.',
['吹云']='吹云:BAAALgAECggJCAAAAA==.',
['吹散']='吹散的记忆:BAAALgAFFAIJAgAAAA==.',
['吾女']='吾女名王梓汐:BAAALgADCgEJAQAAAA==.',
['吾惜']='吾惜:BAAALgAECgYJDAABLgAFFAQJCgAJAMUTAA==.',
['呐个']='呐个谁:BAAALgAECgEJAQABLgAFFAYJEgAUAD8SAA==.',
['咔咔']='咔咔叽叽:BAAALgAECgQJBAAAAA==.',
['咕咕']='咕咕哒:BAAALgAFFAIJAgAAAA==.咕咕德卤鸡:BAAALgAFFAIJAgAAAA==.',
['咖啡']='咖啡德:BAAALgAFFAEJAQAAAA==.咖啡鸦:BAAALgAECgIJAgAAAA==.',
['咸酸']='咸酸菜炒牛亥:BAAALgAECgcJEQAAAA==.',
['哈基']='哈基米曼波:BAAALgAECgIJAwAAAA==.',
['哈籟']='哈籟尼尔:BAAALgAECggJBwAAAA==.',
['哈那']='哈那油:BAAALgAFFAEJAQAAAA==.',
['响彻']='响彻忝堂:BAAALgAECgEJAwAAAA==.',
['哎呀']='哎呀:BAAALgAECgMJBAAAAA==.',
['唔得']='唔得就返顺德:BAAALgAECgUJBQAAAA==.',
['啊嘛']='啊嘛闹:BAAALgAECgQJCAAAAA==.',
['啊祖']='啊祖:BAABLgAFFH8GAAIEAAMJfxAYLQDnAAAEAAMJfxAYLQDnAAAAAA==.',
['啧丶']='啧丶萌萌哒:BAACLgAFFH8FAAIHAAMJ7xokCQDDAAAHAAMJ7xokCQDDAAAuAAQKfxcAAgcACAnwIEEHABwDAAcACAnwIEEHABwDAAAA.',
['啪啪']='啪啪趴趴:BAAALgAECgkJEgAAAA==.',
['嗨飞']='嗨飞仔:BAAALgAECgEJAQAAAA==.',
['嗷呜']='嗷呜嗷呜丶:BAAALgAECgYJCQAAAA==.',
['噬雪']='噬雪残阳:BAAALgAECgkJEwAAAA==.',
['四目']='四目道长:BAAALgAECgEJAQAAAA==.',
['回忆']='回忆那么苦:BAAALgADCgUJBQAAAA==.',
['回转']='回转炮:BAAALgAECgEJAQAAAA==.',
['回风']='回风抚柳:BAAALgAECgkJBgABLgAECgkJFwAJAGkcAA==.',
['团灭']='团灭发动机:BAAALgAECgkJCQAAAA==.',
['园原']='园原杏里:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光之獠牙:BAAALgAECgcJDQAAAA==.圣光小喵喵:BAAALgAECgIJAgAAAA==.圣光永再:BAAALgAECgkJDgAAAA==.圣光罩不住奶:BAAALgAECgEJAwAAAA==.圣光降临丶灬:BAAALgAECgkJBwAAAA==.',
['埋伏']='埋伏等你好污:BAAALgAECgMJAwAAAA==.',
['埋街']='埋街饮井水:BAAALgAECgcJBwAAAA==.',
['堇色']='堇色:BAAALgAFFAIJBAAAAA==.',
['堕天']='堕天:BAAALgADCgUJBQAAAA==.',
['墨染']='墨染剑霜:BAAALgAECgEJAQAAAA==.',
['夏慕']='夏慕丶:BAAALgAECgYJDgAAAA==.',
['夙夜']='夙夜黑:BAACLgAFFH8RAAQYAAUJRiYfAADLAQAYAAQJ/yQfAADLAQAPAAQJXyQICwCDAQAZAAEJAADhEABeAAAuAAQKfx4ABA8ACAn4JX4UANoCAA8ABwnTJX4UANoCABgABAmWJhQIAMwBABkAAgmlJeI3ANUAAAAA.',
['多啦']='多啦没有房:BAAALgAECgYJBgAAAA==.',
['夜后']='夜后禁锢:BAABLgAFFH8FAAIMAAMJDhdeCwAJAQAMAAMJDhdeCwAJAQAAAA==.',
['夜雨']='夜雨清荷:BAAALgAFFAIJAwAAAA==.',
['大不']='大不了死死:BAABLgAECn8XAAMZAAYJmyDSCQAjAgAZAAYJmyDSCQAjAgAPAAEJ0Ax6GQE1AAAAAA==.',
['大壑']='大壑:BAAALgADCgQJBQAAAA==.',
['大跳']='大跳开怪秒躺:BAAALgAECgYJBgABLgAFFAUJCQAZANghAA==.',
['大锅']='大锅锅:BAAALgAFFAIJAwAAAA==.',
['大陵']='大陵墟:BAAALgADCgEJAQAAAA==.',
['天涯']='天涯丶圣光:BAAALgAECgUJBQAAAA==.',
['天然']='天然萌:BAAALgAECgMJAwAAAA==.',
['天空']='天空与海:BAAALgAECgUJBgABLgAFFAYJFwAQANMRAA==.',
['天蝎']='天蝎座丶影子:BAAALgADCgQJAgAAAA==.',
['失绵']='失绵:BAAALgAECgYJCgAAAA==.',
['奥威']='奥威娜:BAAALgAECgEJAQAAAA==.',
['女和']='女和尚:BAAALgAECgEJAQAAAA==.',
['女搜']='女搜查官:BAAALgADCgEJAQAAAA==.',
['奶油']='奶油蛋烘糕:BAACLgAFFH8JAAIEAAMJtQvSIACgAAAEAAMJtQvSIACgAAAuAAQKfyMAAgQACQnCHdUYAOcCAAQACQnCHdUYAOcCAAAA.',
['奶粉']='奶粉子:BAABLgAECn8XAAMOAAcJuBRuMgBCAQAOAAYJXRduMgBCAQACAAYJOAcRUABcAAAAAA==.',
['好吃']='好吃宝橙子酱:BAAALgADCgEJAQAAAA==.',
['如此']='如此惊人:BAAALgAECgEJAQAAAA==.',
['妃兹']='妃兹旺达:BAAALgAFFAEJAQAAAA==.',
['妃滋']='妃滋旺达:BAAALgAECgcJDAABLgAFFAEJAQABAAAAAA==.',
['妖那']='妖那升:BAAALgAECgIJBAAAAA==.',
['妞比']='妞比:BAAALgAECgcJCAAAAA==.',
['姬柊']='姬柊雪菜:BAAALgAECgcJBgABLgAFFAUJBQACAFYJAA==.',
['娅波']='娅波纶:BAAALgAECgEJAgAAAA==.',
['娜格']='娜格瓦灬月影:BAAALgAECgYJBgAAAA==.',
['婧婧']='婧婧宝贝:BAAALgAECgUJBQAAAA==.',
['孟德']='孟德丶曹贼:BAAALgADCgYJBgAAAA==.',
['孤灯']='孤灯夜影丶灬:BAAALgAECgkJEAAAAA==.',
['寂寞']='寂寞冰糖雪糕:BAAALgAECgcJBAAAAA==.寂寞素素雪糕:BAAALgAECgUJBAAAAA==.寂寞雨文雪糕:BAAALgADCgYJBQAAAA==.',
['寒丶']='寒丶殇:BAAALgAECgEJAQAAAA==.',
['寒殇']='寒殇:BAACLgAFFH8MAAIMAAUJEiHWAQD8AQAMAAUJEiHWAQD8AQAuAAQKfyAAAgwACQlxJmgAAPMDAAwACQlxJmgAAPMDAAAA.',
['寒芒']='寒芒逐光:BAACLgAFFH8GAAIWAAMJNhk4JAAlAQAWAAMJNhk4JAAlAQAuAAQKfyIAAhYACAmqJNsGAGECABYACAmqJNsGAGECAAAA.',
['寻迹']='寻迹:BAACLgAFFH8GAAIaAAQJMg/RCQA7AQAaAAQJMg/RCQA7AQAuAAQKfxQAAxoABwmAFNg0AKkBABoABwmAFNg0AKkBAAwAAgnNB7QmAVIAAAAA.',
['小二']='小二:BAAALgAECgYJBwAAAA==.',
['小刘']='小刘不爱吃肉:BAAALgAFFAIJAgAAAA==.',
['小城']='小城小恋:BAAALgAECgEJAgAAAA==.',
['小妖']='小妖精:BAAALgAECgEJAQAAAA==.',
['小小']='小小粉丝:BAAALgAECgEJAQAAAA==.',
['小核']='小核桃肉:BAAALgAECgEJAQAAAA==.',
['小猫']='小猫饭团:BAAALgAECgYJBgAAAA==.',
['小耳']='小耳朵呀:BAAALgAECgEJAQAAAA==.',
['小耶']='小耶十一:BAABLgAFFH8JAAICAAUJHRndCACaAQACAAUJHRndCACaAQAAAA==.',
['小肉']='小肉丁:BAAALgAECgYJBgAAAA==.',
['小肥']='小肥飞:BAAALgAECgEJAwAAAA==.',
['小苏']='小苏联:BAABLgAECn8XAAIMAAkJayAMBQB7AwAMAAkJayAMBQB7AwAAAA==.',
['小茶']='小茶小小茶:BAAALgAECgMJAwAAAA==.',
['小鱼']='小鱼牌电池:BAAALgAFFAEJAQAAAA==.',
['尐宇']='尐宇:BAAALgAECgMJAwAAAA==.',
['少年']='少年游:BAAALgAECgYJCAAAAA==.',
['尕宣']='尕宣:BAAALgAECgYJBgAAAA==.尕宣宣:BAAALgAECgYJBQAAAA==.',
['尕尕']='尕尕宣:BAAALgADCgIJAgAAAA==.',
['尘缘']='尘缘随风:BAAALgAFFAQJAgAAAA==.',
['尤朵']='尤朵拉丶血蹄:BAAALgAECgQJBAAAAA==.',
['就这']='就这样落幕:BAABLgAFFH8GAAMXAAMJNhJXDwCRAAAXAAMJNhJXDwCRAAALAAIJ/wEdGgCAAAAAAA==.',
['工藤']='工藤老弟:BAAALgAECgUJBgAAAA==.',
['左手']='左手插图腾:BAAALgADCgEJAQAAAA==.',
['左迪']='左迪洛斯:BAABLgAFFH8GAAIVAAMJ2RzgBwAiAQAVAAMJ2RzgBwAiAQAAAA==.',
['巫丶']='巫丶基:BAABLgAFFH8IAAIPAAQJ/CRgAQC5AQAPAAQJ/CRgAQC5AQAAAA==.',
['巫喵']='巫喵王:BAAALgAECggJBQAAAA==.',
['巫镜']='巫镜:BAAALgAECgEJAQAAAA==.',
['己狸']='己狸丶:BAAALgAECgcJCAAAAA==.',
['巽芳']='巽芳:BAAALgAECgIJAgAAAA==.',
['布莱']='布莱特妞妞:BAAALgAFFAIJAgAAAA==.',
['师妹']='师妹不够他爽:BAAALgAECgYJEgAAAA==.',
['师姐']='师姐:BAAALgAFFAIJAgAAAA==.',
['希尔']='希尔维文:BAAALgAFFAIJAwAAAA==.',
['帝国']='帝国猛虎:BAAALgAFFAIJAgABLgAFFAMJBAABAAAAAA==.',
['席八']='席八:BAAALgAECgEJAQAAAA==.',
['平淡']='平淡的色彩:BAAALgAECgEJAQAAAA==.',
['幼儿']='幼儿园园长:BAAALgAECgYJCgAAAA==.',
['弓摧']='弓摧南山虎:BAAALgADCgEJAQAAAA==.',
['引力']='引力坍缩:BAAALgAFFAEJAQAAAA==.',
['张一']='张一澜:BAAALgAFFAQJBAAAAA==.',
['张三']='张三澜:BAABLgAFFH8FAAITAAUJjhemAwBZAQATAAUJjhemAwBZAQAAAA==.',
['张二']='张二澜:BAABLgAFFH8IAAITAAUJJBmjCQA9AQATAAUJJBmjCQA9AQAAAA==.',
['张五']='张五澜:BAABLgAFFH8OAAITAAUJdh0AAwC2AQATAAUJdh0AAwC2AQAAAA==.',
['张四']='张四澜:BAABLgAFFH8JAAITAAUJhh3sDQAVAQATAAUJhh3sDQAVAQAAAA==.',
['很帅']='很帅不撩妹丶:BAAALgAECgQJBAAAAA==.',
['微醺']='微醺岁月:BAAALgAECgkJEgABLgAFFAUJBQAGAJkcAA==.',
['徳豺']='徳豺煎狈:BAAALgAECgEJAQAAAA==.',
['德莱']='德莱联丶泰丹:BAABLgAFFH8FAAIbAAMJewNwCgCkAAAbAAMJewNwCgCkAAAAAA==.',
['忘想']='忘想症丶:BAAALgADCgEJAQAAAA==.',
['忧郁']='忧郁男:BAAALgAECgYJCAAAAA==.忧郁的猫猫:BAAALgAECgMJAwAAAA==.',
['快拨']='快拨夭夭灵:BAAALgAECgkJEAAAAA==.',
['恶之']='恶之序曲:BAAALgAFFAIJAgAAAA==.',
['恶魔']='恶魔羊:BAAALgAECgYJBgABLgAFFAcJCwATAM0PAA==.',
['悠闲']='悠闲小猎:BAAALgAECgUJBQAAAA==.',
['惊呆']='惊呆小伙伴:BAAALgAECgYJBwAAAA==.惊呆小朋友:BAAALgAECgQJBAAAAA==.',
['惡魔']='惡魔血刃:BAAALgAECgEJAQAAAA==.',
['愛別']='愛別離:BAAALgAECgEJAgAAAA==.',
['愿肾']='愿肾光照耀你:BAAALgAECgYJDwAAAA==.',
['懦夫']='懦夫克星:BAAALgADCgEJAQAAAA==.',
['我先']='我先闪你随意:BAACLgAFFH8HAAIWAAMJxw2UGQD2AAAWAAMJxw2UGQD2AAAuAAQKfxYAAhYABwnXFpkjAGUBABYABwnXFpkjAGUBAAAA.',
['我好']='我好脆弱:BAAALgADCgEJAQAAAA==.',
['我的']='我的刀盾:BAAALgAECgYJBwAAAA==.',
['战浮']='战浮云:BAAALgAECgYJCAAAAA==.',
['手留']='手留余香:BAAALgAECgEJAgAAAA==.',
['打酱']='打酱油的小白:BAAALgAECgEJAQAAAA==.',
['扯线']='扯线木偶:BAACLgAFFH8QAAIKAAQJlRqtAgA1AQAKAAQJlRqtAgA1AQAuAAQKfyIAAgoACAknHoABAAwCAAoACAknHoABAAwCAAAA.',
['扶老']='扶老登闯红灯:BAAALgAECgEJAQAAAA==.',
['折戟']='折戟丶沉沙:BAAALgADCgcJBwAAAA==.',
['拉糖']='拉糖门全程躺:BAAALgAECgMJAwAAAA==.',
['拳斗']='拳斗萝:BAAALgAECgkJEAABLgAFFAYJFAATAIAOAA==.',
['挥舞']='挥舞辣条斬殺:BAAALgAECgYJCgAAAA==.',
['掂过']='掂过碌蔗:BAAALgAECgQJAwAAAA==.',
['摸鱼']='摸鱼儿:BAAALgAECgIJAgAAAA==.',
['放开']='放开那个娘们:BAAALgAECgYJCwAAAA==.',
['斯卡']='斯卡雷特血刃:BAAALgAECgYJAQAAAA==.',
['方便']='方便面确实好:BAAALgAECgYJBgAAAA==.',
['无天']='无天大师:BAAALgAECgQJBwAAAA==.',
['无敌']='无敌大佬肖:BAAALgADCgYJBgAAAA==.',
['无缘']='无缘纱:BAAALgADCggJCAAAAA==.',
['昂格']='昂格洛玛:BAAALgAECgYJEQAAAA==.',
['明日']='明日香丶:BAABLgAFFH8FAAIPAAUJHxYbBgC/AQAPAAUJHxYbBgC/AQAAAA==.',
['星月']='星月旋律:BAAALgAECgEJAQAAAA==.',
['星释']='星释来苏:BAAALgAECgcJDQAAAA==.',
['春野']='春野奈:BAAALgAFFAMJAwAAAA==.',
['春黛']='春黛秋根:BAAALgAECgEJAgAAAA==.',
['昭水']='昭水草明:BAAALgAECgEJAQAAAA==.',
['景严']='景严:BAAALgAECgYJCgAAAA==.',
['暖暖']='暖暖就是胖妞:BAAALgAECgEJAQAAAA==.',
['曦宝']='曦宝灬九:BAAALgAECgEJAQAAAA==.',
['曦曦']='曦曦妈妈:BAAALgAECgEJAQAAAA==.',
['曾經']='曾經純屬回憶:BAAALgAECgEJAwAAAA==.',
['月下']='月下彼端:BAACLgAFFH8HAAIWAAIJgiZwMQDnAAAWAAIJgiZwMQDnAAAuAAQKfyIAAhYACQk1JScDAMwDABYACQk1JScDAMwDAAAA.',
['月亮']='月亮伊布:BAABLgAFFH8NAAIcAAQJMiUPAADEAQAcAAQJMiUPAADEAQABLgAFFAUJDAAFAG0hAA==.',
['月半']='月半女丑:BAAALgAFFAEJAgAAAA==.',
['月夏']='月夏之恋:BAAALgAECgEJAgAAAA==.',
['月小']='月小柒:BAABLgAECn8YAAIWAAcJ/xqcXQAhAgAWAAcJ/xqcXQAhAgAAAA==.',
['月巴']='月巴亻子:BAAALgAECgUJBQAAAA==.',
['月影']='月影輕殤:BAAALgAECgUJCAAAAA==.',
['月舞']='月舞云裳:BAAALgAECgMJAwAAAA==.',
['朝牧']='朝牧流云:BAAALgAECgEJAQAAAA==.',
['木又']='木又:BAAALgAECgcJCQAAAA==.',
['机智']='机智的二牛桑:BAAALgADCgUJBQAAAA==.',
['杂毛']='杂毛野刁男:BAAALgAECgMJAwAAAA==.',
['李包']='李包包:BAAALgAECgEJAQAAAA==.',
['李小']='李小曼:BAAALgAECgEJAgAAAA==.',
['杠之']='杠之神:BAAALgAECgkJCAAAAA==.',
['来杯']='来杯冰美式:BAAALgAECgYJDwAAAA==.来杯奈雪:BAAALgADCgcJBwAAAA==.',
['来玩']='来玩水:BAAALgAECgMJAwAAAA==.',
['杨教']='杨教授:BAAALgAECgYJBgAAAA==.',
['杨晓']='杨晓帆:BAAALgAECgQJBAAAAA==.',
['東急']='東急亞雪:BAAALgAECgEJAQAAAA==.',
['柳上']='柳上鸣:BAAALgAECgEJAgAAAA==.',
['格尔']='格尔曼的门徒:BAAALgAFFAEJAQAAAA==.',
['桑铎']='桑铎:BAAALgAECgIJBAAAAA==.',
['梦幽']='梦幽丶:BAAALgADCgMJAwAAAA==.',
['梧桐']='梧桐沐雨:BAAALgAECgkJBwAAAA==.',
['椰芷']='椰芷吱:BAAALgAECgkJCAAAAA==.',
['樂逍']='樂逍遥:BAAALgAECgEJAQAAAA==.',
['樱满']='樱满集丶:BAAALgADCgYJBgAAAA==.',
['樱空']='樱空桃:BAAALgAECgQJBAAAAA==.',
['欠扁']='欠扁的小脑斧:BAAALgAECgEJAQAAAA==.',
['欧丨']='欧丨皇:BAAALgAFFAIJAwAAAA==.',
['欧皇']='欧皇久久:BAAALgAFFAIJAgAAAA==.欧皇喵:BAABLgAFFH8GAAIEAAIJ9iYUFgDoAAAEAAIJ9iYUFgDoAAAAAA==.',
['此人']='此人异常神经:BAAALgAECgMJAwAAAA==.',
['步狐']='步狐:BAAALgAECgIJAgAAAA==.',
['武装']='武装直升机:BAAALgAECgkJDAABLgAFFAQJBAABAAAAAA==.',
['歪嘴']='歪嘴龙王叶辰:BAABLgAFFH8GAAMVAAMJGAxcFADTAAAVAAMJGAxcFADTAAAUAAEJZgECDABEAAAAAA==.',
['残偑']='残偑:BAABLgAECn8YAAQCAAgJcw0yawBhAQACAAgJ7AwyawBhAQAOAAUJqgRCSgDIAAADAAMJpQg2IACDAAAAAA==.',
['毁灭']='毁灭的灵魂:BAAALgAECgMJBAAAAA==.',
['毛神']='毛神红体育生:BAAALgAECgEJAgAAAA==.',
['毛胖']='毛胖球:BAAALgAFFAQJBAABLgAFFAUJKgANAP8kAA==.',
['气象']='气象员:BAAALgAECgYJCAAAAA==.',
['汀上']='汀上白丶墨九:BAAALgAECgUJBQAAAA==.',
['求你']='求你们别死:BAAALgADCgEJAQAAAA==.',
['汤姆']='汤姆布利柏:BAAALgAECgYJBwAAAA==.',
['汪小']='汪小林:BAAALgADCgcJBwAAAA==.',
['沐小']='沐小胖:BAAALgAFFAIJBAABLgAFFAUJCQAJAMwQAA==.',
['沙场']='沙场不倒翁:BAAALgADCgYJBgAAAA==.',
['沙库']='沙库鲁玛加拉:BAAALgAECgcJBwAAAA==.',
['没有']='没有双马尾啊:BAAALgAECgEJAQAAAA==.',
['法克']='法克丶小德:BAAALgAECgQJBAAAAA==.',
['法神']='法神飞爷:BAAALgADCgUJBwAAAA==.',
['泼鲤']='泼鲤啊摸:BAAALgAECgYJDAAAAA==.',
['洋火']='洋火儿:BAAALgAECgYJAgAAAA==.',
['洛克']='洛克昂:BAAALgAECgEJAQAAAA==.',
['洛坎']='洛坎:BAAALgAECgYJBgAAAA==.',
['洛瑟']='洛瑟玛:BAAALgAECggJCAAAAA==.',
['浅仓']='浅仓南丶:BAAALgAECgEJAQAAAA==.',
['浅笑']='浅笑醉长安:BAAALgAECgkJCQAAAA==.',
['浚哥']='浚哥:BAAALgAECgUJBQAAAA==.',
['浦江']='浦江樊长玉:BAAALgAECgMJAwAAAA==.',
['浮笙']='浮笙若梦:BAAALgADCgMJAwAAAA==.',
['涛子']='涛子的游侠:BAABLgAFFH8IAAMKAAQJPBaiFQDuAAAKAAMJohSiFQDuAAAJAAEJCxvkHwBhAAAAAA==.',
['淯燕']='淯燕:BAAALgAFFAEJAgAAAA==.',
['清汤']='清汤面:BAAALgAECgkJCQAAAA==.',
['清清']='清清小可爱:BAABLgAFFH8IAAITAAQJRCB7AQCZAQATAAQJRCB7AQCZAQAAAA==.',
['湖边']='湖边小憩:BAAALgADCgUJBQAAAA==.',
['溜只']='溜只傻狍子:BAAALgADCgEJAQAAAA==.',
['火柴']='火柴棍:BAACLgAFFH8RAAMJAAUJSRuyAQB9AQAKAAUJ8xIiCACYAQAJAAQJ1B+yAQB9AQAuAAQKfyIAAwoACQkhInENANgCAAoACAmEInENANgCAAkAAwlJGBE6AJsAAAAA.',
['火烨']='火烨:BAAALgAFFAIJAwAAAA==.',
['火狼']='火狼:BAAALgADCgEJAQAAAA==.',
['火鸡']='火鸡面:BAAALgAECgEJAQAAAA==.',
['灬死']='灬死骑灬:BAAALgAECgYJDAAAAA==.',
['灬綄']='灬綄鎂品德灬:BAAALgAECgIJAgAAAA==.',
['灬耀']='灬耀丶:BAAALgAECgYJEAAAAA==.',
['灬风']='灬风中战神灬:BAAALgAECgEJAgAAAA==.',
['灼热']='灼热的炎爆:BAAALgAECgcJBgAAAA==.',
['灾贼']='灾贼丶:BAAALgAECgcJCQAAAA==.',
['炉火']='炉火纯基:BAABLgAFFH8KAAIWAAQJ4SQgDQCzAQAWAAQJ4SQgDQCzAQAAAA==.',
['烬灭']='烬灭刃:BAAALgAECgEJAgAAAA==.',
['热热']='热热就脱吧:BAAALgAECgcJEwAAAA==.',
['無惜']='無惜:BAACLgAFFH8KAAQJAAQJxRNnCgAOAQAJAAMJOxdnCgAOAQAdAAMJTgZyBADrAAAKAAEJZQllKQBJAAAuAAQKfyAABAkACAnxHZEjADACAAkABwnkHpEjADACAAoABwnEFiklAPwBAB0ABAmRGJgIAE8BAAAA.',
['燃烧']='燃烧栖姬:BAAALgADCgYJBgAAAA==.',
['爫丿']='爫丿爫:BAAALgAECggJCAAAAA==.',
['爱上']='爱上你的含蓄:BAAALgADCgQJBAAAAA==.',
['爱吃']='爱吃砂糖橘:BAACLgAFFH8QAAILAAQJYhqOBwBhAQALAAQJYhqOBwBhAQAuAAQKfxsAAwsACAlVIuQYAE0CAAsABwkvIuQYAE0CABcAAQnaDuuXAEAAAAAA.',
['爱心']='爱心大叔:BAAALgADCgEJAQAAAA==.',
['爱污']='爱污及污:BAAALgADCgIJAgAAAA==.',
['片甲']='片甲不留:BAAALgAECgQJBgAAAA==.',
['牛乸']='牛乸石扣:BAAALgADCgUJBQAAAA==.',
['牛干']='牛干妈:BAAALgAECgEJAQAAAA==.',
['牧秋']='牧秋的风:BAAALgAECgkJCgAAAA==.',
['牧野']='牧野朝歌:BAAALgAECgEJAQAAAA==.',
['物语']='物语论:BAAALgAECgYJBgAAAA==.',
['犇德']='犇德牛:BAAALgADCgMJAwAAAA==.',
['狂刀']='狂刀三浪:BAAALgAECgkJDQAAAA==.',
['狂暴']='狂暴魔临:BAAALgAECgcJBwAAAA==.',
['狐狸']='狐狸快跑:BAAALgAECgkJBAAAAA==.',
['狐队']='狐队长:BAABLgAFFH8NAAMSAAUJLxyRBQCZAQASAAUJNQqRBQCZAQAbAAQJLxynAwBSAQAAAA==.',
['猎小']='猎小手:BAAALgAFFAQJBAAAAA==.',
['猫了']='猫了个咪哇:BAAALgADCgMJAwAAAA==.',
['玖月']='玖月绯蓝:BAAALgADCgcJCAAAAA==.',
['玖歌']='玖歌:BAAALgAECgkJCgAAAA==.',
['玖紫']='玖紫:BAAALgAECgQJBAAAAA==.',
['琉璃']='琉璃胖鸡:BAAALgAECgQJBAAAAA==.',
['琳美']='琳美香:BAAALgAECgYJBgAAAA==.',
['璃伤']='璃伤:BAAALgAECgkJEAAAAA==.',
['瓦坎']='瓦坎达:BAAALgAECgEJAQAAAA==.',
['甘雨']='甘雨:BAAALgAECgQJBAAAAA==.',
['电电']='电电傻馒:BAAALgAECgQJBAAAAA==.',
['疯滴']='疯滴凯:BAAALgAECgMJAwAAAA==.',
['白疾']='白疾风:BAAALgAECggJBwAAAA==.',
['白雾']='白雾红尘:BAACLgAFFH8QAAICAAQJ+h6EBQBeAQACAAQJ+h6EBQBeAQAuAAQKfyEAAgIACAkXIk4HACUCAAIACAkXIk4HACUCAAAA.',
['白马']='白马长风:BAABLgAFFH8JAAIMAAQJvhr0AwBnAQAMAAQJvhr0AwBnAQAAAA==.',
['百里']='百里木木:BAAALgAECgMJAwAAAA==.',
['盲公']='盲公炳:BAAALgAECgEJAQAAAA==.',
['真理']='真理:BAAALgAECgYJDwAAAA==.',
['眼神']='眼神牛碧:BAAALgAECgEJAQAAAA==.',
['督军']='督军黑手:BAAALgAECgkJCQAAAA==.',
['矮挫']='矮挫富的幸福:BAABLgAFFH8LAAIGAAQJTQ9jBwAcAQAGAAQJTQ9jBwAcAQAAAA==.',
['矮肥']='矮肥圆:BAAALgAECgIJBQAAAA==.',
['破壁']='破壁人:BAAALgAECgcJAgAAAA==.',
['破碎']='破碎王者:BAAALgADCgIJAgAAAA==.',
['神灬']='神灬德德:BAAALgAECgYJEQAAAA==.神灬月:BAAALgADCgQJBAAAAA==.神灬米迦勒:BAAALgADCgEJAQAAAA==.神灬路西法:BAAALgADCgEJAQAAAA==.',
['秋风']='秋风九月时:BAAALgADCgEJAQAAAA==.',
['穆跃']='穆跃:BAAALgAECgYJDQAAAA==.',
['突然']='突然的陀螺:BAAALgAFFAQJBAAAAA==.',
['笑尹']='笑尹:BAAALgAECgUJCAAAAA==.',
['米拉']='米拉巴尔坎:BAAALgAECgcJDwAAAA==.米拉希尔:BAAALgADCgIJAgAAAA==.',
['米莉']='米莉弥娜:BAAALgAECgQJBgAAAA==.',
['糕糕']='糕糕:BAAALgAECgUJBgAAAA==.',
['糖果']='糖果里的记忆:BAAALgAECgYJEQAAAA==.',
['綄鎂']='綄鎂灬倵森:BAAALgAECgIJAgAAAA==.綄鎂結鋦:BAAALgADCgIJAgAAAA==.',
['纯情']='纯情狼妹:BAAALgAFFAUJAQAAAA==.',
['纯种']='纯种泰迪:BAAALgAECgMJBAAAAA==.',
['纳兹']='纳兹戈隆:BAAALgAECgcJBwAAAA==.',
['纽丨']='纽丨扣:BAAALgAECgQJBAAAAA==.',
['细品']='细品诗香丶:BAAALgADCgYJBgAAAA==.',
['终焉']='终焉王律:BAAALgADCgYJBgAAAA==.',
['经典']='经典红双喜:BAAALgAECgEJAQAAAA==.',
['绫波']='绫波丽:BAAALgAFFAQJBAAAAA==.',
['绿豆']='绿豆糕:BAAALgAECgQJBAAAAA==.',
['网恋']='网恋丶教父:BAAALgAECgkJDwABLgAFFAUJCQAZANghAA==.',
['羽之']='羽之邪能猎手:BAAALgAECgYJCwAAAA==.',
['肉包']='肉包喵:BAAALgADCgMJAwAAAA==.',
['肉汁']='肉汁团:BAAALgAECgQJBgAAAA==.',
['肥宅']='肥宅龙宝:BAAALgADCgEJAQABLgAFFAEJAQABAAAAAA==.',
['肥肥']='肥肥曼:BAAALgAECgEJAwAAAA==.',
['腐烂']='腐烂的苹果:BAAALgAECgYJBgAAAA==.',
['自由']='自由丶職業:BAAALgAFFAIJAgAAAA==.',
['與兜']='與兜兜的故事:BAAALgAECgkJCQAAAA==.',
['與芋']='與芋头的故事:BAAALgAECgkJDQAAAA==.',
['與鬬']='與鬬鬬的故事:BAAALgAECgkJBwABLgAFFAUJBwAJAEEeAA==.',
['艾伦']='艾伦丶月溪:BAAALgAECgUJBQAAAA==.',
['艾莉']='艾莉莎:BAAALgAECgUJCwAAAA==.',
['芙宁']='芙宁娜:BAAALgAFFAEJAQAAAA==.',
['芭比']='芭比珍:BAAALgAECgcJBwAAAA==.',
['花开']='花开丶夜叉:BAACLgAFFH8NAAMKAAYJkBHjBQDGAQAKAAYJQwjjBQDGAQAJAAMJ+BfRCAATAQAuAAQKfyAAAwoACQnlIJQOAMsCAAoACAmXIJQOAMsCAAkAAQkEI6StAGkAAAAA.花开丶梵天:BAAALgAECgcJEwAAAA==.花开丶迦楼罗:BAAALgAECgkJDwAAAA==.',
['花生']='花生米米:BAAALgAECgUJCQAAAA==.',
['芳芳']='芳芳纯爷们:BAAALgAECgQJBQAAAA==.',
['芸宝']='芸宝宝:BAAALgAECgQJBQAAAA==.',
['苟诗']='苟诗韵:BAABLgAFFH8JAAIPAAUJegJPFgDoAAAPAAUJegJPFgDoAAAAAA==.',
['草莓']='草莓慕斯蛋糕:BAAALgAECgYJBQAAAA==.',
['荒野']='荒野獵人:BAAALgAECgEJAQAAAA==.',
['荒钩']='荒钩爪:BAAALgAECgcJDQAAAA==.',
['菇凉']='菇凉光芒万丈:BAAALgAECgYJBgAAAA==.',
['萨勒']='萨勒芬妮:BAAALgADCgYJBgAAAA==.',
['萨鲁']='萨鲁法尔王子:BAAALgAECgYJBwAAAA==.',
['落叶']='落叶秋风丶:BAAALgAECgcJDAAAAA==.',
['落子']='落子丶无悔:BAAALgADCgYJBgAAAA==.',
['落帆']='落帆:BAACLgAFFH8IAAIPAAMJlhj7HgAIAQAPAAMJlhj7HgAIAQAuAAQKfyIAAw8ACAltHyMqAGcCAA8ABwm7HCMqAGcCABkAAgnoIys3ANkAAAAA.',
['落霞']='落霞与孤雁:BAAALgAFFAIJBAAAAA==.',
['蒂法']='蒂法洛克哈特:BAAALgAECgQJBAAAAA==.',
['蓝色']='蓝色灬妖灵:BAAALgAECgcJCQAAAA==.',
['蓝莓']='蓝莓姐丶猫人:BAAALgAECgMJAwAAAA==.',
['蕃茄']='蕃茄蛋汤:BAAALgAECgYJDwAAAA==.',
['蕾丝']='蕾丝丈母娘:BAAALgAECgcJBwAAAA==.蕾丝大帝:BAAALgAECgIJAgAAAA==.蕾丝大汗:BAACLgAFFH8GAAIEAAMJVBPHKAD2AAAEAAMJVBPHKAD2AAAuAAQKfx8AAgQACAlyIskIAA0CAAQACAlyIskIAA0CAAAA.蕾丝虚空:BAAALgAECgYJBwAAAA==.',
['薛蒂']='薛蒂凯丶:BAAALgAECgYJCgAAAA==.',
['薯条']='薯条贩卖商:BAAALgAECgYJCQAAAA==.',
['蛮牛']='蛮牛小黑:BAAALgAECgIJAgAAAA==.',
['蟹香']='蟹香糯米锅巴:BAAALgAECgUJBgAAAA==.',
['血色']='血色丶弥漫:BAAALgAECgEJAQAAAA==.血色年华:BAAALgADCgEJAQAAAA==.血色狂欢:BAAALgADCgEJAQAAAA==.',
['街角']='街角丶吐烟圈:BAAALgAECgcJBwAAAA==.',
['见手']='见手青:BAAALgAECgYJEwAAAA==.',
['诅咒']='诅咒风:BAABLgAFFH8HAAMSAAMJjwy9CADwAAASAAMJYAu9CADwAAAbAAEJRhhhDwBKAAAAAA==.',
['诡异']='诡异呢灵魂:BAAALgAECgQJBAAAAA==.',
['诺斯']='诺斯特温佩奇:BAAALgAECgIJAgAAAA==.',
['谜一']='谜一样的乳龙:BAACLgAFFH8HAAMUAAMJ/gt3BwCNAAAVAAMJ/gvsDwCiAAAUAAIJvQJ3BwCNAAAuAAQKfxcAAxQACAnEHS8GAJQCABQACAnEHS8GAJQCABUAAQkVFLteAEAAAAAA.',
['豬囧']='豬囧太蕾:BAAALgAECgEJAgAAAA==.',
['费小']='费小包:BAAALgAECgcJBQAAAA==.',
['赦晶']='赦晶舞历:BAAALgAECgcJBwAAAA==.',
['赵子']='赵子龙:BAAALgAECgYJAQAAAA==.',
['超开']='超开心:BAAALgADCgQJBAABLgAFFAYJFwAQANMRAA==.',
['超必']='超必杀成龙:BAAALgAECgYJCgAAAA==.',
['超赞']='超赞:BAAALgAECgYJBgAAAA==.',
['路过']='路过帝:BAAALgAECgQJBQAAAA==.',
['輕描']='輕描淡写:BAAALgAFFAEJAQAAAA==.',
['辣条']='辣条先生丶:BAABLgAFFH8IAAICAAQJWRN+CAA+AQACAAQJWRN+CAA+AQAAAA==.',
['迁里']='迁里走单骑:BAAALgAECgEJAQAAAA==.',
['迈达']='迈达斯驼:BAAALgAECgYJDAAAAA==.',
['这合']='这合理吗:BAAALgADCgcJBwABLgAECgQJBQABAAAAAA==.',
['进击']='进击的奶牛:BAAALgAECgEJAQAAAA==.',
['远吕']='远吕智:BAAALgAFFAEJAQAAAA==.',
['迷失']='迷失的高跟鞋:BAAALgAECgIJBAAAAA==.',
['迷糊']='迷糊的小白:BAAALgAECgEJBAAAAA==.',
['迷雾']='迷雾里缱绻:BAAALgADCgUJBQAAAA==.',
['追一']='追一猎一者:BAAALgAECgQJCAAAAA==.',
['通缉']='通缉晓清昕:BAAALgAECgEJAgAAAA==.',
['逝去']='逝去:BAAALgADCgIJAgAAAA==.',
['逝湮']='逝湮:BAAALgAECgkJCgAAAA==.',
['速度']='速度灭丶:BAAALgAECgIJAQAAAA==.',
['進擊']='進擊德巨鳥:BAAALgAECgYJCQAAAA==.',
['那时']='那时还相信光:BAAALgAECgQJBQAAAA==.',
['郑晓']='郑晓琦:BAAALgAFFAIJAgAAAA==.',
['都没']='都没有人:BAAALgADCgMJAwAAAA==.',
['酒后']='酒后的风骚:BAAALgAECgEJAQAAAA==.',
['酥麻']='酥麻干脆面:BAAALgADCgEJAQAAAA==.',
['里木']='里木白:BAAALgAECgQJBwAAAA==.',
['重案']='重案组曹達华:BAAALgAECgQJBwAAAA==.',
['鋈媵']='鋈媵鋈螽:BAAALgAECgYJCgAAAA==.',
['鎍尓']='鎍尓:BAAALgAECgYJCAAAAA==.',
['鏖魔']='鏖魔:BAAALgAECgcJCAAAAA==.',
['铮铮']='铮铮葬情:BAAALgAECgUJCQAAAA==.',
['长安']='长安明月:BAAALgAECgYJDAAAAA==.',
['长戈']='长戈寸骨:BAAALgADCgYJCAAAAA==.',
['门糖']='门糖:BAAALgAECgUJBQAAAA==.',
['闪电']='闪电旋风踢:BAAALgAECgkJBAABLgAFFAQJBAABAAAAAA==.',
['间桐']='间桐樱:BAAALgAECgEJAQAAAA==.',
['阿丹']='阿丹哥:BAAALgAECgIJAgAAAA==.',
['阿六']='阿六頭:BAAALgAECgEJAQAAAA==.',
['阿瑞']='阿瑞安赫徳:BAAALgAECgEJAQAAAA==.',
['阿雏']='阿雏白银之誓:BAAALgAECgYJEwAAAA==.',
['陈丶']='陈丶雷婷烈酒:BAAALgADCgIJAgAAAA==.',
['陈大']='陈大帥:BAAALgAFFAEJAQAAAA==.',
['陪你']='陪你呼风唤雨:BAAALgAECgEJAQAAAA==.',
['陸郎']='陸郎丨煋:BAAALgAECgQJCAAAAA==.',
['雪白']='雪白太子奶:BAAALgAECgEJAQAAAA==.',
['雷欧']='雷欧娜:BAAALgAECgkJEwAAAA==.',
['震鳞']='震鳞星:BAAALgAECgYJBgAAAA==.',
['霸天']='霸天萨:BAAALgAFFAIJAgAAAA==.',
['青涩']='青涩后妈:BAAALgAECgEJAQAAAA==.',
['青电']='青电主:BAAALgAECgcJBgAAAA==.',
['青色']='青色主祭:BAAALgADCgEJAQAAAA==.',
['青见']='青见女未:BAAALgAECgQJBgAAAA==.',
['靓仔']='靓仔锋:BAAALgAECgYJCAAAAA==.',
['非酋']='非酋的诅咒:BAAALgAECgEJAwAAAA==.',
['面团']='面团小红爪:BAAALgAECgEJAQAAAA==.',
['面色']='面色极其苍白:BAAALgAECgEJAQAAAA==.',
['顶级']='顶级肥牛:BAAALgAECgEJAwAAAA==.',
['顺德']='顺德周杰伦:BAAALgAECgEJAgAAAA==.',
['风乎']='风乎灬舞雩:BAAALgAECgQJCQABLgAFFAEJAQABAAAAAA==.',
['风凌']='风凌雪:BAAALgADCgMJAwAAAA==.',
['风尘']='风尘烟雨:BAAALgAECgMJBQAAAA==.',
['风骚']='风骚圣光者:BAAALgAECgQJBAAAAA==.风骚毁灭者:BAAALgAECgEJAQAAAA==.',
['飯團']='飯團尛奶牛:BAAALgAECgYJBgAAAA==.',
['饮砒']='饮砒霜:BAAALgAFFAIJAgAAAA==.',
['香辣']='香辣味毛豆:BAABLgAFFH8GAAIEAAMJEhp5IwAIAQAEAAMJEhp5IwAIAQAAAA==.',
['骑貌']='骑貌不扬:BAAALgAECgYJBwAAAA==.',
['高压']='高压炉锅:BAAALgAECgkJCgAAAA==.',
['魅的']='魅的舞:BAAALgADCgEJAQAAAA==.',
['鲨鲨']='鲨鲨小鳄鱼:BAAALgAECgEJAQAAAA==.',
['鹊桥']='鹊桥仙:BAAALgAECgMJAwAAAA==.',
['鹏哥']='鹏哥丶:BAAALgAECgIJAgAAAA==.',
['麒麟']='麒麟泷:BAAALgAECgYJBgAAAA==.',
['麥斯']='麥斯克丶費倫:BAABLgAECn8kAAIHAAgJzRgsFQBoAgAHAAgJzRgsFQBoAgAAAA==.',
['黎明']='黎明剑:BAAALgAECgEJAQAAAA==.',
['黑暗']='黑暗盛经:BAAALgAECgEJAgAAAA==.',
['黑漫']='黑漫巴:BAAALgAECgYJDgAAAA==.',
['黑炎']='黑炎王:BAAALgAECgcJDgAAAA==.',
['黑迪']='黑迪克:BAABLgAECn8WAAMEAAgJthybPwA6AgAEAAgJBhqbPwA6AgAeAAcJURy7FgCqAQAAAA==.',
['黑鯭']='黑鯭鯭:BAAALgAECgEJAQAAAA==.',
['黛利']='黛利拉:BAAALgADCgEJAgAAAA==.',
['龙倵']='龙倵:BAAALgAECgEJAgAAAA==.',
['龙魔']='龙魔枫:BAAALgAECgUJBgAAAA==.',
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
