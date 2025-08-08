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
 local lookup = {'Paladin-Retribution','Evoker-Devastation','Evoker-Augmentation','Mage-Frost','Mage-Fire','DemonHunter-Havoc','DeathKnight-Blood','DeathKnight-Unholy','Hunter-BeastMastery','Druid-Restoration','Druid-Balance','Paladin-Holy','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','DemonHunter-Vengeance','Rogue-Subtlety','Rogue-Assassination','Warrior-Fury','Mage-Arcane',}; local provider = {region='CN',realm='达克萨隆',name='CN',type='weekly',zone=42,date='2025-08-08',data={Br='Bride:BAAAKgAECgYICAAAAA==.',Cg='Cgmmi:BAAAKgAECggICAAAAA==.',Co='Conclusion:BAABKgAFFH8GAAIBAAYImBCOKwA5AQABAAYImBCOKwA5AQABKgAFFAgINQACAO8kAA==.',En='Endpeak:BAAAKgAECgEIAQAAAA==.',Fl='Flyingkobe:BAAAKgAFFAQIBAAAAA==.',Li='Lillness:BAACKgAFFH81AAICAAgI7ySmAgCrAgACAAgI7ySmAgCrAgAqAAQKfzUAAwIACAiEI0EJAJoCAAIACAiEI0EJAJoCAAMAAwjZB18HAFgAAAAA.Lindor:BAAAKgADCgEIAQAAAA==.',Sb='Sbavc:BAAAKgADCgcIBwAAAA==.',Sn='Snakiehollic:BAABKgAFFH8SAAMEAAYIZyMeAgADAgAEAAYIZyMeAgADAgAFAAYIXhNNDQBjAQAAAA==.',Yo='Yokoh:BAABKgAECn8nAAIGAAgIsSEYDgCVAgAGAAgIsSEYDgCVAgAAAA==.',Ze='Zeus:BAABKgAFFH8LAAIBAAYInBddGwCIAQABAAYInBddGwCIAQAAAA==.',['万丈']='万丈红尘:BAACKgAFFH8OAAIHAAMI/gBlMQBEAAAHAAMI/gBlMQBEAAAqAAQKfyAAAgcACAgEBXs4AKIAAAcACAgEBXs4AKIAAAAA.',['丩乄']='丩乄亅乊卩:BAAAKgAFFAQIBAAAAA==.',['丶恩']='丶恩赐解脱:BAABKgAFFH8GAAMHAAQIzRRJFACnAAAHAAQIAw1JFACnAAAIAAII4xXjJgCKAAAAAA==.',['丶拔']='丶拔帝倚天灬:BAAAKgAECggICAAAAA==.',['丶烛']='丶烛九阴:BAABKgAFFH8GAAICAAYInBAdFAAwAQACAAYInBAdFAAwAQAAAA==.',['丶阿']='丶阿宝:BAAAKgAFFAQIBAAAAA==.',['乔巴']='乔巴小骑士:BAABKgAFFH8MAAIBAAYIWRy8FQCtAQABAAYIWRy8FQCtAQAAAA==.',['享受']='享受卖萌:BAAAKgADCgQIBQAAAA==.',['以德']='以德唬人:BAAAKgADCggICAAAAA==.',['优质']='优质劣人:BAABKgAECn8qAAIJAAgIXB2AHwBDAgAJAAgIXB2AHwBDAgAAAA==.',['假如']='假如没人看到:BAAAKgADCggIFgAAAA==.',['元素']='元素灰烬:BAAAKgAFFAEIAQAAAA==.',['勇敢']='勇敢的张:BAAAKgAECgYIBgAAAA==.',['北洋']='北洋之狼:BAAAKgAECggICgAAAA==.',['古今']='古今第一喷:BAAAKgAECgMIAwAAAA==.',['咕咕']='咕咕子:BAAAKgAECggICQAAAA==.',['啊酷']='啊酷呐玛塔塔:BAAAKgAFFAEIAQAAAA==.',['嘿眼']='嘿眼圈:BAAAKgADCgIIAgAAAA==.',['四系']='四系乃:BAAAKgAECgYIBgAAAA==.',['堀未']='堀未央奈:BAAAKgAFFAQIBAAAAA==.',['塞萌']='塞萌丶德:BAACKgAFFH8zAAMKAAgIkA3yAgBZAQAKAAgIkA3yAgBZAQALAAYIqAWoBgA+AQAqAAQKfxoAAwoACAhvEEQtAHIBAAoACAhvEEQtAHIBAAsACAgzEeFUAGYBAAAA.',['壹贰']='壹贰叁:BAAAKgADCggICAAAAA==.',['复关']='复关:BAABKgAFFH8HAAMBAAMIywlSXQC2AAABAAMIywlSXQC2AAAMAAMIeAtGDACVAAAAAA==.复关灬:BAAAKgAECgIIAgAAAA==.',['夏日']='夏日微寒:BAAAKgAECggICAAAAA==.',['夜幕']='夜幕骑士:BAAAKgAECgIIAgAAAA==.',['天使']='天使姐姐:BAAAKgAECgQIBAAAAA==.',['奥客']='奥客:BAAAKgAECgMIAwAAAA==.',['好哥']='好哥们:BAABKgAECn8XAAMMAAgIChbVJAA3AQAMAAcI4RPVJAA3AQABAAMIGRtUtwDjAAAAAA==.',['孤存']='孤存:BAACKgAFFH8NAAIGAAQI7Bk9GAA6AQAGAAQI7Bk9GAA6AQAqAAQKfx0AAgYACAjkHXoiADYCAAYACAjkHXoiADYCAAAA.',['它喵']='它喵喵术:BAAAKgAFFAQIBAAAAA==.',['小丶']='小丶旋风:BAAAKgAECgMIAwAAAA==.',['小炳']='小炳:BAAAKgAECgIIAgAAAA==.',['就打']='就打丶那个德:BAAAKgAECgYIBgAAAA==.',['巅峰']='巅峰滑水员:BAABKgAECn8hAAIBAAgIWCQHEgDDAgABAAgIWCQHEgDDAgAAAA==.',['布兰']='布兰:BAACKgAFFH8UAAMKAAQI9x6+EwACAQAKAAQI9x6+EwACAQALAAQI7AeFQgCjAAAqAAQKfyEAAwoACAgSHj4RAB4CAAoACAgSHj4RAB4CAAsAAQhYCNbZACwAAAEqAAUUCAgVAAUAthEA.',['帕瓦']='帕瓦:BAACKgAFFH8VAAIFAAQIthHFHADIAAAFAAQIthHFHADIAAAqAAQKfy4AAwUACAgNFtgSALUBAAUACAjiE9gSALUBAAQACAhAElY+AHEBAAAA.',['幼稚']='幼稚园杀手:BAAAKgAECgcIBwAAAA==.',['广坤']='广坤:BAABKgAFFH8GAAIBAAYIbg+cEwBlAQABAAYIbg+cEwBlAQAAAA==.',['开飞']='开飞机的贝塔:BAAAKgADCgIIAgAAAA==.',['御宅']='御宅男丶曹:BAABKgAFFH8GAAINAAYIYg1eDQApAQANAAYIYg1eDQApAQAAAA==.',['懒丶']='懒丶堕:BAAAKgAECgIIAgAAAA==.',['懒舵']='懒舵:BAAAKgADCgIIAgAAAA==.',['我不']='我不止一粒丹:BAAAKgAECgEIAQAAAA==.',['揍你']='揍你的猫:BAACKgAFFH8QAAIOAAUIGxIaIwBLAAAOAAUIGxIaIwBLAAAqAAQKfxkAAw4ACAgiG5gWAPQBAA4ACAgiG5gWAPQBAA8ABQgwD/9VAOIAAAAA.',['无敌']='无敌小母猫:BAAAKgAECgUICQAAAA==.',['无聊']='无聊的虾米:BAAAKgAECgcIBwAAAA==.',['有你']='有你不寂寞:BAAAKgAECgYIDgAAAA==.',['有术']='有术无道:BAAAKgAFFAgIBAAAAA==.',['朵喵']='朵喵喵丶:BAACKgAFFH8GAAINAAYIDxggDwBwAQANAAYIDxggDwBwAQAqAAQKfxwAAwkABwjrHZxiAIkBAAkABwjrHZxiAIkBAA0ABAi9BC51AGcAAAAA.',['杜兰']='杜兰德尔:BAABKgAFFH8GAAIBAAYInCSBEQDSAQABAAYInCSBEQDSAQAAAA==.',['杰克']='杰克萨利:BAABKgAECn8UAAICAAgIohCkKQBtAQACAAgIohCkKQBtAQAAAA==.',['桃夭']='桃夭丶:BAAAKgAECgEIAQAAAA==.',['梦玉']='梦玉挲:BAAAKgADCgQIBAAAAA==.',['残角']='残角大王:BAAAKgAECgQIBwAAAA==.',['水中']='水中的火焰:BAACKgAFFH8PAAIQAAgIbhY2AwCYAQAQAAgIbhY2AwCYAQAqAAQKfxQAAxAABwjgFIVAAGgBABAABwigEoVAAGgBABEABAhiD9FUAJkAAAAA.',['洋河']='洋河吴彦祖:BAAAKgAFFAQIBAAAAA==.',['火山']='火山灰:BAACKgAFFH9PAAMNAAgI7Rk6BABFAgANAAgIyhk6BABFAgAJAAcILxC6BQBvAQAqAAQKfyQAAwkACAjBI6sdAIECAAkACAicI6sdAIECAA0ABwh/E3JTAM8AAAAA.',['灬阿']='灬阿蒙灬:BAABKgAFFH8MAAMLAAYIrCS3CQD5AQALAAYIrCS3CQD5AQAKAAYIxhNACwBSAQAAAA==.',['烛九']='烛九阴:BAAAKgAECgYICgAAAA==.',['牦牛']='牦牛:BAAAKgAECgMIAwAAAA==.',['牵芊']='牵芊公主:BAAAKgAECgEIAQAAAA==.',['狗拾']='狗拾叁:BAAAKgAECggICAAAAA==.',['玄牝']='玄牝之门:BAABKgAECn8ZAAIBAAgI9yMUGAC3AgABAAgI9yMUGAC3AgAAAA==.',['瑪琉']='瑪琉染柒:BAABKgAFFH8JAAMQAAcIPgsoGgA0AQAQAAYIagooGgA0AQASAAEIZQ/wHwBLAAAAAA==.',['电你']='电你的猫:BAAAKgADCggIEAAAAA==.',['白石']='白石麻衣:BAAAKgAFFAgIAwAAAA==.',['第一']='第一射:BAABKgAFFH8GAAIJAAMIBxRVGQDKAAAJAAMIBxRVGQDKAAAAAA==.',['简单']='简单点:BAAAKgAECggIDQAAAA==.',['箭染']='箭染春水:BAAAKgAECgMIAwAAAA==.',['素手']='素手绾青丝:BAABKgAECn8aAAMTAAgIBBXBIQByAQATAAgIBBXBIQByAQAGAAYIegP0mAA0AAAAAA==.',['红丶']='红丶枣:BAAAKgAECgEIAQAAAA==.',['红叶']='红叶舞秋山:BAAAKgADCggICAAAAA==.',['羽入']='羽入:BAABKgAFFH8IAAMUAAQI+hY0CQDfAAAUAAQI5ws0CQDfAAAVAAQIyxUAAAAAAAAAAA==.',['脏哥']='脏哥:BAABKgAFFH8MAAIWAAYIxA1vCgCBAQAWAAYIxA1vCgCBAQAAAA==.',['芷兮']='芷兮丶:BAAAKgAECggICAAAAA==.芷兮灬:BAAAKgAECggIDAAAAA==.',['苦酒']='苦酒折柳:BAABKgAECn8mAAIXAAgI9hhJCADjAQAXAAgI9hhJCADjAQAAAA==.',['草莓']='草莓德里克:BAAAKgADCgIIAgAAAA==.',['萌妙']='萌妙妙:BAAAKgAECggIBgAAAA==.',['落地']='落地还钱:BAABKgAFFH8UAAIBAAgIhBzpCgAYAgABAAgIhBzpCgAYAgAAAA==.',['解脱']='解脱:BAAAKgADCgYIBgAAAA==.',['谁啊']='谁啊:BAAAKgAFFAcIBAAAAA==.',['财神']='财神灬宝宝:BAAAKgADCgIIAgAAAA==.',['逆天']='逆天逍遥:BAAAKgAECgMIAwAAAA==.',['通碧']='通碧:BAAAKgAECgQIBAAAAA==.',['邪能']='邪能之主:BAAAKgADCggICwAAAA==.',['野蛮']='野蛮婆娘:BAAAKgAECgUIBQAAAA==.',['阎魔']='阎魔奇迹:BAABKgAFFH8GAAIEAAYIyRSaBwBKAQAEAAYIyRSaBwBKAQAAAA==.',['阿努']='阿努恩罗摩:BAAAKgAECgUIBgAAAA==.',['青灯']='青灯佛茶:BAABKgAECn8WAAMIAAgIyxmCSACTAQAIAAgIzBiCSACTAQAHAAgI/QwwLgAhAQAAAA==.',['魔魂']='魔魂恶魄:BAABKgAECn8oAAMFAAgIhBx5DAARAgAFAAgIEBl5DAARAgAEAAcIVx0OGQDsAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end