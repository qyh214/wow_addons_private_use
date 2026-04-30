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

local lookup = {'DeathKnight-Unholy','Paladin-Retribution','Unknown-Unknown','Druid-Balance','Monk-Brewmaster','Druid-Restoration','Warrior-Arms','Warrior-Fury','Warrior-Protection','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','Evoker-Augmentation','Evoker-Devastation','Mage-Frost','Monk-Mistweaver','Paladin-Holy','Shaman-Restoration','Paladin-Protection','DemonHunter-Devourer','DemonHunter-Vengeance','Priest-Discipline','Priest-Holy','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','DemonHunter-Havoc','DeathKnight-Blood',}
local provider = {region='CN',realm='克洛玛古斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ao='Aozrôa:BAAALgAECgYJBgAAAA==.',
Ca='Camelia:BAAALgAECgYJCwAAAA==.',
Co='Corson:BAAALgAECgQJBAAAAA==.',
Di='Discovergpb:BAAALgADCgUJBQAAAA==.',
Dr='Dripuhlz:BAACLgAFFH8FAAIBAAMJ5CV3NwCsAAABAAMJ5CV3NwCsAAAuAAQKfxcAAgEACAlPI7EbANcCAAEACAlPI7EbANcCAAAA.',
El='Elaya:BAAALgAECgQJDgAAAA==.Eldenring:BAAALgAECgYJDAAAAA==.Elone:BAAALgADCgUJBQAAAA==.',
Fi='Fin:BAAALgAECgcJDAAAAA==.',
Ga='Galbrena:BAABLgAECn8bAAICAAgJ0xn8NQBLAgACAAgJ0xn8NQBLAgAAAA==.',
He='Heiheiya:BAAALgAFFAMJBAAAAA==.',
Ic='Icywings:BAAALgADCgEJAQAAAA==.',
Ju='Juechen:BAAALgADCgIJAgABLgAFFAUJBAADAAAAAA==.',
Ki='Kiing:BAAALgAFFAMJBAAAAA==.',
Le='Lellow:BAAALgAECgQJBQAAAA==.',
Mi='Miracast:BAAALgADCgYJBgAAAA==.',
Mo='Moonice:BAAALgAECgEJAQAAAA==.',
My='Myz:BAAALgAECgEJAQAAAA==.',
Na='Nadeshiko:BAAALgADCgUJBQAAAA==.',
Ne='Nenu:BAAALgAECgUJDQAAAA==.',
Pu='Pulling:BAAALgAECgIJAgAAAA==.',
Ta='Tankini:BAAALgADCgYJBgAAAA==.',
Tr='Trillion:BAAALgAECgcJBgABLgAFFAUJCwAEAAgHAA==.',
Wy='Wyz:BAAALgAFFAIJAwAAAA==.',
['一年']='一年还是两年:BAAALgAECggJAgAAAA==.',
['一锤']='一锤一个憨憨:BAAALgAECgcJCwAAAA==.',
['万法']='万法孜然:BAABLgAECn8UAAIFAAgJwwi2PQBPAQAFAAgJwwi2PQBPAQAAAA==.',
['三支']='三支箭:BAAALgAECgkJCQAAAA==.',
['不过']='不过尔尔:BAAALgAECgQJBAAAAA==.',
['东京']='东京奶德:BAACLgAFFH8IAAMEAAQJlRPEDgD0AAAEAAMJ6hTEDgD0AAAGAAEJFyCnIQBeAAAuAAQKfx8AAwQACAndIFUDAAECAAQABwmOI1UDAAECAAYAAgnJGy6rAHAAAAAA.',
['东方']='东方蛮:BAAALgAECgEJAQAAAA==.',
['丨開']='丨開心:BAACLgAFFH8PAAMHAAQJcBgNAQBbAQAIAAQJDRgxCABqAQAHAAQJFhENAQBbAQAuAAQKfx0ABAcACAlMIV0GAGcCAAcABwn6HV0GAGcCAAgABgleI3kiAEECAAkAAgkUHgEzAK0AAAAA.',
['乔迪']='乔迪:BAAALgAECgIJAgAAAA==.',
['乡秀']='乡秀树:BAABLgAECn8gAAQKAAgJoRgUHwAqAgAKAAgJZhYUHwAqAgALAAEJcx+NtQBYAAAMAAEJuRoAAAAAAAAAAA==.',
['二两']='二两三钱:BAAALgAECgkJCQAAAA==.',
['云上']='云上飞静:BAAALgAECgcJAwAAAA==.',
['亿眼']='亿眼丁真:BAAALgAECgUJCAAAAA==.',
['伊布']='伊布:BAAALgAECgUJCgAAAA==.',
['伊蕾']='伊蕾娜:BAAALgADCgYJBgAAAA==.',
['光芒']='光芒:BAAALgAECgMJAwAAAA==.光芒天启:BAAALgAECgMJAwAAAA==.',
['六夜']='六夜丶:BAABLgAFFH8FAAIFAAIJbwLoDQBtAAAFAAIJbwLoDQBtAAAAAA==.',
['农夫']='农夫大锤:BAAALgAECgUJBQAAAA==.',
['凉拌']='凉拌见手青:BAAALgAECgUJBQAAAA==.',
['凡圣']='凡圣:BAAALgAECgYJCgAAAA==.',
['凤狂']='凤狂神:BAABLgAECn8XAAILAAgJChQTDQCgAQALAAgJChQTDQCgAQAAAA==.',
['凯瑟']='凯瑟琳之舞:BAAALgADCgcJBwAAAA==.',
['刘波']='刘波儿:BAACLgAFFH8IAAINAAQJnQyZDQAnAQANAAQJnQyZDQAnAQAuAAQKfx0AAw0ACAnmFwcFALkBAA0ACAnmFwcFALkBAA4ABAkbCqcrAL8AAAAA.',
['剩乔']='剩乔治:BAAALgAFFAEJAQAAAA==.',
['匠人']='匠人无寓:BAAALgAFFAIJAwAAAA==.',
['千本']='千本樱姬:BAAALgAECgUJBQAAAA==.',
['南乔']='南乔峰:BAAALgAECgUJBQAAAA==.',
['南波']='南波吐:BAAALgAECgEJAQAAAA==.',
['卡卡']='卡卡东师傅:BAAALgAECgYJCgAAAA==.',
['叁石']='叁石钉:BAAALgAECgQJBAAAAA==.',
['双喜']='双喜的骑士:BAAALgADCgEJAQAAAA==.',
['可夏']='可夏:BAAALgADCgUJBQAAAA==.',
['呱唧']='呱唧呱唧:BAAALgAECgIJAwAAAA==.',
['命运']='命运丨喉舌:BAABLgAFFH8HAAIPAAQJHQnhIQA4AQAPAAQJHQnhIQA4AQAAAA==.',
['唇色']='唇色:BAAALgAECgEJAQAAAA==.',
['唐山']='唐山浪打浪:BAAALgAECgIJAgAAAA==.',
['唔知']='唔知搞咩:BAABLgAFFH8HAAIFAAMJWQQiIQBuAAAFAAMJWQQiIQBuAAAAAA==.',
['嗜血']='嗜血灬先祖:BAAALgAECgEJAQAAAA==.嗜血灬圣骑:BAAALgAECgEJAQAAAA==.嗜血灬阳哥:BAAALgAECgQJBAAAAA==.',
['嘍嘍']='嘍嘍的嘍嘍:BAAALgAECgEJAQAAAA==.',
['圣骑']='圣骑审判者:BAAALgAECgEJAQAAAA==.',
['夜魇']='夜魇:BAAALgAECgYJCQAAAA==.',
['天地']='天地法神:BAAALgAECgMJAwAAAA==.',
['天色']='天色满影:BAAALgADCgIJAgAAAA==.',
['奈何']='奈何桥上卖身:BAAALgAECgEJAQAAAA==.',
['姜黎']='姜黎:BAAALgADCgMJAwAAAA==.',
['娜娜']='娜娜莫女王:BAACLgAFFH8IAAIQAAQJ3AlBCQAiAQAQAAQJ3AlBCQAiAQAuAAQKfx0AAhAACAnBE6QJAFYBABAACAnBE6QJAFYBAAAA.',
['嫣紫']='嫣紫:BAAALgAECgEJAQAAAA==.',
['存钱']='存钱罐罐:BAAALgAECgEJAQAAAA==.',
['孤身']='孤身伴月影:BAAALgAECgYJEwAAAA==.',
['完美']='完美的一天:BAAALgADCgEJAQAAAA==.',
['宝宝']='宝宝先上:BAAALgAFFAEJAQAAAA==.',
['寂寞']='寂寞的冷月:BAAALgAECgUJCQAAAA==.',
['寶貝']='寶貝別怕不疼:BAAALgAECgEJAQAAAA==.',
['寻找']='寻找岼衡:BAAALgAECgEJAQAAAA==.',
['小允']='小允许:BAAALgAECgYJCAAAAA==.',
['小知']='小知:BAAALgAECgEJAQAAAA==.',
['小笨']='小笨熊的吻:BAAALgAECgUJBQAAAA==.',
['小鱼']='小鱼家的包菜:BAACLgAFFH8HAAIPAAMJ9x26QACtAAAPAAMJ9x26QACtAAAuAAQKfx4AAg8ACAl1HTAtAL0CAA8ACAl1HTAtAL0CAAAA.',
['布莉']='布莉琪特:BAABLgAECn8VAAMRAAgJDxkZJAACAgARAAgJDxkZJAACAgACAAEJrwdIQgEzAAAAAA==.',
['帅气']='帅气大叔:BAAALgADCgYJBwAAAA==.',
['幻月']='幻月傻僈:BAAALgAECgEJAQAAAA==.',
['幽幻']='幽幻魔王:BAAALgAFFAIJAwAAAA==.',
['心事']='心事数径白发:BAAALgAECgUJBgAAAA==.',
['快乐']='快乐小狐狸:BAAALgAECgQJBQAAAA==.',
['惬意']='惬意的风:BAACLgAFFH8IAAISAAQJxxKPCABBAQASAAQJxxKPCABBAQAuAAQKfx4AAhIACAkQHhkSAIUCABIACAkQHhkSAIUCAAAA.',
['我行']='我行我术:BAAALgAECgUJBQAAAA==.',
['我要']='我要让你心碎:BAAALgAECgQJBAAAAA==.',
['战灬']='战灬火:BAAALgAECgEJAQAAAA==.',
['手中']='手中流沙:BAAALgAFFAIJAwAAAA==.',
['拉风']='拉风的小红花:BAAALgAECgcJEgAAAA==.',
['拿铁']='拿铁加冰加奶:BAAALgADCgIJAgAAAA==.',
['敌灬']='敌灬法:BAAALgAECggJCQAAAA==.',
['散庚']='散庚浮白:BAABLgAECn8UAAIBAAYJHCMZPABHAgABAAYJHCMZPABHAgAAAA==.',
['斯文']='斯文的大领主:BAAALgAECgIJAgAAAA==.',
['方小']='方小简:BAAALgAECggJEwAAAA==.',
['星光']='星光:BAAALgAECgQJBgAAAA==.',
['春醒']='春醒鸢徊:BAAALgAECgQJBAAAAA==.',
['昨日']='昨日雪如花灬:BAABLgAECn8XAAIBAAcJvh6yOgBMAgABAAcJvh6yOgBMAgAAAA==.',
['普渡']='普渡法尊:BAAALgAECgcJBwAAAA==.',
['景衣']='景衣卫:BAAALgAECgYJBwAAAA==.',
['暖暖']='暖暖夜之法:BAAALgAFFAIJAwAAAA==.暖暖夜之雾:BAAALgAECgIJAgAAAA==.暖暖爱听风:BAABLgAECn8WAAMCAAgJmBJzVQDhAQACAAgJmBJzVQDhAQATAAMJ9AM/PABOAAAAAA==.',
['暗夜']='暗夜猎神超萌:BAAALgADCgEJAQAAAA==.',
['暗影']='暗影火毁:BAAALgAECgUJBQAAAA==.',
['曹偲']='曹偲妮:BAAALgAECgUJBQAAAA==.',
['曼波']='曼波曼波:BAAALgADCgQJBAAAAA==.',
['月光']='月光傾城:BAAALgAECgIJAgAAAA==.',
['月翼']='月翼猫头鹰:BAAALgAFFAQJBAAAAA==.',
['朙朙']='朙朙很聪明:BAAALgAECgUJBQAAAA==.',
['末日']='末日冰峰:BAAALgAFFAIJBAAAAA==.末日飘雪:BAAALgAECgYJBgAAAA==.',
['术月']='术月:BAAALgAECgkJAgAAAA==.',
['杀戮']='杀戮丨魂鬥羅:BAAALgAECgYJDAAAAA==.杀戮魔王:BAAALgAFFAIJAwABLgAFFAUJEAAPAFIlAA==.',
['来给']='来给你治疗吧:BAAALgAECgMJAwAAAA==.',
['果粒']='果粒多丶:BAAALgAECgEJAQAAAA==.',
['梁敏']='梁敏儿:BAAALgAECgkJCQAAAA==.',
['梅柳']='梅柳丨齐娜灬:BAAALgAECgEJAQABLgAFFAIJAgADAAAAAA==.',
['歌未']='歌未竟:BAAALgAECgIJAgAAAA==.',
['死亡']='死亡女神:BAAALgADCgYJBgAAAA==.',
['残帆']='残帆:BAAALgAECgEJAQAAAA==.',
['永不']='永不减肥:BAACLgAFFH8IAAIFAAMJnQwkFQDMAAAFAAMJnQwkFQDMAAAuAAQKfyIAAgUABwnmGEUiAPABAAUABwnmGEUiAPABAAAA.',
['没遮']='没遮拦:BAAALgAECgYJBwAAAA==.',
['法布']='法布雷加斯:BAAALgADCgEJAQAAAA==.',
['法灬']='法灬廪霜:BAAALgADCgEJAQAAAA==.',
['泛思']='泛思灬喆:BAAALgAFFAEJAQAAAA==.',
['浔找']='浔找苹衡:BAACLgAFFH8IAAIUAAQJ7g4CEwA5AQAUAAQJ7g4CEwA5AQAuAAQKfx4AAxQACAn2EJQgAAcBABQABwmWEZQgAAcBABUABQnyCqkZAMoAAAAA.',
['温温']='温温坏:BAAALgAECgUJCgAAAA==.',
['灬沙']='灬沙洲冷:BAAALgAECgcJDQAAAA==.',
['灯前']='灯前无影:BAAALgAECgEJAgAAAA==.',
['灵岩']='灵岩:BAAALgAECgYJBgAAAA==.',
['炎帝']='炎帝灬萧炎灬:BAAALgAECgMJAwAAAA==.',
['炼狱']='炼狱霜火:BAAALgAECgcJCAAAAA==.',
['無名']='無名:BAABLgAECn8UAAIIAAYJJxYtQgCbAQAIAAYJJxYtQgCbAQAAAA==.',
['焦糖']='焦糖奶油布丁:BAABLgAECn8XAAIEAAgJ/R1JDwCrAgAEAAgJ/R1JDwCrAgAAAA==.',
['爱丽']='爱丽丝风影:BAAALgAECgUJBQAAAA==.',
['狂乱']='狂乱贵公子:BAAALgAECgYJBAAAAA==.',
['狂杀']='狂杀:BAAALgAECgYJCQAAAA==.',
['狠哥']='狠哥:BAAALgAECgcJBwAAAA==.',
['独行']='独行独酬:BAAALgAECgYJEwAAAA==.',
['猪猪']='猪猪蛋:BAACLgAFFH8QAAMWAAUJUBXoBwBdAQAWAAUJUBXoBwBdAQAXAAEJ1wIAAAAAAAAuAAQKfx8AAxYACQnTIWABAIEDABYACQnTIWABAIEDABcABgkYCQpJABUBAAAA.',
['王女']='王女之命:BAABLgAECn8WAAINAAgJDiKRCwC9AgANAAgJDiKRCwC9AgAAAA==.',
['玫瑰']='玫瑰灬魅影:BAAALgAECgEJAQAAAA==.',
['瓦里']='瓦里安丶镖客:BAAALgAECgYJBwAAAA==.',
['生命']='生命之水:BAAALgAECgYJDAAAAA==.',
['疾锋']='疾锋:BAAALgAECgIJAgAAAA==.',
['白太']='白太狼:BAAALgAECgQJBQAAAA==.',
['白嶶']='白嶶:BAAALgAECgEJAQAAAA==.',
['白芷']='白芷:BAAALgAECgYJCQAAAA==.',
['百变']='百变星星:BAAALgADCgYJBgAAAA==.',
['相见']='相见恨晚丿:BAAALgADCgIJAgAAAA==.',
['真的']='真的汉子:BAACLgAFFH8JAAMLAAQJPxQqCgAQAQALAAMJLhkqCgAQAQAKAAIJzgRBIgB/AAAuAAQKfx4AAwsACAn/IXgIAOIBAAsACAmRIXgIAOIBAAoABwloFD88AGwBAAAA.',
['神牧']='神牧土豆粉:BAAALgADCgIJAgAAAA==.',
['福瑞']='福瑞锂猫:BAAALgAFFAIJAgAAAA==.',
['离骚']='离骚的星星:BAAALgAECgIJAgAAAA==.',
['素问']='素问陌上花开:BAAALgAECgEJAQAAAA==.',
['索饵']='索饵:BAAALgAFFAEJAQAAAA==.',
['紫色']='紫色职业:BAAALgAECgEJAQAAAA==.',
['红星']='红星贰裹头:BAAALgAECgYJBwAAAA==.',
['红烛']='红烛:BAABLgAECn8cAAQYAAgJ4xa9EgB7AQAYAAgJ4xa9EgB7AQAZAAQJmQqUOwDGAAAaAAEJAABCKQBNAAAAAA==.',
['绚丽']='绚丽多彩:BAAALgAECgQJBwAAAA==.',
['缘月']='缘月:BAAALgAECgEJAQAAAA==.',
['羊和']='羊和猪:BAAALgADCgQJAQAAAA==.',
['翡翠']='翡翠之矢:BAAALgAECgYJBgAAAA==.',
['老牛']='老牛哞:BAAALgAFFAIJBAAAAA==.',
['艾因']='艾因利奇曼:BAAALgADCgIJAgAAAA==.',
['花若']='花若笑颜:BAABLgAFFH8OAAIXAAQJ+QWKBgASAQAXAAQJ+QWKBgASAQAAAA==.',
['花非']='花非花雾非雾:BAAALgAECgUJCAAAAA==.',
['苍蝇']='苍蝇和你:BAAALgADCgMJAwAAAA==.',
['苏小']='苏小沉:BAAALgAECgYJCQAAAA==.',
['苦涩']='苦涩椛开:BAAALgADCgYJBgAAAA==.',
['莱德']='莱德需要我们:BAAALgADCgIJAgAAAA==.',
['萌萌']='萌萌哒时光吖:BAAALgAECgYJCQAAAA==.',
['蓝萦']='蓝萦傲魂:BAAALgAECgIJAwAAAA==.',
['蕾缪']='蕾缪乐:BAAALgAFFAMJBAAAAA==.',
['蘇小']='蘇小蛮:BAAALgAECgQJBgAAAA==.',
['虫虫']='虫虫变龙:BAAALgAECgEJAQAAAA==.',
['虹豆']='虹豆:BAAALgADCgEJAQAAAA==.',
['蝎子']='蝎子奈奈:BAAALgAECgEJAQAAAA==.',
['街角']='街角的巳时:BAACLgAFFH8GAAMUAAMJpAcjHwDeAAAUAAMJpAcjHwDeAAAbAAEJtwHYDwBCAAAuAAQKfyMAAxQACAknFPBQALMBABQABwnPFPBQALMBABsABgk9EJMvAFIBAAAA.',
['诅咒']='诅咒之殇:BAAALgADCgEJAQAAAA==.',
['豊川']='豊川祥子:BAAALgAECgQJBQAAAA==.',
['辉月']='辉月伊:BAABLgAECn8UAAIXAAYJ0hP5MwBvAQAXAAYJ0hP5MwBvAQAAAA==.',
['遥大']='遥大星丶:BAACLgAFFH8OAAMcAAQJ8xYGBQDYAAABAAMJjBrjJQD+AAAcAAQJ4AcGBQDYAAAuAAQKfxkAAwEACAkTGUxBADQCAAEACAkTGUxBADQCABwAAgnJB3cUADUAAAAA.',
['钩子']='钩子酱:BAAALgAECgMJAwAAAA==.',
['锦鲤']='锦鲤夲鲤:BAABLgAECn8ZAAIPAAgJCyEkKQDOAgAPAAgJCyEkKQDOAgAAAA==.',
['長乐']='長乐:BAAALgADCgYJBgAAAA==.',
['開門']='開門呀寶貝:BAAALgAECgcJDQAAAA==.',
['阿比']='阿比盖尔:BAABLgAECn8YAAIJAAcJDBEyHQBdAQAJAAcJDBEyHQBdAQAAAA==.',
['阿沐']='阿沐斯:BAAALgAECgcJCQAAAA==.',
['随敌']='随敌丶大小变:BAAALgADCgEJAQAAAA==.',
['雾以']='雾以泪聚:BAACLgAFFH8FAAIGAAIJIyDYFAC+AAAGAAIJIyDYFAC+AAAuAAQKfx0AAgYABwkvGhgpAA8CAAYABwkvGhgpAA8CAAAA.',
['静若']='静若潇湘:BAAALgADCgQJBAAAAA==.',
['面无']='面无暇:BAAALgAECgMJBQAAAA==.',
['面漁']='面漁兒:BAAALgAECgEJAQAAAA==.',
['颜丶']='颜丶辰洋:BAABLgAECn8UAAILAAcJyxh6LAABAgALAAcJyxh6LAABAgAAAA==.',
['风云']='风云百合:BAAALgAECgYJDgAAAA==.',
['风暴']='风暴烈酒秘方:BAACLgAFFH8FAAIQAAMJuxrBDwCfAAAQAAMJuxrBDwCfAAAuAAQKfyAAAhAACAkfGeITACwCABAACAkeGeITACwCAAAA.',
['风雪']='风雪夜归人丶:BAABLgAECn8VAAIPAAYJXh9eEQC3AQAPAAYJXh9eEQC3AQAAAA==.',
['风骚']='风骚的小猎:BAAALgADCgMJAwAAAA==.',
['麦丨']='麦丨迪丨文:BAAALgAECgkJCQAAAA==.',
['黄色']='黄色飞灰:BAABLgAECn8VAAICAAcJ/h13NgBJAgACAAcJ/h13NgBJAgAAAA==.',
['黒榊']='黒榊丨目瀧灬:BAAALgAFFAIJAgAAAA==.',
['龙塾']='龙塾:BAAALgADCgUJBQAAAA==.',
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
