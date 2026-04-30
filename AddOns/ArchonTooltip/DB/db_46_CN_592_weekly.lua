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

local lookup = {'Unknown-Unknown','DeathKnight-Unholy','Warlock-Demonology','Rogue-Outlaw','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Frost','Shaman-Restoration','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','DemonHunter-Havoc','Paladin-Holy','Priest-Shadow','Priest-Discipline','Priest-Holy','Paladin-Retribution','Rogue-Subtlety','DemonHunter-Devourer','Mage-Frost','Druid-Restoration','Druid-Balance','Druid-Guardian','Warrior-Fury','Warrior-Protection','Mage-Arcane','Monk-Windwalker','Paladin-Protection','Druid-Feral','Shaman-Elemental','Monk-Mistweaver','Monk-Brewmaster','Shaman-Enhancement','Warrior-Arms','Monk-Any','Warlock-Destruction',}
local provider = {region='CN',realm='加尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={As='Asuna:BAAALgAFFAIJAgAAAA==.',
Ba='Babyssi:BAAALgAECgYJBgABLgAFFAQJBAABAAAAAA==.',
Be='Bergmite:BAAALgAECgUJBgAAAA==.',
Ca='Carryall:BAAALgAECgYJCgAAAA==.',
Co='Cottonball:BAAALgADCgkJCQAAAA==.',
Dd='Ddandkk:BAAALgADCgYJBgAAAA==.',
De='Deley:BAAALgAECgEJAgABLgAFFAQJAgABAAAAAA==.Despair:BAAALgAECgYJBgAAAA==.',
Dh='Dhqaq:BAAALgAECgkJDgAAAA==.',
El='Elementshama:BAAALgAECgkJCQAAAA==.',
Fa='Fairylewis:BAABLgAFFH8GAAICAAMJbhRbKQD0AAACAAMJbhRbKQD0AAAAAA==.',
Fe='Fenix:BAAALgAECgMJAwAAAA==.',
Gi='Gilgamesh:BAAALgADCgEJAQAAAA==.',
Gu='Gulda:BAABLgAFFH8EAAIDAAIJMhXrNACpAAADAAIJMhXrNACpAAABLgAFFAEJAQABAAAAAA==.Gurren:BAAALgAFFAEJAQAAAA==.',
Ic='Icet:BAAALgAECgEJAQAAAA==.',
Ka='Karenlol:BAAALgADCgEJAQAAAA==.',
Ko='Kokoro:BAAALgADCgYJBwAAAA==.',
Ku='Kumo:BAAALgAFFAUJBAABLgAFFAcJBAABAAAAAA==.',
La='Landrovera:BAAALgADCgEJAQAAAA==.',
Li='Liangev:BAAALgAECgYJBgAAAA==.',
Ls='Lsabellae:BAAALgAECgIJAQAAAA==.',
Mo='Morecolor:BAAALgAECgUJBQAAAA==.',
Mu='Muffin:BAABLgAFFH8KAAIEAAQJdSVgAABWAQAEAAQJdSVgAABWAQAAAA==.',
Ne='Neverjab:BAAALgAECgEJAgAAAA==.',
Pa='Pain:BAAALgAECgYJDQAAAA==.Panicbubble:BAAALgAECgEJAQABLgAECgYJBAABAAAAAA==.',
Re='Rei:BAAALgADCgMJAwAAAA==.',
Ri='Riandh:BAAALgAFFAMJAwAAAA==.Riandk:BAAALgAECgMJAgAAAA==.Rianevok:BAAALgAFFAIJAgABLgAFFAMJAwABAAAAAA==.',
Ro='Robinhood:BAABLgAECn8VAAMFAAgJjx7xFwB6AgAFAAgJjx7xFwB6AgAGAAEJYQC7mgAXAAAAAA==.',
Sh='Shihuai:BAACLgAFFH8KAAMCAAQJEhsjCwB6AQACAAQJEhsjCwB6AQAHAAEJoAr2AwBWAAAuAAQKfxsAAwIACAlpHVstAIMCAAIACAlpHVstAIMCAAcAAwmFHGoFALQAAAAA.Shootass:BAAALgAECgcJDQAAAA==.',
St='Styxer:BAAALgAECgkJCQAAAA==.',
To='Torontotokyo:BAAALgAECgYJBwAAAA==.',
Tu='Tulip:BAABLgAFFH8GAAIIAAMJ5AHEFAC0AAAIAAMJ5AHEFAC0AAAAAA==.',
Vu='Vue:BAACLgAFFH8IAAIJAAMJSgooDwDiAAAJAAMJSgooDwDiAAAuAAQKfxgABAkABwlVGkESABsCAAkABwlVGkESABsCAAoABgmAFmooAHoBAAsAAQlhIM83AFkAAAAA.',
Wa='Wamlf:BAAALgAECgkJCAAAAA==.',
We='Weakness:BAAALgADCgEJAQAAAA==.Weyue:BAAALgAFFAEJAQAAAA==.',
Wi='Wisteria:BAAALgAECgYJDwAAAA==.',
Ws='Wsncg:BAAALgAECgYJDQAAAA==.',
Xi='Xihuanzhege:BAAALgAECgUJCAAAAA==.',
Ya='Yakusoku:BAAALgADCgMJAwAAAA==.',
Yo='Yoke:BAAALgAFFAIJBAAAAA==.',
Zo='Zombied:BAAALgAECgEJAQAAAA==.',
['一伊']='一伊蓝妮一:BAAALgAECgIJAgAAAA==.',
['一刀']='一刀团灭:BAAALgADCgEJAQAAAA==.',
['一方']='一方通行:BAAALgAECgUJBQAAAA==.',
['一生']='一生随风:BAAALgADCgEJAQAAAA==.',
['一眼']='一眼见你:BAABLgAECn8UAAIMAAgJvRfDEgBCAgAMAAgJvRfDEgBCAgAAAA==.',
['万物']='万物有灵:BAAALgAECgkJDgAAAA==.',
['万箭']='万箭川心:BAAALgAECgEJAQAAAA==.',
['三粗']='三粗:BAAALgAECgcJCAAAAA==.',
['上帝']='上帝化身:BAACLgAFFH8OAAINAAQJsSAsAgCEAQANAAQJsSAsAgCEAQAuAAQKfxgAAg0ACAnOHzwPAJsCAA0ACAnOHzwPAJsCAAAA.',
['不会']='不会暗牧:BAACLgAFFH8HAAIOAAMJoxgSCgATAQAOAAMJoxgSCgATAQAuAAQKfyAAAw4ACAkkHE4OAJ4CAA4ACAkkHE4OAJ4CAA8ABQnsC/UxABEBAAAA.',
['不落']='不落要塞:BAAALgAECgEJAQAAAA==.',
['严二']='严二哥:BAAALgAECgQJBAAAAA==.',
['丨婲']='丨婲丶無惢灬:BAAALgAFFAEJAQAAAA==.',
['丨张']='丨张哥丨:BAAALgAFFAIJAwAAAA==.',
['丫皮']='丫皮丫皮:BAAALgAECgcJCgAAAA==.',
['丶男']='丶男大:BAAALgAECgYJCwABLgAECggJDQABAAAAAA==.',
['丶艾']='丶艾尔莎:BAAALgAECgMJAwAAAA==.',
['丿紅']='丿紅手灬娃娃:BAAALgADCgYJBgAAAA==.',
['乃飞']='乃飞天:BAABLgAFFH8FAAIQAAMJ+hpjBwD5AAAQAAMJ+hpjBwD5AAAAAA==.',
['乱红']='乱红灬:BAABLgAECn8fAAIRAAgJ7SMHDQAlAwARAAgJ7SMHDQAlAwAAAA==.',
['二月']='二月二十:BAACLgAFFH8JAAIRAAQJ4RfaCAAGAQARAAQJ4RfaCAAGAQAuAAQKfxcAAhEACAmcIH0XANwCABEACAmcIH0XANwCAAAA.',
['云云']='云云早安:BAAALgADCgQJBAAAAA==.',
['云朵']='云朵:BAAALgAECgMJBwAAAA==.',
['云来']='云来启豪:BAAALgAECgYJEAAAAA==.',
['云琅']='云琅:BAAALgADCgYJBgAAAA==.',
['亚娃']='亚娃些:BAACLgAFFH8FAAISAAMJARuTDAAbAQASAAMJARuTDAAbAQAuAAQKfxkAAhIABwklIk4NAMYCABIABwklIk4NAMYCAAAA.',
['亲爱']='亲爱的男妈妈:BAAALgAECgEJAQAAAA==.',
['仙小']='仙小剑:BAAALgADCgEJAQAAAA==.',
['以德']='以德扶人:BAAALgAECgQJBAAAAA==.',
['仿古']='仿古式邪恶:BAAALgADCgUJBQAAAA==.',
['伊藤']='伊藤美来:BAAALgAECgEJAQAAAA==.伊藤诚:BAAALgAECgYJBgAAAA==.',
['传说']='传说的蛋糕:BAAALgAECgMJDAAAAA==.',
['低调']='低调伤:BAACLgAFFH8FAAIFAAIJVRokCwDCAAAFAAIJVRokCwDCAAAuAAQKfxsAAwUACAlGH0IUAJQCAAUABwnpH0IUAJQCAAYABgnEHAowALIBAAAA.',
['佛曰']='佛曰不可说:BAAALgAFFAEJAQAAAA==.',
['俄罗']='俄罗斯小驼鹿:BAAALgADCgYJCAAAAA==.',
['光明']='光明战神:BAAALgAECgYJCgAAAA==.',
['兔神']='兔神:BAAALgAECgcJBAAAAA==.',
['八千']='八千流丶:BAAALgAECgUJCwAAAA==.',
['公正']='公正杀生:BAAALgAECgkJBAAAAA==.',
['六爷']='六爷有赏:BAABLgAECn8VAAITAAYJzQ+VegA4AQATAAYJzQ+VegA4AQAAAA==.',
['再看']='再看你一眼:BAAALgAECgcJAwAAAA==.',
['冫冰']='冫冰冰:BAAALgAECgYJBwAAAA==.',
['冰封']='冰封战将:BAABLgAECn8eAAIRAAgJjRvVBwANAgARAAgJjRvVBwANAgAAAA==.',
['冷祤']='冷祤:BAAALgAECgYJBgAAAA==.',
['冻梨']='冻梨:BAAALgADCgIJAgAAAA==.',
['凋零']='凋零之血:BAAALgAECgUJBQAAAA==.',
['凛冬']='凛冬又逢精灵:BAAALgAFFAIJAwAAAA==.',
['凯妹']='凯妹儿:BAAALgAECgEJAQAAAA==.',
['凯爷']='凯爷的婷小乖:BAAALgAECgEJAQAAAA==.',
['刺眼']='刺眼丶:BAAALgAECgMJBgAAAA==.',
['剑心']='剑心犹在丶:BAAALgAECgEJAQAAAA==.剑心血影:BAACLgAFFH8JAAIRAAQJBhjRCABqAQARAAQJBhjRCABqAQAuAAQKfyMAAhEACQl1HwwHAGADABEACQl1HwwHAGADAAAA.',
['劇丶']='劇丶終:BAAALgAECgYJEQAAAA==.',
['劫机']='劫机女船长:BAAALgADCgUJBQAAAA==.',
['勇者']='勇者不惧:BAAALgADCggJCAAAAA==.',
['化和']='化和非:BAABLgAFFH8FAAIUAAMJkRpEJwAWAQAUAAMJkRpEJwAWAQAAAA==.',
['千均']='千均猎神:BAAALgAECgMJAwAAAA==.',
['千纱']='千纱:BAAALgAECgYJBgAAAA==.',
['千钧']='千钧幻神:BAAALgAECgYJBgAAAA==.千钧雷神:BAAALgAECgQJBAAAAA==.',
['半把']='半把刀:BAAALgAFFAEJAQAAAA==.',
['半神']='半神赎的罪四:BAAALgAFFAQJBAAAAA==.',
['华法']='华法林:BAAALgAECgYJAQAAAA==.',
['卡申']='卡申夫鬼美人:BAAALgAECgUJCAAAAA==.',
['卧梅']='卧梅幽闻花灬:BAAALgAECgQJBQAAAA==.',
['压力']='压力怪:BAAALgAECgYJBgAAAA==.',
['厨子']='厨子:BAAALgAFFAEJAQAAAA==.',
['发财']='发财哥哥:BAAALgAECgYJDAAAAA==.',
['叫我']='叫我二六三:BAAALgAECgIJAwAAAA==.',
['可口']='可口又可乐:BAAALgAECgEJAQAAAA==.',
['可爱']='可爱希宝:BAAALgAECgkJDAAAAA==.',
['叱咤']='叱咤:BAAALgADCgEJAQAAAA==.',
['叶子']='叶子:BAAALgADCgUJBQAAAA==.',
['后天']='后天灬:BAAALgAFFAIJAgAAAA==.',
['君看']='君看一叶舟:BAAALgADCgEJAQAAAA==.',
['吾建']='吾建超世志:BAAALgAECgMJAwAAAA==.',
['吾绝']='吾绝:BAAALgAECgUJBQAAAA==.',
['周慧']='周慧敏:BAAALgAECgEJAQAAAA==.',
['呼延']='呼延大观:BAAALgADCgIJAgAAAA==.',
['命运']='命运融合:BAABLgAECn8XAAQVAAcJ1xjeLwDsAQAVAAcJ1xjeLwDsAQAWAAQJyBgTVgDMAAAXAAIJKQ2ZLABEAAABLgAFFAUJEAAUAIAjAA==.',
['咕噜']='咕噜咕噜肉:BAAALgAECgkJEAAAAA==.咕噜噜一:BAAALgADCgEJAQAAAA==.',
['咬人']='咬人丶猫:BAAALgAFFAEJAQABLgAFFAUJBwAUAMcZAA==.',
['哈莉']='哈莉路亚:BAAALgADCgEJAQAAAA==.',
['哥会']='哥会隐身:BAAALgADCgEJAQAAAA==.',
['哦黑']='哦黑呀哦黑呀:BAACLgAFFH8FAAIDAAMJdgzgNwCkAAADAAMJdgzgNwCkAAAuAAQKfygAAgMACAnGFh8JAN8BAAMACAnGFh8JAN8BAAAA.',
['唐十']='唐十八:BAAALgAECgUJBQAAAA==.',
['唤星']='唤星者:BAAALgAECgYJBQAAAA==.',
['唯有']='唯有我醉诳:BAAALgADCgUJBQAAAA==.',
['啪啪']='啪啪火锅超人:BAABLgAFFH8HAAIUAAUJHQe7IQA5AQAUAAUJHQe7IQA5AQAAAA==.',
['喜欢']='喜欢奶茶:BAABLgAECn8UAAIUAAkJTx4vFgAkAwAUAAkJTx4vFgAkAwAAAA==.',
['喷喷']='喷喷超人:BAABLgAFFH8FAAIYAAQJ4gDUEwDfAAAYAAQJ4gDUEwDfAAAAAA==.',
['回锅']='回锅肉:BAAALgADCgUJBQAAAA==.',
['图谋']='图谋:BAAALgAECgEJAQAAAA==.',
['土生']='土生土长:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光永恒:BAAALgAECgcJDAAAAA==.圣光鄙视你:BAAALgAECgEJAQAAAA==.',
['地狱']='地狱圣光:BAACLgAFFH8HAAIIAAMJ7xR+DwDsAAAIAAMJ7xR+DwDsAAAuAAQKfxkAAggACQmCF9ERAIgCAAgACQmCF9ERAIgCAAAA.',
['埃萌']='埃萌丶剃:BAAALgAECgMJAwAAAA==.',
['塔塔']='塔塔荔娅:BAAALgAECgEJAgAAAA==.',
['夏杰']='夏杰克:BAAALgAECgcJDQAAAA==.',
['夜不']='夜不曰:BAAALgAECgMJAwAAAA==.',
['大力']='大力真武:BAAALgAFFAIJAgAAAA==.',
['大堂']='大堂吧的小号:BAAALgADCgEJAQAAAA==.',
['大米']='大米西西弗:BAAALgAECgEJAQAAAA==.',
['大萨']='大萨满:BAAALgADCgEJAQABLgAECgQJCQABAAAAAA==.',
['大雨']='大雨嘻嘻哈哈:BAAALgADCgMJAwAAAA==.',
['天手']='天手力:BAAALgAECgkJEAABLgAFFAYJEwAZAC8ZAA==.',
['天火']='天火圣裁:BAABLgAFFH8KAAIRAAMJ9BiPFAAEAQARAAMJ9BiPFAAEAQAAAA==.',
['天蝎']='天蝎座丨觉醒:BAABLgAFFH8FAAMUAAMJiAr/HQCbAAAUAAMJiAr/HQCbAAAaAAEJ+wAZAgA9AAAAAA==.',
['天賜']='天賜淡雅香:BAAALgAECgIJAgAAAA==.',
['好哥']='好哥哥组我吖:BAABLgAFFH8KAAIGAAUJriCbAwANAgAGAAUJriCbAwANAgAAAA==.',
['好爱']='好爱晒太阳:BAAALgAFFAEJAQAAAA==.',
['妹妹']='妹妹的黑洞:BAAALgADCgUJBQAAAA==.',
['姑苏']='姑苏猪猪酱:BAABLgAFFH8GAAIDAAQJAQOcHQAOAQADAAQJAQOcHQAOAQAAAA==.',
['威兹']='威兹班:BAAALgAFFAMJBAAAAA==.',
['安世']='安世集团:BAAALgADCgUJBQAAAA==.',
['宝塔']='宝塔鎭河妖:BAAALgAECgIJAgAAAA==.',
['寧德']='寧德:BAAALgAECgEJAQAAAA==.',
['寻找']='寻找流星落丶:BAAALgAECgYJBgAAAA==.',
['小牧']='小牧牧:BAAALgAECgYJDAAAAA==.',
['小绿']='小绿人:BAAALgAFFAIJBAAAAA==.',
['尛乄']='尛乄怪兽:BAABLgAFFH8KAAIUAAQJLg0WIABGAQAUAAQJLg0WIABGAQAAAA==.',
['巴巴']='巴巴输出啊:BAAALgAFFAQJAQAAAA==.',
['巴索']='巴索罗米熊:BAAALgAECgEJAQAAAA==.',
['布洛']='布洛橡木:BAAALgAFFAQJAwAAAA==.',
['布艾']='布艾夏维奇:BAAALgAECgMJAwAAAA==.',
['布莱']='布莱恩丶铜须:BAAALgAFFAIJAwAAAA==.',
['布都']='布都御魂:BAAALgAECgYJBgAAAA==.',
['希尔']='希尔灬格瓦斯:BAAALgAECgEJAgAAAA==.',
['帽丶']='帽丶子:BAAALgAECgMJBQAAAA==.',
['库兹']='库兹马:BAABLgAFFH8FAAICAAQJiQBmKwDtAAACAAQJiQBmKwDtAAAAAA==.',
['张全']='张全蛋:BAAALgAECgYJBgAAAA==.',
['強力']='強力炮台:BAACLgAFFH8OAAIWAAUJmh2nAgDUAQAWAAUJmh2nAgDUAQAuAAQKfxsAAxYACAkeJRIFAE8DABYACAkeJRIFAE8DABUAAwnCE0IjAJkAAAAA.',
['强力']='强力炮台:BAACLgAFFH8IAAIUAAQJQhOiGwBcAQAUAAQJQhOiGwBcAQAuAAQKfxQAAhQABwmjI+w1AJwCABQABwmjI+w1AJwCAAAA.',
['强壮']='强壮的盘龙:BAAALgADCgIJAgAAAA==.',
['彭于']='彭于晏都不急:BAAALgAFFAEJAQAAAA==.',
['影竹']='影竹:BAAALgADCgIJAgAAAA==.',
['心武']='心武:BAABLgAFFH8HAAIbAAMJ9CRQBABQAQAbAAMJ9CRQBABQAQAAAA==.',
['必至']='必至无上道:BAAALgAECgUJBQAAAA==.',
['忘掉']='忘掉种過的花:BAAALgAECgUJBQAAAA==.',
['忧郁']='忧郁的小浣熊:BAACLgAFFH8JAAIJAAQJdSZeAwDSAQAJAAQJdSZeAwDSAQAuAAQKfxYAAgkABwksJo4EAAgDAAkABwksJo4EAAgDAAAA.',
['忿怒']='忿怒的小浣熊:BAAALgAFFAIJAgABLgAFFAQJCQAJAHUmAA==.',
['恩希']='恩希宝宝:BAAALgAECgEJAgAAAA==.',
['恶魔']='恶魔大小子:BAAALgAECgQJBAAAAA==.',
['情人']='情人:BAAALgAECgYJDwABLgAFFAQJCgAcAGABAA==.',
['惩戒']='惩戒琪:BAAALgAECgEJAQAAAA==.',
['感时']='感时花溅泪丶:BAAALgAECgUJBgAAAA==.',
['慵懒']='慵懒的小浣熊:BAAALgAFFAEJAQABLgAFFAQJCQAJAHUmAA==.',
['憎恶']='憎恶屠夫:BAAALgAECgEJAQAAAA==.',
['憮心']='憮心:BAACLgAFFH8KAAIcAAQJYAEkBQB1AAAcAAQJYAEkBQB1AAAuAAQKfyQAAhwACAmBBhYdACIBABwACAmBBhYdACIBAAAA.',
['成功']='成功的法爷:BAAALgAECgUJCAAAAA==.',
['我不']='我不做人垃:BAAALgADCgUJBQAAAA==.',
['我会']='我会骗你么:BAAALgADCgYJBgAAAA==.',
['我好']='我好红啊:BAAALgAECgUJBQAAAA==.',
['我是']='我是愤怒:BAAALgAECgYJBgAAAA==.',
['我来']='我来给你电疗:BAAALgADCgYJBgAAAA==.',
['我还']='我还没准备好:BAAALgAFFAEJAQAAAA==.',
['戦哥']='戦哥:BAAALgAECgQJBAAAAA==.',
['打发']='打发时间:BAAALgAECgUJBQAAAA==.',
['折断']='折断的铅笔:BAAALgAECgQJBQAAAA==.',
['拉西']='拉西梅黛子:BAAALgADCgEJAQAAAA==.',
['招灾']='招灾:BAAALgAECgYJBgAAAA==.',
['拽根']='拽根丶:BAAALgAECgYJBgAAAA==.',
['挚爱']='挚爱接触:BAACLgAFFH8QAAIUAAUJgCMMBwDvAQAUAAUJgCMMBwDvAQAuAAQKfx4AAhQACAlwJUsNAFsDABQACAlwJUsNAFsDAAAA.',
['捍卫']='捍卫丶泰山:BAABLgAFFH8KAAITAAQJdxZzDwBSAQATAAQJdxZzDwBSAQAAAA==.捍卫泰山丶:BAABLgAFFH8LAAICAAQJahicEgBXAQACAAQJahicEgBXAQAAAA==.',
['支付']='支付宝:BAAALgAECgYJCQAAAA==.',
['敌羞']='敌羞去脱她依:BAAALgADCgEJAQAAAA==.',
['救人']='救人医命:BAABLgAECn8WAAIRAAgJQhWaQQAgAgARAAgJQhWaQQAgAgAAAA==.',
['斬龍']='斬龍者龍馬:BAAALgAECgYJCAAAAA==.',
['断桥']='断桥残雪丶:BAAALgAECgYJDAAAAA==.',
['斯塔']='斯塔西司:BAAALgADCgYJBgAAAA==.',
['方梵']='方梵:BAAALgAFFAQJBAAAAA==.',
['施主']='施主请留步:BAAALgAECgUJBQAAAA==.',
['旅店']='旅店老板:BAAALgAECgUJBQAAAA==.',
['旋风']='旋风小小:BAAALgAECgYJCAAAAA==.',
['无敌']='无敌小黄花:BAAALgAECgEJAgAAAA==.无敌炉石:BAAALgAECgcJDQAAAA==.',
['既往']='既往丶:BAAALgAECgYJCQAAAA==.',
['时砾']='时砾逐光丶:BAAALgAECgYJBwAAAA==.',
['昆爷']='昆爷:BAAALgADCgEJAQAAAA==.',
['明知']='明知做戏:BAAALgAECgcJCAAAAA==.',
['明镜']='明镜亦非台丶:BAAALgAECgMJAwAAAA==.',
['時光']='時光流转:BAAALgAECgcJDwAAAA==.時光荏苒:BAAALgAECgcJCAAAAA==.',
['晓月']='晓月圆舞曲:BAAALgAECgYJCAAAAA==.',
['暗淡']='暗淡晨星:BAABLgAECn8jAAIQAAgJ6R4GDwBwAgAQAAgJ6R4GDwBwAgAAAA==.',
['暗黑']='暗黑古天樂:BAAALgAECgYJBgAAAA==.',
['暮烟']='暮烟沉雲:BAAALgAECgEJAQAAAA==.',
['暴躁']='暴躁的小旭旭:BAAALgAECgEJAQAAAA==.',
['曉棄']='曉棄:BAAALgAECgEJAQAAAA==.',
['曉義']='曉義:BAAALgADCgMJAwAAAA==.',
['曾小']='曾小满:BAAALgAECgYJCgAAAA==.',
['替行']='替行者:BAACLgAFFH8MAAIWAAQJUhs8BwBvAQAWAAQJUhs8BwBvAQAuAAQKfxcABBYABwlWIywRAJQCABYABwnZICwRAJQCAB0AAgkKJEMiAMcAABUAAQkqDtHXACkAAAAA.',
['最初']='最初的梦:BAAALgAECgcJBwAAAA==.',
['月影']='月影妖娆:BAAALgAECgEJAQAAAA==.',
['朱莉']='朱莉叶奈奈子:BAAALgAECgYJBwAAAA==.',
['杨主']='杨主官:BAABLgAECn8XAAINAAgJoRZlGwA5AgANAAgJoRZlGwA5AgAAAA==.',
['杨肉']='杨肉丝:BAAALgAECgYJCQAAAA==.',
['板逼']='板逼长玩:BAAALgADCgQJAQAAAA==.',
['极品']='极品妹纸:BAAALgAECgMJAwAAAA==.',
['极影']='极影:BAAALgAECgcJBwAAAA==.',
['柯雨']='柯雨:BAAALgAECgcJDAABLgAFFAUJCQAQANkZAA==.',
['梁大']='梁大状:BAACLgAFFH8MAAIeAAUJRxc5CABXAQAeAAUJRxc5CABXAQAuAAQKfxsAAh4ACAmgIMMMANECAB4ACAmgIMMMANECAAAA.',
['横扫']='横扫一条街霸:BAAALgADCgMJAwAAAA==.',
['橙哆']='橙哆哆:BAAALgAECgMJBQAAAA==.',
['欢乐']='欢乐时光开始:BAACLgAFFH8KAAIWAAQJsxukBwBnAQAWAAQJsxukBwBnAQAuAAQKfxQAAhYACAmwF30kANkBABYACAmwF30kANkBAAAA.',
['欧拉']='欧拉好猫:BAACLgAFFH8HAAIfAAMJyh2aCgABAQAfAAMJyh2aCgABAQAuAAQKfx0AAx8ACQkvHugOAGkCAB8ACQkvHugOAGkCABsAAQnkA9aLACAAAAAA.',
['欧皇']='欧皇大叔:BAAALgAECgYJBgAAAA==.',
['正能']='正能量传递员:BAAALgAECgMJBwAAAA==.',
['死亡']='死亡献祭丶:BAAALgAECgYJCgAAAA==.',
['死神']='死神一:BAAALgAFFAIJAgAAAA==.死神三:BAAALgAFFAQJBAAAAA==.死神二:BAAALgAFFAQJBAAAAA==.',
['死肥']='死肥猫丶:BAAALgAECgYJBgAAAA==.',
['残兵']='残兵败将:BAAALgAECgQJCQAAAA==.',
['毕云']='毕云焘:BAAALgAECgYJBAAAAA==.',
['江阳']='江阳酒徒:BAAALgAECgEJAQAAAA==.',
['汤不']='汤不哩啵啵丶:BAAALgAECgEJAwAAAA==.',
['油炸']='油炸亲菇:BAAALgAECgEJAgAAAA==.',
['法号']='法号丶日天:BAAALgAECgUJAgAAAA==.',
['法型']='法型很酷:BAAALgADCgIJAgAAAA==.',
['波杜']='波杜希蒂:BAAALgADCggJDgAAAA==.',
['泯灭']='泯灭丶:BAAALgAECgMJBQAAAA==.',
['洛洛']='洛洛闪:BAAALgADCgEJAQAAAA==.',
['洪柒']='洪柒:BAAALgAECgIJAwAAAA==.',
['派大']='派大星超人:BAAALgAECgkJCQAAAA==.',
['流沙']='流沙不是河:BAAALgAECgcJCQAAAA==.',
['海瑶']='海瑶心:BAAALgAECgkJBgAAAA==.',
['深夜']='深夜冰兰:BAAALgADCggJCAAAAA==.',
['清雾']='清雾:BAAALgAECgYJCwAAAA==.',
['温也']='温也:BAAALgAECgIJAgAAAA==.',
['湖上']='湖上迷雾森森:BAAALgAECgYJCwAAAA==.',
['溟间']='溟间大白兔:BAAALgADCgUJBQAAAA==.',
['溯雪']='溯雪微寒:BAAALgADCgIJAgAAAA==.',
['演的']='演的好辛苦:BAAALgAECgkJCQAAAA==.',
['漠离']='漠离殇:BAAALgADCgEJAgAAAA==.',
['濑户']='濑户环奈:BAAALgAECgEJAQAAAA==.',
['灬海']='灬海绵宝宝灬:BAAALgAECgUJCQAAAA==.',
['灬西']='灬西柚:BAAALgAFFAEJAQAAAA==.',
['灰掌']='灰掌丶影:BAAALgAECgEJAQABLgAECgQJCQABAAAAAA==.',
['灰烬']='灰烬之地:BAAALgADCgUJBQAAAA==.',
['灵儿']='灵儿的逍遥哥:BAABLgAFFH8GAAIgAAMJ9hNCEgDpAAAgAAMJ9hNCEgDpAAAAAA==.',
['点苍']='点苍风:BAAALgAECgEJAQAAAA==.',
['炽天']='炽天使加百:BAAALgAECgUJBQAAAA==.',
['烙印']='烙印之光:BAAALgAECgMJAwAAAA==.',
['烟雨']='烟雨丶:BAAALgAECgYJBgAAAA==.烟雨戏青峰丶:BAAALgAECgYJBAAAAA==.',
['烧烤']='烧烤土豆:BAAALgAECgEJAQAAAA==.',
['烬斯']='烬斯讠恋恋:BAABLgAECn8XAAICAAcJBhSebACxAQACAAcJBhSebACxAQAAAA==.',
['熊之']='熊之哀木涕:BAAALgAECgYJDgAAAA==.',
['熊掌']='熊掌门:BAAALgADCgEJAQAAAA==.',
['熊的']='熊的力量丶:BAAALgAECgQJBQAAAA==.',
['爱鉨']='爱鉨第一名:BAAALgAECgMJAwAAAA==.',
['牧有']='牧有圣光:BAAALgADCgEJAQAAAA==.',
['狂怒']='狂怒之雷:BAACLgAFFH8KAAIZAAQJYQ3uBQAMAQAZAAQJYQ3uBQAMAQAuAAQKfygAAhkACQl1GZwJAH8CABkACQl1GZwJAH8CAAAA.',
['狂暴']='狂暴战灬:BAAALgADCgIJAgAAAA==.',
['狐说']='狐说八道:BAAALgAECgIJAgAAAA==.',
['独僾']='独僾箐:BAAALgAECgYJBgAAAA==.',
['狮子']='狮子摸摸:BAACLgAFFH8KAAIUAAQJ1wmYHwBKAQAUAAQJ1wmYHwBKAQAuAAQKfyoAAhQACAn2GvsHACkCABQACAn2GvsHACkCAAAA.',
['猎心']='猎心:BAAALgAECgcJCQAAAA==.',
['猫咪']='猫咪会武术:BAAALgADCgEJAQAAAA==.',
['猫眼']='猫眼林克:BAAALgAECgcJCwAAAA==.',
['王嘉']='王嘉尔:BAAALgAECgIJAgAAAA==.',
['王小']='王小当:BAAALgAECgIJAgAAAA==.',
['王比']='王比利:BAAALgAECgQJBgAAAA==.',
['玩命']='玩命兽:BAACLgAFFH8KAAIYAAQJlgvbBgDxAAAYAAQJlgvbBgDxAAAuAAQKfx4AAhgACAnTF00oABwCABgACAnTF00oABwCAAAA.',
['玫瑰']='玫瑰色的你:BAAALgAECgEJAgAAAA==.',
['琳菇']='琳菇凉:BAAALgAECgIJAgAAAA==.',
['琻丶']='琻丶典:BAAALgAECgEJAQAAAA==.',
['生来']='生来为战:BAAALgAECgMJAwAAAA==.',
['甬之']='甬之东猎西渔:BAAALgAECgkJCQABLgAECgkJDwABAAAAAA==.',
['电打']='电打鱼:BAACLgAFFH8FAAIeAAMJIAryEADnAAAeAAMJIAryEADnAAAuAAQKfyIABCEACAlhHVkIAFsCACEABwk1H1kIAFsCAB4ACAlQGiwbADkCAAgAAQk9FueXAEAAAAAA.',
['电烤']='电烤塔布羊:BAAALgAECgQJBQABLgAFFAcJGQAeAJEdAA==.',
['白色']='白色灬宁静:BAAALgAECgEJAgAAAA==.',
['相门']='相门戴羽彤:BAABLgAFFH8HAAIUAAUJjAXAEwB8AQAUAAUJjAXAEwB8AQAAAA==.',
['看大']='看大牛:BAAALgAECgYJBgAAAA==.',
['瞧尔']='瞧尔萨斯:BAAALgAECgUJBgAAAA==.',
['瞬晰']='瞬晰回忆:BAABLgAECn8kAAMiAAcJehRRAwCEAQAYAAcJ+A7hQAChAQAiAAcJXhRRAwCEAQAAAA==.',
['碎依']='碎依语:BAABLgAFFH8HAAMQAAMJSgf3DgCGAAAQAAIJBgn3DgCGAAAPAAEJ0QObGgBFAAAAAA==.',
['神丨']='神丨德:BAAALgAECgMJAwAAAA==.',
['神级']='神级打酱油:BAAALgAECgYJCAAAAA==.',
['神经']='神经丶:BAAALgAECgQJBwAAAA==.',
['神铁']='神铁加鲁鲁:BAAALgAECggJCAAAAA==.',
['祸靈']='祸靈夢丶:BAAALgAECgYJCAAAAA==.',
['科尔']='科尔努诺斯:BAAALgAECgUJBwAAAA==.',
['究级']='究级发神:BAAALgAECgYJEQAAAA==.',
['窝腰']='窝腰烟牌:BAABLgAFFH8LAAICAAQJER92GABDAQACAAQJER92GABDAQAAAA==.',
['立地']='立地成佛:BAAALgADCgUJBQAAAA==.',
['符文']='符文骑士:BAAALgAFFAIJBAAAAA==.',
['第三']='第三种绝色:BAAALgAECgYJBwAAAA==.',
['米麗']='米麗:BAAALgAECgUJBQAAAA==.',
['粉红']='粉红跳跳弹:BAAALgAECgEJAQAAAA==.',
['粪海']='粪海蝶泳:BAAALgAECgQJBQAAAA==.',
['糖醋']='糖醋排骨丶:BAAALgAECgYJBgAAAA==.糖醋椒盐里脊:BAAALgAFFAQJAQAAAA==.',
['紫枫']='紫枫兰:BAAALgAECgMJAwAAAA==.',
['細嗅']='細嗅蔷薇:BAAALgAECgEJAwAAAA==.',
['红乄']='红乄为你而战:BAABLgAFFH8FAAIZAAIJXQkmDQB5AAAZAAIJXQkmDQB5AAAAAA==.',
['红叶']='红叶知秋:BAAALgAECgYJBgAAAA==.',
['红烧']='红烧霸王羊:BAAALgAFFAQJBAAAAA==.',
['红牛']='红牛维生素:BAAALgADCgcJBwAAAA==.',
['纯情']='纯情:BAAALgAECgEJAQAAAA==.',
['纷丶']='纷丶纷:BAAALgADCgUJBQAAAA==.',
['细细']='细细粒:BAAALgAECgYJBgAAAA==.',
['绵呀']='绵呀棉丶:BAAALgAECgYJDQAAAA==.',
['羽梦']='羽梦:BAAALgADCgIJAgAAAA==.',
['翻滚']='翻滚糯米:BAAALgAECgYJBQAAAA==.',
['耶梦']='耶梦加得:BAAALgAECgYJBgAAAA==.',
['聖光']='聖光古天樂:BAAALgAECgMJBgAAAA==.',
['肉感']='肉感帅哥:BAAALgAECgMJAwAAAA==.',
['脓包']='脓包超人:BAAALgAECgQJBgAAAA==.',
['自在']='自在的瓶子:BAAALgADCgUJBQAAAA==.',
['舔血']='舔血恶魔:BAAALgADCgUJBQAAAA==.',
['芒果']='芒果依然:BAAALgAECgIJAwAAAA==.',
['花花']='花花蹄子:BAAALgAECgQJBAAAAA==.',
['苏不']='苏不离:BAAALgAECgQJBAAAAA==.',
['若兰']='若兰暮雪:BAAALgAFFAIJAwAAAA==.',
['范丷']='范丷海辛:BAACLgAFFH8LAAMFAAQJ1xrDDwDJAAAFAAIJXSLDDwDJAAAGAAIJURMKHQCiAAAuAAQKfxcAAwUACAl3IBsdAFcCAAUABwl3IBsdAFcCAAYABgkZHHksAMgBAAAA.',
['茉莉']='茉莉丨丨清茶:BAAALgAECgIJAQAAAA==.',
['荒野']='荒野之息:BAAALgADCgUJBQAAAA==.',
['荟乄']='荟乄为你而战:BAAALgAECgIJAgAAAA==.',
['荭翎']='荭翎巾:BAAALgADCgEJAQAAAA==.',
['莫得']='莫得办法:BAAALgAECgMJBAAAAA==.',
['莱福']='莱福士:BAABLgAECn8fAAIgAAkJpBg1DQC+AgAgAAkJpBg1DQC+AgABLgAFFAUJBQAgAFgQAA==.',
['菈妮']='菈妮:BAACLgAFFH8KAAIJAAQJsRueBwByAQAJAAQJsRueBwByAQAuAAQKfysAAwkACQnGIucAAI4DAAkACQnGIucAAI4DAAsABgkMIRYBAN4BAAEuAAUUBgkDAAEAAAAA.',
['菲亚']='菲亚梅塔:BAAALgAECgMJBAAAAA==.',
['萨雷']='萨雷加尔:BAAALgAECgYJBwABLgAFFAUJEQAOAIwhAA==.',
['落肉']='落肉肉:BAAALgAECgEJAQAAAA==.',
['蒙特']='蒙特苏马:BAAALgAECgYJCQAAAA==.',
['蓝色']='蓝色恶魔:BAAALgAECgYJBwAAAA==.蓝色流星雨:BAAALgAECgQJBgAAAA==.',
['蓧嘢']='蓧嘢太郎:BAAALgAECgMJAwAAAA==.',
['虎虎']='虎虎排骨面:BAAALgAECgUJBQAAAA==.',
['虾剥']='虾剥皮了唛:BAAALgAECgUJBQAAAA==.',
['蜀久']='蜀久涵天:BAAALgAECgIJAgAAAA==.',
['血火']='血火之心:BAAALgAECgQJBAAAAA==.',
['血色']='血色悟空:BAAALgADCgQJBwAAAA==.',
['行走']='行走式面包机:BAAALgADCgIJAgAAAA==.',
['被遗']='被遗忘的小二:BAAALgAECgIJAwAAAA==.被遗忘的祝福:BAAALgAECgkJCQAAAA==.',
['裂丶']='裂丶蹄:BAAALgAECgQJBAAAAA==.',
['裸喯']='裸喯的领头羊:BAABLgAFFH8IAAIUAAMJGhzZJQAcAQAUAAMJGhzZJQAcAQAAAA==.',
['要你']='要你命叁千:BAAALgAECgcJBwAAAA==.',
['触动']='触动心跳:BAAALgADCgMJAQAAAA==.',
['谱面']='谱面完成啦:BAAALgAECgYJBgAAAA==.',
['豆丁']='豆丁:BAACLgAFFH8FAAMQAAMJ9BBTDACdAAAQAAIJsxdTDACdAAAOAAMJ1h2nCQBgAAAuAAQKfxYAAxAABwloJGYKAKcCABAABwloJGYKAKcCAA4ABAkqIIlMAKQAAAAA.',
['贝尔']='贝尔蒙特:BAAALgAECgYJEQAAAA==.',
['贝阿']='贝阿朵丽丝:BAAALgAECgQJBAAAAA==.',
['财阀']='财阀继承人:BAAALgAECgYJCgAAAA==.',
['贺石']='贺石湾小霸王:BAAALgADCgUJBQAAAA==.',
['超级']='超级风骚:BAACLgAFFH8HAAINAAQJ7QS5DAARAQANAAQJ7QS5DAARAQAuAAQKfysAAw0ACQm0EPUGAOABAA0ACQm0EPUGAOABABwAAQlQDdhEACwAAAAA.',
['蹦迪']='蹦迪牛德子:BAAALgAECgIJAgAAAA==.',
['辣白']='辣白菜不辣:BAAALgAECgIJAgAAAA==.',
['这一']='这一刀叫成长:BAACLgAFFH8HAAIUAAMJyRfEJwAUAQAUAAMJyRfEJwAUAQAuAAQKfyIAAhQABwnXISFPAEoCABQABwnXISFPAEoCAAAA.',
['这家']='这家伙有点浪:BAAALgAECgUJBQAAAA==.',
['迪蒙']='迪蒙哼特尔:BAAALgAECgkJDwAAAA==.',
['迪迪']='迪迪麦当劳:BAAALgAFFAEJAQAAAA==.',
['那个']='那个男人丶:BAAALgADCgEJAQAAAA==.',
['那我']='那我问你:BAAALgAECgUJCgAAAA==.',
['郭大']='郭大脚:BAABLgAFFH8HAAIWAAUJHQQKDgD/AAAWAAUJHQQKDgD/AAABLgAFFAYJFwARAN0fAA==.',
['酒丨']='酒丨仙:BAABLgAFFH8FAAIjAAUJ3x0AAAAAAAAgAAUJ3x0AAAAAAAAAAA==.',
['钟意']='钟意:BAAALgAECgkJCwAAAA==.',
['钢之']='钢之炼鑫术师:BAAALgAECgMJAwABLgAFFAEJAQABAAAAAA==.',
['银美']='银美儿丶:BAAALgADCgEJAQAAAA==.',
['锄禾']='锄禾日当午:BAAALgAECgEJAQAAAA==.',
['锅热']='锅热倒油:BAAALgAECgYJCgAAAA==.',
['闇之']='闇之狂想:BAAALgAECgMJAwAAAA==.',
['阙副']='阙副官:BAABLgAECn8XAAMIAAcJxxUpOQCdAQAIAAcJxxUpOQCdAQAeAAEJzAMmjwApAAAAAA==.阙副队:BAAALgAECgYJCwAAAA==.',
['阿咆']='阿咆:BAAALgAECgQJCQAAAA==.',
['阿尔']='阿尔托莉雅王:BAAALgAECgUJBgAAAA==.',
['阿斯']='阿斯拉达:BAAALgAECgcJCwAAAA==.阿斯顿:BAAALgADCgEJAQAAAA==.',
['阿牛']='阿牛奶龙:BAAALgAECgYJBgAAAA==.',
['阿良']='阿良就是猛:BAAALgAECgIJAgAAAA==.',
['阿诺']='阿诺华辛力加:BAAALgAECgMJAwAAAA==.',
['阿飛']='阿飛的小蝴蝶:BAAALgAECgcJEQAAAA==.',
['阿黑']='阿黑归来:BAAALgADCgYJBgAAAA==.',
['雏森']='雏森桃丶:BAAALgAECggJDAAAAA==.',
['雪奶']='雪奶的白子:BAABLgAFFH8FAAITAAUJJgE+EADRAAATAAUJJgE+EADRAAAAAA==.',
['雪月']='雪月加尔:BAAALgADCgEJAQAAAA==.',
['雷神']='雷神立花道雪:BAAALgAECgcJDwAAAA==.',
['雷霆']='雷霆雨路:BAAALgAECgUJBgAAAA==.',
['霄道']='霄道人:BAAALgAECgQJBAAAAA==.',
['霸气']='霸气牛:BAAALgAECgEJAQAAAA==.',
['青丘']='青丘狐帝:BAAALgAECgMJBAAAAA==.',
['青春']='青春犯丶:BAAALgAECgcJDgAAAA==.',
['风打']='风打:BAABLgAECn8UAAMeAAYJWCGLIgD7AQAeAAYJWCGLIgD7AQAIAAEJCyGpkwBNAAAAAA==.',
['风过']='风过无我:BAAALgAFFAIJAgAAAA==.',
['风雨']='风雨如晦:BAAALgADCgEJAQAAAA==.',
['飘缈']='飘缈晨雨:BAAALgAECgMJBAAAAA==.',
['香蕉']='香蕉牛奶:BAAALgAFFAIJAgAAAA==.',
['马修']='马修赫伯特:BAAALgAECgYJCQAAAA==.',
['马尔']='马尔戈隆:BAAALgAECgQJBgAAAA==.',
['驭龙']='驭龙术:BAACLgAFFH8JAAIDAAQJIxFfEwBOAQADAAQJIxFfEwBOAQAuAAQKfysAAwMACQkKIFMCAIUCAAMACQkjHlMCAIUCACQAAwleIAsqABkBAAAA.',
['骇仁']='骇仁鲸:BAAALgAECgEJAQAAAA==.',
['鬼影']='鬼影神法:BAAALgAECgcJDQAAAA==.',
['魈影']='魈影:BAAALgADCgUJBQAAAA==.',
['魑丨']='魑丨魅:BAACLgAFFH8MAAIDAAQJdBVyEgBTAQADAAQJdBVyEgBTAQAuAAQKfxoAAgMABwm/HO44ACgCAAMABwm/HO44ACgCAAAA.',
['魔毁']='魔毁痛逐:BAAALgAECgUJBQAAAA==.',
['黎明']='黎明仲裁官:BAAALgAECgYJBgAAAA==.',
['黑刃']='黑刃暗骑:BAAALgAECgUJBQAAAA==.',
['黑暗']='黑暗嗜猎者:BAAALgAECgMJAwAAAA==.',
['黑血']='黑血:BAAALgAECgYJBwAAAA==.',
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
