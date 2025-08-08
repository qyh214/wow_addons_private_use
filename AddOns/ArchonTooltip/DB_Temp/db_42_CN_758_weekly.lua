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
 local lookup = {'DeathKnight-Unholy','DemonHunter-Havoc','Paladin-Retribution','Druid-Balance','Warlock-Destruction','DemonHunter-Vengeance','Warlock-Affliction','Mage-Fire','Mage-Frost','Mage-Arcane','Paladin-Protection','Warrior-Arms','Monk-Mistweaver','Monk-Windwalker','DeathKnight-Blood','DeathKnight-Frost','Shaman-Restoration','Rogue-Assassination','Evoker-Preservation','Druid-Feral','Warlock-Demonology','Hunter-BeastMastery','Unknown-Unknown','Warrior-Fury','Evoker-Devastation','Priest-Shadow','Priest-Holy','Paladin-Holy','Druid-Guardian','Hunter-Marksmanship','Monk-Brewmaster','Shaman-Enhancement','Shaman-Elemental','Druid-Restoration','Priest-Discipline','Warrior-Protection',}; local provider = {region='CN',realm='玛法里奥',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alielie:BAAAKgAFFAgIAgAAAA==.',An='Angelina:BAABKgAFFH8UAAIBAAQIaQ+NMgDKAAABAAQIaQ+NMgDKAAAAAA==.',Ba='Babynow:BAAAKgADCgEIAQAAAA==.',Be='Bebe:BAAAKgADCgMIAwAAAA==.',Bu='Busystone:BAAAKgAECgEIAQAAAA==.',Ch='Chanelcoco:BAAAKgAECgMIAwAAAA==.Christina:BAAAKgAECgcIBwAAAA==.',Dj='Djkiller:BAAAKgAFFAMIAQAAAA==.Djpikacue:BAAAKgAFFAQIBAAAAA==.',En='Ensemorz:BAAAKgADCgMIAwAAAA==.',Ju='Justsweet:BAABKgAFFH8SAAICAAgIZB7XBgA1AgACAAgIZB7XBgA1AgAAAA==.',Ka='Katherina:BAABKgAECn8aAAIDAAgIFRiUdQCsAQADAAgIFRiUdQCsAQAAAA==.',Li='Licorice:BAAAKgAECgcICQAAAA==.',Lo='Lonyx:BAAAKgAFFAQIBAAAAA==.',Lu='Luxumbra:BAAAKgADCggIDgAAAA==.',Mo='Mousey:BAAAKgADCgEIAQAAAA==.',Mp='Mplusempress:BAABKgAFFH8PAAIEAAYIcxpgFAB3AQAEAAYIcxpgFAB3AQAAAA==.',Mu='Mushroom:BAAAKgAECgYICAAAAA==.',On='Onlook:BAABKgAFFH8XAAIFAAgIXAsoCADiAQAFAAgIXAsoCADiAQAAAA==.',Pu='Purpler:BAAAKgAECgQIBAAAAA==.',Sa='Sabereternal:BAAAKgAFFAcIAwAAAA==.',Sh='Shuoshuo:BAAAKgAECgYIBgAAAA==.',Sp='Spectator:BAABKgAFFH8SAAMCAAgI9hf4BQBKAgACAAgI9hf4BQBKAgAGAAIISAkxDQCFAAAAAA==.',St='Starle:BAABKgAFFH8KAAMFAAgI1gsADwCfAQAFAAcIKw0ADwCfAQAHAAEI2QPjIgBCAAAAAA==.Stormfish:BAABKgAFFH8WAAQIAAYIJh1JCwCCAQAIAAYIJh1JCwCCAQAJAAQINxg1EQDYAAAKAAEIHwZWRwA1AAAAAA==.',Su='Sumton:BAAAKgAFFAgIBAAAAA==.',Ta='Taoist:BAAAKgAECgQIBAAAAA==.Taylordizon:BAAAKgADCgEIAQAAAA==.',Wa='Wangzd:BAAAKgAECggIEgAAAA==.Warforever:BAABKgAFFH8JAAMDAAYIXRtHHwDrAAADAAQIoxNHHwDrAAALAAQIGR1YFADWAAAAAA==.',Wi='Wildhydnose:BAABKgAFFH8MAAIDAAYIWBwvBACHAQADAAYIWBwvBACHAQAAAA==.',Zd='Zd:BAACKgAFFH8bAAIMAAMIsxxsEQD/AAAMAAMIsxxsEQD/AAAqAAQKfxsAAgwACAiiGGAYAPABAAwACAiiGGAYAPABAAAA.',['一个']='一个王祖贤:BAAAKgADCggICwAAAA==.',['一国']='一国两治:BAAAKgAECggIEAAAAA==.',['一本']='一本不正经:BAAAKgAECgQIBQAAAA==.',['一路']='一路奶粉:BAACKgAFFH8RAAMNAAMIFSEoEgAYAQANAAMIFSEoEgAYAQAOAAIIAgfKIABlAAAqAAQKfycAAw0ACAiPH+YVADkCAA0ACAiPH+YVADkCAA4ABQh3DOFJAJ8AAAAA.',['七小']='七小度:BAAAKgAECgYIBwAAAA==.',['三路']='三路奶粉:BAAAKgAECggIEwAAAA==.',['东东']='东东包:BAAAKgAFFAIIAgAAAA==.东东包的武僧:BAAAKgAECgYICQAAAA==.',['两千']='两千次全胜:BAACKgAFFH8ZAAMPAAQIwR3tDQDQAAABAAQIwR1QJAADAQAPAAQIzhXtDQDQAAAqAAQKfyAAAwEACAgNIsEWAHgCAAEACAgNIsEWAHgCABAAAwgXCOUmAIgAAAAA.',['丶吃']='丶吃土人生丶:BAABKgAECn8eAAIDAAgIxSHaCgCXAgADAAgIxSHaCgCXAgAAAA==.',['丶小']='丶小牧:BAAAKgAECgQIBAAAAA==.丶小红帽:BAAAKgAECgMIAwAAAA==.',['丶桃']='丶桃之夭夭丶:BAAAKgADCgEIAQAAAA==.',['丶溜']='丶溜肉段:BAABKgAECn8YAAIRAAgIbRIGUQA5AQARAAgIbRIGUQA5AQAAAA==.',['丶澈']='丶澈淡:BAAAKgADCgEIAgAAAA==.',['丶百']='丶百草枯丶:BAABKgAECn86AAMJAAgISCBlDQBqAgAJAAgISCBlDQBqAgAKAAIIWRcddQCEAAAAAA==.',['丶随']='丶随风:BAAAKgAECgYIBgAAAA==.',['丿余']='丿余生:BAABKgAFFH8MAAISAAYIRw80DwBeAQASAAYIRw80DwBeAQAAAA==.',['九霄']='九霄:BAAAKgAFFAYIBAAAAA==.',['了无']='了无痕迹:BAABKgAFFH8OAAMPAAQIJR/ACQD9AAAPAAQIhhzACQD9AAABAAQI8BpSKwDgAAAAAA==.',['五月']='五月落樱:BAABKgAECn8YAAITAAgIqgSxEwCqAAATAAgIqgSxEwCqAAAAAA==.',['人民']='人民丶币:BAABKgAFFH8IAAINAAgI1A//BwC0AQANAAgI1A//BwC0AQAAAA==.',['人生']='人生海海丶:BAAAKgADCgEIAQAAAA==.',['代表']='代表圣光:BAAAKgAECgMIAwAAAA==.',['会跳']='会跳舞的火焰:BAAAKgADCgQIBAAAAA==.',['余香']='余香:BAAAKgAFFAIIBAAAAA==.',['俦牛']='俦牛:BAAAKgAECggICAAAAA==.',['光铸']='光铸蹄子:BAAAKgAECgUIBQAAAA==.',['六千']='六千次全胜:BAABKgAFFH8KAAMUAAQI1xU+BADuAAAUAAMI1xU+BADuAAAEAAQI2g8fNgDFAAAAAA==.',['六翼']='六翼使徒:BAABKgAECn8ZAAIDAAgImhh1awDCAQADAAgImhh1awDCAQAAAA==.',['再现']='再现繁华:BAABKgAFFH8FAAMFAAUIAxMELgC1AAAFAAQIAxMELgC1AAAVAAEIAACUNgAAAAAAAA==.',['冰晶']='冰晶火舞:BAAAKgAECgMIAwAAAA==.',['冰箱']='冰箱里的胖丁:BAACKgAFFH8QAAQIAAYINxlpDgBXAQAIAAYINxlpDgBXAQAKAAEIrQfURgA3AAAJAAEIFAW8LQAyAAAqAAQKfxYABAoACAg5F/86AFoBAAgACAjDEqdDAHoBAAoABggHGP86AFoBAAkAAwiqBJCUAGQAAAAA.',['冲锋']='冲锋者肆型:BAABKgAFFH8OAAMJAAMIXBYfCwDVAAAJAAMIJxQfCwDVAAAIAAIIWBJaMACJAAAAAA==.',['凉透']='凉透德蛋炒饭:BAAAKgADCggICAAAAA==.',['力量']='力量与荣耀啊:BAAAKgAECgMICAAAAA==.',['劣人']='劣人甲:BAAAKgAFFAMIBAAAAA==.',['单吊']='单吊九条:BAAAKgAECgQIBgAAAA==.',['原味']='原味蕾丝:BAABKgAFFH8KAAIPAAYIuAbkCgDTAAAPAAYIuAbkCgDTAAAAAA==.',['口袋']='口袋小石头:BAAAKgAFFAYIBAABKgAFFAgIEwAWAOUdAA==.',['吃饭']='吃饭吧唧嘴:BAAAKgAFFAgIBAAAAA==.',['吓不']='吓不着:BAAAKgAECgYICAAAAA==.',['周杰']='周杰伦:BAACKgAFFH8GAAINAAIIXAYsLwBaAAANAAIIXAYsLwBaAAAqAAQKfy0AAg0ACAhVD9Q6AFkBAA0ACAhVD9Q6AFkBAAAA.',['呼哧']='呼哧呼哧:BAAAKgADCgEIAQAAAA==.',['命归']='命归尘:BAAAKgAECgQIBAAAAA==.',['咖啡']='咖啡不加冰:BAAAKgAECgcIDAAAAA==.',['嗨嗨']='嗨嗨人生:BAACKgAFFH8bAAILAAQIDRKVGgCkAAALAAQIDRKVGgCkAAAqAAQKfyEAAgsACAgKDR8qAAQBAAsACAgKDR8qAAQBAAAA.',['团团']='团团丶:BAAAKgAFFAQIBAABKgAFFAgIDgAOANAQAA==.',['圣丶']='圣丶殇:BAAAKgAECgQIBAAAAA==.',['圣光']='圣光上的灰烬:BAAAKgADCgYIBgAAAA==.圣光小龙人:BAAAKgAFFAQIBAAAAA==.',['圣壂']='圣壂骑士:BAAAKgAECgUIBQAAAA==.',['圣糖']='圣糖刺客:BAABKgAFFH8HAAINAAYItxYzCgATAQANAAYItxYzCgATAQABKgAFFAgICgANACcaAA==.',['坂井']='坂井泉水:BAAAKgAECgcIBwAAAA==.',['均衡']='均衡之镰:BAABKgAFFH8QAAICAAQIySCsCQApAQACAAQIySCsCQApAQABKgAFFAgIBAAXAAAAAA==.',['城南']='城南慕北:BAAAKgAFFAQIBAAAAA==.',['夜光']='夜光草莓:BAAAKgAECgEIAQAAAA==.夜光菠萝:BAAAKgAECgcICQAAAA==.',['夜月']='夜月渐蓝:BAAAKgAFFAQIBAABKgAFFAgIJQAHACEcAA==.',['夜语']='夜语:BAAAKgAFFAEIAQAAAA==.',['大哥']='大哥是王某某:BAABKgAFFH8IAAIYAAgIjhFNBQBGAgAYAAgIjhFNBQBGAgAAAA==.',['大柱']='大柱子:BAAAKgADCggICAAAAA==.',['大橘']='大橘子:BAAAKgAECggIEQAAAA==.',['大香']='大香蕉:BAABKgAECn8UAAMTAAgIPBKXCQB1AQATAAgIPBKXCQB1AQAZAAEI4APeawAZAAAAAA==.',['天堑']='天堑乌鸦:BAAAKgAFFAYIBAAAAA==.',['天涯']='天涯海阁:BAAAKgAECgcICQAAAA==.',['天真']='天真小流氓:BAAAKgADCgEIAQAAAA==.',['天青']='天青:BAAAKgAECgMIAwAAAA==.',['天驱']='天驱圣骑:BAAAKgAECggIEAAAAA==.',['太有']='太有波哈了:BAAAKgAECgQIBQAAAA==.',['太空']='太空人丶旋转:BAAAKgAECgcIBwAAAA==.',['奈非']='奈非天:BAAAKgAFFAQIBAAAAA==.',['奏是']='奏是布拉堂:BAAAKgAECgcIBwAAAA==.',['奥蕾']='奥蕾:BAAAKgAECgQIBgAAAA==.奥蕾丽娅:BAAAKgAECggIAQAAAA==.',['奥贝']='奥贝里克斯:BAAAKgAECgIIAgAAAA==.',['奧博']='奧博倫影歌:BAAAKgADCggICAAAAA==.',['女神']='女神安然:BAAAKgAECgEIAQAAAA==.',['奶瓶']='奶瓶儿:BAABKgAFFH8IAAMaAAgIQwSfCgApAQAaAAcIlQSfCgApAQAbAAEI5gEoIAA3AAAAAA==.',['如约']='如约而至丶:BAAAKgAECggIEAAAAA==.',['如露']='如露亦如电:BAAAKgAECggICAAAAA==.',['妖妖']='妖妖白玉猫:BAAAKgAECgEIAQAAAA==.',['姑姑']='姑姑:BAABKgAFFH8IAAIBAAgIHBG9BQATAgABAAgIHBG9BQATAgAAAA==.',['威風']='威風堂堂:BAABKgAFFH8QAAQcAAYIdCGwAwARAQAcAAQI1R2wAwARAQALAAYIBgvnCgC4AAADAAIIlRJ6QwB+AAAAAA==.',['娜宝']='娜宝宝:BAABKgAECn8jAAMJAAcIKiJDCgDmAQAJAAcIKiJDCgDmAQAKAAMIYR3JTwD/AAAAAA==.',['孤城']='孤城蓑笠翁:BAAAKgAECgcICAAAAA==.孤城逢甘霖:BAAAKgAECgcIDAAAAA==.',['宝贝']='宝贝:BAABKgAFFH8FAAIKAAUIjweuKwC1AAAKAAUIjweuKwC1AAAAAA==.',['寂寞']='寂寞黑咖啡:BAAAKgADCggICgAAAA==.',['寂静']='寂静的汐儿:BAABKgAFFH8QAAMEAAYIrhZYFgBlAQAEAAYIrhZYFgBlAQAdAAII/Q9SBABsAAABKgAFFAgIUAAEABcmAA==.',['射雷']='射雷:BAAAKgAECgUICAAAAA==.',['尉迟']='尉迟丶敬德:BAABKgAFFH8KAAMBAAYIYg4ZGgBMAQABAAYIYg4ZGgBMAQAPAAQIMATIHAB0AAAAAA==.',['小吱']='小吱吱:BAAAKgAECgEIAQAAAA==.',['小小']='小小婉婉:BAABKgAFFH8IAAIBAAYIcxw6AgDIAQABAAYIcxw6AgDIAQABKgAFFAgICAAPAL0eAA==.',['小德']='小德刷个爪子:BAAAKgAECgcICgAAAA==.',['小野']='小野德:BAAAKgADCgEIAgAAAA==.',['小锤']='小锤锤捶你:BAAAKgAECggICAAAAA==.',['小静']='小静:BAAAKgAECgMIBAAAAA==.',['尛媚']='尛媚娘:BAABKgAFFH8MAAMYAAgIWRH7AQCuAQAYAAYIJRL7AQCuAQAMAAQItw9wDgAqAQAAAA==.',['工程']='工程骑士:BAAAKgAECgYIBgAAAA==.',['左岸']='左岸涟漪:BAAAKgAECgYIBgAAAA==.',['已沫']='已沫:BAABKgAFFH8GAAIeAAYI2xocDwBwAQAeAAYI2xocDwBwAQAAAA==.',['布拉']='布拉多尔:BAABKgAFFH8GAAIDAAYIECEGDQD+AQADAAYIECEGDQD+AQAAAA==.',['希尔']='希尔梅斯:BAAAKgAECgcICQAAAA==.',['带宗']='带宗师:BAAAKgAECgQIBAAAAA==.',['幸福']='幸福的女巫:BAAAKgAFFAEIAQAAAA==.',['幻影']='幻影星辰:BAAAKgAFFAQIBAABKgAFFAgIDAAEAHMZAA==.',['幻星']='幻星:BAAAKgAFFAQIBAAAAA==.',['废铁']='废铁五十星:BAABKgAFFH8GAAIEAAYIaA/FEABcAQAEAAYIaA/FEABcAQAAAA==.',['张小']='张小弟:BAACKgAFFH8ZAAQNAAQIbiJREAAqAQANAAQIbiJREAAqAQAOAAEISwRBKAAsAAAfAAEIsgMcDQAZAAAqAAQKfzYABA4ACAhZGxgGAEQCAA4ACAgNGxgGAEQCAA0ACAipHOgXACkCAB8ABwj9FNYMAGwBAAAA.',['得鹿']='得鹿梦鱼:BAAAKgADCggICAAAAA==.',['心照']='心照一生:BAACKgAFFH8tAAQRAAYI7yN6BAA7AQARAAYI7yN6BAA7AQAgAAIIiAUTDgBqAAAhAAEIWgPbHgAyAAAqAAQKfz4ABBEACAjzJFkMAJQCABEACAjzJFkMAJQCACEABggtDktKAPUAACAAAQiGCzAfADQAAAAA.',['恐龙']='恐龙棱线:BAABKgAFFH8IAAIZAAgIbA8fCADsAQAZAAgIbA8fCADsAQAAAA==.',['恶魔']='恶魔克喵:BAAAKgADCgUIBQAAAA==.',['惊诧']='惊诧:BAAAKgADCgcICwAAAA==.',['想璐']='想璐菲菲:BAAAKgAFFAQIBAAAAA==.',['慈悲']='慈悲渡魂落:BAABKgAFFH8LAAINAAYIHQuwBABsAQANAAYIHQuwBABsAQAAAA==.',['慕荷']='慕荷:BAAAKgAECgQIBAAAAA==.',['慢读']='慢读:BAAAKgAECgQIBAAAAA==.',['我心']='我心已绝:BAAAKgAECgQIBQAAAA==.',['我找']='我找沐沐:BAABKgAFFH8GAAIYAAYI7QhEEABRAQAYAAYI7QhEEABRAQAAAA==.',['我是']='我是买酱油的:BAAAKgAFFAMIAwAAAA==.',['战月']='战月歌:BAAAKgADCgIIAgAAAA==.',['所念']='所念皆星河:BAABKgAFFH8KAAMaAAgIdQ6CBQAJAgAaAAgIdQ6CBQAJAgAbAAIIpQitHQBtAAAAAA==.',['抽得']='抽得你发麻:BAAAKgADCgEIAgAAAA==.',['拾祎']='拾祎:BAABKgAFFH8MAAMKAAgINB+iAgCdAgAKAAgIeB2iAgCdAgAIAAQIXBqzGgDmAAAAAA==.',['握日']='握日月摘星辰:BAAAKgAECgUIBQAAAA==.',['敲敲']='敲敲一休闲:BAAAKgAECgIIAgAAAA==.',['旁观']='旁观者:BAABKgAFFH8QAAIDAAgIHw4mCwDwAQADAAgIHw4mCwDwAQAAAA==.',['无双']='无双上将潘凤:BAAAKgAECggICwAAAA==.',['无能']='无能狂怒:BAABKgAECn8UAAIJAAgIhAtMPgD6AAAJAAgIhAtMPgD6AAAAAA==.',['无量']='无量寿福:BAAAKgAECgUIBQAAAA==.',['旺仔']='旺仔大馒头:BAABKgAFFH8IAAIRAAQIUiPfGQAYAQARAAQIUiPfGQAYAQAAAA==.',['昂寇']='昂寇:BAACKgAFFH8IAAMPAAQIoQusHAB0AAAPAAQIoQusHAB0AAABAAEIAAD8WAAAAAAqAAQKfx0ABAEACAh9IosSAHUCAAEACAh9IosSAHUCAA8AAgiCHqI3AKYAABAAAwgDD1UqAHAAAAEqAAUUCAgMAAEA9REA.',['易燃']='易燃易炸:BAAAKgAECgQIBAAAAA==.',['星辰']='星辰璀璨:BAAAKgADCggIEQAAAA==.',['晓梦']='晓梦清秋:BAAAKgAFFAYIBAAAAA==.',['普贤']='普贤:BAAAKgAECgYIBwAAAA==.',['智鱼']='智鱼:BAAAKgAECgcIBwAAAA==.',['暗刃']='暗刃风:BAAAKgADCgMIAwAAAA==.',['暗影']='暗影精灵:BAAAKgAECgYIBgAAAA==.',['暗流']='暗流:BAAAKgADCgYIBgAAAA==.',['暮酒']='暮酒:BAAAKgAFFAIIAwAAAA==.',['曾有']='曾有你的森林:BAAAKgAECggIBwAAAA==.',['木法']='木法沙:BAAAKgAECgcIDAAAAA==.',['木瓜']='木瓜很瞌睡:BAAAKgADCgYIBgAAAA==.',['杀手']='杀手也温柔:BAAAKgAFFAgIBAAAAA==.',['李叁']='李叁叁:BAAAKgAECgUIBQAAAA==.',['杠上']='杠上开花:BAABKgAECn8YAAMRAAgIYRTuQQBvAQARAAgIYRTuQQBvAQAhAAIInQVAegBIAAAAAA==.',['杨颖']='杨颖:BAAAKgAECgUIBQAAAA==.',['枼小']='枼小钗:BAABKgAFFH8KAAMBAAYIwRh/FAB3AQABAAYIwRh/FAB3AQAPAAQIXhXqDgDHAAABKgAFFAgIDwABAH4XAA==.',['格衬']='格衬衫:BAAAKgAECggICwAAAA==.',['梦深']='梦深渊:BAABKgAECn8eAAIRAAgIRSBNHwANAgARAAgIRSBNHwANAgAAAA==.',['森岛']='森岛帆高:BAAAKgAECgEIAQAAAA==.',['森语']='森语守护者:BAAAKgAECgYIBgAAAA==.',['橘子']='橘子:BAAAKgAECgcICQAAAA==.',['欧玛']='欧玛吉利曼波:BAABKgAFFH8VAAIIAAYIXRJNEQA4AQAIAAYIXRJNEQA4AQAAAA==.',['止战']='止战之睇:BAAAKgADCgIIAgAAAA==.',['正义']='正义的沈沈:BAAAKgAECgUIBQAAAA==.',['死神']='死神来了:BAAAKgAECgYICgAAAA==.',['残叶']='残叶逆风:BAAAKgAECgEIAQAAAA==.',['毛绒']='毛绒玩具:BAAAKgAECgIIAgAAAA==.',['水蜻']='水蜻蜓:BAAAKgADCggICAAAAA==.',['江天']='江天君:BAABKgAFFH8IAAIRAAQI0CQ2BAA/AQARAAQI0CQ2BAA/AQAAAA==.',['江晴']='江晴:BAABKgAECn8sAAIRAAgI6xlAJQD7AQARAAgI6xlAJQD7AQAAAA==.',['江湖']='江湖小猎:BAABKgAFFH8GAAIeAAYISRoMDwBwAQAeAAYISRoMDwBwAQAAAA==.',['油炸']='油炸冰淇淋:BAAAKgAECgEIAQAAAA==.',['沿海']='沿海地带:BAAAKgAFFAEIAQAAAA==.',['法爷']='法爷来了:BAAAKgAECgIIAgAAAA==.',['泥头']='泥头车:BAAAKgAFFAIIAgAAAA==.',['泪流']='泪流满面:BAAAKgADCgEIAgAAAA==.泪流满面啊啊:BAAAKgADCgEIAQAAAA==.',['泰达']='泰达希尔之殇:BAAAKgAFFAIIAgAAAA==.',['洛丹']='洛丹伦的信仰:BAAAKgAECgYIDQAAAA==.洛丹伦的回响:BAAAKgAECgYIBgAAAA==.',['洽宝']='洽宝:BAAAKgADCgMIAwAAAA==.',['浅草']='浅草风树:BAAAKgADCgEIAQAAAA==.',['海格']='海格拉:BAAAKgAFFAgIBAAAAA==.',['淘宝']='淘宝:BAAAKgAECggICAAAAA==.',['淘淘']='淘淘气:BAAAKgADCgMIAwAAAA==.',['淡夏']='淡夏那傷:BAAAKgAECgEIAQAAAA==.',['清蓝']='清蓝:BAAAKgAECggIBQAAAA==.',['渺小']='渺小坦克车:BAAAKgAFFAEIAQAAAA==.',['漠声']='漠声人:BAAAKgAECgQIBgAAAA==.',['漫漫']='漫漫山山:BAAAKgADCggICAAAAA==.',['火火']='火火炎:BAAAKgAFFAgIBAAAAA==.',['灬浮']='灬浮雲灬:BAAAKgAECgMIAwAAAA==.',['灬緣']='灬緣芳灬:BAABKgAECn8UAAIRAAgIEBFHQwB6AQARAAgIEBFHQwB6AQAAAA==.',['灭霸']='灭霸有理想:BAAAKgAECgMIAwAAAA==.',['灵儿']='灵儿疯丫头:BAAAKgAECgEIAQAAAA==.',['灾难']='灾难慢我一步:BAAAKgAECgYIBwAAAA==.',['炙热']='炙热的花生:BAAAKgAECgMIBgAAAA==.',['烟雨']='烟雨青衫:BAAAKgAFFAQIBAAAAA==.',['然然']='然然:BAACKgAFFH8KAAIEAAYIMh1TDAC8AQAEAAYIMh1TDAC8AQAqAAQKfxQAAgQACAjsIlUJANMCAAQACAjsIlUJANMCAAAA.',['熊丶']='熊丶小兔:BAAAKgAFFAIIAgAAAA==.',['燃烧']='燃烧的花生:BAAAKgAECgYICQAAAA==.',['爱莎']='爱莎莉:BAACKgAFFH87AAQFAAgI4hs8DQC4AQAFAAgI4hs8DQC4AQAHAAEIsANfIAA/AAAVAAEIAACLJAAAAAAqAAQKfzEAAwUACAgiInwSAFcCAAUACAgiInwSAFcCAAcAAQgAEn5DADoAAAAA.',['牛牛']='牛牛涨涨德:BAAAKgAECggIBgAAAA==.',['狂怒']='狂怒猎者:BAABKgAECn8WAAIWAAgIKBhSLgDyAQAWAAgIKBhSLgDyAQAAAA==.狂怒腾德尔:BAAAKgAECgUIEAAAAA==.',['猎风']='猎风:BAABKgAFFH8QAAMWAAQIbSLVDwAOAQAWAAQIAyHVDwAOAQAeAAQI2x+2IgDmAAABKgAFFAgIDgADACocAA==.',['猪猪']='猪猪爱吃瓜:BAAAKgAFFAQIBAAAAA==.',['猫咔']='猫咔不咔:BAAAKgAECgQIAgAAAA==.',['猫筱']='猫筱牧:BAABKgAFFH8FAAIbAAMIVQTSMQB+AAAbAAMIVQTSMQB+AAAAAA==.',['玄锐']='玄锐暮:BAAAKgADCggICAAAAA==.',['王污']='王污山:BAAAKgADCggICAAAAA==.',['琉璃']='琉璃:BAABKgAFFH8GAAIEAAYIQxlkEQCTAQAEAAYIQxlkEQCTAQAAAA==.',['生亦']='生亦何歡:BAAAKgAECggIDgAAAA==.',['白色']='白色暴雨:BAAAKgAECgMIAwAAAA==.',['皇城']='皇城女流氓:BAAAKgAECgEIAQAAAA==.',['盾卫']='盾卫:BAAAKgAECgEIAQAAAA==.',['神之']='神之审判:BAAAKgAECgYICAAAAA==.',['神都']='神都扛得住:BAAAKgAECggIEgAAAA==.',['秋月']='秋月无边:BAABKgAFFH8XAAMNAAgICyM+BgDjAQANAAYIMiM+BgDjAQAOAAQIQQ3aBwBGAQAAAA==.',['粑粑']='粑粑菈:BAAAKgADCgMIAwAAAA==.',['糖果']='糖果寳寳:BAAAKgAECgEIAQAAAA==.',['紫芙']='紫芙:BAABKgAFFH8EAAMFAAQIEBS6LQC3AAAFAAMIEBS6LQC3AAAVAAEIAACqNgAAAAAAAA==.',['红尘']='红尘滚滚:BAAAKgADCggICAAAAA==.',['纵横']='纵横杀戮:BAAAKgAECgUIBQAAAA==.',['罗雷']='罗雷:BAAAKgADCggICAAAAA==.',['羊羊']='羊羊:BAAAKgAECgUIBQAAAA==.',['美味']='美味咸鱼:BAAAKgAECgYIBgAAAA==.',['翰墨']='翰墨:BAAAKgADCgYIBgAAAA==.',['老灯']='老灯益壮:BAAAKgAECgUIBQAAAA==.',['老蘑']='老蘑菇:BAAAKgADCggICAAAAA==.',['聖殿']='聖殿土洐猻:BAAAKgAECgQIBAAAAA==.聖殿小牧:BAAAKgADCgcIBwAAAA==.聖殿小賊:BAAAKgADCgEIAQAAAA==.聖殿爆猎:BAAAKgADCggICAAAAA==.聖殿胖胖:BAAAKgADCggICAAAAA==.聖殿黯黑:BAAAKgADCggICAAAAA==.',['肯塔']='肯塔基波旁:BAACKgAFFH8eAAIFAAUIyRn/DwA3AQAFAAUIyRn/DwA3AQAqAAQKfyQAAwUACAhpH0QRAGACAAUACAhpH0QRAGACAAcAAQghDZVDACcAAAAA.',['胖琥']='胖琥:BAABKgAFFH8MAAMFAAMISgquNQCZAAAFAAMISgquNQCZAAAHAAEIlAbkEwA4AAAAAA==.',['自缢']='自缢的人偶:BAAAKgAECgUIBQABKgAECgMIAwAXAAAAAA==.',['舞羽']='舞羽:BAABKgAFFH8GAAMiAAYIdw8YGQDXAAAiAAUIpQwYGQDXAAAEAAEImwxoWwBFAAAAAA==.',['芒果']='芒果薯片:BAAAKgADCgUIBQAAAA==.',['芝芝']='芝芝芒芒:BAAAKgAECggICAAAAA==.',['花漾']='花漾:BAAAKgADCgIIAgAAAA==.',['花见']='花见素:BAABKgAFFH8KAAIWAAYIex2IDwCAAQAWAAYIex2IDwCAAQAAAA==.',['苦小']='苦小九:BAABKgAFFH8IAAIDAAgI5AtCDADeAQADAAgI5AtCDADeAQAAAA==.',['莫声']='莫声人:BAAAKgAECgYICQAAAA==.',['著莪']='著莪菖蒲:BAAAKgAECgYIBgAAAA==.',['蓝天']='蓝天中的阴影:BAACKgAFFH8aAAMjAAUIGhLVEQAPAQAjAAUIGhLVEQAPAQAaAAMIvg1+FQB3AAAqAAQKfysABCMACAioF10kAKwBACMACAioF10kAKwBABoABQj5EHczAP4AABsAAQgAAKujAAAAAAAA.',['藏镜']='藏镜人:BAABKgAFFH8IAAILAAgI+RB/CACAAQALAAgI+RB/CACAAQAAAA==.',['虎视']='虎视眈眈:BAABKgAFFH8KAAMEAAYIBRLMGABSAQAEAAYIBRLMGABSAQAiAAMISAYaHQBhAAABKgAFFAgIEQAiAD4jAA==.',['虚空']='虚空行者:BAAAKgAFFAgIBAAAAA==.',['蜡笔']='蜡笔小心眼子:BAACKgAFFH8UAAMWAAYIIRooDwCEAQAWAAYIIRooDwCEAQAeAAII8wqASQBaAAAqAAQKfyoAAxYACAg3HI1JANcBABYACAhoGo1JANcBAB4ABQhDG99NABkBAAAA.',['訷説']='訷説要有光:BAABKgAFFH8JAAIDAAcIdBvnDQD2AQADAAcIdBvnDQD2AQAAAA==.',['请嫑']='请嫑打我:BAACKgAFFH8aAAIBAAMIBxMnLwDTAAABAAMIBxMnLwDTAAAqAAQKfyEAAwEACAi5HA8rANEBAAEACAi5HA8rANEBABAABghxChUgAMIAAAAA.',['诸神']='诸神丶心雨:BAACKgAFFH8vAAIeAAgI5iTyAQCrAgAeAAgI5iTyAQCrAgAqAAQKfyAAAx4ACAigIh8IAKgCAB4ACAigIh8IAKgCABYACAgDDxhzAFoBAAAA.',['读书']='读书有益健康:BAAAKgAFFAQIBAAAAA==.',['豪猪']='豪猪仔:BAAAKgAECgYIDQAAAA==.',['财源']='财源广进:BAAAKgAECgQIBAAAAA==.',['贰路']='贰路奶粉:BAAAKgAECgIIAgAAAA==.',['走错']='走错:BAABKgAFFH8IAAIRAAQIoAPiPwCJAAARAAQIoAPiPwCJAAAAAA==.',['路西']='路西法:BAAAKgAECggIEAAAAA==.',['辛多']='辛多雷的荣耀:BAAAKgAECgYIDAAAAA==.',['迪肯']='迪肯大爷:BAAAKgAFFAYIBAAAAA==.',['迷你']='迷你星:BAABKgAFFH8LAAINAAYIqAp0CwAKAQANAAYIqAp0CwAKAQAAAA==.',['逍遥']='逍遥之德:BAAAKgAECgEIAQAAAA==.',['逝去']='逝去的秦春:BAAAKgAECgUICQAAAA==.',['遇见']='遇见:BAAAKgADCgEIAQAAAA==.遇见晴天:BAAAKgADCggICAAAAA==.',['邪魅']='邪魅:BAAAKgADCgUIBgAAAA==.',['酋长']='酋长派来卧底:BAAAKgADCgYIBgAAAA==.',['酷一']='酷一菈:BAABKgAFFH8QAAMeAAMItQqnNACgAAAeAAMItQqnNACgAAAWAAEIMwMCZQAjAAAAAA==.',['银月']='银月星晴:BAAAKgADCggICAAAAA==.',['长期']='长期素食:BAAAKgADCggICAAAAA==.',['闪电']='闪电格鲁特:BAAAKgADCgMIAwAAAA==.',['阳明']='阳明贪狼:BAAAKgAECgYICAAAAA==.',['阿尔']='阿尔萨司:BAAAKgAFFAYIAgAAAA==.',['阿拉']='阿拉翠翠:BAAAKgADCgcIBwAAAA==.',['陈赫']='陈赫:BAAAKgADCgEIAQAAAA==.',['陌声']='陌声人:BAAAKgAECgUIBAAAAA==.',['随波']='随波逐流:BAAAKgADCgQIBAAAAA==.',['隽永']='隽永刀:BAAAKgAECgUICAAAAA==.',['霍恩']='霍恩斯:BAAAKgAFFAIIAgAAAA==.',['静大']='静大人的猫:BAAAKgAECgQIBgAAAA==.',['非主']='非主流迪迦:BAABKgAECn8WAAIVAAgIOAvoPgD4AAAVAAgIOAvoPgD4AAAAAA==.',['颜值']='颜值担当:BAAAKgADCgcIBwAAAA==.',['風之']='風之祣人:BAAAKgAECgYIBgAAAA==.',['风行']='风行者希尔:BAAAKgAFFAIIAgAAAA==.',['飘雪']='飘雪清风月朗:BAACKgAFFH8oAAMkAAYIYx3lAQArAQAMAAYIYBDeBQB+AQAkAAUIsSPlAQArAQAqAAQKfzIAAiQACAhZJQ8CAOUCACQACAhZJQ8CAOUCAAAA.',['飞舞']='飞舞的苹果:BAABKgAECn8ZAAIJAAcIVhg7IQCoAQAJAAcIVhg7IQCoAQAAAA==.',['飞霄']='飞霄:BAAAKgAFFAQIBAAAAA==.',['飞鸟']='飞鸟和游鱼:BAAAKgAECggIDgAAAA==.',['首席']='首席烤串儿:BAAAKgADCgYIDQAAAA==.',['马二']='马二饼:BAAAKgAFFAQIBAAAAA==.',['骑士']='骑士四月六:BAAAKgAECgcICgAAAA==.',['魂歌']='魂歌:BAAAKgAFFAIIAQABKgAFFAgIEAAaAFsKAA==.',['魔瘾']='魔瘾患者:BAAAKgADCggICAAAAA==.',['鸢蓝']='鸢蓝:BAAAKgAFFAIIAgAAAA==.',['鹌鹑']='鹌鹑在减肥:BAAAKgADCgEIAQAAAA==.',['麦迪']='麦迪武:BAAAKgAECgYICAAAAA==.',['黄乄']='黄乄泉:BAAAKgADCgUIBQAAAA==.',['黄昏']='黄昏花易落:BAABKgAFFH8LAAIDAAYIHxxmFQCwAQADAAYIHxxmFQCwAQAAAA==.',['黑白']='黑白郎君:BAAAKgAFFAIIAgAAAA==.',['黑角']='黑角行者:BAAAKgAECgUICQAAAA==.',['黑铁']='黑铁元素萨:BAABKgAECn8VAAIRAAgI1x3FJADwAQARAAgI1x3FJADwAQAAAA==.',['黒碳']='黒碳:BAAAKgAECgEIAQAAAA==.',['默声']='默声人:BAAAKgAECgYICgAAAA==.',['龙希']='龙希尔瓦纳斯:BAABKgAFFH8GAAIZAAUIKhYrDwAhAQAZAAUIKhYrDwAhAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end