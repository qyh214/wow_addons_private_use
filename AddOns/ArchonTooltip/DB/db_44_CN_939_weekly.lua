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
 local lookup = {'DemonHunter-Vengeance','Hunter-BeastMastery','DeathKnight-Frost','Mage-Arcane','Paladin-Retribution','Druid-Guardian','Druid-Restoration','Druid-Balance','Shaman-Elemental','Warrior-Fury','DemonHunter-Havoc','Warlock-Destruction','Mage-Frost','Evoker-Preservation','Evoker-Devastation','Monk-Mistweaver','Warrior-Protection','Hunter-Marksmanship','Druid-Feral','Priest-Holy','Priest-Shadow','DeathKnight-Blood','Rogue-Assassination','Hunter-Survival','Paladin-Holy','Evoker-Augmentation','Monk-Brewmaster','Warlock-Demonology','Shaman-Restoration','Paladin-Protection','DeathKnight-Unholy','Unknown-Unknown','Rogue-Subtlety','Monk-Windwalker','Priest-Discipline','Warrior-Arms',}; local provider = {region='CN',realm='苏拉玛',name='CN',type='weekly',zone=44,date='2025-12-07',data={An='Angelone:BAABLAAFFH8RAAIBAAYInQvCBwD0AAABAAYInQvCBwD0AAAAAA==.',Bl='Blackrocks:BAAALAAFFAIIAgAAAA==.',Bu='Butterfly:BAAALAAECgYICwAAAA==.',Ch='Cherish:BAAALAAECggICAAAAA==.',Da='Darkcalee:BAABLAAFFH8JAAICAAUI5RJjUwAFAQACAAUI5RJjUwAFAQAAAA==.',De='Devilskiss:BAAALAAECgUICAAAAA==.',Di='Diu:BAACLAAFFH8GAAIDAAYIWgXqUQDVAAADAAYIWgXqUQDVAAAsAAQKfx0AAgMACAhYGOU3AJwBAAMACAhYGOU3AJwBAAAA.',Fl='Fluorite:BAABLAAFFH8GAAIDAAIIBQ/0agCTAAADAAIIBQ/0agCTAAAAAA==.',Ga='Gainlhdema:BAAALAAECgYIDAAAAA==.',Go='Goxd:BAAALAAFFAIIAgAAAA==.',Gr='Gracehh:BAAALAAECgYIDQAAAA==.',Ha='Hades:BAAALAAECggIEAABLAAFFAYIBgAEACcFAA==.',Hi='Hierophant:BAAALAADCgEIAQAAAA==.Higher:BAACLAAFFH8KAAIFAAIIzBr7UABWAAAFAAIIzBr7UABWAAAsAAQKfysAAgUACAiZGNI7AKoBAAUACAiZGNI7AKoBAAAA.',Ib='Iblis:BAAALAAECgIIAgAAAA==.',Kd='Kdj:BAAALAADCgQIBAAAAA==.',Kl='Klolinde:BAABLAAFFH8YAAIFAAYIAySaBwARAgAFAAYIAySaBwARAgAAAA==.',Li='Lifeweaver:BAACLAAFFH8eAAMGAAYIPheHAAD9AQAGAAYIPheHAAD9AQAHAAYIdgrvCACDAQAsAAQKfyEABAYACAjGHsIGAJkCAAYACAifHsIGAJkCAAgACAhfEV5JAI8BAAcAAQgRFGDjADgAAAAA.',Lx='Lxhzyc:BAAALAAFFAYIAgAAAA==.Lxhzyz:BAABLAAFFH8GAAIJAAYIuxM3GgBwAQAJAAYIuxM3GgBwAQAAAA==.',Ma='Maltesers:BAABLAAFFH8HAAICAAMIrhLgcACCAAACAAMIrhLgcACCAAAAAA==.',Mi='Ming:BAAALAAECgYIBgAAAA==.',Mo='Monochrome:BAACLAAFFH8fAAIKAAYIYSCGDgDlAQAKAAYIYSCGDgDlAQAsAAQKfykAAgoACAhaJC4FAOgCAAoACAhaJC4FAOgCAAAA.',My='Mypreclous:BAAALAAFFAMIAwAAAA==.',Oa='Oak:BAAALAAECgcIAQAAAA==.',Pi='Pilipala:BAAALAADCgEIAQAAAA==.',Pl='Playerbcfkun:BAAALAAECgQIBAAAAA==.Playernegrkw:BAAALAAECgUICQAAAA==.',Sg='Sg:BAABLAAFFH8pAAILAAcISyDmCAA7AgALAAcISyDmCAA7AgAAAA==.',Sw='Swindy:BAABLAAFFH8GAAIMAAII5wP1cAAsAAAMAAII5wP1cAAsAAAAAA==.',Wa='Waoo:BAAALAAFFAIIAgAAAA==.',Wn='Wnbdk:BAAALAAFFAIIAgAAAA==.',Wr='Wrath:BAAALAAECgUIBQAAAA==.',['一发']='一发两发三发:BAABLAAFFH8GAAICAAYIbw9SPwBLAQACAAYIbw9SPwBLAQAAAA==.',['一样']='一样的烂摊子:BAACLAAFFH8JAAINAAMIFBSqDQCBAAANAAMIFBSqDQCBAAAsAAQKfx4AAg0ABwh6HuYVAGwCAA0ABwh6HuYVAGwCAAAA.',['一碰']='一碰就碎丸:BAAALAAECgYIBgAAAA==.',['一袭']='一袭素裙:BAAALAAECggICAAAAA==.一袭青衫:BAAALAAECgIIAgAAAA==.',['一顾']='一顾一酷:BAAALAAECgYIEAAAAA==.一顾宸与瑭:BAAALAAECgYIDAAAAA==.一顾朝与暮:BAAALAAECgYIDAAAAA==.',['丈育']='丈育:BAAALAAECgUIBQAAAA==.',['三色']='三色果盘:BAAALAAECgIIAwAAAA==.',['上山']='上山猎:BAAALAAECgcIDQAAAA==.',['不来']='不来恩白须:BAAALAAECgYIBgAAAA==.',['不需']='不需要:BAAALAADCggICAAAAA==.',['丑兮']='丑兮兮:BAABLAAFFH8HAAMOAAYIahWgBADLAQAOAAYIahWgBADLAQAPAAEITgMsJQA6AAAAAA==.',['专业']='专业:BAABLAAFFH8KAAIDAAYIGBeqCQATAgADAAYIGBeqCQATAgAAAA==.',['两个']='两个馒头:BAABLAAECn82AAIQAAgI/iYvAACPAwAQAAgI/iYvAACPAwAAAA==.',['丨坏']='丨坏坏丨:BAAALAADCgIIAgAAAA==.',['丨灬']='丨灬森森灬丨:BAAALAAECgUIBQAAAA==.',['丶吉']='丶吉高宁宁:BAAALAAFFAEIAQAAAA==.',['丶小']='丶小憨憨:BAAALAADCgIIAgAAAA==.',['乄夵']='乄夵:BAAALAAECgIIAgAAAA==.',['乄鲨']='乄鲨鱼辣椒乄:BAABLAAFFH8IAAIEAAYIBREMMwC9AAAEAAYIBREMMwC9AAAAAA==.',['乐滋']='乐滋:BAAALAAFFAIIAgAAAA==.',['二丢']='二丢:BAABLAAFFH8VAAIDAAUIihd4PgBEAQADAAUIihd4PgBEAQAAAA==.',['云梦']='云梦使者:BAABLAAFFH8UAAIRAAUIvA3qGADfAAARAAUIvA3qGADfAAAAAA==.',['五叶']='五叶:BAABLAAFFH8WAAMCAAUIsBsjQABJAQACAAUIsBsjQABJAQASAAIIFBWGIgCDAAABLAAFFAgIHAAIAOIkAA==.',['五道']='五道杠丶血吼:BAAALAAECggICAAAAA==.',['亚妮']='亚妮拉丝:BAAALAAECgEIAQAAAA==.',['什么']='什么要什么来:BAAALAAFFAMIBAAAAA==.',['仇冯']='仇冯君:BAAALAAECgYIDwAAAA==.',['伤心']='伤心离别:BAACLAAFFH8ZAAITAAMIzhmCBgD0AAATAAMIzhmCBgD0AAAsAAQKfyYAAxMACAhAHIgEAEUCABMACAhAHIgEAEUCAAgABQg/E7tnACIBAAAA.',['你不']='你不要过来:BAACLAAFFH8GAAICAAYIzgO+YADBAAACAAYIzgO+YADBAAAsAAQKfx4AAgIABwglFt5rAGwBAAIABwglFt5rAGwBAAAA.',['佰八']='佰八萬花開:BAABLAAECn8pAAMUAAgIMx3vEABPAgAUAAgIMx3vEABPAgAVAAYIfhayHwBKAQAAAA==.',['俺是']='俺是小疯子:BAAALAAECgYICgAAAA==.',['倾听']='倾听风的思念:BAAALAADCgMIAwAAAA==.',['假面']='假面骑士:BAABLAAFFH8JAAIWAAYIoA3CDQAuAQAWAAYIoA3CDQAuAQAAAA==.',['偷心']='偷心:BAAALAADCgIIAgAAAA==.',['傻傻']='傻傻土萨:BAAALAAFFAIIBAAAAA==.傻傻血战:BAAALAAFFAEIAQAAAA==.傻傻血法:BAAALAAFFAIIAgAAAA==.傻傻踏风:BAAALAAECgYIEAAAAA==.',['像小']='像小鹿一样:BAABLAAFFH8YAAICAAYIehZ1LACGAQACAAYIehZ1LACGAQABLAAFFAcIIgAKAMUlAA==.',['兦丨']='兦丨尢:BAAALAAECgYIBgAAAA==.',['六两']='六两银元:BAACLAAFFH8jAAILAAcI0AwxEwBlAQALAAcI0AwxEwBlAQAsAAQKfy8AAgsACAi5GBBHAEwCAAsACAi5GBBHAEwCAAAA.',['关羽']='关羽灬:BAAALAAECgYIBgAAAA==.',['其实']='其实光不行:BAAALAAECggIAgAAAA==.',['冥海']='冥海醉红莲:BAACLAAFFH8IAAIXAAIIeBKFHQB+AAAXAAIIeBKFHQB+AAAsAAQKfxsAAhcABwgUHAoIAPMBABcABwgUHAoIAPMBAAAA.',['冰乄']='冰乄残月:BAAALAAECgYIDgAAAA==.',['冷玉']='冷玉轩:BAAALAAECgYIBgAAAA==.',['冷轩']='冷轩轩:BAAALAAECgYIDwAAAA==.',['冻蛮']='冻蛮糕兽:BAABLAAFFH8FAAMYAAIIywVgBgCFAAAYAAIIywVgBgCFAAACAAEIuwEEjwAnAAAAAA==.',['净世']='净世傲白莲:BAAALAAFFAIIBAAAAA==.',['凤九']='凤九:BAAALAAECgEIAQAAAA==.',['初生']='初生东曦:BAAALAAFFAEIAQAAAA==.',['别喊']='别喊我:BAAALAAFFAIIAgAAAA==.',['别肘']='别肘:BAACLAAFFH8TAAMCAAUIsR5ePABVAQACAAUIsR5ePABVAQASAAIIRBOWIwCBAAAsAAQKfx0AAwIABwjgIFZAAGYCAAIABwjgIFZAAGYCABIABgjUHiE5ANUBAAAA.',['劣劣']='劣劣人丶:BAAALAAECgYIBgAAAA==.',['匆匆']='匆匆而来:BAAALAAECggICAABLAAFFAgICgAMACgMAA==.',['北辰']='北辰芽衣:BAABLAAFFH8KAAIZAAIIURdbGQCZAAAZAAIIURdbGQCZAAAAAA==.',['十点']='十点二很强:BAABLAAFFH8IAAIDAAYIbhBwNQBpAQADAAYIbhBwNQBpAQAAAA==.',['华佗']='华佗:BAAALAAECgYICQAAAA==.',['南笙']='南笙丶北竹:BAABLAAFFH8JAAMYAAIIaByNBACcAAAYAAIIoxSNBACcAAACAAII2RP2YwCJAAAAAA==.',['卡西']='卡西:BAAALAAFFAIIBAAAAA==.卡西奥佩娅:BAACLAAFFH8+AAMPAAcIpxwKBgDYAQAaAAcIkRlfAwDmAQAPAAYI7xkKBgDYAQAsAAQKfy4AAw8ACAgLJBoGAC0DAA8ACAgLJBoGAC0DABoABQjNH4IKAMcBAAAA.',['古丶']='古丶尔丹:BAABLAAFFH8JAAIMAAIIYAuPRQCRAAAMAAIIYAuPRQCRAAAAAA==.',['可乐']='可乐游泳:BAABLAAFFH8FAAIDAAIIiASpjgB5AAADAAIIiASpjgB5AAABLAAFFAgIDwADADsAAA==.',['可爱']='可爱之疾偶像:BAAALAADCgQIBAAAAA==.',['可达']='可达鸭:BAABLAAFFH8FAAIbAAII6hNUFgB1AAAbAAII6hNUFgB1AAAAAA==.',['吃我']='吃我一发炎爆:BAABLAAFFH8JAAMcAAUIbiEbDABfAAAMAAUIFBk7PgAJAQAcAAIIOyQbDABfAAAAAA==.吃我一枪:BAAALAADCggICAAAAA==.',['吉季']='吉季洋痒德:BAAALAADCgcIBwAAAA==.',['君哥']='君哥:BAABLAAFFH8GAAIDAAIIAxfpWACcAAADAAIIAxfpWACcAAAAAA==.',['吟一']='吟一曲暗林风:BAAALAAECgYIBgAAAA==.',['含笑']='含笑看吴钩:BAAALAAECgEIAQAAAA==.',['启小']='启小德:BAAALAAECgIIAgAAAA==.',['呆呆']='呆呆小萨满:BAAALAAECgYICAAAAA==.',['周塘']='周塘湾一坝:BAAALAAECgQIBQAAAA==.',['周申']='周申恒:BAABLAAFFH8HAAICAAYIZQbLVgD2AAACAAYIZQbLVgD2AAAAAA==.',['呼噜']='呼噜发:BAAALAAECgYIBgAAAA==.',['咖尔']='咖尔鲁什:BAABLAAFFH8HAAIKAAMI2A7cOACRAAAKAAMI2A7cOACRAAAAAA==.',['啊呜']='啊呜喵丶:BAABLAAECn8UAAIFAAgICyCNHQD8AgAFAAgICyCNHQD8AgAAAA==.',['喂你']='喂你喝八珍汤:BAABLAAFFH8IAAIdAAIISwnWagBRAAAdAAIISwnWagBRAAAAAA==.',['喜大']='喜大普奔:BAABLAAFFH8IAAIHAAYI1Rc3EgCvAQAHAAYI1Rc3EgCvAQAAAA==.',['嘉兴']='嘉兴土灵战:BAABLAAFFH8KAAIRAAQIGRk3GQDaAAARAAQIGRk3GQDaAAABLAAFFAYICgAcALMRAA==.嘉兴张德:BAABLAAFFH8UAAUTAAUIUhTSBwDwAAATAAQI8hLSBwDwAAAIAAMIaBBcHwDKAAAHAAMIcxOhLwCtAAAGAAMI6ASECgBKAAAAAA==.',['嘛那']='嘛那嘛咪哄:BAACLAAFFH8IAAMEAAII+Bv8PACjAAAEAAII7xf8PACjAAANAAEIBxmbHgBIAAAsAAQKfxYAAwQABwipIclHADACAAQABwiNIMlHADACAA0AAghyIuouAL8AAAAA.',['嘣喳']='嘣喳喳丶:BAACLAAFFH8KAAIKAAII3BajMgCcAAAKAAII3BajMgCcAAAsAAQKfzUAAgoACAhRJCgKAEkDAAoACAhRJCgKAEkDAAAA.',['圆墩']='圆墩的甲辰未:BAAALAAFFAIIAgAAAA==.',['圣光']='圣光照耀我心:BAAALAADCgEIAQAAAA==.',['圣斗']='圣斗士牛矢:BAAALAAFFAEIAQAAAA==.',['圣灬']='圣灬老卡:BAAALAAECggICgAAAA==.',['圣骑']='圣骑帅不:BAAALAADCggICgAAAA==.',['塞勒']='塞勒斯汀:BAAALAAECgIIBAAAAA==.',['塞来']='塞来昔布:BAAALAAECgYIEgAAAA==.',['夜影']='夜影骑士:BAAALAAFFAIIAgAAAA==.',['夜愿']='夜愿灬老卡:BAAALAAECggICAAAAA==.',['夜无']='夜无忧:BAAALAAFFAIIBAAAAA==.',['夜雨']='夜雨声烦:BAABLAAFFH8JAAIeAAMI4w+oEQBoAAAeAAMI4w+oEQBoAAAAAA==.',['大头']='大头比卡丘:BAAALAAECgYIBgAAAA==.',['大支']='大支也:BAAALAAECgYIDwAAAA==.',['大猪']='大猪二十一:BAABLAAFFH8RAAISAAYIzxWoBQB7AQASAAYIzxWoBQB7AQAAAA==.',['大锤']='大锤接小锤:BAAALAAFFAMIBAAAAA==.',['天堂']='天堂制造:BAAALAAFFAIIAgAAAA==.',['天幕']='天幕红尘:BAAALAAECgIIAgAAAA==.',['天洛']='天洛祆:BAACLAAFFH8OAAICAAMIiBSBPACrAAACAAMIiBSBPACrAAAsAAQKfy4AAwIACAizI/kYAPkCAAIACAizI/kYAPkCABIAAQh1F2W3AEAAAAAA.',['天涯']='天涯明月剑:BAAALAAFFAIIBAABLAAFFAMIBwAMAA8KAA==.',['天狐']='天狐大人:BAAALAAECgYIBgAAAA==.天狐沃克:BAACLAAFFH8SAAICAAUIhhrnRAA5AQACAAUIhhrnRAA5AQAsAAQKfx8AAgIABwjSIC4rAA0CAAIABwjSIC4rAA0CAAAA.天狐玉初:BAACLAAFFH8JAAMKAAMICg1EOwCHAAAKAAMICg1EOwCHAAARAAEI7AIMNAAtAAAsAAQKfzYAAxEABwhbHQUOAPEBABEABwhbHQUOAPEBAAoABwhcBXG8AAQBAAAA.天狐蒂亚:BAACLAAFFH8PAAMUAAUIKQ6EIgAxAQAUAAUIKQ6EIgAxAQAVAAII/AzmLwA1AAAsAAQKfygAAxQABwizHU4TADcCABQABgiOIU4TADcCABUABwjTHCoPAPMBAAAA.天狐露娜:BAABLAAECn8XAAMJAAgI3hWuIwCaAQAJAAcIXBiuIwCaAQAdAAcIwRfMMwCRAQAAAA==.',['天空']='天空中的飞鸟:BAABLAAFFH8TAAIUAAUILRYzHQBmAQAUAAUILRYzHQBmAQAAAA==.',['失眠']='失眠叔叔:BAAALAAFFAIIBAAAAA==.',['夺命']='夺命十三枪:BAABLAAFFH8MAAIRAAYIJBrdEABGAQARAAYIJBrdEABGAQAAAA==.',['奥利']='奥利维拉:BAAALAAFFAIIBAAAAA==.',['她永']='她永远是第一:BAABLAAFFH8GAAIDAAII6B3+TACjAAADAAII6B3+TACjAAAAAA==.',['好运']='好运自然来:BAAALAAECgMIAwAAAA==.',['妖火']='妖火红狐:BAACLAAFFH8wAAMbAAYIbSCNBwDZAQAbAAYIbSCNBwDZAQAQAAQI9AUUEAC9AAAsAAQKfxcAAhsACAiWIYUGAAUDABsACAiWIYUGAAUDAAAA.',['姐夫']='姐夫:BAABLAAECn8cAAMNAAYI0Qn6WAASAQANAAYIjAj6WAASAQAEAAYI4ginSADmAAAAAA==.',['安娜']='安娜喵丶:BAACLAAFFH8GAAIDAAIIHBkqTwCiAAADAAIIHBkqTwCiAAAsAAQKfyoAAgMACAi8I9ERACoDAAMACAi8I9ERACoDAAAA.',['寂寞']='寂寞的冰员外:BAAALAAFFAIIAgAAAA==.寂寞的尼克:BAAALAAFFAIIAgAAAA==.寂寞的竹员外:BAAALAAECggIDgAAAA==.',['富贵']='富贵惩:BAAALAAFFAIIBAAAAA==.',['小倭']='小倭瓜:BAAALAAECgMIAwAAAA==.',['小友']='小友请留步:BAAALAAECgUICAAAAA==.',['小吼']='小吼酋长:BAAALAADCgMIAwAAAA==.',['小奶']='小奶狗不奶人:BAAALAAECgIIAgAAAA==.',['小狗']='小狗:BAAALAAFFAIIAwAAAA==.',['小猫']='小猫咪大冤种:BAACLAAFFH8gAAIDAAUIKyQkKACYAQADAAUIKyQkKACYAQAsAAQKfyMAAgMACAhJIz8NAIgCAAMACAhJIz8NAIgCAAAA.小猫咪大笨蛋:BAAALAAECgYICQAAAA==.',['小米']='小米粥:BAABLAAFFH8HAAICAAMICw/GdwBxAAACAAMICw/GdwBxAAAAAA==.',['小轩']='小轩轩:BAAALAAECgYICAAAAA==.',['尐样']='尐样丶傲雪:BAABLAAECn8aAAICAAgIYBnoTwA/AgACAAgIYBnoTwA/AgAAAA==.尐样丶傻馒:BAABLAAFFH8VAAMdAAUICxc8LQACAQAdAAQIbhQ8LQACAQAJAAMIaRSrMwCSAAAAAA==.尐样丶凝眸:BAACLAAFFH8IAAIdAAII9BGRWQBpAAAdAAII9BGRWQBpAAAsAAQKfxQAAwkACAhrGTtVALgBAAkABgiuFztVALgBAB0ACAi+D0+CAHsBAAAA.尐样丶墨雨:BAAALAAECgIIAgAAAA==.尐样丶常羲:BAABLAAECn8XAAIXAAYIBhStEQBNAQAXAAYIBhStEQBNAQAAAA==.尐样丶术虱:BAABLAAFFH8GAAIMAAIIyBDsWQBGAAAMAAIIyBDsWQBGAAAAAA==.尐样丶玄女:BAAALAAECgYIEgAAAA==.尐样丶玄狐:BAABLAAFFH8FAAIHAAIIQxfxNwCMAAAHAAIIQxfxNwCMAAAAAA==.尐样丶迪奥斯:BAACLAAFFH8HAAIZAAMInRFrHQC8AAAZAAMInRFrHQC8AAAsAAQKfxQAAgUACAhqDvm4AJIBAAUACAhqDvm4AJIBAAAA.',['就是']='就是个骑士:BAAALAAECgYIDAAAAA==.',['崔巉']='崔巉:BAAALAAFFAIIAgAAAA==.',['布偶']='布偶比猪还蠢:BAAALAAFFAIIAgAAAA==.',['帅德']='帅德伊比:BAAALAADCgYIDAAAAA==.',['希丶']='希丶瓦丶:BAAALAAECggICAAAAA==.',['希格']='希格斯术神:BAAALAAECgEIAQAAAA==.',['带着']='带着四只猪:BAAALAAECgIIAgAAAA==.',['幻失']='幻失幻徳:BAAALAAECgYIBgAAAA==.',['幻歌']='幻歌:BAACLAAFFH8JAAIDAAIIZyArPQC3AAADAAIIZyArPQC3AAAsAAQKfxUAAwMACAgTHlIyAKsCAAMACAgTHlIyAKsCAB8AAQhfFzNXAEwAAAEsAAUUAwgFABkA9QsA.',['幽灵']='幽灵射击:BAAALAADCgYIBgAAAA==.幽灵神魔:BAAALAADCggICAAAAA==.',['张飛']='张飛:BAAALAAECggICAAAAA==.',['心中']='心中有术:BAAALAAECgYIDAAAAA==.',['心游']='心游堂大佬:BAAALAAFFAIIBAAAAA==.',['恋人']='恋人射死之日:BAAALAADCggICAABLAAFFAIIAgAgAAAAAA==.',['恰米']='恰米:BAABLAAFFH8HAAMNAAII2xdeEgCJAAAEAAIIOxPeSwCUAAANAAIIbxReEgCJAAAAAA==.',['恶贯']='恶贯满盈:BAAALAAECgcIBwAAAA==.',['悟空']='悟空丶祭司:BAAALAAECggICAAAAA==.',['愚者']='愚者的片尾:BAABLAAFFH8MAAMDAAYIAyHzEwDzAQADAAYIAyHzEwDzAQAWAAYIwBNqCwBaAQAAAA==.',['愛瞌']='愛瞌睡的黑貓:BAAALAAFFAIIAgAAAA==.',['我侄']='我侄女黄依昕:BAABLAAFFH8GAAICAAII7ASstQA0AAACAAII7ASstQA0AAAAAA==.',['我的']='我的小越越:BAAALAAECgYIBgAAAA==.',['战之']='战之凌:BAAALAAFFAIIAgAAAA==.战之呤:BAAALAAECgIIAgAAAA==.战之灵:BAAALAAECgYIBgAAAA==.战之狑:BAAALAADCggICAAAAA==.战之翎:BAABLAAFFH8IAAICAAQIjg7TZgCeAAACAAQIjg7TZgCeAAAAAA==.战之铃:BAAALAAECggICAAAAA==.',['扎马']='扎马斯:BAABLAAFFH8MAAIEAAUIlh3YDwDoAQAEAAUIlh3YDwDoAQAAAA==.',['扒拉']='扒拉扒拉硬:BAAALAAECgUIBQAAAA==.',['打雷']='打雷有闪电:BAAALAAFFAIIBAAAAA==.',['抓点']='抓点小德:BAAALAAECgIIAgAAAA==.',['拉到']='拉到就别想跑:BAAALAAECgIIAgAAAA==.',['拾勾']='拾勾圈儿凯尖:BAABLAAFFH8FAAIJAAII/AgnMQCHAAAJAAII/AgnMQCHAAAAAA==.',['拿来']='拿来吧你:BAAALAAECgYIBgAAAA==.',['提莫']='提莫的小蘑菇:BAAALAAECggIBQAAAA==.',['搞子']='搞子:BAACLAAFFH8lAAMMAAYInRs+EgDQAQAMAAYInRs+EgDQAQAcAAMIGBqbDACuAAAsAAQKfxcAAxwACAh6HrENAJgCABwACAhHHbENAJgCAAwABgjFF4dhAM0BAAEsAAUUCAhPAAcAhSUA.',['摇曳']='摇曳鳗:BAAALAADCgIIAgAAAA==.',['摩恩']='摩恩莱特:BAABLAAFFH8GAAIFAAYIOAHUcQA9AAAFAAYIOAHUcQA9AAAAAA==.',['摩托']='摩托罗拉:BAAALAADCgYIBgAAAA==.',['斩狩']='斩狩:BAABLAAFFH8IAAILAAII6gknZAA8AAALAAII6gknZAA8AAAAAA==.',['无敌']='无敌大菠萝:BAAALAAECgYIBgAAAA==.无敌美少女:BAAALAADCggIEAAAAA==.',['无面']='无面者:BAAALAAECgYIBgAAAA==.',['时光']='时光猎魔人:BAAALAAECgYIBgAAAA==.',['昆莱']='昆莱稀有:BAAALAAECgEIAQAAAA==.',['春暖']='春暖花又开:BAAALAAECggICAAAAA==.',['晚霞']='晚霞下的海面:BAAALAADCgcIDQAAAA==.',['最烈']='最烈的酒:BAABLAAFFH8KAAICAAYIDRzDFwDcAQACAAYIDRzDFwDcAQAAAA==.',['月色']='月色正朦胧:BAAALAAECgMIBAAAAA==.',['月野']='月野喵呜:BAABLAAFFH8GAAIHAAMIkAf0IwCXAAAHAAMIkAf0IwCXAAAAAA==.',['末丶']='末丶洛:BAAALAAECgcIBwAAAA==.',['杉杉']='杉杉:BAABLAAECn8WAAMYAAgIywvaEgB+AQAYAAgICgvaEgB+AQACAAgIvASiFwEPAQAAAA==.',['李元']='李元霸:BAAALAADCgYICwAAAA==.',['枫刀']='枫刀霜剑:BAABLAAFFH8JAAILAAMIeBKoPACbAAALAAMIeBKoPACbAAABLAAFFAYIFAAEANcSAA==.',['梨花']='梨花先雪:BAAALAADCggICAAAAA==.',['森木']='森木灬:BAAALAAFFAIIAgAAAA==.',['榴莲']='榴莲丶千层:BAABLAAFFH8GAAMIAAIIwgkrNQA7AAAIAAIIwgkrNQA7AAAHAAIIGgGnXAA2AAAAAA==.',['橙橙']='橙橙丶小橙子:BAAALAAECgUIBQAAAA==.',['欧阳']='欧阳震华:BAABLAAFFH8LAAMDAAUIXwhsMQDWAAADAAMIJgpsMQDWAAAWAAUIlgUpEgC9AAAAAA==.',['正在']='正在加载目标:BAAALAAECgYIBgAAAA==.',['正视']='正视自己:BAABLAAFFH8GAAIGAAIIMBAyCABxAAAGAAIIMBAyCABxAAAAAA==.',['正高']='正高级防骑:BAAALAAECggIEAAAAA==.',['殇丨']='殇丨无痕:BAAALAADCgQIBAAAAA==.',['残龙']='残龙丨傲雪:BAAALAAECgYIBgAAAA==.',['水管']='水管在开花:BAAALAADCgcIBwAAAA==.',['永恒']='永恒娃娃:BAAALAAECgQIBAAAAA==.',['泓杰']='泓杰:BAAALAAFFAUIAQAAAA==.',['法夫']='法夫尼尔:BAABLAAECn8dAAMOAAYIkg66EwAXAQAOAAYIkg66EwAXAQAPAAYIkAXZKACVAAAAAA==.',['泽孤']='泽孤寂:BAAALAAFFAIIBAAAAA==.',['洗洗']='洗洗日吧:BAAALAAECgYICgAAAA==.',['浅色']='浅色粉笔:BAABLAAFFH8PAAICAAUIPQ8iWADwAAACAAUIPQ8iWADwAAAAAA==.',['浪莎']='浪莎袜儿:BAAALAAECgYIBgAAAA==.',['海岛']='海岛意义:BAABLAAFFH8QAAMVAAYIWAkzGwDLAAAVAAQIVA0zGwDLAAAUAAII8gZCOwB1AAABLAAFFAgIDAAUAJsMAA==.',['海灆']='海灆时见鲸:BAAALAAECgQIBAAAAA==.',['淡定']='淡定乌禅:BAABLAAECn8dAAICAAgIsBRkSQC1AQACAAgIsBRkSQC1AQAAAA==.',['源安']='源安与知恩:BAAALAADCgEIAQAAAA==.',['漏电']='漏电的阿昆达:BAAALAAECgMIAwAAAA==.',['潲水']='潲水潴丶:BAACLAAFFH8MAAMXAAII3BTmFQCmAAAXAAII3BTmFQCmAAAhAAIIoAeWFwA6AAAsAAQKfzMAAxcACAjPIekFAB8DABcACAjPIekFAB8DACEABwgKEbYfAJYBAAAA.',['灌汤']='灌汤小葱:BAAALAAECgIIAgAAAA==.',['火柴']='火柴:BAAALAAFFAIIAgAAAA==.',['灬丨']='灬丨森森丨灬:BAAALAAECgYICQAAAA==.',['灬青']='灬青丨辞灬:BAAALAADCgYIBgAAAA==.',['灬鬼']='灬鬼迷日眼:BAACLAAFFH8GAAIWAAIIYQrqEgB1AAAWAAIIYQrqEgB1AAAsAAQKfxQAAhYABwiWFaQbALYBABYABwiWFaQbALYBAAAA.',['灯红']='灯红酒绿:BAAALAAECgMIAwAAAA==.',['灯芯']='灯芯绒:BAAALAAECgMIAwAAAA==.',['灰常']='灰常硬的葱总:BAAALAAFFAIIAgAAAA==.',['灵儿']='灵儿小叮当:BAAALAAECgUIBQAAAA==.',['灾难']='灾难狂欢:BAAALAAFFAgIBAAAAA==.',['炸雷']='炸雷:BAAALAAECgQIBAAAAA==.',['烂摊']='烂摊子:BAAALAAECgYIEgAAAA==.',['烧光']='烧光异性恋:BAAALAAECgUICQAAAA==.',['熊奶']='熊奶粉:BAAALAADCgYIBgAAAA==.',['熬夜']='熬夜慢性死亡:BAAALAAECgYIBwAAAA==.',['燊舞']='燊舞:BAAALAAFFAIIAgAAAA==.',['爱吃']='爱吃西兰花:BAABLAAFFH8GAAIcAAII/w3GFgCXAAAcAAII/w3GFgCXAAAAAA==.',['爹爹']='爹爹:BAAALAAECgYIDAAAAA==.',['爺爺']='爺爺:BAAALAAFFAQIBAAAAA==.',['牙没']='牙没了:BAAALAAECgYIDAAAAA==.',['牙牙']='牙牙乐:BAAALAAECgEIAQAAAA==.',['牛破']='牛破天:BAAALAADCgMIAwAAAA==.',['牧龙']='牧龙尊:BAAALAAFFAIIAgAAAA==.',['物物']='物物:BAAALAAECgYIDwAAAA==.',['犇犇']='犇犇:BAAALAADCgMIAwAAAA==.',['狂人']='狂人老张:BAABLAAFFH8JAAICAAYIgBdHNwBjAQACAAYIgBdHNwBjAQAAAA==.',['狂怒']='狂怒丨之风:BAAALAAECgQIBQAAAA==.',['狗子']='狗子丶:BAAALAAECgYIBgAAAA==.',['狼叔']='狼叔不老:BAAALAAECgMIAwAAAA==.',['猎影']='猎影随风:BAABLAAECn8VAAMCAAgIJx5tNgCCAgACAAgIJx5tNgCCAgASAAUIuw6TeQDwAAAAAA==.',['猎手']='猎手啊:BAABLAAFFH8GAAICAAYIKxLLPQBQAQACAAYIKxLLPQBQAQABLAAFFAgICwAEAJQfAA==.',['猎祈']='猎祈:BAABLAAFFH8KAAICAAIIgx5YiwBIAAACAAIIgx5YiwBIAAAAAA==.',['王土']='王土:BAAALAADCgYIBgAAAA==.',['瓦罗']='瓦罗克大王:BAAALAAFFAIIAwAAAA==.',['瓦莱']='瓦莱丽娅:BAAALAADCgIIAgAAAA==.',['电竞']='电竞小龙人:BAABLAAFFH8IAAIPAAMIWgiVGQBtAAAPAAMIWgiVGQBtAAAAAA==.',['番茄']='番茄骑士:BAACLAAFFH8WAAIKAAYI1x9ODQDwAQAKAAYI1x9ODQDwAQAsAAQKfxQAAgoACAg2JfsCAAMDAAoACAg2JfsCAAMDAAAA.',['疯狼']='疯狼:BAAALAAECgUIBQAAAA==.疯狼一狂暴战:BAAALAAECgYIEAAAAA==.',['痛苦']='痛苦:BAABLAAFFH8UAAIMAAgIgxykBwCGAgAMAAgIgxykBwCGAgAAAA==.',['皮鞋']='皮鞋老六:BAAALAAECgEIAQAAAA==.',['盲侠']='盲侠:BAAALAAECggICAAAAA==.',['相濡']='相濡意沫:BAAALAAECgYIBgAAAA==.',['看白']='看白腿:BAAALAAECgYIBgAAAA==.',['破碎']='破碎星河:BAAALAAECgEIAQAAAA==.破碎星空:BAAALAAECgIIAgAAAA==.',['神愆']='神愆唯曌:BAAALAADCggICAAAAA==.',['空心']='空心核桃:BAAALAAECgYIBgAAAA==.',['章鱼']='章鱼饲养员:BAABLAAFFH8GAAICAAIIdBkERQCfAAACAAIIdBkERQCfAAAAAA==.',['笑破']='笑破天:BAAALAAECgQIBQAAAA==.',['第七']='第七根草:BAAALAAFFAYIAgAAAA==.',['第二']='第二根草:BAABLAAFFH8MAAMFAAYI6RbHGgCGAQAFAAYI6RbHGgCGAQAZAAQIMRyWFABIAQAAAA==.',['第四']='第四根草:BAABLAAFFH8GAAIIAAYIXBKKEgBVAQAIAAYIXBKKEgBVAQAAAA==.',['米潞']='米潞:BAAALAADCggICAAAAA==.',['米璐']='米璐:BAAALAAECgYICgAAAA==.',['米莎']='米莎:BAAALAAECggICgAAAA==.',['米魯']='米魯:BAAALAADCgYIBgAAAA==.',['米鹭']='米鹭:BAAALAADCggIEAAAAA==.',['米鹿']='米鹿:BAAALAADCggICAAAAA==.',['粘液']='粘液饭:BAAALAAECgUIBQAAAA==.',['紫月']='紫月清风:BAAALAADCgcICQAAAA==.',['紫色']='紫色佷有韵味:BAAALAAECggICAAAAA==.',['红焖']='红焖的小排骨:BAAALAADCgEIAQAAAA==.',['红牛']='红牛:BAAALAADCgMIBAAAAA==.',['给你']='给你打出汁儿:BAAALAAECgYIDAAAAA==.',['绯红']='绯红:BAABLAAFFH8GAAIKAAYI4BR1GwCLAQAKAAYI4BR1GwCLAQAAAA==.',['羽轩']='羽轩:BAAALAAECgUIBwAAAA==.',['翘破']='翘破天:BAAALAAFFAEIAQAAAA==.',['耳机']='耳机:BAAALAAFFAIIAgAAAA==.',['聖光']='聖光:BAABLAAECn8VAAMZAAgIOyEEAwD8AgAZAAgIOyEEAwD8AgAFAAYIuRAUbwAlAQAAAA==.',['肠少']='肠少:BAAALAADCgcIBwAAAA==.',['胖灬']='胖灬老卡:BAAALAAECgYIDgAAAA==.',['胖虎']='胖虎灬:BAAALAAECgIIAgAAAA==.',['至尊']='至尊天神:BAACLAAFFH8OAAMbAAYIaAlDEwAVAQAbAAYIaAlDEwAVAQAQAAII9gfqFAB6AAAsAAQKfyYABBAABwhKFCArAEsBABAABggGEyArAEsBACIABwi9CBE+AD4BABsABgjzBd06AMEAAAAA.',['芙卡']='芙卡洛斯:BAACLAAFFH8cAAIUAAUIQhHCIQA6AQAUAAUIQhHCIQA6AQAsAAQKfx0AAxQACAiiFwIyABcCABQACAhTFgIyABcCACMABwj9D+ASAIEBAAAA.',['芯匠']='芯匠:BAAALAAECgMIAwAAAA==.',['花开']='花开彼岸:BAAALAADCgIIAgAAAA==.',['茉莉']='茉莉的忧伤:BAACLAAFFH8IAAMcAAIIMx5FCgC4AAAcAAIIMx5FCgC4AAAMAAIIUglvYwA9AAAsAAQKfxUAAxwACAiuIgwIAOcCABwACAiuIgwIAOcCAAwAAQgdEzABATwAAAAA.',['莱埃']='莱埃泽尔:BAAALAAECgYIDAAAAA==.',['菜死']='菜死的:BAAALAAECgIIBQAAAA==.',['萨二']='萨二零:BAAALAAFFAYIBAAAAA==.',['萨摩']='萨摩天:BAAALAAECgIIAgAAAA==.',['萬劍']='萬劍一丷:BAAALAAECggIDgAAAA==.',['葵司']='葵司:BAAALAADCgMIAwAAAA==.',['蓝雨']='蓝雨:BAAALAADCgMIAwAAAA==.',['蔷薇']='蔷薇白骑:BAAALAAFFAQIAwAAAA==.',['薇尔']='薇尔莉特:BAAALAAECgYIBgAAAA==.',['虾仁']='虾仁饭:BAAALAAECgIIAgAAAA==.',['血色']='血色丨兽獣:BAABLAAFFH8QAAIWAAYIJRzVCACSAQAWAAYIJRzVCACSAQAAAA==.血色丨刚毅:BAABLAAFFH8OAAIWAAYI1x2xBwCwAQAWAAYI1x2xBwCwAQAAAA==.血色丨焱焱:BAAALAAFFAQIBAAAAA==.血色丨牛汼:BAABLAAFFH8JAAIWAAYIahv/BwCoAQAWAAYIahv/BwCoAQAAAA==.',['西尔']='西尔瓦娜斯:BAAALAAECgMIBAAAAA==.',['许大']='许大炮:BAAALAAECgYIBgAAAA==.',['诺提']='诺提勒斯:BAAALAAECgYIBgAAAA==.',['赫夣']='赫夣:BAAALAAECgMIAwAAAA==.',['赫妻']='赫妻:BAAALAAECgIIAgAAAA==.',['轩辕']='轩辕氏:BAAALAADCggICAAAAA==.',['还没']='还没呢:BAACLAAFFH8eAAIHAAYIGxBRGABxAQAHAAYIGxBRGABxAQAsAAQKfxUAAgcABgiAFnItAH0BAAcABgiAFnItAH0BAAAA.',['这个']='这个牙还是大:BAAALAADCgYIBgAAAA==.',['这把']='这把能限时吗:BAAALAAFFAYIAgAAAA==.',['违法']='违法必究:BAABLAAFFH8FAAICAAIIihN0ZACIAAACAAIIihN0ZACIAAAAAA==.',['迷你']='迷你可爱多:BAAALAADCgEIAQAAAA==.',['迷失']='迷失惪:BAAALAAECgIIBAAAAA==.迷失猎手:BAAALAAECgIIBAAAAA==.',['迷雾']='迷雾之道:BAAALAAECgcIBwAAAA==.',['逻辑']='逻辑猫:BAAALAADCgQIBAAAAA==.',['那夜']='那夜雪吹寒:BAAALAAFFAIIAgAAAA==.',['酸草']='酸草莓:BAAALAAECggIDQAAAA==.',['醉里']='醉里挑灯看剑:BAAALAADCgYIBgAAAA==.',['长胡']='长胡子的女生:BAAALAADCggICwAAAA==.',['长风']='长风与冷烟:BAAALAAECgcIDgAAAA==.',['閉月']='閉月羞蘤小仙:BAAALAAFFAIIBAAAAA==.',['開心']='開心每一天:BAAALAAFFAIIAgAAAA==.',['问岛']='问岛山迁:BAAALAADCgIIAgAAAA==.',['闹小']='闹小闹:BAAALAAECgIIAgABLAAFFAgIIQAUAJAbAA==.',['闻太']='闻太师:BAAALAAECggICAAAAA==.',['防战']='防战:BAAALAADCgMIAwAAAA==.',['阿克']='阿克萌德丶:BAAALAAECgIIAgAAAA==.',['阿坎']='阿坎多尔:BAAALAAECggICgAAAA==.',['阿坤']='阿坤哥小悦:BAACLAAFFH8OAAMkAAMIMxfXAgC2AAAKAAMI/hGrGgDzAAAkAAIIyB3XAgC2AAAsAAQKfycAAyQACAjTInwEANkCACQACAhOH3wEANkCAAoABwgwHT4/ADgCAAAA.',['阿德']='阿德:BAABLAAFFH8SAAIGAAYI4AcfBQDcAAAGAAYI4AcfBQDcAAAAAA==.',['陸國']='陸國:BAAALAAFFAIIAgAAAA==.',['雨与']='雨与铁锅炖:BAAALAAECgYIDwAAAA==.',['雪碧']='雪碧洗银枪:BAAALAAFFAYIAgAAAA==.',['零七']='零七天才萨:BAAALAADCggICAAAAA==.',['雷首']='雷首啸天:BAAALAAECgMIAwAAAA==.',['霜瑾']='霜瑾莉莉娅:BAAALAADCgEIAQAAAA==.',['青花']='青花椒:BAAALAAFFAIIAgAAAA==.',['靓女']='靓女:BAAALAAECgMIAwAAAA==.',['静态']='静态风暴:BAABLAAECn8jAAMJAAgI9gw2YACXAQAJAAgI9gw2YACXAQAdAAgIoAOp3wDQAAAAAA==.',['顾老']='顾老板咋咋:BAAALAAECgYICgAAAA==.',['風景']='風景:BAABLAAFFH8GAAIFAAMIUAtjIQDLAAAFAAMIUAtjIQDLAAAAAA==.',['风月']='风月同天:BAAALAAECgYICAAAAA==.',['风雨']='风雨小小:BAAALAADCgIIAgAAAA==.',['骑猪']='骑猪过马路:BAAALAAECgYIBgAAAA==.',['高岭']='高岭丨大神:BAAALAADCgIIAgAAAA==.',['鲑鱼']='鲑鱼大帝:BAAALAAECgQIBAAAAA==.',['鲜榨']='鲜榨龙乳:BAACLAAFFH8ZAAMVAAYIwwyEEQD8AAAVAAUI6AiEEQD8AAAUAAQIsxQkIQC4AAAsAAQKfyoAAxQABwgiIKceAIECABQABwgiIKceAIECABUABgjcG/sXAI8BAAAA.',['黑店']='黑店:BAACLAAFFH8NAAIFAAUI4Q1YLgAYAQAFAAUI4Q1YLgAYAQAsAAQKfxkAAgUABgipHKiBAOkBAAUABgipHKiBAOkBAAAA.',['黑暗']='黑暗灬烈酒:BAACLAAFFH8FAAIFAAMI4BfcQACUAAAFAAMI4BfcQACUAAAsAAQKfx8ABAUACAjOHC0zAKYCAAUACAitHC0zAKYCABkABgiWHxgNACACAB4ABgiaFbA5AFsBAAAA.',['黑皮']='黑皮体育生阿:BAAALAAECgQICAAAAA==.',['黑蹄']='黑蹄玫瑰:BAAALAAECggIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end