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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','DeathKnight-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Paladin-Retribution','Warrior-Fury','Unknown-Unknown','Shaman-Restoration','Paladin-Protection','Priest-Shadow','Priest-Holy','DemonHunter-Havoc','Druid-Balance','Monk-Mistweaver','Mage-Frost','Mage-Arcane','Rogue-Assassination','Monk-Windwalker','Paladin-Holy','Hunter-Survival','Warrior-Protection','Mage-Fire','Druid-Restoration','Druid-Guardian','DemonHunter-Vengeance','Druid-Feral','Evoker-Devastation','Warrior-Arms','Shaman-Elemental','Evoker-Preservation','Shaman-Enhancement',}; local provider = {region='CN',realm='玛诺洛斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ah='Ahrui:BAAAKgAFFAQIBAAAAA==.',Ai='Airx:BAAAKgADCgcIBwAAAA==.',Al='Alitoleah:BAAAKgAECggICwAAAA==.',As='Ash:BAAAKgAFFAQIBAAAAA==.Astrea:BAAAKgAECggICgAAAA==.',Bl='Bloodavenger:BAAAKgAECgMIAwAAAA==.',Br='Breathefish:BAAAKgAECgYIBgAAAA==.',Bu='Bubbly:BAAAKgADCgEIAQAAAA==.',Cy='Cynthia:BAAAKgADCgEIAQAAAA==.',Da='Darkavenger:BAAAKgAECgYICgAAAA==.',De='Deathknite:BAACKgAFFH8JAAMBAAUIFxh/HwAjAQABAAUIFxh/HwAjAQACAAQIfBCcKQAAAAAqAAQKfxsAAwMACAibD18XACYBAAMACAibD18XACYBAAIAAwgjACZyAAIAAAAA.',Es='Escano:BAAAKgAFFAQIAgAAAA==.',Fu='Fuzzypuzzle:BAAAKgADCggICAAAAA==.',Gl='Glasses:BAABKgAECn8VAAMEAAgIGQoBqADVAAAEAAgItQkBqADVAAAFAAMIogYgewBXAAAAAA==.',Gr='Greens:BAAAKgAECgcICwAAAA==.',Hi='Himmels:BAAAKgAFFAQIBAAAAA==.Hislnightmar:BAAAKgAECgIIAgAAAA==.',Ho='Home:BAAAKgAFFAQIBAAAAA==.',Hu='Hui:BAAAKgADCgIIAgAAAA==.',Il='Illidari:BAAAKgADCgEIAQAAAA==.',In='Innocenc:BAAAKgAECggICAAAAA==.',Kb='Kbz:BAAAKgAECgYIBgAAAA==.',La='Layoomirty:BAAAKgAECgcICAAAAA==.',Mb='Mbappe:BAABKgAFFH8IAAIGAAgIZRWhAwAjAgAGAAgIZRWhAwAjAgAAAA==.',Me='Medog:BAABKgAECn8WAAMBAAgIuR/FFgB4AgABAAgIuR/FFgB4AgACAAEIFg78ZgArAAAAAA==.',Ne='Neall:BAAAKgAFFAEIAQAAAA==.',Qh='Qhnc:BAACKgAFFH9EAAQHAAgIESAjBABmAgAHAAgIcBsjBABmAgAIAAMIaCGFBgAcAQAJAAIIXCAOIABiAAAqAAQKfzIABAcACAhlIsMUAEgCAAcACAgkIsMUAEgCAAgABAg4JIQQAHgBAAkABAhvG8ZbAJEAAAAA.Qhnu:BAAAKgAECgYIBgAAAA==.Qhnx:BAABKgAFFH8IAAIKAAgIYhNZCQAtAgAKAAgIYhNZCQAtAgAAAA==.',Ra='Raver:BAACKgAFFH8nAAMFAAgISSCIAADhAQAEAAgIOh6xAwCDAgAFAAYIwyCIAADhAQAqAAQKfxUAAwQACAhmIW4jAGcCAAQACAhmIW4jAGcCAAUAAQhdGnubAEUAAAAA.',Se='Semoon:BAAAKgAFFAYIAgAAAA==.Seraphs:BAABKgAFFH8IAAIKAAgI1B8hAwC4AgAKAAgI1B8hAwC4AgAAAA==.',Sh='Show:BAABKgAFFH8IAAIBAAYIbx5UDADKAQABAAYIbx5UDADKAQAAAA==.',Sm='Smilefox:BAAAKgAECgUIEQAAAA==.',St='Stefe:BAAAKgAECgUIBQAAAA==.',Un='Unclecat:BAAAKgADCgUIBgAAAA==.',Ur='Uria:BAABKgAFFH8XAAILAAgIJByDBABJAgALAAgIJByDBABJAgAAAA==.',Vi='Victoriasf:BAAAKgAFFAMIAwAAAA==.',Wi='Wildflower:BAAAKgADCgEIAQAAAA==.',Wu='Wuxidixi:BAACKgAFFH8TAAIEAAQImSBMDQAbAQAEAAQImSBMDQAbAQAqAAQKfy0AAwQACAikI2wSALUCAAQACAikI2wSALUCAAUAAghPGWt+AIAAAAEqAAUUCAgEAAwAAAAA.',Xi='Xiaoxiaolong:BAAAKgADCgMIAwAAAA==.',['一句']='一句话惹怒你:BAAAKgADCgQIBAAAAA==.',['一嘉']='一嘉隆一:BAAAKgAECgcICgAAAA==.',['一头']='一头奶牛:BAACKgAFFH8LAAINAAMIdhPvGQCnAAANAAMIdhPvGQCnAAAqAAQKfxUAAg0ACAjoDotYADUBAA0ACAjoDotYADUBAAAA.',['一抹']='一抹无邪:BAAAKgADCgQIBQAAAA==.',['一曲']='一曲断魂曲:BAAAKgAECggIEAAAAA==.',['一氧']='一氧化二氮丶:BAABKgAFFH8IAAIOAAgIYhZEBQDoAQAOAAgIYhZEBQDoAQAAAA==.',['一点']='一点回忆:BAAAKgAFFAQIBAAAAA==.',['一脸']='一脸秀气:BAAAKgAFFAQIBAAAAA==.',['七叶']='七叶树之魂:BAACKgAFFH8GAAIKAAYIKBZjIwBeAQAKAAYIKBZjIwBeAQAqAAQKfxoAAgoACAgSGw46ABgCAAoACAgSGw46ABgCAAAA.',['七年']='七年光景:BAABKgAECn8UAAMGAAgI1CM+BQDBAgAGAAgI1CM+BQDBAgAPAAEIeB/4ZgBaAAABKgAFFAEIAQAMAAAAAA==.',['七弦']='七弦:BAABKgAECn8UAAMQAAgITxZARwAbAQAQAAgIZhVARwAbAQAGAAYI8g4GTQDhAAAAAA==.',['三杯']='三杯吐然诺:BAAAKgADCggIGgAAAA==.',['上邪']='上邪:BAAAKgADCgQICAAAAA==.',['专一']='专一男士:BAAAKgADCgIIAgAAAA==.',['世界']='世界第一坦:BAABKgAFFH8YAAICAAUIQBRBGgDQAAACAAUIQBRBGgDQAAAAAA==.世界萨:BAAAKgAECgMIAwAAAA==.',['丝般']='丝般幼滑:BAABKgAFFH8HAAIEAAMIFA1qHAC2AAAEAAMIFA1qHAC2AAAAAA==.',['丨焦']='丨焦爺丨:BAAAKgAFFAYIAwAAAA==.',['丨蕃']='丨蕃茄丨:BAABKgAFFH8QAAIRAAgIMBSpCgDeAQARAAgIMBSpCgDeAQAAAA==.',['丫的']='丫的不管:BAAAKgAFFAEIAQAAAA==.',['丶喵']='丶喵小鱼:BAAAKgADCgUICgAAAA==.',['丸子']='丸子妹妹:BAAAKgADCgMIBgAAAA==.',['为什']='为什么要我奶:BAAAKgAFFAYIBAAAAA==.',['丽贝']='丽贝卡卡哟:BAAAKgAFFAQIBAAAAA==.',['乂刃']='乂刃一刀:BAAAKgAECgYIDwAAAA==.',['乌瑟']='乌瑟尔的左手:BAABKgAFFH8GAAIKAAYIphzyHQB6AQAKAAYIphzyHQB6AQAAAA==.乌瑟瑞恩:BAAAKgAECggICgAAAA==.',['也許']='也許丶那些:BAAAKgAECgUIBQAAAA==.',['乱了']='乱了感觉:BAAAKgADCgEIAQAAAA==.',['乸熠']='乸熠:BAAAKgADCgUIBQAAAA==.',['二三']='二三一四:BAABKgAFFH8IAAICAAgIwBMBBgDXAQACAAgIwBMBBgDXAQAAAA==.',['二丫']='二丫阿卡曼:BAAAKgAECgQIBAAAAA==.',['二营']='二营长:BAAAKgAECgcIDAABKgAECggIDQAMAAAAAA==.',['五花']='五花肉:BAAAKgADCgcIDgAAAA==.',['人在']='人在影成双:BAAAKgAFFAEIAQAAAA==.',['以德']='以德服人丶:BAABKgAFFH8GAAISAAMI5AoFQQCoAAASAAMI5AoFQQCoAAAAAA==.',['任意']='任意豪赌:BAAAKgAFFAEIAQAAAA==.',['伊利']='伊利单怒疯:BAAAKgADCgQIBAAAAA==.',['伊奇']='伊奇卡小十:BAAAKgAECgYIEQAAAA==.',['传说']='传说哥哥:BAAAKgAECgIIAgAAAA==.',['伤心']='伤心的号丢了:BAAAKgAECgQIBAAAAA==.',['伯氏']='伯氏:BAAAKgADCgMIAwAAAA==.',['佐日']='佐日憧羡:BAAAKgAECgYIBgAAAA==.',['佑灬']='佑灬:BAABKgAFFH8OAAISAAYI3yQKCAAvAQASAAYI3yQKCAAvAQABKgAFFAgIUAASABcmAA==.',['你们']='你们缺德口马:BAAAKgAECgYIBgAAAA==.',['你是']='你是不是小号:BAAAKgAFFAMIAwAAAA==.',['你猜']='你猜:BAAAKgADCgYIBgAAAA==.',['佳萘']='佳萘:BAAAKgAECggIDgAAAA==.',['侬想']='侬想哪能:BAAAKgAFFAYIBAABKgAFFAgIBAAMAAAAAA==.',['修假']='修假:BAAAKgAFFAEIAQAAAA==.',['修罗']='修罗氵七宗罪:BAAAKgAECggICAAAAA==.',['储蓄']='储蓄卡拉你们:BAABKgAECn8UAAILAAYIEQ5sRQABAQALAAYIEQ5sRQABAQAAAA==.',['傲视']='傲视狂杀:BAAAKgADCgEIAQAAAA==.',['兔仔']='兔仔糖:BAAAKgAECgIIAgAAAA==.',['兔姐']='兔姐姐:BAABKgAFFH8IAAIKAAgIwBnPCQAmAgAKAAgIwBnPCQAmAgAAAA==.',['全垒']='全垒僧:BAAAKgAFFAYIBAABKgAFFAgICQATAHwgAA==.全垒手:BAAAKgAECggIDgAAAA==.',['八掛']='八掛子:BAABKgAECn8UAAIUAAgIxhysHQDDAQAUAAgIxhysHQDDAQAAAA==.',['八零']='八零后丶法爷:BAAAKgADCgMIAwAAAA==.',['冰月']='冰月寒丶雪:BAAAKgAECggICwAAAA==.',['冰美']='冰美式少冰:BAAAKgAFFAQIBAAAAA==.',['冲锋']='冲锋砍他:BAAAKgAECggICAAAAA==.',['冻拧']='冻拧奶茶:BAAAKgADCggIEQAAAA==.',['凌晓']='凌晓楚:BAAAKgAECgcIDgAAAA==.',['几百']='几百根棒子:BAAAKgADCggICAAAAA==.',['凤老']='凤老师来了:BAABKgAECn8rAAIUAAgIIhwPBwA+AgAUAAgIIhwPBwA+AgAAAA==.',['刀御']='刀御剑的桐人:BAAAKgAECgYICAAAAA==.',['切莫']='切莫逗逗妹:BAABKgAFFH8MAAIVAAgIziJ8AQDQAgAVAAgIziJ8AQDQAgAAAA==.切莫逗逗法:BAAAKgAFFAQIBAAAAA==.',['别给']='别给我嘻嘻:BAAAKgADCgUIBQAAAA==.',['别问']='别问很可怕:BAAAKgAFFAgIBAAAAA==.',['剑抹']='剑抹天河:BAACKgAFFH8ZAAIWAAcIlxO5BgDAAQAWAAcIlxO5BgDAAQAqAAQKfxoAAhYACAiUG18SAA0CABYACAiUG18SAA0CAAAA.',['剑指']='剑指心向:BAAAKgAECgMIBAAAAA==.',['功夫']='功夫菜刀:BAAAKgADCgYIBgAAAA==.',['北极']='北极村的希望:BAABKgAFFH8MAAMVAAgIoxI5BwAXAgAVAAgIshA5BwAXAgAUAAQI4hI5GAC0AAAAAA==.',['千寻']='千寻:BAABKgAFFH8LAAIHAAYIchDBFABeAQAHAAYIchDBFABeAQAAAA==.',['半棵']='半棵树:BAAAKgAECgIIAgAAAA==.',['华丽']='华丽打击:BAAAKgAFFAYIAgAAAA==.',['卡布']='卡布基诺:BAAAKgADCggICAABKgAFFAgICQAOADAXAA==.',['卡斯']='卡斯比:BAABKgAFFH8KAAINAAYINw3xEgDYAAANAAYINw3xEgDYAAAAAA==.',['卡米']='卡米先森:BAAAKgAFFAQIBAAAAA==.',['卡莉']='卡莉斯塔:BAABKgAFFH8GAAISAAYIgwTKJQD/AAASAAYIgwTKJQD/AAAAAA==.',['厄梦']='厄梦丶:BAAAKgAECgcIDAAAAA==.',['发现']='发现落单的:BAAAKgADCggICAAAAA==.',['可爱']='可爱的汤包:BAACKgAFFH8sAAMTAAgILxrGBgDTAQATAAgILxrGBgDTAQAXAAEIeBRUJABBAAAqAAQKfyQAAhMACAgbHzcTAE8CABMACAgbHzcTAE8CAAAA.',['叶子']='叶子飘然:BAABKgAFFH8GAAMYAAYI8xCoCwDvAAAYAAUIBBCoCwDvAAAKAAEIBwmujAA6AAAAAA==.',['吃鸡']='吃鸡胗:BAABKgAECn8WAAMEAAgIJw5zWgBLAQAEAAgIJw5zWgBLAQAZAAEIkQYYGgAkAAAAAA==.',['啊四']='啊四腰:BAAAKgAFFAQIBAAAAA==.',['喜欢']='喜欢晒太阳:BAAAKgADCgQIBAAAAA==.',['喝酒']='喝酒没问题:BAACKgAFFH8GAAIaAAMIXQvVDgCJAAAaAAMIXQvVDgCJAAAqAAQKfyMAAhoACAgPFmsUAKgBABoACAgPFmsUAKgBAAAA.',['喵了']='喵了个小咪:BAAAKgADCgEIAQAAAA==.',['喵喵']='喵喵小米:BAAAKgAFFAQIBAAAAA==.',['喵鸽']='喵鸽鸡三宝:BAAAKgAFFAgIAgAAAA==.',['嗜血']='嗜血的爱:BAABKgAFFH8IAAIKAAgIkho/BgBoAgAKAAgIkho/BgBoAgAAAA==.',['嘤嘤']='嘤嘤怪嘤嘤:BAAAKgADCgQIBQAAAA==.',['四風']='四風月影:BAAAKgAFFAQIBAAAAA==.',['囝藤']='囝藤:BAAAKgAECgYIBgAAAA==.',['囡囡']='囡囡:BAAAKgAECgEIAQAAAA==.',['圆咕']='圆咕噜:BAAAKgAECgYIBgAAAA==.',['圆园']='圆园圆:BAAAKgADCgQIBAAAAA==.',['圆圈']='圆圈叉叉:BAAAKgADCgMIAwAAAA==.',['土灵']='土灵:BAABKgAFFH8IAAIQAAgIuQzuBgC9AQAQAAgIuQzuBgC9AQAAAA==.',['土豆']='土豆骑士:BAAAKgAFFAgIBAAAAA==.',['圣光']='圣光与你同在:BAAAKgAECgEIAQAAAA==.圣光之耀:BAABKgAFFH8GAAIKAAYIaR3WIQBmAQAKAAYIaR3WIQBmAQABKgAFFAgIEQASAEEeAA==.圣光阿圣光:BAAAKgAECgQIBAAAAA==.',['圣斗']='圣斗士星矢:BAAAKgADCgEIAQAAAA==.',['圣骑']='圣骑妇联主任:BAAAKgADCggICAAAAA==.',['埼玉']='埼玉:BAAAKgAFFAYIBAAAAA==.',['堂庭']='堂庭:BAABKgAFFH8GAAMQAAYILg6zBgAEAQAQAAUIOgqzBgAEAQAPAAEI1gqdIgBRAAAAAA==.',['墨染']='墨染丶:BAACKgAFFH8ZAAQVAAYI8BQ0DgCDAQAVAAYI8BQ0DgCDAQAbAAIIhw3IKAB8AAAUAAEIiAayLQAyAAAqAAQKfzQAAxsACAjPHmMQANQBABsACAipG2MQANQBABUABQhqIEpHACIBAAAA.',['墨水']='墨水:BAAAKgAECgUIBQAAAA==.',['墨灬']='墨灬凌:BAABKgAFFH8GAAIOAAYIGh6rBwCXAQAOAAYIGh6rBwCXAQAAAA==.',['夜刀']='夜刀神狗:BAAAKgAECgYIBgAAAA==.',['夜到']='夜到来白相:BAAAKgAFFAcIBAABKgAFFAgIBAAMAAAAAA==.',['大叔']='大叔的荣耀:BAABKgAFFH8HAAIKAAIIEgdWSABoAAAKAAIIEgdWSABoAAAAAA==.',['大罗']='大罗洞观:BAABKgAFFH8IAAIUAAQINxFmGQCvAAAUAAQINxFmGQCvAAAAAA==.',['天使']='天使康康:BAAAKgAECggICAAAAA==.',['天啊']='天啊丶你真高:BAAAKgAFFAgIBAAAAA==.',['天黑']='天黑就变身:BAAAKgAECggIBgAAAA==.',['奥妙']='奥妙:BAAAKgADCgYIBgAAAA==.',['奥蕾']='奥蕾莉婭:BAAAKgAECgYIBgABKgAECggIDQAMAAAAAA==.',['奶不']='奶不动德:BAABKgAFFH8NAAMSAAQI5QtdPAC1AAASAAQI5QtdPAC1AAAcAAMIDQXTKgB2AAAAAA==.',['妃鱈']='妃鱈:BAAAKgADCggICAAAAA==.',['妙丨']='妙丨脆角:BAABKgAFFH8KAAMBAAQILgfaGACgAAABAAQILgfaGACgAAACAAIIQwPJMQBAAAAAAA==.',['子不']='子不语夏沫:BAAAKgAECgYIBwAAAA==.子不语秋初:BAAAKgAECggIEQAAAA==.',['孤街']='孤街亡魂:BAAAKgAFFAgIBAAAAA==.',['孽杀']='孽杀:BAABKgAFFH8IAAIEAAgIexheBQBHAgAEAAgIexheBQBHAgAAAA==.',['安迪']='安迪沃特:BAABKgAECn8qAAIKAAgIhR1QRAAiAgAKAAgIhR1QRAAiAgAAAA==.',['宓璃']='宓璃:BAABKgAFFH8GAAIFAAYI5RBhDAA+AQAFAAYI5RBhDAA+AQAAAA==.',['寒羽']='寒羽良:BAAAKgAECgQIBAAAAA==.',['寶寶']='寶寶白:BAAAKgAECgQIBgAAAA==.',['封肆']='封肆:BAABKgAFFH8GAAIFAAMI2gsLGgCZAAAFAAMI2gsLGgCZAAAAAA==.',['射九']='射九朝天:BAABKgAFFH8KAAIFAAgIvRWBBgABAgAFAAgIvRWBBgABAgAAAA==.',['射手']='射手不在伤心:BAAAKgAECggICAAAAA==.',['射绵']='射绵疑:BAABKgAFFH8GAAIFAAYIgwY4EQDpAAAFAAYIgwY4EQDpAAAAAA==.',['将错']='将错就错:BAABKgAFFH8XAAIKAAUI0h1+FQBGAQAKAAUI0h1+FQBGAQAAAA==.',['小兔']='小兔子乖乖:BAAAKgAECgYICQAAAA==.',['小号']='小号狂魔:BAABKgAFFH8GAAIaAAYISw6EBgAIAQAaAAYISw6EBgAIAQAAAA==.',['小德']='小德伊伊:BAABKgAECn8UAAQSAAgIhiANHQBUAgASAAgIhiANHQBUAgAcAAQIqxXITgDRAAAdAAEIrgfYRQAPAAAAAA==.',['小木']='小木曾雪菜丶:BAAAKgADCgQIBAAAAA==.',['小火']='小火龙:BAAAKgAECgUICwAAAA==.',['小能']='小能貓:BAABKgAECn8WAAILAAgIdiLrDgCPAgALAAgIdiLrDgCPAgAAAA==.',['小雪']='小雪凝:BAABKgAECn8VAAMQAAgI5xGdMgBVAQAQAAgI5xGdMgBVAQAPAAIIqBCrUABrAAAAAA==.',['小鞭']='小鞭子:BAABKgAECn8WAAIKAAgIURr3OgAUAgAKAAgIURr3OgAUAgAAAA==.',['少时']='少时诵诗书:BAABKgAFFH8PAAICAAQIdRRPHgCwAAACAAQIdRRPHgCwAAAAAA==.',['尔唯']='尔唯尔福:BAAAKgAECgEIAQAAAA==.',['就这']='就这五个字:BAAAKgAECgYIBgAAAA==.',['居莱']='居莱尔丶:BAAAKgAFFAQIBAAAAA==.',['屮乂']='屮乂屮:BAAAKgAFFAIIAgAAAA==.',['岚色']='岚色妖姬:BAAAKgADCgMIBAAAAA==.',['巫马']='巫马:BAABKgAFFH8OAAIHAAQI2hN1FgDPAAAHAAQI2hN1FgDPAAAAAA==.',['帕雷']='帕雷托:BAABKgAECn8dAAMRAAgIWxYEOADKAQARAAgIWxYEOADKAQAeAAIIQQjeZgA/AAAAAA==.帕雷托的骑士:BAAAKgAECggIEAAAAA==.',['幻灵']='幻灵清心:BAABKgAFFH8LAAIHAAgIxhySBwAYAgAHAAgIxhySBwAYAgAAAA==.',['幻瞳']='幻瞳:BAAAKgAECgEIAQAAAA==.',['庶爺']='庶爺:BAAAKgAECgQIBAAAAA==.',['式部']='式部帆夏:BAAAKgAFFAQIBAAAAA==.',['得汝']='得汝衣:BAAAKgADCgcIBwAAAA==.',['德小']='德小喵二号:BAAAKgAECgYICAAAAA==.',['心棱']='心棱丶:BAAAKgAECgEIAQAAAA==.',['忘者']='忘者归来:BAAAKgAECgYICgAAAA==.',['忠不']='忠不可言:BAACKgAFFH8FAAISAAQIXh+MPAC1AAASAAQIXh+MPAC1AAAqAAQKfx0ABBIACAhGIP0eAFACABIACAhGIP0eAFACABwAAQhKEJ2FADUAAB8AAQjIAcQzABAAAAAA.',['恋七']='恋七七:BAAAKgAECgYICgAAAA==.',['恋凌']='恋凌凌:BAAAKgAECgYICQAAAA==.',['悄悄']='悄悄片:BAACKgAFFH8ZAAIBAAQIFx+SIwAHAQABAAQIFx+SIwAHAQAqAAQKfyIAAgEACAhjI8ceAEkCAAEACAhjI8ceAEkCAAAA.',['情丶']='情丶未央:BAAAKgAFFAQIBAAAAA==.',['惨叫']='惨叫姬:BAABKgAFFH8GAAMQAAYIDyJICgB9AQAQAAUIoiFICgB9AQAPAAEIaQdRLQA/AAABKgAFFAgICAAQALsjAA==.',['扶风']='扶风若柳:BAAAKgADCggICAAAAA==.',['抱布']='抱布贸丝:BAAAKgAECgUIBgAAAA==.',['断易']='断易:BAAAKgAECgYICwAAAA==.',['无敌']='无敌狼:BAAAKgAECgMIAwAAAA==.无敌的神马:BAAAKgAECggICQAAAA==.',['无气']='无气战:BAAAKgAFFAgIBAAAAA==.',['无辜']='无辜肉盾:BAAAKgAECgcIDAAAAA==.',['无限']='无限:BAAAKgAECgEIAQAAAA==.',['旺财']='旺财:BAABKgAECn8YAAMBAAgIRRa0KwDNAQABAAgIRRa0KwDNAQACAAEIlwORIgAUAAAAAA==.',['昔我']='昔我往矣:BAAAKgAECgMIAwAAAA==.',['星光']='星光小鴨:BAACKgAFFH8RAAILAAQIQSCpFAAZAQALAAQIQSCpFAAZAQAqAAQKfx0AAgsACAioIv8YAEQCAAsACAioIv8YAEQCAAAA.',['星烬']='星烬:BAABKgAFFH8GAAIVAAYI/Ad9GgARAQAVAAYI/Ad9GgARAQAAAA==.',['星际']='星际争霸:BAABKgAFFH8FAAIcAAMIGwXcKwBvAAAcAAMIGwXcKwBvAAAAAA==.',['映射']='映射:BAAAKgAFFAYIAwAAAA==.',['春鸽']='春鸽的图腾:BAAAKgAFFAQIBAAAAA==.',['晋麒']='晋麒:BAAAKgAECggICAABKgAFFAQIAgAMAAAAAA==.',['普罗']='普罗米修斯:BAAAKgADCggICAAAAA==.',['暗夜']='暗夜微光:BAAAKgADCgYIDAAAAA==.暗夜界:BAAAKgAECgUIBQAAAA==.',['暗月']='暗月飘凌:BAAAKgADCgMIAwAAAA==.',['暮雨']='暮雨晨曦:BAAAKgAECgYIBgAAAA==.',['暴躁']='暴躁小小果:BAAAKgAFFAYIBAAAAA==.',['曲奇']='曲奇吐毛毛球:BAAAKgAECggICAAAAA==.',['曲尘']='曲尘花:BAAAKgAECgEIAQAAAA==.',['曾经']='曾经美好回忆:BAAAKgAECggIEAAAAA==.',['最强']='最强地板王:BAAAKgAFFAQIBAAAAA==.',['最终']='最终审判:BAAAKgAFFAYIBAAAAA==.',['月亮']='月亮山的猫:BAAAKgAECgUIBQAAAA==.',['朦朦']='朦朦恶魔:BAABKgAECn8UAAIPAAYIdRRqNQA7AQAPAAYIdRRqNQA7AQAAAA==.',['木子']='木子嫣:BAAAKgAECgIIAgAAAA==.',['末日']='末日疾风:BAAAKgAFFAQIBAAAAA==.',['朱丽']='朱丽叶萝卜丝:BAAAKgAECgUIBwAAAA==.',['杀猪']='杀猪帝:BAAAKgADCggICAAAAA==.',['极品']='极品三好生:BAAAKgAECgcIBwAAAA==.',['林中']='林中狮:BAAAKgADCggICAAAAA==.',['果奔']='果奔的傻羊:BAAAKgAECggICAAAAA==.',['柠檬']='柠檬叶儿:BAAAKgAECgYIBgAAAA==.柠檬手撕鸡:BAABKgAFFH8GAAMcAAYINgYMHQC8AAAcAAUIDgcMHQC8AAASAAEITwPYXgA8AAABKgAFFAgIBAAMAAAAAA==.',['柳烟']='柳烟:BAAAKgAFFAMIAwAAAA==.',['格里']='格里尔斯丶:BAAAKgADCggICAAAAA==.',['桐舟']='桐舟:BAAAKgAECgcIBwAAAA==.',['桐范']='桐范范:BAAAKgAECgYIBgAAAA==.',['梦之']='梦之輪回:BAAAKgAECgcIBwAAAA==.',['棒棒']='棒棒冰:BAAAKgAFFAIIAwAAAA==.',['橙汁']='橙汁志:BAABKgAFFH8HAAIgAAcIyQhpDABqAQAgAAcIyQhpDABqAQAAAA==.',['檬心']='檬心丶:BAABKgAFFH8GAAIFAAYIwgcLEAD6AAAFAAYIwgcLEAD6AAAAAA==.',['武艺']='武艺:BAACKgAFFH8fAAQhAAQIEBgcEwDsAAAhAAMI3BccEwDsAAAaAAMIPQsGDwCIAAALAAIIvBRbNgBHAAAqAAQKfx8AAiEACAiGHZQNAEECACEACAiGHZQNAEECAAAA.',['歪比']='歪比歪比巴卜:BAABKgAFFH8RAAIgAAYIxSIrDQCQAQAgAAYIxSIrDQCQAQAAAA==.',['死亡']='死亡之角虫:BAAAKgADCgIIAgAAAA==.死亡灬乐章:BAAAKgADCgMIAwAAAA==.',['殇馨']='殇馨:BAAAKgADCgIIAgAAAA==.',['水里']='水里游的鱼:BAAAKgAFFAEIAQAAAA==.',['永恒']='永恒叶:BAAAKgAECgMIAwAAAA==.',['江南']='江南奶绿:BAAAKgAFFAIIAgAAAA==.江南子:BAAAKgAECggICAAAAA==.',['沉默']='沉默圣光:BAAAKgAECgQIBQAAAA==.沉默的喜羊羊:BAAAKgAECgYIBwAAAA==.沉默的懒羊羊:BAAAKgAECgYIBwAAAA==.',['治疗']='治疗萨满:BAAAKgAECggICAAAAA==.',['浓浓']='浓浓曲奇:BAAAKgAECgIIAgAAAA==.',['浪里']='浪里个西:BAAAKgADCgEIAQAAAA==.',['深深']='深深夜轻语:BAAAKgAECgIIAgAAAA==.',['温柔']='温柔波波:BAABKgAECn8WAAMNAAYIkxErMgC1AAANAAYIkxErMgC1AAAiAAEI6APTNwAXAAAAAA==.',['滨崎']='滨崎步:BAAAKgAECgQIBAAAAA==.',['演技']='演技派丶:BAAAKgAFFAQIBAAAAA==.',['漢堡']='漢堡神偷:BAABKgAFFH8OAAMNAAgIIA1TCADCAQANAAgIIA1TCADCAQAiAAEI+wdRGwBBAAAAAA==.',['灬巴']='灬巴哈姆特灬:BAABKgAFFH8HAAIgAAUItyAJDgCAAQAgAAUItyAJDgCAAQAAAA==.',['灰太']='灰太狼之殇:BAAAKgADCggICAAAAA==.',['灰色']='灰色轨迹:BAAAKgADCggICAAAAA==.',['灵魂']='灵魂收割者:BAAAKgADCgMIAwAAAA==.',['灼伤']='灼伤的影子:BAAAKgAECgEIAQAAAA==.',['炎汐']='炎汐:BAABKgAFFH8KAAILAAMIjRhOGgDsAAALAAMIjRhOGgDsAAAAAA==.',['热卤']='热卤电视机:BAAAKgAFFAIIAgAAAA==.',['焚书']='焚书坑部落:BAAAKgAECgYIBgAAAA==.',['熊熊']='熊熊:BAAAKgAECgQIBAAAAA==.',['爽至']='爽至哀伤:BAAAKgADCggICAAAAA==.',['牛可']='牛可:BAAAKgAFFAYIAwAAAA==.',['牛魔']='牛魔鬼:BAAAKgAECgYIBgAAAA==.',['特斯']='特斯拉毛豆歪:BAAAKgAECgEIAQAAAA==.',['犇犇']='犇犇:BAAAKgAECgQIBAAAAA==.',['狼教']='狼教授:BAAAKgAECggIEAAAAA==.',['猫丫']='猫丫:BAAAKgAECggICAAAAA==.',['猫也']='猫也笨笨:BAAAKgAFFAEIAwAAAA==.',['献给']='献给不朽:BAAAKgADCgEIAQAAAA==.',['玄天']='玄天无相:BAAAKgAECgUIBQAAAA==.',['王司']='王司徒:BAABKgAFFH8OAAIRAAYIwxBRBACbAQARAAYIwxBRBACbAQABKgAFFAgIHQARALolAA==.',['玖月']='玖月:BAACKgAFFH8mAAIOAAQIGBeBFQDMAAAOAAQIGBeBFQDMAAAqAAQKfxUAAg4ACAgwFKobAIMBAA4ACAgwFKobAIMBAAAA.',['玩意']='玩意:BAAAKgAECgUIBQAAAA==.',['珍惜']='珍惜:BAAAKgADCgUIBQAAAA==.',['琦琦']='琦琦乖乖:BAAAKgAECgYIBgAAAA==.',['瑪麗']='瑪麗婭:BAABKgAFFH8KAAMQAAgIBRgFBAALAgAQAAgIBRgFBAALAgAPAAIIZwvFFwClAAAAAA==.',['甘道']='甘道夫迷你版:BAAAKgAFFAIIAgAAAA==.',['甲人']='甲人:BAAAKgAECgIIAgAAAA==.',['界丶']='界丶小乌鸦:BAAAKgAECgUIBQAAAA==.',['疯狂']='疯狂的野狗:BAAAKgAECgQIBAAAAA==.',['登记']='登记环保费:BAAAKgAECgEIAQAAAA==.',['白附']='白附子:BAAAKgAECggIEAAAAA==.',['相映']='相映:BAAAKgAECgUIBQAAAA==.',['瞬间']='瞬间瞬间瞬间:BAAAKgAFFAYIBAABKgAFFAgICAAVALoSAA==.',['矮子']='矮子骑士:BAAAKgAECgYIBgAAAA==.',['矮牧']='矮牧有补贴:BAABKgAFFH8FAAIQAAMIxQUQGQB4AAAQAAMIxQUQGQB4AAAAAA==.',['砍你']='砍你没商量:BAAAKgAFFAEIAgAAAA==.',['碎悲']='碎悲之翼:BAAAKgAECgMIAwAAAA==.',['祀溢']='祀溢:BAABKgAFFH8QAAIUAAQIDBpWDwDoAAAUAAQIDBpWDwDoAAAAAA==.',['祈愿']='祈愿那份爱:BAAAKgAFFAIIAgAAAA==.',['祝你']='祝你健康:BAAAKgADCgIIAwAAAA==.',['神一']='神一卡雯:BAABKgAFFH8OAAMLAAgIPRZZCQC9AQALAAYIzh5ZCQC9AQAhAAgI9wE8DQA8AQAAAA==.',['神圣']='神圣赞美姬:BAABKgAFFH8IAAIQAAMITRIjGACGAAAQAAMITRIjGACGAAAAAA==.',['神罚']='神罚之箭:BAAAKgAECggIBAAAAA==.',['祭血']='祭血关山:BAAAKgAFFAEIAwAAAA==.',['福乐']='福乐芙:BAAAKgADCggICAAAAA==.',['福禄']='福禄寿:BAAAKgADCgQIBAAAAA==.',['禾竹']='禾竹稻栽:BAAAKgADCgMIBQAAAA==.',['秋昆']='秋昆丨小乌鸦:BAAAKgAECggIDAAAAA==.',['秋流']='秋流到冬:BAAAKgAFFAMIAwAAAA==.',['秋雨']='秋雨:BAAAKgAECgMIAwAAAA==.',['空虚']='空虚虚空:BAABKgAFFH8GAAIGAAMIwhyWEwD8AAAGAAMIwhyWEwD8AAAAAA==.',['空麻']='空麻袋背米:BAABKgAFFH8QAAMIAAYIgCLZAADsAQAIAAYIoyDZAADsAQAJAAQIqBgzDQDMAAABKgAFFAgIBAAMAAAAAA==.',['童曈']='童曈:BAABKgAFFH8IAAISAAgIIxdQBwAvAgASAAgIIxdQBwAvAgAAAA==.',['童话']='童话里做英雄:BAABKgAFFH8GAAILAAYIQR+yCgCgAQALAAYIQR+yCgCgAQAAAA==.',['笑傲']='笑傲九重天:BAAAKgAECgYIBgAAAA==.',['糖门']='糖门宗主:BAABKgAECn8eAAMHAAgIfCA2DwA0AgAHAAgIaiA2DwA0AgAJAAYIihlGKABdAQAAAA==.',['素羽']='素羽:BAAAKgAECggIDwAAAA==.',['素顔']='素顔丶:BAAAKgAECgMIAwAAAA==.',['紫涩']='紫涩清风:BAAAKgAFFAQIBAAAAA==.',['紫荆']='紫荆骑士:BAAAKgADCgMIAwAAAA==.',['紫菜']='紫菜菜:BAAAKgADCgQIBAAAAA==.',['綠嗏']='綠嗏灬:BAABKgAFFH8UAAMLAAYIVSSoAAD0AQAhAAYIVSSDBAD5AQALAAYINh+oAAD0AQAAAA==.',['织雾']='织雾诛:BAABKgAECn8VAAITAAYIIiDJCADAAQATAAYIIiDJCADAAQAAAA==.',['绝望']='绝望左右:BAAAKgAECgYICAAAAA==.',['统一']='统一绿茶:BAAAKgAECgQICQAAAA==.',['继续']='继续么么:BAABKgAFFH8IAAMBAAQI7RqeEAD3AAABAAQIjRqeEAD3AAACAAQIvxL2EAC5AAAAAA==.继续微笑:BAAAKgAECgMIAwAAAA==.',['绿洲']='绿洲星彩:BAAAKgAECgEIAQAAAA==.绿洲星战:BAAAKgADCgEIAQAAAA==.绿洲星智:BAAAKgADCgEIAQAAAA==.绿洲星渊:BAAAKgAECgEIAQAAAA==.绿洲星爆:BAAAKgADCggICAAAAA==.绿洲星珑:BAAAKgAECgMIAgAAAA==.绿洲星瑶:BAAAKgADCgUICgAAAA==.绿洲星紫:BAAAKgAECgUIBwAAAA==.',['缥缈']='缥缈孤鸿影:BAAAKgAFFAYIAgAAAA==.',['美心']='美心面包:BAAAKgAECgIIAgAAAA==.',['群友']='群友情绪价值:BAAAKgADCgUIBQAAAA==.',['老萨']='老萨尓:BAAAKgAECgEIAQAAAA==.',['联盟']='联盟的国王:BAAAKgAECgcICwAAAA==.',['背叛']='背叛圣光:BAABKgAECn8dAAMGAAgIyxqBBQAgAgAGAAgIyxqBBQAgAgAQAAYIuBABSQDuAAAAAA==.',['胖墩']='胖墩墩:BAAAKgADCggICQAAAA==.',['能奶']='能奶的大花猫:BAABKgAECn8UAAMGAAgIkRt+FQAZAgAGAAgI/Bh+FQAZAgAQAAUIvRSXUAD2AAAAAA==.',['舞夜']='舞夜幽兰:BAABKgAFFH8QAAMQAAUIqB4VFQALAQAQAAQIzCIVFQALAQAPAAUIZg6dEwDhAAAAAA==.',['艾雅']='艾雅俐:BAAAKgADCggICAAAAA==.',['芫荽']='芫荽:BAAAKgAECgMIAwAAAA==.',['花与']='花与琴的流星:BAAAKgAFFAQIBAAAAA==.',['花为']='花为谁而开:BAAAKgADCggIDAAAAA==.',['花之']='花之浮尘:BAAAKgAECgIIAgAAAA==.花之窨儿:BAAAKgAFFAMIAwAAAA==.',['花落']='花落无声:BAAAKgADCggICwAAAA==.',['茉莉']='茉莉儿:BAAAKgADCggICQAAAA==.茉莉冰冰:BAAAKgADCggIFAAAAA==.',['茱萸']='茱萸:BAAAKgAECggICAAAAA==.',['莎缇']='莎缇拉:BAAAKgAECgMIBwAAAA==.',['菠菜']='菠菜大王:BAAAKgAECggICAAAAA==.',['萌萌']='萌萌哒唯一酱:BAAAKgAFFAQIBAABKgAFFAgICAANALsbAA==.萌萌的德德:BAAAKgAECgYIBwAAAA==.',['萤之']='萤之光:BAABKgAFFH8NAAMEAAYIfSPUCgDAAQAEAAYIkSLUCgDAAQAFAAQInBzdBwAIAQAAAA==.',['落雨']='落雨之锋:BAABKgAFFH8NAAICAAYIkA4XEgASAQACAAYIkA4XEgASAQABKgAFFAgIDgABAEoXAA==.',['落雪']='落雪无忧:BAAAKgADCggICAAAAA==.落雪流殇:BAABKgAFFH8IAAIEAAgIiQkeCwC8AQAEAAgIiQkeCwC8AQAAAA==.',['虾仁']='虾仁不眨眼:BAAAKgAFFAEIAgAAAA==.',['蟹蟹']='蟹蟹的誓言:BAAAKgAECgMIAwAAAA==.',['血溅']='血溅江湖:BAABKgAFFH8GAAIKAAYIxhFPEwBpAQAKAAYIxhFPEwBpAQAAAA==.',['血色']='血色圣教军:BAAAKgAECgcIBAAAAA==.',['西瓜']='西瓜没有籽:BAAAKgAECgYIDgAAAA==.',['语隔']='语隔秋烟:BAAAKgADCgcIDAAAAA==.',['读灬']='读灬条:BAAAKgADCgUIBQAAAA==.',['谷氨']='谷氨酰胺:BAAAKgAFFAQIAgAAAA==.',['负二']='负二代:BAAAKgAECgYIBgAAAA==.',['贼特']='贼特么闹腾:BAAAKgAECgcIDQAAAA==.',['赞达']='赞达亚:BAABKgAFFH8GAAIKAAYI4g8QIQBqAQAKAAYI4g8QIQBqAQAAAA==.',['起飞']='起飞的奶:BAAAKgADCgIIAgAAAA==.',['路过']='路过来搞我:BAABKgAFFH8GAAIKAAYIhg1JMgAgAQAKAAYIhg1JMgAgAQAAAA==.',['辣鸡']='辣鸡尼光:BAACKgAFFH8IAAMCAAYIixJPBABMAQACAAYILBJPBABMAQABAAII/Q4PKgB5AAAqAAQKfxUAAwEACAjPIpMYAG0CAAEACAjPIpMYAG0CAAIABwh2CLg9AMoAAAAA.',['达不']='达不溜:BAAAKgAECggIEAAAAA==.达不溜贼:BAAAKgAECgUIBQAAAA==.',['迈扣']='迈扣唐小葶:BAAAKgAECgYICAAAAA==.',['还我']='还我漂漂拳:BAAAKgAECgEIAQAAAA==.',['远山']='远山小增:BAAAKgAECggICgAAAA==.远山小术也:BAAAKgAECgcIDAAAAA==.远山小纱幔:BAABKgAECn8YAAIiAAgI2BpnFgAYAgAiAAgI2BpnFgAYAgAAAA==.远山要爆发:BAABKgAECn8iAAMgAAgIIxdDGAD3AQAgAAgIIxdDGAD3AQAjAAQI4wy8DAB2AAAAAA==.',['迪菲']='迪菲亚夜行者:BAAAKgAECgYICgAAAA==.迪菲亚穿行者:BAAAKgADCgMIAwAAAA==.',['迷你']='迷你版豆豆法:BAABKgAFFH8GAAIVAAMI5gMwIQB6AAAVAAMI5gMwIQB6AAAAAA==.',['追光']='追光者:BAAAKgAECgUIBQAAAA==.',['逖耶']='逖耶里亚:BAAAKgADCgQIBAAAAA==.',['逗妞']='逗妞士:BAABKgAFFH8HAAILAAQIsARbFwCjAAALAAQIsARbFwCjAAAAAA==.',['遂心']='遂心迩迵:BAABKgAFFH8IAAIKAAgIihS9DwDjAQAKAAgIihS9DwDjAQAAAA==.',['那一']='那一抹丶怣:BAAAKgADCggICAAAAA==.那一抹丶殘:BAAAKgADCgIIAgAAAA==.',['那个']='那个術士:BAAAKgAFFAQIBAAAAA==.',['那年']='那年丶冬天:BAAAKgAECgMIAwAAAA==.',['那抹']='那抹殇丶葬訫:BAAAKgAECgQIBAAAAA==.',['邪恶']='邪恶摇粒绒:BAABKgAECn8XAAMNAAgIYRvTLADWAQANAAgIYRvTLADWAQAiAAEImgEmkAANAAAAAA==.',['邪王']='邪王小白:BAAAKgADCgcIBwAAAA==.',['都给']='都给我上:BAAAKgAFFAMIAwAAAA==.',['酒酒']='酒酒妹:BAAAKgADCgMIAwAAAA==.',['酸酸']='酸酸乳:BAABKgAFFH8IAAMaAAMIoQgCCgCIAAALAAMIDAepFQC2AAAaAAMI5wcCCgCIAAAAAA==.',['醉爱']='醉爱砂锅鱼头:BAABKgAFFH8JAAMFAAIITAtmIgBfAAAEAAII1QeOQABkAAAFAAIInwdmIgBfAAAAAA==.',['重组']='重组辉煌:BAAAKgAECggIEAABKgAFFAgIDgAVACQgAA==.',['野蛮']='野蛮射尊:BAAAKgAFFAMIBAAAAA==.',['金香']='金香吻水晶梦:BAAAKgADCgMIAwAAAA==.',['钟薛']='钟薛高:BAAAKgAECgUIBQABKgAECggIDQAMAAAAAA==.',['银月']='银月之耀:BAAAKgADCgMIAwAAAA==.',['长沙']='长沙芙蓉战神:BAAAKgADCggICAAAAA==.',['闪舞']='闪舞精灵:BAACKgAFFH8NAAIWAAMI6BXUFwDoAAAWAAMI6BXUFwDoAAAqAAQKfxcAAhYACAiAHGsNAEcCABYACAiAHGsNAEcCAAAA.',['阅云']='阅云台:BAAAKgADCgEIAQAAAA==.',['阅读']='阅读速度过快:BAAAKgAECgEIAQAAAA==.',['阿紫']='阿紫丶:BAAAKgAECgQIBAAAAA==.',['阿萨']='阿萨斯的禁脔:BAAAKgAECgMIAwAAAA==.',['陪小']='陪小雨看星星:BAABKgAFFH8GAAIkAAYIgxM7BwB0AQAkAAYIgxM7BwB0AQAAAA==.',['雪衣']='雪衣吥染塵:BAAAKgAECgcICQAAAA==.',['雷诺']='雷诺:BAAAKgAECgYIBgAAAA==.',['霄月']='霄月:BAAAKgADCgcIBwAAAA==.',['風月']='風月無邉:BAAAKgADCggIDwAAAA==.',['风云']='风云无极:BAAAKgAECgIIAgAAAA==.',['风刀']='风刀冰箭:BAAAKgADCgEIAQAAAA==.',['风舞']='风舞之殇:BAABKgAECn8bAAMDAAgIZRreBwD6AQADAAgI4xfeBwD6AQABAAgI+xX8LQDBAQAAAA==.',['风雪']='风雪飞扬:BAAAKgADCgIIAgAAAA==.',['风霜']='风霜雪夜:BAABKgAFFH8GAAIBAAYIAiWjCQDyAQABAAYIAiWjCQDyAQABKgAFFAgIFQAiAEUeAA==.',['香辣']='香辣避雷针:BAABKgAFFH8IAAMSAAgIuhx6CwDdAQASAAYIJCR6CwDdAQAcAAII6Q0MJQCRAAAAAA==.',['驍骑']='驍骑:BAAAKgAECgEIAQAAAA==.',['马杀']='马杀姬:BAAAKgADCgEIAQAAAA==.',['高佬']='高佬福乐:BAAAKgAECgIIAgAAAA==.',['魂灵']='魂灵:BAAAKgAECggICQAAAA==.',['魅力']='魅力仔仔:BAAAKgAECgUIBgAAAA==.',['鹰眼']='鹰眼:BAABKgAFFH8GAAIFAAYIyhysDQCAAQAFAAYIyhysDQCAAQAAAA==.',['麦茶']='麦茶者:BAAAKgADCgYICAAAAA==.',['黄昏']='黄昏:BAACKgAFFH9GAAIRAAgIvCOaAgDGAgARAAgIvCOaAgDGAgAqAAQKfxcAAhEACAhSIU0kACwCABEACAhSIU0kACwCAAAA.黄昏的雨:BAAAKgADCgYIBgAAAA==.',['黄正']='黄正经:BAAAKgAFFAgIAwAAAA==.',['黎明']='黎明曙光丶:BAAAKgADCgEIAQAAAA==.',['黑妞']='黑妞无敌:BAAAKgADCgEIAQAAAA==.',['黑牛']='黑牛无敌:BAAAKgAECgMIAwAAAA==.',['黑藏']='黑藏獒:BAAAKgADCggICAAAAA==.',['齐格']='齐格弗里牧歌:BAABKgAFFH8GAAINAAYIYRrNCwCKAQANAAYIYRrNCwCKAQAAAA==.',['龑爺']='龑爺:BAAAKgADCgEIAQAAAA==.',['龙卷']='龙卷:BAAAKgAECgIIAgAAAA==.',['龙祈']='龙祈:BAAAKgAECgYIBgAAAA==.',['龙腾']='龙腾四海:BAAAKgADCgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end