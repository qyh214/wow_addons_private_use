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
 local lookup = {'Evoker-Augmentation','Evoker-Devastation','Monk-Brewmaster','DeathKnight-Frost','Mage-Arcane','DemonHunter-Havoc','Rogue-Subtlety','Priest-Holy','DeathKnight-Blood','Warrior-Protection','Druid-Restoration','Paladin-Holy','Paladin-Protection','Paladin-Retribution','Mage-Frost','Rogue-Assassination','Hunter-BeastMastery','Unknown-Unknown','Priest-Discipline','Priest-Shadow','Mage-Fire','Hunter-Marksmanship','Warlock-Demonology','Warrior-Fury','Warrior-Arms','Monk-Windwalker','DeathKnight-Unholy','Shaman-Restoration','Shaman-Elemental','Warlock-Destruction','Druid-Balance','Monk-Mistweaver','DemonHunter-Vengeance','Shaman-Enhancement','Druid-Guardian','Hunter-Survival',}; local provider = {region='CN',realm='卡扎克',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Active:BAAALAAECgcIBwAAAA==.',Ah='Ahuaga:BAAALAADCgYIBgAAAA==.',Ap='Apocalypsor:BAAALAAFFAIIAgAAAA==.',Az='Azdaja:BAACLAAFFH8jAAMBAAYIJRLhBgBAAQABAAYIrQ3hBgBAAQACAAUIMBMuDwAoAQAsAAQKfyUAAwEABwibHMYIAPIBAAIABwjhG3QiAAYCAAEABwi/F8YIAPIBAAEsAAUUBggjAAMASx0A.',Ch='Ch:BAAALAADCgQIBAAAAA==.',Do='Doublecross:BAAALAAECgQIBAAAAA==.',Ev='Everfiame:BAACLAAFFH8FAAIEAAQI7wOPOQC+AAAEAAQI7wOPOQC+AAAsAAQKfx0AAgQABwigGlhvABcCAAQABwigGlhvABcCAAAA.',Ez='Ezlol:BAABLAAFFH8YAAIFAAYI7g8jLwBMAQAFAAYI7g8jLwBMAQAAAA==.',Fa='Fangg:BAAALAADCggICAAAAA==.',Fr='Friedljh:BAAALAAECgQIBAAAAA==.Friedlljh:BAACLAAFFH8pAAIGAAYI7hS1HwCDAQAGAAYI7hS1HwCDAQAsAAQKfygAAgYABwhIIE08AG8CAAYABwhIIE08AG8CAAAA.',Gr='Greenbot:BAABLAAFFH8QAAIHAAYIUQbCCQAPAQAHAAYIUQbCCQAPAQAAAA==.',Ih='Ihwimsm:BAACLAAFFH8oAAIIAAYIXSVeBACQAgAIAAYIXSVeBACQAgAsAAQKfzIAAggACAjlJdEBAEwDAAgACAjlJdEBAEwDAAAA.',Ja='Jackmaster:BAAALAAECggICAAAAA==.Jasonzhu:BAABLAAFFH8GAAIIAAIIUAFjTABJAAAIAAIIUAFjTABJAAAAAA==.',Lu='Lulu:BAAALAAECgUIBQAAAA==.',Ni='Nightservant:BAABLAAFFH8HAAIJAAUIURNYCgDUAAAJAAUIURNYCgDUAAABLAAFFAYIIwADAEsdAA==.',No='Nozomi:BAAALAAECgYIEQAAAA==.',Or='Orza:BAAALAADCggICAAAAA==.',Ov='Oversize:BAAALAAECgYIBgAAAA==.',Ra='Rare:BAAALAAFFAIIAgAAAA==.',Sa='Samelex:BAACLAAFFH8kAAIKAAYIqiGnBwDJAQAKAAYIqiGnBwDJAQAsAAQKfyUAAgoABwhDJbQKAPsCAAoABwhDJbQKAPsCAAAA.',Sc='Scarletwitch:BAAALAAFFAMIAgAAAA==.',Sk='Skadoosfists:BAAALAADCgYICgAAAA==.',Sn='Snoowlr:BAAALAAECgYIBgAAAA==.Snoowsm:BAAALAADCgIIAgAAAA==.',St='Starship:BAAALAAECgYIBwAAAA==.',Th='Thalyssraz:BAAALAAECgQIBwAAAA==.Theshy:BAAALAAECgUIAgAAAA==.',['一只']='一只小皮蛋:BAAALAAFFAIIAwAAAA==.',['一块']='一块牛排:BAABLAAFFH8GAAILAAIIrBGRQwBpAAALAAIIrBGRQwBpAAAAAA==.',['一点']='一点点灰:BAACLAAFFH8tAAQMAAYIZRU3DADBAQAMAAYIZRU3DADBAQANAAQIMxraCwDZAAAOAAQIZQ2XNQDVAAAsAAQKfycABAwABwiZG/4gAAwCAAwABwiZG/4gAAwCAA0ABwgFFHU6AFcBAA4AAgjZEjlWAYQAAAAA.',['一萱']='一萱萱一:BAABLAAFFH8GAAIPAAIIHBneFABFAAAPAAIIHBneFABFAAAAAA==.',['一龙']='一龙:BAAALAAECgYIBgAAAA==.',['三队']='三队战仕:BAAALAAECgQIBgAAAA==.',['不得']='不得不野:BAAALAAFFAIIBAAAAA==.',['不戴']='不戴眼镜看你:BAAALAADCgUIBwAAAA==.',['不良']='不良牛:BAAALAAECgIIAwAAAA==.',['两仪']='两仪式:BAAALAAECgEIAQAAAA==.',['两口']='两口一只猪:BAAALAAFFAIIAgAAAA==.',['丨南']='丨南风喃丨:BAABLAAFFH8FAAIQAAMISQOdGgBKAAAQAAMISQOdGgBKAAAAAA==.',['丶大']='丶大黄蜂:BAAALAAECgMIAwAAAA==.',['丶生']='丶生如夏花:BAAALAAFFAIIBAAAAA==.',['丶遨']='丶遨游四海:BAABLAAFFH8CAAIGAAIIzSClNwC6AAAGAAIIzSClNwC6AAAAAA==.',['丿辉']='丿辉灬夜:BAACLAAFFH8XAAMFAAUI2gmfOQD+AAAFAAUI2gmfOQD+AAAPAAIIxAjsFwB6AAAsAAQKfxYAAwUACAhYFO9bAPABAAUACAjjEO9bAPABAA8ABQiIFfRVAB0BAAAA.',['丿阿']='丿阿尔灬泰尔:BAABLAAFFH8MAAIRAAUIJQyXVQD3AAARAAUIJQyXVQD3AAAAAA==.',['乔伊']='乔伊:BAAALAAECggICAAAAA==.',['九啸']='九啸:BAAALAAFFAIIBAAAAA==.',['云麾']='云麾将军:BAAALAADCggICAAAAA==.',['亚哈']='亚哈比比:BAAALAAECgYICwAAAA==.',['仙灵']='仙灵女巫:BAACLAAFFH8LAAICAAMISBCcEADZAAACAAMISBCcEADZAAAsAAQKfxUAAgIACAiZFeciAAMCAAIACAiZFeciAAMCAAAA.',['伊莉']='伊莉雅:BAABLAAFFH8JAAIGAAIIbx5TLgCtAAAGAAIIbx5TLgCtAAABLAAFFAMIAgASAAAAAA==.',['众生']='众生绝离:BAACLAAFFH8rAAQIAAYIZxsqEADdAQAIAAYIZxsqEADdAQATAAMIzRg4AgDeAAAUAAQI0g5OGwDFAAAsAAQKfxwAAwgABwjBHKQ0AAoCAAgABwjBHKQ0AAoCABQABggqFmlPAHgBAAAA.',['倾城']='倾城蝶舞:BAAALAADCgcIBwAAAA==.',['储备']='储备粮在哪里:BAAALAAECgEIAQAAAA==.',['傲气']='傲气发型不乱:BAAALAAECggICAAAAA==.',['傲视']='傲视风尘:BAAALAADCgIIAgAAAA==.',['僉夜']='僉夜:BAAALAADCggICAAAAA==.',['像鱼']='像鱼:BAAALAAECgYIBgAAAA==.',['克莱']='克莱文:BAABLAAFFH8NAAIRAAMI4RM5bQCHAAARAAMI4RM5bQCHAAABLAAFFAYIFAAMAEEeAA==.',['兜兜']='兜兜里有奶:BAAALAADCgYIBgAAAA==.兜兜里有烟:BAAALAADCgIIAgAAAA==.',['六库']='六库仙贼:BAAALAAECgUIBQAAAA==.',['再次']='再次回首寒暄:BAAALAAECggIDwAAAA==.',['军团']='军团刺客:BAAALAAECgcIEAAAAA==.军团小满:BAAALAAECgYICAAAAA==.军团小猎:BAAALAAECgUIBQAAAA==.',['冰冰']='冰冰饼:BAABLAAFFH8UAAQFAAYIwAZFPADfAAAFAAUI6wZFPADfAAAVAAIIWAd0DgA8AAAPAAIIKwXaGgA7AAAAAA==.',['刀锋']='刀锋如浪:BAACLAAFFH8xAAMRAAcIkCE1DAAoAgARAAcIESE1DAAoAgAWAAUIIRblCACEAQAsAAQKfyQAAxYACAhAJGcMAAADABYACAhAJGcMAAADABEABQhJIsQ2AOcBAAAA.',['刘五']='刘五魁:BAAALAAECgYICQAAAA==.',['刘芳']='刘芳百世:BAACLAAFFH8JAAMUAAMIbRb9EQD2AAAUAAMIbRb9EQD2AAAIAAEIXwBTTAAsAAAsAAQKfx0ABBQACAj9GXQuABQCABQABwiNGnQuABQCABMABwiWFJoPALABAAgAAggsAbG6AEEAAAAA.',['初雪']='初雪沁心寒:BAAALAAECgMIBAAAAA==.',['别玩']='别玩苍白之主:BAABLAAFFH8GAAIXAAIIbxCKFQCZAAAXAAIIbxCKFQCZAAAAAA==.',['力拔']='力拔山河:BAAALAAECgUIBgAAAA==.',['千甄']='千甄:BAAALAADCgYIBgAAAA==.',['卡兹']='卡兹格罗兹:BAAALAAFFAIIBAAAAA==.',['发怒']='发怒的狼人:BAACLAAFFH8GAAIYAAIIqhSKRQBOAAAYAAIIqhSKRQBOAAAsAAQKfx8AAxgACAhPHEQdAP8BABgACAhPHEQdAP8BABkAAgjuFMkuAH4AAAAA.',['召唤']='召唤的菲戈:BAABLAAECn8XAAIYAAYI/hXqQQBTAQAYAAYI/hXqQQBTAQAAAA==.',['史拉']='史拉达:BAAALAAECgEIAgAAAA==.',['叹息']='叹息之牆:BAAALAAECgYICgAAAA==.',['吃果']='吃果盘:BAAALAAECggICAAAAA==.',['向來']='向來緣淺:BAAALAAECgcIDQAAAA==.向來谜:BAAALAAECgYIBgAAAA==.',['向来']='向来如疯:BAAALAAECgYIDAAAAA==.向来疯狂:BAAALAAECgUIBgAAAA==.向来癫狂:BAAALAAECgUIBQAAAA==.',['咖啡']='咖啡是我隐藏:BAAALAAFFAMIBAAAAA==.',['哇是']='哇是真的皮:BAAALAADCgEIAQAAAA==.',['哪像']='哪像伱丶:BAAALAAECgMIAwAAAA==.哪像你:BAAALAAECgYIBgAAAA==.哪像你丶:BAAALAAECgYIBgAAAA==.哪像你灬:BAABLAAFFH8lAAIMAAcI2SG+AgCjAgAMAAcI2SG+AgCjAgAAAA==.哪像儞:BAABLAAFFH8FAAIEAAIIFRFfcACQAAAEAAIIFRFfcACQAAAAAA==.哪像坭:BAABLAAFFH8GAAIIAAIIPQ/eMACNAAAIAAIIPQ/eMACNAAAAAA==.哪像妳:BAAALAAFFAIIAgAAAA==.哪像妳丶:BAAALAADCgIIAgAAAA==.哪像妳灬:BAAALAAECgYIBgAAAA==.哪像旎:BAAALAADCgUIBQAAAA==.哪像猊:BAAALAAFFAIIBAAAAA==.',['啊胸']='啊胸:BAAALAAFFAIIAgAAAA==.',['噩梦']='噩梦猎手:BAAALAAECggICAAAAA==.',['囝囝']='囝囝囡囡:BAAALAAECgYIBgAAAA==.',['回眸']='回眸:BAABLAAFFH8TAAIaAAQIxguTEQCDAAAaAAQIxguTEQCDAAAAAA==.',['回首']='回首多次:BAAALAAECgcICwAAAA==.回首心冷:BAAALAAECgYICwAAAA==.回首心疼:BAAALAAECgYICwAAAA==.',['圣羽']='圣羽:BAAALAAECgYIBgAAAA==.',['坵彼']='坵彼特:BAAALAAECgUIBQAAAA==.',['处丶']='处丶丶长:BAAALAAECgEIAQAAAA==.',['多次']='多次回首:BAABLAAECn8nAAIOAAgISh/ZEwBvAgAOAAgISh/ZEwBvAgAAAA==.多次寒暄:BAAALAAECggICwAAAA==.',['多看']='多看一眼就炸:BAAALAAECgYICgAAAA==.',['大挪']='大挪姨:BAAALAAECgYIEQAAAA==.',['大旱']='大旱:BAAALAAFFAIIAgAAAA==.',['大萌']='大萌咕:BAAALAAECgUIBQAAAA==.',['大飞']='大飞哥:BAAALAAECgYIBgAAAA==.',['天明']='天明罗塔:BAABLAAECn8hAAIOAAgIcxk2IAAbAgAOAAgIcxk2IAAbAgAAAA==.天明诺兰:BAAALAAECgMIAwAAAA==.',['天曦']='天曦:BAAALAAECgYIBgAAAA==.',['天然']='天然呆呆:BAAALAAFFAIIAgAAAA==.',['天舞']='天舞牛骑:BAAALAAFFAIIAgAAAA==.天舞萨:BAAALAAECgMIBQAAAA==.',['天鸢']='天鸢桜:BAABLAAFFH8OAAMEAAUIVw2ARwAcAQAEAAUIVw2ARwAcAQAJAAIIVwZkHQAsAAAAAA==.',['奇奇']='奇奇怪怪:BAABLAAECn8fAAMEAAgIHCQkKQDNAgAEAAcITCQkKQDNAgAbAAUIMCKaGwDdAQAAAA==.',['她说']='她说是晒黑的:BAAALAAFFAEIAQAAAA==.',['宁仙']='宁仙儿:BAACLAAFFH8vAAMIAAYIthY4EQDSAQAIAAYIthY4EQDSAQAUAAIIzQJtMQAuAAAsAAQKfygABAgACAgIEE5lAEwBAAgACAiHD05lAEwBABQAAgguC6CMAG4AABMAAghaCvA4AEcAAAAA.',['宏先']='宏先生:BAABLAAFFH8GAAILAAYItwPeIwD8AAALAAYItwPeIwD8AAAAAA==.',['宝宝']='宝宝的笨笨:BAACLAAFFH8IAAIOAAIILgjKeQA3AAAOAAIILgjKeQA3AAAsAAQKfxcAAg4ACAgWFK5VAF8BAA4ACAgWFK5VAF8BAAAA.',['富良']='富良野蛇头:BAAALAAECgMIAwABLAAFFAgIMwAQAOQjAA==.',['寒江']='寒江夜:BAAALAAECgQIBAAAAA==.',['对着']='对着镜子撸:BAAALAAECgYICgAAAA==.',['导师']='导师带你送:BAAALAAECgYIBgAAAA==.',['小妖']='小妖猎:BAAALAAFFAIIAgAAAA==.',['小小']='小小的冲风:BAAALAADCgEIAQAAAA==.小小的断章:BAAALAADCgYIBgAAAA==.',['小月']='小月饼:BAAALAAECgYIBgAAAA==.',['小木']='小木鸠:BAACLAAFFH8KAAIcAAMIIxK+RgCSAAAcAAMIIxK+RgCSAAAsAAQKfxoAAhwABghZGixwAKIBABwABghZGixwAKIBAAAA.',['小萨']='小萨代言人:BAAALAAECgYICAAAAA==.',['小血']='小血壹个:BAAALAAECgMIAwAAAA==.',['就是']='就是一般个人:BAAALAAECgYIDAAAAA==.',['岩歌']='岩歌:BAABLAAFFH8LAAMdAAYI+QozIgAwAQAdAAYI+QozIgAwAQAcAAMIZAriTgB+AAAAAA==.',['峭壁']='峭壁库洛米:BAAALAADCgQIBAAAAA==.',['巨馍']='巨馍蘸酱丶:BAACLAAFFH8RAAIFAAMIMBbtRQCaAAAFAAMIMBbtRQCaAAAsAAQKfyIAAwUABgigIxQ7AF4CAAUABgigIxQ7AF4CAA8ABAhcH45IAE4BAAAA.',['已经']='已经在摸鱼了:BAAALAAECgcIDAAAAA==.',['布歌']='布歌:BAABLAAFFH8HAAIeAAQIzgqtRQC2AAAeAAQIzgqtRQC2AAABLAAFFAYICwAdAPkKAA==.',['布鲁']='布鲁托:BAAALAADCgYIBgAAAA==.',['師兄']='師兄:BAAALAAECgUIBQAAAA==.',['建威']='建威将军:BAAALAADCgYIBgAAAA==.',['御术']='御术临疯:BAACLAAFFH8mAAIeAAUIfSC4IwABAQAeAAUIfSC4IwABAQAsAAQKfyEAAx4ABwhmIQwvAIICAB4ABwhmIQwvAIICABcAAwgwFblxALEAAAAA.',['怒龙']='怒龙卷毛:BAAALAAFFAIIAgAAAA==.',['愤怒']='愤怒的马哥:BAAALAAECgIIAgAAAA==.',['我射']='我射中你咯:BAAALAAFFAEIAQAAAA==.',['我就']='我就混混:BAAALAAFFAIIAgAAAA==.',['我想']='我想要钱涛涛:BAAALAAECgQIBwAAAA==.',['我爱']='我爱热干面:BAABLAAECn8UAAILAAYI+BaeMgBdAQALAAYI+BaeMgBdAQAAAA==.',['担心']='担心我的学习:BAAALAAECgYIBgAAAA==.',['拳头']='拳头弟弟:BAAALAAECggICAAAAA==.',['指间']='指间小德:BAAALAAECgMIAwAAAA==.指间魔法:BAAALAADCggICAAAAA==.',['掺水']='掺水的孟婆汤:BAABLAAFFH8SAAIfAAUI6BRpEADuAAAfAAUI6BRpEADuAAAAAA==.',['撒拉']='撒拉丁:BAAALAAFFAEIAQAAAA==.',['斗志']='斗志昂扬:BAAALAAECgYIBwAAAA==.',['断水']='断水流大师兄:BAAALAADCgYIBgAAAA==.',['新垣']='新垣结衣:BAABLAAFFH8MAAIEAAIIyw/bbACSAAAEAAIIyw/bbACSAAAAAA==.',['无人']='无人熟识:BAAALAAECgYIBgAAAA==.',['无式']='无式:BAAALAAECgYIEAAAAA==.',['时光']='时光荏苒:BAAALAAFFAIIAgAAAA==.',['星夜']='星夜浸天涯:BAAALAAECgcIDQAAAA==.',['星辰']='星辰月影:BAACLAAFFH8gAAIWAAYI1g/LBwBJAQAWAAYI1g/LBwBJAQAsAAQKfygAAhYACAgcHnklAEMCABYACAgcHnklAEMCAAAA.',['春风']='春风吹啊吹:BAABLAAFFH8LAAMcAAUI6QTPRACXAAAcAAQIawXPRACXAAAdAAEIgQGeVAAkAAAAAA==.',['晴转']='晴转大雨:BAACLAAFFH8MAAIcAAIImRyjMgCcAAAcAAIImRyjMgCcAAAsAAQKfy0AAhwABwjSIBIpAG0CABwABwjSIBIpAG0CAAAA.',['暗月']='暗月降临:BAAALAADCgEIAQAAAA==.',['曲歌']='曲歌:BAABLAAFFH8FAAIIAAMIEhKTLQC5AAAIAAMIEhKTLQC5AAABLAAFFAYICwAdAPkKAA==.',['曼彻']='曼彻斯特传奇:BAACLAAFFH8bAAIYAAUIZBtIGwDvAAAYAAUIZBtIGwDvAAAsAAQKfx8AAxgABwhUIfE8AEECABgABwhUIfE8AEECABkABgjkFgUTAKkBAAAA.',['曼神']='曼神射手:BAACLAAFFH8SAAMWAAYIOg5eCgD+AAAWAAYIOg5eCgD+AAARAAEIYwixjAA5AAAsAAQKfy0AAhYABwgyHhsjAFICABYABwgyHhsjAFICAAAA.曼神秘学:BAABLAAFFH8bAAIFAAUIDw/ONAAoAQAFAAUIDw/ONAAoAQAAAA==.',['最后']='最后的闪光炮:BAAALAAECgYICAAAAA==.',['月落']='月落星沉:BAAALAAECgEIAQAAAA==.',['有课']='有课题带带我:BAAALAAECgYIEgAAAA==.',['条子']='条子丶:BAABLAAFFH8GAAIMAAIIHhH4JQB0AAAMAAIIHhH4JQB0AAAAAA==.',['杨千']='杨千幻:BAAALAAECgIIAgAAAA==.',['杰哥']='杰哥快来:BAABLAAFFH8JAAIEAAMISRTPLADmAAAEAAMISRTPLADmAAAAAA==.',['极致']='极致的帅:BAAALAADCgQIBAAAAA==.',['果酱']='果酱味奶糖:BAACLAAFFH8JAAIFAAQITwtYQwCWAAAFAAQITwtYQwCWAAAsAAQKfxYAAgUACAiAHQFPABgCAAUACAiAHQFPABgCAAAA.',['枫之']='枫之语:BAABLAAFFH8fAAIRAAUIRBb9JwDdAAARAAUIRBb9JwDdAAAAAA==.枫之迅捷:BAABLAAFFH8PAAILAAMI0RT9JwCKAAALAAMI0RT9JwCKAAAAAA==.',['枯木']='枯木禅心丶:BAAALAAFFAIIBAAAAA==.',['柑道']='柑道夫:BAAALAAECgEIAQAAAA==.',['柳妍']='柳妍妍:BAAALAAECgYIBgAAAA==.',['格尔']='格尔德:BAAALAADCgYIBgAAAA==.',['桃桃']='桃桃妹:BAABLAAFFH8MAAIOAAMIRxSCQwCKAAAOAAMIRxSCQwCKAAAAAA==.',['死前']='死前巨饿:BAABLAAFFH8MAAIeAAYIyh+JHwCeAQAeAAYIyh+JHwCeAQAAAA==.',['殺戮']='殺戮:BAACLAAFFH8nAAIQAAYI+B7KBQDLAQAQAAYI+B7KBQDLAQAsAAQKfzkAAhAACAhnIK0LANQCABAACAhnIK0LANQCAAEsAAUUCAg7AB8A4R4A.',['水流']='水流幕:BAABLAAFFH8LAAIcAAMIaB4RGQDpAAAcAAMIaB4RGQDpAAAAAA==.',['汹怀']='汹怀大痣:BAAALAAECgYIDAAAAA==.',['沅歌']='沅歌:BAAALAAECggICAABLAAFFAYICwAdAPkKAA==.',['沐慕']='沐慕:BAAALAAECgYICgAAAA==.',['沙德']='沙德法丶丶:BAABLAAFFH8WAAIeAAYIZBpbHwCfAQAeAAYIZBpbHwCfAQAAAA==.',['没心']='没心情:BAAALAAECgYIBgAAAA==.',['没有']='没有常识的人:BAABLAAFFH8IAAIEAAUI1Q02RgAhAQAEAAUI1Q02RgAhAQAAAA==.',['法布']='法布雷加斯:BAABLAAFFH8UAAIcAAYIPBrcFAC5AQAcAAYIPBrcFAC5AQAAAA==.',['泪滴']='泪滴嘎嘎:BAABLAAFFH8HAAIIAAMIoAcjNgCLAAAIAAMIoAcjNgCLAAAAAA==.',['泰瑞']='泰瑞克:BAAALAAECgEIAQAAAA==.',['浊酒']='浊酒留风尘:BAAALAADCgMIAwAAAA==.',['海盐']='海盐棒棒糖:BAAALAADCgcIBwAAAA==.',['清绝']='清绝影歌:BAAALAAFFAIIAgAAAA==.',['渣男']='渣男:BAAALAAECgMIAwAAAA==.',['温如']='温如玉:BAAALAAECgYICwAAAA==.',['漫天']='漫天圣光:BAAALAAFFAIIAgAAAA==.',['火炎']='火炎猫头鹰:BAAALAAECgUIBgAAAA==.',['火焰']='火焰猫头鹰:BAAALAAECgUICgAAAA==.',['火焱']='火焱猫头鹰:BAAALAAECgYIDwAAAA==.',['火鸡']='火鸡味锅巴:BAAALAAECgYICAAAAA==.',['灬玖']='灬玖玖灬:BAABLAAFFH8IAAIPAAIIKBdmDwCRAAAPAAIIKBdmDwCRAAAAAA==.',['炼狱']='炼狱之火:BAAALAAECgYIDAAAAA==.',['烈火']='烈火破浪:BAAALAAECgYIBgAAAA==.',['無妄']='無妄:BAAALAAECgUIBgAAAA==.',['煎蛋']='煎蛋饺:BAAALAADCgcIBwAAAA==.',['熊图']='熊图腾:BAACLAAFFH8jAAIDAAYISx1SCQCzAQADAAYISx1SCQCzAQAsAAQKfx8AAwMABwhrIhkMAJwCAAMABwhrIhkMAJwCACAAAgi4Cd5PAEwAAAAA.',['熊淘']='熊淘武乐:BAAALAADCgcIBwAAAA==.',['熟悉']='熟悉橡树的人:BAAALAAFFAMIBAAAAA==.',['牛古']='牛古拉斯凯奇:BAAALAAECgQIBAAAAA==.',['牛郎']='牛郎:BAAALAAECgUIAwAAAA==.',['牛鬼']='牛鬼也疯狂:BAABLAAFFH8pAAMLAAYIQR8RCQAbAgALAAYIQR8RCQAbAgAfAAIInQLNLABMAAAAAA==.',['牧之']='牧之小麻子:BAAALAAECgYIBwAAAA==.',['狗蛋']='狗蛋儿丶汪:BAAALAAECgYIBgAAAA==.',['狮心']='狮心王夏娜:BAAALAAECgQIBAAAAA==.',['猎魂']='猎魂小贼猫:BAAALAAECgYIBgAAAA==.',['猪脚']='猪脚饭:BAAALAAECgYIBgAAAA==.',['猫样']='猫样法娘:BAAALAAFFAIIAgAAAA==.',['猫福']='猫福瑞:BAAALAAECggICAAAAA==.',['猴子']='猴子瘤子:BAAALAAECgYICwAAAA==.',['玄奘']='玄奘:BAABLAAFFH8GAAIeAAYI6g2SLgBfAQAeAAYI6g2SLgBfAQAAAA==.',['玄甲']='玄甲:BAAALAAECgYIBgAAAA==.',['玛咔']='玛咔巴卡:BAACLAAFFH8LAAIGAAMIKwrKQwB5AAAGAAMIKwrKQwB5AAAsAAQKfy8AAwYACAisGnkeAPABAAYACAheGnkeAPABACEABAinEqQdAK4AAAAA.',['玥儛']='玥儛:BAABLAAFFH8NAAMHAAQIxwQADwCKAAAHAAQIXwIADwCKAAAQAAMIkAVJFgCKAAAAAA==.',['玩潮']='玩潮:BAACLAAFFH8IAAIdAAMIYw5qNwB+AAAdAAMIYw5qNwB+AAAsAAQKfyAABB0ABgh3HIZAAAICAB0ABgh3HIZAAAICABwAAghRDAOXAFAAACIAAQjVBGArACoAAAAA.',['珝玥']='珝玥婲:BAABLAAFFH8VAAIOAAYInht9FwCWAQAOAAYInht9FwCWAQAAAA==.',['电殁']='电殁殁:BAAALAAECgYIBgAAAA==.',['白萍']='白萍洲:BAAALAAECgMIBAAAAA==.',['百年']='百年孤封:BAAALAAECgEIAQAAAA==.',['盈盈']='盈盈忽悠你:BAAALAAECgYIBgAAAA==.',['相见']='相见恨晚:BAAALAAECgYIBgAAAA==.',['真心']='真心给了狗:BAAALAAECgYICwAAAA==.',['真的']='真的皮丶:BAAALAADCgIIAgABLAAECgYIBgASAAAAAA==.真的难丶:BAAALAAECgYIBgAAAA==.',['碳酸']='碳酸钙:BAAALAAECgYICgAAAA==.',['神乐']='神乐和定春:BAAALAAECgYIBgAAAA==.',['神明']='神明灵:BAAALAAECgYIDAAAAA==.',['空白']='空白:BAABLAAFFH8IAAMKAAII1x0cFACwAAAKAAII1x0cFACwAAAYAAIITgjERgCCAAAAAA==.',['空空']='空空如也:BAAALAAFFAIIBAAAAA==.',['笕桥']='笕桥往事:BAAALAAECgMIAwAAAA==.',['第几']='第几次回收:BAABLAAECn8WAAIGAAYI+xtILwCcAQAGAAYI+xtILwCcAQAAAA==.',['米兰']='米兰达德儿:BAABLAAFFH8KAAMLAAIITAPmVQBIAAALAAIITAPmVQBIAAAjAAII/w0hDgArAAAAAA==.',['米开']='米开朗基罗:BAAALAAFFAIIAgAAAA==.',['粉雪']='粉雪冲浪:BAAALAAECgYIEgAAAA==.',['索德']='索德公爵:BAAALAAECgIIAgAAAA==.',['紫发']='紫发猎魔王:BAAALAAECggIDAAAAA==.',['红尘']='红尘炼心:BAAALAAECgYIDAAAAA==.红尘箭:BAAALAAFFAIIAgAAAA==.',['纯情']='纯情大牛牛:BAAALAAECgYIBgAAAA==.',['给你']='给你钉墙上:BAAALAAECgEIAQAAAA==.',['给斋']='给斋饭也要打:BAACLAAFFH8dAAMaAAYIzh2BDQDkAAAaAAQIuRuBDQDkAAAgAAQIdAocDQC8AAAsAAQKfycAAxoABwjTI3gPAK8CABoABwjTI3gPAK8CACAABwiBGPEaAOIBAAAA.',['绝岭']='绝岭:BAABLAAFFH8KAAIGAAIIOA8fVgCGAAAGAAIIOA8fVgCGAAAAAA==.',['继光']='继光香香咕:BAAALAAECgUIBQAAAA==.',['罗罗']='罗罗诺阿索罗:BAAALAAECgMIAwAAAA==.',['美丽']='美丽的心情:BAAALAAECgYICwAAAA==.',['美国']='美国怼长:BAAALAAECgcIBwAAAA==.',['美的']='美的美的比:BAAALAAECgYIBgAAAA==.',['羽毛']='羽毛小耳环:BAABLAAFFH8XAAIGAAYIzg0PIgB2AQAGAAYIzg0PIgB2AQAAAA==.',['老妖']='老妖精:BAABLAAFFH8EAAIPAAIIBh5NEwBKAAAPAAIIBh5NEwBKAAAAAA==.',['老师']='老师带大的:BAABLAAFFH8GAAIkAAIILRrYAgCxAAAkAAIILRrYAgCxAAAAAA==.',['肥妞']='肥妞我:BAAALAAECgYICgAAAA==.',['背叛']='背叛者的疯狂:BAAALAAECgYICwAAAA==.',['胡塞']='胡塞神射手:BAABLAAFFH8FAAIRAAQIwx9gWQDkAAARAAQIwx9gWQDkAAAAAA==.',['舞随']='舞随白雪:BAACLAAFFH8rAAMIAAYIlR4dDAAJAgAIAAYIlR4dDAAJAgATAAIItxcGBACMAAAsAAQKfxQABBMACAgaF2QUAG0BABMABgg/FGQUAG0BAAgABgjrF+Y6APwAABQABQgRDRU3AKgAAAAA.',['艾米']='艾米莉雅丶:BAAALAADCgcIBwAAAA==.',['艾莲']='艾莲西雅:BAACLAAFFH8nAAMZAAUIgR2KAQD0AAAYAAUIXhrBIwBQAQAZAAQIhRiKAQD0AAAsAAQKfxUAAxkABwg+JXgHAIACABkABwjGHngHAIACABgABghFInc5AE8CAAAA.',['艾达']='艾达潞希:BAAALAAECgIIAgAAAA==.',['芙柆']='芙柆柆:BAAALAAECgEIAQAAAA==.',['芙罗']='芙罗塞碧那:BAAALAADCgIIAgAAAA==.',['花雨']='花雨夜:BAAALAAECgYIBgAAAA==.',['苍天']='苍天哥九号:BAAALAADCggICAABLAAECgYIBgASAAAAAA==.',['苍穹']='苍穹之下:BAAALAAECgIIAgAAAA==.',['苏式']='苏式阿三:BAAALAAECgIIAgAAAA==.',['英姿']='英姿萨爽:BAAALAAECgYICgAAAA==.',['英雄']='英雄的掠影:BAAALAAECgYIBgAAAA==.',['菟纸']='菟纸丨酱:BAAALAAECggIDAAAAA==.',['菠萝']='菠萝包逆袭:BAAALAADCggIDwAAAA==.',['萨安']='萨安德萨:BAAALAADCgIIAgAAAA==.',['萨雷']='萨雷安学长:BAAALAAECgYIDAAAAA==.',['葵愛']='葵愛深藍:BAAALAAECgYICgAAAA==.',['蒜头']='蒜头长了苗:BAAALAAECgYIBgAAAA==.',['虚空']='虚空灬圣:BAAALAADCgUIBQAAAA==.',['蛋如']='蛋如刀割:BAAALAADCgMIAwAAAA==.',['蛮荒']='蛮荒九哮:BAAALAAFFAIIBAAAAA==.蛮荒九啸:BAACLAAFFH8GAAIPAAIIUyPPCgCsAAAPAAIIUyPPCgCsAAAsAAQKfx8AAw8ABgh2JgARAJ4CAA8ABgh2JgARAJ4CAAUABgggEam1ABQBAAAA.',['血色']='血色沙场:BAABLAAFFH8lAAIEAAYI9he2JwCXAQAEAAYI9he2JwCXAQAAAA==.血色黑骑兵:BAAALAAECgUIBQAAAA==.',['西园']='西园屁屁:BAAALAADCggICAAAAA==.',['西西']='西西弗悦:BAABLAAFFH8IAAILAAgIVgAoYgANAAALAAgIVgAoYgANAAAAAA==.',['要奶']='要奶叫一声:BAAALAAECgYIBgAAAA==.',['请你']='请你荔枝一点:BAACLAAFFH8QAAMEAAYIRBiGQwCuAAAEAAYIRBiGQwCuAAAJAAII/QpLFABrAAAsAAQKfyQAAwkABghtGUwbALsBAAkABghtGUwbALsBAAQAAwgpDLNxAYEAAAAA.',['诺兰']='诺兰天行:BAAALAAECgEIAQAAAA==.',['贺强']='贺强:BAAALAAFFAIIAgAAAA==.',['赞达']='赞达拉大王:BAAALAAECgYIBgAAAA==.',['起舞']='起舞彩牛:BAABLAAFFH8GAAIDAAYIYxRQDwBTAQADAAYIYxRQDwBTAQAAAA==.',['身手']='身手敏捷:BAAALAAECgYICQAAAA==.',['轻歌']='轻歌漫诵:BAAALAAFFAQIBAAAAA==.',['达达']='达达里奥:BAAALAAECgYIBgAAAA==.',['迷人']='迷人小梨涡:BAAALAAECgYIDAAAAA==.',['醉卧']='醉卧云中:BAAALAAECgMIBQAAAA==.醉卧云端:BAAALAAECgUIBQAAAA==.醉卧云霄:BAAALAAECgYIDAAAAA==.醉卧巅峰:BAAALAAECgYIBgAAAA==.醉卧浮生:BAAALAAECgYIDAAAAA==.醉卧烟雨:BAAALAAECgYIBgAAAA==.',['醒醒']='醒醒:BAAALAAECgYIBgAAAA==.',['重铸']='重铸意志:BAAALAADCgIIAgAAAA==.',['鑫森']='鑫森淼焱:BAAALAADCgMIAwAAAA==.',['铥伱']='铥伱螺母:BAABLAAFFH8ZAAIEAAgIryBJBAC8AgAEAAgIryBJBAC8AgAAAA==.',['闪光']='闪光百变怪:BAABLAAFFH8KAAIGAAMI8An7QwB3AAAGAAMI8An7QwB3AAAAAA==.',['阿珂']='阿珂萌德:BAABLAAFFH8LAAILAAQIVQhGLgCyAAALAAQIVQhGLgCyAAAAAA==.',['阿瓦']='阿瓦达啃嗅嗅:BAAALAAECgYIBgAAAA==.阿瓦达啃秀秀:BAAALAAECgIIAgAAAA==.',['阿达']='阿达尔:BAAALAADCgIIAgAAAA==.',['陇月']='陇月之法:BAABLAAECn8XAAIdAAcI1RIvPgAUAQAdAAcI1RIvPgAUAQAAAA==.',['陷阵']='陷阵营:BAAALAAECgYIDAAAAA==.',['随缘']='随缘一砍:BAABLAAECn8eAAIYAAgIRRV+IQDkAQAYAAgIRRV+IQDkAQAAAA==.随缘一锤:BAAALAAFFAIIAwAAAA==.',['隐丶']='隐丶翼:BAAALAAECgEIAQAAAA==.隐丶风:BAABLAAFFH8IAAIRAAYIOAa6UgAEAQARAAYIOAa6UgAEAQAAAA==.',['隐之']='隐之哀伤:BAAALAAECggIDAAAAA==.',['隐藏']='隐藏得咖啡:BAABLAAFFH8mAAMUAAUISheYEwA5AQAUAAUISheYEwA5AQAIAAQI9hkJIgAzAQAAAA==.',['雁过']='雁过无痕:BAAALAAFFAIIAgAAAA==.',['雌熊']='雌熊眼迷离:BAAALAADCgQIBAAAAA==.',['雨丶']='雨丶樱花:BAAALAAECggIBgAAAA==.',['雨灬']='雨灬樱花:BAAALAAECgIIAgAAAA==.',['雪花']='雪花飘零:BAAALAADCgEIAQAAAA==.',['雷法']='雷法:BAAALAAECgYIBgAAAA==.',['霄里']='霄里山:BAAALAAFFAIIBAAAAA==.',['霜玲']='霜玲珑:BAABLAAFFH8FAAIOAAUIvhkMJgBFAQAOAAUIvhkMJgBFAQAAAA==.',['青柑']='青柑普洱丶:BAABLAAFFH8JAAMRAAYILRZyOwBVAQARAAYIZBRyOwBVAQAWAAMI2xe6DgCOAAAAAA==.',['青衫']='青衫依旧:BAABLAAFFH8PAAIRAAYIUxD0OgBWAQARAAYIUxD0OgBWAQAAAA==.',['青青']='青青小板妹:BAABLAAFFH8JAAIOAAUIwQjeLwAGAQAOAAUIwQjeLwAGAQAAAA==.',['风吹']='风吹雨欲来:BAAALAAECgQIBgAAAA==.',['飞飞']='飞飞呀:BAAALAAFFAIIAwAAAA==.',['魂断']='魂断孟良崮:BAABLAAECn8ZAAMIAAcI+xXjRADDAQAIAAcI+xXjRADDAQAUAAEIWRNFlwBGAAAAAA==.',['魔王']='魔王利姆鲁:BAABLAAFFH8IAAILAAMIxCKWDAAvAQALAAMIxCKWDAAvAQAAAA==.',['麻辣']='麻辣香鸡:BAAALAAFFAIIAgABLAAFFAgIBgAfAJAcAA==.',['黑夜']='黑夜梦魇:BAAALAAECgYIBgAAAA==.',['黑暗']='黑暗红门:BAAALAADCgIIAgAAAA==.',['龙妹']='龙妹妹:BAABLAAECn8WAAIRAAYI8BvhlgC5AQARAAYI8BvhlgC5AQAAAA==.',['龙行']='龙行龘龘:BAACLAAFFH8SAAIeAAYI/AfUNgA0AQAeAAYI/AfUNgA0AQAsAAQKfxgAAh4ABwgGDkqQAF0BAB4ABwgGDkqQAF0BAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end