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
 local lookup = {'Priest-Holy','Unknown-Unknown','Warlock-Destruction','Warlock-Affliction','DemonHunter-Havoc','Warrior-Arms','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Warrior-Fury','Hunter-Marksmanship','DeathKnight-Blood','Warlock-Demonology','Shaman-Restoration','DeathKnight-Unholy','Paladin-Retribution','Hunter-BeastMastery','DemonHunter-Vengeance','Shaman-Enhancement','Mage-Arcane','Paladin-Protection','Mage-Frost','Druid-Feral','Druid-Balance','Shaman-Elemental',}; local provider = {region='CN',realm='黑暗之门',name='CN',type='weekly',zone=42,date='2025-08-04',data={Cr='Crossqs:BAAAKgAECgUIBQAAAA==.',De='Deathgirl:BAABKgAFFH8FAAIBAAMICQ/CJQCsAAABAAMICQ/CJQCsAAAAAA==.Devilenvoy:BAAAKgAECgIIBAAAAA==.',Kk='Kkp:BAAAKgAFFAgIBAAAAA==.',La='Lazyk:BAAAKgADCgMIAwAAAA==.',Li='Liberaheartt:BAAAKgAFFAIIBAAAAA==.Lihilineonn:BAAAKgAFFAIIAgAAAA==.',Lo='Longlivejah:BAAAKgAECgUIBQAAAA==.',Lu='Luciddreamss:BAAAKgAECgUICAABKgAFFAIIAgACAAAAAA==.',Sh='Shadow:BAAAKgAECgEIAQAAAA==.',['一一']='一一死亡:BAAAKgAECgQIBwAAAA==.',['一圣']='一圣一骑:BAAAKgAECgcICgAAAA==.',['一宿']='一宿:BAAAKgAECgYIDAAAAA==.',['一战']='一战到顶:BAAAKgAECgUIDQAAAA==.',['一把']='一把钝刀:BAAAKgADCggICAAAAA==.',['一斧']='一斧劈死你:BAAAKgAECgIIAgAAAA==.',['一朵']='一朵娇花:BAABKgAFFH8GAAMDAAQIEQ5KFwDGAAADAAQIEQ5KFwDGAAAEAAEIAAB6JAAAAAAAAA==.',['一根']='一根大前门:BAAAKgAECgIIAgAAAA==.',['一武']='一武一僧:BAAAKgAECgQICwAAAA==.',['一锤']='一锤子砸死你:BAAAKgADCggICAAAAA==.',['万能']='万能的耶耶:BAACKgAFFH8qAAIFAAYIPyEqDADDAQAFAAYIPyEqDADDAQAqAAQKfzQAAgUACAhcJicDAAcDAAUACAhcJicDAAcDAAAA.',['三界']='三界妖王:BAABKgAECn8iAAIGAAgITBa+FQDfAQAGAAgITBa+FQDfAQAAAA==.',['不行']='不行就死:BAAAKgAECgcIBwAAAA==.',['丨牧']='丨牧媤丨:BAAAKgADCggICAAAAA==.',['亚瑟']='亚瑟:BAAAKgAECgQIBAAAAA==.',['余生']='余生丶:BAAAKgAECgcICwAAAA==.',['倚人']='倚人间:BAACKgAFFH8IAAMHAAMIFhGeFgCzAAAHAAMIFhGeFgCzAAAIAAEIBgXdLwAwAAAqAAQKfycABAcACAgHImcKAJ8CAAcACAgHImcKAJ8CAAkABAgXEeMcAIsAAAgAAQjFB7OQAC8AAAAA.',['傲天']='傲天绝四:BAAAKgAECgQIBAAAAA==.',['儛蹈']='儛蹈琾阝可飒:BAAAKgAECgYICAAAAA==.',['兰登']='兰登:BAAAKgAFFAgIAgAAAA==.',['冰弑']='冰弑一图腾:BAAAKgAECggIDgAAAA==.',['冰镇']='冰镇丶西瓜汁:BAABKgAFFH8GAAIKAAYI8Ap+DwBdAQAKAAYI8Ap+DwBdAQAAAA==.',['凯子']='凯子哥哥:BAABKgAFFH8MAAILAAMIFxbAJwDLAAALAAMIFxbAJwDLAAAAAA==.',['加尔']='加尔鲁什丶:BAAAKgADCggICAAAAA==.',['千早']='千早爱音:BAABKgAFFH8YAAIMAAgI5CBeAgBpAgAMAAgI5CBeAgBpAgAAAA==.',['卡萝']='卡萝淋:BAACKgAFFH8MAAMNAAQIyh7HCQDpAAANAAQIyh7HCQDpAAADAAEImgtVNAA8AAAqAAQKfxUAAw0ACAgSF4oeAIwBAA0ACAhjFooeAIwBAAMABQjnDuB1AKoAAAAA.',['原神']='原神:BAAAKgAFFAYIBAAAAA==.',['可口']='可口灬可乐:BAABKgAECn8jAAIDAAgIvhhkHADDAQADAAgIvhhkHADDAQAAAA==.',['吴彦']='吴彦诅:BAABKgAFFH8SAAMDAAcILiS8AQDTAQADAAcI5CO8AQDTAQAEAAQI+hnkDQDGAAAAAA==.',['啦啦']='啦啦队:BAAAKgADCgIIAgAAAA==.',['噶尔']='噶尔:BAAAKgADCggICAAAAA==.',['土著']='土著:BAABKgAFFH8GAAIOAAYIfgf1GgATAQAOAAYIfgf1GgATAQAAAA==.',['墨卿']='墨卿:BAAAKgAFFAIIAgAAAA==.',['大声']='大声发:BAAAKgAECgYIBgAAAA==.',['大头']='大头白帝:BAABKgAFFH8IAAMMAAgIpBSYDgAzAQAMAAQIcReYDgAzAQAPAAQI6RCSNwC8AAAAAA==.',['大威']='大威天龙:BAAAKgAFFAMIAwAAAA==.',['大菇']='大菇:BAAAKgADCggICAAAAA==.',['天堂']='天堂晨歌:BAAAKgAECgEIAQAAAA==.',['天天']='天天惩戒:BAABKgAFFH8KAAIQAAYI/BeYGwCHAQAQAAYI/BeYGwCHAQAAAA==.',['天灬']='天灬下:BAAAKgAECgUIDQAAAA==.',['天界']='天界圣牛:BAAAKgAECgYIBgAAAA==.',['天空']='天空的颜色:BAAAKgAFFAIIAwAAAA==.',['失联']='失联:BAAAKgAECgUICQAAAA==.',['奔驰']='奔驰的小野马:BAAAKgADCgEIAQAAAA==.',['娇本']='娇本环刀:BAAAKgAECgIIAgAAAA==.',['婉若']='婉若游龙:BAAAKgAECgcIBwAAAA==.',['孙王']='孙王若兮:BAABKgAFFH8QAAMNAAMICByqFwCNAAANAAIIRhyqFwCNAAAEAAEIixvCHgBQAAAAAA==.孙王若潼:BAABKgAFFH8OAAMNAAMI9BJWGgB/AAANAAIILxJWGgB/AAAEAAII8Az5GAB4AAAAAA==.',['宝可']='宝可梦大师:BAAAKgADCggICAAAAA==.',['客观']='客观里面请:BAAAKgAECgYIBgAAAA==.',['寂静']='寂静的夜:BAABKgAECn8aAAIRAAYIRRkQigAcAQARAAYIRRkQigAcAQAAAA==.',['小小']='小小大王:BAAAKgAFFAgIBAAAAA==.',['小憨']='小憨憨:BAAAKgAFFAQIBAAAAA==.',['小超']='小超梦:BAAAKgAFFAIIAgAAAA==.',['尘世']='尘世殇:BAAAKgAFFAIIAgAAAA==.',['尛丶']='尛丶銘銘:BAACKgAFFH8GAAIQAAMIlAs6PgCLAAAQAAMIlAs6PgCLAAAqAAQKfxkAAhAACAiuFLhxALQBABAACAiuFLhxALQBAAAA.',['尾火']='尾火虎:BAAAKgAECgQIBAAAAA==.',['心越']='心越:BAAAKgAECgEIAQAAAA==.',['忧郁']='忧郁的沉默:BAAAKgADCggICAAAAA==.',['意起']='意起缘生:BAAAKgAFFAYIBAAAAA==.',['我有']='我有一个帽衫:BAAAKgAECgYIBgAAAA==.',['春风']='春风丶十里:BAAAKgAFFAYIAgABKgAFFAgIDwAIAO4LAA==.',['暗夜']='暗夜之灵:BAAAKgADCgYIBgAAAA==.',['最爱']='最爱小拽拽:BAAAKgAECgYICgAAAA==.',['有秩']='有秩序的围观:BAAAKgADCggICAAAAA==.',['木子']='木子丶:BAAAKgADCgUIBQAAAA==.木子灬:BAAAKgADCgMIAwAAAA==.',['未完']='未完结的故事:BAABKgAFFH8FAAISAAUIvAGkGwB3AAASAAUIvAGkGwB3AAAAAA==.',['李成']='李成敏:BAAAKgAECgIIAgAAAA==.',['李秋']='李秋恋:BAABKgAFFH8FAAITAAUIJhB2CgAoAQATAAUIJhB2CgAoAQAAAA==.',['林思']='林思璇:BAAAKgAECgMIAgAAAA==.',['柠檬']='柠檬糖:BAACKgAFFH8fAAMNAAgIRB0PAwBWAQANAAUILx4PAwBWAQADAAYIcBjxEgDZAAAqAAQKfzIAAwMACAjTI3wgAAICAAMABwiEH3wgAAICAA0ABghOJLYaAKUBAAAA.',['梦小']='梦小河:BAAAKgADCggICgAAAA==.',['梦晓']='梦晓荷:BAAAKgAFFAMIAwAAAA==.',['残暴']='残暴艾因号:BAACKgAFFH8aAAIMAAUIPSTICACMAQAMAAUIPSTICACMAQAqAAQKfyoAAgwACAioJI4DAOMCAAwACAioJI4DAOMCAAAA.',['毽球']='毽球小王子:BAAAKgAECgQIBwAAAA==.',['泠泠']='泠泠月上:BAABKgAFFH8KAAIUAAYI2htqAgDXAAAUAAYI2htqAgDXAAAAAA==.',['溯源']='溯源逆流:BAAAKgAECgYIBgAAAA==.',['潘多']='潘多拉烟盒:BAACKgAFFH8LAAIRAAUIEhr3CAA9AQARAAUIEhr3CAA9AQAqAAQKfyAAAhEACAi3I+sQALwCABEACAi3I+sQALwCAAAA.',['烈焰']='烈焰:BAAAKgAECgMIAwAAAA==.',['狗尾']='狗尾巴花:BAAAKgAECgYIBgAAAA==.',['玄参']='玄参:BAABKgAFFH8GAAIOAAYIrRsxCQB5AQAOAAYIrRsxCQB5AQAAAA==.',['玛德']='玛德绝了:BAACKgAFFH8HAAIKAAQI+RgBHQDgAAAKAAQI+RgBHQDgAAAqAAQKfxoAAgoACAiqHUITAD8CAAoACAiqHUITAD8CAAAA.',['看看']='看看你的牛牛:BAABKgAFFH8GAAIVAAQI7hxyEQD1AAAVAAQI7hxyEQD1AAABKgAFFAgICAAQAEseAA==.',['真难']='真难看啊:BAAAKgAECgUIBQAAAA==.',['离滋']='离滋味:BAAAKgADCgcIBwAAAA==.',['突然']='突然灬好想你:BAAAKgAECgIIAgAAAA==.',['糖纸']='糖纸:BAAAKgADCgEIAQAAAA==.',['绑桑']='绑桑迪:BAAAKgADCggICAAAAA==.',['羊养']='羊养羊:BAAAKgADCggICAAAAA==.',['自律']='自律的泰罗:BAAAKgAECgMIAwAAAA==.',['自閉']='自閉儿童:BAAAKgADCggICAAAAA==.',['莉亚']='莉亚徳琳:BAAAKgAECgYIEAAAAA==.',['莫罗']='莫罗思:BAAAKgAECgYIBgAAAA==.',['萌萌']='萌萌丨喵:BAAAKgAFFAEIAQAAAA==.',['蒜香']='蒜香小龙虾:BAABKgAFFH8NAAMIAAQIih6jCQAYAQAIAAQIih6jCQAYAQAJAAEIAABsCwAAAAAAAA==.',['血海']='血海带:BAAAKgAECggIDQAAAA==.',['血腥']='血腥马子:BAABKgAFFH8GAAMUAAYIlxZdFQA6AQAUAAUIEBldFQA6AQAWAAEIsAyEKwA8AAAAAA==.',['裏表']='裏表:BAAAKgADCgIIAgAAAA==.',['西北']='西北风在吹:BAAAKgAECgEIAQAAAA==.',['逝水']='逝水云茜:BAAAKgAFFAQIAwABKgAFFAgICgABAL0cAA==.',['野蠻']='野蠻執行者:BAACKgAFFH8PAAMXAAQISiJbAwAnAQAXAAMISiJbAwAnAQAYAAQIYA/LGwDQAAAqAAQKfxkAAhcABwj2G4gNANEBABcABwj2G4gNANEBAAAA.',['阳光']='阳光小母牛:BAABKgAFFH8MAAMOAAYIfCRAAAAoAgAOAAYIfCRAAAAoAgAZAAIILQkRFgBxAAAAAA==.',['阿坏']='阿坏:BAAAKgAECgUICQAAAA==.',['雪莉']='雪莉玫:BAAAKgADCggICAAAAA==.',['青青']='青青子衿丶:BAAAKgADCgIIBAAAAA==.',['风之']='风之铃音:BAAAKgAECgMIAwAAAA==.',['飞天']='飞天大焯:BAABKgAFFH8GAAMFAAMI7Q9QOgCVAAAFAAIIeBdQOgCVAAASAAEI1wAEKAATAAAAAA==.',['魏国']='魏国灬貂蝉:BAAAKgADCgUIBQAAAA==.',['鹏鹏']='鹏鹏新之助:BAAAKgAECgEIAQAAAA==.',['黑白']='黑白臆想:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end