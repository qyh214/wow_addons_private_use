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
 local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','Evoker-Preservation','Mage-Arcane','Mage-Frost','Warlock-Demonology','Warlock-Destruction','Warrior-Fury','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Affliction','Paladin-Retribution','Monk-Brewmaster','Druid-Restoration','Shaman-Restoration','Monk-Mistweaver','Rogue-Assassination','Priest-Discipline','Priest-Holy','Priest-Shadow','DeathKnight-Blood','Evoker-Augmentation','DemonHunter-Havoc','Rogue-Subtlety','Paladin-Holy','Evoker-Devastation','Monk-Windwalker','Druid-Feral','Shaman-Elemental','DemonHunter-Vengeance','Warrior-Protection','Druid-Balance',}; local provider = {region='CN',realm='托塞德林',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Ain:BAAALAAECgYIBgAAAA==.',Be='Ber:BAABLAAFFH8PAAMBAAYIPyGXPABIAQABAAUIUyCXPABIAQACAAEI1iWdDgBbAAABLAAFFAgICQABAMwjAA==.Berb:BAABLAAFFH8TAAIBAAYIlRmyKACTAQABAAYIlRmyKACTAQAAAA==.Berc:BAABLAAFFH8QAAMBAAYINREnRQAmAQABAAUIrBInRQAmAQACAAEI5gmuEQBPAAAAAA==.',Ca='Caomeiklb:BAABLAAFFH8RAAIDAAYIrhkOCgC3AQADAAYIrhkOCgC3AQABLAAFFAcIGAADAGAZAA==.',Da='Damage:BAAALAAECgIIAgAAAA==.',El='Ellie:BAAALAAECgYIDAAAAA==.',Ex='Exwind:BAAALAAFFAYIAgABLAAFFAcIGAADAGAZAA==.',Ez='Ez:BAABLAAFFH8eAAIBAAYI8iI2FADvAQABAAYI8iI2FADvAQAAAA==.',Fa='Faithnes:BAABLAAFFH8KAAMEAAIIwBRRQQCeAAAEAAIIwBRRQQCeAAAFAAIIRQxBFgCAAAAAAA==.',Fr='Frieren:BAABLAAFFH8NAAMEAAMIrxw0RQCNAAAEAAMIuho0RQCNAAAFAAEIpyOtGwBgAAAAAA==.',Ho='Horacio:BAACLAAFFH8MAAMGAAIIFRR1GgCNAAAGAAIIexF1GgCNAAAHAAEIhwvyYAA+AAAsAAQKfyIAAwcACAjKGP4YABcCAAcACAjKGP4YABcCAAYABgi/EOA8AHkBAAAA.',Je='Jessiezhang:BAAALAAFFAYIAgAAAA==.',Ji='Jijjo:BAAALAAECgYIDAAAAA==.',Jo='Jojij:BAAALAAECgMIAwAAAA==.',Ki='Kirito:BAABLAAFFH8FAAIIAAUIzwt0EAB7AQAIAAUIzwt0EAB7AQABLAAFFAgIOAAIAHgjAA==.',Ku='Kumo:BAAALAAFFAgIAgAAAA==.',Lj='Ljnn:BAABLAAFFH8GAAIJAAYIsBCrQABEAQAJAAYIsBCrQABEAQAAAA==.',Lr='Lr:BAABLAAFFH8KAAMJAAYIZyBzAwBRAgAJAAYIZyBzAwBRAgAKAAEIBhJJMgBRAAAAAA==.',Lu='Luv:BAABLAAFFH8NAAIHAAgIcxkUCwBPAgAHAAgIcxkUCwBPAgAAAA==.',Ly='Lytehz:BAAALAADCgcICQAAAA==.',Ma='Marimo:BAACLAAFFH8HAAIHAAIIYxyiQQCWAAAHAAIIYxyiQQCWAAAsAAQKfxsAAwcACAgiGTRGACMCAAcACAgRFjRGACMCAAsABQirFZgKANcAAAAA.Marrier:BAAALAAECgYICQAAAA==.',Me='Mengjhin:BAAALAAFFAQIBAAAAA==.',Mo='Moon:BAAALAADCgYICgAAAA==.',Na='Naowh:BAAALAAFFAIIAgAAAA==.',Re='Rembrandt:BAAALAAECgEIAQAAAA==.',Sk='Skyfall:BAAALAADCgUIBQAAAA==.',Su='Superbimango:BAABLAAFFH8PAAIEAAMIbhifPACjAAAEAAMIbhifPACjAAAAAA==.',Ti='Tikktwa:BAABLAAFFH8bAAIIAAYIrA9bHQB+AQAIAAYIrA9bHQB+AQAAAA==.',Uz='Uzi:BAAALAADCgEIAQAAAA==.',Vo='Voldemortlol:BAAALAAECggICAAAAA==.',Wa='Waanbb:BAABLAAFFH8IAAMBAAYI7wzNRQAjAQABAAUIwA7NRQAjAQACAAEI2AOIEwBKAAAAAA==.Wabtxzgj:BAABLAAFFH8VAAMBAAYIxBPCQQA0AQABAAUIDhXCQQA0AQACAAEIVA0xEQBQAAAAAA==.Wanb:BAABLAAFFH8MAAIMAAYIJxI1HwBtAQAMAAYIJxI1HwBtAQAAAA==.Wanbb:BAABLAAFFH8UAAMBAAYIjRd2PwA9AQABAAUIaxl2PwA9AQACAAEIOQ6GEQBPAAAAAA==.',Xm='Xmaolra:BAABLAAFFH8GAAIJAAYICxNfQABFAQAJAAYICxNfQABFAQAAAA==.Xmaolrb:BAABLAAFFH8HAAIJAAQIWhSeLADPAAAJAAQIWhSeLADPAAAAAA==.Xmaolrc:BAABLAAFFH8GAAIJAAYIPBLFDQDFAQAJAAYIPBLFDQDFAQAAAA==.Xmaolrd:BAABLAAFFH8GAAIJAAYI5BoxKACSAQAJAAYI5BoxKACSAQAAAA==.Xmaolre:BAABLAAFFH8YAAIJAAgI5BxlCwAxAgAJAAgI5BxlCwAxAgAAAA==.Xmaolrf:BAABLAAFFH8GAAIJAAYIDxeYNQBmAQAJAAYIDxeYNQBmAQAAAA==.Xmaolrg:BAABLAAFFH8SAAIJAAYInxbgNQBlAQAJAAYInxbgNQBlAQAAAA==.Xmaolrh:BAABLAAFFH8UAAIJAAgIbBpPCQBMAgAJAAgIbBpPCQBMAgAAAA==.Xmaolri:BAABLAAFFH8GAAIJAAYICxH0PQBNAQAJAAYICxH0PQBNAQAAAA==.Xmaolrj:BAABLAAFFH8UAAIJAAYI/RoULwB7AQAJAAYI/RoULwB7AQAAAA==.',Xz='Xzone:BAABLAAFFH8RAAMBAAYIOBduQgAxAQABAAUIFBhuQgAxAQACAAEI6xLKEABRAAAAAA==.Xzxz:BAABLAAFFH8IAAMBAAYI8w9oRQAlAQABAAUIeBBoRQAlAQACAAEIXg3YEABRAAAAAA==.Xzz:BAABLAAFFH8JAAIIAAYIuwjKIwBQAQAIAAYIuwjKIwBQAQAAAA==.Xzzb:BAABLAAFFH8IAAMBAAYIuQyVSAAWAQABAAUITg2VSAAWAQACAAEI0QmXEQBPAAAAAA==.',['一只']='一只鹿盔:BAAALAAFFAIIBAAAAA==.',['一瞬']='一瞬千躺:BAAALAAFFAQIBAAAAA==.',['一纸']='一纸白衣丶:BAAALAAECgYIBgAAAA==.',['一面']='一面:BAAALAAFFAIIBAAAAA==.',['万能']='万能小酱油:BAABLAAFFH8KAAINAAYICRAfEQA5AQANAAYICRAfEQA5AQAAAA==.',['上午']='上午睡觉:BAABLAAFFH8bAAIOAAgIUBiHBABwAgAOAAgIUBiHBABwAgAAAA==.',['下次']='下次还敢:BAAALAAECgYIBgAAAA==.',['不关']='不关小段的事:BAABLAAFFH8FAAIJAAMIbRi0OQCwAAAJAAMIbRi0OQCwAAAAAA==.',['不可']='不可言喻真相:BAAALAAECgYIBgAAAA==.',['不学']='不学无术:BAABLAAFFH8GAAIHAAIIjw7IYQA9AAAHAAIIjw7IYQA9AAAAAA==.',['不敗']='不敗之魂:BAABLAAFFH8KAAIPAAII7yDaIwDAAAAPAAII7yDaIwDAAAAAAA==.',['不白']='不白猫:BAAALAAFFAIIAgAAAA==.',['不落']='不落都市飞舞:BAABLAAFFH8IAAIGAAIILwYtHACHAAAGAAIILwYtHACHAAAAAA==.',['不辣']='不辣:BAAALAAFFAIIAgAAAA==.',['世界']='世界悲:BAABLAAFFH8NAAIQAAcIVh8PAgCKAgAQAAcIVh8PAgCKAgABLAAFFAgIYAADALcjAA==.',['丨细']='丨细嗅蔷薇丨:BAAALAAECgYIBgAAAA==.',['丶云']='丶云迹:BAABLAAFFH8UAAIRAAgIbyYQAAAsAwARAAgIbyYQAAAsAwABLAAFFAgIKQARADUmAA==.',['丶埃']='丶埃琳娜:BAABLAAFFH8YAAIRAAgI8yUgAAAhAwARAAgI8yUgAAAhAwABLAAFFAgIKQARADUmAA==.',['丶提']='丶提丰:BAABLAAFFH8eAAIRAAgI3SUpAAAcAwARAAgI3SUpAAAcAwABLAAFFAgIKQARADUmAA==.',['丶明']='丶明椒:BAABLAAFFH8gAAIRAAgI1yYDAAA4AwARAAgI1yYDAAA4AwABLAAFFAgIKQARADUmAA==.',['丶柳']='丶柳德米拉:BAABLAAFFH8XAAIRAAgIbyYOAAAtAwARAAgIbyYOAAAtAwABLAAFFAgIKQARADUmAA==.',['丶棘']='丶棘刺:BAABLAAFFH8VAAIRAAgIPyYhAAAgAwARAAgIPyYhAAAgAwABLAAFFAgIKQARADUmAA==.',['丶海']='丶海霓:BAABLAAFFH8GAAIRAAII9iQ/EgDcAAARAAII9iQ/EgDcAAABLAAFFAgIKQARADUmAA==.',['丶科']='丶科谢尼娅:BAABLAAFFH8eAAIRAAgIdyZRAAADAwARAAgIdyZRAAADAwABLAAFFAgIKQARADUmAA==.',['丶空']='丶空弦:BAABLAAFFH8KAAIRAAgI+SSpAQCYAgARAAgI+SSpAQCYAgABLAAFFAgIKQARADUmAA==.',['为了']='为了诺克萨斯:BAAALAAFFAQIBAAAAA==.',['乂斷']='乂斷乂卝怒麸:BAAALAAECgQIBAAAAA==.乂斷乂卝熊猫:BAAALAAECgYIBgAAAA==.',['乘风']='乘风:BAAALAADCgQIBAAAAA==.',['云程']='云程之战:BAAALAAECgYIBgAAAA==.',['伊泽']='伊泽瑞尔丶:BAABLAAFFH8QAAIBAAYIsRuTIwCmAQABAAYIsRuTIwCmAQAAAA==.',['佚风']='佚风行:BAAALAADCgMIAwAAAA==.',['你浮']='你浮夸丶:BAAALAAECggICAAAAA==.',['你真']='你真难看:BAAALAAECgYIDAAAAA==.',['俺叫']='俺叫熊大:BAABLAAFFH8FAAIJAAIIMhnMXQCNAAAJAAIIMhnMXQCNAAAAAA==.',['先驱']='先驱萨拉塔斯:BAAALAAECggIBQAAAA==.',['光星']='光星:BAAALAAECgUIBgAAAA==.',['兜壮']='兜壮壮:BAABLAAECn8UAAQSAAYIoA1KEwCtAAATAAYI5ghkQwDQAAASAAMI7BFKEwCtAAAUAAEIlwUSUQAdAAAAAA==.',['八苦']='八苦:BAAALAAFFAQIBAABLAAFFAgIYAADALcjAA==.',['六子']='六子爸:BAAALAADCgYIBgAAAA==.',['冰棒']='冰棒:BAACLAAFFH8kAAMJAAgIrho/CQD1AQAJAAgIrho/CQD1AQAKAAMISgj1GgCeAAAsAAQKfysAAwkACAjyIhAiANACAAkACAg1IhAiANACAAoACAixH58fAGkCAAAA.',['凯恩']='凯恩血蹄尔:BAABLAAECn8hAAMBAAgIlSHFEQBbAgABAAgIlSHFEQBbAgAVAAgIvw6sIACEAQAAAA==.',['刃舞']='刃舞:BAAALAAECgYIBgAAAA==.',['别封']='别封我:BAABLAAFFH8GAAMDAAYIdQp4EQALAQADAAUIBwt4EQALAQAWAAEIegieDwBBAAAAAA==.',['劉海']='劉海柱:BAAALAAFFAIIAgAAAA==.',['匡匡']='匡匡:BAAALAAFFAYIAwAAAA==.',['十六']='十六耶:BAABLAAFFH8UAAIXAAYI3xveGQChAQAXAAYI3xveGQChAQABLAAFFAgICQABAMwjAA==.',['千秋']='千秋雪:BAAALAAECgYIBgAAAA==.',['半根']='半根烟闯江湖:BAAALAADCgIIAgAAAA==.',['卿本']='卿本佳人:BAAALAAFFAcIAwAAAA==.',['双魚']='双魚理:BAABLAAFFH8fAAIEAAgIliJdAwDAAgAEAAgIliJdAwDAAgAAAA==.',['古尓']='古尓丹:BAABLAAFFH8KAAIHAAYItwcdOAAsAQAHAAYItwcdOAAsAQAAAA==.',['只争']='只争朝夕:BAAALAADCgQIBAAAAA==.',['叫兽']='叫兽玩死骑:BAAALAAECgYIBwAAAA==.',['台风']='台风交个消失:BAABLAAFFH8pAAMRAAgINSYNAAAtAwARAAgIFSYNAAAtAwAYAAEImSGUGQAAAAAAAA==.',['听见']='听见你说:BAABLAAFFH8QAAMBAAYIMBZNLACHAQABAAYIMBZNLACHAQACAAEIlQRVEwBKAAAAAA==.',['吾之']='吾之道:BAAALAAECgIIAQAAAA==.',['周角']='周角:BAAALAAECgQIBAAAAA==.',['喷火']='喷火梦嫣怪:BAAALAADCgYIBgAAAA==.',['嗜血']='嗜血无名:BAAALAAECgMIAwAAAA==.',['嘿灬']='嘿灬小鲜肉:BAAALAAECgYICQAAAA==.',['囡囝']='囡囝囚团:BAABLAAFFH8VAAIOAAgIgBpoBABzAgAOAAgIgBpoBABzAgAAAA==.',['土霸']='土霸王:BAAALAAFFAIIAgAAAA==.',['圣羽']='圣羽夜:BAAALAAECgYIDwAAAA==.',['复仇']='复仇之矛:BAABLAAFFH8NAAIBAAcIihb4GADVAQABAAcIihb4GADVAQAAAA==.',['夏咩']='夏咩咩:BAAALAAECgYIBgAAAA==.',['夏慕']='夏慕槿苏丶:BAACLAAFFH8MAAIHAAII6xt6NgCkAAAHAAII6xt6NgCkAAAsAAQKfxgAAgcABghiIP8oALIBAAcABghiIP8oALIBAAAA.',['外战']='外战看滔搏:BAABLAAFFH8KAAIXAAYImBHNHgCHAQAXAAYImBHNHgCHAQAAAA==.',['多椒']='多椒芋头:BAAALAAECgQIBAAAAA==.',['大嚿']='大嚿衰:BAAALAADCgQIBAAAAA==.',['大弄']='大弄一几:BAAALAAECggICAAAAA==.',['大爷']='大爷逍遥游:BAAALAAECgUIBQAAAA==.',['天之']='天之川沙夜:BAABLAAFFH8QAAITAAYIZSHKEADXAQATAAYIZSHKEADXAQABLAAFFAgIMwAZANQmAA==.',['天气']='天气预报:BAACLAAFFH8gAAMTAAYIKSPVAwAqAgATAAYIKSPVAwAqAgAUAAUI2AjgGADwAAAsAAQKfxUAAxMACAgTHcQlAFcCABMACAgTHcQlAFcCABQABgj0HOs0APEBAAEsAAUUCAhgAAMAtyMA.',['天蝎']='天蝎小萨:BAABLAAECn8ZAAIPAAgIaSBMFwDBAgAPAAgIaSBMFwDBAgAAAA==.',['奔放']='奔放的肉肉:BAAALAAECgIIAgAAAA==.',['妙公']='妙公子:BAAALAAECgEIAQAAAA==.',['威尔']='威尔斯丨铁蹄:BAAALAAECgUIBQAAAA==.',['子龙']='子龙:BAAALAAECgYIEgAAAA==.',['寒冰']='寒冰箭砸死你:BAAALAADCgIIAgAAAA==.',['寒少']='寒少充电宝:BAAALAAFFAIIBAAAAA==.',['小六']='小六:BAAALAADCgIIAgAAAA==.小六六:BAAALAADCgUIBQAAAA==.',['小小']='小小劣人:BAAALAAECgQIBAAAAA==.小小妖:BAAALAAECgMIAwAAAA==.',['小扇']='小扇扑流萤:BAABLAAFFH8OAAIJAAYIjAiNVgDzAAAJAAYIjAiNVgDzAAAAAA==.',['小熊']='小熊:BAAALAAECgYIBgAAAA==.',['小狐']='小狐狸米纱:BAAALAAECgYIEQAAAA==.',['小箭']='小箭箭射死你:BAAALAADCgQIBAAAAA==.',['小红']='小红手灬:BAAALAAECggICAAAAA==.小红手王哥:BAAALAAFFAIIAgAAAA==.',['尔等']='尔等必软:BAACLAAFFH8zAAIUAAcINxv0BQADAgAUAAcINxv0BQADAgAsAAQKfysAAhQACAjjHy4RAOgCABQACAjjHy4RAOgCAAAA.',['尤缇']='尤缇安娜:BAABLAAFFH8IAAITAAYIjA3AGwBwAQATAAYIjA3AGwBwAQABLAAFFAcIGAADAGAZAA==.',['屠尽']='屠尽日寇:BAABLAAFFH8YAAINAAgIOBDLBgDnAQANAAgIOBDLBgDnAQAAAA==.',['山村']='山村拓哉:BAAALAAECggICAAAAA==.',['布莱']='布莱克六百:BAAALAAFFAIIBAAAAA==.',['希瓦']='希瓦:BAABLAAFFH8IAAIJAAIIxRdNQgCiAAAJAAIIxRdNQgCiAAAAAA==.',['希腊']='希腊神话:BAABLAAFFH8GAAIOAAYIsxCrGQBgAQAOAAYIsxCrGQBgAQAAAA==.',['帝皮']='帝皮哎斯:BAAALAAECgYIBwAAAA==.',['年过']='年过古稀:BAABLAAFFH8UAAIOAAgIDxZ/BwA1AgAOAAgIDxZ/BwA1AgAAAA==.',['年酱']='年酱丶:BAAALAADCgUIBQAAAA==.',['开除']='开除人籍:BAABLAAFFH8NAAIHAAYI1gaYOAAqAQAHAAYI1gaYOAAqAQAAAA==.开除人籍丶:BAABLAAFFH8bAAMBAAYIzRzuNABoAQABAAUIUh7uNABoAQACAAEINBVhDwBXAAABLAAFFAgICQABAMwjAA==.',['弦千']='弦千钧:BAACLAAFFH8MAAIJAAIIDCKnPQCqAAAJAAIIDCKnPQCqAAAsAAQKfxQAAgkACAggIqgcAOgCAAkACAggIqgcAOgCAAAA.',['彩虹']='彩虹泡泡:BAAALAAFFAMIBAAAAA==.',['影恸']='影恸:BAABLAAFFH8GAAIBAAYIhgvCPQBEAQABAAYIhgvCPQBEAQAAAA==.',['待敌']='待敌:BAACLAAFFH82AAIZAAcIPhZvCQDwAQAZAAcIPhZvCQDwAQAsAAQKfyoAAhkACAjMGwcRAIsCABkACAjMGwcRAIsCAAAA.',['心力']='心力克:BAAALAAFFAIIAgAAAA==.',['忘忧']='忘忧藏舟:BAABLAAFFH8GAAIOAAYIbRQcFwB6AQAOAAYIbRQcFwB6AQAAAA==.',['怎么']='怎么说:BAAALAAECgIIAgAAAA==.',['怕是']='怕是起飞咯丶:BAAALAAECgYIBgAAAA==.',['恩赐']='恩赐解脫:BAAALAAECgcIBwAAAA==.',['慕羽']='慕羽晴:BAAALAAECgUIBgAAAA==.',['我压']='我压迫众生:BAAALAAFFAMIBAAAAA==.',['我叫']='我叫你龙马:BAABLAAFFH8KAAIMAAMIrxerPQCcAAAMAAMIrxerPQCcAAAAAA==.',['我在']='我在水里游:BAABLAAECn8WAAIJAAgIuBQEjwDGAQAJAAgIuBQEjwDGAQAAAA==.',['我来']='我来找妳:BAABLAAFFH8GAAIBAAYIrxM1LwB+AQABAAYIrxM1LwB+AQAAAA==.',['战一']='战一一丶:BAAALAAECgYIBgAAAA==.',['战殇']='战殇:BAAALAAECgYICQAAAA==.',['扎小']='扎小辫小蹄子:BAAALAAFFAIIAgAAAA==.',['拉布']='拉布布:BAAALAAFFAYIBAAAAA==.',['拽拽']='拽拽超比芒:BAABLAAFFH8HAAIBAAIIYhKbdACOAAABAAIIYhKbdACOAAAAAA==.',['接着']='接着奏乐:BAAALAAECggIBwAAAA==.',['敖丙']='敖丙:BAACLAAFFH9gAAQDAAgItyOcAACyAgADAAgItyOcAACyAgAaAAYI0BpNBwC5AQAWAAQI9BfRCQDbAAAsAAQKfykABAMACAi2JkoAAIIDAAMACAi2JkoAAIIDABYABggfHC4JAOgBABoAAgj6DTJdAHUAAAAA.',['无与']='无与偷比:BAAALAAECgYICwAAAA==.',['无名']='无名小德:BAAALAAECgYICwAAAA==.',['无形']='无形的正义:BAABLAAECn8YAAITAAUIOQrMTQCeAAATAAUIOQrMTQCeAAAAAA==.',['无畏']='无畏领主:BAAALAAECggICAAAAA==.',['早生']='早生华发:BAABLAAFFH8MAAIMAAUIvBAkLAAiAQAMAAUIvBAkLAAiAQAAAA==.',['星熊']='星熊:BAABLAAFFH8HAAIJAAMIigdCdgByAAAJAAMIigdCdgByAAAAAA==.',['星野']='星野:BAACLAAFFH8zAAIZAAgI1CZXAABSAwAZAAgI1CZXAABSAwAsAAQKfzYAAhkACAimJRoCAEoDABkACAimJRoCAEoDAAAA.',['晴光']='晴光映雪:BAABLAAFFH8HAAITAAIISwrXOQCBAAATAAIISwrXOQCBAAAAAA==.',['暮云']='暮云深影:BAAALAAFFAYIAgAAAA==.',['最后']='最后的凯哥:BAAALAADCgcICwAAAA==.最后的梦魇:BAAALAAECgYIBgAAAA==.',['有梦']='有梦想的咸鱼:BAAALAAECgYIEgAAAA==.',['末希']='末希:BAAALAAFFAIIAgAAAA==.',['李老']='李老酒:BAACLAAFFH83AAMbAAcIHiF0BADCAQAbAAUIXiJ0BADCAQANAAUImB1dCwD8AAAsAAQKfysAAxsACAg6JNEPAKsCABsACAgtH9EPAKsCAA0ACAjGIv8IAM8BAAAA.',['松花']='松花江上:BAABLAAFFH8FAAIOAAQIiQ2MJQDtAAAOAAQIiQ2MJQDtAAAAAA==.',['枕头']='枕头:BAACLAAFFH8OAAIFAAIIshdrEwCHAAAFAAIIshdrEwCHAAAsAAQKfz4AAgUACAjOIJIKAPACAAUACAjOIJIKAPACAAAA.',['果汁']='果汁分她一半:BAAALAADCgIIAgAAAA==.',['梦烬']='梦烬:BAABLAAFFH8RAAMHAAUIshs2EwDGAQAHAAUISBo2EwDGAQAGAAEIyCY3HwBxAAAAAA==.',['梦醒']='梦醒晚秋:BAAALAAECggICAAAAA==.',['森失']='森失海屿:BAAALAAECgYIBgAAAA==.',['椰蓉']='椰蓉巧心脆:BAABLAAFFH8LAAIOAAYIxBS9FQCIAQAOAAYIxBS9FQCIAQABLAAFFAcIGAADAGAZAA==.',['横刀']='横刀立马:BAAALAADCggICAAAAA==.',['欺诈']='欺诈者狂徒:BAAALAADCggICAAAAA==.',['殇之']='殇之逝:BAAALAAECgcIDQAAAA==.',['殢无']='殢无伤:BAABLAAFFH8FAAMBAAIIqQ1IkwA9AAACAAEIuAfxFABFAAABAAIIqQ1IkwA9AAABLAAFFAgIVwAZACMmAA==.',['水蓝']='水蓝色天空:BAABLAAFFH81AAMEAAYIICBGFgCxAQAEAAYIICBGFgCxAQAFAAIIZxJOFACFAAAAAA==.',['汪利']='汪利丹丶怒风:BAAALAAFFAIIBAAAAA==.',['汪尔']='汪尔萨斯:BAABLAAFFH8OAAIcAAYIoA8+BQBaAQAcAAYIoA8+BQBaAQAAAA==.',['沐歌']='沐歌:BAAALAAECgYICwAAAA==.',['沙弥']='沙弥拉:BAABLAAFFH8fAAIBAAYIeiC+GADWAQABAAYIeiC+GADWAQAAAA==.',['沟槽']='沟槽小奶油:BAABLAAFFH8LAAMBAAYIpQ6yRQAjAQABAAUIXhCyRQAjAQACAAEICga1EgBMAAAAAA==.',['法爷']='法爷驾到:BAAALAADCgEIAQAAAA==.',['洛克']='洛克塔尔:BAABLAAFFH8LAAIIAAYIZhp4BwAcAgAIAAYIZhp4BwAcAgAAAA==.',['浩浩']='浩浩:BAAALAAFFAQIBAAAAA==.',['游侠']='游侠艾莉亚:BAAALAADCgcIBwABLAAFFAIICQABALgNAA==.',['湫兮']='湫兮如风:BAABLAAFFH8IAAIRAAIIcBYOFACtAAARAAIIcBYOFACtAAAAAA==.',['火疗']='火疗:BAAALAAECgUIBQAAAA==.',['炎帝']='炎帝弑天:BAAALAAECgYIBgAAAA==.',['烟雨']='烟雨朦胧:BAAALAADCgcIBwAAAA==.',['熊本']='熊本熊:BAAALAAECgYIBgABLAAFFAMIBwAJAIoHAA==.',['熊猫']='熊猫银:BAAALAAECggIAgAAAA==.',['爆破']='爆破鬼才:BAAALAAFFAQIBAAAAA==.',['牛劲']='牛劲儿:BAABLAAFFH8SAAMdAAYIaxV5FgCJAQAdAAYIaxV5FgCJAQAPAAEIlxE+dwA9AAAAAA==.',['牛小']='牛小花灬:BAABLAAFFH8iAAMZAAgI0BiADQCsAQAZAAYIcxeADQCsAQAMAAIIQRlSOwCpAAAAAA==.',['牛牛']='牛牛德德务:BAABLAAFFH8HAAIOAAMIzRZRJgDmAAAOAAMIzRZRJgDmAAAAAA==.',['犀利']='犀利不解释:BAAALAAECggIEAAAAA==.',['犭昔']='犭昔示申:BAAALAAECgQIBAAAAA==.',['狂彪']='狂彪大哥:BAAALAAECgIIAgAAAA==.',['狠三']='狠三狠四:BAAALAAECgMIAwAAAA==.',['猩红']='猩红布洛克斯:BAABLAAFFH8HAAIIAAMI2AhUPQB3AAAIAAMI2AhUPQB3AAAAAA==.',['猫咪']='猫咪:BAABLAAECn8WAAMKAAYI+RcvcAALAQAKAAYIGxEvcAALAQAJAAYIbBC94gC6AAAAAA==.',['猫舍']='猫舍晚:BAABLAAFFH8FAAIJAAUITR7XSQAkAQAJAAUITR7XSQAkAQAAAA==.',['玛丽']='玛丽亚:BAAALAADCgIIAwAAAA==.',['瑞克']='瑞克:BAAALAAFFAIIAgAAAA==.',['瓦里']='瓦里安乌瑞恩:BAAALAADCgYICQAAAA==.',['白昼']='白昼:BAAALAAFFAIIAgAAAA==.',['白月']='白月魁:BAAALAAECggICAAAAA==.',['百发']='百发百中丶:BAAALAAECgIIAgAAAA==.',['百年']='百年孤寂:BAAALAAECgEIAQAAAA==.',['盒子']='盒子:BAAALAAECgYICQABLAAFFAMIBwAJAIoHAA==.',['盲眼']='盲眼猎手卡恩:BAACLAAFFH8SAAIeAAYInAHZCgCWAAAeAAYInAHZCgCWAAAsAAQKfx0AAh4ACAjjBRU6AAMBAB4ACAjjBRU6AAMBAAAA.',['睿智']='睿智野猪:BAAALAAECggICAAAAA==.',['破戒']='破戒:BAAALAAFFAMIAwAAAA==.',['硬龙']='硬龙龙战:BAAALAAECggIEAAAAA==.',['神原']='神原骏河:BAABLAAECn8vAAIXAAgI8hy3MgCRAgAXAAgI8hy3MgCRAgAAAA==.',['神射']='神射手啊:BAABLAAFFH8IAAIJAAIITCTOfQBcAAAJAAIITCTOfQBcAAAAAA==.',['神秘']='神秘的加菲猫:BAACLAAFFH8iAAIBAAgIGCSAAQD3AgABAAgIGCSAAQD3AgAsAAQKfxMAAwEACAjQJnECAIMDAAEACAjQJnECAIMDAAIAAghBJQ5IAKEAAAAA.',['禁止']='禁止吸烟:BAAALAADCgEIAQAAAA==.',['福尔']='福尔德摩特:BAAALAAFFAIIBAAAAA==.',['空空']='空空:BAAALAAFFAEIAQAAAA==.',['第一']='第一时间甩锅:BAACLAAFFH9AAAIHAAcIPhw/CAA4AgAHAAcIPhw/CAA4AgAsAAQKfy8AAwcACAgIIIQeANUCAAcACAgIIIQeANUCAAsAAQgfECI8AEMAAAAA.',['等等']='等等一:BAABLAAFFH8KAAIHAAYIOhk8IwCOAQAHAAYIOhk8IwCOAQAAAA==.等等二:BAABLAAFFH8IAAIHAAgIMBETEwDyAQAHAAgIMBETEwDyAQAAAA==.',['筋斗']='筋斗云副驾驶:BAAALAADCgMIAwAAAA==.',['米妮']='米妮薇珂:BAAALAAFFAIIAQAAAA==.',['米尼']='米尼亨特:BAACLAAFFH8FAAIJAAMIWQhMdQB0AAAJAAMIWQhMdQB0AAAsAAQKfxwAAgkABwirGz2rAJsBAAkABwirGz2rAJsBAAAA.',['纯妹']='纯妹妹:BAAALAAECgQIBgAAAA==.',['纱雾']='纱雾:BAAALAAFFAMIAwAAAA==.',['缄默']='缄默德克萨斯:BAABLAAFFH8GAAIRAAQI6SUVBgDEAQARAAQI6SUVBgDEAQABLAAFFAgIKQARADUmAA==.',['翟老']='翟老师:BAAALAAFFAIIAwAAAA==.',['老幺']='老幺:BAAALAAECgcIDAAAAA==.',['老舅']='老舅:BAAALAADCgEIAQAAAA==.',['耄耋']='耄耋之年:BAABLAAFFH8aAAIOAAYInB9GBgDCAQAOAAYInB9GBgDCAQAAAA==.',['耐揍']='耐揍王:BAAALAAECgUIBQAAAA==.',['耐撅']='耐撅王:BAAALAAFFAIIBAAAAA==.',['聖園']='聖園未花:BAACLAAFFH8WAAIPAAYIwh8pBAAMAgAPAAYIwh8pBAAMAgAsAAQKfyAAAg8ABghcJT8rAGUCAA8ABghcJT8rAGUCAAEsAAUUCAgzABkA1CYA.',['肥肚']='肥肚肚左卫门:BAACLAAFFH8aAAIMAAcIDCO5BwDrAQAMAAcIDCO5BwDrAQAsAAQKfyQAAgwACAjnIZcfAPQCAAwACAjnIZcfAPQCAAAA.',['腿短']='腿短跑的快:BAAALAAECgYICQAAAA==.',['艾蕬']='艾蕬美菈哒:BAAALAADCgMIAwAAAA==.',['若舞']='若舞清风丶:BAABLAAECn8XAAIMAAYIFyDNNgC6AQAMAAYIFyDNNgC6AQAAAA==.',['英雄']='英雄挽歌:BAABLAAFFH8IAAIBAAYIkx6RHQC/AQABAAYIkx6RHQC/AQAAAA==.',['范达']='范达尔肾亏:BAAALAAFFAIIBAAAAA==.',['茆苧']='茆苧丷:BAABLAAFFH8IAAITAAUIfw4jIgAyAQATAAUIfw4jIgAyAQABLAAFFAYIDQAZAC0WAA==.茆苧乄:BAABLAAFFH8GAAITAAYIwQ6TGwByAQATAAYIwQ6TGwByAQABLAAFFAYIDQAZAC0WAA==.茆苧彡:BAAALAAFFAYIBAABLAAFFAYIDQAZAC0WAA==.',['茕茕']='茕茕孑立:BAABLAAFFH8ZAAIOAAcIxh30BABnAgAOAAcIxh30BABnAgAAAA==.',['茶茶']='茶茶:BAABLAAFFH8XAAMJAAYI3x8cKQCPAQAJAAYI8h4cKQCPAQAKAAMIiBCQGQClAAAAAA==.',['草莓']='草莓可丽饼:BAABLAAFFH8YAAMDAAcIYBkKBgAjAgADAAcIYBkKBgAjAgAWAAQI7SCOBwApAQAAAA==.草莓可丽饼一:BAABLAAFFH8VAAMDAAYIRCDmBgAJAgADAAYIRCDmBgAJAgAWAAYIqxhuBQB3AQABLAAFFAcIGAADAGAZAA==.草莓可丽饼七:BAAALAAFFAYIBAABLAAFFAcIGAADAGAZAA==.草莓可丽饼三:BAABLAAFFH8GAAMDAAYIExbmDgBLAQADAAUIfxTmDgBLAQAWAAEI8xewEgAAAAABLAAFFAcIGAADAGAZAA==.草莓可丽饼九:BAABLAAFFH8FAAIDAAUIBxqtDQBmAQADAAUIBxqtDQBmAQABLAAFFAcIGAADAGAZAA==.草莓可丽饼二:BAABLAAFFH8GAAIDAAYICRFODACFAQADAAYICRFODACFAQABLAAFFAcIGAADAGAZAA==.草莓可丽饼五:BAABLAAFFH8QAAMDAAYIxxf9CgCjAQADAAYIxxf9CgCjAQAWAAQIYxsACQD7AAABLAAFFAcIGAADAGAZAA==.草莓可丽饼八:BAABLAAFFH8PAAMWAAYIaR6mAwDQAQAWAAYIaR6mAwDQAQADAAYImhY2CgC0AQABLAAFFAcIGAADAGAZAA==.草莓可丽饼六:BAABLAAFFH8OAAMDAAYIehqtBwD0AQADAAYIehqtBwD0AQAWAAIIKhbFDgBNAAABLAAFFAcIGAADAGAZAA==.草莓可丽饼十:BAABLAAFFH8KAAMDAAYIkBWjCwCVAQADAAYIkBWjCwCVAQAWAAII3BWNDwBCAAABLAAFFAcIGAADAGAZAA==.草莓可丽饼四:BAABLAAFFH8JAAMWAAYIbR/NAwDGAQAWAAYIbR/NAwDGAQADAAEIdRxsHgBNAAABLAAFFAcIGAADAGAZAA==.草莓可丽饼零:BAABLAAFFH8QAAMDAAYI+RJ3DACBAQADAAYI+RJ3DACBAQAWAAIIuhPKDgBMAAABLAAFFAcIGAADAGAZAA==.草莓摇摇酸奶:BAABLAAFFH8MAAIPAAMIIgZDVAByAAAPAAMIIgZDVAByAAABLAAFFAUIFwAOACcNAA==.',['荞麦']='荞麦面:BAAALAAFFAIIAgABLAAFFAgIHgAHANUiAA==.',['萌帝']='萌帝加洛特:BAAALAAECggICwAAAA==.',['萌萌']='萌萌哒小狐狸:BAAALAAECgIIAgAAAA==.',['萌贼']='萌贼帝罗宾:BAAALAADCgMIAwAAAA==.',['萌骑']='萌骑帝凯多:BAAALAAECgQICQAAAA==.',['萨死']='萨死你:BAAALAADCgEIAQAAAA==.',['葵芜']='葵芜:BAABLAAFFH8NAAIZAAYILRY+DAAhAQAZAAYILRY+DAAhAQAAAA==.',['蒙多']='蒙多:BAAALAAFFAQIBAAAAA==.',['蒙牛']='蒙牛达雷:BAAALAAFFAMIAwAAAA==.蒙牛酸酸乳:BAAALAAECgIIAgAAAA==.',['薇薇']='薇薇:BAAALAAECgMIAwAAAA==.',['蘫冰']='蘫冰麟:BAACLAAFFH9EAAMHAAgIaSHrBwB+AgAHAAgIaSHrBwB+AgAGAAII8RgCEwCeAAAsAAQKfy4AAwcACAjdJDMOAC8DAAcACAjdJDMOAC8DAAYAAwh/II9gAPUAAAAA.',['虚空']='虚空之女:BAABLAAFFH8MAAIBAAYIsxiUJwCXAQABAAYIsxiUJwCXAQAAAA==.',['血雨']='血雨探花刂:BAABLAAECn8VAAMfAAgI+RSpGwBjAQAfAAgI+RSpGwBjAQAIAAYI4QpzqQAwAQABLAAFFAgIJAAgAFEaAA==.',['街头']='街头王老法:BAAALAAECgYICQAAAA==.',['說了']='說了再見:BAABLAAFFH8GAAIBAAYIXBLXLgB/AQABAAYIXBLXLgB/AQAAAA==.',['认真']='认真就输了:BAACLAAFFH8LAAITAAIIbBMFOQB8AAATAAIIbBMFOQB8AAAsAAQKfxsAAxIABgjTIOMLAO0BABIABgjTHOMLAO0BABMABgiQGkcdANABAAAA.',['话梅']='话梅排骨:BAABLAAFFH8IAAIOAAYIuxHHGABqAQAOAAYIuxHHGABqAQAAAA==.',['谢彬']='谢彬是谁:BAABLAAFFH8bAAMBAAYIYiBPNQBnAQABAAUINSBPNQBnAQACAAEIRSF1DgBdAAABLAAFFAgICQABAMwjAA==.',['贝如']='贝如塔:BAAALAAECgcIBwAAAA==.',['贝莉']='贝莉尔:BAAALAAFFAIIAgAAAA==.',['贫穷']='贫穷的阿昆达:BAAALAAECggIDgAAAA==.',['赤红']='赤红符文武器:BAAALAAECgYIBwAAAA==.',['起个']='起个什么名呢:BAAALAAECgIIAgAAAA==.起个嘛名字呢:BAAALAAECggIDQAAAA==.',['软丶']='软丶饼干:BAAALAAECgYIBgAAAA==.',['轻哼']='轻哼丶:BAABLAAFFH8OAAIIAAYIsQ5FHQB/AQAIAAYIsQ5FHQB/AQAAAA==.',['轻描']='轻描淡写:BAABLAAFFH8OAAIBAAYIkhsCJwCaAQABAAYIkhsCJwCaAQAAAA==.',['轻舟']='轻舟近岸:BAABLAAFFH8OAAIOAAgIjRPnCAAeAgAOAAgIjRPnCAAeAgAAAA==.',['轻车']='轻车熟路:BAABLAAFFH8GAAIdAAYI6godHgBQAQAdAAYI6godHgBQAQAAAA==.',['辞楠']='辞楠:BAABLAAFFH8FAAMcAAMI5QacCwBhAAAcAAMIhwacCwBhAAAgAAIIGAfoOwAwAAAAAA==.',['迎风']='迎风布阵:BAAALAAECgYICgAAAA==.',['这个']='这个是雨天:BAABLAAFFH8XAAMQAAYIvRpjCACgAQAQAAYIvRpjCACgAQAbAAQIdRasDAD/AAABLAAFFAcIGAADAGAZAA==.这个是雨天天:BAABLAAFFH8LAAIQAAYImyCGAwBAAgAQAAYImyCGAwBAAgABLAAFFAcIGAADAGAZAA==.',['逍遥']='逍遥:BAAALAAFFAIIAgAAAA==.',['部落']='部落子龙:BAAALAAECgIIAgAAAA==.',['醉梦']='醉梦無訫:BAAALAAECgEIAQAAAA==.',['醉落']='醉落夕风丶:BAABLAAFFH8KAAMJAAIIKSFKRQCfAAAJAAIIKSFKRQCfAAAKAAEIBw5VNgA8AAAAAA==.',['野原']='野原新之助:BAABLAAFFH8FAAIJAAUIeBOqSAAoAQAJAAUIeBOqSAAoAQAAAA==.',['闲趣']='闲趣丶:BAAALAAECgYIBgAAAA==.',['阡陌']='阡陌:BAAALAAFFAIIBAAAAA==.',['阳光']='阳光宅牛:BAAALAAECgcIDwAAAA==.',['阿尓']='阿尓丶萨斯:BAABLAAFFH8KAAIBAAIIjhhFYACYAAABAAIIjhhFYACYAAAAAA==.',['阿布']='阿布达雷:BAAALAAECgYIEwAAAA==.',['阿麦']='阿麦:BAABLAAFFH8KAAIPAAIIggpWWABlAAAPAAIIggpWWABlAAABLAAFFAYIEAAgAGsFAA==.',['陈风']='陈风暴醉酒:BAABLAAECn8uAAIIAAgIoyABEQBgAgAIAAgIoyABEQBgAgAAAA==.',['陷阵']='陷阵营:BAAALAAECgYIBgABLAAFFAcIOgAQAP4aAA==.',['难受']='难受想哭:BAAALAAECgYICAAAAA==.',['雪拥']='雪拥蓝関:BAABLAAFFH8UAAIJAAYI4RptKACRAQAJAAYI4RptKACRAQAAAA==.',['雪见']='雪见山青猫:BAABLAAFFH8MAAMgAAYIUhNuEwBKAQAgAAYIUhNuEwBKAQAOAAII9hHBMgBvAAABLAAFFAcICgAUAH8EAA==.',['雷声']='雷声普化天尊:BAAALAADCggICQAAAA==.',['靇龍']='靇龍:BAAALAAECgYIBgAAAA==.',['青山']='青山为隐:BAAALAAECgYICQAAAA==.',['青眼']='青眼究极龙:BAABLAAFFH8GAAIFAAQIIhn+CAD4AAAFAAQIIhn+CAD4AAAAAA==.',['青衣']='青衣小妖:BAAALAADCgEIAQAAAA==.',['青鹜']='青鹜狂想曲:BAABLAAFFH8IAAMdAAQIVhT3LQDHAAAdAAQIVhT3LQDHAAAPAAIIIhinNQCVAAAAAA==.',['青鹭']='青鹭小红手:BAAALAAECgQIBAAAAA==.青鹭狂想曲:BAABLAAFFH8GAAMCAAIInBjGGgBXAAACAAEIYB7GGgBXAAABAAEI2RJEngBGAAAAAA==.',['非时']='非时之齑粉:BAABLAAFFH8GAAIDAAYIqhffCwCRAQADAAYIqhffCwCRAQAAAA==.',['风中']='风中花朵:BAAALAAECgIIAgAAAA==.',['飛雪']='飛雪倾城:BAABLAAFFH8LAAMMAAYIAxImLAAiAQAMAAUIDBQmLAAiAQAZAAII9h/dHgCrAAAAAA==.',['飞飞']='飞飞人:BAAALAAFFAIIAgAAAA==.',['马洛']='马洛恩:BAABLAAFFH8IAAIOAAIINwsfTABZAAAOAAIINwsfTABZAAAAAA==.',['骑战']='骑战天下:BAAALAADCgIIAgAAAA==.',['魅惑']='魅惑猫猫:BAAALAAECgEIAQAAAA==.',['鲁艾']='鲁艾济南车:BAAALAAECggICQAAAA==.',['鲨掉']='鲨掉东西:BAAALAADCgMIAwAAAA==.',['麒麟']='麒麟小德:BAAALAADCggIBQAAAA==.',['麦麦']='麦麦子:BAABLAAFFH8QAAMgAAYIawXwDAAuAQAgAAYIawXwDAAuAQAOAAII5iKfHwClAAAAAA==.',['麻辣']='麻辣鸡棒棒:BAACLAAFFH8yAAIBAAYImBknJACkAQABAAYImBknJACkAQAsAAQKfxQAAgEABgi2HeuJAOkBAAEABgi2HeuJAOkBAAAA.',['黄油']='黄油面包:BAAALAADCggICAAAAA==.',['黑暗']='黑暗骑士:BAAALAAFFAIIAgAAAA==.黑暗魔王:BAABLAAFFH8IAAIFAAgIpAMaEgBQAAAFAAgIpAMaEgBQAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end