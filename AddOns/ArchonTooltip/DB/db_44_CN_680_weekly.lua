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
 local lookup = {'DeathKnight-Frost','DeathKnight-Blood','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Warrior-Protection','DemonHunter-Havoc','Paladin-Holy','Rogue-Assassination','Rogue-Subtlety','Warrior-Fury','Warrior-Arms','DeathKnight-Unholy','Warlock-Destruction','Priest-Discipline','Priest-Holy','Priest-Shadow','Shaman-Restoration','Shaman-Elemental','Paladin-Protection','Druid-Guardian','Mage-Arcane','Mage-Frost','Druid-Balance','Druid-Restoration','Monk-Brewmaster','Warlock-Demonology','Monk-Windwalker','Monk-Mistweaver',}; local provider = {region='CN',realm='恶魔之翼',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ab='Abb:BAAALAADCgEIAQAAAA==.',Ac='Acacia:BAAALAAFFAIIAgAAAA==.',Ae='Aexiaop:BAAALAAECgYIDAAAAA==.',Al='Alexsyh:BAACLAAFFH8hAAMBAAYImBziIACxAQABAAYIaBziIACxAQACAAYIuhSlCQB9AQAsAAQKfxYAAgEACAgII6AHAMUCAAEACAgII6AHAMUCAAAA.',An='Andale:BAAALAAECgYICQAAAA==.',Bc='Bcy:BAABLAAECn8WAAMDAAYI9Rf+ewBOAQADAAYI9Rf+ewBOAQAEAAYI6gJ2nwB3AAAAAA==.Bcyy:BAABLAAFFH8GAAIFAAYIYxADHwBuAQAFAAYIYxADHwBuAQAAAA==.',Bi='Bigboss:BAACLAAFFH8YAAIGAAUIggi3GgC8AAAGAAUIggi3GgC8AAAsAAQKfzQAAgYACAj3E2cuANwBAAYACAj3E2cuANwBAAAA.Bilboss:BAAALAAECgIIAgAAAA==.Binboss:BAAALAAECgYIDAAAAA==.',Bl='Blue:BAAALAAECgEIAQAAAA==.',Ca='Caitou:BAABLAAFFH8GAAIHAAYIgw9pJABpAQAHAAYIgw9pJABpAQAAAA==.',Cd='Cdd:BAAALAAECgMIAwAAAA==.',Ch='Chase:BAAALAAECgYIDAAAAA==.',Cl='Classback:BAAALAAECgUIBwAAAA==.Classgd:BAAALAAECgYIBgAAAA==.',Co='Conanan:BAAALAAECgQIBAAAAA==.Continued:BAAALAAECgYIDQAAAA==.',Du='Dunkelpferd:BAAALAADCgYIBgAAAA==.Dunkels:BAAALAAECgQIBwAAAA==.',Et='Eternaly:BAAALAAFFAIIAgAAAA==.',Fi='Fiona:BAAALAAECggICAAAAA==.',Fo='Foam:BAAALAAECggICAAAAA==.',Ga='Garnettear:BAABLAAFFH8HAAIBAAQIwQoyVAC+AAABAAQIwQoyVAC+AAAAAA==.Garouman:BAAALAAECgYIBgAAAA==.',Ho='Holy:BAACLAAFFH8OAAIIAAQIph6nDwDkAAAIAAQIph6nDwDkAAAsAAQKfyYAAggACAh2HjMKANMCAAgACAh2HjMKANMCAAEsAAUUBgglAAMAIB0A.',Ju='Julight:BAAALAAECgcIDgAAAA==.',Ka='Kai:BAAALAAFFAIIAgAAAA==.Kakacc:BAAALAAECgYICgAAAA==.',Ki='Killuayzy:BAAALAAFFAIIAgAAAA==.Kittyboss:BAAALAAECgQIBAAAAA==.',Ku='Kuronami:BAAALAADCgEIAQAAAA==.',Ma='Maste:BAAALAAECgcIEwABLAAFFAYIJQADACAdAA==.',Mi='Minfilia:BAABLAAFFH8JAAMJAAII6yAqGQBPAAAKAAEI3R/OGQBWAAAJAAEI+SEqGQBPAAAAAA==.',Mo='Moggle:BAABLAAECn8UAAIBAAgIiQlEhADiAAABAAgIiQlEhADiAAAAAA==.Morals:BAAALAAECgYICAABLAAFFAYILgAFAJUhAA==.',Na='Nanimomo:BAAALAADCgYIBgAAAA==.',Ra='Random:BAAALAAECgYICQAAAA==.',Ri='Ripper:BAAALAADCgEIAQAAAA==.',Se='Secretga:BAAALAAECgUICQAAAA==.',Si='Sierrajoan:BAAALAAECgEIAQAAAA==.',Su='Sugardoor:BAAALAAFFAIIAgAAAA==.',Tw='Twy:BAAALAADCggICgAAAA==.',Uh='Uh:BAABLAAFFH8KAAMLAAYIHCJqDQDuAQALAAYIWiFqDQDuAQAMAAIIfx+dBABNAAAAAA==.',We='Weirdoo:BAACLAAFFH8YAAINAAUIUBoVBQBRAQANAAUIUBoVBQBRAQAsAAQKfy0AAg0ACAiFHvUFAPsCAA0ACAiFHvUFAPsCAAAA.',Wo='Worldstyle:BAABLAAFFH8GAAIOAAYIMBDZEgDKAQAOAAYIMBDZEgDKAQAAAA==.',['一只']='一只迷了鹿:BAABLAAFFH8PAAILAAgISRBsCAAuAgALAAgISRBsCAAuAgAAAA==.',['七度']='七度空间:BAAALAAECgYIAgAAAA==.',['七爷']='七爷灬:BAAALAADCgEIAQAAAA==.',['三月']='三月风:BAAALAAFFAIIAgAAAA==.',['不曾']='不曾毁灭:BAAALAAECgEIAQAAAA==.',['不灭']='不灭:BAAALAAFFAIIAwAAAA==.',['丑牛']='丑牛:BAAALAADCgUIBQAAAA==.',['东方']='东方持国天王:BAAALAAFFAIIAgAAAA==.',['丨丶']='丨丶浅時光:BAAALAADCgIIAgAAAA==.',['丨哈']='丨哈根達斯丨:BAAALAAECgUIBgAAAA==.',['为何']='为何流浪二:BAAALAAECgEIAQAAAA==.',['人生']='人生勝利組:BAAALAAFFAIIAgAAAA==.',['从小']='从小就很闲:BAAALAAECgYIBgAAAA==.',['仙本']='仙本那:BAAALAADCgEIAQAAAA==.',['伤心']='伤心牛:BAAALAADCggIEwAAAA==.',['余辉']='余辉:BAABLAAFFH8GAAIPAAIItQPvBwA7AAAPAAIItQPvBwA7AAAAAA==.',['停下']='停下了足迹:BAABLAAFFH8JAAIBAAYIpRO/KQCQAQABAAYIpRO/KQCQAQAAAA==.',['偷矿']='偷矿偷草偷钱:BAAALAADCgYIBgAAAA==.',['充满']='充满矛盾的鬼:BAABLAAFFH8qAAIOAAYIrxX0JwB6AQAOAAYIrxX0JwB6AQAAAA==.',['冉冉']='冉冉德:BAAALAAFFAIIBAAAAA==.',['再见']='再见亦是恨:BAAALAAECgYICQAAAA==.',['冬絶']='冬絶纱:BAABLAAECn8fAAMQAAcIAArWcwAhAQAQAAcIAArWcwAhAQARAAYIxgNeewC9AAAAAA==.',['冰冻']='冰冻鱼子酱:BAABLAAFFH8JAAIBAAUIVxK3QQA0AQABAAUIVxK3QQA0AQAAAA==.',['冰糖']='冰糖柠檬:BAAALAADCgYIBgAAAA==.冰糖糖小番茄:BAAALAAFFAIIAgAAAA==.',['冰麒']='冰麒步:BAAALAADCgQIBAAAAA==.冰麒麟步:BAAALAAECgUICgAAAA==.',['冷萃']='冷萃多冰丶:BAAALAAFFAIIAgAAAA==.',['创口']='创口贴:BAAALAAECggIBgAAAA==.',['前程']='前程旧梦:BAAALAADCgYIBgAAAA==.',['力挽']='力挽狂澜:BAACLAAFFH8IAAMSAAYIPhIYHwBiAQASAAYIPhIYHwBiAQATAAEIFAEtQQAuAAAsAAQKfxkAAhIACAjFHoUmAHgCABIACAjFHoUmAHgCAAAA.',['北极']='北极的帝凯:BAAALAAECgYIBAAAAA==.北极的牛牛:BAAALAAECgUIBQAAAA==.北极的箭神:BAABLAAFFH8JAAIDAAIIgRLPpgA7AAADAAIIgRLPpgA7AAAAAA==.北极的骑士:BAABLAAFFH8IAAIBAAIIyQj+jwA+AAABAAIIyQj+jwA+AAAAAA==.',['十五']='十五行诗:BAAALAAECgUIBQAAAA==.',['十里']='十里水沉烟冷:BAAALAAECgYIDAAAAA==.',['半岛']='半岛旧铁盒:BAAALAAECgEIAQAAAA==.半岛老铁盒:BAAALAADCgYIBgAAAA==.',['单身']='单身奶茶:BAACLAAFFH8uAAMFAAcIVh6RCQD7AQAFAAcIVh6RCQD7AQAUAAUICRLnCQARAQAsAAQKfy8AAxQACAg5IfMJANsCABQACAi/H/MJANsCAAUABwjOInsvALQCAAAA.单身屠夫:BAAALAAECgYIBgAAAA==.单身肥牛:BAAALAAFFAIIAgAAAA==.',['南方']='南方增长天王:BAABLAAFFH8GAAIOAAYIUwguOQAnAQAOAAYIUwguOQAnAQAAAA==.',['博弈']='博弈哥:BAAALAADCgYIBwAAAA==.',['原罪']='原罪之刃:BAAALAAECgYICAAAAA==.',['叉烧']='叉烧包:BAAALAAECgYICQAAAA==.',['叫我']='叫我起名废:BAAALAADCggIEQAAAA==.',['叮咛']='叮咛咚丶:BAAALAAECgcIDQAAAA==.',['叶灬']='叶灬傾云:BAAALAAECgYIDAAAAA==.',['后姐']='后姐:BAAALAADCgQIBAAAAA==.',['后羿']='后羿:BAAALAAFFAIIAgAAAA==.',['吹吹']='吹吹流:BAAALAADCgQIBAAAAA==.',['呃啊']='呃啊:BAABLAAFFH8IAAIVAAIIJRorBQCcAAAVAAIIJRorBQCcAAAAAA==.',['周杰']='周杰仑:BAAALAAFFAIIAgAAAA==.',['呼啦']='呼啦圈:BAAALAAECgIIAgAAAA==.',['哞哞']='哞哞牛:BAAALAAECgYIBgAAAA==.',['啟示']='啟示錄:BAAALAADCggICAAAAA==.',['嗨呀']='嗨呀打摩丝:BAABLAAFFH8LAAIFAAUIQRSDJwA9AQAFAAUIQRSDJwA9AQAAAA==.',['嘆惜']='嘆惜:BAAALAAECgUIBQAAAA==.',['嘛咪']='嘛咪嘛咪轰轰:BAAALAADCgYICgAAAA==.',['嘲讽']='嘲讽你妹啊:BAAALAAFFAIIBAAAAA==.',['圣丶']='圣丶琮:BAAALAADCgQIAgAAAA==.',['圣光']='圣光丶手电:BAAALAAECgYIBgAAAA==.',['基耳']='基耳加丹:BAAALAADCgEIAQAAAA==.',['堺雅']='堺雅人:BAAALAAFFAIIAgAAAA==.',['夏禾']='夏禾星野:BAACLAAFFH8NAAMWAAII6BHxWQBBAAAXAAEIIhMcHwBGAAAWAAIIfA/xWQBBAAAsAAQKfyAAAhYABgjxFlA3ADIBABYABgjxFlA3ADIBAAAA.',['夏蝉']='夏蝉望霜:BAABLAAFFH8GAAIGAAIIoR6iJQBRAAAGAAIIoR6iJQBRAAAAAA==.',['夏銫']='夏銫纱:BAAALAADCgUIBQAAAA==.',['夜来']='夜来香:BAAALAAECgQICAAAAA==.',['够钟']='够钟死心了:BAABLAAFFH8VAAILAAgIxxCuCAApAgALAAgIxxCuCAApAgAAAA==.',['大口']='大口吃肉:BAAALAAECgYICQAAAA==.',['大師']='大師兄:BAAALAAECgYIBgAAAA==.',['大爱']='大爱仙尊:BAAALAAECgYIBgAAAA==.',['大碗']='大碗热干面:BAAALAAFFAIIAgAAAA==.',['天尊']='天尊皇胤:BAABLAAFFH8IAAIDAAgIBgKMfwBXAAADAAgIBgKMfwBXAAAAAA==.',['天生']='天生牛马:BAAALAAECgEIAQAAAA==.',['天赐']='天赐霐:BAAALAAECggICAAAAA==.',['天黒']='天黒请闭眼:BAAALAAECgUIBQAAAA==.',['奈文']='奈文丶摩尔:BAAALAAECgYIBgAAAA==.',['奥丁']='奥丁:BAAALAAECgMIAwAAAA==.',['好鑫']='好鑫的牛丶:BAAALAADCgEIAQAAAA==.',['妇科']='妇科聖手:BAABLAAFFH8IAAIFAAII/STsIQDJAAAFAAII/STsIQDJAAAAAA==.',['妍丶']='妍丶:BAABLAAFFH8GAAMYAAYI4gi5HgDPAAAYAAUI4gm5HgDPAAAZAAEIGAbYXAA0AAAAAA==.',['妖丶']='妖丶弓:BAAALAAECgQIBwAAAA==.',['孤独']='孤独如狗:BAABLAAFFH8GAAIDAAYI4RHjOQBZAQADAAYI4RHjOQBZAQAAAA==.',['宇後']='宇後來生:BAABLAAFFH8GAAIRAAII/iKFFQDRAAARAAII/iKFFQDRAAAAAA==.',['安宁']='安宁吖:BAAALAADCgYIBgAAAA==.',['安达']='安达:BAAALAADCgUIBQAAAA==.',['宝宝']='宝宝小牛:BAABLAAFFH8OAAMTAAYIWwhcHgDBAAATAAQIQgNcHgDBAAASAAYIdwAJcgBHAAAAAA==.',['对老']='对老汉尊重点:BAAALAAECgUIBQAAAA==.',['小喵']='小喵豆豆:BAABLAAECn8ZAAMIAAgIKQ09HQBeAQAIAAcIhA49HQBeAQAFAAIItxGB3QBCAAAAAA==.',['小妹']='小妹妹的歌:BAABLAAFFH8GAAIHAAYIig/tIwBsAQAHAAYIig/tIwBsAQABLAAFFAgICAAaAPIaAA==.',['小小']='小小二黑:BAAALAAECgEIAQAAAA==.',['小熊']='小熊乔治:BAAALAAECgYICAAAAA==.',['小耳']='小耳耳:BAAALAADCgQIAwAAAA==.',['小豆']='小豆丁:BAAALAAECgQIBwAAAA==.',['小骚']='小骚酷:BAAALAAECgMIBAAAAA==.',['小龙']='小龙女过儿:BAACLAAFFH8HAAIDAAMIqw33bQCGAAADAAMIqw33bQCGAAAsAAQKfyAAAwQABgguHnpPAHgBAAMABgjkHayvAJUBAAQABghnFXpPAHgBAAAA.',['帆之']='帆之牧:BAAALAAECgMIAwAAAA==.',['师法']='师法灵精血:BAAALAAECgQIBAAAAA==.',['廴厶']='廴厶乄凵丩乀:BAAALAAECgYIDgAAAA==.',['开瓶']='开瓶气丶:BAAALAAECgUIBQAAAA==.',['引雷']='引雷针:BAAALAAECgYIBgAAAA==.',['御芍']='御芍神紫:BAABLAAFFH8GAAIOAAYIixJ6KgBwAQAOAAYIixJ6KgBwAQAAAA==.',['心语']='心语星愿:BAAALAAECgMIAwAAAA==.',['快乐']='快乐旅行家:BAAALAAECgMIAwAAAA==.',['忽然']='忽然遇见你:BAABLAAFFH8IAAIBAAYImhDSMAB3AQABAAYImhDSMAB3AQAAAA==.',['怎么']='怎么回忆我:BAABLAAFFH8LAAIBAAYI4BFMLgCBAQABAAYI4BFMLgCBAQAAAA==.',['怒焰']='怒焰斩魂:BAAALAAECgYIBgAAAA==.',['恋上']='恋上月亮:BAAALAAECgcIDAAAAA==.',['恨的']='恨的人没死成:BAABLAAFFH8QAAILAAcIoBD7DADyAQALAAcIoBD7DADyAQAAAA==.',['想去']='想去海边:BAAALAADCgQIBAAAAA==.',['我不']='我不是那个谁:BAABLAAFFH8MAAIZAAIICBeIKQCFAAAZAAIICBeIKQCFAAAAAA==.',['我似']='我似自愿的:BAAALAAECgUIBwAAAA==.',['我的']='我的角好长:BAAALAAECgEIAQAAAA==.',['战神']='战神:BAABLAAFFH8IAAILAAgILRx+BQB8AgALAAgILRx+BQB8AgAAAA==.',['抓娃']='抓娃娃:BAAALAADCgQIBAAAAA==.',['护淑']='护淑宝:BAABLAAFFH8IAAIWAAIIlBCsWgBBAAAWAAIIlBCsWgBBAAAAAA==.',['挽歌']='挽歌不终不止:BAABLAAFFH8GAAIWAAYIGQ58DwDrAQAWAAYIGQ58DwDrAQAAAA==.',['捌个']='捌个萨满:BAAALAAECgMIAwAAAA==.',['捡柴']='捡柴火过冬:BAAALAAECgYIBgAAAA==.',['摩卡']='摩卡加冰:BAABLAAFFH8IAAIBAAMIVBmmVwCmAAABAAMIVBmmVwCmAAAAAA==.',['摸鱼']='摸鱼拌饭:BAAALAADCgcIBwAAAA==.',['无双']='无双乄影:BAAALAAECgQIBAAAAA==.',['旧城']='旧城為醒的妳:BAABLAAFFH8FAAMXAAII3gYqGgBuAAAXAAIIowQqGgBuAAAWAAIIFgVwaAAwAAAAAA==.',['时光']='时光回溯:BAAALAADCgIIAgAAAA==.',['星幺']='星幺:BAAALAAECgQICgAAAA==.',['星狩']='星狩者:BAAALAAECgMIAwAAAA==.',['星辰']='星辰丶云里:BAABLAAFFH8IAAMbAAQIHQWdGwCJAAAOAAMI6QIdTACKAAAbAAIIhQidGwCJAAAAAA==.星辰丶侠侣:BAACLAAFFH8jAAIaAAcILQULEQA5AQAaAAcILQULEQA5AQAsAAQKfxkABBoACAgUC90mAFkBABoACAjWCt0mAFkBABwACAj1BuU9AD8BAB0ABgiZENAsAD0BAAAA.星辰丶刽子手:BAACLAAFFH8OAAMCAAYIcQbdEADhAAACAAYIngTdEADhAAABAAII0Q3kdACOAAAsAAQKfxUAAwEACAhMGZZoACQCAAEABwgiHJZoACQCAAIACAiPCRQfAMMAAAAA.星辰丶炮灰:BAAALAAECgQIBAAAAA==.星辰丶神咕:BAABLAAFFH8FAAIZAAMIuARCQgBsAAAZAAMIuARCQgBsAAAAAA==.星辰丶糖纳兹:BAAALAAFFAIIAgAAAA==.星辰丶雾里:BAAALAAECgYIDAAAAA==.',['星钥']='星钥:BAAALAAECgQIBAAAAA==.',['晓月']='晓月:BAAALAAECgYIBgAAAA==.',['暗夜']='暗夜熊:BAAALAAECgUIBgAAAA==.',['月咏']='月咏歌呗:BAABLAAFFH8FAAIOAAUI8g3WPAAPAQAOAAUI8g3WPAAPAQAAAA==.',['末法']='末法毁天道:BAAALAAECgMIAwAAAA==.',['术丶']='术丶学教授:BAAALAAFFAYIAwAAAA==.',['柏不']='柏不正:BAACLAAFFH8IAAMTAAIIfwhxMgCEAAATAAIIfwhxMgCEAAASAAIIQwE5cABKAAAsAAQKfxQAAxMABgi8EwpmAIcBABMABgi8EwpmAIcBABIABggiBmr/AKEAAAEsAAUUBgglAAMAIB0A.',['柏卜']='柏卜正:BAACLAAFFH8lAAIDAAYIIB3iIwCiAQADAAYIIB3iIwCiAQAsAAQKfy0AAgMACAimIzsTABQDAAMACAimIzsTABQDAAAA.',['栎儿']='栎儿:BAAALAAECgQIBQAAAA==.',['格拉']='格拉斯丶文:BAAALAAECgYIBgAAAA==.',['桀骜']='桀骜:BAAALAAECgYIDgAAAA==.',['桂花']='桂花糕:BAAALAADCggICAAAAA==.',['桃花']='桃花恋:BAABLAAFFH8VAAIFAAUIwxX/KQAvAQAFAAUIwxX/KQAvAQAAAA==.',['梦屿']='梦屿:BAAALAAECgYIBgAAAA==.',['橘子']='橘子超强:BAAALAADCgQIBAAAAA==.',['橙丞']='橙丞澄:BAAALAADCgYIBgAAAA==.',['止血']='止血瓶丶:BAAALAADCgEIAQAAAA==.',['毛胖']='毛胖球:BAABLAAFFH8yAAMQAAgIBSOSBACLAgAQAAcIhSKSBACLAgARAAQIVh6dDQCEAQABLAAFFAgIpAAQAAUkAA==.',['水晶']='水晶北碧:BAABLAAFFH8MAAIHAAYIRB6ZGwCXAQAHAAYIRB6ZGwCXAQAAAA==.',['水牛']='水牛黄牛牦牛:BAAALAADCgIIAgAAAA==.',['永夜']='永夜之主:BAAALAAECgYICgAAAA==.',['污以']='污以丶类聚:BAAALAAECgYICAAAAA==.',['河南']='河南说唱之神:BAABLAAFFH8IAAIGAAgIAQ05CQCuAQAGAAgIAQ05CQCuAQAAAA==.',['法爷']='法爷开个门:BAAALAADCgIIAgAAAA==.',['洋蛋']='洋蛋先生:BAAALAAECgQIAwAAAA==.',['滋你']='滋你三点甲:BAAALAADCgIIAwAAAA==.滋你六点甲:BAABLAAFFH8GAAIBAAII2AmrfgCIAAABAAII2AmrfgCIAAAAAA==.',['火不']='火不高兴:BAAALAAECgcIDQAAAA==.',['火之']='火之高兴拌饭:BAAALAADCgIIAgAAAA==.',['火焰']='火焰獠牙:BAAALAAECgcICwAAAA==.',['灬你']='灬你的深浅:BAAALAAECgQIBAAAAA==.',['灬独']='灬独白灬:BAAALAAECgEIAQAAAA==.',['灼光']='灼光:BAAALAAFFAIIAgAAAA==.',['炽焱']='炽焱:BAAALAAECgIIAgAAAA==.',['热苏']='热苏打:BAAALAAECgEIAQAAAA==.',['熊老']='熊老师:BAAALAAECgEIAQAAAA==.',['爱像']='爱像一场旅行:BAABLAAFFH8RAAILAAgIgBRfBwBIAgALAAgIgBRfBwBIAgAAAA==.',['爱意']='爱意随风起:BAAALAAFFAMIAgAAAA==.',['爱的']='爱的人没可能:BAABLAAFFH8MAAIDAAYI7BL3MQByAQADAAYI7BL3MQByAQAAAA==.',['爲所']='爲所欲为:BAAALAAFFAIIAgAAAA==.',['爷爷']='爷爷泡的茶:BAAALAAECgYICAAAAA==.',['牛奶']='牛奶奶牛:BAAALAAECgYIDAAAAA==.',['狂暴']='狂暴小虾米:BAAALAADCgEIAQAAAA==.',['狐武']='狐武:BAABLAAFFH8GAAIaAAYIbB0mCgCkAQAaAAYIbB0mCgCkAQAAAA==.',['猫巧']='猫巧:BAAALAAFFAYIBAAAAA==.',['猫禾']='猫禾:BAAALAAFFAIIAgAAAA==.',['猫遇']='猫遇:BAABLAAFFH8NAAMbAAQI+w6CEABLAAAOAAQI+w7oQwDLAAAbAAIITBKCEABLAAAAAA==.',['猫里']='猫里猫气:BAAALAAECgYICAAAAA==.',['玩个']='玩个骑士:BAAALAAECgcIBwAAAA==.',['甜甜']='甜甜小雏菊:BAAALAAECgYIBgAAAA==.',['电台']='电台失灵:BAAALAADCgIIAgAAAA==.',['痛苦']='痛苦的恶魔:BAAALAAECgQIBAAAAA==.',['痴情']='痴情小火龙:BAAALAAECgYIEQAAAA==.',['白不']='白不佂:BAAALAADCggIDQABLAAFFAYIJQADACAdAA==.',['白雪']='白雪莹莹:BAAALAAECgYIDQAAAA==.',['盛世']='盛世写华章:BAABLAAFFH8GAAITAAYIxQAyVgAOAAATAAYIxQAyVgAOAAAAAA==.',['真是']='真是悲剧:BAACLAAFFH8uAAILAAcIPCXlBQByAgALAAcIPCXlBQByAgAsAAQKfzQAAgsACAiQJM4KAEUDAAsACAiQJM4KAEUDAAAA.',['砖治']='砖治牛人的丶:BAAALAADCgIIAgAAAA==.',['破晓']='破晓流砂:BAAALAAECgEIAQAAAA==.',['硒都']='硒都奶妈:BAAALAADCgIIAgAAAA==.',['磅丨']='磅丨礴:BAAALAAFFAIIAgAAAA==.',['社会']='社会摇:BAAALAAECgQIBAAAAA==.',['神棍']='神棍缺心眼:BAACLAAFFH8JAAIZAAII9Q4INgBqAAAZAAII9Q4INgBqAAAsAAQKfxwAAhkABwiiHhsiAGQCABkABwiiHhsiAGQCAAAA.神棍缺牙巴:BAAALAAECgcIEAABLAAFFAIICQAZAPUOAA==.',['秋月']='秋月无边:BAAALAAFFAIIBAAAAA==.',['秋水']='秋水云庐:BAAALAAECgYIDwAAAA==.',['秦彻']='秦彻:BAABLAAFFH8IAAIHAAgIzRUqCgAjAgAHAAgIzRUqCgAjAgAAAA==.',['究极']='究极无敌暴龙:BAABLAAFFH8HAAMTAAYInwRIJQAcAQATAAYInwRIJQAcAQASAAEIAB7rYQBZAAAAAA==.',['筱筱']='筱筱布丁:BAABLAAFFH8LAAIKAAYIsCI4AQB5AgAKAAYIsCI4AQB5AgAAAA==.',['算什']='算什么男人:BAAALAAECgUICQAAAA==.',['箭如']='箭如风:BAAALAAECgUIBQAAAA==.',['米拉']='米拉朵朵:BAABLAAFFH8HAAIDAAMI3g5KcACBAAADAAMI3g5KcACBAAAAAA==.',['糖丶']='糖丶德瑞拉:BAACLAAFFH8kAAIIAAcIORTQCQBsAQAIAAcIORTQCQBsAQAsAAQKfyIAAggACAjUHxEJAOECAAgACAjUHxEJAOECAAAA.',['紫颜']='紫颜丿步阡:BAAALAADCgQIBAAAAA==.',['绝影']='绝影:BAABLAAFFH8qAAIHAAYI/SHuCgDzAQAHAAYI/SHuCgDzAQAAAA==.',['绝招']='绝招无敌回城:BAAALAAECgIIAgAAAA==.',['绯色']='绯色奥恋:BAAALAAECgYICwAAAA==.绯色霜恋:BAAALAAECgQIBAAAAA==.',['绿皮']='绿皮书:BAAALAAFFAIIAgAAAA==.',['罗汉']='罗汉果将军:BAABLAAFFH8GAAMbAAYIogHqGAA0AAAOAAQI1wCGZQA6AAAbAAIIOgPqGAA0AAAAAA==.',['美缕']='美缕:BAAALAADCgcICAAAAA==.',['老五']='老五的奥斯卡:BAAALAAECgMIAwAAAA==.',['老当']='老当儿:BAAALAAECgYIBgAAAA==.',['老绵']='老绵羊:BAABLAAFFH8PAAMSAAMIAQg/UQB5AAASAAMIAQg/UQB5AAATAAIItQyKSgA8AAAAAA==.',['聪聪']='聪聪:BAACLAAFFH8KAAIHAAIIFAn0UwCIAAAHAAIIFAn0UwCIAAAsAAQKfyEAAgcACAh/GTpQADICAAcACAh/GTpQADICAAAA.',['胖橘']='胖橘丶萨:BAAALAAECgYIBgAAAA==.',['腹黑']='腹黑喵:BAAALAAECgIIAgAAAA==.',['自凑']='自凑一桌:BAABLAAFFH8GAAIZAAYIqxFsGgBZAQAZAAYIqxFsGgBZAQAAAA==.',['臭样']='臭样子:BAAALAAECgUIBQAAAA==.',['节水']='节水优先:BAAALAAECgIIAQAAAA==.',['花渐']='花渐:BAABLAAFFH8NAAIYAAMIsBW3IwCSAAAYAAMIsBW3IwCSAAABLAAFFAUIHgAbABMcAA==.',['花满']='花满楼石欲梦:BAAALAAFFAIIAgAAAA==.',['苍梧']='苍梧:BAAALAAECgYIDAAAAA==.',['苏堤']='苏堤春晓:BAAALAAECgIIAgAAAA==.',['茉莉']='茉莉青茶:BAAALAADCgEIAQAAAA==.',['茴暃']='茴暃严乜:BAABLAAFFH8KAAISAAMIIQ9wRgB3AAASAAMIIQ9wRgB3AAABLAAFFAgICAASAB4AAA==.',['莉娜']='莉娜兔:BAACLAAFFH8YAAIFAAUI9QeIMgDuAAAFAAUI9QeIMgDuAAAsAAQKfx0AAgUACAhuEy5wAAkCAAUACAhuEy5wAAkCAAAA.',['菜頭']='菜頭:BAAALAAECgUIBQAAAA==.',['菠萝']='菠萝头王子:BAABLAAFFH8MAAIDAAYIJBD2PwBHAQADAAYIJBD2PwBHAQAAAA==.',['萌贼']='萌贼吥呆:BAAALAAFFAMIAwABLAAFFAgIHwAJAIEmAA==.',['萨兰']='萨兰法鲁尔:BAAALAAECgUIBQAAAA==.',['萨满']='萨满丶:BAABLAAFFH8JAAISAAQIOws9OgC6AAASAAQIOws9OgC6AAAAAA==.',['葡萄']='葡萄藤:BAAALAAECgUIBQAAAA==.',['蒂娅']='蒂娅:BAAALAAECgYIBgAAAA==.',['薄暮']='薄暮之眼:BAAALAAECgQIBQAAAA==.',['蘇菲']='蘇菲:BAAALAAECgIIBAAAAA==.',['蛋碎']='蛋碎就拿去蒸:BAABLAAECn8WAAISAAYIYht1OQB2AQASAAYIYht1OQB2AQAAAA==.',['蛋蛋']='蛋蛋旳忧伤:BAAALAADCgcIBwAAAA==.',['血尘']='血尘篮球:BAAALAAECgYIBgAAAA==.',['西门']='西门吹雪:BAAALAAFFAIIBAAAAA==.',['计上']='计上心头:BAAALAAECgIIAgAAAA==.',['豪客']='豪客来:BAAALAAECgYIBgAAAA==.',['贰贰']='贰贰叁肆:BAAALAADCgYIBgAAAA==.',['走停']='走停停走停停:BAABLAAFFH8PAAILAAYI0RZLCgARAgALAAYI0RZLCgARAgAAAA==.',['超级']='超级牛:BAABLAAFFH8UAAITAAMI+Rm4MgCUAAATAAMI+Rm4MgCUAAAAAA==.',['辉光']='辉光刃柒大人:BAAALAAECgEIAQAAAA==.',['过几']='过几多通宵:BAABLAAFFH8TAAILAAYIMxZFCgARAgALAAYIMxZFCgARAgAAAA==.',['迷失']='迷失丷光哥:BAAALAADCggIEAAAAA==.',['逍遥']='逍遥猎:BAAALAAFFAIIAwAAAA==.',['逐风']='逐风猎:BAAALAAECgYIBwAAAA==.',['醒觉']='醒觉才愿退烧:BAABLAAFFH8XAAILAAcIQRW0CgALAgALAAcIQRW0CgALAgAAAA==.',['钻们']='钻们拉宁:BAAALAAFFAIIAgAAAA==.',['闪电']='闪电侠:BAAALAAECgYICgAAAA==.',['防盗']='防盗门丶:BAAALAAECgMIAwAAAA==.',['阿宾']='阿宾:BAAALAAECgYIDAAAAA==.',['阿布']='阿布在不斩:BAAALAAECgUIBQAAAA==.',['阿龙']='阿龙的左手:BAAALAADCggIHgAAAA==.',['隋随']='隋随:BAABLAAFFH8FAAIXAAMIlhFfDQCEAAAXAAMIlhFfDQCEAAAAAA==.',['随便']='随便你歪丶:BAABLAAFFH8JAAIZAAUImBBxJwDcAAAZAAUImBBxJwDcAAAAAA==.',['雨中']='雨中飘零:BAAALAAECgEIAQAAAA==.',['雨露']='雨露之子:BAAALAAFFAIIAgAAAA==.雨露均沾:BAABLAAECn8WAAIXAAYIdh+vHgAlAgAXAAYIdh+vHgAlAgAAAA==.',['雪天']='雪天:BAAALAAECgQIBgAAAA==.雪天的小牛:BAAALAAECgYIBgAAAA==.',['雪晴']='雪晴:BAAALAAECgYIAQAAAA==.',['雷霆']='雷霆士官长:BAAALAADCgIIAgAAAA==.',['霸波']='霸波尔奔:BAAALAADCgIIAgAAAA==.',['非法']='非法走丝:BAAALAAECggIEAAAAA==.',['预言']='预言者:BAAALAAFFAIIAwAAAA==.',['香甜']='香甜水蜜桃:BAAALAAECgUICAAAAA==.',['骑士']='骑士的苦楚:BAACLAAFFH8NAAICAAYIhQTbEADhAAACAAYIhQTbEADhAAAsAAQKfxYAAgIACAiDDWshAHwBAAIACAiDDWshAHwBAAAA.',['骑猪']='骑猪漂移:BAABLAAFFH8GAAIHAAIIdhP0TQBLAAAHAAIIdhP0TQBLAAAAAA==.',['鵬霄']='鵬霄萬裡:BAAALAADCggICAAAAA==.',['麻木']='麻木算罪过:BAABLAAFFH8LAAIBAAYI3xWFLgCAAQABAAYI3xWFLgCAAQAAAA==.',['麻辣']='麻辣小龙虾:BAAALAADCgYIBgAAAA==.',['黄泉']='黄泉彼岸:BAABLAAECn8WAAMBAAgI/iMtDABFAwABAAgI/iMtDABFAwACAAgIVAx/JwBCAQAAAA==.',['黎明']='黎明:BAAALAAFFAIIAgAAAA==.',['黑吃']='黑吃皮:BAAALAAECgMIAwAAAA==.',['鼻塞']='鼻塞:BAABLAAFFH8HAAIBAAUIWxKXQgAwAQABAAUIWxKXQgAwAQAAAA==.',['龙龙']='龙龙的聋聋:BAAALAADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end