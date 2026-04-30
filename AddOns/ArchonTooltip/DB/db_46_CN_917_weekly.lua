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

local lookup = {'Mage-Frost','Monk-Brewmaster','Monk-Windwalker','DeathKnight-Unholy','Druid-Balance','Unknown-Unknown','Druid-Restoration','DemonHunter-Devourer','Paladin-Retribution','DeathKnight-Frost','Warlock-Demonology','Warlock-Destruction','Hunter-BeastMastery','DemonHunter-Havoc',}
local provider = {region='CN',realm='天谴之门',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Anon:BAAALgADCgUJBQAAAA==.',
Da='Dantyan:BAACLgAFFH8TAAIBAAUJiCQDBgACAgABAAUJiCQDBgACAgAuAAQKfyQAAgEACAl2Jh0HAJQDAAEACAl2Jh0HAJQDAAAA.',
Dr='Drakeacht:BAAALgAFFAQJBAAAAA==.Drakedrei:BAAALgAFFAYJAgAAAA==.Drakefear:BAAALgAFFAQJBAAAAA==.Drakeneun:BAAALgAFFAQJBAAAAA==.Drakesex:BAABLgAFFH8GAAICAAQJlxLTCwAnAQACAAQJlxLTCwAnAQAAAA==.Drakezean:BAAALgAFFAIJAgAAAA==.Drakezwei:BAAALgAFFAQJAgAAAA==.',
Fo='Folomind:BAAALgAECgEJAQAAAA==.',
Li='Littleberry:BAABLgAFFH8JAAIDAAMJeCMyAgBAAQADAAMJeCMyAgBAAQAAAA==.',
Lu='Luckinesslul:BAAALgAECgYJCQAAAA==.',
Mi='Misfortunelu:BAAALgADCgUJBQAAAA==.',
Nv='Nvy:BAAALgAFFAIJAwAAAA==.',
Ny='Nyoumi:BAAALgADCgIJAgAAAA==.',
Pa='Pareo:BAAALgAFFAQJBAAAAA==.',
Pl='Playerabdvev:BAAALgAFFAEJAQAAAA==.',
Re='Redlai:BAAALgADCgEJAQAAAA==.',
Td='Tdie:BAAALgAECgYJBgAAAA==.',
Te='Teakwood:BAAALgADCgEJAQAAAA==.',
['一切']='一切的幻梦:BAAALgADCgYJBgABLgAFFAMJCQAEANUaAA==.',
['三十']='三十个花生:BAAALgADCgIJAgAAAA==.',
['三角']='三角初音:BAABLgAFFH8QAAIFAAYJsCObAABqAgAFAAYJsCObAABqAgAAAA==.',
['上原']='上原绯玛丽:BAAALgAFFAUJBAAAAA==.',
['不在']='不在留恋:BAAALgAFFAEJAQAAAA==.',
['东关']='东关的狸花猫:BAAALgAECgQJBAAAAA==.',
['丶天']='丶天嘗地酒:BAAALgADCgEJAQAAAA==.',
['丸山']='丸山彩:BAABLgAFFH8KAAIFAAYJrB7RAABKAgAFAAYJrB7RAABKAgAAAA==.',
['乔伊']='乔伊沫沫:BAAALgADCgIJAgAAAA==.',
['仙道']='仙道贵生:BAAALgAECgYJCgAAAA==.',
['伊利']='伊利达虾:BAAALgADCgYJCwABLgAECgIJBAAGAAAAAA==.',
['你比']='你比从前快了:BAAALgAECgYJBwAAAA==.',
['偏倚']='偏倚角:BAABLgAFFH8GAAIHAAIJbg+gEACKAAAHAAIJbg+gEACKAAAAAA==.',
['兔兔']='兔兔快跑:BAAALgAECgcJCgAAAA==.',
['再化']='再化降水驻守:BAAALgAECgcJCQAAAA==.',
['冫买']='冫买了苹果:BAAALgAECgMJBAAAAA==.',
['冬子']='冬子带皮:BAAALgAECgYJCwAAAA==.',
['冰川']='冰川日菜:BAAALgAFFAUJBAAAAA==.',
['凑有']='凑有希那:BAABLgAFFH8TAAIFAAcJ7SWAAACCAgAFAAcJ7SWAAACCAgAAAA==.',
['刚刚']='刚刚没忍住:BAACLgAFFH8QAAIFAAUJSh+RAgDYAQAFAAUJSh+RAgDYAQAuAAQKfx0AAwUACAkmJMEHABoDAAUACAkmJMEHABoDAAcAAwl7GCN/AN0AAAAA.',
['南南']='南南瓜:BAAALgADCgEJAQAAAA==.',
['南陵']='南陵花神丶:BAAALgAFFAQJAQAAAA==.',
['卡的']='卡的福:BAAALgAECgEJAQAAAA==.',
['卿川']='卿川流:BAAALgADCgQJBAAAAA==.',
['双刀']='双刀火鸡:BAABLgAFFH8FAAIIAAMJlBVwGgD9AAAIAAMJlBVwGgD9AAAAAA==.',
['古尓']='古尓丹的小鬼:BAAALgADCgEJAQAAAA==.',
['可以']='可以:BAAALgADCgEJAQAAAA==.',
['台江']='台江:BAAALgAECgIJAwABLgAFFAUJEAAFAEofAA==.',
['叻太']='叻太:BAAALgAECgYJBwAAAA==.',
['吃我']='吃我大砍刀:BAAALgAECgkJEgAAAA==.',
['吃肉']='吃肉的大帅狐:BAAALgAECgYJCwAAAA==.',
['呆粒']='呆粒橙:BAAALgAFFAEJAQAAAA==.',
['哈兰']='哈兰德:BAAALgAECgEJAQAAAA==.',
['哈基']='哈基蜂:BAAALgAECgQJBAAAAA==.',
['嘿嘿']='嘿嘿骑:BAAALgAECgYJCAAAAA==.',
['噶你']='噶你腰子:BAAALgAECgYJBgAAAA==.',
['土狗']='土狗:BAAALgAECgQJBAAAAA==.',
['地火']='地火流荧:BAAALgAECgYJDgAAAA==.',
['夏雾']='夏雾雨:BAAALgADCgIJAgAAAA==.',
['夜游']='夜游游:BAAALgADCgQJBAAAAA==.',
['大和']='大和麻弥:BAABLgAFFH8HAAIFAAUJ/yL6AQDzAQAFAAUJ/yL6AQDzAQAAAA==.',
['大熊']='大熊猫:BAAALgAECgEJAgAAAA==.',
['大牛']='大牛骑士:BAAALgADCgQJBAAAAA==.',
['大风']='大风歌:BAAALgAECgMJAwAAAA==.',
['宇田']='宇田川亚子:BAABLgAFFH8PAAIFAAYJ1yAvAAANAgAFAAYJ1yAvAAANAgAAAA==.',
['宓鄢']='宓鄢婕:BAAALgAECggJDgAAAA==.',
['宸汐']='宸汐玥:BAAALgAECgMJAwAAAA==.宸汐緣:BAAALgAECgYJCwAAAA==.',
['寒丶']='寒丶愛廷:BAAALgAECgkJEAAAAA==.',
['小狐']='小狐狸丶:BAAALgAECgYJBwAAAA==.',
['小蜂']='小蜂:BAAALgAFFAIJAwAAAA==.',
['小豆']='小豆包丶:BAAALgAECgcJDAAAAA==.',
['小鱼']='小鱼灬小德:BAAALgAECgEJAQAAAA==.',
['巨無']='巨無霸:BAAALgAECgQJBAAAAA==.',
['市谷']='市谷有咲:BAABLgAFFH8HAAIFAAYJyh9DAAD2AQAFAAYJyh9DAAD2AQAAAA==.',
['布洛']='布洛芬:BAABLgAECn8aAAIJAAcJJSD4QAAiAgAJAAcJJSD4QAAiAgAAAA==.',
['帅不']='帅不帅:BAAALgAECgUJBQAAAA==.',
['廷丶']='廷丶宝:BAAALgAECgkJAQAAAA==.',
['弦卷']='弦卷心:BAABLgAFFH8LAAIFAAUJkiM/AgDmAQAFAAUJkiM/AgDmAQAAAA==.',
['往事']='往事已如煙:BAAALgAFFAIJAwABLgAFFAMJCQAEANUaAA==.',
['御剑']='御剑乘风去:BAAALgAECgEJAQAAAA==.',
['微风']='微风的记忆:BAAALgADCgYJCQABLgAECgYJCgAGAAAAAA==.',
['德不']='德不到阿祖:BAAALgADCgYJBgAAAA==.',
['德乄']='德乄克士:BAAALgAECgUJBQAAAA==.',
['怀恋']='怀恋小伴:BAAALgAECgMJAwAAAA==.',
['怜月']='怜月:BAAALgAFFAIJAgABLgAFFAMJCQAEANUaAA==.',
['恋月']='恋月:BAAALgAECgYJBgABLgAFFAMJCQAEANUaAA==.',
['恋語']='恋語:BAACLgAFFH8JAAIEAAMJ1RrfIQAQAQAEAAMJ1RrfIQAQAQAuAAQKfxwAAgQABwmVHXk/ADoCAAQABwmVHXk/ADoCAAAA.',
['恋语']='恋语:BAAALgAFFAIJAwABLgAFFAMJCQAEANUaAA==.',
['恶魔']='恶魔借手:BAAALgAFFAEJAQAAAA==.恶魔小鼠:BAAALgADCgYJBgAAAA==.',
['我将']='我将带头冲锋:BAABLgAFFH8HAAIKAAMJICKjAAA+AQAKAAMJICKjAAA+AQAAAA==.',
['我很']='我很菜别打我:BAAALgADCgYJBgAAAA==.',
['我有']='我有德宝宝:BAAALgAFFAIJAgABLgAFFAMJCQAEANUaAA==.',
['我跌']='我跌:BAAALgAECgIJAgABLgAFFAUJEwABAIgkAA==.',
['户山']='户山香澄:BAABLgAFFH8JAAIFAAUJYhweAwDEAQAFAAUJYhweAwDEAQAAAA==.',
['打你']='打你膝盖:BAAALgAECgEJAQABLgAFFAMJCQAEANUaAA==.',
['打死']='打死我算你狠:BAAALgAECggJCAAAAA==.',
['抓不']='抓不住阿祖:BAAALgAECgQJBAAAAA==.',
['抢地']='抢地盘奶奶:BAAALgAECgcJEQAAAA==.抢地盘奶妈:BAAALgAECgYJCwAAAA==.',
['换我']='换我漂漂拳:BAAALgAECgUJBwAAAA==.',
['无良']='无良道人:BAAALgADCgMJAwABLgAECgYJCgAGAAAAAA==.',
['星河']='星河:BAAALgAFFAEJAQAAAA==.',
['暧昧']='暧昧的喵咪:BAAALgAECgEJAQAAAA==.',
['月夜']='月夜泣魂:BAAALgAECgEJAgAAAA==.',
['朝日']='朝日六花:BAAALgAFFAYJAwAAAA==.',
['朝比']='朝比奈真冬:BAAALgAFFAEJAQAAAA==.',
['木有']='木有小丁丁:BAAALgAECgYJCgAAAA==.',
['李火']='李火旺:BAAALgAECgYJCAAAAA==.',
['李麻']='李麻子丶:BAAALgAECgYJCwAAAA==.',
['杰哥']='杰哥丶:BAAALgAECgcJAQAAAA==.',
['松原']='松原花音:BAABLgAFFH8HAAIFAAQJwSBnDAAfAQAFAAQJwSBnDAAfAQAAAA==.',
['桐谷']='桐谷透子:BAABLgAFFH8JAAIFAAUJJSPaAACtAQAFAAUJJSPaAACtAQAAAA==.',
['梦雪']='梦雪丶嫣然:BAAALgAECgkJDgAAAA==.',
['毁灭']='毁灭法:BAABLgAECn8WAAMLAAkJ5hNrLABdAgALAAkJ5hNrLABdAgAMAAMJzgQyTwCAAAAAAA==.',
['毒我']='毒我喜欢:BAAALgADCgIJAgAAAA==.',
['污师']='污师:BAAALgADCgIJAgAAAA==.',
['没死']='没死成的骑士:BAAALgAECgIJAwAAAA==.',
['法不']='法不择阿祖:BAAALgAECgcJDAAAAA==.',
['法爵']='法爵:BAAALgAECgEJAQAAAA==.',
['派派']='派派:BAAALgAECgYJCwAAAA==.',
['滚来']='滚来又滚去:BAAALgAECgQJBQAAAA==.',
['狂扁']='狂扁小朋友:BAAALgAECgYJBwABLgAECgcJCgAGAAAAAA==.',
['狗煎']='狗煎真红:BAABLgAECn8UAAINAAgJICFqCQD+AgANAAgJICFqCQD+AgAAAA==.',
['独剑']='独剑大侠:BAAALgAECgUJCQABLgAECgcJCgAGAAAAAA==.',
['玛卡']='玛卡巴卡:BAAALgAECgYJBgAAAA==.',
['痛苦']='痛苦术太痛苦:BAAALgAECgYJBgAAAA==.',
['白洁']='白洁:BAAALgADCgEJAQAAAA==.',
['白鹭']='白鹭千圣:BAABLgAFFH8KAAIFAAYJGSIuAAAOAgAFAAYJGSIuAAAOAgAAAA==.',
['破晓']='破晓流沙:BAAALgADCgUJBQAAAA==.',
['福禄']='福禄娃李槐:BAAALgADCgcJBwAAAA==.',
['穿肠']='穿肠毒:BAABLgAECn8YAAIOAAcJ0h3pEABaAgAOAAcJ0h3pEABaAgAAAA==.',
['竖心']='竖心旁的生:BAAALgAECgIJAgAAAA==.',
['竹节']='竹节香附:BAAALgAECgYJBgAAAA==.',
['米诺']='米诺绯:BAAALgAECgMJAwAAAA==.',
['绿了']='绿了:BAAALgAECgUJBgABLgAFFAUJEAAFAEofAA==.',
['美竹']='美竹兰:BAABLgAFFH8JAAIFAAUJ5SIlAgDrAQAFAAUJ5SIlAgDrAQAAAA==.',
['花园']='花园多惠:BAABLgAFFH8LAAIFAAYJDRvxBgB0AQAFAAYJDRvxBgB0AQAAAA==.',
['若宫']='若宫伊芙:BAABLgAFFH8JAAIFAAYJCSOeAABoAgAFAAYJCSOeAABoAgAAAA==.',
['莉亚']='莉亚德琳琳:BAAALgAECgYJEQAAAA==.',
['萌丨']='萌丨新:BAAALgAECgUJBgAAAA==.',
['落篱']='落篱:BAAALgAECgMJBgAAAA==.',
['街球']='街球王:BAABLgAECn8dAAIEAAkJDhuyHgDJAgAEAAkJDhuyHgDJAgAAAA==.',
['还有']='还有木有亡法:BAAALgAECgEJAQAAAA==.',
['进激']='进激的小萨满:BAAALgAECgIJAgAAAA==.',
['酸柠']='酸柠檬丶:BAAALgADCgcJBwAAAA==.',
['鎏晶']='鎏晶小德:BAAALgADCgcJBwAAAA==.',
['锤子']='锤子哥丶:BAAALgADCgYJBgAAAA==.',
['长崎']='长崎爽世:BAABLgAFFH8KAAIFAAUJyx81AQCaAQAFAAUJyx81AQCaAQAAAA==.',
['闑漦']='闑漦:BAAALgAECgUJBQAAAA==.',
['阿汐']='阿汐:BAAALgAECgkJCQAAAA==.',
['阿里']='阿里:BAAALgAECgYJCQAAAA==.',
['雪碧']='雪碧十一:BAAALgAECgYJBgAAAA==.',
['青叶']='青叶摩卡:BAAALgAFFAYJBAAAAA==.',
['韭菜']='韭菜和子:BAAALgAECgcJBwAAAA==.',
['顾方']='顾方亚:BAAALgAECgUJCwABLgAECgYJCwAGAAAAAA==.',
['高甜']='高甜美少女:BAAALgADCgUJBQAAAA==.',
['鬼眼']='鬼眼狂:BAAALgAECgUJCwAAAA==.',
['鳰原']='鳰原令王那:BAAALgAFFAQJAwAAAA==.',
['龙龙']='龙龙快放电:BAAALgAECgEJAQAAAA==.',
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
