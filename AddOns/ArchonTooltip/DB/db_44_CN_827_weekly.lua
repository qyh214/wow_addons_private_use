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
 local lookup = {'DemonHunter-Havoc','Warlock-Destruction','DeathKnight-Frost','DemonHunter-Vengeance','Paladin-Retribution','Warrior-Protection','Warrior-Fury','Druid-Feral','Hunter-BeastMastery','Mage-Frost','Mage-Arcane','Mage-Fire','Shaman-Restoration','Rogue-Outlaw','Monk-Brewmaster','Paladin-Holy','Rogue-Subtlety','Druid-Balance','Druid-Restoration','Shaman-Elemental','Warlock-Demonology','Rogue-Assassination','Priest-Holy','Priest-Shadow','Monk-Mistweaver','DeathKnight-Blood','Paladin-Protection','Hunter-Marksmanship','Monk-Windwalker','Warlock-Affliction','Evoker-Preservation','Evoker-Devastation','DeathKnight-Unholy','Hunter-Survival','Warrior-Arms','Unknown-Unknown','Druid-Guardian',}; local provider = {region='CN',realm='血顶',name='CN',type='weekly',zone=44,date='2025-12-06',data={As='Asddsf:BAAALAAFFAIIAgAAAA==.Asuras:BAABLAAFFH8TAAIBAAYILxWLGQCjAQABAAYILxWLGQCjAQAAAA==.',Be='Beauiful:BAAALAADCggICAAAAA==.',By='Bytedance:BAABLAAFFH8NAAICAAYIoAgNNABFAQACAAYIoAgNNABFAQAAAA==.',Ca='Catherine:BAAALAAFFAIIAgAAAA==.',Ci='Citrus:BAAALAAECggICAABLAAFFAYIHQADABAbAA==.',Cl='Clause:BAAALAAECgcIEAAAAA==.',Da='Darkgabriel:BAABLAAFFH8GAAIEAAYI3hb5BABSAQAEAAYI3hb5BABSAQAAAA==.Daydreamer:BAABLAAECn8uAAIFAAgILxuXPACFAgAFAAgILxuXPACFAgAAAA==.',En='Enzoo:BAAALAAECgYIBgAAAA==.',Fl='Flash:BAAALAAECgMIAwAAAA==.',Ga='Gakki:BAAALAAECggICAAAAA==.',Gu='Guaguare:BAAALAADCgQIBAAAAA==.',Ic='Iceknight:BAAALAAECgUICgAAAA==.',Kr='Kratos:BAABLAAFFH8FAAIGAAUIABQuFwD2AAAGAAUIABQuFwD2AAABLAAFFAgICwAHACohAA==.',La='Landh:BAAALAAECgEIAQAAAA==.',Le='Lengzhi:BAAALAAFFAIIAgABLAAFFAgIIgACAH0lAA==.',Lo='Lovestory:BAAALAAECgYICwAAAA==.Loxx:BAAALAAECgYIDgAAAA==.',Lu='Lucia:BAAALAADCggIDwAAAA==.',Lz='Lzz:BAAALAAECgEIAQAAAA==.',Ma='Maanen:BAAALAADCgMIAwAAAA==.Mariko:BAAALAAFFAIIAgAAAA==.',Mi='Mindali:BAAALAAECgYIBgAAAA==.Misae:BAAALAAECgYIBgAAAA==.Mithril:BAABLAAFFH8IAAIIAAgIIgHWDQBEAAAIAAgIIgHWDQBEAAAAAA==.',Mo='Moonhalo:BAAALAAFFAIIBAABLAAFFAYIDQAJAOIRAA==.Moonray:BAABLAAFFH8KAAQKAAMIqRX0DQB9AAAKAAMIuwv0DQB9AAALAAIIzRfvWQBBAAAMAAEI9QFkEAApAAABLAAFFAYIDQAJAOIRAA==.Moonrise:BAABLAAFFH8FAAIDAAMIvRTXXwCPAAADAAMIvRTXXwCPAAAAAA==.Moonriver:BAABLAAFFH8NAAIJAAYI4hEDQwA+AQAJAAYI4hEDQwA+AQAAAA==.Moonshine:BAAALAAECgYIBgAAAA==.',No='Notpeople:BAABLAAECn8UAAIJAAYIzxb0fABNAQAJAAYIzxb0fABNAQAAAA==.Nozuonodie:BAAALAAECgUIBQAAAA==.',Pa='Panicn:BAABLAAFFH8GAAIBAAQIfAVxQQCJAAABAAQIfAVxQQCJAAAAAA==.',Pl='Playerdgcwvx:BAAALAAECgYIBgAAAA==.',Sa='Saintprayer:BAAALAAECgYIEAAAAA==.',Sh='Showmaker:BAABLAAFFH8GAAINAAYIyxFcIQBTAQANAAYIyxFcIQBTAQAAAA==.',Sq='Sqs:BAABLAAFFH8HAAINAAMIuxh+OADCAAANAAMIuxh+OADCAAAAAA==.',Su='Subversion:BAAALAAECgYIDAAAAA==.',Te='Tea:BAAALAAFFAIIAgAAAA==.',Th='Thatgirl:BAAALAAFFAIIBAAAAA==.',Vs='Vssiws:BAAALAAECgUIBQAAAA==.',Wu='Wudiarmani:BAAALAAECgYICQAAAA==.',Xi='Ximalaya:BAAALAADCgMIAwAAAA==.',Za='Zaiaa:BAAALAADCggICAAAAA==.',['一介']='一介行李:BAAALAAECgYIEAAAAA==.',['一支']='一支烟:BAABLAAFFH8GAAIOAAYImAK1AgDiAAAOAAYImAK1AgDiAAAAAA==.',['一星']='一星软柿子:BAABLAAFFH8FAAIPAAUI+Q73CABPAQAPAAUI+Q73CABPAQABLAAFFAgIDwAQAD4XAA==.',['一条']='一条大菜狗:BAAALAAECgYIBgABLAAFFAIICAARAFIVAA==.',['一直']='一直很憨厚:BAAALAAFFAIIAgAAAA==.',['一米']='一米五:BAAALAAECgQIBAAAAA==.',['丁螺']='丁螺环酮:BAAALAADCgYIBgAAAA==.',['七月']='七月诞:BAAALAAECggICgAAAA==.',['三五']='三五遗南:BAAALAAECgYICQAAAA==.',['三路']='三路向西:BAAALAAECgQIBAAAAA==.',['三鹿']='三鹿毒奶:BAAALAAFFAIIAgAAAA==.',['上善']='上善若水:BAAALAAECgYIBgAAAA==.',['不见']='不见圣光:BAAALAAECgMIAwAAAA==.',['与肾']='与肾光同在:BAAALAAECgUIBQAAAA==.',['丢丢']='丢丢呢:BAAALAAECgYIBgAAAA==.丢丢辉:BAAALAAFFAIIBAAAAA==.',['两生']='两生花:BAAALAADCgYIBgAAAA==.',['两锤']='两锤:BAAALAADCgUIBgAAAA==.',['丨忄']='丨忄丨:BAAALAADCgEIAQAAAA==.',['丨芙']='丨芙宁娜丨:BAAALAAECgYIBwAAAA==.',['中分']='中分背带裤:BAAALAADCgIIAgAAAA==.',['丶冷']='丶冷落的小羊:BAABLAAFFH8NAAIHAAgI/CNUAQD4AgAHAAgI/CNUAQD4AgAAAA==.',['丶大']='丶大无畏:BAAALAAECgEIAQAAAA==.',['丶憨']='丶憨森森:BAACLAAFFH8KAAISAAYIeQWXIACKAAASAAYIeQWXIACKAAAsAAQKfxUAAhIABggwGrhFAJ4BABIABggwGrhFAJ4BAAAA.',['丶方']='丶方枪枪:BAAALAAFFAIIAgAAAA==.',['丶时']='丶时之砂:BAACLAAFFH8wAAMLAAYITCCfGQC3AQALAAYITCCfGQC3AQAMAAEIbhGADQBAAAAsAAQKfzkABAsACAjhIEMeANcCAAsACAiEIEMeANcCAAoABgi2GgNAAHEBAAwAAgjjHKMWAJMAAAAA.丶时之砂丶:BAACLAAFFH8JAAIBAAYIVwvLJwBUAQABAAYIVwvLJwBUAQAsAAQKfyQAAgEABghZIQFMAD0CAAEABghZIQFMAD0CAAEsAAUUBggwAAsATCAA.',['丶阿']='丶阿拉蕾:BAAALAAFFAIIAgAAAA==.',['举着']='举着我家老熊:BAAALAAECgYIDQAAAA==.',['乄我']='乄我叫哀木涕:BAACLAAFFH8IAAIDAAIIhxfGXgCZAAADAAIIhxfGXgCZAAAsAAQKfyIAAgMABggVIuJVAEsCAAMABggVIuJVAEsCAAAA.',['九离']='九离:BAAALAAECgYIBgAAAA==.',['二到']='二到家:BAAALAAECgEIAQAAAA==.',['人心']='人心似海丶:BAAALAAECgYIBgAAAA==.',['今天']='今天出橙装:BAAALAAECgIIBAAAAA==.',['以下']='以下犯上:BAABLAAECn8UAAIHAAYIDw+BVwAQAQAHAAYIDw+BVwAQAQAAAA==.',['任性']='任性牛牛:BAAALAAFFAMIAwAAAA==.',['伊利']='伊利委琐丹:BAAALAAFFAIIBAAAAA==.',['众爱']='众爱卿平身:BAAALAAECgcIBwAAAA==.',['会飞']='会飞的山鸡:BAABLAAFFH8LAAINAAMIvQ3rSwCFAAANAAMIvQ3rSwCFAAAAAA==.会飞的灬山鸡:BAABLAAFFH8GAAITAAIIYwo2PABkAAATAAIIYwo2PABkAAAAAA==.',['伯嚼']='伯嚼咖啡:BAAALAAECgYIDAAAAA==.',['佑曦']='佑曦丶:BAAALAAECgQIBQAAAA==.',['何以']='何以飘零去:BAAALAAECgQIBAAAAA==.',['你什']='你什么意思:BAABLAAFFH8IAAIBAAIIxSFuKAC9AAABAAIIxSFuKAC9AAAAAA==.',['你说']='你说的都对:BAAALAAECgEIAQAAAA==.',['佳猫']='佳猫:BAAALAAFFAIIAgAAAA==.',['依托']='依托考昔:BAABLAAECn8fAAMTAAgIxRmaLwAiAgATAAgIxRmaLwAiAgASAAYIExEvMQABAQAAAA==.',['倒悬']='倒悬山:BAAALAAECgEIAQAAAA==.',['傲雪']='傲雪江湖:BAAALAAECgIIAwAAAA==.',['傻丨']='傻丨馒:BAAALAAECggIDAAAAA==.',['傻蔓']='傻蔓:BAAALAAFFAIIBAAAAA==.',['克洛']='克洛德莫奈:BAAALAAECgYICQAAAA==.',['克莱']='克莱尔西尼亚:BAAALAAECgQIBAAAAA==.',['全天']='全天光光:BAAALAADCgYIBgAAAA==.',['冈多']='冈多拉:BAAALAAECggICAAAAA==.',['冒泡']='冒泡儿:BAAALAAECggIDgAAAA==.',['农民']='农民大伯:BAAALAADCgEIAQAAAA==.',['冥十']='冥十三:BAABLAAFFH8fAAMNAAYI0htjEADjAQANAAYI0htjEADjAQAUAAIIQwrLNgCCAAAAAA==.',['冷凝']='冷凝馨月:BAAALAADCggIEAAAAA==.',['冷妍']='冷妍冷语:BAAALAAFFAEIAQAAAA==.',['冷艳']='冷艳小妈:BAAALAAFFAEIAQAAAA==.',['冻柠']='冻柠茶少糖:BAABLAAECn8WAAMVAAgIZB7dGQAqAgAVAAYIkCDdGQAqAgACAAYI6BVLfQCGAQAAAA==.',['凝丶']='凝丶轩:BAAALAAECgEIAQAAAA==.',['几叶']='几叶到寒:BAAALAAECgYIBgAAAA==.',['凡夫']='凡夫丶俗子:BAAALAAECgQIBAAAAA==.',['击锤']='击锤:BAAALAAECgYICQAAAA==.',['刀仔']='刀仔:BAAALAAECgYIDwAAAA==.',['划水']='划水的烤鸭:BAAALAADCgMIAwAAAA==.',['别龙']='别龙马:BAAALAAECgMIAwAAAA==.',['剑神']='剑神李淳罡:BAACLAAFFH8pAAIGAAcI9RqiBgDeAQAGAAcI9RqiBgDeAQAsAAQKfyUAAgYACAhGIMkNANcCAAYACAhGIMkNANcCAAAA.',['劣人']='劣人老张:BAAALAAECgEIAQAAAA==.',['勇敢']='勇敢牛牛:BAAALAAECgIIAgAAAA==.',['勤俭']='勤俭丶持家:BAAALAAECggIDAABLAAFFAgICAATADMeAA==.',['北梦']='北梦丶:BAAALAAFFAIIBAAAAA==.',['北离']='北离:BAAALAAECgUIBwAAAA==.',['十三']='十三阔少:BAABLAAFFH8NAAIGAAMI1hDZIQBsAAAGAAMI1hDZIQBsAAABLAAFFAYIHwANANIbAA==.',['千夜']='千夜丶:BAACLAAFFH8IAAMRAAIIUhW6GwBHAAAWAAEIYxJzIQBSAAARAAEIQhi6GwBHAAAsAAQKfy0AAxEACAiRHcwLAIMCABEACAieHMwLAIMCABYABggsGo8rAMgBAAAA.',['华丽']='华丽的火舞:BAAALAADCgQIBAAAAA==.',['卖帅']='卖帅到底:BAAALAAECgYICQAAAA==.',['南暮']='南暮丶:BAAALAAFFAIIBAAAAA==.',['南笙']='南笙丶:BAAALAAFFAIIAgAAAA==.',['只是']='只是杀你:BAAALAAECgYIDAAAAA==.',['可爱']='可爱的哈哈:BAAALAAECgEIAQAAAA==.',['可薆']='可薆小女孩:BAABLAAFFH8GAAIJAAYIHg1lQQBDAQAJAAYIHg1lQQBDAQAAAA==.',['史灬']='史灬珍香:BAABLAAFFH8FAAIFAAMIWQUSSwBsAAAFAAMIWQUSSwBsAAAAAA==.',['叶儿']='叶儿萌萌:BAABLAAFFH8IAAINAAIIYQ9qYABbAAANAAIIYQ9qYABbAAAAAA==.',['吃醋']='吃醋的胡萝卜:BAAALAAFFAYIBAAAAA==.',['名不']='名不经转:BAAALAAECgcICwAAAA==.',['名哲']='名哲:BAABLAAFFH8JAAIDAAII+RXPWACcAAADAAII+RXPWACcAAAAAA==.',['咕哒']='咕哒咕哒:BAACLAAFFH8OAAIXAAIIdSCGKQCYAAAXAAIIdSCGKQCYAAAsAAQKfyEAAxcACAh/F+YwABwCABcACAh/F+YwABwCABgABghNG5EUALEBAAAA.',['咕噜']='咕噜咕噜噜:BAAALAAECgEIAQAAAA==.',['咕就']='咕就是这样:BAAALAAECgIIAgAAAA==.',['咖喱']='咖喱土豆盖饭:BAABLAAFFH8GAAIJAAIInhquRgCdAAAJAAIInhquRgCdAAAAAA==.',['咥一']='咥一碗油泼面:BAAALAAECgIIAgAAAA==.',['哆啦']='哆啦松比:BAAALAAECgYIEgABLAAFFAIICAARAFIVAA==.',['哈丽']='哈丽雅:BAABLAAFFH8eAAIZAAYI6hxhBQD+AQAZAAYI6hxhBQD+AQAAAA==.',['哥就']='哥就一俗人:BAACLAAFFH8HAAIaAAMIEAJrGABCAAAaAAMIEAJrGABCAAAsAAQKfxcAAhoACAhRBr8fAL4AABoACAhRBr8fAL4AAAAA.',['善意']='善意的谎言:BAAALAAECgYIDQAAAA==.',['喵了']='喵了个喵:BAAALAAECgMIAwAAAA==.',['嗜血']='嗜血法医:BAAALAADCgYIBgAAAA==.',['四海']='四海龙王:BAAALAADCgYIBgAAAA==.',['回合']='回合:BAAALAAECgMIBwAAAA==.',['回首']='回首已漠然:BAAALAAECgQIBQAAAA==.',['图图']='图图:BAAALAAFFAIIBAAAAA==.',['圣光']='圣光术:BAAALAADCgYIBgAAAA==.圣光照耀夏天:BAABLAAFFH8ZAAIbAAYIYx6GBACjAQAbAAYIYx6GBACjAQAAAA==.',['圣钥']='圣钥:BAACLAAFFH8rAAMXAAgIGCO7AABGAwAXAAgIGCO7AABGAwAYAAEIOQK/LwA1AAAsAAQKfxUAAhcACAidJXcEAE8DABcACAidJXcEAE8DAAAA.',['地塞']='地塞米松:BAAALAADCggICQAAAA==.',['埃斯']='埃斯溜形:BAAALAAECgYIBgAAAA==.',['堕落']='堕落的毁灭:BAABLAAECn8bAAIKAAgI+xgNCwANAgAKAAgI+xgNCwANAgAAAA==.',['墨丶']='墨丶客:BAAALAAECgYIBgAAAA==.',['墨客']='墨客丶:BAABLAAECn8hAAMLAAgIXxQjYADkAQALAAgIXxQjYADkAQAKAAYImQcZYAD0AAAAAA==.',['壹岁']='壹岁丶很低调:BAAALAAECgYICAAAAA==.壹岁依然低调:BAAALAAECgYIBgAAAA==.',['夕丨']='夕丨丨四:BAABLAAECn8UAAIaAAcIvhJIHwCSAQAaAAcIvhJIHwCSAQAAAA==.',['夕丶']='夕丶四夫人:BAACLAAFFH8KAAIJAAIIPQ43ZACJAAAJAAIIPQ43ZACJAAAsAAQKfx8AAwkABghIGuKwAJQBAAkABghIGuKwAJQBABwABQjjDAp+AOIAAAAA.',['多吃']='多吃肉瘦得快:BAAALAAECgYIBgAAAA==.',['多肉']='多肉软软:BAAALAAECggIBwAAAA==.',['夜丶']='夜丶以烽:BAABLAAFFH8dAAQZAAUI6BCFDAArAQAZAAUI6BCFDAArAQAdAAQIABHJDQDcAAAPAAIIqQE4JAAhAAABLAAFFAYIHwANANIbAA==.',['大牛']='大牛大:BAABLAAFFH8RAAIDAAYI/RB/NABrAQADAAYI/RB/NABrAQAAAA==.',['大碗']='大碗丶鱼汤面:BAAALAAECgMIAwAAAA==.',['大腰']='大腰子:BAAALAAECgYIBgAAAA==.',['天堂']='天堂:BAABLAAFFH8IAAIFAAIIoBr3KAC3AAAFAAIIoBr3KAC3AAAAAA==.',['夳氼']='夳氼:BAAALAADCgYIBgAAAA==.',['奶糖']='奶糖布丁:BAABLAAECn8YAAMJAAcIoxcCVACcAQAJAAcIoxcCVACcAQAcAAEIJglCyAAoAAAAAA==.',['奶茶']='奶茶表:BAAALAAECgYIBgAAAA==.',['如穷']='如穷追一个梦:BAAALAAFFAIIBAAAAA==.',['委琐']='委琐的叛逆:BAABLAAFFH8FAAIFAAIIDgLZggAmAAAFAAIIDgLZggAmAAAAAA==.',['威武']='威武的汉子:BAAALAAFFAIIAwAAAA==.',['娃儿']='娃儿还小:BAAALAAECgYIBgAAAA==.',['娜利']='娜利亚:BAAALAADCgYIBgAAAA==.',['婉儿']='婉儿丶:BAABLAAFFH8XAAIJAAYIexReOABfAQAJAAYIexReOABfAQABLAAFFAYIHwANANIbAA==.',['婉婉']='婉婉喵丶:BAABLAAFFH8bAAIQAAcI7B5zAwCBAgAQAAcI7B5zAwCBAgAAAA==.',['安德']='安德鲁:BAAALAAFFAIIBAAAAA==.',['安捷']='安捷伦:BAAALAAFFAYIBAAAAA==.',['寂寞']='寂寞来袭:BAAALAAECgYIDAAAAA==.',['富美']='富美谢超:BAAALAADCggICAAAAA==.',['小叮']='小叮松比:BAACLAAFFH8IAAICAAIIiyKLLgDGAAACAAIIiyKLLgDGAAAsAAQKfy0ABAIACAhhIUweANYCAAIACAitIEweANYCAB4ABQhFFkgVAGoBABUAAQiGBIyhACUAAAAA.',['小可']='小可爱牛牛:BAABLAAFFH8GAAMTAAIIgx11NgCRAAATAAIIgx11NgCRAAASAAII/BIIIQCJAAAAAA==.',['小圆']='小圆宝:BAAALAADCggICgAAAA==.',['小妮']='小妮鹿鹿:BAAALAADCgMIAwAAAA==.',['小婉']='小婉呀丶:BAABLAAFFH8GAAMfAAII1hVUGACEAAAfAAII1hVUGACEAAAgAAIIgQdhHgB6AAAAAA==.小婉婉丶:BAAALAAFFAIIAgAAAA==.',['小术']='小术了术:BAAALAAECgQIBAAAAA==.',['小梦']='小梦林:BAABLAAFFH8GAAIQAAIIvwfTKgBiAAAQAAIIvwfTKgBiAAAAAA==.',['小法']='小法了法:BAAALAADCggICAAAAA==.',['小牙']='小牙:BAAALAAECgIIAgAAAA==.',['小猎']='小猎了猎:BAAALAAECgMIAwAAAA==.',['小电']='小电臀来咯:BAAALAAECgMIAwAAAA==.',['小萝']='小萝卜头:BAAALAAFFAIIAgAAAA==.',['小萨']='小萨了萨:BAAALAADCgYIBgAAAA==.',['小蝌']='小蝌蚪长大了:BAAALAAFFAIIBAAAAA==.',['小贼']='小贼了贼:BAAALAADCgIIAgAAAA==.',['小鬼']='小鬼别跑:BAAALAAECgEIAQAAAA==.',['小魔']='小魔了魔:BAAALAAECgEIAQAAAA==.',['就只']='就只能奶吗:BAAALAAECgQIBAAAAA==.',['就是']='就是拉的住:BAAALAAFFAIIAgAAAA==.',['尼采']='尼采的胡子:BAAALAAECgUICQAAAA==.',['山风']='山风眷眷:BAAALAAECgYIBgAAAA==.',['布德']='布德鸟:BAAALAAECgcIBwAAAA==.',['帝王']='帝王神话:BAAALAAECgMIBAAAAA==.',['带劣']='带劣人的毛虫:BAABLAAFFH8IAAIJAAYInRUIOQBdAQAJAAYInRUIOQBdAQABLAAFFAYIEwABAC8VAA==.',['幽光']='幽光一朵:BAAALAAFFAIIAgAAAA==.',['康爷']='康爷:BAAALAAFFAIIBAAAAA==.',['延静']='延静西里:BAAALAAECgYIBgAAAA==.',['廹钧']='廹钧:BAABLAAECn8WAAIZAAYIYgpuOADsAAAZAAYIYgpuOADsAAAAAA==.',['开门']='开门爸爸:BAAALAAECgYIDwAAAA==.',['式波']='式波飛鳥:BAAALAAFFAIIAgAAAA==.',['归来']='归来仍是少年:BAAALAAFFAIIAgAAAA==.',['彪某']='彪某:BAAALAAECgEIAQAAAA==.',['影歌']='影歌:BAAALAADCgYICwAAAA==.',['彼岸']='彼岸幽茗:BAABLAAFFH8OAAIDAAQIIxV+TgDtAAADAAQIIxV+TgDtAAABLAAFFAgICAAQAGQaAA==.',['德尔']='德尔丽斯塔奇:BAAALAAECggICQAAAA==.',['心成']='心成雪:BAABLAAFFH8SAAMXAAcIlyDYAwChAgAXAAcIlyDYAwChAgAYAAEIdQaOKwBAAAAAAA==.',['忧郁']='忧郁斩:BAAALAAECgYIBgAAAA==.',['怒火']='怒火攻心:BAAALAADCgYIBgAAAA==.',['怒送']='怒送一血:BAAALAAFFAIIAgAAAA==.',['恋恋']='恋恋不乖:BAAALAAECgQICAAAAA==.',['恐怖']='恐怖滑行者:BAAALAADCgYIBgAAAA==.',['恐龙']='恐龙别咬我:BAAALAAECgYICAAAAA==.',['情义']='情义丶:BAACLAAFFH8HAAILAAIIhhXGUwBIAAALAAIIhhXGUwBIAAAsAAQKfxgAAgsABgh2IZghAKMBAAsABgh2IZghAKMBAAEsAAUUCAgeAAsAPiEA.',['慢慢']='慢慢丶:BAAALAAFFAMIBAAAAA==.',['懂哥']='懂哥儿:BAABLAAFFH8GAAMDAAII6RGbYQCXAAADAAII6RGbYQCXAAAhAAIInAZzFQCBAAAAAA==.',['我不']='我不比你懂:BAAALAAFFAYIAgAAAA==.',['我叫']='我叫黑妹:BAAALAAECgEIAQAAAA==.',['我女']='我女朋友呢:BAAALAAECgEIAQAAAA==.',['我很']='我很伤感啊:BAAALAAECgYIEQAAAA==.',['战无']='战无天:BAABLAAFFH8MAAILAAYInRpaDAAGAgALAAYInRpaDAAGAgAAAA==.',['战神']='战神再现:BAAALAADCgYIBgAAAA==.',['扭扭']='扭扭先生:BAABLAAFFH8IAAIDAAgIvhucCwBDAgADAAgIvhucCwBDAgAAAA==.',['扶起']='扶起来还能打:BAABLAAFFH8QAAIFAAUIlRcgKQA1AQAFAAUIlRcgKQA1AQAAAA==.',['抹了']='抹了油的猪:BAAALAAFFAIIBAAAAA==.',['拉起']='拉起来还能打:BAAALAAECgYIBgAAAA==.',['拨云']='拨云吧:BAABLAAFFH8SAAIBAAYIoh3BFAC/AQABAAYIoh3BFAC/AQAAAA==.',['拽的']='拽的一比:BAAALAAECgMIAgAAAA==.',['搁浅']='搁浅丶:BAABLAAFFH8pAAMUAAgIRRsMBgBmAgAUAAgIRRsMBgBmAgANAAUIARqlEAA6AQAAAA==.搁浅丶一:BAABLAAFFH8GAAMNAAYINxOKLAAFAQANAAUIShGKLAAFAQAUAAEIRQZ3SQA+AAAAAA==.搁浅丶七:BAABLAAFFH8GAAMNAAYIOxQ3KwAOAQANAAUIQxI3KwAOAQAUAAEIdgRxSwA7AAAAAA==.搁浅丶三:BAABLAAFFH8IAAIUAAgIphuMBQB0AgAUAAgIphuMBQB0AgAAAA==.搁浅丶九:BAABLAAFFH8QAAMUAAgI9BeJBwBAAgAUAAgI9BeJBwBAAgANAAUIUhSjMQDlAAAAAA==.搁浅丶五:BAABLAAFFH8GAAMNAAYITBIrLgD7AAANAAUIBA8rLgD7AAAUAAEI2wJQTgA3AAAAAA==.搁浅丶八:BAABLAAFFH8GAAIUAAYIWxbcFwB/AQAUAAYIWxbcFwB/AQAAAA==.搁浅丶六:BAABLAAFFH8SAAMNAAYIKxQMFAAVAQANAAUIzhIMFAAVAQAUAAEIsQt8RABEAAAAAA==.搁浅丶十:BAABLAAFFH8OAAMUAAYI7BBjGwBlAQAUAAYI7BBjGwBlAQANAAUIVBgjLQABAQAAAA==.搁浅丶风:BAABLAAFFH8HAAMNAAUIdxXbNQDOAAANAAQIGxPbNQDOAAAUAAEIGgTjTQA4AAAAAA==.',['撒哈']='撒哈拉后羿:BAAALAAFFAIIAgAAAA==.',['旋转']='旋转虾:BAABLAAECn8oAAMNAAgI0BdwQAAdAgANAAgI0BdwQAAdAgAUAAUI/wEesgCTAAAAAA==.',['无上']='无上杀心:BAAALAAECgQIBAAAAA==.',['无情']='无情豆豆:BAAALAADCgEIAQAAAA==.',['无敌']='无敌哀木涕:BAAALAAFFAIIBAAAAA==.无敌纯爱贼神:BAABLAAFFH8HAAIWAAIIlQhoGwCRAAAWAAIIlQhoGwCRAAAAAA==.',['无糖']='无糖的冰豆花:BAAALAADCgIIAgAAAA==.',['既非']='既非不乖:BAABLAAFFH8HAAIJAAMIcwk9dwBxAAAJAAMIcwk9dwBxAAAAAA==.',['明哲']='明哲:BAABLAAFFH8MAAINAAUIMxJrKQAaAQANAAUIMxJrKQAaAQAAAA==.',['星橙']='星橙:BAACLAAFFH8JAAMSAAUIFB0QDgASAQASAAMIgyAQDgASAQATAAII2RVCOACLAAAsAAQKfxwAAhIACAh5JMwMAAoDABIACAh5JMwMAAoDAAAA.',['是正']='是正经骑士:BAACLAAFFH8HAAIFAAMIvwnhRwB8AAAFAAMIvwnhRwB8AAAsAAQKf0kAAwUACAh1GPghABICAAUACAh1GPghABICABsAAwghBqI4AGoAAAAA.',['晴时']='晴时霁无霞:BAAALAAECggICAAAAA==.',['暗夜']='暗夜小丸子:BAAALAADCgIIAgAAAA==.',['暗影']='暗影魅:BAAALAAECgYIBgAAAA==.',['暴走']='暴走的悦悦:BAAALAADCgEIAQAAAA==.',['曼斯']='曼斯坦因:BAAALAAFFAQIBAAAAA==.',['最佳']='最佳情人:BAAALAADCgQIBgAAAA==.',['最后']='最后一口乃:BAAALAADCgYIBgAAAA==.',['月亮']='月亮浮空岛:BAABLAAFFH8JAAMSAAYIJQ0yGgAGAQASAAUIiA4yGgAGAQATAAQIbQLrWQA8AAAAAA==.',['月似']='月似琉璃:BAABLAAFFH8GAAICAAMIOxeKRwCkAAACAAMIOxeKRwCkAAAAAA==.',['月半']='月半小夜曲:BAAALAAECgYICwAAAA==.月半月半白勺:BAAALAAECgYIBgAAAA==.',['月狮']='月狮夏洛特:BAAALAAECgYIBwAAAA==.',['月舞']='月舞清影:BAAALAADCgcICwAAAA==.',['有点']='有点小帅:BAAALAAECgYICgAAAA==.',['末日']='末日狂牛:BAAALAAECgYIBgAAAA==.',['本土']='本土人:BAAALAADCgEIAQAAAA==.',['杰瑞']='杰瑞扛刀追猫:BAAALAADCgYICQAAAA==.',['枝弟']='枝弟:BAAALAADCgMIAwAAAA==.',['枝爷']='枝爷:BAAALAADCgUIBQAAAA==.',['枫月']='枫月白:BAAALAAECgQICwAAAA==.',['柑蕉']='柑蕉桔梨籮柚:BAAALAAECgcIBwABLAAFFAgIKwAJAF4iAA==.',['柠檬']='柠檬麦旋风:BAAALAAFFAIIBAAAAA==.',['核动']='核动力:BAABLAAFFH8NAAMUAAcIHR44CAAvAgAUAAcIHR44CAAvAgANAAYIEhOLHAB4AQAAAA==.',['格兰']='格兰蒂捏:BAAALAADCgQIBAAAAA==.',['桂花']='桂花下酒:BAAALAAFFAIIBAAAAA==.',['梓诺']='梓诺:BAAALAAFFAIIAgAAAA==.',['楚悬']='楚悬黎:BAABLAAFFH8TAAIXAAMIjx6mFAAFAQAXAAMIjx6mFAAFAQAAAA==.',['止于']='止于初见:BAAALAAFFAIIAgAAAA==.',['此乃']='此乃妖孽:BAACLAAFFH8JAAIUAAQIyQSDFAAYAQAUAAQIyQSDFAAYAQAsAAQKfx8AAxQACAh6HPQlAIMCABQACAh6HPQlAIMCAA0ABAiMAXcuAVUAAAAA.',['步履']='步履不停:BAABLAAECn8kAAMhAAgIPhbOCQCdAQAhAAgIPhbOCQCdAQADAAMIXRJoXwGjAAAAAA==.',['武之']='武之禅:BAACLAAFFH8QAAIPAAMIEgnWEAChAAAPAAMIEgnWEAChAAAsAAQKfykAAw8ACAiaFgIYAPABAA8ACAiaFgIYAPABAB0AAQhmDJFvACgAAAAA.',['死老']='死老太婆:BAAALAAECggICAAAAA==.',['比吧']='比吧卡彭:BAAALAAECgYIBgAAAA==.',['毕姥']='毕姥爷:BAAALAAECgIIAgAAAA==.',['氯沙']='氯沙坦钾:BAAALAAECgYIDAAAAA==.',['水水']='水水的法神:BAAALAAFFAIIBAAAAA==.',['水澹']='水澹澹:BAAALAADCgYIBgAAAA==.',['氵渲']='氵渲染灬:BAAALAAFFAIIAgABLAAFFAMICwANAL0NAA==.',['池中']='池中莉莉安:BAAALAADCgQIBwAAAA==.',['油泼']='油泼菠菜面:BAAALAADCgYICAAAAA==.',['法一']='法一:BAAALAAECgEIAQAAAA==.',['泡椒']='泡椒:BAAALAAFFAIIAgAAAA==.',['洛汉']='洛汉:BAAALAAFFAIIAgAAAA==.',['活德']='活德有尊严:BAAALAAFFAEIAQAAAA==.',['派小']='派小爹:BAAALAAECgYIAgAAAA==.',['流氓']='流氓兔:BAAALAAECgEIAQAAAA==.',['浮长']='浮长川而忘返:BAAALAAFFAIIAgAAAA==.',['海雅']='海雅谷慕:BAAALAAECgcIEQAAAA==.',['清爽']='清爽丶凉茶:BAAALAAFFAIIAgAAAA==.',['温蕾']='温蕾萨:BAABLAAFFH8MAAQJAAYI4hveJQCcAQAJAAYIvRveJQCcAQAiAAQIPBULAgD9AAAcAAIIBwmgDwB/AAAAAA==.',['湛蓝']='湛蓝:BAAALAAECgYIBgAAAA==.',['溜溜']='溜溜球儿:BAACLAAFFH8XAAINAAUILBZrDwBJAQANAAUILBZrDwBJAQAsAAQKfxkAAg0ACAhXGCRLAP4BAA0ACAhXGCRLAP4BAAAA.',['满心']='满心皆是你:BAAALAAFFAIIAgAAAA==.',['漓洛']='漓洛:BAAALAAECgYIBgAAAA==.',['灬无']='灬无灬聊灬:BAABLAAFFH8IAAIXAAMI8g+XLwCuAAAXAAMI8g+XLwCuAAAAAA==.',['烈女']='烈女不怕死:BAABLAAFFH8GAAMjAAIIzxpWAwCpAAAjAAIIzxpWAwCpAAAHAAEIXA4TUgBMAAAAAA==.',['焰灵']='焰灵姬:BAACLAAFFH8KAAIFAAIInBZyWwBJAAAFAAIInBZyWwBJAAAsAAQKfyoAAgUABghgHm46AK4BAAUABghgHm46AK4BAAAA.',['燕三']='燕三少:BAABLAAFFH8RAAMFAAYI0xDgHQB1AQAFAAYIvA/gHQB1AQAbAAMIOA6MEQBoAAABLAAFFAYIHwANANIbAA==.',['爱在']='爱在七块钱:BAAALAAECggIBAAAAA==.爱在两块钱:BAAALAAECggIEAAAAA==.爱在五块钱:BAAALAAECggICAAAAA==.爱在八块钱:BAAALAAECggICgAAAA==.爱在六块钱:BAAALAAECgEIAQAAAA==.',['版纳']='版纳西红柿:BAAALAADCgYIBgAAAA==.',['牙长']='牙长先生的:BAAALAAECgQIBAAAAA==.',['牛光']='牛光异彩:BAAALAADCgcIBwAAAA==.牛光逸彩:BAAALAADCgMIAwAAAA==.',['牛油']='牛油果:BAAALAADCgQIBAAAAA==.',['牛牛']='牛牛大:BAABLAAFFH8GAAIaAAYIbg6NDABEAQAaAAYIbg6NDABEAQAAAA==.',['狂舞']='狂舞曲:BAAALAAFFAIIAgAAAA==.',['狐依']='狐依依:BAAALAAFFAIIAgAAAA==.',['狐匪']='狐匪:BAAALAAECgYIDQAAAA==.',['独小']='独小爱:BAABLAAFFH8HAAIJAAQIdQ4eXgDNAAAJAAQIdQ4eXgDNAAAAAA==.',['独狼']='独狼啸月:BAAALAAECgYIDQAAAA==.',['玄光']='玄光宝刀:BAABLAAFFH8GAAMjAAII6RL8BQA+AAAjAAII6RL8BQA+AAAGAAIIogJfOQAlAAAAAA==.',['玉藻']='玉藻前:BAAALAAECgIIAgAAAA==.',['玛格']='玛格汉之魂:BAAALAAECggICAAAAA==.',['璃洛']='璃洛:BAAALAAFFAIIBAAAAA==.',['用脚']='用脚抠:BAAALAADCgIIAgAAAA==.',['疯标']='疯标:BAAALAAECgIIAgAAAA==.',['登高']='登高岭炮象:BAAALAAECgYIBgAAAA==.',['白帽']='白帽子:BAAALAAECgYIEQAAAA==.',['白楓']='白楓:BAAALAAECgQIBgAAAA==.',['盲僧']='盲僧也用刀:BAABLAAFFH8GAAIBAAYIbRvlEgDLAQABAAYIbRvlEgDLAQAAAA==.',['眼睛']='眼睛瞎了:BAABLAAECn8WAAIUAAYIDBC/bwBtAQAUAAYIDBC/bwBtAQAAAA==.',['瞄人']='瞄人丶缝:BAAALAAECgEIAQAAAA==.',['瞳影']='瞳影微蓝:BAAALAAECgcICgAAAA==.',['神奇']='神奇的小武僧:BAAALAAECggIDAAAAA==.',['神密']='神密嘉嘉:BAACLAAFFH8LAAILAAIIRhkOPACkAAALAAIIRhkOPACkAAAsAAQKfx4AAwsACAjXIqslALYCAAsACAhrIaslALYCAAoABgjUFBY6AIwBAAAA.',['神斗']='神斗士吕布:BAAALAAFFAIIAgAAAA==.',['秀水']='秀水无痕:BAACLAAFFH8eAAITAAUIYBMfGwBUAQATAAUIYBMfGwBUAQAsAAQKfzUAAxMACAg4ISIKAKcCABMACAg4ISIKAKcCABIAAQj8ChxlACsAAAAA.秀水无痕三世:BAAALAAECgYIDQAAAA==.秀水无痕二世:BAABLAAFFH8TAAINAAUIoBXFIQBQAQANAAUIoBXFIQBQAQAAAA==.',['秋水']='秋水仙碱:BAAALAAECgYIDAAAAA==.',['空條']='空條承太郎:BAAALAAFFAEIAQAAAA==.',['空谷']='空谷残声:BAAALAAFFAIIAgABLAAFFAYIFwALAIAiAA==.',['立丶']='立丶青:BAAALAAECgYIBwAAAA==.',['竹里']='竹里名日香:BAAALAAECgYICgAAAA==.',['笃行']='笃行致远:BAAALAADCgMIAwAAAA==.',['等着']='等着我家老熊:BAAALAAECgYIDQAAAA==.',['筱筱']='筱筱小小:BAAALAAECggICAAAAA==.',['粗壮']='粗壮壮:BAAALAAFFAIIAgAAAA==.',['纳兰']='纳兰帅哥:BAABLAAFFH8LAAIBAAIIhgR+XQB4AAABAAIIhgR+XQB4AAAAAA==.',['终结']='终结一箭:BAAALAAECgYICAABLAAECggICgAkAAAAAA==.',['绝世']='绝世的爵士:BAABLAAECn8ZAAIJAAYIKgmW3QDDAAAJAAYIKgmW3QDDAAAAAA==.',['维纳']='维纳斯里卡特:BAAALAADCgYIBgAAAA==.',['绿肤']='绿肤兜兜:BAACLAAFFH8hAAMNAAcIWxRJDQBqAQANAAcIWxRJDQBqAQAUAAEIcAIeUwAtAAAsAAQKfxsAAg0ACAjUGt1BABgCAA0ACAjUGt1BABgCAAAA.',['缡洛']='缡洛:BAAALAAFFAIIBAAAAA==.',['美景']='美景:BAAALAAECgIIAwAAAA==.',['羽少']='羽少真跑了:BAABLAAECn8rAAMJAAYIfSSPQQBiAgAJAAYIfSSPQQBiAgAcAAYI3xiXRACjAQAAAA==.',['翫暗']='翫暗恋:BAAALAAECgUIBQAAAA==.',['老兵']='老兵不死:BAAALAAECgUIBwAAAA==.',['老哥']='老哥别冰我:BAAALAAFFAIIBAAAAA==.老哥别锤我:BAAALAAFFAMIAwAAAA==.',['老婆']='老婆大人:BAAALAAECgcIDQAAAA==.',['老弓']='老弓啊:BAAALAAECgQIBAAAAA==.',['耶罗']='耶罗:BAAALAADCgcICQAAAA==.',['肉肉']='肉肉零零:BAAALAAECggICAAAAA==.',['胃卜']='胃卜鲜汁:BAAALAAECgUICgAAAA==.',['胡椒']='胡椒虾:BAAALAADCggIDQAAAA==.',['自然']='自然变:BAAALAADCgIIAwAAAA==.',['良辰']='良辰丶好景:BAAALAAECgMIAwAAAA==.',['芝士']='芝士墨鱼烧:BAABLAAFFH8KAAILAAgIoBM8CwAyAgALAAgIoBM8CwAyAgAAAA==.',['芝麻']='芝麻狐:BAAALAAECgMIAwABLAAFFAIIAgAkAAAAAA==.',['芥末']='芥末虾球:BAAALAAECgYICgAAAA==.',['花儿']='花儿丶飘飘:BAABLAAFFH80AAIYAAcIUyJYBAA5AgAYAAcIUyJYBAA5AgAAAA==.',['花将']='花将军:BAAALAAECgEIAQAAAA==.',['花差']='花差花差:BAAALAAECgYICwAAAA==.',['花生']='花生:BAAALAAECgYIDwAAAA==.花生两:BAAALAADCggICQAAAA==.',['苏容']='苏容蓉:BAAALAAECgYIBgAAAA==.',['苏笑']='苏笑:BAAALAAECgYIBgAAAA==.',['英豪']='英豪之嘉:BAABLAAFFH8GAAIFAAII7h9wLQCvAAAFAAII7h9wLQCvAAAAAA==.',['范思']='范思哲丶:BAABLAAFFH8KAAIHAAYISR66AwBkAgAHAAYISR66AwBkAgABLAAFFAgIFwAFAG8eAA==.',['茅山']='茅山大仙:BAAALAAECgYICAAAAA==.',['菜鸟']='菜鸟太白:BAAALAAECgYIBgAAAA==.菜鸟摩诘:BAAALAAECgYIDAAAAA==.',['菠萝']='菠萝油条虾:BAAALAAFFAIIAgAAAA==.',['萌萌']='萌萌哒吆:BAAALAAECgUIBQAAAA==.萌萌尛牙医:BAABLAAECn8aAAMJAAYIDxL/pQASAQAJAAYIpxH/pQASAQAcAAQIpwnDmgCFAAAAAA==.',['萌面']='萌面糙人:BAAALAADCgEIAgAAAA==.',['萨了']='萨了也不满:BAAALAAECgcIDQAAAA==.',['蒲窂']='蒲窂:BAAALAAECgQIBAAAAA==.',['蔚蓝']='蔚蓝战歌:BAAALAAECgIIAgAAAA==.',['蕾丝']='蕾丝花边条纹:BAAALAADCgEIAQAAAA==.',['虐爆']='虐爆焦儿圈儿:BAAALAAECgIIAgAAAA==.',['虽远']='虽远必诛:BAAALAAECgMIAwAAAA==.',['蛋天']='蛋天帝:BAABLAAFFH8LAAMUAAYITCHZDQDXAQAUAAYITCHZDQDXAQANAAIIWAb1cQBIAAAAAA==.',['蜜之']='蜜之死騎:BAAALAADCggICAAAAA==.蜜之猎手:BAAALAADCgYIBgAAAA==.',['血小']='血小牛:BAAALAAECggICAAAAA==.',['血月']='血月乂堕翼:BAABLAAFFH8GAAIJAAYIyQ6LSQAnAQAJAAYIyQ6LSQAnAQAAAA==.血月乂红唇:BAAALAAECgQIBAAAAA==.',['血色']='血色小母牛:BAAALAADCgQIBAAAAA==.血色黄昏:BAABLAAFFH8UAAIQAAgIpSOQAAA5AwAQAAgIpSOQAAA5AwAAAA==.',['血顶']='血顶天:BAABLAAFFH8GAAIQAAYIgRXnDQCoAQAQAAYIgRXnDQCoAQAAAA==.',['行走']='行走的万艾可:BAAALAAECgEIAQAAAA==.行走的荷尔蒙:BAAALAAECgYIBwAAAA==.',['街边']='街边一炮手:BAAALAAFFAMIAwAAAA==.',['表白']='表白:BAACLAAFFH8WAAILAAYIfAtrKgDpAAALAAYIfAtrKgDpAAAsAAQKfxoABAsACAjEHIU7AFwCAAsACAiTHIU7AFwCAAwABAivEMARAPIAAAoAAQh1GFGNAEIAAAAA.',['西瓜']='西瓜西瓜:BAABLAAFFH8KAAILAAIItBXVPwCgAAALAAIItBXVPwCgAAAAAA==.',['要么']='要么庸俗:BAAALAAECgEIAQAAAA==.',['见青']='见青山:BAAALAAFFAIIBAAAAA==.',['观云']='观云丶端:BAABLAAFFH8IAAIJAAYI7hqsCQDxAQAJAAYI7hqsCQDxAQAAAA==.',['认真']='认真上班:BAAALAAECgYICAAAAA==.',['试玩']='试玩近战:BAAALAAECgYIDAAAAA==.',['说三']='说三:BAABLAAECn8iAAQbAAgIJBzJDwCJAgAbAAgI9xvJDwCJAgAQAAYIFhPgOgB3AQAFAAII+RqcSAGfAAAAAA==.',['说盯']='说盯咱就盯:BAAALAAECgEIAQAAAA==.',['谕緈']='谕緈:BAAALAAECgQIBQAAAA==.',['谢超']='谢超三号:BAAALAADCgIIAgAAAA==.谢超二号:BAAALAADCggICwAAAA==.',['谭天']='谭天钤元:BAABLAAFFH8NAAIUAAYIbQGaNgCDAAAUAAYIbQGaNgCDAAAAAA==.',['豆包']='豆包:BAAALAAECgYICQAAAA==.',['超级']='超级婉婉:BAABLAAFFH8YAAUSAAYIpAtnGwD6AAASAAUI2gpnGwD6AAAlAAMI8ww3CQBWAAATAAMIYAXmVQBJAAAIAAEIFQR/EwAAAAABLAAFFAYIHwANANIbAA==.超级正经:BAAALAAFFAIIBAAAAA==.',['超自']='超自信五胖:BAAALAAECggICAAAAA==.',['路人']='路人杀:BAAALAAECgQIBAAAAA==.',['路過']='路過瑾年丶:BAABLAAFFH8KAAIBAAMIuxmAPACbAAABAAMIuxmAPACbAAAAAA==.',['跳跳']='跳跳妈:BAAALAAECgIIAgAAAA==.',['踩着']='踩着我家老熊:BAAALAAECgYIEwAAAA==.',['辉煌']='辉煌哀殇:BAAALAAECgYIBwAAAA==.',['输出']='输出不够:BAAALAAFFAIIAgAAAA==.',['辰靖']='辰靖丶:BAAALAAECgYIEQAAAA==.',['迈巴']='迈巴赫:BAAALAAECgYIDQAAAA==.',['还是']='还是苝哥哥:BAAALAAECgYIDAAAAA==.',['迪迦']='迪迦小红手:BAAALAADCgcIBwAAAA==.',['迷失']='迷失之泪:BAAALAAFFAMIAwAAAA==.',['逍遥']='逍遥丶獵:BAAALAAECggICgAAAA==.',['道四']='道四:BAAALAADCggICAAAAA==.',['遗失']='遗失牛牛:BAABLAAFFH8HAAITAAIIKAOFSABTAAATAAIIKAOFSABTAAAAAA==.',['那武']='那武僧:BAAALAAECgEIAQAAAA==.',['那那']='那那边:BAAALAAECgIIAwAAAA==.',['酒醉']='酒醉误事:BAAALAAECgEIAQAAAA==.',['酒馆']='酒馆第一深情:BAACLAAFFH8GAAILAAIImAYyYQB4AAALAAIImAYyYQB4AAAsAAQKfxcAAwsABwhxEkt4AKUBAAsABwhxEkt4AKUBAAoABAgMDDlyAKMAAAAA.',['醉舞']='醉舞经阁:BAABLAAFFH8JAAMTAAYIChF+IwABAQATAAUIDg1+IwABAQASAAEIOgEvQAAiAAAAAA==.',['金坷']='金坷垃的逆袭:BAAALAAECgYIDAAAAA==.',['钰煌']='钰煌汏偙:BAAALAADCgIIAwAAAA==.',['铜绿']='铜绿假单胞菌:BAAALAAFFAQIBAAAAA==.',['闪亮']='闪亮丶朵朵:BAABLAAFFH8IAAMcAAII3xYkJAB/AAAJAAIIvxK5YACLAAAcAAIIXBMkJAB/AAAAAA==.',['闷墩']='闷墩儿丿:BAAALAAECgIIAgAAAA==.',['阿丶']='阿丶拉蕾:BAAALAAFFAIIAgAAAA==.',['阿利']='阿利斯塔牛牛:BAAALAAFFAIIAgAAAA==.',['阿米']='阿米子:BAABLAAFFH8IAAICAAIIhBDCQACXAAACAAIIhBDCQACXAAAAAA==.',['陈丶']='陈丶果冻布丁:BAACLAAFFH8NAAINAAIIGBpkSACOAAANAAIIGBpkSACOAAAsAAQKfx0AAg0ABwhdF5AyAJYBAA0ABwhdF5AyAJYBAAAA.',['雨霖']='雨霖铃:BAACLAAFFH8GAAIFAAIIeR44VgBMAAAFAAIIeR44VgBMAAAsAAQKfxwAAgUABgiLII+EAOQBAAUABgiLII+EAOQBAAAA.',['雪姨']='雪姨:BAAALAAECgYICwABLAAFFAgIAQAkAAAAAA==.',['雾寻']='雾寻:BAAALAAECgYICQAAAA==.',['霜刃']='霜刃影歌:BAAALAAECgUICQAAAA==.',['露比']='露比莉亚丝:BAABLAAFFH8HAAIQAAcIiQ2CDQCuAQAQAAcIiQ2CDQCuAQAAAA==.',['霸都']='霸都才子:BAABLAAFFH8GAAIFAAII8gd6cgA9AAAFAAII8gd6cgA9AAAAAA==.霸都财子:BAABLAAFFH8OAAIHAAQIngbYMgCvAAAHAAQIngbYMgCvAAAAAA==.',['顾逆']='顾逆:BAAALAAECgYIBwAAAA==.',['風中']='風中淩亂:BAAALAAECgQICQAAAA==.',['风之']='风之心:BAAALAAECgYICwAAAA==.',['风口']='风口浪尖:BAAALAAECgIIAwAAAA==.',['飞火']='飞火流殇:BAAALAADCgUIBQAAAA==.',['香蕉']='香蕉不软:BAAALAAFFAIIAgAAAA==.',['骑土']='骑土:BAAALAAECgYIBgAAAA==.',['骑士']='骑士死亡:BAABLAAFFH8GAAIDAAII3wkAkQA+AAADAAII3wkAkQA+AAAAAA==.',['魄力']='魄力:BAAALAAECgYIEQAAAA==.',['魄箜']='魄箜:BAAALAAECgYIDQAAAA==.',['魔魔']='魔魔舞曲:BAAALAAECggICAAAAA==.',['鲜肉']='鲜肉小笼宝:BAACLAAFFH8GAAIQAAIIOSBpFAC7AAAQAAIIOSBpFAC7AAAsAAQKfyMABBAABgh9IuEZAD8CABAABgh9IuEZAD8CABsABgioGMQsAKUBAAUAAghzG1hQAY8AAAAA.',['鲜邪']='鲜邪:BAAALAAECgYICgAAAA==.',['鹿森']='鹿森森丶:BAABLAAFFH8GAAIHAAYIswXWLQDuAAAHAAYIswXWLQDuAAAAAA==.',['鹿茸']='鹿茸菌:BAABLAAECn8gAAIIAAgIuxtGDQB5AgAIAAgIuxtGDQB5AgAAAA==.',['麦瑞']='麦瑞蜜:BAAALAADCgcIBwAAAA==.',['麦迪']='麦迪格文:BAAALAAECgMIAwAAAA==.',['黑牛']='黑牛宝宝:BAABLAAFFH8KAAIHAAIIrQ4WOQCVAAAHAAIIrQ4WOQCVAAAAAA==.',['龍魂']='龍魂泣:BAAALAADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end