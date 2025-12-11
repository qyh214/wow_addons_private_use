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
 local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','Shaman-Elemental','Druid-Restoration','Druid-Balance','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Protection','DemonHunter-Vengeance','Mage-Frost','Mage-Arcane','Warrior-Fury','Warrior-Arms','Paladin-Holy','Priest-Holy','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Blood','Priest-Shadow','Monk-Mistweaver','Warlock-Destruction','Warrior-Protection','DemonHunter-Havoc','Hunter-Survival','Monk-Brewmaster','Warlock-Demonology','Evoker-Devastation','Monk-Windwalker','Shaman-Restoration','Warlock-Affliction','Druid-Feral','Rogue-Outlaw',}; local provider = {region='CN',realm='千针石林',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aa='Aarong:BAABLAAFFH8GAAIBAAIIEg5TewCKAAABAAIIEg5TewCKAAAAAA==.',Ac='Accorry:BAAALAAFFAIIBAAAAA==.',Ar='Arditi:BAAALAAFFAIIAgAAAA==.',At='Athenshecate:BAAALAAECgYICgAAAA==.',Au='Auz:BAAALAADCgYIDAAAAA==.',Ay='Ayalegna:BAABLAAFFH8GAAMBAAIIqBPyjQA/AAACAAEImAJzIABAAAABAAIIqBPyjQA/AAAAAA==.',Bl='Blackjack:BAABLAAECn8VAAIDAAYI9AmjSwDhAAADAAYI9AmjSwDhAAAAAA==.',Br='Brocklesnar:BAAALAADCgYIBgAAAA==.',Cc='Cceeo:BAAALAAECgMIAQAAAA==.',Ce='Celecoxib:BAAALAAECgEIAQAAAA==.',Ch='Chrees:BAAALAADCgMIAwAAAA==.',Da='Davinci:BAAALAADCgUIBQAAAA==.',De='Dexstarr:BAAALAAECgUIBwAAAA==.',Do='Dobi:BAAALAAFFAIIAgAAAA==.Doubtlessly:BAABLAAFFH8WAAMEAAYIgx3jCgADAgAEAAYIgx3jCgADAgAFAAEIYAuPNAA7AAAAAA==.',Fo='Forquisnow:BAAALAAFFAIIAgAAAA==.',Fu='Future:BAAALAAECgYIDQAAAA==.',Gl='Glorias:BAAALAAECggICAAAAA==.',Ha='Ha:BAABLAAECn8VAAIGAAYI/RZ0oQC1AQAGAAYI/RZ0oQC1AQAAAA==.Hanser:BAACLAAFFH8LAAMHAAMI7hvwJADpAAAHAAMIuxjwJADpAAAIAAMIFw4+FwCxAAAsAAQKfx4AAwcACAimICEzAI4CAAcABwilIiEzAI4CAAgACAhkHcIfAGkCAAAA.',Ho='Holysprite:BAABLAAFFH8MAAMGAAIIHSC7JgC8AAAGAAIIGR67JgC8AAAJAAIIkxpqFABSAAAAAA==.',Ii='Iilidann:BAABLAAFFH8GAAIKAAII6hmNDgCAAAAKAAII6hmNDgCAAAABLAAFFAIIDAAGAB0gAA==.',Ju='Justwowdh:BAAALAAECgUIBQAAAA==.',Ke='Kepller:BAAALAAECgIIAgAAAA==.',La='Lawlietk:BAAALAAECgMIAwABLAAFFAMICgABADMZAA==.',Le='Leondavinc:BAAALAAECgcIBwAAAA==.',Li='Littles:BAABLAAFFH8KAAMLAAIINR25CwClAAALAAIINR25CwClAAAMAAIIuw9MVgCKAAABLAAFFAgIBgABAO4eAA==.',Lo='Lookinmyass:BAAALAAECgYIBgAAAA==.',Ma='Maybehappy:BAABLAAFFH8IAAMIAAIIgBVdIwCBAAAIAAIIDhJdIwCBAAAHAAII7hTClgBCAAAAAA==.',Mm='Mmhaibin:BAABLAAECn8XAAMNAAYIEBwHXQDcAQANAAYIEBwHXQDcAQAOAAQIQhMHIwDwAAAAAA==.',Mo='Moya:BAAALAAECgYIBgAAAA==.',Ne='Nevin:BAAALAAECgYIBgAAAA==.',No='Nous:BAAALAAECgMIAQAAAA==.',Ov='Overdoes:BAABLAAFFH8HAAMPAAUIyAkJHADKAAAPAAQIAQYJHADKAAAGAAMIYA8aQQCRAAAAAA==.',Pa='Pathos:BAAALAAECgMIBAAAAA==.',Pi='Pikamiaod:BAAALAAFFAIIAgAAAA==.',Pl='Playerjoxkpp:BAAALAAECgQIBQAAAA==.Playerspttee:BAAALAAECgYIBgAAAA==.',Ra='Rany:BAAALAAECgUIBQAAAA==.',Sa='Sacredhealer:BAACLAAFFH8IAAIQAAIIkx2TLQCSAAAQAAIIkx2TLQCSAAAsAAQKfx0AAhAABgjkHfo2AAACABAABgjkHfo2AAACAAAA.',Sc='Scarletkiba:BAACLAAFFH8LAAMHAAMI2wa5fgBZAAAIAAIIewigKwBwAAAHAAMIiQa5fgBZAAAsAAQKfxgAAggABghxEZZiADYBAAgABghxEZZiADYBAAAA.Schlussel:BAAALAAECgYIBgAAAA==.',Se='Selena:BAAALAAECgQIBAAAAA==.',Sh='Shadowdance:BAACLAAFFH8qAAIRAAYIThrRBgCxAQARAAYIThrRBgCxAQAsAAQKfyUAAxIABghvHu4bALYBABEABghgHaMmAOcBABIABgj1GO4bALYBAAAA.Shadowfang:BAAALAAECgUIBQAAAA==.',Si='Sixxbaby:BAAALAAFFAEIAQAAAA==.',Sk='Skdd:BAABLAAECn8ZAAMGAAgIRh8GJgD+AQAGAAgIRh8GJgD+AQAPAAEI6AXoRQAoAAAAAA==.',Sy='Sylvancay:BAACLAAFFH8oAAMBAAYIch+uHwC2AQABAAYIch+uHwC2AQATAAEImxTVFgBRAAAsAAQKfxYAAgEACAhfIRgiAOcCAAEACAhfIRgiAOcCAAAA.',Th='Thislaypain:BAAALAAFFAIIBAAAAA==.Thunderwrath:BAAALAAECgUIBQAAAA==.',Tr='Treasur:BAACLAAFFH8SAAMUAAYI8gpEEwA9AQAUAAYI8gpEEwA9AQAQAAIIdQWgPgB5AAAsAAQKfx0AAxQABwgxG5gQAN4BABQABggvH5gQAN4BABAABwi0EgkwAD4BAAAA.',Ur='Ursoulismine:BAAALAAECgYIDAAAAA==.',Va='Vanityhunter:BAAALAAECggIEgAAAA==.',Vs='Vsddw:BAAALAAECgYIBwAAAA==.',We='Wen:BAAALAAFFAIIAgAAAA==.',Wh='Whitney:BAAALAAECgIIAgAAAA==.',Xi='Xie:BAAALAAECgYICAAAAA==.',Ya='Ya:BAABLAAECn8XAAIQAAYIzQaChwDsAAAQAAYIzQaChwDsAAAAAA==.',['一头']='一头傻手:BAAALAAECgYICAAAAA==.',['一套']='一套三板斧:BAAALAAFFAIIBAAAAA==.',['一念']='一念成佛:BAAALAAECgQIBAAAAA==.',['一枕']='一枕江风梦:BAAALAAFFAIIAgAAAA==.',['一沙']='一沙一天堂:BAAALAAECgUICAAAAA==.',['一点']='一点都不可爱:BAAALAAECgIIAgAAAA==.',['一米']='一米四九:BAAALAADCgIIAgAAAA==.',['一颗']='一颗小糖果:BAACLAAFFH8MAAIVAAMIUxuuDgDjAAAVAAMIUxuuDgDjAAAsAAQKfycAAhUACAjwIMsHAOcCABUACAjwIMsHAOcCAAAA.',['不德']='不德鸟:BAAALAAFFAIIAgAAAA==.',['不忘']='不忘乌贼初心:BAACLAAFFH8GAAIIAAIIdBngHQCRAAAIAAIIdBngHQCRAAAsAAQKfyQAAggACAhZIa0MAP0CAAgACAhZIa0MAP0CAAAA.',['不死']='不死黑黑:BAAALAAECgQICwAAAA==.',['不说']='不说的过去丶:BAAALAAECgUIBQAAAA==.',['丨和']='丨和光同尘丨:BAABLAAECn8YAAIBAAgIpyOWLgC4AgABAAgIpyOWLgC4AgAAAA==.',['丨小']='丨小念頭丨:BAAALAAFFAIIBAAAAA==.丨小灬飛丨:BAACLAAFFH8XAAIRAAYIOxwtBgDCAQARAAYIOxwtBgDCAQAsAAQKfx4AAhEACAhbI4gEADMDABEACAhbI4gEADMDAAAA.',['丨芷']='丨芷丨:BAAALAAFFAIIAgAAAA==.',['丨贝']='丨贝丶壳丨:BAAALAAECgcICAAAAA==.',['丰满']='丰满的山竹:BAAALAAECgIIAgAAAA==.',['临江']='临江仙:BAABLAAFFH8KAAIWAAII+wqRbQAyAAAWAAII+wqRbQAyAAAAAA==.',['丶日']='丶日晷:BAAALAAECgQIBAAAAA==.',['丷兔']='丷兔小洛丷:BAABLAAFFH8GAAIXAAIIyRrXIAB8AAAXAAIIyRrXIAB8AAAAAA==.',['主教']='主教伊瑞尔:BAAALAAECgYIDAAAAA==.',['丿影']='丿影之哀伤:BAAALAADCgcIBwAAAA==.',['乍见']='乍见之欢:BAABLAAFFH8JAAMEAAMIQgt7OACJAAAEAAMIQgt7OACJAAAFAAIIgAz/IwCBAAAAAA==.',['乱射']='乱射:BAAALAAECgIIBAAAAA==.',['予墨']='予墨灬:BAAALAAECgEIAQAAAA==.',['云之']='云之麓:BAAALAADCggICAAAAA==.',['云欣']='云欣:BAAALAAECgIIAgAAAA==.',['五十']='五十年后再说:BAAALAAECgMIAwAAAA==.',['亚南']='亚南的叶奈法:BAAALAADCgQIBAAAAA==.',['亮妹']='亮妹儿:BAAALAAECggICAAAAA==.',['仲夏']='仲夏之残梦:BAAALAADCgMIAwAAAA==.',['伊丽']='伊丽莎白奥妹:BAAALAAECgYICAAAAA==.',['伊利']='伊利達雷:BAABLAAFFH8GAAIYAAYIGQk3KwA7AQAYAAYIGQk3KwA7AQAAAA==.',['伊拉']='伊拉菲:BAAALAADCgIIAgAAAA==.',['但偏']='但偏偏雨渐渐:BAAALAAECggIDwAAAA==.',['你很']='你很能打吗:BAAALAAECgEIAQAAAA==.',['你老']='你老夜:BAABLAAFFH8MAAIGAAIIkxvGOACjAAAGAAIIkxvGOACjAAABLAAFFAgIHgAHADkbAA==.',['倾城']='倾城丶羽洛:BAAALAAFFAIIAwAAAA==.',['偏偏']='偏偏醉断肠:BAAALAAECgEIAQAAAA==.',['兔斯']='兔斯拉:BAACLAAFFH8MAAIHAAIIeiN2ggBRAAAHAAIIeiN2ggBRAAAsAAQKfy8AAwcABggfJbREAFoCAAcABgj0JLREAFoCAAgABggxHrUzAPIBAAEsAAUUAggQABEAlh0A.',['兜兜']='兜兜插图腾:BAAALAAFFAIIAgAAAA==.兜兜爱糖:BAABLAAFFH8iAAIGAAYIvh9jDgDRAQAGAAYIvh9jDgDRAQAAAA==.',['全部']='全部释放:BAAALAAFFAIIAgAAAA==.',['八二']='八二年的雪碧:BAABLAAFFH8IAAIEAAIIKxhwNwCMAAAEAAIIKxhwNwCMAAAAAA==.',['六宝']='六宝宝:BAABLAAFFH8FAAIKAAMI8gapDgBWAAAKAAMI8gapDgBWAAABLAAFFAQIDwAXAAATAA==.',['兽性']='兽性撕裂青春:BAACLAAFFH8GAAIHAAIIawoVowA9AAAHAAIIawoVowA9AAAsAAQKfyAABAcABwjmGahwAGIBAAcABwjmGahwAGIBABkABAi7DN0aAOgAAAgAAQhrA8vTABcAAAAA.',['冬季']='冬季的苍白:BAABLAAFFH8IAAIBAAIIKSDsQQCwAAABAAIIKSDsQQCwAAAAAA==.',['冰块']='冰块:BAAALAADCgYIBgAAAA==.',['冰河']='冰河葬寒星:BAAALAAFFAIIAgAAAA==.冰河解冻:BAAALAAFFAEIAQAAAA==.',['冰火']='冰火二重天:BAABLAAECn8VAAIMAAYI1QmJRgDvAAAMAAYI1QmJRgDvAAAAAA==.',['冲锋']='冲锋是信仰:BAAALAAFFAIIAgAAAA==.',['凋零']='凋零之躯:BAAALAAECgYIDAAAAA==.',['凤凰']='凤凰龙神丸:BAABLAAFFH8GAAMMAAIITwjOZgBeAAAMAAII3AXOZgBeAAALAAEIMwVQIgA5AAAAAA==.',['凭记']='凭记忆想念:BAABLAAFFH8KAAIBAAIItQkahgBDAAABAAIItQkahgBDAAAAAA==.',['凯米']='凯米米:BAAALAAECgEIAQAAAA==.',['凶猛']='凶猛撕咬:BAABLAAFFH8OAAIEAAQIZBFYJAD4AAAEAAQIZBFYJAD4AAAAAA==.',['剑九']='剑九州:BAABLAAFFH8GAAIGAAIIShk/NwClAAAGAAIIShk/NwClAAAAAA==.',['北凉']='北凉卒:BAABLAAFFH8QAAIBAAUIVBn5PgA/AQABAAUIVBn5PgA/AQAAAA==.',['北枫']='北枫狂乱:BAAALAAECgYIBgAAAA==.',['千斗']='千斗五十铃:BAAALAADCgQIBAAAAA==.',['半夏']='半夏:BAAALAAECgYIBgAAAA==.',['单体']='单体猛兽:BAAALAAFFAEIAQAAAA==.',['南葑']='南葑:BAAALAAFFAIIAgAAAA==.',['又又']='又又:BAAALAADCggICAAAAA==.',['又见']='又见小百事:BAABLAAECn8YAAIBAAgILh07WQBEAgABAAgILh07WQBEAgAAAA==.',['反渗']='反渗透:BAAALAAECgYIBgAAAA==.',['叫俺']='叫俺尹志平:BAAALAAECgUICQAAAA==.',['叫我']='叫我小黑:BAAALAAECgQICAAAAA==.叫我蜂蜜大人:BAAALAAFFAIIAgAAAA==.',['叶孤']='叶孤城:BAAALAAECgYIDgAAAA==.',['司徒']='司徒加钱:BAAALAAECgYIEQAAAA==.',['吃货']='吃货阿迅:BAAALAAECgYIDgAAAA==.',['名字']='名字可以吃麽:BAAALAAECgEIAQAAAA==.名字吃不吃额:BAAALAAECgEIAQAAAA==.',['吟慧']='吟慧:BAABLAAECn8XAAMCAAgIgxfIFAAgAgACAAgIgxfIFAAgAgABAAIIdQrTfQFtAAAAAA==.',['吴彦']='吴彦祖丶:BAAALAAFFAMIBAAAAA==.',['吾孜']='吾孜然孤独:BAAALAADCgUIBQAAAA==.',['吾心']='吾心舒出:BAAALAAECgIIAQAAAA==.',['呆萌']='呆萌亨特丨磊:BAABLAAFFH8MAAIYAAgIxwJbRQBoAAAYAAgIxwJbRQBoAAAAAA==.',['和谐']='和谐丶小伍:BAAALAADCgQIBgAAAA==.',['咕德']='咕德白:BAAALAADCgQIBAAAAA==.',['哈士']='哈士奇丶空空:BAAALAAECgEIAQAAAA==.',['响回']='响回耀光:BAABLAAFFH8NAAIHAAYIAQxXRQA0AQAHAAYIAQxXRQA0AQAAAA==.',['哎呀']='哎呀我的牧牧:BAAALAADCgcIBwAAAA==.哎呀我的飞飞:BAABLAAECn8YAAMYAAYI+xFDzgBCAQAYAAYIWBFDzgBCAQAKAAYI3Ac6RQDMAAAAAA==.哎呀灬有联盟:BAABLAAECn8UAAIGAAYI+h1QQgCVAQAGAAYI+h1QQgCVAQAAAA==.',['哦吼']='哦吼耶:BAABLAAFFH8IAAIGAAMIlhZcQACTAAAGAAMIlhZcQACTAAAAAA==.',['哦哈']='哦哈悠丶:BAABLAAFFH8IAAIEAAMImgv0OgCCAAAEAAMImgv0OgCCAAAAAA==.',['喂升']='喂升经:BAABLAAFFH8VAAIYAAYIcyAeDwDpAQAYAAYIcyAeDwDpAQABLAAFFAYIGQAHAHQkAA==.',['善丶']='善丶果:BAAALAAFFAIIBAAAAA==.',['喔呦']='喔呦小贝贝:BAAALAADCgYIBgAAAA==.',['回忆']='回忆很沉重:BAAALAAECgYIDwAAAA==.',['国风']='国风:BAABLAAFFH8KAAMVAAIIxwOhGQBSAAAVAAIIxwOhGQBSAAAaAAIIbAZNIgArAAAAAA==.',['土豆']='土豆宝宝:BAAALAAECgUIBQAAAA==.',['圡人']='圡人:BAAALAADCgYICAAAAA==.',['圣光']='圣光大魔王:BAAALAAECgUIBwAAAA==.圣光是信仰丶:BAAALAAECggICAAAAA==.圣光的戈门:BAAALAAFFAYIAgAAAA==.圣光肌肉奶牛:BAAALAADCgYIBgAAAA==.',['圣琪']='圣琪酾:BAAALAADCgEIAQAAAA==.',['在等']='在等月亮么:BAAALAAECggIAgAAAA==.',['地狱']='地狱战舰:BAAALAADCgMIAwAAAA==.',['墨明']='墨明棋妙彡:BAAALAADCgIIAgAAAA==.',['壁虎']='壁虎不是虎:BAAALAAFFAQIBAAAAA==.',['壹二']='壹二叁四伍:BAAALAAECgUIBgAAAA==.',['壹沙']='壹沙壹天堂:BAAALAAFFAIIBAAAAA==.',['夏沐']='夏沐:BAAALAADCgcIBwAAAA==.',['夏洛']='夏洛洛:BAAALAAFFAQIBAAAAA==.夏洛洛丶往昔:BAABLAAFFH8GAAMJAAII1Rf6HAAxAAAGAAIIkBIFdQA7AAAJAAII1Rf6HAAxAAAAAA==.',['夏至']='夏至天蓝:BAAALAAECgMIAwAAAA==.',['夜之']='夜之羽:BAAALAAFFAIIAgAAAA==.夜之魑魅:BAAALAAFFAgIAgAAAA==.',['夜羽']='夜羽星河:BAACLAAFFH8bAAMHAAUIahVQTQAYAQAHAAUIahVQTQAYAQAIAAIIugdCLABuAAAsAAQKfyAAAwcACAhUH/wwAJUCAAcACAhUH/wwAJUCAAgAAwhDFjeMALQAAAAA.',['大大']='大大的二号:BAAALAAECgcIEQAAAA==.大大飞:BAABLAAECn8cAAMOAAYIRxBFCQAYAQAOAAYIRxBFCQAYAQANAAYItgZ8bQDMAAAAAA==.',['大殺']='大殺四方:BAABLAAFFH8QAAIYAAUI3xfJKgA+AQAYAAUI3xfJKgA+AQAAAA==.',['大白']='大白兔奶糖:BAAALAAFFAgIBAAAAA==.',['大角']='大角怪:BAAALAAFFAIIBAAAAA==.',['天上']='天上的神仙:BAAALAADCggICAAAAA==.',['天佑']='天佑尒复生:BAAALAAECgIIAgAAAA==.天佑灬复生:BAAALAAECgQIBAAAAA==.',['天使']='天使很美:BAAALAAECgIIAgAAAA==.',['天呐']='天呐你眞高:BAAALAADCgMIAwAAAA==.',['天生']='天生博爱:BAAALAADCgYIBgAAAA==.',['天蕊']='天蕊:BAAALAAECgcIBwAAAA==.',['太子']='太子妃:BAABLAAFFH8QAAILAAYICwIzEwBLAAALAAYICwIzEwBLAAAAAA==.',['太空']='太空仔:BAAALAAECgUICAAAAA==.',['奥兹']='奥兹伊蓝德:BAAALAAECgQIBAAAAA==.',['奧爾']='奧爾良:BAAALAAFFAMIAwAAAA==.',['女院']='女院门房德爷:BAAALAADCgYIBQAAAA==.',['奶油']='奶油西米露:BAAALAAECggICAAAAA==.',['奶萨']='奶萨灬:BAAALAADCgYIBgAAAA==.',['如夢']='如夢令:BAAALAAECgYIBgAAAA==.',['妇产']='妇产科主任:BAAALAAECgEIAQAAAA==.',['妮果']='妮果米憨憨:BAAALAAECgcIBwAAAA==.',['姿那']='姿那诺:BAAALAAECgYIEQAAAA==.',['威少']='威少:BAABLAAFFH8GAAIEAAMIzQqXIgCbAAAEAAMIzQqXIgCbAAAAAA==.',['娜渴']='娜渴撸撸:BAABLAAFFH8IAAIBAAIICB7oQACxAAABAAIICB7oQACxAAAAAA==.',['婲瑶']='婲瑶裤儿:BAAALAAECgYIDQAAAA==.',['婷宝']='婷宝丶美美哒:BAAALAAECggIEgAAAA==.',['宁馨']='宁馨儿:BAAALAADCgYIBgAAAA==.',['宇宙']='宇宙抖腿之父:BAAALAAECgYIEAAAAA==.',['宝轩']='宝轩很无聊:BAAALAADCgEIAQAAAA==.',['宠物']='宠物比我强:BAAALAAFFAMIBAAAAA==.',['寿司']='寿司鱼丸:BAAALAAECgcIDQAAAA==.',['小兔']='小兔洛洛:BAAALAAFFAQIAgAAAA==.',['小天']='小天旺仔:BAAALAAECgQIBAAAAA==.',['小宝']='小宝宝不乖:BAAALAAECgUICAAAAA==.小宝宝真乖:BAAALAAECgYIDgAAAA==.小宝宝真闹:BAAALAAECgYIBwAAAA==.',['小富']='小富婆:BAAALAAECggIDgAAAA==.小富婆跟班:BAAALAADCgYIBgAAAA==.',['小小']='小小牛:BAAALAADCgYIBgAAAA==.小小路:BAAALAAECgYIBgAAAA==.',['小德']='小德懂不懂:BAAALAADCggICAAAAA==.',['小心']='小心肝儿:BAAALAADCgEIAQAAAA==.',['小恶']='小恶霸:BAAALAAECgYIDAAAAA==.',['小无']='小无赖:BAABLAAFFH8GAAIHAAIIlBXWgwBOAAAHAAIIlBXWgwBOAAAAAA==.',['小红']='小红牛:BAACLAAFFH8OAAICAAMIkAOTDQB3AAACAAMIkAOTDQB3AAAsAAQKfyAAAwIACAj7DlwKAJIBAAIACAjcDlwKAJIBABMABgiuBo8iAKMAAAAA.',['小茶']='小茶壶嘴嘴:BAAALAAECggIAQAAAA==.',['小诺']='小诺宝:BAABLAAFFH8FAAIHAAMIRxlqOACzAAAHAAMIRxlqOACzAAAAAA==.',['小趴']='小趴菜:BAAALAAECgIIAgAAAA==.',['小蹄']='小蹄子不用桨:BAAALAAFFAMIBAAAAA==.',['小野']='小野塚小町:BAAALAAECgYIDQAAAA==.',['小雨']='小雨天气:BAAALAAECgYIBwAAAA==.',['小马']='小马哇哇叫:BAAALAAFFAIIAgAAAA==.',['小骡']='小骡:BAAALAAFFAMIAwAAAA==.',['小鱼']='小鱼:BAAALAADCgUIBQAAAA==.',['小鸡']='小鸡丶:BAAALAADCgMIAwAAAA==.',['少侠']='少侠请留步:BAABLAAFFH8PAAIHAAYIZBE8PABSAQAHAAYIZBE8PABSAQAAAA==.',['少女']='少女榨汁机:BAABLAAECn8hAAILAAcIchHLGgBLAQALAAcIchHLGgBLAQAAAA==.',['少孑']='少孑:BAAALAADCgYIBgAAAA==.',['巧乐']='巧乐兹:BAABLAAFFH8OAAIEAAMI5hdYFgDKAAAEAAMI5hdYFgDKAAAAAA==.',['帅帅']='帅帅的阿昆达:BAAALAAECgYIEQAAAA==.',['带带']='带带我听到没:BAAALAAECgYIBgAAAA==.',['带球']='带球撞人:BAABLAAFFH8GAAIYAAYI0AYmLAA1AQAYAAYI0AYmLAA1AQAAAA==.',['常熟']='常熟伍佰:BAAALAADCgIIAgABLAAFFAgIHQABAAQVAA==.常熟陆佰:BAAALAAECgIIAgAAAA==.',['幻影']='幻影刚毛手:BAAALAAFFAIIBAAAAA==.',['式神']='式神:BAAALAAECgYICQAAAA==.',['张鳗']='张鳗鱼:BAACLAAFFH8OAAIGAAYIfxpBGACSAQAGAAYIfxpBGACSAQAsAAQKfxkAAgYACAjkIdsZAA0DAAYACAjkIdsZAA0DAAAA.',['彩色']='彩色的黒:BAAALAAECgYIBwAAAA==.',['影月']='影月寒锋:BAAALAAFFAIIAgAAAA==.',['影流']='影流丶劣人:BAAALAAECgYIBwAAAA==.',['往来']='往来井井:BAAALAAECgEIAQAAAA==.',['微微']='微微的风:BAABLAAFFH8FAAIXAAIIJxhtGQCTAAAXAAIIJxhtGQCTAAAAAA==.',['德拉']='德拉迪欧:BAAALAADCgMIAwAAAA==.',['心脏']='心脏撒撒给呦:BAAALAAECggIDAAAAA==.',['心艾']='心艾:BAAALAAECgEIAQAAAA==.',['忘归']='忘归人:BAAALAAECgYIBgAAAA==.',['快乐']='快乐鸟户:BAAALAAECgIIAgAAAA==.',['思念']='思念逆流成河:BAABLAAFFH8SAAMFAAgIURscAwCEAgAFAAgIURscAwCEAgAEAAgIhRPWBwAvAgAAAA==.',['总之']='总之非常可爱:BAAALAAECgYIDgAAAA==.',['恍若']='恍若微凉灬:BAAALAAFFAQIBAAAAA==.',['恶魔']='恶魔在身边:BAABLAAECn8ZAAIYAAgIQwwIPwBgAQAYAAgIQwwIPwBgAQAAAA==.恶魔龙丶:BAAALAAFFAIIAgAAAA==.',['愛随']='愛随风飘:BAAALAAECgYIBgAAAA==.',['愤怒']='愤怒的豆:BAAALAAECgcIDgAAAA==.',['我即']='我即圣光:BAABLAAFFH8GAAMJAAIIgwjXIQAnAAAGAAIIfwdXfQAzAAAJAAEIIwbXIQAnAAAAAA==.',['我是']='我是只猪才怪:BAAALAAFFAYIBAAAAA==.',['我来']='我来组成头部:BAACLAAFFH8fAAIWAAYIuxgQIwCPAQAWAAYIuxgQIwCPAQAsAAQKfyQAAxYACAj/HvApAJoCABYACAj/HvApAJoCABsAAggSHgokALMAAAAA.',['我的']='我的野蛮酸奶:BAABLAAFFH8FAAMGAAMIkAiFSwCWAAAGAAIIoQyFSwCWAAAJAAEIbQCXJAAhAAAAAA==.',['战歌']='战歌传说:BAAALAADCggICAAAAA==.',['战狼']='战狼魂依者:BAAALAAECgYIBgABLAAFFAgIJAAcAAYcAA==.',['手捏']='手捏小黄瓜:BAAALAAFFAMIAwAAAA==.',['把药']='把药给我留下:BAAALAADCgMIAwAAAA==.',['抹去']='抹去记忆丶:BAAALAAECgYIBgAAAA==.',['抽卡']='抽卡啊豆腐:BAAALAAECgQICAAAAA==.',['拔娜']='拔娜娜:BAAALAAECgYICQAAAA==.',['招财']='招财德:BAAALAADCggICAAAAA==.招财法:BAAALAAECgQIBAAAAA==.招财牧:BAAALAAFFAIIAgAAAA==.招财迪凯:BAAALAAECgEIAQAAAA==.招财骑:BAAALAAECgYIBgAAAA==.',['挨个']='挨个戒网瘾:BAAALAAECgYIDAAAAA==.',['放开']='放开那正太:BAAALAADCgIIAgAAAA==.',['放掉']='放掉那个正太:BAAALAADCgEIAgAAAA==.',['斐戾']='斐戾:BAAALAAECgYIBgAAAA==.',['新巴']='新巴克:BAAALAAECgYIEQAAAA==.',['施渊']='施渊契魔:BAAALAADCggICAAAAA==.',['施狩']='施狩星痕:BAAALAADCgYIBgAAAA==.',['无聊']='无聊的轩宝:BAAALAAECggICAAAAA==.',['时髦']='时髦小神仙:BAAALAAECgIIAgAAAA==.',['旺仔']='旺仔天天:BAAALAAECgYIBgAAAA==.旺仔小天:BAAALAAECgYIEQAAAA==.',['昆明']='昆明风:BAABLAAECn8sAAMVAAcIxw7oFgA2AQAVAAcIxw7oFgA2AQAdAAUI6gLuXAB5AAAAAA==.',['昏谜']='昏谜:BAAALAADCggIDgAAAA==.',['星辰']='星辰困叒:BAAALAAECgYICQAAAA==.',['星陨']='星陨寂滅:BAABLAAFFH8IAAMCAAIIgCL8DgCfAAACAAII0Bn8DgCfAAABAAEI0yTclwBaAAAAAA==.',['晓德']='晓德懂不懂:BAAALAAECgYICQAAAA==.',['晓月']='晓月无双:BAAALAADCgQIBAAAAA==.',['普雷']='普雷尔踢:BAAALAAECgYIBgAAAA==.',['晴天']='晴天小劣:BAAALAAFFAIIAgAAAA==.',['暗夜']='暗夜妖艳:BAAALAAECggICAAAAA==.暗夜救世主:BAAALAAECgYICQAAAA==.',['暗影']='暗影中的叹息:BAAALAAECggIDgAAAA==.暗影幻灵:BAACLAAFFH8hAAMUAAYI/BpUCQC/AQAUAAYI/BpUCQC/AQAQAAEI9wfETgA9AAAsAAQKfxQAAxQABghMFJRLAIkBABQABghMFJRLAIkBABAAAwhIBlWrAHMAAAAA.',['暗火']='暗火:BAAALAAECgYICAAAAA==.',['暗爽']='暗爽:BAAALAAECgMIAwAAAA==.',['暗黑']='暗黑骑士:BAAALAAECgYICgAAAA==.',['暴暴']='暴暴术爷:BAAALAADCgYIBgAAAA==.暴暴风云:BAAALAADCgQIBAAAAA==.暴暴风雨:BAAALAAECgUICAAAAA==.',['曾經']='曾經的人族:BAAALAAECgUIBQAAAA==.',['最后']='最后的小小明:BAABLAAFFH8YAAIRAAUISyApCgBvAQARAAUISyApCgBvAQAAAA==.',['月阴']='月阴琴:BAAALAADCgYIBgAAAA==.',['有蹄']='有蹄类恶魔:BAAALAAECgYIBgAAAA==.',['朝阳']='朝阳群众:BAAALAADCgIIAgAAAA==.',['木儿']='木儿弯弯:BAABLAAFFH8gAAIGAAYIlyJVCQD9AQAGAAYIlyJVCQD9AQAAAA==.',['未知']='未知单位:BAAALAAECgQIBAAAAA==.未知目標丶:BAAALAAECgYIEgAAAA==.',['未闻']='未闻花名:BAAALAAECggICAAAAA==.',['末日']='末日圣光:BAAALAADCgUIBQAAAA==.',['杀生']='杀生在握:BAABLAAFFH8GAAMLAAIIMhtiDAChAAALAAIIMhtiDAChAAAMAAIImAopawAkAAAAAA==.',['李与']='李与刘:BAAALAAECgYIBgAAAA==.',['李令']='李令月:BAAALAAECgIIAgAAAA==.',['李唐']='李唐李糖糖丶:BAABLAAECn8YAAIJAAgILSCbDgCXAgAJAAgILSCbDgCXAgAAAA==.',['杨教']='杨教授之吻:BAAALAADCggICAAAAA==.',['杰神']='杰神大妈:BAACLAAFFH8vAAIHAAcIWB+DDgAVAgAHAAcIWB+DDgAVAgAsAAQKf0QAAwcACAhDJlEJAE0DAAcACAhDJlEJAE0DAAgAAgjmEyKfAHgAAAAA.',['板甲']='板甲小脆皮:BAABLAAFFH8LAAIGAAYIgRBNCADiAQAGAAYIgRBNCADiAQAAAA==.',['林兒']='林兒:BAAALAAECgcIBwAAAA==.',['林寒']='林寒冰:BAAALAAFFAQIBAAAAA==.',['林橙']='林橙橙:BAAALAADCgYIBgAAAA==.',['果然']='果然不一样:BAAALAAECgUIBQAAAA==.',['标星']='标星光:BAAALAADCgcIBwAAAA==.',['根本']='根本不赢:BAAALAADCgUIBQAAAA==.根本不输:BAAALAADCgYIBgAAAA==.',['格瑞']='格瑞德:BAAALAAECgEIAQAAAA==.',['格蕾']='格蕾的手术:BAABLAAFFH8KAAIBAAIIoB1BSACoAAABAAIIoB1BSACoAAAAAA==.',['桃桃']='桃桃吃小面:BAAALAADCggICAAAAA==.桃桃吃牛排:BAAALAAECggICAAAAA==.',['桃花']='桃花落:BAAALAAECgIIAwAAAA==.',['桐儿']='桐儿宝宝:BAAALAAECgcIBwAAAA==.',['梧桐']='梧桐丶揍敌客:BAACLAAFFH8kAAMHAAUIoR75LwB4AQAHAAUIoR75LwB4AQAIAAMIoRTfEQDYAAAsAAQKfxgAAwgABwiDIOkkAEYCAAgABgjCIekkAEYCAAcAAwgCHqGvAAQBAAAA.',['棕榈']='棕榈:BAAALAAECgEIAQAAAA==.',['森语']='森语妙蛙种子:BAAALAADCgYIBgAAAA==.',['椰小']='椰小开:BAAALAADCgIIAgAAAA==.',['此情']='此情可待追忆:BAABLAAFFH8KAAIWAAYIASDMFgDTAQAWAAYIASDMFgDTAQAAAA==.',['武器']='武器酒吧:BAAALAAECggIBgAAAA==.',['武英']='武英殿大学士:BAABLAAFFH8rAAQJAAYI/hNoCAA3AQAGAAUImxUwJgBEAQAJAAYIbg1oCAA3AQAPAAIIBwbvLgA/AAAAAA==.',['死灵']='死灵奥兹:BAAALAAECgQICAAAAA==.',['死神']='死神豆:BAAALAAECgEIAQAAAA==.',['残月']='残月之魂:BAAALAADCgIIAgAAAA==.',['残酷']='残酷天使:BAAALAAFFAIIBAAAAA==.',['毒里']='毒里有奶:BAACLAAFFH8OAAMeAAUIYhbuRgCRAAAeAAUIYhbuRgCRAAADAAEI+geyVwAAAAAsAAQKfxQAAgMABgjEHHAgAKwBAAMABgjEHHAgAKwBAAAA.',['毛毛']='毛毛爱小二:BAACLAAFFH8FAAIGAAIINiFrNQCmAAAGAAIINiFrNQCmAAAsAAQKfx0AAgYABggoJu0gABcCAAYABggoJu0gABcCAAAA.',['水墨']='水墨晴:BAAALAAECgYIBgAAAA==.',['水月']='水月:BAABLAAFFH8lAAIGAAYIFCNSCgD0AQAGAAYIFCNSCgD0AQAAAA==.',['汐水']='汐水如墨:BAACLAAFFH8HAAIWAAIIlxTcOwCcAAAWAAIIlxTcOwCcAAAsAAQKfxwABBYACAh3FhgtAJwBABYACAh3FhgtAJwBAB8ABggwDQIXAFYBABsABQgUC0pdAAIBAAEsAAUUAggMAAYAHSAA.',['江上']='江上一归人:BAAALAAECgYIBwAAAA==.',['没奶']='没奶硬钢:BAAALAAFFAIIAgAAAA==.',['沧浪']='沧浪之水:BAABLAAFFH8GAAIeAAYIsRCpIABXAQAeAAYIsRCpIABXAQAAAA==.',['沿途']='沿途右旋:BAAALAAFFAIIAgAAAA==.',['法神']='法神戒指:BAABLAAFFH8GAAMHAAYIywtiVQD4AAAHAAUIog1iVQD4AAAIAAEImgJXGgA1AAAAAA==.',['泡抹']='泡抹:BAAALAAECgYIBgAAAA==.',['泡沫']='泡沫白咖啡:BAAALAAECgMIAwAAAA==.',['注视']='注视光明:BAABLAAFFH8HAAIGAAUIAhHgKQAvAQAGAAUIAhHgKQAvAQAAAA==.',['泰瑞']='泰瑞尔丶破晓:BAABLAAFFH8FAAIGAAMIlxagQwCJAAAGAAMIlxagQwCJAAAAAA==.',['洛丹']='洛丹伦余晖:BAABLAAFFH8FAAIGAAIIoQtddwA5AAAGAAIIoQtddwA5AAAAAA==.',['流风']='流风回雪:BAAALAAECgIICQAAAA==.',['浅听']='浅听枫吟:BAABLAAFFH8RAAIBAAYIpggFRQAmAQABAAYIpggFRQAmAQAAAA==.',['浪人']='浪人:BAAALAAFFAIIBAAAAA==.',['海洋']='海洋不是羊:BAABLAAFFH8GAAIKAAIIbA3HEwBkAAAKAAIIbA3HEwBkAAAAAA==.',['海豹']='海豹大王:BAABLAAFFH8GAAIQAAIIqQprQgBmAAAQAAIIqQprQgBmAAAAAA==.',['混混']='混混达吉:BAAALAAECgQIBAAAAA==.',['清淵']='清淵煙寂:BAACLAAFFH8WAAIYAAYIZhtuFgC0AQAYAAYIZhtuFgC0AQAsAAQKfxwAAhgABwhsITI4AH0CABgABwhsITI4AH0CAAAA.',['满江']='满江红:BAABLAAFFH8MAAMBAAYI2Aa/VAC6AAABAAUINgi/VAC6AAATAAEIAAAAAAAAAAAAAA==.',['滴血']='滴血残阳:BAAALAAECgYIEgAAAA==.',['火跑']='火跑发魅魔:BAAALAADCgMIAwAAAA==.',['灬貂']='灬貂蝉:BAACLAAFFH8VAAMbAAUIFhuZAwBBAQAbAAUIFhuZAwBBAQAWAAEIjRiUWABHAAAsAAQKfxgAAxsACAgyHh8LALABABsACAh5HR8LALABABYABAiqDPXcAJ0AAAAA.',['灵能']='灵能:BAABLAAFFH8OAAIYAAYIXAO8NgDGAAAYAAYIXAO8NgDGAAAAAA==.',['炎发']='炎发灼眼:BAAALAADCgIIAgAAAA==.',['炫月']='炫月雪:BAABLAAFFH8GAAIeAAIIAhjESACMAAAeAAIIAhjESACMAAAAAA==.',['热血']='热血猎神:BAABLAAFFH8MAAIHAAII/whVfgBoAAAHAAII/whVfgBoAAAAAA==.',['熊猫']='熊猫不是猫:BAABLAAFFH8PAAMBAAMIyBGQLwDdAAABAAMIrxGQLwDdAAATAAEILwcsHAAwAAAAAA==.熊猫圆滚滚:BAABLAAECn8hAAIHAAcIcxkqPwDOAQAHAAcIcxkqPwDOAQAAAA==.熊猫混混:BAAALAAECgMIAwAAAA==.',['燕同']='燕同心:BAABLAAFFH8GAAIRAAYI0hUUCQCGAQARAAYI0hUUCQCGAQAAAA==.',['爱吃']='爱吃猫的鱼:BAABLAAECn8cAAIDAAcIcBT7SwDYAQADAAcIcBT7SwDYAQAAAA==.',['爱斯']='爱斯寂寞人:BAAALAAECgQIBAAAAA==.',['爱的']='爱的火铳炮:BAACLAAFFH8KAAMYAAMI1A3JQgCBAAAYAAMI1A3JQgCBAAAKAAEIlgwAAAAAAAAsAAQKfxwAAxgACAgrFYE2AH8BABgACAglFYE2AH8BAAoAAQghCTFpAC0AAAAA.',['牛小']='牛小黑:BAAALAAECgIIAgAAAA==.',['牛爸']='牛爸爸:BAAALAAFFAMIAwAAAA==.',['牛肉']='牛肉汤很好吃:BAABLAAECn8UAAMJAAYIKQ+6TAD7AAAJAAYIPwy6TAD7AAAGAAUIvQ5enADHAAAAAA==.',['牧云']='牧云暗:BAACLAAFFH8aAAIBAAUIShk5HABAAQABAAUIShk5HABAAQAsAAQKfxYAAgEABgiNIZGGAO4BAAEABgiNIZGGAO4BAAAA.',['牧有']='牧有治疗:BAAALAAECggICAAAAA==.',['狂躁']='狂躁的哈士奇:BAABLAAFFH8IAAIBAAIIiBlBcQBQAAABAAIIiBlBcQBQAAAAAA==.',['狂野']='狂野怒火:BAABLAAFFH8cAAIHAAYIYx9iHADBAQAHAAYIYx9iHADBAQAAAA==.',['猛虎']='猛虎下山:BAABLAAFFH8IAAMdAAYIFxAxCABvAQAdAAYIFxAxCABvAQAaAAIIAAAAAAAAAAAAAA==.',['猫咪']='猫咪酒仙:BAABLAAFFH8HAAIaAAYI5g+PEABBAQAaAAYI5g+PEABBAQAAAA==.',['猫妖']='猫妖丶:BAAALAADCgMIBAAAAA==.',['猫爪']='猫爪挠树皮:BAAALAAFFAEIAQAAAA==.',['猫猫']='猫猫飒:BAAALAAECgEIAQAAAA==.',['玄武']='玄武:BAAALAAECgYIBgAAAA==.',['王灵']='王灵:BAAALAAECgUIDQAAAA==.',['玲了']='玲了个玲:BAAALAAFFAEIAQAAAA==.',['玲儿']='玲儿响叮当:BAAALAAECgYIAgAAAA==.',['瑞兹']='瑞兹:BAABLAAECn8UAAIDAAYIVxZkXACiAQADAAYIVxZkXACiAQAAAA==.',['瑞芳']='瑞芳特:BAAALAAECgYIBgAAAA==.',['瓜瓜']='瓜瓜本色丶:BAABLAAECn8VAAIBAAgIaBP0MwCoAQABAAgIaBP0MwCoAQAAAA==.',['生命']='生命的另一瓣:BAAALAAECgYIBgAAAA==.生命的另依半:BAAALAAECgQIBAAAAA==.',['生死']='生死由命:BAACLAAFFH8zAAIGAAcIjCIhBABMAgAGAAcIjCIhBABMAgAsAAQKfyYAAgYACAgIJCsnANQCAAYACAgIJCsnANQCAAAA.',['生猛']='生猛路过:BAAALAAECgQIBAAAAA==.',['电视']='电视遥控器:BAAALAAECgUIBQAAAA==.',['电话']='电话沟通:BAAALAAECgYICgAAAA==.',['略懂']='略懂一些拳脚:BAAALAAECgEIAQAAAA==.',['疯狂']='疯狂打铁:BAAALAAECgQIBAAAAA==.疯狂的狼:BAAALAAECgMIAwAAAA==.',['病名']='病名为爱:BAAALAAECgIIAgAAAA==.',['皛萨']='皛萨摩:BAABLAAFFH8IAAIeAAIIwQkGagBRAAAeAAIIwQkGagBRAAAAAA==.',['相当']='相当容易困:BAABLAAFFH8GAAIYAAYIyAsMJQBlAQAYAAYIyAsMJQBlAQAAAA==.',['石原']='石原里美:BAAALAADCgQIBAAAAA==.',['神燕']='神燕风雷:BAAALAADCgIIAgAAAA==.',['神谕']='神谕者迪萨克:BAAALAAECgQIBQAAAA==.',['秋恩']='秋恩:BAAALAAECgYIBgAAAA==.',['窝窝']='窝窝头一块捌:BAAALAAFFAIIBAAAAA==.',['竹韵']='竹韵幽幽:BAAALAAECgYIBgAAAA==.',['笑忘']='笑忘书:BAAALAAECgQIBgAAAA==.',['第二']='第二条咸鱼:BAABLAAFFH8GAAIGAAIIEBhLMwCoAAAGAAIIEBhLMwCoAAAAAA==.',['等到']='等到花開:BAACLAAFFH8LAAIDAAMIFBjwGADrAAADAAMIFBjwGADrAAAsAAQKfyMAAgMACAhhH94aAMcCAAMACAhhH94aAMcCAAAA.',['米兔']='米兔不是兔:BAABLAAFFH8IAAILAAMInwuzCQC2AAALAAMInwuzCQC2AAAAAA==.',['米凯']='米凯拉的王:BAAALAAECgYIDgAAAA==.',['糖果']='糖果纸潜行者:BAAALAADCgcIBwAAAA==.',['糯米']='糯米兮兮:BAAALAAECgQICQAAAA==.',['索利']='索利达尔群星:BAAALAAECgEIAQAAAA==.',['紫月']='紫月六天:BAAALAAECgYIBwAAAA==.紫月残风:BAAALAADCggICAAAAA==.',['紫菱']='紫菱:BAABLAAFFH8IAAIHAAgIzxlyCQBKAgAHAAgIzxlyCQBKAgAAAA==.',['紫霞']='紫霞一仙子:BAACLAAFFH8OAAILAAMI9BbjDACJAAALAAMI9BbjDACJAAAsAAQKfxwAAgsACAg8I4sDALgCAAsACAg8I4sDALgCAAAA.',['紫韵']='紫韵:BAAALAAECgcIBwAAAA==.',['繁花']='繁花落尽清风:BAAALAAECgEIAQAAAA==.',['红眼']='红眼打火:BAABLAAECn8tAAMeAAYIZBAXTwAeAQAeAAYIZBAXTwAeAQADAAYIUw6RQgADAQAAAA==.',['红酥']='红酥手:BAAALAAECgIIAgAAAA==.',['给你']='给你一猫鞭:BAAALAAECgYIDAAAAA==.',['美大']='美大汹:BAAALAAECgYIBgAAAA==.',['老玖']='老玖:BAACLAAFFH8KAAINAAMIiyRTMADKAAANAAMIiyRTMADKAAAsAAQKfxQAAg0ABwjwIRkUAEICAA0ABwjwIRkUAEICAAAA.',['老石']='老石头:BAAALAAECgYIBgAAAA==.',['联盟']='联盟小小战:BAABLAAECn8XAAINAAgIFx0FMAB4AgANAAgIFx0FMAB4AgAAAA==.',['胖胖']='胖胖隼:BAACLAAFFH8SAAIEAAII5hpfOACKAAAEAAII5hpfOACKAAAsAAQKf0MABAQACAiIFzUdAOcBAAQACAiIFzUdAOcBAAUABgjIGloeAHsBACAABggaBpUzAO8AAAAA.',['胡汉']='胡汉三:BAAALAAECgYIBwAAAA==.',['腋毛']='腋毛乱舞:BAABLAAFFH8GAAIDAAYIvRaxGAB5AQADAAYIvRaxGAB5AQAAAA==.',['舞指']='舞指弹奏:BAABLAAFFH8MAAIEAAYIUxxhAwAJAgAEAAYIUxxhAwAJAgAAAA==.',['范迪']='范迪赛尔丶:BAAALAAECgUIBwAAAA==.',['茉茉']='茉茉菱菱:BAAALAAECggICAAAAA==.',['莎拉']='莎拉嘿呦:BAAALAAECgMIBQAAAA==.',['菁丶']='菁丶橙:BAAALAAECgYICwAAAA==.',['菁媛']='菁媛:BAAALAAECgYIBgAAAA==.',['菜比']='菜比大熊:BAABLAAFFH8MAAIaAAYIDw1YEQA0AQAaAAYIDw1YEQA0AQAAAA==.',['菜菜']='菜菜丶遥:BAABLAAFFH8KAAMPAAYI8hhZDAC/AQAPAAYI8hhZDAC/AQAGAAEIHQP+iQAAAAAAAA==.',['萌萌']='萌萌哒夢魇:BAAALAADCgcICQAAAA==.',['萨安']='萨安的萨:BAAALAAECgQIBAAAAA==.',['落墨']='落墨点清颜:BAAALAADCgUIBQAAAA==.',['落寞']='落寞之夜:BAAALAAECgcIBwAAAA==.',['落霞']='落霞孤鹜:BAAALAAECgYIBgAAAA==.',['葉丶']='葉丶傷:BAABLAAFFH8IAAIBAAIIUhrtVQCdAAABAAIIUhrtVQCdAAAAAA==.',['蒲公']='蒲公英的旅行:BAABLAAECn8XAAINAAgIoCJLCgCqAgANAAgIoCJLCgCqAgAAAA==.',['蒹葭']='蒹葭采采:BAAALAADCgUIBQAAAA==.',['蔓囨']='蔓囨經惢:BAAALAAFFAIIBAAAAA==.',['蕾熙']='蕾熙槟果丶:BAAALAADCgYIBgAAAA==.',['虎妞']='虎妞子:BAAALAAECgYIBgAAAA==.',['虚空']='虚空术爷:BAAALAAECgYIEgAAAA==.',['蚀龙']='蚀龙:BAAALAAECgYICwAAAA==.',['蜜汁']='蜜汁脆皮:BAAALAADCgcIBwAAAA==.',['蜜雪']='蜜雪病橙:BAAALAAECgUIBwAAAA==.',['蝶舞']='蝶舞寒殇:BAAALAAFFAIIAwAAAA==.',['血吼']='血吼:BAABLAAFFH8GAAMOAAIIzRKLBACXAAAOAAIIzRKLBACXAAANAAEIHQvraQAAAAAAAA==.',['血色']='血色荣耀:BAAALAAECgYICgAAAA==.',['被秒']='被秒杀的帅哥:BAAALAAFFAgIAgAAAA==.',['裤兜']='裤兜子:BAABLAAFFH8WAAIHAAUIZSHlKQCMAQAHAAUIZSHlKQCMAQAAAA==.',['西北']='西北望长安:BAAALAAECgMIAwAAAA==.',['西玛']='西玛塔丶棍子:BAAALAAECgMIAwAAAA==.',['要你']='要你小命三千:BAAALAAECgUIBwAAAA==.',['言承']='言承旭:BAABLAAFFH8pAAMeAAYI6iG8CAA5AgAeAAYI6iG8CAA5AgADAAEIfg1vPwBLAAAAAA==.',['许多']='许多多:BAACLAAFFH8MAAIGAAIIaiAyTgBdAAAGAAIIaiAyTgBdAAAsAAQKfyYAAgYABghlJXMiAA8CAAYABghlJXMiAA8CAAEsAAUUAggQABEAlh0A.',['识丶']='识丶时务者:BAAALAAFFAIIBAAAAA==.',['请你']='请你吃药:BAAALAAECgYIBgAAAA==.',['调月']='调月莉音:BAAALAAFFAQIBAAAAA==.',['豚豚']='豚豚:BAAALAAECgUIBQAAAA==.',['豪情']='豪情叒弱:BAAALAAECgIIAgAAAA==.',['贝丶']='贝丶壳:BAAALAAECgQIBAAAAA==.',['败者']='败者食尘丶:BAAALAAECgYIBgAAAA==.',['贰惑']='贰惑丶吼:BAAALAAECgYIBgAAAA==.',['贺兰']='贺兰岿然:BAAALAAECgUIBgAAAA==.',['超高']='超高校级妹控:BAAALAAECgYIBgAAAA==.',['跳跳']='跳跳球:BAAALAAECgUIBQAAAA==.',['轩宝']='轩宝很无聊:BAAALAADCgYICAAAAA==.',['达瓦']='达瓦里氏:BAAALAAECgMIAwAAAA==.',['这个']='这个萨有点电:BAAALAAFFAIIBAAAAA==.',['远程']='远程停手:BAAALAADCgEIAQAAAA==.',['迷茫']='迷茫的羔羊:BAAALAAFFAIIAgAAAA==.',['逆天']='逆天九刃:BAAALAAFFAIIAgAAAA==.',['透心']='透心凉灬:BAAALAAECgEIAQAAAA==.',['逐日']='逐日伯爵:BAABLAAECn8UAAIhAAYIAxtmAwClAQAhAAYIAxtmAwClAQAAAA==.',['逝之']='逝之星辰:BAAALAAECgQIBAAAAA==.',['遥丶']='遥丶小望:BAAALAAFFAIIAgAAAA==.',['那刻']='那刻夏:BAAALAAFFAIIAgAAAA==.',['酱香']='酱香后仰:BAAALAADCgcIBwAAAA==.',['醉卧']='醉卧美人膝:BAAALAAECgYIAgAAAA==.',['重铸']='重铸恶魔之痕:BAAALAAECggICAAAAA==.',['野嘼']='野嘼追猎者:BAABLAAFFH8GAAIHAAIIDSRqMwC9AAAHAAIIDSRqMwC9AAAAAA==.',['野的']='野的原新之助:BAAALAADCgcICwAAAA==.',['野蛮']='野蛮小喵:BAAALAADCgEIAQAAAA==.',['野野']='野野喔:BAABLAAFFH8ZAAMHAAYIdCSmDAAkAgAHAAYIdCSmDAAkAgAIAAEIiBCkFABHAAAAAA==.',['金色']='金色聖騎士:BAAALAAECgYIBgAAAA==.',['釺羽']='釺羽:BAAALAAECgYIBgAAAA==.',['鐵幕']='鐵幕:BAAALAADCgIIAgAAAA==.',['铁臂']='铁臂阿童木:BAACLAAFFH8MAAIBAAIIEh+oSwCkAAABAAIIEh+oSwCkAAAsAAQKfxkAAwEACAiFI6sQADADAAEACAiFI6sQADADAAIAAwiiE4NBANAAAAAA.',['镶钻']='镶钻的吨吨桶:BAAALAAECgYIBgAAAA==.',['闪小']='闪小芳:BAAALAAFFAEIAQAAAA==.',['阝偲']='阝偲灬:BAAALAAECgQIBgAAAA==.',['阴阳']='阴阳天罡:BAAALAAFFAIIAgAAAA==.',['阿格']='阿格莱雅:BAAALAADCgYICwAAAA==.',['阿米']='阿米尔汗:BAAALAADCgEIAQAAAA==.',['阿萨']='阿萨咖啡机:BAAALAAECgIIAgAAAA==.',['陇上']='陇上张不不:BAAALAADCgEIAQAAAA==.',['雁山']='雁山之霭:BAAALAAECgYIEgAAAA==.',['雅誰']='雅誰娅蕾丶:BAAALAAFFAIIAgAAAA==.',['雨之']='雨之丫丫:BAAALAAECgYICgAAAA==.',['雪丶']='雪丶月:BAAALAAFFAIIAwAAAA==.',['雷落']='雷落千军破:BAAALAAECgYIBgAAAA==.',['霞姿']='霞姿月韵丶:BAABLAAFFH8KAAIeAAUIpA8SKwAOAQAeAAUIpA8SKwAOAQAAAA==.',['青山']='青山:BAAALAAECggIEAAAAA==.',['风中']='风中狂沙:BAAALAAFFAIIAwAAAA==.风中的忧伤:BAAALAAECgEIAQAAAA==.',['风雪']='风雪星辰:BAACLAAFFH8FAAIHAAIIKBszQwChAAAHAAIIKBszQwChAAAsAAQKfxkAAwcABgiIInNKAEwCAAcABgiIInNKAEwCAAgAAwgbEXWZAIkAAAAA.风雪迹:BAAALAAECgYICwAAAA==.',['风雷']='风雷扛把子:BAAALAAFFAIIAgAAAA==.',['飘飖']='飘飖兮若流风:BAAALAAFFAIIAgAAAA==.',['飛絮']='飛絮憶雪:BAAALAAECgIIAgAAAA==.',['飞翔']='飞翔:BAAALAAECgYIDAAAAA==.飞翔归来:BAABLAAFFH8RAAIGAAUIax5bIgBaAQAGAAUIax5bIgBaAQAAAA==.',['马老']='马老师摸电门:BAAALAAECgYIDwAAAA==.',['高小']='高小恒:BAAALAAFFAIIAgAAAA==.',['魅力']='魅力勿忘:BAAALAAECgIIAgAAAA==.魅力点射:BAAALAAECgMIAwAAAA==.',['魉魉']='魉魉:BAAALAADCgYIBgAAAA==.',['魑魅']='魑魅蛊惑:BAABLAAFFH8GAAIWAAIIqwlwawA1AAAWAAIIqwlwawA1AAAAAA==.魑魅诱导:BAABLAAFFH8IAAIQAAIIXwnTQwBjAAAQAAIIXwnTQwBjAAAAAA==.',['鱼小']='鱼小满:BAACLAAFFH8QAAIRAAIIlh3/EgCxAAARAAIIlh3/EgCxAAAsAAQKfzIAAhEABgjyJG8UAHcCABEABgjyJG8UAHcCAAAA.鱼小蛮:BAACLAAFFH8OAAIBAAIIsR98cwBNAAABAAIIsR98cwBNAAAsAAQKfxsAAgEABghaIiBcAD0CAAEABghaIiBcAD0CAAEsAAUUAggQABEAlh0A.',['鲍鲍']='鲍鲍:BAABLAAFFH8qAAIDAAYIIRl9CAD3AQADAAYIIRl9CAD3AQAAAA==.',['鸟德']='鸟德吹一下:BAAALAADCgcIBwAAAA==.',['鸟飞']='鸟飞绝:BAABLAAECn8YAAIIAAYIDhw2CwCeAQAIAAYIDhw2CwCeAQAAAA==.',['麦基']='麦基七号:BAAALAAECgEIAQAAAA==.',['麦芽']='麦芽:BAAALAAECgUIBQAAAA==.',['黑天']='黑天使:BAAALAAECgQIDwAAAA==.',['黑手']='黑手妖:BAAALAAECgYIBwAAAA==.',['黑月']='黑月:BAAALAADCgYIBgAAAA==.',['黑神']='黑神话小德:BAAALAADCgQIBAAAAA==.',['黑飞']='黑飞龙:BAAALAAECgYIDQAAAA==.',['黑骨']='黑骨头:BAAALAAECgcIDAAAAA==.',['黒骨']='黒骨髓:BAAALAAECgcIDQAAAA==.',['龙冕']='龙冕:BAAALAAFFAIIAgAAAA==.',['龙哥']='龙哥哥:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end