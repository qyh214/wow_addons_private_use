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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','DeathKnight-Unholy','Priest-Holy','Warlock-Destruction','Paladin-Retribution','DeathKnight-Blood','Paladin-Protection','Mage-Fire','Mage-Frost','Mage-Arcane','Shaman-Enhancement','Priest-Discipline','Shaman-Restoration','Warlock-Demonology','Paladin-Holy','Warrior-Fury','Priest-Shadow','Evoker-Devastation','Warrior-Arms','Warrior-Protection','Warlock-Affliction','Druid-Balance','Druid-Restoration','Unknown-Unknown','Monk-Mistweaver','DemonHunter-Vengeance','Monk-Windwalker','Monk-Brewmaster','Shaman-Elemental','Druid-Guardian','Rogue-Assassination','Evoker-Preservation','Hunter-Survival',}; local provider = {region='CN',realm='图拉扬',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aaronluo:BAAAKgAECgUIBgAAAA==.Aaronworld:BAAAKgAECgMIBgAAAA==.',An='Anemone:BAAAKgAECggICAAAAA==.',Ba='Bagandbag:BAACKgAFFH8TAAMBAAMIAxxyIADzAAABAAMIAxxyIADzAAACAAEIARSJWgBDAAAqAAQKfyoAAwEACAgzIcUQAHQCAAEACAgzIcUQAHQCAAIAAghKHL67AEoAAAEqAAUUAwgWAAMAjRsA.',Bu='Butterfly:BAABKgAECn8zAAIEAAgIVR93BQBtAgAEAAgIVR93BQBtAgAAAA==.',Ch='Christiajean:BAAAKgADCggICAAAAA==.',Ci='Cinderrella:BAAAKgADCggICwAAAA==.Cinnamon:BAAAKgAFFAQIBAAAAA==.',Co='Codebreaker:BAAAKgADCgMIAwAAAA==.',Da='Danshengou:BAABKgAFFH8GAAIFAAMIIxNaFACcAAAFAAMIIxNaFACcAAAAAA==.Dante:BAAAKgAECggICAABKgAFFAgIEwAGADQUAA==.',Dr='Drifting:BAAAKgADCggICAAAAA==.',El='Eln:BAAAKgAECgQIBAAAAA==.',Es='Escanor:BAACKgAFFH8LAAIHAAMIRhkcRwDgAAAHAAMIRhkcRwDgAAAqAAQKfxoAAgcACAhwHbVOANIBAAcACAhwHbVOANIBAAAA.',Ev='Evilsoul:BAAAKgADCggICAAAAA==.',Fa='Fayee:BAABKgAFFH8KAAMIAAYI7BmBCQB9AQAIAAYITRWBCQB9AQAEAAIIDw7cHACzAAAAAA==.',Fe='Feona:BAABKgAFFH8IAAIHAAQIbCJIDAAjAQAHAAQIbCJIDAAjAQABKgAFFAgIEQAJAFUbAA==.',Fo='Fountine:BAACKgAFFH8IAAMKAAQIdh+WEQAMAQAKAAQIdh+WEQAMAQALAAQIDA79HQCVAAAqAAQKfygAAwwACAgUIOIGAH0CAAwACAgUIOIGAH0CAAoACAiPFwkoAAgCAAEqAAUUCAgPAA0ALhsA.',Fr='Frozenheart:BAAAKgAFFAQIAQAAAA==.',Fy='Fyee:BAABKgAFFH8MAAMHAAYIGCQTDgD0AQAHAAYIuCMTDgD0AQAJAAIIdx1ACwC0AAAAAA==.',Ji='Jimmygejm:BAAAKgAECgYIBwAAAA==.',Ka='Kazusa:BAABKgAFFH8QAAMLAAYIkCJCBACnAQALAAYIkCJCBACnAQAKAAUIUg2GFQAKAQAAAA==.',La='Lazarus:BAABKgAECn8XAAIEAAYI+hgWEgBfAQAEAAYI+hgWEgBfAQAAAA==.',Ly='Lyics:BAAAKgAECggIDgAAAA==.',Ma='Mandriva:BAACKgAFFH9PAAMCAAgIIiFVAwCQAgACAAgIIiFVAwCQAgABAAEIAxIWJwBGAAAqAAQKfyIAAwIACAg8Iq0bAIkCAAIACAiVH60bAIkCAAEABAg+DiVXAMEAAAAA.',Me='Memoryfan:BAABKgAFFH8bAAIOAAYIECPbAwAbAgAOAAYIECPbAwAbAgAAAA==.',Ne='Nedavil:BAAAKgAECgUICQAAAA==.Newi:BAACKgAFFH8VAAIPAAMI/B2cDwDmAAAPAAMI/B2cDwDmAAAqAAQKfzAAAg8ACAj4IZ8HAFICAA8ACAj4IZ8HAFICAAAA.',No='Nostalie:BAAAKgAFFAYIBAAAAA==.',Ol='Ollie:BAAAKgAFFAQIBAAAAA==.',Pa='Palad:BAAAKgAFFAgIAgAAAA==.Pallas:BAAAKgAFFAMIAwAAAA==.',Pe='Perhon:BAAAKgAECgQIBAAAAA==.',Po='Poyo:BAAAKgAECgEIAQAAAA==.',Py='Pyrrla:BAAAKgAECgMIAwAAAA==.',Ra='Rainbowg:BAAAKgAECgIIAgAAAA==.',Rk='Rkiws:BAAAKgADCgMIAwAAAA==.',Sc='Scarab:BAAAKgAECgYIEwAAAA==.',Sh='Shardows:BAACKgAFFH8YAAIGAAcI0h2qBwAWAgAGAAcI0h2qBwAWAgAqAAQKfxYAAwYACAh/GucpAM8BAAYACAh/GucpAM8BABAAAgjkD1d4ADwAAAAA.',Sk='Skrskr:BAAAKgAFFAMIAwAAAA==.',Sl='Slayerholy:BAABKgAFFH8FAAIHAAUIdxn6LAAzAQAHAAUIdxn6LAAzAQAAAA==.',Sn='Snoweric:BAAAKgAECgYIBwAAAA==.',St='Straybird:BAABKgAFFH8GAAIBAAYIkhBcFQA5AQABAAYIkhBcFQA5AQAAAA==.',Ta='Tan:BAABKgAFFH8MAAMRAAQIWh0PBQD5AAARAAQIWh0PBQD5AAAJAAQIpBJrCwCyAAAAAA==.Taylormomsen:BAAAKgAECggICAAAAA==.',Va='Valora:BAAAKgAECgYIBwAAAA==.',Vi='Vickygogo:BAAAKgADCgEIAQAAAA==.',Wi='Wind:BAAAKgAECggIDwAAAA==.',Zh='Zhao:BAACKgAFFH8FAAILAAMIggcsHQCbAAALAAMIggcsHQCbAAAqAAQKfxsAAgsACAhqGnoJAPsBAAsACAhqGnoJAPsBAAAA.',['一口']='一口南瓜饼:BAAAKgAECgQIBAAAAA==.',['一罐']='一罐可乐:BAAAKgAECggICgAAAA==.',['一路']='一路火花闪电:BAABKgAFFH8IAAIIAAgIHxHgBwCgAQAIAAgIHxHgBwCgAQAAAA==.一路闪电火花:BAAAKgAFFAYIBAAAAA==.',['一鸽']='一鸽能不鸽嘛:BAAAKgAECggICAAAAA==.',['七年']='七年丶:BAAAKgAECggIEAABKgAFFAgIKgACACMgAA==.',['万岁']='万岁万岁:BAAAKgADCgEIAQAAAA==.',['三轩']='三轩家万智:BAAAKgAECgQIBAAAAA==.',['不会']='不会变羊:BAAAKgAECgYIBgAAAA==.',['不愿']='不愿再醒来:BAAAKgAECggICQAAAA==.',['不知']='不知火舞舞:BAAAKgADCggICAAAAA==.',['与光']='与光同尘:BAABKgAECn8oAAIEAAgI2RpoJgDsAQAEAAgI2RpoJgDsAQAAAA==.',['与心']='与心同寂:BAAAKgAECgYIEAAAAA==.',['丐帮']='丐帮弟子:BAAAKgAECgcICQAAAA==.',['东部']='东部:BAAAKgADCgIIAgAAAA==.',['丶全']='丶全村的希望:BAAAKgAECgEIAQAAAA==.',['丶午']='丶午时丨已到:BAAAKgAFFAQIBAAAAA==.',['丶望']='丶望尘莫及:BAAAKgAECgEIAQAAAA==.',['丶过']='丶过客:BAAAKgADCggICAAAAA==.',['二路']='二路:BAABKgAFFH8QAAISAAgInBJ5BgAZAgASAAgInBJ5BgAZAgAAAA==.',['云岚']='云岚:BAAAKgAECgcIBwAAAA==.',['仙女']='仙女儿:BAABKgAFFH8SAAQOAAcIhg7YEwD5AAAOAAUIFhDYEwD5AAATAAIIKwTCFgBmAAAFAAEIOxGnHwA8AAAAAA==.',['仙踪']='仙踪林:BAABKgAECn8qAAIFAAgIJBnRIgCxAQAFAAgIJBnRIgCxAQAAAA==.',['伊莱']='伊莱克斯:BAAAKgADCgYIBgAAAA==.',['会飞']='会飞的蝙蝠:BAABKgAFFH8VAAIUAAQIbyQ2FAAvAQAUAAQIbyQ2FAAvAQABKgAFFAcIKwATAAIhAA==.',['传说']='传说呢袒克:BAABKgAFFH8HAAMVAAQIIQcpHwCVAAAVAAIIGgspHwCVAAAWAAIIJwOiCwBXAAAAAA==.',['何茵']='何茵茵:BAAAKgAECgMIAwAAAA==.',['你不']='你不理人:BAAAKgAFFAcIBAAAAA==.',['你们']='你们速度灭:BAABKgAFFH8ZAAMFAAYIExp7EgAeAQAFAAUI9Bp7EgAeAQATAAYIdRrfCwD8AAAAAA==.',['保丨']='保丨安:BAAAKgADCgYIBgAAAA==.',['傻杰']='傻杰:BAAAKgADCgEIAQAAAA==.',['元素']='元素大君:BAAAKgADCggICAAAAA==.',['光与']='光与影之子:BAAAKgAECgQIBQAAAA==.',['光之']='光之哀傷丶:BAAAKgAECgMIAwAAAA==.',['六幻']='六幻:BAAAKgADCggICAAAAA==.',['兰斯']='兰斯洛特:BAAAKgAECgYIBwAAAA==.',['再来']='再来十个丶:BAAAKgAECggIDwAAAA==.',['冰火']='冰火俩从天:BAAAKgADCgEIAQAAAA==.',['冷月']='冷月倾城:BAABKgAFFH8GAAIHAAYIcBArJABaAQAHAAYIcBArJABaAQAAAA==.冷月天使:BAAAKgAECggICAAAAA==.',['冻空']='冻空粉雪:BAAAKgAFFAMIAwAAAA==.',['凉风']='凉风听雪:BAAAKgADCgMIAwAAAA==.',['凤之']='凤之韵:BAAAKgADCgQIBAAAAA==.',['凯瑟']='凯瑟琳灬冷月:BAACKgAFFH8PAAQFAAUIpxmgDQDOAAAFAAMI9hKgDQDOAAAOAAQIdRodHAC1AAATAAEIjhzzKgBHAAAqAAQKfyQAAw4ACAhdIPUJAIYCAA4ACAhdIPUJAIYCAAUACAhuFXIlAL0BAAAA.',['刁得']='刁得一:BAABKgAFFH8GAAIMAAYIWxAfEgBWAQAMAAYIWxAfEgBWAQAAAA==.',['剑之']='剑之极:BAAAKgAECggICAAAAA==.',['剩骑']='剩骑士:BAAAKgAECgUIBwAAAA==.',['千之']='千之舰:BAAAKgADCgYIBgAAAA==.',['原则']='原则上可以:BAACKgAFFH8gAAMXAAQIax1tCQDuAAAXAAQIax1tCQDuAAAGAAIIIBXnHgCYAAAqAAQKfyYAAxcACAi1Ib8FAB8CABcABwh+Ib8FAB8CAAYABgjPHLcpANABAAAA.',['及时']='及时雨:BAAAKgAECgEIAQAAAA==.',['古咕']='古咕谷:BAACKgAFFH8VAAMYAAQIQCWsBwAzAQAYAAQIQCWsBwAzAQAZAAEIihnCHwBKAAAqAAQKfxUAAxgABwihJbY1AOMBABgABwihJbY1AOMBABkAAwj+HihTAJcAAAEqAAUUBwgrABMAAiEA.',['可爱']='可爱:BAAAKgAFFAQIBAAAAA==.',['吉尔']='吉尔加郭:BAAAKgAECggIDwAAAA==.',['吖姊']='吖姊:BAAAKgAFFAYIAgABKgAFFAgIAgAaAAAAAA==.',['吖姐']='吖姐:BAABKgAFFH8MAAMGAAgIgBxACAALAgAGAAgIgBxACAALAgAQAAEIAADOIgAAAAAAAA==.',['吖弟']='吖弟:BAAAKgAFFAQIAgAAAA==.',['吼吼']='吼吼哈嘿:BAACKgAFFH8VAAIbAAYIZhWNCgB/AQAbAAYIZhWNCgB/AQAqAAQKfxUAAhsACAi9JFUFAM0CABsACAi9JFUFAM0CAAEqAAUUBwgrABMAAiEA.',['呆板']='呆板黏:BAAAKgADCggIBwAAAA==.',['咕噜']='咕噜冒泡泡:BAABKgAFFH8IAAIbAAYIoB38CgB3AQAbAAYIoB38CgB3AQAAAA==.咕噜噜冒泡泡:BAABKgAFFH8UAAMZAAgIAxBCCgBjAQAZAAcIkhFCCgBjAQAYAAcIkAVRGgDWAAAAAA==.',['哈维']='哈维斯:BAAAKgADCgEIAQAAAA==.',['哎丶']='哎丶可惜啊:BAACKgAFFH8WAAMDAAMIjRsvIgD1AAADAAMIjRsvIgD1AAAcAAMI9hLdEwClAAAqAAQKfx0AAxwACAjHHrMNADcCABwACAglHbMNADcCAAMACAjAHWwbACcCAAAA.',['哒哒']='哒哒:BAAAKgAECggIDQAAAA==.',['唉丶']='唉丶怎么办:BAACKgAFFH8QAAMdAAMI6hxcDQAGAQAdAAMI6hxcDQAGAQAbAAMIaxD3IACfAAAqAAQKfzoABB4ACAghIVkEAFMCAB0ACAg3ILwNAFkCAB4ACAiLHlkEAFMCABsACAjhGc8SAP8BAAEqAAUUAwgWAAMAjRsA.',['唤潮']='唤潮者米斯雷:BAAAKgADCgEIAQAAAA==.',['啊喔']='啊喔饿:BAAAKgADCgUIBQAAAA==.',['嘣嚓']='嘣嚓咔嚓:BAAAKgAFFAQIBAAAAA==.',['四通']='四通:BAAAKgADCggICwAAAA==.',['圣光']='圣光出鞘:BAABKgAFFH8IAAIHAAgI5xMrCgAhAgAHAAgI5xMrCgAhAgAAAA==.圣光戈巴塔尔:BAABKgAFFH8LAAMRAAMIEQesEwCgAAARAAMIEQesEwCgAAAHAAMI/wbNaQCYAAAAAA==.圣光霓裳:BAACKgAFFH8WAAIHAAQIRSMILwAsAQAHAAQIRSMILwAsAQAqAAQKfxQAAgcACAhGIhpJABUCAAcACAhGIhpJABUCAAAA.',['圣耀']='圣耀世人:BAAAKgAECggIDwAAAA==.',['埃辛']='埃辛諾斯:BAAAKgAECgUICgAAAA==.',['堕落']='堕落女神:BAABKgAFFH8GAAIGAAYIpguIDwBAAQAGAAYIpguIDwBAAQAAAA==.',['塔宾']='塔宾斯:BAAAKgAECgUIBQAAAA==.',['塞勒']='塞勒涅:BAABKgAECn8jAAIZAAgIWCHgBABYAgAZAAgIWCHgBABYAgAAAA==.',['墨念']='墨念:BAAAKgADCgQIBAAAAA==.',['声微']='声微丶饭否:BAAAKgAECgIIAwAAAA==.',['多弗']='多弗朗明歌:BAAAKgAFFAQIBAAAAA==.',['夜之']='夜之祈:BAAAKgAECgIIAgAAAA==.',['夜凝']='夜凝霜:BAAAKgAECgUIBQAAAA==.',['大一']='大一武一生:BAABKgAECn8aAAIbAAgIzhlMHgD5AQAbAAgIzhlMHgD5AQAAAA==.',['大地']='大地在忽悠你:BAAAKgAECggICAAAAA==.',['大醉']='大醉侠:BAAAKgAFFAIIAgAAAA==.',['天堂']='天堂爆竹:BAAAKgAECgYIBgAAAA==.',['天蓝']='天蓝色的星尘:BAAAKgAECgQIAgAAAA==.',['天道']='天道阿修罗:BAAAKgAECgcICAAAAA==.',['奈斩']='奈斩:BAABKgAECn8rAAIUAAgIfxVTHADZAQAUAAgIfxVTHADZAQAAAA==.',['奥术']='奥术大蠊:BAAAKgADCgQIBAAAAA==.',['奶出']='奶出天际丶:BAAAKgAECgQIBAAAAA==.',['如太']='如太阳般火热:BAABKgAFFH8GAAIDAAYITh9cAQD5AQADAAYITh9cAQD5AQAAAA==.如太阳般闪耀:BAAAKgAFFAQIBAAAAA==.',['妨弑']='妨弑代行:BAAAKgAECgMIBAAAAA==.',['妮可']='妮可沃特森:BAAAKgADCggIEwAAAA==.',['孙大']='孙大佩佩:BAABKgAFFH8IAAIYAAgIFwkhDADAAQAYAAgIFwkhDADAAQAAAA==.',['孙小']='孙小佩佩:BAAAKgAECggICAAAAA==.',['孟达']='孟达:BAAAKgADCggICQAAAA==.',['宇文']='宇文婷甄:BAAAKgAECggIDgAAAA==.',['安兹']='安兹乌尔王:BAAAKgAECggICAAAAA==.',['安奇']='安奇揦:BAACKgAFFH9QAAMbAAgIPyY5AAABAwAbAAgIPyY5AAABAwAdAAMIfgyBDQC8AAAqAAQKfyYAAhsACAiNJp8BAPoCABsACAiNJp8BAPoCAAAA.安奇翋:BAAAKgAECgQIBwAAAA==.',['宝山']='宝山乌萨奇:BAAAKgAECgIIAgAAAA==.',['宝贝']='宝贝上:BAAAKgAECgMIAwAAAA==.',['密涅']='密涅娃:BAABKgAFFH8IAAIHAAgIIAgHDwCyAQAHAAgIIAgHDwCyAQAAAA==.',['密码']='密码六个八:BAAAKgAECggICAAAAA==.',['寒春']='寒春的澜珊:BAAAKgAFFAgIBAAAAA==.',['射手']='射手小小琴:BAAAKgAFFAMIAwAAAA==.',['小小']='小小舞深:BAACKgAFFH8OAAIeAAMI7Q+kBwCXAAAeAAMI7Q+kBwCXAAAqAAQKfxkAAh4ACAgaGmEJALcBAB4ACAgaGmEJALcBAAAA.小小龙人:BAAAKgAECgEIAQAAAA==.',['小布']='小布尔乔亚丶:BAABKgAECn8WAAIHAAgIBiO9FAC2AgAHAAgIBiO9FAC2AgAAAA==.',['小狐']='小狐狸齐娜:BAABKgAFFH8MAAMPAAcIyRaACAC/AQAPAAcIyRaACAC/AQAfAAIIIyKIGwBAAAAAAA==.',['小狗']='小狗急了:BAAAKgAFFAMIAwAAAA==.',['小猪']='小猪喵喵宝宝:BAAAKgAECgUIBQAAAA==.',['小肚']='小肚皮:BAACKgAFFH8OAAIWAAYIHguBBQDyAAAWAAYIHguBBQDyAAAqAAQKfysAAxYACAhNGhIOAP4BABYACAhNGhIOAP4BABUAAQiQDzVhAEgAAAAA.',['小舅']='小舅子:BAAAKgAFFAMIAwAAAA==.',['尕崔']='尕崔:BAABKgAFFH8JAAIVAAYIVw4RCQDbAAAVAAYIVw4RCQDbAAAAAA==.',['山下']='山下游仙:BAAAKgAECggICgABKgAFFAgICAADALwWAA==.',['巧克']='巧克力味粑粑:BAAAKgAFFAgIBAAAAA==.',['带着']='带着镣铐跳舞:BAAAKgADCgIIAgAAAA==.',['幸运']='幸运星:BAAAKgAECgQIAgAAAA==.',['康斯']='康斯坦丁:BAABKgAFFH8IAAQQAAgIMh87AgB0AQAQAAUIaiA7AgB0AQAGAAIIGx1kMACtAAAXAAEIhB51HQBXAAAAAA==.',['归来']='归来的梦:BAACKgAFFH8GAAIEAAMIbwb0QQCWAAAEAAMIbwb0QQCWAAAqAAQKfzMAAgQACAhUGuotAPwBAAQACAhUGuotAPwBAAAA.归来的阿荣:BAABKgAECn8XAAMJAAgIWQ43EAATAQAJAAgIWQ43EAATAQARAAMI+QEMIgA/AAAAAA==.',['彦林']='彦林:BAAAKgADCgIIAgAAAA==.',['德财']='德财兼备:BAAAKgADCgMIAwAAAA==.',['我要']='我要我的骄傲:BAAAKgADCggICAAAAA==.',['打擦']='打擦有福利气:BAACKgAFFH8vAAIPAAgIJh4HCQC2AQAPAAgIJh4HCQC2AQAqAAQKfyMAAg8ACAiDIDgRAHACAA8ACAiDIDgRAHACAAAA.',['托尼']='托尼灬斯塔克:BAAAKgAFFAIIAgAAAA==.',['扛把']='扛把子:BAAAKgAFFAIIAgAAAA==.',['抓宝']='抓宝宝:BAABKgAECn8aAAICAAcIjBVRJQBPAQACAAcIjBVRJQBPAQAAAA==.',['拉得']='拉得玩死卡:BAAAKgAECgYIBgAAAA==.',['拉风']='拉风又拉怪:BAABKgAFFH8MAAMcAAQIkBP3DQCSAAADAAQIYQdiHwCYAAAcAAIIohn3DQCSAAAAAA==.拉风小骑士:BAAAKgADCgcIBwAAAA==.',['拥抱']='拥抱圣光:BAACKgAFFH8rAAQTAAcIAiHABAABAgATAAcIAiHABAABAgAFAAMIlhwAEADAAAAOAAMImhR3EAB/AAAqAAQKfzEAAxMACAgeJsECAPcCABMACAgeJsECAPcCAAUABwheIEQYABICAAAA.',['捌零']='捌零柒:BAAAKgADCgEIAgAAAA==.',['捞捞']='捞捞拘:BAABKgAFFH8JAAIbAAUI6A1UFgDxAAAbAAUI6A1UFgDxAAAAAA==.',['提拉']='提拉加德:BAABKgAFFH8KAAIYAAYIeBUzGQBPAQAYAAYIeBUzGQBPAQAAAA==.',['提淘']='提淘兔:BAAAKgADCgEIAQAAAA==.',['提高']='提高实力:BAAAKgAECgQIBAAAAA==.',['故人']='故人叹:BAABKgAFFH8FAAIJAAUIwhjrAwA1AQAJAAUIwhjrAwA1AQAAAA==.',['教练']='教练我想进步:BAAAKgAECgQIBQAAAA==.教练我行吗:BAAAKgAFFAQIAwAAAA==.',['料理']='料理仙姬:BAAAKgADCgcICwAAAA==.',['新海']='新海诚:BAAAKgADCgEIAQAAAA==.',['无心']='无心乖乖:BAAAKgADCggICAAAAA==.',['无悔']='无悔橙心:BAAAKgAFFAIIBAAAAA==.',['无毒']='无毒的糖:BAAAKgAECgYIBgAAAA==.',['星光']='星光永烁:BAAAKgAFFAYIBAAAAA==.',['星梦']='星梦无痕:BAACKgAFFH8JAAIFAAMICg+9FACZAAAFAAMICg+9FACZAAAqAAQKfxwAAwUACAgQFts3ADsBAAUACAgQFts3ADsBAA4AAghXBSGEACUAAAAA.',['星空']='星空咕噜:BAAAKgAECgQIBAAAAA==.星空嘟嘟:BAAAKgADCgYICAAAAA==.星空嘟噜:BAAAKgAECgYIDwAAAA==.',['星辰']='星辰小德:BAAAKgAECgMIAwAAAA==.',['晚上']='晚上吃点啥:BAAAKgAFFAIIAgAAAA==.',['暗夜']='暗夜天心:BAABKgAFFH8GAAIBAAYImAgsHAAOAQABAAYImAgsHAAOAQAAAA==.暗夜天语:BAAAKgAFFAYIBAAAAA==.暗夜无影:BAABKgAECn8YAAMGAAgIvxZAPwAOAQAGAAUImRlAPwAOAQAQAAQIdRTKRADfAAAAAA==.',['曦儿']='曦儿宝贝:BAABKgAFFH8FAAIPAAUIFQefFwC4AAAPAAUIFQefFwC4AAABKgAFFAgIBgAPADwFAA==.',['月之']='月之影影之海:BAABKgAECn8YAAIgAAgIBwsDGQDbAAAgAAgIBwsDGQDbAAAAAA==.月之海:BAACKgAFFH8IAAIKAAMIxwgQCQDCAAAKAAMIxwgQCQDCAAAqAAQKfxQAAgoACAhVFyUnAAwCAAoACAhVFyUnAAwCAAAA.',['月兰']='月兰馨:BAABKgAFFH8IAAIZAAgIPwccBgBtAQAZAAgIPwccBgBtAQAAAA==.',['月梦']='月梦墨瞳:BAACKgAFFH8IAAIEAAQI9xUNEwDtAAAEAAQI9xUNEwDtAAAqAAQKfywAAgQACAhoIawNAJ4CAAQACAhoIawNAJ4CAAAA.',['月牧']='月牧:BAAAKgAECggIDwAAAA==.',['月神']='月神之恋:BAABKgAFFH8JAAIPAAMIzxsQIgDwAAAPAAMIzxsQIgDwAAAAAA==.',['有点']='有点些许慵懒:BAAAKgADCggICAAAAA==.有点些许风霜:BAAAKgAECgIIAgAAAA==.有点儿小鸡冻:BAABKgAECn8UAAMLAAgI0RlKMgCpAQALAAcIpRpKMgCpAQAKAAMIzg7gcQCvAAAAAA==.',['朔月']='朔月之雨:BAAAKgAECgEIAQAAAA==.朔月之风:BAABKgAFFH8GAAMPAAYISxmiGgAVAQAPAAUI2hWiGgAVAQAfAAEIMAYuJwBAAAAAAA==.',['李宗']='李宗七:BAAAKgADCgIIAgAAAA==.',['来去']='来去:BAAAKgAECgUIDQAAAA==.',['林夕']='林夕:BAAAKgAECgMIAwAAAA==.',['林寂']='林寂云:BAAAKgAECgUIBQAAAA==.林寂灭:BAABKgAFFH8IAAIbAAgIwxSsBADqAQAbAAgIwxSsBADqAQAAAA==.',['格瑞']='格瑞司华尔德:BAAAKgAECgQIBAAAAA==.',['桂花']='桂花糊:BAAAKgAECgYIBgAAAA==.桂花糖芋苗:BAAAKgAFFAMIAwAAAA==.',['梦里']='梦里花:BAAAKgADCgMIAwAAAA==.',['梵派']='梵派尔烈酒:BAAAKgAECgEIAQAAAA==.',['樱华']='樱华月:BAABKgAFFH8OAAMFAAYITR3UDQBKAQAFAAUI+hvUDQBKAQATAAEISgLSLwA3AAABKgAFFAgICAAFALsjAA==.',['橙色']='橙色小葡萄:BAABKgAECn8TAAMLAAcIlSM9FQBVAgALAAcIlSM9FQBVAgAKAAEIAAD0VAAAAAAAAA==.',['欧尼']='欧尼坦:BAAAKgAFFAgIBAAAAA==.',['欧贝']='欧贝利斯克:BAACKgAFFH8KAAIUAAQIww9vJgCkAAAUAAQIww9vJgCkAAAqAAQKfxUAAhQACAgaGbogALQBABQACAgaGbogALQBAAAA.',['正义']='正义的小灵:BAAAKgADCgQIBAAAAA==.',['武僧']='武僧:BAABKgAFFH8GAAIbAAYIYAu8FAAAAQAbAAYIYAu8FAAAAQAAAA==.',['死亡']='死亡龙心:BAAAKgAFFAQIBAAAAA==.',['死侍']='死侍小德:BAAAKgAECgYIBgAAAA==.',['残梦']='残梦寒:BAAAKgAECggICAAAAA==.',['毒鬼']='毒鬼:BAABKgAFFH8UAAMVAAgIbRWSCQByAQAVAAYIvhmSCQByAQASAAQIuRHJEABJAQAAAA==.',['水月']='水月天天:BAAAKgADCgUICAAAAA==.',['沃什']='沃什大拉基:BAAAKgAECgIIBAAAAA==.',['没了']='没了尾巴:BAABKgAECn8YAAMPAAgIxCDZEgBkAgAPAAgIxCDZEgBkAgAfAAQI9gLbdwBQAAABKgAFFAgICAABALMfAA==.',['波比']='波比娃娃:BAAAKgAECgYICwAAAA==.',['波西']='波西米亚狂想:BAAAKgADCggICAAAAA==.',['洛冰']='洛冰盈:BAAAKgAECgUIBQAAAA==.',['海水']='海水不岚:BAAAKgADCgEIAQAAAA==.',['海深']='海深时浅:BAAAKgAECgMIAwAAAA==.',['淺倉']='淺倉南:BAAAKgAECgEIAQAAAA==.',['清蒸']='清蒸一口气:BAAAKgAECgEIAQAAAA==.',['清风']='清风慕竹:BAABKgAFFH8HAAIdAAYIVRJMCQBTAQAdAAYIVRJMCQBTAQAAAA==.',['溯游']='溯游:BAABKgAFFH8GAAIHAAYIHSOsCwAOAgAHAAYIHSOsCwAOAgABKgAFFAgIEAAVAIYNAA==.',['漆黑']='漆黑匕首:BAABKgAFFH8GAAIhAAYINRVEBwCdAQAhAAYINRVEBwCdAQAAAA==.',['漫步']='漫步水云间:BAABKgAFFH8KAAIBAAYIDx4DCgC2AQABAAYIDx4DCgC2AQAAAA==.',['潮啊']='潮啊:BAAAKgADCggICAABKgAFFAgICQAHAPAJAA==.',['火爖']='火爖:BAAAKgAFFAQIBAAAAA==.',['灬忆']='灬忆学时:BAAAKgAFFAMIBAAAAA==.',['焚天']='焚天猎殇:BAAAKgAECgEIAQAAAA==.',['熊步']='熊步变变:BAABKgAFFH8KAAIbAAYIpgp3EgAWAQAbAAYIpgp3EgAWAQAAAA==.',['爱上']='爱上一位女孩:BAAAKgAFFAMIBAAAAA==.',['爱布']='爱布拉娜:BAAAKgAFFAgIBAAAAA==.',['爱忽']='爱忽悠:BAAAKgADCgEIAQAAAA==.',['牧飞']='牧飞瑶:BAABKgAFFH8FAAMOAAQIJBapDADwAAAOAAQIJBapDADwAAATAAEIAAAsNQAAAAAAAA==.',['特别']='特别想救你:BAAAKgAECggIDgAAAA==.',['狂猎']='狂猎琳琳:BAAAKgAECgcIBwAAAA==.',['狐狸']='狐狸狐琪:BAAAKgADCggICAAAAA==.',['狗头']='狗头军狮:BAAAKgAFFAYIAgABKgAFFAgIFAADAJwZAA==.',['独孤']='独孤天涯:BAAAKgAECgcICAAAAA==.',['玄隆']='玄隆隆:BAABKgAECn9zAAMiAAgINR5KAwBOAgAiAAgINR5KAwBOAgAUAAcIxQ33FQAgAQAAAA==.',['玛格']='玛格汉小短腿:BAAAKgAECggIAgAAAA==.',['球霸']='球霸天:BAAAKgADCgYICAAAAA==.',['琅戟']='琅戟努斯:BAABKgAFFH8MAAMEAAQIShPEFgDcAAAEAAQIShPEFgDcAAAIAAQIBQZkGgCDAAAAAA==.',['琼思']='琼思梦月:BAAAKgAFFAYIAgAAAA==.',['琼斯']='琼斯梦月:BAAAKgAECgQIBAAAAA==.',['瑟贝']='瑟贝丽:BAABKgAFFH8GAAIBAAYI3RGMFgAxAQABAAYI3RGMFgAxAQAAAA==.',['生命']='生命之王:BAABKgAECn9dAAIHAAgIlhdNIAC6AQAHAAgIlhdNIAC6AQABKgAECggIcwAiADUeAA==.',['疯狂']='疯狂咕噜:BAAAKgAECgcIDgAAAA==.疯狂噜噜:BAAAKgAECgYIBgAAAA==.',['白头']='白头佬:BAAAKgADCgIIAgAAAA==.',['白胡']='白胡子胖虎:BAAAKgADCggICAAAAA==.',['百花']='百花凌风:BAABKgAECn8XAAIEAAYIPhrZPwBzAQAEAAYIPhrZPwBzAQAAAA==.百花哲芷:BAACKgAFFH8fAAMCAAYIyRDeIQDQAAACAAQIRhXeIQDQAAABAAIIDgrmPgB9AAAqAAQKfzYAAgIACAiJHOsoAE8CAAIACAiJHOsoAE8CAAAA.',['真月']='真月之神:BAABKgAECn8VAAMGAAgIpgrlQQAEAQAGAAgIpgrlQQAEAQAQAAIIjwLugQAwAAAAAA==.',['真水']='真水:BAACKgAFFH8XAAMPAAMIuhzpIgDsAAAPAAMIuhzpIgDsAAAfAAEINgBALAAQAAAqAAQKfx4AAg8ACAiGGeYxAL8BAA8ACAiGGeYxAL8BAAAA.',['真的']='真的奶妈:BAAAKgAECgYIAgAAAA==.',['瞬影']='瞬影剑:BAAAKgADCgUIBQAAAA==.',['短途']='短途:BAAAKgADCgIIAgAAAA==.',['破碎']='破碎之心:BAAAKgAECggICAAAAA==.',['祈爱']='祈爱漫无天际:BAACKgAFFH8SAAMRAAYIKhu8BACgAQARAAYIKhu8BACgAQAHAAYIRhOvHwBxAQAqAAQKfxsAAgcACAjQGvBRAMgBAAcACAjQGvBRAMgBAAAA.',['穆勒']='穆勒:BAABKgAFFH8MAAMOAAQIgBIoGQDIAAAOAAMIgBIoGQDIAAATAAQItw6OGQCyAAAAAA==.',['空如']='空如大海:BAAAKgAECggICAAAAA==.',['笑一']='笑一:BAAAKgADCggICAAAAA==.',['箜箜']='箜箜小喃:BAAAKgAECgMIAwAAAA==.',['篠之']='篠之之帚:BAABKgAECn8dAAMZAAgI3w76NgAPAQAZAAgI3w76NgAPAQAYAAYIKQvViQDGAAAAAA==.',['米其']='米其林先生:BAAAKgAECgIIAgAAAA==.',['粉色']='粉色别点:BAABKgAFFH8PAAIEAAMIXxegKgDiAAAEAAMIXxegKgDiAAAAAA==.',['糯米']='糯米团:BAAAKgADCgEIAQAAAA==.',['索科']='索科洛芙:BAAAKgAECggIDAAAAA==.',['红莲']='红莲铠骑:BAAAKgAECggICAABKgAFFAgIJAASAEsgAA==.',['绿火']='绿火葬人间:BAABKgAFFH8OAAQXAAYIyRXfAwASAQAXAAUIyRXfAwASAQAGAAQI5wyPFgDJAAAQAAEIAADaIQAAAAAAAA==.',['缇娜']='缇娜里:BAABKgAFFH8GAAIPAAYIJguxFQAtAQAPAAYIJguxFQAtAQAAAA==.',['美女']='美女祭司:BAAAKgAECgYIDQAAAA==.',['美月']='美月熏:BAAAKgADCggICAAAAA==.',['羽蛇']='羽蛇神:BAABKgAECn8aAAIPAAgInBYiKwDQAQAPAAgInBYiKwDQAQAAAA==.',['肖肖']='肖肖兮:BAAAKgAECgMIAwAAAA==.',['肥肥']='肥肥师兄:BAABKgAECn8XAAIbAAgIDhEuJgBeAQAbAAgIDhEuJgBeAQAAAA==.',['肥賊']='肥賊:BAAAKgAECgcICwAAAA==.',['胖达']='胖达饿了:BAABKgAFFH8DAAMdAAMITQ4mHwBxAAAdAAIIIQomHwBxAAAbAAEIsAN7NAAuAAAAAA==.',['胡同']='胡同里有只猫:BAABKgAFFH8GAAIKAAYIUw36EQAxAQAKAAYIUw36EQAxAQAAAA==.',['胡图']='胡图图丨图腾:BAAAKgAECgQIBAAAAA==.',['脉冲']='脉冲米其林:BAAAKgAFFAQIBAABKgAFFAgIDQAHAJEVAA==.',['腐草']='腐草为萤丶:BAACKgAFFH8YAAMCAAQINhcMHADlAAACAAQINhcMHADlAAAjAAEITgrHAwBWAAAqAAQKfyUAAwIACAg0HJA8AAUCAAIACAg0HJA8AAUCACMABAinD1kYAHMAAAAA.',['自然']='自然:BAAAKgADCgMIAwAAAA==.',['艾丽']='艾丽夏:BAAAKgADCgMIBQAAAA==.艾丽娅:BAAAKgAECgcIBwAAAA==.',['艾熙']='艾熙:BAABKgAFFH8WAAICAAQIhSXDFwA8AQACAAQIhSXDFwA8AQAAAA==.',['艾米']='艾米:BAABKgAFFH8KAAQOAAYIOBakAQDBAQAOAAYI+BWkAQDBAQATAAMIKQl6HQB+AAAFAAEIeSHLHwBcAAABKgAFFAgIEwAFAP0gAA==.',['艾迦']='艾迦社明真:BAAAKgADCggICQAAAA==.',['艾露']='艾露蒽:BAAAKgAECgUIBQAAAA==.',['花中']='花中偏爱菊:BAABKgAFFH8IAAIEAAQIyBpEEADxAAAEAAQIyBpEEADxAAAAAA==.',['花開']='花開無由醉:BAAAKgAECgEIAQAAAA==.',['草莓']='草莓蛋糕:BAACKgAFFH8QAAQfAAQIdxvoEgDSAAAfAAQI/xnoEgDSAAANAAQIpwxyFACyAAAPAAQI2w2rNQCnAAAqAAQKfyMAAw8ACAgPHcElAPgBAA8ACAgPHcElAPgBAB8ACAjvFVkxAH8BAAAA.',['荔枝']='荔枝桂圆:BAAAKgAECgYIEAAAAA==.',['莔丁']='莔丁乙:BAAAKgAFFAYIBAAAAA==.',['萨格']='萨格顶顶:BAABKgAFFH8QAAMPAAMIMxZ8IQCSAAAPAAMIMxZ8IQCSAAANAAEIdAGdGwA0AAAAAA==.',['萨满']='萨满大王:BAAAKgAFFAYIBAAAAA==.',['萨萨']='萨萨撒:BAAAKgADCgMIAwAAAA==.',['葉雨']='葉雨阑珊:BAAAKgAFFAIIAgAAAA==.',['蓝宝']='蓝宝石:BAABKgAFFH8IAAMKAAYILRXDBQCoAQAKAAYIQhHDBQCoAQAMAAIINR5GBwBRAAAAAA==.',['虚拟']='虚拟原子小狗:BAAAKgADCgQIBAAAAA==.',['补天']='补天石:BAAAKgAECgIIAgAAAA==.',['西瓜']='西瓜炒肉:BAAAKgADCgMIAwAAAA==.',['请把']='请把我放盐里:BAABKgAFFH8HAAMQAAcIFw9BDgDGAAAGAAMI1goHKADPAAAQAAQIVxNBDgDGAAAAAA==.',['谦卑']='谦卑的糖门滚:BAAAKgADCgIIAwAAAA==.',['贝吉']='贝吉达:BAAAKgADCgIIAgAAAA==.',['贤者']='贤者八云紫:BAAAKgAECggIEQAAAA==.',['费边']='费边:BAAAKgAECggICAAAAA==.',['超人']='超人哑哑:BAAAKgADCgEIAQAAAA==.',['轨迹']='轨迹丨:BAABKgAECn8YAAISAAgIAiHyGAALAgASAAgIAiHyGAALAgABKgAFFAgIEwAPANATAA==.',['辛弗']='辛弗尼尔:BAABKgAECn8VAAMTAAgIOAkMOAAqAQATAAgIOAkMOAAqAQAOAAQIuANggABTAAAAAA==.',['还来']='还来就菊花:BAABKgAFFH8GAAIhAAYI8RKWDQB1AQAhAAYI8RKWDQB1AQAAAA==.',['迟钝']='迟钝咕咕:BAABKgAFFH8GAAIYAAIIVQ5bKQCPAAAYAAIIVQ5bKQCPAAAAAA==.',['邪巫']='邪巫:BAAAKgAECggICAAAAA==.',['邪灵']='邪灵猎手:BAAAKgAFFAIIAgAAAA==.',['郎情']='郎情妾意:BAAAKgAECggICAAAAA==.',['重山']='重山:BAAAKgAECggIDAAAAA==.',['重燃']='重燃灰烬:BAAAKgAECgIIAgAAAA==.',['量子']='量子隧穿:BAACKgAFFH8oAAMUAAUI/RpXCwDzAAAUAAUI/RpXCwDzAAAiAAEISgAzDQAWAAAqAAQKfyQAAxQACAiZH98QAEYCABQACAiZH98QAEYCACIAAgj/C4ojAFkAAAAA.',['钢铁']='钢铁光缚者:BAABKgAFFH8QAAMHAAYIiyEjEQDVAQAHAAYIiyEjEQDVAQARAAMIfB4dEQC5AAAAAA==.',['铁血']='铁血猎鹰:BAAAKgADCgYIBwAAAA==.',['锦衣']='锦衣夜逃:BAAAKgADCggICAAAAA==.',['镜流']='镜流:BAAAKgAECgMIAwAAAA==.',['闷不']='闷不了就跑:BAAAKgAECgYIBgAAAA==.',['闹闹']='闹闹别闹:BAAAKgADCggICAAAAA==.',['阿什']='阿什米达:BAAAKgAECgQIBgAAAA==.',['阿妹']='阿妹你看上帝:BAAAKgAECgIIAgAAAA==.',['阿尔']='阿尔娜斯:BAAAKgAFFAQIBAAAAA==.',['阿睿']='阿睿:BAAAKgADCgEIAQAAAA==.',['阿紫']='阿紫:BAAAKgAECgYIBgAAAA==.',['阿维']='阿维娜丶绒爪:BAAAKgADCgEIAQAAAA==.',['阿诺']='阿诺德:BAABKgAFFH8GAAMBAAMIrgKzIgBeAAABAAMIrQKzIgBeAAACAAEIDgOvMQAuAAAAAA==.',['隔壁']='隔壁老必:BAABKgAFFH8MAAQOAAgIhhEGBwC7AQAOAAcIVg0GBwC7AQAFAAQIIxtTJACyAAATAAEIMhK1KwBEAAAAAA==.',['雨下']='雨下一整晚:BAABKgAFFH8KAAMcAAgI6Q47CQASAQAcAAYInxA7CQASAQADAAQIOwkYPwCCAAAAAA==.',['雨后']='雨后百合:BAABKgAFFH8RAAIcAAMIDxrFBADyAAAcAAMIDxrFBADyAAAAAA==.',['雨山']='雨山佑:BAAAKgAECgMIAwAAAA==.',['雨霖']='雨霖铃:BAAAKgAECgQIBgAAAA==.',['雪冰']='雪冰儿:BAAAKgAFFAMIAwAAAA==.',['雪炎']='雪炎冰:BAAAKgADCggICAAAAA==.',['雷暴']='雷暴:BAAAKgAFFAQIBAAAAA==.',['霜华']='霜华青丘行:BAAAKgAECgUIBQAAAA==.',['霜满']='霜满天丶:BAAAKgAECgUIBgAAAA==.',['面包']='面包嘟嘟:BAAAKgAECggIEQAAAA==.',['革洛']='革洛肯丶:BAAAKgAECgcICwAAAA==.',['韩非']='韩非子:BAAAKgAFFAYIBAABKgAFFAgICAABALMfAA==.',['风尘']='风尘蝶恋:BAAAKgADCgEIAQAAAA==.',['风萨']='风萨:BAABKgAECn8cAAQPAAgI5RWPSwBMAQAPAAgI5RWPSwBMAQAfAAQIJRMAIgCzAAANAAYI5wYWGgBqAAAAAA==.',['风辰']='风辰:BAAAKgAFFAgIAgAAAA==.',['风零']='风零语:BAAAKgADCgEIAQAAAA==.',['飞羽']='飞羽归尘:BAAAKgAFFAgIAQAAAA==.',['骑马']='骑马天涯:BAAAKgAECgUIBQAAAA==.',['高高']='高高瘦瘦:BAAAKgADCggICAAAAA==.',['魔法']='魔法厨师:BAAAKgAECgcIDQAAAA==.',['鲜血']='鲜血扛把子:BAAAKgAFFAYIAgAAAA==.',['鲨鱼']='鲨鱼王:BAAAKgAFFAIIBAAAAA==.',['鲨鳗']='鲨鳗:BAAAKgADCggICAAAAA==.',['麦戈']='麦戈文:BAABKgAFFH8IAAIJAAgIWxQuBQCxAQAJAAgIWxQuBQCxAQAAAA==.',['麻吉']='麻吉阿巴:BAAAKgADCgIIAgAAAA==.',['黄昏']='黄昏之龙:BAAAKgAECggICAAAAA==.',['黑天']='黑天鹅:BAAAKgAECgYICAAAAA==.',['黑暗']='黑暗咆哮:BAAAKgAECgQIBAAAAA==.',['黑神']='黑神话马喽:BAABKgAFFH8MAAIdAAYIsxE0CQBVAQAdAAYIsxE0CQBVAQAAAA==.',['黑色']='黑色闪电:BAAAKgAECggIDAAAAA==.',['龙翱']='龙翱天:BAAAKgADCggIEAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end