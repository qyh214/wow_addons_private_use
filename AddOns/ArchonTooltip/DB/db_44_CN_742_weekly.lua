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
 local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','Paladin-Retribution','Paladin-Protection','Hunter-BeastMastery','Hunter-Survival','DemonHunter-Havoc','Priest-Shadow','Priest-Holy','Shaman-Elemental','Mage-Frost','Mage-Arcane','Warlock-Destruction','Warlock-Affliction','Shaman-Restoration','Druid-Balance','DeathKnight-Blood','Hunter-Marksmanship','Warrior-Fury','Monk-Windwalker','Monk-Brewmaster','Druid-Restoration','Warlock-Demonology','Druid-Guardian','Rogue-Assassination','Paladin-Holy','Monk-Mistweaver','Priest-Discipline','Warrior-Protection','DemonHunter-Vengeance','Mage-Fire','Unknown-Unknown',}; local provider = {region='CN',realm='火焰之树',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alzf:BAAALAAECgIIAgAAAA==.',Ar='Arrietty:BAAALAAECgcIDQAAAA==.',Ba='Backstab:BAAALAAFFAIIAgAAAA==.',Be='Be:BAAALAAECgUIBQAAAA==.',Bl='Bloodglory:BAABLAAFFH8GAAMBAAYIpxZLFgCTAQABAAUIQhpLFgCTAQACAAEInQQDGgBZAAAAAA==.',Ca='Carpediem:BAABLAAFFH8GAAIBAAIIMhHYjwA+AAABAAIIMhHYjwA+AAAAAA==.',Ce='Celebrindal:BAAALAAECgYIBgAAAA==.',De='Deadlight:BAAALAAECgQIBgAAAA==.Demagic:BAAALAAECgIIAgAAAA==.',Di='Diehard:BAAALAAECgYIBgAAAA==.',Fa='Fallenlight:BAAALAAECgEIAQAAAA==.',Fi='Firedreame:BAAALAAECgQIBAAAAA==.',Fo='Foceanusx:BAABLAAECn8XAAMDAAcIliUtHQD+AgADAAcIliUtHQD+AgAEAAEIegmofQAjAAAAAA==.',Fr='Frantic:BAAALAADCgIIAgAAAA==.',Fu='Furacaneye:BAAALAADCgIIAwAAAA==.',Ga='Gallagher:BAABLAAFFH8MAAMFAAII3CDwgQBSAAAGAAIIQQuuBgB6AAAFAAII3CDwgQBSAAAAAA==.',Ge='Gevin:BAAALAAECgUIBQAAAA==.',Ka='Kaneli:BAABLAAFFH8LAAIBAAYIrA0/OwBOAQABAAYIrA0/OwBOAQAAAA==.',Ki='Kinico:BAAALAADCgEIAQAAAA==.Kiyomi:BAABLAAECn8ZAAMDAAcIixdKPQClAQADAAcIbRdKPQClAQAEAAEIThfocQBGAAAAAA==.',La='Landw:BAAALAADCgQIBAAAAA==.',Le='Lebewohl:BAABLAAFFH8HAAIHAAUIzQxELwAeAQAHAAUIzQxELwAeAQAAAA==.',Ma='Mary:BAABLAAFFH8GAAMIAAYIyQp1GQDmAAAIAAMIJxR1GQDmAAAJAAMIGwxQLgC0AAAAAA==.',Mi='Miss:BAAALAAECgcICwAAAA==.Misscure:BAAALAAECgYICAAAAA==.',['Mà']='Màyùyú:BAAALAADCgEIAQAAAA==.',Ob='Obilivate:BAABLAAECn8aAAIBAAgIhg3HtwCkAQABAAgIhg3HtwCkAQAAAA==.',Oc='Octobersky:BAAALAADCgEIAQAAAA==.',Or='Orionz:BAAALAADCgQIBAAAAA==.',Pd='Pd:BAAALAADCgIIAgAAAA==.',Pl='Playergcyqre:BAAALAADCgQIBAAAAA==.Playerxgjmhs:BAAALAADCggIDgAAAA==.Pluviophile:BAACLAAFFH8PAAIJAAMIDyT4HQDKAAAJAAMIDyT4HQDKAAAsAAQKfzAAAwkACAiKJNYKABEDAAkACAiKJNYKABEDAAgAAwjlBrWGAIcAAAAA.',Sa='Sadaharur:BAAALAADCggICQAAAA==.Sagiittarius:BAAALAAECgYIBgAAAA==.',Sh='Shadowlight:BAAALAAECgUIBgAAAA==.',Sl='Sledge:BAAALAAECgEIAQAAAA==.',So='Soapshamans:BAACLAAFFH8LAAIKAAMITwlEOQBzAAAKAAMITwlEOQBzAAAsAAQKf0cAAgoACAjuHwsKAIUCAAoACAjuHwsKAIUCAAAA.',Su='Sumail:BAAALAAECgQIBAAAAA==.Supermage:BAAALAADCgQIBAAAAA==.Superranger:BAAALAADCgIIAgAAAA==.',Ta='Tankpanzer:BAAALAADCgEIAQAAAA==.',Te='Tera:BAABLAAFFH8GAAIFAAYI1hv1HgC2AQAFAAYI1hv1HgC2AQAAAA==.',Th='Thalorian:BAABLAAECn8VAAMLAAYIKR9oPQB8AQAMAAYI/xyHbwC7AQALAAYIkh1oPQB8AQAAAA==.',Ty='Typer:BAAALAAECgYIBwAAAA==.',Vi='Vi:BAAALAADCgIIAgAAAA==.',Wa='Wantpeach:BAAALAAECgUIBQAAAA==.',Wi='Wills:BAAALAAFFAMIAwAAAA==.',Wu='Wuyifan:BAAALAAFFAIIAgABLAAFFAYIEgABAFgXAA==.',Xl='Xll:BAACLAAFFH8GAAMNAAYIwxI3FwCeAQANAAUI8xU3FwCeAQAOAAEI0QL3BgBVAAAsAAQKfxQAAg0ABghLFTs+AE8BAA0ABghLFTs+AE8BAAAA.',Xz='Xz:BAAALAAECgYICQAAAA==.',Ya='Yanmie:BAAALAADCgUIBQAAAA==.',['一丶']='一丶绿:BAAALAAECgEIAQAAAA==.',['一刀']='一刀灬见血:BAABLAAFFH8IAAIDAAII4R5iNACnAAADAAII4R5iNACnAAAAAA==.',['一朵']='一朵祥云:BAABLAAFFH8KAAIMAAIImhcnTQCTAAAMAAIImhcnTQCTAAAAAA==.',['一氵']='一氵點氺一:BAABLAAFFH8IAAMFAAIIuA2DZACIAAAFAAIIuA2DZACIAAAGAAII2gLIBgB0AAAAAA==.',['一牧']='一牧十夯:BAAALAAFFAYIBAAAAA==.',['一眾']='一眾丨思念:BAAALAAFFAIIBAAAAA==.一眾丨掛念:BAAALAAFFAIIAgAAAA==.',['一色']='一色日和:BAABLAAFFH8MAAILAAIIbhp1EQBUAAALAAIIbhp1EQBUAAAAAA==.',['七月']='七月初二:BAAALAADCgIIAgAAAA==.',['七焰']='七焰之夏尔米:BAAALAAECgEIAQAAAA==.',['三井']='三井兽:BAAALAADCgIIAgAAAA==.',['三球']='三球四柱:BAAALAADCgIIAgAAAA==.',['不是']='不是哥们:BAAALAAECgEIAQAAAA==.',['不死']='不死七月:BAAALAADCgMIAwAAAA==.',['东北']='东北小玉:BAAALAAECgYIBgAAAA==.',['东海']='东海三公主:BAAALAAECgYIBgAAAA==.',['丨小']='丨小术丨:BAAALAAECgYICgAAAA==.丨小粥粥:BAAALAADCgEIAQAAAA==.',['丶光']='丶光之刹那:BAAALAAFFAMIAwAAAA==.',['丶妒']='丶妒丶:BAAALAAECgYIBgAAAA==.',['丶年']='丶年华易逝丶:BAABLAAFFH8RAAIPAAIIaSTsNwDDAAAPAAIIaSTsNwDDAAAAAA==.',['丶康']='丶康斯坦丁:BAAALAAECgIIAgAAAA==.',['丶我']='丶我是刹那:BAABLAAFFH8UAAIFAAYI+hvyKACQAQAFAAYI+hvyKACQAQAAAA==.',['丶汏']='丶汏镁钕:BAABLAAFFH8MAAIBAAYIsBSNJwCXAQABAAYIsBSNJwCXAQAAAA==.',['丶牛']='丶牛大德:BAAALAAECgYIBgAAAA==.',['丶阿']='丶阿丁灬:BAAALAAFFAYIAgAAAA==.',['丶随']='丶随风:BAAALAAECgQIBAAAAA==.',['乌拉']='乌拉:BAABLAAFFH8GAAIQAAYIBBNWBgDkAQAQAAYIBBNWBgDkAQAAAA==.',['乜许']='乜许会有日落:BAAALAAECgYIDQAAAA==.',['九月']='九月小仙儿:BAAALAAECgIIAgAAAA==.',['九霄']='九霄烟雨:BAACLAAFFH8HAAIBAAMIvQq3ZQB/AAABAAMIvQq3ZQB/AAAsAAQKfxgAAgEACAjKGAIlAOMBAAEACAjKGAIlAOMBAAAA.',['二三']='二三七:BAAALAAFFAIIAgAAAA==.',['二手']='二手医生:BAAALAAECgUICAABLAAFFAgIGwARAPIcAA==.',['二营']='二营长:BAAALAAECgIIAgAAAA==.',['互锁']='互锁解除:BAAALAADCgEIAQAAAA==.',['亚洲']='亚洲梅西:BAAALAAFFAIIAgAAAA==.亚洲舞王赵四:BAACLAAFFH8NAAIPAAMIGhKELACqAAAPAAMIGhKELACqAAAsAAQKfxwAAw8ACAhUHIYmAHgCAA8ACAhUHIYmAHgCAAoAAQjHAwrcACIAAAAA.',['亡魂']='亡魂雇佣军:BAABLAAFFH8OAAIBAAYI/BAtEADTAQABAAYI/BAtEADTAQAAAA==.',['亿万']='亿万少女的梦:BAACLAAFFH8mAAIBAAYIfyVeDgDkAQABAAYIfyVeDgDkAQAsAAQKfxYAAgEABgixI0JeADkCAAEABgixI0JeADkCAAAA.',['从小']='从小就爱浪:BAAALAAFFAIIBAAAAA==.',['以帅']='以帅服人丶:BAAALAAFFAIIBAAAAA==.',['伊泽']='伊泽奈亚子:BAAALAADCggICAAAAA==.',['伊露']='伊露希尔:BAAALAAECgUIBgAAAA==.',['伱哥']='伱哥:BAAALAAECgQIBAAAAA==.',['似火']='似火流年丶:BAAALAADCgQIBAAAAA==.',['低乔']='低乔热介:BAABLAAFFH8GAAIDAAYIHANgQACTAAADAAYIHANgQACTAAAAAA==.',['你我']='你我相爱相杀:BAAALAADCgUIBQAAAA==.',['你看']='你看我硬吗:BAAALAAFFAIIAgAAAA==.你看看你:BAAALAAECgYIBgAAAA==.',['俊少']='俊少爷:BAACLAAFFH8PAAIFAAMIOQilQwChAAAFAAMIOQilQwChAAAsAAQKfyIAAwUACAhaFbR5AOoBAAUACAhaFbR5AOoBABIABwibDIBhADkBAAAA.',['修罗']='修罗丶魅影:BAAALAAECgYIBgAAAA==.',['俯瞰']='俯瞰风景:BAAALAAECgEIAQAAAA==.',['假装']='假装很凶狠:BAAALAADCgYIBgAAAA==.',['做则']='做则可成:BAABLAAECn8UAAIQAAYISQM4hwCnAAAQAAYISQM4hwCnAAAAAA==.',['偷心']='偷心猎:BAABLAAFFH8OAAIFAAgI2h8tBQCbAgAFAAgI2h8tBQCbAgAAAA==.',['免费']='免费:BAAALAAECgYICAAAAA==.',['兩手']='兩手揣兜:BAAALAAECgEIAQAAAA==.',['八仙']='八仙桌骑士:BAAALAAFFAIIAgAAAA==.',['八级']='八级大狂風:BAABLAAFFH8GAAITAAYI+wliIQBiAQATAAYI+wliIQBiAQAAAA==.',['内个']='内个先别说话:BAAALAAECgYIBgAAAA==.内个来贴贴:BAACLAAFFH8LAAIPAAMICBoWGQDoAAAPAAMICBoWGQDoAAAsAAQKfyAAAwoACAi6ERdJAOIBAAoACAi6ERdJAOIBAA8ABAgwFsXQAOgAAAAA.',['再玩']='再玩壹两天:BAACLAAFFH8GAAIKAAIIPAmASQA+AAAKAAIIPAmASQA+AAAsAAQKfxgAAgoABwhPGHgeALoBAAoABwhPGHgeALoBAAAA.',['冰卝']='冰卝空:BAAALAAECgYIDQAAAA==.',['冰封']='冰封之月:BAAALAAECgYICgAAAA==.',['冰彡']='冰彡空:BAAALAAECgUIDgAAAA==.',['凉开']='凉开水:BAAALAAECgQIBwAAAA==.',['凵凵']='凵凵:BAABLAAFFH8NAAIPAAYIEw2AJwAnAQAPAAYIEw2AJwAnAQAAAA==.',['出来']='出来就很高:BAABLAAECn8UAAIDAAcIvhR5TgByAQADAAcIvhR5TgByAQAAAA==.出来想带电:BAABLAAECn8XAAIPAAYIWRAhswAbAQAPAAYIWRAhswAbAQAAAA==.',['刘大']='刘大顺:BAAALAAFFAQIBAAAAA==.',['别打']='别打这个萨满:BAAALAAECgYIBwAAAA==.',['别样']='别样情怀:BAAALAADCgYIBgAAAA==.',['刹那']='刹那芳华:BAAALAAFFAIIAwAAAA==.',['加尔']='加尔鲁什:BAAALAAECgYIBgAAAA==.',['加红']='加红加大红:BAAALAADCggICAAAAA==.',['动圈']='动圈:BAACLAAFFH8QAAMUAAMIjyVbDAC2AAAUAAMIjyVbDAC2AAAVAAEIXw0fJQAAAAAsAAQKfy8AAhQACAiFJbcBAOoCABQACAiFJbcBAOoCAAAA.',['动物']='动物园管理者:BAAALAAECgYIBgAAAA==.',['动铁']='动铁:BAAALAAFFAIIBAABLAAFFAMIDQADAHQgAA==.',['勇哥']='勇哥哥:BAAALAAECggIDgAAAA==.',['化腾']='化腾给爹跪下:BAAALAAFFAQIBAAAAA==.',['医禽']='医禽治兽:BAAALAAECgcIDgAAAA==.',['半醉']='半醉游侠:BAAALAAECgYIBgAAAA==.',['卑鄙']='卑鄙的外乡人:BAABLAAFFH8cAAIDAAYI+xo5EQC9AQADAAYI+xo5EQC9AQAAAA==.',['卢云']='卢云:BAABLAAFFH8IAAQBAAIIWxe+VwCcAAABAAIIWxe+VwCcAAARAAIIPg2gGQA6AAACAAEIjwH5IAA4AAABLAAFFAcIKwAWAGwcAA==.',['卩丶']='卩丶紫:BAAALAAECgYIBgAAAA==.',['变身']='变身贴脸:BAAALAAECgEIAQAAAA==.',['只儿']='只儿豁阿歹:BAAALAAECgYIEAAAAA==.',['只玩']='只玩一两天:BAAALAAECgIIBAAAAA==.',['叮先']='叮先生:BAACLAAFFH83AAMBAAYIIiU2DgAfAgABAAYIIiU2DgAfAgACAAIInCGBCwC5AAAsAAQKf0EAAwEABwjUJWIhAOoCAAEABwiuJWIhAOoCAAIABwigI+cJALUCAAAA.',['右手']='右手丶会炎爆:BAABLAAFFH8LAAIMAAYIcBqcIwCHAQAMAAYIcBqcIwCHAQAAAA==.',['叶子']='叶子大姨妈:BAAALAADCgIIAgAAAA==.',['叶苓']='叶苓云思:BAAALAAFFAIIBAAAAA==.',['叽里']='叽里叽里:BAAALAAECgMIAwAAAA==.叽里叽里啦:BAACLAAFFH8FAAILAAMIQg4ADgB7AAALAAMIQg4ADgB7AAAsAAQKfxoAAwwABgiZFO06ACIBAAwABgg6EO06ACIBAAsABAi2FWVbAAgBAAAA.叽里咕噜啪:BAABLAAFFH8HAAMXAAMIjRTQCACWAAAXAAMIjRTQCACWAAANAAIIzQ4iQgCVAAAAAA==.',['吓猴']='吓猴蹲:BAAALAAECgYIBgAAAA==.',['吗喽']='吗喽丶:BAABLAAFFH8MAAIPAAMI9A67RwB1AAAPAAMI9A67RwB1AAAAAA==.',['听风']='听风者:BAAALAAECgcIBwAAAA==.',['吳彥']='吳彥祖:BAABLAAFFH8FAAIBAAIIzBqrVwCcAAABAAIIzBqrVwCcAAAAAA==.',['吴大']='吴大哥:BAAALAAFFAIIAgAAAA==.',['吻中']='吻中求进:BAAALAAECgEIAQAAAA==.',['吾仍']='吾仍热血:BAAALAADCggICAAAAA==.',['吾輩']='吾輩何以为战:BAABLAAFFH8IAAIFAAIIfQUTuAAxAAAFAAIIfQUTuAAxAAAAAA==.',['吾辈']='吾辈何以為战:BAABLAAFFH8KAAIEAAIIeQI2IQBQAAAEAAIIeQI2IQBQAAAAAA==.',['周周']='周周大魔王:BAAALAAFFAMIAwAAAA==.',['周老']='周老三:BAABLAAFFH8VAAIHAAYITA7TJQBgAQAHAAYITA7TJQBgAQABLAAFFAYIKwAFAHYYAA==.',['和中']='和中:BAACLAAFFH8NAAMDAAMIdCDCOAC7AAADAAMIdCDCOAC7AAAEAAIIuws3GwBvAAAsAAQKfxwAAgMACAgOJfcOAEADAAMACAgOJfcOAEADAAAA.',['咏夜']='咏夜:BAAALAAECgEIAQAAAA==.',['咕嘟']='咕嘟:BAABLAAFFH8QAAIMAAYI7gtIMABFAQAMAAYI7gtIMABFAQAAAA==.咕嘟嘟:BAABLAAFFH8IAAIFAAYIfgg6UQAKAQAFAAYIfgg6UQAKAQAAAA==.',['咣噹']='咣噹:BAAALAAECgIIAgAAAA==.',['哄嚨']='哄嚨:BAAALAAFFAIIAgAAAA==.',['哇灬']='哇灬嘎:BAAALAAECgYIEQAAAA==.',['哭泣']='哭泣的恶魔:BAABLAAFFH8LAAIDAAQIZQXTOgCsAAADAAQIZQXTOgCsAAAAAA==.',['啊阿']='啊阿奇:BAAALAAECgYIDAAAAA==.',['啸月']='啸月孤狼:BAABLAAFFH8iAAIYAAYIwxMXAwBBAQAYAAYIwxMXAwBBAQAAAA==.',['嘣嘚']='嘣嘚那个蹦嘚:BAAALAAECgIIBAAAAA==.',['嘻哈']='嘻哈丶战:BAAALAAECgYIDQAAAA==.',['国丶']='国丶家电网:BAAALAAECgMIAwAAAA==.',['图腾']='图腾嘟嘟鬼:BAAALAAECgUICgAAAA==.图腾大祭司:BAABLAAECn8YAAIPAAYIzRbcggB6AQAPAAYIzRbcggB6AQAAAA==.',['圆头']='圆头耄耋:BAAALAADCgUIBQAAAA==.',['圣光']='圣光小豆丁:BAAALAADCgYIBgAAAA==.圣光萌小拉:BAABLAAFFH8MAAIDAAYINyGoEADAAQADAAYINyGoEADAAQAAAA==.',['坠月']='坠月琉冰:BAAALAAFFAIIAwAAAA==.',['基尓']='基尓加丹:BAAALAAECgEIAQAAAA==.',['堕落']='堕落的月鬼:BAAALAAECgYIBgAAAA==.堕落领袖:BAABLAAFFH8GAAINAAIITg0fRQCRAAANAAIITg0fRQCRAAAAAA==.堕落黑暗:BAAALAAECggIDwAAAA==.',['塔兰']='塔兰吉王子:BAABLAAFFH8HAAIKAAMI+wRAPABWAAAKAAMI+wRAPABWAAAAAA==.',['士骑']='士骑亡死:BAAALAAECgMIAgAAAA==.',['壹碗']='壹碗嘎巴菜:BAAALAAECgEIAQAAAA==.',['处森']='处森:BAAALAAECgMIAwAAAA==.',['多宝']='多宝:BAAALAAECgEIAQAAAA==.',['多谢']='多谢帝骑哥:BAAALAAECggICgAAAA==.',['夜幕']='夜幕涎鬼:BAAALAAFFAIIBAAAAA==.',['夜琉']='夜琉璃:BAABLAAFFH8GAAIRAAYIiARpEADtAAARAAYIiARpEADtAAAAAA==.',['大地']='大地之涌:BAABLAAFFH8GAAIPAAIIqRpsNQCWAAAPAAIIqRpsNQCWAAAAAA==.',['大漂']='大漂亮:BAAALAAECggICAAAAA==.',['大灰']='大灰牛:BAAALAAECgUIBgAAAA==.',['大红']='大红手:BAABLAAFFH8FAAIBAAUIhg/fQwArAQABAAUIhg/fQwArAQAAAA==.',['天天']='天天好心情:BAACLAAFFH86AAINAAYIKhuLHgCjAQANAAYIKhuLHgCjAQAsAAQKf0IAAg0ACAi1HlAoAKMCAA0ACAi1HlAoAKMCAAAA.天天死骑:BAAALAAFFAIIBAAAAA==.',['天津']='天津爷们拽:BAAALAAECgMIBAAAAA==.',['天空']='天空飞鸟:BAAALAAECgYICgAAAA==.',['天谴']='天谴:BAAALAAECgEIBAAAAA==.',['天越']='天越高心越小:BAAALAAECggICAAAAA==.',['奇怪']='奇怪的射击猎:BAAALAADCgEIAQAAAA==.',['奈何']='奈何桥孟婆:BAAALAAFFAIIBAAAAA==.',['奔放']='奔放的小男朲:BAAALAAECggIDwAAAA==.',['奥绝']='奥绝之飝:BAABLAAFFH8IAAIZAAIIMBSsFQCnAAAZAAIIMBSsFQCnAAAAAA==.',['奧黛']='奧黛丽赫本:BAAALAAECgMIAwAAAA==.',['奶德']='奶德新之助:BAAALAAFFAIIAgAAAA==.',['妈妈']='妈妈:BAABLAAFFH8bAAMJAAgIpBNJCQA1AgAJAAgIpBNJCQA1AgAIAAEIQAbLKwA/AAAAAA==.',['妖媚']='妖媚丶:BAAALAAECgYIDAAAAA==.',['妮莎']='妮莎:BAAALAADCgEIAQAAAA==.',['娜小']='娜小宝:BAAALAAECgYIBgAAAA==.',['娜美']='娜美:BAAALAAFFAIIAgAAAA==.',['嫑啦']='嫑啦:BAAALAADCgEIAQAAAA==.嫑啦嫑啦:BAAALAADCgIIAgAAAA==.嫑啦嫑辣:BAAALAADCgQIBAAAAA==.',['孟婆']='孟婆的优乐美:BAAALAADCggICAAAAA==.',['孤心']='孤心赏月:BAAALAAECggICAAAAA==.',['安安']='安安咔:BAABLAAFFH8GAAIHAAIIhRALRACWAAAHAAIIhRALRACWAAAAAA==.',['安東']='安東:BAABLAAFFH8JAAIaAAgI1RDPBwANAgAaAAgI1RDPBwANAgAAAA==.',['宋慧']='宋慧乔:BAAALAAECgYIBgAAAA==.',['宫羽']='宫羽:BAABLAAFFH8IAAIMAAIIAyG2TQBTAAAMAAIIAyG2TQBTAAAAAA==.',['寒冬']='寒冬将至:BAAALAAECgYIDAAAAA==.',['将相']='将相本无种:BAAALAAECgIIAgAAAA==.',['小乖']='小乖牛:BAAALAAECggICAAAAA==.',['小伙']='小伙贼壮:BAAALAAFFAIIBAAAAA==.小伙贼粗:BAAALAAECgYIDAAAAA==.',['小凶']='小凶许:BAAALAADCgcIBwAAAA==.',['小小']='小小瑶:BAAALAAECgYIBgAAAA==.',['小强']='小强:BAAALAADCggICAAAAA==.',['小德']='小德玛利亚丶:BAABLAAECn8YAAQWAAYIyB90LwAjAgAWAAYIyB90LwAjAgAQAAUIJAtleQDgAAAYAAEIZgLZLQARAAAAAA==.',['小毛']='小毛驴儿:BAABLAAFFH8IAAIVAAYIpgH+FgC5AAAVAAYIpgH+FgC5AAAAAA==.',['小波']='小波:BAAALAAECgYIBgAAAA==.',['小破']='小破術士丶:BAAALAAECgcIDQAAAA==.',['小郡']='小郡主:BAABLAAFFH8KAAMNAAMIihh6SwCMAAANAAIIMxV6SwCMAAAXAAEINh8tKABQAAAAAA==.',['小龙']='小龙霞:BAABLAAFFH8IAAIbAAIIEQmZFQB2AAAbAAIIEQmZFQB2AAAAAA==.',['尐妖']='尐妖妖丷:BAAALAAECgYIAwAAAA==.',['就不']='就不加你:BAAALAAECgMIAwAAAA==.',['就叫']='就叫德丶:BAABLAAFFH8WAAMWAAUIBRNxHgAxAQAWAAUIBRNxHgAxAQAQAAIIrQprPQAsAAAAAA==.',['尹艾']='尹艾茜:BAAALAAECgYIDQAAAA==.',['尼古']='尼古拉斯赵四:BAAALAAFFAIIAgAAAA==.',['尼德']='尼德霍格:BAAALAAECgIIAgAAAA==.',['山有']='山有扶蘇:BAACLAAFFH8rAAQWAAcIbBxcBwCnAQAWAAcIbBxcBwCnAQAQAAUIARFHEQDlAAAYAAEIvwtdDAA3AAAsAAQKfzIABBYACAhcIpkNAO4CABYACAhcIpkNAO4CABgACAjgFPAWAHgBABAAAwgBBxSVAHMAAAAA.',['巧克']='巧克力糖:BAAALAAECgYIDQAAAA==.',['巨馍']='巨馍蘸酱:BAAALAADCggIDAAAAA==.',['巳升']='巳升升:BAACLAAFFH8KAAISAAIIAxOuJAB+AAASAAIIAxOuJAB+AAAsAAQKfxgAAgUABggsHmFMAK0BAAUABggsHmFMAK0BAAAA.',['帅的']='帅的莫名其妙:BAAALAAFFAIIBAAAAA==.',['帕杰']='帕杰罗:BAAALAADCgYICAAAAA==.',['帮桑']='帮桑迪:BAAALAAFFAIIAgAAAA==.',['年华']='年华易逝:BAABLAAFFH8QAAIJAAIIlxuVJQCiAAAJAAIIlxuVJQCiAAABLAAFFAIIEQAPAGkkAA==.年华易逝丶:BAABLAAFFH8PAAIWAAIILhTMKwB/AAAWAAIILhTMKwB/AAABLAAFFAIIEQAPAGkkAA==.',['幽兰']='幽兰芳蔼:BAABLAAFFH8MAAIPAAIIzxAIQwB8AAAPAAIIzxAIQwB8AAAAAA==.',['幽暗']='幽暗毁灭者:BAACLAAFFH8QAAMNAAIIygb8VgBnAAANAAIIygb8VgBnAAAXAAEIhQFPMgAqAAAsAAQKf0UABA0ACAgVFWspALABAA0ACAimFGspALABABcABggTDJIhAMYAAA4AAQhoAWtHACAAAAAA.',['广寒']='广寒宫:BAAALAAECgYIBgAAAA==.',['弹你']='弹你脑瓜崩儿:BAABLAAFFH8QAAQIAAYICgQjGwDIAAAIAAYICgQjGwDIAAAcAAII1AW9BABsAAAJAAIIDwgRRABjAAAAAA==.',['彩云']='彩云牛牛:BAACLAAFFH8KAAIPAAIIcxn/SwCEAAAPAAIIcxn/SwCEAAAsAAQKfxYAAg8ABwj+GPlQAO8BAA8ABwj+GPlQAO8BAAAA.',['影丨']='影丨翳:BAACLAAFFH81AAMCAAYI1RYKAwChAQACAAYI1RYKAwChAQABAAEITAPyogAyAAAsAAQKfzYAAgIACAijFKcTACwCAAIACAijFKcTACwCAAAA.',['彼岸']='彼岸的守护:BAAALAAECgIIAgAAAA==.',['御水']='御水者:BAACLAAFFH8GAAIJAAIIKwjJOgB/AAAJAAIIKwjJOgB/AAAsAAQKfygAAgkACAg4E1k9AOMBAAkACAg4E1k9AOMBAAAA.',['心中']='心中的火焰:BAACLAAFFH8KAAIDAAIIiRYJPwCfAAADAAIIiRYJPwCfAAAsAAQKfx0AAgMABggWIfEzAMQBAAMABggWIfEzAMQBAAAA.',['心若']='心若芷兰:BAAALAAECgMIBgAAAA==.',['快乐']='快乐天使:BAAALAADCgEIAQAAAA==.',['思思']='思思:BAABLAAFFH8GAAIMAAYIqhLkJgB5AQAMAAYIqhLkJgB5AQAAAA==.',['恋時']='恋時雨:BAAALAAECgYIBgAAAA==.',['恬之']='恬之騎士:BAABLAAECn8XAAIDAAYIoxSkugCPAQADAAYIoxSkugCPAQAAAA==.',['恶天']='恶天使:BAAALAAFFAIIAwAAAA==.',['恶意']='恶意涛涛:BAAALAAECgYIBgAAAA==.',['恶魔']='恶魔孢子:BAAALAADCgIIAgAAAA==.恶魔小巫师:BAABLAAECn8eAAMXAAYI2SQeGwAhAgAXAAYI2SQeGwAhAgANAAYIdRsnYgDLAQAAAA==.',['悠闲']='悠闲自得:BAAALAAECgYIBgAAAA==.',['惩戒']='惩戒骑士:BAAALAADCggICAAAAA==.',['愚蠢']='愚蠢的地球人:BAAALAAFFAIIBAAAAA==.',['愿逐']='愿逐月华:BAAALAAECgYIBgAAAA==.',['憨憨']='憨憨牛:BAABLAAFFH8GAAIWAAMIlQslNgCRAAAWAAMIlQslNgCRAAAAAA==.',['戈德']='戈德林:BAAALAADCgYIBgAAAA==.',['我一']='我一个炎爆:BAAALAAECgYIBgAAAA==.',['我丨']='我丨回来了:BAAALAAFFAIIAgAAAA==.',['我射']='我射偏了:BAABLAAFFH8eAAIFAAUI4xnQJQDlAAAFAAUI4xnQJQDlAAAAAA==.',['我是']='我是奶骑:BAABLAAECn8aAAIDAAgIGxRbpQCuAQADAAgIGxRbpQCuAQAAAA==.我是萨导:BAABLAAFFH8GAAIQAAYIJwMkIQCwAAAQAAYIJwMkIQCwAAAAAA==.',['我的']='我的一点看法:BAAALAAECgYICwAAAA==.',['战少']='战少:BAABLAAFFH8GAAIaAAYIpxgqDADCAQAaAAYIpxgqDADCAQAAAA==.',['打窝']='打窝:BAAALAAECgQIBAAAAA==.',['托尼']='托尼托尼乔芭:BAABLAAFFH8GAAIWAAII8xdNNwCNAAAWAAII8xdNNwCNAAABLAAFFAgIDAAWAN8ZAA==.',['执念']='执念女子:BAAALAAFFAIIAgAAAA==.',['承影']='承影:BAAALAAFFAIIAgAAAA==.',['抹茶']='抹茶麻糬:BAACLAAFFH85AAIPAAcIzhsxCAC8AQAPAAcIzhsxCAC8AQAsAAQKfxYAAg8ACAihHR8qAGkCAA8ACAihHR8qAGkCAAAA.',['挚爱']='挚爱娜娜子:BAAALAAECgMIAwAAAA==.',['摇滚']='摇滚雪姨:BAABLAAFFH8PAAIWAAIIfh9EHACxAAAWAAIIfh9EHACxAAAAAA==.',['擎月']='擎月:BAAALAAECgYIBgAAAA==.',['放弃']='放弃回忆:BAAALAAECgQIBAAAAA==.',['放肆']='放肆的温柔:BAABLAAFFH8FAAIRAAIIVAnSHQAqAAARAAIIVAnSHQAqAAAAAA==.',['斋藤']='斋藤飞袅:BAABLAAFFH8GAAIJAAII0QmZQQBnAAAJAAII0QmZQQBnAAAAAA==.',['断弦']='断弦小白:BAAALAAFFAIIBAAAAA==.',['断线']='断线的风筝:BAAALAAECgMIAwAAAA==.',['新东']='新东方厨神:BAABLAAECn8lAAMcAAgIQhO5DADgAQAcAAgIQhO5DADgAQAJAAQI2ATKpQCHAAAAAA==.',['旁观']='旁观者:BAACLAAFFH8KAAIPAAIImSAVJwC3AAAPAAIImSAVJwC3AAAsAAQKfz4AAg8ACAh1JTwDAC0DAA8ACAh1JTwDAC0DAAAA.',['无为']='无为:BAAALAAECgIIBAAAAA==.',['无亟']='无亟之旅:BAABLAAFFH8pAAIdAAYIjA3nEwAiAQAdAAYIjA3nEwAiAQAAAA==.',['无忌']='无忌:BAAALAAECgYIEAAAAA==.',['无权']='无权:BAAALAAECgYIBgAAAA==.',['时代']='时代在召唤:BAABLAAECn8UAAIDAAgI/BaBWQA6AgADAAgI/BaBWQA6AgAAAA==.',['昔日']='昔日的贵族:BAACLAAFFH8gAAMXAAYIlwZGBwCyAAANAAYIlwauOQAkAQAXAAUI8gNGBwCyAAAsAAQKfyMAAxcABwhgD3NEAF0BAA0ABgj1EACMAGYBABcABwj6C3NEAF0BAAAA.',['星光']='星光一烈阳:BAAALAAECgYICQAAAA==.',['星辰']='星辰引渡:BAAALAADCgIIAgAAAA==.星辰蛮蛮:BAAALAAFFAUIAgAAAA==.',['普特']='普特雷斯:BAACLAAFFH8IAAMNAAIIdBB3QQCWAAANAAIIdBB3QQCWAAAXAAEITACgMgASAAAsAAQKfx0AAw0ABwhTHrUbAAQCAA0ABwj7HbUbAAQCABcAAwhpE8NpAM8AAAAA.',['景久']='景久:BAAALAAECgYIBgAAAA==.',['暖橙']='暖橙之血:BAABLAAFFH8FAAIJAAUIcwAxNACWAAAJAAUIcwAxNACWAAAAAA==.',['暗影']='暗影之逝:BAAALAADCgMIAwAAAA==.',['暗悔']='暗悔:BAACLAAFFH87AAMJAAYIfiDCCgAdAgAJAAYIfiDCCgAdAgAIAAUINhNYFAAwAQAsAAQKfzoAAwkABwiXISAQAFYCAAkABwiXISAQAFYCAAgABghgGQ8aAHkBAAAA.',['暗惊']='暗惊鱼:BAAALAADCgYICwAAAA==.',['曙光']='曙光一烈阳:BAAALAAECgUIBQAAAA==.',['曼妥']='曼妥思:BAAALAAECgIIAgAAAA==.',['曾经']='曾经的潇洒哥:BAAALAAECgcIEwAAAA==.',['月魇']='月魇:BAAALAAECgYICgAAAA==.',['有点']='有点小忐忑:BAABLAAFFH8GAAIFAAYIHh+XGwDFAQAFAAYIHh+XGwDFAQAAAA==.',['木槿']='木槿:BAAALAAFFAIIAgAAAA==.',['木羊']='木羊:BAAALAADCgMIAwAAAA==.',['杀戮']='杀戮影舞:BAAALAAECgYIDAAAAA==.杀戮暗夜:BAABLAAFFH8MAAIFAAYI6hPWOgBWAQAFAAYI6hPWOgBWAQABLAAFFAgIEgAFAM0MAA==.杀戮梦魇:BAAALAADCgIIAgAAAA==.杀戮邪神:BAAALAAECgEIAQAAAA==.杀戮随风:BAAALAAFFAQIAgAAAA==.杀戮雨曦:BAAALAAECgYIDAAAAA==.',['李帅']='李帅猪:BAAALAADCgcICwAAAA==.',['杰夫']='杰夫老祭司:BAABLAAECn8xAAIPAAYIURoILQCwAQAPAAYIURoILQCwAQAAAA==.',['東雪']='東雪莲:BAAALAAFFAMIBAAAAA==.',['林品']='林品如:BAAALAAECgQIBQAAAA==.',['枫晨']='枫晨守鹤:BAABLAAECn8kAAIJAAYIByMEEgBCAgAJAAYIByMEEgBCAgAAAA==.',['枫道']='枫道:BAABLAAFFH8HAAIMAAIIECMyMADMAAAMAAIIECMyMADMAAABLAAFFAgIGAAMAAomAA==.',['某德']='某德:BAAALAADCggIDAAAAA==.',['某魔']='某魔:BAAALAAECgUIBQAAAA==.',['树上']='树上骑个猴:BAAALAADCgQIBAAAAA==.',['格罗']='格罗玛什咆笑:BAAALAAECggICAAAAA==.',['桀骜']='桀骜之角:BAAALAAECgYIDAAAAA==.',['桃之']='桃之夭夭:BAABLAAECn8WAAMXAAcIJx2wKwDDAQANAAcImxaVVQDwAQAXAAUIQx2wKwDDAQAAAA==.',['梦的']='梦的磐涅:BAABLAAFFH8JAAIDAAQIgxRwJADCAAADAAQIgxRwJADCAAABLAAFFAgIOAATAHgjAA==.',['森野']='森野夜:BAAALAAFFAIIAgAAAA==.',['楚天']='楚天秋:BAAALAAECgYICQABLAAFFAgIDQAQAKoDAA==.',['欲望']='欲望之火:BAAALAAECggICAAAAA==.',['欺诈']='欺诈面具:BAABLAAFFH8GAAIPAAYIJhyyEQDWAQAPAAYIJhyyEQDWAQAAAA==.',['武僧']='武僧咕噜噜:BAAALAADCgYIBgAAAA==.',['死亡']='死亡序号:BAABLAAFFH8MAAIdAAYItgyoCABdAQAdAAYItgyoCABdAQAAAA==.',['残梦']='残梦惊云:BAAALAAECgMIAwAAAA==.',['毀天']='毀天滅帝:BAAALAAECgYIDAAAAA==.',['毛胖']='毛胖球:BAABLAAFFH8oAAMJAAgIWiBHAQAZAwAJAAgIWiBHAQAZAwAIAAUIhw01GQDqAAABLAAFFAgIpAAJAAUkAA==.',['气球']='气球的怨念:BAAALAAFFAYIBAAAAA==.',['水上']='水上悠:BAAALAAFFAIIBAAAAA==.',['水曜']='水曜曰的猫:BAACLAAFFH8NAAIMAAIIih6cNwCtAAAMAAIIih6cNwCtAAAsAAQKfxcAAgwABwgOIFM6AGECAAwABwgOIFM6AGECAAAA.',['水水']='水水渔渔:BAABLAAECn8UAAIHAAYIYRrMgQDCAQAHAAYIYRrMgQDCAQAAAA==.',['水流']='水流云散:BAAALAADCgIIAgAAAA==.',['汐唐']='汐唐杉禾:BAABLAAFFH8GAAMcAAIIiRHYBgBKAAAJAAIIiRGHOwBzAAAcAAIIeQXYBgBKAAAAAA==.',['汤米']='汤米谢尔比:BAAALAAFFAIIAgAAAA==.',['汪峰']='汪峰:BAACLAAFFH8qAAIHAAcIixDnEQCGAQAHAAcIixDnEQCGAQAsAAQKfzIAAgcACAgAHx4yAJMCAAcACAgAHx4yAJMCAAAA.',['沅芷']='沅芷澧兰:BAAALAAFFAIIBAAAAA==.',['沐雨']='沐雨橙風:BAAALAAECgYICQAAAA==.',['沙迦']='沙迦:BAAALAAECgYIBgAAAA==.',['沧溟']='沧溟之鹰:BAAALAAECgYICQAAAA==.',['法瑟']='法瑟布拉德:BAAALAAECgMIAwAAAA==.',['法里']='法里不容:BAABLAAFFH8NAAIMAAII8RGlXAA/AAAMAAII8RGlXAA/AAAAAA==.',['洛千']='洛千寻:BAAALAADCggIFQAAAA==.',['活着']='活着真累:BAAALAADCgQIBQAAAA==.',['深入']='深入荒野:BAAALAADCggIDgAAAA==.',['清江']='清江寒蕊:BAAALAADCgIIAgAAAA==.',['清霜']='清霜:BAAALAAFFAIIBAAAAA==.',['清风']='清风乄救赎:BAAALAAECgYIBgAAAA==.',['湮灭']='湮灭的魂:BAAALAAECgIIAgAAAA==.',['滑漂']='滑漂:BAAALAAECgMIAwAAAA==.',['激流']='激流充满奶味:BAAALAADCgYIBgAAAA==.',['火之']='火之欲望:BAAALAAECggICAAAAA==.',['火力']='火力城人王:BAAALAADCgcIBwAAAA==.',['灬奔']='灬奔雷剑灬:BAACLAAFFH8MAAIFAAYIJwz7TQAWAQAFAAYIJwz7TQAWAQAsAAQKfxYAAgUACAhBF4tmAA4CAAUACAhBF4tmAA4CAAAA.',['灬影']='灬影子灬:BAAALAAFFAIIAgAAAA==.',['灬脉']='灬脉动灬:BAAALAAECgYIBgAAAA==.',['灬风']='灬风暴之眼灬:BAAALAAECgUIBQAAAA==.',['灵感']='灵感老祭司:BAAALAAECgYIDQAAAA==.灵感萨嘟嘟:BAAALAAECgUICwAAAA==.',['烂木']='烂木头:BAAALAAFFAEIAQAAAA==.',['热心']='热心的群众:BAAALAAFFAMIAQAAAA==.',['焕雪']='焕雪:BAAALAADCgEIAQAAAA==.',['熊小']='熊小库丶:BAAALAAECgYICwAAAA==.熊小德丶:BAAALAAECgYIEAAAAA==.',['熊柒']='熊柒丶:BAABLAAECn8bAAIPAAYIAhb8QwBLAQAPAAYIAhb8QwBLAQAAAA==.',['燃成']='燃成烬的温柔:BAAALAADCggICAAAAA==.',['爱书']='爱书书:BAAALAAECgIIAwAAAA==.',['爱意']='爱意随钟起:BAABLAAFFH8KAAMQAAYIxxfHGAASAQAQAAUIdBfHGAASAQAWAAEI+giZWwA3AAAAAA==.',['牛气']='牛气十足:BAAALAAFFAIIAgAAAA==.',['牧一']='牧一易:BAAALAAFFAIIAgAAAA==.',['牧易']='牧易:BAAALAAFFAIIBAAAAA==.',['牧神']='牧神者:BAAALAAFFAIIAgAAAA==.',['牧雨']='牧雨乾坤:BAAALAAECgYIBgAAAA==.',['特兰']='特兰普打耳洞:BAAALAAECggICgAAAA==.',['狂傲']='狂傲魔影:BAAALAAECgYICgAAAA==.',['独孤']='独孤尚恋:BAACLAAFFH8LAAIeAAMI1w+uCAC0AAAeAAMI1w+uCAC0AAAsAAQKfxUAAx4ACAhtGF8UAC4CAB4ACAhtGF8UAC4CAAcAAQgcDt1ZATIAAAAA.',['独钓']='独钓寒江雪丶:BAAALAAECggICAAAAA==.',['猎魔']='猎魔狂小拉:BAABLAAFFH8SAAIFAAYI4BetLwB5AQAFAAYI4BetLwB5AQAAAA==.',['獨孤']='獨孤尙戀:BAABLAAFFH8IAAMLAAII+BvCEQCLAAALAAII+BvCEQCLAAAMAAIIDQ7eVwBDAAAAAA==.',['玉藻']='玉藻前:BAAALAAECgYIBgAAAA==.',['玛格']='玛格丽特:BAAALAAFFAIIAgAAAA==.',['珍妮']='珍妮玛丶黛靳:BAAALAAECgIIAgAAAA==.',['珍惜']='珍惜丶:BAAALAAECgUIBwAAAA==.',['瑾年']='瑾年丨随风:BAABLAAFFH8GAAIDAAYIAQRuSgBuAAADAAYIAQRuSgBuAAAAAA==.',['瓦利']='瓦利丨白龙皇:BAABLAAECn8YAAMbAAgIJAB6NQAHAAAbAAgIJAB6NQAHAAAVAAUIPwAXVAADAAAAAA==.',['生蚝']='生蚝:BAAALAAECgYICQAAAA==.',['用臀']='用臀恐惧你:BAAALAADCgUIBwAAAA==.',['甲鱼']='甲鱼桑丶:BAABLAAFFH8GAAIBAAYI9QPTTwDgAAABAAYI9QPTTwDgAAAAAA==.',['男兽']='男兽:BAAALAAECgYICAAAAA==.',['痛砼']='痛砼痛撒户辣:BAACLAAFFH8lAAMHAAYIcBkdFgC2AQAHAAYINRkdFgC2AQAeAAMImxFEDAB2AAAsAAQKfx4AAgcACAh0FidhAAcCAAcACAh0FidhAAcCAAAA.',['痛苦']='痛苦面具:BAABLAAFFH8GAAIZAAYI2RC+CgBjAQAZAAYI2RC+CgBjAQAAAA==.',['痞子']='痞子狼哥:BAABLAAFFH8ZAAIRAAYITwIJEgC8AAARAAYITwIJEgC8AAAAAA==.',['白将']='白将军:BAAALAAECgYIEgAAAA==.',['白白']='白白的黑:BAAALAADCgYIBgAAAA==.',['白羊']='白羊:BAABLAAFFH8JAAIKAAgIeQMkNgCEAAAKAAgIeQMkNgCEAAAAAA==.',['白虹']='白虹:BAABLAAFFH8IAAIeAAIIBxgWDQCLAAAeAAIIBxgWDQCLAAAAAA==.',['白龙']='白龙的千寻:BAAALAAECgUIBQAAAA==.',['看我']='看我眼神开怪:BAAALAAECgYIBgAAAA==.',['瞬间']='瞬间的刹那:BAABLAAFFH8GAAIWAAII5gitPwBgAAAWAAII5gitPwBgAAAAAA==.',['石头']='石头梦想圣:BAABLAAFFH8UAAIDAAYIBRA6JABPAQADAAYIBRA6JABPAQABLAAFFAYIKwAFAHYYAA==.石头梦想娃:BAACLAAFFH8rAAMFAAYIdhhSLgB9AQAFAAYIdhhSLgB9AQASAAIIoARhMgBQAAAsAAQKfx8AAwUACAhAG0BlABECAAUABwhrHEBlABECABIABgi7EqtaAE8BAAAA.石头梦想德:BAABLAAFFH8IAAIYAAIIuwXwEAAiAAAYAAIIuwXwEAAiAAAAAA==.石头梦想戦:BAABLAAFFH8KAAITAAQIUAy9MADDAAATAAQIUAy9MADDAAABLAAFFAYIKwAFAHYYAA==.石头梦想法:BAABLAAFFH8FAAILAAMIURC0DQCAAAALAAMIURC0DQCAAAABLAAFFAYIKwAFAHYYAA==.石头梦想萨:BAABLAAFFH8RAAIPAAQIuA3fPQCtAAAPAAQIuA3fPQCtAAABLAAFFAYIKwAFAHYYAA==.石头梦想谛:BAABLAAFFH8MAAIBAAYIugc7PgBCAQABAAYIugc7PgBCAQABLAAFFAYIKwAFAHYYAA==.',['社象']='社象基:BAAALAADCgYIBgAAAA==.',['神圣']='神圣裁决:BAAALAADCggICAAAAA==.',['神崎']='神崎雪奈:BAABLAAFFH8PAAMBAAMISCGsIAAfAQABAAMISCGsIAAfAQACAAIIphMmEgCRAAAAAA==.',['神的']='神的传说:BAAALAAFFAIIAgAAAA==.',['福克']='福克斯:BAAALAADCgcIBwAAAA==.',['禧玛']='禧玛诺:BAAALAAECgMIAwAAAA==.',['秤子']='秤子幻魔者:BAAALAAECgUIBQAAAA==.秤子逐风者:BAAALAAECgYIBwAAAA==.',['积木']='积木狂想季:BAAALAADCgcIBwAAAA==.',['移花']='移花接牧:BAAALAAFFAIIBAAAAA==.',['稗兰']='稗兰:BAACLAAFFH8SAAIJAAMImSYGDwBTAQAJAAMImSYGDwBTAQAsAAQKfzIAAgkACAh5Jj4BAHYDAAkACAh5Jj4BAHYDAAAA.',['章北']='章北海:BAABLAAFFH8GAAIYAAIIaxhKBwB6AAAYAAIIaxhKBwB6AAAAAA==.',['端木']='端木星灵:BAAALAAECgIIAgAAAA==.',['第三']='第三者:BAAALAAFFAIIAgAAAA==.',['粉红']='粉红毛兔兔:BAAALAADCgEIAQAAAA==.',['糖豆']='糖豆先生:BAABLAAFFH8KAAMNAAMICQ59TwB8AAANAAMICQ59TwB8AAAXAAEIQALxMAA+AAAAAA==.',['紧急']='紧急救援:BAAALAAFFAEIAQAAAA==.',['紧那']='紧那羅灬:BAABLAAFFH8QAAIbAAMIkBBTEAC1AAAbAAMIkBBTEAC1AAAAAA==.',['紫薯']='紫薯阿美莉卡:BAAALAAFFAIIAgAAAA==.',['纞戦']='纞戦之狼哥:BAABLAAFFH8UAAIEAAYIXBBZCAA4AQAEAAYIXBBZCAA4AQAAAA==.纞戦狼哥:BAABLAAFFH8jAAIVAAcImQsmDgBlAQAVAAcImQsmDgBlAQAAAA==.',['红鲸']='红鲸鱼:BAAALAAECgYIBwAAAA==.',['终是']='终是浮夸丶:BAAALAAECgEIAQAAAA==.',['绝地']='绝地挽歌:BAABLAAFFH8XAAMWAAYIEBRJFACXAQAWAAYIEBRJFACXAQAQAAMItgrRKABwAAAAAA==.绝地死战:BAABLAAFFH8vAAIdAAYImhWSDgBeAQAdAAYImhWSDgBeAQAAAA==.绝地狂猎:BAABLAAFFH8IAAIFAAUIWxf5RwArAQAFAAUIWxf5RwArAQAAAA==.',['缺德']='缺德吗:BAABLAAFFH8IAAIWAAIIjRxyOACJAAAWAAIIjRxyOACJAAAAAA==.',['羽林']='羽林一烈阳:BAAALAADCgQIBAAAAA==.',['翠玉']='翠玉之剑:BAAALAAECgEIAQAAAA==.翠玉纹章:BAAALAAECgYIBgAAAA==.',['老鲶']='老鲶鱼:BAAALAADCgIIAgAAAA==.',['聆雨']='聆雨观海:BAAALAAECgUIBQAAAA==.',['肉熊']='肉熊猫不好吃:BAABLAAFFH8GAAIJAAIIMwngQgBlAAAJAAIIMwngQgBlAAAAAA==.',['胖胖']='胖胖的老公:BAACLAAFFH86AAIMAAgICSWZAwBwAgAMAAgICSWZAwBwAgAsAAQKfykAAwwACAhaJj8EAGwDAAwACAhaJj8EAGwDAB8AAQjdEwAhAD0AAAAA.',['胸毛']='胸毛荡漾:BAABLAAFFH8GAAMIAAYILSDkDwBnAQAIAAUIbCHkDwBnAQAJAAEIuA4cTgBAAAAAAA==.',['脆皮']='脆皮小笼包:BAAALAAFFAIIBAAAAA==.',['舒克']='舒克:BAABLAAFFH8GAAITAAIInBf5SABKAAATAAIInBf5SABKAAAAAA==.',['花丫']='花丫头:BAABLAAECn8bAAIFAAcIyBZjjwDFAQAFAAcIyBZjjwDFAQAAAA==.',['花生']='花生了什么树:BAACLAAFFH8OAAIFAAMI9RBicgB8AAAFAAMI9RBicgB8AAAsAAQKf0AAAgUACAhaHrszAPABAAUACAhaHrszAPABAAAA.',['花脸']='花脸博迪:BAACLAAFFH8IAAIdAAIIRxZnKwA5AAAdAAIIRxZnKwA5AAAsAAQKfyQAAh0ABwhXFX80ALsBAB0ABwhXFX80ALsBAAAA.',['苒姝']='苒姝儿:BAAALAAECgMIAwAAAA==.',['若蒺']='若蒺若藜:BAACLAAFFH8rAAMFAAYI/RhHLQCBAQAFAAYI/RhHLQCBAQASAAIIGQ16KAB3AAAsAAQKfzwAAwUACAh7I5wSABcDAAUACAgYI5wSABcDABIACAj3GzAgAGUCAAAA.',['茯苓']='茯苓:BAAALAAECgYIBgAAAA==.',['莉塔']='莉塔利安:BAAALAAECgIIAgAAAA==.',['莎樂']='莎樂美:BAAALAAECggIEAAAAA==.',['菊丶']='菊丶希尔芬:BAACLAAFFH8KAAIaAAIIABbIHACQAAAaAAIIABbIHACQAAAsAAQKfxwAAhoABggiH5IhAAgCABoABggiH5IhAAgCAAAA.',['菲奥']='菲奥娜月影:BAAALAADCgQICAAAAA==.',['萌卷']='萌卷卷丶:BAABLAAFFH8IAAMJAAYIDgtLGwDYAAAJAAMI7w1LGwDYAAAIAAMIEQIwFgDIAAABLAAFFAgILAAJAAknAA==.',['萌宠']='萌宠小拉:BAABLAAFFH8SAAIBAAYIfhbBMAB4AQABAAYIfhbBMAB4AQABLAAFFAgIDAABANsdAA==.',['萝莉']='萝莉百合控:BAABLAAFFH8GAAIXAAYIbwCpGgAWAAAXAAYIbwCpGgAWAAAAAA==.',['萨满']='萨满之心:BAAALAAECgIIAgAAAA==.萨满的萨满:BAAALAAECgYICAAAAA==.',['萨萨']='萨萨里安:BAAALAADCgEIAQAAAA==.',['落寞']='落寞且行:BAABLAAFFH8GAAIFAAIIKSHYfgBZAAAFAAIIKSHYfgBZAAAAAA==.',['落花']='落花黯然:BAAALAAECggICgAAAA==.',['落落']='落落青沙:BAAALAAECgYIBgAAAA==.',['落霞']='落霞:BAAALAADCgEIAQAAAA==.',['蒙狼']='蒙狼哥:BAABLAAFFH8UAAIeAAYI1wdiCADdAAAeAAYI1wdiCADdAAAAAA==.',['蒹葭']='蒹葭落絮:BAAALAAECgIIAgAAAA==.',['蓝染']='蓝染惣右介丶:BAAALAAECgYIBgAAAA==.',['蓝鲸']='蓝鲸鱼丶:BAAALAAECgYICQAAAA==.',['蕃茄']='蕃茄红牛:BAABLAAFFH8GAAIPAAIIJCC3OgC4AAAPAAIIJCC3OgC4AAAAAA==.',['薩魯']='薩魯法爾:BAAALAAFFAIIBAABLAAFFAgICAAHABMWAA==.',['蛇王']='蛇王:BAAALAAFFAIIBAAAAA==.',['蛙小']='蛙小侠:BAAALAAECgQIBAAAAA==.',['血小']='血小溅:BAABLAAFFH8GAAIMAAYI4gCjRQCMAAAMAAYI4gCjRQCMAAAAAA==.',['行则']='行则将至:BAAALAAECgYIDgAAAA==.',['观星']='观星者:BAACLAAFFH8GAAIBAAIIoxGlbQCRAAABAAIIoxGlbQCRAAAsAAQKfygAAwEACAh+H1dAAIACAAEACAiSHVdAAIACAAIABwi7GyUZAPQBAAAA.',['触牧']='触牧经心:BAABLAAFFH8GAAIEAAYIKABjJQALAAAEAAYIKABjJQALAAAAAA==.',['试玩']='试玩一夏:BAAALAAECgEIAQAAAA==.',['语录']='语录:BAAALAAECgYICAAAAA==.',['语部']='语部丶索尼娅:BAAALAAFFAIIAgAAAA==.',['谨防']='谨防坏女人:BAABLAAFFH8SAAIBAAYIWBc6JgCcAQABAAYIWBc6JgCcAQAAAA==.',['豆包']='豆包兒:BAAALAADCgEIAQAAAA==.',['贪财']='贪财好色恶魔:BAAALAAECgMIAwAAAA==.',['贰队']='贰队奶德:BAAALAAECgYIDAAAAA==.',['赵灵']='赵灵儿:BAAALAAECgYIBgAAAA==.',['超凡']='超凡入圣:BAAALAAECgMIAwAAAA==.',['路漫']='路漫漫:BAAALAAECgcICgAAAA==.',['路西']='路西菲尔:BAAALAADCgUIBwAAAA==.',['踴鎶']='踴鎶:BAAALAADCgYIBgAAAA==.',['轩辕']='轩辕无双:BAACLAAFFH8NAAIDAAQINAwSOADAAAADAAQINAwSOADAAAAsAAQKfyUAAgMACAgfFP1oABgCAAMACAgfFP1oABgCAAAA.',['输入']='输入错误:BAABLAAECn8WAAIPAAcIXhlsUgDsAQAPAAcIXhlsUgDsAQAAAA==.',['达摩']='达摩院扫地僧:BAAALAADCgYIBgAAAA==.',['过期']='过期菠萝:BAAALAAFFAIIBAAAAA==.',['这样']='这样挺好的:BAAALAAECgUIBQAAAA==.',['迪昂']='迪昂德萨巴赫:BAABLAAFFH8OAAIKAAYIOgqCIAA9AQAKAAYIOgqCIAA9AQAAAA==.',['逆光']='逆光:BAAALAADCgUIBQAAAA==.',['逆风']='逆风的鱼:BAAALAAECgIIAgAAAA==.',['逐风']='逐风者:BAAALAAFFAIIBAAAAA==.',['逝去']='逝去的倾心:BAAALAAECggICAAAAA==.',['遗忘']='遗忘的圣光:BAAALAAECgUIBQAAAA==.遗忘的情义:BAAALAAFFAIIAgAAAA==.遗忘的红楼:BAAALAAFFAIIAgAAAA==.遗忘的魂:BAAALAAECgYICQAAAA==.',['部落']='部落一枝花:BAAALAAECgYIEQAAAA==.',['酋长']='酋长萨薾:BAAALAAFFAIIAgAAAA==.',['酒酒']='酒酒井:BAAALAAECgYIBgAAAA==.',['铁甲']='铁甲你懂的:BAACLAAFFH8iAAIdAAUI4QhzGgDAAAAdAAUI4QhzGgDAAAAsAAQKfywAAx0ACAhTGcYsAOQBAB0ACAh0FcYsAOQBABMACAjiFf+IAHQBAAAA.',['阿基']='阿基米德:BAABLAAFFH8ZAAMPAAYIVhpQHAB5AQAPAAUIVxhQHAB5AQAKAAEILwS4TAA5AAAAAA==.',['陆筱']='陆筱凤:BAACLAAFFH8WAAIDAAMI3CC9KAC4AAADAAMI3CC9KAC4AAAsAAQKf0AAAgMACAihIbYNAKICAAMACAihIbYNAKICAAAA.',['陆贰']='陆贰肆:BAAALAAFFAIIAgAAAA==.',['随风']='随风流水:BAAALAAECgYIDgAAAA==.',['雨和']='雨和雪:BAABLAAECn8WAAIKAAcImg44YgCRAQAKAAcImg44YgCRAQAAAA==.',['雨国']='雨国璇书:BAACLAAFFH8KAAIXAAII1w3MEQBJAAAXAAII1w3MEQBJAAAsAAQKfxYAAxcABghlEnwbAPkAABcABghlEnwbAPkAAA0AAwhzCcV9AIMAAAAA.',['雨怡']='雨怡书怡:BAACLAAFFH8OAAIYAAMI8hhpBwB7AAAYAAMI8hhpBwB7AAAsAAQKfyQAAxgABggrHmYKAJgBABgABggrHmYKAJgBABAABAiiAlacAF4AAAAA.',['雪之']='雪之落:BAAALAAECgIIAgAAAA==.',['雷托']='雷托:BAAALAAECgYIBgAAAA==.',['雷炙']='雷炙:BAAALAADCgYIBgAAAA==.',['雾夜']='雾夜:BAAALAAECgYIDgAAAA==.',['雾语']='雾语者:BAAALAAECgQIBAAAAA==.',['雾途']='雾途:BAAALAAECgMIAwAAAA==.',['霓裳']='霓裳灬魅影:BAABLAAFFH8IAAIDAAII7w1JZABEAAADAAII7w1JZABEAAAAAA==.霓裳雨衣舞:BAABLAAFFH8IAAITAAMIxQIqKwCkAAATAAMIxQIqKwCkAAAAAA==.',['霰雪']='霰雪凝香:BAABLAAFFH8GAAIWAAYIEQB8YwABAAAWAAYIEQB8YwABAAAAAA==.',['青人']='青人:BAAALAAECgYICgAAAA==.',['青山']='青山:BAAALAADCgIIAgAAAA==.',['青春']='青春的躁动:BAAALAAECgYIBgAAAA==.',['颓废']='颓废丨死骑:BAAALAADCggICAAAAA==.',['风中']='风中德:BAAALAADCgUIBQAAAA==.风中魅火:BAAALAAECgYIBgAAAA==.风中魒:BAAALAADCgQIBAAAAA==.',['风之']='风之季语:BAABLAAECn8XAAILAAcIvh21FgBmAgALAAcIvh21FgBmAgAAAA==.风之彼岸婲:BAAALAAECgYIBgAAAA==.',['风烟']='风烟作良辰:BAAALAAECgYIDAAAAA==.',['风行']='风行步:BAABLAAFFH8GAAIFAAMIagwscgB8AAAFAAMIagwscgB8AAAAAA==.',['风起']='风起:BAAALAADCgIIAgAAAA==.',['飘雪']='飘雪之哀殇:BAAALAAECggICQAAAA==.',['飘飘']='飘飘然啊:BAAALAAECgYIBgABLAAFFAgIAQAgAAAAAA==.',['飞月']='飞月:BAABLAAFFH8bAAIMAAcI+hU3FADZAQAMAAcI+hU3FADZAQAAAA==.',['驱魔']='驱魔人:BAAALAADCgMIAwAAAA==.',['骤夜']='骤夜:BAAALAADCgYIBgAAAA==.',['鲶鱼']='鲶鱼哥哥:BAAALAADCgQIBAAAAA==.',['黄小']='黄小萨:BAABLAAFFH8LAAMKAAYIEgGqOQBwAAAKAAYIEgGqOQBwAAAPAAIINQiVagBQAAAAAA==.',['黄桃']='黄桃罐头:BAAALAAFFAIIAgAAAA==.',['黑岩']='黑岩妞子:BAACLAAFFH8LAAMWAAIIbRjgJwCLAAAWAAIIbRjgJwCLAAAYAAIIKwqaDwAmAAAsAAQKfxoAAxYACAjUCvRvAEYBABYACAjUCvRvAEYBABgABgjnDfcXAMsAAAAA.',['黑熊']='黑熊:BAAALAAECgYIBgAAAA==.',['黑白']='黑白小布丁:BAAALAAFFAIIAgAAAA==.',['黑色']='黑色卷云:BAAALAAECgYIBQAAAA==.',['黑蓮']='黑蓮花:BAAALAAECgMIAwAAAA==.',['黑鎽']='黑鎽:BAACLAAFFH8IAAIBAAII0h9wcABSAAABAAII0h9wcABSAAAsAAQKfxQAAgEABgi4IZwpAM8BAAEABgi4IZwpAM8BAAAA.',['黑锋']='黑锋:BAABLAAECn8eAAITAAYI6R+CIgDeAQATAAYI6R+CIgDeAQAAAA==.',['黯夜']='黯夜使者:BAAALAAECggIEAAAAA==.',['黯月']='黯月小牛:BAAALAAECgYIBwAAAA==.',['鼠鼠']='鼠鼠三啊:BAAALAAECgYIBgAAAA==.',['龙凤']='龙凤呈祥:BAAALAAFFAIIAwAAAA==.',['龙太']='龙太木农色:BAAALAADCggICAAAAA==.',['龙渊']='龙渊:BAABLAAFFH8OAAIEAAYIfgqeDACxAAAEAAYIfgqeDACxAAABLAAFFAgIBgAdAJwbAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end