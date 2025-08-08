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
 local lookup = {'Priest-Discipline','Monk-Windwalker','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Destruction','Warlock-Demonology','Shaman-Restoration','Druid-Balance','Mage-Fire','Warrior-Arms','Warrior-Fury','Paladin-Retribution','Druid-Feral','Rogue-Assassination','Warlock-Affliction','Monk-Mistweaver','DeathKnight-Frost','Priest-Shadow','Unknown-Unknown','Paladin-Protection','Priest-Holy','Hunter-Marksmanship','Druid-Restoration','Hunter-BeastMastery','Mage-Frost','Mage-Arcane','Monk-Brewmaster','Warrior-Protection','DemonHunter-Havoc','Druid-Guardian','Hunter-Survival','DemonHunter-Vengeance','Shaman-Elemental',}; local provider = {region='CN',realm='艾森娜',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Actualrisk:BAAAKgAECgUIBQAAAA==.',Ba='Banshee:BAABKgAFFH8RAAIBAAQICxCdFQCyAAABAAQICxCdFQCyAAAAAA==.',De='Desdemona:BAAAKgAECggICAAAAA==.',Di='Diary:BAAAKgAECggICwAAAA==.',Em='Emilia:BAAAKgAECgYIBgAAAA==.',Fe='Fenixone:BAABKgAFFH8EAAICAAQIlwVzGwCNAAACAAQIlwVzGwCNAAAAAA==.',In='Infj:BAAAKgAECgQIBgAAAA==.',Ir='Ironic:BAAAKgAFFAQIBAAAAA==.',Ma='Mar:BAAAKgAECgIIAgAAAA==.',Ms='Msuoon:BAAAKgAECgQIBAAAAA==.',Or='Orz:BAAAKgAECggICQAAAA==.',Pl='Playergxidub:BAAAKgAECgMIAwAAAA==.',Re='Re:BAABKgAFFH8NAAMDAAYIPx2dAwCeAQADAAYIPx2dAwCeAQAEAAUIZQ+gFwDkAAAAAA==.',Sp='Spiky:BAABKgAFFH8RAAMFAAgIAyIyAwCYAQAFAAgIjB8yAwCYAQAGAAEI9iWnIABfAAAAAA==.',['一亚']='一亚马逊一:BAAAKgAECgYICQAAAA==.',['一安']='一安:BAACKgAFFH8LAAIHAAQIbCRMBAA+AQAHAAQIbCRMBAA+AQAqAAQKfykAAgcACAhFImoHAFcCAAcACAhFImoHAFcCAAAA.',['一梦']='一梦两三年:BAABKgAFFH8UAAIIAAQI2yPRFAAUAQAIAAQI2yPRFAAUAQABKgAFFAgIUAAIABcmAA==.',['万卷']='万卷云:BAAAKgAECgYIBgAAAA==.',['不可']='不可宽恕:BAAAKgAFFAgIBAAAAA==.',['不组']='不组惩戒骑:BAAAKgADCggICAAAAA==.',['两条']='两条丶毛腿:BAAAKgAECgIIAgAAAA==.',['丨夜']='丨夜舞清秋:BAAAKgAECgUIBQAAAA==.',['丨妖']='丨妖妖丨:BAAAKgAECgYICgAAAA==.',['丨姜']='丨姜珏丨:BAAAKgAECgYICgAAAA==.',['为了']='为了崇高正义:BAAAKgADCgIIAgAAAA==.',['丿爲']='丿爲誰而戰丨:BAAAKgAECgIIAgAAAA==.',['乃琳']='乃琳:BAABKgAFFH8JAAIJAAgIKRoABQAxAgAJAAgIKRoABQAxAgAAAA==.',['九灯']='九灯灬长歌:BAACKgAFFH8gAAMKAAgIyBciAQDCAQALAAgIeRNgBwDtAQAKAAYIKxoiAQDCAQAqAAQKfxcAAgoACAgYHKUNAFMCAAoACAgYHKUNAFMCAAAA.',['云栖']='云栖松子糖:BAABKgAFFH8OAAMFAAYINBYRDAAAAQAFAAUIChoRDAAAAQAGAAMIeA4ZGgCAAAAAAA==.',['亚洲']='亚洲舞王:BAAAKgADCgQIBAAAAA==.',['仙丨']='仙丨羽:BAAAKgAECgIIAgAAAA==.',['伊万']='伊万卡梅尔:BAAAKgADCggIEAAAAA==.伊万杰琳莉莉:BAAAKgADCggICAAAAA==.',['伊兰']='伊兰特智界:BAABKgAECn8eAAILAAgIWA0MOQA+AQALAAgIWA0MOQA+AQAAAA==.',['伊莎']='伊莎贝拉问界:BAAAKgAECgcICwAAAA==.',['伊达']='伊达航:BAABKgAECn8lAAIMAAgIHiPOMAA8AgAMAAgIHiPOMAA8AgABKgAFFAgIMAANAHIiAA==.',['休闲']='休闲玩家随意:BAAAKgAFFAYIBAAAAA==.',['信仰']='信仰丶圣光吧:BAAAKgADCggICAAAAA==.',['元曦']='元曦:BAAAKgAECgcICwAAAA==.',['光合']='光合作用:BAAAKgADCggICAAAAA==.',['八尺']='八尺男儿:BAAAKgADCgQIBAAAAA==.',['六月']='六月十柒:BAAAKgAECggIDAAAAA==.',['再握']='再握屠刀:BAABKgAFFH8HAAIOAAcIZQ0xDQB7AQAOAAcIZQ0xDQB7AQAAAA==.',['冲天']='冲天一口:BAAAKgAECgYIBgAAAA==.',['冷酷']='冷酷心灵:BAAAKgAECggIEQAAAA==.',['凄凉']='凄凉的乌米:BAABKgAFFH8NAAMPAAMINA66CwCHAAAPAAIIuRK6CwCHAAAFAAIIYAb6PwBtAAAAAA==.',['凌晨']='凌晨四点:BAAAKgADCgYIBgAAAA==.',['凤之']='凤之断翼:BAAAKgAFFAcIAwAAAA==.',['凯蕾']='凯蕾莉娅:BAAAKgADCggICAAAAA==.',['副节']='副节龙出击:BAABKgAFFH8GAAIQAAQIIg8/FADSAAAQAAQIIg8/FADSAAAAAA==.',['北极']='北极之魔:BAAAKgAECgcIBwAAAA==.北极极:BAACKgAFFH8HAAIDAAcI5AVWDABAAQADAAcI5AVWDABAAQAqAAQKfx0AAwQACAiaBEdLAI8AAAQABghJBkdLAI8AABEACAhBAIY8AAIAAAAA.',['千语']='千语话禅:BAAAKgAECgQIBAAAAA==.',['千雪']='千雪:BAABKgAFFH8QAAIHAAMIrhTcLADDAAAHAAMIrhTcLADDAAAAAA==.',['午夜']='午夜小奶嘴:BAABKgAFFH8GAAISAAYIPh0zAQDqAQASAAYIPh0zAQDqAQAAAA==.',['又一']='又一只狗:BAAAKgAFFAMIBAAAAA==.',['反复']='反复传送小明:BAAAKgAFFAMIAwAAAA==.反复攻击小明:BAAAKgAFFAIIAwABKgAFFAMIAwATAAAAAA==.',['只想']='只想安静做狗:BAAAKgAECgQIBAAAAA==.',['可以']='可以不吃肉么:BAABKgAFFH8IAAIDAAgIUQGdEQDeAAADAAgIUQGdEQDeAAAAAA==.',['吉田']='吉田步美:BAACKgAFFH8wAAINAAgIciJEAADUAgANAAgIciJEAADUAgAqAAQKf0YAAg0ACAizJk8AABoDAA0ACAizJk8AABoDAAAA.',['告诉']='告诉过你:BAAAKgADCgYIDAAAAA==.',['呢喃']='呢喃:BAAAKgAECggICgABKgAFFAgIKQAHAAcjAA==.',['和气']='和气勿喷:BAABKgAFFH8FAAIMAAUIyxHjMwAaAQAMAAUIyxHjMwAaAQAAAA==.',['咕嘟']='咕嘟:BAACKgAFFH8GAAIMAAMI0w9JVADIAAAMAAMI0w9JVADIAAAqAAQKfxoAAwwACAjtG0dLABACAAwACAjtG0dLABACABQAAQgfFHxSADkAAAEqAAUUCAgpAAcAByMA.',['唯为']='唯为君倾:BAAAKgAFFAYIBAAAAA==.',['土拨']='土拨鼠吖丶:BAAAKgAECggICAAAAA==.',['圣光']='圣光忽悠你:BAAAKgADCggICAAAAA==.圣光梵尘:BAABKgAFFH8GAAIMAAYIpBIiEwBsAQAMAAYIpBIiEwBsAQAAAA==.圣光重现:BAACKgAFFH8UAAIMAAMIdh0jPQD6AAAMAAMIdh0jPQD6AAAqAAQKfyMAAgwACAgKH/wrAE8CAAwACAgKH/wrAE8CAAAA.',['圣神']='圣神意念:BAAAKgAECgYIBgAAAA==.',['塔娜']='塔娜亚:BAAAKgAECgMIAwAAAA==.',['壮士']='壮士且慢:BAAAKgAECggIBwAAAA==.',['壳壳']='壳壳:BAAAKgAECgcIBwAAAA==.',['夏夜']='夏夜朗朗:BAAAKgAECgEIAQAAAA==.',['夕姐']='夕姐:BAAAKgAFFAQIBAAAAA==.',['夜丶']='夜丶魅颖:BAABKgAFFH8KAAMSAAgIxRZwBgC/AQASAAcINRlwBgC/AQAVAAEICBxqPQBGAAAAAA==.',['大司']='大司寇:BAABKgAECn8YAAIMAAYI7Au9SwDXAAAMAAYI7Au9SwDXAAAAAA==.',['大王']='大王庄吴彦祖:BAABKgAFFH8KAAMFAAgIqx4cBQBMAgAFAAgIqx4cBQBMAgAGAAEIKgYiLgA/AAAAAA==.大王庄火车王:BAABKgAFFH8IAAIWAAgIOweRDgB2AQAWAAgIOweRDgB2AQAAAA==.',['天澄']='天澄:BAAAKgAFFAIIAgAAAA==.',['奥德']='奥德美:BAAAKgAECgMIAwAAAA==.',['奥莱']='奥莱利亚:BAAAKgAFFAIIBAAAAA==.奥莱萨满:BAAAKgAECggIDAAAAA==.',['奶龙']='奶龙咆哮:BAAAKgADCggICAAAAA==.',['妖艳']='妖艳惑众:BAAAKgAFFAIIAgAAAA==.',['妳豆']='妳豆子丶:BAABKgAECn8lAAMFAAgINxo9HwCwAQAFAAgI9Bk9HwCwAQAGAAQIBhOwRgDYAAAAAA==.',['子如']='子如云:BAAAKgAECggIDQAAAA==.',['守护']='守护艾森娜:BAAAKgAFFAEIAQAAAA==.',['寒夜']='寒夜青风:BAABKgAFFH8LAAMIAAYI6hMoAwCcAQAIAAYI6hMoAwCcAQAXAAUIlSD1CAB4AQAAAA==.',['封印']='封印堕落:BAABKgAFFH8KAAMUAAYI/RnCAgBXAQAUAAYI7RLCAgBXAQAMAAQIoyRNCwAoAQAAAA==.',['小橘']='小橘呢:BAAAKgAFFAQIBAAAAA==.',['小燕']='小燕子:BAAAKgAECgYIBgAAAA==.',['小生']='小生好帅:BAAAKgAECgQIBAAAAA==.小生好怕:BAAAKgAECgcIBwAAAA==.小生龙娃:BAAAKgAECgYIBgAAAA==.',['尚轩']='尚轩:BAABKgAFFH8GAAMVAAYI4w51GADzAAAVAAUI/RF1GADzAAASAAEI2QaNLQA/AAABKgAFFAgIBgASAHQcAA==.',['尤勇']='尤勇:BAAAKgAECggIDgAAAA==.',['就是']='就是清新:BAAAKgAECgYIBgAAAA==.',['岁月']='岁月游魂:BAAAKgAECgYICwAAAA==.',['嵇康']='嵇康:BAAAKgAECggIEQAAAA==.',['布鲁']='布鲁斯邢:BAAAKgAFFAgIAgAAAA==.',['希望']='希望人没事:BAABKgAFFH8GAAIEAAYIsgz3FQDxAAAEAAYIsgz3FQDxAAABKgAFFAgIIAAEAFUQAA==.',['平凡']='平凡的平凡:BAABKgAFFH8GAAIWAAYIqhkNEQBdAQAWAAYIqhkNEQBdAQAAAA==.',['年轻']='年轻的信赖:BAABKgAECn8WAAIUAAgIgRwOFwC1AQAUAAgIgRwOFwC1AQAAAA==.',['幽眀']='幽眀孤神:BAABKgAECn8cAAILAAcIpxsHJgD3AQALAAcIpxsHJgD3AQAAAA==.',['异度']='异度装甲:BAAAKgAECggIDQAAAA==.',['弗洛']='弗洛一德:BAABKgAFFH8GAAIXAAYIMQ6fDgAsAQAXAAYIMQ6fDgAsAQAAAA==.',['彩霞']='彩霞:BAAAKgAECgYIBwAAAA==.',['影月']='影月晴空:BAAAKgAFFAEIAQAAAA==.',['往日']='往日岁月:BAAAKgAECgQIBAAAAA==.往日记忆:BAAAKgAECgYICgAAAA==.',['德勒']='德勒克斯汀:BAAAKgAFFAgIBAAAAA==.',['急急']='急急大狂风:BAAAKgADCggICAAAAA==.',['怪蜀']='怪蜀黍老司机:BAAAKgAECgIIAgAAAA==.',['愤怒']='愤怒橘子:BAAAKgADCgIIAgAAAA==.',['我不']='我不是傲天:BAAAKgAECgYICAAAAA==.',['披萨']='披萨心肠:BAABKgAFFH8IAAMMAAgIxwMYFwA0AQAMAAcIaAQYFwA0AQAUAAEIAgDwFwAAAAAAAA==.',['数智']='数智术:BAABKgAFFH8QAAIFAAMIBAbjOACMAAAFAAMIBAbjOACMAAAAAA==.',['星殒']='星殒:BAAAKgAFFAYIBAAAAA==.',['星空']='星空下的旋律:BAAAKgAECgYIBwAAAA==.',['智信']='智信大师:BAAAKgAECgIIAwAAAA==.',['暖了']='暖了个暖:BAABKgAFFH8GAAIIAAYIGR4SDQDFAQAIAAYIGR4SDQDFAQAAAA==.',['曙光']='曙光丶:BAABKgAFFH8GAAIMAAYISgdILgAvAQAMAAYISgdILgAvAQAAAA==.',['曾今']='曾今陌生:BAAAKgAECgYIDAAAAA==.',['月神']='月神灬长歌:BAABKgAFFH8IAAIMAAYIBhRWJwBLAQAMAAYIBhRWJwBLAQAAAA==.',['月舞']='月舞若若:BAAAKgADCgUIBQAAAA==.',['月落']='月落诗无痕:BAAAKgAECggIBAAAAA==.',['月薰']='月薰灬长歌:BAAAKgAECgQIBAAAAA==.',['朱雀']='朱雀含珠:BAAAKgAFFAYIBAAAAA==.',['极限']='极限特工:BAAAKgAECgUIBQAAAA==.',['柔晴']='柔晴绕指柔:BAAAKgAECgUIBQAAAA==.',['柳如']='柳如烟:BAAAKgADCggICAAAAA==.',['桑塔']='桑塔纳:BAABKgAECn8ZAAMYAAYIIg+odwDxAAAYAAYIeg2odwDxAAAWAAEIFhDTpwAwAAAAAA==.',['梅干']='梅干菜扣肉:BAAAKgADCgEIAQAAAA==.',['梅赛']='梅赛德斯:BAAAKgAECggIEQAAAA==.',['梦想']='梦想之光:BAAAKgAECgYIDQAAAA==.',['梦紫']='梦紫瞳:BAAAKgAFFAEIAQAAAA==.',['極樂']='極樂仙貝:BAACKgAFFH8kAAMNAAcIiiAzAQD0AQANAAYIiiAzAQD0AQAIAAEIAABJZwAAAAAqAAQKfzYAAw0ACAgAI2wEAJ0CAA0ACAgAI2wEAJ0CAAgAAQgAAFTfAAAAAAAA.',['橙子']='橙子酱:BAAAKgAECgcIBwAAAA==.',['欧洲']='欧洲舞王:BAAAKgADCgUICAAAAA==.',['正义']='正义审判者:BAAAKgAECgUIBQAAAA==.',['正在']='正在载入中:BAAAKgAECggIDAAAAA==.',['残影']='残影:BAAAKgADCggICAAAAA==.',['汉鼎']='汉鼎:BAABKgAFFH8KAAIHAAMIpQ9FPACVAAAHAAMIpQ9FPACVAAAAAA==.',['江南']='江南顶住:BAAAKgAECgcIDQAAAA==.',['沉睡']='沉睡的小猫:BAAAKgAFFAgIBAAAAA==.',['沙洋']='沙洋那拉:BAAAKgAECggICAAAAA==.',['法号']='法号:BAAAKgAECgIIAgAAAA==.',['法落']='法落梵尘:BAABKgAFFH8IAAMZAAYIXhunDADIAAAZAAQI8xSnDADIAAAaAAQIzhcwBQCKAAAAAA==.',['泪人']='泪人:BAABKgAFFH8GAAMWAAMImgVoQAB4AAAWAAMImgVoQAB4AAAYAAEItAELUwApAAAAAA==.',['流风']='流风易痕:BAAAKgAECgQIBwAAAA==.',['浮萍']='浮萍寄清水:BAAAKgAECgIIAgAAAA==.',['清风']='清风铃醉影:BAAAKgAECgIIAgAAAA==.',['溜溜']='溜溜球:BAABKgAFFH8GAAIMAAYI1QuNMQAjAQAMAAYI1QuNMQAjAQAAAA==.',['火酒']='火酒灬长歌:BAACKgAFFH8dAAMQAAgIohufBAATAgAQAAgIohufBAATAgACAAIIsQIWIwAvAAAqAAQKfxkABBAACAhcInYIAK0CABAACAhcInYIAK0CAAIACAg/FWggANsBABsACAiNEuwQADABAAAA.',['灬汐']='灬汐瞳灬:BAAAKgADCggICAAAAA==.',['灼热']='灼热双目:BAAAKgAFFAQIBAAAAA==.',['炖虾']='炖虾大王:BAACKgAFFH8LAAMWAAYIDxzVEABfAQAWAAYIoRjVEABfAQAYAAUIexvlEQAFAQAqAAQKfyAAAhgACAirImgQAKMCABgACAirImgQAKMCAAEqAAUUCAgEABMAAAAA.',['炜冉']='炜冉:BAABKgAFFH8FAAIcAAMIWgLvEwBcAAAcAAMIWgLvEwBcAAAAAA==.',['烟花']='烟花雪:BAABKgAFFH8IAAMVAAYISBofFgAEAQAVAAQIECMfFgAEAQABAAQIcQcQIQCfAAAAAA==.',['热心']='热心市民:BAAAKgAECggICwAAAA==.',['爱咬']='爱咬人的宝宝:BAABKgAECn8WAAIQAAgIMAoXQgA4AQAQAAgIMAoXQgA4AQAAAA==.',['爱因']='爱因思念:BAAAKgAECgUIDAAAAA==.',['爱莉']='爱莉希雅:BAABKgAFFH8TAAMMAAgIQCN3DAAFAgAMAAcItSR3DAAFAgAUAAYI3glOBQAVAQAAAA==.',['狂傲']='狂傲不羁:BAAAKgAECgYIBgAAAA==.',['狄玫']='狄玫:BAABKgAECn8VAAIMAAgIUQ/TlgBpAQAMAAgIUQ/TlgBpAQAAAA==.',['玛格']='玛格丽特哈利:BAAAKgADCgUIBQAAAA==.',['珀琉']='珀琉斯晨风:BAAAKgAFFAIIAgAAAA==.',['琴瑟']='琴瑟:BAACKgAFFH8pAAIHAAgIByP9AQBiAgAHAAgIByP9AQBiAgAqAAQKfysAAgcACAivIvoLAJcCAAcACAivIvoLAJcCAAAA.',['瓦丁']='瓦丁米儿猎豹:BAAAKgADCgQIBAAAAA==.',['瓦洛']='瓦洛伽:BAAAKgAECgEIAQAAAA==.瓦洛嘉:BAAAKgAECgEIAQAAAA==.',['瓦罗']='瓦罗嘉:BAAAKgADCggICAAAAA==.瓦罗葭:BAAAKgAECgQIBQAAAA==.',['瘦不']='瘦不了一点:BAAAKgAECgIIAgAAAA==.',['白煞']='白煞浩杰:BAAAKgAECgUIBQAAAA==.',['百兽']='百兽精灵王:BAAAKgAECgQIBAAAAA==.',['百花']='百花熊:BAACKgAFFH8RAAIbAAMIgAJeCgBfAAAbAAMIgAJeCgBfAAAqAAQKfxkAAhsABwj3BSsYAKoAABsABwj3BSsYAKoAAAAA.',['看死']='看死你:BAACKgAFFH8HAAIdAAQI9h9QDwADAQAdAAQI9h9QDwADAQAqAAQKfyIAAh0ACAgfIKk2ANEBAB0ACAgfIKk2ANEBAAEqAAUUCAgNAAMArh0A.',['石三']='石三牙:BAABKgAFFH8GAAIeAAMI1QWQBgBmAAAeAAMI1QWQBgBmAAAAAA==.',['神圣']='神圣企鹅:BAABKgAECn8ZAAIMAAgIfh0iQgApAgAMAAgIfh0iQgApAgAAAA==.',['笑茶']='笑茶:BAAAKgAFFAQIBAAAAA==.',['等一']='等一只小黑喵:BAAAKgADCggICAAAAA==.',['等等']='等等泽:BAABKgAECn9DAAQYAAgIkyHVEACgAgAYAAgIkyHVEACgAgAfAAgI2RxbAQBeAgAWAAEITAj/sAAiAAAAAA==.',['筠竹']='筠竹千年:BAAAKgAECgUIBQAAAA==.',['米罗']='米罗丹银歌:BAABKgAFFH8GAAIOAAYIfglVEABLAQAOAAYIfglVEABLAQAAAA==.',['紫夜']='紫夜蓝月:BAAAKgAECgcICQAAAA==.',['红蜘']='红蜘蛛:BAAAKgAECgYIBgAAAA==.',['纪大']='纪大德:BAAAKgAECgcIBwAAAA==.',['纸上']='纸上画魅:BAAAKgAECgYIDwAAAA==.',['绝地']='绝地游侠:BAABKgAECn8UAAIcAAgIMwu2IgDsAAAcAAgIMwu2IgDsAAAAAA==.',['绯斯']='绯斯:BAAAKgAFFAYIAgABKgAFFAgIDAAIAHMZAA==.',['网恋']='网恋骑:BAAAKgADCgMIAwAAAA==.',['肥啾']='肥啾一号:BAAAKgADCggICAABKgAECggIIwAdAIAYAA==.',['肥头']='肥头小耳:BAAAKgAECgUIBQAAAA==.',['胖小']='胖小鲲:BAABKgAECn8fAAIMAAgIZR4CJQBtAgAMAAgIZR4CJQBtAgAAAA==.',['胖帆']='胖帆:BAAAKgAECgcIDQAAAA==.',['艾伯']='艾伯哈特:BAAAKgAECgIIAgAAAA==.',['艾得']='艾得娜:BAABKgAFFH8LAAILAAYIJxbVCwCOAQALAAYIJxbVCwCOAQAAAA==.',['艾欧']='艾欧里亚:BAAAKgAECgcIDQAAAA==.',['艾蕾']='艾蕾西娅:BAAAKgAECgUICAAAAA==.',['芒莉']='芒莉莉:BAAAKgAECgYICgAAAA==.',['芭比']='芭比熊:BAACKgAFFH8NAAMXAAYIfhCmBwAxAQAXAAYIfhCmBwAxAQAIAAQIVB3cJgD6AAAqAAQKfxsAAggACAiBGVkuAPQBAAgACAiBGVkuAPQBAAAA.',['苏图']='苏图:BAAAKgAECgEIAQAAAA==.',['苦信']='苦信大师:BAAAKgAECgcIBwAAAA==.',['茱蒂']='茱蒂斯泰琳:BAAAKgAECgMIAwABKgAFFAgIMAANAHIiAA==.',['莫西']='莫西沙星:BAABKgAFFH8IAAIMAAQIWCU/BwBEAQAMAAQIWCU/BwBEAQABKgAFFAgICgAMAK0lAA==.',['落叶']='落叶知秋:BAAAKgAECgUICAAAAA==.',['蒙娜']='蒙娜丽莎之手:BAAAKgAFFAIIAgAAAA==.',['蓝云']='蓝云琳月:BAAAKgADCggIBwAAAA==.',['蔺二']='蔺二二:BAAAKgAECgMIAwAAAA==.',['蕾伊']='蕾伊:BAAAKgADCggICAAAAA==.',['西马']='西马:BAABKgAFFH8GAAIdAAYInBRsFABWAQAdAAYInBRsFABWAQAAAA==.西马拉雅:BAAAKgAECgIIAgAAAA==.',['诺米']='诺米:BAAAKgADCgQIBAAAAA==.',['贝蕾']='贝蕾莉尔:BAAAKgADCggICQAAAA==.',['赤瞳']='赤瞳灬:BAABKgAFFH8GAAIFAAYIQRIqGABCAQAFAAYIQRIqGABCAQAAAA==.',['赤菁']='赤菁风铃:BAAAKgAECgUIBQAAAA==.',['起手']='起手英勇:BAAAKgAECgcIDQAAAA==.',['车宝']='车宝贝:BAAAKgADCggIBgAAAA==.',['辛龙']='辛龙:BAABKgAECn8YAAMMAAYItB9dVgC6AQAMAAYItB9dVgC6AQAUAAEIAAA2cgAAAAAAAA==.',['迈克']='迈克劫个色:BAAAKgAECggIEAAAAA==.',['迈耶']='迈耶蒂丽娜:BAAAKgAECgQIBAAAAA==.',['这瓜']='这瓜保熟吗:BAAAKgAECggICAAAAA==.',['迦楼']='迦楼罗:BAAAKgAECgYIBgAAAA==.',['迷笛']='迷笛:BAAAKgAECgEIAQAAAA==.',['那没']='那没事了:BAAAKgAFFAQIBAAAAA==.',['那都']='那都不算事:BAABKgAFFH8IAAIDAAgIGwexCACwAQADAAgIGwexCACwAQAAAA==.',['酒窝']='酒窝的开心:BAAAKgAECgcIBwAAAA==.',['酒鬼']='酒鬼:BAAAKgAFFAIIAgAAAA==.',['量子']='量子纠缠:BAAAKgADCgYIBgAAAA==.',['钢然']='钢然:BAAAKgADCggICAAAAA==.',['钻石']='钻石刘老五:BAAAKgADCggIAgAAAA==.',['铁血']='铁血沙场:BAAAKgADCgYIBgAAAA==.',['银河']='银河之汐:BAAAKgADCggIDQAAAA==.银河之锋:BAAAKgADCggIAgAAAA==.',['闇殒']='闇殒:BAABKgAFFH8GAAIFAAYIkQXnIgDxAAAFAAYIkQXnIgDxAAAAAA==.',['防火']='防火龙:BAAAKgAFFAEIAQAAAA==.',['阳鼎']='阳鼎天:BAAAKgADCggICAAAAA==.',['阿卡']='阿卡卡咩:BAAAKgAECggICAAAAA==.',['阿瓦']='阿瓦斯:BAABKgAFFH8IAAIdAAgIFwaSCwCpAQAdAAgIFwaSCwCpAQAAAA==.',['阿笠']='阿笠博士:BAAAKgAECggICwABKgAFFAgIMAANAHIiAA==.',['隔壁']='隔壁老王家:BAAAKgAECgIIBAAAAA==.',['雌鹰']='雌鹰:BAABKgAFFH8IAAIMAAQIfwmNLAC0AAAMAAQIfwmNLAC0AAAAAA==.',['雪落']='雪落无迹:BAAAKgAECgQIBQAAAA==.',['雪魂']='雪魂归来:BAACKgAFFH8WAAIgAAQIiA7LCwClAAAgAAQIiA7LCwClAAAqAAQKfyAAAiAACAhcETMmAE8BACAACAhcETMmAE8BAAAA.',['雷电']='雷电影:BAABKgAECn8bAAIhAAgIsSJACgCiAgAhAAgIsSJACgCiAgAAAA==.',['青衫']='青衫烟雨客:BAAAKgADCggICAAAAA==.',['青黛']='青黛:BAABKgAFFH8cAAIIAAcI0iAzAgC5AQAIAAcI0iAzAgC5AQAAAA==.',['韦小']='韦小宝的老婆:BAAAKgAECgMIAwAAAA==.',['预见']='预见:BAAAKgAECgUICgAAAA==.',['风中']='风中的弯犄角:BAABKgAFFH8MAAMWAAYI1BSwFwAqAQAWAAYIBBKwFwAqAQAYAAIIyBDgRgCHAAAAAA==.',['风暴']='风暴小雪:BAABKgAFFH8GAAIBAAYIdRX7CQB4AQABAAYIdRX7CQB4AQAAAA==.风暴雀鹰:BAABKgAFFH8GAAIWAAYIwAxBPgB/AAAWAAYIwAxBPgB/AAAAAA==.',['风火']='风火山林:BAAAKgADCgEIAQAAAA==.',['风神']='风神女:BAABKgAECn8kAAMWAAgIbhKEGwBCAQAYAAgImxCUTQB1AQAWAAgI4A2EGwBCAQAAAA==.',['风轻']='风轻云淡:BAAAKgAECgEIAQAAAA==.',['飞翔']='飞翔的果果:BAAAKgAECgcIEgAAAA==.飞翔的荷兰人:BAABKgAFFH8IAAMDAAQIlxOAMgDKAAADAAQIeROAMgDKAAAEAAQILg8FIwCQAAAAAA==.',['马应']='马应龙:BAAAKgAECgEIAQAAAA==.',['魅影']='魅影天狼:BAAAKgAECgYICQAAAA==.',['魏柔']='魏柔:BAAAKgAECgUIBQAAAA==.',['麦乐']='麦乐鸡贼:BAAAKgAECgIIBAAAAA==.',['黑煞']='黑煞余庆:BAABKgAECn8cAAIHAAcINB0yLwC9AQAHAAcINB0yLwC9AQAAAA==.',['龙母']='龙母壮骨颗粒:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end