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
 local lookup = {'Mage-Arcane','Mage-Fire','Priest-Discipline','Priest-Shadow','Monk-Mistweaver','Monk-Brewmaster','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Mage-Frost','DeathKnight-Unholy','DeathKnight-Blood','Monk-Windwalker','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Elemental','Shaman-Restoration','Druid-Balance','Paladin-Protection','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Fury','Warrior-Arms','Druid-Restoration','DeathKnight-Frost','Priest-Holy','Warrior-Protection','Unknown-Unknown','Paladin-Holy','Shaman-Enhancement','Rogue-Assassination','Evoker-Devastation','Evoker-Preservation',}; local provider = {region='CN',realm='弗塞雷迦',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ar='Arthurx:BAAAKgAECgUIBQAAAA==.',Bl='Blythefan:BAAAKgAFFAIIAgAAAA==.',Di='Diverdv:BAAAKgAECgMIBAAAAA==.',Et='Eternalmist:BAABKgAFFH8OAAMBAAYIqx0bAgDjAAABAAYIdh0bAgDjAAACAAQI6BUJHQDfAAAAAA==.',Eu='Eugen:BAAAKgAECggICAAAAA==.',Ex='Excalbor:BAAAKgADCggICAAAAA==.',Fa='Fallenangelx:BAAAKgAECgYICwAAAA==.Fancyfoliage:BAAAKgADCgYIBgAAAA==.',Fl='Flynmist:BAAAKgAFFAUIAgAAAA==.',Gr='Grasser:BAAAKgAECgYIBgAAAA==.',Ha='Harley:BAABKgAFFH8GAAMDAAYIGxYNEgDNAAADAAQITgwNEgDNAAAEAAIIjhnpHACeAAAAAA==.Hatsunemiku:BAABKgAECn8YAAMFAAgIlhQRMwCAAQAFAAgIlhQRMwCAAQAGAAEI9AEAAAAAAAAAAA==.',Ix='Ixshishi:BAAAKgAECgcICQAAAA==.',Ja='Jasckrios:BAACKgAFFH8sAAQHAAYIXRWWEACeAAAHAAMIdROWEACeAAAIAAMIXRGMDgB7AAAJAAQIewcUKgBjAAAqAAQKfzEABAkACAj+GxQ9AHcBAAkABwg7FRQ9AHcBAAgABQjoGGRIAMMAAAcAAwgvGUMpALUAAAAA.',Lo='Lolftw:BAAAKgAECgYIDQAAAA==.',Ma='Markooas:BAAAKgADCggICAAAAA==.',Ne='Nemosis:BAAAKgAECgYIBgAAAA==.',Po='Power:BAABKgAFFH8OAAIKAAYIexrWAgCwAQAKAAYIexrWAgCwAQAAAA==.',Sa='Samc:BAABKgAECn8UAAILAAgIch3vGQDlAQALAAgIch3vGQDlAQAAAA==.',So='Solidbear:BAAAKgAECgYIBgAAAA==.',Sp='Splendent:BAAAKgADCggICAAAAA==.',Un='Undefined:BAAAKgAECgEIAQAAAA==.',Us='Ushio:BAABKgAFFH8IAAMMAAQIeh7kDQACAQAMAAQIeh7kDQACAQANAAQIKg8lIwCPAAABKgAFFAgIDgAOANAQAA==.',Va='Valardohaeri:BAAAKgAFFAQIBAAAAA==.',['一头']='一头奶牛:BAABKgAECn8ZAAIMAAgIjRd7MwDkAQAMAAgIjRd7MwDkAQAAAA==.',['一惜']='一惜惜一:BAAAKgAECggICAAAAA==.',['一阳']='一阳阳一:BAAAKgAECgIIAgAAAA==.',['万龙']='万龙:BAAAKgADCgYIBgAAAA==.',['三万']='三万:BAABKgAFFH8NAAMPAAYIrBhcDwCCAQAPAAYI7RVcDwCCAQAQAAUIxAs+GgAaAQAAAA==.',['上杉']='上杉绘梨衣:BAAAKgADCgcIBwAAAA==.',['不过']='不过是玩火:BAAAKgAECgMIBQAAAA==.',['丢了']='丢了你的我:BAAAKgADCgYIBgAAAA==.',['丨假']='丨假面骑士丨:BAAAKgAECgEIAQAAAA==.',['丨好']='丨好多鱼丶:BAABKgAECn8WAAIKAAgIdxjJYwDTAQAKAAgIdxjJYwDTAQAAAA==.',['丨戦']='丨戦神毛毛丨:BAAAKgADCggICAAAAA==.',['丨潜']='丨潜规则丨:BAABKgAFFH8FAAIJAAUIsBscEwBtAQAJAAUIsBscEwBtAQAAAA==.',['丨目']='丨目无王法丨:BAAAKgAECggIEAAAAA==.',['丶姽']='丶姽婳丷:BAAAKgAECggICAAAAA==.',['丶彦']='丶彦祖:BAABKgAFFH8KAAMRAAQIgCQSAwAvAQARAAQIgCQSAwAvAQASAAQI5BUBEwDYAAAAAA==.',['丶朝']='丶朝伟:BAAAKgAFFAIIAgAAAA==.',['丶皮']='丶皮卡丘:BAAAKgADCgYIBgAAAA==.',['丶西']='丶西弗:BAABKgAFFH8GAAISAAYI0QpBFgAqAQASAAYI0QpBFgAqAQAAAA==.',['乌龟']='乌龟的黑头:BAAAKgAFFAUIAQAAAA==.',['九局']='九局下半:BAABKgAFFH8PAAITAAMIMh9WJgD9AAATAAMIMh9WJgD9AAAAAA==.',['云梦']='云梦瑶:BAABKgAFFH8jAAMKAAYIySEnAQDxAQAKAAYIySEnAQDxAQAUAAYI5AxiGAC1AAABKgAFFAgIDQAKAOEYAA==.',['五年']='五年四班丶:BAAAKgAFFAMIAwAAAA==.',['五粮']='五粮液灬:BAABKgAECn8UAAMBAAgIIRCeGQBfAQABAAgIIRCeGQBfAQALAAUIzAuTRgDSAAAAAA==.',['仙人']='仙人板板:BAAAKgAECggICAAAAA==.',['以风']='以风骚惊天下:BAAAKgAECgYIBgAAAA==.',['任意']='任意行:BAAAKgAFFAQIBAAAAA==.',['任朝']='任朝野:BAABKgAFFH8MAAQHAAYIWCHlAQA0AQAJAAYI/RI2GQA6AQAHAAMIriPlAQA0AQAIAAIIfB6qEQBdAAAAAA==.',['伊利']='伊利妲:BAAAKgAFFAQIBAAAAA==.伊利蛋会搓澡:BAAAKgAECgMIAwAAAA==.伊利達雷:BAAAKgAECgMIAwAAAA==.',['伊邪']='伊邪钠镁:BAAAKgAECgEIAgAAAA==.',['体温']='体温零下八十:BAAAKgADCggIDAAAAA==.',['依莎']='依莎貝菈:BAABKgAFFH8GAAIUAAYIZQ1LEgDrAAAUAAYIZQ1LEgDrAAAAAA==.',['信仰']='信仰之光:BAAAKgAECgUICgAAAA==.',['倪久']='倪久依鲁瑟尔:BAACKgAFFH8LAAICAAMIaxbFGgDTAAACAAMIaxbFGgDTAAAqAAQKfyMAAgIACAg6HEERAMgBAAIACAg6HEERAMgBAAAA.',['偷偷']='偷偷射:BAAAKgADCggICAAAAA==.',['元素']='元素灬泯灭:BAAAKgAECgYICQAAAA==.',['克吕']='克吕墨涅:BAAAKgAFFAIIAgAAAA==.',['六筒']='六筒:BAAAKgAECgEIAQAAAA==.',['再見']='再見不見:BAAAKgAFFAIIAgABKgAFFAMIDwATADIfAA==.',['凭正']='凭正气昭乾坤:BAAAKgAECggICAAAAA==.',['凯尔']='凯尔特祭司:BAAAKgAECggICAAAAA==.',['凯蒂']='凯蒂赫尔姆斯:BAAAKgAFFAMIAwAAAA==.',['凶猛']='凶猛小朋友:BAABKgAECn8mAAMVAAgIDhYBMQDqAQAVAAgIVhUBMQDqAQAWAAMI/BIdSgCXAAAAAA==.',['切做']='切做臊子:BAAAKgADCggICAAAAA==.',['列奥']='列奥德罗:BAAAKgADCgcIBwAAAA==.',['别看']='别看我长得丑:BAACKgAFFH8FAAMXAAMItguoJAC+AAAXAAMItguoJAC+AAAYAAEIPgXNHAA7AAAqAAQKfzUAAxcACAhFHuMYAAwCABcACAjXHeMYAAwCABgACAgAFAgbANsBAAAA.别看我长得光:BAAAKgADCggICAAAAA==.别看我长得呆:BAAAKgAECgUIBQABKgAFFAMIBQAXALYLAA==.别看我长得大:BAAAKgAECgYIBgAAAA==.别看我长得妖:BAAAKgAFFAMIAwABKgAFFAMIBQAXALYLAA==.别看我长得小:BAABKgAECn8bAAIQAAgIWBSZNQCEAQAQAAgIWBSZNQCEAQABKgAFFAMIBQAXALYLAA==.别看我长得彪:BAAAKgADCggIGgAAAA==.别看我长得恶:BAAAKgAECggIDgABKgAFFAMIBQAXALYLAA==.别看我长得矮:BAABKgAECn8UAAIMAAgI8htSKwAJAgAMAAgI8htSKwAJAgABKgAFFAMIBQAXALYLAA==.别看我长得花:BAAAKgAFFAMIAwABKgAFFAMIBQAXALYLAA==.别看我长得邪:BAABKgAECn8XAAIIAAgIARWjGgCuAQAIAAgIARWjGgCuAQABKgAFFAMIBQAXALYLAA==.别看我长得靓:BAAAKgAECgcIDQABKgAFFAMIBQAXALYLAA==.',['剩蛋']='剩蛋结:BAAAKgADCggICAAAAA==.',['千隻']='千隻鹤:BAABKgAFFH8GAAIYAAYItw66CgBhAQAYAAYItw66CgBhAQABKgAFFAgIBgAKAG8dAA==.',['午夜']='午夜横行:BAABKgAECn8UAAIPAAgI5h5fGgBjAgAPAAgI5h5fGgBjAgAAAA==.',['卖萌']='卖萌丶不用死:BAABKgAFFH8FAAIKAAMIZASfcACJAAAKAAMIZASfcACJAAAAAA==.',['卡莱']='卡莱斯:BAAAKgAECgYIBgAAAA==.',['原始']='原始圣骑:BAACKgAFFH8MAAIKAAQIxiDUDgAZAQAKAAQIxiDUDgAZAQAqAAQKfx0AAgoACAiwG+9ZAOoBAAoACAiwG+9ZAOoBAAAA.',['双持']='双持信用卡:BAAAKgAECgIIAgAAAA==.',['叛逆']='叛逆人生:BAABKgAFFH8IAAIBAAgIwRx8AgCkAgABAAgIwRx8AgCkAgAAAA==.',['古月']='古月虎:BAABKgAFFH8OAAMQAAYIchd2AQCmAQAQAAYIQRV2AQCmAQAPAAQIaRO4GADNAAAAAA==.',['叨叨']='叨叨个没完:BAAAKgAECgEIAQAAAA==.',['史密']='史密斯北:BAAAKgAECgIIBAAAAA==.',['叶赫']='叶赫那拉香:BAAAKgAFFAEIAQAAAA==.',['吃骨']='吃骨头的鱼:BAAAKgAECgEIAQAAAA==.吃骨头的鱼灬:BAAAKgAFFAEIAQAAAA==.',['呆萌']='呆萌哼特:BAAAKgADCgYIBgAAAA==.',['咔壳']='咔壳勒呦:BAAAKgADCggICAAAAA==.',['咖啡']='咖啡猎手:BAAAKgAECgcIBwAAAA==.',['咪朵']='咪朵儿:BAAAKgADCgEIAQAAAA==.',['咬不']='咬不断的痰:BAABKgAFFH8MAAINAAgIPRNNBQDwAQANAAgIPRNNBQDwAQAAAA==.',['唐就']='唐就是啥吊:BAAAKgAECggICAAAAA==.',['啥玩']='啥玩意:BAAAKgADCgQIBAAAAA==.',['啫啫']='啫啫牛蛙煲:BAAAKgAECgEIAQAAAA==.',['喝后']='喝后摇一摇:BAAAKgADCggIEAAAAA==.',['嗯哼']='嗯哼丶繼續:BAAAKgADCgYIBgAAAA==.',['嘎里']='嘎里克布莱德:BAABKgAFFH8IAAMTAAYI9x3FIwAKAQATAAMIWBzFIwAKAQAZAAQIORpzFwDlAAAAAA==.',['嘴哥']='嘴哥头号舔狗:BAAAKgADCgYIBgAAAA==.',['嘸豳']='嘸豳:BAAAKgADCgIIAgAAAA==.',['嚯嚯']='嚯嚯:BAAAKgADCggICAAAAA==.',['四喜']='四喜丸子:BAACKgAFFH8KAAISAAMIWwOKQwB4AAASAAMIWwOKQwB4AAAqAAQKfx8AAhIACAgZCtVgAB0BABIACAgZCtVgAB0BAAAA.四喜九子:BAABKgAFFH8LAAMSAAYI0AGXIwDpAAASAAUI0AGXIwDpAAARAAQIYAhRDQDAAAAAAA==.',['回首']='回首心远:BAACKgAFFH8HAAMaAAQIUwlkDQCSAAAaAAQIUwlkDQCSAAAMAAEI5wEAVwAtAAAqAAQKfxcAAxoACAgPFtcJAMIBABoACAgPFtcJAMIBAAwABwiGCKiVAKcAAAAA.',['因为']='因为你人善呐:BAAAKgAFFAUIAQAAAA==.',['圆圆']='圆圆哒蘑菇酱:BAAAKgAECggIEQAAAA==.',['圣园']='圣园未花:BAAAKgAECgIIAgABKgAFFAMICgAIAG8dAA==.',['地之']='地之尽痕:BAAAKgADCggICAAAAA==.',['堕落']='堕落大酋长:BAAAKgAECgMIAwAAAA==.',['壞儿']='壞儿:BAAAKgADCgIIAgAAAA==.',['夙翼']='夙翼:BAACKgAFFH8VAAMPAAMI5RaFMQDHAAAPAAMINhaFMQDHAAAQAAMIyxDqLgCxAAAqAAQKfyUAAw8ACAgjIO83ABYCAA8ACAjJHO83ABYCABAACAh9GVkwAJ4BAAAA.',['夜影']='夜影月:BAAAKgAECgIIAgAAAA==.',['夜琅']='夜琅故人:BAAAKgADCgQIBwAAAA==.',['夜耿']='夜耿耿而不寐:BAABKgAFFH8KAAIbAAYIgx6MBQC/AQAbAAYIgx6MBQC/AQAAAA==.',['夜魇']='夜魇:BAABKgAFFH8GAAINAAYIZBegDABKAQANAAYIZBegDABKAQAAAA==.',['大公']='大公主的双剑:BAABKgAFFH8GAAMVAAMIYQ3FLACBAAAVAAIIYQ3FLACBAAAWAAIIOAIqHAApAAABKgAFFAgIEgAVAJgVAA==.',['大泽']='大泽玛莉亚:BAAAKgAFFAQIBAAAAA==.',['大笨']='大笨牛牛:BAABKgAFFH8GAAMXAAQIyRPKEQDzAAAXAAQIdA/KEQDzAAAcAAII1RRiEQBxAAAAAA==.',['大脚']='大脚怪:BAAAKgADCggICAAAAA==.',['大脸']='大脸猫警长:BAAAKgADCgIIAgAAAA==.',['天童']='天童爱丽丝:BAAAKgADCgUIBQABKgAFFAMICgAIAG8dAA==.',['天赋']='天赋异禀:BAAAKgADCgEIAQAAAA==.',['太空']='太空碗豆:BAAAKgADCgEIAQAAAA==.',['夯劦']='夯劦:BAAAKgADCgMIAwAAAA==.',['夹不']='夹不断的翔:BAAAKgAECggIDAAAAA==.',['奎托']='奎托斯:BAABKgAFFH8IAAITAAQItiABJAAJAQATAAQItiABJAAJAQABKgAFFAgIAgAdAAAAAA==.',['奢香']='奢香夫人:BAAAKgADCggICAAAAA==.',['妙手']='妙手回春:BAABKgAFFH8GAAMEAAYIpRsIFADEAAAEAAII6h0IFADEAAAbAAQIJgVlMACEAAAAAA==.',['孤魂']='孤魂染月:BAAAKgAECgIIAgAAAA==.',['安于']='安于长情:BAAAKgAFFAIIAgAAAA==.',['宝宝']='宝宝嗷嗷叫:BAAAKgADCgUIBQAAAA==.',['宫内']='宫内莲华:BAAAKgADCggICAAAAA==.',['寂寞']='寂寞的收获:BAAAKgAECgEIAQAAAA==.',['小凶']='小凶许:BAAAKgAFFAQIBAAAAA==.',['小叨']='小叨叨:BAABKgAECn8nAAIeAAgIiAkjEgDyAAAeAAgIiAkjEgDyAAAAAA==.',['小坏']='小坏坏:BAAAKgADCggICAAAAA==.',['小拳']='小拳拳锤你:BAAAKgADCgMIAwAAAA==.',['小木']='小木士丶:BAAAKgAECggIEAAAAA==.',['小牛']='小牛开口笑:BAAAKgAFFAIIAgAAAA==.',['小西']='小西几:BAAAKgAFFAYIAgAAAA==.',['小香']='小香猪:BAAAKgAECgQIBwAAAA==.',['小鸟']='小鸟游星野:BAACKgAFFH8KAAQIAAMIbx01IgBXAAAIAAEI5yM1IgBXAAAHAAEIixqOIQBGAAAJAAEI2hkKNQA6AAAqAAQKfyIABAgACAhzH6QXALsBAAgACAjwG6QXALsBAAcABAhDGt4ZACEBAAkABAgfI8I/AAwBAAAA.',['尐尐']='尐尐戀歌:BAABKgAFFH8OAAMDAAYI0xJTDABQAQADAAYI0xJTDABQAQAEAAYIiBQOCwBOAQAAAA==.',['屠苏']='屠苏:BAACKgAFFH8QAAMDAAQIeBu4CwD3AAADAAQIeBu4CwD3AAAEAAMIAiB7EwDiAAAqAAQKfxsAAgQACAhAHxgRAFoCAAQACAhAHxgRAFoCAAAA.',['幸运']='幸运小绿人:BAAAKgAFFAYIBAAAAA==.幸运小蓝人:BAABKgAFFH8MAAMfAAgI+CKZAADqAgAfAAgI+CKZAADqAgASAAQImBbzLQC/AAAAAA==.',['幻灵']='幻灵笙羽:BAAAKgADCgcIBwAAAA==.',['张叔']='张叔叔:BAAAKgAFFAIIAgAAAA==.',['彼岸']='彼岸德:BAAAKgAFFAMIAwAAAA==.',['很难']='很难射到你:BAAAKgAECgEIAQAAAA==.',['御宅']='御宅族:BAAAKgADCgcIBwAAAA==.',['德莱']='德莱萨:BAEAKgAFFAgIAgAAAA==.',['德魯']='德魯伊娃:BAAAKgAECgMIBgAAAA==.',['德鲁']='德鲁尼:BAAAKgAECgYIBwAAAA==.',['念念']='念念:BAAAKgADCggICAAAAA==.',['恩赐']='恩赐解脱:BAAAKgADCgIIAgAAAA==.',['恶灬']='恶灬魔大灬师:BAAAKgAFFAMIAwAAAA==.',['恶灵']='恶灵织牧:BAAAKgADCggICgAAAA==.',['悠然']='悠然:BAAAKgADCgIIAgAAAA==.',['惊天']='惊天风骚:BAAAKgAECgcIEQAAAA==.',['我只']='我只是个桐铃:BAAAKgADCggIDwAAAA==.',['我就']='我就是小屁孩:BAAAKgADCgcIDgAAAA==.',['我想']='我想抓只小德:BAAAKgAECgUICwAAAA==.',['我會']='我會飛行:BAAAKgAFFAIIAgAAAA==.',['我本']='我本:BAAAKgAECggIDgAAAA==.我本纯真丶:BAAAKgAFFAYIAQAAAA==.',['我用']='我用欧莱雅:BAABKgAFFH8GAAIVAAYIiQwZDwBOAQAVAAYIiQwZDwBOAQAAAA==.',['戒了']='戒了个律:BAACKgAFFH8QAAQbAAYIKhh8CgDhAAADAAMIFh+PEwD8AAAbAAQI6Bh8CgDhAAAEAAII9AqRFwCmAAAqAAQKfxsAAgMACAgAHH8VABgCAAMACAgAHH8VABgCAAAA.',['战峰']='战峰:BAAAKgADCggIDQAAAA==.',['所谓']='所谓永生:BAAAKgAECggICAAAAA==.',['托尼']='托尼贝贝:BAAAKgAFFAQIBAAAAA==.',['把门']='把门开开:BAAAKgAECgIIAgAAAA==.',['抹茶']='抹茶培根:BAAAKgAECgUIBgAAAA==.',['拔起']='拔起树根然后:BAACKgAFFH8NAAITAAQIOCOcDwD9AAATAAQIOCOcDwD9AAAqAAQKfyMAAxMACAjAJJcVAIUCABMACAjAJJcVAIUCABkABAgaE7xJALsAAAAA.',['无敌']='无敌女:BAAAKgAFFAYIAgAAAA==.',['星丶']='星丶空:BAAAKgAFFAYIBAAAAA==.',['春日']='春日影:BAAAKgAFFAYIAwABKgAFFAgIBgANABkJAA==.',['晚桥']='晚桥:BAAAKgAFFAIIAgAAAA==.',['晨光']='晨光下的战尸:BAAAKgAECgMIAwAAAA==.',['最初']='最初的一个吻:BAABKgAECn8VAAMXAAgIvhUoKwCLAQAXAAcIbRQoKwCLAQAcAAUICgt4NACaAAAAAA==.',['月神']='月神血之舞:BAAAKgAFFAIIAgAAAA==.',['有媳']='有媳妇儿的猪:BAAAKgAFFAIIAgAAAA==.',['有猫']='有猫腻:BAAAKgAECggIEAAAAA==.',['木有']='木有鱼丸:BAAAKgADCggIDwAAAA==.',['杜老']='杜老四:BAAAKgADCgEIAQAAAA==.',['東方']='東方教主:BAAAKgAECggICAAAAA==.',['极寒']='极寒灬冰霜:BAABKgAFFH8GAAMLAAYIYRZUDQDBAAACAAIISSAZHgDBAAALAAQIxg9UDQDBAAABKgAFFAgIDgACAMMiAA==.',['林凤']='林凤云:BAABKgAFFH8WAAQbAAgIKiDaAAB+AQADAAgIHx8vAgBhAgAbAAgIvBnaAAB+AQAEAAEIzxPUIgBRAAAAAA==.',['枫林']='枫林唱晚:BAAAKgAFFAgIBAAAAA==.',['柒月']='柒月涅槃:BAABKgAECn8XAAIKAAgI1RdHXQDiAQAKAAgI1RdHXQDiAQAAAA==.',['格了']='格了个格:BAABKgAFFH8GAAITAAYIXBJYGgBHAQATAAYIXBJYGgBHAQAAAA==.',['梦回']='梦回唐朝:BAAAKgADCggIDAAAAA==.',['梦幻']='梦幻芭比:BAABKgAFFH8IAAMbAAMIdwbzGAB5AAAbAAMIdwbzGAB5AAAEAAIIOwbMFwBZAAABKgAFFAgIIAAQALoYAA==.',['椰风']='椰风挡不住:BAACKgAFFH8HAAIQAAIIxSMMFgCxAAAQAAIIxSMMFgCxAAAqAAQKfxMAAhAACAiNJHkFAMkCABAACAiNJHkFAMkCAAAA.',['模拟']='模拟烤羊肉:BAAAKgADCgcICAAAAA==.',['欧吉']='欧吉酱:BAABKgAFFH8KAAMIAAYIOR6rAQA2AQAJAAYI6BxJDQC3AQAIAAQIzyKrAQA2AQABKgAFFAgIFgAJAOgSAA==.',['死亡']='死亡咆哮:BAAAKgAECgMIAwAAAA==.',['汏苯']='汏苯疍:BAABKgAFFH8FAAICAAUIoxT4CgBJAQACAAUIoxT4CgBJAQAAAA==.',['法師']='法師娃:BAACKgAFFH8LAAIJAAQIQhv2EgDZAAAJAAQIQhv2EgDZAAAqAAQKfxgAAwkACAi1INYVAPgBAAkACAjdHtYVAPgBAAgAAQhTH71pAF0AAAEqAAUUCAglAAcAIRwA.',['波萝']='波萝虎:BAAAKgADCgEIAQAAAA==.',['流云']='流云软软:BAABKgAFFH8GAAIPAAYIrwldGQAyAQAPAAYIrwldGQAyAQAAAA==.',['深更']='深更半夜:BAAAKgADCgMIAwAAAA==.',['温妮']='温妮丶莉莉:BAAAKgADCgUIBgAAAA==.',['满身']='满身雪花肉:BAAAKgAECgcIBQAAAA==.',['漂泊']='漂泊千里的贼:BAABKgAFFH8RAAMBAAgIAhrHBABSAgABAAgIAhrHBABSAgALAAMInxUMEgDSAAAAAA==.',['漠北']='漠北狐:BAAAKgAECgQIBAAAAA==.',['潘诺']='潘诺佩亚:BAAAKgAFFAMIBAAAAA==.',['火舞']='火舞劣劣:BAAAKgAECgcICAAAAA==.',['火车']='火车侠:BAAAKgAECgEIAQAAAA==.',['火雲']='火雲:BAAAKgAECgYIBwAAAA==.',['火鸡']='火鸡味锅巴:BAAAKgAECggICAAAAA==.',['灬罒']='灬罒灬:BAAAKgADCgcICQAAAA==.',['灰角']='灰角:BAAAKgADCgEIAQAAAA==.',['灵之']='灵之仲达:BAABKgAFFH8VAAMFAAgICxrLAgBhAgAFAAgICxrLAgBhAgAOAAEIXwH/GgBQAAAAAA==.',['灵异']='灵异之光:BAAAKgAECgEIAQAAAA==.',['灵心']='灵心若溪:BAAAKgADCggICAAAAA==.',['炎子']='炎子江:BAAAKgADCggICwAAAA==.',['炭烤']='炭烤鸡软骨:BAAAKgAECgMIAwAAAA==.',['烈焰']='烈焰珏仔:BAAAKgAECggICAAAAA==.',['熊猫']='熊猫滑翔者:BAAAKgAFFAEIAgAAAA==.',['爪子']='爪子要放上边:BAAAKgAECgMIAwAAAA==.',['爱与']='爱与救赎:BAAAKgADCgMIAwAAAA==.',['父亲']='父亲:BAABKgAFFH8VAAIKAAgIsRtVDwDnAQAKAAgIsRtVDwDnAQAAAA==.',['牧阿']='牧阿师:BAAAKgAECgMIBAAAAA==.',['狂野']='狂野的阿昆达:BAAAKgAECggICAAAAA==.',['狼大']='狼大灰:BAAAKgAECgYIBgAAAA==.',['猫小']='猫小乐:BAAAKgAECgQIBAAAAA==.',['玄灵']='玄灵:BAABKgAFFH8LAAISAAYIjx8KAwBSAQASAAYIjx8KAwBSAQAAAA==.玄灵之舞:BAAAKgAECgcIBwAAAA==.',['玛卡']='玛卡巴卡丶:BAAAKgAFFAQIBAAAAA==.',['玛尔']='玛尔斯大帝:BAAAKgADCgQIBAAAAA==.',['电疗']='电疗萨:BAAAKgAECgEIAQAAAA==.',['电车']='电车侠:BAAAKgAFFAMIAwAAAA==.',['画画']='画画的卑鄙:BAAAKgAECggICAAAAA==.',['疯僧']='疯僧醉菩提:BAAAKgAECgMIAwAAAA==.',['病态']='病态伊利亚:BAAAKgADCgIIAgAAAA==.',['白露']='白露成霜:BAAAKgAECgIIAgAAAA==.',['皇灬']='皇灬诺加娜:BAABKgAFFH8MAAMPAAQIxxnlMQDGAAAPAAQIARblMQDGAAAQAAQILBauLQC1AAAAAA==.',['皮尔']='皮尔斯:BAAAKgAFFAQIBAAAAA==.皮尔斯北:BAABKgAFFH8GAAIgAAYIuA2WDwBXAQAgAAYIuA2WDwBXAQAAAA==.皮尔斯布鲁:BAABKgAFFH8IAAIhAAgIsheqBwALAgAhAAgIsheqBwALAgAAAA==.',['神避']='神避:BAABKgAFFH8IAAINAAgIShNTBgDNAQANAAgIShNTBgDNAQAAAA==.',['祸事']='祸事油子:BAAAKgADCggICAAAAA==.',['禁咒']='禁咒师:BAAAKgAFFAQIBAABKgAFFAgICgAKAK0lAA==.',['秋山']='秋山雪月漠惜:BAAAKgAFFAEIAQAAAA==.',['稀里']='稀里糊涂:BAAAKgADCggICAAAAA==.',['程哥']='程哥:BAAAKgAECgYIBgAAAA==.',['穆拉']='穆拉釘丶石须:BAAAKgADCgMIAwAAAA==.',['策马']='策马轻烟:BAABKgAFFH8GAAIKAAYILxuCGQCTAQAKAAYILxuCGQCTAQAAAA==.',['粉红']='粉红毛兔兔:BAABKgAFFH8IAAMDAAQINxiLDQDpAAADAAQINxiLDQDpAAAbAAQI/RCUDgDJAAAAAA==.',['纯爱']='纯爱骑士:BAABKgAFFH8GAAIKAAYIHgnEYQCsAAAKAAYIHgnEYQCsAAAAAA==.',['线球']='线球萌喵:BAABKgAFFH8FAAITAAUIYw3RJgD6AAATAAUIYw3RJgD6AAAAAA==.',['绝对']='绝对小猛汉:BAEAKgAFFAMIAwABKgAFFAgIAgAdAAAAAA==.',['维生']='维生素蒂:BAAAKgAFFAQIBAAAAA==.',['维纳']='维纳斯的诅咒:BAACKgAFFH8GAAICAAIImw1XLwCNAAACAAIImw1XLwCNAAAqAAQKfxQAAgIACAhNGSUoAAcCAAIACAhNGSUoAAcCAAAA.',['罓波']='罓波澜不惊罓:BAAAKgADCggICAAAAA==.',['美型']='美型师:BAAAKgAECgYIBgAAAA==.',['耀西']='耀西:BAABKgAFFH8TAAMhAAgIohc7CgDPAQAhAAgIohc7CgDPAQAiAAQIxxMnBADSAAAAAA==.',['老板']='老板是只猫:BAAAKgAECgEIAQAAAA==.',['老演']='老演员了:BAAAKgADCggIDwAAAA==.',['胡大']='胡大仙:BAAAKgAECgYICwAAAA==.',['胭脂']='胭脂酒椛间醉:BAABKgAFFH8SAAMbAAYIphriCwBlAQAbAAYIphriCwBlAQADAAQIgxPnGwC2AAABKgAFFAgIHwAEAAoWAA==.',['舒化']='舒化奶:BAAAKgADCggICAAAAA==.',['艾尔']='艾尔文娜:BAAAKgADCggICAAAAA==.',['艾米']='艾米斯菲尔:BAABKgAFFH8FAAISAAMI0Ab3GQC7AAASAAMI0Ab3GQC7AAAAAA==.',['芒芒']='芒芒露露:BAAAKgAECgYIBgAAAA==.',['芹泽']='芹泽多摩熊:BAAAKgAFFAYIAwAAAA==.',['莫利']='莫利亚提:BAAAKgAFFAQIBAAAAA==.',['莫提']='莫提斯:BAACKgAFFH83AAIOAAgIVSTLAgBnAgAOAAgIVSTLAgBnAgAqAAQKfzwAAw4ACAhxJpgBAAcDAA4ACAhxJpgBAAcDAAYAAQjqA64nAAoAAAAA.',['莫问']='莫问:BAAAKgADCggICAAAAA==.',['菜鸡']='菜鸡互啄:BAABKgAFFH8QAAMVAAQIuBjHEgD1AAAVAAQIuBjHEgD1AAAWAAMIJQ9XFgCVAAAAAA==.',['菠萝']='菠萝小虎:BAAAKgADCgYIBgAAAA==.',['蒙上']='蒙上眼睛瞎干:BAABKgAFFH8KAAIVAAgI+RvkAwCGAgAVAAgI+RvkAwCGAgAAAA==.',['蒙牛']='蒙牛奶液:BAAAKgAECgQICAAAAA==.',['蓝魔']='蓝魔:BAAAKgAECgUICAAAAA==.',['蔚然']='蔚然橙风:BAABKgAFFH8KAAIVAAMImBzIKADTAAAVAAMImBzIKADTAAAAAA==.',['蝶丶']='蝶丶雨:BAAAKgAECgcIDAAAAA==.',['血与']='血与诗人:BAAAKgADCggIDwAAAA==.',['血色']='血色珊瑚骑:BAAAKgAFFAQIBAAAAA==.',['行不']='行不行:BAAAKgADCggICAAAAA==.',['術士']='術士娃:BAABKgAFFH8MAAMBAAYIPxmyEABkAQABAAYIPxmyEABkAQALAAYIsQiuCwAPAQAAAA==.',['要帥']='要帥一辈子:BAABKgAFFH8GAAIYAAYIsg9iGADGAAAYAAYIsg9iGADGAAAAAA==.',['论持']='论持久战:BAAAKgAECgMIAwAAAA==.',['诗雨']='诗雨馨竹:BAAAKgAECgEIAQAAAA==.',['財神']='財神儿:BAAAKgAFFAQIAQAAAA==.',['赛巴']='赛巴斯:BAAAKgADCgYIBgAAAA==.',['赛拉']='赛拉斐:BAACKgAFFH8KAAIeAAMIGBBBEADAAAAeAAMIGBBBEADAAAAqAAQKfxgABAoACAgaD0aiAFMBAAoACAgaD0aiAFMBAB4ABgjOEu8lAC8BABQAAQhAC3FhACQAAAAA.',['起什']='起什么名字:BAAAKgAECgIIAgAAAA==.',['起名']='起名字好难:BAAAKgAECgUIBQAAAA==.',['蹦蹦']='蹦蹦兔兔:BAAAKgAECgEIAQAAAA==.',['那谁']='那谁家老谁:BAAAKgADCgcICQAAAA==.',['醉暧']='醉暧馬娓:BAABKgAECn8WAAMLAAgIZBqvMwCiAQALAAgIZBqvMwCiAQACAAIINgj5iQBnAAABKgAFFAgIEAAPAKobAA==.',['野狼']='野狼伊恩:BAAAKgAFFAQIBAAAAA==.',['銳雯']='銳雯:BAABKgAECn8eAAMMAAgIlxpkLADKAQAMAAgIbhlkLADKAQANAAcIJw6mMQALAQAAAA==.',['鋭雯']='鋭雯:BAAAKgAFFAYIAwAAAA==.',['鏹顏']='鏹顏煥啸:BAAAKgADCgcIBwAAAA==.',['钚莨']='钚莨少哖丨:BAAAKgAECgQIBAAAAA==.',['钮扣']='钮扣熊:BAAAKgAFFAgIBAAAAA==.',['闪现']='闪现撞墙君:BAAAKgAFFAIIAgAAAA==.',['阿尔']='阿尔忒猊斯:BAAAKgADCggICAAAAA==.',['阿芙']='阿芙洛狄忒:BAAAKgADCggICAAAAA==.',['陈刀']='陈刀崽:BAAAKgAFFAQIBAAAAA==.',['随风']='随风浪天涯:BAAAKgAECgMIAwAAAA==.',['霉媚']='霉媚:BAAAKgADCggICAAAAA==.',['露米']='露米娅:BAABKgAFFH8GAAIOAAYIww6kAgCVAQAOAAYIww6kAgCVAQAAAA==.',['青玉']='青玉德德:BAABKgAFFH8JAAMPAAMIbxjgKwDWAAAPAAMIbxjgKwDWAAAQAAEIKgoDVAAxAAAAAA==.青玉德沙比:BAAAKgAFFAEIAQAAAA==.',['青面']='青面槽牙:BAAAKgAECgYIBgAAAA==.',['静流']='静流:BAAAKgAECgcICAAAAA==.',['頹廢']='頹廢的溫柔:BAABKgAFFH8HAAIMAAcI4ArPCQCKAQAMAAcI4ArPCQCKAQAAAA==.',['领悟']='领悟人生:BAAAKgAECgQIBQAAAA==.',['風之']='風之紫电:BAABKgAECn8YAAISAAgIqgi5aQDvAAASAAgIqgi5aQDvAAAAAA==.',['風雨']='風雨中的油条:BAAAKgADCggICAAAAA==.',['风高']='风高月黑:BAAAKgADCgIIAgAAAA==.',['飞雪']='飞雪云峰:BAAAKgADCgYICwAAAA==.',['香浓']='香浓一刻:BAABKgAFFH8KAAINAAYItR7LAADbAQANAAYItR7LAADbAQAAAA==.香浓那一刻:BAABKgAFFH8IAAMIAAYIGBq6AABgAQAIAAUIhhi6AABgAQAJAAII8iC7MgClAAABKgAFFAgIDAAJAMocAA==.',['香狐']='香狐女孩:BAAAKgAFFAQIBAABKgAFFAgIBgAMAB0dAA==.',['骨感']='骨感妹妹:BAAAKgADCggIEQAAAA==.',['魅塔']='魅塔骑士:BAAAKgAFFAYIBAAAAA==.',['魔法']='魔法舅妈:BAAAKgAECgQIBAAAAA==.',['鲍鱼']='鲍鱼红烧肉:BAAAKgAECgUIBQAAAA==.',['黑白']='黑白小朋友:BAAAKgADCggICAAAAA==.',['黑羽']='黑羽玄墨:BAABKgAFFH8FAAIKAAUIoQzsQADuAAAKAAUIoQzsQADuAAAAAA==.',['黑翼']='黑翼降临:BAABKgAFFH8GAAIQAAYIEBgVCwBiAQAQAAYIEBgVCwBiAQAAAA==.',['龘赑']='龘赑赑:BAAAKgAFFAYIAgAAAA==.',['龙夕']='龙夕灬:BAAAKgAECgEIAQAAAA==.',['龙当']='龙当当:BAAAKgADCgIIBAAAAA==.',['龙空']='龙空空:BAAAKgADCgUIBAAAAA==.',['龙车']='龙车侠:BAAAKgAECgYIDAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end