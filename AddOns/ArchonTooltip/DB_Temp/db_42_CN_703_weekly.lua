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
 local lookup = {'Warlock-Demonology','Warlock-Destruction','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','DeathKnight-Blood','Warlock-Affliction','Hunter-Marksmanship','Hunter-BeastMastery','Evoker-Devastation','Paladin-Retribution','Mage-Fire','Mage-Arcane','Shaman-Restoration','Priest-Discipline','DemonHunter-Havoc','Mage-Frost','Warrior-Arms','Hunter-Survival','Priest-Shadow','Priest-Holy','Shaman-Enhancement','Rogue-Assassination','DeathKnight-Unholy','DeathKnight-Frost','Paladin-Protection','Druid-Restoration','DemonHunter-Vengeance','Paladin-Holy','Druid-Balance','Unknown-Unknown','Warrior-Fury','Warrior-Protection','Shaman-Elemental','Rogue-Subtlety','Druid-Feral','Druid-Guardian','Evoker-Preservation',}; local provider = {region='CN',realm='暗影议会',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alexandr:BAAAKgAECgUIBQAAAA==.',An='Andreax:BAABKgAECn8eAAMBAAgIFRgOEgDtAQABAAgINhcOEgDtAQACAAMIqhXeawB9AAAAAA==.',Ao='Aomu:BAAAKgAECgYICQAAAA==.',At='Athlan:BAAAKgAECgQIBAAAAA==.',Az='Azedlol:BAAAKgAFFAUIAgAAAA==.Azmodanlol:BAABKgAFFH8IAAICAAQI1wdVHQCYAAACAAQI1wdVHQCYAAAAAA==.',Bu='Bunny:BAACKgAFFH8LAAQDAAMI2QfRBwBlAAADAAMI2QfRBwBlAAAEAAII0gFzJABAAAAFAAEISgDCNgATAAAqAAQKfxUABAMACAjADdAPADABAAMACAjADdAPADABAAUABAhlBJBVAGcAAAQABAiZBE52ADkAAAEqAAUUBAgJAAYAgAQA.',Ch='Chernobog:BAAAKgAFFAgIBAAAAA==.',Cr='Crash:BAAAKgAFFAgIBAAAAA==.Crushé:BAABKgAECn8ZAAMCAAgIhhdEHQC9AQACAAcIbxlEHQC9AQAHAAEIFQwLQwApAAAAAA==.',Ct='Ctr:BAABKgAFFH8IAAMIAAMIkw1tMgCnAAAIAAMIkw1tMgCnAAAJAAEI/gJwZQAeAAAAAA==.',Da='Darksoul:BAABKgAFFH8IAAIKAAQIvSOpEwA0AQAKAAQIvSOpEwA0AQAAAA==.',De='Delu:BAAAKgAECggICAAAAA==.Devilgui:BAAAKgAFFAYIAQAAAA==.',Dr='Drevival:BAAAKgAFFAYIBAAAAA==.',Du='Dusttodust:BAACKgAFFH8RAAILAAYIsiJWFQCxAQALAAYIsiJWFQCxAQAqAAQKfyUAAgsACAg9Iq4eAIgCAAsACAg9Iq4eAIgCAAAA.',Ei='Eillenials:BAABKgAFFH8NAAMMAAUI+xrwBwCFAQAMAAUI+xrwBwCFAQANAAQI+xmqJgDHAAAAAA==.',El='Elfshooter:BAAAKgAECggICgAAAA==.',Em='Embershorer:BAABKgAFFH8WAAICAAgIVhg3BABFAgACAAgIVhg3BABFAgAAAA==.',Eu='Eurus:BAAAKgADCgYIBgAAAA==.',Ev='Evergrand:BAABKgAECn8lAAIOAAgIriOZCACxAgAOAAgIriOZCACxAgABKgAFFAgICgAPAEUdAA==.',Fa='Fallenember:BAABKgAFFH8KAAIQAAgIuh53BACEAgAQAAgIuh53BACEAgAAAA==.',Go='Gothicmean:BAAAKgAECgUIBQAAAA==.',Ha='Harrypoter:BAAAKgAECggIDgAAAA==.',Is='Issicc:BAAAKgAECgIIAgAAAA==.',It='Iteyo:BAAAKgAECgIIAgAAAA==.',Jh='Jhmn:BAAAKgAECgEIAgAAAA==.',Ju='Justcc:BAABKgAFFH8QAAIRAAMIwxE8GAC0AAARAAMIwxE8GAC0AAAAAA==.',Ka='Kaoruseki:BAAAKgAECgMIAwAAAA==.',Ku='Kucy:BAAAKgADCgQIBAAAAA==.',Li='Links:BAAAKgAFFAIIBAAAAA==.',Ma='Marcovaldo:BAACKgAFFH8fAAISAAcIzCROAgBoAgASAAcIzCROAgBoAgAqAAQKfy4AAhIACAhzJV8DAN4CABIACAhzJV8DAN4CAAAA.',Me='Mercuryx:BAABKgAFFH8FAAIFAAUIZRQ5FgDIAAAFAAUIZRQ5FgDIAAAAAA==.',Mi='Milo:BAAAKgAECgUIEAAAAA==.Mines:BAAAKgAECgYIBgAAAA==.',My='Mystery:BAAAKgAECgQIBAAAAA==.',Nv='Nv:BAAAKgAECgIIAgAAAA==.',Ob='Obsessional:BAAAKgADCgIIAgAAAA==.',Oo='Oosullivan:BAABKgAECn8wAAQIAAcI6htzKQDCAQAIAAcI6htzKQDCAQAJAAYIkhaKfABAAQATAAIIyREmFQBoAAAAAA==.',Pi='Pietruccio:BAAAKgADCgMIAwAAAA==.',Pr='Professorfk:BAAAKgAECggICgAAAA==.',Ra='Ragehorn:BAAAKgAECgYIBgAAAA==.',Sa='Samamomo:BAAAKgAECggICAAAAA==.Sargerasi:BAAAKgAECggIEgAAAA==.',Sc='Scared:BAABKgAFFH8QAAQUAAYIjxnEBwCXAQAUAAYIjxnEBwCXAQAVAAUIZBQyGAD1AAAPAAQIWRnECQDdAAAAAA==.Scotte:BAAAKgAECgMIAwAAAA==.',Sh='Sheldor:BAAAKgAECggICAAAAA==.',So='Sobaniteyo:BAAAKgAECgEIAQAAAA==.',Sp='Sphinx:BAAAKgAECgMIAwAAAA==.',St='Stoper:BAABKgAFFH8GAAIGAAYICAjXGQDTAAAGAAYICAjXGQDTAAAAAA==.Stribog:BAABKgAFFH8KAAIWAAgIWBpGBQDBAQAWAAgIWBpGBQDBAQAAAA==.',Te='Terrylau:BAACKgAFFH8HAAIMAAIIHAcONgBrAAAMAAIIHAcONgBrAAAqAAQKfxwAAgwABggbEoAoAO4AAAwABggbEoAoAO4AAAAA.Terryliu:BAABKgAECn8cAAIRAAgI6R0FEQA/AgARAAgI6R0FEQA/AgAAAA==.',Ti='Tiberius:BAACKgAFFH8NAAIEAAMIow16FgC1AAAEAAMIow16FgC1AAAqAAQKfxwAAgQACAipG3ENAIwBAAQACAipG3ENAIwBAAAA.',Uo='Uomn:BAAAKgAECgMIAwAAAA==.',Vi='Vi:BAAAKgAECgEIAQAAAA==.',['Vá']='Vájra:BAAAKgAFFAYIAgAAAA==.',Wa='Wanan:BAABKgAFFH8GAAILAAYIDxBxNAAYAQALAAYIDxBxNAAYAQAAAA==.',Xe='Xellos:BAAAKgAFFAQIBAAAAA==.',Xm='Xmercury:BAAAKgADCgIIAgAAAA==.',Xx='Xxdxn:BAABKgAFFH8GAAIKAAYIghglDwBtAQAKAAYIghglDwBtAQAAAA==.',Zd='Zdge:BAAAKgAECgEIAQAAAA==.Zdgee:BAAAKgADCggICAAAAA==.',Ze='Zed:BAAAKgAECggICAABKgAFFAgIBQAXALUFAA==.',Zz='Zzluv:BAABKgAFFH8IAAMJAAQIhRwoFwDzAAAJAAQIlBcoFwDzAAAIAAQIyxUVDQDnAAAAAA==.',['一切']='一切都是浮云:BAAAKgADCgIIAwAAAA==.',['一十']='一十一:BAAAKgAECgMIAwAAAA==.',['一生']='一生宠爱:BAAAKgADCggIDQAAAA==.',['一直']='一直很安静永:BAABKgAFFH8GAAILAAYIhw+vJQBSAQALAAYIhw+vJQBSAQAAAA==.',['一萨']='一萨妳荃迦一:BAABKgAFFH8IAAIOAAQIwwe1OgCaAAAOAAQIwwe1OgCaAAAAAA==.',['七月']='七月不喝奶丶:BAAAKgADCgEIAQAAAA==.',['万教']='万教之父:BAAAKgAFFAQIBAAAAA==.',['三千']='三千劫火:BAAAKgAECggIDgAAAA==.',['三葬']='三葬:BAAAKgAECgMIAwAAAA==.',['三鹿']='三鹿奶死你灬:BAAAKgAECggIDgAAAA==.',['不化']='不化骨:BAAAKgAECgMIAwAAAA==.',['不套']='不套盾的萨满:BAAAKgAECgYIBgAAAA==.',['不开']='不开心豆沙了:BAAAKgADCggICAAAAA==.',['不恕']='不恕:BAABKgAFFH8LAAMFAAYIaQifFQDLAAAFAAYIaQifFQDLAAADAAQIdwYAAAAAAAAAAA==.',['东北']='东北虎:BAAAKgAECgMIAwAAAA==.',['严肃']='严肃活泼:BAAAKgAECggICAAAAA==.',['丨若']='丨若丨:BAACKgAFFH8JAAIBAAMI2AezEwClAAABAAMI2AezEwClAAAqAAQKfxUAAgEACAgrEeYgAIYBAAEACAgrEeYgAIYBAAAA.',['丶周']='丶周杰伦丶:BAABKgAFFH8WAAILAAgIgSN6AQDwAgALAAgIgSN6AQDwAgAAAA==.',['丶德']='丶德不常湿:BAAAKgAECggIEgAAAA==.',['丶淘']='丶淘淘:BAABKgAFFH8JAAIOAAMIxQR+PwCKAAAOAAMIxQR+PwCKAAAAAA==.',['丶猎']='丶猎:BAAAKgAECgYIBQAAAA==.',['丽水']='丽水金莎:BAAAKgAECgMIBgAAAA==.',['乂先']='乂先生:BAAAKgAECgQIBAAAAA==.',['么么']='么么羊羊殿:BAACKgAFFH8+AAILAAgIaRyuDQD4AQALAAgIaRyuDQD4AQAqAAQKf0kAAgsACAisJncEAA4DAAsACAisJncEAA4DAAAA.',['九筒']='九筒丶:BAAAKgAECgIIAgAAAA==.',['也是']='也是大起来了:BAAAKgAECgMIAQAAAA==.',['云笙']='云笙:BAAAKgAECgQIBQAAAA==.',['互撸']='互撸寿:BAABKgAFFH8FAAICAAMIiggLMwCjAAACAAMIiggLMwCjAAAAAA==.',['人民']='人民的名义:BAABKgAFFH8GAAIRAAYIgA+tCAA3AQARAAYIgA+tCAA3AQAAAA==.',['今晚']='今晚吃咩餸:BAAAKgAFFAQIBAAAAA==.',['伊人']='伊人在水一方:BAAAKgAFFAMIAwAAAA==.',['伊爾']='伊爾明斯特:BAAAKgAECgQIBQAAAA==.',['伊薇']='伊薇丶缚影者:BAAAKgAECgUIBwAAAA==.',['优菈']='优菈:BAAAKgAFFAEIAQAAAA==.',['你别']='你别怕我:BAABKgAECn8qAAMYAAgIwx01IwAAAgAYAAgIwx01IwAAAgAZAAEI1h2oNAAzAAAAAA==.',['佳莉']='佳莉娅:BAABKgAFFH8GAAIYAAMIzBQELADdAAAYAAMIzBQELADdAAAAAA==.',['俗里']='俗里俗气丶:BAABKgAFFH8HAAIaAAcIMBkEBgDMAQAaAAcIMBkEBgDMAQAAAA==.',['倦意']='倦意濃丶:BAABKgAFFH8IAAIbAAgIFQlXCACFAQAbAAgIFQlXCACFAQAAAA==.',['僾你']='僾你一辈子:BAAAKgAECgIIAgAAAA==.',['儿等']='儿等看好:BAAAKgAECgcICAAAAA==.',['克洛']='克洛诺斯:BAAAKgADCgMIAwAAAA==.',['八十']='八十巴适:BAAAKgAFFAMIAwAAAA==.',['公子']='公子风绝:BAAAKgADCggICAAAAA==.',['养乐']='养乐多丶:BAABKgAFFH8UAAMVAAgIwSKoAwAHAgAVAAcIDiKoAwAHAgAUAAEIEBkIKQBNAAAAAA==.',['冒牌']='冒牌死骑:BAAAKgAECgIIBAAAAA==.',['冠军']='冠军老祖:BAAAKgAECgQIBAAAAA==.',['冰燕']='冰燕麦拿铁:BAAAKgAECgUIBQAAAA==.',['冰霜']='冰霜之力:BAAAKgAFFAIIAgAAAA==.',['凛音']='凛音:BAABKgAFFH8IAAMBAAQI6h45BADzAAAHAAQI6h4hBQADAQABAAQIxBk5BADzAAAAAA==.',['凤凰']='凤凰之涅槃:BAAAKgADCgQIBAAAAA==.',['凯恩']='凯恩日怒:BAABKgAFFH8IAAIcAAQImwhKDQCEAAAcAAQImwhKDQCEAAAAAA==.',['出橙']='出橙萨:BAAAKgAECgcIBwAAAA==.',['出门']='出门一条狗:BAAAKgADCgIIAgAAAA==.',['初夏']='初夏微风:BAAAKgAFFAQIBAABKgAFFAgIEgAPAGQaAA==.',['别看']='别看就是你:BAAAKgADCggICAAAAA==.',['刹那']='刹那永恒丶:BAAAKgAECggICAAAAA==.',['刺猬']='刺猬圣光球:BAAAKgAECggICgABKgAFFAgICgALACQhAA==.',['剑丶']='剑丶来:BAABKgAFFH8FAAILAAUI3yAFJQBWAQALAAUI3yAFJQBWAQAAAA==.',['北风']='北风之刃:BAAAKgAECgYIDQAAAA==.',['十一']='十一一十:BAAAKgAFFAMIAwAAAA==.',['十七']='十七鲸梦:BAABKgAFFH8FAAIMAAUINhw2EgAvAQAMAAUINhw2EgAvAQAAAA==.',['十全']='十全十美:BAAAKgAECgYIBgAAAA==.',['千步']='千步穿杨:BAAAKgAFFAQIBAAAAA==.',['半夜']='半夜恶熊低语:BAAAKgAECgMIBAAAAA==.',['南拳']='南拳拳北腿腿:BAABKgAFFH8NAAIFAAYIAyPlAAAIAgAFAAYIAyPlAAAIAgAAAA==.',['卡尔']='卡尔瓦伊:BAAAKgAECgQIBwAAAA==.',['卡斯']='卡斯兰娜丶蔚:BAAAKgAECgcIBwAAAA==.',['卡迪']='卡迪亚诺:BAAAKgAECgUIBQAAAA==.',['印第']='印第安纳琼斯:BAAAKgAECgQIBAAAAA==.印第安那瓊斯:BAAAKgADCgEIAQAAAA==.',['反射']='反射狐:BAABKgAFFH8KAAMJAAcIwRFZFQBLAQAJAAUIbw9ZFQBLAQAIAAMIORDyLAC3AAAAAA==.',['发飙']='发飙的布尔:BAAAKgAECgUIBQAAAA==.',['史塔']='史塔克艾莉亚:BAAAKgAFFAQIBAAAAA==.',['吉川']='吉川褲浪:BAAAKgAECgIIAgAAAA==.',['吉祥']='吉祥:BAACKgAFFH8HAAIFAAIIPBq0IQCBAAAFAAIIPBq0IQCBAAAqAAQKfxcAAgUABwhoH5IhAH8BAAUABwhoH5IhAH8BAAAA.',['吖丽']='吖丽:BAAAKgAFFAQIAQAAAA==.',['呃咯']='呃咯呃咯黑丶:BAAAKgADCggICAAAAA==.',['呐撸']='呐撸脱:BAAAKgAECgQIBAAAAA==.',['呼叫']='呼叫等待:BAAAKgAECgYIBgAAAA==.',['命里']='命里有橙:BAAAKgAFFAIIAgAAAA==.',['咆哮']='咆哮风俊:BAAAKgADCggICAAAAA==.',['和风']='和风抹茶:BAAAKgADCggICAAAAA==.',['咕尔']='咕尔丹:BAAAKgAECgQIBAAAAA==.',['哈尼']='哈尼射击击:BAAAKgAFFAQIBAAAAA==.',['哈迪']='哈迪斯丶邪骨:BAAAKgAECgQIBAAAAA==.',['哟嚯']='哟嚯:BAAAKgAECgYIBgAAAA==.',['唐宋']='唐宋元明清:BAAAKgAFFAIIAgAAAA==.',['唐李']='唐李白:BAABKgAFFH8GAAIOAAYIxwmWFwAjAQAOAAYIxwmWFwAjAQAAAA==.',['唔该']='唔该晒:BAAAKgAECgMIAwAAAA==.',['喵之']='喵之爱恋:BAAAKgAECgMIBAAAAA==.',['喵喵']='喵喵君:BAABKgAFFH8PAAMIAAYIjx38DACJAQAIAAYIjx38DACJAQAJAAEIAAAAAAAAAAAAAA==.',['噬月']='噬月魔:BAABKgAFFH8LAAIYAAgILyGLAQDRAgAYAAgILyGLAQDRAgAAAA==.',['回忆']='回忆成行:BAAAKgAECgMIAwAAAA==.',['圣光']='圣光忽悠了我:BAAAKgADCggICAAAAA==.圣光打码丶:BAAAKgAECgEIAQAAAA==.圣光的寂寞:BAAAKgAECgIIAgAAAA==.圣光若岚:BAABKgAFFH8GAAILAAYIxgivLAA0AQALAAYIxgivLAA0AQAAAA==.',['圣奇']='圣奇士:BAABKgAFFH8GAAILAAYIZA+6IQBnAQALAAYIZA+6IQBnAQAAAA==.',['圣灬']='圣灬灵:BAABKgAFFH8MAAIdAAMINAoAEgCxAAAdAAMINAoAEgCxAAAAAA==.',['地域']='地域咆哮本人:BAAAKgAECgcIDQAAAA==.',['地魔']='地魔小子:BAAAKgAECggIEwAAAA==.',['基情']='基情在燃烧:BAAAKgAFFAMIBAAAAA==.',['墨曦']='墨曦:BAAAKgAFFAQIBAAAAA==.',['墨茉']='墨茉:BAABKgAFFH8GAAIbAAYIrQ1qEAAcAQAbAAYIrQ1qEAAcAQAAAA==.',['复仇']='复仇焰魂:BAABKgAFFH8GAAIQAAYIlhUuEACFAQAQAAYIlhUuEACFAQAAAA==.',['夏灬']='夏灬迩:BAABKgAFFH8OAAIOAAMIdA/nIwCLAAAOAAMIdA/nIwCLAAAAAA==.',['多喝']='多喝热水谢谢:BAABKgAFFH8SAAIOAAgIeBDrBgDcAQAOAAgIeBDrBgDcAQAAAA==.',['多多']='多多香雪:BAAAKgAECgUIEQAAAA==.',['多拉']='多拉古丶炙热:BAAAKgAECgIIAgAAAA==.',['夜夏']='夜夏鸣泣时:BAAAKgAFFAYIAgAAAA==.',['大佬']='大佬玩小猎:BAAAKgAECgMIAwAAAA==.',['大侠']='大侠不要砍我:BAAAKgADCggICAAAAA==.',['大写']='大写五号:BAAAKgADCggICAAAAA==.',['大明']='大明陳公公:BAABKgAECn8YAAILAAgIqyBcPQA3AgALAAgIqyBcPQA3AgAAAA==.',['大灬']='大灬哥:BAAAKgADCgIIAgAAAA==.',['天之']='天之影:BAABKgAFFH8GAAIPAAYIThHEJABUAAAPAAYIThHEJABUAAAAAA==.',['天津']='天津曲艺家:BAAAKgAECgMIAwAAAA==.',['天涯']='天涯共银辉:BAABKgAFFH8KAAMeAAgIERtJDADRAQAeAAYIEx1JDADRAQAbAAQIZyHWBwCQAQAAAA==.',['天罡']='天罡咆哮:BAAAKgAFFAIIAwAAAA==.天罡芜湖:BAAAKgADCggIDwAAAA==.天罡霏雨:BAAAKgADCgYIBgAAAA==.',['天譴']='天譴之心:BAAAKgADCggIDAAAAA==.',['奥术']='奥术智慧:BAAAKgAECgEIAQABKgAFFAMIBAAfAAAAAA==.',['奥莉']='奥莉薇尔语风:BAAAKgAFFAIIAgAAAA==.',['女萨']='女萨满:BAAAKgAFFAEIAQAAAA==.',['奶牛']='奶牛也有公的:BAAAKgAECgQIBAAAAA==.奶牛咕咕:BAAAKgAECggICAAAAA==.',['奶霸']='奶霸疼你:BAAAKgAECgQIBwAAAA==.',['好好']='好好坏坏:BAAAKgADCgUIBQAAAA==.',['好猫']='好猫:BAABKgAFFH8IAAILAAgI5QVKEgB5AQALAAgI5QVKEgB5AQAAAA==.',['妙趣']='妙趣:BAABKgAECn8pAAISAAgI6SGcBQC3AgASAAgI6SGcBQC3AgAAAA==.',['妲瓦']='妲瓦安娜:BAAAKgAECgEIAQAAAA==.',['姗猪']='姗猪:BAAAKgAECgUIBQAAAA==.',['威震']='威震地:BAAAKgAFFAgIBAAAAA==.',['媛妹']='媛妹:BAABKgAFFH8UAAIQAAMIpxp5IwDtAAAQAAMIpxp5IwDtAAAAAA==.',['宅男']='宅男型男:BAAAKgAECgQIAwAAAA==.',['守护']='守护者:BAAAKgADCggICAAAAA==.',['安久']='安久拉丶後夏:BAAAKgAECgMIAwAAAA==.',['安吉']='安吉麗娜茱莉:BAAAKgAECgQIBAAAAA==.',['安妮']='安妮露娜:BAABKgAFFH8IAAIeAAgIXAgfDQCoAQAeAAgIXAgfDQCoAQAAAA==.',['安德']='安德罗妮:BAAAKgAECgcIBwAAAA==.',['安杰']='安杰利卡语风:BAAAKgAFFAIIAgAAAA==.',['安纳']='安纳塞隆:BAAAKgAFFAQIBAAAAA==.',['宋丶']='宋丶风暴烈酒:BAAAKgADCggICAAAAA==.',['定仙']='定仙游:BAAAKgAECggIDgABKgAFFAMIBQALAOUSAA==.',['宝宝']='宝宝摔倒了:BAAAKgAECggIEQAAAA==.',['富贵']='富贵的布偶:BAAAKgAECgEIAQAAAA==.',['寒蛋']='寒蛋轻抖:BAAAKgAECgQIBwAAAA==.',['小小']='小小陈:BAABKgAFFH8GAAIQAAYIoRZ1EwBeAQAQAAYIoRZ1EwBeAQAAAA==.',['小新']='小新没有蜡笔:BAAAKgADCgQIBAAAAA==.',['小桑']='小桑桑丶:BAAAKgAFFAgIBAAAAA==.',['小牧']='小牧淑:BAAAKgAECgYICQAAAA==.',['小狂']='小狂:BAABKgAFFH8OAAILAAQIcR8DGwANAQALAAQIcR8DGwANAQAAAA==.',['小白']='小白菜丶:BAAAKgAFFAIIAgAAAA==.',['小翠']='小翠西:BAAAKgAFFAEIAQABKgAFFAgIEwAaAA0TAA==.',['小落']='小落与溪流:BAAAKgAECggICAAAAA==.',['小豆']='小豆酱:BAABKgAFFH8IAAIQAAgI0gb8CwCeAQAQAAgI0gb8CwCeAQAAAA==.',['少女']='少女共赴何方:BAACKgAFFH8KAAMCAAYIuRuFHgAUAQACAAUIBh2FHgAUAQABAAEIhhZSJwBKAAAqAAQKfxcAAwIACAjRHVYTAFECAAIACAjRHVYTAFECAAcAAgjEDWI1AHEAAAAA.',['尛尛']='尛尛先生乄:BAABKgAFFH8NAAMgAAgIcht/AwCKAgAgAAgIcht/AwCKAgAhAAEIKALdFwAuAAAAAA==.尛尛牛牛丶:BAABKgAFFH8IAAMeAAQI7xbhEwDrAAAeAAQI7xbhEwDrAAAbAAEIZQC+KAAhAAAAAA==.尛尛猎丶:BAABKgAFFH8GAAIJAAYIVhypDQAZAQAJAAYIVhypDQAZAQAAAA==.',['山之']='山之翁:BAABKgAFFH8TAAQNAAYI+R96CgDEAQANAAYI+R96CgDEAQAMAAUIABAxFQAOAQARAAII4R0hFACOAAABKgAFFAgICgALAK0lAA==.',['崝贤']='崝贤晁:BAABKgAFFH8OAAIOAAgI7QxQBwCoAQAOAAgI7QxQBwCoAQAAAA==.',['巴尔']='巴尔泽布:BAAAKgAFFAIIAgAAAA==.',['巴库']='巴库:BAAAKgAECgUIBQAAAA==.',['布洛']='布洛林:BAAAKgAECggICgAAAA==.',['希尔']='希尔瓦娜:BAAAKgAFFAgIBAAAAA==.希尔瓦那斯:BAAAKgADCggICAAAAA==.',['幕乃']='幕乃伊:BAABKgAFFH8NAAIVAAMIdhv4HQDSAAAVAAMIdhv4HQDSAAAAAA==.',['年轻']='年轻不讲武德:BAABKgAFFH8zAAILAAYIbSWFCQAqAgALAAYIbSWFCQAqAgAAAA==.',['并蒂']='并蒂莲:BAAAKgAECgEIAQAAAA==.',['幸运']='幸运超人:BAAAKgADCgYIBgAAAA==.',['幻之']='幻之击坠王:BAABKgAFFH8NAAIQAAYI3xysAwCpAQAQAAYI3xysAwCpAQAAAA==.',['广州']='广州灬渣男:BAAAKgAECggIDQAAAA==.',['弑灬']='弑灬煞:BAAAKgAECgIIAgAAAA==.',['张茶']='张茶茶:BAAAKgADCgIIAwAAAA==.',['彈弓']='彈弓:BAABKgAFFH8KAAISAAYIZhKqCgBjAQASAAYIZhKqCgBjAQAAAA==.',['影鬃']='影鬃:BAACKgAFFH8xAAMIAAYIWB3mEQBUAQAIAAUIgRzmEQBUAQAJAAMIXBUFQQCbAAAqAAQKfxcAAwgACAhiHm0sAIgBAAgABwi+HW0sAIgBAAkABAiBH1SAADUBAAAA.',['德一']='德一凹雕:BAAAKgAECgYIBgAAAA==.',['德云']='德云一姐:BAAAKgAECgEIAQAAAA==.',['德容']='德容:BAAAKgAECgEIAQAAAA==.',['德德']='德德香:BAABKgAFFH8MAAIYAAgIaSGwAgCmAgAYAAgIaSGwAgCmAgAAAA==.',['心想']='心想肆橙:BAAAKgAECgYIBgAAAA==.',['心橙']='心橙则灵:BAABKgAFFH8FAAIJAAMIDBmrJwCyAAAJAAMIDBmrJwCyAAAAAA==.',['怀草']='怀草诗:BAAAKgAECgQIBgAAAA==.',['思念']='思念的记忆:BAACKgAFFH9JAAIGAAgInRx0AgBlAgAGAAgInRx0AgBlAgAqAAQKfzkAAgYACAigHx0NAFoCAAYACAigHx0NAFoCAAAA.',['恰似']='恰似温柔:BAAAKgADCggICAAAAA==.',['愤怒']='愤怒的小马甲:BAAAKgADCgIIAgAAAA==.',['慈爱']='慈爱菜:BAAAKgAECgMIAwAAAA==.',['成都']='成都吴彦祖:BAAAKgAFFAgIAQAAAA==.',['我就']='我就是自由:BAAAKgAECgYIBgAAAA==.',['我手']='我手上有枪:BAAAKgAECgMIAwAAAA==.',['我是']='我是小强:BAAAKgADCgcIBwAAAA==.',['我智']='我智商有问题:BAAAKgAFFAQIBAAAAA==.',['战神']='战神志创天下:BAAAKgADCggICAAAAA==.',['手撕']='手撕小仙女:BAABKgAFFH8FAAIOAAMILAMPQACIAAAOAAMILAMPQACIAAABKgAFFAQICQAGAIAEAA==.',['托勒']='托勒密:BAAAKgADCgQIBAAAAA==.',['扭曲']='扭曲机器:BAAAKgAFFAgIBAAAAA==.',['拉不']='拉不能拉多:BAACKgAFFH8nAAMMAAYILRhVFgD1AAANAAUIhhwWHAAEAQAMAAQIjRZVFgD1AAAqAAQKf0UAAwwACAhbI0ALALkCAAwACAhVIkALALkCAA0ACAgWIh4HAHcCAAAA.',['拾一']='拾一壹:BAABKgAFFH8KAAIOAAMI4hKbMQCzAAAOAAMI4hKbMQCzAAAAAA==.',['插根']='插根棍:BAAAKgAFFAQIBAAAAA==.',['插班']='插班女學生:BAABKgAFFH8GAAIIAAYIXxFOFABAAQAIAAYIXxFOFABAAQAAAA==.',['搓奶']='搓奶和尚:BAAAKgAFFAYIBAAAAA==.',['摆烂']='摆烂你的鱼:BAAAKgADCgYIAwAAAA==.',['救祓']='救祓少女问候:BAAAKgAECgUICAAAAA==.',['教主']='教主的核弹粉:BAABKgAFFH8QAAQWAAgIchFvCQA/AQAWAAQIcQ9vCQA/AQAOAAQIJQ2NFQDPAAAiAAQIHRRmFgDAAAAAAA==.',['文森']='文森特的:BAAAKgAECgMIAwAAAA==.',['无敌']='无敌炉石:BAABKgAFFH8GAAILAAYInBcJHgB6AQALAAYInBcJHgB6AQAAAA==.',['无谓']='无谓的莎瓦娜:BAAAKgAECgcIEgAAAA==.',['无道']='无道极法魔君:BAAAKgAECgYIBgAAAA==.',['旺旺']='旺旺与花花:BAAAKgAECgIIAgAAAA==.',['明老']='明老师:BAABKgAFFH8HAAMYAAYIrwpDNgDAAAAYAAMIBAlDNgDAAAAGAAQItQ36IwCJAAAAAA==.',['星海']='星海光来:BAABKgAFFH8GAAIJAAYIixDJFABPAQAJAAYIixDJFABPAQAAAA==.',['春上']='春上花枝:BAAAKgAECgEIAQAAAA==.',['昨夜']='昨夜星辰丶:BAAAKgAECgYIBgAAAA==.',['晓晓']='晓晓法魂:BAABKgAFFH8IAAINAAQIOBFHLgCrAAANAAQIOBFHLgCrAAAAAA==.',['晓糖']='晓糖:BAACKgAFFH8NAAQUAAcIrRrFBgC0AQAUAAYIeRnFBgC0AQAPAAIIoiDOEADVAAAVAAMIPRA+DgDLAAAqAAQKfx4ABBUACAhmEahTAOsAABUABQh/FqhTAOsAABQABQjuC/xhAGsAAA8ABAj5BeqTAC0AAAAA.',['晚来']='晚来天欲雪:BAAAKgAECgcICwAAAA==.',['晚风']='晚风停舟:BAAAKgAECgMIAwAAAA==.',['景添']='景添:BAAAKgAFFAQIBAAAAA==.',['暖暖']='暖暖丶:BAAAKgAECgIIAgAAAA==.',['暗裔']='暗裔血魔:BAABKgAFFH8GAAIGAAYI4hlECQCBAQAGAAYI4hlECQCBAQAAAA==.',['暮灬']='暮灬暮:BAABKgAFFH8KAAIFAAMITgwtIwCWAAAFAAMITgwtIwCWAAAAAA==.',['暮色']='暮色游侠:BAAAKgAECggICAAAAA==.',['曜变']='曜变天目:BAAAKgAECgUIBQAAAA==.',['曼珠']='曼珠沙嘩:BAAAKgAECggIDQAAAA==.曼珠沙崋:BAAAKgADCggICAAAAA==.',['最后']='最后的远古:BAAAKgADCgIIAgAAAA==.',['最爱']='最爱薄荷糖:BAABKgAFFH8IAAIPAAgInxdzAwAqAgAPAAgInxdzAwAqAgAAAA==.最爱血小贱:BAABKgAFFH8IAAMjAAQIFBYbBwD3AAAjAAQIuRMbBwD3AAAXAAQImQuPDgC2AAAAAA==.',['月舞']='月舞之风:BAABKgAFFH8HAAMhAAYIyAf9AQAnAQAhAAYIyAf9AQAnAQAgAAEIjQIVMAAuAAAAAA==.',['月魂']='月魂:BAAAKgADCgIIAgAAAA==.',['有視']='有視橙子:BAAAKgAECgEIAQAAAA==.',['木火']='木火通明:BAAAKgAECggICAAAAA==.',['李二']='李二狗:BAABKgAECn8VAAILAAgI2BpcFwAMAgALAAgI2BpcFwAMAgAAAA==.',['来一']='来一杯小酒:BAAAKgADCgYIBgAAAA==.',['杰森']='杰森丽:BAAAKgAFFAIIAgABKgAFFAgIFAAGABQeAA==.',['枪火']='枪火谈判:BAABKgAFFH8GAAIXAAYIxA0PDgBvAQAXAAYIxA0PDgBvAQAAAA==.',['枫林']='枫林:BAAAKgAECgYICAAAAA==.',['柑蕉']='柑蕉吉梨洛柚:BAAAKgADCggIDwAAAA==.',['桔梗']='桔梗丶丶:BAAAKgADCggICAAAAA==.',['桔梨']='桔梨蘿柚:BAAAKgADCgQIBAAAAA==.',['梅轩']='梅轩:BAAAKgAECgIIBAAAAA==.',['梦丶']='梦丶:BAAAKgAECggIEAAAAA==.',['楚门']='楚门天下:BAAAKgAECggIDQAAAA==.',['樱桃']='樱桃小团子:BAABKgAFFH8KAAMYAAYI9A+vGABYAQAYAAYI9A+vGABYAQAGAAQIMgaeGQCIAAAAAA==.',['橙德']='橙德德:BAAAKgAECggICwAAAA==.',['欢乐']='欢乐的二狗:BAAAKgAECggIDwAAAA==.',['欧阳']='欧阳锋:BAAAKgADCggICAAAAA==.',['残月']='残月小殇:BAABKgAECn8rAAIOAAgILR2EFgBBAgAOAAgILR2EFgBBAgAAAA==.残月小殇殇:BAAAKgAECggICAAAAA==.',['母牛']='母牛倒立:BAAAKgADCggICAAAAA==.',['没有']='没有借口:BAAAKgADCgYIBgAAAA==.',['法丨']='法丨爷丶无敌:BAAAKgAECgEIAQAAAA==.',['波仑']='波仑伽:BAAAKgAECgUIBQAAAA==.',['波里']='波里个浪:BAABKgAFFH8SAAIJAAgIVR18AwCLAgAJAAgIVR18AwCLAgAAAA==.',['泰兰']='泰兰徳丶语风:BAAAKgAECgUIBQAAAA==.',['洛丹']='洛丹纶的夏天:BAAAKgAECgMIAwAAAA==.',['洛克']='洛克李:BAAAKgAFFAEIAQAAAA==.',['洛阳']='洛阳:BAAAKgAFFAQIBAAAAA==.',['流浪']='流浪星球:BAAAKgADCggICAAAAA==.',['海葬']='海葬:BAAAKgADCgEIAQAAAA==.',['涅墨']='涅墨西斯语风:BAAAKgAFFAIIAgAAAA==.',['淡淡']='淡淡的憂傷:BAABKgAFFH8GAAIeAAYILglOIAAeAQAeAAYILglOIAAeAQAAAA==.',['温柔']='温柔的泡沫:BAAAKgAECgIIAgAAAA==.',['火鸡']='火鸡小子:BAABKgAFFH8GAAIKAAYIbBgmDgB+AQAKAAYIbBgmDgB+AQAAAA==.',['灬晚']='灬晚安灬:BAAAKgAFFAIIAwAAAA==.',['灬逢']='灬逢場作戲丶:BAACKgAFFH8oAAMkAAgI0CEQAQAQAgAkAAgI0CEQAQAQAgAeAAEIAABOagAAAAAqAAQKfx8AAyQACAiPIIoKABMCACQACAiPIIoKABMCACUAAQjSB7JEABIAAAAA.',['灬静']='灬静静:BAAAKgADCggICAAAAA==.',['灰烬']='灰烬神术:BAAAKgADCgEIAQAAAA==.',['灰色']='灰色的哀傷:BAAAKgAECgMIBgAAAA==.',['灾厄']='灾厄:BAAAKgAFFAYIBAAAAA==.',['点指']='点指冰兵:BAAAKgAFFAQIBAAAAA==.',['烟岚']='烟岚云岫:BAABKgAFFH8NAAIEAAQIJBc4EQDZAAAEAAQIJBc4EQDZAAAAAA==.',['热心']='热心好市民:BAAAKgAECgIIAgAAAA==.',['熊丸']='熊丸子:BAAAKgAECgIIAgAAAA==.',['熊在']='熊在痒:BAAAKgAFFAQIBAAAAA==.',['爱因']='爱因兹贝伦:BAAAKgAECggIEAAAAA==.',['爱德']='爱德华丶艾伦:BAABKgAFFH8KAAIeAAQIlx5IKgDqAAAeAAQIlx5IKgDqAAAAAA==.',['牙齿']='牙齿有点疼:BAABKgAFFH8KAAIbAAYIjQxTDwAlAQAbAAYIjQxTDwAlAQAAAA==.',['牛气']='牛气死:BAAAKgADCggICQAAAA==.',['牛牛']='牛牛痒:BAABKgAFFH8GAAIgAAYIbw8kCgCMAQAgAAYIbw8kCgCMAQAAAA==.',['牛羞']='牛羞羞:BAAAKgAFFAIIBAAAAA==.',['牛老']='牛老大:BAABKgAFFH8IAAIaAAgIKBEpBQCzAQAaAAgIKBEpBQCzAQAAAA==.',['牛肥']='牛肥肥:BAAAKgAECgcICAAAAA==.',['牧野']='牧野琉璃:BAAAKgAFFAgIAgAAAA==.',['犊犊']='犊犊:BAAAKgAECgQIBwAAAA==.',['狐惑']='狐惑之心:BAAAKgAECgUIBQAAAA==.',['猎丸']='猎丸子:BAAAKgAFFAIIAgAAAA==.',['猫猫']='猫猫呓语者:BAAAKgAECgMIAwAAAA==.猫猫指挥使:BAABKgAFFH8IAAIFAAgIFg9YBgCuAQAFAAgIFg9YBgCuAQAAAA==.猫猫摆渡人:BAAAKgADCggICAAAAA==.猫猫斐常萌:BAAAKgAECgIIAgAAAA==.猫猫智天使:BAAAKgAECgYICQAAAA==.猫猫猎魔者:BAAAKgAECgUIBgAAAA==.猫猫织梦者:BAAAKgADCgQIBAAAAA==.猫猫萌萌德:BAAAKgAECgYICAAAAA==.猫猫逐光者:BAAAKgAECgYICQAAAA==.',['玉面']='玉面总钻风:BAABKgAFFH8IAAIYAAQIthlcDgAAAQAYAAQIthlcDgAAAQAAAA==.',['玛丽']='玛丽玛丽红:BAAAKgADCgEIAQAAAA==.',['玛蕾']='玛蕾格碧:BAAAKgAECgUIBQAAAA==.',['玥涵']='玥涵爹:BAACKgAFFH8eAAQMAAQI7B1tGADtAAAMAAQIwxxtGADtAAANAAQIgRceIwDXAAARAAMIXhRqEwBYAAAqAAQKfyYABA0ACAjcHQsaACACAA0ACAgPHQsaACACAAwACAiAE6cUAKABABEABggwGBZKAD0BAAAA.',['玩到']='玩到你自闭:BAAAKgAECgIIAgAAAA==.',['玫瑰']='玫瑰巷的乞儿:BAAAKgAFFAMIAwAAAA==.',['珀瑟']='珀瑟芬妮语风:BAAAKgAECgcICAAAAA==.',['琳琳']='琳琳伊:BAAAKgAECggICAAAAA==.',['瑟琳']='瑟琳娜森歌:BAAAKgAFFAIIAgAAAA==.',['甜橙']='甜橙味安慕希:BAAAKgAECgUIBQAAAA==.',['电鸡']='电鸡小子:BAAAKgAECgYIDQAAAA==.',['疯彪']='疯彪彪:BAAAKgAECgEIAQAAAA==.',['疯飒']='疯飒飒:BAAAKgAECgMIAwAAAA==.',['痴情']='痴情灬尐儍苽:BAAAKgAECgYIBgAAAA==.',['白桃']='白桃味安慕希:BAABKgAFFH8GAAIaAAYIWhT2BwA9AQAaAAYIWhT2BwA9AQAAAA==.',['白马']='白马义从:BAAAKgAFFAEIAQAAAA==.',['百潕']='百潕禁忌:BAABKgAECn8VAAIbAAgIGA3VMwAfAQAbAAgIGA3VMwAfAQAAAA==.',['皇堡']='皇堡:BAAAKgAECggIEAABKgAFFAgIDAAYAPURAA==.',['看水']='看水不是水:BAAAKgAECgUIBQAAAA==.',['眼泪']='眼泪同学:BAAAKgAECgIIBAAAAA==.',['知弦']='知弦水月:BAAAKgAECggIEgAAAA==.',['硬钢']='硬钢:BAABKgAFFH8GAAIgAAYIhBSTCwCSAQAgAAYIhBSTCwCSAQAAAA==.',['离焱']='离焱:BAABKgAFFH8FAAICAAMICBXcKQDGAAACAAMICBXcKQDGAAAAAA==.',['秋裤']='秋裤猫丶:BAAAKgAFFAQIBAAAAA==.',['稚圭']='稚圭:BAAAKgAECggIDgAAAA==.',['空白']='空白:BAAAKgAECgQIBAAAAA==.',['笑看']='笑看浮华:BAAAKgAECgMIAwAAAA==.',['答辩']='答辩投掷者:BAAAKgADCgEIAQAAAA==.',['箭神']='箭神王子:BAAAKgAFFAYIAgABKgAFFAgILQAJAMMeAA==.',['箭飞']='箭飞雪舞:BAAAKgADCgEIAQAAAA==.',['米罗']='米罗克:BAABKgAFFH8KAAIKAAYIIBpuEQBMAQAKAAYIIBpuEQBMAQAAAA==.',['粉红']='粉红刹妈酱:BAAAKgAECgYIBwAAAA==.',['索尼']='索尼娅:BAAAKgAECgIIAgAAAA==.',['緋雪']='緋雪:BAACKgAFFH8LAAIYAAMIOBw2DwD8AAAYAAMIOBw2DwD8AAAqAAQKfx0AAxgACAizI8wOAJQCABgACAizI8wOAJQCABkAAwieFIEjAKIAAAAA.',['繁华']='繁华去冷风尽:BAABKgAFFH8IAAIGAAgIeBApBAC9AQAGAAgIeBApBAC9AQAAAA==.',['红色']='红色柯基:BAAAKgAECgUICQAAAA==.',['纳姆']='纳姆:BAAAKgAECggIDgAAAA==.',['绝望']='绝望灬远征:BAAAKgAECgcIDgAAAA==.',['绿蚁']='绿蚁新醅酒:BAACKgAFFH89AAIOAAgIziYkAAAAAwAOAAgIziYkAAAAAwAqAAQKfzEAAg4ACAjUJswAAAYDAA4ACAjUJswAAAYDAAAA.',['罗武']='罗武林:BAAAKgAECgQIBQAAAA==.',['罗雨']='罗雨萱吖:BAABKgAFFH8GAAIUAAYI5xlUCgBbAQAUAAYI5xlUCgBbAQAAAA==.',['老大']='老大哥看着你:BAAAKgAECgYIDQAAAA==.',['老爸']='老爸:BAAAKgAECgYIBgAAAA==.',['肘鸡']='肘鸡小子:BAAAKgAECggIDgAAAA==.',['胭脂']='胭脂红刃:BAAAKgAECgMIAwAAAA==.',['艾妮']='艾妮:BAAAKgAFFAgIBAAAAA==.',['艾莉']='艾莉萝:BAAAKgAECgIIAgAAAA==.',['芒果']='芒果丿咬一口:BAABKgAFFH8UAAMSAAYIBR4qCQB4AQASAAUIJx0qCQB4AQAgAAYIcBaYCgATAQAAAA==.',['芙莉']='芙莉莲:BAAAKgAECgYIBgABKgAFFAYIFQAGALIVAA==.',['花花']='花花与旺旺:BAAAKgAECgUIDAAAAA==.',['苍月']='苍月影:BAAAKgADCggICwAAAA==.苍月空:BAAAKgAECgQIBAAAAA==.',['苍翼']='苍翼:BAABKgAFFH8IAAMLAAYIcwkPLAA3AQALAAYIcwkPLAA3AQAaAAIIrAWVFQBUAAAAAA==.',['苏杨']='苏杨:BAAAKgADCgIIAgAAAA==.',['若凡']='若凡:BAABKgAFFH8NAAIOAAQINh05JADmAAAOAAQINh05JADmAAAAAA==.',['荆棘']='荆棘:BAABKgAFFH8IAAIZAAgIXwhcAwDhAQAZAAgIXwhcAwDhAQAAAA==.',['草莓']='草莓味胳肢窝:BAAAKgAECgcICgAAAA==.',['草莽']='草莽英雄许仙:BAAAKgAECgcIDQAAAA==.',['莉莉']='莉莉家的莉莉:BAAAKgAFFAQIBAAAAA==.',['莎士']='莎士比亚:BAAAKgAECggIDgAAAA==.',['莫傻']='莫傻:BAACKgAFFH8FAAIbAAMI4Q0MIwCbAAAbAAMI4Q0MIwCbAAAqAAQKfyYAAhsACAjVHFgUAAACABsACAjVHFgUAAACAAAA.',['莫哈']='莫哈拉丶战鼓:BAAAKgAECgYIBgAAAA==.',['莫烦']='莫烦:BAABKgAFFH8GAAMJAAMI1BBhGwC9AAAJAAMIkQ5hGwC9AAAIAAMIsgqVOACUAAAAAA==.',['菲布']='菲布里佐:BAABKgAFFH8MAAMMAAYIDBVXEgAuAQAMAAYIXQ1XEgAuAQARAAQIihIPGQCxAAAAAA==.',['萌妹']='萌妹纸转圈圈:BAABKgAFFH8KAAIQAAgI0RekBQBcAgAQAAgI0RekBQBcAgAAAA==.',['萌萌']='萌萌的蛋仔:BAAAKgAECggIDgABKgAFFAgIBgADAPgLAA==.',['蓝影']='蓝影龙:BAABKgAFFH8SAAMPAAQI6B48DgDlAAAPAAQIjB48DgDlAAAVAAEINRfFPwA4AAAAAA==.',['蕾娜']='蕾娜塔亡语者:BAAAKgAECgYIBwAAAA==.',['蕾米']='蕾米莉亞:BAACKgAFFH8iAAIZAAQIlyG6BgACAQAZAAQIlyG6BgACAQAqAAQKfy0AAhkACAhiIfMIACUCABkACAhiIfMIACUCAAAA.',['蛋苕']='蛋苕儿:BAAAKgAECgUIBQAAAA==.',['蛘一']='蛘一只死一只:BAAAKgAECgcICAAAAA==.',['螃蟹']='螃蟹:BAAAKgADCggICAAAAA==.',['血色']='血色赞美诗:BAAAKgADCggICAAAAA==.血色阿比迪斯:BAAAKgADCgEIAQAAAA==.',['行运']='行运超人:BAAAKgADCgEIAQAAAA==.',['裂刃']='裂刃丶:BAAAKgAECgIIAgAAAA==.',['裴南']='裴南苇:BAAAKgAFFAQIBAAAAA==.',['西瓜']='西瓜呱呱:BAAAKgAECggICAAAAA==.',['西米']='西米鹿:BAAAKgAFFAQIBAAAAA==.',['诡秘']='诡秘之主:BAAAKgAECgYIBgABKgAFFAMIBQALAOUSAA==.',['賊丶']='賊丶椛俚椛筱:BAABKgAFFH8GAAIXAAYI8iDHAADvAQAXAAYI8iDHAADvAQAAAA==.',['贤者']='贤者泰兰迪尔:BAAAKgADCggIBAAAAA==.',['贫僧']='贫僧略懂拳脚:BAAAKgAECgYIBgAAAA==.',['超凡']='超凡大师:BAABKgAFFH8KAAIQAAYIJw5zBACYAQAQAAYIJw5zBACYAQABKgAFFAgIEgAQAJgVAA==.',['超萌']='超萌小可可:BAAAKgAFFAIIAgAAAA==.',['踏雪']='踏雪:BAAAKgAECggICQAAAA==.',['踢狙']='踢狙电玩骑士:BAAAKgAECgQIBAAAAA==.',['转角']='转角遇见沵:BAACKgAFFH8GAAIGAAMI4AVEKwBoAAAGAAMI4AVEKwBoAAAqAAQKfyUAAwYACAhUCsEyAAQBAAYACAhUCsEyAAQBABgAAggOBWXGAD0AAAAA.',['轻音']='轻音:BAABKgAFFH8FAAILAAIIQgcuRwBvAAALAAIIQgcuRwBvAAAAAA==.',['辛多']='辛多雷的愤怒:BAAAKgADCggICAAAAA==.辛多雷的荣耀:BAAAKgAECgYICAAAAA==.',['辛德']='辛德瑞拉语风:BAAAKgAFFAIIAgAAAA==.',['过去']='过去的岁月:BAABKgAFFH8FAAILAAMItAgKZgCiAAALAAMItAgKZgCiAAAAAA==.',['逃离']='逃离村长家:BAAAKgADCgUIBQAAAA==.',['逆流']='逆流而上:BAAAKgADCggICAAAAA==.',['逍遥']='逍遥海鸥:BAAAKgAECggIDAAAAA==.',['酱香']='酱香丨拿铁:BAAAKgAECgMIAwAAAA==.',['醉舞']='醉舞封殇:BAAAKgAFFAIIBAAAAA==.',['重生']='重生之我喷了:BAAAKgAFFAQIBAAAAA==.',['银月']='银月红尘:BAAAKgADCgQIBAAAAA==.',['长安']='长安归故里丶:BAAAKgAECgEIAQAAAA==.',['长岛']='长岛吴彦祖:BAABKgAFFH8MAAIgAAYIHSDQCgCeAQAgAAYIHSDQCgCeAQAAAA==.',['长耳']='长耳朵贱贱:BAACKgAFFH8GAAILAAYIQheKGwCHAQALAAYIQheKGwCHAQAqAAQKfxgAAgsACAicHsEnAGECAAsACAicHsEnAGECAAAA.',['阝丨']='阝丨小默丨丶:BAAAKgAECggIDAAAAA==.',['队友']='队友呢队友呢:BAAAKgAFFAQIBAAAAA==.',['阴影']='阴影中的咸鱼:BAAAKgAECgUIBQAAAA==.',['阿尔']='阿尔托莉雅:BAAAKgAFFAIIAgABKgAFFAIIAgAfAAAAAA==.',['阿尼']='阿尼亚丶艾伦:BAACKgAFFH8lAAMIAAcIGh9UBQAhAQAIAAcIGh9UBQAhAQAJAAIIIxy8LQCeAAAqAAQKfzEAAwgACAipJTMEANkCAAgABwipJTMEANkCAAkABwjAIAlRAL4BAAAA.',['阿斯']='阿斯特黯刃:BAAAKgAECggIDgAAAA==.',['阿爾']='阿爾薩司:BAAAKgAFFAIIAgAAAA==.',['阿狸']='阿狸酱:BAAAKgAECggICAAAAA==.',['阿鲁']='阿鲁迪巴:BAABKgAFFH8GAAIhAAIIvgahCgBmAAAhAAIIvgahCgBmAAAAAA==.',['陈英']='陈英俊:BAABKgAFFH8JAAIGAAQIgAQFLABkAAAGAAQIgAQFLABkAAAAAA==.',['陟罚']='陟罚臧否:BAABKgAFFH8GAAILAAYI5hQIHwB0AQALAAYI5hQIHwB0AQAAAA==.',['随便']='随便你:BAABKgAFFH8PAAIQAAQIFxTPKgDNAAAQAAQIFxTPKgDNAAAAAA==.',['雨之']='雨之馨:BAAAKgAFFAIIAwAAAA==.雨之魔女:BAAAKgADCgMIAwAAAA==.',['雨泽']='雨泽:BAAAKgADCggIIAAAAA==.',['雨皇']='雨皇包吃包住:BAAAKgADCgYIBgAAAA==.',['雨落']='雨落杉:BAAAKgADCgQIBAAAAA==.',['雪小']='雪小言:BAAAKgAECgMIAwAAAA==.雪小詞:BAAAKgAECgUIBQAAAA==.',['雪漠']='雪漠蓝天:BAAAKgAECgEIAQAAAA==.',['雷鼓']='雷鼓:BAAAKgAECggIAwAAAA==.',['雾中']='雾中之风:BAAAKgADCggICAAAAA==.',['青烟']='青烟绕指柔乄:BAABKgAFFH8GAAMaAAQIHh9dFgDFAAAaAAQIRRtdFgDFAAALAAII5yCvOgCTAAAAAA==.',['顺势']='顺势而为丶:BAACKgAFFH8KAAMmAAMIoAh2CABxAAAmAAMIoAh2CABxAAAKAAIIQgPmMgBQAAAqAAQKfzkAAwoACAgTIwIJAJwCAAoACAgTIwIJAJwCACYABwh7FkEJAH0BAAAA.',['风竹']='风竹禅师:BAAAKgADCgEIAQAAAA==.',['风语']='风语之谓之:BAAAKgADCgYICAAAAA==.',['风起']='风起云转:BAACKgAFFH8PAAILAAMI1xq8GAD6AAALAAMI1xq8GAD6AAAqAAQKfx4AAwsACAj/IsAhAJICAAsACAj/IsAhAJICABoAAQhIA2hsAAwAAAAA.',['飞天']='飞天蝙蝠:BAAAKgAECgQIBAAAAA==.',['飞翔']='飞翔的知珠:BAAAKgAFFAEIAQAAAA==.飞翔的蜘蛛:BAAAKgAECgcIEAAAAA==.',['飞霄']='飞霄:BAABKgAFFH8aAAMKAAgIGhc3BgAkAgAKAAgIGhc3BgAkAgAmAAIIKAsyCAB0AAAAAA==.',['饕餮']='饕餮:BAAAKgAECgYIBwAAAA==.',['饿龙']='饿龙咆哮吼:BAAAKgAECggICAAAAA==.',['马尔']='马尔高克:BAAAKgAFFAQIAwABKgAFFAgICAAaAPYSAA==.',['骄阳']='骄阳火影:BAAAKgAFFAEIAQAAAA==.',['高贵']='高贵冷艳傲娇:BAAAKgAFFAQIBAAAAA==.',['魂之']='魂之自在:BAAAKgADCggICAAAAA==.魂之饕餮:BAAAKgAECgMIAwAAAA==.',['魔血']='魔血为墨:BAABKgAFFH8IAAICAAgITxmcBQA/AgACAAgITxmcBQA/AgAAAA==.',['鲁克']='鲁克米:BAAAKgAECggICAAAAA==.',['鲜血']='鲜血之魂:BAABKgAFFH8HAAICAAcIRBlYBwDzAQACAAcIRBlYBwDzAQAAAA==.',['鲲鲲']='鲲鲲小子:BAAAKgAFFAcIAwAAAA==.',['鶄鳥']='鶄鳥:BAAAKgAECgMIAwAAAA==.',['鸾觞']='鸾觞酌醴:BAAAKgAECgIIAgAAAA==.',['麻辣']='麻辣小牛至:BAAAKgADCgIIAgAAAA==.',['黑白']='黑白猎:BAAAKgAFFAgIBAAAAA==.',['龙六']='龙六郎:BAAAKgAFFAgIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end