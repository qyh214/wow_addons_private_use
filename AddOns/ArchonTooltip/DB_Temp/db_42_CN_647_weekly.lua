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
 local lookup = {'DeathKnight-Frost','Warlock-Affliction','Warlock-Destruction','Evoker-Devastation','Paladin-Protection','Rogue-Assassination','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Paladin-Retribution','Shaman-Restoration','Warrior-Fury','Mage-Arcane','DemonHunter-Havoc','Mage-Frost','Mage-Fire','DeathKnight-Unholy','DeathKnight-Blood','Priest-Discipline','Priest-Holy','DemonHunter-Vengeance','Unknown-Unknown','Warrior-Arms','Warrior-Protection','Druid-Restoration','Druid-Balance','Priest-Shadow','Monk-Brewmaster','Monk-Windwalker','Paladin-Holy','Warlock-Demonology','Shaman-Elemental','Shaman-Enhancement','Evoker-Preservation','Druid-Guardian','Druid-Feral',}; local provider = {region='CN',realm='守护之剑',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Always:BAABKgAFFH8LAAIBAAMI9ReiAgD6AAABAAMI9ReiAgD6AAAAAA==.',Am='Amelia:BAAAKgADCggICAAAAA==.',An='Angel:BAAAKgAECgQIBAAAAA==.Angelachang:BAAAKgADCgYIBgAAAA==.',Bo='Boykises:BAAAKgAECggIBgAAAA==.',Cc='Cc:BAACKgAFFH8QAAMCAAQIExEwCgCdAAADAAQIExEFGAC/AAACAAMIWQYwCgCdAAAqAAQKfxcAAgMACAirH9cDAI0CAAMACAirH9cDAI0CAAAA.',Di='Disappeared:BAAAKgAECgMIAwAAAA==.',Dr='Drwar:BAAAKgAECgEIAQAAAA==.',Ef='Efi:BAABKgAFFH8GAAIEAAYIQQ4LDgA8AQAEAAYIQQ4LDgA8AQAAAA==.',Eg='Egoo:BAAAKgAFFAQIBAABKgAFFAgIEgADAJomAA==.',Ei='Eileen:BAAAKgAECggICAAAAA==.',El='Ellis:BAAAKgAECgYICAAAAA==.',Fi='Figo:BAABKgAFFH8IAAIFAAgIECMwAQDOAgAFAAgIECMwAQDOAgAAAA==.',Fn='Fnmdxx:BAABKgAFFH8IAAIGAAgIzQzYBQD0AQAGAAgIzQzYBQD0AQAAAA==.',Fo='Foraiur:BAAAKgAECggICQAAAA==.',Ha='Hack:BAACKgAFFH8VAAMHAAQI2R+kIwDgAAAHAAQI2R+kIwDgAAAIAAIIbiH2KwCjAAAqAAQKfykAAwcACAhHJU8LAIUCAAcACAgLIk8LAIUCAAgABwj/IrYwADECAAAA.',Ir='Iristory:BAAAKgADCggICQAAAA==.',Jm='Jmws:BAABKgAFFH8GAAIJAAYIwAjyGgDFAAAJAAYIwAjyGgDFAAABKgAFFAgIEAAFAFAKAA==.',Ke='Kemical:BAAAKgAFFAQIBAAAAA==.',Kr='Krista:BAABKgAFFH8IAAIJAAgIJg7bBgCaAQAJAAgIJg7bBgCaAQAAAA==.',La='Lani:BAAAKgADCggICAAAAA==.',Lr='Lråforever:BAAAKgADCgUIAwAAAA==.',Mo='Moom:BAAAKgADCgQIBAAAAA==.',Mu='Muscler:BAAAKgAECggICwAAAA==.Musee:BAABKgAECn8fAAIKAAcIoxgTdACvAQAKAAcIoxgTdACvAQAAAA==.',Ni='Ninthelement:BAABKgAFFH8GAAILAAYI8g9yDQAhAQALAAYI8g9yDQAhAQAAAA==.',Pe='Peterrabbit:BAAAKgADCgIIAgAAAA==.',Pi='Pinkmerry:BAAAKgAECgIIAgAAAA==.Pinkpapa:BAABKgAFFH8GAAIMAAYIgQZuEQBAAQAMAAYIgQZuEQBAAQAAAA==.',Pl='Playerdlpqkl:BAAAKgAECggIEAAAAA==.Playerudarsx:BAAAKgAFFAgIBAAAAA==.',Qe='Qeer:BAAAKgAECggICAAAAA==.',Ra='Raziel:BAAAKgADCgUIBQAAAA==.',Re='Remiria:BAAAKgAECgYIAQAAAA==.Renascence:BAABKgAFFH8GAAINAAIIgxITOgB5AAANAAIIgxITOgB5AAAAAA==.Rere:BAAAKgADCgQIBAAAAA==.',Ro='Rockzjsq:BAAAKgAECggICAAAAA==.',Sn='Snn:BAAAKgADCgUIBQAAAA==.',Sq='Squeens:BAAAKgAFFAIIAgAAAA==.',Te='Terminusest:BAAAKgAECgYICAAAAA==.',Th='Theoldone:BAAAKgAECgQIBgAAAA==.',Ti='Timtom:BAAAKgAECgIIAwAAAA==.',Vi='Viva:BAABKgAFFH8KAAIFAAYIBhe1CwA8AQAFAAYIBhe1CwA8AQAAAA==.Vivaa:BAAAKgADCggIEAAAAA==.',Za='Zaki:BAAAKgAECgEIAQAAAA==.',['一丹']='一丹丶筱筱:BAAAKgAECgEIAQAAAA==.',['一叶']='一叶扁舟:BAAAKgADCggICAAAAA==.',['一同']='一同天下:BAABKgAFFH8IAAIOAAQIoiMSHgASAQAOAAQIoiMSHgASAQAAAA==.',['一夜']='一夜教授:BAAAKgAFFAgIBAAAAA==.',['一心']='一心不乱:BAAAKgAECgYIDQAAAA==.',['一枪']='一枪穿云:BAAAKgAECgQIBAAAAA==.',['一点']='一点冷:BAAAKgAECgMIAwAAAA==.',['一騎']='一騎紅塵:BAABKgAECn8bAAMPAAcITgb0IQCkAAAPAAYIFAf0IQCkAAAQAAEIcAJzrgAJAAAAAA==.',['七景']='七景终落:BAABKgAFFH8GAAMRAAYIMhF0MwDIAAARAAQIEBV0MwDIAAASAAIIZgvPKQBuAAAAAA==.',['三刀']='三刀:BAABKgAFFH8GAAIKAAYItx8mFgCqAQAKAAYItx8mFgCqAQAAAA==.',['三陆']='三陆一拾八:BAAAKgAFFAYIAQAAAA==.',['上帝']='上帝的回忆:BAAAKgADCgcIBwAAAA==.上帝的智慧:BAAAKgAECgEIAQAAAA==.上帝的诡媚:BAAAKgADCgQIBAAAAA==.上帝的黑魔法:BAAAKgADCggICAAAAA==.',['与主']='与主同在:BAAAKgAFFAgIBAAAAA==.',['丛林']='丛林蛮易信:BAAAKgADCgQIBAAAAA==.',['丨阿']='丨阿尔托莉雅:BAAAKgAECgUIBAAAAA==.',['丶花']='丶花生米:BAABKgAECn8eAAMTAAgI/BvMHwDKAQATAAgI/BvMHwDKAQAUAAUIlxHpZACwAAAAAA==.',['丿白']='丿白鹿秋:BAAAKgAECggICAAAAA==.',['乌蝇']='乌蝇哥:BAABKgAFFH8QAAMVAAYIXhOsCADAAAAOAAYIuhLqFwA8AQAVAAQI5BKsCADAAAAAAA==.',['乔治']='乔治的恐龙:BAAAKgADCgcIBwAAAA==.',['云淡']='云淡灬风清:BAAAKgAECgYIBgAAAA==.',['五岁']='五岁:BAAAKgAECgcICAAAAA==.',['亚历']='亚历山德拉:BAAAKgADCggICgAAAA==.',['京盒']='京盒盒:BAAAKgAECgYIBgAAAA==.',['亲嘴']='亲嘴:BAAAKgADCgMIBAAAAA==.',['从前']='从前有条狗:BAAAKgAECgIIAgAAAA==.',['以德']='以德服人丶:BAAAKgADCgQIBAAAAA==.',['伊人']='伊人多多:BAABKgAFFH8IAAIIAAgIYBUsBgAsAgAIAAgIYBUsBgAsAgAAAA==.伊人灵灵:BAABKgAECn8UAAILAAgImQ3qTwBPAQALAAgImQ3qTwBPAQAAAA==.',['伊克']='伊克西之翼:BAAAKgAECgMIAwAAAA==.',['伊莉']='伊莉达蕾:BAAAKgAECgIIAgAAAA==.',['余胖']='余胖胖:BAAAKgAECgQIBAAAAA==.',['余霞']='余霞成绮:BAAAKgAFFAgIBAAAAA==.',['俏妞']='俏妞妞:BAAAKgAFFAIIAgAAAA==.',['保护']='保护娭毑:BAABKgAFFH8GAAIMAAYI2RmICADFAQAMAAYI2RmICADFAQAAAA==.',['偷偷']='偷偷的奶一口:BAAAKgADCgEIAQAAAA==.',['克洛']='克洛伊伊莉雅:BAAAKgAFFAQIBAAAAA==.',['克罗']='克罗斯:BAAAKgAECgMIAwAAAA==.',['兜兜']='兜兜有寂寞:BAABKgAFFH8HAAIQAAYIBhZuDABvAQAQAAYIBhZuDABvAQAAAA==.',['兩个']='兩个人的孤寂:BAAAKgAECgUIBQAAAA==.',['兩個']='兩個人的孤寂:BAAAKgAECgEIAQAAAA==.',['八十']='八十八十:BAAAKgAFFAIIAgAAAA==.',['八坂']='八坂神柰子:BAAAKgAECgcIDAABKgAECggICQAWAAAAAA==.',['八月']='八月即飞雪:BAAAKgAECgQIBAAAAA==.',['关关']='关关酱:BAAAKgAFFAQIBAAAAA==.',['养猪']='养猪大户:BAAAKgAFFAUIAwAAAA==.',['冬天']='冬天怕冷:BAAAKgAECgEIAQAAAA==.',['冰墩']='冰墩墩:BAAAKgADCgIIAwAAAA==.',['冰封']='冰封小阿:BAAAKgAFFAEIAQAAAA==.',['冰月']='冰月凝霜:BAAAKgADCgIIAgAAAA==.',['冰蓝']='冰蓝色火焰:BAAAKgADCgQIBAAAAA==.',['冲锋']='冲锋吧丿小德:BAAAKgAFFAQIBAAAAA==.',['冷夜']='冷夜冰:BAAAKgAECgEIAQAAAA==.',['凉森']='凉森玲梦:BAAAKgAECgUIAQAAAA==.',['凤姐']='凤姐夫:BAAAKgADCgMIAwAAAA==.',['出来']='出来吧皮卡丘:BAAAKgAFFAMIAwAAAA==.',['刀子']='刀子:BAAAKgAECgEIAgAAAA==.',['加卡']='加卡:BAABKgAFFH8OAAQXAAQIjhTACQDSAAAMAAQIxQ7GEwDoAAAXAAQIaQrACQDSAAAYAAQIjhSbDABFAAAAAA==.',['劲哥']='劲哥哥:BAACKgAFFH8SAAIMAAMILQ8bIQDPAAAMAAMILQ8bIQDPAAAqAAQKfxUAAgwACAi8E3dFAFUBAAwACAi8E3dFAFUBAAAA.',['勺子']='勺子:BAAAKgAECgEIAQAAAA==.',['十三']='十三少之狼:BAAAKgAECggIDgAAAA==.',['十岁']='十岁:BAAAKgAECgQIBAAAAA==.',['半顆']='半顆糖:BAAAKgAECgMIAwAAAA==.',['卓仔']='卓仔:BAAAKgAECgYIBgAAAA==.',['南渡']='南渡:BAAAKgAECggICAABKgAFFAgIHgALABseAA==.',['卜坦']='卜坦克还能用:BAABKgAFFH8OAAIDAAgIuREpCwDaAQADAAgIuREpCwDaAQAAAA==.',['占戈']='占戈士:BAAAKgAECgMIAwAAAA==.',['卯之']='卯之花千流:BAAAKgAECgYIBgAAAA==.',['原地']='原地爆炸骑:BAAAKgAFFAQIBAAAAA==.',['原来']='原来是你:BAAAKgAECgQIBAAAAA==.',['口袋']='口袋里有奶糖:BAAAKgAFFAQIAgAAAA==.口袋里有弹弓:BAAAKgAECggICAAAAA==.',['可乐']='可乐我不乐:BAABKgAFFH8IAAIKAAgIogoiDQDQAQAKAAgIogoiDQDQAQAAAA==.',['可爱']='可爱野猪妹:BAAAKgAECggICAAAAA==.',['司空']='司空圣:BAAAKgAECgMIBAAAAA==.',['吃吃']='吃吃困困搞搞:BAAAKgAECgEIAQAAAA==.',['君丶']='君丶天下:BAABKgAECn8iAAMXAAgIJRzgKQBrAQAXAAcIjxrgKQBrAQAMAAUI9Bs8RwBMAQAAAA==.',['吾爱']='吾爱有三:BAAAKgAECgIIAgAAAA==.',['咕唂']='咕唂:BAAAKgAECgEIAQAAAA==.',['咸菜']='咸菜超人:BAAAKgADCggICAAAAA==.',['哇嘎']='哇嘎:BAAAKgAECgQIBQAAAA==.',['哈喽']='哈喽比比熊:BAAAKgAECgYICQAAAA==.',['哎哟']='哎哟薇:BAAAKgAECggIEAAAAA==.',['唱诗']='唱诗班头牌:BAAAKgADCggICAAAAA==.',['啷个']='啷个哩个榔:BAAAKgADCggIEwAAAA==.',['喝一']='喝一斤吐八两:BAAAKgADCgIIAgAAAA==.',['嗜血']='嗜血的耗子:BAAAKgADCgcICQAAAA==.',['嘉奖']='嘉奖小恶魔:BAAAKgAECgYICAAAAA==.',['嘎嘣']='嘎嘣啐:BAAAKgADCgQIBAAAAA==.',['嘟嘟']='嘟嘟噜:BAABKgAFFH8KAAIZAAYI6g+jCAD1AAAZAAYI6g+jCAD1AAAAAA==.',['嘿吧']='嘿吧:BAAAKgADCggICAAAAA==.',['噩梦']='噩梦降临:BAAAKgAFFAQIBAAAAA==.',['回荡']='回荡的回忆:BAACKgAFFH8fAAQPAAUIsxuWCwDRAAAQAAUIsxuuDwBJAQAPAAMIuxaWCwDRAAANAAIIRBEOOACCAAAqAAQKf0IABA8ACAhxIWQSAGsCAA8ACAh+IGQSAGsCABAACAhcGfdBAIMBAA0AAwhWIGhJABkBAAAA.',['国服']='国服第一美:BAAAKgAECgIIAgAAAA==.',['土肥']='土肥圆圆:BAABKgAFFH8KAAMaAAYIGBBkFwDgAAAaAAUIxhBkFwDgAAAZAAEIBgR2NwA+AAAAAA==.',['圣一']='圣一若梦:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光女骑:BAABKgAFFH8GAAMFAAQImxsMHACZAAAKAAIImCDaaACbAAAFAAQILw8MHACZAAAAAA==.',['圣血']='圣血天使:BAABKgAFFH8GAAIKAAYITQr1PQD3AAAKAAYITQr1PQD3AAAAAA==.',['地瓜']='地瓜侠啥都会:BAABKgAFFH8GAAIaAAYIKBHnGQBKAQAaAAYIKBHnGQBKAQAAAA==.',['坟凹']='坟凹无限装殖:BAACKgAFFH8RAAMSAAgIdgr4CAADAQASAAgIdgr4CAADAQARAAEIEgG4VwAjAAAqAAQKfxUAAhIACAioA6FQAHkAABIACAioA6FQAHkAAAAA.',['埃斯']='埃斯卡破魂:BAAAKgAECgUIBgAAAA==.',['埃辛']='埃辛一诺斯:BAAAKgAECggIAQAAAA==.',['基情']='基情罒射:BAAAKgAECgYIDAAAAA==.',['堕落']='堕落十字軍:BAAAKgADCggIDwAAAA==.',['墨白']='墨白色块:BAAAKgAFFAQIAgAAAA==.',['壹剑']='壹剑封神:BAAAKgAECgQIBAAAAA==.',['复仇']='复仇:BAAAKgAECgEIAQAAAA==.',['夏天']='夏天怕热:BAAAKgAECgYIDAAAAA==.夏天的小幂幂:BAAAKgAECggICAAAAA==.',['夏溦']='夏溦泱:BAABKgAFFH8MAAMZAAYIiB8NBQDWAQAZAAYIiB8NBQDWAQAaAAIIfxL5SQCKAAAAAA==.',['夏魂']='夏魂:BAABKgAFFH8IAAMDAAgIqA79GwAmAQADAAcIqA79GwAmAQACAAEIAAAzJAAAAAAAAA==.',['多明']='多明我会:BAABKgAECn8XAAIKAAgIGBFeeABhAQAKAAgIGBFeeABhAQAAAA==.',['夜丶']='夜丶小箫:BAACKgAFFH8NAAIUAAMImyU7DwA7AQAUAAMImyU7DwA7AQAqAAQKfyUAAxQACAgkJY0DANYCABQACAgkJY0DANYCABsAAwieHeUyAAEBAAAA.',['夜幕']='夜幕下的游魂:BAABKgAFFH8bAAQJAAYIwhKaDwAyAQAJAAYIwhKaDwAyAQAcAAYIUBNtAwAcAQAdAAQIhR9pBgAWAQAAAA==.',['夜深']='夜深人靜:BAAAKgADCgcIBwABKgAECggILgALAGARAA==.',['大钢']='大钢镚满满兜:BAAAKgAECgYIBgAAAA==.',['天之']='天之神铭:BAAAKgAECgMIBQAAAA==.',['天使']='天使德鲁依:BAAAKgADCgUIBQAAAA==.',['天昏']='天昏:BAABKgAFFH8PAAIPAAMIihx0DQD6AAAPAAMIihx0DQD6AAAAAA==.',['天罸']='天罸:BAAAKgAFFAEIAQAAAA==.',['天闲']='天闲星光:BAAAKgAECgQIBAAAAA==.',['奥黛']='奥黛莉丶赫本:BAABKgAFFH8FAAIFAAQIoAtWFADWAAAFAAQIoAtWFADWAAAAAA==.',['女乃']='女乃乄米唐:BAABKgAFFH8NAAMdAAcI/RcqBQDnAQAdAAcI/RcqBQDnAQAJAAYIkB90CACpAQAAAA==.',['奶到']='奶到天堂:BAABKgAFFH8IAAMUAAYIUxZLCwBuAQAUAAYI1BVLCwBuAQATAAII9RX2HwCjAAAAAA==.',['奶包']='奶包:BAACKgAFFH8OAAITAAQIUx5ZEgAJAQATAAQIUx5ZEgAJAQAqAAQKfzYAAxMACAjdIlAFALECABMACAjdIlAFALECABQAAwgIDN93AHgAAAAA.',['好尖']='好尖一个:BAAAKgADCgIIAgAAAA==.',['如梦']='如梦芳华:BAABKgAFFH8MAAMUAAYIVh0IBgCtAQAUAAYIVh0IBgCtAQAbAAEILAdpLQA/AAAAAA==.',['妖韵']='妖韵:BAABKgAFFH8eAAMaAAYI0R1zEgCJAQAaAAYI0R1zEgCJAQAZAAYIIgq+EQAQAQAAAA==.',['妙脆']='妙脆哆:BAAAKgAFFAQIBAAAAA==.',['妮乀']='妮乀露:BAAAKgADCggICAAAAA==.',['娇花']='娇花术:BAAAKgADCgIIAgAAAA==.',['媛峰']='媛峰:BAAAKgAECggICQAAAA==.',['孤傲']='孤傲天空:BAABKgAFFH8IAAIKAAgI+RKICQAqAgAKAAgI+RKICQAqAgAAAA==.',['安享']='安享晚年:BAAAKgAECgYIDwAAAA==.',['安格']='安格斯:BAAAKgAECgYIDgAAAA==.',['安美']='安美拉:BAAAKgAFFAIIAgAAAA==.',['宝强']='宝强别哭:BAAAKgAECgMIAwAAAA==.',['射你']='射你像塞子:BAAAKgADCgMIAwAAAA==.',['小小']='小小的凡凡:BAAAKgAECggICAAAAA==.',['小师']='小师妹真靓:BAABKgAECn8VAAMZAAgI/A0+GQD3AAAZAAgI/A0+GQD3AAAaAAUI0A8ILwDjAAAAAA==.',['小时']='小时候可黑啦:BAAAKgADCggICAAAAA==.',['小曦']='小曦哥哥:BAABKgAFFH8KAAQXAAQIAyFxBgD+AAAYAAQIyiC4BgADAQAXAAQI2BRxBgD+AAAMAAIIeglVIgCDAAABKgAFFAgIBAAWAAAAAA==.',['小李']='小李子:BAABKgAFFH8GAAIdAAQIlBWXCQDxAAAdAAQIlBWXCQDxAAAAAA==.',['小猪']='小猪猪的传说:BAAAKgAECgQIBwAAAA==.',['小猫']='小猫晃悠悠:BAABKgAECn8tAAMRAAgIviAYFACIAgARAAgIviAYFACIAgASAAgIug3qJAAhAQAAAA==.',['小白']='小白兔团团:BAAAKgADCggICAAAAA==.',['小腰']='小腰果:BAAAKgAECgYIBwAAAA==.',['小萨']='小萨去哪儿:BAAAKgAFFAYIAgAAAA==.',['小貓']='小貓咪大咕咕:BAAAKgADCggIDwAAAA==.',['小飞']='小飞棍来啰:BAAAKgAECgUIBwAAAA==.',['小马']='小马的抹茶:BAABKgAFFH8MAAIIAAYI5yERCAD5AQAIAAYI5yERCAD5AQAAAA==.',['小魔']='小魔无敌:BAAAKgAECgQIBwAAAA==.',['小鱼']='小鱼:BAAAKgAECggIDwAAAA==.',['小龙']='小龙人六号:BAAAKgAECggICQAAAA==.',['尐烧']='尐烧饼:BAAAKgAECgMIBAAAAA==.',['尕乃']='尕乃乃:BAAAKgADCgQIBAAAAA==.',['尖沙']='尖沙咀十三妹:BAABKgAFFH8QAAMRAAgIHx8PCgDsAQARAAYI8SIPCgDsAQASAAUIlhGSDgAzAQAAAA==.',['尤加']='尤加利叶:BAABKgAECn8UAAMNAAgIsxVMMgCHAQANAAgIsxVMMgCHAQAPAAIIvRTQXwB0AAAAAA==.',['屠戮']='屠戮:BAABKgAFFH8NAAQeAAgIUgv+BgBIAQAeAAYIBgz+BgBIAQAFAAIIihi1HgCGAAAKAAEIrgkDiABHAAAAAA==.',['崑崙']='崑崙:BAAAKgAECgIIAgAAAA==.',['巅峰']='巅峰的萌新:BAAAKgAFFAgIBAAAAA==.',['川川']='川川居然:BAABKgAFFH8IAAIDAAgIDwd6CgCsAQADAAgIDwd6CgCsAQAAAA==.',['巴图']='巴图尔:BAAAKgADCggICAAAAA==.',['布莱']='布莱克哈德:BAAAKgAFFAYIAgAAAA==.',['希锐']='希锐:BAABKgAFFH8HAAQfAAQIxB/zCADyAAAfAAQIxB/zCADyAAADAAIIBwO8KwBZAAACAAEISAc4HgBGAAAAAA==.',['带宝']='带宝儿逛街:BAAAKgAECggIDwAAAA==.',['帮助']='帮助伱帮助我:BAAAKgAECggIDgAAAA==.',['幸存']='幸存者:BAABKgAECn8XAAMIAAgI/BbrPQCtAQAIAAgI+xbrPQCtAQAHAAYICRbnQwBCAQAAAA==.',['广结']='广结善缘:BAACKgAFFH8VAAMgAAQI+AoJGQCxAAAgAAMI+AoJGQCxAAALAAQI1hRHIQCSAAAqAAQKfxgABAsACAgXGp9RAEoBAAsACAgXGp9RAEoBACAABAiJCzZgAJkAACEAAgjwCQ5UAGYAAAAA.',['店小']='店小二:BAAAKgAECgYIBgAAAA==.',['开心']='开心女孩:BAAAKgADCggICAAAAA==.开心男孩:BAAAKgAECgYICwAAAA==.',['开怀']='开怀大笑:BAAAKgADCgQIBAAAAA==.',['异度']='异度圣域:BAAAKgADCggICAAAAA==.',['弟荙']='弟荙洞洞荙荙:BAABKgAFFH8YAAMDAAgIpiNmBABdAgADAAgI7yFmBABdAgAfAAQIih+DAgAcAQAAAA==.',['张灬']='张灬海旺:BAABKgAECn8VAAMBAAgI9hSSEwBeAQABAAgI9hSSEwBeAQARAAEIzwlg1AAmAAAAAA==.',['强铌']='强铌哥:BAAAKgADCgUIBQAAAA==.',['当当']='当当:BAABKgAECn8qAAIIAAgI+hvdDQA4AgAIAAgI+hvdDQA4AgAAAA==.',['影兮']='影兮兮:BAAAKgAECgIIAgABKgAFFAgIEQAZAD4jAA==.',['征战']='征战之年:BAAAKgAFFAQIBAAAAA==.',['御龙']='御龙有术:BAAAKgAECgYIBwAAAA==.',['德马']='德马稀丫:BAABKgAFFH8IAAILAAgI/gtwCACNAQALAAgI/gtwCACNAQAAAA==.',['心上']='心上:BAABKgAFFH8GAAMHAAYI0xkmAgB4AQAHAAUIVh0mAgB4AQAIAAEIxws2QgBXAAABKgAFFAgIIwANAIglAA==.心上眉间:BAAAKgAFFAgIBAAAAA==.',['心动']='心动:BAAAKgAECgQIBQAAAA==.',['志愿']='志愿当校长:BAAAKgADCggIFwAAAA==.',['怒牙']='怒牙:BAAAKgADCgIIAgAAAA==.',['恶魔']='恶魔小鱼仔:BAAAKgAECgIIAgAAAA==.恶魔笛:BAAAKgADCggIFgAAAA==.',['情人']='情人无悔:BAAAKgAECgEIAQAAAA==.',['情沙']='情沙岭:BAAAKgAECggIEQAAAA==.',['情流']='情流感:BAAAKgAECggIDAAAAA==.',['情系']='情系吾人:BAAAKgAECgQIBwAAAA==.',['意琦']='意琦行:BAAAKgADCgEIAQAAAA==.',['慕格']='慕格莱尼:BAAAKgAECgUIBwAAAA==.',['慢慢']='慢慢烧点卡:BAABKgAECn8rAAMZAAgIER/lCQDbAQAZAAgIER/lCQDbAQAaAAUI/BqwgwDWAAAAAA==.',['慧宝']='慧宝宝:BAABKgAFFH8UAAQUAAYIlhzdCwBmAQAUAAYIehzdCwBmAQATAAUIVBMPEQAXAQAbAAIIlxFmIACIAAAAAA==.',['我是']='我是花哥:BAACKgAFFH8NAAMHAAMIWhyjIQDsAAAHAAMIWhyjIQDsAAAIAAIIgwxdXAA+AAAqAAQKfxgAAwcACAjsGrAxAG0BAAcACAhyGrAxAG0BAAgAAwjCGRvSAIYAAAAA.',['我狗']='我狗瘾犯啦:BAAAKgAECgEIAQAAAA==.',['我的']='我的号没有了:BAAAKgADCggICAAAAA==.我的天呐:BAABKgAFFH8HAAIdAAYIIw+JAgCbAQAdAAYIIw+JAgCbAQABKgAFFAgIJgAXAHgcAA==.',['我自']='我自关门睡:BAAAKgAECggICAAAAA==.',['我行']='我行我速:BAAAKgADCggICAAAAA==.',['我訆']='我訆亣姐姐:BAAAKgAFFAMIAwAAAA==.',['戒贤']='戒贤:BAABKgAFFH8IAAIJAAgIAhUVBQDZAQAJAAgIAhUVBQDZAQAAAA==.',['战术']='战术核显卡:BAAAKgAECgcIDAAAAA==.',['戦丶']='戦丶魍:BAABKgAECn8kAAIKAAgIrBwBPQA4AgAKAAgIrBwBPQA4AgAAAA==.',['打工']='打工鱼:BAAAKgAECgEIAQAAAA==.',['执笔']='执笔书生:BAAAKgAECgMIAwAAAA==.执笔画卿颜丶:BAAAKgAECgUIBQABKgAECggILQARAL4gAA==.执笔画黛眉:BAABKgAFFH8ZAAMLAAYIlBbKCAARAQALAAYIlBbKCAARAQAgAAEI7gB3HwAuAAAAAA==.',['执迷']='执迷妳画颜:BAABKgAFFH8JAAISAAYIBhMdDwAuAQASAAYIBhMdDwAuAQABKgAFFAgIEgADAJomAA==.',['报丧']='报丧女妖丶:BAABKgAFFH8MAAMSAAgI9B/AAQCXAgASAAgI9B/AAQCXAgARAAQIfBUdEAD5AAAAAA==.',['抱得']='抱得我好痛:BAAAKgAECgcIBwAAAA==.',['拉斐']='拉斐尔娜:BAAAKgAECgcIEgAAAA==.',['拉糖']='拉糖起门告辞:BAAAKgAFFAMIAwABKgAFFAgICAADANMNAA==.',['拉风']='拉风的裤衩:BAAAKgADCgUIBwAAAA==.',['指尖']='指尖嘚律动:BAAAKgAECggICAAAAA==.',['指间']='指间的律动:BAAAKgAFFAQIBAAAAA==.',['掠风']='掠风者:BAAAKgAECggICAAAAA==.',['搏击']='搏击俱乐部:BAAAKgAECgYICQAAAA==.',['搞子']='搞子:BAAAKgAECgYIBgAAAA==.',['撕天']='撕天:BAAAKgAECgMIAwAAAA==.',['收手']='收手吧阿祖:BAAAKgAFFAIIAgAAAA==.',['斯提']='斯提亚拉:BAAAKgAECgcICAAAAA==.',['无尽']='无尽圣光:BAABKgAFFH8HAAIKAAYI/BibGwCHAQAKAAYI/BibGwCHAQAAAA==.无尽暗牧:BAABKgAFFH8OAAITAAYI8xnMBwCnAQATAAYI8xnMBwCnAQAAAA==.',['无尾']='无尾熊:BAABKgAFFH8IAAIIAAgIIRFOBwALAgAIAAgIIRFOBwALAgAAAA==.',['无敌']='无敌中登:BAACKgAFFH8RAAMDAAYI3RzpFgBMAQADAAQIeR3pFgBMAQAfAAIIbxpoIwBTAAAqAAQKfy4AAwMACAiRIEgRAGACAAMACAiRIEgRAGACAB8AAQikEhF1AEMAAAAA.无敌果然寂寞:BAABKgAFFH8aAAIQAAgIOCBOAgCuAgAQAAgIOCBOAgCuAgAAAA==.无敌篮球战神:BAAAKgAECgQIBAAAAA==.',['旺仔']='旺仔馒頭:BAAAKgAECgYICgAAAA==.',['明曰']='明曰花丶绮罗:BAAAKgAECggICAAAAA==.',['明莉']='明莉娅:BAAAKgAECgEIAQAAAA==.',['星屑']='星屑:BAABKgAECn8bAAMRAAgIiBxVJQAmAgARAAgI3BtVJQAmAgABAAYIhxjgFQA7AQAAAA==.',['星辰']='星辰圣骑:BAAAKgADCggICAAAAA==.星辰物语:BAAAKgAECggIDwAAAA==.',['春已']='春已暖花会开:BAAAKgAFFAgIAgABKgAFFAgICAAJACYOAA==.',['显微']='显微鏡:BAABKgAFFH8QAAMEAAYIphYEDgCBAQAEAAYIphYEDgCBAQAiAAUInQlXAgAIAQAAAA==.显微镜:BAABKgAFFH8IAAISAAQI4BU4DwDFAAASAAQI4BU4DwDFAAAAAA==.',['晓朵']='晓朵朵:BAAAKgAFFAgIBAAAAA==.',['晖晖']='晖晖再现:BAAAKgAECggIDQAAAA==.',['晚安']='晚安喵:BAAAKgAFFAgIBAABKgAFFAgIUAAaABcmAA==.',['景元']='景元元:BAAAKgAECgEIAQAAAA==.',['晴空']='晴空茗釼:BAAAKgAFFAYIAQAAAA==.',['暗翼']='暗翼狼魂:BAABKgAECn8WAAISAAgI7xppGQDMAQASAAgI7xppGQDMAQABKgAFFAgIDQAKAOEYAA==.',['暴虐']='暴虐的灬云螭:BAAAKgAECgQICAABKgAFFAYIBgAWAAAAAA==.暴虐的灬螺栓:BAAAKgAECggICAABKgAFFAYIBgAWAAAAAA==.暴虐的灬魍魉:BAAAKgAECggICQABKgAFFAYIBgAWAAAAAA==.',['暴躁']='暴躁的塔塔:BAAAKgADCggICAAAAA==.暴躁的胖胖:BAAAKgADCggICAAAAA==.',['暴雨']='暴雨随风:BAAAKgADCgMIAwAAAA==.',['曦哥']='曦哥小跟班:BAABKgAFFH8PAAQLAAYIfRkECgCmAQALAAYIfRkECgCmAQAhAAUISQ9gCABXAQAgAAEIAACyLAAAAAAAAA==.',['曦小']='曦小猎:BAAAKgAFFAYIBAAAAA==.',['最萌']='最萌板野友美:BAAAKgAECggICAAAAA==.',['月下']='月下千寻:BAAAKgAECgQIBwAAAA==.',['月之']='月之天狼:BAAAKgADCggICAAAAA==.月之黯:BAAAKgAECgYICQAAAA==.',['月夜']='月夜传说:BAABKgAECn8bAAQjAAgIERoFEACnAQAjAAgIERoFEACnAQAZAAUIgRxJLQBGAQAkAAYIsw14GQDsAAAAAA==.',['月盲']='月盲:BAAAKgAECgQIBAAAAA==.',['望风']='望风而逃:BAAAKgAECgMIAwAAAA==.',['木叶']='木叶医院:BAAAKgAECggIEQAAAA==.',['朶兒']='朶兒:BAAAKgADCggICAAAAA==.',['来串']='来串冰糖葫芦:BAAAKgADCggICgAAAA==.',['杨威']='杨威利:BAABKgAFFH8IAAMaAAQI8CCcKADxAAAaAAQI8CCcKADxAAAZAAEIYwcYJAA4AAAAAA==.',['杨露']='杨露禅:BAAAKgAECgUIBQAAAA==.',['松下']='松下裤带仔:BAAAKgADCgYIBgAAAA==.',['柒灬']='柒灬柒:BAAAKgAECgQIBAABKgAFFAYIBgAWAAAAAA==.',['柔王']='柔王丸:BAABKgAFFH8NAAIJAAQIvRQsDAACAQAJAAQIvRQsDAACAQAAAA==.',['柳梦']='柳梦璃:BAAAKgADCgMIBgAAAA==.',['梦多']='梦多却无她:BAAAKgAFFAYIBAAAAA==.',['梦里']='梦里无她:BAABKgAFFH8TAAIKAAYI6h2NFgCnAQAKAAYI6h2NFgCnAQAAAA==.',['梵月']='梵月清梦:BAAAKgAECgYIDQAAAA==.',['棒舞']='棒舞棍:BAABKgAFFH8GAAIRAAYItyOlCQDyAQARAAYItyOlCQDyAQAAAA==.',['楠哥']='楠哥呀:BAAAKgADCgcIBwAAAA==.',['樱桃']='樱桃子:BAAAKgADCggICAAAAA==.',['樱花']='樱花乌龙茶:BAABKgAFFH8JAAMeAAQI0RsZBgDrAAAeAAQI0RsZBgDrAAAKAAIIpyNRLAC/AAAAAA==.',['欧若']='欧若因:BAAAKgAECgYIBgAAAA==.',['正经']='正经咕咕鸡:BAAAKgAECggICgAAAA==.',['武状']='武状元:BAABKgAFFH8DAAIJAAMIFRQ+JgCKAAAJAAMIFRQ+JgCKAAAAAA==.',['毒格']='毒格拉斯:BAAAKgAECgYIBgAAAA==.',['比克']='比克脸都绿了:BAAAKgADCgMIAwAAAA==.',['毛毛']='毛毛僧:BAAAKgADCgUIBQAAAA==.',['气德']='气德龙东强:BAAAKgAECgYIDgAAAA==.',['气水']='气水:BAAAKgAECggIDAAAAA==.',['水冰']='水冰月:BAAAKgADCggICAAAAA==.',['水木']='水木生炏:BAABKgAFFH8GAAIbAAYIJxETCwBNAQAbAAYIJxETCwBNAQAAAA==.',['水水']='水水怎么知道:BAAAKgADCggICAAAAA==.',['水波']='水波:BAAAKgAECggICAAAAA==.',['水骑']='水骑呆赛高:BAAAKgADCgYIBgAAAA==.',['永耀']='永耀:BAAAKgAECgcIBwAAAA==.',['江曦']='江曦月:BAAAKgAECgEIAQAAAA==.',['沃呸']='沃呸:BAAAKgADCggICAAAAA==.',['沉醉']='沉醉灬梦魇:BAABKgAFFH8FAAIOAAUIjA0hHwAKAQAOAAUIjA0hHwAKAQABKgAFFAgIGAAOAFwdAA==.',['沙琪']='沙琪玛:BAABKgAFFH8GAAIaAAYIMQxyIAAdAQAaAAYIMQxyIAAdAQAAAA==.',['沧海']='沧海一粒:BAAAKgADCggICAAAAA==.',['沽酒']='沽酒待人归:BAABKgAFFH8FAAIKAAUIwx2EHgB3AQAKAAUIwx2EHgB3AQAAAA==.',['沾到']='沾到奶的糖:BAAAKgAFFAMIBAAAAA==.',['波伊']='波伊卡:BAAAKgADCggICQAAAA==.',['波澜']='波澜万丈:BAABKgAECn8WAAIVAAgIng6GJwBGAQAVAAgIng6GJwBGAQAAAA==.',['泷谷']='泷谷源治丶:BAAAKgAECgEIAQAAAA==.',['洛丽']='洛丽塔:BAABKgAECn8kAAMTAAgI6hU/HgDWAQATAAgI2hU/HgDWAQAUAAUI0ArJZgCAAAAAAA==.',['流影']='流影丨青霜:BAACKgAFFH8OAAIUAAQIcSVNDwA5AQAUAAQIcSVNDwA5AQAqAAQKfyAAAhQACAh8HhcZAAwCABQACAh8HhcZAAwCAAAA.',['流氓']='流氓要逆袭:BAAAKgAECggICAAAAA==.',['浴火']='浴火菩提:BAAAKgAECgMIAwAAAA==.浴火貂蝉:BAAAKgAECgIIAgAAAA==.',['海绵']='海绵丶宝宝丶:BAABKgAFFH8KAAINAAYIgRhKDwB1AQANAAYIgRhKDwB1AQAAAA==.',['淡定']='淡定法:BAAAKgADCggIDAAAAA==.',['清雨']='清雨新风:BAAAKgAECgEIAQAAAA==.',['滑雪']='滑雪:BAAAKgAECgQIBAAAAA==.',['漂移']='漂移臀:BAAAKgADCggICAAAAA==.',['潮起']='潮起潮落丶:BAAAKgADCgMIAwAAAA==.',['澳门']='澳门火腿:BAAAKgADCggIDgAAAA==.',['火球']='火球火球:BAAAKgAFFAYIBAAAAA==.',['火色']='火色梦魇:BAAAKgADCgQIBAAAAA==.',['火车']='火车王:BAABKgAFFH8UAAIOAAYInBkqAwCzAQAOAAYInBkqAwCzAQAAAA==.',['火辣']='火辣孕妇:BAAAKgAECggICwAAAA==.',['灬枫']='灬枫灬:BAAAKgAECgEIAQAAAA==.',['灵性']='灵性选手:BAABKgAFFH8GAAMUAAYIJxciCAD2AAAUAAQIdhoiCAD2AAATAAIIMhJ9FQCzAAAAAA==.',['炉火']='炉火纯青:BAABKgAFFH8YAAIKAAgI8hNEAgDCAQAKAAgI8hNEAgDCAQAAAA==.',['烟花']='烟花迷离:BAABKgAECn8uAAILAAgIYBGsVQA+AQALAAgIYBGsVQA+AQAAAA==.',['热烈']='热烈的马:BAABKgAFFH8OAAIGAAgIjBykAwBzAgAGAAgIjBykAwBzAgAAAA==.',['爪爪']='爪爪虚:BAAAKgADCggICAAAAA==.',['爬开']='爬开老子宁静:BAABKgAECn8eAAQaAAgIggdOPgCPAAAaAAUIyglOPgCPAAAZAAgIMQORXgBvAAAjAAQIBwXuFQBkAAAAAA==.爬开老子来射:BAABKgAECn8aAAIIAAgIHBRVPQCwAQAIAAgIHBRVPQCwAQAAAA==.爬开老子来滚:BAABKgAECn85AAQdAAgIPAsWEwAmAQAdAAgIPAsWEwAmAQAJAAgI2wK3HQB2AAAcAAEIRQSHJwAMAAAAAA==.爬开老子英勇:BAABKgAECn8eAAMLAAgIVQolbwDfAAALAAgIVQolbwDfAAAhAAUIKAINIAAsAAAAAA==.爬开老子起门:BAABKgAECn8hAAMDAAgIqgWpNgBtAAADAAgIqgWpNgBtAAAfAAEIRwIqjAALAAAAAA==.',['牛小']='牛小风:BAABKgAFFH8IAAIMAAgIPgwlCADZAQAMAAgIPgwlCADZAQAAAA==.',['牧歌']='牧歌丶:BAABKgAFFH8GAAIKAAYICBk5EQCMAQAKAAYICBk5EQCMAQAAAA==.',['狂暴']='狂暴阿义:BAAAKgAECggIDwAAAA==.',['狐头']='狐头虎脑:BAAAKgADCgMIAwAAAA==.',['狐尼']='狐尼克:BAAAKgADCgMIAwAAAA==.',['狖夜']='狖夜鸣:BAACKgAFFH8IAAIhAAMIpwlbFQCnAAAhAAMIpwlbFQCnAAAqAAQKfxwAAiEACAjwFd8dANkBACEACAjwFd8dANkBAAAA.',['狩猎']='狩猎猫咪:BAABKgAECn8XAAMIAAcIyRuqSADaAQAIAAcIyRuqSADaAQAHAAQI3RVIWQC6AAAAAA==.',['独一']='独一无二:BAAAKgAFFAQIBAABKgAFFAgICAAgAEwYAA==.',['独行']='独行的猎手:BAAAKgADCgEIAQAAAA==.',['猎彧']='猎彧:BAAAKgAFFAMIAwAAAA==.',['猪皮']='猪皮大尼哥:BAAAKgAFFAMIAwAAAA==.',['猫宫']='猫宫汐诺:BAAAKgADCgcIBwAAAA==.',['猫的']='猫的魔法密林:BAAAKgAECgMIBAAAAA==.',['獨家']='獨家丨記憶:BAAAKgAECggICAAAAA==.',['玉树']='玉树丨临风:BAABKgAECn8lAAMOAAgIAxjyFAC4AQAOAAcIAhryFAC4AQAVAAgIChHDKQAwAQAAAA==.玉树彡临风:BAAAKgAECgMIAwAAAA==.',['王令']='王令昶:BAAAKgADCggICAAAAA==.',['王者']='王者荣耀:BAAAKgADCgYIBgAAAA==.',['玛珐']='玛珐里奥怒风:BAAAKgADCgQIBgAAAA==.',['班尼']='班尼:BAAAKgAECggICAAAAA==.',['琛心']='琛心如月:BAAAKgAFFAUIAgABKgAFFAgIEQAZAD4jAA==.',['瑶玲']='瑶玲:BAAAKgAFFAgIBAAAAA==.',['用头']='用头创你:BAABKgAFFH8IAAMZAAQIwxdpDABBAQAZAAQIwxdpDABBAQAaAAMIlRkVKAD0AAAAAA==.',['略略']='略略圙我很帅:BAAAKgAECgIIAgAAAA==.',['白凤']='白凤九:BAAAKgAECgUIBQAAAA==.',['白色']='白色秃鹫:BAACKgAFFH8FAAMHAAUIGwlRHgAAAQAHAAQI0QlRHgAAAQAIAAEIRgZoTwA4AAAqAAQKfxcAAggABgiyFi92AFIBAAgABgiyFi92AFIBAAAA.',['皆安']='皆安丶:BAAAKgADCggICAAAAA==.',['皮了']='皮了个皮:BAAAKgAFFAQIBAAAAA==.',['皮皮']='皮皮:BAABKgAECn8YAAMTAAgI1x/bCQCHAgATAAgI1x/bCQCHAgAbAAgIYgbVPgABAQAAAA==.',['皮肚']='皮肚三鲜面:BAAAKgADCggICAAAAA==.',['盖世']='盖世丹妮莉丝:BAAAKgAECgMIAwAAAA==.盖世老司机:BAAAKgAECgUIBQAAAA==.',['盖尔']='盖尔加朵:BAAAKgAECgEIAQAAAA==.',['看丨']='看丨灰机:BAAAKgAFFAQIBAAAAA==.',['看个']='看个锤子看:BAAAKgADCggICAAAAA==.',['睚眦']='睚眦轻狂:BAABKgAFFH8JAAIDAAYIqx8CDgCtAQADAAYIqx8CDgCtAQABKgAFFAgIBgACAJkUAA==.',['瞌睡']='瞌睡虫中士:BAAAKgADCgIIAgAAAA==.',['知妇']='知妇宝:BAAAKgAECgcIBwAAAA==.',['石棉']='石棉铁板烧:BAAAKgAFFAMIAwAAAA==.',['硬而']='硬而不软:BAAAKgAECgIIAgAAAA==.',['神圣']='神圣殿堂:BAAAKgAECgQIBgAAAA==.',['神射']='神射手:BAAAKgADCgIIAgAAAA==.',['神灬']='神灬灬牧:BAAAKgAECgcIBwAAAA==.',['神牧']='神牧会武术:BAAAKgAECgUIBwAAAA==.',['稀神']='稀神探女:BAAAKgAECgYIBgAAAA==.',['空大']='空大玩的嗨:BAAAKgAFFAYIAgAAAA==.',['空袭']='空袭巴格达:BAABKgAFFH8OAAMfAAUIIiC8AwD8AAADAAQIJCChCAAfAQAfAAUILB+8AwD8AAAAAA==.',['简单']='简单独特:BAAAKgADCgIIAgAAAA==.',['简短']='简短:BAAAKgAFFAIIAgAAAA==.',['箭痕']='箭痕:BAAAKgAECgIIAwAAAA==.',['米菈']='米菈娜:BAAAKgAECgcICAAAAA==.',['米诺']='米诺绯:BAAAKgAFFAMIBAAAAA==.米诺陶斯:BAAAKgADCgIIAgAAAA==.',['索兰']='索兰莉安:BAAAKgAECgUIBQAAAA==.',['紫竉']='紫竉:BAACKgAFFH8fAAIKAAgIhyEEDAAKAgAKAAgIhyEEDAAKAgAqAAQKfxUAAgoACAhHJTkkAJ4BAAoACAhHJTkkAJ4BAAAA.',['紫色']='紫色风云:BAAAKgAECgUIBQAAAA==.',['紫龍']='紫龍:BAACKgAFFH8LAAIIAAQIYB11JAD2AAAIAAQIYB11JAD2AAAqAAQKfxgAAwgACAi/I9chADUCAAgACAisIdchADUCAAcAAgjXIdB3AGAAAAAA.',['紫龙']='紫龙神骑士:BAAAKgAECgYIDAAAAA==.',['紳丶']='紳丶經:BAAAKgADCgQIBAAAAA==.',['红烧']='红烧蹄膀:BAAAKgAECggICAAAAA==.',['红祭']='红祭司:BAABKgAFFH8IAAIIAAQIhA/6HADiAAAIAAQIhA/6HADiAAAAAA==.',['红薯']='红薯干:BAABKgAFFH8GAAIIAAIIoRb/LQCeAAAIAAIIoRb/LQCeAAAAAA==.',['红魔']='红魔马球王:BAAAKgAECgEIAQAAAA==.红魔魔力鸟:BAAAKgADCgYIBgAAAA==.',['纲手']='纲手大婶:BAAAKgADCggICAAAAA==.',['纳格']='纳格兰的晨星:BAAAKgAECgQIBQAAAA==.',['纵火']='纵火犯:BAABKgAECn8eAAIQAAgIfhMWNwC5AQAQAAgIfhMWNwC5AQAAAA==.',['终级']='终级刺杀:BAAAKgAECgMIAwAAAA==.',['经理']='经理:BAAAKgADCgIIAwAAAA==.',['绝黛']='绝黛:BAAAKgAECgYIDgAAAA==.',['绯红']='绯红女王:BAAAKgAECgMIAwAAAA==.',['缘生']='缘生意转:BAABKgAFFH8FAAILAAUIVwwSHwD/AAALAAUIVwwSHwD/AAABKgAFFAgIBgALADwFAA==.',['罐子']='罐子:BAAAKgAECgQIBgAAAA==.',['罚罪']='罚罪:BAAAKgADCgIIBwAAAA==.',['美味']='美味山羊:BAAAKgAECgQIBAAAAA==.',['美国']='美国盾长:BAAAKgAECggICAAAAA==.',['美式']='美式加奶:BAAAKgADCggICAAAAA==.',['美麗']='美麗的錯過:BAAAKgAECgUIBQAAAA==.',['老司']='老司机带带你:BAAAKgAECgIIAgAAAA==.',['老王']='老王头:BAAAKgADCgUICAAAAA==.',['老郭']='老郭不上线:BAAAKgADCgQIBAAAAA==.',['胖胖']='胖胖不怕胖:BAAAKgAFFAIIAgAAAA==.胖胖的代理:BAAAKgADCggICAAAAA==.胖胖的小二号:BAAAKgAECggIEgAAAA==.胖胖的小号:BAAAKgAECgUIBQAAAA==.胖胖的花生米:BAAAKgAFFAIIAwAAAA==.',['腹肌']='腹肌南波湾:BAAAKgAECgEIAQAAAA==.',['腼腆']='腼腆的柳如烟:BAABKgAFFH8KAAMHAAYI7Q7tGAAiAQAHAAYIBwvtGAAiAQAIAAIIgxc4MQCXAAAAAA==.',['致命']='致命骑帅:BAAAKgAECgEIAQAAAA==.',['舔狗']='舔狗飞行日记:BAAAKgADCggIDQABKgAECggIJwAHAAwcAA==.',['舞风']='舞风弄月:BAAAKgAECgQIBwAAAA==.',['艾欧']='艾欧泽亚:BAAAKgAECggICAAAAA==.',['芒果']='芒果鸭:BAAAKgAECgUIBQAAAA==.',['芡影']='芡影惊鸿:BAAAKgADCggICAAAAA==.',['花脸']='花脸猫丶:BAABKgAECn8iAAMkAAgIyB3gBgBgAgAkAAgIyB3gBgBgAgAaAAIIxgF30QAlAAAAAA==.',['花花']='花花小弋:BAABKgAFFH8GAAISAAYIoSJSBQDvAQASAAYIoSJSBQDvAQABKgAFFAgIBQAFAKALAA==.',['花靥']='花靥:BAAAKgAFFAgIBAAAAA==.',['芳华']='芳华如梦:BAABKgAFFH8GAAIKAAYIfBiCHQB9AQAKAAYIfBiCHQB9AQAAAA==.',['芷爲']='芷爲伱醉:BAAAKgAFFAQIBAAAAA==.',['芸熙']='芸熙宝贝:BAAAKgADCgUIBQAAAA==.',['苍丶']='苍丶响:BAAAKgAFFAMIBAAAAA==.',['苏妈']='苏妈:BAAAKgAECgQIBQAAAA==.',['英雄']='英雄之魂:BAAAKgAFFAEIAQAAAA==.',['草莓']='草莓胖次:BAABKgAFFH8HAAIOAAQIQwNfOwCQAAAOAAQIQwNfOwCQAAAAAA==.',['莹天']='莹天耀:BAABKgAFFH8GAAINAAYIMQqODwA2AQANAAYIMQqODwA2AQABKgAFFAgIBgANALAdAA==.莹天辛:BAABKgAFFH8MAAIOAAYIphkIAwC2AQAOAAYIphkIAwC2AQABKgAFFAgIGQAOANkhAA==.',['菁姑']='菁姑姑:BAAAKgAFFAIIAgAAAA==.',['菲牟']='菲牟尼欣:BAAAKgAECgcIEwAAAA==.',['萌子']='萌子有点瞎:BAAAKgAECggIDwAAAA==.',['萌系']='萌系先生:BAABKgAECn8fAAMQAAgIWBMIFQCbAQAQAAgIWBMIFQCbAQAPAAEIAQu4sQAqAAAAAA==.',['萌萌']='萌萌哒灬老爬:BAABKgAECn8wAAQKAAgIkQ8HNwAxAQAKAAgIkQ8HNwAxAQAFAAMIJAbnIgAzAAAeAAIIMgToJQAiAAAAAA==.',['萨安']='萨安德萨:BAAAKgAECgQIBAAAAA==.',['萨顶']='萨顶顶你个肺:BAAAKgAECgIIAgAAAA==.',['落叶']='落叶又无痕:BAAAKgADCgIIAgAAAA==.',['落雨']='落雨随风:BAAAKgAFFAEIAQAAAA==.',['著雍']='著雍:BAAAKgAECgQIBAAAAA==.',['葩啪']='葩啪啪:BAAAKgAFFAIIBAAAAA==.',['蒂罗']='蒂罗亚斯:BAABKgAECn8mAAIRAAgIfiKPDAC6AgARAAgIfiKPDAC6AgAAAA==.',['蒋稻']='蒋稻礼:BAAAKgAECgQIBAAAAA==.',['蓝雨']='蓝雨:BAAAKgAECggIDgAAAA==.',['蕾米']='蕾米羅亚:BAABKgAFFH8IAAIGAAgIAALSDACAAQAGAAgIAALSDACAAQAAAA==.',['薛迪']='薛迪凯:BAAAKgADCggICAAAAA==.',['藜曼']='藜曼鲁斯:BAABKgAFFH8MAAMRAAYIqREWCwBlAQARAAYIZhAWCwBlAQASAAYIrw1+FAD+AAAAAA==.',['虚空']='虚空噩魔:BAAAKgAECggICAAAAA==.',['虾味']='虾味胡萝卜:BAAAKgADCgYIBgAAAA==.',['蛇皮']='蛇皮怪:BAAAKgAFFAQIBAAAAA==.',['蜗牛']='蜗牛大魔王:BAACKgAFFH8cAAQDAAgIaRkxEQCCAQADAAgI8RcxEQCCAQAfAAMIYhPPFgCSAAACAAIIdBXcEgCRAAAqAAQKfzUABAMACAiTH0QtAL8BAAMABwhbGkQtAL8BAAIABAhvHaAYACsBAB8AAQg6HHx1AEsAAAAA.',['蝇火']='蝇火:BAABKgAFFH8eAAMMAAgIuCA1AgCyAgAMAAgIuCA1AgCyAgAXAAYI1yAnBQDjAQAAAA==.',['蝇神']='蝇神:BAAAKgAFFAQIAwAAAA==.',['螃蟹']='螃蟹必须滚啊:BAAAKgAECgUIBQAAAA==.',['血丨']='血丨直加:BAAAKgAFFAQIBAAAAA==.',['血之']='血之印记:BAAAKgAECgIIBgAAAA==.',['血手']='血手:BAABKgAFFH8UAAIEAAYI+RfsDgBxAQAEAAYI+RfsDgBxAQAAAA==.',['血脸']='血脸三哥:BAAAKgAECgQIBAAAAA==.',['血色']='血色小毛:BAAAKgADCgMIAwAAAA==.',['表哥']='表哥哥:BAABKgAFFH8lAAQUAAgIvxsBBAAMAgAUAAgInxoBBAAMAgATAAUIcxKRBQA7AQAbAAMIFB01GgCuAAAAAA==.',['袖染']='袖染尘香:BAABKgAFFH8KAAIMAAYIGRpNDACHAQAMAAYIGRpNDACHAQAAAA==.',['西府']='西府趙王:BAAAKgAECgIIAgAAAA==.',['西行']='西行寺幽幽子:BAAAKgAECgYIBAABKgAECggICQAWAAAAAA==.',['训犬']='训犬师:BAAAKgAECgQIBAAAAA==.',['诸神']='诸神的毁灭:BAAAKgADCgIIBAAAAA==.',['豆芽']='豆芽妹:BAABKgAECn8YAAMXAAgIcQWqPQDAAAAXAAgIYAWqPQDAAAAYAAQIpALCRQBCAAAAAA==.豆芽妹妹:BAABKgAECn82AAMOAAgI0Qz8IgAxAQAOAAgIVwz8IgAxAQAVAAcIAwbOHACFAAAAAA==.',['贤者']='贤者贵为德:BAAAKgAECggIEAAAAA==.',['赛德']='赛德克弧光:BAAAKgAECgYIBgAAAA==.',['赞美']='赞美愚者:BAAAKgAFFAMIAgAAAA==.',['跑太']='跑太快看不见:BAAAKgAECgcIDgAAAA==.',['路娅']='路娅:BAAAKgAECgQIBAAAAA==.',['路婭']='路婭:BAABKgAECn8iAAIYAAgIQQnWHwAEAQAYAAgIQQnWHwAEAQAAAA==.',['跳起']='跳起来射膝盖:BAABKgAFFH8FAAMHAAUIxBkvFwCoAAAHAAIIwBcvFwCoAAAIAAMIyBu6MACYAAAAAA==.',['身后']='身后的背影:BAAAKgAFFAIIAgAAAA==.',['这风']='这风儿好喧嚣:BAABKgAFFH8GAAIKAAYINgJyKADGAAAKAAYINgJyKADGAAAAAA==.',['迷恋']='迷恋尘世:BAAAKgADCgQIBQAAAA==.',['迷矢']='迷矢的爱:BAAAKgAECgQIBAAAAA==.',['迷途']='迷途羔羊丶:BAAAKgADCggICgAAAA==.',['逐梦']='逐梦:BAAAKgAECgQIBwAAAA==.',['逝去']='逝去的微风:BAABKgAFFH8FAAILAAMI0gqhNwChAAALAAMI0gqhNwChAAAAAA==.',['遗忘']='遗忘教主:BAABKgAECn8VAAIDAAgI5QSTfgBQAAADAAgI5QSTfgBQAAAAAA==.',['那年']='那年夏天:BAAAKgADCgcIBwAAAA==.',['那晚']='那晚:BAAAKgADCggIEAAAAA==.',['邪丶']='邪丶血帝凯:BAABKgAFFH8UAAISAAYIxx1xBwCrAQASAAYIxx1xBwCrAQAAAA==.',['邪恶']='邪恶圣光:BAAAKgAECgEIAQAAAA==.',['酒醉']='酒醉月满楼:BAAAKgAECggICAAAAA==.',['醉影']='醉影满楼:BAAAKgAFFAQIBAAAAA==.',['醉爱']='醉爱长安法:BAABKgAFFH8FAAIQAAUIux08JgC6AAAQAAUIux08JgC6AAABKgAFFAgIBAAWAAAAAA==.',['野人']='野人新之助:BAAAKgADCgIIAgAAAA==.',['铁铁']='铁铁侠:BAAAKgAECgYIBgAAAA==.',['银眸']='银眸邪瞳:BAAAKgAECgUICgAAAA==.',['镰刀']='镰刀挥挥:BAABKgAFFH8GAAIIAAYIQBfJDgCIAQAIAAYIQBfJDgCIAQAAAA==.',['长剑']='长剑断水丶:BAAAKgAECgIIAgAAAA==.',['闪电']='闪电丶皮卡丘:BAABKgAECn8WAAMgAAcIBhkDOwAkAQAgAAYIkRYDOwAkAQALAAYIHg5vfgC3AAAAAA==.闪电拳:BAAAKgAECgIIAgAAAA==.',['闭麦']='闭麦听歌:BAAAKgAECggIEAAAAA==.',['闻聞']='闻聞闻:BAAAKgAFFAgIBAAAAA==.',['阿古']='阿古斯逃亡者:BAAAKgAECgEIAQAAAA==.',['阿布']='阿布是紫狗:BAABKgAFFH8KAAIOAAYIeBgYAwC1AQAOAAYIeBgYAwC1AQAAAA==.',['阿拉']='阿拉德露:BAAAKgADCggICAAAAA==.',['阿木']='阿木丨牧:BAABKgAFFH8OAAITAAQImiM/BQBAAQATAAQImiM/BQBAAQAAAA==.',['阿氪']='阿氪萌德丶:BAABKgAFFH8GAAMaAAYIqRseDAAPAQAaAAUIGCIeDAAPAQAZAAEI1wgqNgBDAAAAAA==.',['阿耳']='阿耳忒弥丝:BAAAKgADCgIIAgAAAA==.',['阿芙']='阿芙萝蒂娜:BAABKgAFFH8OAAIKAAQIFxn2IQDkAAAKAAQIFxn2IQDkAAAAAA==.',['降喵']='降喵伏汪:BAABKgAFFH8KAAIHAAYIMBGmCwDvAAAHAAYIMBGmCwDvAAAAAA==.',['除暴']='除暴安良:BAABKgAFFH8LAAIKAAQIByNCDgAbAQAKAAQIByNCDgAbAQABKgAFFAgIEAAIACYbAA==.',['随风']='随风宝宇:BAAAKgAECggICAAAAA==.',['难以']='难以灬忘姬:BAAAKgAECggICQAAAA==.',['雪碧']='雪碧灬怪人:BAAAKgAECgMIBQABKgAFFAYIBgAWAAAAAA==.',['雪落']='雪落无痕:BAAAKgAECgEIAQAAAA==.',['雷咯']='雷咯:BAAAKgAECgEIAQAAAA==.',['雷震']='雷震子:BAAAKgAECgIIAgAAAA==.',['霸气']='霸气橙子:BAAAKgAFFAYIBAAAAA==.',['青龙']='青龙熊师:BAAAKgADCggICAAAAA==.',['靖婧']='靖婧婧:BAAAKgAECgcIDgAAAA==.',['靖帛']='靖帛帛:BAAAKgAECgQIBAAAAA==.',['静晶']='静晶晶:BAAAKgAECggIDQAAAA==.',['静谧']='静谧:BAABKgAFFH8LAAIJAAQIMBuzDwDqAAAJAAQIMBuzDwDqAAAAAA==.',['顶你']='顶你不顺:BAAAKgADCgEIAQAAAA==.',['顾小']='顾小桑:BAABKgAFFH8IAAIHAAYIkBD4DAAyAQAHAAYIkBD4DAAyAQAAAA==.',['颓废']='颓废也士罪:BAAAKgAECgMIAwAAAA==.',['風導']='風導星歌:BAABKgAFFH8FAAMUAAIIeAmMOQBaAAAUAAIIeAmMOQBaAAATAAEIBwKPKwA2AAAAAA==.',['风之']='风之魂殇:BAAAKgAFFAUIBAAAAA==.',['风从']='风从云起:BAAAKgADCgEIAQAAAA==.',['风动']='风动:BAAAKgAECggIDAAAAA==.',['风陵']='风陵的渡口:BAAAKgAECgUIBQAAAA==.',['风骚']='风骚男孩:BAAAKgAECgMIAwAAAA==.',['饕餮']='饕餮贝贝:BAABKgAFFH8GAAIIAAYIZBLBEQBpAQAIAAYIZBLBEQBpAQAAAA==.',['首席']='首席小纯洁:BAAAKgADCggICAAAAA==.',['香克']='香克斯的美酒:BAAAKgAECggIEAAAAA==.',['馬幢']='馬幢幢:BAAAKgAECggICwAAAA==.',['马本']='马本在:BAAAKgADCgYIBgAAAA==.',['骑士']='骑士不想走:BAAAKgAECgMIAwAAAA==.',['高冷']='高冷小可爱:BAABKgAFFH8QAAIDAAgI2xt6AgCEAgADAAgI2xt6AgCEAgAAAA==.',['高大']='高大形象:BAAAKgAECgQIBwAAAA==.',['鬼泣']='鬼泣:BAACKgAFFH8RAAIYAAMIdwI+EwBiAAAYAAMIdwI+EwBiAAAqAAQKfxoAAhgACAhPCvwmAMsAABgACAhPCvwmAMsAAAAA.',['魂之']='魂之挽戈:BAABKgAFFH8JAAIXAAYIKCAKBQDnAQAXAAYIKCAKBQDnAQAAAA==.',['魅影']='魅影小小:BAAAKgADCgEIAQAAAA==.',['鱼丸']='鱼丸米线:BAAAKgAECgQIBAAAAA==.鱼丸粗面:BAABKgAECn8lAAISAAgIXQgfPQDMAAASAAgIXQgfPQDMAAAAAA==.',['鲨鱼']='鲨鱼小小:BAAAKgAFFAYIAwABKgAFFAgICwALAP4jAA==.',['麦兜']='麦兜响噹噹:BAABKgAECn8WAAMHAAgIogzzSgDxAAAHAAgIogzzSgDxAAAIAAUI5AXh6wBbAAAAAA==.',['麦可']='麦可可:BAAAKgAFFAUIBAAAAA==.',['麦辣']='麦辣舞:BAAAKgAECgYIDQAAAA==.',['黄卷']='黄卷青灯:BAAAKgAECgcIDQAAAA==.',['黄色']='黄色杠毛侠:BAAAKgADCggICAAAAA==.',['黎明']='黎明光年之外:BAAAKgAECgcICAAAAA==.',['黑夜']='黑夜游侠:BAAAKgAFFAQIBAAAAA==.',['黑色']='黑色皮球:BAAAKgADCggICgAAAA==.',['黑贝']='黑贝贼嘻嘻:BAABKgAFFH8KAAIRAAYIUQovGgBMAQARAAYIUQovGgBMAQAAAA==.黑贝贼小妹:BAAAKgAFFAIIAgAAAA==.',['龙汐']='龙汐:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end