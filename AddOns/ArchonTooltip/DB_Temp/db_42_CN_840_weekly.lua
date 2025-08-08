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
 local lookup = {'Shaman-Restoration','Rogue-Assassination','Evoker-Devastation','Evoker-Preservation','Hunter-Marksmanship','Hunter-BeastMastery','Druid-Balance','Priest-Discipline','Priest-Holy','Priest-Shadow','DemonHunter-Havoc','Paladin-Retribution','Paladin-Protection','Paladin-Holy','DeathKnight-Unholy','DeathKnight-Blood','Hunter-Survival','DemonHunter-Vengeance','Unknown-Unknown','Mage-Frost','Mage-Arcane','Monk-Brewmaster','Monk-Mistweaver','Warrior-Protection','Warrior-Fury','Mage-Fire','Druid-Restoration','Warrior-Arms','Druid-Guardian','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Shaman-Enhancement','Rogue-Subtlety','Rogue-Outlaw','Monk-Windwalker',}; local provider = {region='CN',realm='达纳斯',name='CN',type='weekly',zone=42,date='2025-08-02',data={Ae='Aether:BAAAKgADCgUIBQAAAA==.',Al='Allisom:BAAAKgAFFAEIAQAAAA==.',Bi='Bility:BAAAKgAECgIIAgAAAA==.',Bl='Blackwarlock:BAAAKgADCggICAAAAA==.',Bo='Bob:BAAAKgAECggICAAAAA==.',Ch='Chandlerbing:BAAAKgAECggICAAAAA==.',Da='Darkmurmur:BAAAKgAECgEIAQAAAA==.',De='Devil:BAAAKgAECgIIAgAAAA==.',Et='Ethanz:BAABKgAFFH8FAAIBAAMI1AvxJgCDAAABAAMI1AvxJgCDAAAAAA==.',Fi='Fireroy:BAAAKgADCggIFAAAAA==.',Ga='Gaoyuan:BAABKgAFFH8PAAICAAYIth1nCADfAQACAAYIth1nCADfAQAAAA==.',He='Heysfe:BAAAKgAFFAMIAwAAAA==.',Hm='Hms:BAABKgAFFH8KAAMDAAYIVhr8AwBqAQADAAQIYRj8AwBqAQAEAAMIwg3wBwB4AAAAAA==.',Ho='Hopeless:BAAAKgAECgIIAgAAAA==.',Is='Isolation:BAAAKgAECggICAAAAA==.',Ji='Jimzoe:BAABKgAECn8YAAMFAAgIJA9EMwBlAQAFAAgIJA9EMwBlAQAGAAUIFg0XuQCxAAAAAA==.Jinsir:BAAAKgAECgEIAQAAAA==.',Ju='Jude:BAAAKgAECgQIBAAAAA==.Juliette:BAAAKgAFFAEIAgAAAA==.Juliy:BAAAKgAFFAEIAQAAAA==.',Ki='Kitelin:BAAAKgADCgcIBwAAAA==.',Ky='Kyle:BAAAKgAECggIDgAAAA==.Kylelr:BAAAKgAECgEIAQAAAA==.Kyleqs:BAAAKgAECgUIBQAAAA==.',Le='Leaving:BAAAKgADCggICAAAAA==.Legend:BAAAKgAECggIDwAAAA==.',Lo='Loonger:BAABKgAFFH8GAAIFAAYIGBDSFgAvAQAFAAYIGBDSFgAvAQAAAA==.',Ma='Macmoses:BAABKgAFFH8GAAIHAAYIbxbOEQCPAQAHAAYIbxbOEQCPAQAAAA==.Maus:BAACKgAFFH9BAAMIAAgIZhvBBAD6AQAIAAcICBzBBAD6AQAJAAIIXxwOFACdAAAqAAQKf0AABAgACAiCIMcRADkCAAgACAhzIMcRADkCAAkAAwgyHR5FAP4AAAoABgijC/RCAOsAAAAA.',Mi='Michee:BAAAKgAFFAEIBAAAAA==.Mikolous:BAABKgAFFH8NAAMIAAYI0xS5AgCJAQAIAAYI0xS5AgCJAQAKAAEIAAA3LgAAAAAAAA==.',Mo='Monsterivan:BAAAKgAECgUICQAAAA==.',Ne='Nemesis:BAAAKgAECgUIBQAAAA==.',Rr='Rrogua:BAAAKgAECgUIBgAAAA==.',Sk='Skyla:BAABKgAFFH8NAAIJAAMIUBozHwDMAAAJAAMIUBozHwDMAAAAAA==.',Sy='Syou:BAACKgAFFH8UAAILAAMICSI0EwDzAAALAAMICSI0EwDzAAAqAAQKfywAAgsACAgJIvkWAHwCAAsACAgJIvkWAHwCAAEqAAUUAwgZAAkAnR4A.',Th='Thunderbolt:BAAAKgAFFAYIAgABKgAFFAgIFgABAMYWAA==.',To='Topaz:BAAAKgAECgIIAgAAAA==.',Wi='Wireshark:BAAAKgAFFAMIBAAAAA==.',['一一']='一一吖一一:BAAAKgADCgEIAgAAAA==.',['一分']='一分裤小帅哥:BAAAKgAECggICAAAAA==.',['一号']='一号草药库:BAAAKgAECgIIAgAAAA==.',['一抹']='一抹丶半夏:BAAAKgAECgIIAgAAAA==.',['一杆']='一杆大烟枪:BAABKgAECn8WAAMMAAgIbAwEngBbAQAMAAgIbAwEngBbAQANAAEIAAAAAAAAAAAAAA==.',['一醉']='一醉千年:BAAAKgADCgQIBAAAAA==.',['一雪']='一雪团团一:BAABKgAFFH8eAAQMAAgIaB53CgAdAgAMAAgIaB53CgAdAgANAAYIixg/CQBsAQAOAAYIiAp1BwA8AQAAAA==.',['七夜']='七夜圣光:BAAAKgAFFAEIAgAAAA==.',['三千']='三千雷劫:BAAAKgAFFAQIBAAAAA==.',['三秋']='三秋叶大风歌:BAABKgAFFH8LAAMPAAQI7RVULQDZAAAPAAQI7RVULQDZAAAQAAQIyAZYKQBwAAAAAA==.',['不想']='不想游泳的鱼:BAAAKgADCgYIBgAAAA==.',['世宗']='世宗大王:BAAAKgAECgMIBQAAAA==.',['两只']='两只小白兔:BAAAKgAFFAIIAgAAAA==.',['两根']='两根黄瓜:BAAAKgADCggIGAAAAA==.',['丶俄']='丶俄性空虚:BAAAKgADCgQIBAAAAA==.',['丶南']='丶南宫:BAAAKgAFFAEIAQABKgAFFAQIEAALAKUiAA==.',['丶皮']='丶皮皮:BAABKgAECn8fAAIDAAgI+x7yDQBjAgADAAgI+x7yDQBjAgABKgAFFAMIGQAJAJ0eAA==.',['乊夜']='乊夜火琉萤乊:BAABKgAFFH8FAAMPAAMIKBKbNADEAAAPAAMIKBKbNADEAAAQAAIIVwd/MABKAAABKgAFFAQIEAALAKUiAA==.',['乐楽']='乐楽樂:BAAAKgAECgYIBgAAAA==.',['九天']='九天飞星月:BAABKgAFFH8MAAMFAAQIjhSxKADHAAAFAAQIjhSxKADHAAAGAAQIkg68NQC9AAAAAA==.',['九遥']='九遥:BAABKgAFFH8IAAIPAAYI/QZCDQAnAQAPAAYI/QZCDQAnAQAAAA==.',['云端']='云端漫步:BAAAKgADCgMIAwAAAA==.',['亦兮']='亦兮若之:BAACKgAFFH8SAAIRAAMIfB6wAQAEAQARAAMIfB6wAQAEAQAqAAQKfxUAAhEABQjZI6sFAOcBABEABQjZI6sFAOcBAAAA.',['仲夏']='仲夏夜语:BAAAKgADCgEIAQAAAA==.',['任平']='任平生:BAAAKgADCgEIAQAAAA==.',['企鹅']='企鹅不会飞:BAAAKgADCggIEAAAAA==.',['伊利']='伊利蛋蛋:BAAAKgADCgEIAQAAAA==.',['伊梅']='伊梅尔达:BAAAKgAECggIEgAAAA==.',['伊诺']='伊诺山度:BAAAKgAECgYIBwAAAA==.',['伍四']='伍四三二一:BAAAKgAECgIIAgAAAA==.',['会放']='会放电的木木:BAAAKgADCgUIBQAAAA==.',['你付']='你付出了什么:BAACKgAFFH8HAAILAAQIRBggJQDkAAALAAQIRBggJQDkAAAqAAQKfxoAAwsACAg8IvQWAHwCAAsACAg8IvQWAHwCABIAAQg5HNBYAE0AAAAA.',['你是']='你是不是聋鸣:BAABKgAFFH8IAAIDAAYIQhFiBABcAQADAAYIQhFiBABcAQAAAA==.',['你踩']='你踩我尾巴了:BAAAKgAECgUICQAAAA==.',['依依']='依依吖依依:BAAAKgADCgEIAQAAAA==.',['偏爱']='偏爱狐狸精:BAAAKgAFFAYIBAAAAA==.',['储蓄']='储蓄罐里的猪:BAAAKgAECgQIBAABKgAFFAgIBAATAAAAAA==.',['允允']='允允大魔头:BAABKgAFFH8NAAMUAAYIURf3BACSAQAUAAYIURf3BACSAQAVAAUIlxLcGQAVAQAAAA==.',['光明']='光明:BAAAKgAECgIIAgAAAA==.',['克伦']='克伦海德公爵:BAAAKgAECgEIAQAAAA==.',['兜兜']='兜兜里有糖:BAAAKgAFFAEIAQAAAA==.兜兜里没箭:BAAAKgAECggICAAAAA==.',['兮黎']='兮黎:BAAAKgAECgQIBAAAAA==.',['兰婆']='兰婆婆:BAAAKgADCggIDAAAAA==.',['兰心']='兰心蕙性:BAAAKgAECgQIBAAAAA==.',['再来']='再来一包:BAAAKgAFFAgIBAAAAA==.',['冫令']='冫令钅夆:BAAAKgADCggICwAAAA==.',['冫疑']='冫疑冫青:BAABKgAFFH8HAAMWAAYIPxeTAgBHAQAWAAYIPxeTAgBHAQAXAAEIWQ8FLAA8AAAAAA==.',['冲锋']='冲锋等战复:BAACKgAFFH8ZAAMYAAQIJBgzBQC9AAAYAAMIJBgzBQC9AAAZAAEIAABIPAAAAAAqAAQKfyAAAxgACAgvGsMMAPABABgACAgvGsMMAPABABkABwjWEZw0AFYBAAAA.',['凉拌']='凉拌丶香椿:BAAAKgADCgcIBwAAAA==.',['出门']='出门左转:BAABKgAFFH8GAAIZAAYIXRxgDACGAQAZAAYIXRxgDACGAQAAAA==.',['剑影']='剑影无痕:BAAAKgADCgIIAgAAAA==.',['剑盾']='剑盾华尔兹:BAAAKgAECgMIAwAAAA==.',['勤劳']='勤劳的社畜:BAABKgAFFH8JAAMPAAMIdwTrPwCeAAAPAAMIdwTrPwCeAAAQAAIIugAdNAAtAAAAAA==.',['千寻']='千寻:BAAAKgAECggICAAAAA==.',['半路']='半路救一人:BAAAKgAECgUIBQAAAA==.',['卡林']='卡林姆的意志:BAABKgAFFH8IAAIMAAQIZBRrIADoAAAMAAQIZBRrIADoAAAAAA==.',['卡维']='卡维菈丶裂空:BAAAKgAECggIEAAAAA==.',['印紫']='印紫:BAAAKgADCgMIAwAAAA==.',['受伤']='受伤的喵:BAAAKgAECgcIBwAAAA==.',['变身']='变身大神:BAAAKgADCgMIAwAAAA==.',['只想']='只想用头撞墙:BAABKgAECn8dAAIPAAgIIxxuKQASAgAPAAgIIxxuKQASAgABKgAFFAgICAANACkEAA==.',['吃不']='吃不胖的胖子:BAAAKgAFFAQIBAAAAA==.',['吊丝']='吊丝娷刘诗诗:BAABKgAFFH8GAAIWAAYIMgLQBgCbAAAWAAYIMgLQBgCbAAAAAA==.',['吼路']='吼路:BAAAKgADCgMIAwAAAA==.',['咕嘟']='咕嘟:BAAAKgAECgEIAQAAAA==.',['哈士']='哈士骑:BAAAKgAECgMIAwAAAA==.',['哈特']='哈特虎:BAAAKgAECgQIBQAAAA==.',['哈狄']='哈狄师:BAAAKgAECgYIDQAAAA==.',['啾啾']='啾啾吖啾啾:BAAAKgADCgEIAQAAAA==.',['善若']='善若:BAAAKgAECgQIBQAAAA==.',['喵喵']='喵喵胖熊熊:BAABKgAFFH8BAAIXAAEIXAFJNgAgAAAXAAEIXAFJNgAgAAAAAA==.',['嘟嘟']='嘟嘟舅舅:BAABKgAFFH8OAAMZAAgI6AGJEgDYAAAZAAYIQwKJEgDYAAAYAAYIFAGxDwCBAAAAAA==.',['嘿嘿']='嘿嘿吖嘿嘿:BAAAKgADCgYIBwAAAA==.',['四灵']='四灵驱邪之牛:BAACKgAFFH8IAAIFAAMIjgecNwCXAAAFAAMIjgecNwCXAAAqAAQKfxQAAgUACAgPFOUvAKABAAUACAgPFOUvAKABAAAA.',['回到']='回到昨天:BAAAKgAECgQIBAAAAA==.',['圄圄']='圄圄兔:BAAAKgAFFAgIBAAAAA==.',['圣光']='圣光大叔:BAAAKgAECggICgAAAA==.圣光热不死你:BAAAKgAECgMIAwAAAA==.',['坚挺']='坚挺不解释:BAACKgAFFH8GAAIMAAMIJR+ANwANAQAMAAMIJR+ANwANAQAqAAQKfxUAAgwACAjiI5oTALwCAAwACAjiI5oTALwCAAAA.',['坦爷']='坦爷:BAAAKgAECggICAAAAA==.',['基恩']='基恩么:BAAAKgAECggIDwABKgAFFAgICAANACkEAA==.',['塞巴']='塞巴斯蒂安丶:BAABKgAFFH8PAAIaAAYIGSRuAQAjAgAaAAYIGSRuAQAjAgABKgAFFAgIPAAaAN8mAA==.',['壹米']='壹米陽光:BAACKgAFFH8PAAMbAAMI9hq4GADbAAAbAAMI9hq4GADbAAAHAAIIdwE/WgBJAAAqAAQKfxQAAhsACAhdCl1AAA4BABsACAhdCl1AAA4BAAAA.',['夏天']='夏天旳风:BAAAKgAECggICAAAAA==.',['夏日']='夏日海滨:BAABKgAECn8jAAMIAAgIYSLyBQCmAgAIAAgIYSLyBQCmAgAKAAYIrwMMVQCXAAAAAA==.',['夕梨']='夕梨:BAAAKgAECgQIBAAAAA==.',['多大']='多大的雨:BAABKgAFFH8OAAMFAAgIABhvBgADAgAFAAgIERVvBgADAgAGAAYIfBt0DwCBAQAAAA==.',['夜影']='夜影蓝:BAAAKgADCggICAAAAA==.',['夜的']='夜的第七章:BAAAKgAFFAQIBAAAAA==.',['夢幻']='夢幻丶薄桜:BAACKgAFFH8ZAAIJAAMInR5LFwD7AAAJAAMInR5LFwD7AAAqAAQKfzAAAwkACAgTI5oNAGgCAAkACAgTI5oNAGgCAAoACAgrEdI2AOoAAAAA.',['大伙']='大伙一起上丶:BAAAKgADCgUIBgAAAA==.',['大只']='大只青头籽:BAAAKgAECgcIDQAAAA==.',['大圣']='大圣:BAAAKgAECgEIAQAAAA==.',['大家']='大家速度灭:BAAAKgAFFAgIAQAAAA==.',['大烟']='大烟枪:BAAAKgAECgcIBwAAAA==.',['大眼']='大眼睛狂战:BAAAKgAECgEIAQAAAA==.大眼睛萨满:BAAAKgAECgIIAgAAAA==.大眼睛骑士:BAAAKgAECgUIBQAAAA==.',['大魔']='大魔导师:BAAAKgAECgIIAgAAAA==.',['天使']='天使小朱:BAABKgAECn8YAAILAAgIyQnFUgD+AAALAAgIyQnFUgD+AAAAAA==.',['天堂']='天堂里的地狱:BAAAKgAFFAQIBAAAAA==.',['天魔']='天魔行:BAABKgAFFH8JAAMUAAMILBNoGwCmAAAUAAMILBNoGwCmAAAVAAIIrgXIQQBNAAAAAA==.',['失业']='失业的江南:BAAAKgAFFAEIAgAAAA==.',['头顶']='头顶灰机灰过:BAAAKgAECgEIAQAAAA==.',['妙不']='妙不可言:BAAAKgAECgYIDAAAAA==.',['子衿']='子衿灬:BAABKgAFFH8MAAMaAAYIvRpKDABxAQAaAAYI3RhKDABxAQAVAAYIHxTSEgBPAQAAAA==.',['孤独']='孤独之猎:BAAAKgAFFAIIAgAAAA==.',['守护']='守护一片天:BAAAKgADCggICQAAAA==.守护与怜悯:BAABKgAFFH8IAAIMAAQIph2COgACAQAMAAQIph2COgACAQAAAA==.',['安东']='安东尼奥:BAAAKgAFFAQIBAABKgAFFAgINgAcAIYmAA==.',['宝贝']='宝贝小鸡:BAAAKgAECggICAAAAA==.',['寳貝']='寳貝猎:BAAAKgADCgEIAQAAAA==.',['寶貝']='寶貝熊:BAAAKgAECgYIBgAAAA==.',['射击']='射击假死:BAAAKgADCgcIBwAAAA==.',['小小']='小小石头:BAAAKgAECgIIAgAAAA==.小小茶叶蛋:BAAAKgAFFAQIBAAAAA==.',['小巧']='小巧卝朦胧:BAABKgAFFH8GAAMKAAQI3ATPFwCkAAAKAAQI3ATPFwCkAAAJAAII2QF4HwA7AAAAAA==.',['小布']='小布丁:BAAAKgADCgEIAQAAAA==.',['小拳']='小拳拳锤你哟:BAAAKgAFFAEIAwAAAA==.',['小牛']='小牛奶:BAAAKgAFFAYIAwABKgAFFAgIIwAVAIglAA==.',['小田']='小田佩奇:BAABKgAFFH8FAAIXAAMIwhvoFwDgAAAXAAMIwhvoFwDgAAABKgAFFAgIAgATAAAAAA==.',['小红']='小红帽:BAAAKgADCgEIAQAAAA==.',['小蜜']='小蜜蜂:BAAAKgAECgYIBgAAAA==.',['小馨']='小馨猪:BAAAKgAECgEIAQAAAA==.',['尤菲']='尤菲米娅:BAAAKgAFFAIIAgAAAA==.',['就是']='就是点不到我:BAAAKgAFFAgIAgAAAA==.',['屠龙']='屠龙咆哮:BAABKgAFFH8GAAMGAAMImBEqRgCJAAAGAAIIzhMqRgCJAAAFAAEILQ0jKQAyAAAAAA==.',['左右']='左右开弓:BAABKgAFFH8KAAIBAAMIah8NEQDzAAABAAMIah8NEQDzAAAAAA==.',['希爾']='希爾瓦納斯:BAAAKgAECgUIBQABKgAFFAEIBAATAAAAAA==.',['年糕']='年糕大兄本尊:BAACKgAFFH8PAAMbAAQIQggFEQCtAAAbAAQIQggFEQCtAAAdAAMIaQxlCQB4AAAqAAQKfxUAAh0ABwg4HOkNAMcBAB0ABwg4HOkNAMcBAAAA.',['幽若']='幽若蓝:BAABKgAFFH8GAAIcAAYIJyJJBAADAgAcAAYIJyJJBAADAgAAAA==.',['开江']='开江喽德哇:BAAAKgAECgQIBAAAAA==.',['强妹']='强妹:BAAAKgAFFAMIAwAAAA==.',['彦祖']='彦祖:BAAAKgAFFAQIBAAAAA==.',['彼岸']='彼岸的风铃:BAABKgAFFH8NAAMaAAcIYRzoBwDOAQAaAAcIzhnoBwDOAQAUAAQI6RjCJgAAAAAAAA==.',['得意']='得意:BAAAKgAECgQIBAAAAA==.',['德尼']='德尼骑:BAAAKgAFFAgIBAAAAA==.',['心语']='心语:BAABKgAFFH8IAAIQAAQIox+SBwAaAQAQAAQIox+SBwAaAQAAAA==.',['快乐']='快乐鹰:BAAAKgAFFAMIAwAAAA==.',['怂逼']='怂逼:BAAAKgADCgUIBQAAAA==.',['恩歌']='恩歌拉夏:BAABKgAFFH8IAAMPAAQIcyVqBQBQAQAPAAQIcyVqBQBQAQAQAAQIDhJiEQC2AAAAAA==.',['悬空']='悬空小德:BAAAKgAFFAIIAwAAAA==.',['愤怒']='愤怒的奶妈:BAAAKgAECgQIBAAAAA==.愤怒的达芬奇:BAAAKgADCgEIAQAAAA==.愤怒的野马:BAAAKgAECgQIBAAAAA==.',['慧光']='慧光大师:BAAAKgAFFAgIAwAAAA==.',['懂王']='懂王:BAAAKgAECgMIAwAAAA==.',['我师']='我师妹灭绝:BAAAKgADCgMIAwAAAA==.',['我是']='我是吃货:BAAAKgAFFAQIAwAAAA==.我是射手座丶:BAAAKgAFFAIIAwAAAA==.',['我有']='我有一个问题:BAAAKgAECgYIBgAAAA==.',['我爱']='我爱肥罗:BAAAKgADCgEIAQAAAA==.',['戮之']='戮之微笑:BAAAKgAECggICAAAAA==.',['托尼']='托尼贾:BAAAKgAECgEIAQAAAA==.',['折耳']='折耳猫不吃鱼:BAAAKgADCggICAAAAA==.',['拯救']='拯救小龙人:BAAAKgAECgYICAAAAA==.',['捌佰']='捌佰:BAAAKgAECgUIBQAAAA==.',['掰喵']='掰喵咪:BAAAKgAECgIIAgABKgAECggIDgATAAAAAA==.',['斬魔']='斬魔者:BAAAKgAECgUIBwAAAA==.',['旗袍']='旗袍:BAAAKgAECgIIAgAAAA==.',['无所']='无所谓的冲锋:BAABKgAECn8XAAIcAAgIXRjCBgALAgAcAAgIXRjCBgALAgAAAA==.无所谓的飞盾:BAAAKgAECggIDwAAAA==.',['无限']='无限复仇:BAAAKgAECgQIBAAAAA==.',['春暖']='春暖:BAAAKgAECggIDgAAAA==.',['晓安']='晓安:BAAAKgAFFAgIAgAAAA==.',['晨曦']='晨曦月影:BAAAKgAFFAEIAQAAAA==.晨曦迷雾:BAAAKgAECgYIBgAAAA==.',['晨的']='晨的传说:BAACKgAFFH8UAAMGAAgI3Bo3BwAOAgAGAAgI/Rg3BwAOAgAFAAYIEh54CwCeAQAqAAQKfxUAAgYACAhdAdDvAFQAAAYACAhdAdDvAFQAAAAA.',['暖风']='暖风:BAAAKgADCgEIAQAAAA==.',['暗香']='暗香盈秀:BAAAKgAECggICgAAAA==.',['暮筱']='暮筱:BAAAKgAECgYIBgAAAA==.',['暮色']='暮色来临:BAAAKgADCgEIAQAAAA==.',['暮雪']='暮雪微雨:BAAAKgADCggICAAAAA==.',['暴走']='暴走一戟灞:BAAAKgAECggIEwAAAA==.',['曦雲']='曦雲似水:BAAAKgAECgIIAgAAAA==.',['月下']='月下协奏曲:BAAAKgAECgcICAAAAA==.',['月光']='月光天舞:BAAAKgAFFAgIBAAAAA==.',['月半']='月半月半术:BAAAKgADCgIIAgAAAA==.月半熊:BAACKgAFFH8lAAMeAAcIniKBCAAhAQAeAAYIUx+BCAAhAQAfAAMIiiRaDQDLAAAqAAQKfx4AAx4ACAjnI/EGALoCAB4ACAjnI/EGALoCAB8AAwg0GOBbAIQAAAAA.',['月神']='月神:BAAAKgADCggICAAAAA==.',['木木']='木木啊木木:BAAAKgADCgEIAQAAAA==.',['术手']='术手巫策:BAABKgAFFH8SAAMeAAgIAyMgAgCvAgAeAAgIAyMgAgCvAgAgAAYINBDpAwBPAQAAAA==.',['杀务']='杀务尽:BAAAKgAFFAEIAQAAAA==.',['李大']='李大嘴李:BAABKgAFFH8IAAIHAAgIBBSnBwAsAgAHAAgIBBSnBwAsAgAAAA==.',['李娜']='李娜莉:BAACKgAFFH8FAAIMAAIIlwznPwCIAAAMAAIIlwznPwCIAAAqAAQKfxQAAgwABwihG+FsAL8BAAwABwihG+FsAL8BAAAA.',['村里']='村里的鸡:BAAAKgAECgYIDQAAAA==.',['极丶']='极丶光:BAABKgAFFH8vAAQZAAgIWA1pDQB5AQAZAAgIWAlpDQB5AQAcAAcIlQkmCwBbAQAYAAMI+xU0CgDBAAAAAA==.',['柳如']='柳如烟:BAAAKgADCgQIBAAAAA==.',['梦尽']='梦尽凡尘:BAAAKgAFFAQIBAAAAA==.',['梦烬']='梦烬:BAABKgAFFH8IAAIQAAgI6ActBgBeAQAQAAgI6ActBgBeAQAAAA==.',['椒图']='椒图衔环:BAAAKgAECgUICQAAAA==.',['橘味']='橘味汽水:BAAAKgADCggICAAAAA==.',['武极']='武极:BAAAKgAECggICQAAAA==.',['歪头']='歪头大棒槌:BAABKgAFFH8QAAIMAAgIEwvgEgDFAQAMAAgIEwvgEgDFAQAAAA==.',['残月']='残月:BAAAKgAECgQIBAAAAA==.',['比亚']='比亚乔霸伏:BAABKgAFFH8KAAIeAAgIAiRMAQDaAgAeAAgIAiRMAQDaAgAAAA==.',['毛纟']='毛纟线:BAAAKgAFFAEIAwAAAA==.',['水果']='水果沙拉:BAACKgAFFH8HAAIbAAMIKhLWIACnAAAbAAMIKhLWIACnAAAqAAQKfxYAAhsACAg6F7ouAGkBABsACAg6F7ouAGkBAAAA.',['水波']='水波波:BAABKgAFFH8IAAMMAAQIzCVVBgBOAQAMAAQIzCVVBgBOAQAOAAEI8wEAAAAAAAAAAA==.',['汝之']='汝之所向:BAABKgAFFH8XAAIJAAMIORvwHADYAAAJAAMIORvwHADYAAAAAA==.',['江南']='江南酿造厂长:BAAAKgAFFAEIAgAAAA==.',['江浸']='江浸月丶:BAABKgAECn8UAAMOAAgI0Ru6EAD4AQAOAAgI0Ru6EAD4AQAMAAUIbxZtrwDxAAAAAA==.',['沉默']='沉默之剑:BAAAKgAECgYIBgAAAA==.',['沙布']='沙布兰尼古:BAABKgAFFH8PAAMVAAgIxwv5CADgAQAVAAgIxwv5CADgAQAUAAMISQzXDQCsAAAAAA==.',['沙漠']='沙漠之狐:BAAAKgADCggICAAAAA==.沙漠独角兽:BAAAKgAECgQIBQAAAA==.',['没事']='没事:BAAAKgAECggIAQAAAA==.',['油灬']='油灬泼灬麵:BAABKgAFFH8cAAQeAAgIuCH3AQC2AgAeAAgIuCH3AQC2AgAfAAUIoBG6AQAzAQAgAAII/hEPFwCFAAABKgAFFAgIJQAeAJ4iAA==.',['波涛']='波涛呀:BAAAKgADCgEIAgAAAA==.',['泰沙']='泰沙拉克重工:BAAAKgAECgcICgAAAA==.',['流光']='流光剑:BAAAKgAECgMIAwAAAA==.',['浅尝']='浅尝思念:BAABKgAFFH8SAAISAAMIqx3mCgD9AAASAAMIqx3mCgD9AAAAAA==.',['浅笑']='浅笑瀡訫:BAAAKgAECgUIBQAAAA==.',['浓浓']='浓浓桂花香:BAAAKgADCggICQAAAA==.',['浮生']='浮生半日:BAABKgAECn8WAAIMAAgIWBu7SwAOAgAMAAgIWBu7SwAOAgAAAA==.',['淺笑']='淺笑随心:BAAAKgADCgEIAgAAAA==.',['清幽']='清幽风雨:BAAAKgADCgEIAQAAAA==.',['火语']='火语花:BAAAKgADCggICgAAAA==.',['灵冰']='灵冰:BAAAKgAECgcICwAAAA==.',['灵魂']='灵魂无畏:BAAAKgAFFAIIAgAAAA==.',['炒年']='炒年糕:BAACKgAFFH8OAAIMAAMIJxZlUQDNAAAMAAMIJxZlUQDNAAAqAAQKfxwAAgwACAhhGrtHABkCAAwACAhhGrtHABkCAAAA.',['烟斗']='烟斗大师:BAAAKgADCggICAAAAA==.',['焓蔓']='焓蔓:BAAAKgADCggICAAAAA==.',['燮岺']='燮岺:BAAAKgADCggICAAAAA==.',['狠帅']='狠帅丶狠无奈:BAACKgAFFH8GAAIPAAMIbRMiEwDLAAAPAAMIbRMiEwDLAAAqAAQKfx8AAg8ACAgOItcLAK8CAA8ACAgOItcLAK8CAAAA.',['独品']='独品:BAAAKgADCggIEQAAAA==.',['玉风']='玉风:BAABKgAECn8eAAIOAAgIihB7IgBNAQAOAAgIihB7IgBNAQAAAA==.',['珞斯']='珞斯:BAABKgAFFH8MAAIDAAYI6BTJDwBkAQADAAYI6BTJDwBkAQAAAA==.',['疾風']='疾風訊雷:BAAAKgAECgcIBgAAAA==.',['白桃']='白桃棒棒冰:BAAAKgAFFAEIAQAAAA==.',['白河']='白河愁:BAAAKgAFFAEIAgAAAA==.',['白色']='白色闪电:BAAAKgAECggIEwAAAA==.',['白银']='白银爵士:BAABKgAFFH8GAAIZAAYI1RLjDQB0AQAZAAYI1RLjDQB0AQAAAA==.',['白露']='白露為霜:BAABKgAECn8UAAIJAAgIfBH8KgCdAQAJAAgIfBH8KgCdAQAAAA==.',['百变']='百变妞妞:BAAAKgAECgEIAQAAAA==.',['皓月']='皓月鸣响:BAAAKgAECgQIBQAAAA==.',['皓翰']='皓翰丿晤疋:BAAAKgAECgYIBgAAAA==.',['皮皮']='皮皮浪:BAAAKgAFFAQIBAAAAA==.',['盛夏']='盛夏蔚蓝:BAAAKgAECgIIAgAAAA==.',['盼盼']='盼盼:BAACKgAFFH8MAAIcAAMIswgsDwCgAAAcAAMIswgsDwCgAAAqAAQKfyUAAhwACAg9E68bAKgBABwACAg9E68bAKgBAAAA.',['睡睡']='睡睡小公主:BAAAKgADCgEIAwAAAA==.',['瞑王']='瞑王哈迪斯:BAAAKgADCgEIAQAAAA==.',['硝酸']='硝酸甘油:BAABKgAFFH8KAAMcAAYIVg4DDABOAQAcAAYIww0DDABOAQAZAAQIOA3zJAC8AAAAAA==.',['碉堡']='碉堡了:BAABKgAFFH8GAAIMAAYIVCE6FQCxAQAMAAYIVCE6FQCxAQAAAA==.',['碎魂']='碎魂索灵:BAAAKgADCgQIBAAAAA==.',['神秘']='神秘壹号演员:BAAAKgAFFAQIAgAAAA==.',['秦广']='秦广王:BAAAKgADCggICAAAAA==.',['竹曉']='竹曉曉:BAAAKgAECgIIAgAAAA==.',['箭破']='箭破水中月:BAAAKgAECggICAAAAA==.',['米兰']='米兰小裁缝:BAAAKgAECgYIBwAAAA==.',['粉色']='粉色的西瓜:BAAAKgAFFAYIBAAAAA==.',['紫色']='紫色虚无:BAAAKgAECgcIDQAAAA==.紫色隐身者:BAAAKgAECgQICAAAAA==.',['红灬']='红灬茶:BAABKgAFFH8GAAIBAAYIoQYbIAD5AAABAAYIoQYbIAD5AAAAAA==.',['红炎']='红炎海棠:BAACKgAFFH8vAAMZAAYI8SVYBgAKAgAZAAYI8SVYBgAKAgAcAAQIgRa2FwDKAAAqAAQKfyEAAxkACAi2JMgLAKgCABkACAi2JMgLAKgCABwAAQgFIhhaAGMAAAAA.',['红色']='红色闪电:BAAAKgAECgIIAgAAAA==.',['红葉']='红葉舞:BAABKgAFFH8FAAILAAUITh/cDQClAQALAAUITh/cDQClAQAAAA==.',['纯情']='纯情小狐狸:BAABKgAFFH8NAAIBAAMIAwwAOQCeAAABAAMIAwwAOQCeAAAAAA==.',['终极']='终极皮皮怪:BAAAKgAECgIIAgAAAA==.',['给你']='给你一片天:BAAAKgADCgMIBQAAAA==.',['绝尘']='绝尘丶苏筱:BAAAKgAECgYIBgAAAA==.',['维克']='维克多里安:BAABKgAFFH8IAAIQAAQI7Q8EGQCMAAAQAAQI7Q8EGQCMAAAAAA==.',['维迪']='维迪卡尔之盾:BAAAKgAECggICAAAAA==.',['羅澜']='羅澜雲天:BAABKgAECn8WAAMQAAgIyxQ+HgBaAQAQAAgIjxA+HgBaAQAPAAYI0xacSgBHAQAAAA==.',['老年']='老年神龙大侠:BAAAKgAFFAMIAwAAAA==.',['耶米']='耶米夜影:BAABKgAECn8WAAIHAAgItQzQXwA6AQAHAAgItQzQXwA6AQAAAA==.',['联盟']='联盟国王:BAAAKgAECggICwAAAA==.',['聪明']='聪明的笨蛋:BAAAKgAECgIIAgAAAA==.',['背叛']='背叛天使:BAACKgAFFH8GAAIJAAMIXgePGAB7AAAJAAMIXgePGAB7AAAqAAQKfxUAAgkACAgkCjpIAPEAAAkACAgkCjpIAPEAAAAA.',['胖虎']='胖虎偷油吃:BAABKgAFFH8KAAIXAAQI7RxPCgASAQAXAAQI7RxPCgASAQAAAA==.胖虎打酱油:BAABKgAFFH8OAAIBAAYIcCU/AAApAgABAAYIcCU/AAApAgAAAA==.',['能猫']='能猫人:BAAAKgAFFAYIBAAAAA==.',['脉冲']='脉冲高达:BAAAKgAFFAYIAQAAAA==.',['脑袋']='脑袋背锅:BAAAKgADCgMIAwAAAA==.',['色韵']='色韵东方:BAAAKgAECgEIAQAAAA==.',['花下']='花下杨柳:BAAAKgAECgEIAQAAAA==.',['苏醒']='苏醒之风:BAABKgAECn8jAAMhAAgIlhYeEgDaAQAhAAgIlhYeEgDaAQABAAcIhArpiACcAAAAAA==.',['若木']='若木之落:BAAAKgAFFAIIBAAAAA==.',['草莓']='草莓熊:BAACKgAFFH8LAAIFAAMI3wqMNwCXAAAFAAMI3wqMNwCXAAAqAAQKfyUAAwUACAhfGbQkAOABAAUACAhfGbQkAOABAAYABgiaDiWbAPIAAAAA.',['莫贺']='莫贺延碛:BAAAKgAECgEIAgAAAA==.',['萨斯']='萨斯给:BAAAKgADCggICAAAAA==.',['萨蛮']='萨蛮青青:BAAAKgAECgEIAQAAAA==.',['葛伦']='葛伦多霜瞳:BAABKgAFFH8GAAIGAAYIbhovAgDJAQAGAAYIbhovAgDJAQAAAA==.',['蒹葭']='蒹葭:BAAAKgAECggIDQAAAA==.',['蓝色']='蓝色星尘:BAABKgAFFH8IAAIBAAgI2AkGCQC2AQABAAgI2AkGCQC2AQAAAA==.',['蔷薇']='蔷薇精灵:BAABKgAECn8ZAAIMAAgIdAofPAAUAQAMAAgIdAofPAAUAQAAAA==.',['蛮三']='蛮三刀:BAABKgAFFH8TAAIPAAQIkw1VNQDCAAAPAAQIkw1VNQDCAAAAAA==.',['蝉声']='蝉声无尽:BAABKgAFFH8HAAIPAAYILhinHgAqAQAPAAYILhinHgAqAQAAAA==.',['親親']='親親丶寶貝:BAAAKgAECgUICQAAAA==.',['言不']='言不清:BAABKgAFFH8IAAINAAgIKQQhDwAOAQANAAgIKQQhDwAOAQAAAA==.',['订单']='订单永不超时:BAAAKgAFFAIIAgAAAA==.',['诗桦']='诗桦相逢:BAAAKgADCggICAAAAA==.',['诗画']='诗画相逢:BAABKgAFFH8HAAMGAAQIIiPSHQAYAQAGAAQIIiPSHQAYAQAFAAMIwwdYOQCRAAAAAA==.',['谜橙']='谜橙:BAAAKgAECgEIAQABKgAFFAEIBAATAAAAAA==.',['貓蘇']='貓蘇:BAAAKgAFFAEIAwAAAA==.',['貝吉']='貝吉塔:BAABKgAFFH8OAAIGAAYIMhqgDgCKAQAGAAYIMhqgDgCKAQAAAA==.',['赏金']='赏金狩猎者:BAABKgAECn8VAAIGAAgI1xsWKAASAgAGAAgI1xsWKAASAgAAAA==.',['赛凡']='赛凡堤斯:BAAAKgAECgUIBQAAAA==.',['赤色']='赤色冲击:BAAAKgAECgUIBQAAAA==.',['赫敏']='赫敏格兰杰:BAAAKgAECggIDwAAAA==.',['起手']='起手消失:BAAAKgAFFAgIAwAAAA==.',['轩辕']='轩辕筱猎:BAABKgAECn8dAAIGAAgIuhL8dQBSAQAGAAgIuhL8dQBSAQAAAA==.',['达斯']='达斯摩尔:BAAAKgAECggICAAAAA==.',['达纳']='达纳斯小贩:BAAAKgAFFAYIAgABKgAFFAgIIQAQAP4VAA==.',['还听']='还听晚安吗:BAAAKgADCgQIBAAAAA==.',['迪托']='迪托马斯:BAAAKgADCgcICgABKgADCggICwATAAAAAA==.',['迷之']='迷之圣骑:BAAAKgADCgcIBwAAAA==.',['邪惡']='邪惡小布点:BAABKgAFFH8IAAILAAgIzgzUCQDdAQALAAgIzgzUCQDdAQAAAA==.',['郑丶']='郑丶小钱:BAAAKgADCggICgAAAA==.',['郗尔']='郗尔瓦纳斯:BAACKgAFFH8MAAIFAAgIeRZ9BQAIAgAFAAgIeRZ9BQAIAgAqAAQKfxQAAgYACAiYGElMAM4BAAYACAiYGElMAM4BAAAA.',['酸辣']='酸辣土豆奈斯:BAABKgAFFH8GAAIFAAYIUhQXFABCAQAFAAYIUhQXFABCAQAAAA==.',['银色']='银色战壕:BAAAKgAFFAYIBAAAAA==.',['长崎']='长崎素世:BAABKgAFFH8NAAMcAAgIdhSRBAD4AQAcAAcIVheRBAD4AQAZAAYIwQR0EwAnAQAAAA==.',['长谷']='长谷川:BAAAKgADCgEIAQAAAA==.',['闪电']='闪电哈士奇:BAAAKgAFFAYIAwAAAA==.',['闪闪']='闪闪惹人哎:BAAAKgAECggICAAAAA==.闪闪电阿:BAAAKgADCgEIAQAAAA==.',['阿兰']='阿兰娜逐星:BAAAKgAECggIDgAAAA==.',['阿弟']='阿弟打死:BAAAKgADCgEIAgAAAA==.',['阿莉']='阿莉希亚:BAAAKgAECggIDgAAAA==.',['陆玥']='陆玥:BAAAKgAECgQIBAAAAA==.',['随乄']='随乄缘:BAAAKgAECgEIAQAAAA==.',['随风']='随风潜入夜:BAAAKgADCggICAAAAA==.',['雨馨']='雨馨:BAAAKgAECgIIAgAAAA==.',['雪翼']='雪翼天使:BAAAKgADCggICAAAAA==.',['雲和']='雲和山的彼端:BAACKgAFFH8LAAIMAAMIwATrMwCRAAAMAAMIwATrMwCRAAAqAAQKfxsAAgwACAj9DqODAEcBAAwACAj9DqODAEcBAAAA.',['電飛']='電飛鼠丶:BAAAKgADCgYIBgAAAA==.',['霸者']='霸者的小黄花:BAAAKgADCggICAAAAA==.',['青枫']='青枫:BAACKgAFFH8hAAIGAAQI6yKyEgACAQAGAAQI6yKyEgACAQAqAAQKfx0AAgYACAhzIlIoAFICAAYACAhzIlIoAFICAAAA.',['静谧']='静谧丶聖堂:BAAAKgADCgcIBwAAAA==.静谧夜枫:BAAAKgAECgEIAQAAAA==.',['非常']='非常无姜君:BAABKgAFFH8IAAIaAAQIDxgYGwDlAAAaAAQIDxgYGwDlAAAAAA==.',['非洲']='非洲煤矿工人:BAAAKgAECgYICAAAAA==.',['顺势']='顺势:BAABKgAFFH8RAAIGAAgIlx71BABVAgAGAAgIlx71BABVAgAAAA==.',['顺水']='顺水:BAABKgAFFH8IAAIHAAYIaA4mHgAsAQAHAAYIaA4mHgAsAQAAAA==.',['风中']='风中一粒雪:BAAAKgAECgMIAwAAAA==.',['风之']='风之影傲雪:BAAAKgAFFAQIBAAAAA==.',['风云']='风云小二:BAAAKgAECgMIAwAAAA==.',['风暴']='风暴英雄周卓:BAAAKgAECgcIEgAAAA==.',['风火']='风火雷电土:BAAAKgAECgYIBgAAAA==.',['飞天']='飞天小狐狸:BAABKgAFFH8JAAMXAAYI3QsmCwAOAQAXAAYI3QsmCwAOAQAWAAMIogaJBwCHAAAAAA==.',['香蕉']='香蕉大王:BAAAKgAECggIEAAAAA==.',['马保']='马保国:BAAAKgAECgUICQAAAA==.',['骑小']='骑小德带萨满:BAAAKgAECgYICgAAAA==.',['骑马']='骑马遊北極:BAAAKgADCggICAAAAA==.',['高德']='高德地途:BAAAKgAECgEIAQAAAA==.',['魅兰']='魅兰:BAAAKgAECgcIDgAAAA==.',['魅森']='魅森:BAAAKgAECgIIAgAAAA==.',['魔牙']='魔牙口牙:BAAAKgAECgMIAwAAAA==.',['鲇川']='鲇川天理:BAAAKgAECggIEQAAAA==.',['鲨鱼']='鲨鱼:BAAAKgAECgIIAgAAAA==.',['麦亚']='麦亚糖:BAAAKgAECgYIDgAAAA==.',['麦斯']='麦斯米科尔森:BAAAKgAECgQIBAAAAA==.',['黄色']='黄色的西瓜:BAABKgAECn8YAAQCAAgI1BlrFgDfAQACAAgIWRhrFgDfAQAiAAgImAiuGgBWAQAjAAYIghN6DgABAQAAAA==.',['黄金']='黄金神斗士:BAAAKgADCggICwAAAA==.',['黑色']='黑色的西瓜:BAABKgAECn8XAAMWAAgInB2cCQDMAQAWAAgIsBycCQDMAQAkAAEIlyHuIwBkAAABKgAFFAgICAACAMYWAA==.',['黑黑']='黑黑珍珠:BAAAKgADCgIIAgAAAA==.',['龙之']='龙之力量:BAAAKgAECgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end