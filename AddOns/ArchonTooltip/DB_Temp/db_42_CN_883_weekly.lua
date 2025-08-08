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
 local lookup = {'Shaman-Restoration','DeathKnight-Unholy','DeathKnight-Blood','Mage-Arcane','Mage-Fire','Rogue-Assassination','Priest-Holy','Hunter-BeastMastery','Paladin-Retribution','Paladin-Protection','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Balance','Druid-Restoration','Unknown-Unknown','Monk-Mistweaver','Priest-Discipline','Monk-Brewmaster','Hunter-Marksmanship','Warlock-Destruction','Mage-Frost','Shaman-Elemental','Shaman-Enhancement','Priest-Shadow','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Hunter-Survival','Warrior-Fury','Warrior-Protection','Paladin-Holy','Monk-Windwalker','Druid-Feral','Rogue-Subtlety','Rogue-Outlaw','DeathKnight-Frost','Warlock-Affliction','Warlock-Demonology','Warrior-Arms',}; local provider = {region='CN',realm='风暴之眼',name='CN',type='weekly',zone=42,date='2025-08-04',data={An='Anyoyol:BAAAKgAECggIEAAAAA==.',As='Aspnet:BAAAKgAECgEIAQAAAA==.',Be='Bestwishes:BAABKgAFFH8IAAIBAAgIEg9xBgDmAQABAAgIEg9xBgDmAQAAAA==.',Bl='Bluesshiit:BAABKgAFFH8OAAMCAAYIOhi9BwAtAQACAAQIvR29BwAtAQADAAYIYBGQEQAWAQAAAA==.',Cj='Cjqdnmf:BAAAKgAECgIIAgAAAA==.',Dk='Dk:BAABKgAFFH8NAAMDAAgIQBbfCQB2AQACAAcIJhDTBwDJAQADAAYIWhnfCQB2AQAAAA==.',Dr='Dreamengirl:BAAAKgAECgEIAQAAAA==.',Du='Dudk:BAAAKgAFFAQIBAAAAA==.Durandal:BAAAKgAECgMIAwAAAA==.',El='Elisabe:BAAAKgADCggICAAAAA==.',Er='Erdtree:BAABKgAFFH8PAAMEAAcIhBjtGAC2AAAEAAUIURjtGAC2AAAFAAMIlBMpIQCuAAAAAA==.Erica:BAAAKgADCgUIBQAAAA==.',Eu='Eutopia:BAAAKgAFFAIIAgAAAA==.',Fa='Fa:BAAAKgADCgUIBQAAAA==.',Fo='Fov:BAABKgAFFH8FAAMFAAUIRBWmHADgAAAFAAQIYhamHADgAAAEAAEI5xG7QgBHAAABKgAFFAgICwAEANcaAA==.',Gi='Gioio:BAAAKgAFFAQIBAAAAA==.',He='Heleny:BAAAKgADCggICAAAAA==.Hera:BAAAKgADCggICAAAAA==.',Jo='Journey:BAAAKgAECgQIAwAAAA==.',Ki='Kiyo:BAAAKgAFFAQIBAAAAA==.',Li='Light:BAABKgAFFH8GAAIBAAYIdQYvGgAXAQABAAYIdQYvGgAXAQAAAA==.',Mc='Mcai:BAABKgAFFH8GAAIGAAYIoR7NCADSAQAGAAYIoR7NCADSAQAAAA==.',Me='Mess:BAAAKgADCggICAAAAA==.',Mu='Mumushi:BAAAKgAFFAIIAgAAAA==.',My='Mystara:BAAAKgADCgMIAwAAAA==.',Pu='Pumpkin:BAAAKgAECgcIDAAAAA==.',Ra='Raichu:BAAAKgAFFAgIBAAAAA==.',Ro='Robinnico:BAABKgAFFH8IAAIHAAgIygpQBwCBAQAHAAgIygpQBwCBAQAAAA==.Roro:BAAAKgAECgYIBgAAAA==.',Sa='Saintpast:BAAAKgAECgMIAwAAAA==.',Se='Semage:BAABKgAFFH8GAAIEAAYIxSQOCgDNAQAEAAYIxSQOCgDNAQAAAA==.',Te='Terminatorx:BAABKgAFFH8GAAMCAAYIYQosQACdAAACAAIITxAsQACdAAADAAQIbQbaKwBlAAAAAA==.',Uy='Uyituyik:BAAAKgADCgUIBQAAAA==.',Ve='Ventose:BAAAKgAECgIIAgAAAA==.Verdantwhisp:BAAAKgAFFAMIAwAAAA==.',Ye='Yeren:BAAAKgAECggICwAAAA==.',['一升']='一升的眼涙:BAAAKgAECggICAABKgAFFAgICAAIAJ0HAA==.',['一号']='一号奶罐:BAABKgAECn9JAAIHAAgIuyZHAQD/AgAHAAgIuyZHAQD/AgAAAA==.',['一燃']='一燃血一:BAAAKgAECgEIAQAAAA==.',['一百']='一百多个圣骑:BAAAKgAFFAYIAQAAAA==.',['万俟']='万俟小圣:BAACKgAFFH8QAAIJAAQIkhWXRADmAAAJAAQIkhWXRADmAAAqAAQKfx8AAwkACAgYGrlCACcCAAkACAgYGrlCACcCAAoAAQisA8VsAAsAAAAA.万俟猎手:BAACKgAFFH8PAAILAAMIOhT6KADTAAALAAMIOhT6KADTAAAqAAQKfxcAAwsACAj9FA82AH8BAAsACAjuFA82AH8BAAwABwjGEWoOAEkBAAAA.',['万径']='万径丨人踪灭:BAAAKgAFFAQIBAAAAA==.',['三两']='三两韭菜鸡蛋:BAAAKgAFFAIIAgAAAA==.',['上古']='上古神德:BAABKgAFFH8UAAMNAAYIJyH9CwDVAQANAAYIJyH9CwDVAQAOAAUIgQ+CCAD3AAABKgAFFAgIBAAPAAAAAA==.',['下海']='下海摸瞎:BAAAKgADCgIIAgAAAA==.',['不想']='不想练级啊:BAABKgAFFH8FAAIQAAUINw9TFwDnAAAQAAUINw9TFwDnAAAAAA==.',['不懂']='不懂拒绝:BAAAKgADCgEIAQAAAA==.',['不要']='不要你提醒我:BAAAKgAECgIIAgAAAA==.',['丨赵']='丨赵吏丨:BAAAKgAECgIIAgAAAA==.',['丨迪']='丨迪丽热巴丨:BAABKgAFFH8JAAIBAAYIJRlQCACOAQABAAYIJRlQCACOAQAAAA==.',['丨陈']='丨陈都灵丨:BAACKgAFFH8PAAIRAAMIzxt0FgDfAAARAAMIzxt0FgDfAAAqAAQKfxoAAhEACAjxHEAUAP4BABEACAjxHEAUAP4BAAAA.',['丨鞠']='丨鞠婧祎丨:BAACKgAFFH8NAAMQAAQIlBRLGwDDAAAQAAMIlBRLGwDDAAASAAQIYwTpBgB3AAAqAAQKfxwAAhAACAh3GJgUAOwBABAACAh3GJgUAOwBAAAA.',['串串']='串串:BAAAKgAFFAMIAwAAAA==.',['丶射']='丶射部丨落丶:BAACKgAFFH8PAAIIAAMIPhrdKgDaAAAIAAMIPhrdKgDaAAAqAAQKfxoAAxMABwgFHO4TAJgBABMABgjQG+4TAJgBAAgABggeG7ooADQBAAAA.',['丶西']='丶西鑫:BAAAKgAFFAQIAgAAAA==.',['乌瑟']='乌瑟厼:BAABKgAECn8YAAIJAAgIDyOnCgCYAgAJAAgIDyOnCgCYAgABKgAFFAgIEgAKAOocAA==.',['乔凝']='乔凝心:BAABKgAECn8+AAIJAAgIZyMNFQC0AgAJAAgIZyMNFQC0AgAAAA==.',['乔幺']='乔幺叔:BAAAKgADCggIFQAAAA==.',['二号']='二号奶罐:BAABKgAECn9UAAIHAAgIsSZbAAAUAwAHAAgIsSZbAAAUAwAAAA==.',['二狗']='二狗子:BAABKgAFFH8RAAIUAAgI1R2kBABXAgAUAAgI1R2kBABXAgAAAA==.',['五个']='五个字的德:BAAAKgADCgQIBAAAAA==.',['五色']='五色土豆泥:BAABKgAFFH8LAAIVAAQIbCR7BAAPAQAVAAQIbCR7BAAPAQAAAA==.',['仰天']='仰天听雨:BAAAKgADCggIDwAAAA==.仰天怒视:BAAAKgADCggIEAAAAA==.仰天望月:BAAAKgADCggICAAAAA==.',['仰望']='仰望:BAAAKgADCggICAAAAA==.',['伊芙']='伊芙琳:BAAAKgAECggIDAAAAA==.',['伊麗']='伊麗丹怒風:BAABKgAFFH8IAAMMAAYIPgXPBQDhAAAMAAYI4APPBQDhAAALAAIIFQY1QwByAAABKgAFFAgIBgASAPgLAA==.',['体型']='体型胖:BAAAKgAECgEIAQABKgAECgYIBgAPAAAAAA==.',['元素']='元素行者:BAAAKgAFFAQIBAAAAA==.',['光铸']='光铸圣骑方:BAAAKgAECgUIBQAAAA==.',['八月']='八月的雨:BAABKgAFFH8FAAIKAAUIKxaaDgAVAQAKAAUIKxaaDgAVAQAAAA==.',['六道']='六道左岸:BAAAKgADCggIAgAAAA==.',['兽柱']='兽柱伊之助:BAAAKgADCgQIBAAAAA==.',['再来']='再来一发少年:BAAAKgAFFAIIAgAAAA==.',['农场']='农场主:BAACKgAFFH8PAAIHAAQI4BQdJACzAAAHAAQI4BQdJACzAAAqAAQKfxoAAgcABwgqEtw5AFUBAAcABwgqEtw5AFUBAAAA.',['冬日']='冬日:BAAAKgAECgQIBAAAAA==.',['冰域']='冰域灵帝:BAAAKgAECgcICgAAAA==.',['冰火']='冰火魔龙:BAAAKgADCgIIAgAAAA==.',['冲锋']='冲锋灬释放:BAAAKgADCggICAAAAA==.',['冷少']='冷少:BAAAKgAECggICAAAAA==.',['凭栏']='凭栏听雨:BAAAKgAECgQIBAAAAA==.',['刀爷']='刀爷:BAAAKgAECggICQAAAA==.',['刘罗']='刘罗仙:BAAAKgADCggICAAAAA==.',['别抢']='别抢我零食:BAAAKgADCggICAAAAA==.',['动物']='动物凶猛:BAAAKgAFFAQIBAAAAA==.',['十一']='十一天:BAAAKgADCgcIBwAAAA==.',['十月']='十月丶三十:BAAAKgADCggICAAAAA==.',['十条']='十条毛毛鱼:BAAAKgAECgQIBAAAAA==.',['午夜']='午夜丶缠眠:BAABKgAFFH8gAAMNAAgIECHGAwCXAgANAAgIECHGAwCXAgAOAAQIRRqaGADcAAAAAA==.',['华尔']='华尔都斯:BAAAKgAECgEIAQAAAA==.',['南木']='南木井:BAAAKgADCgMIAwAAAA==.',['原来']='原来我不帅:BAAAKgAECggICAAAAA==.',['只抓']='只抓灵魂兽:BAAAKgAFFAQIBAAAAA==.',['叫我']='叫我小德吧:BAABKgAECn8fAAINAAgIGx/gCQBYAgANAAgIGx/gCQBYAgAAAA==.叫我死骑吧:BAABKgAECn8VAAICAAYIpx09NwCYAQACAAYIpx09NwCYAQAAAA==.',['可儿']='可儿必思嘟嘟:BAABKgAFFH8SAAMBAAYIcSYhAAA8AgABAAYIcSYhAAA8AgAWAAQI0RfFFQDDAAABKgAFFAgIDwAXAC4bAA==.',['可尔']='可尔必思多多:BAABKgAFFH8YAAMDAAgInx4PAQDIAQACAAgIJxz8AgB4AgADAAYIZxwPAQDIAQAAAA==.可尔必思芝士:BAABKgAFFH8LAAMRAAgIRhbCAgAHAgARAAgIRhbCAgAHAgAHAAMI+QV2OQBaAAAAAA==.',['可然']='可然:BAAAKgAFFAIIAgAAAA==.',['史密']='史密斯专员:BAAAKgAFFAgIBAAAAA==.',['叶卿']='叶卿棠:BAABKgAECn82AAIIAAgITSL7FgB3AgAIAAgITSL7FgB3AgAAAA==.',['吃个']='吃个桃桃:BAAAKgAECgYIBgAAAA==.',['吃虾']='吃虾只吃虾线:BAAAKgAFFAUIBAAAAA==.',['后来']='后来:BAAAKgADCggICAAAAA==.',['后羿']='后羿小师媚:BAAAKgADCggICAAAAA==.',['吹不']='吹不破的皮:BAAAKgADCgIIAgAAAA==.',['咖啡']='咖啡鹿死谁手:BAAAKgADCgMIAwAAAA==.',['咖喱']='咖喱叶:BAABKgAFFH8IAAIRAAgIFhZqCwBeAQARAAgIFhZqCwBeAQAAAA==.',['哲晰']='哲晰:BAAAKgAECgUIAwABKgAFFAgIDwARAM4XAA==.',['唯吾']='唯吾德馨:BAAAKgAFFAMIAwAAAA==.',['啊哈']='啊哈哈:BAAAKgAFFAQIBAAAAA==.',['啊逼']='啊逼的小怪兽:BAABKgAECn8UAAIJAAgIfSIeJwCAAgAJAAgIfSIeJwCAAgAAAA==.',['問問']='問問:BAAAKgAECgQIBAAAAA==.',['啸熬']='啸熬浆糊:BAAAKgAECgUIBwAAAA==.',['喪彪']='喪彪:BAAAKgADCggICAAAAA==.',['嗨丶']='嗨丶莉妹:BAAAKgAECgcICAAAAA==.',['嗨灬']='嗨灬娶我:BAACKgAFFH8GAAMHAAYIVQsPIADHAAAHAAUIUwcPIADHAAAYAAEIFyTEJQBhAAAqAAQKfywAAxgACAi0HogLAGkCABgACAi0HogLAGkCABEABQj6BbtyAHAAAAAA.嗨灬战神:BAAAKgAECgUICAAAAA==.嗨灬法神:BAAAKgAECgIIAgAAAA==.',['嗷呜']='嗷呜嗷呜:BAAAKgAECgMIBgAAAA==.',['嘤咛']='嘤咛:BAAAKgADCggICAAAAA==.',['嘤嘤']='嘤嘤牛:BAAAKgAECgYIBwAAAA==.',['器宇']='器宇轩昂:BAAAKgAECggICAAAAA==.',['四号']='四号大菜鸟:BAABKgAECn9iAAMHAAgIuyZiAAATAwAHAAgIuyZiAAATAwARAAEIkhlChgBHAAAAAA==.',['因果']='因果蛀虫:BAAAKgAECgQIBAABKgAECgUICgAPAAAAAA==.',['圆妈']='圆妈咪:BAAAKgAECgMIAwAAAA==.',['圆桌']='圆桌骑士:BAABKgAFFH8IAAIJAAQIPiRyCwAoAQAJAAQIPiRyCwAoAQAAAA==.',['圣光']='圣光之爹:BAAAKgAECgIIAgAAAA==.圣光别搞我:BAAAKgAECgcIDgAAAA==.圣光大妹子:BAAAKgADCgQIBAAAAA==.',['圣手']='圣手回春:BAAAKgADCgIIAgAAAA==.',['坎门']='坎门:BAAAKgAECggIEwAAAA==.',['坏天']='坏天气:BAABKgAFFH8NAAIJAAMIeR8pHQD6AAAJAAMIeR8pHQD6AAAAAA==.',['坏心']='坏心眼的猫:BAAAKgAECgMIAwAAAA==.',['坏念']='坏念过去:BAAAKgADCgEIAQAAAA==.',['坚韧']='坚韧:BAAAKgAECgUIBQAAAA==.',['增的']='增的辉常牛逼:BAACKgAFFH84AAMZAAgIBB6NBQBHAgAZAAgIthuNBQBHAgAaAAMI6A9yAQDnAAAqAAQKf0QAAxkACAiBJTwDAOkCABkACAiBJTwDAOkCABsAAggJBBolAE0AAAAA.',['壞爺']='壞爺:BAABKgAFFH8HAAQIAAMIgRqUQACcAAAIAAIIahqUQACcAAAcAAEIRh3tBQBVAAATAAEIihHpKQA9AAAAAA==.',['夏依']='夏依霖:BAABKgAFFH8OAAIJAAgIXAn6DQDBAQAJAAgIXAn6DQDBAQAAAA==.',['夏夜']='夏夜未央:BAAAKgADCggICAAAAA==.',['夏天']='夏天一缕清凉:BAAAKgADCgIIAgAAAA==.',['夜下']='夜下听风:BAABKgAFFH8UAAIJAAQI1w4yKQDCAAAJAAQI1w4yKQDCAAAAAA==.',['夜丶']='夜丶瞳:BAAAKgAECggIDQAAAA==.',['夜半']='夜半无人:BAAAKgAECgQIBAAAAA==.',['大剑']='大剑豪卓洛:BAAAKgAECgIIAgAAAA==.',['大圣']='大圣光城主:BAAAKgAECgMIAwAAAA==.',['大地']='大地之力:BAACKgAFFH8UAAMdAAYIpw8vFgAJAQAdAAQIlxAvFgAJAQAeAAUIwgb4CwCnAAAqAAQKfycAAh0ACAhMHucWAFICAB0ACAhMHucWAFICAAAA.',['大狼']='大狼蹄子:BAAAKgADCggICAAAAA==.',['大珺']='大珺肝:BAAAKgAECgMIAwAAAA==.',['大经']='大经理丶:BAABKgAFFH8FAAIdAAUIwQ3pBABMAQAdAAUIwQ3pBABMAQAAAA==.',['大锤']='大锤哐哐抡:BAABKgAFFH8GAAIJAAYI5BAWIgBlAQAJAAYI5BAWIgBlAQAAAA==.',['大鸟']='大鸟萌妹:BAAAKgAECggIEAAAAA==.',['天涯']='天涯一品:BAAAKgAECgcICwAAAA==.',['天火']='天火同人:BAAAKgAECgQIAwAAAA==.',['太空']='太空捕:BAAAKgAFFAgIAgAAAA==.',['失落']='失落的雪:BAABKgAECn9kAAIBAAgItibLAAAIAwABAAgItibLAAAIAwAAAA==.',['失败']='失败者:BAAAKgADCgcIBwAAAA==.',['奥兰']='奥兰妮尔丶:BAAAKgAECgQIBgAAAA==.',['奥好']='奥好我地孩:BAAAKgAECggICAAAAA==.',['奶不']='奶不要停:BAAAKgADCgMIAwAAAA==.',['妖零']='妖零零妖零:BAAAKgAECggICAAAAA==.',['妹子']='妹子你炉石呢:BAABKgAECn8yAAIfAAgITR35BQDzAQAfAAgITR35BQDzAQAAAA==.',['姜小']='姜小贱:BAAAKgADCggICAAAAA==.',['威少']='威少:BAAAKgAECgUICwAAAA==.',['嫑牧']='嫑牧:BAAAKgAECgYIBgAAAA==.',['安晴']='安晴:BAAAKgAECgYIBgAAAA==.',['宝宝']='宝宝不坏:BAACKgAFFH8ZAAIeAAQIDhE1DACkAAAeAAQIDhE1DACkAAAqAAQKfyUAAh4ACAgkHHINAOQBAB4ACAgkHHINAOQBAAAA.',['宠物']='宠物院长丶熠:BAAAKgAFFAQIBAAAAA==.',['审判']='审判者维罗亚:BAABKgAFFH8MAAIKAAgIDBgjAwAYAgAKAAgIDBgjAwAYAgAAAA==.',['宫脇']='宫脇咲良:BAAAKgAFFAQIBAAAAA==.',['宸少']='宸少爷:BAAAKgAECgEIBAAAAA==.',['封情']='封情葬爱看海:BAAAKgAECggIDAAAAA==.',['小华']='小华子:BAAAKgAECgEIAQAAAA==.',['小小']='小小珺肝:BAAAKgAECgYIDAAAAA==.',['小弱']='小弱江:BAAAKgAFFAgIAwAAAA==.',['小灬']='小灬火苗:BAAAKgAECgYIBgAAAA==.小灬魔王:BAAAKgAECgQIBAAAAA==.',['小熊']='小熊来抓你了:BAAAKgAECgYICAAAAA==.小熊跑哪了:BAAAKgAFFAIIAgAAAA==.',['小狼']='小狼蹄子:BAAAKgAECggICAAAAA==.',['小猪']='小猪哥哥:BAAAKgAECgYIBgAAAA==.',['小童']='小童不怕死啊:BAAAKgADCgUIBQAAAA==.',['小箭']='小箭飞你臀:BAAAKgAECgYIBgAAAA==.',['小脸']='小脸袋:BAABKgAFFH8LAAIUAAgIAxVrCAAIAgAUAAgIAxVrCAAIAgAAAA==.',['小蜜']='小蜜桃儿:BAAAKgAFFAEIAQAAAA==.',['小酌']='小酌的老陈:BAABKgAFFH8PAAMQAAYIUiGrAwCKAQAQAAYIUiGrAwCKAQASAAQIEBoNAwDTAAABKgAFFAgIBgAOAOUQAA==.',['尐德']='尐德出没:BAAAKgADCggICAAAAA==.',['尽享']='尽享:BAAAKgAECgIIBAAAAA==.',['山河']='山河无恙:BAAAKgADCgEIAQAAAA==.',['岚陵']='岚陵笑笑生:BAAAKgAECgEIAgAAAA==.',['工藤']='工藤君:BAAAKgAECgIIAgAAAA==.',['布布']='布布大人:BAAAKgAECggICAAAAA==.',['帅萌']='帅萌萌:BAAAKgAECgQIBAAAAA==.',['希尔']='希尔瓦奈斯:BAAAKgAECggICAAAAA==.',['年少']='年少:BAAAKgAECgMIAwAAAA==.',['幸福']='幸福的馒头:BAAAKgADCggICwABKgAFFAgIDgABABUPAA==.',['张小']='张小彧:BAAAKgAECgYIBgAAAA==.',['归零']='归零:BAAAKgAECggIDwAAAA==.',['影舞']='影舞空映:BAABKgAFFH8IAAIUAAgIMhbUBgAmAgAUAAgIMhbUBgAmAgAAAA==.',['往昔']='往昔:BAAAKgADCggICQAAAA==.',['德芙']='德芙千夜:BAABKgAECn8WAAIOAAgI2RDlNwA3AQAOAAgI2RDlNwA3AQAAAA==.',['心有']='心有灵犀:BAAAKgAECgQIBAAAAA==.',['心理']='心理医生:BAABKgAFFH8MAAIQAAgIcxWvBAARAgAQAAgIcxWvBAARAgAAAA==.',['怒风']='怒风逐日者:BAAAKgAECgIIAgAAAA==.',['性感']='性感小水桶:BAAAKgAECgMIBQAAAA==.',['悠悠']='悠悠:BAABKgAFFH8HAAIBAAMIKiVxDAD3AAABAAMIKiVxDAD3AAABKgAFFAYIGwAHAL4eAA==.',['惩戒']='惩戒之路:BAAAKgAFFAIIAgAAAA==.',['想看']='想看大白兔吗:BAAAKgAECgIIBAAAAA==.',['愿圣']='愿圣光忽悠你:BAAAKgADCggICAAAAA==.愿圣光照耀:BAAAKgAFFAQIBAAAAA==.',['戈壁']='戈壁滩的凡人:BAAAKgAECgIIAgAAAA==.',['我们']='我们讲道理:BAABKgAFFH8KAAIQAAYIFiKmCQCQAQAQAAYIFiKmCQCQAQAAAA==.',['我发']='我发现猎物了:BAAAKgAECggICQAAAA==.',['我是']='我是小富婆:BAAAKgADCgMIAwAAAA==.我是渣男:BAAAKgAECggICAAAAA==.',['我来']='我来找鹏鹏:BAAAKgAFFAYIBAAAAA==.',['我爱']='我爱吃串串:BAAAKgAECgcICQAAAA==.',['我的']='我的特仑苏:BAAAKgADCgQIBAAAAA==.',['扛不']='扛不住啊:BAAAKgAECgYIBwAAAA==.',['护法']='护法:BAAAKgAECggICAABKgAFFAgIDQAJAOEYAA==.',['抱着']='抱着囘忆込睡:BAAAKgADCgEIAQAAAA==.',['拓跋']='拓跋菩萨:BAAAKgADCggICAAAAA==.',['挽風']='挽風:BAAAKgAFFAgIBAAAAA==.',['摸黑']='摸黑可否一吻:BAAAKgAFFAQIBAAAAA==.',['散尽']='散尽余温:BAAAKgAFFAEIAQAAAA==.',['无情']='无情哈拉少:BAABKgAFFH8GAAIUAAYIkQVHEAAvAQAUAAYIkQVHEAAvAQAAAA==.',['无敌']='无敌大波浪:BAAAKgADCggICAAAAA==.无敌小星星:BAABKgAFFH8SAAIJAAYIjRhVAgDAAQAJAAYIjRhVAgDAAQAAAA==.',['无月']='无月丶小小猎:BAAAKgAECgUIBQAAAA==.无月丶小萨:BAAAKgAECgYIBwAAAA==.无月丶筱萨:BAAAKgAFFAQIBAAAAA==.',['时光']='时光如梦:BAABKgAFFH8IAAIEAAgIPgxuCQDaAQAEAAgIPgxuCQDaAQAAAA==.',['是小']='是小龙人:BAAAKgAECgQIBAAAAA==.',['晓晓']='晓晓鱼:BAAAKgADCgEIAQAAAA==.',['晓聋']='晓聋人:BAAAKgAECggICAAAAA==.',['晚風']='晚風:BAAAKgADCgQIBAAAAA==.',['晨兮']='晨兮一蓝兮:BAAAKgADCgQICAAAAA==.晨兮一裂空:BAAAKgADCgIIAgAAAA==.',['普罗']='普罗米丶脩斯:BAAAKgADCggIDAAAAA==.',['曼曼']='曼曼的射:BAAAKgAFFAQIBAAAAA==.',['最灵']='最灵魂守卫:BAABKgAFFH8GAAIVAAYIqR+HBACeAQAVAAYIqR+HBACeAQAAAA==.',['月上']='月上魇:BAAAKgAECggICAAAAA==.',['月舒']='月舒儿:BAAAKgAECgMIAwAAAA==.',['月魅']='月魅雪影:BAAAKgAFFAQIBAAAAA==.',['有奶']='有奶就是娘:BAAAKgADCggICAAAAA==.',['有點']='有點累了:BAAAKgADCggICAAAAA==.',['木流']='木流翼:BAABKgAECn8YAAIBAAgIrhIyQgBuAQABAAgIrhIyQgBuAQABKgAFFAgICAAWAEwYAA==.',['本前']='本前珺肝:BAAAKgADCgMIAwAAAA==.',['机油']='机油加蛋:BAAAKgAECgUIBQAAAA==.',['村纱']='村纱水蜜:BAAAKgAECggICAAAAA==.',['来杯']='来杯可乐:BAAAKgAFFAQIBAAAAA==.',['杰子']='杰子:BAAAKgAFFAEIAQAAAA==.',['松鼠']='松鼠鳜鱼:BAAAKgAECgQIBAAAAA==.',['染青']='染青衣:BAABKgAFFH8RAAMCAAYIWSHDCgDhAQACAAYIWSHDCgDhAQADAAYIuRRXDQBBAQAAAA==.',['榕榕']='榕榕:BAABKgAFFH8IAAICAAgIVBuUBABhAgACAAgIVBuUBABhAgAAAA==.',['樇欲']='樇欲:BAAAKgAECgIIAgAAAA==.',['此桥']='此桥非彼桥:BAAAKgAECgcIBwABKgAFFAgICAANALEMAA==.',['武曌']='武曌:BAAAKgAECgYICgAAAA==.',['毛民']='毛民:BAABKgAFFH8IAAIUAAgI/ha2BQA8AgAUAAgI/ha2BQA8AgAAAA==.',['气宗']='气宗罪:BAAAKgAFFAIIAgAAAA==.',['氟哌']='氟哌酸:BAABKgAFFH8HAAIKAAYIwBSqCgBPAQAKAAYIwBSqCgBPAQABKgAFFAgIDgACAEoXAA==.',['水煙']='水煙清馨:BAAAKgAFFAQIBAAAAA==.',['汉堡']='汉堡怪兽:BAAAKgAFFAMIAwAAAA==.',['汐陽']='汐陽淸已泹:BAAAKgAFFAQIBAAAAA==.',['没名']='没名字取了:BAABKgAFFH8IAAIUAAgIByH1AQC3AgAUAAgIByH1AQC3AgAAAA==.',['没奶']='没奶啊:BAAAKgAECgEIAQAAAA==.',['沧海']='沧海一法:BAAAKgAECggICQAAAA==.',['治疗']='治疗小萝莉:BAABKgAFFH8KAAMRAAgIUBKVAwDXAQARAAgIUBKVAwDXAQAHAAEI8AXJIQBKAAAAAA==.',['泠时']='泠时汐汐:BAACKgAFFH8PAAIBAAgInh2qBAASAgABAAgInh2qBAASAgAqAAQKfxQAAgEACAgGGBEuANEBAAEACAgGGBEuANEBAAAA.',['泰蘭']='泰蘭德的蚊子:BAAAKgAECggIDwAAAA==.',['泰达']='泰达斯瓦:BAAAKgAECgIIAgAAAA==.',['浅唱']='浅唱丶倾雨:BAAAKgAFFAQIBAAAAA==.浅唱丶卿灼:BAAAKgAECgYIBgAAAA==.浅唱丶挽兮:BAAAKgAECgIIAgAAAA==.浅唱丶月舞:BAABKgAFFH8RAAMDAAYI5hcuCQADAQACAAYIJhZZFQBxAQADAAQI1RwuCQADAQABKgAFFAgIMwAKAK8PAA==.浅唱丶沫非:BAAAKgAECgcIBwAAAA==.浅唱丶逐风:BAABKgAFFH8HAAIgAAQI0xgRDQDUAAAgAAQI0xgRDQDUAAAAAA==.',['浅汐']='浅汐:BAAAKgAECggIDQAAAA==.',['浅澄']='浅澄色:BAAAKgAECggIEAAAAA==.',['浅灰']='浅灰灰色:BAAAKgAECgYIBgAAAA==.',['浅紫']='浅紫色:BAAAKgADCgEIAQAAAA==.',['浪花']='浪花朵朵:BAAAKgAECgMIAwAAAA==.',['浮生']='浮生六世:BAABKgAFFH8IAAIJAAQI4BS1FQBBAQAJAAQI4BS1FQBBAQAAAA==.浮生若梦月:BAAAKgAECgEIAQAAAA==.',['浴火']='浴火玄冰:BAAAKgAECgUIAQAAAA==.',['海德']='海德林:BAAAKgAFFAYIBAABKgAFFAgIDwABAJ4dAA==.',['液化']='液化气大王:BAAAKgAECgYIBwAAAA==.',['淚茫']='淚茫:BAAAKgAECggIDAAAAA==.',['温蕾']='温蕾萨丶:BAAAKgAECgQIBAAAAA==.',['游侠']='游侠霜刃:BAAAKgAECgEIAQAAAA==.',['滅壩']='滅壩:BAAAKgADCgcIBwAAAA==.',['满穗']='满穗:BAAAKgAFFAMIAwAAAA==.',['火小']='火小火:BAABKgAFFH8GAAIXAAYIlhB0BwBsAQAXAAYIlhB0BwBsAQAAAA==.',['灭团']='灭团乄之星:BAAAKgAECgMIAwAAAA==.',['灵悟']='灵悟贤淑:BAAAKgADCgUIBQAAAA==.',['灵魂']='灵魂摆渡人:BAAAKgADCggICAAAAA==.灵魂的温度:BAAAKgAECgUIBQAAAA==.',['炽热']='炽热风暴:BAAAKgADCgQIBAAAAA==.',['烈火']='烈火焚天而上:BAAAKgAECgMIBQABKgAECgUICgAPAAAAAA==.',['烈焰']='烈焰的颂歌:BAAAKgADCgEIAQAAAA==.',['烟雨']='烟雨笙歌:BAABKgAECn8YAAITAAgIwBpRCgAvAgATAAgIwBpRCgAvAgAAAA==.',['無眀']='無眀:BAAAKgAECggICAAAAA==.',['無趣']='無趣:BAAAKgAECgMIAgAAAA==.',['燃烧']='燃烧的胸毛:BAAAKgAECgYIBgAAAA==.',['爱比']='爱比血更冷:BAAAKgAECgQIBAAAAA==.',['爱美']='爱美莉:BAAAKgAECgIIAgABKgAFFAgIGwALAI0bAA==.',['牛古']='牛古力的圣光:BAAAKgAECgUIBQAAAA==.',['牧北']='牧北:BAAAKgAECggICwAAAA==.',['牧小']='牧小师:BAAAKgAECgUIBQAAAA==.',['特么']='特么尴尬了:BAAAKgADCgMIAwAAAA==.',['狂妄']='狂妄之徒:BAABKgAECn8cAAMMAAgImQhHGwCUAAAMAAgIkQZHGwCUAAALAAEIQhKGlwA3AAAAAA==.',['狂的']='狂的很:BAAAKgADCgIIAgAAAA==.',['狠呆']='狠呆:BAABKgAFFH8QAAMTAAgImRe2BQACAgATAAgIfhW2BQACAgAIAAQIWhthFgD2AAAAAA==.',['狠心']='狠心:BAAAKgAECgMIAwAAAA==.',['独角']='独角:BAAAKgADCgcIBwAAAA==.',['狮子']='狮子座流星雨:BAAAKgAFFAUIAgABKgAFFAgICAAWAEwYAA==.',['狼顾']='狼顾炙鬼:BAAAKgADCggICgAAAA==.',['猎心']='猎心娃娃:BAAAKgAECgYICQAAAA==.',['猎杀']='猎杀追魂:BAAAKgADCggICAAAAA==.',['猩红']='猩红毒针:BAABKgAFFH8SAAQFAAYIrx5NBgCfAQAFAAYIAhVNBgCfAQAEAAYISR6kDQCLAQAVAAIIqCKmEQCaAAAAAA==.',['猪皮']='猪皮毛:BAABKgAFFH8HAAIUAAYIOBKSEAAqAQAUAAYIOBKSEAAqAQAAAA==.',['电喵']='电喵喵:BAAAKgAFFAIIAgAAAA==.',['番茄']='番茄牛腩:BAAAKgADCgYIBgAAAA==.',['疯串']='疯串祥子:BAAAKgAFFAQIBAAAAA==.',['瘟猪']='瘟猪的萌柯基:BAABKgAFFH8KAAICAAYI2RUcEgCJAQACAAYI2RUcEgCJAQAAAA==.',['白凝']='白凝冰:BAAAKgAFFAQIBAAAAA==.',['白夜']='白夜桑:BAABKgAFFH8GAAINAAYIuBdHFAB4AQANAAYIuBdHFAB4AQAAAA==.',['白尾']='白尾巴:BAACKgAFFH83AAIIAAgIRR+8BABcAgAIAAgIRR+8BABcAgAqAAQKf0MAAggACAjeJWAEAAADAAgACAjeJWAEAAADAAAA.',['白银']='白银神圣之手:BAAAKgAECgQIBAAAAA==.',['皮蛋']='皮蛋頭頭:BAAAKgAECgUIBQAAAA==.',['相顾']='相顾无言:BAAAKgAECgUIBQAAAA==.',['矮子']='矮子小:BAAAKgAECgMIAwAAAA==.',['硕少']='硕少爷:BAAAKgAECgIIAgAAAA==.',['碱菪']='碱菪莨东:BAABKgAFFH8RAAIGAAgILBlHAABjAgAGAAgILBlHAABjAgAAAA==.',['祝我']='祝我年少有为:BAABKgAFFH8MAAIdAAYIqh0CCgCtAQAdAAYIqh0CCgCtAQAAAA==.',['神經']='神經寎發鈼:BAABKgAFFH8IAAIGAAgIFw35BAAgAgAGAAgIFw35BAAgAgAAAA==.',['神经']='神经毒素:BAAAKgADCggICgAAAA==.',['神聖']='神聖騎士:BAAAKgAECggICAAAAA==.',['神龙']='神龙丸:BAABKgAFFH8FAAIZAAQIphQDDgDgAAAZAAQIphQDDgDgAAAAAA==.',['秘言']='秘言星轨:BAABKgAFFH8LAAMRAAQIXiCREgAGAQARAAQIJByREgAGAQAHAAQIMxsfGQDvAAAAAA==.',['秦始']='秦始皇嬴政:BAAAKgAFFAMIAwAAAA==.',['秦末']='秦末王嬴婴:BAABKgAFFH8QAAIUAAgIcB4FAgCWAgAUAAgIcB4FAgCWAgAAAA==.',['程逸']='程逸:BAAAKgADCgcIBwAAAA==.',['究极']='究极体葫芦娃:BAAAKgADCgYIBgAAAA==.',['空手']='空手抡大炮:BAABKgAECn9OAgIdAAgIkSY+AQAVAwAdAAgIkSY+AQAVAwAAAA==.',['窗户']='窗户里的猫:BAAAKgAFFAQIBAAAAA==.',['竹林']='竹林萌主:BAAAKgADCgcIBwAAAA==.',['第一']='第一次玩这个:BAAAKgAECgEIAQAAAA==.',['箬叶']='箬叶花吹雪:BAAAKgAFFAMIAwAAAA==.',['米拉']='米拉圆滚滚:BAAAKgAECgMIAwAAAA==.',['粉红']='粉红体育生:BAAAKgAECgUIBgAAAA==.粉红姐姐:BAABKgAECn8aAAIJAAgIdRGceABhAQAJAAgIdRGceABhAQAAAA==.',['糯米']='糯米糖:BAAAKgAECggICAAAAA==.糯米蛟:BAAAKgAFFAQIBAAAAA==.',['純潔']='純潔滴惡魔:BAABKgAECn8YAAMdAAgIkAA4fgAsAAAdAAgIkAA4fgAsAAAeAAEIZADfUgADAAAAAA==.',['索尔']='索尔奥丁森:BAABKgAECn8oAAMXAAgIrxFUGQCNAQAXAAgIrxFUGQCNAQABAAgIMw+uHQBBAQAAAA==.',['紫幻']='紫幻云:BAAAKgAFFAUIAQAAAA==.',['紫竹']='紫竹:BAAAKgADCgcIBwAAAA==.',['紫色']='紫色琉璃:BAABKgAECn8dAAIIAAYIpyFhRwDeAQAIAAYIpyFhRwDeAQAAAA==.',['絲沫']='絲沫沫:BAAAKgAECgQIBAAAAA==.',['红发']='红发丶四皇:BAABKgAFFH8FAAIBAAMIhhJHIgCPAAABAAMIhhJHIgCPAAAAAA==.',['红花']='红花多绿叶少:BAAAKgAECgUICQAAAA==.',['绝命']='绝命小萝莉:BAAAKgAECgcIBwAAAA==.',['绝舞']='绝舞:BAABKgAECn9TAAIHAAgI/yXXAwDXAgAHAAgI/yXXAwDXAgAAAA==.绝舞倾城丶:BAABKgAECn8wAAILAAgI0CKrDQCZAgALAAgI0CKrDQCZAgAAAA==.',['维桢']='维桢小滿:BAAAKgAECgUIBQAAAA==.',['缺奶']='缺奶的小德:BAAAKgAECggICgAAAA==.',['罗莎']='罗莎莉娅:BAABKgAFFH8VAAMLAAYIZCamAAA8AgALAAYIZCamAAA8AgAMAAMITwkyGQCFAAAAAA==.',['美特']='美特奥拉:BAAAKgAFFAIIAgAAAA==.',['羽戎']='羽戎:BAAAKgAECgEIAQAAAA==.羽戎丶:BAAAKgAFFAYIAQAAAA==.',['翻出']='翻出墙头:BAAAKgAECgYICgAAAA==.',['老衲']='老衲法号亂来:BAABKgAFFH8HAAILAAQIVBWYLgDCAAALAAQIVBWYLgDCAAAAAA==.',['腮帮']='腮帮一奥雷娅:BAAAKgAECgcICwAAAA==.腮帮一狼牙变:BAAAKgAECgYIBgAAAA==.腮帮击死:BAAAKgAECgEIAQAAAA==.',['自摸']='自摸九子连环:BAAAKgAECgQICAAAAA==.',['自渡']='自渡:BAAAKgADCgQIBAAAAA==.',['致命']='致命一板凳:BAAAKgADCgEIAQAAAA==.',['舞宝']='舞宝宝丶:BAABKgAECn86AAIIAAgI7yQABwDqAgAIAAgI7yQABwDqAgAAAA==.',['艾瑞']='艾瑞利娜:BAAAKgADCggICAAAAA==.',['花丶']='花丶清影:BAAAKgADCggICAAAAA==.',['苏好']='苏好:BAABKgAFFH8GAAIRAAYIQBfJCACQAQARAAYIQBfJCACQAQAAAA==.',['苏浅']='苏浅浅:BAABKgAFFH8JAAMRAAQIPSY3BABUAQARAAQIPSY3BABUAQAYAAEI9RXvIgBQAAAAAA==.',['若素']='若素:BAAAKgAFFAQIBAAAAA==.',['苦苓']='苦苓林:BAAAKgAECgIIAgAAAA==.',['苹果']='苹果太子:BAAAKgAECgEIAQAAAA==.',['范尼']='范尼是徳噜咿:BAACKgAFFH8bAAMOAAQI4h82EQAVAQAOAAQI4h82EQAVAQAhAAMIiQiADQBBAAAqAAQKfxoABA4ACAjKGV4gAMUBAA4ACAjKGV4gAMUBACEAAgjuGUwhAJIAAA0AAQgAAI3vAAAAAAAA.',['荒鉤']='荒鉤爪:BAACKgAFFH82AAMhAAgIoCBHAACiAQAhAAYICSFHAACiAQANAAIIMB4lWABSAAAqAAQKfzsAAyEACAhyJeIBAOICACEACAhyJeIBAOICAA0AAQjwEQe/AEQAAAAA.',['莱尔']='莱尔米斯:BAAAKgADCggICAAAAA==.',['菜刀']='菜刀五哥:BAAAKgADCggIDQAAAA==.',['萨小']='萨小满:BAAAKgAECgEIAQAAAA==.',['萨拉']='萨拉塔丝:BAAAKgADCgIIAgAAAA==.',['蓝凌']='蓝凌儿:BAABKgAECn9BAAIHAAgILyYAAgDyAgAHAAgILyYAAgDyAgAAAA==.',['蕾希']='蕾希:BAAAKgAECggIDgAAAA==.',['薇薇']='薇薇灬乊笑:BAAAKgADCgIIAgAAAA==.',['薩拉']='薩拉塔斯:BAAAKgAECgYIBwAAAA==.',['薩滿']='薩滿生亦何歡:BAABKgAECn8UAAIBAAgInwpoYQAGAQABAAgInwpoYQAGAQAAAA==.',['蘭香']='蘭香佳樹:BAAAKgADCgcIBwAAAA==.',['蛋之']='蛋之祖:BAAAKgAECgQIBAAAAA==.',['蜜糖']='蜜糖罐子:BAAAKgAECggICgAAAA==.',['螢火']='螢火虫:BAAAKgAFFAQIBAAAAA==.',['血渊']='血渊丶:BAAAKgADCgQIBAAAAA==.',['衍衍']='衍衍念璐璐:BAAAKgAECggICAABKgAFFAYICgAUAPcYAA==.衍衍想璐璐:BAABKgAFFH8KAAIUAAYI9xjnEgBvAQAUAAYI9xjnEgBvAQAAAA==.',['西灬']='西灬鑫:BAABKgAFFH8IAAICAAgIDRrIBABbAgACAAgIDRrIBABbAgAAAA==.',['要你']='要你命叁仟:BAAAKgAECgIIAwAAAA==.要你妹三千:BAAAKgAECgcICwAAAA==.',['诡术']='诡术妖僧:BAAAKgADCgIIAgAAAA==.',['诺斯']='诺斯勒:BAAAKgAECgMIBAAAAA==.',['贝塔']='贝塔:BAAAKgAECggIEgAAAA==.',['贼神']='贼神归来:BAABKgAFFH8fAAQGAAQIRBbHFgDwAAAGAAQIRBbHFgDwAAAiAAMIbwbOBQCgAAAjAAQI2QXEBQCNAAAAAA==.',['超越']='超越星辰:BAAAKgAECgQIBgAAAA==.',['跑魂']='跑魂战神:BAACKgAFFH8QAAIkAAQIoBTsBQAVAQAkAAQIoBTsBQAVAQAqAAQKfz0AAiQACAiGIoUEAJgCACQACAiGIoUEAJgCAAAA.',['软软']='软软的小枕头:BAABKgAFFH8OAAMIAAYI8BYlAwCtAQAIAAYI6RMlAwCtAQATAAQIvh+RKQDEAAAAAA==.',['轻轻']='轻轻过客:BAABKgAECn8VAAIJAAgI0Rv+SwDbAQAJAAgI0Rv+SwDbAQAAAA==.',['边边']='边边叨叨:BAABKgAFFH8GAAIMAAYIwAL8EQCzAAAMAAYIwAL8EQCzAAAAAA==.',['追利']='追利:BAAAKgADCgUIBQAAAA==.',['逆风']='逆风射三丈丶:BAAAKgAECgIIAgAAAA==.',['逍遥']='逍遥魔骑:BAAAKgADCggICAAAAA==.',['逐风']='逐风猎影:BAAAKgADCggICAAAAA==.逐风箭影:BAAAKgAFFAIIAgAAAA==.',['逝去']='逝去的荣誉:BAABKgAFFH8HAAITAAYIdwqaEADxAAATAAYIdwqaEADxAAAAAA==.',['遇一']='遇一人白首:BAABKgAFFH8HAAMYAAcIGQoxDQAtAQAYAAYI2goxDQAtAQAHAAEIMQJcPwA6AAAAAA==.',['那个']='那个是谁谁啊:BAAAKgADCgYIBgAAAA==.那个翼神回来:BAABKgAFFH8SAAQlAAYIoiDaBAAGAQAUAAYIVRxFFQBZAQAlAAUIkRraBAAGAQAmAAII6x+6DgBuAAABKgAFFAgIEAAUANkjAA==.',['邪洛']='邪洛:BAABKgAECn8bAAIVAAgIYiJYEQB1AgAVAAgIYiJYEQB1AgAAAA==.',['重温']='重温旧梦:BAAAKgAECgEIAgAAAA==.',['野生']='野生脆脆鲨:BAAAKgAECgIIAgAAAA==.',['金小']='金小豹:BAAAKgAECgYIBwAAAA==.',['钢牙']='钢牙:BAAAKgAFFAQIBAAAAA==.',['锌铁']='锌铁锡铅氢:BAABKgAFFH8LAAIJAAYI3SBzFwCgAQAJAAYI3SBzFwCgAQAAAA==.',['长生']='长生天:BAAAKgAECgIIAwAAAA==.',['闪光']='闪光:BAAAKgAECgIIAwAAAA==.',['阳光']='阳光灬宅男:BAAAKgAECgQIBAAAAA==.',['阿修']='阿修罗之伤:BAAAKgADCgEIAQAAAA==.',['雅灭']='雅灭蝶:BAAAKgADCggICAAAAA==.',['雪碧']='雪碧碧:BAABKgAECn81AAIHAAgIqSZmAQD9AgAHAAgIqSZmAQD9AgAAAA==.',['雾中']='雾中仙:BAAAKgAECgQIBAAAAA==.',['霍尔']='霍尔德尔:BAAAKgADCgUIBQAAAA==.',['霜柚']='霜柚:BAAAKgAECgEIAQAAAA==.',['霞之']='霞之丘诗羽丶:BAAAKgAECgIIAgAAAA==.',['霸天']='霸天连红:BAAAKgAECgYIBwAAAA==.',['霸萨']='霸萨卡:BAABKgAFFH8QAAQnAAgISRTJAwAXAgAnAAgILRHJAwAXAgAeAAQIqxR5CgCAAAAdAAIIRgaPGwBnAAAAAA==.',['青灵']='青灵儿:BAAAKgAECggICgAAAA==.',['青葵']='青葵:BAAAKgADCgUIBwAAAA==.',['青鸟']='青鸟飞鱼:BAAAKgAECgMIBAAAAA==.',['靜椛']='靜椛氺玥:BAAAKgAECgUIBQAAAA==.',['風暴']='風暴猎手:BAAAKgADCggICAAAAA==.',['风形']='风形:BAAAKgAECgYICAAAAA==.',['风车']='风车车儿:BAAAKgADCggICAAAAA==.',['飞沙']='飞沙走奶:BAAAKgAFFAQIAgAAAA==.',['香奈']='香奈奈:BAAAKgAECgYIBwAAAA==.',['马应']='马应龙之怒:BAABKgAFFH8IAAILAAQIqAmUNQCqAAALAAQIqAmUNQCqAAAAAA==.',['高冷']='高冷丶殇:BAAAKgAECgEIAQAAAA==.',['高风']='高风騷:BAAAKgAECgUIBQAAAA==.',['鬼魂']='鬼魂:BAAAKgADCgMIAwAAAA==.',['鬼魅']='鬼魅流觞:BAABKgAFFH8GAAMUAAYIDRDgIwDqAAAUAAUICg/gIwDqAAAmAAEIFhSGKABIAAAAAA==.',['魅猎']='魅猎:BAACKgAFFH8XAAIIAAMIBRknFQDkAAAIAAMIBRknFQDkAAAqAAQKfxsAAggACAjnHMQ9AAACAAgACAjnHMQ9AAACAAAA.',['魔行']='魔行天:BAAAKgADCggICAAAAA==.',['魔魔']='魔魔罗伊:BAAAKgAECgUIBQAAAA==.',['鲸落']='鲸落:BAAAKgAFFAIIBAAAAA==.',['鸽鸽']='鸽鸽:BAAAKgAFFAEIAQAAAA==.',['鹿紫']='鹿紫云丶:BAABKgAFFH8GAAITAAYI4QqyGgAYAQATAAYI4QqyGgAYAQAAAA==.',['麻宫']='麻宫雅典娜:BAABKgAFFH8LAAIJAAMIExxIKwDEAAAJAAMIExxIKwDEAAAAAA==.',['黄糖']='黄糖拿铁:BAAAKgAFFAQIBAAAAA==.',['黯闪']='黯闪:BAAAKgAECgUIAQAAAA==.',['龙凤']='龙凤汤:BAAAKgADCgMIAwAAAA==.',['龙抄']='龙抄手:BAAAKgAECgMIAwAAAA==.',['龙虾']='龙虾团团:BAAAKgAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end