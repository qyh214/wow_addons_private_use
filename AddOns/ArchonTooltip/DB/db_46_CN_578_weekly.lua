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

local lookup = {'Mage-Frost','Druid-Restoration','Druid-Balance','Paladin-Retribution','Paladin-Holy','Warrior-Fury','Druid-Feral','DemonHunter-Havoc','Hunter-BeastMastery','Unknown-Unknown','Rogue-Subtlety','Hunter-Marksmanship','Evoker-Devastation','DeathKnight-Blood','Evoker-Augmentation','DemonHunter-Devourer',}
local provider = {region='CN',realm='军团要塞',name='CN',type='weekly',zone=46,date='2026-04-25',data={Av='Avicii:BAAALgAECgkJCAABLgAFFAUJEAABAJURAA==.',
Cl='Clearlovex:BAABLgAECn8bAAMCAAkJFB0oCQD+AgACAAkJFB0oCQD+AgADAAUJtQRIYgCYAAABLgAECgkJFAACAC8kAA==.',
Co='Connie:BAAALgAECgMJAwAAAA==.',
Em='Emo:BAAALgAECgYJDgAAAA==.',
Fr='Freyayoen:BAAALgAECgUJBwAAAA==.',
Ku='Kumo:BAAALgAFFAcJAQAAAA==.',
Pu='Pusi:BAAALgAECgUJBQAAAA==.',
Su='Sungrass:BAAALgAECgEJAgAAAA==.Suriy:BAAALgAECggJCgAAAA==.',
Vj='Vjghj:BAAALgADCgMJAwAAAA==.',
['Üü']='Üü:BAAALgAECgUJCAAAAA==.',
['一一']='一一唯一一:BAAALgAECgEJAQAAAA==.',
['一丶']='一丶惩戒:BAAALgADCgQJAwAAAA==.',
['一极']='一极品少爷一:BAAALgAECgYJBgAAAA==.',
['一样']='一样的阴霾:BAAALgAECgQJBgAAAA==.',
['七月']='七月狮子:BAAALgAFFAQJBAAAAA==.',
['不许']='不许动贝克曼:BAAALgAECgIJBAAAAA==.',
['丽加']='丽加尔:BAAALgADCgEJAQAAAA==.',
['二一']='二一二一:BAAALgAECgEJAQAAAA==.',
['二二']='二二丶一一:BAAALgAECgUJCAAAAA==.',
['五月']='五月双子:BAAALgAFFAQJBAAAAA==.',
['五点']='五点半:BAAALgAFFAEJAQAAAA==.',
['人民']='人民的名义:BAABLgAECn8WAAMEAAcJPBzzFAB5AQAEAAcJPBzzFAB5AQAFAAYJjgrDWQAVAQAAAA==.',
['伊萨']='伊萨拉:BAAALgAECgQJBQAAAA==.',
['体育']='体育董老师:BAAALgAFFAEJAQAAAA==.',
['你以']='你以:BAAALgADCgcJBwAAAA==.',
['倾颜']='倾颜:BAAALgAECgEJAQAAAA==.',
['假裝']='假裝緈鍢:BAAALgAFFAEJAQAAAA==.',
['六六']='六六刘:BAAALgAECgMJAwAAAA==.',
['六月']='六月巨蟹:BAAALgAFFAQJBAAAAA==.',
['军团']='军团爸爸:BAAALgAECgEJAQAAAA==.',
['别回']='别回头视我:BAAALgAECgYJBwAAAA==.别回头諟我:BAABLgAFFH8IAAIGAAMJNA7oEgDtAAAGAAMJNA7oEgDtAAAAAA==.',
['剑白']='剑白:BAAALgAECgMJAwAAAA==.',
['发条']='发条橙:BAABLgAFFH8HAAMCAAMJUBaxDwDuAAACAAMJUBaxDwDuAAADAAEJeAR1HABEAAAAAA==.',
['咕咕']='咕咕:BAAALgAECgEJAQAAAA==.咕咕噜:BAABLgAECn8WAAIHAAgJUxZSAgC8AQAHAAgJUxZSAgC8AQAAAA==.',
['啊啊']='啊啊袄袄:BAAALgAECgYJBgAAAA==.',
['喵了']='喵了个咪的丶:BAAALgAECgMJBQAAAA==.',
['喵小']='喵小白:BAAALgAECgIJAgAAAA==.',
['噗噗']='噗噗灬萨:BAAALgAECgUJDgAAAA==.',
['四月']='四月牛牛:BAABLgAFFH8FAAICAAQJTQMVDwD2AAACAAQJTQMVDwD2AAAAAA==.',
['土地']='土地婆婆:BAAALgADCgEJAQAAAA==.',
['圣光']='圣光使者刘波:BAAALgADCgcJBwAAAA==.',
['圣园']='圣园未花丶:BAAALgAECgYJBgAAAA==.',
['壹五']='壹五柒三:BAAALgAECgEJAQAAAA==.',
['壹粒']='壹粒弹:BAAALgAECgEJAQAAAA==.',
['大儒']='大儒名宿:BAAALgADCgQJBAAAAA==.',
['天剑']='天剑非天:BAAALgAFFAEJAQAAAA==.',
['天外']='天外来客:BAAALgAECgEJAQAAAA==.',
['奶味']='奶味泡芙:BAAALgADCgIJAgAAAA==.',
['娜儿']='娜儿可爱吖:BAAALgAECggJEgAAAA==.',
['婷姐']='婷姐小年糕:BAAALgAECgYJAgAAAA==.',
['孤独']='孤独的流星:BAAALgAECgIJAgAAAA==.',
['宁欢']='宁欢:BAAALgAECgYJBgABLgAFFAUJBQAIAP4TAA==.',
['宁静']='宁静的梦境:BAAALgAECgUJCwAAAA==.',
['小小']='小小雨啊:BAAALgAFFAYJAQAAAA==.',
['小飞']='小飞侠:BAAALgAECgEJAQAAAA==.',
['小鳥']='小鳥:BAAALgAECgUJDAAAAA==.',
['岱宗']='岱宗:BAAALgAECgUJBQAAAA==.',
['希尔']='希尔瓦娜丝:BAABLgAECn8WAAIJAAgJcQnhQwCgAQAJAAgJcQnhQwCgAQAAAA==.',
['引领']='引领传奇:BAAALgAECgIJAgAAAA==.',
['愤怒']='愤怒的牛血:BAAALgAECgUJBQAAAA==.',
['我却']='我却没有醒:BAAALgAECgYJBwAAAA==.',
['斯瓦']='斯瓦楼麦康姆:BAABLgAFFH8JAAIEAAQJYBpbDwAuAQAEAAQJYBpbDwAuAQABLgAFFAcJAgAKAAAAAA==.',
['无敌']='无敌炉石:BAAALgAECgcJCAAAAA==.',
['有时']='有时爱魅惑:BAAALgADCgMJAwAAAA==.',
['果果']='果果尐:BAAALgAFFAEJAQABLgAFFAMJBQALAN8OAA==.',
['毁灭']='毁灭者轩辕弑:BAAALgAECgEJAQAAAA==.',
['毛坏']='毛坏坏:BAAALgAECgYJBgABLgAECgkJFAACAC8kAA==.',
['法克']='法克游:BAAALgAECgYJBgAAAA==.',
['泰来']='泰来:BAAALgAECgkJDgAAAA==.',
['流觞']='流觞:BAAALgADCgcJBwABLgAFFAMJBQAMAPEPAA==.',
['浑水']='浑水:BAAALgADCgEJAQAAAA==.',
['淡淡']='淡淡灬悲伤:BAAALgAECgYJBgAAAA==.淡淡灬福荣:BAAALgAECgkJEAAAAA==.',
['渡里']='渡里妮娜:BAAALgAECgQJBAAAAA==.',
['灯下']='灯下黑:BAAALgAECgcJBwAAAA==.',
['灼魂']='灼魂:BAAALgAFFAMJAwABLgAFFAMJBQAMAPEPAA==.',
['狼月']='狼月:BAAALgAECgMJAwAAAA==.',
['猫某']='猫某君:BAAALgADCgYJAQAAAA==.',
['玖玖']='玖玖娃儿:BAAALgAECgYJCwAAAA==.',
['现金']='现金拍卖行:BAAALgADCgcJBwAAAA==.',
['瘾大']='瘾大技术差:BAAALgAFFAQJBAABLgAFFAYJBgANAAkSAA==.',
['白色']='白色婚纱:BAABLgAFFH8IAAIOAAQJUwoBCQD5AAAOAAQJUwoBCQD5AAAAAA==.',
['皮卡']='皮卡丘么么:BAAALgAFFAEJAQAAAA==.皮卡丘啊哈:BAAALgAECgYJDAABLgAFFAcJHAAPAFggAA==.皮卡丘欸嘿:BAACLgAFFH8cAAIPAAcJWCB7AADiAgAPAAcJWCB7AADiAgAuAAQKfxYAAw8ABwnyJWAJAOECAA8ABwnyJWAJAOECAA0ABAnKHcAkAAABAAAA.',
['相思']='相思红:BAAALgAECgYJCQAAAA==.',
['石胡']='石胡煲鸡:BAAALgAECgkJCQAAAA==.',
['破名']='破名乀难起:BAAALgAECgQJBAAAAA==.',
['老王']='老王优秀:BAAALgAECgMJAwAAAA==.',
['萨拉']='萨拉挞斯:BAAALgAECgEJAgAAAA==.',
['蒸馏']='蒸馏水:BAAALgADCgEJAQAAAA==.',
['贝果']='贝果:BAACLgAFFH8MAAIQAAQJ0A/GCAAoAQAQAAQJ0A/GCAAoAQAuAAQKfycAAxAACAl3G14eAJwCABAACAl3G14eAJwCAAgABQk2DSxAAPoAAAAA.',
['踮脚']='踮脚大美:BAAALgAECgEJAgAAAA==.',
['辉煌']='辉煌荣耀:BAAALgADCgcJBwAAAA==.',
['近战']='近战法爷:BAAALgAECgUJDAAAAA==.',
['远壹']='远壹点:BAAALgADCgEJAQAAAA==.',
['铁鱼']='铁鱼一号:BAAALgADCgEJAQAAAA==.',
['阎王']='阎王神医:BAAALgAECgcJDQAAAA==.',
['雪碧']='雪碧:BAAALgAECgQJBAAAAA==.',
['雲飛']='雲飛兒:BAAALgAECgIJAwAAAA==.',
['非凡']='非凡牛牛:BAAALgAECgIJAgAAAA==.',
['风月']='风月之巅:BAAALgAECgUJBQAAAA==.',
['风雨']='风雨夜归人:BAAALgAFFAIJBAAAAA==.',
['飞暴']='飞暴:BAABLgAFFH8FAAIMAAMJ8Q+fFQDuAAAMAAMJ8Q+fFQDuAAAAAA==.',
['骑猪']='骑猪上大树:BAAALgAECgYJBgAAAA==.',
['魔族']='魔族九翼:BAAALgAECgkJCQAAAA==.',
['鲨鱼']='鲨鱼辣椒丶:BAAALgAECgkJAQAAAA==.',
['鸟弓']='鸟弓灬狼猎:BAAALgAECgEJAgAAAA==.',
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
