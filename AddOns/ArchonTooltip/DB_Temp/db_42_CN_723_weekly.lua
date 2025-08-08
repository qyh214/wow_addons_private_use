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
 local lookup = {'Paladin-Retribution','Monk-Windwalker','Paladin-Protection','Warlock-Demonology','Warrior-Arms','Warrior-Fury','Evoker-Preservation','Evoker-Devastation','Hunter-BeastMastery','Paladin-Holy','DeathKnight-Blood','DeathKnight-Unholy','Shaman-Elemental','Shaman-Restoration','Mage-Arcane','Mage-Fire','Mage-Frost','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Feral','Rogue-Assassination','Warlock-Affliction','Druid-Restoration','Monk-Mistweaver','Rogue-Outlaw','Warlock-Destruction','Druid-Balance','Monk-Brewmaster','Hunter-Marksmanship','Priest-Holy','Priest-Shadow','Warrior-Protection','Priest-Discipline','DeathKnight-Frost',}; local provider = {region='CN',realm='永夜港',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ad='Adiosamigo:BAAAKgAFFAQIAwAAAA==.',Ag='Agowindy:BAAAKgAECggICQAAAA==.',Al='Aluka:BAABKgAECn8bAAIBAAgInRs2EwA1AgABAAgInRs2EwA1AgAAAA==.',Am='Amini:BAABKgAECn8UAAICAAgIYhAREwAmAQACAAgIYhAREwAmAQAAAA==.',An='Anlk:BAAAKgAECgEIAQAAAA==.',As='Asahi:BAABKgAFFH8GAAIDAAYIeAVGFwC+AAADAAYIeAVGFwC+AAAAAA==.',Ba='Backstorm:BAAAKgAECggIEAAAAA==.',Cr='Crazycup:BAAAKgAFFAYIBAAAAA==.',Da='Danisi:BAABKgAECn8YAAIEAAgIqw7uDgBMAQAEAAgIqw7uDgBMAQAAAA==.',Ev='Evilresident:BAAAKgADCggICAAAAA==.',Ge='Gertrude:BAABKgAFFH8UAAMFAAgIERzHAgBHAgAFAAgIERzHAgBHAgAGAAQIDAcbCgAVAQAAAA==.',Ho='Hop:BAAAKgAECgMIAwAAAA==.',Jy='Jyona:BAACKgAFFH8RAAMHAAQIViNNAQA0AQAHAAMIViNNAQA0AQAIAAQI2RGbIwCyAAAqAAQKfx0AAwcACAgaH7UDAHoCAAcACAgaH7UDAHoCAAgABQj2IS4uAE4BAAAA.',Ka='Kamesennin:BAAAKgAECgcICAAAAA==.',Kl='Klanklang:BAAAKgAECgEIAQAAAA==.',Kr='Kraven:BAABKgAFFH8MAAIJAAYI1B6fDQCXAQAJAAYI1B6fDQCXAQAAAA==.',La='Landino:BAABKgAECn8dAAIFAAgIghQeCQDIAQAFAAgIghQeCQDIAQAAAA==.',Le='Leslie:BAACKgAFFH8cAAMKAAgIaxkdAgA2AgAKAAgIaxkdAgA2AgABAAYIOiTaCgAYAgAqAAQKfx0AAgEACAjCG2VLAN0BAAEACAjCG2VLAN0BAAAA.',Ma='Maladin:BAAAKgAECgQIBAAAAA==.Marpeter:BAAAKgAECggICQAAAA==.',Ne='Necrox:BAABKgAFFH8HAAILAAYIbSM3BQDyAQALAAYIbSM3BQDyAQABKgAFFAgIGgAMAEwhAA==.',Oa='Oaladin:BAAAKgAECgUIBgABKgAFFAgICAAJAHMNAA==.',Or='Orijen:BAAAKgAFFAUIBAAAAA==.',Ou='Ousi:BAABKgAECn8lAAMNAAgIyRgeCQANAgANAAgIyRgeCQANAgAOAAgICA5vKADxAAAAAA==.',Pa='Parardin:BAAAKgAFFAEIAQABKgAFFAgIEAAFAIYNAA==.',Qo='Qogir:BAAAKgAECgUIBgAAAA==.',Re='Retribution:BAAAKgAECgMIAwAAAA==.',Rh='Rhamnus:BAAAKgAECgYIEAAAAA==.',Ri='Rigel:BAAAKgAECggICAAAAA==.',Sa='Sash:BAAAKgAECgYIBwAAAA==.',Ss='Ssksk:BAAAKgAECgIIAgAAAA==.',St='Starkitten:BAAAKgAECgcIBwAAAA==.',Su='Suntory:BAABKgAFFH8bAAQPAAUIRByQHQD5AAAQAAUItxPXFQAGAQAPAAQIqB+QHQD5AAARAAIITR5HHABKAAAAAA==.',Ta='Tainiya:BAABKgAECn8YAAIJAAgINBvSIwApAgAJAAgINBvSIwApAgAAAA==.',Th='Thoughts:BAABKgAECn8bAAMSAAgI+w/JSACEAQASAAgIuQ/JSACEAQATAAEIyQejcgAgAAAAAA==.',Tz='Tzi:BAAAKgAECgIIAgAAAA==.',Vi='Vijiniya:BAAAKgAECgcIBwAAAA==.',Ya='Yaphetschen:BAAAKgAECgEIAQAAAA==.',Zh='Zhounuer:BAAAKgAECgEIAQAAAA==.',['上官']='上官风恒:BAAAKgAECgIIAgAAAA==.',['不事']='不事王侯:BAAAKgAECgEIAQAAAA==.',['不可']='不可诗意:BAAAKgADCgYIBgAAAA==.',['不講']='不講武德:BAABKgAFFH8IAAIUAAQIKwTxBQCaAAAUAAQIKwTxBQCaAAAAAA==.',['丨墨']='丨墨挽青袂丨:BAABKgAFFH8KAAIVAAYIcBaeAQDBAQAVAAYIcBaeAQDBAQAAAA==.',['丶钟']='丶钟丶:BAAAKgAECgUICQAAAA==.',['丿蘩']='丿蘩丶:BAABKgAFFH8JAAMWAAYI+RpABgD4AAAWAAUI2xpABgD4AAAEAAEIbxuvEQBdAAAAAA==.',['乄携']='乄携风踏月:BAAAKgAECgYIBgAAAA==.',['乐乐']='乐乐:BAAAKgAECgMIAwAAAA==.',['云歌']='云歌:BAAAKgADCgEIAQAAAA==.',['云淡']='云淡风静:BAAAKgAFFAQIBAAAAA==.',['人生']='人生长恨:BAAAKgAECggIDAAAAA==.',['仔仔']='仔仔:BAACKgAFFH8GAAIJAAQIABQ2NADBAAAJAAQIABQ2NADBAAAqAAQKfyEAAgkACAgHImAbAFwCAAkACAgHImAbAFwCAAAA.',['伊利']='伊利达雷站长:BAAAKgAECgIIAgAAAA==.',['伊诺']='伊诺鲁克:BAABKgAFFH8GAAIXAAQIPBsLBwALAQAXAAQIPBsLBwALAQAAAA==.',['何泣']='何泣疗:BAAAKgAECgEIAQAAAA==.',['依利']='依利丹怒风:BAABKgAFFH8MAAISAAMILBccFQDjAAASAAMILBccFQDjAAAAAA==.',['依旧']='依旧故我:BAAAKgADCgIIAgAAAA==.',['偷偷']='偷偷打断:BAACKgAFFH8iAAIDAAgI6yOHAQCzAgADAAgI6yOHAQCzAgAqAAQKfyMAAwEACAjLI9ERAMQCAAEACAjLI9ERAMQCAAoACAiTIV8GAIYCAAAA.',['僧傲']='僧傲天:BAABKgAECn8gAAMCAAgIZRugEAA2AgACAAgIZRugEAA2AgAYAAgIKxrfMgCBAQAAAA==.',['克雷']='克雷斯弗:BAAAKgAECgEIAQAAAA==.克雷西亞:BAABKgAECn8dAAIGAAgIZwm/SgDnAAAGAAgIZwm/SgDnAAAAAA==.',['兜兜']='兜兜里有光:BAAAKgAECgYICgAAAA==.',['冰之']='冰之封印:BAAAKgAECgYICwAAAA==.',['凛冬']='凛冬:BAAAKgAECgYIBgAAAA==.',['凤求']='凤求凰凰:BAAAKgAECgYIBwAAAA==.',['凹凹']='凹凹酱:BAAAKgAECgYICwAAAA==.',['千山']='千山丶鳥飞绝:BAABKgAFFH8GAAISAAYI8ws3DwBLAQASAAYI8ws3DwBLAQAAAA==.千山丿鸟飞绝:BAABKgAFFH8IAAIBAAgIcCCrAgC8AgABAAgIcCCrAgC8AgAAAA==.千山鳥飛绝:BAAAKgAECgQIBAAAAA==.',['召天']='召天:BAAAKgAECgEIAQAAAA==.',['可我']='可我想你了:BAABKgAFFH8IAAIPAAgI4AZ7CwChAQAPAAgI4AZ7CwChAQAAAA==.',['叶序']='叶序:BAABKgAFFH8GAAIZAAMI3BnaAwDwAAAZAAMI3BnaAwDwAAAAAA==.',['吾皇']='吾皇万睡:BAABKgAFFH8GAAIaAAYIiAqIGQA4AQAaAAYIiAqIGQA4AQAAAA==.',['咕咕']='咕咕冠军:BAAAKgAFFAIIAgAAAA==.咕咕在输出了:BAAAKgAFFAEIAgAAAA==.',['哆啦']='哆啦美:BAAAKgADCggIEgAAAA==.',['唯见']='唯见月寒日暖:BAAAKgAECggIDAAAAA==.',['啵萝']='啵萝吹雪:BAAAKgAECgUIBQAAAA==.',['喜糖']='喜糖丁:BAAAKgAECgYICgAAAA==.',['喜阳']='喜阳阳:BAAAKgAECggIDAAAAA==.',['喝粥']='喝粥加勺糖:BAAAKgADCggICAAAAA==.',['噼梨']='噼梨吧啦:BAAAKgAECggICQAAAA==.噼梨啪啦:BAAAKgAECgYICQAAAA==.',['圣光']='圣光永存:BAABKgAECn8XAAIBAAgIPxfcYgCYAQABAAgIPxfcYgCYAQAAAA==.',['墨染']='墨染樱:BAAAKgADCggICAAAAA==.',['夏米']='夏米尔:BAAAKgADCggICAAAAA==.',['多多']='多多妹:BAAAKgADCggICAAAAA==.',['夜光']='夜光之瞳:BAAAKgAECgcIBwAAAA==.',['夜君']='夜君:BAACKgAFFH8UAAIEAAQIZhGMDQDJAAAEAAQIZhGMDQDJAAAqAAQKfxQAAgQACAiqElMpAFcBAAQACAiqElMpAFcBAAAA.',['天天']='天天恋佳佳:BAAAKgAFFAYIAwAAAA==.',['天策']='天策上将:BAAAKgAECgIIAgAAAA==.',['奶酪']='奶酪奶呜啊呜:BAAAKgADCggICAAAAA==.',['姑娘']='姑娘请自重:BAAAKgAECgYIBgAAAA==.',['娜薇']='娜薇莉娅:BAAAKgADCggICAAAAA==.',['守陵']='守陵:BAAAKgAECgYIBwAAAA==.',['宏爺']='宏爺:BAAAKgADCgIIAgAAAA==.',['宵暗']='宵暗:BAAAKgAECgEIAQAAAA==.',['寒山']='寒山远:BAAAKgAFFAgIBAAAAA==.',['封魔']='封魔之翼:BAAAKgADCggICAAAAA==.',['小布']='小布丁:BAAAKgAECgEIAQAAAA==.小布丁愛吃鱼:BAAAKgAECgYICwAAAA==.小布丁爱吃鱼:BAAAKgAECgQIBwAAAA==.',['小朋']='小朋友参上:BAAAKgAECggICAAAAA==.',['小狼']='小狼吃土豆:BAAAKgAECgYIBwAAAA==.',['小盆']='小盆友参上:BAAAKgAFFAQIAgAAAA==.',['小高']='小高手载物:BAAAKgAECgEIAQAAAA==.',['尘世']='尘世闲云:BAAAKgADCggICAAAAA==.',['就是']='就是這样:BAACKgAFFH8QAAIBAAYIzyAJEQDXAQABAAYIzyAJEQDXAQAqAAQKfxQAAgEACAhfFWZhAJwBAAEACAhfFWZhAJwBAAAA.',['山葵']='山葵酱:BAAAKgAECggIBgAAAA==.',['崩溃']='崩溃:BAAAKgAECgQIBwAAAA==.',['巍之']='巍之松:BAABKgAFFH8QAAMBAAgIoxL6EwBeAQABAAYIgRD6EwBeAQADAAQIwxHOEQDxAAAAAA==.',['巧哥']='巧哥丶小法:BAABKgAECn8fAAIQAAgIvxygCQBEAgAQAAgIvxygCQBEAgAAAA==.',['希尤']='希尤瓦娜:BAAAKgAECggICAAAAA==.',['平生']='平生多憾事:BAAAKgAECgQIBAAAAA==.',['幻魔']='幻魔之幻:BAABKgAECn8XAAIJAAgIJBKnTgBxAQAJAAgIJBKnTgBxAQAAAA==.幻魔之木:BAAAKgADCgUIBQAAAA==.',['幽茗']='幽茗兰香:BAAAKgAECggIEQAAAA==.',['弑血']='弑血幽兰:BAAAKgAECgcICQAAAA==.',['引魔']='引魔者:BAABKgAFFH8FAAMRAAIIqgwOHgBEAAAPAAIISwQRQABZAAARAAIIqgwOHgBEAAAAAA==.',['张萌']='张萌萌:BAAAKgAECgEIAQAAAA==.',['弯月']='弯月刹罗:BAAAKgAECggICAAAAA==.',['归隐']='归隐者:BAAAKgADCggICAAAAA==.',['彩色']='彩色照片:BAAAKgAECgYIBgAAAA==.',['彬彬']='彬彬猪:BAAAKgAECgYIBgAAAA==.',['彼岸']='彼岸花:BAACKgAFFH8HAAIOAAIIth/lGQC8AAAOAAIIth/lGQC8AAAqAAQKfxkAAg4ACAiEIAEQAHkCAA4ACAiEIAEQAHkCAAAA.',['德伊']='德伊的笑:BAABKgAFFH8GAAIbAAYI+Q32EgAyAQAbAAYI+Q32EgAyAQAAAA==.',['德鲁']='德鲁大叔:BAAAKgAECggIEQAAAA==.',['心宝']='心宝宝:BAAAKgAECgYIDQAAAA==.',['心灵']='心灵丶捕手:BAAAKgAECgYIDwAAAA==.',['念念']='念念丶:BAAAKgAECgEIAQAAAA==.',['怜香']='怜香惜玉:BAAAKgAECggIDAAAAA==.',['恒大']='恒大:BAAAKgAECgQIBAAAAA==.',['恶魔']='恶魔丶殺:BAABKgAFFH8GAAITAAYIVgFtDACQAAATAAYIVgFtDACQAAAAAA==.恶魔术:BAAAKgADCgYIBgAAAA==.',['慕容']='慕容飞雪:BAAAKgADCggICAAAAA==.',['憨豆']='憨豆:BAAAKgAECgcIAgAAAA==.',['我尿']='我尿酸不高:BAAAKgAECgIIAgAAAA==.',['我特']='我特么来辣:BAAAKgADCgYIBgAAAA==.',['戒律']='戒律牧:BAAAKgAECgQIBAAAAA==.',['拉克']='拉克希尔:BAAAKgADCgEIAQAAAA==.',['提里']='提里奥佛丁:BAAAKgAECgIIAgAAAA==.',['摸鱼']='摸鱼小咔咔:BAAAKgADCgcIBwAAAA==.',['斋藤']='斋藤飞鸟:BAAAKgADCgYIBgAAAA==.',['新兵']='新兵卫:BAAAKgADCgYIBgAAAA==.',['旺达']='旺达:BAABKgAFFH8IAAIaAAgIVhS6BgAoAgAaAAgIVhS6BgAoAgAAAA==.',['明天']='明天君:BAACKgAFFH8FAAIOAAUIjhT4EgA+AQAOAAUIjhT4EgA+AQAqAAQKfxgAAw4ACAiwF0ctANQBAA4ACAiwF0ctANQBAA0ABgjdIG4oALQBAAAA.',['明月']='明月如雪:BAAAKgAFFAQIBAABKgAFFAgIBgAcAPgLAA==.',['易行']='易行天下:BAAAKgAECgcICgAAAA==.',['星辰']='星辰之月:BAAAKgAFFAMIAwAAAA==.星辰之秋:BAAAKgAECgYIEwAAAA==.星辰之耀:BAAAKgAFFAIIAgAAAA==.',['昨夜']='昨夜星辰不离:BAABKgAECn8kAAICAAgI4BodFAAPAgACAAgI4BodFAAPAgAAAA==.',['暗处']='暗处的阴影:BAAAKgAFFAIIAgAAAA==.',['暮色']='暮色愁过客:BAAAKgADCgEIAQAAAA==.',['最爱']='最爱十四夜:BAABKgAFFH8FAAIJAAUIkgpLJADEAAAJAAUIkgpLJADEAAAAAA==.',['月影']='月影流觞:BAAAKgAFFAgIBAAAAA==.',['木木']='木木呀:BAAAKgAECgIIAgAAAA==.',['木骨']='木骨实:BAAAKgADCgYIDAAAAA==.',['术罚']='术罚:BAACKgAFFH8JAAMEAAYIZyQtBwAIAQAaAAQIwiQQEACPAQAEAAUIgxAtBwAIAQAqAAQKfyoAAgQACAiIHHMJAEoCAAQACAiIHHMJAEoCAAAA.',['果汁']='果汁饮料:BAAAKgAECgUIBQAAAA==.',['标准']='标准男:BAAAKgAECgYIBwAAAA==.',['桜咲']='桜咲琉璃:BAAAKgAECgQIBAAAAA==.',['梅花']='梅花十三丶:BAAAKgADCgEIAQAAAA==.',['椎名']='椎名林檎:BAABKgAECn8iAAQUAAgIXiShBACYAgAUAAgIXiShBACYAgAXAAcI8BUnLAB4AQAbAAEIogk3ywAvAAAAAA==.',['楠萌']='楠萌部落丫头:BAABKgAECn9BAAMJAAgIFxHPHQCKAQAJAAgIFxHPHQCKAQAdAAYIggWdhwBrAAAAAA==.',['欢愉']='欢愉折磨:BAABKgAECn8jAAMEAAgI1BLKGQCsAQAEAAgI1BLKGQCsAQAaAAQIKwyZkwBkAAAAAA==.',['正义']='正义之击:BAABKgAFFH8IAAIDAAgI2Rd7AwAFAgADAAgI2Rd7AwAFAgAAAA==.',['毛线']='毛线的毛线:BAABKgAFFH8IAAIGAAgIcwvVBgD8AQAGAAgIcwvVBgD8AQAAAA==.',['水官']='水官解厄:BAAAKgAFFAYIBAAAAA==.',['江城']='江城丨志海:BAAAKgAFFAIIAgAAAA==.江城丨老頔:BAACKgAFFH8WAAILAAYIdxrOBABEAQALAAYIdxrOBABEAQAqAAQKfxsAAwwACAh9JOcMALgCAAwACAhpIecMALgCAAsACAjbG7sXAN4BAAAA.',['沙漠']='沙漠中的星星:BAABKgAFFH8HAAIDAAcI3BTLBwCUAQADAAcI3BTLBwCUAQAAAA==.沙漠中的月亮:BAABKgAFFH8FAAMGAAUIRhzsCQAXAQAGAAQIbSHsCQAXAQAFAAEIzwwAAAAAAAAAAA==.',['沙音']='沙音:BAAAKgADCgMIAwAAAA==.',['没我']='没我不行:BAAAKgAECggIDQAAAA==.',['法力']='法力残渣:BAAAKgADCgYIBgAAAA==.',['波本']='波本威士忌:BAAAKgAFFAYIBAAAAA==.',['泰兰']='泰兰:BAAAKgAECggIEgAAAA==.',['活的']='活的紫色仙子:BAAAKgAECggIEQAAAA==.',['浅浅']='浅浅的小精灵:BAABKgAECn8dAAIeAAgI4BevKQCGAQAeAAgI4BevKQCGAQAAAA==.',['浮生']='浮生尽歇丶:BAAAKgADCggICAAAAA==.',['淘气']='淘气的爸爸:BAAAKgAFFAQIBAAAAA==.',['清源']='清源妙道真君:BAACKgAFFH8RAAIYAAQItBjMGADZAAAYAAQItBjMGADZAAAqAAQKfycAAhgACAgPIPgNAHsCABgACAgPIPgNAHsCAAAA.',['清风']='清风若水:BAAAKgAECgUIBQAAAA==.',['温暖']='温暖的小熊:BAABKgAFFH8GAAIYAAYI4hUoDQBSAQAYAAYI4hUoDQBSAQAAAA==.',['火球']='火球从天而降:BAAAKgAECgUICgAAAA==.',['灰太']='灰太浪:BAAAKgAECggIEQAAAA==.',['炫迈']='炫迈风:BAAAKgAFFAEIAQAAAA==.',['爱夏']='爱夏:BAAAKgAFFAIIAgAAAA==.',['爱神']='爱神黑悟空:BAAAKgAECgIIAgAAAA==.',['爱莉']='爱莉希雅:BAAAKgADCgQIBAAAAA==.',['牛牛']='牛牛不怕困难:BAAAKgAECgEIAQAAAA==.',['牧云']='牧云白浅:BAAAKgADCggICAAAAA==.',['狂野']='狂野的肉肉:BAAAKgAECgMIAwAAAA==.',['狸叽']='狸叽米:BAABKgAFFH8GAAIPAAYI/BGcEQBbAQAPAAYI/BGcEQBbAQAAAA==.',['狸觅']='狸觅:BAAAKgADCgIIAgAAAA==.',['狸追']='狸追丶:BAAAKgAECgEIAQAAAA==.',['玛布']='玛布鲁:BAAAKgAFFAQIAgABKgAFFAgIDgAaAEEbAA==.',['玩玩']='玩玩的绝望:BAAAKgAFFAYIBAABKgAFFAgIBgAfAHQcAA==.',['珍妮']='珍妮玛:BAABKgAFFH8XAAIaAAgI/yLRAQC+AgAaAAgI/yLRAQC+AgAAAA==.',['珑玥']='珑玥:BAABKgAFFH8FAAIgAAMIzAEzFABaAAAgAAMIzAEzFABaAAABKgAFFAgIDwAYAMcVAA==.',['瓢雪']='瓢雪无痕:BAAAKgADCgMIAwAAAA==.',['疏影']='疏影残月:BAABKgAFFH8fAAMRAAgIjSB3AgDyAQAPAAgIth+TBABaAgARAAcIZB93AgDyAQAAAA==.',['白咕']='白咕咕:BAAAKgAFFAQIBAAAAA==.',['白水']='白水豆腐:BAAAKgAECgUIAwAAAA==.',['白芷']='白芷:BAAAKgADCggICAAAAA==.',['盖世']='盖世神魔:BAABKgAFFH8WAAMOAAgIsxyhAwAcAgAOAAgIsxyhAwAcAgANAAEIHAtkFwA7AAAAAA==.',['看看']='看看了:BAAAKgAECgYIBgAAAA==.',['砂锅']='砂锅鱼头:BAAAKgAECgYIBgAAAA==.',['硬苯']='硬苯娃:BAAAKgADCgcIBwAAAA==.',['神仙']='神仙也无敌:BAAAKgAECgEIAQAAAA==.',['福祸']='福祸相依:BAAAKgAECgcIDgAAAA==.',['秋水']='秋水新月:BAABKgAFFH8QAAIJAAgIzh8/BABsAgAJAAgIzh8/BABsAgAAAA==.',['秦无']='秦无意:BAAAKgAFFAQIBAAAAA==.',['穆如']='穆如清风丶:BAAAKgAECgcIBwAAAA==.',['空虛']='空虛公子:BAAAKgAECggICgAAAA==.',['站誓']='站誓涕:BAAAKgAECgEIAQAAAA==.',['筿心']='筿心魔:BAABKgAECn8bAAIBAAgINh5uNQBPAgABAAgINh5uNQBPAgAAAA==.',['简单']='简单男孩:BAABKgAFFH8IAAIPAAgIsR4iAwCOAgAPAAgIsR4iAwCOAgAAAA==.',['精灵']='精灵鼠爸爸:BAAAKgAECgIIAgAAAA==.',['糖潴']='糖潴潴:BAAAKgAFFAUIAQAAAA==.',['紗音']='紗音:BAAAKgAFFAIIBAAAAA==.',['紫色']='紫色心情:BAABKgAFFH8JAAMNAAQIgyCzBwDyAAANAAQIgyCzBwDyAAAOAAMIJwiBGADCAAAAAA==.',['紫苏']='紫苏:BAABKgAFFH8MAAIdAAMIdA7LGQCbAAAdAAMIdA7LGQCbAAAAAA==.',['红叶']='红叶栖霞:BAABKgAFFH8WAAQhAAgI5w81BQDsAQAhAAgI5g01BQDsAQAeAAcIMgv0DABVAQAfAAUIrAlCFQDRAAAAAA==.',['红太']='红太浪:BAAAKgAECggICAAAAA==.',['红红']='红红的小熊:BAAAKgAFFAUIBAABKgAFFAYIBgAYAOIVAA==.',['红魔']='红魔慧馨:BAABKgAFFH8GAAIYAAUIERMQHQC3AAAYAAUIERMQHQC3AAAAAA==.',['细雨']='细雨濛濛:BAAAKgAECggIDQAAAA==.',['绯月']='绯月:BAAAKgADCggICAAAAA==.',['缚魂']='缚魂者尼娅米:BAAAKgADCggICAAAAA==.',['美女']='美女莎莎:BAAAKgAECgMIAwAAAA==.',['老丶']='老丶衲:BAABKgAFFH8GAAISAAYINA/zDQBsAQASAAYINA/zDQBsAQAAAA==.',['老六']='老六的一天:BAAAKgAECgQIBAAAAA==.',['老男']='老男人:BAAAKgAFFAIIAgAAAA==.',['舞後']='舞後紅茶:BAABKgAFFH8WAAMSAAYIBxfwEQBuAQASAAYIBxfwEQBuAQATAAYILgOqEgCuAAAAAA==.',['花臂']='花臂奶嘴龙:BAAAKgAECgYIBgAAAA==.',['荷必']='荷必奘傻:BAAAKgAECgYICAAAAA==.',['荹勎']='荹勎剆恝蔺:BAAAKgAECgQIBAAAAA==.',['莉莉']='莉莉:BAACKgAFFH8bAAIBAAMIYiEwNgASAQABAAMIYiEwNgASAQAqAAQKfyUAAgEACAieI9YZALACAAEACAieI9YZALACAAAA.莉莉雨:BAAAKgAECgcICwAAAA==.',['莎士']='莎士比亚伯爵:BAAAKgAECgYICAAAAA==.',['莱弥']='莱弥亚丶银光:BAAAKgADCgEIAQAAAA==.',['萨格']='萨格丶:BAABKgAECn8UAAMMAAgIZA2kTwB7AQAMAAgIZA2kTwB7AQALAAYI0QGRVQBlAAAAAA==.',['萨诺']='萨诺斯:BAAAKgAECggICAAAAA==.',['落雨']='落雨飘飘:BAAAKgAECgUICQAAAA==.',['蔚蓝']='蔚蓝的天空:BAAAKgAECggIEQAAAA==.',['蘑菇']='蘑菇雀:BAAAKgAECggIDgAAAA==.',['虚空']='虚空救赎者:BAAAKgAECgMIAwAAAA==.',['西尔']='西尔维亚:BAAAKgAECgYIDgAAAA==.',['角海']='角海:BAABKgAFFH8FAAMLAAMI7gq2JQCBAAALAAMIfAq2JQCBAAAMAAIIFQjeSgB2AAAAAA==.',['说说']='说说又笑笑:BAAAKgADCgMIAwAAAA==.',['请叫']='请叫我死骑炮:BAABKgAFFH8GAAIMAAYI7xWdEgCFAQAMAAYI7xWdEgCFAQAAAA==.请叫我炮哥:BAABKgAECn8TAAMOAAgI9hOiNgCrAQAOAAgI9hOiNgCrAQANAAYI1RoCNQBpAQAAAA==.',['贴地']='贴地飞行墩墩:BAABKgAFFH8JAAMXAAYIqxsBBwCjAQAXAAYIqxsBBwCjAQAbAAMIqhPITgB6AAAAAA==.',['轩辕']='轩辕凤:BAAAKgAFFAMIAwAAAA==.',['辰鸢']='辰鸢:BAAAKgAECgQIBAAAAA==.',['迷梦']='迷梦沉沦:BAAAKgAECgcIEwAAAA==.',['逄决']='逄决:BAABKgAFFH8KAAMEAAYIvQ/bAgASAQAEAAUIwwvbAgASAQAaAAEIpR88KgBiAAAAAA==.',['逐风']='逐风猎影:BAAAKgAFFAgIAgAAAA==.',['逢坂']='逢坂丶大河:BAABKgAECn8fAAMRAAgIJyHSIQCkAQARAAYIQSPSIQCkAQAQAAUIIhpPUAA7AQAAAA==.',['遐蝶']='遐蝶:BAAAKgADCggICAAAAA==.',['那个']='那个奶德:BAABKgAFFH8QAAQPAAgIXxcLBwATAgAPAAgIKhMLBwATAgARAAQI3h6dBAANAQAQAAQIlBqBGADtAAAAAA==.那个暗牧:BAABKgAFFH8IAAMbAAgIshqiCQD/AQAbAAcI1BiiCQD/AQAXAAEISxSzFgBKAAAAAA==.',['邪恶']='邪恶的小熊猫:BAAAKgAECggIBgAAAA==.',['郑码']='郑码不忙:BAAAKgAECgMIAwAAAA==.',['钢蛋']='钢蛋:BAAAKgAECgYIBgAAAA==.',['阳春']='阳春:BAABKgAFFH8SAAIXAAMIbRcgGgDQAAAXAAMIbRcgGgDQAAAAAA==.',['阿斯']='阿斯特兰纳:BAABKgAECn8iAAIJAAgIHw/nbgBmAQAJAAgIHw/nbgBmAQAAAA==.',['阿满']='阿满:BAAAKgAECgQIBAAAAA==.',['阿玛']='阿玛希尔:BAABKgAFFH8GAAIaAAYItggSHgAYAQAaAAYItggSHgAYAQAAAA==.',['阿米']='阿米达拉:BAAAKgADCggICAAAAA==.',['阿蛮']='阿蛮:BAACKgAFFH8YAAIKAAUIXwsQCQDLAAAKAAUIXwsQCQDLAAAqAAQKfxYAAgoACAhiH54hAFMBAAoACAhiH54hAFMBAAAA.',['阿里']='阿里勃特大:BAABKgAECn8UAAMLAAgIQQqFLQDjAAALAAgIQQqFLQDjAAAiAAEIHweNOAAjAAAAAA==.',['陆军']='陆军:BAAAKgADCggICAAAAA==.',['雅舞']='雅舞:BAAAKgADCgIIAgAAAA==.',['雨夜']='雨夜小毒:BAAAKgADCggICAAAAA==.雨夜晓姽:BAAAKgADCggIDAAAAA==.',['零度']='零度的咖啡:BAABKgAECn8oAAIBAAgIywfqyQDDAAABAAgIywfqyQDDAAAAAA==.',['雷雨']='雷雨天:BAAAKgADCgEIAQAAAA==.',['震泽']='震泽:BAAAKgADCgcIBwAAAA==.',['青烟']='青烟如丝:BAABKgAFFH8FAAMdAAMIygv7RgBkAAAdAAIISgn7RgBkAAAJAAEIyhBEXQA8AAAAAA==.',['革音']='革音:BAAAKgAFFAQIBAABKgAFFAgICAARAA4PAA==.',['风不']='风不语:BAAAKgAECgMIAwAAAA==.',['风乘']='风乘:BAACKgAFFH8MAAMBAAMIORP+TgDRAAABAAMIORP+TgDRAAAKAAMIUQf7EgCnAAAqAAQKfx0AAgEACAj7Hf80AFECAAEACAj7Hf80AFECAAAA.',['风怒']='风怒灬火:BAAAKgADCgcIBwAAAA==.',['飒蛮']='飒蛮:BAAAKgAECggICAAAAA==.',['马保']='马保國:BAABKgAFFH8GAAICAAYI8wm0CgA1AQACAAYI8wm0CgA1AQAAAA==.',['高坂']='高坂桐乃:BAACKgAFFH8aAAMDAAYIaSEDBgDMAQADAAYIaSEDBgDMAQAKAAUIbB0cBwBEAQAqAAQKfxQAAgoACAjtIRMTAN4BAAoACAjtIRMTAN4BAAAA.',['魅影']='魅影之蓝:BAABKgAECn8gAAIRAAgIwhrfFAAVAgARAAgIwhrfFAAVAgAAAA==.',['鲜蜜']='鲜蜜柠檬:BAAAKgAECggIDwAAAA==.',['鸿渐']='鸿渐于陵:BAABKgAFFH8GAAIFAAQIDhDrFgDPAAAFAAQIDhDrFgDPAAAAAA==.',['龙龙']='龙龙飘过来:BAABKgAECn8UAAIRAAgI9h3PHwANAgARAAgI9h3PHwANAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end