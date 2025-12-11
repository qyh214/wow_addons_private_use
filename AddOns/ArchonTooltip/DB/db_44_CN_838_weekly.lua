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
 local lookup = {'Druid-Balance','Druid-Restoration','Priest-Shadow','Mage-Arcane','Mage-Fire','Warrior-Fury','Priest-Holy','Shaman-Restoration','Evoker-Preservation','Mage-Frost','DeathKnight-Blood','Warlock-Destruction','Hunter-BeastMastery','Paladin-Retribution','DemonHunter-Havoc','Hunter-Survival','Hunter-Marksmanship','Rogue-Assassination','DeathKnight-Frost','Warrior-Protection','Shaman-Elemental','Warlock-Demonology','Monk-Brewmaster','Monk-Windwalker','Paladin-Protection','DeathKnight-Unholy','Druid-Feral','Unknown-Unknown','Rogue-Subtlety','Warrior-Arms','DemonHunter-Vengeance','Monk-Mistweaver','Paladin-Holy','Evoker-Devastation',}; local provider = {region='CN',realm='达文格尔',name='CN',type='weekly',zone=44,date='2025-12-08',data={Al='Align:BAAALAAECgYIBwAAAA==.Alwsce:BAAALAADCgIIAgAAAA==.',As='Assistance:BAAALAAECgUIBQABLAAFFAcINgABAC8eAA==.',Av='Avrillavign:BAABLAAFFH8GAAICAAIIShWkKwB/AAACAAIIShWkKwB/AAAAAA==.',Ch='Christie:BAABLAAFFH8pAAIDAAYIJxiREQBVAQADAAYIJxiREQBVAQABLAAFFAcINgABAC8eAA==.',El='Elysium:BAAALAAECgYIBwAAAA==.',Fe='Feelfreefly:BAAALAADCgYIBwAAAA==.',Fo='Foan:BAAALAAECgYICAAAAA==.',Fr='Freedoms:BAABLAAFFH8jAAMEAAYIpibQDAAgAgAEAAYIpibQDAAgAgAFAAEIYyRTCQBcAAAAAA==.',Gr='Greennestea:BAAALAADCggIEAAAAA==.',Ho='Hongbaoshi:BAAALAAECgQIBAAAAA==.',Ki='Kimtaehee:BAAALAADCgUIBQAAAA==.',Ko='Komorebi:BAAALAADCgcIBwAAAA==.',La='Labubu:BAACLAAFFH8kAAIGAAcIlRHpEgDDAQAGAAcIlRHpEgDDAQAsAAQKfy8AAgYACAgYIOacAEsBAAYACAgYIOacAEsBAAAA.Laferrari:BAABLAAFFH8KAAIGAAIIxQrvUwBCAAAGAAIIxQrvUwBCAAAAAA==.Lampa:BAAALAAECgUICAAAAA==.Lapras:BAABLAAFFH8MAAIHAAIISA2wOACDAAAHAAIISA2wOACDAAAAAA==.',Lu='Luckydcc:BAABLAAFFH8FAAIIAAIIZx8NPQCxAAAIAAIIZx8NPQCxAAAAAA==.',Mi='Mingevof:BAABLAAFFH8GAAIJAAYItSJRBQA9AgAJAAYItSJRBQA9AgAAAA==.',Mo='Moonwinds:BAABLAAFFH8ZAAIEAAYIZxioHwCaAQAEAAYIZxioHwCaAQABLAAFFAcINgABAC8eAA==.',Ne='Nekol:BAAALAAECgYICgAAAA==.',On='Oneoptimus:BAAALAAECgYIBgAAAA==.',Pa='Page:BAAALAADCgIIAgAAAA==.Parado:BAABLAAFFH8UAAMHAAYIqhMQGQCLAQAHAAYIqhMQGQCLAQADAAMIdwRvIwBlAAAAAA==.',Pl='Playerfamclw:BAABLAAFFH8FAAIKAAMIUhqZCwClAAAKAAMIUhqZCwClAAAAAA==.Playerrxwla:BAAALAADCgIIAgAAAA==.',Ps='Psanslkokio:BAAALAAECgUIBQAAAA==.',Ru='Rubinli:BAAALAAECgMIAwAAAA==.',Sa='Sabern:BAABLAAFFH8HAAILAAMIBRn3EwCPAAALAAMIBRn3EwCPAAAAAA==.Saki:BAABLAAFFH8FAAIMAAIISg/7XQBBAAAMAAIISg/7XQBBAAAAAA==.Samoyedbaby:BAAALAAECggICAAAAA==.',Se='Selena:BAAALAAECgcIBwAAAA==.Seraph:BAAALAAECgMIAwAAAA==.',Sh='Shenyu:BAABLAAFFH8HAAINAAIImhSMYACLAAANAAIImhSMYACLAAAAAA==.',Sn='Sngeetze:BAABLAAFFH8WAAIIAAYIxBndFAC7AQAIAAYIxBndFAC7AQAAAA==.',St='Starwood:BAAALAAECgUIBQAAAA==.',Ut='Utherr:BAABLAAFFH8nAAIOAAYImCFrDADiAQAOAAYImCFrDADiAQABLAAFFAcINgABAC8eAA==.',We='Westlessrels:BAAALAAECgEIAQAAAA==.',Xl='Xlm:BAACLAAFFH82AAIBAAcILx5TBQAmAgABAAcILx5TBQAmAgAsAAQKfzEAAgEACAhnJNEbAIICAAEACAhnJNEbAIICAAAA.',Yo='Yomeko:BAAALAADCgYIDAAAAA==.Yorugal:BAAALAAFFAIIAgAAAA==.',Yv='Yvonne:BAAALAADCgcIBwAAAA==.',['一五']='一五五的人生:BAABLAAFFH8MAAIIAAMIhBSSPQCvAAAIAAMIhBSSPQCvAAAAAA==.',['一半']='一半死一半活:BAAALAAECgYICQAAAA==.',['一只']='一只野苍蝇:BAABLAAFFH8LAAIPAAUICg7iLwAdAQAPAAUICg7iLwAdAQAAAA==.',['一蹄']='一蹄子踢死你:BAAALAAECggIEgAAAA==.',['上杉']='上杉达也灬:BAAALAADCgQIBAAAAA==.',['不吃']='不吃人头:BAABLAAFFH8UAAQNAAIIJRNSjgBGAAAQAAEIXBG5BwBSAAANAAII2RFSjgBGAAARAAEIsxBPGwAtAAAAAA==.',['不听']='不听话的沐涵:BAAALAADCgEIAQAAAA==.',['不堪']='不堪一鸡:BAABLAAFFH8GAAINAAYIbRZhNABtAQANAAYIbRZhNABtAQAAAA==.',['不知']='不知道取啥名:BAAALAAFFAQIBAAAAA==.',['两鞭']='两鞭子扯过来:BAAALAAECgQIBQAAAA==.',['丨染']='丨染丶:BAAALAAECgYIDwAAAA==.',['丨羙']='丨羙丶伢灬:BAAALAAECgIIAgAAAA==.',['丨落']='丨落羽恋尘丨:BAAALAAECggICAAAAA==.',['丨黑']='丨黑泽明丨:BAAALAADCggIDgAAAA==.',['丰满']='丰满的傻馒:BAAALAAECgcIBwAAAA==.',['丶陈']='丶陈沐婉:BAAALAAECgYIBgAAAA==.',['乌萨']='乌萨奇:BAAALAADCgEIAQAAAA==.',['九十']='九十玖:BAAALAAFFAIIAgABLAAFFAQIEAASAMsXAA==.',['九天']='九天使:BAACLAAFFH8hAAIHAAcI7QXNDwBDAQAHAAcI7QXNDwBDAQAsAAQKfxoAAgcABwj0DHpjAFIBAAcABwj0DHpjAFIBAAAA.',['二丫']='二丫丶史塔克:BAAALAAECgYICgAAAA==.',['云雾']='云雾茶:BAAALAAECgYIBgAAAA==.',['云韵']='云韵无觅处:BAABLAAFFH8GAAITAAII+xOEewBIAAATAAII+xOEewBIAAAAAA==.',['五彩']='五彩果冻:BAAALAAFFAIIAgAAAA==.',['五月']='五月仙:BAAALAADCgMIAwAAAA==.',['五柳']='五柳牧歌:BAAALAAFFAEIAQAAAA==.',['亚鸡']='亚鸡米德:BAABLAAFFH8MAAMBAAgIrBG0IAC6AAABAAgIrBG0IAC6AAACAAEIGg4AAAAAAAAAAA==.',['什么']='什么什么龍囧:BAAALAAFFAIIAgAAAA==.',['从不']='从不抱怨环境:BAABLAAFFH8HAAIPAAMIewpsXQBBAAAPAAMIewpsXQBBAAAAAA==.',['他们']='他们来了丶:BAAALAADCgUIBAAAAA==.',['以屈']='以屈为伸:BAABLAAFFH8LAAITAAUI1Q3ASAAZAQATAAUI1Q3ASAAZAQAAAA==.',['伊央']='伊央:BAABLAAFFH8GAAITAAIIZRWLZQCVAAATAAIIZRWLZQCVAAAAAA==.',['伊扬']='伊扬:BAAALAAECgYIEgAAAA==.',['伊杨']='伊杨:BAAALAAFFAIIAgAAAA==.',['伊洋']='伊洋:BAAALAAFFAIIAgAAAA==.',['伊羊']='伊羊:BAAALAAFFAIIAgAAAA==.',['伊莉']='伊莉雅斯菲尔:BAAALAAECgEIAQAAAA==.',['何以']='何以青春:BAAALAAECgYIBgAAAA==.',['你们']='你们都好细呀:BAABLAAFFH8MAAITAAIILCOCWACcAAATAAIILCOCWACcAAAAAA==.',['你喜']='你喜欢河马嘛:BAABLAAFFH8SAAICAAYIbxhXDwDOAQACAAYIbxhXDwDOAQAAAA==.',['你拿']='你拿个杯:BAACLAAFFH8fAAIOAAYIBBmlEgAlAQAOAAYIBBmlEgAlAQAsAAQKfygAAg4ACAhPIGBFAGwCAA4ACAhPIGBFAGwCAAAA.',['你胖']='你胖到我啦:BAAALAADCgcIBgAAAA==.',['侍剑']='侍剑:BAAALAAFFAIIAgAAAA==.',['侍琴']='侍琴:BAABLAAECn8YAAIOAAgI3BuxUgBJAgAOAAgI3BuxUgBJAgAAAA==.',['依然']='依然荣耀:BAABLAAFFH8GAAIMAAII4AHBcQAqAAAMAAII4AHBcQAqAAAAAA==.',['俪影']='俪影睂:BAAALAADCgIIAgAAAA==.',['倒霉']='倒霉熊:BAAALAADCgMIAwAAAA==.',['倾塍']='倾塍之恋:BAABLAAFFH8mAAINAAUIfCXVHQC+AQANAAUIfCXVHQC+AQAAAA==.',['偏微']='偏微分方程:BAAALAAECgUIBQAAAA==.',['元素']='元素之神:BAABLAAFFH8GAAIIAAIIxQ/iTQBtAAAIAAIIxQ/iTQBtAAABLAAFFAUIFQANAN0XAA==.',['光彩']='光彩照阳:BAAALAAECgYICwAAAA==.',['光影']='光影之间:BAABLAAFFH8ZAAIDAAUIwxlEEgBLAQADAAUIwxlEEgBLAQAAAA==.',['克里']='克里斯蒂亚诺:BAAALAAFFAIIAgAAAA==.',['八鳷']='八鳷鵺:BAACLAAFFH8hAAIPAAcIyg6+FQC6AQAPAAcIyg6+FQC6AQAsAAQKfzQAAg8ACAiqHpExAJQBAA8ACAiqHpExAJQBAAAA.',['六库']='六库仙贼:BAAALAAECggIEAAAAA==.',['冉青']='冉青衣:BAAALAADCgUICAAAAA==.',['再玩']='再玩就剁手:BAAALAADCgUIBQAAAA==.',['冰与']='冰与光的龙诗:BAAALAAECggICwABLAAFFAgIBgAUAJwbAA==.',['冰柠']='冰柠檬:BAAALAAECgYIBgAAAA==.',['冰激']='冰激凌火锅:BAABLAAECn8XAAIKAAgI8R+YDQDJAgAKAAgI8R+YDQDJAgAAAA==.',['冰锅']='冰锅火激凌:BAABLAAFFH8KAAIVAAIIvxYhLACQAAAVAAIIvxYhLACQAAAAAA==.',['冲锋']='冲锋的背影:BAAALAAECggIEgAAAA==.',['冷夜']='冷夜风:BAABLAAECn8XAAIOAAYIUhwgWgBVAQAOAAYIUhwgWgBVAQAAAA==.',['冷月']='冷月天琊:BAAALAAECgQIBAAAAA==.',['冷静']='冷静的刺豚:BAAALAADCgIIAgAAAA==.',['凌烈']='凌烈:BAAALAADCggICAAAAA==.',['凌空']='凌空瞪:BAAALAAFFAEIAQAAAA==.',['刀哥']='刀哥追忆:BAAALAAECggIDQAAAA==.',['制动']='制动你好:BAAALAAECgIIAgAAAA==.制动底板:BAAALAAECgUIBgAAAA==.制动底板冲孔:BAAALAADCgMIAwAAAA==.制动底板切边:BAAALAAECgUIBQAAAA==.制动底板成形:BAAALAAECgYICAAAAA==.制动汽修店:BAAALAAECgEIAQAAAA==.',['劣人']='劣人希尔:BAAALAAECgIIAgAAAA==.',['勇敢']='勇敢的芯:BAABLAAFFH8iAAMCAAYIfhzjDADtAQACAAYIfhzjDADtAQABAAMIxxYyJACRAAAAAA==.',['医学']='医学奇迹:BAAALAAFFAIIBAAAAA==.',['千花']='千花影:BAAALAAECgQIBAAAAA==.',['午夜']='午夜泣雪:BAABLAAECn8cAAMNAAgIqBYIbgD/AQANAAgIMRYIbgD/AQARAAUI4w54eQDwAAAAAA==.',['半夏']='半夏如烟:BAAALAAECgEIAQAAAA==.',['南風']='南風知我意:BAAALAAECgUIBwAAAA==.',['博学']='博学者:BAAALAADCggICwAAAA==.',['卡位']='卡位:BAACLAAFFH8NAAMMAAIIOhNtXgBBAAAMAAIIxwptXgBBAAAWAAEIZBeLHgAAAAAsAAQKfxUAAwwACAiNFbM/AEsBAAwACAhPE7M/AEsBABYABAiyGexPADQBAAAA.卡位的恶魔:BAAALAAECgYIBgAAAA==.',['卡缪']='卡缪:BAABLAAECn8VAAIMAAgI4Q/6OABmAQAMAAgI4Q/6OABmAQAAAA==.',['卡蜜']='卡蜜尔风行者:BAAALAAECgQIBwAAAA==.',['厅局']='厅局级:BAAALAAFFAEIAQAAAA==.',['原神']='原神启动:BAAALAADCgYIBgAAAA==.',['又见']='又见沧海桑田:BAAALAAECgYIDQAAAA==.',['双子']='双子的忧郁:BAAALAAECgEIAQAAAA==.',['发廊']='发廊妹妹:BAAALAAFFAQIBAAAAA==.',['只为']='只为妳而哭:BAAALAAECgYICgAAAA==.',['吉伊']='吉伊:BAABLAAFFH8GAAIIAAIISwmLXgBhAAAIAAIISwmLXgBhAAAAAA==.',['吖丫']='吖丫:BAAALAADCgMIAwAAAA==.',['君莫']='君莫邪:BAAALAAECgIIAgAAAA==.',['吴粤']='吴粤癫婆:BAAALAAECgUICAAAAA==.',['呗弱']='呗弱依云:BAAALAAECgYIBgAAAA==.',['周末']='周末:BAAALAAECggICAAAAA==.',['咦咦']='咦咦吆吆:BAABLAAFFH8GAAIHAAIIlASKPwB3AAAHAAIIlASKPwB3AAAAAA==.',['哎哟']='哎哟灬不错哟:BAABLAAECn8UAAINAAgIqA/vWwCMAQANAAgIqA/vWwCMAQAAAA==.',['啊咕']='啊咕:BAAALAAFFAIIAgABLAAFFAgIMAACAI0WAA==.',['啊菇']='啊菇:BAABLAAFFH8OAAMWAAMIOx1zBwDKAAAWAAIIKyRzBwDKAAAMAAEIXA9XWgBGAAABLAAFFAgIRAAMAGkhAA==.',['啭身']='啭身説爱你:BAAALAAECgYIDgAAAA==.',['嗨咻']='嗨咻嘿:BAAALAAECgEIAQAAAA==.',['嘿起']='嘿起沟子跳:BAAALAAECgMIAwAAAA==.',['回天']='回天战神:BAAALAAFFAIIAgAAAA==.回天推拿:BAAALAAECgYIBgAAAA==.回天黑矮:BAAALAAFFAIIBAAAAA==.',['回家']='回家养猪算了:BAAALAAECgYIDwAAAA==.',['囧丶']='囧丶囧:BAAALAAECgYIBgAAAA==.',['国宝']='国宝级角色:BAAALAAECgEIAQAAAA==.',['圣光']='圣光照耀你妹:BAAALAAECgYICQAAAA==.',['坑爹']='坑爹就是我:BAAALAADCgQIBAAAAA==.',['基尔']='基尔罗格死机:BAAALAAECgMIAwAAAA==.',['塞牙']='塞牙缝:BAACLAAFFH8tAAIPAAYIYxpgFgC2AQAPAAYIYxpgFgC2AQAsAAQKfxQAAg8ACAg5H6s1AIYCAA8ACAg5H6s1AIYCAAAA.',['夏午']='夏午:BAAALAAECgEIAQAAAA==.',['夏天']='夏天的西瓜皮:BAABLAAFFH8GAAMIAAIIiQdmbABTAAAIAAIIiQdmbABTAAAVAAEIyQBdQQApAAAAAA==.',['夏末']='夏末灬未至:BAAALAAFFAIIAgAAAA==.',['多财']='多财多亿:BAABLAAFFH8VAAMNAAUIYBvIRAA6AQANAAUIYBvIRAA6AQARAAEI5BFnNQA/AAAAAA==.',['夜鸦']='夜鸦十三:BAAALAAECgYIDwAAAA==.',['大奥']='大奥斯丁:BAAALAAECgEIAQAAAA==.',['大王']='大王巡山:BAAALAAFFAIIAgAAAA==.',['大瓶']='大瓶怡宝:BAAALAAECgYICQAAAA==.',['大秋']='大秋刀鱼:BAAALAAECgYICQAAAA==.',['大罗']='大罗洞观:BAABLAAFFH8GAAIGAAYICwJrNACkAAAGAAYICwJrNACkAAABLAAFFAUIHwAGAJobAA==.',['大风']='大风柴:BAABLAAFFH8MAAITAAgIlxElKACYAQATAAgIlxElKACYAQAAAA==.',['天一']='天一一域:BAAALAAECgQIBAAAAA==.',['天官']='天官:BAACLAAFFH8XAAINAAYIYBtbKACUAQANAAYIYBtbKACUAQAsAAQKfxcAAw0ACAjSITVAAM0BAA0ACAi8ITVAAM0BABEABQjuGmgRADYBAAAA.',['天琊']='天琊噬血:BAAALAAECgYIBgAAAA==.',['天罡']='天罡战歌:BAAALAAECgYIBgAAAA==.',['天遣']='天遣者:BAABLAAFFH8IAAINAAIIxBAFnwA/AAANAAIIxBAFnwA/AAAAAA==.',['天降']='天降杀机:BAAALAADCgIIAgAAAA==.',['天霆']='天霆号:BAACLAAFFH8iAAIXAAcIcwk4DADlAAAXAAcIcwk4DADlAAAsAAQKfxYAAxcACAg9EoQqADwBABcABwh6E4QqADwBABgABwgICwdZAJEAAAAA.',['太子']='太子殿下:BAAALAAECgYIBgAAAA==.',['夶劦']='夶劦:BAAALAADCgcIBwAAAA==.',['奕冬']='奕冬:BAAALAAECgQIBQAAAA==.',['女王']='女王的骑士:BAAALAAECgEIAQAAAA==.',['奶茶']='奶茶不加糖:BAAALAADCgIIAgAAAA==.',['她不']='她不见星空:BAABLAAFFH8GAAIPAAYImABzbAAwAAAPAAYImABzbAAwAAAAAA==.',['如火']='如火似水:BAAALAAECgYICwAAAA==.',['妍嘟']='妍嘟嘟:BAABLAAFFH8FAAIOAAUI7g4mLwARAQAOAAUI7g4mLwARAQAAAA==.',['妖娆']='妖娆:BAAALAAECgYIAQAAAA==.',['妖彤']='妖彤彤:BAABLAAFFH8JAAIMAAMIuwtlLgDHAAAMAAMIuwtlLgDHAAAAAA==.',['妞妞']='妞妞是比格犬:BAAALAAECgIIAgAAAA==.',['妤薇']='妤薇:BAAALAAECgMIAwAAAA==.',['妹子']='妹子上别怕:BAAALAAECgMIAwAAAA==.',['姑娘']='姑娘灬请自重:BAABLAAECn8VAAIRAAYIDhy7EABBAQARAAYIDhy7EABBAQAAAA==.',['嫦曦']='嫦曦:BAAALAAECgYIDAAAAA==.',['孔雀']='孔雀东南飞:BAAALAAECgUIBQAAAA==.',['安斯']='安斯达克:BAAALAAECgQIBwAAAA==.',['寒山']='寒山一箭:BAABLAAFFH8VAAMNAAUI3RfGSAArAQANAAUI3RfGSAArAQARAAIIvwKOMQBWAAAAAA==.',['寒烟']='寒烟胧月:BAAALAAFFAIIBAAAAA==.',['寓清']='寓清于浊:BAABLAAFFH8LAAIOAAUI5RJqMAAHAQAOAAUI5RJqMAAHAQAAAA==.',['寿司']='寿司的骆驼:BAAALAAFFAIIAgAAAA==.',['射一']='射一枪:BAAALAAFFAIIAgAAAA==.',['小呆']='小呆德:BAAALAAECgYIBgAAAA==.',['小小']='小小丶骑士:BAAALAAFFAQIBAAAAA==.',['小心']='小心你的肾:BAAALAAECgIIAgAAAA==.',['小明']='小明圣疗:BAABLAAFFH8KAAMOAAYIuBkKMAAKAQAOAAYIuBkKMAAKAQAZAAIIWBLEGwAzAAAAAA==.',['小贼']='小贼别跑丶:BAACLAAFFH8IAAIKAAIImBzkEgCIAAAKAAIImBzkEgCIAAAsAAQKfxsAAgoABgipIMUeACUCAAoABgipIMUeACUCAAAA.',['小龙']='小龙其乐无穷:BAAALAAECgYIBgAAAA==.',['尐稀']='尐稀有动物尐:BAAALAAECgYIDQAAAA==.尐稀有美人尐:BAAALAAECgMIAwAAAA==.',['山村']='山村猛妇:BAAALAAECgYIEAAAAA==.',['山花']='山花泡泡:BAAALAAECgYIBgAAAA==.山花骑骑:BAAALAADCgYIBgAAAA==.',['巡山']='巡山小妖灵:BAAALAADCgIIAgAAAA==.',['工口']='工口工口腐:BAAALAAECgYICQAAAA==.',['工捡']='工捡法:BAABLAAFFH8LAAIEAAYIQSHSEQDsAQAEAAYIQSHSEQDsAQAAAA==.',['左手']='左手一只鸡:BAAALAAFFAIIAgAAAA==.左手炽焰:BAAALAAECgYIBgAAAA==.',['巧儿']='巧儿:BAACLAAFFH8sAAITAAYIixtIJQCiAQATAAYIixtIJQCiAQAsAAQKfyAAAhMACAh1H4gmANcCABMACAh1H4gmANcCAAAA.',['希尔']='希尔瓦娜丶:BAAALAADCgIIAgAAAA==.希尔瓦娜巳:BAAALAADCgYIBgAAAA==.希尔瓦娜锅:BAABLAAFFH8MAAINAAUIohRcTwAUAQANAAUIohRcTwAUAQAAAA==.希尔瓦拉丝:BAAALAAFFAIIBAAAAA==.',['帕拉']='帕拉丁沐涵:BAABLAAECn8ZAAIOAAYIMwxx8gA/AQAOAAYIMwxx8gA/AQAAAA==.',['幻缘']='幻缘:BAABLAAFFH8UAAIUAAUIvQ01GADpAAAUAAUIvQ01GADpAAAAAA==.',['庞发']='庞发:BAAALAAECgUIBQAAAA==.',['开鲁']='开鲁厨神:BAABLAAFFH8aAAMEAAYIXxcqJgB+AQAEAAYIXxcqJgB+AQAKAAEINgReIgA5AAAAAA==.',['归零']='归零者:BAAALAAECgIIAgAAAA==.',['彭二']='彭二甩:BAAALAAECgYICAAAAA==.',['彭六']='彭六甩:BAAALAADCgEIAQAAAA==.',['影昼']='影昼:BAAALAADCgIIAgAAAA==.',['微雨']='微雨燕双妃:BAABLAAFFH8GAAISAAMI/QeOFQCVAAASAAMI/QeOFQCVAAAAAA==.',['心虺']='心虺刈冷:BAABLAAFFH8cAAIaAAUIgRYxBQBPAQAaAAUIgRYxBQBPAQAAAA==.',['恋心']='恋心余年:BAAALAAECgYICAAAAA==.',['悠哉']='悠哉悠哉丶:BAAALAAECgcIEwAAAA==.',['惊艳']='惊艳一枪:BAAALAAECgMIAwAAAA==.',['愛是']='愛是一道光:BAAALAAECgEIAQAAAA==.',['愤怒']='愤怒的豆子:BAAALAADCgMIAwAAAA==.',['慕容']='慕容月:BAAALAAECgYICAAAAA==.慕容月颜:BAABLAAECn8VAAIHAAYItBqwIACzAQAHAAYItBqwIACzAQAAAA==.',['我心']='我心中的梦:BAAALAAECgYIBgAAAA==.',['我是']='我是学渣:BAABLAAFFH8IAAITAAYIjwmeTAD/AAATAAYIjwmeTAD/AAAAAA==.',['我未']='我未杀伯仁:BAABLAAECn8ZAAIbAAYIixuxCwCEAQAbAAYIixuxCwCEAQAAAA==.',['戚薇']='戚薇:BAACLAAFFH8GAAIWAAII0Q4zFwCWAAAWAAII0Q4zFwCWAAAsAAQKfxQAAxYACAj+GcUHAPYBABYACAj+GcUHAPYBAAwAAQhpC16bADMAAAAA.',['打拳']='打拳的壮汉:BAAALAAECgEIAQAAAA==.',['打脸']='打脸专业户:BAAALAAECgEIAQAAAA==.',['抠脚']='抠脚大汉:BAAALAAECgYICAAAAA==.',['拘灵']='拘灵遣将:BAAALAAECggICAAAAA==.',['拳拳']='拳拳:BAAALAAFFAIIAgABLAAFFAIIBQAIAGcfAA==.',['搞七']='搞七泥三:BAAALAAFFAIIAgABLAAFFAYIMAANAEojAA==.',['携子']='携子之手:BAAALAAECgYIDQAAAA==.',['摇光']='摇光:BAAALAAECgYIEAAAAA==.',['撒爹']='撒爹的小弟:BAACLAAFFH8YAAIMAAYIlBSsLQBlAQAMAAYIlBSsLQBlAQAsAAQKfxsAAgwABwilGKJhAMwBAAwABwilGKJhAMwBAAEsAAUUBggwAA0ASiMA.',['散场']='散场小迷妹:BAAALAAFFAIIBAAAAA==.',['新来']='新来的啊:BAABLAAFFH8GAAITAAQIEg/aUQDWAAATAAQIEg/aUQDWAAAAAA==.',['旅行']='旅行者:BAAALAAECgIIAgAAAA==.',['时光']='时光如歌:BAAALAAFFAIIAgAAAA==.',['明天']='明天:BAAALAAECgYIBgAAAA==.',['春天']='春天的香蕉皮:BAAALAADCgYIBgAAAA==.',['是的']='是的大王:BAAALAAFFAIIAgAAAA==.',['晓哎']='晓哎:BAAALAAECgYICAAAAA==.',['曰後']='曰後再说:BAAALAAFFAIIBAAAAA==.',['曲灬']='曲灬未终:BAAALAAFFAIIAgABLAAFFAIIAwAcAAAAAA==.',['曾是']='曾是此间少年:BAAALAAECgQIBAAAAA==.',['月凰']='月凰:BAAALAADCgIIAgAAAA==.',['月殇']='月殇无情剑:BAAALAAFFAIIBAAAAA==.',['月落']='月落霜天:BAAALAAFFAIIBAAAAA==.',['朗哥']='朗哥哥:BAABLAAFFH8RAAITAAYI0huzKgCPAQATAAYI0huzKgCPAQAAAA==.朗哥鸽:BAABLAAFFH8QAAIIAAYIHiI+CwAdAgAIAAYIHiI+CwAdAgAAAA==.',['朗鸽']='朗鸽哥:BAAALAAECgMIAwAAAA==.朗鸽鸽:BAAALAADCgEIAQAAAA==.',['木槿']='木槿昔年:BAAALAADCgYIBgAAAA==.',['机械']='机械舒适:BAAALAAECgYICAAAAA==.',['杠上']='杠上开花:BAAALAAFFAIIBAAAAA==.',['杰与']='杰与奇:BAAALAAECgQICAAAAA==.',['林深']='林深时雾起:BAAALAAFFAIIAgAAAA==.',['柒拾']='柒拾壹:BAAALAAECggICAAAAA==.',['染清']='染清尘:BAAALAADCgIIAgAAAA==.',['染红']='染红尘:BAAALAADCgQIBAAAAA==.',['染青']='染青衣:BAAALAADCgIIAgAAAA==.',['树先']='树先生:BAABLAAECn8mAAMNAAgIAxnmKQASAgANAAgIAxnmKQASAgARAAcIhQ5AWgBRAQAAAA==.',['格劳']='格劳克斯:BAABLAAFFH8MAAIEAAUI8gVaPwC+AAAEAAUI8gVaPwC+AAAAAA==.',['桂妮']='桂妮薇娅:BAAALAAFFAIIBAAAAA==.',['梦妲']='梦妲己:BAAALAADCggICAAAAA==.',['梦泽']='梦泽:BAAALAAFFAIIAgAAAA==.',['梧桐']='梧桐月色:BAAALAAFFAIIBAAAAA==.',['楍峎']='楍峎丶凩戥:BAABLAAECn8VAAIOAAgIOh8STwBSAgAOAAgIOh8STwBSAgAAAA==.',['橙阳']='橙阳魂:BAAALAAECgYIBgAAAA==.',['欧皇']='欧皇卡蜜尔:BAABLAAFFH8GAAIOAAIIlw5HVACOAAAOAAIIlw5HVACOAAAAAA==.',['此往']='此往:BAAALAAECgYICAAAAA==.',['死神']='死神归来:BAAALAAECgEIAQABLAAFFAgIBgATAIwUAA==.',['死骑']='死骑卡位:BAAALAAECgMIBwAAAA==.',['毁灭']='毁灭博士:BAAALAAECgIIAgAAAA==.',['永恒']='永恒之泪:BAAALAAECgUICAAAAA==.',['汐月']='汐月:BAAALAAECgYIDgABLAAFFAYILQAYAFoUAA==.',['沁心']='沁心沁国:BAAALAAECgEIAQAAAA==.',['沈七']='沈七七:BAACLAAFFH8FAAISAAMIagXiFgCEAAASAAMIagXiFgCEAAAsAAQKfxkAAhIABwhvF5MrAMgBABIABwhvF5MrAMgBAAAA.',['沈欺']='沈欺霜:BAABLAAECn8bAAITAAgITRUZJQDkAQATAAgITRUZJQDkAQAAAA==.',['沐清']='沐清雨:BAAALAADCgIIAgAAAA==.',['沐风']='沐风同雨:BAAALAADCgEIAQAAAA==.',['沙琪']='沙琪玛:BAABLAAFFH8LAAMNAAMIZxjrSwCZAAANAAMIZxjrSwCZAAARAAIIuwv9KgBxAAAAAA==.',['沧海']='沧海丶怒:BAACLAAFFH8bAAMIAAYIVRCZIABaAQAIAAYIVRCZIABaAQAVAAMIHgj9MwCBAAAsAAQKfy8AAwgACAgrFnpQAPABAAgACAgrFnpQAPABABUABgjREWtqAHsBAAAA.',['泡泡']='泡泡家的抱抱:BAAALAAECgUIBQAAAA==.',['流力']='流力:BAAALAAECgIIAgAAAA==.',['流晕']='流晕:BAAALAAECggICAAAAA==.',['流璃']='流璃:BAAALAAFFAIIAgAAAA==.',['浮沉']='浮沉千古事:BAAALAAECgYICAAAAA==.',['海棠']='海棠花未眠:BAABLAAECn8VAAIHAAYI8A1hcwAiAQAHAAYI8A1hcwAiAQAAAA==.',['涅法']='涅法雷姆:BAABLAAECn8aAAIPAAcIbgUleADBAAAPAAcIbgUleADBAAAAAA==.',['深蓝']='深蓝梦境:BAAALAAFFAIIBAAAAA==.',['清水']='清水末末:BAACLAAFFH8XAAIOAAUIhxYAJgBIAQAOAAUIhxYAJgBIAQAsAAQKfxgAAg4ABgigIQlSAEsCAA4ABgigIQlSAEsCAAAA.清水沫沫:BAABLAAFFH8RAAIHAAQIhRr3IABDAQAHAAQIhRr3IABDAQAAAA==.',['清逆']='清逆亡丶:BAAALAAECgMIAwAAAA==.',['清雨']='清雨灵儿:BAAALAADCgEIAQAAAA==.',['潶铯']='潶铯謿蓅:BAABLAAECn8UAAICAAcIGwylTgDdAAACAAcIGwylTgDdAAAAAA==.',['火激']='火激凌冰锅:BAACLAAFFH8JAAIBAAIIDB1AIgCGAAABAAIIDB1AIgCGAAAsAAQKfyoAAwEABwgsItEYAJwCAAEABwgsItEYAJwCAAIABQg8CgJcAK0AAAAA.',['火稚']='火稚鸡:BAABLAAFFH8GAAIMAAYIhhlJJwB+AQAMAAYIhhlJJwB+AQAAAA==.',['灬小']='灬小法悠哉灬:BAAALAAECgYIBwAAAA==.',['烟花']='烟花冷:BAABLAAFFH8GAAIOAAYItwUDTABpAAAOAAYItwUDTABpAAAAAA==.',['烧不']='烧不透:BAAALAADCggICAAAAA==.',['無声']='無声網亊:BAAALAAFFAIIAgAAAA==.',['熊心']='熊心豹胆丶:BAACLAAFFH8gAAIYAAYIuBIACAB0AQAYAAYIuBIACAB0AQAsAAQKfxoAAhgACAhrGEkgAAACABgACAhrGEkgAAACAAAA.',['燃月']='燃月灬梓:BAAALAAECgQIBAAAAA==.燃月灬静:BAAALAAECgEIAgAAAA==.',['燃烧']='燃烧之泪:BAABLAAFFH8GAAINAAYI8iGRHgC6AQANAAYI8iGRHgC6AQAAAA==.',['爱琴']='爱琴之海:BAAALAAECgYICAAAAA==.',['爵奏']='爵奏:BAAALAADCgUIBQAAAA==.',['狂奔']='狂奔的豆腐乳:BAAALAAECgYIEgAAAA==.',['狂野']='狂野娇花:BAAALAADCgIIAgAAAA==.',['狗孓']='狗孓:BAABLAAFFH8FAAINAAUIJQx/UwAFAQANAAUIJQx/UwAFAQAAAA==.',['猎手']='猎手麦兜:BAAALAAECgIIAgAAAA==.',['玄奘']='玄奘:BAAALAADCggICAAAAA==.',['玉衡']='玉衡:BAAALAAFFAIIAgAAAA==.',['王悦']='王悦:BAACLAAFFH8QAAMSAAQIyxegEAD9AAASAAQIyxegEAD9AAAdAAEI2gy6GgAAAAAsAAQKfxQAAxIABgh7IHwJANIBABIABgh7IHwJANIBAB0AAgiuG+IeAE0AAAAA.',['玖出']='玖出拾叁归:BAABLAAFFH8GAAIXAAYIRQYMFAAGAQAXAAYIRQYMFAAGAQAAAA==.',['珊瑚']='珊瑚傻漫:BAAALAADCgYIBgAAAA==.珊瑚德:BAAALAADCgUIBQAAAA==.珊瑚战:BAAALAADCgQIBAAAAA==.',['珺应']='珺应有语:BAACLAAFFH8eAAIMAAcI4hJXHQCsAQAMAAcI4hJXHQCsAQAsAAQKfyYAAgwACAhbH5pKABQCAAwACAhbH5pKABQCAAAA.',['瑞瑟']='瑞瑟格:BAAALAAFFAIIBAAAAA==.',['瑤光']='瑤光愛露恩:BAAALAAECgIIAgAAAA==.',['瓦力']='瓦力旭旭:BAABLAAFFH8PAAINAAUIGRLNHQAXAQANAAUIGRLNHQAXAQAAAA==.',['用晦']='用晦而明:BAABLAAFFH8MAAMGAAMIaw8sPACCAAAeAAIIXBXSBQCFAAAGAAMIbQosPACCAAAAAA==.',['甲乙']='甲乙丙丁:BAAALAAECgYIDgAAAA==.',['疯疯']='疯疯癫癫:BAABLAAFFH8YAAIPAAYIZBXxIwBuAQAPAAYIZBXxIwBuAQAAAA==.',['白色']='白色体育生:BAAALAAECgYIBwAAAA==.白色空间:BAABLAAFFH8GAAIHAAYIyRSaFQCoAQAHAAYIyRSaFQCoAQAAAA==.',['眼罩']='眼罩忘家里了:BAAALAAFFAIIBAAAAA==.',['矮丑']='矮丑穷搓怂:BAAALAADCggIDwAAAA==.',['砰砰']='砰砰啪啪:BAACLAAFFH8kAAMNAAcIAx0DGwDLAQANAAYI6h0DGwDLAQARAAUIbRgoCwBEAQAsAAQKfy4AAxEACAhEJJgJABgDABEACAhEJJgJABgDAA0AAwgDHetpAYAAAAAA.',['碎影']='碎影舞月:BAABLAAFFH8oAAMCAAYIsg1wHABHAQACAAYIsg1wHABHAQABAAUI9hdnFwAiAQAAAA==.',['碧月']='碧月天寒:BAAALAAECgEIAQAAAA==.',['神明']='神明灵:BAABLAAFFH8MAAMOAAYINAD9hQAXAAAOAAYINAD9hQAXAAAZAAMIJAC4JQAJAAAAAA==.',['神游']='神游太虚:BAAALAAECgYICQAAAA==.',['神话']='神话哥:BAAALAAECgEIAQAAAA==.',['秋风']='秋风落叶:BAAALAAECgEIAQAAAA==.',['空灵']='空灵梦魇:BAAALAAFFAMIAwAAAA==.',['穿越']='穿越之火:BAABLAAFFH8FAAIOAAMIvQfxSAB5AAAOAAMIvQfxSAB5AAAAAA==.',['童话']='童话哥:BAAALAAECgEIAQAAAA==.',['米奇']='米奇法神:BAABLAAFFH8GAAIKAAIIeAZjHwAxAAAKAAIIeAZjHwAxAAAAAA==.',['米奈']='米奈希爾:BAABLAAECn8VAAIOAAYI5Ry2WwBRAQAOAAYI5Ry2WwBRAQAAAA==.',['米饭']='米饭七:BAABLAAFFH8LAAIEAAYI/R1JIgCOAQAEAAYI/R1JIgCOAQAAAA==.',['糖公']='糖公主:BAAALAAECgMIAwAAAA==.',['糖糖']='糖糖公主:BAAALAAECgYIDAAAAA==.',['紫云']='紫云烟:BAAALAAFFAIIAgAAAA==.',['紫夜']='紫夜冰:BAAALAAFFAIIBAAAAA==.紫夜月半弯:BAAALAAFFAIIBAAAAA==.紫夜枫:BAAALAAFFAIIBAAAAA==.紫夜离:BAAALAAECgYIBgAAAA==.紫夜雪月:BAABLAAFFH8GAAIKAAII3xRfFwBBAAAKAAII3xRfFwBBAAAAAA==.',['紫玉']='紫玉玲珑:BAABLAAFFH8GAAIfAAIIWAGXGwAaAAAfAAIIWAGXGwAaAAAAAA==.',['紫魂']='紫魂:BAAALAAECgYIBgAAAA==.',['絶对']='絶对零度:BAACLAAFFH8dAAIKAAYILx5hAgDYAQAKAAYILx5hAgDYAQAsAAQKf1UAAgoACAhxJcUBAPECAAoACAhxJcUBAPECAAAA.',['红嘴']='红嘴儿鲤鱼:BAAALAAECgYIBgAAAA==.',['红眼']='红眼:BAAALAADCgYIBgAAAA==.',['线芯']='线芯:BAABLAAECn8WAAINAAgIkyBTZgAPAgANAAgIkyBTZgAPAgAAAA==.',['终不']='终不似少年游:BAABLAAFFH8GAAIOAAIIrxpOWABLAAAOAAIIrxpOWABLAAAAAA==.',['终极']='终极小蓝:BAACLAAFFH8iAAMDAAcILCUbBgABAgADAAYI7yQbBgABAgAHAAII5BL5NwCDAAAsAAQKfy0AAwMACAgZJvYoADUCAAMACAgZJvYoADUCAAcAAQj/Au/IAB4AAAAA.',['给你']='给你一电炮:BAABLAAFFH8GAAIVAAYIhxBXHABgAQAVAAYIhxBXHABgAQAAAA==.',['绝情']='绝情无双:BAAALAADCgYIBgAAAA==.',['绾青']='绾青殇:BAAALAADCgUIBQAAAA==.',['绿阳']='绿阳魂:BAAALAADCgQIBAAAAA==.',['网事']='网事如枫:BAAALAAFFAIIAgAAAA==.网事如風:BAAALAAECgIIAgAAAA==.',['羊教']='羊教授之吻:BAAALAADCgIIAgAAAA==.',['聖光']='聖光灬静哥哥:BAAALAAECgMIAwAAAA==.',['肥雪']='肥雪:BAAALAADCgcIBwAAAA==.',['背后']='背后飞起一刀:BAAALAAECgQIBAAAAA==.',['胖胖']='胖胖暗影掌控:BAAALAAECgYIBwAAAA==.胖胖箭无虚发:BAAALAADCgUIBQAAAA==.胖胖雷霆风暴:BAAALAAECgYICgAAAA==.',['自然']='自然之神:BAAALAAECgMIAwABLAAFFAUIFQANAN0XAA==.',['臭麦']='臭麦桑:BAAALAAFFAIIAgAAAA==.',['至尊']='至尊大宗师:BAABLAAFFH8OAAIYAAYIEBfQBwB4AQAYAAYIEBfQBwB4AQAAAA==.至尊猪儿虫:BAACLAAFFH8yAAIGAAcIQR5+BABWAgAGAAcIQR5+BABWAgAsAAQKfz0AAgYACAiLJWQHAFsDAAYACAiLJWQHAFsDAAAA.',['至少']='至少一七五:BAACLAAFFH8lAAIOAAcIdBX/DQDWAQAOAAcIdBX/DQDWAQAsAAQKfywAAg4ACAh4G+qtAKIBAA4ACAh4G+qtAKIBAAAA.',['艾米']='艾米琳娜:BAAALAAECggICwAAAA==.',['苍井']='苍井:BAAALAAECgIIAgAAAA==.',['苍穹']='苍穹二鸦:BAABLAAFFH8GAAINAAIIyBSVjABHAAANAAIIyBSVjABHAAAAAA==.苍穹卡鸭:BAAALAAECgQIBwAAAA==.苍穹夜鸦:BAACLAAFFH8HAAINAAIIYAtKawCDAAANAAIIYAtKawCDAAAsAAQKfxsAAw0ACAiTESZzAF8BAA0ACAiTESZzAF8BABEAAQhUDJTLACQAAAAA.苍穹浩茫茫:BAAALAAECgcIEQAAAA==.',['荒野']='荒野大镖客:BAAALAAFFAIIBAAAAA==.',['荣耀']='荣耀依然黯淡:BAACLAAFFH8GAAIOAAII8gevWQCHAAAOAAII8gevWQCHAAAsAAQKfx0AAg4ABwipGB11AAACAA4ABwipGB11AAACAAAA.',['莫妮']='莫妮卡:BAAALAAECggICAAAAA==.',['菇菇']='菇菇萨:BAAALAAFFAYIBAAAAA==.',['菊花']='菊花又想开了:BAABLAAFFH8FAAIgAAQIQw3fDgDhAAAgAAQIQw3fDgDhAAAAAA==.',['菜坬']='菜坬:BAAALAAFFAQIBAAAAA==.',['萬千']='萬千寵愛:BAAALAAECgYIBgABLAAFFAUIFQANAN0XAA==.',['落花']='落花人独笠:BAABLAAFFH8NAAMKAAUIsBH+DACJAAAEAAUIhw0EOAATAQAKAAIIoQ7+DACJAAAAAA==.',['葫芦']='葫芦头的海洋:BAABLAAFFH8FAAICAAMINBE4MQCnAAACAAMINBE4MQCnAAAAAA==.',['蛋了']='蛋了个蛋蛋:BAACLAAFFH8VAAIPAAUIkhtDKABSAQAPAAUIkhtDKABSAQAsAAQKfxwAAw8ACAhgG60wAJkCAA8ACAhgG60wAJkCAB8AAwiJE79MAKcAAAAA.',['蛋茜']='蛋茜碎:BAAALAADCggICAAAAA==.',['蝶咿']='蝶咿梦:BAAALAAECggIAwAAAA==.',['血翼']='血翼伤心小箭:BAAALAAECgYICQAAAA==.血翼傷心小剣:BAAALAAECggIDwAAAA==.血翼天衣有雪:BAAALAAECgUICgAAAA==.血翼朝天一棍:BAAALAAECgYICAAAAA==.血翼温柔一刀:BAAALAAECgYICgAAAA==.血翼苏梦枕:BAAALAAECgYIDAAAAA==.血翼诸葛小花:BAAALAAECgYIDwAAAA==.血翼韦青衣:BAAALAAECgYIBgAAAA==.',['裤裤']='裤裤:BAABLAAFFH8PAAITAAgIdAL2XACWAAATAAgIdAL2XACWAAAAAA==.',['襄阳']='襄阳丶彭于晏:BAACLAAFFH8bAAITAAYIux5iGQBoAQATAAYIux5iGQBoAQAsAAQKfyoAAxMACAiFInZFAHICABMACAiFInZFAHICABoAAgjMBnVVAFQAAAAA.',['要猛']='要猛:BAAALAAFFAIIAgAAAA==.',['论战']='论战之握:BAAALAAECgYIEgAAAA==.',['请叫']='请叫我撒爹:BAABLAAFFH8oAAIIAAYIBhkzFgCwAQAIAAYIBhkzFgCwAQABLAAFFAYIMAANAEojAA==.',['谢小']='谢小丸子:BAAALAAECgUICQAAAA==.',['谦谦']='谦谦不要太帅:BAACLAAFFH8LAAMGAAYIABMQHgB6AQAGAAYIABMQHgB6AQAUAAEIGALFPQAAAAAsAAQKfxgAAwYABghxHKKWAFgBAAYABghxHKKWAFgBABQABgivE2BXACUBAAAA.谦谦妈妈:BAABLAAFFH8RAAINAAYIZhebKgCMAQANAAYIZhebKgCMAQAAAA==.谦谦妈妈诶:BAABLAAFFH8RAAIKAAYI1BYEBQB7AQAKAAYI1BYEBQB7AQAAAA==.',['貓灬']='貓灬貓:BAAALAAECgIIBAAAAA==.',['身材']='身材好:BAAALAADCgcIDAAAAA==.',['辉月']='辉月弄清影:BAAALAAFFAIIAgAAAA==.',['这很']='这很奈斯:BAABLAAFFH8GAAIIAAYI1SNUCABBAgAIAAYI1SNUCABBAgAAAA==.',['这比']='这比魔法好用:BAAALAAECgMIAwAAAA==.',['迪菲']='迪菲亚顾问:BAABLAAFFH8LAAIhAAIIvA2xHgCLAAAhAAIIvA2xHgCLAAAAAA==.',['遇见']='遇见白白:BAAALAADCgQIBQAAAA==.',['遗失']='遗失滴美好:BAAALAAFFAQIBAAAAA==.',['酒舞']='酒舞贰妻:BAAALAAECgMIAwAAAA==.',['醉过']='醉过醉过:BAAALAAECgMIAwAAAA==.',['銭哆']='銭哆哆:BAAALAAECgIIAgAAAA==.',['钙琪']='钙琪叮丝:BAABLAAFFH8GAAIhAAII3h53FwCjAAAhAAII3h53FwCjAAAAAA==.',['铜锤']='铜锤打贼:BAAALAADCgUIBQAAAA==.',['银河']='银河星爆:BAABLAAFFH8GAAMKAAUILweSCgDEAAAKAAMIBQmSCgDEAAAEAAMIhgP2TABbAAAAAA==.',['门番']='门番红美铃:BAACLAAFFH8KAAMYAAMIaxSyCgDYAAAYAAMIVxKyCgDYAAAXAAIIDBOhEwCFAAAsAAQKfy0ABBgACAidJEIFADoDABgACAidJEIFADoDABcABwjXI3YJAM0CACAABgi6EvsnAGMBAAAA.',['闪电']='闪电宝坦:BAABLAAFFH8GAAITAAYI8QK6SgAMAQATAAYI8QK6SgAMAQABLAAFFAgICAAhABoMAA==.闪电宝战:BAABLAAFFH8IAAMGAAYIxQYVKAAxAQAGAAYIxQYVKAAxAQAUAAIIqwY8NAAuAAAAAA==.闪电宝法:BAAALAAFFAIIAgAAAA==.',['问题']='问题少女:BAAALAAFFAIIBAAAAA==.',['闹闹']='闹闹:BAAALAAECgMIAwAAAA==.',['阎魔']='阎魔:BAAALAAFFAIIAwABLAAFFAIIBQAIAGcfAA==.',['阿尼']='阿尼阿赛哟:BAAALAAFFAIIAwAAAA==.',['阿森']='阿森西奥:BAACLAAFFH80AAIIAAcIWhcvDgD7AQAIAAcIWhcvDgD7AQAsAAQKfzMAAggACAjaDXmVAFMBAAgACAjaDXmVAFMBAAAA.',['阿里']='阿里斯门:BAAALAADCgEIAQAAAA==.',['陆逊']='陆逊乄:BAAALAAECgEIAQAAAA==.',['随便']='随便捣捣:BAABLAAFFH8wAAINAAYISiOUEAAIAgANAAYISiOUEAAIAgAAAA==.随便谈谈:BAABLAAFFH8MAAMUAAMI2QcuJgBQAAAUAAMI2QcuJgBQAAAGAAIIRAb1ZwALAAAAAA==.',['随感']='随感:BAABLAAFFH8JAAIIAAIINgTkcwBFAAAIAAIINgTkcwBFAAAAAA==.',['雨季']='雨季还会来:BAAALAAECgYIDAAAAA==.',['雪雨']='雪雨之泪:BAAALAADCgQIAwAAAA==.',['零界']='零界点的穿越:BAABLAAFFH8fAAIGAAUIghYsJABOAQAGAAUIghYsJABOAQAAAA==.',['雷神']='雷神助我:BAAALAAECggICAAAAA==.',['雷霆']='雷霆惊梦:BAACLAAFFH8YAAIIAAUI+ROxIADKAAAIAAUI+ROxIADKAAAsAAQKfyUAAggACAg6EUhvAKQBAAgACAg6EUhvAKQBAAAA.',['雾切']='雾切响子:BAAALAADCgcIBwAAAA==.',['青花']='青花瓷:BAACLAAFFH8wAAIHAAcIoiIsAwC7AgAHAAcIoiIsAwC7AgAsAAQKfzAAAgcACAhzGVBPAJkBAAcACAhzGVBPAJkBAAAA.',['韧者']='韧者陀:BAAALAAECgYIBgAAAA==.',['风吹']='风吹的痛:BAAALAAECgYICQAAAA==.',['饭搭']='饭搭子:BAABLAAFFH8NAAIiAAYI1Q2yDQBGAQAiAAYI1Q2yDQBGAQAAAA==.',['饺子']='饺子就酒:BAAALAAFFAIIAgAAAA==.',['魔鬼']='魔鬼中的天使:BAAALAAFFAEIAQAAAA==.',['鱼丸']='鱼丸粗面:BAAALAAECgYICAAAAA==.',['麻将']='麻将女王乐乐:BAABLAAFFH8aAAIHAAYIiBywDQD5AQAHAAYIiBywDQD5AQAAAA==.',['黏黏']='黏黏虫:BAAALAADCgUIBQAAAA==.',['黑龙']='黑龙幻:BAAALAADCgUICQAAAA==.',['龙怼']='龙怼怼:BAABLAAECn8UAAINAAcIBRrjiAA7AQANAAcIBRrjiAA7AQAAAA==.',['龙蛇']='龙蛇演义:BAAALAADCgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end