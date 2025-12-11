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
 local lookup = {'Paladin-Protection','DeathKnight-Frost','Mage-Frost','Mage-Arcane','Mage-Fire','Paladin-Retribution','DeathKnight-Unholy','Priest-Holy','Priest-Shadow','DemonHunter-Vengeance','Druid-Balance','Hunter-BeastMastery','Shaman-Restoration','Shaman-Elemental','DemonHunter-Havoc','Druid-Restoration','Hunter-Survival','Unknown-Unknown','DeathKnight-Blood','Rogue-Outlaw','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Paladin-Holy','Warrior-Protection','Monk-Mistweaver','Monk-Brewmaster','Hunter-Marksmanship','Rogue-Assassination','Warlock-Destruction','Warrior-Fury','Warlock-Demonology','Monk-Windwalker','Hunter-Ranged','Warlock-Affliction','Rogue-Subtlety',}; local provider = {region='CN',realm='凯尔萨斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Acane:BAACLAAFFH8OAAIBAAQIXRrwBAA/AQABAAQIXRrwBAA/AQAsAAQKfx8AAgEABwj2JDULAMcCAAEABwj2JDULAMcCAAAA.Acerola:BAABLAAFFH8KAAICAAUIyxSzOgBQAQACAAUIyxSzOgBQAQAAAA==.',Al='Alucard:BAAALAAECgYIAgAAAA==.',Be='Besiege:BAACLAAFFH8PAAIDAAQICh10BAATAQADAAQICh10BAATAQAsAAQKfyEABAMABwjJI0EOAMICAAMABwjJI0EOAMICAAQAAwixEF/bAKAAAAUAAwhNF/MVAJ4AAAAA.',Bo='Booty:BAABLAAFFH8GAAIGAAIIQBlMWgBJAAAGAAIIQBlMWgBJAAAAAA==.',Bu='Buibuibui:BAAALAAFFAIIBAAAAA==.',Ca='Carths:BAAALAADCgYIBgAAAA==.',Da='Darkkratos:BAABLAAFFH8NAAMHAAMIchPREACWAAAHAAIIHBPREACWAAACAAMIchNZXwCPAAAAAA==.',Dr='Drop:BAAALAAECgcIDAAAAA==.',Ed='Eden:BAACLAAFFH8qAAMIAAYIbhmdEgDFAQAIAAYIbhmdEgDFAQAJAAEI3QF/MQAtAAAsAAQKfygAAggACAg5FlcxABoCAAgACAg5FlcxABoCAAAA.',Eu='Euphorbia:BAABLAAFFH8HAAIKAAIIQA2XEwBlAAAKAAIIQA2XEwBlAAAAAA==.',Fr='Freya:BAAALAAECgYIDgAAAA==.Freyjastear:BAAALAAECgYIDgAAAA==.',Go='Gotnatural:BAABLAAECn8UAAILAAYIVhD0MwDyAAALAAYIVhD0MwDyAAAAAA==.',Ha='Hanalicelani:BAABLAAECn8jAAIGAAgINBanLQDcAQAGAAgINBanLQDcAQAAAA==.',Ho='Homerhsu:BAABLAAECn8ZAAICAAYIehoDlwDUAQACAAYIehoDlwDUAQAAAA==.',Hu='Hugo:BAAALAAECgQIBAAAAA==.',Ii='Iiluthian:BAABLAAFFH8MAAMFAAUIhgnRBQDZAAAEAAUIhgkMNwAYAQAFAAUIZwTRBQDZAAAAAA==.',Ir='Irucas:BAAALAAECgUIBwAAAA==.',Ju='Jupiter:BAAALAAECgYIBgAAAA==.',Ka='Kakaru:BAABLAAFFH8KAAIGAAMI2QsORgCCAAAGAAMI2QsORgCCAAAAAA==.',Li='Liang:BAAALAAFFAIIBAAAAA==.Lightcow:BAAALAAECgQICQAAAA==.Liz:BAAALAAFFAIIBAAAAA==.',Lo='Locker:BAAALAADCggICAAAAA==.Logan:BAABLAAFFH8FAAIMAAMImQt7dQB0AAAMAAMImQt7dQB0AAAAAA==.',Ma='Makko:BAAALAAFFAIIAgAAAA==.Makok:BAAALAAECgEIAQAAAA==.',Md='Mde:BAAALAADCgYIBgAAAA==.',Me='Mengde:BAAALAAECggIBQAAAA==.',Mi='Mirashel:BAAALAAFFAEIAQAAAA==.',Mo='Mogul:BAABLAAFFH8FAAICAAIIyw55awCSAAACAAIIyw55awCSAAAAAA==.Monicacmm:BAACLAAFFH8RAAINAAYI0g+DHwBfAQANAAYI0g+DHwBfAQAsAAQKfxUAAg0ABwhYFZBrAK0BAA0ABwhYFZBrAK0BAAAA.Moonn:BAAALAAECgYIBgAAAA==.',Ne='Neon:BAAALAAFFAIIBAAAAA==.',Ov='Ovck:BAAALAADCgcICgAAAA==.',Pa='Pazhani:BAACLAAFFH83AAMNAAcIESMJAwCoAgANAAcIESMJAwCoAgAOAAIIJQIqVAAmAAAsAAQKfygAAg0ACAgXI54KAA4DAA0ACAgXI54KAA4DAAAA.',Po='Pokypokey:BAABLAAFFH8GAAIMAAYI2RaGMQBzAQAMAAYI2RaGMQBzAQAAAA==.',Re='Redmoon:BAAALAADCgYIBgAAAA==.',Sa='Safari:BAABLAAFFH8GAAIPAAIIXxysOwCdAAAPAAIIXxysOwCdAAAAAA==.Saturnn:BAAALAADCggICAAAAA==.',Se='Sevenyi:BAAALAAECgEIAQAAAA==.',Sk='Skyla:BAACLAAFFH81AAMNAAYI4BXXDwBEAQANAAYI4BXXDwBEAQAOAAEIcwbQSQA9AAAsAAQKfzQAAw0ACAg/G+8wAE8CAA0ACAg/G+8wAE8CAA4ABQj8DoOKACQBAAAA.',St='Stiferz:BAABLAAFFH8NAAMDAAIIqhlVFQBEAAADAAIIqhlVFQBEAAAEAAIIBQxdYgA5AAAAAA==.',Su='Summitrex:BAAALAAFFAIIAgAAAA==.Superskiller:BAABLAAECn8aAAIQAAYIzAx4SQDwAAAQAAYIzAx4SQDwAAAAAA==.',To='Toosober:BAAALAADCgUIBQAAAA==.',Vu='Vulfpeck:BAAALAAECgcIBwAAAA==.',Wi='Wilburuncle:BAACLAAFFH8fAAIDAAYI1BmzAwCiAQADAAYI1BmzAwCiAQAsAAQKf0wAAgMACAhkJA0CAOcCAAMACAhkJA0CAOcCAAAA.Wilburunlce:BAACLAAFFH8TAAIDAAUIKRR1BwAtAQADAAUIKRR1BwAtAQAsAAQKf0QAAgMABwieI2UGAG8CAAMABwieI2UGAG8CAAEsAAUUBggfAAMA1BkA.',Ya='Yager:BAAALAAECgYIBgAAAA==.',Za='Zakia:BAAALAAECgYIBgAAAA==.',Zx='Zxcxv:BAABLAAFFH8JAAIGAAYIgBz0GgDuAAAGAAYIgBz0GgDuAAAAAA==.',['Ûl']='Ûlû:BAAALAAECggICAAAAA==.',['一世']='一世长安:BAABLAAFFH8HAAIPAAIITB95MACpAAAPAAIITB95MACpAAAAAA==.',['一只']='一只老咸鱼:BAAALAAECgQIBAAAAA==.',['一天']='一天天的:BAAALAADCgQIBAAAAA==.',['一淡']='一淡泊一:BAABLAAFFH8HAAIGAAMIdAmkSgBtAAAGAAMIdAmkSgBtAAAAAA==.一淡蛋一:BAAALAADCgUIBQAAAA==.',['一箭']='一箭绝尘:BAAALAAECgYICwAAAA==.',['一般']='一般都在跪:BAAALAAECgMIAwAAAA==.',['一袖']='一袖两青蛇:BAABLAAFFH8MAAMMAAIIQyYlJgDkAAAMAAIIQyYlJgDkAAARAAEIdCQjBwAAAAAAAA==.',['一龍']='一龍殺一:BAAALAAECgYIBQAAAA==.',['七色']='七色:BAAALAAECgUIBQAAAA==.',['三千']='三千:BAAALAAECgYIBgAAAA==.',['不忘']='不忘初心丶:BAABLAAFFH8PAAIGAAYIIBO0JABNAQAGAAYIIBO0JABNAQAAAA==.',['且试']='且试天下:BAAALAAFFAIIAgAAAA==.',['丛林']='丛林幽影:BAAALAAECgYIBwAAAA==.',['东城']='东城俊:BAAALAAECgUIBQAAAA==.',['丨不']='丨不丶闹丨:BAAALAAECggICAABLAAFFAgIAwASAAAAAA==.',['丶恐']='丶恐怖利刃:BAAALAADCggIDwAAAA==.',['丶烟']='丶烟雨渡青山:BAAALAAECgIIAgAAAA==.',['丶碧']='丶碧月:BAAALAADCgEIAQAAAA==.',['乖猫']='乖猫儿:BAABLAAFFH8GAAIMAAIIqBwsiQBIAAAMAAIIqBwsiQBIAAAAAA==.',['九叔']='九叔公:BAAALAAECgUIBQAAAA==.',['九阴']='九阴埋:BAACLAAFFH82AAICAAYIYSOZEQABAgACAAYIYSOZEQABAgAsAAQKfyIAAwIACAiYIuYpAMoCAAIABwghJeYpAMoCABMAAQjbEG1MADcAAAAA.',['亡流']='亡流星:BAAALAAFFAIIAgAAAA==.',['亦小']='亦小冰:BAAALAAECgYIBwAAAA==.',['亲亲']='亲亲怪:BAAALAAECgQIBAAAAA==.',['今夜']='今夜:BAAALAAECgMIAwAAAA==.',['今天']='今天早点睡:BAAALAADCggICAAAAA==.',['今晚']='今晚吃烤肉:BAAALAAECgYIBgAAAA==.今晚早点退:BAAALAAECgcIDQAAAA==.',['伊利']='伊利奥斯:BAAALAAECgcIBwAAAA==.',['伊库']='伊库:BAAALAAECgYIBgAAAA==.',['伊鲁']='伊鲁鲁德:BAAALAAECggIAgAAAA==.',['低调']='低调羊肉串:BAAALAAFFAYIAgABLAAFFAgIHAALAOIkAA==.',['何物']='何物为真:BAACLAAFFH8TAAIUAAYIqRSCAQCFAQAUAAYIqRSCAQCFAQAsAAQKfyMAAhQACAheI8cAAJoCABQACAheI8cAAJoCAAAA.',['佳宝']='佳宝:BAAALAAECgQIBAAAAA==.',['修利']='修利阿多雷德:BAACLAAFFH8rAAQVAAcIUiGmAwDrAQAVAAYIQiKmAwDrAQAWAAEI9hnFDQBcAAAXAAEIMhb3HABFAAAsAAQKfyUAAhUACAjFJGwBAFQDABUACAjFJGwBAFQDAAAA.',['假高']='假高兴:BAAALAAECgYIBgAAAA==.',['傻傻']='傻傻德:BAAALAAECgYIBgAAAA==.',['元素']='元素奶糖:BAABLAAFFH8IAAIOAAYIOgPPQABJAAAOAAYIOgPPQABJAAAAAA==.',['光天']='光天化日:BAAALAAECggICAAAAA==.',['光明']='光明王:BAAALAAFFAEIAQAAAA==.光明界主:BAABLAAFFH8FAAIMAAQIaw65XwDBAAAMAAQIaw65XwDBAAAAAA==.',['其疾']='其疾如风:BAACLAAFFH8IAAIMAAII2x20iABJAAAMAAII2x20iABJAAAsAAQKfxIAAgwABgimI2ouAAECAAwABgimI2ouAAECAAAA.',['再来']='再来一碗:BAAALAAECgIIAgAAAA==.',['冥界']='冥界猎魂:BAABLAAFFH8GAAIMAAYI+xQ/DADVAQAMAAYI+xQ/DADVAQAAAA==.',['冬瓜']='冬瓜茶米奈希:BAAALAAFFAIIBAAAAA==.',['冰峰']='冰峰:BAABLAAFFH8GAAIEAAYIMSCQHwCYAQAEAAYIMSCQHwCYAQAAAA==.',['冰川']='冰川天女:BAAALAAECgQIBgAAAA==.',['冰心']='冰心冷月:BAAALAAECgEIAQAAAA==.',['冰鋒']='冰鋒:BAABLAAFFH8OAAIYAAgIOwq6BwCsAQAYAAgIOwq6BwCsAQAAAA==.',['冰阔']='冰阔落:BAABLAAECn8UAAMHAAcIQCDoIACzAQAHAAYI/x/oIACzAQACAAQIhBOeWQGtAAAAAA==.',['冰雪']='冰雪女皇:BAAALAAECgYIBgAAAA==.冰雪无语:BAAALAADCgEIAQAAAA==.',['冰風']='冰風:BAACLAAFFH8fAAIGAAYIoB7fDgDOAQAGAAYIoB7fDgDOAQAsAAQKfxwAAgYACAhzIYpfACwCAAYACAhzIYpfACwCAAAA.',['冷妍']='冷妍冰霜:BAACLAAFFH8HAAINAAII0QxQYgBYAAANAAII0QxQYgBYAAAsAAQKfx8AAg0ABwi0GqUrALgBAA0ABwi0GqUrALgBAAAA.',['冷月']='冷月葬香魂:BAAALAADCgIIAgAAAA==.',['冷瞳']='冷瞳雨轩:BAABLAAECn8fAAIMAAYIHiGphwDSAQAMAAYIHiGphwDSAQAAAA==.',['凶残']='凶残的大白兔:BAACLAAFFH8aAAIGAAUItBgjJwBAAQAGAAUItBgjJwBAAQAsAAQKfzMAAgYABwg5I04uALkCAAYABwg5I04uALkCAAAA.',['初夏']='初夏浅阳:BAAALAAECgEIAQAAAA==.',['别贪']='别贪吃饱了:BAABLAAFFH8LAAIEAAIISRrDUQBKAAAEAAIISRrDUQBKAAAAAA==.',['别逼']='别逼我变龙:BAAALAAECgQIBQAAAA==.',['制裁']='制裁之剑:BAAALAAECgYICwAAAA==.',['刷刷']='刷刷乐一世:BAAALAAECgQIBAAAAA==.',['剑仙']='剑仙:BAAALAADCggICAAAAA==.',['加不']='加不起扛不住:BAAALAADCgQIBgAAAA==.',['加尔']='加尔撸仕:BAACLAAFFH8OAAIZAAYIwBFsEQA9AQAZAAYIwBFsEQA9AQAsAAQKfxQAAhkACAjtGuUfADQCABkACAjtGuUfADQCAAAA.',['勤劳']='勤劳的公牛:BAAALAADCgcIBwAAAA==.',['勾栏']='勾栏听曲:BAAALAAECgcIBgAAAA==.',['北斗']='北斗南夕子:BAABLAAFFH8FAAINAAIIRhbZPwCCAAANAAIIRhbZPwCCAAAAAA==.北斗神犬:BAACLAAFFH8QAAIaAAIICyUfDADLAAAaAAIICyUfDADLAAAsAAQKfyEAAhoACAh/JOYBAFMDABoACAh/JOYBAFMDAAEsAAUUAwgOABAA3yQA.',['十年']='十年非洲:BAAALAADCgEIAQAAAA==.',['午言']='午言双玉:BAAALAADCgMIAwAAAA==.',['南风']='南风夜:BAAALAAECgYICAAAAA==.',['南鸢']='南鸢北笙:BAACLAAFFH8eAAICAAYIRRVgLADoAAACAAYIRRVgLADoAAAsAAQKfzkAAgIACAjhIkAfAPICAAIACAjhIkAfAPICAAAA.',['原装']='原装版:BAABLAAECn8XAAINAAYIThM4UwAPAQANAAYIThM4UwAPAQAAAA==.',['双子']='双子星撒卡:BAAALAAECgYIDQAAAA==.',['只为']='只为红颜笑:BAAALAAECgEIAQAAAA==.',['叫我']='叫我挘人:BAAALAAECgYICQAAAA==.',['可乐']='可乐加片柠檬:BAABLAAFFH8QAAMGAAUIrRQoKAA5AQAGAAUIrRQoKAA5AQAYAAMINgqrIQCVAAAAAA==.',['叶落']='叶落清风丶:BAABLAAFFH8bAAMEAAYIdxpVHQCjAQAEAAYIQBhVHQCjAQADAAIItB2oCgCtAAAAAA==.',['司徒']='司徒尚轩:BAAALAAFFAIIBAAAAA==.',['吉侒']='吉侒娜:BAACLAAFFH8cAAIDAAYIpA5UBgBQAQADAAYIpA5UBgBQAQAsAAQKfx8AAwMACAihHU0QAKYCAAMACAihHU0QAKYCAAQABAg1BI/mAH0AAAAA.',['吉安']='吉安妠:BAAALAAECgcICgAAAA==.吉安訤:BAAALAAECgUIBgAAAA==.吉安雫:BAAALAAECgYICQAAAA==.',['向山']='向山河:BAAALAAFFAEIAwAAAA==.',['吻给']='吻给了烟:BAAALAAECgIIAgAAAA==.',['呆萌']='呆萌小骑士:BAAALAAECgEIAQAAAA==.呆萌憨态:BAAALAAECgYIBgAAAA==.',['咬来']='咬来咬去:BAAALAAECgYIBgAAAA==.',['唯我']='唯我独魔:BAABLAAFFH8FAAIDAAUIGxBjCAARAQADAAUIGxBjCAARAQAAAA==.',['唯闻']='唯闻玉磬依旧:BAAALAAECgYIBgABLAAFFAYIJAAbABgdAA==.',['嗨害']='嗨害海:BAAALAAECgMIAwAAAA==.',['嗷呜']='嗷呜咆哮:BAABLAAFFH8LAAQWAAMIoQbMDQBbAAAXAAIIKwjfHwBxAAAWAAMINwTMDQBbAAAVAAIIHwGAGgBXAAAAAA==.',['圣光']='圣光闪耀:BAAALAAECggICAAAAA==.圣光骑士军:BAAALAADCgYIBgAAAA==.',['圣剑']='圣剑:BAABLAAFFH8TAAIGAAUIyyHdHgBvAQAGAAUIyyHdHgBvAQAAAA==.',['埃鲁']='埃鲁妮恩:BAAALAAECgcIDAAAAA==.',['夜空']='夜空星尘:BAACLAAFFH8GAAIMAAMI6gybdgBxAAAMAAMI6gybdgBxAAAsAAQKfyYAAwwACAgTGexUAJoBAAwACAgTGexUAJoBABwAAQgABsnRABsAAAAA.',['大猪']='大猪蹄子丶:BAAALAAECgYIBgAAAA==.',['大约']='大约再冬季:BAAALAAECgYIDAAAAA==.',['大耳']='大耳狸花:BAAALAAECgQIBAAAAA==.',['大贤']='大贤者:BAAALAAFFAIIAgAAAA==.',['天之']='天之流浪:BAACLAAFFH8IAAIYAAMIfg6eEQDTAAAYAAMIfg6eEQDTAAAsAAQKfxQAAhgABwgAIDsRAIgCABgABwgAIDsRAIgCAAAA.',['天启']='天启之光:BAAALAADCgYIBgAAAA==.',['天命']='天命人:BAABLAAFFH8KAAIHAAIIhhckEQCUAAAHAAIIhhckEQCUAAAAAA==.',['天真']='天真无邪:BAAALAAFFAQIBAAAAA==.',['夫风']='夫风者:BAAALAAECgYIDAAAAA==.',['夯犟']='夯犟:BAAALAAECgYIBgAAAA==.',['夷陵']='夷陵老祖:BAAALAAFFAIIAgAAAA==.',['奥圖']='奥圖里斯:BAAALAAECgYICwAAAA==.',['奶满']='奶满人间:BAACLAAFFH8FAAIYAAIItApcKABqAAAYAAIItApcKABqAAAsAAQKfxYAAhgABgjJGhcxAKkBABgABgjJGhcxAKkBAAAA.',['好多']='好多胡子:BAACLAAFFH8qAAMcAAYIrR7hAwCqAQAcAAYIIh3hAwCqAQAMAAUIxBv5QgA9AQAsAAQKfx4AAxwABgj0JNobAIUCABwABgjRJNobAIUCAAwABghZIVBTAJ0BAAEsAAUUBwg/AB0A7iIA.',['如影']='如影随心:BAAALAAECgYIEQAAAA==.',['如梦']='如梦飞雪:BAAALAAFFAIIAgAAAA==.',['妖七']='妖七:BAAALAAECgYIDgAAAA==.',['妖刺']='妖刺:BAAALAAECgEIAQAAAA==.',['妞盾']='妞盾:BAAALAAECgQIBAAAAA==.',['妲己']='妲己名人堂:BAAALAAECgYIBgAAAA==.',['娇宠']='娇宠娘娘:BAAALAAECgYICwAAAA==.',['娇气']='娇气小奶包:BAAALAAECgQIBQAAAA==.',['娲达']='娲达西娃:BAAALAAECgQIBwAAAA==.',['婷不']='婷不下来:BAABLAAFFH8EAAIMAAIIRBecUACVAAAMAAIIRBecUACVAAAAAA==.',['孙甜']='孙甜甜:BAAALAAECgQIBAAAAA==.',['安娜']='安娜的小镜子:BAAALAAFFAQIBAAAAA==.安娜的玫瑰:BAABLAAECn8UAAMIAAgIRxNiJACSAQAIAAgIRxNiJACSAQAJAAEIZAAAAAAAAAAAAA==.',['寂寞']='寂寞沙洲冷:BAAALAAECgIIAgAAAA==.',['封火']='封火沙包:BAACLAAFFH8vAAIEAAYIFh8YHACpAQAEAAYIFh8YHACpAQAsAAQKfyUAAgQABgimIcFIACwCAAQABgimIcFIACwCAAEsAAUUBwg/AB0A7iIA.',['射的']='射的一手好箭:BAAALAAFFAIIAgAAAA==.',['小嗷']='小嗷嗷的嗷嗷:BAAALAAECgMIAwAAAA==.',['小猎']='小猎的圣骑:BAABLAAFFH8MAAIGAAUI9QuOMAAAAQAGAAUI9QuOMAAAAQAAAA==.',['小西']='小西果刚:BAABLAAFFH8FAAIeAAMIuAlkLADWAAAeAAMIuAlkLADWAAAAAA==.',['小香']='小香香幽:BAAALAAECgQIBAAAAA==.',['就是']='就是橘子:BAAALAAFFAMIAwAAAA==.',['尹美']='尹美莱:BAAALAAECgYIEgAAAA==.',['岚蓝']='岚蓝:BAAALAAECgYIBgAAAA==.',['布莱']='布莱迩:BAAALAAFFAIIBAAAAA==.',['帝尘']='帝尘:BAABLAAFFH8KAAIPAAIIshazQgCXAAAPAAIIshazQgCXAAAAAA==.',['帝慕']='帝慕:BAABLAAFFH8IAAIIAAII5QeIOgCAAAAIAAII5QeIOgCAAAAAAA==.',['帝璐']='帝璐:BAABLAAFFH8IAAICAAIIpiAGPwC0AAACAAIIpiAGPwC0AAAAAA==.',['帝苍']='帝苍:BAABLAAFFH8IAAMMAAIIrA0UYACLAAAMAAIIrA0UYACLAAAcAAIISQuAKQB1AAAAAA==.',['帝辰']='帝辰:BAABLAAFFH8FAAIGAAIIEBubTwBYAAAGAAIIEBubTwBYAAAAAA==.',['帮我']='帮我关下灯:BAAALAAECggICwAAAA==.',['年华']='年华似水:BAAALAADCgYIBgAAAA==.',['幸运']='幸运鹅:BAACLAAFFH8ZAAIIAAYInxkxEADcAQAIAAYInxkxEADcAQAsAAQKfzcAAwgABwi5IpsbAJQCAAgABwi5IpsbAJQCAAkABAjzGeQuANwAAAAA.',['幻想']='幻想家丶:BAAALAADCgUIBQAAAA==.',['弹射']='弹射起步:BAAALAAECgIIAgAAAA==.',['彌海']='彌海砂:BAAALAADCgQIBAAAAA==.',['归爷']='归爷:BAAALAADCgIIAgAAAA==.',['当心']='当心我诅咒你:BAAALAAECgYIBgAAAA==.',['彦啊']='彦啊:BAAALAAECgUIBQAAAA==.彦啊彦:BAAALAAECgQIBQAAAA==.',['彦的']='彦的战:BAAALAAECgEIAQAAAA==.',['影刺']='影刺:BAAALAADCggICAAAAA==.',['徐莉']='徐莉條褲:BAAALAAECgEIAQAAAA==.',['微波']='微波炉:BAAALAAFFAIIAgAAAA==.',['德哗']='德哗兔宝宝:BAAALAAECgMIAwAAAA==.',['德萨']='德萨:BAAALAADCgYICAAAAA==.',['德行']='德行合一:BAAALAAECgQIBAAAAA==.',['心前']='心前輩:BAAALAAECgcIEAAAAA==.',['怒峰']='怒峰:BAABLAAFFH8FAAMQAAQInxoAIwAEAQAQAAMIZx4AIwAEAQALAAII/CH3KwBSAAAAAA==.',['性感']='性感小脚丫:BAAALAAECgcICgAAAA==.',['想来']='想来一发么:BAACLAAFFH8OAAIcAAYIpQe1CgDyAAAcAAYIpQe1CgDyAAAsAAQKfyEAAhwABwitHIILAJgBABwABwitHIILAJgBAAAA.',['愤怒']='愤怒的奥伦多:BAAALAAECgYICAAAAA==.',['愺莓']='愺莓菋艿嗏:BAAALAAECgUIBQAAAA==.',['慕容']='慕容嫣然:BAAALAAECgUIBQAAAA==.慕容烟:BAAALAAECgcIDQAAAA==.',['慕白']='慕白:BAAALAAECgMIAwAAAA==.',['成分']='成分复杂:BAABLAAFFH8aAAIeAAYI4yEDDgD7AQAeAAYI4yEDDgD7AQAAAA==.',['我幽']='我幽鬼太菜了:BAAALAAECgEIAQAAAA==.',['我有']='我有小目标:BAAALAAFFAIIBAAAAA==.',['我水']='我水人太菜了:BAABLAAFFH8HAAIPAAMI2RjdPQCWAAAPAAMI2RjdPQCWAAAAAA==.',['我的']='我的衣帽间:BAAALAAECgUIBQAAAA==.',['我耳']='我耳朵很直:BAAALAAECggIEwAAAA==.',['戢熠']='戢熠:BAAALAADCgUIBQAAAA==.',['拉弓']='拉弓射箭:BAAALAAECgYIBgAAAA==.',['指尖']='指尖湮娆:BAAALAAECgYIBwAAAA==.',['挥剑']='挥剑断天涯:BAAALAADCgcIDQAAAA==.',['提里']='提里奥马丁:BAAALAAECgEIAQAAAA==.',['斩丨']='斩丨赤红之瞳:BAACLAAFFH8JAAQCAAUI1RELHABBAQACAAQIpA8LHABBAQATAAII/RpADQChAAAHAAEIxActHwBJAAAsAAQKfxsABAIACAjNIgoxAK8CAAIACAglIQoxAK8CABMABgi1HTYVAAcCAAcAAgjtH61FALEAAAAA.',['无偿']='无偿献血:BAAALAAECgYIDAAAAA==.',['无敌']='无敌啦兄弟们:BAAALAAECgUICAAAAA==.',['无聊']='无聊的薯条:BAAALAAECgIIAgAAAA==.',['无脑']='无脑输出:BAAALAAECgUIBQAAAA==.',['既寿']='既寿永昌:BAAALAADCgIIAgAAAA==.',['早安']='早安:BAAALAAECgYIBwAAAA==.',['时尚']='时尚双马尾:BAAALAADCgYIBgAAAA==.',['明天']='明天开始减肥:BAAALAAFFAIIAgABLAAFFAYIHwADANQZAA==.',['星术']='星术埃兰:BAACLAAFFH8HAAINAAIIVRH+RQB3AAANAAIIVRH+RQB3AAAsAAQKfyAAAg0ACAgPHrgmAHcCAA0ACAgPHrgmAHcCAAAA.',['星爵']='星爵:BAAALAADCgIIAgAAAA==.',['星辰']='星辰小光:BAAALAAECgcIDQAAAA==.',['星隕']='星隕:BAABLAAFFH8cAAICAAUIKxkgPQBGAQACAAUIKxkgPQBGAQABLAAFFAYIHwAGAKAeAA==.',['春牯']='春牯咕:BAAALAAECgQICAAAAA==.',['是夏']='是夏夏呀:BAAALAAECgYIBgAAAA==.',['晃来']='晃来晃去:BAAALAAECgYIBgAAAA==.',['晓月']='晓月水儿:BAAALAADCgMIAwAAAA==.晓月风儿:BAAALAAECgQIBQAAAA==.',['晚安']='晚安:BAAALAAECgYIEgAAAA==.',['普琳']='普琳:BAABLAAFFH8GAAIGAAII2RkbOQCjAAAGAAII2RkbOQCjAAAAAA==.',['暗夜']='暗夜之刃:BAAALAADCggICAAAAA==.',['暗影']='暗影魔月:BAAALAAECggIDwAAAA==.',['暗歌']='暗歌追影:BAACLAAFFH8SAAIPAAUIMhg4IQDiAAAPAAUIMhg4IQDiAAAsAAQKfxUAAg8ABwilH5A1AIcCAA8ABwilH5A1AIcCAAAA.',['暗羽']='暗羽点点:BAAALAAECgIIAwAAAA==.',['暴獵']='暴獵:BAAALAAECgUIBwAAAA==.',['最老']='最老的自由:BAAALAAECgYIBwAAAA==.',['月夜']='月夜七辰:BAAALAAECgYICwAAAA==.',['月思']='月思如伤:BAAALAAECgcIBwAAAA==.',['月球']='月球上的月饼:BAABLAAECn8VAAIfAAcIoxdOWQDmAQAfAAcIoxdOWQDmAQAAAA==.',['有志']='有志青年:BAABLAAFFH8IAAIPAAIIxAktUACMAAAPAAIIxAktUACMAAAAAA==.',['朦胧']='朦胧鸟:BAAALAAECgYIDAAAAA==.',['未完']='未完洅續:BAAALAAFFAIIBAAAAA==.',['末丶']='末丶洛:BAABLAAFFH8GAAMCAAMIlRkDQgCwAAACAAIIHRQDQgCwAAAHAAEIhiToDQBqAAAAAA==.',['朵洛']='朵洛希海娅特:BAAALAAFFAMIAwABLAAFFAgIAwASAAAAAA==.',['杀戮']='杀戮大天使:BAAALAAECgQIBAAAAA==.',['李有']='李有有药:BAAALAAECgIIAgAAAA==.李有药药:BAAALAAFFAIIAgAAAA==.',['李李']='李李有病:BAAALAAECgMIAwAAAA==.',['杨萌']='杨萌彤橙:BAABLAAFFH8IAAIGAAQI7Q3ROAC6AAAGAAQI7Q3ROAC6AAAAAA==.',['杭州']='杭州小伙:BAAALAADCgIIAgAAAA==.',['杰杰']='杰杰哥:BAAALAADCggICAAAAA==.',['极度']='极度风骚:BAACLAAFFH8HAAIgAAUISAY6BQD5AAAgAAUISAY6BQD5AAAsAAQKfxwAAyAABwhGFTsqAMsBACAABwhGFTsqAMsBAB4AAQiQBusIATEAAAAA.',['构想']='构想:BAAALAADCgQIBAAAAA==.',['柠檬']='柠檬味丶奶糖:BAAALAAECggICAABLAAFFAgIBgAZAJwbAA==.',['核武']='核武擴散條約:BAAALAAECgYIBgAAAA==.',['格格']='格格武:BAAALAAECgYIBgAAAA==.',['格温']='格温德林:BAAALAAECgcICwAAAA==.',['格调']='格调残存:BAAALAAECgIIAgAAAA==.',['桂花']='桂花清香:BAAALAAECgYIBgAAAA==.',['桐谣']='桐谣:BAAALAAECgMIAwAAAA==.',['梅丽']='梅丽亚斯:BAABLAAFFH8LAAIVAAUIqg6KEAAhAQAVAAUIqg6KEAAhAQAAAA==.',['梦回']='梦回吹角连营:BAABLAAFFH8MAAIDAAIIOBUHFQBFAAADAAIIOBUHFQBFAAAAAA==.',['梦幻']='梦幻紫精灵:BAAALAAECgYIBgAAAA==.',['梦德']='梦德的:BAAALAAECggICQAAAA==.',['梦棏']='梦棏:BAAALAADCgYIBgAAAA==.',['森之']='森之千手:BAAALAADCgcIBwAAAA==.',['樱桃']='樱桃奶卷:BAABLAAFFH8JAAIEAAYItBZiCgAYAgAEAAYItBZiCgAYAgAAAA==.',['橙筱']='橙筱筱:BAABLAAFFH8JAAIGAAII/gmOVgCMAAAGAAII/gmOVgCMAAAAAA==.',['欧鲁']='欧鲁森:BAAALAAECgYIDgAAAA==.',['死亡']='死亡猫猫:BAABLAAFFH8IAAICAAMIdRROWgCcAAACAAMIdRROWgCcAAAAAA==.',['永不']='永不离弃:BAAALAADCgEIAQAAAA==.',['沟门']='沟门子鸟惹:BAAALAAECgYIDwAAAA==.',['没事']='没事喝两口:BAAALAAECgcIBgAAAA==.没事来二两:BAAALAAECgcIDQAAAA==.',['法你']='法你老味:BAABLAAFFH8IAAIFAAIIJxS6BQCWAAAFAAIIJxS6BQCWAAAAAA==.',['泡椒']='泡椒煮茶:BAAALAAECgYIDAAAAA==.',['泡泡']='泡泡杂酱面:BAAALAAECgYIBgAAAA==.',['波灞']='波灞:BAAALAADCggICAAAAA==.',['洋贝']='洋贝溪:BAAALAAECgQIBwAAAA==.',['浅色']='浅色半夏:BAAALAAECgYIDAAAAA==.',['浅若']='浅若夏陌:BAAALAAFFAIIAgAAAA==.',['浪漫']='浪漫丶倩情:BAAALAAECgQIBAAAAA==.浪漫丶柔情:BAAALAAECgYIBgAAAA==.浪漫灬幽情:BAAALAAECgcIDAAAAA==.浪漫灬曼舞:BAAALAAECgYIBgAAAA==.浪漫灬柔情:BAAALAAECgYIBwAAAA==.',['浮夸']='浮夸小斗士:BAABLAAFFH8HAAINAAII1BJNRwB1AAANAAII1BJNRwB1AAAAAA==.',['消失']='消失的嗅觉:BAAALAAECgYIDwAAAA==.',['涩琪']='涩琪:BAAALAAECgYIBgAAAA==.',['涪陵']='涪陵榨菜:BAAALAADCgEIAQAAAA==.',['混沌']='混沌螺旋:BAAALAAECgQIBAAAAA==.',['清月']='清月如默笙:BAACLAAFFH8kAAIbAAYIGB1sCgCfAQAbAAYIGB1sCgCfAQAsAAQKfx8AAhsACAibHV8NAIQCABsACAibHV8NAIQCAAAA.',['清源']='清源:BAAALAAECgIIAgAAAA==.',['潘多']='潘多拉丶虚:BAAALAAECgEIAQAAAA==.',['潘甜']='潘甜妞:BAAALAAECgIIAgAAAA==.',['澤淚']='澤淚繪裡香:BAAALAAECgIIAgAAAA==.',['灑颟']='灑颟:BAAALAADCggICAAAAA==.',['火焰']='火焰魔月:BAABLAAECn8bAAIEAAYITw6BnABQAQAEAAYITw6BnABQAQAAAA==.',['灬六']='灬六月:BAAALAAECggICAAAAA==.',['灬冰']='灬冰冰:BAAALAADCgcIBwAAAA==.',['灬无']='灬无敌哥:BAAALAAFFAIIBAAAAA==.',['灰刺']='灰刺:BAAALAAECgYIBgAAAA==.',['灵弦']='灵弦之鸣:BAABLAAECn8VAAIMAAYIjhpFZgB2AQAMAAYIjhpFZgB2AQAAAA==.',['灾变']='灾变挽歌:BAAALAAECgYIBgAAAA==.',['烈焰']='烈焰公爵:BAAALAAECggIAwAAAA==.',['烈风']='烈风小睡神:BAAALAAECggICAAAAA==.',['热摩']='热摩卡:BAAALAADCgMIAwAAAA==.',['热血']='热血小学生:BAABLAAFFH8FAAIZAAIIagwcMgAwAAAZAAIIagwcMgAwAAAAAA==.',['焰灵']='焰灵:BAAALAAECgYIDAAAAA==.',['熊二']='熊二:BAAALAAECgYICgAAAA==.',['熊猫']='熊猫那好吧:BAABLAAFFH8FAAINAAIICwKsdQBBAAANAAIICwKsdQBBAAAAAA==.熊猫钕:BAAALAAECgYICAAAAA==.',['燃烧']='燃烧二零二零:BAABLAAFFH8GAAIEAAQImQfKIgARAQAEAAQImQfKIgARAQAAAA==.',['燕云']='燕云一骑:BAABLAAFFH8GAAMGAAYI0grlLgAPAQAGAAUInwvlLgAPAQAYAAEI6wGNMAAxAAAAAA==.',['爱你']='爱你哦:BAAALAAFFAIIBAAAAA==.',['爱喝']='爱喝无糖可乐:BAAALAAECggICAAAAA==.',['爱的']='爱的猪头:BAABLAAFFH8HAAIdAAMIigfZFgCAAAAdAAMIigfZFgCAAAAAAA==.',['牙牙']='牙牙乐贰:BAAALAAECgQIBAAAAA==.',['牛仔']='牛仔很忙:BAAALAAECgEIAQAAAA==.',['牛少']='牛少雄起:BAABLAAECn8cAAICAAgIdRohGAAnAgACAAgIdRohGAAnAgAAAA==.',['牛爷']='牛爷:BAAALAAECgEIAQAAAA==.',['牛肝']='牛肝菌儿:BAAALAAECgYIEQAAAA==.',['狂奔']='狂奔的青竹标:BAABLAAFFH8KAAIGAAUIeQ2oNQDUAAAGAAUIeQ2oNQDUAAAAAA==.',['狂猎']='狂猎:BAABLAAFFH8GAAIMAAIIRBTUhABMAAAMAAIIRBTUhABMAAAAAA==.',['狂邪']='狂邪:BAACLAAFFH8sAAICAAYItx1NHADFAQACAAYItx1NHADFAQAsAAQKfxUAAgIABgi8ITsoANUBAAIABgi8ITsoANUBAAEsAAUUBwg/AB0A7iIA.',['狂野']='狂野的西瓜:BAAALAAECgIIAgAAAA==.',['狐狸']='狐狸吃月亮:BAAALAAFFAIIAwAAAA==.',['狩獵']='狩獵禁忌:BAAALAADCgMIAwAAAA==.',['猎渊']='猎渊者希夫:BAAALAADCgYIBgAAAA==.',['猪头']='猪头麻油:BAAALAAECgIIAgAAAA==.',['猪都']='猪都被吓死:BAABLAAECn8WAAICAAgIshJhfQD+AQACAAgIshJhfQD+AQAAAA==.',['猫刺']='猫刺:BAAALAAECgMIAwAAAA==.',['猫小']='猫小么:BAABLAAFFH8IAAIGAAIInBu9LwCsAAAGAAIInBu9LwCsAAAAAA==.',['王凛']='王凛风:BAAALAAECgUIBQAAAA==.',['玛法']='玛法雷奥:BAAALAAECgcIBwAAAA==.',['珂儿']='珂儿:BAACLAAFFH8GAAMMAAII4Ax7rgA4AAAMAAII4Ax7rgA4AAAcAAEItAO9OQAvAAAsAAQKfzEAAwwABwjJF4CtAJgBAAwABwjJF4CtAJgBABwABgjyC5F2APgAAAAA.',['珈非']='珈非猫:BAAALAAECgYIBgAAAA==.',['珏影']='珏影:BAAALAAFFAIIAgAAAA==.',['琼恩']='琼恩丶雪诺:BAAALAAECgYICgAAAA==.',['瑰洱']='瑰洱:BAAALAAECgYICwAAAA==.',['生锈']='生锈的锤子:BAAALAAECgUIBQAAAA==.',['疯暴']='疯暴烈酒:BAACLAAFFH8JAAIhAAQInBM6DQDrAAAhAAQInBM6DQDrAAAsAAQKfxoAAiEABgihIn0KAP0BACEABgihIn0KAP0BAAAA.',['疯狂']='疯狂跳跳:BAAALAAECgYIBgAAAA==.',['白丨']='白丨子凡:BAAALAAECgMIAwAAAA==.',['白子']='白子凡:BAAALAAECgQIBQAAAA==.',['白露']='白露为晞:BAAALAAFFAYIAQAAAA==.',['相互']='相互伤害啊:BAAALAAECgYIDwAAAA==.',['相随']='相随丶:BAAALAAECgQIBAAAAA==.',['盾妞']='盾妞:BAAALAAECgMIAwAAAA==.',['省电']='省电侠:BAAALAAECgMIAwAAAA==.',['看热']='看热闹的小伙:BAABLAAFFH8FAAIMAAIIKBBfaACFAAAMAAIIKBBfaACFAAAAAA==.',['真假']='真假难辨:BAAALAADCgEIAQAAAA==.',['真猎']='真猎:BAAALAADCgIIAwAAAA==.',['祈福']='祈福:BAAALAAFFAIIAgAAAA==.',['神灵']='神灵之怒:BAAALAAFFAIIAwAAAA==.',['稀饭']='稀饭炒蛋:BAAALAAECgEIAQAAAA==.',['箭在']='箭在弦上:BAACLAAFFH8ZAAMMAAUI+Rw/PgBMAQAMAAUI+Rw/PgBMAQAcAAEIXBQhNQBAAAAsAAQKfxkAAwwABwhrIjUjACwCAAwABwg2IjUjACwCABwABQiqGyxPAHkBAAAA.',['米莉']='米莉红温啦:BAAALAAFFAIIAgAAAA==.',['米里']='米里亚:BAAALAAECgMIAwAAAA==.',['素還']='素還真:BAAALAAECgMIAwAAAA==.',['紫依']='紫依馨梦:BAAALAAECgYICgAAAA==.',['紫嫙']='紫嫙幽梦:BAAALAAECgYICQAAAA==.',['红浪']='红浪漫:BAABLAAFFH8GAAIOAAQI8AI4NQCIAAAOAAQI8AI4NQCIAAAAAA==.',['红色']='红色小萌龙:BAACLAAFFH8HAAIVAAUI3w2kEQAHAQAVAAUI3w2kEQAHAQAsAAQKfxQAAhUABwjhIr4IAKYCABUABwjhIr4IAKYCAAAA.',['绝版']='绝版硬:BAABLAAFFH8FAAICAAII0BjBXQCZAAACAAII0BjBXQCZAAAAAA==.',['美国']='美国叫兽:BAAALAAECgIIAgAAAA==.',['羽川']='羽川:BAABLAAFFH8NAAMJAAYIrBEkGgDbAAAJAAQIiBEkGgDbAAAIAAIIcwK+QQBnAAAAAA==.',['羽蝶']='羽蝶猫猫:BAAALAAECgMIAwAAAA==.',['翠花']='翠花上酸菜:BAAALAAFFAIIBAAAAA==.',['翻新']='翻新老爷车:BAAALAAECgYICgAAAA==.',['老利']='老利丹:BAAALAADCgMIAwAAAA==.',['老撕']='老撕鸡大忽悠:BAAALAAECgYICAABLAAFFAIIBgAaAC8TAA==.老撕鸡带带我:BAACLAAFFH8GAAIaAAIILxOsEACPAAAaAAIILxOsEACPAAAsAAQKfxwAAhoABghmHVoZAPQBABoABghmHVoZAPQBAAAA.老撕鸡皮卡丘:BAABLAAFFH8GAAINAAIIKSS0HgDRAAANAAIIKSS0HgDRAAABLAAFFAIIBgAaAC8TAA==.老撕鸡萌萌哒:BAAALAADCgcIBwABLAAFFAIIBgAaAC8TAA==.',['肆捞']='肆捞妹:BAAALAAECgMIBAAAAA==.',['肥鸡']='肥鸡:BAAALAAECgYICQAAAA==.',['胆小']='胆小的猪儿虫:BAABLAAFFH8HAAIDAAMIKAzcDwBiAAADAAMIKAzcDwBiAAAAAA==.',['背叛']='背叛有妻徒刑:BAAALAAECgUIBQAAAA==.',['胖脸']='胖脸大橘:BAAALAAECgYICgAAAA==.',['胸悍']='胸悍湿三妹:BAACLAAFFH8pAAICAAYIKRbzKgCMAQACAAYIKRbzKgCMAQAsAAQKfxsAAgIABghrHBtMAF8BAAIABghrHBtMAF8BAAAA.',['自由']='自由之盾:BAAALAAECgMIAwAAAA==.',['至高']='至高岭的荣耀:BAAALAADCgIIAgAAAA==.',['致丶']='致丶往昔:BAAALAAECgQIBAAAAA==.',['色战']='色战:BAAALAAECgUIBQAAAA==.',['艳儿']='艳儿爱吃草莓:BAAALAAFFAIIAgABLAAFFAYIBgAPAF8cAA==.',['艾德']='艾德莉安娜:BAAALAAECgYICQAAAA==.',['艾米']='艾米绿亚:BAAALAAECgUIBQAAAA==.',['花之']='花之闲:BAAALAAECgcICQAAAA==.',['花落']='花落明月:BAAALAADCgYIBgAAAA==.',['芳華']='芳華絕代:BAACLAAFFH8IAAMEAAMISA61RgCHAAAEAAMI1wy1RgCHAAADAAEIWgt5GQA9AAAsAAQKfxcAAwMABwgeHssbAD0CAAMABwgeHssbAD0CAAQABAgaE/dEAPYAAAAA.',['苏喂']='苏喂苏喂:BAAALAAECgUICQAAAA==.',['茹惈']='茹惈祢記嘚:BAAALAAECgYIBgAAAA==.',['药师']='药师丶:BAABLAAFFH8GAAIPAAIIihcRNQCiAAAPAAIIihcRNQCiAAAAAA==.',['莉丝']='莉丝亚尔珍特:BAABLAAFFH8VAAINAAYITRtaBwDJAQANAAYITRtaBwDJAQABLAAFFAcIKwAVAFIhAA==.',['莉娜']='莉娜樱柏丝:BAAALAADCgcIBwAAAA==.',['萌萌']='萌萌猪小妹:BAAALAADCgIIAgAAAA==.',['萨你']='萨你老味:BAAALAAECgMIBQAAAA==.',['葉小']='葉小釵:BAAALAAECgYIBgAAAA==.',['蒂朵']='蒂朵:BAABLAAFFH8IAAIiAAgIVAEAAAAAAAAMAAgIVAEAAAAAAAAAAA==.',['蒙面']='蒙面鲨鲨鱼:BAABLAAFFH8KAAICAAYIhhnlGABvAQACAAYIhhnlGABvAQAAAA==.',['蓝猫']='蓝猫猫:BAAALAAECgYICgAAAA==.',['蓝色']='蓝色幽深:BAABLAAFFH8IAAIMAAIIBBL+ZwCGAAAMAAIIBBL+ZwCGAAAAAA==.蓝色菠萝:BAABLAAFFH8HAAMMAAMIxBarcQB+AAAMAAMIxBarcQB+AAAcAAIIGQQqMABgAAABLAAFFAUIEwACABIWAA==.',['蔚雪']='蔚雪:BAABLAAFFH8IAAIeAAIIeBKPPgCZAAAeAAIIeBKPPgCZAAAAAA==.蔚雪丶:BAABLAAFFH8GAAIPAAIIPBPDPACcAAAPAAIIPBPDPACcAAABLAAFFAIICAAGAJwbAA==.',['薇塔']='薇塔克洛提德:BAAALAAECgYIAwABLAAFFAcIKwAVAFIhAA==.',['血染']='血染女厕:BAAALAADCggICAAAAA==.',['血燕']='血燕:BAAALAAECgIIAgAAAA==.',['血盟']='血盟:BAAALAAECgYIBgAAAA==.',['血色']='血色惡魔:BAAALAAECgMIAwAAAA==.',['街角']='街角丨死骑:BAABLAAFFH8nAAQTAAYIXSFwBADJAQATAAYIXSFwBADJAQACAAUIBB1bOgBRAQAHAAEIFAOSFABGAAAAAA==.街角丨萌狐:BAABLAAFFH8iAAQTAAYIjxjJDQArAQATAAUIHBnJDQArAQACAAQIHRCXUADaAAAHAAIIWRXVCgCoAAAAAA==.',['西卡']='西卡莱奥怒风:BAAALAAECgQIBAAAAA==.',['要你']='要你命九千型:BAAALAAECgIIAwAAAA==.',['诸葛']='诸葛杰:BAAALAAECgIIAgAAAA==.',['豪滴']='豪滴豪滴豪豪:BAAALAAECgYICgAAAA==.',['走心']='走心小辣椒:BAACLAAFFH8UAAIMAAUIBBQKTQAZAQAMAAUIBBQKTQAZAQAsAAQKfxYAAgwABgiTGsptAGgBAAwABgiTGsptAGgBAAAA.',['超白']='超白的雪籽:BAAALAADCgEIAQAAAA==.',['跟你']='跟你一换一:BAAALAAECgcICAAAAA==.',['轩辕']='轩辕娃娃:BAAALAAFFAEIAQAAAA==.轩辕改改:BAAALAAECgYICgAAAA==.',['辛多']='辛多雷的忧伤:BAAALAAECgUIBQAAAA==.',['迁亿']='迁亿:BAACLAAFFH8PAAIeAAMIPg1PTgCBAAAeAAMIPg1PTgCBAAAsAAQKfy8AAx4ACAhPF6ZAADcCAB4ACAhPF6ZAADcCACMAAwj5BzIqAJkAAAAA.',['过把']='过把瘾:BAABLAAFFH8VAAIQAAUIqBUcGQBmAQAQAAUIqBUcGQBmAQAAAA==.',['这个']='这个战十真六:BAABLAAFFH8KAAIfAAIInhCTTABHAAAfAAIInhCTTABHAAAAAA==.',['迟早']='迟早腱鞘炎:BAABLAAFFH8WAAMdAAYIeBcrDQA7AQAdAAUI/BYrDQA7AQAkAAIIjhKXEQBUAAAAAA==.',['道可']='道可名:BAAALAAECgcIEAAAAA==.',['遗忘']='遗忘古灵:BAAALAAECgQIBAAAAA==.',['那就']='那就他了吧:BAAALAAFFAIIBAAAAA==.',['都是']='都是我的错咯:BAABLAAECn8iAAIGAAcIcxOQZwA0AQAGAAcIcxOQZwA0AQAAAA==.',['酒杯']='酒杯敲你个头:BAAALAAECgYIEgAAAA==.',['酷盖']='酷盖儿:BAAALAAFFAIIBAAAAA==.',['酷酷']='酷酷潇洒哥:BAAALAAECgcIBwAAAA==.',['醉恶']='醉恶魔:BAAALAADCgIIAwAAAA==.',['醉的']='醉的不行:BAAALAAFFAIIBAAAAA==.',['醉裡']='醉裡挑燈看劍:BAABLAAFFH8LAAMMAAIIsxULXQCNAAAMAAII3RQLXQCNAAAcAAEIMRYMNABEAAAAAA==.',['释永']='释永信:BAAALAADCgYIBgAAAA==.',['野性']='野性奶糖:BAAALAADCgcIBwAAAA==.',['鍅灬']='鍅灬師:BAAALAADCgcIBwAAAA==.',['鑫旅']='鑫旅途:BAABLAAECn8XAAILAAYIIBPvKgAkAQALAAYIIBPvKgAkAQAAAA==.',['锦木']='锦木千术:BAAALAADCgcIBwAAAA==.',['长期']='长期爽食:BAAALAAECgMIAwAAAA==.长期素食:BAABLAAFFH8hAAIZAAYIEBLbEABEAQAZAAYIEBLbEABEAQAAAA==.',['闯荡']='闯荡:BAAALAAECgEIAQAAAA==.',['陈渔']='陈渔:BAABLAAECn8fAAIIAAcIEhiNIACyAQAIAAcIEhiNIACyAQAAAA==.',['隆里']='隆里电丝:BAABLAAECn8cAAICAAYIlxFuWwA6AQACAAYIlxFuWwA6AQAAAA==.',['随风']='随风之悠:BAAALAAFFAQIBAAAAA==.随风而行:BAAALAAECgYICQAAAA==.',['雅爾']='雅爾貝德:BAAALAAECgUIAgAAAA==.',['雪刺']='雪刺:BAAALAAECgUICQAAAA==.',['雷霆']='雷霆风云:BAAALAAECgMIAwAAAA==.',['雾丶']='雾丶燥:BAAALAAECgUIBQAAAA==.',['青头']='青头菌儿:BAAALAAECgYIDgAAAA==.',['青柠']='青柠养乐多:BAACLAAFFH8LAAMGAAQIpg45NwDGAAAGAAQIpg45NwDGAAABAAIIwwMuIABZAAAsAAQKfy0AAwYACAgbHbQuANgBAAYACAgbHbQuANgBAAEABwgiFAkvAJcBAAAA.',['青清']='青清苹果香:BAAALAAECgIIBAAAAA==.',['面包']='面包咬年糕:BAACLAAFFH8MAAINAAMIew4rRwCQAAANAAMIew4rRwCQAAAsAAQKfxkAAg0ACAgEEVQ1AIcBAA0ACAgEEVQ1AIcBAAAA.',['面团']='面团零零五:BAAALAADCgQIBAAAAA==.',['韦伯']='韦伯大叔:BAACLAAFFH8TAAIDAAQIJxV8BwDOAAADAAQIJxV8BwDOAAAsAAQKfzsAAgMACAi3IhQDAMcCAAMACAi3IhQDAMcCAAEsAAUUBggfAAMA1BkA.',['音爆']='音爆:BAAALAAECgYICAAAAA==.',['顶你']='顶你的包学:BAABLAAFFH8GAAIOAAIIjQvvRABDAAAOAAIIjQvvRABDAAAAAA==.',['风月']='风月大欧皇:BAABLAAFFH8LAAIXAAYIsQtbDgA3AQAXAAYIsQtbDgA3AQAAAA==.风月的薄暮:BAABLAAFFH8GAAICAAMI6wX7NADKAAACAAMI6wX7NADKAAAAAA==.',['风翎']='风翎羽:BAAALAADCgIIAgAAAA==.',['风花']='风花雪:BAAALAAECgIIAgAAAA==.',['风韵']='风韵犹存:BAAALAADCggICAAAAA==.',['风骚']='风骚的冉冉:BAAALAAECgYIBgAAAA==.',['飛天']='飛天熊喵:BAAALAADCgEIAQAAAA==.',['飞天']='飞天大咕咕:BAAALAADCgMIAwAAAA==.',['骑你']='骑你老味:BAABLAAFFH8IAAMBAAIIHBXJEwCFAAABAAIIHBXJEwCFAAAGAAIIfAipdgA6AAAAAA==.',['高端']='高端火法:BAAALAADCgMIAwAAAA==.',['鬼冢']='鬼冢英吉:BAAALAAECggIEAAAAA==.',['鬼影']='鬼影丶缠身:BAAALAAECgEIAQAAAA==.',['魔伊']='魔伊:BAAALAAECgYIBgAAAA==.',['魔法']='魔法少女乔杉:BAABLAAFFH8GAAICAAYILwJdUwDFAAACAAYILwJdUwDFAAAAAA==.',['魔艺']='魔艺:BAAALAAECgIIAgAAAA==.',['鲜血']='鲜血圣骑:BAAALAADCgEIAQAAAA==.',['鹿盔']='鹿盔姐姐:BAAALAAECgYIBgAAAA==.',['麻奎']='麻奎桑:BAAALAADCgYIDAAAAA==.',['黑曜']='黑曜丨面包包:BAABLAAFFH8FAAICAAUIlQtYWACjAAACAAUIlQtYWACjAAAAAA==.黑曜石小萌萌:BAAALAAECgcICQAAAA==.',['黑白']='黑白羽翼:BAAALAADCgEIAQAAAA==.',['黑硬']='黑硬直:BAAALAAECgcIBwAAAA==.',['黑风']='黑风白息:BAABLAAFFH8IAAIGAAQIhhiFMwDlAAAGAAQIhhiFMwDlAAAAAA==.',['龙川']='龙川小宇:BAAALAAFFAIIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end