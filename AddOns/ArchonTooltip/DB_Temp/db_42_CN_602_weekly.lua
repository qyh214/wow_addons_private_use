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
 local lookup = {'Priest-Holy','Priest-Discipline','Priest-Shadow','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','Mage-Arcane','DemonHunter-Vengeance','Warrior-Fury','Druid-Balance','Druid-Restoration','Warlock-Demonology','Warlock-Affliction','DeathKnight-Unholy','DeathKnight-Blood','Mage-Fire','Paladin-Protection','Unknown-Unknown','DemonHunter-Havoc','Paladin-Retribution','Evoker-Devastation','Shaman-Restoration','Warrior-Protection','Warlock-Destruction','DeathKnight-Frost','Warrior-Arms','Monk-Mistweaver','Paladin-Holy','Rogue-Assassination',}; local provider = {region='CN',realm='厄祖玛特',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alpharius:BAAAKgAFFAQIBAAAAA==.',Av='Averl:BAAAKgAECggIEAAAAA==.',Bo='Bottega:BAABKgAFFH8JAAQBAAYIKxUGGwDjAAABAAUIphAGGwDjAAACAAIIngyDKgBsAAADAAEI9hmZKQBLAAAAAA==.',Ca='Cancanneed:BAACKgAFFH8WAAMEAAMIVhw5HwD7AAAEAAMIVhw5HwD7AAAFAAIIwRFIOQCEAAAqAAQKfyEAAwQACAihH1wTAF4CAAQACAihH1wTAF4CAAUABghjCTicAO8AAAAA.',Ch='Chaosdruid:BAAAKgAECggIDAAAAA==.Choochoo:BAAAKgAECgQIBAAAAA==.',De='Deleted:BAAAKgADCgEIAgAAAA==.',Eu='Eurek:BAACKgAFFH8SAAMGAAMIQCCbEADdAAAGAAMIQCCbEADdAAAHAAIIsA16PABuAAAqAAQKfxkAAwYACAi9IhAJAL8CAAYACAiZIhAJAL8CAAcABAjsGUJEAC8BAAAA.',Ew='Ewanmage:BAAAKgADCgEIAQAAAA==.',Fi='Firstbleedin:BAAAKgADCgMIAwAAAA==.',Ge='Getone:BAABKgAECn8WAAIIAAgIohCdKAA4AQAIAAgIohCdKAA4AQAAAA==.',Gi='Gilgamesh:BAAAKgAECggICAAAAA==.',Jm='Jmemory:BAAAKgAFFAYIAQAAAA==.',Ko='Koiz:BAAAKgAFFAYIAgAAAA==.',Ku='Kurokokun:BAAAKgADCgcIBwAAAA==.',La='Ladrcd:BAAAKgAECgYICwAAAA==.Laity:BAABKgAECn87AAIJAAgIuiPCCACwAgAJAAgIuiPCCACwAgAAAA==.',Li='Liquor:BAABKgAFFH8JAAMKAAgITRPFGwA8AQAKAAUI0hbFGwA8AQALAAQI7QsZCQAJAQAAAA==.',Mo='Motasha:BAAAKgADCgIIAgAAAA==.',Ok='Okitatsu:BAAAKgAECggIDwAAAA==.',Pl='Playerkkjufs:BAABKgAFFH8HAAMMAAQIvwrKHQBsAAAMAAIIDQXKHQBsAAANAAMIgg1XGwBOAAAAAA==.',Po='Posthaste:BAABKgAFFH8GAAMOAAQIchJKFgDeAAAOAAQIyhFKFgDeAAAPAAIIHBd1GgCCAAAAAA==.',Ra='Rachel:BAAAKgADCgYIBgAAAA==.',Sa='Sandalwood:BAABKgAFFH8GAAMQAAYINBVBFQD5AAAQAAQIUhtBFQD5AAAHAAIIBwyPAwCvAAAAAA==.',Sw='Swancheese:BAAAKgAECggIDgAAAA==.',Th='Thirtyseven:BAAAKgAECgIIAgAAAA==.',Vi='Vicsanity:BAAAKgAFFAgIBAABKgAFFAgIBgAPAIYLAA==.Victoxics:BAABKgAFFH8GAAIPAAYIhgtyFgDuAAAPAAYIhgtyFgDuAAAAAA==.Vivici:BAAAKgADCggICAAAAA==.',Wi='Wion:BAAAKgADCgIIAgAAAA==.',Ye='Yessp:BAABKgAFFH8GAAIRAAYIpwOgDAC1AAARAAYIpwOgDAC1AAAAAA==.',['一个']='一个死骑:BAAAKgAFFAQIBAAAAA==.',['一刀']='一刀龙:BAAAKgAECgEIAQAAAA==.一刀龙爷:BAAAKgAECgQIBgAAAA==.',['一天']='一天满级:BAAAKgADCgcIBwAAAA==.',['一條']='一條龍:BAAAKgADCgEIAQAAAA==.',['一毛']='一毛丶二:BAAAKgADCgYIBgAAAA==.',['一点']='一点寒芒:BAAAKgAECgcICQAAAA==.',['一眼']='一眼顶真:BAABKgAECn8YAAIOAAcIEhLcUgAqAQAOAAcIEhLcUgAqAQABKgAFFAMIAwASAAAAAA==.',['一箭']='一箭双雕王:BAACKgAFFH8TAAIFAAQIBBWnLQDRAAAFAAQIBBWnLQDRAAAqAAQKfzoAAgUACAiZHH4lACECAAUACAiZHH4lACECAAAA.',['一袋']='一袋板蓝根:BAAAKgADCgUIBQAAAA==.',['一诶']='一诶他:BAAAKgAECggICAAAAA==.',['万姩']='万姩三千点:BAAAKgAECgYIBgAAAA==.',['上头']='上头雪:BAAAKgADCgIIAgAAAA==.',['下任']='下任部落酋长:BAABKgAECn8XAAMTAAgIxQ8HVwBJAQATAAcIwQ8HVwBJAQAIAAgIZgjENQDwAAAAAA==.',['不亏']='不亏就是赚:BAAAKgAECgMIAwABKgAFFAgIGQAOAOghAA==.',['不知']='不知名惩戒骑:BAABKgAFFH8MAAIUAAYIuB1wEADcAQAUAAYIuB1wEADcAQAAAA==.',['不聪']='不聪明:BAAAKgAECgYIBgAAAA==.',['东京']='东京没东莞热:BAAAKgADCgcIBwAAAA==.',['东北']='东北雨姐:BAAAKgAFFAgIBAAAAA==.',['东方']='东方树叶:BAAAKgAFFAMIAwAAAA==.',['丨清']='丨清影丨:BAAAKgAFFAMIAwAAAA==.',['丨醉']='丨醉舞倾城丶:BAAAKgAECggIEAAAAA==.',['丿熊']='丿熊猫大哥:BAAAKgADCgEIAQAAAA==.',['乄舞']='乄舞:BAAAKgAECgYIBgAAAA==.',['乌索']='乌索普:BAAAKgAECgEIAQAAAA==.',['乎乎']='乎乎爸爸:BAABKgAFFH8FAAIVAAUI1BdvBABaAQAVAAUI1BdvBABaAQAAAA==.',['九丶']='九丶尾:BAAAKgAECgMIBAAAAA==.',['九黎']='九黎:BAAAKgAFFAYIBAAAAA==.',['乾坤']='乾坤大天地:BAAAKgAECggIDwAAAA==.',['亦菲']='亦菲姐的保镖:BAAAKgAECgEIAQAAAA==.',['他很']='他很吊:BAAAKgAECgMIBgAAAA==.',['以战']='以战爲名:BAAAKgAECgUICAAAAA==.',['休塔']='休塔尔克:BAAAKgAECgUIAgAAAA==.',['会发']='会发光的萌骑:BAABKgAFFH8HAAIUAAcIFR7tCAAzAgAUAAcIFR7tCAAzAgAAAA==.',['低语']='低语瞄咆哮:BAAAKgAECgIIAgAAAA==.',['你艾']='你艾希我奶妈:BAAAKgAECggICAAAAA==.',['偷獵']='偷獵者:BAAAKgAECgUICAAAAA==.',['元宝']='元宝:BAAAKgADCgEIAQAAAA==.',['八基']='八基大狂蜂:BAAAKgAECgUIBQAAAA==.',['公子']='公子阔少:BAABKgAECn8WAAIUAAgIXiG5IgB3AgAUAAgIXiG5IgB3AgAAAA==.',['六十']='六十六号工地:BAAAKgAECgIIAgAAAA==.',['关哥']='关哥:BAAAKgADCggICAAAAA==.',['其實']='其實我不壊:BAAAKgADCgYIBgAAAA==.',['再也']='再也没有了:BAAAKgAECgYIBgAAAA==.',['再见']='再见:BAAAKgAECgcICgAAAA==.',['冰火']='冰火之间:BAAAKgAECggICQAAAA==.',['几百']='几百个萨蛮:BAABKgAFFH8aAAIWAAcIjRSyCACIAQAWAAcIjRSyCACIAQAAAA==.',['刘官']='刘官人丶:BAAAKgADCgIIAgAAAA==.',['刘财']='刘财主丶:BAABKgAECn8UAAITAAgIixBWQgCfAQATAAgIixBWQgCfAQABKgAFFAgIBwATAGEaAA==.',['到处']='到处插棍棍:BAAAKgADCgEIAQAAAA==.',['前行']='前行者:BAAAKgAECgUIBQAAAA==.',['加摩']='加摩尔:BAAAKgAECgEIAgAAAA==.',['十四']='十四姨:BAAAKgAECgIIAgAAAA==.',['华尔']='华尔琪:BAAAKgAECgQIBwAAAA==.',['南波']='南波万:BAAAKgAECgQIBAAAAA==.南波兔:BAAAKgAECgYICQAAAA==.',['卡卡']='卡卡罗特灬:BAABKgAFFH8GAAIUAAYIWCA4EADeAQAUAAYIWCA4EADeAQAAAA==.',['反手']='反手放狗:BAAAKgAECggIAQAAAA==.',['可爱']='可爱的蓝孩子:BAAAKgADCggICAAAAA==.',['史诗']='史诗级退步:BAAAKgAECgIIAgAAAA==.',['司徒']='司徒龍:BAAAKgAECgYIBgAAAA==.',['司文']='司文人:BAABKgAFFH8GAAIEAAMIZRqAIQDtAAAEAAMIZRqAIQDtAAAAAA==.',['吃芝']='吃芝士汉堡:BAAAKgAECgYICwAAAA==.',['名字']='名字丶孤寒:BAAAKgAECggIDgAAAA==.',['呆欧']='呆欧:BAAAKgAECgEIAQAAAA==.',['呆萌']='呆萌小瓜皮:BAAAKgADCgEIAQAAAA==.',['和你']='和你说不走:BAABKgAFFH8FAAIEAAUImA2aHAALAQAEAAUImA2aHAALAQAAAA==.',['和谐']='和谐杀手:BAAAKgADCgMIAwAAAA==.',['咕噜']='咕噜咕噜咕噜:BAAAKgADCggIDwAAAA==.',['咪猪']='咪猪:BAAAKgAECgcICgAAAA==.',['哈侬']='哈侬白侬:BAAAKgAECgQIBAAAAA==.',['哈哈']='哈哈嘻嘻:BAAAKgAECgMIAwAAAA==.',['哈基']='哈基法:BAAAKgAECgEIAQAAAA==.',['哎嘿']='哎嘿就是玩:BAACKgAFFH8OAAIUAAcIBhHTLgAtAQAUAAcIBhHTLgAtAQAqAAQKfxkAAhQACAhhHgw8ADsCABQACAhhHgw8ADsCAAAA.',['哔哩']='哔哩哔哩里:BAAAKgAECgcIBwAAAA==.',['哦耶']='哦耶耶:BAABKgAFFH8GAAIUAAYI+xzSIABsAQAUAAYI+xzSIABsAQAAAA==.',['善射']='善射善撸:BAAAKgAECgMIAwAAAA==.',['喝气']='喝气泡水打嗝:BAABKgAFFH8eAAMEAAgIQRprBAAzAgAEAAgIWhlrBAAzAgAFAAMIBwk6KACvAAAAAA==.',['噬魂']='噬魂风暴:BAAAKgAECgEIAQAAAA==.',['圣丶']='圣丶光:BAABKgAECn8ZAAMRAAgIeQwoJwAcAQARAAgIeQwoJwAcAQAUAAIICwN4cwE2AAAAAA==.',['圣光']='圣光信仰丶:BAAAKgADCgMIAwAAAA==.圣光守护者:BAAAKgAECgIIAgAAAA==.圣光守护者丶:BAAAKgADCggICAAAAA==.圣光的挽歌:BAAAKgAECgcIDQAAAA==.',['在玩']='在玩两年吧:BAAAKgADCgcIBwAAAA==.',['地狱']='地狱撕裂者:BAABKgAFFH8SAAMJAAMIOBWdHgDaAAAJAAMIixOdHgDaAAAXAAMI8A9wDQCVAAAAAA==.',['墨未']='墨未言泽:BAABKgAFFH8IAAIIAAgIfxYdAgAAAgAIAAgIfxYdAgAAAgAAAA==.',['墨香']='墨香随风丶:BAAAKgAECggICAAAAA==.',['壹厘']='壹厘蛋:BAACKgAFFH8TAAITAAMIaR+0HwAGAQATAAMIaR+0HwAGAQAqAAQKfy4AAxMACAhrI0ADAOMCABMACAhrI0ADAOMCAAgACAg9EgIMAH8BAAAA.',['大内']='大内高手:BAABKgAFFH8YAAIBAAYIJBG6CgAiAQABAAYIJBG6CgAiAQAAAA==.',['大头']='大头娃娃:BAAAKgADCggICAAAAA==.',['大概']='大概是好人:BAAAKgAECgIIAgAAAA==.',['大空']='大空异:BAACKgAFFH8SAAQCAAgI5QyiBQDeAQACAAgI5QyiBQDeAQADAAIICgNZJwBXAAABAAIIGAI2PABNAAAqAAQKfxgABAIACAh0E29AABQBAAIABwh0E29AABQBAAMABAhSCrdbAH8AAAEAAQgAAGSkAAAAAAAA.',['大美']='大美妞儿:BAAAKgAECggIEgAAAA==.',['天崽']='天崽菌团酋长:BAAAKgAFFAQIBAAAAA==.',['天洛']='天洛祆:BAAAKgAECggIDQAAAA==.',['天生']='天生强悍:BAAAKgADCgMIAwAAAA==.',['天空']='天空城主:BAABKgAFFH8MAAIFAAgIoSC+BgAbAgAFAAgIoSC+BgAbAgAAAA==.',['奥丁']='奥丁丶朮申:BAAAKgAECgQIBAAAAA==.',['奥术']='奥术炮台:BAAAKgADCgUIBQAAAA==.',['奶不']='奶不住了:BAAAKgAFFAQIBAAAAA==.',['奶萨']='奶萨:BAAAKgAECgEIAQAAAA==.',['妖孽']='妖孽:BAAAKgAECggIDwAAAA==.',['宇翔']='宇翔呆呆:BAAAKgAECgQIBAAAAA==.',['寒光']='寒光照征衣:BAAAKgADCgEIAQAAAA==.',['射普']='射普琴科:BAAAKgAFFAQIBAAAAA==.',['小伊']='小伊万:BAABKgAFFH8dAAMNAAgIiB/pAADlAQAYAAgIKhyHAgCBAgANAAYI5SPpAADlAQAAAA==.',['小奶']='小奶赛:BAABKgAFFH8GAAIWAAYIoBPsDgBjAQAWAAYIoBPsDgBjAQAAAA==.',['小牛']='小牛带花:BAAAKgAFFAEIAQAAAA==.',['小萌']='小萌妹:BAAAKgADCgMIAwAAAA==.',['小鬣']='小鬣人:BAAAKgAECgEIAQAAAA==.',['小龙']='小龙人丶:BAAAKgAECgMIAwAAAA==.',['尛筱']='尛筱蛋:BAAAKgAECgQIBAAAAA==.',['山海']='山海有鸣:BAAAKgAECggICAAAAA==.',['布劳']='布劳缪克斯:BAABKgAFFH8MAAMPAAgI+hp0EQAXAQAPAAQIxxR0EQAXAQAOAAQIPSNIJAADAQAAAA==.',['布莱']='布莱克警长:BAAAKgAECgUIBQAAAA==.',['帅气']='帅气最俊朗:BAAAKgAECggIEAAAAA==.',['年轻']='年轻的加摩尔:BAAAKgAFFAQIBAAAAA==.',['幼儿']='幼儿园小班:BAABKgAFFH8GAAIZAAYI1hL8AwBdAQAZAAYI1hL8AwBdAQABKgAFFAgIAgASAAAAAA==.',['彬长']='彬长之歌:BAAAKgADCggICAAAAA==.',['忆思']='忆思凉:BAAAKgADCggICAAAAA==.',['恶魔']='恶魔去哪了:BAAAKgAECgMIAwAAAA==.',['悟天']='悟天克斯灬:BAAAKgAECggIDgAAAA==.',['悠悠']='悠悠子兮:BAAAKgAECgYIBgAAAA==.',['想个']='想个好名难:BAACKgAFFH9JAAMJAAgIuSGqBABdAgAJAAgI8x6qBABdAgAaAAUIYR35BgCmAQAqAAQKfzgAAwkACAi0JQQCAAkDAAkACAi0JQQCAAkDABoABghjHdkZAOQBAAAA.',['懒回']='懒回顾:BAAAKgAECgEIAQAAAA==.',['懵犇']='懵犇:BAACKgAFFH8OAAIUAAQI/BnmOwD+AAAUAAQI/BnmOwD+AAAqAAQKfyoAAxQACAigIwMIAL0CABQACAigIwMIAL0CABEAAQixCMVaAB0AAAAA.',['懿明']='懿明:BAAAKgAECgYIDAAAAA==.',['懿菲']='懿菲菲:BAAAKgAECgYIDwAAAA==.',['我不']='我不是死神丶:BAAAKgAECggICAAAAA==.',['战耀']='战耀天下:BAAAKgAECgEIAQAAAA==.',['手段']='手段:BAACKgAFFH8aAAMJAAQIlx4XDwD+AAAJAAQIBxYXDwD+AAAaAAMI+hqwEgDwAAAqAAQKfyoAAxoACAiRIgoCAMYCABoACAgFIgoCAMYCAAkACAhAHzcSAHUCAAAA.',['托马']='托马斯旋:BAACKgAFFH8OAAIJAAMINhsBGgDuAAAJAAMINhsBGgDuAAAqAAQKfzkAAwkACAjgIJYEAJQCAAkACAjgIJYEAJQCABcACAj4B2IUANEAAAAA.',['扫扫']='扫扫:BAABKgAFFH8RAAIUAAMIJQRvNACQAAAUAAMIJQRvNACQAAAAAA==.',['扭头']='扭头瞬间丶:BAAAKgAECgUIBgAAAA==.',['把头']='把头埋低:BAAAKgAECgYIBgABKgAFFAYIGAAEAMkiAA==.',['掩耳']='掩耳:BAAAKgADCgMIAwAAAA==.',['斗哦']='斗哦:BAAAKgAECgIIAgAAAA==.',['新青']='新青联十八号:BAAAKgAFFAYIAQAAAA==.',['无与']='无与伦比:BAAAKgAECgQIAgAAAA==.',['无可']='无可匹敌:BAABKgAECn8ZAAMNAAgILxGbHQADAQAYAAgIig63QAAIAQANAAYIYQ2bHQADAQAAAA==.',['无敌']='无敌丶:BAAAKgAECgYIEAAAAA==.无敌铁锤:BAAAKgADCgQIBAAAAA==.',['日向']='日向夏橘:BAABKgAFFH8GAAIbAAYIqQsFEgAaAQAbAAYIqQsFEgAaAQAAAA==.',['星尘']='星尘龙:BAAAKgAECgQIBAAAAA==.',['春丽']='春丽:BAAAKgADCgEIAQAAAA==.',['晖哥']='晖哥真是帅:BAABKgAFFH8IAAMGAAQIbRTtCwDPAAAGAAMIbRTtCwDPAAAQAAEIAADeQwAAAAAAAA==.',['暗夜']='暗夜德:BAAAKgAECgIIAgAAAA==.',['曼朱']='曼朱沙华:BAAAKgAFFAQIBAAAAA==.',['月光']='月光寒:BAABKgAFFH8QAAICAAYI7hh2AQDKAQACAAYI7hh2AQDKAQAAAA==.',['月色']='月色丶:BAAAKgAECggIDgAAAA==.',['未末']='未末流年:BAAAKgAFFAgIBAAAAA==.',['杀戮']='杀戮之末:BAAAKgAFFAQIBAAAAA==.',['桂丶']='桂丶言葉:BAAAKgADCggICAAAAA==.',['桜花']='桜花的羽根:BAAAKgAECgEIAQAAAA==.',['梦山']='梦山狐影:BAAAKgAECgQIBQAAAA==.',['梦见']='梦见小熊丶:BAAAKgAFFAQIBAAAAA==.',['梨噗']='梨噗:BAAAKgAECggICAAAAA==.',['武凡']='武凡达:BAABKgAFFH8FAAIbAAUI+Q99BgBCAQAbAAUI+Q99BgBCAQAAAA==.',['殇丶']='殇丶木木:BAAAKgAECgQIBAAAAA==.',['毒奶']='毒奶丶敢吃么:BAAAKgAECggICAAAAA==.',['毛栗']='毛栗子:BAAAKgADCgEIAQAAAA==.',['沛公']='沛公丶:BAAAKgADCggICAAAAA==.',['河蟹']='河蟹杀手:BAAAKgAECgEIAQAAAA==.',['法法']='法法可游:BAAAKgADCgEIAQAAAA==.',['法热']='法热儿:BAAAKgAFFAIIAgAAAA==.',['泡狐']='泡狐龙:BAAAKgAECgUIBQAAAA==.',['流年']='流年淡漠红尘:BAABKgAFFH8IAAIQAAQINhJvHQDeAAAQAAQINhJvHQDeAAAAAA==.',['淡淡']='淡淡的仙儿:BAAAKgAECgUIBwAAAA==.淡淡的痛:BAAAKgAECgIIAgAAAA==.',['深海']='深海活鱼:BAABKgAFFH8YAAQUAAgIXx0uBQB/AgAUAAgIXx0uBQB/AgAcAAUIpgMxDwDJAAARAAIIawihJQBfAAAAAA==.',['清香']='清香:BAAAKgAECgcICQAAAA==.',['火爆']='火爆小腰花:BAABKgAECn8ZAAIJAAgIGCLZEgBEAgAJAAgIGCLZEgBEAgAAAA==.',['灵芝']='灵芝孢子油:BAAAKgAECgUIBQAAAA==.',['焮焮']='焮焮丶最可爱:BAAAKgAECgUIBQAAAA==.',['熊大']='熊大宝:BAAAKgADCggICgAAAA==.',['熊摆']='熊摆摆:BAAAKgAFFAYIAwAAAA==.',['熊猫']='熊猫丶:BAAAKgADCggICAAAAA==.熊猫大侠:BAAAKgAECgQIBAAAAA==.',['熙熙']='熙熙见豆就吃:BAAAKgAECgcIDwAAAA==.',['燃烧']='燃烧的嗨毛:BAAAKgAECgcICQAAAA==.燃烧的鸠毛:BAAAKgAFFAQIBAAAAA==.',['爆裂']='爆裂黎明:BAAAKgAECgEIAQAAAA==.',['爲妳']='爲妳灬疯狂:BAAAKgAECgQIBAAAAA==.爲妳灬痴狂:BAAAKgAECgQIBQAAAA==.',['牛牪']='牛牪无敌:BAAAKgADCgQIBAAAAA==.',['狩断']='狩断:BAACKgAFFH8GAAIdAAMIoBIIDADiAAAdAAMIoBIIDADiAAAqAAQKfxgAAh0ACAg8ISACALwCAB0ACAg8ISACALwCAAEqAAUUBggaAAkAlx4A.',['狻猊']='狻猊猈吽:BAAAKgADCggICAAAAA==.',['王小']='王小丹:BAAAKgAFFAQIBAABKgAFFAgIDgAOAEoXAA==.',['珐柯']='珐柯游:BAACKgAFFH8GAAIGAAMI0w0xDADBAAAGAAMI0w0xDADBAAAqAAQKfxUAAgYACAgHHcsFAGQCAAYACAgHHcsFAGQCAAAA.',['理查']='理查德:BAAAKgADCggICAAAAA==.',['瑞什']='瑞什么瑞:BAAAKgAECggIEQAAAA==.',['瑞叔']='瑞叔耐你:BAAAKgAECggICgAAAA==.',['瓜子']='瓜子:BAAAKgAFFAEIAQAAAA==.',['瓦帕']='瓦帕努墨姬:BAAAKgAECgcIBwAAAA==.',['甘木']='甘木槿:BAAAKgAECggICwAAAA==.',['甜苞']='甜苞米糊糊:BAAAKgAECgYIEwAAAA==.',['生化']='生化炮台:BAAAKgAECgMIAwABKgAFFAcIKwAYAEkgAA==.',['白银']='白银胖锴:BAAAKgADCgQIBAAAAA==.',['白霪']='白霪之手:BAABKgAFFH8GAAIUAAMIXg8cJgDZAAAUAAMIXg8cJgDZAAAAAA==.',['百变']='百变神牛:BAAAKgAECgEIAQAAAA==.',['眼罩']='眼罩:BAABKgAECn8eAAITAAgIbxCTUwBXAQATAAgIbxCTUwBXAQAAAA==.',['瞎子']='瞎子不迷路:BAAAKgAECgEIAQAAAA==.',['知雪']='知雪:BAAAKgADCggICAAAAA==.',['碎蛋']='碎蛋之击丶:BAAAKgAECgYIBgAAAA==.',['碴子']='碴子:BAABKgAECn8UAAIUAAYIFxt5awCBAQAUAAYIFxt5awCBAQAAAA==.',['祁闻']='祁闻冥轩:BAABKgAFFH8IAAIXAAgIoxFqAgDLAQAXAAgIoxFqAgDLAQAAAA==.',['神一']='神一样存在着:BAAAKgADCgEIAQAAAA==.',['神来']='神来气旺:BAAAKgAFFAEIAQABKgAFFAYIGAAEAMkiAA==.',['秀你']='秀你一脸:BAAAKgAECggIEAAAAA==.',['章丶']='章丶鱼哥:BAAAKgADCggICAAAAA==.',['紅蓮']='紅蓮:BAABKgAFFH8LAAIIAAQIew/jFACeAAAIAAQIew/jFACeAAAAAA==.',['繁星']='繁星尚月争荣:BAABKgAFFH8GAAIOAAYIEAezGwBAAQAOAAYIEAezGwBAAQAAAA==.',['纠结']='纠结的小熊猫:BAAAKgAECgYICQAAAA==.',['红手']='红手:BAAAKgADCgEIAQAAAA==.',['红茶']='红茶拿铁丶:BAAAKgAECgYIBgAAAA==.',['纯属']='纯属丶愚乐:BAAAKgADCggIDQAAAA==.',['练习']='练习两年了半:BAAAKgAFFAIIAgAAAA==.练习九百多天:BAAAKgAFFAQIBAAAAA==.',['经典']='经典小傻嫚:BAAAKgAFFAEIAQAAAA==.',['绿丶']='绿丶巨人:BAABKgAECn8gAAIWAAgIrwx2UABNAQAWAAgIrwx2UABNAQAAAA==.',['習惯']='習惯微笑:BAAAKgAECggICAAAAA==.',['老强']='老强尼秦腔团:BAAAKgADCgMIAwAAAA==.',['老杰']='老杰克京剧团:BAAAKgADCggICAAAAA==.',['耐撕']='耐撕嘀很:BAAAKgAECgYICQAAAA==.',['联盟']='联盟矮小法:BAAAKgAFFAQIBAAAAA==.',['肆意']='肆意的风:BAABKgAFFH8MAAIFAAQImhzrIgD9AAAFAAQImhzrIgD9AAAAAA==.',['脾气']='脾气妞妞:BAAAKgADCgYIBgAAAA==.',['臻纯']='臻纯牛奶:BAAAKgAECgYIBwAAAA==.',['艺术']='艺术就是爆炸:BAAAKgAFFAQIBAAAAA==.',['艾斯']='艾斯艾斯:BAAAKgADCggIDwAAAA==.艾斯艾沐:BAACKgAFFH8PAAIWAAMIXB57IQDzAAAWAAMIXB57IQDzAAAqAAQKfyoAAhYACAgbI0EaACoCABYACAgbI0EaACoCAAAA.',['艾米']='艾米莎:BAAAKgAECgMIBQAAAA==.',['花开']='花开花落:BAAAKgAECgIIAgAAAA==.',['花村']='花村彭于晏丶:BAAAKgAECgYIBgAAAA==.',['花泽']='花泽灬泪:BAABKgAFFH8GAAIaAAYIdQsEDQA/AQAaAAYIdQsEDQA/AQAAAA==.',['花羔']='花羔红点斑鲑:BAAAKgAECgIIBAAAAA==.',['莫莫']='莫莫伽:BAACKgAFFH8YAAMEAAYIySJNAADxAQAEAAYIySJNAADxAQAFAAIIChgNMgCVAAAqAAQKfxcAAgQACAg8JWkCAPICAAQACAg8JWkCAPICAAAA.',['菠萝']='菠萝大哥大:BAAAKgADCgEIAQAAAA==.菠萝菠萝蜜丶:BAAAKgAECgcICgAAAA==.',['蓝色']='蓝色的风:BAAAKgAECgEIAQAAAA==.',['蔫屁']='蔫屁:BAAAKgAECggIEgAAAA==.',['薄暮']='薄暮的艾琳娜:BAAAKgAFFAQIBAAAAA==.薄暮知秋:BAAAKgAECgMIAwAAAA==.',['蛮锤']='蛮锤:BAAAKgAECgEIAwAAAA==.',['西瓜']='西瓜牛牛:BAABKgAECn8VAAIJAAYIbQ/IQwAIAQAJAAYIbQ/IQwAIAQAAAA==.',['西门']='西门四泉:BAAAKgAECggICwAAAA==.',['言多']='言多必失啊:BAABKgAFFH8cAAIOAAgIVyL4AwB3AgAOAAgIVyL4AwB3AgAAAA==.',['请问']='请问飞机去哪:BAAAKgAECgEIAQAAAA==.',['谈笑']='谈笑风声:BAAAKgAECggICwAAAA==.',['贰零']='贰零伍文哥:BAAAKgADCgYICQAAAA==.',['起名']='起名字太难了:BAAAKgAECggIEwAAAA==.',['趙小']='趙小灯:BAABKgAECn8eAAIKAAcIPRGwWwBHAQAKAAcIPRGwWwBHAQAAAA==.',['足道']='足道也是道:BAAAKgAECgQIBAAAAA==.',['路非']='路非:BAAAKgADCgIIAgAAAA==.',['跳啊']='跳啊跳啊跳:BAAAKgADCgEIAQAAAA==.',['辣目']='辣目脚趾:BAAAKgAFFAQIBAABKgAFFAgIDAAQAGwPAA==.',['迎春']='迎春花儿粉:BAABKgAECn8UAAIUAAgIbyOMKwBRAgAUAAgIbyOMKwBRAgAAAA==.',['这脸']='这脸太靓了:BAAAKgAECgYIDAAAAA==.',['迦壠']='迦壠:BAAAKgAECggIEwAAAA==.',['迷离']='迷离的双眸:BAAAKgAECgUICAAAAA==.',['速趴']='速趴塞呀仁:BAABKgAFFH8FAAITAAQIVAz2LQB6AAATAAQIVAz2LQB6AAAAAA==.',['造梦']='造梦:BAAAKgADCgQIBAAAAA==.',['遙控']='遙控器:BAAAKgAECgYIBgAAAA==.',['酋长']='酋长:BAAAKgADCggIEAAAAA==.',['酷奇']='酷奇布拉达:BAACKgAFFH8FAAITAAMIXhO+KQDQAAATAAMIXhO+KQDQAAAqAAQKfxoAAhMACAiQGRUzAJABABMACAiQGRUzAJABAAAA.',['酸酸']='酸酸梅子酒:BAABKgAFFH8IAAIdAAYIKRU7DwBeAQAdAAYIKRU7DwBeAQAAAA==.',['鑫泽']='鑫泽塔琼斯:BAAAKgAECgQIBgAAAA==.',['锋魔']='锋魔丶格莱尔:BAAAKgAECgQIBQAAAA==.',['锐羽']='锐羽丶:BAAAKgADCggICAAAAA==.',['锦瑟']='锦瑟弦:BAAAKgAFFAEIAQAAAA==.',['闲来']='闲来一老翁:BAAAKgAECgEIAQAAAA==.',['阿斯']='阿斯蒂芬芬:BAAAKgAECgUIBgAAAA==.',['陆子']='陆子野:BAAAKgAECggICAAAAA==.',['陆拾']='陆拾级新手:BAAAKgAFFAEIAQAAAA==.',['随清']='随清风:BAAAKgADCggICAAAAA==.',['难受']='难受人:BAAAKgAECgUIBQAAAA==.',['離落']='離落:BAACKgAFFH8TAAMKAAQImhNQGgDWAAAKAAQImhNQGgDWAAALAAIIDw+rFABjAAAqAAQKfx0AAwoACAgGGcszANsBAAoACAgGGcszANsBAAsABAgXHVw9APEAAAAA.',['雪绵']='雪绵豆沙:BAAAKgAFFAEIAQAAAA==.',['雾丨']='雾丨小桶:BAAAKgAECgQIBgAAAA==.',['青涩']='青涩小芒果:BAAAKgAECggICAAAAA==.',['风行']='风行小中褚:BAAAKgADCgEIAQAAAA==.',['首席']='首席奥术师:BAAAKgADCgIIAgAAAA==.',['骑千']='骑千人:BAAAKgADCgYIBwAAAA==.',['骑小']='骑小猪赶夕阳:BAAAKgAFFAQIBAAAAA==.',['魔人']='魔人布欧灬:BAAAKgAFFAQIBAAAAA==.',['魔法']='魔法炮台:BAACKgAFFH8rAAQYAAUISSBgGgAyAQAYAAQIeCRgGgAyAQANAAQI/hqUEQCvAAAMAAEIAABxIgAAAAAqAAQKfz4ABBgACAhsJA8DAOECABgACAhsJA8DAOECAAwABggDFmc5AA8BAA0ABQigG+YaAAIBAAAA.',['麥丶']='麥丶克基:BAACKgAFFH8IAAIUAAQIoiZBHADxAAAUAAQIoiZBHADxAAAqAAQKfxQAAxQABwjTGK6ZAGQBABQABwijFa6ZAGQBABEABAisD6Q9AJgAAAAA.',['麥克']='麥克丶基:BAABKgAFFH8KAAQaAAUI+RQOEwDsAAAaAAQI0BsOEwDsAAAJAAQIkBURIADTAAAXAAEIdABoGAApAAAAAA==.',['黄明']='黄明轩单王:BAAAKgAECggICAAAAA==.',['黏苞']='黏苞米糊糊:BAAAKgAECggICQAAAA==.',['黛尔']='黛尔瑞丶落晨:BAAAKgAECggICAAAAA==.',['黯淡']='黯淡木槿花:BAAAKgAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end