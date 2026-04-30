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

local lookup = {'Unknown-Unknown','Warrior-Fury','Warrior-Protection','Warlock-Demonology','Monk-Brewmaster','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Holy','Shaman-Elemental','Shaman-Restoration','Mage-Frost','DeathKnight-Unholy','Druid-Restoration','DeathKnight-Blood','Priest-Discipline','Druid-Balance','Priest-Holy','Priest-Shadow','Paladin-Retribution','Monk-Windwalker','Warlock-Destruction','Evoker-Augmentation','Evoker-Devastation','Rogue-Assassination','DemonHunter-Devourer',}
local provider = {region='CN',realm='燃烧军团',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aizawa:BAAALgADCgEJAQAAAA==.',
Am='Amehana:BAAALgAECgIJAgABLgAFFAIJAgABAAAAAA==.Amehanaa:BAAALgAFFAIJAgAAAA==.Amorli:BAAALgAECgUJCwAAAA==.',
An='Angeles:BAAALgAECgcJDQAAAA==.',
Ar='Artoria:BAAALgAECgMJAwAAAA==.',
Az='Azs:BAAALgAECgIJAgAAAA==.',
Bi='Bigpanda:BAAALgADCgQJBAAAAA==.',
Bo='Boringillu:BAAALgAECgQJBAAAAA==.Boringmagic:BAAALgAECgYJBgAAAA==.',
De='Destruction:BAABLgAECn8YAAMCAAkJ/Ba7EADLAgACAAkJ/Ba7EADLAgADAAIJqQxvPwBVAAAAAA==.',
Df='Dfillsixh:BAAALgAECgMJBQAAAA==.',
Dk='Dknight:BAAALgAECgYJCwAAAA==.',
Et='Ethanyip:BAABLgAFFH8HAAIEAAIJ9Bv6FgCvAAAEAAIJ9Bv6FgCvAAAAAA==.',
Fo='Forest:BAACLgAFFH8JAAIFAAMJDwdBCgC1AAAFAAMJDwdBCgC1AAAuAAQKfx8AAgUABwkeEFQ3AG4BAAUABwkeEFQ3AG4BAAAA.',
Ge='Gely:BAAALgAECgYJBwAAAA==.',
He='Heetuii:BAABLgAECn8YAAMGAAcJ9R67FQB/AgAGAAcJ4h67FQB/AgAHAAEJXiCZsQBgAAAAAA==.',
Ji='Jimbones:BAAALgAECgYJCAAAAA==.',
Jm='Jmy:BAAALgAECgYJCgABLgAFFAQJBAABAAAAAA==.',
Li='Lilsmokerqs:BAAALgADCgYJBAAAAA==.',
Lu='Luckyppigg:BAAALgAECgEJAQAAAA==.',
Mo='Momo:BAAALgADCgYJBgAAAA==.',
Ni='Ninalee:BAAALgAECgQJBAAAAA==.',
Ob='Obwuy:BAAALgAECgEJAQAAAA==.',
Or='Origin:BAAALgAFFAIJAgAAAA==.',
Pa='Parsifal:BAAALgAECgEJAQAAAA==.',
Pi='Pinkpig:BAAALgAECgIJAgAAAA==.',
Pl='Playerswiair:BAAALgADCgEJAQAAAA==.',
Qd='Qdxc:BAAALgAECgcJBwAAAA==.',
Ru='Runwack:BAAALgAECgYJDwAAAA==.',
Sd='Sdasdw:BAAALgADCgMJBAAAAA==.',
Se='Seemann:BAAALgAECgUJBQAAAA==.Seley:BAAALgADCgEJAQAAAA==.',
St='Style:BAAALgAECgYJDAAAAA==.',
Ze='Zerokt:BAACLgAFFH8IAAIIAAQJhwhIBwDNAAAIAAQJhwhIBwDNAAAuAAQKfycAAggACAkBEsMqAN0BAAgACAkBEsMqAN0BAAAA.',
Zq='Zqs:BAAALgAECgIJAgAAAA==.',
['一旋']='一旋律一:BAAALgADCgEJAgAAAA==.',
['一望']='一望无痕:BAAALgAECgcJDAAAAA==.',
['一生']='一生的守护:BAAALgADCgEJAQAAAA==.',
['一胖']='一胖咕咕一:BAAALgADCgEJAQAAAA==.',
['七宝']='七宝柠檬:BAAALgADCgMJAwAAAA==.',
['上古']='上古旱魃:BAAALgAFFAIJAgAAAA==.',
['不够']='不够狂野:BAAALgAECgYJCQABLgAFFAYJFgAJAMUZAA==.不够自然:BAAALgADCggJCAAAAA==.',
['不要']='不要迷戀哥:BAAALgAECgYJBwAAAA==.',
['两横']='两横一竖:BAAALgAFFAIJAwAAAA==.',
['丨轩']='丨轩辕神君丨:BAAALgAECgcJBwAAAA==.',
['临时']='临时演员:BAAALgAECgMJAwAAAA==.',
['丶嘴']='丶嘴角的温度:BAACLgAFFH8PAAIKAAQJUBgHCABHAQAKAAQJUBgHCABHAQAuAAQKfxYAAgoACAnCIYIJAN8CAAoACAnCIYIJAN8CAAAA.',
['丶夜']='丶夜丨哭泣:BAAALgAECgEJAQAAAA==.',
['丷随']='丷随风丷:BAACLgAFFH8SAAILAAUJEBzkCgDHAQALAAUJEBzkCgDHAQAuAAQKfxgAAgsACQlkHUIfAPgCAAsACQlkHUIfAPgCAAAA.',
['为了']='为了自由:BAABLgAFFH8OAAIMAAQJISEUCQCIAQAMAAQJISEUCQCIAQAAAA==.',
['丿繁']='丿繁花似锦灬:BAAALgAECgYJBgAAAA==.',
['乀虎']='乀虎悍将:BAAALgAECgYJBgAAAA==.',
['乂灵']='乂灵翼乂:BAAALgAECgYJDAAAAA==.',
['九月']='九月天称:BAABLgAFFH8FAAINAAQJVAXsDQAIAQANAAQJVAXsDQAIAQAAAA==.',
['二两']='二两玖錢:BAAALgAECgEJAgAAAA==.',
['今夜']='今夜未到乡:BAAALgAECgIJAgAAAA==.',
['伊利']='伊利呦酸乳:BAAALgAECgIJAgAAAA==.',
['你並']='你並非永恆:BAAALgADCgcJBwAAAA==.',
['你和']='你和我的故事:BAAALgAECgMJAgAAAA==.',
['假行']='假行僧:BAAALgADCgUJBQAAAA==.',
['儿蛋']='儿蛋儿:BAABLgAFFH8KAAIEAAYJzxFEAQCyAQAEAAYJzxFEAQCyAQAAAA==.',
['全麻']='全麻:BAAALgAFFAEJAQAAAA==.',
['八月']='八月仙女:BAABLgAFFH8IAAINAAQJcgm0DAAaAQANAAQJcgm0DAAaAQAAAA==.',
['六道']='六道狂魔:BAAALgAFFAIJAgAAAA==.',
['军团']='军团爸爸:BAAALgAECgMJCAAAAA==.',
['冢中']='冢中丶枯骨:BAAALgAFFAEJAQAAAA==.冢中枯骨:BAAALgAECgQJBAAAAA==.',
['冥界']='冥界猎者:BAAALgADCgEJAQAAAA==.',
['冰冰']='冰冰小霸天:BAAALgADCgEJAQAAAA==.',
['凌波']='凌波微步:BAAALgAECgYJCwAAAA==.',
['凡臣']='凡臣:BAAALgAECgIJAgAAAA==.',
['刀刀']='刀刀糖有毒:BAAALgAECgQJBwAAAA==.',
['别喊']='别喊我也怕:BAAALgAECgEJAQAAAA==.',
['别抢']='别抢我鞋带:BAABLgAFFH8FAAMMAAUJFg0MGQBBAQAMAAQJFg0MGQBBAQAOAAEJAACVFABNAAAAAA==.',
['刺头']='刺头德鲁伊:BAAALgADCgYJBgAAAA==.',
['剑气']='剑气如霜:BAABLgAFFH8IAAMDAAQJcgdVBQCXAAACAAIJhQpNGwCbAAADAAQJPgNVBQCXAAAAAA==.',
['剑荡']='剑荡白玉京:BAAALgADCgUJBQAAAA==.',
['剣刃']='剣刃風暴:BAAALgAECgMJAwABLgAECgUJBgABAAAAAA==.',
['北京']='北京啤酒:BAAALgAFFAMJAwAAAA==.',
['十一']='十一月射手:BAABLgAFFH8IAAINAAQJbwnRDAAYAQANAAQJbwnRDAAYAQAAAA==.',
['十三']='十三:BAAALgAECgUJBQABLgAECgYJBwABAAAAAA==.十三大叔:BAAALgAECgYJBwAAAA==.',
['午夜']='午夜飞行:BAAALgAECgEJAQABLgAFFAUJEgAPANQXAA==.',
['卡丽']='卡丽希:BAAALgADCgUJBQAAAA==.',
['卮言']='卮言春天:BAAALgAECgcJDQABLgAFFAUJBgADAOEYAA==.',
['厉害']='厉害牛排:BAAALgADCgYJBQAAAA==.',
['又是']='又是清明雨上:BAAALgAECgIJAgAAAA==.',
['发抖']='发抖的小喵喵:BAAALgAECgEJAQAAAA==.',
['变形']='变形的小蝎子:BAAALgAECgcJCwABLgAFFAUJCwAQAAgHAA==.',
['叙拉']='叙拉克斯:BAAALgAECgkJCQAAAA==.',
['可乐']='可乐:BAAALgAECgUJBQAAAA==.',
['吃饱']='吃饱了打厨子:BAABLgAECn8UAAIMAAkJ5RScQQAzAgAMAAkJ5RScQQAzAgAAAA==.',
['名起']='名起丧钟:BAAALgAECgYJBgABLgAFFAUJBgADAOEYAA==.',
['吸血']='吸血小蚊子:BAAALgAFFAQJBAAAAA==.',
['呆头']='呆头呆脑:BAAALgAECgQJBAAAAA==.',
['咕咕']='咕咕乱叫:BAAALgAECgQJCAAAAA==.',
['咚巴']='咚巴拉:BAAALgAECgcJDgAAAA==.',
['唱着']='唱着小调儿:BAAALgADCgYJBgAAAA==.',
['喵小']='喵小乐:BAABLgAECn8ZAAMHAAgJ4x5cHgBQAgAHAAgJ4x5cHgBQAgAGAAUJYwn6VwDnAAAAAA==.',
['囚不']='囚不贪:BAAALgAECgQJBAAAAA==.',
['在下']='在下毛毛雨:BAAALgAECgIJAgAAAA==.',
['坂本']='坂本真绫:BAAALgAECggJCAAAAA==.',
['坐飞']='坐飞机吃贡品:BAABLgAECn8UAAMCAAYJLQLFfADJAAACAAYJHwLFfADJAAADAAUJCgECOACJAAAAAA==.',
['堕入']='堕入深海:BAACLgAFFH8SAAIPAAUJ1BfMAQC3AQAPAAUJ1BfMAQC3AQAuAAQKfyUABBEACQnFHX4MAIsCABEABwknIX4MAIsCAA8ACQnAEkQPAEkCABIAAQlPGKNaAEwAAAAA.',
['墮入']='墮入深海:BAAALgAECgIJAwABLgAFFAUJEgAPANQXAA==.',
['多巴']='多巴酚丁胺丨:BAAALgADCgEJAQAAAA==.',
['夜穹']='夜穹殉至:BAAALgAFFAIJAgAAAA==.',
['天堂']='天堂灬在左:BAABLgAECn8fAAMTAAgJmiFBDgAcAwATAAgJmiFBDgAcAwAIAAYJoAxAVAApAQAAAA==.',
['天苍']='天苍谋:BAACLgAFFH8QAAIQAAUJ4hoPAwDGAQAQAAUJ4hoPAwDGAQAuAAQKfyUAAxAACQl8IH8CAJYDABAACQl8IH8CAJYDAA0ABgmEBoyAANkAAAAA.',
['太平']='太平长安:BAAALgAECgQJBAAAAA==.',
['头牛']='头牛骑士:BAAALgADCgIJAgAAAA==.',
['奈法']='奈法莱恩:BAAALgAECgUJBQAAAA==.',
['奔放']='奔放丶:BAAALgADCgEJAQAAAA==.',
['奶中']='奶中第一毛:BAAALgAECgcJCgAAAA==.',
['妖小']='妖小怪丶羽月:BAAALgADCgcJBwAAAA==.',
['妲己']='妲己:BAAALgAECgEJAQABLgAFFAQJDAALAJQbAA==.妲己丶:BAACLgAFFH8MAAILAAQJlBs9FQB1AQALAAQJlBs9FQB1AQAuAAQKfx0AAgsACQmQI5QUAC0DAAsACQmQI5QUAC0DAAAA.',
['嫼骉']='嫼骉迋孓:BAAALgAECgQJBQAAAA==.',
['子彧']='子彧鸿晅:BAAALgAECgEJAQAAAA==.',
['孤灬']='孤灬狼:BAAALgAECgEJAQAAAA==.',
['完美']='完美小撒子:BAAALgAECgYJBgAAAA==.',
['实体']='实体娃娃丶凌:BAAALgADCgYJCQAAAA==.',
['宿敌']='宿敌:BAAALgAECgMJAwAAAA==.',
['对卟']='对卟起:BAACLgAFFH8PAAITAAQJghgICgBcAQATAAQJghgICgBcAQAuAAQKfx0AAhMABwk+I90fAK0CABMABwk+I90fAK0CAAAA.',
['小三']='小三丶德:BAAALgAECgMJBQAAAA==.',
['小丷']='小丷七:BAAALgAECgkJCQAAAA==.',
['小号']='小号也流氓:BAAALgAECgEJAQAAAA==.',
['小土']='小土人逗你玩:BAAALgAECgYJBwAAAA==.',
['小小']='小小黑神:BAAALgADCgEJAQAAAA==.',
['小树']='小树一颗:BAABLgAECn8aAAINAAcJ0R+PGQBsAgANAAcJ0R+PGQBsAgAAAA==.',
['小精']='小精灵:BAAALgAECgQJBAAAAA==.',
['小黑']='小黑看不见:BAABLgAFFH8GAAIUAAQJKQUpBwAFAQAUAAQJKQUpBwAFAQAAAA==.',
['就是']='就是陪人玩:BAAALgAFFAIJAgAAAA==.',
['岩黯']='岩黯:BAAALgADCgEJAQAAAA==.',
['岭锋']='岭锋:BAAALgADCgcJBwAAAA==.',
['崋緔']='崋緔:BAAALgAFFAEJAQAAAA==.',
['巴哈']='巴哈姆特哦:BAAALgAECgUJBQAAAA==.',
['巴尔']='巴尔:BAAALgAECgEJAQAAAA==.',
['布鲁']='布鲁克:BAAALgAECgQJBgAAAA==.',
['帝凯']='帝凯灬:BAAALgAECgEJAQAAAA==.',
['幕后']='幕后煮屎:BAAALgAECgEJAQAAAA==.',
['幻影']='幻影忍者:BAAALgAECgQJBwAAAA==.',
['开无']='开无敌就炉石:BAACLgAFFH8HAAIIAAMJmheMDQABAQAIAAMJmheMDQABAQAuAAQKfxYAAggABwm6GB8jAAcCAAgABwm6GB8jAAcCAAAA.',
['开朗']='开朗呆呆魔:BAACLgAFFH8SAAIOAAUJjhuFAgCoAQAOAAUJjhuFAgCoAQAuAAQKfyYAAw4ACQkbI3ABAHgDAA4ACQlzInABAHgDAAwABwnUH8UmAKACAAAA.',
['张顺']='张顺飞:BAABLgAECn8WAAMOAAkJCBgjCwBjAgAOAAkJ1BcjCwBjAgAMAAcJ9RMcdACeAQAAAA==.',
['强力']='强力虚区:BAAALgAECgkJBgAAAA==.',
['归溟']='归溟幽灵鲨:BAAALgAECgEJAQAAAA==.',
['彩虹']='彩虹猫猫:BAAALgAECgEJAQAAAA==.彩虹猫的迪凯:BAAALgADCgMJAwAAAA==.',
['心碎']='心碎丶梦已醒:BAAALgAECgQJBAAAAA==.',
['忠诚']='忠诚的灵魂:BAAALgADCgMJAwAAAA==.',
['怖可']='怖可說的戰士:BAAALgAECgYJBAAAAA==.怖可説惡魔獵:BAAALgAECgYJBgABLgAECgcJEgABAAAAAA==.怖可説死亡騎:BAAALgAECgcJAQABLgAECgcJEgABAAAAAA==.怖可説的武僧:BAAALgAECgcJEgAAAA==.怖可説聖騎士:BAAALgAECgcJDAABLgAECgcJEgABAAAAAA==.',
['性感']='性感御姐玩物:BAAALgAFFAIJAQAAAA==.',
['恩哥']='恩哥不忙:BAAALgAECgEJAQAAAA==.恩哥特忙:BAAALgAECgYJDAAAAA==.',
['恩菲']='恩菲尔德:BAAALgAECgkJEgAAAA==.',
['恶妖']='恶妖妖:BAAALgAECgkJEgAAAA==.',
['想飛']='想飛别怕摔:BAAALgAECgYJCgAAAA==.',
['慕雨']='慕雨晨曦:BAAALgAECgYJCQAAAA==.',
['戀無']='戀無訫:BAAALgADCgUJBQAAAA==.',
['我剌']='我剌死你:BAAALgAECgMJAwAAAA==.',
['我要']='我要开花:BAAALgAECgEJAQAAAA==.',
['房道']='房道妄:BAAALgAECgYJBgAAAA==.',
['扎老']='扎老大得儿吃:BAAALgAECgEJAQAAAA==.',
['扑了']='扑了蛾子:BAAALgADCgEJAQAAAA==.',
['打鼓']='打鼓小猫汀汀:BAABLgAFFH8NAAIGAAUJyBg7BgC9AQAGAAUJyBg7BgC9AQAAAA==.',
['折耳']='折耳团:BAAALgAECgEJAQAAAA==.',
['抹茶']='抹茶汽水:BAAALgAECgQJBAAAAA==.',
['拳如']='拳如风:BAACLgAFFH8OAAIUAAQJRRzwAgB6AQAUAAQJRRzwAgB6AQAuAAQKfxwAAhQACQkzJS0BALMDABQACQkzJS0BALMDAAAA.',
['指尖']='指尖执念:BAABLgAFFH8GAAIDAAUJ4RiEAQBVAQADAAUJ4RiEAQBVAQAAAA==.',
['摆烂']='摆烂等下版本:BAAALgAECgkJEAAAAA==.',
['救赎']='救赎之魂丶:BAAALgAECgEJAQABLgAFFAQJDAALAJQbAA==.',
['新手']='新手试玩:BAAALgAECgcJBQAAAA==.',
['无为']='无为先生:BAABLgAECn8XAAINAAcJihYfNADYAQANAAcJihYfNADYAQAAAA==.',
['无语']='无语的伤:BAAALgADCgYJCQAAAA==.',
['无闲']='无闲事:BAAALgAECgQJBAAAAA==.',
['无间']='无间稻:BAAALgAFFAEJAgAAAA==.',
['明月']='明月:BAAALgAECgEJAgAAAA==.',
['星海']='星海尘:BAAALgAECgEJAQAAAA==.',
['星辰']='星辰明暗:BAAALgAFFAEJAQAAAA==.',
['是梦']='是梦里吖一:BAAALgAECgkJCgAAAA==.是梦里吖三:BAAALgAECgkJEgAAAA==.是梦里吖二:BAAALgAECgkJCQAAAA==.',
['普崔']='普崔塞德:BAAALgAECgIJAgAAAA==.',
['暮影']='暮影旋律:BAACLgAFFH8OAAMPAAQJQBGpCgA0AQAPAAQJKw6pCgA0AQARAAIJNRdADQCUAAAuAAQKfyEAAw8ACQlMHhMFAAIDAA8ACQkKHhMFAAIDABEABgnqHGslAL4BAAAA.',
['暴风']='暴风过境:BAAALgAECgQJBwAAAA==.',
['暴食']='暴食海獭:BAAALgAECgcJBgAAAA==.',
['曲终']='曲终人又散:BAAALgAFFAEJAQAAAA==.',
['月光']='月光小懒:BAABLgAFFH8KAAIPAAUJDw9rBQCQAQAPAAUJDw9rBQCQAQAAAA==.',
['月夜']='月夜忧光:BAAALgAECgIJAwAAAA==.',
['木木']='木木子子:BAAALgADCgYJAQAAAA==.',
['未来']='未来的对白:BAAALgAECgcJEAAAAA==.',
['术值']='术值怪:BAABLgAFFH8IAAMVAAMJ+heCAQC+AAAVAAIJYh2CAQC+AAAEAAIJ2wqzOACiAAAAAA==.',
['李莉']='李莉:BAAALgAECgYJDAAAAA==.',
['果子']='果子哟吼:BAAALgAFFAIJAwAAAA==.',
['染井']='染井吉野:BAAALgAFFAMJAwAAAA==.',
['柠檬']='柠檬味胖次:BAAALgAECgkJAQAAAA==.',
['桶面']='桶面:BAAALgAECgEJAwAAAA==.',
['檌人']='檌人:BAABLgAFFH8FAAIMAAIJXA4JQgCeAAAMAAIJXA4JQgCeAAAAAA==.',
['檌朲']='檌朲:BAAALgAFFAIJAwAAAA==.',
['步凡']='步凡:BAAALgAECgYJBgAAAA==.',
['武浅']='武浅静:BAAALgAECgMJBQAAAA==.',
['歪嘴']='歪嘴龙王:BAAALgAFFAIJAgAAAA==.',
['比克']='比克大魔王丶:BAAALgAECgIJAgAAAA==.',
['水咔']='水咔咔:BAAALgAECgQJBAAAAA==.',
['永冻']='永冻精华:BAAALgAECgQJBAAAAA==.',
['江万']='江万理:BAAALgAECgIJAgAAAA==.',
['没积']='没积分:BAAALgAFFAQJBAAAAA==.',
['河北']='河北美男子:BAAALgADCgQJBAAAAA==.',
['活活']='活活治死:BAAALgAECgMJBQAAAA==.活活玩死:BAAALgAECgIJAwAAAA==.活活疼死:BAAALgAECgYJBwAAAA==.活活顶死:BAAALgAECgUJBgAAAA==.',
['派派']='派派小星:BAAALgAFFAIJAwAAAA==.',
['浮世']='浮世清欢:BAACLgAFFH8MAAIFAAQJ6RmZBwBYAQAFAAQJ6RmZBwBYAQAuAAQKfxcAAgUACQkoHbMMAMQCAAUACQkoHbMMAMQCAAEuAAUUBQkGAAMA4RgA.',
['深海']='深海之蓝:BAAALgAECgEJAQAAAA==.',
['清冫']='清冫争:BAAALgAECgQJBAAAAA==.',
['灵柒']='灵柒夭夭:BAABLgAECn8UAAILAAYJzxQ2pgCMAQALAAYJzxQ2pgCMAQAAAA==.',
['烟雨']='烟雨十三:BAAALgAECgEJAQAAAA==.',
['燕麦']='燕麦拿铁:BAAALgAECgIJAgAAAA==.',
['爱吃']='爱吃绿叶菜:BAABLgAFFH8IAAIMAAMJbxPqJwD4AAAMAAMJbxPqJwD4AAABLgAFFAUJBAABAAAAAA==.爱吃鱼的人:BAAALgAFFAEJAQAAAA==.',
['爱晴']='爱晴晴:BAAALgAECgYJCAAAAA==.',
['爱王']='爱王子:BAAALgAECgUJCAAAAA==.',
['牛叉']='牛叉超龄儿童:BAAALgAFFAQJBAABLgAFFAYJBgAFAJALAA==.',
['牛德']='牛德了不得:BAAALgAECgEJAQAAAA==.',
['牛玄']='牛玄罡:BAAALgAECgYJEAAAAA==.',
['特拉']='特拉法尔伽罗:BAAALgAECgMJAwAAAA==.',
['狂战']='狂战冲天:BAAALgADCgEJAQAAAA==.',
['猎手']='猎手阿狂:BAAALgAECgQJAQAAAA==.',
['猎日']='猎日人:BAAALgAECgMJAwAAAA==.',
['玛格']='玛格汉兽兽:BAAALgAECgEJAQAAAA==.',
['球神']='球神阿伟罗:BAAALgADCgEJAQAAAA==.',
['电脑']='电脑玩家姜淼:BAAALgAECgEJAQAAAA==.',
['疏星']='疏星几点:BAAALgAECgMJAwAAAA==.',
['白面']='白面包呢:BAAALgAECgYJCQABLgAFFAMJAwABAAAAAA==.',
['看什']='看什么看:BAAALgAFFAIJAgAAAA==.',
['看我']='看我变啦:BAAALgAECgEJAQAAAA==.',
['真灬']='真灬和其正:BAAALgADCgYJBgAAAA==.',
['矮子']='矮子弑冰:BAAALgADCgUJBQAAAA==.',
['神圣']='神圣之翼:BAAALgAECgMJBgAAAA==.',
['离别']='离别了再说:BAAALgAECgEJAQAAAA==.',
['秀儿']='秀儿很秀:BAAALgAFFAMJBAAAAA==.',
['穨廢']='穨廢厷宔:BAAALgAECgMJAwAAAA==.',
['精症']='精症嗯:BAAALgAECgYJCAAAAA==.',
['緋紅']='緋紅色:BAAALgADCgYJDAAAAA==.',
['红星']='红星闪闪:BAABLgAECn8UAAIMAAcJshqWSQAWAgAMAAcJshqWSQAWAgAAAA==.',
['红莲']='红莲落:BAAALgAFFAEJAQAAAA==.',
['红蝶']='红蝶第一砖:BAACLgAFFH8SAAMWAAUJuR0OBQC0AQAWAAUJuR0OBQC0AQAXAAEJgAipCgBPAAAuAAQKfyQAAxYACQlTGhMIAPgCABYACAloHRMIAPgCABcABwmVGboOAO8BAAAA.',
['纵死']='纵死侠骨香:BAAALgAECgkJCQAAAA==.',
['给我']='给我:BAAALgAECgEJAQAAAA==.',
['绝地']='绝地斩杀:BAAALgADCgUJBQAAAA==.',
['翠绿']='翠绿树袋熊:BAAALgAECgMJAwABLgAFFAIJAgABAAAAAA==.',
['老天']='老天最爱的崽:BAAALgAECggJDAAAAA==.',
['老牛']='老牛儿:BAAALgAECgcJCgAAAA==.',
['肉身']='肉身成圣光:BAABLgAFFH8FAAITAAMJAxbsFQD8AAATAAMJAxbsFQD8AAAAAA==.',
['能走']='能走多远:BAAALgAFFAEJAQAAAA==.',
['自君']='自君别后:BAAALgAECgIJAgAAAA==.',
['自由']='自由高兴:BAAALgAECgYJDAAAAA==.',
['至瑰']='至瑰极宏之愿:BAAALgAFFAIJAwAAAA==.',
['苹果']='苹果加大版:BAABLgAECn8WAAMEAAgJ4BoeCgDRAQAEAAgJ4BoeCgDRAQAVAAEJAAA7YwBIAAAAAA==.',
['草鹿']='草鹿八千蓅:BAACLgAFFH8NAAIYAAUJJRptAAD1AQAYAAUJJRptAAD1AQAuAAQKfxwAAhgACQmeI6IAAGkDABgACQmeI6IAAGkDAAAA.',
['莴师']='莴师傅:BAAALgAECgYJBgAAAA==.',
['落天']='落天星尘:BAACLgAFFH8JAAIKAAMJAgs/EQDeAAAKAAMJAgs/EQDeAAAuAAQKfxsAAgoACAmWILoJAN0CAAoACAmWILoJAN0CAAAA.',
['葡萄']='葡萄味胖次:BAAALgAECgcJBwAAAA==.',
['葫芦']='葫芦里的娃:BAAALgADCgEJAQAAAA==.',
['蓝灬']='蓝灬箭舞霓裳:BAAALgADCgEJAQAAAA==.',
['蓝精']='蓝精灵:BAAALgAECgYJCgAAAA==.',
['薛凯']='薛凯琪:BAAALgAECgUJBgAAAA==.',
['蛇舞']='蛇舞的前奏:BAAALgADCgYJBgAAAA==.',
['血疫']='血疫:BAAALgAECgEJAQAAAA==.',
['西瓜']='西瓜蛋糕:BAAALgADCgEJAQAAAA==.',
['詹维']='詹维:BAAALgADCgIJAgAAAA==.',
['诗与']='诗与远方:BAAALgADCgEJAQAAAA==.',
['误食']='误食巨馍:BAAALgAECgIJAgAAAA==.',
['谁与']='谁与争锋丶:BAAALgAECgcJBwAAAA==.',
['贝尔']='贝尔法斯特:BAAALgAECgYJCgAAAA==.贝尔蒙特:BAAALgAECgIJAgAAAA==.',
['贝鲁']='贝鲁蒙多:BAAALgAECgEJAgAAAA==.',
['走路']='走路带风:BAAALgAECgcJBwABLgAFFAUJBgADAOEYAA==.',
['超人']='超人不会飞:BAAALgAECgQJBAAAAA==.',
['超巴']='超巴:BAAALgAECgIJAgAAAA==.',
['超管']='超管我在抽烟:BAAALgAECgcJCAAAAA==.',
['超級']='超級賽亞晨:BAACLgAFFH8SAAIZAAUJqxFTDABxAQAZAAUJqxFTDABxAQAuAAQKfyUAAhkACQlxHFUPAAQDABkACQlxHFUPAAQDAAAA.',
['超级']='超级老叔:BAAALgAECgEJAQAAAA==.',
['轩辕']='轩辕晨曦:BAAALgAECgMJBQABLgAECgUJBgABAAAAAA==.',
['辛德']='辛德瑞菈:BAAALgAECgYJBgAAAA==.',
['邦邦']='邦邦:BAAALgADCgUJBQABLgAFFAMJBwAMAAkVAA==.',
['邪乄']='邪乄冰魔:BAAALgADCgEJAQAAAA==.',
['部落']='部落雅典娜:BAAALgAECgEJAQAAAA==.',
['重庆']='重庆市花:BAAALgAECgcJBwAAAA==.',
['重新']='重新集结部队:BAAALgAECgQJBQAAAA==.',
['野顾']='野顾点点:BAAALgAECgcJCwAAAA==.',
['锅包']='锅包肉大成:BAAALgAECgYJDAAAAA==.',
['镜中']='镜中花:BAAALgAECgYJBgAAAA==.',
['长岛']='长岛冰茶丶:BAAALgAECgYJBwAAAA==.',
['開心']='開心不開心:BAAALgAFFAEJAQAAAA==.',
['门墩']='门墩:BAACLgAFFH8JAAILAAMJ9yG7DwARAQALAAMJ9yG7DwARAQAuAAQKfxoAAgsABwk4JPcqAMcCAAsABwk4JPcqAMcCAAAA.',
['闪电']='闪电恋:BAABLgAECn8cAAMKAAgJoCBTDAC9AgAKAAgJoCBTDAC9AgAJAAUJyB7gKQDGAQAAAA==.闪电老登:BAAALgAECgEJAQAAAA==.',
['陈嘉']='陈嘉男:BAAALgADCgQJBAAAAA==.',
['陨篂']='陨篂:BAABLgAFFH8GAAILAAMJOgbdMADuAAALAAMJOgbdMADuAAAAAA==.',
['陳訫']='陳訫如意:BAAALgAECgQJCQAAAA==.',
['隐身']='隐身閃光彈:BAAALgAECgUJBQAAAA==.',
['雨花']='雨花一号:BAAALgAECgYJBgABLgAFFAIJAgABAAAAAA==.',
['零分']='零分天苍谋:BAAALgADCgcJBwAAAA==.',
['霧切']='霧切:BAAALgAECgcJBwAAAA==.',
['青冥']='青冥之翼:BAAALgADCgIJAgAAAA==.',
['青梅']='青梅味胖次:BAAALgAECgIJAgAAAA==.',
['静蓝']='静蓝:BAAALgAFFAIJAgAAAA==.',
['風火']='風火连城:BAACLgAFFH8KAAICAAMJtQ/PEQD3AAACAAMJtQ/PEQD3AAAuAAQKfxYAAgIABgl3IusmACMCAAIABgl3IusmACMCAAAA.風火靁電:BAAALgAECgkJDAAAAA==.',
['风之']='风之叹息:BAABLgAECn8fAAMXAAgJLBkVAQDgAQAXAAgJLBkVAQDgAQAWAAEJAAAzXgBCAAAAAA==.',
['风霁']='风霁月:BAACLgAFFH8LAAIZAAQJ5waiCwAEAQAZAAQJ5waiCwAEAQAuAAQKfxUAAhkACAlFFJtAAPIBABkACAlFFJtAAPIBAAAA.',
['香煎']='香煎牛仔骨:BAAALgAFFAEJAQAAAA==.',
['香蕉']='香蕉味胖次:BAAALgADCgMJAwAAAA==.',
['马云']='马云:BAABLgAFFH8GAAILAAIJ7BXDPgCvAAALAAIJ7BXDPgCvAAAAAA==.',
['高兴']='高兴霸霸:BAABLgAFFH8FAAITAAIJ9BsMHwCxAAATAAIJ9BsMHwCxAAAAAA==.',
['鬼丿']='鬼丿术:BAAALgADCgUJBQAAAA==.',
['魔法']='魔法喷泉:BAAALgAECgYJCwAAAA==.',
['魔能']='魔能领主昆扎:BAAALgAECgcJDQAAAA==.',
['鸺鹨']='鸺鹨:BAAALgAECgYJCAAAAA==.',
['鹏鹏']='鹏鹏的锅:BAACLgAFFH8HAAIZAAMJpByiFwATAQAZAAMJpByiFwATAQAuAAQKfyIAAhkACAlvILcUANsCABkACAlvILcUANsCAAAA.',
['黑丸']='黑丸子:BAAALgADCgIJAgAAAA==.',
['黑暗']='黑暗默默:BAAALgAECgUJBwAAAA==.',
['黑魔']='黑魔导女孩:BAAALgAECgEJAQAAAA==.',
['黯夜']='黯夜公爵:BAAALgAECgQJBAAAAA==.',
['黯月']='黯月疏影:BAAALgAECgYJCwAAAA==.',
['鼻涕']='鼻涕泡子:BAAALgAECgMJAwAAAA==.',
['龙浩']='龙浩陈:BAAALgAECgcJCAAAAA==.',
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
