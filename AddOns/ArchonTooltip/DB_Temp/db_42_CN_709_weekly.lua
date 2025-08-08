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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Shaman-Restoration','Druid-Balance','Druid-Restoration','Evoker-Devastation','Mage-Arcane','Mage-Fire','Priest-Discipline','Priest-Holy','Priest-Shadow','Warrior-Fury','DeathKnight-Blood','Monk-Mistweaver','DemonHunter-Havoc','Unknown-Unknown','Paladin-Retribution','Hunter-BeastMastery','DeathKnight-Unholy','Mage-Frost','Monk-Brewmaster','Monk-Windwalker','Paladin-Protection','DeathKnight-Frost','DemonHunter-Vengeance','Hunter-Marksmanship','Warlock-Affliction','Shaman-Elemental','Warrior-Arms','Warrior-Protection','Paladin-Holy','Druid-Feral','Druid-Guardian',}; local provider = {region='CN',realm='末日祷告祭坛',name='CN',type='weekly',zone=42,date='2025-08-08',data={Am='Amelie:BAABKgAECn8YAAMBAAgI6x+oCAAWAgABAAgIUhyoCAAWAgACAAEIsiD4bABfAAAAAA==.',An='Andy:BAABKgAFFH8NAAIDAAUIHCWkBwCgAQADAAUIHCWkBwCgAQAAAA==.',Ba='Baby:BAABKgAFFH8HAAMEAAcIZQghEwAuAQAEAAYIhwghEwAuAQAFAAEIlQN4GAA6AAAAAA==.Bahting:BAAAKgAECgcIDAAAAA==.',Be='Beyllos:BAABKgAFFH8IAAIGAAgIHxZ+BQA4AgAGAAgIHxZ+BQA4AgAAAA==.',Bi='Biteme:BAACKgAFFH8OAAMHAAgIJCA2AgCvAgAHAAgInR42AgCvAgAIAAQIaRo7FAD+AAAqAAQKfx8AAggACAgEIZcUAHoCAAgACAgEIZcUAHoCAAAA.',Ch='Chene:BAAAKgADCggICAAAAA==.Chenelle:BAABKgAFFH8HAAQJAAIItRd/JQCJAAAJAAII5RZ/JQCJAAAKAAIIkRHMNgBlAAALAAEImgItMwAoAAAAAA==.Chloé:BAAAKgAECggIEgAAAA==.',Cr='Crossdark:BAAAKgADCggICAAAAA==.',De='Destruction:BAAAKgAECgEIAQAAAA==.',Dr='Dreamsuperma:BAAAKgAFFAEIAQAAAA==.',Fa='Fallenstar:BAAAKgAFFAEIAQAAAA==.',Jo='Jokerno:BAABKgAFFH8IAAIMAAgIMw17BwDqAQAMAAgIMw17BwDqAQAAAA==.',Ke='Keluotar:BAAAKgAECgUIBgAAAA==.',Li='Lilamy:BAAAKgAECgUIBQAAAA==.',Lu='Lucokysm:BAAAKgAECgcICgAAAA==.Lucokyws:BAAAKgAECgEIAgAAAA==.Lunar:BAABKgAFFH8IAAIFAAYI5B7IAADcAQAFAAYI5B7IAADcAQAAAA==.',Me='Methadon:BAABKgAFFH8MAAINAAYI7Q/HEgALAQANAAYI7Q/HEgALAQAAAA==.',Mi='Miiracle:BAABKgAFFH8LAAIBAAQIAQ3YGAC4AAABAAQIAQ3YGAC4AAAAAA==.',Mo='Monster:BAAAKgADCggIEAAAAA==.Morphinee:BAAAKgAECggICwAAAA==.',Od='Oddinn:BAAAKgAECgYICAAAAA==.',Ol='Oleria:BAAAKgAECgEIAQAAAA==.',On='Oneforall:BAAAKgAECgIIAgAAAA==.',Pe='Pepe:BAABKgAFFH8LAAIOAAgIUxLJBQDvAQAOAAgIUxLJBQDvAQABKgAFFAgIEQAOAHIfAA==.',Pl='Playerwrlyvu:BAABKgAFFH8GAAIPAAYILRSrEgBmAQAPAAYILRSrEgBmAQAAAA==.',Pr='Prionailurus:BAAAKgAFFAQIBAAAAA==.Protectme:BAAAKgAFFAEIAQAAAA==.',Sa='Salina:BAAAKgADCggICAAAAA==.',Sh='Shallowdream:BAABKgAECn8XAAMCAAgIYx/WCwAsAgACAAgIYx/WCwAsAgABAAEIDwfxuwAUAAAAAA==.Shiron:BAAAKgAECggIEAAAAA==.',Si='Siamq:BAAAKgADCggICgABKgAFFAQIBAAQAAAAAA==.',St='Strive:BAACKgAFFH8IAAIRAAgIpiRZAgDSAgARAAgIpiRZAgDSAgAqAAQKfxQAAhEACAiIIeIiAI4CABEACAiIIeIiAI4CAAAA.',Te='Terisyhelico:BAAAKgADCggIAwAAAA==.',Wa='Warglaive:BAABKgAFFH8MAAIPAAIIZxlDJgCZAAAPAAIIZxlDJgCZAAAAAA==.',Ye='Yeerell:BAAAKgADCggICgAAAA==.Yertstts:BAAAKgADCgEIAQAAAA==.',['一刀']='一刀一咕咕:BAABKgAFFH8IAAMEAAgIAxTjDQC7AQAEAAcIFxLjDQC7AQAFAAEIyhUdMwBMAAAAAA==.',['一口']='一口啃死你:BAAAKgAECgQIBAAAAA==.',['一坛']='一坛烧肉:BAAAKgADCggIEAAAAA==.',['一恐']='一恐菊花漏:BAABKgAFFH8OAAMBAAQIgxaRJQDdAAABAAQIgxaRJQDdAAACAAIIhAPbGQAoAAAAAA==.',['一茉']='一茉星星一:BAAAKgAECgUIBQAAAA==.',['一锅']='一锅烧肉:BAAAKgAECggIEwAAAA==.',['一颗']='一颗小豆子:BAAAKgAECggICQAAAA==.',['七安']='七安:BAAAKgAECgcICQABKgAFFAQIBwAJALUXAA==.',['万剑']='万剑穿心:BAABKgAFFH8KAAISAAMIRRseJwDpAAASAAMIRRseJwDpAAAAAA==.',['三角']='三角初华:BAAAKgAECggICQAAAA==.',['不干']='不干活的瘸子:BAABKgAFFH8HAAMNAAYIvx4NCACcAQANAAYIvx4NCACcAQATAAEIBxc0MABIAAAAAA==.',['东方']='东方丶夏:BAAAKgADCgUIBQAAAA==.',['两头']='两头蛇解珍:BAAAKgAECgUIBQAAAA==.',['丨天']='丨天火丨:BAABKgAFFH8NAAISAAMI5RyfJQDwAAASAAMI5RyfJQDwAAAAAA==.',['丨旺']='丨旺旺丶:BAAAKgAECgcIBwAAAA==.',['丨煲']='丨煲仔饭丶:BAAAKgADCggIEAAAAA==.',['丨王']='丨王主任丨:BAAAKgAECggICwAAAA==.丨王师傅丨:BAAAKgAECggIDwAAAA==.',['丶下']='丶下课闹闹:BAAAKgADCgYIBgAAAA==.',['丶丨']='丶丨淋漓尽致:BAABKgAFFH8MAAIDAAQI+hnXJADjAAADAAQI+hnXJADjAAAAAA==.',['丶会']='丶会飞的鱼:BAAAKgAECgUIBQAAAA==.',['丹利']='丹利伊:BAAAKgADCgYIBwAAAA==.',['于啊']='于啊于童童:BAABKgAFFH8IAAINAAQIngkgGQCLAAANAAQIngkgGQCLAAAAAA==.',['云漓']='云漓:BAAAKgAECggIDQAAAA==.',['亦丶']='亦丶如歌:BAABKgAFFH8GAAIUAAIIUhwpDgC4AAAUAAIIUhwpDgC4AAAAAA==.',['亲灬']='亲灬爱灬的:BAAAKgAECgEIAQAAAA==.',['今宵']='今宵别梦寒:BAABKgAECn8iAAMVAAgIohvABwDmAQAVAAgIohvABwDmAQAWAAcIWRTKLQB8AQAAAA==.',['伊利']='伊利蛋炒饭:BAAAKgAECggIAwAAAA==.',['低矮']='低矮缺:BAAAKgADCgUIBQAAAA==.',['佛前']='佛前一朵青莲:BAAAKgAECgQIBgAAAA==.',['依赖']='依赖彼此丶:BAABKgAECn8YAAMRAAgIPiBzHgCfAgARAAgIPiBzHgCfAgAXAAEI0AGJYwAEAAAAAA==.',['八魁']='八魁:BAACKgAFFH8IAAIRAAMIzRXgUwDIAAARAAMIzRXgUwDIAAAqAAQKfygAAhEACAgTH8w3AEgCABEACAgTH8w3AEgCAAAA.',['兽战']='兽战天下:BAAAKgADCgMIAwAAAA==.',['冲天']='冲天大宝剑:BAAAKgAECggIDwAAAA==.冲天小剑剑:BAAAKgAECggIDgAAAA==.',['划伤']='划伤天空的泪:BAACKgAFFH8MAAIYAAMIkBwACADqAAAYAAMIkBwACADqAAAqAAQKfxkAAhgACAjzHy8IADkCABgACAjzHy8IADkCAAAA.',['刘能']='刘能与赵四:BAABKgAFFH8GAAIZAAYIShLDCAAYAQAZAAYIShLDCAAYAQAAAA==.',['别云']='别云涧:BAAAKgAECggICQAAAA==.',['加茂']='加茂宪纪:BAABKgAFFH8XAAMSAAQIqxIKOAC3AAASAAMI3w4KOAC3AAAaAAQIqxLkMACrAAAAAA==.',['千山']='千山鹿野:BAAAKgAFFAMIAwAAAA==.',['千珏']='千珏丶:BAABKgAECn8VAAMaAAgIFxJAKwCPAQAaAAgIDxJAKwCPAQASAAYIhg5DvQCpAAAAAA==.',['华韶']='华韶:BAAAKgAECgEIAQABKgAFFAQIBwAJALUXAA==.',['卑鄙']='卑鄙的北鼻:BAAAKgAECgUIBQAAAA==.',['南山']='南山的风:BAAAKgAECgcIBwAAAA==.',['博文']='博文丶风行者:BAABKgAFFH8IAAMSAAQIHA/yIgDLAAASAAQIHA/yIgDLAAAaAAEIPRL8JgBGAAAAAA==.',['卟罗']='卟罗卟珞:BAAAKgAECgQIBAAAAA==.',['卡西']='卡西莫哆:BAAAKgAFFAQIBAABKgAFFAgIDAAbAMkiAA==.',['叁叁']='叁叁贰壹零:BAAAKgADCggICAAAAA==.',['只吃']='只吃画的饼:BAABKgAFFH8GAAIFAAYIxBmHNgBBAAAFAAYIxBmHNgBBAAAAAA==.',['叮咣']='叮咣凿:BAABKgAECn8eAAIOAAgIFxINIQCCAQAOAAgIFxINIQCCAQAAAA==.',['呼啸']='呼啸的北风:BAAAKgAECgMIAwAAAA==.',['咕咕']='咕咕古古:BAAAKgADCgEIAQAAAA==.',['咸鱼']='咸鱼草莓:BAABKgAFFH8HAAMTAAYIvxhgEgCHAQATAAYIvxhgEgCHAQANAAEIAAAYKQAAAAAAAA==.',['喵哆']='喵哆哩:BAABKgAFFH8MAAIOAAYImg1wBAB1AQAOAAYImg1wBAB1AQAAAA==.',['图坦']='图坦咔门:BAABKgAFFH8GAAIcAAYISRmiBgB8AQAcAAYISRmiBgB8AQAAAA==.',['圆周']='圆周率:BAAAKgAECgMIBAABKgAECgMIBgAQAAAAAA==.',['圆脸']='圆脸的小西瓜:BAAAKgAECgcIDgAAAA==.',['坐观']='坐观惊涛骇浪:BAAAKgAFFAQIBAAAAA==.',['坚持']='坚持练满级:BAAAKgAECgEIAQAAAA==.',['坠茵']='坠茵落溷:BAACKgAFFH8gAAQdAAYIqiENBQDmAQAdAAYIqiENBQDmAQAMAAIIUwu/IACOAAAeAAMImASDCwBaAAAqAAQKfygABB0ACAiTG5IbANcBAB0ACAg2GpIbANcBAAwABAgVEKtuAKAAAB4AAwhBCsszAHkAAAAA.',['壕无']='壕无逼术:BAABKgAFFH8QAAQBAAMIehRIKQDJAAABAAMI6BNIKQDJAAAbAAEIyRHtIQBFAAACAAEIBg5LLwA8AAAAAA==.',['士大']='士大夫机械:BAABKgAECn8uAAMSAAgIXiCQGQBoAgASAAgIXiCQGQBoAgAaAAIIygaJiQA2AAAAAA==.',['夜泊']='夜泊秦淮:BAAAKgAECggICwAAAA==.',['大月']='大月几霸:BAAAKgAFFAQIBAAAAA==.',['大爷']='大爷来玩丫:BAAAKgAECgYICwAAAA==.',['天妒']='天妒嘤才:BAABKgAFFH8OAAIPAAgIwxd2BgBAAgAPAAgIwxd2BgBAAgAAAA==.',['夬丶']='夬丶蜀黍:BAAAKgAECgEIAQAAAA==.',['奈莫']='奈莫:BAAAKgAECggIEgAAAA==.',['季陌']='季陌花开:BAAAKgAECgQIBAAAAA==.',['守护']='守护爱我的人:BAAAKgAECgcIDwAAAA==.',['宝该']='宝该断奶了:BAAAKgAECgMIAwAAAA==.',['寒光']='寒光照孤影:BAAAKgAECgMIBgAAAA==.',['小分']='小分号:BAAAKgAECgMIAwAAAA==.',['小叹']='小叹号:BAAAKgAECgYIBgAAAA==.',['小夜']='小夜骑士:BAACKgAFFH8FAAMXAAMIRA0+HgCJAAAXAAMIRA0+HgCJAAAfAAEInRi0EwBJAAAqAAQKfx0AAh8ACAiAHNwKAD8CAB8ACAiAHNwKAD8CAAAA.',['小子']='小子看剑:BAACKgAFFH8NAAIaAAQI2wpFNAChAAAaAAQI2wpFNAChAAAqAAQKfysAAxoACAgJGvcrALUBABIACAiQF1o3AMgBABoACAjgGPcrALUBAAAA.',['小德']='小德玛利亚:BAAAKgAFFAIIAgAAAA==.',['小滴']='小滴精緻:BAAAKgAFFAQIBAAAAA==.',['小猫']='小猫软糖:BAAAKgAECgYIBgAAAA==.',['小逗']='小逗号:BAAAKgAECgMIAwAAAA==.',['小问']='小问号:BAAAKgAECgcICwAAAA==.',['小龙']='小龙人丶:BAAAKgAECgQIBgAAAA==.',['尘祈']='尘祈风:BAABKgAFFH8HAAINAAcITxfuAwDLAQANAAcITxfuAwDLAQAAAA==.',['尙丶']='尙丶小德:BAACKgAFFH8GAAISAAIIDQ8KPgBzAAASAAIIDQ8KPgBzAAAqAAQKfxwAAhIACAidEpFSALkBABIACAidEpFSALkBAAEqAAUUCAgMABoAXxUA.',['尛犄']='尛犄角:BAAAKgAFFAQIBAABKgAFFAgICAADALsbAA==.',['屠戮']='屠戮:BAABKgAECn8ZAAIMAAgI/xsnGABJAgAMAAgI/xsnGABJAgABKgAFFAgIBgAMABcZAA==.',['山德']='山德鲁阿兰蒂:BAAAKgAECgQIBgAAAA==.',['左端']='左端:BAAAKgAFFAEIAQAAAA==.',['巨鹰']='巨鹰丶高岭:BAAAKgADCgEIAQAAAA==.',['彐随']='彐随机生成:BAAAKgADCgMIAwAAAA==.',['忽闪']='忽闪忽现:BAABKgAECn8VAAIUAAgI8w4nPAB7AQAUAAgI8w4nPAB7AQAAAA==.',['我就']='我就是突突:BAAAKgADCggICAAAAA==.',['我是']='我是捌路军:BAAAKgADCggICAAAAA==.',['战火']='战火丶:BAAAKgADCggICAAAAA==.',['打针']='打针专业户:BAAAKgAFFAQIBAAAAA==.',['把饭']='把饭拼好给你:BAAAKgAECggICAAAAA==.',['挤挤']='挤挤总会有:BAAAKgAECggICAAAAA==.',['搜魂']='搜魂曲:BAABKgAECn8UAAIRAAYIOgyHywAIAQARAAYIOgyHywAIAQAAAA==.',['撒娇']='撒娇艳后:BAAAKgAECgIIAgAAAA==.',['新兰']='新兰:BAAAKgADCgQIBAAAAA==.',['新岛']='新岛真:BAAAKgAECgIIAgAAAA==.',['星杯']='星杯星梨奈:BAAAKgAECggICgAAAA==.',['春俪']='春俪:BAACKgAFFH8SAAMOAAgIthDzBQC7AQAOAAgIthDzBQC7AQAWAAEIsQUoHwA/AAAqAAQKfx0AAg4ACAg9FbgiAHYBAA4ACAg9FbgiAHYBAAAA.',['暮生']='暮生阿雷亚:BAAAKgAECggIDAAAAA==.',['暴走']='暴走灬祈祷:BAAAKgADCggICAAAAA==.',['月城']='月城丶博文:BAAAKgAECgIIAgAAAA==.',['有怪']='有怪老婆上:BAAAKgADCgYIBgAAAA==.',['有我']='有我一口吃的:BAABKgAFFH8JAAMaAAQI4B/pCwDtAAASAAQIgRrWFwDxAAAaAAMI5xnpCwDtAAAAAA==.',['有点']='有点逼术:BAAAKgAFFAgIBAAAAA==.',['杀部']='杀部落:BAAAKgAECgMIBgAAAA==.',['李富']='李富贵:BAAAKgAECgIIAgAAAA==.',['柒秦']='柒秦萌货:BAAAKgAFFAQIBAAAAA==.',['核弹']='核弹来喽:BAABKgAFFH8LAAIaAAMI4RrnJgDPAAAaAAMI4RrnJgDPAAAAAA==.',['格兰']='格兰菲迪:BAAAKgADCggICAAAAA==.',['桐人']='桐人:BAAAKgADCggIEAAAAA==.',['梅路']='梅路艾姆:BAABKgAFFH8FAAIGAAUIMBRTFgAXAQAGAAUIMBRTFgAXAQAAAA==.',['梦韶']='梦韶:BAAAKgAECgcICwABKgAFFAQIBwAJALUXAA==.',['椰子']='椰子泡丶:BAAAKgADCgUIBQAAAA==.',['歆竹']='歆竹无忧:BAAAKgAECggICAAAAA==.',['死亡']='死亡低吟者:BAAAKgAECgEIAQAAAA==.',['死在']='死在冲锋上:BAAAKgAECgUIBgAAAA==.',['残风']='残风弦月:BAABKgAECn8WAAIDAAgIPRJFTABJAQADAAgIPRJFTABJAQAAAA==.',['水無']='水無月白:BAABKgAECn8WAAIWAAgI0BsOGAAfAgAWAAgI0BsOGAAfAgAAAA==.',['沐清']='沐清歌:BAAAKgADCgcIBwAAAA==.',['沙弓']='沙弓哒啰:BAAAKgAFFAIIAgAAAA==.',['没事']='没事儿荡漾:BAAAKgADCggICAAAAA==.',['洛花']='洛花听雨:BAABKgAECn8WAAIOAAgIZCPmBwCzAgAOAAgIZCPmBwCzAgAAAA==.',['海东']='海东来:BAAAKgADCggICAAAAA==.',['淋漓']='淋漓尽致丶:BAACKgAFFH8PAAMKAAQImB/LBwD5AAAKAAMImB/LBwD5AAAJAAEIAADvNwAAAAAqAAQKfxUABAoACAiQGnkdAO4BAAoABwi3HHkdAO4BAAkAAwioFDlrAIMAAAsAAwg0CeVjAGUAAAAA.',['渣叔']='渣叔丶:BAAAKgAECggIDQAAAA==.',['满意']='满意大将军:BAAAKgAECgYIBgAAAA==.',['潇洒']='潇洒的一姐:BAABKgAFFH8QAAIRAAgIyQ+SDgDvAQARAAgIyQ+SDgDvAQAAAA==.',['濒死']='濒死的鲤鱼王:BAAAKgAECgEIAQAAAA==.',['灌注']='灌注来喽:BAABKgAFFH8TAAIKAAQImyEhFgAEAQAKAAQImyEhFgAEAQAAAA==.',['火柴']='火柴人:BAAAKgADCgEIAQAAAA==.',['火锅']='火锅仙人:BAABKgAFFH8OAAIOAAYI2hX8AQDBAQAOAAYI2hX8AQDBAQAAAA==.',['灬幼']='灬幼熙灬:BAAAKgAECggICAAAAA==.',['灬流']='灬流灬年灬:BAAAKgADCgEIAQAAAA==.',['炸糕']='炸糕儿:BAABKgAFFH8IAAMgAAgIKhMMAQAXAgAgAAcISxYMAQAXAgAFAAEIRAArPAAiAAAAAA==.',['煤山']='煤山小钻风:BAAAKgADCggICgAAAA==.',['父母']='父母:BAAAKgADCggICAAAAA==.',['牛哇']='牛哇:BAABKgAFFH8LAAMFAAYIRRlJCQByAQAFAAYIRRlJCQByAQAEAAQIABG3GQDYAAABKgAFFAgIKgASACMgAA==.',['狐谷']='狐谷川天熏:BAAAKgAFFAYIAgAAAA==.',['猪猪']='猪猪侠:BAAAKgADCggICAAAAA==.',['王大']='王大锤:BAAAKgAECgUIBQAAAA==.',['玛格']='玛格汉纯爷们:BAAAKgAECggIDgAAAA==.',['琪马']='琪马:BAAAKgAECgUIBQAAAA==.',['生气']='生气的李小胖:BAAAKgAECgYIBgAAAA==.',['疯狂']='疯狂的蛋挞:BAAAKgADCgUIBQAAAA==.',['白流']='白流苏:BAAAKgAECgIIAgAAAA==.',['白铁']='白铁氏族天使:BAAAKgAECgcIDQAAAA==.白铁氏族法爷:BAACKgAFFH8eAAIcAAYIYBpQBgCFAQAcAAYIYBpQBgCFAQAqAAQKfykAAhwACAgeJcMEANwCABwACAgeJcMEANwCAAAA.',['皇图']='皇图:BAAAKgAFFAMIAwAAAA==.',['瞬间']='瞬间振动:BAAAKgAECgIIAgAAAA==.',['硬核']='硬核六十级:BAAAKgAECgYIDQAAAA==.',['神乐']='神乐千鹤丶:BAAAKgADCggICAAAAA==.',['秋辉']='秋辉映梦:BAAAKgAECgYICAAAAA==.',['笑笑']='笑笑小奶狸:BAACKgAFFH8GAAMcAAQInB9LCADsAAAcAAQInB9LCADsAAADAAIIqAhuKgB2AAAqAAQKfxgAAxwACAjlHkQnALwBABwACAjlHkQnALwBAAMABgiWGUheACQBAAAA.',['第九']='第九艺术:BAAAKgAFFAIIBAAAAA==.',['紫羽']='紫羽精灵:BAACKgAFFH8PAAIJAAMIahlBGADQAAAJAAMIahlBGADQAAAqAAQKf1AAAwkACAiuH4cKAGgCAAkACAiuH4cKAGgCAAoACAhmD/84AFkBAAAA.',['美丽']='美丽的麻花辫:BAAAKgADCgUIBQAAAA==.',['肆意']='肆意妄为:BAAAKgAFFAQIBAAAAA==.',['自然']='自然之舞:BAACKgAFFH8QAAMhAAMI0RCwBwCTAAAhAAMI0RCwBwCTAAAFAAEI/AEPKAApAAAqAAQKfx4AAgUACAjHECI0AB4BAAUACAjHECI0AB4BAAAA.',['船长']='船长:BAAAKgADCgEIAQAAAA==.',['花小']='花小惩:BAAAKgAFFAEIAQAAAA==.',['花开']='花开雨无声:BAAAKgAECgQIBAAAAA==.',['茉茉']='茉茉:BAAAKgAECgQIBAAAAA==.',['茸茸']='茸茸:BAAAKgAECgMIAwAAAA==.',['草丛']='草丛一只胖:BAACKgAFFH8cAAQUAAYItxXlCwAMAQAUAAMInB7lCwAMAQAHAAQIOh2rHgDxAAAIAAMIkAbuIADTAAAqAAQKfx0ABBQACAh4IQgZADkCABQACAh4IQgZADkCAAcABAiLGXFJABkBAAgAAQicDfGaADkAAAAA.',['萌萌']='萌萌德:BAAAKgAECgcIBwAAAA==.',['萌面']='萌面凹凸曼:BAACKgAFFH8LAAIIAAMIuiCzFQAIAQAIAAMIuiCzFQAIAQAqAAQKf0MAAggACAiTJYoBAPkCAAgACAiTJYoBAPkCAAAA.',['蓝小']='蓝小妮:BAAAKgAECgMIAwAAAA==.',['蔡需']='蔡需坤:BAAAKgAECggICwAAAA==.',['薇雨']='薇雨晴殇:BAABKgAFFH8MAAMBAAgIcxguCAAMAgABAAgIcxguCAAMAgACAAEIAADONQAAAAAAAA==.',['藤古']='藤古之剑:BAAAKgAECgQIBAAAAA==.',['虚空']='虚空丶彼岸花:BAAAKgAECggICAAAAA==.虚空丶残星泪:BAAAKgAECggICgAAAA==.虚空丶藏功名:BAABKgAFFH8IAAIdAAYInBT+CwBOAQAdAAYInBT+CwBOAQAAAA==.',['虾馒']='虾馒很好吃:BAAAKgAECggIEwAAAA==.',['蛋炒']='蛋炒饭炒蛋:BAAAKgAFFAEIAQAAAA==.',['蜻蜓']='蜻蜓丶水:BAAAKgADCgcIBwAAAA==.',['血月']='血月星河:BAAAKgAFFAgIAQAAAA==.',['行者']='行者丶风:BAAAKgAECgEIAQAAAA==.',['被曝']='被曝光波波:BAAAKgAECgcIDQAAAA==.',['诗情']='诗情画意得雪:BAAAKgAECggICAABKgAFFAgICAABAPUYAA==.',['诗灬']='诗灬歌:BAABKgAFFH8GAAIJAAIIcQ5ZHACLAAAJAAIIcQ5ZHACLAAAAAA==.',['诗风']='诗风:BAAAKgADCgEIAQAAAA==.',['说走']='说走就走:BAAAKgAECgMIAwAAAA==.',['诸葛']='诸葛高兴:BAAAKgAECgQIBwAAAA==.',['诸趣']='诸趣:BAAAKgAFFAcIBAAAAA==.',['谁的']='谁的神话:BAAAKgADCgYIBgAAAA==.',['贰犇']='贰犇犇:BAAAKgADCggICAAAAA==.',['贱意']='贱意永为:BAAAKgADCggIEAAAAA==.',['费伍']='费伍德落叶:BAAAKgADCgQIBAAAAA==.',['贺豪']='贺豪豪:BAAAKgAECggICAAAAA==.',['起始']='起始亦是终:BAABKgAFFH8aAAMSAAgImyEGBAB3AgASAAgIbiAGBAB3AgAaAAQIph2GEQDRAAAAAA==.',['路上']='路上不可能死:BAAAKgAECgYIEgAAAA==.',['踏风']='踏风咆哮:BAAAKgAECgUICgAAAA==.',['轻雨']='轻雨涟漪:BAAAKgAFFAYIBAAAAA==.',['醉梦']='醉梦韶华:BAACKgAFFH8NAAMOAAcIQBGlCQCRAQAOAAYIxA2lCQCRAQAWAAEI8ABkKQAgAAAqAAQKfyAAAw4ACAjyHM4MAEMCAA4ACAjyHM4MAEMCABYABgjQBNtNAIsAAAEqAAUUCAgFABsAjx0A.',['醉迷']='醉迷人最危险:BAAAKgADCgEIAQAAAA==.',['醉韶']='醉韶:BAAAKgAECgIIAgABKgAFFAQIBwAJALUXAA==.',['野生']='野生动物:BAAAKgAECgUIBQAAAA==.',['铁憨']='铁憨憨:BAAAKgAECgIIAgAAAA==.',['铁血']='铁血狂小撸:BAAAKgAECgEIAQAAAA==.',['银月']='银月坠星:BAAAKgADCgcIBwAAAA==.',['银萨']='银萨:BAAAKgAECgYICwABKgAFFAQIBwAJALUXAA==.',['闪耀']='闪耀丹宝:BAAAKgAECgMIAwAAAA==.',['阿尔']='阿尔托莉娅丿:BAAAKgADCggIEAAAAA==.',['阿昆']='阿昆达来了:BAAAKgAECgIIAgAAAA==.',['阿珞']='阿珞冇酒池:BAAAKgAFFAYIBAAAAA==.',['雨宫']='雨宫莲:BAAAKgAECgYIBgAAAA==.',['雾非']='雾非雾花非花:BAAAKgAFFAYIAgAAAA==.',['震骨']='震骨剑:BAABKgAFFH8QAAIPAAgI9AyxCQDgAQAPAAgI9AyxCQDgAQAAAA==.',['飞娥']='飞娥子:BAAAKgAFFAQIAgAAAA==.',['鲨骑']='鲨骑马:BAAAKgAECgUIBQAAAA==.',['黑猩']='黑猩猩队长:BAABKgAECn8aAAQEAAgIgxu9MgDwAQAEAAgIgxu9MgDwAQAFAAcIygnMPwARAQAhAAEIwgc1OQAVAAAAAA==.',['黑糖']='黑糖啵啵:BAAAKgADCgIIAgAAAA==.',['龍尛']='龍尛嗨:BAABKgAECn8iAAMRAAgIYxoDTwAFAgARAAYIDx4DTwAFAgAXAAcIngT8PgCSAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end