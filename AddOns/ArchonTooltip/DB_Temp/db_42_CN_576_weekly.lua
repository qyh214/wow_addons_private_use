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
 local lookup = {'Paladin-Retribution','DemonHunter-Havoc','DeathKnight-Unholy','Evoker-Devastation','DeathKnight-Blood','Warrior-Fury','Warrior-Arms','Paladin-Protection','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Druid-Guardian','Druid-Restoration','Priest-Shadow','Priest-Holy','Priest-Discipline','Shaman-Restoration','DemonHunter-Vengeance','Rogue-Subtlety','Rogue-Assassination','Monk-Windwalker','Unknown-Unknown','Evoker-Preservation','Mage-Fire','Shaman-Elemental','Monk-Mistweaver','Mage-Arcane','Warlock-Destruction','Warrior-Protection','Mage-Frost','Paladin-Holy','Warlock-Demonology','Monk-Brewmaster','Shaman-Enhancement',}; local provider = {region='CN',realm='克洛玛古斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={As='Asuka:BAAAKgAECgcICgAAAA==.',Be='Ben:BAAAKgADCgIIAgAAAA==.',Bo='Boom:BAAAKgAFFAMIAwAAAA==.',Ca='Cathy:BAABKgAFFH8IAAIBAAgISQ2uCwDoAQABAAgISQ2uCwDoAQAAAA==.',Co='Corson:BAABKgAECn8fAAICAAgISBWsOADIAQACAAgISBWsOADIAQAAAA==.',Di='Discovergpb:BAAAKgADCgYIBgAAAA==.',Dk='Dk:BAABKgAFFH8GAAIDAAYIKhJWGABbAQADAAYIKhJWGABbAQAAAA==.',Do='Dontouchme:BAAAKgAECgYICQAAAA==.Dontouchmee:BAAAKgAECggICwAAAA==.',Dr='Dragond:BAABKgAFFH8GAAIEAAYIcBxAAQDhAQAEAAYIcBxAAQDhAQAAAA==.Dreamboat:BAAAKgAFFAMIAwAAAA==.Dripuhlz:BAABKgAFFH8JAAMFAAQIkAzZGwB5AAADAAQIkAwXOwCxAAAFAAQI1QPZGwB5AAAAAA==.Dryad:BAAAKgADCggICAAAAA==.',Du='Dunkel:BAAAKgAECgUIBQAAAA==.',Ge='Geminisaga:BAAAKgAECggICAAAAA==.',He='Heiheiya:BAAAKgAECgcIDQAAAA==.',Ju='Juechen:BAACKgAFFH9JAAMGAAgIEiC1AQDKAgAGAAgIrR+1AQDKAgAHAAUIuRlADABKAQAqAAQKfzgAAwYACAjHJqsAACADAAYACAjHJqsAACADAAcAAQjIJJROAGwAAAAA.',Ki='Kilig:BAABKgAFFH8OAAMBAAMIQAxeWADAAAABAAMIQAxeWADAAAAIAAMIWQePIgBvAAAAAA==.',Le='Lellow:BAAAKgAECgIIAgAAAA==.',Mw='Mwmwmwmwm:BAAAKgADCgIIAgAAAA==.',My='Myz:BAAAKgAFFAQIBAAAAA==.',Na='Naaruia:BAAAKgAECggICAAAAA==.',On='Onettff:BAAAKgADCgYIBQAAAA==.',Pa='Paradiso:BAAAKgADCggIDgAAAA==.',Re='Resolution:BAAAKgADCgIIAgAAAA==.',Sn='Snoopg:BAAAKgAECgQIBwAAAA==.',Va='Valkyrjja:BAAAKgAFFAQIBAAAAA==.',['一阵']='一阵雨:BAAAKgAFFAIIAgAAAA==.',['七年']='七年时光:BAABKgAFFH8GAAMJAAYIwwxsEQBsAQAJAAUIzg5sEQBsAQAKAAEIjgLCVgAnAAAAAA==.',['不如']='不如拂袖去:BAAAKgAECgEIAQAAAA==.',['不泰']='不泰迷糊:BAABKgAFFH8GAAIEAAYI8QCxHABwAAAEAAYI8QCxHABwAAAAAA==.',['不行']='不行就是不行:BAAAKgADCggICAAAAA==.',['东京']='东京奶德:BAACKgAFFH8rAAILAAQIKBX4FgDhAAALAAQIKBX4FgDhAAAqAAQKfy0ABAsACAgdHmwuAAQCAAsACAgdHmwuAAQCAAwAAwi+Do8TAIYAAA0AAQh8DCiMACoAAAAA.',['丨卿']='丨卿本佳人丨:BAAAKgADCgIIAgAAAA==.',['丩爱']='丩爱儿丩:BAABKgAFFH8IAAIBAAgIYwnbEgDFAQABAAgIYwnbEgDFAQAAAA==.',['丶月']='丶月下起司猫:BAAAKgAECgYICQAAAA==.',['丶箏']='丶箏箏紙鳶:BAAAKgAECgYICQAAAA==.',['丶苍']='丶苍井那么空:BAAAKgAECgYIBgAAAA==.',['丶逍']='丶逍遥遥:BAABKgAFFH8WAAQOAAUIIx9XFADBAAAOAAMIWSFXFADBAAAPAAUIVBsaEgC0AAAQAAMItwOpFwCiAAABKgAFFAgICgAPANkWAA==.',['丸子']='丸子龙:BAAAKgAECgQIBAAAAA==.',['丹总']='丹总:BAAAKgADCgYIAgAAAA==.',['九指']='九指战神:BAABKgAFFH8HAAMGAAUIsxOwDACCAQAGAAUI3w+wDACCAQAHAAIIHBUyCwDBAAAAAA==.',['二两']='二两三钱:BAABKgAFFH8RAAIGAAYIsBhVAQDIAQAGAAYIsBhVAQDIAQAAAA==.',['交出']='交出你的波波:BAABKgAFFH8HAAIJAAMIfQ86MgDFAAAJAAMIfQ86MgDFAAAAAA==.',['人间']='人间腊月天:BAAAKgAFFAQIBAAAAA==.',['亿眼']='亿眼丁真:BAAAKgAFFAQIBAAAAA==.',['今日']='今日花如雪灬:BAABKgAECn8VAAIRAAgI+hbhNACjAQARAAgI+hbhNACjAQAAAA==.',['今比']='今比明:BAAAKgAECgEIAQAAAA==.',['从小']='从小头就硬:BAAAKgAFFAYIBAAAAA==.',['仙吟']='仙吟:BAAAKgADCggICAAAAA==.',['代表']='代表太阳:BAAAKgAECgUICQAAAA==.',['以太']='以太:BAAAKgAECggIDwAAAA==.',['伊莉']='伊莉奥拉:BAAAKgAECgQIBAAAAA==.',['伊蕾']='伊蕾娜:BAACKgAFFH8FAAMCAAMIrAT6OwCNAAACAAMIFQT6OwCNAAASAAIIRQU3IgBSAAAqAAQKfx8AAwIACAh1DiJVAFEBAAIABwhLDyJVAFEBABIACAgjCnI2AOwAAAAA.',['伊露']='伊露辛德拉:BAAAKgADCgQIBQAAAA==.',['伤心']='伤心灬小箭:BAAAKgAECggICAAAAA==.',['佐西']='佐西:BAAAKgAECgcIEAAAAA==.',['你看']='你看不見我:BAAAKgAECgYIBgAAAA==.',['佳运']='佳运:BAAAKgAFFAQIBAAAAA==.',['侯鳥']='侯鳥的麻糖:BAAAKgAECgcICAAAAA==.',['光芒']='光芒:BAABKgAFFH8KAAMIAAYIuRcwCwBFAQAIAAYI+RQwCwBFAQABAAQIJyMjQADxAAAAAA==.光芒幻火:BAAAKgAFFAgIAgAAAA==.',['克拉']='克拉拉莱辛:BAACKgAFFH8ZAAIFAAQIpgnZKABzAAAFAAQIpgnZKABzAAAqAAQKfxcAAgUACAgIDgkkACgBAAUACAgIDgkkACgBAAAA.',['公子']='公子別這樣:BAACKgAFFH8FAAITAAMIyQcpBgCSAAATAAMIyQcpBgCSAAAqAAQKfxoAAxMACAgyEO8TALQBABMACAgyEO8TALQBABQAAwgPC6FDAFUAAAAA.',['兰若']='兰若仙踪:BAABKgAFFH8JAAIVAAMIYR0HEgDSAAAVAAMIYR0HEgDSAAAAAA==.',['关云']='关云短:BAAAKgADCggICAABKgAFFAgIAgAWAAAAAA==.',['养啥']='养啥死啥:BAABKgAFFH8FAAIMAAMI5wgaBgBwAAAMAAMI5wgaBgBwAAAAAA==.',['冰峰']='冰峰灬红尘:BAABKgAFFH8YAAIDAAYIIR4TBgAIAgADAAYIIR4TBgAIAgAAAA==.',['净蚀']='净蚀加残暴:BAAAKgAECgcIBwAAAA==.',['凡圣']='凡圣:BAAAKgAECgIIAgAAAA==.',['凤息']='凤息颜:BAAAKgAFFAQIBAAAAA==.',['凤狂']='凤狂神:BAACKgAFFH8lAAMKAAQI1AyHGACfAAAJAAQIUAuwHAC1AAAKAAQIwQqHGACfAAAqAAQKfyMAAwkACAiVFN1YAKYBAAkACAhVEt1YAKYBAAoABQhjEUlVAPwAAAAA.',['列奥']='列奥德罗:BAAAKgAECgYICAAAAA==.',['刘波']='刘波儿:BAABKgAFFH8KAAMEAAQIeRHgDwDUAAAEAAQIeRHgDwDUAAAXAAMI/wvxBADCAAAAAA==.',['刹那']='刹那回首:BAAAKgAECggICAAAAA==.',['加农']='加农多夫:BAABKgAECn8oAAMKAAgIxSDFHAAVAgAKAAgI/BzFHAAVAgAJAAgITyCRKgAFAgAAAA==.',['劣人']='劣人蜀黍:BAAAKgADCggICAAAAA==.',['匀匀']='匀匀和炆炆:BAABKgAFFH8IAAINAAgIiwxFBgC1AQANAAgIiwxFBgC1AQAAAA==.',['北斗']='北斗:BAAAKgAECgMIAwAAAA==.',['南波']='南波吐:BAAAKgAECgMIAwAAAA==.',['卡嘉']='卡嘉莉:BAACKgAFFH8XAAMPAAQIDwqYFQCUAAAQAAQIHQm9IQCdAAAPAAQITgaYFQCUAAAqAAQKfyIAAw8ACAiUECM3AGEBAA8ACAitDyM3AGEBABAABAijC0ZTAKEAAAAA.',['原罪']='原罪學者:BAAAKgAFFAQIBAABKgAFFAgIDAAFAFwZAA==.',['吃肥']='吃肥皂吐泡泡:BAAAKgADCggICAAAAA==.',['后裔']='后裔:BAAAKgAECgcIBwAAAA==.',['咋变']='咋变都有型:BAAAKgADCgYIBgAAAA==.',['咔咔']='咔咔饕餮:BAAAKgAECgUIBQAAAA==.',['咸鱼']='咸鱼酱:BAAAKgADCgIIAgABKgAECggIKQAPAE4eAA==.',['哎撸']='哎撸微:BAABKgAECn8ZAAMBAAgIASWYCQDvAgABAAgIASWYCQDvAgAIAAEITgL6bgAGAAAAAA==.',['唐山']='唐山浪打浪:BAAAKgAECgUIBgAAAA==.',['嗜血']='嗜血灬先祖:BAAAKgAECggICQAAAA==.嗜血灬圣骑:BAAAKgAECgUICAAAAA==.嗜血灬邪神:BAAAKgAECgQIBwAAAA==.嗜血灬阳哥:BAAAKgAECgMIBgAAAA==.',['囍乐']='囍乐:BAAAKgAECgYICgAAAA==.',['圣光']='圣光大镖客:BAAAKgAECgIIAgAAAA==.圣光老哥:BAABKgAFFH8JAAIBAAMIow/RKADEAAABAAMIow/RKADEAAAAAA==.',['圣流']='圣流沙:BAAAKgAFFAEIAQAAAA==.',['圣者']='圣者轻尘:BAAAKgAECggICAAAAA==.',['圣骑']='圣骑审判你:BAAAKgADCgIIAgAAAA==.圣骑审判者:BAABKgAECn8dAAIBAAgIfhiDZwDLAQABAAgIfhiDZwDLAQAAAA==.',['夏夜']='夏夜星辰:BAAAKgADCggICQAAAA==.',['夏日']='夏日配角:BAAAKgADCggICAAAAA==.',['夜魇']='夜魇月:BAAAKgADCggICAAAAA==.',['大呲']='大呲花:BAAAKgAECgcIDAAAAA==.',['大火']='大火收汁:BAAAKgAFFAMIAwAAAA==.',['大鹌']='大鹌鹑:BAAAKgAFFAQIBAAAAA==.',['天天']='天天小妞妞:BAAAKgAECgQIBAAAAA==.',['天子']='天子传奇:BAAAKgAFFAQIAgABKgAFFAgICAAJAHkgAA==.',['天权']='天权凝光:BAAAKgAECgEIAQAAAA==.',['天沐']='天沐:BAAAKgADCggIEAAAAA==.',['天色']='天色满影:BAABKgAFFH8GAAIRAAYIPxhOCwCSAQARAAYIPxhOCwCSAQAAAA==.',['天谴']='天谴之箭:BAAAKgADCggICAAAAA==.',['夯夯']='夯夯面包代购:BAABKgAFFH8MAAIYAAgICRf5AwDMAQAYAAgICRf5AwDMAQAAAA==.',['奈亚']='奈亚子:BAAAKgAFFAQIBAAAAA==.',['奈何']='奈何桥下约会:BAACKgAFFH8YAAIRAAQIyRjKJwDXAAARAAQIyRjKJwDXAAAqAAQKfyAAAxEACAjAGP8sANYBABEACAjAGP8sANYBABkAAwgKAzmEAC4AAAAA.',['奥丁']='奥丁之子:BAAAKgAECgEIAQAAAA==.',['奶住']='奶住大饼:BAAAKgAECgcIEQAAAA==.',['妖吻']='妖吻:BAABKgAFFH8IAAIJAAYIJxgHDwCGAQAJAAYIJxgHDwCGAQABKgAFFAgIBAAWAAAAAA==.',['娅希']='娅希:BAAAKgAFFAQIBAAAAA==.',['娜娜']='娜娜莫女王:BAACKgAFFH8nAAIaAAQIKBm0EQDeAAAaAAQIKBm0EQDeAAAqAAQKfysAAxoACAibHnYgAOoBABoACAibHnYgAOoBABUABQjjB6tXAJ0AAAAA.',['嫩绿']='嫩绿宝宝:BAAAKgADCgcIBwAAAA==.',['子弟']='子弟兵:BAAAKgAECgUIBQAAAA==.',['存钱']='存钱罐罐:BAAAKgAFFAQIBAAAAA==.',['孤身']='孤身伴月影:BAACKgAFFH8nAAILAAQIhBklKgDqAAALAAQIhBklKgDqAAAqAAQKfyoAAwsACAgDHqwLADsCAAsACAgDHqwLADsCAA0AAgjVEgZrAHUAAAAA.',['学院']='学院路潘粤明:BAAAKgAECggIEAAAAA==.',['寂寞']='寂寞的冷月:BAAAKgAECgYIBgAAAA==.',['寻找']='寻找平横:BAAAKgAECggICAAAAA==.寻找平衡:BAAAKgAECgEIAQAAAA==.寻找苹烆:BAAAKgAFFAQIBAAAAA==.寻找苹鸻:BAABKgAFFH8UAAIEAAQIZRUoEwDZAAAEAAQIZRUoEwDZAAAAAA==.',['将军']='将军百戰死:BAAAKgAECggICAAAAA==.',['小夜']='小夜子:BAAAKgAECgQIBAAAAA==.',['小小']='小小刘啊:BAAAKgADCggICAAAAA==.',['小时']='小时候很乖:BAAAKgADCggICAAAAA==.',['小火']='小火慢炖:BAACKgAFFH8lAAMYAAgI+BaNCAC8AQAYAAgI+BaNCAC8AQAbAAII0xwKLgCsAAAqAAQKf0IAAxgACAjEIWISAIgCABgACAjEIWISAIgCABsABAi7G2xBADsBAAAA.',['小骑']='小骑士:BAABKgAFFH8MAAIBAAQIew6uJADdAAABAAQIew6uJADdAAAAAA==.',['小鱼']='小鱼家的包菜:BAAAKgAECgUIBQAAAA==.',['小龙']='小龙侠:BAAAKgADCgMIAwABKgAFFAYICwAIAOsLAA==.',['尐晶']='尐晶晶:BAABKgAFFH8QAAMBAAYI2xiMGQCSAQABAAYI2RiMGQCSAQAIAAYIjRA8DgAaAQAAAA==.',['就爱']='就爱吃面:BAAAKgAECgMIBgAAAA==.',['岚影']='岚影落:BAAAKgAFFAIIBAAAAA==.',['左手']='左手战狂:BAABKgAFFH8FAAINAAMI0RtbFgDuAAANAAMI0RtbFgDuAAAAAA==.',['帅帅']='帅帅的锅巴:BAAAKgAECggICAAAAA==.',['希尔']='希尔瓦哪斯:BAAAKgADCggICAAAAA==.',['幕色']='幕色精灵:BAAAKgAECgEIAQAAAA==.',['幻月']='幻月傻僈:BAAAKgAECgQIBAAAAA==.幻月流苏:BAAAKgAECgcIBwAAAA==.',['幼稚']='幼稚園茶妹:BAAAKgAECgMIAwAAAA==.',['张小']='张小凡:BAAAKgAECggIDgAAAA==.',['徐浩']='徐浩嘉:BAAAKgAECgUIBQAAAA==.',['微笑']='微笑的眼睛:BAAAKgADCgEIAQAAAA==.',['忘却']='忘却忧伤:BAAAKgADCgQIBAAAAA==.',['忧郁']='忧郁战婶:BAABKgAECn8YAAIGAAgIZRT/IADLAQAGAAgIZRT/IADLAQAAAA==.',['快乐']='快乐的小面包:BAAAKgAECgIIAgAAAA==.',['思念']='思念成殇:BAACKgAFFH8GAAIMAAIIgxl5AwCHAAAMAAIIgxl5AwCHAAAqAAQKfysAAgwACAgYJPsFADkCAAwACAgYJPsFADkCAAAA.',['急刹']='急刹车:BAABKgAFFH8WAAMHAAgIUiC5AwD5AQAHAAcIgiG5AwD5AQAGAAUIcBoEHgDcAAAAAA==.',['恩皮']='恩皮西:BAAAKgAECgQICwAAAA==.',['恶魔']='恶魔之韧:BAAAKgAECgcIBwAAAA==.',['惬意']='惬意的风:BAACKgAFFH8rAAMRAAQI0RIWEwDYAAARAAMI0RIWEwDYAAAZAAQIORp2EgDUAAAqAAQKfy0AAxkACAhGHKQHADQCABkACAhGHKQHADQCABEACAjcGN84AKIBAAAA.',['懮鬰']='懮鬰的風:BAAAKgAECggIDwAAAA==.',['成允']='成允:BAABKgAFFH8IAAIbAAgIHh3KBABRAgAbAAgIHh3KBABRAgAAAA==.',['我叫']='我叫长棍:BAAAKgAECgUIBQAAAA==.',['我的']='我的宝贝:BAAAKgADCgYIBgAAAA==.',['我蛋']='我蛋刀呢:BAABKgAFFH8IAAICAAgI1hYNBgBHAgACAAgI1hYNBgBHAgABKgAFFAgISQAGABIgAA==.',['我贼']='我贼萌要奶我:BAABKgAFFH8FAAMZAAMIzQ34CgDYAAAZAAMIzQ34CgDYAAARAAIIggXNKgB0AAABKgAFFAgICAAZAEwYAA==.',['我鸟']='我鸟超大:BAABKgAFFH8GAAIcAAYIqQi6GwAoAQAcAAYIqQi6GwAoAQAAAA==.',['战俘']='战俘别找我:BAAAKgAECgMIAgAAAA==.',['战灬']='战灬火:BAAAKgAECggIEwAAAA==.',['戰神']='戰神佩琪:BAABKgAECn8oAAMGAAgIlh1RCQAdAgAGAAgIlh1RCQAdAgAdAAIIAhFlPQBnAAAAAA==.',['手中']='手中流沙:BAABKgAFFH8LAAIQAAMIFBdMGADPAAAQAAMIFBdMGADPAAAAAA==.',['把血']='把血放出来:BAABKgAFFH8NAAIDAAQIJg1fFgDeAAADAAQIJg1fFgDeAAAAAA==.',['拉风']='拉风的小红花:BAAAKgAFFAMIAwAAAA==.',['斐迪']='斐迪南大公:BAACKgAFFH8fAAIIAAMIHyDfCADTAAAIAAMIHyDfCADTAAAqAAQKfxQAAggACAj7GhkXAKsBAAgACAj7GhkXAKsBAAEqAAUUBAgZAAUApgkA.',['斯文']='斯文的大领主:BAAAKgAECgUICgAAAA==.斯文的敗類:BAAAKgADCgIIAgAAAA==.斯文的疯子:BAAAKgAECgcIBwAAAA==.斯文的老匹夫:BAAAKgADCggICAAAAA==.斯文的老痞子:BAAAKgAECggIEAAAAA==.斯文的败類:BAAAKgAECgMIAwAAAA==.',['方不']='方不甜:BAABKgAFFH8FAAIeAAQIqxtWEgDQAAAeAAQIqxtWEgDQAAAAAA==.',['方小']='方小简:BAAAKgAECggIDgAAAA==.',['无法']='无法触及:BAAAKgADCgQIBAAAAA==.',['日月']='日月与花:BAAAKgAECggICAAAAA==.',['昕阳']='昕阳:BAABKgAECn8UAAMCAAgIzAt9YwDBAAACAAcI4gp9YwDBAAASAAcI2wZ8RQCZAAAAAA==.',['星河']='星河:BAAAKgAFFAQIAgAAAA==.',['昨日']='昨日雪如花灬:BAABKgAECn8UAAIDAAgINRrKIgADAgADAAgINRrKIgADAgAAAA==.',['普渡']='普渡法尊:BAAAKgAFFAEIAQAAAA==.',['晴天']='晴天小猪:BAAAKgAECggIEQAAAA==.',['智商']='智商已停机丶:BAABKgAFFH8IAAICAAgIIwUNDACcAQACAAgIIwUNDACcAQAAAA==.',['暗夜']='暗夜猎神超萌:BAAAKgADCggICAAAAA==.',['暗如']='暗如影:BAAAKgADCgcIBwAAAA==.',['暴打']='暴打兔兔酱:BAAAKgAECggICAAAAA==.',['曙光']='曙光之女神:BAAAKgAECgYIBwAAAA==.',['有时']='有时候掉毛:BAAAKgAECgYIDAAAAA==.',['有点']='有点小心动:BAAAKgADCgUIBQAAAA==.有点神骑:BAABKgAFFH8UAAMBAAgItyQUAQABAwABAAgItyQUAQABAwAfAAII0g1uEAB+AAAAAA==.',['朙朙']='朙朙很聪明:BAAAKgAECgYIBgAAAA==.',['木元']='木元真实:BAAAKgAECgQIBAAAAA==.',['木子']='木子牛文化十:BAAAKgADCgEIAQAAAA==.',['末日']='末日冰峰:BAABKgAECn8UAAMgAAgI5w6BPwD1AAAgAAUIUg6BPwD1AAAcAAgIdQz4UADMAAABKgAFFAMIAwAWAAAAAA==.末日飘雪:BAAAKgAFFAMIAwAAAA==.',['杀到']='杀到不能停手:BAABKgAFFH8KAAIUAAgI+htWAgCbAgAUAAgI+htWAgCbAgAAAA==.',['杀戮']='杀戮魔王:BAAAKgAECggIAgABKgAFFAgIIwAbAIglAA==.',['来个']='来个糖:BAAAKgADCgQIBAAAAA==.',['松鼠']='松鼠的尾巴:BAABKgAFFH8JAAIcAAgIGxwvIwDuAAAcAAgIGxwvIwDuAAAAAA==.',['果圣']='果圣:BAABKgAFFH8GAAIBAAYIXgKwRQDjAAABAAYIXgKwRQDjAAAAAA==.',['果爷']='果爷:BAABKgAFFH8GAAIHAAYIFgMLEQADAQAHAAYIFgMLEQADAQAAAA==.',['果粒']='果粒多丶:BAAAKgAECgYIBwAAAA==.',['某小']='某小某:BAAAKgADCgMIAwAAAA==.',['柠一']='柠一萌:BAAAKgAECgYIDwAAAA==.',['格拉']='格拉秋莎:BAABKgAFFH8GAAILAAYI4h20EgCHAQALAAYI4h20EgCHAQAAAA==.',['桥本']='桥本有腿:BAABKgAECn8dAAQeAAgILyK+DwCDAgAeAAgIHiK+DwCDAgAYAAgIWRDoRQBvAQAbAAMIJxJEJQBqAAAAAA==.',['梅柳']='梅柳丨齐娜灬:BAAAKgADCggICAABKgAFFAEIAgAWAAAAAA==.',['梦之']='梦之舟:BAAAKgADCggICAAAAA==.',['歌未']='歌未竟:BAAAKgAECggICgAAAA==.',['死亡']='死亡绝吻:BAABKgAECn8mAAMBAAgIxxpVNwAiAgABAAgIxxpVNwAiAgAIAAEI9gNUYAAMAAAAAA==.',['死生']='死生:BAAAKgAECgcIBwAAAA==.',['残帆']='残帆:BAAAKgAECgUIBQAAAA==.',['永恒']='永恒蛋挞:BAAAKgAFFAgIBAAAAA==.',['江上']='江上挽风吟:BAAAKgADCgYIBgAAAA==.',['泡芙']='泡芙咖啡:BAAAKgAECgcIBwAAAA==.',['泪已']='泪已随风消逝:BAAAKgADCgEIAQAAAA==.',['泰岚']='泰岚德语风:BAAAKgAECgMIAwAAAA==.',['泰神']='泰神一:BAAAKgADCgEIAQAAAA==.',['泰蘭']='泰蘭德旳記憶:BAABKgAFFH8UAAMCAAgI0xUsBwAuAgACAAgI0xUsBwAuAgASAAQIfxAzCgCpAAAAAA==.',['济刘']='济刘府新家丁:BAAAKgADCggICAAAAA==.',['混沌']='混沌玛利亚:BAAAKgAECgcIDAAAAA==.',['清池']='清池:BAAAKgADCgIIAgAAAA==.',['清风']='清风一游侠:BAAAKgADCggICAAAAA==.清风神偷:BAAAKgADCggICgAAAA==.',['渣男']='渣男不养家:BAAAKgADCggICAAAAA==.',['温温']='温温坏:BAAAKgAFFAgIBAAAAA==.',['漫步']='漫步夕阳:BAAAKgAECgYIDAAAAA==.',['灬沙']='灬沙洲冷:BAAAKgAECgYICAAAAA==.',['灬瞌']='灬瞌睡虫灬:BAABKgAFFH8HAAMbAAUIgCRJDwB1AQAbAAUIgCRJDwB1AQAYAAIIzRu7IwCbAAAAAA==.',['灬零']='灬零度阔落灬:BAAAKgAECgEIAQAAAA==.',['炎帝']='炎帝灬萧炎灬:BAAAKgAECggICgAAAA==.',['烈风']='烈风影:BAAAKgAECggIEAAAAA==.',['無名']='無名:BAACKgAFFH8dAAMdAAQIKQ9IBwCaAAAGAAQIhw2gIADRAAAdAAQIlAtIBwCaAAAqAAQKfxwAAwYACAgXF2QsANYBAAYACAinFmQsANYBAB0ABAhkE/AwAIkAAAAA.',['焦糖']='焦糖奶油布丁:BAAAKgAECgYIBgAAAA==.',['燃烧']='燃烧的毛裤:BAAAKgAECgcICQAAAA==.',['牢尘']='牢尘:BAACKgAFFH8KAAILAAUIoxTLMgDMAAALAAUIoxTLMgDMAAAqAAQKfxkAAw0ACAhaF04aAPIBAA0ACAhaF04aAPIBAAsACAgXGUovAPABAAEqAAUUBggYAAMAIR4A.',['牧诗']='牧诗:BAABKgAFFH8GAAIQAAYIsxPkCACOAQAQAAYIsxPkCACOAQAAAA==.',['狂杀']='狂杀:BAAAKgAECgIIAgAAAA==.',['狠哥']='狠哥:BAAAKgAFFAYIBAAAAA==.',['狸猫']='狸猫乌冬面:BAAAKgAECgYIBwAAAA==.',['猪猪']='猪猪蛋:BAABKgAFFH8jAAIPAAgI/xwnAgBSAgAPAAgI/xwnAgBSAgAAAA==.',['猫德']='猫德学院:BAAAKgADCgMIAwAAAA==.',['珂朵']='珂朵莉:BAAAKgAECgMIBQAAAA==.',['琪乐']='琪乐:BAAAKgAECggICAAAAA==.',['甜奶']='甜奶:BAAAKgAFFAYIBAABKgAFFAgICwAPAKsaAA==.',['生命']='生命的旅程:BAAAKgAECggIDAAAAA==.',['疯狂']='疯狂撒旦:BAAAKgAECgcIBwAAAA==.',['瘾大']='瘾大水平低:BAAAKgADCggIDwAAAA==.',['白嶶']='白嶶:BAAAKgAFFAQIBAAAAA==.',['白毛']='白毛丨浮绿水:BAAAKgADCgYIBgAAAA==.',['白的']='白的黑:BAACKgAFFH8QAAIBAAUISB0QDQAgAQABAAUISB0QDQAgAQAqAAQKfxcAAgEACAhoI5gWAL0CAAEACAhoI5gWAL0CAAAA.',['百变']='百变星星:BAAAKgAECgUICAAAAA==.',['百望']='百望山潘粤明:BAAAKgAECgEIAQAAAA==.',['百無']='百無禁忌:BAAAKgAFFAQIBAAAAA==.',['皓阳']='皓阳装饰:BAABKgAFFH8LAAMSAAMItwYEHAB1AAASAAMItwYEHAB1AAACAAEIegKgOgA0AAAAAA==.',['看上']='看上去很帅:BAABKgAECn8UAAIeAAgI2RxcEgBrAgAeAAgI2RxcEgBrAgAAAA==.',['看不']='看不見我:BAAAKgAECgUICQAAAA==.',['真的']='真的汉子:BAACKgAFFH8YAAMKAAQIpCDDHQAEAQAKAAQIpCDDHQAEAQAJAAQInBh3MQDHAAAqAAQKfyEAAgoACAjsHUkXABYCAAoACAjsHUkXABYCAAAA.',['瞄准']='瞄准未击中:BAAAKgAECgUICQAAAA==.',['祝福']='祝福之锤:BAAAKgAECggICAAAAA==.',['神吕']='神吕布丶:BAAAKgAECggICAAAAA==.',['神牧']='神牧土豆粉:BAAAKgAECgEIAQAAAA==.',['神里']='神里绫华丶:BAAAKgAECgMIAwAAAA==.',['神魔']='神魔之子:BAAAKgAECgIIAgAAAA==.',['神龙']='神龙大虾:BAAAKgAFFAEIAgAAAA==.',['祥龙']='祥龙十八掌:BAAAKgADCgQIBAAAAA==.',['禁止']='禁止刺青:BAAAKgAFFAMIAwAAAA==.',['秋雨']='秋雨醉繁华:BAAAKgAECggICAAAAA==.',['空虚']='空虚娘子:BAAAKgADCgMIAwAAAA==.',['笨蛋']='笨蛋熊猫怪:BAAAKgAECgQIBwAAAA==.',['索饵']='索饵:BAAAKgAFFAMIBAAAAA==.',['紫色']='紫色蒲公英:BAAAKgADCgEIAQAAAA==.',['红掌']='红掌丨拨清波:BAABKgAFFH8GAAIEAAYI1RfWEABVAQAEAAYI1RfWEABVAQAAAA==.',['红烛']='红烛:BAACKgAFFH8nAAIcAAQI6hdBGQC7AAAcAAQI6hdBGQC7AAAqAAQKfyUAAhwACAg0HZEKAPMBABwACAg0HZEKAPMBAAAA.',['绯色']='绯色小牧:BAAAKgAECgYIBgAAAA==.绯色战神:BAAAKgAECggICAAAAA==.绯色猎魔者:BAAAKgAECggICAAAAA==.',['羊和']='羊和猪:BAAAKgAECgIIAgAAAA==.',['羞答']='羞答答地玫瑰:BAAAKgAECgcIDwAAAA==.',['老牛']='老牛哞:BAABKgAECn8yAAMfAAgI3SAzCABoAgAfAAgI3SAzCABoAgABAAgIkBRffABYAQAAAA==.',['胡堂']='胡堂主:BAAAKgAFFAQIBAAAAA==.',['舜杀']='舜杀:BAAAKgADCgIIAgAAAA==.',['艾克']='艾克斯卡特:BAABKgAFFH8RAAMGAAUIUg6EDwBdAQAGAAUIUg6EDwBdAQAdAAIIpAOYFQBLAAAAAA==.',['芙宁']='芙宁娜:BAAAKgAFFAQIBAAAAA==.',['花若']='花若笑颜:BAAAKgAECggICAAAAA==.',['苏擦']='苏擦哈尔灿:BAAAKgAECgIIAgAAAA==.',['苦涩']='苦涩的抉择:BAAAKgADCgUIBQAAAA==.',['英伦']='英伦小牧:BAAAKgAECgIIAgAAAA==.',['莫决']='莫决:BAABKgAECn8cAAMKAAgIngqVMACiAAAKAAgIngqVMACiAAAJAAQIPAMywgA+AAAAAA==.',['蒙牛']='蒙牛雷达:BAAAKgAFFAYIBAAAAA==.',['蓝翡']='蓝翡翠:BAAAKgAECgEIAQAAAA==.',['蓝萦']='蓝萦傲魂:BAABKgAFFH8KAAIDAAYIMxiBEwB+AQADAAYIMxiBEwB+AQAAAA==.',['蘑菇']='蘑菇灬提莫灬:BAAAKgADCgYIBgAAAA==.',['蝎子']='蝎子奈奈:BAAAKgAECgIIAgAAAA==.',['蠢露']='蠢露露:BAAAKgADCggICAAAAA==.',['血蹄']='血蹄的二舅:BAAAKgAFFAIIAgAAAA==.',['街角']='街角的巳时:BAABKgAFFH8GAAISAAMIKAjKGQCBAAASAAMIKAjKGQCBAAAAAA==.',['被宠']='被宠的牛牛:BAABKgAFFH8IAAMLAAgIXwMkOwC5AAALAAMIpAMkOwC5AAANAAUIxgNqIQCjAAAAAA==.',['西伯']='西伯利亚犬:BAAAKgAECggICAAAAA==.',['觥筹']='觥筹交错:BAABKgAFFH8GAAIKAAYIyBXNEABfAQAKAAYIyBXNEABfAQAAAA==.',['變形']='變形琻钢:BAAAKgAECgYIEQAAAA==.',['诗酒']='诗酒流觞:BAACKgAFFH8FAAQOAAQI4hVEGQCZAAAOAAIIWhJEGQCZAAAQAAIIYyBsIwBkAAAPAAEI7w6zJAA/AAAqAAQKfxcAAw8ACAicFlspAIgBAA8ACAicFlspAIgBABAAAwhTCRiGAEcAAAEqAAUUCAgTABwANBQA.',['说公']='说公主请上车:BAAAKgAECgcICgAAAA==.',['豊川']='豊川祥子:BAAAKgAFFAgIBAAAAA==.',['貘螺']='貘螺:BAAAKgADCggICAAAAA==.',['贝拉']='贝拉露娜:BAACKgAFFH8bAAQVAAQIwRq9CgDnAAAVAAQIPBe9CgDnAAAaAAQIKBU1EADmAAAhAAQIghStAwDBAAAqAAQKfycABCEACAiJIFQGACcCACEACAh8HlQGACcCABUABwjgGMspAJcBABoABgg4Du9lAKgAAAEqAAUUCAgGAAUA4AIA.',['赛天']='赛天师:BAAAKgAFFAQIBAAAAA==.',['躲一']='躲一下别吃了:BAAAKgAECgcIDAAAAA==.',['转一']='转一下别毛了:BAABKgAECn8jAAIDAAgINh3CIQAJAgADAAgINh3CIQAJAgAAAA==.',['辛庄']='辛庄有燕:BAAAKgAECgUIBQAAAA==.',['这你']='这你受的了吗:BAAAKgAECgMIAwAAAA==.',['远游']='远游客:BAABKgAECn8dAAMRAAgILhOWOwCXAQARAAgILhOWOwCXAQAZAAIIFASGdgA0AAAAAA==.',['选择']='选择随机:BAAAKgADCggICAAAAA==.',['逍遥']='逍遥淡如烟:BAAAKgAECgMIAwAAAA==.逍遥遥:BAACKgAFFH8VAAIdAAQI8wz5BgCfAAAdAAQI8wz5BgCfAAAqAAQKfx4ABAYACAhvGo8iAAsCAAYACAg3GY8iAAsCAB0ACAjMETEWAGgBAAcAAQj9EPNmADgAAAAA.',['逐光']='逐光之影:BAAAKgAFFAMIAwAAAA==.',['道特']='道特不断:BAACKgAFFH8RAAIgAAQIUx/gBgAMAQAgAAQIUx/gBgAMAQAqAAQKfxoAAyAACAiRHyMPAAkCACAACAgrHSMPAAkCABwAAwiXGuRkAN4AAAAA.',['邸坝']='邸坝夫:BAAAKgAECgEIAQAAAA==.',['酸菜']='酸菜鱼:BAAAKgADCgIIAgAAAA==.',['量子']='量子假体:BAAAKgAECgUICAABKgAFFAYIBgAKAFkYAA==.',['阻丶']='阻丶王:BAABKgAFFH8lAAIDAAYIMR4lCQCiAQADAAYIMR4lCQCiAQAAAA==.',['阻蛋']='阻蛋:BAAAKgAFFAIIAgAAAA==.',['阿克']='阿克汗:BAABKgAFFH8GAAIBAAYIRCDiAAABAgABAAYIRCDiAAABAgAAAA==.',['阿兰']='阿兰娜丶逐日:BAABKgAFFH8IAAICAAQIZggHNACwAAACAAQIZggHNACwAAABKgAFFAgICAAFAFgSAA==.',['阿比']='阿比盖尔:BAAAKgAFFAMIAwAAAA==.',['阿莉']='阿莉塞:BAAAKgAECgcIBwAAAA==.',['陌小']='陌小四:BAAAKgAFFAMIAwAAAA==.',['雨师']='雨师姬:BAAAKgADCggICAAAAA==.',['雨落']='雨落花开:BAAAKgAECggIEgAAAA==.',['雪千']='雪千寻:BAAAKgAFFAQIBAAAAA==.',['雷丶']='雷丶西蒙:BAAAKgADCggICAAAAA==.',['青楼']='青楼丶萨满:BAAAKgAECgUIBQAAAA==.',['青涩']='青涩后妈:BAABKgAFFH8FAAIiAAMITwvhEgC/AAAiAAMITwvhEgC/AAAAAA==.',['面无']='面无暇:BAACKgAFFH8GAAIKAAYI3x72DACKAQAKAAYI3x72DACKAQAqAAQKfxQAAgoACAgKGDEdAOkBAAoACAgKGDEdAOkBAAAA.',['颜丶']='颜丶辰洋:BAAAKgAECggIDwAAAA==.',['風與']='風與未來丶:BAAAKgAECggICAAAAA==.',['风云']='风云百合:BAABKgAECn8bAAIeAAgIQRp7FgAFAgAeAAgIQRp7FgAFAgAAAA==.',['风华']='风华正茂:BAAAKgADCggICAAAAA==.',['风间']='风间凖:BAAAKgAFFAMIAwAAAA==.',['风雪']='风雪夜归人丶:BAAAKgAECggIEAAAAA==.',['飞机']='飞机坐乌鸦:BAAAKgAECgIIAgAAAA==.',['飞虎']='飞虎神鹰:BAAAKgADCgQIBQAAAA==.',['马库']='马库斯李:BAABKgAFFH8KAAIBAAYITQ+eLQAxAQABAAYITQ+eLQAxAQAAAA==.',['鬼脸']='鬼脸丶林黛玉:BAAAKgAECgEIAQAAAA==.',['魂小']='魂小殇:BAAAKgAECgQIBQAAAA==.',['魔神']='魔神斩月:BAAAKgAECgYIDAAAAA==.',['鱼小']='鱼小于:BAAAKgAECgcIBwAAAA==.',['鹰哥']='鹰哥:BAAAKgADCggICAAAAA==.',['黄色']='黄色飞灰:BAAAKgAECggIEAAAAA==.',['黄金']='黄金梅利:BAAAKgAECgUIBQAAAA==.',['黑夜']='黑夜之声:BAAAKgAFFAQIBAAAAA==.',['黑马']='黑马弥娜:BAAAKgAECgYICwAAAA==.',['黒榊']='黒榊丨目瀧灬:BAAAKgAFFAEIAgAAAA==.',['龌龊']='龌龊后很清纯:BAABKgAFFH8IAAIGAAQIuA2zIADQAAAGAAQIuA2zIADQAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end