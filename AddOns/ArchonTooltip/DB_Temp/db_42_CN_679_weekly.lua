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
 local lookup = {'Paladin-Retribution','Paladin-Protection','DeathKnight-Blood','Priest-Shadow','DemonHunter-Havoc','Druid-Balance','Evoker-Devastation','Priest-Holy','Mage-Arcane','DeathKnight-Unholy','DemonHunter-Vengeance','Shaman-Restoration','Shaman-Enhancement','Shaman-Elemental','Hunter-Marksmanship','Hunter-BeastMastery','Druid-Restoration','Warrior-Arms','Warrior-Protection','Druid-Guardian','Warrior-Fury','Warlock-Destruction','Mage-Frost','Warlock-Affliction','Warlock-Demonology','Rogue-Assassination','Monk-Mistweaver','DeathKnight-Frost','Paladin-Holy','Priest-Discipline','Mage-Fire',}; local provider = {region='CN',realm='恐怖图腾',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alita:BAABKgAFFH8QAAMBAAgIsBo4CwApAQACAAgIThabBwCYAQABAAQIFh44CwApAQAAAA==.',Ba='Babysyy:BAAAKgAECgcICAAAAA==.Bananananana:BAAAKgAECgMIAwAAAA==.',Be='Beboom:BAAAKgADCgMIAwAAAA==.',Ca='Canny:BAAAKgAECgcIBwAAAA==.',De='Devilurustao:BAAAKgAECggICQAAAA==.',El='Elfly:BAAAKgADCggICAAAAA==.',Fa='Favorcat:BAABKgAFFH8HAAIDAAcIxRSHCACSAQADAAcIxRSHCACSAQAAAA==.',Ks='Ks:BAAAKgAECgIIAgAAAA==.',Mo='Momoer:BAAAKgAECgIIAgAAAA==.Monee:BAABKgAFFH8GAAIEAAYIDA9WDAA5AQAEAAYIDA9WDAA5AQAAAA==.',Mq='Mqmqmqq:BAAAKgAFFAQIBAAAAA==.',Na='Nazha:BAABKgAFFH8IAAIFAAgInhYCBwAyAgAFAAgInhYCBwAyAgAAAA==.',Pr='Priness:BAAAKgAECgcIBwAAAA==.',Sp='Spiritwhite:BAAAKgAECggICgAAAA==.',Un='Unbelievable:BAAAKgAECgQIBAAAAA==.',['一脸']='一脸晦气:BAAAKgAFFAYIBAAAAA==.',['一颗']='一颗大柠檬:BAAAKgAECgUIBQAAAA==.一颗柠檬:BAAAKgAECgYIBgAAAA==.',['不存']='不存在嘚存在:BAAAKgAECgYICwAAAA==.',['不开']='不开心:BAAAKgAECgEIAQAAAA==.',['不要']='不要崇拜哥:BAAAKgADCggIFAAAAA==.',['专业']='专业切蛋:BAABKgAFFH8XAAIGAAYIhSOQCQD9AQAGAAYIhSOQCQD9AQAAAA==.',['世界']='世界小可爱:BAAAKgAFFAEIAQAAAA==.',['业火']='业火三灾:BAABKgAFFH8HAAIHAAcIFh87BgAzAgAHAAcIFh87BgAzAgAAAA==.',['丨黑']='丨黑白信仰丨:BAAAKgAFFAIIAgAAAA==.',['丶心']='丶心:BAAAKgADCggICwAAAA==.',['丶月']='丶月影:BAAAKgAECggICgAAAA==.',['乃吉']='乃吉布吉岛:BAABKgAFFH8NAAIIAAMIFBSgIgC6AAAIAAMIFBSgIgC6AAAAAA==.',['乌鸦']='乌鸦:BAAAKgAECgQIBAAAAA==.',['乌黑']='乌黑的长耳朵:BAAAKgADCgQIBAAAAA==.',['云中']='云中漫步:BAAAKgAECgEIAQAAAA==.',['云里']='云里雾理:BAAAKgAFFAIIBAAAAA==.',['五月']='五月奶:BAAAKgAECgEIAQAAAA==.',['人家']='人家可嗲了:BAAAKgAFFAcIBAAAAA==.',['休丶']='休丶:BAABKgAFFH8GAAIJAAYIDx+aDgB+AQAJAAYIDx+aDgB+AQAAAA==.',['你凶']='你凶个锤子:BAABKgAFFH8QAAMKAAQIdRajLgDVAAAKAAQIdxWjLgDVAAADAAII6wz8LQBZAAAAAA==.',['你虱']='你虱倒淋头丶:BAAAKgAECgYIBwAAAA==.',['倚澜']='倚澜听风:BAAAKgAECggICAAAAA==.',['倪哥']='倪哥:BAAAKgAECggICAAAAA==.',['傭人']='傭人自擾:BAAAKgAFFAgIAQAAAA==.',['八神']='八神:BAAAKgAECgEIAQAAAA==.',['凤与']='凤与梧桐:BAABKgAFFH8FAAILAAIIRgUSEQBTAAALAAIIRgUSEQBTAAAAAA==.',['凤凰']='凤凰栖息梧桐:BAABKgAFFH8TAAIMAAMILyMdGAAhAQAMAAMILyMdGAAhAQAAAA==.',['凯丶']='凯丶:BAAAKgAECggICAAAAA==.',['凹依']='凹依稀特:BAAAKgADCggICAAAAA==.',['出门']='出门左转:BAAAKgAECgUIDQAAAA==.',['利刃']='利刃风暴:BAAAKgAFFAIIAwAAAA==.',['包健']='包健玮:BAABKgAFFH8KAAMNAAYIkQ9YAwByAQANAAYInQhYAwByAQAOAAQIiRMaCgDeAAAAAA==.',['匊埖']='匊埖殘:BAAAKgAECgIIAgAAAA==.',['印度']='印度电工:BAAAKgAECgcICQAAAA==.',['又见']='又见喵星人:BAAAKgAECgMIBwAAAA==.',['叫你']='叫你再凶:BAABKgAFFH8MAAMPAAMISBa5EADWAAAPAAMISBa5EADWAAAQAAEIWw+hXQA7AAAAAA==.',['叶子']='叶子:BAAAKgAECggICAAAAA==.',['吃个']='吃个嘴子:BAAAKgAECgMIAwAAAA==.',['吉祥']='吉祥赶猪棒:BAAAKgAECgIIAgAAAA==.',['咆哮']='咆哮熊德:BAABKgAFFH8KAAMRAAYIehOlCgDdAAARAAQI7R6lCgDdAAAGAAIIlBXEMwBOAAAAAA==.',['咔鮭']='咔鮭咿丨小鳥:BAABKgAFFH8KAAMBAAII6iTgKwDBAAABAAII6iTgKwDBAAACAAEI6wfcGgArAAAAAA==.',['咕巨']='咕巨鸡:BAAAKgADCggIFAAAAA==.',['哈似']='哈似骑:BAABKgAFFH8IAAMDAAYIbA35FAD6AAADAAYIbA35FAD6AAAKAAEIpguFUQBNAAAAAA==.',['哈克']='哈克蒙得:BAABKgAFFH8GAAIPAAYIXAX1EgDRAAAPAAYIXAX1EgDRAAAAAA==.',['哈密']='哈密瓜往事:BAABKgAFFH8KAAMSAAgI0Qg+CACIAQASAAgI0Qg+CACIAQATAAEI4AAsGQAdAAAAAA==.',['哎呀']='哎呀叶子:BAAAKgAFFAIIAwAAAA==.',['啊又']='啊又死了:BAAAKgADCggIAwAAAA==.',['喊我']='喊我毛毛:BAAAKgAECggICQAAAA==.',['喵翠']='喵翠花:BAABKgAFFH8IAAIMAAgIihN5BQD+AQAMAAgIihN5BQD+AQAAAA==.',['嗝屁']='嗝屁的圣骑:BAAAKgADCgcIBwAAAA==.',['嘚嘚']='嘚嘚的德:BAABKgAECn8XAAMGAAgIvBioLAD8AQAGAAgIvBioLAD8AQAUAAEIygk/RAATAAAAAA==.',['噩梦']='噩梦猎手:BAABKgAECn8XAAIFAAgIkBzaGgArAgAFAAgIkBzaGgArAgAAAA==.',['团队']='团队毒瘤:BAABKgAFFH8FAAIDAAIIUh7sHgCsAAADAAIIUh7sHgCsAAAAAA==.',['图咔']='图咔:BAAAKgAECgYIBgAAAA==.',['圣光']='圣光会守护你:BAAAKgAECgQIBAAAAA==.',['基尔']='基尔格洛:BAAAKgAECggIDgAAAA==.',['壹月']='壹月帝:BAABKgAECn8WAAMQAAgI3BsVMAA0AgAQAAgI/RkVMAA0AgAPAAcIaxHPYgDOAAAAAA==.',['夜舞']='夜舞倾城:BAABKgAFFH8RAAMFAAYI8RxpDAC+AQAFAAYI8RxpDAC+AQALAAYIoAZlBwDdAAABKgAFFAgIGwAFAI0bAA==.',['大愚']='大愚:BAABKgAFFH8QAAIVAAgIZxClBQA7AgAVAAgIZxClBQA7AgAAAA==.',['大眼']='大眼睛会放电:BAAAKgADCggICAABKgAFFAgIDgAKAA8XAA==.',['大耳']='大耳先生:BAAAKgAECgMIAwAAAA==.大耳朵图图:BAAAKgAFFAMIAwAAAA==.',['大自']='大自在天:BAAAKgAECgIIAgAAAA==.',['天然']='天然路痴:BAAAKgADCgIIAwAAAA==.',['失真']='失真:BAAAKgAECggIDgAAAA==.',['奥利']='奥利奥丶:BAAAKgAECgMIAwAAAA==.',['奥术']='奥术智慧:BAAAKgAECggICAAAAA==.',['奥瑞']='奥瑞克:BAABKgAFFH8FAAIWAAIIfxDKPwBtAAAWAAIIfxDKPwBtAAAAAA==.',['奥魂']='奥魂神奥魂:BAACKgAFFH8GAAIJAAYIrB17DACfAQAJAAYIrB17DACfAQAqAAQKfxcAAhcACAicE0omAIQBABcACAicE0omAIQBAAAA.',['好奶']='好奶的白子:BAAAKgADCggIEQAAAA==.',['好牛']='好牛的滑子:BAAAKgADCgYIBgAAAA==.',['妖精']='妖精美色:BAAAKgAFFAMIAwAAAA==.',['孑孓']='孑孓不度:BAAAKgADCggICAAAAA==.',['孤夜']='孤夜奏鸣曲:BAAAKgAFFAgIBAAAAA==.',['寂寞']='寂寞陪着寂寞:BAAAKgAECggIEAAAAA==.',['寒傲']='寒傲冬破殇:BAAAKgADCgIIAgAAAA==.',['小丫']='小丫:BAAAKgAECgYIBgAAAA==.',['小公']='小公公:BAAAKgAECgEIAQAAAA==.',['小潘']='小潘:BAAAKgAECggICQAAAA==.',['小灬']='小灬牧:BAABKgAFFH8KAAIIAAgIqRm7AwAWAgAIAAgIqRm7AwAWAgAAAA==.',['小盐']='小盐熊崽汁:BAAAKgAFFAQIBAAAAA==.',['小苏']='小苏仔:BAABKgAFFH8IAAMGAAYIBxAqHQAzAQAGAAYIugwqHQAzAQAUAAIIFA8GBwBcAAAAAA==.',['小鬼']='小鬼叁:BAAAKgAFFAQIBAAAAA==.',['尕鳥']='尕鳥灬乖乖:BAAAKgAECgYIBgAAAA==.',['尬聊']='尬聊先生:BAAAKgADCgEIAgAAAA==.',['希尔']='希尔瓦娜一思:BAACKgAFFH8OAAIBAAMIww/BUQDMAAABAAMIww/BUQDMAAAqAAQKfywAAgEACAiSGyBNANcBAAEACAiSGyBNANcBAAAA.',['很正']='很正经:BAAAKgAECgUIBQAAAA==.',['快递']='快递大侠:BAAAKgAECgcIBwAAAA==.',['恐怖']='恐怖的獠牙:BAAAKgAECgUICQAAAA==.',['惊恐']='惊恐的鸦熊:BAABKgAECn8YAAQWAAgIoyLLGwAcAgAWAAgIyCDLGwAcAgAYAAMIfiN+JwC/AAAZAAEI1hw4cABLAAABKgAFFAYICQAaAJASAA==.',['戛爽']='戛爽:BAAAKgAECgMIAwAAAA==.',['手法']='手法相当凶残:BAAAKgAECgMIAwAAAA==.',['扎外']='扎外:BAAAKgAFFAEIAQAAAA==.',['打你']='打你的屁啊屁:BAAAKgADCggIDgAAAA==.',['摸眼']='摸眼诶眼呢:BAAAKgAFFAcIAwABKgAFFAgIAQAbALEJAA==.',['放开']='放开那位小妞:BAAAKgADCggIIAAAAA==.',['文远']='文远:BAAAKgAECggICAAAAA==.',['斩妖']='斩妖泣血:BAAAKgAFFAYIAwAAAA==.',['无敌']='无敌大炮:BAAAKgAECgYIBgAAAA==.',['晓风']='晓风残月:BAABKgAFFH8GAAIaAAYIgx+tBwD1AQAaAAYIgx+tBwD1AQAAAA==.',['晚上']='晚上才打猎:BAAAKgAECgIIAgAAAA==.',['暮鼓']='暮鼓晨钟:BAAAKgAECggICAAAAA==.',['月下']='月下紫桐:BAAAKgAECgEIAQAAAA==.',['朝玖']='朝玖晚伍:BAAAKgADCggICAAAAA==.',['本波']='本波儿灞:BAAAKgAFFAEIAQAAAA==.',['机车']='机车男孩小夏:BAACKgAFFH8hAAIKAAgIMCReAgCxAgAKAAgIMCReAgCxAgAqAAQKfyIAAwoACAjTJYMUAIYCAAoACAjTJYMUAIYCABwAAQgAANs8AAAAAAAA.',['李勤']='李勤学:BAAAKgAECgEIAgAAAA==.',['松下']='松下裤带:BAAAKgAECgcICQAAAA==.',['梧桐']='梧桐凤凰:BAAAKgAFFAIIAgAAAA==.',['楊楊']='楊楊丶:BAAAKgAECgMIAwAAAA==.',['死寂']='死寂:BAAAKgADCgUIBQAAAA==.',['死誓']='死誓:BAABKgAFFH8GAAIVAAYIcwm4CgB3AQAVAAYIcwm4CgB3AQAAAA==.',['残月']='残月鸭:BAACKgAFFH8IAAIEAAQIexIgEADeAAAEAAQIexIgEADeAAAqAAQKfxcAAwQACAh+I7QHALsCAAQACAh+I7QHALsCAAgABggsCSZgAMAAAAEqAAUUCAgKAAgA2RYA.',['氵心']='氵心:BAAAKgADCggICAAAAA==.',['永不']='永不为奴:BAABKgAFFH8IAAMVAAMIHwz2IgDHAAAVAAMIjAr2IgDHAAATAAIIKAxyDABjAAAAAA==.',['沁达']='沁达利亚:BAABKgAFFH8KAAMQAAMIJxryGQDrAAAQAAMIaxfyGQDrAAAPAAEIMBtDJQBLAAAAAA==.',['沉沦']='沉沦恐惧:BAAAKgAECgYIBgAAAA==.',['流月']='流月沧岚:BAABKgAFFH8GAAISAAYINQcQDQA+AQASAAYINQcQDQA+AQAAAA==.流月苍岚:BAAAKgAFFAIIAgAAAA==.',['浅殇']='浅殇止水:BAABKgAFFH8UAAMQAAYI1CDwCADmAQAQAAYI1CDwCADmAQAPAAQIqxqpCQD7AAAAAA==.',['渔舟']='渔舟晚音:BAAAKgAECggICgAAAA==.',['渝北']='渝北冯老师:BAABKgAFFH8GAAIBAAYI6xgSIQBqAQABAAYI6xgSIQBqAQAAAA==.',['演技']='演技亮眼:BAAAKgAECgMIAwAAAA==.',['漫天']='漫天箭雨:BAAAKgAECgcIBwAAAA==.',['火之']='火之高兴:BAAAKgADCgQIBAAAAA==.',['灬丶']='灬丶丨微笑:BAACKgAFFH8gAAMBAAYIexPbJgBNAQABAAYI8w3bJgBNAQACAAYI7gzACQD+AAAqAAQKf1YAAgEACAiPIUMeAIoCAAEACAiPIUMeAIoCAAAA.',['灬古']='灬古二蛋灬:BAAAKgADCggICAAAAA==.',['灬活']='灬活力鱼串灬:BAABKgAFFH8FAAIEAAMINiBMEgDRAAAEAAMINiBMEgDRAAAAAA==.',['無法']='無法離弃丶:BAABKgAFFH8KAAQGAAMIOAkbQQCnAAAGAAMIOAkbQQCnAAARAAIIhAYzHABnAAAUAAEIHAD5EQAGAAAAAA==.',['爱在']='爱在西元前:BAAAKgADCgQIBAAAAA==.',['狂牛']='狂牛莫问:BAAAKgAECggIDwAAAA==.',['狐假']='狐假虎威:BAAAKgAECggIEgAAAA==.',['狐尼']='狐尼克丶:BAAAKgADCggICAAAAA==.',['王者']='王者之泪:BAAAKgAECgQIBAAAAA==.',['生鱼']='生鱼:BAABKgAFFH8UAAQBAAYIGyDTEADZAQABAAYIGyDTEADZAQAdAAMIJAIlDQCUAAACAAQIdwxoDgCTAAAAAA==.',['甲方']='甲方:BAAAKgAFFAMIAwAAAA==.',['異想']='異想兲開:BAAAKgAFFAMIAwAAAA==.',['看灬']='看灬飞碟:BAAAKgAECgYIAgAAAA==.',['真香']='真香嗷:BAAAKgAECggICAABKgAFFAgICgAFAAIRAA==.',['眼镜']='眼镜掉了:BAAAKgAECgYIBgAAAA==.',['神棍']='神棍德丶:BAAAKgAECgcIBwAAAA==.',['神道']='神道无念:BAABKgAFFH8HAAIWAAUIthTfGwAnAQAWAAUIthTfGwAnAQABKgAFFAgIAgAJAAIWAA==.',['秋山']='秋山:BAAAKgADCgcIBwAAAA==.',['筋钢']='筋钢大:BAAAKgAECgcIBwAAAA==.',['紫龙']='紫龙:BAAAKgAFFAQIBAAAAA==.',['給消']='給消哎你报警:BAAAKgAECgMIAwAAAA==.',['红烧']='红烧鸭掌:BAAAKgAFFAgIAgAAAA==.',['绯红']='绯红丨女皇:BAABKgAECn8VAAMVAAYIVhocQABzAQAVAAYIGhgcQABzAQASAAYIiBCXLwAWAQAAAA==.',['缘之']='缘之空:BAAAKgAFFAYIBAAAAA==.',['缰尸']='缰尸先生:BAAAKgAECgEIAQAAAA==.',['老娘']='老娘和你没完:BAAAKgAFFAIIAwAAAA==.',['老许']='老许:BAAAKgAFFAIIAgAAAA==.',['花开']='花开满:BAABKgAECn8WAAIZAAgI5BjBHQCZAQAZAAgI5BjBHQCZAQAAAA==.',['苍狼']='苍狼啸月:BAAAKgAECgYIBgAAAA==.',['茜拉']='茜拉:BAAAKgAECgEIAQAAAA==.',['荒野']='荒野大镖客:BAAAKgADCgMIAwAAAA==.',['菊苣']='菊苣的杀气:BAAAKgADCgEIAQAAAA==.',['菊菊']='菊菊有杀气:BAAAKgADCggIDgAAAA==.',['萧萧']='萧萧瑟瑟:BAABKgAFFH8GAAIBAAYIzR7/GwCEAQABAAYIzR7/GwCEAQABKgAFFAgICgABAK0lAA==.',['蒸炽']='蒸炽:BAAAKgAFFAgIBAAAAA==.',['蔚蓝']='蔚蓝色的天空:BAAAKgAECgIIAgAAAA==.',['虛化']='虛化再造傳說:BAAAKgAECgEIAQAAAA==.',['血圣']='血圣天使:BAAAKgAECgYIBgAAAA==.',['西瓜']='西瓜吹雪:BAABKgAFFH8MAAIBAAYIlBEuIgBkAQABAAYIlBEuIgBkAQAAAA==.',['触手']='触手可及:BAABKgAFFH8FAAMdAAQIDCXGAQBHAQAdAAQIDCXGAQBHAQABAAEIEA7XTgBKAAAAAA==.',['詭刺']='詭刺:BAAAKgAECgUIBQAAAA==.',['贫道']='贫道不戒:BAAAKgAFFAIIAgAAAA==.',['赎魂']='赎魂:BAABKgAFFH8GAAIMAAYIahPsDwBYAQAMAAYIahPsDwBYAQAAAA==.',['赤道']='赤道的北边:BAAAKgAECgEIAQAAAA==.',['超豪']='超豪华一条龙:BAABKgAFFH8IAAMIAAgINxBmEAAvAQAIAAYIEQxmEAAvAQAeAAIIlxq+HQCsAAAAAA==.',['蹲在']='蹲在茅坑玩蛆:BAAAKgADCgQIBAAAAA==.',['转角']='转角爱:BAAAKgADCggIBQAAAA==.',['辛洛']='辛洛斯:BAAAKgADCgYIBgAAAA==.',['辣辣']='辣辣弄滴:BAAAKgAECggIDwAAAA==.',['还叫']='还叫这个名字:BAAAKgAFFAQIBAAAAA==.',['进击']='进击的洗剪吹:BAAAKgAECgIIAgABKgAFFAgIEQARAD4jAA==.',['進击']='進击的冰枪:BAABKgAFFH8GAAIJAAYIEw8nFABEAQAJAAYIEw8nFABEAQAAAA==.',['遗忘']='遗忘者叨:BAAAKgADCggICAAAAA==.',['那年']='那年秋天:BAAAKgADCgQIBAAAAA==.',['邪徒']='邪徒叶子:BAAAKgADCggICAAAAA==.',['酒后']='酒后少女的梦:BAAAKgADCgEIAQAAAA==.',['铜曲']='铜曲:BAAAKgAECgUICAAAAA==.',['闊少']='闊少爺:BAAAKgAECgcICQAAAA==.',['门板']='门板糊脸:BAABKgAECn8dAAITAAgITxq8CgAUAgATAAgITxq8CgAUAgAAAA==.',['阔少']='阔少爷:BAACKgAFFH8HAAIBAAIIyQ9AOwCSAAABAAIIyQ9AOwCSAAAqAAQKfxsAAwEACAirIE0tAGoCAAEACAirIE0tAGoCAAIAAghpCq9hACQAAAAA.',['隂陽']='隂陽師:BAAAKgAECggIDwAAAA==.',['雨田']='雨田木羽:BAAAKgAECggICAAAAA==.',['雪子']='雪子奶白:BAABKgAFFH8mAAMMAAgINiE8AQCVAgAMAAgINiE8AQCVAgAOAAMImwc8GQCwAAAAAA==.',['零零']='零零龙:BAAAKgAECgQIBAAAAA==.',['雾似']='雾似雾:BAAAKgADCgEIAQAAAA==.',['雾影']='雾影乱秋:BAAAKgADCgMIAwAAAA==.',['霜凌']='霜凌法影:BAABKgAFFH8GAAIfAAYI3CK5BwDUAQAfAAYI3CK5BwDUAQAAAA==.',['霜流']='霜流刀:BAAAKgAECgUIBQAAAA==.',['露花']='露花倒影:BAAAKgAECgMIAwAAAA==.',['霸击']='霸击大:BAAAKgAECgMIAwAAAA==.',['风一']='风一样的男子:BAAAKgADCgQIBAAAAA==.',['风雨']='风雨雷电:BAAAKgAFFAYIBAAAAA==.',['魔法']='魔法掌控:BAAAKgAFFAQIBAABKgAFFAgICAAQANAVAA==.',['鱼丸']='鱼丸灬初面:BAAAKgAECggIDwAAAA==.',['鳥鳥']='鳥鳥丶:BAABKgAFFH8JAAIEAAMIMyFDCAAlAQAEAAMIMyFDCAAlAQAAAA==.',['鳳凰']='鳳凰:BAABKgAFFH8MAAIDAAQIxAcKHQByAAADAAQIxAcKHQByAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end