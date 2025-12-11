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
 local lookup = {'DeathKnight-Frost','Shaman-Elemental','DemonHunter-Havoc','Druid-Balance','Rogue-Assassination','Rogue-Subtlety','Warrior-Fury','Paladin-Retribution','Paladin-Protection','DemonHunter-Vengeance','Paladin-Holy','Druid-Restoration','Hunter-BeastMastery','Shaman-Restoration','Warrior-Protection','Warrior-Arms','DeathKnight-Blood','Monk-Windwalker','DeathKnight-Unholy','Priest-Shadow','Priest-Holy','Hunter-Marksmanship','Evoker-Devastation','Warlock-Destruction','Mage-Frost','Mage-Arcane','Warlock-Demonology','Druid-Feral','Warlock-Affliction','Monk-Mistweaver','Evoker-Preservation','Priest-Discipline','Monk-Brewmaster','Druid-Guardian',}; local provider = {region='CN',realm='克洛玛古斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Arbalest:BAABLAAFFH8IAAIBAAII2RGefwBGAAABAAII2RGefwBGAAAAAA==.Artanis:BAAALAAECgQIAgAAAA==.',As='Asuka:BAAALAAECgYICQAAAA==.',Ba='Balerion:BAAALAAECgEIAQAAAA==.Baratheon:BAABLAAECn8fAAICAAgIfx93HAC8AgACAAgIfx93HAC8AgAAAA==.',Be='Beastpower:BAAALAADCgUIBwAAAA==.',Bi='Bindk:BAAALAAECggICAAAAA==.',Co='Corson:BAABLAAFFH8GAAIDAAII8BOCQwCXAAADAAII8BOCQwCXAAAAAA==.',Dh='Dhqaq:BAABLAAFFH8UAAIDAAYIYSI4DgDxAQADAAYIYSI4DgDxAQAAAA==.',Dr='Dreamboat:BAACLAAFFH8IAAIEAAII3RB0IwCCAAAEAAII3RB0IwCCAAAsAAQKfyoAAgQACAjLGNUnAC4CAAQACAjLGNUnAC4CAAAA.',El='Elone:BAAALAAECgMIAwAAAA==.',Ge='Geminisaga:BAACLAAFFH8hAAMFAAYIVxnMBgCyAQAFAAYIVxnMBgCyAQAGAAIItw0YFQBEAAAsAAQKfxMAAwUACAg5HrMhAAoCAAUABwiCH7MhAAoCAAYABAjJDsI4ANYAAAAA.',He='Heiheiya:BAACLAAFFH8LAAIDAAIIYRTdTwBJAAADAAIIYRTdTwBJAAAsAAQKfx4AAgMABwiNFn81AIMBAAMABwiNFn81AIMBAAAA.',Ic='Iceforce:BAAALAAECgYIBgAAAA==.Icywings:BAAALAAECggICAAAAA==.',In='Inosence:BAAALAAECgEIAgAAAA==.',Ju='Juechen:BAACLAAFFH8OAAIHAAYIQCN8EADUAQAHAAYIQCN8EADUAQAsAAQKf1UAAgcACAjRJlYAAJ4DAAcACAjRJlYAAJ4DAAAA.',Ka='Kaiba:BAABLAAFFH8IAAIBAAYI8AXlRwAaAQABAAYI8AXlRwAaAQAAAA==.',Ki='Kilig:BAABLAAFFH8FAAMIAAII+QbOWgCFAAAIAAII+QbOWgCFAAAJAAEIKgREJAAqAAAAAA==.',Le='Lellow:BAAALAAECgYICAAAAA==.Lenapark:BAAALAAECgYIBgAAAA==.',Lo='Loramus:BAAALAAECgUIBgAAAA==.',Mi='Minotaura:BAAALAADCgYIBgAAAA==.Minotaurd:BAAALAAECgcIEQAAAA==.Miscedence:BAAALAAFFAIIBAAAAA==.',Mo='Moffy:BAAALAADCgEIAQAAAA==.',Mu='Multivitamin:BAAALAAECgQIBAAAAA==.',Na='Naaruia:BAAALAAECgIIAgAAAA==.',Ne='Nerv:BAAALAAECgQIBAAAAA==.',On='Onettff:BAAALAAFFAIIBAAAAA==.',Pa='Paradiso:BAABLAAECn8bAAIKAAYIkxw0HADcAQAKAAYIkxw0HADcAQAAAA==.',Sa='Sa:BAAALAAFFAIIBAAAAA==.',Si='Simon:BAAALAAFFAIIBAAAAA==.',Va='Valkyrjja:BAABLAAFFH8KAAIDAAIIfhFpQQCYAAADAAIIfhFpQQCYAAAAAA==.',['一介']='一介俗人:BAAALAADCgEIAQAAAA==.',['一年']='一年还是两年:BAABLAAFFH8RAAMLAAYINRbLDwDjAAALAAUI9xbLDwDjAAAIAAEIqQU/bwA+AAAAAA==.',['一把']='一把大木槌:BAABLAAFFH8IAAIIAAQIcBYsNADgAAAIAAQIcBYsNADgAAAAAA==.',['一花']='一花落无声一:BAAALAADCgMIAwAAAA==.',['七年']='七年时光:BAAALAADCgUIBQAAAA==.',['不胜']='不胜寒:BAAALAAECgYIBgAAAA==.',['东京']='东京奶德:BAACLAAFFH85AAMMAAYIVSQqCwAAAgAMAAUI1yMqCwAAAgAEAAUIah7rEABkAQAsAAQKfz0AAwQACAhHIlwXAKkCAAQABwhvIlwXAKkCAAwABghAGP5nAF0BAAAA.',['东倪']='东倪:BAAALAAECgYIDAAAAA==.',['丨开']='丨开心玖好:BAABLAAFFH8MAAMJAAIINBHsGAB1AAAJAAIINBHsGAB1AAALAAIIgwFzJwBmAAAAAA==.',['丨晨']='丨晨丨曦丨:BAAALAAECggIDQAAAA==.',['丶雨']='丶雨天:BAABLAAFFH8GAAINAAYICg6xRAA2AQANAAYICg6xRAA2AQAAAA==.',['为什']='为什么:BAAALAAECgUIBwAAAA==.',['久违']='久违女人香:BAAALAAECgYIBgAAAA==.',['乐安']='乐安:BAAALAAFFAIIAgAAAA==.',['乐言']='乐言:BAABLAAFFH8HAAIMAAIIrQy5OQBmAAAMAAIIrQy5OQBmAAAAAA==.',['于小']='于小渔:BAAALAAFFAEIAQAAAA==.',['云上']='云上飞静:BAABLAAFFH8GAAMEAAYI/g87HADwAAAEAAUIRBA7HADwAAAMAAEIFh1PVQBJAAAAAA==.',['五僧']='五僧红旗:BAAALAAECgYIEAAAAA==.',['交出']='交出你的波波:BAAALAAFFAIIBAAAAA==.',['今日']='今日花如雪灬:BAABLAAFFH8KAAIOAAIIsRj8SACMAAAOAAIIsRj8SACMAAAAAA==.',['今比']='今比明:BAAALAAFFAMIBAAAAA==.',['从小']='从小头就硬:BAABLAAECn8XAAIPAAcIhSBYHgBAAgAPAAcIhSBYHgBAAgAAAA==.',['他是']='他是我的:BAAALAAECgMIAwAAAA==.',['代号']='代号零:BAAALAADCgYIBgAAAA==.',['代表']='代表太阳:BAAALAAECgcICgAAAA==.',['仲间']='仲间由玛姬:BAAALAADCgQIBAAAAA==.',['伊布']='伊布:BAAALAAECgYIBgAAAA==.',['伊蕾']='伊蕾娜:BAAALAAFFAIIBAAAAA==.',['住手']='住手丨我来扛:BAACLAAFFH8KAAIHAAIIDghOWwA7AAAHAAIIDghOWwA7AAAsAAQKfyIABBAABgjsGe8RALgBABAABghRF+8RALgBAAcABgjqEjtKADgBAA8AAwihGgptANYAAAAA.',['佳运']='佳运:BAAALAAECgYIBgAAAA==.',['侯鳥']='侯鳥的麻糖:BAAALAAFFAIIBAAAAA==.',['俺就']='俺就要紫霞:BAAALAAECgIIAgAAAA==.',['傾城']='傾城若雪:BAAALAAECgYIDwAAAA==.',['光华']='光华:BAAALAADCgIIAgAAAA==.',['光芒']='光芒:BAABLAAFFH8GAAIIAAYIRR4sEwCwAQAIAAYIRR4sEwCwAQAAAA==.光芒幻火:BAAALAAECgUIBQAAAA==.光芒怒风:BAABLAAFFH8GAAIPAAYIOxxbCgCaAQAPAAYIOxxbCgCaAQAAAA==.光芒狗蛋:BAAALAAECgIIAgAAAA==.光芒猎手:BAAALAAECgYIDQAAAA==.光芒陨落:BAAALAAECgYIBgAAAA==.',['克拉']='克拉拉莱辛:BAACLAAFFH8gAAIRAAYIBxXXCQB4AQARAAYIBxXXCQB4AQAsAAQKfxcAAxEACAgOF6kZAM4BABEACAgOF6kZAM4BAAEAAQimD5XRADwAAAEsAAUUBggrAAkAWRcA.',['兜里']='兜里棍多多:BAAALAAECgcIDQAAAA==.',['八千']='八千歳:BAAALAADCggICAAAAA==.',['八音']='八音盒:BAAALAAECgYICwAAAA==.',['公子']='公子別這樣:BAABLAAFFH8QAAIGAAIImxRJEwCNAAAGAAIImxRJEwCNAAAAAA==.',['兰若']='兰若仙踪:BAABLAAFFH8GAAISAAUIvAY1EgB5AAASAAUIvAY1EgB5AAAAAA==.',['兽之']='兽之王者:BAAALAAECgUIBQAAAA==.',['农夫']='农夫大锤:BAAALAAECgQIBAAAAA==.',['冰峰']='冰峰灬红尘:BAACLAAFFH8yAAIBAAgI3SJfAwB0AgABAAgI3SJfAwB0AgAsAAQKfyYAAwEACAj+JT8NAEADAAEACAj+JT8NAEADABMABgivEek1ACQBAAAA.',['冰点']='冰点凝凝:BAABLAAFFH8GAAMUAAYINwrtIQB2AAAUAAQIoQHtIQB2AAAVAAIIcwLDSABYAAAAAA==.冰点四十八度:BAAALAADCggICAAAAA==.',['决刀']='决刀送行:BAAALAAECgEIAQAAAA==.',['凡圣']='凡圣:BAAALAAFFAEIAQAAAA==.',['凤狂']='凤狂神:BAACLAAFFH8hAAMNAAYI9g5zLQDNAAANAAYI9g5zLQDNAAAWAAMIuANcLwBjAAAsAAQKfxsAAxYACAhXE687AMkBABYACAhXE687AMkBAA0AAQgdBz+pASMAAAAA.',['凯撒']='凯撒之魂:BAAALAAECgYIBgAAAA==.',['凯蒂']='凯蒂亚:BAAALAAECgUIBgAAAA==.',['出门']='出门带把:BAAALAADCgQIBAAAAA==.',['刘波']='刘波儿:BAABLAAFFH8MAAIXAAYIvAsdDgA8AQAXAAYIvAsdDgA8AQAAAA==.',['剪刀']='剪刀手陶德:BAAALAAECgIIAgAAAA==.',['加什']='加什鲁尔:BAAALAAECgQIBAAAAA==.',['匠人']='匠人无寓:BAAALAAECgMIAwAAAA==.',['十年']='十年一贱:BAAALAADCgYIBgAAAA==.',['南辞']='南辞:BAACLAAFFH8IAAIBAAIIaBJCdgBLAAABAAIIaBJCdgBLAAAsAAQKfxcAAgEABgiGHDE2AKEBAAEABgiGHDE2AKEBAAAA.',['卡卡']='卡卡东师傅:BAABLAAFFH8XAAMBAAYIiRyyIgCpAQABAAYIiRyyIgCpAQARAAEIvQGWHQArAAAAAA==.',['卡嘉']='卡嘉莉:BAACLAAFFH8PAAIVAAYIaASEKQDgAAAVAAYIaASEKQDgAAAsAAQKfzYAAhUACAilDwhOAJ4BABUACAilDwhOAJ4BAAAA.',['卡皮']='卡皮巴拉:BAAALAAECgEIAQAAAA==.',['去有']='去有风的地方:BAAALAAECgEIAQAAAA==.',['双喜']='双喜的骑士:BAAALAAECggICwAAAA==.',['双花']='双花大红棍:BAAALAAECgYIBgAAAA==.',['古明']='古明地恋:BAAALAADCgMIAwAAAA==.',['可乐']='可乐苏打:BAAALAADCgYIBgAAAA==.',['史根']='史根治:BAAALAAECgQIBAAAAA==.',['史蒂']='史蒂文森:BAAALAAECgYIBgAAAA==.',['右手']='右手葬黎明:BAAALAAFFAIIBAAAAA==.',['叶胖']='叶胖达:BAAALAAECgYIEgAAAA==.',['吃亏']='吃亏喝水变污:BAAALAAECgIIAgAAAA==.',['吃俩']='吃俩鸡蛋:BAACLAAFFH8bAAIYAAYIQRdILQBlAQAYAAYIQRdILQBlAQAsAAQKfywAAhgACAiAH8MmAKoCABgACAiAH8MmAKoCAAAA.',['吉祥']='吉祥天:BAAALAAECggICAAAAA==.',['听见']='听见风雨:BAAALAAECggIBgAAAA==.',['呆呆']='呆呆小丸子:BAABLAAFFH8KAAIMAAIIlBtzNgCQAAAMAAIIlBtzNgCQAAAAAA==.',['咔咔']='咔咔舞凌:BAAALAADCgUIBQAAAA==.咔咔饕餮:BAAALAAFFAIIAgAAAA==.',['唐山']='唐山浪打浪:BAABLAAFFH8HAAMZAAMICRRnDQCEAAAZAAMICRRnDQCEAAAaAAIIwAyJXQA+AAAAAA==.',['喵小']='喵小德:BAAALAADCgEIAQAAAA==.',['嗜血']='嗜血灬先祖:BAABLAAFFH8KAAIOAAMIKQ8vQwCcAAAOAAMIKQ8vQwCcAAAAAA==.嗜血灬圣骑:BAABLAAFFH8HAAIIAAIIXRqcUgBQAAAIAAIIXRqcUgBQAAAAAA==.嗜血灬猎神:BAAALAAFFAIIAgAAAA==.嗜血灬邪神:BAABLAAFFH8JAAIbAAMIfhlwCACcAAAbAAMIfhlwCACcAAAAAA==.嗜血灬阳哥:BAACLAAFFH8FAAIMAAMI/A+UMQCjAAAMAAMI/A+UMQCjAAAsAAQKfxYAAgwACAjsF3QYAAsCAAwACAjsF3QYAAsCAAAA.嗜血魔神:BAAALAADCgEIAQAAAA==.',['嗨菇']='嗨菇娘:BAABLAAFFH8FAAMOAAII4AFNdwA9AAAOAAII4AFNdwA9AAACAAEIixFyVwAAAAAAAA==.',['嘍嘍']='嘍嘍的嘍嘍:BAAALAAECgYIBgAAAA==.',['噬神']='噬神魔:BAAALAAECgIIBAAAAA==.',['囧灵']='囧灵:BAAALAAECgMIAwAAAA==.',['图南']='图南:BAAALAAECgQIBAAAAA==.',['圣光']='圣光老哥:BAAALAAECgIIBgAAAA==.',['圣恩']='圣恩:BAAALAAECggICAAAAA==.',['圣流']='圣流沙:BAAALAAFFAEIAQAAAA==.',['圣骑']='圣骑审判者:BAAALAAFFAIIAgAAAA==.',['夜魇']='夜魇:BAABLAAFFH8GAAIcAAII9REgDACgAAAcAAII9REgDACgAAAAAA==.',['大哥']='大哥慢点:BAAALAADCgYIBgAAAA==.',['大奎']='大奎:BAABLAAFFH8GAAMbAAIIgxf0EACiAAAbAAIIgxf0EACiAAAYAAEIEgyYZgA5AAAAAA==.',['天天']='天天小妞妞:BAAALAAECgYICQAAAA==.',['天子']='天子传奇:BAAALAAECgYICgAAAA==.',['天蝎']='天蝎丶睿:BAABLAAFFH8GAAMYAAYIZRQZNwAyAQAYAAUIzBUZNwAyAQAdAAEIYQ0OCABRAAAAAA==.',['天谴']='天谴之箭:BAAALAAECgYIBgAAAA==.',['太和']='太和:BAAALAAECgYIBgAAAA==.',['奈亚']='奈亚子:BAAALAAECgIIAgAAAA==.',['奈何']='奈何桥上卖身:BAACLAAFFH8GAAIHAAIIXQhXRACHAAAHAAIIXQhXRACHAAAsAAQKfxYAAwcACAiVFW1NAAgCAAcACAiVFW1NAAgCAA8ACAgRB51dAA8BAAAA.奈何桥下约会:BAACLAAFFH8GAAIOAAII1BtSMQCfAAAOAAII1BtSMQCfAAAsAAQKfyUAAw4ACAjgHCUgAJMCAA4ACAjgHCUgAJMCAAIAAQirCcLPADgAAAAA.',['奥蕾']='奥蕾灬莉亚:BAACLAAFFH8FAAINAAIIihEWjQBGAAANAAIIihEWjQBGAAAsAAQKfxcAAg0ABgiBHmBOAKgBAA0ABgiBHmBOAKgBAAEsAAUUAwgOAAkArRcA.',['奶住']='奶住大饼:BAAALAADCgIIAgAAAA==.',['好了']='好了吧:BAAALAAECgUICAAAAA==.好了吧你:BAAALAAECgQIBAAAAA==.好了吧你你:BAAALAAECgYICwAAAA==.好了吧你你吧:BAAALAAECgUICwAAAA==.好了吧你你好:BAAALAAECgYIDwAAAA==.',['妖吻']='妖吻:BAAALAAECgEIAQABLAAFFAgIEAANAMoXAA==.',['娜坷']='娜坷露露:BAAALAADCgcIBwAAAA==.',['娜娜']='娜娜莫女王:BAACLAAFFH8xAAIeAAYIbhakCACYAQAeAAYIbhakCACYAQAsAAQKfzoAAh4ACAicHooLAKwCAB4ACAicHooLAKwCAAAA.',['嫣紫']='嫣紫:BAAALAAECgYIBwAAAA==.',['子弟']='子弟兵:BAAALAAECgYICAAAAA==.',['存钱']='存钱罐罐:BAABLAAFFH8LAAIMAAUILhTBIgAGAQAMAAUILhTBIgAGAQAAAA==.',['孤身']='孤身伴月影:BAACLAAFFH8sAAIEAAYIDhsDDwB5AQAEAAYIDhsDDwB5AQAsAAQKfzQAAgQACAjCI7UKAB4DAAQACAjCI7UKAB4DAAAA.',['守卫']='守卫雅典娜:BAAALAAECggIDAAAAA==.',['安薇']='安薇娜提歌:BAAALAAECgUIBQAAAA==.',['寒光']='寒光照鐡衣:BAAALAAECgYIBgAAAA==.',['寻找']='寻找岼衡:BAABLAAFFH8TAAIJAAYIxhSoBwBKAQAJAAYIxhSoBwBKAQAAAA==.寻找平横:BAABLAAFFH8KAAIVAAII5wvqNACIAAAVAAII5wvqNACIAAAAAA==.寻找苹鸻:BAACLAAFFH8sAAMXAAYI0homCgB/AQAXAAYI0homCgB/AQAfAAEIEAD4IgACAAAsAAQKfy8AAhcACAg0Is0JAP4CABcACAg0Is0JAP4CAAAA.',['射你']='射你一箭:BAAALAAECgYIBwAAAA==.',['小丶']='小丶妹:BAAALAAECgYICwAAAA==.',['小兔']='小兔子:BAAALAAECgQIBgAAAA==.',['小小']='小小晾衣夹:BAAALAAECgYIDAAAAA==.',['小术']='小术流沙:BAAALAAECgUIBwAAAA==.',['小法']='小法火法:BAAALAADCgMIAwAAAA==.',['小瘸']='小瘸瘸丶:BAAALAAECgYIBgAAAA==.',['小贼']='小贼猫娜美:BAAALAAECgYIDAAAAA==.',['小魔']='小魔星:BAAALAAECgMIAwAAAA==.',['小鱼']='小鱼家的包菜:BAAALAAECgcIDgAAAA==.',['尘烟']='尘烟大魔王:BAAALAAFFAQIBAAAAA==.',['尛石']='尛石头:BAAALAADCgMIAwAAAA==.',['尹志']='尹志平:BAAALAAECgYIBwAAAA==.',['岚影']='岚影落:BAABLAAFFH8GAAIOAAIIHB8EQgCgAAAOAAIIHB8EQgCgAAAAAA==.',['左手']='左手战狂:BAAALAAECgEIAQAAAA==.',['左边']='左边牙啃苹果:BAAALAADCgEIAQAAAA==.',['幻月']='幻月流苏:BAAALAAECgEIAQAAAA==.幻月琉苏:BAAALAAECgcIBwAAAA==.',['幼稚']='幼稚園茶妹:BAACLAAFFH8FAAIbAAIIzhbfEQBIAAAbAAIIzhbfEQBIAAAsAAQKfxYAAxsABghUD3ojALcAABgABgidBo+3AAYBABsABAhFFHojALcAAAAA.',['幽冥']='幽冥烈焰:BAAALAADCgUIBQAAAA==.',['张云']='张云裳:BAAALAAECgUIBQAAAA==.',['张小']='张小丽:BAAALAAECgYIBgAAAA==.张小凡:BAAALAAFFAIIAwAAAA==.',['归藏']='归藏:BAAALAAECgYICQAAAA==.',['影丨']='影丨丶壁垒:BAAALAAECgYIBgAAAA==.',['徐浩']='徐浩嘉:BAAALAAECgMIAwAAAA==.',['微笑']='微笑的眼睛:BAAALAAECgcIBwAAAA==.',['忘却']='忘却忧伤:BAABLAAFFH8IAAMMAAIISQuoOgBlAAAMAAIISQuoOgBlAAAEAAIIchQLNgA5AAAAAA==.',['忘忧']='忘忧景久:BAAALAAECgQIBAAAAA==.',['快乐']='快乐的老爷们:BAAALAAECgYIBgAAAA==.',['思念']='思念成殇:BAAALAAECgcIBwAAAA==.',['思思']='思思:BAABLAAFFH8IAAIHAAMIIAbLPgBpAAAHAAMIIAbLPgBpAAAAAA==.',['急刹']='急刹车:BAABLAAFFH8QAAMHAAYIESRuEADVAQAHAAYILSJuEADVAQAPAAYIWyErCgCeAQABLAAFFAgIDwAPAKYjAA==.',['恶堕']='恶堕女博士:BAAALAADCgEIAQAAAA==.',['恶魔']='恶魔之韧:BAAALAAECgYICwAAAA==.恶魔刀锋:BAAALAAECgQIBAAAAA==.',['惬意']='惬意的风:BAACLAAFFH85AAMOAAYIQRndGQCNAQAOAAYIQRndGQCNAQACAAYIHxTSGQBwAQAsAAQKfzsAAwIACAg8HI0hAJwCAAIACAg8HI0hAJwCAA4ABwhGGb0pAMIBAAAA.',['我的']='我的宝贝:BAAALAADCgYIBgAAAA==.',['我蛋']='我蛋刀呢:BAABLAAFFH8YAAIDAAYI1SOyCwDoAQADAAYI1SOyCwDoAQABLAAFFAgIDgAHAEAjAA==.',['我要']='我要让你心碎:BAAALAAECgUIBQAAAA==.',['战俘']='战俘别找我:BAAALAAFFAIIAgAAAA==.',['戰神']='戰神佩琪:BAAALAAECgMIBAAAAA==.',['手中']='手中流沙:BAACLAAFFH8IAAIVAAMIxQ5YLgC0AAAVAAMIxQ5YLgC0AAAsAAQKfyIABCAABgi1GhQKAGEBABUABgiKF/9YAHUBACAABgh2FBQKAGEBABQAAQjUBgmeADQAAAAA.',['扶岳']='扶岳:BAAALAAECgYICAAAAA==.',['把血']='把血放出来:BAABLAAECn8fAAMBAAgI7RThhgDuAQABAAgIuRThhgDuAQATAAcIAxBnKAB9AQAAAA==.',['拉布']='拉布布:BAAALAAECggICAAAAA==.',['拉风']='拉风的小红花:BAABLAAFFH8RAAMNAAYIuxsNQABGAQANAAYIuxsNQABGAQAWAAIIQxCgLQBqAAAAAA==.',['搬运']='搬运工:BAABLAAFFH8KAAIMAAIIUB2PNgCQAAAMAAIIUB2PNgCQAAAAAA==.',['散庚']='散庚浮白:BAABLAAFFH8ZAAIBAAYIMBwWHwC4AQABAAYIMBwWHwC4AQAAAA==.',['斐迪']='斐迪南大公:BAACLAAFFH8rAAIJAAYIWRd5BgBqAQAJAAYIWRd5BgBqAQAsAAQKfxYAAgkACAggHIwRAHQCAAkACAggHIwRAHQCAAAA.',['斯文']='斯文的坦克:BAABLAAECn8aAAIBAAYIuiDLcQATAgABAAYIuiDLcQATAgAAAA==.斯文的大领主:BAAALAAECgYIBwAAAA==.斯文的昊先森:BAAALAAECgYIBAAAAA==.斯文的疯子:BAAALAAECgYIDgAAAA==.斯文的败類:BAAALAAECgYIDgAAAA==.',['方小']='方小简:BAAALAAECgUIBQAAAA==.',['无情']='无情屁屁:BAAALAADCgEIAQAAAA==.',['无言']='无言以对:BAAALAADCgUIBQAAAA==.',['日进']='日进斗金:BAAALAADCgcIBwAAAA==.',['明曰']='明曰花绮罗丶:BAABLAAFFH8KAAILAAYI5Q9XBwC1AQALAAYI5Q9XBwC1AQAAAA==.',['昕阳']='昕阳:BAABLAAFFH8KAAIDAAII1BdnUQBIAAADAAII1BdnUQBIAAAAAA==.',['星月']='星月之喑:BAAALAADCgIIAgAAAA==.',['星玥']='星玥:BAAALAADCgMIAwAAAA==.',['星菱']='星菱:BAACLAAFFH8KAAIVAAII1gwXNgCGAAAVAAII1gwXNgCGAAAsAAQKfxQAAhUACAi7GGkeAMYBABUACAi7GGkeAMYBAAAA.',['星辰']='星辰远逝:BAAALAAECgYIDAAAAA==.',['春日']='春日野穹:BAAALAAECgIIAgAAAA==.',['春醒']='春醒鸢徊:BAAALAAECgYIEQAAAA==.',['昨日']='昨日雪如花灬:BAABLAAFFH8GAAIBAAII/hUDbQCSAAABAAII/hUDbQCSAAAAAA==.',['普渡']='普渡法尊:BAABLAAECn8WAAIgAAgIog+sCwA8AQAgAAgIog+sCwA8AQAAAA==.',['暗夜']='暗夜刀斧手:BAAALAAECggICAAAAA==.暗夜悠悠:BAAALAAECgYIEwAAAA==.暗夜猎神超萌:BAAALAAECggICAAAAA==.',['暴躁']='暴躁的孙仲谋:BAABLAAFFH8VAAINAAYIiBrPLgB8AQANAAYIiBrPLgB8AQAAAA==.',['曙光']='曙光之伊丹:BAAALAAECgUIBQAAAA==.曙光之女神:BAAALAAECgMIAwAAAA==.曙光小风:BAAALAAECgYIBgAAAA==.曙光邪月:BAAALAAECgYIDAAAAA==.',['曹偲']='曹偲妮:BAAALAAFFAIIBAAAAA==.',['曹萌']='曹萌徳:BAABLAAFFH8HAAIMAAIIXAzySwBZAAAMAAIIXAzySwBZAAAAAA==.',['最强']='最强怒风:BAAALAADCgMIBAAAAA==.',['月下']='月下起司猫:BAAALAAECgIIAgAAAA==.',['月影']='月影依旧:BAAALAAECgYICgAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8IAAMMAAgIfxabMACnAAAMAAcIqRSbMACnAAAEAAEI1RsAAAAAAAAAAA==.',['有品']='有品位的流氓:BAAALAADCgEIAQAAAA==.',['有点']='有点困:BAAALAAFFAgIBAAAAA==.有点神骑:BAAALAAECgUIBAAAAA==.',['朙朙']='朙朙很聪明:BAABLAAFFH8UAAIHAAIIFhprQwBQAAAHAAIIFhprQwBQAAAAAA==.',['木元']='木元真实:BAAALAAECgYIEQAAAA==.',['末日']='末日冰峰:BAACLAAFFH8TAAIYAAUI3wyZPQAKAQAYAAUI3wyZPQAKAQAsAAQKfxUAAhgACAhzD+RfANEBABgACAhzD+RfANEBAAAA.末日飘雪:BAABLAAFFH8RAAIJAAYIyxJABwBUAQAJAAYIyxJABwBUAQAAAA==.',['术奶']='术奶:BAAALAAECgIIAgAAAA==.',['术狂']='术狂:BAAALAAECgQIBAAAAA==.',['杀戮']='杀戮魔王:BAABLAAFFH8LAAMWAAMINBBSHACXAAAWAAMIswVSHACXAAANAAIIdhZYiABJAAAAAA==.',['杀手']='杀手丨哲学:BAACLAAFFH8qAAICAAYIjxcdFwCEAQACAAYIjxcdFwCEAQAsAAQKfzcAAgIACAhhHXMmAH8CAAIACAhhHXMmAH8CAAAA.',['林雷']='林雷:BAAALAAECgYIEgAAAA==.',['果哥']='果哥:BAAALAAECgIIAgAAAA==.',['果圣']='果圣:BAAALAAECgUIBQAAAA==.',['果大']='果大:BAAALAAECggICAAAAA==.',['果爷']='果爷:BAAALAAECggIDwAAAA==.',['某小']='某小某:BAAALAAECgUIBQAAAA==.',['柒烨']='柒烨尘:BAAALAAECgYIDwAAAA==.',['柠一']='柠一萌:BAAALAAECgYIBwAAAA==.',['格雷']='格雷迈恩:BAAALAAECgQICAAAAA==.',['格鲁']='格鲁鲁:BAAALAAECggICAAAAA==.',['桥本']='桥本有腿:BAABLAAFFH8SAAMaAAYI2RRCJQABAQAaAAYI2RRCJQABAQAZAAEIsAFKIwAvAAAAAA==.',['梁敏']='梁敏儿:BAAALAAECggICAAAAA==.',['梅梨']='梅梨莱:BAAALAAECgMIAwAAAA==.',['梦中']='梦中雨花:BAAALAAECggIAgAAAA==.',['楓宸']='楓宸:BAAALAAECggICAAAAA==.',['樱花']='樱花青提:BAAALAADCggICAAAAA==.',['欧皇']='欧皇的痴狂:BAABLAAFFH8GAAIbAAYIkwAEGgCPAAAbAAYIkwAEGgCPAAAAAA==.',['欲梦']='欲梦:BAABLAAFFH8HAAIIAAMIbwsqSQB1AAAIAAMIbwsqSQB1AAAAAA==.',['歌未']='歌未竟:BAAALAADCgUIBQAAAA==.',['死亡']='死亡绝吻:BAAALAADCgIIAgAAAA==.',['死神']='死神之握:BAAALAAECgYIDQAAAA==.',['残帆']='残帆:BAAALAAECgYIDwAAAA==.',['永离']='永离红尘:BAABLAAFFH8OAAIFAAUIlxUgDgAqAQAFAAUIlxUgDgAqAQABLAAFFAgIMgABAN0iAA==.',['永远']='永远在一起:BAAALAAECggICAAAAA==.永远并不远:BAAALAAFFAIIAgAAAA==.',['沐瑞']='沐瑞:BAAALAADCggIBgAAAA==.',['沝煑']='沝煑兎兒:BAAALAAECggICAAAAA==.',['法也']='法也容情:BAAALAAECgYIDAAAAA==.',['法残']='法残:BAAALAADCgEIAQAAAA==.',['泰蘭']='泰蘭德旳記憶:BAACLAAFFH8YAAMKAAYIHBF5BwD7AAAKAAYI/gt5BwD7AAADAAMIwxq5HAD4AAAsAAQKfycAAwMACAhVHbI+AGcCAAMACAiYHLI+AGcCAAoACAjuEv4dAMsBAAAA.',['流光']='流光暮锦年:BAAALAAECgEIAQAAAA==.',['浅蓝']='浅蓝幽幽:BAAALAADCgEIAQAAAA==.',['测字']='测字解梦算命:BAAALAAECgEIAQAAAA==.',['浪漫']='浪漫休止符:BAAALAADCggICAAAAA==.',['深邃']='深邃小偷:BAAALAADCgEIAQAAAA==.',['混沌']='混沌玛利亚:BAABLAAECn8ZAAMYAAgIhB0yNgBiAgAYAAgIsxsyNgBiAgAdAAMIqiB/GwAhAQAAAA==.',['清梦']='清梦星河灬齊:BAAALAAECgQIBAAAAA==.',['清风']='清风一游侠:BAAALAADCggIDAAAAA==.',['漫天']='漫天樱椛:BAAALAAFFAIIAgAAAA==.漫天樱花:BAABLAAFFH8GAAINAAIIaxqLiQBIAAANAAIIaxqLiQBIAAAAAA==.',['火文']='火文:BAAALAAECgMIAwAAAA==.',['灬以']='灬以诺灬:BAABLAAFFH8UAAIBAAUIphIdQwAuAQABAAUIphIdQwAuAQAAAA==.',['灬怒']='灬怒风灬:BAAALAADCgYIBgAAAA==.',['灬沙']='灬沙洲冷:BAABLAAFFH8GAAIDAAIIFBeWWQBDAAADAAIIFBeWWQBDAAAAAA==.',['灬红']='灬红豆派灬:BAAALAADCgEIAwAAAA==.',['炎帝']='炎帝灬萧炎灬:BAAALAAECgYIDwAAAA==.',['炮灰']='炮灰向前沖:BAAALAAECgIIAgAAAA==.',['烧烤']='烧烤牛肉:BAABLAAFFH8SAAIOAAYImA16JwAnAQAOAAYImA16JwAnAQAAAA==.',['無名']='無名:BAACLAAFFH8dAAIHAAYIGxSbHACEAQAHAAYIGxSbHACEAQAsAAQKfzQAAgcACAgjGeE1AF4CAAcACAgjGeE1AF4CAAAA.',['爱罗']='爱罗拉:BAABLAAECn8eAAMWAAcIgwjAHACwAAAWAAcIXgbAHACwAAANAAEIWRYqKQFDAAAAAA==.',['牛奶']='牛奶骑士:BAAALAAECgYIEwAAAA==.',['狂杀']='狂杀:BAAALAAFFAIIBAAAAA==.',['狙击']='狙击王乌索普:BAAALAAFFAIIBAAAAA==.',['狠哥']='狠哥:BAAALAAECgcIBwAAAA==.',['独孤']='独孤冥神:BAAALAAECgIIAgAAAA==.',['独行']='独行独酬:BAAALAAECgYIDgAAAA==.',['猪猪']='猪猪蛋:BAACLAAFFH8yAAIVAAcIAhXECwCUAQAVAAcIAhXECwCUAQAsAAQKfxQAAxUACAhVDTZZAHQBABUACAhVDTZZAHQBABQABgjfCupjACoBAAAA.',['王戈']='王戈庄小伙:BAAALAAECgYIBgAAAA==.',['玩的']='玩的就是爽:BAAALAAECgYIDAAAAA==.',['珂朵']='珂朵莉:BAAALAAFFAIIAgAAAA==.',['珊翠']='珊翠斯月光:BAAALAAECgYICgAAAA==.',['甜心']='甜心小美:BAAALAAECgMIAwAAAA==.',['生命']='生命的旅程:BAAALAAFFAIIAgAAAA==.',['男主']='男主角:BAAALAAECgcICwAAAA==.',['疏影']='疏影浮月:BAAALAAECgEIAQAAAA==.',['疾锋']='疾锋:BAABLAAFFH8GAAIWAAIIrg0QJwB6AAAWAAIIrg0QJwB6AAAAAA==.',['白太']='白太狼:BAAALAAECgYIBgAAAA==.',['白嶶']='白嶶:BAABLAAFFH8QAAIVAAYIKxeeEQDOAQAVAAYIKxeeEQDOAQAAAA==.',['白的']='白的黑:BAABLAAFFH8MAAIIAAUI1ByqBwDrAQAIAAUI1ByqBwDrAQAAAA==.',['百变']='百变小萨:BAAALAAECgIIAgAAAA==.',['益达']='益达:BAABLAAECn8UAAMUAAYI4BdZTQCBAQAUAAYI4BdZTQCBAQAVAAMIDxSZlwC8AAAAAA==.',['真的']='真的汉子:BAABLAAFFH8fAAINAAYInhdoMAB2AQANAAYInhdoMAB2AQAAAA==.',['砖打']='砖打老幼病残:BAAALAAECgYIEQAAAA==.',['祈桦']='祈桦鎏月:BAAALAAECgYICgAAAA==.',['神仙']='神仙宝贝:BAAALAADCgQIBAAAAA==.',['神圣']='神圣已死:BAAALAAECgIIAgAAAA==.',['神牧']='神牧土豆粉:BAAALAAECgYIBgAAAA==.',['神龙']='神龙:BAAALAAECgYIDQAAAA==.',['离家']='离家出走:BAAALAAECgEIAQAAAA==.',['稀有']='稀有丶:BAABLAAFFH8JAAMVAAYIIhqpHABpAQAVAAUI+BmpHABpAQAUAAEIjRctJQBQAAAAAA==.',['笑殺']='笑殺紅尘:BAAALAADCgYIBgAAAA==.',['箭随']='箭随心意:BAAALAAFFAQIBAAAAA==.',['米呆']='米呆呆钱多多:BAAALAAECgcIDQAAAA==.',['糖球']='糖球児灬:BAAALAADCgYIBgAAAA==.',['索饵']='索饵:BAAALAAFFAIIBAAAAA==.',['紫雨']='紫雨如烟:BAAALAADCgEIAQAAAA==.',['红烛']='红烛:BAACLAAFFH8yAAIYAAYIBRptIwCNAQAYAAYIBRptIwCNAQAsAAQKfzQAAhgACAgzIIscAOACABgACAgzIIscAOACAAAA.',['红色']='红色飞灰:BAAALAAFFAIIAgAAAA==.',['绚丽']='绚丽多彩:BAAALAADCgQIBAAAAA==.',['羊和']='羊和猪:BAAALAADCgMIAwAAAA==.',['羞答']='羞答答地玫瑰:BAAALAAFFAIIAgAAAA==.',['老牛']='老牛哞:BAACLAAFFH8KAAMLAAMI2BrxGgDYAAALAAMI2BrxGgDYAAAIAAEIygTeiQAAAAAsAAQKfyEAAwsACAhdGs8YAEcCAAsACAhdGs8YAEcCAAgABQgxG/5gAEMBAAAA.',['老老']='老老狠:BAAALAAECgIIAgAAAA==.',['聖约']='聖约翰:BAABLAAFFH8IAAILAAgInAnsCgDVAQALAAgInAnsCgDVAQAAAA==.',['肥猫']='肥猫不是猫:BAAALAADCgMIAwAAAA==.',['自爆']='自爆卡车:BAAALAAECgUIBQAAAA==.',['良辰']='良辰美景久:BAAALAAFFAIIAgAAAA==.',['艾因']='艾因利奇曼:BAAALAAECgYIBwAAAA==.',['花若']='花若笑颜:BAACLAAFFH8KAAIVAAMIWheDFgDzAAAVAAMIWheDFgDzAAAsAAQKfxQAAhUACAg4GdchAG4CABUACAg4GdchAG4CAAAA.',['苏小']='苏小鈂:BAAALAADCgMIAwAAAA==.',['苏谨']='苏谨言:BAAALAADCggIEAAAAA==.',['莫决']='莫决:BAAALAAECggIDwAAAA==.',['莫小']='莫小莫:BAAALAAECgYIBgAAAA==.',['莱纳']='莱纳的板凳:BAAALAADCggICAAAAA==.',['莱莉']='莱莉尔织炎:BAAALAAECgYIEgAAAA==.',['菲涅']='菲涅希尔:BAAALAADCgYIBgAAAA==.',['落羽']='落羽:BAAALAAECgUIBQAAAA==.',['蒼天']='蒼天哥:BAABLAAFFH8IAAIIAAIIExoQRwCZAAAIAAIIExoQRwCZAAAAAA==.',['蓝萦']='蓝萦傲魂:BAAALAAFFAIIAgAAAA==.',['虎牙']='虎牙妹妹:BAAALAAECgQIAwAAAA==.',['蜜桃']='蜜桃芝芝:BAAALAAECgMIAwAAAA==.',['蝎子']='蝎子奈奈:BAABLAAFFH8FAAITAAII7QjNEwCKAAATAAII7QjNEwCKAAAAAA==.',['血红']='血红的雨:BAAALAAECgEIAQAAAA==.',['血蹄']='血蹄的二舅:BAABLAAFFH8GAAIOAAMIyw2KTACDAAAOAAMIyw2KTACDAAAAAA==.',['街角']='街角的巳时:BAACLAAFFH8KAAIDAAIIHhXqSgBOAAADAAIIHhXqSgBOAAAsAAQKfxUAAwMACAhBFKtJAD0BAAMACAhBFKtJAD0BAAoAAQhkC7RqACkAAAAA.',['裂人']='裂人美女:BAAALAAECgQIBAAAAA==.',['西门']='西门大官人:BAAALAAECgEIAQAAAA==.',['覺遠']='覺遠:BAAALAAECgMIAwAAAA==.',['誓潮']='誓潮者云霆:BAAALAAFFAIIBAAAAA==.',['诗酒']='诗酒流觞:BAAALAADCgcIBwABLAAFFAgICQAIAIYPAA==.',['请叫']='请叫我纯白:BAAALAADCgEIAQAAAA==.',['诸葛']='诸葛不发愁:BAAALAAECgYIBwAAAA==.',['谁说']='谁说我不发愁:BAAALAAECgQIBAAAAA==.',['貌美']='貌美肤白:BAAALAAECggICgAAAA==.',['貘螺']='貘螺:BAAALAAECgYIBgAAAA==.',['贝拉']='贝拉露娜:BAABLAAFFH8iAAMhAAYIggk1FAABAQAhAAYIggk1FAABAQAeAAIIRANyFwBqAAAAAA==.',['贪睡']='贪睡的玲珑:BAAALAAECgcICAAAAA==.',['躲一']='躲一下别吃了:BAABLAAFFH8KAAIUAAIIeRA+KgBCAAAUAAIIeRA+KgBCAAAAAA==.',['转一']='转一下别毛了:BAABLAAFFH8LAAITAAII9BkdEQCVAAATAAII9BkdEQCVAAAAAA==.',['辛娜']='辛娜:BAAALAADCgIIAgAAAA==.',['达秀']='达秀:BAABLAAFFH8GAAIbAAIIAhqmCgC2AAAbAAIIAhqmCgC2AAAAAA==.',['迅捷']='迅捷女友缰绳:BAABLAAECn8UAAMWAAYIIB0SSgCNAQANAAYI/xf5rwCVAQAWAAYIbxcSSgCNAQAAAA==.',['这你']='这你受的了吗:BAAALAAECgYIEgAAAA==.',['迷茫']='迷茫的雪:BAAALAADCgYIBgAAAA==.',['逆转']='逆转风车:BAABLAAFFH8HAAIBAAIInxDUfwCHAAABAAIInxDUfwCHAAAAAA==.',['选择']='选择随机:BAAALAAECgcIBwAAAA==.',['逍遥']='逍遥淡如烟:BAAALAAFFAIIAgAAAA==.逍遥遥:BAABLAAFFH8zAAMHAAYIRiCcDAD2AQAHAAYIXR+cDAD2AQAPAAUIMhUoDQDxAAAAAA==.',['逐光']='逐光之影:BAABLAAFFH8QAAIKAAUIZQYyCgCnAAAKAAUIZQYyCgCnAAABLAAFFAUIEwAYAN8MAA==.',['逸先']='逸先轩:BAAALAAFFAIIAgAAAA==.',['道特']='道特不断:BAAALAADCggICAAAAA==.',['遺忘']='遺忘的戰場:BAAALAADCgYIBgAAAA==.',['邪恶']='邪恶流行:BAAALAAFFAIIBAAAAA==.',['鄂尔']='鄂尔多斯丶沁:BAAALAAECgYIBgAAAA==.',['酷酷']='酷酷的藤:BAAALAAECgYIEgAAAA==.',['阻丶']='阻丶王:BAABLAAECn8WAAIBAAgI6R7tYAA0AgABAAgI6R7tYAA0AgAAAA==.',['阿二']='阿二三四:BAAALAAECgYIBQAAAA==.',['阿比']='阿比盖尔:BAACLAAFFH8jAAIPAAYIHxt1DAB6AQAPAAYIHxt1DAB6AQAsAAQKfx8AAg8ACAh/IhMIAFYCAA8ACAh/IhMIAFYCAAAA.',['阿沐']='阿沐斯:BAACLAAFFH8PAAQVAAUI5A19KQDgAAAVAAQIlgt9KQDgAAAUAAIITwiKIQB6AAAgAAIIJwmpBgBNAAAsAAQKfxYAAxQABwimG/QYAIQBABQABgi4HfQYAIQBABUABQjNCvGQANEAAAAA.',['阿莉']='阿莉塞:BAAALAAECgcIBwAAAA==.',['陌小']='陌小四:BAAALAAFFAIIBAAAAA==.',['随敌']='随敌丶大小变:BAABLAAECn8XAAQMAAcI3wkGqADEAAAMAAcI3wkGqADEAAAiAAYIhAsPGQC/AAAEAAII4gR1pABGAAAAAA==.',['雅思']='雅思:BAAALAAECgQIBAAAAA==.',['雨天']='雨天丶:BAABLAAFFH8GAAIBAAYI8QywPABIAQABAAYI8QywPABIAQAAAA==.',['雨落']='雨落花开:BAAALAAFFAIIAgAAAA==.',['雪莉']='雪莉酒丶:BAABLAAFFH8KAAIFAAYIOQ5MCgBsAQAFAAYIOQ5MCgBsAQAAAA==.',['雷电']='雷电法王:BAAALAADCgUIBQAAAA==.',['雾以']='雾以泪聚:BAAALAAECgMIBAAAAA==.',['青丹']='青丹:BAAALAADCgIIAgAAAA==.',['青涩']='青涩后妈:BAACLAAFFH8GAAICAAIIcwQcNwB3AAACAAIIcwQcNwB3AAAsAAQKfxsAAgIACAg5F5k4ACQCAAIACAg5F5k4ACQCAAAA.',['面无']='面无暇:BAACLAAFFH8kAAMNAAYIqhdNWADqAAANAAQIrBRNWADqAAAWAAQI4hLoDgCLAAAsAAQKfxUAAxYACAiyHSAXAOoAAA0ABAiJHGe4APgAABYABwgtFyAXAOoAAAAA.',['韩寒']='韩寒:BAAALAAECgYICwAAAA==.',['颜丶']='颜丶辰洋:BAABLAAECn8VAAMNAAYI/xekjwAwAQANAAYI/xekjwAwAQAWAAEIhg+lxQAqAAAAAA==.',['风云']='风云百合:BAACLAAFFH8IAAIZAAIIexXyFgBBAAAZAAIIexXyFgBBAAAsAAQKfxgAAhkABwgwHJsrANMBABkABwgwHJsrANMBAAAA.',['风儿']='风儿:BAAALAADCgcIBwAAAA==.',['风雪']='风雪夜归人丶:BAAALAAFFAIIBAAAAA==.',['风骚']='风骚的小猎:BAAALAAECgIIAgAAAA==.',['飞扬']='飞扬的旋律:BAAALAAFFAIIBAAAAA==.',['飞机']='飞机坐乌鸦:BAAALAAECgQIBAAAAA==.',['饿殍']='饿殍:BAAALAAECgYIEgAAAA==.',['首席']='首席奥术师娘:BAAALAAECgMIAwAAAA==.',['骗你']='骗你的鹿:BAAALAAFFAIIAgAAAA==.',['鬼神']='鬼神狂杀:BAAALAAFFAIIAgAAAA==.',['魂守']='魂守恐怖利刃:BAAALAAECgYIDAAAAA==.',['魂小']='魂小殇:BAACLAAFFH8GAAIYAAII3htmVgBNAAAYAAII3htmVgBNAAAsAAQKfyMAAhgABgjNIfY9AEICABgABgjNIfY9AEICAAAA.',['魔一']='魔一圣骑:BAAALAAECgMIAwAAAA==.魔一尐獵:BAAALAAECgMIAwAAAA==.',['魔神']='魔神斩月:BAAALAADCgcIBwAAAA==.',['鹰哥']='鹰哥:BAAALAAFFAMIBAAAAA==.',['鹰歌']='鹰歌弓:BAAALAAECgUIBQAAAA==.',['鹿逸']='鹿逸:BAABLAAFFH8FAAIiAAMI5wl8BQCXAAAiAAMI5wl8BQCXAAAAAA==.',['黄色']='黄色飞灰:BAAALAAFFAIIBAAAAA==.',['黄金']='黄金梅利:BAAALAAECgYICwAAAA==.',['黑钻']='黑钻会员:BAAALAADCgYIBgAAAA==.',['黒榊']='黒榊丨目瀧灬:BAAALAAFFAIIAgAAAA==.',['默兪']='默兪褬:BAAALAAECgMIAwAAAA==.',['龘龖']='龘龖灬哲:BAABLAAFFH8HAAMWAAMI1BKRHwCLAAAWAAIINBSRHwCLAAANAAMIUA/vcAB/AAAAAA==.',['龙芬']='龙芬宝贝兮若:BAAALAAECgMIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end