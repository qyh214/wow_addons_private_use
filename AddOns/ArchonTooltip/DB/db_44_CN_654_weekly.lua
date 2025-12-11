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
 local lookup = {'Druid-Restoration','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Brewmaster','Rogue-Assassination','Rogue-Subtlety','Priest-Holy','Priest-Shadow','Paladin-Retribution','DeathKnight-Frost','Druid-Guardian','Druid-Feral','Shaman-Restoration','Paladin-Holy','Warrior-Fury','DeathKnight-Blood','DemonHunter-Havoc','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Warrior-Protection','DemonHunter-Vengeance','Mage-Frost','Paladin-Protection','Evoker-Devastation','Rogue-Outlaw','Shaman-Elemental','Unknown-Unknown','Mage-Arcane','Evoker-Preservation','DeathKnight-Unholy',}; local provider = {region='CN',realm='安纳塞隆',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Arthur:BAAALAAECgEIAQABLAAFFAgICAABADMeAA==.',Co='Cococat:BAAALAAFFAIIBAAAAA==.',Da='Darkkiss:BAAALAAECgYIDwAAAA==.',Dh='Dh:BAAALAADCgMIAwAAAA==.',Dj='Djslxs:BAAALAADCgIIAgAAAA==.',Go='Goat:BAABLAAFFH8HAAMCAAMIpR0BGACtAAACAAIIAx0BGACtAAADAAEI5x4OgwBPAAAAAA==.',Gr='Gravityy:BAABLAAFFH8IAAIEAAgIOgffCgCWAQAEAAgIOgffCgCWAQAAAA==.',Hi='Hingis:BAAALAAECgEIAQAAAA==.',Ho='Homeparanoid:BAAALAAECgQIBgAAAA==.',If='Ifyoudie:BAAALAAECgYIBgAAAA==.',Iv='Ivory:BAABLAAFFH8OAAMFAAQIZBRNEQDtAAAFAAQIZBRNEQDtAAAGAAEIeRIyGgAAAAAAAA==.',Ka='Karley:BAAALAAECgIIAgAAAA==.',Ke='Kennard:BAABLAAFFH8OAAMHAAYI5xsNEgDKAQAHAAYI5xsNEgDKAQAIAAEI6QP+LQA6AAAAAA==.',Lo='Lovehlj:BAAALAAECgEIAgAAAA==.',Mo='Momica:BAAALAAECgYIBgAAAA==.',Re='Regina:BAABLAAECn8VAAIJAAYIehkO0ABxAQAJAAYIehkO0ABxAQAAAA==.Relic:BAAALAAECgYIDAAAAA==.',Ro='Rotom:BAAALAAECgIIAgAAAA==.',Th='Theokoles:BAAALAAECgYICgAAAA==.',['一一']='一一宁静致远:BAAALAAECgYIDQAAAA==.',['一丢']='一丢丢:BAAALAAECgYIBgAAAA==.',['一之']='一之濑琴美:BAABLAAFFH8KAAIKAAMIcRq+NQDIAAAKAAMIcRq+NQDIAAAAAA==.',['一小']='一小唯一:BAAALAAECgUICgAAAA==.',['三千']='三千:BAACLAAFFH8JAAILAAIIRxfMBwB0AAALAAIIRxfMBwB0AAAsAAQKfyEAAwsABgg2H5MMABUCAAsABgg2H5MMABUCAAwAAwgPBeJAAHcAAAAA.',['不呆']='不呆不傻还萌:BAAALAAECgYIBgAAAA==.',['不川']='不川苦茶子:BAABLAAFFH8TAAMCAAYIwhpkAwC9AQACAAYIhBpkAwC9AQADAAYI9REDLgB+AQAAAA==.',['不莣']='不莣初心:BAAALAAECgYIDQAAAA==.',['不要']='不要啊姐夫:BAAALAAFFAIIAgAAAA==.',['两只']='两只小老虎:BAAALAAECgYICwAAAA==.',['丨丶']='丨丶飛影灬:BAAALAAECgMIAwAAAA==.',['丨休']='丨休:BAABLAAECn8VAAINAAYIbw7jVQAGAQANAAYIbw7jVQAGAQAAAA==.',['丨冰']='丨冰噸噸丨:BAAALAAECgIIAgAAAA==.',['丨魔']='丨魔武双修丨:BAAALAADCgYIBgAAAA==.',['丿灬']='丿灬默默:BAAALAAECgYIDAAAAA==.',['丿璀']='丿璀璨彡:BAAALAADCgcIBwAAAA==.',['九条']='九条命的猫:BAABLAAECn8UAAIOAAYI3A+iJQAVAQAOAAYI3A+iJQAVAQAAAA==.',['井阵']='井阵:BAABLAAFFH8IAAIPAAUIcAuhLwDUAAAPAAUIcAuhLwDUAAAAAA==.',['亚昆']='亚昆塔牛:BAABLAAFFH8MAAMDAAYIcBpWKgCLAQADAAYIcBpWKgCLAQACAAYIFhCrBwBMAQABLAAFFAgIGAADAIMdAA==.',['亞爾']='亞爾迪巴郎:BAAALAAECgYIBgAAAA==.',['交个']='交个朋友:BAAALAAECgYICQAAAA==.',['人之']='人之圣骑:BAAALAAECgYIDAAAAA==.人之德德:BAAALAAECgYICgAAAA==.人之死骑:BAAALAAECgYIBgAAAA==.人之霸主:BAAALAAECgYIBgAAAA==.人之霸僧:BAAALAAECgYICgAAAA==.人之霸术:BAAALAAECgcICgAAAA==.人之霸法:BAAALAAECgYICAAAAA==.人之霸猎:BAAALAAECgIIAgAAAA==.人之霸王:BAAALAAECgMIBAAAAA==.人之霸贼:BAAALAAECgMIBAAAAA==.',['今年']='今年我十八:BAACLAAFFH8xAAIQAAYIvREkCAAaAQAQAAYIvREkCAAaAQAsAAQKfzQAAxAACAjyHJ4NAHgCABAACAjyHJ4NAHgCAAoAAwjiDCR0AX0AAAEsAAUUCAgGAAoAXxMA.',['任性']='任性的七月:BAAALAAFFAIIBAAAAA==.',['伊丨']='伊丨利灬丹:BAABLAAFFH8GAAIRAAIIQhHnVwBEAAARAAIIQhHnVwBEAAAAAA==.',['伊利']='伊利大雷:BAAALAAECgYIBgAAAA==.',['众乐']='众乐乐:BAAALAAFFAIIAgAAAA==.',['你听']='你听得到:BAAALAAECgYIDAAAAA==.',['你妹']='你妹:BAAALAAECgYIBgAAAA==.',['你猛']='你猛将兄:BAAALAAECggICAAAAA==.',['佩罗']='佩罗塔牛:BAABLAAFFH8YAAMDAAYIgx2zIQCrAQADAAYIHx2zIQCrAQACAAYIyBW7BQB6AQAAAA==.',['侧田']='侧田的春袋:BAAALAAECgcIEAAAAA==.',['光与']='光与影:BAAALAADCgIIAgAAAA==.',['八百']='八百:BAACLAAFFH8GAAIDAAII1g0lYQCLAAADAAII1g0lYQCLAAAsAAQKfxoAAgMACAh1IYsXAG8CAAMACAh1IYsXAG8CAAAA.',['内个']='内个谁丶:BAAALAAECgYICAAAAA==.',['冒牌']='冒牌天神壹:BAAALAAECgYIBwAAAA==.',['冢烟']='冢烟鬼冢:BAAALAAECgYIDgAAAA==.',['冰封']='冰封正义:BAAALAAFFAIIAgAAAA==.冰封牛奶:BAABLAAECn8hAAIBAAcIjBzUHwDTAQABAAcIjBzUHwDTAQAAAA==.',['准男']='准男:BAABLAAFFH8IAAIRAAYIOR63GACnAQARAAYIOR63GACnAQAAAA==.',['凌风']='凌风啊:BAAALAAECgYICwAAAA==.',['凯悦']='凯悦:BAAALAAECgIIAgAAAA==.',['则卷']='则卷小雨:BAAALAADCgIIAgAAAA==.',['初心']='初心不改:BAAALAAECgYICwAAAA==.',['北灬']='北灬牧:BAAALAAECgEIAQAAAA==.北灬野:BAAALAADCgEIAQAAAA==.',['十一']='十一:BAACLAAFFH8QAAIJAAIIlRyqNgClAAAJAAIIlRyqNgClAAAsAAQKfxcAAgkACAglIU0gAPECAAkACAglIU0gAPECAAAA.',['华丽']='华丽丶转身:BAABLAAFFH8LAAIRAAII2xMMTwBKAAARAAII2xMMTwBKAAAAAA==.',['卡哥']='卡哥:BAAALAAFFAIIAgAAAA==.',['卷卷']='卷卷不是兔子:BAAALAAFFAQIBAAAAA==.',['厚木']='厚木刀哥:BAAALAADCgYIAwAAAA==.',['叫我']='叫我卡叔:BAAALAAECgQIBAAAAA==.',['可惡']='可惡:BAAALAAECggIEAAAAA==.',['吉拉']='吉拉迪诺牛:BAABLAAFFH8IAAIDAAgI/BJKEAAIAgADAAgI/BJKEAAIAgABLAAFFAgIGAADAIMdAA==.',['吖咩']='吖咩呆:BAAALAAECgQICQAAAA==.',['含淚']='含淚笑紅顔:BAAALAADCgIIAgAAAA==.',['吹泡']='吹泡泡的蜗牛:BAAALAADCggICAAAAA==.',['吾丨']='吾丨战:BAAALAAECgUICQAAAA==.',['呆呆']='呆呆的你:BAACLAAFFH8XAAQSAAYIihPDEACjAAATAAYIihMAKgByAQASAAMIhBLDEACjAAAUAAEITAu6CwAAAAAsAAQKfxgABBIACAi5HBMNAKACABIACAh9GxMNAKACABQABwipDHwSAI8BABMABQiKEqR0AKAAAAAA.',['哀木']='哀木骑:BAAALAAECgYIEQAAAA==.',['哈利']='哈利撸呀:BAAALAAECgYICgAAAA==.',['哟三']='哟三七零:BAABLAAFFH8GAAIDAAYIwwBfwQAdAAADAAYIwwBfwQAdAAAAAA==.',['嘿丶']='嘿丶牢头:BAABLAAFFH8FAAIDAAMImhNMbQCHAAADAAMImhNMbQCHAAAAAA==.',['回丨']='回丨忆:BAAALAAECgEIAQAAAA==.',['回波']='回波斯喂猫:BAAALAAFFAIIAgAAAA==.',['圆桌']='圆桌骑士:BAAALAAECgYICwAAAA==.',['圣光']='圣光烤地瓜:BAAALAAECgUIBQAAAA==.',['圣血']='圣血帝王:BAABLAAFFH8GAAIJAAYIRAE4TQBhAAAJAAYIRAE4TQBhAAAAAA==.',['圣魔']='圣魔狂:BAAALAAFFAgIBAAAAA==.',['地精']='地精王大胆:BAABLAAFFH8JAAIKAAUItA29RwAaAQAKAAUItA29RwAaAQAAAA==.',['夜天']='夜天子:BAACLAAFFH8wAAIKAAcIzxxyEQACAgAKAAcIzxxyEQACAgAsAAQKfzIAAgoACAgRIoQdAPkCAAoACAgRIoQdAPkCAAAA.',['大司']='大司命:BAAALAAECggICAAAAA==.',['大漠']='大漠:BAABLAAFFH8GAAIDAAYI5w3RRQAzAQADAAYI5w3RRQAzAQAAAA==.',['大粗']='大粗牛:BAABLAAECn8VAAIBAAYIow3oggAXAQABAAYIow3oggAXAQAAAA==.',['大领']='大领主丶:BAAALAAFFAIIAgAAAA==.',['天南']='天南丶小生:BAAALAAFFAIIBAAAAA==.',['天呐']='天呐你真烧:BAAALAAECgEIAQAAAA==.',['天阶']='天阶夜色:BAAALAAECgIIAgAAAA==.',['奥森']='奥森冬日暖阳:BAAALAAECgQIBAAAAA==.',['奶油']='奶油丶小生:BAAALAAFFAIIAgAAAA==.',['奶量']='奶量很大啊:BAAALAAECgEIAQAAAA==.',['如意']='如意算盘:BAAALAAECgYIDQAAAA==.',['婷婷']='婷婷香婷:BAABLAAFFH8GAAIRAAYIHwEJYwA9AAARAAYIHwEJYwA9AAAAAA==.',['嫂子']='嫂子请抱紧沃:BAABLAAFFH8KAAIPAAMISQzsOgCGAAAPAAMISQzsOgCGAAAAAA==.',['孔雀']='孔雀翎:BAAALAADCggICAAAAA==.',['孤星']='孤星之泪:BAABLAAFFH8GAAITAAIISAoVaAA4AAATAAIISAoVaAA4AAAAAA==.',['宁静']='宁静一致远:BAAALAAECgYIEQAAAA==.宁静致远:BAAALAAECgYICQAAAA==.宁静致远喵喵:BAAALAAECgEIAQAAAA==.宁静致远欣:BAAALAAECgYIDAAAAA==.宁静致远涛:BAAALAAECgUIBQAAAA==.宁静致远的猫:BAAALAAECgYIBgAAAA==.',['宇智']='宇智波刘能丶:BAAALAAECgQIBAAAAA==.',['安纳']='安纳酷猎:BAAALAAECgYIDAAAAA==.安纳酷贼:BAAALAAECgYIBgAAAA==.',['寧靜']='寧靜致遠:BAAALAADCgcICgAAAA==.',['小卧']='小卧底:BAAALAAECgYIBwAAAA==.',['小天']='小天才踢破:BAACLAAFFH8GAAITAAIIux1hMAC5AAATAAIIux1hMAC5AAAsAAQKfxUAAhMACAiuIcQYAPMCABMACAiuIcQYAPMCAAAA.',['小小']='小小毛头:BAAALAAECgEIAQAAAA==.小小萌牛:BAAALAAECgYIDAAAAA==.',['小尖']='小尖椒炒土豆:BAAALAADCgcICgAAAA==.',['小猪']='小猪失恋了丶:BAAALAAECgYIBgAAAA==.',['小豆']='小豆丁:BAAALAAECgQIBAAAAA==.',['尼克']='尼克胡尼克:BAAALAADCggICAAAAA==.',['工友']='工友夸我够烧:BAABLAAFFH8JAAIEAAMIhAxXGgBrAAAEAAMIhAxXGgBrAAABLAAFFAMIDAAVAM0VAA==.工友夸我太硬:BAABLAAFFH8MAAIVAAMIzRUCGACZAAAVAAMIzRUCGACZAAAAAA==.工友夸我奇硬:BAABLAAFFH8JAAIWAAIIixp2EQBBAAAWAAIIixp2EQBBAAAAAA==.工友夸我好凶:BAABLAAFFH8GAAMKAAII9xNvhwBCAAAKAAIIaglvhwBCAAAQAAIIDBEGHAAxAAAAAA==.工友夸我好强:BAABLAAFFH8IAAIEAAII6g+5FwBvAAAEAAII6g+5FwBvAAAAAA==.工友夸我好野:BAABLAAFFH8GAAILAAIITReECwA/AAALAAIITReECwA/AAAAAA==.工友夸我挺猛:BAABLAAFFH8IAAIEAAMI3hI9GQCBAAAEAAMI3hI9GQCBAAABLAAFFAMIDAAVAM0VAA==.工友夸我极猛:BAAALAAFFAIIBAAAAA==.工友夸我特强:BAABLAAFFH8HAAIXAAIIDBcRFABHAAAXAAIIDBcRFABHAAAAAA==.工友夸我特棒:BAAALAAFFAIIBAABLAAFFAMIDAAVAM0VAA==.工友夸我特硬:BAAALAAFFAIIBAABLAAFFAMIDAAVAM0VAA==.工友夸我真大:BAAALAAFFAIIAgAAAA==.工友夸我真棒:BAABLAAFFH8IAAIVAAMIthEpIAB4AAAVAAMIthEpIAB4AAAAAA==.工友夸我真猛:BAABLAAFFH8GAAIYAAIIQx5mFQBNAAAYAAIIQx5mFQBNAAAAAA==.工友夸我真硬:BAAALAAFFAIIAgAAAA==.工友夸我能喷:BAABLAAFFH8HAAIZAAIIjwsDHgB8AAAZAAIIjwsDHgB8AAABLAAFFAMIDAAVAM0VAA==.工友夸我能射:BAABLAAFFH8GAAIDAAMI0Q9KdAB3AAADAAMI0Q9KdAB3AAABLAAFFAMIDAAVAM0VAA==.工友夸我贼牛:BAABLAAFFH8GAAIaAAIICxpeBABSAAAaAAIICxpeBABSAAABLAAFFAMIDAAVAM0VAA==.工友夸我颇烧:BAAALAAFFAIIBAAAAA==.',['巴罗']='巴罗内牛:BAABLAAFFH8QAAMCAAYIrBkzBgBuAQACAAYIAxUzBgBuAQADAAQIjxq9VAD8AAABLAAFFAgIGAADAIMdAA==.',['希尔']='希尔丨瓦娜斯:BAACLAAFFH8SAAIDAAYI9RtSKQCOAQADAAYI9RtSKQCOAQAsAAQKfyAAAgMACAg+GURFAL4BAAMACAg+GURFAL4BAAAA.希尔瓦娜肆:BAAALAAECgYIDAAAAA==.',['带投']='带投大哥:BAAALAAECgIIAgAAAA==.',['心中']='心中有场大雪:BAAALAAECgYIBgAAAA==.',['忧郁']='忧郁小小猎:BAAALAAECgIIAgAAAA==.',['快乐']='快乐魔术师:BAAALAAECgIIAgAAAA==.',['忽必']='忽必烈人:BAAALAAFFAIIBAAAAA==.',['怎么']='怎么都射不死:BAAALAAECgIIAgAAAA==.',['思念']='思念丶丹:BAAALAADCggICAAAAA==.思念已丶凋谢:BAAALAADCgQIBAAAAA==.',['慕色']='慕色倾城:BAAALAAECgIIAgAAAA==.',['慕骋']='慕骋:BAAALAAECgQIBAAAAA==.',['我不']='我不是电动的:BAAALAADCgQIBAAAAA==.',['我也']='我也没有办法:BAACLAAFFH8qAAIJAAcIXB7NBAA7AgAJAAcIXB7NBAA7AgAsAAQKfysAAgkACAj8IoMgAPACAAkACAj8IoMgAPACAAAA.',['我们']='我们校风很大:BAAALAAECggIBAAAAA==.',['我依']='我依旧是传奇:BAAALAADCgUIBQAAAA==.',['我全']='我全都知道哦:BAAALAADCgEIAQAAAA==.',['我是']='我是叫兽:BAAALAADCgMIAwAAAA==.我是欧皇:BAAALAADCgcICQAAAA==.',['战灬']='战灬士:BAACLAAFFH8OAAIPAAYIVh/6DgDgAQAPAAYIVh/6DgDgAQAsAAQKfxgAAg8ACAiJIlMZAPECAA8ACAiJIlMZAPECAAEsAAUUCAggAA8A3x0A.',['战牛']='战牛蛮蛮:BAAALAAECgYIBgAAAA==.',['战神']='战神灬战誓:BAAALAAECgYIBgAAAA==.',['戰丨']='戰丨钰:BAABLAAFFH8IAAIJAAII2Rg1XABIAAAJAAII2Rg1XABIAAAAAA==.',['扒衣']='扒衣老爷:BAAALAAECgYICAAAAA==.',['打针']='打针我不怕:BAAALAADCgMIAwAAAA==.',['抗战']='抗战二十年:BAAALAAECgUIBgAAAA==.',['抹茶']='抹茶曲奇:BAAALAAFFAIIAgAAAA==.',['挥手']='挥手阳光:BAAALAAECggIDQAAAA==.',['敏捷']='敏捷的阿昆达:BAAALAAECggIAgAAAA==.',['文小']='文小可:BAAALAADCgIIAgAAAA==.',['断腿']='断腿柯基:BAAALAAECgYIBgAAAA==.',['旋转']='旋转残情:BAAALAAECgEIAQAAAA==.旋转火柴:BAAALAAECgEIAQAAAA==.',['无声']='无声笛:BAAALAAECgMIAgAAAA==.',['昊丶']='昊丶坤尔加丹:BAAALAAECgYIDQAAAA==.',['明丶']='明丶:BAABLAAFFH8FAAMbAAMIEBTKMwCPAAAbAAMIEBTKMwCPAAANAAIIAhmCTgB+AAAAAA==.',['明明']='明明白白:BAAALAAECgIIAgAAAA==.',['明月']='明月清风:BAABLAAFFH8GAAIDAAYIIQvuSQAkAQADAAYIIQvuSQAkAQAAAA==.',['星回']='星回:BAAALAADCgMIAwAAAA==.',['星界']='星界旅行者:BAABLAAFFH8HAAIDAAcIHAx1PgBLAQADAAcIHAx1PgBLAQABLAAFFAgICAABADMeAA==.',['春花']='春花秋月:BAAALAAFFAIIBAAAAA==.',['昭羽']='昭羽:BAAALAAFFAIIAgAAAA==.',['暗度']='暗度熊仓:BAAALAAECgYIEAAAAA==.',['暗淡']='暗淡星辰:BAAALAAFFAIIBAAAAA==.',['暗箭']='暗箭丶:BAAALAAECgIIAQAAAA==.',['月华']='月华:BAAALAAECgYIDQAAAA==.',['木桶']='木桶牛:BAAALAAECgEIAQAAAA==.',['李小']='李小龙:BAAALAADCgMIAwAAAA==.',['李黑']='李黑:BAAALAAECgQIBAAAAA==.',['杨兽']='杨兽医:BAAALAADCgQIBAAAAA==.',['枕头']='枕头丶:BAAALAADCgUIBQAAAA==.',['枫林']='枫林狩猎:BAABLAAFFH8GAAIDAAYIAAHxvwAjAAADAAYIAAHxvwAjAAAAAA==.',['梦雨']='梦雨依:BAACLAAFFH8QAAIJAAIINBZAVwBLAAAJAAIINBZAVwBLAAAsAAQKfxgAAgkABginGC5XAFwBAAkABginGC5XAFwBAAAA.',['橙色']='橙色丶圣光:BAABLAAFFH8JAAMJAAYIUQjFNADbAAAJAAUIJQnFNADbAAAYAAEIMASOHwAtAAAAAA==.橙色丶风暴:BAABLAAFFH8TAAIDAAYISg0ySAAqAQADAAYISg0ySAAqAQAAAA==.',['死狐']='死狐狸:BAAALAAECgIIAgAAAA==.',['死耗']='死耗子:BAAALAADCgMIAwAAAA==.',['比克']='比克:BAAALAAECgYIEwAAAA==.',['毛战']='毛战:BAAALAAECgMIAwAAAA==.',['沫沫']='沫沫丶丿:BAAALAAECgMIBAAAAA==.沫沫灬:BAAALAAECgIIAgAAAA==.',['泰拉']='泰拉:BAAALAAFFAIIAgAAAA==.',['泼墨']='泼墨:BAAALAAFFAIIAgAAAA==.',['浪漫']='浪漫救人:BAABLAAFFH8QAAINAAIIESH7OQC7AAANAAIIESH7OQC7AAAAAA==.',['海盗']='海盗:BAAALAAECggICAAAAA==.海盗号角:BAABLAAFFH8OAAIJAAYIgxvNEgCyAQAJAAYIgxvNEgCyAQAAAA==.',['海鲜']='海鲜:BAAALAAECgYIBgABLAAECgYIDwAcAAAAAA==.',['清辉']='清辉夜宁:BAAALAAFFAIIAgAAAA==.',['灬七']='灬七喜灬:BAAALAAECgYIDwAAAA==.',['灬允']='灬允:BAAALAAECgUICQAAAA==.',['灬回']='灬回笼觉主灬:BAAALAAECgQIBAAAAA==.',['灬按']='灬按键伤人灬:BAAALAAECgYIBgAAAA==.',['灬熠']='灬熠卓丶周:BAAALAAECgYIBgAAAA==.',['灬苏']='灬苏坡曼灬:BAAALAADCgcIBwAAAA==.灬苏某某灬:BAAALAAECgYIEwAAAA==.',['灬虎']='灬虎爷:BAAALAAECgMIAwAAAA==.',['灬风']='灬风中追风灬:BAAALAAECgEIAQAAAA==.',['灰烬']='灰烬中重生:BAAALAAECggICAABLAAFFAYIDAADAN8YAA==.',['烟圈']='烟圈:BAAALAAECgQIBAAAAA==.',['烟雾']='烟雾:BAAALAAECggICAAAAA==.',['焱殺']='焱殺暴军:BAAALAAECggICAAAAA==.',['熊力']='熊力战将:BAAALAAECgYIBgAAAA==.',['熔岩']='熔岩之光:BAAALAAECgUIBQAAAA==.',['爱吃']='爱吃豌杂面:BAAALAADCgcIBwAAAA==.',['牛牛']='牛牛咚咚:BAAALAAFFAIIBAAAAA==.牛牛战斗斗:BAAALAAFFAQIAQAAAA==.',['牛马']='牛马无常:BAABLAAFFH8KAAIRAAUICA4HLgAoAQARAAUICA4HLgAoAQAAAA==.',['狗蛋']='狗蛋儿:BAAALAAECgYICQAAAA==.',['猎手']='猎手霸主:BAAALAAECgYICwAAAA==.',['猎鲨']='猎鲨丶:BAAALAAFFAIIBAAAAA==.',['猪嚼']='猪嚼紧:BAABLAAECn8hAAIKAAgI1h5RUABYAgAKAAgI1h5RUABYAgAAAA==.',['王乂']='王乂爺:BAAALAAFFAIIAgAAAA==.',['琉璃']='琉璃风铃:BAAALAAECgYIBgABLAAFFAgICAABADMeAA==.',['疏楼']='疏楼:BAAALAAFFAIIAgAAAA==.',['白魔']='白魔王灬丨:BAAALAAECgYIBgABLAAFFAgIEQAQAIgVAA==.',['皮蛋']='皮蛋豆腐:BAAALAADCgIIAgAAAA==.',['真的']='真的很无聊:BAAALAADCgMIAwAAAA==.',['砂糖']='砂糖钊:BAAALAAECgYICwAAAA==.',['神龙']='神龙霸主:BAAALAAECgUIBgAAAA==.',['福崽']='福崽:BAAALAAECgYIBgAAAA==.',['秀一']='秀一丶:BAABLAAFFH8GAAIRAAII1wwsXwA/AAARAAII1wwsXwA/AAAAAA==.',['立志']='立志一生永恒:BAAALAAECgMIBQAAAA==.',['筱筱']='筱筱弓:BAAALAADCgYIBgAAAA==.',['米蘭']='米蘭国际:BAAALAADCgIIAgAAAA==.',['精神']='精神晓伙:BAAALAADCgUIBQAAAA==.',['紫晴']='紫晴彩虹:BAACLAAFFH8NAAITAAMITRLhTQCDAAATAAMITRLhTQCDAAAsAAQKfxYAAxMABggFFiU+AE8BABMABggFFiU+AE8BABIAAwhSAzCUAEAAAAAA.',['纤纤']='纤纤:BAAALAAFFAIIAgAAAA==.',['纳兹']='纳兹多拉格尼:BAABLAAFFH8MAAIdAAYIeCCnCQAgAgAdAAYIeCCnCQAgAgAAAA==.',['细语']='细语离殇:BAAALAAECgYIBgAAAA==.',['绝世']='绝世呆贼:BAAALAAECggIBgAAAA==.',['缺人']='缺人疼灬:BAAALAAECgIIAgAAAA==.',['翼叶']='翼叶之秋:BAAALAAECgYIBgAAAA==.',['聖丶']='聖丶龍:BAABLAAFFH8GAAIeAAYIFhWzCgCqAQAeAAYIFhWzCgCqAQAAAA==.',['胡诌']='胡诌:BAAALAADCgEIAQAAAA==.',['自由']='自由自在:BAABLAAFFH8GAAIJAAIIewsQcQA9AAAJAAIIewsQcQA9AAAAAA==.',['芊芊']='芊芊晓璇:BAABLAAECn8WAAIKAAYI6g2VbAAVAQAKAAYI6g2VbAAVAQAAAA==.',['花腿']='花腿鲤鱼:BAAALAAECggIBgAAAA==.',['苍白']='苍白圣光:BAAALAAECgYIBgAAAA==.',['苏醒']='苏醒的月亮:BAAALAADCgIIAgAAAA==.',['茶丶']='茶丶壶:BAACLAAFFH8kAAMKAAgI4SEHAQDlAgAKAAgI4SEHAQDlAgAfAAMICRqqBQAcAQAsAAQKfyIAAwoACAg2JpQZAAoDAAoACAg2JpQZAAoDAB8ACAiCGEAWABACAAAA.',['萝莉']='萝莉深夜交喘:BAAALAADCgMIAwAAAA==.',['萨小']='萨小二:BAAALAAECgUICgAAAA==.',['萨满']='萨满霸主:BAAALAAECgcIEQAAAA==.',['落坨']='落坨翔子:BAABLAAFFH8FAAIbAAIIHRATKwCSAAAbAAIIHRATKwCSAAAAAA==.',['落花']='落花聼雨:BAAALAAECgYICwAAAA==.',['蓝羽']='蓝羽:BAABLAAFFH8MAAIKAAQI7hyARACsAAAKAAQI7hyARACsAAAAAA==.',['蠺丨']='蠺丨殇徳:BAAALAAFFAIIAgAAAA==.',['血色']='血色升旗士:BAABLAAFFH8GAAIJAAIIfQKBZABdAAAJAAIIfQKBZABdAAAAAA==.',['血蹄']='血蹄丶:BAAALAADCgEIAQAAAA==.',['西门']='西门槑娜斯:BAAALAAECgYIDAAAAA==.西门槑战:BAAALAAFFAIIBAAAAA==.西门槑术:BAAALAAFFAIIBAAAAA==.西门罗兰:BAABLAAFFH8GAAIYAAIIPA7qIQAnAAAYAAIIPA7qIQAnAAAAAA==.',['请你']='请你吃葡萄:BAAALAAECgYIBgAAAA==.请你吃香蕉:BAAALAAFFAEIAQAAAA==.',['谁不']='谁不是个菜鸡:BAABLAAFFH8IAAIKAAIIWgQ4lABtAAAKAAIIWgQ4lABtAAAAAA==.',['豪呦']='豪呦哏:BAAALAAECgYIBgAAAA==.',['赵洪']='赵洪江:BAAALAADCgQIBAAAAA==.',['超爱']='超爱雪碧:BAAALAAECgYICwAAAA==.',['轻语']='轻语青岚:BAAALAAECggIAwAAAA==.',['这个']='这个头疼啊:BAAALAADCgIIAgAAAA==.',['逍遥']='逍遥一梦:BAABLAAFFH8QAAMIAAgIQhUbBAA/AgAIAAgIQhUbBAA/AgAHAAUIchAAAAAAAAAAAA==.',['醉酒']='醉酒当歌丶:BAABLAAFFH8GAAIXAAII0BE3EwCHAAAXAAII0BE3EwCHAAAAAA==.',['醴泉']='醴泉:BAAALAADCgEIAgAAAA==.',['野生']='野生丶唐三葬:BAAALAAECgUIDwAAAA==.野生丶葫芦娃:BAAALAAECgUICQAAAA==.',['野蛮']='野蛮小歪:BAAALAAECgYIDgAAAA==.',['鑫森']='鑫森淼焱垚明:BAAALAAECgQIBQAAAA==.',['钰萌']='钰萌:BAAALAAECgYIDAAAAA==.',['锁天']='锁天:BAABLAAFFH8JAAMDAAMI3Q9QUACVAAADAAMIqA9QUACVAAACAAIIqw8SJQB9AAAAAA==.',['锁魔']='锁魔血晓贱:BAAALAADCgYIBgAAAA==.',['闪电']='闪电点灯泡:BAAALAADCgIIAgAAAA==.',['阳炎']='阳炎吹雪:BAAALAADCgcICAAAAA==.',['阿兰']='阿兰哥哥:BAAALAADCggICAAAAA==.',['雪月']='雪月风花:BAABLAAFFH8IAAIdAAYIaQ0SMQBAAQAdAAYIaQ0SMQBAAQAAAA==.',['领航']='领航:BAAALAAECgYIBgAAAA==.',['风情']='风情囧囧:BAAALAAECgIIAwAAAA==.风情牛牛:BAAALAAECgYICQAAAA==.',['骨染']='骨染锈尘:BAAALAAFFAIIAgAAAA==.',['魔咒']='魔咒:BAABLAAFFH8JAAIDAAUIFgZWWQDkAAADAAUIFgZWWQDkAAAAAA==.',['鲨鱼']='鲨鱼辣椒丨:BAAALAADCgIIAgAAAA==.',['麥尅']='麥尅小牛:BAAALAAECgYICwAAAA==.',['麦斯']='麦斯蒂娜:BAAALAAECgUIBQAAAA==.',['黑暗']='黑暗圣堂武士:BAAALAADCgMIAwAAAA==.',['默丶']='默丶默:BAAALAAECgYIBgAAAA==.',['默默']='默默:BAAALAAECgMIBwAAAA==.默默丿丿:BAAALAAECgYICAAAAA==.默默灬灬丶:BAAALAAECgMIAwAAAA==.',['齐撸']='齐撸银行:BAAALAAECgYICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end