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
 local lookup = {'Paladin-Retribution','Shaman-Elemental','Paladin-Holy','Paladin-Protection','Priest-Holy','Priest-Shadow','Priest-Discipline','Warrior-Arms','Warrior-Protection','Druid-Balance','Druid-Restoration','Rogue-Assassination','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','DemonHunter-Vengeance','DeathKnight-Unholy','Shaman-Restoration','Druid-Guardian','Mage-Arcane','Mage-Frost','Mage-Fire','Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','Monk-Mistweaver','Monk-Windwalker','Warrior-Fury','DeathKnight-Blood','Rogue-Subtlety','Monk-Brewmaster','DeathKnight-Frost',}; local provider = {region='CN',realm='奥妮克希亚',name='CN',type='weekly',zone=42,date='2025-08-08',data={Am='Amarlon:BAABKgAFFH8IAAIBAAgIkh1pBACMAgABAAgIkh1pBACMAgAAAA==.',Ba='Bazzinga:BAAAKgAFFAYIAgAAAA==.',Bl='Blueshaman:BAAAKgADCgIIAgAAAA==.',Bo='Boxbaby:BAABKgAFFH8GAAIBAAUIpAqTHAAAAQABAAUIpAqTHAAAAQAAAA==.',Ca='Cathy:BAAAKgAECggICAAAAA==.',Co='Come:BAAAKgAECgIIAwAAAA==.',De='Deathgun:BAAAKgAECgUICgAAAA==.',Dz='Dzip:BAAAKgAFFAQIBAAAAA==.',Er='Erika:BAAAKgADCgQIBAAAAA==.',Ev='Evolution:BAAAKgAECgYIDAAAAA==.',Ha='Hank:BAABKgAFFH8gAAICAAQIOBQlFQDGAAACAAQIOBQlFQDGAAAAAA==.',Ju='Justalex:BAAAKgAECggICQABKgAFFAgICAABAHQWAA==.',Ki='Killa:BAAAKgAECgYIDwAAAA==.',Ma='Magicsnake:BAAAKgADCgMIBAAAAA==.',My='Myfreedom:BAAAKgAFFAQIBAAAAA==.',Oi='Oissii:BAABKgAECn8YAAIDAAgI8xRBGQCeAQADAAgI8xRBGQCeAQAAAA==.',Qo='Qo:BAAAKgAECgUIBQAAAA==.',Sa='Salute:BAAAKgAFFAMIAwAAAA==.',To='Torukmakto:BAABKgAFFH8GAAMBAAII+RcANgCdAAABAAII+RcANgCdAAAEAAEIigB8HQAcAAAAAA==.',Up='Uprising:BAABKgAFFH8sAAIBAAYIeSKAOQAGAQABAAYIeSKAOQAGAQAAAA==.',Vo='Voldemort:BAAAKgADCggICAAAAA==.',Wi='Will:BAAAKgAECgYIBgAAAA==.',['一只']='一只奶牛:BAAAKgAECggIBgAAAA==.一只小蜜蜂呀:BAABKgAFFH8LAAMFAAYItBjACQDmAAAFAAQIAhnACQDmAAAGAAMIvRfKFQC1AAABKgAFFAgIEQAHADMcAA==.',['一小']='一小哦一:BAAAKgAFFAgIBAAAAA==.',['一尛']='一尛尛益一:BAAAKgAECggICAABKgAFFAgICgABAK0lAA==.',['一朵']='一朵小红花:BAAAKgAECgIIAgAAAA==.',['一盒']='一盒纯牛奶:BAAAKgAECgEIAQAAAA==.',['七步']='七步之内:BAAAKgADCgIIAgAAAA==.',['七武']='七武海:BAABKgAECn8UAAMIAAcIChitHQCYAQAIAAcIChitHQCYAQAJAAQIUgucQQBTAAAAAA==.',['三修']='三修:BAAAKgAECgMIAwAAAA==.',['上帝']='上帝武装:BAAAKgADCggICAAAAA==.',['上我']='上我奶你:BAAAKgAECgQIBQAAAA==.',['不加']='不加的小号:BAAAKgAECggICAAAAA==.',['不死']='不死青年:BAAAKgAFFAQIBAAAAA==.',['丨龍']='丨龍尐丨:BAABKgAFFH8NAAMKAAYISBicFQBsAQAKAAYISBicFQBsAQALAAUIBA8ZFwDnAAAAAA==.',['丶愛']='丶愛玩的小貓:BAABKgAFFH8GAAIMAAYIhwVfCQA7AQAMAAYIhwVfCQA7AQAAAA==.',['么么']='么么牧:BAABKgAECn8XAAMHAAgI5hYMGQD6AQAHAAgI5hYMGQD6AQAGAAMIKQ/KTQC2AAAAAA==.',['乐乐']='乐乐:BAAAKgAFFAEIAQAAAA==.',['云霓']='云霓洛普:BAAAKgAECgMIBQAAAA==.',['亚玛']='亚玛哈:BAABKgAFFH8NAAMKAAgISR8bCAAcAgAKAAcItCAbCAAcAgALAAEI8AYzNgBDAAAAAA==.',['人造']='人造棉:BAABKgAECn8aAAQNAAgIdgjrCgAJAQANAAgITAjrCgAJAQAOAAYIeAarHwChAAAPAAYI4gZ6MgCFAAAAAA==.',['今割']='今割大洋马:BAAAKgAECgEIAQAAAA==.',['付出']='付出青春:BAAAKgAFFAQIBAAAAA==.',['以德']='以德扶人:BAAAKgAECgEIAQAAAA==.',['任真']='任真:BAAAKgAECgIIAgAAAA==.',['伊人']='伊人相忘:BAAAKgAECggICAAAAA==.',['伊格']='伊格約姆:BAACKgAFFH9BAAIEAAgITxxrAwA+AgAEAAgITxxrAwA+AgAqAAQKfxUAAwQABAhAIbQcAHUBAAQABAhAIbQcAHUBAAEAAQgnD4NoAUAAAAAA.',['伽尔']='伽尔鲁什:BAAAKgADCgYIBgAAAA==.',['但凡']='但凡有一点:BAAAKgAECgQIBgAAAA==.',['你这']='你这个老六:BAAAKgAFFAIIAgAAAA==.',['信仰']='信仰不滅:BAAAKgAECgYIBgAAAA==.',['偷我']='偷我后场:BAAAKgAECgIIAgAAAA==.',['八戒']='八戒炸肉丝:BAAAKgAFFAEIAQAAAA==.',['八神']='八神庵的怒火:BAACKgAFFH8IAAIBAAQIFhbEQQDsAAABAAQIFhbEQQDsAAAqAAQKfxkAAgEACAjAJNIIAPgCAAEACAjAJNIIAPgCAAAA.',['八级']='八级小狂疯:BAABKgAFFH8IAAIQAAgIoxK1AgDPAQAQAAgIoxK1AgDPAQAAAA==.',['兰朝']='兰朝植:BAAAKgAECggICgAAAA==.',['兰颜']='兰颜知己:BAAAKgAECgcICgAAAA==.',['冰淇']='冰淇淋可乐:BAAAKgAFFAEIAQAAAA==.',['冰火']='冰火刀客:BAAAKgADCggICAAAAA==.冰火魍魉:BAAAKgAFFAQIBAAAAA==.',['冰糖']='冰糖拿铁:BAAAKgAECgQIBAAAAA==.',['冰镇']='冰镇榴莲:BAAAKgAFFAYIBAAAAA==.',['凸勒']='凸勒拔姬:BAAAKgAECgMIAwAAAA==.',['初萌']='初萌:BAAAKgADCgYIBgAAAA==.',['利瓦']='利瓦里奥:BAAAKgADCggIDgAAAA==.',['剧毒']='剧毒皮卡丘:BAAAKgAFFAQIBAAAAA==.',['剩奇']='剩奇石:BAABKgAFFH8JAAIBAAMIpxftQwDnAAABAAMIpxftQwDnAAAAAA==.',['北斗']='北斗五指裂弹:BAAAKgAECgcIBwAAAA==.',['十歩']='十歩殺一人:BAAAKgADCggICAAAAA==.',['千刀']='千刀流丶斷水:BAAAKgAECgIIAgAAAA==.',['千城']='千城:BAACKgAFFH8mAAIBAAQIzyT2GQD3AAABAAQIzyT2GQD3AAAqAAQKfx8AAgEACAi9I84xAFsCAAEACAi9I84xAFsCAAAA.',['千尾']='千尾离鸢:BAABKgAFFH8OAAQGAAQILhF7EQDWAAAGAAQILhF7EQDWAAAFAAMI8RcXHgDSAAAHAAMIkxriFQCwAAAAAA==.',['午夜']='午夜丶屠夫:BAAAKgAFFAgIBAAAAA==.午夜丶遛狗:BAAAKgADCggICAAAAA==.',['卡迪']='卡迪恩:BAAAKgAECgUICwAAAA==.',['叁月']='叁月七:BAAAKgAFFAgIAgAAAA==.',['又菜']='又菜又爱玩:BAABKgAECn8dAAICAAgIBBkmHADmAQACAAgIBBkmHADmAQAAAA==.',['叉班']='叉班笛格子:BAAAKgAFFAEIAQAAAA==.',['双马']='双马尾的胜利:BAAAKgAFFAEIAQABKgAFFAgIJgAIAHgcAA==.',['双鱼']='双鱼座吃鱼头:BAAAKgAFFAIIAgAAAA==.',['可乐']='可乐真好喝:BAACKgAFFH8lAAIBAAMI6SHqDQAcAQABAAMI6SHqDQAcAQAqAAQKfycAAwEACAiEI8IdAKECAAEACAiEI8IdAKECAAQABAgODak3ALQAAAAA.',['可以']='可以上了:BAAAKgAECgIIAgAAAA==.',['可爱']='可爱:BAAAKgAFFAEIAQAAAA==.',['可青']='可青可:BAAAKgAECggIDAAAAA==.',['呜喵']='呜喵王:BAABKgAFFH8GAAIRAAYIlxSuEwB9AQARAAYIlxSuEwB9AQABKgAFFAgIDgABACocAA==.',['咱霸']='咱霸:BAAAKgAFFAIIAgAAAA==.',['哈多']='哈多根:BAAAKgADCgUIBQAAAA==.',['哎呀']='哎呀:BAAAKgADCgQIBAAAAA==.',['哐哐']='哐哐扯两下:BAABKgAFFH8IAAIBAAMIZgScagCWAAABAAMIZgScagCWAAAAAA==.',['喔喔']='喔喔圣牛:BAAAKgADCgEIAgAAAA==.喔喔死牛:BAAAKgADCgEIAQAAAA==.喔喔熊猫:BAAAKgADCgEIAQAAAA==.喔喔牛排:BAAAKgADCgEIAQAAAA==.',['喻文']='喻文波:BAAAKgAECgYIBgAAAA==.',['噩耗']='噩耗:BAAAKgAECggICAAAAA==.',['圣丨']='圣丨骑丨士:BAAAKgAECgIIAgAAAA==.',['圣陨']='圣陨:BAAAKgAECgYIBgAAAA==.',['坑地']='坑地天坑基友:BAAAKgAFFAIIAgAAAA==.',['坑天']='坑天地坑基友:BAABKgAFFH8GAAISAAMIFhICGwCgAAASAAMIFhICGwCgAAAAAA==.',['埋姑']='埋姑娘的:BAAAKgAECgMIBAAAAA==.',['塞巴']='塞巴斯帝安:BAACKgAFFH8IAAILAAQIThsNCAD9AAALAAQIThsNCAD9AAAqAAQKfyMAAwsACAiLHHkUACECAAsACAiLHHkUACECAAoACAg3G90qAAUCAAEqAAUUCAgOABEADxcA.',['壞喃']='壞喃魜:BAAAKgAECgEIAQAAAA==.',['夏沫']='夏沫星辰:BAACKgAFFH8IAAMBAAMI8QDqiQBCAAABAAIILQHqiQBCAAADAAEIWQC9HgAYAAAqAAQKfxcAAwEABggdBNoCAbIAAAEABggdBNoCAbIAAAMAAQg6AQdbAA0AAAAA.',['夏熙']='夏熙路:BAAAKgAFFAEIAQAAAA==.',['外道']='外道暗影:BAAAKgAECggICAAAAA==.',['夜月']='夜月花朝念:BAAAKgAECggIDgAAAA==.',['大德']='大德无形:BAACKgAFFH8IAAMKAAQIfRhvFQDmAAAKAAQIfRhvFQDmAAATAAIIVQl+DABQAAAqAAQKfxcAAgoACAiCD65UAGABAAoACAiCD65UAGABAAAA.',['大闪']='大闪电阁下:BAAAKgAECgMIBgAAAA==.',['大风']='大风行:BAABKgAFFH8IAAIPAAgIPRbFBgAnAgAPAAgIPRbFBgAnAgAAAA==.',['天天']='天天向上的:BAAAKgADCggICAAAAA==.',['失忆']='失忆吐司:BAAAKgAECgMIAgAAAA==.',['奉西']='奉西:BAABKgAFFH8HAAQUAAMIQiGMGgAQAQAUAAMIuyCMGgAQAQAVAAEIxSDeJgBdAAAWAAEIvRTSOgBIAAABKgAFFAgIDgAVAPwaAA==.',['奥妮']='奥妮克希雅:BAAAKgAECgYIBgAAAA==.奥妮克茜娅:BAAAKgAECgQIBwAAAA==.',['媛沐']='媛沐歌谣:BAAAKgADCgEIAQAAAA==.',['宁渊']='宁渊:BAAAKgAFFAEIAQAAAA==.',['宅牛']='宅牛牛:BAAAKgADCgYIBgAAAA==.',['安德']='安德鲁屮暴风:BAAAKgADCgMIAwAAAA==.',['寵妳']='寵妳一玍:BAAAKgAECgUIBwAAAA==.',['封不']='封不觉:BAAAKgAECgcIBwAAAA==.',['小变']='小变态:BAAAKgADCgIIAgAAAA==.',['小小']='小小奶牛:BAAAKgAECgEIAQAAAA==.小小沫娴:BAAAKgAFFAgIBAAAAA==.小小的尖牙妹:BAAAKgAECgUICQAAAA==.',['小屁']='小屁屁:BAAAKgAECggICAAAAA==.',['小拾']='小拾壹:BAAAKgAECggICAAAAA==.小拾玖:BAAAKgADCggICAAAAA==.',['小春']='小春惠美纪:BAAAKgAECgcIBwAAAA==.',['小沐']='小沐遥:BAAAKgADCgUIBQAAAA==.',['小白']='小白龍:BAABKgAECn8VAAMFAAgISRjaMgB1AQAFAAgI0BHaMgB1AQAHAAYIXhTXPwAYAQAAAA==.',['小螺']='小螺号嘀嘀吹:BAAAKgAECggIDQAAAA==.',['小霪']='小霪虫:BAAAKgAFFAgIBAAAAA==.',['岚魂']='岚魂倩影:BAAAKgAECgUIBQAAAA==.',['工具']='工具人败家:BAAAKgAFFAQIBAAAAA==.',['巨熊']='巨熊守峦峰:BAAAKgAECgYIDAAAAA==.',['帕莱']='帕莱达克斯:BAAAKgADCgcIBwAAAA==.',['幽幽']='幽幽相随:BAAAKgAECgcICwAAAA==.',['强圣']='强圣:BAAAKgAECgEIAQAAAA==.',['彼岸']='彼岸之扉:BAAAKgADCgYIBgAAAA==.',['御灵']='御灵:BAAAKgADCggIDAAAAA==.',['微胖']='微胖男人:BAAAKgADCggICAAAAA==.',['德了']='德了:BAAAKgADCggICAAAAA==.',['心随']='心随我動:BAAAKgAECgIIAgAAAA==.',['忌弑']='忌弑安魂曲:BAAAKgAECggIDwAAAA==.',['急速']='急速萝卜:BAACKgAFFH8OAAIWAAQImhK4GwDjAAAWAAQImhK4GwDjAAAqAAQKfxwAAxYACAj0H30YAGECABYACAgGH30YAGECABUABQhTHP1dAPIAAAAA.',['怪兽']='怪兽小怪兽:BAAAKgADCggIEAAAAA==.',['恬遐']='恬遐巫贼:BAAAKgADCgYIBgAAAA==.',['惡魔']='惡魔熾天使:BAAAKgADCggICAAAAA==.',['慕容']='慕容烟花:BAAAKgAECgcICwAAAA==.',['成长']='成长生命幸福:BAAAKgAECgQIBAAAAA==.',['我不']='我不是奶:BAABKgAFFH8HAAMFAAQITxHZCQDmAAAFAAQITxHZCQDmAAAGAAMIJBL0GQCUAAAAAA==.',['我是']='我是混子猎:BAABKgAFFH8KAAMXAAYIuhwEEQBdAQAXAAYIvRgEEQBdAQAYAAQIDg8XHgDeAAAAAA==.',['我来']='我来时的路:BAABKgAFFH8GAAIBAAYIaRpAHgB5AQABAAYIaRpAHgB5AQAAAA==.',['扑街']='扑街猫:BAAAKgAECgYIBgAAAA==.',['扯淡']='扯淡:BAABKgAFFH8GAAIZAAYImw98FgBGAQAZAAYImw98FgBGAQAAAA==.',['挖挖']='挖挖机:BAAAKgAECggICAAAAA==.',['接种']='接种而来:BAAAKgAECgUIBQAAAA==.',['提里']='提里奥皮卡丘:BAABKgAFFH8GAAIBAAYIzBkZHwB0AQABAAYIzBkZHwB0AQAAAA==.',['搅局']='搅局者:BAAAKgAECgYIBgAAAA==.',['文西']='文西:BAAAKgADCgIIAgAAAA==.',['断刀']='断刀客:BAAAKgADCgQIBAAAAA==.',['无影']='无影:BAABKgAFFH8IAAMaAAYISA1eHQC1AAAaAAYISA1eHQC1AAAbAAEIogqNHwA+AAAAAA==.',['无敌']='无敌小七:BAAAKgAECgIIAgAAAA==.',['时间']='时间嘚玫瑰:BAAAKgAECgYIBgAAAA==.',['星如']='星如雨:BAAAKgAECgIIAgAAAA==.',['春梦']='春梦了无痕:BAAAKgAECgUIAQAAAA==.',['春熙']='春熙路丶:BAAAKgAECgUIBQABKgAFFAgIBQAMAEkOAA==.',['晏祖']='晏祖:BAAAKgAECgIIAgAAAA==.',['普罗']='普罗塔斯:BAABKgAFFH8OAAMCAAgInBLbAgApAgACAAgInBLbAgApAgASAAYIpA77AQCHAQAAAA==.',['最终']='最终之守望:BAABKgAFFH8LAAMBAAYIUiRjCgAeAgABAAYIUiRjCgAeAgAEAAEIhgKWGAA4AAAAAA==.',['月影']='月影星辰:BAAAKgAFFAcIBAAAAA==.',['月落']='月落凝霜:BAABKgAFFH8MAAIcAAgItBwgAwCIAgAcAAgItBwgAwCIAgAAAA==.月落无霜:BAAAKgAFFAUIBAAAAA==.',['有种']='有种下课单挑:BAAAKgAECgUIDQAAAA==.',['朋友']='朋友萨缺吗:BAAAKgAECgYIBgAAAA==.',['望明']='望明月:BAAAKgAECgEIAQAAAA==.',['木木']='木木的飘遥:BAABKgAFFH8GAAIFAAMI8w00KgCaAAAFAAMI8w00KgCaAAAAAA==.',['本间']='本间芽衣子:BAAAKgAECggIDgAAAA==.',['朴彩']='朴彩英:BAAAKgAECgcIBwAAAA==.',['李勾']='李勾:BAABKgAFFH8GAAIPAAYIYhxwFABhAQAPAAYIYhxwFABhAQAAAA==.',['杏仁']='杏仁豆腐:BAABKgAFFH8KAAMdAAUIfRnPCQD8AAAdAAQIAxvPCQD8AAARAAUI3xPYFAC/AAAAAA==.',['来福']='来福:BAAAKgAECgcIBwAAAA==.',['林间']='林间风清扬:BAAAKgAECggIEgAAAA==.',['枫叶']='枫叶梅香:BAAAKgADCggICAAAAA==.',['枫林']='枫林邪萨:BAABKgAFFH8GAAISAAYIqxSGDgBoAQASAAYIqxSGDgBoAQAAAA==.',['枯牧']='枯牧逢春:BAAAKgAECgUIBQAAAA==.',['梦断']='梦断蓝桥:BAAAKgADCgYIBgAAAA==.',['梵净']='梵净山:BAABKgAECn8bAAMFAAgICgsmRAAoAQAFAAgIBgomRAAoAQAHAAUI7gWQbQB9AAAAAA==.',['楞头']='楞头青:BAAAKgAECgEIAQAAAA==.',['榴莲']='榴莲侠:BAAAKgAECggIDgAAAA==.',['橙子']='橙子菠萝汁:BAAAKgAFFAIIAgAAAA==.',['橙迷']='橙迷旋转:BAAAKgADCggICAAAAA==.',['橙鱼']='橙鱼零度空间:BAACKgAFFH8UAAMUAAMI4xyQEwDsAAAUAAMI4xyQEwDsAAAVAAIIbAkhGQBtAAAqAAQKfx4ABBQACAjxH6EmAMYBABQABghFIKEmAMYBABUABQi7HlU4AIwBABYABQheFTVbAAgBAAAA.',['欧豆']='欧豆豆们哟:BAABKgAFFH8HAAIRAAMI4xBwEwDrAAARAAMI4xBwEwDrAAAAAA==.',['正丶']='正丶丶:BAAAKgAECggIBgAAAA==.',['正义']='正义花生:BAAAKgAECgQIBgAAAA==.',['死饥']='死饥魔:BAAAKgAFFAQIBAAAAA==.',['汗库']='汗库克:BAAAKgAFFAgIAgAAAA==.',['江左']='江左萌:BAAAKgAECgUIDgAAAA==.',['沐歌']='沐歌谣:BAAAKgAECgIIAgAAAA==.',['沫娴']='沫娴:BAABKgAFFH8KAAMYAAgIFRsbEAB5AQAYAAYIBB4bEAB5AQAXAAQIbRT2GAAiAQAAAA==.',['浮士']='浮士德:BAABKgAECn8kAAMOAAgIMR26CwA+AgAOAAgIMR26CwA+AgAPAAEI8gOFsQApAAAAAA==.',['海军']='海军大元帅:BAAAKgAECgYIBgAAAA==.',['涂山']='涂山:BAABKgAFFH8FAAIXAAUIqhQxHwD7AAAXAAUIqhQxHwD7AAABKgAFFAgICAAYAHMNAA==.',['涅槃']='涅槃芬芳:BAAAKgAECgIIAgAAAA==.',['涵酱']='涵酱:BAAAKgAFFAMIBAAAAA==.',['清汤']='清汤火锅:BAACKgAFFH8TAAIdAAMI4hZDHADAAAAdAAMI4hZDHADAAAAqAAQKfxwAAh0ACAjzHKsPADkCAB0ACAjzHKsPADkCAAAA.',['潘多']='潘多拉:BAAAKgAFFAIIAgAAAA==.',['熊猫']='熊猫不会打本:BAAAKgAECgYIBgAAAA==.熊猫小熊猫:BAAAKgADCggIDQAAAA==.熊猫爱睡觉:BAAAKgAECggICQAAAA==.熊猫爱躺赢:BAAAKgAECggICAAAAA==.',['熙熙']='熙熙:BAAAKgAFFAQIBAAAAA==.',['牛牛']='牛牛牪犇:BAAAKgAECgEIAgAAAA==.牛牛犇牪:BAAAKgAFFAIIAwAAAA==.',['狠妞']='狠妞儿:BAABKgAFFH8IAAMKAAMIswPfUwBnAAAKAAII8wTfUwBnAAALAAIIsQo3LwBcAAAAAA==.',['狱龍']='狱龍术:BAAAKgADCggICAAAAA==.',['猎鲸']='猎鲸戦丶黑狼:BAAAKgAFFAgIBAAAAA==.',['玛利']='玛利亚丶凯丽:BAAAKgAECgMIAwAAAA==.玛利亚凯丽:BAAAKgAECgQIBAAAAA==.',['玩活']='玩活你:BAAAKgADCggIEAAAAA==.',['甄选']='甄选酸奶:BAAAKgADCgUIBQAAAA==.',['甘甘']='甘甘:BAABKgAFFH8KAAQEAAgIkBaACwA/AQAEAAQIKxyACwA/AQADAAQISSD5AwALAQABAAEIcBgMVABBAAAAAA==.',['疯丶']='疯丶岁月如梭:BAAAKgADCgQIBAAAAA==.',['看不']='看不懂吧:BAAAKgAFFAgIBAAAAA==.',['神之']='神之拳拳:BAAAKgAECgcIDAAAAA==.',['神奇']='神奇小白龙:BAACKgAFFH8SAAMFAAMIRRfDCgDfAAAFAAMIRRfDCgDfAAAHAAEIYg0kMwA5AAAqAAQKfx0AAgUACAgLI84GAK4CAAUACAgLI84GAK4CAAAA.',['离异']='离异长腿无孩:BAAAKgAFFAEIAQAAAA==.',['秋天']='秋天澄:BAAAKgAECggICAAAAA==.',['箭男']='箭男春:BAAAKgAECggIDwAAAA==.',['紗锅']='紗锅大的拳头:BAAAKgADCggIDgAAAA==.',['絀蕒']='絀蕒靈魂:BAABKgAFFH8IAAIPAAgIMQlvDQC1AQAPAAgIMQlvDQC1AQAAAA==.',['绿野']='绿野小子:BAAAKgAECggICAAAAA==.',['羽柔']='羽柔子:BAAAKgAECgYICgAAAA==.',['老鹿']='老鹿:BAABKgAFFH8GAAIBAAYIRRJvJABZAQABAAYIRRJvJABZAQAAAA==.',['聚宝']='聚宝盆:BAAAKgADCggICAAAAA==.',['肆无']='肆无忌惮:BAAAKgAECggIEAAAAA==.',['背叛']='背叛者之赐:BAAAKgAECggIEAAAAA==.',['胖达']='胖达圆圆:BAAAKgAECgIIAgAAAA==.',['致命']='致命丘比特:BAAAKgAECgIIBAAAAA==.',['舞丶']='舞丶僧:BAAAKgAECgEIAQAAAA==.舞丶森猫:BAAAKgAFFAMIAgAAAA==.',['艾庭']='艾庭:BAAAKgADCggICgAAAA==.',['艾瑞']='艾瑞莉娅:BAAAKgAFFAEIAgAAAA==.',['芝麻']='芝麻开门:BAAAKgAECgYIBgAAAA==.',['芬芳']='芬芳年华:BAAAKgADCgIIAwAAAA==.',['芭比']='芭比扣啦:BAAAKgAECgQIAgAAAA==.',['花开']='花开荼蘼:BAAAKgAECgYICwAAAA==.',['花无']='花无百日好:BAAAKgAECgUIDAAAAA==.',['花牛']='花牛:BAAAKgAECgIIAgAAAA==.',['花田']='花田乌龙:BAAAKgADCggICAAAAA==.',['莎锅']='莎锅大的拳头:BAAAKgADCggICAAAAA==.',['莣誋']='莣誋蓯葥:BAAAKgAECggICgAAAA==.',['莫小']='莫小娴:BAAAKgAECgIIAgAAAA==.',['菠萝']='菠萝橙子汁:BAAAKgAECgEIAQAAAA==.',['蓝之']='蓝之殇:BAAAKgAECgQIBgAAAA==.',['薩拉']='薩拉祈尔:BAAAKgAECgUIBQAAAA==.',['虚幻']='虚幻梦境:BAAAKgADCggIEAAAAA==.',['虫虫']='虫虫不知:BAAAKgAECgYIBwAAAA==.',['蛋小']='蛋小卷:BAAAKgAFFAQIAgAAAA==.',['血兽']='血兽尊者:BAABKgAFFH8HAAIRAAYIDBffEQCLAQARAAYIDBffEQCLAQABKgAFFAgICAAZAOcMAA==.',['血刃']='血刃莫比乌斯:BAAAKgAFFAgIBAAAAA==.',['西门']='西门吹雪:BAAAKgAECgUIBQAAAA==.',['西风']='西风岚:BAABKgAFFH8PAAMVAAcIJCKBAQBfAgAVAAcIJCKBAQBfAgAWAAQIIwVCJwC0AAAAAA==.',['言宁']='言宁宝宝:BAABKgAFFH8HAAMYAAYIbxi3QACcAAAYAAQIvRi3QACcAAAXAAMIYxV3JABPAAAAAA==.',['请你']='请你来跳个舞:BAACKgAFFH8LAAIYAAMIfQebQACcAAAYAAMIfQebQACcAAAqAAQKfx0AAhgACAj0F+UyANwBABgACAj0F+UyANwBAAAA.',['请叫']='请叫我达文西:BAAAKgAFFAIIAwAAAA==.',['賊神']='賊神:BAABKgAFFH8OAAMMAAYIshYnCAAEAQAMAAYI7RUnCAAEAQAeAAQIkBgbBADPAAAAAA==.',['贼强']='贼强:BAAAKgAECgYIBgAAAA==.',['路随']='路随人茫茫:BAABKgAFFH8IAAISAAgIBginCQCrAQASAAgIBginCQCrAQAAAA==.',['轻影']='轻影:BAABKgAFFH8GAAIBAAMIzRRLSQDcAAABAAMIzRRLSQDcAAAAAA==.',['这是']='这是一个小号:BAAAKgAECgIIAgAAAA==.',['迪丽']='迪丽干巴:BAAAKgAECgUICAAAAA==.',['迪迪']='迪迪大领主:BAABKgAFFH8MAAIBAAQIJhtKGgD2AAABAAQIJhtKGgD2AAABKgAFFAgIEgAEAIoWAA==.',['选择']='选择大于努力:BAABKgAFFH8UAAIRAAYIsiRtBgD7AQARAAYIsiRtBgD7AQAAAA==.',['逐风']='逐风之心:BAAAKgAFFAMIAgAAAA==.',['酱油']='酱油蘸酱:BAAAKgADCggICAAAAA==.',['野蠻']='野蠻神話:BAAAKgAECggIDAAAAA==.',['鑫心']='鑫心鑫:BAAAKgAECggIEwAAAA==.',['闪闪']='闪闪的你:BAAAKgAECggICAAAAA==.',['防不']='防不胜防:BAAAKgADCgEIAQAAAA==.',['阳光']='阳光男高丿:BAAAKgAECgUIBQAAAA==.',['阿克']='阿克萌德:BAAAKgAECgQIBAAAAA==.',['阿卡']='阿卡姆:BAAAKgAECgYIBgAAAA==.',['阿尔']='阿尔宙斯:BAAAKgADCgUIBQAAAA==.',['阿斯']='阿斯拉:BAACKgAFFH8bAAIfAAUIKRuQAABjAQAfAAUIKRuQAABjAQAqAAQKfyUAAh8ACAjJHhQFAFUCAB8ACAjJHhQFAFUCAAAA.',['阿焦']='阿焦:BAAAKgADCggICAAAAA==.',['零度']='零度颜值圣囡:BAAAKgAECgQIBAAAAA==.零度颜值大熊:BAAAKgAECgIIAgAAAA==.',['霸刃']='霸刃未曾试:BAAAKgAECgUIBQAAAA==.',['顶不']='顶不住打击:BAAAKgADCggICAAAAA==.',['风轻']='风轻云淡:BAAAKgAECgUIBwAAAA==.',['风雨']='风雨丶:BAABKgAFFH8GAAIRAAYI9xVAEACbAQARAAYI9xVAEACbAQABKgAFFAgICAAdAL0eAA==.风雨呢喃丶:BAAAKgAECgQIBAAAAA==.风雨呢難:BAAAKgAECgIIAgAAAA==.',['飞寳']='飞寳呼呼呀:BAABKgAECn8YAAMFAAgI6xpFHADgAQAFAAgI6xpFHADgAQAHAAEIhQnljwAzAAAAAA==.',['飞曈']='飞曈:BAAAKgADCgcIBwAAAA==.',['骄傲']='骄傲又温柔:BAAAKgADCggIDgAAAA==.',['鱼丫']='鱼丫头:BAABKgAFFH8GAAIBAAYIoAjbFgA2AQABAAYIoAjbFgA2AQAAAA==.',['黄泉']='黄泉:BAABKgAFFH8QAAMgAAgIkRdCAQA/AgAgAAgIoxFCAQA/AgAdAAgI+BPBAwDUAQAAAA==.',['黑球']='黑球蛋蛋:BAAAKgADCggIDgAAAA==.',['黑色']='黑色的狐狸:BAAAKgAECgYIBgAAAA==.',['黯淡']='黯淡地圣光:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end