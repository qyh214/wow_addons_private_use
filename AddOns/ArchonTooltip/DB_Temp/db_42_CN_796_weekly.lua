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
 local lookup = {'Priest-Holy','Priest-Shadow','Priest-Discipline','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Evoker-Preservation','Evoker-Devastation','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Guardian','Warlock-Destruction','Warlock-Demonology','Shaman-Enhancement','Shaman-Restoration','Rogue-Assassination','Druid-Balance','Druid-Feral','Druid-Restoration','Mage-Fire','Mage-Arcane','Paladin-Retribution','Paladin-Holy','Paladin-Protection','DeathKnight-Frost','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Warrior-Fury','Mage-Frost','Warrior-Arms','Warrior-Protection','Shaman-Elemental','DeathKnight-Unholy','Rogue-Subtlety','Warlock-Affliction','Rogue-Outlaw','Unknown-Unknown',}; local provider = {region='CN',realm='能源舰',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Andruid:BAAAKgAECgEIAQAAAA==.Anubis:BAABKgAECn84AAQBAAgIJh9yFAAgAgABAAgIGR5yFAAgAgACAAYI1QmyQAC0AAADAAMIHhS6ZgCPAAAAAA==.',Bi='Bigbob:BAAAKgAECgYIBgAAAA==.Bigmimimi:BAAAKgAECgEIAQAAAA==.Bigtop:BAACKgAFFH8FAAIEAAUIWQ3YGADYAAAEAAUIWQ3YGADYAAAqAAQKfxsABAUACAgbFdYaAMkBAAUACAgbFdYaAMkBAAQACAggGbAvAJEBAAYAAQj0AQAAAAAAAAAA.',Co='Colibri:BAAAKgAECggICAAAAA==.',Cy='Cyanripple:BAABKgAECn8WAAMHAAgI6Q/JEABQAQAHAAgI6Q/JEABQAQAIAAQILAdrUgBnAAAAAA==.',De='Deepha:BAACKgAFFH8NAAIJAAUIpiDpDQBsAQAJAAUIpiDpDQBsAQAqAAQKfzcAAwkACAiZJWoJANYCAAkACAiZJWoJANYCAAoAAgg/GNQbAJAAAAAA.',Do='Dominater:BAAAKgAECggICAAAAA==.',Em='Emir:BAAAKgAFFAEIAQAAAA==.',En='Enhancemoffe:BAAAKgAECgcIBwAAAA==.',Fi='Fiona:BAAAKgAFFAQIAgAAAA==.',Fr='Fractal:BAAAKgADCgIIAwAAAA==.',Go='Gotpowerful:BAAAKgAECgEIAQAAAA==.',Gu='Guludodo:BAABKgAECn+CAAIKAAgI+yTEAgDkAgAKAAgI+yTEAgDkAgABKgAFFAgIFAADAHEaAA==.',Je='Jennieiriss:BAAAKgAECggICAAAAA==.Jenniemantra:BAAAKgAFFAYIBAAAAA==.',Ki='Killerdj:BAAAKgADCgcIBwAAAA==.',Ku='Kuisa:BAAAKgADCgMIAwAAAA==.',Le='Legendretur:BAAAKgADCggICAAAAA==.',Li='Lichprince:BAAAKgAFFAYIBAAAAA==.',Ma='Makabaka:BAABKgAECn90AAILAAgI5yXhAAAAAwALAAgI5yXhAAAAAwABKgAFFAgIFAADAHEaAA==.',Ne='Nesevil:BAAAKgAECgUIBQAAAA==.',Ni='Nidhogg:BAAAKgAECgYIBgAAAA==.Nighttime:BAAAKgAECgIIAgAAAA==.',Se='Seraphine:BAAAKgAECgUIBgAAAA==.',Sh='Shakurass:BAAAKgAECgcICQAAAA==.',Sk='Skullpanda:BAABKgAFFH8QAAMMAAYIXCKJDQC0AQAMAAYIfx+JDQC0AQANAAIIXCJwIgBXAAAAAA==.',Th='Thread:BAABKgAFFH8MAAIOAAMIdgt8EwC7AAAOAAMIdgt8EwC7AAAAAA==.',['Vó']='Vóvká:BAAAKgADCgEIAQAAAA==.',Wd='Wdm:BAAAKgAECgQIBAAAAA==.',Xu='Xuxutv:BAABKgAFFH8VAAIPAAYIECC2BwCeAQAPAAYIECC2BwCeAQAAAA==.',Yo='Yoki:BAAAKgAECggIEQAAAA==.',Zx='Zxdfghujio:BAAAKgAECgIIAgAAAA==.',['一个']='一个拉风的人:BAABKgAFFH8GAAIQAAYIoAlUCABpAQAQAAYIoAlUCABpAQAAAA==.',['一之']='一之濑千鹤:BAAAKgAFFAQIBAAAAA==.',['一口']='一口三块肉:BAAAKgAECgMIAwAAAA==.',['一只']='一只大老鼠:BAABKgAECn8aAAQRAAgI0BiiZQAtAQARAAYIhxuiZQAtAQASAAYIeRXFGgDqAAATAAMItBHGWgCmAAAAAA==.一只耳:BAAAKgAFFAEIAQAAAA==.',['一坨']='一坨黄:BAAAKgAECgYIBgAAAA==.',['一粒']='一粒丹丹:BAACKgAFFH8IAAIJAAQIUx/UDgAFAQAJAAQIUx/UDgAFAQAqAAQKfx0AAwkACAhZEhtEAJcBAAkABwjmEhtEAJcBAAoACAgNDg4pADsBAAAA.',['一语']='一语轻尘:BAABKgAECn8sAAIUAAgIsRrcCgArAgAUAAgIsRrcCgArAgAAAA==.',['一边']='一边梦游一边:BAAAKgADCgEIAQAAAA==.一边睡觉一边:BAAAKgADCgIIAgAAAA==.',['一醉']='一醉浮生:BAAAKgAECgQIBAAAAA==.',['一零']='一零五四四:BAAAKgAFFAQIBAAAAA==.',['三只']='三只小熊:BAAAKgAECggIEAAAAA==.',['不吃']='不吃饭的胖琪:BAAAKgADCgYIBgAAAA==.',['不拉']='不拉糖的老六:BAAAKgAFFAEIAQAAAA==.',['不死']='不死战神:BAAAKgADCgMIAwAAAA==.',['世界']='世界之灾:BAAAKgAFFAEIAQAAAA==.',['两仪']='两仪丶式:BAAAKgADCgEIAQAAAA==.',['丨愈']='丨愈殇丶:BAACKgAFFH8IAAIRAAgIxQ1oCQAEAgARAAgIxQ1oCQAEAgAqAAQKfxQAAhMABgjSG8AiAIgBABMABgjSG8AiAIgBAAAA.',['丨波']='丨波波丨:BAAAKgAECgYIBgAAAA==.',['丨絡']='丨絡乄鐷丨:BAAAKgAECgQIBAAAAA==.',['临风']='临风:BAAAKgAFFAMIBAAAAA==.临风灬:BAACKgAFFH8LAAIPAAMIERnBKQDPAAAPAAMIERnBKQDPAAAqAAQKfx8AAg8ACAi4G5ccABwCAA8ACAi4G5ccABwCAAAA.',['丶也']='丶也許壹天:BAABKgAFFH8GAAIVAAYIJBJkEABnAQAVAAYIJBJkEABnAQAAAA==.',['丶永']='丶永恒守护:BAAAKgAECggICAAAAA==.',['丶轩']='丶轩辕凝听丶:BAABKgAFFH8GAAMBAAYIwhFlGQDtAAABAAUIZBJlGQDtAAACAAEIdgtxLABCAAAAAA==.',['丶麦']='丶麦兜小铃铛:BAAAKgAFFAIIAgAAAA==.',['丸子']='丸子烧饼:BAACKgAFFH8hAAQWAAYIBRYLHwB0AQAWAAYIBRYLHwB0AQAXAAMIYRDJFgB/AAAYAAEIHQX8LgAaAAAqAAQKf0EABBYACAgPIh81ACsCABYACAgPIh81ACsCABcACAjXEFgiAE0BABgAAQjaBMZoABMAAAAA.',['丿怒']='丿怒丶风灬:BAAAKgADCggICgAAAA==.',['丿瑞']='丿瑞二喵:BAAAKgAFFAIIAgAAAA==.',['乄絯']='乄絯孑氣灬:BAAAKgAECgYIBwAAAA==.',['九紫']='九紫离火:BAABKgAFFH8SAAIZAAMIshFRCQDUAAAZAAMIshFRCQDUAAAAAA==.',['九老']='九老:BAAAKgAECgYIDwAAAA==.',['二队']='二队的奶德:BAAAKgAECgYIBwAAAA==.',['五分']='五分熟烤生牛:BAABKgAFFH8GAAIQAAYI8w8iDwBfAQAQAAYI8w8iDwBfAQAAAA==.',['五行']='五行还缺德:BAAAKgAECgYIBgAAAA==.五行还缺水:BAAAKgAECggICAAAAA==.五行还缺火:BAAAKgADCggICAAAAA==.',['亚洲']='亚洲图片:BAAAKgAECgcIBwAAAA==.',['人字']='人字拖大背头:BAAAKgAECgMIAwAAAA==.',['今晚']='今晚打老虎:BAABKgAFFH8HAAMaAAMIHhA5PwChAAAaAAMIMwo5PwChAAAbAAIIFBBEHwB6AAAAAA==.',['仰望']='仰望丶天空:BAAAKgADCggICAAAAA==.',['伊德']='伊德莉拉:BAAAKgAECgYICgAAAA==.',['会飞']='会飞的蛋壳:BAAAKgADCggICAAAAA==.',['余生']='余生九分甜:BAABKgAFFH8OAAMSAAMIRhoZBAAKAQASAAMIRhoZBAAKAQARAAMIMgZWRQCZAAAAAA==.',['你别']='你别叫:BAAAKgAFFAEIAQAAAA==.',['你的']='你的宽容:BAAAKgADCggICAAAAA==.',['兜兜']='兜兜里有奶瓶:BAAAKgAECgUIBgAAAA==.',['六弑']='六弑荒魔:BAAAKgADCggICAAAAA==.',['兽耳']='兽耳娘:BAAAKgADCgYIBgAAAA==.',['冬冬']='冬冬哐当哐当:BAABKgAECn94AAMcAAgI8CNzAwDRAgAcAAgI8CNzAwDRAgAZAAgIxRVnCwDsAQABKgAFFAgIFAADAHEaAA==.冬冬玛卡巴卡:BAAAKgADCgEIAQAAAA==.',['冬虫']='冬虫夏草:BAAAKgAECgYICQABKgAFFAgIFAADAHEaAA==.',['冰哥']='冰哥圣手:BAABKgAFFH8RAAIXAAMIYw2AEgCsAAAXAAMIYw2AEgCsAAAAAA==.',['冰火']='冰火主宰:BAAAKgADCggICAAAAA==.',['冲锋']='冲锋:BAAAKgAECgEIAQAAAA==.',['冷凌']='冷凌霜彡:BAAAKgAECgEIAQAAAA==.',['冻住']='冻住丶不许跑:BAAAKgAFFAIIAgAAAA==.',['凤凰']='凤凰飛飛:BAABKgAFFH8OAAIdAAYIFxYeCAAkAQAdAAYIFxYeCAAkAQAAAA==.',['力道']='力道大尼:BAAAKgAECgYIBgABKgAFFAgIDwADAM4XAA==.',['加尔']='加尔鲁仟:BAAAKgADCggICAAAAA==.',['十三']='十三刺:BAAAKgADCgEIAQAAAA==.十三嗜:BAAAKgAECggIDwAAAA==.十三姨:BAAAKgAECgEIAQAAAA==.十三影:BAABKgAECn8oAAMKAAgINRrDFwDQAQAKAAgIWxnDFwDQAQAJAAgIIBUDMwCQAQAAAA==.十三次:BAAAKgAECgUIBQAAAA==.十三法:BAAAKgAECgcICwAAAA==.十三龍:BAAAKgAECggICwAAAA==.',['午夜']='午夜徒夫:BAABKgAFFH8GAAIcAAYImAaNGgDNAAAcAAYImAaNGgDNAAAAAA==.',['午後']='午後方豆腐:BAABKgAFFH8GAAIdAAYI+ySyBgAAAgAdAAYI+ySyBgAAAgAAAA==.',['半图']='半图:BAAAKgAFFAIIAgAAAA==.',['卖小']='卖小孩的火柴:BAABKgAECn8YAAIeAAgIxhNtKAB2AQAeAAgIxhNtKAB2AQAAAA==.',['卖火']='卖火孩的柴:BAAAKgAECgEIAQAAAA==.',['南飞']='南飞的雁:BAAAKgAECgcICgAAAA==.',['双子']='双子座:BAAAKgAECgcIBwAAAA==.',['只想']='只想加血:BAAAKgAECggICAAAAA==.',['叭叭']='叭叭菈:BAABKgAECn8WAAQdAAgINRPMHQACAQAfAAYImRKqNwAJAQAdAAQIUBPMHQACAQAgAAIIqQYhSAA4AAAAAA==.',['右手']='右手很忙:BAABKgAECn8sAAIMAAgISBicGADhAQAMAAgISBicGADhAQAAAA==.',['叽里']='叽里咕噜冬冬:BAABKgAECn8ZAQMYAAgIISYIAQAIAwAYAAgIISYIAQAIAwAWAAQIeRejugAkAQABKgAFFAgIFAADAHEaAA==.',['同橙']='同橙快递:BAABKgAFFH8GAAIYAAYIcBdxCgBTAQAYAAYIcBdxCgBTAQAAAA==.',['向惡']='向惡勢力低頭:BAAAKgADCggICAAAAA==.',['呆瓜']='呆瓜雪儿丶:BAAAKgAECgQIBAAAAA==.',['咕咕']='咕咕龙:BAAAKgAECgcICgAAAA==.',['咕噜']='咕噜咕噜冬冬:BAABKgAECn8eAAMhAAgIXiHgDQBvAgAhAAgIXiHgDQBvAgAPAAEI5AtYwQAuAAABKgAFFAgIFAADAHEaAA==.咕噜咕噜咚咚:BAACKgAFFH8WAAIDAAUIrh5FAwB1AQADAAUIrh5FAwB1AQAqAAQKf1YABAMACAgvJgcBAAMDAAMACAgvJgcBAAMDAAIACAgoHMwSAAgCAAEAAgj9C6mGAFIAAAEqAAUUCAgUAAMAcRoA.',['咚咚']='咚咚锵锵:BAABKgAECn9YAAIgAAgIKiXQAADyAgAgAAgIKiXQAADyAgABKgAFFAgIFAADAHEaAA==.',['哇偶']='哇偶打得不错:BAAAKgADCgMIAwAAAA==.',['哈色']='哈色特:BAABKgAFFH8GAAIbAAYIuhv0DQB9AQAbAAYIuhv0DQB9AQAAAA==.',['哒卜']='哒卜溜:BAAAKgAECggIEQAAAA==.',['唔西']='唔西迪西咚咚:BAABKgAECn8oAAIYAAgI0xx+BABIAgAYAAgI0xx+BABIAgAAAA==.',['喝三']='喝三鹿的猫:BAAAKgAECggICAAAAA==.',['喵莫']='喵莫斯喵:BAAAKgAFFAMIAwAAAA==.',['回收']='回收废旧电瓶:BAAAKgAECggIEAABKgAFFAgICQAPAKUYAA==.',['园园']='园园酱丶:BAABKgAFFH8FAAIbAAQIpCG9BgARAQAbAAQIpCG9BgARAQAAAA==.',['国服']='国服小骑士丶:BAABKgAECn8dAAIWAAgIcRs6SQAVAgAWAAgIcRs6SQAVAgAAAA==.',['土怪']='土怪:BAAAKgAECgIIAgAAAA==.',['圣光']='圣光之手:BAAAKgAFFAIIAgAAAA==.圣光背叛了我:BAAAKgAECgUIBwAAAA==.圣光跳:BAABKgAFFH8FAAIWAAUIChePLQAxAQAWAAUIChePLQAxAQAAAA==.圣光陶洛斯:BAABKgAFFH8KAAIWAAYIZRHsKABEAQAWAAYIZRHsKABEAQAAAA==.',['地主']='地主:BAAAKgAECgIIAgAAAA==.',['地狱']='地狱狂德:BAAAKgADCggICAAAAA==.',['坠星']='坠星冲:BAAAKgAFFAYIAgAAAA==.',['塞拉']='塞拉摩的风:BAAAKgAECgYIBwAAAA==.',['壮阳']='壮阳光环:BAAAKgADCgIIAgAAAA==.',['壹八']='壹八七靓仔:BAAAKgAFFAQIBAAAAA==.',['夜喵']='夜喵:BAAAKgAECgIIAgAAAA==.',['夜灬']='夜灬微眠:BAAAKgAFFAMIAwAAAA==.夜灬无眠:BAABKgAFFH8JAAIgAAMI7QJTDABlAAAgAAMI7QJTDABlAAAAAA==.',['大炮']='大炮李兽死骑:BAAAKgAECgIIAgAAAA==.大炮李血灵猎:BAAAKgAECgEIAQAAAA==.',['大神']='大神涼子:BAAAKgADCgcICQAAAA==.大神萨:BAAAKgAECgcICwAAAA==.',['天术']='天术:BAAAKgAECgUIBQAAAA==.',['天道']='天道花憐:BAAAKgAECgQIBAAAAA==.',['头孢']='头孢地尼:BAAAKgADCgEIAQAAAA==.',['奶小']='奶小脾气大:BAABKgAFFH8KAAIDAAYIrBqpAQDAAQADAAYIrBqpAQDAAQAAAA==.',['奶桃']='奶桃:BAAAKgAFFAIIAgAAAA==.',['如霜']='如霜姑娘:BAAAKgAECgIIAgAAAA==.',['如鱼']='如鱼得水:BAABKgAECn8YAAIMAAgIURORLgBZAQAMAAgIURORLgBZAQAAAA==.',['妖娆']='妖娆猛南:BAABKgAFFH8IAAIfAAgIagntAwDwAQAfAAgIagntAwDwAQAAAA==.',['婲婲']='婲婲丶:BAABKgAFFH8GAAIWAAYINQRTNAAYAQAWAAYINQRTNAAYAQAAAA==.',['媲娜']='媲娜妠姌:BAAAKgAECgcICQAAAA==.',['孙菜']='孙菜炖粉条:BAABKgAECn8XAAIiAAgIJBItQgCpAQAiAAgIJBItQgCpAQAAAA==.',['孤独']='孤独与背叛:BAACKgAFFH8TAAMRAAYIfiBrCwDeAQARAAYIfiBrCwDeAQATAAUIGBBJEACyAAAqAAQKfyIAAhEACAiTIgYVAIYCABEACAiTIgYVAIYCAAAA.',['寂寞']='寂寞的床:BAAAKgAECgIIAgAAAA==.',['寂静']='寂静的拖鞋:BAAAKgAECgYIDQAAAA==.寂静的永恒:BAAAKgAECgMIAwAAAA==.',['寒叶']='寒叶孤城:BAAAKgAFFAEIAQAAAA==.',['寒芒']='寒芒一闪:BAAAKgAECgYIBgAAAA==.寒芒壹点:BAAAKgAECgYICQAAAA==.寒芒点点:BAAAKgAECgYICgAAAA==.',['寒蝉']='寒蝉予松:BAABKgAFFH8IAAIRAAgIhg+7LADfAAARAAgIhg+7LADfAAAAAA==.',['小元']='小元:BAAAKgADCgYIBgAAAA==.',['小呀']='小呀小狐狸:BAAAKgAFFAMIAwAAAA==.',['小咪']='小咪:BAAAKgADCgMIAwAAAA==.',['小圆']='小圆:BAAAKgADCggICAAAAA==.',['小小']='小小電萨:BAAAKgAFFAgIAwAAAA==.',['小尛']='小尛仙:BAABKgAECn8WAAQDAAgIuxu6GADUAQADAAcIWhu6GADUAQACAAYIpxGyGQAVAQABAAMIThyDXACkAAAAAA==.',['小林']='小林立奇:BAABKgAFFH8NAAMVAAcIMBxlCgDFAQAVAAYIuh1lCgDFAQAUAAYIehThGADsAAAAAA==.',['小琉']='小琉璃:BAAAKgADCggICAAAAA==.',['小虎']='小虎鲸:BAAAKgAECgYIBgAAAA==.',['小血']='小血僧:BAABKgAECn8dAAIEAAgI+A//PgBGAQAEAAgI+A//PgBGAQAAAA==.',['尖尖']='尖尖的小耳朵:BAABKgAFFH8JAAIbAAQI7hf+EgDHAAAbAAQI7hf+EgDHAAAAAA==.',['山岚']='山岚:BAABKgAFFH8GAAIdAAYI9ApdEQBBAQAdAAYI9ApdEQBBAQAAAA==.',['左手']='左手扶墙:BAABKgAECn86AAMCAAgIrxvZBwA5AgACAAgIrxvZBwA5AgABAAIIywxMegByAAAAAA==.',['巨猫']='巨猫时代:BAABKgAFFH8GAAIJAAYIeQ2xBACUAQAJAAYIeQ2xBACUAQAAAA==.',['布加']='布加迪凯龙:BAAAKgAECggICAABKgAFFAgIBgAZAIMYAA==.',['帕丁']='帕丁变个熊:BAAAKgAECgcIBwAAAA==.',['帮帮']='帮帮硬:BAABKgAECn8gAAQTAAgIshoLEgAWAgATAAgIshoLEgAWAgARAAgIQRUfOADIAQALAAIIQBFsMwBdAAABKgAFFAgICAATAFIeAA==.',['幻影']='幻影:BAAAKgAECgMIAwAAAA==.',['幽冥']='幽冥怒焰:BAAAKgAECgEIAQAAAA==.',['弗雷']='弗雷德尼克:BAAAKgAECgYICAAAAA==.',['彩云']='彩云逐月:BAAAKgAECgYIBgAAAA==.',['彩梅']='彩梅飘飘:BAAAKgADCggICAAAAA==.',['徒劳']='徒劳:BAAAKgAECgIIAgAAAA==.',['德不']='德不倒得了:BAACKgAFFH8aAAMLAAUIJhLUAQAvAQALAAUIJhLUAQAvAQARAAMI7wbYIgChAAAqAAQKfyUAAgsACAiSFZ8MAI0BAAsACAiSFZ8MAI0BAAAA.',['忍者']='忍者神龟:BAAAKgADCggICAAAAA==.',['念念']='念念无畏:BAAAKgAECgMIAwAAAA==.',['恋牧']='恋牧:BAAAKgAECgUIBwAAAA==.',['恶魔']='恶魔灬召唤:BAABKgAFFH8GAAIMAAYIWQu6GQA3AQAMAAYIWQu6GQA3AQAAAA==.',['恼人']='恼人的秋枫:BAAAKgADCgYICgAAAA==.',['悠悠']='悠悠凌波:BAAAKgAECgEIAQAAAA==.',['情绪']='情绪不稳定:BAAAKgAECggIEgAAAA==.',['惦丶']='惦丶念:BAAAKgADCggICAAAAA==.',['想起']='想起你就硬:BAAAKgADCggICAAAAA==.',['懒痒']='懒痒痒:BAABKgAECn8YAAIPAAgIrRT7OACiAQAPAAgIrRT7OACiAQAAAA==.',['我喝']='我喝红牛:BAAAKgADCgEIAQAAAA==.',['我是']='我是小红手:BAABKgAFFH8IAAIiAAQI+BpXJwDxAAAiAAQI+BpXJwDxAAAAAA==.',['我爱']='我爱和平:BAAAKgAECgQIBQAAAA==.',['戒赌']='戒赌者东东:BAABKgAFFH8FAAMQAAMIjgRHIAClAAAQAAMIjgRHIAClAAAjAAEIpwPdEgA8AAAAAA==.戒赌者旭东:BAACKgAFFH8FAAMCAAIIrwQbIABkAAACAAIIrwQbIABkAAADAAEIrwUpKwA4AAAqAAQKfxcAAwIACAjvENMtACMBAAIABwjZDtMtACMBAAMABwhKDStIAPQAAAAA.戒赌者鸭鸭:BAABKgAFFH8MAAIMAAgI/RDTCgDfAQAMAAgI/RDTCgDfAQAAAA==.',['戴斯']='戴斯酱丶:BAAAKgAFFAQIBAAAAA==.',['扎师']='扎师父:BAABKgAFFH8FAAMUAAIIYgSTNQBuAAAUAAIIHASTNQBuAAAVAAIIYAQ1QQBRAAAAAA==.',['打铁']='打铁哥:BAAAKgAECgIIAwAAAA==.',['打麻']='打麻将一洗三:BAAAKgADCgEIAQAAAA==.打麻将从不输:BAAAKgAECgMIBQAAAA==.打麻将最牛:BAAAKgAECgYIBgAAAA==.',['托大']='托大北:BAAAKgADCggICAAAAA==.',['拜山']='拜山华:BAAAKgAFFAQIAQABKgAFFAgICAAWAC8jAA==.',['挽歌']='挽歌:BAACKgAFFH8VAAIiAAMIpyIPHwAmAQAiAAMIpyIPHwAmAQAqAAQKfyAAAiIACAieIpMWAHkCACIACAieIpMWAHkCAAAA.',['撒一']='撒一狗:BAAAKgADCgEIAQAAAA==.',['斩鬼']='斩鬼神:BAAAKgAFFAYIAgAAAA==.',['新名']='新名字:BAAAKgAECgIIAgAAAA==.',['无天']='无天无夜:BAAAKgAECgYIBgAAAA==.',['无敌']='无敌小射手:BAAAKgAECgcICQAAAA==.无敌得小德:BAAAKgAECggICAAAAA==.无敌搓炉石:BAAAKgAFFAMIAwAAAA==.无敌暴龙猫:BAAAKgAECgQIBAAAAA==.',['无矢']='无矢:BAABKgAFFH8SAAIbAAMIQx4zHgABAQAbAAMIQx4zHgABAQAAAA==.',['无赖']='无赖布鲁斯:BAAAKgAECgYIBgAAAA==.',['日下']='日下部加奈:BAAAKgAECgYIBwAAAA==.',['时代']='时代在召唤:BAABKgAFFH8HAAMkAAYIphGqDADEAAAkAAQIvQiqDADEAAAMAAMIrRaDNQCaAAAAAA==.',['星空']='星空落:BAACKgAFFH8KAAIWAAYIMCS7EwC+AQAWAAYIMCS7EwC+AQAqAAQKfxUAAhYACAgAHec7ADsCABYACAgAHec7ADsCAAAA.',['星鳗']='星鳗天妇罗:BAABKgAFFH8IAAIPAAYIwRTSAQCMAQAPAAYIwRTSAQCMAQAAAA==.',['是我']='是我冒饭了:BAABKgAECn8cAAIWAAgIYxkgUgD9AQAWAAgIYxkgUgD9AQAAAA==.',['是觉']='是觉觉呀:BAAAKgAFFAYIAgAAAA==.',['普拉']='普拉:BAAAKgAFFAYIAQAAAA==.',['暗夜']='暗夜断箭:BAABKgAFFH8IAAIJAAgI6hZfBgA9AgAJAAgI6hZfBgA9AgAAAA==.',['暴躁']='暴躁灬語小轩:BAAAKgAECgIIAgAAAA==.',['曜石']='曜石:BAAAKgAFFAIIAgAAAA==.',['曼陀']='曼陀罗夜来袭:BAAAKgAECgQIBAAAAA==.',['木然']='木然唱和:BAAAKgADCggICAAAAA==.',['朱砂']='朱砂痣:BAABKgAFFH8GAAMlAAMI+A7MBQC7AAAlAAMI+A7MBQC7AAAQAAMIOwcfHwCwAAAAAA==.',['机甲']='机甲锅包肉:BAAAKgADCgMIAwAAAA==.',['来生']='来生泪:BAAAKgADCggICAAAAA==.',['杰灬']='杰灬小克:BAAAKgAECgIIAgAAAA==.',['果家']='果家的胡萝卜:BAAAKgAECgcIBwAAAA==.',['柔太']='柔太柔:BAAAKgADCgIIAgAAAA==.',['格兰']='格兰玛格:BAAAKgADCgMIAwAAAA==.',['梦玲']='梦玲珑:BAAAKgAECgYIBgAAAA==.',['梦魇']='梦魇丶躺尸侠:BAACKgAFFH8OAAQNAAgIOx4nAwBKAQANAAUI1SInAwBKAQAkAAQIXxl2BgD2AAAMAAUIUxHzJADhAAAqAAQKfx4ABAwACAjOG8AtALwBAAwABwhlHMAtALwBAA0ABAhhF55IAMIAACQAAQj0CcRDACcAAAAA.',['棒棒']='棒棒打怪兽:BAAAKgADCgQIBAAAAA==.',['森林']='森林原人:BAABKgAFFH8GAAMaAAYIZhrsEAAJAQAaAAQIpxvsEAAJAQAbAAIIhRggFgCxAAABKgAFFAgIHAAVAPgfAA==.',['椰丝']='椰丝觅洛:BAAAKgAECggICAAAAA==.',['武安']='武安君:BAABKgAFFH8KAAMbAAYIXBMIFQA7AQAbAAYIpBIIFQA7AQAaAAQIoQuNPgCkAAAAAA==.',['死之']='死之骑:BAAAKgAECgMIAwAAAA==.',['死骑']='死骑丶張学友:BAAAKgAFFAIIAgAAAA==.死骑士:BAAAKgAECggIEQAAAA==.',['水薄']='水薄诸流:BAAAKgAECgYIBgAAAA==.',['永恒']='永恒守护丨:BAAAKgADCggICAAAAA==.永恒的瞬间:BAABKgAFFH8KAAMFAAYIzw1RCwDjAAAFAAQIlxJRCwDjAAAEAAYIEgkzHQC2AAAAAA==.',['江小']='江小帅:BAAAKgAFFAYIBAAAAA==.',['江洋']='江洋小盗:BAABKgAFFH8IAAIlAAMI3wujBAC1AAAlAAMI3wujBAC1AAAAAA==.',['江湖']='江湖淡定熊:BAAAKgADCgIIAgAAAA==.',['汤卟']='汤卟哩卟咚咚:BAABKgAECn9LAAIGAAgIviC4AgCWAgAGAAgIviC4AgCWAgABKgAFFAgIFAADAHEaAA==.',['沫羽']='沫羽儿:BAAAKgAFFAQIBAAAAA==.',['油泼']='油泼辣子:BAABKgAFFH8GAAIaAAYIUCBuCwC4AQAaAAYIUCBuCwC4AQAAAA==.',['浅浅']='浅浅初荷嵐:BAAAKgAECgcIDwAAAA==.',['浪人']='浪人丶丶:BAAAKgAECgEIAQAAAA==.',['淇哥']='淇哥:BAAAKgAECgEIAQAAAA==.',['清欢']='清欢:BAABKgAFFH8PAAIWAAMIfR3qPQD4AAAWAAMIfR3qPQD4AAAAAA==.',['灬我']='灬我是传奇:BAACKgAFFH8PAAIdAAMIowwFIwDHAAAdAAMIowwFIwDHAAAqAAQKf0kAAx0ACAhaH/wEAIoCAB0ACAhaH/wEAIoCACAAAwiUDDAbAHkAAAAA.',['灬铁']='灬铁铁灬:BAAAKgAECgcIEQAAAA==.',['灰暗']='灰暗信仰:BAAAKgAECgMIBQAAAA==.',['灵动']='灵动哈哈:BAAAKgAFFAIIAgAAAA==.',['灵魂']='灵魂流浪:BAAAKgADCggIEAAAAA==.',['烟小']='烟小雨:BAAAKgAFFAQIBAAAAA==.',['焚冰']='焚冰无烬:BAAAKgAECgEIAQAAAA==.',['無丨']='無丨敵:BAABKgAFFH8IAAIWAAgIWhxpBQB6AgAWAAgIWhxpBQB6AgAAAA==.',['熊抓']='熊抓鱼么:BAABKgAECn8UAAMFAAgIxiFZDQCAAgAFAAgIxiFZDQCAAgAGAAYIFhKRGADAAAABKgAFFAgIAgAVAAIWAA==.',['熊煞']='熊煞:BAAAKgADCggICAAAAA==.',['爽脆']='爽脆牛肉丝:BAAAKgAFFAIIAgAAAA==.',['牙先']='牙先着地:BAAAKgAECgMIAwAAAA==.',['牛克']='牛克萨司:BAAAKgAECgMIAwAAAA==.',['牛牛']='牛牛两只角:BAABKgAFFH8NAAIPAAMIpB29IAD2AAAPAAMIpB29IAD2AAAAAA==.',['狂奔']='狂奔的圣骑:BAACKgAFFH8FAAIWAAIIpBZ7MwCkAAAWAAIIpBZ7MwCkAAAqAAQKfx0AAhYACAhcILMzAFUCABYACAhcILMzAFUCAAAA.狂奔的戰牛:BAACKgAFFH8PAAIfAAQIFRf1FgDPAAAfAAQIFRf1FgDPAAAqAAQKfyMAAx8ACAg2I94GAKMCAB8ACAiHIt4GAKMCAB0ACAgHHrcgABUCAAAA.狂奔的猎手:BAAAKgAECggIDwAAAA==.狂奔的骑士:BAACKgAFFH8FAAIiAAII6w6fJACUAAAiAAII6w6fJACUAAAqAAQKfyUAAiIACAgnH0wjADECACIACAgnH0wjADECAAAA.',['猎骨']='猎骨者巴托:BAABKgAFFH8IAAIbAAQIMxctDgDhAAAbAAQIMxctDgDhAAAAAA==.',['猪野']='猪野狂瓜:BAAAKgAFFAIIAgABKgAFFAYIAgAmAAAAAA==.',['獵影']='獵影丶獨行:BAAAKgAFFAQIAgAAAA==.',['瑶瑶']='瑶瑶吖:BAAAKgAECgEIAQAAAA==.瑶瑶吖丶:BAAAKgAECggICAAAAA==.',['瓦利']='瓦利安:BAABKgAFFH8IAAIfAAgISxe/AgBKAgAfAAgISxe/AgBKAgAAAA==.',['疯丶']='疯丶小布:BAAAKgAFFAQIBAAAAA==.',['疯狂']='疯狂的红包:BAAAKgAECgMIAwAAAA==.',['白月']='白月光:BAABKgAFFH8IAAMeAAMIjw8UGAC1AAAeAAMIjw8UGAC1AAAVAAEI3AgDRgA6AAAAAA==.',['白牛']='白牛裂魂:BAAAKgAECgYICAAAAA==.',['白玉']='白玉老虎:BAAAKgAECgYIBgAAAA==.',['白色']='白色黑裤衩:BAAAKgAECggIBwAAAA==.',['白酒']='白酒一斤半:BAAAKgAFFAIIBAAAAA==.',['皓月']='皓月下的玫瑰:BAABKgAFFH8MAAIZAAMIRxK2CADdAAAZAAMIRxK2CADdAAAAAA==.',['相濡']='相濡以沫:BAABKgAFFH8HAAIUAAQI2wthIgDNAAAUAAQI2wthIgDNAAAAAA==.',['看来']='看来都是风景:BAABKgAFFH8OAAIWAAMIIRsKQgDsAAAWAAMIIRsKQgDsAAAAAA==.',['眼里']='眼里充满怒火:BAAAKgADCggICAAAAA==.',['砍人']='砍人的人:BAACKgAFFH8SAAIdAAYIYSY9BgANAgAdAAYIYSY9BgANAgAqAAQKfxwAAh0ACAhZHbkRAE8CAB0ACAhZHbkRAE8CAAAA.',['砥火']='砥火:BAAAKgADCggICAAAAA==.',['神丨']='神丨龙:BAACKgAFFH8ZAAMTAAMIIBTJDQCyAAATAAMIIBTJDQCyAAARAAMIhgf+IgCgAAAqAAQKfzUABBMACAhbHvULAFkCABMACAhbHvULAFkCABEACAh8F4kUALwBAAsACAhjCT0lAL4AAAAA.',['神偷']='神偷小颂可:BAABKgAFFH8LAAIlAAQIzCJbAwABAQAlAAQIzCJbAwABAQABKgAFFAYIAgAmAAAAAA==.',['神帝']='神帝:BAAAKgAECggIDwABKgAFFAgIAgAVAAIWAA==.',['神选']='神选小颂可:BAAAKgAFFAEIAQAAAA==.',['离开']='离开离开:BAAAKgAECgIIAgAAAA==.',['秋天']='秋天色糖果:BAABKgAECn8lAAMaAAgIjh8VJQAjAgAaAAgIjh8VJQAjAgAbAAgI6RU4LACJAQAAAA==.',['空想']='空想家:BAAAKgAECgcIBwAAAA==.',['立地']='立地叉棍:BAAAKgAFFAEIAQAAAA==.',['笑嘻']='笑嘻嘻骑士:BAAAKgAECgYICAAAAA==.',['笑放']='笑放花千素:BAAAKgAECgMIAwAAAA==.',['第七']='第七夜章:BAABKgAFFH8GAAIaAAYIKhv/EABwAQAaAAYIKhv/EABwAQABKgAFFAgIFgAdANkUAA==.第七狩魂:BAABKgAFFH8GAAIaAAYIOSGwCwC0AQAaAAYIOSGwCwC0AQAAAA==.',['等等']='等等:BAAAKgADCgEIAQAAAA==.',['筱莜']='筱莜丶:BAAAKgAECggICAAAAA==.',['箴言']='箴言术:BAAAKgAFFAIIAgAAAA==.',['米斯']='米斯塔奎恩:BAABKgAFFH8IAAIIAAgIzRBhCAD4AQAIAAgIzRBhCAD4AQAAAA==.',['粉嫩']='粉嫩豆腐:BAABKgAFFH8GAAIWAAYIZR6mFwCfAQAWAAYIZR6mFwCfAQAAAA==.',['粉粉']='粉粉的烧饼:BAAAKgAECgUIBgAAAA==.',['精彩']='精彩必将继续:BAABKgAFFH8FAAIPAAIIhheSHgCgAAAPAAIIhheSHgCgAAAAAA==.',['糖藏']='糖藏蛮娜:BAAAKgAFFAYIAgAAAA==.',['索克']='索克萨丶尔:BAAAKgAECgIIAgAAAA==.',['索大']='索大师:BAAAKgAECgQIBAAAAA==.',['索菲']='索菲亚的复苏:BAAAKgAECgUIBQAAAA==.',['紫翼']='紫翼魅影:BAAAKgADCgcICQAAAA==.',['红色']='红色体育生:BAAAKgAECggIEAAAAA==.',['纯粹']='纯粹乐乐:BAAAKgAECgEIAQAAAA==.',['终末']='终末之冬:BAAAKgAECgUIBQAAAA==.终末之战:BAAAKgAECgQIBgAAAA==.',['羋黄']='羋黄龍:BAAAKgAECgYICQAAAA==.',['美女']='美女上车吗:BAABKgAFFH8FAAIVAAUIZRbXCwCrAQAVAAUIZRbXCwCrAQAAAA==.',['老年']='老年玩家丶:BAABKgAFFH8KAAIiAAYImRe+EQCMAQAiAAYImRe+EQCMAQAAAA==.',['肉粽']='肉粽子:BAAAKgAECgUIBQAAAA==.',['肥肠']='肥肠侠:BAABKgAECn8aAAMVAAgIoxwYFQBLAgAVAAgIoxwYFQBLAgAUAAgINRTxPACcAQAAAA==.',['航海']='航海家:BAAAKgAECgcIBwAAAA==.',['艾俄']='艾俄洛迪斯:BAAAKgADCgQIBAAAAA==.',['花会']='花会长:BAABKgAFFH8KAAIcAAQInBaFIABcAAAcAAQInBaFIABcAAABKgAFFAgIGwAcAFweAA==.',['花哭']='花哭花瓣飞:BAAAKgAECggICAAAAA==.',['花谢']='花谢为谁悲:BAAAKgAECgMIAwAAAA==.',['苏豆']='苏豆蔻:BAAAKgAECgEIAQAAAA==.',['茄子']='茄子蓝莓烧饼:BAAAKgAFFAMIAwAAAA==.',['草莓']='草莓圣代:BAAAKgAFFAYIAwAAAA==.草莓布丁:BAAAKgAFFAYIAgAAAA==.',['莳緔']='莳緔的狂霸:BAAAKgADCgIIAgAAAA==.',['莳绱']='莳绱的調調:BAAAKgAECgUICAAAAA==.',['莼白']='莼白牛奶:BAABKgAECn8WAAIPAAgIRBnsJADvAQAPAAgIRBnsJADvAQAAAA==.',['菜鸟']='菜鸟保护期:BAAAKgAECgEIAQAAAA==.',['萌乄']='萌乄哒哒的牛:BAAAKgAECgIIAgAAAA==.',['萨小']='萨小满:BAAAKgAECgEIAQAAAA==.',['虫虫']='虫虫不吃菜:BAAAKgADCgcICgAAAA==.',['虾我']='虾我连奶:BAAAKgAFFAIIAgAAAA==.',['蛋刀']='蛋刀侠:BAAAKgAECgMIAwAAAA==.',['蜥蜴']='蜥蜴你妹:BAAAKgADCggICAAAAA==.',['血之']='血之梦梦:BAAAKgAECgUIBgAAAA==.',['血兽']='血兽爱我:BAABKgAFFH8lAAMiAAYIAiFlDADJAQAiAAYI+CBlDADJAQAcAAYIyhiEBQB8AQABKgAFFAgICgAiAK0dAA==.',['血夜']='血夜漂香:BAAAKgAFFAIIBAAAAA==.',['血翼']='血翼魅影:BAAAKgADCgQIBAAAAA==.',['西宫']='西宫雪儿:BAABKgAFFH8FAAIBAAIIgBTJGgB8AAABAAIIgBTJGgB8AAAAAA==.',['触龙']='触龙神:BAAAKgAECgYIDgAAAA==.',['诺和']='诺和橙子爸爸:BAAAKgAECgIIAgAAAA==.',['贝贝']='贝贝叽:BAAAKgAECgEIAQAAAA==.',['贪狼']='贪狼廉贞:BAAAKgADCgEIAQAAAA==.',['贾嘉']='贾嘉佳:BAAAKgAECggICAAAAA==.',['赤之']='赤之新月:BAAAKgAECgUIBQAAAA==.',['赤月']='赤月:BAABKgAFFH8FAAIdAAUI/QlQFAAdAQAdAAUI/QlQFAAdAQAAAA==.',['走慢']='走慢点:BAAAKgADCgEIAQAAAA==.',['超级']='超级无敌转圈:BAAAKgAECggICAAAAA==.',['趴趴']='趴趴:BAAAKgAECgIIAgAAAA==.',['路过']='路过的萨满:BAAAKgAECgEIAQAAAA==.',['辛德']='辛德维拉:BAABKgAECn8ZAAIMAAgI4RZFHQC9AQAMAAgI4RZFHQC9AQAAAA==.',['过来']='过来叔叔抱抱:BAABKgAFFH8GAAIWAAYIqRu2FAC2AQAWAAYIqRu2FAC2AQAAAA==.',['迷途']='迷途小浣熊:BAAAKgAECgYIBgAAAA==.',['逆我']='逆我者丨羊:BAABKgAFFH8IAAIUAAgILhAHBgAMAgAUAAgILhAHBgAMAgAAAA==.',['遗失']='遗失的殇:BAAAKgADCgQIBAAAAA==.',['遗忘']='遗忘的忧伤:BAAAKgAECggIBwAAAA==.遗忘的悲伤:BAAAKgAFFAMIBAAAAA==.遗忘的童年:BAACKgAFFH8cAAQPAAgIOgp6IgDuAAAPAAQISQJ6IgDuAAAhAAQImgaFEACbAAAOAAIIZQQzGwBpAAAqAAQKfyEABA4ACAg3FE4dAGgBAA4ABwjZE04dAGgBACEABwgiD6JSALIAAA8ABAjMFfMyALIAAAAA.',['那个']='那个二彼:BAAAKgADCggIEwAAAA==.',['都敏']='都敏俊丶:BAABKgAFFH8IAAIWAAgIXBvGBwBIAgAWAAgIXBvGBwBIAgAAAA==.',['酒一']='酒一笑:BAAAKgADCggICAAAAA==.',['酒醒']='酒醒香满怀:BAACKgAFFH8lAAIWAAcIOSJdBACUAgAWAAcIOSJdBACUAgAqAAQKfz4AAhYACAgyJeUNAOECABYACAgyJeUNAOECAAAA.',['酥嘎']='酥嘎带笛:BAAAKgAECggICAAAAA==.',['酷酷']='酷酷的小骑士:BAAAKgAECgQIBwAAAA==.',['里尔']='里尔哦:BAABKgAFFH8FAAIaAAIIvwm1OACGAAAaAAIIvwm1OACGAAAAAA==.',['银耳']='银耳薏米羹:BAABKgAFFH8GAAIWAAYIHgaWGQAZAQAWAAYIHgaWGQAZAQAAAA==.',['错过']='错过的星期三:BAABKgAFFH8MAAIPAAgIYRvoAgA5AgAPAAgIYRvoAgA5AgAAAA==.',['锦衣']='锦衣:BAAAKgADCgIIAgAAAA==.',['镜光']='镜光水影:BAAAKgAFFAEIAQAAAA==.',['长的']='长的还不错:BAABKgAFFH8MAAIEAAYINxBVCgApAQAEAAYINxBVCgApAQAAAA==.',['闪电']='闪电帕丁熊:BAABKgAFFH8SAAQhAAYIXBlSAADPAQAhAAYIXBlSAADPAQAPAAQIJRX5EADgAAAOAAQIrBWgEACoAAAAAA==.',['阴阳']='阴阳人啊九:BAAAKgADCggICAAAAA==.',['阿尔']='阿尔圆圆:BAAAKgAECgQIBAAAAA==.',['阿布']='阿布罗蒂:BAAAKgAECgUICAAAAA==.',['陈丶']='陈丶茅台烈酒:BAAAKgAFFAMIAwAAAA==.',['陈醋']='陈醋宝宝:BAAAKgAFFAEIAQAAAA==.陈醋宝贝:BAAAKgAFFAIIAwAAAA==.',['陌路']='陌路丿相逢丶:BAAAKgAECgQIBAAAAA==.',['陳风']='陳风暴劣酒:BAABKgAFFH8FAAIEAAIIOAEjKABRAAAEAAIIOAEjKABRAAAAAA==.',['隆恩']='隆恩丶血蹄:BAABKgAFFH8OAAMaAAYIAxmrFADpAAAaAAQI6hyrFADpAAAbAAUIkg1YIwDiAAAAAA==.',['隐隐']='隐隐作秀:BAAAKgADCggICAAAAA==.',['隔壁']='隔壁来德:BAAAKgAECgcIDAAAAA==.',['雨无']='雨无情:BAABKgAFFH8JAAIdAAMIYQkSFQC9AAAdAAMIYQkSFQC9AAAAAA==.',['雨痕']='雨痕:BAACKgAFFH8RAAIaAAMIVhPMMQDGAAAaAAMIVhPMMQDGAAAqAAQKfxgAAhoACAi6HZ8LAFoCABoACAi6HZ8LAFoCAAAA.',['雨瞳']='雨瞳:BAAAKgADCggIDQAAAA==.',['雪白']='雪白的姑娘:BAABKgAFFH8RAAMZAAMIPxFQCgDOAAAZAAMIPxFQCgDOAAAiAAIIPAPaKwBoAAAAAA==.',['雪雁']='雪雁麒麟:BAAAKgAECgIIAgAAAA==.',['雷电']='雷电法皇永信:BAACKgAFFH9FAAIPAAgIhCQEAwBNAgAPAAgIhCQEAwBNAgAqAAQKfzUAAg8ACAhhJNoJAKcCAA8ACAhhJNoJAKcCAAAA.',['霓虹']='霓虹甜心:BAAAKgAECgQIBAAAAA==.',['颂可']='颂可皮卡丘:BAAAKgAFFAYIAgAAAA==.',['風中']='風中的獸王:BAAAKgAECggIBQAAAA==.',['風谷']='風谷薰:BAAAKgAECgYIBgAAAA==.',['风之']='风之叹息:BAAAKgAFFAQIBAAAAA==.',['风叶']='风叶无痕:BAAAKgAECgYIBwAAAA==.',['风吹']='风吹蛋碎一地:BAAAKgAFFAIIBAAAAA==.',['风由']='风由子:BAAAKgADCggICAAAAA==.',['风诺']='风诺:BAAAKgAECgMIBAAAAA==.',['风高']='风高云淡的秋:BAAAKgADCgcIBwAAAA==.',['飞奔']='飞奔的鱼:BAABKgAECn8XAAMaAAgI4hMNGQC1AQAaAAgI4hMNGQC1AQAbAAYIiA+MIgADAQAAAA==.',['馨神']='馨神龙:BAAAKgAFFAIIAgAAAA==.',['騎猪']='騎猪看夕阳:BAAAKgAECggICQAAAA==.',['骄阳']='骄阳下的玫瑰:BAACKgAFFH8MAAIWAAMInh90GgASAQAWAAMInh90GgASAQAqAAQKfxUAAhYACAgpIaocAJACABYACAgpIaocAJACAAAA.',['鬼雾']='鬼雾妖妖:BAAAKgAECgEIAQAAAA==.',['魌魋']='魌魋:BAAAKgADCgYIBgAAAA==.',['魔翼']='魔翼飛:BAAAKgADCgIIAgAAAA==.',['鱼肠']='鱼肠骑:BAAAKgAECgQIBgAAAA==.',['黢龟']='黢龟的黑头:BAAAKgAFFAEIAQAAAA==.',['黯嘚']='黯嘚识邓:BAABKgAECn8YAAMdAAgIphhSDQDKAQAdAAYI2hhSDQDKAQAfAAcIMhYWLwAaAQAAAA==.',['龙弟']='龙弟弟德:BAABKgAFFH8JAAIRAAUIkxBCJAAIAQARAAUIkxBCJAAIAQAAAA==.',['龙虎']='龙虎铮臣魏征:BAAAKgAFFAQIAgAAAA==.',['龙逆']='龙逆天:BAAAKgAECggICAAAAA==.',['龙飞']='龙飞凤舞:BAABKgAECn8XAAIWAAgIeR23YwCWAQAWAAgIeR23YwCWAQAAAA==.',['龙鹤']='龙鹤双形:BAAAKgAFFAUIAQABKgAFFAgIDgAiAA8XAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end