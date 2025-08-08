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
 local lookup = {'Warlock-Destruction','Shaman-Enhancement','DemonHunter-Havoc','Paladin-Retribution','Druid-Balance','DeathKnight-Frost','Rogue-Assassination','Paladin-Protection','Unknown-Unknown','Hunter-Marksmanship','Shaman-Restoration','Paladin-Holy','Hunter-BeastMastery','Warrior-Fury','Warrior-Protection','Warrior-Arms','Mage-Frost','Druid-Restoration','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Demonology','Shaman-Elemental','Priest-Holy','Priest-Discipline','Priest-Shadow','Mage-Fire','Druid-Guardian','Mage-Arcane','DemonHunter-Vengeance','Evoker-Devastation','Monk-Windwalker','Monk-Mistweaver','Druid-Feral','Rogue-Subtlety','Monk-Brewmaster','Rogue-Outlaw',}; local provider = {region='CN',realm='奥拉基尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ae='Aether:BAABKgAFFH8MAAIBAAYIJhS/DAB6AQABAAYIJhS/DAB6AQAAAA==.',An='Anoluck:BAABKgAFFH8GAAICAAYIbg1nCQBAAQACAAYIbg1nCQBAAQAAAA==.',Bl='Blacksheep:BAAAKgAECgYIDQAAAA==.',Ca='Camellia:BAAAKgAECggICAAAAA==.',Cr='Crazyfu:BAABKgAFFH8GAAIDAAYIoA6CFgBGAQADAAYIoA6CFgBGAQAAAA==.',Fe='Felix:BAACKgAFFH8TAAIEAAQIXRn8EgAKAQAEAAQIXRn8EgAKAQAqAAQKfxwAAgQACAjsHwtJAOUBAAQACAjsHwtJAOUBAAAA.',Il='Illidarilord:BAAAKgADCgYIBgAAAA==.',Kn='Knowknow:BAAAKgAECggIDwAAAA==.',Li='Lilíth:BAAAKgAECggIEAAAAA==.',Ll='Llk:BAAAKgAECgUIBQAAAA==.Llsxjr:BAAAKgAECgYIBgAAAA==.',Lu='Luckymage:BAAAKgAECgEIAQAAAA==.Luda:BAAAKgAECggIDAAAAA==.',Ma='Madara:BAACKgAFFH8zAAIFAAgIAx2MBwAqAgAFAAgIAx2MBwAqAgAqAAQKfzMAAgUACAgMJvoRAJoCAAUACAgMJvoRAJoCAAAA.',Mo='Moretee:BAAAKgADCggICAAAAA==.',Na='Naughtymagic:BAAAKgAECgcIBwAAAA==.',Oc='Octfirst:BAAAKgAECgcICwAAAA==.',Pe='Penitent:BAAAKgADCggICAAAAA==.',Ra='Rainbowfish:BAAAKgAFFAQIBAAAAA==.Ranni:BAAAKgADCggIEAAAAA==.',Re='Rebirth:BAABKgAFFH8KAAIGAAYIZxhKAwCCAQAGAAYIZxhKAwCCAQAAAA==.',Ti='Tidey:BAAAKgADCggIDgAAAA==.',Va='Valky:BAABKgAECn8UAAIHAAUIDhQCEAAaAQAHAAUIDhQCEAAaAQAAAA==.',Ve='Vermilion:BAABKgAFFH8FAAIDAAUImQofIQD9AAADAAUImQofIQD9AAAAAA==.',Xi='Xiaoshuang:BAAAKgADCgEIAQAAAA==.',Za='Zaitsev:BAAAKgADCggICAAAAA==.',Zd='Zdlovelyzzq:BAAAKgAECggICgAAAA==.Zdloveyy:BAAAKgADCgIIAgAAAA==.',['一九']='一九八八:BAAAKgAECgMIAwAAAA==.',['一如']='一如一:BAAAKgAECggICQAAAA==.',['一射']='一射满天下:BAAAKgADCgIIAgAAAA==.',['一枚']='一枚咸鸭蛋:BAAAKgADCggICgAAAA==.',['一骑']='一骑丶绝尘:BAABKgAFFH8HAAMIAAQIQxbvGACwAAAIAAQIQxbvGACwAAAEAAEIGBwnTwBKAAAAAA==.',['七尺']='七尺指尖:BAAAKgAECggICwAAAA==.',['七段']='七段变身:BAAAKgAFFAgIAwAAAA==.',['七猫']='七猫人:BAAAKgAECgUIBgAAAA==.',['万古']='万古长存:BAABKgAFFH8UAAIDAAgIYx0RBgBPAgADAAgIYx0RBgBPAgAAAA==.',['三千']='三千院灬凪:BAAAKgADCgEIAQAAAA==.',['三笠']='三笠:BAABKgAFFH8QAAIDAAYIliBVAQD7AQADAAYIliBVAQD7AQAAAA==.',['不会']='不会玩的萝卜:BAAAKgAFFAYIBAAAAA==.不会瓦洛兰特:BAAAKgAFFAEIAQABKgAFFAQIAgAJAAAAAA==.',['不吃']='不吃拉面:BAAAKgAECggIDgAAAA==.',['不打']='不打无畏契约:BAAAKgAFFAQIAgAAAA==.',['不眠']='不眠的思念:BAABKgAFFH8GAAIKAAYI/BnxDgByAQAKAAYI/BnxDgByAQABKgAFFAgIDQAKALkfAA==.',['不肯']='不肯過江東:BAABKgAFFH8IAAIIAAQIOAeOEQB4AAAIAAQIOAeOEQB4AAAAAA==.',['不过']='不过些许风霜:BAABKgAFFH8GAAILAAYIfiOKBgDkAQALAAYIfiOKBgDkAQAAAA==.',['东方']='东方歌白:BAABKgAECn8YAAQMAAgIdRG5GgCQAQAMAAgIdRG5GgCQAQAEAAMIbgiJQgFqAAAIAAMIiAcrWgA5AAAAAA==.',['中年']='中年大叔:BAABKgAFFH8OAAINAAMIASXDHwAOAQANAAMIASXDHwAOAQAAAA==.',['丶小']='丶小姨:BAAAKgADCgEIAwAAAA==.',['丶浅']='丶浅梦:BAAAKgAECgcICAAAAA==.',['丶黑']='丶黑色的猫:BAABKgAFFH8SAAIDAAMI1iBHGwAlAQADAAMI1iBHGwAlAQAAAA==.',['举高']='举高高:BAAAKgADCgEIAQAAAA==.',['乂灬']='乂灬筱瑶:BAAAKgAECgYIBgAAAA==.',['之后']='之后:BAABKgAFFH8LAAIOAAYIKxcpEABSAQAOAAYIKxcpEABSAQAAAA==.',['乐吃']='乐吃点虾片:BAAAKgAECggICAAAAA==.',['九彡']='九彡叁:BAAAKgAECgEIAgAAAA==.',['也无']='也无风雨:BAABKgAFFH8IAAILAAQIBRDaOACfAAALAAQIBRDaOACfAAAAAA==.',['乱世']='乱世小牛:BAAAKgAECgUIBQAAAA==.',['乾隆']='乾隆:BAAAKgADCggICAAAAA==.',['二十']='二十四氪纯帅:BAAAKgAECgEIAQAAAA==.',['二玥']='二玥迷迭:BAAAKgAECgQIBwAAAA==.',['于利']='于利息:BAABKgAFFH8MAAMPAAYISAy8AQAyAQAQAAYIVQoNDQA+AQAPAAYIiwq8AQAyAQAAAA==.',['云岫']='云岫:BAAAKgAECgEIAQAAAA==.',['云鬼']='云鬼氵炎:BAAAKgADCgQIBAAAAA==.',['五月']='五月战歌:BAAAKgAECgEIAQAAAA==.',['五点']='五点五猫人:BAAAKgADCggICAAAAA==.',['今天']='今天又吃多了:BAAAKgAECggICAAAAA==.',['从霜']='从霜丶:BAAAKgAECggICgAAAA==.',['伊休']='伊休:BAAAKgAECgUICAAAAA==.',['伊裴']='伊裴尔塔尔:BAAAKgADCgQIBAAAAA==.',['伊达']='伊达雷尔:BAAAKgAECgEIAQAAAA==.',['会溜']='会溜达的萝卜:BAABKgAFFH8GAAMKAAYILBElGQCbAAAKAAIIOw0lGQCbAAANAAQIzRMAAAAAAAAAAA==.',['会玩']='会玩的萝卜:BAABKgAFFH8IAAIRAAQIBAtSGgCrAAARAAQIBAtSGgCrAAAAAA==.',['伸腿']='伸腿瞪眼丸:BAAAKgAECgEIAQAAAA==.',['似雨']='似雨若离:BAABKgAFFH8FAAIEAAMIDAKdPQBaAAAEAAMIDAKdPQBaAAAAAA==.',['何以']='何以圣光:BAACKgAFFH8GAAMIAAQIFQ1kHwCBAAAIAAQIWAxkHwCBAAAEAAIIiQhRSABpAAAqAAQKfxcAAgQACAgkIfxQAAACAAQACAgkIfxQAAACAAAA.',['你貌']='你貌似:BAAAKgAECgIIAgAAAA==.',['你都']='你都没葱高:BAAAKgAECgYIBgAAAA==.',['依然']='依然主宰:BAAAKgAFFAQIBAAAAA==.',['倔强']='倔强骑士:BAAAKgAECgcIBwAAAA==.',['倾城']='倾城一箭:BAABKgAFFH8WAAMKAAgIWBueAADaAQAKAAYIIiGeAADaAQANAAcITxWbDACmAQAAAA==.',['元素']='元素灬涌动:BAAAKgAECggICAAAAA==.',['光之']='光之圣骑:BAAAKgADCggICAAAAA==.',['光合']='光合作用咕:BAABKgAFFH8HAAISAAcIxQa8CgBaAQASAAcIxQa8CgBaAQAAAA==.',['光头']='光头太强:BAAAKgAECgcIDgAAAA==.',['光影']='光影宗师:BAAAKgAECggICAAAAA==.',['光明']='光明达雷:BAAAKgAECgQIBAAAAA==.',['光辉']='光辉之主:BAAAKgAECgQIBQAAAA==.',['关关']='关关小圣女:BAABKgAFFH8NAAIEAAYImSLGFgCmAQAEAAYImSLGFgCmAQABKgAFFAYIEAATAJslAA==.关关小妖女:BAABKgAFFH8QAAMTAAYImyXUCwDRAQATAAYImyXUCwDRAQAUAAQIFBSqDwDCAAAAAA==.关关小武女:BAABKgAFFH8GAAMOAAYINw+mEAD3AAAOAAQIzhKmEAD3AAAQAAII1AmcDAC1AAAAAA==.关关小裂女:BAAAKgAFFAMIAwABKgAFFAYIEAATAJslAA==.',['关羽']='关羽:BAACKgAFFH8PAAIEAAMIgyKNMAAmAQAEAAMIgyKNMAAmAQAqAAQKfywAAwQACAhLJM8dAKECAAQACAhLJM8dAKECAAgAAgj5AkJcADMAAAAA.',['冈拉']='冈拉美朵:BAABKgAECn8ZAAMBAAgIExZVMQCsAQABAAgIExZVMQCsAQAVAAIIoBDAZgBlAAAAAA==.',['冈格']='冈格尼尔:BAAAKgAECgMIAwAAAA==.',['冰夜']='冰夜灬救赎:BAAAKgAECgUICAAAAA==.',['冲田']='冲田丶总悟:BAAAKgADCgEIAQAAAA==.',['凯瑟']='凯瑟琳丶黛儿:BAAAKgAECgIIAQAAAA==.',['刁德']='刁德一:BAAAKgADCgIIAgAAAA==.',['刃影']='刃影杀:BAABKgAFFH8GAAIHAAYIUQt5DgBpAQAHAAYIUQt5DgBpAQAAAA==.',['刃星']='刃星:BAAAKgAFFAQIBAAAAA==.',['前世']='前世光明:BAAAKgAFFAQIBAAAAA==.',['前田']='前田敦子:BAAAKgAECggIEAAAAA==.',['勇敢']='勇敢地前进吧:BAAAKgAECgIIAgAAAA==.',['匆匆']='匆匆过客:BAABKgAFFH8cAAMOAAgIxiAWAgC3AgAOAAgIgSAWAgC3AgAQAAYIVhxiBgC1AQAAAA==.',['北原']='北原多香:BAABKgAFFH8GAAIEAAYI9hNzhgBMAAAEAAYI9hNzhgBMAAAAAA==.',['半夜']='半夜挠墙:BAAAKgAECgQIBgAAAA==.',['卖女']='卖女孩的小花:BAAAKgAECgMIAwAAAA==.',['卢克']='卢克天行者:BAAAKgAECgMIAwAAAA==.',['卢瑟']='卢瑟的小德:BAABKgAECn8UAAISAAgIgBAnEgBNAQASAAgIgBAnEgBNAQAAAA==.',['原天']='原天衣:BAABKgAFFH8GAAIEAAYI5B7FFwCeAQAEAAYI5B7FFwCeAQAAAA==.',['古手']='古手羽入灬:BAAAKgAECgEIAQAAAA==.',['叫叫']='叫叫:BAABKgAECn8WAAILAAgIgg2jUABNAQALAAgIgg2jUABNAQAAAA==.',['叫我']='叫我同学:BAAAKgAECggIDgAAAA==.叫我大聪明:BAAAKgADCggIDAAAAA==.',['可口']='可口香蕉:BAACKgAFFH8KAAIEAAQIfxcfSQDcAAAEAAQIfxcfSQDcAAAqAAQKfyMAAwQACAjBIZomAGYCAAQACAjBIZomAGYCAAgAAwglG6ASAOkAAAAA.',['叶无']='叶无道:BAAAKgAECgEIAQAAAA==.',['吥忍']='吥忍:BAABKgAECn8ZAAMBAAgI/xg7KwBtAQABAAcI/xg7KwBtAQAVAAEIAAB8igAAAAAAAA==.',['吥萌']='吥萌:BAAAKgAECgQICAAAAA==.',['听安']='听安:BAAAKgAECgcIEQAAAA==.',['吾入']='吾入歧途:BAAAKgAECgYICQAAAA==.',['咋都']='咋都行:BAABKgAFFH8IAAIKAAQIoBUKDgDiAAAKAAQIoBUKDgDiAAAAAA==.',['咒文']='咒文佩里尔:BAAAKgADCgEIAQAAAA==.',['咕咕']='咕咕之神丶:BAAAKgAECggICAAAAA==.',['咸鱼']='咸鱼:BAAAKgAFFAQIBAAAAA==.',['商鞅']='商鞅知马力:BAACKgAFFH8LAAILAAMISRkiJQDiAAALAAMISRkiJQDiAAAqAAQKfxcAAgsACAg8I34IAK0CAAsACAg8I34IAK0CAAAA.',['問天']='問天悟道:BAAAKgAECggIEwAAAA==.',['啦拖']='啦拖把:BAAAKgAFFAYIAwAAAA==.',['喵咪']='喵咪萌萌哒:BAAAKgADCggICAAAAA==.',['圆圆']='圆圆的毛毛:BAAAKgAECgUIBQAAAA==.',['圣光']='圣光之名:BAAAKgAFFAQIBAAAAA==.圣光之神丶:BAAAKgAFFAQIBAAAAA==.圣光凱瑟琳:BAAAKgADCgIIAgAAAA==.圣光好耀眼:BAAAKgAFFAYIBAAAAA==.圣光永存:BAAAKgAECgMIBgAAAA==.圣光老司机:BAAAKgAFFAYIAgAAAA==.',['圣兜']='圣兜:BAAAKgADCgEIAQAAAA==.',['圣堂']='圣堂:BAAAKgAECgYICwAAAA==.',['圣诞']='圣诞老人:BAAAKgAECgQICAAAAA==.',['地狱']='地狱使者:BAAAKgAECgEIAQAAAA==.',['坂田']='坂田丶银时:BAAAKgADCgEIAQAAAA==.',['壹曳']='壹曳之秋:BAAAKgADCgQIBAAAAA==.',['夜光']='夜光裤衩:BAAAKgAFFAIIAgAAAA==.',['夜天']='夜天使之苍月:BAABKgAFFH8HAAILAAQI8gyCNgCkAAALAAQI8gyCNgCkAAAAAA==.夜天使之苍羽:BAAAKgAFFAIIAgAAAA==.',['夜神']='夜神光辉:BAAAKgAFFAMIBAAAAA==.夜神小萨:BAABKgAFFH8FAAIWAAIIDRDGFwBRAAAWAAIIDRDGFwBRAAAAAA==.',['夜雨']='夜雨风华:BAABKgAFFH8FAAINAAQI7RmSEQAHAQANAAQI7RmSEQAHAQAAAA==.',['大奉']='大奉天:BAAAKgADCgEIAQAAAA==.',['大宗']='大宗师:BAAAKgAECggICAAAAA==.',['大爱']='大爱糖醋鱼:BAAAKgAFFAMIAwAAAA==.',['天使']='天使的残羽:BAAAKgAECgEIAQAAAA==.',['天干']='天干勿燥:BAAAKgAECgIIAwAAAA==.',['天王']='天王盖地胡:BAAAKgAECgMIAwAAAA==.',['太守']='太守:BAAAKgADCgMIAwAAAA==.',['奈洛']='奈洛归来:BAAAKgAECgEIAQAAAA==.',['奈烙']='奈烙:BAAAKgADCgcIBwAAAA==.',['奈萝']='奈萝:BAAAKgAFFAIIAgAAAA==.',['奥丶']='奥丶莫格莱尼:BAAAKgAFFAYIBAAAAA==.',['奥术']='奥术华尔滋:BAAAKgADCgQIBAAAAA==.',['奶萨']='奶萨蛮:BAAAKgAECgUICAAAAA==.',['奶香']='奶香小桔子:BAABKgAECn8VAAQXAAgICxqRIwDIAQAXAAcIFRuRIwDIAQAYAAUIAxIuTADkAAAZAAIItRMvXgA8AAAAAA==.',['如來']='如來神掌:BAAAKgADCgcIBwAAAA==.',['如是']='如是我闻:BAAAKgAECgYICgAAAA==.',['妞妞']='妞妞:BAAAKgAECgUIBQAAAA==.',['妩媚']='妩媚小妖精:BAABKgAFFH8cAAMEAAYIrhukCwAnAQAEAAYIrhukCwAnAQAMAAQIJh7aBAD8AAABKgAFFAgICQAIADAXAA==.妩媚小颖:BAAAKgAFFAQIBAAAAA==.',['威廉']='威廉配第:BAAAKgAECgYIBgAAAA==.',['嫵媚']='嫵媚小法:BAAAKgAFFAMIAwAAAA==.',['孙上']='孙上香:BAAAKgAECgYICAAAAA==.',['孟夢']='孟夢:BAABKgAFFH8dAAMOAAYISiCuBgAyAQAOAAYISiCuBgAyAQAQAAIInwlFIACOAAAAAA==.',['孤独']='孤独圣光:BAABKgAECn8bAAMIAAgI2Q58MwDLAAAEAAcIXA+svQDYAAAIAAgI7gZ8MwDLAAAAAA==.孤独帝潜:BAAAKgAECgQIBAAAAA==.孤独独:BAAAKgAECggIEgAAAA==.孤独的小笨贼:BAAAKgADCggIEAAAAA==.',['宇宙']='宇宙无限:BAACKgAFFH8FAAMGAAMIEAdJDQCkAAAGAAMIEAdJDQCkAAATAAII+wCGVAA8AAAqAAQKfxgABAYACAiuDrEYABYBAAYABwghD7EYABYBABQABggoCJg5AJsAABMAAQhLCb61ADAAAAAA.宇宙神射手:BAAAKgAFFAEIAQAAAA==.',['宝贝']='宝贝闹闹:BAAAKgAECgQIBQAAAA==.',['审判']='审判闪到腰:BAAAKgAECgYIBgAAAA==.',['寂静']='寂静烟花:BAAAKgAFFAEIAQAAAA==.',['寒江']='寒江月夜客:BAAAKgADCgQIBgAAAA==.',['寒泥']='寒泥巴:BAAAKgAECgQIBAAAAA==.',['寒风']='寒风之息:BAABKgAFFH8KAAITAAYIwBKLDAA7AQATAAYIwBKLDAA7AQAAAA==.',['寓清']='寓清于浊:BAAAKgAECgUIDAAAAA==.',['小凉']='小凉:BAAAKgAECgcICAAAAA==.',['小可']='小可乐的熊:BAAAKgAFFAYIAgAAAA==.小可酱:BAAAKgAECgEIAQAAAA==.',['小德']='小德最無德:BAAAKgAECgUIBQAAAA==.',['小手']='小手丶炽热:BAACKgAFFH8GAAIOAAMIqw72IQDLAAAOAAMIqw72IQDLAAAqAAQKfx0AAg4ACAjHG10QAJwBAA4ACAjHG10QAJwBAAAA.',['小月']='小月未央:BAAAKgAECgQIBAAAAA==.',['小梦']='小梦想家:BAAAKgADCgEIAQAAAA==.',['小猪']='小猪丶佩奇:BAABKgAFFH8GAAIaAAYIUxWXBgCbAQAaAAYIUxWXBgCbAQAAAA==.',['小王']='小王老师:BAAAKgADCgQIBAAAAA==.',['小矮']='小矮银:BAAAKgADCgMIAwAAAA==.',['小舒']='小舒淇:BAAAKgAFFAQIAwAAAA==.',['小迷']='小迷雾:BAABKgAFFH8IAAMNAAQIzRVRHADkAAANAAQIzRVRHADkAAAKAAQIHQ5UEQDSAAAAAA==.',['小酌']='小酌怡个情:BAAAKgAECgUIBQAAAA==.',['小钻']='小钻風:BAAAKgAFFAMIAwAAAA==.',['尐灬']='尐灬萌喵:BAAAKgAECgYICgAAAA==.尐灬萌熊:BAABKgAECn8ZAAQFAAgIIgkiiwDDAAAFAAgI5ggiiwDDAAASAAEIOwMhlwAYAAAbAAEIlQhTQwAXAAAAAA==.',['就是']='就是会立棍:BAAAKgAECgYIBgAAAA==.',['尾巴']='尾巴有点短:BAAAKgAECgYIBgAAAA==.',['屠日']='屠日者:BAACKgAFFH8VAAIOAAYIJBPuAQCwAQAOAAYIJBPuAQCwAQAqAAQKfyAAAg4ACAiRGX4qAI8BAA4ACAiRGX4qAI8BAAAA.',['左耳']='左耳刀:BAABKgAFFH8HAAMTAAQIIw8XIACkAAATAAMIARQXIACkAAAUAAQINATiKwBlAAAAAA==.',['已经']='已经结束嘞:BAAAKgAECgQIBQAAAA==.',['布弍']='布弍:BAABKgAFFH8KAAIcAAgIIhHYBwD/AQAcAAgIIhHYBwD/AQAAAA==.',['布皮']='布皮狼打工人:BAABKgAFFH8RAAISAAQIMAmIJwCHAAASAAQIMAmIJwCHAAAAAA==.',['幻灭']='幻灭华尔滋:BAAAKgADCgQIBAAAAA==.',['幽偌']='幽偌澜珊:BAAAKgAECgUIBgAAAA==.',['幽幽']='幽幽羽诺:BAAAKgAECgcIEgAAAA==.',['廿廿']='廿廿:BAABKgAFFH8GAAISAAMI5gKgLABqAAASAAMI5gKgLABqAAAAAA==.',['张可']='张可以:BAABKgAECn8fAAIEAAgI7CDLHwCDAgAEAAgI7CDLHwCDAgAAAA==.',['张师']='张师傅牛肉面:BAAAKgAECggICAAAAA==.',['张驰']='张驰一心:BAAAKgADCgQIBAAAAA==.',['影武']='影武者:BAAAKgAECgUIBQAAAA==.',['影舞']='影舞之殇:BAABKgAFFH8MAAIdAAMITxajDwDGAAAdAAMITxajDwDGAAAAAA==.',['影飛']='影飛舞:BAAAKgAFFAQIBAAAAA==.',['彳丶']='彳丶亍:BAAAKgAECgQIBAAAAA==.',['得不']='得不到就赖你:BAAAKgADCgUIBQAAAA==.',['微醺']='微醺岁月:BAAAKgAFFAYIBAAAAA==.',['德福']='德福:BAAAKgAFFAQIAwAAAA==.',['忘却']='忘却是种思念:BAAAKgADCggICAAAAA==.',['忘尘']='忘尘无忧:BAAAKgAFFAEIAQAAAA==.',['忘记']='忘记忧伤:BAAAKgAECgYIBwAAAA==.',['忽然']='忽然狠了:BAAAKgAFFAQIBAAAAA==.',['恶魔']='恶魔泰菲:BAAAKgADCggICAAAAA==.',['悠小']='悠小柒:BAAAKgAECgYIBwAAAA==.',['悲灵']='悲灵笑骨:BAAAKgAECgQIAgAAAA==.',['情义']='情义迅捷:BAAAKgAFFAIIAgAAAA==.',['慕容']='慕容宫詝:BAAAKgAECgUIBgAAAA==.',['懒小']='懒小二:BAABKgAECn8cAAMYAAgIZhAmLwA+AQAYAAgIZhAmLwA+AQAZAAQIage8YABwAAAAAA==.懒小呆:BAAAKgADCgEIAQAAAA==.懒小屁:BAAAKgADCgIIAgAAAA==.',['我喜']='我喜欢鹿管子:BAAAKgAECgIIAgAAAA==.',['我来']='我来组成歹匕:BAAAKgADCgIIAgAAAA==.我来组成鞭部:BAAAKgAECggIDQAAAA==.',['我真']='我真的没有奶:BAAAKgAFFAQIBAAAAA==.',['战国']='战国策:BAABKgAFFH8gAAIEAAUI6RniIADnAAAEAAUI6RniIADnAAAAAA==.',['战神']='战神之殿堂:BAAAKgAECgcIBwAAAA==.',['户山']='户山香橙:BAAAKgAFFAQIBAAAAA==.',['扎克']='扎克斯丶菲尔:BAAAKgADCgEIAgAAAA==.',['抓娃']='抓娃娃:BAABKgAECn8dAAIEAAgIKhtnGgDvAQAEAAgIKhtnGgDvAQAAAA==.',['抹茶']='抹茶小蛋糕:BAAAKgAECgcICgABKgAECggIFQAXAAsaAA==.',['拉達']='拉達曼迪斯:BAABKgAFFH8IAAIeAAgI1BjCBQBBAgAeAAgI1BjCBQBBAgAAAA==.',['拉面']='拉面没牛肉:BAAAKgADCggICAAAAA==.',['拔都']='拔都:BAAAKgADCggICAAAAA==.',['挽风']='挽风:BAABKgAECn8VAAIEAAgI5BrUFAAlAgAEAAgI5BrUFAAlAgAAAA==.',['提里']='提里奥布丁:BAABKgAECn8WAAIEAAYInhhAOwAeAQAEAAYInhhAOwAeAQAAAA==.',['文盲']='文盲小法:BAAAKgAECgYIDAAAAA==.',['文魁']='文魁:BAAAKgAECggICAAAAA==.',['斯旺']='斯旺汽水:BAAAKgAFFAMIAwAAAA==.',['方尖']='方尖碑:BAAAKgAECgIIAgAAAA==.',['施恶']='施恶:BAAAKgAECgEIAQAAAA==.',['旅行']='旅行树蛙:BAAAKgAFFAMIAwAAAA==.旅行雨蛙:BAAAKgAFFAMIAwAAAA==.',['日维']='日维睿:BAAAKgAECggIEgAAAA==.',['明月']='明月轻风语:BAAAKgADCgUIBQAAAA==.',['星坠']='星坠了无痕:BAABKgAECn8nAAIXAAgI/hhVIADCAQAXAAgI/hhVIADCAQAAAA==.',['星月']='星月靈:BAABKgAECn8jAAIFAAgI2h5wJQAvAgAFAAgI2h5wJQAvAgAAAA==.',['星驰']='星驰电:BAAAKgAECgIIAgAAAA==.',['晓花']='晓花:BAAAKgADCgEIAQAAAA==.',['晚街']='晚街丨听风:BAABKgAFFH8IAAIBAAMI7gXaHgCPAAABAAMI7gXaHgCPAAAAAA==.晚街听风:BAAAKgADCgQIBgAAAA==.',['暗兽']='暗兽战:BAAAKgAECgUIBQAAAA==.',['暗夜']='暗夜零:BAAAKgAECgEIAQAAAA==.',['暗杀']='暗杀丿辉煌:BAAAKgADCggICAAAAA==.',['暗血']='暗血夜:BAAAKgAECgEIAQAAAA==.',['暗言']='暗言:BAACKgAFFH8uAAQRAAgIJiOBAADSAgARAAgIBSOBAADSAgAcAAgIIB+5AgCcAgAaAAIIkQvLJgCGAAAqAAQKfycABBwACAg+JkwFAOICABwACAiAJEwFAOICABEABwhlJpgLAKcCABoAAghJIWwzAJ8AAAAA.',['暮色']='暮色下的回忆:BAAAKgAECgIIAgAAAA==.',['暴风']='暴风烈焰:BAAAKgADCgcIBwAAAA==.暴风猎手:BAAAKgAECgEIAQAAAA==.',['有尸']='有尸必有德:BAABKgAFFH8PAAIbAAMIvxgBBQDNAAAbAAMIvxgBBQDNAAAAAA==.',['末日']='末日星辰:BAAAKgAECgQIBAAAAA==.',['李云']='李云鹤:BAAAKgAECgcIDAAAAA==.',['村雨']='村雨:BAAAKgAECgEIAQAAAA==.',['杨小']='杨小五的春天:BAAAKgAECgQIBAAAAA==.杨小四:BAAAKgAECgEIAQAAAA==.',['東風']='東風谷早苗:BAABKgAFFH8RAAQaAAYIDyJ1BwCNAQAaAAYIlg51BwCNAQAcAAUIwyGRFwAnAQARAAYIPhXsCQAmAQAAAA==.',['枫千']='枫千雪:BAABKgAFFH8QAAMQAAYIIRtsAgCFAQAQAAUIdB1sAgCFAQAOAAUIDBf5AwBnAQAAAA==.',['枫铮']='枫铮:BAAAKgAECgUIBwAAAA==.',['柚子']='柚子柚子丶:BAAAKgAECgUIBgAAAA==.',['根基']='根基:BAAAKgAFFAMIAwAAAA==.',['梅森']='梅森凯瑟:BAAAKgADCggICAAAAA==.',['楼兰']='楼兰五香:BAABKgAFFH8OAAMfAAYIhAwwCgBBAQAfAAYIhAwwCgBBAQAgAAQIPB+uCgAPAQAAAA==.',['槲寄']='槲寄生:BAAAKgAECgYIDQAAAA==.',['橘落']='橘落淮南丶環:BAAAKgADCggIEAAAAA==.',['欧维']='欧维森林:BAAAKgAECgIIAwAAAA==.',['正义']='正义的化身:BAABKgAFFH8KAAIEAAgIhhfcCwALAgAEAAgIhhfcCwALAgAAAA==.正义的小夥伴:BAAAKgADCggICAAAAA==.',['死亡']='死亡之影:BAABKgAFFH8GAAIeAAYIzAOyGgDrAAAeAAYIzAOyGgDrAAAAAA==.死亡华尔滋:BAAAKgADCgUICgAAAA==.死亡灬痕:BAAAKgAECggICAAAAA==.',['死骑']='死骑士暗:BAABKgAECn8YAAITAAcIPw5AbwAWAQATAAcIPw5AbwAWAQAAAA==.',['毒藥']='毒藥丶蓝蔓藤:BAAAKgAECgMIBgAAAA==.',['氰灬']='氰灬岚:BAACKgAFFH8gAAIgAAQIkw8FIQCfAAAgAAQIkw8FIQCfAAAqAAQKfzMAAiAACAh/E/A1AHIBACAACAh/E/A1AHIBAAAA.',['永恒']='永恒的血牙:BAAAKgADCgQIBAAAAA==.',['汤姆']='汤姆没了杰瑞:BAAAKgAECgIIAgAAAA==.',['沙加']='沙加:BAABKgAFFH8GAAIBAAYIphW6EwBoAQABAAYIphW6EwBoAQAAAA==.',['没行']='没行医资格证:BAAAKgAFFAIIBAAAAA==.',['法宝']='法宝:BAABKgAECn8WAAIRAAYIARYHMQA/AQARAAYIARYHMQA/AQAAAA==.',['泡果']='泡果奶:BAAAKgAFFAQIBAAAAA==.',['泰疯']='泰疯:BAAAKgAECgcIDgAAAA==.',['泽爷']='泽爷:BAAAKgAFFAQIBAAAAA==.',['洋蛋']='洋蛋蛋:BAABKgAECn8WAAMVAAcIGxgGJQBvAQAVAAcIGxgGJQBvAQABAAMIYBLhjABxAAAAAA==.',['浓浓']='浓浓的奶香味:BAACKgAFFH8HAAIgAAIIYCEGFwDDAAAgAAIIYCEGFwDDAAAqAAQKfxcAAyAACAgEGnwaABYCACAACAgEGnwaABYCAB8ACAjIE1EmAG8BAAAA.',['浩劫']='浩劫华尔滋:BAAAKgADCgQIBAAAAA==.',['浮世']='浮世绘:BAABKgAFFH8GAAIcAAYIeBJzEgBTAQAcAAYIeBJzEgBTAQAAAA==.',['海盗']='海盗船头:BAAAKgAECgMIAwAAAA==.',['涅槃']='涅槃丶兰刺:BAABKgAFFH8HAAQSAAYI3hAjDQA5AQASAAQI2RIjDQA5AQAFAAIIowKkWwBEAAAhAAEIMAT+CQA+AAAAAA==.',['混沌']='混沌元始天尊:BAAAKgAECgYICAAAAA==.',['温大']='温大善人:BAABKgAECn8XAAIiAAgI1BLTEQDQAQAiAAgI1BLTEQDQAQAAAA==.',['湘峰']='湘峰:BAAAKgADCggIDAAAAA==.',['源流']='源流懐古:BAACKgAFFH8IAAMFAAMIYwV/RwCSAAAFAAMIYwV/RwCSAAASAAMIQASDKgB4AAAqAAQKfysAAwUACAhvFVNKAIQBAAUACAhvFVNKAIQBABIABwj6Dx00AB4BAAAA.',['滋润']='滋润:BAAAKgAECgIIAgAAAA==.',['滑翔']='滑翔:BAABKgAFFH8HAAIDAAQIHCGoCgAgAQADAAQIHCGoCgAgAQAAAA==.',['潘多']='潘多拉:BAABKgAFFH8IAAIgAAgI5h3ZAQBxAgAgAAgI5h3ZAQBxAgAAAA==.',['潪深']='潪深:BAABKgAFFH8KAAIfAAYIYxKCCABlAQAfAAYIYxKCCABlAQAAAA==.',['火焰']='火焰之主丶:BAAAKgAECgYIBgAAAA==.',['灬涵']='灬涵语灬:BAAAKgAECgEIAQAAAA==.',['灬筱']='灬筱海灬:BAAAKgAFFAMIAwAAAA==.',['灰爱']='灰爱:BAABKgAFFH8GAAICAAYIzBalBwATAQACAAYIzBalBwATAQABKgAFFAgIBAAJAAAAAA==.',['灵儿']='灵儿:BAABKgAECn8YAAIXAAgI7QLCcgCGAAAXAAgI7QLCcgCGAAAAAA==.灵儿丶:BAAAKgAECgQIBAAAAA==.',['灵战']='灵战八荒:BAAAKgAECggICAAAAA==.',['灵自']='灵自灵:BAAAKgAECgIIAgAAAA==.',['点缀']='点缀记忆:BAAAKgAECgEIAQAAAA==.',['烈火']='烈火丶歌:BAAAKgAECgUIBQAAAA==.',['烈酒']='烈酒之心:BAAAKgAFFAMIAwAAAA==.',['热百']='热百搭巧克力:BAAAKgAECggICgAAAA==.',['焦糖']='焦糖小蛋挞:BAAAKgAECgYICQABKgAECggIFQAXAAsaAA==.',['煞羽']='煞羽:BAABKgAECn8XAAMKAAgIfw+gTwDeAAAKAAgIfw+gTwDeAAANAAUIXQMo3gByAAAAAA==.',['熊灬']='熊灬样儿:BAAAKgAECgcICwAAAA==.',['熙玥']='熙玥:BAAAKgAFFAIIAgAAAA==.',['熠爆']='熠爆:BAAAKgADCgYIBgAAAA==.',['燕语']='燕语花沁:BAABKgAECn8fAAIXAAgIWyPUCQCJAgAXAAgIWyPUCQCJAgAAAA==.',['燚龖']='燚龖:BAAAKgAFFAIIAgAAAA==.',['爆橙']='爆橙的皮卡丘:BAAAKgAECgIIAgAAAA==.',['爱呀']='爱呀:BAABKgAFFH8IAAIBAAgIaxLJBQAYAgABAAgIaxLJBQAYAgAAAA==.',['爱喝']='爱喝点啤啤:BAAAKgAECgQIBAAAAA==.',['狂怒']='狂怒华尔滋:BAAAKgADCgIIAgAAAA==.',['狐狸']='狐狸萨满:BAAAKgADCgYIBgAAAA==.',['猛禽']='猛禽华尔滋:BAAAKgADCgMIAwAAAA==.',['玛雅']='玛雅圣光:BAAAKgADCgEIAQAAAA==.',['玩不']='玩不了了:BAAAKgAECgQIBgAAAA==.',['玩箭']='玩箭的小妹:BAAAKgADCgIIAgAAAA==.',['珍珠']='珍珠果酱:BAAAKgADCggICAAAAA==.',['琪开']='琪开得胜:BAAAKgAECgMIAwAAAA==.',['琳矢']='琳矢弓:BAAAKgADCggIDQAAAA==.',['甜甜']='甜甜妙嫣:BAAAKgADCggICAAAAA==.',['疃春']='疃春:BAAAKgAFFAQIBAAAAA==.',['白旋']='白旋风:BAAAKgAECgQIBAAAAA==.',['盾之']='盾之勇者丶:BAAAKgAFFAIIAgAAAA==.',['看我']='看我眼神:BAABKgAFFH8GAAITAAMIvxTzMQDMAAATAAMIvxTzMQDMAAAAAA==.',['真不']='真不缺德:BAAAKgAECgIIAgAAAA==.',['真神']='真神捞了:BAAAKgAECgQIBAAAAA==.',['知南']='知南而退:BAAAKgAECggICQAAAA==.',['破碎']='破碎灵魂:BAAAKgAFFAMIAgAAAA==.',['神化']='神化飞翼零:BAACKgAFFH8XAAIRAAMIGiBjCwASAQARAAMIGiBjCwASAQAqAAQKfzMAAhEACAjtID0QAH4CABEACAjtID0QAH4CAAAA.',['神密']='神密的神:BAAAKgADCgEIAQAAAA==.',['神灬']='神灬邪圣:BAABKgAFFH8KAAMEAAQIuiNRCQA0AQAEAAQIuiNRCQA0AQAMAAQIsQp2CQDFAAAAAA==.',['神荼']='神荼:BAAAKgAECgEIAgAAAA==.',['祸害']='祸害:BAAAKgAECggIDQAAAA==.',['离心']='离心纸土灵奶:BAAAKgAECgUIBQAAAA==.',['空山']='空山清雨:BAAAKgAECgQIBQAAAA==.',['空心']='空心橘子:BAAAKgADCggICAAAAA==.',['穿礼']='穿礼服的野猫:BAAAKgAECgMIBQAAAA==.',['第七']='第七封印:BAAAKgADCgMIAwAAAA==.',['箭追']='箭追风:BAAAKgADCgMIAwAAAA==.',['米晓']='米晓:BAAAKgAECgIIAgAAAA==.',['紫嫣']='紫嫣:BAABKgAFFH8GAAIUAAYIPhNXBwA1AQAUAAYIPhNXBwA1AQAAAA==.',['紫色']='紫色脆脆鲨:BAAAKgADCggICAAAAA==.',['經紀']='經紀人:BAAAKgADCggICAAAAA==.',['纽约']='纽约龙须面:BAABKgAFFH8iAAIeAAUIvxsFDwAkAQAeAAUIvxsFDwAkAQAAAA==.',['绘里']='绘里的小马尾:BAAAKgAECggIBgAAAA==.',['绚影']='绚影:BAABKgAECn8dAAIZAAgI/xZjJQBcAQAZAAgI/xZjJQBcAQAAAA==.',['美式']='美式冰咖啡:BAAAKgAFFAEIAQAAAA==.',['羽心']='羽心:BAAAKgAECgUICQAAAA==.',['羽纤']='羽纤:BAAAKgAECggICAAAAA==.',['翼人']='翼人之下:BAAAKgAECgMIAwAAAA==.',['老手']='老手冰凉:BAACKgAFFH8FAAIOAAQIsRMmHADkAAAOAAQIsRMmHADkAAAqAAQKfxoAAg4ACAgPCyohAOEAAA4ACAgPCyohAOEAAAAA.',['老秃']='老秃头:BAAAKgAECgEIAQAAAA==.',['老鸭']='老鸭:BAABKgAFFH8MAAMYAAgIvxngBAD2AQAYAAgIHg/gBAD2AQAXAAMIEyKPGgDmAAAAAA==.',['耐瑟']='耐瑟瑞尔:BAACKgAFFH8QAAMaAAQI0xIRGwDRAAAaAAQI0xIRGwDRAAARAAEINQlhLgAuAAAqAAQKfzUABBoACAjiE84WAIoBABEACAhREhk2AJcBABoACAjGEc4WAIoBABwAAQhZGuEpAE0AAAAA.',['背对']='背对圣光:BAAAKgAFFAYIAwABKgAFFAgIEgAIAOocAA==.',['胖熊']='胖熊没忍住:BAAAKgAECgIIAwAAAA==.',['自然']='自然之心:BAACKgAFFH8GAAISAAMI5hLWHwCsAAASAAMI5hLWHwCsAAAqAAQKfxoAAhIACAj6FZgiAIkBABIACAj6FZgiAIkBAAAA.',['舍命']='舍命不舍财:BAAAKgAFFAIIAwAAAA==.',['艾倩']='艾倩倩:BAAAKgAFFAMIAwAAAA==.',['艾斯']='艾斯乄德斯:BAABKgAFFH8OAAMNAAgIzg7KDQCVAQANAAgI1wvKDQCVAQAKAAQICRR6EADXAAAAAA==.',['艾洛']='艾洛恩:BAAAKgADCggICAAAAA==.',['芳名']='芳名千载何用:BAAAKgADCggICAAAAA==.',['苍蓝']='苍蓝星空:BAAAKgAECgIIAgAAAA==.',['苏七']='苏七:BAABKgAFFH8GAAIEAAYIlRfsMwAaAQAEAAYIlRfsMwAaAQAAAA==.',['英雄']='英雄説再见:BAAAKgADCggICAAAAA==.',['荆棘']='荆棘谷之星:BAAAKgAECgEIAQABKgAECgMIAwAJAAAAAA==.',['荷鲁']='荷鲁斯之眼:BAAAKgAECgIIAgAAAA==.',['莉莉']='莉莉丝灬:BAAAKgAFFAgIBAAAAA==.',['菲尔']='菲尔德:BAABKgAECn8UAAMgAAgIWhS9HACiAQAgAAgIWhS9HACiAQAjAAMIBQRAIQBCAAAAAA==.',['菲米']='菲米斯战锤:BAACKgAFFH8PAAIKAAMIzRWtKADHAAAKAAMIzRWtKADHAAAqAAQKfyMAAgoACAgDG1MkALcBAAoACAgDG1MkALcBAAAA.',['萨拉']='萨拉塔斯:BAACKgAFFH8IAAIXAAMI4BQuJgCqAAAXAAMI4BQuJgCqAAAqAAQKfxoAAxgACAjfFo08ACYBABcACAhuEkY5ADQBABgABghKE408ACYBAAAA.',['葡萄']='葡萄:BAAAKgAECgQIBgAAAA==.',['蓝天']='蓝天下的可乐:BAAAKgAECgEIAQAAAA==.',['蕾姆']='蕾姆我老婆:BAAAKgAECgYIBgAAAA==.',['蘑菇']='蘑菇炖提莫:BAAAKgADCggICQAAAA==.',['虚灵']='虚灵华尔滋:BAAAKgADCgQIBgAAAA==.',['虚空']='虚空之箭:BAABKgAFFH8GAAMKAAYIqwzZHAAKAQAKAAQIaQrZHAAKAQANAAIILxGfTwBtAAAAAA==.',['蚩尤']='蚩尤:BAABKgAECn8YAAMUAAgI0hvWEAArAgAUAAgI0hvWEAArAgATAAcIPQTmhADVAAAAAA==.',['蜗角']='蜗角虚名:BAAAKgAECgEIAQAAAA==.',['血与']='血与光荣:BAECKgAFFH8RAAMOAAMIKiCwDwD8AAAOAAMI7h2wDwD8AAAQAAMIGRrTFgDPAAAqAAQKf0UAAw4ACAgjJHMOAJICAA4ACAhPI3MOAJICABAABwheHz0WANoBAAAA.',['血影']='血影圣光:BAABKgAFFH8OAAIEAAYIsSATFgCrAQAEAAYIsSATFgCrAQAAAA==.',['西尔']='西尔芙:BAABKgAFFH8LAAMKAAYIxhVaJADcAAAKAAMIGxRaJADcAAANAAQI3xZ4MQDHAAAAAA==.',['譭丷']='譭丷灭:BAABKgAFFH8IAAIEAAQIzBXibACRAAAEAAQIzBXibACRAAAAAA==.',['让我']='让我来一刀:BAAAKgADCgYIBgAAAA==.',['诗酒']='诗酒趁年少:BAAAKgADCgIIAgAAAA==.',['该增']='该增肥了吧:BAABKgAFFH8GAAIIAAYI3RScBwBKAQAIAAYI3RScBwBKAQABKgAFFAgIBAAJAAAAAA==.',['谁言']='谁言重剑无锋:BAAAKgAECggICwAAAA==.',['豆包']='豆包不沾:BAAAKgAECgUIBQAAAA==.',['豆飞']='豆飞鸿:BAAAKgAECgUIBgAAAA==.',['贝利']='贝利亚邪影:BAAAKgAECgIIAgAAAA==.',['贪婪']='贪婪的冒险者:BAAAKgAECggICAAAAA==.',['赛亚']='赛亚牛妹:BAAAKgADCgYIBgAAAA==.赛亚狐人:BAAAKgADCgEIAQAAAA==.赛亚贼人:BAAAKgADCgYIBgAAAA==.赛亚野人:BAAAKgAECgMIAwAAAA==.',['赛莉']='赛莉斯冷:BAAAKgAFFAQIBAAAAA==.',['赤言']='赤言:BAAAKgAECgQIBAAAAA==.',['跟着']='跟着鹏哥混:BAABKgAFFH8GAAIDAAYIwRKdFQBNAQADAAYIwRKdFQBNAQAAAA==.',['辣个']='辣个戦士:BAAAKgAECgMIAwAAAA==.',['迪妮']='迪妮莎的微笑:BAAAKgADCgEIAQAAAA==.',['送信']='送信的胖子:BAAAKgADCgMIAwAAAA==.',['遥星']='遥星吻雨:BAAAKgADCggIAgAAAA==.',['邪之']='邪之勇者:BAABKgAFFH8FAAMTAAMIBwi8QQCXAAATAAMIugS8QQCXAAAUAAIIXgtrLgBXAAAAAA==.',['邪恶']='邪恶的葫芦娃:BAAAKgAECggIDgAAAA==.',['酋雷']='酋雷姆:BAAAKgAECgUIBQAAAA==.',['酣梦']='酣梦中的大鱼:BAAAKgAECgYIBgAAAA==.',['重生']='重生拿起键盘:BAAAKgAECgQIBAAAAA==.',['钢锁']='钢锁:BAABKgAFFH8FAAIkAAUIGxIJAwAPAQAkAAUIGxIJAwAPAQAAAA==.',['铁城']='铁城开锁王:BAAAKgADCgIIAgAAAA==.',['阿加']='阿加尔塔之风:BAACKgAFFH8GAAITAAIIyQXJKgByAAATAAIIyQXJKgByAAAqAAQKfyQAAhMACAiTGtkoABUCABMACAiTGtkoABUCAAAA.',['阿廖']='阿廖沙:BAAAKgAECgMIAwAAAA==.',['阿爾']='阿爾托利娅:BAAAKgAECgcIBwAAAA==.',['陈王']='陈王黄钺:BAAAKgADCgMIAwAAAA==.',['随缘']='随缘吧:BAABKgAECn8YAAIUAAgIlRq+GADTAQAUAAgIlRq+GADTAQAAAA==.',['随风']='随风逐影:BAAAKgAECgIIAgAAAA==.',['雨涟']='雨涟漪:BAAAKgAFFAQIBAAAAA==.',['雪夜']='雪夜月舞:BAAAKgAECggICAAAAA==.',['雷寻']='雷寻欢:BAAAKgAECgUIBwAAAA==.',['雷幻']='雷幻:BAAAKgADCggICwAAAA==.',['靈魂']='靈魂依托:BAABKgAECn8UAAMTAAgItxE6PgB6AQATAAgIiBA6PgB6AQAGAAMIkRqaLABiAAAAAA==.',['青柠']='青柠味脉动:BAAAKgADCgQIBAAAAA==.',['青莲']='青莲剑歌:BAABKgAFFH8KAAIBAAYIRSH9DQCtAQABAAYIRSH9DQCtAQAAAA==.',['静默']='静默雷暴:BAAAKgAECgIIAgAAAA==.',['鞑靼']='鞑靼姐姐:BAAAKgADCggICAAAAA==.',['风之']='风之第七章:BAABKgAFFH8OAAMaAAUIXCPJEAARAQAaAAUIeh3JEAARAQAcAAEIdCTWPwBaAAAAAA==.',['风暴']='风暴玫瑰丶:BAAAKgAECgIIAgAAAA==.',['风陵']='风陵渡:BAABKgAFFH8GAAIfAAYIug28CQBKAQAfAAYIug28CQBKAQAAAA==.',['飒冉']='飒冉:BAAAKgAECgMIAwAAAA==.',['香吉']='香吉:BAABKgAFFH8HAAIMAAMIRxHGCgCpAAAMAAMIRxHGCgCpAAAAAA==.',['马小']='马小萨萨:BAAAKgAFFAQIBAAAAA==.',['骑龟']='骑龟龟去逛街:BAAAKgAFFAMIAwAAAA==.',['鱼泡']='鱼泡泡的主人:BAAAKgAFFAQIBAAAAA==.',['鲤仔']='鲤仔:BAABKgAFFH8IAAMQAAYIzgxqDABHAQAQAAYIzgxqDABHAQAOAAIIQA+RKgBIAAAAAA==.',['鳳凰']='鳳凰鳴:BAACKgAFFH8WAAMFAAgIthwwCwAVAQAFAAgIthwwCwAVAQASAAEIxhZ1FgBNAAAqAAQKfxYAAxIACAhLI5MGAKwCABIACAhLI5MGAKwCABsACAimGcUHAAQCAAAA.',['黎明']='黎明灬圣光:BAAAKgAFFAEIAQAAAA==.',['黑火']='黑火:BAABKgAFFH8OAAMaAAQIJAqfIQCrAAAaAAQIoQafIQCrAAAcAAQItAhAHAChAAAAAA==.',['黑石']='黑石华尔滋:BAAAKgADCgMIAwAAAA==.',['黯沐']='黯沐丶:BAACKgAFFH8IAAIKAAMIqhTEKADHAAAKAAMIqhTEKADHAAAqAAQKfy0AAwoACAiPHlUZAC0CAAoACAiPHlUZAC0CAA0ABAgJFN6kANwAAAAA.',['齐天']='齐天晓圣:BAACKgAFFH8JAAIgAAgI8gz+BwC0AQAgAAgI8gz+BwC0AQAqAAQKfxgAAiAACAi7HCEVAD8CACAACAi7HCEVAD8CAAAA.',['龙傲']='龙傲天离心支:BAAAKgAECgUICAAAAA==.',['龙鳞']='龙鳞长铭渊:BAAAKgAFFAQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end