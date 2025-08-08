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
 local lookup = {'Shaman-Enhancement','DemonHunter-Havoc','Priest-Shadow','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Shaman-Restoration','DeathKnight-Blood','DeathKnight-Unholy','Shaman-Elemental','Warrior-Arms','Mage-Frost','Mage-Arcane','Paladin-Protection','Paladin-Retribution','Druid-Balance','Mage-Fire','Druid-Restoration','Unknown-Unknown','Druid-Guardian','Monk-Windwalker','Monk-Mistweaver','Priest-Holy','Priest-Discipline','Paladin-Holy','Warrior-Fury','Evoker-Devastation','Evoker-Preservation','Warrior-Protection','Rogue-Subtlety','Rogue-Assassination','Druid-Feral','DemonHunter-Vengeance','Monk-Brewmaster',}; local provider = {region='CN',realm='风暴之鳞',name='CN',type='weekly',zone=42,date='2025-08-04',data={Aa='Aatlass:BAAAKgAFFAEIAQAAAA==.',An='Annieguu:BAAAKgAFFAgIAgAAAA==.',At='Atlass:BAAAKgAFFAQIAgABKgAFFAgIDwABAC4bAA==.',Be='Bean:BAABKgAFFH8PAAICAAYIWhSNEgD1AAACAAYIWhSNEgD1AAAAAA==.',Bw='Bwonsamdi:BAAAKgAECgIIAgAAAA==.',Ch='Christos:BAAAKgAECgYIBgAAAA==.',Co='Colelife:BAAAKgAFFAEIAQAAAA==.Coleworld:BAABKgAFFH8JAAIDAAQIJgvCEQCiAAADAAQIJgvCEQCiAAAAAA==.',Dd='Dd:BAABKgAECn8UAAMEAAgI9Q7YhAApAQAEAAgIMQzYhAApAQAFAAQIswaHfQBRAAABKgAFFAgIDgAEAEIfAA==.',De='Denouement:BAABKgAFFH8GAAIGAAYIbB4xEACOAQAGAAYIbB4xEACOAQAAAA==.',Dk='Dkhu:BAAAKgADCgMIAwAAAA==.Dkhv:BAAAKgADCgMIAwAAAA==.',Fe='Fenian:BAAAKgAFFAMIAgAAAA==.',Kn='Knirvanal:BAACKgAFFH8SAAMHAAgIvhmSAgAaAQAGAAcIvhktCQD6AQAHAAUIqxKSAgAaAQAqAAQKfxgABAYACAhpJkcBAAgDAAYACAhpJkcBAAgDAAgAAQjzI2w5AGAAAAcAAQhCFrF7ADwAAAAA.',Ma='Manhuaba:BAAAKgAECgEIAQAAAA==.',Mi='Miumiuer:BAAAKgADCggICAAAAA==.',Mo='Momo:BAAAKgAECgMIAwABKgAFFAgICAAJALsbAA==.Moonypt:BAAAKgADCgMIAwAAAA==.',Ne='Nes:BAACKgAFFH8tAAMKAAgIfBw1AwA2AgAKAAgIUxw1AwA2AgALAAQIwA71JQD4AAAqAAQKfxkAAgoACAghGewdAKABAAoACAghGewdAKABAAAA.Nestea:BAAAKgAECgUIBgAAAA==.',Ni='Niqiu:BAAAKgAECggIDwAAAA==.',Pl='Playeraoppbk:BAAAKgAECgcIDwAAAA==.Playerxrfagt:BAAAKgAECgEIAQAAAA==.',Sf='Sfagfdsf:BAABKgAFFH8KAAILAAYIqQh4HAA7AQALAAYIqQh4HAA7AQAAAA==.',St='Steak:BAAAKgAFFAYIBAAAAA==.',Sw='Swallowtai:BAAAKgAECgYIBgAAAA==.',Sy='Symolux:BAAAKgADCggICAAAAA==.',Th='Theflame:BAAAKgADCggICAAAAA==.Thunderss:BAABKgAFFH8KAAIJAAgIRA6CBwCiAQAJAAgIRA6CBwCiAQAAAA==.',Tu='Tunny:BAAAKgAECggIEwAAAA==.',Va='Vanssea:BAAAKgAECgcIBwAAAA==.',Zz='Zzxm:BAAAKgAECgUIBQAAAA==.',['一个']='一个人的森林:BAAAKgADCgEIAQAAAA==.',['一笙']='一笙所爱:BAAAKgADCggIDQAAAA==.',['一风']='一风林火山一:BAAAKgADCggICAAAAA==.',['上官']='上官睿:BAAAKgADCgEIAQAAAA==.',['下一']='下一战天国:BAAAKgAFFAMIAwAAAA==.',['下雨']='下雨天怎么办:BAAAKgAECgEIAQAAAA==.',['不再']='不再忧郁:BAAAKgAFFAIIAgAAAA==.',['不卖']='不卖银鳞胸甲:BAAAKgAECgYICQAAAA==.',['不是']='不是我摸的:BAAAKgADCgIIAgAAAA==.',['不辞']='不辞青山:BAABKgAFFH8MAAIGAAYIcxpFEQCBAQAGAAYIcxpFEQCBAQAAAA==.',['与眉']='与眉毛共舞:BAABKgAFFH8IAAMHAAQI1SBcEQC0AAAGAAQI1SA3HQAdAQAHAAQIUQ1cEQC0AAAAAA==.',['丙申']='丙申年:BAABKgAECn8ZAAICAAgIIw9xPwBQAQACAAgIIw9xPwBQAQAAAA==.',['东流']='东流映荷:BAAAKgAECggICAAAAA==.',['两今']='两今半:BAAAKgAFFAQIAgAAAA==.',['丨情']='丨情牵灬一世:BAAAKgAECgUICgAAAA==.',['丨路']='丨路人甲丨:BAACKgAFFH8LAAIJAAQIsApUOQCdAAAJAAQIsApUOQCdAAAqAAQKfyIAAwkACAgSDpdiABgBAAkACAgSDpdiABgBAAwABgjbB2BYALcAAAAA.',['丶俊']='丶俊:BAAAKgAFFAgIAgAAAA==.',['丶别']='丶别问不会奶:BAAAKgAECgcIBwABKgAFFAgIDAANAMwTAA==.',['丷小']='丷小龙女丷:BAAAKgADCgcIBwAAAA==.',['丷岛']='丷岛风丷:BAAAKgAFFAEIAQAAAA==.',['乱跑']='乱跑跑丨:BAABKgAFFH8MAAIBAAYI6BPCBwASAQABAAYI6BPCBwASAQAAAA==.',['云卷']='云卷云舒丶:BAAAKgAECggICAAAAA==.',['亲亲']='亲亲我的蓓蓓:BAABKgAFFH8GAAMOAAYIYA7jDwCnAAAOAAQILAzjDwCnAAAPAAIIrhHuQwBCAAABKgAFFAgIEAAHAOAZAA==.',['人总']='人总是在受罪:BAAAKgAFFAQIBAABKgAFFAgIEAAPAHkTAA==.人总是在死亡:BAABKgAFFH8RAAMKAAcIBBMMBwC1AQAKAAcIlxIMBwC1AQALAAII+hMjIQCgAAAAAA==.人总是在颓废:BAACKgAFFH8NAAIQAAQI2xYoEAADAQAQAAQI2xYoEAADAQAqAAQKfxwAAxAACAhUHJEZAJoBABAACAivGpEZAJoBABEABQhhHXaaABkBAAEqAAUUBwgRAAoABBMA.',['会丨']='会丨长:BAAAKgADCgYIBgAAAA==.',['会灬']='会灬长:BAAAKgAECgEIAQAAAA==.',['你好']='你好时光:BAAAKgADCgQIBAAAAA==.',['你是']='你是我的宠物:BAABKgAFFH8GAAIFAAYIGhYQCgB8AQAFAAYIGhYQCgB8AQAAAA==.',['你的']='你的名字很美:BAAAKgAFFAQIBAAAAA==.',['修羅']='修羅大官人:BAAAKgADCggICAAAAA==.',['催斯']='催斯坦:BAABKgAFFH8UAAMQAAYIGB4aDQAoAQAQAAYI2BIaDQAoAQARAAUIECOtGwDzAAAAAA==.',['光影']='光影丿:BAAAKgAFFAQIBAAAAA==.',['公务']='公务灬猿:BAABKgAFFH8FAAIRAAUI9w3jWAC/AAARAAUI9w3jWAC/AAABKgAFFAgIEQASAEEeAA==.',['六翼']='六翼炽蛇:BAACKgAFFH89AAQTAAgIChjFBgDyAQATAAgIeBHFBgDyAQAOAAQIjSIRCQAyAQAPAAEIAAAXTAAAAAAqAAQKf1EAAw4ACAhIJocBABADAA4ACAhIJocBABADAA8ABAgkHANpAKcAAAAA.',['冰凌']='冰凌恋:BAAAKgADCggIDQAAAA==.',['冰洁']='冰洁的梦:BAAAKgAECgEIAQAAAA==.',['冲锋']='冲锋陷阵:BAABKgAECn8XAAIJAAgI/wxRUABOAQAJAAgI/wxRUABOAQAAAA==.',['冷若']='冷若冰昕:BAAAKgAFFAYIBAAAAA==.',['几两']='几两咖啡:BAAAKgAFFAgIBAAAAA==.',['刚刚']='刚刚就好:BAAAKgAFFAgIBAAAAA==.',['别打']='别打脸啊:BAAAKgADCgcIDQAAAA==.',['刺帝']='刺帝撞钟丶孝:BAAAKgADCggICAAAAA==.',['副到']='副到:BAAAKgADCggIEAAAAA==.',['劳模']='劳模:BAAAKgAECgEIAQAAAA==.',['勾栏']='勾栏听曲:BAAAKgAECgUIBQAAAA==.',['北方']='北方枭客:BAAAKgAECgYIBgAAAA==.',['北风']='北风啸:BAAAKgAECgMIAwAAAA==.',['千里']='千里江陵:BAABKgAFFH8LAAMQAAQINBYRGgCoAAARAAMIlA1fVQDGAAAQAAQINBYRGgCoAAAAAA==.',['博文']='博文:BAABKgAFFH8GAAILAAYIwB6DDADHAQALAAYIwB6DDADHAQAAAA==.博文丶:BAAAKgAECgcIAgAAAA==.',['又是']='又是维以:BAAAKgADCggICAABKgAFFAgIDAANAMwTAA==.',['双子']='双子座灵灵:BAABKgAFFH8IAAIKAAgI2RfoBAD9AQAKAAgI2RfoBAD9AQAAAA==.',['反正']='反正不是我:BAAAKgAECgQIBAAAAA==.',['吃一']='吃一个数一个:BAABKgAFFH8WAAIUAAYIISYGAwAiAgAUAAYIISYGAwAiAgABKgAFFAgIDwALALYgAA==.',['吃猫']='吃猫的鱼:BAAAKgAECgEIAQAAAA==.',['吻心']='吻心丶:BAAAKgADCggICAAAAA==.',['呗呗']='呗呗丶:BAAAKgAECgYIEgAAAA==.呗呗龙:BAAAKgAECgYICgAAAA==.',['咕咕']='咕咕姑咕咕:BAAAKgAECgUIBQAAAA==.',['咕嘎']='咕嘎咕嘎:BAAAKgADCgEIAQAAAA==.',['哀月']='哀月:BAAAKgAFFAQIAwABKgAFFAgIBAAVAAAAAA==.',['品尝']='品尝我的咸:BAAAKgAECgEIAQAAAA==.',['哄小']='哄小朋友来吃:BAAAKgAFFAIIAgAAAA==.',['啵啵']='啵啵伊布:BAAAKgAECgYIBgAAAA==.',['喜多']='喜多川海梦:BAABKgAFFH8LAAILAAUIfh6aFAB2AQALAAUIfh6aFAB2AQAAAA==.',['喵咕']='喵咕哔哔呦:BAAAKgAECggIDQAAAA==.',['嗜血']='嗜血狂魔妮飘:BAAAKgADCggIEgAAAA==.',['嘟噜']='嘟噜嘟噜:BAABKgAECn8ZAAMWAAgIjBgjDwC0AQAWAAgIjBgjDwC0AQASAAIIVQUg0AA4AAAAAA==.',['嘿嘿']='嘿嘿打我呀:BAAAKgAECgEIAQAAAA==.嘿嘿硬:BAAAKgAECgUIBQAAAA==.',['噩梦']='噩梦宝宝:BAAAKgAFFAQIBAAAAA==.',['回音']='回音岛的余晖:BAABKgAECn8bAAIJAAgIFB+UEwBfAgAJAAgIFB+UEwBfAgAAAA==.',['国服']='国服第一非酋:BAACKgAFFH8dAAMXAAUIKyAWBgAbAQAXAAUIKyAWBgAbAQAYAAEIAAAjNwAAAAAqAAQKfxsAAhcACAj9IwUJAK4CABcACAj9IwUJAK4CAAAA.',['圣云']='圣云星光:BAABKgAFFH8MAAIRAAMI5x7SPQD4AAARAAMI5x7SPQD4AAAAAA==.',['圣光']='圣光忽悠谁:BAAAKgADCgEIAQAAAA==.圣光照耀谁:BAABKgAFFH8OAAIZAAgIZhj0BgC9AQAZAAgIZhj0BgC9AQAAAA==.',['地表']='地表最强男人:BAAAKgADCgQIBAAAAA==.地表最强老登:BAAAKgAECgUIBQAAAA==.',['墜吼']='墜吼:BAAAKgAFFAQIBAAAAA==.',['墨漓']='墨漓丶:BAAAKgAECgEIAQAAAA==.',['夕影']='夕影丿:BAAAKgAECggICAAAAA==.',['夕諾']='夕諾:BAAAKgAECgMIAwAAAA==.',['夕魅']='夕魅:BAAAKgAFFAQIBAAAAA==.',['夜之']='夜之雪饭团:BAAAKgADCggICAAAAA==.',['大地']='大地之原:BAAAKgAECgUICgAAAA==.大地之龙:BAAAKgADCgIIAgAAAA==.',['大月']='大月亮丶:BAAAKgAECgQIBAAAAA==.',['大漠']='大漠孤鹰:BAAAKgAECgQIBAAAAA==.',['天使']='天使姐姐:BAABKgAFFH8KAAQaAAYIpRxdCwD5AAAZAAUIjxYyFQAKAQAaAAQIexpdCwD5AAADAAEI8AEaMAA2AAABKgAFFAgICgAZANkWAA==.',['天秤']='天秤座点点:BAABKgAFFH8HAAIbAAcI8he8AwDOAQAbAAcI8he8AwDOAQAAAA==.',['天空']='天空屮鈹寳:BAAAKgAECgEIAQAAAA==.',['失落']='失落的圣剑:BAAAKgADCgEIAgAAAA==.失落的大黄:BAAAKgAECgcICQAAAA==.',['奥拉']='奥拉姆多:BAAAKgAECgIIAgAAAA==.',['奶龙']='奶龙大王:BAAAKgADCgcIBwAAAA==.',['好大']='好大一条蛇:BAAAKgAECgUICQAAAA==.',['妖娆']='妖娆春秋:BAAAKgADCgYIBgAAAA==.',['娜扎']='娜扎:BAAAKgAECgQIBAAAAA==.',['婉拒']='婉拒迪丽热巴:BAABKgAFFH8GAAICAAMI2RRbKADVAAACAAMI2RRbKADVAAAAAA==.',['季落']='季落梨花:BAAAKgAECgQIBAAAAA==.',['孤酒']='孤酒杯空影丶:BAAAKgAECggICAABKgAFFAgIIgARALAmAA==.',['安吉']='安吉丽娜茱莉:BAAAKgADCgEIAQAAAA==.',['安琪']='安琪拉粑粑:BAAAKgADCggICAAAAA==.',['家远']='家远路迢:BAAAKgAECgMIAwAAAA==.',['富婆']='富婆大排档:BAAAKgAFFAgIBAAAAA==.',['射爆']='射爆煤气罐:BAABKgAFFH8SAAMEAAgIWA8bEQBvAQAEAAUIng4bEQBvAQAFAAYIXw6GFgAxAQAAAA==.',['小奶']='小奶龙:BAAAKgAFFAcIAwAAAA==.',['小姗']='小姗姗:BAAAKgAECggICAAAAA==.',['小小']='小小的心愿:BAAAKgAFFAgIBAAAAA==.小小福仙:BAAAKgADCgMIAwAAAA==.小小雪翼:BAAAKgAECgMIAwAAAA==.',['小布']='小布丁雪糕:BAAAKgAECgQIBQAAAA==.',['小时']='小时候丶贼帅:BAAAKgAECgYIBwAAAA==.',['小术']='小术也疯狂:BAAAKgAECgcIDwAAAA==.',['小树']='小树林捉迷藏:BAAAKgAFFAgIBAAAAA==.',['小狸']='小狸猫:BAAAKgAECgIIAgAAAA==.',['小玉']='小玉西瓜:BAABKgAFFH8KAAMNAAQIgSVCAwBBAQANAAQIgSVCAwBBAQAcAAQIOSAnCQAcAQAAAA==.',['小胖']='小胖蛋:BAABKgAFFH8GAAIcAAQIbhdtGgCwAAAcAAQIbhdtGgCwAAAAAA==.',['小龙']='小龙家小林:BAACKgAFFH8tAAMdAAgI5hQpDACkAQAdAAYIwhopDACkAQAeAAYIew59BADlAAAqAAQKfx0AAx4ACAhFG2EHAA8CAB4ACAhFG2EHAA8CAB0AAgiGJeZCANIAAAAA.',['尛情']='尛情歌丶:BAAAKgAECgMIBAAAAA==.',['屠戮']='屠戮:BAABKgAECn8wAAQbAAgIDyJrAwC5AgAbAAgIDyJrAwC5AgAQAAgISBIMIgBGAQARAAUIMgaqFwGYAAABKgAFFAgIEAADAFsKAA==.',['帅小']='帅小伙邓肯:BAAAKgAECgEIAgAAAA==.',['帕尼']='帕尼尼:BAABKgAFFH8rAAQMAAgIECARBADfAQAMAAcIXxwRBADfAQABAAQImRTRCQA2AQAJAAEIyQR1UgA0AAAAAA==.',['幕悠']='幕悠晓寂寂丶:BAAAKgAFFAgIBAAAAA==.',['幽暗']='幽暗暴君:BAAAKgAECgEIAQAAAA==.',['异色']='异色眼柠檬心:BAABKgAFFH8JAAIGAAYIrRpyAQDgAQAGAAYIrRpyAQDgAQAAAA==.',['弦上']='弦上春雪:BAABKgAFFH8HAAIXAAQIkB1IEADjAAAXAAQIkB1IEADjAAABKgAFFAgIAwAVAAAAAA==.',['彼岸']='彼岸花蕊:BAAAKgAECggICAAAAA==.',['德国']='德国烧蹄:BAAAKgAFFAMIAwAAAA==.',['德雷']='德雷克斯勒:BAABKgAFFH8IAAISAAgIQQyeCwDbAQASAAgIQQyeCwDbAQAAAA==.',['忘川']='忘川蒹葭:BAABKgAFFH8jAAMFAAcIxhzrBwDhAQAFAAcIxhzrBwDhAQAEAAEIYBdVQwBSAAABKgAFFAgILQAdAOYUAA==.',['快乐']='快乐火舞流沙:BAAAKgADCggICAAAAA==.',['恋恋']='恋恋不舍:BAABKgAFFH8JAAIRAAMIhxDjUgDKAAARAAMIhxDjUgDKAAAAAA==.',['恐怖']='恐怖的力量:BAAAKgAECgUICAAAAA==.',['悄悄']='悄悄咪咪射你:BAABKgAFFH8RAAMEAAMIkiVsFwA+AQAEAAMIkiVsFwA+AQAFAAIIGh/eMwCiAAAAAA==.',['情深']='情深灬爱且浓:BAABKgAFFH8LAAIRAAQIwSD8GwDyAAARAAQIwSD8GwDyAAAAAA==.',['惊世']='惊世帅气:BAAAKgAFFAQIAgAAAA==.',['愛笨']='愛笨蛋的笨蛋:BAAAKgAECgYICQAAAA==.',['愤怒']='愤怒的小火鸡:BAABKgAECn9BAAIOAAgIYyKeBwCzAgAOAAgIYyKeBwCzAgAAAA==.愤怒的牛牛:BAABKgAFFH8LAAIRAAMI6gdmYQCtAAARAAMI6gdmYQCtAAAAAA==.',['我们']='我们是十七强:BAABKgAFFH8QAAIMAAQIyB+/CwASAQAMAAQIyB+/CwASAQAAAA==.',['我头']='我头上小犄角:BAAAKgADCgMIAwAAAA==.',['我开']='我开我开:BAAAKgAECgQIBAAAAA==.',['我的']='我的闪现呢丶:BAABKgAFFH8IAAIOAAgIUBMJAwDhAQAOAAgIUBMJAwDhAQAAAA==.',['打上']='打上花火:BAAAKgAFFAEIAQAAAA==.',['扛三']='扛三刀:BAACKgAFFH8HAAIRAAMIuA/nJwDTAAARAAMIuA/nJwDTAAAqAAQKfxYAAhEACAgcHoJGABwCABEACAgcHoJGABwCAAAA.',['扬天']='扬天漫雪:BAAAKgAECgYIBwAAAA==.',['扬州']='扬州刘海柱:BAAAKgAECgIIAgAAAA==.',['扶苏']='扶苏:BAABKgAFFH8HAAIYAAQIZCUKEAAtAQAYAAQIZCUKEAAtAQAAAA==.',['技高']='技高一筹:BAAAKgAECgYIBgAAAA==.',['护国']='护国神喵:BAAAKgADCggICAAAAA==.',['拉维']='拉维蒂亚:BAAAKgAECgcIBwAAAA==.',['拳王']='拳王福汉:BAABKgAFFH8NAAMXAAYIoxXgCABdAQAXAAYIoxXgCABdAQAYAAMI9R+HCAAkAQAAAA==.',['拽破']='拽破猎猎:BAAAKgAECgEIAQAAAA==.',['挖的']='挖的一手好坟:BAAAKgAECgYICgAAAA==.',['挥挥']='挥挥手全是狗:BAAAKgAECgMIAwAAAA==.',['捌零']='捌零伍:BAAAKgADCgEIAQAAAA==.',['改个']='改个名字:BAAAKgAECggICAABKgAFFAgIHgAJABseAA==.',['救赎']='救赎灵魂:BAAAKgADCgMIAwAAAA==.',['敖兴']='敖兴:BAABKgAFFH8IAAIeAAQIxAQACACAAAAeAAQIxAQACACAAAAAAA==.',['斩杀']='斩杀冲钅未归:BAAAKgAECgUIBgAAAA==.',['旋转']='旋转吧:BAABKgAFFH8GAAISAAYIPB86AQDiAQASAAYIPB86AQDiAQABKgAFFAgILQAfAG8iAA==.',['无关']='无关风月丶:BAAAKgAECgYIBgAAAA==.',['无夜']='无夜:BAAAKgAECgYICQAAAA==.',['无昼']='无昼:BAAAKgADCgEIAQAAAA==.',['无良']='无良猎艳弓:BAAAKgADCggICAAAAA==.',['明天']='明天天晴:BAAAKgAFFAQIBAAAAA==.',['昔影']='昔影丿:BAAAKgAFFAQIAgABKgAFFAgIDgAPACQgAA==.',['星星']='星星相惜:BAABKgAFFH8iAAMHAAQIJhlhBgDdAAAHAAQIJhlhBgDdAAAGAAMIwgh/HACdAAAAAA==.',['星河']='星河弥漫:BAAAKgAECgQIBAAAAA==.',['晨月']='晨月灬:BAAAKgAECgQIBQAAAA==.',['普通']='普通上班族:BAAAKgAECgIIAgAAAA==.',['晴天']='晴天丶二哈:BAAAKgAFFAQIBAAAAA==.晴天娃娃:BAAAKgAECgQIBwAAAA==.晴天小猪灬:BAAAKgAFFAIIAgAAAA==.',['暗夜']='暗夜公决:BAABKgAFFH8GAAIgAAQIfAMyBgCQAAAgAAQIfAMyBgCQAAAAAA==.',['暗牧']='暗牧:BAAAKgAFFAQIBAAAAA==.',['暗藏']='暗藏鸿霓:BAABKgAFFH8GAAISAAYIuA+LGQBNAQASAAYIuA+LGQBNAQAAAA==.',['曹将']='曹将军巭:BAAAKgAECgIIAgAAAA==.',['最高']='最高:BAAAKgADCggIEAAAAA==.',['月下']='月下:BAAAKgADCggICAAAAA==.',['月亮']='月亮岛扛把子:BAAAKgADCggICAAAAA==.',['木馬']='木馬摇摇乐:BAAAKgAFFAQIAQAAAA==.',['杀魔']='杀魔救拧:BAAAKgAECgYICwAAAA==.',['李东']='李东西:BAAAKgAFFAQIBAAAAA==.',['李建']='李建晨:BAAAKgADCgEIAQAAAA==.',['极地']='极地大乱斗:BAABKgAFFH8KAAIRAAYI6w+dKQBBAQARAAYI6w+dKQBBAQAAAA==.',['果菓']='果菓娃:BAAAKgAECgEIAQAAAA==.',['枫林']='枫林唤雨:BAABKgAECn8wAAMJAAgInRZ/FQCMAQAJAAgInRZ/FQCMAQAMAAEIAADQhgAAAAAAAA==.枫林星辰:BAABKgAECn8jAAIcAAgIxhMEEwB6AQAcAAgIxhMEEwB6AQAAAA==.枫林望舒:BAAAKgAECgYIBgAAAA==.枫林沐白:BAABKgAECn8iAAIZAAgIAA26GQAIAQAZAAgIAA26GQAIAQAAAA==.枫林火山:BAABKgAECn8pAAIPAAgIIxT9EQCzAQAPAAgIIxT9EQCzAQAAAA==.枫林灵泽:BAAAKgAECgMIAwAAAA==.枫林翻雨:BAABKgAECn8gAAILAAgIRRRnDAC3AQALAAgIRRRnDAC3AQAAAA==.枫林苍月:BAABKgAECn8mAAIYAAgIHBeGCQCoAQAYAAgIHBeGCQCoAQAAAA==.枫林覆雨:BAABKgAECn8aAAIHAAgIhxXDCAC2AQAHAAgIhxXDCAC2AQAAAA==.枫林雷鸣:BAABKgAECn8WAAMhAAgIQhJiDgA3AQAhAAgIQhJiDgA3AQAgAAcI6wXnIAAKAQAAAA==.枫林骄阳:BAABKgAECn8yAAMRAAgIcR+mCwCNAgARAAgIcR+mCwCNAgAQAAEIZAAAAAAAAAAAAA==.枫林龍舞:BAABKgAECn8tAAMeAAgIbxCNBQBQAQAeAAgIbxCNBQBQAQAdAAgIcgcmRQDHAAAAAA==.',['柠檬']='柠檬心:BAABKgAFFH8KAAQGAAQIQRxYDQD2AAAGAAQIQRxYDQD2AAAIAAII+ROaFQB9AAAHAAEIAAA0JQAAAAAAAA==.柠檬茶茶:BAABKgAFFH8GAAIPAAYIJgwPFwAsAQAPAAYIJgwPFwAsAQAAAA==.柠檬贼贼:BAABKgAFFH8IAAIhAAgIFx3jAwBrAgAhAAgIFx3jAwBrAgAAAA==.',['栗桃']='栗桃婉:BAAAKgAECgEIAQAAAA==.',['核弹']='核弹奶糖:BAABKgAFFH8IAAIZAAgIPAoeBwCHAQAZAAgIPAoeBwCHAQAAAA==.',['格林']='格林卡本:BAABKgAFFH8FAAIEAAIInBN6OgCAAAAEAAIInBN6OgCAAAAAAA==.',['桃花']='桃花面:BAAAKgADCggICAAAAA==.',['梅川']='梅川熊昭:BAAAKgADCgEIAQAAAA==.',['梦影']='梦影丿:BAABKgAFFH8IAAMUAAQICRO3CgDbAAAUAAQICRO3CgDbAAASAAQI1g1wHQDJAAAAAA==.',['橙色']='橙色风暴:BAAAKgADCgEIAQAAAA==.',['正义']='正义化身:BAAAKgAECgUIBQAAAA==.',['死亡']='死亡赞美诗:BAAAKgAECggIEAAAAA==.',['死缠']='死缠了不用奶:BAACKgAFFH8mAAMGAAcIfiHzCQDsAQAGAAcI6iDzCQDsAQAIAAMILCZpCADmAAAqAAQKfyAAAgYACAhZJOYBAM4CAAYACAhZJOYBAM4CAAAA.',['比比']='比比鸟:BAAAKgAFFAYIAgAAAA==.比比龙:BAABKgAFFH8DAAIdAAMIrxU6HADdAAAdAAMIrxU6HADdAAAAAA==.',['沁园']='沁园春丶:BAAAKgAECgIIAgAAAA==.',['沃什']='沃什拉基:BAAAKgADCggICAAAAA==.',['沙漏']='沙漏倒装回忆:BAAAKgAECgIIAgAAAA==.',['没有']='没有我很重要:BAABKgAFFH8UAAMYAAYIrBW/AgCjAQAYAAYIrBW/AgCjAQAXAAUINRPgCAD3AAABKgAFFAgILQAfAG8iAA==.',['法力']='法力残渣:BAABKgAFFH8OAAQOAAYIyyK6AQA8AQAPAAYIjx0iEABrAQAOAAQIMCK6AQA8AQATAAQIJSGLGADnAAAAAA==.',['泰勒']='泰勒德顿:BAAAKgAFFAYIBAAAAA==.',['洗月']='洗月:BAABKgAECn8eAAISAAcIYRgqQgChAQASAAcIYRgqQgChAQAAAA==.',['洛依']='洛依依:BAABKgAFFH8JAAMaAAMIPgqgHwB+AAAaAAIIrg2gHwB+AAAZAAMIWgO9GgBnAAAAAA==.',['洛阿']='洛阿神佑之血:BAAAKgADCgUIBQAAAA==.',['派大']='派大星:BAAAKgADCgMIAwAAAA==.',['流氓']='流氓的术师:BAABKgAFFH8LAAIGAAgI8Bc5BgAyAgAGAAgI8Bc5BgAyAgAAAA==.',['海豚']='海豚炒年糕:BAAAKgAFFAYIAQAAAA==.',['海魄']='海魄:BAAAKgAFFAQIBAAAAA==.',['混学']='混学带师:BAAAKgAECggICAABKgAFFAgIAgAVAAAAAA==.',['渡火']='渡火者的解脱:BAACKgAFFH8nAAQIAAgIIR+AAgCAAQAIAAUI/yKAAgCAAQAGAAYIEhytCgALAQAHAAIIXh32JABQAAAqAAQKfxoABAYACAgQHaoUAEgCAAYACAgQHaoUAEgCAAgAAQh7JisxAG0AAAcAAgieAlSEACAAAAAA.',['渣男']='渣男耍闪电:BAAAKgAECgUICAAAAA==.',['湛岚']='湛岚晨辉:BAABKgAFFH8FAAMQAAUI4wQBKABQAAAQAAQIWQIBKABQAAAbAAEI8Q2XGwBJAAAAAA==.',['满怒']='满怒斩:BAAAKgADCggICAAAAA==.',['激流']='激流涌进:BAAAKgAECgQIBAAAAA==.',['瀛丶']='瀛丶:BAAAKgAECgIIAgAAAA==.',['火狐']='火狐天使:BAAAKgADCggICAAAAA==.火狐蛮萨:BAAAKgADCggIDgAAAA==.',['火雨']='火雨法:BAABKgAFFH8KAAQIAAYIRhKMBwALAQAIAAQIQhSMBwALAQAGAAQI3RKjEADkAAAHAAIInwUtLgA+AAAAAA==.',['灬寵']='灬寵愛灬:BAAAKgAECgEIAQAAAA==.',['灬小']='灬小白:BAABKgAFFH8MAAIhAAYISSTMAQC7AQAhAAYISSTMAQC7AQAAAA==.',['灬李']='灬李白:BAAAKgADCgEIAQAAAA==.',['灬龍']='灬龍先生:BAAAKgADCgcIBwAAAA==.',['灰之']='灰之魔女:BAABKgAECn8ZAAIRAAgI+RxxPAA6AgARAAgI+RxxPAA6AgAAAA==.',['灵魂']='灵魂使徒:BAAAKgADCggICAAAAA==.',['烟雨']='烟雨泷:BAACKgAFFH8sAAMEAAgIAx+gBQA9AgAEAAcIuiCgBQA9AgAFAAMI/RqSFwClAAAqAAQKfx4AAwUACAj3IskQAHMCAAUABwhKJckQAHMCAAQABwgJILxIANoBAAAA.烟雨落流星:BAAAKgAFFAEIAQAAAA==.烟雨龙:BAAAKgAECgYIBgABKgAFFAQICwAbAGcaAA==.',['焚天']='焚天帝:BAAAKgAECgYIBgAAAA==.',['片刻']='片刻安宁:BAACKgAFFH8ZAAIaAAgISyKCAAAgAgAaAAgISyKCAAAgAgAqAAQKfxQAAxoACAh2JYUDANoCABoACAgPJIUDANoCABkABgghHAY7AFABAAAA.',['牛丸']='牛丸师傅:BAAAKgAECgIIAQAAAA==.',['牛牛']='牛牛一逐风者:BAAAKgAECggIBgABKgAFFAgIDgAJABUPAA==.牛牛来辣:BAAAKgAECgcICAAAAA==.',['牛皮']='牛皮德:BAAAKgAFFAIIBAAAAA==.',['牧欢']='牧欢欢:BAAAKgAFFAMIAwAAAA==.',['狐人']='狐人老千:BAABKgAFFH8FAAIPAAUIGgqSLwCmAAAPAAUIGgqSLwCmAAAAAA==.',['猎天']='猎天使男爵:BAAAKgAECgEIAQAAAA==.',['猛练']='猛练:BAAAKgAECgQIBAAAAA==.',['玲珑']='玲珑馆美纱夜:BAAAKgAECggICAAAAA==.',['琥糖']='琥糖:BAABKgAFFH8IAAQPAAYIWhwMJgDJAAATAAIIfCH9IgDLAAAPAAQImRgMJgDJAAAOAAIIPResFQCGAAAAAA==.',['电疗']='电疗不包熟:BAAAKgAECgUICwAAAA==.',['男的']='男的有奶:BAABKgAFFH8FAAMWAAQImw+UBwCVAAAWAAQImw+UBwCVAAASAAEIAACzNQAAAAAAAA==.',['痛苦']='痛苦的月色:BAAAKgAECgYIDAAAAA==.',['白小']='白小纯:BAAAKgAECgYICAAAAA==.',['白牛']='白牛警长:BAAAKgADCgQIBAAAAA==.',['白皮']='白皮丶牧:BAAAKgADCgMIAwAAAA==.',['盗就']='盗就贼:BAAAKgAECgUIBQAAAA==.',['盲侠']='盲侠:BAAAKgADCgEIAQAAAA==.',['相反']='相反面:BAAAKgAECgEIAQAAAA==.',['真凉']='真凉酱大胜利:BAABKgAFFH8OAAICAAgIfyEzAADVAgACAAgIfyEzAADVAgAAAA==.',['睚眦']='睚眦丶:BAAAKgAECgIIAgAAAA==.',['短脚']='短脚蟹:BAABKgAECn8aAAIEAAgIOhluKwABAgAEAAgIOhluKwABAgAAAA==.',['磷霖']='磷霖:BAAAKgAECgEIAQAAAA==.',['神力']='神力:BAABKgAFFH8TAAMcAAgIKSMeAQDiAgAcAAgIKSMeAQDiAgANAAII0hbxCgDEAAAAAA==.',['神慕']='神慕慕:BAAAKgAECgYIDAAAAA==.',['神战']='神战科比:BAAAKgADCgMIAwAAAA==.',['福福']='福福小仙:BAAAKgADCggICAAAAA==.',['窗外']='窗外萤火:BAAAKgAECgIIAgAAAA==.',['窥天']='窥天姬:BAAAKgAFFAQIBAAAAA==.',['粉皮']='粉皮丶骑:BAAAKgAECgMIAwAAAA==.',['精灵']='精灵丶猎:BAAAKgAECgEIAgAAAA==.',['紫皮']='紫皮咕咕:BAABKgAFFH8GAAIGAAYI+BKdAwCHAQAGAAYI+BKdAwCHAQAAAA==.',['紫蝶']='紫蝶:BAAAKgAECgYIBgAAAA==.',['紫金']='紫金之魂:BAAAKgAECgYIEwAAAA==.',['红毛']='红毛强盗:BAAAKgAECgMIAwAAAA==.',['红皮']='红皮丶死骑:BAAAKgAECgYIBgAAAA==.',['红糖']='红糖糍粑:BAAAKgAECgEIAQAAAA==.',['纪念']='纪念丶回忆:BAABKgAECn8UAAIcAAgIoBoAHAAxAgAcAAgIoBoAHAAxAgAAAA==.',['给你']='给你个大毕斗:BAAAKgAECgEIAQAAAA==.',['绿皮']='绿皮丶萨:BAACKgAFFH8KAAIJAAMIYBcjLQDCAAAJAAMIYBcjLQDCAAAqAAQKfxcAAgkACAiCEbs+AIsBAAkACAiCEbs+AIsBAAAA.',['罖杔']='罖杔嵤皐:BAAAKgAECggICAAAAA==.',['老宫']='老宫:BAACKgAFFH8pAAIhAAgI+RmFBABVAgAhAAgI+RmFBABVAgAqAAQKfxwAAyEACAi/HuQRABICACEACAjsHeQRABICACAABQhcCc0jAOgAAAAA.',['老麻']='老麻汉:BAAAKgADCgIIAgAAAA==.',['耶梦']='耶梦伽得:BAAAKgAFFAYIAQAAAA==.',['职业']='职业道德:BAAAKgADCgEIAQAAAA==.',['肆维']='肆维丶:BAABKgAFFH8IAAIRAAgIpBfMBwBHAgARAAgIpBfMBwBHAgAAAA==.',['肉丨']='肉丨包丨子:BAAAKgADCgIIAgAAAA==.',['肉六']='肉六:BAABKgAFFH8GAAMOAAYI6RFVBgAwAQAOAAUIYxRVBgAwAQAPAAEIAwiZKAA4AAAAAA==.',['胖迪']='胖迪凯:BAAAKgAECgIIBAAAAA==.',['脑浆']='脑浆:BAACKgAFFH8nAAIGAAUIqBc3EAAwAQAGAAUIqBc3EAAwAQAqAAQKfzAAAgYACAgdJBYCAMYCAAYACAgdJBYCAMYCAAAA.',['自己']='自己开减伤:BAAAKgADCgUIBQAAAA==.',['自找']='自找伞渡:BAAAKgAECgUIBQAAAA==.',['艾希']='艾希丨灬女王:BAAAKgAECgUIBQAAAA==.',['花都']='花都唐:BAAAKgAECgQIBAAAAA==.',['苍月']='苍月厶塞亚:BAAAKgAECgYIDQAAAA==.',['茉莉']='茉莉乌龙无糖:BAABKgAFFH8GAAITAAYI5xQTBgCjAQATAAYI5xQTBgCjAQAAAA==.',['荡漾']='荡漾波:BAAAKgAECggICAAAAA==.',['莎莎']='莎莎蜜:BAAAKgADCgEIAQAAAA==.',['莽夫']='莽夫的寒冬:BAAAKgAECgMIBQAAAA==.',['菲米']='菲米莉丝:BAABKgAECn9GAAIRAAgI/x3xDwBbAgARAAgI/x3xDwBbAgAAAA==.',['萨不']='萨不住了:BAACKgAFFH8OAAIJAAYIDR/XBwDLAQAJAAYIDR/XBwDLAQAqAAQKfxUAAwwACAi4EVxFAA4BAAwABggnDlxFAA4BAAkACAg5AyV1AOMAAAAA.',['萨拉']='萨拉丁之力:BAAAKgAECgcIEgAAAA==.',['萨爷']='萨爷:BAABKgAFFH8GAAIJAAYInwkBFwAmAQAJAAYInwkBFwAmAQAAAA==.',['蒂姆']='蒂姆波顿:BAABKgAFFH8GAAMDAAQIxAg9FQC6AAADAAMIxAg9FQC6AAAaAAII0RHBJQBMAAAAAA==.',['蒼瀾']='蒼瀾:BAABKgAECn8WAAIZAAgIIBlnHwDJAQAZAAgIIBlnHwDJAQAAAA==.',['蔚来']='蔚来猎不打人:BAAAKgAFFAQIBAAAAA==.',['薩爾']='薩爾:BAAAKgADCgIIAgAAAA==.',['蛮干']='蛮干:BAABKgAFFH8GAAIcAAYIHhVRCwCWAQAcAAYIHhVRCwCWAQAAAA==.',['蛮斯']='蛮斯坦:BAABKgAFFH8GAAIJAAYIfhG3DwBaAQAJAAYIfhG3DwBaAQAAAA==.',['血兽']='血兽来了:BAABKgAFFH8PAAIaAAYIjiODAAAeAgAaAAYIjiODAAAeAgABKgAFFAgILQAfAG8iAA==.',['血刃']='血刃天下:BAAAKgAFFAIIAgAAAA==.',['血源']='血源病注射器:BAACKgAFFH8sAAQUAAgI0RQYBwChAQAUAAYIVBYYBwChAQAiAAQIlxl8AgBVAQASAAQI+CN6BgBAAQAqAAQKfx4ABBIACAhpJUoSAJoCABIACAhDI0oSAJoCABQAAwixF1VFAM0AACIAAgjoIZolAGsAAAAA.',['西楚']='西楚霸王项羽:BAAAKgAFFAYIBAAAAA==.',['西菛']='西菛大吹雪:BAABKgAECn8cAAIRAAgIoRqJbADAAQARAAgIoRqJbADAAQAAAA==.',['諾夕']='諾夕:BAAAKgADCggICgAAAA==.',['请你']='请你吃丿牛鞭:BAAAKgAECgEIAQAAAA==.',['请叫']='请叫我三鹿:BAAAKgADCggICAAAAA==.',['诸神']='诸神:BAABKgAECn8xAAMCAAgIsBWBFgCkAQACAAgIsBWBFgCkAQAjAAMIPAXbagAZAAAAAA==.',['诸葛']='诸葛二细:BAAAKgAECgYICgABKgAFFAgIDgAXANAQAA==.',['贝黑']='贝黑摩斯:BAABKgAFFH8IAAICAAgIngfiCwCeAQACAAgIngfiCwCeAQAAAA==.',['贫僧']='贫僧丶唐三葬:BAABKgAECn8dAAICAAgIJBRKNwB5AQACAAgIJBRKNwB5AQAAAA==.',['躺客']='躺客:BAAAKgADCggICAAAAA==.',['轻语']='轻语:BAAAKgADCgcIBwAAAA==.',['辉月']='辉月灬:BAABKgAFFH8LAAMbAAQIZxqVBQDxAAAbAAQIZxqVBQDxAAARAAEItA8aTgBMAAAAAA==.',['辣么']='辣么丶萌:BAABKgAFFH8GAAIRAAYIuSIqDgDzAQARAAYIuSIqDgDzAQAAAA==.',['边疆']='边疆猎仁:BAAAKgADCgIIAgAAAA==.',['迷你']='迷你猪灬香橙:BAACKgAFFH8KAAIJAAMI1QsjJgCEAAAJAAMI1QsjJgCEAAAqAAQKfyMAAgkACAi3D41NAFYBAAkACAi3D41NAFYBAAAA.',['逆流']='逆流而下:BAABKgAFFH8GAAIJAAYIoxVJAQCpAQAJAAYIoxVJAQCpAQAAAA==.',['遥遥']='遥遥无期:BAACKgAFFH8XAAMEAAQI4hkPHgDeAAAEAAQI4hkPHgDeAAAFAAMI4QgTNgCcAAAqAAQKfxYAAgQACAhNHdIrAEQCAAQACAhNHdIrAEQCAAAA.',['邪风']='邪风小短短:BAABKgAFFH8IAAIKAAgI2R0TAgB/AgAKAAgI2R0TAgB/AgAAAA==.',['郁闷']='郁闷的菜鸡:BAABKgAFFH8GAAINAAYIHxPiCQBtAQANAAYIHxPiCQBtAQAAAA==.',['都说']='都说我小菜:BAABKgAFFH8JAAMaAAMIcRfUCgDFAAAaAAMIcRfUCgDFAAAZAAII2w7YNABtAAAAAA==.',['铁内']='铁内鬼:BAABKgAFFH8PAAIFAAUImBjoCwDtAAAFAAUImBjoCwDtAAAAAA==.',['银牛']='银牛:BAAAKgADCgIIAgAAAA==.',['锅锅']='锅锅哒:BAAAKgAECgYICAAAAA==.',['锤死']='锤死坦:BAABKgAFFH8GAAIKAAYIog8YEQAbAQAKAAYIog8YEQAbAQABKgAFFAgIBgAKABkJAA==.',['锴喵']='锴喵喵:BAAAKgADCggICAAAAA==.',['闪耀']='闪耀伊布:BAABKgAFFH8IAAIRAAgIzQKLFQBDAQARAAgIzQKLFQBDAQAAAA==.',['陌上']='陌上花开缘:BAABKgAFFH8IAAIQAAgI6Q99EAD/AAAQAAgI6Q99EAD/AAAAAA==.',['随便']='随便的我:BAABKgAFFH8IAAIUAAgImgVbBgBhAQAUAAgImgVbBgBhAQAAAA==.',['雅木']='雅木天堂:BAABKgAFFH8FAAMFAAQIHyKeBAApAQAFAAQIHyKeBAApAQAEAAEIAACTZwAAAAAAAA==.',['雷雷']='雷雷宝宝打肚:BAACKgAFFH8qAAMaAAgI6Rg9BQDqAQAaAAgI6Rg9BQDqAQADAAUItyYeBgDKAQAqAAQKfx8AAwMACAhTJkgFANcCAAMACAhTJkgFANcCABoABgiYHXEUAAEBAAAA.',['霜血']='霜血:BAAAKgADCggICAAAAA==.霜血治愈者:BAAAKgADCgEIAQAAAA==.霜血灭魔者:BAAAKgADCggICAAAAA==.',['青山']='青山远黛:BAAAKgAECgEIAgAAAA==.',['青皮']='青皮丶僧:BAAAKgADCgUIBQAAAA==.',['靓牛']='靓牛:BAAAKgAECgEIAQAAAA==.',['颓废']='颓废的败家子:BAACKgAFFH8gAAMXAAYIMBjYBwB6AQAXAAYIdBXYBwB6AQAkAAMI8xicBQDKAAAqAAQKfxsAAyQACAjBIm8EAFACACQACAhHHm8EAFACABcABwjrGnsWAPUBAAEqAAUUCAgTABIAcx8A.',['风丶']='风丶疯:BAAAKgAFFAMIAwAAAA==.',['风叔']='风叔:BAAAKgAECgMIAwAAAA==.',['风行']='风行者凯特:BAAAKgAECggIDAABKgAFFAMIBgAJAOkUAA==.',['风隐']='风隐丶:BAAAKgAFFAYIBAAAAA==.',['风雨']='风雨在途:BAAAKgAFFAIIAgABKgAFFAgICAAJALsbAA==.',['风骚']='风骚男人:BAAAKgADCggICAAAAA==.风骚的大牛:BAAAKgAFFAQIBAAAAA==.',['飞丨']='飞丨爷:BAAAKgADCgUIBQAAAA==.',['飞尐']='飞尐爺:BAAAKgAECgMIBAAAAA==.',['飞巛']='飞巛飞:BAAAKgAECgYICAAAAA==.',['飞机']='飞机炸蛋:BAABKgAFFH8KAAMJAAYIJQ3hDgAOAQAJAAYIJQ3hDgAOAQABAAQIwwmBCgC7AAAAAA==.',['飞翔']='飞翔吧:BAABKgAECn8gAAMdAAgI+QudNwAUAQAdAAgI+QudNwAUAQAeAAEIKhVyHQBBAAAAAA==.飞翔的水牛:BAAAKgAFFAQIBAAAAA==.',['饭后']='饭后来走走:BAAAKgAECgcIEgAAAA==.',['香草']='香草苹果:BAAAKgAECggICAAAAA==.',['香香']='香香的暖手器:BAAAKgADCgQIBAAAAA==.',['骑士']='骑士之怒:BAAAKgADCgYIBgAAAA==.',['骸骨']='骸骨战弓:BAAAKgAFFAEIAQAAAA==.',['高阶']='高阶祭司:BAAAKgAFFAQIBAAAAA==.',['魂帝']='魂帝:BAABKgAECn8bAAIEAAgIyBYYNwDJAQAEAAgIyBYYNwDJAQAAAA==.',['鹿南']='鹿南:BAAAKgADCgMIAwAAAA==.',['黄皮']='黄皮丶咕:BAAAKgADCgIIAgAAAA==.',['黑咖']='黑咖双糖双奶:BAABKgAFFH8JAAISAAUI0BZdIAAeAQASAAUI0BZdIAAeAQAAAA==.',['黑灬']='黑灬乌龙茶:BAAAKgADCgUIBQAAAA==.',['黑黯']='黑黯邪灵:BAAAKgADCggICAAAAA==.',['齋藤']='齋藤明日香:BAACKgAFFH8kAAICAAgIHBqOCQD2AQACAAgIHBqOCQD2AQAqAAQKfxsAAgIACAikIL0eAEwCAAIACAikIL0eAEwCAAAA.',['齐格']='齐格勒:BAABKgAFFH8IAAIZAAgIzhgOAwAiAgAZAAgIzhgOAwAiAgAAAA==.',['龙啸']='龙啸九天:BAAAKgAECgMIAwAAAA==.',['龙天']='龙天一:BAAAKgAECggICAAAAA==.',['龙腾']='龙腾四海:BAAAKgAECgEIAgAAAA==.',['龙骧']='龙骧残雪:BAAAKgAECggIDQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end