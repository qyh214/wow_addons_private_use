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
 local lookup = {'DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Frost','Druid-Balance','Druid-Restoration','Warlock-Destruction','Warlock-Demonology','Mage-Fire','Mage-Arcane','Evoker-Preservation','Shaman-Restoration','Paladin-Protection','Warrior-Fury','Warrior-Protection','Hunter-Marksmanship','Paladin-Retribution','Monk-Mistweaver','Unknown-Unknown','Shaman-Elemental','Priest-Holy','Paladin-Holy','Evoker-Devastation','Hunter-BeastMastery','Monk-Brewmaster','Evoker-Augmentation','DeathKnight-Unholy','DeathKnight-Blood','Priest-Shadow','Mage-Frost',}; local provider = {region='CN',realm='埃霍恩',name='CN',type='weekly',zone=44,date='2025-12-07',data={Ab='Abchuhu:BAABLAAFFH8JAAMBAAMIohB9PACcAAABAAMIohB9PACcAAACAAII8AR2GQAjAAABLAAFFAUIDQADAIQSAA==.',Ai='Airi:BAAALAAFFAQIBAAAAA==.',Al='Alcapone:BAAALAAECgQIBAAAAA==.',Au='Aurora:BAAALAAECgYIBwAAAA==.',Be='Beel:BAAALAAECgYICQAAAA==.',Ch='Charmy:BAACLAAFFH8IAAMEAAQI+xINIQC2AAAEAAQI+xINIQC2AAAFAAEI5QFKUgApAAAsAAQKfxUAAwQABghHIa0WAL8BAAQABghHIa0WAL8BAAUABAgaFFGUAO8AAAAA.',Cl='Clairdelune:BAAALAAECgcICwAAAA==.',Ct='Ctmdb:BAAALAADCggICQAAAA==.',Da='Dawn:BAABLAAFFH8NAAMGAAMIChtHNgCkAAAGAAIIXRZHNgCkAAAHAAEIZST/HwBsAAAAAA==.Dayday:BAAALAADCggICAAAAA==.',Di='Discovery:BAAALAAECggICAAAAA==.',Dr='Druidism:BAAALAAECgMIAwAAAA==.',Du='Dusk:BAAALAAFFAIIBAAAAA==.',Dw='Dwarfknight:BAAALAADCgMIAwAAAA==.',Ec='Ec:BAAALAAFFAIIAgAAAA==.',Fi='Firefly:BAAALAADCggIEAAAAA==.',Gl='Glory:BAACLAAFFH9kAAMIAAgI/CUGAABSAwAIAAgI/CUGAABSAwAJAAYIRyClEgDmAQAsAAQKfy0AAwgACAjzJjkAAIUDAAgACAjzJjkAAIUDAAkABwgbGhOQAGwBAAAA.',Jv='Jvebie:BAAALAAFFAMIAwAAAA==.',['Mé']='Mélusine:BAABLAAFFH8QAAIKAAYIlBf9CwCQAQAKAAYIlBf9CwCQAQAAAA==.',No='Nokk:BAABLAAFFH8GAAILAAIIdBQxQgB9AAALAAIIdBQxQgB9AAAAAA==.',Ox='Ox:BAAALAAECgYIEAAAAA==.',Pa='Pandarenyuan:BAABLAAFFH8LAAIDAAMIcSIjIwAQAQADAAMIcSIjIwAQAQAAAA==.',Ra='Raindrops:BAABLAAFFH8JAAIMAAIIHCFjCgDEAAAMAAIIHCFjCgDEAAAAAA==.',Re='Redive:BAABLAAFFH8MAAIDAAMICxN8ZgB/AAADAAMICxN8ZgB/AAAAAA==.',Sa='Sandsculptur:BAAALAAECgIIAgAAAA==.Sayanything:BAACLAAFFH8rAAMNAAUIUBeuHADkAAAOAAUI7hYIFgAJAQANAAMI8gyuHADkAAAsAAQKfzsAAw0ACAjWHCQqAJQCAA0ACAgRHCQqAJQCAA4ABgh3GvsaAGoBAAAA.',Su='Sugarfee:BAABLAAFFH8IAAIPAAgIKBOoBADpAQAPAAgIKBOoBADpAQAAAA==.Sunday:BAAALAAECgYIDAAAAA==.',Th='Theshy:BAAALAAECggICAAAAA==.',To='Toxic:BAAALAAECgQICAAAAA==.',Vs='Vs:BAAALAADCgEIAQAAAA==.',Xt='Xtremeone:BAABLAAFFH8JAAIGAAcI4hfEFwDPAQAGAAcI4hfEFwDPAQAAAA==.Xtremeseven:BAABLAAFFH8IAAIGAAgIPRKbEgD6AQAGAAgIPRKbEgD6AQAAAA==.Xtremethree:BAABLAAFFH8GAAIGAAYIVhdHLQBnAQAGAAYIVhdHLQBnAQAAAA==.Xtremexis:BAABLAAFFH8IAAIGAAYIrRJJGADLAQAGAAYIrRJJGADLAQAAAA==.',Xx='Xxlzy:BAABLAAFFH8GAAIQAAIIqhxfLQCvAAAQAAIIqhxfLQCvAAAAAA==.',['一发']='一发入魂:BAAALAAECggIDgAAAA==.一发旋风斩:BAAALAAECgQIBAAAAA==.',['一只']='一只梨:BAAALAAECggICgABLAAFFAMICAARALAWAA==.',['丁胖']='丁胖:BAAALAAFFAMIAgAAAA==.',['三乜']='三乜木:BAAALAAECgUIBQABLAAECggIAgASAAAAAA==.',['三重']='三重刘德华:BAAALAAFFAIIBAAAAA==.',['不听']='不听话的猫丶:BAAALAAECgYIBAAAAA==.',['不懂']='不懂情的人:BAAALAADCggICAAAAA==.',['专业']='专业泥头车:BAABLAAFFH8JAAMNAAMIdhpgNwCXAAANAAMIKBNgNwCXAAAOAAIIrCFbIwBjAAABLAAFFAUIDQADAIQSAA==.',['丨十']='丨十丨:BAAALAADCgcIBwAAAA==.',['丶青']='丶青头菌:BAAALAAECgIIAgAAAA==.',['丷夜']='丷夜空丷:BAAALAAECgMIAwAAAA==.',['乂力']='乂力丹:BAAALAAECgYIEQAAAA==.',['九儿']='九儿丶:BAAALAAECgYIBgAAAA==.',['九江']='九江吴彦祖:BAAALAAFFAIIAwAAAA==.',['争梦']='争梦:BAABLAAFFH8GAAINAAYISwC5aAAHAAANAAYISwC5aAAHAAAAAA==.',['人皇']='人皇:BAAALAADCgIIAgAAAA==.',['人间']='人间小苦瓜丶:BAABLAAFFH8FAAIPAAUIwxkEBwCwAQAPAAUIwxkEBwCwAQAAAA==.',['亻尹']='亻尹禾刂丹:BAAALAAECgMIAwAAAA==.',['仙境']='仙境轩辕:BAAALAAECgUIBQAAAA==.',['仿若']='仿若暮夏:BAAALAAECgQIBQAAAA==.',['伊芙']='伊芙利特:BAACLAAFFH8HAAITAAMIdCKRFAAXAQATAAMIdCKRFAAXAQAsAAQKfxQAAhMACAh1JAgKAD4DABMACAh1JAgKAD4DAAEsAAUUCAgqABMAwiUA.',['伏羲']='伏羲氏:BAABLAAFFH8JAAMCAAII7BVuEwBlAAACAAII7BVuEwBlAAABAAIIiAmRXQBBAAAAAA==.',['依稀']='依稀想你:BAAALAADCgEIAQAAAA==.',['元神']='元神启动:BAAALAAFFAIIBAAAAA==.',['全是']='全是细节:BAAALAADCgIIAgAAAA==.',['八一']='八一佰:BAABLAAFFH8MAAIGAAYIdhBTLwBeAQAGAAYIdhBTLwBeAQAAAA==.',['八三']='八三佰:BAABLAAFFH8SAAIGAAYITg/GMQBSAQAGAAYITg/GMQBSAQAAAA==.',['八二']='八二佰:BAABLAAFFH8hAAIGAAgI6xAmEQAIAgAGAAgI6xAmEQAIAgAAAA==.',['八五']='八五佰:BAABLAAFFH8SAAIGAAYInQuHMwBJAQAGAAYInQuHMwBJAQAAAA==.',['八佰']='八佰:BAABLAAFFH8UAAIGAAgIrBKQDQAvAgAGAAgIrBKQDQAvAgAAAA==.',['八四']='八四佰:BAABLAAFFH8YAAIGAAYINRPNKwBtAQAGAAYINRPNKwBtAQAAAA==.',['冬的']='冬的飘雪:BAAALAAECgUIBgAAAA==.',['冰柠']='冰柠可乐:BAAALAAECgYIBgAAAA==.',['冶力']='冶力关:BAABLAAFFH8FAAIDAAIIRAUvmwA5AAADAAIIRAUvmwA5AAAAAA==.',['冷雨']='冷雨凌:BAAALAAECgEIAQAAAA==.',['别玩']='别玩冰迪凯了:BAAALAAECgYIBgAAAA==.',['劭超']='劭超:BAAALAAFFAIIBAAAAA==.',['十一']='十一:BAAALAAECgEIAQAAAA==.',['十翼']='十翼天使:BAAALAAECgUIBQAAAA==.',['南风']='南风:BAAALAAFFAIIBAAAAA==.',['卲超']='卲超:BAABLAAFFH8IAAIUAAIIrwFMTABMAAAUAAIIrwFMTABMAAAAAA==.',['司马']='司马老贼:BAAALAADCgIIAgAAAA==.',['吃橘']='吃橘子吗:BAAALAAECgMIBAAAAA==.',['和花']='和花:BAABLAAFFH8GAAIVAAIIdhRRHQCOAAAVAAIIdhRRHQCOAAAAAA==.',['哈桑']='哈桑丶阿巴赫:BAABLAAECn8ZAAIDAAcIiB5JHQAKAgADAAcIiB5JHQAKAgAAAA==.',['喝鹅']='喝鹅何:BAAALAAECgYICgAAAA==.',['喵筱']='喵筱筱喵:BAABLAAFFH8VAAMLAAYIwBHTIABZAQALAAYIwBHTIABZAQATAAQIRgMgIQCsAAAAAA==.',['嗜血']='嗜血君:BAAALAAECgQIBgAAAA==.',['嗯哼']='嗯哼:BAAALAAECggIBgABLAAFFAgIJAAWAAYcAA==.',['四顆']='四顆菠菜:BAAALAAECgcIEAAAAA==.',['土灵']='土灵:BAABLAAFFH8GAAIOAAIIxBS1IAB8AAAOAAIIxBS1IAB8AAAAAA==.',['圣光']='圣光照耀:BAAALAAECgYICgAAAA==.',['地上']='地上最凉:BAAALAAECgUIBwAAAA==.',['地狱']='地狱丨咆哮:BAAALAAECgEIAQAAAA==.',['坦克']='坦克没后视镜:BAAALAAFFAIIAgAAAA==.',['墨岚']='墨岚:BAABLAAFFH8VAAIXAAYIqA7PSgAkAQAXAAYIqA7PSgAkAQAAAA==.',['墨心']='墨心无尘:BAAALAAECgYIBgAAAA==.',['夏的']='夏的光辉:BAAALAAECgIIAgAAAA==.',['夜空']='夜空丨:BAAALAAECgMIAwAAAA==.',['夜雨']='夜雨喧嚣:BAAALAAFFAIIAgAAAA==.',['大脑']='大脑腐丶:BAABLAAECn8cAAIBAAYIThddOQB2AQABAAYIThddOQB2AQAAAA==.',['天下']='天下唯我风云:BAABLAAFFH8KAAIOAAgIMBFsCAC+AQAOAAgIMBFsCAC+AQAAAA==.',['太阳']='太阳卤蛋:BAABLAAFFH8YAAIXAAYIrRWxMAB4AQAXAAYIrRWxMAB4AQAAAA==.太阳抚蛋:BAAALAAECgYIBgAAAA==.太阳流蛋:BAAALAAFFAMIBAAAAA==.太阳滑蛋:BAABLAAFFH8UAAIDAAYI5xNQLQCGAQADAAYI5xNQLQCGAQAAAA==.太阳焗蛋:BAABLAAFFH8dAAIQAAUIuSIlFgCgAQAQAAUIuSIlFgCgAQAAAA==.太阳煮蛋:BAAALAADCgYIBgAAAA==.太阳爆蛋:BAABLAAFFH8FAAIKAAMIEwyPFgCeAAAKAAMIEwyPFgCeAAAAAA==.太阳腌蛋:BAACLAAFFH8HAAILAAUI+wxnLgD7AAALAAUI+wxnLgD7AAAsAAQKfxQAAxMABgiCFGpOANgAABMAAwguF2pOANgAAAsABgj7CxXzALMAAAAA.',['奈亚']='奈亚拉托提普:BAAALAAECgUIBwAAAA==.',['奎隆']='奎隆摩诃萨埵:BAACLAAFFH8LAAMTAAYIlhQ7GgBwAQATAAYIlhQ7GgBwAQALAAII0xfFOACPAAAsAAQKfxYAAwsABggVI+A2ADsCAAsABggVI+A2ADsCABMABgiaHFU9AA8CAAAA.',['奥妮']='奥妮克茜娅:BAABLAAFFH8IAAIXAAIICxlnlABDAAAXAAIICxlnlABDAAAAAA==.',['奶喵']='奶喵喵:BAABLAAECn8VAAIFAAgI8CNSCgAKAwAFAAgI8CNSCgAKAwAAAA==.',['奶谁']='奶谁谁死:BAABLAAECn8dAAIUAAcIPQ6PXgBiAQAUAAcIPQ6PXgBiAQAAAA==.',['如风']='如风翎:BAABLAAECn8VAAIBAAYIiRmijACtAQABAAYIiRmijACtAQAAAA==.',['姗姗']='姗姗来时:BAAALAAECgYIBgAAAA==.',['姣姣']='姣姣监护人:BAAALAADCgIIAgAAAA==.',['孟婆']='孟婆泪:BAAALAADCggICAAAAA==.',['宇智']='宇智波鼬:BAAALAAECgYIDQAAAA==.',['宝可']='宝可梦训练师:BAAALAAFFAIIBAAAAA==.',['寒风']='寒风追影:BAAALAAFFAIIAgAAAA==.',['射鸡']='射鸡猎:BAAALAAFFAIIAgAAAA==.',['小冬']='小冬:BAAALAAECgQIBAAAAA==.',['小灰']='小灰灰:BAAALAADCggIDQAAAA==.',['小白']='小白的风宝宝:BAABLAAFFH8GAAIYAAYInBrFDAB7AQAYAAYInBrFDAB7AQAAAA==.',['小落']='小落落:BAAALAAECgYIDAAAAA==.',['小蜡']='小蜡烛:BAAALAAECgYIEAAAAA==.',['小迷']='小迷糊:BAAALAAECgEIAgAAAA==.',['小龙']='小龙弟丶:BAAALAAFFAMIAwAAAA==.',['尾巴']='尾巴掉了哟:BAAALAAECggIAwABLAAFFAIIAgASAAAAAA==.',['屠尽']='屠尽日寇:BAABLAAFFH8eAAIYAAgI1xDWBQAAAgAYAAgI1xDWBQAAAgAAAA==.',['山上']='山上撤也:BAAALAADCgYIBgAAAA==.',['帖拉']='帖拉索一朵:BAAALAAECgEIAQAAAA==.',['幽儿']='幽儿希卡:BAAALAAECggIBQABLAAFFAgIBgAGAEEhAA==.',['弗叮']='弗叮:BAACLAAFFH8MAAIQAAIIRB61MACqAAAQAAIIRB61MACqAAAsAAQKfxQAAhAABggsHORsABACABAABggsHORsABACAAAA.',['弥勒']='弥勒:BAAALAAFFAIIAgAAAA==.',['張滿']='張滿月:BAABLAAFFH8GAAIDAAYIzx9+FwDfAQADAAYIzx9+FwDfAQAAAA==.',['影战']='影战:BAAALAAECgMIAwAAAA==.',['影棠']='影棠:BAAALAAECgYIBgAAAA==.',['影澜']='影澜:BAAALAAFFAIIAgAAAA==.',['影煞']='影煞:BAAALAAECgQIBwAAAA==.',['影璃']='影璃:BAAALAAECgYIBgAAAA==.',['得得']='得得易德德:BAAALAADCggICAABLAAFFAYIBgABABsAAA==.',['德玛']='德玛西亚:BAAALAAECgYIEgAAAA==.',['心太']='心太软丶:BAAALAAFFAMIAwAAAA==.',['心渡']='心渡林海:BAAALAAFFAIIAgAAAA==.',['志摩']='志摩凛:BAAALAAECgQICAAAAA==.',['怎安']='怎安过往:BAAALAAFFAIIAgAAAA==.',['怒风']='怒风:BAACLAAFFH8IAAIFAAIIwB+fHQCsAAAFAAIIwB+fHQCsAAAsAAQKfxUAAwQACAhJI2kVALkCAAQABwiYI2kVALkCAAUABQheEZaEABMBAAAA.',['恒心']='恒心:BAAALAAECgUIDQAAAA==.',['恶魔']='恶魔:BAABLAAFFH8GAAIGAAYITRmMCgAeAgAGAAYITRmMCgAeAgAAAA==.',['愚蠢']='愚蠢的欧豆豆:BAAALAADCgQIBAAAAA==.',['懂事']='懂事的她:BAAALAAECgIIBAAAAA==.',['战马']='战马:BAAALAAFFAIIBAAAAA==.',['扭曲']='扭曲的三分醒:BAABLAAFFH8IAAIJAAIICg5tTwCRAAAJAAIICg5tTwCRAAAAAA==.',['折冲']='折冲:BAAALAAFFAMIAwAAAA==.',['拉普']='拉普拉斯:BAABLAAFFH8SAAIGAAYI9wtRMgBQAQAGAAYI9wtRMgBQAQAAAA==.',['掉泪']='掉泪落某个海:BAAALAAECgQIBAAAAA==.',['撒腿']='撒腿就跑:BAAALAADCgcIBwAAAA==.',['放心']='放心浪:BAAALAAFFAIIAgAAAA==.',['敖隐']='敖隐:BAABLAAFFH8NAAMKAAQIaBsHEgABAQAKAAQIaBsHEgABAQAZAAEI9gk8DwBHAAAAAA==.',['断桥']='断桥残影:BAAALAADCggIDQAAAA==.',['斯卡']='斯卡蒂:BAABLAAFFH8qAAMTAAgIwiXlAQDjAgATAAgIwiXlAQDjAgALAAEI6AMYdAA5AAAAAA==.',['无双']='无双大黄瓜:BAAALAAECgYIBgAAAA==.',['无情']='无情掠夺:BAABLAAFFH8RAAIXAAYI0yREFADwAQAXAAYI0yREFADwAQAAAA==.',['无极']='无极复仇:BAABLAAFFH8NAAIBAAIIxxiUOgCdAAABAAIIxxiUOgCdAAAAAA==.',['旧颜']='旧颜旧人:BAAALAAECgQIBAAAAA==.',['早春']='早春红玉:BAABLAAFFH8MAAIVAAgIIRp8BQBGAgAVAAgIIRp8BQBGAgAAAA==.',['时有']='时有幽花:BAABLAAFFH8XAAINAAUIyRPtEQBSAQANAAUIyRPtEQBSAQAAAA==.',['春天']='春天的花一样:BAAALAAFFAcIBAAAAA==.',['春日']='春日影:BAABLAAFFH8MAAIXAAgIIB/CBQCSAgAXAAgIIB/CBQCSAgAAAA==.',['春泥']='春泥棒:BAAALAAFFAIIAgAAAA==.',['春风']='春风不语:BAABLAAFFH8FAAINAAIItgWQYAA0AAANAAIItgWQYAA0AAAAAA==.',['是小']='是小椿哟:BAAALAAECgUICAAAAA==.',['晒白']='晒白白:BAAALAAECgYIBgAAAA==.',['晨歌']='晨歌:BAAALAADCggICAAAAA==.',['普蕾']='普蕾尔:BAAALAADCggICAAAAA==.',['暗黑']='暗黑佟大为:BAABLAAFFH8VAAIaAAYI3hvCAgCsAQAaAAYI3hvCAgCsAQAAAA==.',['曼巴']='曼巴依旧在:BAAALAAECgYIEAAAAA==.',['曾经']='曾经输出顶点:BAABLAAFFH8eAAIGAAYIQx1vHwChAQAGAAYIQx1vHwChAQAAAA==.',['朋克']='朋克小强:BAAALAAECgUIBQAAAA==.',['来都']='来都来了:BAACLAAFFH8XAAIXAAUIwBTqRwAuAQAXAAUIwBTqRwAuAQAsAAQKfxgAAhcABggAHoVEAMEBABcABggAHoVEAMEBAAEsAAUUBggGAAEAGwAA.',['极品']='极品卡哇伊:BAAALAAECgEIAQAAAA==.',['果断']='果断就会白给:BAABLAAFFH8FAAINAAMISg8POQCQAAANAAMISg8POQCQAAAAAA==.',['栗子']='栗子:BAAALAAFFAIIAgAAAA==.',['椿椿']='椿椿哟:BAAALAAECgYIBgAAAA==.',['樱桃']='樱桃小完犊子:BAABLAAECn8eAAMOAAgIaxj8FwCGAQANAAgIaQyRdQCeAQAOAAcIoRn8FwCGAQAAAA==.',['橘子']='橘子喵酱:BAABLAAFFH8FAAIUAAMI7QI3OACCAAAUAAMI7QI3OACCAAAAAA==.橘子猫酱:BAAALAAECggIAQAAAA==.橘子貓酱:BAAALAAECggIBAAAAA==.',['欧皇']='欧皇:BAAALAAFFAIIAgAAAA==.',['沙曼']='沙曼丶基斯:BAAALAAECgYIBgAAAA==.',['泥河']='泥河:BAAALAAECgYIBgAAAA==.',['海棠']='海棠依旧:BAABLAAFFH8FAAIMAAIIdRGhFACCAAAMAAIIdRGhFACCAAAAAA==.',['海海']='海海先生:BAAALAAECgEIAQAAAA==.',['海马']='海马成长痛:BAABLAAFFH8QAAMWAAUITw8yCgB1AQAWAAUITw8yCgB1AQAKAAIIdAawFwB5AAAAAA==.',['涿州']='涿州卢总:BAAALAAFFAIIAgAAAA==.',['灬麦']='灬麦小兜:BAAALAAFFAIIBAAAAA==.',['然然']='然然:BAABLAAFFH8GAAITAAYIGRo0KwDpAAATAAYIGRo0KwDpAAABLAAFFAgIAQASAAAAAA==.',['燕返']='燕返:BAAALAAECgYIEwAAAA==.',['爱莉']='爱莉杏菜:BAABLAAFFH8FAAIPAAUI7xptBQDWAQAPAAUI7xptBQDWAQAAAA==.',['狂炫']='狂炫富婆画饼:BAABLAAFFH8IAAMZAAgIYBUqBACwAQAZAAYITxkqBACwAQAKAAIIUg6zFgCcAAAAAA==.',['猫霸']='猫霸霸:BAABLAAFFH8NAAMDAAUIhBK4QAA7AQADAAUIhBK4QAA7AQAbAAIIcgCEIAAYAAAAAA==.',['獭嗒']='獭嗒嗒:BAABLAAFFH8KAAMFAAIIch+uMwCcAAAFAAIIch+uMwCcAAAEAAII6w8iHwCOAAAAAA==.',['玄武']='玄武门前互砍:BAAALAAECgUIBQAAAA==.',['王祖']='王祖蓝:BAABLAAFFH8lAAIcAAYIGByfDQCFAQAcAAYIGByfDQCFAQAAAA==.',['甩裤']='甩裤扛把子:BAAALAAECggICAAAAA==.',['田大']='田大黄:BAAALAAECgYIBgAAAA==.',['田泡']='田泡芙:BAAALAAFFAYIBAAAAA==.',['男德']='男德:BAAALAADCgYIBgAAAA==.',['白景']='白景:BAABLAAFFH8LAAQJAAIIEh4oNwCuAAAJAAIIEh4oNwCuAAAdAAEIDiAvHgBKAAAIAAEIhxneDABIAAABLAAFFAgIGAAJAAomAA==.',['看着']='看着浪费:BAABLAAFFH8HAAIDAAIIgBXBWACcAAADAAIIgBXBWACcAAAAAA==.',['瞎子']='瞎子鸡蛋:BAAALAADCgEIAQAAAA==.',['破晓']='破晓晨星:BAAALAAFFAIIBAAAAA==.',['神头']='神头鬼脸:BAABLAAFFH8VAAIBAAYI0ByKFwCwAQABAAYI0ByKFwCwAQAAAA==.',['秋的']='秋的黎明:BAAALAAECgYIDwAAAA==.',['秦始']='秦始皇:BAAALAAECggIBQAAAA==.',['移动']='移动荣誉:BAAALAAECggICgAAAA==.',['穿越']='穿越丛林:BAAALAAECgUIBAAAAA==.',['笑里']='笑里藏刀:BAAALAAECgUICQAAAA==.',['素水']='素水凝香:BAABLAAECn8XAAIDAAgIkh9qLgC9AQADAAgIkh9qLgC9AQAAAA==.',['繁华']='繁华落尽:BAAALAAECgUICwAAAA==.',['红手']='红手常客:BAAALAAFFAIIBAAAAA==.',['绚丽']='绚丽海棠:BAAALAAECgQIBgAAAA==.',['罗玛']='罗玛尼阿其曼:BAAALAAFFAgIAgAAAA==.',['老趴']='老趴菜:BAABLAAECn8cAAIXAAcIZw+AyQBzAQAXAAcIZw+AyQBzAQAAAA==.',['老邦']='老邦桑迪:BAABLAAFFH8GAAMUAAYIpgMEEABAAQAUAAUI1wMEEABAAQAcAAEI0gHGLgA8AAAAAA==.',['老钟']='老钟医:BAAALAADCgYIBwAAAA==.',['芙莉']='芙莉莲:BAAALAAECgIIAgAAAA==.',['芙蓉']='芙蓉王源:BAAALAAFFAQIBAAAAA==.',['芯芯']='芯芯:BAABLAAECn8MAAMDAAYILxt02wB0AQADAAUICBp02wB0AQAaAAMIlBUkPwDiAAAAAA==.',['花落']='花落落:BAAALAAECgYIBgAAAA==.',['范吧']='范吧啦:BAAALAAECgMIAwAAAA==.',['范大']='范大山:BAAALAAECgYICQAAAA==.',['菲尼']='菲尼克:BAAALAAECgYIDgAAAA==.',['萌萌']='萌萌哒鸡蛋饼:BAABLAAFFH8SAAIOAAYIeRT6DgBbAQAOAAYIeRT6DgBbAQAAAA==.',['蒙牛']='蒙牛伊利怒风:BAAALAAECgYIBgAAAA==.',['藍色']='藍色火焰:BAABLAAECn8UAAIdAAYI/xP3QgBkAQAdAAYI/xP3QgBkAQAAAA==.',['藤田']='藤田琴音:BAAALAADCgIIAgAAAA==.',['裹着']='裹着心的光:BAACLAAFFH80AAIYAAcI/iOaAgByAgAYAAcI/iOaAgByAgAsAAQKfyAAAhgACAhcJAIEADYDABgACAhcJAIEADYDAAAA.',['西瓜']='西瓜一号:BAABLAAFFH8GAAIVAAYIERTGBADwAQAVAAYIERTGBADwAQAAAA==.西瓜十三号:BAABLAAFFH8GAAIVAAYIjBBnEQB1AQAVAAYIjBBnEQB1AQAAAA==.西瓜十八号:BAABLAAFFH8IAAIVAAYI1xeqDwCPAQAVAAYI1xeqDwCPAQAAAA==.西瓜十四号:BAABLAAFFH8QAAIVAAgIYBTdBwAPAgAVAAgIYBTdBwAPAgAAAA==.',['让我']='让我先插一个:BAAALAAECgYIEgAAAA==.',['贪狼']='贪狼:BAABLAAECn83AAIRAAgIXBuFDwByAgARAAgIXBuFDwByAgAAAA==.',['贴心']='贴心的邦桑迪:BAAALAADCgMIAwAAAA==.',['起舞']='起舞牛牛:BAABLAAFFH8KAAIYAAcIEhlaBwDeAQAYAAcIEhlaBwDeAQAAAA==.',['邓紫']='邓紫棋:BAACLAAFFH8xAAMQAAgIMxxtBABFAgAQAAgIMxxtBABFAgAVAAUIKyBiDADBAQAsAAQKfxoAAxAACAjwJXwDAIEDABAACAjwJXwDAIEDABUAAgg4IYYyALUAAAAA.',['邵小']='邵小凡:BAAALAADCgYIBgAAAA==.',['邵超']='邵超:BAAALAAFFAIIBAAAAA==.',['醉里']='醉里挑灯看剣:BAABLAAFFH8GAAIYAAYIIg9xEQA2AQAYAAYIIg9xEQA2AQAAAA==.',['闪电']='闪电喷雾:BAABLAAFFH8GAAITAAYI6wCATQA5AAATAAYI6wCATQA5AAAAAA==.',['阿迩']='阿迩萨斯:BAAALAAFFAIIBAAAAA==.',['陪我']='陪我过个冬:BAAALAAFFAYIBAAAAA==.',['雨宫']='雨宫莲:BAAALAAECgYIBwAAAA==.',['雷霆']='雷霆之魔:BAAALAAECgYIBwAAAA==.',['霸战']='霸战:BAAALAAFFAQIBAAAAA==.',['飞哥']='飞哥:BAAALAAFFAIIAgAAAA==.',['魅惑']='魅惑猫猫:BAAALAAECgIIAgAAAA==.',['黑旋']='黑旋风:BAAALAAECgYIBgAAAA==.',['齐莹']='齐莹晴:BAABLAAFFH8GAAINAAYIvxlfFgCrAQANAAYIvxlfFgCrAQAAAA==.',['龅牙']='龅牙珍:BAAALAAFFAQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end