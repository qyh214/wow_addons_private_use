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
 local lookup = {'DeathKnight-Frost','Shaman-Restoration','Shaman-Elemental','Druid-Restoration','Hunter-BeastMastery','Mage-Frost','Warlock-Destruction','Priest-Holy','Warlock-Demonology','DemonHunter-Havoc','Hunter-Marksmanship','Rogue-Outlaw','Rogue-Subtlety','Hunter-Survival','DeathKnight-Unholy','Mage-Arcane','Druid-Feral','Druid-Balance','Monk-Brewmaster','Paladin-Retribution','Warrior-Fury','DemonHunter-Vengeance','DeathKnight-Blood','Monk-Mistweaver','Evoker-Preservation','Evoker-Devastation','Paladin-Holy','Monk-Windwalker','Warrior-Protection','Rogue-Assassination','Priest-Shadow','Druid-Guardian','Shaman-Enhancement','Paladin-Protection','Priest-Discipline','Mage-Fire','Unknown-Unknown',}; local provider = {region='CN',realm='金度',name='CN',type='weekly',zone=44,date='2025-12-09',data={Af='Afkeyboard:BAABLAAFFH8FAAIBAAII9QIWoQA1AAABAAII9QIWoQA1AAAAAA==.',Ar='Arms:BAAALAAECgYICgAAAA==.',Ba='Bareheaded:BAAALAAECgYICQAAAA==.',Bi='Bigbinbing:BAAALAAECgMIAwAAAA==.',Ca='Carroth:BAAALAAECgYIDwAAAA==.',Cr='Crazykfc:BAAALAADCgUIBQAAAA==.',Dr='Draculall:BAAALAADCgIIAgAAAA==.Draculalzl:BAAALAADCgMIAwAAAA==.Draculaz:BAAALAADCgQIBAAAAA==.Drxper:BAAALAADCgIIAgAAAA==.',En='Enshadow:BAAALAAFFAIIBAAAAA==.',Fa='Faye:BAAALAAECgQIBAAAAA==.',Fe='Feketerigó:BAAALAAECgYIDAAAAA==.',Ga='Gamble:BAABLAAFFH8GAAICAAYIeg4AJgA0AQACAAYIeg4AJgA0AQAAAA==.',Go='Gogo:BAACLAAFFH8OAAMDAAYI2gjBKgDvAAADAAYI2gjBKgDvAAACAAIIlRURUAB9AAAsAAQKfxoAAwIACAjFGMEXADYCAAIACAjFGMEXADYCAAMABggOIpMWAPkBAAAA.',Ha='Harajuku:BAAALAAFFAIIBAAAAA==.',Ho='Holocene:BAAALAAECgcIBwAAAA==.',Iz='Izvestia:BAAALAAECgEIAQAAAA==.',Jk='Jkl:BAABLAAFFH8MAAIEAAUInw6BIAAgAQAEAAUInw6BIAAgAQAAAA==.',Kr='Krious:BAAALAAECgYIDAABLAAECggITAAFAF4kAA==.',La='Latomate:BAAALAADCgQIBAAAAA==.',Mi='Milkbottle:BAABLAAECn8eAAIEAAYIDxTxPAArAQAEAAYIDxTxPAArAQAAAA==.Misa:BAAALAAECgQIBAAAAA==.',Mz='Mzero:BAABLAAFFH8PAAIGAAYI+SQLAQAjAgAGAAYI+SQLAQAjAgAAAA==.',Na='Narcissa:BAABLAAFFH8GAAIHAAIIVAxqTwCCAAAHAAIIVAxqTwCCAAAAAA==.',No='Noli:BAAALAAFFAIIAgAAAA==.',Pi='Pinke:BAAALAAECgYIBgAAAA==.',Pl='Playeraucuoo:BAAALAAECgMIAwAAAA==.',Pu='Purpehaze:BAABLAAFFH8GAAIIAAIIwgdpRABjAAAIAAIIwgdpRABjAAAAAA==.',Ro='Rosekelly:BAAALAAECgUIBQAAAA==.',Sa='Sarateamo:BAAALAAECgYIBwAAAA==.',Sh='Shark:BAAALAAECgQIBQAAAA==.',So='Soloist:BAAALAAECgYIDAAAAA==.',Ta='Tasse:BAAALAADCgYIBgAAAA==.',Ti='Tian:BAAALAAFFAIIAgAAAA==.Tinker:BAAALAAECgEIAQAAAA==.',Va='Valentinoå:BAAALAAECgEIAQAAAA==.',['一发']='一发毁灭:BAABLAAECn84AAMJAAgIESB6CADgAgAJAAgIESB6CADgAgAHAAcIRBKHMgCEAQABLAAECggITAAFAF4kAA==.',['一小']='一小萨一:BAAALAAECgcIBwAAAA==.',['一念']='一念之别:BAAALAADCgcIBwAAAA==.一念百年:BAAALAAECgQIBAAAAA==.',['一梦']='一梦两三年:BAABLAAFFH8JAAIBAAII8xH5hQBDAAABAAII8xH5hQBDAAAAAA==.',['一碰']='一碰就碎:BAAALAAFFAEIAQAAAA==.',['一粒']='一粒子弹:BAABLAAFFH8IAAIKAAIIzR53SABZAAAKAAIIzR53SABZAAAAAA==.',['一野']='一野卜鸠你:BAAALAAFFAIIBAAAAA==.',['一零']='一零一:BAAALAAFFAIIAgAAAA==.',['丁尼']='丁尼格菲儿:BAABLAAFFH8KAAMLAAIIaBolIQCGAAALAAIICxMlIQCGAAAFAAEIyRmAhQBMAAAAAA==.',['上京']='上京临潢府:BAABLAAECn8jAAIKAAgI2iOcCQBSAwAKAAgI2iOcCQBSAwAAAA==.上京会宁府:BAAALAAECggIEAAAAA==.',['不捅']='不捅不爽斯基:BAABLAAECn8iAAMMAAgIxx0ZAQBwAgAMAAgIxx0ZAQBwAgANAAIIYhRWHwBJAAABLAAECggITAAFAF4kAA==.',['不死']='不死降神:BAAALAAECgYICQAAAA==.',['不灭']='不灭壁垒:BAAALAADCgQIBAAAAA==.',['不爱']='不爱了:BAAALAAECgYIDAAAAA==.',['不知']='不知道:BAAALAAECgUIBwAAAA==.',['不要']='不要酱紫嘛:BAAALAAECgIIBAAAAA==.',['不负']='不负少年:BAAALAAECgQIBAAAAA==.',['专治']='专治各种不服:BAACLAAFFH8LAAMFAAIIGBK3oAA/AAALAAIIjwE/MwBJAAAFAAIIGBK3oAA/AAAsAAQKfxkAAwUACAjGDMS1AP4AAAUABwgsDMS1AP4AAAsACAiVBWd5APAAAAAA.',['东门']='东门听雨:BAAALAAECgEIAQAAAA==.',['东风']='东风伍壹:BAAALAAECgYIBgAAAA==.东风导弹:BAAALAAECgMIAwAAAA==.',['丨烬']='丨烬渊丶:BAAALAAECgYIEAAAAA==.',['丨瞳']='丨瞳橙丶:BAAALAAFFAIIAgAAAA==.',['丶亦']='丶亦久亦旧:BAABLAAFFH8IAAIFAAIISwvtqAA7AAAFAAIISwvtqAA7AAAAAA==.',['丶伊']='丶伊莉雅:BAAALAAFFAIIAgAAAA==.',['丶偏']='丶偏居一隅:BAAALAAECgEIAgAAAA==.',['丶电']='丶电饭锅:BAAALAAECgYIBgAAAA==.',['丶荔']='丶荔枝桃桃:BAABLAAFFH8GAAIFAAYIxxa2CwDbAQAFAAYIxxa2CwDbAQAAAA==.',['为你']='为你我不配:BAAALAAFFAIIBAAAAA==.为你我喜欢:BAABLAAFFH8IAAIOAAII+R0XBACgAAAOAAII+R0XBACgAAAAAA==.',['丽丽']='丽丽俪:BAAALAAECgYIEgAAAA==.',['乌托']='乌托邦:BAAALAAECgYIBgAAAA==.',['乌莲']='乌莲娜的愤怒:BAAALAAECgEIAQAAAA==.',['乙醛']='乙醛脱氢酶:BAAALAAECgMIAwAAAA==.',['九五']='九五二柒:BAAALAADCgIIAgAAAA==.',['亅爷']='亅爷:BAAALAAECgcIBwAAAA==.',['二零']='二零七:BAAALAAFFAIIAgAAAA==.',['五十']='五十二日:BAAALAAECgEIAQAAAA==.',['五枪']='五枪:BAAALAAECgYICwAAAA==.',['亚尔']='亚尔佛莉德:BAABLAAFFH8GAAIFAAIIQA9ymQBCAAAFAAIIQA9ymQBCAAAAAA==.',['人像']='人像三要素:BAAALAAFFAIIAgAAAA==.',['仇白']='仇白:BAABLAAFFH8MAAIHAAYIUBhEKAB7AQAHAAYIUBhEKAB7AQAAAA==.',['他太']='他太团队了:BAABLAAFFH8SAAIFAAcIix/3DgAVAgAFAAcIix/3DgAVAgAAAA==.',['仙人']='仙人牛格尔:BAAALAAECgUIBgAAAA==.',['令糊']='令糊葱:BAAALAAECgUIBQAAAA==.',['仲德']='仲德:BAAALAAECgQIBAAAAA==.',['伊丶']='伊丶念逍遥:BAAALAAECgYICQAAAA==.',['伊达']='伊达哥:BAAALAAECgYIDAAAAA==.',['伽楠']='伽楠:BAACLAAFFH8FAAIBAAIIwQvvkAA/AAABAAIIwQvvkAA/AAAsAAQKfxUAAwEABwhRGqZmACgCAAEABwiiGaZmACgCAA8AAwgkG+9EALYAAAAA.',['余小']='余小米:BAAALAAFFAIIBAAAAA==.',['你给']='你给路达呦:BAAALAAECgUICAAAAA==.',['依依']='依依熠熠:BAABLAAFFH8IAAIQAAII8BzKUQCPAAAQAAII8BzKUQCPAAAAAA==.',['依旧']='依旧那个角度:BAACLAAFFH8sAAIQAAcIxB8oEAD+AQAQAAcIxB8oEAD+AQAsAAQKfz4AAxAACAg6I24XAPcCABAACAg6I24XAPcCAAYAAQggE52RADgAAAAA.',['倪好']='倪好:BAACLAAFFH8JAAIRAAMIHg4LBwDnAAARAAMIHg4LBwDnAAAsAAQKfx4AAhEACAhcHaoLAJUCABEACAhcHaoLAJUCAAAA.',['催眠']='催眠:BAAALAAECgMIBAAAAA==.',['傷逝']='傷逝:BAAALAADCgQIBAAAAA==.',['光丶']='光丶:BAAALAAFFAIIBAAAAA==.',['光天']='光天化曰:BAABLAAFFH8IAAISAAII1w7aNgA5AAASAAII1w7aNgA5AAAAAA==.',['光芒']='光芒疾风:BAABLAAFFH8GAAITAAYIDhBmEABHAQATAAYIDhBmEABHAQAAAA==.',['光铸']='光铸关注我:BAAALAAECgcIBwAAAA==.光铸臊蹄子:BAABLAAFFH8JAAIUAAII1hRbYABGAAAUAAII1hRbYABGAAAAAA==.',['克里']='克里斯丨蒂娜:BAAALAAECgEIAQAAAA==.',['八月']='八月啊八月:BAAALAAECgUICAAAAA==.',['六月']='六月小镇:BAAALAAECgYICQAAAA==.',['内个']='内个水木师:BAAALAAFFAIIAgAAAA==.',['再打']='再打叫老师了:BAAALAAECgYIBQAAAA==.',['冒丶']='冒丶泡:BAABLAAFFH8GAAIQAAYIGxgsKAB2AQAQAAYIGxgsKAB2AQAAAA==.',['冬瓜']='冬瓜小牧師:BAABLAAFFH8GAAIIAAIIsRd7KwCVAAAIAAIIsRd7KwCVAAAAAA==.',['冰中']='冰中飞舞:BAAALAAECgEIAQAAAA==.',['冰巛']='冰巛涔涔:BAABLAAFFH8LAAIVAAQI8hMBLwDlAAAVAAQI8hMBLwDlAAABLAAFFAYIDAAQAO8eAA==.',['冰涔']='冰涔涔:BAABLAAFFH8MAAIQAAII7x5ATQBbAAAQAAII7x5ATQBbAAAAAA==.',['冰碴']='冰碴子:BAAALAAECgYIBgAAAA==.',['冲锋']='冲锋三十八:BAAALAADCgIIAgAAAA==.',['冲鸭']='冲鸭卡比丘:BAABLAAECn8jAAIUAAcIFxp7XQAxAgAUAAcIFxp7XQAxAgAAAA==.',['冻结']='冻结的时间:BAAALAAECgEIAQAAAA==.',['凝冰']='凝冰:BAAALAAECgcIDQAAAA==.',['凝霜']='凝霜:BAAALAAECgEIAQAAAA==.',['刀有']='刀有点假:BAAALAAECgMIAwAAAA==.',['刘岩']='刘岩:BAAALAAECggIDwAAAA==.',['初夏']='初夏雨凉:BAAALAAECgYIEAAAAA==.',['刺猬']='刺猬:BAABLAAFFH8GAAIEAAYIExdrFQCPAQAEAAYIExdrFQCPAQAAAA==.',['剩光']='剩光光:BAAALAADCgYICAAAAA==.',['劳伦']='劳伦斯:BAAALAAECgcIEgAAAA==.',['十一']='十一月的肖邦:BAAALAAECgQIBAAAAA==.',['十七']='十七丶风行者:BAABLAAECn9MAAMFAAgIXiTlCQDRAgAFAAgIXiTlCQDRAgALAAUIbBD+dAD9AAAAAA==.',['十三']='十三号大胡子:BAAALAAECgUICAAAAA==.',['千里']='千里邀月:BAAALAAECgMIAwAAAA==.',['单彩']='单彩色:BAACLAAFFH8RAAIFAAUIkA0aUwAIAQAFAAUIkA0aUwAIAQAsAAQKfxQAAgUABggQHeJ0APMBAAUABggQHeJ0APMBAAAA.',['单调']='单调的人生:BAAALAAECgYIBgAAAA==.单调的红:BAABLAAFFH8VAAICAAUIZA88LQADAQACAAUIZA88LQADAQAAAA==.',['卡尔']='卡尔瑪:BAAALAAECgYIBgAAAA==.',['厄提']='厄提诺斯:BAAALAAECgcIDAABLAAECggITAAFAF4kAA==.',['原味']='原味食物:BAAALAAECgYICQAAAA==.',['又要']='又要取名字了:BAABLAAFFH8LAAMWAAIIcQ65FQBeAAAWAAIIcQ65FQBeAAAKAAIIEwYWawA0AAAAAA==.',['双刀']='双刀小游子:BAAALAADCgcICwAAAA==.双刀流:BAAALAAFFAIIAgAAAA==.',['取名']='取名要随机:BAABLAAFFH8IAAIVAAgIHQPxWAA+AAAVAAgIHQPxWAA+AAAAAA==.',['只是']='只是近黄昏:BAAALAADCgEIAQAAAA==.',['叫丶']='叫丶兽:BAAALAAECggIEAAAAA==.',['叫米']='叫米幺幺零:BAAALAAECgYIDgAAAA==.',['可莉']='可莉頑家:BAABLAAFFH8MAAMLAAYITx23BADnAQALAAYIBxe3BADnAQAFAAQIRB/5EgCOAQAAAA==.',['吊龙']='吊龙:BAAALAAFFAIIAgABLAAFFAYIHQAFAB8WAA==.',['名字']='名字么所谓:BAAALAADCgYIBgAAAA==.',['吥會']='吥會訫動:BAABLAAFFH8LAAMBAAQIWRNHUQDeAAABAAQIWRNHUQDeAAAXAAMIKQIwGQA+AAAAAA==.',['吹个']='吹个气球:BAAALAAECgYIBgAAAA==.吹个球:BAAALAADCgUIBQAAAA==.',['呆毛']='呆毛大魔王:BAAALAAFFAIIBAAAAA==.',['呜啦']='呜啦啦:BAAALAAECgYIBgAAAA==.',['呜噜']='呜噜噜疤:BAAALAADCgEIAQAAAA==.',['呼呼']='呼呼哒哒鸡:BAAALAADCgYIBgAAAA==.',['咘悠']='咘悠咘悠:BAABLAAFFH8LAAIYAAMIcRS3DwDJAAAYAAMIcRS3DwDJAAAAAA==.',['哈特']='哈特菲莉娅:BAAALAADCgIIAgAAAA==.',['哎呦']='哎呦洼拉:BAAALAAECggIEAAAAA==.',['哒哒']='哒哒呼呼鸡:BAAALAAECgYICAAAAA==.',['唔知']='唔知小旭:BAAALAAECgYICwAAAA==.',['啦道']='啦道:BAAALAAFFAIIBAAAAA==.',['喜哥']='喜哥:BAABLAAFFH8IAAMZAAIIDwutGwBkAAAZAAIIDwutGwBkAAAaAAIIEwk3IwAyAAAAAA==.',['嗜血']='嗜血丹:BAABLAAECn8ZAAMKAAYI/g14YAAAAQAKAAYIOQt4YAAAAQAWAAYIOwr6QgDXAAAAAA==.嗜血和尚:BAAALAAFFAIIAgAAAA==.',['嗷丶']='嗷丶:BAAALAADCgYIBgAAAA==.',['嘟嘟']='嘟嘟傻满丶:BAABLAAFFH8IAAICAAgITx9yAgDKAgACAAgITx9yAgDKAgAAAA==.',['固定']='固定剂:BAAALAAFFAIIBAAAAA==.',['圣光']='圣光抛弃我:BAAALAAECgEIAQAAAA==.圣光胜于打码:BAABLAAECn8pAAIUAAgI8yGADQClAgAUAAgI8yGADQClAgABLAAECggITAAFAF4kAA==.圣光闪先:BAABLAAFFH8GAAIUAAYIUQBGhwARAAAUAAYIUQBGhwARAAAAAA==.',['圣卩']='圣卩光之手:BAAALAAECgMIAwAAAA==.',['圣戮']='圣戮:BAAALAADCgIIAgAAAA==.',['圣珈']='圣珈堂:BAACLAAFFH8bAAIUAAYIEh+eEADEAQAUAAYIEh+eEADEAQAsAAQKfzEAAhQACAg5JbsIAGADABQACAg5JbsIAGADAAAA.',['地狱']='地狱勇士:BAABLAAFFH8GAAIBAAII+w3GiwBBAAABAAII+w3GiwBBAAAAAA==.',['坏壊']='坏壊灬孩孓气:BAABLAAFFH8tAAMCAAgI5ySOAACoAgACAAgI5ySOAACoAgADAAMIEgjGNQB8AAAAAA==.',['埃呢']='埃呢撒阿多切:BAABLAAFFH8JAAIbAAIICSSTHADIAAAbAAIICSSTHADIAAAAAA==.',['堕落']='堕落锝戰榊:BAAALAADCgUIBQAAAA==.',['塑心']='塑心:BAABLAAFFH8IAAIHAAYIRxSlLgBiAQAHAAYIRxSlLgBiAQAAAA==.',['墨尔']='墨尔本菠萝:BAAALAAECgYIBgAAAA==.',['壹伍']='壹伍柒柒:BAAALAAECgYIBgAAAA==.',['夏日']='夏日冰爽:BAACLAAFFH8cAAMSAAYIzheADQCPAQASAAYIzheADQCPAQAEAAMI8Rq2JgDoAAAsAAQKfzYAAwQACAgFIaEGAOMCAAQACAgFIaEGAOMCABIABwgsIpsKAFQCAAAA.',['夕阳']='夕阳下看海:BAACLAAFFH8JAAIUAAIIqSHYJgC8AAAUAAIIqSHYJgC8AAAsAAQKfxcAAhQACAgAInIdAP0CABQACAgAInIdAP0CAAAA.',['大卫']='大卫丶:BAAALAAECgIIAgAAAA==.',['大坑']='大坑:BAAALAAECgYIBgAAAA==.',['大志']='大志雷马:BAABLAAECn8UAAMYAAYIBxAzKwBKAQAYAAYIBxAzKwBKAQAcAAMI6xbiJQDKAAAAAA==.',['天宇']='天宇法:BAAALAAFFAIIAwAAAA==.天宇牧:BAAALAAECgQIBAAAAA==.天宇的瓦莉拉:BAAALAADCgYIBgAAAA==.天宇龙:BAAALAAFFAIIBAAAAA==.',['天幕']='天幕红尘:BAAALAAECgYIDAAAAA==.',['天贞']='天贞:BAAALAAECgMIAwAAAA==.',['夶丶']='夶丶洣:BAAALAAECgcIBwAAAA==.',['夺面']='夺面双雄:BAAALAAECgYICQAAAA==.',['女鬼']='女鬼王:BAAALAAECgYICQAAAA==.',['奶似']='奶似奶非奶:BAAALAAECgUIBQAAAA==.',['姐是']='姐是老中医:BAAALAAFFAIIBAAAAA==.',['姝总']='姝总:BAAALAAECgYICwAAAA==.',['孤芳']='孤芳:BAAALAAECgYICwAAAA==.',['宁采']='宁采臣:BAAALAAECgYIBgAAAA==.',['守备']='守备官:BAAALAADCgMIAwAAAA==.',['宋集']='宋集薪:BAABLAAFFH8NAAIQAAYIyxiGNwAaAQAQAAYIyxiGNwAaAQAAAA==.',['宝宝']='宝宝桃太郎:BAAALAAECgYIBgAAAA==.',['宫廷']='宫廷御用采菊:BAAALAAECgIIAgAAAA==.',['封丨']='封丨翼:BAAALAADCggICAAAAA==.',['小兵']='小兵一零四:BAABLAAFFH8IAAIFAAII5xxhVACTAAAFAAII5xxhVACTAAAAAA==.',['小小']='小小爱豆豆:BAAALAAECgYIBgAAAA==.',['小德']='小德真好玩:BAAALAADCggICAAAAA==.',['小满']='小满战:BAAALAAECgYIEAAAAA==.',['小腿']='小腿毛:BAAALAAECgYIBgAAAA==.',['小花']='小花生丶:BAABLAAFFH8JAAIVAAYIdRYjGwCPAQAVAAYIdRYjGwCPAQAAAA==.',['小蜻']='小蜻蜓丶:BAAALAADCgIIAgAAAA==.',['小风']='小风雪:BAABLAAECn8mAAMaAAcI6xIwFQBaAQAaAAcI6xIwFQBaAQAZAAYINgrRGADLAAABLAAECggITAAFAF4kAA==.',['小鲫']='小鲫鱼丶:BAAALAAFFAIIAgAAAA==.',['尐龟']='尐龟龟:BAABLAAFFH8GAAIFAAIIgBa6cAB+AAAFAAIIgBa6cAB+AAAAAA==.',['少喝']='少喝点:BAAALAAECgEIAQAAAA==.',['尒丶']='尒丶朲:BAAALAAECggIDAAAAA==.',['尛柚']='尛柚归来:BAAALAADCgEIAQAAAA==.',['尛笙']='尛笙归来:BAAALAADCgQIBQAAAA==.',['尛米']='尛米归来:BAAALAADCgUIBwAAAA==.',['尛鑫']='尛鑫归来:BAABLAAFFH8EAAIHAAQI8wmXWgBQAAAHAAQI8wmXWgBQAAAAAA==.',['尛饭']='尛饭归来:BAAALAADCgMIBgAAAA==.',['就是']='就是个干:BAABLAAFFH8MAAITAAIIJwWrIgAqAAATAAIIJwWrIgAqAAAAAA==.就是哐哐抽:BAABLAAFFH8GAAIBAAYITBfrKQCTAQABAAYITBfrKQCTAQAAAA==.就是嗤嗤刨:BAAALAAFFAYIBAAAAA==.就是气死你:BAAALAAECgYIDwAAAA==.就是铛铛敲:BAABLAAFFH8MAAIBAAYI+R17HwC6AQABAAYI+R17HwC6AQAAAA==.',['屁珐']='屁珐师龚智伟:BAABLAAECn8dAAMGAAcINRiNFACMAQAGAAYIVhuNFACMAQAQAAcIqhEHMwBGAQABLAAECggITAAFAF4kAA==.',['岛田']='岛田玛薇:BAAALAAFFAIIAwABLAAFFAYIJQAbAPQaAA==.岛田邦桑迪:BAABLAAFFH8QAAMJAAIIkgcBFQBCAAAJAAIIkgcBFQBCAAAHAAIIcwEkcwAlAAABLAAFFAYIJQAbAPQaAA==.',['左手']='左手执魂:BAAALAAFFAIIBAAAAA==.',['左腿']='左腿的右边:BAABLAAFFH8cAAIXAAUIPxwxCwBeAQAXAAUIPxwxCwBeAQAAAA==.',['巫毒']='巫毒箭舞:BAAALAAECgcIBwAAAA==.',['巫蛊']='巫蛊丨清墩墩:BAAALAAECgIIAgAAAA==.',['希咓']='希咓娜:BAAALAAECgYIBgAAAA==.',['希尔']='希尔之手:BAABLAAECn9AAAMBAAgI8CHTCwCXAgABAAgI8CHTCwCXAgAXAAII2Ab7MgAtAAABLAAECggITAAFAF4kAA==.',['帕拉']='帕拉丁:BAACLAAFFH8FAAIUAAUIbBLLOgCzAAAUAAUIbBLLOgCzAAAsAAQKfxcAAhQABwiHISQkAAgCABQABwiHISQkAAgCAAAA.',['幕夜']='幕夜杀手:BAABLAAFFH8KAAIKAAIIcRsKNwCgAAAKAAIIcRsKNwCgAAAAAA==.',['年轻']='年轻的信义:BAAALAAECgIIAgAAAA==.',['年迈']='年迈的韦德:BAABLAAFFH8GAAIUAAMIiRZ/GwDrAAAUAAMIiRZ/GwDrAAAAAA==.',['幽幽']='幽幽小帕布:BAAALAADCgUIBwAAAA==.',['广智']='广智:BAAALAADCgIIAgAAAA==.',['弗兰']='弗兰克加拉格:BAAALAAECgUIBQAAAA==.',['张起']='张起灵:BAABLAAFFH8GAAIQAAYIpAuDLQBaAQAQAAYIpAuDLQBaAQAAAA==.',['張童']='張童鞋:BAABLAAFFH8oAAMXAAYIbxIeCwBgAQAXAAYIbxIeCwBgAQABAAMIKgQOawBtAAAAAA==.',['弹跳']='弹跳甲鱼汤:BAABLAAFFH8mAAMHAAYIQB5FGgC/AQAHAAYI5RxFGgC/AQAJAAIIXhQkGwCLAAAAAA==.',['彭城']='彭城三妹:BAAALAAECgYIBgAAAA==.',['得赖']='得赖妮女劣人:BAAALAAFFAIIBAAAAA==.',['微笑']='微笑时很美:BAAALAADCgUIBQAAAA==.',['德里']='德里亚诺:BAAALAADCgIIAgAAAA==.',['恋人']='恋人炉丶:BAAALAAECggIEAAAAA==.',['恶魔']='恶魔候选人:BAAALAADCgYIBgAAAA==.恶魔月饼:BAAALAAECggICAAAAA==.',['情深']='情深却不寿丶:BAAALAAECggIDgAAAA==.',['情迷']='情迷圣光之望:BAAALAAECgYIBgAAAA==.情迷艾玛:BAAALAAECgEIAQAAAA==.',['慕容']='慕容玉洹:BAAALAAECgYIBgAAAA==.',['我不']='我不是德神:BAAALAADCggIDgAAAA==.',['我才']='我才没有哭呢:BAAALAADCgYIBgAAAA==.',['我爱']='我爱馄饨:BAAALAADCgIIAgAAAA==.',['我要']='我要吃灌注:BAAALAADCgEIAQAAAA==.',['战隼']='战隼筋肉人:BAACLAAFFH8rAAIdAAcIIB2xCQCqAQAdAAcIIB2xCQCqAQAsAAQKfzYAAh0ACAhwIvsJAAQDAB0ACAhwIvsJAAQDAAAA.战隼饭団:BAAALAAFFAIIAgABLAAFFAgIEAABANAcAA==.',['折磨']='折磨:BAABLAAFFH8LAAMJAAIIgyB1CADCAAAJAAIIgyB1CADCAAAHAAEIexORXABDAAAAAA==.',['抠脚']='抠脚大汉:BAAALAAECgYICgAAAA==.',['挽手']='挽手说梦话丶:BAAALAAECggIDwAAAA==.',['摸坐']='摸坐骑一号:BAAALAAECgUIBQAAAA==.',['擼破']='擼破兲:BAACLAAFFH8MAAIXAAIIEQl9EwBwAAAXAAIIEQl9EwBwAAAsAAQKfxgAAwEACAgtDe5xAAwBAAEABAjMFO5xAAwBABcACAhcB60vAAABAAAA.',['斐欧']='斐欧娜:BAAALAAECgQIBAAAAA==.',['斯卡']='斯卡蒂:BAABLAAFFH8GAAIBAAIIcR12OgC9AAABAAIIcR12OgC9AAAAAA==.',['无巧']='无巧不成书:BAABLAAFFH8GAAIEAAYIbxR+FgCEAQAEAAYIbxR+FgCEAQAAAA==.',['无情']='无情樱花:BAAALAAECggICAAAAA==.无情的泡面:BAAALAADCgMIAwAAAA==.',['无敌']='无敌大背剑:BAAALAAECgIIAgAAAA==.',['无星']='无星夜空:BAAALAAECgMIAwAAAA==.',['日倒']='日倒扶桑:BAAALAAECgQIBAAAAA==.',['早寒']='早寒:BAAALAAECgYIDAAAAA==.',['旭光']='旭光:BAABLAAFFH8VAAIIAAYIGBksEADhAQAIAAYIGBksEADhAQAAAA==.',['旺仔']='旺仔牛:BAAALAAECgIIAgAAAA==.',['旺德']='旺德发:BAAALAADCggICAAAAA==.',['昊天']='昊天跎跎:BAABLAAFFH8LAAIeAAYI7RnvBgC0AQAeAAYI7RnvBgC0AQAAAA==.',['易水']='易水潇潇寒:BAAALAAECgMIAwAAAA==.',['星冰']='星冰乐:BAAALAAECgIIAgAAAA==.',['星缘']='星缘恶少:BAAALAAFFAIIBAAAAA==.星缘梦魇:BAABLAAFFH8JAAMFAAIISRfUQgCiAAAFAAIISRfUQgCiAAALAAEI6QUgOQAzAAAAAA==.',['晓德']='晓德德:BAAALAAECgYIDAAAAA==.',['晓风']='晓风:BAAALAAFFAIIAgAAAA==.',['普通']='普通的冰蒂凯:BAAALAAFFAIIAwAAAA==.',['暗影']='暗影控魔:BAAALAAECgYIEAAAAA==.',['暗杠']='暗杠杠上花:BAAALAAECgUIBQAAAA==.',['暗若']='暗若:BAAALAAECgIIAgAAAA==.',['暗角']='暗角:BAAALAAECgYIBgAAAA==.',['暮光']='暮光闪闪:BAAALAAFFAIIAwABLAAFFAYIHgAEAGkfAA==.',['暴躁']='暴躁的诸葛亮:BAABLAAFFH8YAAIFAAYIKRZwNABuAQAFAAYIKRZwNABuAQAAAA==.',['曾恋']='曾恋水墨青花:BAABLAAFFH8eAAIQAAYILx3ZHwCaAQAQAAYILx3ZHwCaAQAAAA==.',['月夜']='月夜寒风:BAAALAAECgIIAgAAAA==.月夜神战:BAAALAADCggICAAAAA==.',['月影']='月影追風:BAAALAAECgYIDgAAAA==.月影追风:BAABLAAFFH8FAAIbAAUIrQYKGQAAAQAbAAUIrQYKGQAAAQAAAA==.',['月牙']='月牙叉炮:BAACLAAFFH8bAAMBAAYIQCUzHABAAQABAAUI8SQzHABAAQAPAAIIpiV5CADiAAAsAAQKfy0AAwEACAiPJsECAIADAAEACAh0JsECAIADAA8ABAjXJisgALkBAAAA.',['月色']='月色归来:BAAALAAECgYIDQAAAA==.',['有无']='有无敌我怕啥:BAAALAAFFAIIAgAAAA==.',['术梦']='术梦醒今生:BAABLAAFFH8LAAIHAAUI0QvWPQANAQAHAAUI0QvWPQANAQAAAA==.',['李会']='李会计:BAAALAAFFAQIBAAAAA==.',['李宝']='李宝瓶:BAABLAAFFH8YAAIQAAYIsRtlHgCiAQAQAAYIsRtlHgCiAQAAAA==.',['李思']='李思思:BAABLAAFFH8IAAITAAgIigeACgCiAQATAAgIigeACgCiAQABLAAFFAgIEgATAKEcAA==.',['李斯']='李斯顿飞刀:BAABLAAECn8vAAMIAAgIoSRPAwAqAwAIAAgIoSRPAwAqAwAfAAUIuRriFwCRAQABLAAECggITAAFAF4kAA==.',['村口']='村口阿龙:BAABLAAFFH8dAAIFAAYIHxanKwCKAQAFAAYIHxanKwCKAQAAAA==.',['杜蕾']='杜蕾卡:BAABLAAFFH8KAAIUAAQIxQ3vNwDJAAAUAAQIxQ3vNwDJAAAAAA==.',['来自']='来自海克泰尔:BAABLAAFFH8dAAIfAAUIdR7PEABeAQAfAAUIdR7PEABeAQAAAA==.',['极恶']='极恶小栗帽:BAAALAAECgYIBgAAAA==.',['极饿']='极饿小栗帽:BAABLAAFFH8IAAIBAAIIpQ7FcACQAAABAAIIpQ7FcACQAAAAAA==.',['柒号']='柒号肉老板:BAABLAAFFH8HAAMLAAIIXgavMABdAAAFAAIIXgYadgB4AAALAAIIagOvMABdAAAAAA==.',['柒爪']='柒爪魚:BAAALAAECggIBgAAAA==.',['柠檬']='柠檬很酸:BAAALAAECgEIAQAAAA==.',['柳眠']='柳眠棠丶:BAAALAAECgEIAQAAAA==.',['桐城']='桐城丶小花:BAACLAAFFH8dAAIeAAYIpBafCACUAQAeAAYIpBafCACUAQAsAAQKfx0AAh4ACAiHGmUVAG4CAB4ACAiHGmUVAG4CAAAA.桐城小花丶:BAAALAAFFAIIBAAAAA==.',['梦魇']='梦魇死骑:BAAALAAECgIIAgAAAA==.梦魇莅临:BAAALAAECgYIBgAAAA==.',['森之']='森之灵羿:BAAALAAECgQIBAAAAA==.',['森宝']='森宝:BAAALAAECgUIBgAAAA==.',['楠丁']='楠丁格尔:BAACLAAFFH82AAMUAAcIMxk4GACWAQAUAAcIMxk4GACWAQAbAAYIohJyEACFAQAsAAQKfzsAAxQACAilI90VAB8DABQACAilI90VAB8DABsAAghyARF+ACsAAAAA.',['榜一']='榜一大哥:BAAALAAECgQIBAAAAA==.',['樱木']='樱木花:BAACLAAFFH8NAAMIAAUIBxjmCgCiAQAIAAUIBxjmCgCiAQAfAAQIPgi/HwCNAAAsAAQKfxQAAh8ACAg2HYEIAF4CAB8ACAg2HYEIAF4CAAAA.',['樱桃']='樱桃大丸子:BAAALAAECgYICAAAAA==.樱桃小丸子:BAACLAAFFH8LAAQEAAMIMwpZOwBkAAAEAAMIMwpZOwBkAAAgAAIIdApwCgBgAAASAAEIZSAeKwBVAAAsAAQKfxQABBIABgiwHqwyAPMBABIABgiwHqwyAPMBACAABgg8ENETAAIBAAQAAQipGKPmADEAAAAA.',['橘子']='橘子气泡酒:BAAALAAECggIBAAAAA==.',['武汉']='武汉彭于晏丶:BAABLAAFFH8HAAIFAAQIqiHEFAB6AQAFAAQIqiHEFAB6AQAAAA==.',['歩行']='歩行上天镗:BAAALAADCgEIAQAAAA==.',['死心']='死心塌地:BAAALAAECgMIAwAAAA==.',['殇月']='殇月小寒:BAAALAAECgYIBgAAAA==.',['残梦']='残梦丨清墩墩:BAAALAAECgYICgAAAA==.',['水中']='水中飞舞:BAACLAAFFH8FAAIUAAIIkhYFUgBUAAAUAAIIkhYFUgBUAAAsAAQKfyIAAhQABwiEH4QkAAYCABQABwiEH4QkAAYCAAAA.',['永恒']='永恒夕阳:BAABLAAFFH8YAAIdAAUI6AvxGQDRAAAdAAUI6AvxGQDRAAAAAA==.',['汤姆']='汤姆逊呀:BAAALAAFFAIIAgABLAAFFAYICwAgANwDAA==.',['沁无']='沁无軋念:BAAALAAECgEIAQAAAA==.',['沃尔']='沃尔皮:BAAALAAECgQIBAAAAA==.',['沉默']='沉默:BAABLAAECn8aAAIcAAgIbRP4JQDSAQAcAAgIbRP4JQDSAQAAAA==.',['泡泡']='泡泡骑屮:BAABLAAFFH8NAAIfAAQIqRnCGQDmAAAfAAQIqRnCGQDmAAAAAA==.',['洛丹']='洛丹伦勇士:BAACLAAFFH8KAAMJAAQIrQPqCwBiAAAHAAMIFANXTQCHAAAJAAMIAwTqCwBiAAAsAAQKfxoAAwkACAiYChw0AJ0BAAkACAiYChw0AJ0BAAcAAQj8A42kABkAAAAA.洛丹伦的王子:BAABLAAFFH8oAAIUAAgIkRuKBQAuAgAUAAgIkRuKBQAuAgAAAA==.',['洛尽']='洛尽缘亦浅:BAAALAAECgYIDgAAAA==.',['流浪']='流浪妖:BAACLAAFFH8IAAIFAAIIlQZfuQAyAAAFAAIIlQZfuQAyAAAsAAQKfxYAAgUABgiGFIGNADUBAAUABgiGFIGNADUBAAAA.流浪风之间:BAABLAAFFH8GAAIHAAYIgRB6EADiAQAHAAYIgRB6EADiAQAAAA==.',['浅陌']='浅陌初心:BAAALAADCgYIBgAAAA==.',['海徳']='海徳拉灬影翼:BAAALAAECggICAAAAA==.',['海战']='海战:BAAALAAECgYIBgAAAA==.海战之星:BAABLAAFFH8GAAIUAAII1xXQNgClAAAUAAII1xXQNgClAAAAAA==.海战之盾:BAACLAAFFH8TAAIVAAMIYSIQJgCtAAAVAAMIYSIQJgCtAAAsAAQKfxoAAhUACAirJIoPACkDABUACAirJIoPACkDAAAA.',['海纳']='海纳百川:BAAALAAECgMIAwAAAA==.',['湮滅']='湮滅淵:BAACLAAFFH8LAAIVAAIIOCX3IQC8AAAVAAIIOCX3IQC8AAAsAAQKfyQAAhUABwgtJb0NAIQCABUABwgtJb0NAIQCAAAA.',['漃寞']='漃寞蒅指灬迗:BAAALAAECgEIAQAAAA==.',['漠璐']='漠璐:BAAALAAECgUIBQAAAA==.',['漠路']='漠路:BAAALAAECgYIDAAAAA==.',['漫游']='漫游星空:BAAALAAECgYIBgAAAA==.',['潜水']='潜水差点淹:BAABLAAECn8VAAIWAAYIaw+2GADcAAAWAAYIaw+2GADcAAAAAA==.',['火工']='火工头陀:BAAALAAECgYIDAABLAAECggITAAFAF4kAA==.',['火鸡']='火鸡味大锅巴:BAAALAAECgYIBQAAAA==.',['灬以']='灬以箭之名灬:BAAALAAECgYICQAAAA==.',['灬浅']='灬浅写丶爱:BAAALAAECgIIAgAAAA==.',['灬須']='灬須彌的等待:BAACLAAFFH8IAAIQAAYIZQieSACCAAAQAAYIZQieSACCAAAsAAQKfxcAAwYABwiOIlYaAEcCAAYABwhMHlYaAEcCABAABAg+GACrAC4BAAAA.',['烟花']='烟花一半醒:BAAALAAECgYIBgAAAA==.',['焰凤']='焰凤凰:BAAALAAECgYIDAAAAA==.',['熊熊']='熊熊壹号:BAAALAAECgYIBgAAAA==.熊熊贰号:BAAALAAECgYIBwAAAA==.',['爆炸']='爆炸头:BAABLAAFFH8GAAIPAAIIIRswDwCeAAAPAAIIIRswDwCeAAABLAAFFAcIIAAhABMgAA==.',['爱吃']='爱吃草莓:BAAALAAECgEIAQAAAA==.',['牛三']='牛三胖:BAABLAAECn8UAAMDAAgI9AswcgBnAQADAAYIFQ8wcgBnAQACAAgIuQtJpQA0AQAAAA==.',['牛啤']='牛啤轰轰:BAAALAAECgQIAwAAAA==.',['牛爷']='牛爷:BAAALAAECgIIAgAAAA==.',['牛犇']='牛犇犇:BAACLAAFFH8IAAMUAAIIHwuBWwCEAAAUAAII9wWBWwCEAAAiAAIIHwuPIAArAAAsAAQKfx8AAxQABwiDERNYAFsBABQABQgKFhNYAFsBACIABwjNBzEvAKsAAAAA.',['牧神']='牧神影:BAAALAADCgIIAgAAAA==.',['狂人']='狂人:BAAALAAECgYICgAAAA==.',['狂刀']='狂刀手:BAAALAADCgEIAQAAAA==.',['独倚']='独倚望江楼:BAAALAAECgYIDAAAAA==.',['猛练']='猛练丶自然强:BAAALAAFFAIIBAAAAA==.',['王冰']='王冰冰:BAABLAAFFH8SAAITAAYIoRwAAwAhAgATAAYIoRwAAwAhAgAAAA==.',['王小']='王小明丶:BAABLAAECn8hAAIKAAgIdCG+FwAJAwAKAAgIdCG+FwAJAwAAAA==.',['玛卡']='玛卡巴卡丶:BAAALAAECgQIBAAAAA==.',['玛瑙']='玛瑙:BAABLAAECn8pAAMEAAgIhxA3VACZAQAEAAgIhxA3VACZAQAgAAYIrwHuMABwAAAAAA==.',['玻璃']='玻璃渣渣贰:BAAALAADCgYIBgAAAA==.',['琳达']='琳达斯麦尔:BAAALAADCgIIAgAAAA==.',['瑰魅']='瑰魅:BAAALAAECgEIAQAAAA==.',['瓶子']='瓶子妖:BAACLAAFFH8MAAIIAAIIKAnIPAB8AAAIAAIIKAnIPAB8AAAsAAQKfxgAAggABgjlCsFDANIAAAgABgjlCsFDANIAAAAA.',['甜妹']='甜妹:BAAALAAFFAIIAgAAAA==.',['甜香']='甜香最妇少:BAAALAADCgIIAgAAAA==.',['申艺']='申艺艺:BAAALAADCgQIBAAAAA==.',['番茄']='番茄小萱:BAAALAAECgYIBgAAAA==.',['白丽']='白丽霊梦:BAAALAAECgYIDAAAAA==.',['皂皂']='皂皂丶:BAAALAAFFAIIBAAAAA==.',['皓月']='皓月龙心:BAAALAADCggICQAAAA==.',['皮皮']='皮皮萨:BAAALAAFFAIIAgAAAA==.',['盗玥']='盗玥:BAAALAAECgYICgAAAA==.',['真心']='真心是丑:BAAALAADCgUICQAAAA==.',['真志']='真志雷马:BAAALAAFFAIIBAAAAA==.',['睨风']='睨风:BAABLAAFFH8TAAIUAAYICQxINwDPAAAUAAYICQxINwDPAAAAAA==.',['矮子']='矮子:BAAALAAECgEIAQAAAA==.',['石中']='石中玉:BAACLAAFFH8HAAICAAIIsiCINACYAAACAAIIsiCINACYAAAsAAQKfxwAAgIABgiWHk5NAPkBAAIABgiWHk5NAPkBAAAA.',['石榴']='石榴汁:BAAALAAECgUIBQAAAA==.',['砂锅']='砂锅炖鱼:BAABLAAFFH8QAAIiAAUIdxadCgADAQAiAAUIdxadCgADAQAAAA==.',['砍头']='砍头爸爸:BAAALAAFFAIIBAAAAA==.',['砍爆']='砍爆哩的头:BAAALAAFFAIIBAAAAA==.',['破落']='破落户顶凉柱:BAAALAAECgYICQAAAA==.',['硫萤']='硫萤丶:BAAALAAECgYIBgAAAA==.',['碧海']='碧海逍遥:BAAALAADCgMIAwAAAA==.',['祖国']='祖国毕统一:BAAALAADCgYIBgAAAA==.',['神棍']='神棍龟:BAABLAAFFH8HAAIfAAIIDRi+KABGAAAfAAIIDRi+KABGAAAAAA==.',['移形']='移形换影:BAAALAAECgQIBAAAAA==.',['筱凝']='筱凝:BAAALAAECgYIBgAAAA==.',['简单']='简单:BAAALAAFFAIIAgAAAA==.',['米兰']='米兰菠萝:BAAALAAECgYICgAAAA==.',['米大']='米大爷:BAAALAAFFAYIBAAAAA==.',['米托']='米托夫法鸡:BAAALAAFFAIIBAAAAA==.',['米粒']='米粒儿:BAAALAADCggICwAAAA==.',['米苏']='米苏:BAAALAAFFAIIAgAAAA==.',['米菲']='米菲児:BAAALAAECgQIBAAAAA==.',['糖门']='糖门小鬼:BAAALAAECgYIBgAAAA==.',['紫仙']='紫仙:BAACLAAFFH8IAAIIAAIItQ7gPgBtAAAIAAIItQ7gPgBtAAAsAAQKfxwAAwgABgjEGc8gALMBAAgABgjEGc8gALMBACMABgiQBOgoAKQAAAAA.',['紫飘']='紫飘:BAABLAAFFH8OAAIFAAIItCCXPACrAAAFAAIItCCXPACrAAAAAA==.',['红袖']='红袖满楼招:BAABLAAECn8nAAILAAgIMhcvCQDNAQALAAgIMhcvCQDNAQAAAA==.',['纭晴']='纭晴晴:BAABLAAFFH8GAAIHAAYIuRmRHgCmAQAHAAYIuRmRHgCmAQAAAA==.',['纯净']='纯净:BAAALAAECgMIAwAAAA==.',['纯境']='纯境:BAAALAADCgQIBAAAAA==.',['纯粹']='纯粹为幻化:BAAALAADCgIIAgAAAA==.',['给你']='给你插地里:BAAALAADCggICgAAAA==.',['绚丽']='绚丽寒冰:BAAALAAECggICAAAAA==.',['维贝']='维贝:BAAALAAECgcICAAAAA==.',['罒丶']='罒丶墓中无人:BAAALAAECgEIAQAAAA==.',['罗兰']='罗兰大师:BAAALAAECgYIBgAAAA==.',['翅膀']='翅膀:BAAALAAECgMIAwAAAA==.',['老抽']='老抽:BAABLAAFFH8GAAIFAAIIOBVTnABAAAAFAAIIOBVTnABAAAAAAA==.',['肆乄']='肆乄虐:BAAALAADCgMIAwAAAA==.',['胖阿']='胖阿凤:BAAALAAECgQIBAAAAA==.',['自爆']='自爆自行车:BAABLAAFFH8KAAIdAAII/wleOQAmAAAdAAII/wleOQAmAAABLAAFFAYIJQAbAPQaAA==.',['舸梓']='舸梓:BAAALAAECgYIBgAAAA==.',['艾尔']='艾尔:BAAALAADCgMIAwAAAA==.艾尔莎:BAAALAAECgYIEQAAAA==.',['艾露']='艾露莎:BAAALAAECgYIDAAAAA==.',['芙兰']='芙兰迪伦:BAAALAAECgYIBgAAAA==.',['茉莉']='茉莉美美:BAABLAAECn8WAAIcAAYIAxSvNQBuAQAcAAYIAxSvNQBuAQAAAA==.',['茶有']='茶有点淡了:BAAALAAECgUIBQAAAA==.',['莉娜']='莉娜因巴斯:BAAALAAECgMIAwAAAA==.',['莉莉']='莉莉斯:BAAALAAECgIIAgAAAA==.',['萌丶']='萌丶泡泡:BAABLAAFFH8HAAMBAAYIsRA7NQBrAQABAAYIsRA7NQBrAQAXAAEI8wPvGQA7AAAAAA==.',['萌泰']='萌泰妍:BAAALAADCgYIFAAAAA==.',['萌龟']='萌龟龟:BAACLAAFFH8GAAMBAAIIVhUFbwCRAAABAAIIoRIFbwCRAAAXAAIIzBMuHAAyAAAsAAQKfx4AAhcABwhRHvAQAEMCABcABwhRHvAQAEMCAAAA.',['萝莉']='萝莉有三宝:BAABLAAFFH8KAAIBAAIIshZdawCTAAABAAIIshZdawCTAAAAAA==.',['萨磨']='萨磨拉诅:BAAALAAECgYICAAAAA==.',['葡萄']='葡萄牙菠萝:BAAALAAECgIIAgAAAA==.',['葱爆']='葱爆蛋:BAAALAAFFAIIAgAAAA==.',['蓄意']='蓄意愤怒丶:BAAALAAFFAIIBAAAAA==.',['蓝翔']='蓝翔老司机:BAABLAAFFH8HAAIGAAIItwVhGgBsAAAGAAIItwVhGgBsAAAAAA==.',['蓝芷']='蓝芷鸢:BAABLAAFFH8IAAIWAAII+Ar0FgAoAAAWAAII+Ar0FgAoAAAAAA==.',['蕾切']='蕾切尔晨光:BAABLAAFFH8eAAIEAAYIaR+HCAAoAgAEAAYIaR+HCAAoAgAAAA==.',['薇琪']='薇琪:BAAALAAECggIEgAAAA==.',['虚空']='虚空射卫:BAAALAAECgYIBgAAAA==.虚空追猎者:BAAALAAFFAIIAwAAAA==.虚空骑士:BAAALAAFFAIIAgAAAA==.',['虹霓']='虹霓儿:BAAALAAECggIDQAAAA==.',['虾仁']='虾仁水饺:BAABLAAFFH8HAAMFAAMIahHLeABwAAAFAAMIPA7LeABwAAALAAEIzRRENABDAAAAAA==.',['蜜鳕']='蜜鳕:BAAALAAECggIDwAAAA==.',['蜻蜓']='蜻蜓队长:BAAALAAECgEIAQAAAA==.',['蝶恋']='蝶恋蜂狂:BAAALAAECgIIAgAAAA==.',['西冷']='西冷红茶:BAAALAAFFAIIBAAAAA==.',['要饭']='要饭么有碗:BAAALAAECggICgAAAA==.',['言欢']='言欢:BAAALAAFFAIIAgAAAA==.',['調泄']='調泄了:BAABLAAECn8YAAMFAAYIVCVKMgCRAgAFAAYIVCVKMgCRAgALAAYIVBJ+YwAzAQAAAA==.',['調爆']='調爆了:BAAALAAECgYIBgAAAA==.',['诗和']='诗和远方的你:BAAALAAFFAQIBAAAAA==.',['请出']='请出示通行证:BAAALAAECgMIAwAAAA==.',['诺萨']='诺萨琳丶星殒:BAAALAAECggICAAAAA==.',['豁酨']='豁酨偒霞:BAABLAAFFH8IAAIVAAQIpBDPLwDcAAAVAAQIpBDPLwDcAAAAAA==.',['贰泉']='贰泉印月:BAAALAADCgMIAwAAAA==.',['赵丽']='赵丽颖:BAAALAAFFAIIBAAAAA==.',['超凡']='超凡骑士:BAAALAAECgEIAQAAAA==.',['超级']='超级宾周仔:BAABLAAFFH8IAAIFAAYICRdqCwDeAQAFAAYICRdqCwDeAQAAAA==.',['蹦跶']='蹦跶嘚橙仔:BAAALAADCgIIAgAAAA==.',['身材']='身材很重要:BAAALAAECgMIBAAAAA==.',['辣手']='辣手摧残:BAAALAAECgMIAwAAAA==.',['辣西']='辣西美黛子:BAAALAAECgIIAgAAAA==.',['运气']='运气很重要:BAAALAAECgIIAgAAAA==.',['还有']='还有谁:BAAALAADCgMIAwAAAA==.',['迷迷']='迷迷茫茫:BAAALAAECgIIAgAAAA==.',['逆流']='逆流一圣骑:BAABLAAFFH8GAAIiAAII4gYDIgAoAAAiAAII4gYDIgAoAAAAAA==.逆流一德:BAAALAAFFAIIBAAAAA==.逆流一死骑:BAABLAAFFH8OAAMBAAIIORORfQBHAAAPAAIIGw1qEgBMAAABAAIIORORfQBHAAAAAA==.逆流一牧:BAABLAAFFH8KAAQjAAIIQxa9AgCTAAAjAAIIQxa9AgCTAAAIAAIIhgIRTABOAAAfAAIIvgeuLgA5AAAAAA==.逆流一萨:BAAALAAFFAIIAwAAAA==.',['遙遠']='遙遠的回憶:BAABLAAECn8UAAIFAAYI8xYTjwAzAQAFAAYI8xYTjwAzAQAAAA==.',['避税']='避税太多:BAAALAADCgMIAwAAAA==.',['那个']='那个发斯:BAABLAAFFH8lAAICAAYI9SGrCgAlAgACAAYI9SGrCgAlAgAAAA==.',['那年']='那年丶冬季:BAAALAAECgMIAwAAAA==.',['邪帝']='邪帝跎跎:BAABLAAFFH8SAAIBAAYIDCCzGQDVAQABAAYIDCCzGQDVAQAAAA==.',['邪血']='邪血冰:BAAALAAECgEIAQAAAA==.',['量大']='量大管饱:BAAALAAECgYIBgAAAA==.',['鈤落']='鈤落之后:BAABLAAECn86AAIMAAgIwyOuAACqAgAMAAgIwyOuAACqAgAAAA==.',['錵錵']='錵錵嘚蓓哔:BAABLAAFFH8IAAIhAAIIrg0LBwCVAAAhAAIIrg0LBwCVAAAAAA==.',['钀人']='钀人:BAAALAAECgIIAgAAAA==.',['铁甲']='铁甲依然在:BAAALAADCgEIAQAAAA==.',['锤哥']='锤哥:BAAALAADCgEIAQAAAA==.',['长高']='长高不是事儿:BAABLAAFFH8GAAIJAAIIGw3DFABDAAAJAAIIGw3DFABDAAAAAA==.',['队长']='队长我中枪了:BAABLAAFFH8IAAIEAAII0CAuIgCdAAAEAAII0CAuIgCdAAAAAA==.',['阮秀']='阮秀:BAABLAAFFH8LAAIQAAYIaw68LQBZAQAQAAYIaw68LQBZAQABLAAFFAcIDwAQAPIXAA==.',['阳阳']='阳阳的老爸:BAAALAADCgEIAQAAAA==.',['阿克']='阿克西瓦:BAABLAAECn8yAAMVAAgIzhyzEQBbAgAVAAgIzhyzEQBbAgAdAAQI5w6wNQDCAAABLAAECggITAAFAF4kAA==.',['阿斯']='阿斯旺的猪:BAAALAADCgIIAgAAAA==.阿斯普洛斯:BAAALAAECgYIBgAAAA==.',['陆沉']='陆沉:BAABLAAFFH8NAAIQAAYIlxpvGwCwAQAQAAYIlxpvGwCwAQABLAAFFAcIDwAQAPIXAA==.',['陈都']='陈都灵:BAAALAADCgYIBgAAAA==.',['随地']='随地大小变:BAABLAAFFH8cAAMSAAYIfRwXFQA8AQASAAUIKB0XFQA8AQAEAAQICxpLKQDRAAAAAA==.',['雨落']='雨落傾城:BAACLAAFFH8GAAIgAAIIBQpXDwAoAAAgAAIIBQpXDwAoAAAsAAQKfxwAAyAABwiPDagUAPcAACAABwiPDagUAPcAABIABAivB0NKAJIAAAAA.',['雨鱼']='雨鱼之战:BAAALAAECgYIBgAAAA==.雨鱼之猎:BAACLAAFFH8SAAIFAAYI4RsGIQCyAQAFAAYI4RsGIQCyAQAsAAQKfzoAAgUACAinJd0LAD0DAAUACAinJd0LAD0DAAAA.',['雪域']='雪域冰封:BAACLAAFFH8SAAMkAAMI3RULBQCfAAAkAAMI3RULBQCfAAAGAAEIHwIMIwAzAAAsAAQKfxcAAyQACAigIasBAA0DACQACAigIasBAA0DAAYAAghaG8lBAFQAAAEsAAUUBgglAAIA9SEA.',['雷电']='雷电斧王:BAABLAAECn8iAAIDAAgI0RykIQCbAgADAAgI0RykIQCbAgABLAAECggITAAFAF4kAA==.',['雾里']='雾里飞花:BAABLAAFFH8GAAIFAAIIbxiulABEAAAFAAIIbxiulABEAAAAAA==.',['霜精']='霜精亮救龙:BAABLAAFFH8HAAIBAAMI5R+sJAAIAQABAAMI5R+sJAAIAQAAAA==.',['霸王']='霸王天椒牛堡:BAAALAADCgIIAgAAAA==.',['霸霸']='霸霸:BAAALAADCgMIAwAAAA==.',['青涟']='青涟:BAAALAADCgYIBgAAAA==.',['静灵']='静灵艾御姐:BAAALAAECgYIBgAAAA==.',['静留']='静留:BAAALAADCgIIAgAAAA==.',['静静']='静静的沉睡丶:BAAALAAFFAIIAgAAAA==.',['颜值']='颜值很重要:BAAALAAECgMIAwAAAA==.',['颠峰']='颠峰飞贼:BAAALAAFFAIIAgAAAA==.',['風之']='風之沙:BAABLAAFFH8KAAIFAAIIARz/jQBHAAAFAAIIARz/jQBHAAAAAA==.',['风中']='风中的凌乱:BAABLAAFFH8JAAMKAAUIuQTjNgDPAAAKAAUIkQTjNgDPAAAWAAIIEwaXFwAnAAAAAA==.',['风之']='风之优雅:BAAALAAECgYICwAAAA==.风之沙:BAAALAAFFAIIBAAAAA==.',['风凌']='风凌:BAAALAAECgEIAQAAAA==.',['风暴']='风暴前锋:BAABLAAFFH8IAAICAAUIShhbHwBlAQACAAUIShhbHwBlAQAAAA==.',['风速']='风速疾驰:BAAALAAFFAEIAQAAAA==.',['骑士']='骑士道:BAAALAAFFAIIAgABLAAFFAMIAwAlAAAAAA==.',['骑扣']='骑扣詹姆斯丶:BAAALAAECgYICgAAAA==.',['高圆']='高圆圆:BAABLAAFFH8IAAITAAgIvw+lBwDZAQATAAgIvw+lBwDZAQABLAAFFAgIEgATAKEcAA==.',['鬼泣']='鬼泣大叔:BAABLAAECn8bAAMOAAYIFB2+CgABAgAOAAYILBu+CgABAgAFAAYIUhhSbwBmAQAAAA==.',['魂之']='魂之挽歌:BAAALAADCgQIBAAAAA==.',['魉煌']='魉煌鬼:BAAALAAECgYICwAAAA==.',['魔人']='魔人小布欧仔:BAAALAAECgEIAQAAAA==.',['魔幻']='魔幻之旅:BAACLAAFFH8UAAIFAAYIEh7QIgCrAQAFAAYIEh7QIgCrAQAsAAQKfz8AAgUACAijJDwHAOUCAAUACAijJDwHAOUCAAAA.',['黑巧']='黑巧闪闪:BAAALAADCgcIBwABLAAFFAYIHgAEAGkfAA==.',['黑暗']='黑暗丨陨落:BAAALAAECgcIBwAAAA==.',['黑死']='黑死神:BAAALAAFFAIIAgAAAA==.',['黑疯']='黑疯骑士团:BAAALAAFFAIIBAAAAA==.',['齐静']='齐静春:BAABLAAFFH8JAAIQAAYIDRh/PADkAAAQAAYIDRh/PADkAAABLAAFFAcIDwAQAPIXAA==.',['龙神']='龙神希维尔:BAAALAAECgYIDQAAAA==.',['龙跎']='龙跎跎:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end