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
 local lookup = {'DemonHunter-Havoc','Warlock-Destruction','Warlock-Demonology','Warrior-Fury','Shaman-Elemental','Shaman-Restoration','Priest-Holy','DeathKnight-Frost','DeathKnight-Unholy','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Vengeance','Druid-Restoration','Mage-Arcane','Priest-Shadow','Paladin-Protection','Monk-Mistweaver','Druid-Feral','Druid-Guardian','Druid-Balance','Unknown-Unknown','Warrior-Arms','Mage-Frost','Paladin-Holy','Warrior-Protection','DeathKnight-Blood',}; local provider = {region='CN',realm='奎尔丹纳斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Angels:BAAALAAECggICAAAAA==.',Ar='Artemis:BAAALAAECgYIBgAAAA==.',Ca='Can:BAABLAAECn8cAAIBAAgIhRQWWwAVAgABAAgIhRQWWwAVAgAAAA==.',Da='Danielle:BAABLAAFFH8eAAMCAAYIGhusHABRAQACAAYI2RmsHABRAQADAAEIix3tIwBWAAAAAA==.',Ha='Hagengu:BAAALAAECgYIEAAAAA==.',Hu='Huzi:BAAALAAECgYIBgAAAA==.',Ka='Karys:BAAALAADCgEIAQAAAA==.',Kr='Kratoss:BAAALAAECgMIAwAAAA==.',Li='Ligoat:BAAALAAECgQIBAABLAAFFAgIVAAEAC4lAA==.',Ma='Marlboio:BAABLAAFFH8GAAMFAAIIqASYNgB5AAAFAAIIqASYNgB5AAAGAAII5hN0WgBmAAAAAA==.',Pl='Playertluuyp:BAAALAAECgIIAgAAAA==.',Sh='Sheeponice:BAAALAADCgYIBgAAAA==.',Sy='Sylverster:BAAALAAECgYIBgAAAA==.',Um='Umr:BAAALAAECggICAAAAA==.',['七契']='七契:BAAALAAFFAIIAgAAAA==.',['三眼']='三眼乌鸦:BAAALAAFFAIIAgAAAA==.',['上峰']='上峰有令:BAAALAAFFAIIAgAAAA==.',['不学']='不学有术:BAAALAAECgYIBgAAAA==.',['不识']='不识字:BAAALAAECgYICQAAAA==.',['东瓯']='东瓯:BAAALAAFFAIIAgAAAA==.',['丶多']='丶多弗朗明哥:BAAALAAECgYIBgAAAA==.',['乄妖']='乄妖妖灵灬:BAAALAAECgcIBwAAAA==.',['二屁']='二屁爱撞墙:BAAALAADCgYIBgAAAA==.',['仅留']='仅留下哀伤:BAABLAAFFH8hAAIHAAYI+xTfFACuAQAHAAYI+xTfFACuAQAAAA==.',['低头']='低头等你吻:BAACLAAFFH8oAAIIAAYIRCPOEQDDAQAIAAYIRCPOEQDDAQAsAAQKfxgAAwgABggDJeM8AIoCAAgABggDJeM8AIoCAAkAAQj/EOhaAD4AAAAA.',['克洛']='克洛伊大人:BAAALAAFFAIIBAAAAA==.',['八方']='八方来财:BAABLAAECn8UAAMDAAYIzhXyNACZAQADAAYIYhPyNACZAQACAAYIzAzXpwArAQAAAA==.',['兽业']='兽业丶恩师:BAAALAADCgIIAgAAAA==.',['冬晚']='冬晚聚:BAAALAAFFAIIAgAAAA==.',['冬瓜']='冬瓜炖豆腐:BAAALAAECgEIAQAAAA==.',['凉眸']='凉眸丶:BAABLAAFFH8GAAIKAAYIoxetGACPAQAKAAYIoxetGACPAQAAAA==.',['凋零']='凋零所罗门:BAAALAAECgMIAwAAAA==.',['凯撒']='凯撒宝宝:BAAALAADCgMIAwAAAA==.',['凯迪']='凯迪不拉客:BAAALAAECggIDwAAAA==.',['刃乱']='刃乱之吻:BAABLAAFFH8XAAMLAAYI+yGlIwCjAQALAAYI+yGlIwCjAQAMAAII3R1CHQCTAAAAAA==.',['剑月']='剑月琴星:BAACLAAFFH8FAAIIAAII1xldUgCfAAAIAAII1xldUgCfAAAsAAQKfycAAggACAhiIDglANwCAAgACAhiIDglANwCAAAA.',['努尔']='努尔哈茨:BAABLAAFFH8NAAINAAMI2QIGEgA9AAANAAMI2QIGEgA9AAAAAA==.',['千夜']='千夜孤雪:BAAALAAECgIIAgAAAA==.',['升平']='升平:BAAALAAECgEIAQAAAA==.',['半糖']='半糖不加冰:BAAALAAECgQIBAAAAA==.',['半醉']='半醉丶:BAABLAAFFH8MAAIIAAYIUB51KACUAQAIAAYIUB51KACUAQAAAA==.',['半醒']='半醒丶:BAAALAADCgYIBgAAAA==.',['卡卡']='卡卡罗特:BAAALAAECgcIDgAAAA==.',['卡殿']='卡殿:BAAALAAECgMIAwAAAA==.',['卡莉']='卡莉歐斯托蘿:BAAALAAECgYICgAAAA==.',['双马']='双马尾的缰绳:BAAALAADCgMIBAAAAA==.',['古辰']='古辰海:BAAALAAFFAQIBAAAAA==.',['可乐']='可乐:BAAALAAECgYICgAAAA==.可乐味的芬达:BAAALAAECggIAwAAAA==.',['史蒂']='史蒂芬大叔:BAAALAAFFAEIAQAAAA==.',['右手']='右手年華:BAABLAAECn8WAAIKAAYIig7vhgDzAAAKAAYIig7vhgDzAAAAAA==.',['叶良']='叶良辰丶:BAABLAAFFH8OAAICAAUICw7mOgAdAQACAAUICw7mOgAdAQAAAA==.',['吃我']='吃我一箭:BAAALAADCggICAAAAA==.',['吉祥']='吉祥如意:BAABLAAECn8UAAIIAAYIlhrykgDbAQAIAAYIlhrykgDbAQAAAA==.',['吹飞']='吹飞你是我:BAABLAAECn8dAAIOAAgIShNwSADBAQAOAAgIShNwSADBAQAAAA==.',['周書']='周書:BAABLAAFFH8KAAILAAMI/gaAdwBuAAALAAMI/gaAdwBuAAAAAA==.',['哈弄']='哈弄弄:BAABLAAFFH8LAAIOAAMITR/2LgCvAAAOAAMITR/2LgCvAAAAAA==.',['唐牛']='唐牛才是食神:BAABLAAFFH8GAAIPAAIIOg4CXgB/AAAPAAIIOg4CXgB/AAAAAA==.',['啊菠']='啊菠萝:BAAALAADCgQIBAAAAA==.',['嗜血']='嗜血灬落泪:BAAALAADCgYIBgAAAA==.',['回忆']='回忆正在继续:BAAALAAECgYIBgAAAA==.回忆那一刻:BAABLAAFFH8WAAMHAAYIShSkIQA4AQAHAAUImxCkIQA4AQAQAAEIdQ0xJwBJAAAAAA==.',['困在']='困在那天:BAABLAAFFH8JAAIPAAMIIRA2LQDcAAAPAAMIIRA2LQDcAAAAAA==.',['圣光']='圣光止殇:BAAALAADCgYIBgAAAA==.',['圣童']='圣童降临:BAABLAAFFH8GAAIRAAIIIR2MEgCKAAARAAIIIR2MEgCKAAAAAA==.',['埋藏']='埋藏圣海:BAABLAAFFH8SAAIKAAUIoRYOJwBAAQAKAAUIoRYOJwBAAQAAAA==.',['墓诗']='墓诗丶:BAABLAAFFH8GAAIHAAYIahcdFgCiAQAHAAYIahcdFgCiAQAAAA==.',['多一']='多一多:BAAALAADCgUIBQAAAA==.',['夜王']='夜王子:BAAALAADCgIIAgAAAA==.',['大王']='大王饶命:BAABLAAFFH8iAAIGAAUIohpbGwCAAQAGAAUIohpbGwCAAQAAAA==.',['大瓶']='大瓶可乐:BAAALAADCgIIAgAAAA==.',['大鼻']='大鼻子丶若风:BAAALAAECgYIBgAAAA==.',['天堂']='天堂小鱼:BAAALAAECgQIBAAAAA==.天堂的小龙:BAAALAADCgYIAQAAAA==.',['天灾']='天灾毒瘤:BAABLAAFFH8KAAIIAAIITg9/egBIAAAIAAIITg9/egBIAAAAAA==.',['天雷']='天雷棍棍:BAACLAAFFH8kAAMGAAYIHRTWHgBlAQAGAAYIHRTWHgBlAQAFAAMImAasOgBmAAAsAAQKfxsAAwYABghIFiCBAH4BAAYABghIFiCBAH4BAAUAAggeD9t4ADcAAAAA.',['失去']='失去的美好:BAABLAAFFH8GAAIOAAIICgPpSABSAAAOAAIICgPpSABSAAAAAA==.',['头上']='头上没鸡脚:BAAALAAECgIIAgAAAA==.',['奈何']='奈何丶百花杀:BAAALAADCgIIAgAAAA==.',['奈奈']='奈奈个熊:BAAALAAECgMIBAAAAA==.',['奔跑']='奔跑的松狮:BAAALAAFFAIIBAAAAA==.',['女古']='女古女古:BAAALAAFFAIIBAAAAA==.',['女圭']='女圭女圭:BAAALAAECgQIBAAAAA==.',['女审']='女审女审:BAAALAAFFAIIAgAAAA==.',['女良']='女良女良:BAAALAAECgUIBgAAAA==.',['奶糖']='奶糖味薄荷:BAAALAADCgIIAgAAAA==.',['娘娘']='娘娘千岁:BAABLAAFFH8bAAISAAUIERy8CACWAQASAAUIERy8CACWAQABLAAFFAUIIgAGAKIaAA==.',['婀弗']='婀弗詻狄忒:BAACLAAFFH8IAAIKAAII9Bk1VABNAAAKAAII9Bk1VABNAAAsAAQKfxYAAgoABghRINYyAMcBAAoABghRINYyAMcBAAAA.',['婲開']='婲開怑嗄:BAACLAAFFH8KAAITAAIITBKqDgCSAAATAAIITBKqDgCSAAAsAAQKfx8ABBMACAijGW0KAJsBABQACAjzF98SAK8BABMABgh9HG0KAJsBABUABQhPFHs3AOAAAAAA.',['孤独']='孤独丶旅行者:BAAALAAECgEIAQAAAA==.',['审判']='审判官:BAAALAADCgQIBAAAAA==.',['寥寥']='寥寥无几:BAAALAAECgMIAwAAAA==.',['小何']='小何尖尖:BAAALAADCgEIAQAAAA==.',['小吼']='小吼意难平:BAAALAAFFAYIBAABLAAFFAgIAQAWAAAAAA==.',['小时']='小时候可逗了:BAAALAAECggICAAAAA==.',['小熊']='小熊有钱花:BAAALAADCgUIBQAAAA==.',['小猪']='小猪骑大象:BAAALAADCggIDQAAAA==.',['小白']='小白龍:BAAALAAFFAYIAgAAAA==.',['小虎']='小虎:BAABLAAFFH8GAAILAAYI2gAQxQALAAALAAYI2gAQxQALAAAAAA==.',['少司']='少司命:BAAALAAECgQIBQAAAA==.',['屠戮']='屠戮无形:BAAALAAECgQIBwAAAA==.',['左手']='左手青春:BAAALAAECgUIBQAAAA==.',['巫山']='巫山祝:BAAALAADCgcIBwAAAA==.',['带小']='带小孩的流氓:BAAALAAECgYICQAAAA==.',['干戈']='干戈寥落:BAABLAAECn8XAAIXAAgIHRZ/CgA1AgAXAAgIHRZ/CgA1AgAAAA==.',['幽灵']='幽灵骑士:BAAALAAECgEIAQAAAA==.',['府恗']='府恗:BAAALAAFFAIIBAAAAA==.',['彩虹']='彩虹笔刷:BAAALAAECgYIEgAAAA==.',['影流']='影流之锋:BAAALAAECgYIBgAAAA==.',['忠艾']='忠艾一生:BAAALAAECgYIBgAAAA==.',['悠悠']='悠悠起很晚:BAACLAAFFH8JAAIPAAYIfRjuCQAdAgAPAAYIfRjuCQAdAgAsAAQKfx8AAw8ACAhNI6QSABADAA8ACAhNI6QSABADABgAAQgPG5CQADoAAAAA.',['愤怒']='愤怒之锤:BAABLAAFFH8FAAIKAAMI5xFlPgCZAAAKAAMI5xFlPgCZAAAAAA==.',['慕容']='慕容萨满:BAAALAAECgUIBQAAAA==.慕容醉猫:BAAALAAECgIIAgAAAA==.',['慕岚']='慕岚焚初:BAAALAAECgEIAQAAAA==.',['戎马']='戎马一身:BAABLAAFFH8KAAIRAAIINQW0HwBcAAARAAIINQW0HwBcAAAAAA==.',['戏水']='戏水:BAAALAAECgQIBQAAAA==.',['我很']='我很抱歉:BAAALAAECgYICgAAAA==.',['我是']='我是个萌新:BAAALAADCgcIBwAAAA==.',['抓豆']='抓豆豆:BAAALAAECgQIBAAAAA==.',['捶飞']='捶飞你是我:BAAALAAECgYICQAAAA==.',['撒满']='撒满基斯:BAAALAAFFAIIAwAAAA==.',['撩怪']='撩怪特工:BAAALAAECgYIBgAAAA==.',['新城']='新城同学:BAABLAAFFH8PAAILAAUINR8cNwC1AAALAAUINR8cNwC1AAAAAA==.',['无敌']='无敌任炳聪:BAABLAAFFH8WAAIIAAYIEA4aNABrAQAIAAYIEA4aNABrAQAAAA==.',['昊昊']='昊昊:BAAALAAECgMIAwAAAA==.',['晕晕']='晕晕:BAAALAADCgMIAwAAAA==.',['暗夜']='暗夜水蜜桃:BAAALAAFFAIIAgAAAA==.',['月语']='月语星聆:BAAALAAECgIIAgAAAA==.',['有钱']='有钱任性:BAABLAAFFH8PAAQVAAUIjQvHIQCnAAAVAAQIvwvHIQCnAAAOAAEIYQfgXAAzAAAUAAEITg05EwAAAAAAAA==.',['木下']='木下丨秀吉:BAABLAAECn8hAAIIAAYIsh2tRQBxAQAIAAYIsh2tRQBxAQAAAA==.',['木石']='木石:BAABLAAFFH8NAAMLAAMIOQ2DdAB3AAALAAMIOQ2DdAB3AAAMAAIIKgS4LwBiAAAAAA==.',['术法']='术法无敌:BAAALAAECgQIBAAAAA==.',['朱露']='朱露露丶:BAAALAAECgIIAgAAAA==.',['杀生']='杀生灭众生:BAABLAAECn8kAAIKAAgIbR/xMgCnAgAKAAgIbR/xMgCnAgAAAA==.',['李寻']='李寻欢丨:BAAALAAECgYIBgAAAA==.',['李阳']='李阳春:BAAALAAECgcIEwAAAA==.',['来一']='来一包七匹狼:BAAALAAECgYIBwABLAAFFAYIDAAKAFERAA==.来一包云烟:BAAALAAECgYIBgAAAA==.',['来吖']='来吖快活啊:BAAALAAFFAIIBAAAAA==.',['来財']='来財来財来財:BAAALAADCgMIAwAAAA==.',['杯莫']='杯莫停:BAAALAAFFAIIAgAAAA==.',['柒宝']='柒宝霸霸:BAABLAAFFH8RAAIOAAYIPRTIEgCmAQAOAAYIPRTIEgCmAQAAAA==.',['歌舞']='歌舞:BAAALAAECgIIAgAAAA==.',['武憎']='武憎:BAAALAAECggIAwAAAA==.',['死我']='死我也不救:BAAALAAECgYIDQAAAA==.',['法炎']='法炎心:BAAALAAECgYICwAAAA==.',['混子']='混子:BAAALAAECgYIDAAAAA==.',['清风']='清风烈酒:BAAALAAECgQIBAAAAA==.',['潜德']='潜德秘行:BAAALAAECgUIBQAAAA==.',['潶色']='潶色灬小鬼:BAAALAAECgYIBgAAAA==.',['灬独']='灬独家记忆灬:BAAALAAECgEIAQAAAA==.',['灰色']='灰色老头:BAAALAAECgYIDQAAAA==.',['灼眼']='灼眼的夏亚:BAABLAAFFH8YAAIBAAUIoyEwHwCFAQABAAUIoyEwHwCFAQAAAA==.',['熙喵']='熙喵喵的天空:BAAALAAECggICAAAAA==.',['熙阳']='熙阳皓月:BAAALAAFFAMIAwAAAA==.',['燃烧']='燃烧吧腋毛:BAAALAAECgYIAQAAAA==.',['牢大']='牢大:BAAALAAFFAIIAgAAAA==.',['牧童']='牧童姩纪:BAAALAAFFAQIBAAAAA==.',['狂与']='狂与峯:BAAALAAECgYICgAAAA==.',['狂舞']='狂舞盛怒:BAAALAAECgIIAgAAAA==.',['狼王']='狼王前来拜访:BAAALAADCggICAAAAA==.',['猫猫']='猫猫:BAACLAAFFH8UAAIGAAYIKhTXCQCgAQAGAAYIKhTXCQCgAQAsAAQKfx4AAgYACAj2IIcVAMoCAAYACAj2IIcVAMoCAAAA.',['环保']='环保春哥:BAAALAAECgUIBgAAAA==.',['瓜皮']='瓜皮大将:BAAALAAFFAQIAwAAAA==.',['电闪']='电闪雷鸣:BAAALAAFFAIIAgAAAA==.',['白豌']='白豌豆:BAACLAAFFH8MAAIZAAIIXiaHEADcAAAZAAIIXiaHEADcAAAsAAQKfyEAAxkACAiFH4sLAMQCABkACAiFH4sLAMQCAAoAAwgBHYNEAacAAAAA.',['盐汁']='盐汁油梨:BAAALAAECggIBgAAAA==.',['真有']='真有你的:BAABLAAECn8WAAIKAAgIRBX1egAKAQAKAAgIRBX1egAKAQAAAA==.',['福尔']='福尔康丶益达:BAAALAAECgYIBgAAAA==.',['科技']='科技与狠活:BAAALAAECgYIEQAAAA==.',['穷疯']='穷疯的小羊:BAAALAAECgYIBgAAAA==.',['等会']='等会再狗叫:BAAALAAECgQIBAAAAA==.',['箩玉']='箩玉凤:BAAALAAECggICwAAAA==.',['紫色']='紫色的圈圈:BAABLAAFFH8IAAIDAAIIXhIvFQCaAAADAAIIXhIvFQCaAAAAAA==.',['纱由']='纱由理:BAAALAAFFAIIAgAAAA==.',['维生']='维生素:BAAALAADCgIIAgAAAA==.',['耦牟']='耦牟嘿漏哒哗:BAAALAAECgUIBQAAAA==.',['肉掌']='肉掌软软哒:BAAALAADCgQIBAAAAA==.',['胸毛']='胸毛慕斯:BAABLAAFFH8LAAIPAAMILwXDSwBkAAAPAAMILwXDSwBkAAAAAA==.',['脆皮']='脆皮杀手:BAAALAAFFAIIAgAAAA==.',['自愚']='自愚自乐:BAABLAAFFH8GAAIHAAYI6hoOFQCrAQAHAAYI6hoOFQCrAQAAAA==.',['舞夜']='舞夜悠靈:BAABLAAFFH8MAAMKAAQIqQpQOAC+AAAKAAQIBwpQOAC+AAARAAIIeQWVHwBdAAAAAA==.舞夜悠靈丶:BAABLAAFFH8OAAIaAAQIwQoOHAClAAAaAAQIwQoOHAClAAAAAA==.',['航线']='航线加勒比:BAAALAAFFAIIAgAAAA==.航线织女星座:BAAALAAFFAIIBAAAAA==.',['艾伦']='艾伦:BAAALAAFFAIIAgAAAA==.',['艾米']='艾米哈伯:BAAALAAECgYICAAAAA==.',['芒果']='芒果乄千层:BAAALAADCggIAgAAAA==.',['花开']='花开富贵:BAAALAAECgYIBgAAAA==.',['花言']='花言花:BAAALAAECgQICAAAAA==.',['苍穹']='苍穹丶无垠:BAAALAAFFAIIAgAAAA==.',['萌萌']='萌萌小乳牛:BAAALAADCggICAAAAA==.',['落魄']='落魄山小米粒:BAAALAADCgYIBgAAAA==.',['董香']='董香丶:BAAALAAECgEIAQAAAA==.',['蔡歪']='蔡歪歪无敌:BAACLAAFFH8ZAAIIAAYIZCIZEwD3AQAIAAYIZCIZEwD3AQAsAAQKfyAAAggACAi3IMwdAAYCAAgACAi3IMwdAAYCAAAA.蔡歪歪瞎砍:BAABLAAFFH8RAAIBAAYI9ha2GwCXAQABAAYI9ha2GwCXAQAAAA==.',['藤椒']='藤椒鱼片:BAAALAADCgIIAgAAAA==.',['西野']='西野七濑:BAAALAAECgIIAgAAAA==.',['觉非']='觉非:BAABLAAFFH8GAAIPAAIICBNpRwCYAAAPAAIICBNpRwCYAAAAAA==.',['诚实']='诚实的小菠萝:BAAALAAFFAIIBAAAAA==.',['豆豆']='豆豆那麼可愛:BAAALAADCgYIBgAAAA==.',['赛琳']='赛琳:BAAALAAFFAIIAgAAAA==.',['赛过']='赛过个加强连:BAAALAADCgIIAgAAAA==.',['赤炎']='赤炎心火:BAAALAAECgYICAAAAA==.',['蹦跶']='蹦跶的小羊:BAAALAAECgUICAAAAA==.',['软馒']='软馒头:BAABLAAFFH8MAAIZAAYIwwsaEwBZAQAZAAYIwwsaEwBZAQAAAA==.',['辉仔']='辉仔:BAAALAAECgQIBgAAAA==.',['辛多']='辛多雷女技司:BAABLAAFFH8GAAIQAAIIygoDIwCGAAAQAAIIygoDIwCGAAAAAA==.辛多雷血骑士:BAABLAAFFH8RAAIKAAUI5BkmJABQAQAKAAUI5BkmJABQAQAAAA==.',['还得']='还得是你:BAAALAAECgQIBAAAAA==.',['迷虹']='迷虹:BAAALAAFFAIIBAAAAA==.',['迷鹿']='迷鹿:BAAALAAECgYIDAAAAA==.',['追风']='追风赶月:BAAALAAFFAQIBAABLAAFFAgIAwAWAAAAAA==.',['逆丶']='逆丶凡尘:BAAALAAFFAIIAgAAAA==.',['遠古']='遠古巫灵:BAAALAAECggIDgAAAA==.',['邪影']='邪影之月:BAAALAAECgEIAQAAAA==.',['邪恶']='邪恶的小土人:BAAALAAECgMIAwAAAA==.',['邪能']='邪能空虚公主:BAACLAAFFH8OAAMCAAMIFhbKSwCLAAACAAMIFhbKSwCLAAADAAEIxA1OLABKAAAsAAQKfxwAAgIABwjLHr0aAAsCAAIABwjLHr0aAAsCAAAA.',['部落']='部落制糕王:BAAALAAECgYIDAAAAA==.',['郭源']='郭源潮:BAAALAAFFAIIBAAAAA==.',['野牛']='野牛一头:BAAALAAFFAIIAgAAAA==.',['银川']='银川好公民:BAAALAAECgMIAwAAAA==.',['锝镥']='锝镥铱:BAABLAAFFH8VAAIUAAUIpwg6BgCpAAAUAAUIpwg6BgCpAAAAAA==.',['镂尘']='镂尘欥影:BAAALAAECgYICQAAAA==.',['阿纳']='阿纳拉克:BAAALAAECggICwAAAA==.',['陆军']='陆军上将:BAAALAAECgEIAQAAAA==.',['陆玖']='陆玖之王:BAAALAAECgYICAAAAA==.',['陈書']='陈書:BAABLAAFFH8aAAIbAAUIvQXHEQDEAAAbAAUIvQXHEQDEAAAAAA==.',['陌小']='陌小牧:BAAALAAECgUIBQAAAA==.',['陌路']='陌路以西:BAABLAAFFH8VAAIDAAUIsR7vAgBgAQADAAUIsR7vAgBgAQAAAA==.',['限量']='限量可乐:BAAALAAECgUIAgAAAA==.',['雨过']='雨过天晴:BAAALAADCgQIBAAAAA==.',['雪静']='雪静灵妹子:BAAALAAECgEIAQAAAA==.',['霓虹']='霓虹:BAAALAAFFAQIBAAAAA==.',['非洲']='非洲帝凯:BAACLAAFFH8JAAIIAAMIAxNbYACNAAAIAAMIAxNbYACNAAAsAAQKfxYAAwgACAilFqBZAEMCAAgACAilFqBZAEMCAAkAAQizCVdcADkAAAAA.',['顺我']='顺我昌逆我亡:BAABLAAFFH8WAAMFAAUI5QipKAD/AAAFAAUI5QipKAD/AAAGAAMI5A46RgCTAAAAAA==.',['风月']='风月无尘:BAAALAAECgYIDAAAAA==.',['飘逸']='飘逸尘尘:BAAALAAFFAIIAgAAAA==.',['驱雷']='驱雷策电:BAABLAAFFH8GAAIFAAUInAUuMQChAAAFAAUInAUuMQChAAAAAA==.',['骑士']='骑士的祷告:BAAALAAECgUIBwAAAA==.',['骑天']='骑天大圣:BAABLAAFFH8IAAIKAAII3ROPbQA/AAAKAAII3ROPbQA/AAAAAA==.',['黎書']='黎書:BAABLAAFFH8IAAIIAAII7AKjnwA1AAAIAAII7AKjnwA1AAAAAA==.',['黑是']='黑是黑健康色:BAABLAAFFH8LAAIKAAMIbRv0PwCUAAAKAAMIbRv0PwCUAAAAAA==.',['黑锋']='黑锋降临:BAAALAAFFAIIAgAAAA==.',['龙形']='龙形小德:BAAALAAECgYIEgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end