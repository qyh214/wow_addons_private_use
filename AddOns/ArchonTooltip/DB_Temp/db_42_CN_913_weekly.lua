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
 local lookup = {'Druid-Balance','Priest-Shadow','Warlock-Demonology','Warrior-Fury','Paladin-Retribution','Rogue-Assassination','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Priest-Discipline','Priest-Holy','Monk-Windwalker','DemonHunter-Vengeance','Paladin-Protection','Druid-Guardian','Warlock-Destruction','Mage-Fire','Mage-Arcane','Paladin-Holy','Rogue-Subtlety','Shaman-Elemental','DeathKnight-Unholy','Warlock-Affliction','Shaman-Restoration','Monk-Mistweaver','Monk-Brewmaster',}; local provider = {region='CN',realm='奥杜尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Achilles:BAAAKgAFFAgIAgAAAA==.',Ch='Cheng:BAAAKgAECgUICAAAAA==.',He='Henrikh:BAABKgAFFH8EAAIBAAQIKh6LLQDdAAABAAQIKh6LLQDdAAAAAA==.',Ho='Horusluperca:BAAAKgAECgYICgAAAA==.',Hu='Huang:BAAAKgAECgEIAQAAAA==.',Le='Leoji:BAAAKgAECgEIAQAAAA==.',Lu='Lucas:BAAAKgAFFAgIBAAAAA==.',Mo='Mole:BAAAKgAECggICgAAAA==.',Na='Nanami:BAAAKgAECgcIDAAAAA==.',Ni='Niot:BAAAKgAECgUIBQAAAA==.Niott:BAABKgAFFH8MAAICAAMIIhMzGAC6AAACAAMIIhMzGAC6AAAAAA==.',Pe='Peche:BAAAKgAECggIEQAAAA==.',Po='Posche:BAAAKgAECggIEAAAAA==.',Re='Redarrow:BAAAKgAFFAgIBAAAAA==.',Sa='Sakame:BAAAKgAECgEIAQAAAA==.',Su='Suyyzl:BAAAKgAFFAIIAgABKgAFFAgIFAADAOMgAA==.',Wi='Win:BAAAKgAECgQIAwAAAA==.',Yi='Yishouge:BAAAKgADCggICAAAAA==.',['一飞']='一飞影一:BAAAKgADCgUIBQAAAA==.',['三页']='三页:BAABKgAFFH8GAAIEAAYIZA5qDwBeAQAEAAYIZA5qDwBeAQAAAA==.',['个哦']='个哦武器:BAAAKgAECgMIAwAAAA==.',['丶阿']='丶阿喵:BAAAKgAFFAQIBAAAAA==.',['买菜']='买菜女路人:BAAAKgAECggICAAAAA==.',['云朵']='云朵绿绿:BAAAKgAFFAQIBAAAAA==.',['修马']='修马呀修马:BAABKgAFFH8HAAIFAAYI3As6YgCrAAAFAAYI3As6YgCrAAAAAA==.',['农十']='农十一月二九:BAAAKgAECgQIBwAAAA==.',['冬言']='冬言丶:BAAAKgAFFAQIBAAAAA==.',['冰死']='冰死你:BAAAKgADCgIIAgAAAA==.',['凄凉']='凄凉丶不思量:BAAAKgAECgEIAQAAAA==.',['别看']='别看我矮:BAAAKgAECgcICQAAAA==.',['十年']='十年饮冰:BAABKgAFFH8GAAIGAAYIXg2mEgAoAQAGAAYIXg2mEgAoAQAAAA==.',['南宫']='南宫灬逸轩:BAAAKgAECgIIAgAAAA==.',['卡夫']='卡夫卡:BAAAKgADCggICAAAAA==.',['卡欧']='卡欧斯丶灵语:BAAAKgAECggIDwAAAA==.',['吧唧']='吧唧一口雪雪:BAAAKgAECggIBAABKgAFFAgIHAAHACQZAA==.',['含家']='含家富贵:BAABKgAFFH8KAAMIAAYIlyKQDQCYAQAIAAYIlyKQDQCYAQAJAAQIchXhCwDtAAAAAA==.',['嗜血']='嗜血狼:BAAAKgADCgIIAgAAAA==.',['土豆']='土豆片炒肉:BAAAKgADCgQIBAAAAA==.土豆粉:BAABKgAFFH8NAAIFAAYIDBSsJgBOAQAFAAYIDBSsJgBOAQAAAA==.',['圣佑']='圣佑骁骑:BAAAKgAECgYIBgAAAA==.',['在也']='在也回不去丶:BAAAKgAECgEIAQAAAA==.',['士气']='士气:BAAAKgAECgMIAwAAAA==.',['夏洛']='夏洛特丶玲玲:BAAAKgAECgMIAwAAAA==.',['多吃']='多吃魔芋:BAAAKgAECgYICQAAAA==.',['多多']='多多耍大锤:BAAAKgADCggICwAAAA==.',['夜夜']='夜夜有小酒:BAAAKgADCgMIAwAAAA==.',['夜的']='夜的安魂曲:BAACKgAFFH8YAAIKAAYIfAJ4IAChAAAKAAYIfAJ4IAChAAAqAAQKfyIAAgoACAhQBlA7ANUAAAoACAhQBlA7ANUAAAAA.',['大保']='大保健享受者:BAAAKgADCggICAAAAA==.',['大发']='大发明家:BAABKgAFFH8MAAQLAAYI1Bx5EQASAQALAAUIcBV5EQASAQAMAAUI0BTnGgDkAAACAAEImx+XKABPAAAAAA==.',['大叔']='大叔玩变身:BAAAKgAECgIIAgAAAA==.',['大杰']='大杰锅:BAAAKgAFFAEIAQAAAA==.',['大鱼']='大鱼:BAAAKgAFFAMIAwAAAA==.',['始皇']='始皇爱酱:BAAAKgAECgcIBwAAAA==.',['学妹']='学妹别这样:BAAAKgAECgYIEQAAAA==.',['小居']='小居居:BAAAKgAFFAQIBAAAAA==.',['小杰']='小杰锅:BAAAKgADCggICAAAAA==.',['小熊']='小熊软糖:BAAAKgAFFAQIAwAAAA==.',['小野']='小野麻里亞:BAAAKgAFFAYIAQAAAA==.',['少月']='少月:BAABKgAFFH8MAAINAAYICxUAAgC5AQANAAYICxUAAgC5AQAAAA==.',['屋及']='屋及乌:BAAAKgAECgQIBQAAAA==.',['归来']='归来:BAAAKgAECgcICgAAAA==.',['怒讽']='怒讽:BAABKgAFFH8GAAMOAAQIDQSoEAB8AAAOAAQIrAOoEAB8AAAHAAIIgAMlMABoAAAAAA==.',['慕夏']='慕夏:BAAAKgAECgYIBgAAAA==.',['我凶']='我凶的批爆:BAAAKgAFFAEIAQAAAA==.',['我去']='我去哞一根:BAABKgAFFH8IAAIKAAQIpBgzDwAtAQAKAAQIpBgzDwAtAQAAAA==.',['我是']='我是奶萨:BAABKgAECn8XAAMCAAcITBvpHgDeAQACAAcITBvpHgDeAQAMAAYIGBRuSwAKAQAAAA==.',['我来']='我来奶:BAAAKgADCggICAAAAA==.',['戴了']='戴了不算给:BAAAKgAFFAQIBAAAAA==.',['拽拽']='拽拽的小强:BAABKgAFFH8IAAIKAAgI0g5mCACUAQAKAAgI0g5mCACUAQAAAA==.',['搞东']='搞东搞西:BAAAKgAECgMIAwAAAA==.',['撼地']='撼地神牛:BAAAKgADCggICAAAAA==.',['放空']='放空灬去旅行:BAAAKgAECggIEgAAAA==.',['新手']='新手卫星:BAAAKgAFFAEIAQAAAA==.新手司机:BAAAKgAECggIEgAAAA==.新手摩托:BAABKgAFFH8IAAIBAAgIIQw2DADSAQABAAgIIQw2DADSAQAAAA==.新手火箭:BAABKgAFFH8IAAIPAAgIlBRSBADYAQAPAAgIlBRSBADYAQAAAA==.新手飞机:BAAAKgAECgUIBQAAAA==.',['晨风']='晨风猎手:BAABKgAFFH8QAAIHAAgIuBQlBwAnAgAHAAgIuBQlBwAnAgAAAA==.',['暗影']='暗影镰接:BAAAKgAECgQIBAAAAA==.',['暴怒']='暴怒神将:BAAAKgAECgEIAQAAAA==.',['月下']='月下:BAAAKgAECgUIBwAAAA==.',['月玲']='月玲珑:BAAAKgAFFAQIAgAAAA==.',['望涯']='望涯:BAABKgAFFH8IAAIFAAgIdAR9FQBGAQAFAAgIdAR9FQBGAQAAAA==.',['机械']='机械柱柱:BAAAKgAECggIDgAAAA==.',['松花']='松花酿酒:BAAAKgAECgYIBgAAAA==.',['枫暴']='枫暴之灵:BAABKgAFFH8IAAIQAAQIBAIuDQBIAAAQAAQIBAIuDQBIAAAAAA==.',['格挡']='格挡家:BAAAKgAECgIIAgAAAA==.',['桐桐']='桐桐真痛苦:BAABKgAECn8YAAIRAAgILx0ZEgAYAgARAAgILx0ZEgAYAgAAAA==.',['桔中']='桔中秘:BAAAKgAECgYIBgAAAA==.',['橙子']='橙子是酸德:BAAAKgADCggICAAAAA==.',['橙黏']='橙黏人:BAABKgAFFH8IAAIRAAQILBq9IwDrAAARAAQILBq9IwDrAAAAAA==.',['死亡']='死亡如影随行:BAAAKgAFFAIIAwAAAA==.',['活死']='活死人牧:BAAAKgAECggIEgAAAA==.',['流光']='流光丶岁月:BAAAKgAECgUIBQAAAA==.',['火德']='火德星姬:BAABKgAFFH8IAAMSAAQITBC5HgC9AAASAAQI3w25HgC9AAATAAQIxQ4AAAAAAAAAAA==.',['灵衣']='灵衣兮被被:BAAAKgADCggIEAAAAA==.',['熊猫']='熊猫张爷爷:BAAAKgAECggIDQAAAA==.',['爱好']='爱好排队真君:BAABKgAFFH8HAAIUAAQI0QTcCgCyAAAUAAQI0QTcCgCyAAABKgAFFAgIEgAPAOocAA==.',['牛排']='牛排专卖:BAAAKgAECgcIEAAAAA==.',['狗尔']='狗尔丹:BAAAKgAECgIIAgAAAA==.',['狩魔']='狩魔骑士:BAAAKgAECgEIAQAAAA==.',['猎到']='猎到你的心:BAAAKgAECggICAAAAA==.',['猩红']='猩红蒸虾仁:BAAAKgAECgIIAwAAAA==.',['玛雅']='玛雅丶妲婕妮:BAAAKgAECgIIAgAAAA==.',['琉璃']='琉璃安安:BAAAKgADCgMIAwAAAA==.',['瑶池']='瑶池有溪:BAAAKgAECggIEAAAAA==.',['生不']='生不带来:BAAAKgADCggIDgAAAA==.',['碍人']='碍人:BAABKgAFFH8GAAIFAAYI3RxEHACDAQAFAAYI3RxEHACDAQAAAA==.',['糯米']='糯米兮兮丶:BAABKgAFFH8QAAMLAAgImxidAgBNAgALAAgImxidAgBNAgAMAAQIrxddEgCyAAAAAA==.',['纳瑞']='纳瑞安丶银风:BAAAKgAECggICwAAAA==.',['织影']='织影小龙:BAABKgAFFH8FAAMMAAII6gkNHQBxAAAMAAII6gkNHQBxAAACAAII1QQ6IABjAAAAAA==.',['给你']='给你跳支舞:BAAAKgAECgYIBgAAAA==.',['绝对']='绝对幸运星:BAABKgAFFH8YAAMGAAgIYRi2AwBwAgAGAAgIYRi2AwBwAgAVAAQImw05CQDeAAAAAA==.',['罗的']='罗的贝宝:BAAAKgADCggICAAAAA==.',['耍娃']='耍娃儿噜哒哒:BAABKgAECn8XAAIWAAgIrxh6LQCVAQAWAAgIrxh6LQCVAQAAAA==.',['艾丽']='艾丽妮:BAAAKgAECgYIDAAAAA==.',['艾瑞']='艾瑞达索克:BAAAKgAFFAQIBAAAAA==.',['花名']='花名册灬权:BAAAKgAECggICAAAAA==.',['花开']='花开丶季节:BAAAKgAECggIEQAAAA==.',['茶茶']='茶茶丶丶:BAABKgAECn8aAAMXAAgI9SM6DwCoAgAXAAgIcyM6DwCoAgAKAAEI0CVTQwBoAAAAAA==.',['荧荧']='荧荧:BAAAKgAECggICAAAAA==.',['荼色']='荼色荼香:BAAAKgAECgMIBAAAAA==.',['萝卜']='萝卜:BAAAKgAECgMIAwAAAA==.',['萨拉']='萨拉塔丝:BAABKgAFFH8LAAISAAgIVxFpBgD/AQASAAgIVxFpBgD/AQAAAA==.',['蛋蛋']='蛋蛋的忧伤:BAAAKgAECggICAAAAA==.',['血性']='血性狂爆:BAAAKgADCgQIBgAAAA==.',['裤儿']='裤儿提拉丝:BAAAKgADCggICAAAAA==.',['裳安']='裳安珀:BAAAKgAECgEIAQAAAA==.',['西吉']='西吉斯蒙德:BAAAKgAECgYIBgAAAA==.',['言叶']='言叶芷汀:BAABKgAECn8WAAQRAAcI2RjQQQBiAQARAAYI5hnQQQBiAQADAAUIaxCkQADeAAAYAAII7womPABVAAAAAA==.',['诗悠']='诗悠洛:BAAAKgAECgQIBQAAAA==.',['诚实']='诚实者:BAAAKgAECgEIAQAAAA==.',['谷尔']='谷尔丹:BAAAKgAECgQIBAAAAA==.',['赤色']='赤色彗星夏亚:BAAAKgAECggIBQAAAA==.',['达拉']='达拉姆大主教:BAAAKgAECgQIBgAAAA==.',['迪亚']='迪亚:BAAAKgAECgcIBwAAAA==.',['逐風']='逐風者:BAAAKgAECgcIBwAAAA==.',['邪能']='邪能路由器:BAAAKgAECgUIDgAAAA==.',['醉蟹']='醉蟹醉蟹:BAAAKgAFFAIIAgAAAA==.',['铁戈']='铁戈:BAAAKgADCggIDwAAAA==.',['镇魂']='镇魂歌:BAAAKgAECgEIAQAAAA==.',['闪电']='闪电侠:BAACKgAFFH8OAAIZAAQIgB3WDAD1AAAZAAQIgB3WDAD1AAAqAAQKfyMAAhkACAjJIacNAIoCABkACAjJIacNAIoCAAAA.',['雅若']='雅若诗画:BAAAKgADCggICAAAAA==.',['雷扎']='雷扎德:BAAAKgAECggICAAAAA==.',['青丝']='青丝落成秋霜:BAAAKgAECgIIAgAAAA==.',['风之']='风之优雅:BAABKgAFFH8hAAIPAAgIWwVTCAAwAQAPAAgIWwVTCAAwAQAAAA==.风之圣灵:BAAAKgAFFAEIAQAAAA==.',['风骚']='风骚的妹抖:BAABKgAFFH8IAAIFAAQIexVNTQDUAAAFAAQIexVNTQDUAAAAAA==.',['骑士']='骑士我最怂:BAAAKgAFFAYIAQAAAA==.',['骑驴']='骑驴大圣:BAAAKgADCgEIAQAAAA==.',['鬼烧']='鬼烧:BAAAKgAFFAMIAwAAAA==.鬼烧丶暴风:BAACKgAFFH8KAAMaAAUIvSOECQCUAQAaAAUIvSOECQCUAQANAAMIvRGWEwDHAAAqAAQKfxwABA0ACAjgHQ4SACYCAA0ABwi9Hw4SACYCABsACAjADZYQACABABoAAQiOCFeQADAAAAAA.',['黑胡']='黑胡椒肋排:BAAAKgAECgQIBAAAAA==.',['龍傲']='龍傲天:BAAAKgADCgQIBAAAAA==.',['龙佛']='龙佛:BAAAKgADCgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end