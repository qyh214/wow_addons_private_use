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
 local lookup = {'DeathKnight-Frost','Monk-Windwalker','Monk-Mistweaver','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Arcane','DemonHunter-Vengeance','DemonHunter-Havoc','Druid-Feral','Shaman-Restoration','Priest-Shadow','Priest-Holy','Warrior-Fury','Shaman-Elemental','Shaman-Enhancement','DeathKnight-Blood','Monk-Brewmaster','Rogue-Assassination','Paladin-Holy','DeathKnight-Unholy','Warlock-Destruction','Druid-Restoration','Warrior-Protection','Warrior-Arms','Druid-Balance','Rogue-Subtlety','Mage-Frost','Paladin-Protection','Mage-Fire','Unknown-Unknown',}; local provider = {region='CN',realm='克苏恩',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ad='Adios:BAAALAAECggICQABLAAFFAgIHgABAKscAA==.',Ak='Akm:BAAALAAECggIEAAAAA==.',Al='Alencon:BAACLAAFFH8QAAMCAAUIKx0bCAByAQACAAUIKx0bCAByAQADAAII2guuEwCAAAAsAAQKfxQAAwIABgjbImQKAP8BAAIABgjbImQKAP8BAAMABggmHf4aAOIBAAAA.Allin:BAAALAAECgIIAgAAAA==.',An='Angelimy:BAABLAAECn8aAAIEAAgIDx7TOQCOAgAEAAgIDx7TOQCOAgAAAA==.',Ba='Bamboos:BAABLAAECn8jAAMFAAYIjyGVYAAbAgAFAAYIjyGVYAAbAgAGAAII1xhFoAB1AAAAAA==.',Be='Bewithyouqvq:BAAALAADCggICAABLAAFFAUIFgAHALAXAA==.',Co='Coco:BAAALAAECgEIAQAAAA==.',De='Demon:BAAALAAECgYICgAAAA==.Deralanmao:BAACLAAFFH8lAAIIAAYI6RLgAgBVAQAIAAYI6RLgAgBVAQAsAAQKfysAAwgACAhuHAURAFcCAAgACAhuHAURAFcCAAkABgjMEBHNAEQBAAAA.',Di='Diabolous:BAAALAAECggIDQAAAA==.',Dr='Druidmark:BAAALAAFFAIIBAABLAAFFAMICwAEAHAYAA==.',Du='Duckingz:BAABLAAECn8VAAIFAAgILhGbYgB9AQAFAAgILhGbYgB9AQAAAA==.',Fr='Fragile:BAAALAADCgQIBAAAAA==.',Ha='Haken:BAAALAAECggICAAAAA==.',Hu='Huntermark:BAAALAAFFAIIAgABLAAFFAMICwAEAHAYAA==.',Ls='Lsotvoep:BAAALAAFFAMIAwAAAA==.',Me='Merin:BAAALAAFFAIIAgAAAA==.',Mi='Micaiah:BAABLAAFFH8IAAIHAAMInRaVQwCUAAAHAAMInRaVQwCUAAAAAA==.',Mx='Mx:BAAALAADCgUIBQAAAA==.',Pe='Persephonet:BAAALAAFFAEIAQAAAA==.',Ri='Rider:BAABLAAFFH8TAAIEAAUI6xWHKQAxAQAEAAUI6xWHKQAxAQAAAA==.',Si='Sixmage:BAACLAAFFH8HAAIHAAMIFA7ITQCTAAAHAAMIFA7ITQCTAAAsAAQKfxcAAgcABgh+IY1GADQCAAcABgh+IY1GADQCAAEsAAUUBggGAAcARRQA.',Ta='Tavins:BAAALAAECggICQAAAA==.',Tr='Treenewbe:BAAALAADCgYIEQAAAA==.',Un='Uncrowned:BAAALAAFFAIIAgABLAAFFAUIFgAHALAXAA==.',Wj='Wjishf:BAAALAAECgUIBQAAAA==.',Xa='Xalatath:BAAALAAECgYIBgAAAA==.',['一万']='一万只蛆:BAAALAAECgYICQAAAA==.',['一条']='一条龙服雾:BAAALAAECggICAAAAA==.',['一槍']='一槍送终:BAAALAAECgcIBwAAAA==.',['一矮']='一矮大紧一:BAABLAAECn8ZAAIKAAYIRBgXEAAwAQAKAAYIRBgXEAAwAQAAAA==.',['一颗']='一颗杨梅:BAAALAAECgYIDAAAAA==.',['七界']='七界云天河:BAAALAAFFAIIAwAAAA==.',['三井']='三井:BAAALAAECgQIBAAAAA==.',['三气']='三气归来:BAAALAAFFAIIAgAAAA==.',['上古']='上古战神:BAAALAAECgYIEgAAAA==.上古法神:BAAALAAECgcICwAAAA==.上古猎王:BAABLAAECn8YAAIFAAYIzw9+twD6AAAFAAYIzw9+twD6AAAAAA==.上古祭司:BAAALAAECgYIEgAAAA==.上古领主:BAAALAAECgYICAAAAA==.',['上谭']='上谭:BAAALAADCggIBQAAAA==.',['丌月']='丌月柳溪:BAAALAAECgUIBgABLAAFFAgICgALAO4aAA==.',['不在']='不在狀態:BAAALAAECgQIBAAAAA==.',['不忘']='不忘初心乄:BAACLAAFFH8hAAIFAAYIdCBjCAD/AQAFAAYIdCBjCAD/AQAsAAQKfyYAAwUACAg6JS0LAEEDAAUACAg6JS0LAEEDAAYAAgj+Bb63AD8AAAAA.',['不说']='不说话装高手:BAABLAAFFH8bAAIMAAgIFBvZAgB8AgAMAAgIFBvZAgB8AgAAAA==.',['不骑']='不骑马:BAAALAADCggIDgAAAA==.',['世一']='世一猎:BAAALAAFFAIIAgAAAA==.',['严厉']='严厉的父亲:BAABLAAFFH8NAAIBAAYIOQbTRAAnAQABAAYIOQbTRAAnAQAAAA==.',['严查']='严查内鬼:BAAALAAFFAYIAgAAAA==.',['临时']='临时演员:BAAALAAECgMIAwAAAA==.',['丶乘']='丶乘风破浪:BAAALAAECgYIBwAAAA==.',['丶先']='丶先祖之力:BAAALAADCgMIAwAAAA==.',['丶淡']='丶淡墨绘卿颜:BAABLAAFFH8IAAINAAII5RIXOgB3AAANAAII5RIXOgB3AAAAAA==.',['丹妮']='丹妮乄莉丝:BAAALAADCgIIAgAAAA==.',['为七']='为七守护:BAAALAAECgIIAgAAAA==.',['乌奎']='乌奎斯布林:BAABLAAFFH8GAAMMAAYI0hTLGADxAAAMAAQI2BbLGADxAAANAAIItxKpNgCIAAAAAA==.',['乔幺']='乔幺叔:BAAALAADCggIDgAAAA==.',['乙酰']='乙酰丙酮:BAAALAADCgYIBgAAAA==.',['九州']='九州天空:BAAALAAECgYIDAAAAA==.九州鑫燃:BAAALAAECgYIBgAAAA==.',['伊利']='伊利大雷:BAABLAAFFH8GAAIJAAYINwQ8OAC0AAAJAAYINwQ8OAC0AAAAAA==.',['伞奎']='伞奎斯布林:BAABLAAFFH8OAAMNAAYINSFoEgDHAQANAAUItiBoEgDHAQAMAAUIihSdFAAtAQAAAA==.',['伤灬']='伤灬逝:BAABLAAFFH8GAAIOAAYI3iJcCgAQAgAOAAYI3iJcCgAQAgAAAA==.',['你二']='你二大爷死前:BAAALAAECgYIBgAAAA==.',['你先']='你先跑我殿后:BAABLAAFFH8UAAIEAAUIRhtmJABOAQAEAAUIRhtmJABOAQAAAA==.',['你在']='你在教我做事:BAAALAAECgMIAwAAAA==.',['倾世']='倾世:BAAALAAECgYICwAAAA==.',['僧僧']='僧僧不息:BAABLAAFFH8oAAIDAAYI4R4dBQAFAgADAAYI4R4dBQAFAgAAAA==.僧僧不熄:BAABLAAFFH8gAAIDAAYILxtEBwDCAQADAAYILxtEBwDCAQAAAA==.',['光屁']='光屁灬股灬雷:BAACLAAFFH8GAAMPAAIIbAJQOQBqAAAPAAIIbAJQOQBqAAALAAIIdQiGaQBRAAAsAAQKfyMABAsABwgHD7NIADcBAAsABwgHD7NIADcBAA8ABwiBDYNGAPUAABAABAjICvAQAJgAAAAA.',['冰冷']='冰冷小心:BAAALAAFFAEIAQABLAAFFAgIGwARAPIcAA==.冰冷小手:BAAALAAECgQIBgAAAA==.冰冷小斧:BAAALAAECgQIBwAAAA==.',['冰雪']='冰雪菲儿:BAAALAAECgUIBQAAAA==.',['凄凉']='凄凉奶萨:BAAALAAECgUIBQAAAA==.',['凯尔']='凯尔斯云:BAACLAAFFH8PAAIFAAMIxgowdgByAAAFAAMIxgowdgByAAAsAAQKfzEAAgUACAjLF4dBAMcBAAUACAjLF4dBAMcBAAAA.',['初冬']='初冬丶啤酒:BAABLAAFFH8KAAISAAYItA8NDADqAAASAAYItA8NDADqAAAAAA==.',['利威']='利威尔阿克曼:BAAALAAECgMIAwAAAA==.',['别死']='别死没豆战复:BAAALAAECgYICAAAAA==.',['动次']='动次打次:BAAALAAFFAEIAQAAAA==.',['卡侬']='卡侬:BAAALAADCgQIBAAAAA==.',['卡尔']='卡尔萨斯:BAACLAAFFH8iAAIBAAYIvBq4IACxAQABAAYIvBq4IACxAQAsAAQKf0UAAgEACAhfIlsxAK4CAAEACAhfIlsxAK4CAAAA.',['变形']='变形者集群:BAABLAAFFH8yAAITAAYIZiS3AwAPAgATAAYIZiS3AwAPAgAAAA==.',['只是']='只是丷猎茶叶:BAAALAADCgYIBwAAAA==.',['史迪']='史迪崽:BAAALAAFFAIIBAAAAA==.',['右安']='右安门双棒儿:BAAALAAFFAIIAgAAAA==.',['右灯']='右灯左行:BAAALAAECgYIDAAAAA==.',['叶无']='叶无道:BAAALAADCgEIAQABLAAFFAUIFgAHALAXAA==.',['吴惟']='吴惟忠:BAAALAAFFAIIAgAAAA==.',['呛怼']='呛怼溜:BAAALAAECgUIBQAAAA==.',['咕徳']='咕徳猫恁:BAAALAAECgYICwAAAA==.',['哇呀']='哇呀:BAAALAAECgEIAQAAAA==.',['哈啰']='哈啰小蛮腰:BAABLAAFFH8GAAISAAYIKAX0FADwAAASAAYIKAX0FADwAAAAAA==.',['团团']='团团小天使:BAAALAAECgQIBAAAAA==.',['土牧']='土牧:BAAALAAECgYIBgAAAA==.',['圣光']='圣光大胡子:BAAALAAECgcIBwAAAA==.',['地理']='地理:BAAALAAECgUIBQAAAA==.',['坤宝']='坤宝可乐:BAAALAAECgMIAwAAAA==.',['壹丶']='壹丶:BAABLAAFFH8GAAITAAYIggthCwBZAQATAAYIggthCwBZAQAAAA==.',['复仇']='复仇心灵:BAAALAAECgYICAAAAA==.',['夏末']='夏末微凉:BAABLAAFFH8LAAMUAAUI5BBvGwDSAAAUAAQIPw9vGwDSAAAEAAEIAARydwA5AAAAAA==.',['夕尔']='夕尔瓦娜:BAAALAAECgYIEgAAAA==.',['夜空']='夜空中的砖头:BAAALAAECggICAAAAA==.',['大一']='大一奶:BAAALAAFFAIIBAAAAA==.',['大官']='大官人:BAAALAAFFAQIBAAAAA==.',['天兵']='天兵鬼眼狂刀:BAAALAAECgEIAQAAAA==.',['头铁']='头铁:BAACLAAFFH8NAAMJAAYI3hGRIQB5AQAJAAYIpA+RIQB5AQAIAAIIPxdNEgA7AAAsAAQKfxcAAwgABgjTHQEhAK8BAAgABghuGgEhAK8BAAkABggVFjKrAHkBAAAA.',['奈往']='奈往:BAAALAAECgYICgAAAA==.',['奉天']='奉天枭雄:BAAALAADCgYIBgAAAA==.奉天狼人:BAAALAAECgMIAwAAAA==.',['奔流']='奔流:BAAALAADCgIIAgAAAA==.',['奥蕾']='奥蕾莉亜:BAABLAAFFH8LAAIBAAMIihniVgCrAAABAAMIihniVgCrAAAAAA==.',['奶咖']='奶咖:BAAALAAECgEIAQAAAA==.',['奶油']='奶油虾球:BAAALAAECggIDgAAAA==.',['她用']='她用下面:BAABLAAFFH8VAAMVAAQIxBLNDwCbAAAVAAMI4RDNDwCbAAABAAQILRJNcABTAAAAAA==.',['她说']='她说是晒黑的:BAAALAAFFAgIAgAAAA==.',['好大']='好大的绿根儿:BAABLAAECn8YAAIWAAYI1RZ4bwCoAQAWAAYI1RZ4bwCoAQAAAA==.',['如此']='如此丶姚饶:BAAALAAECgUIBQAAAA==.',['子忆']='子忆呀:BAAALAAFFAIIAgAAAA==.',['孤海']='孤海黑骑:BAAALAAFFAIIAwAAAA==.',['孤獨']='孤獨丶患者:BAAALAAECgYICgAAAA==.',['宫垚']='宫垚:BAAALAAFFAIIBAAAAA==.',['寒月']='寒月斩:BAAALAAECgQIBAAAAA==.寒月溺行:BAAALAAECgYIBgAAAA==.',['寒枂']='寒枂血色:BAAALAAECgYIEQAAAA==.',['小七']='小七不理人:BAAALAAFFAIIAgAAAA==.',['小业']='小业主:BAAALAAECgIIAgAAAA==.',['小哥']='小哥真给力:BAABLAAFFH8HAAIXAAIIyhtYNACYAAAXAAIIyhtYNACYAAAAAA==.',['小壮']='小壮:BAAALAAECgIIAgAAAA==.',['小小']='小小三月七:BAAALAAFFAMIAwAAAA==.小小猎手:BAAALAAFFAIIAgAAAA==.小小的秋裤:BAAALAAFFAIIAgAAAA==.',['小给']='小给教授:BAABLAAFFH8KAAILAAMIkRjlMwDXAAALAAMIkRjlMwDXAAAAAA==.',['小鸡']='小鸡酱汁:BAAALAADCggICgAAAA==.小鸡酱汁丨:BAAALAAECgEIAQAAAA==.小鸡酱汁酱:BAAALAAECgcICQAAAA==.',['少卿']='少卿:BAAALAAECgYICwAAAA==.',['尘成']='尘成晨:BAACLAAFFH8gAAQOAAUIKBagEQBZAQAOAAUIKBagEQBZAQAYAAIIhg40HQCEAAAZAAEIxBCTCABKAAAsAAQKfy0ABA4ACAiBIzInAKQCAA4ABwjdIzInAKQCABgABgjQG9MxAMkBABkAAwjdIb8fABYBAAAA.',['山风']='山风:BAAALAAECgYIDgAAAA==.',['岁月']='岁月无恨:BAACLAAFFH8OAAIFAAIIDg/9jQBGAAAFAAIIDg/9jQBGAAAsAAQKfxYAAgUACAgZE410AFsBAAUACAgZE410AFsBAAAA.',['布鲁']='布鲁布鲁静:BAAALAAECgUIBQAAAA==.',['康迪']='康迪隆:BAAALAAECgYIBwAAAA==.',['开始']='开始冲钅:BAAALAAECgUIBQAAAA==.',['弑魂']='弑魂瑟瑟:BAAALAAFFAIIAwAAAA==.',['心中']='心中的日月:BAACLAAFFH8jAAMaAAUImw8SGwD8AAAaAAUImw8SGwD8AAAXAAQIvRDhJgDhAAAsAAQKfxkAAxoACAiiG9c3ANkBABoACAiiG9c3ANkBABcABwgqEFZxAEMBAAAA.',['忧郁']='忧郁小猫咪:BAAALAAECgEIAQAAAA==.',['念念']='念念大宝贝:BAAALAAECgYIBAAAAA==.',['性感']='性感的水桶腰:BAAALAAECgYICQAAAA==.',['恶灬']='恶灬魔:BAAALAADCgUIBQAAAA==.',['恶魔']='恶魔不恶:BAAALAAECgYIDAAAAA==.',['悠哉']='悠哉:BAAALAAECgYIDgAAAA==.',['情浅']='情浅缘浅:BAAALAAFFAIIBAAAAA==.',['愿大']='愿大地忽悠你:BAAALAAECgUICQAAAA==.',['憨憨']='憨憨丶:BAAALAAECgYICQAAAA==.',['我是']='我是坤哥:BAACLAAFFH8WAAIHAAUIsBfrMABBAQAHAAUIsBfrMABBAQAsAAQKfyoAAgcACAiMI4cEAM0CAAcACAiMI4cEAM0CAAAA.',['戰囶']='戰囶:BAAALAAECgYICwAAAA==.',['扶风']='扶风:BAAALAAECgEIAQAAAA==.',['拉塔']='拉塔恩:BAAALAAFFAIIAgAAAA==.',['斯奎']='斯奎丝布丝:BAABLAAFFH8GAAMMAAYIbRoXFgAaAQAMAAQIfB8XFgAaAQANAAIIvhNhNgCKAAAAAA==.斯奎丝布伞:BAABLAAFFH8LAAMMAAYIjRGtDwBqAQAMAAYIjRGtDwBqAQANAAIIlRQyNgCLAAAAAA==.斯奎丝布尔:BAABLAAFFH8TAAMMAAYITBg3CgCxAQAMAAYITBg3CgCxAQANAAIIEwz2OAB9AAAAAA==.斯奎丝布屋:BAABLAAFFH8GAAMMAAYIvRm2FgARAQAMAAQIrR22FgARAQANAAIIhQllOQB7AAAAAA==.斯奎丝布衣:BAABLAAFFH8NAAMMAAYI8w7UFQAdAQAMAAUIPRHUFQAdAQANAAUIsQS+JwDzAAAAAA==.斯奎斯布林:BAABLAAFFH8SAAMMAAYIlxlZCgCvAQAMAAYIlxlZCgCvAQANAAQIpxBBJgAFAQAAAA==.',['斯斯']='斯斯丶:BAABLAAFFH8MAAMTAAYIOh1jBwClAQATAAUIhiFjBwClAQAbAAQIdgdsDAC5AAAAAA==.',['无止']='无止灬之殇:BAAALAAECgIIAgAAAA==.',['无骑']='无骑不有:BAAALAAECgIIAgAAAA==.',['时光']='时光中漫步:BAACLAAFFH8FAAIHAAIINwM7ZgA0AAAHAAIINwM7ZgA0AAAsAAQKfxkAAwcABgijFCE/ABABAAcABgjDEiE/ABABABwABAh8EXk7AG8AAAAA.',['时差']='时差:BAAALAAECgEIAQAAAA==.',['星丨']='星丨痕:BAAALAAFFAIIAgAAAA==.',['星痕']='星痕:BAABLAAFFH8LAAMEAAMIcBiNPwCVAAAEAAMIcBiNPwCVAAAdAAIIzwV0IAArAAAAAA==.',['暗之']='暗之刀线:BAAALAAECgYIBgAAAA==.',['暗夜']='暗夜圣光之王:BAABLAAECn8UAAIUAAYITRCyIQA2AQAUAAYITRCyIQA2AQAAAA==.暗夜的祝福:BAAALAAECgYIBgAAAA==.',['暗天']='暗天者:BAAALAAECgYIBgAAAA==.',['月满']='月满长河:BAAALAAECgUIBQAAAA==.',['月神']='月神:BAABLAAFFH8HAAIFAAUIlQ6aUgAFAQAFAAUIlQ6aUgAFAQAAAA==.月神的吻:BAABLAAFFH8IAAIcAAII5xlzFABGAAAcAAII5xlzFABGAAAAAA==.',['李阿']='李阿不:BAAALAAECgYIDQAAAA==.',['来治']='来治猩猩的你:BAAALAAECggICAAAAA==.',['杰雷']='杰雷米亚:BAACLAAFFH8UAAIMAAUIVBADFQAoAQAMAAUIVBADFQAoAQAsAAQKfxUAAgwACAh3HtUGAH4CAAwACAh3HtUGAH4CAAAA.',['枪花']='枪花:BAAALAADCgcIBwAAAA==.',['柳奎']='柳奎斯布林:BAABLAAFFH8SAAMNAAYI5BapHQBgAQANAAUIUhapHQBgAQAMAAQIvxlXGAD5AAAAAA==.',['棍哥']='棍哥:BAAALAAFFAIIAgAAAA==.',['止戰']='止戰天涯:BAAALAADCggICAAAAA==.',['此世']='此世梦妖娆:BAAALAADCgIIAgAAAA==.',['武神']='武神:BAABLAAFFH8HAAISAAMIgwNZHABYAAASAAMIgwNZHABYAAAAAA==.',['水之']='水之残雪:BAAALAAECgYICgAAAA==.水之燕齐:BAAALAAECgYICQAAAA==.',['水月']='水月灬冰晶:BAAALAAECgYIBgAAAA==.',['沃弗']='沃弗括丝:BAAALAAECgIIAgAAAA==.',['没出']='没出呀:BAABLAAFFH8JAAMHAAgIDAxHMQA/AQAHAAgIAAxHMQA/AQAeAAEIZwDzEAACAAAAAA==.',['涅槃']='涅槃:BAABLAAECn8WAAIEAAgIhRJXlQDIAQAEAAgIhRJXlQDIAQAAAA==.',['清纯']='清纯女大学生:BAAALAADCgYIEgAAAA==.',['溜溜']='溜溜糖:BAAALAAECggIEAAAAA==.',['满满']='满满的回忆:BAAALAAECgYIBwAAAA==.',['潜在']='潜在情人:BAABLAAFFH8OAAIWAAYIPAFERwCkAAAWAAYIPAFERwCkAAAAAA==.潜在情人丶:BAABLAAFFH8OAAIWAAYIdwkSMwBJAQAWAAYIdwkSMwBJAQAAAA==.',['灬熊']='灬熊宝:BAAALAAFFAgIAgAAAA==.',['灵狐']='灵狐:BAAALAADCgIIAgAAAA==.',['灵雾']='灵雾燥:BAABLAAECn8YAAIHAAYIfyRAMgCBAgAHAAYIfyRAMgCBAgABLAAFFAIIBAAfAAAAAA==.',['灵魂']='灵魂行这:BAAALAAECgYIEAAAAA==.',['煽风']='煽风点火:BAAALAADCgYIBgAAAA==.',['熊宝']='熊宝丶:BAABLAAFFH8IAAITAAgIDB8LAgB/AgATAAgIDB8LAgB/AgAAAA==.',['熊熊']='熊熊来啦:BAABLAAFFH8FAAIBAAIITxWCZQCVAAABAAIITxWCZQCVAAAAAA==.',['爆炒']='爆炒熘肝尖:BAAALAAECggIBgAAAA==.',['牛教']='牛教授:BAAALAAECgcIBwAAAA==.',['狂笑']='狂笑的大福:BAAALAADCgMIAwAAAA==.',['独影']='独影戏:BAAALAAFFAIIBAAAAA==.',['猪九']='猪九婧:BAAALAADCggICAAAAA==.',['猫老']='猫老师:BAABLAAECn8dAAILAAYIRxYjPgBiAQALAAYIRxYjPgBiAQAAAA==.',['玉宇']='玉宇琼楼:BAAALAAECgYIBgAAAA==.',['王富']='王富贵三号:BAAALAAFFAIIAgAAAA==.王富贵儿:BAAALAAFFAIIBAAAAA==.',['玲娜']='玲娜贝儿爆轰:BAABLAAFFH8HAAMcAAMIZxJpDgB2AAAcAAMIGRFpDgB2AAAHAAEIEAynWABCAAABLAAFFAgIEAAEAHAcAA==.',['理塘']='理塘顶真:BAAALAAFFAIIAgAAAA==.',['瓜门']='瓜门德:BAAALAAECgYIBgAAAA==.',['甜甜']='甜甜的少女心:BAABLAAFFH8KAAINAAIIbxQIOgB4AAANAAIIbxQIOgB4AAABLAAFFAUIFgAHALAXAA==.',['生活']='生活要多点绿:BAABLAAFFH8LAAIJAAUIEAqeMwDqAAAJAAUIEAqeMwDqAAABLAAFFAUIFgAHALAXAA==.',['生物']='生物:BAAALAAECgEIAQAAAA==.',['白日']='白日烟火:BAABLAAFFH8GAAMbAAYIUwlIDAC8AAAbAAQIIAlIDAC8AAATAAIIuAnHFQCQAAAAAA==.',['白酒']='白酒公主:BAAALAAFFAIIBAAAAA==.',['盖畜']='盖畜:BAABLAAFFH8GAAITAAYINhtdBgC9AQATAAYINhtdBgC9AQAAAA==.',['石小']='石小甜:BAAALAAECgYIBgAAAA==.',['破晓']='破晓之光:BAAALAAECgUIBQAAAA==.',['破碎']='破碎清算:BAAALAAECgUIBQAAAA==.',['祛倪']='祛倪禡鍀蕾钬:BAAALAAECgYIEgAAAA==.',['祝福']='祝福你全家:BAABLAAFFH8RAAICAAMIqRK2EACOAAACAAMIqRK2EACOAAAAAA==.',['神圣']='神圣之熊:BAAALAAECgEIAQAAAA==.神圣之语:BAAALAAECgYIDgAAAA==.',['离别']='离别别开花:BAAALAAFFAIIAgAAAA==.',['禾盛']='禾盛:BAAALAAECgYIBgAAAA==.',['箭心']='箭心犹在:BAABLAAFFH8IAAIFAAYImRTxNABoAQAFAAYImRTxNABoAQAAAA==.',['纠缠']='纠缠怨毒:BAAALAAFFAIIAgAAAA==.',['维达']='维达:BAABLAAFFH8FAAIEAAUIyQAnhgAOAAAEAAUIyQAnhgAOAAAAAA==.',['缝补']='缝补软脚虾:BAAALAAECgQIBQAAAA==.',['老子']='老子信痒:BAAALAAECgMIAwAAAA==.',['老白']='老白干:BAAALAADCggIDgAAAA==.',['耳奎']='耳奎斯布林:BAABLAAFFH8TAAMMAAYI5xVyDACSAQAMAAYI5xVyDACSAQANAAUIeBzIGACLAQAAAA==.',['肆月']='肆月拾肆:BAABLAAECn8WAAILAAgINBIiMQCcAQALAAgINBIiMQCcAQAAAA==.',['肌不']='肌不可失:BAAALAADCgIIAgAAAA==.',['肝帝']='肝帝:BAAALAAFFAIIAgAAAA==.',['致命']='致命元素:BAAALAAECgQIBQAAAA==.',['芒果']='芒果养乐多:BAAALAAECgYIDAAAAA==.',['花乃']='花乃玖叶月:BAABLAAFFH8PAAIEAAUINhV1KgAsAQAEAAUINhV1KgAsAQAAAA==.',['苟玲']='苟玲子一块:BAAALAAECggICAAAAA==.苟玲子伍毛:BAAALAADCgEIAQAAAA==.苟玲子壹块壹:BAAALAAECgUIBQAAAA==.苟玲子壹毛:BAABLAAFFH8FAAIYAAUIeAqyHACdAAAYAAUIeAqyHACdAAAAAA==.苟玲子捌毛:BAAALAAECgYIBQAAAA==.苟玲子柒毛:BAAALAAECggICAAAAA==.苟玲子玖毛:BAAALAAECgIIAgAAAA==.苟玲子肆毛:BAAALAAECgYIBgAAAA==.',['莽飀']='莽飀旨:BAAALAAECgYIBgAAAA==.',['萌月']='萌月:BAAALAAECgUIBQAAAA==.',['落筱']='落筱羽:BAAALAAFFAIIAgAAAA==.',['蒙着']='蒙着眼睛的神:BAAALAAECgEIAQAAAA==.',['蓝色']='蓝色的萨满:BAAALAAFFAIIAgAAAA==.',['薪涯']='薪涯:BAAALAAECgYIBgAAAA==.',['虎步']='虎步关右:BAAALAAECgYIBgAAAA==.',['虫虫']='虫虫五号:BAAALAAECgIIAgAAAA==.',['蛇年']='蛇年灬吉祥:BAAALAADCgUIBQAAAA==.蛇年灬大发:BAAALAAECgEIAQAAAA==.蛇年灬平安:BAAALAADCggICAAAAA==.',['蜡笔']='蜡笔大心眼子:BAAALAAECgYIBgAAAA==.',['街溜']='街溜子:BAAALAAECgQIBAAAAA==.',['衡水']='衡水老白干:BAAALAADCggICAAAAA==.',['衣奎']='衣奎斯布林:BAABLAAFFH8YAAMMAAYIrRu9CQC4AQAMAAYIrRu9CQC4AQANAAUIHRdYHgBZAQAAAA==.',['言蹊']='言蹊:BAAALAAECggICAAAAA==.',['诸葛']='诸葛猪猪:BAAALAADCgcIBwAAAA==.',['诺诺']='诺诺的梅栗:BAAALAAECgYIBgAAAA==.',['豆子']='豆子威:BAABLAAFFH8GAAICAAIIoQu9FACDAAACAAIIoQu9FACDAAAAAA==.',['賸骑']='賸骑士:BAAALAAECgQIBAAAAA==.',['贪睡']='贪睡之熊:BAAALAAECgYIEQAAAA==.',['贰丶']='贰丶:BAABLAAFFH8MAAMTAAYIpyCUBADsAQATAAYIpyCUBADsAQAbAAYIzQn9BwBJAQAAAA==.',['赤帝']='赤帝苍星:BAABLAAFFH8bAAIHAAYIWB3dFwDBAQAHAAYIWB3dFwDBAQAAAA==.',['超级']='超级红手逗:BAABLAAFFH8cAAIBAAUI+hwqOABbAQABAAUI+hwqOABbAQAAAA==.',['迷津']='迷津:BAAALAADCgQIBAAAAA==.',['逆法']='逆法之殇:BAAALAAECgUIBQAAAA==.',['逍遥']='逍遥一找死:BAAALAADCgMIAwAAAA==.',['邪神']='邪神小脑:BAAALAAECgEIAQAAAA==.',['钢琴']='钢琴里的猫:BAAALAAFFAgIAgAAAA==.',['铃木']='铃木奶瓶:BAAALAAECggIDwAAAA==.铃木瓶瓶奶:BAABLAAFFH8GAAIYAAYIsQeHFgD+AAAYAAYIsQeHFgD+AAABLAAFFAgIBgAYAJwbAA==.',['银刃']='银刃猎魔人:BAAALAAFFAMIAwAAAA==.',['银驽']='银驽猎魔人:BAAALAAECgYIBgAAAA==.',['长夜']='长夜无声:BAABLAAFFH8bAAIWAAYIaxjCFwCYAQAWAAYIaxjCFwCYAQAAAA==.长夜无声丶:BAABLAAFFH8QAAIWAAYINgs0MgBOAQAWAAYINgs0MgBOAQAAAA==.',['随缘']='随缘而聚:BAAALAAFFAIIAgAAAA==.',['随风']='随风消散:BAAALAADCgQIBAAAAA==.',['难得']='难得优哉:BAAALAAECgYIBgAAAA==.',['零六']='零六捌:BAAALAAECgQIBwAAAA==.',['雷武']='雷武龙:BAAALAAECgIIBAAAAA==.',['露琪']='露琪亚:BAABLAAFFH8LAAIEAAUINBbHJwA7AQAEAAUINBbHJwA7AQAAAA==.',['霸奎']='霸奎斯布林:BAAALAAFFAYIAgAAAA==.',['青春']='青春无极限:BAAALAADCgEIAQAAAA==.',['青炎']='青炎:BAABLAAECn8VAAMXAAYIWRArdgA2AQAXAAYIWRArdgA2AQAaAAQIPgokiACjAAAAAA==.',['非洲']='非洲黑人挑逗:BAAALAAFFAIIAgAAAA==.',['飘渺']='飘渺小帅:BAAALAADCgMIBQAAAA==.飘渺小狂:BAAALAADCgYIBwAAAA==.飘渺随風:BAAALAAECgcICAAAAA==.',['飞肯']='飞肯:BAAALAADCgIIAgAAAA==.',['飞跃']='飞跃吧:BAAALAAECgMIAwAAAA==.',['騛號']='騛號殺誽:BAAALAAFFAIIAgAAAA==.',['鬼之']='鬼之暗騎:BAAALAAECgMIAwAAAA==.',['魂殇']='魂殇痕:BAACLAAFFH8HAAILAAIIDQcWbABPAAALAAIIDQcWbABPAAAsAAQKfygAAgsACAhLGt0fAPsBAAsACAhLGt0fAPsBAAAA.',['鸠奎']='鸠奎斯布林:BAABLAAFFH8GAAMMAAYIKhVmGAD4AAAMAAQIghdmGAD4AAANAAIIUg4DOACBAAAAAA==.',['麦噶']='麦噶尼银须:BAAALAAECggIEAABLAAFFAYIBgAUAAEOAA==.',['黑手']='黑手不摸怪:BAAALAAECgQIBQAAAA==.',['黑羽']='黑羽毛刀:BAABLAAFFH8NAAMIAAUIzgZlCgChAAAIAAUIcAVlCgChAAAJAAMI7wZJRAB0AAAAAA==.',['黯淡']='黯淡丶:BAAALAAECgIIAgAAAA==.',['齐奎']='齐奎斯布林:BAABLAAFFH8MAAMNAAYIzhBsGACOAQANAAYIzhBsGACOAQAMAAQIHhxiFwAHAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end