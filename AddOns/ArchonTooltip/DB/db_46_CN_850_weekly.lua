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

local lookup = {'Evoker-Augmentation','Warlock-Demonology','Priest-Discipline','Druid-Balance','Warrior-Protection','Mage-Arcane','Mage-Frost','Paladin-Retribution','Paladin-Holy','Monk-Mistweaver','DeathKnight-Unholy','Druid-Guardian','Druid-Restoration','Monk-Windwalker','Paladin-Protection','Warlock-Destruction','Priest-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Unknown-Unknown','Priest-Shadow',}
local provider = {region='CN',realm='逐日者',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aelarae:BAAALgAECgcJDgAAAA==.',
Br='Brick:BAABLgAFFH8OAAIBAAYJ3BvHAADwAQABAAYJ3BvHAADwAQABLgAFFAcJGQABAPggAA==.',
Do='Doge:BAAALgAECgEJAQAAAA==.',
Ea='Earthspirit:BAAALgAECgMJAwAAAA==.',
Ei='Einhart:BAAALgADCgIJAgAAAA==.Eiros:BAAALgADCgYJBgAAAA==.',
Ep='Ephe:BAAALgAECgMJBQAAAA==.',
Et='Eternalia:BAAALgAECgEJAQAAAA==.',
Ev='Evilneuro:BAABLgAFFH8JAAICAAMJBgrnFgDkAAACAAMJBgrnFgDkAAAAAA==.',
Je='Jeanreno:BAAALgAECgQJBAAAAA==.',
Ke='Kensiron:BAAALgAECgEJAQAAAA==.',
Lo='Loved:BAABLgAFFH8UAAIBAAYJoCQqAQB3AgABAAYJoCQqAQB3AgABLgAFFAcJGQABAPggAA==.',
Ma='Manastorm:BAAALgAECgYJCgAAAA==.Maxmage:BAAALgAECgUJBQABLgAECgYJFwADAFgjAA==.',
Mo='Molodoy:BAAALgAECgIJAgAAAA==.',
On='Onion:BAABLgAFFH8MAAIBAAYJ6h50AQBgAgABAAYJ6h50AQBgAgABLgAFFAcJGQABAPggAA==.',
Ph='Phi:BAAALgAECgYJCwAAAA==.Phil:BAACLgAFFH8PAAIEAAQJECXbAACtAQAEAAQJECXbAACtAQAuAAQKfxwAAgQACAmJJIAEAFsDAAQACAmJJIAEAFsDAAAA.Phili:BAAALgAECgIJAgAAAA==.',
So='Soga:BAAALgAECgEJAQAAAA==.',
Tr='Tranquil:BAAALgAECgQJCAAAAA==.',
Tt='Tto:BAAALgAECgYJCgAAAA==.',
Wa='Wander:BAAALgAECgYJBgAAAA==.Waxahatchee:BAAALgAECgYJBgABLgAECgYJFwADAFgjAA==.',
We='Weather:BAAALgAECgMJBgAAAA==.',
['万岁']='万岁爷:BAAALgAFFAEJAQAAAA==.',
['不要']='不要批呱卵呱:BAAALgAECgQJBAAAAA==.',
['且听']='且听龙吟:BAAALgADCgEJAQAAAA==.',
['乔碧']='乔碧萝:BAAALgAECgEJAQAAAA==.',
['乾坤']='乾坤一箭:BAAALgADCgYJAwAAAA==.',
['二手']='二手烟:BAAALgAECgYJEAAAAA==.',
['亚德']='亚德萨达格:BAAALgADCgEJAQAAAA==.',
['亚洲']='亚洲砍王灬:BAAALgAECgUJBQAAAA==.',
['会打']='会打会加:BAAALgAECgYJBgAAAA==.',
['佳熙']='佳熙:BAAALgAECgYJEQABLgAFFAgJHgAFABkZAA==.',
['倾城']='倾城一月歌:BAAALgAECgcJEQAAAA==.',
['傲蕾']='傲蕾莉亚:BAAALgAECgQJBAAAAA==.',
['傲血']='傲血:BAAALgAECgkJBwAAAA==.',
['光幽']='光幽幽:BAAALgAECgYJBgAAAA==.',
['六月']='六月的耙耳朵:BAAALgAECgYJDAAAAA==.六月的萨耳朵:BAAALgAECgEJAQAAAA==.六月的骑耳朵:BAAALgAECgYJDQAAAA==.',
['冻结']='冻结查封扣押:BAAALgAECgUJBQAAAA==.',
['劝学']='劝学医遭雷劈:BAAALgAECgIJAgAAAA==.',
['勾陈']='勾陈大帝:BAAALgAECgIJAgAAAA==.',
['匕匕']='匕匕叭叭:BAACLgAFFH8KAAMGAAMJDglzAADpAAAGAAMJDglzAADpAAAHAAIJfwV9SQCaAAAuAAQKfzIAAwcABwmaFeKBAM0BAAcABwliEuKBAM0BAAYAAgmNEpITAIsAAAAA.',
['北京']='北京二零零八:BAAALgAECgUJBQAAAA==.',
['双面']='双面亚娃:BAAALgAECgcJCQAAAA==.',
['君士']='君士坦丁:BAAALgAFFAIJAgAAAA==.',
['启明']='启明:BAABLgAFFH8FAAIIAAIJ0Q7lJQCfAAAIAAIJ0Q7lJQCfAAAAAA==.',
['呦呦']='呦呦侃:BAAALgAFFAIJAgAAAA==.',
['呼呼']='呼呼跑:BAAALgAFFAQJBAAAAA==.',
['哀伤']='哀伤灬冷眸:BAAALgAECgYJBgAAAA==.',
['哈帝']='哈帝嘶:BAAALgADCgEJAQAAAA==.哈帝嘶国王:BAAALgADCgEJAQAAAA==.哈帝嘶王:BAAALgADCgIJAgAAAA==.',
['哎无']='哎无聊哥特人:BAAALgAECgQJCwAAAA==.',
['啸天']='啸天哥:BAAALgADCgYJBgAAAA==.',
['嗤嗤']='嗤嗤刨:BAAALgAECgYJBgAAAA==.',
['嘶嘶']='嘶嘶削:BAAALgAECgkJCQAAAA==.',
['土豆']='土豆丝:BAAALgADCgYJBgAAAA==.',
['塞外']='塞外小德:BAAALgADCgMJAwAAAA==.',
['夜太']='夜太羙:BAAALgADCgIJAQAAAA==.',
['大梦']='大梦一场丶:BAAALgAFFAEJAQAAAA==.',
['大猫']='大猫小猫:BAACLgAFFH8IAAIJAAQJnBKlCQA8AQAJAAQJnBKlCQA8AQAuAAQKfxcAAgkACAn5GRooAOwBAAkACAn5GRooAOwBAAAA.',
['天谴']='天谴之鬼术:BAAALgAECgYJBgAAAA==.',
['奥塔']='奥塔维娅:BAAALgAECgMJAwAAAA==.',
['如风']='如风:BAABLgAECn8fAAIIAAgJ0B/rAwCEAgAIAAgJ0B/rAwCEAgAAAA==.',
['孤城']='孤城乱舞:BAABLgAFFH8JAAIKAAMJahnZBgD1AAAKAAMJahnZBgD1AAAAAA==.',
['密諾']='密諾斯:BAAALgAECgYJDAAAAA==.',
['小小']='小小之德:BAAALgAECgQJBQAAAA==.',
['小李']='小李飞刀:BAAALgAECgEJAQAAAA==.',
['屡射']='屡射不爽:BAAALgAECgYJBgAAAA==.',
['师太']='师太:BAAALgAECgUJBQAAAA==.',
['帕格']='帕格诺丶野火:BAAALgADCgYJBgAAAA==.',
['张益']='张益达丶:BAAALgADCgEJAQAAAA==.张益达丶丶:BAAALgADCgEJAQAAAA==.',
['徐龙']='徐龙象:BAAALgAECgMJBgAAAA==.',
['心属']='心属巧儿:BAAALgAECgcJAwAAAA==.',
['忆尘']='忆尘缘醉清风:BAAALgADCgUJBQAAAA==.',
['快乐']='快乐的小羊:BAAALgAECgYJBgAAAA==.',
['懒洋']='懒洋洋:BAAALgAECgEJAQAAAA==.',
['我们']='我们贵阳见吧:BAABLgAFFH8JAAICAAMJkBKeIAABAQACAAMJkBKeIAABAQAAAA==.',
['我要']='我要振刀了:BAABLgAFFH8KAAIIAAQJPAhvBwA4AQAIAAQJPAhvBwA4AQAAAA==.',
['打工']='打工专用:BAAALgAECgUJBQAAAA==.',
['拉格']='拉格娜罗斯:BAAALgADCgUJBQAAAA==.',
['挖挖']='挖挖撅:BAABLgAFFH8HAAILAAUJvBgPCACQAQALAAUJvBgPCACQAQAAAA==.',
['提瑞']='提瑞斯法之晟:BAAALgAECgEJAQAAAA==.提瑞斯法之枫:BAAALgAECgMJAgAAAA==.',
['撒娇']='撒娇五花肉:BAAALgAFFAIJAgAAAA==.',
['星星']='星星丷之火:BAAALgADCgQJBAAAAA==.',
['星辰']='星辰坠落:BAAALgAECgEJAQAAAA==.',
['昨夜']='昨夜:BAAALgAECgQJCAAAAA==.',
['暗影']='暗影助我:BAAALgAECgEJAQAAAA==.',
['更衣']='更衣小夜:BAAALgAECgMJAwAAAA==.',
['月光']='月光一族:BAAALgAECgQJBAAAAA==.',
['月夜']='月夜暗炉:BAAALgAECgYJBgAAAA==.',
['月隐']='月隐灬咏叹:BAACLgAFFH8JAAIMAAQJtQf/AgDOAAAMAAQJtQf/AgDOAAAuAAQKfxUAAwwACAkhDfcWAAUBAAwABwmVDPcWAAUBAA0AAQkzDjvRAC0AAAAA.',
['有事']='有事宝宝先上:BAAALgAECgEJAQAAAA==.',
['朝天']='朝天棍:BAABLgAECn8bAAMOAAYJEhWMDwAEAQAOAAYJEhWMDwAEAQAKAAQJyBTIPQDvAAAAAA==.',
['李淳']='李淳罡:BAAALgAECgIJAwAAAA==.',
['李通']='李通崖:BAAALgAECgMJBQAAAA==.',
['李阙']='李阙宛:BAAALgAECgYJBgAAAA==.',
['比尔']='比尔亚北:BAAALgAECgUJBQAAAA==.',
['水域']='水域魔方:BAAALgAECgIJAgAAAA==.',
['永远']='永远沉睡吧:BAAALgAECgYJBgAAAA==.',
['没事']='没事吃西瓜:BAABLgAFFH8HAAIHAAMJqBPjPwCuAAAHAAMJqBPjPwCuAAAAAA==.',
['法兰']='法兰西多士:BAAALgAECgYJBgAAAA==.',
['法力']='法力猫:BAAALgAECgYJCgAAAA==.',
['法号']='法号释怀:BAAALgAECgcJBwAAAA==.',
['深红']='深红之惑:BAAALgAECgYJBgAAAA==.',
['灬哎']='灬哎呦喂灬:BAAALgAECgcJCwAAAA==.',
['灬圈']='灬圈灬:BAAALgADCgYJBgAAAA==.',
['灵感']='灵感咕:BAAALgAECgEJAQAAAA==.',
['灵魂']='灵魂死者:BAAALgAECgQJBAAAAA==.',
['牧有']='牧有爱:BAAALgAECgEJAQAAAA==.',
['特里']='特里奥帕特拉:BAAALgAECgMJAwAAAA==.',
['狂怒']='狂怒的门牙:BAAALgAECgQJCgAAAA==.',
['猎虎']='猎虎八八:BAAALgADCgcJBwAAAA==.',
['猎袭']='猎袭:BAAALgAECgYJEQAAAA==.',
['猗窝']='猗窝座大人:BAAALgAFFAEJAQAAAA==.',
['玩骰']='玩骰子喝酒:BAAALgADCgEJAQAAAA==.',
['班主']='班主妊:BAAALgADCgEJAQAAAA==.',
['琴斯']='琴斯:BAAALgAECgEJAQAAAA==.',
['璐娜']='璐娜:BAAALgADCgMJAwAAAA==.',
['生如']='生如洋葱:BAABLgAFFH8JAAIBAAUJXxckBQCyAQABAAUJXxckBQCyAQABLgAFFAcJGQABAPggAA==.',
['白起']='白起:BAAALgAECgIJAgAAAA==.',
['真缺']='真缺德:BAAALgAECgEJAQAAAA==.',
['知更']='知更鸟:BAAALgAECgcJBwAAAA==.',
['社恐']='社恐小飞熊:BAAALgAECgEJAgAAAA==.',
['神代']='神代绫花:BAAALgAECgcJDAAAAA==.',
['神琦']='神琦丽美:BAAALgAECgEJAwAAAA==.',
['秃噜']='秃噜战:BAAALgAECgYJBgAAAA==.',
['秘法']='秘法之星:BAACLgAFFH8RAAIHAAUJxRFEDgCnAQAHAAUJxRFEDgCnAQAuAAQKfygAAgcACAllIvYVACUDAAcACAllIvYVACUDAAAA.',
['笑雨']='笑雨菲菲:BAAALgADCgEJAQAAAA==.',
['筱小']='筱小辉:BAABLgAECn8UAAMPAAcJ8BwPDQD3AQAPAAYJJR0PDQD3AQAIAAEJ6RuXJQFUAAAAAA==.',
['米迦']='米迦埃莉丝:BAAALgAECgQJCAAAAA==.',
['红丷']='红丷太阳:BAAALgAECgYJCAAAAA==.',
['纳兰']='纳兰嫣然:BAAALgAECgYJBgAAAA==.',
['绯弹']='绯弹的亚里亚:BAAALgAECgYJBgAAAA==.',
['罗格']='罗格多恩:BAAALgAECgYJCgAAAA==.',
['群星']='群星间的低语:BAACLgAFFH8PAAIIAAQJYhs7BQBXAQAIAAQJYhs7BQBXAQAuAAQKfxgAAggABwktIlcwAGECAAgABwktIlcwAGECAAAA.',
['聖光']='聖光指引著我:BAABLgAECn8UAAMQAAYJaxm0OQDNAAACAAQJExmGNgDZAAAQAAMJCxe0OQDNAAAAAA==.',
['艾克']='艾克僧死橙汁:BAAALgAECgYJCwAAAA==.',
['若枼']='若枼睦:BAABLgAECn8XAAMDAAYJWCOmDABuAgADAAYJWCOmDABuAgARAAEJuh6kIABaAAAAAA==.',
['萌萌']='萌萌大人:BAAALgAECgUJBwAAAA==.',
['落日']='落日之魅影:BAAALgADCgMJAwAAAA==.',
['葡萄']='葡萄夹心饼干:BAAALgAECgMJBQAAAA==.',
['藤原']='藤原蘑菇炭丶:BAAALgAECgEJAQAAAA==.',
['蝎子']='蝎子籁籁:BAAALgAECgcJAwAAAA==.',
['血月']='血月丨:BAAALgADCgYJBgAAAA==.',
['該丨']='該丨診灬惜:BAAALgADCgEJAQAAAA==.',
['谁是']='谁是谁的谁:BAAALgADCgUJBwAAAA==.',
['谁的']='谁的铁马冰河:BAAALgAECgMJBwAAAA==.',
['谁要']='谁要男妈妈:BAAALgAECgYJCwAAAA==.',
['谷德']='谷德夯特:BAABLgAFFH8JAAMSAAUJDhWaBgA4AQATAAUJDhVBBwCnAQASAAQJGweaBgA4AQAAAA==.',
['贰粒']='贰粒蛋怒疯:BAAALgAECgYJDgAAAA==.',
['迎风']='迎风布阵丶:BAAALgADCgYJBgAAAA==.',
['进击']='进击的雄鹰:BAAALgAECgUJCAAAAA==.',
['远去']='远去的云:BAAALgADCgEJAQABLgAECgEJAQAUAAAAAA==.',
['那谁']='那谁是那啥:BAAALgADCgIJAgAAAA==.',
['阿兹']='阿兹特克酋长:BAAALgAFFAIJAwAAAA==.',
['雪菲']='雪菲児:BAAALgAECgYJCwAAAA==.',
['零之']='零之露易丝:BAAALgAECgEJAQAAAA==.',
['青衫']='青衫隐:BAABLgAFFH8FAAIVAAMJihqnBAAbAQAVAAMJihqnBAAbAQAAAA==.',
['风之']='风之彩:BAAALgAECgMJAwAAAA==.',
['马三']='马三娘:BAACLgAFFH8QAAIRAAUJKiOMAAAEAgARAAUJKiOMAAAEAgAuAAQKfx0AAxEACAlIJlwBAG0DABEACAlIJlwBAG0DABUABglTGvIlAKcBAAAA.',
['高人']='高人是我:BAAALgAECgMJBAAAAA==.',
['魔法']='魔法批风:BAAALgAECgQJBAAAAA==.',
['黄色']='黄色:BAAALgAECgQJBAAAAA==.',
['黑死']='黑死牟殿下:BAAALgAFFAIJBAAAAA==.',
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
