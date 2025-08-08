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
 local lookup = {'DeathKnight-Blood','Evoker-Devastation','DeathKnight-Frost','DeathKnight-Unholy','Warlock-Affliction','Warlock-Destruction','Shaman-Restoration','Hunter-Marksmanship','Mage-Fire','Paladin-Retribution','Paladin-Protection','Mage-Arcane','Mage-Frost','Priest-Discipline','Priest-Holy','Hunter-BeastMastery','Warlock-Demonology','Druid-Balance','Warrior-Fury','Shaman-Elemental','Monk-Mistweaver','Monk-Windwalker','Rogue-Assassination','Warrior-Protection','Priest-Shadow','DemonHunter-Havoc','DemonHunter-Vengeance','Hunter-Survival','Paladin-Holy','Monk-Brewmaster','Unknown-Unknown','Druid-Guardian','Druid-Restoration','Warrior-Arms','Evoker-Preservation','Shaman-Enhancement',}; local provider = {region='CN',realm='卡德加',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aimerl:BAACKgAFFH8JAAIBAAIIIgRoJwApAAABAAIIIgRoJwApAAAqAAQKfxYAAgEACAjSBmA/AMIAAAEACAjSBmA/AMIAAAAA.',Ak='Akoasm:BAAAKgAECgcIBwAAAA==.',Al='Alance:BAAAKgAFFAgIBAABKgAFFAgIEAACAIsNAA==.',Ar='Artanis:BAAAKgAECgIIAgAAAA==.',Bl='Blacklagoon:BAAAKgAFFAIIAwAAAA==.',Ca='Caningvale:BAAAKgAECgIIAgAAAA==.Cardi:BAAAKgADCggICAAAAA==.Cathy:BAAAKgAFFAQIBAAAAA==.',Ck='Cklove:BAACKgAFFH8FAAMDAAMIXwr9DACpAAADAAMIIAr9DACpAAAEAAEI5APTMgA+AAAqAAQKfxoAAgMACAjDG5wHAEcCAAMACAjDG5wHAEcCAAAA.',Cl='Clytze:BAAAKgADCggICQAAAA==.',Co='Codey:BAAAKgAECggICgAAAA==.',Cr='Crazystart:BAAAKgAECggIDQAAAA==.',Da='Darkdream:BAAAKgAECgQIBAAAAA==.Darker:BAABKgAFFH8HAAMFAAMIjQMaFwCFAAAFAAMIcAMaFwCFAAAGAAEIxwP0OQAsAAAAAA==.',Dd='Ddad:BAABKgAFFH8GAAIGAAYIkR15EgB0AQAGAAYIkR15EgB0AQAAAA==.',De='Defendh:BAAAKgAFFAYIBAAAAA==.',Dh='Dh:BAAAKgAECggICAAAAA==.',Dr='Drance:BAABKgAFFH8QAAICAAgIiw3YCADYAQACAAgIiw3YCADYAQAAAA==.Dreamna:BAACKgAFFH8KAAIHAAMIoCFGGgAWAQAHAAMIoCFGGgAWAQAqAAQKfxoAAgcACAiBI90HALcCAAcACAiBI90HALcCAAAA.',Ea='Earnest:BAAAKgADCggICAAAAA==.',Ec='Ecstay:BAAAKgAECgMIAwAAAA==.',En='Eno:BAABKgAFFH8IAAIIAAgIFhxyBAA/AgAIAAgIFhxyBAA/AgAAAA==.',Fa='Fann:BAAAKgAECggICAAAAA==.',Gs='Gswchampion:BAAAKgADCgEIAQAAAA==.',Hy='Hykd:BAABKgAFFH8GAAIJAAYInAt+EABBAQAJAAYInAt+EABBAQAAAA==.',Im='Imfool:BAABKgAECn8bAAIKAAgIZSAoPAA6AgAKAAgIZSAoPAA6AgAAAA==.',Is='Iscandar:BAAAKgADCgIIAgAAAA==.',Jo='Jolin:BAACKgAFFH8IAAMLAAYIFRDKEQDxAAALAAYImAzKEQDxAAAKAAEIMh7CTwBIAAAqAAQKfy0AAwoACAgrJAkbAKwCAAoACAgrJAkbAKwCAAsAAQgVBIVqABAAAAAA.',Lo='Long:BAABKgAFFH8KAAICAAYIcxKTDQBKAQACAAYIcxKTDQBKAQAAAA==.Lopsy:BAAAKgAFFAIIAgAAAA==.',Ma='Magiclove:BAAAKgAECgUIBwAAAA==.Magicloveu:BAABKgAFFH8kAAQMAAQIGh6aHgDxAAAMAAQIUxmaHgDxAAANAAMIlhQ/FgCDAAAJAAEIQwYePwA7AAAAAA==.',Mi='Mikasa:BAAAKgAECggICAAAAA==.',Ne='Newlovet:BAACKgAFFH8KAAMOAAUIYBUyDABTAQAOAAUIBhMyDABTAQAPAAII/A9sGgB9AAAqAAQKfxYAAw8ABggQGYJBADMBAA8ABggQGYJBADMBAA4ABAgyEANmAJEAAAAA.',Ni='Nicovega:BAABKgAFFH8IAAIEAAgIbB9zAgCuAgAEAAgIbB9zAgCuAgAAAA==.',No='Nob:BAAAKgAECgcIBwAAAA==.',Oo='Ooqvo:BAABKgAECn8wAAIKAAgIlyDrMQBaAgAKAAgIlyDrMQBaAgAAAA==.',Pa='Patriarch:BAABKgAFFH8HAAIJAAYIiRfGCgCLAQAJAAYIiRfGCgCLAQAAAA==.',Ph='Phantom:BAAAKgADCgQIBAAAAA==.',Re='Revenant:BAAAKgADCgEIAQAAAA==.',Sh='Shayulajiao:BAAAKgAFFAQIBAAAAA==.',Si='Sindorin:BAAAKgAECgYIBwAAAA==.',St='Stan:BAACKgAFFH8IAAIQAAMIAxBmPACrAAAQAAMIAxBmPACrAAAqAAQKfyEAAhAACAj4HkAbAF0CABAACAj4HkAbAF0CAAAA.',Sw='Swordnewnew:BAAAKgAECgEIAQAAAA==.',Te='Teer:BAAAKgADCggICAAAAA==.',Ti='Tiaralyouyou:BAAAKgADCgcIBwAAAA==.Tiaralyoyqs:BAAAKgAFFAQIAQABKgAFFAgICAAQAHMNAA==.Tinabranford:BAABKgAFFH8IAAIEAAQIaxevEAD2AAAEAAQIaxevEAD2AAAAAA==.',Ts='Tsyy:BAAAKgAECgYIBgAAAA==.',Wa='Wakeoverlxrd:BAAAKgAFFAIIBAAAAA==.Wasurete:BAAAKgAECggICAAAAA==.',Wh='Whirlwind:BAAAKgAECgIIAgAAAA==.',Xi='Xiaojian:BAAAKgADCggICwAAAA==.',Xx='Xxbuoduoyeje:BAAAKgAECgQIBAAAAA==.Xxmeinaiaque:BAAAKgADCggICwAAAA==.Xxshaowen:BAAAKgAECgEIAQAAAA==.Xxzhengxxwen:BAAAKgAECgYICwAAAA==.Xxzhengzheng:BAAAKgAECgMIAwAAAA==.',Ya='Yaice:BAAAKgADCgcIBwAAAA==.',Yx='Yxl:BAABKgAFFH8JAAIRAAMIfgcZEwCpAAARAAMIfgcZEwCpAAAAAA==.',['一会']='一会儿让你哭:BAAAKgAECgMIAwAAAA==.',['一剑']='一剑终情:BAAAKgAECgEIAQAAAA==.',['一只']='一只小麦兜:BAABKgAFFH8IAAIMAAgIbhjKBgAYAgAMAAgIbhjKBgAYAgAAAA==.',['一叶']='一叶轻舟:BAAAKgAECgMIAwAAAA==.',['一度']='一度红尘:BAAAKgADCggICAAAAA==.',['一无']='一无敌一:BAAAKgAFFAgIBAAAAA==.',['一百']='一百斤包吃喝:BAAAKgAECggIBwAAAA==.',['一赌']='一赌天下:BAAAKgADCgMIAwAAAA==.',['一起']='一起哈啤:BAAAKgAFFAQIBAAAAA==.',['一鬼']='一鬼厉一:BAABKgAFFH8KAAILAAIItQMNKQBHAAALAAIItQMNKQBHAAAAAA==.',['七精']='七精灵:BAABKgAFFH8KAAIKAAgINQeuDwCmAQAKAAgINQeuDwCmAQAAAA==.',['三国']='三国志:BAAAKgAECgcICAAAAA==.',['三宝']='三宝乐:BAAAKgAECggICAAAAA==.',['三氧']='三氧化二铁:BAAAKgADCgIIAgAAAA==.',['三色']='三色堇:BAAAKgAECgMIBAAAAA==.',['上帝']='上帝九禁区:BAAAKgAECgcICwAAAA==.',['上海']='上海:BAAAKgAECgEIAQAAAA==.',['不准']='不准跪:BAABKgAFFH8MAAISAAMIRREhOQC+AAASAAMIRREhOQC+AAAAAA==.',['不必']='不必意兴阑珊:BAAAKgAECgMIBgAAAA==.',['不赌']='不赌不为赢:BAAAKgAECgYICgAAAA==.',['专职']='专职卖萌:BAAAKgAECgcIEAAAAA==.',['世一']='世一上陈泽彬:BAAAKgAFFAMIAwAAAA==.',['世纪']='世纪儿:BAAAKgAFFAQIBAAAAA==.',['丘处']='丘处机:BAAAKgAECgQIBAAAAA==.',['东京']='东京有点冷:BAAAKgAECgcIBwAAAA==.',['东风']='东风野咿:BAABKgAFFH8MAAMFAAgICRfwAAAWAgAFAAcIbBjwAAAWAgAGAAQIHguPHQAbAQAAAA==.',['丨二']='丨二妞丨:BAAAKgAECggIEwAAAA==.',['丨傀']='丨傀丨:BAAAKgAECgcIEQAAAA==.',['丨在']='丨在丨丨劫丨:BAABKgAECn8VAAIKAAgIhRKDagCEAQAKAAgIhRKDagCEAQAAAA==.丨在丨劫丨:BAAAKgADCgEIAQAAAA==.',['丨小']='丨小鸡丨:BAAAKgAECgYIDQAAAA==.',['丨希']='丨希尔瓦纳斯:BAAAKgADCgYIBgAAAA==.',['丨祈']='丨祈福丨:BAABKgAFFH8KAAMOAAYIrxL8CgBmAQAOAAYIrxL8CgBmAQAPAAQIVgULMQCBAAAAAA==.',['丨風']='丨風丶雲丨:BAABKgAFFH8FAAITAAUINwPMDwD3AAATAAUINwPMDwD3AAAAAA==.',['丶叮']='丶叮叮当当:BAAAKgADCgQIBAAAAA==.',['丶情']='丶情何以堪:BAAAKgAECggICAAAAA==.',['丶疯']='丶疯爆:BAACKgAFFH8SAAIHAAYI3hrnAADJAQAHAAYI3hrnAADJAQAqAAQKfxcAAwcACAj0GNolAPgBAAcACAj0GNolAPgBABQABwjjC6BEABEBAAAA.',['丶茉']='丶茉莉奶绿:BAABKgAFFH8IAAMOAAgI3Q4tCwBiAQAOAAQIlxYtCwBiAQAPAAQIjwTxMQB+AAAAAA==.',['丶薄']='丶薄荷奶绿:BAABKgAFFH8MAAIVAAgIBhQEBwDMAQAVAAgIBhQEBwDMAQAAAA==.',['为了']='为了单刷:BAABKgAECn8zAAIKAAgIsh0oKwBTAgAKAAgIsh0oKwBTAgAAAA==.',['丿壹']='丿壹瓶丨盖:BAAAKgAECggICAAAAA==.',['丿断']='丿断罪丶:BAAAKgAECgQICAAAAA==.',['久寺']='久寺:BAABKgAFFH8GAAIWAAYIjw8fBwBsAQAWAAYIjw8fBwBsAQAAAA==.',['么么']='么么菈哚:BAACKgAFFH8WAAIPAAQInBPkEgCrAAAPAAQInBPkEgCrAAAqAAQKfyMAAg8ACAiVHP4VACMCAA8ACAiVHP4VACMCAAAA.',['乌鸦']='乌鸦:BAAAKgAECgQIBAAAAA==.',['二月']='二月半:BAAAKgAECgMIAwAAAA==.',['云中']='云中鶴:BAABKgAECn84AAIVAAgIFByREAAWAgAVAAgIFByREAAWAgAAAA==.',['互联']='互联网混子:BAACKgAFFH8hAAIXAAQIGhWyDQDLAAAXAAQIGhWyDQDLAAAqAAQKfysAAhcACAjBExgaALYBABcACAjBExgaALYBAAAA.',['亡之']='亡之抗争:BAAAKgADCgIIAgAAAA==.',['亡法']='亡法至尊:BAAAKgAECgcIBwAAAA==.',['京城']='京城飞爷:BAAAKgAECggICAAAAA==.',['人与']='人与兽爱:BAAAKgADCggICAAAAA==.',['人见']='人见人爱:BAAAKgADCggICAAAAA==.',['什么']='什么名字矫情:BAACKgAFFH8ZAAIGAAQI4BVwEgDbAAAGAAQI4BVwEgDbAAAqAAQKfxwAAwYACAhnIBIRAGICAAYACAhnIBIRAGICAAUAAQhuDvZEADYAAAAA.',['伊利']='伊利达雷之刃:BAAAKgAFFAIIAgAAAA==.',['伊沙']='伊沙:BAAAKgAFFAQIBAAAAA==.',['伊莎']='伊莎柏拉:BAAAKgADCgUIBQAAAA==.',['休闲']='休闲自由人生:BAABKgAFFH8GAAIKAAYIcRZ1HQB9AQAKAAYIcRZ1HQB9AQAAAA==.',['低调']='低调大毛:BAABKgAFFH8GAAIEAAYIVwrIFgDcAAAEAAYIVwrIFgDcAAAAAA==.',['佐佐']='佐佐佑:BAACKgAFFH8QAAITAAYI2RKhBQBAAQATAAYI2RKhBQBAAQAqAAQKfxcAAxMACAhNGskmAKUBABMACAg9GskmAKUBABgACAg/EQ4bAF8BAAAA.',['体积']='体积小躲技能:BAAAKgAECggICAAAAA==.',['你干']='你干嘛哎哟:BAAAKgAFFAQIBAAAAA==.',['你那']='你那边:BAAAKgADCgcIBwAAAA==.',['來生']='來生緣:BAABKgAFFH8OAAIMAAgIshlEDACjAQAMAAgIshlEDACjAQAAAA==.',['便便']='便便王便便王:BAAAKgAECgcIDwAAAA==.',['倒掉']='倒掉鸟:BAAAKgAFFAEIAQAAAA==.',['倒霉']='倒霉的铁锤:BAABKgAECn8WAAIKAAgIiRxpTQAKAgAKAAgIiRxpTQAKAgAAAA==.',['假装']='假装丶男爵:BAAAKgADCgEIAQAAAA==.',['傲慢']='傲慢的月亮:BAABKgAFFH8OAAMMAAgILSB2BQA+AgAMAAgIEyB2BQA+AgANAAQIaR9SCwATAQAAAA==.',['元素']='元素主宰者:BAAAKgADCggICAAAAA==.元素使丶狐涂:BAAAKgADCgIIAgAAAA==.',['克雷']='克雷多斯:BAAAKgADCgIIAgAAAA==.',['八重']='八重樱:BAAAKgADCggICAAAAA==.',['兰奇']='兰奇:BAAAKgAECgcIBwAAAA==.',['冬夏']='冬夏:BAABKgAFFH8IAAMRAAgItBkCBAA4AQARAAUIMx4CBAA4AQAGAAMIthPFJgDXAAAAAA==.',['冰王']='冰王子妮可:BAAAKgAFFAgIBAAAAA==.',['刘凤']='刘凤芝:BAAAKgAECgQIBAAAAA==.',['剩歧']='剩歧视:BAAAKgAECgcIEwAAAA==.',['力之']='力之神:BAAAKgADCgQIBgAAAA==.',['加加']='加加布鲁跟:BAAAKgAFFAgIAwAAAA==.',['劫数']='劫数来临:BAABKgAFFH8IAAIGAAgIoRj8AwBNAgAGAAgIoRj8AwBNAgAAAA==.',['北方']='北方秀倦收天:BAAAKgADCgcIBwAAAA==.',['北极']='北极熊猫:BAAAKgAECgEIAQAAAA==.',['北燕']='北燕奎宿:BAAAKgAECgUIBQAAAA==.',['卟想']='卟想早睡:BAAAKgAECggIAgAAAA==.',['占戈']='占戈灬云鬼:BAABKgAECn88AAITAAgI4iGuEQB5AgATAAgI4iGuEQB5AgAAAA==.',['卡卡']='卡卡东森赛:BAABKgAFFH8SAAMQAAgITR7rBABXAgAQAAgITR7rBABXAgAIAAQIyh3bCQD6AAAAAA==.卡卡乱窜:BAAAKgAECgQIBAAAAA==.',['卷物']='卷物:BAABKgAFFH8HAAIGAAQIhw1XIwDtAAAGAAQIhw1XIwDtAAAAAA==.',['双劫']='双劫:BAABKgAECn8YAAMTAAgI/Q2bMwCzAQATAAgI/Q2bMwCzAQAYAAgIiQjMIAD8AAAAAA==.',['双马']='双马尾加速:BAABKgAFFH8GAAMPAAYIbR49DgBFAQAPAAUI6xw9DgBFAQAZAAEIuwtfLABDAAABKgAFFAgICAAPALsjAA==.',['变变']='变变:BAAAKgAFFAQIBAAAAA==.',['只会']='只会寒冰箭:BAABKgAECn8bAAINAAgIbgipGgDuAAANAAgIbgipGgDuAAAAAA==.',['叫我']='叫我楼子哥:BAABKgAFFH8IAAIIAAgIsQrBCAClAQAIAAgIsQrBCAClAQAAAA==.',['叫沃']='叫沃四七七:BAAAKgAECgUIBwAAAA==.',['可乐']='可乐椒麻鸡:BAAAKgAFFAEIAQAAAA==.',['可樂']='可樂加檸檬:BAABKgAFFH8GAAIKAAYIlBdIIABvAQAKAAYIlBdIIABvAQAAAA==.',['右腕']='右腕:BAAAKgAECgIIAgAAAA==.',['叶子']='叶子酱:BAAAKgAECgcIDAAAAA==.',['吃早']='吃早餐呀:BAAAKgAECgYIBgAAAA==.',['各自']='各自丶远扬:BAAAKgADCggICAAAAA==.',['名門']='名門之戰:BAABKgAFFH8JAAIKAAMIDhN3UADPAAAKAAMIDhN3UADPAAAAAA==.',['吐奶']='吐奶喵:BAAAKgAECgcIBwAAAA==.',['君焱']='君焱:BAABKgAFFH8MAAMaAAQIVRkKEwD0AAAaAAQIVRkKEwD0AAAbAAQIPAUWDwCIAAAAAA==.',['吴莫']='吴莫愁丶:BAAAKgAFFAQIBAAAAA==.',['呆呆']='呆呆丶:BAAAKgAECgUIBQAAAA==.呆呆崽:BAAAKgAECggIDAAAAA==.呆呆酱:BAABKgAECn8WAAMQAAgIIxJ7KgAqAQAQAAUI7Bd7KgAqAQAIAAgIGwr6WgDoAAABKgAFFAgICAAQABcdAA==.呆呆酱丶:BAAAKgAECgcIBwAAAA==.',['命运']='命运使者:BAACKgAFFH8PAAIHAAMIgAuBOwCXAAAHAAMIgAuBOwCXAAAqAAQKfywAAgcACAgWFxs4AKYBAAcACAgWFxs4AKYBAAAA.',['咕噜']='咕噜猎猎:BAAAKgAECgMIAwAAAA==.',['咪神']='咪神:BAAAKgAECggICAAAAA==.',['哈哈']='哈哈刀哈哈:BAAAKgAFFAMIAwAAAA==.',['哈彼']='哈彼国:BAACKgAFFH8FAAMcAAIIUQptAwBoAAAIAAIIcwiwHgB+AAAcAAIIRgdtAwBoAAAqAAQKfx0AAwgACAgMFLgzAI0BAAgACAiME7gzAI0BABwABQgeFIgSAMEAAAAA.',['哥战']='哥战无不胜:BAAAKgAECggIEQAAAA==.',['唐诗']='唐诗嵩词:BAABKgAFFH8IAAMMAAcIOg5UDgBUAQAMAAQIxBJUDgBUAQANAAQIqgXQHQCWAAAAAA==.',['商博']='商博良:BAACKgAFFH8GAAILAAYIlBxXGQCtAAALAAYIlBxXGQCtAAAqAAQKfxUAAwoABwgGF0yQAHcBAAoABggHGEyQAHcBAB0ABQi+CCU4AK8AAAEqAAUUCAgIAAoALyMA.',['單戈']='單戈乂云鬼:BAABKgAECn8fAAISAAgIRx3uIwA3AgASAAgIRx3uIwA3AgAAAA==.',['喵菲']='喵菲斯特:BAAAKgADCggICAAAAA==.',['嗚咪']='嗚咪:BAACKgAFFH87AAIIAAgIwhZzDQCDAQAIAAgIwhZzDQCDAQAqAAQKf0EAAggACAiFIqoSAGQCAAgACAiFIqoSAGQCAAAA.',['嗜血']='嗜血圣骑:BAAAKgAECggICgAAAA==.',['嗳訫']='嗳訫嚼囉灬泡:BAABKgAFFH8GAAIGAAYI+wq5GgAwAQAGAAYI+wq5GgAwAQAAAA==.',['嗳马']='嗳马仕:BAAAKgAECgcIEgAAAA==.',['四十']='四十多个女生:BAACKgAFFH8IAAIQAAMItw2wNADAAAAQAAMItw2wNADAAAAqAAQKfyQAAxAACAh/FFs7ALcBABAACAh/FFs7ALcBAAgABwjZCQxjAM0AAAAA.',['因吹']='因吹斯听:BAAAKgAFFAQIBAAAAA==.',['圣之']='圣之浪漫:BAAAKgAFFAgIBAAAAA==.',['圣光']='圣光干脆面:BAAAKgAECgYIBgAAAA==.圣光忽悠你们:BAABKgAFFH8IAAIKAAQIMCLVPAD7AAAKAAQIMCLVPAD7AAAAAA==.圣光蝎:BAAAKgADCggICQAAAA==.',['圣徒']='圣徒犹大:BAAAKgAECgYIEQAAAA==.',['地狱']='地狱火灬:BAAAKgAFFAEIAQAAAA==.',['坟头']='坟头上抽筋:BAAAKgADCgIIAgAAAA==.',['墨焰']='墨焰:BAAAKgADCggICAAAAA==.',['墨魇']='墨魇:BAACKgAFFH8JAAIBAAQIwgIRHgBsAAABAAQIwgIRHgBsAAAqAAQKfygAAgEACAhaB6s4AOMAAAEACAhaB6s4AOMAAAAA.',['壹东']='壹东:BAAAKgAECgcIDwAAAA==.',['夏天']='夏天丶:BAAAKgAFFAMIAwAAAA==.',['夜游']='夜游宫:BAACKgAFFH8NAAMYAAIIyQ6JCQB2AAAYAAIIyQ6JCQB2AAATAAEIwQGLLwA0AAAqAAQKfxoAAxgACAjAEx0TAJABABgACAgXEx0TAJABABMAAQgpDmyJAEgAAAAA.',['夢里']='夢里婲落丶:BAAAKgADCgIIAgAAAA==.',['大圈']='大圈豹:BAABKgAFFH8OAAIHAAgIkhW0CgCcAQAHAAgIkhW0CgCcAQAAAA==.',['大漠']='大漠孤鹏:BAAAKgADCggICAAAAA==.',['大熊']='大熊二号:BAAAKgADCggICAAAAA==.',['大羅']='大羅洞觀:BAAAKgAFFAIIAgAAAA==.',['大肠']='大肠刺身:BAAAKgAECgQIBAAAAA==.',['大角']='大角顶顶:BAAAKgAECgUIBQAAAA==.',['大铁']='大铁:BAAAKgAECgYIBgAAAA==.',['大魔']='大魔导士:BAACKgAFFH8GAAIKAAYIqhfNIQBmAQAKAAYIqhfNIQBmAQAqAAQKfxwAAgoACAjJGKsYAAACAAoACAjJGKsYAAACAAAA.大魔王:BAAAKgAECgQIBAAAAA==.',['天丛']='天丛云:BAABKgAFFH8MAAIeAAYIng0vAQAyAQAeAAYIng0vAQAyAQABKgAFFAgIDAAVAAYUAA==.',['天使']='天使刺:BAAAKgAECggIDAAAAA==.',['天火']='天火:BAAAKgADCggICgAAAA==.',['天魔']='天魔下凡尘:BAAAKgADCgEIAQAAAA==.',['头发']='头发乱了灬:BAAAKgAFFAIIAgAAAA==.',['奇怪']='奇怪的萨满:BAAAKgADCgIIAgAAAA==.',['奈何']='奈何一笑:BAAAKgADCggIDwAAAA==.',['契音']='契音:BAAAKgAECgQIBAAAAA==.',['奥妮']='奥妮:BAABKgAFFH8GAAIJAAYILxLMBgCXAQAJAAYILxLMBgCXAQAAAA==.奥妮奥妮:BAABKgAFFH8IAAMdAAQItwW7CwClAAAdAAQItwW7CwClAAALAAQIYhUnGwCgAAAAAA==.',['奶小']='奶小骑:BAABKgAFFH8KAAILAAgI0RN2BgC8AQALAAgI0RN2BgC8AQAAAA==.',['奶萨']='奶萨:BAAAKgAECgcIEgAAAA==.',['姬兒']='姬兒强:BAAAKgAECgUICAAAAA==.',['季末']='季末的花絮:BAAAKgAECgMIAwAAAA==.',['孤独']='孤独的大灰狼:BAAAKgAECggICAAAAA==.',['安度']='安度因的情人:BAAAKgAFFAYIAwAAAA==.',['定喘']='定喘你的肺:BAABKgAFFH8GAAILAAYI3RO5FQDKAAALAAYI3RO5FQDKAAAAAA==.',['宝多']='宝多六花呀:BAAAKgADCggICAAAAA==.',['寂寞']='寂寞的老狼:BAAAKgADCgEIAQAAAA==.',['寂零']='寂零丶:BAAAKgAECgcIBwAAAA==.',['寒绫']='寒绫:BAABKgAFFH8KAAMOAAMItyClEQAQAQAOAAMIJCClEQAQAQAPAAEIeiEfIABZAAAAAA==.',['寻找']='寻找火星的你:BAABKgAFFH8IAAIJAAQI/CEZGgDYAAAJAAQI/CEZGgDYAAABKgAFFAgIDgAJAMMiAA==.',['射射']='射射丶就会了:BAAAKgAFFAQIBAAAAA==.',['小七']='小七:BAAAKgAECgIIAgAAAA==.',['小三']='小三丶:BAABKgAFFH8IAAIdAAgIZhr9AQA+AgAdAAgIZhr9AQA+AgAAAA==.',['小宝']='小宝的洋娃娃:BAAAKgAECgMIAwAAAA==.',['小小']='小小的也很乖:BAAAKgAECgUIBgAAAA==.',['小水']='小水冰冰凉:BAAAKgAFFAMIAwAAAA==.',['小泡']='小泡芙:BAAAKgADCggICAABKgADCggIGAAfAAAAAA==.',['小灰']='小灰兔:BAAAKgAECgIIAgAAAA==.',['小爆']='小爆牙:BAABKgAFFH8UAAIHAAMIaROyNQCnAAAHAAMIaROyNQCnAAAAAA==.',['小珊']='小珊:BAAAKgADCggIDAAAAA==.',['小豆']='小豆鹌鹑:BAAAKgAECgYIBgAAAA==.',['小鞭']='小鞭炮:BAABKgAFFH8KAAIKAAUIOxTFMwAaAQAKAAUIOxTFMwAaAQAAAA==.',['小鬼']='小鬼的奶妈:BAACKgAFFH8TAAIgAAMIYxBeAwCLAAAgAAMIYxBeAwCLAAAqAAQKfysAAiAACAhsF8ANAMoBACAACAhsF8ANAMoBAAAA.',['少女']='少女乐队呐喊:BAAAKgADCggICAAAAA==.少女乐队哭泣:BAAAKgADCggICAAAAA==.',['少少']='少少甜:BAAAKgAFFAQIBAAAAA==.',['少爷']='少爷:BAAAKgAECggICAAAAA==.',['就知']='就知道吃土:BAAAKgAFFAQIBAABKgAFFAgIDgAWANAQAA==.',['尼克']='尼克狐尼克:BAAAKgAECgUIBwAAAA==.',['尼奥']='尼奥罗萨:BAAAKgADCgQIBAAAAA==.尼奥羅萨:BAAAKgADCgEIAQAAAA==.',['屠戮']='屠戮苍生:BAAAKgAECggICAAAAA==.',['山中']='山中一老仙:BAAAKgAFFAMIAwAAAA==.',['巨狰']='巨狰狞:BAAAKgAFFAgIAQAAAA==.',['已逝']='已逝的六月:BAABKgAECn8dAAIdAAgI7xRQGQCeAQAdAAgI7xRQGQCeAQAAAA==.',['布拉']='布拉德崩:BAAAKgADCggICAAAAA==.',['帕丁']='帕丁顿熊:BAABKgAFFH8MAAMSAAYIyhkIDQCqAQASAAYIyhkIDQCqAQAhAAIIwQguOgAwAAAAAA==.',['平天']='平天大聖:BAAAKgAECggIAgAAAA==.',['幻化']='幻化之刃:BAAAKgAECgMIAwAAAA==.',['幽默']='幽默小黄人:BAAAKgAECggIEgAAAA==.',['开心']='开心网丶:BAAAKgAFFAQIBAAAAA==.开心贰壹七:BAAAKgADCgIIAgAAAA==.',['开摆']='开摆:BAAAKgAFFAIIAwAAAA==.',['开盘']='开盘:BAABKgAFFH8IAAIKAAMIgxmQTADWAAAKAAMIgxmQTADWAAAAAA==.',['强效']='强效炎爆术:BAAAKgADCggICAAAAA==.',['德国']='德国郭德纲:BAABKgAECn8WAAMaAAYIlw1NXwDQAAAaAAYIlw1NXwDQAAAbAAQICgHVawAVAAAAAA==.',['德鲁']='德鲁依术师:BAABKgAFFH8MAAMGAAUIkhDbGwAnAQAGAAUIgAzbGwAnAQARAAIIwAzFEABjAAAAAA==.',['心的']='心的彼方:BAAAKgAFFAQIBAAAAA==.',['快手']='快手诺啊:BAAAKgAECgUICQAAAA==.',['念念']='念念大魔王:BAABKgAFFH8IAAIGAAYIeQ8iGABCAQAGAAYIeQ8iGABCAQABKgAFFAgIFgAGAGsbAA==.',['怎么']='怎么个事儿:BAAAKgAECgUIBwAAAA==.',['怒焰']='怒焰狂袭:BAAAKgAECgIIAgAAAA==.',['急速']='急速卡卡:BAAAKgAECggIDwAAAA==.急速小兜子:BAAAKgAECgIIAgAAAA==.急速萌萌德:BAAAKgAECggICAAAAA==.急速血夜:BAAAKgAECggICgAAAA==.急速风荇:BAABKgAFFH8GAAICAAYIBxqTAQDIAQACAAYIBxqTAQDIAQAAAA==.',['恋爱']='恋爱黑洞:BAAAKgAECgIIAgAAAA==.',['恶灵']='恶灵骑士:BAAAKgADCggIEAAAAA==.',['恶烬']='恶烬:BAABKgAFFH8YAAQEAAcI3xc4CQCfAQAEAAUISho4CQCfAQABAAQIZxMYEgCyAAADAAMIhBJyEQBfAAAAAA==.',['想念']='想念凡尘:BAAAKgADCgYIBAAAAA==.',['慕水']='慕水镜月:BAAAKgADCggICgAAAA==.',['慕灬']='慕灬瑞雪丹青:BAAAKgAFFAUIAwAAAA==.',['我在']='我在奶你瞎吗:BAAAKgAECgEIAQAAAA==.',['我想']='我想吃呷哺:BAAAKgAFFAIIAgAAAA==.',['我手']='我手残丶:BAAAKgAFFAYIBAAAAA==.',['我是']='我是阿姆:BAAAKgAECgYIBwAAAA==.',['戒灵']='戒灵朱庇特:BAAAKgAECgIIAwAAAA==.',['战神']='战神幽雅:BAAAKgAECgUIBQAAAA==.',['戮杀']='戮杀灬神超:BAAAKgADCgUIBQAAAA==.',['抽丶']='抽丶煊赫门:BAAAKgAECgQIBAAAAA==.',['拉人']='拉人要收费的:BAAAKgAECgYIEgAAAA==.',['拉她']='拉她丶左右手:BAABKgAFFH8SAAMGAAgIvBmiBABXAgAGAAgIvBmiBABXAgARAAIIxh0TFwBNAAAAAA==.',['拉某']='拉某奋起反抗:BAAAKgAECggIEgABKgAFFAgIDwAGADgWAA==.',['拉胯']='拉胯水骑:BAAAKgADCgcIBwAAAA==.',['拉面']='拉面炒饭:BAAAKgAECggICgAAAA==.',['掀起']='掀起你的骨头:BAAAKgAECgcIEQAAAA==.',['搖滾']='搖滾怎么了:BAAAKgAECgYIBgAAAA==.',['放學']='放學有种别走:BAAAKgAFFAIIAgABKgAFFAcIBwAKAOcbAA==.',['放开']='放开你的辣条:BAABKgAECn8WAAIKAAcIUA7/qAD9AAAKAAcIUA7/qAD9AAAAAA==.放开俺的辣条:BAAAKgADCgQIBAAAAA==.',['放弃']='放弃速度跑尸:BAAAKgADCggICAAAAA==.',['文明']='文明不如一箭:BAAAKgADCgUIBQAAAA==.',['施巴']='施巴拉谷大师:BAABKgAFFH8GAAIHAAYIDge1GwAQAQAHAAYIDge1GwAQAQAAAA==.',['无敌']='无敌最俊朗:BAABKgAFFH8LAAMNAAQIAAqxDQCvAAANAAQIAAqxDQCvAAAJAAQIVASlMQCEAAABKgAFFAgIDgAMAC0gAA==.',['旭旭']='旭旭宝宝:BAAAKgADCgQIBAAAAA==.',['明日']='明日香:BAABKgAFFH8IAAIMAAgILgeoDQCLAQAMAAgILgeoDQCLAQAAAA==.',['星殒']='星殒丶默旭:BAAAKgAFFAMIAwAAAA==.',['星语']='星语:BAAAKgAFFAIIAgAAAA==.',['晓小']='晓小七:BAAAKgAFFAQIBAAAAA==.',['晓霜']='晓霜天晓:BAAAKgAFFAgIBAAAAA==.',['晕晕']='晕晕嘟:BAABKgAECn8pAAIUAAgIKQ1dPAAdAQAUAAgIKQ1dPAAdAQAAAA==.',['晨曦']='晨曦残月:BAAAKgADCgQIBAAAAA==.',['暗夜']='暗夜之瞳:BAAAKgADCggICAAAAA==.',['暗舞']='暗舞:BAAAKgAECggIDgAAAA==.',['暴富']='暴富:BAABKgAFFH8MAAIHAAQIwhicKADUAAAHAAQIwhicKADUAAAAAA==.',['暴打']='暴打果果:BAABKgAFFH8HAAIKAAcI5xs0CgADAgAKAAcI5xs0CgADAgAAAA==.',['暴走']='暴走安吉娜:BAABKgAFFH8UAAMQAAgI7RsUBgAwAgAQAAgI7RsUBgAwAgAIAAQIVQtiOACVAAAAAA==.',['暴鸷']='暴鸷:BAAAKgAFFAYIAQAAAA==.',['曼哈']='曼哈顿博士:BAABKgAFFH8FAAIWAAUIcw3GDwDnAAAWAAUIcw3GDwDnAAAAAA==.',['曾经']='曾经一米二:BAAAKgADCgIIAgAAAA==.曾经三米二:BAAAKgADCgIIAgAAAA==.曾经两米一:BAABKgAFFH8IAAIQAAYIvhenAwChAQAQAAYIvhenAwChAQAAAA==.',['最後']='最後丶舊時光:BAABKgAFFH8GAAISAAYI8RexEwB+AQASAAYI8RexEwB+AQAAAA==.',['月未']='月未沉:BAABKgAFFH8FAAMVAAUIPxTDGwC/AAAVAAQIPRTDGwC/AAAWAAEI3QLWJwAuAAAAAA==.',['有点']='有点丑:BAAAKgADCggICAAAAA==.有点僵硬:BAABKgAFFH8IAAIKAAgIlwriEADYAQAKAAgIlwriEADYAQAAAA==.',['望江']='望江舟:BAAAKgAECgEIAQAAAA==.',['木碗']='木碗:BAACKgAFFH8IAAIIAAgItRGOBgDqAQAIAAgItRGOBgDqAQAqAAQKfxkAAggACAgDHYQZACwCAAgACAgDHYQZACwCAAAA.木碗三:BAABKgAFFH8IAAIKAAgIQQ2sCwDoAQAKAAgIQQ2sCwDoAQAAAA==.',['未晚']='未晚:BAAAKgAECgEIAQAAAA==.',['朮師']='朮師:BAAAKgAFFAIIBAAAAA==.',['机拿']='机拿个杯:BAAAKgAECgMIAwAAAA==.',['李司']='李司怡:BAAAKgAECgMIBAAAAA==.',['杨了']='杨了二过:BAACKgAFFH8LAAIQAAMIByA8JgDtAAAQAAMIByA8JgDtAAAqAAQKfxkAAhAABghdIa9LANABABAABghdIa9LANABAAAA.',['杰尼']='杰尼杰尼:BAAAKgAECgYICgAAAA==.',['林李']='林李飘雪:BAAAKgAECgEIAQAAAA==.',['枫可']='枫可怜:BAABKgAECn8UAAQPAAYIWAVmZQCEAAAPAAYIWAVmZQCEAAAZAAQIzACGfgAcAAAOAAEIogJAjQAPAAAAAA==.',['枫舞']='枫舞炽焱:BAAAKgAECgQIBgAAAA==.',['格妮']='格妮薇儿:BAAAKgAECgYIBgAAAA==.',['格格']='格格不入:BAAAKgADCggICAAAAA==.',['桂花']='桂花酒酿圆子:BAAAKgADCggICAAAAA==.',['梦寒']='梦寒:BAAAKgAECggICAAAAA==.',['梵天']='梵天一页书:BAAAKgAECggICAAAAA==.',['椰汁']='椰汁粉豆糕:BAAAKgAECgQIBAABKgAFFAgIBAAfAAAAAA==.',['楠蛮']='楠蛮幽雅:BAAAKgADCggICAAAAA==.',['橙味']='橙味美年达:BAABKgAECn8lAAIiAAgIXRcRGADzAQAiAAgIXRcRGADzAQAAAA==.',['橙紫']='橙紫酱:BAABKgAFFH8IAAIhAAgIdggdCACKAQAhAAgIdggdCACKAQAAAA==.',['死亡']='死亡笑脸:BAAAKgAECgUICwAAAA==.',['殿小']='殿小卿:BAABKgAFFH8GAAMdAAYIPg7BCgD8AAAdAAUICw7BCgD8AAAKAAEIrwJ+iwA9AAAAAA==.',['毛毛']='毛毛狐:BAAAKgAECgMIAwAAAA==.',['永夜']='永夜黎明:BAAAKgADCggIEwAAAA==.',['永恒']='永恒的痛苦:BAAAKgADCggICAAAAA==.永恒风暴:BAAAKgAECgQIBAAAAA==.',['永远']='永远龙的传人:BAAAKgAECgcICAAAAA==.',['江先']='江先:BAABKgAFFH8VAAQRAAYI7BE9BADzAAAGAAYIdA8nHAAlAQARAAQI3RU9BADzAAAFAAQIrhiRBQDrAAAAAA==.',['沐雨']='沐雨隨風:BAAAKgAFFAMIAwAAAA==.',['沙扎']='沙扎比:BAAAKgAFFAQIBAAAAA==.',['没事']='没事摸一下:BAAAKgADCgEIAQAAAA==.',['沧海']='沧海冰齐:BAAAKgADCgUIBQAAAA==.沧海壹粟:BAAAKgADCggICAAAAA==.',['沧苓']='沧苓:BAAAKgAECgMIAwAAAA==.',['河道']='河道小骑士:BAAAKgAECggICgAAAA==.',['泉樱']='泉樱:BAABKgAFFH8IAAILAAgIThsuBQDtAQALAAgIThsuBQDtAQAAAA==.',['波波']='波波沙的烦恼:BAAAKgAFFAYIBAAAAA==.',['洛月']='洛月:BAABKgAFFH8IAAIPAAQIXxwFBwABAQAPAAQIXxwFBwABAQABKgAFFAgICAAHAO0XAA==.',['流浪']='流浪的舞步:BAAAKgAECgQIBAAAAA==.',['浪子']='浪子阿烈:BAAAKgAFFAQIBAAAAA==.',['液态']='液态镁:BAACKgAFFH8TAAMJAAQItSD1DQAnAQAJAAMItSD1DQAnAQAMAAQI3gjpLgCoAAAqAAQKfx8ABAkACAjBI9MSAIUCAAkACAjGItMSAIUCAAwAAwi/H/5UAOwAAA0AAwgMGFKGAIMAAAAA.',['淡淡']='淡淡黄昏丶:BAABKgAFFH8HAAIIAAMIQBPdKgC/AAAIAAMIQBPdKgC/AAAAAA==.',['添命']='添命人:BAAAKgADCggICQAAAA==.',['清风']='清风它自来:BAAAKgAECgYIBgAAAA==.清风明月我:BAACKgAFFH8MAAIHAAMIowyNJgCDAAAHAAMIowyNJgCDAAAqAAQKfxkAAgcABgjNEdZpAAQBAAcABgjNEdZpAAQBAAEqAAUUCAgIAAcAuxsA.',['清香']='清香白莲:BAAAKgAECgQIBAAAAA==.',['渺灬']='渺灬怒:BAAAKgAECgUIBQAAAA==.',['溟灭']='溟灭:BAABKgAFFH8RAAMRAAMIlhkpCgDlAAARAAMIlhkpCgDlAAAGAAIIGg2GPwBuAAAAAA==.',['漂亮']='漂亮的馒头君:BAAAKgAFFAQIBAAAAA==.',['漂泊']='漂泊的魍魉:BAAAKgAECgQIBQABKgAECgcIEgAfAAAAAA==.',['火焰']='火焰渣渣:BAAAKgADCgQIBwAAAA==.',['火鸡']='火鸡味糍粑:BAAAKgADCggICAAAAA==.火鸡味锅巴丶:BAAAKgAFFAQIBAAAAA==.',['灬一']='灬一剑倾心灬:BAABKgAECn8pAAIaAAgIGSIkEgBxAgAaAAgIGSIkEgBxAgAAAA==.',['灬屁']='灬屁屁凉灬:BAAAKgAECgUIBQAAAA==.',['灬星']='灬星灬晴灬:BAAAKgAECgMIAwAAAA==.',['灬沉']='灬沉迷灬:BAAAKgAECgUICAAAAA==.',['灬神']='灬神龙灬:BAAAKgADCggIDgAAAA==.',['灬芃']='灬芃然欣动灬:BAABKgAFFH8IAAIQAAMIPxjwFgD0AAAQAAMIPxjwFgD0AAAAAA==.',['灬薄']='灬薄情:BAACKgAFFH8eAAIEAAYIcCPCCwDSAQAEAAYIcCPCCwDSAQAqAAQKfxgAAwQACAivIM4aAF8CAAQACAivIM4aAF8CAAEAAQgTAaZvABEAAAAA.',['灬踏']='灬踏灬岚灬:BAAAKgAECgQIBgAAAA==.',['灬霓']='灬霓裳魅影灬:BAAAKgAECgYIBgAAAA==.',['炭烤']='炭烤鸡翅:BAACKgAFFH8JAAMCAAQIyRdRDQDlAAACAAQIyRdRDQDlAAAjAAMIuRxDBgCYAAAqAAQKfzcAAgIACAjoJY0CAPACAAIACAjoJY0CAPACAAAA.',['烟波']='烟波媚行:BAAAKgAECggIEAAAAA==.',['烦人']='烦人精:BAAAKgAFFAMIAwAAAA==.',['熊猫']='熊猫荣誉会长:BAAAKgAECgIIAgAAAA==.',['熱河']='熱河:BAACKgAFFH8HAAMUAAIIzAoRFACGAAAUAAIIzAoRFACGAAAHAAIIhwCaTwBFAAAqAAQKfx0AAhQACAidFqgpAIkBABQACAidFqgpAIkBAAAA.',['燕浚']='燕浚:BAAAKgAFFAIIAgAAAA==.',['牛奶']='牛奶冒泡泡灬:BAABKgAFFH8aAAISAAMIcg/qHwC6AAASAAMIcg/qHwC6AAAAAA==.',['牛德']='牛德行:BAAAKgAFFAQIAQAAAA==.',['牛魔']='牛魔鬼王:BAABKgAFFH8KAAITAAYIAhfdEAD2AAATAAYIAhfdEAD2AAAAAA==.',['牧芸']='牧芸:BAABKgAFFH8OAAMGAAgIKBTaBQAXAgAGAAgIKBTaBQAXAgARAAEIAABSNwAAAAAAAA==.',['特斯']='特斯拉:BAAAKgADCgIIAgAAAA==.',['特贰']='特贰的獵人:BAABKgAFFH8IAAMIAAQIAyHkBQAaAQAIAAQI1R3kBQAaAQAQAAQI3B/PEgACAQAAAA==.',['狂暴']='狂暴辣条:BAAAKgAECgUIBQAAAA==.',['狂曰']='狂曰一乂乂:BAAAKgADCgEIAQAAAA==.',['狂盗']='狂盗金不焕:BAAAKgAECggICQAAAA==.',['狄鋽']='狄鋽佛歌:BAAAKgADCggIEwAAAA==.',['猫一']='猫一:BAAAKgAECgEIAQAAAA==.',['猫蹦']='猫蹦蹦:BAAAKgADCggICAAAAA==.',['玉水']='玉水茗沙:BAABKgAFFH8QAAQFAAYITxbjAABTAQAFAAUIDBnjAABTAQAGAAQI8xsCJQDhAAARAAIIrgT1FwBLAAAAAA==.',['王大']='王大锤:BAAAKgAFFAYIAwAAAA==.',['王希']='王希:BAAAKgAECgIIAgAAAA==.',['玛卡']='玛卡洛夫:BAAAKgADCggIGAAAAA==.',['玛尼']='玛尼托尼:BAAAKgAECgMIAwAAAA==.',['玩个']='玩个騎士:BAAAKgADCgMIBAAAAA==.',['珊珊']='珊珊来迟:BAAAKgAFFAMIAwAAAA==.',['珑籥']='珑籥:BAAAKgAFFAIIBAAAAA==.',['琉璃']='琉璃喵:BAAAKgAFFAQIBAAAAA==.琉璃猫:BAAAKgAECggICAAAAA==.',['琴筝']='琴筝挽弦歌:BAAAKgAFFAQIBAAAAA==.',['瑾玥']='瑾玥:BAABKgAECn8WAAMOAAgInx/TCQCHAgAOAAgInx/TCQCHAgAPAAYIpAnvXQDHAAAAAA==.',['璐灬']='璐灬崽:BAABKgAECn8lAAQHAAcImgurZQAPAQAHAAcImgurZQAPAQAUAAQIZATBbgBtAAAkAAEIDQR4XgAxAAAAAA==.',['生有']='生有何欢:BAAAKgAFFAIIAgAAAA==.',['用小']='用小拳拳锤你:BAABKgAFFH8HAAMVAAQI0AOqHQCzAAAVAAQI0AOqHQCzAAAWAAIIAgJCJABCAAAAAA==.',['田天']='田天帝:BAABKgAFFH8FAAICAAUI0BbPFgASAQACAAUI0BbPFgASAQAAAA==.',['画画']='画画的贝赑:BAAAKgAECggICAAAAA==.',['疯逗']='疯逗小抗:BAAAKgAFFAMIAwABKgAFFAgICAAXAJIaAA==.',['白羽']='白羽灬丨痕丨:BAABKgAFFH8GAAMPAAYIkRA6HgDRAAAPAAUI0As6HgDRAAAZAAEIpSOYJwBVAAAAAA==.',['白色']='白色考考:BAAAKgAFFAgIAgAAAA==.白色职业:BAAAKgAFFAQIBAAAAA==.',['白露']='白露:BAAAKgADCgEIAQAAAA==.',['百千']='百千家美滋滋:BAACKgAFFH8JAAMCAAYINQ/TEgA8AQACAAYINQ/TEgA8AQAjAAMINgRaBgBoAAAqAAQKfyIAAgIACAgaHbgRAD4CAAIACAgaHbgRAD4CAAAA.',['皮卡']='皮卡丘:BAABKgAECn8VAAIHAAgIihHxTABHAQAHAAgIihHxTABHAQAAAA==.',['相忘']='相忘于江湖:BAABKgAFFH8LAAMZAAgInRCYDQAnAQAZAAUIHRWYDQAnAQAPAAQIQA91GQCBAAAAAA==.',['真心']='真心加不住:BAAAKgAFFAQIBAAAAA==.',['真黑']='真黑:BAABKgAFFH8KAAMGAAgIvRfjGQA2AQAGAAQINRfjGQA2AQAFAAQIchjNDgDAAAAAAA==.',['督军']='督军归来:BAAAKgAECgUIBwAAAA==.',['瞄不']='瞄不准呐:BAAAKgAFFAQIBAAAAA==.',['知秋']='知秋叶:BAAAKgADCggICAAAAA==.',['碧海']='碧海蓝天:BAABKgAFFH8FAAIiAAMICAjdDQC0AAAiAAMICAjdDQC0AAAAAA==.',['碾压']='碾压小骑:BAAAKgAFFAQIBAAAAA==.',['祈雲']='祈雲:BAABKgAECn8XAAMQAAgIyx+PHACFAgAQAAgIyx+PHACFAgAIAAgIVRWPJwCjAQAAAA==.',['神人']='神人:BAAAKgAFFAQIBAAAAA==.',['神奇']='神奇呆呆:BAABKgAECn8aAAMhAAgIQhwABgA6AgAhAAgIQhwABgA6AgASAAgI6ws8JwAYAQAAAA==.',['神无']='神无月灵梦:BAAAKgADCggICAAAAA==.',['神舞']='神舞:BAAAKgAECgMIAwAAAA==.',['神风']='神风竹竿:BAABKgAFFH8FAAIkAAUIvAN/CQDPAAAkAAUIvAN/CQDPAAAAAA==.',['秀耐']='秀耐达公爵:BAAAKgAECgcIDQAAAA==.',['秋梦']='秋梦:BAAAKgAECgEIAQAAAA==.',['秋风']='秋风丶:BAAAKgADCgIIAgAAAA==.',['移动']='移动木桩:BAAAKgAFFAIIAgAAAA==.',['程艾']='程艾影丶:BAABKgAFFH8HAAMQAAQIhBeHFwDyAAAQAAQIaxaHFwDyAAAIAAIIxBAgHACMAAAAAA==.',['穿云']='穿云箭:BAABKgAFFH8MAAIIAAQI/xnPIQDrAAAIAAQI/xnPIQDrAAAAAA==.',['竖横']='竖横竖:BAAAKgAFFAQIBAAAAA==.',['童言']='童言巨儒:BAAAKgAFFAIIAgAAAA==.',['笑笑']='笑笑游侠:BAAAKgAECggICAAAAA==.',['笑苍']='笑苍天:BAAAKgADCgcIBwAAAA==.',['第五']='第五根棍儿:BAAAKgAECgQIBAABKgAECggIDAAfAAAAAA==.',['筱依']='筱依:BAAAKgAFFAgIAgAAAA==.',['筱蔷']='筱蔷:BAABKgAFFH8MAAMIAAIIWhDNQAB3AAAIAAIIWhDNQAB3AAAQAAEIxwL6UQAwAAAAAA==.',['简直']='简直丧心病狂:BAABKgAFFH8MAAINAAYIrg5zBQBYAQANAAYIrg5zBQBYAQAAAA==.',['米卡']='米卡:BAAAKgAECgYIDQAAAA==.',['米开']='米开朗丶基罗:BAAAKgAECgYIBgAAAA==.',['精靈']='精靈回歸:BAAAKgAFFAgIBAAAAA==.',['糖醋']='糖醋排骨丶:BAAAKgAECggICAAAAA==.',['紫月']='紫月无双:BAAAKgAFFAQIBAAAAA==.',['紫颜']='紫颜:BAAAKgAECggIDAAAAA==.',['纪寒']='纪寒武:BAABKgAFFH8LAAITAAYILiUTBgARAgATAAYILiUTBgARAgAAAA==.',['绝代']='绝代神王:BAAAKgAFFAQIBAAAAA==.',['绝对']='绝对强力奶萨:BAAAKgAECgcIDAAAAA==.',['羊过']='羊过小龙女:BAAAKgAECgQIBAAAAA==.',['美年']='美年达:BAAAKgADCgMIAwAAAA==.',['耀灬']='耀灬完成式:BAAAKgAECgUIBQAAAA==.耀灬火星:BAABKgAFFH8IAAIKAAgIYhvOBgBbAgAKAAgIYhvOBgBbAgAAAA==.',['耀麾']='耀麾:BAAAKgAFFAMIAwAAAA==.',['老婆']='老婆当家:BAAAKgAECgEIAQAAAA==.',['老肝']='老肝爹丶:BAAAKgADCggICwAAAA==.',['老腿']='老腿哥:BAABKgAFFH8MAAIKAAMIsSOcKwA5AQAKAAMIsSOcKwA5AQAAAA==.',['联盟']='联盟提款机:BAAAKgAFFAQIBAABKgAFFAgIEgAKAEYfAA==.',['肆伍']='肆伍:BAAAKgAECgcICAAAAA==.',['肉肉']='肉肉萨:BAAAKgAECgMIAwAAAA==.',['肥肥']='肥肥狗蛋:BAABKgAECn8YAAMIAAgIlB/dEQBqAgAIAAgIlB/dEQBqAgAQAAEIzB1J+gBCAAAAAA==.',['背时']='背时鬼:BAAAKgAECgYICQAAAA==.',['胜男']='胜男:BAAAKgAECgEIAQAAAA==.',['胡呆']='胡呆呆:BAABKgAECn8hAAIHAAgIGhFAGQBpAQAHAAgIGhFAGQBpAQAAAA==.',['自寻']='自寻死路丨:BAACKgAFFH8OAAMaAAMIkiUFCQAuAQAaAAMISCMFCQAuAQAbAAEI6ia4EQB1AAAqAAQKfx8AAxoACAghJCwQAKcCABoACAhUIywQAKcCABsAAwgeIwwrAC0BAAAA.',['自然']='自然之法:BAAAKgAECgQIBAAAAA==.自然元素:BAAAKgAECgIIAgAAAA==.',['自由']='自由虚无德:BAAAKgADCggICAAAAA==.',['艺术']='艺术鉴赏家:BAAAKgAECgYIBgAAAA==.',['艾克']='艾克斯兰特:BAAAKgAFFAIIAgAAAA==.',['芙蓉']='芙蓉花开:BAAAKgADCgEIAQAAAA==.',['花千']='花千骨:BAAAKgADCgEIAQAAAA==.',['花落']='花落丶莫相离:BAABKgAFFH8KAAIBAAYIIBKVEwAFAQABAAYIIBKVEwAFAQAAAA==.',['苍天']='苍天小鬼:BAAAKgAECggIDQAAAA==.苍天血魂:BAAAKgADCggICAAAAA==.',['若啃']='若啃肉:BAABKgAFFH8HAAMPAAMIkBovFQCUAAAPAAIIpRkvFQCUAAAOAAEIZRzVEwBTAAAAAA==.',['苦藤']='苦藤洗衣机:BAAAKgAECgYIBgAAAA==.',['苦逼']='苦逼的美年达:BAAAKgADCggICwAAAA==.',['苹果']='苹果耳机:BAAAKgADCgYIBgAAAA==.',['范丶']='范丶达克霍姆:BAAAKgADCgQIBAAAAA==.',['茶饮']='茶饮三道:BAAAKgAFFAQIBAABKgAFFAgIBgAHADwFAA==.',['荡漾']='荡漾的椿芯:BAAAKgAFFAIIAgAAAA==.',['荼蘼']='荼蘼若茶:BAABKgAFFH8JAAIDAAMIuhdfCADkAAADAAMIuhdfCADkAAAAAA==.',['莣记']='莣记一切:BAAAKgAECggIDwAAAA==.',['莫辞']='莫辞:BAAAKgADCggICAAAAA==.',['莱依']='莱依:BAABKgAFFH8GAAIBAAYIrQknFwDoAAABAAYIrQknFwDoAAABKgAFFAgIIAABAFUQAA==.',['莱唯']='莱唯贝贝:BAAAKgAECggICwAAAA==.',['萌中']='萌中带酒:BAACKgAFFH8dAAMeAAUImg1GBQDUAAAeAAQI0g1GBQDUAAAVAAIIhBs0IgCaAAAqAAQKfzoAAh4ACAgTHIQHAAQCAB4ACAgTHIQHAAQCAAAA.',['萨橙']='萨橙橙:BAAAKgAFFAQIAwABKgAFFAgIDgAHABUPAA==.',['葡萄']='葡萄冰柠茶:BAAAKgAECggICAAAAA==.',['蒋妮']='蒋妮:BAAAKgAECgIIAgAAAA==.',['蓝水']='蓝水凌日:BAAAKgAECgcIDQAAAA==.',['蓝色']='蓝色妖姬:BAAAKgADCgQIBAAAAA==.蓝色德鲁依:BAABKgAFFH8JAAQSAAMI+BAmOgC7AAASAAMI+BAmOgC7AAAhAAMIqgkFJwCJAAAgAAII9QImDgA7AAAAAA==.',['蓝花']='蓝花楹:BAAAKgAFFAEIAQAAAA==.',['蔡国']='蔡国庆:BAAAKgAECgQIBAAAAA==.',['虔诚']='虔诚之光:BAABKgAECn8WAAMKAAgIxQ0MOQAnAQAKAAcI+g4MOQAnAQALAAEIhQYgXgAUAAAAAA==.',['虚云']='虚云:BAABKgAFFH8HAAIVAAMIawZYKAB/AAAVAAMIawZYKAB/AAAAAA==.',['虞小']='虞小乙:BAABKgAFFH8OAAMQAAgICBxgBgAmAgAQAAgIgRtgBgAmAgAIAAYI7RV9EgBPAQAAAA==.',['蜂蜜']='蜂蜜柚子茶:BAAAKgAFFAQIBAAAAA==.',['螢火']='螢火蟲:BAAAKgADCgIIAgAAAA==.',['蠢灬']='蠢灬萌灬骑:BAABKgAFFH8QAAMdAAgI0Q4YAwDtAQAdAAgI0Q4YAwDtAQAKAAQIwATmZwCdAAAAAA==.',['血杀']='血杀之圣岚:BAAAKgAFFAIIAgAAAA==.',['褔牛']='褔牛:BAAAKgAECgIIAgAAAA==.',['褪色']='褪色者:BAAAKgAECgMIAwAAAA==.',['西格']='西格玛之子:BAAAKgAECgQIBgAAAA==.',['西野']='西野七濑:BAAAKgAECgMIBQAAAA==.',['觅心']='觅心:BAAAKgAECggIDAAAAA==.',['許芐']='許芐承喏:BAABKgAFFH8IAAIKAAgIaAkOFQCzAQAKAAgIaAkOFQCzAQAAAA==.',['诡术']='诡术妖姬丶:BAAAKgAFFAEIAQAAAA==.',['诶哟']='诶哟小祖宗丶:BAAAKgAECgIIAgAAAA==.',['请你']='请你耗子尾汁:BAABKgAECn8ZAAMWAAYIqwt+PgDZAAAWAAYIqwt+PgDZAAAeAAQIUQIwIwAwAAAAAA==.',['豆豆']='豆豆信圣光:BAAAKgAECggIDgAAAA==.',['貝阿']='貝阿朵莉切:BAAAKgAFFAMIAwAAAA==.',['超级']='超级呼呼蛋:BAAAKgADCgEIAQAAAA==.',['趣茤']='趣茤茤:BAABKgAFFH8GAAIGAAYInB9sOQCKAAAGAAYInB9sOQCKAAAAAA==.',['趴下']='趴下来到脑袋:BAAAKgAECggICAAAAA==.',['身后']='身后有尾巴:BAABKgAFFH8IAAICAAgIQwPkEABUAQACAAgIQwPkEABUAQAAAA==.',['轻风']='轻风之语丶:BAAAKgAECggICAAAAA==.',['辛月']='辛月之幕:BAAAKgAFFAEIAQAAAA==.',['辣条']='辣条猎:BAAAKgADCggICAAAAA==.辣条萨:BAAAKgAECgMIAgAAAA==.',['远坂']='远坂凛:BAAAKgAECggICAAAAA==.',['远方']='远方二十七:BAABKgAFFH8VAAMKAAgIIBGUMgAfAQAKAAUIoRCUMgAfAQALAAYIRwvmCQD5AAAAAA==.',['迦羅']='迦羅:BAAAKgAECgIIAgAAAA==.',['追风']='追风旅行者:BAAAKgADCggICAAAAA==.',['逍遥']='逍遥恋菲:BAAAKgAECgUIBQAAAA==.逍遥莫寒:BAACKgAFFH8LAAIHAAMIHQd9IACBAAAHAAMIHQd9IACBAAAqAAQKfxQAAgcACAhOCDRsAPwAAAcACAhOCDRsAPwAAAAA.逍遥魔皇:BAAAKgADCgUIBQAAAA==.',['逸晨']='逸晨宇:BAAAKgAECgIIAgAAAA==.',['道友']='道友请渡劫:BAAAKgAFFAMIAwAAAA==.',['遗忘']='遗忘天空:BAAAKgAECgYICgAAAA==.',['遥望']='遥望:BAAAKgAFFAYIAQAAAA==.',['那个']='那个薛帝凯:BAAAKgAECgEIAQAAAA==.',['邦邦']='邦邦萨:BAAAKgAECgYIBwAAAA==.',['邪恶']='邪恶小男孩:BAAAKgAECgIIAgAAAA==.',['酒窝']='酒窝:BAAAKgAECgUIBQAAAA==.',['酱焖']='酱焖鲫鱼盖饭:BAAAKgADCggICAAAAA==.',['酱狗']='酱狗狗:BAAAKgAECggICAAAAA==.',['酴醾']='酴醾:BAABKgAECn8eAAIJAAgIjB6ZGQBaAgAJAAgIjB6ZGQBaAgAAAA==.酴醾荼蘼:BAABKgAFFH8KAAIKAAMIMhIGUQDOAAAKAAMIMhIGUQDOAAAAAA==.',['醉卧']='醉卧沙场:BAAAKgAFFAQIBAAAAA==.',['里予']='里予女圭女圭:BAABKgAFFH8UAAIKAAgIdR+EBwBPAgAKAAgIdR+EBwBPAgAAAA==.',['野原']='野原广志:BAAAKgAECgEIAQAAAA==.',['銱児']='銱児鋃譡:BAAAKgAECgEIAQAAAA==.',['钢铁']='钢铁洪流:BAABKgAFFH8IAAMSAAgI2R+yEQCRAQASAAYIAiKyEQCRAQAhAAIIUwlxJgCMAAAAAA==.',['银发']='银发:BAAAKgAECgYIBgAAAA==.',['闹闹']='闹闹别闹:BAAAKgAFFAgIAwAAAA==.',['阿达']='阿达魔:BAAAKgAFFAgIAgAAAA==.',['陆尹']='陆尹儿:BAACKgAFFH8sAAIaAAQI2SOYGQAwAQAaAAQI2SOYGQAwAQAqAAQKfyoAAhoACAjUIE8ZAG0CABoACAjUIE8ZAG0CAAEqAAUUCAgXABoALyIA.',['陆屿']='陆屿森岛丶:BAAAKgAFFAgIAgAAAA==.',['隐约']='隐约雷鸣:BAAAKgAFFAQIBAABKgAFFAgIDAAQAN0lAA==.',['雨水']='雨水:BAAAKgADCgIIAgAAAA==.',['雷鬼']='雷鬼吖:BAAAKgAFFAQIBAAAAA==.',['電動']='電動小馬達:BAAAKgAECgcIBwAAAA==.',['雾绕']='雾绕山空:BAABKgAECn8UAAMTAAgIzRD5LgB1AQATAAgIzRD5LgB1AQAiAAEICQqcYAAsAAAAAA==.',['雾雨']='雾雨魔理纱:BAAAKgADCggICAABKgAFFAgIDAAaAMMaAA==.',['霜见']='霜见叁柒:BAACKgAFFH8SAAIKAAQISyJJCwApAQAKAAQISyJJCwApAQAqAAQKfx0AAgoACAgTJQ8OAOACAAoACAgTJQ8OAOACAAAA.',['露娜']='露娜喵:BAAAKgAECggICgAAAA==.',['青苹']='青苹果美年达:BAAAKgADCgQIBAAAAA==.',['青青']='青青的爱:BAACKgAFFH8PAAIQAAMI4BZfLQDSAAAQAAMI4BZfLQDSAAAqAAQKfxkAAhAABgiNFqt8AD8BABAABgiNFqt8AD8BAAAA.',['顶不']='顶不住:BAAAKgAFFAQIAwAAAA==.',['领衔']='领衔主演:BAABKgAECn8UAAINAAgINhCNOwB+AQANAAgINhCNOwB+AQAAAA==.',['颤动']='颤动的睫毛:BAAAKgAECggIBgAAAA==.',['风天']='风天决:BAAAKgADCggICAAAAA==.',['风火']='风火雷电劈:BAABKgAFFH8GAAIkAAYI1gVWCgArAQAkAAYI1gVWCgArAQAAAA==.',['风雨']='风雨无啨:BAAAKgADCgIIAgAAAA==.风雨雷电:BAAAKgAECgMIAwAAAA==.',['香泽']='香泽微闻:BAAAKgADCggIJgAAAA==.',['马老']='马老师:BAAAKgAFFAMIAwAAAA==.',['骄傲']='骄傲的孤狼:BAABKgAECn8kAAIaAAgIjRkLHwAMAgAaAAgIjRkLHwAMAgAAAA==.',['骑士']='骑士默默:BAAAKgAECggICgAAAA==.',['骨匠']='骨匠:BAAAKgAECggICAAAAA==.',['高启']='高启强:BAAAKgAECgMIBgAAAA==.',['魍魉']='魍魉画魂:BAAAKgAECgcICQABKgAECgcIEgAfAAAAAA==.',['魔之']='魔之水晶:BAAAKgAFFAIIBAAAAA==.',['魔焱']='魔焱天空:BAAAKgADCggICAAAAA==.',['魔爆']='魔爆酱:BAAAKgAECgUIBQAAAA==.',['鲜嫩']='鲜嫩多汁:BAABKgAFFH8IAAIEAAgIhwyXCwDUAQAEAAgIhwyXCwDUAQAAAA==.',['鳥山']='鳥山明:BAAAKgAECgQIBAAAAA==.',['鹏鹏']='鹏鹏的绿皮儿:BAABKgAECn8WAAITAAgImx0lBgBuAgATAAgImx0lBgBuAgABKgAFFAgIIAAKAFscAA==.',['黄毛']='黄毛怪:BAAAKgAFFAQIBAAAAA==.',['黑寡']='黑寡人:BAAAKgAFFAIIAgAAAA==.',['黑暗']='黑暗的威胁:BAAAKgAFFAgIAwAAAA==.黑暗的猎杀者:BAAAKgAFFAgIBAAAAA==.黑暗的颂歌:BAAAKgAECggICAAAAA==.',['黑猫']='黑猫露娜:BAABKgAECn8eAAIPAAgIGhA8MABiAQAPAAgIGhA8MABiAQAAAA==.',['黑神']='黑神话悟空:BAAAKgADCggIEQABKgAECgcICwAfAAAAAA==.',['黑鲸']='黑鲸丶:BAABKgAFFH8IAAMTAAgIEhNdEQD0AAATAAUIcxNdEQD0AAAiAAMIkRKmEwDmAAAAAA==.',['黑龍']='黑龍部落灬:BAABKgAECn8mAAQFAAgItCTNFAA2AQAFAAMIkiXNFAA2AQARAAMI4yIHRQDOAAAGAAIIOCVxUwDEAAAAAA==.',['默默']='默默阿:BAABKgAECn8aAAMSAAcIEwmXjwC4AAASAAYIRQmXjwC4AAAgAAUIHQXHOABDAAAAAA==.',['龌龊']='龌龊之奶豆:BAABKgAFFH8QAAMHAAYIOxGwEQBHAQAHAAYIOxGwEQBHAQAUAAQILBMTCwDWAAAAAA==.',['龍泽']='龍泽萝拉:BAAAKgAECggICAAAAA==.',['龙族']='龙族小天才:BAAAKgADCggIFAAAAA==.',['龙猪']='龙猪丶熊白白:BAAAKgAFFAMIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end