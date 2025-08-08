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
 local lookup = {'Rogue-Assassination','Rogue-Subtlety','Warrior-Arms','Warrior-Fury','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Priest-Holy','Warlock-Demonology','Priest-Shadow','Priest-Discipline','Druid-Restoration','Shaman-Restoration','Hunter-Marksmanship','Monk-Mistweaver','Druid-Balance','Shaman-Enhancement','DemonHunter-Havoc','Warlock-Destruction','Warlock-Affliction','Evoker-Devastation','Warrior-Protection','Druid-Guardian','Hunter-BeastMastery','Mage-Frost','DemonHunter-Vengeance','Mage-Fire','Unknown-Unknown',}; local provider = {region='CN',realm='库德兰',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Ann:BAABKgAFFH8bAAMBAAgIXxw0BABgAgABAAgIXxw0BABgAgACAAQIqhj2BgD4AAAAAA==.',At='Atlantis:BAACKgAFFH8TAAMDAAMIsCAYGQDBAAADAAIIESAYGQDBAAAEAAMIUxr/GwCnAAAqAAQKfxwAAwMACAg6Iv4KAGQCAAMABwhLI/4KAGQCAAQABwjFGSYtANIBAAAA.',Be='Beforetime:BAAAKgAFFAcIAQAAAA==.',Ch='Chaons:BAAAKgADCggICAAAAA==.',Do='Dowant:BAAAKgADCggICQAAAA==.',Gl='Gloria:BAABKgAFFH8UAAQFAAgICBbgAQBcAgAFAAgI0RXgAQBcAgAGAAgIcBBQBAC0AQAHAAQIbAXwGQCWAAAAAA==.',Ji='Jixiegeming:BAACKgAFFH8QAAIIAAMISBmiSQDbAAAIAAMISBmiSQDbAAAqAAQKfzcABAgACAjtHswxADgCAAgACAjtHswxADgCAAkABwiHE1oMAF0BAAoABgjBBnk7AKoAAAAA.',Ju='Junf:BAAAKgADCggIDAAAAA==.',Li='Linbei:BAAAKgAECgYIBgAAAA==.',Lu='Lunaris:BAABKgAFFH8GAAILAAYIOBavDABZAQALAAYIOBavDABZAQAAAA==.',Mi='Miquella:BAACKgAFFH8mAAILAAQIFSMkEwAZAQALAAQIFSMkEwAZAQAqAAQKf2QAAgsACAhrJj8CAO4CAAsACAhrJj8CAO4CAAAA.',Mo='Monicaya:BAABKgAECn8UAAIMAAcI5BOSJQBrAQAMAAcI5BOSJQBrAQAAAA==.',Na='Nausicca:BAACKgAFFH8OAAMLAAMIPxQgEgC0AAALAAMIPxQgEgC0AAANAAEIjhL6GgA6AAAqAAQKfyMABAsACAgoGS0nALMBAAsACAh6Fy0nALMBAA4ABgjbEqI8ACYBAA0ABQjnDg9QAG0AAAAA.',Pl='Playermvmcyg:BAAAKgAECgQIBAAAAA==.',Po='Popo:BAAAKgADCggICAAAAA==.',Ry='Rykard:BAACKgAFFH8RAAIPAAMI7yKTDwAjAQAPAAMI7yKTDwAjAQAqAAQKfz0AAg8ACAgIJe0CANUCAA8ACAgIJe0CANUCAAEqAAUUBAgmAAsAFSMA.',Sg='Sggcd:BAAAKgADCgMIAwAAAA==.',So='Soyairis:BAABKgAFFH8IAAIQAAgIew8QBwDZAQAQAAgIew8QBwDZAQAAAA==.',Sp='Spike:BAAAKgAECggICAAAAA==.',Tr='Tresa:BAACKgAFFH8RAAIRAAMI7w2SGACiAAARAAMI7w2SGACiAAAqAAQKfwwAAhEABAgEEPZNAOUAABEABAgEEPZNAOUAAAAA.',Vo='Vor:BAAAKgAFFAcIBAAAAA==.',Yi='Yiyayo:BAAAKgAFFAQIBAAAAA==.',['不会']='不会奶的鹌鹑:BAAAKgAECggICAAAAA==.',['东尼']='东尼乔巴:BAAAKgAFFAgIAwAAAA==.',['丰川']='丰川祥子:BAAAKgADCgYIBgAAAA==.',['丿听']='丿听说丶:BAAAKgAECggIDgABKgAFFAgICgASAHUSAA==.',['九幽']='九幽狱蝶:BAABKgAFFH8GAAIEAAQI7x3QCwAMAQAEAAQI7x3QCwAMAQABKgAFFAgIFAATAFUiAA==.',['二十']='二十周年死骑:BAAAKgAECggICAAAAA==.二十周年萨满:BAABKgAFFH8IAAIQAAgIyA79BQDxAQAQAAgIyA79BQDxAQAAAA==.',['二宝']='二宝耶:BAABKgAECn8YAAIUAAYIRwsoOQD/AAAUAAYIRwsoOQD/AAAAAA==.',['会笑']='会笑的狼:BAABKgAFFH8MAAMDAAYI5R3rCQD0AAADAAYICB3rCQD0AAAEAAQIrQyhGAC9AAAAAA==.',['伯爵']='伯爵:BAABKgAFFH8JAAIVAAUIxxBnEgD2AAAVAAUIxxBnEgD2AAAAAA==.',['伶俐']='伶俐鬼:BAABKgAFFH8MAAMTAAgI2xMXDADAAQATAAcIDhEXDADAAQAPAAIIpgldJgCMAAAAAA==.',['元素']='元素应我召唤:BAAAKgAECgQIBAAAAA==.',['光盾']='光盾人:BAABKgAFFH8KAAIIAAYIzSOiFgCnAQAIAAYIzSOiFgCnAQAAAA==.',['克里']='克里斯汀碧:BAAAKgAFFAEIAQAAAA==.',['六氓']='六氓:BAAAKgAECgQIBQAAAA==.',['冰柔']='冰柔水瓶:BAAAKgADCgQIBAAAAA==.',['冷月']='冷月酆神:BAAAKgAFFAIIAwAAAA==.',['凛寒']='凛寒:BAAAKgAFFAQIBAAAAA==.',['十八']='十八翼复仇者:BAAAKgAECgQIBAAAAA==.十八翼虚空禅:BAABKgAECn8UAAISAAgIaR2cIgDdAQASAAgIaR2cIgDdAQAAAA==.十八翼铸光者:BAAAKgAECgMIAwAAAA==.',['卓尔']='卓尔文:BAABKgAFFH8IAAIIAAgIhRJjCwASAgAIAAgIhRJjCwASAgAAAA==.',['卡琳']='卡琳娜斯:BAAAKgAECgQICQAAAA==.',['变成']='变成小野猪:BAAAKgADCggIEAAAAA==.',['叮叮']='叮叮咚:BAAAKgAECgcIDQAAAA==.叮叮铛铛:BAAAKgAECgYICwAAAA==.',['叮铛']='叮铛叮:BAAAKgADCgQIBwAAAA==.叮铛铛:BAAAKgAECggICAAAAA==.叮铛铛叮:BAAAKgAECgQIBAAAAA==.',['吃又']='吃又吃不饱:BAAAKgAECgQIBgAAAA==.',['吹枫']='吹枫灬潇灑:BAAAKgAECgEIAQAAAA==.',['吹风']='吹风牛皮:BAAAKgADCggICAAAAA==.',['哈娜']='哈娜:BAABKgAECn8RAAIHAAgISheqMADwAQAHAAgISheqMADwAQAAAA==.',['哟呵']='哟呵:BAABKgAFFH8GAAIJAAYIBBN/AgBiAQAJAAYIBBN/AgBiAQAAAA==.',['哪个']='哪个有我狠:BAAAKgAECgcIBwAAAA==.',['喵帕']='喵帕丝:BAAAKgAECggICQAAAA==.',['嘟嘟']='嘟嘟熊:BAAAKgAECgUIBQAAAA==.',['圣光']='圣光永恒:BAABKgAFFH8MAAMIAAgI4xGNEQDRAQAIAAgI4xGNEQDRAQAKAAQI8w09CADUAAAAAA==.圣光牛牛:BAAAKgADCgEIAQAAAA==.',['圣域']='圣域油菜:BAACKgAFFH8PAAQIAAMImQokXwCyAAAIAAMImQokXwCyAAAJAAMIGwdLEAB8AAAKAAII2QjQDgBiAAAqAAQKfxoABAoACAgtE70qABEBAAoABgjlEr0qABEBAAgABwgcFQ/GABABAAkAAgiWCjhTADYAAAAA.',['地狱']='地狱:BAABKgAECn9FAAQMAAgIAyJoEAAIAgAMAAcIJR9oEAAIAgAWAAcIzR48LQBhAQAXAAUIbROYKgCtAAAAAA==.',['坐看']='坐看枫林晚:BAAAKgAECgYIBgAAAA==.',['夏末']='夏末的蔷薇:BAABKgAFFH8GAAIIAAYIFBayIABsAQAIAAYIFBayIABsAQAAAA==.',['大神']='大神龙:BAABKgAFFH8MAAIYAAgIPh5+BwAQAgAYAAgIPh5+BwAQAgAAAA==.',['大酱']='大酱军:BAAAKgAECgUIBwAAAA==.',['天下']='天下有个贼:BAAAKgAECgcICQAAAA==.',['天从']='天从云:BAAAKgAECgcICAAAAA==.',['奥丝']='奥丝法蕾亚:BAABKgAFFH8PAAMHAAYIxSBuDADIAQAHAAYIxSBuDADIAQAGAAYIARp1CQB+AQAAAA==.',['奶个']='奶个锤锤:BAABKgAECn8dAAITAAcIlBEjWgBMAQATAAcIlBEjWgBMAQAAAA==.',['姬伯']='姬伯昌:BAAAKgAFFAQIBAAAAA==.',['安全']='安全村村花:BAABKgAFFH8GAAIGAAYICxU1DQBDAQAGAAYICxU1DQBDAQAAAA==.',['宝宝']='宝宝鱼:BAAAKgADCggICAAAAA==.',['寂寞']='寂寞来了:BAAAKgAFFAEIAQAAAA==.',['小小']='小小文:BAAAKgAECgYIBwAAAA==.',['小污']='小污亀:BAAAKgADCgQIBAAAAA==.',['小猪']='小猪吃得饱:BAAAKgAECggICAAAAA==.',['小钻']='小钻风:BAABKgAFFH8IAAIWAAYIyRkGFwDJAAAWAAYIyRkGFwDJAAAAAA==.',['山楂']='山楂味的阳光:BAAAKgAECggIDwAAAA==.',['山猫']='山猫:BAAAKgADCgIIAgAAAA==.',['峨眉']='峨眉峰:BAAAKgAECggIDAAAAA==.',['布鲁']='布鲁斯韦恩:BAAAKgAECgcIBwAAAA==.',['帝辛']='帝辛:BAABKgAFFH8PAAIEAAYIwhesCAAgAQAEAAYIwhesCAAgAQAAAA==.',['库德']='库德兰的神:BAAAKgAFFAMIAwAAAA==.',['德之']='德之王:BAAAKgAECgUIBQAAAA==.',['德蒙']='德蒙:BAAAKgADCgYIBgAAAA==.',['心灵']='心灵鸡汤:BAAAKgAECggICAAAAA==.',['怪我']='怪我不够渣男:BAABKgAFFH8GAAIIAAYIphFWKABGAQAIAAYIphFWKABGAQAAAA==.',['憔悴']='憔悴的大伯:BAAAKgAECggIDwAAAA==.',['懒之']='懒之鱼鱼:BAACKgAFFH8LAAMCAAQIAB7cBQACAQACAAQIAB7cBQACAQABAAQIEw1THQDCAAAqAAQKfxQAAwEACAgFDxAdAJkBAAEACAjGDRAdAJkBAAIAAwi5DhUnAMIAAAEqAAUUCAgSAAEALRUA.',['我只']='我只玩联盟:BAAAKgAECgYICwAAAA==.',['我要']='我要变胖宝:BAAAKgADCggICAAAAA==.',['或许']='或许如果可能:BAABKgAFFH8KAAIEAAYIdhCSDwBcAQAEAAYIdhCSDwBcAQAAAA==.',['战姆']='战姆斯:BAABKgAFFH8MAAMZAAYINBnGAwBpAQADAAYITRP5CQBsAQAZAAYINBnGAwBpAQAAAA==.',['把我']='把我搁八队:BAACKgAFFH8QAAIWAAMI8BdAKADOAAAWAAMI8BdAKADOAAAqAAQKfxYAAhYACAiIHd8OADcCABYACAiIHd8OADcCAAAA.',['护士']='护士姐姐:BAAAKgADCgEIAQAAAA==.',['敖闰']='敖闰:BAAAKgAFFAMIAwAAAA==.',['星霜']='星霜:BAABKgAFFH8QAAIIAAQIoSBbEwAJAQAIAAQIoSBbEwAJAQAAAA==.',['暗河']='暗河大家长:BAAAKgAECgMIAwAAAA==.',['暗黑']='暗黑圣堂:BAABKgAFFH8IAAMGAAQI1xuVCwDmAAAHAAQIeBm/EgDuAAAGAAQIZhmVCwDmAAAAAA==.',['最后']='最后一个死骑:BAAAKgADCggICAAAAA==.',['月之']='月之风:BAAAKgAECggICAAAAA==.',['月夜']='月夜轻舞:BAACKgAFFH8LAAIaAAMI+RNKBwCaAAAaAAMI+RNKBwCaAAAqAAQKfyIAAxoACAj/GdENAMkBABoACAj/GdENAMkBABMAAwj9EIqUAKAAAAAA.',['月神']='月神之殇:BAAAKgAECggIEgAAAA==.月神之绯:BAAAKgAECggICQAAAA==.月神之风:BAAAKgAECgMIAwAAAA==.月神之黛:BAAAKgAECgIIAgAAAA==.',['月色']='月色不如李:BAAAKgADCggICQAAAA==.',['期货']='期货透资:BAAAKgADCgMIAwAAAA==.',['来疼']='来疼我:BAAAKgAECgQIBQAAAA==.',['树总']='树总:BAAAKgAECgIIAgAAAA==.',['樹总']='樹总:BAABKgAECn8nAAQHAAgI5xY8MQCyAQAHAAgIgBQ8MQCyAQAFAAIImhqJHAChAAAGAAEIEASvIgATAAAAAA==.',['欢欢']='欢欢熙熙乐乐:BAAAKgADCggICQAAAA==.',['死亡']='死亡如风:BAAAKgAECggICwAAAA==.',['死神']='死神:BAAAKgAFFAQIBAAAAA==.',['汐丶']='汐丶:BAAAKgAECgUICAAAAA==.',['油条']='油条沾豆桨:BAAAKgADCgQIBAAAAA==.',['泡腾']='泡腾片:BAAAKgADCggICAAAAA==.',['浪德']='浪德不得了:BAAAKgAECgYICwAAAA==.',['浪里']='浪里个波:BAAAKgAECggIDwAAAA==.',['深渊']='深渊凝视:BAAAKgAECggIEQAAAA==.',['渺小']='渺小而强大:BAAAKgADCgIIAgAAAA==.',['点不']='点不到最好:BAAAKgAECgQIBAAAAA==.',['熙年']='熙年丶:BAAAKgADCgMIAwAAAA==.',['爱夏']='爱夏路摩尔:BAABKgAFFH8GAAIHAAYIjxx9CAC2AQAHAAYIjxx9CAC2AQAAAA==.',['牙好']='牙好:BAAAKgADCgUIBQAAAA==.',['玖拾']='玖拾:BAACKgAFFH8WAAMbAAQIfRt+JgDsAAAbAAMIfRt+JgDsAAARAAEIAAA7WQAAAAAqAAQKfzcAAxsACAhzIg0cAIcCABsACAhzIg0cAIcCABEAAQjGGwidAEIAAAAA.',['甜心']='甜心小法医:BAAAKgADCgQIBAAAAA==.',['痞丶']='痞丶流:BAAAKgADCgcIBwAAAA==.痞丶贼:BAAAKgADCgYIBgAAAA==.',['白银']='白银丶离殇法:BAAAKgAECggICAAAAA==.',['皮卡']='皮卡皮卡:BAAAKgAFFAYIBAAAAA==.',['破壁']='破壁机:BAAAKgAFFAEIAQAAAA==.',['神圣']='神圣一锤:BAAAKgAFFAIIAgAAAA==.',['神父']='神父:BAAAKgAECgUIBQAAAA==.',['精神']='精神病:BAAAKgAECggIEAAAAA==.',['糖悠']='糖悠悠:BAAAKgAFFAMIBAAAAA==.',['紫妍']='紫妍:BAACKgAFFH8FAAIEAAMInAK+GQCJAAAEAAMInAK+GQCJAAAqAAQKfxQAAgQACAjSD+csAIEBAAQACAjSD+csAIEBAAAA.',['紫焱']='紫焱:BAABKgAFFH8IAAIKAAMIkQl9DACRAAAKAAMIkQl9DACRAAAAAA==.',['紫色']='紫色的梦:BAAAKgADCgEIAQAAAA==.',['绑上']='绑上帝:BAAAKgADCggIEAAAAA==.',['美丽']='美丽的小燕子:BAABKgAFFH8IAAIbAAMIwwYaIQCcAAAbAAMIwwYaIQCcAAAAAA==.',['老树']='老树盘根:BAABKgAECn8hAAMTAAgIwRUBRACaAQATAAcIdRYBRACaAQAPAAgIZw+kLQBEAQAAAA==.',['肥仔']='肥仔好叻:BAACKgAFFH8MAAIcAAMIwAxrDQCzAAAcAAMIwAxrDQCzAAAqAAQKfwoAAhwABQjKGSg1ACkBABwABQjKGSg1ACkBAAAA.肥仔好恶:BAAAKgAFFAMIAwAAAA==.',['肥皂']='肥皂:BAAAKgAECgYIBwAAAA==.',['肯德']='肯德基上校:BAABKgAECn8aAAIIAAgIKBjrKQB8AQAIAAgIKBjrKQB8AQAAAA==.肯德基骑士:BAABKgAECn8ZAAIHAAgI2w5gEwBOAQAHAAgI2w5gEwBOAQAAAA==.',['艾丽']='艾丽丝:BAACKgAFFH8KAAIQAAIIPRekIACAAAAQAAIIPRekIACAAAAqAAQKfxwAAhAACAjJHn8TAFUCABAACAjJHn8TAFUCAAAA.',['苏打']='苏打水不会输:BAABKgAFFH8OAAIIAAQI0gc+LwCoAAAIAAQI0gc+LwCoAAAAAA==.',['苏格']='苏格兰高鸟蛋:BAABKgAFFH8IAAIIAAgIrw2QCwDqAQAIAAgIrw2QCwDqAQAAAA==.',['莉雅']='莉雅拉:BAACKgAFFH8QAAMGAAYI6hEAEAAlAQAGAAYI6hEAEAAlAQAFAAMIyg/VCQDOAAAqAAQKfx4AAgUACAg4HoEIADECAAUACAg4HoEIADECAAAA.',['萨布']='萨布里多:BAACKgAFFH8bAAIQAAQISRmjFADQAAAQAAQISRmjFADQAAAqAAQKfxkAAhAACAgeGB1VAD8BABAACAgeGB1VAD8BAAAA.',['虎烈']='虎烈:BAACKgAFFH8RAAIDAAMIpwoYGwCyAAADAAMIpwoYGwCyAAAqAAQKfxgAAgMACAijFSgaAOIBAAMACAijFSgaAOIBAAAA.',['西红']='西红柿炒番茄:BAABKgAFFH8IAAIdAAQIeBHcCQCuAAAdAAQIeBHcCQCuAAAAAA==.',['請勿']='請勿喂食袙打:BAAAKgAECgQIBAAAAA==.',['赛博']='赛博胖客:BAAAKgAECggICwAAAA==.',['赛眯']='赛眯眯:BAAAKgAECggICAAAAA==.',['赤道']='赤道以北:BAACKgAFFH8MAAIeAAQI7Q7JCADLAAAeAAQI7Q7JCADLAAAqAAQKfyQAAh4ACAiyH84GAH8CAB4ACAiyH84GAH8CAAEqAAUUBggiABwA6xgA.',['超级']='超级女孩:BAAAKgAFFAIIAgAAAA==.超级美女:BAABKgAFFH8FAAILAAMIowUtGQB3AAALAAMIowUtGQB3AAAAAA==.超级美少女:BAAAKgAFFAEIAQAAAA==.超级骑士:BAAAKgAFFAMIAwAAAA==.',['跨越']='跨越柒海的风:BAABKgAFFH8GAAIQAAYIexjfCgBSAQAQAAYIexjfCgBSAQAAAA==.',['远程']='远程地皮埃斯:BAAAKgAECgQIBAAAAA==.',['适才']='适才相戏耳:BAAAKgAECgEIAQAAAA==.',['那个']='那个飒满:BAABKgAECn8UAAIQAAYITh7kRAB0AQAQAAYITh7kRAB0AQABKgAFFAQIBAAfAAAAAA==.',['邪魔']='邪魔人:BAABKgAFFH8HAAQWAAcIbRjAJgDXAAAWAAMIuxTAJgDXAAAXAAMIaSDBFQCPAAAMAAEIjRPIKABIAAAAAA==.',['邮电']='邮电部诗人:BAAAKgAECgMIAwAAAA==.',['酒酒']='酒酒:BAABKgAFFH8GAAIQAAYIBQhAGgAWAQAQAAYIBQhAGgAWAQAAAA==.',['酷怕']='酷怕:BAAAKgAECgMIAwAAAA==.',['门牙']='门牙大的奶妈:BAAAKgADCggICgAAAA==.',['闪烁']='闪烁的浪花:BAABKgAFFH8IAAIQAAgI6hctAwBHAgAQAAgI6hctAwBHAgAAAA==.',['阿斌']='阿斌:BAAAKgAECgUIBQAAAA==.',['阿特']='阿特波罗斯:BAAAKgAFFAYIBAAAAA==.',['陳老']='陳老师:BAABKgAFFH8FAAIZAAIIYA9ACQB7AAAZAAIIYA9ACQB7AAAAAA==.',['雨猫']='雨猫:BAAAKgAECgcICgAAAA==.',['霸下']='霸下:BAAAKgAECgEIAQAAAA==.',['静水']='静水散人:BAAAKgAECgUICgAAAA==.',['顶你']='顶你个肺:BAAAKgAECgYICQAAAA==.',['风顺']='风顺:BAAAKgADCggICAAAAA==.',['骑士']='骑士深渊:BAAAKgADCggIEAAAAA==.',['骑掰']='骑掰掰:BAAAKgAECgYIBgAAAA==.',['魂之']='魂之挽歌:BAABKgAFFH8IAAIHAAUI3BvXHACzAAAHAAUI3BvXHACzAAABKgAFFAgICAAEALMSAA==.',['魅影']='魅影裳:BAABKgAECn8bAAMVAAgInhtdGgAvAgAVAAgInhtdGgAvAgAdAAQIRBM0SACfAAAAAA==.',['魔法']='魔法人:BAAAKgAFFAIIAgAAAA==.',['鱼崽']='鱼崽子:BAACKgAFFH8JAAIIAAQI/xSUHADxAAAIAAQI/xSUHADxAAAqAAQKfxsAAggACAhzIXIgAJgCAAgACAhzIXIgAJgCAAAA.',['鸢白']='鸢白薇:BAAAKgAECgcIBwAAAA==.',['黑铁']='黑铁军团长:BAAAKgADCgIIAgAAAA==.',['黑魔']='黑魔女依丝特:BAAAKgAFFAYIBAAAAA==.',['龙希']='龙希尔大统领:BAAAKgAECgcIDgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end