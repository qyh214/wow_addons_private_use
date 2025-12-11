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
 local lookup = {'Paladin-Retribution','DeathKnight-Frost','DeathKnight-Blood','Warlock-Demonology','Warlock-Destruction','Shaman-Restoration','Priest-Shadow','Mage-Arcane','Druid-Balance','Warrior-Fury','Druid-Restoration','Paladin-Protection','Warrior-Protection','Shaman-Elemental','Unknown-Unknown','Paladin-Holy','Priest-Holy','DemonHunter-Havoc','DemonHunter-Vengeance','Hunter-BeastMastery','Mage-Frost','Hunter-Marksmanship','Priest-Discipline','Evoker-Preservation',}; local provider = {region='CN',realm='古加尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={At='Atomic:BAAALAAECgQIBAAAAA==.',Au='August:BAABLAAFFH8LAAIBAAUI6BQ2KwAoAQABAAUI6BQ2KwAoAQAAAA==.',Bi='Biabiabia:BAAALAAFFAEIAQAAAA==.',Ca='Candice:BAAALAAECgYIBgAAAA==.',Do='Donmdunk:BAAALAAECgYIEgAAAA==.',Du='Dugg:BAABLAAFFH8LAAICAAUI4AotTAD9AAACAAUI4AotTAD9AAABLAAFFAgIGwADAPIcAA==.',Ei='Eiwa:BAABLAAECn8bAAMEAAYIzg8TQwBiAQAEAAYI+A4TQwBiAQAFAAYIxQrfWgDvAAAAAA==.',Em='Emmel:BAAALAAECgMIAwAAAA==.',Fi='Filipo:BAABLAAFFH8GAAIGAAQI5xJXIwDCAAAGAAQI5xJXIwDCAAAAAA==.Filipoo:BAAALAAECgYIEQAAAA==.Filippo:BAAALAAECgUICQAAAA==.',Gi='Gilgil:BAAALAAECggICAAAAA==.',Gr='Greennegro:BAAALAAFFAIIAgAAAA==.',Ha='Hardys:BAAALAAECgYICAAAAA==.',Lu='Luan:BAAALAADCgEIAQAAAA==.',Lv='Lvy:BAAALAAECgEIAQAAAA==.',Mm='Mms:BAACLAAFFH8pAAIHAAcIeBRYCQC+AQAHAAcIeBRYCQC+AQAsAAQKfzEAAgcACAhQIgwNAAwDAAcACAhQIgwNAAwDAAAA.',Ne='Nebula:BAAALAAECggICAAAAA==.Newwest:BAAALAAECgYIBwAAAA==.',Pl='Playergrnqec:BAABLAAECn8XAAMFAAcI6hVRMQCHAQAFAAcI1xVRMQCHAQAEAAII4RCSgAB5AAAAAA==.',Re='Redbin:BAAALAAFFAIIAgAAAA==.',Si='Sierra:BAAALAAFFAIIAwAAAA==.Silverdew:BAAALAAECggICAAAAA==.',Su='Sunsoldier:BAAALAADCgcIBwAAAA==.',Sw='Sweetbang:BAAALAAECgYIBgAAAA==.',Ti='Tiktok:BAAALAAECgQIBAAAAA==.',['一个']='一个小胖胖:BAAALAAFFAYIBAAAAA==.',['一百']='一百个炎爆术:BAABLAAFFH8MAAIIAAIIWBiLRwCYAAAIAAIIWBiLRwCYAAAAAA==.',['三蛆']='三蛆丶超哥:BAAALAAECgIIAgAAAA==.',['上官']='上官丶来顺:BAAALAADCgcIBwAAAA==.',['不将']='不将就:BAAALAADCgYIBgAAAA==.',['丧娇']='丧娇的小提琴:BAAALAAECgYIBgAAAA==.',['丶断']='丶断香:BAAALAAECggIEQAAAA==.',['丶虔']='丶虔橙:BAABLAAFFH8bAAIJAAYIaBEwEgBWAQAJAAYIaBEwEgBWAQAAAA==.',['丶謌']='丶謌特灬式:BAAALAAECgYIBgAAAA==.',['丿乱']='丿乱舞:BAAALAAECgYICwAAAA==.',['丿油']='丿油条丿:BAAALAADCgIIAgAAAA==.',['丿苧']='丿苧顏:BAAALAAECgIIAgAAAA==.',['乔丶']='乔丶:BAAALAAECgQIBAAAAA==.',['乔允']='乔允妍:BAAALAAECgMIAwAAAA==.',['乱砍']='乱砍乱杀:BAAALAAECgUICQAAAA==.',['云治']='云治:BAABLAAFFH8MAAICAAYI4xmDWQCeAAACAAYI4xmDWQCeAAAAAA==.',['亚历']='亚历山德罗斯:BAABLAAFFH8HAAIBAAMIeBGqGgDwAAABAAMIeBGqGgDwAAAAAA==.',['仙气']='仙气灬飘飘:BAABLAAFFH8KAAICAAIIsxM3dgBLAAACAAIIsxM3dgBLAAAAAA==.',['伊利']='伊利大雷:BAAALAAECgcIBwAAAA==.',['传移']='传移模写:BAAALAAECgMIBAAAAA==.',['保护']='保护庄周周:BAAALAAECgYICQAAAA==.',['信神']='信神棍得永生:BAAALAAECgUIBgAAAA==.',['兜里']='兜里有枪:BAAALAAFFAIIAgAAAA==.',['八百']='八百个心捻子:BAAALAAECgYICQAAAA==.',['公孙']='公孙丶淑芬:BAAALAADCgcIDAAAAA==.',['六味']='六味丶地黄丸:BAAALAAECgYIDAAAAA==.',['冥冥']='冥冥的狐林:BAAALAAECgcICwAAAA==.',['冰淇']='冰淇淋玫瑰:BAAALAADCgYIBgAAAA==.',['冰阔']='冰阔落:BAAALAAECgYIBwAAAA==.',['刘病']='刘病已:BAAALAAFFAIIAgAAAA==.',['利宾']='利宾纳梳打:BAAALAAECgUICQAAAA==.',['加厼']='加厼鲁什:BAAALAAECgEIAQAAAA==.',['加这']='加这里:BAAALAADCgEIAQAAAA==.',['勇闯']='勇闯斑马线:BAAALAAECgYIBgAAAA==.',['十八']='十八停:BAAALAAFFAIIAgAAAA==.',['十宝']='十宝茶:BAAALAAECggIDAAAAA==.',['千早']='千早爱音:BAABLAAFFH8HAAIIAAIItBNTVABHAAAIAAIItBNTVABHAAAAAA==.',['卡恩']='卡恩丶:BAAALAAECgUIBQAAAA==.',['卢克']='卢克丶:BAAALAADCgUIBQAAAA==.',['又硬']='又硬了:BAACLAAFFH8KAAIKAAQIYh05HADoAAAKAAQIYh05HADoAAAsAAQKfxoAAgoACAjvISIRAB8DAAoACAjvISIRAB8DAAAA.',['又脆']='又脆嘴还硬:BAAALAAECgYIBwAAAA==.',['双拳']='双拳爆头:BAAALAAECggIEAAAAA==.',['叫我']='叫我驰神:BAAALAAECgcIBwAAAA==.',['右边']='右边忧伤:BAABLAAFFH8HAAILAAYI8QPRLgCvAAALAAYI8QPRLgCvAAAAAA==.',['司徒']='司徒丶翠花:BAAALAAECgYICgAAAA==.',['吉尔']='吉尔伽美时:BAACLAAFFH8HAAIBAAIIbBtgMgCpAAABAAIIbBtgMgCpAAAsAAQKfxQAAgEACAidHS8yAKkCAAEACAidHS8yAKkCAAAA.',['君子']='君子的法丝:BAAALAAECggIBQAAAA==.',['听雨']='听雨落:BAABLAAFFH8HAAIBAAYIMhk3BQAVAgABAAYIMhk3BQAVAgABLAAFFAYICgAKAGIdAA==.',['吳雯']='吳雯妞妞:BAAALAAECgUIBQAAAA==.',['命运']='命运:BAAALAADCggICAAAAA==.',['咕咕']='咕咕不知道:BAAALAAFFAIIAgAAAA==.',['咖啡']='咖啡不加奶:BAAALAAECgYIBgAAAA==.',['咬人']='咬人的猎狗:BAAALAAFFAQIBAAAAA==.',['哈达']='哈达思根:BAAALAAECgMIAwAAAA==.',['哦一']='哦一西:BAAALAAECgMIAwAAAA==.',['唤魔']='唤魔师丶:BAAALAAECgMIAwAAAA==.',['唰咻']='唰咻嗖啊:BAAALAAECgUICAAAAA==.',['喵喵']='喵喵王:BAAALAAECggICQAAAA==.',['嘚儿']='嘚儿呐荡:BAAALAAECgEIAQAAAA==.',['因崔']='因崔斯汀:BAABLAAFFH8IAAIKAAIIThdYNwCXAAAKAAIIThdYNwCXAAAAAA==.',['国民']='国民小三:BAAALAAECgUICwAAAA==.',['圣光']='圣光之子:BAAALAADCgYIBgAAAA==.圣光蟹丶:BAABLAAFFH8HAAIMAAMI7hMzEAB7AAAMAAMI7hMzEAB7AAAAAA==.',['圣血']='圣血魔骑:BAAALAAECgYIBgAAAA==.',['地狱']='地狱不咆哮:BAABLAAFFH8MAAINAAMI/BknHgCMAAANAAMI/BknHgCMAAAAAA==.地狱丶火:BAAALAAECgEIAQAAAA==.',['堕落']='堕落的影子:BAAALAAFFAIIAgAAAA==.',['塞班']='塞班:BAABLAAFFH8HAAIOAAIIPxAWKgCTAAAOAAIIPxAWKgCTAAAAAA==.',['墨染']='墨染倾城殇:BAAALAAECgYIBgAAAA==.',['复仇']='复仇哀木梯:BAABLAAFFH8SAAMKAAYIVx81BABbAgAKAAYILB01BABbAgANAAYIqA7mEABDAQAAAA==.',['夏沫']='夏沫琥珀瞳:BAAALAAECgIIAgAAAA==.',['夜媚']='夜媚:BAAALAADCgQIBAAAAA==.',['夜武']='夜武:BAAALAAFFAIIAgAAAA==.',['夜雨']='夜雨:BAAALAAECgEIAQAAAA==.',['大傅']='大傅凌霜:BAAALAAECgcIDAAAAA==.',['大海']='大海的女婿:BAAALAAECgYIBgAAAA==.',['天外']='天外飞仙:BAAALAAECggIEAABLAAFFAgIEgAKAFcfAA==.',['天空']='天空没有极限:BAAALAAECggICgAAAA==.',['天雷']='天雷无妄:BAAALAADCgIIAgABLAAECggIEAAPAAAAAA==.',['头头']='头头子:BAAALAADCgQIBAAAAA==.',['奉天']='奉天逍遥:BAAALAADCgIIAgAAAA==.',['奋斗']='奋斗的卡卡:BAAALAAECgYIDAAAAA==.',['契卒']='契卒:BAAALAAFFAEIAQAAAA==.',['奥鲁']='奥鲁鲁:BAAALAAECgEIAQAAAA==.',['好大']='好大一块德芙:BAACLAAFFH8HAAILAAMI2gppOgCEAAALAAMI2gppOgCEAAAsAAQKfyAAAgsABwgiHYwwAB8CAAsABwgiHYwwAB8CAAAA.',['娅梓']='娅梓莎丶:BAAALAAECgYICAAAAA==.',['孔雀']='孔雀东南飞:BAAALAAECgYIBgABLAAFFAgIDAAQAKUUAA==.',['孤勇']='孤勇者:BAABLAAFFH8GAAICAAIIuxbbYwCWAAACAAIIuxbbYwCWAAAAAA==.',['孤叶']='孤叶:BAABLAAECn8VAAIGAAYIxxwBLAC2AQAGAAYIxxwBLAC2AQAAAA==.',['宇琳']='宇琳:BAAALAADCgcIBwAAAA==.',['守护']='守护爱:BAAALAAFFAEIAQAAAA==.',['安图']='安图恩丶:BAAALAAECgMIAwAAAA==.',['小吉']='小吉祥宝:BAABLAAFFH8OAAICAAcIVx7cCQBdAgACAAcIVx7cCQBdAgAAAA==.',['小狗']='小狗波吉:BAAALAAFFAIIAgAAAA==.',['小瓷']='小瓷气:BAABLAAFFH8HAAIRAAIIpBXvMwCJAAARAAIIpBXvMwCJAAAAAA==.',['小破']='小破孩丶:BAAALAAFFAIIAwAAAA==.',['小纯']='小纯洁:BAAALAAECgcIDwAAAA==.',['左边']='左边忧伤:BAABLAAFFH8ZAAMQAAUIKBm9EAB7AQAQAAUIKBm9EAB7AQABAAMIwSGyLQCuAAAAAA==.',['巴卡']='巴卡尔丶:BAAALAAECgMIAwAAAA==.',['希洛']='希洛克丶:BAAALAAECggIEAAAAA==.',['带墨']='带墨痕特:BAAALAAECgYIBgAAAA==.',['彡飝']='彡飝萌牛:BAAALAAFFAIIBAAAAA==.',['彦祖']='彦祖呀:BAABLAAFFH8KAAICAAUIVgmINQDIAAACAAUIVgmINQDIAAAAAA==.',['後山']='後山小悠悠:BAAALAAFFAIIAwAAAA==.',['忧郁']='忧郁小妹丶:BAABLAAECn8UAAINAAgIIw8JPACVAQANAAgIIw8JPACVAQAAAA==.',['悲伤']='悲伤华尔兹:BAAALAAECgYIBgAAAA==.',['惊蛰']='惊蛰:BAABLAAFFH8HAAIOAAUIphR4IwAoAQAOAAUIphR4IwAoAQAAAA==.',['慕容']='慕容丶二丫:BAAALAAECgQIBAAAAA==.慕容丶狗蛋:BAAALAAECgYIBwAAAA==.',['我一']='我一箭你就笑:BAAALAADCgMIBAAAAA==.',['我不']='我不管我最萌:BAAALAADCgcIDgAAAA==.',['才活']='才活不久:BAABLAAFFH8sAAIBAAYIYCXLBwANAgABAAYIYCXLBwANAgAAAA==.',['拒绝']='拒绝者:BAAALAAFFAIIAwAAAA==.',['文理']='文理双修:BAAALAAECgQIBAAAAA==.',['斩魔']='斩魔:BAABLAAECn8VAAIKAAgIvRq+LACIAgAKAAgIvRq+LACIAgAAAA==.',['断手']='断手牛肉人:BAAALAADCgQIBAAAAA==.',['无业']='无业凶灵:BAAALAAECggICAAAAA==.',['无敌']='无敌小浣熊:BAAALAAECgYICgAAAA==.无敌小魔女:BAAALAAECgYICgAAAA==.',['无羽']='无羽:BAAALAADCgQIBAAAAA==.',['星丶']='星丶期丶八:BAAALAAECgIIAgAAAA==.',['是彦']='是彦祖啊:BAAALAAFFAIIAgAAAA==.',['晚风']='晚风忆青山:BAAALAAECgYIEgAAAA==.',['智商']='智商碾压:BAAALAAECgMIAwAAAA==.',['有德']='有德乃大:BAAALAAECgIIBAAAAA==.',['朴实']='朴实吳华:BAAALAAECgYIDAAAAA==.',['来一']='来一发儿:BAAALAAECgYIBgAAAA==.',['林夕']='林夕洛雪:BAAALAAECgIIAgAAAA==.',['果子']='果子狸狸:BAAALAAECgYICQAAAA==.',['枪之']='枪之勇者:BAAALAAECgcICgAAAA==.',['柒度']='柒度丨落笔:BAABLAAFFH8JAAMSAAMImhE0IQDjAAASAAMI9RA0IQDjAAATAAIIERHKFgAoAAAAAA==.',['柠檬']='柠檬红茶:BAAALAADCgIIAgAAAA==.',['校花']='校花贴身保镖:BAAALAADCgUIBQAAAA==.',['根号']='根号伍:BAABLAAFFH8TAAIUAAYImh1BJgCZAQAUAAYImh1BJgCZAQAAAA==.',['格罗']='格罗马什:BAAALAAECgYIDAAAAA==.',['梦魇']='梦魇咕咕:BAABLAAFFH8QAAMLAAYIbR+8DADsAQALAAYIbR+8DADsAQAJAAUIDBuBGAAVAQAAAA==.梦魇萨满:BAABLAAFFH8JAAIGAAYIbh9rCwAYAgAGAAYIbh9rCwAYAgABLAAFFAgIBgARAKwPAA==.',['梧桐']='梧桐灬雨:BAAALAAECgUIBQAAAA==.',['樱花']='樱花丶宝儿:BAABLAAECn8UAAMBAAgICB42RQBsAgABAAgICB42RQBsAgAMAAQIUgBdTAACAAAAAA==.',['欧米']='欧米奥:BAAALAADCggICAAAAA==.',['残酷']='残酷丶天使:BAAALAADCgQIBAAAAA==.',['汉格']='汉格玛:BAAALAAFFAEIAQAAAA==.',['沉丶']='沉丶鱼:BAAALAAECgYIBgAAAA==.',['沟壑']='沟壑神牛:BAABLAAFFH8GAAILAAYI8QI3KADVAAALAAYI8QI3KADVAAAAAA==.',['沟股']='沟股啶里:BAABLAAFFH8PAAISAAYIcCI9DgDxAQASAAYIcCI9DgDxAQAAAA==.',['没名']='没名字的名字:BAAALAAECgQIBAAAAA==.',['沫咿']='沫咿丶嗷喵:BAAALAAECgEIAQAAAA==.',['法灵']='法灵怪怪:BAAALAAECgIIAgAAAA==.',['泡泡']='泡泡棠:BAAALAAECgYIBwAAAA==.',['泪迹']='泪迹:BAAALAAECgMIAwAAAA==.',['洛水']='洛水之心:BAAALAAECgQIBAAAAA==.',['浪浪']='浪浪山小猪仙:BAAALAADCgcIBwAAAA==.',['淘气']='淘气泡泡:BAABLAAFFH8GAAIRAAIIBxEDPgBuAAARAAIIBxEDPgBuAAAAAA==.',['清风']='清风乱烟雨:BAAALAAECgYICwAAAA==.',['渡心']='渡心:BAAALAAECgYIBwAAAA==.',['满月']='满月见红:BAAALAADCgUIBQAAAA==.',['灬缘']='灬缘灬:BAAALAADCgEIAQAAAA==.',['灬黯']='灬黯殇灬:BAAALAAECgMIAwAAAA==.',['灰来']='灰来灰气:BAAALAAFFAMIAwAAAA==.',['灰色']='灰色的天空:BAAALAAECgUIBwAAAA==.',['烦躁']='烦躁的老蜗牛:BAAALAAECgIIAgAAAA==.',['烨皇']='烨皇:BAAALAADCgYIBgAAAA==.',['烨耶']='烨耶:BAAALAAECgUIBQAAAA==.',['煜鸦']='煜鸦:BAAALAAECgYIBgAAAA==.',['熊不']='熊不乖:BAABLAAFFH8MAAICAAcIcBeMGQBlAQACAAcIcBeMGQBlAQAAAA==.',['燃烧']='燃烧丶:BAABLAAECn8WAAIGAAcI6RzmIQDuAQAGAAcI6RzmIQDuAQAAAA==.',['爆护']='爆护小欧皇:BAAALAAFFAIIAgAAAA==.',['爱上']='爱上你的床:BAAALAAECggICAAAAA==.',['牛奶']='牛奶:BAAALAAECgYICgAAAA==.',['牛小']='牛小西:BAAALAAECgYIBgAAAA==.',['牛痞']='牛痞哄哄:BAAALAADCgYIBgAAAA==.',['牛肉']='牛肉:BAAALAAECgEIAQAAAA==.',['犄角']='犄角怪:BAACLAAFFH8VAAIFAAUIJwxmPwD7AAAFAAUIJwxmPwD7AAAsAAQKfyAAAgUACAgdGqoaAAsCAAUACAgdGqoaAAsCAAAA.',['狂狼']='狂狼小圣骑:BAAALAAECgUIBQAAAA==.',['狄瑞']='狄瑞吉丶:BAAALAAECgMIAwAAAA==.',['猎灵']='猎灵之冤:BAACLAAFFH8KAAIUAAII9xrHhABMAAAUAAII9xrHhABMAAAsAAQKfykAAhQABgiZIQU7ANoBABQABgiZIQU7ANoBAAAA.猎灵龙冤:BAAALAADCgYIBgAAAA==.',['猎穎']='猎穎:BAAALAAECgYIDgAAAA==.',['猎龙']='猎龙者:BAAALAAECgIIBAAAAA==.',['王犇']='王犇犇:BAAALAAFFAIIAgAAAA==.',['王者']='王者归来:BAAALAAECgYICAAAAA==.',['瓦纳']='瓦纳斯:BAAALAAECgcIEwAAAA==.',['白发']='白发七千:BAAALAADCgIIAgAAAA==.',['白虹']='白虹贯日:BAAALAAFFAMIAwAAAA==.',['百厮']='百厮不嘚骑姐:BAABLAAFFH8LAAILAAIIbiCLGgC4AAALAAIIbiCLGgC4AAAAAA==.',['真王']='真王扒拳:BAAALAAECgIIAgAAAA==.',['真红']='真红奈奈娜:BAAALAAFFAIIAwAAAA==.真红希尔娜:BAAALAAECgEIAQAAAA==.真红康娜娜:BAAALAAECgYIBgAAAA==.',['破旧']='破旧易拉罐:BAAALAAECgYIBgAAAA==.',['祎块']='祎块饼:BAAALAAECgYIEAAAAA==.',['神射']='神射手啊:BAAALAAFFAIIBAAAAA==.',['神秘']='神秘天月:BAAALAADCgQIBAAAAA==.',['祭礼']='祭礼之蛇悠二:BAAALAAECgYIBgAAAA==.',['秋秋']='秋秋吖:BAABLAAFFH8KAAIHAAQIbAw+EAASAQAHAAQIbAw+EAASAQAAAA==.',['粗糙']='粗糙男人:BAAALAAECgEIAQAAAA==.',['糖果']='糖果罐丶:BAAALAAECgcICAAAAA==.',['糖门']='糖门道姑:BAABLAAFFH8FAAMEAAIIAg/xEgBGAAAEAAIIAg/xEgBGAAAFAAEI3wkOdwAAAAAAAA==.',['绝版']='绝版的爱:BAACLAAFFH8GAAIGAAIIqhkASwCHAAAGAAIIqhkASwCHAAAsAAQKfxUAAgYABwiOGCpcANIBAAYABwiOGCpcANIBAAAA.',['缚灵']='缚灵圣物:BAABLAAFFH8GAAIIAAYIMBe9JwB1AQAIAAYIMBe9JwB1AQAAAA==.',['缪米']='缪米拉索尔:BAAALAAECgQIBAAAAA==.',['缺德']='缺德的找我:BAAALAAFFAIIAgAAAA==.',['罗蔓']='罗蔓洛夫:BAAALAAFFAYIAgAAAA==.',['老衲']='老衲只用力士:BAAALAAECgYIBgAAAA==.',['老迷']='老迷糊萨叔:BAAALAADCgIIAgAAAA==.',['肥宅']='肥宅快乐水:BAAALAAECgcIBwAAAA==.',['能能']='能能横扫天下:BAAALAAECgYICQAAAA==.',['至上']='至上刺猬兽兽:BAAALAADCgEIAQAAAA==.',['若瑄']='若瑄:BAABLAAECn8XAAINAAgIzA69HgBMAQANAAgIzA69HgBMAQAAAA==.',['萨迩']='萨迩玛:BAAALAADCgYIBgAAAA==.',['蒂华']='蒂华之秀:BAABLAAFFH8IAAIUAAYImg7yTAAZAQAUAAYImg7yTAAZAQAAAA==.',['蓝莓']='蓝莓丶面包:BAAALAAECgQIBAAAAA==.',['虾仁']='虾仁猪心:BAAALAAECgIIAgAAAA==.',['蚂蝗']='蚂蝗:BAAALAADCgIIAgAAAA==.',['蛋蛋']='蛋蛋猎手:BAAALAADCgUIBQAAAA==.',['螃蟹']='螃蟹丶:BAABLAAFFH8hAAIVAAYI3RseBACVAQAVAAYI3RseBACVAQAAAA==.螃蟹威武:BAABLAAFFH8JAAIUAAYI8xhlKQCOAQAUAAYI8xhlKQCOAQAAAA==.',['血吼']='血吼爆头:BAAALAAECggICAAAAA==.',['裤儿']='裤儿脱娃:BAAALAAECgMIAwAAAA==.',['西门']='西门猎艳:BAABLAAECn8nAAMUAAcIWBi8hgA9AQAUAAcIpRS8hgA9AQAWAAYIYA6NZwAmAQAAAA==.',['诗怡']='诗怡很健康:BAAALAAECgUIBQAAAA==.',['诺丶']='诺丶晟曦:BAAALAAECgIIAgAAAA==.',['谁还']='谁还不是宝宝:BAAALAAECgIIAwAAAA==.',['谢赫']='谢赫六法:BAAALAADCggICAAAAA==.',['豿看']='豿看家貓鎭宅:BAACLAAFFH8dAAMRAAUINBw9FgCgAQARAAUINBw9FgCgAQAXAAEIZgdTCQAjAAAsAAQKfxUAAxEABggkHpw7AOsBABEABggkHpw7AOsBAAcABQhUB5Z0AN0AAAAA.',['败家']='败家骑士:BAAALAAECgcIDwAAAA==.',['赫尔']='赫尔德丶:BAAALAAECgYIBgAAAA==.',['赵君']='赵君毅:BAAALAAECgYIDAAAAA==.',['超炫']='超炫电光王:BAAALAAECgQIBAAAAA==.',['跟随']='跟随带头大哥:BAAALAAECgEIAQAAAA==.',['轻灬']='轻灬飘飘:BAAALAADCgYICAAAAA==.',['这牛']='这牛咋这帅丨:BAAALAADCgQIBAAAAA==.',['追梦']='追梦者:BAAALAAECgYIBwAAAA==.',['還是']='還是會呼呼:BAAALAADCgMIAwAAAA==.還是會喵喵:BAAALAADCgIIAgAAAA==.還是會寂寞:BAAALAAECgYIDAAAAA==.還是會狸狸:BAAALAADCgEIAQAAAA==.',['邪恶']='邪恶廾血骑:BAAALAAECgYICQAAAA==.',['释怀']='释怀:BAAALAADCgIIAgAAAA==.',['铜墙']='铜墙:BAAALAAECgUIBgAAAA==.',['锤锤']='锤锤子:BAAALAADCgEIAQAAAA==.',['长恨']='长恨还无用:BAAALAADCgIIAgAAAA==.',['长的']='长的可以了:BAAALAADCgYIBgAAAA==.',['防盗']='防盗门:BAABLAAFFH8JAAIUAAMIkxk+aACVAAAUAAMIkxk+aACVAAAAAA==.',['阿布']='阿布滴避风港:BAAALAADCgEIAQAAAA==.',['限量']='限量鈑嘚嗳:BAABLAAFFH8KAAIQAAIIBQzeJwBsAAAQAAIIBQzeJwBsAAAAAA==.',['陳冠']='陳冠晞:BAAALAADCggICgAAAA==.',['雨天']='雨天不打伞:BAABLAAFFH8MAAIKAAIIXB5gIwC1AAAKAAIIXB5gIwC1AAAAAA==.',['雪王']='雪王:BAAALAAECgIIAgAAAA==.',['雲游']='雲游者:BAAALAAECgYIBgAAAA==.',['雷勋']='雷勋爵:BAAALAAECgMIAwAAAA==.',['霜晶']='霜晶剑魂:BAAALAAECgYIBgAAAA==.',['露琪']='露琪娅:BAAALAAECgYIBgAAAA==.',['静静']='静静太淘气:BAACLAAFFH8MAAIYAAIIvh5KFQCwAAAYAAIIvh5KFQCwAAAsAAQKfx0AAhgABghxIp8FAFQCABgABghxIp8FAFQCAAAA.',['须臾']='须臾之梦:BAACLAAFFH8vAAIUAAcIeh9/DwAOAgAUAAcIeh9/DwAOAgAsAAQKfzoAAhQACAiuJAcUABADABQACAiuJAcUABADAAAA.',['颈椎']='颈椎骨折:BAAALAAFFAIIAgAAAA==.',['风灬']='风灬飘渺:BAAALAAECgIIAgAAAA==.',['风萧']='风萧萧兮:BAAALAAECgMIAwAAAA==.',['风间']='风间古庙:BAAALAAECgQIBAAAAA==.',['香丶']='香丶飄飄:BAAALAAECgcICwAAAA==.',['香灬']='香灬飘飘:BAABLAAFFH8KAAIEAAII3wzzFgA9AAAEAAII3wzzFgA9AAAAAA==.',['骑士']='骑士也疯狂:BAABLAAECn8VAAIBAAYINx4RNwC5AQABAAYINx4RNwC5AQAAAA==.',['骑手']='骑手赵铁柱:BAAALAAECgYIEwAAAA==.',['骑神']='骑神传说:BAAALAAECgUICAAAAA==.',['麦田']='麦田:BAAALAADCgQIBAAAAA==.',['黄石']='黄石混混:BAAALAAECgQIBAAAAA==.黄石牛叉:BAAALAAECgQIBAAAAA==.',['黑糖']='黑糖玛琪朵:BAAALAAECgIIAgAAAA==.',['黯丨']='黯丨泠音:BAAALAAFFAIIAgAAAA==.',['龍神']='龍神细雨:BAAALAAECggICAAAAA==.',['龙纹']='龙纹身:BAAALAAFFAIIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end