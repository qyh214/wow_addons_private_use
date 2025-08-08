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
 local lookup = {'DemonHunter-Havoc','Unknown-Unknown','Paladin-Protection','Evoker-Devastation','Evoker-Preservation','Paladin-Retribution','Monk-Windwalker','Priest-Discipline','Priest-Holy','Warrior-Arms','Warrior-Fury','Paladin-Holy','Mage-Arcane','Rogue-Assassination','DeathKnight-Frost','Monk-Mistweaver','Warlock-Destruction','Shaman-Enhancement','Druid-Balance','Druid-Restoration','Shaman-Restoration','Shaman-Elemental','DeathKnight-Blood','Mage-Fire','DeathKnight-Unholy','Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Vengeance','Priest-Shadow','Mage-Frost','Monk-Brewmaster',}; local provider = {region='CN',realm='沙怒',name='CN',type='weekly',zone=42,date='2025-08-08',data={As='Asl:BAAAKgAECgYICwAAAA==.',Av='Avarice:BAAAKgADCgEIAgAAAA==.',Da='Danceg:BAABKgAFFH8FAAIBAAUI3xl0HgAQAQABAAUI3xl0HgAQAQABKgAFFAgIBAACAAAAAA==.',Ea='Earthx:BAAAKgAFFAEIAQAAAA==.',En='Endwordgry:BAAAKgADCgcIBwAAAA==.',Et='Ethereal:BAAAKgAECgYIBgAAAA==.',Ff='Ffot:BAAAKgAECgIIAgAAAA==.',Fi='Fif:BAAAKgAECgMIAwAAAA==.',He='Helbeel:BAAAKgAECgcIBwAAAA==.',Ju='Judgelight:BAAAKgAECggICAAAAQ==.',Ka='Karas:BAABKgAFFH8KAAIDAAgIig4yBgCKAQADAAgIig4yBgCKAQAAAA==.',Ma='Marksuperman:BAAAKgAECggICAAAAA==.',Mu='Muriel:BAAAKgAECgYIBgAAAA==.',Ne='Nescafem:BAAAKgAECgMIAwAAAA==.',Sp='Spitile:BAAAKgAECgIIAgAAAA==.',Su='Superx:BAAAKgAECgMIAwAAAA==.',To='Toplrl:BAAAKgADCggICAAAAA==.',Vv='Vvca:BAABKgAECn8cAAMEAAgIBxzLFgAMAgAEAAgIBxzLFgAMAgAFAAQI2g9AHwB/AAAAAA==.Vvcc:BAAAKgADCgQIBAABKgAECggIHAAEAAccAA==.',['一小']='一小双儿一:BAAAKgAECgQIBAAAAA==.',['一拳']='一拳小和尚:BAAAKgAECggICwAAAA==.',['一相']='一相亦一:BAAAKgAECggIEAAAAA==.',['一虎']='一虎贲一:BAAAKgAECggIEQAAAA==.',['丁真']='丁真:BAAAKgADCgYIBgAAAA==.',['七夜']='七夜果果:BAAAKgAECgEIAQAAAA==.',['七月']='七月在野:BAABKgAECn8rAAIGAAgIkBhkHwDBAQAGAAgIkBhkHwDBAQAAAA==.七月流火:BAAAKgADCgEIAQAAAA==.七月食瓜:BAABKgAECn8kAAIHAAgI2BVcCQDhAQAHAAgI2BVcCQDhAQAAAA==.',['三生']='三生三幸:BAAAKgADCggICAAAAA==.',['上电']='上电:BAABKgAECn8bAAMIAAgIKgteQADqAAAIAAgIJApeQADqAAAJAAgI8gecUADPAAAAAA==.',['下雨']='下雨的伊伊:BAABKgAECn8WAAMKAAgI6Qt4MAA6AQAKAAgIPwt4MAA6AQALAAYI6Qr+YADSAAAAAA==.',['丨符']='丨符娃灬:BAAAKgAECgcIDQABKgAFFAgIAQACAAAAAA==.',['丩零']='丩零灬大男人:BAABKgAFFH8PAAILAAQIYx2RDgAAAQALAAQIYx2RDgAAAQAAAA==.',['中等']='中等的新手:BAAAKgAECgQIBAAAAA==.',['丶墨']='丶墨渊:BAACKgAFFH8TAAQMAAQIDh2pBwDzAAAMAAMIDh2pBwDzAAAGAAMIVBk5IgDfAAADAAQINgvZIAB5AAAqAAQKfxkABAYACAjoH4RRAP8BAAYABwiOH4RRAP8BAAwABAhxH0YfAGYBAAMAAwjoGWwwANsAAAAA.',['丶嫣']='丶嫣嫣焉:BAAAKgAECggIEAAAAA==.',['丶星']='丶星延:BAAAKgAECgIIAgAAAA==.',['丶燕']='丶燕狂徒:BAABKgAFFH8GAAIGAAYIZB0VEgDMAQAGAAYIZB0VEgDMAQAAAA==.',['乄誓']='乄誓灬约:BAAAKgAECgEIAQAAAA==.',['义演']='义演顶针:BAAAKgAECgYICgABKgAFFAIIAgACAAAAAA==.',['乌镇']='乌镇醇酒:BAAAKgAECgcIDgAAAA==.',['了不']='了不起的人:BAAAKgAECggICAAAAA==.',['二舅']='二舅姥爷:BAAAKgAECgQIBgAAAA==.',['二蛋']='二蛋他二婶:BAAAKgAECgEIAQAAAA==.',['井空']='井空空:BAAAKgAECggICAAAAA==.',['伊利']='伊利尔灬破风:BAAAKgADCgIIAgAAAA==.',['伊斯']='伊斯埃雷之光:BAABKgAFFH8IAAINAAgIUw/gBwD+AQANAAgIUw/gBwD+AQAAAA==.',['伏黑']='伏黑甚尔:BAABKgAFFH8IAAIGAAgI7QtJEQDUAQAGAAgI7QtJEQDUAQAAAA==.',['优库']='优库里伍德:BAAAKgAECgUIBQAAAA==.',['低卡']='低卡美式:BAAAKgADCgcIBwAAAA==.',['你的']='你的天堂:BAAAKgADCgUIBQAAAA==.',['傲娇']='傲娇小伙伴:BAAAKgAECgYIBgABKgAFFAgICAAGAC8jAA==.',['先生']='先生你好帅:BAAAKgAECgQIBAAAAA==.',['全区']='全区美男:BAAAKgAECgQIBAAAAA==.',['六六']='六六:BAABKgAFFH8IAAIOAAUIuSHmDAB+AQAOAAUIuSHmDAB+AQABKgAFFAgICAAOAP8VAA==.',['兰斯']='兰斯维亚:BAAAKgAECgcIDgAAAA==.',['冰逝']='冰逝风尘:BAABKgAFFH8FAAMKAAUIJA5mFQDZAAAKAAQI7g1mFQDZAAALAAEI+g7gNQBJAAAAAA==.',['冰雪']='冰雪女王:BAAAKgAECggICAAAAA==.',['冲动']='冲动的骑士:BAAAKgADCgIIAgAAAA==.',['冲锋']='冲锋踩到翔:BAAAKgAECgEIAQAAAA==.',['冻顶']='冻顶乌龙:BAABKgAECn8ZAAIPAAgIjxv8CAAsAgAPAAgIjxv8CAAsAgAAAA==.',['凉兮']='凉兮冷:BAABKgAFFH8XAAIQAAQI4xZcFQDMAAAQAAQI4xZcFQDMAAAAAA==.',['凌乱']='凌乱的虫虫:BAABKgAFFH8IAAIRAAQIjQ6YFQDOAAARAAQIjQ6YFQDOAAAAAA==.',['凯特']='凯特琳丶薇:BAAAKgAECggICAAAAA==.',['刺客']='刺客尼基塔:BAAAKgADCgcIBwAAAA==.',['剩歧']='剩歧视:BAAAKgADCggICAAAAA==.',['加迩']='加迩什丶咆哮:BAAAKgAFFAEIAQAAAA==.',['午夜']='午夜镇魂曲:BAAAKgAECgMIAwABKgAFFAUIBQAKACQOAA==.',['半支']='半支烟:BAABKgAECn8YAAISAAgINh7ZAgCJAgASAAgINh7ZAgCJAgAAAA==.',['南冥']='南冥有猫:BAAAKgAECggIDgAAAA==.',['卡布']='卡布达:BAAAKgAECgEIAQAAAA==.',['古巨']='古巨基:BAABKgAFFH8IAAIGAAgI6hSpDAADAgAGAAgI6hSpDAADAgAAAA==.',['只会']='只会卖萌:BAAAKgAFFAYIBAAAAA==.',['叱咤']='叱咤风云:BAAAKgADCggIFQAAAA==.',['叶之']='叶之眼:BAABKgAFFH8GAAIQAAYIHAdFBQBcAQAQAAYIHAdFBQBcAQAAAA==.',['吃枣']='吃枣药丸:BAAAKgAECgcICAAAAA==.',['名人']='名人不说暗话:BAAAKgAECgMIAwAAAA==.',['向右']='向右看齐丶:BAAAKgAFFAIIAwAAAA==.',['吮指']='吮指脆脆基:BAACKgAFFH8cAAMTAAQI/SRDHwAlAQATAAQI/SRDHwAlAQAUAAMINhj9EACtAAAqAAQKfywAAxQACAhhIuMFALQCABQACAhhIuMFALQCABMACAhxHWodAFkCAAAA.',['吾奶']='吾奶天海丶:BAAAKgAECgYIBgAAAA==.',['咕咕']='咕咕爱吃香蕉:BAAAKgAECgIIAgAAAA==.',['咸鱼']='咸鱼牧:BAAAKgAFFAEIAQAAAA==.咸鱼猎:BAAAKgADCgEIAQAAAA==.咸鱼萨:BAACKgAFFH8uAAMVAAgIGiNsAgBoAgAVAAgIGiNsAgBoAgAWAAEIABH9GQBGAAAqAAQKfxwAAxUACAjuHwgYAEQCABUACAjuHwgYAEQCABYAAwiOExxgAJoAAAAA.',['哦呼']='哦呼:BAAAKgAECgEIAQAAAA==.',['喝多']='喝多了打男人:BAAAKgADCgIIAgAAAA==.',['嗜血']='嗜血总裁:BAAAKgADCgQIBAAAAA==.',['嗷呜']='嗷呜:BAAAKgAECggIEAAAAA==.',['嘿你']='嘿你尾巴呢:BAABKgAFFH8GAAIXAAYIFxDhEQATAQAXAAYIFxDhEQATAQABKgAFFAgICgADAIoOAA==.',['在等']='在等月亮和你:BAABKgAFFH8JAAIYAAYIkA53BwCNAQAYAAYIkA53BwCNAQAAAA==.',['地精']='地精真坑爹:BAACKgAFFH8NAAIVAAQIIg2+OACfAAAVAAQIIg2+OACfAAAqAAQKfzoAAhUACAjUGxohAAQCABUACAjUGxohAAQCAAAA.',['壹歲']='壹歲就學壞:BAAAKgAFFAQIBAAAAA==.',['多乐']='多乐港:BAACKgAFFH8vAAIZAAgIdyWWAAAEAwAZAAgIdyWWAAAEAwAqAAQKfzAAAhkACAjXJGsJANECABkACAjXJGsJANECAAAA.',['夜舞']='夜舞幽影:BAAAKgADCgUIBQAAAA==.',['夜色']='夜色屠戮:BAAAKgAFFAIIAgAAAA==.',['大学']='大学生:BAAAKgADCggICAAAAA==.',['大胡']='大胡子:BAAAKgAECgMIAwAAAA==.',['天外']='天外飞小牛:BAAAKgAECgYIDAAAAA==.',['天官']='天官赐福:BAABKgAFFH8FAAIXAAUIMARQCgDfAAAXAAUIMARQCgDfAAABKgAFFAgIEQAXAIwKAA==.',['奶上']='奶上天:BAAAKgAECgcICwAAAA==.',['如夢']='如夢:BAAAKgAFFAgIBAAAAA==.',['如约']='如约而至:BAAAKgAFFAYIBAAAAA==.',['妩媚']='妩媚丶小女人:BAAAKgAECgUIBQAAAA==.',['媚唲']='媚唲:BAAAKgAECgIIAgAAAA==.',['嫩牛']='嫩牛吃鲜花:BAAAKgAECgQIBAAAAA==.',['子珊']='子珊善柏:BAAAKgAECgQIBAAAAA==.',['孤独']='孤独里冬眠:BAABKgAECn8VAAMDAAgIWx3XDQAsAgADAAgI6BvXDQAsAgAGAAgIzRdLcgCzAQAAAA==.',['宁戮']='宁戮:BAACKgAFFH8KAAMaAAYI+xrjDgDeAAAaAAUImR/jDgDeAAAbAAEIgwhEXwA4AAAqAAQKfx4AAxoACAh4IxEfANoBABsABwghIc05AA8CABoACAihHxEfANoBAAEqAAUUCAgIABsAcw0A.',['宇哥']='宇哥乃小红:BAABKgAFFH8IAAIGAAgI9Q3yDQD2AQAGAAgI9Q3yDQD2AQAAAA==.',['安多']='安多的汉尼:BAAAKgAECgUIBQAAAA==.',['安迪']='安迪圣骑之光:BAABKgAFFH8FAAMGAAQIJhLvOACXAAAGAAIIGxDvOACXAAADAAIIMhSqIAB6AAAAAA==.安迪猎王:BAABKgAECn8VAAIbAAgITCGAGgCPAgAbAAgITCGAGgCPAgAAAA==.',['完全']='完全不懂浪漫:BAABKgAECn8kAAIHAAgIVBw6BgBAAgAHAAgIVBw6BgBAAgAAAA==.',['寂灭']='寂灭的骨头:BAAAKgAECgIIAgAAAA==.',['寶貝']='寶貝二零一一:BAAAKgAECgcIDQAAAA==.',['封獸']='封獸鵺:BAABKgAFFH8GAAITAAYI3w50GgBGAQATAAYI3w50GgBGAQAAAA==.',['小兮']='小兮兮:BAAAKgAFFAEIAQAAAA==.',['小咖']='小咖拉蜜:BAAAKgADCggICAAAAA==.',['小咘']='小咘灬爱酱:BAAAKgAECggICQAAAA==.',['小嚒']='小嚒丶:BAAAKgAECggIEAAAAA==.',['小夕']='小夕夕:BAABKgAECn8VAAMJAAgIdQdFWgCsAAAJAAgItAJFWgCsAAAIAAMIMA3aWwCFAAAAAA==.',['小明']='小明伟:BAAAKgAFFAYIAgAAAA==.',['小猪']='小猪苒:BAABKgAFFH8FAAIOAAII3xhHEQCnAAAOAAII3xhHEQCnAAAAAA==.',['小猫']='小猫菲儿:BAAAKgAECggIDgAAAA==.',['小珑']='小珑灬:BAAAKgADCggIEAAAAA==.',['小的']='小的德德:BAAAKgAECgYICAABKgAFFAUIBQAKACQOAA==.',['小脑']='小脑斧:BAABKgAFFH8GAAIXAAYIChdUDABOAQAXAAYIChdUDABOAQAAAA==.',['小马']='小马珍珠:BAAAKgAECgQIBQABKgAFFAIIAgACAAAAAA==.',['尘灬']='尘灬觞:BAAAKgAECgUIBQABKgAFFAUIBQAKACQOAA==.',['尹利']='尹利丹怒风:BAAAKgAECggIEAAAAA==.',['带妳']='带妳私奔:BAABKgAECn8tAAIGAAgI1SSGEQDGAgAGAAgI1SSGEQDGAgAAAA==.',['幼儿']='幼儿园大佬:BAABKgAECn8hAAIcAAgIeB2GDABIAgAcAAgIeB2GDABIAgAAAA==.幼儿园大姥:BAAAKgAECgcIBwAAAA==.',['幽靈']='幽靈獵灬手:BAAAKgADCggICQAAAA==.',['微笑']='微笑向暖丶:BAAAKgAECgYICAAAAA==.',['怀特']='怀特迈嗯:BAAAKgADCgIIAgAAAA==.',['思慕']='思慕棍哥:BAAAKgAECgYIBgABKgAFFAIIAgACAAAAAA==.',['性感']='性感妖精:BAAAKgAECgIIAgAAAA==.',['我恨']='我恨我自己:BAAAKgAECgIIAgAAAA==.',['我砍']='我砍死了希瓦:BAAAKgADCgEIBQAAAA==.',['戒烟']='戒烟的说丶:BAAAKgAFFAIIAgAAAA==.',['打脑']='打脑壳:BAAAKgAECgYICAAAAA==.',['拉孜']='拉孜:BAAAKgAECgcIDQAAAA==.',['拉鸶']='拉鸶斯里:BAAAKgADCgIIAgAAAA==.',['拾忆']='拾忆少女的梦:BAACKgAFFH8GAAIUAAYIVA8mDQA5AQAUAAYIVA8mDQA5AQAqAAQKfyMAAxQACAhkIIkFAEUCABQACAhkIIkFAEUCABMABQhoEgSEANUAAAAA.',['挽之']='挽之:BAAAKgAECgYIBgAAAA==.',['斩断']='斩断奈何桥:BAAAKgAECggIEAAAAA==.',['无情']='无情打击:BAAAKgADCgEIAQAAAA==.',['无敌']='无敌风扶水:BAAAKgADCgMIAwAAAA==.',['无月']='无月丶:BAAAKgAFFAYIBAAAAA==.',['无聊']='无聊的熊三:BAAAKgAECgEIAQAAAA==.',['星海']='星海祜:BAAAKgADCggICAAAAA==.星海箶:BAAAKgADCggICAAAAA==.星海醐:BAAAKgAFFAQIBAAAAA==.',['時光']='時光丶:BAAAKgAFFAQIBAAAAA==.',['晓闫']='晓闫:BAAAKgAECgcIBwAAAA==.',['晨曦']='晨曦云岚:BAAAKgADCggICAAAAA==.',['暗淡']='暗淡的矿脉:BAAAKgAECgYICAAAAA==.',['暴怒']='暴怒的黑牛:BAAAKgADCgMIAwAAAA==.',['最后']='最后的风行者:BAAAKgAECggICAABKgAFFAgILQAbAMMeAA==.',['最坑']='最坑小牛:BAAAKgADCggICAAAAA==.',['最爱']='最爱吃兽奶:BAABKgAECn8YAAIbAAgIVSVPBgDvAgAbAAgIVSVPBgDvAgAAAA==.',['月之']='月之少女:BAAAKgAECgMIAwAAAA==.',['月影']='月影之怒:BAAAKgADCgEIAQAAAA==.',['杳无']='杳无音讯丶:BAABKgAFFH8IAAMdAAUI0RB3AwCbAQAdAAUI0RB3AwCbAQAJAAMISwPWEwChAAAAAA==.',['果儿']='果儿佟佟:BAAAKgAECgQIBgAAAA==.',['柔情']='柔情的小妈:BAAAKgAECgYIBgAAAA==.',['格罗']='格罗马式:BAAAKgAECgUICQAAAA==.',['桜丶']='桜丶:BAAAKgADCggIBQAAAA==.',['梵门']='梵门嗔徒:BAAAKgAFFAgIBAAAAA==.',['棒棒']='棒棒的好二萌:BAABKgAFFH8GAAMdAAQI+Q8kFADDAAAdAAQI+Q8kFADDAAAJAAII5gogHAB2AAABKgAFFAgIBgAJAKsLAA==.',['楸芭']='楸芭比母牛牛:BAAAKgADCgIIAgAAAA==.',['橙浮']='橙浮:BAAAKgAECggICQAAAA==.',['武僧']='武僧熊:BAAAKgAECgcIBwAAAA==.',['武起']='武起来:BAAAKgAECgcIDgAAAA==.',['歪歪']='歪歪不老神鸡:BAAAKgAECgEIAQAAAA==.',['没脸']='没脸猫:BAAAKgAECgIIAgABKgAFFAgIEQAUAD4jAA==.',['法拉']='法拉利法:BAAAKgAECggICQAAAA==.',['波波']='波波奶茶:BAAAKgADCgYIBgAAAA==.',['泪在']='泪在流浪:BAAAKgAECgEIAQAAAA==.',['浪加']='浪加:BAABKgAFFH8FAAIHAAQI3R6PBgATAQAHAAQI3R6PBgATAQAAAA==.',['淡定']='淡定的肉丝:BAAAKgAECgEIAQAAAA==.',['淸玖']='淸玖丶:BAAAKgAFFAgIBAAAAA==.',['满山']='满山找牛牛:BAAAKgAFFAEIAQAAAA==.',['灬迪']='灬迪丽热巴:BAAAKgAECgQIBAAAAA==.',['灬黄']='灬黄瓜消灭者:BAAAKgADCgQIBAAAAA==.',['灰毫']='灰毫:BAAAKgAECggICwAAAA==.',['灼目']='灼目黑电:BAAAKgAECggIDwAAAA==.',['炎帝']='炎帝:BAAAKgADCgUIBQAAAA==.',['点头']='点头魔丶:BAAAKgADCggICAAAAA==.',['烈焰']='烈焰:BAABKgAFFH8IAAIGAAYIUR+SHwByAQAGAAYIUR+SHwByAQAAAA==.',['煎饼']='煎饼狗子:BAAAKgADCggIDQAAAA==.',['煙花']='煙花过後:BAAAKgADCggICAAAAA==.',['爱吃']='爱吃橘子皮:BAAAKgAFFAgIAgAAAA==.爱吃猪脚饭:BAAAKgADCgEIAQAAAA==.',['牛哞']='牛哞哞:BAAAKgADCggICAAAAA==.',['犬来']='犬来八荒:BAABKgAFFH8IAAIGAAYIWSG5FQCtAQAGAAYIWSG5FQCtAQAAAA==.',['狂卷']='狂卷尼姑庵:BAAAKgAECgMIAwAAAA==.',['狐一']='狐一菲:BAAAKgAFFAMIAwABKgAFFAUIBQAKACQOAA==.',['玄程']='玄程:BAAAKgAFFAQIBAAAAA==.',['玛里']='玛里恩血蹄:BAAAKgAECggICAAAAA==.',['珑灬']='珑灬猫猫:BAAAKgAECgEIAQAAAA==.',['理塘']='理塘王:BAAAKgAECgYIBgAAAA==.',['瓦粒']='瓦粒瓦谷:BAAAKgAECgQIBAAAAA==.',['电动']='电动奶瓶:BAAAKgAFFAIIAQAAAA==.',['疯狂']='疯狂虫子:BAAAKgAFFAQIBAABKgAFFAgIEAAVACIVAA==.',['白色']='白色体育生:BAAAKgAECgUIBQAAAA==.',['相思']='相思煮余年:BAAAKgAECgEIAQAAAA==.',['瞎逼']='瞎逼玩:BAAAKgAECggICAAAAA==.',['神秘']='神秘勇士:BAABKgAECn8aAAMVAAgIdBEKSwBeAQAVAAgIdBEKSwBeAQAWAAEIiwZZiwAfAAAAAA==.神秘英雄:BAAAKgAECgIIAgAAAA==.',['禾酒']='禾酒:BAACKgAFFH8NAAIFAAQIkyEmAwAfAQAFAAQIkyEmAwAfAQAqAAQKfxgAAgUACAiLG4UGAM0BAAUACAiLG4UGAM0BAAAA.',['秦心']='秦心:BAAAKgAECggIEAAAAA==.',['空弦']='空弦:BAEAKgAECggIDAABKgAFFAgIBgASAK4TAA==.',['穿云']='穿云一箭:BAABKgAFFH8GAAIbAAMIOQoHHQCzAAAbAAMIOQoHHQCzAAABKgAFFAUIBQAKACQOAA==.',['竹子']='竹子大仙:BAAAKgAECgUIBwAAAA==.',['等等']='等等不急:BAAAKgAECgYIBgAAAA==.',['精萃']='精萃澳瑞白:BAAAKgADCgYIBgAAAA==.',['練丶']='練丶霓裳:BAAAKgADCggICAAAAA==.',['红杉']='红杉沈南鹏:BAAAKgADCgEIAQAAAA==.',['纳兰']='纳兰英雄:BAAAKgADCggICAAAAA==.',['终极']='终极电疗:BAABKgAFFH8KAAISAAYINwxtAgCgAQASAAYINwxtAgCgAQAAAA==.',['给眼']='给眼:BAAAKgADCggICAAAAA==.',['罪刑']='罪刑法定:BAAAKgAECggIEAAAAA==.',['美美']='美美莹:BAABKgAFFH8JAAIBAAMI1R7sEQASAQABAAMI1R7sEQASAQABKgAFFAUIBQAKACQOAA==.',['翎森']='翎森:BAAAKgAECggIDwAAAA==.',['老的']='老的快精华:BAAAKgAECgMIAwAAAA==.',['联盟']='联盟统帅:BAAAKgAFFAIIBAAAAA==.',['肺肺']='肺肺驾到:BAABKgAFFH8GAAILAAYIgRZKDACHAQALAAYIgRZKDACHAQAAAA==.',['胖嘟']='胖嘟嘟麦麦:BAAAKgAFFAQIBAAAAA==.',['胖熊']='胖熊无敌:BAAAKgAECgQIBQAAAA==.',['胡椒']='胡椒乌龙茶:BAABKgAFFH8KAAMLAAYIBg0HFQAVAQALAAUIXA8HFQAVAQAKAAQIcAPEGQC8AAAAAA==.',['脑袋']='脑袋还在:BAACKgAFFH8fAAIGAAYIPB51IgBjAQAGAAYIPB51IgBjAQAqAAQKfyQAAgYACAibIogdAKICAAYACAibIogdAKICAAEqAAUUCAgCAAIAAAAA.',['自然']='自然风暴:BAABKgAECn8YAAISAAgIaRTAGACSAQASAAgIaRTAGACSAQABKgAFFAUIBQAKACQOAA==.',['艺术']='艺术就是爆炸:BAAAKgAFFAQIBAAAAA==.',['艾莱']='艾莱克:BAACKgAFFH8NAAIZAAMIOxifKADrAAAZAAMIOxifKADrAAAqAAQKfxsAAxkACAj8IukKALcCABkACAj8IukKALcCABcACAhJHKQNABoCAAAA.',['花开']='花开叶落:BAAAKgAECgMIAwAAAA==.',['花淡']='花淡媣:BAAAKgADCggICAAAAA==.',['苍白']='苍白圣光:BAAAKgAECgIIAwAAAA==.',['荼吉']='荼吉尼天:BAAAKgADCgEIAQAAAA==.',['莳丶']='莳丶緔:BAAAKgAFFAIIAgAAAA==.',['萌灬']='萌灬小菜瓜:BAAAKgAECgYICgAAAA==.',['萨佢']='萨佢老味:BAAAKgAECgMIAwAAAA==.',['蓝妹']='蓝妹儿:BAACKgAFFH8FAAIVAAMIOxGvMgCvAAAVAAMIOxGvMgCvAAAqAAQKfyIAAhUACAg1G+AbACACABUACAg1G+AbACACAAAA.',['蓝莓']='蓝莓甜甜圈:BAAAKgAFFAQIBAAAAA==.',['蕾依']='蕾依丽雅:BAAAKgAFFAMIAwABKgAFFAMIAwACAAAAAA==.',['血兽']='血兽来了丶:BAABKgAFFH8IAAMXAAQItBhHEgCxAAAZAAQIxhewLgDVAAAXAAQIDxFHEgCxAAAAAA==.',['血帝']='血帝尅:BAAAKgAECgQIBwABKgAFFAUIBQAKACQOAA==.',['行路']='行路难:BAABKgAECn8wAAIWAAgIJhnUCgDiAQAWAAgIJhnUCgDiAQAAAA==.',['裹着']='裹着心的光丶:BAAAKgAECgEIAQAAAA==.',['西南']='西南暴龙:BAAAKgAFFAMIAwAAAA==.',['见习']='见习圣光:BAABKgAFFH8GAAIDAAYICxoRAQC4AQADAAYICxoRAQC4AQAAAA==.',['记得']='记得要微笑:BAAAKgADCgQIBAAAAA==.',['诗丨']='诗丨妤:BAABKgAFFH8IAAIIAAMICxsvFgDhAAAIAAMICxsvFgDhAAAAAA==.',['谁家']='谁家那小谁:BAAAKgADCgIIAgAAAA==.',['豊聡']='豊聡耳神子:BAABKgAFFH8GAAMTAAYIOAysJwD2AAATAAUIpQ2sJwD2AAAUAAEI8wCNOAA4AAAAAA==.',['贰元']='贰元叁毛钱:BAABKgAECn8qAAILAAgIFx0iCAA7AgALAAgIFx0iCAA7AgAAAA==.',['跷脚']='跷脚牛肉:BAAAKgAFFAYIBAAAAA==.',['轩萧']='轩萧:BAAAKgADCgcICQAAAA==.',['辣肉']='辣肉宗师:BAABKgAECn8lAAIQAAgIEyQiBwC6AgAQAAgIEyQiBwC6AgABKgAFFAgIDgAGACIeAA==.',['進魤']='進魤戰熋:BAACKgAFFH8ZAAMGAAMIog2tKQDAAAAGAAMIog2tKQDAAAAMAAEIxAEcFwAxAAAqAAQKfxwAAwwACAjyFSEVAMgBAAwACAjyFSEVAMgBAAYAAQg9CYZ2ATQAAAAA.',['遗失']='遗失灬:BAAAKgADCgIIAgAAAA==.',['那年']='那年我五岁:BAABKgAECn8jAAIBAAgIsxvhGQAzAgABAAgIsxvhGQAzAgAAAA==.',['郭郭']='郭郭:BAAAKgAECgcICAAAAA==.',['醉拳']='醉拳甘艿迪:BAAAKgAFFAIIAwAAAA==.',['重庆']='重庆扛把子:BAABKgAECn8dAAITAAgIRxq1JgAbAgATAAgIRxq1JgAbAgAAAA==.',['锦依']='锦依:BAABKgAFFH8JAAIRAAMIFQoBGwCoAAARAAMIFQoBGwCoAAABKgAFFAUIBQAKACQOAA==.',['锦添']='锦添:BAABKgAFFH8JAAIGAAMI0hmWHwDrAAAGAAMI0hmWHwDrAAABKgAFFAUIBQAKACQOAA==.',['阳光']='阳光丶:BAAAKgAECgEIAQAAAA==.',['阿尔']='阿尔托莉亜:BAABKgAFFH8GAAIPAAYISxdaBACVAQAPAAYISxdaBACVAQAAAA==.',['阿拉']='阿拉隔壁老王:BAABKgAFFH8GAAIBAAYIUwibGQAwAQABAAYIUwibGQAwAQAAAA==.',['阿魚']='阿魚:BAABKgAFFH8IAAIZAAQIJgt1FwDYAAAZAAQIJgt1FwDYAAAAAA==.',['隔壁']='隔壁老黄:BAAAKgAECgEIAQAAAA==.',['雾月']='雾月:BAABKgAECn8ZAAIeAAgIRBB1LwBJAQAeAAgIRBB1LwBJAQAAAA==.雾月幻雨:BAACKgAFFH8FAAIPAAMIvQ5PDAC1AAAPAAMIvQ5PDAC1AAAqAAQKfyMAAg8ACAj+IwICAOICAA8ACAj+IwICAOICAAAA.',['霉好']='霉好的钱途:BAAAKgADCggICAAAAA==.',['霜晚']='霜晚丶:BAABKgAFFH8GAAITAAYI8AvDGwA8AQATAAYI8AvDGwA8AQAAAA==.',['霹雳']='霹雳娇娃:BAABKgAECn8XAAIWAAgIlxl3HADkAQAWAAgIlxl3HADkAQAAAA==.',['靉丽']='靉丽銯丶賯児:BAAAKgADCggIGAAAAA==.',['青椴']='青椴:BAAAKgAECgIIAgAAAA==.',['顺风']='顺风尿湿鞋:BAABKgAFFH8FAAMbAAUIJRVrFwDyAAAbAAQI+RlrFwDyAAAaAAEIqgakJQBKAAABKgAFFAgIEwAbAIEjAA==.',['颠覆']='颠覆德界:BAAAKgADCgMIAwAAAA==.',['風玲']='風玲儿:BAAAKgAECgMIAwAAAA==.',['风往']='风往北吹:BAABKgAECn8jAAITAAgIlx15CgBQAgATAAgIlx15CgBQAgAAAA==.',['风爵']='风爵士:BAAAKgAECgYIBgAAAA==.',['香辣']='香辣牛肉面:BAAAKgAECgQIBAAAAA==.',['高岭']='高岭麋鹿:BAAAKgAECgYIBgAAAA==.',['鬼才']='鬼才三电:BAABKgAFFH8GAAIfAAYI9gZbBADxAAAfAAYI9gZbBADxAAAAAA==.',['魔兽']='魔兽大叔:BAAAKgAECgYIBgAAAA==.',['鲁西']='鲁西西:BAABKgAFFH8JAAQMAAUIGRH9BwDWAAAMAAQIJg/9BwDWAAADAAQI4QuyIAB6AAAGAAEIiBNiPwBPAAABKgAFFAgIEAAdAFsKAA==.',['麦克']='麦克雷:BAAAKgAFFAQIBAAAAA==.',['黑牛']='黑牛嘎子:BAAAKgAECggICAAAAA==.',['黑糖']='黑糖卡布奇洛:BAAAKgAFFAMIAwAAAA==.',['龍卷']='龍卷:BAAAKgAFFAQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end