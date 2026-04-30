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

local lookup = {'Unknown-Unknown','Mage-Frost','Rogue-Subtlety','DeathKnight-Unholy','Warrior-Protection','Warlock-Demonology','Warlock-Affliction','Warlock-Destruction','Shaman-Elemental','Evoker-Augmentation','Evoker-Preservation','Shaman-Restoration','Warrior-Fury','Monk-Brewmaster','Paladin-Holy','Paladin-Protection','Warrior-Arms','DemonHunter-Devourer','Evoker-Devastation','Priest-Shadow','Druid-Balance','Druid-Restoration','Monk-Mistweaver','Rogue-Assassination',}
local provider = {region='CN',realm='埃霍恩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aihuoenwp:BAAALgAECgkJAQABLgAFFAQJBAABAAAAAA==.Aihuoenxt:BAAALgAECgcJBwAAAA==.Aihuoenxx:BAABLgAECn8VAAICAAkJDh0PFgAkAwACAAkJDh0PFgAkAwAAAA==.',
Be='Beel:BAABLgAECn8cAAIDAAgJwArLCABwAQADAAgJwArLCABwAQAAAA==.',
Di='Discovery:BAAALgAECgkJDwAAAA==.',
Es='Esés:BAAALgAFFAQJAwAAAA==.',
Ge='Genki:BAAALgAECgYJBgAAAA==.',
Gl='Glory:BAACLgAFFH8eAAICAAgJlSAmAABpAgACAAgJlSAmAABpAgAuAAQKfyMAAgIACQm/Jg4DAM4DAAIACQm/Jg4DAM4DAAAA.',
Ha='Harley:BAAALgAFFAEJAQAAAA==.',
Ma='Mathilda:BAAALgADCgMJAwAAAA==.',
Na='Natsumek:BAAALgADCgIJAgAAAA==.',
Pa='Pandarenyuan:BAABLgAECn8VAAIEAAgJHh+9GADnAgAEAAgJHh+9GADnAgAAAA==.',
Re='Reiko:BAABLgAFFH8RAAIEAAYJoiVMAAAXAgAEAAYJoiVMAAAXAgAAAA==.',
Ro='Rocveadeelan:BAAALgAFFAQJBAAAAA==.',
Sa='Sayanything:BAABLgAECn8iAAIFAAgJqROlFADCAQAFAAgJqROlFADCAQAAAA==.',
Wo='Wonyoung:BAABLgAFFH8GAAIGAAIJdyUoFwDiAAAGAAIJdyUoFwDiAAAAAA==.',
Xt='Xtremeone:BAABLgAFFH8FAAQGAAUJOhBDIQD/AAAGAAMJOBFDIQD/AAAHAAEJAAC4AwBdAAAIAAEJPw3NFQBTAAAAAA==.Xtremexis:BAAALgAFFAQJBAAAAA==.',
['Ãä']='Ãäãã:BAAALgAECgYJBwAAAA==.',
['一只']='一只梨:BAABLgAECn8sAAIJAAkJ8w8OCwBuAQAJAAkJ8w8OCwBuAQAAAA==.',
['丁胖']='丁胖:BAAALgAECgUJCQAAAA==.丁胖胖:BAAALgAECgIJAgAAAA==.',
['不知']='不知水:BAAALgAECgEJAQABLgAECgYJDQABAAAAAA==.',
['丶怠']='丶怠惰:BAAALgAFFAEJAQAAAA==.',
['丷夜']='丷夜空丷:BAAALgAECgkJCQAAAA==.',
['丹恩']='丹恩年:BAAALgAECgkJDwABLgAFFAQJBAABAAAAAA==.',
['九儿']='九儿丶:BAAALgAECgIJAgAAAA==.',
['争梦']='争梦:BAAALgAECgcJCQABLgAFFAcJDQAFAM4ZAA==.',
['仿生']='仿生泪滴:BAAALgAECgcJBwABLgAFFAQJCgAKACwSAA==.',
['低血']='低血鸭鸭:BAAALgADCgYJBgAAAA==.',
['何事']='何事十:BAAALgAECgkJEQAAAA==.',
['倾弦']='倾弦:BAAALgAECgYJCAAAAA==.倾弦潇:BAAALgAECgcJCAAAAA==.',
['倾潇']='倾潇:BAAALgAECgYJDgAAAA==.',
['倾璇']='倾璇:BAAALgAECgYJDQAAAA==.',
['八一']='八一佰:BAABLgAFFH8IAAMGAAUJeQa7DQAhAQAGAAUJeQa7DQAhAQAIAAEJrQLvGQBIAAAAAA==.',
['八三']='八三佰:BAABLgAFFH8JAAMGAAQJdAwPJQDuAAAGAAQJdAwPJQDuAAAIAAEJsgNaGQBKAAAAAA==.',
['八二']='八二佰:BAABLgAFFH8GAAIGAAQJhggzDAAvAQAGAAQJhggzDAAvAQAAAA==.',
['八五']='八五佰:BAAALgAFFAQJBAAAAA==.',
['八佰']='八佰:BAABLgAFFH8NAAMGAAUJ9grPCwAzAQAGAAUJ9grPCwAzAQAIAAEJZQZWGABOAAAAAA==.',
['十路']='十路九空:BAAALgAECgYJDAAAAA==.',
['半夏']='半夏:BAAALgAFFAIJAwAAAA==.',
['南拳']='南拳:BAAALgAFFAQJBAAAAA==.',
['卲超']='卲超:BAAALgAECgYJBgAAAA==.',
['古或']='古或今:BAABLgAFFH8IAAIEAAQJCCOtBwCTAQAEAAQJCCOtBwCTAQAAAA==.',
['另外']='另外那支角呢:BAAALgAECgYJDQAAAA==.',
['吉祥']='吉祥物吐泡泡:BAAALgADCgEJAQAAAA==.',
['呜呜']='呜呜灵:BAABLgAFFH8FAAILAAUJEhF0BQCgAQALAAUJEhF0BQCgAQAAAA==.',
['和花']='和花:BAAALgAECgYJBgAAAA==.',
['哈莉']='哈莉:BAAALgAFFAIJAgAAAA==.',
['喵筱']='喵筱筱喵:BAAALgAFFAMJBAAAAA==.',
['嗯哼']='嗯哼:BAAALgAECgcJAQABLgAFFAYJCgAMAHYKAA==.',
['地下']='地下堡:BAAALgAECgcJEAAAAA==.',
['埃霍']='埃霍恩:BAAALgAECgQJBwAAAA==.',
['塔烙']='塔烙莎沙:BAAALgADCgEJAQAAAA==.',
['墙里']='墙里佳人笑:BAAALgAECgIJAgAAAA==.',
['夏的']='夏的光辉:BAAALgADCgQJBAAAAA==.',
['大可']='大可不必:BAAALgAECgUJBgAAAA==.',
['大地']='大地圣光:BAAALgAECgEJAgAAAA==.',
['天下']='天下唯我风云:BAAALgAFFAMJAQAAAA==.',
['天丨']='天丨南葵:BAACLgAFFH8FAAIFAAIJHwMjCABrAAAFAAIJHwMjCABrAAAuAAQKfxQAAwUABwllDdseAE0BAAUABwllDdseAE0BAA0AAQkAACyoADYAAAAA.',
['天真']='天真的云:BAABLgAFFH8GAAIEAAQJNBAZGQBBAQAEAAQJNBAZGQBBAQABLgAFFAYJCAAKAAkTAA==.',
['天蓝']='天蓝圣光:BAAALgADCgEJAQAAAA==.',
['太阳']='太阳卤蛋:BAAALgAFFAIJAwAAAA==.太阳流蛋:BAAALgAECgYJCAAAAA==.太阳焗蛋:BAAALgAECgUJBQAAAA==.',
['奈亚']='奈亚拉托提普:BAAALgAECgMJBAAAAA==.',
['奈何']='奈何桥上抢人:BAAALgAECgYJBgAAAA==.',
['奥妮']='奥妮克茜娅:BAAALgAECgcJDgAAAA==.',
['奶谁']='奶谁谁死:BAAALgAECgYJDQAAAA==.',
['好奇']='好奇猫猫头:BAAALgAECgYJDAABLgAECgkJLAAJAPMPAA==.',
['嫁衣']='嫁衣裳:BAAALgAECgEJAQAAAA==.',
['小椿']='小椿:BAAALgAECgQJAwAAAA==.',
['小红']='小红手道川:BAAALgAFFAQJAgAAAA==.',
['小蜡']='小蜡烛:BAAALgAFFAEJAQAAAA==.',
['屠尽']='屠尽日寇:BAABLgAFFH8PAAIOAAUJCxCLBgBqAQAOAAUJCxCLBgBqAQAAAA==.',
['岚之']='岚之山:BAAALgAECggJDQAAAA==.',
['庄方']='庄方宜:BAABLgAFFH8FAAMPAAMJAhTkFgCNAAAPAAIJww3kFgCNAAAQAAIJqQ72AgBwAAABLgAFFAYJFgAOALISAA==.',
['弦月']='弦月:BAAALgAECgcJCAAAAA==.',
['当时']='当时爷就火了:BAAALgAECgUJBQAAAA==.',
['影凤']='影凤:BAAALgADCgUJBQAAAA==.',
['影棠']='影棠:BAAALgADCgEJAQAAAA==.',
['恶夜']='恶夜燃烛光:BAAALgAECgcJBwAAAA==.',
['我不']='我不是彦祖:BAABLgAFFH8HAAIGAAIJUBYbMwCsAAAGAAIJUBYbMwCsAAAAAA==.',
['我是']='我是炖土豆:BAAALgAFFAIJAgAAAA==.',
['我要']='我要炖土豆:BAABLgAFFH8IAAILAAMJDRl+DQAFAQALAAMJDRl+DQAFAQAAAA==.',
['战争']='战争领主:BAAALgAECgcJAQAAAA==.',
['拉普']='拉普拉斯:BAAALgAFFAQJBAAAAA==.',
['敖隐']='敖隐:BAAALgAECgUJCgAAAA==.',
['敲鼓']='敲鼓萨萨:BAAALgAECgQJAQAAAA==.',
['无聊']='无聊的小花椒:BAABLgAFFH8OAAMNAAQJVRUnCQBeAQANAAQJVRUnCQBeAQARAAQJMAOcAgANAQAAAA==.',
['旺旺']='旺旺:BAAALgADCgEJAQAAAA==.',
['是小']='是小椿哟:BAABLgAECn8XAAICAAYJsRkUlQCqAQACAAYJsRkUlQCqAQAAAA==.',
['普希']='普希芬尼:BAAALgADCgEJAQAAAA==.',
['暁美']='暁美焰:BAAALgADCgIJAgAAAA==.',
['朋克']='朋克小强:BAAALgADCgUJBQAAAA==.',
['李师']='李师师:BAABLgAFFH8GAAISAAYJAADqKgABAAASAAYJAADqKgABAAAAAA==.',
['松浦']='松浦果南:BAAALgAECgYJBwAAAA==.',
['柳智']='柳智敏:BAABLgAFFH8VAAMTAAYJ3g/9AgBJAQATAAQJOg/9AgBJAQAKAAQJwguUCgD5AAAAAA==.',
['樱桃']='樱桃小完犊子:BAAALgAECgcJBwAAAA==.',
['欧皇']='欧皇:BAAALgAECgEJAQAAAA==.',
['污里']='污里唔撮:BAAALgAECgYJBgAAAA==.',
['深蓝']='深蓝圣光:BAAALgAECgMJAwAAAA==.',
['潇月']='潇月炫:BAAALgAECgYJDgAAAA==.',
['灬丨']='灬丨影丨灬:BAAALgADCgUJBQAAAA==.',
['然然']='然然:BAAALgAFFAQJBAABLgAFFAQJBgAUAAcWAA==.',
['熊小']='熊小包丶:BAAALgAECggJEgAAAA==.',
['狂炫']='狂炫富婆画饼:BAAALgAFFAQJBAAAAA==.',
['猪尐']='猪尐悠:BAAALgADCgUJCgAAAA==.',
['獭嗒']='獭嗒嗒:BAABLgAFFH8FAAIVAAIJxhzpEQC2AAAVAAIJxhzpEQC2AAAAAA==.',
['琥珀']='琥珀幽夜:BAABLgAECn8hAAMWAAkJ4hVTKQAOAgAWAAkJ4hVTKQAOAgAVAAQJvhnFVgDJAAABLgAFFAgJFgAKADUTAA==.',
['皇里']='皇里黄气:BAAALgAECgkJAgAAAA==.',
['看着']='看着浪费:BAAALgAFFAIJAwAAAA==.',
['矮瓜']='矮瓜蛋子:BAAALgAECgIJAgAAAA==.',
['祖达']='祖达萨萨:BAAALgAECgYJBgAAAA==.',
['神头']='神头鬼脸:BAAALgAECgYJDAAAAA==.',
['秦明']='秦明月:BAAALgAFFAIJAgAAAA==.',
['笙梨']='笙梨:BAAALgAECgUJBQAAAA==.',
['粉红']='粉红圣光:BAAALgAECgEJAQAAAA==.',
['罗玛']='罗玛尼阿其曼:BAAALgAFFAMJAwABLgAFFAUJBQAVAKkYAA==.',
['罪歌']='罪歌:BAAALgAECgYJDAAAAA==.',
['美团']='美团女骑手:BAAALgADCgUJCgAAAA==.',
['范吧']='范吧啦:BAABLgAECn8UAAIXAAgJJR5DCwCeAgAXAAgJJR5DCwCeAgAAAA==.',
['范大']='范大山:BAAALgAECgQJBAAAAA==.',
['菈妮']='菈妮:BAAALgAECgYJCQAAAA==.',
['菲尼']='菲尼克:BAAALgADCgIJAgAAAA==.',
['萌新']='萌新求土豆:BAAALgADCgEJAQAAAA==.',
['蒙牛']='蒙牛丹:BAAALgADCgcJAQAAAA==.',
['藍色']='藍色火焰:BAAALgAECgQJBAAAAA==.',
['蟹黄']='蟹黄汤包:BAAALgAECgYJBgAAAA==.',
['被诅']='被诅咒的精灵:BAAALgAECgEJAQAAAA==.',
['裹着']='裹着心的光:BAACLgAFFH8TAAIOAAUJFSbmAAAsAgAOAAUJFSbmAAAsAgAuAAQKfyEAAg4ACQntJPQAALgDAA4ACQntJPQAALgDAAAA.',
['西瓜']='西瓜十九号:BAABLgAFFH8OAAIPAAcJdRQpAABuAgAPAAcJdRQpAABuAgAAAA==.',
['路小']='路小雨:BAABLgAECn8hAAMDAAkJ+BuoCQD3AgADAAkJ+BuoCQD3AgAYAAEJiwmcHgA6AAAAAA==.',
['软饭']='软饭硬吃:BAABLgAFFH8NAAIPAAQJeBT6BwBRAQAPAAQJeBT6BwBRAQABLgAFFAgJHgAXAOQfAA==.',
['这点']='这点够谁打啊:BAAALgAECgcJBwAAAA==.',
['邵超']='邵超:BAAALgADCgQJBAAAAA==.',
['锃光']='锃光瓦亮亮哥:BAAALgADCgIJAgAAAA==.',
['阿尔']='阿尔萨斯丶:BAAALgAFFAIJAgAAAA==.',
['阿迩']='阿迩萨斯:BAAALgAFFAEJAQAAAA==.',
['陨石']='陨石艾丝缇:BAAALgAFFAIJAgAAAA==.',
['雨之']='雨之魔女梣:BAABLgAFFH8GAAMGAAMJYCJDFwA2AQAGAAMJYCJDFwA2AQAHAAEJ2hwnAQBjAAABLgAFFAQJBQACAKocAA==.',
['雷霆']='雷霆残月:BAAALgADCgIJAgAAAA==.',
['青绿']='青绿圣光:BAAALgAECgUJCQAAAA==.',
['风月']='风月夜:BAAALgAECgYJBwAAAA==.',
['飞哥']='飞哥:BAAALgAECgcJCwAAAA==.',
['高兴']='高兴萤火虫:BAAALgAECgYJBgAAAA==.',
['高血']='高血胖胖:BAAALgADCgYJBgAAAA==.',
['鱼卷']='鱼卷卷:BAAALgAECgYJDAAAAA==.',
['鲤鱼']='鲤鱼打挺:BAAALgAECgEJAgAAAA==.',
['龙儿']='龙儿:BAAALgAFFAEJAQABLgAFFAUJEQACAHsmAA==.',
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
