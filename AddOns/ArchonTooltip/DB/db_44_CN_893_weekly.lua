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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','Mage-Arcane','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Warrior-Fury','Priest-Holy','Druid-Balance','Druid-Restoration','Hunter-Survival','DemonHunter-Havoc','Druid-Guardian','Warrior-Protection','Unknown-Unknown','DeathKnight-Frost','Shaman-Restoration','Warlock-Demonology','Mage-Fire','Rogue-Assassination','Warlock-Destruction','Warlock-Affliction','Monk-Brewmaster','Shaman-Elemental','DemonHunter-Vengeance','Monk-Windwalker','Monk-Mistweaver','Druid-Feral','Priest-Discipline',}; local provider = {region='CN',realm='黄金之路',name='CN',type='weekly',zone=44,date='2025-12-10',data={Ai='Aina:BAAALAADCgYIBgAAAA==.',As='Ashfur:BAACLAAFFH8GAAMBAAIIIREcJAB/AAABAAIIIREcJAB/AAACAAEIBgWCjQA1AAAsAAQKfxUAAwIACAhgJHYOALACAAIACAhgJHYOALACAAEABQjBE+poACIBAAAA.',Be='Bedivere:BAABLAAFFH8QAAMDAAUIFBxFDACbAAAEAAUISBeFMgA6AQADAAII/xhFDACbAAAAAA==.',Bt='Btwang:BAACLAAFFH8QAAIFAAIIlSAtJADCAAAFAAIIlSAtJADCAAAsAAQKfxsABAUABwh+IBR7APQBAAUABwh+IBR7APQBAAYABgjSHAcpANgBAAcAAQjgEFd/AB4AAAAA.',Bu='Buddylove:BAAALAAFFAIIAgAAAA==.Buddylovei:BAAALAAFFAIIAgAAAA==.Buddylovevi:BAAALAAECgYIBwAAAA==.Buddylovevii:BAAALAAFFAIIAgAAAA==.',Ca='Casilla:BAAALAAECgIIAgAAAA==.',Cl='Closer:BAAALAAECgMIAwAAAA==.',Co='Coconice:BAABLAAFFH8IAAMGAAYIQRwQCwDaAQAGAAYIQRwQCwDaAQAFAAIIrwsocQA+AAAAAA==.',Dr='Dragonsky:BAACLAAFFH8HAAIFAAQInAIVOACkAAAFAAQInAIVOACkAAAsAAQKfxcAAgUACAieChH5ADUBAAUACAieChH5ADUBAAEsAAUUCAgMAAgAoQMA.',Dy='Dylanhunter:BAABLAAFFH8GAAICAAYIoAV8UgANAQACAAYIoAV8UgANAQAAAA==.',Ec='Eclecticism:BAAALAAECgYIBgAAAA==.',El='Elysium:BAABLAAFFH8KAAIJAAIIqhyOJQCiAAAJAAIIqhyOJQCiAAAAAA==.',Ev='Evo:BAAALAAECgUIBQAAAA==.',Fo='For:BAAALAAECgMIAwAAAA==.',Gu='Guuguda:BAAALAAFFAIIBAAAAA==.',Ha='Haar:BAAALAAFFAQIBAAAAA==.',Hi='Hillside:BAAALAADCgEIAQAAAA==.',Hy='Hygwendy:BAAALAADCgUIBQAAAA==.',Le='Leahdizon:BAABLAAFFH8FAAIEAAUIuwa4PADkAAAEAAUIuwa4PADkAAAAAA==.Leahdizoni:BAAALAAECgUICQAAAA==.Leahdizonii:BAAALAAFFAIIBAAAAA==.Leahdizoniv:BAAALAAFFAIIAgAAAA==.Leahdizony:BAAALAAECgYICgAAAA==.',Li='Lim:BAAALAAFFAIIAgAAAA==.',Lo='Lovelulu:BAAALAAECgQIBAAAAA==.',Mi='Mininice:BAAALAAFFAgIAgAAAA==.Missan:BAAALAAECgYIBgAAAA==.',Mm='Mmtlr:BAAALAADCgMIAwAAAA==.',Na='Najasna:BAAALAAFFAIIAgAAAA==.',Ni='Nicenice:BAABLAAFFH8JAAIGAAgI5hO3BQBFAgAGAAgI5hO3BQBFAgAAAA==.',Or='Orangeduck:BAAALAAECgQIBAAAAA==.',Pl='Playerimflew:BAABLAAFFH8GAAMKAAYIPBK8CgB2AQAKAAUIpxO8CgB2AQALAAEIfAo5TQBDAAAAAA==.Playervwnbsu:BAAALAAECgYIDQAAAA==.Playerxzetls:BAAALAADCgcIBwAAAA==.',Po='Polee:BAABLAAFFH8oAAIIAAYIJCEDDgDuAQAIAAYIJCEDDgDuAQAAAA==.',Qh='Qhm:BAAALAAFFAMIAwAAAA==.',Ql='Qlr:BAABLAAFFH8KAAMMAAMI8hK2AQDsAAAMAAMI0RG2AQDsAAACAAMIfguVLwDHAAAAAA==.',Qq='Qqy:BAABLAAFFH8GAAINAAMI7Q0uIQDjAAANAAMI7Q0uIQDjAAAAAA==.',Qs='Qsy:BAAALAAFFAIIBAAAAA==.',Qu='Quirinus:BAAALAADCgEIAQAAAA==.',Qw='Qws:BAAALAAFFAIIAgAAAA==.',Ro='Rossoneri:BAABLAAFFH8GAAILAAIIJQZ1UgBSAAALAAIIJQZ1UgBSAAAAAA==.',Sa='Sasayaki:BAAALAAFFAIIAgAAAA==.',Sm='Smin:BAAALAADCgMIAwAAAA==.',Su='Sunboy:BAAALAAECgIIAwAAAA==.',Tb='Tb:BAABLAAFFH8UAAIEAAgIMBzOCwAwAgAEAAgIMBzOCwAwAgAAAA==.',Th='Thyfate:BAAALAAECggICAAAAA==.',Ty='Tyrandex:BAAALAAECgYIDAAAAA==.',Wa='Walkingdead:BAABLAAFFH8GAAIIAAIIlw0RQgCKAAAIAAIIlw0RQgCKAAAAAA==.',Wh='Whispering:BAABLAAFFH8GAAIDAAIIcxA4FwBCAAADAAIIcxA4FwBCAAAAAA==.',Xh='Xhop:BAAALAAECgYIDQAAAA==.',Xi='Xiaoluob:BAABLAAFFH8LAAIOAAMINxgRAgACAQAOAAMINxgRAgACAQAAAA==.',Xx='Xxsdrf:BAAALAAFFAIIAgAAAA==.',Zh='Zhengyu:BAAALAAECgYIBQAAAA==.',['一个']='一个人物:BAAALAAECgYIEgAAAA==.',['一人']='一人:BAAALAAFFAIIBAAAAA==.',['一天']='一天吃三顿土:BAACLAAFFH8GAAIFAAIITxdwYQBGAAAFAAIITxdwYQBGAAAsAAQKfxsAAgUACAgJIaIRAIMCAAUACAgJIaIRAIMCAAAA.',['一粒']='一粒丹:BAABLAAFFH8KAAINAAUIwA0aMgANAQANAAUIwA0aMgANAQAAAA==.',['下辈']='下辈子我请:BAAALAADCgYIBgAAAA==.',['不知']='不知火乀:BAABLAAFFH8JAAICAAgI7BJ3FgDoAQACAAgI7BJ3FgDoAQAAAA==.',['不见']='不见岳丷:BAABLAAFFH8SAAICAAYIDCCeFwDhAQACAAYIDCCeFwDhAQAAAA==.',['丶阿']='丶阿库娅:BAAALAAECggICAAAAA==.',['九萌']='九萌妹:BAABLAAFFH8GAAIIAAYIjRVPBwAfAgAIAAYIjRVPBwAfAgAAAA==.',['九龙']='九龙刀霸王:BAAALAAECgYICgAAAA==.',['亮闪']='亮闪闪神棍:BAAALAAECggICAAAAA==.',['人生']='人生若枫:BAAALAAECgYIBgAAAA==.',['人间']='人间词:BAABLAAFFH8GAAMIAAYIHQTsOwCIAAAIAAUIPAPsOwCIAAAPAAEIgwgMLAA6AAAAAA==.',['仇白']='仇白:BAABLAAFFH8GAAICAAYI6A0JRQA9AQACAAYI6A0JRQA9AQAAAA==.',['仓白']='仓白之神:BAABLAAFFH8MAAICAAUIPQ1NVAAHAQACAAUIPQ1NVAAHAQAAAA==.',['伊人']='伊人如月:BAAALAAECgYIBgAAAA==.',['伯起']='伯起:BAAALAAECgYICQAAAA==.',['佈吉']='佈吉叨:BAAALAAECgIIAgAAAA==.',['你在']='你在掩饰神马:BAAALAADCgIIAgAAAA==.',['你好']='你好呀丶起灵:BAABLAAFFH8IAAMCAAUIfhPpTwAWAQACAAUIfhPpTwAWAQABAAEIHwXTOAA0AAAAAA==.',['你的']='你的大屁屁:BAAALAADCgMIAwAAAA==.你的小洣洣:BAAALAAECgMIAwAAAA==.你的小苐苐:BAAALAAECgYIBgAAAA==.',['佩图']='佩图拉博:BAAALAAFFAIIAwAAAA==.',['依然']='依然如风:BAAALAAECgYIBgAAAA==.',['信仰']='信仰之殇:BAABLAAECn8UAAMHAAgIjSNDCQDmAgAHAAgIjSNDCQDmAgAFAAYIgxTUugCPAQABLAAFFAgIAgAQAAAAAA==.',['傲天']='傲天战:BAAALAAFFAIIBAAAAA==.',['傲笑']='傲笑红尘:BAAALAAECgYIEAAAAA==.',['光之']='光之子:BAABLAAFFH8MAAIFAAUIbx1eIQBnAQAFAAUIbx1eIQBnAQAAAA==.',['光铸']='光铸死骑:BAACLAAFFH8FAAIRAAMILglQOQC/AAARAAMILglQOQC/AAAsAAQKfxQAAhEABwj3Gfx4AAYCABEABwj3Gfx4AAYCAAAA.',['克丽']='克丽丝娜光翼:BAABLAAFFH8XAAIGAAUI2xllEACJAQAGAAUI2xllEACJAQAAAA==.',['八级']='八级大狂蜂:BAABLAAFFH8gAAMKAAcIzhpqCgDAAQAKAAYI0R1qCgDAAQALAAYI1wltIAAiAQAAAA==.',['兰州']='兰州拉面:BAAALAAECgUIBgAAAA==.',['关云']='关云短:BAAALAAECgYIBgAAAA==.',['兽性']='兽性大发:BAAALAADCggICAAAAA==.',['凉森']='凉森玲梦:BAABLAAFFH8IAAIFAAgITAGPhQAhAAAFAAgITAGPhQAhAAAAAA==.',['凤凰']='凤凰小兔:BAAALAADCgYIBgAAAA==.',['刹那']='刹那芳华灬:BAAALAAECgEIAQAAAA==.',['劣人']='劣人:BAAALAAECgYIBwAAAA==.',['半寒']='半寒微风凉:BAAALAAECgcIEgAAAA==.',['单边']='单边指环:BAAALAAECgIIAgAAAA==.',['卖艺']='卖艺不卖身:BAAALAADCgcIBwAAAA==.',['南屿']='南屿清辞:BAACLAAFFH8QAAIFAAYIBxBdEwAeAQAFAAYIBxBdEwAeAQAsAAQKfxsAAgUACAjZHUZGAGkCAAUACAjZHUZGAGkCAAEsAAUUCAgIAAUAVBMA.',['卡卡']='卡卡骑士再临:BAAALAADCgIIAgAAAA==.',['卧龙']='卧龙大花熊:BAAALAAECgUIBgAAAA==.',['危机']='危机之年:BAAALAADCgIIAgAAAA==.',['危险']='危险小小:BAAALAADCggICAAAAA==.',['厉害']='厉害的奶:BAACLAAFFH8VAAISAAMIpA7ESgCKAAASAAMIpA7ESgCKAAAsAAQKfxUAAhIABwjdF2hfAMoBABIABwjdF2hfAMoBAAAA.',['又是']='又是小湖人:BAAALAAECgcIBwAAAA==.',['双叶']='双叶萤:BAAALAAECgEIAQAAAA==.',['叶凡']='叶凡:BAABLAAECn8XAAITAAYIvCAkCQDbAQATAAYIvCAkCQDbAQAAAA==.',['吃到']='吃到破产:BAAALAAECgMIAwAAAA==.',['吃饱']='吃饱饭:BAAALAAECgYIBgAAAA==.',['后羿']='后羿射月:BAABLAAFFH8aAAICAAUIAxjaTAAhAQACAAUIAxjaTAAhAQAAAA==.',['呜拉']='呜拉:BAAALAAECgMICQAAAA==.',['咚咚']='咚咚锵咚锵:BAAALAAECgYIBgAAAA==.',['咸蛋']='咸蛋小草人:BAACLAAFFH8PAAIRAAQI6xZfUQDiAAARAAQI6xZfUQDiAAAsAAQKfxwAAhEACAjfGGkcABECABEACAjfGGkcABECAAAA.',['哈基']='哈基猎:BAAALAAFFAIIAgAAAA==.',['哎呦']='哎呦喂:BAAALAADCgMIAwAAAA==.',['哥布']='哥布林杀手:BAAALAADCgUIBQAAAA==.',['哲学']='哲学的淡季:BAABLAAFFH8KAAINAAII3h1/SwBPAAANAAII3h1/SwBPAAAAAA==.',['喵之']='喵之哀伤:BAAALAAECgYIDQAAAA==.',['喵了']='喵了个喵:BAACLAAFFH8QAAIUAAMILQ9/AwDKAAAUAAMILQ9/AwDKAAAsAAQKfy8AAhQABwjCIesBAFECABQABwjCIesBAFECAAAA.',['嗷呜']='嗷呜狮驼:BAAALAADCgEIAQAAAA==.',['噩梦']='噩梦无魂:BAAALAADCgYIBgAAAA==.',['土之']='土之灵:BAAALAAECgYIBwAAAA==.',['土灵']='土灵土:BAAALAADCgQIBAAAAA==.',['圣光']='圣光在忽悠你:BAABLAAFFH8GAAIRAAIIOxUdYwCXAAARAAIIOxUdYwCXAAAAAA==.',['地宝']='地宝:BAABLAAFFH8KAAISAAIIXyOxLACpAAASAAIIXyOxLACpAAAAAA==.',['地狱']='地狱豆浆:BAAALAAECgMIAwAAAA==.',['坚硬']='坚硬的稀饭:BAABLAAFFH8GAAIVAAII0hMVFgClAAAVAAII0hMVFgClAAAAAA==.',['塑心']='塑心:BAABLAAFFH8gAAICAAgIBBpQCgBHAgACAAgIBBpQCgBHAgAAAA==.',['塔莉']='塔莉塔莉:BAAALAAFFAEIAQAAAA==.',['墨狄']='墨狄斯丶菲比:BAAALAAECgcICAAAAA==.',['壹贰']='壹贰壹:BAAALAAECgYICwAAAA==.',['夏美']='夏美哩哩:BAABLAAECn8nAAMWAAcImxVkYADQAQAWAAcIbxNkYADQAQATAAIIqxMcfwB+AAAAAA==.',['多蒙']='多蒙卡欣:BAABLAAFFH8GAAIIAAIIRhnAJwCqAAAIAAIIRhnAJwCqAAAAAA==.',['大粽']='大粽子:BAAALAADCgYIBgAAAA==.',['大领']='大领主一弗丁:BAAALAAECgIIAgAAAA==.',['大黑']='大黑角:BAAALAAECgYIBgAAAA==.',['天下']='天下:BAAALAAFFAIIAgABLAAFFAYIBgAFAP4LAA==.',['天生']='天生人助力:BAABLAAFFH8GAAINAAYINxAcDQDVAQANAAYINxAcDQDVAQAAAA==.',['天空']='天空之翠玉:BAAALAAECgMIAwAAAA==.',['天道']='天道:BAAALAAECgUIBwABLAAFFAYIBgAFAP4LAA==.',['太阳']='太阳的人骑:BAAALAAECgYICwAAAA==.',['头上']='头上长犄角:BAAALAAFFAIIAgABLAAFFAgICAAFAFQTAA==.',['女大']='女大学生:BAACLAAFFH8IAAIKAAIITRZgMABDAAAKAAIITRZgMABDAAAsAAQKfxkAAgoABggeH7cwAP0BAAoABggeH7cwAP0BAAAA.',['娇嫣']='娇嫣的紫水晶:BAACLAAFFH8FAAIXAAMI/Q9cBgBgAAAXAAMI/Q9cBgBgAAAsAAQKfx0AAhcACAiqHfUGAGECABcACAiqHfUGAGECAAAA.',['安么']='安么么:BAAALAAECgYICAAAAA==.',['安德']='安德鲁茬儿:BAABLAAFFH8GAAIFAAIIYgv7cQA+AAAFAAIIYgv7cQA+AAAAAA==.',['宝宝']='宝宝爱吃肉:BAACLAAFFH8IAAIRAAMIxhFrXQCYAAARAAMIxhFrXQCYAAAsAAQKfzIAAhEACAgkG78YACcCABEACAgkG78YACcCAAAA.宝宝爱吃菜:BAABLAAFFH8NAAIFAAQIQBizMgD6AAAFAAQIQBizMgD6AAAAAA==.',['宫崎']='宫崎骏:BAAALAAECgIIAgAAAA==.',['小伙']='小伙伴:BAAALAAECgYICgAAAA==.',['小狼']='小狼的骑:BAAALAAECgIIAgAAAA==.',['小番']='小番茄屮:BAAALAAECgYIBgAAAA==.',['小短']='小短腿清辞:BAABLAAFFH8FAAIFAAMIng5hSAB/AAAFAAMIng5hSAB/AAABLAAFFAgICAAFAFQTAA==.',['小矮']='小矮子清辞:BAAALAAFFAIIAgABLAAFFAgICAAFAFQTAA==.',['小米']='小米虫子:BAABLAAFFH8VAAIRAAUIeQnCSwAMAQARAAUIeQnCSwAMAQAAAA==.',['小西']='小西几丶:BAAALAAECgYIDAAAAA==.',['小赤']='小赤佬:BAAALAAECgQIBgAAAA==.',['小辞']='小辞掐指一算:BAAALAAECggICAABLAAFFAgICAAFAFQTAA==.',['尼克']='尼克狐尼克:BAAALAADCgEIAQAAAA==.',['尼古']='尼古拉斯安德:BAAALAAFFAIIBAAAAA==.尼古拉斯安贝:BAABLAAFFH8HAAIIAAQIiQTKPgB2AAAIAAQIiQTKPgB2AAAAAA==.',['尼尼']='尼尼亚:BAAALAADCgMIAwAAAA==.',['山雨']='山雨欲来风:BAAALAAECgMIBAAAAA==.',['川续']='川续断:BAABLAAFFH8JAAIIAAYI/xQsHwB3AQAIAAYI/xQsHwB3AQAAAA==.',['巡猎']='巡猎者柒大人:BAAALAADCgMIAwAAAA==.',['巫喵']='巫喵王丶:BAAALAAECggIBgAAAA==.',['布洛']='布洛芬疼:BAAALAAFFAIIBAAAAA==.',['幻幻']='幻幻羽:BAAALAAFFAIIAgAAAA==.',['张顺']='张顺飞:BAAALAADCgIIAgAAAA==.',['弯的']='弯的我们:BAABLAAFFH8KAAIIAAIIWhTXMACeAAAIAAIIWhTXMACeAAAAAA==.',['强者']='强者之心:BAAALAADCgEIAQAAAA==.',['当时']='当时我就滚了:BAABLAAFFH8aAAIYAAYINBETEABPAQAYAAYINBETEABPAQAAAA==.',['很单']='很单纯很懵懂:BAABLAAFFH8SAAIWAAgINBo1CgBkAgAWAAgINBo1CgBkAgAAAA==.',['德矿']='德矿:BAAALAAECgIIAwABLAAFFAIIAgAQAAAAAA==.',['忍张']='忍张:BAAALAAECgYIDgAAAA==.',['快点']='快点我好痒:BAAALAAECgQIBAAAAA==.',['怒火']='怒火猎手:BAAALAADCgUIBQAAAA==.',['悲伤']='悲伤印眼眸:BAAALAADCgYIBgAAAA==.',['我们']='我们的开始:BAAALAAFFAMIBAAAAA==.',['我可']='我可能会掉线:BAAALAADCgMIAwAAAA==.我可能爱上你:BAAALAAECgMIAwAAAA==.我可能要掉线:BAAALAADCgcIBwAAAA==.',['我是']='我是小萨满:BAAALAAFFAIIAgAAAA==.我是萨满:BAAALAAECgIIAgAAAA==.',['我要']='我要嘣拾个:BAAALAAFFAIIAgAAAA==.我要打拾个:BAAALAAFFAIIBAAAAA==.我要打猎:BAAALAAECgYICwAAAA==.我要锤拾个:BAAALAAFFAIIAgAAAA==.',['所罗']='所罗门王后:BAABLAAFFH8GAAIEAAYITRGJEgDSAQAEAAYITRGJEgDSAQAAAA==.',['打渔']='打渔郎:BAABLAAFFH8GAAIWAAIIQxGKWQBIAAAWAAIIQxGKWQBIAAAAAA==.',['执笔']='执笔哀灬殤:BAAALAAECgYIBgAAAA==.',['扯毛']='扯毛线:BAACLAAFFH8GAAISAAIIGw45YwBZAAASAAIIGw45YwBZAAAsAAQKfxYAAhIABgiKH/0iAOsBABIABgiKH/0iAOsBAAAA.',['把耳']='把耳朵撿起來:BAABLAAFFH8EAAICAAQIkgb0awCRAAACAAQIkgb0awCRAAAAAA==.',['拳拳']='拳拳桃花开:BAAALAAECgUIBQAAAA==.',['挑灯']='挑灯问梦:BAABLAAFFH8MAAICAAYIOQ53RAA/AQACAAYIOQ53RAA/AQAAAA==.',['撒娇']='撒娇小满:BAACLAAFFH8KAAISAAII7BgDUgB6AAASAAII7BgDUgB6AAAsAAQKfxYAAhIABwhBH+YzAEUCABIABwhBH+YzAEUCAAAA.',['救人']='救人一锤子:BAABLAAFFH8NAAIFAAUIaxWYKQA4AQAFAAUIaxWYKQA4AQAAAA==.',['斥罪']='斥罪:BAAALAAFFAIIBAABLAAFFAMIFQASAKQOAA==.',['新无']='新无名氏:BAAALAAECgYIBgABLAAFFAIIBgAKAFMgAA==.',['无敌']='无敌热熔人:BAAALAADCggIDgAAAA==.',['无畏']='无畏骑士:BAAALAAECgYIDgAAAA==.',['时光']='时光之心:BAABLAAFFH8FAAIIAAUIKgCiagAFAAAIAAUIKgCiagAFAAAAAA==.',['明明']='明明就是明明:BAAALAAECgMIAwAAAA==.',['易碎']='易碎品:BAAALAAECgMIAwABLAAFFAYIBgAIAB0EAA==.',['星之']='星之卡比:BAAALAAECgYIBwAAAA==.',['星尘']='星尘:BAAALAAECgEIAQAAAA==.',['星明']='星明:BAAALAAECgYIEQAAAA==.',['星见']='星见草:BAACLAAFFH8GAAISAAIIDRJlRwB1AAASAAIIDRJlRwB1AAAsAAQKfxcAAhIABgjLIHA+ACMCABIABgjLIHA+ACMCAAAA.',['晋善']='晋善晋美:BAAALAAECggICAAAAA==.',['晕呼']='晕呼呼:BAABLAAFFH8OAAILAAQIsxf+HwAmAQALAAQIsxf+HwAmAQAAAA==.',['普罗']='普罗米修斯:BAACLAAFFH8GAAIIAAMICBHMKQCmAAAIAAMICBHMKQCmAAAsAAQKfx8AAggACAidHmcmAKkCAAgACAidHmcmAKkCAAAA.',['智狗']='智狗:BAAALAAECggIDQAAAA==.',['暗之']='暗之黎明:BAAALAAECgYIBgAAAA==.',['月夜']='月夜清霜:BAABLAAFFH8FAAILAAIIDxcvOgCHAAALAAIIDxcvOgCHAAAAAA==.',['月小']='月小九:BAAALAAECgYIDQAAAA==.',['月涩']='月涩香槟:BAAALAAECgMIAwAAAA==.',['月玖']='月玖歌:BAABLAAFFH8GAAIZAAYI6xG9HQBYAQAZAAYI6xG9HQBYAQAAAA==.',['月薇']='月薇儿:BAAALAAECgYIDgAAAA==.',['期盼']='期盼未来:BAAALAAFFAIIBAAAAA==.',['术大']='术大招凤:BAAALAAECgEIAQAAAA==.',['术矿']='术矿:BAAALAADCgQIBAABLAAFFAIIAgAQAAAAAA==.',['机械']='机械狗:BAAALAADCgUIBQAAAA==.',['松针']='松针听雨:BAAALAAECgYICQAAAA==.',['林宏']='林宏伟:BAAALAAECgUICAAAAA==.',['枫飞']='枫飞梦舞:BAABLAAFFH8PAAMDAAIIAxQ+FQCCAAADAAIIAxQ+FQCCAAAEAAIIwhKSVwBFAAAAAA==.',['梅伊']='梅伊比斯:BAAALAADCgIIAgAAAA==.',['梅比']='梅比斯:BAAALAAECgYIBwAAAA==.',['梦繁']='梦繁华:BAAALAAECgYIBgAAAA==.',['森蚺']='森蚺:BAABLAAFFH8GAAICAAYIPAwFRABAAQACAAYIPAwFRABAAQAAAA==.',['概辞']='概辞彼肉肉:BAAALAAFFAYIAgAAAA==.',['檬是']='檬是柠檬的檬:BAAALAAECgEIAQAAAA==.',['欧气']='欧气喵喵:BAABLAAFFH8MAAITAAII3h4/CgC4AAATAAII3h4/CgC4AAAAAA==.',['欲爱']='欲爱已忘言:BAAALAAECgMIAwAAAA==.',['毛里']='毛里求斯:BAAALAAFFAIIAgAAAA==.',['氤氲']='氤氲混沌:BAABLAAFFH8ZAAIaAAUI8hWfBwD+AAAaAAUI8hWfBwD+AAAAAA==.',['汉丁']='汉丁顿伯爵:BAAALAAFFAIIAgAAAA==.',['汐魔']='汐魔王:BAAALAAECgEIAQAAAA==.',['江城']='江城子:BAAALAAECgQIBAAAAA==.',['沐丷']='沐丷苒:BAAALAAECgUIBgAAAA==.',['沧海']='沧海丶扬尘:BAACLAAFFH8wAAISAAYIgyLdCAA+AgASAAYIgyLdCAA+AgAsAAQKfzYAAhIACAi+IEsUANECABIACAi+IEsUANECAAAA.',['河发']='河发源于:BAAALAAFFAIIAgAAAA==.',['泅游']='泅游:BAABLAAFFH8KAAILAAIIsw7mPABjAAALAAIIsw7mPABjAAAAAA==.',['法西']='法西丝丶:BAAALAAECgYIBgAAAA==.',['波波']='波波哥:BAABLAAECn8ZAAINAAYIkRAWVAAiAQANAAYIkRAWVAAiAQAAAA==.波波哥哥:BAAALAAECgYIEgAAAA==.',['流水']='流水之透辉石:BAAALAAECggIDgAAAA==.',['海墟']='海墟:BAAALAAECgYICgAAAA==.',['淄博']='淄博井柏然:BAACLAAFFH8ZAAIEAAUIURtBLwBPAQAEAAUIURtBLwBPAQAsAAQKfxUAAgQABgitFdmGAIEBAAQABgitFdmGAIEBAAAA.淄博吴彦祖:BAAALAAFFAMIAwAAAA==.淄博彭于晏:BAABLAAFFH8FAAICAAMI4w7PcwB/AAACAAMI4w7PcwB/AAAAAA==.',['淮山']='淮山:BAAALAAECgYIDQAAAA==.',['深渊']='深渊之玛瑙玉:BAAALAAECggICAAAAA==.',['清源']='清源丫:BAABLAAFFH8TAAMKAAUIexHmGAAXAQAKAAUIexHmGAAXAQALAAQIFA0dKgDOAAAAAA==.',['溪水']='溪水外流:BAAALAADCgYIBgAAAA==.溪水常流:BAAALAADCgcICwAAAA==.',['火爆']='火爆腰花:BAAALAADCgIIAgAAAA==.',['火红']='火红的心:BAABLAAECn8VAAIFAAYIfxJEzAB2AQAFAAYIfxJEzAB2AQAAAA==.',['灯火']='灯火不灭:BAABLAAFFH8UAAICAAgIsRWLDgAcAgACAAgIsRWLDgAcAgAAAA==.',['灵感']='灵感菇:BAAALAAFFAIIAgAAAA==.',['灼灼']='灼灼其华楠:BAAALAAECggICgAAAA==.',['点纱']='点纱织:BAAALAAECgEIAQAAAA==.',['炽焰']='炽焰圣卫莱恩:BAAALAAECgYICAAAAA==.',['热心']='热心网友:BAAALAADCgYIBgAAAA==.热心观众:BAAALAADCgYIBgAAAA==.',['無銘']='無銘天使:BAAALAAECgYIEQAAAA==.無銘小卒:BAAALAAECgYIDQAAAA==.無銘肥兴:BAAALAAECgYICwAAAA==.無銘零零:BAAALAAECgEIAQAAAA==.',['焰尾']='焰尾:BAABLAAFFH8UAAICAAYI4B5ZGwDNAQACAAYI4B5ZGwDNAQAAAA==.',['熊猫']='熊猫羊:BAAALAADCgEIAQAAAA==.',['燕归']='燕归:BAAALAAECgcIBwAAAA==.',['爆炸']='爆炸虚区:BAABLAAFFH8IAAMMAAIIOhPzBACZAAAMAAIIrxLzBACZAAACAAIIDA/+ZQCHAAAAAA==.',['爱夏']='爱夏:BAAALAAECggICAAAAA==.',['牧名']='牧名:BAAALAADCggICAAAAA==.',['狂风']='狂风烟雨:BAAALAAFFAIIAgAAAA==.',['狐乱']='狐乱喝:BAAALAAECgUIBQAAAA==.狐乱奶:BAAALAADCgcIBwABLAAFFAIIAgAQAAAAAA==.狐乱电:BAAALAAFFAIIAgAAAA==.',['狐小']='狐小白:BAAALAAECgYIDAAAAA==.',['狩猎']='狩猎小学生:BAAALAADCggICAAAAA==.',['猎猎']='猎猎风中:BAAALAAECgEIAQAAAA==.',['猫宁']='猫宁:BAAALAAECgYIDgAAAA==.',['獄門']='獄門:BAABLAAFFH8aAAMTAAUI5BuFCwBnAAAWAAQIzhhWMwBOAQATAAIImCKFCwBnAAAAAA==.',['獒呜']='獒呜呜:BAAALAAECgYIBgAAAA==.',['玉藻']='玉藻前丷:BAABLAAFFH8JAAICAAgI0xCmFwDhAQACAAgI0xCmFwDhAQAAAA==.',['玉逍']='玉逍遥:BAAALAAECgYIEgAAAA==.',['王否']='王否留行:BAAALAAFFAIIBAAAAA==.',['玥九']='玥九歌:BAAALAAECgYIEAAAAA==.',['理性']='理性论马:BAABLAAFFH8GAAIGAAYI5RZfBAD6AQAGAAYI5RZfBAD6AQAAAA==.',['瑾年']='瑾年丨福狂牛:BAAALAAECgYIBgAAAA==.',['生雾']='生雾生:BAAALAAECggICAAAAA==.',['申小']='申小贝:BAAALAAECgYIBQAAAA==.',['电灯']='电灯泡:BAAALAAFFAIIAgABLAAFFAgICAAFAFQTAA==.',['电竞']='电竞肖邦:BAAALAAECgEIAQAAAA==.',['白哩']='白哩个白:BAAALAADCgEIAQAAAA==.',['白夜']='白夜行:BAAALAAFFAIIBAABLAAFFAYIBgAIAB0EAA==.',['白就']='白就穿:BAAALAAECgEIAQAAAA==.',['白藏']='白藏主丷:BAABLAAFFH8ZAAICAAcIyh9UCgBHAgACAAcIyh9UCgBHAgAAAA==.',['益达']='益达口香糖:BAAALAAECgMIAwAAAA==.',['盛夏']='盛夏灬初晴:BAAALAAECgIIAgAAAA==.',['短发']='短发女神经:BAAALAAECgYICQAAAA==.',['砺剑']='砺剑蔷薇:BAAALAAECgcIEgAAAA==.',['神一']='神一般的男人:BAAALAADCggICAAAAA==.',['秦始']='秦始皇嬴政:BAAALAAECgEIAQAAAA==.',['笑笑']='笑笑黎明:BAAALAAECgYIDAAAAA==.',['筱月']='筱月若水:BAAALAADCgMIAwAAAA==.',['精钢']='精钢芭比:BAAALAAECgQIBAAAAA==.',['紫衣']='紫衣如煙:BAAALAAECgYIDAAAAA==.',['红色']='红色熊猫:BAAALAAECgYIDwAAAA==.',['纸糊']='纸糊的阿昆达:BAABLAAFFH8IAAINAAgINwGPcQAaAAANAAgINwGPcQAaAAAAAA==.',['给我']='给我一个么么:BAAALAAECggICAAAAA==.',['绫晄']='绫晄:BAAALAAECggIBwAAAA==.',['绮罗']='绮罗悦芬芳:BAABLAAFFH8RAAIRAAQIPxHiUQDeAAARAAQIPxHiUQDeAAAAAA==.',['维密']='维密天使:BAAALAAECgEIAQAAAA==.',['老贼']='老贼:BAAALAADCggICAAAAA==.',['聽南']='聽南門說:BAAALAADCgMIBgAAAA==.',['肯恰']='肯恰那叮叮:BAABLAAFFH8GAAISAAIIVhyQQgChAAASAAIIVhyQQgChAAAAAA==.',['背脊']='背脊唱情歌:BAAALAAECggICAAAAA==.',['胖不']='胖不死:BAAALAAECgYIBgAAAA==.',['胖大']='胖大仁:BAACLAAFFH8YAAQbAAYIEwhsEwBkAAAbAAYIEwhsEwBkAAAYAAIIXAPRHABVAAAcAAIIuwEQGwBGAAAsAAQKfygABBsABwg4GY0hAPUBABsABggUHI0hAPUBABgABwjNCLUxAAUBABwABAivBzJHAIsAAAAA.',['腾唧']='腾唧唧:BAAALAAFFAIIAgAAAA==.',['自在']='自在的风:BAAALAAECgYIBgAAAA==.',['自然']='自然睡到醒:BAABLAAFFH8IAAIBAAII1yGYFADCAAABAAII1yGYFADCAAAAAA==.',['舟小']='舟小柒:BAAALAAECggICAAAAA==.',['舟柒']='舟柒词:BAAALAAECgUIBwAAAA==.',['艼香']='艼香:BAAALAAECgYIDwAAAA==.',['艾力']='艾力:BAABLAAFFH8GAAMSAAYIrwnLMgDjAAASAAUILArLMgDjAAAZAAEISwenSAA/AAAAAA==.',['艾叶']='艾叶流觞:BAAALAAFFAIIAwAAAA==.',['艾雅']='艾雅法拉:BAAALAAFFAIIBAABLAAFFAMIFQASAKQOAA==.',['芒鞋']='芒鞋:BAAALAAECgYIDAAAAA==.',['芳得']='芳得始终:BAAALAAECgYICAAAAA==.',['苇草']='苇草:BAABLAAFFH8aAAICAAgI8BR2DgAcAgACAAgI8BR2DgAcAgAAAA==.',['苍天']='苍天之青玉:BAABLAAFFH8GAAMLAAIIJRvDNACaAAALAAIIJRvDNACaAAAKAAIIbwaMOAA3AAABLAAFFAgIPgAdAMMlAA==.',['苏苏']='苏苏小妹:BAABLAAECn8UAAICAAYI4h2jTwCoAQACAAYI4h2jTwCoAQAAAA==.',['莫小']='莫小小:BAAALAAECgYIDQAAAA==.',['莱因']='莱因哈特:BAACLAAFFH8LAAIGAAIIKyQRHADRAAAGAAIIKyQRHADRAAAsAAQKfxkAAgYABwh9EkY1AJIBAAYABwh9EkY1AJIBAAAA.',['莱贝']='莱贝克勒:BAAALAADCgMIAwAAAA==.',['菟菟']='菟菟格蕾丝:BAACLAAFFH8KAAIJAAIIJAk0OwB/AAAJAAIIJAk0OwB/AAAsAAQKfxwAAx4ABwhQFIgWAFEBAAkABwj0ExRLAKoBAB4ABgg7EogWAFEBAAAA.',['萨拉']='萨拉塔斯:BAAALAADCgYIBgAAAA==.',['落雨']='落雨归尘:BAABLAAFFH8QAAISAAUIVRe3IgBPAQASAAUIVRe3IgBPAQAAAA==.',['蒙宝']='蒙宝宝:BAAALAAECgYIDAAAAA==.',['蒙牛']='蒙牛优酸乳:BAABLAAFFH8LAAISAAMILRWtQACnAAASAAMILRWtQACnAAAAAA==.',['虚空']='虚空大君:BAAALAAFFAYIAwAAAA==.',['蝠乱']='蝠乱飞:BAAALAAECgEIAQABLAAFFAIIAgAQAAAAAA==.',['血与']='血与暗的挣扎:BAAALAAFFAYIAgAAAA==.',['西瓜']='西瓜拿铁丶:BAAALAAECgEIAQAAAA==.',['西行']='西行寺幽幽子:BAAALAADCgEIAQAAAA==.',['记得']='记得打给我:BAABLAAECn8XAAMCAAYIqCJVOgDfAQABAAYI8h25MgD3AQACAAYIaCJVOgDfAQAAAA==.',['谢芽']='谢芽:BAAALAAFFAEIAQAAAA==.',['谭松']='谭松韵:BAAALAAECgYIBwAAAA==.',['豪华']='豪华咕咕套餐:BAAALAADCgcIDwAAAA==.',['起门']='起门专用:BAACLAAFFH8IAAIWAAIIrw9CXQBDAAAWAAIIrw9CXQBDAAAsAAQKfyEAAxYACAhoGtIkAM4BABYACAhoGtIkAM4BABcAAgiuD5g7AEQAAAAA.',['超级']='超级神猎手:BAAALAADCggICAAAAA==.超级美男子:BAAALAAECgYICAAAAA==.',['踩地']='踩地板丶:BAAALAAECggICgAAAA==.',['轰炸']='轰炸鸡:BAACLAAFFH9CAAIKAAYI9SMxBgATAgAKAAYI9SMxBgATAgAsAAQKfyYAAgoACAgwI2IIAH4CAAoACAgwI2IIAH4CAAAA.',['达布']='达布拉:BAABLAAECn8VAAMCAAYIFRgLwADxAAACAAQI9RsLwADxAAABAAMIHw5alQCWAAAAAA==.',['迷羽']='迷羽:BAAALAAFFAIIAgAAAA==.',['退潮']='退潮虾:BAAALAAECgYIBgAAAA==.',['逃的']='逃的飞快:BAAALAAFFAMIAwAAAA==.',['通天']='通天干探:BAAALAAFFAIIAgAAAA==.',['逢坂']='逢坂大河:BAABLAAFFH8MAAIBAAYIMAQcDADJAAABAAYIMAQcDADJAAAAAA==.',['邪能']='邪能奶昔:BAAALAAECgQIBAAAAA==.',['醉红']='醉红尘:BAAALAAECgYIDwAAAA==.',['钢达']='钢达姆机器人:BAAALAAECgYIBwAAAA==.',['铁甲']='铁甲黑大米:BAABLAAFFH8IAAMBAAIIhg3fJwB4AAABAAIIhg3fJwB4AAACAAEIBQUtzgAAAAAAAA==.',['银之']='银之流星:BAACLAAFFH8RAAMEAAMI8ht/OACqAAAEAAIIFR9/OACqAAADAAIIwRhmGABAAAAsAAQKfxoAAwMABwjkIh4dADICAAMABgjXIh4dADICAAQABQjKHa17AJ0BAAAA.',['银翼']='银翼圣龙:BAAALAAECgYIBgAAAA==.',['长烟']='长烟落日:BAAALAAECgcIBwAAAA==.',['闪光']='闪光蹄子:BAAALAAECggICQABLAAFFAgICAAFAFQTAA==.闪光黑豆:BAAALAAECggIDQAAAA==.',['闷闷']='闷闷儿:BAAALAAECgMIAwAAAA==.',['阡陌']='阡陌花开:BAABLAAFFH8GAAILAAYI8A2/HABFAQALAAYI8A2/HABFAQAAAA==.',['阿叁']='阿叁:BAAALAAECgQIBAAAAA==.',['阿呦']='阿呦痛阿:BAAALAAECgYIBgAAAA==.',['阿鲁']='阿鲁比斯:BAAALAAECgIIAgAAAA==.',['陈乔']='陈乔恩:BAABLAAFFH8PAAIIAAUIjA+LKQAqAQAIAAUIjA+LKQAqAQAAAA==.',['陶萌']='陶萌萌:BAAALAADCgEIAQAAAA==.',['随风']='随风飘飘:BAAALAADCgEIAQAAAA==.',['雪天']='雪天使:BAABLAAFFH8JAAIJAAMIKx00JACoAAAJAAMIKx00JACoAAAAAA==.',['雲岸']='雲岸無霜:BAABLAAFFH8OAAIJAAUIgw96IQBBAQAJAAUIgw96IQBBAQAAAA==.',['雷欧']='雷欧娜:BAAALAAECgYIEgAAAA==.',['霜刃']='霜刃骑士:BAAALAAECgEIAQAAAA==.',['青光']='青光流萤:BAAALAAECgcIBwAAAA==.',['青旗']='青旗沽酒:BAAALAAECgYIBwAAAA==.',['青木']='青木爭羽:BAACLAAFFH8MAAMGAAIIqBKdGwCSAAAGAAIIqBKdGwCSAAAFAAIIkgn+UwCOAAAsAAQKfxsABAYABwjYFH82AIwBAAYABwjYFH82AIwBAAUABQg7Fkn1ADsBAAcAAwgECU9sAFoAAAAA.',['青青']='青青灬拧:BAAALAAECgUIBQAAAA==.',['面条']='面条:BAABLAAFFH8GAAMBAAIIQhUvIwCBAAABAAIIpxIvIwCBAAACAAEItQ6UsQA4AAAAAA==.',['顽强']='顽强的小强:BAAALAAECgIIAgAAAA==.',['风月']='风月无影:BAAALAAECgYIDAAAAA==.',['马尔']='马尔兰:BAAALAAECgYIBgAAAA==.',['骨香']='骨香一号:BAABLAAFFH8WAAIYAAYIlxMPCABvAQAYAAYIlxMPCABvAQAAAA==.骨香七号:BAABLAAFFH8MAAIYAAYIug8IEQBBAQAYAAYIug8IEQBBAQAAAA==.骨香三号:BAABLAAFFH8iAAIYAAYIvxjGCABWAQAYAAYIvxjGCABWAQAAAA==.骨香二号:BAABLAAFFH8XAAIYAAYIeBJKCABoAQAYAAYIeBJKCABoAQAAAA==.骨香五号:BAABLAAFFH8bAAIYAAYIqhZrCgAcAQAYAAYIqhZrCgAcAQAAAA==.骨香六号:BAABLAAFFH8YAAIYAAYIvwxrEQA6AQAYAAYIvwxrEQA6AQAAAA==.骨香四号:BAABLAAFFH8RAAIYAAYIjRDeCgAMAQAYAAYIjRDeCgAMAQAAAA==.',['高大']='高大威猛噢:BAAALAAECgYICAAAAA==.',['魑魅']='魑魅之息:BAAALAADCgMIAwAAAA==.魑魅之灵:BAABLAAFFH8OAAIaAAUIQROrBwD9AAAaAAUIQROrBwD9AAAAAA==.魑魅之灾:BAABLAAFFH8MAAIRAAUIxBdLPABRAQARAAUIxBdLPABRAQAAAA==.',['麒麟']='麒麟小猪:BAAALAADCgQIBAAAAA==.',['黄致']='黄致列:BAABLAAFFH8GAAICAAIIMA4rdAB6AAACAAIIMA4rdAB6AAAAAA==.',['黎明']='黎明嘻嘻:BAAALAAECgYIDQAAAA==.黎明小法:BAAALAAECgYICwAAAA==.',['黑壮']='黑壮壮:BAAALAAECgQIBAAAAA==.',['黑裙']='黑裙子:BAAALAAECgcIDAAAAA==.',['默子']='默子陌:BAABLAAFFH8XAAMSAAUIWg1rMADyAAASAAUIWg1rMADyAAAZAAEItAGBVQAnAAAAAA==.',['龙乡']='龙乡之星:BAAALAAECgIIAgAAAA==.',['龙王']='龙王破山剑:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end