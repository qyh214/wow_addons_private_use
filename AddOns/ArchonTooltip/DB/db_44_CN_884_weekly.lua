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
 local lookup = {'Hunter-BeastMastery','Shaman-Restoration','Unknown-Unknown','Monk-Windwalker','Hunter-Marksmanship','DeathKnight-Frost','Warlock-Destruction','Mage-Arcane','Mage-Fire','Shaman-Elemental','Paladin-Protection','Paladin-Retribution','Mage-Frost','Priest-Holy','Druid-Restoration','Druid-Feral','Druid-Guardian','Warrior-Fury','DemonHunter-Havoc','DeathKnight-Unholy','Evoker-Preservation','Paladin-Holy','Warlock-Demonology','Monk-Brewmaster','Monk-Mistweaver','Druid-Balance','Rogue-Assassination','Warrior-Protection','Rogue-Subtlety','Priest-Shadow','Warlock-Affliction','DemonHunter-Vengeance',}; local provider = {region='CN',realm='风暴之鳞',name='CN',type='weekly',zone=44,date='2025-12-10',data={Aa='Aatlass:BAAALAAFFAIIAgAAAA==.',Ac='Acq:BAAALAAECgYICgAAAA==.',Ak='Aksa:BAAALAAECgYIBgAAAA==.',An='Antclown:BAABLAAFFH8IAAIBAAYIgBlWBwAMAgABAAYIgBlWBwAMAgAAAA==.',Ar='Arthascris:BAAALAAFFAIIBAAAAA==.',At='Atlass:BAABLAAFFH8IAAICAAQIcAQbWABmAAACAAQIcAQbWABmAAABLAAFFAgIAgADAAAAAA==.',Ch='Chuanevil:BAAALAAECgYIDQAAAA==.',Co='Colelife:BAACLAAFFH8kAAIEAAYI+CH2BADAAQAEAAYI+CH2BADAAQAsAAQKfxUAAgQABwjqHnYcACECAAQABwjqHnYcACECAAAA.Coleworld:BAAALAADCggICAAAAA==.',Da='Dante:BAABLAAFFH8GAAIBAAII2APAuQAyAAABAAII2APAuQAyAAAAAA==.',Dd='Dd:BAABLAAFFH8pAAMBAAcIjB8ADQApAgABAAcIjB8ADQApAgAFAAEIVRb+MwBEAAABLAAFFAgIDAABAHghAA==.Ddkk:BAABLAAFFH8HAAIGAAIIyRsKRgCrAAAGAAIIyRsKRgCrAAAAAA==.',Dk='Dkhe:BAAALAAECgYIBgAAAA==.Dkhu:BAAALAAECgUIBQAAAA==.Dkhv:BAAALAAECgMIAwAAAA==.',Eb='Ebon:BAAALAAECgYIBgAAAA==.',Ei='Eileenliu:BAAALAAECgYIEgAAAA==.',El='Ele:BAAALAAECgMIAwAAAA==.',Em='Emls:BAAALAAECgMIAwAAAA==.Emoo:BAAALAAECggICAAAAA==.',En='Endlessrain:BAAALAAFFAIIAgAAAA==.',Fi='Fireclay:BAAALAAECgQIBQAAAA==.',Ho='Hoyo:BAAALAAFFAIIAgAAAA==.',Hu='Huntero:BAAALAAFFAIIBAAAAA==.',Ji='Jioneg:BAAALAAECgYIBgAAAA==.',Kn='Knirvanal:BAABLAAFFH8HAAIHAAYIGCEWIACgAQAHAAYIGCEWIACgAQAAAA==.',Ma='Marscattle:BAAALAAECgYICQAAAA==.',Me='Melochuan:BAAALAAECgUIBQAAAA==.',My='Myeileen:BAAALAAECgYIBgAAAA==.',Ne='Nestea:BAABLAAFFH8hAAMIAAYIFButFAC/AQAIAAYIFButFAC/AQAJAAII8gsuBgCQAAAAAA==.',Pl='Playerxrfagt:BAAALAAECgYICwAAAA==.',Re='Redminotaur:BAAALAAECgIIAgAAAA==.',Sf='Sfagfdsf:BAAALAAECggICAAAAA==.',Su='Sunnylife:BAABLAAFFH8NAAIGAAYIXiVbFwDkAQAGAAYIXiVbFwDkAQAAAA==.Sunsweet:BAAALAADCgQIBAAAAA==.',Sw='Swqs:BAAALAADCgIIAgAAAA==.',Ug='Uglybaby:BAAALAADCgIIAgAAAA==.',Wa='Warriorx:BAAALAADCggIEQAAAA==.',['一字']='一字齐肩眉:BAAALAAECgYICwAAAA==.',['一救']='一救自醉:BAAALAAFFAIIBAAAAA==.',['一自']='一自寻死路一:BAAALAAECgIIAgAAAA==.',['一赢']='一赢家一:BAAALAAFFAIIAgAAAA==.',['一骑']='一骑无尘:BAAALAAECgUIBgAAAA==.',['下一']='下一战天国:BAAALAAECggICAAAAA==.',['不会']='不会停的战思:BAAALAAECgIIAgAAAA==.不会停的裂银:BAAALAAECgEIAQAAAA==.',['不晓']='不晓得叫么斯:BAAALAAFFAMIAwAAAA==.',['不洁']='不洁的圣光:BAAALAAECgUIBQAAAA==.',['不要']='不要虚火:BAAALAAECgYIBgAAAA==.',['不辞']='不辞青山:BAAALAAECggICAAAAA==.',['不闻']='不闻之狐:BAAALAAECgQIBAAAAA==.',['与眉']='与眉毛共舞:BAABLAAFFH8GAAIHAAYIsQ7QLwBeAQAHAAYIsQ7QLwBeAQAAAA==.',['丨情']='丨情牵灬一世:BAAALAAECgYICAAAAA==.',['丨路']='丨路人甲丨:BAABLAAECn8VAAICAAcInw5+oQA7AQACAAcInw5+oQA7AQAAAA==.',['中单']='中单不给就送:BAAALAAECgEIAQAAAA==.',['丷岛']='丷岛风丷:BAAALAAECgMIAwAAAA==.',['丹星']='丹星星:BAAALAAECgYIDAAAAA==.',['丿訫']='丿訫:BAABLAAECn8WAAIBAAYIXhOrlwAoAQABAAYIXhOrlwAoAQAAAA==.',['九亿']='九亿少女的梦:BAAALAADCgQIBAAAAA==.',['乱跑']='乱跑跑丨:BAABLAAFFH8uAAIKAAcItxwACwADAgAKAAcItxwACwADAgAAAA==.',['人总']='人总是在受罪:BAABLAAFFH8UAAIIAAUItwzeNQCyAAAIAAUItwzeNQCyAAAAAA==.人总是在死亡:BAABLAAFFH8YAAIGAAUItR+gKAD2AAAGAAUItR+gKAD2AAAAAA==.人总是在颓废:BAABLAAFFH8TAAMLAAMIGSWhDQCwAAAMAAMIGSWNNgDZAAALAAMIyh+hDQCwAAABLAAFFAYIGAAGALUfAA==.',['仇伍']='仇伍仁化:BAAALAAECgYICgAAAA==.',['仙亦']='仙亦恋烦尘:BAAALAAECgYIBgAAAA==.',['会灬']='会灬长:BAAALAAECgYIBgAAAA==.',['似玉']='似玉坠入秋风:BAAALAADCgYIBAAAAA==.',['你很']='你很牛吗:BAAALAAECgYIBgAAAA==.',['修羅']='修羅大官人:BAAALAAECgYIDwAAAA==.',['偆俪']='偆俪:BAAALAADCgMIAwAAAA==.',['傏僧']='傏僧肉:BAAALAAECgEIAQAAAA==.',['僉刂']='僉刂:BAAALAAECgIIAgAAAA==.',['兜兜']='兜兜里的逗逗:BAAALAAECgYIBgAAAA==.',['公务']='公务灬猿:BAAALAAECgEIAQAAAA==.',['六翼']='六翼炽蛇:BAACLAAFFH8RAAMIAAMILg5SLQDcAAAIAAMIvg1SLQDcAAANAAIIZQ2XFQCBAAAsAAQKf0UAAwgACAjuILEdANoCAAgACAhAH7EdANoCAA0ABwh9FBsvAMABAAEsAAUUBggxAA0A6x0A.',['养殖']='养殖户丶:BAABLAAFFH8JAAIBAAYICyIwGgDTAQABAAYICyIwGgDTAQAAAA==.',['内脏']='内脏灬:BAAALAAECgEIAQAAAA==.',['册那']='册那队长:BAAALAADCgMIAwAAAA==.',['再让']='再让我躺会:BAAALAAECgYIAwAAAA==.',['冠希']='冠希的小尾巴:BAAALAAFFAIIBAAAAA==.',['冰凌']='冰凌恋:BAABLAAECn8ZAAIOAAYILAmCRgDHAAAOAAYILAmCRgDHAAAAAA==.',['冲锋']='冲锋陷阵:BAAALAAFFAIIBAAAAA==.',['凸凹']='凸凹凸:BAABLAAECn8ZAAIKAAYIIAhvUwDHAAAKAAYIIAhvUwDHAAAAAA==.',['创可']='创可贴:BAAALAAECgYIBgAAAA==.',['初相']='初相遇:BAAALAAECgYICAAAAA==.',['别打']='别打脸啊:BAAALAAECgMIAwAAAA==.',['刺刺']='刺刺背:BAAALAAECgQIBwAAAA==.',['副到']='副到:BAAALAAECgIIAgAAAA==.',['北方']='北方枭客:BAACLAAFFH8NAAICAAIIHRcoOwCKAAACAAIIHRcoOwCKAAAsAAQKfyQAAgIABgieIM0+ACICAAIABgieIM0+ACICAAAA.',['北落']='北落師門:BAAALAAFFAIIAgAAAA==.',['北风']='北风啸:BAAALAADCgEIAQAAAA==.',['千早']='千早星井:BAAALAAECgYICgAAAA==.',['千玉']='千玉千寻:BAAALAAECgcICAAAAA==.',['千里']='千里江陵:BAABLAAFFH8GAAIMAAIIEA62cwA9AAAMAAIIEA62cwA9AAAAAA==.',['半夏']='半夏灬微光:BAAALAADCgEIAQAAAA==.',['南奟']='南奟:BAAALAAECgYICQAAAA==.',['南悠']='南悠:BAABLAAFFH8GAAIMAAYI6BRlHACBAQAMAAYI6BRlHACBAQAAAA==.',['博文']='博文:BAABLAAFFH8uAAIGAAYIqiGjGADdAQAGAAYIqiGjGADdAQAAAA==.',['叄花']='叄花聚顶:BAAALAAFFAIIAgAAAA==.',['双子']='双子座灵灵:BAAALAAECggICAAAAA==.',['双马']='双马尾少女:BAAALAAECgMIBAAAAA==.',['反正']='反正不是我:BAABLAAFFH8IAAIMAAUIPQfMNADnAAAMAAUIPQfMNADnAAAAAA==.',['反浩']='反浩克乌龟:BAAALAAECgIIAgAAAA==.',['发抖']='发抖的小猫猫:BAAALAAECggICAAAAA==.',['发福']='发福的半藏:BAAALAAECgYIBgAAAA==.',['古爾']='古爾莫斯暗焰:BAAALAAECgYIBgAAAA==.',['吃一']='吃一个数一个:BAABLAAFFH8vAAIPAAcIGyJMAgAyAgAPAAcIGyJMAgAyAgAAAA==.',['吃猫']='吃猫的鱼:BAAALAAECgYIBgAAAA==.',['吃鱼']='吃鱼的喵儿:BAAALAAECgIIAgAAAA==.',['吾錓']='吾錓:BAAALAAECgEIAQAAAA==.',['呗呗']='呗呗丶:BAAALAAECgYICAAAAA==.呗呗龙:BAAALAAECgEIAQAAAA==.',['和风']='和风:BAAALAAECgMIAwAAAA==.',['咦鸡']='咦鸡娜慧:BAAALAADCggICAAAAA==.',['品尝']='品尝我的咸:BAAALAAECgYIBgAAAA==.',['哒嘎']='哒嘎嘎:BAAALAADCgYIBgAAAA==.',['唤灵']='唤灵哈尔:BAAALAAECgMIAwAAAA==.',['喜多']='喜多川海梦:BAABLAAFFH8NAAIGAAUIHxQWGgBbAQAGAAUIHxQWGgBbAQAAAA==.',['喵咕']='喵咕哔哔呦:BAACLAAFFH8KAAIQAAUIkwilBwACAQAQAAUIkwilBwACAQAsAAQKfxsAAhAACAitEHMNAGMBABAACAitEHMNAGMBAAAA.',['嗜血']='嗜血狂魔妮飘:BAAALAADCgYIBgAAAA==.',['嗯哼']='嗯哼嗯哼:BAAALAAECgQIBAAAAA==.',['嘟噜']='嘟噜嘟噜:BAABLAAECn8aAAMPAAgIRBzBFQAmAgAPAAgIRBzBFQAmAgARAAcIFBROGgBNAQAAAA==.',['嘿丶']='嘿丶来一发:BAABLAAFFH8GAAIIAAIIShnLUABOAAAIAAIIShnLUABOAAAAAA==.',['噩梦']='噩梦宝宝:BAAALAAECggICAAAAA==.',['国服']='国服第一杰宝:BAAALAAFFAMIAwAAAA==.',['國寳']='國寳丶锋锋:BAAALAAECgMIAwAAAA==.',['土豆']='土豆烤肉:BAAALAADCgIIAgAAAA==.',['土间']='土间埋:BAAALAADCgUIBQAAAA==.',['土黄']='土黄色萨满:BAABLAAFFH8IAAISAAIIsiRhHgDVAAASAAIIsiRhHgDVAAABLAAFFAcICAAKADQTAA==.',['圣云']='圣云星光:BAABLAAFFH8PAAIMAAIILB2xKgC0AAAMAAIILB2xKgC0AAAAAA==.',['圣光']='圣光护佑着你:BAABLAAFFH8VAAIMAAYIkRrZFwCaAQAMAAYIkRrZFwCaAQAAAA==.圣光跟你有仇:BAAALAAECgYIBgAAAA==.圣光阿西利亚:BAAALAADCgcIBwAAAA==.',['坏坏']='坏坏笑:BAAALAAECgcIDAAAAA==.',['坚强']='坚强狐狸:BAAALAAECggICAAAAA==.',['垃圾']='垃圾火法:BAAALAADCgcIBwAAAA==.',['城春']='城春灬草木深:BAAALAAFFAIIBAAAAA==.',['墓尸']='墓尸小妹子:BAAALAAECgYICwAAAA==.',['墨尔']='墨尔本丨晴:BAAALAAECgYIEAAAAA==.',['墨漓']='墨漓丶:BAAALAAECgYICgAAAA==.',['夕諾']='夕諾:BAAALAAFFAYIAgAAAA==.',['夙吉']='夙吉:BAABLAAFFH8GAAICAAIIKRGPYABdAAACAAIIKRGPYABdAAAAAA==.',['多久']='多久开网吧:BAABLAAFFH8xAAMCAAcImRydCQA0AgACAAcImRydCQA0AgAKAAIIdA4GRABFAAAAAA==.',['夜之']='夜之雪饭团:BAACLAAFFH8TAAIIAAQIchRRPQDeAAAIAAQIchRRPQDeAAAsAAQKfyYAAwgABghFIuAaANMBAAgABghFIuAaANMBAA0AAwhpFft0AJgAAAAA.',['夜牧']='夜牧杀手:BAAALAADCgYIBgAAAA==.',['夜的']='夜的不死神:BAAALAAFFAMIAwAAAA==.',['大咴']='大咴熊:BAAALAADCgMIBAAAAA==.',['大地']='大地之原:BAAALAAECgYIDAAAAA==.',['大漠']='大漠孤鹰:BAAALAAECgYIBgAAAA==.',['大菠']='大菠萝三:BAAALAAECggIBAAAAA==.',['大酋']='大酋长:BAAALAAFFAYIBAAAAA==.',['天人']='天人合一:BAAALAAECgUIBQAAAA==.',['天秤']='天秤座点点:BAAALAAECggIEAAAAA==.天秤座聪聪:BAAALAAECggICAAAAA==.',['天策']='天策皮卡丘:BAAALAAECgYIBgAAAA==.',['头铁']='头铁老舅:BAAALAAECgEIAQAAAA==.',['奇异']='奇异果丶追梦:BAAALAADCgQIBAAAAA==.',['奥拉']='奥拉姆多:BAAALAADCgYIBgAAAA==.',['如甜']='如甜蜜是凶手:BAABLAAFFH8cAAICAAgI6Bj8BwBJAgACAAgI6Bj8BwBJAgAAAA==.',['妍丶']='妍丶爱:BAAALAADCgEIAQAAAA==.',['妖娆']='妖娆春秋:BAAALAADCgQIBAAAAA==.',['姚帅']='姚帅:BAAALAAECgEIAQAAAA==.',['婉拒']='婉拒迪丽热巴:BAACLAAFFH8LAAITAAMIgxQkPwCWAAATAAMIgxQkPwCWAAAsAAQKfxoAAhMABgigHCiEAL0BABMABgigHCiEAL0BAAAA.',['定风']='定风波丶:BAACLAAFFH8HAAMUAAIIjRVmEQBQAAAGAAIIGAz9dgCMAAAUAAIIjRVmEQBQAAAsAAQKfxUAAwYABghxGm+UANgBAAYABghxGm+UANgBABQABgg1Ea4QACcBAAAA.',['寂寞']='寂寞丶情调:BAAALAAFFAIIBAAAAA==.',['富婆']='富婆通讯录:BAAALAAECgYIBwAAAA==.',['寳唄']='寳唄吥哭:BAABLAAFFH8GAAIBAAIISRkYRgCeAAABAAIISRkYRgCeAAAAAA==.',['射爆']='射爆煤气罐:BAAALAAFFAIIAgAAAA==.',['小小']='小小的心愿:BAABLAAFFH8GAAIBAAYIGRGMRAA/AQABAAYIGRGMRAA/AQAAAA==.小小雪翼:BAAALAAECgYICAAAAA==.',['小术']='小术也疯狂:BAAALAAECgYICgAAAA==.',['小林']='小林酱:BAAALAAECgMIAwAAAA==.',['小熊']='小熊喜欢下雪:BAAALAADCggICAAAAA==.小熊爱钓鱼:BAAALAADCgYIBgAAAA==.',['小牛']='小牛爱吃饼干:BAAALAADCgMIAwAAAA==.',['小白']='小白灬:BAABLAAFFH8LAAIGAAYIlhxGKQCXAQAGAAYIlhxGKQCXAQAAAA==.',['小福']='小福福来啦:BAAALAAECgQIBAAAAA==.',['小龙']='小龙人呀:BAAALAAECgEIAQAAAA==.小龙家小林:BAABLAAFFH88AAIVAAcI2hXcAwDlAQAVAAcI2hXcAwDlAQAAAA==.',['屠戮']='屠戮:BAABLAAFFH8JAAIWAAQIJR5TEwBeAQAWAAQIJR5TEwBeAQAAAA==.',['巜没']='巜没有蛀牙:BAAALAAECgYIBwAAAA==.',['巜牧']='巜牧头人:BAAALAAFFAIIBAAAAA==.',['巨龙']='巨龙家巨林:BAAALAAECgQIAgAAAA==.',['布丽']='布丽丝:BAAALAADCgUIBQAAAA==.',['帅小']='帅小伙邓肯:BAAALAAFFAIIAgAAAA==.',['希維']='希維婭凋零者:BAAALAAECgYIEAAAAA==.',['帝凇']='帝凇:BAABLAAFFH8IAAIXAAII7R/wCgC1AAAXAAII7R/wCgC1AAAAAA==.',['干涉']='干涉给我:BAABLAAFFH8IAAIPAAgIqgBwYwAVAAAPAAgIqgBwYwAVAAAAAA==.',['平板']='平板支撑:BAAALAAECgYIBgAAAA==.',['异色']='异色眼柠檬心:BAAALAAECgYICAAAAA==.',['弃弃']='弃弃丢了:BAAALAAECggICAAAAA==.',['引体']='引体向上:BAAALAAECgYIDAAAAA==.',['弦上']='弦上春雪:BAABLAAFFH8zAAIYAAcInSGzAgAsAgAYAAcInSGzAgAsAgAAAA==.',['御龙']='御龙在天:BAAALAAECgMIAwAAAA==.',['心臓']='心臓壊了丿:BAAALAAFFAIIBAAAAA==.',['忘川']='忘川蒹葭:BAABLAAFFH8KAAIFAAIIqR9QGgChAAAFAAIIqR9QGgChAAABLAAFFAcIPAAVANoVAA==.',['快乐']='快乐火舞流沙:BAAALAAFFAIIAgAAAA==.',['念念']='念念不忘:BAABLAAFFH8KAAIOAAMIbAXCNgCMAAAOAAMIbAXCNgCMAAAAAA==.',['性感']='性感小兽猫:BAAALAAECgYIBgAAAA==.',['恐怖']='恐怖的力量:BAAALAAECgYIBgAAAA==.',['恶魔']='恶魔之击:BAAALAADCgYIDAAAAA==.恶魔赦令:BAAALAAECgYIBgAAAA==.',['悄悄']='悄悄咪咪射你:BAABLAAFFH8jAAIBAAYI9SRpCgDpAQABAAYI9SRpCgDpAQAAAA==.',['悬垂']='悬垂举腿:BAAALAAECgYIBgAAAA==.',['惊世']='惊世帅气:BAAALAAECgYIDAAAAA==.',['愤怒']='愤怒的小火鸡:BAACLAAFFH8aAAINAAYIxBYNBQB+AQANAAYIxBYNBQB+AQAsAAQKfyQAAw0ACAizIaUIAAsDAA0ACAizIaUIAAsDAAgAAQgSE/T+AD4AAAAA.愤怒的牛牛:BAABLAAFFH8TAAIMAAUI8AfSNQDeAAAMAAUI8AfSNQDeAAAAAA==.',['我们']='我们是十七强:BAABLAAFFH8IAAIKAAIIDRtaJACfAAAKAAIIDRtaJACfAAAAAA==.',['我在']='我在减肥:BAAALAAECgYICgAAAA==.',['我是']='我是小怪兽:BAAALAAECgYIBgAAAA==.',['我的']='我的闪现呢丶:BAAALAADCgcIBgAAAA==.',['战噗']='战噗拉丝:BAAALAADCgMIAwAAAA==.',['房灰']='房灰逢:BAAALAAECgYIBwAAAA==.',['扑街']='扑街小超:BAABLAAFFH8GAAIPAAIIwAvCPwBgAAAPAAIIwAvCPwBgAAAAAA==.',['打上']='打上花火:BAAALAAECgYIBwAAAA==.',['打我']='打我队友:BAAALAAFFAIIAgAAAA==.',['扬州']='扬州刘海柱:BAAALAADCgEIAQAAAA==.',['扶苏']='扶苏:BAAALAAECggICAAAAA==.',['技高']='技高一筹:BAAALAAFFAIIAgAAAA==.',['护国']='护国神喵:BAAALAAECgYIEgAAAA==.',['拉克']='拉克萨斯:BAAALAAFFAIIAwAAAA==.',['拉维']='拉维蒂亚:BAAALAAECgYIBgAAAA==.',['拳王']='拳王福汉:BAABLAAFFH8LAAMYAAYI7wl/CABhAQAYAAYI7wl/CABhAQAZAAIIpxoXDwCcAAABLAAFFAgIBgAWAOIhAA==.',['拽破']='拽破猎猎:BAACLAAFFH8IAAIBAAYIagyPEACoAQABAAYIagyPEACoAQAsAAQKfxYAAwUACAhHIRsqACYCAAUACAhmGxsqACYCAAEACAh6HOJoAAkCAAAA.',['拿铁']='拿铁:BAAALAAECgYIBgAAAA==.',['挖的']='挖的一手好坟:BAAALAAECgYIBgAAAA==.',['挥挥']='挥挥手全是狗:BAAALAAFFAIIAgAAAA==.',['捶你']='捶你膝盖:BAAALAAECgYICgAAAA==.',['插不']='插不够:BAAALAAECgYICQAAAA==.',['改个']='改个名字:BAAALAAECggIDgABLAAFFAcIGAACAD4UAA==.',['斩杀']='斩杀冲钅未归:BAABLAAFFH8FAAISAAII1Rv2JQCtAAASAAII1Rv2JQCtAAAAAA==.',['旋转']='旋转吧:BAABLAAFFH8HAAIPAAIIVSXgFQDNAAAPAAIIVSXgFQDNAAABLAAFFAcICAAKADQTAA==.',['无夜']='无夜:BAAALAAECgYIDAAAAA==.',['无敌']='无敌小术术:BAAALAAECgQIBAAAAA==.',['无昼']='无昼:BAAALAAECgYIBgAAAA==.',['明天']='明天天晴:BAACLAAFFH8KAAIGAAIIhB+SPgC1AAAGAAIIhB+SPgC1AAAsAAQKfxkAAgYACAjQIKAdAPkCAAYACAjQIKAdAPkCAAAA.',['明日']='明日之炎:BAAALAADCggICgAAAA==.',['昔曰']='昔曰战神:BAAALAAECgYIDgAAAA==.',['星凝']='星凝:BAAALAAECgYICAAAAA==.',['星星']='星星相惜:BAABLAAFFH8fAAMXAAYI1g3fBAD0AAAHAAYIgwvHMgBQAQAXAAMI5RPfBAD0AAAAAA==.',['春暖']='春暖花開:BAAALAAECgQIBAAAAA==.',['晴儿']='晴儿:BAAALAAECgQIBAAAAA==.',['晴天']='晴天娃娃:BAABLAAFFH8GAAMNAAIIXw8IEwCIAAANAAIIXw8IEwCIAAAIAAEIoAVkcAAAAAAAAA==.晴天小猪灬:BAAALAAECgYICQAAAA==.',['暗藏']='暗藏箭枪:BAAALAAFFAIIAgAAAA==.',['暧光']='暧光昧影:BAAALAAFFAIIAwAAAA==.',['曾经']='曾经无沧海:BAAALAAECgIIAwAAAA==.',['最终']='最终之奥:BAAALAADCgMIAwAAAA==.',['最高']='最高:BAABLAAFFH8GAAICAAYIoBK9CACxAQACAAYIoBK9CACxAQAAAA==.',['月下']='月下:BAAALAAECgQIAgAAAA==.',['月朗']='月朗风清:BAAALAAECgMIAwAAAA==.',['有过']='有过去的男人:BAAALAADCgcIBwAAAA==.',['朋友']='朋友你缺德么:BAABLAAECn8hAAMaAAgIZBmCEQD3AQAaAAgIZBmCEQD3AQAQAAYIWRGSEwABAQAAAA==.',['朝阳']='朝阳群众:BAABLAAFFH8gAAIGAAUITQ2cSAAfAQAGAAUITQ2cSAAfAQAAAA==.',['木馬']='木馬摇摇乐:BAABLAAFFH8FAAIHAAIIgAKxcgAqAAAHAAIIgAKxcgAqAAAAAA==.',['末那']='末那:BAAALAAECgUIDwAAAA==.',['术爷']='术爷来了:BAAALAAECgYIEgAAAA==.',['杀魔']='杀魔救拧:BAAALAAECgYIDAAAAA==.',['权一']='权一:BAAALAAECgEIAQAAAA==.',['板甲']='板甲牛:BAAALAAECggICAAAAA==.',['果果']='果果兽:BAAALAAFFAIIAgAAAA==.',['果菓']='果菓娃:BAABLAAFFH8GAAIBAAIIBBDMnQBAAAABAAIIBBDMnQBAAAAAAA==.',['枫之']='枫之王子:BAAALAAECgcICQAAAA==.',['枫林']='枫林三元及第:BAAALAAECgYIBwAAAA==.枫林唤雨:BAABLAAECn8ZAAICAAYICRpHcACiAQACAAYICRpHcACiAQAAAA==.枫林国士无双:BAAALAAFFAIIAgAAAA==.枫林星辰:BAAALAAFFAIIAgAAAA==.枫林晴飔:BAAALAAFFAIIAgAAAA==.枫林望舒:BAAALAAECgYIDAAAAA==.枫林止默:BAAALAAECgYICwAAAA==.枫林沐白:BAAALAAECgYIEQAAAA==.枫林火山:BAAALAAECgYIEgAAAA==.枫林灵泽:BAAALAAECgYIBgAAAA==.枫林翻雨:BAAALAAECgYIDAAAAA==.枫林苍月:BAAALAAECgYIDAAAAA==.枫林覆雨:BAABLAAECn8ZAAIXAAYIzhOYPAB6AQAXAAYIzhOYPAB6AQABLAAFFAgIKwAHAOQkAA==.枫林雷鸣:BAAALAAECgYIBgAAAA==.枫林骄阳:BAAALAAFFAIIAgAAAA==.',['枫枫']='枫枫打疯疯:BAAALAAECgMIAwAAAA==.枫枫王子:BAAALAADCgIIAgAAAA==.枫枫的小骑士:BAAALAADCgMIBAAAAA==.',['某小']='某小骑丶:BAAALAAECgYIBgAAAA==.',['栗桃']='栗桃婉:BAAALAAFFAIIBAAAAA==.',['栩栩']='栩栩:BAAALAAECgUIBgAAAA==.',['格林']='格林卡本:BAABLAAFFH8oAAMBAAYIbiTpFADxAQABAAYIbiTpFADxAQAFAAQIoBtBDwD6AAAAAA==.',['桂芬']='桂芬:BAAALAAFFAIIAgAAAA==.',['梅花']='梅花三弄:BAAALAAECgYIBwAAAA==.',['梦灬']='梦灬半朵雲:BAAALAADCgcIBwAAAA==.',['梨花']='梨花灬雨凉:BAAALAADCgQIBAAAAA==.',['森林']='森林大灰狼:BAAALAAECgMIAwAAAA==.森林小红帽:BAAALAAECgYICAAAAA==.森林小赖赖:BAAALAAECgYICAAAAA==.',['橙心']='橙心橙意:BAAALAAECgYIDAAAAA==.',['死亡']='死亡赞美诗:BAAALAAECgYIBgAAAA==.',['死性']='死性不改:BAAALAAECgUIAwAAAA==.',['死缠']='死缠了不用奶:BAABLAAFFH8GAAIHAAII8xcXOQCgAAAHAAII8xcXOQCgAAAAAA==.',['死骑']='死骑小妹妹:BAAALAAECgEIAQAAAA==.',['毛毛']='毛毛蛆:BAAALAADCgEIAQAAAA==.',['水泠']='水泠月:BAAALAAFFAMIAwAAAA==.',['沉吟']='沉吟至今:BAAALAADCgEIAQAAAA==.',['沙漏']='沙漏倒装回忆:BAAALAAECgYICwAAAA==.',['没血']='没血了吃糖呀:BAABLAAFFH8IAAMKAAQINBNaGQDpAAAKAAMIEBdaGQDpAAACAAQICCFmJwC2AAAAAA==.',['法力']='法力残渣:BAAALAAFFAYIAgABLAAFFAgIHgAIAAccAA==.',['法式']='法式摩卡:BAAALAAECgEIAQAAAA==.',['法神']='法神领域:BAAALAAECgUIBQAAAA==.',['注意']='注意有熊岀沒:BAAALAAECgIIAgAAAA==.',['泪之']='泪之彼端:BAAALAAECgYIBgAAAA==.',['洛依']='洛依依:BAACLAAFFH8TAAIOAAMI1grZMQClAAAOAAMI1grZMQClAAAsAAQKfx4AAg4ABwglFNolAIoBAA4ABwglFNolAIoBAAAA.',['流氓']='流氓的术师:BAAALAAECgYICgAAAA==.',['流風']='流風回雪:BAABLAAFFH8GAAIIAAQIdA6IIAAnAQAIAAQIdA6IIAAnAQAAAA==.',['浅云']='浅云流裳:BAAALAAECgYIBgAAAA==.',['浅末']='浅末:BAAALAADCgIIAgAAAA==.',['浩劫']='浩劫小渤:BAAALAAECgYIBwAAAA==.',['浮世']='浮世三千:BAAALAAFFAIIAgAAAA==.',['海豚']='海豚炒年糕:BAAALAAECggICgAAAA==.',['海魄']='海魄:BAAALAAFFAEIAQAAAA==.',['深海']='深海丶:BAAALAAFFAMIAgAAAA==.',['混学']='混学带师:BAABLAAFFH8HAAIVAAYIuguSDwBBAQAVAAYIuguSDwBBAQAAAA==.',['清蒸']='清蒸鳕鱼片:BAAALAAECgMIAwAAAA==.',['渣男']='渣男耍闪电:BAAALAAFFAIIAgAAAA==.',['满怒']='满怒斩:BAABLAAFFH8HAAISAAIIsAtPSgBKAAASAAIIsAtPSgBKAAAAAA==.',['澹台']='澹台暖树:BAAALAAECggIAQAAAA==.',['激流']='激流涌进:BAAALAAECgEIAQAAAA==.',['火焰']='火焰冲天:BAAALAAECgQIBAAAAA==.',['火狐']='火狐天使:BAAALAAECgYIBgAAAA==.火狐蛮萨:BAABLAAFFH8UAAMCAAYIxB1ZGQCXAQACAAUIZB1ZGQCXAQAKAAUI4hJyJQAgAQAAAA==.',['火雨']='火雨法:BAABLAAFFH8IAAIHAAII7hd3OAChAAAHAAII7hd3OAChAAAAAA==.',['灬寵']='灬寵愛灬:BAAALAAECgQIBAAAAA==.',['灬小']='灬小白:BAABLAAFFH8IAAIbAAIIRRdXFACsAAAbAAIIRRdXFACsAAAAAA==.',['灰色']='灰色的轨迹:BAAALAAFFAIIAgABLAAFFAcINAAFAHckAA==.',['灵魂']='灵魂使徒:BAAALAAECgYIBgAAAA==.',['烟雨']='烟雨泷:BAACLAAFFH80AAMFAAcIdyRtAQBPAgAFAAYIsCVtAQBPAgABAAUIdxy0IQD9AAAsAAQKfxUAAwUACAh8JMkYAJ0CAAUACAj7IMkYAJ0CAAEABAiYI7zOANwAAAAA.烟雨落流星:BAAALAAFFAIIBAAAAA==.',['烤肉']='烤肉土豆:BAAALAAECgQIBAAAAA==.',['焚天']='焚天帝:BAABLAAFFH8HAAIIAAIIfRDGWQBCAAAIAAIIfRDGWQBCAAAAAA==.',['牛丸']='牛丸师傅:BAABLAAFFH8IAAIZAAIIAhp+DgClAAAZAAIIAhp+DgClAAAAAA==.',['牛牛']='牛牛来辣:BAACLAAFFH8gAAICAAgICh2YAgDHAgACAAgICh2YAgDHAgAsAAQKfxQAAgIABggvHYlbANQBAAIABggvHYlbANQBAAAA.',['牛皮']='牛皮德:BAABLAAFFH8ZAAMaAAUIkhv6FwAgAQAaAAUIkhv6FwAgAQAPAAMIBQpQMQByAAABLAAFFAYIKAABAG4kAA==.',['牧大']='牧大果:BAAALAAECgYIDwAAAA==.',['狂徒']='狂徒:BAAALAADCgQIBgAAAA==.',['狂暴']='狂暴雷霆:BAAALAAECgEIAQAAAA==.',['狐中']='狐中哈士奇:BAAALAADCgMIAwAAAA==.',['狐星']='狐星高照:BAAALAAECgIIAgAAAA==.',['猎之']='猎之魏丶:BAABLAAECn8aAAMBAAgILxqNZQAQAgABAAYIHB+NZQAQAgAFAAgIbw6ETACDAQABLAAFFAIIBAADAAAAAA==.',['猎光']='猎光光头:BAAALAAECgYIDQAAAA==.',['猎天']='猎天使男爵:BAACLAAFFH8GAAIBAAII7BQlmABDAAABAAII7BQlmABDAAAsAAQKfxUAAwUABggxHGNbAE0BAAUABgj6E2NbAE0BAAEAAwg0I+SgABsBAAAA.',['玛格']='玛格部落:BAAALAAFFAIIBAAAAA==.',['玲珑']='玲珑馆美纱夜:BAAALAAECgUIBgAAAA==.',['珑珑']='珑珑:BAAALAAECgYIBgAAAA==.',['珞瑜']='珞瑜哥哥:BAABLAAFFH8FAAICAAII5wSocgBJAAACAAII5wSocgBJAAAAAA==.',['琥糖']='琥糖:BAAALAAECggICAAAAA==.',['疯狂']='疯狂的今天:BAAALAAECgUIBwAAAA==.疯狂的番茄:BAAALAAECgEIAQAAAA==.疯狂迪迪:BAAALAAECgYIDwAAAA==.',['痛苦']='痛苦的月色:BAAALAADCgcIBwAAAA==.',['白丶']='白丶巧克力:BAAALAAFFAIIAgAAAA==.白丶果冻:BAAALAAECgYIBgAAAA==.',['白牛']='白牛警长:BAAALAADCgEIAQAAAA==.',['白羽']='白羽璃洛:BAABLAAFFH8MAAIGAAIIoAu8egCKAAAGAAIIoAu8egCKAAAAAA==.',['盲人']='盲人按摩师:BAABLAAECn8YAAIGAAgI1xavYwAuAgAGAAgI1xavYwAuAgAAAA==.',['相生']='相生克乘相悔:BAAALAAECgYIBgAAAA==.',['眉毛']='眉毛一号:BAAALAAECgQIBAAAAA==.',['看我']='看我凶咩:BAAALAAECgEIAQAAAA==.',['睿智']='睿智的猫咪:BAABLAAFFH8HAAIBAAMI6wn6egBsAAABAAMI6wn6egBsAAAAAA==.',['石敢']='石敢当:BAABLAAFFH8KAAIBAAIIBxWjXQCNAAABAAIIBxWjXQCNAAAAAA==.',['磷霖']='磷霖:BAAALAAFFAIIBAAAAA==.',['祖爾']='祖爾坎噬魂者:BAAALAAECgMIAwAAAA==.',['神之']='神之慰:BAABLAAFFH8JAAIOAAIIlx6rMgChAAAOAAIIlx6rMgChAAAAAA==.',['神力']='神力:BAABLAAFFH8GAAMSAAYIpwWhPACFAAASAAQIJAehPACFAAAcAAIIrQI7KQBDAAAAAA==.',['神慕']='神慕慕:BAAALAAFFAIIBAAAAA==.',['福福']='福福小仙:BAAALAADCgYIBgAAAA==.',['秀儿']='秀儿跳火车:BAAALAADCgYIBgAAAA==.',['立丶']='立丶夏:BAAALAAECgcICwAAAA==.',['符华']='符华:BAAALAAECgYIBwAAAA==.',['简丶']='简丶静:BAAALAAFFAIIAgAAAA==.',['精灵']='精灵丶猎:BAAALAADCgYIBgAAAA==.',['紫金']='紫金之魂:BAAALAAECggIBAAAAA==.',['絡依']='絡依依:BAAALAAECgQIBwAAAA==.',['红尘']='红尘恋曲:BAAALAADCgIIAgAAAA==.',['红糖']='红糖糍粑:BAAALAAECgYIDgAAAA==.',['纯情']='纯情小狸猫:BAAALAAECgYIBgAAAA==.',['纳兹']='纳兹丶多拉格:BAAALAAECgYIBgAAAA==.',['纷飞']='纷飞默雪:BAAALAADCgcIBwAAAA==.',['练级']='练级好累:BAAALAAECgQIBAAAAA==.',['绯啊']='绯啊绯:BAABLAAFFH8IAAIHAAIIcwuBYQA/AAAHAAIIcwuBYQA/AAAAAA==.',['维蒂']='维蒂利亚:BAAALAAECgYIBgAAAA==.',['绿皮']='绿皮丶萨:BAABLAAECn8YAAMCAAcIiBrcZwC2AQACAAYIlRvcZwC2AQAKAAcI4AhcegBRAQAAAA==.',['缚神']='缚神:BAAALAADCgMIAwAAAA==.',['缺徳']='缺徳就要團滅:BAAALAAECgQIBAAAAA==.',['罖杔']='罖杔嵤皐:BAAALAAECgYIEgAAAA==.',['美式']='美式咖啡:BAAALAAECgEIAQAAAA==.',['翱翔']='翱翔:BAACLAAFFH8HAAMNAAIILQZ3GgBsAAANAAII5QV3GgBsAAAIAAEIYgUHcAAqAAAsAAQKfxcAAw0ABggSGk5JAEsBAAgABgggE3yLAHYBAA0ABAh0HU5JAEsBAAAA.',['老宫']='老宫:BAABLAAFFH8lAAMbAAYI3BgGBgBzAQAbAAUIHhsGBgBzAQAdAAIIjg4uFACKAAAAAA==.',['老花']='老花包谷:BAAALAAECgYICQAAAA==.',['聂银']='聂银琪:BAABLAAFFH8MAAMOAAYI1BzNDQBuAQAOAAUIaxzNDQBuAQAeAAEI8CFFJABfAAAAAA==.',['聖者']='聖者遺物:BAAALAAECggIDgAAAA==.',['胸多']='胸多基少:BAAALAAECgQIBAAAAA==.',['脑浆']='脑浆:BAACLAAFFH8mAAIHAAcI+R2REwD2AQAHAAcI+R2REwD2AQAsAAQKf0oAAwcACAi7JXcCAAcDAAcACAi7JXcCAAcDAB8AAggOE6UvAHgAAAAA.',['自找']='自找伞渡:BAAALAAECgYIBwAAAA==.',['舞幽']='舞幽丶蒔舞:BAAALAADCgQIBAAAAA==.',['艾伊']='艾伊丝:BAAALAADCggICAAAAA==.',['艾蓉']='艾蓉儿:BAAALAAECgMIAwAAAA==.',['花都']='花都唐:BAAALAAFFAIIAgAAAA==.',['芽儿']='芽儿看:BAAALAADCgIIAgAAAA==.',['苍月']='苍月厶塞亚:BAAALAAECgMIAwAAAA==.',['苏州']='苏州梅友机场:BAABLAAFFH8GAAIEAAYIKxXOBwB7AQAEAAYIKxXOBwB7AQAAAA==.',['英勇']='英勇归来:BAAALAAECggICAAAAA==.',['范桶']='范桶水:BAAALAADCgIIAgAAAA==.',['茶叶']='茶叶蛋:BAAALAAECgQIBgAAAA==.',['莱莎']='莱莎琳:BAAALAAECgYICQAAAA==.',['菲米']='菲米莉丝:BAABLAAECn8bAAIMAAcILBc3gADrAQAMAAcILBc3gADrAQAAAA==.',['萌儿']='萌儿:BAABLAAFFH8NAAMPAAYI/BecCACMAQAPAAUIzBqcCACMAQAaAAEIUQdGLABMAAAAAA==.',['萨不']='萨不住了:BAABLAAFFH8IAAICAAMIHBpyMwDgAAACAAMIHBpyMwDgAAAAAA==.',['萨拉']='萨拉丁之力:BAAALAAECgYIDwAAAA==.',['萨爷']='萨爷:BAAALAAFFAIIAgAAAA==.',['落叶']='落叶泛黄:BAAALAAFFAIIAgAAAA==.',['落花']='落花微雨:BAAALAADCggICAAAAA==.落花逸秋水:BAAALAAECgQIBAAAAA==.',['葉什']='葉什麽什麽枫:BAAALAAECggIEAAAAA==.',['葡萄']='葡萄糖酸钙:BAAALAAECgYIBgAAAA==.',['蒼瀾']='蒼瀾:BAACLAAFFH8LAAIOAAMILQ4wMwCfAAAOAAMILQ4wMwCfAAAsAAQKfycAAg4ACAgRE2kqAGkBAA4ACAgRE2kqAGkBAAAA.',['蓝丶']='蓝丶喵喵:BAAALAAECgEIAQAAAA==.',['蓝光']='蓝光闪烁:BAAALAAFFAIIAgAAAA==.',['薙切']='薙切绘里奈:BAAALAADCgEIAQAAAA==.',['薩爾']='薩爾:BAAALAAECgYIDQAAAA==.',['虚惊']='虚惊一场梦:BAAALAAFFAIIBAAAAA==.',['蛮干']='蛮干:BAAALAAECggIEAAAAA==.',['蜡笔']='蜡笔小鑫:BAAALAAECgYIBwAAAA==.',['融雪']='融雪:BAAALAAECgEIAQAAAA==.',['血之']='血之审判:BAAALAAECgYIDAAAAA==.',['血兽']='血兽来了:BAABLAAFFH8OAAIOAAQIvRrlDQBsAQAOAAQIvRrlDQBsAQABLAAFFAcICAAKADQTAA==.',['血刃']='血刃天下:BAACLAAFFH8FAAISAAMImxP9PACDAAASAAMImxP9PACDAAAsAAQKfyYAAxIACAiIJMARAFsCABIACAiIJMARAFsCABwABAhTGOQ0AMgAAAEsAAUUBggGABwAqwkA.',['血得']='血得呼唤:BAAALAAECgIIAgAAAA==.',['血源']='血源病注射器:BAABLAAFFH8tAAQQAAcIQRu5AgDHAQAQAAYI5hy5AgDHAQAPAAIIeQuULwB1AAAaAAEIAAnWMgA/AAAAAA==.',['血色']='血色那抹残阳:BAAALAAECgYIBgAAAA==.',['西大']='西大六纲:BAAALAADCgEIAQAAAA==.',['西山']='西山经:BAAALAAECgEIAQAAAA==.',['角得']='角得板板:BAAALAAECgYIBgAAAA==.',['解围']='解围:BAAALAADCgEIAQAAAA==.',['让我']='让我毛点伤害:BAAALAAECgUIBQAAAA==.',['请你']='请你吃丿牛鞭:BAABLAAFFH8FAAIGAAUIOxSHFACmAQAGAAUIOxSHFACmAQAAAA==.',['诸神']='诸神:BAAALAAFFAIIBAAAAA==.',['贫僧']='贫僧丶唐三葬:BAAALAAECgYICwAAAA==.贫僧丶玄奘:BAABLAAFFH8IAAICAAIIziLnNwDIAAACAAIIziLnNwDIAAAAAA==.贫僧葫芦娃:BAAALAADCgYIDAAAAA==.',['赖皮']='赖皮的小懒赖:BAAALAAECgYICgAAAA==.',['赢灬']='赢灬勾:BAAALAAECgQIBQAAAA==.',['赤红']='赤红之瞳:BAAALAAECggICAAAAA==.',['赵小']='赵小锤:BAABLAAFFH8IAAIaAAgIuQByQAAmAAAaAAgIuQByQAAmAAAAAA==.',['赵若']='赵若橙:BAAALAAECgEIAQAAAA==.',['起舞']='起舞灬弄清影:BAABLAAFFH8IAAIgAAIIkwW9GABTAAAgAAIIkwW9GABTAAAAAA==.',['超级']='超级爸比:BAAALAAECgYICAAAAA==.',['踢王']='踢王:BAAALAAECgYIBgAAAA==.',['躺客']='躺客:BAAALAAECgYICQAAAA==.',['躺赢']='躺赢狗:BAABLAAFFH8FAAIIAAII1hDSSwCVAAAIAAII1hDSSwCVAAAAAA==.',['轩辕']='轩辕猎:BAAALAAECgMIAwAAAA==.轩辕笑笑:BAAALAAECgYIBgAAAA==.',['辉月']='辉月灬:BAACLAAFFH8wAAMWAAYIBBxFAwAYAgAWAAYIBBxFAwAYAgAMAAMIYRY8MACrAAAsAAQKfxYAAxYABwiuGE0lAPABABYABwiuGE0lAPABAAwAAwgZIWoTAQoBAAAA.',['辣么']='辣么丶萌:BAABLAAECn8YAAIMAAYItxxjgwDmAQAMAAYItxxjgwDmAQAAAA==.',['近水']='近水含烟:BAAALAAECgYIBgAAAA==.',['迪迪']='迪迪鍅师:BAAALAAFFAMIAwAAAA==.',['迷你']='迷你猪灬香橙:BAACLAAFFH8lAAMCAAYI/hWIGgCNAQACAAYI/hWIGgCNAQAKAAUIaAnNKwDoAAAsAAQKfx4AAwIACAhgGPYZACUCAAIACAhgGPYZACUCAAoABwgdDLdvAG0BAAAA.',['追追']='追追魏魏丶:BAAALAAECggIDQAAAA==.',['逆光']='逆光:BAABLAAFFH8KAAIPAAII8Bu/OACMAAAPAAII8Bu/OACMAAAAAA==.逆光丶:BAABLAAFFH8HAAICAAIISxT6TQBtAAACAAIISxT6TQBtAAAAAA==.',['逗你']='逗你頑:BAACLAAFFH8fAAIKAAYIXxWTGQB3AQAKAAYIXxWTGQB3AQAsAAQKfyQAAgoACAh6HLMuAFQCAAoACAh6HLMuAFQCAAAA.',['遥知']='遥知不是雪:BAAALAAECgMIBAAAAA==.',['遥遥']='遥遥无期:BAABLAAFFH8UAAIBAAYI3BhGLACKAQABAAYI3BhGLACKAQAAAA==.',['邪灵']='邪灵:BAAALAADCgcIBwAAAA==.',['都说']='都说我小菜:BAABLAAFFH8LAAIOAAIIvBqxOQB9AAAOAAIIvBqxOQB9AAAAAA==.',['醉酒']='醉酒丶抚花颜:BAAALAAECgYICwAAAA==.',['野战']='野战:BAAALAAECgIIAgAAAA==.',['铁血']='铁血乂魔:BAAALAADCgYIBgAAAA==.',['银牛']='银牛:BAAALAAECgEIAQAAAA==.',['锤子']='锤子砸脚背:BAABLAAFFH8GAAIKAAYIjhqJEQC3AQAKAAYIjhqJEQC3AQAAAA==.',['长宇']='长宇丶妍:BAAALAAECgYICwAAAA==.',['阴月']='阴月琴:BAAALAAECgIIAgAAAA==.',['阿伯']='阿伯茶:BAAALAADCgEIAQAAAA==.',['阿尔']='阿尔丶萨斯:BAABLAAECn8ZAAIGAAYI1Bw6SABtAQAGAAYI1Bw6SABtAQAAAA==.阿尔托莉雅:BAAALAAECgYICgAAAA==.',['阿蒂']='阿蒂亚古灵:BAAALAAECgYIBwAAAA==.',['陈朵']='陈朵:BAAALAAFFAIIBAAAAA==.',['随风']='随风起舞:BAAALAAECgEIAQAAAA==.',['隐形']='隐形的提莫:BAAALAADCgQIBAAAAA==.',['雅木']='雅木天堂:BAABLAAECn8UAAIBAAgIZhe7ggDaAQABAAgIZhe7ggDaAQAAAA==.',['雷雷']='雷雷宝宝打肚:BAABLAAFFH83AAIeAAcI/yUyAQCqAgAeAAcI/yUyAQCqAgAAAA==.',['霁無']='霁無瑕:BAAALAAECgYIBgAAAA==.',['霊堺']='霊堺纆禱師:BAAALAADCgQIBAAAAA==.',['靈魂']='靈魂出竅:BAAALAADCgcIBwAAAA==.',['青山']='青山远黛:BAAALAAECgYIBgAAAA==.',['靓牛']='靓牛:BAAALAAECgEIAQAAAA==.',['頭硬']='頭硬:BAAALAADCgEIAQAAAA==.',['项链']='项链:BAAALAAECgYIAgAAAA==.',['颓废']='颓废的败家子:BAACLAAFFH8nAAMYAAYIehwYCgCrAQAYAAYIehwYCgCrAQAEAAIIpwM0GABlAAAsAAQKfyAAAgQACAgXGrcgAPwBAAQACAgXGrcgAPwBAAEsAAUUCAgKABMAnQQA.',['风丶']='风丶疯:BAABLAAFFH8IAAITAAIIFyDPJwC/AAATAAIIFyDPJwC/AAAAAA==.',['风之']='风之原:BAAALAADCgYICwAAAA==.',['风云']='风云小萨:BAAALAAECgIIAgAAAA==.',['风行']='风行者凯特:BAABLAAFFH8HAAIBAAMIMBz0ZgCmAAABAAMIMBz0ZgCmAAABLAAFFAUIFQACAM4gAA==.',['风骚']='风骚的大牛:BAAALAAECgEIAQAAAA==.',['飘逸']='飘逸:BAABLAAFFH8GAAIYAAYI6h0EDQB7AQAYAAYI6h0EDQB7AQAAAA==.',['飞一']='飞一机:BAAALAAECgYIBgAAAA==.',['飞丨']='飞丨爷:BAAALAAFFAIIAgAAAA==.',['飞尐']='飞尐爺:BAAALAAFFAIIBAAAAA==.',['飞巛']='飞巛飞:BAAALAAFFAIIBAAAAA==.',['饭后']='饭后来走走:BAAALAAECgYIBgAAAA==.',['香草']='香草甜澄:BAAALAAECggICAAAAA==.',['马伊']='马伊琍丶怒风:BAAALAAFFAIIAwAAAA==.',['鬼灭']='鬼灭萤火:BAABLAAFFH8GAAIaAAIIZARNPgAuAAAaAAIIZARNPgAuAAAAAA==.',['魂帝']='魂帝:BAAALAAECgYIDQAAAA==.',['魔界']='魔界筱麒:BAAALAAECgIIAgAAAA==.',['鲸鱼']='鲸鱼煎豆角:BAAALAAECggIDwABLAAFFAgIKwABAF4iAA==.',['黄皮']='黄皮丶咕:BAAALAAECgYIBgAAAA==.',['黑暗']='黑暗丶契约:BAAALAAECggIEAAAAA==.',['黑月']='黑月灬:BAAALAAECgYIDAAAAA==.',['黑灬']='黑灬乌龙茶:BAAALAADCgIIAgAAAA==.',['黛瑟']='黛瑟琳幽歌:BAAALAAECgYIBgAAAA==.',['齋藤']='齋藤明日香:BAABLAAFFH8qAAITAAcIFRlUDADfAQATAAcIFRlUDADfAQAAAA==.',['龍樱']='龍樱:BAAALAAFFAIIAgAAAA==.',['龙儱']='龙儱吟笨笨:BAAALAADCgIIAgAAAA==.',['龙啸']='龙啸九天:BAAALAAECgYIDQAAAA==.',['龙腾']='龙腾四海:BAAALAAECgQIBgAAAA==.',['龟蛋']='龟蛋:BAAALAAECgUIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end