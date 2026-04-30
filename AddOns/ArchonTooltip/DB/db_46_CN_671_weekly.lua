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

local lookup = {'Druid-Restoration','Paladin-Holy','Mage-Frost','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','Paladin-Retribution','Monk-Mistweaver','Priest-Discipline','Priest-Holy','DeathKnight-Unholy','Monk-Brewmaster','DemonHunter-Devourer','Priest-Shadow','Unknown-Unknown','Warrior-Protection','Druid-Balance','Rogue-Subtlety','DeathKnight-Frost','Evoker-Devastation',}
local provider = {region='CN',realm='希雷诺斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Ail:BAAALgAECgEJAQAAAA==.Aill:BAAALgADCgcJBwAAAA==.',
Al='Aletheia:BAAALgAECgEJAQABLgAFFAMJCQABAE0mAA==.',
Be='Beaman:BAAALgAECgEJAQAAAA==.',
Cq='Cq:BAABLgAFFH8HAAICAAMJmSFWBwDLAAACAAMJmSFWBwDLAAAAAA==.',
El='Elise:BAABLgAFFH8LAAIDAAQJSQ/mHQBTAQADAAQJSQ/mHQBTAQAAAA==.',
Ga='Gary:BAAALgAECgYJBwAAAA==.',
Ge='Gelina:BAAALgAFFAIJBAAAAA==.',
He='Hellbark:BAAALgAECgEJAQAAAA==.Heystaaccy:BAAALgAECgQJBwAAAA==.Heystaccyy:BAAALgAECgQJBAAAAA==.',
Li='Lightshow:BAAALgAECgMJBAAAAA==.',
Ma='Magician:BAACLgAFFH8IAAIDAAMJeBphJgAZAQADAAMJeBphJgAZAQAuAAQKfxQAAgMABwlSH18yAKkCAAMABwlSH18yAKkCAAAA.',
Md='Mdsd:BAAALgADCgYJCQABLgAECgcJIAAEANAbAA==.Mdsg:BAABLgAECn8gAAQEAAcJ0BvAAgCdAQAEAAcJAxnAAgCdAQAFAAIJfSFpjwC8AAAGAAMJVhG7JACjAAAAAA==.',
Mo='Morewant:BAAALgAFFAUJAwAAAA==.',
Mu='Mushroom:BAAALgAECgYJCwAAAA==.',
Po='Pomelo:BAAALgADCgQJBAAAAA==.',
Ra='Raphael:BAAALgAECgEJAQAAAA==.',
Sa='Sangeyasha:BAAALgAECgcJEgAAAA==.Saurfang:BAAALgAECgEJAQAAAA==.',
Sn='Snowelf:BAACLgAFFH8LAAIHAAMJkSO3DQA9AQAHAAMJkSO3DQA9AQAuAAQKfygAAgcACQnNJEsBANMDAAcACQnNJEsBANMDAAAA.',
So='Soulramius:BAABLgAFFH8FAAIIAAIJMBGCEACYAAAIAAIJMBGCEACYAAAAAA==.',
St='Stares:BAAALgADCgYJBgAAAA==.',
Th='Thistle:BAACLgAFFH8VAAIJAAUJlSMiAgAEAgAJAAUJlSMiAgAEAgAuAAQKfyQAAwkACQnkI7UBAHECAAoABwk8IgkNAIUCAAkACQkcIbUBAHECAAAA.',
Tr='Try:BAAALgAECgUJBwAAAA==.',
Ve='Vermithor:BAAALgAECgcJCQAAAA==.',
['一小']='一小唯一:BAAALgAFFAEJAQAAAA==.',
['一颗']='一颗栗子:BAAALgAECgkJEAAAAA==.',
['七四']='七四贰:BAAALgAECgEJAQAAAA==.',
['三减']='三减开:BAAALgAECgMJBQAAAA==.',
['三哥']='三哥大叔:BAAALgADCgUJBQAAAA==.',
['三月']='三月雪飘:BAAALgAECgEJAgAAAA==.',
['三蹦']='三蹦子:BAAALgAECgUJBgAAAA==.',
['不知']='不知德:BAAALgAFFAEJAQAAAA==.',
['与我']='与我常在:BAAALgADCgcJBwAAAA==.',
['东大']='东大眠:BAAALgADCgIJAgABLgAFFAUJBQALAFUTAA==.',
['丨林']='丨林大头丨:BAAALgADCgEJAQAAAA==.',
['丨燃']='丨燃烧语风丨:BAACLgAFFH8NAAIMAAQJLA9JDQAbAQAMAAQJLA9JDQAbAQAuAAQKfyYAAgwABwkhGuUfAAMCAAwABwkhGuUfAAMCAAAA.',
['丶暗']='丶暗淡丷旖旎:BAAALgAECgEJAQAAAA==.',
['丶流']='丶流沙:BAAALgADCgIJAgAAAA==.',
['丶牛']='丶牛结实:BAAALgAECgEJAQAAAA==.',
['丶箭']='丶箭:BAAALgAECgYJDAAAAA==.',
['丶零']='丶零点點:BAAALgAECgYJCwAAAA==.',
['丷筱']='丷筱布:BAAALgADCgYJBgAAAA==.',
['乌鲁']='乌鲁鲁:BAABLgAFFH8GAAINAAIJJSGEIQDFAAANAAIJJSGEIQDFAAAAAA==.',
['九亿']='九亿少女梦:BAAALgAECgQJBgAAAA==.',
['人生']='人生几度秋凉:BAAALgADCgEJAQAAAA==.',
['从背']='从背后拥抱你:BAABLgAECn8VAAMOAAgJuhufFQA9AgAOAAgJuhufFQA9AgAJAAYJxwvMMAAZAQAAAA==.',
['伊利']='伊利小丹丹:BAAALgAECgYJBwAAAA==.',
['伊比']='伊比路:BAAALgADCgYJCgAAAA==.',
['会长']='会长丶:BAAALgAECgIJAgAAAA==.',
['会闪']='会闪现的矮子:BAAALgADCgUJBQAAAA==.',
['佛耶']='佛耶戈:BAAALgAFFAIJAgAAAA==.',
['依宝']='依宝宝:BAAALgAECgMJAwAAAA==.',
['偷土']='偷土豆得:BAAALgAECgUJDgAAAA==.',
['全球']='全球变暖:BAAALgAECgQJBAAAAA==.',
['全能']='全能流氓:BAAALgAECgEJAQAAAA==.',
['写不']='写不完的诗歌:BAABLgAFFH8FAAILAAIJbAgQRQCZAAALAAIJbAgQRQCZAAAAAA==.',
['冬逝']='冬逝丶:BAAALgAECgYJBwAAAA==.',
['冷花']='冷花淡萼:BAAALgAECgEJAgAAAA==.',
['出发']='出发啊丷:BAAALgADCggJAQAAAA==.',
['刘一']='刘一半:BAAALgAECgEJAgAAAA==.刘一口:BAAALgADCgEJAQAAAA==.刘一头长发:BAAALgAECgEJAQAAAA==.',
['刘奶']='刘奶奶:BAAALgAECgEJAQAAAA==.',
['刘小']='刘小猪:BAAALgAECgEJAQAAAA==.',
['刘白']='刘白发:BAAALgAECgEJAQAAAA==.',
['刘胡']='刘胡须:BAAALgAECgEJAQAAAA==.',
['勃艮']='勃艮第:BAABLgAFFH8HAAILAAIJ7SB9NQCyAAALAAIJ7SB9NQCyAAAAAA==.',
['北海']='北海:BAAALgAFFAEJAQAAAA==.',
['十块']='十块帝豪:BAAALgAECgkJCQAAAA==.',
['十步']='十步一杀:BAAALgAECgkJCQAAAA==.',
['半熟']='半熟芝士:BAAALgAECgYJBgAAAA==.',
['卡布']='卡布灬奇诺:BAAALgADCgEJAQAAAA==.',
['卧梅']='卧梅有闻花:BAAALgAECgEJAQAAAA==.',
['又见']='又见格泽曜日:BAAALgAFFAQJBAAAAA==.',
['发新']='发新卡卡:BAAALgAECgIJAgABLgAECgYJEgAPAAAAAA==.',
['可鲁']='可鲁可亚:BAAALgADCgcJCQAAAA==.',
['台湾']='台湾回归:BAAALgAFFAQJBAAAAA==.',
['叶落']='叶落抚尘:BAAALgAECgUJBQAAAA==.',
['吇叽']='吇叽侳鉒:BAAALgAECgYJCAAAAA==.',
['吓獐']='吓獐灰在此:BAAALgADCgMJAgAAAA==.',
['君临']='君临异世:BAAALgAECgYJDQAAAA==.',
['听风']='听风说往事:BAAALgAFFAEJAQAAAA==.',
['呼吸']='呼吸衰竭:BAAALgAECgEJAgAAAA==.',
['咕咕']='咕咕一:BAAALgADCgcJBwAAAA==.咕咕鸡:BAAALgAECgEJAQAAAA==.',
['咕噜']='咕噜头戴假发:BAAALgAECgYJCQAAAA==.',
['咕尔']='咕尔蛋:BAAALgAFFAIJAgAAAA==.',
['啊瞒']='啊瞒:BAAALgAECgQJBAAAAA==.',
['喝啤']='喝啤酒拉肚子:BAAALgADCgYJCAAAAA==.',
['喵手']='喵手囘春:BAAALgAECgUJCAAAAA==.',
['嘿嘿']='嘿嘿哈哈大王:BAAALgAECgYJBwAAAA==.',
['四个']='四个圈丶:BAAALgAECgkJCQABLgAFFAIJBgANAOQZAA==.',
['回归']='回归基本功:BAAALgAECgUJBAAAAA==.',
['回忆']='回忆之刃:BAABLgAFFH8HAAIQAAMJ+AIYDgBmAAAQAAMJ+AIYDgBmAAAAAA==.',
['圣光']='圣光晃瞎狗眼:BAAALgAECgEJAQAAAA==.',
['士力']='士力架:BAAALgADCgEJAQAAAA==.',
['多拉']='多拉贡尼桑:BAAALgAECgUJBwAAAA==.',
['大号']='大号麻小:BAAALgADCgYJBgAAAA==.',
['天剑']='天剑:BAAALgAECgYJBgAAAA==.',
['妈妈']='妈妈咪呀:BAAALgADCgYJBgAAAA==.',
['妖精']='妖精的尾吧:BAAALgADCgIJAgAAAA==.',
['宇智']='宇智波玉凤:BAAALgAECgMJAwAAAA==.',
['安慰']='安慰之心:BAAALgAECgQJBAAAAA==.',
['宝了']='宝了个宝:BAAALgAECgEJAQAAAA==.',
['小小']='小小胡丶:BAAALgAECgUJBwAAAA==.',
['小灬']='小灬德丶:BAAALgAECgEJAgAAAA==.',
['小猫']='小猫兜:BAAALgAECgUJBgAAAA==.',
['小王']='小王要努力:BAAALgAFFAMJBAAAAA==.',
['小赫']='小赫:BAAALgAECgIJAwAAAA==.',
['小雪']='小雪碧丶:BAAALgAECggJDQAAAA==.',
['尛灬']='尛灬静:BAAALgAECgIJAgAAAA==.',
['尼古']='尼古丁真:BAAALgAECgIJAwAAAA==.',
['屁屁']='屁屁看这里:BAACLgAFFH8WAAIDAAYJpyT2AQB7AgADAAYJpyT2AQB7AgAuAAQKfyMAAgMACAlYJl4IAIQDAAMACAlYJl4IAIQDAAAA.',
['山田']='山田孝之:BAAALgAECgYJDQAAAA==.',
['岑风']='岑风暴烈久:BAAALgAECgYJBwAAAA==.',
['希尔']='希尔瓦娜斯丶:BAAALgAECgUJCAAAAA==.',
['带小']='带小号用的:BAAALgAECgQJBAAAAA==.',
['带投']='带投丨大哥:BAAALgAECgUJBAAAAA==.',
['干了']='干了啦:BAAALgAECgEJAQAAAA==.',
['幽灵']='幽灵菇传说:BAAALgAECgEJAQAAAA==.',
['弑丶']='弑丶冰:BAAALgAECgYJCgAAAA==.',
['张云']='张云龙教授:BAAALgAECgEJAQAAAA==.',
['张大']='张大腰子:BAAALgAECgMJAwAAAA==.',
['彩凤']='彩凤鸣岐灬:BAAALgAECgEJAQAAAA==.',
['影戏']='影戏:BAAALgADCgMJAwAAAA==.',
['往事']='往事橙风:BAAALgADCggJCAAAAA==.',
['心思']='心思云梦:BAABLgAFFH8IAAMCAAMJdCV6AwBNAQACAAMJdCV6AwBNAQAHAAEJAQpFNQBNAAAAAA==.',
['快乐']='快乐的小跟班:BAAALgAECgEJAQAAAA==.',
['悠悠']='悠悠吾心:BAAALgAECgEJAQAAAA==.',
['悲伤']='悲伤大鼻嘎:BAACLgAFFH8FAAIQAAMJgwazCQC0AAAQAAMJgwazCQC0AAAuAAQKfyUAAhAABwk0Fx8FAGgBABAABwk0Fx8FAGgBAAAA.',
['想抓']='想抓个小德:BAABLgAFFH8HAAIFAAMJUyFYEgC5AAAFAAMJUyFYEgC5AAAAAA==.',
['我爱']='我爱撒星星:BAAALgAFFAIJAwAAAA==.',
['我看']='我看怎么个事:BAAALgAECgYJCQAAAA==.',
['戦國']='戦國彡叁:BAAALgAECgEJAQAAAA==.',
['打火']='打火机:BAAALgAFFAEJAQAAAA==.',
['抗怪']='抗怪专用:BAAALgAECgYJCgAAAA==.',
['挥辣']='挥辣条的女孩:BAAALgAECgQJBgAAAA==.',
['掌控']='掌控丶规则:BAAALgAECgYJBgAAAA==.',
['摩挲']='摩挲楚殇:BAABLgAECn8VAAMOAAcJBBrYFwAkAgAOAAcJBBrYFwAkAgAKAAEJSQM9hQAsAAABLgAFFAYJCwABACURAA==.',
['擒兽']='擒兽:BAAALgAECgIJBAAAAA==.',
['斗私']='斗私批修:BAAALgADCgIJAgAAAA==.',
['斬丶']='斬丶赤紅之瞳:BAAALgADCgYJBwAAAA==.',
['断水']='断水流丶:BAAALgAECgYJBgAAAA==.',
['旋转']='旋转跳跃转身:BAAALgAECgQJBAAAAA==.',
['无线']='无线:BAAALgAFFAEJAgAAAA==.',
['昨日']='昨日风尘:BAAALgAECgMJAwAAAA==.',
['晚星']='晚星:BAAALgAFFAQJBAAAAA==.',
['景美']='景美任达华:BAAALgAECgEJAQAAAA==.',
['智能']='智能小德:BAAALgAECgEJAgAAAA==.',
['暗里']='暗里着迷:BAAALgAECgMJAwAAAA==.',
['暴烈']='暴烈:BAAALgAECgYJCgAAAA==.',
['月影']='月影倾城:BAAALgAFFAEJAQAAAA==.',
['木偶']='木偶王子:BAAALgAECggJEwAAAA==.',
['李亚']='李亚军:BAAALgAECgEJAQAAAA==.',
['李元']='李元梅西:BAAALgAECgcJCQAAAA==.',
['杨幂']='杨幂:BAAALgAECgEJAQAAAA==.',
['柳絮']='柳絮:BAAALgAECgQJBAAAAA==.',
['梅普']='梅普露:BAAALgAECgEJAgAAAA==.',
['梅林']='梅林迪斯:BAAALgADCgUJBQAAAA==.',
['水之']='水之湄:BAAALgAECgYJCgAAAA==.',
['永夜']='永夜黑暗:BAAALgAECgYJCQAAAA==.',
['永恒']='永恒璀璨星空:BAAALgAECgYJCwAAAA==.',
['江江']='江江:BAAALgAECgMJBgAAAA==.',
['沐雪']='沐雪听凨:BAAALgADCgYJBgAAAA==.',
['法布']='法布赞:BAAALgAFFAIJBAAAAA==.',
['流年']='流年丶若:BAAALgAECgcJCAAAAA==.',
['浅然']='浅然:BAAALgADCgUJBQAAAA==.',
['浪不']='浪不过一杯酒:BAAALgAFFAEJAQAAAA==.',
['浮厝']='浮厝:BAAALgADCgUJBQAAAA==.',
['淡淡']='淡淡小妞:BAABLgAFFH8FAAIRAAUJCAyjBQCOAQARAAUJCAyjBQCOAQAAAA==.',
['深度']='深度觉醒:BAAALgAECgEJAQAAAA==.',
['混沌']='混沌双子:BAAALgAECgMJAwAAAA==.',
['潘达']='潘达的希望:BAAALgAECgQJBgAAAA==.',
['灬刺']='灬刺丶芒灬:BAAALgAFFAIJAgAAAA==.',
['灭世']='灭世七罪:BAAALgAECgEJAQAAAA==.',
['炙殇']='炙殇:BAABLgAECn8XAAISAAgJhRmbEgCHAgASAAgJhRmbEgCHAgAAAA==.',
['烈渊']='烈渊:BAAALgAECgMJAwAAAA==.',
['無敌']='無敌锋:BAABLgAFFH8HAAMTAAIJ0yJHAQDPAAATAAIJ0B1HAQDPAAALAAIJVxhJOwCmAAAAAA==.',
['然懿']='然懿:BAAALgAECgYJBgAAAA==.',
['熊猫']='熊猫超人:BAAALgAECgQJBAAAAA==.',
['熠熠']='熠熠:BAAALgAECgMJAwAAAA==.',
['爱奔']='爱奔哥爱生活:BAAALgAFFAMJBAAAAA==.',
['牛总']='牛总裁:BAAALgAECgUJBwAAAA==.',
['牛魔']='牛魔邪神:BAAALgADCgEJAQAAAA==.',
['犸猴']='犸猴烧酒:BAAALgAECgMJAwAAAA==.',
['狂暴']='狂暴之刃:BAABLgAECn8UAAMLAAgJGBVeQwAsAgALAAgJGBVeQwAsAgATAAEJ9AFAGgAjAAAAAA==.',
['猎人']='猎人:BAAALgAECgcJBwAAAA==.',
['猫猫']='猫猫頭:BAACLgAFFH8LAAIDAAMJkhlBKQAPAQADAAMJkhlBKQAPAQAuAAQKfxsAAgMACAm1H6kuALcCAAMACAm1H6kuALcCAAAA.',
['獍形']='獍形而:BAAALgAECgYJBgAAAA==.',
['王仔']='王仔顺丰:BAAALgAECgUJBQABLgAFFAMJBgADAOAJAA==.',
['王扬']='王扬:BAAALgADCgMJAwAAAA==.',
['玛法']='玛法奥里:BAAALgAECgYJBwAAAA==.',
['痛可']='痛可太痛了:BAAALgAECgYJBgAAAA==.',
['看我']='看我眼色行世:BAAALgAECgIJAgAAAA==.',
['矮狗']='矮狗蛋儿:BAAALgAECgIJAQAAAA==.',
['硬汉']='硬汉猫猫头:BAACLgAFFH8MAAIDAAQJoRaVGABoAQADAAQJoRaVGABoAQAuAAQKfxgAAgMACAncIJ4xAKwCAAMACAncIJ4xAKwCAAAA.',
['童丨']='童丨话:BAAALgAECgYJBwAAAA==.',
['童话']='童话:BAAALgADCgEJAQAAAA==.',
['第七']='第七:BAAALgAECgYJBgAAAA==.第七王爵:BAAALgAECgQJAwAAAA==.',
['第九']='第九:BAAALgAECgQJBAAAAA==.',
['第八']='第八:BAAALgADCgcJCAAAAA==.',
['米米']='米米大魔王:BAAALgAECgEJAQAAAA==.',
['粉宝']='粉宝石:BAAALgAECgUJCAAAAA==.',
['續寫']='續寫輝煌:BAAALgAECgEJAgAAAA==.',
['美少']='美少年卡卡丶:BAAALgAECgYJEgAAAA==.',
['老杨']='老杨头:BAAALgAFFAMJAwABLgAFFAcJHAADAKwbAA==.',
['胤灬']='胤灬绝夜:BAAALgAECgEJAQAAAA==.',
['至高']='至高邪牛:BAAALgAECgEJAgAAAA==.',
['舔狗']='舔狗二号:BAAALgAECgUJCQAAAA==.',
['艾斯']='艾斯瓦纳尔:BAAALgADCgYJBgAAAA==.',
['若曲']='若曲无音:BAAALgAECgcJBwAAAA==.',
['茶度']='茶度太虎:BAAALgAECgEJAQAAAA==.',
['荒古']='荒古狂战:BAAALgAECgYJCgAAAA==.',
['莉迪']='莉迪亚:BAAALgAECgcJBwAAAA==.',
['菲儿']='菲儿丶:BAAALgAECgEJAQAAAA==.',
['萨萨']='萨萨无敌:BAAALgADCgMJAwAAAA==.',
['虹霁']='虹霁:BAAALgAFFAIJBAAAAA==.',
['血兽']='血兽来了:BAAALgADCgYJBgAAAA==.',
['血域']='血域狂狼:BAAALgAECgYJCAAAAA==.',
['西顿']='西顿丶牛猎:BAAALgAFFAIJAwAAAA==.',
['谁家']='谁家的小乖:BAAALgAFFAEJAQAAAA==.',
['豆弄']='豆弄三只皮蛋:BAAALgAFFAIJAgAAAA==.',
['豌豆']='豌豆蛐蛐:BAAALgAECgIJAwAAAA==.',
['豿剩']='豿剩:BAAALgAECgcJDgAAAA==.',
['赶羚']='赶羚羊大师:BAAALgAECgkJCwAAAA==.',
['超大']='超大只哈吉米:BAAALgAFFAQJBAAAAA==.',
['软萌']='软萌旺旺糖:BAABLgAFFH8IAAIDAAQJIxP4CABZAQADAAQJIxP4CABZAQAAAA==.',
['轻丝']='轻丝:BAAALgAECgEJAQAAAA==.',
['轻尘']='轻尘红颜泪丶:BAAALgAECgMJBAAAAA==.',
['进击']='进击的圣骑:BAABLgAFFH8IAAIHAAQJ2BhMCABvAQAHAAQJ2BhMCABvAQABLgAFFAYJBgAUAAkSAA==.',
['逐日']='逐日释然:BAAALgAECgQJBAAAAA==.',
['逝者']='逝者生存:BAAALgADCgMJAwAAAA==.',
['遗忘']='遗忘天使:BAAALgAECgYJBgAAAA==.',
['邓太']='邓太阿:BAAALgADCgEJAQAAAA==.',
['鄳玺']='鄳玺:BAABLgAFFH8GAAIIAAMJ0QjeDQDCAAAIAAMJ0QjeDQDCAAAAAA==.',
['酒仙']='酒仙来了:BAAALgADCgcJBwAAAA==.',
['醒着']='醒着做梦:BAAALgAECgQJCAAAAA==.',
['釨鏶']='釨鏶鈼鉒:BAAALgAECgQJBAAAAA==.',
['铁树']='铁树该鷥:BAABLgAFFH8GAAIDAAMJ4AnZGgCsAAADAAMJ4AnZGgCsAAAAAA==.',
['锋锋']='锋锋:BAAALgAECgQJBgABLgAFFAIJBwATANMiAA==.',
['阿丽']='阿丽:BAAALgADCgQJBAAAAA==.',
['阿兰']='阿兰:BAAALgAECgUJBQAAAA==.',
['阿尔']='阿尔福雷德:BAAALgAECgMJAQAAAA==.',
['青青']='青青西红柿:BAAALgAECgYJCQAAAA==.',
['风暴']='风暴滋生:BAAALgAECgQJBAAAAA==.',
['香草']='香草七:BAABLgAECn8cAAIHAAgJvx1uKACDAgAHAAgJvx1uKACDAgAAAA==.',
['骑过']='骑过小龙女:BAAALgAECgEJAQABLgAFFAMJBgADAOAJAA==.',
['高位']='高位截瘫:BAAALgAECgMJAwAAAA==.',
['高启']='高启强:BAAALgAECgEJAQAAAA==.',
['黑手']='黑手的自然:BAAALgAECgcJBwAAAA==.',
['龍腾']='龍腾尛圣:BAAALgAECgYJBgAAAA==.龍腾尛文:BAAALgAECgIJAgAAAA==.',
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
