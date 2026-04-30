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

local lookup = {'Monk-Windwalker','Monk-Mistweaver','Shaman-Elemental','Shaman-Restoration','Warlock-Affliction','Hunter-Marksmanship','Hunter-BeastMastery','Priest-Shadow','DeathKnight-Unholy','Warrior-Protection','Mage-Frost','Priest-Holy','Priest-Discipline','Druid-Restoration','Monk-Brewmaster','Druid-Balance','Rogue-Subtlety','Paladin-Retribution','Hunter-Survival','DemonHunter-Devourer','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation',}
local provider = {region='CN',realm='辛达苟萨',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bd='Bd:BAAALgADCgEJAQAAAA==.',
Dk='Dkt:BAAALgAECgEJAQAAAA==.',
Do='Dominus:BAAALgADCgEJAQAAAA==.',
Hx='Hxx:BAAALgADCgEJAQAAAA==.',
Ka='Kaldalis:BAAALgAFFAEJAQAAAA==.',
Ke='Keenful:BAAALgAECgEJAQAAAA==.',
Ma='Maqnilie:BAAALgAFFAIJAwAAAA==.',
Ni='Ningg:BAAALgAECgEJAQAAAA==.',
Pa='Pangze:BAABLgAFFH8JAAMBAAIJWiE+CgC7AAABAAIJWiE+CgC7AAACAAIJRQ70CgCIAAAAAA==.',
St='Stir:BAAALgAECgIJAgAAAA==.',
Su='Suyyzs:BAABLgAFFH8FAAMDAAIJNAzoFgCcAAADAAIJNAzoFgCcAAAEAAIJ5wddGwCMAAABLgAFFAQJEAAFAHsmAA==.',
Te='Tender:BAABLgAFFH8FAAMGAAIJKCT7GADDAAAGAAIJKCT7GADDAAAHAAEJvyQIFwBvAAAAAA==.',
Tz='Tz:BAAALgADCgcJBgAAAA==.',
Vo='Voidpg:BAAALgAECgkJEAAAAA==.',
Zs='Zs:BAAALgAECgEJAgAAAA==.',
['一位']='一位奶萨:BAAALgAFFAQJBAAAAA==.',
['一粒']='一粒蛋:BAAALgADCgYJDAAAAA==.',
['七七']='七七丶打怪兽:BAAALgAECgMJAwAAAA==.',
['三上']='三上丶悠亞:BAAALgAFFAQJBAAAAA==.',
['丰川']='丰川祥紫:BAABLgAFFH8FAAIIAAUJDg7DAwA0AQAIAAUJDg7DAwA0AQAAAA==.',
['丶黑']='丶黑雪姬:BAAALgAECgcJBwAAAA==.',
['二队']='二队小德:BAAALgAECgEJAQAAAA==.',
['亚里']='亚里士多奶:BAAALgAECgYJDAAAAA==.',
['伊卡']='伊卡落斯之翼:BAAALgADCgcJBwAAAA==.',
['你也']='你也想起舞吗:BAAALgAECggJEQAAAA==.',
['假装']='假装没死:BAABLgAFFH8IAAIJAAIJJhJ/RgCXAAAJAAIJJhJ/RgCXAAAAAA==.',
['冰脉']='冰脉快断了:BAAALgAECgYJBgABLgAFFAQJEgAJANslAA==.冰脉断了:BAABLgAFFH8SAAIJAAQJ2yWmAQCmAQAJAAQJ2yWmAQCmAQAAAA==.',
['南瓜']='南瓜二米粥:BAABLgAFFH8LAAIKAAQJUxzTAwBLAQAKAAQJUxzTAwBLAQAAAA==.',
['双魚']='双魚理:BAABLgAFFH8TAAILAAYJNSMGAwBOAgALAAYJNSMGAwBOAgAAAA==.',
['可璐']='可璐希尔:BAAALgAFFAQJBAAAAA==.',
['可露']='可露儿:BAABLgAECn8eAAQMAAkJTxhqGAAYAgAMAAcJkRxqGAAYAgANAAIJaglZSQBzAAAIAAEJAAAAAAAAAAABLgAFFAUJEQAOAIAaAA==.',
['呼啦']='呼啦呼啦圈:BAAALgADCgIJAgAAAA==.',
['哎赚']='哎赚不到钱:BAAALgAECgEJAQAAAA==.',
['喵呜']='喵呜最可爱:BAAALgAECgcJBwAAAA==.',
['嗷嗷']='嗷嗷呜:BAAALgAECgYJBgAAAA==.',
['嘉贝']='嘉贝莉娜:BAAALgAFFAMJAwABLgAFFAQJDQALAFggAA==.',
['国教']='国教骑士团:BAAALgAECgMJAwAAAA==.',
['圆滚']='圆滚滚飞起来:BAABLgAECn8aAAMPAAcJ2g/vMwCAAQAPAAcJ2g/vMwCAAQACAAYJcwi/PgDqAAAAAA==.',
['圆灬']='圆灬:BAAALgAECgQJCAAAAA==.',
['圣光']='圣光萨尓:BAAALgAECgQJBAAAAA==.',
['堂姐']='堂姐套圈圈:BAAALgAECgcJBwAAAA==.',
['夜咒']='夜咒:BAAALgADCgYJBgAAAA==.',
['大美']='大美女:BAAALgAECgQJBAABLgAFFAYJEQAQADQeAA==.',
['天之']='天之苍苍:BAAALgAFFAEJAgABLgAFFAIJCQARABQhAA==.',
['天命']='天命:BAACLgAFFH8NAAILAAQJWCAsEQCMAQALAAQJWCAsEQCMAQAuAAQKfygAAgsABwm1JZ8FAHgCAAsABwm1JZ8FAHgCAAAA.',
['奶龙']='奶龙奶龙:BAAALgAECgYJCQAAAA==.',
['如潮']='如潮领吾归乡:BAAALgAECgcJAQAAAA==.',
['宇星']='宇星辰:BAAALgAECgEJAQAAAA==.',
['宝乖']='宝乖:BAAALgADCgEJAwAAAA==.',
['小丢']='小丢丢丶:BAAALgAECgcJCwAAAA==.',
['小李']='小李广术:BAAALgADCgYJBgAAAA==.小李广莱:BAAALgAECgQJBAAAAA==.',
['小檬']='小檬同学:BAAALgAECgEJAQAAAA==.',
['崔斯']='崔斯特杜垩登:BAAALgAECgQJBAAAAA==.',
['已经']='已经在奶啦:BAAALgAECgQJBQAAAA==.',
['幻境']='幻境小得:BAAALgAECgQJBAAAAA==.',
['幽丨']='幽丨默:BAAALgAECgEJAQAAAA==.',
['幽默']='幽默站岗人:BAAALgAECgIJAQAAAA==.',
['弐拾']='弐拾弐式祝词:BAAALgAECgYJCQAAAA==.',
['强男']='强男萨满:BAAALgAECgEJAgAAAA==.',
['恶魔']='恶魔伊莉雅:BAAALgAECgEJAQAAAA==.',
['憨厚']='憨厚小潘达:BAAALgAECgQJBAAAAA==.',
['我心']='我心鹤锦:BAABLgAFFH8FAAISAAIJVRI3FACsAAASAAIJVRI3FACsAAAAAA==.',
['撩人']='撩人乀尐姐姐:BAAALgAECgYJBgAAAA==.',
['敌法']='敌法师:BAAALgAECgYJCAAAAA==.',
['星奈']='星奈:BAAALgAECgcJBwAAAA==.',
['晚星']='晚星:BAAALgADCggJCAAAAA==.',
['更深']='更深的蓝:BAAALgAECgUJCAAAAA==.',
['李狗']='李狗蛋儿:BAAALgAECgMJAgAAAA==.',
['杨小']='杨小楼:BAAALgAFFAQJBAAAAA==.',
['极霸']='极霸:BAAALgAECgEJAQAAAA==.',
['果酱']='果酱:BAAALgAECgEJAgAAAA==.',
['格罗']='格罗咆哮:BAAALgAECgQJBAAAAA==.',
['桔子']='桔子真好吃:BAAALgAECgUJBQAAAA==.',
['槿月']='槿月:BAAALgAECgEJAQAAAA==.',
['欢颜']='欢颜:BAAALgADCgEJAQAAAA==.',
['毁灭']='毁灭咕:BAAALgAECgYJCgAAAA==.',
['水之']='水之生灵:BAABLgAECn8WAAMHAAcJHx38IgA0AgAHAAcJHx38IgA0AgATAAYJLxGXFgBgAQAAAA==.',
['法力']='法力灌注:BAAALgAECgEJAQAAAA==.',
['泰蕾']='泰蕾莎的微笑:BAAALgAECgEJAQAAAA==.',
['海月']='海月:BAABLgAFFH8JAAIRAAIJFCG+CADSAAARAAIJFCG+CADSAAAAAA==.',
['温水']='温水:BAAALgAECgYJDwAAAA==.',
['火山']='火山灰:BAAALgADCggJCAAAAA==.',
['熊火']='熊火火:BAAALgADCgEJAQAAAA==.',
['熊猫']='熊猫人输一天:BAAALgAECgcJBgAAAA==.',
['狂风']='狂风:BAAALgAFFAIJAgAAAA==.',
['狂骨']='狂骨:BAAALgAFFAIJAwAAAA==.',
['猛喝']='猛喝二锅头:BAAALgAFFAEJAQABLgAFFAUJDwACAEcVAA==.',
['琴月']='琴月阴:BAAALgAECgEJAQAAAA==.',
['生亦']='生亦何欢:BAAALgAFFAQJAgAAAA==.',
['百事']='百事小仙:BAAALgAECgMJAwAAAA==.',
['皮一']='皮一一糖:BAAALgAFFAEJAQAAAA==.皮一下很开心:BAAALgAFFAQJAgAAAA==.',
['盾菇']='盾菇:BAAALgAECgIJAgAAAA==.',
['瞎了']='瞎了眼的胖几:BAACLgAFFH8NAAIUAAUJOBjJBwCoAQAUAAUJOBjJBwCoAQAuAAQKfxUAAhQABwkEIPw4ABECABQABwkEIPw4ABECAAAA.瞎了眼的胖叽:BAABLgAFFH8NAAIUAAUJtBi5BwCoAQAUAAUJtBi5BwCoAQAAAA==.瞎了眼的胖子:BAACLgAFFH8OAAIUAAUJJiRFBADvAQAUAAUJJiRFBADvAQAuAAQKfxUAAhQACQlbGSQrAFMCABQACQlbGSQrAFMCAAAA.瞎了眼的胖纸:BAABLgAFFH8IAAIUAAQJmgreFAAsAQAUAAQJmgreFAAsAQAAAA==.',
['碗叔']='碗叔吃仙丹:BAAALgAECgcJCQAAAA==.碗叔练武功:BAAALgAECgEJAgAAAA==.',
['神漫']='神漫波:BAAALgAECgEJAQAAAA==.',
['空城']='空城丨天下:BAAALgAFFAIJAgAAAA==.',
['绵羊']='绵羊:BAAALgAECgMJAwAAAA==.',
['缇坦']='缇坦妮雅:BAAALgAFFAQJBAAAAA==.',
['罪牛']='罪牛:BAAALgADCgMJAwAAAA==.',
['美屡']='美屡:BAAALgAECgUJBQAAAA==.',
['羽生']='羽生萌萌香:BAAALgAFFAQJBAAAAA==.',
['老炫']='老炫:BAAALgADCgcJBwAAAA==.',
['自助']='自助者天助:BAAALgADCgIJAgAAAA==.',
['艾丽']='艾丽妮:BAAALgAFFAQJBAAAAA==.',
['艾雅']='艾雅法柆:BAAALgAFFAQJBAAAAA==.',
['莓良']='莓良心:BAAALgAECgYJBgAAAA==.',
['菈尼']='菈尼:BAAALgAFFAQJBAAAAA==.',
['菲亚']='菲亚梅塔:BAABLgAFFH8IAAIMAAQJzwmXAwATAQAMAAQJzwmXAwATAQAAAA==.',
['落丨']='落丨幕:BAAALgAECgcJCwAAAA==.',
['蓝正']='蓝正龙:BAAALgAECgEJAgAAAA==.',
['薇薇']='薇薇安娜:BAABLgAFFH8JAAIIAAUJwRYOAwBFAQAIAAUJwRYOAwBFAQAAAA==.',
['语柒']='语柒:BAAALgAECgEJAQAAAA==.',
['豆芽']='豆芽児:BAAALgAECgIJAgAAAA==.',
['贵阳']='贵阳第一死宅:BAAALgAECgcJBwAAAA==.',
['赵日']='赵日天:BAAALgAECgcJCAAAAA==.',
['超库']='超库德:BAAALgAECgUJBQAAAA==.',
['超级']='超级二:BAAALgADCgUJBQAAAA==.',
['跟着']='跟着我有鱼吃:BAAALgAECgcJBwAAAA==.',
['辣烧']='辣烧水潺:BAAALgAFFAIJAQAAAA==.',
['迷迷']='迷迷狐狐:BAAALgAECgYJCgAAAA==.',
['长尾']='长尾巴狐狸:BAAALgADCgIJAgAAAA==.',
['陶矢']='陶矢:BAABLgAFFH8RAAMDAAUJHx+ZAgDRAQADAAUJHx+ZAgDRAQAEAAEJ8gXdIgBIAAABLgAFFAUJDwANANwiAA==.',
['雪花']='雪花沉睡:BAACLgAFFH8UAAMVAAYJniHEAADwAQAVAAYJniHEAADwAQAWAAEJAADGBwBsAAAuAAQKfywABBUACQlgJcMAANUDABUACQk6JcMAANUDABYABgksJYABAMoBABcAAwmhHoswAOwAAAAA.',
['雷霆']='雷霆嘎巴:BAAALgADCgEJAQAAAA==.',
['雾海']='雾海:BAAALgAFFAIJBAAAAA==.',
['露露']='露露缇雅:BAABLgAFFH8HAAIJAAMJiiJ+GwA2AQAJAAMJiiJ+GwA2AQAAAA==.',
['面杨']='面杨:BAAALgAECgYJCAAAAA==.',
['韩天']='韩天尊:BAAALgAECgIJAwAAAA==.',
['饮茶']='饮茶先啦:BAACLgAFFH8PAAICAAUJRxXiAgCCAQACAAUJRxXiAgCCAQAuAAQKfyYAAgIACQm4IskBAH0DAAIACQm4IskBAH0DAAAA.',
['龙咕']='龙咕:BAAALgAFFAIJAgABLgAFFAgJFgAVAH0HAA==.',
['龙戦']='龙戦于野:BAAALgADCgUJBQAAAA==.',
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
