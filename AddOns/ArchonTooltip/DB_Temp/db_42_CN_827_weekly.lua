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
 local lookup = {'DemonHunter-Havoc','DeathKnight-Unholy','DemonHunter-Vengeance','Unknown-Unknown','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Monk-Mistweaver','Priest-Holy','Priest-Discipline','Priest-Shadow','Mage-Arcane','Shaman-Restoration','Shaman-Elemental','Mage-Frost','Paladin-Protection','Paladin-Retribution','Warrior-Arms','Warrior-Fury','Shaman-Enhancement','Warrior-Protection','Hunter-Marksmanship','Druid-Balance','Druid-Restoration','DeathKnight-Blood','Hunter-BeastMastery','Hunter-Survival','Monk-Windwalker','Mage-Fire','Monk-Brewmaster','Paladin-Holy',}; local provider = {region='CN',realm='血顶',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ap='Apostle:BAAAKgADCgYIBgAAAA==.',Be='Beauiful:BAAAKgAECgEIAQAAAA==.',Ca='Catherine:BAAAKgAECgEIAQAAAA==.',Ci='Citrus:BAABKgAFFH8GAAIBAAYIBgb3HgAMAQABAAYIBgb3HgAMAQABKgAFFAgICAACAFcPAA==.',Da='Darkgabriel:BAABKgAFFH8MAAIBAAYIrBoqDgCgAQABAAYIrBoqDgCgAQABKgAFFAgIEgABAJgVAA==.Daydreamer:BAAAKgAECgUIBwAAAA==.',Di='Discogirl:BAAAKgAECggIEwAAAA==.',Eu='Eutopia:BAAAKgAECgcIBwAAAA==.',Gi='Ginights:BAACKgAFFH8eAAIDAAYI6gZfDgDUAAADAAYI6gZfDgDUAAAqAAQKfx0AAwMACAgCFqMdAJYBAAMACAgCFqMdAJYBAAEAAwj7BGyxAEwAAAAA.',Kr='Kratos:BAAAKgAFFAQIBAABKgAFFAgIAgAEAAAAAA==.',Le='Lengzhi:BAABKgAFFH8KAAQFAAYI9g7fBgDIAAAGAAQIJBCNEwDWAAAFAAUI5QPfBgDIAAAHAAEIHRRYGQBXAAABKgAFFAgIFgAGAOgSAA==.',Lo='Loxx:BAAAKgAECgYIBwAAAA==.',Lu='Lucia:BAAAKgADCgEIAQAAAA==.',Lz='Lzz:BAAAKgAECggIDgAAAA==.',Mi='Mithril:BAAAKgAFFAgIAgAAAA==.',Pr='Present:BAABKgAFFH8IAAIIAAQI5wamFwC/AAAIAAQI5wamFwC/AAAAAA==.',Pu='Puerto:BAAAKgAECgYIDAAAAA==.',Qu='Quenn:BAAAKgAECgYIBgAAAA==.',Ro='Rockrabbit:BAAAKgAECgQIBAAAAA==.',Sh='Shielder:BAAAKgADCggICAAAAA==.',Sq='Squirrel:BAABKgAFFH8NAAQJAAMIcSEOFwD9AAAJAAMIwCAOFwD9AAAKAAMI0R69FQDmAAALAAIIAwQkIABkAAAAAA==.',Su='Summon:BAAAKgADCgMIAwAAAA==.',Vs='Vssiws:BAABKgAFFH8IAAIMAAgINA6dCQDWAQAMAAgINA6dCQDWAQAAAA==.',We='Weirdo:BAAAKgADCgIIAgAAAA==.',Za='Zaiaa:BAABKgAFFH8MAAMNAAgIkBlkAwA+AgANAAgIkBlkAwA+AgAOAAQIJhb/CADmAAAAAA==.',['一介']='一介行李:BAAAKgADCggIEAAAAA==.',['一只']='一只鸭咩蝶:BAAAKgADCggICAAAAA==.',['一支']='一支烟:BAAAKgADCgcIBwAAAA==.',['丁螺']='丁螺环酮:BAAAKgAECgQIBAAAAA==.',['三鹿']='三鹿毒奶:BAABKgAFFH8GAAMMAAYIkRPnFwAlAQAMAAUIohPnFwAlAQAPAAEITxOYKgBAAAAAAA==.',['不是']='不是很熟:BAABKgAFFH8QAAMGAAYIkxjSDQBjAQAGAAYIiBTSDQBjAQAHAAQIrxvfDADNAAAAAA==.',['世界']='世界的硬盘:BAAAKgAFFAYIBAAAAA==.',['两锤']='两锤:BAAAKgAFFAYIBAAAAA==.',['中级']='中级经济尸:BAAAKgAFFAYIBAAAAA==.',['丶方']='丶方枪枪:BAAAKgAFFAgIBAAAAA==.',['丶时']='丶时之砂:BAAAKgAECgUIBgAAAA==.',['丶空']='丶空白格:BAAAKgAFFAQIBAAAAA==.',['丶诗']='丶诗意:BAACKgAFFH8GAAIQAAYIaST8BAD0AQAQAAYIaST8BAD0AQAqAAQKfyMAAhEACAgqJGwNANoCABEACAgqJGwNANoCAAAA.',['举着']='举着我家老熊:BAAAKgADCgMIAwAAAA==.',['乄我']='乄我叫哀木涕:BAABKgAECn8WAAICAAgIlBmkMgDnAQACAAgIlBmkMgDnAQAAAA==.',['久违']='久违的胡椒粉:BAAAKgAECgIIAwAAAA==.',['九幽']='九幽阴靈:BAAAKgAECgYIBgAAAA==.',['云想']='云想衣裳:BAABKgAECn8cAAIRAAgI+hV7ggCSAQARAAgI+hV7ggCSAQAAAA==.',['五角']='五角场精灵:BAAAKgAFFAYIBAAAAA==.',['亡者']='亡者的箴言:BAAAKgAECgUIBQAAAA==.',['他唇']='他唇毁她纯:BAAAKgAECgYIBgAAAA==.',['众爱']='众爱卿平身:BAAAKgADCgcICQAAAA==.',['优秀']='优秀:BAAAKgAFFAQIBAAAAA==.',['似水']='似水乄流年:BAAAKgAFFAQIAwAAAA==.',['佳猫']='佳猫:BAAAKgAECgYIDAAAAA==.',['保险']='保险箱:BAAAKgADCgIIAgAAAA==.',['光子']='光子:BAAAKgADCggIDQAAAA==.',['兮兮']='兮兮:BAACKgAFFH8lAAMSAAYIvCIiBAAJAgASAAYIvCIiBAAJAgATAAQILhJxEgDvAAAqAAQKfzYAAxMACAhBGg4lAP0BABMACAgKGg4lAP0BABIABghLGUsdAJsBAAAA.',['内库']='内库外穿丶:BAAAKgAFFAQIBAAAAA==.',['冈多']='冈多拉:BAAAKgAECgcIBwAAAA==.',['冒泡']='冒泡儿:BAABKgAFFH8GAAINAAYIoBaoCwCNAQANAAYIoBaoCwCNAQAAAA==.',['冥十']='冥十三:BAABKgAECn8fAAQUAAgIzB0zFAAtAgAUAAgIShwzFAAtAgAOAAcIdRnyIgC1AQANAAEIqxsMuABFAAABKgAFFAgIHgAPAFEhAA==.',['冰之']='冰之末裔:BAAAKgAECggIAgAAAA==.',['冰糖']='冰糖豆腐花:BAAAKgAECgIIAgAAAA==.',['冷艳']='冷艳小妈:BAABKgAFFH8KAAQGAAYI+CCYDADDAQAGAAYI+CCYDADDAQAFAAEICQolMAA6AAAHAAEIAACYKQAAAAAAAA==.',['冻柠']='冻柠茶少糖:BAABKgAECn8aAAMGAAgIYB05JgDiAQAGAAgIYB05JgDiAQAFAAIILxoOWgCXAAAAAA==.',['刀仔']='刀仔:BAAAKgAECgEIAQAAAA==.',['别龙']='别龙马:BAAAKgAFFAQIBAAAAA==.',['剑神']='剑神李淳罡:BAACKgAFFH8iAAIVAAUIOA0LCQDUAAAVAAUIOA0LCQDUAAAqAAQKfyAABBIACAilF30hAKkBABIACAhND30hAKkBABUACAhwF7YcACABABMAAggUDtRoAGgAAAAA.',['勇敢']='勇敢牛牛:BAABKgAFFH8MAAIWAAgIoReBBQAeAgAWAAgIoReBBQAeAgAAAA==.',['勤俭']='勤俭丶持家:BAABKgAFFH8YAAMXAAYI3CJUCQACAgAXAAYI3CJUCQACAgAYAAUIUwUtHgC2AAABKgAFFAgIBAAEAAAAAA==.',['医师']='医师:BAAAKgAFFAQIBAAAAA==.',['十三']='十三阔少:BAAAKgAECgUICgAAAA==.',['千夜']='千夜丶:BAAAKgAECgMIAwAAAA==.',['半只']='半只兔的星河:BAABKgAFFH8GAAMYAAYIGgOuHwCtAAAYAAUIVgOuHwCtAAAXAAEIOgPxXgA8AAABKgAFFAgIBAAEAAAAAA==.',['卿尘']='卿尘:BAABKgAFFH8WAAMSAAYIyBrBBQDJAQASAAYIyBrBBQDJAQATAAQIVAYaFgCxAAAAAA==.',['只是']='只是杀你:BAAAKgAECgYIDAAAAA==.',['史灬']='史灬珍香:BAAAKgAECgMIAwAAAA==.',['吃醋']='吃醋的胡萝卜:BAEAKgAECggIDgABKgAFFAgIBgAUAK4TAA==.',['名字']='名字就是嘲讽:BAAAKgAFFAQIBAAAAA==.',['君临']='君临程下:BAAAKgAFFAMIAwAAAA==.',['听风']='听风:BAACKgAFFH8VAAIWAAQI0hFvFgCxAAAWAAQI0hFvFgCxAAAqAAQKfxwAAhYACAg5HIkLABsCABYACAg5HIkLABsCAAAA.',['咕尔']='咕尔丹:BAAAKgAFFAgIAwAAAA==.',['咕就']='咕就是这样:BAAAKgAECgIIAgAAAA==.',['咩吖']='咩吖咩阿咩:BAAAKgADCgcIDAAAAA==.',['哈丽']='哈丽雅:BAABKgAFFH8KAAIIAAYIzBQxCQBPAQAIAAYIzBQxCQBPAQAAAA==.',['哥就']='哥就一俗人:BAAAKgAECgMIAwAAAA==.',['喵喵']='喵喵龙牧:BAAAKgAECgYIBgAAAA==.',['回首']='回首已漠然:BAAAKgAECgUIBgAAAA==.',['圣光']='圣光之辉:BAACKgAFFH8FAAIRAAMI1xZRUADPAAARAAMI1xZRUADPAAAqAAQKfxUAAhEABwiPHCCzADIBABEABwiPHCCzADIBAAAA.圣光照耀夏天:BAACKgAFFH8IAAIQAAUIAQcxIAB9AAAQAAUIAQcxIAB9AAAqAAQKfxkAAxAABgiuGHgkADEBABAABgiVFXgkADEBABEABghFENzoANkAAAAA.',['圣钥']='圣钥:BAACKgAFFH8OAAIJAAYI8SO8AwAFAgAJAAYI8SO8AwAFAgAqAAQKfxYAAgkACAhxJN0BANECAAkACAhxJN0BANECAAAA.',['地塞']='地塞米松:BAAAKgADCggIBgAAAA==.',['地狱']='地狱执行者:BAAAKgADCggICAAAAA==.',['埃斯']='埃斯溜形:BAAAKgADCgQIBgAAAA==.',['城南']='城南沙洲镜:BAAAKgAECgEIAQAAAA==.',['培根']='培根蔬菜堡:BAAAKgAECgEIAQAAAA==.',['堕落']='堕落的毁灭:BAABKgAECn8WAAIPAAgIXxMRDQCqAQAPAAgIXxMRDQCqAQAAAA==.',['夕丨']='夕丨丨四:BAABKgAECn8eAAMZAAgIsQ4RNwDsAAAZAAgIuQwRNwDsAAACAAgICwpLfwDmAAAAAA==.',['夕丶']='夕丶四夫人:BAABKgAECn8nAAQaAAgIXBo0TwDEAQAaAAgIEhk0TwDEAQAWAAUIzhUzWwDoAAAbAAQIIRipFgCFAAAAAA==.',['夜丶']='夜丶以烽:BAABKgAECn8YAAMIAAgIVRSgKQCzAQAIAAgIVRSgKQCzAQAcAAgI4g1CdAA+AAABKgAFFAgIHgAPAFEhAA==.',['夜露']='夜露:BAAAKgAECgQIDAAAAA==.',['大刘']='大刘君:BAAAKgADCgEIAQAAAA==.',['大象']='大象希声:BAAAKgADCggICgAAAA==.',['天神']='天神下凡:BAAAKgAECgcIBwAAAA==.',['夯敦']='夯敦敦:BAAAKgADCgEIAQAAAA==.',['夳氼']='夳氼:BAABKgAECn8YAAIZAAgIggVxRQCnAAAZAAgIggVxRQCnAAAAAA==.',['奥瑞']='奥瑞西亚:BAAAKgAFFAQIBAABKgAFFAgIBgACAB0dAA==.',['奶牛']='奶牛没奶出:BAAAKgAECgUIBQAAAA==.',['奶糖']='奶糖布丁:BAABKgAECn8aAAMaAAgIpRRfQQChAQAaAAgIpRRfQQChAQAWAAMIlAtjawCAAAAAAA==.',['妳微']='妳微笑時好美:BAABKgAFFH8SAAMSAAgIHhjEAwAYAgASAAgIGxXEAwAYAgATAAYIPRJ0DQB5AQAAAA==.',['娟娃']='娟娃子:BAAAKgADCgEIAQAAAA==.',['安德']='安德鲁:BAAAKgAECgQIBAAAAA==.',['安捷']='安捷伦:BAABKgAFFH8FAAMWAAIIlg0EQgBzAAAWAAIIlg0EQgBzAAAaAAIIiQX0VQBVAAAAAA==.',['安静']='安静的跳跳僧:BAAAKgADCggICQAAAA==.',['小叮']='小叮松比:BAAAKgAECgMIAwAAAA==.',['小可']='小可爱牛牛:BAAAKgAFFAIIAgAAAA==.',['小太']='小太阳:BAAAKgADCgcIBwAAAA==.',['小德']='小德了德:BAAAKgADCggICAAAAA==.',['小甜']='小甜橙:BAABKgAFFH8FAAINAAUIRwaTEwA5AQANAAUIRwaTEwA5AQAAAA==.',['小菠']='小菠萝:BAAAKgAECgcIBwAAAA==.',['小萝']='小萝卜头:BAAAKgAECgUIBQAAAA==.',['小蝌']='小蝌蚪长大了:BAAAKgAECgEIAQAAAA==.',['小龙']='小龙了龙:BAAAKgAECggICAAAAA==.',['山风']='山风眷眷:BAACKgAFFH8vAAINAAgIax19AwA6AgANAAgIax19AwA6AgAqAAQKfx0AAg0ACAjGHIAfABkCAA0ACAjGHIAfABkCAAAA.',['左手']='左手已致残:BAAAKgAECgMIAQAAAA==.',['巴洛']='巴洛克:BAAAKgADCgIIAwAAAA==.',['布德']='布德鸟:BAAAKgAFFAMIAwAAAA==.',['希望']='希望圣歌:BAAAKgAECgMIAwAAAA==.',['延静']='延静西里:BAAAKgAECgUIBQAAAA==.',['影歌']='影歌:BAAAKgADCgMIAwAAAA==.',['彼岸']='彼岸幽茗:BAABKgAFFH8LAAICAAYI4Rs8CwARAQACAAYI4Rs8CwARAQABKgAFFAgIBgAYAOUQAA==.',['微微']='微微小风行者:BAABKgAFFH8IAAIZAAgIegqkBQB4AQAZAAgIegqkBQB4AQAAAA==.',['德尔']='德尔丽斯塔奇:BAABKgAFFH8KAAIGAAgIfB/kAQCdAgAGAAgIfB/kAQCdAgAAAA==.',['德胜']='德胜再临:BAAAKgAECggICAAAAA==.',['忆秋']='忆秋年:BAAAKgADCgEIAQAAAA==.',['思绵']='思绵绵而增慕:BAAAKgADCggICAAAAA==.',['恐惧']='恐惧中毁灭:BAABKgAFFH8IAAMHAAQI5h/UAgAhAQAHAAQI5h/UAgAhAQAGAAQInhamEQDfAAAAAA==.',['悠哉']='悠哉划水:BAAAKgAECgQICAAAAA==.',['情义']='情义丶:BAABKgAECn8bAAMPAAgI/ByDGgDfAQAPAAgIZxuDGgDfAQAMAAYIjB49KgCxAQABKgAFFAgIDAAXAE8iAA==.',['我是']='我是小闪电:BAAAKgADCggICAABKgAECgYIBgAEAAAAAA==.',['战无']='战无不胜:BAAAKgADCggICAAAAA==.战无天:BAABKgAFFH8KAAMPAAYI2A6yDQC9AAAdAAYIfwdRFgAAAQAPAAQItxOyDQC9AAAAAA==.',['打猎']='打猎:BAAAKgAFFAIIAwAAAA==.',['拉钩']='拉钩不说谎:BAAAKgAFFAEIAQAAAA==.',['撑住']='撑住奶来了:BAAAKgAFFAUIBAAAAA==.',['旋转']='旋转虾:BAAAKgAECgMIAwAAAA==.',['旺仔']='旺仔球球糖:BAAAKgAFFAYIAgAAAA==.',['明哲']='明哲:BAAAKgAFFAMIAgAAAA==.',['明天']='明天不减肥:BAAAKgAFFAQIBAAAAA==.',['星仔']='星仔:BAAAKgAECgQIBwAAAA==.',['星橙']='星橙:BAAAKgAFFAEIAQAAAA==.',['是正']='是正经骑士:BAACKgAFFH8IAAIRAAIICwOTPgBUAAARAAIICwOTPgBUAAAqAAQKfyUAAxEACAgJDLdIAOQAABEACAgJDLdIAOQAABAABAiMAnxbABwAAAAA.',['晚笛']='晚笛:BAAAKgAFFAYIAwAAAA==.',['晴时']='晴时霁无霞:BAAAKgADCgEIAQAAAA==.',['暗夜']='暗夜牧奶伊:BAAAKgADCggICAABKgAFFAgIIAAJADMhAA==.',['暴怒']='暴怒的阿昆达:BAABKgAFFH8GAAMGAAYI4AvBEgADAQAGAAQIYA7BEgADAQAFAAII4QFyGQAwAAAAAA==.',['最佳']='最佳情人:BAAAKgADCggICAAAAA==.',['最后']='最后一口乃:BAAAKgAECgQIBAAAAA==.',['月似']='月似琉璃:BAABKgAFFH8IAAMGAAYIqA3oFQBUAQAGAAUIqA3oFQBUAQAFAAIIaANOLwA8AAAAAA==.',['末日']='末日狂牛:BAAAKgAECgcICwAAAA==.',['朵利']='朵利的朵特:BAAAKgAECgIIAgAAAA==.',['极寒']='极寒之风:BAAAKgADCgMIAwAAAA==.',['枝哥']='枝哥:BAABKgAFFH8LAAMWAAgISRfoEABeAQAWAAYIVRboEABeAQAaAAUIphcPFABVAQAAAA==.',['柑蕉']='柑蕉桔梨籮柚:BAABKgAFFH8WAAMaAAYIOSA0CQDgAQAaAAYIOSA0CQDgAQAWAAQIBAvPEgDJAAAAAA==.',['格兰']='格兰蒂捏:BAAAKgADCgYIBgAAAA==.',['桔子']='桔子不红:BAAAKgADCggICAAAAA==.',['楚悬']='楚悬黎:BAABKgAFFH8IAAMLAAYIoRkCAgDEAQALAAYIoRkCAgDEAQAJAAII6hfVFQCTAAAAAA==.',['樱桃']='樱桃不甜:BAAAKgADCggICAAAAA==.',['止于']='止于初见:BAAAKgAFFAQIBAAAAA==.',['步履']='步履不停:BAABKgAECn8kAAICAAgIYRpqCAAWAgACAAgIYRpqCAAWAgAAAA==.',['武之']='武之禅:BAABKgAECn8qAAMeAAgIKhWHDACDAQAeAAgIABOHDACDAQAcAAgI1hGkGQDSAAAAAA==.',['死老']='死老太婆:BAAAKgAECggICQAAAA==.',['死骑']='死骑魔:BAAAKgAFFAYIBAAAAA==.',['沃德']='沃德发:BAACKgAFFH8MAAMaAAQI0w7IJgC2AAAaAAQIvQnIJgC2AAAWAAIIHw13HACKAAAqAAQKfxoAAxoACAj2Gl5BAPMBABoACAglGl5BAPMBABYABAjjGExSANMAAAAA.',['沉默']='沉默不是懦弱:BAAAKgADCgQIBAAAAA==.',['泡灬']='泡灬椒:BAAAKgAFFAIIAgAAAA==.',['洛汉']='洛汉:BAAAKgAECgEIAQAAAA==.',['温蕾']='温蕾萨:BAABKgAFFH8JAAMaAAUIDArVFQDfAAAaAAUIGAfVFQDfAAAbAAQIkAp7AwC5AAAAAA==.',['湛蓝']='湛蓝:BAAAKgAFFAgIAQAAAA==.',['溜溜']='溜溜球儿:BAABKgAFFH8OAAINAAgIyRE2BgDsAQANAAgIyRE2BgDsAQAAAA==.',['潸然']='潸然乄淚下:BAAAKgAFFAEIAQABKgAFFAgILQAJADsVAA==.',['灬无']='灬无灬聊灬:BAAAKgAECggIEQAAAA==.',['烈女']='烈女不怕死:BAACKgAFFH8vAAMSAAgIGiBNAgBpAgASAAgIGiBNAgBpAgATAAMIiRfUHACjAAAqAAQKfy8AAxIACAiNIxkQADsCABIABwjIIhkQADsCABMABwitII0mAPUBAAAA.',['熊本']='熊本熊:BAAAKgAECgYICQAAAA==.',['熊猫']='熊猫爱吃虾:BAAAKgAECgEIAQABKgAECgYIBgAEAAAAAA==.',['燕三']='燕三少:BAAAKgAECgYIBgABKgAFFAgIHgAPAFEhAA==.',['爱俞']='爱俞利:BAABKgAFFH8GAAIcAAMIOg7wDADDAAAcAAMIOg7wDADDAAAAAA==.',['爱吃']='爱吃柚子:BAAAKgAECggIDgAAAA==.爱吃炸鸡:BAAAKgAECgIIAgAAAA==.爱吃香菜:BAAAKgADCggICAAAAA==.',['爱在']='爱在七块钱:BAABKgAFFH8SAAQRAAYIVR+2GACXAQARAAYIVR+2GACXAQAfAAUIHA6/CQAMAQAQAAYIJQNJGgCmAAAAAA==.爱在两块钱:BAABKgAFFH8IAAIXAAYIZxgQFAB6AQAXAAYIZxgQFAB6AQAAAA==.',['狐依']='狐依依:BAAAKgAECgYIDAAAAA==.',['玖月']='玖月贰拾壹:BAAAKgADCggICQAAAA==.',['珊妮']='珊妮当空照:BAAAKgAFFAIIAgAAAA==.',['珍珍']='珍珍是我:BAABKgAFFH8HAAIRAAcI8BxmDAAGAgARAAcI8BxmDAAGAgAAAA==.',['瑾年']='瑾年丨哈克:BAAAKgAECggIEgAAAA==.',['璃洛']='璃洛:BAAAKgAECgIIAgAAAA==.',['町风']='町风德雨:BAAAKgADCgMIAwAAAA==.',['疯标']='疯标:BAAAKgAECgIIAgAAAA==.',['白菜']='白菜还来了:BAAAKgAECgYIBgAAAA==.',['盈浦']='盈浦三霸:BAABKgAFFH8GAAIaAAQIrxKTHwDZAAAaAAQIrxKTHwDZAAAAAA==.',['眳哲']='眳哲:BAAAKgAECgMIAwAAAA==.',['眼娃']='眼娃:BAAAKgAFFAQIBAAAAA==.',['眼睛']='眼睛瞎了:BAAAKgAECggICAAAAA==.',['破碎']='破碎的承诺:BAAAKgADCgUIBQAAAA==.破碎行者:BAAAKgADCggICgAAAA==.',['神密']='神密嘉嘉:BAACKgAFFH8uAAMPAAcIhxkTAwDWAQAPAAcIhxkTAwDWAQAMAAUINRRWFwAqAQAqAAQKfzUAAw8ACAgiJpUGANgCAA8ACAgiJpUGANgCAAwAAgiHGINxAI4AAAAA.',['神话']='神话灬夏沫:BAABKgAFFH8IAAINAAgIoAQOCwCWAQANAAgIoAQOCwCWAQAAAA==.',['秀水']='秀水无痕:BAACKgAFFH8iAAIYAAQI5B5JEwAFAQAYAAQI5B5JEwAFAQAqAAQKf14AAhgACAiZJLgEALkCABgACAiZJLgEALkCAAAA.秀水无痕二世:BAABKgAECn8VAAINAAgIDBJeHgA9AQANAAgIDBJeHgA9AQAAAA==.',['秋水']='秋水仙碱:BAAAKgAFFAEIAQAAAA==.',['空栾']='空栾:BAAAKgAECggICAAAAA==.',['空條']='空條承太郎:BAACKgAFFH8fAAIDAAQIHxCuCgCjAAADAAQIHxCuCgCjAAAqAAQKfxYAAgMABgjKFhMmAEoBAAMABgjKFhMmAEoBAAAA.',['窜西']='窜西大王:BAAAKgADCgcIBwAAAA==.',['筱筱']='筱筱小德:BAAAKgAECgcIBwAAAA==.筱筱小狐:BAAAKgAFFAMIAwAAAA==.筱筱小骑:BAABKgAFFH8IAAIRAAgIoSBrBACMAgARAAgIoSBrBACMAgAAAA==.',['箭鬼']='箭鬼:BAAAKgAECgEIAQAAAA==.',['粗壮']='粗壮壮:BAACKgAFFH8bAAMOAAMIlxXoEwDMAAAOAAMIlxXoEwDMAAANAAMIVBPdLgC8AAAqAAQKfx4AAg0ACAgKHx4qAOMBAA0ACAgKHx4qAOMBAAAA.',['素还']='素还真丶:BAAAKgAECgYIBgAAAA==.',['纳兰']='纳兰帅哥:BAABKgAFFH8JAAIBAAMIDAkiNACwAAABAAMIDAkiNACwAAAAAA==.',['终结']='终结一箭:BAAAKgAECggIDgAAAA==.',['绝世']='绝世狂战:BAABKgAECn8WAAITAAgIYRl+IwAFAgATAAgIYRl+IwAFAgAAAA==.',['绝对']='绝对咬卵匠:BAAAKgAECgQIBQAAAA==.',['绿肤']='绿肤兜兜:BAABKgAFFH8RAAINAAUIdh0UFgArAQANAAUIdh0UFgArAQAAAA==.',['翘豚']='翘豚嘟嘟:BAAAKgAECgUIBQAAAA==.翘豚波比:BAAAKgAECgUICQAAAA==.',['老牛']='老牛驯兽师丶:BAAAKgAECgEIAQAAAA==.',['肥米']='肥米滴狐狐:BAACKgAFFH8GAAINAAIIfxxIIACXAAANAAIIfxxIIACXAAAqAAQKfxwAAg0ACAjnHCIiAAsCAA0ACAjnHCIiAAsCAAAA.',['胃卜']='胃卜鲜汁:BAAAKgAECgcICgAAAA==.',['胖包']='胖包:BAAAKgAFFAgIBAAAAA==.',['胖达']='胖达人:BAAAKgADCggICQAAAA==.',['胡工']='胡工:BAAAKgADCggICAAAAA==.',['脆弱']='脆弱的身板:BAAAKgAECggICAAAAA==.',['脚踢']='脚踢假面熊:BAAAKgAFFAYIAgAAAA==.',['自闭']='自闭:BAAAKgAECggICAAAAA==.',['芋圆']='芋圆葡萄:BAAAKgAECgQIBQAAAA==.',['芝士']='芝士墨鱼烧:BAACKgAFFH8HAAIdAAUIshIkDwAdAQAdAAUIshIkDwAdAQAqAAQKfycAAwwACAhmIDoTAFsCAAwACAgLHjoTAFsCAB0ACAhTHDUQANcBAAEqAAUUCAgOABoAwB0A.',['芝麻']='芝麻哥:BAABKgAFFH8GAAIWAAYI9xcaEgBTAQAWAAYI9xcaEgBTAQAAAA==.芝麻烧饼:BAAAKgADCggICAAAAA==.',['花儿']='花儿丶飘飘:BAABKgAFFH8GAAMLAAIIEQ84IABjAAALAAIIEQ84IABjAAAJAAEIXg9gPwA6AAAAAA==.',['花生']='花生:BAAAKgAECggIDAAAAA==.',['苞娜']='苞娜:BAABKgAFFH8QAAICAAgIORmpAwBfAgACAAgIORmpAwBfAgAAAA==.',['萨了']='萨了也不满:BAAAKgAECgQIBgAAAA==.',['萨飒']='萨飒:BAAAKgAECgEIAQAAAA==.',['落与']='落与白露:BAABKgAFFH8IAAIQAAgIbAzoCAB2AQAQAAgIbAzoCAB2AQAAAA==.',['蕾丝']='蕾丝花边条纹:BAAAKgAECgYIBgAAAA==.',['虽远']='虽远必诛:BAAAKgAECgEIAQAAAA==.',['蛋天']='蛋天帝:BAABKgAFFH8IAAIUAAQITRlICAANAQAUAAQITRlICAANAQAAAA==.',['蜜之']='蜜之猎手:BAAAKgADCgEIAQAAAA==.',['血小']='血小牛:BAABKgAFFH8FAAIXAAQIbgOKJwCBAAAXAAQIbgOKJwCBAAAAAA==.',['血渍']='血渍:BAABKgAFFH8OAAIaAAgIiA/AGAA2AQAaAAgIiA/AGAA2AQAAAA==.',['血色']='血色黄昏:BAACKgAFFH8IAAMfAAUI0RyBBAABAQAfAAQIaB2BBAABAQARAAIIoA62hQBPAAAqAAQKfxkAAxEACAhbHLdXAPABABEACAhbHLdXAPABAB8ABggsJGMaAJMBAAAA.',['西瓜']='西瓜不甜:BAAAKgADCgYIBwAAAA==.西瓜西瓜:BAACKgAFFH8QAAMdAAQI1BU0HwDZAAAdAAQI1BU0HwDZAAAPAAEIAADWMAAAAAAqAAQKfxkAAh0ACAinGpowANoBAB0ACAinGpowANoBAAAA.',['西窗']='西窗:BAAAKgAECgcIBwAAAA==.',['要乐']='要乐奈:BAAAKgAECggIDwABKgAECggIHwAJAF8jAA==.',['观云']='观云丶端:BAACKgAFFH8MAAMWAAQIeSH9AwAzAQAWAAQIeSH9AwAzAQAaAAQIcgrxPwCfAAAqAAQKfxUAAxoACAiSH3oxAC4CABoACAiSH3oxAC4CABYABQhBCZtZALkAAAAA.',['詹姆']='詹姆斯:BAAAKgADCggICQAAAA==.',['试玩']='试玩近战:BAAAKgAECggICAAAAA==.',['请叫']='请叫我幽爷:BAAAKgADCggICAAAAA==.',['谢超']='谢超二号:BAAAKgAFFAQIBAAAAA==.',['谭天']='谭天钤元:BAAAKgAFFAgIBAAAAA==.',['超级']='超级婉婉:BAAAKgAFFAIIAgAAAA==.',['路過']='路過瑾年丶:BAABKgAFFH8GAAIBAAYIBQ8tFwBBAQABAAYIBQ8tFwBBAQAAAA==.',['身上']='身上有虾在爬:BAABKgAFFH8IAAQKAAQIKhKvHQCtAAAKAAQIDxCvHQCtAAAJAAMI9RZrGACFAAALAAEIXA5YJABMAAAAAA==.',['辰良']='辰良:BAABKgAFFH8KAAMWAAUIqRF5NACgAAAaAAIImRVkHwClAAAWAAQI9Q15NACgAAAAAA==.',['迈巴']='迈巴赫:BAAAKgAECgEIAQAAAA==.',['这是']='这是小德:BAAAKgADCgMIAwAAAA==.',['迷失']='迷失之泪:BAABKgAFFH8FAAILAAUIdg8vBwA5AQALAAUIdg8vBwA5AQAAAA==.',['逍遥']='逍遥丶騎:BAAAKgAFFAYIBAAAAA==.',['遗忘']='遗忘影之伤:BAAAKgADCgQIBAAAAA==.',['那武']='那武僧:BAAAKgAECgMIAwAAAA==.',['邪魅']='邪魅一笑丶:BAAAKgAECgQIBAAAAA==.',['酒翁']='酒翁:BAAAKgAECgQIBAAAAA==.',['酒醉']='酒醉误事:BAAAKgAECgUIBQAAAA==.',['酒馆']='酒馆打烊了:BAAAKgADCgQIBAAAAA==.',['金坷']='金坷垃的逆袭:BAAAKgAECgYICQAAAA==.',['铜绿']='铜绿假单胞菌:BAABKgAFFH8MAAMZAAgINyTfAADkAgAZAAgINyTfAADkAgACAAQIURv1JwDuAAAAAA==.',['银姬']='银姬小蜡:BAAAKgADCggICAAAAA==.',['闪亮']='闪亮丶朵朵:BAAAKgAFFAIIAgAAAA==.',['阿丶']='阿丶拉蕾:BAAAKgAFFAYIBAABKgAFFAgIDwAKAM4XAA==.阿丶狸:BAAAKgADCggIGAAAAA==.',['阿泰']='阿泰尔:BAAAKgAECgEIAQAAAA==.',['阿米']='阿米子:BAABKgAFFH8KAAIGAAYIRSIpCQD6AQAGAAYIRSIpCQD6AQAAAA==.',['陈丶']='陈丶果冻布丁:BAABKgAECn8jAAMNAAgI5RhdEADLAQANAAgI5RhdEADLAQAUAAII6gWTRABCAAAAAA==.',['陪着']='陪着我家老熊:BAAAKgADCgQIBAAAAA==.',['雪姨']='雪姨:BAAAKgAFFAYIBAABKgAFFAgILgALAO0iAA==.',['霸都']='霸都才子:BAAAKgAECgMIBgAAAA==.霸都财子:BAACKgAFFH8PAAITAAMIxQpCJADAAAATAAMIxQpCJADAAAAqAAQKfyUAAhMACAhiFekgAMwBABMACAhiFekgAMwBAAAA.',['青竹']='青竹蜂云剑:BAAAKgADCgUIBQAAAA==.',['静灀']='静灀飞雪:BAAAKgAECgIIAgAAAA==.',['非布']='非布司他:BAAAKgAFFAYIBgAAAA==.',['风暴']='风暴狂涌:BAAAKgADCggICAAAAA==.',['饭岛']='饭岛小丶爱:BAACKgAFFH8HAAIRAAQIByHoEgAKAQARAAQIByHoEgAKAQAqAAQKfxwAAhEACAh+H2o6AD8CABEACAh+H2o6AD8CAAAA.',['香脆']='香脆大萝卜:BAAAKgAECgcIBwAAAA==.',['骑土']='骑土:BAAAKgAECgcICAAAAA==.',['鱼么']='鱼么么:BAABKgAECn8VAAMZAAgIDhMxGgCAAQAZAAgIDhMxGgCAAQACAAUI3geLkwCtAAAAAA==.',['鲜肉']='鲜肉小笼宝:BAAAKgAECgIIAgAAAA==.',['鹿森']='鹿森森丶:BAAAKgAFFAYIBAAAAA==.',['鹿茸']='鹿茸菌:BAAAKgAECgMIAwAAAA==.',['黑牛']='黑牛宝宝:BAACKgAFFH8mAAITAAQIhBRHHgDbAAATAAQIhBRHHgDbAAAqAAQKf0EAAhMACAgpHWgTAD4CABMACAgpHWgTAD4CAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end