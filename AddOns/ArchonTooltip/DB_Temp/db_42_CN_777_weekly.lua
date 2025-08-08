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
 local lookup = {'Hunter-BeastMastery','Rogue-Outlaw','Warlock-Destruction','Warlock-Demonology','Mage-Frost','Paladin-Retribution','Hunter-Marksmanship','DemonHunter-Havoc','Warrior-Arms','Priest-Holy','Paladin-Protection','Evoker-Devastation','Shaman-Restoration','Druid-Balance','Druid-Restoration','DeathKnight-Blood','Paladin-Holy','Druid-Guardian','Rogue-Assassination','Shaman-Elemental','DeathKnight-Unholy','DeathKnight-Frost','Mage-Fire','Unknown-Unknown','Monk-Windwalker','Shaman-Enhancement','Warrior-Protection','Monk-Mistweaver','Warlock-Affliction','Mage-Arcane',}; local provider = {region='CN',realm='祖阿曼',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aisaka:BAAAKgAECgMIAQAAAA==.',Al='Alphawolf:BAAAKgAECgUIBQAAAA==.',Be='Beacon:BAAAKgADCgEIAQAAAA==.',Fr='Frista:BAABKgAECn8iAAIBAAgIHRbiPQCuAQABAAgIHRbiPQCuAQABKgAFFAgICAABABcdAA==.',Gu='Gurban:BAAAKgAFFAgIAQAAAA==.',He='Heisenberg:BAAAKgAECgEIAQAAAA==.',Kn='Kngdeathchen:BAAAKgAFFAQIBAAAAA==.',Mi='Mikulu:BAABKgAECn8ZAAICAAgIsx/1AwBYAgACAAgIsx/1AwBYAgAAAA==.',Ni='Nicholaslyx:BAACKgAFFH8KAAMDAAQIdhpQFADTAAADAAMIdhpQFADTAAAEAAEIAAAQNQAAAAAqAAQKfxwAAgMACAhDHd0YAC4CAAMACAhDHd0YAC4CAAAA.',Re='Rexsparrow:BAABKgAECn8cAAIFAAgIciHeDACcAgAFAAgIciHeDACcAgAAAA==.',St='Starxcc:BAAAKgAECggIEAAAAA==.',Un='Uncit:BAAAKgAECgYIDwAAAA==.',['一丢']='一丢:BAABKgAFFH8KAAIGAAQIDw+sGgAQAQAGAAQIDw+sGgAQAQAAAA==.',['一乐']='一乐:BAAAKgADCgIIAgAAAA==.',['一彩']='一彩云追月一:BAAAKgAECggIEQAAAA==.',['丁真']='丁真:BAAAKgAFFAEIAQAAAA==.',['三十']='三十二新月:BAAAKgADCggICAAAAA==.',['丨傷']='丨傷丶心:BAAAKgADCgYIBgAAAA==.',['丶乔']='丶乔巴:BAABKgAFFH8LAAIHAAMI2Q4iMwClAAAHAAMI2Q4iMwClAAAAAA==.',['丶小']='丶小青龙丶:BAAAKgADCgMIAwAAAA==.',['丶幽']='丶幽蓝蝶:BAABKgAFFH8KAAIIAAMIPAnjKwCFAAAIAAMIPAnjKwCFAAAAAA==.',['丶红']='丶红魔:BAABKgAFFH8HAAIJAAMIHAx9DADIAAAJAAMIHAx9DADIAAAAAA==.',['乌塔']='乌塔塔:BAAAKgADCgIIAgAAAA==.',['云中']='云中客灬敏:BAAAKgAECgMIAwAAAA==.云中客灬翔:BAAAKgAECggIDAAAAA==.',['云水']='云水:BAAAKgAECggICQAAAA==.',['伊一']='伊一利一丹:BAAAKgAECgQIBAAAAA==.',['伊利']='伊利蛋幼儿园:BAABKgAFFH8HAAIIAAUIrBdBFwBBAQAIAAUIrBdBFwBBAQABKgAFFAgIHAAKANkiAA==.',['会发']='会发光:BAAAKgADCgQIBAAAAA==.',['会發']='会發光:BAAAKgAFFAQIBAAAAA==.',['传说']='传说的王者:BAAAKgADCgEIAQAAAA==.',['低调']='低调的小骑:BAAAKgAFFAEIAQAAAA==.',['你四']='你四不四萨:BAAAKgADCggICAAAAA==.',['倏忽']='倏忽如风:BAABKgAECn8mAAILAAcIbxe1HAB1AQALAAcIbxe1HAB1AQAAAA==.',['倾斜']='倾斜天平:BAAAKgAECgMIAwAAAA==.',['傲世']='傲世斩神:BAAAKgADCgEIAQAAAA==.',['兜兜']='兜兜里藏的糖:BAAAKgADCgIIAgAAAA==.',['八千']='八千米海岸:BAAAKgAECgYIBgAAAA==.',['六侠']='六侠:BAAAKgADCgEIAQAAAA==.',['六条']='六条德:BAAAKgAECgYICgAAAA==.',['六次']='六次骑:BAAAKgAFFAMIAwAAAA==.',['冰火']='冰火精灵:BAAAKgAECgEIAQAAAA==.',['冰雪']='冰雪消融:BAAAKgADCggICAAAAA==.',['别奶']='别奶:BAABKgAFFH8RAAIGAAMIrBNKTgDTAAAGAAMIrBNKTgDTAAAAAA==.',['别急']='别急有反转:BAACKgAFFH8gAAIMAAgIeR68CgDCAQAMAAgIeR68CgDCAQAqAAQKfyIAAgwACAhkIskOAFoCAAwACAhkIskOAFoCAAAA.',['别打']='别打我真怕疼:BAABKgAFFH8IAAINAAQIIwSsQACFAAANAAQIIwSsQACFAAAAAA==.',['刺哥']='刺哥:BAAAKgADCgYIBgAAAA==.',['刺灬']='刺灬瑰:BAAAKgAECggICgAAAA==.',['剃头']='剃头不用刀:BAAAKgADCgcIBwAAAA==.',['午夜']='午夜独醉:BAAAKgAECgMIAwAAAA==.',['可可']='可可:BAAAKgADCgcIBwAAAA==.',['名动']='名动天下:BAAAKgAFFAQIBAAAAA==.',['呱呱']='呱呱护卫:BAABKgAFFH8GAAIGAAYIzQQ+MgAgAQAGAAYIzQQ+MgAgAQAAAA==.',['和绅']='和绅老婆:BAAAKgADCggICAAAAA==.',['咕一']='咕一一丶:BAABKgAFFH8NAAMOAAgIVRt4EACcAQAOAAcIORx4EACcAQAPAAEIWA0YNQBGAAAAAA==.',['咕咕']='咕咕辣么:BAAAKgADCgYIBgAAAA==.',['唐丶']='唐丶吉诃德:BAAAKgAFFAQIBAAAAA==.',['四月']='四月一:BAAAKgADCggICAAAAA==.',['圣光']='圣光婴宁:BAABKgAFFH8FAAIGAAMIyAQEMwCXAAAGAAMIyAQEMwCXAAAAAA==.',['圣言']='圣言律令:BAAAKgAFFAQIBAAAAA==.',['坤拳']='坤拳掌门人:BAAAKgAFFAgIBAAAAA==.',['墨邪']='墨邪无痕:BAAAKgAECgcIEwAAAA==.',['多情']='多情侠客:BAAAKgADCgYIBgAAAA==.',['夜枫']='夜枫丶岚:BAAAKgAFFAMIBAAAAA==.',['夜雨']='夜雨潇潇:BAABKgAECn8XAAMHAAgI8hCETgAWAQAHAAgI8hCETgAWAQABAAgIBwK27wBUAAAAAA==.',['大秦']='大秦铁甲如云:BAABKgAFFH8GAAIQAAYIbAXmCgDuAAAQAAYIbAXmCgDuAAAAAA==.',['大蛇']='大蛇丸:BAACKgAFFH8NAAIGAAYIgRu3FgCmAQAGAAYIgRu3FgCmAQAqAAQKfxwAAgYACAh7HRtJABUCAAYACAh7HRtJABUCAAAA.',['天空']='天空的恶魔:BAAAKgAECgEIAQAAAA==.天空的骑士:BAAAKgAECgUICAAAAA==.',['妖妮']='妖妮大姐:BAAAKgAFFAgIBAAAAA==.',['姝然']='姝然大宝贝儿:BAAAKgADCgEIAQAAAA==.',['娜塔']='娜塔亚:BAABKgAFFH8WAAMBAAcINR65AQDaAQABAAcI4hq5AQDaAQAHAAYIBSH6DACJAQABKgAFFAgICAABABcdAA==.',['季海']='季海晴:BAAAKgADCggIEwAAAA==.',['守护']='守护:BAABKgAFFH8KAAMBAAYINxhgEwBbAQABAAYINxhgEwBbAQAHAAEIAwCpLgABAAAAAA==.',['射你']='射你个不吱声:BAAAKgAECgIIAgAAAA==.',['小妹']='小妹:BAAAKgADCgIIAgAAAA==.',['小酌']='小酌:BAAAKgAECggICAAAAA==.',['屋檐']='屋檐下你我:BAABKgAFFH8HAAMRAAMIxQq1EQC0AAARAAMIxQq1EQC0AAAGAAEIYQIqkQAsAAAAAA==.屋檐下的你:BAABKgAFFH8GAAINAAMIGQpaOACgAAANAAMIGQpaOACgAAAAAA==.',['崔崔']='崔崔:BAAAKgAECgYIBgAAAA==.',['布莱']='布莱克嘿嘿:BAAAKgADCgEIAQAAAA==.',['希尓']='希尓瓦娜斯丿:BAAAKgAECgEIAQAAAA==.',['幼儿']='幼儿园体委:BAAAKgAECgIIAgAAAA==.',['弑神']='弑神丿觞:BAABKgAECn8UAAMBAAgIARzKOgC6AQABAAgIARzKOgC6AQAHAAEIkQIrmAAZAAAAAA==.',['张三']='张三爷:BAAAKgAECggICAAAAA==.',['很皮']='很皮的小脑辅:BAAAKgADCggICAAAAA==.',['德鲁']='德鲁之灵:BAABKgAECn8aAAMOAAgI+BQoTACGAQAOAAcIQhcoTACGAQASAAEIPAeuRQAPAAAAAA==.',['忘形']='忘形丶:BAAAKgADCgcIBwAAAA==.',['快意']='快意刀:BAAAKgAECggICAAAAA==.',['我是']='我是坦克:BAAAKgAFFAEIAQAAAA==.我是龙鸣:BAABKgAFFH8JAAIMAAUIphJ5JACuAAAMAAUIphJ5JACuAAAAAA==.',['战神']='战神无畏:BAAAKgADCgMIAwAAAA==.',['扎瓜']='扎瓜胡子:BAABKgAFFH8IAAINAAgILQbHCQBtAQANAAgILQbHCQBtAQAAAA==.',['抖音']='抖音玩物丧智:BAACKgAFFH8SAAIGAAYIpRsiGQCVAQAGAAYIpRsiGQCVAQAqAAQKfxYAAgsACAhGGpUSAOsBAAsACAhGGpUSAOsBAAEqAAUUBwgkAAYAqSMA.',['抱皂']='抱皂不安:BAAAKgAFFAIIAgAAAA==.',['拽丫']='拽丫头:BAAAKgAECgMIAwAAAA==.',['挤挤']='挤挤不露:BAAAKgAFFAMIBAAAAA==.挤挤布鲁:BAAAKgAECgMIAwAAAA==.',['斗牛']='斗牛牛:BAAAKgADCgIIAgAAAA==.',['斩月']='斩月:BAAAKgAECgMIAwAAAA==.',['斯人']='斯人如逝:BAAAKgAFFAMIBAAAAA==.',['无情']='无情无意狂:BAAAKgADCgUIBQAAAA==.',['无求']='无求心静:BAABKgAFFH8FAAITAAIIhQ4yJACGAAATAAIIhQ4yJACGAAAAAA==.',['普通']='普通市民:BAAAKgAECggICAAAAA==.',['曰光']='曰光之橙:BAAAKgADCggICAAAAA==.',['月半']='月半亻子:BAAAKgADCggICAAAAA==.',['朕射']='朕射儞捂嘴:BAAAKgAECgUIBQAAAA==.',['望云']='望云卷云舒:BAAAKgADCggICAAAAA==.',['杜康']='杜康:BAAAKgAECggICAAAAA==.',['来根']='来根梦龙:BAAAKgAFFAIIAQAAAA==.',['杨幂']='杨幂:BAABKgAFFH8OAAIGAAYIHBjrGwCFAQAGAAYIHBjrGwCFAQAAAA==.',['東北']='東北最速傳說:BAAAKgAECggICAAAAA==.',['果果']='果果小麻瓜:BAACKgAFFH8HAAIHAAMIYw0oOACVAAAHAAMIYw0oOACVAAAqAAQKfxUAAwcACAiBEi8vAHkBAAcACAhxES8vAHkBAAEABQiPDFq2ALcAAAAA.',['柒院']='柒院脊梁:BAAAKgAECggIDwABKgAFFAMICAAUADQOAA==.',['柔丶']='柔丶唲:BAAAKgAECggICAAAAA==.',['梦幻']='梦幻之锤:BAAAKgADCgIIAgAAAA==.',['梯叁']='梯叁肆:BAAAKgAECgYIBgAAAA==.',['次级']='次级风暴元素:BAABKgAFFH8PAAMUAAYIShcXCgApAQAUAAUIlxkXCgApAQANAAUI2wtcKAB+AAAAAA==.',['求上']='求上上签:BAABKgAFFH8IAAIGAAQIVBYCIgDgAAAGAAQIVBYCIgDgAAAAAA==.',['江湖']='江湖术:BAAAKgADCggICAAAAA==.',['污日']='污日:BAABKgAFFH8MAAMBAAMIjyGSCgAtAQABAAMIjyGSCgAtAQAHAAMI4BrpLAC4AAAAAA==.',['法兰']='法兰西多士:BAACKgAFFH8PAAIVAAYIdBnGMgDKAAAVAAYIdBnGMgDKAAAqAAQKfygAAxUACAjNHoQcACsCABUACAjNHoQcACsCABYAAwjmBFowAEsAAAAA.',['海瑟']='海瑟丶薇:BAAAKgAECggICAAAAA==.海瑟薇丶安妮:BAABKgAFFH8JAAISAAUIUQ5UAwDLAAASAAUIUQ5UAwDLAAAAAA==.',['海蓝']='海蓝之迷:BAAAKgAFFAIIAgAAAA==.',['温吻']='温吻尔雅:BAAAKgADCgQIBAAAAA==.',['灬图']='灬图腾:BAAAKgADCgMIAwAAAA==.',['灬斌']='灬斌灬:BAAAKgAECgEIAQAAAA==.',['灬暴']='灬暴躁:BAAAKgAECgQIBAAAAA==.',['灰汰']='灰汰狼:BAAAKgAECgcIAwAAAA==.',['炉钩']='炉钩子丶:BAACKgAFFH8IAAMUAAQIMx5eEgDVAAAUAAQIMx5eEgDVAAANAAEIAAB1VgAAAAAqAAQKfxgAAxQACAglInEhAOQBABQACAglInEhAOQBAA0ACAhTCT5dACcBAAAA.',['炮炮']='炮炮糖:BAAAKgADCgQIBAAAAA==.',['無丶']='無丶过:BAAAKgADCggIBQAAAA==.',['無枫']='無枫:BAAAKgADCggICAAAAA==.',['焦糖']='焦糖麦旋风:BAAAKgAECgUIBwAAAA==.',['煤咕']='煤咕咕:BAAAKgAECgEIAQAAAA==.',['爱曲']='爱曲:BAAAKgAECgIIAwAAAA==.',['牜仔']='牜仔:BAAAKgAECgUIBwAAAA==.',['狂野']='狂野小德:BAAAKgAECgQIBAAAAA==.',['独奶']='独奶天下:BAAAKgAECgEIAQAAAA==.',['独射']='独射天下丶:BAAAKgAECggICAAAAA==.',['独戮']='独戮天下:BAAAKgAECgUICQAAAA==.',['独搅']='独搅天下:BAAAKgAFFAMIBAAAAA==.',['独霹']='独霹天下:BAABKgAFFH8IAAINAAgIrg1mBwCmAQANAAgIrg1mBwCmAQAAAA==.',['独骑']='独骑天下:BAAAKgAECgUIBQAAAA==.',['狼人']='狼人微微:BAAAKgAECgQIAgAAAA==.',['猎灬']='猎灬王:BAAAKgADCgYIBgAAAA==.',['猛思']='猛思君:BAAAKgAFFAEIAQAAAA==.',['猪小']='猪小白:BAABKgAFFH8GAAIRAAMIOwaeEwCgAAARAAMIOwaeEwCgAAAAAA==.',['王源']='王源:BAABKgAECn8QAAIXAAgIfxsSIgAoAgAXAAgIfxsSIgAoAgABKgAFFAEIAQAYAAAAAA==.',['班长']='班长:BAAAKgAECgEIAQAAAA==.',['琅琊']='琅琊王:BAAAKgADCgUIBQAAAA==.',['瑞文']='瑞文戴爾女爵:BAAAKgAECgYIBgAAAA==.',['甜瓜']='甜瓜:BAABKgAECn8eAAMQAAgIchovDwACAgAQAAgIchovDwACAgAVAAIITQmcuQBXAAAAAA==.',['电动']='电动牛仔:BAAAKgAECgYIBgAAAA==.',['疯狂']='疯狂的摇滚熊:BAACKgAFFH8RAAIZAAYIFBjiBgCdAQAZAAYIFBjiBgCdAQAqAAQKfxYAAhkABwguE50xAGMBABkABwguE50xAGMBAAAA.',['皮皮']='皮皮瞎:BAAAKgADCggICAAAAA==.',['看不']='看不见的土豪:BAABKgAFFH8KAAITAAgI5BZqBgAdAgATAAgI5BZqBgAdAgAAAA==.',['眾生']='眾生繁華:BAABKgAFFH8MAAMGAAQIThMhJADXAAAGAAQIThMhJADXAAALAAQI5AHjEgBYAAAAAA==.',['瞎咔']='瞎咔啦咔:BAAAKgAECgYIBgAAAA==.',['祖国']='祖国昌盛:BAAAKgAFFAYIBAAAAA==.',['神赐']='神赐之名:BAACKgAFFH8PAAMHAAUIFRAgLAC6AAABAAMIag7+GgDAAAAHAAUIBw0gLAC6AAAqAAQKfxUAAwEACAitEnxiAIoBAAEACAjDD3xiAIoBAAcABQiCElRcAK8AAAAA.神赐逆袭:BAAAKgADCgUIBQAAAA==.',['粉色']='粉色红头龟:BAAAKgAECgQIBAAAAA==.',['红剑']='红剑:BAAAKgAECgIIAgAAAA==.',['红绿']='红绿灯的黄:BAABKgAFFH8IAAIGAAgI5gtADADfAQAGAAgI5gtADADfAQAAAA==.',['绝版']='绝版青春:BAAAKgAECggICAAAAA==.',['美好']='美好时光:BAAAKgADCgcIBwAAAA==.',['联盟']='联盟疤痕:BAABKgAFFH8MAAIGAAMIxgs/LAC1AAAGAAMIxgs/LAC1AAAAAA==.',['背书']='背书包上学堂:BAAAKgAECgIIAgAAAA==.',['胡萝']='胡萝卜中人:BAAAKgAFFAMIAwAAAA==.胡萝卜小人:BAABKgAECn8UAAIaAAgIxQ7JJgCRAQAaAAgIxQ7JJgCRAQAAAA==.',['花叶']='花叶:BAAAKgAECgQIBAAAAA==.',['莫名']='莫名:BAAAKgAECgEIAQAAAA==.',['菊击']='菊击手:BAAAKgAECgYIBgAAAA==.',['菠萝']='菠萝啤:BAAAKgADCggIDAABKgAECggIFAARAIohAA==.',['萨拉']='萨拉隆:BAAAKgAECgYIBgAAAA==.',['落叶']='落叶仨:BAAAKgADCgIIAgAAAA==.',['葉小']='葉小風:BAACKgAFFH8GAAIDAAMI7gpkMQCpAAADAAMI7gpkMQCpAAAqAAQKfxYAAgMACAhxDwdCAGIBAAMACAhxDwdCAGIBAAAA.',['蔻梢']='蔻梢:BAAAKgADCgIIAgAAAA==.',['藏海']='藏海:BAAAKgADCgEIAQAAAA==.',['虾溜']='虾溜哒灬:BAABKgAFFH8PAAIDAAgIHB5ZAgCIAgADAAgIHB5ZAgCIAgAAAA==.',['蛊月']='蛊月:BAABKgAECn8bAAIDAAgItha8HADBAQADAAgItha8HADBAQAAAA==.',['蜘蛛']='蜘蛛泡酒:BAAAKgAECgUIBQAAAA==.',['詮釋']='詮釋傳說:BAABKgAECn8ZAAIPAAgI7ReUIQCRAQAPAAgI7ReUIQCRAQAAAA==.',['謬丶']='謬丶論:BAABKgAFFH8PAAIbAAQIsgnqCQCJAAAbAAQIsgnqCQCJAAAAAA==.',['试玩']='试玩账号:BAAAKgADCggICAAAAA==.',['谁知']='谁知莲的心事:BAAAKgADCgQIBAAAAA==.',['调查']='调查她学历:BAAAKgAFFAIIAgAAAA==.',['豆比']='豆比别跑:BAAAKgADCgYIBgAAAA==.',['賀無']='賀無晴:BAABKgAFFH8FAAIPAAUI+h0/CwBSAQAPAAUI+h0/CwBSAQAAAA==.',['贰狗']='贰狗:BAAAKgAFFAIIAgAAAA==.',['赵百']='赵百灵:BAACKgAFFH8LAAIcAAMIVCIYCQAfAQAcAAMIVCIYCQAfAQAqAAQKfyUAAhwACAhEJkUBAP8CABwACAhEJkUBAP8CAAAA.',['超爱']='超爱玩:BAACKgAFFH8FAAIGAAIIexP1MwCTAAAGAAIIexP1MwCTAAAqAAQKf0AAAgYACAhaHAISAEMCAAYACAhaHAISAEMCAAAA.',['跳舞']='跳舞的圣歌:BAAAKgAECgIIAgAAAA==.',['过来']='过来吃奶:BAAAKgADCgQIBAAAAA==.',['送你']='送你洗面奶:BAABKgAFFH8GAAIKAAYIJhVpDABdAQAKAAYIJhVpDABdAQAAAA==.',['逍遥']='逍遥的天空:BAAAKgAECgEIAQAAAA==.',['道艰']='道艰难唯志成:BAABKgAECn8ZAAQEAAgINx8eLgBAAQAEAAYIVBseLgBAAQAdAAMItxp2IwDCAAADAAEIhB4newBXAAAAAA==.',['那天']='那天的记忆:BAAAKgAECgcICwAAAA==.',['部落']='部落一哥:BAAAKgAECgUIBwAAAA==.部落大肉盾:BAACKgAFFH8IAAILAAYIqQmyCQD/AAALAAYIqQmyCQD/AAAqAAQKfx0AAwsACAjQFsIHAM0BAAsACAjQFsIHAM0BAAYACAifDrMwAFIBAAAA.',['银一']='银一霏:BAABKgAFFH8XAAIBAAYIdR/1CgC/AQABAAYIdR/1CgC/AQABKgAFFAcIJAAGAKkjAA==.',['闹呢']='闹呢:BAAAKgAECgQIBAAAAA==.',['阿尔']='阿尔赛利亚:BAACKgAFFH8aAAMGAAQItAacMQCdAAAGAAQItAacMQCdAAARAAIIDgMDGgBlAAAqAAQKfzsAAwYACAicFF9yALMBAAYACAicFF9yALMBABEAAwghCONGAGIAAAAA.',['風凌']='風凌之黑雪:BAAAKgAECgEIAQAAAA==.',['风筝']='风筝的决心:BAABKgAFFH8FAAIHAAUIuhpTHQAHAQAHAAUIuhpTHQAHAQAAAA==.',['骨頭']='骨頭:BAABKgAECn8oAAIBAAgIVREPHQCRAQABAAgIVREPHQCRAQAAAA==.',['黎明']='黎明骨刃:BAAAKgAECgEIAQAAAA==.',['黑暗']='黑暗油侠:BAAAKgAECgYIBgAAAA==.',['黑牡']='黑牡丹:BAABKgAECn8XAAMFAAgIrBR1IgCfAQAFAAgIrBR1IgCfAQAeAAEIXweHpQAcAAAAAA==.',['鼠式']='鼠式坦克:BAACKgAFFH8GAAIVAAMI9wbEPgCjAAAVAAMI9wbEPgCjAAAqAAQKfyEAAhUACAg9GCE9ALwBABUACAg9GCE9ALwBAAAA.',['齊達']='齊達內:BAAAKgADCgIIAgAAAA==.',['龙猫']='龙猫小萨:BAAAKgAECgcICwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end