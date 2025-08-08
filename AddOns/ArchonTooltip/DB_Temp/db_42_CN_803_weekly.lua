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
 local lookup = {'DemonHunter-Vengeance','DeathKnight-Unholy','DeathKnight-Blood','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','DemonHunter-Havoc','Monk-Mistweaver','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Rogue-Assassination','Paladin-Retribution','Monk-Brewmaster','Shaman-Elemental','Priest-Holy','Paladin-Holy','Priest-Shadow','Monk-Windwalker','Evoker-Devastation','Warrior-Fury','Priest-Discipline','Warrior-Protection','Druid-Restoration','Druid-Balance','Paladin-Protection','Mage-Arcane','Mage-Frost','Shaman-Enhancement','Shaman-Restoration','Druid-Guardian','Druid-Feral','Warrior-Arms','Mage-Fire',}; local provider = {region='CN',realm='艾萨拉',name='CN',type='weekly',zone=42,date='2025-08-08',data={Am='Amenadiel:BAAAKgAECgUIBQAAAA==.',An='Angelived:BAAAKgAECggICAAAAA==.',Be='Becky:BAAAKgADCgEIAQAAAA==.',De='Deathly:BAAAKgAFFAQIBAAAAA==.',Dk='Dk:BAAAKgAECggICAAAAA==.',Do='Dogwe:BAAAKgAFFAgIBAAAAA==.Double:BAABKgAFFH8IAAIBAAgIJwjFBABiAQABAAgIJwjFBABiAQAAAA==.',Ev='Evilwhisper:BAAAKgAECgEIAQAAAA==.',Ex='Explosion:BAAAKgADCggICAAAAA==.',Fi='Fishbean:BAAAKgAECgEIAQAAAA==.',Fr='Franky:BAAAKgADCgEIAQAAAA==.Freedom:BAAAKgAECgEIAQAAAA==.',Ha='Haloarcher:BAAAKgAECgYIBgAAAA==.Halolich:BAAAKgAFFAMIAQAAAA==.Halomana:BAAAKgAECggICAAAAA==.Hank:BAAAKgAECgEIAQAAAA==.',Je='Jev:BAAAKgAECggICAABKgAFFAgIDgACAEoXAA==.',Jo='Joy:BAAAKgAECggICAAAAA==.',Ka='Kardashian:BAABKgAFFH8GAAIDAAYIswvzCAAEAQADAAYIswvzCAAEAQAAAA==.',Le='Leslies:BAAAKgAECgQIBAABKgAECgYICgAEAAAAAA==.',Li='Lie:BAAAKgAECgUIBQABKgAECgYICgAEAAAAAA==.Lies:BAAAKgAECgYICgAAAA==.',Lr='Lr:BAABKgAECn8ZAAQFAAcIyBsNLQCFAQAFAAcI0RcNLQCFAQAGAAUIGxfWkwADAQAHAAEI8hP6HwAoAAAAAA==.',Lu='Luckyrabbit:BAAAKgAECgUIBQAAAA==.',Mi='Miskye:BAAAKgAFFAYIBAABKgAFFAgIAgAEAAAAAA==.',Mo='Moscato:BAACKgAFFH8GAAIBAAYIghIdBgA/AQABAAYIghIdBgA/AQAqAAQKfxUAAggACAhBFrUsALIBAAgACAhBFrUsALIBAAAA.',Nb='Nb:BAAAKgAECgQIBAAAAA==.',Ni='Nightreaver:BAABKgAECn8XAAICAAgI4h4UHwBIAgACAAgI4h4UHwBIAgABKgAFFAgIDwAJABYaAA==.',Nu='Numeria:BAAAKgADCgEIAQAAAA==.',Po='Po:BAAAKgAFFAIIAgAAAA==.',Re='Reopenlolz:BAAAKgAECggICQAAAA==.Rexxooxx:BAAAKgAFFAIIAgAAAA==.',Rl='Rleena:BAAAKgADCgQIBAAAAA==.',Sa='Sarah:BAAAKgADCgMIAwAAAA==.',St='Stanley:BAACKgAFFH8NAAQKAAMI1yKeDQC6AAAKAAIIjiCeDQC6AAALAAIIfh+mGgCzAAAMAAEIBCLGIwBTAAAqAAQKfyEABAoACAiMJMIPAIEBAAoABQiHJMIPAIEBAAwABQivF+83AAQBAAsAAwgHJZVmANgAAAAA.',Vi='Vivvee:BAAAKgAFFAQIAQAAAA==.',['一个']='一个小点:BAABKgAECn8WAAINAAgIXBfGEgDmAQANAAgIXBfGEgDmAQAAAA==.',['一切']='一切为了部落:BAAAKgAECgEIAQAAAA==.',['一夜']='一夜骑九次:BAAAKgAECggICQAAAA==.',['一小']='一小米一:BAAAKgADCgYIBgAAAA==.',['一步']='一步捣胃:BAAAKgAFFAQIAQAAAA==.',['三灬']='三灬十:BAAAKgAECggIEQAAAA==.',['三重']='三重刘德华:BAABKgAFFH8HAAIFAAMICQVRPgB/AAAFAAMICQVRPgB/AAAAAA==.',['下言']='下言长相忆:BAAAKgAECgMIAwAAAA==.',['不可']='不可卷也:BAAAKgAECggICQAAAA==.',['不惑']='不惑者:BAABKgAFFH8GAAIOAAYIYBJBJABaAQAOAAYIYBJBJABaAQAAAA==.',['丨瞎']='丨瞎丨子丨:BAABKgAFFH8uAAMBAAYIGyJJAgDyAQABAAYIGyJJAgDyAQAIAAYIkQ7RBACQAQABKgAFFAgIBgAPAPgLAA==.',['丶八']='丶八部浮屠:BAAAKgAECgMIAwAAAA==.',['丸丸']='丸丸:BAAAKgAECgQIBAAAAA==.',['为了']='为了圣光:BAAAKgADCgQIBAAAAA==.',['丿琳']='丿琳琅丶:BAAAKgADCggICAAAAA==.丿琳琅乀:BAAAKgAECggIDQAAAA==.',['乖小']='乖小孩儿:BAAAKgAFFAQIBAAAAA==.',['九五']='九五弍七:BAAAKgAFFAMIAwAAAA==.',['乱飞']='乱飞飞:BAAAKgADCgYIBgAAAA==.',['二丁']='二丁目:BAAAKgADCgYIBgAAAA==.',['二猪']='二猪:BAAAKgAECggIDQAAAA==.',['亮仔']='亮仔一号:BAABKgAFFH8FAAIQAAQIBQYrEwB5AAAQAAQIBQYrEwB5AAAAAA==.亮仔亮仔:BAABKgAFFH8LAAIRAAQIMQ+SKQCcAAARAAQIMQ+SKQCcAAAAAA==.亮仔会魔术:BAAAKgADCggICwAAAA==.亮仔出击:BAAAKgAECgIIAgAAAA==.亮仔别假死:BAAAKgAFFAIIAgAAAA==.亮仔别闪:BAAAKgAECgMIAgAAAA==.亮仔巭孬:BAAAKgAECgMIAgAAAA==.亮仔德:BAAAKgAECggIDgAAAA==.亮仔无敌:BAABKgAFFH8IAAMSAAQI6xJ5DgDPAAASAAQI6xJ5DgDPAAAOAAIISRAmdACCAAAAAA==.',['亮坤']='亮坤:BAABKgAECn8bAAICAAgI+B+9KAAVAgACAAgI+B+9KAAVAgAAAA==.',['人间']='人间:BAAAKgAECggICAAAAA==.',['什么']='什么小狗:BAAAKgADCgYIBgAAAA==.',['伊利']='伊利莎白:BAAAKgAECgYIBgAAAA==.',['伊扎']='伊扎克斯:BAACKgAFFH8MAAMKAAQIUiPKDQC4AAALAAQIUiNLIwDuAAAKAAIIhx/KDQC4AAAqAAQKfxgABAoACAgwIb4aABkBAAoABwi1Hb4aABkBAAwABAizFo9NALEAAAsAAgjOHEqDAEgAAAAA.',['伊瑞']='伊瑞伍:BAAAKgAECgUIBQAAAA==.',['伊瑟']='伊瑟里安:BAABKgAFFH8HAAITAAcIzQMEDQDqAAATAAcIzQMEDQDqAAAAAA==.',['何以']='何以笙箫:BAAAKgAFFAgIBAAAAA==.',['何苦']='何苦:BAABKgAFFH8GAAIFAAYI7xBwFQA4AQAFAAYI7xBwFQA4AQAAAA==.',['你怎']='你怎么不笑:BAAAKgAECgUIBQAAAA==.',['你的']='你的小爷们:BAABKgAFFH8PAAMCAAYItB2tGwBAAQACAAUICh+tGwBAAQADAAYIpw49EwAIAQAAAA==.',['依稀']='依稀:BAABKgAECn8cAAMSAAcIURc2GwCMAQASAAcIURc2GwCMAQAOAAEI8QiUdQE0AAAAAA==.',['保安']='保安:BAAAKgADCgEIAQAAAA==.',['信仰']='信仰圣光嘛:BAAAKgAECgMIAwAAAA==.',['偏財']='偏財:BAAAKgADCgQIBAAAAA==.',['健康']='健康幸福快楽:BAABKgAFFH8GAAIFAAYIdRuRCgCtAQAFAAYIdRuRCgCtAQAAAA==.',['傲天']='傲天海皇:BAAAKgADCgMIAwAAAA==.',['光头']='光头强:BAAAKgADCgEIAwAAAA==.',['光带']='光带闪电:BAAAKgAECgQIBAAAAA==.',['兔兔']='兔兔吃蘑菇:BAAAKgAECgcIEgAAAA==.',['八剑']='八剑初晴:BAAAKgAECggIDwAAAA==.',['六号']='六号:BAAAKgAFFAMIAwAAAA==.',['兽血']='兽血沸腾:BAAAKgAECggIAgAAAA==.',['再小']='再小龙:BAAAKgAECgQIBAAAAA==.',['农夫']='农夫三拳:BAAAKgAFFAQIBAAAAA==.',['冰镇']='冰镇的芒果:BAAAKgADCggICAAAAA==.',['冰雕']='冰雕猫:BAABKgAECn8cAAMJAAgISBojFQDnAQAJAAgISBojFQDnAQAUAAEIPR5YWgBYAAAAAA==.',['冰餜']='冰餜:BAAAKgAECggICAAAAA==.',['冷暖']='冷暖:BAAAKgAECgIIAgAAAA==.',['准的']='准的一笔:BAACKgAFFH8pAAIGAAgIsR50BABmAgAGAAgIsR50BABmAgAqAAQKfykAAgYACAgXI6wbAIkCAAYACAgXI6wbAIkCAAAA.',['凌宇']='凌宇轩:BAAAKgAFFAIIAgAAAA==.',['凛雁']='凛雁小轩:BAABKgAFFH8IAAIVAAgIewVpCwCKAQAVAAgIewVpCwCKAQAAAA==.',['刀光']='刀光贱影:BAAAKgAECgMIAwAAAA==.',['刈天']='刈天之龙:BAABKgAECn8eAAILAAgI/RiyIAABAgALAAgI/RiyIAABAgAAAA==.',['利百']='利百加:BAABKgAFFH8QAAIOAAgIvBSPEADbAQAOAAgIvBSPEADbAQAAAA==.',['别碰']='别碰我尾巴:BAAAKgAFFAYIAgAAAA==.',['北悸']='北悸安良:BAABKgAECn8ZAAIWAAgITiA+DwBnAgAWAAgITiA+DwBnAgAAAA==.',['北极']='北极以北:BAABKgAFFH8MAAQRAAgIHxMRCgCAAQARAAYInxYRCgCAAQATAAIIdiD6FgDEAAAXAAIIjAVuJgCCAAAAAA==.',['千夜']='千夜浮梦:BAABKgAFFH8FAAMLAAUI7w00MACtAAALAAQIrA40MACtAAAKAAEIuAsPIQBHAAAAAA==.',['千机']='千机蝶:BAACKgAFFH8VAAIOAAMIZw/dVADHAAAOAAMIZw/dVADHAAAqAAQKfykAAg4ACAgAHfY0ACwCAA4ACAgAHfY0ACwCAAAA.',['卡尔']='卡尔丶血蹄:BAABKgAFFH8GAAMWAAUIFg0fBQBHAQAWAAUIFg0fBQBHAQAYAAEI3QOlDwAuAAAAAA==.',['卤煮']='卤煮老湿:BAAAKgAECgEIAQAAAA==.',['史前']='史前巨型生蚝:BAABKgAFFH8LAAIVAAgIGhInCgDRAQAVAAgIGhInCgDRAQAAAA==.',['叶子']='叶子枫:BAABKgAFFH8GAAIOAAYIaRVcEgB3AQAOAAYIaRVcEgB3AQAAAA==.叶子舞:BAABKgAFFH8GAAIGAAYIFQrfDgA8AQAGAAYIFQrfDgA8AQAAAA==.',['叹息']='叹息的笙箫:BAAAKgAECgMIAwAAAA==.',['后勤']='后勤主管:BAABKgAFFH8OAAIDAAYIGA2dFQCgAAADAAYIGA2dFQCgAAABKgAFFAgIBgAZAOUQAA==.',['吓到']='吓到吃蕉蕉:BAAAKgAECgQIBAAAAA==.',['吕归']='吕归尘:BAAAKgADCgIIAgAAAA==.',['吻如']='吻如双下雪:BAACKgAFFH8cAAIRAAQIgBxLDgDmAAARAAQIgBxLDgDmAAAqAAQKfxgAAhEACAiwGKAQAH8BABEACAiwGKAQAH8BAAAA.',['周淮']='周淮安:BAAAKgADCgQIBAAAAA==.',['咚咚']='咚咚羌:BAAAKgAECgcIDQAAAA==.',['哇啦']='哇啦哇啦:BAAAKgADCgcIBwAAAA==.',['哈比']='哈比:BAAAKgAFFAgIBAAAAA==.',['哥布']='哥布萨:BAABKgAFFH8XAAIQAAYIwhQfCQA6AQAQAAYIwhQfCQA6AQAAAA==.',['唐家']='唐家三藏:BAABKgAFFH8PAAMYAAMIZQXJEQBuAAAWAAMIXgSSLQCJAAAYAAMIXQTJEQBuAAAAAA==.',['唐小']='唐小小:BAAAKgADCgEIAQAAAA==.',['喝酒']='喝酒捞肉:BAAAKgAFFAYIBAAAAA==.',['喵喵']='喵喵星座:BAAAKgADCgIIAgAAAA==.',['嗷嗷']='嗷嗷就是炫:BAAAKgAFFAMIAwAAAA==.',['四季']='四季红:BAABKgAECn8cAAMGAAgIBBfvRQCQAQAGAAgIBBfvRQCQAQAFAAII4BXhgQB4AAAAAA==.',['圖拉']='圖拉楊:BAAAKgAFFAEIAQAAAA==.',['圣光']='圣光已灭:BAAAKgAECgQIBAAAAA==.',['圣无']='圣无尘:BAABKgAFFH8IAAMXAAQIgR60CAASAQAXAAQIYB60CAASAQARAAMIaRkJJwCmAAAAAA==.',['基情']='基情荡漾:BAAAKgAFFAgIAwAAAA==.',['塞罗']='塞罗打怪兽:BAAAKgADCgEIAQAAAA==.',['夏禾']='夏禾:BAAAKgAFFAgIBAAAAA==.',['夕丶']='夕丶芮:BAAAKgAECggICAAAAA==.',['夜之']='夜之絮语:BAACKgAFFH8cAAMTAAQIwg2LEQCmAAATAAQIwg2LEQCmAAARAAQIaA44KwCXAAAqAAQKfyAAAxEACAiHHhkTADkCABEACAiHHhkTADkCABMABAjJGSVEAOUAAAAA.',['夜店']='夜店不好玩:BAAAKgADCggICAAAAA==.',['夜曲']='夜曲:BAAAKgAFFAQIBAAAAA==.',['夜月']='夜月战神:BAABKgAFFH8GAAIWAAYIlwl/EABNAQAWAAYIlwl/EABNAQAAAA==.夜月飘逸:BAABKgAFFH8GAAIaAAMIcQr8HwCyAAAaAAMIcQr8HwCyAAAAAA==.',['夜杀']='夜杀加血:BAAAKgAECgIIAgAAAA==.',['大嘴']='大嘴巴反正撤:BAAAKgAECgQIBAAAAA==.',['大灬']='大灬板灬砖:BAABKgAFFH8KAAIbAAYIQQfZFgDBAAAbAAYIQQfZFgDBAAAAAA==.',['大腰']='大腰子哥哥:BAABKgAFFH8IAAIcAAgIixd3BQA+AgAcAAgIixd3BQA+AgAAAA==.',['大自']='大自然的拥抱:BAAAKgAECgIIAgAAAA==.',['大花']='大花:BAAAKgAECgYIDAAAAA==.',['大蒜']='大蒜頭:BAAAKgADCggICAAAAA==.',['天灾']='天灾小轩:BAAAKgAFFAUIBAAAAA==.',['太妃']='太妃榛果:BAABKgAFFH8MAAIVAAYIWyG6CADvAQAVAAYIWyG6CADvAQAAAA==.',['头角']='头角峥嵘:BAAAKgAECgIIBAAAAA==.',['夺命']='夺命者:BAAAKgAECgYIEAAAAA==.',['夺魂']='夺魂二世:BAAAKgAECgYIBgAAAA==.',['如三']='如三月兮:BAAAKgADCggICAAAAA==.',['妖怪']='妖怪般杀戮:BAABKgAFFH8GAAIdAAMIqAQqEACQAAAdAAMIqAQqEACQAAAAAA==.',['姐姐']='姐姐哪儿疼:BAAAKgAECgEIAQAAAA==.',['姬明']='姬明月:BAABKgAFFH8GAAIOAAYI3wskFQBLAQAOAAYI3wskFQBLAQAAAA==.',['孓孑']='孓孑:BAABKgAFFH8PAAMJAAgIFhq1BAAQAgAJAAgIFhq1BAAQAgAUAAEICQoxJgA2AAAAAA==.',['守岸']='守岸:BAAAKgAECgEIAQAAAA==.',['安娜']='安娜罗曼诺娃:BAACKgAFFH8LAAQQAAMIpQjDGwCdAAAQAAMI/AfDGwCdAAAeAAIIxAeGFACGAAAfAAEIKgHYOQArAAAqAAQKfyMABB4ACAjlE3whALoBAB4ACAj/EHwhALoBABAABgh4Ey45AC0BAB8ABwhSCQJqAAMBAAAA.',['安室']='安室奶美惠:BAAAKgAECgQIBAAAAA==.',['宋丹']='宋丹丹怒风:BAAAKgAFFAQIBAAAAA==.',['小丑']='小丑鱼:BAAAKgAECgEIAQAAAA==.',['小光']='小光头找媳妇:BAAAKgAECgEIAQAAAA==.',['小小']='小小若水:BAAAKgADCggICAAAAA==.',['小时']='小时候就懵:BAAAKgAECgEIAQAAAA==.',['小熊']='小熊焰焰:BAACKgAFFH8OAAQgAAUI2BiUAwD4AAAgAAQIGx2UAwD4AAAhAAQIyQ0XBQDwAAAaAAEIAABjaQAAAAAqAAQKfzMABSAACAgkJD4CAMACACAACAgkIz4CAMACACEACAhhHlMGAFICABoABAiOEvmsAHcAABkAAQgxEZaAAEEAAAAA.',['小箭']='小箭贱:BAAAKgADCggICAAAAA==.',['尐蹄']='尐蹄子:BAAAKgAECggIEAAAAA==.',['岁月']='岁月可回首:BAABKgAFFH8GAAIiAAYIZQ5TBgBnAQAiAAYIZQ5TBgBnAQAAAA==.',['巭喵']='巭喵:BAAAKgAECgMIAwAAAA==.',['己陌']='己陌丶虞姬:BAABKgAFFH8FAAMGAAQIliHfEAAJAQAGAAQIliHfEAAJAQAFAAEIxhG8JQBKAAAAAA==.',['布拉']='布拉格子夜:BAAAKgAFFAYIBAAAAA==.',['布莱']='布莱恩桐须:BAAAKgADCgQIBAAAAA==.',['常庆']='常庆:BAAAKgAECgQIBAAAAA==.',['平静']='平静如水:BAAAKgAFFAQIBAAAAA==.',['并非']='并非小甲:BAABKgAFFH8iAAIIAAMI4h+2HwAGAQAIAAMI4h+2HwAGAQAAAA==.',['幻狱']='幻狱行者:BAAAKgAECggIEwAAAA==.',['开心']='开心的圣光:BAAAKgAECggICAAAAA==.',['强力']='强力三鞭丸:BAACKgAFFH8NAAMGAAMIxwtVOgCxAAAGAAMIxwtVOgCxAAAFAAEIpQETVwAlAAAqAAQKfyQAAwYACAj5EUtUALQBAAYACAj5EUtUALQBAAUAAgiADgd3AGIAAAAA.',['归头']='归头正弘丶:BAAAKgAECgEIAQAAAA==.',['彡清']='彡清风思明月:BAABKgAFFH8IAAIGAAgIog6QCgDFAQAGAAgIog6QCgDFAQAAAA==.',['德芙']='德芙:BAAAKgAECggICAAAAA==.',['德菜']='德菜兼备:BAAAKgAFFAMIAwAAAA==.',['德醉']='德醉:BAABKgAECn8fAAMZAAgIBhvLEgAvAgAZAAgIBhvLEgAvAgAaAAgI/hrUSACTAQABKgAFFAgICgAZAO0VAA==.',['心臟']='心臟:BAAAKgAECggICAAAAA==.',['怒疯']='怒疯:BAAAKgAFFAYIBAAAAA==.',['性并']='性并一针灵:BAAAKgADCgQIBAAAAA==.',['悟灬']='悟灬怪:BAAAKgAECgYIBgAAAA==.',['想要']='想要了是吧:BAAAKgAECgMIAwAAAA==.',['愛如']='愛如潮水:BAAAKgAECgQIBAAAAA==.',['懒猫']='懒猫猫:BAAAKgAECgIIAgAAAA==.',['我与']='我与天空比高:BAAAKgAECggICQAAAA==.',['我奶']='我奶来了:BAAAKgAECgQIBAAAAA==.',['我怕']='我怕猫:BAAAKgADCgUIBQAAAA==.',['我有']='我有小秘密:BAABKgAFFH8GAAILAAYIJwsWHAAmAQALAAYIJwsWHAAmAQAAAA==.',['战复']='战复三队防骑:BAABKgAFFH8hAAIaAAgIrST7AAD+AgAaAAgIrST7AAD+AgAAAA==.战复二队武僧:BAABKgAECn8jAAILAAgIeCNeBADFAgALAAgIeCNeBADFAgABKgAFFAgIDAALAMocAA==.战复五队神牧:BAAAKgAECggICAABKgAFFAgIIQAaAK0kAA==.战复六队火法:BAAAKgAECggICAABKgAFFAgIIQAaAK0kAA==.战复四队萨满:BAACKgAFFH8aAAIGAAYI8h7FCADeAQAGAAYI8h7FCADeAQAqAAQKfx0AAgYACAguJk0DAAkDAAYACAguJk0DAAkDAAEqAAUUCAghABoArSQA.',['战灬']='战灬歌:BAAAKgAFFAgIBAAAAA==.',['把酒']='把酒临风醉月:BAAAKgAECgMIAwAAAA==.',['报纸']='报纸壳壳:BAAAKgAECgQIBAAAAA==.',['拉撒']='拉撒路:BAAAKgAFFAQIBAAAAA==.',['拔丝']='拔丝麻花:BAABKgAFFH8JAAIBAAMIEAQMDwBtAAABAAMIEAQMDwBtAAAAAA==.',['指导']='指导员:BAACKgAFFH8OAAIRAAQINBeBIgC7AAARAAQINBeBIgC7AAAqAAQKfyEABBcACAhCEDI1AEkBABcABwjYETI1AEkBABEACAjbCDtEACgBABMABwh3ClQ5ACEBAAAA.',['指间']='指间的溫柔:BAABKgAFFH8SAAQXAAgIexOxAwDUAQAXAAgIexOxAwDUAQARAAQI9wZWFgACAQATAAIIaSK7EQDUAAAAAA==.指间的藝術:BAAAKgADCggICAAAAA==.',['挽星']='挽星:BAAAKgAECgMIAwAAAA==.',['挽歌']='挽歌永葬:BAAAKgAECggICAAAAA==.',['擎天']='擎天柱丶黑角:BAAAKgAECgcICQAAAA==.',['放肆']='放肆的张小妮:BAABKgAFFH8MAAMGAAQIYxLfMQDGAAAGAAQIYxLfMQDGAAAFAAQIaAfVOwCIAAAAAA==.',['散了']='散了吧不打了:BAAAKgAECgUIBQAAAA==.',['文哥']='文哥有点困:BAABKgAFFH8HAAIIAAMIKgfeHQCjAAAIAAMIKgfeHQCjAAAAAA==.',['斜刘']='斜刘海:BAAAKgAECgQIAgABKgAECgYICgAEAAAAAA==.',['斯坦']='斯坦利哈维:BAAAKgADCggICAAAAA==.',['施兀']='施兀术:BAAAKgAECgYIBgAAAA==.',['旋转']='旋转的狂想:BAAAKgAFFAMIAwAAAA==.',['无双']='无双小钢炮:BAAAKgAECgcIBwAAAA==.',['无名']='无名火:BAAAKgADCggIDgAAAA==.',['昆山']='昆山玉:BAAAKgAECggICAAAAA==.',['明月']='明月玉才:BAAAKgADCggICAAAAA==.',['易片']='易片冰心:BAAAKgAECgUIBQAAAA==.',['星星']='星星如画里:BAAAKgAECgUIBQAAAA==.',['星祈']='星祈术师:BAAAKgADCgQIBAAAAA==.',['春困']='春困秋乏:BAAAKgAECgMIAwAAAA==.',['晓仙']='晓仙:BAAAKgAECgMIAwAAAA==.',['晓月']='晓月夜:BAAAKgAECgUICQAAAA==.',['晚风']='晚风心里吹:BAACKgAFFH9kAAITAAgIRSYdAAAkAwATAAgIRSYdAAAkAwAqAAQKf1oAAhMACAjrJnoAACEDABMACAjrJnoAACEDAAAA.',['暗影']='暗影之韧:BAAAKgADCgEIAQAAAA==.',['最靓']='最靓的仔仔:BAAAKgADCgMIAwAAAA==.',['月之']='月之信仰:BAAAKgAECgYIBgAAAA==.',['月侠']='月侠魅影:BAABKgAFFH8JAAIGAAUIsx1QBQB5AQAGAAUIsx1QBQB5AQAAAA==.',['月卡']='月卡:BAAAKgAECgYIBgAAAA==.',['月舞']='月舞冰霜:BAABKgAFFH8GAAQfAAMI1g6bHACWAAAfAAMI1g6bHACWAAAQAAIIhQZfFABjAAAeAAEIZgxfDwBIAAAAAA==.',['木子']='木子鱼日眉:BAAAKgADCgMIAwAAAA==.',['李春']='李春生:BAABKgAFFH8HAAIUAAYIiQzOCQBJAQAUAAYIiQzOCQBJAQAAAA==.',['杨影']='杨影:BAABKgAFFH8VAAMOAAgI/xenFwCfAQAOAAYIzB+nFwCfAQAbAAgI+QiLCgBSAQAAAA==.',['极地']='极地肉企鹅:BAABKgAFFH8IAAMaAAgIXxaYDADNAQAaAAcInBSYDADNAQAZAAEI1xbpMgBMAAAAAA==.',['果冻']='果冻:BAAAKgAFFAQIBAAAAA==.',['果洛']='果洛蒙蒙:BAAAKgAECgQIBwAAAA==.',['枣哥']='枣哥强战:BAAAKgAECgYIDwAAAA==.',['枸杞']='枸杞小猫:BAAAKgAECgMIAwABKgAFFAgIDwAJABYaAA==.',['柏丶']='柏丶翘:BAAAKgAECggIDAAAAA==.',['柏翘']='柏翘:BAAAKgAFFAMIAwAAAA==.',['某盗']='某盗号:BAAAKgADCgEIAQAAAA==.',['桔烟']='桔烟:BAAAKgAECgcICgAAAA==.',['梅川']='梅川丨酷子:BAAAKgAECgYIBgAAAA==.',['梦中']='梦中的婚礼:BAABKgAFFH8FAAIcAAUIGxTiGgAOAQAcAAUIGxTiGgAOAQAAAA==.',['梦吥']='梦吥忧伤:BAABKgAFFH8GAAIWAAMIMgwnIwDGAAAWAAMIMgwnIwDGAAAAAA==.',['梦梦']='梦梦:BAAAKgAECgUIBQAAAA==.',['橘子']='橘子汽水丶:BAABKgAFFH8GAAIiAAYIehd4CQBzAQAiAAYIehd4CQBzAQAAAA==.',['橙心']='橙心丨橙意:BAACKgAFFH8GAAMJAAIIBwQNJwBdAAAJAAIIBwQNJwBdAAAUAAII6gNXIwBJAAAqAAQKfxgAAxQACAg8DBpAAA0BABQABwgcDRpAAA0BAAkABggpCFZiALUAAAAA.',['橙百']='橙百万:BAAAKgAECggIEwAAAA==.',['欧皇']='欧皇丶猎:BAAAKgAFFAgIAgAAAA==.',['正义']='正义无价:BAABKgAFFH8SAAMOAAgIoA5bJQBUAQAOAAYIUhBbJQBUAQAbAAgI2wa7CAAhAQAAAA==.',['此夜']='此夜:BAABKgAFFH8hAAIVAAgIvyKJBABnAgAVAAgIvyKJBABnAgAAAA==.',['步惊']='步惊雲:BAAAKgADCgIIAgAAAA==.',['武流']='武流风:BAAAKgAECgcIBwAAAA==.',['死猪']='死猪王子:BAABKgAFFH8IAAIOAAYIPhxBFgCpAQAOAAYIPhxBFgCpAQAAAA==.',['毛毛']='毛毛小狗:BAACKgAFFH8OAAQOAAQIPhZkMQCpAAAOAAMIrRZkMQCpAAAbAAQIGxSNGwCcAAASAAIIWQQ0GgBiAAAqAAQKfx4ABBsACAjGFHkbAIUBABsACAhaFHkbAIUBAA4ABAgJC3Y4AXQAABIAAQgzGI9PAEQAAAAA.毛毛虫:BAABKgAFFH8GAAIUAAMI8weIDwCjAAAUAAMI8weIDwCjAAAAAA==.',['水水']='水水睡不醒:BAAAKgAECgUIBQAAAA==.',['汐芮']='汐芮:BAAAKgAECgIIAgAAAA==.',['沈千']='沈千越:BAAAKgAFFAMIAwAAAA==.',['油笔']='油笔道子:BAAAKgADCgcICwAAAA==.',['法术']='法术胖猫:BAAAKgAECgMIBAAAAA==.',['法棍']='法棍乱天下:BAAAKgAECggIDQAAAA==.',['法神']='法神李正道:BAAAKgAECgEIAQAAAA==.',['泥头']='泥头车小分队:BAACKgAFFH8dAAIVAAYIMhPOEQBIAQAVAAYIMhPOEQBIAQAqAAQKfyEAAhUACAh2Gw8rAGQBABUACAh2Gw8rAGQBAAAA.泥头车撞大运:BAACKgAFFH8OAAMHAAYIMxYCAQD9AAAHAAMIXhICAQD9AAAFAAYIuxBtLgCzAAAqAAQKfyoAAwcACAgbJG8BAMgCAAcACAgbJG8BAMgCAAUAAQimJXaHAGsAAAAA.',['浓眉']='浓眉单眼皮:BAAAKgADCgEIAQAAAA==.浓眉大眼狐:BAAAKgAFFAQIBAAAAA==.',['海棠']='海棠花:BAAAKgAECgEIAQAAAA==.',['涅莫']='涅莫涅:BAAAKgAFFAQIBAAAAA==.',['涝秧']='涝秧的茄子:BAAAKgADCgcIBwAAAA==.',['涤烦']='涤烦子:BAABKgAFFH8GAAISAAYIoRo5BQCOAQASAAYIoRo5BQCOAQAAAA==.',['深淵']='深淵回響:BAABKgAECn8YAAICAAgIFh0qKQATAgACAAgIFh0qKQATAgABKgAFFAgIBgACAB0dAA==.',['深院']='深院锁清秋:BAABKgAFFH8HAAMZAAQIihyVFQD0AAAZAAQIihyVFQD0AAAaAAIIuCI1MgBVAAAAAA==.',['淼霖']='淼霖:BAAAKgAECgUIBQAAAA==.',['清一']='清一色一条龙:BAAAKgAECgYIEAAAAA==.',['清茶']='清茶:BAABKgAECn8XAAILAAgIgx5xFAAEAgALAAgIgx5xFAAEAgAAAA==.',['清风']='清风之影:BAAAKgAECggIDQABKgAECggIGgACAE4fAA==.',['温蒂']='温蒂:BAAAKgAECgQIBwAAAA==.',['滚地']='滚地龍:BAAAKgAECgQIBAAAAA==.',['漫天']='漫天飞羽:BAAAKgAECgMIAwAAAA==.',['漫漫']='漫漫苏:BAABKgAECn8wAAMXAAgIkx+VBAA9AgAXAAgIkx+VBAA9AgARAAII7A7IhQBUAAABKgAFFAgIDgARACAkAA==.',['潇洒']='潇洒骑:BAAAKgADCgEIAQAAAA==.',['灬吉']='灬吉吉小鱼灬:BAAAKgADCgEIAQABKgAECgYIBwAEAAAAAA==.',['灬小']='灬小耗子灬:BAABKgAFFH8GAAIRAAYIvx08CAClAQARAAYIvx08CAClAQAAAA==.',['灬角']='灬角落安静灬:BAAAKgAFFAEIAQAAAA==.',['炤煋']='炤煋:BAAAKgADCgEIAQAAAA==.',['点击']='点击头像:BAAAKgAFFAQIBAAAAA==.',['烟花']='烟花易冷:BAABKgAFFH8GAAILAAYItSOtCwDTAQALAAYItSOtCwDTAQAAAA==.',['無关']='無关風月:BAAAKgAECggIEAAAAA==.',['熊猫']='熊猫盼盼:BAAAKgADCgYIBgAAAA==.',['燃燈']='燃燈:BAAAKgAECgYIBgAAAA==.',['燕京']='燕京小法:BAAAKgAECgIIAgAAAA==.',['版本']='版本娘:BAAAKgAFFAQIBAAAAA==.',['牛大']='牛大痣:BAAAKgAECgYIBgAAAA==.',['牛德']='牛德华:BAAAKgADCgcIBwAAAA==.',['牧歌']='牧歌:BAAAKgAFFAQIBAAAAA==.',['狂想']='狂想的恶魔:BAAAKgAECgEIAQAAAA==.',['狗头']='狗头萝莉:BAAAKgAECggICwAAAA==.',['狗熊']='狗熊岭熊三:BAAAKgAECggIEAAAAA==.',['狼型']='狼型打桩机:BAAAKgAECgYIBgAAAA==.',['狼德']='狼德狠:BAAAKgAECgUIBQAAAA==.',['猫一']='猫一杯:BAAAKgAECggIEAAAAA==.',['猫扑']='猫扑的小圣骑:BAAAKgADCgQIBQABKgAFFAYIDQARAOAJAA==.猫扑的小螃蟹:BAACKgAFFH8NAAIRAAMI4An/LQCNAAARAAMI4An/LQCNAAAqAAQKf0QAAxEACAgGFL80AGwBABEACAgGFL80AGwBABMABwjkAvFPAG0AAAAA.',['猫本']='猫本帕克维尔:BAABKgAFFH8NAAIWAAUI5hRHDgACAQAWAAUI5hRHDgACAQAAAA==.',['猫车']='猫车:BAABKgAECn8ZAAMZAAgIpxy3FAD9AQAZAAgIpxy3FAD9AQAaAAEIYiFFvgBXAAAAAA==.',['珍妮']='珍妮玛黛劲丶:BAABKgAFFH8IAAINAAgIGRR/BwD8AQANAAgIGRR/BwD8AQAAAA==.',['琳琅']='琳琅丶:BAABKgAFFH8IAAIBAAgICw1xAwCjAQABAAgICw1xAwCjAQAAAA==.',['瑞秋']='瑞秋:BAABKgAFFH8NAAINAAgIASI6AwCCAgANAAgIASI6AwCCAgAAAA==.',['瑟拉']='瑟拉菲娜:BAAAKgADCgcIBwAAAA==.',['瓦立']='瓦立安:BAAAKgAECgEIAQAAAA==.',['白白']='白白:BAACKgAFFH8HAAIJAAUIpAqUCgAQAQAJAAUIpAqUCgAQAQAqAAQKfykAAgkACAg7IkQOAHgCAAkACAg7IkQOAHgCAAAA.',['白蓬']='白蓬蓬:BAAAKgADCgMIAwABKgAECgcIGAAJALkgAA==.',['百基']='百基拉:BAAAKgAFFAgIBAAAAA==.',['相见']='相见狠晚:BAABKgAFFH8GAAIWAAYILiMvCADYAQAWAAYILiMvCADYAQAAAA==.',['真瞎']='真瞎:BAAAKgAECgMIBQAAAA==.',['真香']='真香回锅肉:BAAAKgAECgMIAwAAAA==.',['眼看']='眼看喜:BAAAKgAECgUIBQAAAA==.',['瞎混']='瞎混归来:BAAAKgAECggICAAAAA==.瞎混歸來:BAAAKgAECgYIBgAAAA==.瞎混歸唻:BAAAKgAECgYICQAAAA==.瞎混歸来:BAAAKgAECgUIBQAAAA==.瞎混歸萊:BAAAKgAECgQICQAAAA==.瞎混禅师:BAAAKgAECgQICAAAAA==.',['矮法']='矮法也强:BAAAKgAECgMIAwAAAA==.',['破碎']='破碎之花:BAAAKgAECgMIBgAAAA==.',['确定']='确定武器:BAAAKgADCgEIAQAAAA==.',['碍事']='碍事梨:BAABKgAECn8iAAMjAAgIRBw8JQAWAgAjAAgIRBw8JQAWAgAdAAQICwiFgwCJAAAAAA==.',['磍婫']='磍婫歸唻:BAAAKgAECggIBAAAAA==.',['神之']='神之审判:BAABKgAFFH8OAAMbAAYIZhc5CwBEAQAbAAYInBM5CwBEAQAOAAQISg/UJgDXAAABKgAFFAgIEQAaAO8iAA==.神之斩杀:BAABKgAFFH8FAAIiAAUIkxYxCACJAQAiAAUIkxYxCACJAQAAAA==.神之风行:BAAAKgAECgYIBgAAAA==.',['神圣']='神圣风暴:BAAAKgAECgYIDAAAAA==.',['秋夜']='秋夜丶:BAAAKgAECgEIAQAAAA==.',['稻五']='稻五米:BAABKgAFFH8MAAICAAYI/g+AGQBRAQACAAYI/g+AGQBRAQAAAA==.',['穆恩']='穆恩:BAABKgAFFH8IAAIDAAgIMRzkAQBYAgADAAgIMRzkAQBYAgAAAA==.',['穆色']='穆色:BAAAKgAECgMIAwAAAA==.',['笑看']='笑看魔界:BAAAKgAECgcIDAAAAA==.',['第十']='第十三:BAAAKgAECgcICAAAAA==.',['简易']='简易:BAABKgAFFH8hAAIGAAUI0BlCDwAzAQAGAAUI0BlCDwAzAQAAAA==.',['粘豆']='粘豆包:BAAAKgAFFAEIAQAAAA==.',['精灵']='精灵守护:BAAAKgADCggICAAAAA==.',['糖炒']='糖炒小栗子:BAABKgAFFH8KAAILAAYIDAmfHgATAQALAAYIDAmfHgATAQAAAA==.',['索丽']='索丽娜:BAAAKgADCgcIBwAAAA==.',['終極']='終極炫舞:BAAAKgAECggIEAAAAA==.',['絶地']='絶地武士:BAAAKgADCgUIBQAAAA==.',['红箭']='红箭女侠:BAABKgAFFH8MAAIFAAgIPRRzBgDtAQAFAAgIPRRzBgDtAQAAAA==.',['红色']='红色跑车:BAABKgAFFH8MAAIFAAgIjx3uAgB6AgAFAAgIjx3uAgB6AgAAAA==.',['约克']='约克十二世:BAAAKgAECgMIAwAAAA==.约克十五世:BAAAKgADCgMIAwABKgAECgMIAwAEAAAAAA==.约克十四世:BAAAKgAECgEIAQABKgAECgMIAwAEAAAAAA==.',['绘月']='绘月:BAAAKgAFFAIIAgAAAA==.',['绝界']='绝界行:BAAAKgAECggICAAAAA==.',['罗小']='罗小嘿:BAAAKgADCgcICQAAAA==.罗小黑:BAAAKgAFFAYIBAAAAA==.',['罚克']='罚克:BAAAKgAFFAQIBAAAAA==.',['羊咩']='羊咩咩丶:BAABKgAFFH8OAAMFAAUIZSEZAwBHAQAFAAUIZSEZAwBHAQAGAAMIIgzGIwDHAAAAAA==.',['老弓']='老弓豪艇:BAAAKgAECgUIBQAAAA==.',['老牛']='老牛:BAAAKgAECgUICQAAAA==.',['联盟']='联盟的律师:BAAAKgADCggIDAAAAA==.',['聖砡']='聖砡小轩:BAABKgAFFH8HAAMXAAYIbAdZDwCLAAAXAAQIswhZDwCLAAARAAIIgQWZMQB/AAAAAA==.',['色羽']='色羽:BAACKgAFFH8FAAIfAAMI1xt9DAD3AAAfAAMI1xt9DAD3AAAqAAQKfxUAAh8ACAh8HZoeAB4CAB8ACAh8HZoeAB4CAAEqAAUUCAghABUAvyIA.',['艾路']='艾路摁:BAAAKgAECgQIBAAAAA==.',['芙兰']='芙兰朵:BAAAKgAECggIEAAAAA==.',['茉莉']='茉莉二号:BAAAKgAFFAgIAgAAAA==.',['莫烦']='莫烦欧子:BAAAKgAECgQIBAAAAA==.',['莱茵']='莱茵多特:BAABKgAFFH8MAAIOAAYI9R0tFAC6AQAOAAYI9R0tFAC6AQAAAA==.',['莱雅']='莱雅娜丶:BAABKgAFFH8MAAIaAAYIxh4CDQDGAQAaAAYIxh4CDQDGAQAAAA==.',['莽壮']='莽壮人:BAAAKgADCgIIAgAAAA==.',['萬事']='萬事顺心鸭:BAACKgAFFH8NAAMdAAUIaRz4AwAWAQAjAAUI/xkmEgAwAQAdAAQIbh74AwAWAQAqAAQKfxYAAh0ACAg+JqkPAIQCAB0ACAg+JqkPAIQCAAAA.',['蒂法']='蒂法洛克哈特:BAABKgAFFH8QAAMdAAQICx5gCADpAAAdAAQIbB1gCADpAAAcAAQIRhMcAwC+AAAAAA==.',['蓝月']='蓝月亮:BAAAKgAECgUIBAAAAA==.',['蘋果']='蘋果果:BAAAKgAECggICAAAAA==.',['虎斑']='虎斑大人:BAAAKgAECgQIBAAAAA==.',['虫博']='虫博士:BAABKgAFFH8QAAMXAAUIdxRiEwD9AAAXAAUInBFiEwD9AAARAAEIkxnPIgBEAAABKgAFFAgIIQAVAL8iAA==.',['蚩尤']='蚩尤:BAAAKgAECgMIAwAAAA==.',['西域']='西域老马拉面:BAAAKgAFFAEIAQAAAA==.',['语嫣']='语嫣:BAABKgAFFH8GAAIOAAMInQ3LKADEAAAOAAMInQ3LKADEAAAAAA==.',['请享']='请享用我:BAAAKgAECggICAAAAA==.',['谁言']='谁言春物荣:BAAAKgAECgEIAQAAAA==.',['贪吃']='贪吃喵儿:BAABKgAFFH8KAAIJAAYIohGMDABdAQAJAAYIohGMDABdAQAAAA==.',['贫果']='贫果果:BAABKgAFFH8IAAMXAAQIigdhIwCWAAAXAAQIhQdhIwCWAAARAAQInQR4MQCAAAAAAA==.',['贱男']='贱男春:BAAAKgAECgUIBQAAAA==.',['费费']='费费:BAAAKgADCggICAAAAA==.',['贼星']='贼星高照:BAAAKgAFFAIIBAAAAA==.',['赛默']='赛默飞世尔:BAAAKgAECgUIBQAAAA==.',['越看']='越看越稀罕:BAAAKgAECgIIAwAAAA==.',['跟你']='跟你丫死磕:BAAAKgADCgYIBgAAAA==.',['跪下']='跪下叫爸爸:BAAAKgADCggICAAAAA==.',['躺尸']='躺尸战:BAAAKgAECggICAAAAA==.',['过电']='过电:BAAAKgAFFAIIBAAAAA==.',['远古']='远古大茄子:BAAAKgAFFAYIAgAAAA==.',['迷之']='迷之微笑:BAABKgAFFH8GAAIBAAYIfRWoBwAlAQABAAYIfRWoBwAlAQABKgAFFAgIEgAIAJgVAA==.',['迷夜']='迷夜:BAAAKgAECgQIBAAAAA==.',['追灬']='追灬忆:BAAAKgAFFAMIAwAAAA==.',['逆光']='逆光:BAAAKgAFFAQIBAAAAA==.',['遗忘']='遗忘的思念:BAAAKgADCgYIBgAAAA==.',['邪能']='邪能噬者:BAAAKgAECggICAAAAA==.',['郁闷']='郁闷的熊熊:BAAAKgAECgIIAgAAAA==.',['郑晓']='郑晓泰小正太:BAABKgAFFH8MAAIaAAYIdwFiSACPAAAaAAYIdwFiSACPAAAAAA==.',['酒笙']='酒笙清栀:BAAAKgADCgMIAwABKgAFFAgIDQAIAIcmAA==.',['酸奶']='酸奶麻花:BAAAKgAECgMIAwAAAA==.',['野德']='野德:BAABKgAFFH8IAAIOAAgI7BGpCQAOAgAOAAgI7BGpCQAOAgAAAA==.',['野结']='野结衣:BAAAKgADCgMIAwAAAA==.',['野蛮']='野蛮孩子:BAAAKgAECgcIDwAAAA==.',['钢弹']='钢弹姆:BAABKgAFFH8NAAMfAAYINByJDgBoAQAfAAYINByJDgBoAQAQAAEIlQ6BGgBEAAABKgAFFAgIDwAeAC4bAA==.',['铁柱']='铁柱儿:BAAAKgADCggICAAAAA==.',['铭铭']='铭铭:BAAAKgAECgQIBgAAAA==.',['银色']='银色叶琳娜:BAAAKgAECgIIAgAAAA==.',['长河']='长河落日圆:BAABKgAFFH8GAAMCAAQI/AaMQACcAAACAAQI/AaMQACcAAADAAIIDwQ8IgBNAAABKgAFFAgIAgAEAAAAAA==.',['閃光']='閃光少女:BAAAKgAECgUIBgAAAA==.',['阿克']='阿克的眼泪:BAACKgAFFH8XAAQLAAQIoBauFQDYAAALAAMIZhauFQDYAAAMAAMI0Q1nKABIAAAKAAIIDQx/HQBIAAAqAAQKfzAABAsACAizIgYdABQCAAsACAg+HwYdABQCAAwACAjeHQAZALkBAAoAAwhJGMklAMoAAAAA.',['阿法']='阿法:BAAAKgAFFAQIBAAAAA==.',['阿盐']='阿盐有点咸:BAAAKgADCgMIAwAAAA==.',['阿萨']='阿萨:BAAAKgAECgMIAwAAAA==.',['雅典']='雅典学堂老饕:BAAAKgAECggIDwAAAA==.',['雨路']='雨路酒鬼:BAAAKgAFFAgIAgAAAA==.',['雪无']='雪无双:BAAAKgAECgEIAgAAAA==.',['雪舞']='雪舞双:BAAAKgAECggICQAAAA==.',['雷神']='雷神丨托尔:BAAAKgAFFAEIAQAAAA==.',['雷霆']='雷霆与烈焰:BAACKgAFFH8FAAIfAAMIugt3NgCkAAAfAAMIugt3NgCkAAAqAAQKfyYABB4ACAgeEWQoAIIBAB4ACAgeEWQoAIIBAB8ACAhYFWhPAD8BABAAAwjLB1lzAF8AAAAA.',['霜疫']='霜疫:BAAAKgADCgYIBgAAAA==.',['露娜']='露娜:BAAAKgADCggICAAAAA==.',['霸道']='霸道女总裁:BAAAKgAECgQIBAAAAA==.',['靓仔']='靓仔德:BAACKgAFFH8UAAQaAAQIjRSeLwDVAAAaAAQImBOeLwDVAAAZAAIIDSDkHQC3AAAhAAEI3BeeCABTAAAqAAQKfxQABBoACAgmHMwjACsCABoACAgmHMwjACsCABkAAQh6A7aEABgAACAAAQiNBjRGAA4AAAAA.靓仔拳王:BAAAKgAECggIDgAAAA==.',['靓昆']='靓昆:BAAAKgAECgMIAwAAAA==.',['靓锟']='靓锟:BAABKgAFFH8FAAQMAAIILBD5GQCBAAAMAAIILBD5GQCBAAAKAAIINgNUHQBYAAALAAEIIw+aTwA0AAAAAA==.',['靓鲲']='靓鲲:BAAAKgADCggIEgAAAA==.',['面如']='面如雪上孀:BAAAKgAECgYIEQAAAA==.',['顶天']='顶天立地:BAABKgAFFH8OAAMFAAMIPwvrNQCcAAAFAAMIcwrrNQCcAAAGAAIIrQmaJgB1AAAAAA==.',['风动']='风动忆流年:BAAAKgAECgcICgAAAA==.',['风暴']='风暴之灵:BAABKgAFFH8FAAIfAAMI3Al7OQCdAAAfAAMI3Al7OQCdAAAAAA==.',['风来']='风来雨就来:BAABKgAFFH8GAAIeAAYIug9UCgArAQAeAAYIug9UCgArAQAAAA==.',['风行']='风行者:BAACKgAFFH8KAAIfAAIInAXSLgBVAAAfAAIInAXSLgBVAAAqAAQKfxUAAh8ABwgqFXhQADsBAB8ABwgqFXhQADsBAAAA.',['首席']='首席邪能丨师:BAAAKgAECgQIBAAAAA==.',['马富']='马富贵:BAAAKgAECgUICAAAAA==.',['高手']='高手:BAAAKgADCggICAAAAA==.',['魂戒']='魂戒:BAAAKgAECgQIBAAAAA==.魂戒龙:BAAAKgAECgMIAwAAAA==.',['鸭鸭']='鸭鸭惊:BAAAKgAECgcICgAAAA==.',['麻小']='麻小:BAAAKgAECgYICgAAAA==.',['黄昏']='黄昏:BAAAKgAECgcIBwAAAA==.黄昏阴影:BAAAKgAECgIIAgAAAA==.',['黑暗']='黑暗阴影丶煞:BAAAKgAECgQIBQAAAA==.',['黑龙']='黑龙凯尔特:BAABKgAFFH8GAAMZAAYIzQZdHADAAAAZAAUIFAddHADAAAAaAAEI0wGHYQA0AAABKgAFFAgIBAAEAAAAAA==.黑龙雨润春山:BAAAKgAFFAgIAgAAAA==.',['龍女']='龍女:BAABKgAFFH8FAAIVAAMIRAF5HgBSAAAVAAMIRAF5HgBSAAAAAA==.',['龙丨']='龙丨神:BAABKgAECn8dAAIWAAgIGBUyJgD2AQAWAAgIGBUyJgD2AQAAAA==.',['龙城']='龙城猎手:BAABKgAFFH8IAAMIAAYI3AhCEAAyAQAIAAYI3AhCEAAyAQABAAIIYAAMJgAxAAAAAA==.',['龙神']='龙神:BAAAKgAFFAEIAQAAAA==.',['龙霜']='龙霜:BAABKgAECn8ZAAIdAAgIESCwFQBSAgAdAAgIESCwFQBSAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end