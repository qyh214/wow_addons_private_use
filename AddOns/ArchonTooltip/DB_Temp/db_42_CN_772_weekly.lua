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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Unholy','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Priest-Discipline','Shaman-Enhancement','Shaman-Elemental','DeathKnight-Frost','DeathKnight-Blood','Monk-Brewmaster','Rogue-Assassination','Evoker-Devastation','Monk-Mistweaver','DemonHunter-Vengeance','Priest-Holy','Priest-Shadow','Warrior-Protection','Druid-Balance','Druid-Restoration','Druid-Guardian','DemonHunter-Havoc','Mage-Frost','Mage-Fire','Monk-Windwalker','Unknown-Unknown','Shaman-Restoration','Paladin-Retribution','Warrior-Fury','Warrior-Arms','Mage-Arcane','Paladin-Protection','Paladin-Holy',}; local provider = {region='CN',realm='盖斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ca='Cassandra:BAABKgAECn8dAAMBAAgIDSafEwBcAgABAAYI4SSfEwBcAgACAAQINSZPXgA+AQAAAA==.',Cy='Cypily:BAAAKgADCgcIBwAAAA==.',De='Deathcg:BAABKgAFFH8GAAIDAAYIAgqgGwBAAQADAAYIAgqgGwBAAQAAAA==.Deco:BAABKgAECn8dAAQEAAgIDR07FwDtAQAEAAgIjho7FwDtAQAFAAMIEhgLZAB2AAAGAAEITRP6PQA7AAAAAA==.Demada:BAAAKgAFFAMIAQAAAA==.',Fa='Farshore:BAAAKgAECgEIAQAAAA==.',Fl='Flyingx:BAAAKgAECgYICAAAAA==.',Hl='Hlkho:BAAAKgADCgMIAwAAAA==.',Ii='Iiridescent:BAAAKgAFFAQIBAABKgAFFAgIGAAHAOgeAA==.',Ke='Keyoo:BAABKgAECn8VAAMIAAcImRnNEwDHAQAIAAcImRnNEwDHAQAJAAMIYwTQbwBFAAAAAA==.',Li='Lilgrave:BAAAKgADCggICQAAAA==.',Lu='Luciferss:BAABKgAECn8gAAIKAAgIshwACgAUAgAKAAgIshwACgAUAgAAAA==.',Ma='Maii:BAAAKgAFFAIIAwAAAA==.Maike:BAAAKgADCggIDQAAAA==.',Me='Meteoraa:BAAAKgAECgcIBwAAAA==.Meteoraao:BAABKgAECn8fAAMBAAgI3hwPFAAxAgABAAgI3hwPFAAxAgACAAYIvBGziwAXAQAAAA==.',Mi='Mikea:BAAAKgAECggICAAAAA==.',Mo='Moerae:BAAAKgADCggICAAAAA==.Moonx:BAAAKgAECgQIBAAAAA==.',Na='Navzul:BAABKgAFFH8GAAILAAUIRxKWGgCCAAALAAUIRxKWGgCCAAABKgAFFAgILAAMAKIPAA==.',Pe='Pescado:BAAAKgAECggIEwAAAA==.',Rc='Rce:BAAAKgAECgcIDQAAAA==.',Sh='Shadoow:BAABKgAFFH8KAAINAAYIZwpaCABoAQANAAYIZwpaCABoAQAAAA==.Shuri:BAAAKgAECggIDwAAAA==.',Ti='Tifa:BAAAKgAFFAIIAgAAAA==.',Ty='Tyana:BAABKgAFFH8PAAIEAAgI8B9mAgCiAgAEAAgI8B9mAgCiAgAAAA==.',['一撮']='一撮大胡子:BAAAKgAECgYIBgAAAA==.',['一脸']='一脸消魂丶:BAAAKgADCgYIBgAAAA==.',['三千']='三千焱炎火:BAAAKgADCgYIBgAAAA==.',['上课']='上课觉觉:BAAAKgAECggICQAAAA==.',['不再']='不再安静:BAABKgAECn8jAAIFAAcIcBvRHQCZAQAFAAcIcBvRHQCZAQAAAA==.',['不會']='不會起名字:BAABKgAFFH8LAAIBAAgIjxX2BAAuAgABAAgIjxX2BAAuAgAAAA==.',['丛步']='丛步圣光:BAAAKgAFFAIIAwAAAA==.',['丨三']='丨三尺青锋丨:BAAAKgAECgcIEgAAAA==.',['丶依']='丶依旧:BAAAKgADCggICAAAAA==.',['丶养']='丶养啥死啥:BAAAKgAFFAQIBAAAAA==.',['丶精']='丶精靈復甦:BAAAKgAFFAQIBAAAAA==.',['丶隐']='丶隐伤:BAAAKgAECgUICAAAAA==.',['丹阳']='丹阳殿下:BAAAKgAECggICAAAAA==.',['为爱']='为爱灬鼓掌:BAABKgAFFH8aAAIOAAgI6h2xBABQAgAOAAgI6h2xBABQAgAAAA==.',['乌萨']='乌萨奇:BAAAKgAECgEIAQAAAA==.',['乔若']='乔若:BAABKgAFFH8KAAIPAAYIehcvCgCHAQAPAAYIehcvCgCHAQAAAA==.',['九歌']='九歌丶湘君:BAAAKgADCgQIBAAAAA==.',['二少']='二少爺:BAAAKgADCggICgAAAA==.',['人面']='人面獸心:BAAAKgAECggICAAAAA==.',['众神']='众神谎言:BAABKgAFFH8GAAIDAAYIhh4PUABXAAADAAYIhh4PUABXAAABKgAFFAgIBgADAB0dAA==.',['传说']='传说中的三鞭:BAAAKgAFFAMIAwAAAA==.',['伱奏']='伱奏開:BAAAKgADCggICQAAAA==.',['你也']='你也想起舞吗:BAAAKgAFFAIIAgAAAA==.',['你头']='你头像真牛:BAAAKgAFFAIIAgAAAA==.',['你巳']='你巳经:BAAAKgADCgIIAgAAAA==.',['你愁']='你愁啥呢:BAAAKgAECgQIBAAAAA==.',['傲剑']='傲剑寒霜:BAACKgAFFH8WAAIQAAMI8gWsGwB3AAAQAAMI8gWsGwB3AAAqAAQKfyQAAhAACAibDQExAAEBABAACAibDQExAAEBAAAA.',['僧灬']='僧灬住:BAAAKgAFFAYIBAABKgAFFAgIDQADAPMWAA==.',['光影']='光影独行:BAABKgAFFH8SAAQRAAYImh70CABQAQARAAYIaBb0CABQAQAHAAQI5BWJEwDCAAASAAEILRhmIgBSAAAAAA==.',['其实']='其实我是蛋蛋:BAAAKgAECgQIBAAAAA==.',['冥茵']='冥茵:BAAAKgAECgEIAQAAAA==.',['冥音']='冥音:BAAAKgAECgIIAgAAAA==.',['冬莉']='冬莉:BAABKgAFFH8IAAITAAgI+gvTAwBmAQATAAgI+gvTAwBmAQAAAA==.',['冷之']='冷之追毅:BAACKgAFFH8GAAMSAAII1hDIIwBuAAASAAII1hDIIwBuAAARAAEIEQQcQQAvAAAqAAQKfy0AAxEACAj5FrcgANsBABEACAj5FrcgANsBABIACAjoEpwmAKEBAAAA.',['冷清']='冷清秋:BAAAKgADCggICAAAAA==.',['凝眸']='凝眸:BAAAKgAECggIDgAAAA==.',['创新']='创新高涨停:BAAAKgAECgEIAQAAAA==.',['北极']='北极熊先生:BAAAKgAECgcIEQAAAA==.',['卖萌']='卖萌小德:BAABKgAFFH8FAAMUAAMIhwZ6UwBpAAAUAAIIrQh6UwBpAAAVAAMI0gEBLQBoAAAAAA==.',['南苑']='南苑南阳:BAABKgAECn8YAAMUAAgIvh57JAAnAgAUAAgIvh57JAAnAgAWAAEImwSZRgANAAAAAA==.',['卡哇']='卡哇伊小车:BAAAKgAECggICAAAAA==.',['反者']='反者道之动:BAAAKgADCggICAABKgAFFAgICAAXANsSAA==.',['古德']='古德猫宁:BAAAKgADCggICAAAAA==.',['可可']='可可酱酱:BAAAKgAECgYICAAAAA==.',['叶随']='叶随风儿飘:BAAAKgADCgMIAwAAAA==.',['命运']='命运守护夜:BAAAKgAECggICAAAAA==.命运风华:BAAAKgADCgIIAgAAAA==.',['咕咕']='咕咕嘎嘎:BAAAKgAECgEIAQAAAA==.咕咕娘:BAAAKgADCgUIBQAAAA==.',['哀川']='哀川和彦:BAABKgAFFH8RAAIYAAMIcR6qCwAPAQAYAAMIcR6qCwAPAQAAAA==.',['問天']='問天可敢爲敌:BAAAKgADCggICAAAAA==.',['嗬这']='嗬这妞真美:BAAAKgAECgQIBAAAAA==.',['嗲宝']='嗲宝贝玲玲:BAAAKgADCgcICgAAAA==.',['嘿丶']='嘿丶那个妞:BAAAKgAECgMIAwAAAA==.',['四分']='四分五猎:BAABKgAFFH8MAAICAAYI/hD5DABoAQACAAYI/hD5DABoAQAAAA==.',['四灬']='四灬灬季:BAABKgAFFH8IAAMYAAYIWxXOBgBcAQAYAAYIWxXOBgBcAQAZAAIIoQT2OABPAAAAAA==.',['回眸']='回眸依旧:BAAAKgAECggIEQAAAA==.',['团长']='团长你缺德不:BAAAKgAFFAgIAgAAAA==.',['圆溜']='圆溜溜:BAABKgAFFH8FAAIaAAMIVgstFwCwAAAaAAMIVgstFwCwAAAAAA==.',['圆滚']='圆滚滚的雪球:BAAAKgAECgMIAwAAAA==.',['土灵']='土灵:BAAAKgAECgIIAgAAAA==.',['圣光']='圣光会庇护我:BAAAKgADCgQIBAABKgAECggIEwAbAAAAAA==.圣光老狐狸:BAAAKgAFFAQIBAAAAA==.圣光黑白花:BAAAKgAECgEIAQAAAA==.',['地狱']='地狱夫人:BAACKgAFFH8NAAMHAAgIqRZbBACwAQAHAAYIHB1bBACwAQARAAIIiwaIHAB0AAAqAAQKfyIAAwcACAhnFwwJAMQBAAcACAgJFgwJAMQBABEACAjFEnswAIEBAAAA.',['塞克']='塞克熊猫:BAACKgAFFH8eAAIcAAQIiiUyBAA/AQAcAAQIiiUyBAA/AQAqAAQKfxUAAhwACAi4I2gLAJsCABwACAi4I2gLAJsCAAAA.',['塮蕝']='塮蕝芶吲:BAAAKgADCgIIAwAAAA==.',['墨汐']='墨汐:BAAAKgADCgUIBQAAAA==.',['壹贰']='壹贰叁肆:BAAAKgADCgMIAQAAAA==.',['夜姬']='夜姬:BAAAKgAECgQIBAAAAA==.',['大哥']='大哥布林圣骑:BAAAKgAECgIIAgAAAA==.',['大山']='大山:BAAAKgAECgUIDwAAAA==.',['天丶']='天丶空:BAABKgAECn8UAAIDAAgIVxtqGwAzAgADAAgIVxtqGwAzAgAAAA==.',['天使']='天使依然:BAAAKgAFFAYIAwAAAA==.',['奶不']='奶不到:BAABKgAFFH8GAAIdAAYIbBa/EgByAQAdAAYIbBa/EgByAQAAAA==.',['奶油']='奶油慕思:BAAAKgAECgEIAQAAAA==.',['奶瓶']='奶瓶:BAAAKgAECgQIBAAAAA==.',['妮可']='妮可老大:BAAAKgAECgYIBwAAAA==.',['娅媚']='娅媚蝶:BAAAKgAFFAQIBAAAAA==.',['守护']='守护个大怪兽:BAABKgAECn8bAAICAAgIhgmnLAAcAQACAAgIhgmnLAAcAQAAAA==.',['小土']='小土豆丶:BAAAKgAFFAQIBAAAAA==.',['小奈']='小奈家姐:BAAAKgAFFAYIAgAAAA==.',['小小']='小小岩石:BAAAKgAECgIIAgAAAA==.',['小岩']='小岩石:BAAAKgADCgMIAwAAAA==.',['小漓']='小漓:BAABKgAFFH8SAAMRAAQIgBRGJgCpAAARAAQIgBRGJgCpAAAHAAMITQQ9JQCLAAAAAA==.',['小白']='小白入坑:BAAAKgAECgYIDAAAAA==.',['小萝']='小萝卜:BAAAKgAECgUIBQAAAA==.',['少侠']='少侠好功夫:BAAAKgADCgIIAgAAAA==.',['尚香']='尚香尚武:BAAAKgAFFAIIBAAAAA==.',['尤德']='尤德:BAAAKgADCgYICgAAAA==.',['尹志']='尹志平:BAAAKgAFFAYIAgAAAA==.',['岁月']='岁月神偷:BAAAKgAFFAQIBAAAAA==.',['岸然']='岸然辉煌:BAAAKgAECgEIAQAAAA==.',['左手']='左手倒影:BAAAKgAECgUIBAAAAA==.',['巴布']='巴布罗:BAAAKgAECgUIBQAAAA==.',['幻梦']='幻梦似泪:BAAAKgAECgIIAgAAAA==.',['幽幽']='幽幽黎歌:BAAAKgAECggICAAAAA==.',['开宝']='开宝马偷西瓜:BAAAKgADCggICAAAAA==.',['强力']='强力男:BAAAKgAECggICAAAAA==.',['影之']='影之殇:BAAAKgADCggICAAAAA==.',['很美']='很美味:BAAAKgAFFAQIBAAAAA==.',['得得']='得得撸:BAAAKgADCggICAAAAA==.',['從此']='從此退出江湖:BAAAKgAFFAIIAgAAAA==.',['御清']='御清风:BAAAKgAECgYIBgAAAA==.',['德闲']='德闲博野:BAAAKgADCggICAAAAA==.',['快乐']='快乐的小黑皮:BAAAKgAFFAIIAgAAAA==.',['想踹']='想踹人:BAAAKgAECgcIBwAAAA==.',['愛羅']='愛羅丶星矢:BAAAKgAECgIIAgAAAA==.',['愤怒']='愤怒的小牛灬:BAAAKgADCgMIAwAAAA==.',['我只']='我只是比较矮:BAABKgAFFH8GAAIeAAYIRRF+DACEAQAeAAYIRRF+DACEAQAAAA==.',['我头']='我头上有犄角:BAAAKgADCgQIBAAAAA==.',['我媳']='我媳妇欠揍:BAAAKgAECggICAAAAA==.',['我对']='我对那男孩说:BAAAKgADCgIIAgAAAA==.',['我想']='我想玩亚索:BAABKgAFFH8NAAMZAAgI0xjvBQAQAgAZAAgI0xjvBQAQAgAYAAMIyA13GgCqAAAAAA==.',['我是']='我是土灵:BAAAKgAECggIEQAAAA==.我是爱哭鬼:BAABKgAFFH8IAAIfAAcIlBOXBgCxAQAfAAcIlBOXBgCxAQAAAA==.',['我爱']='我爱百步穿杨:BAAAKgAECgEIAQAAAA==.',['我选']='我选择死亡:BAABKgAECn8TAAMYAAgI5CJ0CADFAgAYAAgI5CJ0CADFAgAgAAMI+gwScwCKAAAAAA==.',['或昱']='或昱或愚:BAACKgAFFH8ZAAIBAAQIcST1FAA7AQABAAQIcST1FAA7AQAqAAQKfx8AAgEACAikJFgCAN4CAAEACAikJFgCAN4CAAAA.',['戴子']='戴子玲:BAAAKgAECgUICgAAAA==.',['抓咕']='抓咕大队长:BAAAKgAECggICAAAAA==.',['抓大']='抓大鹅:BAAAKgADCgEIAQAAAA==.',['护佑']='护佑圣光:BAAAKgADCggICAAAAA==.',['放开']='放开那个萌叔:BAAAKgAECgYIDAAAAA==.',['救救']='救救妮妮吧:BAAAKgAFFAQIBAAAAA==.',['无灬']='无灬花果:BAAAKgAFFAgIAgAAAA==.',['星丶']='星丶白:BAAAKgAFFAEIAQAAAA==.',['星灬']='星灬矢:BAAAKgAFFAMIAwAAAA==.',['星际']='星际漫游:BAAAKgAFFAgIBAAAAA==.',['晓枫']='晓枫:BAAAKgADCgEIAQAAAA==.',['暴仔']='暴仔:BAAAKgADCggICAAAAA==.暴仔灬:BAAAKgADCggICAAAAA==.',['暴打']='暴打小姨妹:BAAAKgADCgMIAwAAAA==.',['月下']='月下小憩:BAACKgAFFH8GAAIYAAMIoA8vCwDVAAAYAAMIoA8vCwDVAAAqAAQKfycAAxgACAhdIT4NAJgCABgACAhdIT4NAJgCABkAAQgAAJKwAAAAAAAA.',['月隐']='月隐:BAAAKgAFFAIIAgAAAA==.',['望月']='望月拨星:BAAAKgAECggIDAAAAA==.',['木有']='木有眼睛:BAAAKgADCggICAAAAA==.',['木木']='木木丁丁:BAAAKgAECgUIBQAAAA==.木木哦:BAAAKgAFFAQIBAAAAA==.',['未来']='未来龙皇小蓝:BAAAKgAECgYIBgAAAA==.',['末把']='末把椅:BAAAKgAECgUIBQABKgAFFAgILAABAEsjAA==.',['极乐']='极乐净土:BAAAKgAECggIDgAAAA==.',['枫林']='枫林星语:BAAAKgAECgEIAQAAAA==.',['森羽']='森羽丶:BAAAKgAECgQIBAAAAA==.',['楚雨']='楚雨:BAAAKgAECgIIAgAAAA==.',['欢喜']='欢喜我仲要:BAAAKgADCgEIAQAAAA==.',['正义']='正义:BAAAKgADCgcIBwAAAA==.',['正正']='正正玲玲:BAAAKgADCgIIAgAAAA==.',['此去']='此去经年:BAABKgAFFH8GAAIBAAYIUhIsDABFAQABAAYIUhIsDABFAQAAAA==.',['殇丨']='殇丨灬優:BAAAKgAECgYIBgAAAA==.',['汤圆']='汤圆还是汤团:BAAAKgAECgYIDAAAAA==.',['沙滩']='沙滩之子:BAACKgAFFH8aAAMKAAMI6w9hCgDNAAAKAAMI6w9hCgDNAAADAAMIbgoxOgC0AAAqAAQKfzEAAwoACAgVHoAJAB8CAAoACAgCHoAJAB8CAAMACAg+F8k1ANoBAAAA.',['沙灬']='沙灬雕:BAAAKgADCgQIBAAAAA==.',['法王']='法王:BAAAKgADCggIDgAAAA==.',['泛滥']='泛滥的小青年:BAAAKgADCgIIAgAAAA==.',['泷泷']='泷泷恶姤:BAABKgAFFH8MAAIUAAQIFwZORACdAAAUAAQIFwZORACdAAAAAA==.',['浮生']='浮生若梦:BAAAKgAECgIIAgAAAA==.',['海龟']='海龟入水:BAAAKgAECgMIAwAAAA==.',['涂抹']='涂抹心情:BAAAKgAECgcIDwAAAA==.',['清一']='清一色自摸:BAAAKgAECggIDwAAAA==.',['清浅']='清浅:BAAAKgADCgEIAQAAAA==.',['温柔']='温柔的脸型:BAACKgAFFH8SAAIUAAQIswZIIwCeAAAUAAQIswZIIwCeAAAqAAQKfxcAAxQABAhLFaYqAAEBABQABAhLFaYqAAEBABUAAQjgAX2DABoAAAAA.',['温水']='温水流年:BAABKgAFFH8GAAIeAAYICBRfDQB6AQAeAAYICBRfDQB6AQAAAA==.',['潇潇']='潇潇渝雨玉:BAABKgAFFH8HAAIDAAcILRl5BwAaAgADAAcILRl5BwAaAgAAAA==.',['灬丨']='灬丨噬魂丨灬:BAAAKgADCgYIBwAAAA==.灬丨天机丨灬:BAABKgAFFH8aAAIcAAgIERySAwA2AgAcAAgIERySAwA2AgAAAA==.',['灬佐']='灬佐耳钉灬:BAAAKgADCgYIBgAAAA==.',['灬樱']='灬樱宫猫妖灬:BAAAKgAECgYICgAAAA==.',['灬無']='灬無丶趣:BAAAKgAECggIAgAAAA==.',['灬舞']='灬舞丨僧灬:BAAAKgADCgcIBwAAAA==.',['灼华']='灼华:BAAAKgAECgEIAQAAAA==.',['無窮']='無窮:BAAAKgAECgMIAwAAAA==.',['焦面']='焦面包:BAABKgAFFH8OAAMdAAYIQhMHDQAgAQAdAAQI1x8HDQAgAQAhAAYIQwmABgD8AAABKgAFFAgIBAAbAAAAAA==.',['熊阿']='熊阿赳赳:BAABKgAFFH8IAAIdAAQIVCXWBwA/AQAdAAQIVCXWBwA/AQAAAA==.',['熟手']='熟手啤胶员:BAAAKgAECgcIBgAAAA==.',['爷爷']='爷爷不泡茶:BAABKgAFFH8IAAIdAAgIyiGwBQB0AgAdAAgIyiGwBQB0AgAAAA==.',['独孤']='独孤战:BAAAKgAFFAMIAwAAAA==.独孤焕:BAAAKgAFFAMIBAAAAA==.',['狮之']='狮之红颜:BAAAKgADCgQIBAAAAA==.',['狸猫']='狸猫仙子:BAAAKgADCgMIAwAAAA==.',['猫仙']='猫仙:BAAAKgADCgMIAwAAAA==.',['玖玖']='玖玖捌拾壹:BAAAKgAFFAQIBAAAAA==.',['玛丽']='玛丽狗斯:BAAAKgAECggIDQAAAA==.',['玛露']='玛露西尔:BAAAKgAECgYICQAAAA==.',['瑞文']='瑞文她奶奶:BAAAKgAECgEIAQAAAA==.',['白日']='白日游魂:BAABKgAFFH8JAAIdAAMIaRNvJQDSAAAdAAMIaRNvJQDSAAAAAA==.',['白曰']='白曰游魂:BAAAKgAFFAEIAQAAAA==.',['白菜']='白菜根炒千张:BAAAKgAECgEIAQAAAA==.',['盖了']='盖了:BAAAKgAFFAQIBAAAAA==.',['知行']='知行明阳:BAAAKgADCggICAAAAA==.',['短腿']='短腿地板流:BAACKgAFFH8JAAMDAAUIkBDwNwC7AAADAAMIUQ7wNwC7AAALAAII7hOfJACGAAAqAAQKfxkAAgMACAgvGZciAAQCAAMACAgvGZciAAQCAAAA.',['碎星']='碎星拉塔恩:BAAAKgAECgEIAQAAAA==.',['神诺']='神诺:BAAAKgAECgIIAgAAAA==.',['禽牛']='禽牛感:BAAAKgADCgQIBAAAAA==.',['禾禾']='禾禾的老霸:BAAAKgAECgUIBQAAAA==.',['空欢']='空欢喜:BAAAKgAECggICAAAAA==.',['窝的']='窝的蝶:BAAAKgADCggICAAAAA==.',['米迦']='米迦勒之舞:BAAAKgADCgIIAgAAAA==.',['糊你']='糊你一脸:BAABKgAFFH8GAAIdAAYIPhwyIQBpAQAdAAYIPhwyIQBpAQAAAA==.',['糖朵']='糖朵朵:BAAAKgAECgYIBgAAAA==.',['红装']='红装素裹:BAAAKgAECggICAAAAA==.',['红颜']='红颜易老:BAAAKgAECgMIAwAAAA==.',['绝世']='绝世糖门:BAABKgAFFH8GAAIEAAYIjgWGHgAUAQAEAAYIjgWGHgAUAQAAAA==.',['缓冲']='缓冲:BAAAKgAECgIIAgAAAA==.',['缥缈']='缥缈:BAAAKgAECggICAAAAA==.',['网瘾']='网瘾老嘢:BAAAKgADCggICAAAAA==.',['美味']='美味鹌鹑:BAAAKgAECgEIAQAAAA==.',['老爹']='老爹:BAAAKgAFFAEIAQAAAA==.',['老贼']='老贼堃仔:BAAAKgADCgYICgAAAA==.',['聖光']='聖光裁決:BAAAKgAECgIIAgAAAA==.',['肝姐']='肝姐姐:BAAAKgAECgQIBAAAAA==.',['艾薩']='艾薩拉斯星魂:BAABKgAFFH8JAAMgAAgIbAQsDwA/AQAgAAgI1gIsDwA/AQAYAAEIJQ2MFABLAAAAAA==.',['花美']='花美侽:BAAAKgAECggICAAAAA==.',['若水']='若水纷飞:BAABKgAFFH8UAAIYAAMI/CATDgDzAAAYAAMI/CATDgDzAAAAAA==.',['药不']='药不奇:BAABKgAFFH8FAAIZAAUI9wnHFgD6AAAZAAUI9wnHFgD6AAAAAA==.',['萌牛']='萌牛猛妞:BAAAKgADCgUIBQAAAA==.',['萌面']='萌面大虾:BAAAKgADCggICAAAAA==.',['萨一']='萨一下满了:BAAAKgAECgcIEQABKgAECggIEwAbAAAAAA==.',['葉落']='葉落隨風:BAAAKgADCggICgAAAA==.',['西门']='西门吹逼:BAAAKgAECgIIAgAAAA==.',['谋黄']='谋黄忠:BAABKgAFFH8OAAICAAMI1xvHKgDaAAACAAMI1xvHKgDaAAAAAA==.',['豈止']='豈止仗義:BAAAKgAECgYIBwAAAA==.',['貌似']='貌似很妖精:BAAAKgAECggICwAAAA==.',['贡克']='贡克丶:BAAAKgAECggIDwAAAA==.',['贰拾']='贰拾贰:BAACKgAFFH8MAAIcAAMIfSHGGQAZAQAcAAMIfSHGGQAZAQAqAAQKfxYAAhwACAj2HTMvAL0BABwACAj2HTMvAL0BAAAA.',['超级']='超级变變变:BAAAKgAECggICAAAAA==.',['蹄里']='蹄里奥哞叮:BAABKgAFFH8YAAQdAAgIHhjhEwC9AQAdAAYI0B7hEwC9AQAiAAYIEBU1BACiAQAhAAYIQQL1DQCfAAAAAA==.',['轻狂']='轻狂的书生:BAAAKgAECgYICAAAAA==.',['辣嘎']='辣嘎布:BAAAKgADCgUIBQAAAA==.',['进桥']='进桥里:BAABKgAFFH8IAAIdAAgIUwUsEQCNAQAdAAgIUwUsEQCNAQAAAA==.',['进鸡']='进鸡的绿巨人:BAAAKgADCgYIBgAAAA==.',['逸风']='逸风栈:BAAAKgAECggIEAAAAA==.',['遥听']='遥听风铃语:BAAAKgAFFAIIAgAAAA==.',['遵义']='遵义燃毛丹:BAAAKgAECgcIBwAAAA==.',['那莳']='那莳的法苟:BAAAKgAECggICAAAAA==.那莳的萨苟:BAAAKgAECggIDAAAAA==.',['酷酷']='酷酷的小虎牙:BAAAKgAECgIIAgAAAA==.',['醉阳']='醉阳:BAABKgAFFH8GAAIdAAYI0Q+2JwBJAQAdAAYI0Q+2JwBJAQAAAA==.',['野徳']='野徳:BAAAKgAFFAIIBAAAAA==.',['野性']='野性艾露思:BAAAKgAECgIIAwAAAA==.',['长夜']='长夜更漏难眠:BAABKgAFFH8GAAIBAAYIgxk+AQC1AQABAAYIgxk+AQC1AQAAAA==.',['阑珊']='阑珊丶流年:BAAAKgAFFAIIAgAAAA==.',['阳光']='阳光橙:BAAAKgADCgEIAQAAAA==.',['随心']='随心丶:BAAAKgAECgYIBgAAAA==.',['雪伦']='雪伦盖尔:BAABKgAFFH8HAAMdAAMIYwMyeQB3AAAdAAMIYwMyeQB3AAAiAAIINQRcEgBnAAAAAA==.',['雪山']='雪山白:BAAAKgADCgEIAQAAAA==.',['雷帝']='雷帝丶芬达:BAAAKgAECgEIAQAAAA==.',['青疑']='青疑冰:BAAAKgAFFAgIAgAAAA==.青疑雪:BAABKgAFFH8HAAIIAAIIawrQEwCPAAAIAAIIawrQEwCPAAAAAA==.',['风柒']='风柒:BAAAKgAECgQIBAAAAA==.',['风行']='风行者:BAABKgAFFH8FAAIdAAUI7BIDNQAWAQAdAAUI7BIDNQAWAQAAAA==.',['风霜']='风霜烟牧:BAAAKgAECgEIAQAAAA==.',['风骚']='风骚丫麦呆:BAAAKgAFFAIIAgAAAA==.',['香酥']='香酥鸡腿:BAAAKgAECgcICAAAAA==.',['高坂']='高坂桐乃:BAAAKgAFFAEIAQAAAA==.',['鬼术']='鬼术妖姬:BAAAKgADCgUIBQAAAA==.',['黑牛']='黑牛贝贝:BAAAKgAECgYIBgAAAA==.',['黑黑']='黑黑煞:BAABKgAECn8eAAIcAAgInho3IgAKAgAcAAgInho3IgAKAgAAAA==.',['黑黯']='黑黯中的獨影:BAABKgAFFH8RAAIeAAMIJhQqEQDpAAAeAAMIJhQqEQDpAAAAAA==.',['龙晶']='龙晶:BAAAKgAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end