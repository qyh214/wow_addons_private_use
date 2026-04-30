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

local lookup = {'Paladin-Holy','DeathKnight-Unholy','Rogue-Subtlety','Priest-Holy','Priest-Discipline','Priest-Shadow','Mage-Frost','Warrior-Fury','Warrior-Arms','Evoker-Preservation','Paladin-Retribution','DeathKnight-Blood','Unknown-Unknown','Evoker-Augmentation','Hunter-Marksmanship','Shaman-Elemental','Shaman-Restoration','Shaman-Enhancement','Monk-Brewmaster','DemonHunter-Havoc','Warlock-Demonology','Warrior-Protection','Druid-Balance','Druid-Restoration','DeathKnight-Frost','DemonHunter-Devourer','Mage-Arcane','Warlock-Destruction','Rogue-Assassination',}
local provider = {region='CN',realm='银松森林',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ab='Abigail:BAAALgAECgQJCAAAAA==.',
Ae='Aemeath:BAAALgADCgcJDQAAAA==.',
Al='Altlas:BAAALgADCgQJBQAAAA==.',
As='Aspirinx:BAAALgAECgQJBAAAAA==.',
At='Atimage:BAAALgAECgcJCQAAAA==.',
Au='Audioslave:BAAALgAFFAIJAgAAAA==.',
By='Byakure:BAAALgAECgEJAQAAAA==.',
Ch='Charminglove:BAAALgAECgQJBAAAAA==.',
Co='Coolbloody:BAAALgAECgYJEwAAAA==.',
Cr='Crils:BAAALgAECgIJAgAAAA==.',
Da='Darkformer:BAAALgAECgUJCgAAAA==.',
Di='Digitalfun:BAAALgADCgQJBAAAAA==.',
Ev='Evlight:BAABLgAFFH8FAAIBAAIJBiONEADSAAABAAIJBiONEADSAAAAAA==.',
Fr='Frostiron:BAAALgAECgQJBwAAAA==.Frozenearl:BAAALgAFFAEJAQAAAA==.',
Fu='Furseal:BAAALgAECgYJBwAAAA==.',
Gr='Grayson:BAAALgADCgEJAQAAAA==.',
Im='Impossible:BAAALgAECgcJDAAAAA==.',
Ix='Ixkxn:BAAALgAECgEJAQAAAA==.',
Jo='Jojolucky:BAAALgAECgMJBQAAAA==.',
Ka='Kaleb:BAAALgADCgIJAgAAAA==.',
Ke='Kekowow:BAAALgAECgEJAQAAAA==.Kelli:BAAALgAECgUJBgAAAA==.',
Kr='Krakatoa:BAAALgAFFAIJAQAAAA==.',
Ku='Kumo:BAABLgAFFH8FAAICAAUJcxnEBQCnAQACAAUJcxnEBQCnAQAAAA==.Kuromi:BAAALgADCgcJDAAAAA==.',
La='Ladan:BAAALgAECgYJBgAAAA==.',
Lo='Lool:BAAALgADCgEJAQAAAA==.',
Lx='Lxora:BAAALgAECgQJBQAAAA==.',
Ly='Lynnqaq:BAACLgAFFH8TAAIDAAUJziaIAAA+AgADAAUJziaIAAA+AgAuAAQKfyYAAgMACAl1JjICAI4DAAMACAl1JjICAI4DAAAA.',
Ma='Macleods:BAAALgAFFAMJBAAAAA==.Mainmian:BAAALgAECgEJAQAAAA==.Marshmallow:BAAALgAECgYJBwAAAA==.',
Me='Medlife:BAAALgAFFAIJAgAAAA==.Mercurial:BAAALgAECgIJAgAAAA==.',
Ms='Mshimfs:BAABLgAECn8hAAQEAAgJRiXOAQBaAwAEAAgJRiXOAQBaAwAFAAQJQx/0KABPAQAGAAIJEBygTQCeAAAAAA==.',
Ne='Nekomiaya:BAAALgAECgEJAQAAAA==.',
Ni='Nightmaredk:BAAALgAECgEJAQAAAA==.Nineng:BAAALgAECgcJDgAAAA==.',
Pl='Playmaker:BAAALgAECgQJBAAAAA==.',
Po='Ponponpon:BAABLgAECn8nAAIHAAgJqhsIDgD7AQAHAAgJqhsIDgD7AQAAAA==.',
Pr='Priestqiu:BAAALgAECgYJBgAAAA==.Proflee:BAAALgAECgMJAwAAAA==.Profrong:BAAALgAECgYJDAAAAA==.',
Qi='Qiuqui:BAAALgAECgYJEAAAAA==.',
Qs='Qshimfs:BAAALgAECgQJBwABLgAECggJIQAEAEYlAA==.',
Qz='Qzg:BAACLgAFFH8PAAIIAAQJNiB0AQB+AQAIAAQJNiB0AQB+AQAuAAQKfxsAAwgACQn3IqsCAIsDAAgACQn3IqsCAIsDAAkAAgluH8wnALEAAAAA.',
Ro='Robohop:BAAALgADCgEJAQAAAA==.Roboroll:BAAALgADCgUJBQAAAA==.Robot:BAAALgAECgYJCwAAAA==.Romulus:BAAALgADCgcJBwAAAA==.',
Ru='Rupa:BAAALgAECgYJCgAAAA==.',
Sa='Saiyajin:BAAALgAECgYJCAAAAA==.Sasaqaq:BAAALgAECgYJBgAAAA==.',
Sh='Shator:BAAALgAECgUJBQAAAA==.',
Su='Supanda:BAAALgADCgQJBAAAAA==.',
Te='Temopoo:BAAALgADCgEJAQAAAA==.',
Ti='Timothee:BAAALgAECgcJAQAAAA==.Tinger:BAAALgAECgYJBwAAAA==.',
Ut='Utwo:BAABLgAFFH8MAAIHAAYJdiJgAAAsAgAHAAYJdiJgAAAsAgAAAA==.',
Va='Valphalk:BAAALgAECggJCAAAAA==.',
Vo='Voidnt:BAAALgAECgUJBgAAAA==.',
Vu='Vulpis:BAAALgAECgYJCQAAAA==.',
Xx='Xxod:BAAALgADCgEJAQAAAA==.',
['一介']='一介武夫:BAAALgAECgIJAgAAAA==.',
['一杖']='一杖没:BAAALgAECgUJBgAAAA==.',
['一爪']='一爪没:BAAALgAECgYJCQAAAA==.',
['一白']='一白心一:BAAALgAECgIJAgAAAA==.',
['丁丁']='丁丁帕克:BAAALgAECggJEwAAAA==.',
['七鯮']='七鯮不醉:BAAALgAECgEJAQABLgAECggJFgAKAPgUAA==.',
['万恶']='万恶寅为首:BAAALgAECgMJAwAAAA==.',
['三楼']='三楼楼長:BAAALgAECgYJAgAAAA==.',
['不乖']='不乖就吻你:BAAALgADCgEJAQAAAA==.',
['不悔']='不悔:BAAALgAECgQJBQAAAA==.',
['不掉']='不掉血:BAAALgADCgQJBAAAAA==.',
['世纪']='世纪丽人:BAAALgADCgUJBQAAAA==.',
['东乡']='东乡一二三:BAAALgADCgYJBgAAAA==.',
['两仪']='两仪未那:BAAALgAFFAIJBAAAAA==.',
['两块']='两块三毛八:BAAALgAECgIJAwAAAA==.',
['丨斗']='丨斗鹰丨:BAAALgAECgEJAgAAAA==.',
['丨灬']='丨灬目无王法:BAAALgADCgYJBwAAAA==.',
['丨猎']='丨猎丨:BAAALgAECgQJBQAAAA==.',
['丶汐']='丶汐:BAABLgAECn8WAAIHAAcJzhjwdQDmAQAHAAcJzhjwdQDmAQAAAA==.',
['丹翡']='丹翡:BAABLgAFFH8IAAIHAAUJ+xlbBwDrAQAHAAUJ+xlbBwDrAQAAAA==.',
['为你']='为你而殇心:BAAALgAECgYJBgAAAA==.',
['丿丶']='丿丶浅浅的爱:BAAALgAECgQJCAAAAA==.',
['丿灬']='丿灬听风者:BAAALgAECgMJAwAAAA==.丿灬猎灬丿:BAAALgAECgEJAQAAAA==.',
['乐叶']='乐叶战神:BAAALgAFFAIJAwAAAA==.',
['乔安']='乔安好:BAAALgAECgMJAwAAAA==.',
['九块']='九块七毛八:BAAALgAECgMJAwAAAA==.',
['云水']='云水:BAAALgADCgMJAwAAAA==.',
['五晨']='五晨老白干:BAAALgAFFAEJAQAAAA==.',
['令人']='令人惊叹:BAABLgAECn8UAAILAAkJARuJIQCkAgALAAkJARuJIQCkAgAAAA==.',
['伊莱']='伊莱克斯之刃:BAABLgAFFH8GAAMMAAIJYRvEDACmAAAMAAIJYRvEDACmAAACAAIJdxFZPwChAAAAAA==.',
['估计']='估计难打:BAACLgAFFH8IAAIHAAMJ+QSFGwDiAAAHAAMJ+QSFGwDiAAAuAAQKfxYAAgcABwlDEiYtADwBAAcABwlDEiYtADwBAAAA.',
['佛勒']='佛勒咪:BAAALgAECgUJBwAAAA==.',
['修仙']='修仙代替思考:BAAALgADCgMJAwAAAA==.',
['倍亲']='倍亲平衡车:BAAALgAECgIJAgAAAA==.',
['做个']='做个梦给你:BAAALgADCgEJAQAAAA==.',
['偶尔']='偶尔躲躲乌云:BAAALgAECgEJAwAAAA==.',
['充满']='充满愉快的笑:BAAALgAECgMJAgAAAA==.',
['先生']='先生找不着北:BAAALgADCgIJAgAAAA==.先生望北:BAAALgAFFAEJAQAAAA==.',
['光铸']='光铸宋慧乔:BAAALgAFFAEJAQAAAA==.',
['克己']='克己攻心:BAAALgADCgcJCgAAAA==.',
['八块']='八块九毛七:BAAALgAECgQJBQAAAA==.',
['六一']='六一幸福:BAAALgAECgcJCwAAAA==.',
['兵者']='兵者诡道:BAAALgAECgEJAQAAAA==.',
['兹有']='兹有奔放:BAAALgADCgIJAgAAAA==.',
['冰糖']='冰糖芒果:BAAALgADCgcJDAAAAA==.',
['冰雪']='冰雪嘉人:BAAALgAECgIJAwAAAA==.',
['凡恩']='凡恩:BAAALgAECgMJAgAAAA==.',
['凯爹']='凯爹就是我:BAABLgAFFH8PAAMCAAYJEB1qGQBAAQACAAQJmx5qGQBAAQAMAAIJ5BayFABMAAAAAA==.',
['列兵']='列兵大案要案:BAAALgADCgYJBwAAAA==.',
['剑断']='剑断人断:BAAALgAECgEJAQAAAA==.',
['加尔']='加尔赛力克:BAAALgAECgQJBAAAAA==.',
['勇敢']='勇敢煜煜:BAAALgAECggJDAAAAA==.勇敢熊猫:BAAALgAECgYJCAAAAA==.',
['北野']='北野未奈:BAAALgAECgEJAQAAAA==.',
['十一']='十一点以前睡:BAAALgAECgQJBAAAAA==.',
['十万']='十万大山土著:BAAALgAECgQJBAAAAA==.',
['十二']='十二乐章:BAAALgAECgEJAgAAAA==.',
['十块']='十块二毛七:BAAALgAECgEJAQAAAA==.',
['半妖']='半妖倾城丶:BAAALgAECgEJAQAAAA==.',
['华丽']='华丽的救赎丶:BAAALgAECgMJAwAAAA==.',
['南方']='南方:BAABLgAECn8WAAIKAAgJ+BTGEwAIAgAKAAgJ+BTGEwAIAgAAAA==.',
['卡德']='卡德减:BAABLgAECn8ZAAMFAAgJNBxKCwCDAgAFAAgJFBxKCwCDAgAEAAQJuhFGVADlAAAAAA==.',
['卡祖']='卡祖尔:BAAALgAECgMJAwABLgAECgUJCQANAAAAAA==.',
['卡路']='卡路迪亚:BAAALgAECgUJDwAAAA==.',
['厄洛']='厄洛斯:BAABLgAFFH8HAAIOAAMJWRn/DwACAQAOAAMJWRn/DwACAQAAAA==.',
['历战']='历战王摇曳鳗:BAAALgAECgYJCwAAAA==.',
['又菜']='又菜又爱摸:BAACLgAFFH8GAAMEAAMJZRPABwDvAAAEAAMJZRPABwDvAAAGAAEJeQ5GEwBZAAAuAAQKfyAAAwYACAnLHjcJAPACAAYACAnLHjcJAPACAAQABAlyGURFACQBAAAA.',
['双黄']='双黄蛋蒸宍:BAAALgAECgYJEQAAAA==.',
['反派']='反派小猫咪:BAAALgADCgUJBwAAAA==.',
['古手']='古手川奈奈华:BAAALgAECgQJBwAAAA==.',
['吹水']='吹水二号:BAAALgADCgMJAgAAAA==.',
['呆毛']='呆毛王:BAAALgAECgYJCQABLgAECgcJDwANAAAAAA==.',
['呐丶']='呐丶大角德:BAAALgAFFAEJAQAAAA==.呐丶小惊雷:BAAALgAFFAIJBAAAAA==.呐丶胖嘟嘟:BAAALgAFFAIJAgAAAA==.',
['呲奥']='呲奥:BAAALgAECgYJBgAAAA==.',
['咖喱']='咖喱烧鹅濑:BAAALgADCgcJBwABLgAFFAQJCwAPAFoRAA==.',
['哀悼']='哀悼荣耀:BAAALgAECgQJCAAAAA==.',
['哀木']='哀木涕在哪:BAAALgADCgEJAQAAAA==.',
['哆啦']='哆啦白梦:BAAALgAECgEJAQAAAA==.',
['哈斯']='哈斯骑:BAABLgAECn8WAAILAAcJdRoCPQAwAgALAAcJdRoCPQAwAgAAAA==.',
['唤魔']='唤魔师一紫贝:BAAALgAECgYJBgAAAA==.',
['啤又']='啤又咕咕儿:BAAALgAECgYJDAAAAA==.啤又武僧儿:BAAALgAECgEJAQABLgAECgYJDAANAAAAAA==.啤又超凶儿:BAAALgAECgEJAQAAAA==.',
['啾啾']='啾啾丶啾:BAAALgADCgEJAQABLgADCgYJBgANAAAAAA==.',
['嘎嘎']='嘎嘎地:BAAALgAECgEJAgAAAA==.',
['噗呲']='噗呲噗呲:BAAALgAECgEJAQAAAA==.',
['噬天']='噬天蔷薇花:BAAALgAECgkJEgAAAA==.',
['土狗']='土狗丸子:BAAALgAFFAUJAQAAAA==.',
['圣光']='圣光呀:BAAALgAFFAEJAQAAAA==.圣光大冬瓜:BAAALgAECgYJDAAAAA==.圣光的女婿:BAAALgADCgUJBQAAAA==.圣光终焉:BAAALgAECgUJCQAAAA==.',
['圣夜']='圣夜:BAABLgAFFH8IAAILAAMJGRbvCgANAQALAAMJGRbvCgANAQAAAA==.',
['圣美']='圣美女:BAAALgAECgEJAQAAAA==.',
['塊扎']='塊扎得很:BAAALgADCgEJAQAAAA==.',
['夏梦']='夏梦玫珑:BAAALgAECgYJBwAAAA==.',
['大力']='大力牛牛:BAAALgAFFAEJAQAAAA==.',
['大喷']='大喷锑:BAAALgAECgUJBgAAAA==.',
['天界']='天界无月痕:BAAALgAECgQJBAAAAA==.',
['天秤']='天秤座皇虎:BAAALgAFFAIJAgAAAA==.',
['天空']='天空玲:BAAALgADCgUJBQAAAA==.',
['太子']='太子:BAAALgAECgcJDQAAAA==.',
['奔放']='奔放哥:BAAALgADCgcJBwAAAA==.',
['奥莉']='奥莉尔:BAAALgAECgQJBgAAAA==.',
['奶萨']='奶萨:BAABLgAFFH8HAAIKAAMJwQvjBwDRAAAKAAMJwQvjBwDRAAAAAA==.',
['好歌']='好歌剧:BAAALgAFFAMJAwAAAA==.',
['如此']='如此强劲:BAAALgAECgUJBwAAAA==.',
['妖孽']='妖孽横生:BAAALgAECgYJDAABLgAECgYJEwANAAAAAA==.',
['妮麗']='妮麗艾露:BAAALgAECgcJDwAAAA==.',
['娜塔']='娜塔婭:BAAALgAECgMJAwAAAA==.',
['婷婷']='婷婷丶玉立:BAABLgAFFH8FAAILAAIJPyHGGgDJAAALAAIJPyHGGgDJAAAAAA==.',
['孙半']='孙半城:BAAALgAECgUJBQAAAA==.',
['孤兮']='孤兮:BAAALgADCgEJAQABLgADCgUJBQANAAAAAA==.',
['孤山']='孤山飞将军:BAAALgADCgYJBwAAAA==.',
['安东']='安东尼丶故里:BAAALgAECgIJAgAAAA==.安东尼丶既往:BAAALgADCgEJAQAAAA==.安东尼丶盼兮:BAAALgAECgIJAgAAAA==.安东尼丶般若:BAAALgADCgMJAwAAAA==.安东尼之永恒:BAAALgAECgMJAwAAAA==.',
['安静']='安静湖面:BAAALgAECgEJAQAAAA==.',
['安魂']='安魂祈祷:BAAALgAECgYJDwAAAA==.',
['宝妈']='宝妈蜜芽:BAAALgAECgUJBQAAAA==.',
['密魔']='密魔:BAAALgADCgYJBgAAAA==.',
['富士']='富士山下:BAAALgAECgYJCwAAAA==.',
['寒烟']='寒烟柔:BAAALgAECgYJEQAAAA==.',
['寒风']='寒风破晓:BAAALgAECgEJAQAAAA==.',
['射人']='射人先射狗:BAAALgAECgIJAgAAAA==.',
['将军']='将军不二:BAAALgADCgYJBgAAAA==.',
['小丶']='小丶萨:BAABLgAECn8WAAQQAAcJwhdIOABwAQAQAAUJNxxIOABwAQARAAYJYRurFgAkAQASAAEJTgbwLQAuAAAAAA==.',
['小吼']='小吼的男朋友:BAAALgADCgEJAQAAAA==.',
['小奋']='小奋:BAAALgAECgQJBgAAAA==.',
['小小']='小小二德:BAAALgAFFAEJAQAAAA==.',
['小强']='小强单刷:BAAALgAFFAIJAgAAAA==.',
['小思']='小思语:BAAALgAECgEJAgAAAA==.',
['小朱']='小朱诺诺:BAAALgAECgIJAgAAAA==.',
['小柒']='小柒想发财:BAAALgAECgEJAQAAAA==.',
['小水']='小水萝卜:BAAALgADCgYJBgAAAA==.',
['小浪']='小浪仔发飙了:BAAALgADCgUJBQAAAA==.',
['小烈']='小烈女:BAAALgADCgQJBAAAAA==.',
['小男']='小男孩:BAAALgAFFAMJBAABLgAFFAMJBwAOAFkZAA==.',
['小红']='小红手掉线:BAABLgAFFH8IAAITAAMJRQzHFADQAAATAAMJRQzHFADQAAAAAA==.',
['小钻']='小钻疯丶:BAABLgAFFH8GAAIUAAIJjCJsAwDFAAAUAAIJjCJsAwDFAAAAAA==.',
['小闪']='小闪光:BAAALgAECgEJAQAAAA==.',
['小麒']='小麒麟:BAAALgAECggJEQAAAA==.',
['尘夜']='尘夜:BAAALgAECgMJBAAAAA==.',
['就决']='就决定是你了:BAAALgAECgUJBgAAAA==.',
['尼罗']='尼罗河花园丶:BAAALgAECgYJBgAAAA==.',
['屙祖']='屙祖:BAAALgADCgYJBgAAAA==.',
['山城']='山城理沙:BAAALgADCgIJAgABLgAECgYJCQANAAAAAA==.',
['岚小']='岚小飒:BAAALgAECgkJBwAAAA==.',
['崔斯']='崔斯叮:BAAALgAECgYJDAAAAA==.',
['巅峰']='巅峰卿少:BAAALgADCgIJAgAAAA==.',
['左小']='左小伤:BAAALgAECgYJBwAAAA==.',
['已德']='已德福人:BAAALgAECgEJAQAAAA==.',
['布洛']='布洛特亨德儿:BAAALgAECgUJBQAAAA==.布洛芬缓释:BAAALgAECgkJEgAAAA==.',
['布莱']='布莱上班铜须:BAAALgAECgEJAQABLgAFFAMJCwAKAEclAA==.',
['希夕']='希夕尔:BAAALgAECgMJAwABLgAECggJAQANAAAAAA==.',
['希瑞']='希瑞儿:BAAALgAECgYJBwAAAA==.',
['希纳']='希纳维亚:BAAALgADCggJCAAAAA==.',
['常务']='常务副队长:BAAALgAECgQJBwAAAA==.',
['干涉']='干涉治疗:BAAALgAFFAEJAQAAAA==.',
['平头']='平头哥:BAAALgAECgYJBgAAAA==.',
['康娜']='康娜:BAAALgAFFAIJAgAAAA==.',
['弃暗']='弃暗投明:BAAALgAECgEJAQAAAA==.',
['式雪']='式雪:BAAALgAECgEJAQAAAA==.',
['弑神']='弑神的玛奇朵:BAAALgAECgEJAgAAAA==.',
['张大']='张大饼:BAAALgAECgcJAQABLgAFFAcJCgAHAO4cAA==.',
['张小']='张小邪:BAABLgAFFH8FAAIHAAUJNAliDwA7AQAHAAUJNAliDwA7AQAAAA==.',
['张梟']='张梟邪:BAAALgAECgEJAQAAAA==.',
['弥赛']='弥赛雅:BAAALgADCgcJBwAAAA==.',
['归烸']='归烸:BAAALgAFFAEJAQAAAA==.',
['影心']='影心:BAABLgAFFH8GAAIVAAIJDSGwKgDGAAAVAAIJDSGwKgDGAAAAAA==.',
['很小']='很小的果子:BAAALgAFFAQJBAAAAA==.',
['得享']='得享安息:BAAALgADCgYJBgAAAA==.',
['得人']='得人畏:BAAALgAECgcJDwAAAA==.',
['御坂']='御坂的硬币:BAAALgAECgcJDwAAAA==.',
['微微']='微微玖:BAAALgAECgUJBQAAAA==.',
['微笑']='微笑骑士:BAAALgAECggJEwAAAA==.',
['徳莉']='徳莉莎:BAAALgAECgUJBwAAAA==.',
['忧郁']='忧郁菇:BAABLgAFFH8GAAIGAAMJpx/3DADWAAAGAAMJpx/3DADWAAAAAA==.',
['恶堕']='恶堕卡伦西芽:BAAALgAECgQJBAAAAA==.',
['恶狼']='恶狼传说:BAAALgADCgEJAQAAAA==.',
['恶魔']='恶魔小绵羊:BAAALgAECgEJAQAAAA==.恶魔风情会所:BAAALgAFFAEJAgAAAA==.',
['想笑']='想笑:BAAALgAECgYJDAAAAA==.',
['我不']='我不是战吊:BAACLgAFFH8FAAIWAAMJGgpnDACEAAAWAAMJGgpnDACEAAAuAAQKfyYAAhYACAkbFkkPABQCABYACAkbFkkPABQCAAAA.',
['我很']='我很神秘:BAAALgAECgEJAQAAAA==.',
['我心']='我心飞翔同行:BAAALgAECgUJCAAAAA==.',
['我怎']='我怎能抵挡:BAAALgAECgIJAgAAAA==.',
['我打']='我打不死:BAAALgAECgUJBQAAAA==.',
['我是']='我是黄色奶龙:BAAALgADCgIJAgAAAA==.',
['我真']='我真的吃不饱:BAAALgADCgYJBgAAAA==.',
['我要']='我要舒服:BAAALgAFFAMJAwAAAA==.',
['我见']='我见青山:BAAALgAFFAQJBAAAAA==.',
['我还']='我还没起床:BAAALgAECgMJBQAAAA==.',
['我顶']='我顶你哟:BAAALgAECgMJAwAAAA==.',
['战曰']='战曰天:BAAALgAECgUJBAAAAA==.',
['战神']='战神卡伦西牙:BAAALgADCgYJBgAAAA==.',
['手持']='手持真理:BAAALgADCgEJAQAAAA==.',
['托尼']='托尼史塔盖:BAAALgAECgUJCAAAAA==.',
['护国']='护国公:BAAALgADCgEJAQAAAA==.',
['抵食']='抵食:BAAALgAECgUJCwAAAA==.',
['拉普']='拉普拉斯:BAAALgAFFAMJAwAAAA==.',
['拜德']='拜德:BAAALgAECgYJCgAAAA==.',
['拿命']='拿命丶賭将来:BAABLgAECn8VAAMBAAcJ1BkiIwAHAgABAAcJ1BkiIwAHAgALAAYJ6htOWwDRAQAAAA==.',
['指尖']='指尖旋律:BAAALgAECgEJAQAAAA==.',
['捕鹿']='捕鹿司:BAAALgAECgYJDwAAAA==.',
['掉线']='掉线小红手:BAAALgADCgEJAQAAAA==.',
['掌风']='掌风带毛:BAAALgAFFAIJAgABLgAECgYJCQANAAAAAA==.',
['摩托']='摩托哥:BAAALgAECgUJBwAAAA==.',
['放羊']='放羊的小娃娃:BAAALgAECgYJDQAAAA==.',
['救命']='救命我害怕:BAAALgAECgQJBAAAAA==.',
['文刂']='文刂:BAAALgAECgUJCAAAAA==.',
['断犽']='断犽:BAAALgADCgcJBwAAAA==.',
['无以']='无以为家:BAAALgADCgMJAwAAAA==.',
['无尽']='无尽毁灭之神:BAAALgAECgQJBAAAAA==.',
['明天']='明天增肌:BAAALgAECgkJEAAAAA==.',
['昕儿']='昕儿:BAAALgAECgEJAQAAAA==.昕儿吖:BAAALgADCgIJAgAAAA==.',
['星星']='星星将军:BAAALgADCgEJAQAAAA==.',
['星空']='星空的眷恋:BAAALgAECgIJAgAAAA==.',
['是蜜']='是蜜芽儿:BAAALgAECgEJAQAAAA==.',
['暗夜']='暗夜蔷薇花:BAAALgAECgUJBQAAAA==.',
['暗黑']='暗黑圣教军:BAAALgAECgQJBAAAAA==.',
['暝灭']='暝灭:BAAALgAECgQJBAAAAA==.',
['暮白']='暮白寒窗雪:BAAALgAECgMJAwAAAA==.',
['月村']='月村手毯:BAAALgAECgEJAgAAAA==.',
['月色']='月色与雪:BAAALgAECgYJBgAAAA==.',
['有妖']='有妖气四:BAAALgAECgcJAgAAAA==.',
['木子']='木子圣骑:BAACLgAFFH8HAAILAAQJ5AyHDQA+AQALAAQJ5AyHDQA+AQAuAAQKfxgAAgsABwlIG+5IAAgCAAsABwlIG+5IAAgCAAAA.',
['李敏']='李敏:BAAALgAECgQJCwAAAA==.',
['束音']='束音小花:BAAALgAECgcJCQAAAA==.',
['来困']='来困麻辣竹笋:BAAALgAFFAIJAgAAAA==.',
['来碗']='来碗把子肉:BAAALgAECgQJBAABLgAFFAIJAgANAAAAAA==.',
['枫萧']='枫萧飘奕:BAABLgAECn8XAAMXAAcJ1xy+KQCyAQAXAAcJ1xy+KQCyAQAYAAMJ4RkTjAC7AAAAAA==.',
['柒幺']='柒幺零:BAAALgADCgIJAgAAAA==.',
['梦微']='梦微思语:BAAALgAECgMJAwAAAA==.',
['棅念']='棅念:BAACLgAFFH8LAAIPAAQJWhHHDwAzAQAPAAQJWhHHDwAzAQAuAAQKfyQAAg8ACAmUHDsYAGgCAA8ACAmUHDsYAGgCAAAA.',
['楚楚']='楚楚动楼:BAAALgAECgQJBAAAAA==.',
['楠宝']='楠宝:BAAALgAECgUJCAAAAA==.',
['橡木']='橡木贤者:BAAALgAECgMJBAAAAA==.',
['欣然']='欣然回忆:BAAALgAFFAEJAQAAAA==.',
['欧皇']='欧皇大人:BAAALgAECgYJCgAAAA==.',
['正义']='正义角斗士:BAAALgAECgYJBgAAAA==.',
['殺欲']='殺欲生花丶:BAAALgAECgQJBAABLgAECgcJAQANAAAAAA==.',
['水妃']='水妃梣:BAAALgAECgIJAgAAAA==.',
['水若']='水若轻寒:BAAALgAECgkJDwABLgAFFAYJCwAHAL0cAA==.',
['永真']='永真:BAAALgAECgYJBgAAAA==.',
['江南']='江南皮皮归来:BAAALgAECgcJEAAAAA==.',
['江心']='江心薄雾起:BAAALgAECgYJBgAAAA==.',
['沈茅']='沈茅台:BAAALgADCgQJBAAAAA==.',
['沙雕']='沙雕家族:BAAALgAECgMJBQAAAA==.',
['油光']='油光瓦亮:BAAALgADCgMJBAAAAA==.',
['法比']='法比安:BAACLgAFFH8GAAIHAAIJHRpDIAC0AAAHAAIJHRpDIAC0AAAuAAQKfx8AAgcACAkUHBsqAMoCAAcACAkUHBsqAMoCAAAA.',
['波仔']='波仔:BAAALgAECgEJAQAAAA==.',
['波士']='波士顿:BAAALgAECgEJAQAAAA==.',
['流明']='流明蛋饼:BAAALgAECgQJBAAAAA==.',
['浪人']='浪人情歌:BAAALgAECgQJBAAAAA==.',
['淡烟']='淡烟疏影:BAAALgADCgYJBgAAAA==.',
['混沌']='混沌蛋刀:BAAALgADCgQJBAAAAA==.',
['渡鹤']='渡鹤寻梅:BAAALgAECgMJAwAAAA==.',
['游学']='游学者周卓:BAAALgADCgMJAwAAAA==.',
['溏丨']='溏丨心:BAAALgAECgEJAgAAAA==.',
['漫步']='漫步:BAAALgAECgEJAgAAAA==.',
['漫长']='漫长的季节:BAAALgAECgUJBAAAAA==.',
['火之']='火之偷税:BAAALgAFFAQJAgAAAA==.',
['灰羽']='灰羽眠:BAAALgAECgMJAwAAAA==.',
['炁机']='炁机:BAABLgAECn8aAAIHAAcJIhyEFgCwAQAHAAcJIhyEFgCwAQAAAA==.',
['烟孤']='烟孤橙:BAAALgAECgEJAQAAAA==.',
['焚焰']='焚焰血灵:BAAALgAECgcJCQAAAA==.',
['熊滴']='熊滴帕瓦:BAAALgAECgcJCAAAAA==.',
['熊者']='熊者猫也:BAAALgADCgQJBAAAAA==.',
['爆击']='爆击图腾:BAAALgAECgMJAwAAAA==.',
['爱穿']='爱穿皮裤:BAAALgAECgIJAgAAAA==.',
['爱魔']='爱魔蓝:BAAALgAECgYJBgAAAA==.',
['牛牛']='牛牛冲锋:BAAALgADCgQJBAAAAA==.牛牛威武:BAAALgADCgYJDAAAAA==.',
['牢骑']='牢骑刘培强:BAAALgAECgUJBQAAAA==.',
['牧云']='牧云法:BAAALgADCgEJAQAAAA==.',
['狂暴']='狂暴白羊:BAAALgADCgQJBAAAAA==.',
['狂狮']='狂狮堂岛:BAAALgAECgYJCgAAAA==.',
['狂风']='狂风僧僧:BAAALgAECgMJAwAAAA==.狂风小德:BAAALgAECgIJAQAAAA==.狂风小满:BAAALgAECgIJAgAAAA==.',
['狐狸']='狐狸马叉:BAAALgAECgEJAgAAAA==.',
['狠人']='狠人镇的人:BAAALgAECgEJAQAAAA==.',
['狮子']='狮子座雪莉:BAAALgAFFAIJAwAAAA==.',
['画楼']='画楼云雨无凭:BAAALgAFFAQJBAAAAA==.',
['痛苦']='痛苦毁灭术:BAAALgAECgYJCAAAAA==.',
['白开']='白开掺可乐:BAABLgAFFH8HAAIZAAQJwBtlAABvAQAZAAQJwBtlAABvAQAAAA==.',
['百无']='百无丶禁忌:BAAALgADCgYJBgAAAA==.',
['皇城']='皇城刹那:BAAALgAECgcJBwAAAA==.',
['盐酸']='盐酸苯海拉明:BAAALgAECgkJEwAAAA==.',
['盖壹']='盖壹螃蟹:BAAALgAECgEJAQAAAA==.',
['眨眼']='眨眼要你命:BAAALgADCgYJCAAAAA==.',
['矢岛']='矢岛舞美:BAAALgAECgYJDAAAAA==.',
['矫枉']='矫枉必过正:BAACLgAFFH8LAAMIAAQJ1A0VDABCAQAIAAQJmwsVDABCAQAWAAEJexckCQBMAAAuAAQKfxgAAggACAnDG40YAIcCAAgACAnDG40YAIcCAAAA.',
['破灭']='破灭孤途:BAAALgADCgYJBgAAAA==.',
['砸瓦']='砸瓦鲁多冲锋:BAAALgAFFAIJAgAAAA==.',
['磷酸']='磷酸奥司他韦:BAABLgAECn8mAAMGAAkJrCNZAAAlAwAGAAkJrCNZAAAlAwAFAAMJayKQLQAxAQAAAA==.',
['祝允']='祝允:BAAALgAECgQJBQAAAA==.',
['祝間']='祝間黑:BAAALgADCgcJBwAAAA==.',
['福阿']='福阿月:BAABLgAECn8aAAITAAcJTwwiFQDhAAATAAcJTwwiFQDhAAAAAA==.',
['离裳']='离裳:BAABLgAFFH8GAAIOAAQJgQJzCgD6AAAOAAQJgQJzCgD6AAAAAA==.',
['秋山']='秋山直美:BAAALgADCgcJBwABLgAECgYJCQANAAAAAA==.秋山莉奈:BAAALgAECgYJCQAAAA==.',
['秦琼']='秦琼秦叔宝:BAAALgADCgEJAQAAAA==.',
['穹语']='穹语:BAABLgAECn8WAAIHAAkJqBzkFAArAwAHAAkJqBzkFAArAwABLgAFFAIJAgANAAAAAA==.',
['窝泽']='窝泽发:BAAALgAFFAEJAQAAAA==.',
['站长']='站长推荐:BAACLgAFFH8FAAICAAMJqA3/KwDrAAACAAMJqA3/KwDrAAAuAAQKfxYAAgIABwmVHQ5HAB8CAAIABwmVHQ5HAB8CAAAA.',
['章鱼']='章鱼丸子:BAAALgADCgcJBwAAAA==.',
['筱灬']='筱灬鋼盔:BAAALgAECgYJDwAAAA==.',
['箫声']='箫声巷陌:BAAALgADCgUJBQAAAA==.',
['米开']='米开朗基翠花:BAAALgADCgEJAQAAAA==.',
['索妮']='索妮娅:BAAALgAECgQJCAAAAA==.',
['紫丨']='紫丨唄:BAABLgAECn8WAAILAAkJOR9jDQAiAwALAAkJOR9jDQAiAwAAAA==.',
['綾波']='綾波綾波綾:BAAALgAECgQJBgAAAA==.',
['终局']='终局锋刃:BAABLgAFFH8GAAMaAAQJ5RU6EQDtAAAaAAMJqRs6EQDtAAAUAAEJlwS2DgBLAAAAAA==.',
['终极']='终极猎手:BAAALgAFFAEJBAAAAA==.',
['绝地']='绝地冻肉:BAAALgAECgYJBgAAAA==.绝地潜兵:BAAALgADCgcJBwAAAA==.',
['维什']='维什戴尔:BAABLgAECn8WAAIPAAgJ+SC6AABjAgAPAAgJ+SC6AABjAgAAAA==.',
['缘尽']='缘尽缘灭:BAAALgAECgEJAQAAAA==.',
['缺水']='缺水的海豚:BAAALgADCgUJBQAAAA==.',
['羽前']='羽前京香:BAAALgADCgYJBgAAAA==.',
['翠花']='翠花:BAAALgAFFAIJBAAAAA==.',
['老寞']='老寞:BAAALgAECgEJAQAAAA==.',
['老默']='老默:BAAALgAECgIJAgAAAA==.',
['耶哥']='耶哥蕊特:BAAALgAECgYJBwAAAA==.',
['耶路']='耶路撒冷的神:BAABLgAECn8eAAQJAAYJeyCzBQBWAQAIAAYJOiDzJwAeAgAJAAYJoxizBQBWAQAWAAEJEwj/GQAvAAAAAA==.',
['自求']='自求多福:BAAALgAECgEJAgAAAA==.',
['臭臭']='臭臭蛙法狮:BAAALgAFFAEJAQAAAA==.',
['舞酌']='舞酌邸衫库:BAAALgAECgEJAQAAAA==.',
['艾席']='艾席拉:BAAALgAECgQJBAAAAA==.',
['芍玺']='芍玺猫:BAAALgAECggJEAAAAA==.',
['花了']='花了个花:BAAALgAECgQJBAAAAA==.',
['花菜']='花菜:BAAALgADCgEJAQAAAA==.',
['英雄']='英雄的掠影:BAAALgAECgQJCAAAAA==.',
['荒野']='荒野小龙人:BAAALgAECgIJAgAAAA==.',
['莉亚']='莉亚德琳丶:BAAALgAECgYJBAAAAA==.',
['菜园']='菜园小饼:BAAALgAFFAEJAQAAAA==.',
['萨瓦']='萨瓦滴卡:BAAALgADCgMJAwAAAA==.',
['落叶']='落叶乄血骑:BAAALgADCgcJBwAAAA==.',
['葱花']='葱花也是海:BAACLgAFFH8NAAMCAAQJTx3mCwB1AQACAAQJTx3mCwB1AQAZAAEJXQ2OBABZAAAuAAQKfxkABAIABwkJHQ06AE8CAAIABwkJHQ06AE8CABkAAgnTEQ4IAHcAAAwAAgn/FI86AG8AAAAA.',
['蒂嘟']='蒂嘟:BAABLgAECn8UAAMHAAYJgw+zPgD8AAAHAAYJgw+zPgD8AAAbAAEJFgvrGwA8AAAAAA==.',
['蒙古']='蒙古海军下士:BAACLgAFFH8NAAIQAAQJahu8BwBeAQAQAAQJahu8BwBeAQAuAAQKfxYAAhAABwmRISQWAGkCABAABwmRISQWAGkCAAAA.',
['蒙娜']='蒙娜丽莎:BAAALgAECgYJEwAAAA==.',
['蓝夜']='蓝夜翱天:BAACLgAFFH8GAAIVAAIJsx/oGwC4AAAVAAIJsx/oGwC4AAAuAAQKfyEAAxUACAkiH0AMANgBABUACAl/GkAMANgBABwABAn3IMMYAIUBAAAA.',
['蔷薇']='蔷薇辉石:BAAALgADCgUJBQAAAA==.',
['薛定']='薛定谔之喵:BAAALgAECgUJBQAAAA==.',
['薪王']='薪王葛温:BAAALgADCgYJBgAAAA==.',
['被崇']='被崇拜对象:BAAALgAECgEJAQAAAA==.',
['西红']='西红柿麻鸡:BAAALgAECgYJBgABLgAFFAIJAgANAAAAAA==.',
['要不']='要不要乐奈:BAAALgAECgcJCAAAAA==.',
['让叶']='让叶:BAAALgAFFAEJAQAAAA==.',
['语画']='语画:BAAALgAECgEJAQAAAA==.',
['诸星']='诸星当:BAAALgAECgQJBwAAAA==.',
['谁的']='谁的问题:BAAALgADCgQJBAAAAA==.',
['谕灵']='谕灵梅燕:BAAALgAECgYJBgAAAA==.',
['谜之']='谜之绅士:BAAALgAECgEJAQAAAA==.',
['谢耳']='谢耳朵啊:BAAALgADCgEJAQAAAA==.',
['贝利']='贝利亚:BAAALgAECgIJAgAAAA==.',
['赛菲']='赛菲尔:BAAALgAECgMJAwAAAA==.',
['赞达']='赞达拉皮卡丘:BAAALgAECgIJAgABLgAFFAEJAQANAAAAAA==.',
['赫鲁']='赫鲁兹:BAABLgAECn8nAAIWAAgJUBJnBQCIAQAWAAgJUBJnBQCIAQAAAA==.',
['超级']='超级赛亚劲:BAAALgAECgYJCwAAAA==.',
['跳姐']='跳姐超捣蛋:BAAALgAECgEJAQAAAA==.',
['轻纱']='轻纱掩面:BAAALgAFFAIJAwAAAA==.',
['逍遥']='逍遥的逍遥:BAAALgAECgcJBwABLgAFFAQJBgATAFUbAA==.',
['邪能']='邪能帆:BAAALgAECgUJBQAAAA==.',
['鄙人']='鄙人擅长奔跑:BAAALgADCgUJBQAAAA==.',
['酹灵']='酹灵:BAAALgAFFAIJAgAAAA==.',
['醉卧']='醉卧沙场:BAAALgADCgQJBQAAAA==.',
['野上']='野上爱理:BAAALgADCgEJAQABLgAECgYJCQANAAAAAA==.',
['钢铁']='钢铁沙凯:BAAALgAECgEJAQAAAA==.',
['铁血']='铁血铜人:BAABLgAECn8UAAIIAAYJRxDoWgBCAQAIAAYJRxDoWgBCAQAAAA==.',
['银月']='银月游侠:BAAALgAECgEJAQAAAA==.',
['铸光']='铸光者:BAAALgAECgEJAQAAAA==.',
['镁钕']='镁钕嘉瑶:BAAALgAECgMJAwAAAA==.',
['长夜']='长夜挽歌:BAAALgAECgEJAQAAAA==.',
['闪现']='闪现送人头:BAAALgAECgMJAwAAAA==.',
['阿木']='阿木的守望:BAAALgAECgYJCQAAAA==.',
['陈大']='陈大壮:BAAALgAECgMJAwAAAA==.',
['随性']='随性随心:BAAALgADCgIJAgAAAA==.',
['随风']='随风舞干戈:BAAALgAECgIJAgAAAA==.',
['雨下']='雨下整夜:BAAALgAECgUJCQAAAA==.',
['雪翼']='雪翼宝宝:BAAALgAECgcJDwAAAA==.',
['零下']='零下九度:BAAALgAECgUJCQAAAA==.零下二十三度:BAAALgAECgYJCwAAAA==.零下二十四度:BAAALgAECgUJBQAAAA==.',
['雷娜']='雷娜:BAAALgADCgEJAQAAAA==.',
['雷普']='雷普苟斯:BAABLgAECn8nAAMOAAgJgRdYBQDUAQAOAAgJgRdYBQDUAQAKAAYJNwxoKAAwAQAAAA==.',
['雷電']='雷電芽衣:BAAALgAECgQJBAABLgAECgUJBwANAAAAAA==.',
['青丨']='青丨栀:BAAALgAECgYJBwAAAA==.',
['青龙']='青龙之刃:BAAALgAECgUJBQAAAA==.',
['面朝']='面朝大海:BAAALgAECgYJBQAAAA==.',
['韩为']='韩为:BAAALgADCgUJCAAAAA==.',
['風暴']='風暴烈酒陳:BAAALgAECgEJAQABLgAFFAEJAQANAAAAAA==.',
['风中']='风中叮呤:BAAALgADCgMJAwAAAA==.风中玎玲:BAAALgADCgUJBQAAAA==.风中菲雪:BAAALgADCgUJBQAAAA==.',
['风的']='风的颜色:BAAALgAECgMJAwAAAA==.',
['风谷']='风谷真鱼:BAAALgADCgEJAQABLgAECgYJCQANAAAAAA==.',
['飘渺']='飘渺老德:BAAALgADCgMJAwAAAA==.',
['首先']='首先要神秘:BAAALgADCgIJAgAAAA==.',
['马老']='马老师:BAAALgAECgEJAgAAAA==.',
['魔力']='魔力牛牛:BAAALgADCgcJBwAAAA==.',
['鱼檬']='鱼檬大哥:BAAALgAECgYJDQAAAA==.',
['鹊德']='鹊德:BAAALgAECgEJAQAAAA==.',
['鹿梦']='鹿梦:BAAALgAECgIJAgAAAA==.',
['鹿鱼']='鹿鱼:BAAALgADCgUJBQABLgAECgYJCgANAAAAAA==.',
['麻辣']='麻辣手撕兔:BAAALgAECgIJAgAAAA==.',
['麻雀']='麻雀的猫:BAAALgAECgEJAQAAAA==.',
['黄色']='黄色闪光:BAACLgAFFH8MAAMdAAQJwRkUAQAaAQADAAQJkhguBwBvAQAdAAMJjhQUAQAaAQAuAAQKfykAAx0ACAnzII8BANIBAAMABwlIHr8ZADUCAB0ACAnBH48BANIBAAAA.',
['黎明']='黎明前的黑暗:BAAALgAECgEJAgAAAA==.',
['黑大']='黑大帅小黑子:BAAALgADCgEJAQAAAA==.',
['黑暗']='黑暗大魔王:BAAALgADCgEJAQAAAA==.',
['黑锋']='黑锋哈士奇:BAAALgAFFAEJAQAAAA==.',
['龙吟']='龙吟九天:BAAALgADCgEJAQAAAA==.',
['龙猫']='龙猫仔:BAAALgAECgMJAwAAAA==.',
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
