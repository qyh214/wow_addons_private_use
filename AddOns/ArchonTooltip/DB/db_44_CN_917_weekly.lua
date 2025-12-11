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
 local lookup = {'Hunter-BeastMastery','Mage-Arcane','Mage-Frost','Hunter-Marksmanship','Druid-Balance','Monk-Brewmaster','Priest-Holy','DeathKnight-Frost','DemonHunter-Havoc','Warlock-Destruction','Warlock-Demonology','Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','Druid-Feral','Druid-Restoration','Druid-Guardian','DeathKnight-Unholy','Paladin-Protection','DemonHunter-Vengeance','Evoker-Devastation','Warrior-Fury','Warrior-Protection','Unknown-Unknown',}; local provider = {region='CN',realm='天谴之门',name='CN',type='weekly',zone=44,date='2025-12-07',data={An='Anon:BAACLAAFFH8bAAIBAAYIIx4jJQCgAQABAAYIIx4jJQCgAQAsAAQKfyoAAgEABgi2I6hPAD8CAAEABgi2I6hPAD8CAAAA.',Ap='Apex:BAAALAADCgIIAgAAAA==.',Co='Confetti:BAAALAAECgYIDAAAAA==.',Da='Dantyan:BAACLAAFFH9DAAMCAAcIYCXdBgB9AgACAAcIYCXdBgB9AgADAAIIUhZCEgCKAAAsAAQKfyAAAwMACAivJPcTAH8CAAMABwgmJvcTAH8CAAIACAhqIXYdAMABAAAA.',Do='Donk:BAABLAAECn8ZAAMEAAYIsCGCJwA2AgAEAAYIqyGCJwA2AgABAAYIDh4aUQCjAQABLAAFFAcILwAFAGsjAA==.',Dr='Drakeeins:BAAALAAFFAgIBAAAAA==.Drakefear:BAABLAAFFH8GAAIGAAYIqBZaDgBkAQAGAAYIqBZaDgBkAQAAAA==.Drakezwei:BAAALAAFFAYIAQAAAA==.',En='Entreri:BAAALAAECgMIAwAAAA==.',Ha='Hala:BAAALAAECgYIEQAAAA==.',Hc='Hcy:BAAALAADCgEIAQAAAA==.',Hu='Hushup:BAAALAADCgYIBgAAAA==.',Ki='Kissgrape:BAAALAAECgYIEAAAAA==.',Lu='Lucawsj:BAABLAAFFH8IAAIHAAgIeA+GDAAGAgAHAAgIeA+GDAAGAgAAAA==.',Ny='Nyoumi:BAAALAAECggIDAAAAA==.',Pc='Pcb:BAAALAADCgEIAQAAAA==.',Re='Redlai:BAABLAAFFH8KAAIIAAIIew1SggBFAAAIAAIIew1SggBFAAAAAA==.',Ro='Romanticmake:BAAALAAECgMIAwAAAA==.',Sa='Sarena:BAAALAAECgUIBQAAAA==.',St='Staynight:BAAALAAECgUIBQAAAA==.',Un='Uncle:BAAALAAFFAIIBAAAAA==.',Zz='Zzmabaka:BAAALAAFFAIIAgAAAA==.',['一切']='一切的幻梦:BAAALAAECgIIAgABLAAFFAcIIwAJAHUYAA==.',['一只']='一只土灵:BAAALAAFFAIIAgAAAA==.',['一条']='一条小锦李丶:BAAALAADCggICAAAAA==.',['七宗']='七宗:BAAALAADCgYIBgAAAA==.',['三本']='三本粉碎小炮:BAAALAADCgMIBAAAAA==.',['不吃']='不吃韭菜:BAAALAAFFAIIAwAAAA==.',['不在']='不在留恋:BAACLAAFFH8RAAMKAAUI5Q5OOwAdAQAKAAUI5Q5OOwAdAQALAAEIjwUPLwBFAAAsAAQKfxgAAwoABwhkHKk7AEsCAAoABwhkHKk7AEsCAAsABQh8E+dRAC0BAAAA.',['不要']='不要说谎:BAAALAAECgYICgAAAA==.',['丘巴']='丘巴:BAAALAAECggICAAAAA==.',['业浮']='业浮生:BAACLAAFFH8RAAIIAAMIExMTVACeAAAIAAMIExMTVACeAAAsAAQKfxQAAggACAivGOlcADwCAAgACAivGOlcADwCAAAA.',['丛林']='丛林追迹者:BAACLAAFFH8KAAIBAAUI9R1qMQB2AQABAAUI9R1qMQB2AQAsAAQKfyEAAwEABgjgI+AzAPEBAAEABgjgI+AzAPEBAAQABgilA5uPAKkAAAAA.',['丢丶']='丢丶小贼:BAAALAADCgYIBgAAAA==.',['为爱']='为爱发电:BAAALAAECgcICwAAAA==.',['举杯']='举杯痛饮:BAAALAADCgMIAwAAAA==.',['乀九']='乀九月丶:BAAALAADCgUIBQAAAA==.',['乄战']='乄战丶天下灬:BAAALAADCgQIBAAAAA==.',['乾坤']='乾坤一掷:BAAALAAECgUIBwAAAA==.',['二头']='二头肌:BAAALAAECgQICAAAAA==.',['亚历']='亚历莫格莱尼:BAAALAAECgYIBgAAAA==.',['亚瑟']='亚瑟克莱纳:BAAALAAECgIIAgAAAA==.',['亦丶']='亦丶利丹:BAAALAAECgMIAwAAAA==.',['仁自']='仁自拖:BAAALAAECgYICAAAAA==.',['伊德']='伊德莉拉:BAAALAADCgYIBgAAAA==.',['伊普']='伊普利斯:BAAALAAECgYIBgAAAA==.',['伊蕾']='伊蕾丹丶怒风:BAAALAADCgYICQAAAA==.',['伤心']='伤心丯葫芦娃:BAAALAAECgIIAgAAAA==.',['你好']='你好两小情人:BAAALAAECgYIBgAAAA==.',['倾月']='倾月:BAAALAAFFAIIBAAAAA==.',['傻傻']='傻傻南瓜:BAAALAAECgYIBgAAAA==.',['充满']='充满强度的萨:BAACLAAFFH8KAAMMAAII4xLpRgB2AAAMAAII4xLpRgB2AAANAAEITASdWAAAAAAsAAQKfxgAAw0ABggMI10UAAsCAA0ABggMI10UAAsCAAwABgggGRqgAD4BAAAA.',['光头']='光头圣骑:BAABLAAECn8WAAIOAAgIlR4iMgCpAgAOAAgIlR4iMgCpAgAAAA==.',['六哥']='六哥吉祥:BAAALAAECgYIBgAAAA==.',['刘主']='刘主任:BAAALAAECgUIBQAAAA==.',['刚刚']='刚刚没忍住:BAACLAAFFH8vAAQFAAcIayOSBABAAgAFAAcIayOSBABAAgAPAAQIZCGkAwCSAQAQAAQIoA6RHACwAAAsAAQKfygABQ8ABwh0IvkNAG4CAA8ABwhaH/kNAG4CABAABgiVHfA4APwBAAUABQg8JKcdAIMBABEAAggqIusYAMQAAAAA.',['北以']='北以木:BAAALAAFFAIIAgAAAA==.',['南南']='南南瓜:BAAALAADCggIDgAAAA==.',['可以']='可以:BAAALAAECgIIAgAAAA==.',['可口']='可口完胜百事:BAAALAAECgEIAQAAAA==.',['合波']='合波合波:BAAALAAFFAMIAwAAAA==.',['君子']='君子有三德:BAAALAAECgYIBgAAAA==.',['吾殇']='吾殇斩:BAAALAAECgYICgAAAA==.',['吾游']='吾游侠:BAAALAAECgYICAAAAA==.',['吾猎']='吾猎手:BAAALAAECgEIAQAAAA==.',['吾玄']='吾玄冰:BAAALAAFFAIIAgAAAA==.',['和尚']='和尚爱吃鸡腿:BAAALAAECgMIAwAAAA==.',['哈基']='哈基魔:BAAALAAECgcICgAAAA==.',['啾啾']='啾啾:BAAALAADCgYIBQAAAA==.',['四法']='四法清云:BAAALAAFFAIIBAAAAA==.',['土木']='土木汪在恋爱:BAABLAAFFH8GAAIHAAIImwd2QAB1AAAHAAIImwd2QAB1AAAAAA==.',['土狗']='土狗:BAACLAAFFH8IAAMIAAIIEBzRQwCtAAAIAAIIEBzRQwCtAAASAAEIZRNkIABAAAAsAAQKfx8AAwgABwgVIHc8AIsCAAgABwgVIHc8AIsCABIABghoFeIqAGsBAAAA.',['圣埼']='圣埼士:BAABLAAECn8VAAITAAYIcQjaLQCzAAATAAYIcQjaLQCzAAAAAA==.',['地火']='地火流荧:BAAALAAECgcIBwAAAA==.',['大牛']='大牛骑士:BAABLAAFFH8GAAIOAAYIGBF+IQBiAQAOAAYIGBF+IQBiAQABLAAFFAgICgAOAKIaAA==.',['大蛋']='大蛋子:BAAALAAFFAIIAwAAAA==.',['大非']='大非常大:BAAALAAFFAIIAgAAAA==.',['大风']='大风歌:BAAALAAECgEIAQAAAA==.',['天上']='天上雀儿飞:BAAALAAECgEIAQAAAA==.',['头晕']='头晕是正常的:BAAALAAECgcICAAAAA==.',['契机']='契机零:BAAALAAECgEIAQAAAA==.',['奶奶']='奶奶桑麻:BAABLAAFFH8GAAIIAAMIQA4tMQDXAAAIAAMIQA4tMQDXAAAAAA==.奶奶都会奶德:BAAALAAECgcIBwAAAA==.',['好玩']='好玩的爆炸糖:BAAALAADCgEIAQAAAA==.好玩的跳跳糖:BAAALAAECgEIAQAAAA==.',['安格']='安格丶莉丝塔:BAAALAAFFAIIAgAAAA==.安格丶莉思塔:BAAALAADCgYIBgAAAA==.安格丶莉斯塔:BAAALAAECgUICAAAAA==.',['小丶']='小丶葡萄:BAAALAAECgYIDAAAAA==.',['小鱼']='小鱼灬小德:BAAALAAECgMIAwAAAA==.小鱼灬战神:BAAALAAECgMIAwAAAA==.',['就说']='就说没毛病:BAAALAADCgEIAQAAAA==.',['屋大']='屋大维首:BAAALAAECgYICwAAAA==.',['巨饼']='巨饼:BAABLAAFFH8GAAIOAAYIiRDCHwBtAQAOAAYIiRDCHwBtAQAAAA==.',['布衣']='布衣:BAAALAADCgMIAwAAAA==.',['帅不']='帅不帅:BAAALAAFFAEIAQAAAA==.',['希望']='希望:BAABLAAFFH8PAAIMAAYITSFdCABAAgAMAAYITSFdCABAAgAAAA==.',['常吃']='常吃非洛地平:BAAALAAFFAIIAgAAAA==.',['开始']='开始摆烂:BAAALAAECgYICQAAAA==.开始摆烂啦:BAAALAAECgUIBQAAAA==.',['彡罪']='彡罪歌:BAAALAAECgYIBgAAAA==.',['影丨']='影丨月色:BAAALAADCgUIBQAAAA==.',['往事']='往事已如煙:BAACLAAFFH8VAAIOAAUIUxcdKgAxAQAOAAUIUxcdKgAxAQAsAAQKfxQAAg4ACAgNGoF+AO4BAA4ACAgNGoF+AO4BAAEsAAUUBwgjAAkAdRgA.',['忆秋']='忆秋年:BAAALAAECgYIEwAAAA==.',['忉忉']='忉忉哉:BAABLAAFFH8VAAIJAAYIph8NEADiAQAJAAYIph8NEADiAQAAAA==.',['怜月']='怜月:BAACLAAFFH8jAAIJAAcIdRjoDgDtAQAJAAcIdRjoDgDtAQAsAAQKfxkAAgkACAhAHDRNADoCAAkACAhAHDRNADoCAAAA.',['恋月']='恋月:BAABLAAFFH8WAAMDAAUIkw4LDwCTAAACAAUIQg2rOAANAQADAAII+xoLDwCTAAABLAAFFAcIIwAJAHUYAA==.',['恋語']='恋語:BAAALAAFFAIIAwABLAAFFAcIIwAJAHUYAA==.',['恋语']='恋语:BAABLAAFFH8fAAMKAAYISBWPKAB5AQAKAAYI7hOPKAB5AQALAAIImBOkFACbAAABLAAFFAcIIwAJAHUYAA==.',['恶魔']='恶魔借手:BAACLAAFFH8tAAIUAAUIER/RBABZAQAUAAUIER/RBABZAQAsAAQKfywAAhQABwheHwoQAGMCABQABwheHwoQAGMCAAAA.',['意改']='意改:BAAALAAECgIIAgAAAA==.',['愤怒']='愤怒的母蟑螂:BAABLAAFFH8OAAMSAAUIkxUQBQBRAQASAAUIkxUQBQBRAQAIAAIIsAYhowAzAAAAAA==.',['慌的']='慌的呀匹:BAAALAADCgEIAQAAAA==.',['慷慨']='慷慨悲歌:BAAALAAFFAEIAQAAAA==.',['我将']='我将带头冲锋:BAABLAAFFH8RAAIIAAMIDh/pIwAMAQAIAAMIDh/pIwAMAQAAAA==.',['我死']='我死没:BAAALAADCgcIBwAAAA==.',['我真']='我真的是胖子:BAAALAAECgYIDAAAAA==.我真该死:BAABLAAFFH8GAAIIAAYIPwDNrAALAAAIAAYIPwDNrAALAAAAAA==.',['我跌']='我跌:BAAALAAFFAMIAwAAAA==.',['打你']='打你妹:BAAALAADCggICwAAAA==.',['打枪']='打枪的不要:BAAALAADCgYIBgAAAA==.',['抢地']='抢地盘奶妈:BAAALAAECgYIEwAAAA==.',['挑灯']='挑灯:BAABLAAFFH8JAAIJAAIIqgb2WwB8AAAJAAIIqgb2WwB8AAAAAA==.',['挤挤']='挤挤爆:BAAALAADCgYIBgAAAA==.',['捏麻']='捏麻麻滴:BAAALAAFFAIIAgABLAAFFAcILwAFAGsjAA==.',['昂科']='昂科威哥:BAAALAAECgYIEQAAAA==.',['易衍']='易衍:BAABLAAECn8ZAAIVAAcIxg1GOQBrAQAVAAcIxg1GOQBrAQAAAA==.',['星河']='星河:BAAALAAFFAIIBAAAAA==.',['晚风']='晚风漫漫:BAAALAAECgYIBgAAAA==.',['晨曦']='晨曦战天殇:BAAALAAECgYIBgAAAA==.',['暗夜']='暗夜的宠儿:BAABLAAFFH8SAAIPAAMI4RxLCQChAAAPAAMI4RxLCQChAAABLAAFFAcIIwAJAHUYAA==.',['暧昧']='暧昧的喵咪:BAAALAAECgYIEAAAAA==.暧昧的喵喵:BAAALAAECgYICAAAAA==.暧昧的小喵:BAAALAAECgIIAgAAAA==.暧昧的猫猫:BAAALAAECgYIBgAAAA==.暧昧的迪凯:BAAALAADCgMIAwAAAA==.',['曳小']='曳小木:BAABLAAFFH8GAAILAAYIZQB9GgAgAAALAAYIZQB9GgAgAAAAAA==.',['月夜']='月夜泣魂:BAABLAAFFH8QAAMBAAUIkQunWADtAAABAAUIkQunWADtAAAEAAEI+wM+OQAyAAAAAA==.',['有种']='有种驱散我啊:BAABLAAFFH8GAAIOAAYI4gIZOQC+AAAOAAYI4gIZOQC+AAAAAA==.',['未曾']='未曾离开:BAAALAAECgcICgAAAA==.',['杰哥']='杰哥丶:BAABLAAFFH8KAAIIAAYIjBdGOADBAAAIAAYIjBdGOADBAAAAAA==.杰哥防战:BAABLAAFFH8FAAIWAAUIEgfxLAD6AAAWAAUIEgfxLAD6AAABLAAFFAYICgAIAIwXAA==.',['染指']='染指灬戏红颜:BAAALAAECgEIAQAAAA==.',['桂花']='桂花糕:BAABLAAFFH8GAAIMAAII8hX/QgB8AAAMAAII8hX/QgB8AAAAAA==.',['森海']='森海飞霞:BAAALAAFFAIIAgAAAA==.',['死亡']='死亡之雾:BAABLAAFFH8GAAIIAAII/BGXXgCZAAAIAAII/BGXXgCZAAAAAA==.',['殊不']='殊不知:BAABLAAFFH8GAAIQAAYIJQAmYwAHAAAQAAYIJQAmYwAHAAAAAA==.',['毁灭']='毁灭法:BAAALAAFFAYIBAAAAA==.',['毒我']='毒我喜欢:BAAALAAECggICAAAAA==.',['水晶']='水晶丶枫叶:BAAALAAECgQIBAAAAA==.',['江湖']='江湖游医丷:BAAALAADCgQIBAAAAA==.',['沉没']='沉没之鱼:BAAALAAECgYICQAAAA==.',['法涅']='法涅斯:BAAALAAECgYIDQAAAA==.',['流萤']='流萤最可爱:BAAALAAECgcIBwAAAA==.',['浪漫']='浪漫丶辉辉:BAAALAAECgYIEwAAAA==.',['淦天']='淦天雷:BAAALAAECgYICAAAAA==.',['清風']='清風细语:BAAALAAECggICAAAAA==.',['清风']='清风:BAABLAAFFH8QAAIHAAYIvyO6BQB0AgAHAAYIvyO6BQB0AgAAAA==.清风细语:BAABLAAFFH8GAAIHAAYIHBs0EADeAQAHAAYIHBs0EADeAQAAAA==.',['满目']='满目星河:BAAALAAECgMIAwAAAA==.',['漂亮']='漂亮的萌兔兔:BAAALAAFFAIIAwABLAAFFAYIFwAJAIkfAA==.',['灟霐']='灟霐:BAAALAAECgQIBwAAAA==.',['火锅']='火锅真香:BAAALAAECgYICQAAAA==.',['灬小']='灬小趴菜:BAAALAAECgcIBwAAAA==.',['灵食']='灵食灵:BAAALAAECgQIBwAAAA==.',['炘丶']='炘丶:BAAALAAECgIIAgAAAA==.',['点点']='点点妹:BAAALAAECgQICQAAAA==.',['爆炒']='爆炒豆腐粉:BAAALAAECgQIBAAAAA==.',['爆燃']='爆燃:BAABLAAFFH8KAAMNAAYInQ6oHQBWAQANAAYInQ6oHQBWAQAMAAIIPAOYdABEAAAAAA==.',['爲爱']='爲爱痴狂:BAAALAAECgYIBgAAAA==.',['狗煎']='狗煎真红:BAABLAAFFH8GAAIBAAQImx+CVAAAAQABAAQImx+CVAAAAQAAAA==.',['狩猎']='狩猎者:BAAALAADCgEIAQAAAA==.',['猎维']='猎维度:BAAALAAECgYICgAAAA==.',['玩世']='玩世不恭:BAABLAAFFH8LAAIIAAUI1xweMgDUAAAIAAUI1xweMgDUAAAAAA==.',['男猪']='男猪脚:BAABLAAFFH8NAAIDAAIIDRrbCwCkAAADAAIIDRrbCwCkAAAAAA==.',['疯一']='疯一样的男纸:BAAALAAECgUIBgAAAA==.',['白也']='白也真无敌:BAABLAAECn8XAAIOAAYIsBmMYABFAQAOAAYIsBmMYABFAQAAAA==.',['白发']='白发苍苍:BAAALAAECgYICAAAAA==.',['白草']='白草净华:BAAALAAECggICAAAAA==.',['白银']='白银乄凤凰:BAAALAAECgIIAgAAAA==.',['矮壮']='矮壮电疗师:BAABLAAFFH8fAAINAAYIoyBhDADpAQANAAYIoyBhDADpAQAAAA==.',['福禄']='福禄娃李槐:BAAALAAECgUIBQAAAA==.',['离孤']='离孤:BAAALAAECgIIAgAAAA==.',['穿肠']='穿肠毒:BAABLAAFFH8ZAAIJAAYIyhA1JABsAQAJAAYIyhA1JABsAQAAAA==.',['第三']='第三小非:BAAALAAFFAIIAgAAAA==.',['箐谷']='箐谷:BAAALAAECgYICQAAAA==.',['米哥']='米哥威武:BAABLAAFFH8GAAIEAAIIlA2xGAA3AAAEAAIIlA2xGAA3AAAAAA==.米哥真帅:BAAALAAECgEIAQAAAA==.',['米娜']='米娜艾莉丝:BAAALAAECgIIAgAAAA==.',['粉粉']='粉粉的多可爱:BAAALAAECgQIBAAAAA==.',['组我']='组我一把过:BAAALAAFFAIIAgAAAA==.',['细语']='细语:BAABLAAFFH8IAAIHAAYIoRYXFAC4AQAHAAYIoRYXFAC4AQAAAA==.',['终点']='终点站陌路人:BAAALAAECgMIAwAAAA==.',['绿了']='绿了:BAAALAAECggICAAAAA==.',['缤纷']='缤纷果然多:BAAALAAECgYICgAAAA==.',['老白']='老白桃:BAAALAAECgYICAAAAA==.',['聆雪']='聆雪依风:BAAALAAECgMIAwAAAA==.',['臧天']='臧天:BAAALAAFFAIIBAAAAA==.',['至尊']='至尊霸狂帝豪:BAAALAADCgYIBgAAAA==.',['至高']='至高圣愈:BAABLAAFFH8GAAIMAAIIyw6XYgBZAAAMAAIIyw6XYgBZAAAAAA==.',['花似']='花似梦:BAAALAAECgEIAQAAAA==.',['花落']='花落流水:BAABLAAFFH8bAAIQAAYIHyL9BQBSAgAQAAYIHyL9BQBSAgAAAA==.',['花青']='花青鱼丶:BAAALAAECgYIBgAAAA==.',['苍蓝']='苍蓝星:BAAALAAECgUIBQAAAA==.苍蓝爆破:BAABLAAFFH8TAAIIAAYIqAVuRwAfAQAIAAYIqAVuRwAfAQAAAA==.',['苦尔']='苦尔丹:BAAALAAFFAIIAgAAAA==.',['范多']='范多尼尔:BAABLAAFFH8GAAIMAAIIiwmDWgBkAAAMAAIIiwmDWgBkAAAAAA==.',['莎野']='莎野布慧:BAABLAAFFH8IAAIIAAUI3RKfRAArAQAIAAUI3RKfRAArAQAAAA==.',['萌丨']='萌丨新:BAAALAAECgcIBwAAAA==.',['萨手']='萨手人寰:BAABLAAFFH8HAAIMAAIIeAm+agBRAAAMAAIIeAm+agBRAAAAAA==.',['落篱']='落篱:BAAALAAECgYIDAAAAA==.',['虔诚']='虔诚:BAABLAAFFH8YAAIHAAYIsCUaBACZAgAHAAYIsCUaBACZAgAAAA==.',['虾米']='虾米叨叨:BAAALAAECgYIDAAAAA==.',['蚊子']='蚊子进冰箱:BAABLAAFFH8HAAICAAII7QoxVACMAAACAAII7QoxVACMAAAAAA==.',['街角']='街角摆摊卖萌:BAAALAAECgYICAAAAA==.',['要什']='要什么完美:BAAALAAECgQIBAAAAA==.',['识德']='识德唔识德:BAAALAADCgMIAwAAAA==.',['请叫']='请叫我死亡:BAAALAAECgQIBwAAAA==.',['貌似']='貌似潘安:BAAALAADCggICAAAAA==.',['轻风']='轻风知语:BAAALAAECgYIDAAAAA==.',['这谁']='这谁顶得住啊:BAAALAAECgYICgAAAA==.',['逆光']='逆光之心:BAABLAAFFH8OAAIIAAgILAzMMwBuAQAIAAgILAzMMwBuAQAAAA==.',['遇上']='遇上彩虹:BAACLAAFFH8YAAIIAAYIIxXGKQCSAQAIAAYIIxXGKQCSAQAsAAQKfxYAAggACAg5JZoMAEMDAAgACAg5JZoMAEMDAAAA.',['邪恶']='邪恶的老太婆:BAAALAADCgYIBgAAAA==.邪恶维度:BAAALAAECgUIBgAAAA==.',['邪能']='邪能烤翅:BAACLAAFFH83AAIUAAYI8CT/AAAdAgAUAAYI8CT/AAAdAgAsAAQKfyYAAxQACAi7ItUGAPwCABQACAgoItUGAPwCAAkACAgrHe0WACUCAAAA.',['部落']='部落之战:BAAALAADCgEIAQAAAA==.',['酸伟']='酸伟:BAAALAAECgIIAgAAAA==.',['闪电']='闪电九连鞭:BAAALAAECgYICgAAAA==.闪电波比:BAAALAAECgcIBwAAAA==.',['阿兰']='阿兰德龙:BAAALAADCgEIAQAAAA==.',['阿基']='阿基塔:BAABLAAFFH8FAAIXAAMIKgSbJQBTAAAXAAMIKgSbJQBTAAAAAA==.',['阿里']='阿里:BAABLAAFFH8FAAIBAAIIyg+emABCAAABAAIIyg+emABCAAAAAA==.',['阿隆']='阿隆索东东:BAAALAAECgYICgAAAA==.',['隐鯓']='隐鯓丶守候:BAAALAADCgIIAgAAAA==.',['难逃']='难逃月色:BAAALAAECgYIDgAAAA==.',['雷霆']='雷霆战警:BAAALAAECgYIEwAAAA==.',['青禾']='青禾染:BAAALAADCggICAAAAA==.',['韭菜']='韭菜和子:BAAALAAFFAIIAgAAAA==.',['顺其']='顺其自然丷:BAAALAAECgYIBgAAAA==.',['顾小']='顾小柒:BAAALAADCgIIAgAAAA==.',['顾方']='顾方亚:BAAALAAECgYIDAABLAAECgYIEwAYAAAAAA==.',['风丨']='风丨之痕:BAAALAAECgYIBgAAAA==.',['飘逸']='飘逸的花生:BAABLAAFFH8KAAIBAAMIfRLCcwB7AAABAAMIfRLCcwB7AAAAAA==.',['驱夜']='驱夜星辰:BAAALAAECgIIAgAAAA==.',['骑士']='骑士之花:BAABLAAFFH8IAAIOAAYIoBxlFgCfAQAOAAYIoBxlFgCfAQAAAA==.',['鬼影']='鬼影缠身:BAAALAAFFAIIAgAAAA==.',['鸟瑟']='鸟瑟尔:BAAALAADCgIIAgAAAA==.',['麦田']='麦田丶守望:BAAALAAECgUIBQAAAA==.',['龙门']='龙门人:BAAALAAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end