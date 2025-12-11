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
 local lookup = {'Mage-Frost','Paladin-Protection','DemonHunter-Vengeance','DemonHunter-Havoc','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Blood','Priest-Shadow','Priest-Holy','Warrior-Fury','Mage-Arcane','DeathKnight-Frost','Paladin-Retribution','Hunter-BeastMastery','Unknown-Unknown','Hunter-Marksmanship','Shaman-Restoration','Evoker-Devastation','DeathKnight-Unholy','Druid-Feral','Druid-Guardian','Hunter-Survival','Shaman-Elemental','Monk-Brewmaster','Warlock-Destruction','Warrior-Protection','Monk-Mistweaver',}; local provider = {region='CN',realm='塔纳利斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aw='Awdahwdkajgh:BAAALAAECgEIAQAAAA==.',Co='Colour:BAAALAAECgYIBgAAAA==.',Ez='Ezio:BAAALAAFFAIIAgAAAA==.',Fo='Forevertime:BAAALAAECgYIBgAAAA==.',Jo='Joana:BAABLAAECn8WAAIBAAcI4hTnFQB6AQABAAcI4hTnFQB6AQAAAA==.',Ma='Maxi:BAAALAAFFAIIAgABLAAFFAIICgACAAcZAA==.Maxii:BAABLAAECn8XAAMDAAYInxT7KgBgAQADAAYInxT7KgBgAQAEAAYIUwmr8AAHAQABLAAFFAIICgACAAcZAA==.Maxis:BAABLAAFFH8KAAICAAIIBxllEACWAAACAAIIBxllEACWAAAAAA==.Maxiz:BAAALAAECgYICwABLAAFFAIICgACAAcZAA==.',Mi='Mickeyy:BAABLAAFFH8KAAMFAAYIJg+PDABFAQAFAAQISBGPDABFAQAGAAII4QpnEwBKAAAAAA==.',Ne='Nekoo:BAABLAAFFH8NAAIBAAYIqQPVDgBxAAABAAYIqQPVDgBxAAAAAA==.',Rx='Rxll:BAAALAAECgEIAQAAAA==.',Sp='Spoony:BAABLAAFFH8GAAIHAAIIIgvtEgB0AAAHAAIIIgvtEgB0AAAAAA==.',Xz='Xzxdmn:BAAALAADCgEIAQAAAA==.',Yk='Ykkap:BAAALAADCgcIBwAAAA==.',['一地']='一地鸡毛:BAAALAAECgYIDAAAAA==.',['一直']='一直丶微笑:BAAALAADCgQIBAAAAA==.',['一锤']='一锤子呼死你:BAAALAAECgUIBQAAAA==.',['不死']='不死牛:BAAALAAECgYICwAAAA==.',['不要']='不要奶我:BAAALAAECgEIAQAAAA==.',['丑扒']='丑扒怪:BAAALAAECgEIAQAAAA==.',['临风']='临风听蝉:BAAALAAECggIBwAAAA==.',['乱世']='乱世丷小仙:BAAALAAECgMIAwAAAA==.',['亲近']='亲近大地:BAAALAAECgUIBQAAAA==.',['人工']='人工智能:BAABLAAFFH8dAAICAAcIXAt1BgBqAQACAAcIXAt1BgBqAQAAAA==.',['人称']='人称吕奉先:BAAALAAECgMIAwAAAA==.',['仙人']='仙人抚我顶:BAAALAAECgMIAwAAAA==.',['任咔']='任咔:BAAALAAECgYIDAAAAA==.',['伊暮']='伊暮:BAABLAAFFH8KAAMIAAIItQMmKABtAAAIAAIItQMmKABtAAAJAAIIKg19PgBtAAABLAAFFAMIBQABAP8NAA==.',['低碳']='低碳哥:BAAALAAECgIIAgAAAA==.',['你先']='你先斩:BAACLAAFFH8qAAIKAAYIrhfRDQC7AQAKAAYIrhfRDQC7AQAsAAQKfycAAgoACAg5IfQZAO0CAAoACAg5IfQZAO0CAAAA.',['你真']='你真强:BAAALAAFFAMIAwAAAA==.',['偷你']='偷你光光:BAAALAAECggIDgAAAA==.',['傲魂']='傲魂魅影:BAABLAAFFH8GAAILAAYIcADybQADAAALAAYIcADybQADAAAAAA==.',['元宝']='元宝的大招:BAAALAADCgIIAgAAAA==.',['全球']='全球皆可飞:BAAALAAECgYIEQAAAA==.',['八心']='八心八箭:BAABLAAFFH8GAAIMAAIIZgeBlAA8AAAMAAIIZgeBlAA8AAAAAA==.',['兰卡']='兰卡威豪仔:BAAALAADCgcIBwAAAA==.',['关服']='关服就不玩了:BAAALAAFFAEIAQAAAA==.',['冬飞']='冬飞之翼:BAACLAAFFH8YAAILAAYIJAcJHABnAQALAAYIJAcJHABnAQAsAAQKfyUAAgsACAgoG3Q7AFwCAAsACAgoG3Q7AFwCAAAA.',['冰蟹']='冰蟹:BAAALAAECgYIAwAAAA==.',['剩骑']='剩骑士啊:BAAALAAECgYIBgAAAA==.',['华耀']='华耀:BAABLAAFFH8WAAINAAUIaSEQHAB9AQANAAUIaSEQHAB9AQABLAAFFAcIHwAEALgcAA==.',['卡尔']='卡尔瓦罗森:BAABLAAECn8WAAMNAAgI1gR3swCWAAANAAUIQwd3swCWAAACAAgIXABCTAADAAAAAA==.',['卩灬']='卩灬毒女乃粉:BAAALAAECgQIBAAAAA==.',['古伦']='古伦木:BAAALAAECgUIBgAAAA==.',['吥二']='吥二:BAAALAAECgYIEwAAAA==.',['吻如']='吻如雪下霜:BAAALAAECgYIBgAAAA==.',['命运']='命运之裁决:BAAALAADCggICAAAAA==.',['咖啡']='咖啡背后:BAAALAAFFAIIBAAAAA==.',['哟法']='哟法热儿:BAAALAAECgYICQAAAA==.',['喝咖']='喝咖啡的猴子:BAAALAAECgYIDAAAAA==.',['喝茶']='喝茶的猴子:BAAALAADCgIIAgAAAA==.',['嘻嘻']='嘻嘻嘿嘿吼吼:BAAALAAECgEIAQAAAA==.',['壞孩']='壞孩子:BAAALAAECgMIAgAAAA==.',['天殇']='天殇不当老大:BAABLAAFFH8RAAIOAAUIVRtZNwBhAQAOAAUIVRtZNwBhAQAAAA==.',['太慌']='太慌张的拥抱:BAAALAAECgYIDAAAAA==.',['夹心']='夹心灬盖伦:BAABLAAFFH8KAAIEAAIIwiPqMACoAAAEAAIIwiPqMACoAAAAAA==.夹心甜点:BAABLAAFFH8VAAMBAAYIJCFCBwDRAAALAAYIjByTGQC2AQABAAQIqSNCBwDRAAAAAA==.',['女魔']='女魔头:BAAALAADCgYIBAAAAA==.',['奶油']='奶油巧克力:BAAALAAECgYIBgAAAA==.',['如烟']='如烟:BAAALAAECgEIAQAAAA==.',['孟鲁']='孟鲁斯特:BAAALAAECggIEQAAAA==.',['宇智']='宇智波香蕉:BAAALAAECgYIBgAAAA==.',['安德']='安德鲁克:BAAALAAECgYIEQAAAA==.',['完全']='完全受不鸟拉:BAAALAADCgYIBgAAAA==.',['完美']='完美斩杀:BAAALAAECgYIAQAAAA==.',['寡人']='寡人有请爱妃:BAAALAAECggIAQABLAAFFAIIAgAPAAAAAA==.',['小三']='小三:BAAALAAFFAIIBAAAAA==.',['小灬']='小灬鲁:BAAALAAFFAIIAgAAAA==.',['小牛']='小牛牛:BAAALAAFFAIIAwAAAA==.',['山丘']='山丘蕨根:BAAALAADCgMIAwABLAAFFAYICAAEAFYjAA==.',['巧克']='巧克力:BAAALAAFFAIIAgABLAAFFAIIBAAPAAAAAA==.',['应该']='应该装傻:BAAALAAECggIEAAAAA==.',['弯弯']='弯弯的太阳:BAABLAAFFH8FAAINAAIIkRDDRgCZAAANAAIIkRDDRgCZAAAAAA==.',['彼得']='彼得猪:BAABLAAECn8WAAIQAAgIohtfJQBDAgAQAAgIohtfJQBDAgAAAA==.',['很好']='很好的坏人:BAABLAAECn8ZAAMNAAgIMSLeHAD/AgANAAgIMSLeHAD/AgACAAQIxw8AVwDFAAAAAA==.',['微风']='微风没她会吹:BAAALAAECgUIBQAAAA==.',['快到']='快到坑里来:BAAALAAECgYIEwAAAA==.',['恶魔']='恶魔猎雄:BAAALAAECgUIBwAAAA==.',['慕白']='慕白:BAACLAAFFH8WAAIRAAYIZgzoJQAyAQARAAYIZgzoJQAyAQAsAAQKfxcAAhEABgjHGl9hAMUBABEABgjHGl9hAMUBAAAA.',['我不']='我不是坏牛:BAAALAAECgIIAgAAAA==.',['我了']='我了个去:BAAALAADCggIDQAAAA==.',['我罩']='我罩蛋弟:BAAALAAECgEIAQAAAA==.',['打十']='打十个:BAAALAADCgUIBQAAAA==.',['找啊']='找啊找啊找:BAAALAAECggICAAAAA==.',['护蘇']='护蘇寶:BAAALAAECgYIBgAAAA==.',['摩拉']='摩拉克斯大王:BAAALAAECgYIBgAAAA==.',['斯特']='斯特莱夫:BAACLAAFFH8bAAIKAAUIuhNJJwA2AQAKAAUIuhNJJwA2AQAsAAQKfx8AAgoABwiaGutEACQCAAoABwiaGutEACQCAAAA.',['无敌']='无敌小涵涵:BAAALAAECggICAAAAA==.',['晓慧']='晓慧:BAAALAAECgIIAgAAAA==.',['曹飞']='曹飞之翼:BAAALAAECgcIBwAAAA==.',['月影']='月影悠悠:BAAALAAECgQIBAAAAA==.月影流砂:BAABLAAFFH8NAAINAAUItwv3MAD9AAANAAUItwv3MAD9AAAAAA==.',['望天']='望天大树:BAABLAAECn8hAAINAAcI6wysZwAzAQANAAcI6wysZwAzAQAAAA==.',['木易']='木易丹心:BAAALAAECgYICwAAAA==.',['杀戮']='杀戮丶:BAAALAAFFAIIAgAAAA==.',['来一']='来一发好不好:BAAALAAFFAIIBAAAAA==.',['果汁']='果汁小欣:BAAALAAECgcIDAAAAA==.',['枫枫']='枫枫叶飘飘:BAAALAAECgIIAgAAAA==.',['枫风']='枫风叶飘飘:BAAALAAECgYIDAAAAA==.',['桥本']='桥本奈奈未:BAAALAAECggIEAAAAA==.',['梦寐']='梦寐龙:BAABLAAFFH8JAAISAAIItRqJFQCfAAASAAIItRqJFQCfAAAAAA==.',['梦魂']='梦魂:BAAALAADCgcIBwAAAA==.',['楓桥']='楓桥落葉:BAAALAAECgYIBgAAAA==.',['橘子']='橘子味蟹老板:BAAALAAECgYIBgAAAA==.',['欧皇']='欧皇熊二:BAAALAAECggIAQAAAA==.',['死亡']='死亡晚礼服:BAABLAAFFH8TAAMMAAUI8hSGQQA1AQAMAAUIYhOGQQA1AQAHAAEI3xYUIQAAAAABLAAFFAUIGwAKALoTAA==.',['毒药']='毒药灵:BAAALAADCgYIBgAAAA==.',['水是']='水是这样喝的:BAAALAAECgYIEAAAAA==.',['沃噬']='沃噬蛛:BAAALAADCgcIBwAAAA==.',['波丶']='波丶:BAACLAAFFH8RAAMTAAMIQhTUCwCdAAATAAMIQhTUCwCdAAAMAAIIbQQXoQA0AAAsAAQKfx4AAxMACAjJGggGAAACABMACAh1GggGAAACAAwABAh0E5aXALcAAAAA.',['泰達']='泰達希爾:BAACLAAFFH8TAAIUAAUIvRJMBgA0AQAUAAUIvRJMBgA0AQAsAAQKfxYAAxQABgjnFZQQACkBABQABgjvEpQQACkBABUAAgjJF6keAIoAAAAA.',['洄游']='洄游鱼丶:BAAALAAFFAIIAwAAAA==.',['流逝']='流逝的星辰:BAACLAAFFH8SAAIOAAYIGxiJMAB2AQAOAAYIGxiJMAB2AQAsAAQKfxoAAw4ACAgYHhcjAC0CAA4ACAgYHhcjAC0CABYAAQiwBxoSADQAAAAA.',['海蓝']='海蓝回忆:BAAALAAECgMIAwAAAA==.',['温柔']='温柔之后:BAAALAAFFAIIBAAAAA==.',['潇湘']='潇湘水云:BAABLAAFFH8aAAITAAYISx5cAgC+AQATAAYISx5cAgC+AQABLAAFFAcIHwAEALgcAA==.',['火灬']='火灬火:BAAALAAFFAIIAgAAAA==.',['灬夜']='灬夜幕灬:BAAALAAECgYIBgAAAA==.灬夜雨声烦灬:BAACLAAFFH8TAAMRAAYIBBzlAwASAgARAAYIBBzlAwASAgAXAAEIEAYyPABNAAAsAAQKfxoAAhEACAgUHrYoAG8CABEACAgUHrYoAG8CAAAA.',['烟霞']='烟霞彩凤仙:BAAALAAECgcIBwAAAA==.',['無與']='無與倫比:BAAALAAECgYIEgAAAA==.',['牛德']='牛德一币:BAAALAAECgYIBgAAAA==.',['环城']='环城西路战神:BAAALAAECgEIAQAAAA==.',['琻刚']='琻刚娃转转猴:BAABLAAFFH88AAIYAAcIdhsmBQAQAgAYAAcIdhsmBQAQAgAAAA==.',['生命']='生命之輕:BAAALAAECgYICgAAAA==.',['破灭']='破灭重生:BAAALAAECgUIBQAAAA==.',['神兽']='神兽缺月:BAAALAADCgYIBgAAAA==.',['穆罗']='穆罗萨:BAAALAAECgIIAgAAAA==.',['箭过']='箭过无痕:BAABLAAECn8dAAMOAAgIVBW9WgCNAQAOAAgIVBW9WgCNAQAQAAEIwwPYzAAjAAAAAA==.',['紅顏']='紅顏殤:BAAALAAECgIIAgAAAA==.',['紫藤']='紫藤曼:BAAALAADCgQIBQAAAA==.',['紫鸢']='紫鸢回忆:BAAALAAECgYIBgAAAA==.',['绿罩']='绿罩子:BAABLAAFFH8YAAIMAAUI1hdSOwBNAQAMAAUI1hdSOwBNAQAAAA==.',['老酸']='老酸奶:BAABLAAFFH8FAAIMAAMISQfWagBnAAAMAAMISQfWagBnAAAAAA==.',['芙蘭']='芙蘭朵露:BAAALAAECgcIDwAAAA==.',['莪不']='莪不湜蓅氓:BAAALAADCgIIAgAAAA==.',['莪芣']='莪芣湜蓅氓:BAAALAAECgIIAgAAAA==.',['萌蹄']='萌蹄牛角包:BAAALAAECggIDAABLAAFFAgICgARAM0jAA==.',['葬花']='葬花蝶舞:BAAALAAFFAIIBAAAAA==.',['蕊丿']='蕊丿:BAAALAAECgIIAgAAAA==.',['藏灿']='藏灿:BAAALAAECgUIBAABLAAFFAIIAgAPAAAAAA==.',['藤田']='藤田琴音:BAAALAADCgMIAwAAAA==.',['蟹神']='蟹神:BAAALAAECggIDgABLAAFFAIIAgAPAAAAAA==.',['蟹蟹']='蟹蟹:BAAALAAECggIAwAAAA==.',['血域']='血域幽魂:BAAALAAECgUIBQAAAA==.',['角斗']='角斗士的灵魂:BAAALAAFFAIIAgABLAAFFAgIBAAPAAAAAA==.',['谁能']='谁能书阁下:BAAALAAECgUICAAAAA==.',['贝吉']='贝吉塔:BAAALAAECgYIBwAAAA==.',['赛利']='赛利亚克鲁敏:BAAALAAECgIIAgAAAA==.',['越喝']='越喝越有:BAAALAAECgQIBAAAAA==.',['越简']='越简单越好:BAAALAAECggIDQAAAA==.',['踢壹']='踢壹输出:BAABLAAFFH8SAAIMAAUIaxFUQAA5AQAMAAUIaxFUQAA5AQAAAA==.',['踢零']='踢零输出:BAABLAAFFH8QAAIZAAUI/w+BOwAZAQAZAAUI/w+BOwAZAQAAAA==.',['軍士']='軍士:BAABLAAFFH8HAAIKAAMIuxBYOACRAAAKAAMIuxBYOACRAAAAAA==.',['辉之']='辉之不去:BAAALAAECgMIAwAAAA==.',['辕门']='辕门射姬:BAABLAAFFH8GAAIOAAYIeRCROwBUAQAOAAYIeRCROwBUAQAAAA==.',['迷途']='迷途书童儿:BAAALAAECgYIBgAAAA==.',['追风']='追风风:BAAALAAECgYIBgAAAA==.',['逍遥']='逍遥无边:BAAALAAFFAIIAgAAAA==.',['逐影']='逐影:BAABLAAFFH8GAAIOAAYIoQrgSQAkAQAOAAYIoQrgSQAkAQAAAA==.',['钢蛋']='钢蛋儿:BAABLAAFFH8GAAIaAAYIexfcDgBbAQAaAAYIexfcDgBbAQAAAA==.',['阿华']='阿华田:BAAALAAFFAIIBAAAAA==.',['阿历']='阿历克斯:BAAALAAFFAEIAQAAAA==.',['阿格']='阿格拉玛:BAAALAAFFAEIAQAAAA==.阿格迪斯:BAABLAAFFH8GAAIOAAIILBK+XACOAAAOAAIILBK+XACOAAAAAA==.',['阿洗']='阿洗吧:BAAALAAFFAQIBAAAAA==.',['青玄']='青玄:BAAALAAFFAIIAgAAAA==.',['风枫']='风枫叶飘飘:BAAALAAECgYIBgAAAA==.',['风玫']='风玫影:BAAALAAECgMIAwAAAA==.',['飞天']='飞天鹌鹑:BAAALAAECgYICAAAAA==.',['魔仙']='魔仙堡练习生:BAABLAAFFH8KAAMYAAQIxAIcEACqAAAYAAQIxAIcEACqAAAbAAIIDwvjFgBlAAAAAA==.',['鹿晗']='鹿晗:BAAALAAFFAYIBAAAAA==.',['麟舞']='麟舞:BAAALAADCgEIAgAAAA==.',['黑娃']='黑娃:BAAALAADCgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end