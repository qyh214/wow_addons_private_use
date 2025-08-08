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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Rogue-Subtlety','Rogue-Assassination','Druid-Restoration','Warrior-Fury','Mage-Arcane','Mage-Frost','Warrior-Arms','Priest-Shadow','Priest-Discipline','Priest-Holy','Paladin-Holy','Paladin-Retribution','Paladin-Protection','Monk-Mistweaver','Monk-Brewmaster','DemonHunter-Vengeance','Warrior-Protection','DeathKnight-Unholy','Monk-Windwalker','Druid-Balance','Mage-Fire','Hunter-Marksmanship','Shaman-Restoration','Shaman-Enhancement','DeathKnight-Blood','Druid-Feral','Hunter-BeastMastery','DeathKnight-Frost','Unknown-Unknown','Druid-Guardian','DemonHunter-Havoc','Warlock-Affliction','Evoker-Devastation','Evoker-Preservation','Shaman-Elemental','Hunter-Survival','DeathKnight-Melee',}; local provider = {region='CN',realm='巴瑟拉斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Airr:BAAAKgADCggICAAAAA==.',Am='Ame:BAAAKgAECgIIAgAAAA==.',Aq='Aqua:BAAAKgAECgMIAwAAAA==.',At='Atrwicked:BAAAKgAFFAMIAgAAAA==.',Bi='Bingoo:BAAAKgAECggICwAAAA==.',Da='Daviding:BAAAKgADCggICAAAAA==.',De='Desolate:BAABKgAECn8cAAMBAAgI/SArGAAyAgABAAgIqh0rGAAyAgACAAIIIhi8agBlAAAAAA==.',Do='Doppelganger:BAAAKgADCgIIAgAAAA==.',Fe='Fear:BAAAKgAFFAUIAQAAAA==.',Go='Goulding:BAAAKgADCgIIAgAAAA==.',Ju='Jubileus:BAAAKgAECgMIBAAAAA==.',La='Laminaria:BAAAKgADCgEIAQAAAA==.Latonia:BAAAKgAFFAYIBAAAAA==.',Ll='Llfan:BAAAKgADCgEIAQAAAA==.',Mi='Michelangêlo:BAABKgAFFH8GAAMDAAQIaA/EBwDxAAADAAQIXg/EBwDxAAAEAAIIZgYaKgA5AAAAAA==.',Mo='Mom:BAAAKgAFFAQIBAAAAA==.',Pa='Patent:BAAAKgAFFAMIAwAAAA==.',Qw='Qweasdzc:BAABKgAFFH8IAAIFAAgIBwehCAB+AQAFAAgIBwehCAB+AQAAAA==.',Ra='Rainning:BAACKgAFFH8SAAIGAAUIYxQNFQDgAAAGAAUIYxQNFQDgAAAqAAQKfxYAAgYACAirGRMiAA4CAAYACAirGRMiAA4CAAAA.',Sh='Shawnmendes:BAAAKgAFFAMIAwAAAA==.',Sw='Sweelbbnmb:BAAAKgAFFAIIBAAAAA==.',Tb='Tbagox:BAABKgAFFH8KAAMEAAYIMBGWDACEAQAEAAYIMBGWDACEAQADAAQI/wh3BQCtAAAAAA==.',Ti='Timothyh:BAAAKgAECgYIDAAAAA==.',Tj='Tjjtdsa:BAAAKgAECgMIAwAAAA==.',Vi='Vivisky:BAABKgAFFH8IAAMHAAII8wpVOwB0AAAHAAII8wpVOwB0AAAIAAIIfwZFJwBaAAAAAA==.',['一剑']='一剑顷城:BAAAKgAECgYIBgAAAA==.',['一只']='一只狸狸离:BAAAKgAECgEIAQAAAA==.',['一往']='一往情深:BAAAKgADCggICAAAAA==.',['一怒']='一怒冲天:BAAAKgAECggIEwAAAA==.',['一直']='一直爱睿恩:BAAAKgADCgUIBQAAAA==.',['一箭']='一箭万血:BAAAKgAFFAMIAwAAAA==.',['上善']='上善若水:BAAAKgAECgcIBwAAAA==.',['不了']='不了好:BAABKgAFFH8IAAIJAAgIIhCnAwAcAgAJAAgIIhCnAwAcAgAAAA==.',['不加']='不加糖:BAACKgAFFH8OAAMKAAYINxrgAgCpAQAKAAYINxrgAgCpAQALAAUI6xYaBABWAQAqAAQKfxwAAwsACAghIrALAHQCAAsACAhpILALAHQCAAwACAgeHco2AGMBAAAA.',['不睡']='不睡觉的熠:BAACKgAFFH8LAAQNAAUIMxJ5CAAkAQANAAUIMxJ5CAAkAQAOAAMIJAlLZQCkAAAPAAEI5grQKwAxAAAqAAQKfxUAAw0ACAhqHVAmACwBAA0ABgisHFAmACwBAA4ABQg2GFOiAAkBAAAA.',['不落']='不落妖精:BAAAKgADCggIEAAAAA==.',['世界']='世界的尽头黑:BAAAKgAECgYIBgAAAA==.',['东古']='东古诺:BAABKgAFFH8MAAMQAAgIyA3CBgDUAQAQAAgIyA3CBgDUAQARAAII0xksBgCHAAAAAA==.',['丶厨']='丶厨子:BAABKgAECn8WAAISAAgIZxz9FQDjAQASAAgIZxz9FQDjAQAAAA==.',['丶小']='丶小饼干:BAABKgAFFH8GAAITAAYINg1RAQBHAQATAAYINg1RAQBHAQAAAA==.',['丶诺']='丶诺诺:BAAAKgADCgEIAQAAAA==.',['丷麦']='丷麦辣鸡腿堡:BAAAKgAECgMIBgAAAA==.',['丹儿']='丹儿:BAAAKgADCgcIBwAAAA==.',['举火']='举火烧天:BAAAKgAFFAMIAwAAAA==.',['乂魂']='乂魂之挽歌乂:BAAAKgAECgYIDQAAAA==.',['乇從']='乇從妗以後乇:BAAAKgAECgEIAQAAAA==.',['么看']='么看来:BAAAKgADCggICAAAAA==.',['乐多']='乐多:BAAAKgAECgYICgAAAA==.乐多熊:BAAAKgAECggIDQAAAA==.',['乐游']='乐游刘:BAAAKgAECgQIBAAAAA==.',['乐莲']='乐莲:BAAAKgADCggIEAAAAA==.',['九尺']='九尺鹅肠:BAABKgAFFH8MAAIOAAgIQxqrDgAZAQAOAAgIQxqrDgAZAQAAAA==.',['二爺']='二爺要上岗:BAACKgAFFH8FAAIOAAMIkhEbRgDiAAAOAAMIkhEbRgDiAAAqAAQKfzYAAg4ACAgSJDEHAMgCAA4ACAgSJDEHAMgCAAAA.',['二釢']='二釢要转正:BAAAKgAECgMIBAAAAA==.',['五岁']='五岁半:BAAAKgAECgUIDwAAAA==.',['五条']='五条悟:BAAAKgAECgEIAQAAAA==.',['交幻']='交幻機:BAAAKgAECggIBgAAAA==.',['人被']='人被杀就会死:BAAAKgADCggIEAAAAA==.',['从未']='从未如此哀伤:BAAAKgADCggICAAAAA==.',['他只']='他只是男闺蜜:BAABKgAFFH8KAAIRAAYISheEAgDrAAARAAYISheEAgDrAAAAAA==.',['他说']='他说我不抗:BAABKgAFFH8IAAIUAAgIlAUUCgCCAQAUAAgIlAUUCgCCAQAAAA==.',['仰望']='仰望天空:BAAAKgAFFAQIBAAAAA==.',['伊利']='伊利逹泪酸奶:BAAAKgADCggICAAAAA==.',['伊歌']='伊歌利特:BAAAKgAECgEIAQAAAA==.',['休闲']='休闲呆呆:BAAAKgADCgQIBQAAAA==.休闲宝宝:BAABKgAECn8dAAMVAAgIaiDMDACGAgAVAAgIaiDMDACGAgAQAAIIlAtOhwBIAAAAAA==.',['似画']='似画:BAAAKgAECgEIAQAAAA==.',['你们']='你们不懂胖虎:BAAAKgAFFAIIBAAAAA==.',['你跺']='你跺你也麻:BAACKgAFFH8JAAMQAAMIrgiqJQCNAAAQAAMIrgiqJQCNAAAVAAIIfwT7JQA3AAAqAAQKfyIAAxAACAjOG7EWADMCABAACAjOG7EWADMCABUABghaGoAlAHUBAAAA.',['佬男']='佬男孩儿:BAAAKgADCggICAAAAA==.',['依赖']='依赖:BAAAKgAECgEIAgAAAA==.',['保济']='保济丸:BAAAKgAECggIDgAAAA==.',['修纙']='修纙道:BAACKgAFFH8FAAICAAIISRIDCwCWAAACAAIISRIDCwCWAAAqAAQKfxgAAgIABwjiHN0LAH8BAAIABwjiHN0LAH8BAAAA.',['偶原']='偶原来不帅:BAACKgAFFH8GAAMWAAUIXBNpKwDlAAAWAAMIfhhpKwDlAAAFAAIIqAd5JwCIAAAqAAQKfxoAAxYACAi7F4UsAA0CABYACAi7F4UsAA0CAAUABghWFNw3AAoBAAAA.',['偷死']='偷死不偿命:BAAAKgADCgUIBQAAAA==.',['光明']='光明正大:BAAAKgADCggICAAAAA==.光明背后:BAAAKgADCgQIBAAAAA==.',['八十']='八十一锤:BAAAKgAECgEIAQAAAA==.',['八级']='八级小狂風:BAABKgAFFH8wAAIPAAgIdhnwAwAkAgAPAAgIdhnwAwAkAgAAAA==.',['公正']='公正公平公开:BAAAKgAECgYIBgAAAA==.',['兰博']='兰博基尼喵:BAAAKgADCgIIAgAAAA==.兰博貓:BAAAKgAECgEIAgAAAA==.',['养乐']='养乐多哟:BAAAKgADCggICAAAAA==.',['军团']='军团法神:BAAAKgAECgIIAgAAAA==.',['冰天']='冰天动地:BAAAKgAECgIIAgAAAA==.',['冰封']='冰封无限:BAAAKgAECgMIBQAAAA==.',['冰爽']='冰爽:BAAAKgADCggICgAAAA==.',['冲鸭']='冲鸭:BAAAKgAECggICAAAAA==.',['凯西']='凯西:BAAAKgAECgQIBAAAAA==.',['刘三']='刘三爷:BAAAKgAECgEIAQAAAA==.',['勇气']='勇气之手:BAAAKgAECggICQAAAA==.',['千里']='千里不留行:BAAAKgADCgMIAwAAAA==.',['卓耿']='卓耿:BAAAKgAFFAQIAgAAAA==.',['南玻']='南玻斯瑞:BAAAKgAECgQIBAAAAA==.',['卜弋']='卜弋丶天使:BAAAKgAECgcICAAAAA==.',['卡伽']='卡伽斯血吼:BAAAKgADCggICQAAAA==.',['卡尔']='卡尔王:BAABKgAFFH8GAAIXAAYIVRagDQBgAQAXAAYIVRagDQBgAQAAAA==.',['卡斯']='卡斯特洛:BAAAKgADCgIIAgAAAA==.',['卡特']='卡特洛斯:BAAAKgAECgIIAgAAAA==.',['历飞']='历飞雨:BAAAKgADCggICAAAAA==.',['原原']='原原橘橘子:BAAAKgADCggICQAAAA==.',['双全']='双全法:BAABKgAFFH8OAAIIAAMIlhzLDgDsAAAIAAMIlhzLDgDsAAAAAA==.',['双杠']='双杠双飘:BAABKgAFFH8IAAIYAAgIMA+3CwCbAQAYAAgIMA+3CwCbAQAAAA==.',['叫妈']='叫妈妈:BAAAKgAECgcIBwAAAA==.',['司梦']='司梦:BAAAKgAECgIIAgAAAA==.',['吕奉']='吕奉先:BAAAKgAFFAMIAwAAAA==.',['吕小']='吕小战:BAAAKgADCgEIAQAAAA==.',['吾辈']='吾辈武僧战:BAABKgAFFH8EAAIQAAQIqw9HHwCpAAAQAAQIqw9HHwCpAAAAAA==.',['呀呀']='呀呀嘿:BAAAKgAECgYICgAAAA==.',['咆哮']='咆哮:BAAAKgAECgEIAQAAAA==.',['咕咕']='咕咕复咕咕:BAAAKgAECgcIEAAAAA==.',['咖啡']='咖啡丶那么苦:BAACKgAFFH8FAAIZAAIINQzdJABbAAAZAAIINQzdJABbAAAqAAQKfxgAAxoACAiDElwrAGgBABoACAiDElwrAGgBABkABwgBD99pAAMBAAAA.',['哎呀']='哎呀灬蛇:BAABKgAFFH8LAAMbAAgIuxPIBACfAQAbAAgI0g7IBACfAQAUAAMImBbHDwD6AAAAAA==.',['哞哞']='哞哞断角:BAAAKgAFFAMIBAAAAA==.',['唯爱']='唯爱天使:BAAAKgADCggICAAAAA==.',['啤酒']='啤酒与龙虾:BAAAKgAECgcIDgAAAA==.',['善解']='善解人铱:BAABKgAFFH8IAAIcAAgIigdRAQDhAQAcAAgIigdRAQDhAQAAAA==.',['嗜血']='嗜血护术宝:BAACKgAFFH8aAAMBAAUIaRaGEgAIAQABAAUIaRaGEgAIAQACAAIIuwXSGAA3AAAqAAQKfxQAAwEACAg5GPkfAP8AAAEACAgBFvkfAP8AAAIAAwiFEw9eAH4AAAAA.',['嘈霓']='嘈霓玛麻:BAAAKgADCggICAAAAA==.',['四夕']='四夕女青文:BAAAKgAFFAIIAgAAAA==.',['回到']='回到丶过去:BAAAKgAECgYIBgAAAA==.',['回香']='回香豆:BAAAKgADCgEIAQAAAA==.',['团团']='团团子:BAAAKgAECggICAAAAA==.',['团座']='团座喝咖啡:BAAAKgADCggICAAAAA==.',['图拉']='图拉羊:BAAAKgADCggICAAAAA==.',['圣光']='圣光熊熊:BAAAKgAECggIDgAAAA==.圣光魅影:BAAAKgADCgIIAgAAAA==.',['圣奶']='圣奶士:BAAAKgAECgcIDgAAAA==.',['圣殿']='圣殿骑士:BAAAKgAECggICAAAAA==.',['圣血']='圣血恶魔:BAAAKgAECgcICgAAAA==.',['地心']='地心骑士:BAAAKgAECgEIAgAAAA==.',['坏男']='坏男人之冷:BAAAKgAFFAIIAwAAAA==.',['堕落']='堕落圣光:BAAAKgADCgYIBgAAAA==.堕落天涯:BAAAKgAECgIIAgAAAA==.',['塔邀']='塔邀尼斯阿卡:BAAAKgAFFAQIBAAAAA==.',['墨灵']='墨灵:BAAAKgAECgEIAQAAAA==.',['墨瞳']='墨瞳丶嘿嘿:BAAAKgAECgMIBgAAAA==.',['壹楪']='壹楪知秋:BAAAKgAECgYIDgAAAA==.',['复往']='复往昔:BAAAKgAECgQIBAAAAA==.',['夏雨']='夏雨的宁静:BAAAKgAECgYIDQAAAA==.',['多肉']='多肉梨花喵:BAAAKgAECgQIBAAAAA==.',['大丿']='大丿圣牛:BAABKgAFFH8KAAMNAAYIkBHdBQA2AQANAAYIkBHdBQA2AQAOAAQIORcsHADyAAAAAA==.',['大哒']='大哒棒棒糖:BAAAKgADCgQIBAAAAA==.',['大尾']='大尾巴狼:BAAAKgAECgcICwAAAA==.',['大敕']='大敕令使:BAAAKgADCgQIBAAAAA==.',['大甜']='大甜梨:BAAAKgAECgYIBgAAAA==.',['天权']='天权:BAAAKgAFFAIIAgAAAA==.',['天枢']='天枢:BAAAKgAECggICAAAAA==.',['天琁']='天琁:BAAAKgAECgMIBQAAAA==.',['天空']='天空的引路人:BAABKgAFFH8GAAIXAAYITCIPHwDZAAAXAAYITCIPHwDZAAAAAA==.',['奥尔']='奥尔什方:BAAAKgADCggICgAAAA==.',['女侠']='女侠笑春春:BAAAKgADCgIIAgAAAA==.',['女王']='女王驾到:BAABKgAECn8iAAMdAAcICyHFJwAUAgAdAAcICyHFJwAUAgAYAAQIWxsuTADsAAAAAA==.',['好名']='好名字都没啦:BAAAKgAECgYIBgAAAA==.',['妈个']='妈个牛佬:BAABKgAECn8eAAIGAAcIKiDxFgAdAgAGAAcIKiDxFgAdAgAAAA==.',['妹妹']='妹妹恰个微:BAAAKgAECgQIBAAAAA==.',['姐夫']='姐夫:BAABKgAFFH8IAAIZAAQIjhUQDQDzAAAZAAQIjhUQDQDzAAAAAA==.',['完辣']='完辣:BAABKgAFFH8IAAIeAAgIpwQkBACkAQAeAAgIpwQkBACkAQAAAA==.',['宛陵']='宛陵湖:BAAAKgAFFAgIAwAAAA==.',['宝丿']='宝丿大:BAABKgAFFH8UAAIYAAYIgSHVBwC/AQAYAAYIgSHVBwC/AQAAAA==.',['宫保']='宫保鸡丁:BAAAKgAFFAQIBAAAAA==.',['对不']='对不起我想你:BAAAKgADCgYIBwAAAA==.对不起我爱你:BAAAKgAECgQIBAAAAA==.',['小声']='小声开军舰:BAAAKgAECgUIBgAAAA==.',['小夫']='小夫君:BAAAKgAECggICAAAAA==.',['小小']='小小多多:BAABKgAFFH8GAAIGAAYIwR6/CADLAQAGAAYIwR6/CADLAQAAAA==.小小西:BAAAKgAECgYIBwAAAA==.小小西紫:BAAAKgAFFAQIBAABKgAFFAgIBAAfAAAAAA==.',['小废']='小废废丶:BAABKgAFFH8HAAIgAAMICAmzCgBoAAAgAAMICAmzCgBoAAAAAA==.',['小德']='小德小德小:BAAAKgAECgYIEAAAAA==.',['小手']='小手圣光:BAAAKgADCgQIBAAAAA==.',['小拉']='小拉格:BAAAKgADCggICAAAAA==.',['小满']='小满哥:BAAAKgAECggIDwAAAA==.',['小熊']='小熊水煮肉:BAAAKgAFFAYIBAAAAA==.',['小红']='小红手玩咖:BAABKgAFFH8MAAIhAAgIfh4gCAAXAgAhAAgIfh4gCAAXAgAAAA==.',['尐聖']='尐聖骑:BAABKgAFFH8GAAIOAAYIKgtoJwDUAAAOAAYIKgtoJwDUAAAAAA==.',['尚尚']='尚尚:BAAAKgADCgEIAQAAAA==.',['尛兎']='尛兎紙:BAAAKgAECgYICAAAAA==.',['尤丽']='尤丽亚:BAABKgAECn8XAAIIAAgIwAC4gwAaAAAIAAgIwAC4gwAaAAAAAA==.',['尧舜']='尧舜门徒静修:BAAAKgAECggIDAAAAA==.',['就让']='就让一切随风:BAAAKgAECgEIAQAAAA==.',['左手']='左手之间:BAAAKgADCgIIAgAAAA==.',['巫语']='巫语者:BAABKgAFFH8GAAIBAAYI5Az/DgBLAQABAAYI5Az/DgBLAQAAAA==.',['巷子']='巷子里的猫丷:BAAAKgAECgMIBgAAAA==.',['布萊']='布萊克汉德:BAAAKgAECgMIAwAAAA==.',['布鲁']='布鲁斯满:BAAAKgADCgcIBwAAAA==.',['师妹']='师妹沐季姬:BAAAKgAFFAgIAgAAAA==.',['希格']='希格诺:BAAAKgADCgQIBAAAAA==.',['帝王']='帝王之威:BAAAKgAECggICwAAAA==.',['幹泥']='幹泥拟昂:BAAAKgAFFAQIBAAAAA==.',['幻彩']='幻彩衣:BAAAKgAECggIDgAAAA==.',['开阳']='开阳:BAAAKgAECgcIBwAAAA==.',['弍奶']='弍奶要转正:BAAAKgAECgcIBwAAAA==.',['弗特']='弗特曼:BAAAKgAECggICAAAAA==.',['張老']='張老师:BAAAKgADCgUICAAAAA==.',['弹寺']='弹寺砼:BAAAKgAECgYIBgAAAA==.',['弹葱']='弹葱丶:BAABKgAECn8ZAAILAAcICA4oQwDeAAALAAcICA4oQwDeAAAAAA==.',['影依']='影依:BAACKgAFFH8bAAMMAAUIoRI2EQC/AAAMAAUIoRI2EQC/AAAKAAII8QGKGgA+AAAqAAQKfxcAAgwACAhpIX0RAEUCAAwACAhpIX0RAEUCAAAA.',['彼岸']='彼岸深蓝:BAAAKgADCggICAAAAA==.',['德撸']='德撸伊人:BAAAKgAECgUIBQAAAA==.',['念雪']='念雪慕鸿:BAABKgAFFH8OAAMdAAQIDxk9OQC0AAAdAAQIDxk9OQC0AAAYAAIIXw8EIQBsAAAAAA==.',['怀抱']='怀抱太阳:BAAAKgAECgcIBwAAAA==.',['恶魔']='恶魔一罚款:BAAAKgADCgQIBAAAAA==.恶魔熊熊:BAAAKgAECggIDQAAAA==.',['悟性']='悟性有道:BAAAKgAFFAMIAwAAAA==.',['惩戒']='惩戒之神:BAABKgAFFH8GAAMOAAYIVguYMQAjAQAOAAQIfA+YMQAjAQANAAIIvQNAEgBpAAAAAA==.',['想你']='想你的睿恩:BAAAKgADCgMIAwAAAA==.',['愤怒']='愤怒的榴莲干:BAAAKgADCgEIAQAAAA==.愤怒的猪猪:BAABKgAFFH8GAAMOAAYIrRpBUgDLAAAOAAQIXxhBUgDLAAANAAIIIhHEEwCfAAAAAA==.',['慕思']='慕思妹子:BAAAKgADCgMIAwABKgAECgYIAQAfAAAAAA==.',['懒米']='懒米米傻团团:BAAAKgADCgQIBAAAAA==.',['我将']='我将带头升空:BAAAKgAECgMIAwAAAA==.',['我是']='我是叫来的人:BAAAKgAFFAgIBAAAAA==.',['战斗']='战斗熊熊:BAABKgAECn8bAAIGAAgI7yP6DwBhAgAGAAgI7yP6DwBhAgAAAA==.',['戦譕']='戦譕訫:BAAAKgAECgYICwAAAA==.',['打弓']='打弓崽:BAAAKgAECgcIDAAAAA==.',['拉斐']='拉斐尔桀:BAABKgAFFH8FAAIQAAUILQYaGQDWAAAQAAUILQYaGQDWAAAAAA==.',['拉鸡']='拉鸡游戏:BAABKgAFFH8MAAMiAAYIrBioBQD+AAABAAYIUhRfGQA5AQAiAAQIfheoBQD+AAAAAA==.',['支离']='支离梦境:BAAAKgAECgQIBwAAAA==.',['放开']='放开一只羊:BAABKgAFFH8ZAAIBAAgIRB2xDgDuAAABAAgIRB2xDgDuAAAAAA==.',['救赎']='救赎哥:BAAAKgAFFAYIBAAAAA==.救赎蛋:BAABKgAFFH8IAAMWAAQI2iSoIwALAQAWAAQI2iSoIwALAQAFAAQIfgruJwCFAAAAAA==.',['教主']='教主万紫千橙:BAACKgAFFH8SAAIUAAQI6xBwNADFAAAUAAQI6xBwNADFAAAqAAQKfxgAAhQACAgYHME1ANoBABQACAgYHME1ANoBAAAA.',['无可']='无可奈何:BAAAKgAECgQIBQAAAA==.',['无心']='无心入圣:BAAAKgAECgYIBgAAAA==.无心无伤:BAAAKgAECgcICwAAAA==.无心无恶魔:BAAAKgADCgEIAQAAAA==.无心无战:BAAAKgADCgIIAgAAAA==.无心无竹:BAAAKgAECgQIBgAAAA==.无心無伤:BAAAKgAECggICAAAAA==.无心無竹:BAAAKgAECgYIBgAAAA==.',['无敌']='无敌绿巨人:BAAAKgAECgUIBQAAAA==.',['无聊']='无聊:BAAAKgAECgUICAAAAA==.无聊德:BAAAKgAECgMIBQAAAA==.',['春水']='春水东流:BAAAKgAECgUIBQAAAA==.',['是的']='是的没错:BAABKgAFFH8GAAIKAAYIwh0qCACNAQAKAAYIwh0qCACNAQAAAA==.',['晓风']='晓风残夜:BAAAKgAFFAEIAQAAAA==.',['暴力']='暴力饼干:BAAAKgAFFAMIAwAAAA==.',['最后']='最后的留恋:BAABKgAFFH8KAAMjAAgIYBXbEABVAQAjAAYIcRHbEABVAQAkAAMINiFaAwAVAQAAAA==.',['最爱']='最爱吃兽奶:BAAAKgAECgUIBQAAAA==.',['月舞']='月舞妃嫣:BAAAKgAECgcIBwAAAA==.',['有点']='有点乖:BAABKgAFFH8IAAMMAAQI4RuvDwDCAAALAAQI4RvfFQDlAAAMAAQIZQyvDwDCAAAAAA==.有点呆:BAABKgAFFH8UAAIEAAYITyBRAgCoAQAEAAYITyBRAgCoAQAAAA==.有点困:BAABKgAFFH8GAAIMAAYIwxHLDgA/AQAMAAYIwxHLDgA/AQAAAA==.有点浪:BAABKgAFFH8GAAIEAAYIuxWBDACFAQAEAAYIuxWBDACFAQAAAA==.有点跳:BAAAKgAFFAQIBAAAAA==.',['木仓']='木仓:BAABKgAFFH8PAAMYAAYI1hnBAQCQAQAYAAYIwBTBAQCQAQAdAAEIxholQQBgAAAAAA==.',['木子']='木子:BAAAKgAFFAgIBAAAAA==.',['木饭']='木饭:BAAAKgAECgQIBAAAAA==.',['机智']='机智萨哟:BAABKgAECn8/AAIZAAgIAxsXKgDVAQAZAAgIAxsXKgDVAQAAAA==.',['李嘉']='李嘉欣:BAAAKgADCggICAAAAA==.',['松下']='松下守莎:BAAAKgAECggICAAAAA==.',['枫枼']='枫枼:BAACKgAFFH8pAAIWAAgIthu9BwAtAgAWAAgIthu9BwAtAgAqAAQKfxQAAhYABwioIA82ANABABYABwioIA82ANABAAAA.',['枭阳']='枭阳:BAAAKgAECgIIAgAAAA==.',['柒叶']='柒叶知秋:BAAAKgAECgQIBAAAAA==.',['柠檬']='柠檬盒子:BAAAKgAECgUIBQAAAA==.',['树欲']='树欲静凨不止:BAAAKgAECggICwAAAA==.',['桃与']='桃与箭:BAAAKgAFFAQIBAAAAA==.',['桃小']='桃小妖夭:BAAAKgADCgMIAwAAAA==.',['桜小']='桜小路露娜:BAAAKgAECgEIAQAAAA==.',['梦之']='梦之双刀:BAAAKgAECggICAAAAA==.',['梦想']='梦想之名:BAAAKgAFFAQIBAAAAA==.',['梨花']='梨花先雪丶:BAABKgAECn8aAAMYAAgIhCW7AgDuAgAYAAgIKSS7AgDuAgAdAAgIHyQNFACLAgABKgAFFAgIDwAYAOMRAA==.',['武田']='武田信玄:BAAAKgAECgcIDgAAAA==.',['死灵']='死灵骑手:BAAAKgAECgEIAQAAAA==.',['残阳']='残阳如血:BAAAKgADCggIEAAAAA==.',['比狗']='比狗还要菜:BAABKgAFFH8KAAMOAAYIeBPBFAAFAQAOAAYIeBPBFAAFAQANAAQI2AdzCgC4AAAAAA==.',['水了']='水了无痕:BAAAKgAECgIIAgAAAA==.',['永恒']='永恒封冰:BAAAKgAECgIIAwAAAA==.',['没啥']='没啥意思:BAAAKgADCggICAAAAA==.',['没有']='没有线的人偶:BAAAKgADCggICAAAAA==.',['法丝']='法丝洛洛:BAAAKgADCgIIAgAAAA==.',['洒家']='洒家来一发:BAABKgAECn8WAAMdAAgI+SAcGgCRAgAdAAgI+SAcGgCRAgAYAAIIsBI5pgAzAAAAAA==.',['洛梵']='洛梵丶:BAAAKgAECgYICQAAAA==.',['浅一']='浅一葬花:BAABKgAFFH8VAAIWAAcI5BsgAwCdAQAWAAcI5BsgAwCdAQAAAA==.',['浅白']='浅白夜空:BAABKgAECn8XAAMFAAgInxJuRwDwAAAFAAcIrxBuRwDwAAAgAAUInwwqKwCUAAAAAA==.',['浪啸']='浪啸雨:BAABKgAFFH8IAAIGAAgIdQ7KBQA1AgAGAAgIdQ7KBQA1AgAAAA==.',['浮云']='浮云骑神马:BAACKgAFFH8MAAIZAAYIVhhUDACEAQAZAAYIVhhUDACEAQAqAAQKfxUAAhkACAjmECs5AKEBABkACAjmECs5AKEBAAEqAAUUCAgcABkAMyUA.',['海月']='海月白灵:BAABKgAFFH8FAAMQAAQI8CJhHQC1AAAQAAMIbSFhHQC1AAAVAAEIbQHvKAAmAAAAAA==.',['海棠']='海棠朵朵:BAAAKgAECgcIBgAAAA==.',['海的']='海的女儿:BAAAKgAFFAQIBAAAAA==.',['海绵']='海绵宝呗:BAAAKgADCgQIBAAAAA==.',['深渊']='深渊血骑:BAAAKgAECgYIDQAAAA==.',['清风']='清风玲音:BAAAKgAECgQIBAAAAA==.',['渊漪']='渊漪:BAAAKgAECgYIBgABKgAFFAUIGwAMAKESAA==.',['湛神']='湛神:BAAAKgAECggICwAAAA==.',['湛豆']='湛豆豆:BAABKgAFFH8FAAIWAAMI4gkgPwCuAAAWAAMI4gkgPwCuAAAAAA==.',['湮灭']='湮灭:BAAAKgAECgYIBgAAAA==.',['灬紫']='灬紫了葡萄灬:BAACKgAFFH8wAAMZAAgI5x1OCQCxAQAZAAgI5x1OCQCxAQAlAAEI3AEbHgA2AAAqAAQKfx8AAxkACAjJEm1EAHYBABkACAjJEm1EAHYBACUABQhQE1lSANAAAAAA.',['灼眼']='灼眼的夏娜:BAAAKgADCggIDgAAAA==.',['炉石']='炉石萌新别打:BAAAKgAFFAIIAgAAAA==.',['炫顿']='炫顿自助:BAAAKgAECgUICQAAAA==.',['炫风']='炫风:BAAAKgAECgYICwAAAA==.',['烟丶']='烟丶瘾:BAABKgAFFH8GAAIZAAQIAAwAFwDJAAAZAAQIAAwAFwDJAAAAAA==.',['無心']='無心無傷:BAAAKgADCgEIAQAAAA==.',['煌竹']='煌竹:BAABKgAFFH8VAAMKAAcIRhmoAwCXAQAKAAcIRhmoAwCXAQALAAQIbxqeDwDcAAAAAA==.',['熏丶']='熏丶儿:BAABKgAFFH8IAAIPAAgIABpwBAAKAgAPAAgIABpwBAAKAgAAAA==.',['爆浆']='爆浆麻薯:BAACKgAFFH8oAAIGAAcIUiAtBgA4AQAGAAcIUiAtBgA4AQAqAAQKfyYAAgYACAhHJqABAA4DAAYACAhHJqABAA4DAAAA.',['爱丽']='爱丽希希:BAAAKgADCgQIBAAAAA==.',['爱美']='爱美女的菠萝:BAABKgAFFH8RAAMdAAMISRQAMACZAAAdAAII6hgAMACZAAAYAAIIoA9NQwBvAAAAAA==.',['牛板']='牛板筋儿:BAAAKgADCggICAAAAA==.',['牛爪']='牛爪解衣:BAAAKgAECggICQAAAA==.',['狄拉']='狄拉:BAAAKgADCgEIAQAAAA==.',['狩猎']='狩猎阝灬:BAABKgAECn8VAAMdAAgIRh7AMQAtAgAdAAgIaBvAMQAtAgAYAAQIdx7pRQA5AQAAAA==.',['狮子']='狮子座流星:BAABKgAFFH8XAAMdAAYI3CG2CQDXAQAdAAYI3CG2CQDXAQAYAAYIfw5JDQArAQAAAA==.',['猎祖']='猎祖猎宗:BAABKgAFFH8KAAImAAMIIAq2AwCvAAAmAAMIIAq2AwCvAAAAAA==.',['猪皮']='猪皮扫地僧:BAAAKgAECgcIDQAAAA==.',['玉兰']='玉兰灬花开:BAAAKgAECgYIBgAAAA==.',['玛丽']='玛丽罗斯:BAABKgAFFH8fAAIbAAgIaxjRBQDeAQAbAAgIaxjRBQDeAQAAAA==.',['男魔']='男魔:BAAAKgADCgcIBwAAAA==.',['白衣']='白衣未央:BAAAKgAECggIDAAAAA==.',['皮皮']='皮皮虾之怒:BAAAKgAECggICgAAAA==.',['真正']='真正的鳗:BAAAKgAECgYIBgAAAA==.',['睿智']='睿智毛线球:BAAAKgAECgQIBAAAAA==.',['矜持']='矜持丶先森:BAACKgAFFH8HAAIIAAQIYxI3CgDWAAAIAAQIYxI3CgDWAAAqAAQKfyUAAggACAjkIc8YADsCAAgACAjkIc8YADsCAAAA.',['砍断']='砍断天柱:BAAAKgAECgYICAAAAA==.',['破剑']='破剑人丶罗辑:BAAAKgAECgYIBgAAAA==.',['破哥']='破哥:BAAAKgADCgMIAwAAAA==.',['破碎']='破碎的残阳:BAAAKgAECggICwAAAA==.',['祖尔']='祖尔纳克:BAAAKgADCgMIAwAAAA==.',['神域']='神域灬无敌:BAAAKgAECgEIAQAAAA==.',['神羅']='神羅天征:BAAAKgAECgUIBQAAAA==.',['福福']='福福大魔王:BAAAKgAECgcIDAAAAA==.',['秋叶']='秋叶为何而落:BAAAKgAFFAEIAQAAAA==.',['筱筱']='筱筱丶魚兒:BAAAKgADCggICAAAAA==.',['简丶']='简丶兮:BAAAKgAECgEIAQAAAA==.',['简单']='简单旋律:BAAAKgAECggICQAAAA==.',['精神']='精神小伙:BAABKgAFFH8VAAIZAAYINiFnBwDTAQAZAAYINiFnBwDTAQABKgAFFAgIHgAZABseAA==.',['糖醋']='糖醋排骨:BAABKgAFFH8KAAMYAAgIlAtMCgB4AQAYAAgIOQhMCgB4AQAdAAII1RTvQgCUAAAAAA==.糖醋茄子丶:BAAAKgADCggICAAAAA==.',['紫氣']='紫氣東來:BAAAKgAECggIEQAAAA==.',['絶蝂']='絶蝂锋少:BAABKgAECn8aAAMOAAgIrBcTZwCOAQAOAAcIoxkTZwCOAQANAAYIngg0OgCyAAAAAA==.',['红色']='红色冰法:BAAAKgADCgEIAQAAAA==.',['红袖']='红袖招盈盈:BAAAKgAFFAQIBAAAAA==.',['纯吊']='纯吊:BAABKgAFFH8EAAIQAAQItgiUCQAZAQAQAAQItgiUCQAZAQAAAA==.',['纯属']='纯属搞笑:BAAAKgAECggICgAAAA==.',['纯爱']='纯爱战神:BAAAKgAECgYIAQAAAA==.',['终极']='终极丨小壊疍:BAAAKgAECgMIAwAAAA==.',['经济']='经济学模型:BAABKgAFFH8QAAIjAAgIFQ8ECADvAQAjAAgIFQ8ECADvAQAAAA==.',['给你']='给你吗一拳:BAAAKgAECggICQAAAA==.',['给力']='给力有木有:BAAAKgAFFAIIAwAAAA==.',['给色']='给色个:BAAAKgAFFAYIAwAAAA==.',['羊大']='羊大仙儿:BAABKgAFFH8RAAMOAAQIAhiTHgDsAAAOAAQIAhiTHgDsAAAPAAQILhL0DAChAAAAAA==.羊大先:BAAAKgAFFAQIBAAAAA==.羊大鲜儿:BAAAKgAECgMIAwAAAA==.',['美人']='美人泪杯中酒:BAAAKgAECgIIAgAAAA==.',['老二']='老二在前面:BAAAKgAFFAQIBAABKgAFFAgIDQABAIAmAA==.',['老司']='老司机的阴谋:BAACKgAFFH8UAAIYAAQIJRFGMACtAAAYAAQIJRFGMACtAAAqAAQKfzkAAhgACAgFHXsYAA0CABgACAgFHXsYAA0CAAAA.',['老牛']='老牛在腰間:BAABKgAFFH8GAAIOAAYIPRRIHwBzAQAOAAYIPRRIHwBzAQAAAA==.',['考拉']='考拉酱:BAAAKgAFFAUIAQABKgAFFAgIDQALANocAA==.',['聖光']='聖光裁决使者:BAAAKgADCgQIBAABKgAFFAgICgAOAK0lAA==.',['聪明']='聪明的石头人:BAAAKgAECgQIBQAAAA==.',['胖达']='胖达公主:BAAAKgAECgcIDAAAAA==.',['至爱']='至爱成伤:BAAAKgAECgcIBwAAAA==.',['舞空']='舞空:BAAAKgAECgEIAQAAAA==.',['艾斯']='艾斯特兰娜:BAAAKgAECgEIAQAAAA==.艾斯蒂:BAAAKgAECgYIDQAAAA==.',['艾欧']='艾欧灬洛斯:BAAAKgADCgIIAgAAAA==.',['艾达']='艾达晨光:BAAAKgADCgIIAgAAAA==.',['芝士']='芝士发丝:BAAAKgAECggIAgAAAA==.芝士小德:BAABKgAFFH8GAAIWAAYIsRF1DwB2AQAWAAYIsRF1DwB2AQAAAA==.',['花花']='花花:BAAAKgADCggICgAAAA==.',['若水']='若水寒冰:BAAAKgAFFAMIAwAAAA==.',['苦逼']='苦逼的他:BAABKgAFFH8MAAIGAAgIrhTjBQAWAgAGAAgIrhTjBQAWAgAAAA==.',['英伦']='英伦玫瑰:BAAAKgADCgcIBwAAAA==.',['莉莉']='莉莉絲:BAAAKgADCggICAAAAA==.',['菠萝']='菠萝怪:BAAAKgAFFAQIBAABKgAFFAgIBAAfAAAAAA==.',['萌萌']='萌萌小宝宝:BAAAKgAECgcICwAAAA==.',['蒲尼']='蒲尼阿摩:BAABKgAFFH8GAAIRAAYI0g9JBAD3AAARAAYI0g9JBAD3AAAAAA==.',['蔷薇']='蔷薇与剑:BAAAKgAFFAQIAQAAAA==.',['薇尔']='薇尔莉特:BAABKgAFFH8LAAIhAAQIVRxqEgD2AAAhAAQIVRxqEgD2AAAAAA==.',['薩菲']='薩菲羅斯丶:BAAAKgAECgQIBAAAAA==.',['虎啸']='虎啸龙吟:BAAAKgADCggIDAAAAA==.',['蜀道']='蜀道山:BAABKgAFFH8GAAInAAYIsA0AAAAAAAAUAAYIsA0AAAAAAAAAAA==.',['蜗牛']='蜗牛砍闪电:BAAAKgAECggICgAAAA==.',['蜡笔']='蜡笔丨小刚:BAACKgAFFH8MAAIIAAQIyAvcEADbAAAIAAQIyAvcEADbAAAqAAQKfxkAAggACAjuHAwZAOwBAAgACAjuHAwZAOwBAAAA.蜡笔丨小新:BAABKgAFFH8IAAIRAAMIzQVKCQB1AAARAAMIzQVKCQB1AAAAAA==.蜡笔丨小旧:BAACKgAFFH8FAAIGAAMIfAgGKQCjAAAGAAMIfAgGKQCjAAAqAAQKfxkAAwYACAgvDYtEAAUBAAYACAgvDYtEAAUBABMABwhoBIw4AIEAAAAA.',['蝶狄']='蝶狄吖丶:BAAAKgAECgYIBwAAAA==.',['血无']='血无情:BAAAKgAECgEIAQAAAA==.',['血泪']='血泪:BAAAKgAECgMIAwAAAA==.',['血色']='血色灰壗:BAAAKgAFFAYIBAAAAA==.血色飘舞:BAABKgAFFH8GAAIhAAYIbxPSEQBvAQAhAAYIbxPSEQBvAQAAAA==.',['被阴']='被阴的小龍女:BAAAKgAECgMIAwAAAA==.',['譕訫']='譕訫丨冰:BAAAKgAECgIIAgAAAA==.譕訫丨四爷:BAAAKgAECggICwAAAA==.',['请你']='请你忘了我:BAAAKgAFFAQIBAAAAA==.',['谁爱']='谁爱上你的醉:BAAAKgADCggIDAAAAA==.',['谜飒']='谜飒焱:BAAAKgAECgUICgAAAA==.',['豪哥']='豪哥:BAABKgAFFH8GAAIOAAYI9AblMQAhAQAOAAYI9AblMQAhAQAAAA==.',['贝儿']='贝儿麦莎:BAAAKgADCgcIBwAAAA==.',['贞德']='贞德:BAAAKgAECgcICgAAAA==.',['费兰']='费兰肯斯坦:BAAAKgAECgQIBAAAAA==.',['超人']='超人强:BAAAKgAFFAIIAgAAAA==.',['超级']='超级破魔虫:BAAAKgAECgYIBgAAAA==.',['超薄']='超薄也有距离:BAAAKgAECgcIDwAAAA==.',['越秀']='越秀傾城:BAAAKgAFFAgIBAAAAA==.',['跳跳']='跳跳逗:BAAAKgADCgQIBQAAAA==.',['轻轻']='轻轻丶追风:BAAAKgADCgQIBAAAAA==.',['远古']='远古巨龙:BAAAKgAECgQIBQAAAA==.',['迟迟']='迟迟:BAAAKgAFFAQIBAAAAA==.',['迷生']='迷生寂乱:BAAAKgADCggIEAAAAA==.迷生忌乱:BAAAKgADCgYIBgAAAA==.',['迷途']='迷途的阿宝:BAAAKgAECggICAAAAA==.',['迷雾']='迷雾:BAAAKgAFFAIIAgAAAA==.',['逍遥']='逍遥凡者:BAAAKgADCgEIAQAAAA==.逍遥魅影:BAAAKgAECggICAAAAA==.',['遗忘']='遗忘沐沐:BAABKgAFFH8IAAISAAIIAAOnIwBHAAASAAIIAAOnIwBHAAAAAA==.遗忘的白开水:BAAAKgAFFAEIAQAAAA==.',['邪灵']='邪灵之怒:BAAAKgAECgcIBwAAAA==.',['酸萝']='酸萝卜丶别吃:BAAAKgADCggIEAAAAA==.',['醉天']='醉天涯术:BAABKgAFFH8KAAIBAAgIIRd7AgCzAQABAAgIIRd7AgCzAQAAAA==.',['野风']='野风涉:BAABKgAFFH8IAAMMAAQINiGIBQARAQAMAAQINiGIBQARAQALAAQI5Q56EQDRAAAAAA==.',['銩倪']='銩倪佬慕:BAABKgAFFH8QAAIPAAYIaQuhDACkAAAPAAYIaQuhDACkAAABKgAFFAgIDQAOAOEYAA==.',['钢铁']='钢铁侠:BAAAKgAECggICQAAAA==.',['键来']='键来:BAAAKgAECggICwAAAA==.',['阿伽']='阿伽莎赫拉:BAAAKgAECgQIBAAAAA==.',['阿可']='阿可蒙德之眼:BAABKgAFFH8GAAIBAAQI7hxGDgDxAAABAAQI7hxGDgDxAAAAAA==.',['阿尔']='阿尔忒弥斯:BAABKgAFFH8KAAIFAAYIeRkTKQADAAAFAAYIeRkTKQADAAAAAA==.',['阿狸']='阿狸爱吃鸡:BAAAKgAFFAYIAgAAAA==.',['雪冷']='雪冷萃:BAABKgAFFH8MAAMOAAQIBCE9EQAQAQAOAAQIBCE9EQAQAQAPAAQIUwYMJABnAAAAAA==.',['雪后']='雪后初晴:BAABKgAFFH8LAAMEAAYITB5IBABLAQAEAAYITB5IBABLAQADAAEIuQkgEQBHAAAAAA==.',['雪城']='雪城熊熊:BAAAKgAECggIEAAAAA==.',['零零']='零零龍:BAAAKgADCggICAAAAA==.',['雷戈']='雷戈:BAAAKgADCgIIAgAAAA==.',['雾仙']='雾仙人:BAABKgAFFH8IAAMVAAYIbRfkAQC9AQAVAAYIbRfkAQC9AQAQAAIIwQpcJAB1AAAAAA==.',['静修']='静修之猎刃:BAAAKgAECgMIAwAAAA==.',['静谧']='静谧之手:BAAAKgAECggIEAAAAA==.',['風主']='風主霜城:BAAAKgAECggIDgAAAA==.',['风一']='风一様的女子:BAABKgAFFH8NAAMGAAcIfCD9BQATAgAGAAcIfCD9BQATAgATAAEImxVWFgBAAAAAAA==.',['风中']='风中散发:BAAAKgADCggICAAAAA==.',['风之']='风之悠贤:BAAAKgADCggICAAAAA==.',['风起']='风起叶落:BAAAKgAFFAEIAQAAAA==.',['饅饅']='饅饅:BAAAKgADCgUIBQAAAA==.',['饿虎']='饿虎残龙:BAABKgAFFH8OAAIbAAgIvxe9AgARAgAbAAgIvxe9AgARAgAAAA==.',['马歇']='马歇尔咆哮:BAAAKgAECggICAAAAA==.',['驯狐']='驯狐师:BAAAKgAECggIDQAAAA==.',['骚年']='骚年丶:BAAAKgAECggICAAAAA==.',['魄儿']='魄儿:BAAAKgAECgEIAQAAAA==.',['魄斧']='魄斧:BAAAKgADCggICAAAAA==.',['魔力']='魔力战刃:BAAAKgAECgMIAwAAAA==.魔力毁灭:BAABKgAECn8iAAIBAAgIYRs1GwAfAgABAAgIYRs1GwAfAgAAAA==.',['魔龙']='魔龙:BAAAKgADCgQIAwAAAA==.',['鱼香']='鱼香肉丝:BAAAKgAFFAQIBAAAAA==.',['鸽王']='鸽王:BAAAKgAECggICAAAAA==.',['鹤仙']='鹤仙问鹿仙:BAAAKgAECgIIAgAAAA==.',['麒耀']='麒耀黑锋:BAABKgAFFH8LAAIUAAYIVR78DADBAQAUAAYIVR78DADBAQAAAA==.',['麦乐']='麦乐鶏:BAAAKgAECgYICgAAAA==.',['黑豹']='黑豹永存:BAAAKgAECggICAAAAA==.',['黑骑']='黑骑也风骚:BAABKgAFFH8MAAIUAAgI3Rb0BQA7AgAUAAgI3Rb0BQA7AgAAAA==.',['齐木']='齐木楠雄:BAAAKgADCggICAAAAA==.',['龙骑']='龙骑死:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end