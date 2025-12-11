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
 local lookup = {'Hunter-Marksmanship','Hunter-Survival','Hunter-BeastMastery','DemonHunter-Havoc','Paladin-Retribution','DemonHunter-Vengeance','Priest-Holy','DeathKnight-Frost','Druid-Guardian','Mage-Arcane','Mage-Frost','Unknown-Unknown','Warrior-Fury','Shaman-Restoration','Paladin-Protection','Shaman-Elemental','Paladin-Holy','Druid-Restoration','Mage-Fire','DeathKnight-Blood','Monk-Mistweaver','Rogue-Assassination','Rogue-Subtlety','Warlock-Destruction','Warrior-Protection','Priest-Shadow','Druid-Balance','Evoker-Preservation','Warlock-Affliction','Rogue-Outlaw','Monk-Brewmaster','DeathKnight-Unholy','Warlock-Demonology','Druid-Feral','Monk-Windwalker','Evoker-Devastation','Evoker-Augmentation',}; local provider = {region='CN',realm='能源舰',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ag='Agreesif:BAAALAAECgYIBgAAAA==.',An='Anubis:BAAALAAFFAIIAgAAAA==.',Be='Bestpriest:BAAALAAFFAIIAgAAAA==.',Bi='Biubiulikeme:BAACLAAFFH8GAAIBAAIIJyC0FQC7AAABAAIIJyC0FQC7AAAsAAQKfyEABAEABgjLJaYfAGkCAAEABgjLJaYfAGkCAAIAAQjcH+IPAF4AAAMAAQiVGMuMAUgAAAAA.',Bl='Blooddrunk:BAAALAAFFAIIAgAAAA==.',De='Deepha:BAABLAAFFH8eAAIEAAcIwRyREADcAQAEAAcIwRyREADcAQAAAA==.',Do='Dominater:BAACLAAFFH8QAAIFAAYIKxm4EwCsAQAFAAYIKxm4EwCsAQAsAAQKfxsAAgUACAjzIWMgAPACAAUACAjzIWMgAPACAAAA.',Ed='Edisonn:BAAALAADCgYIBgAAAA==.',Fi='Fiona:BAAALAADCgEIAQAAAA==.',Fo='Fortuna:BAAALAAFFAIIBAAAAA==.',Fr='Fractal:BAAALAAECgMIBgAAAA==.',Gu='Guludodo:BAABLAAECn9AAAIGAAgICCR+AwBAAwAGAAgICCR+AwBAAwABLAAFFAYIPwAHANQZAA==.',Gy='Gyrohawk:BAAALAAECgYIBgAAAA==.',Ki='Kila:BAAALAAECgYICwAAAA==.Killerdj:BAAALAAECgEIAQAAAA==.Kissxiao:BAAALAAECgEIAQAAAA==.',Kr='Kryor:BAAALAADCgEIAQAAAA==.',La='Laodie:BAAALAAECggICAAAAA==.',Le='Leloucha:BAAALAAECgYIBgAAAA==.',Lu='Lustful:BAAALAAECgUICAAAAA==.',Ma='Mageknight:BAABLAAFFH8HAAIIAAMI+AmFZQCAAAAIAAMI+AmFZQCAAAABLAAFFAgICAAIAJUYAA==.Magicugg:BAAALAAECgUIBQAAAA==.Makabaka:BAABLAAECn83AAIJAAgI/CRGAQDaAgAJAAgI/CRGAQDaAgABLAAFFAYIPwAHANQZAA==.',Na='Narro:BAABLAAECn8VAAMKAAcIsxYNgwCLAQAKAAYIyhYNgwCLAQALAAUIdRBoVAAjAQABLAAFFAIIBAAMAAAAAA==.',Ne='Nephale:BAAALAAECgEIAQAAAA==.',Ni='Nidhogg:BAAALAAECgcIEwAAAA==.Nikolaus:BAAALAAECgYIDAAAAA==.',No='Nobume:BAAALAAECgYIBgAAAA==.',Ro='Ro:BAABLAAFFH8GAAINAAYIYBHwGwCIAQANAAYIYBHwGwCIAQAAAA==.',Sa='Sannky:BAAALAAECgYIAgAAAA==.',Sh='Shakuras:BAABLAAECn8ZAAIIAAYI8x60cAAVAgAIAAYI8x60cAAVAgAAAA==.Shamanistic:BAAALAAFFAIIBAAAAA==.',Th='Thread:BAABLAAFFH8GAAIOAAIIvQowZQBVAAAOAAIIvQowZQBVAAAAAA==.',To='Tokai:BAAALAAECgUIBQAAAA==.Topsky:BAAALAADCgYIBgAAAA==.',Ve='Vessalius:BAAALAAECgYICgAAAA==.',Vi='Vivodefather:BAAALAAECgYICwAAAA==.',Wi='Wintercoming:BAAALAADCgQIBAAAAA==.',Xu='Xuxutv:BAAALAAFFAIIAgAAAA==.',Yi='Yinlonguncle:BAAALAADCgQIBAAAAA==.',['一半']='一半阳光:BAABLAAFFH8GAAIPAAYIwwMKDQC6AAAPAAYIwwMKDQC6AAAAAA==.',['一只']='一只大老鼠:BAAALAAFFAYIAgAAAA==.',['一叽']='一叽咕吖吖:BAACLAAFFH8KAAIQAAQI5QjsNwB7AAAQAAQI5QjsNwB7AAAsAAQKfxgAAhAABwjYGK06ABsCABAABwjYGK06ABsCAAAA.',['一坨']='一坨黄:BAAALAAECgIIAwAAAA==.',['一定']='一定要弄肿:BAAALAAECgMIAwAAAA==.',['一念']='一念花开:BAAALAAECgUICQAAAA==.',['一般']='一般罩得住:BAAALAADCgEIAQAAAA==.',['一语']='一语轻尘:BAAALAAECgQIBAAAAA==.',['一边']='一边梦游一边:BAAALAADCggICAAAAA==.',['一醉']='一醉浮生:BAAALAAFFAIIAgAAAA==.',['七号']='七号牛牛:BAAALAAECgQIBAAAAA==.',['三七']='三七开:BAABLAAFFH8GAAMRAAYIRBQ1HwCoAAARAAMIOww1HwCoAAAFAAMIPxNwPgCZAAAAAA==.',['三千']='三千度近视:BAAALAAECggICAAAAA==.',['三月']='三月七:BAAALAADCggICAABLAAECgYICgAMAAAAAA==.',['下辈']='下辈子再光启:BAAALAAECgYIBgAAAA==.',['不包']='不包吃不包住:BAAALAAECgMIAwAAAA==.',['不觉']='不觉明厉:BAAALAAECggIBwAAAA==.',['世界']='世界之灾:BAACLAAFFH8IAAIEAAIIbxPSVgBFAAAEAAIIbxPSVgBFAAAsAAQKfx0AAwQABghKHQ1jAAMCAAQABghKHQ1jAAMCAAYABAj1CyxQAJQAAAAA.',['东宫']='东宫雪儿:BAAALAAFFAIIAgAAAA==.',['丨愈']='丨愈殇丶:BAABLAAFFH8YAAISAAUIgRYcFgCEAQASAAUIgRYcFgCEAQAAAA==.',['丨絡']='丨絡乄鐷丨:BAAALAAFFAEIAQAAAA==.',['丨聖']='丨聖灬殇丿:BAAALAADCgIIAgAAAA==.',['临风']='临风:BAAALAAFFAIIAgAAAA==.临风灬:BAABLAAFFH8GAAIOAAIIExR4VQBwAAAOAAIIExR4VQBwAAAAAA==.',['丶明']='丶明栈雪:BAAALAAECgMIAwAAAA==.',['丶永']='丶永恒守护:BAAALAAECgYICQAAAA==.',['丶空']='丶空夜:BAAALAAECgEIAQAAAA==.',['丶轻']='丶轻狂洞天:BAAALAAECgYIBgAAAA==.',['丸子']='丸子烧饼:BAABLAAFFH8JAAMRAAMI/A99JgBxAAARAAIIAhF9JgBxAAAFAAMIURk2UQBUAAAAAA==.',['举头']='举头望明月:BAAALAAECgcICAAAAA==.',['乐游']='乐游:BAAALAAFFAIIBAAAAA==.',['九紫']='九紫离火:BAAALAAFFAIIAgAAAA==.',['九老']='九老:BAAALAAFFAIIBAAAAA==.',['二营']='二营长呢:BAAALAAECgYIBgAAAA==.',['五行']='五行还缺德:BAAALAAECgcIBwAAAA==.五行还缺术:BAAALAADCggICAAAAA==.',['亚洲']='亚洲图片:BAAALAAFFAIIAgAAAA==.',['亡魂']='亡魂丨曲:BAAALAAECgYICQAAAA==.',['人人']='人人果实乔巴:BAAALAAFFAIIAgAAAA==.',['人字']='人字拖大背头:BAAALAAFFAMIBAAAAA==.',['人肉']='人肉打蛋器:BAAALAAECgcIDgAAAA==.',['伊德']='伊德利菈:BAAALAAECgYIBgAAAA==.伊德莉拉:BAAALAAECgEIAQAAAA==.',['会开']='会开花的云:BAAALAAECgYICgAAAA==.',['会飞']='会飞的蛋壳:BAAALAAFFAIIAgAAAA==.',['低调']='低调的峰哥:BAAALAAFFAIIAgAAAA==.',['你终']='你终究还是风:BAAALAADCgQIBAAAAA==.',['光影']='光影行者艾琳:BAAALAAFFAIIBAAAAA==.',['光铸']='光铸丨石头哥:BAAALAAECgYIDAAAAA==.',['克莱']='克莱维斯:BAAALAAECgUIBQAAAA==.',['兜兜']='兜兜里有奶瓶:BAAALAADCgIIAgAAAA==.',['八月']='八月烨:BAABLAAFFH8GAAMKAAYIqyE2FADDAQAKAAUI5CA2FADDAQATAAEIkSULCABpAAAAAA==.',['兮幽']='兮幽:BAAALAAECgYIDAAAAA==.',['冬冬']='冬冬哐当哐当:BAABLAAECn/2AQIUAAgIuyU2AwBGAwAUAAgIuyU2AwBGAwABLAAFFAYIPwAHANQZAA==.',['冬夜']='冬夜霜语:BAAALAADCgcIBwAAAA==.',['冬虫']='冬虫夏草:BAAALAAECggIDwABLAAFFAYIPwAHANQZAA==.',['冰哥']='冰哥圣手:BAABLAAFFH8eAAIRAAYI9RcdDADCAQARAAYI9RcdDADCAQAAAA==.',['冷漠']='冷漠:BAABLAAFFH8HAAIVAAMIkAk6EgCXAAAVAAMIkAk6EgCXAAAAAA==.',['冷萃']='冷萃加冰:BAAALAAECgMIAwAAAA==.',['冷酷']='冷酷饿呢:BAAALAADCgQIBAAAAA==.',['凌乱']='凌乱:BAAALAAECgQIBAAAAA==.',['剑丿']='剑丿锋:BAAALAAECgQIBAAAAA==.',['加不']='加不了血:BAAALAAECgYIBgAAAA==.',['努风']='努风:BAAALAADCgYIBgAAAA==.',['十一']='十一熊猫:BAAALAAECgYIBgAAAA==.',['十三']='十三刺:BAAALAAECgYIBgAAAA==.十三嗜:BAAALAAECgYIBgAAAA==.十三坦:BAAALAAECgYIBwAAAA==.十三姨:BAAALAADCgEIAQAAAA==.十三赐:BAAALAAECgYIDAAAAA==.十三龍:BAAALAAECgUIBQAAAA==.',['千丶']='千丶夜:BAAALAAECgMIAwAAAA==.',['千雪']='千雪:BAAALAAFFAIIAgAAAA==.',['半图']='半图:BAAALAAFFAIIAgAAAA==.',['半朋']='半朋克:BAAALAAECgIIAgAAAA==.',['卖火']='卖火孩的柴:BAABLAAFFH8IAAIKAAIIzQxbVgCKAAAKAAIIzQxbVgCKAAAAAA==.',['南飞']='南飞的雁:BAACLAAFFH8TAAIDAAUIShSzTgATAQADAAUIShSzTgATAQAsAAQKfyEAAwMACAi1IkkNALcCAAMACAi1IkkNALcCAAEAAQguAurUABQAAAAA.',['卡梅']='卡梅隆:BAACLAAFFH8UAAMWAAUItxKlDABDAQAWAAQI9hKlDABDAQAXAAEIvBEuGgAAAAAsAAQKfzoAAxcACAglHNkFAOQBABcABwjVGtkFAOQBABYABwi0GBcuALkBAAAA.',['卢森']='卢森特丨邪焰:BAAALAAECgYIDQAAAA==.',['印度']='印度叫兽:BAAALAADCgYIBgAAAA==.',['叁队']='叁队那个劣人:BAAALAAECgIIAgAAAA==.',['双刀']='双刀贼:BAAALAAECgYIDAAAAA==.',['双子']='双子座:BAAALAAECgYIDwAAAA==.',['发丶']='发丶髻:BAACLAAFFH8IAAIRAAIIHxYFGgCXAAARAAIIHxYFGgCXAAAsAAQKfxYAAxEACAjAEdIpANMBABEACAjAEdIpANMBAA8AAQjmA9t+AB8AAAAA.',['发现']='发现他居然:BAAALAAECgEIAQAAAA==.',['受不']='受不鸟了:BAAALAAECgYICAAAAA==.',['只想']='只想开心点:BAAALAAECgMIAwAAAA==.',['只要']='只要三五:BAAALAADCggIBAAAAA==.',['叽叽']='叽叽腹肌鸡:BAABLAAFFH8FAAISAAQIAQvXOwB/AAASAAQIAQvXOwB/AAABLAAFFAUICQAOAGsNAA==.',['叽里']='叽里咕噜冬冬:BAABLAAECn8rAAIPAAgIBiAzCwDHAgAPAAgIBiAzCwDHAgABLAAFFAYIPwAHANQZAA==.',['吓死']='吓死您:BAAALAAECgYICgAAAA==.',['周美']='周美灵:BAABLAAFFH8GAAIYAAIIUgdsZgA6AAAYAAIIUgdsZgA6AAAAAA==.',['呼噜']='呼噜可可:BAAALAAECgYIBgAAAA==.',['咆哮']='咆哮妹:BAAALAAECgIIAgAAAA==.',['咕噜']='咕噜咕噜冬冬:BAABLAAECn8VAAIQAAgIIyBwEgAAAwAQAAgIIyBwEgAAAwABLAAFFAYIPwAHANQZAA==.咕噜咕噜咚咚:BAAALAAECgQIBAABLAAFFAYIPwAHANQZAA==.',['咚咚']='咚咚锵锵:BAABLAAECn8eAAIZAAgIlyIIBgCDAgAZAAgIlyIIBgCDAgABLAAFFAYIPwAHANQZAA==.',['咸鱼']='咸鱼喵:BAAALAAECgYIEgAAAA==.',['哇偶']='哇偶打得不错:BAABLAAFFH8NAAIHAAUIdhC6IQA3AQAHAAUIdhC6IQA3AQABLAAFFAYICAAOAOIIAA==.',['哈基']='哈基米米:BAAALAAFFAIIAgAAAA==.',['哔哔']='哔哔侠:BAAALAAFFAEIAQAAAA==.',['啟天']='啟天:BAAALAAECgYIDAAAAA==.',['喵莫']='喵莫斯喵:BAACLAAFFH8MAAISAAIIOB4PHgCqAAASAAIIOB4PHgCqAAAsAAQKfywAAxIACAjxGREjAF4CABIACAjxGREjAF4CAAkABQhcDC8dAJkAAAAA.',['嘎嘎']='嘎嘎乱杀:BAAALAAECgEIAQAAAA==.',['嘻嘻']='嘻嘻不嘻嘻:BAAALAAECggICAAAAA==.',['嚣聋']='嚣聋人:BAAALAAECgYIBgAAAA==.',['土丶']='土丶豆:BAAALAADCgUIBQAAAA==.',['土豆']='土豆一:BAAALAAFFAgIBAABLAAFFAgIBgAQACsbAA==.土豆丝:BAAALAAFFAgIAwABLAAFFAgIBgAQACsbAA==.土豆二:BAAALAAFFAgIAgABLAAFFAgIBgAQACsbAA==.土豆五:BAAALAAFFAcIBAABLAAFFAgIBgAQACsbAA==.土豆四:BAAALAAFFAgIAQABLAAFFAgIBgAQACsbAA==.',['圣光']='圣光跳:BAABLAAECn8WAAIFAAgIGxc4SQCBAQAFAAgIGxc4SQCBAQAAAA==.圣光陶洛斯:BAAALAAFFAMIAwAAAA==.',['圣灵']='圣灵狐:BAAALAAECgEIAQAAAA==.',['地狱']='地狱风暴:BAABLAAFFH8IAAIOAAIIWx76NQCVAAAOAAIIWx76NQCVAAAAAA==.',['埃辛']='埃辛诺斯丶:BAAALAAECgYIBgAAAA==.',['城中']='城中村老流氓:BAAALAAECgUIDgAAAA==.',['塞拉']='塞拉摩的风:BAAALAAECgYIBgAAAA==.',['复活']='复活卷轴:BAAALAAFFAIIAgAAAA==.',['复苏']='复苏季风:BAACLAAFFH8GAAIHAAII1w5zPwBrAAAHAAII1w5zPwBrAAAsAAQKfyAAAwcABgiOIX4XAAcCAAcABgiOIX4XAAcCABoAAQjbCeGgAC4AAAAA.',['夏日']='夏日的微风:BAAALAAECgMIAwAAAA==.夏日重现:BAAALAAFFAMIAwAAAA==.',['多恩']='多恩诺德:BAAALAAECgYIBgAAAA==.',['夜媚']='夜媚无瑕:BAAALAAECgIIAgAAAA==.',['夜灬']='夜灬唯眠:BAAALAAECgMIBQAAAA==.夜灬微眠:BAABLAAFFH8HAAIbAAII2RCONAA7AAAbAAII2RCONAA7AAAAAA==.夜灬无眠:BAABLAAFFH8GAAMNAAIIVAaGXAA5AAANAAII2ASGXAA5AAAZAAIIOASVOAAnAAAAAA==.',['夜的']='夜的风格:BAAALAAECgUIBQAAAA==.',['夜航']='夜航星:BAAALAAFFAIIBAAAAA==.',['大丨']='大丨丶圣:BAAALAAECgIIAwAAAA==.',['大天']='大天使泰瑞尔:BAAALAAECgQIBAAAAA==.大天堂之信仰:BAAALAAECggICAAAAA==.',['大橘']='大橘喵:BAAALAAECgEIAgAAAA==.',['大炮']='大炮李熊猫僧:BAAALAAECggIDwAAAA==.大炮李虚空牧:BAAALAAECgUIBQAAAA==.',['大猴']='大猴叽西西酱:BAAALAADCgEIAQAAAA==.',['大神']='大神萨:BAABLAAFFH8GAAMOAAYIexPsJgArAQAOAAUIzhPsJgArAQAQAAEIvRFQPwBLAAAAAA==.',['天启']='天启:BAAALAAECgYIBgAAAA==.',['天天']='天天的心肝:BAABLAAECn8cAAIPAAYIxR0XJQDWAQAPAAYIxR0XJQDWAQAAAA==.',['天边']='天边飘过:BAAALAAECgYIBgAAAA==.',['天问']='天问:BAAALAAECgMIAwAAAA==.',['失忆']='失忆的鱼:BAAALAAFFAIIAgAAAA==.',['头孢']='头孢地尼:BAAALAADCgEIAQAAAA==.',['奥吾']='奥吾:BAAALAAECgQIBQAAAA==.',['奶凶']='奶凶也是凶:BAAALAAECgYIBgAAAA==.',['奶嘴']='奶嘴丶糖:BAABLAAFFH8JAAMRAAYIjBc4EwBYAQARAAUIghk4EwBYAQAFAAQIXQuMOAC9AAAAAA==.',['奶小']='奶小脾气大:BAAALAAECggICAAAAA==.',['奶有']='奶有奶的奶量:BAAALAAFFAIIAgAAAA==.',['奶流']='奶流喝流奶:BAAALAADCgYIBgAAAA==.',['如花']='如花:BAAALAAECgEIAQAAAA==.',['如鱼']='如鱼得水:BAAALAAFFAIIBAAAAA==.',['妈妈']='妈妈桑:BAABLAAFFH8GAAIOAAIImxbnPQCFAAAOAAIImxbnPQCFAAAAAA==.',['妖娆']='妖娆猛南:BAAALAAECggICgAAAA==.',['妹妹']='妹妹的泥头车:BAABLAAFFH8RAAIIAAYIjBqdIQCuAQAIAAYIjBqdIQCuAQAAAA==.',['始源']='始源之潮:BAAALAAFFAgIBAABLAAFFAgIBgAQACsbAA==.',['孤独']='孤独与背叛:BAAALAAECgUIBQABLAAFFAYIBgAbAHsWAA==.',['寂寞']='寂寞罪红颜:BAAALAAECgYIDAAAAA==.寂寞醉红颜:BAAALAAECgUIBQAAAA==.',['寒叶']='寒叶孤城:BAAALAAFFAEIAQAAAA==.',['寒芒']='寒芒一闪:BAAALAAFFAIIBAAAAA==.寒芒壹点:BAAALAAFFAIIAgAAAA==.寒芒点点:BAAALAAECgIIAgAAAA==.',['射到']='射到你发朊:BAAALAADCgYIBgAAAA==.',['射的']='射的飞起:BAAALAAFFAYIAwAAAA==.',['小嘎']='小嘎豆:BAAALAAECgUIBQAAAA==.',['小小']='小小牧:BAABLAAFFH8GAAIHAAYIoRzTEQDMAQAHAAYIoRzTEQDMAQAAAA==.小小電萨:BAAALAAFFAEIAQAAAA==.',['小时']='小时候真显老:BAABLAAFFH8XAAIYAAYIbSLmEQD+AQAYAAYIbSLmEQD+AQAAAA==.',['小林']='小林立奇:BAAALAADCgEIAQAAAA==.',['小玩']='小玩熊:BAAALAADCgYIBgAAAA==.',['小矮']='小矮:BAAALAAFFAEIAQAAAA==.',['小血']='小血僧:BAAALAADCgcIBwAAAA==.',['小长']='小长虫:BAAALAAECggICAAAAA==.',['小马']='小马达:BAAALAAECggIAgAAAA==.',['小麦']='小麦子粒粒:BAAALAADCgIIAgAAAA==.',['小龙']='小龙疯:BAABLAAFFH8JAAILAAYI1BYfBQB1AQALAAYI1BYfBQB1AQAAAA==.',['尝试']='尝试一下:BAAALAAECgMIAwAAAA==.',['尼古']='尼古拉斯阿奇:BAABLAAFFH8JAAMZAAIIHxmMKABDAAANAAIIywHiTgBkAAAZAAIIHxmMKABDAAAAAA==.',['峡谷']='峡谷溪月:BAAALAAFFAIIBAAAAA==.',['川井']='川井:BAAALAADCgEIAQABLAAECgMIAwAMAAAAAA==.',['巧克']='巧克力麻薯:BAABLAAFFH8VAAIIAAYIkRhjJACjAQAIAAYIkRhjJACjAQAAAA==.',['帅帅']='帅帅劣:BAAALAAFFAMIBAABLAAFFAgIEAADAOoiAA==.',['希尔']='希尔德加德:BAAALAAECgEIAQAAAA==.',['帝戰']='帝戰:BAAALAAECgYIBwAAAA==.',['帮帮']='帮帮硬:BAAALAAECgIIAgAAAA==.',['干涉']='干涉那只猪:BAAALAAECgYIBQAAAA==.',['幻影']='幻影:BAAALAAFFAMIAwAAAA==.',['幽冥']='幽冥帝君:BAAALAAECgQIBQAAAA==.幽冥逍遥:BAAALAAECggIBgAAAA==.幽冥邪神:BAAALAAECgYIBgAAAA==.幽冥飞矢:BAAALAAECgYIBgAAAA==.',['弟御']='弟御狍笑:BAAALAADCggIDwAAAA==.',['张春']='张春华:BAAALAAFFAIIAwAAAA==.',['弹指']='弹指红颜老:BAAALAAECgYIBgAAAA==.',['强击']='强击:BAABLAAFFH8FAAIDAAUIAgSnZQCgAAADAAUIAgSnZQCgAAAAAA==.',['得瑟']='得瑟怪叔叔:BAABLAAFFH8WAAMFAAYIYB7DDADdAQAFAAYIYB7DDADdAQAPAAMICALiFwA/AAAAAA==.',['性感']='性感的屁屁:BAAALAAECgEIAQAAAA==.性感萬筒条:BAAALAAECgYIBgAAAA==.',['恋牧']='恋牧:BAABLAAFFH8MAAIHAAYIExhKGACPAQAHAAYIExhKGACPAQAAAA==.',['情绪']='情绪不稳定:BAAALAAFFAEIAQAAAA==.',['惩诫']='惩诫:BAAALAAECgUIBgAAAA==.',['憨憨']='憨憨的大壮:BAAALAAECgYIBgAAAA==.',['懒痒']='懒痒痒:BAABLAAFFH8aAAIOAAUIaBJ+JwAnAQAOAAUIaBJ+JwAnAQAAAA==.',['成和']='成和叶:BAAALAAFFAIIBAAAAA==.',['我不']='我不变熊熊:BAABLAAFFH8GAAMNAAIIhxASTgBGAAANAAIIiQwSTgBGAAAZAAIIUQwoNQAtAAAAAA==.',['我空']='我空:BAABLAAFFH8GAAINAAYIUxfwBgAlAgANAAYIUxfwBgAlAgAAAA==.',['战争']='战争萨:BAAALAAECgYIEwAAAA==.',['戦伍']='戦伍渣:BAABLAAFFH8GAAINAAIIlRK6UABEAAANAAIIlRK6UABEAAABLAAFFAYIEAAIAO4bAA==.',['扎师']='扎师父:BAAALAAFFAIIAgAAAA==.',['打铁']='打铁哥:BAAALAAECgEIAQAAAA==.打铁爸爸:BAAALAAECggICAAAAA==.',['打麻']='打麻将从不输:BAAALAADCgEIAQAAAA==.',['扫地']='扫地焚香:BAAALAAFFAMIBAAAAA==.',['扯淡']='扯淡淡丶:BAAALAAECgYIDQAAAA==.',['抓你']='抓你枚子:BAAALAADCgIIAgAAAA==.',['拉啦']='拉啦辣:BAAALAAECgEIAQAAAA==.',['拒蕝']='拒蕝憾動:BAAALAAECggIEAAAAA==.',['拖孩']='拖孩君:BAAALAAECgYICQAAAA==.',['拜拜']='拜拜老火锅:BAAALAAECgYIDAAAAA==.',['拿青']='拿青春度明天:BAAALAAECgYIBwAAAA==.',['挽歌']='挽歌:BAABLAAFFH8lAAIIAAYIkSAdFgDkAQAIAAYIkSAdFgDkAQAAAA==.',['插得']='插得有点深:BAAALAAECgEIAQAAAA==.',['擎天']='擎天棍:BAAALAAECgMIAwAAAA==.',['文明']='文明人:BAAALAAECgIIAgAAAA==.',['斩鬼']='斩鬼神:BAAALAADCgYIBgAAAA==.',['断角']='断角小小牛:BAAALAAFFAIIAwAAAA==.',['新手']='新手保护期:BAAALAADCggICAAAAA==.',['无敌']='无敌小射手:BAABLAAFFH8KAAIDAAIIFBfEUgCUAAADAAIIFBfEUgCUAAAAAA==.无敌搓炉石:BAAALAAECgIIAwAAAA==.无敌金盾:BAAALAAECgIIAgAAAA==.',['无泪']='无泪:BAAALAAFFAIIAgAAAA==.',['无玖']='无玖:BAAALAAECgMIAwAAAA==.',['无矢']='无矢:BAACLAAFFH8SAAMBAAMIjh+vEwDJAAABAAII8yOvEwDJAAADAAEIxRZumwBAAAAsAAQKfzoAAwEACAiGJNkJABYDAAEACAiHI9kJABYDAAMACAjHIJAyAJACAAAA.',['无聊']='无聊的鸡蛋:BAAALAAECgYICQAAAA==.',['无赖']='无赖布鲁斯:BAAALAAECgYIBgAAAA==.',['星彡']='星彡月:BAAALAAECgQIBAAAAA==.',['星星']='星星下:BAAALAAECgUIBQAAAA==.',['星空']='星空落:BAAALAAFFAMIAgAAAA==.',['星霜']='星霜卡卡:BAAALAAFFAEIAQAAAA==.',['是只']='是只大肉兔呀:BAAALAAECgQIBAAAAA==.',['晴天']='晴天是你:BAACLAAFFH8RAAISAAUIpQfBJQDrAAASAAUIpQfBJQDrAAAsAAQKfxkAAhIABwjqD7w6ADIBABIABwjqD7w6ADIBAAAA.',['暗夜']='暗夜断箭:BAAALAADCgYIBgAAAA==.',['暗箭']='暗箭杀:BAAALAADCgcIBwAAAA==.',['暧冷']='暧冷:BAAALAAECgEIAgAAAA==.',['暴暴']='暴暴一米:BAAALAAECgMIAwAAAA==.',['暴躁']='暴躁路人甲:BAABLAAECn8ZAAINAAYIVw8EmABVAQANAAYIVw8EmABVAQAAAA==.',['最后']='最后乃我一口:BAACLAAFFH8LAAIIAAIIXhi4dQBLAAAIAAIIXhi4dQBLAAAsAAQKfyAAAggACAh6GkggAPkBAAgACAh6GkggAPkBAAAA.',['最爱']='最爱喝纯牛奶:BAAALAAFFAIIBAAAAA==.',['月下']='月下闪灵:BAAALAAECgUIBQAAAA==.',['朱颜']='朱颜染尘:BAABLAAFFH8TAAMFAAcIuxnFCgDvAQAFAAcIuxnFCgDvAQAPAAIIdQnWHQBlAAAAAA==.',['朵朵']='朵朵:BAAALAAECgMIAwAAAA==.',['杀气']='杀气好重:BAABLAAFFH8QAAIOAAYI/CBxCwAYAgAOAAYI/CBxCwAYAgAAAA==.',['来生']='来生泪:BAABLAAFFH8GAAIDAAIIoAegrAA5AAADAAIIoAegrAA5AAAAAA==.',['杨咏']='杨咏信:BAABLAAFFH8JAAIOAAUIaw0XMADuAAAOAAUIaw0XMADuAAAAAA==.',['林鹤']='林鹤由美:BAACLAAFFH8IAAIEAAIIQRMGUgBIAAAEAAIIQRMGUgBIAAAsAAQKfxgAAgQABgi7F1o/AF8BAAQABgi7F1o/AF8BAAAA.',['果家']='果家的胡萝卜:BAAALAAECgQIBAAAAA==.',['枪响']='枪响鸟散:BAAALAAECgMIAwAAAA==.',['柒晴']='柒晴:BAAALAAECgYIBgAAAA==.',['柔中']='柔中柔:BAAALAAECgYIBgAAAA==.',['柔心']='柔心柔:BAAALAAECgEIAQAAAA==.',['柔情']='柔情柔:BAAALAAECgYIBgAAAA==.',['柱子']='柱子能奶你吗:BAAALAAECgYIBgAAAA==.',['核桃']='核桃核桃:BAAALAAECgcICgAAAA==.',['梅霖']='梅霖久久:BAAALAAECgYIBgAAAA==.',['梦醒']='梦醒半陶醉:BAAALAAECgMIAwAAAA==.',['梦魇']='梦魇丶躺尸侠:BAABLAAFFH8OAAIYAAYIMQg4GwBkAQAYAAYIMQg4GwBkAQAAAA==.',['梧桐']='梧桐丶:BAAALAAECgIIAgAAAA==.',['欣德']='欣德瑞拉:BAAALAAECgYIBgAAAA==.',['欧水']='欧水给你宣出:BAAALAAFFAQIBAAAAA==.',['欧美']='欧美电影:BAAALAAFFAIIAgAAAA==.',['欧鸡']='欧鸡饱:BAABLAAFFH8MAAIDAAYIjx+1HQC8AQADAAYIjx+1HQC8AQAAAA==.',['此去']='此去半生:BAAALAADCgIIAgAAAA==.',['武之']='武之内空:BAAALAAECgYIBgAAAA==.',['死亡']='死亡摇滚:BAAALAAECgcICgAAAA==.',['死大']='死大师:BAAALAAECgYIBgAAAA==.',['死騎']='死騎訓练師:BAAALAAFFAIIBAAAAA==.',['死骑']='死骑友友:BAAALAAFFAEIAQAAAA==.死骑士:BAABLAAECn8ZAAMFAAcIBhgxTwBxAQAFAAcIlRYxTwBxAQAPAAYIkxQiPwA/AQAAAA==.',['残月']='残月之叹:BAAALAAECgYIBgAAAA==.',['殡仪']='殡仪馆天后:BAABLAAFFH8GAAIIAAIIsRB+fwBGAAAIAAIIsRB+fwBGAAAAAA==.',['母牛']='母牛刷坐骑:BAAALAAECgMIAwAAAA==.',['毛胖']='毛胖球:BAABLAAFFH8gAAMHAAgIWB1YAwCzAgAHAAgIWB1YAwCzAgAaAAMIOA8ZGgDcAAABLAAFFAgIpAAHAAUkAA==.',['水煮']='水煮乌鱼片:BAABLAAFFH8MAAIcAAYIGhcHCwCjAQAcAAYIGhcHCwCjAQAAAA==.',['永恒']='永恒丨守护:BAAALAADCgMIAwAAAA==.永恒嗲鸡哥:BAAALAAECgYIDQAAAA==.永恒守护:BAAALAADCggICAAAAA==.永恒守护丨:BAAALAAECgQIBAAAAA==.',['汉堡']='汉堡宝:BAABLAAFFH8vAAMYAAcIMhfmFwDLAQAYAAcIMhXmFwDLAQAdAAEIAxMyBwBXAAAAAA==.',['江洋']='江洋小盗:BAABLAAECn8VAAIeAAgI4hnBBACIAgAeAAgI4hnBBACIAgAAAA==.',['江湖']='江湖淡定熊:BAAALAAECgQIBQAAAA==.',['汤卟']='汤卟哩卟咚咚:BAABLAAECn8fAAIfAAgIcyJVBQAcAwAfAAgIcyJVBQAcAwABLAAFFAYIPwAHANQZAA==.',['沁泽']='沁泽渊:BAABLAAFFH8GAAIKAAMI7AvzMwC5AAAKAAMI7AvzMwC5AAAAAA==.',['油泼']='油泼辣子:BAACLAAFFH8eAAIDAAYIMx/YGgDJAQADAAYIMx/YGgDJAQAsAAQKfxQAAwEABgjOHIJTAGkBAAEABggjE4JTAGkBAAMABAiqJCGPADEBAAAA.',['法克']='法克蛮:BAABLAAFFH8FAAISAAIIjhGqLwB1AAASAAIIjhGqLwB1AAAAAA==.',['泛泰']='泛泰希:BAAALAAECgYICAAAAA==.',['洛天']='洛天依:BAAALAAFFAIIBAAAAA==.',['洪炎']='洪炎:BAAALAAFFAQIBAAAAA==.',['浅浅']='浅浅初荷嵐:BAABLAAFFH8GAAIgAAIIPBOFEACXAAAgAAIIPBOFEACXAAAAAA==.',['浪人']='浪人丶丶:BAAALAAECgYICgAAAA==.',['浴血']='浴血丷天歌:BAAALAAECgcIBwAAAA==.',['海鱼']='海鱼的奶牛:BAAALAAECgMIAwAAAA==.',['淇哥']='淇哥:BAAALAAECgQIBAAAAA==.',['深红']='深红浅碧:BAAALAADCgIIAgAAAA==.',['清璇']='清璇妩皑:BAAALAADCgQIBAAAAA==.',['澜飞']='澜飞:BAAALAAFFAIIAgAAAA==.',['激爽']='激爽大片:BAAALAAECgEIAQAAAA==.',['火星']='火星人:BAAALAAECgYICAAAAA==.',['火震']='火震:BAABLAAFFH8GAAIQAAYIKxtzGQBzAQAQAAYIKxtzGQBzAQAAAA==.',['灬娜']='灬娜娜酱灬:BAAALAAECggIDwAAAA==.',['灬我']='灬我是传奇:BAACLAAFFH8QAAINAAIIohopRgBNAAANAAIIohopRgBNAAAsAAQKf0IAAg0ACAiXH2AOAHwCAA0ACAiXH2AOAHwCAAAA.',['灯灯']='灯灯战:BAABLAAFFH8GAAINAAQIgQZsNgCZAAANAAQIgQZsNgCZAAAAAA==.',['灰熊']='灰熊丘陵的风:BAAALAADCgIIAgAAAA==.',['炎火']='炎火火:BAAALAADCggICAAAAA==.',['烈焰']='烈焰回归:BAAALAAECgUIBQAAAA==.烈焰飞舞:BAAALAADCggICAAAAA==.',['焚香']='焚香:BAAALAAFFAIIAgAAAA==.',['煙灰']='煙灰到处飛:BAAALAAECgYIDAAAAA==.',['熊灬']='熊灬爸:BAABLAAFFH8GAAISAAIINg6hOgBlAAASAAIINg6hOgBlAAAAAA==.',['熊猫']='熊猫老三:BAAALAADCgIIAgAAAA==.',['爱你']='爱你每一世:BAAALAAFFAIIAgAAAA==.',['爱吃']='爱吃橘子:BAAALAAFFAIIAgAAAA==.爱吃西瓜:BAABLAAFFH8HAAIDAAIIZiNHeABsAAADAAIIZiNHeABsAAAAAA==.爱吃西瓜吖:BAACLAAFFH8NAAIIAAMI4xhRVQC1AAAIAAMI4xhRVQC1AAAsAAQKfxYAAggACAgBH9ANAIECAAgACAgBH9ANAIECAAAA.爱吃西瓜呀:BAAALAAFFAIIAgAAAA==.',['爱新']='爱新觉罗喵喵:BAAALAAECgEIAQAAAA==.',['爽脆']='爽脆牛肉丝:BAABLAAFFH8OAAIIAAQIhBBiUQDUAAAIAAQIhBBiUQDUAAAAAA==.',['牙先']='牙先着地:BAABLAAFFH8IAAIOAAYI4gjtLAACAQAOAAYI4gjtLAACAQAAAA==.',['牛仔']='牛仔猎手:BAAALAAFFAIIAgAAAA==.',['牛克']='牛克萨司:BAAALAAECgYICAAAAA==.',['牛匕']='牛匕哄哄:BAAALAADCgcIBwAAAA==.',['牛牛']='牛牛两只角:BAACLAAFFH8OAAIOAAII5RcfPQCGAAAOAAII5RcfPQCGAAAsAAQKfxcAAg4ABgihHpwtAK0BAA4ABgihHpwtAK0BAAAA.牛牛小头痛:BAAALAADCgQIBAAAAA==.',['牛重']='牛重征:BAAALAADCgcIBwAAAA==.',['牧古']='牧古尘终:BAABLAAFFH8MAAMKAAgIVx81CQBPAgAKAAgIeh41CQBPAgALAAII8iGGEABcAAAAAA==.',['牧夜']='牧夜独舞:BAABLAAFFH8HAAIEAAIIBw63WwBCAAAEAAIIBw63WwBCAAAAAA==.',['狂奔']='狂奔的圣骑:BAAALAAFFAIIBAAAAA==.狂奔的戰牛:BAABLAAECn8WAAINAAgIWR2sLgB+AgANAAgIWR2sLgB+AgAAAA==.狂奔的骑士:BAAALAAECgYIBgAAAA==.',['狐影']='狐影猎手:BAAALAAECgYIBwAAAA==.',['狮子']='狮子之歌:BAAALAAECgYICAAAAA==.',['猎骨']='猎骨者巴托:BAAALAAECgIIAgAAAA==.',['王先']='王先生:BAAALAADCggICQAAAA==.',['王半']='王半斤:BAAALAAECgQIBAAAAA==.',['理查']='理查德佩恩:BAABLAAFFH8IAAILAAII3Ap9GgA7AAALAAII3Ap9GgA7AAAAAA==.',['瑶一']='瑶一丶:BAAALAAFFAgIAgAAAA==.',['瑶酷']='瑶酷魅川:BAAALAAECgEIAQAAAA==.',['璃婚']='璃婚婚:BAABLAAFFH8KAAIOAAIIBBzZSACMAAAOAAIIBBzZSACMAAAAAA==.',['用点']='用点力行不行:BAAALAAECgIIAgAAAA==.',['男人']='男人猫:BAAALAAFFAgIAgAAAA==.',['白唆']='白唆唆:BAAALAAFFAIIBAAAAA==.',['白牛']='白牛猎魂:BAAALAAECgYIBgAAAA==.白牛裂魂:BAABLAAECn8UAAQhAAYI7h4DGgAFAQAhAAQI0x8DGgAFAQAdAAQIagxeJADFAAAYAAEIKh6SjQBUAAAAAA==.',['白羊']='白羊:BAAALAAECgYIBgAAAA==.',['白色']='白色黑裤衩:BAAALAAECgUIBQAAAA==.',['百分']='百分百掉坐骑:BAAALAAECgUICgAAAA==.',['百变']='百变星君:BAAALAAECgUIBQAAAA==.百变熊孩子:BAAALAAECgYICAAAAA==.',['皓月']='皓月下的玫瑰:BAAALAAECgYICwAAAA==.',['皮蛋']='皮蛋一米三:BAAALAADCgUIBQAAAA==.',['盲兽']='盲兽:BAAALAADCgQIBAAAAA==.',['相当']='相当老火:BAAALAAFFAIIBAAAAA==.',['相濡']='相濡以沫:BAAALAAFFAQIBAAAAA==.',['真妹']='真妹子:BAAALAADCgIIAgAAAA==.',['石头']='石头人萨满:BAAALAAECgUIBQAAAA==.',['石田']='石田龍弦:BAAALAADCgEIAQAAAA==.',['砍人']='砍人的人:BAABLAAECn8eAAMNAAgIWxjDSwANAgANAAcIeRrDSwANAgAZAAMIiQWyhwBmAAAAAA==.',['砸瓦']='砸瓦鲁德:BAAALAAECgYIBgAAAA==.',['碎碎']='碎碎丶念:BAAALAAFFAIIBAAAAA==.',['神丨']='神丨龙:BAACLAAFFH8JAAISAAIIPBdAOgCEAAASAAIIPBdAOgCEAAAsAAQKfyIABRIACAiwFXs1AAkCABIACAiwFXs1AAkCABsABQiSFN80AO0AAAkAAggwCCM2AEgAACIAAQiiDiAnADAAAAAA.',['神帝']='神帝:BAAALAAECgUIBQABLAAFFAgIEQAYAJYaAA==.',['神木']='神木丽:BAAALAADCgcICAAAAA==.',['神枪']='神枪手保罗:BAAALAAECgcIDAAAAA==.',['神选']='神选小颂可:BAAALAAFFAIIAgABLAAFFAMIBgAQAL8dAA==.',['禽深']='禽深深愚懵懵:BAAALAAECgYIEQAAAA==.',['秉公']='秉公执法:BAAALAAFFAIIAgABLAAFFAgICAAjAOwAAA==.',['秋天']='秋天色糖果:BAAALAAFFAIIAgAAAA==.',['穆娅']='穆娅:BAAALAAECgYIBgAAAA==.',['空想']='空想家:BAAALAAFFAIIAgAAAA==.',['空我']='空我:BAABLAAFFH8GAAIfAAYI+hHKBQC9AQAfAAYI+hHKBQC9AQAAAA==.',['笑叶']='笑叶子:BAAALAAECgIIAgAAAA==.',['笑嘻']='笑嘻嘻骑士:BAAALAAECgYIBgAAAA==.',['箭走']='箭走偏疯:BAABLAAFFH8PAAIDAAYIkQcxWADqAAADAAYIkQcxWADqAAAAAA==.',['米开']='米开朗基罗:BAAALAADCgEIAQAAAA==.',['米斯']='米斯塔奎恩:BAABLAAFFH8YAAQkAAUI5hLCDwAdAQAkAAUI5hLCDwAdAQAcAAMIgwvNGAB8AAAlAAEIVwVxEAA6AAAAAA==.',['粉粉']='粉粉的烧饼:BAACLAAFFH8sAAMkAAYIgh0yCQCQAQAkAAYIgh0yCQCQAQAlAAUIqRIxCAAXAQAsAAQKfy8AAyQACAi7IDkKAPkCACQACAi7IDkKAPkCABwABgjFB48xANIAAAAA.',['精彩']='精彩必将继续:BAAALAAFFAEIAQAAAA==.',['索伦']='索伦艾尔:BAAALAAECgMIAwAAAA==.',['索大']='索大师:BAAALAAFFAIIAgAAAA==.',['索西']='索西亚黑莲:BAAALAAECgMIBAAAAA==.索西娅红莲:BAAALAAECgQIBQAAAA==.',['紫色']='紫色心情:BAAALAAECgYIBgAAAA==.紫色記憶:BAABLAAFFH8KAAMhAAIIMBuhIgBcAAAhAAEIhR+hIgBcAAAYAAIIGRK9ZwA4AAAAAA==.',['紫颜']='紫颜星晨:BAAALAAECgYICAAAAA==.',['絶對']='絶對猥亦琐:BAAALAAECgYIBgAAAA==.',['綯氣']='綯氣寶唄:BAAALAAECgcICAAAAA==.',['繁华']='繁华落尽:BAAALAAFFAIIBAAAAA==.',['繁星']='繁星的坠落:BAAALAAECgYIEgAAAA==.',['终小']='终小鱼:BAAALAAFFAMIAwAAAA==.',['给你']='给你糖丸了:BAAALAAFFAIIAgABLAAFFAUIJAAfABwSAA==.',['罗伯']='罗伯特唐尼:BAAALAAECgEIAQAAAA==.',['美羊']='美羊羊:BAAALAADCgEIAQAAAA==.',['老年']='老年玩家丶:BAAALAADCgUIBQAAAA==.',['老特']='老特拉福德:BAAALAAECgMIBAAAAA==.',['老阴']='老阴闭:BAAALAADCgMIAwAAAA==.',['聖光']='聖光:BAAALAAECgYIBgAAAA==.',['股伊']='股伊耳:BAAALAADCgQIBAAAAA==.',['肥肠']='肥肠侠:BAAALAAFFAIIAgAAAA==.',['胡飞']='胡飞非:BAABLAAFFH8HAAIZAAIIFhDYLgA0AAAZAAIIFhDYLgA0AAAAAA==.',['胸小']='胸小别哔哔:BAABLAAFFH8IAAIEAAIIRxgaMwClAAAEAAIIRxgaMwClAAAAAA==.',['能猫']='能猫:BAAALAAECgMIAwAAAA==.',['脆脆']='脆脆牧:BAAALAAECgIIAgAAAA==.',['腼腆']='腼腆的大壮:BAAALAAECgYIBwAAAA==.',['艾俄']='艾俄洛迪斯:BAAALAAECgYIBgAAAA==.',['花乄']='花乄满楼:BAAALAAECgQIAgAAAA==.',['花事']='花事了丶:BAAALAAECgYIBgAAAA==.',['花鸡']='花鸡:BAAALAAECgYICgAAAA==.',['苦菜']='苦菜干巴炒饭:BAAALAAFFAgIAgAAAA==.',['荆轲']='荆轲刺秦王:BAABLAAFFH8IAAIeAAgIMAHZBgARAAAeAAgIMAHZBgARAAAAAA==.',['草莓']='草莓圣代:BAABLAAFFH8GAAIZAAYI3BLXEQA4AQAZAAYI3BLXEQA4AQAAAA==.',['莳绱']='莳绱的寶寶:BAAALAAECgQIBAAAAA==.莳绱的調調:BAAALAAECggIDQAAAA==.',['莼白']='莼白牛奶:BAABLAAECn8VAAIOAAcIQhQ1cACiAQAOAAcIQhQ1cACiAQAAAA==.',['菀菀']='菀菀类卿:BAABLAAFFH8FAAISAAMIuwbSJACUAAASAAMIuwbSJACUAAAAAA==.',['菊花']='菊花很香:BAAALAAECgYIBgAAAA==.',['萌乄']='萌乄哒哒的牛:BAABLAAFFH8QAAIFAAYITSGqCQDMAQAFAAYITSGqCQDMAQAAAA==.',['萌新']='萌新保护期:BAAALAAECggICAAAAA==.',['萌有']='萌有萌的萌法:BAAALAAECgIIAgAAAA==.',['萍水']='萍水相逢:BAABLAAFFH8GAAIIAAMI1QiCawBjAAAIAAMI1QiCawBjAAAAAA==.',['萤火']='萤火虫的伞:BAAALAADCgYIBgAAAA==.',['落日']='落日:BAAALAAFFAIIAwAAAA==.',['薛之']='薛之谦:BAAALAAECgMIAwAAAA==.',['虎杖']='虎杖悠仁:BAAALAAFFAIIBAAAAA==.',['蛮小']='蛮小德:BAAALAAECgYIBgAAAA==.',['蜜桔']='蜜桔烧饼:BAAALAAECgMIAwAAAA==.',['血之']='血之梦梦:BAABLAAECn8ZAAILAAYIFxZIIQAVAQALAAYIFxZIIQAVAQAAAA==.',['血夜']='血夜漂香:BAABLAAFFH8MAAMYAAYIsBWSCgAeAgAYAAYIsBWSCgAeAgAhAAIIVBdNEABMAAAAAA==.',['血燃']='血燃:BAAALAAECgUIBQAAAA==.',['袖白']='袖白雪:BAAALAADCgYIBgAAAA==.',['褪色']='褪色者:BAAALAADCgYIBgAAAA==.',['西宫']='西宫丶雪儿:BAAALAAFFAIIAgAAAA==.西宫雪儿:BAAALAAFFAIIAwAAAA==.西宫雪儿丶:BAABLAAFFH8GAAISAAIIBQc8QgBdAAASAAIIBQc8QgBdAAAAAA==.',['西格']='西格玛男人:BAABLAAFFH8GAAINAAYIcQqDIwBSAQANAAYIcQqDIwBSAQAAAA==.',['談笑']='談笑舞非酋:BAAALAAFFAIIAgAAAA==.',['记得']='记得笑:BAAALAAECgYIDQAAAA==.',['请叫']='请叫我丶贤姐:BAABLAAFFH8SAAIYAAYI3B4XFgDYAQAYAAYI3B4XFgDYAQABLAAFFAYIFwAYAG0iAA==.请叫我女王:BAAALAAECgYIBgAAAA==.',['请向']='请向我开炮:BAAALAAECgYIBgAAAA==.',['诺和']='诺和橙子爸爸:BAAALAAFFAIIAgAAAA==.',['诺温']='诺温蓓泰菈:BAAALAAECgYICgAAAA==.',['谢小']='谢小丸子:BAAALAAECgYIEQAAAA==.',['贪狼']='贪狼廉贞:BAABLAAFFH8GAAIOAAIIBw0HUwBpAAAOAAIIBw0HUwBpAAAAAA==.',['赛红']='赛红儿:BAABLAAFFH8FAAIDAAUI0AzKVQD2AAADAAUI0AzKVQD2AAAAAA==.',['赤月']='赤月:BAAALAAECgYIBgAAAA==.',['走慢']='走慢点:BAABLAAFFH8FAAIKAAMIkQ+cRACbAAAKAAMIkQ+cRACbAAAAAA==.',['赵二']='赵二狗狗:BAAALAAECggICAAAAA==.',['起床']='起床特困户:BAAALAAECgYIBgAAAA==.',['路过']='路过的萨满:BAAALAADCggICAAAAA==.',['转角']='转角遇见眷:BAAALAAECgUIBQAAAA==.',['辣条']='辣条配红酒:BAABLAAFFH8QAAIYAAYIyRN4JgCAAQAYAAYIyRN4JgCAAQAAAA==.',['迦南']='迦南:BAAALAAECgYIBgAAAA==.',['迷來']='迷來所你的卡:BAAALAAECgYIBgAAAA==.',['迷所']='迷所:BAAALAAECgQIBAAAAA==.',['迷途']='迷途小浣熊:BAABLAAECn8YAAIFAAcIahTtmADCAQAFAAcIahTtmADCAQAAAA==.迷途的大表哥:BAAALAADCgcIBwAAAA==.迷途的悲伤蛙:BAAALAAECgUIBQAAAA==.',['追梦']='追梦赤子:BAAALAAECgYIBgAAAA==.',['逝武']='逝武:BAAALAAECgYIBgAAAA==.',['道北']='道北男模:BAAALAAFFAIIBAAAAA==.',['遗忘']='遗忘的忧伤:BAACLAAFFH8XAAUiAAUIxAfaBwDpAAAiAAUIxAfaBwDpAAASAAQICAVdKACJAAAJAAIIrAhdDgAqAAAbAAEIpwEDQAAhAAAsAAQKfx8AAyIACAiRFWwJAK8BACIABwitF2wJAK8BABIABwh8ELZxAEIBAAAA.遗忘的悲伤:BAACLAAFFH8WAAMgAAUInw8IBgA5AQAgAAUInw8IBgA5AQAIAAMIdwWGaAB0AAAsAAQKfxwABCAACAi+GgwFACACACAACAi+GgwFACACAAgABQjsC8l0AAQBABQAAQgHEqgwADcAAAAA.遗忘的童年:BAACLAAFFH8FAAIQAAIIVg7PTgA2AAAQAAIIVg7PTgA2AAAsAAQKfyEAAxAACAgEGJIWAPcBABAACAgEGJIWAPcBAA4ABwg4D0u/AAYBAAEsAAUUBQgWACAAnw8A.',['邓唯']='邓唯减速图腾:BAAALAAFFAEIAQAAAA==.',['郭大']='郭大宝的姨妈:BAAALAADCgYIBgAAAA==.',['都敏']='都敏俊丶:BAABLAAFFH8FAAIFAAMI4g9fSgBuAAAFAAMI4g9fSgBuAAAAAA==.',['酒醒']='酒醒香满怀:BAABLAAFFH8HAAIFAAMIrBqTGQD2AAAFAAMIrBqTGQD2AAAAAA==.',['酷酷']='酷酷的小射手:BAAALAAECgYIBgAAAA==.酷酷的小骑士:BAABLAAFFH8MAAIFAAIIBCS0IADOAAAFAAIIBCS0IADOAAAAAA==.',['醉漾']='醉漾轻舟:BAAALAAECgYIBgAAAA==.',['里尔']='里尔哦:BAABLAAFFH8GAAIDAAIIpQ7PZACIAAADAAIIpQ7PZACIAAAAAA==.',['野师']='野师傅:BAAALAAECgQIBQAAAA==.',['鉄甲']='鉄甲依然在:BAAALAAECgYICAAAAA==.',['铁头']='铁头肥羊:BAAALAAECgYICAAAAA==.铁头肥羊二号:BAAALAAECgYICAAAAA==.',['银耳']='银耳薏米粥:BAAALAAECgYIBgAAAA==.',['银龙']='银龙欧吧:BAAALAAFFAIIAgAAAA==.',['错过']='错过的星期三:BAAALAAECgYIBgAAAA==.',['锦衣']='锦衣:BAABLAAFFH8FAAIRAAMINgWKIwCGAAARAAMINgWKIwCGAAAAAA==.',['阿仁']='阿仁阿仁:BAAALAAFFAIIAgAAAA==.',['阿克']='阿克斯通:BAAALAAECgYIBwAAAA==.',['阿刁']='阿刁:BAAALAAECgYIDwAAAA==.',['阿塔']='阿塔尼斯:BAAALAAECgYIBgAAAA==.',['陆雪']='陆雪琪:BAAALAAECgUIBQAAAA==.',['陈丶']='陈丶茅台烈酒:BAAALAAECgUIBQAAAA==.',['陈醋']='陈醋宝宝:BAAALAAFFAIIAgAAAA==.',['陌路']='陌路丿相逢丶:BAABLAAFFH8UAAIDAAUIHAwvVwDwAAADAAUIHAwvVwDwAAAAAA==.',['隆恩']='隆恩丶血蹄:BAABLAAECn8UAAIDAAcI2x4hVwAvAgADAAcI2x4hVwAvAgAAAA==.',['隨風']='隨風瑩瑩:BAAALAADCgEIAQAAAA==.',['雄霸']='雄霸丶东眆:BAAALAAECgYIDAAAAA==.雄霸丶花丛忠:BAAALAAECgMIAwAAAA==.雄霸丶菜玖練:BAAALAAECgYICQAAAA==.',['雨痕']='雨痕:BAAALAAFFAIIAgAAAA==.',['雨瞳']='雨瞳:BAAALAAECgUIBQAAAA==.',['雷电']='雷电法皇永信:BAACLAAFFH8sAAIOAAgICyKJAQBnAgAOAAgICyKJAQBnAgAsAAQKfzwAAg4ACAjnIfYSANkCAA4ACAjnIfYSANkCAAAA.',['霜之']='霜之哀殇:BAAALAAECgYIBgAAAA==.',['靁电']='靁电法王:BAAALAADCgIIAgAAAA==.',['青桔']='青桔柠檬:BAAALAAECgEIAQAAAA==.',['非非']='非非胡:BAABLAAFFH8GAAIJAAIIIQifCgBfAAAJAAIIIQifCgBfAAAAAA==.',['韓菲']='韓菲子:BAAALAAECgQIBAAAAA==.',['颂可']='颂可搞破坏:BAAALAAFFAIIAwABLAAFFAMIBgAQAL8dAA==.颂可皮卡丘:BAABLAAFFH8GAAIQAAMIvx3MFQAHAQAQAAMIvx3MFQAHAQAAAA==.',['风之']='风之暗影:BAAALAAFFAIIAgAAAA==.',['风亦']='风亦风:BAAALAADCgYIBgAAAA==.',['风吹']='风吹蛋碎一地:BAAALAADCgUIBQAAAA==.',['风影']='风影无踪:BAAALAAECgIIAgAAAA==.',['风雨']='风雨行者:BAABLAAFFH8HAAIDAAIIBA2VqAA7AAADAAIIBA2VqAA7AAAAAA==.',['飞奔']='飞奔的鱼:BAACLAAFFH8LAAIDAAMI6g6AcQB+AAADAAMI6g6AcQB+AAAsAAQKfxoAAgMACAieHY4tAAQCAAMACAieHY4tAAQCAAAA.',['马桶']='马桶怪:BAAALAAECgYICgAAAA==.',['马特']='马特林机枪丶:BAAALAAECgIIAgAAAA==.',['骄阳']='骄阳下的玫瑰:BAAALAAFFAIIBAAAAA==.',['高启']='高启强:BAAALAAECgYIDgAAAA==.',['鬼雾']='鬼雾妖妖:BAABLAAFFH8GAAIYAAYIwgghNQA9AQAYAAYIwgghNQA9AQAAAA==.',['鲨鱼']='鲨鱼线萨七七:BAAALAAECgYICwAAAA==.',['麻辣']='麻辣牛肉米线:BAAALAAECgYIBgAAAA==.',['黑夜']='黑夜里的守护:BAAALAAECgYIBgAAAA==.黑夜里的守望:BAAALAAECgYIDAAAAA==.',['黑月']='黑月:BAABLAAFFH8GAAMeAAIIUR4aBABdAAAeAAIIUR4aBABdAAAXAAEIeQf7GwBGAAAAAA==.',['黑桃']='黑桃大佬尅:BAAALAAECgYIEAAAAA==.黑桃尖尅圈:BAAALAAECgEIAQAAAA==.',['黑眼']='黑眼圈丶道长:BAAALAAECgYIBgAAAA==.',['黑豚']='黑豚:BAAALAAECgEIAQAAAA==.',['黢龟']='黢龟的黑头:BAAALAAFFAEIAQAAAA==.',['黯嘚']='黯嘚识邓:BAAALAAECgcIEAAAAA==.',['龙御']='龙御风行者:BAAALAAECgYIBgAAAA==.',['龙飞']='龙飞凤舞:BAACLAAFFH8IAAIFAAIIlBiEWABKAAAFAAIIlBiEWABKAAAsAAQKfxYAAgUABwipImQ3AJYCAAUABwipImQ3AJYCAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end