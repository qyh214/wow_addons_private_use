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
 local lookup = {'Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Rogue-Assassination','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Frost','Mage-Frost','Mage-Arcane','Warlock-Affliction','Warlock-Destruction','Warrior-Fury','Priest-Holy','Priest-Shadow','Druid-Restoration','Warrior-Protection','Paladin-Protection','Warlock-Demonology','Warrior-Arms','Shaman-Elemental','DeathKnight-Unholy','Paladin-Holy','Rogue-Outlaw',}; local provider = {region='CN',realm='库尔提拉斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aipplenn:BAAALAAECgIIAgAAAA==.',An='Angeltodevil:BAABLAAFFH8KAAIBAAYIzReBEgC0AQABAAYIzReBEgC0AQAAAA==.',Ao='Aotoman:BAABLAAECn8YAAMCAAcIBh4NMAD8AQACAAcI+R0NMAD8AQADAAYI0hBGZgAqAQAAAA==.',Ar='Arturiasaber:BAAALAAECgIIAgAAAA==.',As='Ashelydu:BAAALAAECgYIBgAAAA==.',At='Atheneminerv:BAAALAADCgMIAwAAAA==.',Av='Avbox:BAAALAAFFAIIBAAAAA==.',De='Demoncheater:BAAALAAECgYIBgAAAA==.',Du='Duang:BAAALAAECgYIEgAAAA==.',Ec='Ecthelion:BAAALAAECgYICgAAAA==.',El='Elainè:BAAALAAECgYICgAAAA==.Elainé:BAABLAAECn8ZAAIBAAYIUB1OcgAFAgABAAYIUB1OcgAFAgAAAA==.',Hu='Hui:BAAALAAECgYIBwAAAA==.',Jn='Jnkdog:BAAALAADCggICAAAAA==.',Jo='Joe:BAAALAAECgQIBQAAAA==.',Ki='Kira:BAAALAAECgMIAwAAAA==.',Ku='Kukunat:BAABLAAFFH8cAAIEAAYI5SLfBQDkAQAEAAYI5SLfBQDkAQAAAA==.',La='Lastforone:BAABLAAFFH8LAAICAAYInh6ZGgDKAQACAAYInh6ZGgDKAQABLAAFFAgIDAACACgbAA==.',Mo='Moonbaby:BAAALAADCgIIAwAAAA==.',Sa='Saudiwolf:BAABLAAECn8YAAIFAAYIUBZ8DwBsAQAFAAYIUBZ8DwBsAQAAAA==.',Se='Seirios:BAAALAAECgEIAQAAAA==.Seize:BAAALAADCggIEAAAAA==.',Sh='Shiracchi:BAAALAADCgcIBwAAAA==.',Sm='Smilee:BAACLAAFFH8MAAIGAAIIEyMXJgDHAAAGAAIIEyMXJgDHAAAsAAQKfxQAAwYABwhzIVBCAFsCAAYABgjSIlBCAFsCAAcAAQg4GfljAEAAAAAA.',Sz='Sznbrr:BAAALAADCgMIAwAAAA==.',Th='Theshy:BAAALAAECgUIBQAAAA==.',Vi='Viviby:BAAALAAECgcICAAAAA==.',Ze='Zeparbob:BAAALAAECgEIAQAAAA==.Zeparkok:BAAALAAFFAEIAQAAAA==.',['一心']='一心寂一:BAAALAAECgMIAwAAAA==.',['一首']='一首凉凉:BAAALAAECgMIAwAAAA==.',['三野']='三野个蛋:BAAALAAECgQIBAAAAA==.',['不加']='不加外求:BAAALAAFFAEIAQAAAA==.',['与风']='与风为友:BAAALAAECgYIBgAAAA==.',['丑弋']='丑弋:BAAALAAECgYIBgAAAA==.',['世纪']='世纪末魔术师:BAAALAAECgEIAQAAAA==.',['临渊']='临渊:BAAALAAFFAIIAgAAAA==.',['丶柒']='丶柒染:BAAALAAECgYIBgAAAA==.',['云玫']='云玫:BAAALAAFFAIIBAAAAA==.',['亚巴']='亚巴顿:BAABLAAECn8UAAIIAAgITxOT0gB/AQAIAAgITxOT0gB/AQAAAA==.',['享受']='享受阳光:BAAALAAECgMIAwAAAA==.',['仙劍']='仙劍堂凝:BAAALAAFFAYIAwAAAA==.',['优雅']='优雅的小主:BAAALAAFFAIIAwAAAA==.',['依恋']='依恋幸福:BAAALAAFFAIIBAAAAA==.',['倾城']='倾城:BAAALAAECgYIEQAAAA==.',['傻傻']='傻傻發槑:BAAALAAECgcICQAAAA==.',['元素']='元素小龙:BAABLAAECn8VAAMJAAYIZwUmcQCoAAAJAAUI+QUmcQCoAAAKAAEIjgIqfAAVAAAAAA==.',['光博']='光博士:BAACLAAFFH8VAAMLAAUIkRBDBACWAAAMAAUIkRBEOwAaAQALAAIIwgtDBACWAAAsAAQKfxQAAwwABgj0HQArAKcBAAwABgi+HQArAKcBAAsABQgkFFsZADsBAAAA.',['八加']='八加壹:BAAALAAECgYIDwAAAA==.',['八极']='八极小狂风:BAABLAAFFH8HAAIIAAQI/Q2eTwDhAAAIAAQI/Q2eTwDhAAAAAA==.',['八爪']='八爪章鱼猫:BAAALAAECgYIBgAAAA==.',['冷冰']='冷冰冰:BAAALAAECgYIDAAAAA==.',['凉月']='凉月风夕:BAAALAAECgUIBQAAAA==.',['剑聖']='剑聖:BAABLAAFFH8IAAINAAIIzRotOQCVAAANAAIIzRotOQCVAAABLAAFFAMIDQAIAM4YAA==.',['千早']='千早愛音:BAAALAAECggIDgAAAA==.',['千面']='千面盗:BAAALAAECgYIBgAAAA==.',['半山']='半山溪如雨:BAACLAAFFH8PAAMOAAIIERqxNACTAAAOAAIIERqxNACTAAAPAAII+hKHJgBLAAAsAAQKfysAAw4ABwjNHz0RAEkCAA4ABwjNHz0RAEkCAA8ABwikGE44AOABAAAA.',['卡拉']='卡拉赞的祝福:BAAALAAECgcIEwAAAA==.',['双刃']='双刃:BAAALAAECgMIAwAAAA==.',['发呆']='发呆就好:BAAALAADCgIIAgAAAA==.发呆的骑士:BAABLAAFFH8FAAIBAAUIHwxbLQAbAQABAAUIHwxbLQAbAQAAAA==.',['名字']='名字好难起:BAAALAAECgYIEQAAAA==.',['吱之']='吱之吱:BAACLAAFFH8hAAIBAAYIhxzhFQCgAQABAAYIhxzhFQCgAQAsAAQKfyYAAgEACAhkIRQhAO0CAAEACAhkIRQhAO0CAAAA.',['呆呆']='呆呆的望着天:BAAALAADCgMIAwAAAA==.',['周六']='周六阿哥:BAAALAADCgEIAQAAAA==.',['咿呀']='咿呀哈:BAAALAAFFAIIBAAAAA==.',['喀邱']='喀邱莎:BAAALAAECgYIBwAAAA==.',['嗯我']='嗯我很好:BAAALAADCgEIAQAAAA==.',['囚之']='囚之寒月:BAABLAAFFH8GAAIQAAIIVRsrNACZAAAQAAIIVRsrNACZAAAAAA==.',['圣武']='圣武:BAAALAADCgYIBgAAAA==.',['圣灵']='圣灵沨:BAAALAAECgYIBgAAAA==.',['地狱']='地狱葬歌:BAAALAAECgYIBgAAAA==.',['坏孩']='坏孩子:BAAALAAECgYIDQAAAA==.',['夏多']='夏多雷之刃:BAAALAAFFAIIAgAAAA==.',['夙願']='夙願:BAAALAAECgYIBgAAAA==.',['夜的']='夜的宁静:BAAALAAECgUIBQAAAA==.',['大侠']='大侠:BAAALAAECgQIBAAAAA==.',['大师']='大师兄:BAAALAAECggIBQAAAA==.',['天启']='天启丶:BAAALAAFFAQIBAAAAA==.',['天堂']='天堂梦影:BAABLAAFFH8KAAIMAAYIBAiaOAAqAQAMAAYIBAiaOAAqAQAAAA==.',['失色']='失色季莭:BAAALAAECgEIAQAAAA==.',['奈斯']='奈斯型队友:BAABLAAFFH8KAAIQAAYIGw7oGABoAQAQAAYIGw7oGABoAQAAAA==.',['奥菲']='奥菲迩:BAAALAADCgcIBwAAAA==.',['好孕']='好孕:BAACLAAFFH8OAAIFAAIIExqGGQCaAAAFAAIIExqGGQCaAAAsAAQKfyIAAgUACAiYHNMFACwCAAUACAiYHNMFACwCAAAA.',['媽媽']='媽媽:BAABLAAFFH8cAAMNAAYI6B9XDQDvAQANAAYI/x5XDQDvAQARAAIIVRniIgB4AAAAAA==.',['孤鸦']='孤鸦:BAAALAADCgMIAwAAAA==.',['孩哥']='孩哥:BAAALAAECgUIBQAAAA==.',['寂寞']='寂寞放逐:BAABLAAFFH8IAAMBAAYIDQVXLgATAQABAAYIDQVXLgATAQASAAIIWgeMHQBmAAAAAA==.',['寒露']='寒露丶:BAABLAAFFH8mAAICAAYIICO+DwAMAgACAAYIICO+DwAMAgAAAA==.',['小地']='小地主:BAAALAAECgYIDgAAAA==.',['小猪']='小猪一佩奇:BAAALAAECgYIBgAAAA==.',['小盒']='小盒里的精灵:BAAALAAFFAIIAgAAAA==.',['小笨']='小笨熊:BAABLAAFFH8MAAIQAAIIWx59NgCQAAAQAAIIWx59NgCQAAAAAA==.',['小红']='小红手法師:BAAALAAECgYIDAAAAA==.',['小胡']='小胡纸先生:BAAALAAECgEIAQAAAA==.',['小蹄']='小蹄子一腾:BAAALAAECgQIBAAAAA==.',['崖叶']='崖叶的今天:BAAALAAFFAQIAgAAAA==.',['嶵兒']='嶵兒:BAAALAAECgIIAQAAAA==.',['彩色']='彩色雪花:BAABLAAECn8ZAAIBAAgIBBB5UwBlAQABAAgIBBB5UwBlAQAAAA==.',['得瑟']='得瑟猫:BAAALAAECgEIAQAAAA==.',['心寂']='心寂丶:BAAALAAECgYIBgAAAA==.',['恶魔']='恶魔不落泪:BAAALAAFFAIIAgAAAA==.恶魔精灵:BAAALAAECgYIBgAAAA==.恶魔起飞:BAAALAAECgYIBgAAAA==.',['戍侍']='戍侍:BAAALAADCgQIBAAAAA==.',['把苹']='把苹果咬哭:BAAALAAECgcIEwAAAA==.',['挚丶']='挚丶情:BAAALAAECgQIBAAAAA==.',['挚情']='挚情:BAAALAAECgYIDAAAAA==.',['掉了']='掉了颗螺丝:BAAALAAECgMIAwAAAA==.',['摇摆']='摇摆摇摆:BAACLAAFFH8GAAINAAIIdAyjTwBEAAANAAIIdAyjTwBEAAAsAAQKfxgAAg0ACAhuGXoVADYCAA0ACAhuGXoVADYCAAAA.',['斩鬼']='斩鬼:BAAALAAECgYICAAAAA==.',['旋风']='旋风可达鸭:BAAALAADCgIIAgAAAA==.',['无敌']='无敌大拿:BAAALAAECgUIBQAAAA==.',['无穷']='无穷小亮:BAAALAAFFAIIBAAAAA==.',['无聊']='无聊到处逛逛:BAAALAAFFAIIAgAAAA==.无聊的鱼:BAAALAAFFAIIBAAAAA==.',['日暮']='日暮秋风起:BAAALAAECgMIAwAAAA==.',['旺仔']='旺仔奶牛:BAAALAADCgMIAwAAAA==.',['星海']='星海传奇:BAAALAAECgYIEQAAAA==.',['星空']='星空林地:BAAALAAFFAIIAgAAAA==.',['星贯']='星贯虹月:BAAALAAECgYIBgAAAA==.',['是小']='是小染尘吧:BAAALAAFFAIIAgAAAA==.是小染尘呀:BAABLAAFFH8HAAMTAAMIGiCxCgBuAAATAAIInySxCgBuAAAMAAEIEBemWgBQAAABLAAFFAgIDgATAMkdAA==.是小染尘呢:BAABLAAFFH8GAAMUAAII5gc5BgA4AAAUAAII5gc5BgA4AAANAAIIPAPTYQAvAAAAAA==.是小染尘哈:BAAALAAFFAIIBAAAAA==.',['暗夜']='暗夜游侠:BAAALAAFFAQIBAAAAA==.',['暗辉']='暗辉:BAAALAAECgMIAwAAAA==.',['暮色']='暮色瑟瑟:BAAALAAECgYICQAAAA==.',['暴怒']='暴怒的黑暗:BAAALAADCgYIBgAAAA==.',['月色']='月色如华:BAAALAAFFAMIBAAAAA==.',['杨杨']='杨杨爱吃草:BAAALAAFFAIIBAAAAA==.',['极乐']='极乐净土:BAAALAAECgQIBAAAAA==.',['林慕']='林慕儿:BAAALAADCggICAAAAA==.',['果果']='果果吃了糖:BAAALAADCgEIAQAAAA==.',['梅兹']='梅兹尔一克瑞:BAAALAADCgEIAQAAAA==.',['梦书']='梦书:BAAALAAECgIIAgAAAA==.',['橙色']='橙色预警:BAAALAAFFAIIAgAAAA==.',['欧皇']='欧皇的蔑视:BAAALAADCgIIAwAAAA==.',['欧盟']='欧盟:BAABLAAFFH8JAAMDAAYI8QsbDQAaAQADAAQI1A4bDQAaAQACAAMIxwZhTQCYAAAAAA==.',['武灬']='武灬罪:BAAALAAECggICAAAAA==.',['武越']='武越:BAAALAAECgEIAQAAAA==.',['死亡']='死亡大领主:BAABLAAFFH8PAAIIAAgIKCHgAwBqAgAIAAgIKCHgAwBqAgAAAA==.',['毛毛']='毛毛子:BAAALAAECgQIBAAAAA==.',['沐丶']='沐丶清:BAABLAAECn8WAAIBAAgIBA8dSgB+AQABAAgIBA8dSgB+AQAAAA==.',['沐彡']='沐彡雨:BAAALAAECgIIAgAAAA==.',['沐灬']='沐灬清:BAABLAAECn8xAAIJAAgIJBsUCwALAgAJAAgIJBsUCwALAgAAAA==.',['洛羽']='洛羽殇:BAAALAADCggICAAAAA==.',['洳淉']='洳淉呮湜冋忆:BAAALAADCgUIBAAAAA==.',['流年']='流年岁影:BAAALAAECgIIAgAAAA==.',['浪浪']='浪浪山小妖精:BAAALAADCgIIAgAAAA==.',['清新']='清新的汪汪儿:BAABLAAFFH8MAAMIAAYIDhtyIQCuAQAIAAYIzRlyIQCuAQAEAAYIFRPcCwBPAQABLAAFFAgIGAAIAOwWAA==.',['清风']='清风之牧:BAAALAADCggICAAAAA==.',['灬宝']='灬宝宝灬:BAAALAAECgYIBgAAAA==.',['灬小']='灬小趴菜:BAAALAAFFAIIAgAAAA==.',['灰烬']='灰烬游侠:BAABLAAFFH8JAAMDAAYIQxvvAwD6AQADAAYIjhnvAwD6AQACAAMIABEtJQDoAAAAAA==.',['烈阳']='烈阳:BAAALAAECgYIBgAAAA==.',['無畏']='無畏:BAAALAAECggIDQAAAA==.',['然也']='然也然也:BAAALAAECggIBwAAAA==.',['爻灬']='爻灬看你妹:BAAALAADCgQIBwAAAA==.',['牧濑']='牧濑红莉栖丶:BAAALAAFFAIIBAABLAAFFAIIDwAOABEaAA==.',['特别']='特别色:BAAALAAECgYIBgAAAA==.',['狂战']='狂战:BAAALAAECgIIAgAAAA==.',['狂暴']='狂暴怪人:BAAALAAECgYIBgAAAA==.',['狐仙']='狐仙人:BAAALAAECgEIAQAAAA==.',['狐嘚']='狐嘚嘚:BAAALAADCgIIAgAAAA==.',['狐狸']='狐狸:BAAALAAFFAIIAgAAAA==.',['猎杀']='猎杀武神:BAAALAAECgUIBQAAAA==.',['猫鲨']='猫鲨:BAAALAAECgcIEwABLAAFFAIIDwAOABEaAA==.',['电锯']='电锯猫:BAAALAADCgEIAQAAAA==.',['石秀']='石秀:BAAALAADCgIIAgAAAA==.',['神圣']='神圣小混混:BAABLAAFFH8PAAIBAAMICRYxOwCqAAABAAMICRYxOwCqAAAAAA==.',['神奇']='神奇的东:BAAALAAECgQIBAAAAA==.',['笨牛']='笨牛牛:BAAALAAECgYIBgAAAA==.',['简墨']='简墨:BAAALAAFFAgIAgAAAA==.',['糖沫']='糖沫沫:BAACLAAFFH8GAAIVAAIIAwXVOQBlAAAVAAIIAwXVOQBlAAAsAAQKfxQAAhUABwiODW5mAIYBABUABwiODW5mAIYBAAAA.',['索马']='索马里悍匪:BAAALAAECgYIBgAAAA==.',['絕版']='絕版殺手:BAABLAAECn8bAAMEAAYILh26GQDNAQAEAAYIIBq6GQDNAQAWAAYIExsyJACbAQAAAA==.',['纯黑']='纯黑的天空:BAABLAAFFH8GAAIGAAYINw3jIgBxAQAGAAYINw3jIgBxAQAAAA==.',['罗小']='罗小黑:BAACLAAFFH8eAAMDAAYIExkyBwBXAQADAAYIqBEyBwBXAQACAAQIOB7bVgDxAAAsAAQKfxwAAwIABgjeJPc5AHgCAAIABgjeJPc5AHgCAAMABggHIRYnADkCAAAA.',['罗最']='罗最帅:BAACLAAFFH8WAAIBAAUIpBuoIwBSAQABAAUIpBuoIwBSAQAsAAQKfxQAAgEABgiHIQkxAM4BAAEABgiHIQkxAM4BAAAA.',['罗真']='罗真帅:BAABLAAFFH8ZAAIKAAYIWh6IGAC8AQAKAAYIWh6IGAC8AQAAAA==.',['自由']='自由灬如风:BAAALAAECgIIAgAAAA==.',['莫问']='莫问:BAAALAADCgIIAgAAAA==.',['菊花']='菊花神:BAABLAAFFH8IAAIXAAgIKgoeEQB1AQAXAAgIKgoeEQB1AQAAAA==.',['菜德']='菜德一匹:BAAALAADCggICAAAAA==.',['落花']='落花葬青草:BAAALAAECgYIEwAAAA==.',['蒲公']='蒲公英的旅行:BAAALAAFFAIIAgAAAA==.',['薇薇']='薇薇安:BAAALAAECgEIAQAAAA==.',['蛇蛇']='蛇蛇的龙龙:BAAALAAECggICAAAAA==.',['袅熊']='袅熊:BAAALAAECgYIBgAAAA==.',['许坚']='许坚许坚:BAABLAAFFH8IAAIGAAIIEhPVQwCWAAAGAAIIEhPVQwCWAAAAAA==.',['许爽']='许爽:BAABLAAFFH8IAAIUAAgIpAL7BgAdAAAUAAgIpAL7BgAdAAAAAA==.',['贾小']='贾小鬼:BAAALAAECgUIBQAAAA==.',['輪廻']='輪廻:BAACLAAFFH8KAAIBAAIIEQ17gAAtAAABAAIIEQ17gAAtAAAsAAQKfzYAAwEACAiqFcszAMQBAAEACAiqFcszAMQBABIABQgNCBstALYAAAAA.',['迎男']='迎男而上:BAACLAAFFH8HAAIBAAMIQxJgRwB9AAABAAMIQxJgRwB9AAAsAAQKfxoAAgEACAhcHusVAF4CAAEACAhcHusVAF4CAAAA.',['迷城']='迷城再见你:BAABLAAFFH8IAAIGAAMItBR5OwCdAAAGAAMItBR5OwCdAAAAAA==.',['逍遥']='逍遥:BAAALAAECgYIBgAAAA==.',['過璐']='過璐鬼毛毛:BAAALAADCgcIBwAAAA==.',['邪门']='邪门歪盗:BAAALAAECgMIAwAAAA==.',['酷宝']='酷宝贝:BAAALAAECgYIDAAAAA==.',['铁血']='铁血力劈:BAAALAADCgIIAgAAAA==.',['铃屋']='铃屋什造:BAAALAAECgEIAQAAAA==.',['闪电']='闪电一号:BAAALAAECgYIDwAAAA==.闪电雷鸣:BAAALAADCgUIBQAAAA==.',['闭家']='闭家锁:BAABLAAFFH8GAAIGAAIIgw5wVQBGAAAGAAIIgw5wVQBGAAAAAA==.',['阳刃']='阳刃:BAAALAADCgMIAwAAAA==.',['阿姨']='阿姨丶:BAABLAAFFH8nAAIGAAYIdCBiEQDWAQAGAAYIdCBiEQDWAQAAAA==.',['阿寳']='阿寳丶:BAABLAAFFH8jAAMYAAYI0SDLAgDQAAAFAAQIURzhDQAuAQAYAAMI8iDLAgDQAAAAAA==.',['雪风']='雪风号驱逐舰:BAAALAAECgMIBQAAAA==.',['雲中']='雲中猎:BAABLAAECn8ZAAMCAAgI0hLwiwA2AQACAAgIgBLwiwA2AQADAAYIpwsYeQDxAAAAAA==.',['霜羽']='霜羽风舞:BAAALAADCgIIAgAAAA==.',['霜袶']='霜袶丶:BAABLAAFFH8cAAIIAAYIOSVXDQApAgAIAAYIOSVXDQApAgAAAA==.',['颓废']='颓废小狼:BAAALAAECgYICwAAAA==.',['颗粒']='颗粒丝王:BAAALAAECgIIAgAAAA==.',['风尘']='风尘筱筱:BAAALAADCggICAAAAA==.',['风暴']='风暴使者:BAAALAAECgYICgAAAA==.',['风蓝']='风蓝之星:BAAALAADCgcIDgAAAA==.',['飛妳']='飛妳丶吥娶:BAAALAADCgMIAwAAAA==.',['飛華']='飛華雪:BAABLAAECn8dAAMJAAYIXBXQOwCDAQAJAAYIXBXQOwCDAQAKAAYIXgzIowA/AQAAAA==.',['飛雪']='飛雪蕭熙:BAAALAAECgYICgAAAA==.',['飞天']='飞天德:BAAALAAECgYICAAAAA==.飞天蟑螂:BAAALAADCgMIAwAAAA==.',['鬼火']='鬼火摩托:BAAALAAECggICAAAAA==.',['鬼迷']='鬼迷心竅:BAABLAAFFH8GAAIKAAYIyBQIKwBlAQAKAAYIyBQIKwBlAQAAAA==.',['魉忽']='魉忽:BAAALAADCgMIAwAAAA==.',['魔玲']='魔玲:BAAALAAECgYIBgAAAA==.',['鹅哥']='鹅哥:BAAALAAFFAIIAwAAAA==.',['黑暗']='黑暗猎魔:BAACLAAFFH8JAAICAAMI8guNfABfAAACAAMI8guNfABfAAAsAAQKfxsAAgIABgg0FPeSACwBAAIABgg0FPeSACwBAAAA.',['黑焰']='黑焰:BAAALAAECgYIBgAAAA==.',['黑骑']='黑骑牛牛:BAAALAAECgYIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end