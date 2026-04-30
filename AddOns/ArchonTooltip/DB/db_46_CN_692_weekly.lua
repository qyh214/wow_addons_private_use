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

local lookup = {'Warrior-Fury','DeathKnight-Unholy','Warrior-Arms','Unknown-Unknown','Hunter-BeastMastery','Mage-Frost','Warrior-Protection','DemonHunter-Devourer','DemonHunter-Havoc','Monk-Brewmaster','Priest-Discipline','Evoker-Augmentation','Hunter-Marksmanship','Monk-Mistweaver','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Paladin-Holy','Monk-Windwalker','Priest-Shadow','Paladin-Retribution','Shaman-Elemental','Shaman-Restoration','Druid-Restoration','DeathKnight-Frost','Evoker-Preservation','Evoker-Devastation','DemonHunter-Vengeance','Druid-Balance',}
local provider = {region='CN',realm='提尔之手',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Alexanderamy:BAAALgAFFAMJBAAAAA==.',
An='Annecy:BAAALgAECgIJAwAAAA==.',
Ba='Baga:BAACLgAFFH8GAAIBAAIJThOoFwCrAAABAAIJThOoFwCrAAAuAAQKfx0AAgEABwkfHWYbAHECAAEABwkfHWYbAHECAAAA.',
Ca='Candycoco:BAAALgAFFAEJAgAAAA==.',
Cl='Cleinmoretti:BAABLgAFFH8GAAICAAQJhhLbCwAUAQACAAQJhhLbCwAUAQAAAA==.',
Cr='Crazilyshrek:BAAALgAECgEJAgAAAA==.Crimson:BAAALgAFFAIJBAABLgAFFAQJCwADACQgAA==.',
Fi='Firewaltz:BAAALgAFFAIJBAAAAA==.',
Ka='Katarin:BAAALgAECgEJAQAAAA==.Kayw:BAAALgAECgEJAQABLgAECgYJCgAEAAAAAA==.',
Li='Liesbey:BAAALgADCgYJCgAAAA==.',
Mo='Monk:BAAALgAECgEJAQAAAA==.',
Nr='Nrmandela:BAAALgAFFAQJBAAAAA==.',
Nu='Numk:BAAALgADCgMJAwAAAA==.',
Oo='Ooningoo:BAAALgAFFAIJBAABLgAFFAUJDwAFAAcbAA==.',
Ou='Ou:BAAALgAECgMJAwAAAA==.',
Ro='Robust:BAAALgADCgUJBQAAAA==.',
Te='Teny:BAAALgAECgcJBwAAAA==.',
To='Toyly:BAAALgAECgEJAQAAAA==.',
Wo='Worki:BAAALgAFFAQJAgAAAA==.',
['一抹']='一抹天蓝色:BAACLgAFFH8KAAIGAAQJUhnYFQByAQAGAAQJUhnYFQByAQAuAAQKfyIAAgYACAksIa0gAPECAAYACAksIa0gAPECAAAA.',
['七月']='七月杀:BAABLgAFFH8GAAIGAAIJeRx1PgCwAAAGAAIJeRx1PgCwAAAAAA==.',
['三十']='三十六帝飞机:BAAALgAECgYJEQABLgAFFAUJDwAFAAcbAA==.',
['不万']='不万能的青年:BAACLgAFFH8LAAMDAAQJJCA9AQCOAQADAAQJJCA9AQCOAQABAAEJvBhCIABVAAAuAAQKfxkABAMACAlUIsMIACYCAAMABgnHIcMIACYCAAEABQmxIZY4AMQBAAcABAmIGOQsANoAAAAA.',
['丨素']='丨素还真丨:BAABLgAECn8ZAAICAAcJuCOwLACGAgACAAcJuCOwLACGAgAAAA==.',
['丶楪']='丶楪祈:BAAALgAECgIJAgABLgAFFAQJCgAIAHoGAA==.',
['乄起']='乄起风了:BAACLgAFFH8KAAMIAAQJegYUIADVAAAIAAMJpAUUIADVAAAJAAIJaAUCCwCKAAAuAAQKfyMAAwgACAmYF5EyADACAAgACAmYF5EyADACAAkABQlyD3k4ACIBAAAA.',
['乐撞']='乐撞小幸运:BAAALgAECgYJCAAAAA==.',
['乱扣']='乱扣费:BAAALgAECgcJBwAAAA==.',
['云泽']='云泽:BAAALgAECgEJAQAAAA==.',
['五德']='五德充沛:BAAALgAECgUJBwAAAA==.',
['五晨']='五晨寺炎掌门:BAAALgAECgYJBgAAAA==.',
['今天']='今天不做黑酋:BAAALgAECgIJAgAAAA==.',
['伊什']='伊什塔尔:BAAALgAECgkJDAAAAA==.',
['伏特']='伏特加马天尼:BAAALgADCgIJAgAAAA==.',
['低保']='低保老师傅:BAAALgAECgkJBAAAAA==.',
['佚名']='佚名翼:BAAALgADCgUJBQAAAA==.',
['佛罗']='佛罗伦娜:BAAALgADCgcJBwAAAA==.',
['光与']='光与火:BAAALgADCgYJBgAAAA==.',
['冰峰']='冰峰零度:BAAALgAFFAIJAgAAAA==.',
['冰美']='冰美式:BAAALgAECgQJBAAAAA==.',
['凄之']='凄之哀伤:BAAALgAECgIJAgAAAA==.',
['凨雲']='凨雲劣人:BAAALgADCgYJBgAAAA==.凨雲小战:BAAALgADCgcJDAAAAA==.凨雲洒满:BAAALgADCgYJBgAAAA==.',
['划水']='划水小学生:BAAALgADCgMJBQAAAA==.',
['加尔']='加尔鲁什地狱:BAAALgAECgQJBgAAAA==.',
['加菲']='加菲喵很懒:BAABLgAECn8VAAICAAYJKBMaJwD2AAACAAYJKBMaJwD2AAAAAA==.',
['半盏']='半盏观山海:BAAALgAECgYJCAABLgAECgYJDgAEAAAAAA==.',
['南乡']='南乡子:BAAALgAECgYJBwAAAA==.',
['卡斯']='卡斯帕尔:BAAALgADCgUJBQAAAA==.',
['叫我']='叫我莫莫:BAAALgAECgYJCgAAAA==.',
['呵呵']='呵呵牛逼:BAAALgAECgYJDAAAAA==.',
['命运']='命运正伟:BAAALgAECgIJAgAAAA==.',
['咕哒']='咕哒子:BAAALgAFFAEJAQAAAA==.',
['咕噜']='咕噜咕噜圆:BAABLgAFFH8OAAIKAAQJjxHQDAAeAQAKAAQJjxHQDAAeAQAAAA==.',
['哈庚']='哈庚七七:BAAALgAECgMJAwAAAA==.',
['啼魂']='啼魂:BAAALgADCgEJAQAAAA==.',
['圣骑']='圣骑我最拽:BAAALgAECgEJAgAAAA==.',
['城堡']='城堡:BAAALgADCgQJBAAAAA==.',
['基德']='基德:BAAALgAECgYJDAAAAA==.',
['夏天']='夏天的茶叶:BAAALgADCgUJBQAAAA==.',
['夜不']='夜不见雾梢:BAAALgAECgYJBgAAAA==.',
['夜丶']='夜丶枫:BAAALgAFFAIJAgAAAA==.',
['大尾']='大尾巴鱼:BAAALgAFFAEJAgAAAA==.',
['大滋']='大滋水枪:BAAALgAECgUJBwAAAA==.',
['大炮']='大炮架子包爽:BAAALgADCgQJBAAAAA==.',
['好有']='好有型:BAAALgAECgYJDwAAAA==.',
['妈妈']='妈妈:BAABLgAFFH8GAAILAAQJJAtJCwApAQALAAQJJAtJCwApAQAAAA==.',
['孑弦']='孑弦:BAAALgAFFAIJBAAAAA==.',
['学习']='学习大王:BAAALgAECgYJBgAAAA==.',
['安杜']='安杜尼苏斯:BAAALgADCgIJAgAAAA==.',
['寒食']='寒食:BAABLgAFFH8FAAIMAAQJWgOtEAD8AAAMAAQJWgOtEAD8AAAAAA==.',
['寻常']='寻常巷陌:BAAALgAECgYJDAAAAA==.',
['小倩']='小倩乖:BAACLgAFFH8PAAIFAAUJBxswAADrAQAFAAUJBxswAADrAQAuAAQKfx4AAwUACAm7Ix8FADsDAAUACAm7Ix8FADsDAA0AAQmZFw2BAEIAAAAA.',
['小小']='小小芳芳:BAACLgAFFH8JAAIOAAQJXyJTBAChAQAOAAQJXyJTBAChAQAuAAQKfxoAAg4ABwlYJDMIANQCAA4ABwlYJDMIANQCAAAA.',
['小滋']='小滋水枪:BAABLgAFFH8PAAIGAAUJiCC3EgCCAQAGAAUJiCC3EgCCAQAAAA==.',
['小羊']='小羊的爷爷:BAAALgAECgcJEgAAAA==.',
['小野']='小野六花:BAAALgAECgUJBQAAAA==.',
['尘墨']='尘墨:BAAALgADCgEJAQAAAA==.',
['岳火']='岳火术:BAAALgAECgIJAgAAAA==.',
['巨鲨']='巨鲨:BAAALgAECgMJAwAAAA==.',
['带头']='带头大个:BAAALgAECgEJAgAAAA==.',
['怀瑾']='怀瑾握瑜:BAABLgAECn8bAAQPAAcJDxtcTQDgAQAPAAYJDxtcTQDgAQAQAAIJVAdQVABxAAARAAEJHgK8NwAgAAAAAA==.',
['悶油']='悶油瓶:BAAALgADCgYJBgAAAA==.',
['我不']='我不萌:BAACLgAFFH8GAAISAAMJAAsIEADYAAASAAMJAAsIEADYAAAuAAQKfx0AAhIACAmxFYwiAAoCABIACAmxFYwiAAoCAAAA.',
['我要']='我要你背我:BAAALgAECgMJAwAAAA==.',
['抗住']='抗住吖犄角:BAAALgADCgUJBQAAAA==.',
['断弓']='断弓:BAAALgAECgYJCQAAAA==.',
['斯坦']='斯坦森郭达:BAACLgAFFH8UAAITAAUJnQ33AgB6AQATAAUJnQ33AgB6AQAuAAQKfxsAAhMACQkIGPMQAHMCABMACQkIGPMQAHMCAAAA.',
['无奈']='无奈之举:BAACLgAFFH8LAAIKAAQJehQmCwAtAQAKAAQJehQmCwAtAQAuAAQKfyUAAgoACAlaGTcaADICAAoACAlaGTcaADICAAAA.',
['星空']='星空:BAAALgADCgEJAQAAAA==.',
['智力']='智力高乐高:BAAALgAECggJDwAAAA==.',
['月落']='月落无痕:BAAALgAFFAEJAQAAAA==.',
['李逵']='李逵:BAAALgAECggJAgAAAA==.',
['李队']='李队长:BAAALgAECgkJCQAAAA==.',
['林花']='林花谢了春红:BAAALgAECgEJAQAAAA==.',
['正义']='正义的小羊:BAAALgAECgIJAgAAAA==.',
['死靈']='死靈猎手:BAAALgAECgIJAwAAAA==.',
['殇泪']='殇泪:BAAALgAECgEJAQAAAA==.',
['毁丶']='毁丶灭:BAAALgADCgkJCAAAAA==.',
['毁灭']='毁灭曼巴:BAAALgAECgUJAQAAAA==.',
['江东']='江东猛虎:BAAALgAECgEJAQAAAA==.',
['池鱼']='池鱼:BAAALgADCgYJBgAAAA==.',
['沏上']='沏上一壶茶:BAAALgAECgYJDgAAAA==.',
['沐冉']='沐冉尘:BAABLgAFFH8KAAIGAAQJwhGUHABZAQAGAAQJwhGUHABZAQAAAA==.',
['治疗']='治疗曼巴:BAAALgADCgUJBQAAAA==.',
['洁云']='洁云:BAAALgAECgYJCQAAAA==.',
['清霄']='清霄酒:BAACLgAFFH8IAAIOAAQJXhvJBgBXAQAOAAQJXhvJBgBXAQAuAAQKfxUAAw4ACAnYG1IOAHICAA4ACAnYG1IOAHICABMAAQnTE6J2AD0AAAAA.',
['温上']='温上一壶酒:BAAALgAECgUJBwABLgAECgYJDgAEAAAAAA==.',
['漫步']='漫步远征路:BAAALgADCgYJAQAAAA==.',
['灵荫']='灵荫:BAAALgADCgQJBAAAAA==.',
['热门']='热门妹妹:BAAALgAECgYJDwAAAA==.',
['無聊']='無聊的小白:BAAALgADCgEJAQAAAA==.',
['然然']='然然:BAAALgAFFAQJBAABLgAFFAQJBgAUAAcWAA==.',
['爱意']='爱意随钟起:BAAALgAFFAEJAQAAAA==.',
['爸气']='爸气歪露:BAAALgADCgUJBQAAAA==.',
['牢大']='牢大:BAABLgAECn8aAAIPAAcJDhnsOAAoAgAPAAcJDhnsOAAoAgAAAA==.',
['特兰']='特兰奇亚:BAAALgAECggJCQAAAA==.',
['用箭']='用箭当用长:BAAALgAECgYJCgAAAA==.',
['目木']='目木:BAAALgAECgEJAQAAAA==.',
['盾御']='盾御天下:BAAALgAECgIJAQAAAA==.',
['真棒']='真棒:BAAALgAECgIJAwAAAA==.',
['瞎髻']='瞎髻墢飋:BAAALgAECgUJBQAAAA==.',
['神裂']='神裂火織:BAABLgAFFH8GAAMFAAQJqw+PBABZAQAFAAQJqw+PBABZAQANAAEJbwadKgBGAAAAAA==.',
['神避']='神避:BAAALgADCgUJBQAAAA==.',
['穆冉']='穆冉尘:BAAALgAECgIJAgAAAA==.',
['立正']='立正:BAAALgAECgUJCAAAAA==.',
['竖着']='竖着:BAAALgADCgUJBQAAAA==.',
['粉色']='粉色棉花:BAABLgAECn8bAAIVAAgJKRyVLABxAgAVAAgJKRyVLABxAgABLgAFFAIJAgAEAAAAAA==.',
['紫色']='紫色大喷菇:BAAALgAFFAEJAQAAAA==.',
['縌愛']='縌愛緈諨:BAAALgADCgYJBgAAAA==.',
['绝对']='绝对核心:BAAALgAFFAIJBAABLgAFFAUJBQAGAGkYAA==.',
['绞杀']='绞杀:BAAALgAECgEJAQAAAA==.绞杀联盟:BAAALgADCgIJAgAAAA==.',
['罗斯']='罗斯特:BAACLgAFFH8KAAMWAAQJfRMoCQBMAQAWAAQJfRMoCQBMAQAXAAEJcwOCIgBJAAAuAAQKfyUAAxYACAlaHZcUAHkCABYACAlaHZcUAHkCABcABwmyDhpRAEABAAAA.',
['美味']='美味烤鹌鹑:BAAALgAFFAEJAQAAAA==.',
['臭臭']='臭臭的佳:BAAALgAFFAIJAwAAAA==.',
['致命']='致命枯萎:BAABLgAECn8ZAAICAAcJFBk8RgAiAgACAAcJFBk8RgAiAgAAAA==.',
['艾丝']='艾丝蒂尔:BAAALgADCgIJAQAAAA==.',
['艾泽']='艾泽拉斯:BAABLgAECn8VAAIYAAcJsyCrFQCJAgAYAAcJsyCrFQCJAgAAAA==.',
['苹儿']='苹儿:BAAALgAECgQJBQAAAA==.',
['荒川']='荒川爆笑团:BAAALgAECgYJDAAAAA==.',
['莼丨']='莼丨红色:BAAALgAECgIJAgAAAA==.',
['萨菲']='萨菲隆:BAAALgADCgcJBwAAAA==.',
['落花']='落花无意:BAAALgAECgQJAQAAAA==.',
['葉落']='葉落薔薇:BAAALgADCgcJBwAAAA==.',
['薛定']='薛定谔的厨子:BAAALgAECgkJCQAAAA==.',
['蛋卷']='蛋卷哥:BAAALgADCgYJBgAAAA==.蛋卷王子:BAAALgAECgUJBQAAAA==.',
['蜜桃']='蜜桃雪糕:BAABLgAFFH8FAAICAAMJ7Q7yKQDyAAACAAMJ7Q7yKQDyAAAAAA==.',
['貓吢']='貓吢詠恆:BAAALgAECgYJCAAAAA==.',
['贪财']='贪财好色:BAACLgAFFH8JAAICAAQJ9SRPBAC7AQACAAQJ9SRPBAC7AQAuAAQKfx4AAwIACAnqJRAGAHUDAAIACAnqJRAGAHUDABkAAQkAALcTAFYAAAAA.',
['起名']='起名真费劲:BAAALgAECgEJAQAAAA==.',
['还是']='还是壹碗泡面:BAAALgAFFAEJAQAAAA==.',
['進撃']='進撃的大米:BAAALgADCgEJAQAAAA==.',
['逺哘']='逺哘的人:BAAALgAECgMJAwAAAA==.',
['铁锤']='铁锤骑士:BAAALgAECgYJBwAAAA==.',
['错念']='错念今夕:BAAALgAFFAEJAQAAAA==.',
['闪击']='闪击丶:BAAALgADCgUJBQAAAA==.',
['阿巴']='阿巴瑟三:BAABLgAECn8VAAQaAAcJjx1fEAA1AgAaAAcJjx1fEAA1AgAMAAUJEA6/OQAMAQAbAAEJShxqOQBOAAABLgAFFAMJBgAOANsYAA==.阿巴瑟瑟:BAABLgAECn8fAAMXAAgJ7RzyFwBWAgAXAAcJsx/yFwBWAgAWAAcJcxZbMQCYAQABLgAFFAMJBgAOANsYAA==.',
['阿库']='阿库拉玛塔塔:BAAALgADCgYJBgAAAA==.',
['阿科']='阿科:BAAALgAECgkJDwAAAA==.',
['阿萨']='阿萨斯阿萨:BAAALgAECgEJAQAAAA==.',
['隐术']='隐术:BAAALgAFFAEJAgAAAA==.',
['雪姐']='雪姐:BAAALgADCgUJBgAAAA==.',
['零度']='零度火焰:BAAALgAECgYJDAAAAA==.',
['霜丶']='霜丶火:BAAALgADCgYJBgAAAA==.',
['霜之']='霜之痕:BAAALgAECgMJAwAAAA==.',
['霜冷']='霜冷长河:BAABLgAECn8aAAICAAgJARx5LgB+AgACAAgJARx5LgB+AgAAAA==.',
['霜月']='霜月无痕:BAAALgAECgYJCwAAAA==.',
['风中']='风中的白果:BAAALgAECgUJCgAAAA==.',
['风之']='风之痕迹:BAAALgAECgEJAwAAAA==.',
['风驰']='风驰:BAABLgAFFH8NAAIcAAQJRA9YAQAHAQAcAAQJRA9YAQAHAQAAAA==.',
['馒头']='馒头小骑士:BAAALgADCgEJAQAAAA==.',
['魔剑']='魔剑创造:BAABLgAECn8dAAMdAAgJSBhGFgBcAgAdAAgJSBhGFgBcAgAYAAUJkRcqdgD1AAAAAA==.',
['龍龍']='龍龍:BAAALgAECgcJEwAAAA==.',
['龙牌']='龙牌酱油:BAABLgAFFH8IAAIFAAQJUA3oBQBEAQAFAAQJUA3oBQBEAQABLgAFFAUJDQAFAOsUAA==.',
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
