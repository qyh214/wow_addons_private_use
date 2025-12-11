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
 local lookup = {'Druid-Guardian','Druid-Restoration','Shaman-Elemental','Shaman-Restoration','DeathKnight-Frost','DeathKnight-Blood','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','Monk-Brewmaster','Paladin-Holy','Paladin-Retribution','DemonHunter-Havoc','Warrior-Protection','Rogue-Subtlety','Rogue-Assassination','Warlock-Destruction','Warrior-Fury','Paladin-Protection','Unknown-Unknown','Mage-Arcane','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Mage-Frost','Druid-Balance','Monk-Mistweaver','Monk-Windwalker','Priest-Holy','Priest-Shadow','Shaman-Enhancement',}; local provider = {region='CN',realm='奥斯里安',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Anine:BAAALAAECgEIAQAAAA==.',Au='Austonmartin:BAABLAAECn8XAAMBAAcI0RB4EAAvAQABAAcI0RB4EAAvAQACAAYIPAZ8rgC1AAAAAA==.',Bi='Bit:BAAALAAECgEIAQAAAA==.',Da='Daedal:BAACLAAFFH8TAAMDAAMIBRpGFwD4AAADAAMIBRpGFwD4AAAEAAEIyheadgA/AAAsAAQKfyIAAwMACAgnIzsMAC0DAAMACAgnIzsMAC0DAAQAAgjXHd/9AKMAAAAA.Darkmessiah:BAACLAAFFH8GAAIFAAIIjATYnAA4AAAFAAIIjATYnAA4AAAsAAQKfx0AAwUABwi+FkcyAK4BAAUABwiSFkcyAK4BAAYABQiNDXgiAKQAAAAA.Darksouls:BAAALAAFFAgIAgAAAA==.',Do='Docter:BAAALAADCgUIBQAAAA==.',Fk='Fkryan:BAAALAAECgIIAgAAAA==.',Fr='Freezinglove:BAAALAAECgcIDwAAAA==.',Ho='Horoscope:BAAALAADCgYIBgAAAA==.',La='Lastrelax:BAABLAAFFH8RAAMHAAYIjwskRwAuAQAHAAYIjwskRwAuAQAIAAEI5wKtOQAwAAAAAA==.',Ma='Maomaodk:BAABLAAFFH8HAAIFAAMIfhv+PgC0AAAFAAMIfhv+PgC0AAAAAA==.',Pe='Peter:BAAALAADCgIIAgAAAA==.',Ri='Ric:BAAALAADCgMIAgAAAA==.',Ro='Rommyuwe:BAAALAAECgYICwAAAA==.',Sa='Saoirse:BAABLAAECn8YAAIHAAYICR72RQC8AQAHAAYICR72RQC8AQAAAA==.',So='Someone:BAACLAAFFH8YAAIEAAYIhiQYBQByAgAEAAYIhiQYBQByAgAsAAQKfx8AAgQACAitIxsKABEDAAQACAitIxsKABEDAAAA.',Sw='Swiper:BAAALAAFFAIIAwAAAA==.',Ta='Tankl:BAAALAAECgYIBgAAAA==.',Ye='Yelvet:BAAALAAFFAIIBAAAAA==.',Ze='Zeroblood:BAACLAAFFH8OAAIFAAMIqB9HKQD0AAAFAAMIqB9HKQD0AAAsAAQKfy0AAwUACAhJIy8dAPsCAAUACAgZIy8dAPsCAAkABggWIP4UAB0CAAAA.Zerohunter:BAAALAAFFAIIBAAAAA==.',Zz='Zzreight:BAABLAAFFH8RAAIKAAgISBcYBQARAgAKAAgISBcYBQARAgAAAA==.Zzreleven:BAABLAAFFH8GAAIKAAYIaRIADwBXAQAKAAYIaRIADwBXAQAAAA==.Zzrnine:BAABLAAFFH8QAAIKAAgIRhhPCADHAQAKAAgIRhhPCADHAQAAAA==.Zzrseven:BAABLAAFFH8OAAIKAAgIbhWaBQAEAgAKAAgIbhWaBQAEAgAAAA==.Zzrten:BAABLAAFFH8KAAIKAAgI7RJUBgDxAQAKAAgI7RJUBgDxAQAAAA==.',['一个']='一个女杀手:BAAALAAFFAIIAgAAAA==.',['一年']='一年望一年:BAAALAAFFAIIAgAAAA==.',['一身']='一身英雄胆:BAABLAAFFH8NAAMLAAYIex+UBwATAgALAAYIex+UBwATAgAMAAIIkBRROwChAAAAAA==.',['东城']='东城陵:BAAALAADCggICAAAAA==.',['东海']='东海三太子:BAAALAADCgMIAwAAAA==.',['东郊']='东郊到家姬师:BAAALAAECgYIDAAAAA==.东郊老妈子:BAAALAAECgEIAQAAAA==.',['丶珊']='丶珊珊来迟:BAAALAAFFAIIAgAAAA==.',['九幽']='九幽霜寒:BAAALAAECgEIAQAAAA==.',['似惊']='似惊雷丶:BAAALAAECgQIBwAAAA==.',['何似']='何似风雨:BAABLAAFFH8FAAINAAIIWh2/KgC2AAANAAIIWh2/KgC2AAAAAA==.',['保安']='保安队长:BAABLAAFFH8FAAIOAAIImwruKgBnAAAOAAIImwruKgBnAAAAAA==.',['光舞']='光舞耀阳:BAAALAAECgYIBwAAAA==.',['冰箱']='冰箱里泡面:BAAALAAFFAQIBAAAAA==.',['冰蓝']='冰蓝的绚烂:BAAALAAECgYIDwAAAA==.',['冷月']='冷月光:BAAALAAECgYIDQAAAA==.',['冻橘']='冻橘子:BAAALAADCgEIAQAAAA==.',['凛丶']='凛丶:BAAALAAFFAIIAgAAAA==.',['凝简']='凝简禅梦姗熙:BAABLAAFFH8KAAIMAAMIghTLQwCJAAAMAAMIghTLQwCJAAAAAA==.',['凯士']='凯士德里亚:BAAALAAECgYIBgAAAA==.',['医生']='医生我瞎了:BAAALAAECgYIEgAAAA==.',['半个']='半个月亮:BAAALAAECgUIBQAAAA==.',['厄勒']='厄勒忒斯:BAAALAAECgYICwAAAA==.',['双刀']='双刀就看走:BAAALAAECgIIAgAAAA==.',['含汨']='含汨加入:BAAALAAECgIIBAAAAA==.',['含泪']='含泪加入:BAACLAAFFH9MAAMPAAgIjCY0AAALAwAPAAgIjCY0AAALAwAQAAEIMwuHIgBPAAAsAAQKfy4AAg8ACAi+Jm4AAIgDAA8ACAi+Jm4AAIgDAAAA.',['吴壹']='吴壹贰:BAAALAAECgUICgAAAA==.',['周二']='周二毛:BAAALAAFFAIIBAAAAA==.',['啷个']='啷个搞:BAAALAAECgYIBgAAAA==.',['喝不']='喝不完的奶:BAABLAAFFH8JAAIHAAIIYAtCqQA6AAAHAAIIYAtCqQA6AAAAAA==.',['喵了']='喵了个米的:BAAALAAFFAEIAQAAAA==.',['回首']='回首再非少年:BAAALAADCgYIAgAAAA==.回首少年:BAAALAADCgcIBwAAAA==.回首忆少年:BAAALAAECgYIDAAAAA==.回首非少年:BAAALAAECgYIEAAAAA==.',['囨囚']='囨囚囨図:BAAALAAECgYIBgAAAA==.',['囨囡']='囨囡囨囝:BAAALAAECgYIBgAAAA==.',['图腾']='图腾牛:BAAALAADCgIIAgAAAA==.',['圣光']='圣光代言者:BAABLAAFFH8FAAIMAAIIYRHoawBAAAAMAAIIYRHoawBAAAAAAA==.圣光牛牛:BAAALAAECgUIBQAAAA==.圣光轨道炮:BAABLAAFFH8NAAIMAAYIQxtvGgCFAQAMAAYIQxtvGgCFAQAAAA==.',['堕落']='堕落的战戟:BAAALAAFFAEIAQAAAA==.',['壹皮']='壹皮:BAAALAADCgYIBgAAAA==.',['多喝']='多喝点岩浆:BAAALAADCgMIAwAAAA==.',['多弗']='多弗朗明哥:BAABLAAFFH8GAAIEAAIIRgsqWwBkAAAEAAIIRgsqWwBkAAAAAA==.',['大猎']='大猎毛:BAAALAAECgMIAwAAAA==.',['头上']='头上有鸡角:BAAALAAECgYICwAAAA==.',['奥斯']='奥斯丁格里芬:BAAALAADCgEIAQAAAA==.',['威猛']='威猛大南瓜:BAAALAAECgYIDAAAAA==.威猛大菜瓜:BAAALAAFFAIIAgAAAA==.威猛大西瓜:BAAALAAFFAIIAgAAAA==.',['安东']='安东憨憨泥:BAAALAADCgYIBgAAAA==.',['宝井']='宝井宁:BAABLAAFFH8SAAIRAAYIrhbuJACGAQARAAYIrhbuJACGAQAAAA==.',['寂静']='寂静悲傷:BAABLAAFFH8JAAIQAAMINRV6DgDuAAAQAAMINRV6DgDuAAAAAA==.',['射点']='射点什么:BAABLAAFFH8LAAIHAAMIcBiVawCLAAAHAAMIcBiVawCLAAAAAA==.',['小兔']='小兔子白又白:BAAALAADCgYIBQAAAA==.',['小小']='小小邪:BAAALAAECgYICgAAAA==.',['小萨']='小萨毛:BAAALAAECgEIAQAAAA==.',['小鸡']='小鸡出壳:BAAALAAECgYIBgAAAA==.',['小鸥']='小鸥:BAAALAAECggIDwAAAA==.',['岁月']='岁月屠夫:BAABLAAFFH8NAAISAAMIjAbePAB7AAASAAMIjAbePAB7AAAAAA==.',['幻影']='幻影撸猫手:BAABLAAFFH8IAAIHAAQIvBMlXQDPAAAHAAQIvBMlXQDPAAAAAA==.',['幻灭']='幻灭:BAAALAADCgIIAgAAAA==.',['广富']='广富林萨神:BAAALAAECgYIBgAAAA==.',['弹射']='弹射起步:BAAALAAECgMIBQAAAA==.',['强子']='强子哥:BAAALAAECgUIBwAAAA==.',['快感']='快感炮神:BAAALAAECgYICAAAAA==.',['怅然']='怅然:BAAALAAECggICAAAAA==.',['恶魔']='恶魔猎首:BAAALAAECgQIBAAAAA==.',['想屁']='想屁吃的贼总:BAAALAAECggICQAAAA==.',['愤怒']='愤怒伏特加:BAAALAAFFAIIAgAAAA==.愤怒的钢板:BAAALAAFFAIIAwAAAA==.',['憨得']='憨得一批:BAAALAAECgYICQAAAA==.',['我不']='我不够持久:BAAALAAECggICAABLAAFFAYIBgAMAKEIAA==.',['我是']='我是大萌德:BAAALAAECgEIAQAAAA==.',['我真']='我真的很怪:BAAALAAECgEIAQAAAA==.',['执着']='执着的铁锤:BAABLAAFFH8GAAITAAIIugl/HABrAAATAAIIugl/HABrAAAAAA==.',['抓猫']='抓猫的老鼠:BAAALAAECgYIBgAAAA==.',['掌上']='掌上幼虎:BAAALAAECgUIBQAAAA==.掌上老虎:BAAALAAFFAMIAgAAAA==.掌上萌虎:BAAALAAECggIBgAAAA==.',['摸摸']='摸摸唱大师:BAAALAAFFAIIAgAAAA==.',['撒斯']='撒斯费罗:BAAALAAECgYIDAAAAA==.',['斯文']='斯文的:BAAALAAFFAIIAQAAAA==.',['新岛']='新岛冴:BAABLAAECn8ZAAINAAYI5Ry4ZQD9AQANAAYI5Ry4ZQD9AQABLAAFFAIIAgAUAAAAAA==.',['旅店']='旅店老板娘:BAABLAAFFH8PAAINAAYI2x5wEgDNAQANAAYI2x5wEgDNAQABLAAFFAgIDAALAKUUAA==.',['早乙']='早乙女道:BAABLAAFFH8KAAIRAAYI5g3OHwApAQARAAYI5g3OHwApAQAAAA==.',['昕诚']='昕诚:BAABLAAFFH8KAAIVAAYI8hRMJgB7AQAVAAYI8hRMJgB7AQAAAA==.',['春哥']='春哥夸我帅:BAAALAAECgEIAQAAAA==.',['晚鸢']='晚鸢枫华:BAABLAAFFH8YAAIHAAYIIhTPMwBsAQAHAAYIIhTPMwBsAQAAAA==.',['暗魂']='暗魂哀歌:BAACLAAFFH8nAAIEAAYIqht/EADiAQAEAAYIqht/EADiAQAsAAQKfyIAAgQACAjsIFsTANcCAAQACAjsIFsTANcCAAAA.',['朋友']='朋友是彩笔:BAAALAAECgYIBAAAAA==.',['机子']='机子酱:BAAALAADCgcIBwAAAA==.',['杯酒']='杯酒释人生:BAAALAAECgYIBgAAAA==.',['果然']='果然不是:BAAALAADCggIEAAAAA==.',['柳贯']='柳贯一:BAAALAAECgEIAQABLAAFFAIIAgAUAAAAAA==.',['格兰']='格兰帝亚:BAAALAAECgUICQAAAA==.',['桃子']='桃子酱:BAABLAAFFH8GAAMFAAMIYwGUiABCAAAFAAMICwGUiABCAAAGAAIISQHSHwAeAAAAAA==.',['梅里']='梅里东风:BAAALAADCgIIAgAAAA==.',['橙色']='橙色:BAABLAAFFH8eAAMTAAYIehkWBQCRAQATAAYIUhkWBQCRAQAMAAYIZBPKGgCEAQAAAA==.',['欧洲']='欧洲大祭司:BAAALAAECgYIEwAAAA==.',['死神']='死神眷恋:BAABLAAFFH8IAAIEAAIIpRl1RwCQAAAEAAIIpRl1RwCQAAAAAA==.',['殇城']='殇城天命:BAAALAAECgYIBgAAAA==.',['残阳']='残阳老沫:BAAALAAECgEIAQAAAA==.',['母牛']='母牛太妖娆:BAACLAAFFH8fAAIMAAUI3RxvIQBgAQAMAAUI3RxvIQBgAQAsAAQKfxQAAgwABghoJBQlAAICAAwABghoJBQlAAICAAAA.',['比安']='比安卡丶深痕:BAAALAAECgYIBgAAAA==.',['没脑']='没脑袋:BAABLAAFFH8TAAQWAAYI9B4+AgAtAgAWAAYI9B4+AgAtAgAXAAUI0w6CAwCVAQAYAAEIqgegJAA/AAAAAA==.',['泪中']='泪中名:BAAALAAECgYIBgAAAA==.',['洛瑟']='洛瑟玛灬祭風:BAABLAAECn8gAAIEAAYItiLDGwAVAgAEAAYItiLDGwAVAgAAAA==.',['流氓']='流氓兔斯基:BAABLAAFFH8qAAMVAAYI7xn3HgCbAQAVAAYI7xn3HgCbAQAZAAEIaAuFIQA9AAAAAA==.流氓兔斯基喔:BAABLAAFFH8ZAAIFAAYISgy9NgBgAQAFAAYISgy9NgBgAQAAAA==.',['海王']='海王的王:BAAALAAFFAEIAQAAAA==.',['淑漱']='淑漱:BAAALAAFFAIIAgAAAA==.',['深藏']='深藏功与名:BAAALAAFFAMIAwAAAA==.',['清晨']='清晨点支烟:BAAALAAFFAIIAgAAAA==.清晨点根烟:BAABLAAFFH8PAAIMAAYIOCA8DgDSAQAMAAYIOCA8DgDSAQABLAAFFAgIDAALAKUUAA==.',['漫步']='漫步灬云端:BAAALAADCgMIAwAAAA==.',['潘朵']='潘朵拉魔盒:BAAALAAECgYICwAAAA==.',['火锅']='火锅:BAABLAAFFH8MAAIMAAMIVBtuPQCdAAAMAAMIVBtuPQCdAAAAAA==.',['灭霸']='灭霸之星:BAAALAAFFAIIBAAAAA==.',['炒娃']='炒娃蒜头:BAAALAAECgUIBQAAAA==.',['炽热']='炽热防御者:BAAALAAECgYICAAAAA==.',['烈咬']='烈咬陆鲨:BAABLAAFFH8KAAINAAYIiRZkIQB6AQANAAYIiRZkIQB6AQAAAA==.',['焱火']='焱火来点冰:BAAALAAFFAIIAgAAAA==.',['照烧']='照烧小丸子:BAABLAAECn8UAAMaAAYIaQ6WMwD0AAAaAAYIaQ6WMwD0AAACAAYI/ws0ngDZAAAAAA==.',['熊猫']='熊猫布布:BAABLAAFFH8OAAMSAAYIQgc3LAD/AAASAAUIHwg3LAD/AAAOAAEI7gJ4NAAtAAAAAA==.',['爆击']='爆击灭烟:BAABLAAECn8WAAICAAgIJxL+LQB4AQACAAgIJxL+LQB4AQAAAA==.',['爱德']='爱德华纽盖特:BAAALAAECggICAAAAA==.',['牛儿']='牛儿响叮当:BAABLAAFFH8HAAISAAQI2BuQIQBgAQASAAQI2BuQIQBgAQABLAAFFAgIDAALAKUUAA==.',['狂热']='狂热的铁剑:BAAALAAFFAIIAgAAAA==.',['狂野']='狂野伏特加:BAABLAAFFH8KAAIHAAQIlA5yXwDDAAAHAAQIlA5yXwDDAAAAAA==.',['狐狸']='狐狸捉小鸡:BAABLAAFFH8GAAIVAAYIYCBQBQBSAgAVAAYIYCBQBQBSAgAAAA==.',['王嘉']='王嘉熙:BAACLAAFFH82AAIbAAYIriJDAwBKAgAbAAYIriJDAwBKAgAsAAQKfysAAxsACAh2JfIBAFIDABsACAh2JfIBAFIDABwAAQhABTNtAC8AAAAA.',['玫瑰']='玫瑰酱:BAAALAAFFAIIBAAAAA==.',['瑝镞']='瑝镞牛:BAABLAAFFH8IAAICAAIIIweGTwBUAAACAAIIIweGTwBUAAAAAA==.',['画大']='画大饼:BAAALAAECgQIBAAAAA==.',['白昼']='白昼:BAAALAAFFAIIBAAAAA==.',['皮皮']='皮皮:BAAALAAECgUIAgAAAA==.',['相见']='相见不欢:BAAALAAECgYICgAAAA==.',['矢泽']='矢泽妮可:BAAALAAFFAIIAwAAAA==.',['破晓']='破晓:BAACLAAFFH8QAAIVAAMIviO3IAAlAQAVAAMIviO3IAAlAQAsAAQKfxgAAhUACAhKIwYWAP8CABUACAhKIwYWAP8CAAAA.',['碧蚕']='碧蚕毒蛊:BAAALAAFFAIIAgAAAA==.',['神圣']='神圣的爱:BAAALAAFFAIIAgAAAA==.',['秦百']='秦百胜:BAAALAAFFAIIAgAAAA==.',['红手']='红手我来也:BAAALAAECgIIAwAAAA==.',['细嗅']='细嗅蔷薇:BAAALAAFFAIIBAAAAA==.',['绫零']='绫零:BAAALAAECgYIBwAAAA==.',['绫香']='绫香:BAAALAAECgYIBgAAAA==.',['罗卡']='罗卡德木木:BAAALAAECgMIBQAAAA==.',['美美']='美美:BAAALAAECgYICwAAAA==.',['翻车']='翻车老司机:BAAALAAECgYIBgAAAA==.',['聖斗']='聖斗士:BAAALAADCgQIBAAAAA==.',['胯间']='胯间暴击:BAAALAAECgEIAQAAAA==.',['自恋']='自恋长发飘:BAACLAAFFH8oAAISAAYIOB4TEwDBAQASAAYIOB4TEwDBAQAsAAQKfyEAAhIACAg5IEEcAOACABIACAg5IEEcAOACAAAA.',['至臻']='至臻牧司:BAAALAAECggIDQAAAA==.',['艾尔']='艾尔斯:BAABLAAECn8VAAIRAAgIRQmcRwAsAQARAAgIRQmcRwAsAQAAAA==.',['艾沙']='艾沙克:BAAALAAECgYICgAAAA==.',['芋泥']='芋泥厚厚牛奶:BAABLAAFFH8GAAIMAAYIVgirKgArAQAMAAYIVgirKgArAQABLAAFFAgIDAALAKUUAA==.',['芝士']='芝士莓莓茶:BAABLAAFFH8GAAIHAAYIwgTPWwDWAAAHAAYIwgTPWwDWAAAAAA==.',['英勇']='英勇:BAAALAAECgYICwAAAA==.',['莱克']='莱克糖:BAAALAAECgIIAgAAAA==.',['菜小']='菜小四:BAAALAAECgYICAAAAA==.',['萨顶']='萨顶顶:BAAALAADCgMIAwAAAA==.',['落寞']='落寞年华霜钰:BAAALAAFFAIIAgAAAA==.',['血色']='血色迷恋:BAAALAADCggICAAAAA==.',['血落']='血落:BAABLAAFFH8JAAIMAAMI+BfIQgCMAAAMAAMI+BfIQgCMAAAAAA==.',['西野']='西野:BAAALAADCgQIBAAAAA==.',['言出']='言出法随:BAAALAADCggIFAAAAA==.',['诺贝']='诺贝尔火焰奖:BAAALAAECgIIAgAAAA==.',['贱死']='贱死不救:BAACLAAFFH8fAAIdAAUI2BI1HwBQAQAdAAUI2BI1HwBQAQAsAAQKfywAAx0ACAh0HC4OAG4CAB0ACAh0HC4OAG4CAB4ABwhxFlocAGQBAAAA.',['贵宾']='贵宾楼上请:BAAALAAFFAIIAgAAAA==.',['赤小']='赤小豆:BAAALAAECgYIBgAAAA==.',['跑跑']='跑跑法叶:BAAALAAFFAIIAgABLAAFFAIIAgAUAAAAAA==.',['踏雪']='踏雪丨凝梦:BAABLAAFFH8IAAIVAAMIwBIzRwCFAAAVAAMIwBIzRwCFAAAAAA==.',['进化']='进化吧小火龙:BAAALAADCgQIBAAAAA==.',['造纸']='造纸龙:BAAALAADCgYIBgAAAA==.',['遇术']='遇术临瘋:BAABLAAFFH8GAAIRAAIIUgWLagA2AAARAAIIUgWLagA2AAAAAA==.',['邪恶']='邪恶小王子:BAAALAAECgYIBgAAAA==.',['邪能']='邪能伏特加:BAACLAAFFH8nAAINAAYIyhU+GgCfAQANAAYIyhU+GgCfAQAsAAQKfxkAAg0ACAiVGxQ6AHcCAA0ACAiVGxQ6AHcCAAAA.',['酷棋']='酷棋:BAABLAAFFH8LAAIFAAUI0BLZRQAjAQAFAAUI0BLZRQAjAQAAAA==.',['酷酷']='酷酷的鱼小:BAAALAADCgEIAQAAAA==.',['酸辣']='酸辣土豆丝:BAAALAAECgQIBQABLAAFFAIIAgAUAAAAAA==.',['醉爱']='醉爱:BAAALAAECgQIBAAAAA==.',['钴毛']='钴毛头:BAAALAAECgYIBgAAAA==.',['银河']='银河美少年:BAAALAAECgYIBgAAAA==.',['销魂']='销魂大师:BAAALAADCgEIAQAAAA==.',['错误']='错误:BAAALAAFFAIIAgAAAA==.',['镍毛']='镍毛头:BAAALAAECgEIAQABLAAECgYIBgAUAAAAAA==.',['闪光']='闪光光:BAABLAAFFH8SAAMfAAUIYBA8BADSAAADAAUIPg2PKgDrAAAfAAQIrAo8BADSAAAAAA==.闪光的冬季:BAAALAAECgMIAwAAAA==.',['阿塔']='阿塔澜忒:BAABLAAECn8UAAIHAAYIIBzKVgCVAQAHAAYIIBzKVgCVAQAAAA==.',['阿曼']='阿曼苏尔的妈:BAAALAAECgYIBgAAAA==.',['随候']='随候斩:BAAALAAFFAIIAgAAAA==.',['雀斑']='雀斑小白猪:BAAALAADCgYIBgAAAA==.',['雪华']='雪华风暴烈酒:BAAALAAECgMIAwAAAA==.',['零六']='零六灯笼:BAAALAAECgEIAQAAAA==.',['雾都']='雾都赛力斯:BAAALAADCgIIAgAAAA==.',['霜天']='霜天月:BAAALAAECggICAAAAA==.',['青萍']='青萍丶承影:BAAALAAFFAYIAgAAAA==.',['颓废']='颓废的温存:BAAALAAECgIIAgAAAA==.',['飘渺']='飘渺逸:BAAALAAECgYIBgAAAA==.',['饭饭']='饭饭扫尾:BAACLAAFFH8OAAITAAMIgQnSDQCoAAATAAMIgQnSDQCoAAAsAAQKfxYAAhMACAjGFC0iAOkBABMACAjGFC0iAOkBAAEsAAUUBggTABYA9B4A.',['香蕉']='香蕉你个扒拉:BAABLAAECn8WAAINAAYIfhP2rQB1AQANAAYIfhP2rQB1AQAAAA==.',['驼鹿']='驼鹿角:BAABLAAFFH8TAAICAAMInxLzIwCXAAACAAMInxLzIwCXAAAAAA==.',['高须']='高须龙儿:BAAALAAECgYIBwAAAA==.',['鬼狼']='鬼狼舞妖:BAAALAAECgYICwAAAA==.',['魔圣']='魔圣王:BAAALAADCgQIBAAAAA==.',['黑月']='黑月之潮:BAABLAAFFH8IAAIFAAYIyBdxMQB1AQAFAAYIyBdxMQB1AQAAAA==.',['黑豹']='黑豹:BAAALAAECgYIBwAAAA==.',['龍丶']='龍丶:BAABLAAFFH8EAAIMAAIIziOWIQDLAAAMAAIIziOWIQDLAAAAAA==.',['龙洺']='龙洺:BAABLAAFFH8QAAINAAYI6R3NBgAwAgANAAYI6R3NBgAwAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end