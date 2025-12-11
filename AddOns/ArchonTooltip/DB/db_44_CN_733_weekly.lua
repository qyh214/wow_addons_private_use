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
 local lookup = {'DemonHunter-Havoc','Rogue-Assassination','Warrior-Protection','Hunter-BeastMastery','Paladin-Protection','Paladin-Retribution','Druid-Restoration','Priest-Holy','Druid-Guardian','Priest-Shadow','Paladin-Holy','Shaman-Restoration','Evoker-Preservation','DeathKnight-Frost','Mage-Arcane','Mage-Frost','Warlock-Demonology','Monk-Brewmaster','Evoker-Augmentation','Shaman-Elemental','Warrior-Fury','Warlock-Destruction','Evoker-Devastation','Druid-Feral','Druid-Balance','Hunter-Marksmanship','DemonHunter-Vengeance','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Affliction','Rogue-Subtlety','Shaman-Enhancement','Mage-Fire','Monk-Mistweaver',}; local provider = {region='CN',realm='海加尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Accuracysiyi:BAAALAADCggICAAAAA==.',An='Anye:BAAALAAECgYIBgAAAA==.',As='Asi:BAAALAAECgQIBAAAAA==.',Bl='Blackbird:BAAALAADCgUIBQAAAA==.Blackdh:BAABLAAECn8VAAIBAAYIIB3HKAC4AQABAAYIIB3HKAC4AQAAAA==.Blackdk:BAAALAAECgYIEAAAAA==.Blackhorseq:BAABLAAECn8WAAICAAYIeh0SDQCSAQACAAYIeh0SDQCSAQAAAA==.Blackmonk:BAAALAAECgYIBgAAAA==.Blackq:BAAALAAECgQICAAAAA==.Blackshaman:BAAALAAECgYIDgAAAA==.Blackss:BAAALAAECgYIBgAAAA==.',Br='Bruce:BAABLAAFFH8GAAIDAAQIoRQZGgDGAAADAAQIoRQZGgDGAAAAAA==.',Ch='Chan:BAAALAAFFAIIAwAAAA==.',Cl='Closer:BAAALAAECggICAAAAA==.',Co='Coldinrain:BAAALAADCgYIBgAAAA==.Combust:BAABLAAFFH8hAAIEAAYIpxuEKQCOAQAEAAYIpxuEKQCOAQAAAA==.Conch:BAAALAADCgEIAQAAAA==.Conquestsiyi:BAAALAADCgYIBgAAAA==.',De='Destroyer:BAAALAAECgYICgAAAA==.',Do='Domo:BAAALAAECggICAAAAA==.',Ea='Easondlucky:BAAALAAECgYIBgAAAA==.',Em='Emilian:BAAALAAECgIIAgAAAA==.',Fe='Fengrui:BAAALAAFFAEIAQAAAA==.',Fi='Fireworm:BAAALAAECgIIAgAAAA==.',Fo='Foogy:BAAALAAECgMIAwAAAA==.',Ge='Genseiliane:BAAALAAECgQIBAAAAA==.Geraltzrivii:BAABLAAFFH8jAAIEAAcIXiAVCgBBAgAEAAcIXiAVCgBBAgAAAA==.',He='Hecateæ:BAACLAAFFH8VAAMFAAUIYRASCwDxAAAFAAUIYRASCwDxAAAGAAMIrQIkTwBaAAAsAAQKfx0AAwYABgjbGdlSAGcBAAYABgjFGdlSAGcBAAUABgj7D/AjAPIAAAAA.Hendry:BAABLAAFFH8JAAIHAAMIAQ8kHQCuAAAHAAMIAQ8kHQCuAAAAAA==.',Ho='Holyz:BAABLAAFFH8MAAIIAAMI5BkqIgCyAAAIAAMI5BkqIgCyAAAAAA==.',Hu='Humankeeper:BAABLAAFFH8VAAIJAAUI/wziBQC2AAAJAAUI/wziBQC2AAABLAAFFAUIFgADAIwKAA==.',In='Intriguing:BAACLAAFFH8JAAIIAAUIhBQIHABuAQAIAAUIhBQIHABuAQAsAAQKfyAAAwgACAhyGssTAC8CAAgACAhyGssTAC8CAAoABggBExEjAC0BAAEsAAUUBggiAAsAAhUA.',Jo='Joker:BAAALAAECgYIDwAAAA==.',La='Lalaguer:BAAALAAFFAIIAgAAAA==.',Le='Leotherass:BAAALAADCgYIBgAAAA==.',Ma='Magicstar:BAAALAADCgcIBwAAAA==.',Mi='Mightyhunter:BAABLAAFFH8LAAIEAAMIsSEKNgC4AAAEAAMIsSEKNgC4AAAAAA==.Minx:BAAALAAECgUIBwAAAA==.',Mo='Moonbow:BAABLAAFFH8MAAIHAAII+RVRKgCDAAAHAAII+RVRKgCDAAAAAA==.Moonlight:BAABLAAFFH8HAAIIAAIIlxAeNgCGAAAIAAIIlxAeNgCGAAAAAA==.Moonlit:BAABLAAFFH8HAAIMAAII3x22LQCnAAAMAAII3x22LQCnAAAAAA==.',Na='Nail:BAABLAAFFH8dAAIIAAYIFhCVGwByAQAIAAYIFhCVGwByAQAAAA==.Naturesiyi:BAAALAAECgIIAgAAAA==.',Ni='Ninelie:BAAALAAECgMIAwAAAA==.Nivs:BAAALAAFFAIIAgAAAA==.',Ob='Oblivionis:BAAALAAECgIIAgABLAAFFAYIFwANAHYXAA==.',Oo='Oopsmomo:BAAALAAFFAYIBAAAAA==.',Oy='Oyeah:BAAALAAFFAIIAgAAAA==.Oyster:BAABLAAFFH8HAAIOAAIIVAsQiACBAAAOAAIIVAsQiACBAAAAAA==.',Pa='Packy:BAAALAAECgYIDAAAAA==.Pal:BAAALAAFFAIIBAAAAA==.',Pl='Playerdswadh:BAAALAADCggICAAAAA==.',Pr='Praddo:BAAALAAECgMIAwAAAA==.',Re='Rebroken:BAABLAAECn8cAAMPAAgIiSXwDQArAwAPAAgIviTwDQArAwAQAAQIpiaQGQBWAQAAAA==.',Ro='Roxette:BAAALAAECggICAAAAA==.',Sa='Sandor:BAAALAADCgYIBgAAAA==.Saviorsiyi:BAAALAADCgYIBgAAAA==.',Se='Senko:BAAALAAECggICAAAAA==.Settler:BAAALAAECgYIEgAAAA==.',Sl='Slania:BAAALAAFFAIIAgAAAA==.',Sp='Spicystrip:BAACLAAFFH8IAAIDAAIISQc2KgBpAAADAAIISQc2KgBpAAAsAAQKfx4AAgMACAg2Ebc1ALQBAAMACAg2Ebc1ALQBAAAA.',Te='Teebayy:BAABLAAFFH8FAAIDAAMITQivFACsAAADAAMITQivFACsAAAAAA==.Terranfans:BAAALAAFFAIIAgAAAA==.',Th='Theiaæ:BAAALAAECgYIDAAAAA==.',Vi='Viscum:BAABLAAFFH8KAAIOAAYICRBeOQBWAQAOAAYICRBeOQBWAQAAAA==.',Wa='Wantd:BAAALAAECgYIDQAAAA==.',Wi='Winter:BAAALAAFFAIIAgAAAA==.',Zy='Zyp:BAABLAAFFH8IAAIRAAMIexHYCQCDAAARAAMIexHYCQCDAAAAAA==.',['一丶']='一丶剩光:BAAALAAECgYICAAAAA==.',['一念']='一念一永恒:BAAALAAECgIIAgAAAA==.',['一把']='一把抓:BAAALAAECggIBgAAAA==.',['一木']='一木阿头一:BAACLAAFFH8IAAIOAAMINwz5aAByAAAOAAMINwz5aAByAAAsAAQKfxYAAg4ABwi0FuSvAK8BAA4ABwi0FuSvAK8BAAAA.',['一步']='一步一人:BAAALAADCggICAAAAA==.',['一瞬']='一瞬之光:BAAALAADCgYIBgAAAA==.',['一米']='一米阳光:BAAALAAECgIIAgAAAA==.',['一脚']='一脚踢死你:BAABLAAFFH8cAAISAAUIIRTpEgAZAQASAAUIIRTpEgAZAQAAAA==.',['一首']='一首传世之歌:BAAALAAFFAIIBAAAAA==.',['丁点']='丁点肉肉:BAABLAAFFH8FAAIHAAUI9AR1KADTAAAHAAUI9AR1KADTAAAAAA==.',['七王']='七王爷:BAABLAAFFH8GAAIDAAYIdh6iCQCnAQADAAYIdh6iCQCnAQAAAA==.',['七百']='七百酒:BAABLAAFFH8KAAITAAgIViVBAAD2AgATAAgIViVBAAD2AgAAAA==.',['三元']='三元奶:BAAALAAECgEIAQAAAA==.',['三百']='三百九:BAABLAAFFH8JAAITAAgIlSV5AADZAgATAAgIlSV5AADZAgAAAA==.',['不灭']='不灭狂灵:BAAALAAECggICAAAAA==.',['不用']='不用怜惜我:BAAALAAECgUIBQAAAA==.',['不过']='不过羁绊不在:BAABLAAFFH8lAAMMAAYIiRxBHQByAQAMAAUI3xtBHQByAQAUAAUIuRsAIQA5AQAAAA==.',['丘处']='丘处机:BAAALAAECgIIBAAAAA==.',['丨劣']='丨劣人:BAAALAAECgYIBgAAAA==.',['丨聖']='丨聖丨:BAAALAAECgEIAQAAAA==.',['丶刺']='丶刺:BAABLAAFFH8PAAIEAAUIwg/yUAALAQAEAAUIwg/yUAALAQAAAA==.',['丶呷']='丶呷哺:BAAALAAECgYIDQAAAA==.',['丶幽']='丶幽兰蝶:BAAALAAECgQIBAAAAA==.',['丶朶']='丶朶:BAAALAAFFAIIAgAAAA==.',['丶錵']='丶錵:BAAALAAFFAIIAgAAAA==.',['为了']='为了一粒淡:BAAALAADCgEIAQAAAA==.',['乖乖']='乖乖丁小妹:BAAALAAECgUICQAAAA==.',['九有']='九有钱:BAAALAAECgIIAgAAAA==.',['九百']='九百一:BAABLAAFFH8MAAITAAgIRyVvAADeAgATAAgIRyVvAADeAgAAAA==.',['乱战']='乱战蓝娇:BAABLAAFFH8KAAIVAAQIghFALgDmAAAVAAQIghFALgDmAAAAAA==.',['二郎']='二郎丸:BAABLAAFFH8IAAIVAAIIrx7jNQCYAAAVAAIIrx7jNQCYAAAAAA==.',['云袭']='云袭:BAAALAAFFAIIAgAAAA==.',['云雀']='云雀不渡海:BAAALAAFFAMIAgAAAA==.',['五百']='五百一:BAABLAAFFH8FAAITAAIIPiWzCQDdAAATAAIIPiWzCQDdAAAAAA==.',['亡心']='亡心:BAAALAADCggICAAAAA==.亡心丨射:BAAALAAECgEIAQAAAA==.亡心丨燚:BAAALAAECgYIBgAAAA==.',['京口']='京口瓜洲丶:BAABLAAFFH8GAAIDAAYIMwcPFwD2AAADAAYIMwcPFwD2AAAAAA==.',['京香']='京香茱莉亞:BAAALAAECgYIEAAAAA==.',['亾兦']='亾兦:BAAALAAECggICAAAAA==.',['仁慈']='仁慈的暗牡:BAAALAADCgMIAwAAAA==.',['以德']='以德伏人:BAAALAAECgQIBAAAAA==.',['伊公']='伊公子乂:BAAALAAECggICQAAAA==.',['伏羲']='伏羲仕:BAAALAAECgMIBAAAAA==.',['伯劳']='伯劳:BAAALAAECggIEAAAAA==.',['佐佑']='佐佑为難:BAAALAAECgEIAQAAAA==.',['你也']='你也皮工:BAAALAAFFAYIBAABLAAFFAgIBgAIAKwPAA==.',['保安']='保安丨队长:BAAALAAFFAIIAgAAAA==.',['傲世']='傲世孤狼:BAACLAAFFH8rAAMRAAYIsCHBBAD3AAAWAAYIDR8jGgC8AQARAAQIYBzBBAD3AAAsAAQKfxYAAxYABQi1HyV1AJkBABYABQiQHiV1AJkBABEAAQgPIXwxAFMAAAAA.',['元素']='元素理理:BAAALAADCgUIBwAAAA==.',['光与']='光与暗的抉择:BAABLAAECn8YAAIIAAgIaRzPKQBBAgAIAAgIaRzPKQBBAgABLAAFFAgIIgATADcYAA==.',['光头']='光头翔:BAABLAAFFH8GAAIMAAIIyQIndQBCAAAMAAIIyQIndQBCAAAAAA==.',['光明']='光明大将军:BAAALAAECgYIEwAAAA==.',['光羽']='光羽佳:BAAALAAECgQIBAAAAA==.',['全是']='全是肉:BAAALAAECgUIBQABLAAFFAYIKQAMANMfAA==.',['八百']='八百酒:BAABLAAFFH8KAAITAAgIFiYfAAAKAwATAAgIFiYfAAAKAwAAAA==.',['六百']='六百酒:BAABLAAFFH8WAAITAAgI+iUoAAADAwATAAgI+iUoAAADAwAAAA==.',['其实']='其实:BAACLAAFFH8TAAIGAAII/yBwMgCpAAAGAAII/yBwMgCpAAAsAAQKfxkAAgYACAjDIOMnANICAAYACAjDIOMnANICAAAA.',['兽大']='兽大大兽:BAAALAAFFAIIBAAAAA==.',['兽群']='兽群之王:BAAALAAECgEIAQAAAA==.兽群风暴:BAAALAADCgIIAgAAAA==.',['内牛']='内牛小萨:BAAALAAECgYICgAAAA==.内牛满面:BAAALAAECgIIAgAAAA==.',['冥河']='冥河冥河:BAAALAAECgYIBgAAAA==.',['冬天']='冬天的罗卜:BAAALAAECgMIBAAAAA==.',['冬暖']='冬暖夏凉:BAAALAAFFAIIBAAAAA==.',['冬泉']='冬泉谷的雪:BAAALAAECgYIBgAAAA==.',['冯睿']='冯睿大人:BAAALAAFFAIIBAAAAA==.冯睿大人七世:BAAALAAFFAEIAQAAAA==.冯睿大人五世:BAAALAAECgYIBgAAAA==.',['冰封']='冰封的回忆:BAACLAAFFH8XAAMGAAYIGiGaCgDxAQAGAAYIGiGaCgDxAQALAAMIRAn4IACbAAAsAAQKfxYAAwYACAgkG+Z0AAACAAYACAgkG+Z0AAACAAsAAgguAzxDADcAAAAA.',['冰珑']='冰珑如玉:BAABLAAFFH8MAAIPAAYIvCNmDwAAAgAPAAYIvCNmDwAAAgAAAA==.',['冰风']='冰风沐雪:BAAALAAECgYIBgAAAA==.',['冲钅']='冲钅老头:BAAALAAECgIIAgAAAA==.',['凌晨']='凌晨二刻:BAAALAAFFAIIBAAAAA==.',['凯厄']='凯厄斯:BAACLAAFFH8SAAIGAAUIXRFGLQAbAQAGAAUIXRFGLQAbAQAsAAQKfxQAAgYACAhFHSBQAE8CAAYACAhFHSBQAE8CAAAA.',['凯瑟']='凯瑟琳冰儿:BAABLAAFFH8GAAIPAAYIQw8eEQDdAQAPAAYIQw8eEQDdAQAAAA==.',['分担']='分担难倒:BAAALAAECgYIBgAAAA==.',['刑丶']='刑丶警:BAAALAADCgEIAQAAAA==.',['别划']='别划走:BAABLAAFFH8UAAIEAAYI+hZ3KgCKAQAEAAYI+hZ3KgCKAQAAAA==.',['前夕']='前夕丶骑士:BAABLAAFFH8aAAIGAAUIxRnBJQBHAQAGAAUIxRnBJQBHAQAAAA==.',['勤劳']='勤劳的卡比兽:BAAALAAFFAYIBAAAAA==.',['勺子']='勺子战:BAABLAAFFH8KAAIDAAUIviEbDQBxAQADAAUIviEbDQBxAQAAAA==.勺子梅猫饼:BAABLAAFFH8MAAIEAAUItBx1HAAhAQAEAAUItBx1HAAhAQAAAA==.',['十五']='十五的猩猩:BAABLAAECn8UAAMQAAcIxwpZIwAGAQAQAAcIxwpZIwAGAQAPAAEIMwPqegAdAAAAAA==.',['十六']='十六:BAAALAAFFAYIAwAAAA==.',['半城']='半城煙沙:BAAALAAECgYIBgAAAA==.',['半神']='半神灬恶魔:BAAALAAECgYIBgAAAA==.半神灬沫沫子:BAABLAAFFH8cAAMNAAUIExTfDQBhAQANAAUIExTfDQBhAQAXAAQIbBCjFAC2AAAAAA==.',['卑鄙']='卑鄙的猫丶:BAABLAAFFH8FAAIEAAUIgwwKVwDwAAAEAAUIgwwKVwDwAAAAAA==.',['南丶']='南丶春香:BAAALAAFFAIIAgAAAA==.',['博丽']='博丽魔理沙:BAABLAAECn8aAAIPAAcIlBcOXwDnAQAPAAcIlBcOXwDnAQAAAA==.',['卡尔']='卡尔库克:BAABLAAECn8ZAAIEAAcIaxAuzABvAQAEAAcIaxAuzABvAQAAAA==.',['卡蕾']='卡蕾拉晨风:BAACLAAFFH8bAAIIAAUIfh7MFACuAQAIAAUIfh7MFACuAQAsAAQKfxcAAwgACAh2FyYwACACAAgACAh2FyYwACACAAoABAiwAsiHAIIAAAAA.',['卢天']='卢天惠:BAAALAAECgIIAgAAAA==.',['印象']='印象:BAAALAAECgYIBgAAAA==.',['厄运']='厄运先生:BAACLAAFFH8IAAIOAAIInRkkTQCjAAAOAAIInRkkTQCjAAAsAAQKfyYAAg4ACAgvHwsqAMoCAA4ACAgvHwsqAMoCAAAA.',['厉害']='厉害了:BAAALAAECgUIBQAAAA==.',['去旅']='去旅游吧:BAAALAAECgMIAwAAAA==.',['变牛']='变牛的大子:BAABLAAFFH8GAAMYAAIIiRlMDgCVAAAYAAIInRVMDgCVAAAZAAIIdhZfMABBAAAAAA==.',['叙利']='叙利亚悍妇:BAAALAAECgcIBwAAAA==.',['口狗']='口狗的水手:BAAALAADCgcIBwAAAA==.',['只狼']='只狼:BAAALAADCgIIAgAAAA==.',['叭叭']='叭叭吧吧:BAAALAAFFAIIAgAAAA==.',['吃糖']='吃糖果的猫:BAAALAAFFAIIAgAAAA==.',['咆哮']='咆哮的砖头:BAAALAAECgYIBgAAAA==.',['咕咕']='咕咕哒咕咕哒:BAAALAAFFAIIAgAAAA==.',['咕德']='咕德猫呐:BAABLAAFFH8GAAIHAAUISwK4MgCfAAAHAAUISwK4MgCfAAAAAA==.',['哈瓦']='哈瓦那黄昏:BAAALAAECgQIBAAAAA==.',['唯美']='唯美情殇:BAAALAAFFAIIBAAAAA==.',['善战']='善战的部落丶:BAABLAAFFH8IAAIDAAMIIQLIJwBGAAADAAMIIQLIJwBGAAAAAA==.',['喵喵']='喵喵不是猫:BAABLAAFFH8IAAIMAAIIwhGpSQByAAAMAAIIwhGpSQByAAAAAA==.',['喵妖']='喵妖王:BAABLAAFFH8KAAIMAAIIlA/bXQBfAAAMAAIIlA/bXQBfAAAAAA==.',['嗷嗷']='嗷嗷吵吵:BAAALAAECgYIBgAAAA==.',['嘉衍']='嘉衍:BAAALAAECgcIBwAAAA==.',['嘤灬']='嘤灬嘤嘤:BAABLAAFFH8aAAIWAAYIKA7oMQBPAQAWAAYIKA7oMQBPAQAAAA==.',['嘿蜀']='嘿蜀黍硕:BAAALAAECgYIBgAAAA==.',['噗噗']='噗噗:BAAALAAECgIIAgAAAA==.',['四百']='四百一:BAABLAAFFH8SAAITAAgIfyVoAADiAgATAAgIfyVoAADiAgAAAA==.',['回忆']='回忆一下:BAAALAADCgYIBgAAAA==.',['园板']='园板板:BAAALAADCggICAAAAA==.',['圣辉']='圣辉闪耀:BAAALAAECgUIBQAAAA==.',['在下']='在下乘风而起:BAAALAAFFAIIAwAAAA==.',['在吗']='在吗:BAAALAADCgUIBgAAAA==.',['在坟']='在坟堆跳舞:BAAALAAECgMIAwAAAA==.',['地狱']='地狱嗥叫:BAAALAADCgYIBgAAAA==.',['坚强']='坚强地活下去:BAABLAAFFH8SAAMaAAYI2hN/CACOAQAaAAUIAhF/CACOAQAEAAYIEA8ERAA5AQABLAAFFAgIHAAZAOIkAA==.',['城南']='城南一霸:BAAALAADCgEIAQAAAA==.',['塔哥']='塔哥:BAAALAAECgMIAwAAAA==.',['墮落']='墮落的胖子:BAAALAADCgYIBgAAAA==.',['复刻']='复刻时光:BAABLAAFFH8MAAIFAAIIkA/kGAB1AAAFAAIIkA/kGAB1AAAAAA==.',['多少']='多少惦念:BAACLAAFFH8RAAMEAAYIJB92IwCkAQAEAAYIJB92IwCkAQAaAAMIMRciGQCnAAAsAAQKfxYAAxoABgjLIYU6AM4BABoABgiFG4U6AM4BAAQABAg1JGGpAJ4BAAAA.',['夜乄']='夜乄猫子:BAABLAAFFH8PAAIYAAII5hVMDQCaAAAYAAII5hVMDQCaAAAAAA==.',['夜露']='夜露死苦:BAABLAAFFH8KAAIOAAgISxVBGgDOAQAOAAgISxVBGgDOAQAAAA==.',['夜青']='夜青:BAABLAAFFH8GAAIQAAIIXBgiFgBDAAAQAAIIXBgiFgBDAAAAAA==.',['大声']='大声公:BAABLAAFFH8aAAIPAAUI+hXZMgA0AQAPAAUI+hXZMgA0AQAAAA==.',['大天']='大天尊丶:BAAALAAECgQIBAAAAA==.',['大师']='大师姐:BAABLAAFFH8GAAISAAYIXR4zCQC2AQASAAYIXR4zCQC2AQAAAA==.',['大燕']='大燕儿:BAAALAAECgMIAwAAAA==.',['大猛']='大猛壹:BAAALAAECgYICgAAAA==.',['大连']='大连街达文西:BAAALAAECgEIAQAAAA==.',['大鹏']='大鹏展翅:BAAALAADCgYIBgAAAA==.',['天使']='天使紫罗兰:BAAALAADCgYIBwABLAAFFAgIHwABAEEkAA==.',['头顶']='头顶尖尖:BAAALAADCgIIAgAAAA==.',['奈何']='奈何:BAAALAAECgYIDgABLAAFFAQICwAbAJkEAA==.',['奔跑']='奔跑的小兔子:BAAALAAECgUIBQAAAA==.',['奶丶']='奶丶有毒:BAAALAAFFAEIAQAAAA==.',['奶到']='奶到你死:BAAALAAFFAEIAQAAAA==.',['好耶']='好耶是大冒险:BAABLAAFFH8KAAMZAAgIoBnPDACVAQAZAAYIxxjPDACVAQAHAAII/QgIQABzAAAAAA==.',['始乱']='始乱未二:BAABLAAFFH8VAAIWAAgIHSFWBABzAgAWAAgIHSFWBABzAgAAAA==.始乱未伍:BAAALAAFFAIIAgAAAA==.始乱未拾:BAABLAAFFH8MAAIWAAYIcR8YGQDCAQAWAAYIcR8YGQDCAQAAAA==.始乱未柒:BAABLAAFFH8KAAIWAAcIHx1OCQAqAgAWAAcIHx1OCQAqAgAAAA==.始乱未陸:BAABLAAFFH8GAAIWAAYIHRW+KAB3AQAWAAYIHRW+KAB3AQAAAA==.',['威斯']='威斯特:BAABLAAECn8ZAAIHAAgI4R3kCQCqAgAHAAgI4R3kCQCqAgAAAA==.',['孟德']='孟德雅痞:BAACLAAFFH8YAAMcAAUIzxOuCADxAAAcAAQIxg+uCADxAAAOAAQICRS8UADZAAAsAAQKfxUAAg4ABgiPH5osAMMBAA4ABgiPH5osAMMBAAAA.',['季末']='季末碎心:BAAALAAECgYIDQAAAA==.',['宁宁']='宁宁闹他:BAABLAAECn8UAAIWAAgIrQBLCAEyAAAWAAgIrQBLCAEyAAAAAA==.',['宁静']='宁静致远:BAAALAAECggIDwAAAA==.',['宅妹']='宅妹傻馒:BAABLAAFFH8KAAIMAAII9BU2UgB3AAAMAAII9BU2UgB3AAABLAAFFAYIGAAOAEgiAA==.',['安德']='安德烈丶神射:BAAALAAECgEIAQAAAA==.',['完美']='完美若心:BAAALAAFFAMIBAAAAA==.完美若雪:BAABLAAFFH8WAAIPAAYIzA4NKgBqAQAPAAYIzA4NKgBqAQAAAA==.',['家中']='家中月喵喵:BAAALAAFFAEIAQAAAA==.家中瑶瑶咪:BAAALAADCggICAAAAA==.',['寂寞']='寂寞狐狸:BAACLAAFFH8iAAMLAAYIAhX1DQCmAQALAAYIAhX1DQCmAQAGAAUI8w/8MAD9AAAsAAQKfycAAgsACAjBH5YEAMsCAAsACAjBH5YEAMsCAAAA.寂寞身后事:BAACLAAFFH8HAAIOAAIIlQj+jABAAAAOAAIIlQj+jABAAAAsAAQKfxUAAg4ABggDDQt2AAIBAA4ABggDDQt2AAIBAAAA.',['密林']='密林游侠:BAAALAAFFAMIAwAAAA==.',['寜寜']='寜寜:BAABLAAFFH8GAAIGAAQInhWXMgDuAAAGAAQInhWXMgDuAAAAAA==.',['小动']='小动物:BAAALAAFFAIIAgAAAA==.',['小唏']='小唏姐姐:BAACLAAFFH8rAAMMAAYInhE5HgBqAQAMAAYInhE5HgBqAQAUAAMI7gK3OgBmAAAsAAQKfxkAAgwABgjmFAqEAHgBAAwABgjmFAqEAHgBAAAA.',['小土']='小土人戰士:BAACLAAFFH8WAAIDAAUIjAqxGgC8AAADAAUIjAqxGgC8AAAsAAQKfxsAAxUACAjGFA0+AGIBAAMACAhfD3U/AIYBABUABgheGA0+AGIBAAAA.',['小壞']='小壞氮:BAAALAAFFAIIAgAAAA==.',['小小']='小小兔宝宝:BAABLAAFFH8hAAIGAAYIRR1cFwCXAQAGAAYIRR1cFwCXAQAAAA==.',['小法']='小法的疯狂:BAAALAAECgcIBwAAAA==.',['小爷']='小爷有冰锥:BAABLAAFFH8SAAIPAAYIUAxiLQBXAQAPAAYIUAxiLQBXAQAAAA==.',['小猎']='小猎很可爱:BAABLAAFFH8HAAIEAAIIBxALWwCPAAAEAAIIBxALWwCPAAAAAA==.',['小猴']='小猴子睡猫:BAAALAAECgEIAQAAAA==.',['小疯']='小疯仔:BAACLAAFFH8KAAMMAAQIQBH+QACjAAAMAAMIBxT+QACjAAAUAAMI6wOFOgBoAAAsAAQKfxYAAwwABwgVG81yAJ0BAAwABwgVG81yAJ0BABQAAgj2CKeAACQAAAAA.',['小砑']='小砑:BAAALAAFFAEIAQAAAA==.',['小萝']='小萝卜:BAAALAAECgUIBQAAAA==.',['小萨']='小萨丶润篪:BAAALAAECgQIBAAAAA==.',['小辣']='小辣椒:BAABLAAFFH8GAAIMAAII9hZyUgB2AAAMAAII9hZyUgB2AAAAAA==.',['小锋']='小锋子:BAAALAAECgMIAwAAAA==.',['小鱼']='小鱼吞猫:BAABLAAFFH8IAAMGAAII2Q98gAAtAAAGAAII2Q98gAAtAAAFAAIIZgTdIwAgAAAAAA==.',['小黑']='小黑骑士:BAACLAAFFH8SAAIGAAUIthBCKgAtAQAGAAUIthBCKgAtAQAsAAQKfzgAAwYACAhUG34jAAoCAAYACAhUG34jAAoCAAUABgh3FBg/AD8BAAAA.',['尐猪']='尐猪佩奇:BAAALAAECgUIBQAAAA==.',['巡猎']='巡猎者:BAAALAAECgYIBgAAAA==.',['巨石']='巨石弱森:BAAALAAECgMIAwAAAA==.',['希尔']='希尔瓦納斯:BAAALAADCgIIAgAAAA==.',['希影']='希影丶鸦冠:BAACLAAFFH8LAAIbAAQImQTZDABrAAAbAAQImQTZDABrAAAsAAQKfx0AAxsACAiMDoYUAAwBABsACAhkC4YUAAwBAAEAAwgvEreCAKMAAAAA.',['帕瓦']='帕瓦:BAAALAAECgYIBgAAAA==.',['帥嘚']='帥嘚不朙显:BAAALAADCgMIAwAAAA==.',['带风']='带风的牛:BAAALAAFFAIIBAAAAA==.',['年华']='年华弹指间:BAACLAAFFH8cAAIaAAUIyxYaCQAkAQAaAAUIyxYaCQAkAQAsAAQKfyIAAhoACAgmH1wWALACABoACAgmH1wWALACAAAA.',['幸运']='幸运星:BAAALAAFFAIIBAAAAA==.',['幻灬']='幻灬想:BAAALAAECggICAAAAA==.',['幻龙']='幻龙展翅飞:BAAALAAECgIIAgAAAA==.幻龙破苍穹:BAAALAAECgEIAQAAAA==.',['库克']='库克噜噜:BAAALAAFFAIIAgAAAA==.库克皮皮:BAAALAAECgYIDQAAAA==.',['廵警']='廵警:BAAALAADCgMIAwAAAA==.',['当然']='当然要原谅她:BAAALAAFFAIIAgAAAA==.',['影枫']='影枫:BAACLAAFFH8WAAIPAAYIRg95KwBiAQAPAAYIRg95KwBiAQAsAAQKfxoAAg8ACAi5ExcuAF8BAA8ACAi5ExcuAF8BAAEsAAUUBwgwAAYA9R4A.',['往矣']='往矣矣:BAACLAAFFH8gAAMOAAUIwx8wKgDwAAAOAAUIwx8wKgDwAAAdAAEI3wBgGQArAAAsAAQKfyIAAg4ACAigIPApAMoCAA4ACAigIPApAMoCAAAA.',['征尘']='征尘:BAAALAAECgEIAQAAAA==.',['很小']='很小心:BAAALAAFFAEIAQAAAA==.',['很爱']='很爱阚清子:BAAALAAECgUICAAAAA==.',['得寸']='得寸进分啊:BAAALAAFFAIIBAAAAA==.',['德鲁']='德鲁依门将:BAAALAADCgcIBwAAAA==.',['心弦']='心弦乄梦:BAABLAAFFH8hAAIIAAYIjxdtEwC9AQAIAAYIjxdtEwC9AQAAAA==.心弦乄音:BAAALAAECgIIAgAAAA==.',['心為']='心為誰痛:BAAALAADCgYIBgAAAA==.',['心结']='心结:BAAALAAECgYICAAAAA==.',['怂包']='怂包:BAAALAAECgYIDAAAAA==.',['惡丶']='惡丶:BAAALAADCgIIAgAAAA==.',['惬意']='惬意由心丶:BAAALAAFFAMIAwAAAA==.',['愤怒']='愤怒的匹夫:BAAALAADCgcIBwAAAA==.',['慷慨']='慷慨激昂:BAABLAAFFH8bAAIEAAUIsRovPABTAQAEAAUIsRovPABTAQAAAA==.',['我丑']='我丑我不温柔:BAAALAAFFAIIBAAAAA==.',['我也']='我也是长角的:BAAALAAECgcIDQAAAA==.',['我好']='我好方:BAAALAADCggICAAAAA==.',['我很']='我很丶清纯:BAABLAAFFH8GAAIHAAII8Q9fRwBgAAAHAAII8Q9fRwBgAAAAAA==.',['我怎']='我怎么是武僧:BAAALAAFFAQIAgAAAA==.',['我是']='我是死骑:BAAALAAFFAIIAgAAAA==.我是烈人:BAAALAAFFAIIAwAAAA==.',['我的']='我的咸菜呢:BAAALAADCgUIBQAAAA==.我的哥:BAAALAAECgUICAAAAA==.',['我跑']='我跑的超快的:BAAALAAECgUIBQAAAA==.',['我还']='我还要送:BAAALAADCgQIBAAAAA==.',['战战']='战战站站:BAAALAAFFAIIBAAAAA==.',['战斗']='战斗吧少年:BAAALAAFFAIIBAAAAA==.',['抓住']='抓住那头熊:BAAALAADCggICAAAAA==.',['拉尼']='拉尼亚凯亚:BAABLAAECn8cAAIEAAYIvCMkKAAXAgAEAAYIvCMkKAAXAgAAAA==.',['拉科']='拉科:BAABLAAECn8qAAIEAAYIFxH6mwAfAQAEAAYIFxH6mwAfAQAAAA==.',['拉轟']='拉轟蕞重要:BAAALAAFFAEIAQAAAA==.',['拉轰']='拉轰蕞重要:BAAALAAECgYICwAAAA==.',['拉風']='拉風最重要:BAAALAAECgYIDAAAAA==.',['拜了']='拜了佛冷:BAAALAAECgYIDAAAAA==.',['收割']='收割者:BAAALAADCggIDAAAAA==.',['故事']='故事未完待续:BAAALAAFFAIIAgAAAA==.',['故漓']='故漓:BAABLAAFFH8GAAIPAAIIbRFwVgCKAAAPAAIIbRFwVgCKAAAAAA==.',['斩风']='斩风:BAACLAAFFH8GAAIEAAYIrQ3XSwAdAQAEAAYIrQ3XSwAdAQAsAAQKfxkAAwQABghqIxY0AO8BAAQABghqIxY0AO8BABoAAgirFGueAHoAAAEsAAUUCAgzAA4AWSMA.',['断风']='断风尘:BAABLAAFFH8HAAQeAAYI8Q47AwDqAAAeAAMIBw87AwDqAAAWAAIIVw/dQwCTAAARAAEI5g3pHwAAAAAAAA==.',['无影']='无影迷踪:BAAALAAECgMIAwAAAA==.',['无敌']='无敌圣光:BAAALAAECgYICgAAAA==.',['无月']='无月:BAACLAAFFH8KAAMdAAYI2xB9DQAxAQAdAAYIng59DQAxAQAOAAIIEhplYACYAAAsAAQKfxsAAg4ABgj4IG46AJMBAA4ABgj4IG46AJMBAAAA.',['无极']='无极魔:BAAALAAECggICAAAAA==.',['日怒']='日怒法:BAAALAAFFAIIAgAAAA==.',['星丨']='星丨灿:BAAALAADCgYIBgAAAA==.',['星璨']='星璨:BAAALAAECgYIBgAAAA==.',['是相']='是相思老师呀:BAAALAADCgMIAwAAAA==.',['晓疯']='晓疯子:BAABLAAFFH8OAAMfAAUI0gsgDADAAAACAAUImwriEAD2AAAfAAQIpgkgDADAAAAAAA==.',['晓赫']='晓赫:BAABLAAFFH8ZAAIGAAUIjiHUGQCJAQAGAAUIjiHUGQCJAQAAAA==.',['晴天']='晴天小丹:BAABLAAFFH8GAAIGAAYIVQJqRgCAAAAGAAYIVQJqRgCAAAAAAA==.',['暗影']='暗影萨满卢克:BAABLAAFFH8JAAIUAAIIOyLiIACtAAAUAAIIOyLiIACtAAAAAA==.',['暴怒']='暴怒斩杀:BAABLAAFFH8XAAIVAAUIaR1FHwBwAQAVAAUIaR1FHwBwAQAAAA==.',['曦影']='曦影:BAAALAAECgYIBgAAAA==.',['最容']='最容易遗忘:BAABLAAFFH8WAAIVAAUIoRglIQBjAQAVAAUIoRglIQBjAQAAAA==.',['月亮']='月亮小公主:BAAALAAFFAIIAgAAAA==.月亮的猫:BAAALAAECgQIBAAAAA==.',['月影']='月影兮沉:BAAALAAECgMIAwAAAA==.',['有点']='有点肉肉:BAAALAAECgYICwABLAAFFAYIKQAMANMfAA==.',['有爱']='有爱的死骑:BAAALAAFFAIIBAAAAA==.',['木生']='木生水:BAAALAAFFAIIBAAAAA==.',['木阿']='木阿头:BAAALAAFFAIIBAAAAA==.',['朮學']='朮學老師:BAABLAAFFH8IAAMRAAIIERbTEwBEAAARAAIIERbTEwBEAAAWAAEI8Qu2agA2AAAAAA==.',['朱利']='朱利叶斯欧文:BAAALAAECgQIBAAAAA==.',['朱厌']='朱厌:BAAALAAECgYIBwAAAA==.',['机智']='机智的呆呆兽:BAABLAAFFH8hAAIWAAgIlCaQAAAeAwAWAAgIlCaQAAAeAwAAAA==.',['李小']='李小多:BAAALAAFFAIIAgAAAA==.',['李帝']='李帝一:BAAALAAECgYIBgAAAA==.',['来兮']='来兮:BAAALAADCgMIAwAAAA==.',['来吧']='来吧死神:BAAALAAECggICAAAAA==.',['林北']='林北骑士:BAAALAAECggICAAAAA==.',['果壳']='果壳:BAABLAAFFH8eAAIMAAUI8hMvKAAiAQAMAAUI8hMvKAAiAQAAAA==.',['柯鸡']='柯鸡:BAABLAAFFH8FAAIOAAMIuQLtawBiAAAOAAMIuQLtawBiAAAAAA==.',['树勇']='树勇买买提:BAABLAAFFH8IAAIEAAIIWBGnZACIAAAEAAIIWBGnZACIAAAAAA==.',['栗原']='栗原紗英:BAACLAAFFH8GAAIXAAIIYxBkGQCOAAAXAAIIYxBkGQCOAAAsAAQKfxcAAhcABghbFOs7AFsBABcABghbFOs7AFsBAAAA.',['桅叶']='桅叶:BAAALAAFFAEIAQAAAA==.',['梨树']='梨树落梨花:BAAALAAFFAcIBAAAAA==.',['梵音']='梵音若梦:BAAALAAFFAMIAwAAAA==.',['森海']='森海飞霞:BAABLAAFFH8QAAMEAAUI8hY/TAAcAQAEAAUI8hY/TAAcAQAaAAII6QbhFQBDAAAAAA==.',['橘子']='橘子酒:BAABLAAFFH8GAAIWAAIISwYfUACAAAAWAAIISwYfUACAAAAAAA==.',['橙玥']='橙玥:BAACLAAFFH8NAAIGAAMIoSFmFQAPAQAGAAMIoSFmFQAPAQAsAAQKfxcAAgYACAiJIgkhAO4CAAYACAiJIgkhAO4CAAAA.',['檸檬']='檸檬沙拉:BAABLAAFFH8VAAIKAAUIGAuGGAD1AAAKAAUIGAuGGAD1AAAAAA==.',['欢丶']='欢丶彬彬有理:BAAALAADCgEIAQAAAA==.',['此昵']='此昵称不存在:BAAALAAECgcIDQAAAA==.',['殇之']='殇之刹那:BAAALAADCgcIBwAAAA==.',['残雪']='残雪梦:BAAALAAFFAIIAgAAAA==.',['毁灭']='毁灭之握:BAAALAAECgYIBgAAAA==.',['沉默']='沉默的牧師:BAACLAAFFH8ZAAMKAAUI7gw9GwDGAAAKAAQI1A09GwDGAAAIAAQIFwdAMQClAAAsAAQKfzoAAwoACAgDHcgXAK4CAAoACAgDHcgXAK4CAAgABwi2FPpGALoBAAAA.沉默的魔王:BAACLAAFFH8gAAIVAAUIMhfQJABIAQAVAAUIMhfQJABIAQAsAAQKfygAAhUACAjdIHsSABcDABUACAjdIHsSABcDAAAA.',['沙漏']='沙漏:BAABLAAFFH8KAAMEAAIIrBWCjQBGAAAEAAIIrBWCjQBGAAAaAAEIvg6OHgAAAAAAAA==.',['没有']='没有肉肉:BAABLAAFFH8pAAMMAAYI0x9GDQACAgAMAAYI0x9GDQACAgAUAAYIOB7mDgDLAQAAAA==.',['法湿']='法湿:BAAALAAECgYIDAAAAA==.',['法网']='法网无边:BAAALAAECgMIAwAAAA==.',['泡芙']='泡芙酱:BAAALAADCgcICwAAAA==.',['洗脚']='洗脚水灌汤包:BAAALAADCgcIBwAAAA==.洗脚水熬汤:BAABLAAFFH8XAAIBAAUInhe6JgBaAQABAAUInhe6JgBaAQAAAA==.',['洣澜']='洣澜:BAAALAAECgQIBAAAAA==.',['流星']='流星能飞多久:BAAALAADCgYIBgAAAA==.',['流氓']='流氓乁术:BAABLAAFFH8FAAIWAAIIPQiPbQAyAAAWAAIIPQiPbQAyAAAAAA==.',['流浪']='流浪刀刀:BAABLAAFFH8OAAIDAAIImBPGHgCAAAADAAIImBPGHgCAAAAAAA==.',['浪潮']='浪潮胸涌:BAABLAAFFH8GAAIMAAYIvgCjcQBIAAAMAAYIvgCjcQBIAAAAAA==.',['海贼']='海贼王之俊:BAAALAAECgcICQAAAA==.',['游侠']='游侠之猎:BAACLAAFFH8SAAMEAAUIlgtcWADpAAAEAAUIlgtcWADpAAAaAAMIGQevLgBmAAAsAAQKfxYAAxoACAhMD1FqAB0BABoABgiTDVFqAB0BAAQABghJDDaqAAsBAAAA.',['游戏']='游戏东西:BAAALAAFFAIIAgAAAA==.',['滚叨']='滚叨:BAACLAAFFH8jAAIWAAYIfA2gMABVAQAWAAYIfA2gMABVAQAsAAQKfycAAhYACAg5F6MlAMUBABYACAg5F6MlAMUBAAAA.',['灬众']='灬众神之王灬:BAAALAAFFAQIBAAAAA==.',['灬沐']='灬沐阿头灬:BAAALAAECggIDwAAAA==.',['灬阿']='灬阿木头灬:BAAALAAFFAIIAgAAAA==.',['灵魂']='灵魂相茜:BAAALAAFFAIIAgAAAA==.',['炎龙']='炎龙之魂:BAAALAAECgcIBwAAAA==.',['炯炯']='炯炯有神的眼:BAAALAAECgYICAAAAA==.',['烈焰']='烈焰火鬼:BAABLAAFFH8MAAIfAAIIBRBZEwBKAAAfAAIIBRBZEwBKAAAAAA==.烈焰灬灼心:BAACLAAFFH8nAAIBAAYI8Rz2FQC3AQABAAYI8Rz2FQC3AQAsAAQKfxQAAgEABwg4I/goALoCAAEABwg4I/goALoCAAAA.烈焰灬风暴:BAAALAAFFAIIAgAAAA==.',['烤鸭']='烤鸭帮小妹:BAAALAAECgUICAAAAA==.',['焉知']='焉知子非鱼:BAAALAAECgYICQAAAA==.',['無敵']='無敵:BAAALAAECgYIDAAAAA==.',['熊猫']='熊猫萨满:BAABLAAFFH8HAAMMAAMIdwYGVgBvAAAMAAMIdwYGVgBvAAAUAAIIZQHyUwAoAAAAAA==.',['熙熙']='熙熙:BAAALAADCgIIAgAAAA==.',['燃烧']='燃烧的勇气:BAAALAAECggICAAAAA==.',['爱与']='爱与洗脚:BAAALAAECgIIAgAAAA==.',['爱吃']='爱吃的圆宝:BAAALAAECgYIBgAAAA==.',['爱蜜']='爱蜜莉雅:BAAALAADCgQIBAAAAA==.',['爲了']='爲了坐骑:BAAALAADCgUIBQAAAA==.',['牛浩']='牛浩浩:BAAALAAECgQIBAAAAA==.',['牛肉']='牛肉人人不爱:BAABLAAFFH8QAAIGAAYI0xHvHgBuAQAGAAYI0xHvHgBuAQAAAA==.',['牛霸']='牛霸儿灬:BAABLAAFFH8IAAIVAAUI5ArmKgARAQAVAAUI5ArmKgARAQAAAA==.',['牛黄']='牛黄豆:BAACLAAFFH8RAAMgAAQIhRAyBADVAAAgAAQIhRAyBADVAAAMAAII6hYJSwCGAAAsAAQKfxkAAyAACAinH/4DAPICACAACAinH/4DAPICAAwAAQhfCeNLASoAAAAA.',['牧哦']='牧哦师:BAAALAAECgQIBAAAAA==.',['牧沨']='牧沨:BAAALAAECgYIDwAAAA==.',['牧黎']='牧黎:BAAALAAECgYIBgAAAA==.',['狗丨']='狗丨萨:BAAALAAFFAIIBAAAAA==.',['狗灬']='狗灬黑骑:BAABLAAFFH8IAAIOAAII9wZ3jAB8AAAOAAII9wZ3jAB8AAAAAA==.',['猎心']='猎心小公举:BAAALAADCgIIAgAAAA==.',['猎神']='猎神二黑:BAAALAAFFAQIAgAAAA==.',['猎魔']='猎魔人:BAABLAAFFH8GAAIEAAYIxhKYDQDHAQAEAAYIxhKYDQDHAQAAAA==.猎魔恶手:BAACLAAFFH8cAAIBAAUI0w54LgAlAQABAAUI0w54LgAlAQAsAAQKfxUAAgEACAj8FUJUACcCAAEACAj8FUJUACcCAAAA.',['猫不']='猫不满:BAAALAAECgYIBwAAAA==.',['玉瑾']='玉瑾:BAAALAAECgYIBgAAAA==.',['王力']='王力宏:BAAALAAECgYIBgAAAA==.',['王者']='王者又归来:BAAALAAECgMIAwAAAA==.',['玛法']='玛法里傲:BAABLAAFFH8TAAIHAAQIsRdWIQATAQAHAAQIsRdWIQATAQAAAA==.',['珍惜']='珍惜這段情:BAABLAAECn8dAAIOAAcIGxeXkgDbAQAOAAcIGxeXkgDbAQAAAA==.',['瑞瑟']='瑞瑟晨风:BAAALAAFFAIIAgAAAA==.',['瑶瑶']='瑶瑶乐:BAAALAAECgMIAwAAAA==.',['瑾丶']='瑾丶年:BAABLAAFFH8HAAIIAAMInwW3NACTAAAIAAMInwW3NACTAAAAAA==.',['甜伯']='甜伯光:BAAALAAECgYIDgAAAA==.',['甜酥']='甜酥奶泡:BAAALAAFFAIIBAAAAA==.',['甲板']='甲板上好冷:BAAALAAFFAIIAgAAAA==.',['疯中']='疯中追风:BAABLAAFFH8WAAQTAAYI0xYRBwA6AQATAAUIshYRBwA6AQANAAMIRQh9FgCdAAAXAAEITQ/GHABFAAABLAAFFAYIIgALAAIVAA==.',['疯牛']='疯牛维维:BAAALAAECgYIBgAAAA==.',['疯狂']='疯狂的摇滚牛:BAAALAADCgYIBgAAAA==.',['白如']='白如冰呀:BAAALAAECgMIBQAAAA==.',['白犽']='白犽:BAAALAADCgEIAQAAAA==.',['白白']='白白嫩嫩滑滑:BAAALAAFFAIIAgAAAA==.白白死神:BAAALAAECgYIBwAAAA==.',['白魂']='白魂:BAAALAADCgcIBwAAAA==.',['百里']='百里东君:BAABLAAFFH8KAAIOAAYIiQs4OgBSAQAOAAYIiQs4OgBSAQAAAA==.',['皤魑']='皤魑傀儡公:BAAALAAECgUIBgAAAA==.',['皮皮']='皮皮丶战:BAABLAAECn8mAAMDAAgI9xFhMQDLAQADAAgI9xFhMQDLAQAVAAgIRwdNZwDfAAAAAA==.',['盘丝']='盘丝灬大仙:BAAALAAECgIIAgAAAA==.',['真空']='真空场娜娜:BAABLAAFFH8GAAISAAYIOx29AgArAgASAAYIOx29AgArAgAAAA==.',['矿老']='矿老爷:BAAALAAECgQIBAAAAA==.',['破城']='破城者:BAAALAAECgYIBgAAAA==.',['破裂']='破裂人偶:BAAALAADCgQIBAAAAA==.',['碰瓷']='碰瓷专家:BAAALAADCgcIBwAAAA==.',['神乐']='神乐沧月:BAAALAAECgYIBgAAAA==.',['神圣']='神圣魔幻:BAAALAAECgYIBgAAAA==.',['神奇']='神奇的神祗:BAAALAAFFAIIAgAAAA==.',['离凰']='离凰:BAABLAAFFH8FAAMXAAMIkgrfGQCMAAAXAAIIOg/fGQCMAAATAAEIQQEeEQA0AAABLAAFFAQICwAbAJkEAA==.',['离若']='离若:BAAALAAECgYIBgAAAA==.',['秦始']='秦始皇二一四:BAACLAAFFH8dAAIMAAUI0RnxIABVAQAMAAUI0RnxIABVAQAsAAQKfzoAAgwACAiRIbAPAOwCAAwACAiRIbAPAOwCAAAA.',['稚天']='稚天使:BAAALAAECggICAAAAA==.',['空然']='空然:BAAALAAECgYICwAAAA==.',['空空']='空空如也:BAAALAAECgIIAgAAAA==.',['空虚']='空虚公子:BAABLAAFFH8IAAIWAAYI6w52LwBbAQAWAAYI6w52LwBbAQAAAA==.',['空谷']='空谷残聲:BAAALAAFFAIIBAAAAA==.',['章若']='章若楠:BAABLAAFFH8TAAIhAAYIThmgAgCbAQAhAAYIThmgAgCbAQAAAA==.',['笑丶']='笑丶悲情:BAAALAAECgYIBgAAAA==.',['第一']='第一幽心:BAAALAADCgcIBwAAAA==.',['简单']='简单的幸福:BAAALAAECgYIDAAAAA==.',['箭洞']='箭洞苍穹:BAAALAAECgYICwAAAA==.',['米瑞']='米瑞斯嘉:BAACLAAFFH8OAAIWAAUIjQ18PAASAQAWAAUIjQ18PAASAQAsAAQKfxQAAhYABghzGTE+AE8BABYABghzGTE+AE8BAAAA.',['索克']='索克雷茨:BAABLAAFFH8KAAMQAAIIaxIDEgCKAAAQAAIIaxIDEgCKAAAPAAEI3QInbQA+AAAAAA==.',['紫星']='紫星:BAAALAAECggICAAAAA==.',['絮怀']='絮怀殇:BAABLAAFFH8qAAIGAAYIwiFLCQD+AQAGAAYIwiFLCQD+AQAAAA==.',['红猫']='红猫:BAAALAAFFAIIAgAAAA==.',['细雨']='细雨无声:BAAALAAFFAIIAgAAAA==.细雨飘雾:BAAALAAECgYIDgAAAA==.',['绚丽']='绚丽音符:BAAALAAECgEIAQAAAA==.',['绯主']='绯主流嘻哈:BAAALAAECgYIDAAAAA==.',['维生']='维生素二细:BAAALAAECgUICwAAAA==.',['维纳']='维纳尔:BAAALAADCgIIAgAAAA==.',['绿豆']='绿豆奶茶:BAAALAAFFAIIAgAAAA==.',['罪孽']='罪孽烙印:BAABLAAFFH8MAAIOAAYIyQWoQwAsAQAOAAYIyQWoQwAsAQAAAA==.',['美川']='美川内酷:BAAALAADCgEIAQAAAA==.',['美艳']='美艳冰星:BAAALAAECgMIBQAAAA==.',['翠风']='翠风行者:BAAALAAECgMIAwAAAA==.',['翱翔']='翱翔灬翼:BAAALAAECggICAABLAAFFAgIBQAWAIQIAA==.',['翼冰']='翼冰寒:BAAALAAECgEIAQAAAA==.',['聖光']='聖光忽悠:BAAALAAFFAIIAgAAAA==.',['肉嘟']='肉嘟嘟胖呼呼:BAAALAAECgYIDAAAAA==.',['脑袋']='脑袋尖尖:BAAALAAFFAEIAQAAAA==.',['至高']='至高岭小磁怪:BAAALAAECgEIAQAAAA==.',['艾米']='艾米:BAAALAAECgEIAQAAAA==.艾米拉:BAAALAAECgIIAgAAAA==.',['艾蕾']='艾蕾莉亚晨风:BAABLAAFFH8NAAIaAAMINh/LFQC6AAAaAAMINh/LFQC6AAABLAAFFAUIGwAIAH4eAA==.',['芭比']='芭比:BAAALAAECgYIBgAAAA==.',['花丶']='花丶殇:BAAALAAECgIIAgAAAA==.',['花殇']='花殇小魔女:BAAALAAECgYICAAAAA==.花殇紫幽幽:BAACLAAFFH8OAAIOAAIIkB5qRQCrAAAOAAIIkB5qRQCrAAAsAAQKfxYAAg4ACAicICkhAOsCAA4ACAicICkhAOsCAAAA.',['花落']='花落兮:BAAALAAECgIIAgAAAA==.',['芳丶']='芳丶华:BAAALAAECgYICAAAAA==.',['苏妲']='苏妲机:BAAALAAFFAIIAgAAAA==.',['苏烟']='苏烟:BAAALAAECgYIBwAAAA==.',['荻野']='荻野由佳:BAAALAAECgIIAgAAAA==.',['莱维']='莱维:BAAALAAECgYIBgAAAA==.',['莽撞']='莽撞人:BAAALAAECggICAABLAAFFAMICQAHAAEPAA==.',['菜就']='菜就多練:BAAALAAFFAIIBAAAAA==.',['萌有']='萌有萌的萌僧:BAAALAAFFAIIAgAAAA==.萌有萌的萌法:BAABLAAFFH8GAAIQAAYImQpSBwAwAQAQAAYImQpSBwAwAQAAAA==.',['萨古']='萨古斯:BAABLAAFFH8IAAIEAAIIZRU2WACRAAAEAAIIZRU2WACRAAAAAA==.',['萨牛']='萨牛儿:BAAALAAECgMIAwAAAA==.',['萨贝']='萨贝柠:BAAALAAFFAIIAgAAAA==.',['萨雷']='萨雷特:BAAALAADCggICQAAAA==.',['落花']='落花狼藉丷:BAABLAAFFH8YAAMOAAcIcxvlEwDxAQAOAAcIcxvlEwDxAQAcAAQIfheBCAD1AAAAAA==.',['蒙牛']='蒙牛值的拥有:BAAALAAECgcIBwAAAA==.',['蒜泥']='蒜泥宝贝:BAAALAAFFAIIBAABLAAFFAUIDwAEAMIPAA==.',['蕾姆']='蕾姆:BAABLAAFFH8GAAIBAAIIpBKdTABMAAABAAIIpBKdTABMAAAAAA==.',['薄荷']='薄荷仙子:BAAALAAECgYIBgAAAA==.',['薇薇']='薇薇安宅:BAACLAAFFH8NAAIZAAUI4Q5rGgADAQAZAAUI4Q5rGgADAQAsAAQKfxgAAhkABggtHG0ZAKQBABkABggtHG0ZAKQBAAEsAAUUBggYAA4ASCIA.',['虫虫']='虫虫万:BAAALAAECgQIBAAAAA==.',['蛀虫']='蛀虫帮左护法:BAABLAAFFH8LAAMZAAYIyhNVCgCDAQAZAAUIxBRVCgCDAQAHAAEI4A3ETABFAAAAAA==.',['蛋塔']='蛋塔王子:BAAALAAECgMIAwAAAA==.',['蛋蛋']='蛋蛋的菊与刀:BAAALAADCgQIBAAAAA==.',['蜜拉']='蜜拉娜:BAAALAAFFAIIAgAAAA==.',['西行']='西行寺幽幽子:BAAALAAECgQIBwAAAA==.',['覆盖']='覆盖全球:BAAALAAECgYIDAAAAA==.',['許鱼']='許鱼:BAACLAAFFH8SAAMUAAMIOBn8MgCTAAAUAAMIOBn8MgCTAAAMAAIIRAvSYgBeAAAsAAQKfxcAAxQACAh/H3QXAN4CABQACAh/H3QXAN4CAAwABAiZGPG0ABgBAAAA.',['许鱼']='许鱼:BAABLAAECn8gAAMPAAcIyxw7SQAqAgAPAAcIyxw7SQAqAgAQAAEIdwenlgAuAAAAAA==.',['该死']='该死的猫:BAAALAAECggICAAAAA==.',['请叫']='请叫我老康:BAAALAAECgcIBwAAAA==.',['谜之']='谜之真相:BAABLAAFFH8HAAIGAAUIWw1XHADmAAAGAAUIWw1XHADmAAABLAAFFAgIDAALAKUUAA==.',['豆到']='豆到碗里来:BAABLAAFFH8LAAIGAAMIFRctQQCRAAAGAAMIFRctQQCRAAAAAA==.',['豆豆']='豆豆土土:BAAALAAECgUIBQAAAA==.',['賊友']='賊友橙意:BAAALAADCgIIAgAAAA==.',['贝勒']='贝勒爷:BAAALAAECgYIDQAAAA==.',['资次']='资次不资次啊:BAAALAAFFAIIAgAAAA==.',['超级']='超级一哥:BAABLAAFFH8VAAIPAAgIPRIvDgANAgAPAAgIPRIvDgANAgAAAA==.超级二页:BAABLAAFFH8IAAIPAAgINgpaEwDgAQAPAAgINgpaEwDgAQAAAA==.超级叁叁:BAAALAAECggICAAAAA==.超级四爷:BAAALAAECgUIBQAAAA==.超级无愧:BAABLAAFFH8GAAIPAAYILApcLwBLAQAPAAYILApcLwBLAQAAAA==.超级流放:BAAALAAECgQIBAAAAA==.',['踏月']='踏月的熊:BAAALAAFFAIIAgAAAA==.',['踏雪']='踏雪无痕丨:BAAALAADCgcIBwAAAA==.',['躺会']='躺会别战复我:BAAALAAECgIIBAAAAA==.',['躺赢']='躺赢:BAABLAAFFH8GAAIUAAMItgjVHwC1AAAUAAMItgjVHwC1AAAAAA==.',['轩辕']='轩辕雪莉:BAAALAAFFAMIAQAAAA==.',['辉煌']='辉煌:BAABLAAFFH8GAAIWAAYIWyGOCwAVAgAWAAYIWyGOCwAVAgAAAA==.',['运动']='运动牛牛:BAABLAAFFH8UAAIVAAgINQmxDgCqAQAVAAgINQmxDgCqAQAAAA==.',['迗嘡']='迗嘡的栤:BAAALAAFFAIIAgAAAA==.',['还得']='还得是你丶:BAAALAADCggICgAAAA==.',['这毫']='这毫王意义:BAAALAAECgYIDgAAAA==.',['远古']='远古一喵:BAABLAAFFH8SAAIHAAYIZhgqEADDAQAHAAYIZhgqEADDAQAAAA==.',['迟到']='迟到的幸福:BAAALAAECgEIAQAAAA==.',['迪亚']='迪亚菠萝:BAAALAAECgQIBAAAAA==.',['迪奧']='迪奧布蘭度:BAABLAAFFH8TAAIWAAUIzxbCNgA0AQAWAAUIzxbCNgA0AQAAAA==.',['迪桑']='迪桑信仰者:BAAALAADCgYIBgAAAA==.',['逍遙']='逍遙哥哥:BAAALAAFFAIIBAAAAA==.',['透明']='透明月色:BAABLAAFFH8GAAIMAAYI6BkEBgDiAQAMAAYI6BkEBgDiAQAAAA==.',['道丶']='道丶无爲:BAAALAAECgYIDgAAAA==.道丶无魂:BAAALAAECgMIAwAAAA==.道丶無殇:BAAALAADCgUIBQAAAA==.道丶無道:BAAALAAECgEIAQAAAA==.',['那夜']='那夜我还无语:BAAALAAECgEIAQAAAA==.',['那年']='那年:BAAALAAECgYIBgAAAA==.',['邪云']='邪云:BAAALAADCgYIBgAAAA==.',['邪皇']='邪皇:BAAALAAFFAIIBAAAAA==.',['邪能']='邪能排骨:BAAALAADCgEIAQAAAA==.',['部族']='部族之涛:BAABLAAFFH8HAAIGAAIIbAhAfQAzAAAGAAIIbAhAfQAzAAAAAA==.',['醉丷']='醉丷酒仙:BAAALAAECggICAAAAA==.',['醋溜']='醋溜白菜:BAAALAAECgQIBQAAAA==.',['醒目']='醒目丨葡萄味:BAABLAAFFH8JAAIGAAIIMRl7OACkAAAGAAIIMRl7OACkAAAAAA==.',['铜锅']='铜锅炖大鹅屮:BAABLAAFFH8GAAIWAAYIOwsjMwBIAQAWAAYIOwsjMwBIAQAAAA==.',['长相']='长相思:BAAALAAECgYICAAAAA==.',['长肆']='长肆寸:BAAALAAECgQIBAAAAA==.',['開鈊']='開鈊小豬:BAABLAAECn86AAIBAAgIRCIJCAC+AgABAAgIRCIJCAC+AgAAAA==.',['闲云']='闲云飘渺:BAABLAAFFH8WAAIDAAYI8A7CEwAjAQADAAYI8A7CEwAjAQAAAA==.',['闻之']='闻之残阳落日:BAAALAAECgYIBgAAAA==.闻之风卷残云:BAAALAAECgIIAQAAAA==.闻之风卷残雲:BAABLAAECn8XAAIUAAgIig5nTwDMAQAUAAgIig5nTwDMAQAAAA==.',['阿凉']='阿凉是哪个:BAAALAAECgYIDAAAAA==.',['阿普']='阿普什勒丶:BAAALAAECgYIBwAAAA==.',['陆小']='陆小凤:BAABLAAFFH8GAAIFAAIIPQJBJAAeAAAFAAIIPQJBJAAeAAAAAA==.',['集合']='集合石大师:BAABLAAFFH8WAAMOAAYImRvjLQDjAAAOAAUIHR3jLQDjAAAcAAEICRRaEABTAAAAAA==.',['集团']='集团马总:BAABLAAFFH8GAAIaAAYIyRhwBADuAQAaAAYIyRhwBADuAQAAAA==.',['雨林']='雨林:BAABLAAFFH8GAAIEAAIISxalSwCZAAAEAAIISxalSwCZAAAAAA==.',['雪品']='雪品品猪:BAAALAAECgYIBgAAAA==.',['霓虹']='霓虹甜心:BAAALAAECgcIDAAAAA==.',['霹雳']='霹雳五:BAACLAAFFH8HAAIMAAII2RL4TQCAAAAMAAII2RL4TQCAAAAsAAQKfxUAAgwABwjXGg5OAPcBAAwABwjXGg5OAPcBAAAA.',['风之']='风之牛:BAABLAAECn8UAAIHAAgILhHYJwCdAQAHAAgILhHYJwCdAQAAAA==.风之萨:BAAALAAFFAIIAgAAAA==.风之骑:BAAALAAFFAIIBAAAAA==.',['风神']='风神库库尔坎:BAAALAAECgYIBgAAAA==.',['风雨']='风雨依然:BAABLAAFFH8IAAIWAAIIowSFVwBjAAAWAAIIowSFVwBjAAAAAA==.',['风雷']='风雷火电:BAABLAAFFH8GAAIgAAII/RPlBgCWAAAgAAII/RPlBgCWAAAAAA==.',['风骚']='风骚走地鸡:BAAALAAECgQIBAAAAA==.',['飞天']='飞天刀削面:BAAALAAECgYIBgAAAA==.飞天炸酱面:BAAALAAFFAIIAgAAAA==.飞天牛肉面:BAAALAADCgMIAwAAAA==.',['飞腿']='飞腿儿喵:BAABLAAFFH8XAAMiAAYIhRpTBwC/AQAiAAYIhRpTBwC/AQASAAEIvQG6IAAyAAAAAA==.',['饼干']='饼干熊:BAABLAAFFH8SAAIEAAUIGQx/UgAFAQAEAAUIGQx/UgAFAQAAAA==.',['驚聲']='驚聲尖訆:BAAALAAECgYICgAAAA==.',['马格']='马格纳斯:BAAALAAFFAIIAwAAAA==.',['骁老']='骁老豆:BAACLAAFFH8NAAIBAAIIEx4ELwCsAAABAAIIEx4ELwCsAAAsAAQKfx4AAgEACAi8HycyAJMCAAEACAi8HycyAJMCAAEsAAUUAggTAAYA/yAA.',['骸饕']='骸饕:BAAALAAFFAIIAgAAAA==.',['高圆']='高圆圆老公:BAABLAAFFH8FAAIOAAIIDA3heACLAAAOAAIIDA3heACLAAAAAA==.',['高坂']='高坂穗乃果:BAABLAAFFH8PAAMHAAIIjyHGFwDDAAAHAAIIjyHGFwDDAAAYAAIIVw7oEAA0AAAAAA==.',['魔兽']='魔兽我最菜:BAAALAADCggICAAAAA==.',['魔力']='魔力斗士:BAAALAAECgEIAQAAAA==.',['鹤守']='鹤守月:BAAALAAECgMIAwAAAA==.',['麦兜']='麦兜儿:BAABLAAFFH8FAAIBAAMIigxcQwB9AAABAAMIigxcQwB9AAAAAA==.',['黑翼']='黑翼尖刀:BAAALAAFFAIIAgAAAA==.',['黑色']='黑色圣堂:BAAALAAECgQIBAAAAA==.',['默府']='默府丶光蝶姬:BAAALAAFFAIIAgAAAA==.默府丶雙蝶姬:BAAALAAFFAIIAgAAAA==.',['黯然']='黯然失落:BAABLAAFFH8cAAICAAYIGSBtBQDUAQACAAYIGSBtBQDUAQAAAA==.',['鼓捣']='鼓捣猫柠:BAAALAADCgYIBgAAAA==.',['龙云']='龙云凤:BAACLAAFFH8rAAMEAAYIOCIgGADXAQAEAAYIOCIgGADXAQAaAAIIWxA1JgB7AAAsAAQKfyYAAwQACAijIUkkACcCAAQACAhwH0kkACcCABoABwibG8kxAPsBAAAA.',['龙翱']='龙翱天宇:BAAALAAECgEIAQAAAA==.',['龙腾']='龙腾虎跃:BAAALAAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end