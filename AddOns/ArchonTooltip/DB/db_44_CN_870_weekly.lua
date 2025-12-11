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
 local lookup = {'Paladin-Holy','Paladin-Retribution','Rogue-Subtlety','Rogue-Assassination','Warlock-Destruction','Warlock-Demonology','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Mage-Arcane','DeathKnight-Frost','Warrior-Fury','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','DemonHunter-Havoc','Druid-Balance','Druid-Restoration','DemonHunter-Vengeance','Warrior-Protection','Paladin-Protection','Warrior-Arms','Warlock-Affliction','Shaman-Restoration','Priest-Holy','Priest-Shadow','Priest-Discipline','Shaman-Elemental','Mage-Fire','DeathKnight-Unholy','Rogue-Outlaw','Druid-Feral','Monk-Mistweaver','Monk-Brewmaster','DeathKnight-Blood','Unknown-Unknown',}; local provider = {region='CN',realm='阿比迪斯',name='CN',type='weekly',zone=44,date='2025-12-09',data={Ab='Abeauty:BAABLAAFFH8FAAMBAAUIWQtgGgDrAAABAAQIPAtgGgDrAAACAAEI1QuZXwBHAAAAAA==.Absolution:BAABLAAECn8aAAMDAAYI9x7kHgCcAQADAAUIsh3kHgCcAQAEAAUIERuSNwCBAQAAAA==.',Al='Alexandre:BAABLAAFFH8NAAMFAAIIVx/RLwC8AAAFAAIIVx/RLwC8AAAGAAEIICT3IABmAAAAAA==.',An='Anoxia:BAACLAAFFH8hAAMHAAYI3yNeEAANAgAHAAYImCNeEAANAgAIAAIIXhpLGQCmAAAsAAQKfxYAAwcABwhpIBJSADoCAAcABgjxIRJSADoCAAgABwgWHEIqACUCAAAA.',Co='Cokeavenger:BAAALAAECggICAAAAA==.',De='Deathwill:BAAALAAECgYIDAAAAA==.Dejavu:BAAALAADCggICAAAAA==.Demonly:BAAALAADCggIDgAAAA==.',Dh='Dht:BAAALAADCgYIBgAAAA==.',Di='Dietrich:BAAALAADCgIIAgAAAA==.',Dj='Djbass:BAAALAAECgYIBgAAAA==.',Ef='Efsggs:BAAALAAECgIIAgAAAA==.',El='Elysia:BAAALAAFFAIIAgAAAA==.',Er='Erdebuxing:BAABLAAFFH8GAAICAAIIeiA0KgC1AAACAAIIeiA0KgC1AAAAAA==.',Et='Eternalpain:BAAALAAFFAIIBAAAAA==.',Ev='Evo:BAAALAADCgIIAgAAAA==.',Fo='Foc:BAAALAAECgYIBgAAAA==.',Fr='Fraser:BAAALAAECgQIBAAAAA==.',Fu='Futures:BAABLAAFFH8GAAMJAAII3hWyDwCQAAAJAAII3hWyDwCQAAAKAAIIsQgZWwCEAAAAAA==.',Gr='Grommas:BAAALAAECgMIAwAAAA==.',He='Heike:BAAALAAFFAIIAgAAAA==.Hellyes:BAAALAADCggIDQAAAA==.',Hm='Hmonster:BAAALAAECgYICAAAAA==.',Ho='Holyrovski:BAACLAAFFH8cAAIBAAYILxGtEQB0AQABAAYILxGtEQB0AQAsAAQKfxQAAgEABggFFZM4AIIBAAEABggFFZM4AIIBAAAA.',Jo='Joycee:BAAALAAECgcIBwAAAA==.',Ka='Kariada:BAAALAAECgUIBwAAAA==.',La='Laura:BAAALAAECgIIAgAAAA==.',Ly='Lyone:BAAALAADCgIIAgAAAA==.',Ma='Magicrain:BAABLAAFFH8LAAMEAAYIUgTdEQDqAAAEAAQIywTdEQDqAAADAAIIYgP8FwA3AAAAAA==.Maintanker:BAABLAAFFH8LAAILAAMIDxPQXQCWAAALAAMIDxPQXQCWAAABLAAFFAYIHQAGANIgAA==.',Me='Medeinchina:BAACLAAFFH8PAAIMAAMI1QxcPwBuAAAMAAMI1QxcPwBuAAAsAAQKfzIAAgwACAjzFeIgAOoBAAwACAjzFeIgAOoBAAAA.',Ne='Nelthariona:BAACLAAFFH8lAAQNAAYIvxNxAwCcAQANAAYIvxNxAwCcAQAOAAQIdgrDDQAGAQAPAAEI2ADFHQAnAAAsAAQKfy0AAg4ACAiyIBgLAO4CAA4ACAiyIBgLAO4CAAAA.',Pa='Pandora:BAACLAAFFH8TAAIQAAUIeBbOKwA9AQAQAAUIeBbOKwA9AQAsAAQKfysAAhAACAjpGvJIAEYCABAACAjpGvJIAEYCAAAA.Papiyas:BAAALAAECgEIAQAAAA==.',Pl='Playerwgqxyk:BAAALAAECgYICAAAAA==.',Qi='Qingsong:BAABLAAECn8kAAIKAAgI4hZvFwDuAQAKAAgI4hZvFwDuAQABLAAFFAYIBgAKAM8NAA==.',Qx='Qxdk:BAAALAAFFAUIBAAAAA==.',Ra='Radio:BAAALAAECgYIDAAAAA==.',Re='Reroll:BAABLAAFFH8IAAIBAAII5Q97IACHAAABAAII5Q97IACHAAAAAA==.',Sa='Sanxin:BAAALAAECgYIDAAAAA==.',Te='Tefuir:BAABLAAFFH8FAAILAAMIjRIvLwDeAAALAAMIjRIvLwDeAAAAAA==.',Vi='Vigoss:BAAALAAECgYIEgAAAA==.',Vo='Vortue:BAAALAAFFAIIAwAAAA==.',Xc='Xclent:BAAALAAFFAIIAgAAAA==.',Ya='Yald:BAAALAAFFAIIAwAAAA==.',Yy='Yyoorha:BAAALAAECgIIAgAAAA==.',['一个']='一个小德德丶:BAAALAAECgEIAQAAAA==.',['一曲']='一曲双人舞:BAAALAAECgYIBwAAAA==.',['一炮']='一炮红到底:BAAALAAECgUIBgAAAA==.',['一路']='一路發丶:BAAALAAECgYIBgAAAA==.',['丁达']='丁达尔迅贤:BAAALAAFFAYIAwAAAA==.',['七月']='七月沫:BAAALAAECggIBwAAAA==.',['三横']='三横一竖的人:BAAALAAECgQIDAAAAA==.',['上去']='上去就是斩:BAAALAAECgYIBgAAAA==.',['上海']='上海老克勒:BAAALAADCggICAAAAA==.',['下巴']='下巴长胸毛:BAAALAAECgYICQAAAA==.',['世间']='世间祥瑞:BAABLAAFFH8XAAIIAAYIixftBQB1AQAIAAYIixftBQB1AQAAAA==.',['东北']='东北大仙:BAAALAAFFAIIAwAAAA==.',['丨净']='丨净莲妖火丨:BAAALAAECggICAAAAA==.',['丨奈']='丨奈依组特:BAAALAAECgUIBQAAAA==.',['丨斩']='丨斩月丨:BAABLAAFFH8KAAILAAYIZRfEIAAeAQALAAYIZRfEIAAeAQAAAA==.',['丨浮']='丨浮生若梦丨:BAABLAAFFH8GAAMRAAYIjg7AGwD7AAARAAUI3Q3AGwD7AAASAAEIogkyXAA4AAAAAA==.',['丨消']='丨消逝的魂:BAABLAAFFH8IAAICAAIIFhDeRgCZAAACAAIIFhDeRgCZAAABLAAFFAIICAAMADgUAA==.',['丨火']='丨火鸡味锅巴:BAAALAAECgQIBQAAAA==.',['丨神']='丨神聖疯爆丨:BAAALAAECgcIBwAAAA==.',['丨黑']='丨黑寡妇丨:BAAALAAECggICAAAAA==.',['丶东']='丶东风谷早苗:BAAALAADCgEIAQAAAA==.',['丶加']='丶加尓鲁什:BAAALAAFFAEIAQAAAA==.',['丿灬']='丿灬弑念丶殺:BAAALAAFFAIIAgAAAA==.',['丿蒜']='丿蒜头丶:BAAALAADCgYICQAAAA==.',['乄丶']='乄丶凛峯:BAAALAAFFAIIAgAAAA==.',['乄天']='乄天涯:BAAALAAFFAIIAgAAAA==.',['乌克']='乌克拉玛特:BAAALAADCggICAAAAA==.',['乜云']='乜云云:BAABLAAECn8aAAIHAAgImBMFjgA1AQAHAAgImBMFjgA1AQAAAA==.',['九菜']='九菜:BAAALAAECgYIBwAAAA==.',['也许']='也许忘了:BAAALAADCgYIBgAAAA==.',['事妤']='事妤愿违:BAEBLAAFFH8PAAICAAYIHRlHHACBAQACAAYIHRlHHACBAQAAAA==.',['二狗']='二狗子跟我走:BAAALAAECgYIBgAAAA==.',['二零']='二零零九:BAAALAAECgMIBAAAAA==.',['云芝']='云芝:BAABLAAFFH8KAAMJAAIIUSAQEwBNAAAJAAIIUSAQEwBNAAAKAAIItw98YAA8AAAAAA==.',['京都']='京都念瓷鹌:BAABLAAFFH8FAAIHAAMIVgwSdQB7AAAHAAMIVgwSdQB7AAAAAA==.',['人世']='人世:BAAALAAECgYIBgAAAA==.',['今天']='今天大雾:BAAALAADCggICAAAAA==.',['今日']='今日说法:BAAALAADCggIEAAAAA==.',['今晚']='今晚就爆炸:BAAALAAFFAIIBAAAAA==.今晚打老虎:BAAALAAECgQIBAAAAA==.',['以前']='以前以后:BAAALAAECgEIAQAAAA==.',['以撒']='以撒:BAACLAAFFH9RAAIQAAcIFyN6BgB6AgAQAAcIFyN6BgB6AgAsAAQKfzwAAhAACAgGJlwDAH0DABAACAgGJlwDAH0DAAAA.',['以礼']='以礼:BAABLAAFFH8GAAIQAAMIvQl5IwDVAAAQAAMIvQl5IwDVAAAAAA==.',['以言']='以言:BAACLAAFFH8yAAMOAAYIdiCgBgDNAQAOAAYIdiCgBgDNAQAPAAEIOAURIQA5AAAsAAQKfyYAAg4ACAh/H+cUAIQCAA4ACAh/H+cUAIQCAAEsAAUUCAgGAAIA8xcA.',['伊利']='伊利刐:BAABLAAFFH8HAAITAAMIXAeODwBRAAATAAMIXAeODwBRAAAAAA==.',['伊戈']='伊戈达拉:BAAALAAECgYICgAAAA==.',['伊星']='伊星:BAAALAAECgUIBQAAAA==.',['传奇']='传奇灬流牛:BAAALAADCgIIAgAAAA==.',['传说']='传说中的逗逗:BAAALAAFFAIIAgAAAA==.',['伤害']='伤害最低选手:BAAALAAFFAIIAgAAAA==.',['似水']='似水情如梦:BAAALAADCgYICgAAAA==.',['余之']='余之觞:BAABLAAFFH8hAAMJAAYIRhrdBwAkAQAKAAYIhhkmKABzAQAJAAUI4xLdBwAkAQAAAA==.',['你咬']='你咬我呀丶:BAAALAAECgQIBwAAAA==.',['你老']='你老婆:BAABLAAFFH8eAAIMAAYI2hSJIgBdAQAMAAYI2hSJIgBdAQAAAA==.',['俊哲']='俊哲:BAAALAAECgMIAwAAAA==.',['倾丶']='倾丶城:BAAALAAFFAIIAgAAAA==.',['元素']='元素回响:BAAALAAFFAIIAgAAAA==.',['光明']='光明术辻:BAABLAAECn8WAAIGAAYIohgwLQC8AQAGAAYIohgwLQC8AQAAAA==.光明母牛:BAAALAAECgUICAAAAA==.光明萨满:BAAALAAFFAIIAwAAAA==.',['再见']='再见丨姿势:BAAALAAECgYIBwAAAA==.',['再跩']='再跩就再见:BAAALAAECgYIEQAAAA==.',['冥王']='冥王星的魚:BAAALAAFFAIIAgAAAA==.冥王星的鱼:BAAALAAECgYIBwAAAA==.',['冯依']='冯依甜:BAABLAAFFH8OAAIBAAYIagkFDQAQAQABAAYIagkFDQAQAQAAAA==.',['冰枫']='冰枫:BAAALAAFFAIIAgAAAA==.',['冰河']='冰河晨星:BAABLAAFFH8GAAMBAAIIvg7VJwBvAAABAAIIvg7VJwBvAAACAAIIORMjZgBDAAAAAA==.',['冲锋']='冲锋牛:BAABLAAFFH8OAAIUAAIIhgOiOQAmAAAUAAIIhgOiOQAmAAAAAA==.',['冷死']='冷死谁:BAAALAAECgYIDAAAAA==.',['凋零']='凋零星尘:BAAALAAECggICAAAAA==.',['凡凡']='凡凡小可爱:BAACLAAFFH8PAAIVAAMIqgijEgBhAAAVAAMIqgijEgBhAAAsAAQKfxgAAhUABwhmFhAdACsBABUABwhmFhAdACsBAAAA.',['凶猛']='凶猛的大灰狼:BAAALAAECgYIDwAAAA==.',['刀锋']='刀锋血影:BAAALAAECgcIDwAAAA==.',['刘锤']='刘锤锤丶:BAAALAAECgYIBgAAAA==.',['刘闪']='刘闪闪:BAAALAAFFAIIAgABLAAFFAgIBQAKAMoSAA==.',['初乄']='初乄曉:BAAALAAECgYIBgAAAA==.',['初生']='初生的东汐:BAAALAAECgYIDQAAAA==.',['别削']='别削弱我:BAABLAAFFH8kAAMFAAYI0SHnDQD8AQAFAAYI0SHnDQD8AQAGAAEITySRIQBiAAAAAA==.',['别板']='别板:BAAALAAECgUICAAAAA==.',['剣灬']='剣灬来:BAAALAADCgEIAQAAAA==.',['加厼']='加厼鲁什:BAABLAAFFH8IAAIMAAIILQyNOwCSAAAMAAIILQyNOwCSAAAAAA==.',['加尔']='加尔丶鲁什:BAABLAAFFH8FAAIWAAMIgAibAwBtAAAWAAMIgAibAwBtAAAAAA==.',['加菲']='加菲猫想睡觉:BAAALAAECgYIDQAAAA==.',['劣人']='劣人丨吴晓迪:BAABLAAFFH8FAAIHAAIIJRFRowA+AAAHAAIIJRFRowA+AAAAAA==.',['劣灬']='劣灬劣人:BAAALAAECgQIBgAAAA==.',['十里']='十里烂桃花:BAAALAAFFAIIAgAAAA==.',['千年']='千年丨等待:BAAALAADCgEIAQAAAA==.',['千里']='千里单骑:BAAALAADCgcIBwAAAA==.',['半岛']='半岛晴空:BAAALAAFFAIIBAAAAA==.',['单车']='单车战神:BAABLAAFFH8fAAILAAUIUx+qMgB2AQALAAUIUx+qMgB2AQAAAA==.',['卖女']='卖女孩小薯条:BAAALAAECgYICQAAAA==.',['南风']='南风入弦:BAABLAAFFH8IAAIHAAYIEhuOJAClAQAHAAYIEhuOJAClAQAAAA==.南风陵:BAAALAAECgYIDAAAAA==.',['占戈']='占戈:BAAALAAECgIIAgAAAA==.',['卡卡']='卡卡丽熙:BAAALAAECgYIDwABLAAECgcIGAAKABkbAA==.',['厉害']='厉害吃货:BAACLAAFFH8LAAICAAUIfREXGQD5AAACAAUIfREXGQD5AAAsAAQKfx8AAgIACAhbHHldADECAAIACAhbHHldADECAAAA.',['双手']='双手画圈圈:BAAALAAECgYICgAAAA==.',['叔叔']='叔叔怪:BAAALAADCgEIAQAAAA==.',['变个']='变个树人:BAABLAAFFH8aAAMSAAUIZxJ2HwArAQASAAUIZxJ2HwArAQARAAUI/AflHwDIAAAAAA==.',['变节']='变节:BAABLAAECn8eAAQFAAYIoBh/SgAlAQAFAAUI9Rd/SgAlAQAGAAQIdw3kZQDgAAAXAAMIRBQbJQC/AAABLAAECgYIGAAEAGEaAA==.',['古云']='古云:BAACLAAFFH8NAAIVAAMIkgntEwBYAAAVAAMIkgntEwBYAAAsAAQKfxUAAxUABghLDwxMAP4AABUABQiqEQxMAP4AAAIABgioBMUvAdIAAAAA.',['古尔']='古尔圆:BAAALAAECgcIBwAAAA==.',['叨哥']='叨哥:BAAALAADCgMIAwAAAA==.',['叩指']='叩指断长生:BAAALAAECgYIDAAAAA==.',['可口']='可口:BAAALAAECgcIEAAAAA==.',['可可']='可可:BAAALAAFFAIIAgAAAA==.',['可爱']='可爱圆吨吨:BAABLAAFFH8KAAIYAAIITxdpPQCGAAAYAAIITxdpPQCGAAAAAA==.',['可狠']='可狠:BAAALAAECgEIAQAAAA==.',['吃小']='吃小虾:BAAALAAECgYIDgAAAA==.',['吉祥']='吉祥丶如意:BAAALAAECgEIAQAAAA==.',['后面']='后面那小德:BAAALAAECgYIDwAAAA==.',['听说']='听说猎爹强:BAAALAADCgYIBgAAAA==.',['吾善']='吾善撩人:BAABLAAECn8WAAMGAAcIsBkoHwAIAgAGAAYIZx0oHwAIAgAFAAcIxQnTlwBNAQAAAA==.',['吾色']='吾色:BAAALAAFFAIIAgAAAA==.',['告別']='告別時刻:BAAALAAECgMIAwAAAA==.',['咆哮']='咆哮肉夹馍:BAAALAAECgYIBgAAAA==.',['和你']='和你躲猫猫:BAAALAAECggIBgAAAA==.',['咕咕']='咕咕品:BAAALAAECgYIBgAAAA==.咕咕小猪:BAAALAAECgYICwAAAA==.',['哀木']='哀木哀木:BAAALAAECgYIBgAAAA==.',['哇哦']='哇哦:BAAALAADCggICAAAAA==.',['哈哈']='哈哈哥:BAAALAAECgYIBwAAAA==.',['哈士']='哈士骑:BAAALAAFFAIIAgAAAA==.',['哈里']='哈里波特:BAAALAAFFAIIBAAAAA==.',['哒哒']='哒哒嗒:BAAALAAECgYIEQAAAA==.',['哥一']='哥一直很寂寞:BAAALAAECgQIBAAAAA==.哥一直很潇洒:BAAALAAECgYIEgAAAA==.哥一直很纯洁:BAAALAAECgUIBQAAAA==.哥一直很霸气:BAAALAAECgYIBgAAAA==.',['哥就']='哥就是李刚:BAACLAAFFH8aAAMCAAUIZg90LwATAQACAAQIEgx0LwATAQABAAMIAhTlHQC5AAAsAAQKfyUAAwIACAh3GS15APgBAAIABwj4GS15APgBAAEACAjVEsEpANQBAAAA.',['唏娅']='唏娅:BAABLAAFFH8FAAICAAUIKQY+NQDhAAACAAUIKQY+NQDhAAAAAA==.',['唔知']='唔知叫咩名:BAAALAAFFAIIAgAAAA==.',['嘛呢']='嘛呢叭咪嗨:BAAALAADCggICAAAAA==.',['嘿哟']='嘿哟黑丶:BAAALAAECgEIAQAAAA==.',['国民']='国民表率:BAAALAAECgYIDgAAAA==.',['囿毐']='囿毐啲拉菲尔:BAABLAAFFH8dAAIGAAYI0iDnAADuAQAGAAYI0iDnAADuAQAAAA==.',['圣光']='圣光永不熄灭:BAAALAADCgYICAAAAA==.圣光的名义:BAAALAAECgEIAQAAAA==.',['圣翼']='圣翼丶风暴:BAACLAAFFH8fAAICAAYIFyH9DQDYAQACAAYIFyH9DQDYAQAsAAQKfysAAgIACAhyJJIfAPQCAAIACAhyJJIfAPQCAAAA.',['圣闪']='圣闪:BAAALAAECgIIAgAAAA==.',['在下']='在下车不圆:BAAALAAECgQIBgAAAA==.',['地狱']='地狱终结者:BAAALAAFFAIIAgAAAA==.',['埋尸']='埋尸人:BAAALAAECgYIDgAAAA==.',['堕天']='堕天使之泪:BAABLAAFFH8KAAMZAAYIShEPIgA6AQAZAAUIRRQPIgA6AQAaAAEIwALFLwA3AAAAAA==.',['墙角']='墙角丨买瓜皮:BAAALAAFFAIIAgAAAA==.',['夏天']='夏天在飘雪:BAAALAAECgIIAgAAAA==.夏天小雪:BAAALAAFFAIIBAAAAA==.夏天猎:BAAALAAECgIIAgAAAA==.',['夏小']='夏小埋丶:BAABLAAECn8WAAMQAAgI9hfhTwAyAgAQAAgI9hfhTwAyAgATAAEIDQCmcwABAAAAAA==.',['大哥']='大哥谋:BAAALAAECgYIBgAAAA==.',['大奥']='大奥奔奔:BAABLAAFFH8LAAMZAAUIDQqQJQAVAQAZAAUIwgiQJQAVAQAbAAIItAzZBQBdAAAAAA==.',['大曾']='大曾加:BAAALAAFFAIIBAAAAA==.',['大棍']='大棍棍:BAAALAAECgYIDgAAAA==.',['大石']='大石仔:BAAALAAFFAIIBAAAAA==.',['大细']='大细腿:BAABLAAFFH8GAAIKAAYIwQDwagArAAAKAAYIwQDwagArAAAAAA==.',['夨寵']='夨寵:BAAALAAECgYIBgAAAA==.',['天殇']='天殇牛:BAAALAADCgYIBgAAAA==.',['天蓬']='天蓬戏丨娥:BAAALAAECgYIBgAAAA==.',['天道']='天道飘渺:BAAALAAFFAIIAgAAAA==.',['天降']='天降正义丶:BAABLAAFFH8HAAIQAAIIcxshTABOAAAQAAIIcxshTABOAAAAAA==.',['太雷']='太雷回来了:BAAALAAECgYICwAAAA==.',['奈玖']='奈玖:BAAALAAECgYICQAAAA==.',['奔四']='奔四的梦想:BAAALAADCgYIBgAAAA==.',['奔跑']='奔跑的水牛:BAAALAAECgMIAwAAAA==.',['女乃']='女乃:BAAALAAECggIEAAAAA==.女乃米唐:BAAALAADCggICAAAAA==.',['奶油']='奶油小布丁:BAAALAAECgEIAQAAAA==.',['好傻']='好傻好天真:BAAALAAECgYIBgAAAA==.',['好吃']='好吃不如饺子:BAAALAAECgYICgAAAA==.',['如嫣']='如嫣丶幻雪:BAAALAAECggIEAAAAA==.',['如果']='如果打小黑:BAAALAAECggICQAAAA==.',['妖小']='妖小药:BAAALAAECgQIBAAAAA==.',['妖気']='妖気丸丶:BAACLAAFFH8IAAIFAAII9hTJYAA/AAAFAAII9hTJYAA/AAAsAAQKfxsAAwYACAi4HrwUAFMCAAYACAhJHbwUAFMCAAUACAg+Gg0WADECAAAA.',['姆叉']='姆叉鸡:BAAALAADCgIIAgAAAA==.',['安娜']='安娜伊芙琳:BAAALAAFFAIIAgAAAA==.',['射射']='射射的夜叉:BAAALAAECgYIBwAAAA==.',['小医']='小医仙:BAAALAAECgEIAQAAAA==.',['小吉']='小吉娃:BAAALAAECgUIBQAAAA==.',['小女']='小女不财:BAAALAAECgEIAQAAAA==.',['小姜']='小姜能司机:BAAALAAECgYIDAABLAAFFAQIFwAFAC0aAA==.',['小恩']='小恩家的小术:BAAALAAECggICAAAAA==.',['小时']='小时了了:BAAALAAECgMIAwAAAA==.',['小胖']='小胖丫:BAAALAAFFAIIAgAAAA==.',['小钢']='小钢炮儿:BAABLAAFFH8LAAIHAAQIdRBVKwDTAAAHAAQIdRBVKwDTAAAAAA==.',['小霸']='小霸王乐吴琼:BAACLAAFFH8FAAIYAAMIMhGsRACaAAAYAAMIMhGsRACaAAAsAAQKfxwAAxgACAgHFhuQAF4BABgACAgHFhuQAF4BABwABAibBj2vAJ0AAAAA.',['尐卩']='尐卩:BAAALAAECgUIBwAAAA==.',['就是']='就是如此:BAAALAADCgIIAgAAAA==.',['岁月']='岁月如哥:BAAALAAECgQIBAAAAA==.',['崩蹦']='崩蹦嘣:BAAALAAECggIBgAAAA==.',['左手']='左手莫及:BAACLAAFFH8hAAIQAAUIySDoDADYAQAQAAUIySDoDADYAQAsAAQKfycAAhAABwhNJdQ6AHQCABAABwhNJdQ6AHQCAAAA.',['巨牙']='巨牙小明:BAAALAAECgYIDwAAAA==.',['巨狼']='巨狼强森:BAAALAAECgUIBQAAAA==.',['巨磨']='巨磨人:BAAALAADCgEIAQAAAA==.',['巴啦']='巴啦啦小魔仙:BAAALAAECgMIAwAAAA==.',['巴山']='巴山:BAAALAAECgYIDAAAAA==.',['巴巴']='巴巴托斯:BAABLAAECn8iAAILAAgIZSGQDACQAgALAAgIZSGQDACQAgAAAA==.',['布伦']='布伦希尔德:BAAALAAECgYIBgAAAA==.',['布拉']='布拉德刘能:BAAALAADCggICAAAAA==.',['布烙']='布烙克斯:BAAALAAECgYICgAAAA==.',['帅的']='帅的惊动瓽:BAAALAAECgYIBgAAAA==.',['希尔']='希尔丶瓦那师:BAAALAAFFAIIAgAAAA==.希尔瓦娜簛:BAABLAAFFH8HAAIHAAMIxwzGegBrAAAHAAMIxwzGegBrAAAAAA==.',['幻晨']='幻晨:BAABLAAECn8UAAMIAAgIAB2QIQBcAgAIAAgI9BqQIQBcAgAHAAQITBrA+QA2AQAAAA==.',['幻月']='幻月影:BAAALAAECgEIAQAAAA==.',['幻术']='幻术使者:BAAALAAECgYICQAAAA==.',['开局']='开局别点连击:BAAALAAFFAIIAgAAAA==.',['弑魔']='弑魔诛神:BAAALAAECgYIDAAAAA==.',['弓射']='弓射南山虎:BAAALAAECgYIDQAAAA==.',['弗洛']='弗洛一德:BAAALAAFFAIIAgAAAA==.',['张生']='张生:BAAALAAECgMIBQAAAA==.',['弹勿']='弹勿虚发:BAACLAAFFH8HAAIHAAMIDRJofABnAAAHAAMIDRJofABnAAAsAAQKfxcAAwcABgjkI/szAPIBAAcABgjkI/szAPIBAAgABAg9D3aHAMMAAAAA.',['强尼']='强尼二十:BAAALAAFFAIIAgAAAA==.强尼十二:BAAALAAECgYIBgAAAA==.',['归隐']='归隐山林去:BAAALAAECgMIAwAAAA==.',['彩云']='彩云之南:BAAALAAECgYICgAAAA==.',['影心']='影心:BAAALAAECgYICwAAAA==.',['往事']='往事如风去:BAAALAAECgYICAAAAA==.',['御天']='御天敌:BAAALAADCgIIAgAAAA==.',['微震']='微震天:BAAALAAECgQIBAAAAA==.',['心月']='心月狐:BAAALAADCggICAAAAA==.',['忧郁']='忧郁滴板儿砖:BAABLAAFFH8NAAICAAYIvR16FACsAQACAAYIvR16FACsAQAAAA==.忧郁滴犄角:BAAALAAFFAIIBAAAAA==.',['快枪']='快枪石青山:BAABLAAFFH8KAAIPAAMISRHaEQCYAAAPAAMISRHaEQCYAAAAAA==.',['怀旧']='怀旧骚年:BAAALAAFFAIIBAAAAA==.',['怎么']='怎么又饿了:BAAALAAECgQIBwAAAA==.',['怎麽']='怎麽又餓了:BAAALAAECgMIAwAAAA==.',['总之']='总之就是很强:BAACLAAFFH8bAAICAAYIKB6cDwDNAQACAAYIKB6cDwDNAQAsAAQKfyoAAgIABwiVIzUhABgCAAIABwiVIzUhABgCAAAA.',['恩賜']='恩賜灬解脫:BAABLAAFFH8JAAMSAAIIWxwJJACXAAASAAIIWxwJJACXAAARAAEIwQFTMAAxAAAAAA==.',['恶意']='恶意:BAAALAAECgcIBwAAAA==.',['恶鬼']='恶鬼辣椒:BAAALAAFFAIIBAAAAA==.',['恶魔']='恶魔伊星:BAAALAAFFAIIAgAAAA==.',['愤怒']='愤怒的小苹果:BAAALAAECgQIBAAAAA==.愤怒的野火:BAABLAAFFH8MAAIMAAYI5gjwJABMAQAMAAYI5gjwJABMAQAAAA==.',['懒羊']='懒羊羊喜洋洋:BAAALAADCgIIAgAAAA==.',['戈薇']='戈薇丶:BAAALAAECgYIBgAAAA==.',['我也']='我也想奶:BAAALAADCggIDgAAAA==.',['我帅']='我帅故我拽:BAAALAAECgYIBgAAAA==.',['我心']='我心依镹:BAAALAAECggICAAAAA==.',['我是']='我是寒江啊:BAAALAAECgYIBgAAAA==.',['我的']='我的卡:BAAALAAECgYIBgAAAA==.我的确萌新:BAABLAAECn8YAAMKAAcIGRuvbQDAAQAKAAcIUBivbQDAAQAdAAQIBR14EAARAQAAAA==.',['战破']='战破羽翼:BAAALAAFFAIIAgAAAA==.',['手下']='手下不留情:BAABLAAFFH8GAAICAAYIMBabFgCgAQACAAYIMBabFgCgAQAAAA==.',['打不']='打不过加入:BAABLAAFFH8OAAIYAAUIfwpBMwDgAAAYAAUIfwpBMwDgAAAAAA==.',['扯呼']='扯呼风紧:BAABLAAFFH8KAAIHAAIIzBKxkwBEAAAHAAIIzBKxkwBEAAAAAA==.',['拉面']='拉面狐狸:BAAALAAECggIBQAAAA==.',['拿什']='拿什么挽留你:BAAALAAECgYIBgAAAA==.',['振翅']='振翅屈心:BAAALAAECgYIBgAAAA==.',['捌捌']='捌捌陆拾肆:BAAALAADCgIIAgAAAA==.',['掌心']='掌心:BAAALAAFFAIIAgAAAA==.',['提里']='提里奥丶神秘:BAAALAAECgQICAAAAA==.',['搞姐']='搞姐:BAAALAAECgYIBgAAAA==.',['摆酷']='摆酷撞到树:BAAALAAECgQIBAAAAA==.',['撒嗯']='撒嗯的撒:BAAALAADCgEIAQAAAA==.',['撒贝']='撒贝宁:BAAALAADCgEIAQAAAA==.',['攻击']='攻击二杠三:BAACLAAFFH8gAAILAAYI9xaEJQCjAQALAAYI9xaEJQCjAQAsAAQKfxcAAgsABgiKGQlWAEgBAAsABgiKGQlWAEgBAAAA.',['斑斑']='斑斑驳驳:BAAALAAECgQIBAAAAA==.',['无上']='无上天心:BAAALAAECgQIBAAAAA==.',['无尽']='无尽丶后天:BAAALAAECgEIAQAAAA==.无尽的冰霜:BAABLAAFFH8IAAIeAAIIXRyQCgDBAAAeAAIIXRyQCgDBAAAAAA==.无尽的誓言:BAAALAAFFAIIAgAAAA==.',['无心']='无心看风景:BAAALAAECgEIAQAAAA==.',['无敌']='无敌最俊美:BAABLAAFFH8SAAILAAUIYRZ3KQDzAAALAAUIYRZ3KQDzAAAAAA==.',['日向']='日向真凛丶:BAABLAAFFH8lAAMHAAYIUxrQHgAQAQAHAAYIUxrQHgAQAQAIAAII/wQYLwBlAAAAAA==.',['早安']='早安:BAAALAAFFAIIBAAAAA==.',['明天']='明天不上班:BAABLAAFFH8GAAIHAAYIdAT6egBrAAAHAAYIdAT6egBrAAAAAA==.',['明月']='明月之心:BAACLAAFFH8RAAIJAAII5h4NDQCdAAAJAAII5h4NDQCdAAAsAAQKfyQAAgkABwh8IAUeACsCAAkABwh8IAUeACsCAAAA.明月倚高楼:BAAALAAECgYIBgAAAA==.',['星之']='星之辉:BAAALAAECggICAAAAA==.',['星尘']='星尘之絮:BAAALAAFFAIIAgAAAA==.',['星辰']='星辰风暴:BAAALAAECgYIDAAAAA==.',['星际']='星际火狐:BAABLAAFFH8IAAIYAAIIdBkAPwCDAAAYAAIIdBkAPwCDAAAAAA==.',['晚上']='晚上鸟没事:BAAALAADCggIEAAAAA==.',['晴天']='晴天柱:BAAALAAECgYIBgAAAA==.',['暗影']='暗影蔷薇:BAACLAAFFH8tAAIZAAUIThyIFwCaAQAZAAUIThyIFwCaAQAsAAQKfzEAAxoABwiHG1owAAkCABoABghWHlowAAkCABkABwhbGJRFAMABAAAA.',['暗魔']='暗魔影:BAAALAAECgYIEQAAAA==.',['暗黑']='暗黑狂牛:BAAALAAECgYIBgAAAA==.',['曜青']='曜青丨飞霄:BAAALAAECgYIDgAAAA==.',['曰邢']='曰邢一珊:BAAALAAECgIIAwAAAA==.',['最爱']='最爱回锅肉:BAABLAAFFH8JAAMEAAYIsQ6dDwASAQAEAAUISgydDwASAQADAAIIDRbxEACXAAAAAA==.',['最牛']='最牛的冰法:BAAALAAFFAIIBAAAAA==.',['月下']='月下酒:BAAALAAFFAIIAgAAAA==.',['月小']='月小夜丶:BAACLAAFFH8hAAIHAAcIxB8/DAAuAgAHAAcIxB8/DAAuAgAsAAQKfxcAAgcABggwJPUwAPsBAAcABggwJPUwAPsBAAAA.',['月琰']='月琰:BAAALAADCgMIAwAAAA==.',['有德']='有德定有尸:BAABLAAFFH8GAAISAAIIIQ0POQBnAAASAAIIIQ0POQBnAAAAAA==.',['有钱']='有钱哥:BAAALAAECgMIAwAAAA==.',['朕灬']='朕灬天下:BAAALAAECgEIAQAAAA==.',['术大']='术大招风:BAACLAAFFH8eAAMFAAYILgy9MgBPAQAFAAYI8Qq9MgBPAQAGAAEIWRM5HwAAAAAsAAQKfyUAAwUACAhIHJ80AGgCAAUACAg/G580AGgCAAYABwj2FXIlAOMBAAAA.',['朱先']='朱先森贼拉风:BAABLAAFFH8SAAMfAAUIRg5XAgAlAQAfAAUIkw1XAgAlAQAEAAEIcxfJHwBZAAAAAA==.',['朱文']='朱文俊:BAAALAAECggICwAAAA==.',['朽木']='朽木:BAAALAAECgYIBgAAAA==.',['杉木']='杉木松:BAAALAAECgQIAQAAAA==.',['李敏']='李敏皓:BAAALAAFFAIIAgAAAA==.',['杜丶']='杜丶一一:BAAALAAFFAIIAgAAAA==.',['杰克']='杰克达斯维达:BAABLAAFFH8GAAIKAAYIkRV+CwAOAgAKAAYIkRV+CwAOAgAAAA==.',['极光']='极光掠夺天边:BAAALAADCgYIBgAAAA==.',['极夜']='极夜之牧:BAAALAAECgYICgAAAA==.',['柔情']='柔情似水:BAAALAADCgQIBAAAAA==.',['柠檬']='柠檬味的柑橘:BAACLAAFFH8IAAMRAAIIjxDDLgBGAAARAAIIjxDDLgBGAAAgAAEICwaZEwBFAAAsAAQKfx0AAxEACAg5HBQOACACABEACAjZGxQOACACACAAAQiWGBZHAEwAAAAA.柠檬味的青柠:BAAALAAFFAIIAgAAAA==.',['桃桃']='桃桃:BAAALAAECgQIBAAAAA==.',['桃白']='桃白白丶:BAAALAAFFAIIAgAAAA==.',['梦落']='梦落灰尘:BAAALAAECgYIDAABLAAECgYIGAAEAGEaAA==.梦落红尘:BAABLAAECn8YAAMEAAYIYRp9LADCAQAEAAYIAxp9LADCAQADAAMIgxWBOwC+AAAAAA==.',['梨膏']='梨膏糖:BAABLAAFFH8RAAIhAAYI+QdTDAA4AQAhAAYI+QdTDAA4AQAAAA==.',['橋本']='橋本環奈:BAABLAAECn8oAAICAAgIkyE8HQD+AgACAAgIkyE8HQD+AgAAAA==.',['橙心']='橙心橙意求橙:BAACLAAFFH8HAAMfAAMIvBN0AgDhAAAfAAMI8w90AgDhAAAEAAEIaiSMHgBlAAAsAAQKfy4AAx8ACAgrIqYCAO4CAB8ACAiXIaYCAO4CAAQACAhOHIERAJUCAAAA.',['橙色']='橙色加血小人:BAACLAAFFH89AAMRAAYIPB21CACtAQARAAUIFiK1CACtAQASAAUIwBDIFQDNAAAsAAQKfx8AAxEACAjHH/8PAOwCABEACAjHH/8PAOwCABIAAwhVH6mHAAwBAAAA.',['橙黄']='橙黄橘绿:BAAALAAFFAQIAwAAAA==.',['欢哥']='欢哥超牛:BAAALAAFFAIIBAAAAA==.',['欲由']='欲由忄生:BAAALAADCgEIAQAAAA==.',['死亡']='死亡兽兽:BAAALAAFFAYIAwAAAA==.',['死神']='死神饕餮:BAAALAAFFAIIBAABLAAFFAMIDAAYAP4TAA==.死神饕餮德:BAABLAAFFH8GAAISAAII3RqWOwCDAAASAAII3RqWOwCDAAABLAAFFAMIDAAYAP4TAA==.死神饕餮智:BAACLAAFFH8IAAILAAIIOxcngQBGAAALAAIIOxcngQBGAAAsAAQKfx8AAgsACAj2HoAXAC8CAAsACAj2HoAXAC8CAAAA.',['残枝']='残枝败叶丶:BAAALAAECgYIBgAAAA==.',['毁灭']='毁灭者丶怒风:BAAALAAECgYIBgAAAA==.',['毅力']='毅力帝艾斯:BAABLAAFFH8FAAIQAAII+gdPbAAyAAAQAAII+gdPbAAyAAAAAA==.',['每天']='每天射一射:BAAALAAECgUIBQAAAA==.',['毒蝇']='毒蝇伞:BAAALAADCgMIAwAAAA==.',['比鲁']='比鲁斯:BAAALAAECgIIAwAAAA==.',['水那']='水那么少:BAAALAADCgcICgAAAA==.',['汐顔']='汐顔:BAACLAAFFH8oAAIJAAYIYhqWAgCGAQAJAAYIYhqWAgCGAQAsAAQKfyIAAgkACAiYISMJAAUDAAkACAiYISMJAAUDAAAA.',['汤猪']='汤猪:BAABLAAECn8YAAILAAgIcR7jLAC/AgALAAgIcR7jLAC/AgAAAA==.',['沃德']='沃德起:BAAALAADCgMIAwAAAA==.',['没熊']='没熊就缺德:BAAALAADCgYIBgAAAA==.',['波妞']='波妞不咬人丶:BAACLAAFFH8RAAMZAAYIlgzjHQBkAQAZAAYIlgzjHQBkAQAaAAII0ghmHQCWAAAsAAQKfyAAAhkACAhJJeQFAEADABkACAhJJeQFAEADAAAA.波妞出去玩:BAAALAAECggICgABLAAFFAYIHgAiABQXAA==.',['波比']='波比锤子大:BAABLAAFFH8IAAMVAAYIHwjMDQCrAAAVAAMIxwnMDQCrAAACAAMIdwajTgBhAAAAAA==.',['泽郎']='泽郎:BAAALAAECgUIBwAAAA==.',['洢利']='洢利玬怒疯:BAAALAAECgQIBAAAAA==.',['浅丶']='浅丶小狐:BAABLAAFFH8KAAIYAAII+wdwbABQAAAYAAII+wdwbABQAAAAAA==.',['浅夏']='浅夏未央:BAABLAAFFH8IAAIZAAgI5QvoDQD6AQAZAAgI5QvoDQD6AQAAAA==.',['浓香']='浓香怪咖啡:BAAALAAFFAIIAgAAAA==.',['浮槎']='浮槎廿二:BAAALAADCgIIAgAAAA==.',['海鸥']='海鸥:BAAALAAECggICQAAAA==.',['消逝']='消逝的空:BAABLAAFFH8IAAIMAAIIOBT2OgCTAAAMAAIIOBT2OgCTAAAAAA==.',['淡蛋']='淡蛋蛋淡:BAAALAAECgEIAQAAAA==.',['淮海']='淮海路小佩奇:BAAALAAECggICAAAAA==.',['深籽']='深籽:BAABLAAFFH8IAAMHAAIIYgoibACCAAAHAAIIYgoibACCAAAIAAEI/AEgOgAtAAAAAA==.',['清霜']='清霜:BAAALAAECgQIBwAAAA==.',['温言']='温言如玉:BAAALAAECgMIAwAAAA==.',['游侠']='游侠中:BAAALAAECgEIAQAAAA==.',['湮丶']='湮丶羽轩:BAAALAAECgYIBgAAAA==.',['滴尅']='滴尅诶:BAACLAAFFH8OAAILAAMItROsLgDgAAALAAMItROsLgDgAAAsAAQKfzgAAgsACAgbIpwbAAEDAAsACAgbIpwbAAEDAAAA.',['滿是']='滿是優傷:BAABLAAFFH8nAAILAAcImhxyDwAZAgALAAcImhxyDwAZAgAAAA==.滿是纏綿:BAABLAAFFH8YAAICAAUIJhbeKgAwAQACAAUIJhbeKgAwAQABLAAFFAcIJwALAJocAA==.',['激活']='激活:BAABLAAFFH8GAAISAAYIQg+fGgBbAQASAAYIQg+fGgBbAQAAAA==.',['火鸡']='火鸡味锅巴:BAAALAAECgEIAQAAAA==.',['灬墨']='灬墨寒灬:BAAALAADCgIIAgAAAA==.',['灬曜']='灬曜晨灬:BAAALAAECgYICAAAAA==.',['灬豆']='灬豆豆灬:BAABLAAFFH8IAAIDAAII2gqAFQCFAAADAAII2gqAFQCFAAAAAA==.',['灰烬']='灰烬挽歌:BAAALAAECgMIAwAAAA==.',['灵魂']='灵魂猎:BAAALAADCgcIBwAAAA==.',['点燃']='点燃星海丶:BAAALAAECggIBgAAAA==.',['為愛']='為愛停留丶霜:BAAALAADCgEIAQAAAA==.',['焕晨']='焕晨:BAAALAAECggIDAAAAA==.',['無用']='無用聖光:BAAALAAFFAIIBAAAAA==.',['熊也']='熊也有抱负:BAAALAAECgYIBgAAAA==.',['熊猫']='熊猫老板:BAAALAADCgQIBAAAAA==.',['熬过']='熬过每个夜:BAAALAAFFAIIAgAAAA==.',['爆裂']='爆裂星星:BAAALAAECggICAAAAA==.',['牛场']='牛场娃:BAAALAAECgIIAgAAAA==.',['牛玄']='牛玄德:BAAALAAECggIEQAAAA==.',['牛顿']='牛顿莱布尼茨:BAAALAADCgUIBQAAAA==.',['牧虚']='牧虚:BAABLAAFFH8JAAIcAAIIWAZ2UQAzAAAcAAIIWAZ2UQAzAAAAAA==.',['狂暴']='狂暴于心:BAAALAAECgUIBQAAAA==.',['狂浪']='狂浪:BAAALAAECgQIBAAAAA==.',['狂牛']='狂牛滴小茻师:BAAALAAECgYIEQAAAA==.',['狂疯']='狂疯浪嗲:BAAALAAFFAIIAgAAAA==.',['狠潇']='狠潇洒:BAAALAADCgEIAQAAAA==.',['狱蝴']='狱蝴蝶:BAAALAAECgYIBgAAAA==.',['猎手']='猎手壹壹:BAAALAADCggICAAAAA==.',['猪刚']='猪刚烈:BAAALAADCgMIAwAAAA==.',['猪肉']='猪肉炖豆腐:BAAALAAECgIIAgAAAA==.猪肉炖豆角:BAAALAADCgMIAwAAAA==.猪肉闷豆腐:BAAALAAECgYIBgAAAA==.',['猫狗']='猫狗双全:BAABLAAFFH8GAAMHAAII+gz5YwCJAAAHAAII+gz5YwCJAAAIAAIIqwPuLwBhAAAAAA==.',['猫骑']='猫骑士:BAAALAAFFAIIAgAAAA==.',['王元']='王元宝:BAAALAAECgYIDQAAAA==.',['王导']='王导:BAAALAAECggICAAAAA==.',['玖丶']='玖丶号:BAAALAAECgQIBAAAAA==.',['玩玩']='玩玩而已丶:BAAALAAECgEIAQAAAA==.',['理理']='理理哈基米:BAAALAADCgQIBAAAAA==.',['琳琅']='琳琅之舞:BAAALAAECgYIBgAAAA==.琳琅毓:BAABLAAFFH8GAAILAAIIDgrSkgA+AAALAAIIDgrSkgA+AAAAAA==.琳琅舞:BAAALAAFFAIIBAAAAA==.',['瑰拉']='瑰拉:BAAALAAECgYIDwAAAA==.',['璐灬']='璐灬璐:BAAALAADCggICAAAAA==.',['璐璐']='璐璐女王:BAAALAAFFAIIBAAAAA==.',['瓦里']='瓦里安之子:BAAALAAECgYIBgAAAA==.',['生椰']='生椰拿铁:BAABLAAFFH8GAAIHAAYIIBPeQgBDAQAHAAYIIBPeQgBDAQAAAA==.',['男寵']='男寵的萌女王:BAAALAAFFAIIAgAAAA==.',['男模']='男模爱吃兔兔:BAAALAAFFAIIAgAAAA==.',['疯小']='疯小墨:BAABLAAFFH8GAAQVAAIIVA4wHgAvAAACAAIIigsEVgCMAAABAAIIFAphIQCEAAAVAAIIjgwwHgAvAAAAAA==.',['疯爆']='疯爆斩人:BAAALAAECgMIBAAAAA==.',['疯狂']='疯狂地面具:BAAALAAECgYIBgAAAA==.疯狂小湎包:BAAALAAECgcICAAAAA==.疯狂老炮:BAAALAAECgYIEgAAAA==.',['發電']='發電機:BAACLAAFFH8fAAIcAAYIlxjXEwChAQAcAAYIlxjXEwChAQAsAAQKfxYAAhwABggzHmU8ABQCABwABggzHmU8ABQCAAAA.',['白夜']='白夜圈圈:BAABLAAFFH8IAAICAAII8hdoMwCoAAACAAII8hdoMwCoAAABLAAFFAgIBgAMAJYbAA==.',['盲人']='盲人推拿师:BAABLAAFFH8QAAIQAAMIkBxFLQCvAAAQAAMIkBxFLQCvAAAAAA==.',['盾瞬']='盾瞬六花:BAAALAAECgYIBgAAAA==.',['看海']='看海的狐狸:BAAALAAECgcICAAAAA==.',['真爱']='真爱之骑:BAABLAAECn8YAAMLAAYI0xG03gBwAQALAAYIrBG03gBwAQAjAAYI/QvULwD/AAAAAA==.',['真豆']='真豆:BAAALAAECggICAAAAA==.',['瞎湖']='瞎湖闹:BAAALAAFFAIIBAAAAA==.',['瞎猫']='瞎猫丶:BAACLAAFFH8oAAQFAAgIFRUgFwDVAQAFAAcIQBUgFwDVAQAXAAIIsw/7BQBfAAAGAAEItBTGJgBSAAAsAAQKf0IABAUACAhNJHUcAOACAAUACAh8I3UcAOACABcABggAFPATAHwBAAYABAi1HQ5fAPsAAAAA.',['研究']='研究昆字诀:BAAALAAECgQIBQAAAA==.',['碉堡']='碉堡同学:BAAALAAFFAIIAgAAAA==.',['磨你']='磨你:BAAALAAECgUIBQAAAA==.',['神选']='神选者乔扎布:BAAALAADCgMIAwAAAA==.',['秋天']='秋天:BAAALAAECgMIAwAAAA==.秋天的燕子:BAAALAAECgIIAgAAAA==.',['种花']='种花仔仔:BAAALAAECgEIAQAAAA==.',['程慢']='程慢:BAABLAAFFH8GAAILAAIIXwn9iQB/AAALAAIIXwn9iQB/AAAAAA==.',['程潇']='程潇:BAAALAAECgYICAAAAA==.',['空白']='空白的墓志铭:BAAALAADCggICAAAAA==.',['立立']='立立的小德德:BAAALAAECgIIAgAAAA==.',['管我']='管我叫什么:BAAALAAECgYIBgAAAA==.',['篮球']='篮球练习生:BAAALAAECgIIAgAAAA==.',['糖糖']='糖糖:BAAALAAECgYIBgAAAA==.',['素年']='素年瑾时:BAAALAAECggICAAAAA==.',['素质']='素质流氓法哥:BAAALAAECgcIBwAAAA==.',['紫色']='紫色豹子:BAAALAADCgQIBAAAAA==.',['縂統']='縂統先生:BAAALAAECgYIBgAAAA==.',['红发']='红发娇娇:BAAALAAECgYIBgAAAA==.',['红红']='红红巨兽丶:BAAALAAFFAIIAgAAAA==.',['纷乱']='纷乱天下:BAAALAAECgcICwAAAA==.',['给你']='给你打针:BAAALAADCgIIAgAAAA==.',['给我']='给我翻过来:BAAALAAFFAIIAgAAAA==.',['绝对']='绝对不死王者:BAAALAAECgYIBgAAAA==.绝对奶死王者:BAABLAAECn8XAAIcAAYIxheKLgBdAQAcAAYIxheKLgBdAQAAAA==.',['绝望']='绝望死亡:BAAALAAECgYIBgAAAA==.',['绣冬']='绣冬:BAAALAAECgYIBwAAAA==.',['绽放']='绽放:BAABLAAFFH8TAAISAAgInBYcBgBSAgASAAgInBYcBgBSAgAAAA==.',['罗丶']='罗丶霜冻温酒:BAAALAADCgIIAgAAAA==.',['羊羔']='羊羔把:BAAALAAFFAgIAQAAAA==.',['美队']='美队飞盾:BAAALAAFFAIIBAAAAA==.',['群星']='群星丨三月:BAABLAAFFH8IAAIKAAII7wqOXABAAAAKAAII7wqOXABAAAAAAA==.群星丨卡芙卡:BAAALAAECgYICwAAAA==.群星丨黑塔:BAABLAAFFH8IAAMHAAII2hVJTACYAAAHAAII2hVJTACYAAAIAAIISgnCKgByAAAAAA==.',['老傣']='老傣族竹筒饭:BAAALAAECgYIBgAAAA==.',['老劉']='老劉忙:BAAALAAECgYIDAAAAA==.老劉氓:BAAALAAFFAIIAgAAAA==.老劉盲:BAAALAAFFAIIBAAAAA==.老劉莽:BAAALAAFFAIIAgAAAA==.老劉釯:BAAALAAECgYIBgAAAA==.',['肉球']='肉球:BAABLAAFFH8aAAMPAAUISSDaCADZAQAPAAUISSDaCADZAQAOAAEI4QG3JwAAAAAAAA==.',['脂鳯']='脂鳯色的刀花:BAABLAAFFH8MAAICAAYIkhCKIgBfAQACAAYIkhCKIgBfAQAAAA==.',['脆皮']='脆皮小猪骑:BAACLAAFFH8gAAMjAAUI9xlBDgAmAQAjAAUItRdBDgAmAQALAAMInBrWRwCoAAAsAAQKfx8AAwsACAj/H7IwALACAAsACAiiHrIwALACACMACAhyGDIaAMgBAAAA.',['脉动']='脉动还不错:BAAALAAFFAIIAgAAAA==.',['與亊']='與亊無爭:BAABLAAECn8aAAICAAgIShMvOQC0AQACAAgIShMvOQC0AQAAAA==.',['艾沐']='艾沐涕丶噫誌:BAAALAAFFAQIBAAAAA==.',['艾筠']='艾筠丶叁柯斯:BAAALAADCgIIAgAAAA==.',['花杀']='花杀染香:BAABLAAFFH8KAAIYAAII4RXHUQB6AAAYAAII4RXHUQB6AAAAAA==.',['花满']='花满楼丶如花:BAAALAAECgYICQAAAA==.',['花落']='花落莫吩离:BAAALAAFFAIIBAAAAA==.',['花街']='花街一梦:BAAALAAECgcIBgAAAA==.',['苏紫']='苏紫依依:BAAALAAECgEIAQAAAA==.',['若叶']='若叶睦:BAAALAADCggICAAAAA==.',['草果']='草果:BAACLAAFFH8MAAIYAAQI7xorHgDSAAAYAAQI7xorHgDSAAAsAAQKfxgAAxgACAjIEZ5yAJ0BABgACAjIEZ5yAJ0BABwABQiLDgeNABwBAAAA.',['莫逐']='莫逐燕:BAABLAAFFH8XAAIYAAYIQB+zDAAOAgAYAAYIQB+zDAAOAgAAAA==.',['萌丶']='萌丶球球:BAAALAAECgYICgAAAA==.',['萌亮']='萌亮:BAAALAAECgIIAgAAAA==.',['萌小']='萌小神丶:BAABLAAFFH8GAAIHAAYInR4GGwDOAQAHAAYInR4GGwDOAQAAAA==.',['萌新']='萌新小白兔:BAABLAAFFH8JAAIGAAUIlgWmBgDIAAAGAAUIlgWmBgDIAAAAAA==.',['萌萌']='萌萌哟:BAACLAAFFH8fAAIZAAYI3x8zCgAsAgAZAAYI3x8zCgAsAgAsAAQKfyUAAhkACAhIIj4OAPYCABkACAhIIj4OAPYCAAAA.萌萌的光头强:BAAALAAECgQIBAAAAA==.',['萨里']='萨里萨气丶:BAAALAAFFAIIAgAAAA==.',['萬能']='萬能辣媽丶:BAAALAAECgQIBAAAAA==.',['落丹']='落丹伦的秋天:BAAALAAECgQIBAAAAA==.',['落单']='落单的骑士:BAAALAAECgYIDAAAAA==.',['蒂塔']='蒂塔微风:BAAALAADCgEIAQAAAA==.',['蒸汽']='蒸汽蘑菇:BAAALAAECgYIEgAAAA==.',['蓝啵']='蓝啵兔:BAABLAAFFH8JAAICAAII0BmMRwCZAAACAAII0BmMRwCZAAAAAA==.',['蓝色']='蓝色妖女:BAAALAADCgEIAQAAAA==.',['薇薇']='薇薇冰:BAAALAADCgUIBQAAAA==.',['虎鞭']='虎鞭灬:BAABLAAFFH8IAAILAAII3go/hgCCAAALAAII3go/hgCCAAAAAA==.',['虾人']='虾人不眨眼:BAAALAAFFAQIAgAAAA==.',['虾仁']='虾仁猪星:BAAALAAECggICAAAAA==.',['蛋总']='蛋总丶:BAAALAAECgYIBgAAAA==.',['蛋淡']='蛋淡蛋:BAAALAAFFAIIAwAAAA==.',['蛟龙']='蛟龙吐火球:BAAALAADCggICAAAAA==.',['蜗牛']='蜗牛胖胖:BAAALAAFFAIIBAAAAA==.',['血染']='血染得风采:BAAALAAECgYIDAAAAA==.',['血腥']='血腥巴格达:BAAALAAECgEIAQAAAA==.',['血魂']='血魂丨傀儡:BAAALAAECgYIBgAAAA==.',['被享']='被享用的男人:BAABLAAFFH8KAAISAAIIoR5fLwCxAAASAAIIoR5fLwCxAAAAAA==.',['被抬']='被抬着天上飞:BAAALAADCgcIBwAAAA==.',['被虐']='被虐光圈:BAABLAAFFH8UAAILAAIIYSTOQgCvAAALAAIIYSTOQgCvAAAAAA==.被虐光晕:BAABLAAFFH8IAAIQAAII3BcFVABHAAAQAAII3BcFVABHAAAAAA==.被虐光环:BAACLAAFFH8KAAMCAAII0iUcKgC1AAACAAII0iUcKgC1AAABAAIIkhX3GQCXAAAsAAQKfyUAAwIACAgMIJFCAHQCAAIACAgMIJFCAHQCAAEABgijDUFNACIBAAAA.',['製冰']='製冰機:BAACLAAFFH8RAAMLAAYIoA7BQwAxAQALAAUIMhHBQwAxAQAjAAEIxgGZHwAkAAAsAAQKfxwAAgsABgh9DMB3AAABAAsABgh9DMB3AAABAAAA.',['褚小']='褚小小:BAAALAAECggICAAAAA==.',['西班']='西班牙男模:BAAALAAFFAIIBAAAAA==.',['西瓜']='西瓜步兵:BAAALAAECgQIBAAAAA==.',['解释']='解释:BAAALAAECgYIDAAAAA==.',['诗残']='诗残莫续:BAAALAADCgMIAwAAAA==.',['诗绮']='诗绮灬:BAABLAAFFH8FAAITAAMI8wMxDgCCAAATAAMI8wMxDgCCAAAAAA==.',['请鞭']='请鞭挞我公瑾:BAABLAAFFH8IAAIIAAQIug0OFwCyAAAIAAQIug0OFwCyAAAAAA==.',['谢忞']='谢忞明喽喽:BAABLAAFFH8GAAICAAYIZBITHwBzAQACAAYIZBITHwBzAQAAAA==.',['賊特']='賊特嘻嘻:BAABLAAFFH8GAAISAAIIsx2OMACrAAASAAIIsx2OMACrAAAAAA==.',['贝丽']='贝丽:BAACLAAFFH8KAAICAAII7BG3RACbAAACAAII7BG3RACbAAAsAAQKfxcAAgIABgiNIIkpAPABAAIABgiNIIkpAPABAAAA.',['贰爷']='贰爷:BAAALAAFFAIIAgAAAA==.',['贰狗']='贰狗:BAAALAAECgIIAgAAAA==.',['赖杰']='赖杰皮之熊牛:BAAALAAFFAIIBAAAAA==.',['赞妞']='赞妞丶:BAAALAAFFAEIAQAAAA==.',['赦倪']='赦倪亦鲢:BAAALAAECgMIAwAAAA==.',['走撸']='走撸壹阵疯:BAAALAAECgYIBwAAAA==.',['走笔']='走笔各半丶:BAAALAAECgcIBwAAAA==.',['超凡']='超凡熊猫侠:BAAALAADCgMIAwAAAA==.',['超声']='超声波:BAAALAAECgYIEgAAAA==.',['超级']='超级大红手:BAAALAAECgUIBQAAAA==.',['跑的']='跑的有点快:BAAALAADCgIIAgAAAA==.',['跟风']='跟风猎:BAABLAAFFH8IAAIHAAIIcx6JVwCRAAAHAAIIcx6JVwCRAAAAAA==.',['轩辕']='轩辕老鬼:BAAALAAFFAIIAwAAAA==.',['转啊']='转啊转:BAAALAAECgYICwAAAA==.',['辣辣']='辣辣的保镖:BAABLAAECn8WAAMFAAYIGg2iWgDyAAAFAAYIGg2iWgDyAAAGAAEIMgeDngAtAAAAAA==.',['農夫']='農夫三拳丶:BAAALAAECgYIBgAAAA==.',['过往']='过往温柔:BAAALAAECgMIAwAAAA==.',['这牛']='这牛给力:BAAALAAFFAgIAQAAAA==.',['违规']='违规内容:BAAALAAECgMIBAAAAA==.',['逆灵']='逆灵花木:BAAALAAECgUIBQAAAA==.',['逐风']='逐风灬猎影:BAAALAAECggICAAAAA==.逐风者的丧钟:BAABLAAFFH8TAAILAAUIoRCURgAlAQALAAUIoRCURgAlAQAAAA==.逐风者的咒逐:BAABLAAFFH8GAAIQAAII4hQ1WgBDAAAQAAII4hQ1WgBDAAAAAA==.',['通通']='通通消灭:BAAALAAECgYIBgAAAA==.',['逮你']='逮你满满:BAAALAAECgYIBgAAAA==.',['那个']='那个法士:BAAALAAECggIBAAAAA==.',['那没']='那没路躲:BAAALAAFFAIIAgAAAA==.',['邪恶']='邪恶六角恐龙:BAAALAAECgYICgAAAA==.',['郁離']='郁離:BAABLAAECn8WAAMIAAgIlhfzKwAcAgAIAAgIUBbzKwAcAgAHAAMI8xQU3gDFAAAAAA==.',['部落']='部落英熊:BAABLAAFFH8JAAISAAIIyBmfLAB9AAASAAIIyBmfLAB9AAAAAA==.',['重生']='重生亡者:BAAALAADCgEIAQAAAA==.',['野牛']='野牛奥特曼:BAAALAADCgcIBwAAAA==.',['錵间']='錵间一壶酒:BAAALAAECgYIDQAAAA==.',['钞能']='钞能力:BAAALAAECgYICgAAAA==.',['钢蛋']='钢蛋丶:BAAALAAFFAQIBAAAAA==.',['铁木']='铁木树皮:BAABLAAFFH8KAAISAAcIfQ2FCQB1AQASAAcIfQ2FCQB1AQAAAA==.',['镜花']='镜花:BAAALAAECgYICAAAAA==.',['镜莲']='镜莲花:BAAALAAECgYIDwAAAA==.',['闪耀']='闪耀的土豪:BAABLAAFFH8GAAIZAAYIPBmDBAAaAgAZAAYIPBmDBAAaAgAAAA==.',['阿帕']='阿帕籽:BAAALAAECgYIBgAAAA==.',['阿波']='阿波丸:BAABLAAECn8UAAIhAAgIuRKTHQDFAQAhAAgIuRKTHQDFAQAAAA==.',['阿迩']='阿迩忒彌斯:BAABLAAFFH8FAAICAAQIBxKxNQDeAAACAAQIBxKxNQDeAAAAAA==.',['離殇']='離殇:BAABLAAFFH8KAAICAAIILyBCKQC3AAACAAIILyBCKQC3AAAAAA==.',['雪丶']='雪丶少:BAAALAAECgYIBwAAAA==.',['雪之']='雪之下丶雪乃:BAAALAAECgMIAwAAAA==.',['雪猎']='雪猎手:BAAALAAFFAIIAgAAAA==.',['零星']='零星风中絮:BAAALAAFFAIIBAAAAA==.',['雷切']='雷切尔贝洛克:BAAALAAECgQIBAAAAA==.',['雾殇']='雾殇雨:BAACLAAFFH8NAAMCAAMICh4wFQAQAQACAAMICh4wFQAQAQABAAEIYQHyKgA1AAAsAAQKfxoAAwIABgjsI5h3APsBAAIABgjsI5h3APsBAAEAAwhRBTpvAG8AAAAA.',['雾红']='雾红骑:BAAALAAFFAIIAgAAAA==.',['青山']='青山独归远:BAAALAAECggIDwAAAA==.',['青浦']='青浦欢哥:BAAALAAFFAIIAgAAAA==.',['青衣']='青衣:BAABLAAFFH8GAAMKAAIIuBmPNwCtAAAKAAIIuBmPNwCtAAAJAAEIZghkIQA+AAAAAA==.',['静曦']='静曦:BAAALAAECgYICAAAAA==.',['领闲']='领闲主演:BAAALAADCggICAAAAA==.',['風继']='風继续吹:BAAALAAECggIBgAAAA==.',['风丿']='风丿瑶筝:BAAALAAECgYIBgAAAA==.',['风吹']='风吹菊花微绽:BAAALAAECgYICgAAAA==.风吹鼻涕飘:BAAALAAECgQIBAAAAA==.',['风行']='风行者丶阿飞:BAAALAAECgYICAAAAA==.',['风过']='风过鸟无痕:BAABLAAFFH8FAAIUAAII5gdbOAApAAAUAAII5gdbOAApAAAAAA==.',['风骚']='风骚的大灰狼:BAAALAAECgcICgAAAA==.',['飘上']='飘上月球:BAABLAAFFH8GAAIQAAIIjA0eWQBEAAAQAAIIjA0eWQBEAAAAAA==.',['飘渺']='飘渺御风:BAAALAADCgUIBQAAAA==.',['飞了']='飞了味:BAAALAAECgUIBgAAAA==.',['香菜']='香菜灭亡者:BAAALAADCgIIAgAAAA==.',['駕馭']='駕馭者:BAAALAAECgYIDAAAAA==.',['马东']='马东锡丶:BAAALAAECgYIDwAAAA==.',['马库']='马库斯:BAAALAAECgQICwABLAAFFAEIAQAkAAAAAA==.',['驹驹']='驹驹大人:BAAALAAECgUICAAAAA==.驹驹大人丶:BAAALAAECgYIDAAAAA==.',['鬓霜']='鬓霜何妨:BAAALAADCgcIBwAAAA==.',['鬣磨']='鬣磨人:BAAALAAECgQIBAAAAA==.',['魂之']='魂之灬挽歌:BAAALAAFFAIIAgAAAA==.',['魂兮']='魂兮冥帝:BAAALAADCgEIAQAAAA==.魂兮墨落:BAAALAADCgMIAwAAAA==.魂兮影劫:BAAALAAECgYIBgAAAA==.魂兮迅影:BAAALAAECgYICwAAAA==.魂兮雷腾:BAAALAAECgYIBgAAAA==.魂兮魇影:BAAALAAECgYIBwAAAA==.',['魅魅']='魅魅丶:BAAALAAECgIIAgAAAA==.',['魔丶']='魔丶瞳:BAAALAAECgYIBgAAAA==.',['魔道']='魔道宗师:BAAALAADCggICAAAAA==.',['魔鬼']='魔鬼不疯狂:BAAALAAFFAIIAwAAAA==.',['魚缸']='魚缸裏的貓:BAAALAAECggIDAAAAA==.',['鱼人']='鱼人:BAAALAAFFAMIBAAAAA==.',['麦药']='麦药德:BAACLAAFFH8IAAIRAAII8QbXOAA2AAARAAII8QbXOAA2AAAsAAQKfx4AAhEABgifEG4wAAgBABEABgifEG4wAAgBAAAA.',['麻辣']='麻辣公主:BAAALAAECgEIAQAAAA==.',['黑白']='黑白丸子:BAAALAADCgEIAQAAAA==.黑白无常:BAAALAAECgQIBAAAAA==.黑白无罪:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end