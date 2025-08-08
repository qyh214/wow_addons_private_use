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
 local lookup = {'Rogue-Assassination','Druid-Restoration','Warlock-Affliction','Warlock-Destruction','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Arcane','Mage-Fire','Evoker-Devastation','Evoker-Preservation','Priest-Holy','DeathKnight-Frost','DeathKnight-Unholy','Warrior-Fury','Monk-Mistweaver','Paladin-Retribution','Shaman-Elemental','Shaman-Restoration','DeathKnight-Blood','Paladin-Protection','Mage-Frost','Priest-Discipline','Priest-Shadow','Monk-Windwalker','Shaman-Enhancement','Warlock-Demonology','Warrior-Arms','Warrior-Protection','DemonHunter-Havoc','Hunter-Survival','Unknown-Unknown','Monk-Brewmaster','Druid-Balance','Paladin-Holy','Druid-Feral','DemonHunter-Vengeance',}; local provider = {region='CN',realm='元素之力',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ay='Ayanamirei:BAACKgAFFH8yAAIBAAcILBnCCQC3AQABAAcILBnCCQC3AQAqAAQKfzwAAgEACAgfIfAIAHgCAAEACAgfIfAIAHgCAAAA.',De='Devilkin:BAAAKgADCgIIAgAAAA==.',Ka='Kazekami:BAABKgAFFH8PAAICAAMIRR9QEgAMAQACAAMIRR9QEgAMAQAAAA==.',No='Norton:BAAAKgAFFAIIAgAAAA==.',Qi='Qingyi:BAAAKgAECggIEAAAAA==.',Ro='Rova:BAAAKgAECggIDwAAAA==.',Sa='Sar:BAABKgAFFH8QAAMDAAgIRCTEAAD3AQADAAYInCPEAAD3AQAEAAQINyUyJgDaAAAAAA==.',Si='Sile:BAAAKgADCggICAAAAA==.',So='Solusek:BAABKgAFFH8HAAMFAAYItRf0EgBLAQAFAAYItRf0EgBLAQAGAAEIxRRNXAA/AAAAAA==.',Ye='Yesterdaycat:BAAAKgAECggICAAAAA==.',['一柒']='一柒柒一:BAABKgAFFH8IAAMHAAQIdCN7AAA+AQAHAAQIdCN7AAA+AQAIAAQIsRN4HgDbAAAAAA==.',['丁彡']='丁彡石:BAAAKgAECgYIEwAAAA==.',['七星']='七星静香:BAABKgAFFH8KAAMJAAYI7w4PBABnAQAJAAYI7w4PBABnAQAKAAQIzQ3KBQClAAABKgAFFAgIBgALAEAYAA==.',['上帝']='上帝地意志:BAAAKgAECgcICwAAAA==.',['不老']='不老亡魂:BAACKgAFFH8SAAILAAMI7xUoJgCqAAALAAMI7xUoJgCqAAAqAAQKf14AAgsACAjrICMLAHsCAAsACAjrICMLAHsCAAAA.',['且随']='且随风行:BAAAKgAECgQIBAAAAA==.',['东方']='东方烧饼:BAABKgAFFH8GAAMMAAMIrQmiCwCyAAAMAAMIVQmiCwCyAAANAAMIowNOHQByAAAAAA==.',['丨绵']='丨绵羊丨:BAAAKgADCgYIBgAAAA==.',['丶壊']='丶壊囝囝丨:BAABKgAFFH8IAAIOAAgI2gqrBgASAgAOAAgI2gqrBgASAgAAAA==.',['乔克']='乔克叔叔:BAABKgAFFH8GAAIFAAYIVwteGgAaAQAFAAYIVwteGgAaAQAAAA==.乔克阿姨:BAAAKgAECgYIBgAAAA==.',['云冰']='云冰吟:BAAAKgAECgYIBgAAAA==.',['亦乐']='亦乐:BAAAKgADCggIGAAAAA==.',['伏弦']='伏弦:BAAAKgAECgYIBgAAAA==.',['佳期']='佳期如梦丶:BAABKgAECn8fAAIPAAgI3BsiFwAvAgAPAAgI3BsiFwAvAgAAAA==.',['侯里']='侯里斯骑天:BAABKgAFFH8LAAIQAAMIfwzyLACyAAAQAAMIfwzyLACyAAAAAA==.',['元素']='元素风暴:BAAAKgAECgcIBwAAAA==.',['先钱']='先钱后奶乳业:BAAAKgAFFAQIBAAAAA==.',['光头']='光头强丶:BAABKgAFFH8GAAIIAAYI4Q45DgBaAQAIAAYI4Q45DgBaAQAAAA==.',['克洛']='克洛:BAAAKgADCggICAAAAA==.',['养牛']='养牛专业户:BAACKgAFFH8KAAIRAAMIMBSpEgDTAAARAAMIMBSpEgDTAAAqAAQKf0kAAxEACAjCIwMOAG4CABEACAjCIwMOAG4CABIACAiIExQ4AJUBAAAA.',['冰坦']='冰坦:BAABKgAFFH8JAAITAAMI5wtuJQCCAAATAAMI5wtuJQCCAAAAAA==.',['凉小']='凉小勾:BAABKgAECn8YAAIBAAgIog6nIwBUAQABAAgIog6nIwBUAQABKgAFFAMIEgAQAFgVAA==.',['凌晨']='凌晨一点钟:BAAAKgAFFAMIAwAAAA==.凌晨一點鐘:BAAAKgAECgIIAgAAAA==.',['刘老']='刘老师:BAABKgAFFH8HAAMQAAUIHRQQIADpAAAQAAQIZhcQIADpAAAUAAMIHhHOEAB+AAAAAA==.',['别怕']='别怕有冰箱:BAABKgAECn8WAAIVAAgIgg05NAAtAQAVAAgIgg05NAAtAQAAAA==.',['到处']='到处溜达:BAAAKgAECgUIBQAAAA==.',['北极']='北极丶大宝剑:BAAAKgADCgQIBAAAAA==.',['匹诺']='匹诺康尼:BAAAKgADCgUIBQAAAA==.',['千荷']='千荷壹:BAACKgAFFH8GAAIWAAMIog2VDQCcAAAWAAMIog2VDQCcAAAqAAQKfx4AAxYACAg4GzMcALcBABYACAg4GzMcALcBABcABQimCxZMAL4AAAAA.千荷小依:BAABKgAECn8YAAISAAgI+w1/TwA+AQASAAgI+w1/TwA+AQAAAA==.千荷小德:BAAAKgAECgYICgAAAA==.千荷忆:BAAAKgADCgQIBAAAAA==.千荷武:BAACKgAFFH8JAAIPAAMIgAWAJwCEAAAPAAMIgAWAJwCEAAAqAAQKfxwAAxgACAj6EAlAAA4BABgABghaEAlAAA4BAA8ACAgPDbdLAA0BAAAA.千荷翼:BAAAKgAECgYIBgAAAA==.',['南瓜']='南瓜二米粥:BAABKgAECn8sAAQRAAgIyyO9BgDDAgARAAgIhiO9BgDDAgAZAAgIuiFrFgAZAgASAAEIoQkSwwAiAAAAAA==.',['南风']='南风知我意:BAAAKgAFFAQIBAABKgAFFAgICAAFALMfAA==.',['卡罗']='卡罗卡曼:BAAAKgAECggIDAAAAA==.',['原来']='原来是这样啊:BAABKgAFFH8HAAILAAQIEBY4IADGAAALAAQIEBY4IADGAAAAAA==.',['可爱']='可爱灰兔:BAAAKgAFFAQIBAAAAA==.',['右手']='右手黑暗:BAABKgAECn8lAAMaAAgItxfOIwB2AQAaAAgItxfOIwB2AQAEAAMIzgIZpgA9AAAAAA==.',['名字']='名字想半天:BAAAKgAECgYICAAAAA==.',['向阳']='向阳花:BAAAKgADCggICAAAAA==.',['吕布']='吕布战三胤:BAABKgAFFH8FAAIOAAQInxX2KwCSAAAOAAQInxX2KwCSAAAAAA==.',['听风']='听风的蚕:BAACKgAFFH8NAAIGAAMIUQg3PgClAAAGAAMIUQg3PgClAAAqAAQKfzcAAgYACAgwG4wkACYCAAYACAgwG4wkACYCAAAA.',['咕咕']='咕咕牛德:BAAAKgADCgEIAQAAAA==.',['咚咚']='咚咚:BAAAKgADCgQIBgAAAA==.',['咸鱼']='咸鱼小熊猫:BAAAKgAECgMIAwAAAA==.',['哞哞']='哞哞蔻小琪:BAAAKgAECggIEQAAAA==.',['哼哈']='哼哈哼哈:BAAAKgADCggICAAAAA==.',['喔胖']='喔胖大叔:BAAAKgAECggIDwAAAA==.',['回家']='回家的呆呆:BAAAKgAECgIIAgAAAA==.',['回归']='回归:BAAAKgADCgQIBAAAAA==.',['团长']='团长我躺哪儿:BAACKgAFFH8PAAIVAAMI2SNhCQAtAQAVAAMI2SNhCQAtAQAqAAQKfxoAAhUACAgSJIEJALsCABUACAgSJIEJALsCAAEqAAUUCAgIAAcAuhIA.',['图腾']='图腾霸霸丶:BAAAKgAECgIIAgAAAA==.',['圣光']='圣光小罗莉:BAAAKgAFFAQIBAAAAA==.',['地狱']='地狱小吼:BAACKgAFFH8NAAMbAAYIPB/RCAB9AQAbAAYIHBzRCAB9AQAOAAQI/A2uIgDIAAAqAAQKfyIAAhsACAjeEYclAIwBABsACAjeEYclAIwBAAAA.',['地蛋']='地蛋:BAAAKgADCggIAQAAAA==.',['堕落']='堕落的雨:BAABKgAFFH8IAAIQAAQIPBQNFgABAQAQAAQIPBQNFgABAQAAAA==.',['墨雾']='墨雾烧:BAABKgAFFH8IAAIbAAgI6BaPAgBVAgAbAAgI6BaPAgBVAgAAAA==.',['夜之']='夜之子术天:BAAAKgADCgEIAQAAAA==.',['大煮']='大煮干丝:BAAAKgADCgIIAgAAAA==.',['大白']='大白兔奶牛:BAAAKgAFFAUIBAAAAA==.',['天下']='天下我最拽:BAAAKgAECgIIAwAAAA==.天下我最猛:BAACKgAFFH8JAAMbAAMI6wcuGwCxAAAbAAMI6wcuGwCxAAAcAAMIzgFEDQBWAAAqAAQKfy0AAxsACAg8EcYeAI8BABsACAg8EcYeAI8BABwACAjIC6EkAAcBAAAA.',['夷陵']='夷陵老祖:BAAAKgAFFAgIAQAAAA==.',['奥卡']='奥卡斯:BAABKgAFFH8KAAIGAAYIaSJcCgDJAQAGAAYIaSJcCgDJAQAAAA==.',['奥术']='奥术射击:BAAAKgADCggIEAAAAA==.',['奶满']='奶满:BAAAKgAECgEIAQAAAA==.',['奶爸']='奶爸别担心:BAABKgAFFH8SAAIdAAYIQyJuCwDQAQAdAAYIQyJuCwDQAQABKgAFFAgIDAAdADUhAA==.',['宝批']='宝批龍:BAAAKgAECgcICwAAAA==.',['寒舞']='寒舞寂:BAACKgAFFH8eAAMFAAYIog+tDwD/AAAFAAYI4A6tDwD/AAAGAAQItw2ANgC7AAAqAAQKfyMABAYACAhwFnRNAMoBAAYACAj5FHRNAMoBAAUABAjQF/BWAMIAAB4AAQg9BsYgACMAAAAA.',['小乔']='小乔的靠背:BAAAKgAECgIIAgAAAA==.',['小小']='小小牛:BAAAKgAECgQIBAAAAA==.',['小心']='小心超人:BAAAKgADCgEIAQAAAA==.',['小海']='小海狗:BAAAKgAECggIEAAAAA==.',['小蛋']='小蛋糕呀:BAAAKgAECgYIEgAAAA==.',['少年']='少年王:BAAAKgAECgUIBQAAAA==.少年王之怒:BAACKgAFFH8SAAITAAMI8hhLGQDXAAATAAMI8hhLGQDXAAAqAAQKf0IABBMACAi/G9ANABcCABMACAi/G9ANABcCAA0AAQhMBye/AB8AAAwAAwhgFQAAAAAAAAAA.',['就爱']='就爱窜门:BAAAKgADCgEIAQAAAA==.',['就这']='就这么地了:BAAAKgADCggICAAAAA==.',['尼德']='尼德霍格:BAAAKgADCggICAAAAA==.',['山上']='山上的人:BAAAKgADCggICQAAAA==.',['希露']='希露菲叶特:BAABKgAFFH8GAAMLAAYIQBiQBwD7AAALAAQIfx2QBwD7AAAWAAIIYhBkFAC7AAAAAA==.',['席尔']='席尔瓦纳斯:BAACKgAFFH8RAAIaAAMIJh0uCQDwAAAaAAMIJh0uCQDwAAAqAAQKfzwAAhoACAgNIFkLAEMCABoACAgNIFkLAEMCAAAA.',['幻影']='幻影:BAAAKgAFFAEIAQAAAA==.',['幽泉']='幽泉:BAAAKgAECgUIBQAAAA==.',['开黑']='开黑吗我选源:BAAAKgAECgQIBwAAAA==.',['弑羽']='弑羽:BAAAKgAFFAQIBAABKgAFFAgIBAAfAAAAAA==.',['弗拉']='弗拉明戈舞步:BAAAKgAECggIEAAAAA==.',['德神']='德神:BAABKgAECn8ZAAICAAgIKBfuIQCOAQACAAgIKBfuIQCOAQAAAA==.',['德莱']='德莱妮萨天:BAAAKgADCgQIBAAAAA==.',['怎么']='怎么也睡不够:BAABKgAFFH8IAAMWAAYISRC4GQDEAAAWAAQIYBK4GQDEAAAXAAQIRQuTGQCyAAAAAA==.',['悟嗳']='悟嗳慲訫:BAACKgAFFH8SAAILAAQIQxOaDwDDAAALAAQIQxOaDwDDAAAqAAQKfxYABAsACAidDdU4AFkBAAsACAidDdU4AFkBABcABAjUCkFZAIcAABYAAQjfCvKXACYAAAAA.',['慈世']='慈世大魔王:BAAAKgAECgcIDgAAAA==.',['憨老']='憨老头:BAAAKgAECgMIAwAAAA==.',['懵懂']='懵懂那些年:BAAAKgAECgEIAQAAAA==.',['我叫']='我叫胖墩墩:BAACKgAFFH8FAAMYAAQIBBNcFQC8AAAYAAQIBBNcFQC8AAAgAAEIlAWvCgAqAAAqAAQKfzAAAxgACAj3HYQWAPUBABgABwiIHYQWAPUBACAACAh9Fc0LAJMBAAAA.',['我的']='我的小可愛丶:BAAAKgAECgEIAQAAAA==.',['我知']='我知道要进潜:BAABKgAFFH8GAAMCAAYIvgNaDwC4AAACAAMIkgVaDwC4AAAhAAMISBTMNABLAAAAAA==.',['打望']='打望:BAABKgAFFH8KAAIGAAQIXQmjPACqAAAGAAQIXQmjPACqAAAAAA==.',['扶阿']='扶阿奶闯红灯:BAACKgAFFH8IAAIQAAMIcRi3RgDhAAAQAAMIcRi3RgDhAAAqAAQKf2AAAxAACAjuIOcbAJQCABAACAjuIOcbAJQCACIAAQgcAT5bAAsAAAAA.',['指路']='指路的苍蓝星:BAAAKgAECggICAAAAA==.',['捉鬼']='捉鬼小能手:BAAAKgAECgYICgAAAA==.',['捍卫']='捍卫心灵:BAAAKgADCgcIBwAAAA==.',['撕裂']='撕裂噩梦:BAABKgAFFH8IAAIIAAQIZwW6NQBtAAAIAAQIZwW6NQBtAAAAAA==.',['文化']='文化流氓:BAAAKgAECgQIBAAAAA==.',['斯黛']='斯黛西:BAAAKgAECgYIBgAAAA==.',['无尽']='无尽之海:BAABKgAECn8oAAINAAgIXBvgHgAcAgANAAgIXBvgHgAcAgAAAA==.无尽之门:BAAAKgAECggICAAAAA==.',['无敌']='无敌拳脚:BAAAKgAFFAgIBAAAAA==.无敌砍王:BAABKgAFFH8PAAMOAAYIXyZyBQAlAgAOAAYIXyZyBQAlAgAbAAEIFQRbKgBDAAAAAA==.',['时光']='时光荏苒:BAAAKgAFFAMIAwAAAA==.',['星岩']='星岩:BAAAKgAFFAQIBAABKgAFFAgIAgAHAAIWAA==.',['星汉']='星汉天空:BAAAKgADCgcIBwAAAA==.',['星空']='星空下的邂逅:BAAAKgAFFAQIAgAAAA==.',['是风']='是风就该自由:BAABKgAECn83AAIRAAgIISUABADoAgARAAgIISUABADoAgAAAA==.',['暗想']='暗想:BAAAKgAFFAMIAwAAAA==.',['最大']='最大西瓜:BAAAKgAECgUIAwAAAA==.',['月下']='月下弄潮儿:BAAAKgADCgEIAQAAAA==.',['月牙']='月牙天冲:BAABKgAFFH8GAAIGAAYIKRyeEAB0AQAGAAYIKRyeEAB0AQAAAA==.',['月璃']='月璃牧梦:BAAAKgAECggICwAAAA==.',['木头']='木头贝贝:BAACKgAFFH8LAAMaAAQIYQVUFQCbAAAaAAQIYQVUFQCbAAAEAAMIagJnPwBvAAAqAAQKfyEABAQACAiGDxA+ABMBAAQACAhzDBA+ABMBABoABAh3FkJMAMQAAAMAAQjuCIxCACoAAAAA.',['朴危']='朴危黎:BAAAKgAFFAQIBAAAAA==.',['格鲁']='格鲁的妹妹:BAAAKgADCgIIAgAAAA==.',['梦中']='梦中的浮空城:BAACKgAFFH8LAAMIAAYIxRlIBgCfAQAIAAYIZBZIBgCfAQAHAAUIcBg3HAADAQAqAAQKfxgABAcACAiYGsQ1AHUBAAcABwjyFsQ1AHUBAAgABghEGeNIAGABABUAAQj9Ecp3ADYAAAAA.',['梨涡']='梨涡浅笑:BAABKgAFFH8PAAIdAAgIZxvOBgA2AgAdAAgIZxvOBgA2AgAAAA==.',['此彼']='此彼绘卷:BAAAKgADCgQIBAAAAA==.',['水工']='水工稳:BAAAKgAECggIEgAAAA==.',['油老']='油老师狂热粉:BAABKgAFFH8FAAIdAAUIDB4XNgCpAAAdAAUIDB4XNgCpAAAAAA==.',['泪殤']='泪殤旖旎:BAAAKgAECggICAABKgAFFAgIAgAfAAAAAA==.',['洛琪']='洛琪希:BAAAKgADCgEIAQABKgAFFAgIBgALAEAYAA==.',['浪打']='浪打郎:BAAAKgAECgIIAgAAAA==.',['海盗']='海盗捷克:BAAAKgAECgIIAgAAAA==.',['淡淡']='淡淡的奶香:BAAAKgADCgQICwAAAA==.',['清明']='清明微雨:BAAAKgAECgUIBgAAAA==.',['清衣']='清衣晚风:BAAAKgAECggICgAAAA==.',['烟雨']='烟雨伊风:BAABKgAECn8bAAIQAAcI5hqZdgBmAQAQAAcI5hqZdgBmAQAAAA==.',['熊猫']='熊猫鸟树:BAABKgAECn8vAAMCAAgILBY+EABqAQACAAgILBY+EABqAQAjAAMI2QcAAAAAAAAAAA==.',['爆浆']='爆浆:BAAAKgADCgQIBAAAAA==.',['牌坊']='牌坊老男人:BAAAKgAECgYICAAAAA==.',['狄迪']='狄迪迪:BAAAKgAECgYIBgAAAA==.',['猫迩']='猫迩葉:BAABKgAFFH8LAAQNAAQI1BHrFgDbAAANAAQIvw/rFgDbAAAMAAMIDwlUDQCkAAATAAQIYgcCGQCMAAAAAA==.',['王权']='王权富贵:BAAAKgAECgIIAgAAAA==.',['琉璃']='琉璃昂:BAAAKgAFFAEIAQAAAA==.',['琥珀']='琥珀之影:BAAAKgAFFAEIAQAAAA==.',['疯狂']='疯狂的鼠鼠:BAAAKgAECgcIAgABKgAFFAMICgARADAUAA==.',['病蕉']='病蕉:BAAAKgADCggICQAAAA==.',['白光']='白光莹:BAAAKgAECggIBwAAAA==.',['白菜']='白菜:BAABKgAFFH8KAAIQAAYIjh4HHACEAQAQAAYIjh4HHACEAQAAAA==.',['盆鱼']='盆鱼宴:BAABKgAFFH8PAAISAAQIXiI6CgAGAQASAAQIXiI6CgAGAQAAAA==.',['盗亦']='盗亦可道:BAAAKgAECgIIAgAAAA==.',['真心']='真心喂过狗:BAAAKgADCgIIAgAAAA==.',['砰砰']='砰砰咻咻:BAAAKgAECgUIBQAAAA==.',['禅武']='禅武双全:BAAAKgAECgIIAgAAAA==.',['穆拉']='穆拉乙:BAABKgAFFH8KAAIQAAYIbxzCAQDTAQAQAAYIbxzCAQDTAQAAAA==.',['筱晓']='筱晓:BAAAKgAECgUIBQAAAA==.',['篱笆']='篱笆菜菜子:BAABKgAFFH8KAAMDAAYI5B1DBAANAQAEAAYIJx17EwBqAQADAAQIGRhDBAANAQAAAA==.',['糖门']='糖门不可无主:BAABKgAFFH8FAAIHAAIIgwoGIwBpAAAHAAIIgwoGIwBpAAAAAA==.',['糯奇']='糯奇:BAAAKgAFFAQIBAAAAA==.',['红楼']='红楼梦靥:BAABKgAFFH8GAAIYAAMIAQayEACUAAAYAAMIAQayEACUAAAAAA==.',['绝世']='绝世狐魔王:BAABKgAECn8ZAAISAAgIowYJdADSAAASAAgIowYJdADSAAAAAA==.',['绝命']='绝命滑铲:BAABKgAFFH8HAAIQAAYIwyJsEQDSAQAQAAYIwyJsEQDSAQAAAA==.',['绿皮']='绿皮蔻小琪:BAAAKgAECgUIBQAAAA==.',['缇啦']='缇啦米酥:BAABKgAFFH8GAAIWAAYIkQ76CwBVAQAWAAYIkQ76CwBVAQAAAA==.',['群魔']='群魔大舞:BAAAKgADCggICAAAAA==.',['翻地']='翻地滚:BAAAKgAECgYIBwAAAA==.',['老大']='老大:BAAAKgAECgcICwAAAA==.',['老杆']='老杆子:BAABKgAFFH8GAAIBAAYIbgkLDwBhAQABAAYIbgkLDwBhAQAAAA==.',['肉夹']='肉夹馍灬:BAAAKgADCgEIAQAAAA==.',['肥嘟']='肥嘟嘟左卫门:BAAAKgAECgUIBQAAAA==.',['自然']='自然随风:BAAAKgAFFAIIAgABKgAFFAgIEAAhACoOAA==.',['艾米']='艾米莉安:BAAAKgAECgYIBgABKgAFFAMIEgAQAFgVAA==.',['艾莲']='艾莲:BAAAKgAECggIDgAAAA==.',['芙莉']='芙莉莲:BAABKgAFFH8KAAIIAAYIMhvWAgDrAQAIAAYIMhvWAgDrAQAAAA==.',['花残']='花残泪:BAABKgAFFH8HAAISAAQIHQc7GQC/AAASAAQIHQc7GQC/AAAAAA==.',['莎拉']='莎拉格雷拉特:BAABKgAFFH8LAAMFAAQI0R+XBgATAQAFAAQI0R+XBgATAQAGAAQIcRFyOQC0AAABKgAFFAgIBgALAEAYAA==.',['萌新']='萌新小撒:BAAAKgAECggIBAAAAA==.',['萨儿']='萨儿玛格:BAAAKgADCggIEwAAAA==.',['萨米']='萨米夜:BAAAKgADCggIDQAAAA==.萨米娜:BAAAKgADCgUIBQAAAA==.萨米术:BAAAKgADCgQIBAAAAA==.萨米法:BAAAKgADCgIIAgAAAA==.',['萨萨']='萨萨狐:BAAAKgAFFAEIAQAAAA==.萨萨里安:BAAAKgADCggICAAAAA==.',['蒙查']='蒙查查:BAABKgAFFH8GAAIWAAYIhRjzCACOAQAWAAYIhRjzCACOAQAAAA==.',['蓝猪']='蓝猪:BAAAKgAFFAQIBAAAAA==.',['蓝羌']='蓝羌:BAACKgAFFH8NAAQGAAQIkhIRMQDIAAAGAAQIkhIRMQDIAAAFAAII2AhdIgBhAAAeAAEIzQxsBABGAAAqAAQKf0cABAUACAhMIEgXAD4CAAUACAgcHkgXAD4CAAYACAhCHlQhADcCAB4ACAgHFl4CAO8BAAAA.',['蔡丶']='蔡丶徐丶坤:BAAAKgAECgcICAAAAA==.',['蔻小']='蔻小琪:BAABKgAECn8YAAMGAAgImRaHWACnAQAGAAcIWheHWACnAQAFAAgIHg7JSwDtAAAAAA==.',['蛇床']='蛇床子:BAAAKgADCggICQAAAA==.',['蛐蛐']='蛐蛐你:BAAAKgADCgIIAgAAAA==.',['讲个']='讲个笑话:BAAAKgADCgIIAgAAAA==.',['诸神']='诸神之光辉:BAABKgAFFH8IAAIQAAgI2QtjEwDBAQAQAAgI2QtjEwDBAQAAAA==.',['这个']='这个人有点冰:BAABKgAFFH8FAAMSAAIITRJKIQCSAAASAAIITRJKIQCSAAARAAEIXAtOGwBBAAAAAA==.这个人有点冷:BAABKgAFFH8HAAIHAAcIWBaFCgDDAQAHAAcIWBaFCgDDAQAAAA==.',['逝无']='逝无痕:BAACKgAFFH8SAAIQAAMIWBWrTADWAAAQAAMIWBWrTADWAAAqAAQKfx4AAxAACAhbG7s6ABUCABAACAhbG7s6ABUCABQAAQjqAaRjAAQAAAAA.',['逝水']='逝水无痕:BAABKgAECn8jAAMkAAgItA+NMAAEAQAkAAgIlguNMAAEAQAdAAgIqwx0bQD2AAAAAA==.',['邪恶']='邪恶小猫:BAAAKgADCgcIBwAAAA==.',['郭襄']='郭襄:BAAAKgAFFAQIBAAAAA==.',['释水']='释水无痕:BAABKgAECn8gAAMCAAgI/gqnJwB7AAACAAgI/gqnJwB7AAAhAAgIbwkAAAAAAAABKgAFFAMIEgAQAFgVAA==.',['野性']='野性呼唤:BAAAKgAECggICAAAAA==.',['铜头']='铜头铁皮:BAAAKgAFFAMIAwAAAA==.',['阿毛']='阿毛:BAABKgAFFH8HAAIQAAcIWCEBDQD/AQAQAAcIWCEBDQD/AQAAAA==.',['阿茶']='阿茶:BAACKgAFFH8MAAIGAAMIniZHDAAiAQAGAAMIniZHDAAiAQAqAAQKfyYAAgYACAgrJVIJAOUCAAYACAgrJVIJAOUCAAAA.阿茶茶:BAAAKgAFFAMIAwABKgAFFAYIDAAGAJ4mAA==.',['阿达']='阿达啊:BAAAKgADCggICAAAAA==.',['隆胸']='隆胸:BAAAKgAECgIIAgAAAA==.',['雷霆']='雷霆嘎巴:BAACKgAFFH8IAAITAAQIugh6FwCVAAATAAQIugh6FwCVAAAqAAQKfxgAAw0ACAgVENpOAH4BAA0ACAjrDtpOAH4BAAwABwj4DNAWAC0BAAAA.',['霸气']='霸气狂煞:BAAAKgADCgIIAgAAAA==.',['韭菜']='韭菜鸡蛋:BAABKgAFFH8FAAIQAAQI6x/eDQAdAQAQAAQI6x/eDQAdAQAAAA==.',['颠覆']='颠覆妖兽:BAAAKgADCggIGwAAAA==.颠覆美眉:BAAAKgAECggIEQAAAA==.',['风风']='风风火火:BAAAKgAECgcIEAAAAA==.',['飞星']='飞星寻龙:BAAAKgAECgYICwAAAA==.',['黄昏']='黄昏的日落:BAAAKgAECgYIBgAAAA==.',['黄牛']='黄牛:BAABKgAECn8WAAIhAAcIcSBwKAASAgAhAAcIcSBwKAASAgAAAA==.',['黑山']='黑山老牛:BAAAKgAECgUICQAAAA==.',['黑黑']='黑黑猫警长:BAAAKgAECgYIBgAAAA==.',['齐拉']='齐拉:BAAAKgAFFAIIAgABKgAFFAgIBgAGAKcfAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end