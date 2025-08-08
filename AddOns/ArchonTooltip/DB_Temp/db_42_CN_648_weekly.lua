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
 local lookup = {'Paladin-Retribution','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Arcane','Warrior-Fury','Warrior-Protection','Warlock-Destruction','DeathKnight-Unholy','DeathKnight-Blood','Priest-Shadow','Evoker-Devastation','Monk-Mistweaver','DemonHunter-Havoc','Druid-Restoration','Warrior-Arms','Monk-Windwalker','Monk-Brewmaster','Warlock-Demonology','Shaman-Enhancement','Shaman-Elemental','Paladin-Protection','Mage-Fire','Mage-Frost','Evoker-Preservation','Unknown-Unknown','Druid-Balance','Shaman-Restoration','Hunter-Survival','Druid-Guardian','DemonHunter-Vengeance','Priest-Discipline','Priest-Holy',}; local provider = {region='CN',realm='安其拉',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Allkyingtiao:BAABKgAFFH8GAAIBAAYIvhq5HACBAQABAAYIvhq5HACBAQAAAA==.',Am='Amazon:BAAAKgAECgEIAQAAAA==.',An='Animate:BAAAKgAFFAQIBAAAAA==.',As='Asa:BAAAKgADCgYIBgAAAA==.Asana:BAAAKgAECgIIAgAAAA==.',Co='Copycat:BAAAKgAFFAQIBAAAAA==.',Di='Disna:BAAAKgADCgIIAgAAAA==.',Do='Dovery:BAAAKgADCgIIAgAAAA==.',Dr='Dreamer:BAAAKgAECgMIAwAAAA==.',Du='Dualsnse:BAAAKgAFFAEIAQAAAA==.',Fa='Fastrong:BAAAKgAFFAIIBAAAAA==.',Hy='Hybs:BAAAKgAFFAgIBAAAAA==.',Ju='Judgement:BAAAKgADCggICAAAAA==.',Ka='Kadenz:BAAAKgAECgYIBgAAAA==.',Lo='Locer:BAAAKgAFFAgIBAAAAA==.',Mi='Mitsuha:BAAAKgADCgMIAwAAAA==.',On='Ontheway:BAAAKgAFFAIIAgAAAA==.',Pl='Playerridmnj:BAAAKgADCgcICAAAAA==.',Py='Pyke:BAAAKgAECgUIBQAAAA==.',Re='Red:BAAAKgAECgMIAwAAAA==.',Ru='Rubine:BAABKgAFFH8GAAMCAAYITxDgHAAKAQACAAUIjBLgHAAKAQADAAEIXQf/XgA4AAAAAA==.',Si='Sillygirl:BAAAKgADCgMIAwAAAA==.Simpleline:BAAAKgAECgMIAwAAAA==.',St='Stauro:BAAAKgAECgEIAQAAAA==.',Vi='Vita:BAAAKgADCgQIBAAAAA==.',Wi='Withered:BAAAKgAECgEIAgAAAA==.',Yc='Ycy:BAAAKgAECggIDgAAAA==.',Nt='ntr:BAAAKgADCgEIAQAAAA==.',['一屋']='一屋化骨龙:BAAAKgAECgcIBwAAAA==.',['一生']='一生不愁吃喝:BAABKgAFFH8IAAIEAAgInAz0CADlAQAEAAgInAz0CADlAQAAAA==.',['一身']='一身排骨:BAABKgAECn8fAAMFAAgIWQxOPQCCAQAFAAgIWQxOPQCCAQAGAAYIygjaKQC2AAAAAA==.',['一魔']='一魔鬼精灵一:BAABKgAFFH8HAAIHAAcI4hARDQC7AQAHAAcI4hARDQC7AQAAAA==.',['一龙']='一龙:BAAAKgAECgEIAQAAAA==.',['七亿']='七亿少女的梦:BAAAKgAECggICQAAAA==.',['三千']='三千玉龙:BAAAKgAFFAQIBAAAAA==.',['上帝']='上帝就是个兽:BAABKgAFFH8JAAMIAAYI/hdGAwCoAQAIAAYItBRGAwCoAQAJAAMIsAwmLwBTAAAAAA==.上帝的寶兒:BAAAKgAECgQIBAABKgAFFAgINgAKAJgdAA==.',['不会']='不会玩丶:BAAAKgADCggICAAAAA==.',['不好']='不好吃啊:BAABKgAFFH8GAAIJAAYIDxE5EwAIAQAJAAYIDxE5EwAIAQAAAA==.',['不敢']='不敢点天赋:BAAAKgADCgcIBwAAAA==.',['丨姐']='丨姐夫丶壊蛋:BAAAKgAECgEIAQAAAA==.',['丫丫']='丫丫:BAAAKgADCgEIAQAAAA==.',['丿丶']='丿丶无影无踪:BAAAKgADCgMIAwAAAA==.',['丿夢']='丿夢魘:BAAAKgAECgIIAgAAAA==.',['乄棍']='乄棍歐巴:BAAAKgAFFAgIBAAAAA==.',['之前']='之前:BAAAKgADCgcIBwAAAA==.',['乐佩']='乐佩:BAAAKgADCggICAAAAA==.',['九五']='九五菊尊:BAABKgAFFH8IAAIBAAQInxpAJgDYAAABAAQInxpAJgDYAAAAAA==.',['今夏']='今夏:BAAAKgADCggIDgAAAA==.',['以祺']='以祺丶:BAAAKgADCgMIAwAAAA==.',['伊俐']='伊俐蛋蛋:BAAAKgAECgMIAwAAAA==.',['你的']='你的乐事:BAAAKgADCgEIAQAAAA==.',['保存']='保存心情:BAAAKgADCgcIDQAAAA==.',['元帅']='元帅战国:BAABKgAFFH8GAAIDAAYIexIOFgBHAQADAAYIexIOFgBHAQAAAA==.',['光之']='光之末裔:BAAAKgAECgMIBgAAAA==.',['克耳']='克耳苏加德:BAAAKgAECgEIAQAAAA==.',['兜兜']='兜兜里有糖糖:BAAAKgADCggICAAAAA==.',['八奈']='八奈见:BAAAKgAFFAEIAQABKgAFFAMICgALABESAA==.',['兽兽']='兽兽丷:BAAAKgADCgEIAQAAAA==.',['冷风']='冷风有幸灬:BAAAKgAFFAgIBAAAAA==.',['凯恩']='凯恩丶血蹄:BAAAKgAECggIEAAAAA==.',['刚滿']='刚滿十八岁:BAAAKgAFFAQIBAAAAA==.',['勇敢']='勇敢的心:BAAAKgADCgEIAQAAAA==.',['卜露']='卜露露:BAAAKgAECggIBQAAAA==.',['叶落']='叶落深秋:BAAAKgAECggIDgAAAA==.',['吉姆']='吉姆格麟:BAAAKgAECgcIDwAAAA==.',['吉米']='吉米:BAAAKgAECgYIBgAAAA==.',['吗喽']='吗喽命也是命:BAAAKgADCgcICAAAAA==.',['呆呆']='呆呆鸟:BAAAKgAECgYIDwAAAA==.',['咖啡']='咖啡加点糖:BAAAKgADCgUIBQAAAA==.',['咸者']='咸者芝士:BAAAKgADCgMIAwAAAA==.',['哈拉']='哈拉比:BAAAKgAECgUIBQAAAA==.',['哐哐']='哐哐加:BAAAKgADCggICAAAAA==.',['啥都']='啥都想试小德:BAAAKgAFFAIIAgAAAA==.啥都想试试:BAACKgAFFH8GAAIMAAIIDA6kIQCBAAAMAAIIDA6kIQCBAAAqAAQKfxkAAgwACAjqFiwjANoBAAwACAjqFiwjANoBAAAA.',['嘢蠻']='嘢蠻芭比:BAABKgAFFH8KAAINAAYIeBb9EwBZAQANAAYIeBb9EwBZAQAAAA==.',['噬魂']='噬魂之爪:BAABKgAFFH8IAAIOAAgIBhz8AQBiAgAOAAgIBhz8AQBiAgAAAA==.',['嚎呦']='嚎呦跟:BAAAKgAECgEIAQAAAA==.',['团子']='团子萌萌哒:BAAAKgAECgYIBwAAAA==.',['圣光']='圣光泡泡:BAAAKgAECgIIAgAAAA==.',['圣骑']='圣骑小妹:BAAAKgAECggIEwAAAA==.',['地狱']='地狱未满:BAABKgAFFH8GAAILAAYI7wqMDgAwAQALAAYI7wqMDgAwAQAAAA==.',['坊屋']='坊屋春道:BAABKgAFFH8GAAIEAAYIpxNQEABoAQAEAAYIpxNQEABoAQAAAA==.',['坦格']='坦格利安:BAACKgAFFH8KAAMPAAMIFBPqFwDJAAAPAAMIFBPqFwDJAAAFAAIINATZMgBfAAAqAAQKfx0AAwUACAjlFy82AKYBAAUABwhnFC82AKYBAA8ABAi6FPU2AA4BAAAA.',['塔夫']='塔夫:BAAAKgADCgcIBwAAAA==.',['墨尘']='墨尘熙:BAAAKgADCgQIBAAAAA==.',['复活']='复活节环环:BAAAKgAFFAEIAQAAAA==.复活节酒桶:BAACKgAFFH8QAAIQAAQI7RcFEgDSAAAQAAQI7RcFEgDSAAAqAAQKfyUAAxAACAhrHU4XACUCABAACAhrHU4XACUCABEAAQj0AQAAAAAAAAAA.',['夏多']='夏多拉格尼尔:BAAAKgAECgQIBQAAAA==.',['夏日']='夏日清凉:BAAAKgAFFAIIAgAAAA==.',['夏颉']='夏颉:BAAAKgAECgcIEwAAAA==.',['大聪']='大聪明殿下:BAABKgAFFH8JAAMCAAYInB+uCgCrAQACAAYInB+uCgCrAQADAAMIlB/4DQAXAQAAAA==.',['天下']='天下第一魔女:BAAAKgADCgQIBAAAAA==.',['天空']='天空的畅想:BAACKgAFFH8IAAIHAAIIxASALQBQAAAHAAIIxASALQBQAAAqAAQKfxkAAwcABwgRE5EtAF8BAAcABwgRE5EtAF8BABIAAQiwBFGAACwAAAAA.',['天道']='天道有眷:BAAAKgAECgUICAAAAA==.',['天隙']='天隙流光:BAAAKgAECgIIAgAAAA==.',['奥德']='奥德斯:BAACKgAFFH8JAAIDAAMIURoMKADlAAADAAMIURoMKADlAAAqAAQKfyEAAgMACAgsIhEIAJICAAMACAgsIhEIAJICAAAA.',['女武']='女武神徳拉卡:BAAAKgAECgEIAQAAAA==.',['妖巫']='妖巫王丶:BAAAKgADCggICQAAAA==.',['妖豓']='妖豓涂鴉:BAAAKgAECgQIBAAAAA==.',['娃娃']='娃娃:BAAAKgAFFAIIAgAAAA==.',['媾合']='媾合:BAAAKgAECgYICgAAAA==.',['存在']='存在锕:BAAAKgAECgIIAgAAAA==.',['学习']='学习与实践:BAECKgAFFH8RAAITAAQI5xeaCQADAQATAAQI5xeaCQADAQAqAAQKfzUAAhMACAikI04OAGcCABMACAikI04OAGcCAAAA.',['学术']='学术混子:BAAAKgAFFAYIAgAAAA==.',['安安']='安安乖宝宝:BAAAKgAECgEIAQABKgAFFAgICAAUAEwYAA==.',['安小']='安小宝:BAAAKgAFFAQIBAAAAA==.',['安德']='安德丽娅:BAABKgAFFH8IAAIVAAgIGgkTBwBhAQAVAAgIGgkTBwBhAQAAAA==.',['完美']='完美战车:BAAAKgAECgMIAwAAAA==.',['宝儿']='宝儿姐:BAABKgAFFH8HAAIWAAYInghuIwDJAAAWAAYInghuIwDJAAAAAA==.',['寒山']='寒山独见:BAAAKgADCggICAAAAA==.',['封于']='封于修:BAAAKgAECgcICwAAAA==.',['小兔']='小兔叽叽:BAAAKgADCgMIAwAAAA==.',['小动']='小动物终结者:BAABKgAECn8bAAICAAgI5hgzGAAPAgACAAgI5hgzGAAPAgAAAA==.',['小满']='小满满:BAAAKgAECggIDQAAAA==.',['小火']='小火柴丶:BAAAKgAFFAEIAQAAAA==.',['小皮']='小皮娘:BAABKgAFFH8FAAIHAAUITwt+FQBYAQAHAAUITwt+FQBYAQAAAA==.',['小老']='小老头:BAAAKgADCgMIAwAAAA==.',['尐七']='尐七:BAAAKgAECggICAABKgAFFAgIFQAXAK4kAA==.',['尐灬']='尐灬丨哀木涕:BAAAKgADCgMIAwAAAA==.',['尘墨']='尘墨池:BAAAKgAECggIEQAAAA==.',['尘封']='尘封的旋律:BAABKgAFFH8IAAMPAAgIIQ9/AgB/AQAPAAQIHBB/AgB/AQAFAAQI0w0mFADmAAAAAA==.',['尤娜']='尤娜塔斯:BAACKgAFFH8KAAILAAMIERIpIwC0AAALAAMIERIpIwC0AAAqAAQKfxwAAxgACAhSFI8OAHgBABgACAhSFI8OAHgBAAsABAgNFz9DALoAAAAA.',['尼可']='尼可罗罗:BAAAKgAECgEIAQAAAA==.',['尼尔']='尼尔斐:BAAAKgAFFAQIBAAAAA==.',['山河']='山河:BAAAKgADCgYIBgAAAA==.',['布袋']='布袋果子:BAAAKgADCggIDwAAAA==.',['帝皇']='帝皇的猎魔人:BAAAKgAECgQIBAAAAA==.',['幽冥']='幽冥道哥:BAAAKgADCggICAAAAA==.',['弄影']='弄影:BAAAKgAECgIIAgAAAA==.',['强效']='强效炎爆术:BAAAKgADCgMIAwAAAA==.',['彼岸']='彼岸花丶:BAAAKgADCggICAAAAA==.',['恶魔']='恶魔的背影:BAABKgAFFH8MAAMHAAYIKxteBABuAQAHAAUITxteBABuAQASAAEImRq5EQBdAAABKgAFFAgIAgAZAAAAAA==.',['我在']='我在你心:BAAAKgADCgQIBAAAAA==.',['戰士']='戰士:BAAAKgADCgEIAQAAAA==.',['戰天']='戰天龍:BAAAKgAECggICAAAAA==.',['扒蒜']='扒蒜老洪:BAAAKgAECggIEQAAAA==.',['把酒']='把酒问青天儿:BAAAKgAECgQIBAAAAA==.',['拂晓']='拂晓吹:BAAAKgADCggICAAAAA==.',['拿铁']='拿铁加冰:BAABKgAFFH8HAAMaAAYIfhcKFgBoAQAaAAUIYRwKFgBoAQAOAAIIahuiHwCtAAAAAA==.',['挡我']='挡我死:BAAAKgAECgQIBAAAAA==.',['摸一']='摸一嗷:BAAAKgAECggICgAAAA==.',['改名']='改名五十:BAAAKgAECgEIAQAAAA==.',['敬你']='敬你一杯酒:BAABKgAFFH8GAAIHAAYIOg2WTwA0AAAHAAYIOg2WTwA0AAAAAA==.',['无名']='无名的人:BAAAKgAECgEIAQAAAA==.',['无尽']='无尽夜幕:BAABKgAFFH8IAAIEAAgI8Qg2CgDBAQAEAAgI8Qg2CgDBAQAAAA==.',['无心']='无心绽放:BAAAKgAECgEIAQAAAA==.',['无敌']='无敌嘟嘟:BAABKgAFFH8GAAIDAAYIVwj4EAAWAQADAAYIVwj4EAAWAQAAAA==.',['无有']='无有字符:BAAAKgAECgYIBwAAAA==.',['无限']='无限魅力:BAAAKgAECgUIBQAAAA==.',['时空']='时空猎手:BAAAKgADCgcICAAAAA==.',['星月']='星月迷途:BAAAKgAFFAQIBAABKgAFFAgICAANAOcMAA==.',['暗里']='暗里着迷:BAAAKgAECgcICgAAAA==.',['曉狐']='曉狐狸:BAAAKgADCgYIBgAAAA==.',['曼陀']='曼陀羅怒风:BAAAKgAECgQIBwAAAA==.',['曾强']='曾强萨:BAAAKgADCgcIBwAAAA==.',['最美']='最美滴瑜瑜:BAAAKgAECgYIBgAAAA==.',['會發']='會發光的黑手:BAAAKgAECgQIBwAAAA==.',['朵儿']='朵儿:BAABKgAFFH8HAAIVAAYIDAs8EwDhAAAVAAYIDAs8EwDhAAAAAA==.',['杨喵']='杨喵喵:BAAAKgAECgcIBwAAAA==.',['杪肆']='杪肆凉酒:BAABKgAFFH8GAAIbAAYIBgwfEgBEAQAbAAYIBgwfEgBEAQAAAA==.',['柒度']='柒度:BAAAKgAECgEIAQAAAA==.',['柒芯']='柒芯海棠:BAABKgAFFH8IAAMaAAQIURi4NgDDAAAaAAQIURi4NgDDAAAOAAQIPgjyEACtAAAAAA==.',['栤咖']='栤咖啡:BAAAKgAECgIIAgAAAA==.',['森林']='森林里的椰子:BAABKgAFFH8HAAILAAQIXh0jCgD+AAALAAQIXh0jCgD+AAAAAA==.森林里的风铃:BAACKgAFFH8QAAMDAAYIChJICQA6AQADAAYI9A1ICQA6AQAcAAIIqhSQBACPAAAqAAQKfxQAAwMACAiuHFouAPIBAAMACAiuHFouAPIBABwAAQhrE1wcAEgAAAAA.',['槑槑']='槑槑:BAAAKgAECgMIAwAAAA==.',['残隠']='残隠殇丶玥:BAACKgAFFH8WAAMXAAQIMSHWFADDAAAXAAQIMSHWFADDAAAEAAMIqQ+GNwCEAAAqAAQKfy4AAxcACAjEIJ8TAGECABcACAjEIJ8TAGECAAQABgjvGgY2AHMBAAEqAAUUCAgIAAQAuhIA.',['永无']='永无止境:BAAAKgAFFAQIBAAAAA==.',['沉默']='沉默的高洋:BAAAKgAECggICAAAAA==.',['法泽']='法泽尔跌地:BAAAKgAECgYIBgAAAA==.',['泪无']='泪无痕:BAAAKgAFFAIIBAAAAA==.',['洛丹']='洛丹伦的母牛:BAAAKgADCggICAAAAA==.洛丹伦的荣耀:BAAAKgAECgEIAQAAAA==.',['灭杀']='灭杀:BAAAKgAFFAQIBAAAAA==.',['炮火']='炮火玫瑰:BAAAKgAECgUIBQAAAA==.',['烫了']='烫了个发灬:BAAAKgAECgEIAQAAAA==.',['爱马']='爱马仕橘:BAAAKgAECggIDAAAAA==.',['牛中']='牛中的战斗牛:BAABKgAECn8vAAMOAAgI5Bp8FwAIAgAOAAgI5Bp8FwAIAgAdAAEIZAAAAAAAAAAAAA==.',['牛年']='牛年大吉:BAAAKgADCgMIAwAAAA==.',['牧光']='牧光星野:BAAAKgAECggIDgAAAA==.',['狂浪']='狂浪啊狂浪:BAABKgAFFH8JAAIMAAcIXwWcFQD3AAAMAAcIXwWcFQD3AAAAAA==.',['狗蛋']='狗蛋:BAAAKgAECgIIAgAAAA==.',['猎兔']='猎兔犬:BAAAKgAFFAIIAwAAAA==.',['猎小']='猎小猎:BAABKgAECn8eAAIDAAgItBEtbgBoAQADAAgItBEtbgBoAQAAAA==.',['猛牛']='猛牛纯牛奶:BAABKgAECn8hAAMbAAgITAu0WQAeAQAbAAgITAu0WQAeAQAUAAEIBAPSfwAeAAAAAA==.',['玖怜']='玖怜:BAAAKgAECgUICwAAAA==.',['玩好']='玩好就去学习:BAACKgAFFH8KAAMXAAYIwx9qBgD8AAAWAAYIfx6WCQCgAQAXAAQI/hRqBgD8AAAqAAQKfxQAAhcACAi1ImYOAI8CABcACAi1ImYOAI8CAAAA.玩好立刻学习:BAAAKgAFFAQIBAABKgAFFAgICAAJAL0eAA==.',['玩完']='玩完就去学习:BAAAKgAFFAgIBAAAAA==.玩完马上学习:BAAAKgAFFAEIAQAAAA==.',['玩手']='玩手电的黑猫:BAAAKgAECgYIBgAAAA==.',['玩爆']='玩爆青春:BAAAKgAECggICAAAAA==.',['珠穆']='珠穆朗玛:BAAAKgAECgEIAQAAAA==.',['甜妹']='甜妹妹:BAABKgAFFH8MAAMeAAQIEhLtCAC+AAANAAQIuw2qGgDaAAAeAAQInhHtCAC+AAAAAA==.',['电疗']='电疗萨:BAAAKgAECgYIBgAAAA==.',['白骑']='白骑大队长:BAAAKgAECgUIBwAAAA==.',['看你']='看你那猴样:BAAAKgAECgcIBwAAAA==.',['眷恋']='眷恋咖啡:BAAAKgAECggICQAAAA==.',['石原']='石原里美:BAABKgAFFH8cAAMSAAgIHx2uAQA1AQAHAAgI3RyxBwAVAgASAAUIlROuAQA1AQAAAA==.',['神之']='神之小锅:BAABKgAFFH8IAAIVAAgI6BCBBQCkAQAVAAgI6BCBBQCkAQAAAA==.',['禁止']='禁止心碎:BAABKgAFFH8GAAILAAYI3xQfDwBuAQALAAYI3xQfDwBuAQAAAA==.',['种草']='种草莓:BAABKgAFFH8LAAIJAAQICwv+FQCeAAAJAAQICwv+FQCeAAAAAA==.',['稀有']='稀有图腾师:BAAAKgADCgMIAwAAAA==.',['突然']='突然好想你丶:BAABKgAFFH8UAAMJAAYI3xWADABLAQAJAAYI6xSADABLAQAIAAQIChpSJwDxAAAAAA==.',['粥润']='粥润发:BAACKgAFFH89AAQPAAYIahDCBwAuAQAPAAYIZhDCBwAuAQAGAAYI+gMeCwCyAAAFAAEIAACaIgAAAAAqAAQKfyYABAYACAgMB+ouAL0AAAYACAgrBuouAL0AAAUABgjbA1FpALEAAA8ABwj+BNBIAKoAAAAA.',['糖门']='糖门冰糖:BAAAKgAECgEIAQAAAA==.',['紫夜']='紫夜凋零:BAAAKgAECggIEAAAAA==.',['纳兹']='纳兹戈林将军:BAAAKgAECgYIBgAAAA==.',['织女']='织女星的凝望:BAABKgAFFH8MAAMfAAMIax1IDwDeAAAfAAMIax1IDwDeAAAKAAEIaQjTLwA3AAAAAA==.',['绿肥']='绿肥紅瘦:BAABKgAFFH8GAAIYAAYIyBPFAgAzAQAYAAYIyBPFAgAzAQAAAA==.',['群尸']='群尸玩过界:BAABKgAECn8XAAIgAAgI7RLmLQBvAQAgAAgI7RLmLQBvAQAAAA==.',['羽然']='羽然:BAAAKgADCgEIAgAAAA==.',['翎丨']='翎丨苹果派:BAAAKgAECgYIBgABKgAFFAgIAgAEAAIWAA==.',['翎兰']='翎兰:BAABKgAFFH8MAAIBAAYIHB9nBAB/AQABAAYIHB9nBAB/AQAAAA==.',['翡翠']='翡翠捕梦者:BAABKgAECn8YAAIaAAgI7CNSDwCtAgAaAAgI7CNSDwCtAgAAAA==.',['老孟']='老孟:BAAAKgAECgQIBAAAAA==.',['耳语']='耳语声烦:BAAAKgAFFAQIBAAAAA==.',['聂丶']='聂丶小倩:BAAAKgAECgIIAgAAAA==.',['聖贤']='聖贤:BAAAKgAECgYIBgAAAA==.',['肆意']='肆意的射击:BAAAKgADCgIIAgAAAA==.',['腐烂']='腐烂的南瓜:BAAAKgADCgYIBgAAAA==.',['舞动']='舞动全球:BAAAKgADCgEIAQAAAA==.',['节约']='节约:BAABKgAFFH8HAAIHAAMInQnnGwCiAAAHAAMInQnnGwCiAAAAAA==.',['芙兰']='芙兰朵露:BAAAKgAECgMIAwAAAA==.',['英雄']='英雄的心恶魔:BAAAKgAECgIIAgAAAA==.',['莉亚']='莉亚德琳丶:BAAAKgAFFAEIAQAAAA==.',['菊花']='菊花乱突突:BAAAKgAFFAgIBAAAAA==.',['萨哇']='萨哇迪咖:BAAAKgADCgEIAQAAAA==.',['落花']='落花幽幽:BAAAKgADCgcIBwAAAA==.',['血腥']='血腥飝非飛:BAACKgAFFH8JAAIXAAMIsBnrFQC/AAAXAAMIsBnrFQC/AAAqAAQKfyUAAhcACAhLIR4NAJkCABcACAhLIR4NAJkCAAAA.',['血色']='血色大领主:BAAAKgADCggICAAAAA==.',['親爱']='親爱灬德:BAABKgAECn8WAAIOAAgI9RY1IgCMAQAOAAgI9RY1IgCMAQAAAA==.',['贰叁']='贰叁肆:BAAAKgAFFAYIBAABKgAFFAgIBgAKAHQcAA==.',['贼能']='贼能活:BAAAKgADCggIDQAAAA==.',['赞赞']='赞赞敲可爱:BAAAKgADCgEIAgAAAA==.',['辰曦']='辰曦:BAACKgAFFH8HAAIBAAMIcxI1KwC6AAABAAMIcxI1KwC6AAAqAAQKfxkAAgEACAg2IM07ABICAAEACAg2IM07ABICAAAA.',['这个']='这个老登:BAAAKgAECgUIDAAAAA==.',['迪俪']='迪俪热巴:BAACKgAFFH8UAAMbAAMIsCGcEgDZAAAbAAMIsCGcEgDZAAAUAAMIUQ1QFwC7AAAqAAQKfyYABBsACAj9IqAVAFMCABsACAj9IqAVAFMCABMACAgUDc4jAKkBABQABQgjGQ48AB8BAAAA.',['遇术']='遇术淋疯:BAABKgAFFH8GAAIHAAYIEwiMGwAqAQAHAAYIEwiMGwAqAQAAAA==.',['邪恶']='邪恶烙印:BAAAKgAECggIDQAAAA==.邪恶的南瓜:BAAAKgAECgYIEAAAAA==.',['酒斗']='酒斗麻袋:BAABKgAFFH8IAAMKAAgIxxshBAAkAgAKAAcIzB0hBAAkAgAgAAEIfRT+PABJAAAAAA==.',['鉛華']='鉛華淡淡妝成:BAAAKgADCgcIBwAAAA==.',['银月']='银月:BAABKgAFFH8NAAMgAAgIMyPkBgACAQAfAAUIXiEECgB3AQAgAAcIPh/kBgACAQAAAA==.',['锐雯']='锐雯:BAAAKgAECgcIEwAAAA==.',['阿仁']='阿仁开无敌:BAAAKgAECggIEAAAAA==.',['阿布']='阿布集团总裁:BAABKgAFFH8GAAIBAAYIvBINAwCqAQABAAYIvBINAwCqAQAAAA==.',['陵南']='陵南:BAAAKgAECgUIBQAAAA==.',['雪融']='雪融融:BAAAKgAECgQIBgAAAA==.',['雾漫']='雾漫了風景:BAAAKgAECgYIBgAAAA==.',['風行']='風行者的挽歌:BAAAKgAECgMIAwAAAA==.',['驱灵']='驱灵人:BAACKgAFFH8OAAMgAAgIvhAuDABgAQAgAAcIPg8uDABgAQAKAAYI0RRVCgBbAQAqAAQKfxsAAyAABwhDH+giALEBACAABwhDH+giALEBAAoABQgnDFdEAKIAAAAA.',['骑猪']='骑猪去流浪:BAAAKgAECgQIBAAAAA==.',['鬼迷']='鬼迷日眼:BAAAKgAECgYIBgAAAA==.',['魔兽']='魔兽筋肉人:BAAAKgAFFAQIBAAAAA==.',['鱼丸']='鱼丸粗面:BAABKgAFFH8IAAIbAAIIVgtqJQBYAAAbAAIIVgtqJQBYAAAAAA==.',['鸡蛋']='鸡蛋饼:BAAAKgADCggICAAAAA==.',['黏黏']='黏黏小豆包:BAAAKgADCggICAAAAA==.',['黑暗']='黑暗救赎者:BAAAKgAECgIIAgAAAA==.黑暗阿尔法:BAAAKgAECgcIBwAAAA==.',['黑牛']='黑牛怪兽:BAAAKgAECgYICAAAAA==.',['黑锋']='黑锋研究员:BAAAKgADCggICwAAAA==.',['黯沐']='黯沐:BAABKgAFFH8GAAIfAAYIKgz0NwAAAAAfAAYIKgz0NwAAAAAAAA==.',['龍灬']='龍灬魂:BAAAKgAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end