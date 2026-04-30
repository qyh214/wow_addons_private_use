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

local lookup = {'Evoker-Preservation','Evoker-Augmentation','DeathKnight-Unholy','Warlock-Demonology','DemonHunter-Devourer','Mage-Frost','Unknown-Unknown','Shaman-Restoration','Priest-Holy','Priest-Shadow','Priest-Discipline','DemonHunter-Havoc','Monk-Brewmaster','Monk-Windwalker','Warlock-Destruction','DemonHunter-Vengeance','Hunter-BeastMastery','Warrior-Protection','Druid-Balance','Druid-Restoration','Shaman-Elemental','Paladin-Protection','Paladin-Holy','Paladin-Retribution','Monk-Mistweaver','Hunter-Marksmanship','Warrior-Fury','Warrior-Arms','Warlock-Affliction',}
local provider = {region='CN',realm='冬泉谷',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akili:BAAALgADCgMJAwAAAA==.',
Al='Alexios:BAAALgAECgQJBwAAAA==.Allballs:BAAALgAECgIJAgAAAA==.',
Br='Britneyspear:BAAALgAECgcJBwAAAA==.',
Ca='Cat:BAACLgAFFH8MAAIBAAQJSyQ3BgCPAQABAAQJSyQ3BgCPAQAuAAQKfycAAwEACAmEJYoBAG4DAAEACAmEJYoBAG4DAAIABgn6CQg2ACEBAAAA.',
Da='Darkzero:BAAALgAECgEJAQAAAA==.Datou:BAAALgAECgEJAgAAAA==.',
De='Dellasolx:BAAALgAECgcJBwAAAA==.',
Ea='Eagonmap:BAAALgAECgUJBwAAAA==.',
Eb='Ebod:BAAALgAECgkJCwAAAA==.Ebody:BAAALgAECggJEgAAAA==.',
Ed='Edwindle:BAAALgAFFAMJAwAAAA==.',
Ha='Harmonyo:BAAALgAFFAQJAwAAAA==.',
In='Insanebear:BAAALgAECgQJBAAAAA==.',
Jo='Johnnydeppxd:BAAALgADCgUJBQAAAA==.',
Ke='Kennys:BAAALgAFFAEJAQAAAA==.',
Ko='Koala:BAAALgAECgEJAQAAAA==.',
Le='Levin:BAAALgAECgkJAQAAAA==.',
Lu='Luckycows:BAAALgAFFAIJAgAAAA==.',
Ma='Macdemon:BAAALgADCgEJAQAAAA==.',
Me='Meta:BAAALgAECgQJBgAAAA==.Metass:BAAALgADCgMJBAAAAA==.',
Mi='Miinv:BAAALgADCgMJBQAAAA==.',
Mo='Monody:BAAALgAECgUJBwAAAA==.',
Om='Omi:BAAALgAECgUJBQAAAA==.',
Pl='Playerhotydn:BAABLgAFFH8FAAIDAAIJ0AwwQgCeAAADAAIJ0AwwQgCeAAAAAA==.Playerpteftp:BAABLgAECn8UAAIEAAYJpRaMgwBTAQAEAAYJpRaMgwBTAQAAAA==.Playerwqhvlt:BAAALgAECgUJBQAAAA==.Playerzqczuo:BAAALgAECgcJBwAAAA==.',
Su='Sussurro:BAAALgAECgEJAQAAAA==.',
Sz='Szero:BAAALgAECgYJCgAAAA==.',
Un='Unihamster:BAAALgAECgUJBQAAAA==.',
['七少']='七少:BAAALgADCgYJBgAAAA==.',
['不是']='不是算了我的:BAAALgAFFAIJAwABLgAFFAUJBQAFAN8aAA==.',
['不灭']='不灭苍穹:BAAALgAECgUJAwAAAA==.',
['不用']='不用驱我能解:BAAALgAECgUJBgAAAA==.',
['丰川']='丰川祥子:BAABLgAFFH8GAAICAAQJbQMUDwAQAQACAAQJbQMUDwAQAQAAAA==.',
['云一']='云一号:BAABLgAFFH8PAAIGAAYJCw/6AQCvAQAGAAYJCw/6AQCvAQAAAA==.',
['云三']='云三号:BAABLgAFFH8KAAIGAAUJRA1aDgCnAQAGAAUJRA1aDgCnAQABLgAFFAcJBAAHAAAAAA==.',
['云二']='云二号:BAABLgAFFH8JAAIGAAYJhhRbAgClAQAGAAYJhhRbAgClAQABLgAFFAcJBAAHAAAAAA==.',
['云四']='云四号:BAABLgAFFH8KAAIGAAYJSxDMBwBiAQAGAAYJSxDMBwBiAQABLgAFFAcJBAAHAAAAAA==.',
['今田']='今田美樱:BAAALgADCgMJAwAAAA==.',
['以下']='以下都该删号:BAAALgAECgQJBQAAAA==.',
['俺是']='俺是耕田滴:BAAALgAECgYJCAAAAA==.',
['倚楼']='倚楼君莫笑:BAAALgAFFAIJAgAAAA==.',
['做你']='做你的星光:BAAALgAECgUJBQAAAA==.',
['划水']='划水嗑瓜子:BAAALgAECgEJAQAAAA==.',
['初如']='初如晴天丶:BAAALgAECgcJBwAAAA==.',
['北风']='北风知我意:BAAALgAECgYJCAAAAA==.',
['半月']='半月小月半:BAAALgAFFAEJAQAAAA==.',
['卡哇']='卡哇伊小母牛:BAAALgAECgQJBQAAAA==.',
['厕所']='厕所哈尼心:BAAALgAECgYJCQAAAA==.',
['双子']='双子星嚤羯:BAAALgAECgcJCgAAAA==.',
['只会']='只会玩亚索:BAAALgAECgEJAQAAAA==.只会玩冰女:BAABLgAECn8VAAIGAAYJnQrGEQHZAAAGAAYJnQrGEQHZAAAAAA==.',
['叶子']='叶子系:BAAALgAECgEJAQAAAA==.',
['哈基']='哈基咪:BAAALgAECgcJCwAAAA==.',
['嘦巭']='嘦巭深:BAABLgAECn8XAAIIAAcJ9SFADwCfAgAIAAcJ9SFADwCfAgAAAA==.',
['圣光']='圣光属于我们:BAAALgAECgQJBQAAAA==.',
['坏脾']='坏脾气俏:BAABLgAECn8bAAQJAAYJtBX7LgCHAQAJAAYJtBX7LgCHAQAKAAEJ2gVgZQAuAAALAAMJlwcAAAAAAAAAAA==.',
['堕落']='堕落妖姬:BAAALgAECgEJAQAAAA==.',
['大跳']='大跳变游泳:BAAALgAFFAIJAgAAAA==.',
['天下']='天下黄汤:BAAALgAECgUJBQAAAA==.',
['天地']='天地一刀斩:BAAALgAECggJCAAAAA==.',
['头上']='头上犄角:BAAALgAECgYJCAAAAA==.',
['她说']='她说丶:BAAALgAECgcJBQAAAA==.',
['好色']='好色嘻嘻:BAAALgAECgQJCQAAAA==.',
['小乔']='小乔乔丶:BAAALgAECgEJAwAAAA==.小乔妈丶:BAAALgAECgEJAwAAAA==.',
['小司']='小司机:BAABLgAECn8YAAIEAAcJ5Q2HcQB8AQAEAAcJ5Q2HcQB8AQAAAA==.',
['小棉']='小棉裤:BAAALgAFFAIJAwAAAA==.',
['小灰']='小灰狼:BAAALgAECgIJAgAAAA==.',
['小罗']='小罗就吃肉:BAABLgAECn8bAAMMAAgJyg71HQDQAQAMAAgJyg71HQDQAQAFAAUJggTFqQC8AAAAAA==.',
['尕尕']='尕尕:BAAALgAECgcJDwAAAA==.',
['巅峰']='巅峰丿修罗灬:BAAALgAECgEJAgAAAA==.巅峰丿君臨灬:BAAALgAECgEJAQAAAA==.',
['川行']='川行者:BAAALgAECgQJBAAAAA==.',
['巨人']='巨人车头:BAAALgAECgUJBQAAAA==.',
['巨大']='巨大:BAAALgAECgYJCAABLgAFFAQJBgANAFUbAA==.',
['巴蒂']='巴蒂斯图团团:BAAALgAECgEJAQAAAA==.',
['布响']='布响丸辣:BAAALgAECgEJAQABLgAFFAQJDwACAOQhAA==.',
['干煸']='干煸四季豆:BAAALgADCgYJBgAAAA==.',
['幻兽']='幻兽之王:BAAALgADCgQJBAAAAA==.',
['幻雨']='幻雨月光:BAAALgADCgEJAQAAAA==.',
['幽幽']='幽幽南山:BAAALgAECgYJBgAAAA==.',
['很牛']='很牛的牛肉粉:BAAALgAECgYJDQAAAA==.',
['很猛']='很猛的母牛:BAAALgAFFAEJAQAAAA==.',
['御丶']='御丶守兔待猪:BAAALgAECgEJAgAAAA==.',
['微笑']='微笑不是演戏:BAAALgAECgUJBQAAAA==.',
['德资']='德资:BAAALgAECgMJAwAAAA==.',
['性感']='性感冷艳:BAAALgAECgcJEQAAAA==.',
['怨憎']='怨憎会:BAAALgAECgMJAwAAAA==.',
['憤怒']='憤怒的蜗牛:BAAALgAECgkJCgAAAA==.',
['扎西']='扎西:BAAALgAECgMJBAAAAA==.',
['批萨']='批萨猪:BAAALgAECgYJBwAAAA==.',
['放假']='放假不吃狗粮:BAAALgAFFAQJAwAAAA==.',
['敏龟']='敏龟的感头:BAAALgAECgcJBwAAAA==.',
['斧声']='斧声:BAAALgAECgQJBwAAAA==.',
['断怪']='断怪除妖:BAAALgADCgIJAgAAAA==.',
['旋转']='旋转卡卡子:BAAALgADCgUJBQAAAA==.',
['星間']='星間飞行:BAAALgAFFAIJAgAAAA==.',
['暴力']='暴力混学:BAAALgAECgYJBgAAAA==.',
['月灬']='月灬小陌:BAAALgADCgEJAgAAAA==.',
['有点']='有点小忐忑:BAAALgAECgYJBwAAAA==.',
['朵朵']='朵朵:BAAALgAECggJEwAAAA==.',
['杰尼']='杰尼龟:BAAALgADCgMJAwAAAA==.',
['柠檬']='柠檬哭酸涩:BAAALgAFFAIJAgAAAA==.',
['柴犬']='柴犬爸爸:BAABLgAECn8aAAMOAAgJPwoTOgA1AQAOAAcJbQsTOgA1AQANAAEJKQPyjgAmAAAAAA==.',
['梦魇']='梦魇小骑士:BAAALgAECgMJAwAAAA==.',
['欧皇']='欧皇小妮:BAAALgAFFAIJAQAAAA==.',
['武圣']='武圣关羽:BAAALgAECgQJBAAAAA==.',
['毛头']='毛头小术:BAACLgAFFH8GAAMEAAMJPRzDKgDGAAAEAAIJYSLDKgDGAAAPAAEJ8w8AAAAAAAAuAAQKfx0AAw8ABwk2I9wQAMcBAA8ABQnSG9wQAMcBAAQABQk5IehVAMYBAAAA.',
['毛毛']='毛毛珠珠露西:BAAALgADCgYJCwAAAA==.毛毛球:BAABLgAFFH8IAAILAAQJJSPTBACdAQALAAQJJSPTBACdAQAAAA==.',
['毛胖']='毛胖球:BAABLgAFFH8LAAILAAQJBSORBACkAQALAAQJBSORBACkAQABLgAFFAUJKgALAP8kAA==.',
['求不']='求不得:BAAALgAECgQJBAAAAA==.',
['求死']='求死谋生:BAABLgAECn8UAAMJAAYJlBadMAB/AQAJAAYJlBadMAB/AQAKAAYJLQclPAARAQAAAA==.',
['沉沦']='沉沦醉生梦死:BAAALgADCgYJBgAAAA==.',
['灰烬']='灰烬使者:BAAALgAECgYJCwAAAA==.',
['炖鸡']='炖鸡狂魔:BAAALgAECgYJCQAAAA==.',
['炫酷']='炫酷:BAAALgAECgEJAgAAAA==.',
['烈火']='烈火银狐:BAAALgADCgYJBQAAAA==.',
['烧烤']='烧烤大师:BAAALgAECgcJDQAAAA==.',
['热心']='热心市民小山:BAAALgAFFAQJBAAAAA==.',
['爱别']='爱别离:BAAALgAECggJCAAAAA==.',
['爱梅']='爱梅特赛尔克:BAACLgAFFH8FAAIFAAIJUBcLJQCrAAAFAAIJUBcLJQCrAAAuAAQKfyIAAwUACAlrHWoZALwCAAUACAlrHWoZALwCABAAAQlcAiYwACEAAAAA.',
['牛栏']='牛栏山:BAAALgAECgQJBwAAAA==.',
['狐福']='狐福福:BAABLgAECn8gAAIRAAcJKhxDJwAcAgARAAcJKhxDJwAcAgABLgAECggJGgASAEQdAA==.',
['猫儿']='猫儿啃泥巴:BAAALgAECgYJBgAAAA==.',
['獵头']='獵头者:BAAALgAECgYJCwAAAA==.',
['王影']='王影璐:BAABLgAFFH8FAAITAAUJTh7iAgDMAQATAAUJTh7iAgDMAQAAAA==.',
['王源']='王源:BAAALgAECgUJCAAAAA==.',
['珠珠']='珠珠露西毛毛:BAAALgADCgYJDAAAAA==.',
['琥珀']='琥珀酸脱氢酶:BAABLgAECn8gAAIUAAgJhhv7KwAAAgAUAAgJhhv7KwAAAgAAAA==.',
['男人']='男人:BAAALgADCgIJBAAAAA==.男人无敌:BAAALgADCgYJCAAAAA==.',
['當夏']='當夏末無蝉:BAAALgAECgkJCQAAAA==.',
['白梦']='白梦妍:BAAALgAECgMJBAAAAA==.',
['皮卡']='皮卡丘皮卡丘:BAABLgAFFH8GAAMVAAIJmhc+FACsAAAVAAIJmhc+FACsAAAIAAEJABPvHwBTAAAAAA==.',
['直击']='直击我的灵魂:BAACLgAFFH8IAAIEAAQJ2RVIFABJAQAEAAQJ2RVIFABJAQAuAAQKfxYAAwQABwmrHbp/AFsBAAQABAmGIrp/AFsBAA8AAwn2E+M2ANoAAAEuAAUUAgkDAAcAAAAA.',
['看家']='看家能手放假:BAAALgAFFAQJBAAAAA==.',
['知鱼']='知鱼:BAAALgAECgkJCQAAAA==.',
['石中']='石中剑:BAABLgAFFH8FAAIDAAMJVgw5IABZAAADAAMJVgw5IABZAAAAAA==.',
['离群']='离群的大猫咪:BAABLgAFFH8KAAIMAAMJOyFCBAA0AQAMAAMJOyFCBAA0AQAAAA==.',
['秋知']='秋知叶落:BAAALgAECgcJCgAAAA==.',
['童童']='童童:BAAALgAECgYJBgAAAA==.',
['籹吇']='籹吇借个吻:BAAALgAECgQJBQAAAA==.',
['红袖']='红袖:BAAALgAFFAIJAgAAAA==.',
['结界']='结界灬:BAACLgAFFH8OAAIDAAQJPiSHBgCeAQADAAQJPiSHBgCeAQAuAAQKfx4AAgMACAkPJnUIAFoDAAMACAkPJnUIAFoDAAAA.',
['舞零']='舞零舞:BAAALgADCgEJAQAAAA==.',
['艾德']='艾德蕾妮:BAAALgAECggJBwAAAA==.',
['艾陆']='艾陆之力:BAABLgAFFH8IAAISAAQJdRqsAwBRAQASAAQJdRqsAwBRAQAAAA==.',
['芤曖']='芤曖:BAAALgAFFAIJAgAAAA==.',
['芯碎']='芯碎:BAAALgAECgcJCAAAAA==.',
['花椰']='花椰菜之心:BAABLgAECn8aAAQWAAgJMg2hHQAdAQAWAAcJ5wuhHQAdAQAXAAMJ3AOWfgB/AAAYAAMJxwyQJQFUAAAAAA==.',
['苏幽']='苏幽璃:BAACLgAFFH8IAAIZAAMJew5fDADfAAAZAAMJew5fDADfAAAuAAQKfxkAAhkACAnrGMgRAEUCABkACAnrGMgRAEUCAAAA.',
['苏格']='苏格拉底:BAAALgAECgQJCQABLgAFFAYJDgAEAPoiAA==.',
['英俊']='英俊:BAAALgAECgEJAgAAAA==.',
['茜公']='茜公舉殿下丶:BAAALgAECgQJBAAAAA==.',
['荒野']='荒野镖猎:BAAALgAECgEJAQAAAA==.',
['莉亚']='莉亚迪桑:BAABLgAECn8UAAMRAAkJVRl7CAAKAwARAAkJVRl7CAAKAwAaAAYJMgoNTwATAQAAAA==.',
['莫名']='莫名心慌:BAAALgADCgEJAQAAAA==.',
['蒲公']='蒲公英:BAAALgAECgYJDQAAAA==.',
['蓝月']='蓝月儿:BAAALgAECgMJAwAAAA==.',
['蓝瘦']='蓝瘦香菇鸭:BAAALgAFFAQJAwAAAA==.',
['行星']='行星洄游:BAAALgAECgQJBAAAAA==.',
['西丨']='西丨猛:BAACLgAFFH8FAAMaAAIJTiMYGwCrAAAaAAIJsRoYGwCrAAARAAIJLB7rEAB0AAAuAAQKfygAAxoACAmEIYILAO4CABoACAkVIYILAO4CABEABwn6HEQfAEoCAAAA.',
['谁又']='谁又明浪子心:BAAALgAECgQJBwAAAA==.',
['谷雨']='谷雨:BAAALgAECgYJCwAAAA==.',
['超人']='超人只会飞:BAAALgAECgYJDwAAAA==.',
['超威']='超威老炮:BAABLgAECn8aAAQSAAgJRB3KDAA/AgASAAcJax/KDAA/AgAbAAIJ2ReXjQCIAAAcAAMJARI6MQBvAAAAAA==.',
['跑跑']='跑跑就是牛:BAAALgAECgcJEQAAAA==.',
['车车']='车车人:BAAALgADCgMJAwAAAA==.',
['遗弃']='遗弃新之助:BAAALgADCgYJBgAAAA==.遗弃神起:BAAALgADCgUJBQAAAA==.',
['那个']='那个龙人:BAACLgAFFH8JAAIGAAMJkxg3JwAWAQAGAAMJkxg3JwAWAQAuAAQKfxUAAgYACAk4IOAZABADAAYACAk4IOAZABADAAAA.',
['邪恶']='邪恶之霸:BAACLgAFFH8JAAMEAAQJOxQPDgADAQAEAAMJCxcPDgADAQAdAAEJywuwAQBUAAAuAAQKfxsAAgQACAkyHLEpAGoCAAQACAkyHLEpAGoCAAAA.',
['郭小']='郭小囡:BAAALgAECgIJBAAAAA==.',
['酒意']='酒意观山海:BAABLgAECn8UAAIDAAcJPh5iRAAoAgADAAcJPh5iRAAoAgABLgAFFAUJCQAPANghAA==.',
['酸菜']='酸菜雨:BAAALgAFFAIJAwAAAA==.',
['醉翩']='醉翩翩:BAAALgAECgYJCQAAAA==.',
['释永']='释永信:BAAALgADCgYJBgAAAA==.',
['重创']='重创手刃降服:BAAALgAECgUJBQAAAA==.',
['鋼鉄']='鋼鉄韵律:BAABLgAECn8aAAISAAgJxw0UHQBeAQASAAgJxw0UHQBeAQAAAA==.',
['长夜']='长夜孤月无间:BAAALgAFFAEJAQAAAA==.',
['阳光']='阳光宝宝:BAAALgAECgMJBQAAAA==.阳光小宝贝:BAAALgAFFAMJAwAAAA==.',
['阳阳']='阳阳宝贝:BAAALgAECgEJAQAAAA==.',
['阿蒙']='阿蒙:BAAALgADCgYJBwAAAA==.',
['陌上']='陌上寸草:BAAALgAECgQJBAAAAA==.',
['隋风']='隋风踏青:BAAALgAECgQJBAAAAA==.',
['隨機']='隨機事件:BAAALgAECgMJAwAAAA==.',
['雪之']='雪之凤凰:BAAALgADCggJCAAAAA==.',
['零神']='零神瑟丝卡:BAAALgAECgEJAgAAAA==.',
['霍霍']='霍霍:BAAALgAECgkJBgAAAA==.',
['霖泽']='霖泽天璇啸啸:BAAALgAECgkJDwAAAA==.',
['霜糖']='霜糖:BAAALgAECgYJCgAAAA==.',
['露西']='露西毛毛珠珠:BAAALgADCgcJBwAAAA==.',
['霸气']='霸气上冒:BAAALgAECgUJBgAAAA==.',
['顶级']='顶级手法:BAAALgAFFAIJAgABLgAFFAIJAwAHAAAAAA==.',
['风流']='风流飞雪:BAAALgADCgEJAQAAAA==.',
['飞龙']='飞龙车头:BAAALgADCgEJAQAAAA==.',
['香香']='香香熊:BAAALgAFFAIJAQAAAA==.',
['馬克']='馬克斯彡德:BAAALgAECgMJAwAAAA==.馬克斯彡肖:BAAALgAECgQJBAAAAA==.',
['骄阳']='骄阳严寒:BAAALgAECgQJBQAAAA==.',
['高冷']='高冷女明星:BAAALgAECgUJBQAAAA==.',
['高大']='高大壮:BAAALgAECgMJAwAAAA==.',
['鱼刺']='鱼刺丶:BAAALgAECgUJCwAAAA==.',
['鹿灵']='鹿灵泽:BAAALgADCgEJAQAAAA==.',
['鹿筱']='鹿筱森:BAAALgADCgIJAgAAAA==.',
['龍龍']='龍龍柒喊海底:BAAALgAECgIJAgAAAA==.',
['龘桜']='龘桜鲸:BAAALgAECgIJAgAAAA==.',
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
