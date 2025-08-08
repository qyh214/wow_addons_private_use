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
 local lookup = {'Priest-Discipline','Priest-Shadow','Priest-Holy','DeathKnight-Blood','DeathKnight-Unholy','Mage-Arcane','Mage-Frost','Shaman-Restoration','Shaman-Elemental','Warlock-Destruction','Warlock-Affliction','Warrior-Fury','Druid-Restoration','Druid-Balance','Rogue-Assassination','Paladin-Protection','Paladin-Retribution','Hunter-Marksmanship','Hunter-Survival','Hunter-BeastMastery','Monk-Mistweaver','Evoker-Preservation','Evoker-Devastation','DemonHunter-Havoc','DeathKnight-Frost','Warrior-Arms','Warrior-Protection','DemonHunter-Vengeance','Shaman-Enhancement','Rogue-Subtlety','Mage-Fire','Monk-Windwalker','Paladin-Holy','Monk-Brewmaster','Warlock-Demonology','Druid-Feral','Rogue-Outlaw',}; local provider = {region='CN',realm='血羽',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aiyouou:BAAAKgAFFAIIAgAAAA==.',Ar='Ardenrena:BAABKgAFFH8LAAQBAAYIEhQRHgCrAAABAAIISBkRHgCrAAACAAQIyBGsHACfAAADAAEI8ACkQwAjAAAAAA==.',Bb='Bbudk:BAABKgAFFH8OAAMEAAgIwhvxAQCdAQAEAAgISxnxAQCdAQAFAAQICiXYBQBIAQAAAA==.',Bl='Bloodbecry:BAAAKgADCggIDAAAAA==.',Bs='Bshadow:BAABKgAECn8XAAMGAAgIQx7XFQBDAgAGAAgIPx3XFQBDAgAHAAUIjhGIUACqAAAAAA==.',Cy='Cyanscream:BAACKgAFFH8cAAMIAAUISSGyDQBzAQAIAAUISSGyDQBzAQAJAAMISQgSGgCqAAAqAAQKfxUAAggACAg1H9MWAD8CAAgACAg1H9MWAD8CAAAA.',De='Deathlj:BAABKgAFFH8KAAIKAAgIlQ1pDADGAQAKAAgIlQ1pDADGAQAAAA==.',El='Elegyss:BAABKgAFFH8GAAILAAYI3gc/BQAyAQALAAYI3gc/BQAyAQAAAA==.',Fi='Firecloudk:BAABKgAFFH8GAAIMAAMITB0hFgAKAQAMAAMITB0hFgAKAQAAAA==.',Gr='Grubby:BAAAKgAFFAMIAwAAAA==.',Gy='Gyugijgy:BAABKgAECn8YAAIHAAgICRhSLwC4AQAHAAgICRhSLwC4AQAAAA==.',Ha='Hamburg:BAAAKgAECggICQAAAA==.Haze:BAAAKgAECggIDAAAAA==.',Is='Isolation:BAABKgAFFH8GAAMNAAYIuAPjHwCsAAANAAUIKgTjHwCsAAAOAAEIZAXrXQA+AAABKgAFFAgIHAANAPUZAA==.',Ka='Katsumi:BAABKgAFFH8eAAIMAAYIfhULCgCPAQAMAAYIfhULCgCPAQABKgAFFAgIOAAPAFYgAA==.',Lc='Lclucifer:BAAAKgAECgQIBAAAAA==.',Lo='Loganz:BAAAKgAECgEIAQAAAA==.',Lz='Lzblood:BAACKgAFFH8WAAIEAAgIxhjrAwAbAgAEAAgIxhjrAwAbAgAqAAQKfxsAAgQACAgmBek9AMkAAAQACAgmBek9AMkAAAAA.Lzpink:BAACKgAFFH9JAAIQAAgIiginCwA9AQAQAAgIiginCwA9AQAqAAQKfxoAAxAACAj/DSAuAOsAABAACAjGCSAuAOsAABEAAghfG+swAXwAAAAA.',Ma='Martin:BAAAKgADCggICAAAAA==.',Mi='Mikasaf:BAAAKgAFFAIIAgAAAA==.Mizuki:BAAAKgADCgQIBAAAAA==.',Mo='Mourning:BAABKgAFFH8RAAMSAAUIzxnmEwBDAQASAAUIzxnmEwBDAQATAAEIXxJDBABNAAABKgAFFAgIOAAPAFYgAA==.',Oe='Oeoe:BAAAKgAECgEIAQAAAA==.',On='Onlythisone:BAAAKgAECgQIAwAAAA==.',Ps='Psly:BAAAKgADCgQIBAAAAA==.',Ro='Roit:BAAAKgAECgQIBAAAAA==.',Ry='Rye:BAAAKgAECgcIBwAAAA==.',Sc='Sctersally:BAAAKgADCgYIBgAAAA==.',So='Socrazyman:BAAAKgAFFAQIBAAAAA==.',Ta='Tailslide:BAAAKgAECgUIBQAAAA==.',Tc='Tc:BAAAKgAECgIIAgAAAA==.',Un='Undecember:BAABKgAFFH8WAAIRAAYIxCJwDgDxAQARAAYIxCJwDgDxAQAAAA==.',Wh='Whiteovo:BAABKgAFFH8IAAIHAAgIqBmkAQBTAgAHAAgIqBmkAQBTAgAAAA==.',Wi='Without:BAAAKgAFFAgIAQAAAA==.',Xo='Xom:BAABKgAFFH8IAAIPAAMIRxA3HQDDAAAPAAMIRxA3HQDDAAAAAA==.Xorn:BAAAKgAECgcICAAAAA==.',Ye='Yep:BAAAKgADCggICAAAAA==.',Zi='Zihuatanejo:BAABKgAFFH8IAAIIAAgImxFdBgDDAQAIAAgImxFdBgDDAQAAAA==.',['一丨']='一丨傳說丨一:BAAAKgADCgMIAgAAAA==.一丨妖術丨一:BAAAKgADCgcIBwAAAA==.一丨淩丨一:BAAAKgADCgYICgAAAA==.',['一其']='一其疾如风一:BAABKgAFFH8IAAIUAAgIBQbeCwCEAQAUAAgIBQbeCwCEAQAAAA==.',['一刀']='一刀阴死你:BAAAKgADCggIDAAAAA==.',['一只']='一只大肥瓜:BAABKgAFFH8JAAIRAAcItBiuEwBkAQARAAcItBiuEwBkAQAAAA==.一只青团:BAABKgAFFH8RAAMSAAgIPBkuBwDUAQASAAgIhRguBwDUAQAUAAMIFhLMPgCjAAAAAA==.',['一戰']='一戰無不勝一:BAAAKgADCggICQAAAA==.',['一根']='一根:BAAAKgAECgcICQAAAA==.',['一玉']='一玉麒麟一:BAAAKgADCgMIAwAAAA==.',['一箱']='一箱染煞钱币:BAACKgAFFH8IAAIVAAMInRW6GQDQAAAVAAMInRW6GQDQAAAqAAQKfxQAAhUABwghGpMuACcBABUABwghGpMuACcBAAAA.',['一览']='一览众山小:BAAAKgAECgcICwAAAA==.',['一顿']='一顿仨馒头:BAACKgAFFH8IAAMWAAMIRSAiBAD0AAAWAAMIRSAiBAD0AAAXAAMIvRJEJACvAAAqAAQKfxsAAxYACAiVIRMEAG4CABYACAiVIRMEAG4CABcABwjhGRwkAJIBAAEqAAUUCAgQAAMAvxoA.一顿俩鸡腿:BAABKgAFFH8QAAQDAAgIvxqsBAD3AQADAAcImBqsBAD3AQABAAIIlwmPIQBzAAACAAEI5xYrKgBJAAAAAA==.',['七八']='七八零零:BAAAKgAFFAMIAwAAAA==.',['七宗']='七宗罪灬恶魔:BAAAKgAFFAYIAgAAAA==.',['三开']='三开战贼僧:BAAAKgAECgIIAgAAAA==.',['三笠']='三笠丶阿克曼:BAABKgAFFH8TAAIPAAcItxf/BgCtAQAPAAcItxf/BgCtAQAAAA==.',['不会']='不会起名字:BAAAKgAECgQIBAAAAA==.',['严直']='严直高:BAAAKgAECgQIBAAAAA==.',['丨吟']='丨吟灬天丨:BAAAKgAFFAMIAgAAAA==.',['丨魅']='丨魅灬影丨:BAABKgAFFH8QAAIYAAYIRRSWEQBzAQAYAAYIRRSWEQBzAQAAAA==.',['丶会']='丶会钓鱼的猫:BAAAKgAECgIIAgAAAA==.',['丶大']='丶大茄子丶:BAAAKgAECggICAAAAA==.',['丶梦']='丶梦蝶:BAABKgAFFH8GAAIOAAMIvg7rQwCeAAAOAAMIvg7rQwCeAAAAAA==.',['丶牛']='丶牛二小丶:BAABKgAFFH8GAAINAAYIlRYVCgBlAQANAAYIlRYVCgBlAQAAAA==.',['丶甲']='丶甲甲:BAACKgAFFH8FAAIVAAMISiSSEAAoAQAVAAMISiSSEAAoAQAqAAQKfx8AAhUACAhiIkIHALkCABUACAhiIkIHALkCAAAA.',['丶董']='丶董巴特丶:BAABKgAFFH8GAAIUAAYI8x22EAByAQAUAAYI8x22EAByAQAAAA==.',['为了']='为了你变狼人:BAAAKgAECgYIBgAAAA==.',['乌拉']='乌拉辣拉貔貅:BAACKgAFFH8GAAIOAAQIox0PDwD/AAAOAAQIox0PDwD/AAAqAAQKfycAAw0ACAiCH74RADkCAA0ACAiCH74RADkCAA4ACAiwEX1cAEwBAAEqAAUUCAgQAAMAvxoA.',['乌璐']='乌璐德:BAAAKgAECgYICgAAAA==.',['乌龟']='乌龟的青头:BAAAKgAECgIIAgAAAA==.',['乾翊']='乾翊:BAABKgAFFH8IAAIRAAgI8BayCgAaAgARAAgI8BayCgAaAgAAAA==.',['二手']='二手的:BAAAKgADCggIDgAAAA==.',['二貘']='二貘:BAABKgAFFH8GAAIHAAYI7hNdBwBQAQAHAAYI7hNdBwBQAQAAAA==.',['亚斯']='亚斯宾娜:BAAAKgAECgUIBQAAAA==.',['伊弉']='伊弉冉尊:BAAAKgAECgUIBQAAAA==.',['伊格']='伊格尼丝:BAAAKgAFFAgIBAAAAA==.伊格尼斯:BAAAKgAFFAQIBAAAAA==.',['伍德']='伍德费斯:BAAAKgADCgIIAgAAAA==.',['伏特']='伏特加加冰:BAAAKgAFFAYIAgAAAA==.',['众生']='众生同调奥秘:BAACKgAFFH8wAAMFAAgI4iR6AgCtAgAFAAgI4iR6AgCtAgAZAAIIxCMqEQBmAAAqAAQKfygABAUACAhaI64hADgCAAUABwjFJK4hADgCABkAAwiBGd4iAMUAAAQAAQjaGkFLAEgAAAAA.',['会飞']='会飞的苹果:BAAAKgAFFAIIAgAAAA==.',['低调']='低调是一种罪:BAABKgAFFH8GAAIHAAMIzh/PCwANAQAHAAMIzh/PCwANAQAAAA==.',['佐岸']='佐岸丨布丁:BAACKgAFFH8iAAIRAAYILx/WIABrAQARAAYILx/WIABrAQAqAAQKfzIAAhEACAizJAYYAKYCABEACAizJAYYAKYCAAAA.',['依然']='依然潇洒:BAABKgAFFH8NAAIRAAQIsCRXEQAPAQARAAQIsCRXEQAPAQAAAA==.依然萨爽:BAAAKgAECgYIDAAAAA==.',['侧漏']='侧漏:BAAAKgADCgEIAQAAAA==.',['做到']='做到两个维护:BAAAKgAECggICAAAAA==.',['停一']='停一下别打了:BAABKgAECn8UAAQaAAgIzRRoJQBcAQAaAAgIORNoJQBcAQAMAAQIVxXSIwDJAAAbAAUIpwVNPQBnAAAAAA==.',['傲天']='傲天灬绮罗生:BAAAKgADCggICAAAAA==.',['元宝']='元宝:BAACKgAFFH9DAAICAAgIqSK/AQC6AgACAAgIqSK/AQC6AgAqAAQKfxkAAgIACAjYIukJAIECAAIACAjYIukJAIECAAAA.',['兄弟']='兄弟要盘么:BAAAKgAECgMIAgAAAA==.',['充电']='充电:BAAAKgAFFAMIAwAAAA==.',['克里']='克里瑟历斯:BAABKgAFFH8DAAIFAAMIcx8jIQAYAQAFAAMIcx8jIQAYAQABKgAFFAgICAAMALMSAA==.',['兎大']='兎大乖:BAAAKgAFFAcIAwAAAA==.',['兎小']='兎小乖:BAABKgAFFH8HAAIUAAMI9A3oGwC6AAAUAAMI9A3oGwC6AAAAAA==.',['兜兜']='兜兜糖:BAAAKgADCggICAAAAA==.',['內个']='內个骑士:BAABKgAECn8gAAIQAAgImg3YJQAnAQAQAAgImg3YJQAnAQAAAA==.',['全能']='全能牟牟牛:BAAAKgADCggIEAAAAA==.',['八神']='八神嘉儿丶:BAABKgAFFH8NAAIUAAYIUBitDgCJAQAUAAYIUBitDgCJAQAAAA==.',['公主']='公主的厷:BAAAKgAECgYIEQAAAA==.',['公牛']='公牛也能奶:BAAAKgAECgcIBwAAAA==.',['六氟']='六氟化硫:BAAAKgAECgYICQAAAA==.',['兰卡']='兰卡斯卓尔:BAABKgAFFH8UAAIMAAQIVyO0BgAyAQAMAAQIVyO0BgAyAQAAAA==.',['关云']='关云短:BAAAKgAECgIIAQAAAA==.',['兽花']='兽花灬绮罗生:BAACKgAFFH8JAAIPAAMIyxIKGQDgAAAPAAMIyxIKGQDgAAAqAAQKfxkAAg8ACAhXF1ASAOsBAA8ACAhXF1ASAOsBAAAA.',['冠军']='冠军不如冠希:BAAAKgAECgYIBgAAAA==.',['冬日']='冬日暖阳啊:BAAAKgAFFAMIAwAAAA==.',['冰凝']='冰凝物语:BAABKgAECn8xAAIHAAgI8R8SDQBuAgAHAAgI8R8SDQBuAgAAAA==.',['冲锋']='冲锋我不亡:BAAAKgADCgIIAgAAAA==.',['冻结']='冻结伤:BAAAKgAFFAQIBAAAAA==.',['凛冬']='凛冬降临:BAAAKgAFFAIIAgAAAA==.',['凝望']='凝望灬深渊:BAAAKgAFFAQIBAAAAA==.',['凝霜']='凝霜雨:BAAAKgAFFAQIBAAAAA==.',['凱寂']='凱寂寞:BAAAKgADCgYIBgAAAA==.',['出溜']='出溜船船长:BAAAKgAECgYICgAAAA==.',['刘春']='刘春的耋:BAAAKgAECgYIBgAAAA==.',['初心']='初心壹世:BAABKgAFFH8KAAMOAAgIJBbhCQD2AQAOAAcIBxnhCQD2AQANAAEI1AMQNwA/AAAAAA==.',['利群']='利群富春山居:BAABKgAECn8ZAAIcAAgImBYkGAC9AQAcAAgImBYkGAC9AQAAAA==.',['力亞']='力亞:BAAAKgAFFAQIBAAAAA==.',['加拉']='加拉达:BAAAKgAFFAgIAQAAAA==.',['勾栏']='勾栏听曲儿:BAABKgAFFH8TAAMdAAYIkBmbBgCGAQAdAAYIkBmbBgCGAQAIAAQICwWuHwCaAAAAAA==.',['北方']='北方:BAAAKgAECgMIAwAAAA==.',['十二']='十二载丶:BAACKgAFFH8ZAAIPAAQIJB/8EwASAQAPAAQIJB/8EwASAQAqAAQKfzAAAg8ACAjzHyYMAFcCAA8ACAjzHyYMAFcCAAAA.',['华佗']='华佗再世:BAAAKgAECgYICwAAAA==.',['博丽']='博丽:BAAAKgAECgYIBgAAAA==.',['原味']='原味绿皮肤:BAABKgAECn8ZAAMMAAgIPwfLQwAIAQAMAAgI/AbLQwAIAQAaAAQINwbmTQBvAAAAAA==.',['发惹']='发惹儿:BAAAKgAECgQIBAAAAA==.',['古林']='古林舞:BAAAKgAFFAgIBAAAAA==.',['古道']='古道东风胖牛:BAAAKgADCgUIBQAAAA==.',['只喝']='只喝无糖可乐:BAAAKgAFFAEIAQAAAA==.',['可乐']='可乐老登:BAABKgAFFH8LAAMaAAYIXxktAQDAAQAaAAYIhxUtAQDAAQAMAAQITRwzDQAGAQABKgAFFAgIDgAEAMIbAA==.',['可惜']='可惜丨不是你:BAAAKgAECgYIEgAAAA==.',['可爱']='可爱女人:BAAAKgAECggICAAAAA==.',['右眼']='右眼寂寞:BAAAKgAECgMIBgAAAA==.',['叶子']='叶子宝贝:BAAAKgAECgMIBAAAAA==.',['号令']='号令八荒:BAAAKgAECgcIDAAAAA==.',['吃零']='吃零食长大个:BAAAKgAECgEIAgAAAA==.',['吉按']='吉按娜姊妹:BAAAKgAFFAMIAgAAAA==.',['听错']='听错了风:BAABKgAFFH8bAAMCAAgIKhomBgDsAQACAAcIehkmBgDsAQABAAEIIwr2FABJAAABKgAFFAgIJwAXAGggAA==.',['呦呦']='呦呦鹿鸣:BAAAKgAECgYICgAAAA==.',['呵丶']='呵丶:BAAAKgADCggICAAAAA==.',['命运']='命运云云潮流:BAACKgAFFH8RAAMPAAUITCT5CQCzAQAPAAUITCT5CQCzAQAeAAMITxLBDACXAAAqAAQKfyYAAx4ACAiwHPcOAPoBAB4ACAgRGfcOAPoBAA8ABAjKHKMlADwBAAAA.命运云潮流:BAAAKgAECggIDQAAAA==.',['咩咩']='咩咩:BAAAKgAECgEIAQAAAA==.',['哈拉']='哈拉烧:BAABKgAFFH8GAAIFAAYI2gtfGABaAQAFAAYI2gtfGABaAQAAAA==.',['唰唰']='唰唰娃儿:BAAAKgAECggIDgAAAA==.',['喵喵']='喵喵苗:BAAAKgAECgYIBgAAAA==.',['嘉翊']='嘉翊:BAABKgAFFH8IAAIYAAgIYwUVEgAPAQAYAAgIYwUVEgAPAQAAAA==.',['噓噓']='噓噓后的颤抖:BAAAKgAECgEIAQAAAA==.',['团长']='团长罚三千:BAAAKgAECgQIBAAAAA==.',['囧四']='囧四娘:BAAAKgADCgIIAgAAAA==.',['土灵']='土灵灬绮罗生:BAAAKgAFFAIIAgAAAA==.',['土豆']='土豆蘸奶:BAAAKgADCggICAAAAA==.',['圣光']='圣光吖:BAABKgAFFH8FAAIRAAUIXxyQJQBTAQARAAUIXxyQJQBTAQAAAA==.圣光的救赎:BAAAKgAECgEIAQAAAA==.',['圣影']='圣影:BAAAKgAECgMIAwAAAA==.',['圣骑']='圣骑行不行啊:BAAAKgAECgQIBQAAAA==.',['埋头']='埋头猛冲:BAAAKgAECgEIAQAAAA==.',['塞纳']='塞纳李奥:BAAAKgAECgYIBgAAAA==.',['声优']='声优都是怪物:BAABKgAFFH8JAAMNAAMI2RjUGADaAAANAAMI2RjUGADaAAAOAAIIjQFrWQBMAAAAAA==.',['夏虫']='夏虫语冰:BAABKgAFFH8TAAMUAAcICBfGCQA1AQAUAAQIeiLGCQA1AQASAAcIZRJUEwDFAAAAAA==.',['夜幕']='夜幕降临:BAAAKgADCgEIAQAAAA==.',['夜空']='夜空最亮的星:BAAAKgAECgYIBgAAAA==.',['大地']='大地枝叶:BAAAKgADCgYIBgAAAA==.大地萨:BAAAKgAECgUICAAAAA==.',['大糯']='大糯糯:BAAAKgAECgUICgAAAA==.',['大胖']='大胖师傅:BAAAKgAECgIIAgAAAA==.',['天下']='天下青山一样:BAAAKgAFFAEIAQAAAA==.',['天丨']='天丨命:BAABKgAFFH8IAAIFAAgINgs7CgDpAQAFAAgINgs7CgDpAQAAAA==.',['天天']='天天啃大骨头:BAAAKgAECgYIBwAAAA==.',['天晴']='天晴:BAAAKgAECggICAAAAA==.',['天苍']='天苍月:BAAAKgAECgEIAQAAAA==.',['天降']='天降锤神阿狸:BAAAKgAECgYIDgAAAA==.',['天陨']='天陨星丨银狼:BAAAKgAECggIDAAAAA==.',['天骑']='天骑士:BAABKgAFFH8HAAIRAAQIeiDWMgAeAQARAAQIeiDWMgAeAQAAAA==.',['失落']='失落圣光:BAAAKgAFFAQIBAAAAA==.',['头号']='头号大鸟:BAABKgAFFH8MAAMSAAgIlRNODwBuAQASAAYI+xdODwBuAQAUAAYI8gooHwASAQAAAA==.头号白白:BAABKgAFFH8OAAQCAAYIMxwJBwCrAQACAAYIMxwJBwCrAQADAAUIsx3fDwA0AQABAAII1hVlHQCHAAAAAA==.',['奈斯']='奈斯哦:BAABKgAFFH8XAAIYAAYIzhfHDQBvAQAYAAYIzhfHDQBvAQAAAA==.奈斯啊:BAABKgAECn8ZAAIIAAgIlRnfJwDgAQAIAAgIlRnfJwDgAQAAAA==.',['奈法']='奈法勒姆:BAABKgAFFH8FAAIIAAMI5hq+HACrAAAIAAMI5hq+HACrAAAAAA==.',['奔雷']='奔雷战:BAAAKgAECgUICAAAAA==.',['奥希']='奥希酥:BAAAKgAECggICAAAAA==.',['奥迪']='奥迪大魔王:BAAAKgAFFAEIAQABKgAFFAYIDQAEALQbAA==.',['奶一']='奶一下别看了:BAABKgAECn8ZAAMfAAgILhcrOgCqAQAfAAgItBArOgCqAQAGAAUI/xgYRwAjAQAAAA==.',['奶妈']='奶妈救我灬:BAAAKgAECgQIBAAAAA==.',['奶糖']='奶糖卡布奇诺:BAAAKgAECgcICQAAAA==.',['如梦']='如梦似幻:BAABKgAECn8YAAIUAAgIrBIhWQBOAQAUAAgIrBIhWQBOAQAAAA==.',['如虹']='如虹:BAACKgAFFH8LAAIRAAYIqR0WEQAQAQARAAYIqR0WEQAQAQAqAAQKfxUAAhEACAiFJYEKAPACABEACAiFJYEKAPACAAAA.',['姐丶']='姐丶獨一無二:BAAAKgAFFAMIAwAAAA==.',['姬宫']='姬宫十六夜:BAABKgAFFH8GAAIFAAYIEhO+FQBuAQAFAAYIEhO+FQBuAQAAAA==.',['威尼']='威尼斯的水:BAABKgAFFH8GAAIRAAYINBPWHQB7AQARAAYINBPWHQB7AQAAAA==.',['嫒尐']='嫒尐傑:BAABKgAFFH8IAAIYAAgIoBPVBwAWAgAYAAgIoBPVBwAWAgAAAA==.',['嫣姬']='嫣姬:BAAAKgAECgUIAwAAAA==.',['子了']='子了子了:BAABKgAFFH8PAAMUAAMIpBH9NQC9AAAUAAMIpBH9NQC9AAASAAMIqATQHgB5AAABKgAFFAgIIwAGAIglAA==.',['孔哥']='孔哥仁且义:BAACKgAFFH8GAAIFAAMIsxOGMQDNAAAFAAMIsxOGMQDNAAAqAAQKfxUABAUACAj1GZssAAMCAAUACAiqGJssAAMCABkABAihGnAfAOcAAAQAAgguB4BMAEMAAAAA.',['孙小']='孙小美:BAAAKgADCggICAAAAA==.',['安小']='安小僧:BAAAKgAFFAEIAgAAAA==.',['家有']='家有萌宠:BAAAKgADCgQIBAAAAA==.家有萌德:BAAAKgADCggICAAAAA==.家有萌虎:BAAAKgAECggIEQAAAA==.',['对对']='对对:BAAAKgAECgIIAgAAAA==.',['小个']='小个子法神:BAAAKgAECgQIBAAAAA==.',['小凌']='小凌丶:BAAAKgAECgIIAgAAAA==.',['小刀']='小刀奈何桥:BAAAKgADCggICAAAAA==.',['小城']='小城里:BAAAKgAFFAcIBAAAAA==.',['小小']='小小法佬:BAAAKgAECggICAAAAA==.',['小熊']='小熊小羊:BAAAKgAECggIDQAAAA==.小熊硬糖:BAABKgAFFH8HAAIYAAcIzxFlDQCtAQAYAAcIzxFlDQCtAQAAAA==.',['小瓜']='小瓜瞎:BAAAKgAECggIEQAAAA==.',['小蜜']='小蜜桃儿:BAAAKgAECgUICAAAAA==.',['小馬']='小馬爷:BAABKgAFFH8RAAIOAAQIaxptLQDdAAAOAAQIaxptLQDdAAAAAA==.',['尘缘']='尘缘不相误:BAAAKgAECgIIAgAAAA==.',['尤菲']='尤菲如月:BAABKgAFFH8QAAIRAAYIjRYUGgCQAQARAAYIjRYUGgCQAQAAAA==.',['尸体']='尸体收割机:BAAAKgADCggICAAAAA==.',['尼奥']='尼奥:BAABKgAFFH8GAAIYAAQIKRubLQDFAAAYAAQIKRubLQDFAAAAAA==.',['左手']='左手哈哈:BAAAKgADCgUIBQAAAA==.',['巧克']='巧克力楠楠:BAAAKgAECgUIBQAAAA==.',['布卡']='布卡布卡:BAABKgAFFH8IAAICAAQIkhDpEQDTAAACAAQIkhDpEQDTAAAAAA==.',['帅气']='帅气的藕总:BAABKgAFFH8GAAMVAAQIYBFWJQBuAAAVAAMIpxRWJQBuAAAgAAEIwwf3JQA3AAAAAA==.',['希尔']='希尔瓦叶斯:BAAAKgAECggIEgAAAA==.',['希格']='希格露恩:BAAAKgAFFAMIAwAAAA==.',['带走']='带走你的恶魔:BAAAKgADCgMIBAAAAA==.',['平衡']='平衡牧:BAABKgAFFH8IAAINAAgIQRdvBwCYAQANAAgIQRdvBwCYAQAAAA==.',['幸福']='幸福不遥远:BAAAKgAECgcIAQAAAA==.',['开始']='开始射:BAABKgAFFH8MAAMUAAYIKxmgDgCKAQAUAAYIKxmgDgCKAQASAAYI5gbRIADxAAAAAA==.',['异乡']='异乡人:BAAAKgADCggICAAAAA==.',['弱柳']='弱柳扶风:BAAAKgAECgQIBAAAAA==.',['强强']='强强战神:BAABKgAECn8eAAMaAAgIEx5GFAAUAgAaAAcIIB1GFAAUAgAMAAMIJxygbgCgAAAAAA==.',['归心']='归心:BAAAKgADCgcIBwAAAA==.',['征服']='征服王的掠夺:BAABKgAFFH8MAAMOAAQIcyPIGwA8AQAOAAQIcyPIGwA8AQANAAIIrAY0MQBTAAAAAA==.',['得得']='得得:BAAAKgADCggICAAAAA==.',['得闲']='得闲饮茶:BAAAKgADCgcIBwAAAA==.',['快乐']='快乐抠脚男:BAAAKgAFFAIIAgAAAA==.',['念念']='念念的毁灭:BAAAKgADCggICAAAAA==.念念的萨满:BAAAKgADCggICAAAAA==.念念的颜值:BAABKgAFFH8GAAIGAAYI9BF3DQBqAQAGAAYI9BF3DQBqAQAAAA==.',['怪物']='怪物史瑞克:BAAAKgADCgMIAwAAAA==.',['恶魔']='恶魔心:BAABKgAFFH8GAAIYAAYI5AL0IQD3AAAYAAYI5AL0IQD3AAAAAA==.恶魔灬绮罗生:BAAAKgAECgQIBAAAAA==.恶魔的祝福:BAAAKgAECgQIBAAAAA==.',['情义']='情义灬墓尸:BAAAKgAECgEIAQAAAA==.情义灬复仇:BAABKgAFFH8GAAIcAAMIfw1vCwCbAAAcAAMIfw1vCwCbAAAAAA==.情义灬小得:BAABKgAFFH8IAAMOAAMINxBJPAC1AAAOAAMINxBJPAC1AAANAAMIuA+kDwCbAAAAAA==.情义灬法爷:BAAAKgADCgEIAQAAAA==.情义灬猎爹:BAABKgAFFH8EAAMSAAIIwAo9UAA9AAASAAEIJxU9UAA9AAAUAAEIWQA9ZgAPAAAAAA==.',['惩戒']='惩戒之刃:BAAAKgAECggIEAABKgAFFAQIFAAMAFcjAA==.',['愤怒']='愤怒的鲨鱼:BAAAKgAECgUICQAAAA==.',['憨憨']='憨憨的圣骑:BAABKgAFFH8GAAIRAAYIyyA9FQCxAQARAAYIyyA9FQCxAQAAAA==.',['我宝']='我宝宝叫凋零:BAACKgAFFH8MAAMUAAgIQRUXCAD4AQAUAAgIQRUXCAD4AQASAAQIVQgmFQC4AAAqAAQKfxQAAxQACAhbGYc3AMcBABQACAj8FYc3AMcBABIAAwgBFRBuAKwAAAAA.',['我爸']='我爸刚弄死他:BAABKgAECn8bAAIgAAgIQxXkHAC3AQAgAAgIQxXkHAC3AQAAAA==.',['我的']='我的小奶宝:BAABKgAFFH8LAAIKAAcIWQfjDQBhAQAKAAcIWQfjDQBhAQAAAA==.',['我真']='我真没演:BAABKgAFFH8NAAMGAAgIIB97AwCBAgAGAAgIHR17AwCBAgAfAAUIPRqkCgCMAQAAAA==.我真的太难了:BAABKgAFFH8FAAIYAAUI8RftHQCjAAAYAAUI8RftHQCjAAAAAA==.',['战吊']='战吊爱冲锋:BAABKgAFFH8GAAIMAAMI/RRNIADSAAAMAAMI/RRNIADSAAAAAA==.',['打是']='打是亲骂是爱:BAAAKgAECgYIBgAAAA==.',['扔白']='扔白的雪子:BAACKgAFFH8ZAAIIAAQI0x8FFgDNAAAIAAQI0x8FFgDNAAAqAAQKfywAAggACAjcIz4KAKMCAAgACAjcIz4KAKMCAAAA.',['把子']='把子肉套餐:BAAAKgADCgMIAwAAAA==.',['抑制']='抑制欲望:BAABKgAFFH8IAAIEAAgIyQX2DwAmAQAEAAgIyQX2DwAmAQAAAA==.',['持剑']='持剑难诉离殇:BAABKgAECn8iAAMZAAgIGBubCAA0AgAZAAgIGBubCAA0AgAFAAYI+wq7bQDTAAABKgAFFAMICQARAC0bAA==.',['捏起']='捏起來肉肉哒:BAACKgAFFH8RAAMhAAgIShzqAwDEAQAhAAYI2SDqAwDEAQAQAAgIPRTwBAC9AQAqAAQKfx0AAyEACAhVJsIBAN4CACEACAhVJsIBAN4CABEABQhNID6PAHgBAAAA.捏起来肉肉哒:BAACKgAFFH9YAAMVAAgI7CL2AAACAgAVAAgI7CL2AAACAgAiAAMITRJ7BQDAAAAqAAQKfycAAxUACAgMJAMKAJ8CABUACAgMJAMKAJ8CACIAAQgIE8IiADUAAAAA.',['搂的']='搂的瓦:BAAAKgAECgQIBAAAAA==.',['摸头']='摸头点赞拒战:BAABKgAFFH8RAAMKAAMIPxelFgDNAAAKAAMIPBKlFgDNAAALAAEIRB1fDwBWAAAAAA==.',['放肆']='放肆的溫柔:BAABKgAFFH8MAAQLAAQIySL5AwARAQALAAMIySL5AwARAQAKAAQI7xpwEQDgAAAjAAEIAAAYIgAAAAAAAA==.',['教父']='教父:BAABKgAFFH8IAAMYAAQIrQx0GgDbAAAYAAQIrQx0GgDbAAAcAAQIyAIXEQB6AAAAAA==.',['新疆']='新疆:BAAAKgAECgIIAgAAAA==.',['无人']='无人角色的:BAAAKgAECgcIDwAAAA==.',['无幽']='无幽:BAAAKgAECgUIBQAAAA==.',['时光']='时光掠影:BAAAKgADCgEIAQAAAA==.',['星奈']='星奈:BAAAKgAECggICAABKgAFFAgIBQALAI8dAA==.',['星界']='星界夜鹰:BAAAKgAECggIEAAAAA==.',['星虹']='星虹:BAABKgAFFH8IAAMbAAQIEgnuEQBtAAAaAAQIJwjzIQCDAAAbAAQIBwXuEQBtAAAAAA==.',['是满']='是满满呀:BAACKgAFFH80AAMCAAgIHxHYBAD9AQACAAgIHxHYBAD9AQADAAEIAAALRQAAAAAqAAQKfyMAAwIACAjdG+YnAJcBAAIABQhJG+YnAJcBAAMACAhmDrIgAMoAAAAA.',['晓炎']='晓炎:BAABKgAFFH8WAAIIAAgIOhjjAwArAgAIAAgIOhjjAwArAgAAAA==.',['晓猞']='晓猞猁:BAABKgAFFH8KAAIOAAQI8xzNDQAGAQAOAAQI8xzNDQAGAQAAAA==.',['晓表']='晓表弟:BAAAKgAECggIDQAAAA==.',['晴天']='晴天小小马:BAAAKgAECgcIDAAAAA==.',['晴風']='晴風:BAABKgAFFH8IAAMiAAgItBJaAwAeAQAiAAYITBRaAwAeAQAVAAIIpQEGGgCtAAAAAA==.',['智喜']='智喜:BAAAKgADCgMIAwAAAA==.',['暖阳']='暖阳轻抚柳面:BAAAKgADCgEIAQAAAA==.',['暴力']='暴力的宝丽:BAAAKgADCgEIAQAAAA==.',['暴走']='暴走狐狸:BAAAKgAECgcIDQAAAA==.',['曰仙']='曰仙:BAAAKgADCgMIAwAAAA==.',['更木']='更木劍八:BAABKgAFFH8GAAIEAAYIvRs8CQCCAQAEAAYIvRs8CQCCAQAAAA==.',['最后']='最后的堡垒:BAAAKgADCgQIBAAAAA==.',['月虹']='月虹:BAABKgAFFH8OAAMUAAgIGBHJCgDBAQAUAAgIBA3JCgDBAQASAAYIUxLJFQA1AQAAAA==.',['有点']='有点脾气:BAAAKgAFFAIIAgAAAA==.',['望秋']='望秋云:BAAAKgADCggICAAAAA==.',['木小']='木小沫:BAABKgAFFH8RAAIRAAMIfg/TKwC3AAARAAMIfg/TKwC3AAAAAA==.',['未来']='未来小伙:BAAAKgAECggIDgAAAA==.',['朴彩']='朴彩英:BAABKgAFFH8WAAIRAAgI+RqbCwAPAgARAAgI+RqbCwAPAgAAAA==.',['机智']='机智的小满满:BAAAKgAECgcIBwABKgAFFAgINAACAB8RAA==.',['权倾']='权倾一世:BAABKgAFFH8GAAIRAAYIfRvLHACAAQARAAYIfRvLHACAAQAAAA==.',['杜皮']='杜皮和帝皮:BAABKgAFFH8PAAIEAAMIrQGZEgBPAAAEAAMIrQGZEgBPAAAAAA==.',['来口']='来口芥末么:BAACKgAFFH8JAAIKAAgIJxZnBwAbAgAKAAgIJxZnBwAbAgAqAAQKf0EAAgoACAgQHtsMAE0CAAoACAgQHtsMAE0CAAAA.',['来碗']='来碗豆汁:BAAAKgAFFAIIAgAAAA==.',['极饿']='极饿生灵:BAABKgAFFH8TAAICAAcIXhhPBACGAQACAAcIXhhPBACGAQAAAA==.',['枯荷']='枯荷听夜雨:BAAAKgAFFAQIBAAAAA==.',['柠檬']='柠檬冰茶:BAAAKgAECgIIAgAAAA==.',['格式']='格式化灬灵魂:BAAAKgAECgcIBwAAAA==.',['梦坤']='梦坤:BAAAKgAFFAMIAwAAAA==.',['梦境']='梦境缠绕阿:BAAAKgAFFAQIBAABKgAFFAgIBgAYAOsJAA==.',['梦游']='梦游师:BAABKgAECn8WAAMUAAcIbR6SQQDyAQAUAAcIbR6SQQDyAQASAAUINBHOUwDOAAAAAA==.',['梦逐']='梦逐芭蕉雨丶:BAAAKgAECggICQAAAA==.',['梦魇']='梦魇破晓:BAACKgAFFH9ZAAMgAAgI9iX8AADXAgAgAAgI9iX8AADXAgAiAAQIgx/wAgDYAAAqAAQKfzEAAyIACAjpJDoFAE8CACIACAgYIjoFAE8CACAABQi/JW4bAAMCAAAA.',['棍子']='棍子掉一地:BAAAKgAECgQIBAAAAA==.',['森罗']='森罗万象:BAAAKgAECgEIAQAAAA==.',['欧皇']='欧皇灬小王子:BAAAKgAECgEIAQAAAA==.',['止殇']='止殇之狂:BAAAKgAECgUICAAAAA==.',['正经']='正经圣光:BAABKgAFFH8IAAIRAAgIeQkiNwAOAQARAAgIeQkiNwAOAQAAAA==.',['此生']='此生不渝:BAAAKgADCgUIBQAAAA==.',['歩倒']='歩倒防騎:BAAAKgAECgYIBwAAAA==.',['歪比']='歪比巴波灬:BAAAKgAECgQIBAAAAA==.',['死也']='死也无敌:BAAAKgADCgEIAQAAAA==.',['毛不']='毛不到伤害了:BAAAKgAFFAEIAQAAAA==.',['毛毛']='毛毛熊:BAAAKgAECgMIAwAAAA==.',['永恒']='永恒飞鸟:BAAAKgAECggIDgAAAA==.',['汤汤']='汤汤:BAABKgAFFH8FAAIIAAUIoQjAGAAeAQAIAAUIoQjAGAAeAQAAAA==.',['汤湯']='汤湯:BAAAKgADCgcIBwAAAA==.',['沉沦']='沉沦兎子:BAAAKgAECgQIBAAAAA==.沉沦小米:BAAAKgADCgEIAQAAAA==.',['沐雪']='沐雪微寒:BAACKgAFFH9OAAIYAAgI6x74BQBRAgAYAAgI6x74BQBRAgAqAAQKfzUAAhgACAiuI5ATAJECABgACAiuI5ATAJECAAAA.',['沙白']='沙白填:BAABKgAECn8XAAIDAAgIdh5hFgAgAgADAAgIdh5hFgAgAgAAAA==.',['没头']='没头脑:BAAAKgAFFAEIAQAAAA==.',['没想']='没想到吧:BAABKgAFFH8QAAIVAAgIehttAwBEAgAVAAgIehttAwBEAgAAAA==.',['治愈']='治愈系芒果丶:BAACKgAFFH8lAAMSAAgIpCQzAAABAgASAAgIfSQzAAABAgAUAAQIYyKFEAALAQAqAAQKfy4AAxIACAgbJhMEAOwCABIACAgbJhMEAOwCABQACAjfIxI4ABUCAAAA.',['泡面']='泡面丶:BAAAKgAFFAIIAgAAAA==.',['波波']='波波丶奈奈酱:BAAAKgAECgMIAwAAAA==.',['洛丹']='洛丹伦的太阳:BAABKgAFFH8aAAIPAAYI2CKMAgCdAQAPAAYI2CKMAgCdAQAAAA==.',['流年']='流年花事了:BAAAKgADCgEIAQAAAA==.',['浦西']='浦西马:BAAAKgAECgUIBgAAAA==.',['浪漫']='浪漫小蛮妖:BAAAKgADCgEIAQAAAA==.',['海棠']='海棠未雨:BAAAKgAECggIBgAAAA==.',['海绵']='海绵瓜瓜:BAACKgAFFH8gAAICAAYIZh3yCAB4AQACAAYIZh3yCAB4AQAqAAQKfx4AAgIACAi9ImkKAJ0CAAIACAi9ImkKAJ0CAAAA.',['海边']='海边微风起:BAAAKgADCgcIBwAAAA==.',['涅法']='涅法蕾姆:BAABKgAFFH8FAAIIAAUIgg3xEQBFAQAIAAUIgg3xEQBFAQAAAA==.',['涛爷']='涛爷:BAAAKgADCgUIBQAAAA==.',['清风']='清风拂过:BAACKgAFFH8HAAIUAAQIliOxGwAkAQAUAAQIliOxGwAkAQAqAAQKfxkAAxQACAjtH3o1AM8BABQABwgeIno1AM8BABIACAgcF4kvAKIBAAAA.',['漂亮']='漂亮的回旋踢:BAABKgAFFH8JAAIVAAMItAf2JQCLAAAVAAMItAf2JQCLAAAAAA==.',['潇澜']='潇澜:BAABKgAFFH8NAAIYAAQIoxN0KwDLAAAYAAQIoxN0KwDLAAAAAA==.',['澜潇']='澜潇:BAAAKgAECgcIBAAAAA==.',['灬惩']='灬惩戒骑灬:BAABKgAFFH8PAAIRAAMIzyBLHQD6AAARAAMIzyBLHQD6AAAAAA==.',['灬莫']='灬莫奈灬:BAAAKgADCgEIAQAAAA==.',['灬貦']='灬貦童灬:BAAAKgADCgIIAgAAAA==.',['灬达']='灬达芬奇灬:BAAAKgADCggICAAAAA==.',['灰太']='灰太狼的春天:BAAAKgAFFAIIAgAAAA==.',['灰烬']='灰烬觉醒:BAABKgAFFH8GAAIRAAYIcyPUDQD2AQARAAYIcyPUDQD2AQAAAA==.',['炮舰']='炮舰丶会卖萌:BAAAKgADCgYIBgAAAA==.炮舰丶会耍帅:BAAAKgADCggICAAAAA==.',['炼狱']='炼狱久久:BAABKgAFFH8GAAIfAAMIyg1AGwDlAAAfAAMIyg1AGwDlAAAAAA==.',['烏鸦']='烏鸦:BAAAKgADCgMIAwAAAA==.',['烟云']='烟云缥缈:BAABKgAFFH8uAAMRAAgIxSMcAgDTAgARAAgIxSMcAgDTAgAQAAEIAAAHGAAAAAAAAA==.',['烨烨']='烨烨小烨:BAABKgAFFH8KAAIXAAgIeAOZDgAuAQAXAAgIeAOZDgAuAQAAAA==.',['煕媛']='煕媛:BAAAKgAFFAgIAgAAAA==.',['熊熊']='熊熊猫了丶:BAACKgAFFH8UAAMQAAYIyg+gCgDlAAAQAAYIywugCgDlAAARAAMIfxb7OgCTAAAqAAQKfxwAAhEACAgLI7oyAFgCABEACAgLI7oyAFgCAAAA.',['燃星']='燃星:BAAAKgAECggIDAAAAA==.',['牛多']='牛多重:BAACKgAFFH9AAAMSAAgIxiN7AADkAQASAAgIxiN7AADkAQAUAAMILh4pMQCXAAAqAAQKfzEAAxIACAghJU8PAF0CABQACAhqI6MbAIoCABIACAjmIk8PAF0CAAAA.',['牛大']='牛大锤:BAABKgAFFH8GAAIQAAYIbAyyEQDyAAAQAAYIbAyyEQDyAAAAAA==.',['牛晓']='牛晓熊:BAAAKgAFFAYIBAAAAA==.',['特麽']='特麽劈我瓜:BAABKgAFFH8LAAIIAAMIjh89HwD+AAAIAAMIjh89HwD+AAAAAA==.',['狂人']='狂人麦迪:BAACKgAFFH8UAAIUAAQIpx45IwD8AAAUAAQIpx45IwD8AAAqAAQKfy8AAhQACAiQIUUkAGMCABQACAiQIUUkAGMCAAAA.',['狐人']='狐人总冠军:BAACKgAFFH8oAAIIAAgIhRAgBgDuAQAIAAgIhRAgBgDuAQAqAAQKfxgAAggACAhCGpM+AIwBAAgACAhCGpM+AIwBAAAA.',['独乐']='独乐纪:BAAAKgAFFAQIBAAAAA==.',['玄翊']='玄翊:BAAAKgAFFAcIAQABKgAFFAgIDAAKAMocAA==.',['王不']='王不留行:BAACKgAFFH8NAAMEAAYItBuoAgB6AQAEAAUIOR2oAgB6AQAFAAYI0xKbFwBgAQAqAAQKfxUAAgUACAjPFzk/ALQBAAUACAjPFzk/ALQBAAAA.',['王子']='王子必须死:BAAAKgADCgcICwAAAA==.',['王小']='王小熊:BAABKgAFFH8GAAIKAAYILRc3EACOAQAKAAYILRc3EACOAQAAAA==.',['王德']='王德发:BAABKgAFFH8GAAIaAAYIOxgSBgC+AQAaAAYIOxgSBgC+AQAAAA==.',['玖块']='玖块肆毛壹:BAAAKgAECggICAAAAA==.',['玛索']='玛索索:BAAAKgADCgYIBgAAAA==.',['玛薇']='玛薇卡:BAAAKgAECgYIBgAAAA==.',['珠宝']='珠宝买买麦:BAAAKgAECggIEwAAAA==.',['琥珀']='琥珀翡翠:BAAAKgADCgYIBgAAAA==.',['瑞兹']='瑞兹:BAAAKgAECggICwAAAA==.',['瑞驰']='瑞驰:BAABKgAFFH8UAAIEAAYIZx6uAADnAQAEAAYIZx6uAADnAQABKgAFFAgIGgAFAEwhAA==.',['瑶虹']='瑶虹:BAABKgAFFH8LAAMGAAYIcxigEQBaAQAGAAYIcxigEQBaAQAHAAEIAADjMAAAAAAAAA==.',['生死']='生死看淡:BAAAKgAECgUIBQAAAA==.',['由加']='由加莉:BAABKgAFFH8FAAIRAAMIJR4WLQC7AAARAAMIJR4WLQC7AAAAAA==.',['画甲']='画甲:BAABKgAFFH8JAAIIAAQILhVlDgDsAAAIAAQILhVlDgDsAAAAAA==.',['痞帅']='痞帅:BAABKgAFFH8IAAIRAAQIFB23GQD3AAARAAQIFB23GQD3AAAAAA==.',['白丶']='白丶巧克力:BAABKgAECn8UAAIDAAcIBBaYSwAKAQADAAcIBBaYSwAKAQAAAA==.',['白沙']='白沙和天下:BAAAKgAECggIEAAAAA==.',['白河']='白河凶鸟:BAAAKgAFFAQIBAAAAA==.',['皇城']='皇城宝少:BAAAKgAECgcICQAAAA==.皇城少龙:BAAAKgAECgYIDgAAAA==.皇城月光:BAAAKgAECgEIAQAAAA==.皇城龙少:BAAAKgAECgUICQAAAA==.',['皓儿']='皓儿丨利爪:BAAAKgADCgEIAQAAAA==.',['皮叽']='皮叽兔:BAACKgAFFH9IAAMDAAgIgCWoAADGAgADAAgIBCSoAADGAgABAAgIRCAwAQCcAgAqAAQKfywAAwEACAhrJNkEAMYCAAEACAhrJNkEAMYCAAMAAQgDCxuYACoAAAAA.皮叽叽:BAABKgAFFH8ZAAIIAAgI0iIEAQC4AgAIAAgI0iIEAQC4AgABKgAFFAgISAADAIAlAA==.',['皮皮']='皮皮喵丶:BAAAKgADCgIIAgAAAA==.皮皮骑大鸟:BAAAKgADCgYIDAAAAA==.',['看你']='看你菊花:BAAAKgAECgQIBAAAAA==.',['真言']='真言术盾:BAABKgAFFH8HAAMBAAYIagf8AwBaAQABAAYIagf8AwBaAQACAAEIAAAgNQAAAAAAAA==.',['眼镜']='眼镜琤琤亮:BAABKgAECn8aAAIFAAgIDBmDCAAUAgAFAAgIDBmDCAAUAgAAAA==.',['睿翊']='睿翊:BAAAKgAFFAYIBAAAAA==.',['瞎熊']='瞎熊寶:BAAAKgAFFAgIAgAAAA==.',['破晓']='破晓之矢:BAAAKgAECggIDgAAAA==.',['破碎']='破碎的光明:BAAAKgAECggICAAAAA==.',['碎星']='碎星:BAABKgAFFH8jAAQOAAgIhB4MCQAIAgAOAAgI1xsMCQAIAgAkAAMIchiHAwALAQANAAQIuAb3KACBAAAAAA==.',['神之']='神之一手:BAAAKgAECgYIDAAAAA==.',['神龙']='神龙叶子:BAAAKgADCgYIBgAAAA==.神龙大侠阿宝:BAABKgAFFH8JAAMgAAQIBgXmEACqAAAgAAQIBgXmEACqAAAVAAQIlwvZLAA6AAAAAA==.',['秋泠']='秋泠:BAAAKgAFFAQIBAAAAA==.',['秦妈']='秦妈妈:BAABKgAFFH8UAAMJAAgIRhduBADPAQAJAAcIbhluBADPAQAIAAUIcQlmJADmAAAAAA==.',['秦媽']='秦媽媽:BAABKgAFFH8GAAIGAAYILho0CwCnAQAGAAYILho0CwCnAQAAAA==.',['究极']='究极无敌:BAAAKgAFFAQIBAAAAA==.',['立地']='立地成魔:BAAAKgADCgQIBQAAAA==.',['筱月']='筱月儿:BAABKgAFFH8OAAQDAAYIUxIiDgBHAQADAAYIUxIiDgBHAQABAAYIogoWDwAsAQACAAII9AG3JABLAAAAAA==.',['米斯']='米斯思:BAACKgAFFH80AAIdAAgIeyBQAgCAAgAdAAgIeyBQAgCAAgAqAAQKfyUAAh0ACAg8ItoMACQCAB0ACAg8ItoMACQCAAEqAAUUCAhDAAIAqSIA.',['糖尸']='糖尸三摆手:BAAAKgAECggIDAAAAA==.',['紫云']='紫云统夜:BAABKgAFFH8GAAIUAAQI5B39FgDzAAAUAAQI5B39FgDzAAAAAA==.',['紫色']='紫色豆豆:BAAAKgAFFAQIBAAAAA==.',['红发']='红发狂魔:BAAAKgAECgMIBAAAAA==.',['红莲']='红莲:BAABKgAFFH8JAAMPAAYIOhqDAQDEAQAPAAYIuhSDAQDEAQAeAAIIQhfACgCwAAAAAA==.',['给个']='给个机会丶:BAAAKgAFFAgIBAAAAA==.',['续不']='续不上龙喷了:BAABKgAFFH8IAAMFAAQIDRwtIwAKAQAFAAQIDRwtIwAKAQAZAAEI2A6rEQBAAAAAAA==.',['美味']='美味小脚:BAAAKgAECggIDAAAAA==.',['美拉']='美拉:BAAAKgADCgQIBAAAAA==.',['羽柔']='羽柔:BAAAKgAFFAQIBAAAAA==.',['翻滚']='翻滚吧兔宝宝:BAABKgAFFH8OAAIDAAMIqh6GDAADAQADAAMIqh6GDAADAQAAAA==.',['耳竖']='耳竖得像天线:BAAAKgAECgIIAgAAAA==.',['耳龙']='耳龙:BAACKgAFFH8nAAMXAAgIaCBiDQCMAQAXAAUIFB5iDQCMAQAWAAYIBR9UAgBVAQAqAAQKfx0AAxYACAj8GnIGACkCABYACAj8GnIGACkCABcAAgizIuZSAGUAAAAA.',['聊疗']='聊疗你的心:BAAAKgAECgUIBQAAAA==.',['聖光']='聖光無用:BAAAKgAECgMIAwAAAA==.',['肚皮']='肚皮君:BAABKgAFFH8OAAMaAAcISx2nAQCvAQAMAAcISx3UBQAXAgAaAAYIEhOnAQCvAQAAAA==.',['背刺']='背刺达人动视:BAABKgAFFH8GAAMSAAMI2xOaFADAAAASAAMI2xOaFADAAAAUAAEI0wZzYQAyAAAAAA==.',['胸小']='胸小还无脑:BAAAKgAECgUIBwAAAA==.',['自然']='自然英雄:BAAAKgAECgYIBgAAAA==.',['至高']='至高岭丶黑角:BAAAKgADCgQIBAAAAA==.',['艾维']='艾维娜丶晨歌:BAABKgAFFH8GAAIQAAYI7wTrFwC4AAAQAAYI7wTrFwC4AAAAAA==.',['芒果']='芒果呐丶:BAACKgAFFH8IAAIEAAQIOR3uCAAHAQAEAAQIOR3uCAAHAQAqAAQKfxgAAgUACAg+GaI6AMYBAAUACAg+GaI6AMYBAAAA.',['花甲']='花甲:BAABKgAECn8UAAMMAAgIThiZKQDkAQAMAAgIThiZKQDkAQAaAAEIlRUmZAA/AAAAAA==.',['苍明']='苍明天:BAABKgAFFH8GAAIQAAYINww4DwANAQAQAAYINww4DwANAQAAAA==.',['若蓠']='若蓠:BAABKgAFFH8GAAIfAAYIMBc0DAByAQAfAAYIMBc0DAByAQAAAA==.',['苿兰']='苿兰:BAAAKgADCgMIAwAAAA==.',['茉莉']='茉莉雨:BAABKgAFFH8UAAMNAAYIeRcWCQDvAAANAAQIPBkWCQDvAAAOAAQIyBURQQCoAAABKgAFFAgIJwAXAGggAA==.',['荳包']='荳包:BAAAKgAFFAQIBAAAAA==.',['莳丶']='莳丶緔:BAABKgAFFH8IAAIFAAcIjBfOCQDvAQAFAAcIjBfOCQDvAQAAAA==.',['莼青']='莼青色灬:BAAAKgAECgYIBgAAAA==.',['萌妹']='萌妹子潼潼:BAAAKgADCggICgAAAA==.',['萌面']='萌面大叔:BAAAKgAECgEIAQAAAA==.',['萧逸']='萧逸血雨:BAAAKgADCgYIBgAAAA==.',['蓝娆']='蓝娆:BAABKgAFFH8JAAIFAAQI7AmLOwCvAAAFAAQI7AmLOwCvAAAAAA==.',['蔷薇']='蔷薇九环:BAACKgAFFH84AAMVAAYIqhvlDwAvAQAVAAYIqhvlDwAvAQAgAAQIZwgjEQDaAAAqAAQKfyQABBUACAhMGbUhAOIBABUACAhMGbUhAOIBACIAAwiCD6MdAIMAACAAAQiqBm9oACoAAAAA.',['薄脆']='薄脆:BAAAKgAECgIIAwAAAA==.',['薄透']='薄透漏:BAABKgAFFH8WAAIPAAgIwhl5BABXAgAPAAgIwhl5BABXAgAAAA==.',['薯条']='薯条大人:BAABKgAFFH8lAAQSAAgIHSFKBABDAgASAAgIHSFKBABDAgAUAAcIZBkWCAD4AQATAAEINBsABABVAAAAAA==.',['藍聖']='藍聖:BAAAKgAECgcICQAAAA==.',['藕藕']='藕藕总:BAAAKgAFFAQIBAAAAA==.',['藤宫']='藤宫兰:BAABKgAFFH8IAAIPAAgIoxVvBABYAgAPAAgIoxVvBABYAgAAAA==.',['蛊毒']='蛊毒修罗:BAAAKgAECggIEgAAAA==.',['血中']='血中悍刀行:BAABKgAFFH8LAAIMAAMIZh3mGgDqAAAMAAMIZh3mGgDqAAAAAA==.',['血雨']='血雨爱丽丝:BAAAKgAECgEIAQAAAA==.',['行苇']='行苇筏喻:BAAAKgAFFAEIAgAAAA==.',['西红']='西红柿炖牛腩:BAABKgAFFH8HAAIKAAYIJBH+FwBEAQAKAAYIJBH+FwBEAQAAAA==.',['观心']='观心知天下:BAAAKgAECgIIAgAAAA==.',['讨厌']='讨厌:BAAAKgADCgMIBAAAAA==.',['说谎']='说谎丶给你听:BAABKgAFFH8KAAIKAAgIVBvNBABTAgAKAAgIVBvNBABTAgAAAA==.',['请耐']='请耐心等待:BAAAKgADCgEIAQABKgAFFAYICgAjADgcAA==.',['谁人']='谁人不识君:BAAAKgADCgEIAQAAAA==.',['豪豬']='豪豬吉列姆:BAACKgAFFH9EAAQKAAgI+CanAAAAAwAKAAgIbianAAAAAwAjAAgIWx0QAQAOAgALAAUI+SYpAQDIAQAqAAQKfxgABCMABQjQJn8nAFQBACMABAjGJn8nAFQBAAoAAwjAJjwzAEIBAAsAAgh1Jm8iAOAAAAAA.',['貂缠']='貂缠在腰上:BAAAKgAECgMIAwAAAA==.',['贝簏']='贝簏丹尼:BAAAKgAECgYICAAAAA==.',['贝露']='贝露丹蒂:BAAAKgAFFAIIAgAAAA==.',['赤炎']='赤炎马:BAACKgAFFH84AAQPAAgIViA3AgCvAgAPAAgIViA3AgCvAgAeAAIIAQsQDgCEAAAlAAEIQA99CwBBAAAqAAQKfzIAAx4ACAj1IvkOAPoBAB4ACAi4GPkOAPoBAA8ABQhhJF8XANQBAAAA.',['赤焰']='赤焰馬:BAABKgAFFH8QAAIXAAgI5RlPBwAVAgAXAAgI5RlPBwAVAgAAAA==.',['路南']='路南十叁:BAAAKgAECgcICAAAAA==.',['路易']='路易斯丶圣光:BAACKgAFFH8dAAIRAAYIjyQnEADfAQARAAYIjyQnEADfAQAqAAQKfyIAAhEACAjqI4gaAK4CABEACAjqI4gaAK4CAAAA.路易斯丶鲜血:BAAAKgAECggICAAAAA==.',['蹄子']='蹄子:BAAAKgADCgEIAQAAAA==.',['转一']='转一下别毛了:BAAAKgAFFAcIAwAAAA==.',['这里']='这里的黎明:BAAAKgADCgIIAgAAAA==.',['遗忘']='遗忘的泪:BAAAKgAFFAYIAgABKgAFFAgIDAAQAPwdAA==.遗忘血腥:BAABKgAFFH8OAAMDAAYIIReWCADxAAADAAYIIReWCADxAAABAAMIoANoJgCCAAABKgAFFAgICAAIAO0XAA==.',['那个']='那个谁哪个誰:BAAAKgADCgEIAQAAAA==.',['邦桑']='邦桑笛:BAAAKgAECgIIAgAAAA==.',['都行']='都行丶:BAAAKgAFFAQIBAAAAA==.',['里芙']='里芙:BAABKgAFFH8QAAMKAAYIaxoqBAB2AQAKAAYIaxoqBAB2AQALAAIIeBMIGAB/AAAAAA==.',['铁臀']='铁臀霹雳火:BAAAKgAFFAYIAgAAAA==.',['银色']='银色天空:BAABKgAECn8XAAIcAAgI0xC5JABaAQAcAAgI0xC5JABaAQAAAA==.',['锵锵']='锵锵睬:BAABKgAFFH8GAAIKAAYIriHZDwCSAQAKAAYIriHZDwCSAQAAAA==.',['长岛']='长岛冰茶灬:BAABKgAFFH8IAAIRAAgI1RA2DQD8AQARAAgI1RA2DQD8AQAAAA==.',['闷骚']='闷骚的花生:BAAAKgAECgYICAAAAA==.',['阿富']='阿富汗酋长:BAAAKgADCgQIBAAAAA==.',['阿弥']='阿弥道尔:BAAAKgAECgIIAgAAAA==.',['阿芒']='阿芒芒:BAAAKgADCgQIBAAAAA==.',['陌上']='陌上花开:BAAAKgAECgUICAAAAA==.',['陳皮']='陳皮话梅糖:BAAAKgAECgMIAwAAAA==.',['随灬']='随灬风:BAAAKgADCggICAAAAA==.',['隔壁']='隔壁村老王:BAAAKgAECggIEwAAAA==.',['雨纷']='雨纷纷:BAACKgAFFH8QAAQEAAYIkx7UAADZAQAEAAYI9BzUAADZAQAZAAYIdxTxAwBfAQAFAAQIuBvvLQDXAAAqAAQKfxkAAxkACAjOInwIADICABkACAg3InwIADICAAUACAi4HS0nAB0CAAEqAAUUCAgJAAUAKBkA.',['雪悦']='雪悦:BAABKgAECn8uAAIUAAgILRxbDgAxAgAUAAgILRxbDgAxAgAAAA==.',['零点']='零点一卡路里:BAABKgAFFH8QAAINAAcIcBiABQDJAQANAAcIcBiABQDJAQAAAA==.',['霜之']='霜之盼盼:BAAAKgADCgEIAQAAAA==.',['青涩']='青涩麻酱:BAAAKgAECgUICgAAAA==.',['青青']='青青河边:BAAAKgADCgYIBgAAAA==.',['非丶']='非丶洲丶啵:BAAAKgAECgEIAQAAAA==.',['风之']='风之弈天冰:BAAAKgAFFAQIBAAAAA==.风之弈烈冰:BAAAKgAFFAQIBAAAAA==.风之弈羽冰:BAABKgAFFH8GAAIHAAYIhgYICgDZAAAHAAYIhgYICgDZAAAAAA==.风之弈翊冰:BAABKgAFFH8KAAIOAAYIQA3dGgBDAQAOAAYIQA3dGgBDAQAAAA==.风之弈魔冰:BAABKgAFFH8NAAMLAAgIThVfBQAvAQAKAAgIQA0WDADLAQALAAUIpRZfBQAvAQAAAA==.风之悲伤:BAABKgAFFH8IAAMOAAQIWyLuHQAuAQAOAAQIWyLuHQAuAQANAAQIDhExIACqAAAAAA==.',['风吹']='风吹烟花:BAAAKgADCggICAAAAA==.风吹裆鸟飞扬:BAAAKgADCgUIBQAAAA==.',['风暴']='风暴无尽:BAACKgAFFH8HAAIIAAMI+hsnFADVAAAIAAMI+hsnFADVAAAqAAQKfxgAAwgACAhFIE4OAHsCAAgACAhFIE4OAHsCAAkAAQhME5xzADsAAAAA.',['风飒']='风飒飒木萧萧:BAAAKgAECgQIBQAAAA==.',['飒踏']='飒踏如流星:BAAAKgAECgYIBwAAAA==.',['饺子']='饺子就酒:BAAAKgAECgYIBgABKgAFFAMICQARAC0bAA==.',['香勿']='香勿银:BAABKgAFFH8GAAMUAAMIfRaTFgDaAAAUAAMIfRaTFgDaAAASAAEIwwgbKQA1AAAAAA==.',['马可']='马可波罗:BAABKgAFFH8cAAIRAAcIbxpUEwDBAQARAAcIbxpUEwDBAQAAAA==.',['高攀']='高攀不起的牛:BAAAKgAECgYIBgAAAA==.',['髭男']='髭男:BAACKgAFFH8cAAQjAAYIyx9zBgDOAAAKAAMImibRFQBVAQALAAMIdyajCgDXAAAjAAUI8glzBgDOAAAqAAQKfyIABAoACAhXJpEpANEBAAoABgg9JpEpANEBAAsABAhQJk8YAC4BACMABAi3IsU0ABIBAAEqAAUUCAhEAAoA+CYA.',['鱼鱼']='鱼鱼不喝水:BAAAKgAECgMIBQAAAA==.',['鲁丶']='鲁丶西西:BAAAKgAECgQIBgAAAA==.',['鸡少']='鸡少:BAAAKgADCgEIAQAAAA==.',['黑暗']='黑暗丶开始:BAAAKgAECgIIAgAAAA==.',['黑檀']='黑檀木白:BAAAKgAECgYIBgAAAA==.',['黑铁']='黑铁大叔:BAABKgAFFH8GAAISAAQIRQQxHwB2AAASAAQIRQQxHwB2AAAAAA==.',['默默']='默默杺菲:BAAAKgAFFAMIAwAAAA==.',['龙琬']='龙琬重酿:BAABKgAECn8ZAAIVAAgI5BtUFADvAQAVAAgI5BtUFADvAQAAAA==.',['龙痰']='龙痰泡面:BAAAKgAFFAMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end