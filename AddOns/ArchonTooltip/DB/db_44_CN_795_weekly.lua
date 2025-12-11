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
 local lookup = {'Hunter-BeastMastery','DemonHunter-Vengeance','Unknown-Unknown','Druid-Restoration','Druid-Balance','Paladin-Holy','Shaman-Restoration','Mage-Frost','Mage-Arcane','Shaman-Elemental','Priest-Holy','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Blood','Monk-Mistweaver','Monk-Windwalker','Priest-Shadow','Rogue-Assassination','Warrior-Protection','Warlock-Destruction','Warlock-Affliction','Warrior-Fury','Rogue-Subtlety','Priest-Discipline','DeathKnight-Unholy','Mage-Fire','Paladin-Protection','Hunter-Marksmanship','Druid-Guardian','Warlock-Demonology','Warrior-Arms','DemonHunter-Havoc','Druid-Feral','Hunter-Survival','Evoker-Devastation','Shaman-Enhancement','Evoker-Augmentation','Evoker-Preservation','Monk-Brewmaster',}; local provider = {region='CN',realm='耳语海岸',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Arthurmorgan:BAAALAAFFAIIAgAAAA==.',Ay='Ayolala:BAAALAAECgYIBwAAAA==.',Be='Bestdota:BAAALAAECgYICgAAAA==.',Bu='Bulkhead:BAABLAAFFH8KAAIBAAIIHg+7lwBBAAABAAIIHg+7lwBBAAAAAA==.Burning:BAABLAAFFH8KAAICAAYIjxYZBQBNAQACAAYIjxYZBQBNAQAAAA==.',Ch='Chloe:BAAALAAECggICAAAAA==.',Cy='Cylinne:BAAALAADCgcIBwABLAAFFAgIAwADAAAAAA==.',De='Deepsea:BAAALAAECgIIAgAAAA==.Dessy:BAAALAAECgMIAwAAAA==.',Dr='Dragonhill:BAAALAADCgYIBgAAAA==.Dredwing:BAAALAAFFAIIAgAAAA==.Druld:BAACLAAFFH8LAAIEAAIIXCK8LgCwAAAEAAIIXCK8LgCwAAAsAAQKfxsAAwQABgjSGn1GAMgBAAQABgjSGn1GAMgBAAUAAwhwCZGcAF0AAAEsAAUUAwgRAAYAixQA.',Fa='Fafafa:BAAALAADCgYIBgAAAA==.',Fr='Freing:BAABLAAFFH8NAAIGAAMI7xgtFAC9AAAGAAMI7xgtFAC9AAAAAA==.Fres:BAABLAAFFH8LAAIHAAMIahuTJAC+AAAHAAMIahuTJAC+AAAAAA==.Frostnova:BAACLAAFFH8KAAMIAAMIbRt3CwCnAAAIAAIIQxt3CwCnAAAJAAIIJhbsQgCdAAAsAAQKfy8AAwkACAgVIg8YAPUCAAkACAhZIA8YAPUCAAgABghNJIUaAEYCAAAA.',Gh='Ghgi:BAABLAAFFH8FAAIKAAIIJAgwSQA+AAAKAAIIJAgwSQA+AAAAAA==.Ghy:BAAALAAECgQIBAAAAA==.',Go='Good:BAABLAAFFH8IAAIHAAIIOhG+RwB1AAAHAAIIOhG+RwB1AAABLAAFFAIICAALADcHAA==.',Ho='Holynova:BAABLAAFFH8GAAIMAAII1gdHdwA5AAAMAAII1gdHdwA5AAAAAA==.',Il='Illidana:BAAALAAFFAIIAgAAAA==.',Jo='Josh:BAACLAAFFH8dAAIHAAYIqhm7FAC6AQAHAAYIqhm7FAC6AQAsAAQKfyIAAgcACAhmH4sbAKsCAAcACAhmH4sbAKsCAAAA.',Ke='Kensou:BAACLAAFFH83AAIBAAYIKRk/LQCBAQABAAYIKRk/LQCBAQAsAAQKfxYAAgEACAiMHpBMAEcCAAEACAiMHpBMAEcCAAAA.',Ku='Kumo:BAABLAAFFH8GAAINAAQIUx6AQwCuAAANAAQIUx6AQwCuAAAAAA==.',La='Labubu:BAAALAAECgYICAAAAA==.',Li='Liza:BAAALAADCgYIBgAAAA==.',Lu='Luna:BAAALAAFFAIIAQAAAA==.Lusy:BAAALAAFFAIIAgAAAA==.',Mi='Milenio:BAAALAAECgYIDQAAAA==.Min:BAAALAAECgUIBQAAAA==.Minoqwq:BAAALAAFFAIIBAAAAA==.',Mo='Mom:BAABLAAFFH8IAAILAAIINwe+OwB+AAALAAIINwe+OwB+AAAAAA==.',Ne='Needherr:BAAALAAECgQIBAAAAA==.',Ni='Nikanya:BAAALAADCggICAAAAA==.',No='Nonce:BAAALAAECgYIDAAAAA==.Noworries:BAAALAAFFAYIBAAAAA==.',Ok='Okita:BAABLAAFFH8gAAIOAAYIgQ1MDQA1AQAOAAYIgQ1MDQA1AQAAAA==.',Pa='Pander:BAACLAAFFH8zAAMPAAYIlA7YCgBdAQAPAAYIlA7YCgBdAQAQAAQIfhN5DQDlAAAsAAQKfyUAAw8ACAiDGL8UAC0CAA8ACAiDGL8UAC0CABAABgjHFfgxAIMBAAAA.Paris:BAAALAAECgcICAAAAA==.',Pe='Pexo:BAAALAAFFAEIAQAAAA==.',Ql='Qlong:BAAALAAECgQIBAAAAA==.',Qu='Quantum:BAABLAAFFH8JAAIRAAQImBV2DgA7AQARAAQImBV2DgA7AQAAAA==.',Re='Realy:BAAALAADCgQIBAAAAA==.',Ri='Riansong:BAAALAADCggICAAAAA==.Rita:BAABLAAFFH8HAAISAAIIxQM+HgA+AAASAAIIxQM+HgA+AAAAAA==.',Ru='Rubyms:BAAALAADCggICAAAAA==.',Sa='Saisei:BAABLAAFFH8GAAITAAYIjwO+GADdAAATAAYIjwO+GADdAAAAAA==.',St='Stellaluna:BAAALAAECgEIAQAAAA==.Strangennj:BAAALAAECgYIBgAAAA==.',Ta='Tang:BAAALAAECgYIBgAAAA==.',Th='Thoughluck:BAACLAAFFH82AAMHAAYI7RVkGwCAAQAHAAYI7RVkGwCAAQAKAAYIIBJ7GAB6AQAsAAQKfxoAAwcABgiBImIZACYCAAcABgiBImIZACYCAAoABQi1DMmTAAYBAAAA.',Wh='Whylost:BAAALAAFFAIIAgAAAA==.Whyui:BAAALAAECgUICQAAAA==.Whyy:BAAALAAECgYIDgAAAA==.',Ww='Wwoo:BAAALAAECgMIAwAAAA==.',Xi='Xiaoshaman:BAAALAAECgYICgAAAA==.Xina:BAAALAAFFAIIAgAAAA==.',Zg='Zgreen:BAAALAAECgYIBwAAAA==.',Zh='Zhenye:BAAALAAECgYICAAAAA==.Zhyu:BAACLAAFFH87AAMUAAcIqCWdCQBlAgAUAAcIRiWdCQBlAgAVAAEIdSaoBQBsAAAsAAQKfykAAxQACAhpJYMIAFMDABQACAhpJYMIAFMDABUABQhEHzcSAJIBAAAA.',['一个']='一个猎痴:BAAALAAFFAIIAgAAAA==.一个盾痴:BAABLAAECn8iAAMWAAgITB0QKQCZAgAWAAgITB0QKQCZAgATAAQI8xQ8OgCqAAAAAA==.一个贼痴:BAABLAAFFH8KAAMSAAII6wvKGgCUAAASAAII3gvKGgCUAAAXAAEI5AJBIAAzAAAAAA==.',['一宿']='一宿一:BAAALAAFFAIIAwAAAA==.',['一尤']='一尤朵拉一:BAABLAAFFH8GAAIJAAYIpBNVKQBuAQAJAAYIpBNVKQBuAQAAAA==.',['一撒']='一撒旦一:BAAALAAECggICAAAAA==.',['一猪']='一猪八戒一:BAAALAAECgQICAAAAA==.',['一色']='一色彩羽:BAACLAAFFH83AAMLAAcIPyMiAwC7AgALAAcIPyMiAwC7AgARAAQI8xYBGAD+AAAsAAQKfyUABAsABwhcI5ggAHUCAAsABwhcI5ggAHUCABEABggQH+8vAAwCABgAAgjyCcA2AFAAAAAA.',['一锤']='一锤子抡死:BAAALAADCgYIBgAAAA==.',['万佛']='万佛茶米:BAAALAAECgUIBQAAAA==.',['万法']='万法千宗:BAACLAAFFH8oAAMZAAYI6iTmAwA9AQANAAUImBygNwBdAQAZAAUI6STmAwA9AQAsAAQKfyEAAhkACAgLJhcGAPkCABkACAgLJhcGAPkCAAEsAAUUCAgKAA0AgwEA.',['三分']='三分糖少冰:BAAALAAECgYIBgAAAA==.',['三哈']='三哈:BAAALAAECgQIBAAAAA==.',['不听']='不听故事:BAAALAAECgYIBwAAAA==.',['不灭']='不灭狂雷:BAAALAAECgMIAwAAAA==.',['两禽']='两禽相悦:BAAALAADCggICAAAAA==.',['丨梦']='丨梦绮灬:BAAALAADCgcIBwAAAA==.',['丨莫']='丨莫淇洛丨:BAACLAAFFH8zAAIHAAcItBkkBwDMAQAHAAcItBkkBwDMAQAsAAQKfycAAgcACAhyHpkhAI0CAAcACAhyHpkhAI0CAAAA.',['丨隔']='丨隔壁老钱丨:BAACLAAFFH8aAAIBAAYIIRJxHAAhAQABAAYIIRJxHAAhAQAsAAQKfyIAAgEACAgKGcugAKoBAAEACAgKGcugAKoBAAAA.',['个头']='个头兮兮:BAAALAAFFAIIBAAAAA==.',['中看']='中看不中用:BAAALAADCgIIAgAAAA==.',['丶掃']='丶掃把星丶:BAABLAAFFH8MAAMNAAYINCJuFgDiAQANAAYINCJuFgDiAQAOAAYIkxNpCwBYAQAAAA==.',['丶月']='丶月影灬星痕:BAABLAAFFH8JAAIBAAUIGBsNQwA8AQABAAUIGBsNQwA8AQAAAA==.',['丶玉']='丶玉景灬天池:BAACLAAFFH8fAAMJAAUIUB4yKwBkAQAJAAUIUB4yKwBkAQAaAAMIexg0BwCYAAAsAAQKfz0AAwkACAiKI+QJAIECAAkACAiKI+QJAIECABoABgiqHFwIANwBAAEsAAUUCAgSAAUAeR0A.',['丿牛']='丿牛盾:BAACLAAFFH8gAAQGAAgIkQ3oDQCmAQAGAAcI8gvoDQCmAQAMAAUI9QtQLwALAQAbAAIImBrWFQBKAAAsAAQKfxgAAxsABggjFihKAAgBAAwABggrDfL8AC8BABsABAhVFihKAAgBAAAA.',['丿龍']='丿龍皇丶:BAABLAAFFH8MAAIMAAMIrgpkRwB9AAAMAAMIrgpkRwB9AAAAAA==.',['乂莎']='乂莎:BAACLAAFFH8QAAIMAAUIDQYcMgDyAAAMAAUIDQYcMgDyAAAsAAQKf0EAAgwACAirF20sAOEBAAwACAirF20sAOEBAAAA.',['九天']='九天霸主:BAAALAADCgEIAgAAAA==.',['书桓']='书桓丶:BAABLAAECn8YAAIMAAYICx19RQCMAQAMAAYICx19RQCMAQAAAA==.',['乱抓']='乱抓野生宝宝:BAAALAAFFAIIAgAAAA==.',['乱拳']='乱拳:BAABLAAECn80AAMBAAYIzx2oTwClAQABAAYIzx2oTwClAQAcAAMIBBOwkgCfAAAAAA==.',['二次']='二次元:BAAALAAECgYIDQAAAA==.二次元暗魂:BAACLAAFFH8MAAIdAAUIgQc1AwDIAAAdAAUIgQc1AwDIAAAsAAQKfxUAAh0ABwjxCkMgAA4BAB0ABwjxCkMgAA4BAAAA.',['亏克']='亏克利:BAAALAAECgYICwAAAA==.',['云既']='云既无心出迶:BAAALAAECgYIEQAAAA==.',['云树']='云树绕堤沙:BAACLAAFFH8iAAMUAAYISRc0KQB1AQAUAAYISRc0KQB1AQAeAAEIEgeSLgBGAAAsAAQKfyoAAxQACAjHIA4WAAIDABQACAjHIA4WAAIDAB4AAQicChWaADYAAAEsAAUUBwg1AAsAZRwA.',['人性']='人性的背叛者:BAABLAAFFH8GAAINAAIIURiRVQCeAAANAAIIURiRVQCeAAAAAA==.',['人道']='人道是战神:BAABLAAECn8cAAINAAgIjSHCHQAGAgANAAgIjSHCHQAGAgAAAA==.',['伊兰']='伊兰妮娅:BAAALAADCggICAAAAA==.',['休闲']='休闲东东:BAACLAAFFH8SAAIWAAQI6BcQLAABAQAWAAQI6BcQLAABAQAsAAQKfxYAAxYACAjrIF0sAIoCABYACAjrIF0sAIoCAB8ABAiUDaElANMAAAAA.',['你的']='你的骑士:BAAALAAECgYIBgAAAA==.',['信仰']='信仰之歌:BAAALAAECggICAAAAA==.信仰战:BAACLAAFFH8MAAITAAUIaw68FwDtAAATAAUIaw68FwDtAAAsAAQKfzcAAhMABwjSHWkNAPkBABMABwjSHWkNAPkBAAAA.',['信风']='信风悠悠:BAAALAADCgYIBgAAAA==.',['修逻']='修逻:BAACLAAFFH8QAAITAAUIhx4pDgBjAQATAAUIhx4pDgBjAQAsAAQKf0EAAhMACAgfJeYBAO8CABMACAgfJeYBAO8CAAAA.',['俺也']='俺也静灵:BAAALAAECgIIAwAAAA==.',['倒影']='倒影红尘:BAACLAAFFH8jAAIJAAYIsxJfIAApAQAJAAYIsxJfIAApAQAsAAQKfyUAAgkACAgQHZQ6AGACAAkACAgQHZQ6AGACAAAA.',['倪克']='倪克斯:BAAALAAECgEIAQAAAA==.',['倾城']='倾城丶依依:BAAALAAECgYIBgAAAA==.',['倾杯']='倾杯:BAACLAAFFH8PAAILAAII7SGxIwCqAAALAAII7SGxIwCqAAAsAAQKfxQAAgsABgjlHXUZAPMBAAsABgjlHXUZAPMBAAAA.',['偷你']='偷你苦茶子:BAAALAADCggICAAAAA==.',['傷心']='傷心寶寶:BAABLAAECn8XAAMIAAYIqxLyIwABAQAIAAYIqxLyIwABAQAJAAII/QM9ewAbAAAAAA==.',['元素']='元素猫咩咩:BAAALAADCggICAAAAA==.',['光棍']='光棍萨满:BAAALAAECgYIDAAAAA==.',['光阴']='光阴副本:BAAALAAFFAIIBAABLAAFFAIICAARAKEdAA==.',['兰艾']='兰艾:BAAALAAECgYIDQAAAA==.',['兰茵']='兰茵蔽月:BAAALAAECgQIBAAAAA==.',['养了']='养了两只猫:BAAALAAECggICAAAAA==.',['冫中']='冫中:BAAALAAECgMIAwAAAA==.',['冬季']='冬季艳阳:BAAALAAFFAIIBAAAAA==.',['冰刃']='冰刃男爵:BAAALAADCgIIAgAAAA==.',['冰天']='冰天丨百花葬:BAAALAAFFAYIAgAAAA==.',['冰糖']='冰糖柚子茶:BAABLAAECn8UAAIBAAgIJxXhYACAAQABAAgIJxXhYACAAQAAAA==.',['冰葡']='冰葡美式:BAAALAADCgcIBwAAAA==.',['几十']='几十个圣骑:BAAALAAECgYIEgABLAAFFAUIDAATAGsOAA==.几十个小德:BAAALAAECgYIBgABLAAFFAUIDAATAGsOAA==.几十个猎魔人:BAACLAAFFH8IAAICAAIIsgo4FQBgAAACAAIIsgo4FQBgAAAsAAQKfysAAgIACAgdEZElAIkBAAIACAgdEZElAIkBAAEsAAUUBQgMABMAaw4A.',['凤凰']='凤凰使者:BAAALAAECgMIAwAAAA==.',['刘老']='刘老六:BAAALAADCgMIBAAAAA==.',['利姆']='利姆露:BAAALAAECggICAAAAA==.',['制裁']='制裁丶:BAABLAAFFH8GAAMGAAIIfwfaIwB9AAAGAAIIfwfaIwB9AAAbAAIIFA4wGQB0AAAAAA==.',['刺骨']='刺骨寒寒:BAABLAAFFH8IAAMZAAIIORpbEQBQAAAZAAIIORpbEQBQAAANAAEIoRUBrwAAAAAAAA==.',['北大']='北大路五月:BAAALAAFFAIIAgAAAA==.',['北极']='北极没有夏天:BAABLAAFFH8FAAINAAIIVwwMfACKAAANAAIIVwwMfACKAAAAAA==.',['千儿']='千儿八百遍:BAAALAAECgMIAwAAAA==.',['午夜']='午夜红玫瑰:BAAALAADCgUIBQAAAA==.',['卖萌']='卖萌小女德:BAAALAADCgEIAQAAAA==.',['南户']='南户唯:BAAALAAECgYICgAAAA==.',['単戈']='単戈独戦:BAAALAAECgYIBgAAAA==.',['卡德']='卡德虾:BAAALAAECgYIBgAAAA==.',['却邪']='却邪:BAAALAAECgEIAQAAAA==.',['叮叮']='叮叮咚:BAABLAAFFH8GAAMXAAYIMRVwDAC5AAASAAMIBRAIEQDzAAAXAAMIXRpwDAC5AAAAAA==.',['叮咚']='叮咚叮:BAAALAAFFAQIBAAAAA==.',['叮铛']='叮铛叮:BAABLAAFFH8GAAMXAAYIOhwMDADCAAASAAMIRhcAEAAEAQAXAAMILSEMDADCAAAAAA==.',['可爱']='可爱:BAAALAADCgYIBgAAAA==.可爱的女胖墩:BAAALAADCgIIAgAAAA==.',['右护']='右护法周米粒:BAAALAADCggICAAAAA==.',['司马']='司马皮特:BAAALAAECgYIBgAAAA==.',['吃鸡']='吃鸡仙人:BAAALAADCgYIBgAAAA==.',['吉好']='吉好德:BAAALAAECgIIAgAAAA==.',['吖吖']='吖吖德兮:BAAALAAECgEIAQAAAA==.',['呛口']='呛口小火锅:BAAALAAECgYIDAAAAA==.',['哇真']='哇真的是你呀:BAAALAAFFAIIAgAAAA==.',['哈喉']='哈喉的老腊肉:BAABLAAFFH8GAAIBAAYInAm8RwAsAQABAAYInAm8RwAsAQAAAA==.',['哈迪']='哈迪斯的怒吼:BAACLAAFFH8kAAIUAAcIUhrNFQDaAQAUAAcIUhrNFQDaAQAsAAQKfxsAAhQABwgXIjMSAFQCABQABwgXIjMSAFQCAAAA.',['哎圣']='哎圣光:BAABLAAFFH8NAAINAAUIzxM5RQAmAQANAAUIzxM5RQAmAQAAAA==.',['員外']='員外:BAABLAAECn8aAAMeAAYIARu7NgCSAQAeAAUIgRu7NgCSAQAVAAEIgBgoOQBLAAAAAA==.',['哥变']='哥变的是寂寞:BAAALAAECggICAAAAA==.',['哥哥']='哥哥猛不猛:BAAALAAECgYICwAAAA==.',['唠啦']='唠啦丶氪唠馥:BAAALAAECggICgAAAA==.',['唱歌']='唱歌给谁听:BAAALAAECgYIBgAAAA==.',['啦拉']='啦拉啦种太阳:BAAALAAECggIEQAAAA==.',['喵大']='喵大帅:BAAALAAECgUIBQAAAA==.',['嘉丹']='嘉丹和:BAAALAADCgQIBQAAAA==.',['嘚嘚']='嘚嘚以嘚嘚:BAABLAAFFH8GAAIFAAYI7w4NFgAtAQAFAAYI7w4NFgAtAQAAAA==.',['回忆']='回忆狂野:BAABLAAECn8dAAMCAAgILwuzFgDxAAACAAcItAuzFgDxAAAgAAIItAZarAA8AAAAAA==.回忆规划:BAAALAAECgYIDgAAAA==.',['圣光']='圣光不够靓:BAAALAAECgIIAgAAAA==.圣光小马仔:BAACLAAFFH8MAAMGAAIIdQ6LJgBxAAAGAAIIdQ6LJgBxAAAMAAIIpgXcZgBRAAAsAAQKfx4AAwYABgh7FyAXAJ0BAAYABgh7FyAXAJ0BAAwABQhQHb1TAGQBAAAA.圣光猫咩咩:BAAALAAECgYIBgAAAA==.圣光的忽悠:BAABLAAECn8VAAILAAYI7xY4JgCDAQALAAYI7xY4JgCDAQAAAA==.',['圣恆']='圣恆韵楓:BAAALAADCgIIAgAAAA==.圣恆韵风:BAAALAADCgQIBAAAAA==.',['圣恒']='圣恒韵葑:BAAALAADCgEIAQAAAA==.',['坐看']='坐看雲起:BAABLAAECn8YAAMPAAYIWg8uGQAXAQAPAAYIWg8uGQAXAQAQAAMIBQ1CMABvAAAAAA==.',['坠空']='坠空:BAAALAAFFAIIAgAAAA==.',['基督']='基督山千送伊:BAAALAADCgYIBgAAAA==.基督山呆毛王:BAAALAAECgYIBgAAAA==.',['基维']='基维思:BAABLAAFFH8LAAIMAAIIhxgIUgBSAAAMAAIIhxgIUgBSAAAAAA==.',['塔莉']='塔莉萨:BAAALAADCgQIBAAAAA==.',['壮壮']='壮壮宝啊:BAAALAAFFAIIBAAAAA==.',['壹原']='壹原侑子:BAABLAAFFH8GAAIJAAYIGhzsHgCbAQAJAAYIGhzsHgCbAQAAAA==.',['壹柒']='壹柒叁贰:BAAALAADCggICAAAAA==.',['夏天']='夏天的风:BAAALAAECgYIBgAAAA==.',['夜曲']='夜曲:BAAALAAECgYIBwAAAA==.',['夜鹰']='夜鹰之王:BAACLAAFFH8KAAIMAAIIxQsoagBBAAAMAAIIxQsoagBBAAAsAAQKfyAAAgwABwh/GAuHAOABAAwABwh/GAuHAOABAAAA.',['大丨']='大丨领丨主:BAAALAADCgEIAQAAAA==.',['大叔']='大叔的乖萝卜:BAABLAAFFH8IAAIOAAIINw41EQB/AAAOAAIINw41EQB/AAAAAA==.',['大宗']='大宗师:BAAALAAECgYICwAAAA==.',['大老']='大老千:BAAALAAFFAIIAgAAAA==.',['大耳']='大耳朵波波:BAABLAAFFH8fAAIOAAYI4wxyCgDSAAAOAAYI4wxyCgDSAAAAAA==.大耳朵爱吃饭:BAAALAAECgYIBgAAAA==.',['大聪']='大聪哥:BAAALAAECgQIBAAAAA==.',['大蕉']='大蕉丶:BAAALAAECgEIAQAAAA==.',['天然']='天然圣泉水:BAAALAAECgUIBQAAAA==.天然纯净水:BAAALAAECgYIBgAAAA==.',['天王']='天王之王:BAAALAAECgYIDAAAAA==.',['天空']='天空下的小鱼:BAAALAADCgUIBQAAAA==.',['太子']='太子司马:BAABLAAFFH8EAAIBAAIIZxOzggBQAAABAAIIZxOzggBQAAAAAA==.',['太寿']='太寿鸠毛:BAAALAAECggICAAAAA==.',['失落']='失落的正义:BAAALAAFFAIIBAAAAA==.',['失魂']='失魂疯:BAAALAAECgYIBgAAAA==.',['奁戈']='奁戈苘芥:BAAALAAECgYICAAAAA==.',['奈拉']='奈拉丝特娜:BAAALAAECgcIEgAAAA==.奈拉丝特拉:BAABLAAFFH8KAAIgAAIIDhBwQgCXAAAgAAIIDhBwQgCXAAAAAA==.',['女二']='女二:BAAALAAECgIIAgAAAA==.',['奶爆']='奶爆:BAABLAAFFH8GAAIRAAIIVBcqIACOAAARAAIIVBcqIACOAAAAAA==.',['奶萨']='奶萨:BAABLAAECn8gAAIHAAYI8SGRGQAlAgAHAAYI8SGRGQAlAgAAAA==.',['如意']='如意:BAABLAAECn8dAAIaAAgIUA2CBgBhAQAaAAgIUA2CBgBhAQAAAA==.',['婀娜']='婀娜多姿:BAAALAADCgQIBAAAAA==.',['嫣嘫']='嫣嘫若夕:BAAALAADCgMIAwAAAA==.',['孙小']='孙小武:BAAALAADCgMIAwAAAA==.',['安安']='安安逸:BAAALAAFFAIIAgAAAA==.',['宋齐']='宋齐梁陈:BAAALAAECgYIEgAAAA==.',['宝贝']='宝贝爱天使:BAAALAAECgYIDgAAAA==.',['家有']='家有暖宝:BAAALAAECgQICQAAAA==.',['容成']='容成墨熙:BAAALAAECgYIBgAAAA==.',['富贵']='富贵:BAAALAAECgYIBgAAAA==.',['封之']='封之不死骑士:BAABLAAFFH8IAAIMAAII5xptUgBRAAAMAAII5xptUgBRAAAAAA==.',['小仪']='小仪仪:BAAALAAFFAIIAwAAAA==.',['小卷']='小卷:BAACLAAFFH8rAAIhAAYI6hboAwCLAQAhAAYI6hboAwCLAQAsAAQKfyQAAyEACAixGuQTABkCACEACAixGuQTABkCAAUAAwhSBm5SAGgAAAAA.',['小小']='小小布兰:BAAALAAECgYIBgAAAA==.小小桃:BAAALAAECgIIAgAAAA==.小小牛:BAAALAAECggICgAAAA==.',['小果']='小果妹妹:BAAALAAECgIIAgAAAA==.',['小犄']='小犄角长尾巴:BAACLAAFFH8mAAIHAAYIxhZlEgAmAQAHAAYIxhZlEgAmAQAsAAQKfxQAAgcACAgEHsk2ADsCAAcACAgEHsk2ADsCAAAA.',['小狐']='小狐抓抓:BAAALAAECgUIBQAAAA==.',['小王']='小王子的狐狸:BAABLAAFFH8MAAILAAII7R3zLwCrAAALAAII7R3zLwCrAAAAAA==.',['小痴']='小痴不忧郁:BAABLAAECn8XAAINAAgIxRx3UABXAgANAAgIxRx3UABXAgAAAA==.',['小白']='小白人:BAAALAAECgMIAwAAAA==.',['小米']='小米辣:BAABLAAECn8YAAIeAAYI7RY/MwCgAQAeAAYI7RY/MwCgAQAAAA==.',['小红']='小红红苹果:BAAALAADCgUIBQAAAA==.',['小肥']='小肥煋:BAABLAAFFH8sAAMUAAYIQxi3IQCVAQAUAAYIJRi3IQCVAQAeAAEI5B6HDABbAAAAAA==.',['小花']='小花花丶:BAAALAADCgYIBgAAAA==.',['小蛮']='小蛮腰:BAAALAADCgIIAgAAAA==.',['就是']='就是这个味:BAAALAAECgYIDAAAAA==.',['局外']='局外人浩爷:BAAALAAECgMIAwAAAA==.',['崋陀']='崋陀:BAAALAAECgQIBAAAAA==.',['左右']='左右:BAAALAADCgMIAwAAAA==.',['布列']='布列塔尼:BAAALAAECgMIAwAAAA==.',['布林']='布林顿五千:BAAALAAFFAIIBAAAAA==.',['希丝']='希丝缇娜:BAAALAAECgYIBgABLAAFFAcINwALAD8jAA==.',['幕诗']='幕诗:BAACLAAFFH8hAAMLAAYIQiTLBwDaAQALAAYIQiTLBwDaAQARAAUIux77BwDXAQAsAAQKfykAAxEACAi6IRUOAAMDABEACAi6IRUOAAMDAAsAAQhtHqi8ADoAAAAA.',['幸福']='幸福白勺泡泡:BAABLAAFFH8IAAIJAAIIhRZMVQBGAAAJAAIIhRZMVQBGAAAAAA==.幸福白勺贝贝:BAABLAAFFH8GAAIWAAIIABnISABKAAAWAAIIABnISABKAAAAAA==.',['幻丶']='幻丶月:BAACLAAFFH8MAAIHAAIIlgwCZQBWAAAHAAIIlgwCZQBWAAAsAAQKfx4AAgcACAg0GFZRAO4BAAcACAg0GFZRAO4BAAAA.',['幻之']='幻之萧萧:BAAALAADCggIEAAAAA==.',['幻魔']='幻魔的小狼:BAAALAAECgMIBAAAAA==.',['幽冥']='幽冥怒雪:BAAALAAECgMIAwAAAA==.',['库尔']='库尔提娜:BAAALAAECgEIAQAAAA==.',['弈殇']='弈殇:BAABLAAFFH8GAAIBAAYIoBlVLACEAQABAAYIoBlVLACEAQAAAA==.',['弹丸']='弹丸曳光者:BAAALAAECgcIBwAAAA==.',['强力']='强力熊:BAACLAAFFH8OAAIPAAIIMA1CFgBpAAAPAAIIMA1CFgBpAAAsAAQKfxgAAg8ABwh0D9QnAGUBAA8ABwh0D9QnAGUBAAAA.',['强尼']='强尼银手:BAAALAAECgIIAgAAAA==.',['当红']='当红灬俊:BAABLAAECn9HAAMBAAgI6R/tFwBtAgABAAgI6R/tFwBtAgAiAAYIgguSFABiAQABLAAFFAUIDAATAGsOAA==.',['德墨']='德墨忒尔:BAAALAAFFAMIAwAAAA==.',['心之']='心之所向:BAAALAAFFAIIBAAAAA==.',['忧郁']='忧郁小痴:BAABLAAFFH8LAAMIAAIIshfQFACEAAAJAAIIshfFSACXAAAIAAII+w7QFACEAAAAAA==.忧郁的打火机:BAAALAADCggICAAAAA==.',['怒光']='怒光歌:BAACLAAFFH8KAAIeAAII+BskDQCsAAAeAAII+BskDQCsAAAsAAQKfxsAAx4ABgjtImQmAN4BAB4ABQiMI2QmAN4BABQAAghlG7jcAJ0AAAAA.',['恐虐']='恐虐神选者:BAACLAAFFH8rAAMNAAcIWh/BFACkAQANAAcIOR7BFACkAQAZAAMI2hnQBAApAQAsAAQKfzAAAw0ACAhVJQIWABkDAA0ACAhdJAIWABkDABkABgiEIjASAD0CAAAA.',['恶魔']='恶魔扳手:BAAALAAFFAIIBAAAAA==.',['悬凝']='悬凝空:BAABLAAFFH8jAAIjAAYIDiD9BgDBAQAjAAYIDiD9BgDBAQAAAA==.',['我家']='我家的小璐璐:BAABLAAFFH8SAAIBAAUIDhD3UQAHAQABAAUIDhD3UQAHAQAAAA==.',['我已']='我已双持风剑:BAABLAAFFH8IAAIPAAgIAADxHAAEAAAPAAgIAADxHAAEAAAAAA==.',['我用']='我用菊花:BAAALAAFFAIIBAAAAA==.',['我要']='我要倒了:BAAALAAECgMIAwAAAA==.我要双持蛋刀:BAAALAAECgUICgABLAAFFAgICAAPAAAAAA==.',['战争']='战争残月:BAAALAAECgYIDQAAAA==.',['战住']='战住:BAAALAAECgIIAgAAAA==.',['战无']='战无极:BAAALAAFFAEIAQAAAA==.',['战神']='战神刑天:BAAALAAECgYICQAAAA==.战神将:BAAALAADCgcIBwAAAA==.',['打不']='打不过就跑吧:BAAALAAECggIDAAAAA==.',['打老']='打老虎六六:BAAALAADCgUIBQAAAA==.',['扶摇']='扶摇九里:BAAALAAECgYIBgAAAA==.',['抓哒']='抓哒你猛吸:BAAALAAECgUIBQAAAA==.抓哒你猛砍:BAAALAAECgUIBQAAAA==.',['披萨']='披萨心肠:BAAALAAFFAEIAQAAAA==.',['拉克']='拉克丝克莱恩:BAAALAAECgUIBQAAAA==.',['招招']='招招猎猎:BAABLAAECn8bAAIBAAYIURVwzgBsAQABAAYIURVwzgBsAQAAAA==.',['拾柒']='拾柒号:BAAALAAECgMIBgAAAA==.',['捌幺']='捌幺伍:BAAALAAFFAQIBAABLAAFFAgIDQAXAEoQAA==.',['教科']='教科书式亵渎:BAABLAAFFH8FAAIUAAUIdwGhTACHAAAUAAUIdwGhTACHAAAAAA==.',['斯卡']='斯卡莱特:BAAALAADCgYIBgAAAA==.',['新电']='新电池一块:BAABLAAFFH8HAAIYAAcIBgNZBACBAAAYAAcIBgNZBACBAAAAAA==.',['方一']='方一然:BAAALAAFFAIIAwAAAA==.',['方么']='方么么:BAAALAAFFAIIAgAAAA==.',['方朝']='方朝朝:BAAALAAECgEIAQAAAA==.',['方然']='方然:BAAALAAECgMIAwAAAA==.',['方羽']='方羽墨:BAABLAAFFH8HAAIeAAMIIQqfCgBwAAAeAAMIIQqfCgBwAAAAAA==.方羽然:BAAALAAFFAIIAgAAAA==.方羽萌:BAAALAAFFAIIBAAAAA==.',['早苗']='早苗:BAAALAADCgYIBgAAAA==.',['星熊']='星熊:BAABLAAECn8ZAAMFAAcIygyMVwBbAQAFAAcIygyMVwBbAQAEAAYIghGnbgBKAQAAAA==.',['春娇']='春娇与八戒:BAABLAAFFH8GAAIBAAMIvBRybwCDAAABAAMIvBRybwCDAAAAAA==.',['時光']='時光:BAAALAAECgMIAwAAAA==.',['時空']='時空:BAAALAAECgMIAwAAAA==.',['晓之']='晓之狼:BAABLAAECn8aAAIMAAgIBhwqGwA4AgAMAAgIBhwqGwA4AgAAAA==.',['晓乌']='晓乌苏:BAAALAAECgUIBQAAAA==.',['智商']='智商过高:BAAALAADCgIIAgAAAA==.',['暖阳']='暖阳:BAABLAAFFH8KAAIMAAIInRbnNwCkAAAMAAIInRbnNwCkAAAAAA==.',['暗影']='暗影的狩猎者:BAACLAAFFH8IAAMBAAIIbBQhhwBKAAAcAAIIJAQSMABgAAABAAIIbBQhhwBKAAAsAAQKfxoAAwEACAgYGg1MAEgCAAEACAgYGg1MAEgCABwABgg1FkFRAHEBAAAA.',['暮光']='暮光的微笑:BAAALAAECggICAAAAA==.',['曌楽']='曌楽梓:BAACLAAFFH83AAQLAAYIPiAdCwAXAgALAAYIPiAdCwAXAgARAAUI9RWmCgCdAQAYAAIIlQbyBgBIAAAsAAQKfyUABAsACAi9HZY4APkBAAsACAi9HZY4APkBABgABQigEK0aACIBABEABgjiCqQxAMoAAAAA.',['最后']='最后一个老千:BAAALAAECgQICAAAAA==.最后坦格利安:BAAALAAECgYIDAAAAA==.',['木土']='木土土:BAAALAADCgYIBgAAAA==.',['木子']='木子方:BAAALAAFFAIIAgAAAA==.',['朱无']='朱无视:BAAALAAFFAIIAgAAAA==.',['杜飞']='杜飞丶:BAABLAAFFH8GAAIbAAIIWRISGwA0AAAbAAIIWRISGwA0AAAAAA==.',['松饼']='松饼喵熊:BAAALAAFFAIIAgAAAA==.',['枭熊']='枭熊:BAACLAAFFH8UAAMdAAUIpRXlBADjAAAdAAUIXRHlBADjAAAhAAMIkxuJCQCYAAAsAAQKfygABSEACAhgHoUHAN0BACEACAhgHoUHAN0BAAUABQjqFNFcAEcBAB0ABgiAETsYAMkAAAQAAQgtHYp3AFMAAAAA.',['柏月']='柏月之影:BAAALAAFFAEIAQAAAA==.',['核电']='核电皮卡丘:BAACLAAFFH8FAAIKAAIIcxeMPwBLAAAKAAIIcxeMPwBLAAAsAAQKfx8AAyQABgiTHY8HAHoBACQABQihH48HAHoBAAoABggeGT4tAGEBAAAA.',['桑铎']='桑铎克里冈:BAAALAAFFAIIAgAAAA==.',['梅赛']='梅赛德寺:BAABLAAECn8qAAIbAAYITB3FIQDtAQAbAAYITB3FIQDtAQABLAAFFAUIEAATAIceAA==.',['梵丶']='梵丶夜:BAAALAAECggICwAAAA==.',['梶猗']='梶猗:BAABLAAFFH8fAAQjAAYIhBQ3DAAwAQAlAAYICQqrBgBIAQAjAAUIaxc3DAAwAQAmAAQIdRNdCQAnAQAAAA==.',['棂花']='棂花蝶舞:BAAALAAECgYIBgAAAA==.',['楽鸽']='楽鸽:BAABLAAFFH8tAAMIAAYISBP9BwAcAQAJAAYI1xEFJACFAQAIAAUINBL9BwAcAQAAAA==.',['機械']='機械絑儒:BAAALAAECgYIBgAAAA==.',['欣欣']='欣欣好宝贝:BAAALAAECgYIDwAAAA==.',['欧雷']='欧雷:BAAALAADCgIIAgAAAA==.',['欺雪']='欺雪凌霜:BAABLAAFFH8GAAIZAAYIlwHbDACOAAAZAAYIlwHbDACOAAAAAA==.',['正义']='正义审判者:BAAALAAECgYIDAAAAA==.',['正道']='正道滄桑:BAABLAAECn8WAAIMAAgIghmPSwBbAgAMAAgIghmPSwBbAgAAAA==.',['此生']='此生固短:BAABLAAECn8xAAMBAAgI5hyxIgAuAgABAAgI/huxIgAuAgAcAAcIFxpQCQDIAQAAAA==.',['武财']='武财神:BAAALAAFFAIIAgAAAA==.',['死亡']='死亡丨骑士:BAAALAADCggIDgAAAA==.死亡宣告:BAAALAAFFAQIBAAAAA==.',['汤汤']='汤汤水水:BAAALAAECgIIAgAAAA==.',['沃尔']='沃尔科夫:BAAALAAECgYIEQAAAA==.',['沙度']='沙度丶:BAAALAAFFAIIAgAAAA==.',['法丝']='法丝不是很累:BAAALAAECgQIBAAAAA==.',['法修']='法修散打:BAAALAAECgUIBQAAAA==.',['法師']='法師丶:BAAALAADCggICAAAAA==.',['泡泡']='泡泡小小:BAABLAAFFH8HAAIMAAIImgVKfQAzAAAMAAIImgVKfQAzAAABLAAFFAYIJwALAIAIAA==.泡泡蝴蝶:BAABLAAFFH8nAAILAAYIgAhFHwBQAQALAAYIgAhFHwBQAQAAAA==.',['泻满']='泻满太平洋:BAAALAAECgMIAwAAAA==.',['洛琪']='洛琪希:BAAALAAFFAEIAQABLAAFFAcINwALAD8jAA==.',['洛蕯']='洛蕯之光:BAAALAADCgQICAAAAA==.',['流星']='流星坠落:BAABLAAFFH85AAQEAAYIYBguEgCtAQAEAAYIYBguEgCtAQAFAAYIQhc3EQBgAQAdAAYIMxWiAgBgAQAAAA==.',['流雲']='流雲:BAABLAAFFH8OAAIgAAYIFhbXGwCWAQAgAAYIFhbXGwCWAQAAAA==.',['浣花']='浣花洗剑:BAACLAAFFH8OAAQfAAII4xG1BABMAAAWAAIIaAKbTQBtAAAfAAIIphC1BABMAAATAAIIxAcPOQAmAAAsAAQKfyYABB8ABwhOFvcQAMUBAB8ABgi0GPcQAMUBABMABgjsCK9xAMMAABYAAQjtB1kYASIAAAEsAAUUBggzACcAHAYA.',['淡淡']='淡淡的雨:BAACLAAFFH8QAAILAAIIKAsQOACDAAALAAIIKAsQOACDAAAsAAQKfzAAAgsABwjeGME9AOIBAAsABwjeGME9AOIBAAAA.',['深海']='深海海鲜:BAAALAAFFAIIBAAAAA==.',['深渊']='深渊之喉:BAAALAAECggIEAAAAA==.',['清粥']='清粥小菜:BAACLAAFFH8OAAMiAAIIihrmBACZAAAiAAIIqxnmBACZAAABAAIIpQ5vmQBBAAAsAAQKfxcAAyIABgitHh8LAPkBACIABgiGHB8LAPkBAAEAAggxHtEaAVsAAAEsAAUUBggzACcAHAYA.',['清风']='清风明月:BAACLAAFFH8zAAMnAAYIHAbnDQDFAAAnAAYIGwbnDQDFAAAQAAII3wQ5FwByAAAsAAQKfx0AAycACAjxDn4oAEwBACcACAiRDX4oAEwBABAABQihCspUAK4AAAAA.',['溧阳']='溧阳中关村:BAABLAAFFH8ZAAITAAYIaw/vEwAhAQATAAYIaw/vEwAhAQAAAA==.溧阳凤凰公园:BAABLAAFFH8ZAAITAAYIxxAdFAAfAQATAAYIxxAdFAAfAQAAAA==.溧阳西郊公园:BAABLAAFFH8dAAITAAUIZRBQFwDzAAATAAUIZRBQFwDzAAAAAA==.',['满江']='满江红:BAAALAADCgYIBgAAAA==.',['灬伊']='灬伊卡丶洛斯:BAAALAAECgYIEQAAAA==.',['灬影']='灬影伊:BAAALAADCgYIDAAAAA==.',['灵儿']='灵儿的小小我:BAAALAAECgYIDwAAAA==.',['灵月']='灵月馨香:BAAALAAFFAIIBAAAAA==.',['炎之']='炎之审判:BAAALAAECgcIEgAAAA==.',['炫舞']='炫舞哥:BAAALAADCgEIAQAAAA==.',['烈焰']='烈焰神术:BAAALAAECgcIDgAAAA==.',['烟花']='烟花飞火:BAABLAAFFH8JAAIBAAYIihZdLgB9AQABAAYIihZdLgB9AQABLAAFFAYIIQAUADAkAA==.',['熊猫']='熊猫萨满:BAAALAAFFAIIAwAAAA==.',['燕燕']='燕燕发飙:BAAALAADCgIIAgAAAA==.',['爱丶']='爱丶悦:BAAALAADCgYIBgAAAA==.',['爸爸']='爸爸可以哦:BAACLAAFFH8MAAMNAAUI7AfpTAD3AAANAAUI7AfpTAD3AAAZAAIIAgigFACGAAAsAAQKfxQAAxkABwh0GrkcANQBABkABwicFbkcANQBAA0ABwjQF9VUAEkBAAAA.',['牛三']='牛三刀:BAAALAADCggIDAAAAA==.',['牛百']='牛百叶:BAABLAAFFH8RAAMGAAMIixSXFQCwAAAGAAMIixSXFQCwAAAMAAII6RbCWwBIAAAAAA==.',['牛逼']='牛逼哄哄:BAAALAAECgQIBwAAAA==.牛逼哄哄红码:BAAALAAECgYIBwAAAA==.',['狂风']='狂风冷寂:BAAALAAFFAYIAwAAAA==.狂风战圣:BAAALAAFFAIIBAAAAA==.狂风神龍:BAABLAAFFH8NAAMMAAYIHhhBBgACAgAMAAYIHhhBBgACAgAGAAEIKQaiLwA4AAAAAA==.狂风神龙:BAAALAAECgYIDgAAAA==.狂风隐侠:BAABLAAECn8ZAAISAAcIoBZADgCAAQASAAcIoBZADgCAAQAAAA==.狂风雷霆:BAABLAAFFH8GAAMKAAUIwQ7VJQAYAQAKAAUIwQ7VJQAYAQAHAAEIhQcefgAqAAAAAA==.',['狐火']='狐火:BAAALAAECgIIAgAAAA==.',['独逥']='独逥:BAABLAAECn8bAAIKAAYIXhpXTgDQAQAKAAYIXhpXTgDQAQABLAAFFAIICgAeAPgbAA==.',['狼忈']='狼忈:BAAALAADCgYIBgAAAA==.',['猫熊']='猫熊人:BAAALAAECgYIBgAAAA==.',['猫猫']='猫猫酱:BAAALAAECgIIAgAAAA==.',['玉腿']='玉腿肩上扛:BAABLAAFFH8hAAMVAAYIZRfbAQB9AQAVAAYI/A7bAQB9AQAUAAUI1RaaHQBEAQAAAA==.',['王初']='王初初:BAAALAAFFAIIAgAAAA==.',['玛莲']='玛莲妮娅:BAABLAAFFH8IAAIMAAIIZRXrWgBJAAAMAAIIZRXrWgBJAAAAAA==.',['疯之']='疯之光铸:BAAALAAECgYIBgAAAA==.',['疯狂']='疯狂若雨:BAAALAADCgUIBQAAAA==.',['白猫']='白猫绿水:BAAALAADCgIIAgAAAA==.',['盛夏']='盛夏之处:BAAALAADCgQIBAAAAA==.',['相思']='相思重上楼:BAAALAAFFAIIAwAAAA==.',['盾痴']='盾痴:BAAALAAECgYICAAAAA==.',['真是']='真是小矮子:BAAALAAECgYIBgAAAA==.',['磁力']='磁力棒:BAACLAAFFH8IAAMMAAYInBPJHwBqAQAMAAYIig/JHwBqAQAbAAII+RwOFgBJAAAsAAQKfxUABAwACAiEIdU4AJECAAwACAiSHtU4AJECABsABgh8IBANANIBAAYAAQjIB7h+ACkAAAAA.',['祐天']='祐天寺若麦:BAAALAAECgcIBwAAAA==.',['神乐']='神乐:BAABLAAFFH8KAAMLAAcI2RWjIABDAQALAAUIURCjIABDAQARAAMIURJ6GQDlAAAAAA==.',['神术']='神术:BAAALAAECggICAAAAA==.',['神的']='神的点心:BAAALAADCggICAAAAA==.',['神箭']='神箭丘比特:BAABLAAFFH8LAAIBAAYIPQHXowA9AAABAAYIPQHXowA9AAAAAA==.',['秋季']='秋季萧雨:BAABLAAFFH8UAAQGAAYI5B87CQD0AQAGAAYI5B87CQD0AQAMAAII9hM/SACYAAAbAAIIyyAJFABVAAAAAA==.',['秋月']='秋月无痕:BAAALAADCgUIBQAAAA==.',['秋风']='秋风荡漾:BAAALAAECgIIAwAAAA==.',['竖士']='竖士:BAAALAAECgYIBgAAAA==.',['竹林']='竹林涧小兔兔:BAAALAAECgYICwAAAA==.',['笨丁']='笨丁丁:BAAALAAFFAIIAgAAAA==.',['米奈']='米奈拉丝:BAAALAAECgUIBQAAAA==.',['米果']='米果果:BAAALAAECgYIBgAAAA==.',['粉笔']='粉笔学校才有:BAABLAAFFH8HAAILAAUI6gROKADsAAALAAUI6gROKADsAAAAAA==.',['粉红']='粉红蕾丝罩:BAAALAADCgIIAgAAAA==.',['粉色']='粉色乳红头:BAAALAAECgYIBwAAAA==.粉色乳红头丶:BAABLAAFFH8FAAQkAAIILQtMCACCAAAkAAIIbAVMCACCAAAKAAEI6xGOPABLAAAHAAIIRwGmcABIAAAAAA==.',['精灵']='精灵的德鲁猪:BAAALAAECgYIDAAAAA==.',['糯米']='糯米糍粑:BAAALAADCgYIBgAAAA==.',['索拉']='索拉卡的救赎:BAAALAAFFAIIAgAAAA==.',['紫星']='紫星夢境丷:BAAALAAECgYICQAAAA==.',['紫枫']='紫枫飘零:BAAALAAFFAIIBAABLAAFFAIICAARAKEdAA==.',['紫色']='紫色幽林:BAAALAAECgYIDwAAAA==.',['紫苏']='紫苏青柠:BAABLAAECn8WAAINAAYI7hk0PACNAQANAAYI7hk0PACNAQAAAA==.',['紫血']='紫血冰枫:BAACLAAFFH8IAAIRAAIIoR3kFwCzAAARAAIIoR3kFwCzAAAsAAQKfycAAhEABgiuI5QfAHYCABEABgiuI5QfAHYCAAAA.',['紫雨']='紫雨俊:BAAALAAECgYIDAAAAA==.紫雨濛:BAAALAAECgYIBgAAAA==.',['红袖']='红袖添乱:BAABLAAFFH8MAAMfAAIIyxbjAwCgAAAfAAIIyxbjAwCgAAAWAAIIThHbTABHAAABLAAFFAMIEQAGAIsUAA==.',['纳兹']='纳兹米:BAAALAAECgQIBgAAAA==.',['给桃']='给桃子的信:BAAALAAECgMIAwAAAA==.',['维鲁']='维鲁莎多:BAAALAAECggICAAAAA==.',['绿儿']='绿儿龙骑士:BAABLAAFFH8IAAIGAAIIEBFbJQB3AAAGAAIIEBFbJQB3AAAAAA==.',['绿色']='绿色圣骑树:BAAALAADCgMIAwAAAA==.',['罗祖']='罗祖:BAABLAAFFH8IAAIUAAII4Ar8SACMAAAUAAII4Ar8SACMAAAAAA==.',['罗莉']='罗莉之星:BAAALAAECgYIDAAAAA==.',['美丽']='美丽加芬:BAABLAAFFH8JAAIMAAMIexIcMACrAAAMAAMIexIcMACrAAAAAA==.',['肆伍']='肆伍陆七酱:BAAALAADCgEIAQAAAA==.',['腿毛']='腿毛飘飘:BAAALAAECgYIBgAAAA==.',['自摸']='自摸双翻东:BAAALAAECgYIDAAAAA==.',['艰苦']='艰苦时刻:BAAALAADCgIIAgAAAA==.',['色眯']='色眯眯的小德:BAABLAAECn8dAAIFAAgI4xA1KQAuAQAFAAgI4xA1KQAuAQAAAA==.色眯眯的小鱼:BAABLAAECn8aAAQZAAgIqwmCFADiAAAOAAgI+wQVMAD8AAAZAAQIHg6CFADiAAANAAYILAfXhADhAAAAAA==.色眯眯的渔:BAAALAAECgUIBwAAAA==.色眯眯的猎手:BAAALAAECgYIEwAAAA==.色眯眯的魚:BAAALAAECgYIEgAAAA==.色眯眯的鱼:BAABLAAFFH8HAAMUAAUI9xcKOQAnAQAUAAUI9xcKOQAnAQAVAAEIYwFMCwAgAAAAAA==.',['色虐']='色虐小魅魔:BAAALAAECgMIAQAAAA==.',['色迷']='色迷迷的鱼:BAABLAAECn8YAAMHAAgICxoqMwBHAgAHAAgICxoqMwBHAgAKAAQINBPGWACvAAAAAA==.',['艾娃']='艾娃:BAABLAAFFH8RAAIBAAMI6xaLSACbAAABAAMI6xaLSACbAAABLAAFFAMIEQAGAIsUAA==.',['艾布']='艾布拉姆斯:BAAALAAECgYIDQAAAA==.',['艾紗']='艾紗:BAAALAAECgYIEgAAAA==.',['艾萨']='艾萨:BAABLAAECn8YAAIUAAYIxwv/ngA+AQAUAAYIxwv/ngA+AQAAAA==.',['花开']='花开半夏:BAABLAAECn8dAAIBAAcI7h2/MwDwAQABAAcI7h2/MwDwAQAAAA==.',['花花']='花花仙子:BAAALAAECgYIEgAAAA==.',['英梨']='英梨梨:BAAALAAECgIIAgAAAA==.',['莫浚']='莫浚:BAABLAAECn8WAAIeAAgIRA2fRwBSAQAeAAgIRA2fRwBSAQAAAA==.',['菊花']='菊花怪七号:BAABLAAFFH8PAAMSAAYIBRedCACQAQASAAYIBRedCACQAQAXAAEIPA14HQBAAAAAAA==.',['菜菜']='菜菜摆烂王:BAAALAAECgYIBgAAAA==.',['菲菲']='菲菲仙子:BAAALAADCgMIAwAAAA==.',['萌德']='萌德突袭队:BAAALAAECgYIBgAAAA==.',['蒂垭']='蒂垭波尔:BAAALAAFFAIIAgAAAA==.',['蒂雅']='蒂雅波尔:BAAALAAFFAIIAgAAAA==.',['蒜泥']='蒜泥啵啵浆水:BAACLAAFFH8hAAIPAAUIVxpNCQCGAQAPAAUIVxpNCQCGAQAsAAQKfx0AAg8ACAh6IJ8PAHECAA8ACAh6IJ8PAHECAAAA.',['蒜蓉']='蒜蓉甜胚子:BAABLAAFFH8aAAIGAAUIKxbVEQBrAQAGAAUIKxbVEQBrAQAAAA==.',['藤井']='藤井树:BAACLAAFFH80AAMcAAcIKR5KAQBXAgAcAAYIOyBKAQBXAgABAAcIshoHGQDSAQAsAAQKfzMAAxwACAi9JBAGADoDABwACAi9JBAGADoDAAEABgiuHs6jABQBAAAA.',['虚影']='虚影之尘:BAAALAAFFAIIAgAAAA==.',['虚空']='虚空游隼:BAAALAADCgEIAQAAAA==.',['虾仁']='虾仁不眨眼:BAAALAADCgYICQAAAA==.',['血月']='血月殇:BAAALAAECgYIDQAAAA==.',['袍哥']='袍哥:BAAALAAECgUIBQAAAA==.',['被圣']='被圣光灌注惹:BAABLAAFFH8LAAIMAAUIHgrcHwDTAAAMAAUIHgrcHwDTAAAAAA==.',['西柚']='西柚沙拉丶:BAACLAAFFH8NAAIKAAUI1xksIQA3AQAKAAUI1xksIQA3AQAsAAQKfyEAAwoACAgUIzYHALACAAoACAgUIzYHALACAAcABgivDYzHAPgAAAAA.',['诅咒']='诅咒丶:BAACLAAFFH8dAAIUAAUIwBnwJwDtAAAUAAUIwBnwJwDtAAAsAAQKfyUAAxQACAiqHmsyAHICABQACAiqHmsyAHICAB4ABAgBFfFjAOgAAAAA.',['诗意']='诗意江山:BAAALAAECgMIBQAAAA==.',['诗歌']='诗歌除外:BAAALAADCggICQABLAAFFAYIMwAnABwGAA==.',['诗雨']='诗雨磬竹:BAAALAAFFAIIBAAAAA==.',['诶呜']='诶呜禾牛:BAABLAAFFH8IAAMhAAIIPBerCgCnAAAhAAIIPBerCgCnAAAEAAEIlArOTwA0AAAAAA==.',['谢尔']='谢尔盖:BAABLAAFFH8FAAICAAUIugOGCwCHAAACAAUIugOGCwCHAAAAAA==.',['豆鼓']='豆鼓:BAAALAAECgMIBAAAAA==.',['赫卡']='赫卡忒:BAAALAAFFAEIAQAAAA==.',['超级']='超级变便便:BAABLAAFFH8KAAIEAAIInhaRPAB9AAAEAAIInhaRPAB9AAAAAA==.超级懒人:BAAALAAFFAQIBAAAAA==.',['跑得']='跑得慢:BAAALAAFFAIIBAAAAA==.',['踏歌']='踏歌冰雪:BAABLAAFFH8aAAMKAAUIPBBQJgAUAQAKAAUIPBBQJgAUAQAkAAEItQYzBwBGAAAAAA==.踏歌飞雪:BAAALAAFFAIIAgAAAA==.',['踏浪']='踏浪者:BAAALAADCgUIBQAAAA==.',['踏风']='踏风者:BAAALAADCgQIBAAAAA==.',['达令']='达令哥:BAAALAAECgYICAAAAA==.',['这个']='这个小崽很酷:BAABLAAFFH8TAAMJAAYIciUREAD6AQAJAAYIciUREAD6AQAaAAEIvBvKCQBVAAAAAA==.',['迪剋']='迪剋牛仔:BAABLAAFFH8LAAINAAUIKhTsRgAeAQANAAUIKhTsRgAeAQAAAA==.',['迷人']='迷人小祖宗:BAAALAAFFAgIBAAAAA==.',['迷糊']='迷糊的麋鹿吖:BAABLAAFFH8hAAIHAAYI5g0BKAAjAQAHAAYI5g0BKAAjAQABLAAFFAYIJwALAIAIAA==.',['遇女']='遇女醒精:BAAALAAECgIIAgAAAA==.遇女醒茎:BAAALAADCgYIBgAAAA==.',['道临']='道临哥:BAAALAAFFAIIAgAAAA==.',['遠方']='遠方传来風笛:BAACLAAFFH8hAAMWAAYIuR6DFAC3AQAWAAYIuR6DFAC3AQAfAAEICiTfBgBpAAAsAAQKfxsAAhYACAiUI+UKAKMCABYACAiUI+UKAKMCAAAA.',['選擇']='選擇性乁夨憶:BAAALAADCgMIAwAAAA==.',['那你']='那你先哄她吧:BAAALAADCgEIAQAAAA==.',['邪恶']='邪恶神杖:BAAALAADCggICAAAAA==.',['部落']='部落小学生:BAAALAAECgEIAQAAAA==.',['酒肆']='酒肆梦桃夭:BAAALAAFFAMIAgAAAA==.',['醉后']='醉后缠眠:BAACLAAFFH8rAAQUAAYIdBzIIACZAQAUAAYIdBzIIACZAQAVAAEIWg1sCABOAAAeAAIIzQnJEgBHAAAsAAQKfx4AAhQACAgJIfseANICABQACAgJIfseANICAAAA.',['银色']='银色弹丸龙:BAAALAADCgcIBwAAAA==.',['锤打']='锤打大萌德:BAAALAADCgcIFAABLAAFFAgICAAPAAAAAA==.',['长征']='长征之旅:BAAALAAECgIIAgAAAA==.长征部落之旅:BAAALAAECgYIEgAAAA==.',['阿佛']='阿佛洛狄忒:BAAALAAECgUIAwAAAA==.',['阿坤']='阿坤:BAAALAAECgEIAQAAAA==.',['阿塔']='阿塔兰塔:BAAALAAECgEIAQAAAA==.',['阿波']='阿波克烈:BAAALAADCggICAAAAA==.',['阿泰']='阿泰尔:BAAALAAECgUICAAAAA==.',['阿白']='阿白白丶:BAACLAAFFH8bAAIgAAYIMB+kEgDMAQAgAAYIMB+kEgDMAQAsAAQKfxQAAiAABghrI1tMADwCACAABghrI1tMADwCAAEsAAUUBwg0ABwAKR4A.',['阿米']='阿米娅:BAAALAADCgcIBwAAAA==.',['雅诗']='雅诗兰黛:BAAALAAECgEIAQAAAA==.',['雨天']='雨天的思念:BAABLAAFFH8IAAMRAAYIchKoCwCKAQARAAUI9w6oCwCKAQALAAMITQO6RwBLAAAAAA==.',['雪爪']='雪爪飞鸿:BAABLAAECn8YAAMBAAYIZRN5fwBIAQABAAYIZRN5fwBIAQAiAAEIzwqYJQA6AAAAAA==.',['雪雪']='雪雪恶魔:BAAALAADCgUIBgAAAA==.',['零度']='零度炫舞:BAAALAAECgYIBgAAAA==.',['露蓰']='露蓰翽:BAAALAAECgcIDwAAAA==.',['霸罢']='霸罢:BAAALAAECgMIAwAAAA==.',['青柠']='青柠蜜桃:BAABLAAECn8ZAAMHAAYI1R06IgDsAQAHAAYI1R06IgDsAQAKAAYIWg+YegBQAQAAAA==.',['青树']='青树湖都:BAACLAAFFH8ZAAILAAYIZRnOEgDDAQALAAYIZRnOEgDDAQAsAAQKfxkAAgsACAhVG4IrADcCAAsACAhVG4IrADcCAAAA.',['顶牛']='顶牛牛:BAAALAAECgYIBgAAAA==.',['顶级']='顶级捕食者:BAABLAAFFH8FAAIhAAMIOh5eBQARAQAhAAMIOh5eBQARAQAAAA==.',['风中']='风中樱:BAAALAAECgMIAwAAAA==.',['风滢']='风滢:BAABLAAECn8XAAMLAAYIkQgJRgDEAAALAAYIkQgJRgDEAAARAAMIvAZcRwBIAAAAAA==.',['风语']='风语者德克萨:BAABLAAFFH8VAAQEAAUIHx28EwCcAQAEAAUIHx28EwCcAQAhAAIIJhICCQC1AAAFAAEI/gSKNQA6AAAAAA==.',['风铃']='风铃雪:BAAALAAECgYIBgAAAA==.',['飘风']='飘风落叶情:BAAALAAECgIIAgAAAA==.',['飞飞']='飞飞天使:BAAALAAECgIIAQAAAA==.',['饶孙']='饶孙弟:BAABLAAECn8gAAINAAcIwhQ4tACpAQANAAcIwhQ4tACpAQAAAA==.',['香草']='香草可颂:BAABLAAECn8aAAIMAAYI8SAfMADSAQAMAAYI8SAfMADSAQAAAA==.',['骑士']='骑士马库斯:BAAALAADCgEIAQAAAA==.',['骑马']='骑马与砍杀:BAAALAAECgYIEwAAAA==.',['魅影']='魅影:BAAALAAECgMIBQAAAA==.',['魔刺']='魔刺:BAAALAADCgMIAwAAAA==.',['魔影']='魔影暗语:BAACLAAFFH8hAAIUAAYIMCQkBgBWAgAUAAYIMCQkBgBWAgAsAAQKfxwAAxQABghjJp0WACoCABQABghBJp0WACoCABUAAggfIlcnAK4AAAAA.',['黄衣']='黄衣的阿肥:BAABLAAFFH8tAAMcAAYIchYlBwBYAQAcAAYIRxQlBwBYAQABAAYI9Q9zOwBVAQAAAA==.',['黑夜']='黑夜吻白天:BAAALAAECgYIBgAAAA==.黑夜问白天:BAABLAAFFH8GAAIIAAIIWB+1CQC1AAAIAAIIWB+1CQC1AAABLAAFFAIICAARAKEdAA==.',['黑帝']='黑帝斯:BAABLAAFFH8GAAInAAYIwwCoGACNAAAnAAYIwwCoGACNAAAAAA==.',['黑松']='黑松露:BAAALAAECggICgAAAA==.',['黑白']='黑白祗鸦:BAABLAAFFH8kAAMNAAYIkQx+PQBFAQANAAYIYQp+PQBFAQAOAAUI2gpPEQDTAAAAAA==.',['黑瞳']='黑瞳浩軒:BAAALAAECgIIAQAAAA==.',['黑色']='黑色柳丁:BAAALAAECgEIAQAAAA==.',['黑鐵']='黑鐵丶戰士:BAAALAAECgYIBgAAAA==.',['齐静']='齐静春:BAAALAADCgIIAgAAAA==.',['龙妈']='龙妈:BAAALAAECgYIBgAAAA==.',['龙胧']='龙胧陇珑拢:BAAALAAECgYIDAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end