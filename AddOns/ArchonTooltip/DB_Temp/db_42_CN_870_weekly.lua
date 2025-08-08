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
 local lookup = {'Rogue-Subtlety','Rogue-Assassination','Warlock-Demonology','Warlock-Destruction','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','DeathKnight-Blood','Monk-Mistweaver','Mage-Frost','Shaman-Restoration','DeathKnight-Frost','Paladin-Protection','Paladin-Retribution','DemonHunter-Vengeance','DemonHunter-Havoc','Druid-Balance','Druid-Restoration','Evoker-Devastation','Evoker-Preservation','Priest-Discipline','Warrior-Fury','Warrior-Protection','Mage-Fire','Warlock-Affliction','Paladin-Holy','Warrior-Arms','Priest-Holy','Priest-Shadow','Druid-Feral','Mage-Arcane','Druid-Guardian','Unknown-Unknown','Rogue-Outlaw','Shaman-Elemental','Shaman-Enhancement',}; local provider = {region='CN',realm='阿比迪斯',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ab='Absolution:BAACKgAFFH8IAAMBAAMIsRaOBgCGAAACAAIIJREXEwCZAAABAAIIABSOBgCGAAAqAAQKfysAAwEACAjIHTwRANgBAAEABwiyGzwRANgBAAIABQh6GiEfAIMBAAAA.',Ae='Aerlabless:BAAAKgADCgEIAQAAAA==.',Al='Alexandre:BAABKgAFFH8HAAMDAAQIxxLmDQCBAAAEAAQIkxA/LQC4AAADAAII4RLmDQCBAAAAAA==.',An='Anoxia:BAABKgAFFH8KAAMFAAYIUx8yDQCeAQAFAAYIUx8yDQCeAQAGAAQIjRIMLQC3AAAAAA==.',Ba='Babaaini:BAAAKgAECgcIBwAAAA==.',Bi='Bighammer:BAABKgAFFH8IAAMHAAQISQ7rJACTAAAHAAII2xTrJACTAAAIAAQIaQJWHgBrAAAAAA==.Bimmer:BAABKgAFFH8GAAIEAAQIAxceGQA7AQAEAAQIAxceGQA7AQAAAA==.',Bl='Blackz:BAAAKgAFFAgIBAAAAA==.',De='Demonly:BAAAKgAECgYIDAAAAA==.',Dh='Dht:BAAAKgAECgEIAQAAAA==.',Dj='Djbass:BAAAKgADCggICAAAAA==.',Dp='Dpblue:BAABKgAFFH8IAAIJAAIITg9eKwBrAAAJAAIITg9eKwBrAAAAAA==.',Ei='Eiysony:BAABKgAFFH8GAAIIAAMI4QBnIQBUAAAIAAMI4QBnIQBUAAAAAA==.',El='Elysia:BAABKgAFFH8GAAIGAAMIKw11NgCaAAAGAAMIKw11NgCaAAAAAA==.',En='Engbaiyunk:BAAAKgADCgEIAQAAAA==.',Fu='Futures:BAACKgAFFH8FAAIKAAUIMxBgCgAfAQAKAAUIMxBgCgAfAQAqAAQKfxQAAgoACAiQIpQJAJkCAAoACAiQIpQJAJkCAAAA.',Ga='Galahad:BAAAKgADCgUIBQAAAA==.',Gr='Grommas:BAAAKgAECgEIAgAAAA==.',He='Hellyes:BAABKgAFFH8QAAIGAAQIfxGSLQC1AAAGAAQIfxGSLQC1AAABKgAFFAUIHQALAHAZAA==.',Hm='Hmonster:BAAAKgAECgUIBwAAAA==.',Jo='Joycee:BAAAKgAFFAIIAgAAAA==.',Lo='Lolitas:BAACKgAFFH8IAAMMAAMIdxEdCwDEAAAMAAMIdxEdCwDEAAAIAAII8AyxLQBbAAAqAAQKfyQABAwACAicHqsJABsCAAwACAicHqsJABsCAAcABghrGFdSAHIBAAgABQinEMU7ANMAAAAA.',Ma='Magicfaint:BAABKgAFFH8IAAINAAQIZAwGDQCgAAANAAQIZAwGDQCgAAAAAA==.Matthearl:BAAAKgADCggICAAAAA==.',Me='Medeinchina:BAAAKgAECggICAAAAA==.',Ms='Msmsmms:BAAAKgAECgQIBAAAAA==.',Ne='Nelthariona:BAAAKgAECgQIBAAAAA==.',Pa='Papiyas:BAAAKgAFFAEIAQAAAA==.Paramour:BAAAKgAFFAYIAgAAAA==.',Sa='Sanmencat:BAABKgAFFH8TAAIMAAQIjxw5BwD3AAAMAAQIjxw5BwD3AAAAAA==.',Sh='Showdown:BAABKgAFFH8WAAIOAAcICBS8DgC1AQAOAAcICBS8DgC1AQABKgAFFAgIEQANAFUbAA==.',So='Somaxx:BAACKgAFFH8GAAIPAAIIXgXrIQBUAAAPAAIIXgXrIQBUAAAqAAQKfxcAAw8ACAgGBnZCALYAAA8ABghRBnZCALYAABAABQggBCqYAIQAAAAA.',Sq='Sqs:BAAAKgAECgUIBQAAAA==.',Ti='Tiamollww:BAAAKgAECggIEAAAAA==.Tiamolw:BAAAKgADCggICAAAAA==.Tige:BAAAKgADCgYIBgAAAA==.',Xe='Xenofaith:BAAAKgAFFAYIBAAAAA==.',Za='Zachariae:BAAAKgAECgEIAQAAAA==.',Zo='Zooplliee:BAAAKgAECgUIBQAAAA==.',['一颗']='一颗花生一俩:BAABKgAECn8hAAIKAAgIQBmyFwD5AQAKAAgIQBmyFwD5AQAAAA==.一颗花生二两:BAABKgAECn8lAAMFAAgIHxzyWQCjAQAFAAgIMhvyWQCjAQAGAAYIwhZeXADjAAAAAA==.',['丁达']='丁达尔迅贤:BAABKgAFFH8IAAMRAAQIaiEYLwDXAAARAAQIaiEYLwDXAAASAAIIThMxFwB/AAAAAA==.',['七月']='七月沫:BAABKgAFFH8OAAIEAAgIvh9tAgCfAgAEAAgIvh9tAgCfAgAAAA==.',['三横']='三横一竖的人:BAAAKgAECgcIEwAAAA==.',['三胖']='三胖你好大啊:BAAAKgAECgcIBwAAAA==.',['下巴']='下巴长胸毛:BAAAKgAECgEIAQAAAA==.',['东北']='东北大仙:BAAAKgAFFAEIAQAAAA==.',['东成']='东成西就:BAAAKgAECgIIAgAAAA==.',['丨斩']='丨斩月丨:BAAAKgAFFAQIBAAAAA==.',['丨緑']='丨緑嗏丶:BAAAKgAECggIEgAAAA==.',['丶冫']='丶冫氵灬:BAAAKgADCgYIBgAAAA==.',['丶加']='丶加尓鲁什:BAAAKgAFFAEIAQAAAA==.',['丶宁']='丶宁采臣:BAAAKgAFFAQIBAAAAA==.',['丶小']='丶小仰:BAAAKgADCgIIAgAAAA==.',['丶我']='丶我是哀木涕:BAAAKgAECggICAAAAA==.',['丶无']='丶无度之初:BAAAKgAECgYIBgAAAA==.',['丶柴']='丶柴郡猫:BAAAKgAECgQIBAAAAA==.',['丶盼']='丶盼:BAAAKgADCgQIBAAAAA==.',['丿芜']='丿芜灬訫丨:BAAAKgAFFAEIAQAAAA==.',['丿蒜']='丿蒜头丶:BAAAKgAECgYIBwAAAA==.',['丿魍']='丿魍丶魉丨:BAAAKgADCggICAAAAA==.',['乄聖']='乄聖灬七夜:BAAAKgADCgEIAQAAAA==.',['久久']='久久射射:BAAAKgAECgUIBQAAAA==.',['乌森']='乌森:BAAAKgAFFAgIBAAAAA==.',['二混']='二混子翠花:BAAAKgADCgIIAgAAAA==.',['二爷']='二爷:BAAAKgAECgcICwAAAA==.',['人世']='人世:BAAAKgADCgEIAQAAAA==.',['今天']='今天大雾:BAAAKgAECgYIEQAAAA==.',['今晚']='今晚就爆炸:BAAAKgAFFAYIAgAAAA==.',['以前']='以前以后:BAAAKgAECgUIBQAAAA==.',['以撒']='以撒:BAACKgAFFH9QAAIQAAgIyB7fBABtAgAQAAgIyB7fBABtAgAqAAQKfzsAAhAACAhEI8sNALcCABAACAhEI8sNALcCAAAA.',['以言']='以言:BAACKgAFFH8sAAMTAAgITBvPAwCDAgATAAgITBvPAwCDAgAUAAIIwAxsCABxAAAqAAQKfzYAAhMACAg+IKsdAM0BABMACAg+IKsdAM0BAAAA.',['伊利']='伊利刐:BAAAKgAECggIDAAAAA==.',['传奇']='传奇萌萌:BAAAKgAFFAIIAgAAAA==.',['传说']='传说中的逗逼:BAABKgAECn8XAAIOAAgIjxVUbgB6AQAOAAgIjxVUbgB6AQAAAA==.',['佛心']='佛心修罗:BAABKgAFFH8IAAIVAAQI+xHGHQCsAAAVAAQI+xHGHQCsAAAAAA==.',['倒转']='倒转流年灬:BAAAKgAECgQIAgAAAA==.',['八哥']='八哥带你飞:BAAAKgAECgUICAAAAA==.',['兲丅']='兲丅地丄:BAAAKgADCgYIBgAAAA==.',['冰火']='冰火炽舞:BAAAKgAECgQIAwAAAA==.',['冲锋']='冲锋牛:BAABKgAFFH8NAAMWAAMIIAbSJwCrAAAWAAMIGAXSJwCrAAAXAAMIxwReEQBxAAAAAA==.',['冷血']='冷血崽崽:BAAAKgAFFAQIBAAAAA==.',['凉小']='凉小戒:BAAAKgAECgQIBAAAAA==.',['凉戎']='凉戎戒丶:BAAAKgAECggICAAAAA==.',['凋零']='凋零星尘:BAAAKgAFFAIIAgABKgAFFAgIGgAHAEwhAA==.',['刑期']='刑期未满:BAAAKgAECgMIAwAAAA==.',['刘闪']='刘闪闪:BAAAKgAFFAEIAQABKgAFFAgIDgAYAMMiAA==.',['初乄']='初乄曉:BAAAKgAECgMIAwAAAA==.',['别削']='别削弱我:BAAAKgAFFAIIAwAAAA==.',['别德']='别德亿:BAABKgAFFH8HAAIRAAMIhyRyBgBBAQARAAMIhyRyBgBBAQAAAA==.',['别怕']='别怕我伤心:BAAAKgAECgMIAwAAAA==.',['前田']='前田香織:BAABKgAECn81AAIMAAgIXyE/AwCTAgAMAAgIXyE/AwCTAgAAAA==.',['劣灬']='劣灬劣人:BAABKgAECn8UAAMGAAgIwAtpTQAbAQAGAAgIwAtpTQAbAQAFAAEIAACh3gAAAAAAAA==.',['北极']='北极之翼:BAAAKgAECgQIBAAAAA==.',['十里']='十里坡剑神:BAABKgAECn8dAAIOAAgIyiTBFADEAgAOAAgIyiTBFADEAgAAAA==.',['半岛']='半岛晴空:BAACKgAFFH8UAAMEAAYIXB8kEQCDAQAEAAYIOBwkEQCDAQADAAIInByTEgCsAAAqAAQKfxkAAwQACAhzH2MPAG8CAAQACAhzH2MPAG8CAAMAAgjNDrV9ADgAAAAA.',['单人']='单人华尔兹:BAAAKgADCggICQAAAA==.',['南风']='南风入弦:BAABKgAFFH8KAAMGAAQIyRvTCwDuAAAGAAQIyRvTCwDuAAAFAAQIYw0tJADFAAABKgAFFAgIDAARAHMZAA==.',['占戈']='占戈:BAAAKgADCgQIBAAAAA==.',['卡油']='卡油豆:BAAAKgAFFAgIAQAAAA==.',['卡萨']='卡萨定:BAAAKgADCggICAAAAA==.',['双手']='双手画圈圈:BAAAKgADCgEIAQAAAA==.',['变节']='变节:BAABKgAECn9CAAQDAAgIXBvcEwDcAQADAAgIiRfcEwDcAQAZAAYIfxt8DQCLAQAEAAEIyQLRvAAQAAABKgAECggILQACABQgAA==.',['叨哥']='叨哥:BAAAKgAECgEIAQAAAA==.',['叫我']='叫我辉哥就好:BAAAKgAECggIDgAAAA==.',['叶山']='叶山瞳菜:BAAAKgAECggICAAAAA==.',['吃泡']='吃泡面送火箭:BAAAKgAECggICAAAAA==.',['君羡']='君羡:BAAAKgAECgQIBAAAAA==.',['君莫']='君莫舞:BAAAKgAECggIDAAAAA==.',['吴冠']='吴冠超:BAAAKgAFFAQIBAAAAA==.',['吴江']='吴江法神:BAAAKgADCgEIAQAAAA==.',['吼爹']='吼爹丶:BAAAKgADCgIIAgAAAA==.',['吾善']='吾善撩人:BAABKgAFFH8GAAIEAAYI/h7PDAC+AQAEAAYI/h7PDAC+AQAAAA==.吾善疗人:BAAAKgADCgYIBgAAAA==.',['吾色']='吾色:BAAAKgAECggIEwAAAA==.',['咕咕']='咕咕哪里跑:BAABKgAFFH8GAAIJAAYI5Qj6BABmAQAJAAYI5Qj6BABmAQAAAA==.咕咕小猪:BAAAKgAECgcICgAAAA==.',['咖希']='咖希摩多:BAAAKgAECgUIBQAAAA==.',['哈哈']='哈哈哥:BAAAKgAECgIIAgAAAA==.',['哒哒']='哒哒嗒:BAAAKgAECgcICgAAAA==.',['哥就']='哥就是李刚:BAABKgAFFH8ZAAQaAAMIchfVBwDXAAAaAAMIchfVBwDXAAAOAAMI+go7WgC8AAANAAII1wBUKwA0AAAAAA==.',['嗜魂']='嗜魂血印:BAAAKgAECgcIDAAAAA==.',['嘎嘎']='嘎嘎土:BAAAKgAECgYIBgAAAA==.',['噬灵']='噬灵者:BAAAKgADCggICAAAAA==.',['圣光']='圣光彤彤:BAAAKgAECggIEAAAAA==.',['圣翼']='圣翼丶风暴:BAACKgAFFH8ZAAIOAAUIjiP4HgB1AQAOAAUIjiP4HgB1AQAqAAQKf0QAAg4ACAjUJQwCAAsDAA4ACAjUJQwCAAsDAAAA.',['圣闪']='圣闪:BAAAKgAECgIIAgAAAA==.',['圣骑']='圣骑牛肉干:BAAAKgAECgIIAgAAAA==.',['地狱']='地狱土豆:BAAAKgAECgUICQAAAA==.地狱终结者:BAAAKgAECggIEwAAAA==.',['坏坏']='坏坏卟壞:BAAAKgAECgYIBgAAAA==.',['堕落']='堕落得猴子:BAAAKgADCgUIBQAAAA==.',['塔么']='塔么么:BAAAKgADCgEIAQAAAA==.',['墙角']='墙角丨买瓜皮:BAAAKgAECgIIAgAAAA==.',['墨珏']='墨珏:BAAAKgAFFAUIAgAAAA==.',['墨药']='墨药浪:BAAAKgAFFAgIBAAAAA==.',['壹龍']='壹龍:BAAAKgAECgEIAgAAAA==.',['复兴']='复兴路吴彦祖:BAAAKgAFFAgIBAAAAA==.',['复活']='复活的猴王:BAAAKgAECgYIAwAAAA==.',['夏天']='夏天小雪:BAABKgAECn8VAAMWAAcIUAnrTQDYAAAWAAcIKAbrTQDYAAAXAAUIeAvVGACQAAAAAA==.夏天猎:BAAAKgADCgYIBgAAAA==.',['夜灬']='夜灬笙歌:BAAAKgAECgUIBQAAAA==.',['大石']='大石仔:BAAAKgAECgYICQAAAA==.',['大细']='大细腿:BAAAKgAFFAgIAQAAAA==.',['大领']='大领主爱恋:BAAAKgAECgcICQAAAA==.',['天武']='天武茶道:BAAAKgAECgIIAgAAAA==.',['天锁']='天锁铃铃音:BAAAKgAECgYIBgAAAA==.',['太平']='太平人寿保险:BAABKgAECn8VAAIFAAgIchsFIwAuAgAFAAgIchsFIwAuAgAAAA==.',['太极']='太极熊猫:BAAAKgAFFAEIAQAAAA==.',['奇甲']='奇甲遁门:BAAAKgADCggIGAAAAA==.',['奇遁']='奇遁门甲:BAAAKgADCgMIBAAAAA==.',['奇门']='奇门遁甲:BAAAKgADCgYIBgAAAA==.',['奥特']='奥特打哈欠:BAAAKgADCgYIBgAAAA==.',['女乃']='女乃米唐:BAABKgAFFH8GAAIOAAYIGRuMFgCnAQAOAAYIGRuMFgCnAQAAAA==.',['奶油']='奶油小布丁:BAAAKgAECgIIAgAAAA==.',['如果']='如果打小黑:BAAAKgAFFAcIAwAAAA==.',['妖気']='妖気丸丶:BAACKgAFFH8GAAIEAAYIvhP+FABbAQAEAAYIvhP+FABbAQAqAAQKfxQAAwMACAhMHaQOABsCAAMACAgmHKQOABsCABkABgjzGOMSAEgBAAAA.',['妲妲']='妲妲威龙:BAAAKgAECgIIAgAAAA==.',['姆叉']='姆叉鸡:BAAAKgADCggIBAAAAA==.',['孤单']='孤单挑逗:BAAAKgAECgYIBgAAAA==.',['孤月']='孤月未殃:BAABKgAFFH8GAAIWAAYIahRmDACFAQAWAAYIahRmDACFAQAAAA==.',['安全']='安全生产法:BAAAKgADCggICAAAAA==.',['宠溺']='宠溺的猫:BAAAKgAECggICAAAAA==.',['射射']='射射的夜叉:BAAAKgAECgUIBgAAAA==.',['小二']='小二柄:BAAAKgADCgUIBQAAAA==.',['小吉']='小吉娃:BAABKgAFFH8GAAIOAAYI1xVGHwBzAQAOAAYI1xVGHwBzAQAAAA==.',['小女']='小女不财:BAAAKgAFFAQIBAAAAA==.',['小性']='小性感失控丶:BAAAKgADCggIEAAAAA==.',['小胖']='小胖丫:BAAAKgAECgIIAgAAAA==.',['小钢']='小钢炮儿:BAAAKgAECgMIAwAAAA==.',['小霸']='小霸王乐吴琼:BAACKgAFFH8OAAILAAYItRRMDAA0AQALAAYItRRMDAA0AQAqAAQKfysAAgsACAjvEfBMAEcBAAsACAjvEfBMAEcBAAAA.',['小馋']='小馋猫丶:BAAAKgAFFAQIBAAAAA==.',['小騒']='小騒蹄子:BAAAKgAECgYIBgAAAA==.',['尛飯']='尛飯飯:BAAAKgADCggICQABKgAFFAYICAAHAPEXAA==.',['就爱']='就爱玩大鸟:BAABKgAFFH8GAAISAAYIzgh5EwAEAQASAAYIzgh5EwAEAQAAAA==.',['屁屁']='屁屁虾:BAAAKgAECgEIAQAAAA==.',['岁月']='岁月翩跹:BAABKgAFFH8MAAIWAAgIvRf0AwB4AgAWAAgIvRf0AwB4AgAAAA==.',['巅峰']='巅峰潇洒:BAABKgAFFH8MAAIWAAgIChddAwB9AQAWAAgIChddAwB9AQAAAA==.',['巡山']='巡山丶小妖:BAAAKgAECgcIDQAAAA==.',['左岸']='左岸的橘子哥:BAAAKgAECgUIBQAAAA==.',['左手']='左手莫及:BAAAKgADCgEIAQAAAA==.',['巨牙']='巨牙小明:BAAAKgAECgQIBAAAAA==.',['巨狼']='巨狼强森:BAAAKgADCgMIAwAAAA==.',['布拉']='布拉德刘能:BAAAKgAECggIDAAAAA==.',['希尔']='希尔瓦娜簛:BAABKgAFFH8MAAIGAAMI3grKNwCWAAAGAAMI3grKNwCWAAAAAA==.',['广岛']='广岛烧:BAAAKgAECggICwAAAA==.',['开局']='开局别点连击:BAAAKgAECgQIBAAAAA==.',['弑魔']='弑魔诛神:BAABKgAECn8cAAIMAAgIRx6GAwCIAgAMAAgIRx6GAwCIAgAAAA==.',['强尼']='强尼二十:BAAAKgAECgUIBQAAAA==.',['强盗']='强盗哥布林:BAAAKgADCgYIBgAAAA==.',['彩云']='彩云之南:BAAAKgAECgUIBQAAAA==.',['彩虹']='彩虹的微笑:BAAAKgAECggIDgAAAA==.',['彩飘']='彩飘菲蕾丝:BAAAKgAECggICAAAAA==.',['影心']='影心:BAAAKgAECggICAAAAA==.',['很红']='很红:BAAAKgAECgMIAwAAAA==.',['德育']='德育处总管:BAABKgAFFH8JAAIOAAYIkSOZEgALAQAOAAYIkSOZEgALAQABKgAFFAgIDgAHALIcAA==.',['快乐']='快乐锦雯:BAAAKgAECgYIBgAAAA==.',['怀旧']='怀旧骚年:BAAAKgAECgYICgAAAA==.',['怎麽']='怎麽又餓了:BAAAKgAFFAMIAwAAAA==.',['思念']='思念病毒:BAAAKgAECggICwAAAA==.',['总之']='总之就是很强:BAABKgAFFH8IAAIOAAQIpiNqLwAqAQAOAAQIpiNqLwAqAQAAAA==.',['恩賜']='恩賜灬解脫:BAABKgAFFH8LAAIRAAQIlA4fFQALAQARAAQIlA4fFQALAQAAAA==.',['恶鬼']='恶鬼辣椒:BAABKgAFFH8GAAINAAYI7wS3GACyAAANAAYI7wS3GACyAAAAAA==.',['我的']='我的卡:BAAAKgADCggICAAAAA==.我的确萌新:BAAAKgAECgcICwAAAA==.',['戰谌']='戰谌:BAABKgAFFH8PAAMWAAYI4BzoBwDfAQAWAAYI4BzoBwDfAQAbAAYIFgidDQA3AQAAAA==.',['手下']='手下不留情:BAABKgAFFH8GAAIOAAYI0R6FEQDRAQAOAAYI0R6FEQDRAQAAAA==.',['扌是']='扌是礻申:BAAAKgAECgYIBgAAAA==.',['打裆']='打裆:BAAAKgAFFAEIAQAAAA==.',['托塔']='托塔李天王:BAAAKgAECgYIBgAAAA==.',['扯呼']='扯呼风紧:BAABKgAECn8fAAIFAAcIfBCkdQD2AAAFAAcIfBCkdQD2AAAAAA==.',['找不']='找不到对象:BAAAKgAECgQIBAAAAA==.',['指流']='指流砂:BAAAKgAECgYIBgAAAA==.',['掌心']='掌心:BAAAKgAECgYIDAAAAA==.',['放开']='放开那只熊:BAABKgAECn8aAAIHAAcIbRHlTwA1AQAHAAcIbRHlTwA1AQAAAA==.',['散桦']='散桦礼弥:BAAAKgAFFAEIAQAAAA==.',['敲钟']='敲钟牛:BAAAKgAECgMIAwAAAA==.',['新工']='新工火车王:BAAAKgAECgYIBgAAAA==.',['无双']='无双一剑:BAAAKgAECgYIAQAAAA==.无双一箭:BAAAKgAFFAMIBAAAAA==.',['无尽']='无尽的冰霜:BAAAKgAECgcIEwAAAA==.无尽的咆哮:BAACKgAFFH8IAAIFAAMIUiT9CwAkAQAFAAMIUiT9CwAkAQAqAAQKfyYAAgUACAhfJqwGAPUCAAUACAhfJqwGAPUCAAAA.无尽的浪漫:BAABKgAFFH8HAAIIAAUIQR2FCwBZAQAIAAUIQR2FCwBZAQAAAA==.无尽的翅膀:BAAAKgAECgcIEwABKgAFFAMICAAFAFIkAA==.',['无敌']='无敌斌哥:BAAAKgAECgUICQAAAA==.',['无欲']='无欲不能:BAAAKgAFFAEIAQAAAA==.',['无痛']='无痛仁牛:BAAAKgAECggICAAAAA==.',['无聊']='无聊的游戏:BAABKgAFFH8GAAIOAAMIxwbcMACfAAAOAAMIxwbcMACfAAAAAA==.',['旧盾']='旧盾:BAAAKgAECggIDwABKgAFFAUIHQALAHAZAA==.',['昊天']='昊天凨雲:BAAAKgAECggIDwAAAA==.昊天風雲:BAAAKgAECgYIBgAAAA==.',['明心']='明心破瘴:BAAAKgAECgQIBwAAAA==.',['明月']='明月之心:BAABKgAFFH8IAAIKAAIIBxbbFwB5AAAKAAIIBxbbFwB5AAAAAA==.',['易翠']='易翠娜:BAAAKgADCgIIAgAAAA==.',['星河']='星河落日:BAAAKgAECgEIAQAAAA==.',['春麗']='春麗:BAABKgAFFH8OAAIGAAYIgRjPCAABAQAGAAYIgRjPCAABAQAAAA==.',['晚上']='晚上鸟没事:BAAAKgAECgMIAwAAAA==.',['晨汐']='晨汐:BAAAKgAECggIDwAAAA==.',['晴天']='晴天柱:BAAAKgADCgEIAQAAAA==.',['暖冬']='暖冬伤别离:BAAAKgAECggIDgABKgAFFAgICAAOAEseAA==.',['暗影']='暗影蔷薇:BAABKgAECn84AAQcAAgIABmYHwDIAQAcAAgIABmYHwDIAQAVAAIIRQ0hfgBYAAAdAAEIbgfsegAlAAAAAA==.',['暮霭']='暮霭蓅囌:BAABKgAFFH8IAAIGAAQIQh9MJADcAAAGAAQIQh9MJADcAAAAAA==.',['曼波']='曼波:BAAAKgAECgMIAwAAAA==.',['最强']='最强悍丨猎:BAAAKgAECgQIBAAAAA==.',['最爱']='最爱回锅肉:BAABKgAFFH8cAAICAAgIQSEFBgAoAgACAAgIQSEFBgAoAgAAAA==.',['月下']='月下酒:BAAAKgADCgQIBAAAAA==.',['月琰']='月琰:BAAAKgADCgIIAgAAAA==.',['有德']='有德定有尸:BAABKgAFFH8GAAISAAMI2RuxCgDjAAASAAMI2RuxCgDjAAAAAA==.',['有钱']='有钱哥:BAAAKgAFFAMIAwAAAA==.',['期期']='期期艾艾:BAAAKgAECgYIDwAAAA==.',['末日']='末日流星:BAAAKgAECgQIBgAAAA==.',['术大']='术大招风:BAAAKgAECggIDAAAAA==.',['杀骑']='杀骑玛:BAABKgAFFH8HAAMIAAcIhg1EEwAIAQAIAAYIcQ9EEwAIAQAHAAEI8ANEUwBDAAAAAA==.',['李火']='李火旺:BAAAKgAECgQIBAAAAA==.',['杜克']='杜克公爵:BAABKgAFFH8FAAIMAAUIcQ3iBQAXAQAMAAUIcQ3iBQAXAQAAAA==.',['松落']='松落叶:BAABKgAFFH8JAAMWAAIImQnXIACOAAAWAAIIagnXIACOAAAbAAEI7AY1HAA/AAAAAA==.',['极夜']='极夜使者:BAABKgAECn8VAAICAAgIziO7AwDMAgACAAgIziO7AwDMAgAAAA==.',['柠檬']='柠檬味的柑橘:BAABKgAECn8sAAMeAAgIjSKCAwCnAgAeAAcIjSKCAwCnAgARAAUI3BWldQD4AAAAAA==.柠檬味的橙子:BAAAKgAECggIEQAAAA==.柠檬味的青柠:BAAAKgADCggIEAAAAA==.',['桃杏']='桃杏嫁东风丶:BAAAKgAECgYIBgAAAA==.',['桃白']='桃白白丶:BAABKgAFFH8OAAMIAAYIrhtICwBdAQAIAAYIvBdICwBdAQAHAAQI+BYSEQD1AAAAAA==.',['梦泪']='梦泪轩:BAAAKgAECgEIAQAAAA==.',['梦落']='梦落灰尘:BAAAKgAECgYICQABKgAECggILQACABQgAA==.梦落红尘:BAABKgAECn8tAAICAAgIFCBzBwCRAgACAAgIFCBzBwCRAgAAAA==.',['梨膏']='梨膏糖:BAABKgAFFH8HAAIJAAYIDggAEgAaAQAJAAYIDggAEgAaAQAAAA==.',['棍之']='棍之勇者:BAAAKgADCggICAAAAA==.',['棺柩']='棺柩裁缝师:BAAAKgAECggICQAAAA==.',['楊眉']='楊眉吐气:BAAAKgAECgcIEgAAAA==.',['楍刕']='楍刕:BAAAKgADCgIIAgAAAA==.',['樱岛']='樱岛麻衣:BAABKgAFFH8FAAIfAAUIyBZmFABBAQAfAAUIyBZmFABBAQAAAA==.',['橋本']='橋本環奈:BAABKgAECn8UAAIOAAgIsB4FbgC9AQAOAAgIsB4FbgC9AQAAAA==.',['橙子']='橙子丶丸:BAAAKgADCgYIBgAAAA==.',['橙色']='橙色加血小人:BAACKgAFFH8vAAMSAAYIFReRCACAAQASAAYIFReRCACAAQARAAUIEhUrFAAaAQAqAAQKfzcABBIACAj4HK8eANEBABIACAj4HK8eANEBABEABAjwHoUbAHQBACAAAQi7Cw41ACAAAAAA.',['橙黄']='橙黄橘绿:BAABKgAFFH8GAAMVAAYIvR3BEwD6AAAVAAQIoB/BEwD6AAAdAAII1iKaGwClAAAAAA==.',['欢哥']='欢哥超牛:BAAAKgAECgUICAAAAA==.',['欧阳']='欧阳凌晨:BAAAKgAECgEIAQAAAA==.',['此人']='此人非人:BAAAKgAFFAQIBAAAAA==.',['死神']='死神饕餮:BAAAKgAECggIEAABKgAFFAIIAgAhAAAAAA==.死神饕餮德:BAAAKgAECgcIDAAAAA==.死神饕餮智:BAAAKgAECgYICgAAAA==.',['残阳']='残阳之誓:BAAAKgAECgcICgAAAA==.',['水东']='水东长:BAAAKgAFFAQIBAAAAA==.',['水深']='水深呼吸:BAAAKgAFFAMIAwAAAA==.',['汐顔']='汐顔:BAACKgAFFH8kAAMKAAQIxRy5DgDtAAAKAAQIxRy5DgDtAAAYAAQIARcaGQDgAAAqAAQKfx4AAwoACAjaId4TAF8CAAoACAjaId4TAF8CAB8AAQi4C9WgACUAAAAA.',['治愈']='治愈心灵:BAAAKgAECgcIDAAAAA==.',['法力']='法力残渣丶:BAAAKgAECgYIBwAAAA==.',['法神']='法神制裁者:BAAAKgAECgUIBQAAAA==.',['波妞']='波妞出去玩:BAABKgAFFH8GAAILAAQI9Bx0DAD3AAALAAQI9Bx0DAD3AAABKgAFFAgIFAAJAMYaAA==.',['波斯']='波斯大蓝猫:BAAAKgADCggICAAAAA==.',['波比']='波比锤子大:BAAAKgAFFAIIAgAAAA==.',['泰瑞']='泰瑞娅灬嘶:BAAAKgADCggICAAAAA==.',['泽郎']='泽郎:BAAAKgAECgYIBgAAAA==.',['活麻']='活麻抽胩:BAABKgAFFH8GAAIHAAYIUgaMHQAxAQAHAAYIUgaMHQAxAQAAAA==.',['浅丶']='浅丶小狐:BAAAKgADCgEIAQAAAA==.',['浅浅']='浅浅的:BAACKgAFFH8dAAILAAUIcBkVEABWAQALAAUIcBkVEABWAQAqAAQKfywAAgsACAhEI60GAL4CAAsACAhEI60GAL4CAAAA.',['浓香']='浓香怪咖啡:BAABKgAFFH8QAAIRAAgIqhGmDQC+AQARAAgIqhGmDQC+AQAAAA==.',['海潮']='海潮:BAAAKgAECggICAAAAA==.',['涅磐']='涅磐丶启程:BAAAKgAECgEIAQAAAA==.涅磐丶啟示錄:BAAAKgAECgMIAwAAAA==.',['涟漪']='涟漪泛泛:BAAAKgAECggICAAAAA==.',['液师']='液师傅:BAABKgAFFH8IAAIJAAgIfAbuCQCMAQAJAAgIfAbuCQCMAQAAAA==.',['淮海']='淮海路小佩奇:BAAAKgAECgYIBgAAAA==.',['温州']='温州小姑娘:BAAAKgAECgYICQAAAA==.',['湮丶']='湮丶羽轩:BAACKgAFFH8lAAMFAAUI7yIkGwAnAQAFAAQIiyIkGwAnAQAGAAMI7x+pHgD+AAAqAAQKfykAAwUACAgTIWUuADoCAAUACAiRIGUuADoCAAYACAgDGa8uAHwBAAAA.',['满是']='满是忧伤丶牧:BAAAKgAECggIDgAAAA==.',['滿是']='滿是纏綿:BAABKgAFFH8HAAIOAAQIsBdrLwCxAAAOAAQIsBdrLwCxAAAAAA==.',['漱漱']='漱漱口:BAAAKgAECgIIAgAAAA==.',['火冰']='火冰是奥:BAAAKgAECgIIAgAAAA==.',['火锅']='火锅十二:BAAAKgADCggICQAAAA==.',['火鸡']='火鸡味鐹巴:BAAAKgAECgIIAgAAAA==.',['灰烬']='灰烬挽歌:BAAAKgAECgQIBAAAAA==.',['灿烂']='灿烂之戟:BAAAKgAECgEIAgAAAA==.',['点燃']='点燃星海丶:BAABKgAFFH8FAAIQAAUIcw90IQD6AAAQAAUIcw90IQD6AAAAAA==.',['烎火']='烎火炎焱燚:BAAAKgADCgIIAgAAAA==.',['熊猫']='熊猫老板:BAAAKgADCggICAAAAA==.',['熬过']='熬过每个夜:BAABKgAFFH8GAAIMAAYI1Be1AgClAQAMAAYI1Be1AgClAQAAAA==.',['爱睡']='爱睡觉的橙子:BAAAKgAECggIDQAAAA==.',['爱萝']='爱萝莉丶:BAAAKgADCggICgAAAA==.',['牛顿']='牛顿莱布尼茨:BAABKgAECn8bAAQYAAgIqhsINwC5AQAYAAcIDBcINwC5AQAKAAUIoxrbPwDyAAAfAAMI9xzAUwDwAAAAAA==.',['牧乐']='牧乐乐:BAAAKgAECgYIBwAAAA==.',['牧轩']='牧轩丶夜辰:BAAAKgAECgQIBAAAAA==.',['牵手']='牵手看月落:BAAAKgADCgQIBAAAAA==.',['狂暴']='狂暴酋长:BAAAKgAECgIIAgAAAA==.',['狂浪']='狂浪:BAAAKgADCgIIAgAAAA==.',['狗狗']='狗狗小黑之术:BAABKgAFFH8FAAMEAAUIcAMpOwCDAAAEAAQIOgQpOwCDAAADAAEIEQH2MgAtAAAAAA==.',['狮子']='狮子射手:BAAAKgADCgUIBQAAAA==.',['狱蝴']='狱蝴蝶:BAAAKgAECgQIBAAAAA==.',['狼铛']='狼铛:BAACKgAFFH8XAAIiAAMIEyNnAgArAQAiAAMIEyNnAgArAQAqAAQKfxgAAiIACAh5IiQCAKkCACIACAh5IiQCAKkCAAEqAAUUCAgnACIASBoA.',['猎魔']='猎魔人:BAABKgAFFH8FAAIOAAMI3hoZHgDzAAAOAAMI3hoZHgDzAAAAAA==.',['猪肉']='猪肉闷豆腐:BAAAKgAECgEIAQAAAA==.',['猪腰']='猪腰子丶:BAAAKgAFFAQIAgAAAA==.',['猫熊']='猫熊猫熊:BAAAKgAFFAQIBAAAAA==.',['猫狗']='猫狗双全:BAABKgAFFH8JAAIGAAIImxagPwB7AAAGAAIImxagPwB7AAAAAA==.',['璃月']='璃月:BAAAKgAECgQIBAAAAA==.',['璐灬']='璐灬璐:BAAAKgAECgcIBwAAAA==.',['生命']='生命一号:BAAAKgADCgUIBQAAAA==.',['疯子']='疯子:BAAAKgAECggIBQAAAA==.',['疯小']='疯小墨:BAABKgAFFH8LAAIOAAMI9RqBSADdAAAOAAMI9RqBSADdAAAAAA==.',['疯流']='疯流倜傥:BAAAKgAECgYIBgAAAA==.',['白夜']='白夜圈圈:BAACKgAFFH8OAAMOAAYIDRbMEAARAQAOAAQIaiTMEAARAQANAAYI0APlGQCpAAAqAAQKfxQAAg4ABwidJHIpAFoCAA4ABwidJHIpAFoCAAEqAAUUCAgOABYAriIA.',['白天']='白天没鸟事:BAAAKgAECgYIBgAAAA==.',['白峰']='白峰权现:BAAAKgAECggICAAAAA==.',['白袍']='白袍干豆腐:BAAAKgAECgMIAwAAAA==.白袍萨鲁曼:BAAAKgADCgcIBwAAAA==.',['盗亦']='盗亦丶有道:BAAAKgAECgUIBwAAAA==.',['瞎湖']='瞎湖闹:BAAAKgAECgYIBwAAAA==.',['瞎猫']='瞎猫丶:BAACKgAFFH82AAQZAAgIeBnZBQAnAQAEAAYI2xdaDADHAQAZAAUIWRnZBQAnAQADAAEIowW6LQA/AAAqAAQKfyAABAQACAinIQYZAN4BAAQABwitIAYZAN4BABkABAi5IdgOAHoBAAMAAQiEF096AD8AAAAA.',['破晓']='破晓时刻:BAAAKgAECgUICQAAAA==.',['磨鬼']='磨鬼筋肉人:BAAAKgAECggICAAAAA==.',['神牛']='神牛骑将:BAAAKgAFFAQIAwAAAA==.',['神选']='神选者乔扎布:BAAAKgADCgMIAQAAAA==.',['离开']='离开好吃发:BAAAKgADCggICAAAAA==.',['种花']='种花仔仔:BAAAKgADCgYIBgAAAA==.',['科学']='科学养猪丶:BAAAKgAECggIDQABKgAFFAgIKgAFACMgAA==.',['空城']='空城空梦:BAAAKgAECggICAAAAA==.',['立立']='立立的大虫虫:BAAAKgAFFAIIAgAAAA==.',['管不']='管不起:BAAAKgADCgIIAgAAAA==.',['米纳']='米纳斯伊西尔:BAAAKgADCgEIAQAAAA==.',['素乂']='素乂颜:BAAAKgADCgMIAwAAAA==.',['素年']='素年瑾时:BAAAKgAFFAQIBAAAAA==.',['紫色']='紫色豹子:BAAAKgAECgQIBAAAAA==.',['红烧']='红烧咩咩:BAABKgAFFH8FAAIQAAUIrAYvJADpAAAQAAUIrAYvJADpAAABKgAFFAgIBgAQAOsJAA==.',['红红']='红红巨兽丶:BAAAKgAECgIIAgAAAA==.',['给你']='给你打针:BAAAKgAECgMIAwAAAA==.',['给我']='给我起来:BAAAKgADCggIAwAAAA==.',['给老']='给老子咬死它:BAAAKgAECgYIBgAAAA==.',['绿绿']='绿绿的大猴子:BAAAKgAECgUIBQAAAA==.',['聖騎']='聖騎士:BAAAKgAFFAQIBAAAAA==.',['脆皮']='脆皮小猪骑:BAABKgAECn8UAAMIAAgIyhGeJgBVAQAIAAgIpRCeJgBVAQAMAAQI3hH/IAC6AAAAAA==.',['致命']='致命的手术刀:BAABKgAFFH8KAAMHAAgIihT0GQBOAQAHAAQIKhX0GQBOAQAIAAYI6A/KEQAUAQAAAA==.',['艾咪']='艾咪丶:BAAAKgADCgEIAQAAAA==.',['艾沐']='艾沐涕丶噫誌:BAAAKgAECggIDwAAAA==.',['艾筠']='艾筠丶叁柯斯:BAAAKgAECgUIAgAAAA==.',['花开']='花开莫浅忆:BAAAKgADCgUIBQAAAA==.',['花花']='花花小妞:BAAAKgADCgIIAgAAAA==.',['花香']='花香清新:BAAAKgAECgUIBgAAAA==.',['若叶']='若叶睦:BAAAKgAECgQIBAAAAA==.',['茂木']='茂木夏树丶:BAABKgAFFH8MAAIVAAYI/SUQBAARAgAVAAYI/SUQBAARAgAAAA==.',['莫克']='莫克莱尼:BAAAKgAFFAQIAQAAAA==.',['莫得']='莫得奶你:BAAAKgAECgUICQAAAA==.',['莫逐']='莫逐燕:BAABKgAFFH8GAAILAAYIRAlAGgC6AAALAAYIRAlAGgC6AAAAAA==.',['萌丶']='萌丶怪怪:BAAAKgAECgUIBQAAAA==.萌丶球球:BAACKgAFFH8GAAIJAAYILSKSBgDZAQAJAAYILSKSBgDZAQAqAAQKfxYAAgkACAgREJk1AHMBAAkACAgREJk1AHMBAAAA.',['萌亮']='萌亮:BAAAKgAECgQICAAAAA==.',['萌新']='萌新小白兔:BAAAKgAFFAIIAgAAAA==.',['萌萌']='萌萌哒刚背牛:BAACKgAFFH8OAAMLAAMIjCCFHwD8AAALAAMIjCCFHwD8AAAjAAEI+CGZJQBLAAAqAAQKfxgABAsABwg8JNQlAPgBAAsABgi0JNQlAPgBACMABQiSGbg8ADwBACQABgiLG8UxADMBAAEqAAUUBggWABIAMyAA.',['萨士']='萨士七:BAAAKgAECgYICQAAAA==.',['萨瓦']='萨瓦迪卡啦:BAAAKgAECgYIBgAAAA==.',['萨鲁']='萨鲁法爾:BAAAKgAECgEIAQAAAA==.',['蒹葭']='蒹葭月枫:BAABKgAECn8bAAIOAAgIbxbIcAB0AQAOAAgIbxbIcAB0AQAAAA==.',['蓝啵']='蓝啵兔:BAACKgAFFH8NAAIOAAMIvQ/5IwDfAAAOAAMIvQ/5IwDfAAAqAAQKfygAAg4ACAg8IF4tAGoCAA4ACAg8IF4tAGoCAAAA.',['薇薇']='薇薇冰:BAABKgAECn8UAAIcAAgIixhbHAD2AQAcAAgIixhbHAD2AQAAAA==.',['虾仁']='虾仁猪星:BAAAKgAFFAUIBAAAAA==.',['蛋淡']='蛋淡蛋:BAAAKgAFFAgIAQAAAA==.',['蜜汁']='蜜汁鸡冻丶:BAABKgAECn8YAAIWAAcIwBa9JgClAQAWAAcIwBa9JgClAQAAAA==.',['血魂']='血魂丨傀儡:BAAAKgAECgEIAQAAAA==.',['被享']='被享用的男人:BAACKgAFFH8GAAISAAMIAxeOGgDNAAASAAMIAxeOGgDNAAAqAAQKfx8AAhIABwiwGvMaAMYBABIABwiwGvMaAMYBAAAA.',['诩骑']='诩骑:BAAAKgAECgUIBQAAAA==.',['贝丽']='贝丽:BAABKgAECn8UAAIOAAcIhxWpaACJAQAOAAcIhxWpaACJAQAAAA==.',['贾丶']='贾丶克丶斯:BAAAKgAECggICAAAAA==.',['走笔']='走笔各半丶:BAAAKgADCgEIAQAAAA==.',['超凡']='超凡熊猫侠:BAAAKgAECggIDwAAAA==.',['超声']='超声波:BAAAKgAECggICwAAAA==.',['超笙']='超笙天下:BAAAKgAFFAQIBAAAAA==.',['超级']='超级红红:BAABKgAFFH8IAAINAAgIdBXcBQDSAQANAAgIdBXcBQDSAQAAAA==.',['跑糖']='跑糖的小伙计:BAAAKgADCgIIAgAAAA==.',['辣辣']='辣辣的保镖:BAAAKgAECgQIBAAAAA==.',['这就']='这就是胖胖哥:BAAAKgAFFAIIAgAAAA==.',['违规']='违规内容:BAABKgAECn8YAAIKAAgIoSEeEgAzAgAKAAgIoSEeEgAzAgAAAA==.',['追魂']='追魂:BAAAKgAFFAIIAgAAAA==.',['通通']='通通消灭:BAAAKgAECgEIAQAAAA==.',['遁奇']='遁奇门甲:BAAAKgADCggIHgAAAA==.',['遁甲']='遁甲奇门:BAAAKgADCgEIAQAAAA==.',['那个']='那个傻慢:BAAAKgAECgUIBQAAAA==.那个战师:BAAAKgAECgUIBQAAAA==.那个法士:BAABKgAFFH8KAAIYAAYItBoqDQBkAQAYAAYItBoqDQBkAQABKgAFFAgIFAAYAKMfAA==.',['邻居']='邻居家的胖熊:BAAAKgADCgEIAQAAAA==.',['郁離']='郁離:BAAAKgAECgQIBAAAAA==.',['酋丶']='酋丶长:BAAAKgAECggIEAAAAA==.',['酒剑']='酒剑仙:BAAAKgADCgEIAQAAAA==.',['酷爱']='酷爱柠檬茶:BAABKgAFFH8SAAMfAAgINxY2DgCDAQAfAAgINxY2DgCDAQAKAAEIvwQJIwA1AAAAAA==.',['醉酒']='醉酒趁年少:BAAAKgAFFAQIBAAAAA==.',['锤总']='锤总:BAAAKgAECgcIBwAAAA==.',['镭電']='镭電丶法王:BAABKgAECn8ZAAMkAAgItBkaDwACAgAkAAgItBkaDwACAgAjAAEIIAgCggA0AAAAAA==.',['长尾']='长尾巴的家伙:BAAAKgAECgIIAgAAAA==.',['阿咒']='阿咒:BAAAKgAECgYIBgAAAA==.',['阿帕']='阿帕籽:BAAAKgADCgIIAgAAAA==.',['阿莉']='阿莉埃蒂:BAAAKgADCggICAAAAA==.',['阿迩']='阿迩忒彌斯:BAABKgAFFH8GAAINAAYIiyTWBAD8AQANAAYIiyTWBAD8AQABKgAFFAgIEAAdAFsKAA==.',['阿面']='阿面同學:BAAAKgAFFAQIBAAAAA==.',['雪中']='雪中酒舞:BAAAKgAECgYICgAAAA==.',['雪猎']='雪猎手:BAAAKgAECgcIBwAAAA==.',['雾月']='雾月苍雲:BAABKgAFFH8GAAILAAYIlSKyBQD4AQALAAYIlSKyBQD4AQAAAA==.',['雾殇']='雾殇雨:BAACKgAFFH8oAAIOAAYIpBy6FAC2AQAOAAYIpBy6FAC2AQAqAAQKfzoAAw4ACAj0JbYNAOICAA4ACAj0JbYNAOICABoABAiMD1IzANwAAAAA.',['雾红']='雾红骑:BAABKgAFFH8GAAIIAAYIYR3MBwCiAQAIAAYIYR3MBwCiAQAAAA==.',['青浦']='青浦欢哥:BAABKgAECn8eAAIQAAgI9xu/GgAsAgAQAAgI9xu/GgAsAgAAAA==.',['青衣']='青衣:BAAAKgAECgcIEwAAAA==.',['顶进']='顶进芳芯:BAAAKgAECgUIDQAAAA==.',['领闲']='领闲主演:BAAAKgAFFAIIAgAAAA==.',['风丿']='风丿瑶筝:BAAAKgAECgcIBwAAAA==.',['风吹']='风吹菊花微绽:BAACKgAFFH8bAAIOAAcIZhP9FABMAQAOAAcIZhP9FABMAQAqAAQKfyEAAw4ACAh2Hcs/AAMCAA4ACAh2Hcs/AAMCAA0AAQjrA1dhAAkAAAAA.风吹鼻涕飘:BAAAKgAECgYIBgAAAA==.',['风暴']='风暴女猎手:BAAAKgADCggIDAAAAA==.风暴灬元素:BAAAKgAFFAIIAgAAAA==.风暴牛犊:BAAAKgAECgQIBAAAAA==.',['风飞']='风飞丶月:BAAAKgAECgcIBwAAAA==.',['飞跃']='飞跃云端:BAABKgAECn8UAAIHAAgImR5BFgBaAgAHAAgImR5BFgBaAgAAAA==.',['飯爺']='飯爺:BAAAKgADCggICAAAAA==.',['飯飯']='飯飯:BAABKgAFFH8OAAMQAAUIFBVyIQD6AAAQAAUIeBFyIQD6AAAPAAMIUhM4EQC5AAABKgAFFAYICAAHAPEXAA==.',['饼乾']='饼乾:BAAAKgAECggICAAAAA==.',['驹驹']='驹驹大人:BAAAKgAECggIDQAAAA==.',['鬣磨']='鬣磨人:BAAAKgAECgQIBgAAAA==.',['鬼魅']='鬼魅吃凉:BAAAKgADCgIIAgAAAA==.',['魂兮']='魂兮雾璃:BAAAKgADCggICAAAAA==.',['魅妖']='魅妖丶:BAAAKgADCgMIAwAAAA==.',['魏武']='魏武帝继承者:BAAAKgAECgYIBwAAAA==.',['魔法']='魔法披风:BAAAKgADCggICAAAAA==.',['鱼人']='鱼人:BAAAKgAFFAMIAwAAAA==.',['鸩羽']='鸩羽千殇:BAABKgAFFH8LAAIWAAYIpCAHCwCaAQAWAAYIpCAHCwCaAQAAAA==.',['麦药']='麦药德:BAAAKgAECgUICQAAAA==.',['麻辣']='麻辣公主:BAAAKgAFFAIIAgAAAA==.',['黎黎']='黎黎安:BAAAKgAECgQIBAAAAA==.',['黑色']='黑色閃電:BAAAKgAECggIDAAAAA==.',['黑莓']='黑莓棒棒糖:BAAAKgAFFAgIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end