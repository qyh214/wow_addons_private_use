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
 local lookup = {'Priest-Holy','DemonHunter-Havoc','Shaman-Elemental','Mage-Arcane','Mage-Fire','DeathKnight-Frost','Hunter-BeastMastery','Priest-Shadow','Unknown-Unknown','DeathKnight-Unholy','Shaman-Restoration','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','Hunter-Marksmanship','Mage-Frost','Druid-Restoration','DemonHunter-Vengeance','Paladin-Retribution','Warrior-Fury','Warrior-Protection','Paladin-Protection','Rogue-Assassination','Rogue-Subtlety','Druid-Balance','Monk-Mistweaver','Monk-Windwalker','Paladin-Holy','Druid-Guardian','Monk-Brewmaster','Hunter-Survival','DeathKnight-Blood','Warlock-Destruction','Warlock-Demonology',}; local provider = {region='CN',realm='时光之穴',name='CN',type='weekly',zone=44,date='2025-12-07',data={Ai='Airfar:BAAALAAECgYIDAAAAA==.',Al='Alicemay:BAAALAAECgEIAQAAAA==.',Ao='Aoeiuv:BAAALAAECgYIBgAAAA==.',As='Asdadad:BAAALAADCggICAAAAA==.',Ba='Baalzebul:BAAALAADCgYIBgAAAA==.Babyjen:BAABLAAFFH8GAAIBAAIIawHaTABJAAABAAIIawHaTABJAAAAAA==.Bao:BAAALAAECgIIAgAAAA==.',Bl='Blisse:BAABLAAFFH8GAAICAAYI9BeFJABqAQACAAYI9BeFJABqAQAAAA==.',Bo='Bob:BAAALAADCgMIAwAAAA==.Boling:BAABLAAFFH8OAAIDAAgIWBRYCAAuAgADAAgIWBRYCAAuAgAAAA==.Bonappetit:BAAALAAFFAIIAgAAAA==.',Ca='Capoo:BAACLAAFFH8tAAMEAAYIYyLKHgA7AQAEAAUI3SPKHgA7AQAFAAQI3BliBQD4AAAsAAQKfycAAwUACAhHIuoAALMCAAUACAgXIuoAALMCAAQABgi1IQFZAPkBAAAA.',Ch='Cherry:BAAALAAECgYICQAAAA==.',Cl='Claude:BAACLAAFFH8TAAICAAYIGh6mDwCxAQACAAYIGh6mDwCxAQAsAAQKfxwAAgIACAjUJAUNAEADAAIACAjUJAUNAEADAAAA.',Cm='Cmo:BAACLAAFFH8VAAIGAAUIsB8uIgAWAQAGAAUIsB8uIgAWAQAsAAQKfyEAAgYABwhBIFsxALIBAAYABwhBIFsxALIBAAAA.',Co='Corruption:BAAALAAECgQIBAAAAA==.',Da='Darkzelf:BAAALAAECgMIAwAAAA==.',De='Delta:BAAALAAECgMIBAAAAA==.',Dh='Dhqaq:BAABLAAFFH8aAAICAAYI/CIRDAALAgACAAYI/CIRDAALAgAAAA==.',El='Electronan:BAAALAAECgYIDgAAAA==.',Ev='Evil:BAABLAAFFH8FAAIHAAII4hoKjABIAAAHAAII4hoKjABIAAABLAAFFAYIDwAGAO0KAA==.',Fa='Fadasd:BAAALAAECgUIBQAAAA==.',Fu='Funnymadpee:BAACLAAFFH8IAAIBAAIIRB8YIwCtAAABAAIIRB8YIwCtAAAsAAQKfx8AAwEACAjVHW8gAHYCAAEABwjEHm8gAHYCAAgABQiqHZ1AALgBAAAA.',Gu='Gutysa:BAAALAAECgYIBgAAAA==.',Ha='Hazelmage:BAAALAAECgQIBwAAAA==.',Hi='Him:BAAALAAECgcIEAAAAA==.',Hu='Humo:BAAALAAECgYICQAAAA==.',Im='Imtouch:BAAALAAECgUIBQAAAA==.',Ja='Jas:BAAALAAFFAIIAgAAAA==.',Je='Jeruary:BAABLAAFFH8GAAIGAAIIXxwLRACtAAAGAAIIXxwLRACtAAAAAA==.',Jh='Jhwnb:BAAALAAECggIEgAAAA==.',La='Lastliadri:BAAALAAECgQIBAABLAAFFAIIBAAJAAAAAA==.Lastshadowx:BAABLAAFFH8TAAIKAAYIKBB2BABlAQAKAAYIKBB2BABlAQAAAA==.',Lu='Lune:BAAALAAECgUICAAAAA==.Luolisda:BAAALAAFFAIIAgAAAA==.',Ma='Maxion:BAABLAAFFH8iAAIHAAYIBCStDwAPAgAHAAYIBCStDwAPAgAAAA==.',Me='Memaf:BAAALAADCgQIBAAAAA==.',Mi='Mirria:BAABLAAFFH8OAAILAAII7iCHJQC8AAALAAII7iCHJQC8AAAAAA==.',Mm='Mmbee:BAAALAAECgYICAAAAA==.',Mo='Moga:BAACLAAFFH8QAAICAAYIfhbHHQCOAQACAAYIfhbHHQCOAQAsAAQKfxUAAgIACAj/Iq0bAPcCAAIACAj/Iq0bAPcCAAAA.',Na='Nanako:BAABLAAFFH8GAAQMAAQIWCZ4CQDoAAAMAAIIcSZ4CQDoAAANAAEIcyWjGgBbAAAOAAEIngBrIgApAAAAAA==.',Ne='Newmoreone:BAAALAAECgUIBQAAAA==.',Nn='Nnt:BAAALAAECgYIBgAAAA==.',No='Nothingtosay:BAAALAAECgYIBgAAAA==.Notrom:BAAALAAECgYICgAAAA==.',Oe='Oern:BAAALAAECgQIBgAAAA==.',Oo='Ook:BAAALAAFFAYIBAAAAA==.',Ra='Raven:BAAALAAFFAIIBAAAAA==.',Se='Seuqs:BAAALAAECgUIBQAAAA==.',Sh='Shaguar:BAABLAAFFH8HAAIPAAIITA80FgA/AAAPAAIITA80FgA/AAAAAA==.',Sp='Spz:BAACLAAFFH8GAAIQAAIIQh1xEgBQAAAQAAIIQh1xEgBQAAAsAAQKfxcAAhAACAjcG1sLAAgCABAACAjcG1sLAAgCAAAA.',Su='Sunper:BAAALAAECgUIBQAAAA==.',Sw='Swiftbean:BAAALAAECgYIEgAAAA==.',Sy='Sylvana:BAABLAAFFH8NAAIHAAYI7BwEJwCZAQAHAAYI7BwEJwCZAQAAAA==.',Th='Thinker:BAAALAAFFAIIAgAAAA==.',Tw='Twinkles:BAAALAAECgEIAQAAAA==.',Vi='Vivdoun:BAAALAADCgEIAQAAAA==.',Wa='Waidlady:BAAALAADCgEIAQAAAA==.',['一刀']='一刀上云霄:BAAALAAFFAIIBAAAAA==.',['一念']='一念天堂地狱:BAAALAAECgQIBgAAAA==.',['一溜']='一溜黑烟:BAAALAADCgIIAgAAAA==.',['一發']='一發入魂:BAABLAAFFH8GAAMQAAIIOQpnFgB/AAAQAAIIOQpnFgB/AAAEAAEI5QIZaQAvAAAAAA==.',['一眼']='一眼千年万语:BAAALAAECggIDgAAAA==.',['一颗']='一颗大蒜:BAAALAAFFAIIBAAAAA==.',['七妹']='七妹:BAAALAAECgMIAwAAAA==.',['三月']='三月你好吗丶:BAAALAADCgcIBwAAAA==.',['不会']='不会武功啊:BAAALAAECgYICwAAAA==.',['不送']='不送:BAABLAAFFH8KAAIFAAYIowHUBgCnAAAFAAYIowHUBgCnAAAAAA==.',['丨丅']='丨丅凸丅丨:BAACLAAFFH8WAAIRAAMIVRIvLwCwAAARAAMIVRIvLwCwAAAsAAQKfyYAAhEACAjnGL4sAC8CABEACAjnGL4sAC8CAAAA.',['丨憶']='丨憶丶無限丨:BAAALAAECgQIBAAAAA==.',['丨莫']='丨莫及丨:BAAALAAECgQIBQAAAA==.',['丶红']='丶红尘:BAAALAAECgYIBgAAAA==.',['主要']='主要瞄得准:BAAALAAECgYICAAAAA==.',['丽丽']='丽丽喵:BAAALAAECgYIBgAAAA==.',['丿随']='丿随风散:BAAALAAECgQIBAAAAA==.',['乌兰']='乌兰巴图:BAAALAAECgQIBAAAAA==.',['乛一']='乛一乛:BAAALAADCgIIAgAAAA==.',['予星']='予星:BAAALAAFFAIIBAAAAA==.',['二瞎']='二瞎子:BAABLAAFFH8IAAMSAAQIvgcODwBUAAASAAMI9QkODwBUAAACAAEIGgHrcAAUAAAAAA==.',['二蛤']='二蛤饥渴熊:BAABLAAFFH8ZAAMHAAYICRohLQCEAQAHAAYICRohLQCEAQAPAAIIJw1+KgByAAAAAA==.',['五点']='五点:BAAALAAECgEIAQAAAA==.',['亦笔']='亦笔雕凿:BAABLAAFFH8GAAIHAAII8BuATwCWAAAHAAII8BuATwCWAAABLAAFFAYICQACAKkiAA==.',['亮鳞']='亮鳞:BAAALAADCgIIAgAAAA==.',['今晚']='今晚关灯吃面:BAAALAAECgUIBwAAAA==.',['伍德']='伍德凯:BAABLAAFFH8KAAIGAAIIZQzIfACJAAAGAAIIZQzIfACJAAAAAA==.',['会哭']='会哭的锅子:BAABLAAFFH8GAAMBAAYI7RRcGwB2AQABAAUIyRdcGwB2AQAIAAEI6AegKgBCAAAAAA==.',['传奇']='传奇耐奶王:BAAALAAECgYIBgAAAA==.',['低调']='低调的猎熊人:BAABLAAFFH8WAAIHAAUImSD0KwCHAQAHAAUImSD0KwCHAQAAAA==.',['你跺']='你跺你也麻:BAAALAAECggICAAAAA==.',['佬公']='佬公:BAAALAAECgYIBgAAAA==.',['修假']='修假:BAAALAAECggICAAAAA==.',['修车']='修车佬的梦想:BAAALAADCgIIAgAAAA==.',['儱陾']='儱陾:BAAALAAECgYICQAAAA==.',['光铸']='光铸神乐:BAAALAADCgQIBAAAAA==.',['克库']='克库尔伊比:BAAALAAFFAIIAgABLAAFFAgIJAANAAYcAA==.',['克洛']='克洛伊丹:BAABLAAECn8VAAIEAAYIXgZuWgCYAAAEAAYIXgZuWgCYAAAAAA==.',['兔兔']='兔兔憨:BAAALAADCgYIBgAAAA==.',['全糖']='全糖加冰:BAAALAAECgYIDAAAAA==.',['六六']='六六吖:BAAALAAECgIIAgAAAA==.六六呀:BAAALAAFFAIIAgAAAA==.六六很菜:BAABLAAECn8VAAMEAAYIcgzRRQDyAAAEAAYIaAzRRQDyAAAQAAMIkQc/QgBRAAAAAA==.',['其实']='其实是小熊猫:BAAALAAFFAIIBAAAAA==.',['再梦']='再梦世界:BAAALAAECgYICAAAAA==.',['冬日']='冬日祈愿:BAAALAAECgYIBgAAAA==.',['冬栀']='冬栀:BAABLAAFFH8XAAIBAAUIrgU0KADxAAABAAUIrgU0KADxAAAAAA==.',['冰大']='冰大师寒冰:BAABLAAFFH8GAAIEAAYIFBPbKgBoAQAEAAYIFBPbKgBoAQAAAA==.',['冰莓']='冰莓:BAAALAAECgYIBgAAAA==.',['冰霜']='冰霜神乐:BAAALAADCgIIAgAAAA==.',['冲钅']='冲钅点复活:BAAALAAECgUIBQABLAAFFAYIHQAHAB8bAA==.',['冷漠']='冷漠的呆法:BAAALAADCgYIBgAAAA==.',['冷面']='冷面大青聋:BAACLAAFFH8nAAQOAAYIqBVxCABEAQAOAAUIVxdxCABEAQAMAAUIRxTcBwAhAQANAAEIuA8fJwAAAAAsAAQKfxoAAw0ACAimGXQZAFMCAA0ACAiMGHQZAFMCAAwABQijGq4QADsBAAAA.',['凌波']='凌波丽:BAAALAAFFAIIAgABLAAFFAUIEQATAL8KAA==.',['刘碧']='刘碧诚:BAAALAAECgYICAAAAA==.',['别乱']='别乱搞我来顶:BAAALAAECggICAAAAA==.',['削肾']='削肾客丶:BAAALAADCgQIBAAAAA==.',['功夫']='功夫恰恰:BAAALAAECggIEgAAAA==.功夫猫猫:BAAALAAECgYIBgAAAA==.功夫粒粒:BAAALAADCgIIAgAAAA==.功夫魔魔:BAAALAAECgYIDAAAAA==.',['加什']='加什么鲁队长:BAACLAAFFH8QAAMUAAUIMhPzJgA6AQAUAAUIMhPzJgA6AQAVAAIIBwWzLQBfAAAsAAQKfxQAAxUACAjiE6Y9AI4BABUACAjiE6Y9AI4BABQAAQhDCtqkADYAAAAA.',['动物']='动物凶猛啊:BAAALAAECgYIEgAAAA==.动物庄园:BAAALAADCgEIAQAAAA==.',['劲风']='劲风:BAAALAADCgYIBgAAAA==.',['勇敢']='勇敢的小迪迪:BAAALAAFFAIIAgAAAA==.',['半岛']='半岛铁盒丶:BAABLAAFFH8VAAIHAAYInB6NEwCHAQAHAAYInB6NEwCHAQAAAA==.',['半瓶']='半瓶芬达:BAABLAAFFH8XAAITAAYIlhv2FQChAQATAAYIlhv2FQChAQAAAA==.',['卑劣']='卑劣的街头:BAAALAADCgYIBgAAAA==.',['单修']='单修贼:BAAALAAFFAIIAgAAAA==.',['南德']='南德狐图:BAAALAAECgIIAgAAAA==.',['南瓜']='南瓜二米粥:BAACLAAFFH8YAAITAAYI1iTnBwANAgATAAYI1iTnBwANAgAsAAQKfzYAAxMACAhJJnADAIEDABMACAhJJnADAIEDABYABgg9INIXADkCAAAA.',['原批']='原批:BAABLAAFFH8LAAILAAYIDCCbCgAlAgALAAYIDCCbCgAlAgAAAA==.',['原老']='原老师:BAAALAAFFAIIAgAAAA==.',['双刀']='双刀老头:BAAALAAECgMIAwAAAA==.',['古德']='古德:BAABLAAFFH8HAAIWAAIIPRnLEQCPAAAWAAIIPRnLEQCPAAABLAAFFAcIJAAEACMhAA==.',['只吃']='只吃香菜:BAABLAAFFH8GAAIGAAII4hPofQBHAAAGAAII4hPofQBHAAAAAA==.',['叶暖']='叶暖醉流光丶:BAAALAAFFAIIAgAAAA==.',['叹息']='叹息夜星无眠:BAACLAAFFH9YAAMXAAgIqSAwAgD1AQAXAAcI7SAwAgD1AQAYAAUIjBNjCAAkAQAsAAQKfyYAAxcACAhXI8IJAOsCABcACAg4I8IJAOsCABgABQhJHkANADYBAAAA.',['吃肉']='吃肉小怪兽:BAAALAAFFAMIBAAAAA==.',['后会']='后会远期:BAAALAAECgUIBQAAAA==.',['呀呀']='呀呀帝:BAACLAAFFH8LAAIPAAMIrBneDwDwAAAPAAMIrBneDwDwAAAsAAQKfyIAAg8ACAgIIHcUAL8CAA8ACAgIIHcUAL8CAAAA.',['咕噜']='咕噜咕:BAAALAAECgYIBgAAAA==.',['咕德']='咕德摆:BAAALAAECgMIBAAAAA==.',['咖啡']='咖啡不加奶:BAAALAAECgIIAgAAAA==.',['哇哈']='哇哈哈一:BAABLAAFFH8GAAIEAAIINRRvQgCdAAAEAAIINRRvQgCdAAAAAA==.',['哇煤']='哇煤球儿:BAAALAADCgUIBQAAAA==.',['哈基']='哈基喵:BAABLAAFFH8OAAIRAAYI9xqdEwCgAQARAAYI9xqdEwCgAQABLAAFFAYIHQAHAB8bAA==.',['哎小']='哎小萌:BAAALAAECgYIBgAAAA==.',['哒哒']='哒哒酱:BAAALAAFFAIIAgAAAA==.',['唯物']='唯物辩证法则:BAAALAADCgYICAAAAA==.',['啊灬']='啊灬米洛斯:BAAALAAECgIIAgAAAA==.',['喜剧']='喜剧人物:BAAALAADCgQIBAAAAA==.',['喜欢']='喜欢春天:BAAALAAECgYIDAAAAA==.',['喝血']='喝血吼烈酒:BAABLAAFFH8GAAIVAAIIJhSuHACGAAAVAAIIJhSuHACGAAAAAA==.',['喵喵']='喵喵踩键盘:BAAALAADCgYIBgAAAA==.',['噫犁']='噫犁蛋丶绝决:BAABLAAFFH8GAAISAAII1BFpEABzAAASAAII1BFpEABzAAAAAA==.',['土豆']='土豆哦:BAAALAAECgYICQAAAA==.',['圣光']='圣光之愿:BAAALAAECgIIAwAAAA==.圣光灬德:BAABLAAECn8XAAITAAYIUhrDlwDEAQATAAYIUhrDlwDEAQAAAA==.圣光灬牧:BAAALAADCgYIBgAAAA==.',['圣殿']='圣殿裁决者:BAAALAAECgYIBgAAAA==.',['墨疏']='墨疏影猎:BAAALAAECgEIAQAAAA==.',['夏天']='夏天的绿叶丶:BAAALAAFFAIIAgAAAA==.',['夏川']='夏川真凉:BAABLAAFFH8FAAIHAAUIpQaaWwDdAAAHAAUIpQaaWwDdAAAAAA==.',['夏普']='夏普:BAAALAAECgMIAwAAAA==.',['外宝']='外宝兴路:BAAALAAECgYIBgAAAA==.',['夜之']='夜之箭:BAAALAAECgIIAgAAAA==.',['夜夜']='夜夜不归:BAAALAAFFAIIAgAAAA==.夜夜不归的德:BAABLAAFFH8FAAIZAAIIzwpnJQB8AAAZAAIIzwpnJQB8AAAAAA==.',['夜曲']='夜曲丶:BAAALAADCgMIAwAAAA==.',['大刀']='大刀瞎:BAAALAAECgYIBgAAAA==.',['大耄']='大耄哈天:BAAALAADCggICAAAAA==.',['大耳']='大耳狐:BAACLAAFFH8KAAIHAAIIASa8KwDRAAAHAAIIASa8KwDRAAAsAAQKfyEAAwcACAijJeAHAFYDAAcACAijJeAHAFYDAA8ABghNEfBaAE8BAAAA.',['大胃']='大胃袋:BAAALAAECgUICAAAAA==.',['大飞']='大飞飞:BAAALAAECgYIEgABLAAFFAgIMAARAI0WAA==.',['天使']='天使的恐惧:BAAALAAECgQIBAAAAA==.',['天时']='天时地利人和:BAAALAADCgcIBwAAAA==.',['天穹']='天穹仙:BAAALAAECgEIAQAAAA==.',['太湖']='太湖小小鲨鱼:BAAALAAFFAIIAgAAAA==.',['失温']='失温症:BAAALAAECggICQAAAA==.',['奔跑']='奔跑的牛牛啊:BAABLAAFFH8GAAIZAAYIZANpJwB6AAAZAAYIZANpJwB6AAAAAA==.',['奔驰']='奔驰哥哥:BAAALAAECgUICQAAAA==.',['奢侈']='奢侈品大佬:BAAALAAFFAYIAgAAAA==.',['奶黑']='奶黑奶:BAAALAAECgcICAAAAA==.',['她与']='她与遗憾皆在:BAAALAAECgYIBwAAAA==.',['妍妍']='妍妍六:BAAALAAECgEIAQAAAA==.',['姂姥']='姂姥之鹰:BAAALAAFFAIIAgAAAA==.',['娜塔']='娜塔莎欧尼酱:BAAALAAECgYICQAAAA==.',['娶银']='娶银河嫁九天:BAAALAADCgUIBQAAAA==.',['子轩']='子轩灬:BAAALAAECgYIBgAAAA==.',['孙小']='孙小弎:BAAALAAECgYIBgAAAA==.',['宇云']='宇云初晴:BAAALAAECgQIBAAAAA==.',['宇宙']='宇宙不及小熊:BAAALAAECgYIDAAAAA==.宇宙不敌小熊:BAACLAAFFH8TAAMGAAYIDA8jRgAlAQAGAAUI2RAjRgAlAQAKAAIIogp6EgBMAAAsAAQKfxcAAwYACAi7GjJXAEkCAAYABwhlGzJXAEkCAAoAAgg/FGZMAIYAAAAA.宇宙罚泽:BAAALAADCgEIAQAAAA==.',['宇逸']='宇逸清风:BAABLAAFFH8JAAIHAAMIiwfsfQBfAAAHAAMIiwfsfQBfAAAAAA==.',['宇霄']='宇霄栖鹤:BAAALAAECgQIBAAAAA==.',['安德']='安德神:BAAALAAECgUIBwAAAA==.',['宝贝']='宝贝姨求你了:BAAALAAECgQIBAAAAA==.',['实名']='实名制上网:BAAALAAECgcIBwAAAA==.',['寒冰']='寒冰丶恶魔:BAAALAAECgYICQAAAA==.寒冰丶萨满:BAAALAAFFAgIBAAAAA==.',['小伙']='小伙子丶:BAAALAAECgYIDAAAAA==.',['小咕']='小咕伊人:BAAALAAFFAIIBAAAAA==.',['小星']='小星星:BAAALAAFFAIIAgAAAA==.',['小灰']='小灰灰:BAABLAAFFH8GAAIGAAIIaBZOXQCZAAAGAAIIaBZOXQCZAAAAAA==.',['小熵']='小熵:BAAALAADCgIIAgAAAA==.',['小猫']='小猫米米:BAAALAADCgMIAwAAAA==.',['小粥']='小粥熊:BAABLAAFFH8TAAIHAAcIChesGgDMAQAHAAcIChesGgDMAQAAAA==.',['小胖']='小胖打桩机:BAABLAAFFH8FAAMaAAMIdhmLCAARAQAaAAMIdhmLCAARAQAbAAIIoQqQGAA8AAAAAA==.小胖秋:BAAALAAECgYICAAAAA==.',['小苗']='小苗呀:BAABLAAFFH8GAAIHAAYIsQW8TQAaAQAHAAYIsQW8TQAaAQAAAA==.',['小飞']='小飞飞:BAAALAAECgYIEgAAAA==.',['小饭']='小饭团:BAABLAAECn8UAAIcAAYIYh5jDgANAgAcAAYIYh5jDgANAgAAAA==.',['小马']='小马佩德罗:BAABLAAFFH8aAAMDAAYIoRVJFgCMAQADAAYIoRVJFgCMAQALAAUI1Q6TLAAGAQAAAA==.',['小魔']='小魔元素萨:BAAALAAECgYIBgAAAA==.',['小鱼']='小鱼山:BAAALAADCgYIBgAAAA==.',['川妹']='川妹子:BAAALAADCgEIAQAAAA==.',['巴博']='巴博斯:BAAALAAECgEIAQAAAA==.',['布丁']='布丁西米:BAAALAADCgUICAAAAA==.',['帅小']='帅小斩:BAABLAAFFH8IAAIVAAIIwwGDMgA8AAAVAAIIwwGDMgA8AAAAAA==.',['帅气']='帅气的螃蟹:BAAALAAECgYICwAAAA==.',['希埃']='希埃尔之翼:BAABLAAECn8gAAMHAAgInBVlfwDgAQAHAAgIOxVlfwDgAQAPAAcIHhMTRQChAQAAAA==.',['帕劳']='帕劳:BAACLAAFFH8iAAQNAAcIBB6CCQCFAQANAAYIeRyCCQCFAQAMAAUISRyrBgBLAQAOAAEImgYgHAA+AAAsAAQKfx4AAw0ABgiJIg8fACICAA0ABgiJIg8fACICAA4ABQiWCwAvAOkAAAAA.',['常山']='常山赵老三:BAAALAAFFAIIAgAAAA==.',['平凡']='平凡者:BAAALAAECgEIAQAAAA==.',['幺饒']='幺饒:BAAALAAECgUIBQAAAA==.',['弑神']='弑神六六:BAAALAAECgUIBAAAAA==.',['张小']='张小张:BAACLAAFFH8IAAIGAAIIAgm1nwA2AAAGAAIIAgm1nwA2AAAsAAQKfxkAAgYACAjDDoxBAH4BAAYACAjDDoxBAH4BAAAA.',['归去']='归去来兮丶:BAAALAAECgYIBgAAAA==.',['往后']='往后丶余生:BAAALAADCgEIAQAAAA==.',['微风']='微风治愈者:BAAALAAECgQIBAAAAA==.',['德天']='德天肥牛:BAABLAAFFH8HAAIRAAIItyIEFwDHAAARAAIItyIEFwDHAAAAAA==.',['德道']='德道:BAAALAAECgYIBgAAAA==.',['德鲁']='德鲁姨:BAAALAAECgUIBQAAAA==.',['心愿']='心愿先生灬:BAAALAAECgYIBwAAAA==.',['心觉']='心觉大师:BAAALAAECgYIDQAAAA==.',['情书']='情书:BAAALAAECgYIBgAAAA==.',['惠山']='惠山园长:BAAALAAECgQIBAAAAA==.',['慕忘']='慕忘言:BAABLAAFFH8IAAMBAAgIpQzlGwByAQABAAYIXQ3lGwByAQAIAAIIIgcCIACKAAAAAA==.',['成橙']='成橙橙成骋:BAAALAAECgYICwAAAA==.',['我为']='我为人人为我:BAAALAADCgcIBwAAAA==.',['我们']='我们是好朋友:BAAALAADCgMIAwAAAA==.',['我在']='我在后面看着:BAAALAADCgYIBgAAAA==.',['我执']='我执:BAAALAAECgIIAgAAAA==.',['我爱']='我爱一条牧:BAAALAAECgYIBgAAAA==.',['我锤']='我锤子呢:BAAALAAECgIIAgAAAA==.',['战刃']='战刃不是我的:BAAALAAECgcIBwAAAA==.',['打小']='打小就爱闹:BAAALAAECgUIBQAAAA==.',['托尼']='托尼丨斯塔克:BAAALAADCgYICwAAAA==.',['扬眉']='扬眉:BAABLAAFFH8HAAITAAMIACR1IADPAAATAAMIACR1IADPAAAAAA==.',['把酒']='把酒黄昏后丶:BAABLAAFFH8MAAILAAYInR0uDwDxAQALAAYInR0uDwDxAQAAAA==.',['抓猪']='抓猪壮士:BAABLAAECn8aAAMHAAgIaxKTZgB3AQAHAAcI/hSTZgB3AQAPAAgIsQKusQBMAAAAAA==.',['拉格']='拉格:BAAALAADCgEIAQAAAA==.',['挚爱']='挚爱灬小天:BAAALAADCgcIGQAAAA==.',['捕鱼']='捕鱼人:BAAALAAFFAIIAgAAAA==.',['放纸']='放纸鸢:BAAALAAFFAQIAgAAAA==.',['敢想']='敢想敢干:BAAALAAECgYICAAAAA==.',['新鲜']='新鲜野兽汤:BAAALAAECgcICAAAAA==.',['无敌']='无敌炉石回城:BAAALAAECggIDgAAAA==.',['无迪']='无迪:BAAALAAECggIEQAAAA==.',['无量']='无量:BAACLAAFFH8OAAIaAAIIuB9YEAC3AAAaAAIIuB9YEAC3AAAsAAQKfyAAAhoABgg0IM0JACcCABoABgg0IM0JACcCAAEsAAUUBggiAAsAYRIA.',['星回']='星回隐月:BAABLAAFFH8TAAIOAAMIwhbzFAC4AAAOAAMIwhbzFAC4AAAAAA==.',['星星']='星星都晓得:BAAALAADCgIIAgAAAA==.',['星辰']='星辰萨:BAAALAAFFAIIBAAAAA==.',['星际']='星际混元弟子:BAAALAAECgYIDQABLAAFFAIIBAAJAAAAAA==.',['春日']='春日影:BAAALAAECgEIAQAAAA==.',['晨兮']='晨兮兮:BAAALAAECgYIBwAAAA==.',['晨嘻']='晨嘻嘻:BAAALAAFFAIIAgAAAA==.',['晨惜']='晨惜惜:BAAALAAFFAIIAgAAAA==.',['暗夜']='暗夜老叔叔:BAABLAAFFH8MAAIdAAUIZQ9VBQDSAAAdAAUIZQ9VBQDSAAAAAA==.暗夜霜露:BAAALAAECgIIAgAAAA==.',['暗影']='暗影延伸:BAAALAAECgIIAgAAAA==.',['暴雨']='暴雨不上班:BAAALAADCgQIBgAAAA==.',['暴龙']='暴龙战神:BAABLAAFFH8LAAICAAYI6CGQEADeAQACAAYI6CGQEADeAQAAAA==.',['曼哈']='曼哈顿博士:BAABLAAECn8UAAMLAAYIDwl47gC6AAALAAYIDwl47gC6AAADAAQI2AzEYACTAAAAAA==.',['最后']='最后四圈:BAAALAADCgYIBgAAAA==.',['最强']='最强阴阳师:BAAALAAECgUIBQAAAA==.',['月亮']='月亮几点睡:BAAALAAECgUIBQAAAA==.',['有怪']='有怪仙人上:BAAALAAECgYIBgAAAA==.',['朝比']='朝比奈真冬:BAABLAAECn8YAAIeAAcIXSM4CQDRAgAeAAcIXSM4CQDRAgAAAA==.',['本茜']='本茜雅雅:BAAALAADCgEIAQAAAA==.',['朱北']='朱北朱北:BAAALAAECgQIBAAAAA==.',['杀马']='杀马特细芬:BAACLAAFFH8GAAIYAAII4BMXEwCOAAAYAAII4BMXEwCOAAAsAAQKfxkAAxgABgheIBoSACACABgABgheIBoSACACABcAAQh9GI1rAD4AAAAA.',['来年']='来年追寻:BAAALAADCgUIBQAAAA==.',['来随']='来随便:BAABLAAFFH8KAAIGAAYIaQJvTQD4AAAGAAYIaQJvTQD4AAAAAA==.',['林智']='林智妍:BAACLAAFFH8VAAMKAAYI7BqrBwAJAQAKAAQIrh+rBwAJAQAGAAMIcRZmXgCTAAAsAAQKfxQAAwYACAgGIC1/APsBAAYACAgGIC1/APsBAAoAAwj4HFpAANoAAAEsAAUUBggdAAcAHxsA.',['枫白']='枫白:BAABLAAFFH8RAAMTAAUIvwr6MAACAQATAAUIvwr6MAACAQAcAAIIByGfEwDCAAAAAA==.',['柒烨']='柒烨:BAAALAAFFAIIAgAAAA==.',['栎泽']='栎泽:BAAALAADCgcIBwAAAA==.',['梅普']='梅普露:BAAALAAECgYIBwAAAA==.',['梦之']='梦之心:BAAALAAECgYICQAAAA==.',['梦魇']='梦魇之心:BAAALAAECggICAAAAA==.',['梧桐']='梧桐小朵:BAACLAAFFH8MAAIGAAIIkw6ybwCQAAAGAAIIkw6ybwCQAAAsAAQKfzcAAgYACAiHGgZMAGICAAYACAiHGgZMAGICAAAA.',['梨灬']='梨灬瞳:BAABLAAFFH8GAAIEAAIIzxM/UgCPAAAEAAIIzxM/UgCPAAAAAA==.',['橘子']='橘子海:BAAALAAECgYICgAAAA==.',['橘芋']='橘芋:BAABLAAFFH8GAAIDAAYIYhBSIQA5AQADAAYIYhBSIQA5AQAAAA==.',['欢歌']='欢歌笑语:BAAALAAECgEIAQAAAA==.',['武斌']='武斌:BAAALAAFFAIIBAAAAA==.',['死亡']='死亡如风:BAAALAAFFAIIBAAAAA==.',['毋畏']='毋畏死兆:BAAALAAECgMIAwAAAA==.',['气质']='气质担当:BAABLAAFFH8IAAILAAIIPhg0PwCDAAALAAIIPhg0PwCDAAAAAA==.',['氵白']='氵白夜:BAAALAAECgcICQAAAA==.',['氵述']='氵述:BAAALAAECgQIBAAAAA==.',['永恒']='永恒黎明:BAAALAAFFAIIAgAAAA==.',['沃尔']='沃尔夫斯:BAAALAAECgcIDQAAAA==.',['法殇']='法殇:BAAALAAFFAMIAwAAAA==.',['法爷']='法爷来了:BAAALAADCgMIAwAAAA==.',['泡泡']='泡泡灬拾叁:BAABLAAFFH8MAAIeAAYIdhUNEABLAQAeAAYIdhUNEABLAQAAAA==.',['洋子']='洋子:BAAALAAECgEIAQAAAA==.',['洛丹']='洛丹佐:BAAALAAECgYICAAAAA==.',['洛阿']='洛阿浮屠:BAAALAAECgYIBgAAAA==.',['洞若']='洞若观火丶:BAAALAAECgMIAwAAAA==.',['浅羽']='浅羽优真:BAABLAAFFH8HAAIHAAUIBBkuSAAtAQAHAAUIBBkuSAAtAQAAAA==.',['浩浩']='浩浩丶酱:BAAALAAECggICAAAAA==.',['浮光']='浮光忆流年:BAAALAAECgYICQAAAA==.',['消磨']='消磨时光:BAAALAADCgYICgAAAA==.',['深夜']='深夜电台:BAAALAAFFAIIAgAAAA==.',['漆黑']='漆黑魅影:BAAALAADCgQIAQAAAA==.',['火拳']='火拳流:BAAALAAECgMIAwAAAA==.',['灬哔']='灬哔灬哔灬:BAACLAAFFH8dAAMHAAYIHxtbEQCgAQAHAAUIshlbEQCgAQAPAAYIoRgtCwBDAQAsAAQKfyIABA8ACAgnJDoKABMDAA8ACAh0IjoKABMDAAcABAj5GukSARUBAB8AAQiwG8IjAEcAAAAA.',['灬花']='灬花花大王灬:BAAALAADCgMIAwAAAA==.',['灼眼']='灼眼夏翎娜:BAAALAAECgYICgAAAA==.',['炎麒']='炎麒:BAAALAADCgMIAwAAAA==.',['烙印']='烙印剑士格斯:BAAALAAECgYICAAAAA==.',['烟囱']='烟囱囱:BAABLAAFFH8GAAMHAAII4hPKVwCRAAAHAAIItxHKVwCRAAAPAAIIVhGAJQB9AAABLAAFFAgIHAAZAOIkAA==.',['焦糖']='焦糖瓜子:BAAALAADCggICAAAAA==.',['熊猫']='熊猫人丶佳玉:BAAALAAFFAQIBAAAAA==.',['熊老']='熊老师:BAAALAADCgQIBAAAAA==.',['熟透']='熟透了:BAAALAAECgUIBQAAAA==.',['熬夜']='熬夜伤眼圈:BAAALAAECgYIBwAAAA==.',['燕子']='燕子别走:BAAALAADCgIIAgAAAA==.',['爆爆']='爆爆:BAAALAAECgEIAQAAAA==.',['爱吃']='爱吃蓝莓:BAAALAAECgYIBgAAAA==.爱吃鸡腿:BAAALAAECgYIBgAAAA==.',['爱意']='爱意东升西落:BAAALAAECgYICwAAAA==.',['特龙']='特龙娜米:BAABLAAFFH8IAAIRAAIIyRa+LQB6AAARAAIIyRa+LQB6AAAAAA==.特龙米璐:BAAALAAFFAIIBAAAAA==.',['狂战']='狂战神乐:BAAALAADCgQIBAAAAA==.',['狂雷']='狂雷真人:BAAALAADCgQIBAAAAA==.',['狐憨']='狐憨憨:BAAALAADCgQIBAAAAA==.',['独孤']='独孤真人:BAAALAAECgYIBwAAAA==.',['独打']='独打光头:BAAALAAECgYICQAAAA==.',['猪滑']='猪滑:BAAALAAECggICAAAAA==.',['猫咪']='猫咪公主:BAAALAAECgMIAwAAAA==.',['猫沫']='猫沫沫:BAAALAAECgUIBQAAAA==.',['猫猫']='猫猫森丶:BAABLAAFFH8MAAIEAAIIwiKaMQDDAAAEAAIIwiKaMQDDAAAAAA==.',['猴赛']='猴赛雷灬:BAAALAAECgEIAQAAAA==.',['玄救']='玄救非氪改命:BAAALAAFFAIIAgAAAA==.',['玄玉']='玄玉龙枪:BAAALAAECgMIBAAAAA==.',['玩谁']='玩谁都教学:BAAALAAFFAIIAgAAAA==.',['珊灬']='珊灬璞:BAAALAAECgIIAgAAAA==.',['瑞尔']='瑞尔希斯特:BAAALAAECgYICAAAAA==.',['瓦塔']='瓦塔诺:BAABLAAFFH8TAAIUAAYIxhbgFwChAQAUAAYIxhbgFwChAQAAAA==.',['瓦尔']='瓦尔西:BAACLAAFFH8dAAIHAAYIMhsXJQCgAQAHAAYIMhsXJQCgAQAsAAQKfxUAAgcABgiUHzZpAAgCAAcABgiUHzZpAAgCAAAA.',['甜妹']='甜妹:BAAALAAECgIIAgAAAA==.',['生气']='生气骑:BAAALAAECgMIAwAAAA==.',['生灵']='生灵:BAAALAAECgYICAAAAA==.',['疾风']='疾风猎头者:BAAALAAECgMIAwAAAA==.',['白孜']='白孜孜:BAAALAAECgYIBwAAAA==.',['白尛']='白尛兎丶:BAABLAAECn8WAAIOAAcIRRUkGADCAQAOAAcIRRUkGADCAQAAAA==.',['白月']='白月光丶:BAAALAAECgYIDAAAAA==.',['白煞']='白煞魔杰:BAAALAAECgYIBwAAAA==.',['白藏']='白藏主丶:BAAALAAFFAIIAgAAAA==.',['白衣']='白衣飞烟:BAAALAAFFAIIBAAAAA==.',['白静']='白静静:BAAALAAECgIIAgAAAA==.',['白鸥']='白鸥归巷里:BAAALAAECggICAAAAA==.',['百思']='百思不得骑芥:BAAALAAECgQIBQAAAA==.',['皮卡']='皮卡皮卡:BAABLAAFFH8LAAIGAAYItgbZQQA2AQAGAAYItgbZQQA2AQAAAA==.皮卡超:BAABLAAFFH8SAAITAAUI9QoOMQABAQATAAUI9QoOMQABAQAAAA==.',['皮弗']='皮弗娄牛:BAAALAAECgYIBgABLAAFFAYIIwAOAH8ZAA==.',['直面']='直面天命:BAABLAAFFH8JAAIHAAMIPyHKYwCvAAAHAAMIPyHKYwCvAAAAAA==.',['眼大']='眼大无神:BAABLAAFFH8JAAIRAAIIyRIMQQBxAAARAAIIyRIMQQBxAAAAAA==.',['眼镜']='眼镜男:BAABLAAFFH8KAAMNAAIIZwaOIQBeAAANAAIIZwaOIQBeAAAOAAIIIAS/HQBVAAAAAA==.',['瞬发']='瞬发炉石:BAAALAAECgUIBgAAAA==.',['砍完']='砍完就跑:BAAALAADCgcIBwAAAA==.',['硬丶']='硬丶骨:BAAALAADCgYIBgAAAA==.',['祖宗']='祖宗:BAAALAAECgQIAwAAAA==.',['神乐']='神乐胧月:BAACLAAFFH8RAAMDAAII8hH7KgCSAAADAAII8hH7KgCSAAALAAIIdRdtTACEAAAsAAQKfywAAwsABwgHFTgzAJQBAAsABwgHFTgzAJQBAAMABwiCG7QkAJMBAAAA.',['神光']='神光啊:BAAALAAECggICAAAAA==.',['神木']='神木丽丶:BAABLAAFFH8eAAITAAYIERgsHAB/AQATAAYIERgsHAB/AQAAAA==.',['祢豆']='祢豆子:BAAALAADCgYIBgAAAA==.',['离岛']='离岛丷:BAABLAAFFH8GAAIHAAYIqxjjOgBZAQAHAAYIqxjjOgBZAQAAAA==.',['秦端']='秦端雨:BAABLAAFFH8MAAMGAAYI3A8GRgAlAQAGAAUIuhIGRgAlAQAgAAMI/gDCFQBoAAAAAA==.',['空椅']='空椅子:BAAALAADCgEIAQAAAA==.',['符文']='符文图腾:BAAALAAECgEIAQAAAA==.',['筱筱']='筱筱七:BAAALAAFFAIIAgAAAA==.筱筱乐:BAAALAAECgYIBgAAAA==.筱筱二:BAAALAAECgYIBgAAAA==.',['管泽']='管泽元:BAABLAAFFH8GAAIBAAYIVhCdHABrAQABAAYIVhCdHABrAQAAAA==.',['米娜']='米娜:BAAALAAECgYICgAAAA==.',['米瑞']='米瑞尔萨巴肖:BAAALAAFFAIIAgAAAA==.',['粉面']='粉面小狐丶:BAAALAAECgYIBgAAAA==.',['糖糖']='糖糖寒冰:BAAALAAFFAMIAgAAAA==.',['紫月']='紫月伍:BAABLAAFFH8ZAAMhAAgIxiRzAQD9AgAhAAgIxiRzAQD9AgAiAAEIhCI1CwBoAAAAAA==.紫月叁:BAABLAAFFH8NAAIhAAgI8iMrAgDqAgAhAAgI8iMrAgDqAgAAAA==.紫月壹:BAABLAAFFH8jAAIhAAgIvSM1AwDUAgAhAAgIvSM1AwDUAgAAAA==.紫月肆:BAABLAAFFH8kAAIhAAgIlyWyAAAYAwAhAAgIlyWyAAAYAwAAAA==.紫月贰:BAABLAAFFH8QAAIhAAgIpCKiAwDMAgAhAAgIpCKiAwDMAgAAAA==.紫月陆:BAABLAAFFH8JAAIhAAgISBiSCwBLAgAhAAgISBiSCwBLAgAAAA==.',['紫色']='紫色星空:BAAALAADCgUIBQAAAA==.',['紫菜']='紫菜蛋花汤:BAAALAAECgUIBQAAAA==.',['红粉']='红粉佳人:BAAALAAECgcIBwAAAA==.',['红语']='红语:BAAALAAECgYICgAAAA==.',['红豆']='红豆沙小丸子:BAAALAAECgYIDAAAAA==.',['纪梵']='纪梵希图:BAAALAADCggIDwAAAA==.',['终是']='终是一厢情愿:BAABLAAFFH8GAAILAAYIYRJvIgBNAQALAAYIYRJvIgBNAQAAAA==.',['终极']='终极苦修:BAAALAAFFAYIAwAAAA==.',['给我']='给我放肆撒野:BAAALAAECgYICQAAAA==.',['绝区']='绝区零高手:BAABLAAFFH8GAAILAAYIEiF6CQAyAgALAAYIEiF6CQAyAgAAAA==.',['网恋']='网恋教父:BAAALAAFFAIIAgAAAA==.',['罗小']='罗小黑喵:BAAALAAFFAIIAgAAAA==.',['美女']='美女贝拉:BAAALAAECgQIBAAAAA==.',['耀光']='耀光:BAAALAAECgYIEAAAAA==.',['老狼']='老狼孩:BAAALAAFFAIIAgAAAA==.',['肉老']='肉老师:BAAALAADCgYIBgAAAA==.',['肾骑']='肾骑士:BAAALAADCgUIBQAAAA==.',['胖汏']='胖汏爷:BAABLAAFFH8PAAIGAAYI7QprRAAsAQAGAAYI7QprRAAsAQAAAA==.',['脏死']='脏死你的圣光:BAAALAAFFAIIAgAAAA==.',['致命']='致命猎手:BAAALAADCgMIAwAAAA==.',['艾洛']='艾洛丹:BAAALAADCgcIBwAAAA==.',['艾莱']='艾莱斯坦索姆:BAAALAADCgYIBgAAAA==.',['艾露']='艾露迪:BAAALAADCgYIBgAAAA==.',['芙甯']='芙甯娜:BAAALAAECgUIBQAAAA==.',['花花']='花花世界:BAAALAAECgYIBgAAAA==.',['范海']='范海辛姆:BAAALAAECgMIAwAAAA==.',['范达']='范达尔丶锅盔:BAACLAAFFH8gAAIGAAYIIB4CHwC7AQAGAAYIIB4CHwC7AQAsAAQKfxgABCAABggHGYwnAEIBAAYABgiPF0naAHUBACAABgjrEYwnAEIBAAoABQgKDBpCAMwAAAAA.',['茉莉']='茉莉小宝:BAAALAAECgYIBgAAAA==.',['药老']='药老:BAAALAADCggICAAAAA==.',['菜鸡']='菜鸡菜狂:BAAALAADCgIIAgAAAA==.',['菲奥']='菲奥娜:BAAALAAECgYICQAAAA==.',['萝卜']='萝卜历史:BAAALAADCggICAAAAA==.',['萨拉']='萨拉塔斯:BAABLAAFFH8KAAIBAAIIRQ4sOACDAAABAAIIRQ4sOACDAAAAAA==.萨拉齐:BAABLAAFFH8GAAILAAIITw0/ZABXAAALAAIITw0/ZABXAAAAAA==.',['落单']='落单:BAACLAAFFH8HAAIPAAMI8woEEQBqAAAPAAMI8woEEQBqAAAsAAQKfx4AAg8ABgisG04OAGcBAA8ABgisG04OAGcBAAAA.',['落叶']='落叶惊残梦:BAABLAAFFH8MAAMTAAYINxq9CQDLAQATAAUI5xy9CQDLAQAcAAYIqwjDBwCsAQAAAA==.',['蕾蕾']='蕾蕾闹不住:BAAALAAECgQIBAAAAA==.',['薇薇']='薇薇笑一倾城:BAACLAAFFH8WAAIGAAUIvQqUOQC+AAAGAAUIvQqUOQC+AAAsAAQKfxoAAgYACAjsFHZzABACAAYACAjsFHZzABACAAAA.',['虾仁']='虾仁无敌:BAAALAAECgYICgAAAA==.',['蜜雪']='蜜雪有点咸:BAAALAADCgYIBgAAAA==.',['蝴蝶']='蝴蝶:BAAALAAECgYIDAAAAA==.',['血色']='血色残阳:BAAALAAECgEIAQAAAA==.',['衣架']='衣架:BAACLAAFFH8NAAIPAAMIWhbPEgDPAAAPAAMIWhbPEgDPAAAsAAQKfyUAAw8ACAj/HS0cAIMCAA8ACAj/HS0cAIMCAAcAAwi3DORlAYcAAAAA.',['裂尐']='裂尐君:BAAALAAFFAIIAgAAAA==.',['西贝']='西贝:BAAALAAECgYIBgAAAA==.',['詺棹']='詺棹:BAABLAAFFH8IAAIEAAYIhRi7HwCZAQAEAAYIhRi7HwCZAQAAAA==.',['贝斯']='贝斯手:BAAALAADCgYIBgAAAA==.',['贝露']='贝露丹蒂:BAAALAAECgEIAQAAAA==.',['贫僧']='贫僧略懂拳脚:BAABLAAFFH8KAAIbAAIIZQ63EwCIAAAbAAIIZQ63EwCIAAAAAA==.',['赎罪']='赎罪糕手:BAAALAAECgYIDwAAAA==.',['赛琳']='赛琳娜星辉:BAAALAAECgcIBwAAAA==.',['赤色']='赤色大地:BAAALAAECggICQAAAA==.',['超级']='超级小狼猎:BAAALAADCgUIBgAAAA==.',['路天']='路天寒:BAAALAAECgQIBAAAAA==.',['踏天']='踏天境:BAABLAAFFH8GAAIGAAIICxHkdwBKAAAGAAIICxHkdwBKAAAAAA==.',['身强']='身强丶体壮:BAAALAAECgYIBgAAAA==.',['轰鸣']='轰鸣的太阳:BAAALAAECggIBwAAAA==.',['轻声']='轻声细语:BAAALAAECgMIAwAAAA==.',['达荙']='达荙哒逹:BAABLAAFFH8IAAMPAAIItSCeGQClAAAPAAIICRyeGQClAAAHAAIIGyAeiwBIAAAAAA==.',['过来']='过来看我多大:BAAALAAFFAUIAgAAAA==.',['还是']='还是没想好:BAAALAAECgEIAQAAAA==.',['还有']='还有高手:BAABLAAFFH8MAAICAAYInBdrIQB8AQACAAYInBdrIQB8AQAAAA==.',['还能']='还能有多黑:BAABLAAFFH8GAAIUAAIImATpSwB1AAAUAAIImATpSwB1AAAAAA==.',['这一']='这一条天路:BAAALAAECgEIAQAAAA==.',['这个']='这个人就是妈:BAAALAAECgYIBgAAAA==.这个人就是娘:BAAALAAECgYIBgAAAA==.',['进蓝']='进蓝圈才能活:BAAALAAFFAEIAQAAAA==.',['远古']='远古守护者:BAAALAADCgYIBgAAAA==.',['迪凯']='迪凯:BAAALAAFFAQIBAAAAA==.',['迷你']='迷你酱:BAABLAAFFH8cAAMhAAYISRhwJQCGAQAhAAYINhhwJQCGAQAiAAIIixYYEABMAAAAAA==.',['迷雾']='迷雾之子玟:BAACLAAFFH8oAAICAAYI9Bv1FgCzAQACAAYI9Bv1FgCzAQAsAAQKfxoAAgIABwjPIG9HAEsCAAIABwjPIG9HAEsCAAAA.',['追光']='追光骑士:BAAALAAECgQIBAAAAA==.',['速凝']='速凝剂:BAAALAAECgIIAgAAAA==.',['造物']='造物者的愤怒:BAAALAAECgIIAgAAAA==.',['遁地']='遁地苍龙:BAAALAAECgIIAgAAAA==.',['遗忘']='遗忘殆尽:BAAALAAECggICwAAAA==.',['那個']='那個慕师:BAAALAADCggIDwAAAA==.',['邪能']='邪能支配者:BAAALAAECgYICQAAAA==.',['部落']='部落之王:BAABLAAFFH8GAAILAAYI/gRNMADvAAALAAYI/gRNMADvAAAAAA==.',['酱湿']='酱湿新娘:BAAALAAECgYIDAAAAA==.',['重生']='重生的阿瑞斯:BAAALAAECgYICQAAAA==.',['铁掌']='铁掌水上漂:BAAALAAECgUIBgAAAA==.铁掌风清:BAAALAAECgUIBQAAAA==.',['铁腿']='铁腿水上漂:BAABLAAFFH8GAAICAAYIYxTvIgBzAQACAAYIYxTvIgBzAQAAAA==.',['阳炬']='阳炬顶天:BAAALAAECgYIDQAAAA==.',['阿严']='阿严:BAAALAAECgEIAQAAAA==.',['阿尔']='阿尔飒思:BAAALAAECgYIBgAAAA==.',['阿毛']='阿毛儿:BAAALAAECgcIEAAAAA==.',['阿米']='阿米娅:BAAALAAECgYIDAAAAA==.',['阿紫']='阿紫:BAAALAADCgcIBwAAAA==.',['陈宇']='陈宇轩:BAAALAAFFAMIAwAAAA==.',['陌雪']='陌雪:BAAALAADCgYIBgAAAA==.',['陶猫']='陶猫猫:BAACLAAFFH9HAAMLAAgIxx0wBgBgAgALAAcIkxwwBgBgAgADAAcIRQwFEwCmAQAsAAQKfyoAAgsACAh7IBEcAKgCAAsACAh7IBEcAKgCAAAA.',['随便']='随便看看:BAAALAAFFAYIBAAAAA==.',['随意']='随意那:BAAALAADCgEIAQAAAA==.',['随风']='随风散:BAABLAAFFH8ZAAMBAAYIDyRDBAAfAgABAAUIbyZDBAAfAgAIAAMIGRi2EgDuAAABLAAFFAgIBQABALAfAA==.',['雨飞']='雨飞飞:BAAALAAECgEIAQAAAA==.',['雪丶']='雪丶玲珑:BAAALAAECgYICAAAAA==.',['零捌']='零捌零肆:BAAALAAECgYIEgAAAA==.',['雾蒙']='雾蒙蒙:BAAALAAECgUIBQAAAA==.',['面如']='面如霜下雪:BAAALAAECgYICQAAAA==.',['风师']='风师哥:BAAALAAECgMIBQAAAA==.',['风雨']='风雨漫天:BAAALAAECgYIDQAAAA==.',['飞奔']='飞奔的兔子:BAABLAAFFH8GAAIhAAMISgQaUwBqAAAhAAMISgQaUwBqAAAAAA==.',['饲养']='饲养员灬跟班:BAACLAAFFH8GAAILAAIIAiaCGwDcAAALAAIIAiaCGwDcAAAsAAQKfy0AAgsACAhPIZcPAO0CAAsACAhPIZcPAO0CAAAA.',['香甜']='香甜小饼干:BAAALAAECggIDAAAAA==.',['马可']='马可波罗蜜:BAABLAAFFH80AAIhAAcI/yJWCgBdAgAhAAcI/yJWCgBdAgABLAAFFAcINAAhAP8iAA==.',['鬊鸟']='鬊鸟:BAABLAAFFH8RAAIRAAYI1hmZEQC1AQARAAYI1hmZEQC1AQAAAA==.',['魔冰']='魔冰:BAAALAAECgYIBgAAAA==.',['魔威']='魔威:BAAALAAECgQIBAAAAA==.',['魔瘾']='魔瘾患者:BAAALAAECgEIAgAAAA==.',['魔骑']='魔骑:BAAALAAECgYICQAAAA==.',['鲜血']='鲜血霜冻死亡:BAABLAAFFH8KAAIGAAIIFh9xTwChAAAGAAIIFh9xTwChAAAAAA==.',['鳞长']='鳞长安波莎:BAAALAAECggIEwAAAA==.',['麦灬']='麦灬小手冰凉:BAAALAAECgIIAgAAAA==.',['麻瓜']='麻瓜小表哥:BAABLAAFFH8QAAMTAAUIfBLxLAAhAQATAAUIfBLxLAAhAQAWAAII3g5WGAB3AAAAAA==.',['麻辣']='麻辣兔头哟:BAAALAAECgYIBwAAAA==.',['黎明']='黎明的写照:BAAALAAECgYIBgAAAA==.黎明的平静:BAAALAAECgUIBQAAAA==.',['黑白']='黑白灰:BAAALAAECgIIAgAAAA==.',['鼎大']='鼎大爷:BAAALAAECgIIAgAAAA==.',['龙丷']='龙丷潜:BAABLAAFFH8GAAISAAIIjA0HEwBnAAASAAIIjA0HEwBnAAAAAA==.',['龙腾']='龙腾四海:BAAALAADCgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end