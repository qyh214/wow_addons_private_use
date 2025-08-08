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
 local lookup = {'DemonHunter-Havoc','Priest-Discipline','DemonHunter-Vengeance','Druid-Guardian','Paladin-Protection','Monk-Brewmaster','Hunter-Marksmanship','Priest-Holy','Priest-Shadow','Shaman-Elemental','Shaman-Restoration','Druid-Balance','DeathKnight-Frost','DeathKnight-Unholy','DeathKnight-Blood','Mage-Frost','Mage-Arcane','Mage-Fire','Warlock-Destruction','Warrior-Fury','Paladin-Retribution','Warrior-Protection','Druid-Restoration','Hunter-BeastMastery','Monk-Mistweaver','Shaman-Enhancement','Unknown-Unknown','Monk-Windwalker','Warrior-Arms','Warlock-Demonology','Rogue-Assassination','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Paladin-Holy',}; local provider = {region='CN',realm='冬拥湖',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Acemoglu:BAAAKgAECgQIBAAAAA==.',Ar='Arteezy:BAAAKgAFFAIIAwAAAA==.',Ax='Axc:BAAAKgADCgUIBQAAAA==.',Ba='Bababala:BAAAKgAECgYIBgAAAA==.Ballala:BAABKgAECn8XAAIBAAgI4BvAHAAcAgABAAgI4BvAHAAcAgAAAA==.',Br='Bringshadow:BAAAKgAECgYICQAAAA==.Brokeneyes:BAAAKgADCggICAAAAA==.',Da='Danan:BAABKgAFFH8HAAICAAQIOxJ4EQDRAAACAAQIOxJ4EQDRAAAAAA==.',Db='Dbdxdh:BAABKgAFFH8GAAIDAAYInQQDCQC9AAADAAYInQQDCQC9AAAAAA==.Dbdxdry:BAABKgAFFH8GAAIEAAYIbwvNAgDiAAAEAAYIbwvNAgDiAAAAAA==.Dbdxsqs:BAABKgAFFH8GAAIFAAYIzgImDQCsAAAFAAYIzgImDQCsAAAAAA==.Dbdxws:BAABKgAFFH8GAAIGAAYImgT+BADQAAAGAAYImgT+BADQAAAAAA==.',De='Deepseek:BAAAKgAECggIBwAAAA==.Deter:BAABKgAFFH8GAAIHAAYIUR0TDQCIAQAHAAYIUR0TDQCIAQAAAA==.',En='Enasce:BAAAKgADCggIDAAAAA==.',Fi='Fiaclagear:BAAAKgADCggICAAAAA==.Fissio:BAAAKgAFFAIIAgAAAA==.',Fo='Foching:BAAAKgAFFAQIAQAAAA==.Foreverforev:BAAAKgAECggICAAAAA==.Four:BAAAKgAECgMIAwAAAA==.',Gl='Glorysoul:BAABKgAFFH8GAAIBAAYIaR04EQB4AQABAAYIaR04EQB4AQAAAA==.',Ho='Holyheart:BAAAKgAECggIEAAAAA==.',Jo='Joucwj:BAAAKgAECgYIBgAAAA==.',Ki='Kioomi:BAAAKgADCggICAAAAA==.',Kk='Kkeepgone:BAABKgAFFH8FAAQIAAQIShTHLQCOAAAIAAIILB3HLQCOAAAJAAII9BHPIQB8AAACAAEIkg83MABQAAABKgAFFAgIEwAKAMEkAA==.',Kr='Kroenen:BAAAKgAECggICAAAAA==.',La='Lamourest:BAAAKgADCgYIBgAAAA==.',Lo='Lolol:BAAAKgAECgMIAwAAAA==.',Ma='Manga:BAAAKgAFFAQIBAAAAA==.Maybeam:BAABKgAFFH8HAAIJAAQISReaEwDhAAAJAAQISReaEwDhAAAAAA==.',Mi='Missrobin:BAACKgAFFH8iAAIIAAMIgiVzBAAfAQAIAAMIgiVzBAAfAQAqAAQKf04AAggACAhCJRMEAM8CAAgACAhCJRMEAM8CAAAA.',Ni='Nirxdtante:BAAAKgAFFAgIAQAAAA==.',No='Notinlovel:BAAAKgAECggICQAAAA==.',Oh='Ohoojeelay:BAABKgAFFH8SAAILAAYI9hVxFAA0AQALAAYI9hVxFAA0AQAAAA==.',['Qú']='Qúeen:BAAAKgADCgQIBAAAAA==.',Ra='Rainmbow:BAABKgAFFH8MAAIMAAMI8RHNNgDDAAAMAAMI8RHNNgDDAAAAAA==.',Re='Reona:BAAAKgAFFAYIBAAAAA==.',Sa='Sam:BAAAKgAECggIDAAAAA==.Santorinss:BAABKgAFFH8PAAMNAAgI4xasAwBvAQAOAAgIZw0YBwDjAQANAAYIJBWsAwBvAQAAAA==.',Se='Sendyouhome:BAAAKgAECgMIBgAAAA==.Sevenfour:BAAAKgADCggICAAAAA==.Sevenzone:BAAAKgADCgEIAQAAAA==.',Sh='Shermie:BAAAKgAECgYIBgAAAA==.',['Sè']='Sè:BAABKgAFFH8OAAMNAAMIBAwxDAC3AAANAAMITQoxDAC3AAAPAAIIbAsuLwBTAAAAAA==.',Ty='Tydrande:BAAAKgADCgIIAwAAAA==.',Zz='Zzle:BAAAKgAECgIIAgAAAA==.',['一壶']='一壶美酒:BAAAKgAECggICAAAAA==.',['一晦']='一晦气一:BAAAKgAFFAgIBAAAAA==.',['一朵']='一朵俊美男子:BAAAKgAFFAIIAgAAAA==.一朵小芽芽:BAAAKgAECgQIBQAAAA==.',['一锤']='一锤八十:BAAAKgAECgUIBQAAAA==.',['一颗']='一颗大菠萝:BAAAKgAECgMIAgAAAA==.',['七个']='七个隆小恰恰:BAAAKgAECggIDgAAAA==.',['七月']='七月:BAAAKgAECggICwABKgAFFAgIDAAMAHMZAA==.',['上帝']='上帝在你手背:BAAAKgAECgEIAQAAAA==.上帝在你眼中:BAAAKgADCgMIAwAAAA==.',['下雨']='下雨:BAAAKgAECgIIAwAAAA==.',['不打']='不打高难:BAAAKgADCggICAAAAA==.',['东京']='东京闹五鼠:BAABKgAFFH8PAAMQAAMIgwvDFwB5AAARAAMI5wdyMgCaAAAQAAIIEgzDFwB5AAAAAA==.',['丨小']='丨小小筱亭丶:BAABKgAECn8UAAIQAAYIhQv4XgDvAAAQAAYIhQv4XgDvAAAAAA==.',['丨白']='丨白沙在涅丨:BAAAKgAECgQIBAAAAA==.',['个人']='个人练习生:BAAAKgAECgEIAQAAAA==.',['丶尛']='丶尛尛佳:BAAAKgAECgUIBgAAAA==.',['丶桐']='丶桐崎千棘:BAABKgAFFH8IAAIMAAgI7RVYBwAuAgAMAAgI7RVYBwAuAgAAAA==.',['丶白']='丶白芷:BAABKgAFFH8JAAISAAUIBh93CAB5AQASAAUIBh93CAB5AQAAAA==.',['丶鏖']='丶鏖战灬蓝天:BAABKgAFFH8IAAITAAgIXhKIBwAZAgATAAgIXhKIBwAZAgAAAA==.',['丿血']='丿血刃灬:BAAAKgAFFAMIAwAAAA==.',['乄红']='乄红尘:BAAAKgAFFAEIAQAAAA==.',['乌鸦']='乌鸦:BAABKgAECn8YAAIOAAgIXg+DQABwAQAOAAgIXg+DQABwAQAAAA==.',['九如']='九如:BAAAKgADCgQIBAAAAA==.',['予君']='予君:BAAAKgAECgYIBwAAAA==.',['云归']='云归争渡:BAAAKgAFFAIIBAAAAA==.',['五星']='五星欧皇:BAAAKgAECgUICgAAAA==.',['亚丝']='亚丝娜:BAABKgAFFH8GAAIUAAYIYg6mEABLAQAUAAYIYg6mEABLAQAAAA==.',['任迪']='任迪:BAAAKgADCggICAAAAA==.',['伊之']='伊之喵:BAAAKgAECgMIAwAAAA==.伊之大鸟:BAAAKgADCgMIAwAAAA==.',['优然']='优然:BAAAKgAECgUIBQAAAA==.',['优雅']='优雅的颓废:BAAAKgAECggICQAAAA==.',['伟大']='伟大的狄奥:BAAAKgAECggIEgAAAA==.',['你多']='你多小:BAAAKgAECgEIAQAAAA==.',['你无']='你无敌了:BAAAKgADCggIEAAAAA==.',['你是']='你是我的苏菲:BAAAKgAECggIDgAAAA==.',['你最']='你最大:BAAAKgAECgUIBQAAAA==.',['佳成']='佳成毛:BAAAKgAECgYIBgAAAA==.',['修玛']='修玛:BAAAKgAECgIIAgAAAA==.',['倒镜']='倒镜里那公路:BAAAKgAECgYIBgAAAA==.',['光明']='光明之刃:BAAAKgADCggICAAAAA==.',['兜里']='兜里没悠米:BAAAKgAECgIIAgAAAA==.',['全奶']='全奶练习:BAABKgAFFH8JAAIFAAMIDQa5FQBSAAAFAAMIDQa5FQBSAAAAAA==.',['全村']='全村的希望:BAAAKgAECgUIBQAAAA==.',['冰与']='冰与火的距离:BAAAKgAECgMIAwAAAA==.',['决战']='决战圣徒:BAAAKgADCgMIAwAAAA==.',['几田']='几田莉拉:BAABKgAFFH8IAAQIAAQIXyHnDQDMAAAIAAQIXxPnDQDMAAACAAMIHyOKHQCuAAAJAAEIgxRaLQA/AAABKgAFFAgIEAACAC0SAA==.',['刀哥']='刀哥:BAABKgAECn8XAAIVAAgIjgCokgAPAAAVAAgIjgCokgAPAAAAAA==.',['刑部']='刑部尚书:BAAAKgAECgUIBQAAAA==.',['刚放']='刚放出来的:BAAAKgAECggIDgAAAA==.',['别去']='别去海滩了丶:BAAAKgAECgYIBgAAAA==.',['动科']='动科小桶:BAABKgAFFH8GAAIRAAYIugq4DQBjAQARAAYIugq4DQBjAQAAAA==.',['励人']='励人幸:BAAAKgAECgUIBQAAAA==.',['北丶']='北丶岛:BAABKgAFFH8IAAIHAAQIMxt9DADqAAAHAAQIMxt9DADqAAAAAA==.',['北冥']='北冥先生:BAACKgAFFH8RAAIUAAgIDhE/BgANAgAUAAgIDhE/BgANAgAqAAQKfxcAAhQACAg/FJsuAMwBABQACAg/FJsuAMwBAAAA.',['北海']='北海道的樱花:BAABKgAFFH8HAAIDAAMI5BFNCgCoAAADAAMI5BFNCgCoAAAAAA==.',['十晦']='十晦气十:BAAAKgAFFAgIAwAAAA==.',['南朝']='南朝鲜我:BAAAKgAECgYICwAAAA==.',['厂长']='厂长:BAAAKgAECgEIAQAAAA==.',['原味']='原味茄子:BAAAKgADCgcIBwAAAA==.',['取啥']='取啥:BAAAKgAECggIDgAAAA==.',['口水']='口水敷脸:BAAAKgAFFAMIAwAAAA==.',['只奶']='只奶妹子:BAAAKgAECgQIBAAAAA==.',['叮个']='叮个隆咚镪:BAAAKgAECgYICAAAAA==.',['司徒']='司徒钟:BAAAKgADCggICAAAAA==.',['同道']='同道中人:BAABKgAFFH8HAAIPAAcIpQPyFwDhAAAPAAcIpQPyFwDhAAAAAA==.',['周老']='周老师的宝贝:BAAAKgAECgUIBwAAAA==.',['咆哮']='咆哮回忆:BAAAKgAECggICAAAAA==.',['啾啾']='啾啾小牙牙:BAABKgAFFH8HAAICAAcIxBAlCwBjAQACAAcIxBAlCwBjAQAAAA==.',['善良']='善良妹:BAAAKgAECgIIAwAAAA==.',['喵叻']='喵叻咯咪:BAABKgAECn8eAAILAAgI9g9fSwBNAQALAAgI9g9fSwBNAQAAAA==.',['嗜血']='嗜血角斗士:BAABKgAFFH8OAAIUAAMIOg9HIADSAAAUAAMIOg9HIADSAAAAAA==.',['嗜鳕']='嗜鳕和尚:BAABKgAFFH8MAAIWAAMIigfICgB9AAAWAAMIigfICgB9AAAAAA==.',['四法']='四法青云:BAAAKgAECgcIDQAAAA==.',['土不']='土不蜡基:BAAAKgADCgQIBAAAAA==.',['圣光']='圣光与我无关:BAAAKgADCgYIBgAAAA==.圣光爆米花:BAAAKgADCgcIBwAAAA==.',['圣型']='圣型尤物丷:BAACKgAFFH8MAAQJAAgI6RmqBwCaAQAJAAcIWhiqBwCaAQACAAQIsRrZCAARAQAIAAEIMAXyPgA9AAAqAAQKf10DBAgACAhfJWIEAMsCAAgACAhfJWIEAMsCAAkACAgwJLgHAKICAAIAAwiBFqJNAN4AAAAA.',['圣骑']='圣骑王者:BAAAKgAECgQIBAAAAA==.',['地铁']='地铁伍号:BAAAKgAFFAIIAgAAAA==.地铁叁号:BAABKgAFFH8KAAIXAAMIEheZGQDUAAAXAAMIEheZGQDUAAAAAA==.地铁四号:BAAAKgAFFAEIAQAAAA==.',['坑总']='坑总:BAAAKgAECggIAQABKgAFFAgICAAYAHkgAA==.',['境灬']='境灬:BAAAKgAECgIIAgAAAA==.',['夏尔']='夏尔:BAABKgAFFH8GAAITAAYIFxK6GgAwAQATAAYIFxK6GgAwAQAAAA==.',['外星']='外星人憨憨:BAAAKgAFFAUIBAABKgAFFAgIEgAZACAPAA==.外星人橙汁:BAAAKgAECgcIEQAAAA==.外星韦小宝:BAAAKgAFFAQIBAAAAA==.',['夜色']='夜色下的神祇:BAABKgAFFH8FAAIXAAUIPhb2EgAHAQAXAAUIPhb2EgAHAQABKgAFFAgIKQAMAGQbAA==.',['大主']='大主教:BAABKgAFFH8IAAIRAAQIUBNSFQA6AQARAAQIUBNSFQA6AQAAAA==.',['奀黑']='奀黑牛:BAABKgAECn8qAAQLAAgI8wrRKQDnAAALAAgI8wrRKQDnAAAKAAYICQeoUwDKAAAaAAUINAi0NQCjAAAAAA==.',['奶孩']='奶孩子的辣妈:BAAAKgAECgYIBgAAAA==.',['好无']='好无丶奈:BAABKgAFFH8GAAIVAAIIjQPBRwBsAAAVAAIIjQPBRwBsAAAAAA==.好无丶聊:BAAAKgAFFAMIAwAAAA==.',['好运']='好运常在:BAAAKgAFFAQIAQAAAA==.',['好问']='好问题:BAABKgAFFH8KAAILAAYI4wfgGAAdAQALAAYI4wfgGAAdAQAAAA==.',['妖冫']='妖冫:BAAAKgADCgIIAgAAAA==.',['妖精']='妖精灵儿:BAAAKgADCgUIBwAAAA==.',['子菲']='子菲鱼:BAAAKgADCggICAAAAA==.',['安吉']='安吉:BAAAKgAFFAYIBAAAAA==.',['宣告']='宣告者的神巫:BAACKgAFFH8OAAIJAAYIRSHaCQAQAQAJAAYIRSHaCQAQAQAqAAQKfx8AAgkACAiMIb0MAIUCAAkACAiMIb0MAIUCAAAA.',['小卜']='小卜丶柯:BAAAKgAECgEIAQAAAA==.',['小咸']='小咸鱼的战:BAAAKgADCggICAABKgAECggICwAbAAAAAA==.',['小城']='小城往事:BAACKgAFFH8UAAIcAAMI3h5ZDQAGAQAcAAMI3h5ZDQAGAQAqAAQKfy8AAhwACAhBIJ4TAEUCABwACAhBIJ4TAEUCAAAA.',['小太']='小太爷:BAAAKgADCgcIBwAAAA==.',['小斑']='小斑斑:BAAAKgAECggICAAAAA==.',['小桃']='小桃:BAABKgAFFH8GAAIOAAYIpxxuDwCkAQAOAAYIpxxuDwCkAQAAAA==.',['小牙']='小牙嘎嘣脆:BAAAKgAECgYIBgABKgAFFAgIEwAIAP0gAA==.',['小酒']='小酒酿:BAAAKgADCgEIAQAAAA==.',['小饼']='小饼:BAAAKgAECgYIDAAAAA==.',['小马']='小马灬飞飞:BAAAKgADCggICAAAAA==.',['小鸡']='小鸡能射星:BAAAKgAFFAEIAQAAAA==.',['尛乀']='尛乀馒头:BAAAKgADCggICAAAAA==.',['就是']='就是弄:BAAAKgAECggICAAAAA==.',['巴啦']='巴啦啦小龙人:BAAAKgAECggICwAAAA==.',['希尔']='希尔瓦拉斯:BAAAKgADCgcIBwAAAA==.',['带翅']='带翅膀的奔驰:BAAAKgADCggICAAAAA==.',['常世']='常世:BAAAKgAECgMIAwAAAA==.',['幻雪']='幻雪琴儿:BAAAKgAECggICAAAAA==.',['开心']='开心的玩:BAAAKgADCggICAAAAA==.',['很迷']='很迷茫:BAABKgAFFH8FAAMHAAMIJxDOMQCpAAAHAAMIwg7OMQCpAAAYAAEIRwakTgA6AAAAAA==.',['德伍']='德伍:BAAAKgAECgMICgAAAA==.',['德叁']='德叁:BAAAKgAECgMIEAAAAA==.',['德壹']='德壹:BAAAKgAECggIDwAAAA==.',['德无']='德无命:BAAAKgAECgUIBQAAAA==.',['德玛']='德玛西亚马仔:BAAAKgAFFAgIBAAAAA==.',['德肆']='德肆:BAAAKgAECgMIDQAAAA==.',['德莱']='德莱:BAAAKgAFFAIIAgAAAA==.',['德贰']='德贰:BAAAKgAECggIDwAAAA==.',['念小']='念小旧:BAAAKgADCggIEAABKgAFFAYIBgAYAB8MAA==.',['怒放']='怒放的青春丶:BAAAKgAECgEIAQAAAA==.',['悠亚']='悠亚永不过时:BAAAKgAECgUIBgAAAA==.',['悲尘']='悲尘大师:BAABKgAFFH8GAAIZAAYIWBJKCQBLAQAZAAYIWBJKCQBLAQAAAA==.',['想太']='想太多先生:BAAAKgADCgcIBwAAAA==.',['愤怒']='愤怒的骨头:BAAAKgAECggICAAAAA==.',['我不']='我不入地獄:BAAAKgAFFAgIBAAAAA==.',['我最']='我最棒:BAAAKgAFFAIIAgAAAA==.',['我问']='我问你好笑么:BAABKgAFFH8GAAIcAAYIZhArCgBBAQAcAAYIZhArCgBBAQAAAA==.',['扎古']='扎古:BAAAKgADCgYIBgAAAA==.',['扛把']='扛把子:BAAAKgADCggICAAAAA==.',['执笔']='执笔写爱:BAAAKgAECgEIAQAAAA==.',['扯灬']='扯灬丁丁:BAAAKgAECgUIBQAAAA==.',['扯线']='扯线木偶:BAABKgAFFH8MAAIVAAQIEiL3CwAlAQAVAAQIEiL3CwAlAQAAAA==.',['抃風']='抃風儛润:BAAAKgAFFAMIAwAAAA==.',['提裤']='提裤子就走:BAAAKgADCggICAAAAA==.',['支持']='支持:BAAAKgADCgYIBgAAAA==.',['无奈']='无奈丶啊:BAAAKgAECgMIAQAAAA==.',['暗夜']='暗夜女祭司:BAAAKgADCgQIBAAAAA==.',['暗小']='暗小夜:BAAAKgADCggICAAAAA==.',['暗黑']='暗黑之殇:BAAAKgADCgYIBgAAAA==.',['月舞']='月舞丶:BAAAKgADCgEIAQAAAA==.',['朝廷']='朝廷心腹:BAAAKgADCgQIBAAAAA==.',['朝蕣']='朝蕣:BAAAKgAFFAQIAwAAAA==.',['木三']='木三丶:BAABKgAECn8hAAIIAAgIKh7fFwADAgAIAAgIKh7fFwADAgAAAA==.木三丶德:BAABKgAFFH8MAAMXAAgIFQv1CgBXAQAXAAcIGwv1CgBXAQAMAAEIXwO6XQA/AAAAAA==.',['末端']='末端遺傳因子:BAAAKgADCgQIBAAAAA==.',['朱鹭']='朱鹭子:BAAAKgAFFAQIBAAAAA==.',['朽慕']='朽慕:BAAAKgAECgYIBgAAAA==.',['杨恭']='杨恭如:BAAAKgAECgcICgAAAA==.',['林深']='林深河:BAAAKgADCgIIAgAAAA==.',['柳暗']='柳暗花明:BAAAKgADCggICAAAAA==.',['栀子']='栀子茶茶:BAABKgAFFH8GAAMCAAYIDhxsFgDfAAACAAQIshhsFgDfAAAJAAII0BWLHwCNAAAAAA==.',['楚狂']='楚狂奴:BAAAKgAECgIIAgAAAA==.',['楠墨']='楠墨香:BAAAKgADCggICAAAAA==.',['樱岛']='樱岛麻衣:BAABKgAECn/rAQQRAAgI7yUdBABXAgASAAgI5CS3EwB/AgARAAYI8CUdBABXAgAQAAMIDBxfZwDUAAAAAA==.',['橙风']='橙风沐雨:BAAAKgAECggIDwAAAA==.',['欺骗']='欺骗空间:BAABKgAECn8aAAMJAAcITxCPFgA6AQAJAAcITxCPFgA6AQACAAUIpASJKgBJAAAAAA==.',['武林']='武林盟主:BAAAKgAFFAQIBAAAAA==.',['残月']='残月下的黑暗:BAABKgAFFH8GAAIOAAMI+gHiHQBqAAAOAAMI+gHiHQBqAAAAAA==.',['每天']='每天都要开心:BAAAKgAECggICAAAAA==.',['水晶']='水晶小德:BAAAKgAFFAYIBAABKgAFFAgIAQAbAAAAAA==.水晶枫叶:BAAAKgAECgEIAwAAAA==.',['永夜']='永夜之术:BAAAKgADCgMIAwAAAA==.',['沉默']='沉默:BAAAKgADCggICAAAAA==.',['沐王']='沐王府二号:BAAAKgADCggICAAAAA==.',['沐雨']='沐雨橙风:BAAAKgAFFAMIAwAAAA==.',['没事']='没事儿偷着乐:BAAAKgAFFAgIBAAAAA==.',['波波']='波波猪:BAAAKgAFFAQIBAAAAA==.',['波涛']='波涛使者:BAABKgAFFH8HAAIIAAMIGhi3IADEAAAIAAMIGhi3IADEAAAAAA==.',['流浪']='流浪猫丶:BAABKgAFFH8FAAMQAAMIEBvGHgCPAAAQAAMIKhbGHgCPAAARAAEI2x6bQABVAAAAAA==.',['浴霸']='浴霸不能:BAAAKgADCgQIBAAAAA==.',['渃言']='渃言丶:BAAAKgAECgUIBQAAAA==.',['湮灭']='湮灭的爱:BAAAKgAFFAYIBAAAAA==.',['满满']='满满都是爱:BAAAKgADCggICAAAAA==.',['潴小']='潴小薰:BAABKgAFFH8OAAMEAAMIsQ9cBwCZAAAEAAMIsQ9cBwCZAAAXAAIIwg2wGQB0AAAAAA==.',['灌注']='灌注记得缴费:BAABKgAFFH8GAAICAAYIxBUDFwDaAAACAAYIxBUDFwDaAAAAAA==.',['灬慕']='灬慕黑彡:BAAAKgADCgQIBAAAAA==.',['灵狐']='灵狐灬踏银砂:BAAAKgAFFAgIAQAAAA==.',['熊大']='熊大的新世界:BAAAKgADCgMIAwAAAA==.',['熊德']='熊德:BAAAKgAFFAYIAgAAAA==.',['熊没']='熊没:BAAAKgAECgUIBQAAAA==.',['熊魔']='熊魔煞:BAAAKgADCgMIAwAAAA==.',['爱霏']='爱霏霏:BAAAKgAECgcIBwAAAA==.',['牛肉']='牛肉烧麦君:BAAAKgAECgUIBQAAAA==.',['牵着']='牵着晓猪漫步:BAABKgAFFH8GAAILAAYIsBJCMQC0AAALAAYIsBJCMQC0AAAAAA==.',['狂戦']='狂戦灬二锅头:BAAAKgAECgUIBgABKgAFFAcIAQAbAAAAAA==.',['狂砍']='狂砍老牛:BAAAKgADCgQIBAAAAA==.',['狄奥']='狄奥:BAAAKgAECgYIBgAAAA==.',['狐狸']='狐狸狐狸:BAAAKgAECgYIBgAAAA==.',['狠迷']='狠迷茫:BAAAKgAECgMIAwAAAA==.',['狸喵']='狸喵菜菜子:BAABKgAFFH8JAAIYAAMINA26GwC7AAAYAAMINA26GwC7AAAAAA==.',['狼得']='狼得虚鸣:BAABKgAFFH8GAAIdAAYIUBADCgBrAQAdAAYIUBADCgBrAQAAAA==.',['玄武']='玄武湖王处:BAAAKgAFFAMIBAAAAA==.',['王启']='王启年:BAAAKgADCgUIBQAAAA==.',['王者']='王者赞歌:BAABKgAECn8ZAAIPAAgIdhObHwCQAQAPAAgIdhObHwCQAQAAAA==.',['玻酱']='玻酱:BAAAKgAECgYIAwAAAA==.',['琪心']='琪心甄美:BAAAKgAECggIDwAAAA==.',['石蒜']='石蒜:BAAAKgAECgYIDAAAAA==.',['破空']='破空之矢:BAABKgAFFH8IAAIYAAQIFw9aIADXAAAYAAQIFw9aIADXAAABKgAFFAgICAAYAHMNAA==.',['碧瞳']='碧瞳妖妖:BAACKgAFFH8RAAITAAMINhcxJwDUAAATAAMINhcxJwDUAAAqAAQKfxUAAxMACAhMHLwTAAoCABMACAjoGrwTAAoCAB4AAQhxCyODAC4AAAAA.',['神丶']='神丶灯:BAAAKgADCgEIAQAAAA==.神丶艾尼路:BAAAKgAECgcICgAAAA==.',['神圣']='神圣德鲁依:BAAAKgAECggIEwAAAA==.',['神赴']='神赴我:BAABKgAFFH8MAAIVAAgIkwm2DQDHAQAVAAgIkwm2DQDHAQAAAA==.',['穿云']='穿云贱:BAAAKgAECggIEQAAAA==.',['窃贼']='窃贼的烟玉:BAABKgAFFH8TAAIfAAUIRh0qDQB7AQAfAAUIRh0qDQB7AQAAAA==.',['粉色']='粉色的浪蹄子:BAAAKgADCggICAAAAA==.',['紅美']='紅美玲:BAABKgAFFH8UAAIZAAMILyRTDwA2AQAZAAMILyRTDwA2AQAAAA==.',['纯萌']='纯萌新:BAAAKgAECgQIBAAAAA==.',['织朵']='织朵蛀小牙:BAAAKgAFFAQIBAAAAA==.',['老北']='老北京肉龙:BAABKgAECn9CAAQgAAQIRSXBBwCnAQAgAAQIRSXBBwCnAQAhAAMIiCEOCAAUAQAiAAII5xHlVQBxAAAAAA==.',['聪明']='聪明性紊乱:BAAAKgAECgQIBQAAAA==.',['肉丸']='肉丸丨四牧:BAABKgAECn95AAMCAAgIoRwvEgA1AgACAAgIgBwvEgA1AgAIAAMIpxxrSwDkAAAAAA==.肉丸儿:BAABKgAECn8QAQQjAAgIniYzAAAaAwAjAAgIniYzAAAaAwAVAAQIFxDj6wDUAAAFAAIIXAhtVwBBAAAAAA==.肉丸的头盔:BAAAKgAECgMIAwAAAA==.',['肖白']='肖白朗:BAAAKgADCggIDQAAAA==.',['胖胖']='胖胖的笨笨:BAABKgAECn8UAAIQAAgIdx2DBQBtAgAQAAgIdx2DBQBtAgAAAA==.',['脱贫']='脱贫小表哥:BAABKgAFFH8FAAIBAAMIawScIACQAAABAAMIawScIACQAAAAAA==.',['腤之']='腤之戰殇:BAACKgAFFH8OAAIUAAQIhhpMHQDfAAAUAAQIhhpMHQDfAAAqAAQKfycABBQACAizI6IGAM0CABQACAizI6IGAM0CAB0AAQiDF5heAFEAABYAAQjYEQZJADQAAAAA.',['自然']='自然何用:BAAAKgAECgQIBAAAAA==.',['芙宁']='芙宁娜:BAAAKgAECggICAAAAA==.',['芙莉']='芙莉莲:BAAAKgADCggICAAAAA==.',['芝士']='芝士就是力量:BAAAKgAECgQIBAAAAA==.',['花果']='花果山悍匪:BAAAKgAECgIIAgAAAA==.',['芸梦']='芸梦之州:BAABKgAFFH8KAAILAAYIPhmPDQB1AQALAAYIPhmPDQB1AQABKgAFFAgICQALAKUYAA==.',['苁今']='苁今以茩:BAAAKgAFFAIIAgAAAA==.',['苏菲']='苏菲丶:BAAAKgAFFAYIBAAAAA==.',['草莓']='草莓:BAAAKgAECgYIBgAAAA==.',['荣耀']='荣耀丶之风:BAABKgAFFH8GAAIQAAMI2QK6EQB3AAAQAAMI2QK6EQB3AAAAAA==.',['莽撞']='莽撞人:BAAAKgAECgMIAwAAAA==.',['菲欧']='菲欧亚娜:BAACKgAFFH8OAAIZAAQI2xlrGwChAAAZAAQI2xlrGwChAAAqAAQKfyQAAhkACAgaFb0oALcBABkACAgaFb0oALcBAAAA.',['萌萌']='萌萌懵懵:BAAAKgAFFAYIBAAAAA==.',['萨贝']='萨贝宁:BAAAKgADCggICAAAAA==.',['落丶']='落丶幕:BAAAKgADCgMIAwAAAA==.',['落单']='落单被人伦:BAABKgAECn8YAAIUAAgIrhliHgAjAgAUAAgIrhliHgAjAgAAAA==.',['落花']='落花流水雨:BAAAKgAFFAQIBAAAAA==.',['葛力']='葛力娒乔:BAABKgAFFH8SAAIUAAQIlxhjGQDyAAAUAAQIlxhjGQDyAAAAAA==.',['蓓优']='蓓优妮塔:BAAAKgAECggIEAAAAA==.',['蛋炒']='蛋炒饭灬:BAAAKgAECgUIBQAAAA==.',['血红']='血红缨:BAAAKgAECgEIAQAAAA==.',['见习']='见习圣光:BAABKgAFFH8FAAIFAAUI1gtjDgCTAAAFAAUI1gtjDgCTAAAAAA==.',['豆花']='豆花烤鱼:BAABKgAECn8kAAQUAAgIkwL1aABoAAAUAAgIkwL1aABoAAAdAAcIQQAMaAAHAAAWAAEIZAAAAAAAAAAAAA==.',['豆豆']='豆豆芒果:BAACKgAFFH8IAAIKAAQIDAxVDgCzAAAKAAQIDAxVDgCzAAAqAAQKfxwAAgoACAjUGQEIACkCAAoACAjUGQEIACkCAAAA.',['赤道']='赤道雨:BAABKgAFFH8KAAITAAMIBA8PLgC1AAATAAMIBA8PLgC1AAAAAA==.',['超级']='超级偷偷贼:BAAAKgADCggICAAAAA==.',['远房']='远房大舅子:BAAAKgAECggICAAAAA==.',['追云']='追云影:BAAAKgAECggICgAAAA==.',['酷乐']='酷乐:BAAAKgAECgMIBAAAAA==.',['钓鱼']='钓鱼大师:BAAAKgAECgYICQAAAA==.',['键盘']='键盘上的烟灰:BAABKgAECn8XAAIVAAgIWBVHcAC4AQAVAAgIWBVHcAC4AQAAAA==.',['阎魔']='阎魔爱:BAAAKgADCggICAAAAA==.',['阳光']='阳光下的星:BAAAKgADCgUIBQAAAA==.',['阿东']='阿东:BAAAKgADCggICAAAAA==.',['阿博']='阿博:BAAAKgAFFAQIBAAAAA==.',['阿库']='阿库那吗塔塔:BAAAKgAECggICAAAAA==.',['阿瑶']='阿瑶瑶:BAAAKgADCggIDgABKgAFFAgIEAARAJAaAA==.',['阿里']='阿里:BAABKgAFFH8GAAIVAAYI5ArCKQBAAQAVAAYI5ArCKQBAAQAAAA==.',['陀螺']='陀螺精:BAAAKgAECgcIBwAAAA==.',['随风']='随风的圣光:BAAAKgAECggIDAAAAA==.',['霸王']='霸王牛:BAABKgAECn8VAAIUAAgIzhQ/IADRAQAUAAgIzhQ/IADRAQAAAA==.',['青楼']='青楼城灵动:BAAAKgAECgMIAwAAAA==.',['靓到']='靓到没朋友:BAAAKgADCggICAAAAA==.',['静心']='静心思考:BAABKgAFFH8GAAIQAAQIIhN8GQCvAAAQAAQIIhN8GQCvAAAAAA==.',['韩波']='韩波:BAABKgAECn+JAgIgAAgIGyOZAQDDAgAgAAgIGyOZAQDDAgAAAA==.',['風至']='風至踏來:BAACKgAFFH8PAAIcAAcI0wzCBQDMAQAcAAcI0wzCBQDMAQAqAAQKfxUAAhwACAg2GTYmAK8BABwACAg2GTYmAK8BAAAA.',['风暴']='风暴财团猎手:BAABKgAFFH8FAAIdAAUIpBCTBwAzAQAdAAUIpBCTBwAzAQAAAA==.',['风阳']='风阳:BAAAKgAECgEIAQAAAA==.',['风霜']='风霜任漂泊:BAAAKgAFFAMIBAAAAA==.',['风骚']='风骚靓仔:BAAAKgAFFAMIAwAAAA==.',['饿熊']='饿熊咆哮:BAAAKgAECgIIAgAAAA==.',['馨的']='馨的启航:BAABKgAFFH8JAAMgAAMIXACoCwAsAAAgAAMIXACoCwAsAAAiAAEIUgBHIgASAAAAAA==.',['骑士']='骑士:BAAAKgAECgMIAwAAAA==.骑士朵朵:BAAAKgAECgMIAgAAAA==.',['骑爽']='骑爽:BAAAKgAECgYICwAAAA==.',['骗了']='骗了表妹进房:BAAAKgAFFAQIBAAAAA==.',['魏武']='魏武遗风:BAAAKgADCggICAAAAA==.',['魔丶']='魔丶赤匟马猴:BAAAKgAFFAQIBAAAAA==.',['魔贼']='魔贼一二三:BAABKgAFFH8QAAIfAAYITSUEAQDeAQAfAAYITSUEAQDeAQAAAA==.',['鲨鱼']='鲨鱼:BAAAKgADCgEIAQAAAA==.',['鸽子']='鸽子王小港:BAAAKgAECggICAAAAA==.',['麻瓜']='麻瓜四季稻:BAABKgAFFH8cAAMVAAQIhCBmMwAcAQAVAAQIhCBmMwAcAQAFAAEI0AMRFwAeAAAAAA==.',['黑豆']='黑豆芽:BAAAKgADCggICAAAAA==.',['齊迹']='齊迹:BAABKgAFFH8IAAIOAAgIIx/1AQClAgAOAAgIIx/1AQClAgAAAA==.',['龙丿']='龙丿帝:BAAAKgAECgYIBgAAAA==.',['龙理']='龙理电丝:BAABKgAFFH8IAAIYAAgIEA5JCADuAQAYAAgIEA5JCADuAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end