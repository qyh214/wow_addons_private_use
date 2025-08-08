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
 local lookup = {'Mage-Arcane','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Priest-Discipline','Hunter-BeastMastery','Paladin-Retribution','DeathKnight-Blood','DeathKnight-Frost','Shaman-Restoration','Mage-Frost','Hunter-Marksmanship','Paladin-Protection','Druid-Balance','Druid-Guardian','DeathKnight-Unholy','Unknown-Unknown','Paladin-Holy','Rogue-Assassination','Druid-Restoration','DemonHunter-Havoc','Priest-Holy','Priest-Shadow','Rogue-Outlaw','Shaman-Enhancement','Warrior-Fury','Warrior-Protection','Warrior-Arms','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Evoker-Preservation','Mage-Fire','Evoker-Devastation',}; local provider = {region='CN',realm='雷霆之怒',name='CN',type='weekly',zone=42,date='2025-08-03',data={As='Asprose:BAAAKgADCggICAAAAA==.',Au='Autisms:BAAAKgAFFAMIAQABKgAFFAgIBgABABsRAA==.',Ba='Babyfive:BAAAKgADCgEIAQAAAA==.',Bl='Blindlove:BAAAKgAECgcIDAAAAA==.',Ca='Candice:BAAAKgAFFAQIBAAAAA==.Cassiel:BAAAKgADCgMIAwAAAA==.',Co='Constantinee:BAAAKgAECggICAAAAA==.',En='Enhancement:BAAAKgAECgcIEgAAAA==.',Ep='Eplayhr:BAAAKgADCggICAAAAA==.Eplayls:BAAAKgADCggICAAAAA==.',Fa='Favorite:BAAAKgAECgUIBQAAAA==.',Fr='Frezix:BAAAKgAFFAQIBAAAAA==.',Fu='Furina:BAAAKgADCgEIAQAAAA==.',Hh='Hh:BAABKgAFFH8IAAQCAAQIvhyEDAD8AAACAAMIvhyEDAD8AAADAAEIAAD8IwAAAAAEAAEIAABbJQAAAAAAAA==.',It='Itriangel:BAAAKgAFFAQIBAAAAA==.',Lo='Lot:BAAAKgADCggICAAAAA==.',Me='Mercurys:BAAAKgADCgQIBAAAAA==.Mercyde:BAABKgAECn8bAAIFAAcIOwlVSADJAAAFAAcIOwlVSADJAAAAAA==.',No='Nofacebook:BAABKgAFFH8FAAIGAAUIqBOJEAAbAQAGAAUIqBOJEAAbAQAAAA==.Nomomo:BAABKgAFFH8OAAIHAAgI1RAECgAGAgAHAAgI1RAECgAGAgAAAA==.',Re='Reaperde:BAACKgAFFH8aAAIIAAgIrwTVBgBCAQAIAAgIrwTVBgBCAQAqAAQKfzEAAwkACAg0Ea4LAJEBAAkABwh4E64LAJEBAAgACAglCDQwANEAAAAA.Reinhardtde:BAAAKgAECggICAAAAA==.',Si='Sinkai:BAAAKgADCggIFAAAAA==.',Uh='Uhoh:BAAAKgADCggICAAAAA==.',Va='Vayne:BAAAKgADCgMIAwAAAA==.',Ve='Vermilion:BAAAKgADCgEIAQAAAA==.',['一叶']='一叶随风丶:BAAAKgAECgQIBAAAAA==.',['一念']='一念成魔丨:BAABKgAFFH8MAAIGAAgIuw73CADmAQAGAAgIuw73CADmAQAAAA==.',['三体']='三体星人:BAABKgAFFH8QAAIKAAMIHh4bHwD/AAAKAAMIHh4bHwD/AAAAAA==.',['三分']='三分绅士:BAAAKgADCgEIAQAAAA==.',['上帝']='上帝的幻影:BAACKgAFFH8LAAMBAAMIXRFmKADBAAABAAMIXRFmKADBAAALAAIIvgtgGAB0AAAqAAQKfzMAAwEACAgEIE8UAFICAAEACAijHk8UAFICAAsACAj6HW0dABwCAAAA.',['不再']='不再有风:BAAAKgADCgQIBAAAAA==.',['与子']='与子彤鉴:BAACKgAFFH8PAAIMAAMIXyaZFQA3AQAMAAMIXyaZFQA3AQAqAAQKf2IAAwwACAijJswAABcDAAwACAijJswAABcDAAYABAiYI3SVAP8AAAEqAAUUBAgHAAcAkhwA.',['两三']='两三星火:BAAAKgAFFAYIAwAAAA==.',['中年']='中年油腻男:BAAAKgAECgIIAgAAAA==.',['为爱']='为爱变坏了:BAAAKgADCggIFwAAAA==.',['乄禦']='乄禦魂灬也許:BAAAKgAECgIIAgAAAA==.',['乌巭']='乌巭星魔:BAACKgAFFH8GAAINAAYIDBIdDQAnAQANAAYIDBIdDQAnAQAqAAQKfxYAAwcACAggIpwpAHcCAAcACAggIpwpAHcCAA0AAQiECuxYACMAAAEqAAUUCAgoAAcAjxkA.',['乐融']='乐融融的梦:BAABKgAFFH8GAAIMAAYICR9qDQCDAQAMAAYICR9qDQCDAQAAAA==.',['九十']='九十岁守奥格:BAABKgAFFH8IAAIHAAQIDRQ/JADWAAAHAAQIDRQ/JADWAAAAAA==.',['乳酪']='乳酪戯芢:BAACKgAFFH8SAAIIAAQIXwLgLgBUAAAIAAQIXwLgLgBUAAAqAAQKfywAAwgACAjJDUkoAAgBAAgACAhPDUkoAAgBAAkAAgiLCWoxAEQAAAAA.',['二到']='二到家:BAAAKgAECgQIBwAAAA==.',['二十']='二十个萨满:BAAAKgAFFAQIBAAAAA==.',['云聿']='云聿岁暮:BAAAKgAECgIIAgAAAA==.',['亦如']='亦如是:BAAAKgAECggIEgAAAA==.',['人骨']='人骨收集者:BAAAKgAFFAcIBAAAAA==.',['什么']='什么皮肤为:BAAAKgAECgEIAQAAAA==.',['从小']='从小呆到大:BAAAKgADCggIEAAAAA==.',['仔宅']='仔宅在寨:BAAAKgAECgEIAQAAAA==.',['你就']='你就是个丢巴:BAAAKgAECgQIBQAAAA==.你就是只咕咕:BAAAKgADCgcIBwAAAA==.你就是只爬爬:BAAAKgAFFAIIAgAAAA==.',['倩影']='倩影寻騌:BAAAKgAECgQIBAAAAA==.',['假装']='假装很爱你:BAAAKgADCggICAAAAA==.',['傲天']='傲天:BAAAKgAFFAgIBAAAAA==.',['兜里']='兜里有熊:BAACKgAFFH8cAAIOAAQI8yCGIAAcAQAOAAQI8yCGIAAcAQAqAAQKfycAAw4ACAjtH9soAB4CAA4ACAjtH9soAB4CAA8AAQjrDZoaACsAAAAA.',['八手']='八手死骑:BAABKgAFFH8GAAIQAAYIFQw/GABbAQAQAAYIFQw/GABbAQAAAA==.',['兮烂']='兮烂:BAACKgAFFH8KAAMLAAMIHhzsDgDrAAALAAMIzxrsDgDrAAABAAEIqBhKJgBIAAAqAAQKfyMAAgsACAjEGcgbANQBAAsACAjEGcgbANQBAAAA.',['再睡']='再睡亿分钟:BAABKgAECn8eAAIHAAgIXw3GiQCDAQAHAAgIXw3GiQCDAQAAAA==.',['冰河']='冰河葬寒心:BAAAKgAFFAgIBAAAAA==.',['冰落']='冰落无心:BAAAKgAFFAIIAQAAAA==.',['凄凉']='凄凉的婚礼:BAABKgAFFH8MAAMIAAgI2BpTBAAQAgAIAAgI2BpTBAAQAgAQAAIItwgOHgCtAAAAAA==.',['凤梨']='凤梨酥:BAAAKgADCggICAAAAA==.',['别怕']='别怕躲我身后:BAAAKgAECgMIAwAAAA==.',['别用']='别用鼠标点我:BAABKgAFFH8KAAMCAAYI/BHIFQDNAAACAAUIWBLIFQDNAAAEAAMIhgsNGgCAAAAAAA==.',['劉陸']='劉陸陸卿:BAAAKgAECggIDAAAAA==.',['勤勤']='勤勤佳人:BAAAKgAECgIIBAAAAA==.',['化劲']='化劲马保国:BAACKgAFFH8ZAAQEAAQIqx+kFgCTAAACAAMI0RsXFQDdAAAEAAMIPxukFgCTAAADAAEIAABfJAAAAAAqAAQKf08ABAQACAjlIxsMACkCAAQABwhAIxsMACkCAAIABQhzIk0XAOwBAAMAAQgnGTQ/AEkAAAAA.',['千梦']='千梦:BAABKgAFFH8FAAIHAAUIERaXEACVAQAHAAUIERaXEACVAQABKgAFFAgIBAARAAAAAA==.',['千灵']='千灵灵:BAAAKgAFFAQIBAAAAA==.',['千芊']='千芊:BAAAKgADCggICgAAAA==.',['卓学']='卓学者周游:BAAAKgADCggICAAAAA==.',['卡壐']='卡壐鄔釲:BAAAKgAECgYIDwAAAA==.',['卷子']='卷子大王:BAABKgAFFH8GAAIKAAYIRBV0DQB2AQAKAAYIRBV0DQB2AQAAAA==.',['卿卿']='卿卿小蝶:BAAAKgAECgUIBQAAAA==.',['叆博']='叆博剌祀:BAAAKgAECgYIBwAAAA==.',['双角']='双角红茶:BAAAKgAECggICAAAAA==.',['叫姐']='叫姐:BAAAKgADCgIIAgAAAA==.',['叮丨']='叮丨铃铃:BAAAKgADCgYIBgAAAA==.',['君山']='君山:BAAAKgADCgIIBAAAAA==.',['呆呆']='呆呆的熊:BAAAKgADCgIIAgAAAA==.',['呆小']='呆小呆:BAAAKgAECgIIAgAAAA==.呆小布:BAAAKgADCgEIAgAAAA==.',['咕咕']='咕咕嘎嘎:BAAAKgAECgUICQAAAA==.',['喷泉']='喷泉牛杂:BAAAKgAECgIIAgAAAA==.',['嗑药']='嗑药丶:BAAAKgAECgQIBAAAAA==.',['嗬韵']='嗬韵味:BAAAKgADCgQIBAAAAA==.',['圣牛']='圣牛斗士:BAAAKgAECgcIBwAAAA==.',['坦途']='坦途灬:BAAAKgADCggICAAAAA==.',['塞勒']='塞勒涅:BAABKgAFFH8JAAMNAAYIahYBDAA3AQANAAYIahYBDAA3AQAHAAMIIAusZwCeAAAAAA==.',['墙面']='墙面上的黑白:BAAAKgADCgQIBgAAAA==.',['壹丄']='壹丄生:BAAAKgAECgIIAgAAAA==.',['复仇']='复仇者联盟:BAAAKgADCgIIAwAAAA==.',['夜阑']='夜阑兮:BAAAKgAFFAgIAgAAAA==.',['夢蝶']='夢蝶:BAACKgAFFH8aAAISAAQIyxCQEAC+AAASAAQIyxCQEAC+AAAqAAQKfzAAAhIACAiaHpsIAGECABIACAiaHpsIAGECAAAA.',['大人']='大人小样:BAAAKgAFFAEIAQAAAA==.',['大器']='大器晚橙:BAAAKgADCgEIAQAAAA==.',['大胖']='大胖子石头:BAAAKgAFFAEIAQAAAA==.',['大胡']='大胡子:BAAAKgADCgYIBgAAAA==.',['大蝇']='大蝇子:BAAAKgAECggIAQAAAA==.',['天界']='天界自由:BAABKgAFFH8GAAINAAYITAW5FwC6AAANAAYITAW5FwC6AAAAAA==.',['天降']='天降胖贼:BAABKgAFFH8HAAITAAUI7B5JAwCAAQATAAUI7B5JAwCAAQABKgAFFAgIBQATAEkOAA==.',['太极']='太极马保国:BAAAKgADCggICAAAAA==.',['孙越']='孙越:BAAAKgAECggIEQAAAA==.',['宇宙']='宇宙公主:BAAAKgAFFAQIBAAAAA==.',['寒歌']='寒歌傲雪:BAAAKgAECgQIBAAAAA==.',['将近']='将近酒:BAAAKgAECgMIAQAAAA==.',['小尾']='小尾巴丶球球:BAAAKgAECgUIBQAAAA==.',['小心']='小心追云鬼:BAABKgAFFH8MAAIHAAMIUw9zKgC8AAAHAAMIUw9zKgC8AAAAAA==.',['小手']='小手遮天:BAABKgAECn8YAAIHAAgIww6RfACeAQAHAAgIww6RfACeAQAAAA==.',['小爆']='小爆能:BAAAKgAECgQIBAAAAA==.',['小猪']='小猪腰子丶:BAAAKgAFFAEIAQAAAA==.',['小胖']='小胖熊:BAABKgAFFH8OAAMGAAYIgRrJFQBIAQAGAAYIPxXJFQBIAQAMAAQIkSAfDgAXAQAAAA==.小胖牛:BAABKgAFFH8MAAMOAAQITw9GHADIAAAOAAQITw9GHADIAAAUAAQI8w+4IQChAAABKgAFFAgIBAARAAAAAA==.',['小胡']='小胡子哥:BAAAKgAECgcIDwAAAA==.',['小雨']='小雨夹雪:BAAAKgADCggICAAAAA==.',['小顽']='小顽皮:BAABKgAFFH8GAAIHAAYImh9eGQCTAQAHAAYImh9eGQCTAQABKgAFFAgICgAHAK0lAA==.',['尐了']='尐了辣了椒:BAABKgAECn8pAAISAAgI1yEbCQBaAgASAAgI1yEbCQBaAgABKgAFFAgIEgANAOocAA==.',['少年']='少年不再年少:BAAAKgAECgIIAgAAAA==.',['巧克']='巧克力甜甜圈:BAAAKgAFFAQIBAAAAA==.',['弑壆']='弑壆霊韵:BAAAKgAECgYICgAAAA==.',['弥弥']='弥弥:BAAAKgADCggIEAAAAA==.',['很强']='很强力:BAAAKgAECgYIDAAAAA==.',['很御']='很御姐:BAABKgAFFH8FAAIEAAMIdQglFgCWAAAEAAMIdQglFgCWAAAAAA==.',['很犀']='很犀利:BAABKgAFFH8NAAMGAAQIxBe9FwDxAAAGAAMINRe9FwDxAAAMAAQIZw1mNgCbAAAAAA==.',['很生']='很生性:BAAAKgAECgEIAgAAAA==.',['很萝']='很萝莉:BAAAKgAECgYICgAAAA==.',['御风']='御风踏雪:BAAAKgAECggICAAAAA==.',['微風']='微風吹過大地:BAAAKgAECgIIBQAAAA==.',['德味']='德味美术生:BAAAKgADCgEIAQAAAA==.',['德菜']='德菜兼备:BAAAKgAECgEIAQAAAA==.',['心之']='心之海洋:BAAAKgAECgcICQAAAA==.',['恩宠']='恩宠丶:BAAAKgAFFAgIBAAAAA==.',['恶魔']='恶魔猎刃:BAABKgAFFH8MAAIVAAQIlA7THQDLAAAVAAQIlA7THQDLAAAAAA==.',['愤怒']='愤怒的影魔:BAABKgAFFH8MAAMIAAQImRpPDQDVAAAQAAQIOBg1FQDjAAAIAAQISBdPDQDVAAAAAA==.愤怒的鲨鱼:BAAAKgAFFAIIAgAAAA==.',['憨憨']='憨憨是只猫:BAACKgAFFH8iAAQFAAgIyyCxAgCKAQAWAAcIBx2ABgDIAQAFAAUIMR+xAgCKAQAXAAEIZgqlLABCAAAqAAQKfxwAAgUACAiGJesBAPQCAAUACAiGJesBAPQCAAAA.',['我先']='我先跑你抗住:BAAAKgAFFAYIAgAAAA==.',['我来']='我来抱抱你:BAAAKgAECggICAAAAA==.',['我爱']='我爱倩倩:BAABKgAECn8YAAILAAgIBAtcTQAvAQALAAgIBAtcTQAvAQAAAA==.',['战尸']='战尸妹纸:BAAAKgAECgEIAQAAAA==.',['战神']='战神龙舞:BAAAKgAECgEIAQAAAA==.',['抓只']='抓只大老虎:BAAAKgAFFAYIBAABKgAFFAgIHAABAPgfAA==.',['拴柱']='拴柱:BAABKgAFFH8GAAIKAAYIZQxZFAA0AQAKAAYIZQxZFAA0AQAAAA==.',['据説']='据説真的有神:BAABKgAFFH8KAAIVAAYIOxjcEQBvAQAVAAYIOxjcEQBvAQAAAA==.',['救赎']='救赎者的伪善:BAAAKgADCgQIBQAAAA==.',['斗战']='斗战胜丶:BAAAKgAECgQIBAAAAA==.',['无尽']='无尽夏:BAAAKgAFFAQIBAAAAA==.',['无常']='无常:BAAAKgAECgYIBgAAAA==.',['无忧']='无忧德:BAAAKgADCgUIBQAAAA==.',['时代']='时代:BAAAKgAECgQIAQAAAA==.',['晴雨']='晴雨丶:BAAAKgAFFAgIBAAAAA==.',['曹丶']='曹丶孟德:BAAAKgAECgQIBAAAAA==.',['最后']='最后曙光:BAAAKgAECggIEAAAAA==.',['有德']='有德丨比有湿:BAABKgAFFH8OAAMOAAgIXSAhBgBRAgAOAAcIpSAhBgBRAgAUAAEIkhiQMgBNAAAAAA==.',['朢夢']='朢夢鑽實:BAAAKgAECgQICwAAAA==.',['末日']='末日夕阳:BAAAKgAECgUIBQAAAA==.',['李子']='李子木:BAAAKgAECgEIAQAAAA==.',['林夕']='林夕:BAAAKgAECgYICQAAAA==.',['枫晓']='枫晓絮:BAAAKgAFFAQIBAAAAA==.',['柔情']='柔情如此似火:BAABKgAFFH8HAAIVAAQI+hfREwDxAAAVAAQI+hfREwDxAAAAAA==.柔情灬似火:BAABKgAFFH8GAAIMAAYIiiHHDQB/AQAMAAYIiiHHDQB/AQAAAA==.',['校服']='校服到婚纱:BAABKgAFFH8HAAIHAAQIkhw3KwC4AAAHAAQIkhw3KwC4AAAAAA==.',['桜崎']='桜崎雉禹:BAAAKgAECgcIBwAAAA==.',['梦魇']='梦魇祝福:BAAAKgADCgMIAwAAAA==.',['橙时']='橙时:BAABKgAFFH8GAAICAAYIUxHWFwBFAQACAAYIUxHWFwBFAQAAAA==.',['橙花']='橙花:BAABKgAFFH8LAAIQAAYIGw/QGwA/AQAQAAYIGw/QGwA/AQAAAA==.',['歌谣']='歌谣丶:BAAAKgAFFAIIAgAAAA==.',['正义']='正义芝士:BAABKgAFFH8LAAIYAAUIzRkQAgBhAQAYAAUIzRkQAgBhAQABKgAFFAgIIAAZAMAcAA==.',['残风']='残风墨月:BAACKgAFFH8aAAMUAAQIDiV9DgAtAQAUAAMIDiV9DgAtAQAOAAQIPxsmMwDLAAAqAAQKf2EAAxQACAh4JIUEALwCABQACAh4JIUEALwCAA4ACAiSHDEMAC8CAAAA.',['比心']='比心飞扬:BAAAKgAECgQIBAAAAA==.',['毛毛']='毛毛大网红:BAAAKgAFFAEIAQAAAA==.',['水沐']='水沐辰星:BAAAKgAECgMIAwAAAA==.',['氷丶']='氷丶:BAAAKgADCgQIBAAAAA==.',['永夜']='永夜惡夢:BAAAKgAECggICAAAAA==.',['汐语']='汐语:BAAAKgAFFAQIAgAAAA==.',['沙思']='沙思牛:BAAAKgAECgMIAwAAAA==.',['河北']='河北彩伽:BAAAKgAECgMIAwAAAA==.',['河马']='河马细细:BAAAKgAECggICAAAAA==.',['油腻']='油腻浪人:BAAAKgAECgUIBQAAAA==.',['法比']='法比奥木木:BAAAKgAECgQIBAAAAA==.',['注意']='注意本大人:BAAAKgAFFAQIBAAAAA==.',['泪繖']='泪繖星辰:BAACKgAFFH8JAAIaAAYI8RKlDQB3AQAaAAYI8RKlDQB3AQAqAAQKfxUABBsACAgXFh0bAF4BABsACAgMER0bAF4BABwABghQEAgyAC4BABoABQjkFfloALIAAAAA.',['洛丹']='洛丹伦的挽歌:BAAAKgADCgcICgAAAA==.',['洛杉']='洛杉矶:BAAAKgAECgEIAQAAAA==.',['海辛']='海辛丶歘:BAAAKgAECgQIBwAAAA==.',['清风']='清风不解风情:BAACKgAFFH8OAAIHAAMIrBu2QwDnAAAHAAMIrBu2QwDnAAAqAAQKfyUAAgcACAgvImYbAJYCAAcACAgvImYbAJYCAAAA.清风浮尘:BAAAKgADCgMIAwAAAA==.清风的风:BAAAKgADCgUIBQAAAA==.',['温柔']='温柔点:BAAAKgAECggICAAAAA==.',['溟陌']='溟陌之咖:BAAAKgADCggICAAAAA==.',['潇洒']='潇洒哥:BAAAKgAECgEIAQAAAA==.',['潶社']='潶社会:BAABKgAECn8WAAIQAAgIPBTVRgCZAQAQAAgIPBTVRgCZAQAAAA==.',['灋麟']='灋麟袶烖:BAAAKgAECgUIBwAAAA==.',['灬傲']='灬傲丨丗灬:BAABKgAFFH8GAAMIAAYIrQx4JgB9AAAQAAQIlgoiPgClAAAIAAII0Q94JgB9AAAAAA==.灬傲丶世灬:BAABKgAFFH8IAAIHAAYIsB8vFgCqAQAHAAYIsB8vFgCqAQAAAA==.灬傲丶丗灬:BAAAKgAECggICAAAAA==.',['灬囧']='灬囧灬:BAABKgAECn8cAAMHAAgInBokPwAGAgAHAAgInBokPwAGAgANAAEIFAYpJQAdAAAAAA==.',['灬星']='灬星丶辰灬:BAAAKgADCgEIAQAAAA==.',['灬烈']='灬烈焰涂鸦灬:BAAAKgAECgMIAwAAAA==.',['灬舞']='灬舞狼灬:BAAAKgADCgEIAQAAAA==.',['灭神']='灭神天尊:BAAAKgADCgEIAQAAAA==.',['灵狐']='灵狐:BAAAKgAECgQIBAAAAA==.',['焕卿']='焕卿之巅:BAAAKgAECgUIBQAAAA==.',['無雙']='無雙曲奇:BAAAKgAECgUIBQAAAA==.',['爱是']='爱是一道圣光:BAAAKgAECgcIBwAAAA==.',['牛逼']='牛逼:BAAAKgAECgQIBAAAAA==.',['玉缇']='玉缇丶:BAAAKgAECgIIAgAAAA==.',['环佩']='环佩:BAAAKgAECgcIBwAAAA==.',['琼斯']='琼斯教授:BAAAKgAECgMIAwAAAA==.',['白酒']='白酒醉蟹:BAAAKgAECgUIBAAAAA==.',['白麟']='白麟祥雲:BAAAKgAECgUICgAAAA==.',['真的']='真的好想要:BAAAKgAECggICAAAAA==.',['矮子']='矮子石头人:BAAAKgAFFAIIAgAAAA==.',['石头']='石头僧:BAAAKgAECgQIBAAAAA==.',['砍不']='砍不死的怪:BAABKgAECn8bAAIQAAgILhmSCQD3AQAQAAgILhmSCQD3AQAAAA==.',['破灭']='破灭华尔兹:BAABKgAFFH8IAAIIAAgIUw3bBACYAQAIAAgIUw3bBACYAQAAAA==.',['神尾']='神尾观玲:BAAAKgADCgYIBgAAAA==.',['神逻']='神逻天征:BAAAKgAECgcIBwABKgAFFAQIBwAHAJIcAA==.',['离人']='离人不挽丶:BAACKgAFFH8SAAMWAAYITSPDCQCHAQAWAAUIdCLDCQCHAQAXAAUI8xeNDQAoAQAqAAQKfxkAAxYACAhcGQclAKMBABYACAhcGQclAKMBAAUABQjaBON3AGUAAAEqAAUUCAgRAAUAMxwA.',['程橙']='程橙橙丶:BAABKgAFFH8IAAILAAQIeh5TAwAfAQALAAQIeh5TAwAfAQAAAA==.',['笨与']='笨与傻的故事:BAAAKgADCggICAAAAA==.',['粉粉']='粉粉的小白脸:BAAAKgAECgYIDQAAAA==.',['糖三']='糖三角:BAABKgAFFH8GAAIKAAYICQ1EFAA1AQAKAAYICQ1EFAA1AQAAAA==.',['糖门']='糖门首席:BAAAKgADCgIIAgAAAA==.',['紫色']='紫色嬷嬷茶:BAAAKgADCgYIBgAAAA==.',['給生']='給生活哼个曲:BAAAKgAECgIIAwAAAA==.給生活比个菟:BAAAKgAECgYICAAAAA==.',['絶伦']='絶伦逸羣:BAABKgAFFH8JAAIdAAQIdwK3CABiAAAdAAQIdwK3CABiAAAAAA==.',['红烧']='红烧丸子:BAABKgAECn8YAAMeAAgI0x4pDgB4AgAeAAgI0x4pDgB4AgAfAAMIDhkTWwDPAAAAAA==.',['纣虎']='纣虎:BAAAKgADCgMIAwAAAA==.',['绝活']='绝活哥:BAABKgAFFH8IAAIfAAgIjAUACgCLAQAfAAgIjAUACgCLAQAAAA==.',['绯红']='绯红艾露莎:BAAAKgAECgUIBQABKgAFFAgIDwAHAMkcAA==.',['翻咔']='翻咔:BAAAKgAFFAQIBAAAAA==.',['耐法']='耐法兰圣辉:BAACKgAFFH8YAAMWAAQIMBuzIQC/AAAWAAQIMBuzIQC/AAAFAAIInQkrHwCAAAAqAAQKf0gABBYACAiEIqcOAF4CABYACAiEIqcOAF4CABcABAiPDmJIAM8AAAUABQgDFUxRAKgAAAAA.耐法兰拂尘:BAAAKgAECgQIBQAAAA==.耐法兰星陨:BAABKgAECn8fAAIKAAgI+hutJgDmAQAKAAgI+hutJgDmAQAAAA==.耐法兰梦呓:BAAAKgAECgcIEAAAAA==.耐法兰葳蕤:BAAAKgAECgQIBQAAAA==.',['肉冻']='肉冻大魔王:BAACKgAFFH8KAAIIAAMIdwnwJgB7AAAIAAMIdwnwJgB7AAAqAAQKfzoAAwgACAi+F2EaAMIBAAgACAi+F2EaAMIBABAABAh8BcmLAIEAAAAA.',['舒言']='舒言:BAAAKgAFFAQIBAAAAA==.',['芜菁']='芜菁沙袋:BAAAKgAFFAcIBAAAAA==.',['花落']='花落:BAACKgAFFH8ZAAQDAAQIXRyrEACeAAADAAIIrherEACeAAACAAIIrRuvIACOAAAEAAIIXxzFJgBLAAAqAAQKfxUABAQACAghGzkxACIBAAQABgjWETkxACIBAAIABwgLG0FVABQBAAMAAQjcHHo+AEwAAAAA.',['茯苓']='茯苓:BAAAKgAECgIIAwAAAA==.',['荧光']='荧光熊:BAABKgAFFH8JAAIOAAQICyGpFQDlAAAOAAQICyGpFQDlAAAAAA==.',['莫得']='莫得感情:BAACKgAFFH8FAAIHAAIIoAkyQwB/AAAHAAIIoAkyQwB/AAAqAAQKfxwAAgcACAi8F0tvALoBAAcACAi8F0tvALoBAAAA.',['莳翎']='莳翎之翼:BAAAKgAECgQIBAAAAA==.',['莺歌']='莺歌儿:BAAAKgAECgcIBwAAAA==.',['萨哈']='萨哈哈:BAAAKgAECgMIAwAAAA==.',['落日']='落日夕阳:BAAAKgADCgUIBQAAAA==.',['董棒']='董棒棒:BAAAKgAFFAcIBAAAAA==.',['葬湮']='葬湮忁影:BAABKgAECn8XAAIgAAgIbgJwDQBlAAAgAAgIbgJwDQBlAAAAAA==.',['蕾姆']='蕾姆:BAAAKgAECgYIBgAAAA==.',['蘿莉']='蘿莉小鑫:BAAAKgAECgMIAwAAAA==.',['訷話']='訷話丶凹凸曼:BAAAKgAFFAIIAgABKgAFFAgIEgAIALUfAA==.訷話丶德小德:BAABKgAFFH8IAAIUAAgIyRxUAgAsAgAUAAgIyRxUAgAsAgAAAA==.訷話丶龙小龙:BAAAKgADCgIIAgAAAA==.',['诀别']='诀别:BAAAKgAECgYIAwAAAA==.',['谜兔']='谜兔丶:BAAAKgADCgQIBAAAAA==.',['谜情']='谜情丶:BAAAKgAECgcIEQAAAA==.',['谜璐']='谜璐丶:BAAAKgAECgQIBQAAAA==.',['谜笙']='谜笙丶:BAAAKgADCgEIAQAAAA==.',['谜阿']='谜阿丶:BAABKgAECn8hAAMMAAgIixdOPABjAQAMAAgIixdOPABjAQAGAAEIGgVx0QAkAAAAAA==.',['谜鸳']='谜鸳丶:BAAAKgAECgYIBgAAAA==.',['豢心']='豢心:BAAAKgADCgIIAgAAAA==.',['豬姯']='豬姯寶氣:BAAAKgAFFAEIAQAAAA==.',['貔貎']='貔貎刄峫:BAAAKgAECgUICAAAAA==.',['贰丄']='贰丄蛋:BAAAKgADCggIEAAAAA==.',['赫利']='赫利俄斯:BAABKgAFFH8KAAMaAAQIEh0YLQCMAAAaAAMIThMYLQCMAAAcAAIIJyJMIgCBAAAAAA==.',['赫尔']='赫尔利:BAAAKgAFFAQIBAAAAA==.',['达尔']='达尔文:BAABKgAFFH8HAAICAAcIBxyPBgAEAgACAAcIBxyPBgAEAgAAAA==.',['返老']='返老还童丶:BAAAKgAECgIIAgAAAA==.',['逐鹿']='逐鹿在西元前:BAAAKgAECgMIBAAAAA==.',['酥糖']='酥糖伊伊:BAAAKgAECggICQAAAA==.酥糖小蝶:BAABKgAECn8WAAMSAAgIKwyEJQA1AQASAAgIKwyEJQA1AQAHAAEIAACMWAEAAAAAAA==.酥糖红鸾:BAAAKgAECgcIEwAAAA==.酥糖蝶姬:BAAAKgAECggIDgAAAA==.',['醒着']='醒着梦游:BAAAKgAECgEIAQAAAA==.',['鈊訫']='鈊訫緗茚:BAAAKgAECggICAAAAA==.',['钟止']='钟止意难平:BAAAKgAECgQIBwAAAA==.',['钱兔']='钱兔无量丶:BAABKgAFFH8OAAIVAAYI5iCVBwBBAQAVAAYI5iCVBwBBAQAAAA==.',['锤子']='锤子飞一会:BAAAKgAECggICAAAAA==.',['閃丶']='閃丶電:BAAAKgAFFAEIAQAAAA==.',['閃玲']='閃玲:BAAAKgAECgQIBAAAAA==.',['闪电']='闪电咆哮:BAABKgAFFH8IAAIaAAgIjA7rBQAtAgAaAAgIjA7rBQAtAgAAAA==.',['阿克']='阿克蒙惪:BAACKgAFFH8gAAQLAAQI9SUgCABAAQALAAMI9SUgCABAAQABAAQI7CSjAgDNAAAhAAIIMhHRLwBAAAAqAAQKf4sABAsACAjVJnABABEDAAsACAjQJnABABEDAAEACAhPJqcFAN8CACEACAhvIJ8YAHgBAAAA.',['阿尔']='阿尔忒弥斯:BAAAKgAFFAMIAwAAAA==.',['阿迷']='阿迷:BAACKgAFFH8gAAIZAAgIwBwtBABMAQAZAAgIwBwtBABMAQAqAAQKfyQAAhkACAjkJKoDAMsCABkACAjkJKoDAMsCAAAA.',['雪舞']='雪舞曦顢:BAAAKgAECgMIAwAAAA==.',['零的']='零的開端:BAAAKgAFFAIIAgAAAA==.',['雷霆']='雷霆已:BAAAKgADCgEIBAAAAA==.',['露娜']='露娜:BAABKgAFFH8KAAIXAAUIVRvbDwAJAQAXAAUIVRvbDwAJAQAAAA==.',['霸王']='霸王灬霸王:BAAAKgAECgEIAQAAAA==.',['颅献']='颅献颅座:BAABKgAFFH8GAAIIAAYIOw1yFAD+AAAIAAYIOw1yFAD+AAAAAA==.',['颖宝']='颖宝:BAAAKgAECgIIAgAAAA==.',['风絮']='风絮芮兒:BAAAKgAECgMIAwAAAA==.',['饿魔']='饿魔之握:BAAAKgAFFAQIBAAAAA==.',['首席']='首席杏仁学家:BAACKgAFFH8hAAMcAAUItx4TCgDNAAAcAAUIpBgTCgDNAAAaAAMIIBuCKACmAAAqAAQKfycAAxwACAi4IisKAHsCABwABwgmJCsKAHsCABoABQgaHGY/AB8BAAAA.',['骚气']='骚气春哥:BAAAKgAECgYIBgAAAA==.',['骧驣']='骧驣獣圙:BAAAKgADCgcIBwAAAA==.',['魂牵']='魂牵的小猎:BAAAKgAFFAIIAgAAAA==.',['鲜菓']='鲜菓時間:BAAAKgAECgUIBQAAAA==.',['麽麽']='麽麽哒丶:BAAAKgAECgQIBQAAAA==.',['鼠鼠']='鼠鼠大运营:BAABKgAFFH8GAAIVAAYI2xG6EgBmAQAVAAYI2xG6EgBmAQAAAA==.',['龙不']='龙不吟虎不啸:BAABKgAFFH8IAAMgAAgI9Q5yAgBNAQAgAAYIWRFyAgBNAQAiAAIIYSLGJgCiAAAAAA==.',['龙之']='龙之狂舞:BAAAKgAECgEIAQAAAA==.',['龙龙']='龙龙飛:BAAAKgADCgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end