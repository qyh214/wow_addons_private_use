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
 local lookup = {'Hunter-BeastMastery','DeathKnight-Blood','DeathKnight-Frost','Warrior-Fury','Druid-Restoration','Paladin-Protection','DemonHunter-Vengeance','Shaman-Elemental','Hunter-Marksmanship','Paladin-Retribution','Shaman-Restoration','Paladin-Holy','Evoker-Augmentation','Evoker-Preservation','Druid-Balance','Priest-Holy','Rogue-Assassination','DemonHunter-Havoc','Warrior-Arms','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Warlock-Demonology','Hunter-Survival','Mage-Arcane','Druid-Guardian','Warrior-Protection','Mage-Frost','Warlock-Destruction','Rogue-Subtlety','DeathKnight-Unholy','Priest-Shadow','Evoker-Devastation',}; local provider = {region='CN',realm='达尔坎',name='CN',type='weekly',zone=44,date='2025-12-08',data={Al='Alr:BAAALAAFFAIIBAAAAA==.',At='Atone:BAAALAAECgQIBwAAAA==.',Bl='Bloodthirst:BAAALAADCgEIAQAAAA==.',Ci='Ciao:BAABLAAFFH8FAAIBAAMIUw5PdwByAAABAAMIUw5PdwByAAAAAA==.',Cu='Cuteyili:BAAALAAECgIIAgAAAA==.',De='Dermi:BAABLAAFFH8GAAICAAIIMQV0FQBhAAACAAIIMQV0FQBhAAAAAA==.',Ds='Dsanend:BAAALAADCgEIAQAAAA==.',Fo='Foxsay:BAAALAADCgcIBwAAAA==.',Gr='Grimdd:BAAALAAECgYIBgAAAA==.',Hy='Hyzmage:BAAALAAECgYIBwAAAA==.',Ka='Kaede:BAABLAAFFH8LAAIBAAIIBhE2lgBDAAABAAIIBhE2lgBDAAAAAA==.',Ke='Kelante:BAAALAADCgYIBgAAAA==.',Ku='Kumashi:BAABLAAFFH8GAAIBAAIIoR5NNQC5AAABAAIIoR5NNQC5AAAAAA==.',Ky='Kyrin:BAAALAAFFAIIAgAAAA==.',La='Laferrari:BAAALAAFFAIIBAAAAA==.Lanfe:BAAALAADCggICAAAAA==.',Lo='Lono:BAAALAAFFAIIBAAAAA==.',Lr='Lrida:BAACLAAFFH82AAMDAAcICSbZBQCjAgADAAcICSbZBQCjAgACAAEIKAkDGQAzAAAsAAQKfywAAwMABwgbJrYcAP0CAAMABwgbJrYcAP0CAAIAAQh/Fm5LADwAAAAA.',Lu='Lulululo:BAABLAAFFH8FAAIBAAMIFwyjdgB0AAABAAMIFwyjdgB0AAAAAA==.',Me='Metri:BAAALAAECgIIAgAAAA==.',Mo='Monpetitchou:BAAALAAECgYIBgAAAA==.Monroe:BAAALAAECgYICgAAAA==.',My='Mycc:BAABLAAFFH8GAAIEAAIIIxChNACaAAAEAAIIIxChNACaAAAAAA==.',Na='Naomi:BAAALAADCgQIBAAAAA==.',Ob='Oberon:BAABLAAFFH8GAAIFAAII4wt+OgBlAAAFAAII4wt+OgBlAAAAAA==.',Pa='Paralyse:BAABLAAFFH8RAAIFAAgIQBDuDADsAQAFAAgIQBDuDADsAQAAAA==.',Pl='Playerhuwrbl:BAAALAAECgMIAwAAAA==.Playerjwlqmt:BAAALAADCggICAAAAA==.',Qs='Qsmm:BAABLAAFFH8GAAIGAAIIYwgEIAAsAAAGAAIIYwgEIAAsAAAAAA==.',Ra='Razghul:BAAALAADCgIIAgAAAA==.',Sc='Scathach:BAAALAADCgIIAgAAAA==.',Sq='Squirrel:BAAALAAECgUICAAAAA==.',Su='Sunsc:BAAALAADCgMIAwAAAA==.',Te='Teentine:BAAALAAECgYIEAAAAA==.',Tr='Trency:BAABLAAFFH8UAAIHAAMI1AFqEgBpAAAHAAMI1AFqEgBpAAABLAAFFAYIHQAHACsIAA==.',Tw='Twinklepanda:BAAALAADCgcIBwAAAA==.',Vt='Vturn:BAAALAAFFAIIAwAAAA==.',Wa='Walch:BAAALAAECgYIEgAAAA==.',Ye='Yeehaw:BAAALAAECgYIBgAAAA==.',Yo='Youyou:BAAALAADCgEIAQAAAA==.',['Ðm']='Ðmemory:BAABLAAFFH8GAAIIAAQIvAxWEwAtAQAIAAQIvAxWEwAtAQAAAA==.',['一万']='一万零二:BAABLAAFFH8IAAIFAAIIcRZ+PQB8AAAFAAIIcRZ+PQB8AAAAAA==.一万零五:BAAALAAECgcICQAAAA==.',['一则']='一则驴:BAAALAAECgYICAAAAA==.',['一只']='一只圣骑:BAAALAAECgYIBgAAAA==.一只棍棍:BAAALAAECgYIDQAAAA==.',['一嘀']='一嘀事丶都冇:BAAALAADCgIIAgAAAA==.',['一德']='一德天下丶:BAAALAAECgMIAwAAAA==.',['一杆']='一杆鱼叉猎:BAABLAAECn8XAAMJAAgIRx97GgCQAgAJAAgIRx97GgCQAgABAAII8BItcQFyAAAAAA==.',['一梦']='一梦:BAAALAADCgEIAQAAAA==.',['一笼']='一笼乌骨鸡:BAAALAAECgIIAgAAAA==.',['一转']='一转身的幸福:BAAALAADCgEIAQAAAA==.',['一队']='一队奶骑:BAAALAAECgcIDAAAAA==.',['七月']='七月在野:BAABLAAFFH8gAAIDAAYIfR9OHADHAQADAAYIfR9OHADHAQAAAA==.',['万事']='万事皆术:BAAALAADCgMIAwAAAA==.万事皆死骑:BAAALAAECgMIAwAAAA==.万事皆猎:BAAALAAECgQIBAAAAA==.万事皆相宜:BAAALAAECgYIBgAAAA==.万事皆萨:BAAALAAECgYICgAAAA==.万事皆贼:BAAALAADCgYIBgAAAA==.',['三星']='三星坏女人:BAAALAAECgcIBwAAAA==.',['上帝']='上帝猎无语:BAAALAAFFAIIBAAAAA==.上帝超无语:BAABLAAFFH8GAAMGAAIIpQzXHAAxAAAKAAIIMAqVUgCQAAAGAAIIpQzXHAAxAAAAAA==.',['专业']='专业萨爹:BAABLAAFFH8JAAILAAIIJCK4OwC2AAALAAIIJCK4OwC2AAAAAA==.',['世间']='世间温柔以待:BAAALAADCgYIBgAAAA==.',['丘比']='丘比特:BAAALAAECgIIAwAAAA==.',['丨吕']='丨吕小布丶:BAAALAAECgQIBAAAAA==.',['丨萌']='丨萌萌哒丨:BAAALAAFFAMIAwAAAA==.',['临沧']='临沧普洱茶:BAAALAAECggICAAAAA==.',['丶吟']='丶吟诗:BAAALAAECgYIDQAAAA==.',['丶小']='丶小红手:BAAALAAFFAQIBAAAAA==.',['丶菜']='丶菜菜丶:BAABLAAFFH8OAAIDAAIIVRiaVgCdAAADAAIIVRiaVgCdAAAAAA==.',['丿叶']='丿叶落知秋丶:BAAALAAECgYIBgAAAA==.',['丿灬']='丿灬流水:BAAALAAECgIIAgAAAA==.丿灬潺潺:BAAALAAECgYICQAAAA==.丿灬送葬者:BAABLAAFFH8GAAIEAAII4xXBSwBIAAAEAAII4xXBSwBIAAAAAA==.',['之琳']='之琳关:BAAALAADCgIIAgAAAA==.',['乌鸦']='乌鸦坐飞鸡:BAAALAAECgMIBQAAAA==.',['二少']='二少的剑:BAAALAAECgYIBgAAAA==.',['二狗']='二狗子三精:BAABLAAFFH8GAAIMAAYIKQcwFQA/AQAMAAYIKQcwFQA/AQAAAA==.',['云从']='云从龙:BAABLAAFFH8OAAMMAAIIHhuhGACcAAAMAAIIHhuhGACcAAAKAAIIpBN6YwBFAAAAAA==.',['五万']='五万多个萨满:BAAALAAECggICAAAAA==.',['五代']='五代天王:BAAALAAECgYIBgAAAA==.',['五码']='五码圣光:BAAALAAECgcIBwAAAA==.',['亦风']='亦风:BAAALAAECgYIBgAAAA==.',['人家']='人家好乖呀:BAAALAAFFAIIAgAAAA==.人家好白呀:BAAALAAFFAIIBAAAAA==.',['人生']='人生怎能无憾:BAAALAAECgYIBgAAAA==.',['什么']='什么人:BAAALAAFFAIIAgAAAA==.',['伊内']='伊内丝:BAAALAAECgQIBgAAAA==.',['伊萨']='伊萨奥拉丶:BAAALAAECgMIAwAAAA==.',['伊露']='伊露维塔:BAACLAAFFH8wAAMNAAcI0AmcBwApAQANAAYIGwmcBwApAQAOAAUIEg2QCQAgAQAsAAQKfywAAg4ABwgVGxQTAAQCAA4ABwgVGxQTAAQCAAAA.',['会飞']='会飞的牛奶:BAABLAAFFH8MAAMPAAYI0yF9AgBPAgAPAAYI0yF9AgBPAgAFAAIItQweQgBdAAAAAA==.',['佐曉']='佐曉忆:BAAALAAECgMIAwAAAA==.',['佛氏']='佛氏崇拜:BAAALAAFFAIIBAAAAA==.',['你在']='你在掩饰什么:BAAALAAECggICAABLAAFFAgIDAAMAKUUAA==.',['你的']='你的小老婆:BAAALAADCgYIBgAAAA==.',['佧佧']='佧佧羅特:BAAALAAECgIIAgAAAA==.',['佳能']='佳能照相机:BAABLAAFFH8FAAIKAAUIhxZxKgAvAQAKAAUIhxZxKgAvAQAAAA==.',['依咖']='依咖牧師妹:BAAALAAFFAMIBAAAAA==.',['依然']='依然坚挺:BAAALAAFFAIIBAAAAA==.',['倾城']='倾城小龙牧:BAABLAAFFH8pAAIQAAYIPSRQBgBpAgAQAAYIPSRQBgBpAgABLAAFFAgINAALALkiAA==.',['偏分']='偏分戴安娜:BAAALAAECgUIBQAAAA==.偏分朱莉叶:BAAALAAECgYICAAAAA==.偏分马卡龙:BAAALAAECgEIAQAAAA==.',['僷铯']='僷铯的帷幕:BAAALAADCgEIAQAAAA==.',['元素']='元素之友:BAAALAADCgIIAwAAAA==.',['兜兜']='兜兜有大锤:BAAALAAFFAMIAwAAAA==.',['八楼']='八楼小飞刀:BAAALAAECgYIBAABLAAFFAYIBgARAI8jAA==.',['六一']='六一儿童术:BAAALAAECgYIBgAAAA==.',['六樓']='六樓後座:BAAALAAECgYIDAAAAA==.',['六阳']='六阳:BAAALAAFFAIIAgAAAA==.',['兽性']='兽性天下:BAAALAADCgYIBgAAAA==.',['冚屲']='冚屲屲冚:BAAALAAECgQIBAAAAA==.',['冬瓜']='冬瓜茶:BAAALAAECgEIAQAAAA==.',['冰封']='冰封的心:BAAALAAECgYIBgAAAA==.',['冲钅']='冲钅丶:BAAALAAFFAIIAgAAAA==.',['冲锋']='冲锋帝:BAAALAAECgYIBgAAAA==.',['冷月']='冷月丶安魂师:BAAALAAFFAIIBAAAAA==.冷月丶送葬师:BAAALAAECgYIBgAAAA==.',['凄凌']='凄凌玉光:BAABLAAECn8fAAIDAAcIBBC0vQCbAQADAAcIBBC0vQCbAQAAAA==.',['凉风']='凉风青叶:BAAALAAECgYIBgAAAA==.',['凤橙']='凤橙鬼武者:BAAALAAECgQIBAAAAA==.',['凶飞']='凶飞杀手:BAAALAADCggICAAAAA==.',['出马']='出马仙:BAAALAAECgUIBQAAAA==.',['切茜']='切茜娅:BAABLAAECn8WAAIHAAYIjBpcDgBpAQAHAAYIjBpcDgBpAQAAAA==.',['创世']='创世神魔:BAAALAAECgMIAwAAAA==.',['初音']='初音芙兰:BAABLAAFFH8YAAISAAYISh5ZEQDYAQASAAYISh5ZEQDYAQAAAA==.',['刹霖']='刹霖:BAABLAAFFH8PAAIIAAMIeQrkOAB5AAAIAAMIeQrkOAB5AAAAAA==.',['劍闌']='劍闌珊:BAAALAAECgQIBAAAAA==.',['加特']='加特:BAAALAAECgYIBgAAAA==.',['劲仔']='劲仔老冰:BAAALAADCgcIBwAAAA==.',['劳资']='劳资蜀道伞:BAACLAAFFH8HAAIEAAMI4giwPgBuAAAEAAMI4giwPgBuAAAsAAQKfxoAAwQABwgWFgE6AHIBABMABwiwDvEVAIQBAAQABwjVFQE6AHIBAAAA.',['半瓶']='半瓶冰红茶:BAAALAAFFAIIAgAAAA==.',['华尔']='华尔街沃夫:BAAALAAECgYIDAAAAA==.',['单吊']='单吊一条:BAAALAAECgEIAQAAAA==.',['单手']='单手煎鸡蛋:BAAALAADCggICAAAAA==.',['占山']='占山丶太阳王:BAAALAAECgYICAAAAA==.占山丶牧:BAAALAAECgQIBAAAAA==.',['卡瑞']='卡瑞格丶风切:BAABLAAFFH8MAAILAAIIQA/mYABbAAALAAIIQA/mYABbAAAAAA==.',['卫星']='卫星定位:BAAALAAECgUIBQAAAA==.',['又鼬']='又鼬又有嘘蛆:BAAALAAECgYIDwAAAA==.',['叉烧']='叉烧熊:BAAALAADCgUIBwAAAA==.',['双之']='双之哀伤:BAAALAAFFAIIAgAAAA==.',['可爱']='可爱的小肥牛:BAAALAAECgcIBwAAAA==.',['右誓']='右誓:BAABLAAFFH8NAAISAAYIGwjjKgBAAQASAAYIGwjjKgBAAQAAAA==.',['吃过']='吃过饭了么:BAAALAAFFAIIAgAAAA==.吃过饭了吗:BAAALAADCgUIBQAAAA==.吃过饭了吧:BAAALAADCgcIBwAAAA==.吃过饭了哦:BAAALAAFFAIIAgAAAA==.吃过饭了没:BAAALAAECgEIAQAAAA==.',['吃面']='吃面要吃蒜:BAAALAAECgIIAgAAAA==.',['吉安']='吉安忒尼斯:BAAALAAECgQIBAAAAA==.',['吕阿']='吕阿牧:BAAALAAECgIIAgAAAA==.',['吖噗']='吖噗丷吖噗:BAABLAAECn8UAAIHAAcIZQjKPgDrAAAHAAcIZQjKPgDrAAAAAA==.',['君战']='君战:BAAALAADCgYIBgAAAA==.',['吾去']='吾去脱她依:BAAALAAECggICAAAAA==.',['吾叉']='吾叉叉:BAABLAAECn8VAAQUAAYIjhqpJgBuAQAUAAUIFhmpJgBuAQAVAAUIXRbeOQBVAQAWAAYIUwwaGADVAAAAAA==.',['呆呆']='呆呆灬萨满:BAABLAAFFH8GAAILAAQINQZXRgCUAAALAAQINQZXRgCUAAAAAA==.',['周星']='周星星:BAABLAAFFH8FAAMJAAIIPhNgKwBwAAAJAAIIygxgKwBwAAABAAEIZBGCiwA8AAAAAA==.',['咕咕']='咕咕不咕咕:BAACLAAFFH80AAMFAAcIBhzrCwD5AQAFAAcIBhzrCwD5AQAPAAUIQBA9GgAHAQAsAAQKfycAAgUABwiLIQsbAI0CAAUABwiLIQsbAI0CAAAA.',['咕拉']='咕拉索丶碎晶:BAAALAADCgMIAwAAAA==.',['哈喽']='哈喽凯蒂:BAAALAAECgYIBgAAAA==.',['哈基']='哈基汪:BAAALAAECgcIBwAAAA==.',['哒狙']='哒狙提子:BAAALAADCgQIBAAAAA==.',['唐吉']='唐吉坷德丶:BAAALAADCgIIAgAAAA==.',['唯爱']='唯爱伊伊:BAACLAAFFH8MAAIDAAII3AvBgACGAAADAAII3AvBgACGAAAsAAQKfxYAAgMABwjpE0nYAHgBAAMABwjpE0nYAHgBAAAA.',['唸风']='唸风语者:BAAALAAECgMIBgAAAA==.',['喜提']='喜提米翘:BAABLAAECn8UAAISAAYIgRpaLQClAQASAAYIgRpaLQClAQAAAA==.',['喝喝']='喝喝酒:BAAALAAECgYICwAAAA==.',['嗡嗡']='嗡嗡:BAAALAAECgYIBgAAAA==.',['嘟嘟']='嘟嘟哟嘟嘟:BAABLAAFFH8IAAIFAAIISQ1RSQBeAAAFAAIISQ1RSQBeAAAAAA==.',['嘿丶']='嘿丶蛋炒饭:BAAALAAECggIBAAAAA==.',['嚎尤']='嚎尤哽:BAAALAAECgUIBwAAAA==.',['困兽']='困兽之都:BAAALAADCgYIBgAAAA==.',['国产']='国产小可爱:BAABLAAFFH8IAAIBAAYIVxirZgCgAAABAAYIVxirZgCgAAAAAA==.',['圆球']='圆球坨坨:BAAALAAECgcICwAAAA==.',['土肥']='土肥圆:BAAALAAECgEIAQAAAA==.',['土豆']='土豆我地瓜:BAABLAAFFH8IAAIXAAIIhhwjEABMAAAXAAIIhhwjEABMAAAAAA==.',['土鳖']='土鳖:BAAALAAFFAIIAgAAAA==.',['圣叉']='圣叉叉:BAAALAAFFAQIBAAAAA==.',['坂井']='坂井泉水:BAAALAADCgYICQAAAA==.',['坤坤']='坤坤的篮球:BAAALAADCgYIBgAAAA==.',['垒岛']='垒岛叭紫:BAAALAAECgYIBwAAAA==.',['城墙']='城墙倒拐:BAAALAAFFAIIAgAAAA==.',['境静']='境静净:BAAALAAECgIIAgAAAA==.',['墨狸']='墨狸:BAAALAAECgMIAwAAAA==.',['壹箭']='壹箭彪血:BAABLAAFFH8PAAIBAAUI4A6dVwDyAAABAAUI4A6dVwDyAAAAAA==.',['夏天']='夏天大魔王:BAABLAAFFH8RAAIOAAgILwBdIgApAAAOAAgILwBdIgApAAAAAA==.',['夏季']='夏季丶巫羽:BAAALAAECgYIBwAAAA==.',['夏小']='夏小茶:BAAALAAECggICAAAAA==.',['夏纠']='夏纠结:BAABLAAECn8ZAAIMAAcIhBIMHABqAQAMAAcIhBIMHABqAQAAAA==.',['大吉']='大吉哥:BAAALAAECgEIAQAAAA==.',['大野']='大野熊:BAABLAAFFH8GAAIFAAIISgaSUgBQAAAFAAIISgaSUgBQAAAAAA==.',['大驹']='大驹驹:BAABLAAFFH8KAAIBAAIINR0XPgCpAAABAAIINR0XPgCpAAAAAA==.',['大魚']='大魚海苔丶:BAAALAAECgIIAgAAAA==.',['大鼻']='大鼻子王源:BAAALAAECgcIBwAAAA==.',['天宇']='天宇之心:BAABLAAFFH8OAAIGAAII5BM0GgA2AAAGAAII5BM0GgA2AAAAAA==.',['天才']='天才琪露諾:BAABLAAFFH8MAAMBAAUItxRNTgAYAQABAAUItxRNTgAYAQAYAAII8wrPBQCPAAAAAA==.',['天涯']='天涯丨炫血:BAAALAAECgYIEQAAAA==.',['天灾']='天灾骨钟:BAACLAAFFH8GAAIBAAIIYSA3fwBbAAABAAIIYSA3fwBbAAAsAAQKf1MAAgEACAhoINAYAGkCAAEACAhoINAYAGkCAAAA.',['天琴']='天琴雨:BAABLAAFFH8JAAIGAAIIfhAEGQB1AAAGAAIIfhAEGQB1AAAAAA==.',['天生']='天生就抗揍:BAABLAAFFH8FAAIFAAMIIBGpMQClAAAFAAMIIBGpMQClAAAAAA==.',['天神']='天神下凡:BAAALAAECggICAAAAA==.天神下瀿:BAAALAAECgUIBQAAAA==.',['太阳']='太阳王后:BAAALAAECgMIAwAAAA==.',['夯驴']='夯驴子:BAABLAAFFH8UAAIKAAUIZhdICwCyAQAKAAUIZhdICwCyAQAAAA==.',['夹急']='夹急夹急嘟喂:BAABLAAFFH8HAAIBAAYItxz1LwB6AQABAAYItxz1LwB6AQAAAA==.',['奇葩']='奇葩无极限:BAAALAAECgQIBAAAAA==.',['奈奈']='奈奈子丶:BAAALAAECgMIAwAAAA==.',['奧蕾']='奧蕾莉亚:BAABLAAFFH8GAAIJAAYIEQAWHgABAAAJAAYIEQAWHgABAAAAAA==.',['女骑']='女骑士:BAABLAAFFH8GAAIDAAIIXxAOjwA/AAADAAIIXxAOjwA/AAAAAA==.',['奶一']='奶一口没:BAAALAAECggIEAAAAA==.',['她不']='她不一样:BAAALAAFFAIIBAAAAA==.',['如丨']='如丨果:BAABLAAFFH8IAAILAAIIYhw2QgCgAAALAAIIYhw2QgCgAAAAAA==.',['姚江']='姚江寒:BAAALAAECgMIAwAAAA==.',['姬如']='姬如雪:BAAALAAECgYIBwAAAA==.',['姬莉']='姬莉丶哈泽尔:BAAALAAECgYIDAAAAA==.',['姬野']='姬野丶:BAAALAAECgYIBgAAAA==.',['威猛']='威猛的胸肌:BAAALAADCgEIAQAAAA==.',['威風']='威風堂堂:BAABLAAFFH8NAAIIAAYIzRLbGwBjAQAIAAYIzRLbGwBjAQAAAA==.',['宇宙']='宇宙骑士利盾:BAAALAAECgEIAQAAAA==.宇宙骑士利箭:BAABLAAFFH8KAAIZAAIIhh+aNQCzAAAZAAIIhh+aNQCzAAAAAA==.',['守心']='守心:BAAALAADCgQIBAABLAAFFAYIEgAPAHcSAA==.',['守护']='守护着物语:BAAALAAECgUIBQAAAA==.',['安之']='安之若:BAABLAAFFH8GAAIaAAII4gSKCwBWAAAaAAII4gSKCwBWAAAAAA==.',['宝宝']='宝宝德:BAAALAAECggICQAAAA==.',['寒霜']='寒霜雪:BAABLAAFFH8HAAICAAYINAENFwBUAAACAAYINAENFwBUAAAAAA==.',['小九']='小九儿:BAABLAAFFH8MAAIFAAYIVgsEIAAkAQAFAAYIVgsEIAAkAQAAAA==.',['小呀']='小呀:BAAALAAECgYIDwAAAA==.',['小嘴']='小嘴蘸了蜜:BAAALAAFFAIIAgAAAA==.',['小子']='小子够狠:BAAALAAECgYIDAAAAA==.',['小小']='小小菜鸟一只:BAAALAAECgYIBgAAAA==.',['小泽']='小泽又沐风:BAAALAAECggIDAAAAA==.',['小烟']='小烟凌:BAAALAAFFAIIAgABLAAFFAgICgAMAJ0LAA==.',['小生']='小生不才:BAAALAAFFAIIBAAAAA==.',['小米']='小米:BAAALAAFFAIIAgAAAA==.',['小红']='小红丶手:BAABLAAFFH8GAAISAAYICRatIwBvAQASAAYICRatIwBvAQAAAA==.',['小艳']='小艳玲:BAABLAAFFH8GAAIbAAIIYRMhLAA5AAAbAAIIYRMhLAA5AAAAAA==.',['小魔']='小魔头:BAAALAADCgEIAQAAAA==.',['少龄']='少龄萌主:BAAALAAECgIIAgAAAA==.',['尤古']='尤古朵拉:BAAALAAECgcIBwAAAA==.',['尼哥']='尼哥:BAAALAADCggICAAAAA==.',['屁屁']='屁屁也疯狂丶:BAABLAAFFH8GAAIcAAIIXRL4GAB1AAAcAAIIXRL4GAB1AAAAAA==.',['山鬼']='山鬼:BAAALAAFFAIIAwAAAA==.',['岁夜']='岁夜:BAAALAAECgEIAQAAAA==.',['巍戨']='巍戨:BAAALAAECgMIAwAAAA==.',['左左']='左左:BAABLAAECn8XAAIaAAcIixYsEgC4AQAaAAcIixYsEgC4AQAAAA==.',['左翼']='左翼麦哥:BAAALAAECgUICgAAAA==.',['巭乂']='巭乂羲:BAAALAAECgYIDwAAAA==.',['巴基']='巴基小狂风:BAAALAAECggIEAAAAA==.',['布兰']='布兰丶史塔克:BAAALAAECgIIAgAAAA==.',['布索']='布索匹灬拳须:BAAALAAFFAIIAgAAAA==.',['布莱']='布莱克麻吉酱:BAAALAAECgMIBgAAAA==.',['布鲁']='布鲁丶玛丽:BAAALAAECgIIAgAAAA==.',['帅帅']='帅帅小丑男:BAAALAADCgQIBAAAAA==.',['希尔']='希尔瓦纳斯:BAACLAAFFH8GAAMBAAUIlxTqSAArAQABAAUIlxTqSAArAQAJAAEIzgXwOAAzAAAsAAQKfyUAAgkACAg+IM8RANQCAAkACAg+IM8RANQCAAAA.',['帕克']='帕克丶:BAACLAAFFH8IAAIDAAIIyBaCUgCfAAADAAIIyBaCUgCfAAAsAAQKfxUAAwMACAgMF0ljAC8CAAMACAgMF0ljAC8CAAIAAQi6A/41ABwAAAAA.',['帕秋']='帕秋莉諾蕾姬:BAAALAAECgcIBwAAAA==.',['帝诶']='帝诶叱:BAAALAAECgUIBQAAAA==.',['平常']='平常人:BAAALAAECgYIEQAAAA==.',['年迈']='年迈的我:BAAALAAECgUIBQABLAAFFAgIKwAdAOQkAA==.',['幺鸡']='幺鸡小一条:BAAALAAECggIEQABLAAFFAgIEQAQAEQaAA==.',['幽幽']='幽幽一一蓝妞:BAAALAAFFAIIBAAAAA==.',['开水']='开水白菜:BAAALAADCgMIAwAAAA==.',['式微']='式微灬:BAABLAAFFH8MAAIWAAYIlSGDCQCxAQAWAAYIlSGDCQCxAQAAAA==.',['张狂']='张狂完美:BAABLAAFFH8IAAMLAAMI4Rr4KgCuAAALAAII5x34KgCuAAAIAAMIYxHeNwB/AAAAAA==.',['当铺']='当铺丶:BAAALAAECgMIAwABLAAFFAgIIgAdAH0lAA==.',['影仕']='影仕:BAACLAAFFH8LAAMRAAIIuB37EQC2AAARAAIIuB37EQC2AAAeAAEIrAW8HwA2AAAsAAQKfxoAAxEABwjIHJMaAEACABEABwiRHJMaAEACAB4AAQgUDONOADcAAAAA.',['彼杨']='彼杨德丶雷钬:BAAALAADCgMIAwAAAA==.',['微笑']='微笑灬:BAAALAAFFAIIBAAAAA==.',['徳萊']='徳萊厄斯:BAAALAADCgQIBAAAAA==.',['心如']='心如冰碎:BAAALAAECgQIBAAAAA==.',['快乐']='快乐小流星:BAAALAAECgcICAAAAA==.快乐小闪电:BAAALAAECgcICQAAAA==.',['怀念']='怀念还是怀念:BAAALAADCgMIAwAAAA==.',['性感']='性感丶米老鼠:BAAALAAFFAIIAgAAAA==.',['恋恋']='恋恋青鸟丶:BAAALAAFFAIIBAAAAA==.恋恋风歌:BAAALAAFFAQIAgAAAA==.',['恶毒']='恶毒抓鸡:BAAALAAECgQIBAAAAA==.',['悲伤']='悲伤的记忆:BAAALAADCgEIAQAAAA==.',['愚鲁']='愚鲁:BAABLAAFFH8TAAIBAAYI8h+yFgDiAQABAAYI8h+yFgDiAQAAAA==.',['愛太']='愛太深:BAAALAAECggIEgAAAA==.',['慈观']='慈观寺:BAAALAAECgIIAgAAAA==.',['懒得']='懒得改名:BAAALAAECggICAAAAA==.',['戀心']='戀心:BAAALAAFFAIIBAAAAA==.',['我也']='我也不是恶魔:BAAALAAECgMIAwAAAA==.',['我其']='我其实是奶骑:BAAALAAECggICwAAAA==.',['我头']='我头上有鸡脚:BAAALAAFFAIIAgAAAA==.',['我成']='我成了瘸腿鹅:BAAALAADCgYIBgAAAA==.',['我握']='我握住了希望:BAAALAAECgMIAwAAAA==.',['我来']='我来组成頭部:BAAALAAECgEIAQAAAA==.',['我爱']='我爱潇洒哥:BAABLAAFFH8UAAIfAAUIWApABwAUAQAfAAUIWApABwAUAQAAAA==.',['战狂']='战狂:BAAALAAECgEIAQAAAA==.',['战神']='战神的姐姐:BAAALAADCgcIBwAAAA==.',['戦神']='戦神:BAAALAADCgQIBAAAAA==.',['戰士']='戰士丷:BAAALAAECgUIBwAAAA==.',['所有']='所有人:BAABLAAFFH8IAAIBAAIIgw4ymwBBAAABAAIIgw4ymwBBAAAAAA==.',['打不']='打不出盾击:BAACLAAFFH8JAAIKAAMIOw7PHwDTAAAKAAMIOw7PHwDTAAAsAAQKfyUAAgoABwi1IEhQAE8CAAoABwi1IEhQAE8CAAAA.',['拖鞋']='拖鞋没牙齿:BAABLAAFFH8JAAIBAAIIYw4BcQB+AAABAAIIYw4BcQB+AAABLAAFFAIIDAAKAC0QAA==.',['掌门']='掌门:BAAALAADCgYIBgAAAA==.',['放不']='放不出斩杀:BAABLAAFFH8IAAIbAAII1xGeHwB+AAAbAAII1xGeHwB+AAAAAA==.',['放肆']='放肆丶那纠结:BAABLAAFFH8IAAMdAAIIWRksOQCgAAAdAAIIABYsOQCgAAAXAAEIshbaJwBQAAAAAA==.',['断角']='断角小白:BAAALAADCgEIAQAAAA==.',['斯巴']='斯巴达克斯:BAAALAAECgYIDQAAAA==.',['方腾']='方腾云:BAAALAAECgIIAgAAAA==.',['无忧']='无忧烈酒:BAAALAAECgMIAwAAAA==.',['无敌']='无敌王:BAABLAAFFH8PAAMQAAMIqxeMLQC7AAAQAAMIqxeMLQC7AAAgAAIICQhFJACCAAAAAA==.',['无法']='无法无影:BAAALAAECgYIBgAAAA==.',['时尚']='时尚垨護:BAABLAAFFH8KAAMLAAYIzRo5DgBcAQALAAUIZxg5DgBcAQAIAAUIdguIKgDwAAAAAA==.',['明英']='明英宗朱祁镇:BAAALAAECgYIDAAAAA==.',['易秋']='易秋顔:BAABLAAFFH8FAAMBAAIIuRfITACYAAABAAIIhhbITACYAAAJAAIIFxMwIgCEAAAAAA==.',['星潋']='星潋:BAAALAAFFAIIBAAAAA==.',['星辰']='星辰丶言:BAAALAAECgYICAAAAA==.',['晓丶']='晓丶圣光:BAAALAAECgYIEgAAAA==.晓丶猎心:BAAALAAECgYIBgAAAA==.晓丶瞄准:BAAALAAECgYIEAAAAA==.',['晓羽']='晓羽丅银果:BAAALAADCgUIBQAAAA==.晓羽灬阳炎:BAAALAADCgIIAgAAAA==.',['暗夜']='暗夜幽殤:BAAALAAECgcIBwAAAA==.暗夜流光:BAAALAAFFAIIAgAAAA==.',['暗血']='暗血噬心:BAAALAADCgYIBgAAAA==.',['暴力']='暴力的怪蜀黍:BAAALAAECgQIBAAAAA==.',['暴富']='暴富灬前行:BAAALAAFFAIIBAAAAA==.暴富灬回响:BAABLAAFFH8NAAMXAAIIhhrhCwCxAAAXAAIIhhrhCwCxAAAdAAIIMQ7cXgBGAAAAAA==.暴富灬解忧:BAABLAAFFH8QAAILAAIImxv1MgCbAAALAAIImxv1MgCbAAAAAA==.暴富牛:BAABLAAFFH8IAAIDAAIInwmyfQCJAAADAAIInwmyfQCJAAAAAA==.',['暴走']='暴走的香蕉:BAAALAADCgQIBAAAAA==.',['最后']='最后一眼:BAABLAAFFH8GAAIgAAUIWwNyIQB9AAAgAAUIWwNyIQB9AAAAAA==.',['月之']='月之火舞:BAAALAAECgIIAgAAAA==.',['月光']='月光的救赎:BAABLAAECn8aAAMQAAgIshbkQwDHAQAQAAgIshbkQwDHAQAgAAYItgXXbwD2AAAAAA==.',['月明']='月明中:BAAALAAECgYIDgAAAA==.',['月泣']='月泣:BAABLAAFFH8MAAMKAAIILRBNVgCMAAAKAAIILRBNVgCMAAAMAAIIqguDKABrAAAAAA==.',['有朋']='有朋自远方来:BAABLAAFFH8IAAICAAMIhwDZHAAvAAACAAMIhwDZHAAvAAABLAAFFAYIHQAHACsIAA==.',['木兰']='木兰没及:BAAALAAECgYIDwAAAA==.',['术手']='术手就擒丶:BAAALAAFFAIIAgAAAA==.',['机器']='机器:BAABLAAFFH8IAAMTAAgI+AN6AwByAAATAAcITgR6AwByAAAbAAEImQEwOwAfAAAAAA==.',['李斯']='李斯德林:BAABLAAECn8UAAMPAAcISxiyGQCkAQAPAAcISxiyGQCkAQAFAAYIuQQrZQCOAAAAAA==.',['来瓶']='来瓶鲜奶么:BAABLAAFFH8HAAIFAAMIiAxRHwCmAAAFAAMIiAxRHwCmAAAAAA==.',['杲晴']='杲晴旖旎:BAAALAAFFAIIBAAAAA==.',['板凳']='板凳劣人:BAAALAAECgYICwAAAA==.',['极速']='极速火炮:BAAALAAECgUIBQAAAA==.',['枫华']='枫华摇红:BAACLAAFFH8MAAIKAAMIDBLnQwCLAAAKAAMIDBLnQwCLAAAsAAQKfxsAAgoABwgFHToqAOsBAAoABwgFHToqAOsBAAAA.',['柠檬']='柠檬萌不萌:BAACLAAFFH8vAAMFAAgIZB3IAQDhAgAFAAgIZB3IAQDhAgAPAAUIFBj1FQAxAQAsAAQKfygAAwUACAjlE+tDANEBAAUACAjlE+tDANEBAA8ABQjmHKtHAJYBAAAA.',['梦痕']='梦痕:BAABLAAFFH8KAAIBAAUIzhi9SAArAQABAAUIzhi9SAArAQAAAA==.',['樓蘭']='樓蘭芷殇:BAAALAAFFAIIAgAAAA==.',['欢乐']='欢乐小萨满:BAAALAAECgYIBgAAAA==.',['歪把']='歪把子:BAAALAAECgYIAwAAAA==.',['死得']='死得骑所:BAABLAAFFH8UAAMDAAUIehbeNQDHAAADAAUIehbeNQDHAAACAAEInAyzGQA7AAAAAA==.',['残念']='残念的路人:BAAALAAECgcICgAAAA==.',['毒瘤']='毒瘤啾啾:BAAALAADCgQIBAAAAA==.',['比妳']='比妳嫲爱伱丶:BAABLAAFFH8IAAIEAAII5BtOKwCkAAAEAAII5BtOKwCkAAAAAA==.',['毛老']='毛老爷:BAAALAAECgYICQAAAA==.',['水恋']='水恋铱:BAABLAAFFH8GAAIFAAIIMR4gMwCfAAAFAAIIMR4gMwCfAAAAAA==.',['水牛']='水牛:BAAALAAECgYIEAAAAA==.',['氵淺']='氵淺笑彡:BAAALAAECgYIBgAAAA==.',['永恒']='永恒的下巴:BAAALAADCgMIBQAAAA==.',['没追']='没追求:BAAALAAECgYIEAAAAA==.',['沫晓']='沫晓柒:BAAALAAECgYIDQAAAA==.',['法力']='法力洪流:BAAALAAECgYIBwAAAA==.',['泡沫']='泡沫丶青:BAABLAAFFH8HAAIKAAYI9BOEJABRAQAKAAYI9BOEJABRAQAAAA==.',['洁癖']='洁癖:BAABLAAFFH8GAAMDAAIIMhOnbACSAAADAAIIMhOnbACSAAAfAAEI7g3NHABSAAAAAA==.',['洋葱']='洋葱葱:BAAALAAFFAEIAQAAAA==.',['洛唲']='洛唲丶:BAABLAAFFH8GAAIMAAYIoSTrBABWAgAMAAYIoSTrBABWAgAAAA==.',['洛清']='洛清梦:BAAALAAECggICgAAAA==.洛清舞:BAAALAAECgUIBAAAAA==.',['浮生']='浮生若梦丶:BAABLAAFFH8GAAIDAAIIUAajnAA4AAADAAIIUAajnAA4AAAAAA==.',['海尔']='海尔洗衣机:BAAALAAFFAIIAgAAAA==.',['涂山']='涂山我罩的:BAABLAAFFH8GAAILAAIIDBOPWwBlAAALAAIIDBOPWwBlAAAAAA==.',['涟漪']='涟漪丶:BAAALAAFFAIIAgAAAA==.',['涳汽']='涳汽洅丶撒谎:BAAALAAECgUIBQAAAA==.',['清丶']='清丶漪:BAAALAAFFAIIBAAAAA==.',['清平']='清平乐:BAAALAADCgEIAQAAAA==.',['清渊']='清渊:BAAALAAECgMIAwAAAA==.',['清辉']='清辉夜凝:BAAALAAFFAIIAgAAAA==.',['清道']='清道夫:BAAALAADCgEIAQAAAA==.清道夫小草:BAAALAAECggIEAAAAA==.清道夫牧牧:BAAALAAECgYIDwAAAA==.',['清风']='清风熏人醉:BAAALAAFFAIIAgAAAA==.',['温暖']='温暖如夏:BAAALAADCgMIBgAAAA==.',['满杯']='满杯百香果:BAABLAAFFH8GAAIeAAYIEQBaGQACAAAeAAYIEQBaGQACAAAAAA==.',['漫漫']='漫漫人生路:BAAALAAFFAIIAgAAAA==.',['灬梅']='灬梅川库子:BAAALAADCgYICAAAAA==.',['灬涩']='灬涩酱酱灬:BAAALAADCgcIBwAAAA==.',['灬糖']='灬糖两茶匙:BAAALAADCgYICQAAAA==.',['灬芫']='灬芫茜冰萃:BAAALAADCgYIAgAAAA==.',['灬菜']='灬菜菜灬:BAAALAADCgEIAQAAAA==.',['灬豪']='灬豪雅灬:BAAALAAECgEIAQAAAA==.',['灬那']='灬那个妹子:BAAALAADCgYIBwAAAA==.',['灰机']='灰机到处飘:BAAALAAECggICAAAAA==.',['灰灰']='灰灰:BAAALAAECgYICQABLAAFFAgIDgAIANMiAA==.灰灰的小雨天:BAABLAAFFH8tAAMDAAYIEyKuFQDoAQADAAYIEyKuFQDoAQAfAAII7BO9EACWAAAAAA==.',['灵丶']='灵丶灵:BAAALAAECgYICgAAAA==.',['灵宵']='灵宵:BAAALAADCggIDgAAAA==.',['灵魂']='灵魂持杵夜王:BAAALAAECgYIBgAAAA==.',['炮团']='炮团炊事员:BAAALAADCgMIBgAAAA==.',['焖驴']='焖驴子:BAAALAAECgYIBgAAAA==.',['燕小']='燕小六:BAABLAAFFH8GAAIEAAIIIBdXNgCYAAAEAAIIIBdXNgCYAAAAAA==.',['爆爆']='爆爆小肥牛:BAAALAAECgEIAQAAAA==.',['爱会']='爱会会的:BAAALAAECggICAAAAA==.',['爱的']='爱的魔力圈圈:BAACLAAFFH8KAAIDAAII8g4ligBBAAADAAII8g4ligBBAAAsAAQKfxgAAgMABghPDxh2AAMBAAMABghPDxh2AAMBAAAA.',['牛叉']='牛叉叉:BAAALAAECgYIBgAAAA==.',['牛某']='牛某某:BAAALAAFFAIIAgAAAA==.',['牛牛']='牛牛师傅:BAAALAAECggICAAAAA==.',['牛牪']='牛牪犇:BAAALAADCgIIAgAAAA==.',['牛绿']='牛绿紫:BAAALAAECgIIAgAAAA==.',['牛蜀']='牛蜀黍:BAAALAAECgQIBAAAAA==.',['牧師']='牧師唱回藍:BAABLAAECn8ZAAILAAYIVRMylwBQAQALAAYIVRMylwBQAQAAAA==.',['狂踹']='狂踹瘸子好腿:BAABLAAFFH8GAAMLAAQI2CCZLAAGAQALAAMI6R+ZLAAGAQAIAAEIwhPMPwBLAAAAAA==.',['狂魔']='狂魔血:BAAALAAECgYIBgAAAA==.',['狐叉']='狐叉叉:BAAALAAECgEIAgAAAA==.',['狗哥']='狗哥的小弟:BAABLAAFFH8GAAISAAIIAw4AXQBBAAASAAIIAw4AXQBBAAAAAA==.',['狩猎']='狩猎者:BAAALAAECgUIBQAAAA==.',['猴急']='猴急急:BAACLAAFFH8HAAIBAAMIpw68cACCAAABAAMIpw68cACCAAAsAAQKfxwAAgEABwgqGs93AO0BAAEABwgqGs93AO0BAAAA.',['獒鹰']='獒鹰:BAAALAAECgIIAgAAAA==.',['王富']='王富贵儿:BAAALAAFFAEIAQAAAA==.',['玮玮']='玮玮牛:BAAALAAFFAIIAgAAAA==.',['现实']='现实与假寐:BAAALAAECgYIEQAAAA==.',['琳琳']='琳琳宝:BAABLAAECn8aAAIKAAYIkxgVrQCjAQAKAAYIkxgVrQCjAQAAAA==.',['瑞希']='瑞希:BAAALAAECgIIAgAAAA==.',['甜蜜']='甜蜜兒:BAAALAAECgYIBgAAAA==.',['疾风']='疾风亚索:BAAALAAECgMIAwAAAA==.',['瘋牛']='瘋牛卟咬魜:BAACLAAFFH8MAAMZAAMI5hHEQQCeAAAZAAIIFhfEQQCeAAAcAAEIhQcSHQA3AAAsAAQKfxYAAxkABghEHOyIAHwBABkABggXGOyIAHwBABwABAhsHHlbAAcBAAAA.',['白菜']='白菜牙:BAAALAADCgQIBAAAAA==.',['百变']='百变大星君:BAAALAAECgUIBQAAAA==.',['皮丶']='皮丶点点:BAABLAAFFH8JAAILAAIIfQuHVgBnAAALAAIIfQuHVgBnAAAAAA==.',['盲人']='盲人按摩技师:BAAALAADCgIIAgAAAA==.',['直视']='直视哥的双眼:BAAALAAECgcIBwAAAA==.',['眼子']='眼子寒:BAABLAAECn8aAAIKAAYI9SP/LwDUAQAKAAYI9SP/LwDUAQAAAA==.',['瞬刻']='瞬刻:BAABLAAFFH8IAAIPAAMIcBWtEADrAAAPAAMIcBWtEADrAAABLAAFFAgIPAABAJ8kAA==.',['短裤']='短裤斯文:BAAALAAECgYIBgAAAA==.',['石页']='石页:BAACLAAFFH8KAAIKAAII6xUzOgCiAAAKAAII6xUzOgCiAAAsAAQKfxoAAgoACAhyIL8iAOcCAAoACAhyIL8iAOcCAAAA.',['砍魔']='砍魔达人:BAAALAAECgYIBgAAAA==.',['碇真']='碇真嗣丶:BAABLAAFFH8TAAIDAAUI6hfcEQDCAQADAAUI6hfcEQDCAQAAAA==.',['碳基']='碳基狗丶:BAAALAAECgcIBwAAAA==.',['神圣']='神圣牛肉人:BAAALAAECgYIBgAAAA==.',['神牧']='神牧娜娜:BAAALAAFFAMIAwAAAA==.',['神猎']='神猎手:BAAALAAFFAIIBAAAAA==.',['祥子']='祥子骆驼:BAAALAADCgYIBgAAAA==.',['空军']='空军老:BAABLAAFFH8FAAIBAAMI6gm/cgB+AAABAAMI6gm/cgB+AAAAAA==.',['穿尿']='穿尿布不好惹:BAAALAADCggICAAAAA==.',['突然']='突然范特西:BAAALAAFFAQIBAAAAA==.',['筱僧']='筱僧灬绒舞:BAAALAAECgYIBgAAAA==.',['筱嗳']='筱嗳灬萌斩:BAAALAAECgQIBAAAAA==.',['筱靈']='筱靈灬缨瑶:BAAALAAECgIIAgAAAA==.',['筱飒']='筱飒兒:BAAALAAECgQIBAAAAA==.',['简单']='简单实用丶:BAAALAAECgYIBgAAAA==.',['箭驴']='箭驴子:BAAALAAECgYIDAAAAA==.',['米尔']='米尔萨斯:BAAALAAECgIIAgAAAA==.',['紹興']='紹興老酒:BAACLAAFFH8pAAMLAAcIDhFAEwAdAQALAAcIDhFAEwAdAQAIAAEIPQkuRgBCAAAsAAQKfyIAAgsABghYIJJSAOsBAAsABghYIJJSAOsBAAAA.',['红手']='红手帝:BAABLAAFFH8MAAIDAAMIRhClXwCQAAADAAMIRhClXwCQAAAAAA==.',['红茶']='红茶养乐多:BAAALAAFFAIIAgAAAA==.',['纯情']='纯情丶小翅膀:BAAALAAECgYIAwAAAA==.',['纯绿']='纯绿玩:BAAALAAFFAIIBAAAAA==.',['终极']='终极霸王龙:BAABLAAFFH8GAAIKAAIIDxJ7QwCcAAAKAAIIDxJ7QwCcAAAAAA==.',['绿玩']='绿玩头子:BAABLAAFFH8NAAMOAAII5BrrFgCZAAAOAAII5BrrFgCZAAAhAAIIwB5vGgBfAAAAAA==.',['罐头']='罐头先生:BAAALAAECgYIBgAAAA==.',['网红']='网红主播:BAABLAAFFH8FAAIcAAUIsADLIgAPAAAcAAUIsADLIgAPAAAAAA==.',['羊西']='羊西西:BAAALAAECggIBQABLAAFFAYIDAASAEkSAA==.',['美式']='美式满冰灬:BAAALAADCgcIEAAAAA==.',['羽风']='羽风:BAACLAAFFH8OAAIZAAII+BQhSgCWAAAZAAII+BQhSgCWAAAsAAQKfxgAAhkABggfHPpgAOEBABkABggfHPpgAOEBAAAA.',['老子']='老子很痛苦:BAABLAAFFH8GAAIdAAYI8wDkVQBTAAAdAAYI8wDkVQBTAAABLAAFFAgIIgASAGEcAA==.',['老鼠']='老鼠偷奶酪:BAAALAAECgQIBAAAAA==.',['脑袋']='脑袋砸核桃:BAAALAAECggIBAAAAA==.',['臧玉']='臧玉尘:BAACLAAFFH8rAAIdAAYIORqEHwCgAQAdAAYIORqEHwCgAQAsAAQKfx4AAh0ACAgyGyUkAM8BAB0ACAgyGyUkAM8BAAAA.',['至尊']='至尊宝宝:BAAALAAECgIIAgAAAA==.',['舒舒']='舒舒:BAABLAAFFH8GAAIaAAIIwQi2DwAmAAAaAAIIwQi2DwAmAAAAAA==.舒舒的:BAABLAAFFH8GAAIHAAIIigmlFwAnAAAHAAIIigmlFwAnAAAAAA==.',['艾瑞']='艾瑞吧弟:BAAALAAECgIIAQAAAA==.',['花落']='花落灬吾相依:BAAALAAECgMIAwAAAA==.',['苏帕']='苏帕赛亚硬:BAACLAAFFH8IAAMBAAYIPwyRSAAsAQABAAYIPwyRSAAsAQAJAAIIRgZIHAAnAAAsAAQKfx0AAwkACAhtG6ELAJgBAAEACAhPF5ZkABICAAkABwjTF6ELAJgBAAAA.',['苏格']='苏格兰丨调情:BAAALAADCgYIBgAAAA==.',['范佛']='范佛里特弹药:BAAALAAECgQIBgAAAA==.',['范德']='范德彪:BAAALAAFFAIIAgAAAA==.',['茉莉']='茉莉缇娜:BAAALAAECgYIEAAAAA==.',['茶冻']='茶冻乌龙:BAACLAAFFH8NAAMIAAMIVQsuHADVAAAIAAMIVQsuHADVAAALAAIIqRxcMQCfAAAsAAQKfyAAAwsACAhOHBMuAFoCAAsACAhOHBMuAFoCAAgABwgpDn9uAHABAAAA.',['荒原']='荒原妖:BAAALAAFFAIIAgAAAA==.',['荷尔']='荷尔蒙公主:BAACLAAFFH8IAAIcAAIIgA4/GgA8AAAcAAIIgA4/GgA8AAAsAAQKfx4AAxwABgjoCpgvALwAABkABggkBDzKANgAABwABggeCpgvALwAAAAA.荷尔蒙兽兽:BAABLAAFFH8KAAMRAAIIyQzAGwBHAAARAAIISwvAGwBHAAAeAAIIJwkmGAA1AAAAAA==.荷尔蒙烎士:BAACLAAFFH8OAAIdAAIIdgdPaQA4AAAdAAIIdgdPaQA4AAAsAAQKfxwAAh0ABwiVDmuJAGwBAB0ABwiVDmuJAGwBAAAA.',['莉艾']='莉艾拉:BAABLAAECn8VAAMJAAcI/xzzQwCmAQAJAAcI4hTzQwCmAQABAAYIUR3XaQBwAQAAAA==.',['菜丨']='菜丨菜:BAAALAAFFAIIBAAAAA==.',['菲菲']='菲菲娅:BAAALAAECgMIBgAAAA==.',['萌妞']='萌妞柔柔:BAABLAAFFH8GAAMPAAYIpAqoHQDiAAAPAAUIpQmoHQDiAAAFAAEIhgOIXgAwAAAAAA==.',['萝莉']='萝莉安娜:BAAALAAECgMIAwAAAA==.',['萤火']='萤火眠海:BAAALAAECgEIAQAAAA==.',['萨刃']='萨刃如麻:BAABLAAFFH8JAAILAAIIohJYSQByAAALAAIIohJYSQByAAAAAA==.',['蒙奇']='蒙奇骑:BAABLAAFFH8OAAIKAAUIYRcZJgBIAQAKAAUIYRcZJgBIAQAAAA==.',['蓝蝴']='蓝蝴蝶蓝:BAABLAAECn8VAAMJAAYI6wsOIACTAAABAAYILAuuyADjAAAJAAYImwkOIACTAAAAAA==.',['蕃茄']='蕃茄:BAAALAAECgYIDwAAAA==.',['薛敌']='薛敌忾:BAABLAAFFH8IAAIDAAgIlwCfqgAbAAADAAgIlwCfqgAbAAAAAA==.',['虚空']='虚空鲶鱼:BAACLAAFFH8RAAMdAAYIMQqqMwBIAQAdAAYI/gmqMwBIAQAXAAEICgxuKwBLAAAsAAQKfywAAx0ACAjVGoUiANkBAB0ACAjVGoUiANkBABcABAhTERxhAPMAAAAA.',['蛋花']='蛋花馒头:BAAALAADCgEIAQAAAA==.',['蜜桃']='蜜桃乌龙:BAAALAADCgIIAgAAAA==.',['血月']='血月丨邪:BAAALAAFFAYIBAAAAA==.',['血溢']='血溢指尖:BAAALAAECgYIDAAAAA==.',['血魔']='血魔之舞:BAAALAADCgEIAQAAAA==.',['西冷']='西冷丶血蹄:BAAALAAFFAEIAQAAAA==.',['西瓜']='西瓜味的西瓜:BAAALAAFFAIIAgAAAA==.',['西米']='西米露:BAAALAAECgYIDAAAAA==.',['覆众']='覆众法度繁缛:BAABLAAFFH8IAAISAAQIaRHENQDZAAASAAQIaRHENQDZAAAAAA==.',['言不']='言不由衷丶:BAABLAAFFH8RAAIBAAUIohmGRAA6AQABAAUIohmGRAA6AQAAAA==.',['言无']='言无不禁:BAABLAAFFH8KAAILAAIIJAofaQBSAAALAAIIJAofaQBSAAAAAA==.',['諾亜']='諾亜灬雪儿:BAACLAAFFH8SAAIBAAYIKRwzJgCcAQABAAYIKRwzJgCcAQAsAAQKfyYAAgEACAgxJC8KAM8CAAEACAgxJC8KAM8CAAAA.',['諾亞']='諾亞灬奶嘴:BAAALAAFFAIIAwABLAAFFAYIEgABACkcAA==.諾亞灬樰児:BAAALAAECgYIEAABLAAFFAYIEgABACkcAA==.諾亞灬雪儿:BAAALAAECgYIDgAAAA==.諾亞灬雪兒:BAAALAAECgYICQABLAAFFAYIEgABACkcAA==.',['许愿']='许愿球:BAAALAADCgUICAAAAA==.',['诈尸']='诈尸了赶紧跑:BAAALAAECgMIAwAAAA==.',['诗诗']='诗诗丝黛拉:BAABLAAFFH8YAAIQAAUIpBz4GQCDAQAQAAUIpBz4GQCDAQAAAA==.',['语兰']='语兰枫:BAACLAAFFH8HAAIQAAMIhxIeGADnAAAQAAMIhxIeGADnAAAsAAQKfxUAAhAABghWI0YlAFoCABAABghWI0YlAFoCAAEsAAUUBggJAAQApRQA.',['误伤']='误伤队友:BAABLAAFFH8GAAISAAYIJBGbCwDpAQASAAYIJBGbCwDpAQAAAA==.',['谁不']='谁不是个宝宝:BAAALAAECgYIBgAAAA==.',['谢矮']='谢矮矮:BAAALAAECgYIEwAAAA==.',['豆柿']='豆柿辣鸡:BAAALAAECgQIBgAAAA==.',['贪吃']='贪吃猪猪:BAAALAAFFAIIBAAAAA==.',['贰樓']='贰樓後座:BAAALAAECgUIBQAAAA==.',['贱贱']='贱贱的牛仔:BAAALAAFFAQIAwAAAA==.',['赞达']='赞达拉非酋:BAACLAAFFH8mAAIKAAgISw+vIABnAQAKAAgISw+vIABnAQAsAAQKfzMAAgoABwhBHopPAFECAAoABwhBHopPAFECAAAA.',['走在']='走在冷风里:BAAALAAECgYIBgAAAA==.',['赵主']='赵主任:BAAALAAECgEIAQAAAA==.',['超級']='超級瑪麗薛:BAAALAAECgMIAwAAAA==.',['超级']='超级伐木机:BAAALAAECgYIDQAAAA==.',['踹你']='踹你一蹄子:BAAALAAECgcIBwAAAA==.',['蹦达']='蹦达的颖酱:BAABLAAFFH8KAAIEAAMI6AoqPQB9AAAEAAMI6AoqPQB9AAAAAA==.',['这次']='这次人比较小:BAAALAAECgUIBQAAAA==.',['逍遥']='逍遥星河:BAACLAAFFH8FAAIKAAMIHQvhRgCBAAAKAAMIHQvhRgCBAAAsAAQKfycAAgoABwimGv0qAOgBAAoABwimGv0qAOgBAAAA.',['透明']='透明气球:BAAALAADCgQIBAAAAA==.',['逐风']='逐风者丶熊猫:BAAALAAECgYICgAAAA==.',['道格']='道格修二世:BAAALAAECgYIBwAAAA==.',['那个']='那个人:BAABLAAFFH8GAAIEAAIINw13XQA5AAAEAAIINw13XQA5AAAAAA==.',['那夜']='那夜我脸红咯:BAAALAAECgYIBgAAAA==.',['酒舞']='酒舞无心:BAAALAAECgYIDQAAAA==.',['醉光']='醉光阴:BAACLAAFFH8IAAIKAAIIyx54KwCyAAAKAAIIyx54KwCyAAAsAAQKfxgAAgoABwh+IlVAAHoCAAoABwh+IlVAAHoCAAAA.',['钻石']='钻石男高:BAAALAAFFAIIAwAAAA==.',['铁骨']='铁骨豆腐腰:BAAALAADCgEIAQAAAA==.',['错的']='错的人:BAAALAAFFAIIAgAAAA==.',['镇丶']='镇丶岳:BAAALAAECggIBQAAAA==.',['长孙']='长孙慕语:BAABLAAFFH8GAAIKAAIIVg8FTACVAAAKAAIIVg8FTACVAAAAAA==.',['阿尔']='阿尔缇米斯:BAAALAADCggICAAAAA==.',['阿福']='阿福揍扁成龙:BAAALAAECgEIAQAAAA==.',['陈丶']='陈丶风暴劣酒:BAAALAAECgYIBgAAAA==.',['陈嘉']='陈嘉轩:BAAALAAECggIBgABLAAFFAIIDgAZAPgUAA==.',['随意']='随意挼个猫:BAABLAAFFH8OAAILAAQI/gpGOgC7AAALAAQI/gpGOgC7AAAAAA==.',['随芯']='随芯:BAABLAAFFH8OAAIFAAQILAkCLwCwAAAFAAQILAkCLwCwAAAAAA==.',['雕刻']='雕刻小时光:BAAALAAFFAIIBAAAAA==.',['雪山']='雪山飞侠:BAABLAAFFH8MAAIBAAUISA/iVAD/AAABAAUISA/iVAD/AAAAAA==.',['零度']='零度久战:BAAALAAFFAIIBAAAAA==.',['靈魂']='靈魂冷心:BAABLAAFFH8GAAIDAAYIFwJKVwCtAAADAAYIFwJKVwCtAAAAAA==.靈魂心骸:BAAALAAECgUICAAAAA==.',['靓小']='靓小丫:BAAALAAECgYICQAAAA==.',['非凡']='非凡套哥:BAAALAAFFAEIAQAAAA==.',['韦小']='韦小宝丶射:BAAALAAECggICAAAAA==.',['项空']='项空归尘:BAABLAAFFH8GAAILAAIIpRJqWQBpAAALAAIIpRJqWQBpAAAAAA==.',['风吹']='风吹你的裙角:BAAALAADCgYIBgAAAA==.风吹头发扬:BAAALAAFFAIIBAAAAA==.',['风暴']='风暴萨满:BAAALAAECgEIAQAAAA==.',['风雅']='风雅颂:BAAALAAECgYICgAAAA==.',['飘雪']='飘雪悠然:BAABLAAFFH8MAAIKAAIIfw4WSACYAAAKAAIIfw4WSACYAAAAAA==.',['飛壆']='飛壆:BAAALAAFFAIIBAAAAA==.',['飞毛']='飞毛腿:BAAALAAECgYIBgAAAA==.',['飞象']='飞象踩老鼠:BAAALAADCgMIAwAAAA==.',['香草']='香草拿铁:BAAALAAECgYIDAAAAA==.',['香香']='香香:BAAALAADCgUIBQAAAA==.',['驱不']='驱不了:BAABLAAFFH8OAAIEAAIIHBmfKACoAAAEAAIIHBmfKACoAAAAAA==.',['骄羞']='骄羞的香蕉:BAAALAADCgUIBQAAAA==.',['鬼月']='鬼月丨邪:BAABLAAFFH8KAAMSAAIIeBveSQBSAAASAAIIBhveSQBSAAAHAAIIQBLOFQArAAAAAA==.',['魔力']='魔力瓜杍:BAAALAADCggICAAAAA==.',['魔王']='魔王:BAABLAAFFH8HAAIDAAIIzx+nOQC+AAADAAIIzx+nOQC+AAAAAA==.',['鱼利']='鱼利丹:BAAALAAECgQIBAAAAA==.',['麦芽']='麦芽糖吖:BAABLAAFFH8FAAILAAMIkwvjTgB/AAALAAMIkwvjTgB/AAAAAA==.',['黑夜']='黑夜魅魔:BAAALAAECgEIAQAAAA==.',['黑胖']='黑胖丶:BAAALAAFFAIIBAAAAA==.',['黑莓']='黑莓糯糍:BAAALAAECgYIBgAAAA==.',['黑须']='黑须猎:BAABLAAFFH8GAAIBAAIIOhwmRgCeAAABAAIIOhwmRgCeAAAAAA==.',['默瀚']='默瀚莫德丶牛:BAAALAAECgYICAAAAA==.',['龍兕']='龍兕月:BAAALAAECgYIBgAAAA==.',['龍獵']='龍獵月:BAAALAAECgUIBQAAAA==.',['龍飛']='龍飛鳳舞丶:BAAALAAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end