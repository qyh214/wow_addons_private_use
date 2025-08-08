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
 local lookup = {'Mage-Fire','Mage-Arcane','Mage-Frost','Druid-Balance','Druid-Guardian','Druid-Restoration','Warlock-Destruction','Paladin-Retribution','Paladin-Protection','Warrior-Fury','Priest-Shadow','Priest-Discipline','Warlock-Demonology','Warlock-Affliction','Rogue-Assassination','Shaman-Restoration','Hunter-Marksmanship','Evoker-Devastation','Evoker-Augmentation','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','DeathKnight-Blood','Warrior-Protection','Warrior-Arms','Priest-Holy','Hunter-BeastMastery','Unknown-Unknown','DemonHunter-Havoc','DeathKnight-Unholy','DemonHunter-Vengeance','Shaman-Enhancement','Evoker-Preservation','Rogue-Subtlety','Rogue-Outlaw','Shaman-Elemental',}; local provider = {region='CN',realm='阿格拉玛',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ad='Adnachiel:BAACKgAFFH8FAAIBAAMIigvlHgC8AAABAAMIigvlHgC8AAAqAAQKfyEABAEACAgdFU5PAEABAAEACAgBE05PAEABAAIAAgiMGKZwAJEAAAMABggJBHuAAJAAAAAA.',Al='Alberta:BAAAKgAECgQIBAAAAA==.All:BAACKgAFFH8fAAQEAAUIJgvDKADwAAAEAAUIJgvDKADwAAAFAAIIsgVODQBGAAAGAAIIawMuFwBFAAAqAAQKfxsAAwQACAgmD/FNAIABAAQACAgmD/FNAIABAAYACAgeCc1YAKwAAAEqAAUUBggqAAcAOBMA.',Ap='Apllo:BAAAKgADCgIIAgAAAA==.',As='Asmodel:BAABKgAFFH8FAAIIAAMI+RCmVwDBAAAIAAMI+RCmVwDBAAAAAA==.',Bo='Boomboomboom:BAAAKgAECgYIBgAAAA==.',Br='Breezing:BAAAKgAECgIIAgAAAA==.',Bu='Bujo:BAABKgAFFH8KAAIJAAgIYBS4BwCVAQAJAAgIYBS4BwCVAQAAAA==.',Ca='Calvados:BAABKgAFFH8GAAIHAAYIlhFxAwCPAQAHAAYIlhFxAwCPAQAAAA==.Cathy:BAAAKgAECgMIAwAAAA==.',Co='Cokie:BAAAKgAFFAYIBAAAAA==.Colab:BAAAKgAECgYICQABKgAFFAgICgAIACYlAA==.',Da='Dash:BAAAKgADCgQIBAAAAA==.',Ha='Haaland:BAAAKgAFFAMIBAAAAA==.Haerin:BAAAKgAFFAgIBAAAAA==.',Hi='Hingir:BAABKgAFFH8kAAMDAAMIuxMmFADGAAADAAMIuxMmFADGAAACAAMImAzbGAC1AAABKgAFFAgIIwAKAKobAA==.',Li='Lisa:BAACKgAFFH8JAAIDAAQIiRjyEgDNAAADAAQIiRjyEgDNAAAqAAQKfx0AAgMACAhrHjYPAFQCAAMACAhrHjYPAFQCAAAA.',Lu='Luxanna:BAABKgAECn8WAAMCAAgIGxyOHwD3AQACAAgIFhuOHwD3AQADAAcIWxS6LgBNAQABKgAFFAgIIAACAJkjAA==.',Ma='Malzahar:BAAAKgAECgIIAgAAAA==.',Me='Mefisto:BAAAKgAECgMIAwAAAA==.',Pu='Pupu:BAAAKgAECggIDAAAAA==.',Re='Reroll:BAABKgAFFH8MAAIIAAgIpiAwBgBbAgAIAAgIpiAwBgBbAgAAAA==.',Ru='Ruba:BAABKgAFFH8GAAMLAAYIGA7kBgA/AQALAAUIvA/kBgA/AQAMAAEImgtnJgBIAAAAAA==.',Sa='Saber:BAAAKgAECgEIAQAAAA==.',So='Sona:BAACKgAFFH8qAAIHAAYIOBMaDgBaAQAHAAYIOBMaDgBaAQAqAAQKfycABAcACAgFHq0YAC8CAAcACAgFHq0YAC8CAA0AAQhcEZ57ADcAAA4AAQh8B+BHAC8AAAAA.',Su='Su:BAAAKgAECgMIAwAAAA==.',Th='Thanos:BAAAKgAECgMIAwAAAA==.',Ti='Tifieya:BAAAKgAFFAQIAwAAAA==.',Ve='Veeshan:BAAAKgADCggICAAAAA==.',Wa='Waitagint:BAAAKgADCgMIAwAAAA==.',Xh='Xhuger:BAABKgAFFH8VAAIPAAQI9BXTCwDlAAAPAAQI9BXTCwDlAAAAAA==.',Za='Zaozaoaoao:BAABKgAFFH8QAAMBAAYIeiEXBwDoAQABAAYIeiEXBwDoAQADAAQIWhh1BwDyAAAAAA==.',Zz='Zzrt:BAABKgAFFH8IAAIQAAQI7Re1LgC8AAAQAAQI7Re1LgC8AAABKgAFFAgIDAARAF8VAA==.',['一一']='一一小宝贝:BAAAKgAECgQIBAAAAA==.',['一灰']='一灰太狼一:BAAAKgAECgUIBQAAAA==.',['一箭']='一箭走天下:BAAAKgAFFAEIAQAAAA==.',['一队']='一队那个洒满:BAAAKgAECgYIBgAAAA==.',['一魔']='一魔:BAAAKgAFFAMIAwAAAA==.',['七森']='七森莉莉:BAAAKgAFFAQIBAAAAA==.',['上帝']='上帝泪光:BAAAKgAECgQIBAAAAA==.',['不丨']='不丨离:BAAAKgAECgQIBAAAAA==.',['丶仟']='丶仟年杀:BAABKgAFFH8IAAICAAgIBRwNBABwAgACAAgIBRwNBABwAgAAAA==.',['丷小']='丷小朋友:BAABKgAFFH8KAAIIAAYIJiVhCQArAgAIAAYIJiVhCQArAgAAAA==.',['丽丽']='丽丽斯:BAAAKgADCggIDgAAAA==.',['么么']='么么黑:BAAAKgAECgYIDgAAAA==.',['二九']='二九一十八:BAACKgAFFH8KAAISAAgI/ROhCgDDAQASAAgI/ROhCgDDAQAqAAQKfxcAAxIACAibHQ4YAAECABIACAhzGw4YAAECABMAAwgxIa4DAPoAAAAA.',['云不']='云不归:BAAAKgAECggIDgAAAA==.',['井中']='井中月:BAAAKgAFFAgIAgAAAA==.',['人帅']='人帅刀快:BAAAKgADCggIDAAAAA==.',['从前']='从前多优秀:BAAAKgADCggICAAAAA==.',['从小']='从小就会:BAAAKgAECgQIBAAAAA==.',['从此']='从此不空车:BAABKgAFFH8QAAIUAAYIiiKfBgDXAQAUAAYIiiKfBgDXAQAAAA==.',['仙灵']='仙灵:BAACKgAFFH8ZAAMVAAQIgRdACAAyAQAVAAQIgRdACAAyAQAWAAMIAA2IBwCZAAAqAAQKfyYAAhUACAi3Iq4LAJECABUACAi3Iq4LAJECAAAA.',['伊利']='伊利蛋糕:BAAAKgAECgMIAwAAAA==.',['似雨']='似雨若雾:BAABKgAECn8YAAIIAAgIIyI8GQCzAgAIAAgIIyI8GQCzAgABKgAFFAgIBgAXAOACAA==.',['作死']='作死:BAAAKgAECggICQAAAA==.',['你说']='你说帅不帅:BAAAKgADCgUIBQAAAA==.',['做死']='做死:BAACKgAFFH8TAAIYAAcIYA37CQDEAAAYAAcIYA37CQDEAAAqAAQKfxsABBgACAj/GWQHAN8BABgABwhDG2QHAN8BAAoACAiCCldFAFYBABkAAQgBDLJkAD4AAAAA.做死大人:BAAAKgAECgQIBQAAAA==.',['偶尔']='偶尔非偶然:BAAAKgAECgQIBAAAAA==.',['傲天']='傲天雷冥飒:BAAAKgAECgYIBgAAAA==.',['光与']='光与暗之子:BAAAKgAFFAQIBAAAAA==.',['光榔']='光榔头:BAAAKgADCgYIBgAAAA==.',['兔儿']='兔儿兜:BAAAKgAECgQIBAAAAA==.',['六只']='六只小鸡:BAAAKgAFFAUIAQAAAA==.',['再诞']='再诞之翼:BAAAKgAECggICgAAAA==.',['农夫']='农夫三拳两脚:BAAAKgADCgEIAQAAAA==.',['冰凉']='冰凉:BAAAKgAFFAYIAwAAAA==.',['冰封']='冰封:BAAAKgADCgIIAgAAAA==.',['凌霜']='凌霜华:BAAAKgADCgMIAwAAAA==.',['凶灵']='凶灵再现:BAAAKgAFFAMIAwAAAA==.',['刑裁']='刑裁者:BAAAKgAECgUICQAAAA==.',['别奶']='别奶我让我死:BAABKgAFFH8IAAIaAAQI1RlZIADGAAAaAAQI1RlZIADGAAAAAA==.',['剑心']='剑心圣骑:BAABKgAFFH8GAAIIAAYISB4SEQDWAQAIAAYISB4SEQDWAQAAAA==.',['加你']='加你个头啊:BAAAKgAECgIIAgAAAA==.',['十字']='十字军凌叶:BAACKgAFFH8FAAIPAAIIpgOnJgBoAAAPAAIIpgOnJgBoAAAqAAQKfxoAAg8ABwhlDwsiAGUBAA8ABwhlDwsiAGUBAAAA.',['半只']='半只菜鸡:BAABKgAFFH8PAAIIAAgI7x+LBgBhAgAIAAgI7x+LBgBhAgAAAA==.',['半夜']='半夜惊叫唤:BAAAKgAECgMIAwAAAA==.',['卖油']='卖油郎:BAAAKgAECgYIDwAAAA==.',['卡德']='卡德减:BAACKgAFFH8IAAIBAAYIqxnrBAC4AQABAAYIqxnrBAC4AQAqAAQKfxQAAwMABwjmH0goANsBAAMABwjmH0goANsBAAEABQgkFIpkAOAAAAAA.',['去他']='去他码的圣光:BAAAKgAECgQIBAAAAA==.去他骂的奥丁:BAAAKgAFFAQIBAAAAA==.',['变形']='变形苏苏:BAABKgAFFH8IAAIEAAgIbAkBDADAAQAEAAgIbAkBDADAAQAAAA==.',['古明']='古明地丶觉:BAAAKgAECgcICgAAAA==.',['可可']='可可星冰乐:BAABKgAFFH8GAAIXAAYIEw+cEgANAQAXAAYIEw+cEgANAQAAAA==.',['听说']='听说奶萨很强:BAABKgAFFH8FAAIQAAMIPxtfEwDbAAAQAAMIPxtfEwDbAAAAAA==.',['听雨']='听雨落花丶:BAAAKgAECgIIAgABKgAFFAgIBgALAHQcAA==.',['吳下']='吳下阿蒙:BAAAKgAFFAQIBAAAAA==.',['呆僧']='呆僧:BAAAKgAFFAQIBAAAAA==.',['咕咕']='咕咕丶鸡:BAAAKgAECggICAAAAA==.',['哈根']='哈根大师:BAABKgAECn8eAAMbAAgIrxyGEgD4AQAbAAgIrxyGEgD4AQARAAEIAACWvQAAAAAAAA==.',['啦啦']='啦啦小魔仙:BAAAKgAECgEIAQAAAA==.',['喬治']='喬治阿瑪尼:BAAAKgAFFAcIBAAAAA==.',['喵弎']='喵弎菇凉:BAABKgAECn8wAAMDAAgItBh/CAAQAgADAAgItBh/CAAQAgABAAEIPwu6mgA5AAAAAA==.',['嘴炮']='嘴炮得:BAAAKgADCgIIAgAAAA==.',['噗噗']='噗噗宝宝:BAAAKgAECgMIBAAAAA==.',['圣光']='圣光照死你:BAAAKgAECggIDAAAAA==.圣光麦乐鸡:BAACKgAFFH8vAAIIAAcIOR6HGgCNAQAIAAcIOR6HGgCNAQAqAAQKf00AAggACAhIJaALAOQCAAgACAhIJaALAOQCAAAA.',['圣昭']='圣昭灵:BAABKgAFFH8JAAMIAAMIjw7QUgDKAAAIAAMIjw7QUgDKAAAJAAMIcQSuJABkAAAAAA==.',['坚定']='坚定最能混:BAAAKgAECgUIBQAAAA==.',['塞拉']='塞拉利昂:BAAAKgADCgEIAQAAAA==.',['塞林']='塞林木寄卖:BAABKgAFFH8MAAMRAAYIhBuFCQDAAQARAAYIbxuFCQDAAQAbAAYILBErDQBiAQAAAA==.',['大儿']='大儿童:BAAAKgADCggICAAAAA==.',['大白']='大白:BAAAKgAFFAIIAgAAAA==.',['大鎏']='大鎏特鎏:BAAAKgAFFAQIBAAAAA==.',['天堂']='天堂怒霸毙:BAAAKgAECgEIAQAAAA==.',['天恩']='天恩之父:BAAAKgAFFAYIAwABKgAFFAgICAAKALMSAA==.',['天河']='天河王嘉尔:BAAAKgAFFAYIAgABKgAFFAgIBAAcAAAAAA==.',['奥利']='奥利弗奎恩:BAACKgAFFH8QAAMRAAQIhRSiQAB4AAARAAIIfRSiQAB4AAAbAAIIlhR+WgBDAAAqAAQKfx4AAxEACAh+IYUZACwCABEABwh+IYUZACwCABsABAh+HzirAM4AAAAA.',['女子']='女子無財:BAAAKgAECggIDAAAAA==.',['奶牛']='奶牛鎏鎏:BAAAKgADCggICAAAAA==.',['好吃']='好吃不如饺子:BAAAKgAECggICAAAAA==.',['妇女']='妇女出虚汗:BAAAKgAECgcICgAAAA==.',['婵鸣']='婵鸣在呼唤:BAAAKgAECgIIAgAAAA==.',['嫂子']='嫂子我害怕啊:BAAAKgAECgYIBwAAAA==.',['宁静']='宁静灬至远:BAAAKgAECggIEQAAAA==.',['守夜']='守夜精灵:BAAAKgADCgcIBwAAAA==.',['安妮']='安妮莎莉娜:BAAAKgAECggICgAAAA==.',['安娜']='安娜卡列琳娜:BAAAKgAECgMIAwAAAA==.',['宝宝']='宝宝顶上:BAACKgAFFH8NAAIbAAMIywvNPACpAAAbAAMIywvNPACpAAAqAAQKfzkAAxsACAjVHbkZAGcCABsACAjVHbkZAGcCABEAAQjmBsCXABsAAAAA.',['密厮']='密厮:BAAAKgADCggICAAAAA==.',['寒慕']='寒慕雨:BAAAKgAECgYIBgAAAA==.',['寒溏']='寒溏渡剑影:BAAAKgAECgUICQAAAA==.',['小叮']='小叮当:BAAAKgAFFAYIAwAAAA==.',['小呆']='小呆:BAAAKgADCgQIBAAAAA==.',['小圆']='小圆仔:BAABKgAFFH8KAAMUAAYICBxmCQCVAQAUAAYICBxmCQCVAQAVAAEICQIwKAAsAAAAAA==.小圆崽:BAAAKgAFFAIIAgAAAA==.',['小小']='小小吼:BAABKgAFFH8eAAIKAAYIESMEAQDbAQAKAAYIESMEAQDbAQABKgAFFAgIBgAKABcZAA==.',['小巫']='小巫嘙:BAAAKgAECgIIAgAAAA==.',['小梨']='小梨香:BAAAKgAECgQICAAAAA==.',['小飞']='小飞姬樣:BAABKgAECn8VAAIRAAgI2CInCwCHAgARAAgI2CInCwCHAgABKgAFFAgICAAbABcdAA==.小飞盾来咯丶:BAAAKgAECgYIEAAAAA==.',['峰爱']='峰爱莹:BAABKgAFFH8FAAIdAAQInRY6FgBJAQAdAAQInRY6FgBJAQAAAA==.',['巫婆']='巫婆:BAABKgAFFH8GAAIHAAMIEAcQQgBkAAAHAAMIEAcQQgBkAAAAAA==.',['希爾']='希爾瓦娜斯:BAABKgAECn8oAAIRAAgIyRngIgDsAQARAAgIyRngIgDsAQABKgAFFAgICAAbABcdAA==.',['干涉']='干涉那个小德:BAABKgAFFH8JAAMJAAgIWQqvBwBEAQAJAAgINQevBwBEAQAIAAEIThjFTQBNAAAAAA==.',['幻觉']='幻觉:BAAAKgAECgIIBAAAAA==.',['张疯']='张疯子:BAAAKgAFFAgIBAAAAA==.',['往事']='往事:BAAAKgAFFAQIBAAAAA==.',['徐超']='徐超:BAAAKgAFFAIIAwAAAA==.',['得了']='得了赛赛:BAAAKgADCgMIAwAAAA==.',['得意']='得意忘形:BAAAKgAECgcIDQAAAA==.',['心之']='心之飞越:BAAAKgAECgcIDQAAAA==.',['心若']='心若猛虎:BAAAKgAECgYICwAAAA==.',['快乐']='快乐的灌注:BAABKgAFFH8VAAQLAAcI/BsSBgDMAQALAAcI/BsSBgDMAQAaAAYIIhlzCABcAQAMAAMI+hAgIgCbAAABKgAFFAgIBAAcAAAAAA==.',['恐惧']='恐惧兽魂:BAAAKgADCgQIBAAAAA==.恐惧脚步:BAAAKgAFFAEIAgAAAA==.',['悄悄']='悄悄问圣僧:BAAAKgAECggICAABKgAFFAgIBgAIAO8LAA==.',['悔意']='悔意灬思忆:BAAAKgAFFAQIBAAAAA==.',['悠哉']='悠哉悠哉:BAAAKgADCgcIBwAAAA==.',['惊风']='惊风火扯:BAAAKgADCggICAAAAA==.',['慕容']='慕容倾城:BAAAKgADCggICAAAAA==.慕容宝儿:BAAAKgADCgUICAAAAA==.',['慕沙']='慕沙:BAAAKgAECgQIBAAAAA==.',['懒得']='懒得起名:BAAAKgADCggICAAAAA==.',['我是']='我是大狐:BAAAKgAECgYIEgAAAA==.',['我爱']='我爱小龙虾:BAAAKgADCgIIAgAAAA==.',['我知']='我知道你很急:BAABKgAFFH8JAAMGAAUIMR0HBQApAQAGAAUIMR0HBQApAQAEAAQIRBsTNQDHAAABKgAFFAgIJQAOACEcAA==.',['战十']='战十八:BAABKgAECn8UAAIKAAgIbxxXGgD/AQAKAAgIbxxXGgD/AQAAAA==.',['扛不']='扛不住打扰了:BAABKgAFFH8GAAIeAAMIPBfmFAC+AAAeAAMIPBfmFAC+AAAAAA==.',['承天']='承天之佑:BAAAKgAFFAYIAwABKgAFFAgIDAAEAHMZAA==.',['抚慰']='抚慰你的心:BAAAKgADCggICAAAAA==.',['揍爆']='揍爆吴小狗:BAABKgAFFH8EAAIeAAQIqSQ9HAA8AQAeAAQIqSQ9HAA8AQAAAA==.',['搬山']='搬山道人:BAAAKgAECgYICAAAAA==.',['摩卡']='摩卡星冰乐:BAABKgAFFH8IAAMaAAQICxNKCwDbAAAaAAQIdA9KCwDbAAAMAAQISQxLEQDSAAAAAA==.',['摩尔']='摩尔迦娜:BAAAKgAECgQIBgAAAA==.',['断剑']='断剑红尘:BAAAKgAECgQICAAAAA==.',['新奥']='新奥尔良图腾:BAABKgAECn8bAAIQAAgIZRphHwANAgAQAAgIZRphHwANAgAAAA==.',['旋转']='旋转跳跃休息:BAABKgAFFH8GAAIfAAMILQMiEABfAAAfAAMILQMiEABfAAAAAA==.',['明羽']='明羽千夜:BAAAKgADCgMIAwAAAA==.',['星御']='星御:BAAAKgAFFAYIAwAAAA==.',['晓美']='晓美灬焰:BAAAKgAECggICQAAAA==.',['晴晴']='晴晴女王:BAAAKgADCgMIAwAAAA==.',['暗月']='暗月之蚀:BAAAKgAECgYIBwAAAA==.',['暗言']='暗言术:BAAAKgAFFAQIBAAAAA==.',['暴揍']='暴揍吴小狗:BAAAKgAECgYIBgAAAA==.',['曰上']='曰上三杆:BAAAKgADCggICAAAAA==.',['月叶']='月叶:BAAAKgAECgEIAQAAAA==.',['有心']='有心人无名仕:BAAAKgAECgUIBQAAAA==.',['有脾']='有脾气的麦麦:BAAAKgAECgQIBAAAAA==.',['板甲']='板甲三刹:BAAAKgAFFAQIBAAAAA==.',['果果']='果果的小巫婆:BAAAKgAFFAIIBAAAAA==.',['枫花']='枫花恋兮:BAAAKgAFFAYIBAABKgAFFAgIBAAcAAAAAA==.',['枼子']='枼子辰:BAAAKgAECgEIAQAAAA==.',['柊真']='柊真昼:BAAAKgAECgEIAQAAAA==.',['某球']='某球:BAAAKgAFFAMIAwAAAA==.',['柒琪']='柒琪:BAAAKgAECggICAAAAA==.',['柚子']='柚子夜:BAAAKgADCgEIAQAAAA==.',['柳从']='柳从芸:BAAAKgADCggICAAAAA==.',['栉川']='栉川鸠子:BAABKgAECn8UAAMQAAcI/hOmZgD4AAAQAAYIGhSmZgD4AAAgAAEI7ALCSwAdAAAAAA==.',['格罗']='格罗玛什:BAAAKgAFFAIIAgAAAA==.',['桔子']='桔子切啊切:BAABKgAFFH8PAAISAAYIAhHNAwByAQASAAYIAhHNAwByAQAAAA==.',['梅超']='梅超疯:BAAAKgADCgMIAwAAAA==.',['棂羽']='棂羽衣:BAABKgAFFH8OAAIDAAMItRnjCQDcAAADAAMItRnjCQDcAAAAAA==.',['欧皇']='欧皇毛小妹:BAAAKgAFFAYIBAAAAA==.',['歌手']='歌手奈琪:BAAAKgADCggIEgAAAA==.',['正义']='正义的地球人:BAABKgAFFH8GAAIIAAYI7wvRLgAtAQAIAAYI7wvRLgAtAQAAAA==.',['武器']='武器魄电脑:BAAAKgAECgQIBQAAAA==.',['死球']='死球:BAAAKgAECgUIBgAAAA==.',['毒蝎']='毒蝎:BAAAKgAECgQIBAAAAA==.',['水元']='水元素:BAAAKgAFFAgIAwAAAA==.',['水哥']='水哥牛:BAAAKgAFFAQIAwAAAA==.',['水痘']='水痘崽:BAAAKgAECgEIAQAAAA==.',['沁凉']='沁凉:BAAAKgAECgIIAgAAAA==.沁凉丶:BAAAKgAFFAgIAwAAAA==.',['没名']='没名字就好了:BAAAKgAECgQIBAAAAA==.',['泰神']='泰神二:BAAAKgADCgEIAQAAAA==.',['洒家']='洒家插图疼:BAAAKgAECgIIAgAAAA==.',['流年']='流年碎容颜丶:BAAAKgAECggIEAABKgAFFAgIDgAJAHMWAA==.',['淡定']='淡定:BAAAKgAFFAMIAwAAAA==.',['清风']='清风扶醉月:BAAAKgADCggICAAAAA==.',['源神']='源神:BAABKgAECn8qAAMDAAgIuh21FABZAgADAAgIuh21FABZAgABAAIIxQQlogArAAAAAA==.',['灬繁']='灬繁华落尽丶:BAAAKgAFFAgIBAAAAA==.',['灵笼']='灵笼:BAACKgAFFH8dAAISAAUIbhjzFwAHAQASAAUIbhjzFwAHAQAqAAQKfxsAAxIACAhXG1EWAAsCABIACAhXG1EWAAsCACEABQhhBWAeAIgAAAAA.',['灵长']='灵长类杀手:BAAAKgAFFAgIBAAAAA==.',['無敌']='無敌晓眼睛:BAABKgAFFH8UAAQDAAYI5yMqAwDbAQADAAYIeCAqAwDbAQACAAYIphp0CwCxAQABAAQIyiUhCwBHAQABKgAFFAgIFgAHAOgSAA==.',['爪妹']='爪妹酱酱:BAAAKgAECgYICgAAAA==.爪妹醬:BAACKgAFFH8pAAIbAAcI3hRuFABSAQAbAAcI3hRuFABSAQAqAAQKfz4AAhsACAhqIO0SAJICABsACAhqIO0SAJICAAAA.',['爱音']='爱音:BAAAKgAECgUIBQAAAA==.',['牛脆']='牛脆脆:BAABKgAFFH8SAAIPAAYILyI2CADlAQAPAAYILyI2CADlAQAAAA==.',['牧流']='牧流冰:BAABKgAFFH8IAAQaAAYIqxlTFAAQAQAaAAUI+hdTFAAQAQAMAAII3x/SEQDOAAALAAEIVxSfKgBIAAAAAA==.',['物丸']='物丸大队长:BAABKgAFFH8lAAMIAAMIzBUcIgDeAAAIAAMIzBUcIgDeAAAJAAMI7gvJHgCGAAABKgAFFAgIIwAKAKobAA==.物丸小混范:BAABKgAFFH8lAAMdAAMIFxSeFgDVAAAdAAMIFxSeFgDVAAAfAAMIvQVwDQCBAAABKgAFFAgIIwAKAKobAA==.物丸小混飯:BAACKgAFFH8eAAMFAAQIjRN+CACFAAAEAAMIjRMlGgDWAAAFAAQIug1+CACFAAAqAAQKfx0ABAUACAgjDcUTABQBAAUACAjzC8UTABQBAAYAAgg/D6trAHMAAAQAAgh/C/mqAG4AAAEqAAUUCAgjAAoAqhsA.物丸小混饭:BAACKgAFFH8jAAMKAAQIqhvrDgD/AAAKAAQIqhvrDgD/AAAYAAMI/gdzEAB6AAAqAAQKfxsAAwoACAhrGc0kAP4BAAoACAhrGc0kAP4BABgABAhIDAY1AJcAAAAA.物丸小炒饼:BAAAKgAFFAYIAgAAAA==.物丸桃桃酱:BAABKgAECn8VAAIaAAgIyRUYJQC/AQAaAAgIyRUYJQC/AQAAAA==.',['犀利']='犀利妹:BAAAKgAECgIIAgAAAA==.',['犬来']='犬来八荒:BAAAKgAFFAQIAwABKgAFFAgICwASAEYiAA==.',['狂球']='狂球:BAAAKgADCgEIAQAAAA==.',['狂野']='狂野的大蜂子:BAAAKgAFFAIIAgAAAA==.',['狄安']='狄安娜:BAAAKgAECggICAAAAA==.',['狐撸']='狐撸娃:BAAAKgAFFAgIBAAAAA==.',['狐狸']='狐狸棒棒:BAAAKgAECgUIBQAAAA==.狐狸镜子:BAABKgAFFH8nAAMRAAMIoBRkKQDEAAARAAMIoBRkKQDEAAAbAAMIkQl0PwCgAAABKgAFFAgIIwAKAKobAA==.',['猎杀']='猎杀麦乐鸡:BAACKgAFFH8TAAMbAAUIsRqzIgD/AAAbAAUIsRqzIgD/AAARAAMIgwpxRQBpAAAqAAQKfxgAAxsACAh1IO0UAIUCABsABwh1IO0UAIUCABEABgj1Dt5GAAMBAAAA.',['玛里']='玛里奥:BAABKgAFFH8FAAIGAAMI4BJZDQC1AAAGAAMI4BJZDQC1AAAAAA==.',['琪琪']='琪琪丶:BAAAKgAECggICAAAAA==.',['琼妍']='琼妍:BAAAKgAECggIDAAAAA==.',['生杀']='生杀予夺:BAACKgAFFH8cAAMPAAgIuxjLAgCVAQAPAAgIuxjLAgCVAQAiAAMInhlIBwD2AAAqAAQKfxsAAyIACAghISQLADYCACIACAhJHyQLADYCAA8ABAivGbU4AJYAAAAA.',['疯狂']='疯狂星期四:BAAAKgADCgEIAQAAAA==.',['瘦僧']='瘦僧:BAAAKgAECgYIBgAAAA==.',['白与']='白与黑:BAABKgAECn8VAAIeAAgI1hk5CgDnAQAeAAgI1hk5CgDnAQAAAA==.',['百隐']='百隐之鬼:BAAAKgAFFAQIBAAAAA==.',['目中']='目中无人:BAAAKgAECgEIAQAAAA==.',['瞌睡']='瞌睡箭魔:BAABKgAFFH8OAAMRAAgIARZaBQAPAgARAAgIkRRaBQAPAgAbAAYI/RBOFwA/AQAAAA==.',['破晓']='破晓晨曦:BAABKgAFFH8IAAIJAAYIzBFBCAAwAQAJAAYIzBFBCAAwAQABKgAFFAgIGQAIAP8eAA==.',['神人']='神人梅西:BAACKgAFFH8TAAQiAAQIjCDcAgAJAQAiAAQIjCDcAgAJAQAjAAMIKhvJBADRAAAPAAMIbhz4FQB6AAAqAAQKfywABCIACAgSI90CADUCACIACAhkIN0CADUCACMACAgCIa4HANABAA8AAgihDfRHAEAAAAAA.',['神圣']='神圣的番茄:BAAAKgAECgMIAwAAAA==.',['神棍']='神棍法:BAAAKgAFFAQIBAAAAA==.',['祥瑞']='祥瑞狸:BAAAKgAECggICgAAAA==.',['秀忠']='秀忠:BAAAKgAECggICwAAAA==.',['秀念']='秀念:BAABKgAFFH8IAAIdAAgIhheRBgA+AgAdAAgIhheRBgA+AgAAAA==.',['秀真']='秀真:BAAAKgAECgMIAwAAAA==.',['秦筠']='秦筠:BAAAKgADCggICAAAAA==.',['程灵']='程灵素:BAAAKgAFFAYIBAABKgAFFAgIBAAcAAAAAA==.',['笑笑']='笑笑西风忘:BAAAKgADCgIIAgAAAA==.',['等我']='等我读个条:BAAAKgADCggICAAAAA==.',['糖果']='糖果丶呆猎:BAAAKgAECgcICAAAAA==.',['索兰']='索兰皇冠骑士:BAAAKgAECgYICAAAAA==.',['紫殇']='紫殇:BAAAKgAFFAYIBAAAAA==.',['紫潇']='紫潇:BAACKgAFFH8HAAIIAAMIAwZMNwCDAAAIAAMIAwZMNwCDAAAqAAQKfx0AAwgACAh1Go5PAM8BAAgACAjaF45PAM8BAAkABghiC/wUAMEAAAAA.',['紫黯']='紫黯幽煞:BAAAKgAECgMIAwAAAA==.',['红中']='红中老大:BAAAKgAECgYIBgAAAA==.',['红手']='红手阿风:BAAAKgAECggICAAAAA==.',['纯情']='纯情小火鸡:BAABKgAFFH8FAAIZAAMIFxG2CwDUAAAZAAMIFxG2CwDUAAAAAA==.纯情火鸡:BAAAKgAFFAEIAQABKgAFFAMIBQAZABcRAA==.',['纯甄']='纯甄土哥:BAAAKgAECgcIEwAAAA==.',['纷乱']='纷乱雪月花:BAAAKgAECggIDAAAAA==.',['终极']='终极节拍:BAAAKgAFFAgIBAAAAA==.',['维型']='维型生物:BAAAKgAFFAMIAwAAAA==.',['美树']='美树沙耶香:BAAAKgAECgYIBgAAAA==.',['羽星']='羽星辉:BAAAKgADCggICAAAAA==.',['羽霍']='羽霍飞:BAAAKgAECgQIBAAAAA==.',['老拳']='老拳拳碎胸口:BAABKgAFFH8GAAIUAAUITw+yEwAKAQAUAAUITw+yEwAKAQAAAA==.',['耶路']='耶路撒冷:BAACKgAFFH8JAAIQAAMIZB53IwDqAAAQAAMIZB53IwDqAAAqAAQKfxcAAhAACAh/GH42AKwBABAACAh/GH42AKwBAAAA.',['聋的']='聋的传人:BAAAKgAFFAgIBAAAAA==.',['肉嘟']='肉嘟嘟小烧麦:BAABKgAFFH8HAAIQAAcI9g2wDQBzAQAQAAcI9g2wDQBzAQABKgAFFAgIBgAQADwFAA==.',['胆囊']='胆囊炎:BAABKgAFFH8LAAISAAgIRiKfAgCsAgASAAgIRiKfAgCsAgAAAA==.',['胭脂']='胭脂虫:BAAAKgAECgIIAgAAAA==.',['脚趾']='脚趾很性感:BAAAKgAECggICAAAAA==.',['自动']='自动发电机:BAAAKgAECggICAAAAA==.',['自摸']='自摸乱风向:BAAAKgADCggICAAAAA==.',['致盲']='致盲:BAABKgAFFH8KAAIPAAYIDB97CwCUAQAPAAYIDB97CwCUAQAAAA==.',['艾加']='艾加:BAABKgAFFH8QAAMQAAgIMRXpBAALAgAQAAcIbBjpBAALAgAkAAMIVxx2DAAKAQAAAA==.',['艾希']='艾希:BAABKgAFFH8JAAIRAAMIGglMGwCQAAARAAMIGglMGwCQAAAAAA==.',['花小']='花小奶:BAAAKgADCggICAAAAA==.',['苏州']='苏州白便:BAAAKgAECgYIEAAAAA==.',['苏梓']='苏梓桧:BAAAKgADCgIIAgAAAA==.',['苏苏']='苏苏:BAAAKgAECgMIAwAAAA==.苏苏老师:BAAAKgAFFAgIBAAAAA==.',['苏非']='苏非玛索:BAAAKgAECgcIBwAAAA==.',['茅场']='茅场晶彦:BAABKgAFFH8GAAIIAAYIsxnuHQB6AQAIAAYIsxnuHQB6AQAAAA==.',['茉莉']='茉莉奶绿:BAAAKgAECgEIAQAAAA==.',['萌萌']='萌萌猫:BAAAKgAECgcIAgAAAA==.',['萝卜']='萝卜切啊切:BAAAKgAECggICwAAAA==.',['萨妃']='萨妃洛斯:BAAAKgAECgYIDAAAAA==.',['萨拉']='萨拉洛佩兹:BAABKgAFFH8GAAMRAAMIXwR2IABrAAARAAMIXwR2IABrAAAbAAEIBAZKYAA1AAAAAA==.',['萨鲁']='萨鲁法爾大王:BAAAKgAECgcIBwABKgAFFAgIIAAXAFUQAA==.',['葉子']='葉子辰丶:BAAAKgAECgcIDQAAAA==.',['蕾欧']='蕾欧娜:BAACKgAFFH8QAAIIAAgIpRj0JQBRAQAIAAgIpRj0JQBRAQAqAAQKfxcAAggACAiTIbUqAFUCAAgACAiTIbUqAFUCAAAA.',['虎之']='虎之咆哮:BAAAKgAECgYIBgAAAA==.虎之骑士:BAAAKgAECggIEQAAAA==.',['虚锤']='虚锤子方丈:BAAAKgAECggIDQAAAA==.',['蛋糕']='蛋糕切啊切:BAAAKgAFFAMIAwABKgAFFAgIDgAHAPkhAA==.',['血腥']='血腥一点:BAAAKgADCggIDAAAAA==.',['血鬼']='血鬼狂人:BAACKgAFFH8dAAMIAAgIhCVnAgC+AQAIAAYIFyVnAgC+AQAJAAIIlSYjEwDiAAAqAAQKfyAAAggACAiSJmQIAPoCAAgACAiSJmQIAPoCAAAA.',['被遗']='被遗忘的九九:BAAAKgAECggIDgAAAA==.',['西尔']='西尔瓦娜斯:BAAAKgAFFAYIBAAAAA==.',['西格']='西格玛男银丶:BAAAKgAFFAEIAQAAAA==.',['西瓜']='西瓜癫掉:BAAAKgAFFAYIBAAAAA==.',['詸罗']='詸罗:BAAAKgAECgQIBwAAAA==.',['计划']='计划复古:BAAAKgAECgIIAgAAAA==.',['超想']='超想养只猫:BAAAKgAFFAIIAgABKgAFFAgIBAAcAAAAAA==.',['身高']='身高一米八:BAABKgAFFH8WAAIIAAYI/SDuDgDrAQAIAAYI/SDuDgDrAQAAAA==.',['达光']='达光贵人:BAABKgAFFH8IAAMIAAQIxiBOEwAJAQAIAAMIxiBOEwAJAQAJAAQIcAZgIwBrAAAAAA==.',['远征']='远征意志:BAABKgAFFH8GAAIbAAMIhRr0KQDdAAAbAAMIhRr0KQDdAAABKgAFFAgIBAAcAAAAAA==.',['迷失']='迷失的辛多雷:BAAAKgAFFAYIBAAAAA==.',['迷茫']='迷茫雾色:BAAAKgADCgIIAgAAAA==.',['重生']='重生我是毒奶:BAAAKgAECggICQAAAA==.',['铁扇']='铁扇:BAAAKgAECgIIAgAAAA==.',['银剑']='银剑不能移:BAAAKgAECgIIAQAAAA==.',['门捷']='门捷猎夫:BAAAKgAECgUIBQAAAA==.',['闹闹']='闹闹大神:BAAAKgADCggIEQAAAA==.',['阿比']='阿比达:BAAAKgADCgEIAQAAAA==.',['阿爾']='阿爾薩斯:BAABKgAFFH8GAAIeAAYIGxEjFQByAQAeAAYIGxEjFQByAQAAAA==.',['阿言']='阿言超灵的:BAABKgAFFH8GAAIHAAYIiAeWHQAbAQAHAAYIiAeWHQAbAQAAAA==.',['阿阿']='阿阿吾阮丫:BAAAKgAFFAgIBAAAAA==.',['陈平']='陈平安:BAAAKgAECggIDgAAAA==.',['陌生']='陌生:BAABKgAFFH8GAAIIAAYI6g+vJQBSAQAIAAYI6g+vJQBSAQAAAA==.',['隔壁']='隔壁表姐丿:BAAAKgAECgcICQAAAA==.',['难等']='难等佛举:BAAAKgAECgYIBgAAAA==.',['雪娜']='雪娜蕊斯:BAABKgAFFH88AAMaAAgIgCDTAQB6AgAaAAgIgCDTAQB6AgALAAIIXg9nGACgAAAAAA==.',['雷电']='雷电飘毛飞扬:BAAAKgAECgIIAgAAAA==.',['雷霆']='雷霆老怒:BAAAKgAFFAQIBAAAAA==.',['青岛']='青岛爱纯生:BAAAKgAFFAQIBAAAAA==.',['顾异']='顾异的:BAAAKgAFFAYIAgAAAA==.',['风之']='风之风:BAAAKgAECgcIBwAAAA==.',['风前']='风前絮:BAAAKgAECgQIBAABKgAFFAYIGwASAJAmAA==.',['风向']='风向决定发型:BAAAKgAECggICAAAAA==.',['风斩']='风斩冰华:BAAAKgAECgcIDQAAAA==.',['风起']='风起荧荧:BAAAKgADCgEIAQAAAA==.',['飞翔']='飞翔的猪:BAAAKgAFFAgIBAAAAA==.',['香香']='香香熊:BAAAKgAECggICAAAAA==.',['驱魔']='驱魔龙族:BAABKgAECn8UAAIKAAgIsheVDADVAQAKAAgIsheVDADVAQAAAA==.',['骇人']='骇人鲸:BAABKgAFFH8MAAMLAAYIQx2YAQDWAQALAAYIQx2YAQDWAQAaAAUIFA6YHQDVAAAAAA==.',['鬼拳']='鬼拳:BAABKgAFFH8cAAMVAAgIqR8bAgCyAQAVAAgIQR0bAgCyAQAWAAYIhhTUAABHAQAAAA==.',['鱼来']='鱼来佛举:BAAAKgAECgQIBAAAAA==.',['黑旋']='黑旋风武松:BAAAKgAFFAIIAQAAAA==.',['黑海']='黑海岸以东:BAABKgAFFH8HAAQFAAYIug3xCQBxAAAFAAQIGw3xCQBxAAAGAAIIqQZPLwBbAAAEAAEIZxV2VwBWAAAAAA==.',['黯影']='黯影谜踪:BAABKgAFFH8KAAIUAAQIhRW+EwDUAAAUAAQIhRW+EwDUAAAAAA==.',['龙人']='龙人族统领:BAAAKgAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end