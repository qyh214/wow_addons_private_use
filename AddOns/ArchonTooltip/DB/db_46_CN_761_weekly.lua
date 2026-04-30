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

local lookup = {'Shaman-Restoration','Rogue-Subtlety','Rogue-Assassination','Hunter-BeastMastery','Hunter-Marksmanship','Unknown-Unknown','DeathKnight-Blood','Druid-Restoration','Druid-Guardian','Shaman-Elemental','Monk-Brewmaster','DemonHunter-Devourer','DemonHunter-Havoc','DeathKnight-Unholy','Druid-Balance','Mage-Frost','Warrior-Arms','Warlock-Demonology','Priest-Holy','Priest-Discipline',}
local provider = {region='CN',realm='玛诺洛斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Airx:BAACLgAFFH8IAAIBAAIJ3A7xCwCKAAABAAIJ3A7xCwCKAAAuAAQKfxkAAgEABwk3GlIpAOoBAAEABwk3GlIpAOoBAAAA.',
As='Asbfjb:BAAALgAECgYJBwAAAA==.',
Ba='Bamboocm:BAAALgAECgIJAgAAAA==.',
Cy='Cybershot:BAAALgAECgkJCAAAAA==.',
Da='Darkavenger:BAAALgAECgYJBwAAAA==.',
Di='Disorderlyye:BAAALgADCgMJAwAAAA==.',
Fl='Flame:BAAALgAECgEJAQAAAA==.',
Ob='Obi:BAAALgADCgcJBwAAAA==.',
Pr='Prada:BAAALgAECgMJAwAAAA==.',
Qh='Qhnt:BAAALgADCgEJAQAAAA==.Qhnu:BAACLgAFFH8LAAICAAQJzB0hAgBuAQACAAQJzB0hAgBuAQAuAAQKfxUAAwIACAm6IMQMAMwCAAIACAkMIMQMAMwCAAMAAQm/IY8ZAGAAAAAA.',
Ra='Raver:BAACLgAFFH8KAAIEAAMJvyDSBwAmAQAEAAMJvyDSBwAmAQAuAAQKfxUAAwUABwmYGC8rANABAAUABwmlFS8rANABAAQAAgl0JM6WAKgAAAEuAAUUBAkMAAQACBgA.',
Si='Sixsixsix:BAAALgADCgIJAgAAAA==.',
Sm='Smilefox:BAAALgAECgcJEgAAAA==.',
St='Stargosa:BAAALgAFFAMJAwAAAA==.',
Ta='Tarecgosa:BAAALgAFFAEJAQABLgAFFAMJAwAGAAAAAA==.',
Tl='Tlan:BAAALgAECgkJCQAAAA==.',
Un='Unno:BAAALgAECgUJCgAAAA==.',
Wa='Walnut:BAAALgAECgYJDwAAAA==.',
Wy='Wyy:BAAALgAECgcJBwAAAA==.',
['一世']='一世一琉璃:BAAALgAECgEJAQAAAA==.一世无橙:BAAALgAECgUJBgAAAA==.',
['一个']='一个大领主:BAAALgADCgUJBQAAAA==.',
['一抹']='一抹无邪:BAAALgAECgcJAwAAAA==.',
['上邪']='上邪:BAAALgAECgYJBwAAAA==.',
['世界']='世界第一坦:BAABLgAFFH8LAAIHAAUJtwYHBQDXAAAHAAUJtwYHBQDXAAAAAA==.',
['丝般']='丝般幼滑:BAABLgAFFH8GAAIEAAQJARAbFQCwAAAEAAQJARAbFQCwAAAAAA==.',
['丶残']='丶残一月丶:BAAALgAECgEJAQAAAA==.',
['丷苏']='丷苏晚晚:BAAALgAECgIJAgABLgAECgYJBgAGAAAAAA==.',
['乂崽']='乂崽崽乂:BAACLgAFFH8MAAIIAAQJIh9HDAAfAQAIAAQJIh9HDAAfAQAuAAQKfxYAAwgACAnEIsMPALoCAAgACAnEIsMPALoCAAkAAwmbGGYdALcAAAAA.',
['乖乖']='乖乖龙嘀咚:BAAALgADCgEJAQAAAA==.',
['云朵']='云朵棉花糖:BAAALgAECgYJBwAAAA==.',
['云治']='云治:BAABLgAECn8WAAIFAAkJ5iOaAQCpAwAFAAkJ5iOaAQCpAwABLgAFFAUJBwAEAEEeAA==.',
['人帅']='人帅才黑:BAAALgADCgEJAQAAAA==.',
['人懒']='人懒愿望多:BAAALgAFFAQJAwAAAA==.',
['以德']='以德富人:BAAALgAECgYJCwAAAA==.',
['伊丽']='伊丽莎白曼玉:BAAALgAECgcJEAAAAA==.',
['伏月']='伏月之神:BAAALgAECgEJAQAAAA==.',
['佑灬']='佑灬:BAAALgAFFAIJBAAAAA==.',
['你与']='你与我佛有缘:BAAALgAECgQJBQAAAA==.',
['你瞧']='你瞧那只猫:BAAALgAFFAIJAgAAAA==.你瞧那头牛:BAAALgAECgYJDwAAAA==.',
['修假']='修假:BAAALgAECgEJAQAAAA==.',
['傲娇']='傲娇小媚娘:BAAALgAECgcJDgAAAA==.',
['光之']='光之风月:BAAALgAFFAQJAQAAAA==.',
['光影']='光影之羽:BAAALgAECgYJCgAAAA==.',
['全垒']='全垒手:BAAALgADCgMJAwAAAA==.',
['八变']='八变莽妹:BAABLgAECn8WAAIJAAYJthIuEwA+AQAJAAYJthIuEwA+AQAAAA==.',
['六个']='六个灬核桃:BAAALgADCgEJAQAAAA==.',
['冰月']='冰月寒丶雪:BAAALgADCgcJCQAAAA==.',
['冰柠']='冰柠茶:BAAALgAFFAIJAwABLgAFFAYJFgAKAMUZAA==.',
['冰飞']='冰飞霜:BAAALgAECgUJBQAAAA==.',
['冰魄']='冰魄寒鸩:BAABLgAFFH8GAAILAAIJ0xU6GwCSAAALAAIJ0xU6GwCSAAAAAA==.',
['凌枫']='凌枫秋:BAAALgAECgYJBgAAAA==.',
['切莫']='切莫逗逗瞎:BAACLgAFFH8JAAIMAAIJ7xZJJQCqAAAMAAIJ7xZJJQCqAAAuAAQKfxwAAwwACAn8GjE5ABACAAwACAlCGDE5ABACAA0ABgkLFWIuAFoBAAAA.',
['别着']='别着急在读条:BAAALgADCgcJBwAAAA==.',
['力工']='力工:BAAALgAECgQJAwAAAA==.',
['北极']='北极村的希望:BAAALgAECgYJAgAAAA==.',
['北落']='北落师门:BAAALgAECgYJDgAAAA==.',
['千寻']='千寻:BAAALgAECgUJCAAAAA==.',
['半藏']='半藏森林:BAAALgADCgUJBQAAAA==.',
['华丽']='华丽打击:BAAALgAECgUJCAAAAA==.',
['卖白']='卖白嘶的猫:BAAALgAECgEJAQAAAA==.',
['南方']='南方小土豆:BAABLgAFFH8IAAIOAAMJDiPEGwA1AQAOAAMJDiPEGwA1AQAAAA==.',
['卡利']='卡利熙:BAAALgAECgMJAwAAAA==.',
['危险']='危险大:BAAALgAECgcJCgAAAA==.',
['原来']='原来也可以:BAAALgAECgMJAwAAAA==.',
['双喜']='双喜猎猎:BAAALgAECgcJCwAAAA==.',
['古尔']='古尔蛋:BAAALgAECgEJAQAAAA==.',
['可乐']='可乐:BAAALgAECgYJEQAAAA==.',
['可爱']='可爱的小萌萌:BAAALgAECgIJAgAAAA==.可爱的汤包:BAAALgAFFAIJAgAAAA==.',
['听风']='听风细雨:BAABLgAECn8UAAIPAAcJWCBbEwB6AgAPAAcJWCBbEwB6AgAAAA==.',
['咬人']='咬人的蚊子:BAAALgAECgEJAQAAAA==.',
['哈里']='哈里路大旋风:BAAALgAFFAEJAQAAAA==.',
['哒哒']='哒哒丙:BAAALgAECgYJBgAAAA==.哒哒芙:BAABLgAFFH8JAAIQAAQJFAutHwBJAQAQAAQJFAutHwBJAQAAAA==.',
['唐朝']='唐朝诡事录:BAAALgAECgMJAwAAAA==.',
['喵呜']='喵呜气气:BAAALgAECgYJDAABLgAFFAYJEgARAE8VAA==.',
['囝藤']='囝藤:BAAALgAECgQJBAAAAA==.',
['囧雪']='囧雪诺:BAAALgADCgEJAQAAAA==.',
['土豆']='土豆骑士:BAAALgAECgkJCQAAAA==.',
['圣骑']='圣骑妇联主任:BAAALgADCgEJAQAAAA==.',
['在月']='在月亮上吻你:BAAALgAFFAIJAgAAAA==.',
['地皮']='地皮爱死法爷:BAAALgADCgEJAQAAAA==.',
['堂庭']='堂庭:BAAALgAFFAIJAgAAAA==.',
['墨染']='墨染丶:BAAALgAECgYJCQAAAA==.',
['墨水']='墨水:BAAALgAECgIJAgAAAA==.',
['大丧']='大丧失:BAAALgAECgYJCAAAAA==.',
['天啊']='天啊丶你真高:BAAALgAFFAEJAgAAAA==.',
['天天']='天天微笑:BAAALgAECgYJDAAAAA==.',
['天空']='天空卫士:BAAALgAECgEJAQAAAA==.',
['天驱']='天驱:BAAALgAECgEJAgAAAA==.',
['好多']='好多鱼:BAAALgAECgEJAQAAAA==.',
['妾身']='妾身不想奶:BAAALgAECgcJAQAAAA==.',
['姚曰']='姚曰月:BAAALgADCgYJCAAAAA==.',
['守卫']='守卫者火羽:BAAALgADCggJCAAAAA==.',
['害生']='害生嘎:BAAALgAECgUJBgAAAA==.',
['寒星']='寒星雨:BAAALgAECgcJDQABLgAECgcJFAAPAFggAA==.',
['寒风']='寒风化雨:BAAALgADCgMJAwAAAA==.',
['射的']='射的罪过:BAAALgAECgEJAQAAAA==.',
['小南']='小南辰王:BAAALgAECgYJDgAAAA==.',
['小火']='小火龙:BAAALgAFFAIJBAAAAA==.',
['小筱']='小筱筱:BAAALgAECgYJBwAAAA==.',
['小能']='小能貓:BAAALgAECgQJBAAAAA==.',
['屠夫']='屠夫快跑:BAAALgADCgkJCQAAAA==.',
['左耳']='左耳:BAAALgAECgYJEQAAAA==.',
['巨人']='巨人尤姆:BAAALgAECgEJAQAAAA==.',
['巫马']='巫马:BAABLgAFFH8JAAISAAMJohgeGwAbAQASAAMJohgeGwAbAQAAAA==.',
['幸福']='幸福的微笑:BAAALgADCgEJAQAAAA==.',
['幻风']='幻风灵月:BAAALgAECgQJBwAAAA==.',
['康斯']='康斯坦丁:BAAALgAECgEJAQAAAA==.',
['弘忍']='弘忍:BAAALgAFFAIJAwAAAA==.',
['张顺']='张顺飞:BAAALgAECgIJAgAAAA==.',
['彩渱']='彩渱邊的雨雲:BAAALgAECgYJDAAAAA==.',
['御姐']='御姐:BAAALgAECgcJBwAAAA==.',
['心棱']='心棱丶:BAAALgAECgYJBgAAAA==.',
['忠不']='忠不可言:BAAALgAECgYJDgAAAA==.',
['恆河']='恆河大水牛:BAAALgAECggJBgABLgAECgkJCQAGAAAAAA==.',
['恋凌']='恋凌凌:BAAALgAECgIJAgAAAA==.',
['悄悄']='悄悄片:BAABLgAFFH8KAAIOAAQJWheqBQBfAQAOAAQJWheqBQBfAQAAAA==.',
['惨叫']='惨叫姬:BAAALgAECgEJAQAAAA==.',
['愛戀']='愛戀丨永恆:BAAALgADCgQJBAAAAA==.',
['慯心']='慯心心:BAAALgAECgEJAwAAAA==.',
['我家']='我家猫是老板:BAABLgAFFH8FAAIEAAMJYxM/CwAIAQAEAAMJYxM/CwAIAQAAAA==.',
['我是']='我是萨馒:BAAALgADCgEJAQAAAA==.',
['我说']='我说我不帅:BAAALgAECgEJAQAAAA==.',
['扑克']='扑克牌:BAAALgAECgMJAwAAAA==.',
['扯淡']='扯淡的圣光:BAAALgAECgEJAgAAAA==.',
['扶风']='扶风若柳:BAAALgAECgUJCQAAAA==.',
['排脓']='排脓次的六:BAAALgAECgEJAQABLgAFFAQJBAAGAAAAAA==.',
['星光']='星光小鴨:BAAALgAFFAEJAgAAAA==.',
['星辰']='星辰:BAAALgAFFAIJAgAAAA==.',
['晚风']='晚风不再停留:BAAALgADCgIJAgAAAA==.',
['智慧']='智慧果丶:BAAALgAECgUJBQAAAA==.',
['暮雨']='暮雨晨曦:BAAALgAECgYJCAAAAA==.',
['暴走']='暴走小丸子:BAAALgAECgIJAgAAAA==.',
['曦辉']='曦辉川三号机:BAAALgADCgYJBgAAAA==.曦辉川二号机:BAAALgADCgQJBAAAAA==.',
['曲尘']='曲尘花:BAAALgAECgYJEAAAAA==.',
['最美']='最美大姨妈:BAAALgAECgYJBgAAAA==.',
['月咏']='月咏:BAAALgAECgYJBgAAAA==.',
['月夜']='月夜浅吟:BAAALgAECgIJAgAAAA==.',
['月殇']='月殇零度:BAAALgAECgUJBgAAAA==.',
['月焱']='月焱之銘:BAAALgADCgMJAwAAAA==.',
['朦朦']='朦朦恶魔:BAAALgAFFAIJAwAAAA==.',
['木夜']='木夜动秋声:BAAALgAECgEJAQAAAA==.',
['来碗']='来碗泡面:BAAALgAECgQJBAAAAA==.',
['林友']='林友友丶:BAAALgAECgYJBgAAAA==.',
['林深']='林深抚月痕:BAABLgAECn8YAAMEAAcJAiTWEACzAgAEAAcJAiTWEACzAgAFAAMJTAsucAB+AAAAAA==.',
['桐人']='桐人:BAAALgAECgYJBgAAAA==.',
['桐范']='桐范范:BAAALgAECgYJCwAAAA==.',
['桜绒']='桜绒:BAAALgAECgUJCAAAAA==.',
['梦幻']='梦幻之无敌:BAAALgAECgkJCQAAAA==.',
['梦魇']='梦魇妖姬:BAAALgAECgMJAwAAAA==.',
['梨丶']='梨丶陌颜:BAAALgAECgEJAQAAAA==.',
['植物']='植物人:BAAALgAECgMJAwAAAA==.',
['檬檬']='檬檬的橙:BAAALgAFFAMJBAAAAA==.',
['止水']='止水:BAAALgAFFAQJBAAAAA==.',
['武艺']='武艺:BAAALgAECgYJBgAAAA==.',
['歳絔']='歳絔無聲:BAAALgAECgEJAQAAAA==.',
['死亡']='死亡之角虫:BAAALgAECgQJBAAAAA==.',
['比克']='比克鲁斯:BAAALgAECgUJCAAAAA==.',
['永恒']='永恒叶:BAAALgAFFAEJAQAAAA==.',
['江南']='江南七海:BAAALgAFFAIJBAAAAA==.江南米汀:BAAALgAECgcJBwABLgAFFAIJBAAGAAAAAA==.江南露米:BAAALgAFFAIJAwABLgAFFAIJBAAGAAAAAA==.',
['沉默']='沉默的喜羊羊:BAABLgAECn8UAAIQAAYJ/wzNxwBYAQAQAAYJ/wzNxwBYAQAAAA==.沉默的懒羊羊:BAAALgAECgYJBwAAAA==.',
['波暑']='波暑:BAAALgAFFAEJAQAAAA==.',
['洛叶']='洛叶:BAAALgAECgEJAgAAAA==.',
['流馨']='流馨雨:BAAALgAECgQJBwAAAA==.',
['混沌']='混沌力量之源:BAAALgAECgQJBAAAAA==.',
['温柔']='温柔波波:BAAALgAECgQJBAAAAA==.',
['火羽']='火羽丶流星:BAAALgAECgMJAwAAAA==.',
['灬佐']='灬佐:BAAALgAECgUJCQAAAA==.',
['灰太']='灰太狼之殇:BAAALgAECgIJAwAAAA==.',
['点点']='点点之愿:BAAALgAECgEJAQAAAA==.',
['烟雨']='烟雨淡淡香:BAAALgAECgYJDAAAAA==.',
['热卤']='热卤电视机:BAAALgAECgEJAQAAAA==.',
['热情']='热情马铃薯:BAAALgAECgQJBAAAAA==.',
['爱一']='爱一个人:BAAALgAECgYJBgAAAA==.',
['牛可']='牛可:BAAALgAECgkJEAAAAA==.',
['狼教']='狼教授:BAAALgAECgEJAQAAAA==.',
['猫也']='猫也笨笨:BAAALgADCgcJBwAAAA==.',
['猫眼']='猫眼看世界:BAAALgAECgEJAgAAAA==.',
['玉珑']='玉珑之心:BAAALgAECggJBwAAAA==.',
['珍惜']='珍惜:BAAALgAECgYJBgAAAA==.',
['疯牛']='疯牛:BAAALgAECgMJBQAAAA==.',
['疯狂']='疯狂的幻影:BAAALgADCgMJAwAAAA==.',
['盾牌']='盾牌亦可破:BAAALgAFFAQJBAAAAA==.',
['真的']='真的不可以吗:BAAALgAECgIJAgAAAA==.真的可以吗:BAAALgAECgMJAwAAAA==.',
['睁眼']='睁眼虾:BAAALgAECgEJAQAAAA==.',
['睡在']='睡在梦乡:BAAALgAFFAEJAQAAAA==.',
['瞬间']='瞬间瞬间瞬间:BAAALgAFFAIJAwABLgAFFAUJBwAQAMcZAA==.',
['砍你']='砍你没商量:BAAALgAECgUJBgAAAA==.',
['祖马']='祖马猎:BAAALgAECgEJAQAAAA==.',
['神罚']='神罚之箭:BAAALgAECgcJBwAAAA==.',
['祭血']='祭血关山:BAAALgAECgUJBQAAAA==.',
['秋昆']='秋昆丨小乌鸦:BAAALgAECgYJBwAAAA==.',
['红色']='红色的曲线:BAAALgAECgYJAwAAAA==.',
['绝影']='绝影:BAABLgAFFH8GAAINAAQJrhDuAABVAQANAAQJrhDuAABVAQAAAA==.',
['继续']='继续么么:BAAALgAECgUJCwAAAA==.继续呵呵哒:BAAALgAECgYJDQAAAA==.继续微笑:BAAALgAECgMJBQAAAA==.',
['绿洲']='绿洲星彩:BAAALgAECgUJBgAAAA==.绿洲星瑶:BAAALgAECgUJBwAAAA==.绿洲星紫:BAAALgAECgYJDAAAAA==.绿洲星陨:BAAALgAECgUJBQAAAA==.',
['美心']='美心面包:BAAALgADCgQJBAAAAA==.',
['群友']='群友情绪价值:BAAALgAECgQJBAAAAA==.',
['老子']='老子碉堡了:BAAALgAECgQJBwAAAA==.',
['联盟']='联盟的国王:BAAALgADCgIJAgAAAA==.',
['脚真']='脚真的不臭:BAAALgAECgMJBAAAAA==.',
['自来']='自来也:BAAALgAECgkJDgAAAA==.',
['至尊']='至尊战德:BAAALgAFFAEJAQAAAA==.',
['艾伦']='艾伦家的李白:BAAALgAFFAIJAgAAAA==.艾伦家的蔡琰:BAAALgAECgYJCAAAAA==.',
['芫荽']='芫荽:BAAALgAECgEJAQAAAA==.',
['苳冬']='苳冬冬:BAAALgAECgEJAQAAAA==.',
['莫里']='莫里亞蒂:BAAALgADCgIJAgAAAA==.',
['萨米']='萨米娜:BAAALgAFFAEJAQAAAA==.',
['薇薇']='薇薇安可:BAAALgADCgQJBAAAAA==.',
['虚夜']='虚夜月:BAAALgADCgQJBAAAAA==.',
['虚幻']='虚幻的背影:BAAALgAECgUJBQAAAA==.',
['虱蚤']='虱蚤:BAAALgADCgQJBAAAAA==.',
['虾仁']='虾仁不眨眼:BAABLgAFFH8HAAIBAAMJ+BW6BwDZAAABAAMJ+BW6BwDZAAAAAA==.',
['血腥']='血腥玛丽亚:BAAALgAECgQJAQAAAA==.',
['血衣']='血衣不染尘:BAAALgAECgYJBgAAAA==.',
['裹裹']='裹裹妙:BAAALgADCgQJBAAAAA==.',
['见机']='见机行事:BAAALgAECgUJCQAAAA==.',
['诗与']='诗与远方:BAAALgADCgUJBQAAAA==.',
['读灬']='读灬条:BAAALgAECgIJBAAAAA==.',
['趴趴']='趴趴老爹丶:BAAALgAECgQJDwAAAA==.',
['辣鸡']='辣鸡尼光:BAAALgAFFAQJBAABLgAFFAUJAgAGAAAAAA==.',
['过往']='过往云烟灬:BAAALgAECgQJBAAAAA==.',
['这桶']='这桶下肚要倒:BAAALgADCgYJBgAAAA==.',
['这里']='这里有情况:BAAALgAFFAIJAgAAAA==.',
['追光']='追光者:BAACLgAFFH8JAAIJAAYJhxG9AAC8AQAJAAYJhxG9AAC8AQAuAAQKfxoAAgkACQm0GnYEAKsCAAkACQm0GnYEAKsCAAAA.',
['遗忘']='遗忘风:BAAALgADCgEJAwAAAA==.',
['那年']='那年丶冬天:BAAALgAFFAIJAwAAAA==.',
['邪恶']='邪恶摇粒绒:BAAALgAECgkJDwAAAA==.',
['邪王']='邪王小白:BAAALgADCgUJBQAAAA==.',
['酸菜']='酸菜汁淬毒刃:BAABLgAFFH8KAAICAAQJuRAxCQBcAQACAAQJuRAxCQBcAQAAAA==.',
['野蛮']='野蛮斗帝:BAAALgAECgYJCAAAAA==.',
['钕澡']='钕澡堂搓澡工:BAABLgAFFH8GAAISAAQJtxdUPwCMAAASAAQJtxdUPwCMAAAAAA==.',
['铅华']='铅华落尽时丶:BAAALgAECgEJAQAAAA==.',
['长不']='长不大的熊熊:BAAALgAECgEJAQAAAA==.',
['长歌']='长歌如酒丶:BAAALgAECgcJAwAAAA==.',
['阿香']='阿香公爵:BAAALgAECgEJAgAAAA==.',
['陶萌']='陶萌豆:BAAALgAECgYJBgAAAA==.',
['陶豆']='陶豆豆:BAAALgADCgEJAQAAAA==.',
['隔壁']='隔壁的小灰毛:BAAALgAECgIJAwAAAA==.',
['雅香']='雅香:BAAALgAECgYJBwAAAA==.',
['雪衣']='雪衣吥染塵:BAAALgAECgYJCwAAAA==.雪衣黙黙僾:BAAALgAECgYJCwAAAA==.',
['雾里']='雾里小白:BAABLgAECn8cAAMTAAcJYhciJADGAQATAAcJYhciJADGAQAUAAEJagp4FwA7AAAAAA==.',
['霄月']='霄月:BAAALgAECgYJCwAAAA==.',
['青影']='青影:BAABLgAFFH8GAAISAAIJcBt9FQC4AAASAAIJcBt9FQC4AAAAAA==.',
['青歌']='青歌富恒:BAAALgAECgEJAQAAAA==.',
['风不']='风不会停息:BAAALgAECgUJCgAAAA==.',
['风起']='风起云涌:BAAALgAECgIJAQAAAA==.',
['风鹰']='风鹰长啸:BAAALgAFFAIJAwAAAA==.',
['飞花']='飞花:BAAALgAECgEJAQAAAA==.',
['馮宝']='馮宝宝:BAAALgAECgYJDwAAAA==.',
['鲸落']='鲸落:BAAALgADCgEJAQAAAA==.',
['鸢尾']='鸢尾花的回憶:BAAALgAECgcJBwAAAA==.',
['麦林']='麦林咻咻:BAAALgADCgIJAgAAAA==.',
['黄昏']='黄昏:BAABLgAFFH8HAAINAAIJsRRCCQCkAAANAAIJsRRCCQCkAAAAAA==.',
['黑色']='黑色不锈:BAACLgAFFH8GAAIOAAIJABlaPQCkAAAOAAIJABlaPQCkAAAuAAQKfx8AAg4ACAkOHlwtAIMCAA4ACAkOHlwtAIMCAAAA.',
['黙黙']='黙黙僾:BAAALgAECgYJCwAAAA==.',
['龔丞']='龔丞狮:BAAALgAECgYJDgAAAA==.',
['龙小']='龙小默默:BAAALgAECgMJAwAAAA==.',
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
