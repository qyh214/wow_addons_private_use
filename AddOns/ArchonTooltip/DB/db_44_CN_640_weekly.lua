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
 local lookup = {'DeathKnight-Frost','DemonHunter-Vengeance','DemonHunter-Havoc','Unknown-Unknown','Shaman-Elemental','Druid-Balance','Druid-Restoration','Hunter-BeastMastery','Paladin-Holy','Shaman-Restoration','Paladin-Protection','Paladin-Retribution','Monk-Brewmaster','Monk-Windwalker','Warlock-Destruction','Warrior-Fury','Warrior-Protection','Warlock-Demonology','Priest-Holy','Priest-Shadow','Hunter-Marksmanship','Mage-Arcane','Evoker-Augmentation','Evoker-Preservation','Evoker-Devastation','Warlock-Affliction','Druid-Guardian','DeathKnight-Blood','Monk-Mistweaver','Druid-Feral','Mage-Frost','DeathKnight-Unholy',}; local provider = {region='CN',realm='奥妮克希亚',name='CN',type='weekly',zone=44,date='2025-12-06',data={As='Asdsafasd:BAABLAAFFH8KAAIBAAYIeBpwIwCmAQABAAYIeBpwIwCmAQAAAA==.Ashleycole:BAAALAAECgEIAQAAAA==.',Ch='Chen:BAAALAAFFAIIAgAAAA==.',Cr='Crush:BAABLAAFFH8JAAMCAAMIRhcNDgCEAAADAAMIRheGOACxAAACAAIIvhUNDgCEAAAAAA==.',Cy='Cyanrader:BAAALAAECgYICwAAAA==.',Do='Dounnai:BAAALAAECgYICwABLAAECgYIEwAEAAAAAA==.',Fi='Fierces:BAAALAAFFAIIAgAAAA==.',Fo='Foxbaby:BAAALAAECgUIBQAAAA==.',Gi='Giko:BAAALAAECgEIAgAAAA==.Gil:BAAALAAFFAEIAQAAAA==.',Go='Goodcow:BAAALAAECgIIAgAAAA==.',Ha='Hank:BAABLAAFFH8KAAIFAAII8Ak2NwB2AAAFAAII8Ak2NwB2AAAAAA==.',Ir='Irud:BAAALAADCggIDwAAAA==.',Ki='Killa:BAABLAAFFH8FAAMGAAIIKgZmJwB1AAAGAAIIKgZmJwB1AAAHAAIIzxE6RgBYAAAAAA==.',Ma='Marianne:BAACLAAFFH8bAAIIAAYIoh/AIwCjAQAIAAYIoh/AIwCjAQAsAAQKfxYAAggABgiCHMOJAM4BAAgABgiCHMOJAM4BAAAA.',Oi='Oissii:BAACLAAFFH8GAAIJAAII1QgwIgCCAAAJAAII1QgwIgCCAAAsAAQKfx8AAgkABwiKHxcTAHgCAAkABwiKHxcTAHgCAAAA.',Pa='Pasts:BAACLAAFFH8HAAIHAAII7xL8RABlAAAHAAII7xL8RABlAAAsAAQKfyIAAgcACAgjG5kQAFMCAAcACAgjG5kQAFMCAAAA.',Pz='Pzzp:BAAALAAFFAEIAQAAAA==.',Qo='Qo:BAABLAAFFH8FAAIKAAIIdB3oPgCpAAAKAAIIdB3oPgCpAAAAAA==.',Sa='Saaryoda:BAAALAAECgMIAwAAAA==.Salute:BAABLAAFFH8hAAMKAAYIvRRJGgCKAQAKAAYIvRRJGgCKAQAFAAUI4Ax3JQAbAQAAAA==.',Sh='Shirleyone:BAAALAAFFAIIAgAAAA==.',So='Sopulaide:BAAALAADCgcIBwAAAA==.',To='Torukmakto:BAABLAAFFH8HAAILAAMIUhlaBwDvAAALAAMIUhlaBwDvAAAAAA==.',Up='Uprising:BAACLAAFFH8zAAIMAAYIwRuhGACPAQAMAAYIwRuhGACPAQAsAAQKfyEAAgwACAixHgUwALICAAwACAixHgUwALICAAAA.',Va='Vanellope:BAACLAAFFH8VAAIIAAUIWx82NgBkAQAIAAUIWx82NgBkAQAsAAQKfxgAAggABgjmH2ZDAMMBAAgABgjmH2ZDAMMBAAAA.',Wa='Walkure:BAAALAAFFAIIAgAAAA==.',['一朵']='一朵小红花:BAABLAAFFH8HAAMNAAIIvg9aGgBjAAANAAIIWg1aGgBjAAAOAAII2Q08GQA7AAAAAA==.',['一次']='一次到天明:BAACLAAFFH8IAAIIAAII0BfGhQBLAAAIAAII0BfGhQBLAAAsAAQKfxkAAggABgjHHf9LAK4BAAgABgjHHf9LAK4BAAAA.',['一盒']='一盒纯牛奶:BAAALAAECgYICgAAAA==.',['一粒']='一粒儿蛋撸橙:BAAALAAECgUIBQAAAA==.',['一路']='一路撩妹:BAAALAAECgQIBAAAAA==.',['七天']='七天五岁:BAABLAAFFH8QAAIPAAgI8RiHCwAVAgAPAAgI8RiHCwAVAgAAAA==.七天叁岁:BAABLAAFFH8JAAIPAAgIfhY/DgAjAgAPAAgIfhY/DgAjAgAAAA==.七天壹岁:BAABLAAFFH8MAAIPAAcIQx3BEgD1AQAPAAcIQx3BEgD1AQAAAA==.七天肆岁:BAABLAAFFH8OAAIPAAgIRhhCCwAXAgAPAAgIRhhCCwAXAgAAAA==.七天贰岁:BAABLAAFFH8IAAIPAAYI+xWSIgCRAQAPAAYI+xWSIgCRAQAAAA==.',['七武']='七武海:BAABLAAFFH8KAAMQAAIIzA/dTgBFAAAQAAIIkw/dTgBFAAARAAIIcAxoMwAvAAAAAA==.',['不加']='不加的骑士:BAAALAADCggICAAAAA==.',['不死']='不死青年:BAAALAAFFAIIAgAAAA==.',['专业']='专业挖毛:BAAALAAECgYICQAAAA==.',['丶愛']='丶愛玩的小貓:BAAALAAECgcIEwAAAA==.',['丶晓']='丶晓演员:BAAALAAECgYIBgAAAA==.',['为爱']='为爱起航:BAAALAAECgMIAwAAAA==.',['丿浪']='丿浪条条:BAAALAAECgYIBgAAAA==.',['久五']='久五二七:BAAALAAECgYIBgAAAA==.',['乌蒙']='乌蒙圣骑:BAABLAAECn8XAAIMAAYISiZRNwCXAgAMAAYISiZRNwCXAgAAAA==.',['云霓']='云霓洛普:BAACLAAFFH8TAAIMAAUIyBkzJQBKAQAMAAUIyBkzJQBKAQAsAAQKfxUAAgwABwjgHB1HAIcBAAwABwjgHB1HAIcBAAAA.',['五福']='五福:BAACLAAFFH8JAAIFAAIIkA6KRABEAAAFAAIIkA6KRABEAAAsAAQKfxkAAgUABwjPHGEWAPgBAAUABwjPHGEWAPgBAAAA.',['亚历']='亚历克斯:BAAALAAFFAgIAQAAAA==.',['人辶']='人辶告革:BAABLAAECn8YAAIRAAYI1hqnFgCQAQARAAYI1hqnFgCQAQAAAA==.',['人造']='人造棉:BAABLAAFFH8JAAISAAQItgyHBgDFAAASAAQItgyHBgDFAAAAAA==.',['今割']='今割大洋马:BAAALAAFFAEIAQAAAA==.',['从前']='从前车马很慢:BAAALAAECgYIDgAAAA==.',['以德']='以德扶人:BAACLAAFFH8KAAIHAAII3AmsSwBaAAAHAAII3AmsSwBaAAAsAAQKfxcAAwYABwgsElgpAC0BAAYABggrFFgpAC0BAAcABwg1B/aPAPgAAAAA.',['伊人']='伊人相忘:BAABLAAFFH8YAAITAAYIawhYHwBPAQATAAYIawhYHwBPAQAAAA==.',['伊利']='伊利琳昕:BAAALAAECgYIEQAAAA==.伊利达雷暗影:BAAALAAECgYIBgAAAA==.',['伊只']='伊只狐狸精:BAAALAAECgYICwAAAA==.',['伊多']='伊多雷:BAAALAAECgYIBgAAAA==.',['会跳']='会跳舞的熊:BAAALAADCgcICQAAAA==.',['但凡']='但凡有一点:BAAALAAECgYIBgAAAA==.',['你不']='你不懂我:BAAALAAECgUIBQAAAA==.',['你这']='你这个老六:BAAALAAECggICAAAAA==.',['侬则']='侬则香辣蟹:BAAALAADCgYIBgAAAA==.',['偷我']='偷我后场:BAAALAAECgYIBwAAAA==.',['傲视']='傲视丶群雄:BAAALAAECgMIAwAAAA==.',['先祖']='先祖忽悠你:BAAALAAECgYICAAAAA==.',['全部']='全部都想要:BAAALAAECgIIAgAAAA==.',['八神']='八神庵的怒火:BAAALAAECggIEAAAAA==.',['公仔']='公仔公仔:BAAALAAFFAIIBAAAAA==.',['公会']='公会长:BAAALAAECgYICwAAAA==.',['兰颜']='兰颜知己:BAAALAAECgYIEgAAAA==.',['兽兽']='兽兽:BAAALAADCgQIBAAAAA==.',['再起']='再起风云客:BAAALAAECgIIAgAAAA==.',['冬天']='冬天澄:BAAALAAFFAgIAgAAAA==.',['冰火']='冰火刀客:BAAALAAECgQIBQAAAA==.冰火魍魉:BAAALAAFFAIIAgAAAA==.',['冰镇']='冰镇榴莲:BAAALAAECgYIDAAAAA==.',['凉风']='凉风团:BAAALAAFFAIIAgAAAA==.',['剑啸']='剑啸江湖:BAABLAAECn8cAAIQAAYIjBhiPABoAQAQAAYIjBhiPABoAQAAAA==.',['剩奇']='剩奇石:BAABLAAFFH8MAAIMAAIIYhv4OgCiAAAMAAIIYhv4OgCiAAAAAA==.',['加不']='加不起来:BAAALAAECgYIBgAAAA==.',['勇士']='勇士:BAAALAAECgMIBwAAAA==.',['北投']='北投女巫:BAAALAAECgYIBgAAAA==.',['十三']='十三厶:BAABLAAECn8YAAIJAAYIcxw+EADwAQAJAAYIcxw+EADwAQAAAA==.',['十五']='十五楼的娇娇:BAAALAAFFAMIBAAAAA==.',['十字']='十字相乘法:BAAALAAFFAIIBAAAAA==.',['十年']='十年人间丶:BAABLAAFFH8dAAILAAYI7hnsBACYAQALAAYI7hnsBACYAQAAAA==.',['千尾']='千尾离鸢:BAACLAAFFH8NAAITAAIIgAaWRQBgAAATAAIIgAaWRQBgAAAsAAQKfxoAAxMABwjSC+A4AAcBABMABwjSC+A4AAcBABQAAwgDDVo6AJIAAAEsAAUUBQgPAA4A2gkA.',['午夜']='午夜丶观星者:BAAALAAECgMIAwAAAA==.午夜丶雷神:BAAALAAECggIAgAAAA==.',['卡姿']='卡姿兰大眼睛:BAAALAADCgQIBAAAAA==.',['厄难']='厄难骑士:BAACLAAFFH8SAAIMAAUIiBRFKQAzAQAMAAUIiBRFKQAzAQAsAAQKfyEAAwwACAioH+kZAEACAAwACAioH+kZAEACAAsABggQCKQvAKYAAAAA.',['叁月']='叁月七:BAAALAAECgYIBwABLAAECgYIEwAEAAAAAA==.',['叉班']='叉班笛格子:BAAALAAECgYIBgAAAA==.',['双鱼']='双鱼座吃鱼头:BAAALAAECggICAAAAA==.',['可乐']='可乐真好喝:BAAALAAECgMIAwAAAA==.',['可爱']='可爱:BAABLAAFFH8NAAIPAAUIWwyxQADtAAAPAAUIWwyxQADtAAAAAA==.可爱的威啵:BAAALAAECgMIAwAAAA==.',['可青']='可青可:BAAALAAFFAEIAQAAAA==.',['吾名']='吾名孟德:BAAALAAECgIIAgAAAA==.',['呼你']='呼你两锤子:BAAALAAECggIDAAAAA==.',['咱霸']='咱霸:BAAALAAECgQIBgAAAA==.',['品精']='品精无再雪暴:BAAALAAECgYIEAAAAA==.',['善缘']='善缘好运:BAAALAAECgEIAQAAAA==.',['喑哑']='喑哑无言:BAAALAAECgIIAgAAAA==.',['噢唔']='噢唔先生:BAAALAAECgUIBQABLAAFFAMIDAAVAF8SAA==.',['噩耗']='噩耗:BAAALAAECgYIBgAAAA==.',['土包']='土包狼来了:BAAALAAECgQIBgAAAA==.',['圣殿']='圣殿骑士:BAABLAAECn8mAAMMAAgIAQlo6ABOAQAMAAgIugho6ABOAQALAAYIQAX3MgCQAAAAAA==.',['圣陨']='圣陨:BAAALAADCgQIAgAAAA==.',['坑地']='坑地天坑基友:BAAALAAECgYIEAAAAA==.',['埋姑']='埋姑娘的:BAAALAAECgYIDQAAAA==.',['塞巴']='塞巴斯帝安:BAAALAAECggIDwAAAA==.',['塞班']='塞班:BAAALAAECgYIBgAAAA==.',['壞喃']='壞喃魜:BAABLAAECn8fAAIIAAYIVg2EqQAMAQAIAAYIVg2EqQAMAQAAAA==.',['夏未']='夏未央夜微凉:BAAALAAECgYIBgAAAA==.',['夏沫']='夏沫星辰:BAABLAAFFH8iAAMMAAYIRQmBKAA3AQAMAAYIygiBKAA3AQALAAIIgw30HgAuAAAAAA==.',['夜月']='夜月花朝念:BAAALAAECgcIBQAAAA==.',['大德']='大德公:BAAALAAFFAEIAQAAAA==.大德无形:BAABLAAFFH8GAAIGAAII7QaUJgB4AAAGAAII7QaUJgB4AAAAAA==.',['大熊']='大熊饼干:BAAALAAECgYIBwAAAA==.',['大爷']='大爷来了:BAAALAAECgcIBwAAAA==.',['天堂']='天堂的悲悼:BAABLAAECn8UAAIHAAcIfBL2LAB+AQAHAAcIfBL2LAB+AQAAAA==.',['天灾']='天灾之主:BAABLAAFFH8UAAIBAAUITxeFPABJAQABAAUITxeFPABJAQAAAA==.',['天蓝']='天蓝色风暴:BAAALAAECgYICwAAAA==.',['奉西']='奉西:BAABLAAFFH8OAAIWAAUI/B5wKAByAQAWAAUI/B5wKAByAQAAAA==.',['奥妮']='奥妮克希雅:BAAALAAECgcIBwAAAA==.',['奶力']='奶力爆炸:BAAALAAECgIIAgAAAA==.',['如烟']='如烟:BAAALAADCgQIBAAAAA==.',['妙影']='妙影:BAAALAAECgYICQAAAA==.',['妮露']='妮露:BAAALAADCgYIBgAAAA==.',['娇娇']='娇娇:BAAALAAECgUIBwAAAA==.',['媛沐']='媛沐歌谣:BAAALAAECgUICgAAAA==.',['孤芳']='孤芳怎自赏:BAAALAAECgYIDAAAAA==.',['孽畜']='孽畜快现形:BAAALAADCgYIBwAAAA==.',['宁渊']='宁渊:BAAALAAFFAIIAgAAAA==.',['宅牛']='宅牛牛:BAAALAAECgYICgAAAA==.',['安苏']='安苏的梯:BAAALAAECggICAAAAA==.',['宋叉']='宋叉叉:BAAALAAFFAQIBAAAAA==.',['小小']='小小快跑:BAABLAAFFH8oAAIWAAYICR92FwDEAQAWAAYICR92FwDEAQAAAA==.小小沫娴:BAAALAAECgIIAgABLAAFFAEIAQAEAAAAAA==.小小的尖牙妹:BAAALAAECggICAAAAA==.',['小心']='小心丨有电:BAAALAAECgMIAwAAAA==.',['小手']='小手冷冷:BAAALAADCgIIAgAAAA==.',['小拾']='小拾壹:BAABLAAFFH8oAAQXAAgINRoiAgA+AgAXAAgI+BciAgA+AgAYAAgIPBFMBQA7AgAZAAQI2xcFCwBZAQAAAA==.',['小沫']='小沫小娴:BAAALAAFFAEIAQAAAA==.',['小螺']='小螺号嘀嘀吹:BAAALAAECgIIAgAAAA==.',['小霪']='小霪虫:BAABLAAFFH8QAAIPAAYIZiDSGwCyAQAPAAYIZiDSGwCyAQAAAA==.',['尼古']='尼古拉斯牛崽:BAABLAAFFH8OAAMKAAIIhx58NgCUAAAKAAIIhx58NgCUAAAFAAIIug6LRgBBAAAAAA==.',['岚魂']='岚魂倩影:BAAALAADCgYIBgAAAA==.',['川祺']='川祺:BAAALAADCggICAAAAA==.',['工具']='工具人败家:BAAALAAFFAYIAwAAAA==.',['巧克']='巧克力牛奶:BAAALAAECgYIDgAAAA==.',['差丶']='差丶是美女:BAAALAADCgYIBgAAAA==.',['希尔']='希尔文:BAAALAAFFAIIAgAAAA==.',['帝牙']='帝牙卢卡:BAAALAAECgYIEgAAAA==.',['带刀']='带刀不带伞:BAAALAADCgEIAQAAAA==.',['平淡']='平淡淡:BAAALAADCgEIAQAAAA==.',['幽幽']='幽幽相随:BAABLAAECn8WAAIIAAYIbSIHegDpAQAIAAYIbSIHegDpAQAAAA==.',['康师']='康师傅冰火茶:BAAALAADCggICAAAAA==.',['开心']='开心澄:BAABLAAFFH8GAAMJAAIIsiOEHQC4AAAJAAIIsiOEHQC4AAALAAIIcAlJHgAvAAAAAA==.',['御尸']='御尸大夫:BAAALAADCgIIAgAAAA==.',['德丨']='德丨的笑:BAAALAADCgUIBQAAAA==.',['德了']='德了:BAAALAAECgYIBgAAAA==.',['心跳']='心跳呼吸:BAAALAAECgEIAQAAAA==.',['心随']='心随我動:BAAALAAECgYIBwAAAA==.',['忠犬']='忠犬美利坚:BAAALAADCgUIBQAAAA==.',['急速']='急速萝卜:BAAALAAECggICQAAAA==.',['恬遐']='恬遐巫贼:BAAALAAECgEIAQAAAA==.',['恶魔']='恶魔數:BAAALAAECgcIEAAAAA==.',['悲伤']='悲伤猪大肠:BAAALAAECgYIBwAAAA==.',['想不']='想不出名字了:BAACLAAFFH8TAAMPAAQI4xheHABVAQAPAAQI4xheHABVAQASAAEIpwk+LwBEAAAsAAQKfyIABBIACAjSHH8eAAsCABIABgjFIH8eAAsCAA8ABQi6ENivABkBABoAAgg7DFAyAGsAAAAA.',['惹得']='惹得起个锤子:BAABLAAFFH8IAAIIAAYICx3NKwCGAQAIAAYICx3NKwCGAQAAAA==.',['慕容']='慕容烟花:BAAALAAECggIDAAAAA==.',['成年']='成年亚洲象:BAAALAADCgUIBQAAAA==.',['我不']='我不是奶:BAAALAAFFAgIAwAAAA==.',['我来']='我来抓人了:BAAALAAFFAIIAgAAAA==.我来时的路:BAACLAAFFH8RAAIMAAMI5RoXFwADAQAMAAMI5RoXFwADAQAsAAQKfxYAAgwACAiCIRUbADkCAAwACAiCIRUbADkCAAAA.我来玩活你:BAAALAAECgYICgAAAA==.',['我玩']='我玩活你:BAAALAAECgcICgAAAA==.',['战战']='战战奇胜:BAAALAAECgYIDQAAAA==.',['戴達']='戴達洛斯:BAAALAAECgEIAQAAAA==.',['扑街']='扑街猫:BAAALAAECgUIBgAAAA==.',['扬帆']='扬帆不用风:BAABLAAFFH8FAAIbAAUIOguxBQC+AAAbAAUIOguxBQC+AAAAAA==.',['扯蛋']='扯蛋因步子大:BAAALAAECgcIDQAAAA==.',['抹茶']='抹茶炒蛋:BAAALAAFFAIIBAAAAA==.',['拂灬']='拂灬叶:BAAALAAECgUIBQAAAA==.',['拉蒂']='拉蒂欧斯:BAAALAAECggIEgAAAA==.',['提里']='提里奥皮卡丘:BAAALAAECgYIEwAAAA==.',['搅局']='搅局者:BAAALAAECgYIDAAAAA==.',['无双']='无双丶战神:BAAALAAECggIEQAAAA==.',['无敌']='无敌小七:BAABLAAECn8gAAMLAAgIMhUAEgCTAQALAAgIMhUAEgCTAQAMAAIIig7NWQF+AAAAAA==.无敌最俊朗:BAABLAAFFH8GAAIQAAIIyRFCUgBCAAAQAAIIyRFCUgBCAAAAAA==.无敌最凶狠:BAABLAAFFH8UAAMFAAgIERZTBwBEAgAFAAgIERZTBwBEAgAKAAUI5wnuMQDiAAAAAA==.',['无明']='无明逆流:BAAALAAFFAIIAgAAAA==.',['无畏']='无畏先生:BAAALAADCgYIBgAAAA==.',['旧梦']='旧梦:BAAALAADCgQIAwAAAA==.',['时间']='时间嘚玫瑰:BAABLAAFFH8bAAIHAAYIHBOkFADTAAAHAAYIHBOkFADTAAAAAA==.',['明明']='明明不可以:BAAALAAFFAIIBAAAAA==.',['春梦']='春梦了无痕:BAAALAAECgMIAwAAAA==.',['昭明']='昭明:BAAALAAECgEIAQAAAA==.',['晚来']='晚来天欲雪丶:BAAALAADCgMIAwAAAA==.',['普罗']='普罗塔斯:BAABLAAECn8UAAIKAAgIqRzBMABQAgAKAAgIqRzBMABQAgAAAA==.',['暗夜']='暗夜翎雨:BAACLAAFFH8IAAIDAAIIpQJhbQAqAAADAAIIpQJhbQAqAAAsAAQKfxgAAgMABghzCIl8ALMAAAMABghzCIl8ALMAAAAA.',['暗影']='暗影绝殇:BAABLAAECn8aAAMBAAgIZQrecAANAQABAAgINQjecAANAQAcAAEIABeLLgBEAAAAAA==.',['曾经']='曾经的你:BAAALAADCgQIBAAAAA==.',['最萌']='最萌蛋蛋:BAAALAAECgQIBAAAAA==.',['有种']='有种下课单挑:BAAALAAFFAIIAgAAAA==.',['本间']='本间芽衣子:BAAALAADCgMIAwAAAA==.',['李勾']='李勾:BAAALAAFFAIIBAAAAA==.',['李知']='李知晓:BAAALAADCgEIAQAAAA==.',['杏仁']='杏仁豆腐:BAABLAAFFH85AAIBAAYIUSNxCwABAgABAAYIUSNxCwABAgAAAA==.',['杠丨']='杠丨灬丨开:BAAALAAFFAIIAgAAAA==.',['极光']='极光净土:BAAALAADCgYIBgAAAA==.',['林间']='林间风清扬:BAAALAAECgYIDQAAAA==.',['枫叶']='枫叶梅香:BAAALAADCgQIBAAAAA==.',['枫林']='枫林邪萨:BAAALAAECgIIAgAAAA==.',['枯牧']='枯牧逢春:BAAALAAFFAIIAgAAAA==.',['格格']='格格巫:BAAALAAECgYIEAAAAA==.',['梦断']='梦断蓝桥:BAAALAAECgQIBQAAAA==.',['棒棒']='棒棒有点粗:BAAALAAECgIIAgAAAA==.',['楞头']='楞头青:BAAALAAECgYIDwAAAA==.',['榴莲']='榴莲侠:BAAALAAECgYIDQAAAA==.',['橙子']='橙子菠萝汁:BAABLAAFFH8KAAMMAAYI7AkgNgDQAAAMAAYI7AkgNgDQAAAJAAIIhR0lFgCsAAAAAA==.',['橙鱼']='橙鱼零度空间:BAACLAAFFH8MAAIWAAIIhwsNVgCLAAAWAAIIhwsNVgCLAAAsAAQKfxwAAhYABgjTHd9wALgBABYABgjTHd9wALgBAAAA.',['欧皇']='欧皇无敌:BAAALAAECgcIEAAAAA==.',['欧米']='欧米茄丶暗翼:BAAALAAECgYIBgABLAAFFAMIBQAHAPQJAA==.欧米茄骑士:BAABLAAECn8gAAIQAAgIJCDWIwC2AgAQAAgIJCDWIwC2AgABLAAFFAMIBQAHAPQJAA==.',['歐皇']='歐皇先生:BAAALAAECgYIEQAAAA==.',['正义']='正义花生:BAAALAAECggIDQAAAA==.',['殇之']='殇之魔神:BAAALAAFFAIIBAAAAA==.',['毛毛']='毛毛虫儿:BAAALAAECggICwABLAAFFAMIBQAHAPQJAA==.',['江左']='江左萌:BAABLAAFFH8ZAAITAAYI3QmZIABDAQATAAYI3QmZIABDAQAAAA==.',['池鹤']='池鹤:BAAALAAFFAIIBAAAAA==.',['沃利']='沃利贝尔:BAAALAADCggICAAAAA==.',['沐歌']='沐歌谣:BAAALAAECgQIBQAAAA==.',['沙砾']='沙砾:BAACLAAFFH8LAAMKAAMImQubSwBvAAAKAAMImQubSwBvAAAFAAIItwVcTQA5AAAsAAQKfygAAwoACAjLExVvAKUBAAoACAjLExVvAKUBAAUABwi6B0GEADYBAAAA.',['沧澜']='沧澜丶:BAAALAAECgUICgAAAA==.',['河马']='河马:BAAALAAECgIIAgAAAA==.',['沽酒']='沽酒杯空影:BAAALAAFFAIIAgAAAA==.',['法力']='法力無邊:BAAALAAECgYIDwAAAA==.',['洛神']='洛神:BAAALAAECgIIAgAAAA==.',['洛羽']='洛羽:BAAALAADCgIIAgAAAA==.',['活出']='活出骑士风范:BAAALAADCgQICAAAAA==.',['浪哩']='浪哩个狼:BAABLAAFFH8LAAMKAAIIFwyGYQBZAAAKAAIIFwyGYQBZAAAFAAEI2wHPUwApAAAAAA==.',['浮士']='浮士德:BAAALAAECgYICgAAAA==.',['海的']='海的女婿:BAABLAAFFH8IAAIBAAIIgAHvpgAqAAABAAIIgAHvpgAqAAAAAA==.',['涅槃']='涅槃芬芳:BAAALAAECgYIBgAAAA==.',['涵酱']='涵酱:BAAALAAFFAUIAwAAAA==.',['淡烟']='淡烟疏雨:BAAALAADCgYIBgAAAA==.',['清晨']='清晨:BAABLAAFFH8GAAIdAAII0AO7FwBnAAAdAAII0AO7FwBnAAAAAA==.',['潘多']='潘多拉:BAAALAADCggICAAAAA==.',['灬双']='灬双刀火鸡灬:BAABLAAFFH8GAAIRAAYIxw3eFgD5AAARAAYIxw3eFgD5AAAAAA==.',['灵风']='灵风震岳手:BAAALAAECgEIAQAAAA==.',['熊猫']='熊猫不会打本:BAAALAAECgMIAwAAAA==.熊猫爱吃糖:BAAALAAECgYIBgAAAA==.',['熙熙']='熙熙:BAAALAAECggIEwAAAA==.',['牛屠']='牛屠天下:BAABLAAECn8fAAIQAAgIKQhoUAAkAQAQAAgIKQhoUAAkAQAAAA==.',['牛猫']='牛猫:BAAALAAFFAIIAgAAAA==.',['狗儿']='狗儿蛋:BAAALAAECgQIBQAAAA==.',['狠妞']='狠妞儿:BAACLAAFFH8YAAQGAAUI7AwDGwD9AAAGAAUI7AwDGwD9AAAHAAMIEAunOQCGAAAbAAMIxAdRCgBKAAAsAAQKfxwABAYACAjxDFY2AOYAAAYABgiMDFY2AOYAABsABgh7DakXAM8AAAcABgiwEEVWAL0AAAEsAAUUCAg+AB4AwCUA.',['猜咚']='猜咚哩猜:BAABLAAFFH8IAAIBAAYIhgE/YQCLAAABAAYIhgE/YQCLAAAAAA==.',['猫在']='猫在飞:BAACLAAFFH8KAAIPAAIISgwIRgCQAAAPAAIISgwIRgCQAAAsAAQKfygAAw8ACAgJFUBPAAQCAA8ACAgJFUBPAAQCABIAAwgiA12PAEoAAAAA.',['猫想']='猫想飞:BAAALAAECgcIDAAAAA==.',['獠牙']='獠牙:BAAALAAECgUIBQAAAA==.',['玖五']='玖五贰三:BAAALAAECgYIBgAAAA==.',['玛丽']='玛丽亚丶梦露:BAAALAAECgYIDQAAAA==.',['玛利']='玛利亚丶泰勒:BAAALAAECgMIAwAAAA==.',['玛莉']='玛莉亚丶凯利:BAAALAAECgYIBgAAAA==.',['玩活']='玩活你:BAAALAADCgQIBAAAAA==.',['珍妮']='珍妮玛诗朵:BAAALAAECgYICwAAAA==.',['瑞佳']='瑞佳思:BAAALAAECggICAAAAA==.',['甘甘']='甘甘:BAABLAAFFH8GAAIMAAYIUhffGQCIAQAMAAYIUhffGQCIAQABLAAFFAgIDAAJAKUUAA==.',['疯牛']='疯牛乱舞:BAAALAAECgYIBgAAAA==.',['痧锅']='痧锅大的拳头:BAAALAAECgQIBAAAAA==.',['白衣']='白衣苍狗:BAAALAADCgEIAQAAAA==.',['百亿']='百亿老毕登:BAAALAAECgYIBgAAAA==.',['皮影']='皮影大师:BAACLAAFFH8FAAIPAAIIZgWhagA2AAAPAAIIZgWhagA2AAAsAAQKfxYAAg8ACAjSClFBAEMBAA8ACAjSClFBAEMBAAAA.',['皮燕']='皮燕孑痒痒德:BAAALAADCgcIBwAAAA==.',['瞄准']='瞄准射鸡:BAAALAAFFAIIAgAAAA==.',['破道']='破道灬死神:BAAALAAECgYIBgAAAA==.',['神之']='神之拳拳:BAABLAAFFH8MAAMJAAIIRhayIwCFAAAJAAIIRhayIwCFAAAMAAIIABLQbABAAAAAAA==.',['神赐']='神赐:BAAALAAECgYIBgAAAA==.',['秀逗']='秀逗吴:BAAALAAFFAIIAgAAAA==.',['秋叶']='秋叶澜:BAAALAAECgEIAQAAAA==.',['秋天']='秋天澄:BAABLAAECn8gAAMKAAgIERt1TgD2AQAKAAcIkRp1TgD2AQAFAAgIxRSFHwCzAQAAAA==.',['秋小']='秋小澄:BAAALAAECgYICQAAAA==.秋小猎:BAABLAAFFH8IAAIIAAgIghhUDQAfAgAIAAgIghhUDQAfAgAAAA==.',['稀有']='稀有品种:BAAALAAFFAIIAgAAAA==.',['穿云']='穿云箭:BAAALAADCggICwAAAA==.',['等待']='等待时刻:BAABLAAFFH8NAAIQAAMIOA6lOQCMAAAQAAMIOA6lOQCMAAAAAA==.',['筱希']='筱希丶:BAAALAAECgYIBgAAAA==.',['筱臭']='筱臭臭:BAACLAAFFH8FAAIHAAMI9AnGIAChAAAHAAMI9AnGIAChAAAsAAQKfxoAAgcACAj7ERRXAI8BAAcACAj7ERRXAI8BAAAA.',['箭男']='箭男春:BAACLAAFFH8MAAIIAAMIdwgpfQBeAAAIAAMIdwgpfQBeAAAsAAQKfxUAAxUABgifES1vAA4BABUABgg4DC1vAA4BAAgABAi0E5zOANkAAAAA.',['粉黛']='粉黛峨嵋:BAAALAADCgYIBgAAAA==.',['精灵']='精灵坏坏:BAAALAAECgYICAAAAA==.精灵小牧:BAAALAAECgYICAAAAA==.',['糖爹']='糖爹:BAAALAAFFAIIAgAAAA==.',['紗锅']='紗锅大的拳头:BAAALAADCgMIAwAAAA==.',['索利']='索利达尔之怒:BAAALAADCgQIBAAAAA==.',['絀蕒']='絀蕒靈魂:BAAALAAFFAMIAwAAAA==.',['纯小']='纯小白丶:BAAALAAECgUIBQAAAA==.',['纯纯']='纯纯粹粹:BAAALAAECgEIAQAAAA==.',['绿肥']='绿肥红瘦丶:BAABLAAFFH8eAAMcAAYIaxUXCQCJAQAcAAYIaxUXCQCJAQABAAIIMgjChQCDAAAAAA==.',['绿茵']='绿茵冉冉:BAAALAADCgQIBAAAAA==.',['罪恶']='罪恶的人:BAAALAAECgUIBQAAAA==.',['羽柔']='羽柔子:BAAALAAECgYIBgAAAA==.',['老妞']='老妞:BAAALAAFFAIIAwAAAA==.',['老扭']='老扭:BAAALAAECgIIAgAAAA==.',['老陈']='老陈一先生:BAAALAADCgEIAQAAAA==.',['耐耐']='耐耐克拖板鞋:BAAALAAECgQIBAAAAA==.',['聆听']='聆听风吟雨落:BAAALAAECgMIAwAAAA==.',['聖光']='聖光降臨:BAAALAADCggICAAAAA==.',['聚宝']='聚宝盆:BAAALAAECgYIBgAAAA==.',['艾庭']='艾庭:BAAALAAECgEIAQAAAA==.',['芬芳']='芬芳不死:BAAALAADCgIIAgAAAA==.芬芳再起:BAAALAADCgEIAQAAAA==.芬芳善射:BAAALAADCgcIDgAAAA==.芬芳年华:BAAALAADCgEIAQAAAA==.芬芳蛋蛋:BAAALAADCgIIAgAAAA==.',['芭比']='芭比扣啦:BAAALAAECgYICQAAAA==.',['花心']='花心菜:BAAALAAECgUIBQAAAA==.',['花牛']='花牛:BAABLAAFFH8GAAIFAAYIoASlJwAIAQAFAAYIoASlJwAIAQAAAA==.',['花镜']='花镜丶恶:BAAALAAECgQIBAAAAA==.花镜丶猎:BAAALAAECgMIAwAAAA==.花镜丶锋:BAAALAAECgUIAgAAAA==.',['苏菲']='苏菲无二:BAAALAAECgYIBgAAAA==.',['荣耀']='荣耀之剑丶:BAABLAAFFH8UAAIBAAUIDhh/QAA5AQABAAUIDhh/QAA5AQAAAA==.',['莉娅']='莉娅德琳:BAAALAAECggIEAAAAA==.',['莎丶']='莎丶点:BAABLAAECn8YAAMIAAgI3xupMgD0AQAIAAgIPRupMgD0AQAVAAgIyxO1NgDiAQAAAA==.',['莣誋']='莣誋蓯葥:BAABLAAECn8WAAIMAAYIcQv9ggD6AAAMAAYIcQv9ggD6AAAAAA==.',['萌萌']='萌萌劣:BAAALAAECgQIBAAAAA==.',['萝卜']='萝卜炖排骨:BAAALAAFFAIIAgAAAA==.',['萨满']='萨满不如牛:BAAALAAECgMIBAAAAA==.',['蒸馒']='蒸馒头:BAABLAAFFH8IAAIIAAYIvAuTQgA+AQAIAAYIvAuTQgA+AQAAAA==.',['蓝彩']='蓝彩蝶:BAAALAAECgYIBgAAAA==.',['薩拉']='薩拉祈尔:BAAALAAECgYIBgAAAA==.',['虚伪']='虚伪:BAAALAAECgYIBgAAAA==.',['虚幻']='虚幻梦境:BAAALAADCgEIAQAAAA==.',['虫虫']='虫虫不知:BAAALAAECgYIBgAAAA==.',['蛇喰']='蛇喰梦子:BAACLAAFFH8OAAIDAAQIjQzINQDTAAADAAQIjQzINQDTAAAsAAQKfzMAAgMABwivGNIqAK8BAAMABwivGNIqAK8BAAEsAAUUBQgPAA4A2gkA.',['蛋小']='蛋小卷:BAAALAAFFAEIAQAAAA==.',['蛋黄']='蛋黄大圣:BAAALAAECgYIBwAAAA==.',['蠕动']='蠕动的饥饿:BAAALAAECgYIBgAAAA==.',['血兽']='血兽尊者:BAAALAAFFAIIAgAAAA==.',['血弑']='血弑魂:BAAALAAECggIDgAAAA==.',['血海']='血海芬芳:BAAALAAECgMIAwAAAA==.',['血艺']='血艺味精:BAAALAAFFAIIAgAAAA==.',['行走']='行走的荷尔蒙:BAAALAADCgYIBgAAAA==.',['裃佈']='裃佈冥愿灬:BAAALAAECgcICAAAAA==.',['西门']='西门扛把子:BAABLAAFFH8KAAMQAAII1g9eSQBJAAAQAAII1g9eSQBJAAARAAIItAdCNAAuAAAAAA==.',['西风']='西风岚:BAABLAAECn8XAAIfAAYIYhGmRABeAQAfAAYIYhGmRABeAQAAAA==.',['言宁']='言宁宝宝:BAAALAAECggIDgAAAA==.',['诡秘']='诡秘羊:BAAALAAECgYIBgAAAA==.',['请叫']='请叫我达文西:BAABLAAFFH8YAAIMAAUI7SMDFQCkAQAMAAUI7SMDFQCkAQABLAAFFAYIGgABAFEhAA==.',['豆渣']='豆渣:BAAALAAECgYIDAAAAA==.',['賊神']='賊神:BAAALAAECgEIAQAAAA==.',['财迷']='财迷猫:BAAALAADCgIIAgAAAA==.',['贼强']='贼强:BAAALAADCggICAAAAA==.',['趁月']='趁月色小酌:BAAALAAFFAIIAgAAAA==.',['转身']='转身时的落寞:BAAALAAECgMIAwAAAA==.',['达州']='达州吴彦祖:BAAALAADCgcIBwAAAA==.',['近战']='近战劣人:BAAALAAECgEIAQAAAA==.',['还你']='还你漂漂拳:BAAALAAECgQIBAAAAA==.',['这是']='这是一个小号:BAAALAAFFAIIBAAAAA==.',['进击']='进击的兽战:BAAALAAECgYICQAAAA==.',['迪丽']='迪丽干巴:BAAALAAECgYIEwAAAA==.',['选择']='选择大于努力:BAABLAAFFH8rAAMBAAYI3CDCHgC6AQABAAYI3CDCHgC6AQAgAAEI6RRxHABSAAAAAA==.',['那年']='那年那时丶:BAAALAAECgUIBQAAAA==.',['酱油']='酱油蘸酱:BAAALAAECgYICwAAAA==.',['重案']='重案组之虎丨:BAAALAAECgQIBAAAAA==.',['野原']='野原广智:BAAALAAECgYICAAAAA==.',['野生']='野生菌炖土鸡:BAABLAAFFH8GAAIYAAYI7QuJDgBTAQAYAAYI7QuJDgBTAQAAAA==.',['鑫心']='鑫心鑫:BAACLAAFFH8GAAIfAAIIURKUFgBCAAAfAAIIURKUFgBCAAAsAAQKfxQAAh8ACAjWH+0aAEMCAB8ACAjWH+0aAEMCAAAA.',['钢蛋']='钢蛋:BAAALAAECgYICwAAAA==.',['铁蛋']='铁蛋:BAAALAAECgIIAgAAAA==.',['铃鹿']='铃鹿御前:BAAALAAECgYICgAAAA==.',['铅球']='铅球:BAABLAAFFH8GAAIKAAIItQnTXABiAAAKAAIItQnTXABiAAAAAA==.',['银得']='银得一首好湿:BAAALAAECgYIEAAAAA==.',['银月']='银月骑士:BAAALAAECgIIAgAAAA==.',['银翼']='银翼的魔術師:BAAALAAECgEIAQAAAA==.',['锁镰']='锁镰:BAAALAAECgYIEgAAAA==.',['防不']='防不胜防:BAAALAAECgIIBAAAAA==.',['阿二']='阿二:BAAALAAECgYIDwAAAA==.',['阿克']='阿克萌德:BAAALAAECgcICwAAAA==.',['阿吾']='阿吾:BAAALAAECgYIDgAAAA==.',['阿布']='阿布哒:BAAALAAECgIIAgAAAA==.',['雪凌']='雪凌晨:BAAALAAECgcIDgAAAA==.',['雪舞']='雪舞劍飛:BAAALAADCggICAAAAA==.',['雷克']='雷克萨斯:BAAALAAECgYICAAAAA==.',['雾里']='雾里看花:BAAALAAECgEIAQAAAA==.',['霸气']='霸气的牛:BAAALAAECgYIBgAAAA==.',['霹雳']='霹雳火:BAABLAAFFH8LAAIBAAYIJwVASQARAQABAAYIJwVASQARAQAAAA==.',['顶不']='顶不住打击:BAAALAAFFAIIBAAAAA==.',['颜歌']='颜歌冰冰:BAACLAAFFH8GAAIKAAIISwmSagBQAAAKAAIISwmSagBQAAAsAAQKfxUAAgoABwivGY01AIYBAAoABwivGY01AIYBAAAA.',['风伊']='风伊人:BAAALAAECgYIBgAAAA==.',['风暴']='风暴阿尔法:BAAALAAECgMIAwAAAA==.',['风清']='风清飏:BAAALAAFFAEIAQAAAA==.',['风行']='风行天下:BAAALAAECgQIBgAAAA==.',['风轻']='风轻云淡:BAAALAAECgYICgAAAA==.',['风雨']='风雨丶:BAABLAAFFH8GAAIBAAII9xu4RQCrAAABAAII9xu4RQCrAAABLAAFFAgIAQAEAAAAAA==.风雨喃呢:BAAALAAECgUIBQAAAA==.',['风雪']='风雪不沾衣:BAAALAADCgYIBgAAAA==.',['飕飕']='飕飕的:BAAALAADCgYIBgAAAA==.',['飞曈']='飞曈:BAAALAAFFAIIAgAAAA==.',['香烟']='香烟烫手:BAABLAAFFH8IAAIIAAUILxq3WQDiAAAIAAUILxq3WQDiAAAAAA==.',['香蕉']='香蕉炒蛋:BAABLAAFFH8HAAIDAAIIOQsVYAA/AAADAAIIOQsVYAA/AAAAAA==.',['马儿']='马儿跑得快:BAAALAADCgQIBAAAAA==.',['骄傲']='骄傲又温柔:BAACLAAFFH8KAAMgAAIIcQmVGQBbAAAgAAIIKwSVGQBbAAABAAIImQiwjQA/AAAsAAQKfyMAAwEACAjqF6YqAMsBACAABwhFFCUaAOsBAAEACAh+E6YqAMsBAAAA.',['高西']='高西霸:BAAALAADCgYIBgAAAA==.',['鬥戦']='鬥戦勝佛:BAAALAAECgYIDwAAAA==.',['鬼辰']='鬼辰:BAAALAAECgYIBwAAAA==.',['魔亡']='魔亡:BAAALAAECgUIBQAAAA==.',['鳪囬']='鳪囬亜:BAAALAAECgYIBgAAAA==.',['鹤沙']='鹤沙航一霸:BAAALAADCgEIAQAAAA==.鹤沙航之光:BAAALAADCgQIBAAAAA==.鹤沙航之神:BAAALAADCgQICAAAAA==.',['黑巫']='黑巫王:BAAALAAECgQIBAAAAA==.',['黑思']='黑思忒:BAAALAAECgYIDAAAAA==.',['黑瑟']='黑瑟斯:BAAALAAECgEIAQAAAA==.',['龍小']='龍小猎:BAAALAAECgYIDgAAAA==.',['龍腾']='龍腾舞霓裳:BAAALAADCgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end