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
 local lookup = {'DemonHunter-Havoc','Priest-Holy','Priest-Shadow','Priest-Discipline','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Restoration','Paladin-Retribution','Rogue-Assassination','Warrior-Fury','DeathKnight-Blood','DeathKnight-Unholy','Shaman-Elemental','Evoker-Devastation','Monk-Windwalker','Paladin-Protection','Monk-Mistweaver','Monk-Brewmaster','DeathKnight-Frost','Warrior-Protection','Druid-Restoration','Druid-Guardian','Druid-Balance','DemonHunter-Vengeance','Mage-Frost','Warrior-Arms','Mage-Arcane','Paladin-Holy','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Evoker-Preservation','Unknown-Unknown','Rogue-Outlaw','Rogue-Subtlety','Mage-Fire','Hunter-Survival',}; local provider = {region='CN',realm='血牙魔王',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aibe:BAAAKgADCgUIBQAAAA==.',Al='Allicee:BAABKgAFFH8KAAIBAAYIXxk9AgDQAQABAAYIXxk9AgDQAQAAAA==.Aluba:BAABKgAFFH8SAAQCAAYIgBygDABaAQACAAYIchegDABaAQADAAQI9RxjCgALAQAEAAQI3BhiCgACAQAAAA==.',Am='Amaranta:BAAAKgAFFAcIAgAAAA==.',As='Astrea:BAAAKgAECggICgAAAA==.',Bg='Bgvrbr:BAABKgAFFH8SAAMFAAYIMiMJCADeAQAFAAYIMiMJCADeAQAGAAQIcRywFgD0AAAAAA==.',Bu='Burninglegi:BAAAKgADCgYIBgAAAA==.',Da='Dahfey:BAAAKgAFFAQIBAAAAA==.Davidzhuo:BAABKgAECn8jAAIHAAgIyRZmNwCYAQAHAAgIyRZmNwCYAQAAAA==.Daxiang:BAAAKgAECggIBwAAAA==.',De='Deadpool:BAAAKgAECgQIBAAAAA==.',Di='Dianevas:BAAAKgAFFAIIAgAAAA==.',El='Elfknight:BAABKgAFFH8IAAIIAAMIAR9xQQDtAAAIAAMIAR9xQQDtAAAAAA==.',En='Endman:BAABKgAFFH8KAAIJAAMIHQW5HwCqAAAJAAMIHQW5HwCqAAAAAA==.',Ep='Epos:BAAAKgADCgEIAQAAAA==.',Fe='Ferguson:BAAAKgAFFAYIBAAAAA==.',Fi='Firenze:BAACKgAFFH8gAAIJAAYIqhj7AQC0AQAJAAYIqhj7AQC0AQAqAAQKfxUAAgkACAgeGfgZAJkBAAkACAgeGfgZAJkBAAAA.',Fm='Fmruyuan:BAAAKgAFFAUIAwAAAA==.',Ga='Gadget:BAABKgAFFH8GAAIKAAYIiBxCDgBuAQAKAAYIiBxCDgBuAQAAAA==.',Li='Lililala:BAAAKgAECgUIBwAAAA==.',Lo='Lookyo:BAABKgAFFH8HAAICAAcIJREzCQCRAQACAAcIJREzCQCRAQAAAA==.Lookyu:BAAAKgAFFAQIBAAAAA==.',Ma='Marklee:BAAAKgADCgcICgAAAA==.',Mi='Mione:BAABKgAFFH8GAAILAAYIrR6yAADmAQALAAYIrR6yAADmAQABKgAFFAgIEgAMAIMXAA==.',Mk='Mklee:BAAAKgADCggICgAAAA==.',Mm='Mmk:BAAAKgADCgYIBgAAAA==.',Mo='Monarchii:BAAAKgAFFAEIAQAAAA==.',No='Noroi:BAAAKgAECgQIBAAAAA==.Notleaving:BAAAKgAECgIIAgAAAA==.',Ol='Olzx:BAAAKgAFFAMIAwAAAA==.',Pa='Patchouli:BAAAKgAECgcICwAAAA==.',Pl='Playerhnvmhk:BAAAKgADCggICwAAAA==.Playerlslfaf:BAAAKgAFFAEIAQAAAA==.',Ra='Ravenous:BAABKgAFFH8LAAILAAYIkRtDAwBgAQALAAYIkRtDAwBgAQABKgAFFAgIFgAKANkUAA==.',Re='Reverence:BAABKgAFFH8OAAMHAAgI5AyRCAC+AQAHAAgI5AyRCAC+AQANAAIIUg/nFQBzAAAAAA==.',Rf='Rfin:BAAAKgAECgMIAwAAAA==.',Sa='Sampdoria:BAAAKgAECgUIDAAAAA==.',Sc='Scarletts:BAAAKgADCgUIBQAAAA==.',Sl='Slamander:BAAAKgAECggIDQAAAA==.',Ss='Ssa:BAAAKgAECgEIAQAAAA==.',Su='Subert:BAABKgAECn8kAAIMAAgIGiNKEACJAgAMAAgIGiNKEACJAgAAAA==.',Sw='Swan:BAAAKgAECgYICQAAAA==.',Tc='Tcakel:BAAAKgADCgIIAgAAAA==.',Ti='Titansnova:BAAAKgAFFAEIAQAAAA==.',Tp='Tproofsm:BAAAKgADCggICAAAAA==.',Wa='Wandamaximof:BAAAKgADCgYICwAAAA==.',Yo='Yokilo:BAAAKgADCgQIBAAAAA==.',Zo='Zobie:BAABKgAFFH8HAAINAAQIfAh/DwCmAAANAAQIfAh/DwCmAAAAAA==.',Zy='Zyr:BAAAKgADCggICgAAAA==.',Zz='Zzhappy:BAAAKgADCgQIBAAAAA==.',['一个']='一个人旅行:BAAAKgADCggICAAAAA==.',['一定']='一定是你喝:BAAAKgAECggICQAAAA==.',['一点']='一点可爱:BAAAKgAFFAYIBAAAAA==.',['一箭']='一箭倾情:BAAAKgADCggICAAAAA==.',['一粒']='一粒疍:BAAAKgADCgcIBwAAAA==.',['三加']='三加五德二:BAAAKgAFFAEIAQAAAA==.',['三皇']='三皇五帝:BAAAKgAECgcIBwAAAA==.',['三级']='三级人品光环:BAAAKgAECgEIAQAAAA==.',['上善']='上善若水丶:BAAAKgAECgMIAwAAAA==.',['上帝']='上帝也凶残:BAAAKgAECgEIAQAAAA==.',['不主']='不主动可负责:BAABKgAECn8XAAIOAAcIqCD+EwAiAgAOAAcIqCD+EwAiAgABKgAFFAQIEgAPALogAA==.',['不会']='不会就消费:BAABKgAECn8YAAMIAAgIrB03LgBHAgAIAAcIjiI3LgBHAgAQAAYIMQB6cAADAAAAAA==.',['不觉']='不觉细雨:BAABKgAFFH8IAAIJAAgIKwd5CADdAQAJAAgIKwd5CADdAQAAAA==.',['丑奴']='丑奴儿:BAAAKgAECgYICAAAAA==.',['东方']='东方术爷:BAAAKgAECggIBgAAAA==.',['东风']='东风谷早苗:BAABKgAFFH8FAAMEAAQI/yXLDABJAQAEAAQI/yXLDABJAQACAAEIaAbpQgAoAAAAAA==.',['丨乌']='丨乌冬丨:BAABKgAFFH8NAAMRAAYI2AtNBAB6AQARAAYI2AtNBAB6AQASAAQI9RbaAwC9AAAAAA==.',['丨寒']='丨寒舞丨:BAABKgAFFH8GAAICAAIIrh5CEwCnAAACAAIIrh5CEwCnAAAAAA==.',['丨戰']='丨戰士丶:BAAAKgAECgcIBwAAAA==.',['丨米']='丨米咕咕丨:BAAAKgAECgYIBgAAAA==.',['丨萌']='丨萌丨:BAAAKgAFFAgIAwAAAA==.',['丰川']='丰川祥子:BAAAKgAFFAQIBAAAAA==.',['丶小']='丶小球球:BAAAKgAECgYIBgAAAA==.',['主任']='主任灬小秘:BAAAKgAECgYIBgAAAA==.',['丿儸']='丿儸丶煞丨:BAAAKgAECggIEgAAAA==.',['丿无']='丿无声无息灬:BAAAKgAECggICAAAAA==.',['丿浅']='丿浅丶浅:BAAAKgAFFAQIBAABKgAFFAQIFwAIAMkiAA==.',['丿猎']='丿猎手丶儸刹:BAAAKgAECgYIBgAAAA==.',['丿茶']='丿茶小德:BAAAKgAECgEIAgAAAA==.',['乖乖']='乖乖龙滴冻:BAAAKgADCgMIAwAAAA==.',['乱一']='乱一咪一咪:BAACKgAFFH8fAAMTAAMIJhcTCQDXAAATAAMIJhcTCQDXAAALAAIIvwGyEwA9AAAqAAQKfywAAhMACAiSH1EIADoCABMACAiSH1EIADoCAAAA.',['乱三']='乱三咪三咪:BAAAKgAECgcIBwAAAA==.',['乱二']='乱二咪二咪:BAACKgAFFH8MAAIGAAMIkxq7KADiAAAGAAMIkxq7KADiAAAqAAQKfyQAAgYACAjBG8Y5AA8CAAYACAjBG8Y5AA8CAAAA.',['乱八']='乱八咪八咪:BAAAKgAFFAMIAwAAAA==.',['二队']='二队慕斯:BAAAKgAFFAQIBAAAAA==.二队術爺:BAAAKgADCgMIAwAAAA==.',['云汀']='云汀:BAABKgAFFH8GAAMDAAQIOwyoFgCvAAADAAMI6QuoFgCvAAACAAIIVQ4VMACGAAAAAA==.',['五百']='五百年前的刀:BAAAKgAFFAQIBAAAAA==.',['五福']='五福:BAAAKgADCggIAgAAAA==.',['亚修']='亚修拉姆:BAAAKgAFFAYIAQAAAA==.',['亚瑟']='亚瑟凯恩:BAAAKgAFFAQIBAAAAA==.',['亚索']='亚索:BAAAKgADCggICAAAAA==.',['亚达']='亚达:BAAAKgADCgYIBgAAAA==.',['亲切']='亲切妹妹:BAAAKgAECggICAAAAA==.',['人小']='人小子巴大:BAAAKgAECggICAAAAA==.',['人无']='人无再少年:BAABKgAFFH8GAAMKAAQIeRQRDwD+AAAKAAQIeRQRDwD+AAAUAAIIhwRjCwBbAAAAAA==.',['以德']='以德不悔:BAAAKgAECgEIAQAAAA==.以德丨服人:BAAAKgADCgEIAQAAAA==.',['企鹅']='企鹅人:BAAAKgADCggICAAAAA==.',['伊人']='伊人憔悴:BAABKgAECn8bAAQVAAgI9wdiUQDIAAAVAAcIWAZiUQDIAAAWAAEI1QvzMgAlAAAXAAEIAADM7wAAAAAAAA==.',['伊利']='伊利蛋灬鲁风:BAABKgAECn8qAAIYAAgIahCHJgBGAQAYAAgIahCHJgBGAQAAAA==.',['休宁']='休宁:BAAAKgADCgIIAgAAAA==.',['优化']='优化大师:BAAAKgADCgUIBQAAAA==.',['伸缩']='伸缩自如的愛:BAABKgAFFH8FAAIHAAQIbAXvGwCwAAAHAAQIbAXvGwCwAAAAAA==.',['低调']='低调大哥哥:BAAAKgAECggICAAAAA==.',['你做']='你做的菜最香:BAABKgAFFH8KAAIZAAMI6BkaEQDZAAAZAAMI6BkaEQDZAAAAAA==.',['你关']='你关的灯最黑:BAAAKgAECgEIAQAAAA==.',['保安']='保安来消费:BAAAKgAECgYIBgAAAA==.',['俺要']='俺要蜂蜜:BAAAKgADCggICAAAAA==.',['做人']='做人真难:BAAAKgAECggIDwAAAA==.',['元素']='元素的召唤:BAAAKgAFFAQIBAAAAA==.',['光明']='光明猎:BAAAKgAFFAYIAgAAAA==.',['光火']='光火啊:BAACKgAFFH8hAAQaAAcI5yEUAgBgAgAaAAcI5yEUAgBgAgAUAAEILCOeEwBfAAAKAAEIGR5QJQBeAAAqAAQKfzAABBoACAjMJaoKAHUCABoABgjBJaoKAHUCABQACAiQHp0NAAUCAAoABgggJB81AKsBAAAA.',['光能']='光能使者:BAABKgAFFH8HAAIIAAQIDhfJQwDnAAAIAAQIDhfJQwDnAAAAAA==.',['八十']='八十一个壮汉:BAAAKgAECgEIAQAAAA==.',['养狗']='养狗的大象:BAAAKgAECgEIAQAAAA==.',['再见']='再见西野:BAAAKgAFFAYIBAAAAA==.',['冰日']='冰日:BAAAKgADCgUIBQAAAA==.',['冰淇']='冰淇淋水果:BAAAKgAFFAQIBAAAAA==.',['冰火']='冰火丶子彧:BAAAKgAECggICAAAAA==.冰火丶曦彧:BAABKgAECn8VAAMZAAgIpR7NGQAzAgAZAAgIpR7NGQAzAgAbAAQImxEaHgCmAAAAAA==.',['冲锋']='冲锋下跪释放:BAABKgAFFH8FAAIMAAUIdgRyKwDfAAAMAAUIdgRyKwDfAAAAAA==.冲锋释放丶:BAACKgAFFH8gAAIIAAgIyh42BACSAgAIAAgIyh42BACSAgAqAAQKfx4ABBAACAiTHNUQAPIBABAACAhYGNUQAPIBAAgACAjEF1YlAJcBABwAAQjdEYlSADUAAAAA.',['冷如']='冷如月:BAAAKgAECgQIBAAAAA==.',['冷韵']='冷韵幽香:BAAAKgADCgQIBAAAAA==.',['凌棂']='凌棂零:BAACKgAFFH8GAAIZAAIIGwtdEQB+AAAZAAIIGwtdEQB+AAAqAAQKfxQAAhkACAjvEkItAFYBABkACAjvEkItAFYBAAAA.',['几万']='几万个恶魔:BAABKgAECn8kAAQdAAgI8CP1BADQAgAdAAgI8CP1BADQAgAeAAQIKxVnSADDAAAfAAEIVgnmRAA2AAAAAA==.',['凯奥']='凯奥斯成:BAABKgAFFH8GAAIPAAYI5xQ5BwCRAQAPAAYI5xQ5BwCRAQAAAA==.凯奥斯泰瑞:BAABKgAFFH8mAAMIAAYIXh/TEgDFAQAIAAYIXh/TEgDFAQAcAAEIKArJEAA6AAAAAA==.',['别撸']='别撸了都是泪:BAAAKgAECggICAAAAA==.',['剑血']='剑血红叶:BAAAKgADCggICAAAAA==.',['功夫']='功夫秋少:BAAAKgADCgcIDwAAAA==.',['加嘞']='加嘞比一丶:BAAAKgAECggICAAAAA==.',['努尔']='努尔哈赤丶:BAACKgAFFH8XAAQIAAQIySJEGgAUAQAIAAMIySJEGgAUAQAcAAQItyTwCADNAAAQAAEI9wQEFwAfAAAqAAQKfxgAAxwACAijIH4IAGUCABwACAijIH4IAGUCABAAAQgOF3pWAEQAAAAA.',['北虹']='北虹剑:BAABKgAFFH8IAAIXAAgIkAeUDgCKAQAXAAgIkAeUDgCKAQAAAA==.',['千刃']='千刃夜曲:BAAAKgAECgEIAQAAAA==.',['半杯']='半杯清酒丶:BAAAKgAECgUIBgAAAA==.',['南星']='南星傻鳗:BAAAKgAECgEIAQAAAA==.',['南飞']='南飞:BAAAKgADCggIDQAAAA==.',['卡修']='卡修:BAABKgAFFH8NAAIJAAYIVh14CQD5AAAJAAYIVh14CQD5AAAAAA==.',['卡莲']='卡莲:BAABKgAFFH8QAAMCAAQIOyFrBwD9AAACAAQIOyFrBwD9AAAEAAQIrAjaIgCYAAAAAA==.',['厗哆']='厗哆檑哋梚戨:BAABKgAECn8hAAIIAAgIbhFCdgBmAQAIAAgIbhFCdgBmAQAAAA==.',['双刀']='双刀贼:BAACKgAFFH8PAAMBAAMIsyPXDgAFAQABAAMIsyPXDgAFAQAYAAMIfA4XCwCfAAAqAAQKfyQAAgEACAiUIuUQAKICAAEACAiUIuUQAKICAAAA.',['发电']='发电机飞车:BAAAKgAECgcICQAAAA==.',['叫兽']='叫兽:BAACKgAFFH8NAAMKAAgIXR9IAgCvAgAKAAgIXR9IAgCvAgAaAAEI0wuBKwA8AAAqAAQKfysAAwoACAgfH5siAAsCAAoACAhmGZsiAAsCABoABwiQGt4bANQBAAAA.',['叫我']='叫我皮卡丘:BAAAKgAFFAYIAQABKgAFFAgIEwACAP0gAA==.',['可乐']='可乐不乐:BAAAKgAECgUICwAAAA==.',['史密']='史密斯专员:BAABKgAFFH8IAAIGAAgIqB2WAwCHAgAGAAgIqB2WAwCHAgAAAA==.',['叶大']='叶大娘:BAAAKgADCggICAAAAA==.',['叶孤']='叶孤陌:BAAAKgADCggICAAAAA==.',['叶红']='叶红:BAABKgAECn8WAAMHAAgIYhMMOwCaAQAHAAcIqRUMOwCaAQANAAgI3BW+LwCIAQAAAA==.',['吹梦']='吹梦到西洲:BAAAKgAECgMIAwAAAA==.',['咆哮']='咆哮丶彧虎:BAAAKgAECgYICgAAAA==.',['咒術']='咒術乄回戰:BAAAKgAECgIIAgAAAA==.',['咕二']='咕二单:BAABKgAFFH8KAAMdAAgImhIEDwCfAQAdAAYIhBIEDwCfAQAeAAQIaAdqFAChAAAAAA==.',['咸菜']='咸菜寶寶:BAABKgAFFH8FAAIGAAUIFhfgPwBpAAAGAAUIFhfgPwBpAAAAAA==.',['哈尼']='哈尼族:BAAAKgAECgYIBgAAAA==.',['哈欠']='哈欠嘻嘻脸:BAAAKgADCgEIAQAAAA==.',['哎呦']='哎呦哎呦喂:BAABKgAFFH8GAAIcAAMINwqJEwChAAAcAAMINwqJEwChAAAAAA==.',['哥伦']='哥伦布的蛋:BAABKgAFFH8IAAIHAAgIQheEAwA5AgAHAAgIQheEAwA5AgAAAA==.',['喵楽']='喵楽個咪:BAAAKgAECgYICgAAAA==.',['嘉懿']='嘉懿的天空:BAAAKgAFFAMIBAAAAA==.',['嘴平']='嘴平伊之助丶:BAAAKgAECggIEAAAAA==.',['囍犇']='囍犇:BAAAKgAFFAMIAwAAAA==.',['图灵']='图灵守护者:BAAAKgAFFAQIBAAAAA==.',['圆锥']='圆锥曲线:BAABKgAFFH8YAAMHAAgIGSG8AQCJAgAHAAgIGSG8AQCJAgANAAIIJwfNEwBuAAAAAA==.',['土御']='土御门夏目:BAACKgAFFH8HAAMGAAQI+hpcKQDgAAAGAAMIDhhcKQDgAAAFAAQIZQ+tNACgAAAqAAQKfxoAAwYACAjUHnY0ANQBAAYABwhBHnY0ANQBAAUABAjLGBFVAP0AAAAA.',['土牧']='土牧工程师:BAAAKgADCggICAAAAA==.',['圣光']='圣光之潮:BAAAKgAFFAQIBAAAAA==.',['地狱']='地狱凯撒:BAABKgAFFH8KAAMQAAYI/R7PAADSAQAQAAYI/R7PAADSAQAIAAQIaRiWHwDqAAAAAA==.',['坑我']='坑我就消费:BAABKgAECn8bAAMFAAcI6ROOQABQAQAFAAcI0RKOQABQAQAGAAEIvhxLtwBTAAAAAA==.',['坚定']='坚定四个自信:BAAAKgAECgYIBgAAAA==.',['埃辛']='埃辛诺斯怒风:BAAAKgAECggICAAAAA==.',['埋伏']='埋伏你娃:BAABKgAFFH8GAAIVAAYIYRDODQAzAQAVAAYIYRDODQAzAQAAAA==.',['埋山']='埋山山:BAACKgAFFH8VAAILAAQImgbAKQBvAAALAAQImgbAKQBvAAAqAAQKfyIAAgsACAgWDnMkACQBAAsACAgWDnMkACQBAAAA.',['城户']='城户沙织:BAABKgAFFH8GAAIIAAYIuw5AIwBfAQAIAAYIuw5AIwBfAQAAAA==.',['塔蘭']='塔蘭吉:BAABKgAFFH8GAAIIAAYIRxdtHgB3AQAIAAYIRxdtHgB3AQAAAA==.',['夕梨']='夕梨依修塔尔:BAAAKgAECgYIBwAAAA==.',['多喝']='多喝开水:BAAAKgAECgQIBAAAAA==.',['夜潞']='夜潞死酷:BAAAKgAECggIDQAAAA==.',['夜色']='夜色笼罩的路:BAAAKgADCgYIBgAAAA==.',['够不']='够不够久:BAABKgAFFH8GAAIOAAQIrgrNJwCcAAAOAAQIrgrNJwCcAAAAAA==.',['大壮']='大壮:BAABKgAFFH8HAAIMAAQIABovDwD8AAAMAAQIABovDwD8AAAAAA==.',['大萨']='大萨鲁法尔:BAAAKgADCggICAAAAA==.',['大蕉']='大蕉蕉:BAABKgAFFH8PAAMMAAcIRRkQAgDNAQAMAAYI7BsQAgDNAQALAAUIyxYoCQAEAQAAAA==.',['大路']='大路朝天:BAAAKgAECgEIAQAAAA==.',['大锤']='大锤肖:BAABKgAFFH8FAAMKAAQIhxD1JQC3AAAKAAQIcA31JQC3AAAUAAEIwg1OFwA0AAAAAA==.',['大饼']='大饼叔叔:BAAAKgAFFAQIAgAAAA==.',['天之']='天之德:BAAAKgAECgEIAQAAAA==.',['天劫']='天劫:BAAAKgAECgcIDQAAAA==.',['天在']='天在水:BAABKgAFFH8GAAIMAAYIQxg7FAB5AQAMAAYIQxg7FAB5AQABKgAFFAgICAAKALMSAA==.',['天堂']='天堂之伤:BAAAKgAECgEIAQAAAA==.天堂之靉:BAAAKgAECgYICAAAAA==.',['天子']='天子铭:BAABKgAECn8WAAIIAAgI6xvTRgAbAgAIAAgI6xvTRgAbAgAAAA==.天子铭之血骑:BAAAKgAECggICAAAAA==.',['天青']='天青惹寂寥:BAAAKgAECgMIAwAAAA==.',['太虚']='太虚古龙:BAABKgAFFH8IAAIOAAgIZwqfCQDAAQAOAAgIZwqfCQDAAQAAAA==.',['夯色']='夯色那:BAAAKgAFFAMIAwAAAA==.',['失落']='失落焱:BAAAKgAFFAQIBAAAAA==.',['头发']='头发粉打人狠:BAAAKgAFFAEIAQAAAA==.',['奥巴']='奥巴羊丶:BAAAKgAFFAYIAgAAAA==.',['奥瑞']='奥瑞莉亚:BAAAKgAFFAgIAQAAAA==.',['奶伊']='奶伊卒特:BAAAKgAECgMIAwAAAA==.',['好运']='好运来:BAABKgAECn8UAAIBAAcIyhbDTAB0AQABAAcIyhbDTAB0AQAAAA==.',['如水']='如水涣涣丶:BAAAKgADCgUIBQAAAA==.',['姐一']='姐一贱死一片:BAAAKgADCggICAAAAA==.',['威尔']='威尔逊爱德华:BAAAKgADCgMIBAAAAA==.',['娜美']='娜美:BAABKgAFFH8IAAMeAAQIog6vBgDLAAAeAAQIKwyvBgDLAAAfAAQIfAqvDADEAAABKgAFFAgIHQAfAOkaAA==.',['子夜']='子夜丶龙龖龘:BAABKgAFFH8GAAIOAAYIehodDQCRAQAOAAYIehodDQCRAQAAAA==.',['子灬']='子灬不語:BAAAKgAFFAMIAwAAAA==.',['孑璇']='孑璇:BAAAKgADCggIDgAAAA==.',['安格']='安格斯厚牛堡:BAAAKgADCgIIAgAAAA==.',['完美']='完美大领主:BAAAKgADCggICAAAAA==.',['宜嗔']='宜嗔宜喜:BAAAKgAECgEIAQAAAA==.',['宝宝']='宝宝薇薇:BAAAKgAFFAQIBAAAAA==.',['宝马']='宝马零利息:BAABKgAFFH8OAAMgAAYIwyDIAwACAQAgAAQI+B/IAwACAQAOAAUIDSD8GwBuAAABKgAFFAgIBAAhAAAAAA==.',['室女']='室女座:BAAAKgAECgEIAQAAAA==.',['家有']='家有小月亮:BAAAKgAECgEIAQAAAA==.',['容赦']='容赦姬丶:BAAAKgAFFAQIBAAAAA==.',['寂寞']='寂寞如雪落:BAAAKgADCgIIAgAAAA==.',['寒軒']='寒軒:BAAAKgAECgQIBAAAAA==.',['对风']='对风讲故事灬:BAAAKgAECggIDwAAAA==.',['封存']='封存你嘚曦:BAAAKgAFFAQIBAAAAA==.封存你旳曦:BAAAKgAECgcIBwAAAA==.封存你的曦:BAAAKgAECgQIBAAAAA==.',['射灬']='射灬灰机:BAAAKgAECgMIAwAAAA==.',['小了']='小了百了兔:BAAAKgADCgEIAQAAAA==.',['小小']='小小的天:BAABKgAFFH8GAAIHAAYIdgmkFwAjAQAHAAYIdgmkFwAjAQAAAA==.小小秋少:BAAAKgADCgYIBwAAAA==.',['小屁']='小屁儿虫:BAAAKgADCggIDwAAAA==.',['小德']='小德晓不得:BAACKgAFFH8JAAIWAAMIIRdRBgCtAAAWAAMIIRdRBgCtAAAqAAQKfxkAAxcACAhfG2YnABcCABcACAjbGWYnABcCABYABwjUEpEQAEMBAAAA.',['小柠']='小柠檬的霸霸:BAAAKgAECgMIAwAAAA==.',['小猪']='小猪快跑:BAAAKgADCggIIAAAAA==.',['尖叫']='尖叫哈尼:BAAAKgADCgMIAwAAAA==.',['就想']='就想抓个熊德:BAAAKgAFFAEIAQAAAA==.',['屁儿']='屁儿有点痒:BAAAKgADCggIDwAAAA==.',['山背']='山背后的葵花:BAACKgAFFH8ZAAIJAAQIEh6dFAAJAQAJAAQIEh6dFAAJAQAqAAQKfzwABAkACAgAHh4MAEMCAAkACAgAHh4MAEMCACIAAghVBIkZAEEAACMAAgilATM8ABsAAAAA.',['崽锅']='崽锅:BAABKgAFFH8SAAIQAAYInhIhDwAOAQAQAAYInhIhDwAOAQAAAA==.',['左转']='左转再左转:BAAAKgAECggICAAAAA==.',['巭大']='巭大师:BAAAKgAECgcICAAAAA==.',['布谷']='布谷虫:BAAAKgAECgcIDQAAAA==.',['帅到']='帅到不能自理:BAAAKgAECgcIBwAAAA==.',['希尔']='希尔瓦德斯:BAABKgAFFH8OAAIOAAUIhhasDwBmAQAOAAUIhhasDwBmAQAAAA==.',['帕娜']='帕娜克亚:BAABKgAFFH8JAAMCAAUIMAu8FgCJAAACAAQIFwy8FgCJAAAEAAEIfAgvFQBHAAAAAA==.',['年轻']='年轻就该多浪:BAAAKgAFFAIIAgAAAA==.',['幻影']='幻影奶茶:BAAAKgAECgEIAQAAAA==.',['幽冥']='幽冥:BAAAKgAECggIEAAAAA==.',['建工']='建工黄色闪电:BAABKgAFFH8GAAIHAAYI3xtkCwCRAQAHAAYI3xtkCwCRAQAAAA==.',['异乡']='异乡异客:BAAAKgAFFAEIAQAAAA==.',['归于']='归于原点:BAAAKgADCgIIAgAAAA==.归于源点:BAAAKgADCgUIBQAAAA==.',['彡宝']='彡宝可梦:BAAAKgAECgQIBAAAAA==.',['征服']='征服者康:BAACKgAFFH8dAAIIAAgIxyCEDQD5AQAIAAgIxyCEDQD5AQAqAAQKfxwAAggACAjuJUoFAAcDAAgACAjuJUoFAAcDAAAA.',['很强']='很强灬大牛:BAAAKgADCgMIAwAAAA==.',['御坂']='御坂妹:BAAAKgADCggICAAAAA==.',['微笑']='微笑的迪妮沙:BAAAKgAECgEIAQAAAA==.',['心灵']='心灵导师:BAAAKgAECgQIBwAAAA==.',['心里']='心里的年华:BAABKgAFFH8FAAMVAAIIbhXaIgCbAAAVAAIIbhXaIgCbAAAXAAEIlSRXVABlAAAAAA==.',['怀念']='怀念贰零零伍:BAAAKgAECgMIBAAAAA==.',['思君']='思君如满弦:BAAAKgAECgMIAwAAAA==.',['恋上']='恋上下雪天丶:BAAAKgAECgUIBQAAAA==.',['恩迪']='恩迪:BAAAKgAECgYICgAAAA==.',['恶魔']='恶魔张猫咪:BAAAKgADCggIEwAAAA==.',['悲秋']='悲秋:BAAAKgAECggICAAAAA==.',['惡靈']='惡靈退散:BAABKgAFFH8IAAIIAAgIGxWzCAAiAgAIAAgIGxWzCAAiAgAAAA==.',['惡魔']='惡魔猎手:BAAAKgAECgcICgAAAA==.',['愛灬']='愛灬双双:BAAAKgAFFAYIBAAAAA==.',['慕名']='慕名:BAABKgAECn8XAAIGAAgIQR0TIwAuAgAGAAgIQR0TIwAuAgAAAA==.',['我就']='我就爱划水:BAACKgAFFH8IAAMeAAMIoRFiDwBxAAAeAAIIbRRiDwBxAAAdAAEICAzKUAAwAAAqAAQKfycAAx4ACAhdHZsRAPEBAB4ABwiwHZsRAPEBAB0ABAhrGl0/AA4BAAAA.',['我想']='我想多喝热水:BAAAKgAECgMIAwAAAA==.',['我是']='我是真的丑:BAAAKgAECggIEwAAAA==.我是胖胖:BAABKgAFFH8IAAMHAAgIXAdpFADSAAAHAAUI5AJpFADSAAANAAMI9QXvEACXAAAAAA==.',['我爱']='我爱鱼豆腐:BAAAKgADCggIDQAAAA==.',['我花']='我花钱不赚钱:BAAAKgADCgUIBQAAAA==.',['我追']='我追你舅佬:BAAAKgAECgMIAwAAAA==.',['战神']='战神小白:BAAAKgAECggICAAAAA==.',['打不']='打不赢就跑:BAAAKgADCgUIBgAAAA==.',['扭咕']='扭咕噜:BAABKgAFFH8IAAIKAAgIcwkRBwD0AQAKAAgIcwkRBwD0AQAAAA==.',['扶她']='扶她奶茶:BAAAKgAECggIEgAAAA==.',['抒情']='抒情坏宝宝:BAAAKgAECggIDQAAAA==.',['折耳']='折耳根战神:BAAAKgAECggIEAAAAA==.',['抛情']='抛情绝爱:BAAAKgADCggICAAAAA==.',['拒绝']='拒绝战复丶:BAABKgAECn8pAAMFAAgIuB03GgAnAgAFAAgIuB03GgAnAgAGAAEIegP8EAEgAAAAAA==.拒绝抗怪:BAACKgAFFH8KAAIUAAQIeQkrCgCGAAAUAAQIeQkrCgCGAAAqAAQKfxQABBoACAg2DQ0wABMBABoABwgACw0wABMBABQABgjDC/UsAMoAAAoAAQg2Aw6CACAAAAAA.',['招财']='招财大将军:BAAAKgAFFAQIBAAAAA==.',['持剑']='持剑今朝丶:BAAAKgAFFAgIBAAAAA==.',['捧一']='捧一束月光:BAAAKgAECgcICAAAAA==.',['故事']='故事有结局吗:BAAAKgAECgUICQAAAA==.',['敖饼']='敖饼:BAABKgAECn8UAAIGAAYIUxh3awBwAQAGAAYIUxh3awBwAQAAAA==.',['斩鬼']='斩鬼神:BAACKgAFFH8NAAIdAAMIdhHsFADRAAAdAAMIdhHsFADRAAAqAAQKfxkAAx0ACAgbGnEkAOwBAB0ACAinGXEkAOwBAB4AAgg7CgVpAF8AAAAA.',['施法']='施法:BAAAKgAECgUIEgABKgAFFAQIFwAIAMkiAA==.',['昂博']='昂博丽涡啵:BAAAKgADCggICAAAAA==.',['明日']='明日奈由纪:BAAAKgAFFAgIAgAAAA==.',['明月']='明月照彩云归:BAAAKgAECgQIBAAAAA==.',['昔曰']='昔曰伊人:BAAAKgAECgUIBQAAAA==.',['春哥']='春哥:BAABKgAFFH8GAAMEAAYItRj8EQANAQAEAAUI/hX8EQANAQACAAEIkCPvOgBUAAAAAA==.',['是不']='是不是说不听:BAAAKgAFFAYIBAAAAA==.',['昴宿']='昴宿星人:BAAAKgAECgcIBwAAAA==.',['晚霞']='晚霞梦魔:BAABKgAECn8UAAMCAAgIIxg+LQCRAQACAAgIIxg+LQCRAQADAAQIEBTfNAD2AAAAAA==.',['晴雯']='晴雯之钗:BAABKgAFFH8KAAMbAAgISg9rFQA5AQAkAAYIdAofEQA6AQAbAAQIrA9rFQA5AQAAAA==.',['暖灬']='暖灬阳:BAAAKgAECgEIAQAAAA==.',['暗夜']='暗夜悠阳:BAABKgAFFH8JAAMdAAUIICAIHAAmAQAdAAUIzR4IHAAmAQAfAAQIJBJpEAC2AAAAAA==.',['曹家']='曹家巷俊哥:BAAAKgAECggICAAAAA==.',['會衤']='會衤大师:BAAAKgADCgUIBQAAAA==.',['月下']='月下醉仙酒:BAABKgAFFH8JAAQlAAMIwQpHAwCJAAAlAAIITAtHAwCJAAAGAAMIAgdQTwBuAAAFAAEIFAXhKgApAAAAAA==.',['月丶']='月丶妖灵儿:BAABKgAECn8aAAMCAAgIwxX6IAC+AQACAAgIwxX6IAC+AQAEAAEI6QlrMgAhAAAAAA==.',['月之']='月之刃:BAACKgAFFH8UAAIJAAMIwSDxCQD2AAAJAAMIwSDxCQD2AAAqAAQKfy4AAgkACAhRIV0IAIYCAAkACAhRIV0IAIYCAAAA.',['月夜']='月夜沫语:BAACKgAFFH8PAAQIAAYIOyBlDwAWAQAIAAQIySNlDwAWAQAcAAQImxb4DADfAAAQAAII5xpaHACXAAAqAAQKfx4AAggACAhqJP4wAF4CAAgACAhqJP4wAF4CAAEqAAUUCAgTAAgAShoA.',['月落']='月落挽歌:BAAAKgAFFAIIAgAAAA==.',['木兰']='木兰当盟主:BAAAKgADCgQIBAAAAA==.',['未核']='未核实:BAAAKgAFFAEIAQAAAA==.',['未止']='未止目标:BAABKgAFFH8GAAIIAAYIrxEUIABwAQAIAAYIrxEUIABwAQAAAA==.',['朮丶']='朮丶士:BAAAKgADCgQIBAAAAA==.',['李老']='李老栓酸:BAAAKgAECggICAAAAA==.',['杏林']='杏林春暖:BAAAKgAFFAQIBAAAAA==.',['村姑']='村姑爱装萌:BAAAKgAECgIICwAAAA==.',['東莞']='東莞吴彦祖:BAAAKgAFFAEIAQAAAA==.',['林影']='林影丶丶:BAAAKgADCggIDwAAAA==.',['果缤']='果缤纷奥斯卡:BAAAKgADCggICAAAAA==.',['枷鲨']='枷鲨:BAAAKgADCgIIAgAAAA==.',['柏多']='柏多伊铮铮:BAAAKgADCgMIAwAAAA==.',['栀子']='栀子比众木:BAAAKgAECgcIDAAAAA==.',['格瑞']='格瑞特豆:BAACKgAFFH8dAAMaAAQIZh8xEgD2AAAaAAMIZh8xEgD2AAAKAAEIAAAzPAAAAAAqAAQKfyYAAxoACAgvIh8MAGQCABoACAgvIh8MAGQCAAoAAghAHoJtAFkAAAEqAAUUCAgdAAgAxyAA.',['桑德']='桑德玛莂琪:BAAAKgADCggIBwAAAA==.',['梅山']='梅山寻橙:BAAAKgAECgcIDgAAAA==.',['梦月']='梦月寒:BAAAKgAECggICAAAAA==.',['槑槑']='槑槑呆槑槑:BAAAKgAFFAYIAwAAAA==.',['橘子']='橘子熟了:BAAAKgAFFAQIAQAAAA==.橘子罐头:BAAAKgADCggICAAAAA==.',['欧斯']='欧斯卡欧巴:BAAAKgADCgcIBwAAAA==.',['欧诺']='欧诺弥亚:BAAAKgAECgMIAwAAAA==.',['正经']='正经小伙:BAABKgAFFH8PAAQQAAYILxSODwAJAQAQAAYIfBGODwAJAQAcAAQI2A7AEAC8AAAIAAIIyRJsMwCkAAABKgAFFAgIGgAQADESAA==.',['死亡']='死亡标记:BAAAKgAECgcIDgAAAA==.',['死神']='死神的信使:BAAAKgAFFAgIBAAAAA==.',['殇丶']='殇丶小熙:BAAAKgADCgMIAwAAAA==.',['永凍']='永凍丶黎明:BAAAKgAECgQICAAAAA==.',['永夜']='永夜蜃楼:BAAAKgAECgcICgAAAA==.',['汐丶']='汐丶芮:BAAAKgAFFAgIAwAAAA==.',['汕海']='汕海:BAABKgAFFH8GAAILAAYIHgq+BwAYAQALAAYIHgq+BwAYAQAAAA==.',['汤圆']='汤圆煮馄饨:BAAAKgAECgQIBAAAAA==.',['没你']='没你睡不着:BAAAKgAECgMIAwAAAA==.',['没有']='没有名字啊:BAAAKgAECgUIBQAAAA==.',['油炸']='油炸小虾片:BAAAKgADCggICAAAAA==.',['沿途']='沿途小毒奶:BAAAKgADCgUIBgAAAA==.',['法克']='法克嗳可嘶:BAAAKgAECgcIBgAAAA==.',['泡椒']='泡椒土豆:BAAAKgAFFAQIBAAAAA==.',['泰兰']='泰兰徳的回忆:BAABKgAFFH8KAAMHAAYIOBtPDgDsAAAHAAQIGxhPDgDsAAANAAIIrhJsHACXAAAAAA==.',['泰尼']='泰尼恩丶鹰翼:BAAAKgAFFAEIAQAAAA==.',['泰神']='泰神七:BAAAKgADCgIIAgAAAA==.',['洐泠']='洐泠:BAACKgAFFH8TAAIcAAMI4x7KBQDvAAAcAAMI4x7KBQDvAAAqAAQKf1kAAxwACAgAJdEAAN8CABwACAgAJdEAAN8CAAgAAwjlDRQSAZ8AAAEqAAUUBggLAAgAzhoA.',['洛欧']='洛欧:BAACKgAFFH8SAAQPAAQIuiCzDAARAQAPAAQIuiCzDAARAQASAAMIIhOVBQC9AAARAAIIAhEsKgBzAAAqAAQKfx8AAg8ACAjGJSENAIICAA8ACAjGJSENAIICAAAA.',['浊酒']='浊酒换新梦:BAABKgAFFH8GAAIBAAYIKxDjFQBMAQABAAYIKxDjFQBMAQAAAA==.',['浪荡']='浪荡的丶烟花:BAABKgAECn8VAAICAAgIPxXVIwCqAQACAAgIPxXVIwCqAQAAAA==.',['浮尸']='浮尸:BAAAKgAECgcIBwAAAA==.',['清醒']='清醒的梦魇:BAAAKgAECgYIBwAAAA==.',['清风']='清风拂红叶:BAAAKgAECggICgAAAA==.',['渴死']='渴死的骆驼:BAABKgAFFH8KAAIIAAgIbxaeDgDvAQAIAAgIbxaeDgDvAQAAAA==.',['潇湘']='潇湘曲丶夜語:BAAAKgAECgEIAQAAAA==.潇湘曲丶夜语:BAACKgAFFH8JAAMCAAMI6SWmAQBQAQACAAMI6SWmAQBQAQADAAEIKwMmLAAzAAAqAAQKfxcAAgIACAieGX4XABgCAAIACAieGX4XABgCAAAA.',['濮阳']='濮阳冻豆浆:BAABKgAFFH8GAAIIAAQIugs5HAADAQAIAAQIugs5HAADAQABKgAFFAQICAAGALMVAA==.',['火锅']='火锅烤肉:BAAAKgAECgEIAQAAAA==.',['灬劣']='灬劣空:BAACKgAFFH8PAAMZAAYIKBivEACgAAAZAAYIKBivEACgAAAkAAEIZAR5PwA6AAAqAAQKfxsAAxkACAjrFycrAM0BABkACAg8FycrAM0BACQABQjrEPpTACgBAAAA.灬劣风:BAAAKgAECgQIBAAAAA==.',['灬白']='灬白夜灬:BAAAKgAECgEIAQAAAA==.',['灵魂']='灵魂乌鸦:BAAAKgAECgYIBgAAAA==.',['灾厄']='灾厄:BAAAKgAFFAgIAgAAAA==.',['炮轰']='炮轰造价站:BAAAKgADCggICAAAAA==.',['炽血']='炽血丨零:BAABKgAFFH8MAAMZAAQImyUrAwAiAQAZAAQIzCErAwAiAQAbAAQIZCWOHgDyAAAAAA==.',['烙惪']='烙惪:BAAAKgAECgEIAQAAAA==.',['烟火']='烟火:BAABKgAFFH8IAAMHAAYIhBxaDwBfAQAHAAUIoh5aDwBfAQANAAIIIBjUHACTAAAAAA==.',['煎包']='煎包加锅盔:BAAAKgADCggICAAAAA==.',['熊孩']='熊孩子右踢腿:BAAAKgAFFAYIBAAAAA==.',['熊猫']='熊猫会功夫:BAAAKgADCggIEAAAAA==.',['燃烧']='燃烧军团爪牙:BAAAKgAECgYIBgAAAA==.',['燕驼']='燕驼龙:BAAAKgAECgYICgAAAA==.',['爷今']='爷今年走荭:BAABKgAFFH8HAAIdAAYINhCIGgAxAQAdAAYINhCIGgAxAQAAAA==.',['爷玩']='爷玩啥都厉害:BAACKgAFFH8HAAIGAAQI1h1KEwAAAQAGAAQI1h1KEwAAAQAqAAQKfxcAAgYABwhzI4omABsCAAYABwhzI4omABsCAAAA.',['牌子']='牌子班尼路:BAAAKgAFFAIIAgAAAA==.',['牛牛']='牛牛来消费:BAAAKgAFFAgIBAAAAA==.',['犀利']='犀利的牛角:BAAAKgAECgcICAAAAA==.',['犴哥']='犴哥哥:BAABKgAFFH8GAAILAAYIMAWdGwDGAAALAAYIMAWdGwDGAAAAAA==.',['狂暴']='狂暴:BAAAKgADCggICAAAAA==.',['狄海']='狄海粟:BAABKgAECn8WAAQkAAgIDQ+wIAAuAQAkAAgI+QiwIAAuAQAZAAgIOwyzNQAmAQAbAAYIcAiReAB6AAABKgAFFAcIAQAhAAAAAA==.',['狄祝']='狄祝融:BAAAKgAECgIIAgAAAA==.',['狩猎']='狩猎恶魔:BAAAKgAECgEIAQAAAA==.',['狮吼']='狮吼吼狮:BAAAKgAFFAMIAwAAAA==.狮吼恶魔:BAAAKgAFFAMIAwAAAA==.',['猜我']='猜我是谁:BAABKgAFFH8YAAIIAAQI4CAVOwABAQAIAAQI4CAVOwABAQAAAA==.',['玥芷']='玥芷:BAAAKgADCgMIAwAAAA==.',['珊瑚']='珊瑚宫心海:BAABKgAFFH8IAAIEAAgIvAu9BACcAQAEAAgIvAu9BACcAQAAAA==.',['琥珀']='琥珀海:BAABKgAFFH8IAAIGAAMIsxVFGgDEAAAGAAMIsxVFGgDEAAAAAA==.',['瑕梓']='瑕梓:BAAAKgAECggIEAAAAA==.',['瑟闻']='瑟闻亦唻吻丶:BAAAKgAFFAQIBAAAAA==.',['瓦渣']='瓦渣部落:BAAAKgAECggIDwAAAA==.',['甲寅']='甲寅部落:BAAAKgAECggIDwAAAA==.',['电死']='电死你个扑街:BAAAKgAECgEIAgAAAA==.',['疯狂']='疯狂之大黑牛:BAAAKgAECgYIDgAAAA==.疯狂的萌牛:BAAAKgAFFAgIBAAAAA==.',['白子']='白子真奶:BAAAKgAECgYIBgAAAA==.',['白山']='白山道长:BAAAKgADCgcIBwAAAA==.',['百目']='百目真人:BAAAKgAECgUIBwAAAA==.',['皓雪']='皓雪落:BAABKgAECn8VAAIVAAgIUxXvHQCtAQAVAAgIUxXvHQCtAQAAAA==.',['皮皮']='皮皮蝦:BAAAKgADCgEIAQAAAA==.皮皮霞跟我走:BAAAKgAECgIIAgAAAA==.',['盖亚']='盖亚拉大王:BAAAKgAECgUIBQAAAA==.',['目光']='目光伶俐:BAAAKgAECgQIBAAAAA==.',['眼疾']='眼疾手快:BAABKgAFFH8GAAIBAAYIyRRpEgBpAQABAAYIyRRpEgBpAQAAAA==.',['祖国']='祖国的花骨朵:BAAAKgAECggIBQAAAA==.',['神圣']='神圣丶之光:BAAAKgADCggICAAAAA==.',['神祐']='神祐部落:BAAAKgADCgcIBwAAAA==.',['神里']='神里绫华:BAAAKgAECgIIAgAAAA==.',['禾火']='禾火哥哥:BAAAKgADCgYIBwAAAA==.',['秋叶']='秋叶漫漫:BAAAKgADCgEIAQAAAA==.',['笨宝']='笨宝伟:BAAAKgAECgQIBAAAAA==.',['笨笨']='笨笨伟:BAABKgAFFH8GAAILAAMIVwNwEQBjAAALAAMIVwNwEQBjAAAAAA==.',['简单']='简单快乐:BAAAKgAECgIIAwAAAA==.',['箭术']='箭术训练师:BAAAKgAECgUIBQAAAA==.',['米米']='米米果丶:BAAAKgAECgQIBQAAAA==.',['粤睇']='粤睇越靓:BAAAKgAFFAMIAwAAAA==.',['精灵']='精灵小南:BAAAKgAFFAEIAQAAAA==.',['糯香']='糯香柠檬茶:BAAAKgAECggIEwAAAA==.',['素影']='素影:BAABKgAFFH8JAAIiAAMIdQ1EBgCxAAAiAAMIdQ1EBgCxAAAAAA==.',['红桃']='红桃一:BAAAKgAECgUIBQAAAA==.',['给你']='给你一个嘴槌:BAACKgAFFH8VAAIBAAQIwx0RFwDmAAABAAQIwx0RFwDmAAAqAAQKfyUAAgEACAiTICATAJQCAAEACAiTICATAJQCAAAA.给你一个肘击:BAABKgAFFH8MAAIMAAMIuBSqNADEAAAMAAMIuBSqNADEAAABKgAFFAQIFQABAMMdAA==.',['绝不']='绝不含糊:BAAAKgADCgMIAwAAAA==.',['绮灬']='绮灬念:BAAAKgADCggICQAAAA==.',['维尔']='维尔利特:BAAAKgADCggICAAAAA==.',['绿茶']='绿茶白莲花:BAAAKgADCgYIBgAAAA==.',['缺德']='缺德丶不缺钱:BAAAKgADCggICAAAAA==.',['罪與']='罪與罚:BAAAKgAECgYIBgAAAA==.',['署妲']='署妲己:BAAAKgADCggIEQAAAA==.',['羊屁']='羊屁屁大仙:BAAAKgAECgcICwAAAA==.',['群青']='群青丶丶:BAAAKgADCgIIAgAAAA==.',['老子']='老子跟你拚了:BAAAKgAECgEIAQAAAA==.',['老总']='老总:BAAAKgADCgIIAgAAAA==.',['老牛']='老牛吃茶叶蛋:BAAAKgAECgYIEgAAAA==.老牛在天堂:BAAAKgAECgIIAgAAAA==.',['老衲']='老衲法号推车:BAAAKgAECgEIAQAAAA==.',['耷狭']='耷狭:BAAAKgAECggIDAABKgAFFAYICwAIAM4aAA==.',['聖光']='聖光之愿:BAABKgAFFH8GAAIIAAYIehVEHwBzAQAIAAYIehVEHwBzAQAAAA==.聖光之殇:BAAAKgAECgMIAwAAAA==.',['胖不']='胖不了啦:BAAAKgAFFAUIAQAAAA==.',['舒妲']='舒妲己:BAAAKgAECgIIAgAAAA==.',['航小']='航小屁:BAAAKgAECgEIAQAAAA==.',['节奏']='节奏丶大师:BAAAKgAECggICAAAAA==.',['芙宁']='芙宁娜:BAAAKgAECgQIBAAAAA==.',['芣偷']='芣偷腥的猫:BAAAKgAECgYIEQAAAA==.',['花尚']='花尚喜:BAAAKgAFFAcIBAAAAA==.',['莉莉']='莉莉丝女王:BAAAKgAFFAgIAgAAAA==.',['莨劫']='莨劫:BAACKgAFFH8LAAICAAQIsBiuDwDSAAACAAQIsBiuDwDSAAAqAAQKfxkAAgIACAizHyoRAEkCAAIACAizHyoRAEkCAAEqAAUUBggLAAgAzhoA.',['莫惹']='莫惹我嚛:BAAAKgADCgQIBAAAAA==.',['菿佌']='菿佌爲芷:BAAAKgAECgUIBQAAAA==.',['萌呆']='萌呆耐:BAAAKgAECgMIAwAAAA==.',['萌新']='萌新大帝:BAAAKgAECgQICAAAAA==.',['萨勒']='萨勒芬妮:BAABKgAFFH8OAAMOAAYIIheMDwBoAQAOAAYIIheMDwBoAQAgAAQI2g/CBADGAAAAAA==.',['落叶']='落叶木俞瑶丶:BAAAKgAFFAQIBAAAAA==.',['蒜鸟']='蒜鸟:BAAAKgAECggIDwAAAA==.蒜鸟蒜鸟:BAABKgAFFH8FAAIdAAIIIAuFQABrAAAdAAIIIAuFQABrAAAAAA==.',['蓝小']='蓝小灵同学:BAAAKgAFFAQIBAAAAA==.',['蓝枫']='蓝枫小筱:BAAAKgAECgcIBwAAAA==.蓝枫秋筱:BAAAKgAECgUIBQAAAA==.',['薄情']='薄情秋幺哥:BAAAKgADCgIIAgAAAA==.',['蝙蝠']='蝙蝠叔叔:BAAAKgAFFAMIAwABKgAFFAgIQwAVAFYlAA==.',['血斧']='血斧断魂:BAAAKgADCgIIAgAAAA==.',['血染']='血染星辰:BAABKgAECn8oAAMdAAcISRfsOQCFAQAdAAcISRfsOQCFAQAeAAEIAADqiQAAAAAAAA==.',['行巫']='行巫时刻:BAAAKgAFFAIIAwAAAA==.',['被遗']='被遗忘的小鸦:BAAAKgADCgEIAQAAAA==.被遗忘的朵朵:BAAAKgAFFAgIAgAAAA==.',['西天']='西天丶宋仲基:BAAAKgAECgQIBgAAAA==.',['西横']='西横塘强哥:BAAAKgAECgcIEQAAAA==.',['誰心']='誰心一梦:BAAAKgAECggIDQAAAA==.',['譕胤']='譕胤:BAAAKgAECggIEAAAAA==.',['谁输']='谁输谁赢谁知:BAABKgAFFH8IAAIIAAgILQxMEADeAQAIAAgILQxMEADeAQAAAA==.',['调灬']='调灬情:BAAAKgADCgcIBwAAAA==.',['调酒']='调酒师:BAAAKgAFFAIIAgAAAA==.',['赞达']='赞达拉:BAABKgAFFH8GAAIHAAMITwexOgCaAAAHAAMITwexOgCaAAAAAA==.',['赤星']='赤星小萨:BAAAKgADCgYIBgAAAA==.',['赫尔']='赫尔阿克帝:BAAAKgAFFAYIAQAAAA==.',['赵小']='赵小小丶:BAAAKgADCggICQAAAA==.',['超级']='超级电风扇:BAAAKgAECgUIBQAAAA==.',['越塔']='越塔欢乐送:BAACKgAFFH8PAAMbAAQIHhNfAwC1AAAkAAQIAQ3JIwDHAAAbAAMI+BpfAwC1AAAqAAQKfywAAyQACAikH9MkABgCACQACAg4HtMkABgCABsABAj9H8UPAFABAAAA.',['蹲墙']='蹲墙:BAAAKgAFFAcIAQAAAA==.',['躺岼']='躺岼:BAAAKgADCgUIBQAAAA==.',['躺板']='躺板板:BAAAKgAECgcIBwAAAA==.',['辞旧']='辞旧乄:BAAAKgAECgYIBgAAAA==.',['还算']='还算潇洒:BAABKgAFFH8IAAIdAAMIgQLSPQB2AAAdAAMIgQLSPQB2AAAAAA==.',['进击']='进击的神棍德:BAABKgAFFH8MAAIXAAMIswnYQQClAAAXAAMIswnYQQClAAAAAA==.进击的神棍牧:BAABKgAFFH8LAAIEAAgIVhpFAgAmAgAEAAgIVhpFAgAmAgAAAA==.',['逝去']='逝去的时间:BAAAKgAECgEIAQAAAA==.',['逸尚']='逸尚界一号:BAAAKgAECgcICgAAAA==.逸尚界一柏:BAAAKgAECgcICQAAAA==.逸尚界三二:BAAAKgAECgMIBgAAAA==.逸尚界三十:BAAAKgAECgMIAwAAAA==.逸尚界二一:BAABKgAECn8oAAMIAAgIqSNPGgCcAgAIAAgIqSNPGgCcAgAcAAEIOhQ2TwA6AAAAAA==.逸尚界二三:BAABKgAECn82AAIOAAgI8RicHQDFAQAOAAgI8RicHQDFAQAAAA==.逸尚界二十六:BAACKgAFFH8GAAIZAAQIdRFWFACNAAAZAAQIdRFWFACNAAAqAAQKfyMAAhkACAjyIIYTACQCABkACAjyIIYTACQCAAAA.逸尚界二号:BAACKgAFFH8HAAIYAAQIuxctDgDWAAAYAAQIuxctDgDWAAAqAAQKfx8AAxgACAhxG38QABMCABgACAhxG38QABMCAAEABwjCDBhUAPkAAAAA.逸尚界二点一:BAAAKgAECggICAAAAA==.逸尚界五号:BAABKgAECn8iAAMKAAgIhhgNIQDLAQAKAAgIhhgNIQDLAQAaAAIInQprYgAmAAAAAA==.逸尚界六百六:BAAAKgAECggIDwAAAA==.逸尚界叁号:BAABKgAECn9CAAIZAAgIPR3QEQA2AgAZAAgIPR3QEQA2AgAAAA==.逸尚界壹佰:BAAAKgAECgcIBwAAAA==.逸尚界壹号:BAABKgAECn8yAAMIAAgIMh0hKwBTAgAIAAgIMh0hKwBTAgAQAAcIHRHzJgAeAQAAAA==.逸尚界工具人:BAAAKgAECggICQAAAA==.逸尚界拾号:BAAAKgAECggIDQAAAA==.逸尚界拾壹:BAABKgAECn8YAAIFAAgIqRBxPgBZAQAFAAgIqRBxPgBZAQAAAA==.逸尚界拾玖:BAAAKgADCggIEgAAAA==.逸尚界拾肆:BAABKgAECn8aAAIBAAgIeBL2NgB7AQABAAgIeBL2NgB7AQAAAA==.逸尚界拾贰:BAAAKgAECgMIAwAAAA==.逸尚界捌号:BAAAKgAECgMIAwAAAA==.逸尚界捌捌:BAAAKgAECgcIBwAAAA==.逸尚界柒号:BAABKgAECn8rAAMCAAgI8hjQHQDUAQACAAgIhxjQHQDUAQAEAAgIdhHNLABLAQAAAA==.逸尚界贰三:BAABKgAECn8wAAMTAAgIch9aCQAjAgATAAgIXhpaCQAjAgAMAAQI/CDYVAAjAQAAAA==.逸尚界贰伊:BAAAKgADCggICAAAAA==.逸尚界贰号:BAAAKgAECgcIDwAAAA==.逸尚界贰壹:BAAAKgAECgYIDwAAAA==.逸尚界贰拾陆:BAAAKgAECgcICgAAAA==.逸尚界贰陆:BAABKgAECn8uAAMVAAgIoR4LDQBLAgAVAAgIoR4LDQBLAgAXAAcI4godcwADAQAAAA==.逸尚界陆号:BAAAKgAECgcICwAAAA==.逸尚界零零發:BAAAKgADCgMIAwAAAA==.',['達叔']='達叔:BAABKgAFFH8HAAIMAAQIfBA+OAC6AAAMAAQIfBA+OAC6AAAAAA==.',['遥远']='遥远的救世主:BAABKgAECn8VAAIHAAgIeBrhIAAFAgAHAAgIeBrhIAAFAgAAAA==.',['邪之']='邪之血冰:BAABKgAFFH8PAAMLAAgIVgqkCgBpAQALAAgIKgqkCgBpAQAMAAQIKwwaOwCxAAAAAA==.',['邪暗']='邪暗骑士:BAAAKgAECgcIBwAAAA==.',['郎丶']='郎丶总:BAAAKgADCggICAAAAA==.',['郭大']='郭大爷:BAAAKgAECggICAAAAA==.',['钢铁']='钢铁悍将:BAAAKgAFFAMIAwAAAA==.',['长空']='长空无敌:BAAAKgAECgEIAQAAAA==.',['闪亮']='闪亮之翼:BAAAKgAECgYIDAAAAA==.',['闪电']='闪电兔:BAABKgAFFH8fAAINAAQIkiIqCgAoAQANAAQIkiIqCgAoAQABKgAFFAgIHQAIAMcgAA==.',['闹呢']='闹呢:BAABKgAECn8lAAIWAAgIaBDxCQBFAQAWAAgIaBDxCQBFAQAAAA==.',['闻意']='闻意:BAAAKgAECgUIBQAAAA==.',['阿克']='阿克塔尼亚:BAABKgAFFH8QAAIaAAgIJxV4AQC1AQAaAAgIJxV4AQC1AQAAAA==.',['阿凌']='阿凌要努力:BAAAKgAFFAQIBAAAAA==.',['阿尔']='阿尔托利雅丶:BAAAKgAFFAQIBAABKgAECggIGgAMABQkAA==.',['阿里']='阿里克南尔:BAABKgAFFH8GAAIXAAYIEiOBAAAQAgAXAAYIEiOBAAAQAgAAAA==.',['阿隆']='阿隆索斯:BAAAKgADCgMIAwAAAA==.',['陈光']='陈光光:BAAAKgADCgcIBwAAAA==.',['隆戈']='隆戈:BAAAKgAFFAQIBAABKgAFFAYICwAIAM4aAA==.',['雀了']='雀了雀:BAAAKgAECggICAAAAA==.',['雅典']='雅典娜娜:BAAAKgAECgQIBgAAAA==.',['雪落']='雪落凝寒霜丶:BAAAKgAECggICAAAAA==.',['雷焱']='雷焱丶咆哮:BAAAKgAECgcICQAAAA==.',['雷迪']='雷迪森弗兰雷:BAAAKgAECgUIBgAAAA==.',['霜灬']='霜灬火:BAAAKgAECggICAAAAA==.',['霸凌']='霸凌侯:BAAAKgAECgEIAwAAAA==.',['静听']='静听年华:BAAAKgADCgMIAwAAAA==.',['項佐']='項佐灬:BAAAKgAFFAIIAgABKgAFFAgIBAAhAAAAAA==.',['順风']='順风:BAAAKgADCggICAABKgAFFAgIEAADAFsKAA==.',['颜舍']='颜舍灬:BAABKgAFFH8IAAIGAAgInwzHCADeAQAGAAgInwzHCADeAQAAAA==.',['风骚']='风骚的菠萝:BAABKgAECn8oAAMGAAgILxBSHwB+AQAGAAgILxBSHwB+AQAFAAEIEgg1tQAbAAAAAA==.',['餹果']='餹果牛:BAAAKgAECgIIAgAAAA==.',['饿鬼']='饿鬼道:BAAAKgADCggICAAAAA==.',['香浓']='香浓玉米味:BAAAKgAECgEIAQAAAA==.',['马上']='马上有帅哥:BAAAKgAECgUIBQAAAA==.',['高优']='高优秀阿细:BAAAKgADCggICgAAAA==.',['高贵']='高贵的红迪凯:BAAAKgAECggICAAAAA==.',['魔牛']='魔牛奥比:BAABKgAFFH8MAAIKAAYIRiSJCADQAQAKAAYIRiSJCADQAQAAAA==.',['魔王']='魔王王魔:BAAAKgAECggICAAAAA==.',['魔鬼']='魔鬼忍者:BAAAKgAFFAMIAwAAAA==.',['鸡枪']='鸡枪贼厉害:BAAAKgADCggIDwAAAA==.',['麦客']='麦客:BAAAKgADCggICAAAAA==.',['麦蠢']='麦蠢蠢:BAABKgAECn8YAAIZAAgI9R18FwBDAgAZAAgI9R18FwBDAgAAAA==.',['黄色']='黄色体育生:BAABKgAFFH8KAAIJAAgIhhlKBQA9AgAJAAgIhhlKBQA9AgAAAA==.',['黑暗']='黑暗圣光:BAAAKgAECggICAAAAA==.',['黑色']='黑色狸猫:BAAAKgADCggICAAAAA==.',['黯然']='黯然樂:BAAAKgAECgMIAwAAAA==.',['龙虾']='龙虾片:BAABKgAECn8ZAAMRAAgIaQsNMQAYAQARAAgIaQsNMQAYAQAPAAQIng1QJABpAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end