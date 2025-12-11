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
 local lookup = {'DeathKnight-Frost','Warrior-Fury','Evoker-Devastation','Evoker-Preservation','Hunter-BeastMastery','Priest-Holy','Priest-Shadow','Shaman-Restoration','Shaman-Elemental','Mage-Frost','Druid-Balance','DemonHunter-Havoc','Rogue-Outlaw','DemonHunter-Vengeance','Paladin-Holy','Priest-Discipline','Paladin-Retribution','Mage-Arcane','Mage-Fire','Druid-Restoration','Warlock-Demonology','Hunter-Marksmanship','Rogue-Assassination','Warlock-Destruction','Monk-Mistweaver','Monk-Windwalker','DeathKnight-Blood','Warlock-Affliction','DeathKnight-Unholy','Hunter-Survival','Monk-Brewmaster','Paladin-Protection','Druid-Guardian','Warrior-Protection',}; local provider = {region='CN',realm='永夜港',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alka:BAABLAAFFH8GAAIBAAIIygXBmABVAAABAAIIygXBmABVAAAAAA==.Aluka:BAAALAAFFAIIAgAAAA==.',An='Anlk:BAAALAAECgcIDwAAAA==.',Ar='Argus:BAAALAAECgYIAgAAAA==.',As='Asahi:BAAALAAECgYIEwAAAA==.Asili:BAAALAAECgYIDAAAAA==.',Ba='Backstorm:BAAALAAECgYIBgAAAA==.',Bl='Bladesong:BAAALAAFFAIIAgAAAA==.',Ca='Camaro:BAAALAADCgMIAwAAAA==.',Ce='Cecilia:BAAALAAECgIIAgAAAA==.',Ch='Chuchu:BAAALAADCgIIAgAAAA==.',Co='Constantin:BAAALAAECgYIDQAAAA==.',Da='Danisi:BAAALAADCgcIBwAAAA==.',De='Defthands:BAAALAAECgQIBAAAAA==.',Ed='Eden:BAAALAAECgMIAwAAAA==.',Fo='Forthehorde:BAAALAAECgUIBQAAAA==.',Ge='Gertrude:BAABLAAFFH8MAAICAAYINhHGHwBtAQACAAYINhHGHwBtAQAAAA==.',Hy='Hyzf:BAAALAADCgcIBwAAAA==.',Il='Illida:BAAALAAECgYIAwAAAA==.',Jy='Jyona:BAACLAAFFH8fAAMDAAcIUR/nBQDbAQADAAUISx7nBQDbAQAEAAYIQBf4CgCkAQAsAAQKfzEAAwMACAiKI24HABsDAAMACAiKI24HABsDAAQABggXHdoRADMBAAAA.',Ka='Kassidy:BAAALAADCgYICgAAAA==.',Kl='Klanklang:BAAALAAECgEIAQAAAA==.',Kr='Kraven:BAABLAAFFH8GAAIFAAYIzB9eGwDGAQAFAAYIzB9eGwDGAQAAAA==.',La='Landino:BAAALAAECgYIDAAAAA==.',Lc='Lce:BAAALAAECgYIDwAAAA==.',Le='Leslie:BAAALAADCggICAABLAAFFAcIJgAGAGURAA==.',Lu='Ludis:BAAALAAFFAIIAgAAAA==.Lulala:BAAALAADCgIIAgAAAA==.',Ma='Magirus:BAAALAAECgIIAwAAAA==.',['Má']='Mándala:BAAALAADCggICAAAAA==.',Ni='Ninthmoon:BAABLAAECn8XAAIHAAYIVx4yNwDmAQAHAAYIVx4yNwDmAQAAAA==.',Or='Orijen:BAAALAAECgUIBQAAAA==.',Ou='Ousi:BAACLAAFFH8GAAMIAAIIMwgeawBQAAAIAAIIMwgeawBQAAAJAAIIswhuUgAuAAAsAAQKfxYAAwgABggFHSAiAO0BAAgABggFHSAiAO0BAAkABgh7FuwzAEEBAAAA.',Pr='Provence:BAACLAAFFH8GAAIKAAIIzgcSHQA3AAAKAAIIzgcSHQA3AAAsAAQKfxwAAgoABgjzEz0/AHQBAAoABgjzEz0/AHQBAAAA.',Ss='Ssksk:BAAALAADCgIIAgAAAA==.',Ta='Tainiya:BAAALAAECgYIDAAAAA==.',Vi='Vijiniya:BAACLAAFFH8GAAIGAAIIthnINQCNAAAGAAIIthnINQCNAAAsAAQKfxUAAwYABggaImoRAEcCAAYABggaImoRAEcCAAcABghQDBBhADQBAAAA.',Ya='Yaphetschen:BAAALAAECgYIEQAAAA==.',Zh='Zhounuer:BAAALAAECgYICAAAAA==.',Zo='Zorya:BAAALAAECgYIDAAAAA==.',['一生']='一生的缘:BAAALAAECgYIDAAAAA==.',['一眼']='一眼云烟:BAAALAADCggICAAAAA==.',['一闷']='一闷棍闷死你:BAAALAADCggICAAAAA==.',['上古']='上古男污尸丶:BAAALAADCgYICQAAAA==.',['不知']='不知道取啥:BAAALAADCgMIAwAAAA==.',['不講']='不講武德:BAABLAAFFH8OAAILAAYIAAfnGAARAQALAAYIAAfnGAARAQABLAAFFAgIIgAMAGEcAA==.',['不足']='不足为骑:BAAALAADCggIDQAAAA==.',['丨影']='丨影子丨:BAAALAADCggICAAAAA==.',['临行']='临行莫回头:BAAALAADCgIIAgAAAA==.',['乐迪']='乐迪:BAAALAAECgcICQAAAA==.',['九蓝']='九蓝镜水月:BAAALAAECgUIBQAAAA==.',['乡音']='乡音:BAAALAAECgYICQABLAAFFAYIDwANALIVAA==.',['云依']='云依:BAAALAAECgYIBgAAAA==.',['伊利']='伊利达雷站长:BAACLAAFFH8MAAIMAAIIyR0oMACpAAAMAAIIyR0oMACpAAAsAAQKfxcAAgwABwhhH7w9AGoCAAwABwhhH7w9AGoCAAAA.',['伯拉']='伯拉勒斯领主:BAAALAAFFAIIAgAAAA==.',['佑圣']='佑圣灵应真君:BAAALAAECgIIAgAAAA==.',['你可']='你可没有永恒:BAAALAAFFAIIAgAAAA==.',['依利']='依利丹怒风:BAACLAAFFH8LAAIMAAUIkBnHJABmAQAMAAUIkBnHJABmAQAsAAQKfxcAAwwABgg1G2M2AH8BAAwABgg1G2M2AH8BAA4AAwg0A9MpAE0AAAAA.',['信仰']='信仰之盾:BAAALAAECgMIAwAAAA==.',['倾城']='倾城之恋:BAAALAAECgQIBAAAAA==.',['偷偷']='偷偷打断:BAACLAAFFH8nAAIPAAgISh81AQAEAwAPAAgISh81AQAEAwAsAAQKfxUAAg8ACAiCI1cFABIDAA8ACAiCI1cFABIDAAAA.',['傲天']='傲天霸:BAAALAAECgQIBAAAAA==.',['光明']='光明圣堂勇士:BAAALAADCgMIAwAAAA==.',['光焰']='光焰使徒:BAAALAAECgMIAwAAAA==.',['克雷']='克雷斯弗:BAAALAAECgYIDgAAAA==.',['兜兜']='兜兜里有光:BAAALAAECgYIDwAAAA==.',['八筒']='八筒:BAAALAAECgcIDAAAAA==.',['冰丶']='冰丶鼬:BAAALAAFFAIIAgAAAA==.',['冰之']='冰之封印:BAAALAAECgUICAAAAA==.',['凉风']='凉风有信:BAAALAADCgIIAgAAAA==.',['凛冬']='凛冬:BAAALAAFFAEIAQAAAA==.',['凤求']='凤求凰凰:BAABLAAECn8UAAMQAAYIvxvdBQDkAQAQAAYIvxvdBQDkAQAGAAYIwQSHSwCpAAAAAA==.',['凤盏']='凤盏:BAAALAAFFAIIAgAAAA==.',['凯丶']='凯丶丶勒:BAAALAAECgMIAwAAAA==.',['凯勒']='凯勒会冲锋:BAAALAAECgMIAwAAAA==.',['凹凹']='凹凹酱:BAAALAAECgYIBgAAAA==.',['刀大']='刀大美女多:BAAALAADCgUIBQAAAA==.',['加勒']='加勒比海藻:BAAALAAECgYICwAAAA==.',['包大']='包大侠:BAAALAADCgYICQAAAA==.',['北野']='北野武:BAAALAAECgYIBgAAAA==.',['千山']='千山丶鳥飞绝:BAAALAAECgYIBwAAAA==.千山丶鸟飛绝:BAAALAAFFAIIAgAAAA==.千山丿鸟飞绝:BAAALAAFFAIIAgABLAAFFAgIKwAPAE8dAA==.千山鸟飞绝:BAAALAAFFAIIAgAAAA==.',['卡文']='卡文迪什:BAABLAAECn8VAAIRAAgIiBsIMgDLAQARAAgIiBsIMgDLAQAAAA==.',['又歇']='又歇菜了:BAAALAADCgQIBAAAAA==.',['可我']='可我想你了:BAABLAAFFH8KAAMSAAMI2BfgJgD4AAASAAMI2BfgJgD4AAATAAEILgccDQBGAAAAAA==.',['可爱']='可爱遥遥:BAAALAADCgcICwAAAA==.',['叶序']='叶序:BAACLAAFFH8PAAINAAYIshVuAQCRAQANAAYIshVuAQCRAQAsAAQKfzQAAg0ACAiwJCIBAEQDAA0ACAiwJCIBAEQDAAAA.',['吕小']='吕小布丶:BAAALAAECggICAABLAAFFAgICAAUAL8fAA==.',['吾皇']='吾皇万睡:BAAALAAECgYIEgAAAA==.',['咕咕']='咕咕冠军:BAABLAAFFH8IAAILAAYIXhDkEgBQAQALAAYIXhDkEgBQAQAAAA==.',['哈基']='哈基米曼波:BAACLAAFFH8VAAIVAAUIMyNAAgCFAQAVAAUIMyNAAgCFAQAsAAQKf0AAAhUACAgIJnMAAA8DABUACAgIJnMAAA8DAAAA.',['哈底']='哈底斯:BAAALAADCgYIBwAAAA==.',['哥只']='哥只是个传说:BAAALAAECgYIBwAAAA==.',['喜阳']='喜阳阳:BAAALAADCgYICgAAAA==.',['噼梨']='噼梨吧啦:BAAALAAECggIDgAAAA==.',['圣光']='圣光永存:BAAALAAECgYICwAAAA==.圣光骑士:BAAALAAFFAIIAgAAAA==.',['地狱']='地狱火的爪子:BAAALAADCgQIBAAAAA==.',['埃辛']='埃辛诺斯盲眼:BAAALAAECgUIBgAAAA==.',['塞尔']='塞尔逹:BAACLAAFFH8bAAIFAAUI1RGUUAAMAQAFAAUI1RGUUAAMAQAsAAQKfzIAAwUACAgUH8AzAIwCAAUACAgUH8AzAIwCABYAAwh5DhuXAJEAAAAA.',['夏丶']='夏丶小浅:BAAALAAECgIIAgAAAA==.',['夏米']='夏米尔:BAAALAADCggICAAAAA==.',['外恩']='外恩:BAAALAAFFAIIAgAAAA==.',['夜君']='夜君:BAACLAAFFH8lAAIVAAUI7BPmAwA1AQAVAAUI7BPmAwA1AQAsAAQKfywAAhUACAipG6AOAI0CABUACAipG6AOAI0CAAAA.',['夜宵']='夜宵吃烤鸭:BAABLAAFFH8OAAIGAAMIjBKGLgCzAAAGAAMIjBKGLgCzAAAAAA==.',['大兵']='大兵之恋:BAABLAAECn8WAAMKAAYIQgnkWAASAQAKAAYIQgnkWAASAQASAAII2QIKcgA7AAAAAA==.大兵的德:BAAALAAECgYICQAAAA==.',['大地']='大地精华之魂:BAAALAADCgIIAgAAAA==.',['天使']='天使:BAACLAAFFH8HAAIGAAIIwCQFHQDPAAAGAAIIwCQFHQDPAAAsAAQKfxgAAgYABwi3GZc4APkBAAYABwi3GZc4APkBAAAA.',['天策']='天策上将:BAAALAAECgYIDAAAAA==.',['奉告']='奉告不可:BAAALAAECgYIBgAAAA==.',['如沐']='如沐清风:BAAALAAECgQIBAAAAA==.',['姑娘']='姑娘请自重:BAAALAAECgYIBgAAAA==.',['娜薇']='娜薇莉娅:BAAALAAFFAIIBAAAAA==.',['孤蛋']='孤蛋哥:BAAALAADCgcIBwAAAA==.',['宁静']='宁静致远:BAAALAADCgQIBAAAAA==.',['寒水']='寒水浮冰:BAAALAAECgQIBwAAAA==.',['寒露']='寒露潇潇:BAAALAAECgQIBAAAAA==.',['尊卢']='尊卢四月:BAAALAADCgMIBAAAAA==.',['小啪']='小啪姬:BAAALAAECgMIBQAAAA==.',['小布']='小布丁愛吃鱼:BAAALAAECgYICAAAAA==.',['小手']='小手哗哗红:BAAALAAECgYIBgAAAA==.',['小樱']='小樱樱:BAAALAADCgQIBAAAAA==.',['小汤']='小汤姆杰西:BAAALAAECgYIBgAAAA==.',['小盆']='小盆友参上:BAAALAAECgQIBAAAAA==.',['小蓝']='小蓝毛:BAAALAAECgYIBgAAAA==.',['小软']='小软灬:BAAALAAECggIEAAAAA==.',['小高']='小高手载物:BAABLAAFFH8IAAIFAAIIYhdyTQCYAAAFAAIIYhdyTQCYAAAAAA==.',['就是']='就是任性:BAAALAAECgUIBQAAAA==.',['山不']='山不让尘:BAAALAAECgYICgAAAA==.',['山葵']='山葵酱:BAABLAAFFH8FAAIUAAIInAzLSABeAAAUAAIInAzLSABeAAAAAA==.',['巍之']='巍之松:BAAALAAECggIEAAAAA==.巍之松血骑士:BAAALAAECggICAAAAA==.',['巧兮']='巧兮刺:BAAALAADCgYIBgAAAA==.',['巧哥']='巧哥丶小德:BAAALAAFFAIIBAAAAA==.',['帅气']='帅气的肥宅:BAAALAAECgIIAgAAAA==.',['希尔']='希尔瓦娜:BAAALAAECgYIBwAAAA==.希尔瓦纳爹:BAAALAAECgUIBgAAAA==.',['帝王']='帝王州叶知秋:BAAALAAFFAIIAgAAAA==.',['幕鱼']='幕鱼:BAABLAAECn8UAAIXAAYIrxcgLwCyAQAXAAYIrxcgLwCyAQAAAA==.',['平生']='平生多憾事:BAAALAADCgUIBgAAAA==.',['幻象']='幻象很常见:BAAALAAFFAQIBAAAAA==.',['幼稚']='幼稚园院长丶:BAAALAAECgIIAgAAAA==.',['幽玄']='幽玄丿乱:BAABLAAFFH8IAAIVAAIIBhxAEwCeAAAVAAIIBhxAEwCeAAAAAA==.',['幽茗']='幽茗兰香:BAAALAAECgYIDwAAAA==.',['弑血']='弑血幽兰:BAABLAAFFH8OAAIWAAIIUhGpFQBEAAAWAAIIUhGpFQBEAAAAAA==.',['引魔']='引魔者:BAAALAAECgcIEwAAAA==.',['弯月']='弯月刹罗:BAACLAAFFH8SAAIFAAYI/SN5FADsAQAFAAYI/SN5FADsAQAsAAQKfxcAAgUACAgUIrspABECAAUACAgUIrspABECAAAA.',['强效']='强效不灭精华:BAAALAAECgcICAAAAA==.',['彬彬']='彬彬猪:BAABLAAFFH8FAAIIAAMIPw8OSQCLAAAIAAMIPw8OSQCLAAAAAA==.',['彼岸']='彼岸花:BAABLAAFFH8IAAIIAAIIsBSgQACAAAAIAAIIsBSgQACAAAAAAA==.',['往事']='往事已不在:BAAALAADCgcIBwAAAA==.',['德州']='德州香扒鸡:BAAALAAFFAIIBAABLAAFFAYIGgADAMQVAA==.',['德鲁']='德鲁大叔:BAABLAAFFH8KAAIVAAIIUBKqFgA+AAAVAAIIUBKqFgA+AAAAAA==.德鲁大爷:BAABLAAFFH8GAAIKAAIIXg22GgA7AAAKAAIIXg22GgA7AAAAAA==.',['心宝']='心宝宝:BAABLAAFFH8GAAIIAAIIyBUbUgB3AAAIAAIIyBUbUgB3AAAAAA==.',['心惊']='心惊胆战:BAAALAADCgMIBAAAAA==.',['心灵']='心灵丶捕手:BAAALAAECgYIDwAAAA==.',['快打']='快打壹壹零:BAAALAADCgMIAwAAAA==.',['怀言']='怀言者:BAAALAADCgcIBwAAAA==.',['怜香']='怜香惜玉:BAAALAAECgYICQAAAA==.',['恒大']='恒大:BAAALAAFFAIIBAAAAA==.',['恶魔']='恶魔丶殺:BAAALAAECgMIAwAAAA==.恶魔捕猎者:BAAALAAECgUIBQAAAA==.恶魔术:BAAALAADCgQIBAAAAA==.',['悠遊']='悠遊:BAAALAAECgEIAQAAAA==.',['愤怒']='愤怒的猪宝:BAAALAAECggIDwAAAA==.',['慕容']='慕容飞雪:BAAALAAECgYIBgAAAA==.',['我不']='我不服丶:BAAALAADCgcIBwAAAA==.',['我到']='我到这儿来咯:BAAALAAECgMIAwAAAA==.',['手旺']='手旺先锋丶:BAAALAAECgUIBgAAAA==.',['托里']='托里昂:BAAALAAECgQIBAAAAA==.',['抖音']='抖音:BAAALAAECgMIAwAAAA==.',['按摩']='按摩大脑:BAAALAAECgMIAwAAAA==.',['排行']='排行榜第二名:BAABLAAFFH8GAAICAAMI1wLyWgA7AAACAAMI1wLyWgA7AAAAAA==.',['提里']='提里奥佛丁:BAABLAAFFH8IAAMRAAQIDBYbPACkAAARAAMIwBkbPACkAAAPAAEIwAG3MAAwAAAAAA==.',['摇篮']='摇篮曲灬:BAAALAAECgUIBQAAAA==.',['放开']='放开那个公的:BAAALAAECgMIAwAAAA==.',['故都']='故都的秋:BAAALAAECgYICAAAAA==.',['斋藤']='斋藤飞鸟:BAAALAAECgUIBQAAAA==.',['斷弦']='斷弦叶灬:BAABLAAECn8ZAAMFAAYI9yBqSAC2AQAFAAYI9yBqSAC2AQAWAAEI2wx4vQA1AAAAAA==.',['方人']='方人也:BAAALAADCgEIAQAAAA==.',['无伤']='无伤大雅:BAAALAAECgUIBQAAAA==.',['无图']='无图言蛋:BAAALAAECgEIAQAAAA==.',['无拘']='无拘无术:BAAALAADCggICAAAAA==.',['星辰']='星辰之月:BAAALAAFFAIIAgAAAA==.星辰之耀:BAAALAAFFAIIBAAAAA==.',['春日']='春日影:BAABLAAFFH8GAAMJAAUImRAXLwC7AAAJAAII6iEXLwC7AAAIAAQIfhKISgCIAAAAAA==.',['昨夜']='昨夜星辰不离:BAAALAAFFAIIBAAAAA==.',['暗夜']='暗夜大兵:BAABLAAECn8YAAMWAAYIrQf6gwDOAAAWAAYIZAf6gwDOAAAFAAYIpgPc9wCYAAAAAA==.暗夜宝可梦:BAAALAAECgYIAgAAAA==.暗夜战神:BAAALAAECgIIAgAAAA==.',['暮色']='暮色苍狼:BAAALAAECgYIBgAAAA==.',['暴丶']='暴丶鼬:BAAALAAECgYICAAAAA==.',['暴风']='暴风战斧:BAAALAAECgYIBgAAAA==.',['曰大']='曰大侠:BAAALAAECgYIBgAAAA==.',['月之']='月之爱恋:BAAALAAECgYIDgAAAA==.',['月影']='月影星痕:BAAALAAECggICAAAAA==.月影流觞:BAAALAAECggICAAAAA==.',['有生']='有生之莲:BAABLAAFFH8LAAIUAAMIYRGwFgDIAAAUAAMIYRGwFgDIAAAAAA==.',['木谷']='木谷实:BAAALAADCgQIBAAAAA==.',['木骨']='木骨实:BAAALAADCgQIBAAAAA==.',['末日']='末日变节者:BAAALAAECgMIAwAAAA==.',['标准']='标准男:BAABLAAECn8ZAAICAAYIEhmIZwDAAQACAAYIEhmIZwDAAQAAAA==.',['树的']='树的苗:BAAALAAFFAEIAQAAAA==.',['桜咲']='桜咲琉璃:BAAALAADCggICAAAAA==.',['楠萌']='楠萌部落丫头:BAABLAAECn8XAAMWAAYIyAbmjQCuAAAFAAYIwwZdLQHtAAAWAAYI/APmjQCuAAAAAA==.',['模拟']='模拟天天:BAACLAAFFH8WAAIFAAYImAyHPwBIAQAFAAYImAyHPwBIAQAsAAQKfxoAAgUACAj+DAzsAEcBAAUACAj+DAzsAEcBAAAA.',['武僧']='武僧食铁兽:BAAALAAECgIIAgAAAA==.',['武大']='武大爷:BAAALAADCgEIAgAAAA==.',['毛线']='毛线的毛线:BAABLAAFFH8GAAICAAYIKBGoJABKAQACAAYIKBGoJABKAQAAAA==.',['水官']='水官解厄:BAACLAAFFH8MAAIGAAIILhgFMgCMAAAGAAIILhgFMgCMAAAsAAQKfyIAAgYABgglG6s/ANkBAAYABgglG6s/ANkBAAEsAAUUAwgIABQAfRYA.',['江城']='江城丨志海:BAAALAAFFAYIBAAAAA==.',['沙县']='沙县大盘鸡:BAAALAAECgYIDAAAAA==.',['沙音']='沙音:BAACLAAFFH8VAAMYAAgIBCESBQCvAgAYAAgIBCESBQCvAgAVAAMIBhH+BADxAAAsAAQKfxkAAxUACAjFFLAeAAoCABUACAjFFLAeAAoCABgABQhBC0u4AAQBAAAA.',['没我']='没我不行:BAABLAAFFH8JAAIPAAMIzQxZIQCXAAAPAAMIzQxZIQCXAAAAAA==.',['泽文']='泽文:BAAALAAECgUIBQAAAA==.',['洛城']='洛城少年郎:BAAALAAFFAIIAgAAAA==.',['洵月']='洵月:BAAALAAECgQICAAAAA==.',['活的']='活的紫色仙子:BAAALAAECgEIAQAAAA==.',['浅夏']='浅夏是猪头:BAAALAADCgEIAQAAAA==.',['浅浅']='浅浅的小熊:BAAALAAECgUIBQAAAA==.',['浪花']='浪花:BAAALAADCgMIAwAAAA==.',['浪蹄']='浪蹄:BAAALAAFFAIIAgAAAA==.',['浮生']='浮生尽歇丶:BAAALAADCgQIBAAAAA==.',['润物']='润物细无声:BAAALAADCgMIAwAAAA==.',['淘气']='淘气的爸爸:BAABLAAECn8VAAMVAAYIniKaLAC/AQAVAAUI4yKaLAC/AQAYAAQIlhzfQQBBAQAAAA==.',['混沌']='混沌之锋:BAAALAAFFAEIAQAAAA==.',['清源']='清源妙道真君:BAACLAAFFH8YAAIZAAUItBrrBgBbAQAZAAUItBrrBgBbAQAsAAQKfxcAAhkACAjeHCoOAIcCABkACAjeHCoOAIcCAAAA.',['清风']='清风有信:BAAALAADCgcIBwAAAA==.清风若水:BAAALAAECgUIDAAAAA==.',['温暖']='温暖的小熊:BAACLAAFFH8LAAIaAAMIXSLACwDCAAAaAAMIXSLACwDCAAAsAAQKfxUAAhoABgiaJOcTAHkCABoABgiaJOcTAHkCAAEsAAUUBggMAAEAhCEA.',['满穗']='满穗:BAAALAAECgYIBgAAAA==.',['灬之']='灬之舞:BAAALAAECgYICwAAAA==.',['灬沐']='灬沐瞳灬:BAAALAAECgYIBgAAAA==.',['灰太']='灰太浪:BAAALAADCgEIAQAAAA==.',['灰烬']='灰烬小骑:BAAALAAECgYIBgAAAA==.',['炫迈']='炫迈风:BAAALAAECgUICgAAAA==.',['煊舞']='煊舞小区:BAAALAADCgIIAgAAAA==.',['熊德']='熊德不切奶:BAAALAAECgYICgAAAA==.',['熊悠']='熊悠悠:BAAALAADCggICAAAAA==.',['爆大']='爆大侠:BAAALAAECgYIBgAAAA==.',['爱夏']='爱夏:BAAALAAFFAIIBAAAAA==.',['爱择']='爱择拉撕公主:BAAALAAECggIDgAAAA==.',['爱潜']='爱潜行的小德:BAAALAAFFAIIAgAAAA==.',['爱神']='爱神天使:BAAALAAECgUIBQAAAA==.爱神怒风:BAAALAAECgMIAwAAAA==.爱神无敌萨:BAAALAAECgYIBgAAAA==.',['牛牛']='牛牛可没错:BAAALAAFFAEIAQAAAA==.',['狂暴']='狂暴战:BAAALAAECgUIBgAAAA==.',['狸叽']='狸叽米:BAAALAADCgYICgAAAA==.',['狸追']='狸追丶:BAABLAAFFH8HAAIGAAIIUQnIOQCBAAAGAAIIUQnIOQCBAAAAAA==.',['猪猪']='猪猪小楠:BAAALAADCgEIAQAAAA==.',['玉环']='玉环露华浓:BAAALAAECgIIAgAAAA==.',['王大']='王大娘:BAAALAAECgYICQAAAA==.',['玛埃']='玛埃尔:BAABLAAFFH8eAAIbAAYIcSW7AwAxAgAbAAYIcSW7AwAxAgAAAA==.',['玛法']='玛法理奥怒风:BAAALAAFFAIIBAABLAAFFAUICwAMAJAZAA==.',['珍妮']='珍妮玛:BAABLAAFFH8aAAMYAAgIYAbOLgDDAAAYAAgIYAbOLgDDAAAcAAEIiwNaCQA3AAAAAA==.',['珍珠']='珍珠小米儿:BAAALAAECgYICAAAAA==.珍珠米米:BAAALAAECgUIBgAAAA==.',['瑟拉']='瑟拉奈莎:BAAALAAECgIIAgAAAA==.',['生如']='生如朝露:BAAALAAECgMIAwAAAA==.',['疏影']='疏影残月:BAABLAAFFH8VAAISAAgIThmACQBJAgASAAgIThmACQBJAgAAAA==.',['白云']='白云苍狗丶:BAAALAADCgIIAgAAAA==.',['白水']='白水豆腐:BAAALAAECgQIBAAAAA==.',['百味']='百味菜篮:BAABLAAFFH8FAAMBAAUIVwrBUQDSAAABAAQI4AvBUQDSAAAdAAEINwTfEwBIAAAAAA==.',['皮五']='皮五辣子:BAAALAAECgYIBgAAAA==.',['盛夏']='盛夏灬夜来香:BAAALAAECgYICAAAAA==.盛夏灬永夜:BAAALAADCgQIBAAAAA==.',['盲目']='盲目吃鱼:BAAALAADCgIIAgAAAA==.',['瞄你']='瞄你脑瓜:BAAALAAFFAIIAgAAAA==.',['知世']='知世:BAABLAAFFH8JAAIYAAYIJxWuJACIAQAYAAYIJxWuJACIAQAAAA==.',['神仙']='神仙也无情:BAAALAAECgUIBQAAAA==.神仙很高兴:BAAALAAECgYIBgAAAA==.',['神奇']='神奇的德:BAAALAAECgcIEwAAAA==.',['神赴']='神赴我:BAABLAAFFH8GAAIaAAYIWhJYCABtAQAaAAYIWhJYCABtAQAAAA==.神赴我一:BAAALAAFFAYIAwAAAA==.',['秋水']='秋水新月:BAABLAAFFH8RAAIFAAUIlwhkHQAZAQAFAAUIlwhkHQAZAQAAAA==.',['秋秋']='秋秋千:BAABLAAFFH8QAAIFAAYIBR3ZGQDOAQAFAAYIBR3ZGQDOAQAAAA==.',['秋风']='秋风有信:BAAALAAECgMIBQAAAA==.',['秦雯']='秦雯:BAAALAAECgYIEgAAAA==.',['秩序']='秩序之枪:BAAALAAECgYIBgAAAA==.',['窥欲']='窥欲无罪:BAAALAADCgQIBAAAAA==.',['精灵']='精灵鼠爸爸:BAAALAAFFAIIBAAAAA==.',['糖门']='糖门丨:BAAALAAECgYIBwAAAA==.',['紗音']='紗音:BAACLAAFFH8QAAMHAAgIOBiNBAAxAgAHAAgIOBiNBAAxAgAGAAII6ANDQAB1AAAsAAQKfxYAAwYACAg5C0xcAGoBAAYACAg5C0xcAGoBAAcABgh8B7xrAAkBAAAA.',['紫式']='紫式部:BAACLAAFFH8MAAMPAAUItAuqFwAUAQAPAAUItAuqFwAUAQARAAIIeQvnXgBHAAAsAAQKfxcAAg8ACAjxFm0LADgCAA8ACAjxFm0LADgCAAAA.',['紫苏']='紫苏:BAACLAAFFH8tAAQFAAYIOhSiOwBUAQAFAAYIOhSiOwBUAQAeAAEIkRHgBwBQAAAWAAEI9w8/NgA9AAAsAAQKfx4ABBYABwjXGRJSAG4BABYABwjDEhJSAG4BAAUABgg+Fp3/AC8BAB4AAggpELogAHYAAAAA.',['红叶']='红叶栖霞:BAABLAAFFH8VAAIGAAgIKB2iAgDRAgAGAAgIKB2iAgDRAgAAAA==.',['红太']='红太浪:BAAALAADCgYIBgAAAA==.',['红红']='红红的小熊:BAABLAAFFH8MAAIBAAMIhCGBRgCqAAABAAMIhCGBRgCqAAAAAA==.',['红魔']='红魔慧馨:BAAALAAECggICAABLAAFFAgIEQAfAJASAA==.',['练习']='练习生蔡某:BAAALAADCgEIAQAAAA==.',['绝地']='绝地的傲气:BAAALAAECgYIDgAAAA==.',['绝对']='绝对是菠萝:BAAALAADCgIIAQAAAA==.',['绯月']='绯月:BAAALAADCgUIBQAAAA==.',['群狼']='群狼:BAAALAADCgMIAwAAAA==.',['老六']='老六的一天:BAAALAAECgYIDQAAAA==.',['老婆']='老婆打断的角:BAAALAAECgYIDAAAAA==.',['自由']='自由之舞:BAAALAAFFAIIAgAAAA==.',['舞後']='舞後紅茶:BAABLAAFFH8TAAMOAAYIJBZ7BQA+AQAOAAYIiRN7BQA+AQAMAAIIyh/DRgBdAAABLAAFFAgILgARAB4iAA==.',['艾司']='艾司唑仑:BAAALAADCggICAAAAA==.',['艾夏']='艾夏拉:BAABLAAFFH8RAAIBAAYIfQmyPQBEAQABAAYIfQmyPQBEAQAAAA==.',['艾爾']='艾爾薩斯:BAAALAAECgMIAwAAAA==.',['苍穹']='苍穹超燃:BAABLAAFFH8KAAICAAIIExF2SABKAAACAAIIExF2SABKAAAAAA==.',['荆轲']='荆轲刺秦:BAAALAADCgQIBAAAAA==.',['荷必']='荷必奘傻:BAAALAAECgYIDwAAAA==.',['莉莉']='莉莉:BAACLAAFFH8aAAMRAAYIpRlmFwCWAQARAAYIpRlmFwCWAQAgAAEIVxC9GgA1AAAsAAQKfxcAAhEABwhKI2g0AKICABEABwhKI2g0AKICAAAA.莉莉安:BAABLAAFFH8FAAIeAAUIEghGAgDBAAAeAAUIEghGAgDBAAAAAA==.莉莉雅:BAABLAAFFH8GAAIBAAYINwQARgAiAQABAAYINwQARgAiAQAAAA==.',['莉迪']='莉迪亚:BAAALAAFFAIIAgAAAA==.',['莱弥']='莱弥亚丶银光:BAAALAADCgMIAwAAAA==.',['萌新']='萌新阿杰:BAAALAAECggICgAAAA==.',['萨拉']='萨拉托加:BAABLAAFFH8GAAIRAAIIXw8QYgBFAAARAAIIXw8QYgBFAAAAAA==.',['落叶']='落叶辰:BAAALAAECgYIDAAAAA==.',['落雨']='落雨飘飘:BAAALAAFFAIIAgAAAA==.',['葛尔']='葛尔丹:BAAALAADCgYICQAAAA==.',['蔚蓝']='蔚蓝的天空:BAAALAAECgYIDAAAAA==.',['薄暮']='薄暮:BAAALAADCgIIAgAAAA==.',['虎妞']='虎妞:BAAALAADCgEIAQAAAA==.',['蛋总']='蛋总的忧伤:BAAALAAFFAIIBAAAAA==.',['西尔']='西尔维亚:BAAALAAECgQIBAAAAA==.',['西门']='西门哥哥:BAABLAAFFH8IAAIhAAYIngb8CwA6AAAhAAYIngb8CwA6AAAAAA==.西门老哥:BAABLAAFFH8KAAIKAAQI6hKkCgC+AAAKAAQI6hKkCgC+AAAAAA==.',['角海']='角海:BAABLAAFFH8KAAIBAAMIlAoRaAB3AAABAAMIlAoRaAB3AAAAAA==.',['贝尔']='贝尔摩德:BAAALAAECgQIBAAAAA==.',['赤色']='赤色苍狼:BAAALAAECgcIDAAAAA==.',['起司']='起司猫:BAAALAADCgEIAQAAAA==.',['起名']='起名好麻烦:BAAALAAECggICAAAAA==.',['轩辕']='轩辕凤:BAAALAAFFAIIBAAAAA==.',['轻舞']='轻舞的雏田:BAAALAAECgYIDAAAAA==.轻舞的飞羊:BAAALAAECgYIEAAAAA==.',['过帅']='过帅:BAAALAAECgYIEAAAAA==.',['迷梦']='迷梦沉沦:BAAALAAECgIIAgAAAA==.',['追逐']='追逐么么茶:BAABLAAECn8aAAICAAYIqxTQQwBNAQACAAYIqxTQQwBNAQAAAA==.',['逢坂']='逢坂丶大河:BAACLAAFFH8NAAMSAAMIBhcjNgCxAAASAAMIBhcjNgCxAAAKAAEImAPNIgA2AAAsAAQKfx4ABBIABgg2IUVVAAQCABIABgg2IUVVAAQCABMAAwj8G38SAOAAAAoAAwiZDb59AHMAAAAA.',['那个']='那个奶德:BAAALAAECgYIBgABLAAFFAYIFgAKAP4hAA==.那个暗牧:BAAALAAFFAIIAgAAAA==.那个毁伤贼:BAAALAAFFAIIAgAAAA==.',['邪念']='邪念:BAABLAAFFH8LAAMEAAIIyCTIDADZAAAEAAIIyCTIDADZAAADAAIIYxlXHgBAAAAAAA==.',['邪恶']='邪恶的小熊猫:BAAALAADCgcIBwAAAA==.',['郑码']='郑码不忙:BAAALAAECgYICAAAAA==.',['醋溜']='醋溜肥肠:BAAALAAECgQIBwAAAA==.',['金色']='金色少年:BAAALAAECgQIBAAAAA==.',['锦绣']='锦绣之曳:BAAALAAECgQIBAAAAA==.',['阳春']='阳春:BAABLAAFFH8HAAMUAAMIQBkfMQCmAAAUAAIIVR8fMQCmAAALAAII+wdmOgAzAAAAAA==.',['阿加']='阿加西的保镖:BAAALAAECgYIBwAAAA==.',['阿尔']='阿尔托莉亚:BAABLAAFFH8mAAMRAAYI3SHtBAAcAgARAAUI2CPtBAAcAgAPAAUIjBa5CgBKAQAAAA==.',['阿暴']='阿暴:BAAALAAECgMIAwAAAA==.',['阿满']='阿满:BAACLAAFFH8HAAMBAAMIKxtzJwD7AAABAAMIKxtzJwD7AAAdAAEIrwIsIABDAAAsAAQKfxMABBsABwh+IxQUABYCABsABwhIIBQUABYCAAEABggnJGOKAOgBAB0AAgjNHmBHAKUAAAAA.',['阿玛']='阿玛希尔:BAAALAAECgYIBwABLAAFFAgIGgAYAFEfAA==.',['阿蛮']='阿蛮:BAAALAAECgYIDAAAAA==.',['陆军']='陆军:BAAALAAECgYIBgAAAA==.',['陌梓']='陌梓寒:BAABLAAFFH8GAAIiAAYIZRHMBQC7AQAiAAYIZRHMBQC7AQAAAA==.',['随便']='随便起一个:BAAALAADCggICAAAAA==.',['雨夜']='雨夜小毒:BAAALAADCgMIAwAAAA==.雨夜晓姽:BAAALAADCgYIBgAAAA==.',['雪色']='雪色苍狼:BAAALAAECgQIBQAAAA==.',['雪莲']='雪莲花开:BAAALAADCgQIBAAAAA==.',['雷电']='雷电法王菲克:BAAALAAFFAQIAgAAAA==.',['雷钢']='雷钢须世理:BAAALAAECgYIBgAAAA==.',['雷雨']='雷雨天:BAAALAAECgcIEQAAAA==.',['震泽']='震泽:BAAALAAECgYIDAAAAA==.',['露琪']='露琪亚兔兔:BAAALAAECggIEAAAAA==.',['霸波']='霸波奔:BAAALAADCgEIAQAAAA==.',['霸王']='霸王:BAAALAADCgEIAQAAAA==.',['革音']='革音:BAAALAAFFAIIAgAAAA==.',['风之']='风之舞:BAAALAAECgQIBAAAAA==.',['风乘']='风乘:BAABLAAFFH8GAAIgAAIIAwa6HgBhAAAgAAIIAwa6HgBhAAAAAA==.',['风怒']='风怒灬火:BAAALAAECgYIBgAAAA==.',['风暴']='风暴火焰大地:BAAALAAECgYIBgAAAA==.',['风行']='风行者艾瑞丝:BAAALAAFFAIIAgAAAA==.',['风迹']='风迹:BAAALAAFFAIIAgAAAA==.',['风里']='风里雨里丶:BAAALAAECgUICQAAAA==.',['风骚']='风骚矮子:BAAALAAECgcICgAAAA==.',['飞霄']='飞霄:BAAALAADCgMIAwAAAA==.',['马莲']='马莲尼娅:BAAALAADCgEIAQAAAA==.',['骑士']='骑士食铁兽:BAAALAAECgYIBwAAAA==.',['高坂']='高坂桐乃:BAABLAAFFH8FAAMRAAMIiRZhGAD8AAARAAMIiRZhGAD8AAAPAAIIMB5cFgCqAAAAAA==.',['魂灬']='魂灬舞:BAABLAAFFH8GAAIYAAQIJQvhRQC0AAAYAAQIJQvhRQC0AAAAAA==.',['魅影']='魅影之蓝:BAAALAAECgYIBgAAAA==.',['鸦雀']='鸦雀无僧:BAAALAADCgUIBQAAAA==.',['鸿渐']='鸿渐于陵:BAABLAAFFH8IAAICAAIIkBQuNgCYAAACAAIIkBQuNgCYAAAAAA==.',['黄鹤']='黄鹤楼:BAAALAAECgUIBQAAAA==.',['黑大']='黑大哥:BAAALAADCgMIAwAAAA==.',['點點']='點點的回憶:BAAALAAECgIIAgAAAA==.',['龙之']='龙之骄子:BAAALAAFFAEIAQAAAA==.',['龙角']='龙角丶加攻速:BAAALAAECgYICAAAAA==.',['龙龙']='龙龙飘过来:BAACLAAFFH8JAAISAAIIABX8SQCWAAASAAIIABX8SQCWAAAsAAQKfx4AAxIABgiPICogAK0BABIABgi1HyogAK0BAAoAAQgdJZOFAFoAAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end