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
 local lookup = {'Shaman-Restoration','Monk-Mistweaver','Monk-Brewmaster','Druid-Restoration','Paladin-Holy','Paladin-Retribution','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','DeathKnight-Blood','DeathKnight-Unholy','Priest-Shadow','Priest-Discipline','Priest-Holy','Mage-Arcane','Unknown-Unknown','Shaman-Elemental','Shaman-Enhancement','Mage-Frost','Mage-Fire','Warrior-Fury','Hunter-Marksmanship','Paladin-Protection','Hunter-BeastMastery','Evoker-Devastation','Evoker-Preservation','Warrior-Arms','Warrior-Protection','Druid-Balance','Hunter-Survival','DemonHunter-Vengeance','DemonHunter-Havoc','Rogue-Outlaw','DeathKnight-Frost','Monk-Windwalker','Druid-Guardian','Rogue-Assassination','Druid-Feral',}; local provider = {region='CN',realm='卡拉赞',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ad='Adiany:BAAAKgADCggICAAAAA==.',As='Asfhbe:BAAAKgADCgUIBQAAAA==.',Ax='Axcl:BAAAKgAFFAQIBAAAAA==.',Ba='Bad:BAAAKgAECgcIDAAAAA==.',Bi='Biood:BAAAKgADCgEIAgAAAA==.',Bo='Booming:BAABKgAFFH8HAAIBAAQIPQqlNwChAAABAAQIPQqlNwChAAAAAA==.',Ca='Carlosy:BAAAKgADCgcIBwAAAA==.Catiman:BAACKgAFFH8rAAMCAAcI+B9hCAAmAQACAAcI+B9hCAAmAQADAAEIXwcdDAAtAAAqAAQKfzoAAwIACAh5JcICAOsCAAIACAh5JcICAOsCAAMAAQitBHcnAA0AAAAA.Catman:BAABKgAECn8gAAIEAAgI9BlZFwAJAgAEAAgI9BlZFwAJAgABKgAFFAcIKwACAPgfAA==.',Cu='Curelove:BAACKgAFFH8YAAMFAAYIJyAGCgAHAQAFAAQIxx4GCgAHAQAGAAUI+g1NHAADAQAqAAQKfxQAAwUACAjGGNUWALcBAAUACAjGGNUWALcBAAYAAQgpBtCHASUAAAAA.',Db='Dbtrkygaly:BAAAKgAECgUIBQAAAA==.',De='Deepseek:BAAAKgAFFAEIAQAAAA==.Demonlord:BAACKgAFFH8SAAQHAAYIvBV7EQB+AQAHAAYIvBV7EQB+AQAIAAEIHRUqEQBNAAAJAAEIAADSGwAAAAAqAAQKfykABAcACAiyIAgfAAoCAAcACAidIAgfAAoCAAkABwiNGokkAGcBAAgAAQi3B51HADAAAAAA.',Di='Diver:BAABKgAFFH8JAAMKAAQIYAIiLgBYAAAKAAQIYAIiLgBYAAALAAIIHgJpIABNAAAAAA==.',Ei='Eictcle:BAAAKgAECgYICwAAAA==.',El='Elecrt:BAAAKgAECgMIBQAAAA==.Electrs:BAAAKgAFFAEIAQAAAA==.Electsr:BAAAKgAECgYICgAAAA==.Elemet:BAAAKgAECggIDAAAAA==.',Fi='Finefan:BAAAKgAECgcIBwAAAA==.',Fl='Floway:BAAAKgADCggICAAAAA==.',Fu='Funnylove:BAAAKgAFFAMIAwAAAA==.',Ge='Gentcat:BAAAKgAECgUIBQABKgAFFAcIKwACAPgfAA==.',Gp='Gpmage:BAAAKgADCgUIBQAAAA==.',Gr='Grimbatore:BAACKgAFFH8eAAIKAAQIVhd5EwCrAAAKAAQIVhd5EwCrAAAqAAQKfyMAAwoACAhqHpMQAC4CAAoACAhqHpMQAC4CAAsABghDDIp8AO4AAAAA.',Ha='Hackernet:BAABKgAECn8UAAIGAAcI3hveVQC7AQAGAAcI3hveVQC7AQAAAA==.Harry:BAACKgAFFH8IAAMMAAYIBBcNBgBRAQAMAAUIGRYNBgBRAQANAAEI5B+OIwBiAAAqAAQKfxkABA0ACAjPIe4HAJ4CAA0ACAjPIe4HAJ4CAAwABQhUBxRMAL4AAA4AAQjiHTCOAD8AAAEqAAUUCAgRAA0AqBYA.',Ja='Jackpriest:BAAAKgAFFAgIBAAAAA==.',Ko='Korvash:BAAAKgAECgMIAwAAAA==.',Ku='Kumaqaq:BAAAKgAECgIIAgAAAA==.',Le='Leisure:BAAAKgADCggICAAAAA==.Leoni:BAAAKgAECggICAAAAA==.',Ma='Makecar:BAAAKgAECgEIAQAAAA==.Mako:BAAAKgAECggICAAAAA==.',Me='Medeargirl:BAAAKgAFFAIIAwAAAA==.',Ni='Nike:BAAAKgAECgYIBgAAAA==.',Ot='Otamendi:BAAAKgAECgMIAwAAAA==.',Ph='Phantomcat:BAAAKgADCggICQAAAA==.',Ro='Rocketss:BAAAKgAFFAUIAwAAAA==.',So='So:BAABKgAECn8dAAIPAAgIzRafIwDaAQAPAAgIzRafIwDaAQAAAA==.',St='Stopkillall:BAABKgAFFH8IAAMOAAgIMxcoBwC5AQAOAAYINx0oBwC5AQANAAIIKQiTDwCJAAAAAA==.',Th='Thorn:BAAAKgAECgQIBAABKgAECgcIEwAQAAAAAA==.',Ti='Timidlove:BAACKgAFFH8NAAQRAAQI5ggEEgCTAAARAAMIYAMEEgCTAAABAAQIgQNhQgB9AAASAAEIiRLyFgBSAAAqAAQKfyMABAEACAiZDPhVAD0BAAEACAiZDPhVAD0BABEABQhXF/JBAB8BABIAAgiHGrNWAFcAAAAA.',Tk='Tkkwenlliv:BAAAKgADCggICAABKgAECgUIBQAQAAAAAA==.',Tm='Tmoon:BAAAKgAECgcIDAAAAA==.',Vi='Vila:BAACKgAFFH8lAAQTAAYIFB8XCABBAQAUAAYIfxdODABxAQATAAMIZSUXCABBAQAPAAQIpRbDJQDLAAAqAAQKfygABBMACAgyJb8TAGACABMABgirJb8TAGACAA8ABgisIv4xAIgBABQABQhTHY5ZAA8BAAAA.',Vp='Vpuhtuvnwu:BAAAKgADCgMIAwABKgAECgUIBQAQAAAAAA==.',Wi='Windwalker:BAAAKgAECgYICwAAAA==.',['一个']='一个纯洁的人:BAAAKgAECgUIBQAAAA==.一个跳劈:BAAAKgAECggICAAAAA==.',['一十']='一十焱十一:BAAAKgADCgYIBgAAAA==.',['一叶']='一叶灬之秋:BAAAKgADCgcIBwAAAA==.',['一念']='一念一年:BAABKgAFFH8IAAIGAAMIzw5yUwDJAAAGAAMIzw5yUwDJAAAAAA==.',['一斩']='一斩杀一:BAABKgAECn8xAAIVAAgIsRS7DADUAQAVAAgIsRS7DADUAQAAAA==.',['一猎']='一猎魂一:BAAAKgAECgQIBAAAAA==.',['一直']='一直孤独:BAABKgAFFH8GAAIWAAYILhgeDACVAQAWAAYILhgeDACVAQAAAA==.',['一路']='一路七到底:BAAAKgAECggICAAAAA==.一路柒到底:BAAAKgAECggICAAAAA==.一路贰到底:BAAAKgAFFAQIBAAAAA==.',['七秒']='七秒妍乀:BAAAKgAFFAQIAgAAAA==.',['三修']='三修全需德:BAAAKgAFFAMIAwAAAA==.',['三叶']='三叶草:BAABKgAFFH8IAAIPAAMI4xwLHgD2AAAPAAMI4xwLHgD2AAAAAA==.',['三藏']='三藏师傅:BAAAKgAECggIDgAAAA==.',['三鲜']='三鲜包:BAAAKgADCggICAAAAA==.',['上帝']='上帝之手:BAAAKgAECgQIBAAAAA==.',['不会']='不会治疗的牧:BAAAKgAFFAQIBAABKgAFFAgICgAOAL0cAA==.',['不吃']='不吃药药:BAAAKgADCggICAAAAA==.',['不耐']='不耐:BAAAKgAECgUICAAAAA==.',['东方']='东方鈈败:BAACKgAFFH8QAAITAAMInB4rDwDpAAATAAMInB4rDwDpAAAqAAQKfx4AAhMACAgeIHUUAFoCABMACAgeIHUUAFoCAAAA.',['丨奎']='丨奎托斯丨:BAABKgAFFH8KAAILAAgIkwXyHgAnAQALAAgIkwXyHgAnAQAAAA==.',['丨木']='丨木落丨:BAABKgAECn8ZAAMMAAgIhhJ1LgBoAQAMAAcIzhB1LgBoAQANAAgIvw4YMwBUAQAAAA==.',['丨糖']='丨糖丨:BAACKgAFFH8gAAIHAAQIYw/EGAC+AAAHAAQIYw/EGAC+AAAqAAQKfyYAAgcACAigHA8jAPMBAAcACAigHA8jAPMBAAAA.',['丨霸']='丨霸天虎丨:BAAAKgAFFAYIBAAAAA==.',['丫抢']='丫抢我爽歪歪:BAAAKgAFFAgIAQAAAA==.',['临江']='临江仙:BAAAKgAECgcIBwAAAA==.',['丶任']='丶任羽逍遥:BAAAKgAFFAYIAQAAAA==.',['丶我']='丶我叫纠结伦:BAABKgAECn8YAAMLAAgI1Q+cTABAAQALAAgInQ6cTABAAQAKAAQITAcuRwBYAAAAAA==.',['丶旺']='丶旺仔小馒头:BAACKgAFFH8TAAIGAAQICR7HNwAMAQAGAAQICR7HNwAMAQAqAAQKfyYAAwYACAgwGRqHAIkBAAYABwiDHBqHAIkBABcABwhPBnk3ALUAAAAA.',['丶樱']='丶樱花落尽:BAAAKgADCgEIAQAAAA==.',['丶泽']='丶泽兰丶:BAAAKgAECgYIBgAAAA==.',['丶涵']='丶涵丶:BAAAKgADCggICAAAAA==.',['丶煲']='丶煲仔:BAAAKgAFFAYIBAAAAA==.',['丶靈']='丶靈魂:BAAAKgAFFAYIAwAAAA==.',['丷梦']='丷梦小游丷:BAAAKgAECgEIAQAAAA==.',['丿你']='丿你值得拥有:BAAAKgAECgIIAgAAAA==.',['丿只']='丿只会无敌:BAAAKgAECggICAABKgAFFAQIBAAQAAAAAA==.',['丿贪']='丿贪狼:BAAAKgAFFAQIBAAAAA==.',['乌发']='乌发五天:BAAAKgAECggICgAAAA==.',['九天']='九天青云:BAAAKgAECggIDgAAAA==.',['也曾']='也曾善良:BAAAKgADCggICAAAAA==.',['乱了']='乱了感觉:BAAAKgADCgUIBQAAAA==.',['云缨']='云缨:BAABKgAFFH8GAAIGAAYIsBd5IQBoAQAGAAYIsBd5IQBoAQAAAA==.',['云舒']='云舒情散:BAABKgAECn8iAAIRAAgIOB2IGQD9AQARAAgIOB2IGQD9AQAAAA==.',['五行']='五行缺铁:BAABKgAFFH8IAAIGAAQIaBIYJADfAAAGAAQIaBIYJADfAAAAAA==.',['人变']='人变心不变:BAABKgAFFH8GAAIEAAYIagRtCwDXAAAEAAYIagRtCwDXAAAAAA==.',['会长']='会长的二大爷:BAAAKgAECgIIAgAAAA==.',['会飞']='会飞的萝卜:BAACKgAFFH8YAAMUAAYIWw5DCQBnAQAUAAYItApDCQBnAQAPAAMIsA7mKQC7AAAqAAQKfzEAAg8ACAjfGQYKALwBAA8ACAjfGQYKALwBAAAA.',['伽蓝']='伽蓝寺礼赞:BAABKgAFFH8LAAIGAAYIVBlpHgB4AQAGAAYIVBlpHgB4AQAAAA==.',['住山']='住山不记年:BAAAKgAECgcICQAAAA==.',['何老']='何老板:BAAAKgAFFAIIAgAAAA==.',['你猜']='你猜是不是奶:BAAAKgAECgEIAQAAAA==.',['佧萨']='佧萨布兰卡:BAAAKgADCggICAAAAA==.',['依天']='依天飞雪:BAAAKgAECgQIBgAAAA==.',['依希']='依希恩:BAAAKgADCggICAAAAA==.',['偶尔']='偶尔的神:BAAAKgAFFAYIBAAAAA==.',['元气']='元气骑:BAAAKgAECgYIBgAAAA==.',['兄弟']='兄弟情义重:BAABKgAECn8VAAIWAAgIcxvJIAD6AQAWAAgIcxvJIAD6AQAAAA==.',['全结']='全结构化:BAAAKgADCgEIAQAAAA==.',['全需']='全需:BAAAKgAECgYIBgAAAA==.',['八六']='八六年健力宝:BAACKgAFFH8QAAMLAAQIVR+VDQAEAQALAAQIVR+VDQAEAQAKAAMIQQtiJgB9AAAqAAQKfzAAAwsACAj3IO0VAH0CAAsACAj3IO0VAH0CAAoABQjCEAFCALYAAAAA.',['兰德']='兰德亚瑟:BAAAKgADCggICAAAAA==.',['养猪']='养猪能手铁根:BAACKgAFFH8WAAIYAAYIoxehEAB0AQAYAAYIoxehEAB0AQAqAAQKfxwAAhgACAgfHvQiAGkCABgACAgfHvQiAGkCAAEqAAUUCAgJABMAwxMA.',['冠辰']='冠辰:BAABKgAFFH8FAAIYAAMIbRopKgDcAAAYAAMIbRopKgDcAAAAAA==.',['冬季']='冬季没有雪:BAAAKgAECggIEgAAAA==.',['冰封']='冰封灬神罚:BAAAKgAECgQIBAAAAA==.',['冷羽']='冷羽輕風:BAAAKgAFFAIIAgAAAA==.',['凉拌']='凉拌见手青:BAAAKgAFFAQIBAAAAA==.',['凑斗']='凑斗景明:BAAAKgADCggICAAAAA==.',['凝香']='凝香:BAAAKgAFFAgIAgAAAA==.',['凤凰']='凤凰雪:BAAAKgAECgIIAgAAAA==.',['凶猛']='凶猛又天眞:BAACKgAFFH8eAAIZAAQIrRskEADSAAAZAAQIrRskEADSAAAqAAQKfy0AAxoACAhtH2kDAIMCABoACAhtH2kDAIMCABkACAgLH/EXAAICAAAA.',['刀伤']='刀伤木:BAAAKgAECgYIBgAAAA==.',['划桨']='划桨不用船:BAAAKgAECgUICQAAAA==.',['划水']='划水的咸鱼:BAAAKgADCggICAAAAA==.',['刚满']='刚满逮脑斧:BAAAKgAECgQIBAAAAA==.',['创星']='创星:BAAAKgAECgEIAQAAAA==.',['劉二']='劉二狗:BAACKgAFFH8GAAIGAAMIDhDdJQDaAAAGAAMIDhDdJQDaAAAqAAQKfyIAAwYACAi6IvQgAJUCAAYACAi6IvQgAJUCABcAAgjpFo1BAIcAAAAA.',['十十']='十十三:BAACKgAFFH8QAAIWAAQIrBDYKgC/AAAWAAQIrBDYKgC/AAAqAAQKfyIAAxYACAhJFygOAOwBABYACAhJFygOAOwBABgABAjzB6ukAHkAAAAA.',['千圣']='千圣丶:BAAAKgAECgYIDgAAAA==.',['千年']='千年回忆:BAABKgAECn80AAQVAAgItheMJwDvAQAVAAgIPheMJwDvAQAbAAcIsg1CLQBSAQAcAAEI1QRHUQAQAAAAAA==.',['半丶']='半丶夏:BAAAKgADCgcICAAAAA==.',['卡塔']='卡塔莉娜:BAAAKgADCggICAAAAA==.',['卡塞']='卡塞吖:BAAAKgADCgEIAQAAAA==.卡塞蒂卡佛:BAAAKgAECgUIBQAAAA==.',['卡杰']='卡杰洛斯:BAAAKgADCggIEAAAAA==.',['卷二']='卷二爷:BAAAKgAECgYIBwAAAA==.',['双剑']='双剑滑斩:BAAAKgADCggIEAAAAA==.',['变形']='变形铜刚:BAABKgAFFH8GAAMdAAYIvg7ZRwCQAAAdAAII4hDZRwCQAAAEAAQI7wIjLgBhAAAAAA==.',['古唲']='古唲丹:BAACKgAFFH8NAAQJAAQISBgLGgBHAAAIAAEI0hm6GgBQAAAJAAIIYRcLGgBHAAAHAAEIpBdxNAA8AAAqAAQKfysAAwkACAj+HMwMACECAAkACAj+HMwMACECAAcABgjxFdFYAAgBAAAA.',['叨叨']='叨叨牛:BAAAKgAECgYIDAAAAA==.',['叮噹']='叮噹猫:BAAAKgADCggICQAAAA==.',['可燃']='可燃冰绿茶:BAAAKgAECgYIBgAAAA==.',['吃骨']='吃骨頭的魚:BAABKgAFFH8GAAIOAAYI7A4cDwA8AQAOAAYI7A4cDwA8AQAAAA==.',['听说']='听说惩戒骑挺:BAAAKgADCgcIBwAAAA==.',['吾将']='吾将出谁争锋:BAAAKgAECgEIAQAAAA==.',['哀木']='哀木涕搞毛啊:BAAAKgAECgUIBgAAAA==.',['哇哇']='哇哇叫:BAAAKgAFFAIIAgAAAA==.',['哈基']='哈基米:BAAAKgAECgQICAAAAA==.',['哥哥']='哥哥救我丶:BAABKgAFFH8MAAMEAAMIpRGMHwCuAAAEAAMIpRGMHwCuAAAdAAII7gTiVABiAAAAAA==.',['啊妈']='啊妈泥:BAAAKgADCggICAAAAA==.',['啾咪']='啾咪兔兔:BAAAKgAFFAYIBAABKgAFFAgIDQAVAMIkAA==.',['喔雷']='喔雷格区:BAABKgAFFH8IAAMWAAQIYQZ0FgCuAAAWAAQIYQZ0FgCuAAAYAAEIAADmVAAAAAAAAA==.',['嘟嘟']='嘟嘟骑:BAAAKgAECgIIBAAAAA==.',['四道']='四道风:BAAAKgADCggICAAAAA==.',['因幡']='因幡巡:BAAAKgAECgQIBgAAAA==.',['图尔']='图尔斯特:BAAAKgAECgQIBAAAAA==.',['土灵']='土灵酋长:BAAAKgAECgIIAgAAAA==.',['土豆']='土豆烧肉:BAABKgAFFH8GAAMHAAYIFArgEwDwAAAHAAQIlQrgEwDwAAAJAAIIEQjGFgBEAAAAAA==.',['地狱']='地狱烈焰:BAAAKgADCgEIAQAAAA==.',['坏脾']='坏脾气萌梦梦:BAAAKgAECgMIAwAAAA==.',['堕落']='堕落丨灬信仰:BAACKgAFFH8eAAQWAAQISRqxEQDQAAAYAAMIHg24IQDRAAAWAAQISRqxEQDQAAAeAAIIDQ39BACCAAAqAAQKfyEAAxYACAh2Ih0cAPEBABYABwgfHh0cAPEBABgACAgTGRlCAPEBAAAA.',['墨丶']='墨丶泣:BAAAKgAECgEIAQAAAA==.',['墨染']='墨染:BAAAKgAECgYIBwAAAA==.',['壮壮']='壮壮:BAAAKgAFFAQIBAABKgAFFAgIDAAGAJIXAA==.',['壮烈']='壮烈成仁:BAABKgAFFH8GAAILAAYIRxOfFQBvAQALAAYIRxOfFQBvAQAAAA==.',['备用']='备用牛排:BAACKgAFFH8bAAMEAAQIBRWSDQDEAAAEAAQIBRWSDQDEAAAdAAIIiwGrNABLAAAqAAQKfx0AAx0ACAiPFpozAOwBAB0ACAiPFpozAOwBAAQACAisE0IwAGABAAAA.',['多功']='多功能玩具:BAABKgAFFH8GAAQIAAQI0QuXHABeAAAHAAIIiQiqIwBjAAAIAAIIZAOXHABeAAAJAAIIYhJRGAA7AAAAAA==.',['大天']='大天老儿:BAABKgAFFH8KAAMEAAYIcRUnCACJAQAEAAYIcRUnCACJAQAdAAQIPBXeFADoAAAAAA==.',['大梦']='大梦归离:BAAAKgADCgEIAQAAAA==.',['大眼']='大眼呱呱丶:BAACKgAFFH8GAAIHAAMIMQiHHgCRAAAHAAMIMQiHHgCRAAAqAAQKfxUAAwkACAi0DeA2ABoBAAkACAhGCOA2ABoBAAcABAhBFG5YALUAAAAA.',['大郎']='大郎的忧伤:BAAAKgADCgYIBgAAAA==.',['天之']='天之婧:BAABKgAFFH8OAAMYAAYIsQ6JHwAQAQAYAAYIXguJHwAQAQAWAAQInQ9PMACtAAAAAA==.天之降临:BAAAKgAECgYICQAAAA==.',['天命']='天命之人:BAABKgAFFH8WAAQHAAYI3CJOHwANAQAHAAYI3CJOHwANAQAIAAIIgwkAHABjAAAJAAIIxyClIgBWAAAAAA==.',['天涯']='天涯涯:BAAAKgAECgYIBgAAAA==.',['天翔']='天翔龙闪:BAAAKgAFFAUIAgAAAA==.',['天青']='天青牛莽:BAAAKgADCggICAAAAA==.',['天靖']='天靖:BAAAKgAECgEIAQAAAA==.',['太蓝']='太蓝得:BAAAKgADCggIDgAAAA==.',['奇妙']='奇妙魔法之旅:BAABKgAFFH8GAAMTAAQIviIrCgAjAQATAAMIviIrCgAjAQAPAAMIdxUKOQB+AAAAAA==.',['奔跑']='奔跑的西蓝花:BAAAKgAFFAQIBAAAAA==.',['女拳']='女拳:BAAAKgAECgIIAgAAAA==.女拳击手:BAABKgAECn8hAAIDAAgIXRQYDgBjAQADAAgIXRQYDgBjAQAAAA==.',['奴兽']='奴兽之猎:BAAAKgAECggIEQAAAA==.',['奶芯']='奶芯巧克力:BAAAKgAFFAIIAgAAAA==.',['奶萨']='奶萨:BAAAKgAECgcIBwAAAA==.',['奶骑']='奶骑:BAAAKgAFFAEIAQAAAA==.',['如冰']='如冰虽不冻:BAAAKgADCggICAAAAA==.',['如梦']='如梦令:BAAAKgAFFAIIAgAAAA==.',['妈妈']='妈妈省的:BAAAKgAECgMIBAAAAA==.',['妙脆']='妙脆角:BAAAKgADCgQIBAAAAA==.',['威廉']='威廉迪特:BAACKgAFFH8RAAIYAAUIrw5FDgBJAQAYAAUIrw5FDgBJAQAqAAQKfyQAAhgACAh4Gr45AL4BABgACAh4Gr45AL4BAAAA.',['威猛']='威猛先生丶:BAAAKgADCgIIAgAAAA==.威猛嬢嬢丶:BAAAKgAECgEIAQAAAA==.',['婧天']='婧天水月:BAAAKgAECggICAAAAA==.',['媛来']='媛来:BAAAKgAECgMIAwAAAA==.',['嫂子']='嫂子:BAAAKgAFFAEIAQAAAA==.',['子城']='子城:BAACKgAFFH8FAAMVAAIIEQgiLwCAAAAVAAIIEQgiLwCAAAAcAAIIcwFJDgBCAAAqAAQKfxQAAxUACAhdEFQ4AJsBABUACAhdEFQ4AJsBABwAAQinBtpGACQAAAAA.',['孙尚']='孙尚香丷:BAAAKgAFFAQIBAAAAA==.',['孙锤']='孙锤锤:BAAAKgAECgQIBAAAAA==.',['孤傲']='孤傲:BAAAKgADCgMIAwAAAA==.',['孤狼']='孤狼的挽歌:BAACKgAFFH8vAAMYAAQIESCWIgD/AAAYAAQIESCWIgD/AAAWAAIIIBnnJQBJAAAqAAQKfxYAAxgACAgvIz4fAHoCABgACAgvIz4fAHoCABYAAQiCGgaJADcAAAAA.',['安和']='安和昴:BAAAKgADCggICAAAAA==.',['安雅']='安雅:BAAAKgADCgIIAgAAAA==.',['安颜']='安颜:BAABKgAECn8cAAIGAAgIEyYhDwDbAgAGAAgIEyYhDwDbAgAAAA==.',['官庄']='官庄丶刘德华:BAAAKgAFFAIIAgAAAA==.',['宸谐']='宸谐音尘:BAAAKgAFFAQIAwAAAA==.',['寛恕']='寛恕:BAAAKgAFFAUIBAAAAA==.',['小小']='小小夏:BAAAKgAECgQIBAAAAA==.小小星:BAAAKgADCgQIBAAAAA==.小小炮灰:BAAAKgADCggICwAAAA==.小小马奇士:BAACKgAFFH8ZAAIGAAYI2xsmFwCjAQAGAAYI2xsmFwCjAQAqAAQKfxYAAgYACAjWHNpGAOwBAAYACAjWHNpGAOwBAAAA.',['小尛']='小尛花:BAABKgAFFH8MAAMGAAQIAyKxSgDZAAAGAAQIAyKxSgDZAAAFAAQIfBMrCADUAAAAAA==.',['小星']='小星:BAAAKgAECgQIBAAAAA==.',['小浣']='小浣龙:BAABKgAFFH8GAAIaAAQIRRDmBADDAAAaAAQIRRDmBADDAAAAAA==.',['小浪']='小浪蹄子丶:BAABKgAECn8fAAMfAAgIQBjGHgCDAQAgAAgItBfwQQChAQAfAAgI7RLGHgCDAQAAAA==.',['小灬']='小灬天:BAABKgAFFH8IAAIGAAgI9BeaDAADAgAGAAgI9BeaDAADAgAAAA==.',['小灰']='小灰蝶:BAAAKgAFFAQIBAABKgAFFAgIGAAgAFwdAA==.',['小熊']='小熊和安妮:BAAAKgADCggICAAAAA==.',['小白']='小白菇凉丶:BAABKgAFFH8FAAMNAAUIch2vDADwAAANAAQIrRyvDADwAAAOAAEIxB9FOgBXAAAAAA==.',['小色']='小色鸟:BAABKgAFFH8UAAIdAAQIKx9rJQABAQAdAAQIKx9rJQABAQABKgAFFAgIIgAZAOQfAA==.',['尐翾']='尐翾:BAACKgAFFH8oAAMOAAcI6R5iCQCOAQAOAAcI6R5iCQCOAQANAAEIpx9gEwBZAAAqAAQKfxgAAg4ABwjIGh4nALMBAA4ABwjIGh4nALMBAAAA.',['少年']='少年游:BAACKgAFFH8FAAIYAAMIaiLjHAAdAQAYAAMIaiLjHAAdAQAqAAQKfxYAAhgACAhzI1gYAJkCABgACAhzI1gYAJkCAAAA.',['尛悍']='尛悍妇:BAAAKgAFFAYIAwAAAA==.',['就叫']='就叫我公子:BAABKgAECn81AAIOAAgIkwteSQATAQAOAAgIkwteSQATAQAAAA==.',['山有']='山有桥松:BAAAKgAECggICAAAAA==.',['崔丝']='崔丝塔娜丶:BAAAKgAECggICAAAAA==.',['左在']='左在存:BAACKgAFFH8UAAIVAAMICh5MGAD4AAAVAAMICh5MGAD4AAAqAAQKfyoAAhUACAgZH4UhAMcBABUACAgZH4UhAMcBAAEqAAUUBggPACAAmBoA.',['巫九']='巫九:BAAAKgADCgIIAgAAAA==.',['帅七']='帅七七丶:BAAAKgAECgYICQAAAA==.',['希尔']='希尔薇拉:BAAAKgAECgMIAwAAAA==.',['帕鲁']='帕鲁玛:BAAAKgADCgIIAgAAAA==.',['常陆']='常陆茉子:BAABKgAFFH8QAAIhAAgIgw8wAQD4AQAhAAgIgw8wAQD4AQAAAA==.',['平衡']='平衡动力学:BAABKgAFFH8NAAICAAMIBQq0JACQAAACAAMIBQq0JACQAAAAAA==.',['幽夜']='幽夜小德:BAAAKgAECgMIAwAAAA==.',['库库']='库库琳丶血蹄:BAAAKgAECgEIAQAAAA==.',['开在']='开在太阳下丶:BAABKgAFFH8GAAILAAYIbxRJAwCoAQALAAYIbxRJAwCoAQAAAA==.',['开心']='开心麻花:BAAAKgADCgMIAwAAAA==.',['強手']='強手裂顱:BAAAKgAECgMIAwABKgAFFAgICwALADsUAA==.',['强力']='强力萨满:BAABKgAECn8nAAIBAAgI2xs7KwDQAQABAAgI2xs7KwDQAQABKgAFFAUICQABAAoSAA==.',['影魂']='影魂丨:BAACKgAFFH8eAAIGAAQIvyamBQBWAQAGAAQIvyamBQBWAQAqAAQKfx0AAgYACAi3JroCABkDAAYACAi3JroCABkDAAAA.',['德胜']='德胜:BAAAKgAECggIBgAAAA==.',['德鲁']='德鲁狂人:BAAAKgAECgEIAQAAAA==.',['心之']='心之航海图:BAAAKgAFFAQIBAAAAA==.',['心静']='心静自然清:BAABKgAFFH8UAAMYAAgIOB2IBQBBAgAYAAgIOB2IBQBBAgAWAAQItiAjJADdAAAAAA==.',['志在']='志在止戈:BAABKgAECn8dAAMbAAcIIhU0KQBwAQAbAAcIIhU0KQBwAQAVAAMI0wtigABoAAAAAA==.',['忽然']='忽然想看桃花:BAAAKgADCggICAAAAA==.',['怪鸟']='怪鸟:BAABKgAFFH8KAAIGAAgIAA1ADgC+AQAGAAgIAA1ADgC+AQAAAA==.',['怼怼']='怼怼李:BAAAKgAECgMIAwAAAA==.',['恐怖']='恐怖寄器人:BAAAKgADCggICAAAAA==.',['恐步']='恐步利刃:BAAAKgADCgEIAQAAAA==.',['恶徒']='恶徒剑逍遥:BAAAKgADCggICAAAAA==.',['悠狸']='悠狸猫:BAACKgAFFH8FAAITAAIIAQlfJABtAAATAAIIAQlfJABtAAAqAAQKfyEAAhMACAhyF6wZAOcBABMACAhyF6wZAOcBAAAA.',['悲伤']='悲伤灬间奏曲:BAAAKgADCggICAAAAA==.',['惆怅']='惆怅得微笑:BAAAKgAECgEIAwAAAA==.',['想象']='想象很美好丶:BAAAKgAFFAQIBAAAAA==.',['愛無']='愛無傳達之日:BAAAKgAECgQIDAAAAA==.',['慕灬']='慕灬鑫:BAAAKgADCgMIBAAAAA==.',['戈兰']='戈兰:BAAAKgADCgIIAgAAAA==.',['我叫']='我叫憨憨龙:BAABKgAFFH8IAAIEAAgI3wYWCQB2AQAEAAgI3wYWCQB2AQAAAA==.',['我是']='我是冠辰:BAAAKgAECggICAAAAA==.',['我曾']='我曾经是个贼:BAAAKgADCgEIAQAAAA==.',['我没']='我没有单抬:BAABKgAFFH8rAAQNAAYIqxlQBgDKAQANAAYIqxlQBgDKAQAMAAYIPhhHAgC7AQAOAAEIzw5oIwBDAAABKgAFFAgICgAOANkWAA==.',['我爱']='我爱短发:BAAAKgAECgQIBAAAAA==.',['我的']='我的圣光吖:BAAAKgADCggICAAAAA==.',['我这']='我这朵矫花:BAABKgAFFH8PAAQJAAYIQxqbBQDyAAAHAAYIqBY7FABjAQAJAAQIUhebBQDyAAAIAAIIHxiHHgBRAAAAAA==.',['戒赌']='戒赌中:BAAAKgADCggIDAAAAA==.',['戒酒']='戒酒中:BAAAKgADCggIEwAAAA==.',['战无']='战无止尽:BAAAKgADCgcICAAAAA==.',['战神']='战神激怒:BAAAKgAECggIEAAAAA==.',['抖音']='抖音游戏挽歌:BAAAKgAECgQIBAAAAA==.',['抹茶']='抹茶小懒:BAABKgAECn8iAAIgAAcIDR6BIgDyAQAgAAcIDR6BIgDyAQAAAA==.',['拉你']='拉你一把:BAAAKgADCgIIAgAAAA==.',['拔刀']='拔刀为了谁:BAAAKgAECgEIAQAAAA==.',['拳頭']='拳頭妹妹丶:BAABKgAFFH8JAAQiAAMINxByCgDEAAALAAMIwQ7pMwDHAAAiAAMIVgxyCgDEAAAKAAEIQwKjNQAfAAAAAA==.拳頭弟弟丶:BAABKgAFFH8JAAMjAAMILgVvEQCIAAAjAAMILgVvEQCIAAACAAMISQSXFAB0AAAAAA==.',['挥剑']='挥剑舞忧伤:BAAAKgAFFAQIBAAAAA==.',['擒兽']='擒兽:BAAAKgAECgYIBgAAAA==.',['收丶']='收丶破烂儿:BAAAKgAECggIDgAAAA==.',['放电']='放电的牛奶奶:BAAAKgAECgIIAgAAAA==.',['敲钟']='敲钟牛:BAAAKgADCggICAAAAA==.',['斩灬']='斩灬杀:BAAAKgAECgYIBgAAAA==.',['斩炎']='斩炎丶:BAACKgAFFH8bAAIcAAQIyCS3BAA7AQAcAAQIyCS3BAA7AQAqAAQKfx0AAhwACAidI8EFAH4CABwACAidI8EFAH4CAAAA.',['断魂']='断魂:BAAAKgAECgEIAQAAAA==.',['方程']='方程式自行车:BAAAKgAECgIIAgAAAA==.',['施翮']='施翮:BAAAKgAECgIIAwAAAA==.',['无心']='无心灬残月:BAAAKgAFFAEIAQAAAA==.',['无情']='无情:BAAAKgADCgEIAQAAAA==.',['明明']='明明就大牛牛:BAAAKgAECggIDgAAAA==.明明碧血干戚:BAAAKgAECggICAAAAA==.',['易爆']='易爆易漏电:BAAAKgAECggICAAAAA==.',['星海']='星海尽散:BAAAKgADCggICAAAAA==.',['星际']='星际之门:BAAAKgADCgEIAgAAAA==.',['是小']='是小狐狸:BAAAKgAECgUIBQAAAA==.',['晓幽']='晓幽:BAAAKgADCgMIAwAAAA==.',['晚风']='晚风依旧温柔:BAAAKgAFFAQIBAAAAA==.',['暁喵']='暁喵詸詸叫:BAABKgAFFH8WAAQUAAYIHiBpBwDeAQAUAAYIHiBpBwDeAQATAAQIkhgOCQDoAAAPAAIIHRBzOACAAAAAAA==.',['暗夜']='暗夜猎手丶:BAAAKgAECggICAAAAA==.',['暮色']='暮色狩猎:BAAAKgAECgEIAQAAAA==.',['暴走']='暴走的可乐:BAAAKgAECggICAAAAA==.',['暴躁']='暴躁小龙虾:BAAAKgAECgUICQAAAA==.暴躁龙虾:BAABKgAECn8UAAIOAAYI/ha4QgAuAQAOAAYI/ha4QgAuAQAAAA==.',['月影']='月影残空:BAABKgAFFH8JAAMYAAMIsgsTHAC5AAAYAAMIsgsTHAC5AAAWAAMIngf6PACEAAAAAA==.',['有狐']='有狐自远方来:BAAAKgADCggICAAAAA==.',['木木']='木木子酱:BAAAKgAFFAQIBAAAAA==.',['末影']='末影暮色:BAACKgAFFH8UAAIjAAQILx9VCQDzAAAjAAQILx9VCQDzAAAqAAQKfyUAAiMACAhXIxEJAK4CACMACAhXIxEJAK4CAAAA.',['术业']='术业专攻:BAABKgAECn8WAAIIAAgIXQw+EQBwAQAIAAgIXQw+EQBwAQAAAA==.',['杀不']='杀不死的坏蛋:BAABKgAFFH8GAAIKAAYIzgIZIABfAAAKAAYIzgIZIABfAAAAAA==.',['李怼']='李怼怼:BAACKgAFFH8VAAIKAAMIjx+TEgANAQAKAAMIjx+TEgANAQAqAAQKfxQAAwoACAjTF2EYANcBAAoACAjTF2EYANcBAAsAAQjGCKDQAC0AAAAA.',['果滋']='果滋果心:BAAAKgAFFAIIAgAAAA==.',['柚子']='柚子猫:BAAAKgAECggICwAAAA==.',['查拉']='查拉特拉图斯:BAAAKgAECgUIBQAAAA==.',['桃艳']='桃艳:BAAAKgADCgEIAQAAAA==.',['梁志']='梁志超的奶奶:BAAAKgAECgcICgAAAA==.',['梅狸']='梅狸猫:BAAAKgADCgUIBQAAAA==.',['梦游']='梦游的小保安:BAABKgAFFH8OAAMdAAYIygbRKwDjAAAdAAUIQgfRKwDjAAAEAAUIOQQ0HwCwAAAAAA==.',['棠梨']='棠梨煎雪:BAAAKgAFFAgIAQAAAA==.',['榴火']='榴火:BAAAKgAECgIIAgAAAA==.',['樱桃']='樱桃丸犊子:BAAAKgAFFAgIAQAAAA==.',['橙丷']='橙丷管:BAAAKgADCggICAAAAA==.',['次次']='次次有翔:BAABKgAFFH8GAAMBAAYIxhLMLgC8AAABAAQIJArMLgC8AAARAAIIlQXpIgBpAAAAAA==.',['欧仔']='欧仔:BAAAKgADCgcIBwAAAA==.',['止境']='止境的不归途:BAAAKgADCggICAAAAA==.',['死亡']='死亡之翼:BAAAKgAECgUIBQAAAA==.',['殺手']='殺手姐姐丶:BAACKgAFFH8TAAIGAAMIUxpmQADwAAAGAAMIUxpmQADwAAAqAAQKfxcAAwYACAg0IAwrAHICAAYACAg0IAwrAHICABcABAinCDVMAE4AAAAA.',['永不']='永不停日:BAAAKgAECgcIDwAAAA==.',['永夜']='永夜丶神射:BAAAKgAECgIIAgAAAA==.',['沉默']='沉默丶壁垒:BAAAKgAFFAgIAgAAAA==.',['沐川']='沐川內枯:BAACKgAFFH8NAAMVAAQIwiQ7BQBGAQAVAAQIwiQ7BQBGAQAbAAEIpx/nFQBgAAAqAAQKfxQAAxUACAjcJM0zALIBABUABgg5JM0zALIBABsAAwizJGIvAEIBAAAA.',['没棱']='没棱角的石头:BAAAKgAECgIIAgAAAA==.',['没糖']='没糖的周末丶:BAACKgAFFH8lAAMUAAUIKhsxEQAOAQAUAAUIChoxEQAOAQAPAAMIFh1RLgCrAAAqAAQKfxkABBQACAgMILAbAE4CABQACAgMILAbAE4CAA8AAQhIHcg/AFcAABMAAwiADLyhAEYAAAAA.',['泡芙']='泡芙来拉:BAAAKgADCggICAAAAA==.',['波泼']='波泼魔佛:BAABKgAFFH8GAAIYAAYIZAnCGwAkAQAYAAYIZAnCGwAkAQAAAA==.',['洛克']='洛克塔:BAABKgAFFH8QAAIVAAMIkxgHGAD6AAAVAAMIkxgHGAD6AAAAAA==.',['流云']='流云煞战:BAABKgAFFH8IAAIVAAgIJQqeBgAUAgAVAAgIJQqeBgAUAgAAAA==.',['流竜']='流竜馬:BAAAKgADCggIDAAAAA==.',['涧山']='涧山黄泉:BAAAKgAECggIEgAAAA==.',['淡定']='淡定的整死你:BAABKgAFFH8GAAIGAAYIZgxqKQBCAQAGAAYIZgxqKQBCAQAAAA==.',['淡忘']='淡忘曙光:BAAAKgAFFAQIBAAAAA==.',['淡慕']='淡慕:BAAAKgAECgYIBgAAAA==.',['清平']='清平乐:BAAAKgAFFAIIAgAAAA==.',['清浅']='清浅流年:BAAAKgAECgYIBgAAAA==.',['游戏']='游戏真没意思:BAABKgAFFH8GAAINAAMIKQWQJACPAAANAAMIKQWQJACPAAAAAA==.',['湖南']='湖南口味王:BAAAKgAECgIIAgAAAA==.',['溜肥']='溜肥肠:BAAAKgAECgIIAgAAAA==.',['灬乔']='灬乔一帆灬:BAAAKgADCggIKAAAAA==.',['灬呼']='灬呼哈灬:BAAAKgAECgcIDAAAAA==.',['灬小']='灬小陀螺灬:BAAAKgAECgQIBAAAAA==.',['灬氤']='灬氤氲之息灬:BAAAKgAFFAIIBAAAAA==.',['灬霜']='灬霜丶火灬:BAAAKgAFFAEIAQAAAA==.',['灵魂']='灵魂石丶:BAABKgAFFH8MAAMHAAYIOQ7bGgAvAQAHAAYIfQvbGgAvAQAJAAEIng+9KABIAAAAAA==.',['灿烂']='灿烂小星:BAAAKgAECgMIAwAAAA==.灿烂的宝贝:BAAAKgADCggICAAAAA==.灿烂的星空:BAAAKgADCgIIAgAAAA==.',['烈之']='烈之楠瓜派:BAABKgAFFH8HAAIVAAMI+AuIIwDEAAAVAAMI+AuIIwDEAAAAAA==.',['烟雨']='烟雨流年灬:BAAAKgAFFAQIBAAAAA==.烟雨维德:BAAAKgADCggICAAAAA==.',['烽神']='烽神大刚:BAABKgAFFH8GAAIOAAYInRVBLwCJAAAOAAYInRVBLwCJAAAAAA==.',['烽谐']='烽谐大刚:BAABKgAFFH8PAAMLAAYIUB8kCwASAQAKAAUIVhsuDQBDAQALAAQIfx8kCwASAQABKgAFFAgIHAALANsdAA==.',['熬到']='熬到你们死:BAAAKgAECggIEAAAAA==.',['熱情']='熱情似火:BAAAKgADCgUIBQAAAA==.',['燃宝']='燃宝哥哥:BAABKgAFFH8FAAIkAAMIZQTaBgBgAAAkAAMIZQTaBgBgAAAAAA==.',['爆了']='爆了皮的香肠:BAAAKgADCgIIAgAAAA==.',['爱乐']='爱乐芬特:BAAAKgAECgEIAQAAAA==.',['爱吃']='爱吃土豆丝:BAAAKgAECgQIBQAAAA==.',['爱意']='爱意随钟起:BAAAKgADCgEIAQAAAA==.',['爷傲']='爷傲奈我何:BAAAKgAFFAMIAwAAAA==.',['牛肉']='牛肉火锅:BAAAKgAECgcIDQAAAA==.牛肉面:BAACKgAFFH8IAAMYAAIIlhppMACYAAAYAAII6hNpMACYAAAWAAIINhWaIABvAAAqAAQKfyMAAxYACAh5JDQUAC8CABYACAh5JDQUAC8CABgAAwgAG12bAPIAAAEqAAUUCAgiABkA5B8A.',['牧有']='牧有帝屁艾斯:BAAAKgADCgYIBgAAAA==.',['狐尔']='狐尔萨斯:BAAAKgAECggICAAAAA==.',['狐猎']='狐猎狗友:BAAAKgADCggICAAAAA==.',['狐鹏']='狐鹏狗猷:BAAAKgAFFAMIAQAAAA==.',['独孤']='独孤月影:BAAAKgAECggIEQAAAA==.',['狮子']='狮子歌歌:BAAAKgAFFAIIBAAAAA==.',['猎魔']='猎魔猫:BAAAKgADCgMIAwAAAA==.',['猫荷']='猫荷:BAABKgAFFH8GAAIOAAYIjhj5CQDlAAAOAAYIjhj5CQDlAAAAAA==.',['玉光']='玉光盈:BAAAKgAECggICQAAAA==.',['玉楼']='玉楼春:BAAAKgAFFAQIBAABKgAFFAgICAAgALAUAA==.',['玉玉']='玉玉豆:BAAAKgAECgQIBwAAAA==.',['王淳']='王淳煜:BAAAKgAECgMIBAAAAA==.',['玛莲']='玛莲妮亚:BAAAKgAFFAMIAwAAAA==.',['现场']='现场直播:BAACKgAFFH8oAAMbAAYIwRseBgBxAQAbAAUIwRseBgBxAQAVAAMIchuZGgCuAAAqAAQKfywAAxsACAhvIg4hAK0BABsABQgnIA4hAK0BABUABAiCIp1PACIBAAAA.',['珈灬']='珈灬珈:BAAAKgAECgcIBwAAAA==.',['琅琊']='琅琊山我装死:BAAAKgAECgYIBgAAAA==.',['理想']='理想三旬丶:BAAAKgADCggICAAAAA==.',['琴瑟']='琴瑟:BAAAKgAECgQIBQAAAA==.',['璀璨']='璀璨火焰:BAAAKgAECggIBAAAAA==.',['璧癖']='璧癖五五開:BAAAKgADCgEIAQAAAA==.',['瓦顶']='瓦顶顶:BAAAKgAECgMIAwAAAA==.',['甜修']='甜修:BAAAKgADCggICAAAAA==.',['电哥']='电哥刷大白:BAAAKgAECgEIAgAAAA==.',['电梯']='电梯战神:BAAAKgAECggICAAAAA==.',['电炮']='电炮飞脚丶:BAAAKgADCgEIAQAAAA==.',['疯狂']='疯狂屠戮:BAACKgAFFH8ZAAIGAAQIshTZKgDGAAAGAAQIshTZKgDGAAAqAAQKfxkAAgYACAhXHCJzALEBAAYACAhXHCJzALEBAAAA.',['疯雪']='疯雪飘摇:BAAAKgAECgcIDgAAAA==.',['白色']='白色霓虹:BAAAKgAECgEIAQAAAA==.',['白鸽']='白鸽乌鸦:BAAAKgAECgMIAwAAAA==.',['百万']='百万伏特:BAAAKgADCggICAAAAA==.',['百变']='百变小牛:BAAAKgAFFAMIAwAAAA==.',['皎皎']='皎皎白驹:BAAAKgAECgQIBAAAAA==.',['盐水']='盐水毛豆丶:BAAAKgAFFAgIBAAAAA==.',['盗跖']='盗跖:BAAAKgAECggICAAAAA==.',['看看']='看看啊:BAACKgAFFH8bAAIVAAMIkyFWDQAGAQAVAAMIkyFWDQAGAQAqAAQKfyIAAxUACAi4I0kHAMQCABUACAi4I0kHAMQCABwAAggiEhI9AGgAAAAA.',['眼眉']='眼眉调:BAABKgAFFH8GAAINAAYIvgirAwBkAQANAAYIvgirAwBkAQAAAA==.',['瞅俺']='瞅俺呐熊噻:BAAAKgADCgEIAgAAAA==.',['瞅我']='瞅我嘎哈:BAAAKgAECgYIBgAAAA==.',['矮子']='矮子暴捶:BAAAKgAFFAMIAwAAAA==.',['石之']='石之守望:BAAAKgAECgcIDwAAAA==.',['砍扎']='砍扎:BAAAKgADCgEIAQAAAA==.',['破名']='破名想了一年:BAAAKgAECgYIBwAAAA==.',['碎钞']='碎钞机咔嚓嚓:BAAAKgAFFAgIBAAAAA==.',['碧海']='碧海云遥:BAAAKgADCgMIAwAAAA==.',['碳烤']='碳烤小黄牛:BAABKgAFFH8OAAMEAAQIUxkNGADgAAAEAAQIUxkNGADgAAAdAAQIAx34LgDYAAAAAA==.',['神张']='神张角:BAAAKgADCgIIAgAAAA==.',['神牧']='神牧:BAAAKgAECgcIDQAAAA==.',['离我']='离我而去:BAAAKgAECgUIEgAAAA==.',['秋名']='秋名山山神:BAAAKgAFFAgIBAAAAA==.',['秋泪']='秋泪无痕丶:BAAAKgADCgEIAQAAAA==.',['积积']='积积阳阳德丶:BAAAKgADCgcIBwAAAA==.',['穆恩']='穆恩大地之怒:BAAAKgADCgEIAQAAAA==.',['笔墨']='笔墨染流年:BAABKgAECn8kAAIGAAgIYyN3KQB3AgAGAAgIYyN3KQB3AgAAAA==.',['等你']='等你下钟:BAABKgAFFH8SAAMbAAgIzR46BQDgAQAbAAgIwh06BQDgAQAVAAMILRRyDwD9AAAAAA==.',['简単']='简単:BAAAKgAECgYIDAAAAA==.',['糖棉']='糖棉花:BAACKgAFFH8cAAIlAAQIwiDPCAD+AAAlAAQIwiDPCAD+AAAqAAQKfyEAAiUACAi0IiEHAJcCACUACAi0IiEHAJcCAAAA.',['糖糖']='糖糖果:BAABKgAFFH8FAAIGAAIIQg1OQACHAAAGAAIIQg1OQACHAAAAAA==.',['索尔']='索尔丶:BAAAKgAECgEIAQAAAA==.',['紫剑']='紫剑寒风:BAAAKgAECgIIAgAAAA==.',['紫文']='紫文:BAAAKgADCgQIBgAAAA==.',['紫禁']='紫禁摇摆:BAAAKgAFFAgIBAAAAA==.',['红尘']='红尘旧梦丶:BAABKgAECn8cAAIJAAgIvh7FEgDvAQAJAAgIvh7FEgDvAQAAAA==.',['红糖']='红糖雪糕:BAAAKgAFFAYIBAAAAA==.',['红莲']='红莲之影:BAAAKgAECgQIBAAAAA==.',['红萨']='红萨:BAAAKgADCggICAAAAA==.',['红鼻']='红鼻毛船长:BAAAKgAECgIIAwAAAA==.',['纯属']='纯属新号:BAAAKgADCgIIAgAAAA==.',['线条']='线条小狗:BAAAKgADCgIIAgAAAA==.',['绝地']='绝地蒙牛:BAAAKgAECgMIAwAAAA==.',['绫波']='绫波丽:BAABKgAFFH8GAAIXAAYISQZOCwDVAAAXAAYISQZOCwDVAAAAAA==.',['绿毛']='绿毛饲养员:BAAAKgADCggICAAAAA==.',['绿色']='绿色天然呆:BAAAKgADCggICAAAAA==.',['缔造']='缔造辉煌:BAAAKgAFFAQIAgAAAA==.',['缶夬']='缶夬彳惪:BAAAKgAECgYICgAAAA==.',['罖罖']='罖罖亽亽:BAAAKgAECgQIBgAAAA==.',['罗罗']='罗罗汤马西:BAAAKgADCgQIBAAAAA==.',['羅生']='羅生門:BAAAKgAECgQIBAAAAA==.',['美妙']='美妙梦幻之旅:BAABKgAFFH8KAAIOAAYI0hR1HgDQAAAOAAYI0hR1HgDQAAAAAA==.',['美屡']='美屡与劣人:BAAAKgADCggICAAAAA==.',['老子']='老子是个狐狸:BAAAKgAECgMIAwAAAA==.',['聖光']='聖光閃現:BAAAKgADCggICAAAAA==.',['肆吥']='肆吥像:BAAAKgADCggICAAAAA==.',['脚踝']='脚踝终结者:BAAAKgAECgIIAgAAAA==.',['至高']='至高领:BAAAKgAFFAMIAwAAAA==.',['艾莉']='艾莉娅史塔克:BAAAKgAFFAQIBAAAAA==.',['艾莎']='艾莎妮娅逐星:BAACKgAFFH8PAAIgAAMImBpuIwDtAAAgAAMImBpuIwDtAAAqAAQKfyMAAiAACAgUISwPAIwCACAACAgUISwPAIwCAAAA.',['艾薇']='艾薇丽:BAAAKgADCgUIBQAAAA==.',['艾露']='艾露玛:BAAAKgAFFAYIAgAAAA==.',['芒果']='芒果锅包肉:BAAAKgAFFAQIBAAAAA==.',['芝士']='芝士聋人:BAACKgAFFH8iAAIZAAgI5B91AABhAgAZAAgI5B91AABhAgAqAAQKfy4AAxkACAg4IQ8TADECABkACAg4IQ8TADECABoAAgirBYElAEkAAAAA.',['芥末']='芥末辣椒丶:BAABKgAFFH8LAAIbAAMIRhBaGADGAAAbAAMIRhBaGADGAAAAAA==.',['芬必']='芬必德:BAABKgAECn8bAAMEAAgIOR82EQA+AgAEAAgIOR82EQA+AgAdAAQISBJHmQCjAAAAAA==.',['花無']='花無凋零之時:BAABKgAFFH8YAAQmAAQIgSTfAgA8AQAmAAMIgSTfAgA8AQAdAAQIEgcRLwBzAAAkAAEIixbnBgA8AAAAAA==.',['芹菜']='芹菜:BAAAKgAFFAYIBAABKgAFFAgICAAXAAEUAA==.',['苏誉']='苏誉:BAAAKgAECgYIBgAAAA==.',['若栎']='若栎:BAABKgAECn8UAAIVAAgIRRI8KgCQAQAVAAgIRRI8KgCQAQAAAA==.',['英维']='英维安娜:BAABKgAFFH8HAAIGAAQIzRKJIQDlAAAGAAQIzRKJIQDlAAAAAA==.',['英雄']='英雄苍穹:BAAAKgAECgQICAAAAA==.',['茨木']='茨木:BAAAKgADCggICgAAAA==.',['莊生']='莊生夢蝶:BAAAKgAFFAgIBAAAAA==.',['莫一']='莫一夕:BAAAKgAECgcIDwAAAA==.',['莫甘']='莫甘娜:BAAAKgAECgIIAgAAAA==.',['莱德']='莱德:BAAAKgAECgMIAwAAAA==.',['菈妮']='菈妮丨:BAACKgAFFH8eAAIGAAQIZxXNJwDTAAAGAAQIZxXNJwDTAAAqAAQKfyUAAgYACAhZHtk5AEECAAYACAhZHtk5AEECAAAA.',['菊花']='菊花残:BAAAKgAECggICAAAAA==.',['菩萨']='菩萨蛮:BAAAKgAECgcIBwAAAA==.',['萌多']='萌多丶:BAAAKgAECgcIBwAAAA==.',['萧丶']='萧丶瑟:BAABKgAFFH8GAAIdAAYIpBI/CQAkAQAdAAYIpBI/CQAkAQAAAA==.',['萨琪']='萨琪玛:BAAAKgADCggICAAAAA==.',['落花']='落花流水:BAAAKgAECggIDwABKgAECggIFwAEAAkbAA==.',['蒙齐']='蒙齐路飞:BAABKgAECn8gAAIdAAgIVyRpDgC0AgAdAAgIVyRpDgC0AgABKgAECggIGwAVANkkAA==.',['蓝发']='蓝发小妖:BAABKgAFFH8GAAMNAAMICRBIDQCgAAANAAMICRBIDQCgAAAMAAMIqAjfEgCYAAAAAA==.',['蓝瑟']='蓝瑟铁骑:BAAAKgAECgcIBwAAAA==.',['薄荷']='薄荷冰珠:BAAAKgAECggIEAAAAA==.',['薯条']='薯条鳕鱼:BAAAKgAFFAMIAwAAAA==.',['蘇蘇']='蘇蘇:BAAAKgAECgcICgAAAA==.',['蘑菇']='蘑菇精:BAAAKgADCggICAAAAA==.',['血色']='血色天涯:BAACKgAFFH8GAAMTAAUIwhiYEgCVAAAUAAQIoxXqIQCpAAATAAIIChWYEgCVAAAqAAQKfygABBMACAhTH3gYAPIBABMACAghHHgYAPIBAA8ABQiDHXYPAFYBABQABQibEeZjAOIAAAAA.',['袖缠']='袖缠云:BAAAKgAECggICAAAAA==.',['被窝']='被窝里的幸福:BAAAKgAECgcIEAAAAA==.',['裙下']='裙下之臣:BAABKgAFFH8KAAMPAAgIIRW+CADqAQAPAAgImhS+CADqAQAUAAIIpxXGJACTAAAAAA==.',['西北']='西北偏北:BAAAKgAFFAYIBAAAAA==.',['西炎']='西炎山大祭司:BAAAKgAECgYIBgAAAA==.',['观緈']='观緈:BAAAKgAECggICAAAAA==.',['解冻']='解冻冰虫:BAACKgAFFH8IAAIgAAYI1BO9FgDnAAAgAAYI1BO9FgDnAAAqAAQKfyEAAiAACAhMIc8TAGMCACAACAhMIc8TAGMCAAAA.',['訫淚']='訫淚:BAABKgAFFH8FAAMDAAUIkQtMCACIAAADAAQIGQ1MCACIAAAjAAEI+QZlIwBIAAAAAA==.',['訫随']='訫随风飘逝:BAAAKgAFFAIIAgAAAA==.',['誑渢']='誑渢廳我号令:BAAAKgAECgcIEgAAAA==.',['计都']='计都罗睺:BAAAKgAFFAMIAwAAAA==.',['诅咒']='诅咒之锤:BAABKgAFFH8GAAIHAAYIjx8tDQC5AQAHAAYIjx8tDQC5AQAAAA==.',['诡咒']='诡咒:BAAAKgAECgEIAQAAAA==.',['诡异']='诡异嘚微笑:BAAAKgAFFAQIBAABKgAFFAgIGgAXADESAA==.',['请以']='请以猫为核:BAAAKgAECgYIBgAAAA==.',['请组']='请组:BAABKgAFFH8GAAIEAAYIAwQrGADfAAAEAAYIAwQrGADfAAAAAA==.',['谁在']='谁在那里不语:BAAAKgAECggIDgAAAA==.',['谜醉']='谜醉丶:BAAAKgAFFAMIAwAAAA==.',['豌豆']='豌豆黄:BAAAKgAECgIIAgAAAA==.',['貓貓']='貓貓愛吃魚:BAABKgAFFH8GAAIgAAMISQk+HACwAAAgAAMISQk+HACwAAAAAA==.',['贪财']='贪财好色俗人:BAAAKgAFFAIIAgAAAA==.',['赖赖']='赖赖乎:BAACKgAFFH8QAAIfAAMIowpAGQCEAAAfAAMIowpAGQCEAAAqAAQKfx4AAh8ABwgBEbwrACkBAB8ABwgBEbwrACkBAAAA.',['赵美']='赵美美:BAAAKgADCggICAAAAA==.',['跳楼']='跳楼机大王:BAABKgAFFH8GAAIdAAYIEhIqFgBnAQAdAAYIEhIqFgBnAQAAAA==.',['辣妹']='辣妹:BAABKgAFFH8GAAILAAYImAIDKgDlAAALAAYImAIDKgDlAAAAAA==.',['达瓦']='达瓦里氏:BAAAKgADCgEIAQAAAA==.',['迈克']='迈克尔猪八戒:BAAAKgAECgYIBgAAAA==.',['还能']='还能抢救亿下:BAAAKgADCggICAAAAA==.',['追风']='追风:BAAAKgADCggIEAAAAA==.',['逆水']='逆水风寒:BAACKgAFFH8FAAMIAAUIwQzzBwDpAAAIAAQI2A/zBwDpAAAJAAEIfQPXGABJAAAqAAQKfxgABAkACAjgEIY1AA4BAAkABwh5CoY1AA4BAAgABQj0DQYkAL8AAAcABAjNEGNiAJgAAAEqAAUUCAglAAgAIRwA.',['逍遥']='逍遥枭妖:BAAAKgAFFAIIAgAAAA==.',['逸欣']='逸欣:BAAAKgAECggICAAAAA==.',['逼满']='逼满:BAAAKgADCgEIAQAAAA==.',['遇见']='遇见夏天:BAACKgAFFH8UAAIMAAQIkiENDgAgAQAMAAQIkiENDgAgAQAqAAQKfyMAAgwACAiYIhwdAO0BAAwACAiYIhwdAO0BAAAA.',['遗忘']='遗忘的桃花源:BAABKgAECn8VAAIGAAgIlxgzVAD4AQAGAAgIlxgzVAD4AQAAAA==.',['那个']='那个武僧:BAABKgAECn8XAAIOAAgI3hEvMgB5AQAOAAgI3hEvMgB5AQAAAA==.',['酋长']='酋长的传令官:BAAAKgAECgEIAgAAAA==.酋长的微笑:BAAAKgAECgMIBAAAAA==.',['野杏']='野杏儿:BAAAKgAFFAQIBAAAAA==.',['鎫瀛']='鎫瀛嫨衅:BAABKgAFFH8QAAIHAAgIcRwlBQBKAgAHAAgIcRwlBQBKAgAAAA==.',['铁血']='铁血英魂:BAAAKgAECgcIEwAAAA==.',['长发']='长发飘飘:BAAAKgAECgcIEAAAAA==.',['长安']='长安常乐:BAAAKgAFFAUIAQAAAA==.',['開在']='開在太陽下丶:BAABKgAFFH8GAAMEAAYIhAceHADCAAAEAAUI9QYeHADCAAAdAAEIowGsYAA3AAABKgAFFAgIBAAQAAAAAA==.',['阵发']='阵发性噪狂:BAABKgAFFH8MAAMLAAcIOB5kBwAxAQALAAcIABdkBwAxAQAKAAQIrSF0BgArAQAAAA==.',['阿叮']='阿叮:BAAAKgADCgcIBwAAAA==.',['阿哲']='阿哲阿别:BAAAKgADCggICAAAAA==.',['阿尔']='阿尔蒂玛:BAAAKgAECgMIAwAAAA==.',['阿布']='阿布团:BAABKgAFFH8XAAQTAAYIFCAuAwDRAQATAAYIFCAuAwDRAQAPAAUIMxivGwAIAQAUAAQIjA0YIwDKAAAAAA==.阿布团五:BAABKgAFFH8UAAMLAAYI8BxpCQCYAQALAAYI8BxpCQCYAQAKAAYI7Q0sFQD4AAABKgAFFAgIDgALAEoXAA==.',['阿洛']='阿洛艾莉丶:BAAAKgAECgQIBAAAAA==.',['阿纳']='阿纳贝尔卡多:BAACKgAFFH8eAAMIAAQIsiVpCwDYAAAIAAQIbhtpCwDYAAAHAAIIzCTGFgDIAAAqAAQKfxkABAgACAg0JmIMAKkBAAgABAhoJWIMAKkBAAkAAwiOJt9BANkAAAcAAgjNJQFoANQAAAAA.',['阿葵']='阿葵娅莉阿斯:BAAAKgAFFAQIAgAAAA==.',['陆月']='陆月中暑:BAAAKgAFFAQIBAAAAA==.',['陌南']='陌南尘:BAAAKgAECgcICAAAAA==.',['隐射']='隐射一脸:BAAAKgAECggICAAAAA==.',['难得']='难得糊涂:BAAAKgAECggIDQAAAA==.',['雪碧']='雪碧的兽猎:BAAAKgAECgIIAgAAAA==.',['雯灬']='雯灬雯:BAAAKgAECgIIAgAAAA==.',['零度']='零度之吻:BAAAKgAECgMIAwAAAA==.',['雷文']='雷文顿:BAAAKgAECgQIBAAAAA==.',['霍格']='霍格沃茨校花:BAABKgAFFH8NAAINAAgIMRYAAwD7AQANAAgIMRYAAwD7AQAAAA==.',['顺仔']='顺仔大帅比:BAABKgAECn8VAAIGAAgIViBVKgB0AgAGAAgIViBVKgB0AgAAAA==.顺仔小帅比:BAAAKgAECggIEAAAAA==.',['风中']='风中穿行:BAACKgAFFH8IAAMfAAMIpwH5IgBMAAAfAAMI7QD5IgBMAAAgAAEIHwQVTQA0AAAqAAQKfxUAAx8ACAjYBKBIAJ4AAB8ACAiYBKBIAJ4AACAAAgjOAo2lABwAAAAA.',['风之']='风之舞者:BAAAKgADCgEIAgAAAA==.',['风舞']='风舞苍莲:BAACKgAFFH8cAAITAAYIuRaxBACAAQATAAYIuRaxBACAAQAqAAQKfx8AAxMACAhfIvMKAK4CABMACAhfIvMKAK4CABQAAghaDMqTAEsAAAAA.',['风行']='风行者丶露娜:BAAAKgAECgIIAgAAAA==.',['风雪']='风雪守护:BAAAKgADCgEIAQAAAA==.',['饭人']='饭人超:BAAAKgADCgUIBQAAAA==.',['香蕉']='香蕉芭比丶:BAAAKgAECgEIAQAAAA==.',['騎士']='騎士精魂:BAAAKgAECgIIAgAAAA==.',['驴打']='驴打滚:BAABKgAFFH8LAAIGAAYIWR4lIABvAQAGAAYIWR4lIABvAQAAAA==.',['高弗']='高弗雷:BAAAKgADCggICAAAAA==.',['高松']='高松灯:BAAAKgAECggICQAAAA==.',['高血']='高血压:BAAAKgADCgQIBAAAAA==.',['鬼不']='鬼不曾伤害我:BAACKgAFFH8dAAMYAAQIbBkVKQDhAAAYAAQIbBkVKQDhAAAWAAEI1QGrKwAeAAAqAAQKfyAAAxgACAgkGP5AAPUBABgACAgkGP5AAPUBABYAAgitBe6BAEcAAAAA.',['魇丶']='魇丶枭:BAAAKgAECgIIAgAAAA==.',['魔礼']='魔礼蓝:BAAAKgADCggICAAAAA==.',['鱼怒']='鱼怒:BAAAKgADCggICAAAAA==.',['鹏哥']='鹏哥在稳了:BAAAKgAECgEIAQAAAA==.',['鹤冲']='鹤冲天:BAABKgAFFH8GAAICAAYIeBOIDwAzAQACAAYIeBOIDwAzAQAAAA==.',['黄哲']='黄哲维:BAABKgAFFH8GAAICAAYIHAXFFQD2AAACAAYIHAXFFQD2AAAAAA==.',['黄瓜']='黄瓜刺:BAAAKgAECgUIBQAAAA==.',['黯雨']='黯雨:BAAAKgAECggIDAAAAA==.',['龙啸']='龙啸紫峰:BAAAKgAECgcIBwAAAA==.',['龙皇']='龙皇异次元:BAAAKgAFFAYIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end