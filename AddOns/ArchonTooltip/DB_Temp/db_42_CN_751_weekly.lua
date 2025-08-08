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
 local lookup = {'DeathKnight-Blood','Warrior-Arms','Warrior-Fury','DeathKnight-Unholy','Mage-Frost','Priest-Holy','Priest-Shadow','Priest-Discipline','DeathKnight-Frost','DemonHunter-Havoc','DemonHunter-Vengeance','Mage-Fire','Druid-Balance','Druid-Restoration','Paladin-Retribution','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Holy','Monk-Windwalker','Shaman-Restoration','Shaman-Elemental','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Mage-Arcane','Shaman-Enhancement','Rogue-Assassination','Monk-Mistweaver','Druid-Feral','Druid-Guardian','Monk-Brewmaster','Hunter-Survival','Warrior-Protection','Paladin-Protection','Evoker-Devastation','Rogue-Subtlety','Evoker-Augmentation','Monk-Any',}; local provider = {region='CN',realm='燃烧军团',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Acdk:BAAAKgAFFAgIBAAAAA==.Achenghms:BAAAKgAECgEIAQAAAA==.Aciy:BAABKgAFFH8GAAIBAAYIthZkDQBAAQABAAYIthZkDQBAAQAAAA==.',Al='Alyx:BAAAKgAECgIIAgAAAA==.',Am='Amorli:BAAAKgAFFAYIBAAAAA==.',An='Andrés:BAAAKgADCgEIAQAAAA==.Ant:BAAAKgADCggICAAAAA==.',Ar='Ares:BAAAKgADCgYIBgAAAA==.Artoria:BAAAKgAFFAYIBAAAAA==.',Av='Avictor:BAAAKgAFFAIIAgABKgAFFAIIBgABAA4HAA==.',Az='Azs:BAAAKgAECgYIDAAAAA==.',Ba='Barti:BAAAKgAFFAYIAgAAAA==.',Bi='Bigpanda:BAAAKgAECggICAAAAA==.',Bl='Bloodydemon:BAAAKgADCgMIAwAAAA==.',Ce='Ceres:BAAAKgAFFAQIBAAAAA==.',Ch='Chono:BAAAKgADCgYIBgAAAA==.',Cl='Clabby:BAAAKgAFFAgIAQAAAA==.',Cy='Cynics:BAAAKgADCgcIBwAAAA==.',Da='Dandan:BAAAKgAFFAQIBAAAAA==.Darktemplar:BAAAKgAECgIIAgAAAA==.',De='Destruction:BAABKgAECn8ZAAMCAAgINB7PEAA0AgACAAgINB7PEAA0AgADAAYIFhdwLgB5AQAAAA==.',Dk='Dknight:BAAAKgAECggICAAAAA==.',Dv='Dvita:BAAAKgAECggICAABKgAFFAgIBgAEAB0dAA==.',Fa='Fankywork:BAAAKgAFFAIIBAAAAA==.',Fr='Freemike:BAABKgAECn8aAAIFAAYIFxeVMABCAQAFAAYIFxeVMABCAQAAAA==.',Ge='Gely:BAACKgAFFH8IAAMGAAMILQoQFwCHAAAGAAMILQoQFwCHAAAHAAEImAH3MwAgAAAqAAQKfyAABAYACAiNHFgHADECAAYACAiNHFgHADECAAcABgg8BAldAHsAAAgAAghsDIxuAFIAAAAA.',Gi='Gily:BAABKgAFFH8IAAMJAAQIjxb0BwDrAAAJAAQIjxb0BwDrAAABAAQIIAm7JgB8AAAAAA==.',Ha='Hang:BAAAKgADCggIDwAAAA==.',He='Hephaestus:BAAAKgADCgQIBAAAAA==.Hessian:BAAAKgAECggICAAAAA==.',Ji='Jinji:BAAAKgAECggICAAAAA==.',Jm='Jmy:BAACKgAFFH8TAAIKAAUIyyLABwA/AQAKAAUIyyLABwA/AQAqAAQKfxwAAgoABwgzI9IdAFECAAoABwgzI9IdAFECAAAA.',La='Lawbringer:BAAAKgAFFAQIBAAAAA==.',Lg='Lghiug:BAAAKgAFFAcIAwAAAA==.',Li='Lidstrom:BAAAKgAECggIEQAAAA==.Lilsmokerqs:BAAAKgAECgYICwAAAA==.',Mi='Mio:BAAAKgAECgYIDAAAAA==.',Mo='Moshoudh:BAABKgAFFH8ZAAMKAAQIYBrLIgDxAAAKAAQIRxrLIgDxAAALAAQI4A3uCgCgAAAAAA==.',Ne='Neoo:BAABKgAFFH8QAAIKAAgIEhv7BAByAgAKAAgIEhv7BAByAgAAAA==.',Ni='Ninalee:BAACKgAFFH8LAAIMAAYIExVtCwCAAQAMAAYIExVtCwCAAQAqAAQKfyEAAgwACAgZHf8fADMCAAwACAgZHf8fADMCAAAA.',Or='Origin:BAACKgAFFH8GAAINAAII/AuuUAB0AAANAAII/AuuUAB0AAAqAAQKfyMAAw0ACAhcHak3AMoBAA0ACAhcHak3AMoBAA4ABwi5FuYsAHQBAAAA.',Pl='Playerswiair:BAAAKgAECgEIAQAAAA==.',Qu='Quibblemankk:BAAAKgAFFAEIAQAAAA==.',Sa='Sadda:BAAAKgAFFAMIAwABKgAFFAYIEgAPABAcAA==.',Sd='Sdasdw:BAABKgAFFH8PAAIGAAQI2B54FQAJAQAGAAQI2B54FQAJAQAAAA==.',Su='Suannai:BAABKgAFFH8kAAMQAAgI6xcFBwD0AQAQAAgI6BcFBwD0AQARAAEI5gFuMQAwAAAAAA==.',To='Toster:BAACKgAFFH8GAAIBAAIIDgeCMABKAAABAAIIDgeCMABKAAAqAAQKfyEAAgEACAhmDWAtACYBAAEACAhmDWAtACYBAAAA.',Tu='Turandot:BAAAKgAECgYIBgAAAA==.',Va='Varedis:BAAAKgAECgcIBQAAAA==.',Wh='Whitegive:BAAAKgAECgUIBQAAAA==.',Wt='Wtkphc:BAAAKgAECgUIBQAAAA==.',Xd='Xd:BAABKgAFFH8GAAINAAYIiQ3MHAA1AQANAAYIiQ3MHAA1AQAAAA==.',Ya='Yaice:BAAAKgADCgIIAgAAAA==.',Yi='Yiangzhieng:BAAAKgAECgYICgAAAA==.',Ze='Zerokt:BAACKgAFFH8kAAISAAUI6gseCwD3AAASAAUI6gseCwD3AAAqAAQKf0YAAhIACAgWF7QUAMwBABIACAgWF7QUAMwBAAAA.',['一只']='一只考拉:BAAAKgADCgIIAgAAAA==.',['一大']='一大波骑士:BAABKgAECn8dAAMSAAgIyhKCIQBUAQASAAYI6RWCIQBUAQAPAAgI9QmMrAA+AQAAAA==.',['一定']='一定要娶伱:BAAAKgAECgEIAQAAAA==.',['一库']='一库:BAABKgAFFH8FAAITAAMItxvBEQDUAAATAAMItxvBEQDUAAAAAA==.',['一望']='一望无痕:BAABKgAECn8wAAMOAAgI6xpyFgDtAQAOAAgI6xpyFgDtAQANAAEIeAh/3AAoAAAAAA==.',['一杯']='一杯加冰美式:BAAAKgAECgcIEgAAAA==.',['一胖']='一胖咕咕一:BAABKgAFFH8KAAMNAAYIORicDwCmAQANAAYIORicDwCmAQAOAAQInAEJLgBhAAAAAA==.',['一起']='一起看日落吗:BAABKgAFFH8WAAQBAAcInx9dCQCAAQABAAQIZSJdCQCAAQAEAAMI7BvvJAD+AAAJAAEINw6hEQBBAAAAAA==.',['上古']='上古旱魃:BAABKgAECn8WAAMEAAgIJBkJLgD8AQAEAAgIJBkJLgD8AQABAAMIXw/5VABnAAAAAA==.',['下铺']='下铺的小弟:BAAAKgADCggICAAAAA==.',['不够']='不够狂野:BAAAKgAECgcICQABKgAFFAgIDgAUABUPAA==.不够自然:BAAAKgAECgYIBwAAAA==.',['两极']='两极反转:BAAAKgADCggICAAAAA==.',['两横']='两横一竖:BAABKgAFFH8VAAIPAAgIlCCVBQB2AgAPAAgIlCCVBQB2AgAAAA==.',['丨七']='丨七丨:BAAAKgADCgMIAwAAAA==.',['丨無']='丨無訫倾城丨:BAAAKgAFFAEIAQAAAA==.',['丨阿']='丨阿娜丨:BAABKgAFFH8IAAMFAAQIeRFyDADKAAAFAAQIeRFyDADKAAAMAAEIAADiQwAAAAAAAA==.',['中娅']='中娅沙漏:BAAAKgAECgcIBAABKgAFFAMIBQATALcbAA==.',['丶七']='丶七七丶:BAAAKgAECgUIBQAAAA==.',['丶丶']='丶丶七爷丶丶:BAAAKgAECgMIBQAAAA==.',['丶嘴']='丶嘴角的温度:BAACKgAFFH8jAAMUAAUIhRu4BAA4AQAUAAQIgyO4BAA4AQAVAAUIeAqKCwDVAAAqAAQKfzQAAxQACAh5IYEMAJMCABQACAh5IYEMAJMCABUABAjpE2VDAPoAAAAA.',['丶小']='丶小七:BAAAKgAECgcIBwAAAA==.',['丶弧']='丶弧线丿:BAAAKgAECgQIBAAAAA==.',['丶杨']='丶杨小骚:BAAAKgAECgUIBQAAAA==.',['丶魔']='丶魔法少女:BAACKgAFFH8ZAAQWAAgIxhozCAAkAQAWAAUI+BYzCAAkAQAXAAMI6R37BAAFAQAYAAIICBerEgBaAAAqAAQKfxgAAhYACAjFI1ELAJACABYACAjFI1ELAJACAAAA.',['丷千']='丷千鹤道长丷:BAAAKgAECggICAABKgAFFAgIBgAWAC4RAA==.',['丷水']='丷水库浪子丷:BAAAKgAECgYIBgAAAA==.',['丷血']='丷血凌丷:BAAAKgADCgIIAgAAAA==.',['丷随']='丷随风丷:BAACKgAFFH8oAAMZAAgIRBdEDgCCAQAZAAcIyBhEDgCCAQAMAAUINxp3DwBMAQAqAAQKfxwAAwwACAh1ISIHAHgCAAwACAjGHyIHAHgCABkABQjmIeAgAO4BAAAA.',['为了']='为了自由:BAABKgAFFH8WAAIBAAYImg/FCAAIAQABAAYImg/FCAAIAQAAAA==.',['为爱']='为爱情鼓掌:BAAAKgAECgMIAwAAAA==.',['丿啵']='丿啵璃唲唲灬:BAABKgAFFH8GAAIUAAYIogdpGAAgAQAUAAYIogdpGAAgAQAAAA==.',['乂灵']='乂灵翼乂:BAAAKgAECgYIBgAAAA==.',['九丨']='九丨天:BAAAKgADCggICAAAAA==.',['九乂']='九乂天:BAAAKgAECgQIBAAAAA==.',['乾元']='乾元:BAAAKgADCggICAAAAA==.',['云淡']='云淡风轻:BAAAKgAECggICAAAAA==.',['五连']='五连鞭:BAAAKgAECgcIEAAAAA==.',['亲人']='亲人两行泪乄:BAAAKgADCgEIAQAAAA==.',['人一']='人一叩:BAAAKgAECgYIBgAAAA==.',['人服']='人服德以:BAAAKgAECggIDwAAAA==.',['今夜']='今夜无人入睡:BAABKgAFFH8GAAIaAAYI+RDjCABLAQAaAAYI+RDjCABLAQAAAA==.',['伊利']='伊利呦酸乳:BAABKgAFFH8FAAILAAMI3AWIHABzAAALAAMI3AWIHABzAAAAAA==.伊利达雷斯:BAAAKgAECgEIAQAAAA==.',['伍六']='伍六七:BAAAKgAECgUIBQAAAA==.',['伍德']='伍德枫:BAAAKgAECgUIBQAAAA==.',['你並']='你並非永恆:BAACKgAFFH8nAAMUAAUI5xtECQANAQAUAAUI5xtECQANAQAVAAQIwgU/HgCHAAAqAAQKfyoAAhQACAisFJo2AKwBABQACAisFJo2AKwBAAAA.',['你好']='你好啊朋友:BAABKgAFFH8GAAIbAAYI+hOEDACFAQAbAAYI+hOEDACFAQAAAA==.',['倒斗']='倒斗小丸子:BAAAKgAFFAQIBAAAAA==.',['偷偷']='偷偷摸摸:BAAAKgAECgQIBAAAAA==.',['傾城']='傾城绝恋:BAAAKgAECggIDQAAAA==.',['全村']='全村的希望:BAAAKgAECgQIBAAAAA==.',['六十']='六十五不能退:BAAAKgAFFAgIBAAAAA==.',['六月']='六月飞花:BAABKgAFFH8QAAIcAAgIWQm8BwB9AQAcAAgIWQm8BwB9AQAAAA==.',['六道']='六道狂魔:BAAAKgADCggIDwAAAA==.',['军爷']='军爷:BAAAKgADCgEIAQAAAA==.',['冥姬']='冥姬:BAAAKgAECgIIAgAAAA==.',['冰镇']='冰镇麻辣烫:BAAAKgADCggICAAAAA==.',['冲锋']='冲锋即吾命:BAAAKgAFFAMIAwAAAA==.',['几许']='几许风雨:BAAAKgAECgUIDgAAAA==.',['凤舞']='凤舞水寒:BAAAKgADCggICAAAAA==.',['刀刀']='刀刀糖有毒:BAAAKgAFFAYIBAAAAA==.',['别抢']='别抢我鞋垫:BAAAKgAECgEIAgAAAA==.别抢我鞋带:BAAAKgAECgYIBgAAAA==.',['剑中']='剑中仙:BAAAKgADCgMIAwAAAA==.',['勾勾']='勾勾和丢丢:BAACKgAFFH8KAAIdAAIIQyU/AwDbAAAdAAIIQyU/AwDbAAAqAAQKfykAAx0ACAg3JbkAAAgDAB0ACAg3JbkAAAgDAB4AAQh/COFEABEAAAEqAAUUAwgOABEAtCEA.',['北京']='北京啤酒:BAABKgAFFH8NAAMBAAYIOBznBgAkAQAEAAYIwhmfEACXAQABAAYIrxTnBgAkAQAAAA==.',['北落']='北落师門:BAAAKgAFFAQIBAABKgAFFAgIDwAaAC4bAA==.',['十三']='十三大叔:BAAAKgAECgIIAwAAAA==.',['千年']='千年老僧:BAAAKgAECgYICwAAAA==.',['千树']='千树千寻:BAAAKgAECgcICAAAAA==.',['卌卌']='卌卌雪卝亓:BAAAKgAECgYIEAAAAA==.卌卌雪卝冰:BAABKgAFFH8PAAIGAAMI5wzSKwCVAAAGAAMI5wzSKwCVAAAAAA==.',['华夏']='华夏壹宝:BAAAKgAECggICAAAAA==.',['博只']='博只斤铁木真:BAAAKgAECgYICwAAAA==.',['卡个']='卡个熊:BAAAKgAECgQIBQAAAA==.',['即出']='即出战则必胜:BAAAKgAECgEIAgAAAA==.',['原宿']='原宿领主:BAAAKgAECgIIAgAAAA==.',['叁仟']='叁仟若水:BAAAKgAECgIIAgAAAA==.',['古德']='古德猫咛:BAAAKgAECgYIBgAAAA==.',['叶湘']='叶湘伦:BAABKgAFFH8HAAMWAAYIjR3BFwDDAAAWAAUIVhvBFwDDAAAXAAIIdh2bFQCQAAAAAA==.',['名起']='名起丧钟:BAACKgAFFH8nAAIBAAcIyRxtBAAMAgABAAcIyRxtBAAMAgAqAAQKfz8AAgEACAgoIr0GAI8CAAEACAgoIr0GAI8CAAAA.',['呆頭']='呆頭灰鸟:BAAAKgAFFAEIAgAAAA==.',['呦呦']='呦呦鹿鸣丶:BAABKgAFFH8MAAMNAAYIgA2FEQBMAQANAAYIgA2FEQBMAQAOAAYIwxAqDABEAQAAAA==.',['呼啦']='呼啦啦小樱桃:BAABKgAFFH8NAAMKAAQIAR/VCgAfAQAKAAQIAR/VCgAfAQALAAQIcA3hCgCtAAAAAA==.',['咔嚓']='咔嚓丨裂了:BAAAKgADCggICgAAAA==.',['咕咕']='咕咕乱叫:BAAAKgAECgcIDQAAAA==.',['咚巴']='咚巴拉:BAAAKgAECgUIBQAAAA==.',['哀伤']='哀伤魅影:BAAAKgAFFAEIAgAAAA==.',['哈撒']='哈撒给灬:BAACKgAFFH8OAAIPAAQIGxVyHADxAAAPAAQIGxVyHADxAAAqAAQKfzAAAg8ACAjaI6whAJMCAA8ACAjaI6whAJMCAAAA.',['唐一']='唐一:BAACKgAFFH8FAAMcAAMIyAxBLQBiAAAcAAIIggtBLQBiAAAfAAIIGgEHDAAvAAAqAAQKfxgAAhwACAjhGvUbAAsCABwACAjhGvUbAAsCAAEqAAUUAwgOABEAtCEA.',['唯你']='唯你懂我心:BAAAKgAECgcICwAAAA==.',['唯有']='唯有杜康丶:BAAAKgAECgYIDgAAAA==.',['商汤']='商汤苏妲己:BAAAKgADCgEIAQAAAA==.',['啊曦']='啊曦啊曦啊:BAACKgAFFH8LAAMTAAMIcxGlCwDgAAATAAMIcxGlCwDgAAAcAAIIbQVlMABTAAAqAAQKfxQAAhMACAgoGQ4cAP4BABMACAgoGQ4cAP4BAAAA.啊曦曦啊啊曦:BAAAKgAECgcICQAAAA==.',['喵小']='喵小乐:BAACKgAFFH8oAAMQAAgImhkdBQApAgAQAAcIQxkdBQApAgARAAQIIBp/FQD4AAAqAAQKfx8ABBEACAgrITM8AAcCABEACAhRHTM8AAcCABAABghPF4k9ADABACAAAwhzEwoRALMAAAAA.',['嗜血']='嗜血月神:BAAAKgADCggICAAAAA==.',['嘴角']='嘴角得温度:BAAAKgADCggIEAAAAA==.',['囚小']='囚小僧:BAAAKgADCgIIAgAAAA==.囚小法:BAAAKgADCggICQAAAA==.囚小牧:BAAAKgADCgMIAwAAAA==.囚小萨:BAAAKgADCgcIBwAAAA==.囚小龙:BAAAKgADCgEIAQAAAA==.',['回忆']='回忆我的青春:BAAAKgADCgEIAQAAAA==.',['圣光']='圣光天赐:BAAAKgADCggICAAAAA==.圣光照不到你:BAAAKgADCgYIBgAAAA==.',['圣德']='圣德:BAAAKgAECgUICgAAAA==.',['圣者']='圣者遗物:BAAAKgADCgQIBAAAAA==.',['坂本']='坂本真绫:BAAAKgAFFAIIBAAAAA==.',['坐拥']='坐拥五百亿:BAACKgAFFH8FAAIWAAUIJhBJIAAGAQAWAAUIJhBJIAAGAQAqAAQKfxUAAxgACAjzF1slAGEBABYABwj7E0tBAGUBABgABwiLFFslAGEBAAAA.坐拥六百亿:BAAAKgAECggICAAAAA==.',['坐飞']='坐飞机吃贡品:BAABKgAECn8XAAMhAAgIrgRXNwCIAAAhAAYI1ARXNwCIAAADAAUI4wGjiwBCAAAAAA==.',['堕入']='堕入深海:BAACKgAFFH89AAQIAAgIuiCVBQDhAQAIAAYIdh+VBQDhAQAGAAUIZxteCABiAQAHAAQI8hawEQD1AAAqAAQKf2AABAYACAg0JjcBAAADAAYACAgSJjcBAAADAAgACAhKJaoEAMgCAAcACAhPHXMVADACAAAA.',['塞尔']='塞尔菲:BAAAKgAECgEIAQABKgAFFAUIKAALALAHAA==.',['夏日']='夏日薇风:BAAAKgADCggICAAAAA==.',['夜歌']='夜歌:BAAAKgAECggICAAAAA==.',['夜穹']='夜穹殉至:BAAAKgAECgUIBgAAAA==.',['夜舞']='夜舞:BAAAKgADCggICAAAAA==.',['夜萌']='夜萌球:BAAAKgADCggICAAAAA==.',['大云']='大云来啦:BAABKgAECn8hAAIUAAgIfSBbEABrAgAUAAgIfSBbEABrAgAAAA==.',['大惊']='大惊小怪:BAAAKgADCgYIBgAAAA==.',['大色']='大色鸟:BAAAKgAECgIIAwAAAA==.',['大魔']='大魔王樱桃桃:BAABKgAFFH8QAAMPAAgImg7eDwDiAQAPAAgImg7eDwDiAQAiAAQIahB+HgCHAAAAAA==.',['大黄']='大黄鳝我们走:BAAAKgAECggICAAAAA==.',['天佑']='天佑残疾人:BAACKgAFFH8bAAQWAAYIRRMJEgDdAAAWAAUIvRcJEgDdAAAYAAQIuQluDwBpAAAXAAEIUwI7IQA7AAAqAAQKfxwAAxYACAiXHeISABECABYABghRIuISABECABgAAwjtCPZtAFEAAAAA.',['天堂']='天堂灬在左:BAACKgAFFH8SAAIPAAMI1B26JwDTAAAPAAMI1B26JwDTAAAqAAQKfywAAg8ACAglJNYRANACAA8ACAglJNYRANACAAAA.',['天天']='天天有有零:BAAAKgAECgUIBQAAAA==.',['天涯']='天涯梦断:BAABKgAFFH8GAAICAAYIIAj7DAA/AQACAAYIIAj7DAA/AQAAAA==.',['天苍']='天苍谋:BAACKgAFFH8pAAMNAAgIeBRMFAB4AQANAAcIKBZMFAB4AQAOAAYI1w3UDQDCAAAqAAQKfzsAAw0ACAhwI8oMAL8CAA0ACAhwI8oMAL8CAA4ACAgiHtUNAGACAAAA.',['天菩']='天菩萨:BAAAKgAECgYIBgAAAA==.',['天蚕']='天蚕丝雨:BAAAKgAFFAQIBAAAAA==.',['天逸']='天逸残剑:BAABKgAFFH8LAAIDAAQIQBf8HgDYAAADAAQIQBf8HgDYAAAAAA==.天逸雪姬:BAAAKgAFFAMIAwAAAA==.',['天际']='天际流:BAAAKgADCggICAABKgAFFAUIKAALALAHAA==.',['夫妻']='夫妻肺骗:BAAAKgAFFAMIAwAAAA==.',['头牛']='头牛骑士:BAACKgAFFH8IAAIiAAgI7wsUCgBbAQAiAAgI7wsUCgBbAQAqAAQKfxYAAw8ACAjuDSGhAAwBAA8ABwhyDSGhAAwBABIABgi4CFNBAH0AAAAA.',['奇奇']='奇奇的木事:BAAAKgAECggICgAAAA==.奇奇的术土:BAAAKgAECgIIAgAAAA==.',['奇急']='奇急因:BAAAKgAECgQIBQAAAA==.',['奈何']='奈何桥畔:BAAAKgAECggICAAAAA==.',['奈法']='奈法莱恩:BAAAKgAFFAQIBAAAAA==.',['奎恩']='奎恩缇丝:BAACKgAFFH8oAAILAAUIsAfhCQCuAAALAAUIsAfhCQCuAAAqAAQKfzQAAgsACAhXEQsrAC0BAAsACAhXEQsrAC0BAAAA.',['奔放']='奔放丶:BAABKgAFFH8SAAMQAAYIwxldEABjAQAQAAYIwxldEABjAQARAAII7RssVgBTAAAAAA==.',['奔跑']='奔跑小健将:BAABKgAFFH8RAAMFAAUI2RtJBgD9AAAMAAUImRhgEwADAQAFAAQIEx9JBgD9AAABKgAFFAgIDgAZACQgAA==.',['奥妮']='奥妮蕾亚斯:BAAAKgADCgIIAgAAAA==.',['奶中']='奶中第一毛:BAAAKgAECggIDgAAAA==.',['妖娆']='妖娆:BAAAKgADCggICAAAAA==.',['妲己']='妲己:BAAAKgAFFAMIAwAAAA==.',['姐姐']='姐姐你别回头:BAAAKgAECgEIAQAAAA==.',['威猛']='威猛先生丶:BAAAKgADCgYIBgAAAA==.',['嫼骉']='嫼骉迋孓:BAAAKgAECgYICQAAAA==.',['孝顺']='孝顺丈母娘:BAAAKgAECgUIBQAAAA==.',['孤城']='孤城寂:BAAAKgAECgcIDwAAAA==.',['完美']='完美小撒子:BAABKgAFFH8HAAITAAcIIBF7BgCsAQATAAcIIBF7BgCsAQAAAA==.',['审判']='审判天使:BAABKgAFFH8FAAIPAAMIPQUGNACSAAAPAAMIPQUGNACSAAAAAA==.',['寂鴉']='寂鴉:BAAAKgAECgUIBgAAAA==.',['寒枫']='寒枫池:BAABKgAECn8XAAIPAAcILg/GowAHAQAPAAcILg/GowAHAQAAAA==.',['对卟']='对卟起:BAABKgAECn8iAAIPAAgISx61OwA8AgAPAAgISx61OwA8AgAAAA==.',['小丶']='小丶七丶:BAAAKgAECgIIAgAAAA==.',['小丷']='小丷七:BAACKgAFFH8VAAIRAAYIuiAYDgCRAQARAAYIuiAYDgCRAQAqAAQKfykAAxEACAh4IfIcAIQCABEACAgkIfIcAIQCABAAAgizJEV4AF8AAAAA.',['小喵']='小喵是只雕:BAABKgAFFH8GAAIPAAYIgRUGHgB6AQAPAAYIgRUGHgB6AQAAAA==.',['小母']='小母牛儿曦曦:BAAAKgAECggICQAAAA==.',['小灬']='小灬七:BAAAKgAECgcIBwAAAA==.',['小熊']='小熊犇犇:BAAAKgADCggICAAAAA==.小熊笨笨:BAAAKgAECggIBwAAAA==.',['小爷']='小爷龙傲天:BAAAKgAECgIIAgAAAA==.',['小王']='小王:BAAAKgAECgMIBgAAAA==.',['小考']='小考拉:BAAAKgADCggICAAAAA==.',['小腿']='小腿肚子:BAAAKgAFFAQIBAAAAA==.',['小透']='小透明:BAAAKgADCggICAAAAA==.',['小飞']='小飞龙来咯:BAABKgAECn8iAAIjAAgIsh3LEQA9AgAjAAgIsh3LEQA9AgABKgAFFAMIBgAJAI0eAA==.',['尖尖']='尖尖头阿巴顿:BAAAKgAECggICAAAAA==.',['就叫']='就叫小橙吧:BAACKgAFFH8oAAIbAAUIvRdhCQA7AQAbAAUIvRdhCQA7AQAqAAQKfzUAAhsACAjFHn4RABcCABsACAjFHn4RABcCAAAA.',['就是']='就是会加血:BAAAKgAECgYICwAAAA==.就是陪人玩:BAABKgAFFH8GAAIWAAYIABQhEwBtAQAWAAYIABQhEwBtAQAAAA==.',['岩黯']='岩黯:BAAAKgADCgIIAgAAAA==.',['崋緔']='崋緔:BAABKgAFFH8OAAMEAAMIpBa1LQDYAAAEAAMIpBa1LQDYAAABAAMITwYrKwBoAAAAAA==.',['左指']='左指尖的画卷:BAABKgAECn85AAMUAAgIAhlEDgDpAQAUAAgIAhlEDgDpAQAVAAEIKQSvfwAeAAAAAA==.',['巨型']='巨型号角:BAAAKgADCggICAAAAA==.',['康洛']='康洛洛鲁西鲁:BAAAKgAECgUIBgAAAA==.',['开朗']='开朗呆呆魔:BAACKgAFFH88AAMBAAgIXhUrBwCzAQABAAgIUhQrBwCzAQAJAAQIQxyjAgD6AAAqAAQKfzwAAwkACAjyI40CAMwCAAkACAiKI40CAMwCAAEACAjKHa4KAEsCAAAA.',['弑杀']='弑杀佛雷:BAABKgAFFH8IAAMIAAgIzxa/CQB9AQAIAAQIHiG/CQB9AQAGAAQIEAmXMACDAAAAAA==.',['弱弱']='弱弱的小蝎子:BAAAKgAECggICAAAAA==.',['征辉']='征辉酋长:BAABKgAFFH8IAAIPAAgIpBhICAA/AgAPAAgIpBhICAA/AgAAAA==.',['微胖']='微胖天花板:BAAAKgAECgUIBQAAAA==.',['心碎']='心碎丶梦已醒:BAAAKgAFFAEIAQAAAA==.',['快乐']='快乐的半支烟:BAAAKgADCggICAAAAA==.',['恐惧']='恐惧天天:BAAAKgADCgcIBwAAAA==.',['恶恶']='恶恶魔:BAAAKgAECgMIAwAAAA==.',['悲慘']='悲慘:BAAAKgADCggICAABKgAFFAUIKAALALAHAA==.',['惜偌']='惜偌凝伤:BAAAKgAFFAMIAwAAAA==.',['想去']='想去海边:BAAAKgAFFAIIAgAAAA==.',['想飛']='想飛别怕摔:BAACKgAFFH8nAAINAAgITCE5BwAxAgANAAgITCE5BwAxAgAqAAQKfzcABA0ACAgDJgAFAPoCAA0ACAgDJgAFAPoCAB0ABAirHMcbAN4AAA4AAghSCn54AFQAAAAA.想飛的小蹄子:BAAAKgAECggICAAAAA==.',['愤怒']='愤怒的葡萄皮:BAAAKgAECgMIAwAAAA==.',['成功']='成功支付:BAABKgAECn8jAAIPAAgIMSG8HACQAgAPAAgIMSG8HACQAgAAAA==.',['我会']='我会飞呀:BAAAKgAECgEIAQAAAA==.',['我剌']='我剌死你:BAAAKgAECgMIAwAAAA==.',['我叫']='我叫雷货:BAAAKgAECggIEgAAAA==.',['我杀']='我杀你你必死:BAAAKgAECgcIDAAAAA==.我杀你你必肆:BAAAKgAECgMIAwAAAA==.',['房灰']='房灰冯:BAAAKgAFFAIIAgAAAA==.',['房道']='房道妄:BAAAKgAECgUIBgAAAA==.',['打断']='打断交给大刘:BAABKgAFFH8IAAIeAAMIOQ24CACCAAAeAAMIOQ24CACCAAAAAA==.',['托尼']='托尼灬乔巴:BAAAKgAFFAIIBAAAAA==.',['托蕾']='托蕾斯:BAAAKgADCgcIBwAAAA==.',['抗怪']='抗怪倒霉牛:BAAAKgAECggICQAAAA==.',['折耳']='折耳团:BAAAKgAECgYIBgAAAA==.',['抠破']='抠破都不给你:BAAAKgAFFAMIAwAAAA==.',['护佑']='护佑妮:BAAAKgADCggICAAAAA==.',['抽华']='抽华子咳嗽:BAAAKgADCggICwAAAA==.',['拳如']='拳如风:BAACKgAFFH8SAAITAAQIeCQ/CAD+AAATAAQIeCQ/CAD+AAAqAAQKfysAAhMACAh1I+8HALsCABMACAh1I+8HALsCAAAA.',['指尖']='指尖执念:BAABKgAECn8WAAMCAAgIAyHkBwCTAgACAAgI7iDkBwCTAgAhAAYIVxwjGAB/AQAAAA==.',['捅主']='捅主任:BAACKgAFFH8OAAIRAAMItCGjIAAKAQARAAMItCGjIAAKAQAqAAQKfxgAAhEACAjRItgXAHICABEACAjRItgXAHICAAAA.',['捕风']='捕风:BAAAKgAECgYIDAAAAA==.',['撕夹']='撕夹栗:BAAAKgAFFAEIAQAAAA==.',['救赎']='救赎之盾丶:BAAAKgAECgIIAgAAAA==.救赎之魂丶:BAACKgAFFH8QAAQSAAUIMx9kBwA9AQASAAMIzCRkBwA9AQAPAAMIHRD6UADOAAAiAAIIOBIcFQA5AAAqAAQKfywAAxIACAgRJOQCAMICABIACAgRJOQCAMICAA8ABAjnEqf5AL8AAAAA.',['斗山']='斗山:BAAAKgAECggIEgAAAA==.',['斩丶']='斩丶赤红:BAAAKgADCgEIAQAAAA==.',['斩春']='斩春:BAAAKgADCggICAABKgAFFAgIPQAIALogAA==.',['斩神']='斩神狂:BAAAKgADCggIEAAAAA==.',['新手']='新手试玩:BAAAKgAFFAQIBAAAAA==.',['旋风']='旋风叉:BAAAKgADCgUIBQAAAA==.',['无忧']='无忧僧:BAAAKgAFFAQIBAAAAA==.',['无情']='无情灬哈拉少:BAAAKgAECgcIEAAAAA==.',['无敌']='无敌剪刀手:BAAAKgAECgYIEgAAAA==.',['无邪']='无邪丶:BAACKgAFFH8WAAIHAAQIpR7ODAD1AAAHAAQIpR7ODAD1AAAqAAQKfxoAAgcACAhAGxEaAAYCAAcACAhAGxEaAAYCAAEqAAUUCAgQABIAMx8A.',['无间']='无间稻:BAAAKgAFFAUIBAAAAA==.',['晨光']='晨光里有你丶:BAABKgAFFH8FAAISAAUImgk9CgAEAQASAAUImgk9CgAEAQAAAA==.',['普崔']='普崔塞德:BAAAKgAECgMIAwAAAA==.',['暗影']='暗影行者:BAAAKgADCgIIAgAAAA==.',['暗杀']='暗杀女兵:BAAAKgAECgQIBAAAAA==.',['暗牧']='暗牧模仿者:BAAAKgAFFAMIAwAAAA==.',['暮影']='暮影旋律:BAACKgAFFH8oAAMIAAUIoRqnBwAdAQAGAAUIQhoyCgAvAQAIAAMIkB+nBwAdAQAqAAQKfzMAAwgACAjeINkRADgCAAgACAh3HdkRADgCAAYABgjKH+QrAJgBAAAA.',['暴走']='暴走天使龙二:BAAAKgAECgUIBQAAAA==.',['暴躁']='暴躁小战手:BAAAKgAECgEIAQAAAA==.暴躁小萨手:BAAAKgAECgEIAQAAAA==.暴躁小骑手:BAAAKgAECgEIAQAAAA==.暴躁的熊二:BAAAKgAECgMIAwAAAA==.暴躁的魔导师:BAAAKgAECgYICwAAAA==.暴躁的龙龙:BAAAKgAECgYICAAAAA==.',['暴风']='暴风过境:BAAAKgADCgIIAgAAAA==.',['暴食']='暴食海獭:BAABKgAFFH8NAAMiAAYIFRqDAwA/AQAiAAYICBGDAwA/AQAPAAQI9xp7HADxAAAAAA==.',['曉曉']='曉曉貓丶:BAAAKgAFFAYIAQAAAA==.',['曦啊']='曦啊曦啊啊:BAABKgAFFH8bAAIRAAcIiyIwBQBOAgARAAcIiyIwBQBOAgAAAA==.',['最后']='最后的狂欢:BAAAKgADCgEIAQAAAA==.',['月夜']='月夜忧光:BAAAKgAECgUICQAAAA==.',['月见']='月见:BAAAKgAECggIDwAAAA==.',['有点']='有点小脾气:BAAAKgADCgUIBQAAAA==.',['有痣']='有痣不在年糕:BAAAKgADCgMIAwAAAA==.',['未亡']='未亡人素世:BAAAKgAFFAEIAQAAAA==.',['未央']='未央不见丶:BAACKgAFFH8OAAINAAMIqh/YCQAfAQANAAMIqh/YCQAfAQAqAAQKfy4AAg0ACAjmI3QJANICAA0ACAjmI3QJANICAAAA.',['术术']='术术老师:BAAAKgAECgYICgAAAA==.',['果子']='果子哟吼:BAACKgAFFH8GAAIGAAMIkhoSEADMAAAGAAMIkhoSEADMAAAqAAQKfx0AAgYACAhlEQ8yAFkBAAYACAhlEQ8yAFkBAAAA.',['柳如']='柳如烟:BAAAKgAECgEIAQAAAA==.',['栎栎']='栎栎一级棒:BAAAKgAFFAYIAQAAAA==.',['森森']='森森:BAACKgAFFH8FAAIDAAIISgbvIgB+AAADAAIISgbvIgB+AAAqAAQKfy8AAgMACAinGQkrAN0BAAMACAinGQkrAN0BAAAA.',['橙仔']='橙仔丶:BAABKgAFFH8NAAILAAMIYRboBwDRAAALAAMIYRboBwDRAAAAAA==.',['欢快']='欢快的小牛:BAAAKgAECggICAAAAA==.',['步凡']='步凡:BAAAKgAECgcICAAAAA==.',['武僧']='武僧二零零九:BAAAKgADCgEIAQAAAA==.',['武戈']='武戈:BAAAKgADCggICAAAAA==.',['歪嘴']='歪嘴龙王:BAABKgAFFH8hAAIjAAUIgBkACQALAQAjAAUIgBkACQALAQAAAA==.',['死亡']='死亡的回响:BAABKgAECn8VAAMBAAgIPwUwGAB1AAABAAgIiwMwGAB1AAAEAAMI2gY2NgAqAAAAAA==.',['死王']='死王叔:BAAAKgAECggICQAAAA==.',['毒龙']='毒龙钻丶得劲:BAAAKgAECgQIBAAAAA==.',['毛毛']='毛毛:BAAAKgAFFAcIBAAAAA==.',['水往']='水往高处流:BAAAKgAECgMIAwAAAA==.',['水树']='水树奈奈:BAABKgAECn8UAAMTAAgIuxtQFAAMAgATAAcIvB5QFAAMAgAfAAYIaA27FADbAAAAAA==.',['江万']='江万理:BAABKgAFFH8NAAMRAAUI0BwQIQAHAQARAAUI4hUQIQAHAQAQAAIIcCKTGgCUAAAAAA==.',['江夏']='江夏:BAABKgAECn8uAAIPAAgIGyI4JACKAgAPAAgIGyI4JACKAgAAAA==.',['江山']='江山:BAAAKgAECgcIBwAAAA==.',['没有']='没有星期天:BAABKgAECn8lAAIQAAgIRg82RgA4AQAQAAgIRg82RgA4AQAAAA==.',['治愈']='治愈之手:BAAAKgAECgYICgAAAA==.',['法力']='法力枯竭:BAACKgAFFH8VAAQZAAYI4wxIEwBKAQAZAAYI4wxIEwBKAQAMAAIImwCwPABCAAAFAAIIpwDQJAAvAAAqAAQKfxcABBkACAikDiUZANYAABkABAj1FSUZANYAAAUABgjgBCF0AK4AAAwABQhkA599AIsAAAAA.',['法小']='法小贱:BAAAKgAECgQIDwAAAA==.',['波妞']='波妞:BAABKgAFFH8cAAMQAAgIpyDoAQCIAQAQAAgI4B3oAQCIAQARAAYIkhwBEQBwAQAAAA==.',['波波']='波波好大:BAAAKgAECgIIAgAAAA==.',['津杠']='津杠开捉五本:BAAAKgAECgYIBgAAAA==.',['活活']='活活治死:BAAAKgAECggICwAAAA==.活活玩死:BAAAKgAECggICgAAAA==.活活疼死:BAAAKgAECgYICgAAAA==.活活顶死:BAAAKgAECgIIAgAAAA==.',['派派']='派派小星:BAACKgAFFH8PAAIFAAMIVhhCEgDRAAAFAAMIVhhCEgDRAAAqAAQKfzoAAgUACAicIRAJAKECAAUACAicIRAJAKECAAAA.',['浅笑']='浅笑悲伤:BAABKgAFFH8RAAMFAAQIdxyTDQD4AAAFAAQIdxyTDQD4AAAZAAQIbw/UFwC+AAABKgAFFAQIEwAWAC0YAA==.',['浊心']='浊心斯卡蒂:BAAAKgAFFAMIAQAAAA==.',['浮世']='浮世清欢:BAACKgAFFH8YAAQfAAgInRSrAQAKAgAfAAgIKxSrAQAKAgAcAAIIIyVoEQDgAAATAAMIsA/XDgDCAAAqAAQKfxoAAxwACAhrH5UJAG0CABwACAhrH5UJAG0CAB8ACAh8IIMHAAQCAAAA.',['消失']='消失的五月:BAABKgAFFH8GAAMiAAYI8xXXHgCFAAAPAAIISSKDYACvAAAiAAQIuQ3XHgCFAAABKgAFFAgICAAPAC8jAA==.',['淘气']='淘气小生:BAABKgAECn8zAAIWAAgI1hbYIgCbAQAWAAgI1hbYIgCbAQAAAA==.',['淡若']='淡若如初:BAAAKgADCgQIBAAAAA==.',['深渊']='深渊幽鬼:BAABKgAECn8sAAMRAAgInxvoDABFAgARAAgIiBvoDABFAgAQAAgI5RXXEgCnAQAAAA==.',['潇然']='潇然随风:BAACKgAFFH8QAAQXAAUIZxT5BAD9AAAXAAMIxhf5BAD9AAAWAAIIcxINOwCDAAAYAAIIfQXcFwA+AAAqAAQKfyMABBcACAgUH/cIAOABABcABwhXHPcIAOABABYABQitGUFbAP8AABgABAgGHxlKAL0AAAAA.',['潛行']='潛行閃光彈:BAABKgAECn8VAAMkAAgI9h5TBwB2AgAkAAgI9h5TBwB2AgAbAAUIoxvjJQA6AQAAAA==.',['灬丨']='灬丨七丨灬:BAAAKgAFFAQIBAAAAA==.',['灰头']='灰头呆鸟:BAABKgAECn8VAAIcAAgI3R8KCQB2AgAcAAgI3R8KCQB2AgAAAA==.',['炸丨']='炸丨开:BAAAKgAFFAIIAgAAAA==.',['炸德']='炸德:BAAAKgAFFAQIBAABKgAFFAgIEAASADMfAA==.',['点哥']='点哥:BAAAKgAFFAIIAgAAAA==.',['点点']='点点丶一级棒:BAACKgAFFH8KAAIPAAUIJBNIGQAdAQAPAAUIJBNIGQAdAQAqAAQKfxgAAw8ACAh1HUJNAAoCAA8ACAh1HUJNAAoCACIAAQjDBfNaAB0AAAAA.',['烈萨']='烈萨血魔:BAAAKgAECggIDgAAAA==.',['無訫']='無訫倾城:BAAAKgAFFAgIBAAAAA==.',['熊本']='熊本熊大魔王:BAABKgAFFH8IAAIPAAgIBR28BgBdAgAPAAgIBR28BgBdAgAAAA==.',['爱似']='爱似烟火:BAACKgAFFH8YAAMDAAUILRUsEgA3AQADAAUILRUsEgA3AQACAAEIuAIOLQAtAAAqAAQKfyUAAwMACAhuGlYdACkCAAMACAi8GFYdACkCAAIAAwhPFvVNAJMAAAAA.',['爱吃']='爱吃鱼的人:BAAAKgAFFAMIAwAAAA==.',['爱在']='爱在:BAAAKgADCgIIAgAAAA==.',['爱晴']='爱晴晴:BAAAKgAECgcICwAAAA==.',['爱贝']='爱贝贝:BAAAKgAECggICAAAAA==.',['牛叉']='牛叉超龄儿童:BAABKgAFFH8cAAMOAAgI9RkpAACLAgAOAAgI9RkpAACLAgANAAQI6QodJACjAAAAAA==.',['牛德']='牛德了不得:BAAAKgAECgcIBwAAAA==.',['物语']='物语:BAAAKgAECgIIAgAAAA==.',['特仑']='特仑苏纯奶牛:BAAAKgAECgcICAAAAA==.',['狂战']='狂战冲天:BAAAKgAECgcIBwAAAA==.',['狂野']='狂野猩:BAACKgAFFH8UAAMCAAMI1wojDQC+AAACAAMI1wojDQC+AAAhAAMIzQNDCwBdAAAqAAQKf0sAAwIACAj5Gg0HAAcCAAIABwgBHQ0HAAcCACEACAglFJwXAIUBAAAA.',['狐碧']='狐碧猎:BAAAKgAECgYIBgAAAA==.',['猛猛']='猛猛吃香菜:BAAAKgAECgcIDQAAAA==.',['猫叔']='猫叔嘚赴亡者:BAAAKgADCgEIAQAAAA==.',['王者']='王者永和:BAAAKgAECgYIDAAAAA==.',['球神']='球神阿伟罗:BAAAKgAECgUIBgAAAA==.',['电萨']='电萨雷鸣:BAAAKgAECgUIBQAAAA==.',['疯狂']='疯狂吃香菜:BAAAKgAECgIIAgAAAA==.',['癫疯']='癫疯神射:BAAAKgAECgMIAwAAAA==.',['白夜']='白夜行:BAAAKgAFFAMIAwAAAA==.',['白色']='白色树袋熊:BAAAKgAFFAIIAgAAAA==.',['白锦']='白锦无纹:BAABKgAFFH8UAAMKAAYIJRi0EgBmAQAKAAYIJRi0EgBmAQALAAQI6ALOEQB1AAABKgAFFAgIBgAfAPgLAA==.',['白面']='白面包呢:BAABKgAFFH8KAAINAAYIHiGYCQAhAQANAAYIHiGYCQAhAQAAAA==.',['百思']='百思得你姐:BAAAKgADCggICAAAAA==.',['皇家']='皇家恐怖騎士:BAAAKgAECggICAAAAA==.',['直布']='直布罗陀学姐:BAABKgAFFH8MAAMBAAYIxhpuAQCzAQABAAYIJRpuAQCzAQAEAAQIiCB+KwDfAAAAAA==.',['看什']='看什么我有枪:BAABKgAFFH8IAAIRAAQI8xYeIwDKAAARAAQI8xYeIwDKAAAAAA==.',['真灬']='真灬怡宝:BAAAKgAFFAIIAgAAAA==.',['瞬秒']='瞬秒:BAABKgAFFH8KAAMDAAYITxZjDQB6AQADAAYITxZjDQB6AQACAAMIMAZQEQCBAAAAAA==.',['知默']='知默:BAAAKgAECgYICQAAAA==.',['神圣']='神圣之翼:BAAAKgAECgQIBAAAAA==.',['神经']='神经科主任:BAAAKgAECgYIBwAAAA==.',['福生']='福生玄煌天尊:BAABKgAFFH8GAAIEAAYIKRHYCgBtAQAEAAYIKRHYCgBtAQAAAA==.',['福音']='福音猎手:BAAAKgADCggIEAAAAA==.',['稻香']='稻香:BAABKgAFFH8IAAIZAAgI9Ad9CgC6AQAZAAgI9Ad9CgC6AQAAAA==.',['穨廢']='穨廢厷宔:BAAAKgAECgUIBQAAAA==.',['空之']='空之轨迹:BAABKgAFFH8NAAMNAAYIEhS5AwCJAQANAAYIEhS5AwCJAQAOAAYI+xoAAAAAAAAAAA==.',['空天']='空天猎:BAABKgAFFH8KAAMRAAcIAQg/IAAMAQARAAcIAQg/IAAMAQAQAAMILgE7JgBFAAAAAA==.',['空心']='空心菜:BAAAKgAFFAQIAgAAAA==.',['窝嫩']='窝嫩达爹:BAAAKgAECggICAAAAA==.',['笙笙']='笙笙骑:BAAAKgAFFAUIAQAAAA==.',['粉色']='粉色仙女蚌:BAAAKgAFFAgIBAAAAA==.',['糖门']='糖门丶歌吾嗯:BAAAKgADCgEIAQAAAA==.',['素颜']='素颜女王:BAABKgAFFH8IAAIPAAgIzwxIDADeAQAPAAgIzwxIDADeAQAAAA==.',['緋紅']='緋紅色:BAAAKgAECgYIBgAAAA==.',['红尘']='红尘九世仙:BAAAKgAECgcIDQAAAA==.',['红牛']='红牛能量饮料:BAABKgAFFH8GAAMBAAYIBRoFEQC5AAAEAAIIwiTjLQDXAAABAAQI3BIFEQC5AAAAAA==.',['红莲']='红莲落:BAAAKgAECgUIBQAAAA==.',['红蝶']='红蝶第一砖:BAACKgAFFH8zAAMjAAgIRR0vCQDkAQAjAAgIRR0vCQDkAQAlAAMIfRA9AADNAAAqAAQKfx8AAiMACAjcI9kGALgCACMACAjcI9kGALgCAAAA.',['纯閖']='纯閖灬丒恨:BAAAKgAFFAEIAQAAAA==.',['纵死']='纵死侠骨香:BAAAKgAFFAYIBAAAAA==.',['细脸']='细脸长胳膊:BAAAKgADCggICAAAAA==.',['给我']='给我:BAAAKgADCggICAAAAA==.',['绝地']='绝地斩杀:BAAAKgAECgIIAgAAAA==.',['绾青']='绾青丝丶:BAAAKgAECgQIBAAAAA==.',['缇娜']='缇娜:BAAAKgADCggICAAAAA==.',['罗小']='罗小蝶:BAABKgAFFH8GAAIUAAQIAhxTCQANAQAUAAQIAhxTCQANAQABKgAFFAgICAAUALsbAA==.',['美女']='美女亲爱的:BAAAKgAECgYIBgAAAA==.',['翠绿']='翠绿树袋熊:BAABKgAFFH8MAAIcAAgILhCICQCTAQAcAAgILhCICQCTAQAAAA==.',['老兵']='老兵牛蹄:BAAAKgADCggICAAAAA==.',['老天']='老天最爱的崽:BAACKgAFFH8wAAIUAAgI4h+cAgBcAgAUAAgI4h+cAgBcAgAqAAQKf1wAAhQACAh9JPUJAJ8CABQACAh9JPUJAJ8CAAAA.',['老妹']='老妹你多大:BAAAKgADCgEIAQAAAA==.',['老牛']='老牛儿:BAAAKgAECgQIBAAAAA==.',['考拉']='考拉熊:BAAAKgAFFAcIAQAAAA==.',['肉身']='肉身成圣光:BAACKgAFFH8WAAIPAAMI5CBlGgATAQAPAAMI5CBlGgATAQAqAAQKf0IAAg8ACAi2JB8HAMkCAA8ACAi2JB8HAMkCAAAA.',['胖潘']='胖潘哒:BAAAKgAECgMIAwAAAA==.',['胖胖']='胖胖大龙龙:BAABKgAFFH8KAAIjAAgI1A8SCADtAQAjAAgI1A8SCADtAQAAAA==.',['脏藝']='脏藝朮家:BAAAKgAECgUIBQAAAA==.',['脸滚']='脸滚带爬:BAACKgAFFH8TAAMcAAMImhMoHAC9AAAcAAMImhMoHAC9AAAfAAEIjQKqDAAkAAAqAAQKfyUAAxwACAhAIUgKAJ0CABwACAhAIUgKAJ0CABMAAQg5EPZ4ADEAAAAA.',['自君']='自君别后:BAACKgAFFH8NAAMUAAYI/hriCACDAQAUAAYI/hriCACDAQAaAAMI2xECEACsAAAqAAQKfxUAAxQACAiiHNsfAAsCABQACAiiHNsfAAsCABUABQifJB8lAKcBAAAA.',['舞灬']='舞灬橙贼多:BAABKgAFFH8IAAIEAAgICQsgBwDiAQAEAAgICQsgBwDiAQAAAA==.',['艺术']='艺术即是爆炸:BAAAKgAECgMIBQAAAA==.',['艾丽']='艾丽桑德:BAACKgAFFH8QAAIhAAQIzgcACACNAAAhAAQIzgcACACNAAAqAAQKfywAAiEACAjoFskRAKEBACEACAjoFskRAKEBAAAA.',['艾瑞']='艾瑞卡:BAACKgAFFH8ZAAMBAAYIxSI0BgAvAQAEAAYI1B5PDQC8AQABAAYIcxg0BgAvAQAqAAQKfxgAAwQACAgIGNRBAKoBAAQACAjLF9RBAKoBAAEACAikEn0qADkBAAAA.',['艾辛']='艾辛诺斯:BAABKgAFFH8GAAILAAYIIwF2FwCOAAALAAYIIwF2FwCOAAAAAA==.',['芙柔']='芙柔桑克斯:BAAAKgAFFAMIAQAAAA==.',['花泽']='花泽香菜:BAAAKgAECggIEgAAAA==.',['若月']='若月晶影:BAAAKgADCgQIBAAAAA==.',['范灬']='范灬尛菇凉:BAAAKgAECgQIBAAAAA==.',['茗香']='茗香飘鳥:BAAAKgADCgMIAwAAAA==.',['草吃']='草吃牛儿毕博:BAAAKgADCgQIBAAAAA==.',['草莽']='草莽英雄许仙:BAABKgAFFH8GAAImAAYIVQgAAAAAAAAcAAYIVQgAAAAAAAAAAA==.',['草鹿']='草鹿八千蓅:BAACKgAFFH8nAAIbAAcIpiD9BABFAgAbAAcIpiD9BABFAgAqAAQKf0cAAhsACAiPJq4BAPcCABsACAiPJq4BAPcCAAAA.',['莫名']='莫名祈祷:BAAAKgAECgEIAQAAAA==.',['莫斯']='莫斯:BAAAKgAFFAIIAQAAAA==.',['萌妹']='萌妹落泪:BAAAKgAECgcICwAAAA==.',['落天']='落天星尘:BAABKgAFFH8KAAIUAAYIrhXzCgBPAQAUAAYIrhXzCgBPAQAAAA==.',['葬爱']='葬爱灬杀马特:BAACKgAFFH8UAAQXAAQIkyJHBAARAQAXAAMIVCJHBAARAQAWAAQIcCDcIwDqAAAYAAEIAAAcNwAAAAAqAAQKfywABBYACAi8JEUHALYCABYACAieJEUHALYCABgABghnIDseAJYBABcAAgjOGd0uAHoAAAAA.',['蒜泥']='蒜泥泥空心菜:BAABKgAECn8fAAIUAAgIsSBcDQCNAgAUAAgIsSBcDQCNAgAAAA==.',['蓝毛']='蓝毛老头:BAACKgAFFH8HAAIPAAMIIhWTMQCpAAAPAAMIIhWTMQCpAAAqAAQKfyQAAg8ACAghHxkRAE8CAA8ACAghHxkRAE8CAAAA.',['蓝灬']='蓝灬箭舞霓裳:BAAAKgAECggICAAAAA==.',['蓝精']='蓝精灵:BAAAKgADCgIIAgAAAA==.',['蓝色']='蓝色冰凌:BAAAKgAECgYIBgAAAA==.蓝色的秋天:BAAAKgADCggICAAAAA==.',['蔚蓝']='蔚蓝海洋:BAAAKgAFFAgIBAAAAA==.',['蔷薇']='蔷薇时代:BAACKgAFFH8NAAMQAAMI9BGrDgDfAAAQAAMI0BGrDgDfAAARAAEI9Q3BRwBIAAAqAAQKfyoAAxAACAgnI1ALAIUCABAACAgnI1ALAIUCABEAAwgIF07SAIYAAAEqAAUUBggKABEAFBUA.',['蕴之']='蕴之:BAABKgAECn8aAAMIAAgIoBzBGgDuAQAIAAgINRjBGgDuAQAGAAgIZhU8LwCHAQAAAA==.',['蕾姆']='蕾姆灬真爱蓝:BAAAKgAECgMIAwAAAA==.',['蕾蒂']='蕾蒂娅:BAAAKgAFFAQIBAAAAA==.',['藝朮']='藝朮家:BAAAKgAECgEIAQAAAA==.',['虚空']='虚空破灭:BAABKgAECn8UAAMFAAcI9haEQQBiAQAFAAcI9haEQQBiAQAMAAYIXQkyYwDlAAAAAA==.',['蚂蚁']='蚂蚁:BAABKgAFFH8iAAMRAAQI2x/kHQAYAQARAAQI2x/kHQAYAQAQAAQIHhNkJgDSAAAAAA==.蚂蚁仔:BAAAKgAFFAQIBAAAAA==.',['蛇舞']='蛇舞的前奏:BAABKgAFFH8IAAIZAAgI/gO8DQBjAQAZAAgI/gO8DQBjAQAAAA==.',['血色']='血色一少:BAAAKgAECgIIAgAAAA==.',['褶子']='褶子脸:BAAAKgAFFAYIBAAAAA==.',['西一']='西一欧:BAABKgAFFH8OAAMaAAYIUhxWBwAWAQAaAAQIKBhWBwAWAQAUAAQI2wX7HACqAAABKgAFFAgIFgAIAIwTAA==.',['西瓜']='西瓜妈妈:BAABKgAFFH8KAAIPAAYIWBzwEwC8AQAPAAYIWBzwEwC8AQAAAA==.西瓜灵:BAAAKgADCggICAAAAA==.西瓜血蹄:BAAAKgAECggICgAAAA==.',['覆灭']='覆灭者一雷斯:BAAAKgADCggICAAAAA==.',['譽丶']='譽丶:BAAAKgAECgcIDAAAAA==.',['让月']='让月亮晒黑了:BAAAKgAECgQIBAAAAA==.',['诛伏']='诛伏赐死:BAAAKgAECgcIDQAAAA==.',['调皮']='调皮的只只:BAABKgAFFH8GAAIjAAYIZAL3GwDfAAAjAAYIZAL3GwDfAAAAAA==.',['豆丁']='豆丁坦:BAAAKgAECggICAAAAA==.',['贝塔']='贝塔丶怒蹄:BAAAKgAECgMIAwAAAA==.',['贝尔']='贝尔法斯特:BAAAKgADCggICAAAAA==.',['赫卡']='赫卡里姆:BAAAKgAECgUIAgAAAA==.',['走路']='走路带风:BAABKgAFFH8NAAMKAAYICiH+AQDaAQAKAAYICiH+AQDaAQALAAIIpADmIwBEAAABKgAFFAgIJwABAMkcAA==.',['超级']='超级大闸蟹:BAAAKgAECgEIAQAAAA==.超级奶爸:BAAAKgADCgEIAgAAAA==.超级白白:BAAAKgAECgEIAQAAAA==.',['轩辕']='轩辕晨曦:BAABKgAFFH8TAAIWAAQILRgnFQDeAAAWAAQILRgnFQDeAAAAAA==.',['进口']='进口大龙人:BAAAKgAECgYICAAAAA==.',['邦邦']='邦邦:BAAAKgAECgYIBgABKgAFFAYIMQAJAEoXAA==.',['邪乄']='邪乄冰魔:BAAAKgAECgYIBgAAAA==.',['邪天']='邪天使玛丽:BAACKgAFFH8GAAIKAAQIbxupIgDyAAAKAAQIbxupIgDyAAAqAAQKfyoAAwoACAgpIzYKALkCAAoACAgpIzYKALkCAAsABQgOCipLAJQAAAAA.',['邪恶']='邪恶大武僧:BAAAKgAECgIIAgAAAA==.邪恶栀子花:BAABKgAFFH8LAAIEAAgIOR1aBQBMAgAEAAgIOR1aBQBMAgAAAA==.邪恶波比:BAAAKgAFFAIIAgAAAA==.',['邪邪']='邪邪老师:BAAAKgAECgcICgAAAA==.',['部落']='部落小钢炮:BAAAKgAFFAQIBAABKgAFFAgIEAAMAKcaAA==.部落雅典娜:BAABKgAECn8VAAIRAAgIjhLpVABcAQARAAgIjhLpVABcAQAAAA==.',['都说']='都说缺德:BAAAKgAECgUIBAAAAA==.',['酒桶']='酒桶:BAAAKgADCgYIBgAAAA==.',['酷酷']='酷酷吃香菜:BAAAKgADCgEIAQAAAA==.酷酷龙:BAAAKgAECggICAAAAA==.',['醋焖']='醋焖鱼:BAAAKgAECgEIAQAAAA==.',['重新']='重新集结部队:BAABKgAFFH8SAAIPAAMIEBxDQgDrAAAPAAMIEBxDQgDrAAAAAA==.',['金左']='金左脚:BAAAKgADCgIIAgAAAA==.',['钮扣']='钮扣:BAAAKgAECgIIAgAAAA==.',['钻石']='钻石王老五:BAABKgAFFH8GAAIUAAYIgAQrEwDeAAAUAAYIgAQrEwDeAAAAAA==.',['铁渣']='铁渣渣:BAAAKgAECgIIAgAAAA==.',['铃木']='铃木爱理:BAABKgAECn8fAAMHAAgITxeMFQDpAQAHAAgITxeMFQDpAQAIAAcIqBLEKwBRAQAAAA==.',['银鞍']='银鞍照白马:BAABKgAFFH8SAAIBAAYIhwy+FQDzAAABAAYIhwy+FQDzAAABKgAFFAgIDgAEAEoXAA==.',['锅包']='锅包肉大丞:BAAAKgAECgUICgAAAA==.锅包肉大成:BAABKgAECn8jAAQFAAcIcBnFOgCCAQAFAAcIcBnFOgCCAQAZAAUI+A5TLgC1AAAMAAEIAACksQAAAAAAAA==.',['锅碗']='锅碗瓢盆壶:BAAAKgAECgIIAgAAAA==.',['镜中']='镜中花:BAABKgAECn8ZAAITAAgIyCHPCACZAgATAAgIyCHPCACZAgAAAA==.',['长岛']='长岛冰茶丶:BAABKgAFFH8OAAIWAAYI2xsLAwCeAQAWAAYI2xsLAwCeAQAAAA==.',['開心']='開心不開心:BAABKgAFFH8IAAMSAAQIchScDgDNAAASAAQIchScDgDNAAAPAAIIeAXJiwA8AAAAAA==.',['门墩']='门墩:BAABKgAECn8YAAMZAAgIGiLeBACrAgAZAAgIGiLeBACrAgAMAAIIqx1TkQBTAAAAAA==.',['闪电']='闪电恋:BAACKgAFFH8lAAIUAAYIySJSBgAnAQAUAAYIySJSBgAnAQAqAAQKf0UAAhQACAiSI/kJAKYCABQACAiSI/kJAKYCAAAA.',['闪耀']='闪耀:BAAAKgADCgIIAgAAAA==.',['阮星']='阮星竹:BAABKgAFFH8IAAIcAAYIPhEDDwA6AQAcAAYIPhEDDwA6AQAAAA==.',['防战']='防战糕糕手:BAABKgAFFH8FAAICAAQIxwvICADfAAACAAQIxwvICADfAAAAAA==.',['阿兰']='阿兰迪尔:BAAAKgAFFAYIAwAAAA==.',['阿加']='阿加雷斯:BAAAKgADCgEIAQAAAA==.',['阿姨']='阿姨我想通了:BAAAKgAECggICAAAAA==.',['阿尔']='阿尔图罗:BAABKgAFFH8GAAIKAAYI1A5yBACZAQAKAAYI1A5yBACZAQAAAA==.',['阿晨']='阿晨大魔王:BAACKgAFFH8vAAMCAAgIax2RAwAfAgACAAYIkB6RAwAfAgADAAUIWhfJEwDoAAAqAAQKfz4AAwIACAi7JCIFAMMCAAIACAiLJCIFAMMCAAMACAgGH/8cACsCAAAA.',['陨篂']='陨篂:BAAAKgAFFAIIAgAAAA==.',['陳灬']='陳灬柒柒:BAAAKgAECgUIBQAAAA==.陳灬那个小法:BAAAKgADCgQIBAAAAA==.',['雷丿']='雷丿霆:BAAAKgADCggICAAAAA==.',['雷欧']='雷欧灬奥特曼:BAACKgAFFH8FAAIjAAUIcw9PBQBHAQAjAAUIcw9PBQBHAQAqAAQKfxoAAiMACAiPIJkNAGYCACMACAiPIJkNAGYCAAAA.',['雾中']='雾中猎手:BAABKgAFFH8TAAIKAAgIHxzaBABpAgAKAAgIHxzaBABpAgAAAA==.',['雾雾']='雾雾子:BAAAKgAECgQIBAAAAA==.',['霜晨']='霜晨月:BAABKgAECn8SAAIcAAYINw1BPADZAAAcAAYINw1BPADZAAAAAA==.',['霸道']='霸道总裁上我:BAAAKgAECgYIBwABKgAFFAUIKAALALAHAA==.',['青柠']='青柠微酸:BAAAKgAECgUIBQAAAA==.',['静蓝']='静蓝:BAAAKgAECgYIBgAAAA==.',['风之']='风之叹息:BAABKgAFFH8IAAIjAAgIsB6pAgCrAgAjAAgIsB6pAgCrAgAAAA==.',['风雷']='风雷焱:BAAAKgAECggICAAAAA==.',['飞侠']='飞侠:BAAAKgAECggIEAAAAA==.',['飞飞']='飞飞的狗腿子:BAAAKgAFFAIIAgAAAA==.',['骑小']='骑小骑:BAACKgAFFH8HAAIPAAMIsyT3LgAsAQAPAAMIsyT3LgAsAQAqAAQKfygAAg8ACAhJJWYLAOUCAA8ACAhJJWYLAOUCAAAA.',['高兴']='高兴霸霸:BAABKgAFFH8eAAMPAAQIviHPLgAtAQAPAAQIviHPLgAtAQAiAAMIrA6THgCHAAAAAA==.',['高大']='高大上:BAAAKgADCggICQAAAA==.高大壮:BAAAKgADCgcIBwAAAA==.',['鬼丿']='鬼丿术:BAAAKgAECgUICgAAAA==.',['鬼刃']='鬼刃天使:BAAAKgAECggICAAAAA==.',['魔仙']='魔仙小豪:BAAAKgADCggICAAAAA==.',['魔法']='魔法喷泉:BAABKgAFFH8GAAIGAAYINQt1EwAXAQAGAAYINQt1EwAXAQAAAA==.',['魔神']='魔神坛斗士:BAAAKgAECgMIAwAAAA==.',['魔能']='魔能领主昆扎:BAAAKgAECgMIBwAAAA==.',['鸡饵']='鸡饵加蛋:BAAAKgADCgIIAgAAAA==.',['鹏鹏']='鹏鹏的铸铁锅:BAABKgAFFH8GAAIUAAYI7gjoEAD2AAAUAAYI7gjoEAD2AAAAAA==.鹏鹏的锅:BAAAKgAECgIIAwAAAA==.鹏鹏的高压锅:BAAAKgAECgYICwAAAA==.',['麦子']='麦子熟了:BAABKgAECn8UAAMUAAgITwjcYAAdAQAUAAgITwjcYAAdAQAVAAcIkAsXHwDQAAABKgAFFAgICwAGAKsaAA==.',['麦搁']='麦搁倪酮须:BAAAKgAECgMIAwAAAA==.',['麻宫']='麻宫雅典娜:BAABKgAFFH8GAAIWAAII+wruRABWAAAWAAII+wruRABWAAAAAA==.',['黄瓜']='黄瓜:BAABKgAFFH8KAAMYAAgIJhytBADrAAAWAAcI/xlwGABAAQAYAAMI7hatBADrAAAAAA==.',['黑夜']='黑夜的夜:BAAAKgAFFAQIBAAAAA==.',['黑色']='黑色蕾丝秋裤:BAAAKgAECgMIAwAAAA==.',['黑骑']='黑骑士丶:BAAAKgAECggICQAAAA==.',['黛丝']='黛丝:BAAAKgAECggICgAAAA==.',['黯夜']='黯夜公爵:BAABKgAECn8WAAMSAAgIhR6rCABiAgASAAgIhR6rCABiAgAPAAEIvANEkAAYAAAAAA==.',['鼓捣']='鼓捣蛋:BAAAKgAECgMIAwAAAA==.',['齒輪']='齒輪:BAAAKgAECggIEAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end