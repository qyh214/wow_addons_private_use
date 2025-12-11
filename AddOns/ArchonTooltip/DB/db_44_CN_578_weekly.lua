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
 local lookup = {'DeathKnight-Frost','Warrior-Fury','Rogue-Outlaw','Rogue-Assassination','Shaman-Restoration','Druid-Restoration','Druid-Balance','Paladin-Holy','Warlock-Destruction','DemonHunter-Havoc','Hunter-BeastMastery','Paladin-Protection','Mage-Arcane','Shaman-Elemental','Paladin-Retribution','Priest-Holy','Priest-Shadow','Warrior-Protection','Hunter-Marksmanship','DeathKnight-Unholy','Warlock-Demonology','DeathKnight-Blood','Evoker-Augmentation','Evoker-Devastation','Mage-Frost','Unknown-Unknown',}; local provider = {region='CN',realm='军团要塞',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Armstrong:BAAALAAFFAIIBAAAAA==.',Av='Avicii:BAAALAAECggICAAAAA==.',Bi='Bindee:BAAALAAECgYIDAAAAA==.',By='Byan:BAAALAAECgYIBgAAAA==.',Ch='Chigirihyoma:BAAALAADCgMIAwAAAA==.',Em='Emo:BAAALAAECgYIDwAAAA==.',Fo='Fofo:BAAALAAECgUIBQAAAA==.',Ku='Kumo:BAABLAAFFH8MAAIBAAgIUR+QBAC3AgABAAgIUR+QBAC3AgAAAA==.',Pi='Pia:BAAALAAFFAIIBAAAAA==.',Yo='Yolo:BAAALAAFFAIIBAAAAA==.',['Üü']='Üü:BAAALAAECgYIDgAAAA==.',['一极']='一极品天使一:BAAALAAECggIEQAAAA==.一极品家丁一:BAAALAAECggIEgAAAA==.一极品少爷一:BAAALAAECgcIEwAAAA==.一极榀镓钉一:BAAALAAECggIDwAAAA==.',['一样']='一样的阴霾:BAABLAAECn8dAAICAAgIJBkDHQABAgACAAgIJBkDHQABAgAAAA==.',['一笔']='一笔墨稠思一:BAABLAAECn8iAAMDAAgImQ+uDQCLAQADAAgIRQ+uDQCLAQAEAAgI6QkeGAD5AAAAAA==.',['七月']='七月毛毛:BAABLAAFFH8GAAIFAAQI2AibVwBrAAAFAAQI2AibVwBrAAAAAA==.七月狮子:BAABLAAFFH8MAAMGAAYIBRN2GABtAQAGAAYIBRN2GABtAQAHAAEIrwHFPQArAAAAAA==.',['不工']='不工:BAAALAAECgYIDgAAAA==.',['不许']='不许动贝克曼:BAAALAAFFAIIAgAAAA==.',['丨尐']='丨尐淸蒓灬:BAAALAADCgUIBQAAAA==.',['丰田']='丰田普拉多:BAAALAAECgMIAwAAAA==.',['丿鬼']='丿鬼舞丶乾坤:BAAALAAECgYIDgAAAA==.',['乖乖']='乖乖:BAABLAAFFH8SAAIIAAYINRO7DgCaAQAIAAYINRO7DgCaAQAAAA==.',['九儿']='九儿永不言败:BAABLAAFFH8GAAIBAAYIxA+WNgBhAQABAAYIxA+WNgBhAQAAAA==.',['云倚']='云倚:BAAALAAECgYICAABLAAFFAIICAAFAAsaAA==.',['五月']='五月双子:BAABLAAFFH8LAAMGAAgI0xIxEgCsAQAGAAcI9xExEgCsAQAHAAEIZgjENgA4AAAAAA==.',['伊墨']='伊墨:BAAALAAECgMIBgAAAA==.',['伊森']='伊森丶毁魔:BAABLAAECn8eAAIJAAgIaSAzGgDrAgAJAAgIaSAzGgDrAgAAAA==.',['优秀']='优秀老王:BAACLAAFFH8IAAIKAAIILxHPUgBHAAAKAAIILxHPUgBHAAAsAAQKfysAAgoACAinHpw5AHgCAAoACAinHpw5AHgCAAAA.',['传奇']='传奇游侠燎原:BAACLAAFFH8KAAILAAIICReoVwCRAAALAAIICReoVwCRAAAsAAQKfxkAAgsABggzImlbACUCAAsABggzImlbACUCAAEsAAQKBggfAAwAkh8A.',['伯爵']='伯爵丶凉凉:BAABLAAECn8ZAAIKAAcItRiFYQAGAgAKAAcItRiFYQAGAgAAAA==.',['你的']='你的影子:BAABLAAFFH8GAAINAAIIsAQ8ZQBpAAANAAIIsAQ8ZQBpAAAAAA==.',['假裝']='假裝緈鍢:BAABLAAFFH8cAAIJAAYIJRpzHwCfAQAJAAYIJRpzHwCfAQAAAA==.',['偶是']='偶是个奶萨:BAABLAAFFH8IAAMFAAIICxoKNQCXAAAFAAIICxoKNQCXAAAOAAIIihJaKQCVAAAAAA==.',['克林']='克林霉素:BAAALAAECgYIDAAAAA==.',['克罗']='克罗米米:BAAALAADCggICAAAAA==.',['六六']='六六刘:BAAALAAFFAIIAgAAAA==.',['六月']='六月巨蟹:BAABLAAFFH8UAAMGAAgIyRhQDgDYAQAGAAcIvxZQDgDYAQAHAAEIOwKLPAAvAAAAAA==.六月疯魔:BAAALAADCgIIAgAAAA==.',['养生']='养生局混子:BAAALAAFFAMIAwAAAA==.',['冰火']='冰火世界:BAABLAAFFH8KAAIPAAII4wshbQBAAAAPAAII4wshbQBAAAAAAA==.',['凉风']='凉风吹肚皮:BAAALAAECgYICgAAAA==.',['凛冬']='凛冬又逢精灵:BAAALAAECgUIBQAAAA==.',['别回']='别回头是硪:BAABLAAFFH8GAAILAAYIJQECtwAyAAALAAYIJQECtwAyAAAAAA==.别回頭是我:BAABLAAFFH8FAAIPAAUIBgOTNwDEAAAPAAUIBgOTNwDEAAAAAA==.',['剑白']='剑白:BAAALAAECgUIBQAAAA==.',['剥皮']='剥皮自己打:BAAALAAFFAIIAgAAAA==.',['包不']='包不同:BAAALAAECgEIAQAAAA==.',['包老']='包老太爷:BAAALAADCgMIBQAAAA==.',['医用']='医用棉签:BAAALAAECgUIBQAAAA==.',['十年']='十年后猎高嘲:BAAALAAFFAIIAgAAAA==.',['卖糖']='卖糖术神:BAAALAADCgQIBAAAAA==.',['卡卡']='卡卡特罗:BAAALAAECggICAAAAA==.',['印第']='印第安老斑鸠:BAAALAAECgYIBgAAAA==.',['卷煎']='卷煎鸡蛋:BAAALAAFFAIIAgAAAA==.',['发条']='发条橙:BAABLAAFFH8XAAMGAAYI8xzfDQDeAQAGAAYI8xzfDQDeAQAHAAQIcBMlHwDJAAAAAA==.',['右眼']='右眼看见你:BAABLAAFFH8VAAMQAAYI/BbpGgB3AQAQAAUIoBnpGgB3AQARAAQIUAfwHgCRAAAAAA==.',['向佐']='向佐:BAAALAAECgUIBQAAAA==.',['向山']='向山:BAAALAAECgYIBgAAAA==.',['吸鼠']='吸鼠霸王:BAABLAAFFH8NAAISAAIIrR40EwC1AAASAAIIrR40EwC1AAABLAAFFAYIFwAGAPMcAA==.',['唯物']='唯物辩证法:BAAALAAECgMIBAAAAA==.',['喵了']='喵了个咪的丶:BAAALAAECgEIAQAAAA==.',['嘉睿']='嘉睿:BAABLAAFFH8IAAIFAAQIHgMxSACOAAAFAAQIHgMxSACOAAAAAA==.',['嘎斯']='嘎斯提:BAAALAAECgMIAwAAAA==.',['四月']='四月牛牛:BAABLAAFFH8SAAMGAAYIwxwjGQBmAQAGAAUItRojGQBmAQAHAAEIiAWnOQA0AAAAAA==.',['圆滚']='圆滚滚的骑士:BAAALAAECgEIAQAAAA==.',['圣光']='圣光使者:BAAALAADCgIIAgAAAA==.圣光天命人:BAAALAAECggICAAAAA==.',['地狱']='地狱尚香:BAAALAAECgcIBwAAAA==.',['墨墨']='墨墨:BAAALAAECgYICAAAAA==.',['壹五']='壹五柒三:BAAALAAECgYIBgAAAA==.',['大儒']='大儒名宿:BAAALAAECgYIDAAAAA==.',['大爷']='大爷会骑术:BAAALAAFFAIIAwAAAA==.',['天剑']='天剑非天:BAACLAAFFH8OAAIPAAQIygylTQBfAAAPAAQIygylTQBfAAAsAAQKfxwAAg8ABggOHfJ8APEBAA8ABggOHfJ8APEBAAAA.',['天外']='天外来客:BAAALAAECgIIAgAAAA==.',['天雨']='天雨流芳:BAAALAADCgEIAQAAAA==.',['契约']='契约骑:BAAALAAECgYIBgAAAA==.',['奥沙']='奥沙利毒:BAAALAAECgIIAgAAAA==.',['娜儿']='娜儿可爱吖:BAACLAAFFH8cAAILAAYIXBWzLwB5AQALAAYIXBWzLwB5AQAsAAQKfxcAAwsACAi4FjBHALkBAAsACAi4FjBHALkBABMABggkDOpvAAwBAAAA.',['婷姐']='婷姐小七宝:BAABLAAFFH8KAAIBAAIIogfWjQA/AAABAAIIogfWjQA/AAAAAA==.婷姐小元宵:BAABLAAFFH8GAAIPAAYIQAEofAA1AAAPAAYIQAEofAA1AAAAAA==.婷姐小年糕:BAABLAAFFH8GAAICAAIIBwerXAA5AAACAAIIBwerXAA5AAAAAA==.婷姐小术娘:BAAALAAFFAIIAwAAAA==.婷姐熊宝:BAAALAAECggICAAAAA==.',['孤独']='孤独的流星:BAAALAAFFAIIAgAAAA==.',['宠物']='宠物收容所长:BAAALAAECgYIBgAAAA==.',['将进']='将进舞姝莫停:BAAALAAECgYIBgAAAA==.',['小丑']='小丑鱼:BAAALAADCgQIBAAAAA==.',['小胖']='小胖孩:BAAALAAECgYICwABLAAFFAYIDQACALkkAA==.',['小豆']='小豆娘:BAAALAAECgYIEQAAAA==.',['小鱼']='小鱼崽:BAAALAAECgIIAgAAAA==.',['尔哆']='尔哆隆拉:BAAALAAECgEIAQAAAA==.',['希尔']='希尔瓦娜丝:BAACLAAFFH8YAAILAAcI4wZ2OwBVAQALAAcI4wZ2OwBVAQAsAAQKfx0AAgsACAjKE51BAckAAAsACAjKE51BAckAAAAA.',['引领']='引领传奇:BAAALAAFFAIIAgAAAA==.',['微胖']='微胖:BAAALAAECgMIBQAAAA==.',['德行']='德行不行:BAABLAAECn8UAAIHAAgI9wnCNwDfAAAHAAgI9wnCNwDfAAAAAA==.',['心灵']='心灵风暴:BAAALAAECgcIEwAAAA==.',['快给']='快给我拯救:BAAALAAECgYIDAAAAA==.',['愤怒']='愤怒的牛血:BAABLAAFFH8FAAIFAAIIkgr6ZQBVAAAFAAIIkgr6ZQBVAAAAAA==.',['我勒']='我勒丶个去:BAAALAADCgMIAwAAAA==.',['把把']='把把杠上花:BAABLAAFFH8LAAIBAAQINA8EUQDXAAABAAQINA8EUQDXAAAAAA==.',['抹茶']='抹茶星冰泪:BAABLAAFFH8sAAINAAYI+B/vFwDAAQANAAYI+B/vFwDAAQAAAA==.',['拥慌']='拥慌:BAAALAAECgYIBgAAAA==.',['提昂']='提昂:BAABLAAECn8ZAAICAAcIDx6CPgA7AgACAAcIDx6CPgA7AgAAAA==.',['新新']='新新:BAAALAADCgcIBwAAAA==.',['无尽']='无尽战刃:BAAALAADCgEIAQAAAA==.',['旷野']='旷野孤疆:BAAALAADCgEIAQAAAA==.',['春季']='春季里开花:BAAALAADCggICAAAAA==.',['晨曦']='晨曦微寒:BAAALAADCgIIAgAAAA==.',['暗夜']='暗夜凛冬:BAABLAAFFH8HAAIBAAMIBgyDMwDPAAABAAMIBgyDMwDPAAAAAA==.',['暗黑']='暗黑刃:BAAALAADCgEIAQAAAA==.',['有话']='有话就说:BAAALAAFFAIIAgAAAA==.',['望生']='望生塔之歌:BAAALAAECgEIAQAAAA==.',['末日']='末日号角:BAAALAAECgYIBgAAAA==.',['朱轩']='朱轩怀雀:BAAALAAECgMIAwAAAA==.',['杨哥']='杨哥:BAAALAAECgcIAwAAAA==.',['林下']='林下風丶:BAABLAAFFH8GAAMRAAIItAQDJwB1AAARAAIItAQDJwB1AAAQAAII0RFLPQBvAAAAAA==.',['果果']='果果尐:BAABLAAFFH8PAAIMAAUIeR7cBQB7AQAMAAUIeR7cBQB7AQABLAAFFAYIFQAQAPwWAA==.',['枫扬']='枫扬扬:BAAALAADCgcIBwAAAA==.',['柳智']='柳智敏:BAAALAAECgYICgAAAA==.',['栩翼']='栩翼:BAABLAAFFH8oAAILAAYIJhmVKwCGAQALAAYIJhmVKwCGAQAAAA==.',['永远']='永远的瓦王:BAAALAAECgIIAgAAAA==.',['汉堡']='汉堡王:BAAALAADCgEIAQAAAA==.',['法克']='法克游:BAAALAAFFAIIAgABLAAFFAgIBwABAFQYAA==.',['法天']='法天象地:BAAALAAECgMIAwAAAA==.',['泰格']='泰格猎风:BAAALAAECgEIAQAAAA==.',['浑水']='浑水:BAAALAADCgMIAwAAAA==.',['涌夜']='涌夜:BAABLAAFFH8QAAMUAAYI/Qk/CQDWAAAUAAQILwg/CQDWAAABAAMITAo/agBrAAAAAA==.',['滴滴']='滴滴打德:BAAALAAECgIIAgAAAA==.',['灬夏']='灬夏之洛熙灬:BAAALAAECgYICAAAAA==.',['灰啊']='灰啊灰:BAAALAADCgYIBgAAAA==.',['烟雨']='烟雨如情:BAAALAAECgYICwAAAA==.烟雨如语:BAAALAAECgQIBAAAAA==.',['热烈']='热烈的马:BAACLAAFFH8GAAIVAAIIsBXkFACaAAAVAAIIsBXkFACaAAAsAAQKfxoAAhUACAjKIMENAJcCABUACAjKIMENAJcCAAAA.',['牛哞']='牛哞哞:BAAALAAFFAIIAgAAAA==.',['牛憨']='牛憨憨:BAAALAAECgYICgAAAA==.',['狂暴']='狂暴小猴:BAABLAAFFH8KAAISAAII0xbrJAB0AAASAAII0xbrJAB0AAAAAA==.狂暴的小强:BAAALAAECgYIBgAAAA==.',['獵之']='獵之殇:BAAALAAECgIIAgAAAA==.',['玄阳']='玄阳:BAABLAAFFH8HAAIPAAMIKxIVRgCCAAAPAAMIKxIVRgCCAAAAAA==.',['玖玖']='玖玖娃儿:BAAALAAFFAIIAgAAAA==.',['玩具']='玩具骑士:BAABLAAECn8YAAIIAAYI+RDFJAAcAQAIAAYI+RDFJAAcAQAAAA==.',['璐璐']='璐璐张:BAACLAAFFH8oAAIGAAYI6xrmDgDRAQAGAAYI6xrmDgDRAQAsAAQKfxUAAgYACAhUGIMqAIwBAAYACAhUGIMqAIwBAAAA.',['瘾大']='瘾大技术差:BAACLAAFFH8gAAIPAAYIxiHsBQAIAgAPAAYIxiHsBQAIAgAsAAQKfzwAAg8ACAjQJkgBAJQDAA8ACAjQJkgBAJQDAAAA.',['白兰']='白兰地丶:BAABLAAFFH8XAAIEAAgIoCJlAAD5AgAEAAgIoCJlAAD5AgAAAA==.',['白墨']='白墨浅离:BAABLAAECn8eAAISAAgITA+2OgCcAQASAAgITA+2OgCcAQAAAA==.',['白猫']='白猫球长:BAAALAAECgEIAQAAAA==.',['白色']='白色婚纱:BAABLAAFFH8MAAIWAAgI2Q7EBgDJAQAWAAgI2Q7EBgDJAQAAAA==.',['白骑']='白骑:BAAALAAFFAMIAwABLAAFFAcIMgAJAGQiAA==.',['皮卡']='皮卡丘啊哈:BAABLAAFFH8cAAMTAAYIOh0IAwDLAQATAAYIOh0IAwDLAQALAAQIpw1SYQC4AAABLAAFFAgITAAXAAsgAA==.皮卡丘欸嘿:BAACLAAFFH9MAAMXAAgICyDtAACqAgAXAAgIax/tAACqAgAYAAcITiBmAwA4AgAsAAQKfx4AAxgACAg+I54LAOgCABgACAg+I54LAOgCABcAAQj8E6kcADMAAAAA.',['相思']='相思红:BAABLAAFFH8GAAIPAAIIPhCxUQCRAAAPAAIIPhCxUQCRAAAAAA==.',['砂狼']='砂狼白子:BAAALAAECgcICAAAAA==.',['破名']='破名乀难起:BAAALAAFFAIIAgAAAA==.',['离空']='离空岛海:BAACLAAFFH8KAAIUAAMIqxD8BwDtAAAUAAMIqxD8BwDtAAAsAAQKfxkAAhQACAh1CxItAFsBABQACAh1CxItAFsBAAEsAAUUCAgzAA4AmhUA.',['秦酿']='秦酿:BAAALAAFFAEIAQAAAA==.',['米加']='米加勒:BAAALAAECgYIEQAAAA==.',['索马']='索马里钢蛋:BAAALAADCgcICgAAAA==.',['紫蓝']='紫蓝羊肉:BAAALAAECgYICgAAAA==.',['红猫']='红猫球长:BAAALAAECgYIBgAAAA==.',['继续']='继续加强武僧:BAAALAAFFAIIAgAAAA==.',['缠中']='缠中说缠:BAABLAAFFH8QAAILAAgIGx+QBACpAgALAAgIGx+QBACpAgAAAA==.',['罐儿']='罐儿破鸟:BAAALAAECgYICgAAAA==.',['罗宾']='罗宾翰:BAAALAAECgEIAQAAAA==.',['罗温']='罗温:BAAALAAFFAYIBAAAAA==.',['老牛']='老牛抬圈大:BAAALAAECgQIBgAAAA==.',['老王']='老王优秀:BAAALAAFFAIIBAAAAA==.',['考拉']='考拉快跑:BAAALAAECgQIBAAAAA==.',['聖光']='聖光丶舞步:BAAALAAECgYIBgAAAA==.',['肆意']='肆意:BAAALAAECgUIBQAAAA==.',['至高']='至高之锤:BAAALAAECgEIAQAAAA==.',['茶茶']='茶茶小妹:BAABLAAECn8UAAMSAAgIjg6GKwD5AAASAAcI5QqGKwD5AAACAAcI5w3qZADmAAAAAA==.',['莱铬']='莱铬拉斯:BAAALAAFFAIIBAAAAA==.',['落落']='落落岁寒丶:BAABLAAFFH8VAAIFAAYI6Q9RDgBaAQAFAAYI6Q9RDgBaAQAAAA==.',['蒸馏']='蒸馏水:BAAALAAECgYICAAAAA==.',['蔡总']='蔡总一号:BAAALAAECgEIAQAAAA==.',['蔷头']='蔷头的愺:BAAALAAFFAIIBAAAAA==.',['蕾蕊']='蕾蕊儿:BAAALAAECgYIEAAAAA==.',['蜡笔']='蜡笔小乖:BAAALAAECgYIEQAAAA==.',['西瓜']='西瓜小含片:BAABLAAECn8UAAMZAAYIkROlHQAzAQAZAAYIkROlHQAzAQANAAMIbANj7ABtAAAAAA==.西瓜德:BAAALAAECgYIEAAAAA==.西瓜霜含片:BAABLAAECn8WAAIFAAYIXB9XIQDyAQAFAAYIXB9XIQDyAQAAAA==.',['跌跌']='跌跌:BAABLAAFFH8GAAIBAAYILhOzMQB0AQABAAYILhOzMQB0AQAAAA==.',['踮脚']='踮脚大美:BAAALAAECgYIEAAAAA==.',['车斤']='车斤骨亥:BAABLAAFFH8KAAIPAAMIYxYaMwCoAAAPAAMIYxYaMwCoAAAAAA==.',['过去']='过去的哀伤:BAABLAAECn8dAAIZAAcILhSmGQBVAQAZAAcILhSmGQBVAQAAAA==.',['近战']='近战法爷:BAABLAAECn8kAAMZAAYImxo8FwBsAQAZAAYImxo8FwBsAQANAAEI5gPbCwEmAAAAAA==.',['逸尚']='逸尚界玖号:BAAALAAFFAMIBAAAAA==.',['邪真']='邪真人:BAAALAAFFAIIAgAAAA==.',['铁骑']='铁骑:BAABLAAFFH8GAAIBAAII5xCjcwCOAAABAAII5xCjcwCOAAAAAA==.',['铁鱼']='铁鱼四号:BAACLAAFFH8PAAIKAAYIJgucMAARAQAKAAYIJgucMAARAQAsAAQKfxcAAgoACAh8H+UgAN8CAAoACAh8H+UgAN8CAAAA.',['银辉']='银辉:BAAALAAFFAIIAwAAAA==.',['阴魂']='阴魂死骑:BAAALAAECgYIEQAAAA==.',['阿尔']='阿尔纹:BAAALAAECgYIBgAAAA==.',['阿森']='阿森纳是冠军:BAAALAADCgIIAgAAAA==.',['雪碧']='雪碧:BAAALAAECgQIBAAAAA==.',['雲飛']='雲飛兒:BAABLAAECn8aAAINAAYIVRsiZwDSAQANAAYIVRsiZwDSAQAAAA==.',['霜天']='霜天:BAABLAAFFH8kAAIPAAYIJiPZBAAdAgAPAAYIJiPZBAAdAgAAAA==.',['青车']='青车:BAACLAAFFH8nAAMVAAcIoxIGBwDPAAAJAAcIoxIcHQCrAQAVAAMIoQUGBwDPAAAsAAQKfy8AAxUACAjWG+EXADkCAAkACAgGGzgyAHMCABUACAjKF+EXADkCAAAA.',['非凡']='非凡牛牛:BAAALAAECgYICgAAAA==.',['顺你']='顺你一棍子:BAAALAADCgIIAgAAAA==.',['風雲']='風雲無雙:BAAALAAECggICAAAAA==.',['風鳴']='風鳴葉薩:BAAALAAFFAIIBAAAAA==.',['风月']='风月之喵:BAAALAADCgMIAwAAAA==.风月之尖:BAAALAAECgYIEgABLAAECggIDwAaAAAAAA==.风月之巅:BAAALAAECggIDwAAAA==.风月小死骑:BAAALAAECgUIBwAAAA==.',['风灵']='风灵舞:BAAALAADCgEIAQAAAA==.',['风逍']='风逍:BAAALAAECggICgAAAA==.',['风雨']='风雨夜归人:BAACLAAFFH8HAAILAAII3gr6qgA5AAALAAII3gr6qgA5AAAsAAQKfyIAAwsABgggHDpiAH4BAAsABgggHDpiAH4BABMAAghVCIivAFEAAAAA.',['飞暴']='飞暴:BAABLAAFFH8MAAILAAYIChU1NQBnAQALAAYIChU1NQBnAQAAAA==.',['馨雨']='馨雨丶:BAAALAAECgYIBgAAAA==.',['骑潴']='骑潴追流星:BAAALAAECgIIAgAAAA==.',['骑猪']='骑猪上大树:BAABLAAFFH8NAAIFAAgI1hlyBQBrAgAFAAgI1hlyBQBrAgAAAA==.',['魅丽']='魅丽新新:BAAALAAECgYIBgAAAA==.',['魔人']='魔人小虫:BAAALAAECgMIAgAAAA==.',['鱼丸']='鱼丸:BAAALAADCgEIAQAAAA==.',['鱼子']='鱼子酱:BAAALAAECgYIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end