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
 local lookup = {'Rogue-Assassination','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Frost','DemonHunter-Havoc','Druid-Balance','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Mage-Arcane','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','Druid-Restoration','Warrior-Fury','Warrior-Protection','Shaman-Elemental','Shaman-Restoration','Priest-Shadow','DemonHunter-Vengeance','Unknown-Unknown','Warrior-Arms','Evoker-Preservation','Rogue-Subtlety','Mage-Frost','DeathKnight-Blood','Monk-Mistweaver','Monk-Brewmaster','Warlock-Destruction','Mage-Fire','Druid-Guardian','Warlock-Demonology','Hunter-Survival','Druid-Feral','Evoker-Devastation','Warlock-Affliction',}; local provider = {region='CN',realm='丹莫德',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aa='Aaronzz:BAAALAAECgEIAQAAAA==.',Ab='Abababababa:BAAALAAECgMIAwABLAAFFAIICAABABAjAA==.Abbas:BAAALAADCgYIBgAAAA==.',Al='Alluka:BAAALAADCgUIBQAAAA==.',Ap='Applejuice:BAABLAAFFH8NAAMCAAYIEQ4pQQBDAQACAAYIFQwpQQBDAQADAAMIbgZsKwBwAAAAAA==.',As='Asukalangley:BAAALAAFFAIIAgAAAA==.',Ay='Ayboin:BAAALAAECgYIAwAAAA==.',Ba='Baku:BAAALAAECgMIAwAAAA==.',Be='Beauty:BAAALAAECgYIDwAAAA==.Beetomb:BAAALAAFFAIIBAAAAA==.',Bl='Blacklu:BAAALAAECgQIBAAAAA==.Blackmage:BAAALAAECgcICwAAAA==.',Br='Brokenpoint:BAAALAAECgIIAgAAAA==.',Ca='Cantcahtzs:BAAALAAECggIEgAAAA==.',Co='Columbia:BAAALAAECgMIAwAAAA==.Conjurs:BAACLAAFFH8NAAIEAAYIqRy0FAClAQAEAAYIqRy0FAClAQAsAAQKfyAAAgQACAh5ImglANsCAAQACAh5ImglANsCAAAA.',Da='Danny:BAAALAAECgYIDwAAAA==.Daybyday:BAAALAAECgMIAwAAAA==.',Dd='Ddqer:BAAALAAECgUIBQAAAA==.',Dh='Dhqaq:BAABLAAFFH8SAAIFAAYIxiJfDAAEAgAFAAYIxiJfDAAEAgAAAA==.',Di='Disconice:BAAALAAECgYICwAAAA==.',Do='Donava:BAAALAAFFAIIAgAAAA==.Doublehuman:BAAALAADCgMIAwAAAA==.',Dr='Dragontec:BAAALAAFFAIIAgAAAA==.Drechunter:BAABLAAFFH8IAAICAAYIWQQ3bQCHAAACAAYIWQQ3bQCHAAAAAA==.',Fl='Fly:BAAALAAECgYICwAAAA==.',Fo='Forthreen:BAABLAAFFH8GAAIGAAII9QkNOAA2AAAGAAII9QkNOAA2AAAAAA==.',Fr='Frefh:BAAALAADCgQIBAAAAA==.',Fu='Funnel:BAAALAAECgYIBgAAAA==.',Gi='Giveyou:BAAALAADCgEIAQAAAA==.',Go='Gobang:BAAALAAECgcIDgAAAA==.',Gu='Guerdan:BAAALAAECggICgAAAA==.',Hb='Hbend:BAAALAAFFAIIBAAAAA==.',Hr='Hrunting:BAAALAAECgQIBAAAAA==.',Ic='Iceqi:BAAALAAFFAIIBAAAAA==.',Il='Ilonginus:BAAALAADCgMIAwAAAA==.',Ku='Kumo:BAABLAAFFH8MAAIEAAgIjSJnAwDPAgAEAAgIjSJnAwDPAgAAAA==.',Li='Liardancer:BAAALAAFFAEIAQAAAA==.',Lo='Loosepusysy:BAABLAAFFH8dAAQHAAYIthwgFQCkAQAHAAYIthwgFQCkAQAIAAII8QKiJgBvAAAJAAII7gByIgBBAAAAAA==.',Mo='Moo:BAAALAAECgUICQAAAA==.',Ne='Nevxvm:BAAALAAECggIAQAAAA==.',No='Noikie:BAABLAAFFH8GAAIKAAII5w5QUQCQAAAKAAII5w5QUQCQAAAAAA==.',Oo='Ookami:BAAALAAECgUIBAAAAA==.',Pa='Paradise:BAABLAAECn8fAAIBAAgIAw9rDQCNAQABAAgIAw9rDQCNAQAAAA==.',Pl='Playertadtok:BAACLAAFFH8MAAIEAAIIqx8oPAC5AAAEAAIIqx8oPAC5AAAsAAQKfx0AAgQABwgmIgc8AIwCAAQABwgmIgc8AIwCAAAA.Playerxxaiun:BAAALAAECgQIBAAAAA==.',Pu='Punchme:BAABLAAFFH8HAAMLAAMIbAzWMQCiAAALAAMIbAzWMQCiAAAMAAEIqQOVCQAeAAAAAA==.',Qu='Quee:BAAALAAECgYICAAAAA==.',Re='Recaro:BAAALAADCgYIBgAAAA==.Remyn:BAAALAADCgIIAgAAAA==.Reverend:BAAALAADCgcIBwAAAA==.',Sa='Samsarm:BAAALAAECgYIBgAAAA==.Samsarms:BAAALAAECgYICwAAAA==.Satori:BAABLAAFFH8hAAMCAAcIoR80CwAzAgACAAcIoR80CwAzAgADAAEI4xdfEwBNAAAAAA==.',Sh='Shelby:BAABLAAFFH8MAAINAAYIoRNYAwCXAQANAAYIoRNYAwCXAQAAAA==.',Sl='Slowlyhunter:BAAALAAECgYIBgAAAA==.',Sp='Springmao:BAAALAAFFAIIAQAAAA==.',Sw='Sweetdefence:BAAALAAFFAIIAgABLAAFFAUIIQAFAMkgAA==.',Th='Thequiett:BAAALAAECgEIAQAAAA==.',Tr='Traxex:BAABLAAFFH8GAAICAAIIoRZYpwA7AAACAAIIoRZYpwA7AAAAAA==.',Wa='Warman:BAAALAAECggICAAAAA==.',Yo='Yogsothoth:BAAALAAFFAIIBAAAAA==.',['Ãä']='Ãäãä:BAAALAADCgYIBgAAAA==.',['一学']='一学就废:BAAALAAECggIEgAAAA==.',['一条']='一条不归路:BAAALAAECgYIDAAAAA==.',['一枪']='一枪不开:BAAALAADCggICAAAAA==.',['一箭']='一箭穿心丶:BAAALAAFFAIIAwAAAA==.',['万花']='万花不点墨:BAAALAADCggICAAAAA==.',['三个']='三个手指:BAAALAAECgQIBAAAAA==.',['上杉']='上杉夏香:BAAALAAFFAIIBAAAAA==.',['不会']='不会取名:BAAALAAECgYIEAAAAA==.不会取名术:BAAALAAECgYIDwAAAA==.不会取名骑:BAAALAADCgUIBQAAAA==.',['不带']='不带这么玩的:BAAALAAECgMIAwAAAA==.',['不白']='不白:BAABLAAFFH8IAAIOAAIIcRLkMQBwAAAOAAIIcRLkMQBwAAAAAA==.',['不能']='不能:BAABLAAFFH8GAAIHAAIIGRuhMgCoAAAHAAIIGRuhMgCoAAAAAA==.',['不讲']='不讲武德:BAAALAAECgYIBgAAAA==.',['专业']='专业假死:BAAALAAFFAMIAwAAAA==.',['东风']='东风陆拾壹:BAAALAAECgQIBgAAAA==.',['丨女']='丨女骑士丨:BAAALAADCgEIAQAAAA==.',['丨狂']='丨狂暴神丨:BAAALAAECgUIBQAAAA==.',['中信']='中信证券:BAAALAAECgYICQAAAA==.',['临悉']='临悉:BAAALAAECgcICwAAAA==.',['丶娜']='丶娜美:BAAALAAECggICAAAAA==.',['丶无']='丶无忧:BAAALAADCggIEAAAAA==.',['丶月']='丶月神:BAAALAAFFAIIBAAAAA==.',['丶美']='丶美呆:BAAALAAECggICAAAAA==.',['丿灬']='丿灬邪:BAACLAAFFH8PAAIPAAMI+hS7OQCLAAAPAAMI+hS7OQCLAAAsAAQKfxUAAg8ACAhNFz0eAPkBAA8ACAhNFz0eAPkBAAAA.',['乃乃']='乃乃个熊:BAAALAAFFAIIAwAAAA==.',['乐邦']='乐邦詹士:BAAALAADCgYIBgAAAA==.',['乘峰']='乘峰:BAAALAADCgIIAgAAAA==.',['九浅']='九浅亿深:BAAALAAECgQIBgAAAA==.',['了然']='了然:BAAALAAECgYIBgAAAA==.',['二零']='二零一八:BAACLAAFFH8YAAMPAAYIYBQSGwCNAQAPAAYI+BISGwCNAQAQAAIIsRlRGQCTAAAsAAQKfxQAAxAABgiMH7suANsBABAABgiRHbsuANsBAA8AAgiPHyTWAL0AAAAA.',['互相']='互相伤害啊:BAAALAAECgMIAwAAAA==.',['亓晓']='亓晓:BAAALAAECgYICQAAAA==.亓晓晓:BAAALAAECgQIBAAAAA==.',['五十']='五十已到:BAAALAADCgYICgAAAA==.',['亦萌']='亦萌亦妖:BAAALAAECgIIAgAAAA==.',['亵渎']='亵渎杀戮:BAAALAAFFAIIAgAAAA==.',['人生']='人生休说痛苦:BAABLAAFFH8cAAICAAYI8RUGJwDgAAACAAYI8RUGJwDgAAABLAAFFAgIEgACAM0MAA==.',['人造']='人造雷轰渣男:BAAALAAFFAIIBAAAAA==.',['亿叮']='亿叮定乾坤:BAAALAAECggICAAAAA==.',['仅仅']='仅仅如此:BAAALAADCgcIBwAAAA==.',['仟夜']='仟夜:BAAALAAECgUIBQAAAA==.',['伊如']='伊如雪:BAAALAAECggIDgAAAA==.',['伊姆']='伊姆帕里斯:BAAALAAECgQIBwAAAA==.',['伊拉']='伊拉贝塔:BAAALAAECgYIDQAAAA==.',['伍贰']='伍贰:BAAALAAECgIIAgAAAA==.',['伐要']='伐要太难看:BAAALAAFFAIIBAAAAA==.',['会心']='会心一笑:BAAALAADCgIIAgAAAA==.',['伟大']='伟大教员:BAAALAAECgYICAAAAA==.',['低等']='低等动物:BAAALAAECggICgAAAA==.',['佳娃']='佳娃儿:BAAALAAECgYIDQAAAA==.',['俺村']='俺村就我牛笔:BAAALAAECgcIBgAAAA==.',['俺要']='俺要吃蜂蜜:BAAALAAECgYIEgAAAA==.',['倒叙']='倒叙的小时光:BAAALAADCgIIAgAAAA==.',['偏分']='偏分:BAAALAAECgUIBQAAAA==.',['偲偲']='偲偲嚸嚸:BAAALAAECgYIBgAAAA==.',['偶不']='偶不是天然呆:BAAALAAFFAIIAgAAAA==.',['傻傻']='傻傻的馒馒:BAABLAAFFH8IAAMRAAIIFAd3NAB/AAARAAIIFAd3NAB/AAASAAIIsRXkVwBrAAAAAA==.',['傻蛋']='傻蛋丶:BAABLAAFFH8FAAICAAIIPwqjrgA4AAACAAIIPwqjrgA4AAAAAA==.',['像只']='像只大虾:BAABLAAFFH8HAAIOAAUIlgp+IwAAAQAOAAUIlgp+IwAAAQABLAAFFAgICAAOADMeAA==.',['先祖']='先祖之父:BAAALAAFFAMIAwAAAA==.',['克里']='克里斯丶:BAAALAAECgYIBgAAAA==.',['兔尾']='兔尾巴:BAAALAADCgYIBgAAAA==.',['兜兜']='兜兜木有豆豆:BAACLAAFFH8pAAMTAAYI5xQhDgB+AQATAAYI5xQhDgB+AQALAAYI7AWHEwASAQAsAAQKfy8AAxMACAgUH78UAMkCABMACAgUH78UAMkCAAsABwjdDDNoAEMBAAAA.',['六六']='六六霸霸:BAAALAAECgYIBgAAAA==.',['共饮']='共饮长江水:BAAALAADCgIIAQAAAA==.',['兼职']='兼职技师:BAAALAAECgIIAgAAAA==.',['再嘘']='再嘘也要社:BAABLAAECn8jAAMDAAYI0BmDRQCgAQADAAYI0BmDRQCgAQACAAYIiwtOxgDlAAAAAA==.',['冬季']='冬季校园:BAAALAADCgIIAgAAAA==.',['冬涤']='冬涤:BAAALAAECgYIBgAAAA==.',['冰块']='冰块:BAABLAAFFH8XAAIEAAYIOxOJLgCAAQAEAAYIOxOJLgCAAQAAAA==.',['冰墨']='冰墨心:BAAALAADCgEIAQAAAA==.',['冰封']='冰封小箭:BAAALAAECgMIAwAAAA==.',['冰炎']='冰炎傲义:BAAALAAECgMIAwAAAA==.',['冲釒']='冲釒:BAABLAAFFH8IAAIQAAgIwQ2cCQCoAQAQAAgIwQ2cCQCoAQAAAA==.',['况总']='况总是只鹌鹑:BAAALAAECgUIBQAAAA==.',['况某']='况某人:BAAALAAECgUIBQAAAA==.',['况阿']='况阿姨:BAAALAAECgMIAwAAAA==.',['凤翔']='凤翔歧水:BAAALAADCgYIBgAAAA==.',['凶刃']='凶刃之痕:BAAALAAECgYICwAAAA==.',['刻于']='刻于星月之铭:BAACLAAFFH8RAAMLAAYICA0tMgChAAALAAMIawQtMgChAAATAAMIXQ57IACEAAAsAAQKfx4AAxMABghpD6RYAFQBABMABghpD6RYAFQBAAsAAQjkAXHIAB8AAAAA.',['剑胆']='剑胆琴心:BAABLAAFFH8MAAIUAAMIaggODwBTAAAUAAMIaggODwBTAAAAAA==.',['剥皮']='剥皮三世:BAAALAAFFAIIBAAAAA==.剥皮小能手:BAAALAAECgYIBgAAAA==.',['副主']='副主编:BAABLAAFFH8bAAISAAUI0xUeGwDdAAASAAUI0xUeGwDdAAAAAA==.',['功夫']='功夫魔头:BAAALAAFFAIIAgAAAA==.',['加勒']='加勒比海豹:BAAALAAECgEIAQAAAA==.',['加尔']='加尔撸什:BAAALAAECgcIBwAAAA==.',['北川']='北川杏树:BAAALAAECgYIBgAAAA==.',['十方']='十方:BAAALAAECgEIAQAAAA==.',['单身']='单身小阿姨:BAACLAAFFH8bAAINAAUIDCDgAwB/AQANAAUIDCDgAwB/AQAsAAQKfxsAAg0ACAgrI6IBALsCAA0ACAgrI6IBALsCAAEsAAUUBQghAAoAHBYA.',['南千']='南千秋:BAAALAADCgIIAgAAAA==.',['南小']='南小鸟的缰绳:BAAALAADCgYIBgAAAA==.',['卡拉']='卡拉季:BAABLAAFFH8IAAIEAAII4QltiwBAAAAEAAII4QltiwBAAAAAAA==.',['厘小']='厘小宝:BAAALAAECgYIBgAAAA==.',['叫我']='叫我小德儿:BAAALAAECgIIAgAAAA==.',['叭叭']='叭叭啦叭叭丶:BAAALAAECgYIEQAAAA==.',['可口']='可口丨蟹黄堡:BAAALAAECgIIAgAAAA==.',['吃我']='吃我大黑炎龙:BAAALAAFFAIIBAABLAAFFAIICAABABAjAA==.',['吃瓜']='吃瓜:BAAALAAECgYIBgAAAA==.',['君住']='君住长江头:BAAALAAECgIIAgAAAA==.',['吾辈']='吾辈心中有火:BAAALAAFFAIIAgAAAA==.',['呃呃']='呃呃乖:BAAALAAECgEIAQAAAA==.',['呆呆']='呆呆兽:BAAALAAECgcICwAAAA==.',['周七']='周七七:BAAALAAECgUIBQAAAA==.',['周大']='周大仙:BAAALAAECgYIBgAAAA==.',['呵呵']='呵呵你个头:BAAALAADCgYIBgAAAA==.',['咋真']='咋真紧张:BAAALAADCgcIBwAAAA==.',['咻咻']='咻咻的身丶寸:BAABLAAFFH8JAAMCAAMIQRjbIwDvAAACAAMIQRjbIwDvAAADAAEInBD4NABBAAAAAA==.',['咿呀']='咿呀咿呀:BAAALAAECgEIAQAAAA==.',['哇靠']='哇靠不是吧:BAAALAAECgUIBQAAAA==.',['哈莱']='哈莱莱:BAAALAADCggICAAAAA==.',['哈雷']='哈雷娜:BAABLAAFFH8HAAIHAAIIlQlsYwBEAAAHAAIIlQlsYwBEAAAAAA==.',['响暮']='响暮崩云:BAAALAADCgQIBAAAAA==.',['哎呀']='哎呀哈黑凤梨:BAABLAAFFH8YAAISAAYIRBy/DwDoAQASAAYIRBy/DwDoAQAAAA==.',['唛土']='唛土豆不卖萌:BAAALAAECgYIBwAAAA==.',['啊发']='啊发发:BAAALAADCggICAAAAA==.',['啊呜']='啊呜栾子:BAAALAAFFAQIAgAAAA==.',['啊牛']='啊牛:BAAALAADCggICgAAAA==.',['啪啪']='啪啪君:BAAALAADCgYIBgAAAA==.',['喂丶']='喂丶醒醒:BAAALAAECgMIAwAAAA==.',['喵喵']='喵喵鱼子酱:BAAALAADCgEIAQAAAA==.',['喷喷']='喷喷:BAAALAADCgIIAgAAAA==.',['嗨你']='嗨你真高:BAAALAAECgYIDgABLAAFFAgIOAAPAHgjAA==.',['嘉州']='嘉州诗屿:BAAALAAECgQIBAAAAA==.',['嘉心']='嘉心糖:BAAALAAECgUICgABLAAFFAIIBAAVAAAAAA==.',['嘿休']='嘿休萌牛:BAAALAAECgYIBgAAAA==.',['四川']='四川来的熊猫:BAAALAAECgEIAQAAAA==.',['回留']='回留:BAAALAAECgYIDQAAAA==.',['国宝']='国宝囡囡:BAABLAAFFH8UAAMSAAYIhROsGQCOAQASAAYIhROsGQCOAQARAAEI1wHsUwAoAAAAAA==.',['在下']='在下头铁战:BAAALAAECgYIBgAAAA==.在下迪咳:BAAALAAECggICAAAAA==.',['堕落']='堕落的羽翼:BAAALAADCgMIAwAAAA==.堕落阿骑:BAABLAAFFH8LAAIEAAIIjhuvUACgAAAEAAIIjhuvUACgAAAAAA==.',['复兴']='复兴路战神:BAAALAAECgYICgAAAA==.',['夏之']='夏之曦雨:BAAALAAECgQIBAAAAA==.',['夏忆']='夏忆:BAABLAAFFH8NAAICAAYIHBSnNQBmAQACAAYIHBSnNQBmAQAAAA==.',['夜丶']='夜丶逍遥:BAAALAADCgEIAQAAAA==.',['夜之']='夜之暗面:BAABLAAFFH8MAAIBAAIIyR8+EQC8AAABAAIIyR8+EQC8AAAAAA==.',['夜晚']='夜晚的圣光:BAAALAAECggICAAAAA==.',['夜未']='夜未央:BAACLAAFFH8IAAIOAAMISgzhHgCnAAAOAAMISgzhHgCnAAAsAAQKfxcAAg4ACAhlFXhHAMQBAA4ACAhlFXhHAMQBAAEsAAUUBwguABIAaB0A.',['夜莺']='夜莺:BAABLAAFFH8RAAIJAAMIyxIREAB+AAAJAAMIyxIREAB+AAAAAA==.',['夜逍']='夜逍丶遥:BAAALAAFFAIIAgAAAA==.',['夜雨']='夜雨声烦:BAAALAAECgYIBgAAAA==.夜雨灬灯落下:BAAALAADCgYIBgAAAA==.',['大名']='大名大明:BAAALAAECggIDgAAAA==.',['大地']='大地之环:BAAALAAECgIIAgAAAA==.',['大料']='大料:BAAALAAECgYICgAAAA==.',['大桥']='大桥丶未久:BAACLAAFFH8KAAIPAAIIBhXyRwBLAAAPAAIIBhXyRwBLAAAsAAQKfxgAAxYACAgXF90RALkBABYABgjFFt0RALkBAA8ABggSGbY2AH4BAAAA.',['天下']='天下牧:BAABLAAFFH8QAAIMAAMIrRWmAgDDAAAMAAMIrRWmAgDDAAAAAA==.天下第一长:BAABLAAFFH8IAAICAAUIQhOURgAwAQACAAUIQhOURgAwAQAAAA==.',['天使']='天使会掉毛:BAABLAAFFH8GAAIEAAYIRQoaPwA+AQAEAAYIRQoaPwA+AQABLAAFFAgIHgAEAKscAA==.',['天宸']='天宸:BAABLAAECn8ZAAIPAAYIbiHQOgBJAgAPAAYIbiHQOgBJAgAAAA==.',['天灾']='天灾小蚊香:BAACLAAFFH8LAAIEAAMIdRw3JgABAQAEAAMIdRw3JgABAQAsAAQKfxgAAgQACAjoIRwvALYCAAQACAjoIRwvALYCAAAA.',['天黑']='天黑請闭眼:BAAALAAECggICAAAAA==.',['太空']='太空人:BAAALAAFFAIIAgAAAA==.',['奈伊']='奈伊组忒:BAABLAAFFH8ZAAIOAAUIkg5IIQAUAQAOAAUIkg5IIQAUAQAAAA==.',['奥特']='奥特曼小怪兽:BAAALAAFFAQIBAAAAA==.',['奥雷']='奥雷莉亚:BAAALAAECgYIBgAAAA==.',['好困']='好困呀:BAAALAADCgQIBQAAAA==.',['好狐']='好狐狸:BAABLAAFFH8IAAIOAAgI1hJBDADyAQAOAAgI1hJBDADyAQAAAA==.',['娇婵']='娇婵:BAAALAAECgYIBwAAAA==.',['娇婷']='娇婷:BAAALAAECgEIAQAAAA==.',['娇媚']='娇媚:BAAALAAECgMIAwAAAA==.',['娇宠']='娇宠:BAAALAADCgYIBgAAAA==.',['娇羞']='娇羞:BAAALAAECgYIBgAAAA==.',['娇萌']='娇萌:BAAALAADCgYIBgAAAA==.',['娇颜']='娇颜:BAAALAAECgYICAAAAA==.',['子熏']='子熏:BAAALAAECgYIBgAAAA==.',['子默']='子默:BAAALAAECgcIDgAAAA==.',['孤云']='孤云:BAAALAAECgYICwAAAA==.',['孤影']='孤影单彳亍:BAAALAAECgYIBgAAAA==.',['孤狼']='孤狼斯科特丶:BAAALAAECgQIBAAAAA==.',['宝批']='宝批龙:BAABLAAFFH8FAAIXAAUI/QsAEQAWAQAXAAUI/QsAEQAWAQAAAA==.',['宠物']='宠物饲养员:BAAALAAFFAIIAgAAAA==.',['宫肋']='宫肋咲良:BAABLAAFFH8GAAIEAAIIuhsIRgCrAAAEAAIIuhsIRgCrAAAAAA==.',['宸浮']='宸浮翊生:BAAALAADCgcIBwAAAA==.',['寂寞']='寂寞如風:BAAALAAECgIIAgAAAA==.',['寒蕊']='寒蕊:BAABLAAFFH8FAAILAAMIMgNNNgCKAAALAAMIMgNNNgCKAAAAAA==.',['射后']='射后圣如佛:BAAALAADCgQIBAAAAA==.',['射灬']='射灬射灬射灬:BAACLAAFFH8IAAICAAQIXRcqWwDaAAACAAQIXRcqWwDaAAAsAAQKfygAAgIABwi4IOE+AGoCAAIABwi4IOE+AGoCAAEsAAUUCAgcAAYA4iQA.',['小佳']='小佳开飞机:BAAALAAECgQIBAAAAA==.',['小十']='小十七:BAAALAAECgIIAgAAAA==.',['小太']='小太爷孟烦了:BAAALAAECgYICQAAAA==.',['小子']='小子蛮坏:BAABLAAFFH8QAAICAAYIAx7qJgCWAQACAAYIAx7qJgCWAQAAAA==.',['小小']='小小萨鲁法尔:BAACLAAFFH8FAAMNAAIIoQ70HgBKAAAEAAEIOBRunABKAAANAAEICgn0HgBKAAAsAAQKfyIAAgQABwghIGYpANABAAQABwghIGYpANABAAAA.',['小憋']='小憋憋:BAABLAAFFH8GAAMYAAYIkBO+DACvAAABAAMIxA9aEQDsAAAYAAMIXBe+DACvAAAAAA==.',['小母']='小母牛:BAAALAADCggICAAAAA==.',['小禽']='小禽獸丷:BAACLAAFFH8oAAIPAAUIsxwyIABqAQAPAAUIsxwyIABqAQAsAAQKfxoAAg8ACAgSGqJjAMoBAA8ACAgSGqJjAMoBAAAA.',['小飞']='小飞哥哥:BAAALAAECgQIBgAAAA==.',['尘沙']='尘沙扬:BAAALAAECgYIDAAAAA==.',['尛刘']='尛刘:BAAALAAECgEIAQAAAA==.',['尤丶']='尤丶迪丶安:BAAALAAECgUIBQAAAA==.',['就爱']='就爱喝可乐:BAAALAAECgUIBQAAAA==.',['就要']='就要在一起:BAABLAAFFH8MAAIXAAYI0hCdBQCrAQAXAAYI0hCdBQCrAQAAAA==.',['尹菲']='尹菲:BAAALAAECgMIBgAAAA==.',['尾巴']='尾巴甩甩:BAAALAAECgIIAgAAAA==.',['屍体']='屍体發火:BAAALAADCgEIAQAAAA==.',['山城']='山城雾漫漫:BAAALAADCgIIAgAAAA==.',['左右']='左右丶:BAAALAAFFAIIBAAAAA==.',['巧克']='巧克力果萃:BAAALAAECgEIAQAAAA==.巧克力柠萃:BAAALAAECggICAAAAA==.',['巨大']='巨大无比:BAAALAADCgcIBwAAAA==.',['帝丶']='帝丶:BAAALAAECgYIBgAAAA==.',['带我']='带我飞:BAABLAAFFH8OAAIFAAUI8w4uMAAVAQAFAAUI8w4uMAAVAQAAAA==.',['平日']='平日上去:BAAALAAECgUIBQAAAA==.',['幸福']='幸福飞鹰:BAAALAAFFAIIAgAAAA==.',['幸运']='幸运小鸟:BAAALAADCggICAAAAA==.',['幻世']='幻世沧海:BAABLAAECn8UAAIHAAYI2yHrLwDTAQAHAAYI2yHrLwDTAQAAAA==.',['幻月']='幻月:BAAALAAECgYIBgAAAA==.幻月岚:BAAALAAECgEIAQAAAA==.',['幽光']='幽光:BAAALAAECgYIDgABLAAFFAIIBAAVAAAAAA==.',['幽狱']='幽狱:BAAALAAECgYIDwAAAA==.',['床头']='床头明月光:BAAALAAECgEIAQAAAA==.',['弄大']='弄大你的奶娘:BAAALAAECgQIBwAAAA==.',['引导']='引导之侍者:BAAALAAECgIIAgAAAA==.',['弹幕']='弹幕屏障:BAAALAAECgYICwAAAA==.',['强哥']='强哥带你灰:BAAALAAECgYIBwAAAA==.强哥带你爬:BAAALAAECgYIBgAAAA==.强哥带你跑:BAAALAAECgYIBgAAAA==.',['当里']='当里个当:BAACLAAFFH8KAAICAAMIyRJ2bACJAAACAAMIyRJ2bACJAAAsAAQKfyUAAwIACAhZHFUgADsCAAIACAhTHFUgADsCAAMABAj5DVGIAMAAAAAA.',['影刃']='影刃:BAAALAAECgMIAwAAAA==.',['影卝']='影卝帝:BAAALAADCgIIAgAAAA==.',['得瑟']='得瑟猫:BAAALAAECgYIBgAAAA==.',['復仇']='復仇的衝鋒:BAABLAAFFH8JAAMPAAYIbgUZPACAAAAPAAUIIgIZPACAAAAQAAII7QtUKwBmAAAAAA==.',['微风']='微风吹:BAACLAAFFH8uAAISAAcIaB3dBQBkAgASAAcIaB3dBQBkAgAsAAQKfyAAAhIACAgaJT0EAEQDABIACAgaJT0EAEQDAAAA.',['德之']='德之我幸:BAABLAAFFH8IAAIOAAIIZRMcLwB2AAAOAAIIZRMcLwB2AAAAAA==.',['德能']='德能勤绩廉:BAAALAAECgYIBgAAAA==.',['心之']='心之寻:BAAALAAFFAIIAgAAAA==.',['心灵']='心灵纵火犯:BAACLAAFFH8eAAIKAAYI9xd8IwCIAQAKAAYI9xd8IwCIAQAsAAQKfxQAAxkACAhKGg8NAOsBABkABwgwGg8NAOsBAAoABQg7GfmFAIMBAAAA.',['心神']='心神风息:BAABLAAFFH8GAAMTAAIIXh0ZGACwAAATAAIIXh0ZGACwAAALAAIIRQ+7MACNAAAAAA==.',['念戰']='念戰之觴:BAAALAADCgYIBAAAAA==.',['怀念']='怀念开裆裤:BAAALAADCgIIAgAAAA==.',['怀溪']='怀溪哟:BAABLAAFFH8OAAIaAAgIkRr/AgBRAgAaAAgIkRr/AgBRAgAAAA==.',['怒曰']='怒曰仙人掌:BAAALAAECgYIEgAAAA==.',['怒江']='怒江:BAAALAAECgcICwAAAA==.',['思钱']='思钱想厚:BAAALAADCgYIBwAAAA==.',['恐惧']='恐惧代表一切:BAAALAAECgYIDAAAAA==.',['悲伤']='悲伤奥利奥:BAAALAAFFAIIAgAAAA==.',['惟馀']='惟馀莽莽:BAABLAAECn8aAAIDAAcIZRqtMQD8AQADAAcIZRqtMQD8AQAAAA==.',['想吃']='想吃烤肉:BAAALAAECggIDgAAAA==.',['想念']='想念开裆裤:BAAALAAECgYIBgAAAA==.',['慢慢']='慢慢地:BAAALAAECgYIDgAAAA==.',['戎江']='戎江魔警:BAAALAAECgMIAwAAAA==.',['我不']='我不是瞎纸:BAAALAAECgMIAwAAAA==.',['我尿']='我尿里带点糖:BAAALAAECgcICwAAAA==.',['我接']='我接得嘎笑笑:BAABLAAFFH8MAAMSAAIIbiI7PACyAAASAAIIbiI7PACyAAARAAIInxKDQQBIAAAAAA==.',['我是']='我是谁叶烁叠:BAABLAAFFH8eAAIFAAUIuSF1HACTAQAFAAUIuSF1HACTAQAAAA==.',['我爱']='我爱葵仔:BAABLAAFFH8HAAIQAAYIlxJfCQCsAQAQAAYIlxJfCQCsAQAAAA==.',['戒爱']='戒爱小烦:BAAALAADCgMIAwAAAA==.',['房裹']='房裹窝:BAABLAAFFH8YAAIXAAgIZh+oAQDoAgAXAAgIZh+oAQDoAgAAAA==.',['把酒']='把酒黄昏后丶:BAABLAAFFH8MAAISAAYIKxzFEADfAQASAAYIKxzFEADfAQAAAA==.',['折戟']='折戟丶沉沙:BAAALAAECgIIAgAAAA==.',['抠脚']='抠脚的土肥圆:BAAALAAECgYIBgAAAA==.',['拦个']='拦个女的折磨:BAAALAADCgEIAQAAAA==.',['指尖']='指尖流年:BAAALAADCgYIBgAAAA==.',['指間']='指間得緈諨:BAAALAAECgYIDAAAAA==.',['掐死']='掐死伱的温柔:BAAALAAECgQIBAAAAA==.',['摞黎']='摞黎命三千:BAAALAADCgEIAQAAAA==.',['摸鱼']='摸鱼的阿昆达:BAAALAAFFAIIAQAAAA==.',['放妈']='放妈过来:BAAALAAECgUIBQAAAA==.',['放学']='放学啃西瓜:BAAALAAECgYIBgAAAA==.',['故地']='故地重游:BAAALAADCgQIBAAAAA==.',['敲你']='敲你烂番茄:BAABLAAECn8UAAMPAAYIVRTbgQCDAQAPAAYIVRTbgQCDAQAWAAIIzwr7MQBpAAAAAA==.',['文人']='文人雅士:BAAALAADCgYIBgAAAA==.',['断水']='断水流大師兄:BAACLAAFFH8RAAMRAAMIiRIMGgDlAAARAAMIiRIMGgDlAAASAAIIRhJVQACBAAAsAAQKfywAAxEACAi/HPIeAKwCABEACAi/HPIeAKwCABIABAgCGgKtACYBAAAA.',['施华']='施华洛世骑:BAABLAAFFH8KAAIEAAgIlBdtCwBEAgAEAAgIlBdtCwBEAgAAAA==.',['旁友']='旁友上海宁啊:BAAALAAFFAIIAgAAAA==.',['无尘']='无尘三:BAAALAAECgUIBQAAAA==.',['无尽']='无尽的江:BAACLAAFFH8LAAMbAAMIugxFEgCWAAAbAAMIugxFEgCWAAAcAAIIZgG4IwAkAAAsAAQKfyQAAxsACAh6G5wHAFgCABsACAh6G5wHAFgCABwABQgxBmM9AKwAAAAA.',['无我']='无我无剑:BAABLAAECn8YAAIPAAYIxyGDOwBHAgAPAAYIxyGDOwBHAgAAAA==.',['无敌']='无敌大波浪:BAABLAAFFH8GAAIHAAIIWAfOdQA6AAAHAAIIWAfOdQA6AAAAAA==.',['无聊']='无聊的猫:BAAALAADCgYIBgAAAA==.',['时光']='时光的模样:BAAALAAECgYIBgAAAA==.',['明日']='明日香今日臭:BAAALAAECgQIBAAAAA==.',['星尘']='星尘:BAABLAAFFH8FAAILAAIIpAEaTABLAAALAAIIpAEaTABLAAAAAA==.',['星野']='星野丶瑞羽凉:BAACLAAFFH8KAAIIAAIIPBNVGwCTAAAIAAIIPBNVGwCTAAAsAAQKfyYAAwgACAj7HoYRAIYCAAgACAj7HoYRAIYCAAcAAgjqDphZAX4AAAAA.',['春日']='春日茶:BAAALAAECggIBwAAAA==.',['昼小']='昼小至丶:BAAALAAFFAYIBAAAAA==.昼小贼丶:BAAALAAECgYIBgAAAA==.',['昼至']='昼至丶:BAAALAAFFAgIAgAAAA==.',['晒月']='晒月亮的猪猪:BAAALAAECgYIBgAAAA==.',['晓福']='晓福利:BAAALAAECgYIBgAAAA==.',['晴雨']='晴雨格格:BAAALAADCggICgAAAA==.',['曦仔']='曦仔仔:BAAALAADCgYIBgAAAA==.',['曦宝']='曦宝:BAAALAAFFAYIBAAAAA==.',['更阑']='更阑影:BAAALAAECgUIBAAAAA==.',['曼陀']='曼陀罗修:BAAALAAECgEIAQAAAA==.',['月迷']='月迷津渡:BAAALAAECgYIBgAAAA==.',['月风']='月风魔:BAABLAAFFH8UAAIdAAUIZhCDOQAlAQAdAAUIZhCDOQAlAQAAAA==.',['有一']='有一种酒独醉:BAAALAADCgcICgAAAA==.',['有关']='有关单位:BAAALAAECgcICwAAAA==.',['有理']='有理想的胖子:BAABLAAFFH8PAAILAAYI8xvhDQD0AQALAAYI8xvhDQD0AQAAAA==.',['未竟']='未竟:BAABLAAFFH8NAAICAAMI3hYibgCFAAACAAMI3hYibgCFAAAAAA==.',['杀戮']='杀戮狂魔:BAAALAAFFAIIAgAAAA==.',['杜雷']='杜雷斯氵:BAAALAAECgYIBgAAAA==.',['来战']='来战个痛:BAABLAAFFH8IAAMBAAIIECPIFwCgAAABAAIIqxXIFwCgAAAYAAEIDybYGABnAAAAAA==.',['柒肆']='柒肆带我飞:BAAALAAFFAIIAgABLAAFFAYIGwAEANAgAA==.',['柚木']='柚木缇娜:BAABLAAFFH8eAAIEAAYIyR0aFgCWAQAEAAYIyR0aFgCWAQAAAA==.',['柳碧']='柳碧雪:BAAALAAFFAIIAwAAAA==.',['桃田']='桃田賢斗:BAABLAAFFH8MAAIRAAgIMQK9GADsAAARAAgIMQK9GADsAAAAAA==.',['梦游']='梦游天姥:BAABLAAFFH8FAAICAAMIIwdlewBjAAACAAMIIwdlewBjAAAAAA==.',['梦溪']='梦溪笔谈:BAAALAADCgYIBgAAAA==.',['椎名']='椎名真昼丶:BAAALAAECgYIBgAAAA==.',['榴莲']='榴莲拌饭:BAAALAAFFAIIAgAAAA==.榴莲炒米饭:BAAALAAECgIIAgAAAA==.榴莲炒面:BAAALAADCgEIAQAAAA==.',['橙南']='橙南:BAAALAAFFAIIAgAAAA==.',['欧吉']='欧吉儿:BAAALAAECgYIBwAAAA==.',['止战']='止战之殇:BAABLAAFFH8MAAIPAAIIqRnBJwCqAAAPAAIIqRnBJwCqAAAAAA==.',['武武']='武武:BAAALAAECgYIEAAAAA==.',['歧水']='歧水楼主:BAAALAADCgcIBwAAAA==.',['殛奶']='殛奶德:BAAALAAECgcIDQAAAA==.',['毁灭']='毁灭旋律:BAABLAAFFH8HAAMeAAYI2BASBQALAQAeAAQI3woSBQALAQAZAAMIAhijEgBNAAAAAA==.',['毛毛']='毛毛爱睡觉:BAABLAAFFH8GAAISAAMIHhCuRgCSAAASAAMIHhCuRgCSAAAAAA==.',['毛酒']='毛酒:BAABLAAFFH8GAAIEAAIIwhU7dABMAAAEAAIIwhU7dABMAAAAAA==.',['水墨']='水墨澜庭:BAAALAAECgYIDAAAAA==.',['江湖']='江湖老虾米:BAAALAADCgcIBwAAAA==.',['江苏']='江苏吴彦祖丶:BAABLAAECn8XAAIPAAgIvhgfMwCNAQAPAAgIvhgfMwCNAQAAAA==.',['沈大']='沈大锤:BAAALAAECgEIAQAAAA==.',['沈总']='沈总:BAAALAAECgIIAgAAAA==.',['沈棍']='沈棍兎:BAAALAAFFAIIAgAAAA==.沈棍堍:BAAALAAECgUIBQAAAA==.沈棍菟:BAAALAAFFAIIBAAAAA==.',['沉默']='沉默的幽灵:BAAALAAFFAIIBAAAAA==.沉默的高阳:BAAALAADCgEIAQAAAA==.',['油榨']='油榨街公牛:BAAALAADCggICAAAAA==.',['法如']='法如的龙木艮:BAABLAAFFH8IAAMPAAIIbBVWUABEAAAPAAIIbBVWUABEAAAQAAIIpQBHMgA/AAAAAA==.',['泰兰']='泰兰徳丶語風:BAAALAAECgMIAwAAAA==.',['泰玛']='泰玛:BAABLAAFFH8QAAIfAAUIuwxcBQDOAAAfAAUIuwxcBQDOAAAAAA==.',['洛璃']='洛璃:BAAALAAECgYIBgAAAA==.',['洛神']='洛神一夏天:BAAALAAECgUIBwAAAA==.',['浅浅']='浅浅灬:BAAALAAECgEIAQAAAA==.',['浊酒']='浊酒醉人心:BAAALAAECgEIAQAAAA==.',['深夏']='深夏:BAAALAAECgQIBAAAAA==.',['淳风']='淳风:BAABLAAECn8VAAIHAAYIISORLgDYAQAHAAYIISORLgDYAQAAAA==.',['混世']='混世灬眼眸:BAAALAAFFAIIBAAAAA==.',['清明']='清明微雨:BAABLAAFFH8IAAISAAIIVh65KgCuAAASAAIIVh65KgCuAAAAAA==.',['湮圏']='湮圏:BAAALAAFFAIIAgAAAA==.',['源芯']='源芯:BAAALAAFFAMIAwAAAA==.',['漂浮']='漂浮群岛:BAABLAAFFH8GAAIFAAMIkRD0QQCFAAAFAAMIkRD0QQCFAAAAAA==.',['潮水']='潮水我已归来:BAAALAAECgcICwAAAA==.',['火者']='火者:BAAALAADCgcIBwAAAA==.',['灬丨']='灬丨拜拜:BAAALAAECgEIAQAAAA==.',['灬青']='灬青山灬:BAAALAAECgMIAwAAAA==.',['灰蹄']='灰蹄丶怒风:BAAALAADCgUIBQAAAA==.',['灵尊']='灵尊:BAAALAAECgYIBwAAAA==.',['灵魂']='灵魂:BAAALAAECgcIDQAAAA==.',['炫之']='炫之帝:BAAALAADCgUICgAAAA==.',['炸胡']='炸胡椒:BAAALAAFFAMIAwAAAA==.',['烈火']='烈火兽兽:BAAALAAECgQIBwAAAA==.烈火屠城:BAACLAAFFH8IAAICAAMIzAzjcgB7AAACAAMIzAzjcgB7AAAsAAQKfxoAAgIABgibHcJiAH0BAAIABgibHcJiAH0BAAAA.烈火牛牛:BAAALAAECgYIAQAAAA==.烈火老妖:BAAALAAECgUIBQAAAA==.烈火雄:BAAALAAECgYIBgAAAA==.',['熊型']='熊型小饼干:BAAALAAFFAIIAgAAAA==.',['熟手']='熟手踏风:BAAALAAECgcICwAAAA==.',['燃烧']='燃烧天时:BAAALAAECgYIBwAAAA==.',['爬牆']='爬牆頭等紅杏:BAAALAAFFAIIAgAAAA==.',['爱发']='爱发呆的笨猫:BAAALAAECgYIDAAAAA==.',['爱吸']='爱吸小卤蛋:BAAALAAECgUIBQAAAA==.',['爱蜜']='爱蜜莉雅:BAAALAAECgYIBgAAAA==.',['牛中']='牛中刘德华:BAAALAAFFAIIAgAAAA==.',['牛奶']='牛奶好喝丶:BAABLAAFFH8GAAISAAIIQhBlSwBvAAASAAIIQhBlSwBvAAAAAA==.',['牛毛']='牛毛入:BAAALAAECgYIBgAAAA==.',['牛盾']='牛盾:BAABLAAFFH8FAAIHAAMIEArMTwBYAAAHAAMIEArMTwBYAAAAAA==.',['牛顿']='牛顿:BAAALAAFFAIIBAAAAA==.',['牧灬']='牧灬尛莉:BAAALAAECggICAAAAA==.',['牧牧']='牧牧神依:BAAALAAECgIIAgAAAA==.',['狂风']='狂风啊牛:BAAALAADCgcICAAAAA==.',['独翼']='独翼天使:BAACLAAFFH8KAAMdAAUIRhPOOAApAQAdAAUIzhDOOAApAQAgAAEIoB3eHQAAAAAsAAQKfyYAAyAABwieHZI4AIoBACAABAjZIZI4AIoBAB0ABggkF2g5AGMBAAAA.',['狮蚀']='狮蚀胜于熊便:BAAALAAFFAIIAgAAAA==.',['猎天']='猎天魔:BAACLAAFFH8UAAICAAYIJB+jJQCcAQACAAYIJB+jJQCcAQAsAAQKfxYAAwIACAjlHbIeAEQCAAIACAjlHbIeAEQCACEABQgmBTkaAPcAAAAA.',['猎王']='猎王战:BAAALAAECgYICAAAAA==.',['猎豹']='猎豹小子:BAAALAAECgYIBgAAAA==.',['猫冬']='猫冬菇:BAAALAAFFAIIAgAAAA==.',['玖夜']='玖夜:BAABLAAFFH8HAAIOAAcIPwCsYgAGAAAOAAcIPwCsYgAGAAAAAA==.',['玖玖']='玖玖德德:BAAALAAECgUIBQAAAA==.',['玛丽']='玛丽希亚:BAAALAAECgYIBgAAAA==.',['玲格']='玲格格:BAAALAADCgEIAQAAAA==.',['玲珑']='玲珑:BAAALAAFFAYIBAAAAA==.',['瑟瓦']='瑟瓦娜斯:BAAALAADCgQIBAAAAA==.',['璞瑶']='璞瑶客:BAABLAAFFH8LAAISAAUI5wpUOADBAAASAAUI5wpUOADBAAAAAA==.',['瓦娜']='瓦娜斯:BAAALAAECgIIAgAAAA==.',['甄姬']='甄姬扒菜:BAAALAAECgYIBgAAAA==.',['甩枪']='甩枪术:BAABLAAECn8fAAIDAAcIsR0aIwBSAgADAAcIsR0aIwBSAgAAAA==.',['白不']='白不白:BAABLAAFFH8RAAIUAAMIgwnaDgBUAAAUAAMIgwnaDgBUAAAAAA==.',['白月']='白月魁:BAAALAAFFAIIBAAAAA==.',['白翼']='白翼誓约:BAACLAAFFH8ZAAMBAAUIsRRaDABIAQABAAUIMRJaDABIAQAYAAEIDg7KHQA/AAAsAAQKfy8AAwEACAiLH/0OAK8CAAEACAilHf0OAK8CABgABQg7EgEtADUBAAAA.',['皮卡']='皮卡唛:BAACLAAFFH8jAAMPAAYIuh34FQCtAQAPAAYIuh34FQCtAQAWAAEIKRrHBwBTAAAsAAQKfzUAAw8ACAjuJWQFAGkDAA8ACAjMJWQFAGkDABYAAwjDIKMfABgBAAAA.',['盒子']='盒子猫:BAAALAAECgMIAwAAAA==.',['相公']='相公丶:BAAALAAECgUIBQAAAA==.',['相关']='相关部门:BAAALAADCgMIAwAAAA==.',['看我']='看我疯狂:BAAALAAFFAIIBAAAAA==.',['看海']='看海:BAABLAAFFH8MAAIFAAQIpxOOHwDrAAAFAAQIpxOOHwDrAAAAAA==.',['看谁']='看谁疯狂:BAABLAAFFH8GAAIEAAIINA6KkwA9AAAEAAIINA6KkwA9AAAAAA==.',['真岛']='真岛吾郎:BAAALAADCgYIBgAAAA==.',['眸年']='眸年眸衵:BAAALAAECggICAAAAA==.',['瞄瞄']='瞄瞄咪:BAAALAAECgYICQAAAA==.',['瞎扯']='瞎扯蛋吧:BAAALAAECgUIBwAAAA==.',['瞎指']='瞎指挥:BAAALAAFFAIIAwAAAA==.',['硬是']='硬是巴适耶:BAAALAAECgUIBQAAAA==.',['硬笔']='硬笔的正反面:BAACLAAFFH8HAAIMAAIIPxBkBQBkAAAMAAIIPxBkBQBkAAAsAAQKfxUAAwwABgiZG/4FAN8BAAwABgiZG/4FAN8BABMABAjiDb5LADQAAAAA.',['示岁']='示岁:BAAALAAECgIIAgAAAA==.',['神之']='神之龙翊:BAAALAADCgIIAgAAAA==.',['神尾']='神尾觀鈴:BAABLAAFFH8LAAISAAIIKxbjPQCFAAASAAIIKxbjPQCFAAAAAA==.',['神罗']='神罗天星:BAAALAAFFAIIAgAAAA==.',['神都']='神都为我哭泣:BAABLAAECn8YAAMTAAgIpx2PJABSAgATAAcIoR6PJABSAgALAAcITAn0bQAxAQAAAA==.',['离歌']='离歌丶笑:BAAALAAECgMIAwAAAA==.',['秋天']='秋天的风:BAAALAAECgYIDAAAAA==.',['秋月']='秋月:BAAALAAFFAIIAgAAAA==.',['秦缶']='秦缶:BAAALAAECgYIDAAAAA==.',['稚名']='稚名真白:BAABLAAFFH8IAAMOAAYIeQdSOQCHAAAOAAMI2Q5SOQCHAAAGAAUISAB4QQARAAAAAA==.',['竹径']='竹径通幽处:BAAALAAECgYIBgAAAA==.',['笑尘']='笑尘诀:BAAALAADCgYIBgABLAAECgYIGAAPAMchAA==.',['笑萨']='笑萨满:BAAALAADCgMIAwAAAA==.',['等天']='等天黑:BAAALAAECgEIAQAAAA==.',['等风']='等风來灬:BAAALAAECggICAAAAA==.',['简娜']='简娜的库叉子:BAAALAADCgIIAgAAAA==.',['箭啸']='箭啸:BAAALAADCgIIAgAAAA==.',['米小']='米小红:BAAALAAFFAUIBAAAAA==.',['紅葉']='紅葉舞秋山:BAAALAADCgUIBQAAAA==.',['紅蓮']='紅蓮之翼:BAAALAAECgMIAwABLAAFFAIIBAAVAAAAAA==.',['紫色']='紫色魅影:BAAALAAECggIDQAAAA==.',['紫萱']='紫萱无悔:BAAALAAECgUICQAAAA==.',['紫风']='紫风轻尘:BAAALAAECgYICgAAAA==.',['繁华']='繁华落尽:BAAALAADCgUICQAAAA==.',['红南']='红南京:BAAALAAECgYIBgAAAA==.',['红殷']='红殷桃:BAAALAADCgIIAgAAAA==.',['终究']='终究是错负:BAAALAADCgUIBQAAAA==.',['结冰']='结冰的太阳:BAABLAAFFH8GAAIEAAQIaA4gUgDPAAAEAAQIaA4gUgDPAAAAAA==.',['给我']='给我过来添添:BAAALAAFFAIIBAAAAA==.',['绝地']='绝地重生:BAAALAADCgYIBgAAAA==.',['绝版']='绝版圣斗士:BAAALAAECgYIBgAAAA==.',['罗斯']='罗斯柴尔德:BAAALAAECgUIBQAAAA==.',['美吖']='美吖吖:BAABLAAFFH8ZAAMOAAYIvhmqDQDgAQAOAAYIvhmqDQDgAQAiAAMI1QnfCgB6AAAAAA==.',['老哥']='老哥很稳:BAABLAAFFH8tAAMFAAYIeSPfDQD0AQAFAAYIPiLfDQD0AQAUAAYIQx4AAAAAAAAAAA==.',['老肩']='老肩巨滑:BAAALAADCgEIAQAAAA==.',['聆风']='聆风之音:BAAALAAFFAIIBAAAAA==.',['聖光']='聖光苍穹:BAAALAADCggIHAAAAA==.',['肉包']='肉包不信圣光:BAABLAAFFH8HAAIHAAIISxx3MACrAAAHAAIISxx3MACrAAAAAA==.',['肥仔']='肥仔爱蹦迪:BAAALAAECggIBgAAAA==.',['胖子']='胖子二龙:BAABLAAFFH8XAAMjAAYI0ROrDgAyAQAjAAUI/hWrDgAyAQAXAAYIYwWYEAAgAQAAAA==.',['胡子']='胡子大叔:BAACLAAFFH8IAAMEAAII7R3DOgC8AAAEAAII7R3DOgC8AAANAAIIfQrWFACFAAAsAAQKfxoAAwQACAjlHu86AI8CAAQACAgKHu86AI8CAA0ABgitF7ohAK0BAAAA.',['胸毛']='胸毛入:BAAALAAECgEIAQAAAA==.',['腌制']='腌制五花肉:BAAALAAFFAYIAgAAAA==.',['舌尖']='舌尖上的音符:BAAALAADCgYIBgAAAA==.',['舞力']='舞力拳鐦:BAAALAAFFAIIBAAAAA==.',['艾尼']='艾尼迪丝:BAAALAAECgYIBAAAAA==.',['花木']='花木兰丶:BAACLAAFFH8FAAICAAIIYB15PQCqAAACAAIIYB15PQCqAAAsAAQKfxcAAgIABgjsJLZVADICAAIABgjsJLZVADICAAAA.',['芳砖']='芳砖叔:BAAALAAFFAEIAQAAAA==.',['苍南']='苍南敢死队江:BAABLAAFFH8MAAIIAAIIbBcNGwCUAAAIAAIIbBcNGwCUAAAAAA==.',['苍蝇']='苍蝇坐飞机:BAAALAAFFAIIBAAAAA==.苍蝇爱叮蛋:BAAALAADCgYIBgAAAA==.',['苦海']='苦海洗我胸襟:BAABLAAFFH8IAAIQAAIIuQx4MwAvAAAQAAIIuQx4MwAvAAAAAA==.',['范德']='范德西:BAAALAAFFAIIAgAAAA==.',['茄子']='茄子上带血:BAAALAADCgIIAgAAAA==.',['莉莉']='莉莉灬尛果冻:BAAALAAECggICAAAAA==.',['莫名']='莫名的悲伤:BAAALAAECgYIDAAAAA==.',['莫枫']='莫枫:BAABLAAFFH8GAAIFAAYI2QANcAAWAAAFAAYI2QANcAAWAAAAAA==.',['菟爺']='菟爺:BAAALAADCgEIAQAAAA==.',['萌萌']='萌萌哒母牛:BAAALAAECgEIAQAAAA==.',['萌面']='萌面男纸汉:BAAALAAFFAIIBAAAAA==.',['萨满']='萨满吖:BAACLAAFFH8VAAMSAAYI/A7oIwBAAQASAAYI/A7oIwBAAQARAAIINQIXUwAsAAAsAAQKfyQAAhIABwhkHH1QAPABABIABwhkHH1QAPABAAAA.',['落云']='落云:BAAALAADCgEIAgAAAA==.',['落叶']='落叶叹秋冷:BAABLAAECn8aAAIZAAgIHxQ6EQCxAQAZAAgIHxQ6EQCxAQAAAA==.',['落孤']='落孤敖狱:BAAALAADCgYIBgAAAA==.',['葡萄']='葡萄不淘:BAAALAADCgcIBwAAAA==.',['蒜蓉']='蒜蓉粉丝虾儿:BAAALAAECgMIAwAAAA==.',['蓝烟']='蓝烟灰:BAACLAAFFH8hAAIKAAUIHBZwLwBKAQAKAAUIHBZwLwBKAQAsAAQKfxkAAgoACAi7Iv0EAMcCAAoACAi7Iv0EAMcCAAAA.',['蓝阔']='蓝阔乐:BAAALAAECgEIAQAAAA==.',['薄荷']='薄荷红糖丶:BAACLAAFFH8JAAICAAMIdhGbMgC/AAACAAMIdhGbMgC/AAAsAAQKfxQAAgIABwjKHEpcACMCAAIABwjKHEpcACMCAAAA.',['藏剑']='藏剑流光:BAAALAAECgYIBgAAAA==.',['虚空']='虚空剑姬:BAAALAAECgYICQAAAA==.',['虾不']='虾不来虫:BAAALAAFFAIIBAAAAA==.',['虾仁']='虾仁:BAABLAAFFH8XAAIQAAQI4gvYHACbAAAQAAQI4gvYHACbAAAAAA==.',['蟑螂']='蟑螂勇士:BAAALAAFFAIIAwAAAA==.',['血海']='血海洗我胸襟:BAAALAAECgYICgAAAA==.',['血蹄']='血蹄村盗賊:BAAALAAECgYIDgAAAA==.',['行肉']='行肉走尸:BAAALAADCgcIBwAAAA==.',['襄铃']='襄铃:BAACLAAFFH8OAAMdAAMIiAh0UAB4AAAdAAMIiAh0UAB4AAAkAAEIrgbCCwAAAAAsAAQKfyQABB0ACAj1GgowAI0BAB0ACAjGGgowAI0BACAAAgioCTswAFkAACQAAQhSDgAAAAAAAAAA.',['西湖']='西湖扛把子:BAAALAAECgIIAwAAAA==.',['要爆']='要爆了:BAABLAAFFH8SAAMEAAUIgw38XACVAAAEAAMIZBH8XACVAAAaAAQIHAUlFQBxAAAAAA==.',['誓法']='誓法:BAAALAADCgEIAQAAAA==.',['许七']='许七安:BAAALAADCgEIAQAAAA==.',['许瀛']='许瀛龙:BAAALAAFFAIIAgAAAA==.',['谨年']='谨年:BAAALAAECgcIBwAAAA==.',['豌豆']='豌豆颠颠:BAAALAAECgYIDQAAAA==.',['贵妃']='贵妃醉酒:BAAALAAECgYIBgAAAA==.',['赤城']='赤城:BAAALAAECgEIAQAAAA==.',['赤脚']='赤脚大佬汉:BAACLAAFFH8IAAICAAIIzwP7fABsAAACAAIIzwP7fABsAAAsAAQKfxkAAwIABwiHDwLdAFoBAAIABwinDgLdAFoBAAMABQidCUCIAMAAAAAA.',['赤色']='赤色天灾:BAAALAADCggICAAAAA==.',['赵琛']='赵琛的父亲:BAABLAAFFH8MAAIOAAYI7hY0GABwAQAOAAYI7hY0GABwAQAAAA==.',['超级']='超级牛的牛:BAAALAAECgMIAwAAAA==.超级皮卡丘:BAAALAAECgYIBgAAAA==.',['踏雪']='踏雪龙井:BAAALAADCgMIAwAAAA==.',['躬贱']='躬贱手:BAAALAAFFAgIAQAAAA==.',['躺倒']='躺倒之龙:BAAALAAECgYICAAAAA==.',['软妹']='软妹终结者:BAAALAAECgUIBgAAAA==.',['软软']='软软的你:BAAALAADCgYIBgAAAA==.',['辣眼']='辣眼睛:BAAALAAECgYICwAAAA==.',['辰风']='辰风去:BAABLAAFFH8GAAICAAIICxFoXwCMAAACAAIICxFoXwCMAAAAAA==.',['达叔']='达叔灬:BAABLAAFFH8bAAIdAAYIiB+9GADFAQAdAAYIiB+9GADFAQAAAA==.',['达纳']='达纳托斯:BAAALAAECgYICwAAAA==.',['达魔']='达魔瘋:BAAALAADCgEIAQAAAA==.',['迪亚']='迪亚贝尔斯塔:BAABLAAFFH8KAAIdAAII4SDDLwC8AAAdAAII4SDDLwC8AAAAAA==.',['那个']='那个傻治疗:BAAALAAFFAIIAgAAAA==.',['那些']='那些年灬妖精:BAABLAAFFH8MAAIHAAII1hVDaQBCAAAHAAII1hVDaQBCAAAAAA==.',['那维']='那维莱特灬:BAABLAAFFH8PAAISAAcI1SKJBQDsAQASAAcI1SKJBQDsAQAAAA==.',['酒桶']='酒桶丨老司机:BAAALAAECgIIAwAAAA==.',['醉渔']='醉渔唱晚:BAAALAAECgEIAQAAAA==.',['里罗']='里罗斯特:BAABLAAFFH8HAAIPAAMIZRp9HwDLAAAPAAMIZRp9HwDLAAAAAA==.',['野德']='野德新之助:BAABLAAFFH8WAAIIAAYIcA6jEADbAAAIAAYIcA6jEADbAAAAAA==.',['针音']='针音:BAAALAADCggICAAAAA==.',['钢铁']='钢铁猛猛兽:BAACLAAFFH8LAAIEAAMI6Q+DYwCFAAAEAAMI6Q+DYwCFAAAsAAQKfxQAAgQACAi9HYBTAFACAAQACAi9HYBTAFACAAAA.',['铂金']='铂金荣耀:BAABLAAFFH8KAAMdAAIIow5JRgCQAAAdAAIIow5JRgCQAAAgAAEIjgUfLwBEAAAAAA==.',['闪灵']='闪灵:BAAALAAECgYIDgAAAA==.',['队长']='队长别开腔:BAAALAAECgUICgAAAA==.',['阳光']='阳光彩虹小马:BAAALAAECgQIBAAAAA==.',['阿呆']='阿呆不羁:BAAALAADCgYIBgAAAA==.',['阿尓']='阿尓萨斯:BAABLAAFFH8GAAIHAAQIdwUiFwADAQAHAAQIdwUiFwADAQAAAA==.',['阿尔']='阿尔媞妮斯:BAAALAAECgQIBAAAAA==.阿尔霎斯:BAAALAAECggICAAAAA==.',['阿斯']='阿斯达克斯:BAAALAAECgYIDAAAAA==.',['阿牛']='阿牛的山:BAABLAAFFH8GAAMHAAIIQhKTQwCcAAAHAAIIQhKTQwCcAAAIAAIIrRT6GgCUAAABLAAFFAgIBwAcAPwWAA==.阿牛的海:BAAALAAFFAIIBAAAAA==.',['陆小']='陆小小宝:BAAALAAECgMIAwAAAA==.',['陈红']='陈红鱼:BAAALAAECgYIBgAAAA==.',['陌伤']='陌伤花:BAAALAAECgYIDgAAAA==.',['陌熙']='陌熙残阳:BAAALAAECgEIAQAAAA==.',['降龙']='降龙十八掌:BAAALAAFFAIIAgAAAA==.',['陸七']='陸七七:BAAALAAECgIIAgAAAA==.',['雨雪']='雨雪纷飞:BAABLAAECn89AAIHAAgIiSEfDwCWAgAHAAgIiSEfDwCWAgAAAA==.',['雪后']='雪后初晴丶:BAAALAAECgUIAgAAAA==.',['雪雨']='雪雨纷飞:BAAALAAECgcICAAAAA==.',['零因']='零因:BAAALAAECgEIAQAAAA==.',['雷动']='雷动:BAAALAADCgMIAwAAAA==.',['雷霆']='雷霆苍穹:BAABLAAECn8YAAMRAAgIBx+BHgCvAgARAAgIBx+BHgCvAgASAAMIxgr3HAFyAAAAAA==.',['霜悼']='霜悼者:BAAALAAECgYIBgAAAA==.',['青山']='青山客:BAACLAAFFH8GAAIdAAIIUgPAVABzAAAdAAIIUgPAVABzAAAsAAQKfxUAAh0ABwjJDZqHAG8BAB0ABwjJDZqHAG8BAAAA.',['青椒']='青椒斩蛋:BAAALAAECgYICAAAAA==.青椒炒肉片:BAACLAAFFH8HAAIHAAMI6BfzGAD5AAAHAAMI6BfzGAD5AAAsAAQKfykAAgcACAg6IHAmANcCAAcACAg6IHAmANcCAAAA.',['青河']='青河愁:BAAALAAECgYICwAAAA==.',['青花']='青花:BAAALAAECggIEAAAAA==.',['静悄']='静悄悄嘚开:BAAALAADCgcIBwAAAA==.',['非来']='非来:BAACLAAFFH8ZAAICAAYIzB8IHgC6AQACAAYIzB8IHgC6AQAsAAQKfx0AAgIABwjVIACAAN4BAAIABwjVIACAAN4BAAAA.',['面对']='面对疾风巴:BAAALAAECgUIBQAAAA==.',['風衣']='風衣:BAAALAAECgQIBAAAAA==.',['風铃']='風铃摇曳:BAAALAAECgYIBgAAAA==.',['風雨']='風雨灬江湖:BAAALAAECgYICQAAAA==.',['风吹']='风吹的方向:BAAALAAECgIIAgAAAA==.',['风月']='风月恋:BAAALAAECgIIAgAAAA==.',['风湿']='风湿关节炎:BAAALAADCgEIAQAAAA==.',['飘逸']='飘逸浩浩:BAABLAAFFH8LAAIKAAYIdhA5JAAIAQAKAAYIdhA5JAAIAQAAAA==.',['飘雪']='飘雪桑桑:BAAALAAECgYICgAAAA==.',['饥渴']='饥渴袭胸人:BAABLAAFFH8GAAIRAAYIPRynEwCeAQARAAYIPRynEwCeAQAAAA==.',['马提']='马提尼:BAABLAAFFH8HAAISAAQILRthIwBDAQASAAQILRthIwBDAQAAAA==.',['骑上']='骑上这不归鹿:BAABLAAFFH8MAAICAAYITBTOOQBZAQACAAYITBTOOQBZAQAAAA==.',['骑士']='骑士之誓:BAAALAAFFAIIAgAAAA==.',['骤夜']='骤夜:BAAALAAECgYIBgAAAA==.',['骨头']='骨头是啊固:BAABLAAECn8cAAMCAAcIJhoUmgC0AQACAAYInRsUmgC0AQADAAIIyhXEnQB8AAAAAA==.',['高个']='高个子:BAAALAAECgYIBgAAAA==.',['高登']='高登:BAABLAAECn8cAAIBAAYIKg1oPwBXAQABAAYIKg1oPwBXAQAAAA==.',['鬼王']='鬼王达:BAABLAAFFH8jAAIFAAYI0BcvGgCfAQAFAAYI0BcvGgCfAQAAAA==.鬼王達:BAABLAAFFH8MAAIRAAYIwwqkIwAnAQARAAYIwwqkIwAnAQAAAA==.',['魂灵']='魂灵风息:BAACLAAFFH8SAAISAAUIPxelCgCSAQASAAUIPxelCgCSAQAsAAQKfxgAAhIACAgDHg8hAI8CABIACAgDHg8hAI8CAAAA.',['魔无']='魔无敌:BAABLAAFFH8GAAIHAAIINxCCcgA8AAAHAAIINxCCcgA8AAAAAA==.',['魔界']='魔界小风:BAAALAAECgYICQAAAA==.',['鲁摸']='鲁摸买:BAAALAAECgYIBgAAAA==.',['鲤鱼']='鲤鱼旗:BAAALAADCgYICQAAAA==.',['鹿鼎']='鹿鼎记丨阿珂:BAAALAAECgYICAAAAA==.',['麒麟']='麒麟的痕迹:BAAALAAECgMIAwAAAA==.',['黑曼']='黑曼巴蛇:BAAALAAECgQIBAAAAA==.',['黑濑']='黑濑小夜:BAAALAAFFAIIBAAAAA==.',['黒的']='黒的白的光:BAAALAAECgIIAgAAAA==.',['龍斬']='龍斬:BAAALAAECgYIDAAAAA==.',['龙卷']='龙卷风:BAAALAADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end