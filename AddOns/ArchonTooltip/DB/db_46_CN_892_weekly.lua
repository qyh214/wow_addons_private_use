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

local lookup = {'Monk-Mistweaver','Priest-Shadow','Priest-Holy','Priest-Discipline','Hunter-Marksmanship','Mage-Frost','Paladin-Retribution','DemonHunter-Devourer','DemonHunter-Havoc','Evoker-Augmentation','Evoker-Devastation','Unknown-Unknown','Evoker-Preservation','Hunter-BeastMastery','Warrior-Protection','DeathKnight-Blood','Monk-Windwalker','Shaman-Restoration','Druid-Guardian','Monk-Brewmaster','Warlock-Demonology','Warlock-Destruction','DeathKnight-Unholy','DeathKnight-Frost','Druid-Restoration','Druid-Balance','Warrior-Fury','Warrior-Arms','Hunter-Survival','Paladin-Holy','Shaman-Elemental',}
local provider = {region='CN',realm='麦迪文',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akabalance:BAAALgAECgUJBgAAAA==.Akirabiubiu:BAAALgAECgUJBQABLgAECggJFQABAG0XAA==.',
Al='Albee:BAACLgAFFH8GAAMCAAQJkgUYDQDRAAACAAQJkgUYDQDRAAADAAEJkBDkCgBOAAAuAAQKfxkABAMACAkvGekOAHECAAMACAkvGekOAHECAAIABQnZBjBBAO8AAAQAAQmgDH4gAC8AAAAA.All:BAAALgAFFAMJAwABLgAFFAUJFAAFAFYkAA==.Altria:BAABLgAECn8UAAIGAAYJnh12cwDsAQAGAAYJnh12cwDsAQABLgAECgcJGgAFAJMYAA==.',
An='Anna:BAAALgADCgEJAQAAAA==.',
Aq='Aquariuslea:BAAALgAFFAEJAQAAAA==.',
Aw='Awaroyad:BAAALgAECgYJCQAAAA==.',
Be='Being:BAAALgADCgMJAwAAAA==.',
Bl='Blackswan:BAAALgAECgMJBQAAAA==.',
Ch='Chloe:BAACLgAFFH8JAAIGAAQJMCGMDgBDAQAGAAQJMCGMDgBDAQAuAAQKfxYAAgYACAmiIcI5AI8CAAYACAmiIcI5AI8CAAAA.',
Da='Dance:BAACLgAFFH8HAAIHAAMJ+x8KCAAvAQAHAAMJ+x8KCAAvAQAuAAQKfxkAAgcACAkgI4MNACIDAAcACAkgI4MNACIDAAAA.',
Dl='Dlovey:BAABLgAECn8XAAMIAAcJHxUwUQCyAQAIAAcJHxUwUQCyAQAJAAIJ5QeUYQBcAAAAAA==.',
Do='Donjuan:BAAALgAECgYJDwAAAA==.Dovakiin:BAACLgAFFH8PAAIKAAUJ+BLqBQCgAQAKAAUJ+BLqBQCgAQAuAAQKfxYAAwoACAkxHrYQAG0CAAoACAkxHrYQAG0CAAsABgkKFKwfADABAAAA.',
El='Elsia:BAAALgAECgkJCQAAAA==.',
En='Endofdream:BAAALgAECgMJBgAAAA==.',
Fi='Filia:BAAALgAECgEJAQAAAA==.',
Go='Gouws:BAAALgAECgcJEAAAAA==.',
He='Hermitpurple:BAAALgAECgMJAwABLgAFFAEJAQAMAAAAAA==.',
Ho='Hojlund:BAAALgAECgEJAgAAAA==.',
Kh='Khafi:BAAALgAECgEJAQABLgAFFAIJAgAMAAAAAA==.',
Ki='Killjaeden:BAAALgAFFAIJBAAAAA==.Kiri:BAAALgAFFAIJAgAAAA==.Kizato:BAAALgADCgYJBgAAAA==.Kizuto:BAAALgAECgEJAQAAAA==.',
La='Laevatain:BAAALgADCgcJBwAAAA==.',
Le='Lea:BAAALgADCgQJBAABLgAFFAEJAQAMAAAAAA==.Leach:BAAALgAECgcJCQABLgAFFAEJAQAMAAAAAA==.Lenny:BAABLgAFFH8FAAINAAUJCAO7BABEAQANAAUJCAO7BABEAQABLgAFFAUJBQAOALgTAA==.',
Lo='Lobern:BAABLgAFFH8HAAIGAAMJ/xazKQANAQAGAAMJ/xazKQANAQAAAA==.Loberno:BAAALgAECgIJAgAAAA==.',
Ma='Marsback:BAACLgAFFH8NAAIPAAQJlQ04AwAYAQAPAAQJlQ04AwAYAQAuAAQKfyIAAg8ABwm1HPISANoBAA8ABwm1HPISANoBAAAA.',
Me='Meliisaa:BAACLgAFFH8PAAMEAAQJMw5pCgA4AQAEAAQJDg5pCgA4AQADAAMJtAikBQDIAAAuAAQKfxoAAwQACAlLGukPAEACAAQACAmPGekPAEACAAMAAgmRFi1rAH4AAAAA.',
Mi='Mirelune:BAAALgAECgIJAwAAAA==.',
Mo='Moiange:BAAALgAFFAIJAgAAAA==.',
Ms='Msjj:BAAALgADCgMJAwAAAA==.',
Na='Natural:BAAALgAECgYJCQAAAA==.Nazgul:BAABLgAFFH8GAAIQAAUJtBNyAwCGAQAQAAUJtBNyAwCGAQABLgAFFAYJEQARALEOAA==.',
Ne='Neptune:BAAALgAECgMJBAAAAA==.',
Ni='Nickelback:BAAALgAECggJCAAAAA==.Nicky:BAAALgADCgQJBAAAAA==.',
No='Notorious:BAAALgADCgMJAwAAAA==.',
Nw='Nwhunt:BAAALgAECgYJBwABLgAFFAIJAgAMAAAAAA==.',
Or='Ora:BAABLgAECn8YAAMEAAcJ8xoFEgAlAgAEAAcJ8xoFEgAlAgADAAMJ2A+yYgClAAAAAA==.',
Rn='Rnb:BAAALgAECgYJCwAAAA==.',
Sa='Sandara:BAAALgAECgMJAwAAAA==.Sayumi:BAABLgAECn8aAAIOAAcJ9htLIQA+AgAOAAcJ9htLIQA+AgAAAA==.',
Sc='Scamacca:BAAALgAFFAIJAgAAAA==.',
Sh='Shiningtears:BAAALgADCgMJAgAAAA==.',
Sk='Sksoke:BAAALgAFFAIJAgAAAA==.Skydms:BAAALgAECgEJAQAAAA==.Skydsm:BAABLgAECn8aAAISAAcJCBjIKQDnAQASAAcJCBjIKQDnAQAAAA==.',
So='Souldeceiver:BAAALgAECgMJAwAAAA==.',
Su='Suguha:BAAALgAECgYJDQAAAA==.Sunofbeach:BAAALgAECgQJBQAAAA==.',
Ti='Timetogo:BAAALgAECgEJAQAAAA==.',
To='Toukakirishi:BAABLgAFFH8GAAITAAQJwAWTAwCuAAATAAQJwAWTAwCuAAABLgAFFAQJCQAUAMcPAA==.',
Wh='Whotwotwo:BAAALgADCgMJAwAAAA==.',
Wi='Wish:BAAALgAECgQJCgAAAA==.',
Wz='Wzzfyxsb:BAAALgADCgMJAwAAAA==.',
Ze='Zealotgbb:BAAALgADCgUJBQABLgAECgkJDQAMAAAAAA==.',
['一卦']='一卦一算:BAAALgAECgEJAgAAAA==.',
['一只']='一只大香蕉:BAAALgAECgUJAQABLgAECgYJBwAMAAAAAA==.',
['一蹬']='一蹬大师:BAAALgAECgEJAQAAAA==.',
['七叶']='七叶树:BAAALgAECggJCwAAAA==.',
['万一']='万一:BAAALgAFFAEJAQAAAA==.万一丶怒吼:BAAALgAECgYJBwAAAA==.万一丶花州:BAAALgAECgYJBgAAAA==.万一花天狂骨:BAAALgAECgcJCAAAAA==.',
['三文']='三文鱼榨汁:BAAALgAFFAIJAwAAAA==.',
['上帝']='上帝情人:BAAALgAECgcJCAAAAA==.上帝的钢门:BAAALgAECgMJAwAAAA==.',
['不嘻']='不嘻嘻:BAABLgAFFH8PAAIUAAUJHxhSBACVAQAUAAUJHxhSBACVAQAAAA==.',
['与我']='与我共黄昏:BAAALgAECgEJAQAAAA==.',
['与猫']='与猫共舞:BAAALgADCgEJAQAAAA==.',
['东南']='东南不在西北:BAAALgAECgUJAgAAAA==.',
['两只']='两只大香蕉:BAAALgAECgYJBwAAAA==.',
['丶小']='丶小丶姐不美:BAAALgAECgcJDAABLgAFFAUJEQAGAGQiAA==.',
['丶柳']='丶柳羡青:BAAALgADCgYJBwAAAA==.',
['丶毛']='丶毛:BAABLgAFFH8RAAMVAAUJvSMeBADeAQAVAAUJvSMeBADeAQAWAAIJhx6xCgCzAAAAAA==.丶毛丶:BAABLgAFFH8LAAIIAAUJQSQEAwASAgAIAAUJQSQEAwASAgAAAA==.',
['丷猎']='丷猎丷:BAAALgADCgYJBgAAAA==.',
['么麼']='么麼熊:BAAALgAECgYJEAAAAA==.',
['义父']='义父:BAAALgAECgQJBwAAAA==.',
['乌巴']='乌巴斯提:BAAALgAECgQJBQAAAA==.',
['乌涅']='乌涅特:BAAALgADCgMJAwAAAA==.',
['乌鸦']='乌鸦哥:BAAALgAECgkJCQAAAA==.',
['云影']='云影逡巡:BAAALgAECgYJBwABLgAFFAIJBAAMAAAAAA==.',
['亚拉']='亚拉冈:BAAALgAFFAEJAQABLgAFFAYJEQARALEOAA==.',
['人造']='人造人索加:BAAALgAECgQJCAAAAA==.',
['仓小']='仓小趴睡着了:BAABLgAFFH8JAAMFAAYJ2R2jCACQAQAFAAQJch2jCACQAQAOAAIJch73DgDTAAAAAA==.',
['他化']='他化自在天:BAAALgAECgIJAwAAAA==.',
['仙妮']='仙妮丶墨羽:BAAALgADCgkJCQAAAA==.',
['企鹅']='企鹅男孩:BAAALgAECgcJCgAAAA==.',
['伊丝']='伊丝塔:BAABLgAECn8aAAIXAAcJlxQAaQC7AQAXAAcJlxQAaQC7AQAAAA==.',
['伊利']='伊利丶丹怒风:BAAALgAECgYJCAAAAA==.',
['优娜']='优娜丶墨羽:BAAALgADCgMJAwAAAA==.',
['会爬']='会爬树的鼻毛:BAAALgAECgEJAQAAAA==.',
['佐迪']='佐迪垭克:BAAALgAECgEJAwAAAA==.',
['余养']='余养性:BAAALgAFFAEJAQAAAA==.',
['你講']='你講先:BAAALgAECgEJAQAAAA==.',
['依然']='依然卖檬:BAAALgAECgYJCQAAAA==.依然猴得起:BAAALgAECgcJCwAAAA==.',
['依纹']='依纹:BAAALgAECgcJDAAAAA==.',
['保时']='保时捷灸爻爻:BAACLgAFFH8OAAIYAAQJlhKAAABbAQAYAAQJlhKAAABbAQAuAAQKfy0AAhgACQnKHa8AADsDABgACQnKHa8AADsDAAAA.',
['修罗']='修罗娜:BAAALgAECgMJAwAAAA==.修罗娜娜:BAAALgAECgEJAQAAAA==.',
['俺只']='俺只吃蔬菜:BAABLgAECn8aAAMZAAcJ/iBVAwCOAgAZAAcJ/iBVAwCOAgAaAAEJaAHXkQASAAAAAA==.',
['假丿']='假丿面:BAAALgAECgUJBQAAAA==.',
['儒雅']='儒雅:BAAALgAECgUJBQAAAA==.',
['光之']='光之祝福:BAAALgADCgMJBgAAAA==.光之追追:BAAALgAECgYJEAAAAA==.',
['兼愛']='兼愛:BAAALgAECgUJBgAAAA==.',
['兽兽']='兽兽的胖花花:BAAALgAECgYJBgAAAA==.',
['冫古']='冫古河渚:BAAALgAECgYJBgAAAA==.',
['冬馬']='冬馬和紗:BAAALgADCgUJBgAAAA==.',
['冰冰']='冰冰雪霜儿:BAACLgAFFH8MAAIGAAQJkRC1DgBCAQAGAAQJkRC1DgBCAQAuAAQKfxkAAgYABwnMIfU5AI4CAAYABwnMIfU5AI4CAAAA.',
['冰风']='冰风宝:BAAALgADCgUJBQAAAA==.',
['冷清']='冷清秋:BAAALgAECgYJBgAAAA==.',
['冷玉']='冷玉笙寒:BAAALgADCgYJBgABLgAFFAIJBAAMAAAAAA==.',
['减辉']='减辉龙:BAAALgAFFAIJAgAAAA==.',
['刀刀']='刀刀烈火:BAAALgAECgEJAQAAAA==.',
['刀尖']='刀尖镇魂曲:BAAALgAECgcJDgAAAA==.',
['加藤']='加藤小厦:BAAALgAFFAEJAQAAAA==.',
['勇敢']='勇敢小亮:BAAALgAECgIJAgAAAA==.',
['勒布']='勒布朗:BAAALgAECgEJAQAAAA==.',
['北极']='北极的鱼:BAABLgAFFH8IAAIHAAcJJBgEAgCHAQAHAAcJJBgEAgCHAQAAAA==.',
['十万']='十万嬉皮:BAAALgAFFAEJAQAAAA==.',
['十二']='十二种蓝色:BAAALgAECgEJAgAAAA==.',
['半生']='半生浮:BAAALgAECgMJBAAAAA==.',
['单翅']='单翅的天使:BAAALgAECgEJAQAAAA==.',
['南辞']='南辞北遇:BAAALgAECgYJCQAAAA==.',
['卡列']='卡列乌斯:BAAALgAECgMJAwAAAA==.',
['厚颜']='厚颜无耻:BAAALgADCgIJAgAAAA==.',
['原星']='原星绝:BAABLgAFFH8FAAIOAAUJuBOXAgBtAQAOAAUJuBOXAgBtAQAAAA==.',
['叁文']='叁文鱼頭:BAABLgAECn8WAAIXAAcJeCKMKwCLAgAXAAcJeCKMKwCLAgABLgAFFAIJAwAMAAAAAA==.',
['友哈']='友哈巴赫:BAAALgAECgcJDQABLgAECgcJDgAMAAAAAA==.',
['双子']='双子座小黑龙:BAAALgAECgUJBAAAAA==.',
['双驱']='双驱动打桩机:BAAALgAFFAEJAQAAAA==.',
['古兰']='古兰桑克斯:BAAALgAECgcJAQAAAA==.',
['古德']='古德里安:BAAALgAECgYJCgAAAA==.',
['只喝']='只喝冰美式:BAAALgAECggJBgAAAA==.',
['只是']='只是偶尔迷路:BAAALgAECggJDgABLgAFFAQJCQAUAMcPAA==.',
['可爱']='可爱丫头:BAAALgAECgEJAQAAAA==.可爱鹃鹃:BAAALgAECgEJAQAAAA==.',
['吃花']='吃花椒:BAAALgADCgEJAQAAAA==.',
['吃苹']='吃苹果的虫子:BAAALgAECgMJBAAAAA==.',
['向死']='向死而生丶:BAAALgAECgUJBQAAAA==.',
['吕归']='吕归尘:BAAALgADCgEJAQAAAA==.',
['吞一']='吞一只六六:BAAALgAECgcJCgAAAA==.',
['听又']='听又不懂:BAAALgAECgEJAQAAAA==.',
['吻之']='吻之殇:BAABLgAECn8aAAIQAAcJgRkZEwDbAQAQAAcJgRkZEwDbAQABLgAECgkJFQAXAPgLAA==.',
['呜啦']='呜啦啦拉:BAAALgAFFAIJAgAAAA==.',
['呼拉']='呼拉啦:BAAALgAECgYJBgAAAA==.',
['和平']='和平之歌:BAAALgAECgQJBAAAAA==.',
['咫尺']='咫尺圣光:BAAALgAECgYJDgAAAA==.',
['咸鱼']='咸鱼一只:BAAALgADCgcJBwAAAA==.',
['哆來']='哆來咪法:BAAALgAECgIJAwAAAA==.',
['哦叉']='哦叉丙甘:BAABLgAECn8aAAMbAAcJ7x/ZGgB1AgAbAAcJbB/ZGgB1AgAcAAEJBA6JQAA3AAAAAA==.',
['哦耶']='哦耶:BAAALgAFFAEJAgAAAA==.',
['啦啦']='啦啦呼呼嗨:BAAALgAFFAQJBAAAAA==.',
['喜欢']='喜欢就冲:BAACLgAFFH8UAAQFAAUJViQ8CQCGAQAFAAQJEiM8CQCGAQAOAAMJ1SM5DwDPAAAdAAIJFBKvBQC5AAAuAAQKfyMABAUACAl0JUMFAEkDAAUACAlqJUMFAEkDAB0AAwnOISQKAC8BAA4AAQmnIY9FAGIAAAAA.',
['嗨乐']='嗨乐送:BAAALgAECgEJAQAAAA==.',
['嗨皮']='嗨皮体育生:BAAALgAECgEJAQAAAA==.',
['嘟督']='嘟督嘟督:BAAALgAECgcJCgAAAA==.',
['嘴巴']='嘴巴寂寞:BAAALgAFFAQJBAAAAA==.',
['回忆']='回忆瞬间:BAAALgAECgIJAwAAAA==.',
['土豆']='土豆泥二号:BAAALgAECgYJCwAAAA==.',
['圣光']='圣光之挽歌:BAAALgAECgUJCgAAAA==.圣光照耀众生:BAAALgADCgQJBQAAAA==.圣光记忆:BAAALgAECgYJCAAAAA==.',
['圣恩']='圣恩:BAAALgAFFAMJAwAAAA==.',
['圣托']='圣托利亚:BAAALgAECgkJCgAAAA==.',
['圣洁']='圣洁北极光:BAAALgAECgQJBwAAAA==.',
['地上']='地上一只猴:BAAALgAECgEJAQAAAA==.',
['坨子']='坨子捏的邦紧:BAAALgADCgMJAwAAAA==.',
['埼玉']='埼玉:BAAALgADCgMJAwAAAA==.',
['塔沙']='塔沙达:BAAALgADCgUJBgAAAA==.',
['塔玛']='塔玛拉丶焰鳞:BAAALgADCgYJBgAAAA==.',
['复苏']='复苏之神:BAAALgAFFAQJBAAAAA==.',
['夏弥']='夏弥安洋洋德:BAAALgAFFAEJAQAAAA==.',
['夏眠']='夏眠:BAAALgAFFAIJAwAAAA==.',
['夕象']='夕象:BAABLgAECn8XAAIHAAcJDx/3FACfAQAHAAcJDx/3FACfAQAAAA==.',
['多佛']='多佛朗明哥:BAAALgAECgEJAQAAAA==.',
['多龙']='多龙巴鲁托:BAAALgAECgcJCAAAAA==.',
['夜凯']='夜凯:BAAALgAECgYJCQAAAA==.',
['夜半']='夜半青丝:BAAALgAECgYJCQAAAA==.',
['夜月']='夜月一帘幽梦:BAAALgAECgUJBwAAAA==.',
['夜灬']='夜灬火:BAAALgAECgYJDAAAAA==.',
['大地']='大地之战:BAABLgAFFH8IAAIPAAQJ/AS7BwDiAAAPAAQJ/AS7BwDiAAAAAA==.大地之牧:BAAALgAECgcJCAAAAA==.',
['大宝']='大宝剑:BAAALgAECgcJDQAAAA==.',
['大帅']='大帅蛋:BAAALgAFFAIJBAAAAA==.大帅蛋丶:BAAALgAFFAMJBAAAAA==.',
['大师']='大师球:BAAALgAECgYJBwAAAA==.',
['大福']='大福崽:BAABLgAFFH8QAAIXAAUJ+ybxAABFAgAXAAUJ+ybxAABFAgAAAA==.',
['大翻']='大翻转:BAAALgADCgEJAQAAAA==.',
['大醉']='大醉猫:BAAALgAECgYJEAAAAA==.',
['天堂']='天堂之怒:BAABLgAFFH8FAAIHAAQJmA7jDQA8AQAHAAQJmA7jDQA8AQABLgAFFAQJBgAIAF8JAA==.',
['天天']='天天躺尸:BAAALgAECgEJAQAAAA==.',
['失格']='失格落日:BAAALgAECgYJBgAAAA==.',
['契约']='契约之瞳:BAAALgAFFAIJBAAAAA==.',
['奔本']='奔本笨:BAAALgAECgQJBAAAAA==.',
['奶别']='奶别走神:BAAALgADCgYJCwABLgAFFAIJAgAMAAAAAA==.',
['奶小']='奶小灭:BAAALgAECgYJEwAAAA==.',
['她说']='她说:BAAALgAECgQJBAAAAA==.',
['好强']='好强的名字:BAAALgAECgYJCAAAAA==.',
['如是']='如是我闻:BAAALgAFFAEJAQAAAA==.',
['如风']='如风一样自由:BAAALgADCgIJAgAAAA==.',
['妳猜']='妳猜:BAAALgAECgEJAQAAAA==.',
['妺嫇']='妺嫇小妖:BAAALgAECgkJCQAAAA==.妺嫇小贼:BAAALgAECgEJAQAAAA==.',
['娜爻']='娜爻娜:BAAALgAECgYJBgAAAA==.',
['婕妮']='婕妮娜:BAAALgAECgUJCAAAAA==.',
['媂妗']='媂妗:BAAALgADCgIJAgAAAA==.',
['嫣然']='嫣然芳容:BAAALgAECgMJAwAAAA==.',
['学好']='学好数理化:BAAALgAECgYJBgAAAA==.',
['安慕']='安慕希丹:BAAALgAECgQJBAAAAA==.',
['宫商']='宫商角徵羽:BAAALgAECgkJDQAAAA==.',
['寒酥']='寒酥:BAAALgAECgcJEgAAAA==.',
['小丶']='小丶姐丶不美:BAAALgAECgkJDwAAAA==.',
['小周']='小周周月半拉:BAAALgADCgYJBgAAAA==.',
['小火']='小火聋:BAAALgAECgcJBwAAAA==.',
['小砸']='小砸哥:BAAALgADCgcJCgAAAA==.',
['少年']='少年先锋队:BAACLgAFFH8GAAIIAAQJXwkbFgAgAQAIAAQJXwkbFgAgAQAuAAQKfxUAAwgABgm5H+pBAOwBAAgABgm5H+pBAOwBAAkABgmHFzksAGcBAAAA.',
['尛天']='尛天使的爱:BAAALgAECgcJDgAAAA==.',
['布朗']='布朗尼:BAAALgADCgUJBQAAAA==.',
['布甲']='布甲之友:BAAALgAFFAEJAQAAAA==.',
['希亚']='希亚娜娜:BAAALgADCgIJAgAAAA==.希亚昵娜:BAAALgADCgEJAQAAAA==.',
['希腊']='希腊酸奶:BAAALgAECgEJAQAAAA==.',
['带带']='带带胖奶龟:BAAALgAECgEJAQAAAA==.',
['幸运']='幸运蛋:BAAALgAECgEJAgAAAA==.',
['幻彩']='幻彩泡芙崽:BAABLgAFFH8KAAIGAAQJQSUnDAC8AQAGAAQJQSUnDAC8AQABLgAFFAUJEAAXAPsmAA==.',
['幻痛']='幻痛:BAAALgAECgYJBgAAAA==.',
['幽默']='幽默蹄发发:BAAALgADCgcJBwAAAA==.',
['庐山']='庐山霸龙升:BAAALgAECgEJAgAAAA==.',
['应是']='应是良辰:BAAALgAECgIJAgAAAA==.',
['应许']='应许之地:BAAALgADCgEJAQAAAA==.',
['开心']='开心熊猫:BAAALgAFFAIJAwAAAA==.',
['張丨']='張丨风暴茅台:BAAALgAECgQJBAAAAA==.',
['当下']='当下最萌:BAAALgADCgEJAQAAAA==.',
['影月']='影月苍狼:BAAALgAFFAEJAQAAAA==.',
['很有']='很有粪量的人:BAAALgAECgYJCwAAAA==.',
['德理']='德理不饶人:BAAALgADCgQJBAAAAA==.',
['心灵']='心灵词雅:BAAALgAECgQJAwAAAA==.',
['快刀']='快刀斩乱麻:BAAALgADCgQJBAAAAA==.',
['快客']='快客之逸:BAAALgAECgYJDQAAAA==.',
['思过']='思过崖:BAAALgAFFAMJAwAAAA==.',
['怡和']='怡和:BAAALgAECgQJCwAAAA==.',
['性别']='性别男:BAAALgADCgIJAgAAAA==.',
['恐怖']='恐怖双刀人:BAAALgAECgcJEAAAAA==.',
['恶行']='恶行易施:BAAALgADCgEJAQAAAA==.',
['悟能']='悟能花生米:BAAALgAECgcJBwAAAA==.',
['惹蜂']='惹蜂落泪:BAAALgAFFAIJAgAAAA==.',
['意念']='意念纷飞:BAAALgAECgcJCwAAAA==.',
['慈母']='慈母守中线:BAAALgAECgYJAQAAAA==.',
['慵懒']='慵懒周末:BAAALgADCgYJCQAAAA==.',
['我不']='我不是陈弈迅:BAAALgAECgQJBgAAAA==.',
['我喜']='我喜歡的類型:BAABLgAFFH8FAAIeAAIJ2wmuDACJAAAeAAIJ2wmuDACJAAAAAA==.',
['我看']='我看不到的:BAAALgAECgUJBQAAAA==.',
['戰士']='戰士阿布:BAAALgAECgMJBgAAAA==.',
['戰煌']='戰煌:BAABLgAFFH8FAAIbAAUJZgfvBQCRAQAbAAUJZgfvBQCRAQAAAA==.',
['拾穗']='拾穗:BAAALgAECgYJDAAAAA==.',
['指尖']='指尖上的风情:BAAALgAECgYJDAAAAA==.',
['挠挠']='挠挠:BAAALgAECgIJAQAAAA==.',
['提宁']='提宁:BAAALgAFFAIJBAAAAA==.',
['搁浅']='搁浅:BAAALgADCgYJCAAAAA==.',
['收你']='收你们来啦:BAAALgAECgYJBgAAAA==.',
['断刃']='断刃:BAAALgADCgcJCgAAAA==.',
['斯人']='斯人剑问桃仙:BAAALgAECgEJAQABLgAECgYJCQAMAAAAAA==.',
['无助']='无助幼小可怜:BAAALgAECgYJAQAAAA==.',
['旧刃']='旧刃:BAAALgADCgEJAQAAAA==.',
['早餐']='早餐都是肉:BAAALgADCgcJBwAAAA==.',
['时光']='时光之何仙姑:BAAALgAECgYJBgAAAA==.',
['时雨']='时雨思安:BAAALgADCgYJBgAAAA==.',
['星冰']='星冰乐去冰:BAAALgAECgYJEAABLgAECgYJEgAMAAAAAA==.',
['星耀']='星耀圣骑:BAAALgAECgUJBQAAAA==.',
['春雨']='春雨润人暧:BAAALgAECgUJCAABLgAFFAUJBQAQAKgLAA==.',
['昨夜']='昨夜星辰:BAAALgAFFAIJBAAAAA==.',
['晚安']='晚安:BAAALgAECgMJAwAAAA==.',
['晚秋']='晚秋倒沫子啦:BAAALgAFFAIJAgAAAA==.晚秋赤空:BAAALgAECgYJCgAAAA==.',
['晚风']='晚风丶清晨:BAAALgAECgEJAQAAAA==.',
['晴川']='晴川一历:BAAALgAECgQJBAAAAA==.',
['暗夜']='暗夜之歌:BAAALgAECgcJCwAAAA==.暗夜狩猎:BAAALgAECgcJEAAAAA==.',
['暗月']='暗月光:BAAALgAECgkJBQAAAA==.',
['暗黑']='暗黑拯救者:BAAALgAECgEJAgAAAA==.',
['暮夜']='暮夜暧语:BAAALgAECgYJBgAAAA==.',
['暮看']='暮看云呀:BAAALgADCgUJBQAAAA==.',
['月神']='月神之守护:BAAALgAECgYJBgAAAA==.',
['有点']='有点懒的猫:BAAALgAECgYJCQAAAA==.',
['未知']='未知小伙伴:BAABLgAECn8VAAIJAAgJoB1sCgC6AgAJAAgJoB1sCgC6AgAAAA==.',
['本间']='本间芽衣子灬:BAAALgAECgQJAwAAAA==.',
['术吊']='术吊:BAAALgAECgMJAwAAAA==.',
['朵儿']='朵儿:BAAALgAECgUJBQAAAA==.',
['朵拉']='朵拉西梅尔:BAAALgAECgYJCgAAAA==.',
['机智']='机智的阿昆达:BAABLgAECn8XAAMEAAcJhCVCBgDlAgAEAAcJeCVCBgDlAgADAAMJgiXMPQBDAQAAAA==.',
['杉多']='杉多:BAAALgAECgYJBwABLgAECgcJGgAFAJMYAA==.',
['杰克']='杰克琼斯:BAAALgADCgcJBwAAAA==.',
['林允']='林允兒:BAAALgADCgEJAQAAAA==.',
['林北']='林北:BAACLgAFFH8KAAMXAAQJuBWoIwAHAQAXAAMJuBWoIwAHAQAQAAEJAAAYHAAoAAAuAAQKfxoAAhcACAnGH0UfAMYCABcACAnGH0UfAMYCAAAA.',
['林子']='林子丶:BAACLgAFFH8OAAIfAAUJQRtLAwC5AQAfAAUJQRtLAwC5AQAuAAQKfxgAAx8ACQkvISUKAPICAB8ACAkBIiUKAPICABIAAwlaJvVNAEsBAAAA.',
['枯鹰']='枯鹰抚凋籣:BAAALgAECgEJAQAAAA==.',
['柚点']='柚点淘气:BAAALgAECgEJAQAAAA==.',
['柠月']='柠月如风:BAAALgAECgYJEAAAAA==.',
['核子']='核子輪椅:BAAALgAECgEJAQAAAA==.',
['格欧']='格欧费茵:BAAALgADCgEJAQAAAA==.',
['格洛']='格洛妮娅:BAAALgAECgEJAQAAAA==.',
['梦为']='梦为鱼:BAAALgAECgYJCAAAAA==.',
['梦醒']='梦醒醉浮生:BAAALgAFFAEJAQAAAA==.',
['棍爷']='棍爷:BAAALgADCgMJAwAAAA==.',
['椅柳']='椅柳看夕阳:BAAALgAECgYJCQAAAA==.',
['横筆']='横筆绡浥:BAAALgAECgEJAQABLgAFFAIJAgAMAAAAAA==.',
['橘子']='橘子冰激凌:BAAALgAFFAEJAQAAAA==.',
['欲指']='欲指归途:BAAALgAECgYJAQABLgAECgYJCgAMAAAAAA==.',
['正义']='正义女神菲娜:BAAALgAECgYJBwAAAA==.',
['此去']='此去经年:BAAALgAECgEJAQAAAA==.',
['死亡']='死亡绽放:BAAALgADCgYJBgAAAA==.',
['氵衮']='氵衮刀肉:BAAALgAECgMJBQAAAA==.',
['沐漓']='沐漓:BAAALgAECgcJCgAAAA==.',
['沐诗']='沐诗:BAAALgAECgUJBgAAAA==.',
['沪上']='沪上丶阿姨:BAABLgAECn8ZAAIGAAkJKh1yAgDYAgAGAAkJKh1yAgDYAgAAAA==.',
['波可']='波可波克:BAAALgAECgkJDwAAAA==.',
['泰风']='泰风:BAAALgAECgYJBgAAAA==.',
['洋葱']='洋葱圈:BAAALgAECgEJAQAAAA==.',
['洒家']='洒家醉矣:BAAALgADCgEJAQAAAA==.',
['洗炼']='洗炼生命:BAABLgAECn8bAAMIAAcJsRshOAAUAgAIAAcJsRshOAAUAgAJAAIJMhnqWgB1AAAAAA==.',
['洛兰']='洛兰丶:BAAALgAECgUJBAAAAA==.',
['洛水']='洛水:BAAALgAECgQJBAAAAA==.洛水丨江:BAAALgAECgUJBQABLgAFFAcJBAAMAAAAAA==.',
['洛洛']='洛洛偌亚卓洛:BAAALgAECgcJBwAAAA==.',
['流矢']='流矢:BAAALgADCgQJBAAAAA==.',
['浅梦']='浅梦心雨:BAAALgAFFAIJAgAAAA==.',
['浑身']='浑身肝:BAAALgAECgYJCAAAAA==.',
['浩然']='浩然剑:BAABLgAECn8UAAIXAAcJMRhuVgDuAQAXAAcJMRhuVgDuAQAAAA==.',
['浪人']='浪人女将:BAAALgAFFAEJAQAAAA==.',
['浪漫']='浪漫猎手:BAAALgAECgMJAwAAAA==.',
['海天']='海天梦之蓝:BAABLgAFFH8IAAISAAMJox+TBgAfAQASAAMJox+TBgAfAQAAAA==.',
['涅槃']='涅槃荀彧:BAAALgADCgUJBQAAAA==.',
['淡淡']='淡淡的压抑:BAAALgADCgEJAQAAAA==.',
['清风']='清风袭来:BAAALgADCgUJBQAAAA==.',
['温暖']='温暖的雪丶:BAAALgAECgIJAgAAAA==.',
['溜溜']='溜溜锤:BAAALgADCgYJBgAAAA==.',
['滴滴']='滴滴叭叭早安:BAAALgADCgcJBwAAAA==.',
['滿天']='滿天星:BAAALgAECgcJBgAAAA==.',
['潇潇']='潇潇沐雨寒:BAAALgAECgYJCgAAAA==.',
['潘金']='潘金莲的相好:BAAALgAECgMJAwAAAA==.',
['火柴']='火柴战猎:BAAALgAECgcJBwAAAA==.',
['火焰']='火焰和泪水:BAAALgADCgMJAwAAAA==.',
['火神']='火神之火柴:BAAALgAECgQJBAAAAA==.',
['灵魂']='灵魂石要不要:BAABLgAECn8ZAAIVAAcJMiNgEwDiAgAVAAcJMiNgEwDiAgABLgAFFAIJBAAMAAAAAA==.',
['烟雨']='烟雨随風:BAAALgAECgYJCAABLgAFFAQJCQAUAMcPAA==.',
['烧浪']='烧浪蹄子:BAAALgAECgUJAQAAAA==.',
['热血']='热血恋人:BAAALgAECgQJBAAAAA==.',
['無为']='無为:BAAALgAECgUJBQAAAA==.',
['無助']='無助幼小可憐:BAABLgAFFH8GAAIUAAIJuR6gFwCyAAAUAAIJuR6gFwCyAAAAAA==.',
['無憂']='無憂:BAAALgADCgcJBwAAAA==.',
['無淚']='無淚:BAAALgADCgQJBAAAAA==.',
['無相']='無相:BAABLgAECn8aAAIUAAcJOxMRLgChAQAUAAcJOxMRLgChAQAAAA==.',
['無雙']='無雙丨藍瞳:BAABLgAFFH8FAAIDAAMJ8gPTCwClAAADAAMJ8gPTCwClAAAAAA==.',
['熊丨']='熊丨喵酒仙:BAAALgADCgQJBAAAAA==.',
['燃烧']='燃烧的知识:BAAALgAFFAIJAwAAAA==.',
['爱之']='爱之直至成伤:BAAALgADCgEJAQAAAA==.',
['爱的']='爱的陶醉:BAAALgAECgcJDgAAAA==.',
['片刻']='片刻宁静:BAAALgAECgcJBwAAAA==.',
['牛爱']='牛爱花:BAAALgADCgEJAQAAAA==.',
['狂忙']='狂忙之芳:BAACLgAFFH8TAAMOAAYJ4SW1AQB9AQAFAAUJwCVWAwAXAgAOAAUJPhy1AQB9AQAuAAQKfxcAAgUACAlJJU4GADYDAAUACAlJJU4GADYDAAAA.',
['狂狂']='狂狂的骑士:BAABLgAECn8iAAMeAAcJGR+/JAD+AQAeAAYJLCK/JAD+AQAHAAQJ/RXfxgD6AAAAAA==.',
['狗头']='狗头骑士:BAAALgAECgUJCgAAAA==.',
['猎鹰']='猎鹰骑士:BAABLgAECn8eAAIaAAcJUR+pFABtAgAaAAcJUR+pFABtAgAAAA==.',
['猪猪']='猪猪侠波比:BAAALgAECgYJDAAAAA==.',
['玄幻']='玄幻冰激凌:BAACLgAFFH8QAAIGAAUJ+COYBQALAgAGAAUJ+COYBQALAgAuAAQKfxoAAgYACAk9JVMNAFsDAAYACAk9JVMNAFsDAAAA.',
['玄牛']='玄牛砮皂:BAAALgAECgkJDQAAAA==.',
['王通']='王通:BAAALgADCgQJBQAAAA==.',
['琪夜']='琪夜丶晨曦:BAAALgAECgQJBwAAAA==.',
['琳奈']='琳奈:BAAALgAECgIJAwAAAA==.',
['琳达']='琳达梅尔:BAAALgAECgEJAQAAAA==.',
['甜丶']='甜丶妞:BAAALgADCgYJBgAAAA==.',
['甜點']='甜點殺手:BAAALgADCgUJBQAAAA==.',
['由小']='由小蘭:BAAALgAECgYJEAAAAA==.',
['疯狂']='疯狂的裤衩:BAAALgAECgcJDwAAAA==.',
['白日']='白日春不渡:BAAALgAFFAEJAQAAAA==.',
['白黑']='白黑白:BAAALgAFFAEJAQAAAA==.',
['百万']='百万大圣光:BAAALgAFFAEJAQAAAA==.百万没法生:BAAALgADCgEJAQAAAA==.百万没踩圈:BAAALgAECgYJCAAAAA==.',
['百成']='百成:BAABLgAECn8cAAIGAAcJxBJjIQBxAQAGAAcJxBJjIQBxAQAAAA==.',
['盛冬']='盛冬玫瑰:BAAALgAECgQJBQAAAA==.',
['盛夏']='盛夏果实:BAAALgADCgcJBwAAAA==.盛夏落雪:BAAALgAECgUJCQABLgAECgYJCgAMAAAAAA==.',
['知道']='知道了:BAAALgADCgIJAgAAAA==.',
['石豆']='石豆能:BAAALgAECggJEgAAAA==.',
['硬盘']='硬盘里没秘密:BAAALgAECgYJCAAAAA==.',
['磐磐']='磐磐:BAAALgAECgIJAgAAAA==.',
['祁同']='祁同伟:BAAALgADCgUJBQAAAA==.',
['神之']='神之羽:BAAALgADCgMJAwAAAA==.',
['神奇']='神奇的蔻蔻:BAAALgAECgEJAQAAAA==.',
['神明']='神明灵:BAAALgAECgUJBAAAAA==.',
['神行']='神行兔兔:BAAALgADCgcJBwAAAA==.',
['禧羊']='禧羊羊:BAABLgAECn8aAAMJAAcJ3RoEFwARAgAJAAcJQBoEFwARAgAIAAUJ0AxdiwAMAQAAAA==.',
['秋月']='秋月白:BAAALgAECgQJBQAAAA==.',
['秋水']='秋水丶:BAAALgADCgUJBQAAAA==.',
['空手']='空手道克星:BAAALgAECgYJCAAAAA==.',
['笑笑']='笑笑老祖:BAAALgADCgcJBwAAAA==.',
['第九']='第九个拐角:BAAALgAECggJCgAAAA==.',
['米老']='米老水子:BAAALgAECggJCAAAAA==.',
['类目']='类目泪目:BAAALgAECgUJEQAAAA==.',
['粉汪']='粉汪汪:BAAALgAECggJCwAAAA==.',
['紫羽']='紫羽幽月:BAABLgAECn8VAAIDAAcJRSSjCADCAgADAAcJRSSjCADCAgAAAA==.',
['紫韵']='紫韵儿:BAAALgADCgQJBAAAAA==.',
['給不']='給不了的曖昧:BAAALgADCgQJBAAAAA==.',
['红怡']='红怡:BAAALgAECgYJBgAAAA==.',
['红茶']='红茶馆:BAAALgAECgYJDQAAAA==.',
['约翰']='约翰丶法雷尔:BAAALgADCgUJBQAAAA==.',
['纯情']='纯情男高:BAAALgAFFAEJAQAAAA==.',
['纳尔']='纳尔加库尔特:BAAALgAECgkJCQAAAA==.',
['给朕']='给朕含上:BAAALgAECgMJAwAAAA==.',
['绿皮']='绿皮皮:BAAALgADCgYJBgAAAA==.',
['罗伊']='罗伊丶马斯坦:BAAALgAECgYJBgAAAA==.',
['翻矛']='翻矛枪:BAAALgADCgEJAQAAAA==.',
['老皮']='老皮蛋:BAAALgAECgEJAQAAAA==.',
['股市']='股市大韭菜:BAAALgADCgcJBwAAAA==.',
['肥东']='肥东东奥力给:BAAALgAECgUJBQAAAA==.',
['肾骑']='肾骑士:BAAALgADCgQJBAAAAA==.',
['胖次']='胖次收藏家:BAAALgAECgYJEgAAAA==.',
['脚踏']='脚踏光明:BAAALgAECgMJBQAAAA==.',
['自由']='自由人:BAAALgAFFAMJAwABLgAFFAUJFAAFAFYkAA==.',
['艾丽']='艾丽雅史塔克:BAAALgAECgcJDQAAAA==.',
['艾德']='艾德莉丶寒冬:BAAALgADCgYJBgAAAA==.',
['芙兰']='芙兰卡:BAAALgAECgIJAgAAAA==.',
['芙米']='芙米拉:BAAALgAECgEJAQAAAA==.',
['芬蕾']='芬蕾莎:BAAALgAECgUJBwAAAA==.',
['苍蓝']='苍蓝星:BAAALgAECgYJBgAAAA==.',
['荡秋']='荡秋千:BAAALgADCgUJBQAAAA==.',
['莜莜']='莜莜兰芷:BAAALgAECgYJBwABLgAFFAIJAgAMAAAAAA==.',
['莫妮']='莫妮卡:BAAALgAECgYJBgAAAA==.',
['莫星']='莫星云:BAABLgAECn8bAAIGAAgJCSKnFQAnAwAGAAgJCSKnFQAnAwAAAA==.',
['莫的']='莫的感情:BAAALgADCgMJAwAAAA==.',
['莺莺']='莺莺之恋:BAAALgAECgYJCwAAAA==.',
['菈丷']='菈丷萁:BAAALgAECgYJCgAAAA==.',
['萌萌']='萌萌哒:BAAALgAECggJDgAAAA==.',
['萧萧']='萧萧天:BAAALgADCgUJBQAAAA==.',
['萨骑']='萨骑马:BAAALgAECggJCgAAAA==.',
['落楼']='落楼买烟:BAAALgAECgYJCgABLgAFFAIJAwAMAAAAAA==.',
['落落']='落落无名:BAAALgAECgcJDAAAAA==.',
['葵花']='葵花接八稚女:BAABLgAFFH8RAAMRAAYJsQ4zAwBxAQARAAYJugUzAwBxAQAUAAQJSBK7DAAfAQAAAA==.',
['蓝姑']='蓝姑:BAAALgADCgYJBgAAAA==.',
['蓝蓝']='蓝蓝羽羽:BAAALgAECgQJBAAAAA==.',
['虚迪']='虚迪凯:BAAALgADCgUJBQAAAA==.',
['虫二']='虫二丶:BAACLgAFFH8LAAIHAAQJkCQaAQCnAQAHAAQJkCQaAQCnAQAuAAQKfxkAAgcACAkMJCwGAFECAAcACAkMJCwGAFECAAAA.',
['虹枫']='虹枫晚秋:BAAALgAECgEJAgABLgAECgYJCgAMAAAAAA==.',
['虾仁']='虾仁送葬:BAAALgAFFAEJAQAAAA==.',
['虾小']='虾小猪可乖了:BAACLgAFFH8RAAMZAAUJ3RgEBACiAQAZAAUJ3RgEBACiAQAaAAIJiAEVGABkAAAuAAQKfxQAAhkACAm7H3URAKsCABkACAm7H3URAKsCAAAA.虾小猪可皮了:BAACLgAFFH8QAAIGAAUJlCQCBQAZAgAGAAUJlCQCBQAZAgAuAAQKfxoAAgYACAmlJZQPAEsDAAYACAmlJZQPAEsDAAAA.',
['虾肉']='虾肉大馄饨:BAAALgADCgIJAgABLgAECggJCwAMAAAAAA==.',
['蝴蝶']='蝴蝶初翻帘绣:BAAALgAECgQJBAAAAA==.',
['血金']='血金刚:BAAALgAECgMJAwAAAA==.',
['西行']='西行寺汐汐子:BAAALgADCgMJBAABLgADCgYJBwAMAAAAAA==.',
['訪希']='訪希深:BAAALgADCgMJAwAAAA==.',
['许勒']='许勒:BAAALgADCgQJBAAAAA==.',
['许小']='许小仙:BAAALgAECgYJEAAAAA==.',
['诗人']='诗人之怒:BAAALgADCgMJAwAAAA==.',
['豚鼠']='豚鼠抱才起来:BAABLgAFFH8KAAICAAYJXgSiBACOAQACAAYJXgSiBACOAQAAAA==.',
['贪恋']='贪恋伱的温柔:BAABLgAFFH8NAAICAAUJ6ha7AgDMAQACAAUJ6ha7AgDMAQAAAA==.',
['贪食']='贪食:BAAALgAECgEJAQAAAA==.',
['贰幺']='贰幺幺:BAAALgAECgUJBAAAAA==.',
['费纳']='费纳德:BAAALgAECgYJCQAAAA==.',
['赛猪']='赛猪肉:BAAALgAECgQJBAAAAA==.',
['赫克']='赫克托耳:BAAALgAECgcJDgAAAA==.',
['超级']='超级棋子:BAAALgAECgYJBgAAAA==.',
['超超']='超超公主丶:BAAALgAECgYJBwABLgAECgcJHAAGAMQSAA==.',
['越过']='越过商丘:BAAALgAECgQJBAAAAA==.',
['踏霜']='踏霜:BAAALgAFFAMJAwAAAA==.',
['身死']='身死心不死:BAAALgAECgQJAwAAAA==.',
['轩辕']='轩辕恒穴:BAAALgADCgEJAQAAAA==.',
['辣爻']='辣爻辣:BAAALgAECgMJAwAAAA==.',
['运小']='运小开:BAAALgAECgUJBQAAAA==.',
['这个']='这个层数奔放:BAABLgAFFH8JAAIUAAQJxw+FDAAhAQAUAAQJxw+FDAAhAQAAAA==.这个群拉奈斯:BAAALgAFFAIJAgAAAA==.',
['远古']='远古列王守卫:BAAALgAFFAEJAQABLgAFFAUJDwAKAPgSAA==.',
['逐流']='逐流:BAAALgADCgEJAQAAAA==.',
['逗逗']='逗逗龙苟萨:BAAALgAFFAEJAQAAAA==.',
['遮雨']='遮雨也遮月光:BAABLgAECn8VAAMVAAcJtB66JQB8AgAVAAcJtB66JQB8AgAWAAMJKArBSwCKAAAAAA==.',
['邓布']='邓布利多:BAABLgAFFH8FAAIGAAMJAwZtMADxAAAGAAMJAwZtMADxAAAAAA==.',
['那些']='那些年的娱乐:BAAALgADCgEJAQAAAA==.',
['邻居']='邻居王神父:BAAALgAECgEJAQAAAA==.',
['郁闷']='郁闷熊:BAAALgAECgYJCgABLgAECgYJEgAMAAAAAA==.',
['酸菜']='酸菜面面:BAAALgAECgEJAQAAAA==.',
['醒醒']='醒醒哎:BAAALgAECgcJBwAAAA==.',
['野蛮']='野蛮堂客:BAABLgAECn8mAAMEAAgJ2QkUCgBhAQAEAAgJ9gYUCgBhAQADAAYJ1grWRgAeAQAAAA==.',
['铁皮']='铁皮艺术家:BAAALgADCgQJBAAAAA==.',
['铃科']='铃科百合子:BAAALgADCgEJAQAAAA==.',
['锦歌']='锦歌丶:BAAALgAECgQJBQAAAA==.',
['长乐']='长乐安:BAACLgAFFH8QAAMOAAQJnB8cCAAbAQAFAAQJjxsEDABaAQAOAAMJ8BccCAAbAQAuAAQKf0YAAw4ACQm6JAYCAH4DAA4ACAkfJQYCAH4DAAUACAkXHXINANgCAAAA.',
['閃電']='閃電五連鞭:BAAALgAFFAIJAgAAAA==.',
['闻我']='闻我德脚丶:BAAALgAECgQJBgAAAA==.',
['阿加']='阿加莎:BAAALgAECgkJCgAAAA==.',
['阿塔']='阿塔蘭忒:BAABLgAECn8aAAIFAAcJkxieJAAAAgAFAAcJkxieJAAAAgAAAA==.',
['阿姆']='阿姆拉:BAABLgAFFH8FAAIcAAMJZhk2AgAfAQAcAAMJZhk2AgAfAQAAAA==.',
['阿尔']='阿尔法瑞斯:BAABLgAECn8VAAINAAYJBBYBHgCSAQANAAYJBBYBHgCSAQAAAA==.',
['阿德']='阿德马利克:BAAALgAECgQJBgAAAA==.',
['阿鱼']='阿鱼吐泡泡啦:BAAALgAECgYJCAABLgAFFAIJAgAMAAAAAA==.',
['陆寇']='陆寇:BAABLgAFFH8FAAIUAAMJWQRaDQC5AAAUAAMJWQRaDQC5AAABLgAFFAYJDwAFADwZAA==.',
['陌上']='陌上人如玉:BAAALgADCgUJBQAAAA==.',
['随梦']='随梦而飞:BAAALgADCgEJAQAAAA==.',
['雾霭']='雾霭庇佑:BAABLgAECn8UAAIHAAYJpxzqEgCvAQAHAAYJpxzqEgCvAQAAAA==.',
['霂颻']='霂颻:BAAALgAECgMJBgAAAA==.',
['霧靄']='霧靄塵埃:BAAALgAECgQJBQAAAA==.霧靄蒼茫:BAAALgAECgYJEQAAAA==.',
['青丷']='青丷青:BAAALgAFFAIJBAAAAA==.',
['青峰']='青峰叶鸣:BAAALgAECgEJAgAAAA==.',
['青文']='青文:BAABLgAFFH8IAAMFAAQJ/AWOEwAEAQAFAAQJXQSOEwAEAQAOAAEJhAdlJQBWAAAAAA==.',
['青青']='青青陌上桑:BAABLgAECn8gAAMDAAcJhRx5FQAxAgADAAcJhRx5FQAxAgAEAAUJAQweMwAJAQAAAA==.',
['风不']='风不快乐:BAAALgAECgUJCAABLgAFFAEJAQAMAAAAAA==.',
['风中']='风中叹息:BAAALgAFFAIJAgAAAA==.风中语风:BAAALgAECgcJBgAAAA==.',
['风吹']='风吹胸毛挺:BAAALgAECgcJCwAAAA==.',
['风月']='风月虚空:BAAALgAECgYJDwAAAA==.',
['飘雪']='飘雪映残霜:BAAALgADCgYJBgAAAA==.',
['飘零']='飘零生白发:BAAALgAECgYJDwAAAA==.',
['飞天']='飞天小娜娜:BAAALgAECgMJAwAAAA==.',
['飞鸟']='飞鸟歌颂之时:BAAALgAECgcJBgABLgAECgcJCAAMAAAAAA==.',
['香菜']='香菜冰淇淋:BAAALgAECgYJBgAAAA==.',
['马保']='马保国本人:BAABLgAFFH8MAAIUAAQJPw8QBgAwAQAUAAQJPw8QBgAwAQAAAA==.',
['高大']='高大的阴影:BAAALgAECgYJCAAAAA==.',
['高尚']='高尚骏逸:BAAALgAECgkJDQABLgAFFAYJCwAGAL0cAA==.',
['鬼胄']='鬼胄蛇影:BAAALgAECgIJAgAAAA==.',
['魅影']='魅影灬小法:BAABLgAFFH8LAAIGAAQJwSO4DwCYAQAGAAQJwSO4DwCYAQAAAA==.',
['魏武']='魏武青虹:BAABLgAFFH8GAAIVAAMJTwbDFwDdAAAVAAMJTwbDFwDdAAAAAA==.',
['鸡之']='鸡之极光:BAABLgAFFH8IAAMOAAQJCROxCgAMAQAOAAMJdBixCgAMAQAFAAEJxQLPLQA4AAAAAA==.',
['鸡蛋']='鸡蛋鸟:BAAALgAECgcJCQAAAA==.',
['鹅城']='鹅城黄四郎:BAAALgADCgIJAgAAAA==.',
['鹿拉']='鹿拉蕾:BAAALgAECgMJAwAAAA==.',
['麦廸']='麦廸文:BAAALgAECgcJBwAAAA==.',
['麼麼']='麼麼熊:BAAALgAECgYJBwAAAA==.',
['黄鱼']='黄鱼馄饨:BAAALgAECggJCwAAAA==.',
['黎明']='黎明后的欣:BAABLgAECn8TAAMZAAYJzBpKRwCFAQAZAAYJzBpKRwCFAQAaAAQJ+BVoTgDvAAAAAA==.',
['黑火']='黑火:BAAALgAECgQJBQAAAA==.',
['黑色']='黑色教长:BAAALgAFFAEJAQAAAA==.',
['龙猫']='龙猫小龙猫:BAAALgADCgIJAgAAAA==.',
['龙龙']='龙龙傲天:BAAALgAECgMJAwAAAA==.',
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
