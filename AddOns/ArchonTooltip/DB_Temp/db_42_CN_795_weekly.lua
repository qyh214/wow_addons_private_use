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
 local lookup = {'DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Druid-Restoration','DemonHunter-Havoc','Mage-Arcane','Mage-Frost','Priest-Shadow','Shaman-Restoration','Unknown-Unknown','Warlock-Destruction','Paladin-Retribution','Priest-Holy','Mage-Fire','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Shaman-Elemental','Shaman-Enhancement','Warlock-Affliction','Warlock-Demonology','Priest-Discipline','Warrior-Arms','Druid-Guardian','DeathKnight-Blood','Warrior-Fury','Warrior-Protection','Evoker-Devastation','Evoker-Preservation','DeathKnight-Frost','Paladin-Protection','Druid-Feral','Paladin-Holy','Rogue-Outlaw','Rogue-Assassination','DemonHunter-Vengeance','Hunter-Survival',}; local provider = {region='CN',realm='耳语海岸',name='CN',type='weekly',zone=42,date='2025-08-08',data={As='Asana:BAABKgAFFH8FAAIBAAQIWgaCDwD/AAABAAQIWgaCDwD/AAAAAA==.',Bi='Bige:BAAAKgAECgYIDQAAAA==.',Br='Brokenderams:BAAAKgAFFAMIAwAAAA==.',Bu='Bulkhead:BAACKgAFFH8FAAMCAAMILAyXOQCzAAACAAMILAyXOQCzAAADAAEICgaUKgArAAAqAAQKfyIAAwIACAgYGjUpAAwCAAIACAgYGjUpAAwCAAMABggIEaJWAPgAAAAA.',Co='Cool:BAAAKgAFFAQIBAAAAA==.',Cy='Cylinne:BAABKgAFFH8GAAIEAAYImCAwCwDiAQAEAAYImCAwCwDiAQABKgAFFAgIEQAFAD4jAA==.',Db='Dbxp:BAABKgAFFH8KAAICAAYIniNsBwAJAgACAAYIniNsBwAJAgAAAA==.',De='Deepsea:BAABKgAECn8aAAIGAAgIbxCyRQCRAQAGAAgIbxCyRQCRAQAAAA==.Delia:BAAAKgADCgQIAgAAAA==.',Dr='Dredwing:BAAAKgAECggICwAAAA==.Druld:BAAAKgAECgYICAAAAA==.',Ec='Ecthelion:BAAAKgADCggICAAAAA==.',Fr='Frostnova:BAACKgAFFH8HAAMHAAYIzx3HDgB8AQAHAAYIzx3HDgB8AQAIAAEIhghdHwBAAAAqAAQKfzAAAwgACAjDIzkJAL4CAAgACAjDIzkJAL4CAAcAAQjkGqKMAEsAAAAA.',Gh='Ghy:BAABKgAECn8ZAAIJAAYIrhv6LABzAQAJAAYIrhv6LABzAQAAAA==.',Go='Good:BAABKgAECn8XAAIKAAgI/h4XFQBKAgAKAAgI/h4XFQBKAgABKgAFFAQIBAALAAAAAA==.',Ho='Holynova:BAAAKgAECgQICQAAAA==.',Hu='Hugaga:BAABKgAFFH8GAAIMAAQIpBobEQDhAAAMAAQIpBobEQDhAAAAAA==.',Ka='Kaito:BAAAKgAECggICAAAAA==.',Ke='Kensou:BAABKgAFFH8eAAICAAQIthggIAANAQACAAQIthggIAANAQAAAA==.',La='Labubu:BAAAKgADCgEIAQAAAA==.',Li='Liste:BAABKgAFFH8IAAINAAgIFQizDgC2AQANAAgIFQizDgC2AQAAAA==.Liza:BAAAKgAECgYICgAAAA==.',Lu='Luna:BAAAKgAFFAIIAgAAAA==.',Mo='Mom:BAABKgAECn8jAAIOAAgIxhmGKQClAQAOAAgIxhmGKQClAQABKgAFFAQIBAALAAAAAA==.',Ne='Needherr:BAAAKgAECgQIBwAAAA==.',No='Nonce:BAAAKgAFFAgIAgAAAA==.Noworries:BAABKgAFFH8NAAQHAAQI+CAgAQAKAQAHAAQI2RkgAQAKAQAPAAQIOhJ0HADhAAAIAAQILxhnFQDBAAAAAA==.',Pa='Pander:BAACKgAFFH8lAAMQAAQIVQ1BGACnAAAQAAQIVQ1BGACnAAARAAQIxwsVJgCLAAAqAAQKfykABBAACAguGs4SAB4CABAACAguGs4SAB4CABEABwiSEl83AGoBABIAAQj0AQAAAAAAAAAA.',Pe='Pexo:BAAAKgAECggIEAAAAA==.',Pu='Purplerain:BAAAKgADCgEIAQAAAA==.',Qu='Quantum:BAAAKgAFFAUIAQAAAA==.',Re='Re:BAABKgAFFH8HAAIGAAYI+hOFFABVAQAGAAYI+hOFFABVAQAAAA==.',Ri='Rita:BAAAKgAECgQICAAAAA==.',Ru='Rubyms:BAABKgAFFH8GAAIOAAQIzhCxKgCYAAAOAAQIzhCxKgCYAAAAAA==.Rumina:BAAAKgAECgYIBgAAAA==.',Sc='Scardhymn:BAAAKgAECgYIBgAAAA==.',Sh='Shortseer:BAAAKgAECgUIBQAAAA==.',So='Soo:BAAAKgAECgcIDAABKgAFFAQIBAALAAAAAA==.',Th='Themax:BAABKgAFFH8GAAIPAAYIBxWmDABsAQAPAAYIBxWmDABsAQAAAA==.Thoughluck:BAACKgAFFH8rAAMKAAQIDyLgGwAPAQAKAAQIDyLgGwAPAQATAAQIRxY6CwDaAAAqAAQKfywABBMACAhCF18eANYBABMACAhCF18eANYBAAoACAg9FodVAD4BABQAAghEDvc8AHAAAAAA.',Ti='Tianxing:BAABKgAFFH8MAAINAAgIwhwJBgBrAgANAAgIwhwJBgBrAgAAAA==.',To='Topmoon:BAABKgAFFH8aAAMHAAgI7hrYBABQAgAHAAgI7hrYBABQAgAIAAQILwpNDQDBAAAAAA==.',Ve='Vectorw:BAAAKgAFFAgIAgAAAA==.',Xi='Xina:BAAAKgAECgYICgAAAA==.',Ze='Zerodawn:BAAAKgAFFAEIAQAAAA==.',Zh='Zhenye:BAAAKgAFFAEIAQAAAA==.Zhyu:BAACKgAFFH9DAAQVAAgIKSYXBQA1AQAMAAQInCUUGQA7AQAVAAQIaSYXBQA1AQAWAAEI3iboDwBlAAAqAAQKfzkABAwACAiSJRkUAEwCAAwACAj+IxkUAEwCABUABQh/IwAVADQBABYAAghjIxsoAGEAAAAA.',Zo='Zoe:BAAAKgAECgIIAgAAAA==.',['一个']='一个盾菇:BAAAKgADCggICAAAAA==.',['一夜']='一夜星光:BAAAKgAECgQIBAAAAA==.',['一妮']='一妮可一:BAAAKgAECggICAAAAA==.',['一宿']='一宿一:BAAAKgAECgUIBQAAAA==.',['一色']='一色彩羽:BAACKgAFFH8FAAIJAAQIuwvoHACeAAAJAAQIuwvoHACeAAAqAAQKfxoABBcACAgFHCsRAB0CABcACAgFHCsRAB0CAAkABQjcFz47ABUBAA4AAQg4D8GWAC0AAAAA.',['一路']='一路西菲尔一:BAAAKgAECgEIAQAAAA==.',['七二']='七二:BAAAKgAECgQIBAAAAA==.',['万法']='万法千宗:BAACKgAFFH8zAAIBAAUI9iEcGgBMAQABAAUI9iEcGgBMAQAqAAQKfy4AAgEACAgvJugCAAQDAAEACAgvJugCAAQDAAEqAAUUCAgYAAEApRsA.',['不二']='不二:BAAAKgAECggICAAAAA==.',['不动']='不动如山丶:BAAAKgAECgIIAgAAAA==.',['两个']='两个人的温暖:BAAAKgADCgEIAQAAAA==.',['两袖']='两袖青蛇:BAAAKgAECgMIAwAAAA==.',['丨莫']='丨莫淇洛丨:BAACKgAFFH85AAIKAAgIPiLKAgBWAgAKAAgIPiLKAgBWAgAqAAQKfzkAAgoACAjkI+cLAJcCAAoACAjkI+cLAJcCAAAA.',['丨隔']='丨隔壁老钱丨:BAAAKgAFFAIIAgAAAA==.',['个头']='个头兮兮:BAABKgAFFH8GAAIYAAYIcAYvCwBaAQAYAAYIcAYvCwBaAQAAAA==.',['丫丫']='丫丫宝宝:BAAAKgAFFAgIAwAAAA==.',['丶月']='丶月影灬星痕:BAAAKgAFFAgIAgAAAA==.',['丶玉']='丶玉景灬天池:BAAAKgAFFAgIBAAAAA==.',['丿牛']='丿牛盾:BAABKgAFFH8QAAINAAQIBBEmJgDPAAANAAQIBBEmJgDPAAAAAA==.',['乌龙']='乌龙乌龙茶:BAAAKgAFFAIIAgAAAA==.',['九天']='九天玉女:BAAAKgADCggICAAAAA==.',['书桓']='书桓丶:BAAAKgADCgEIAQAAAA==.',['乱拳']='乱拳:BAABKgAECn8gAAICAAgISB73LgDvAQACAAgISB73LgDvAQAAAA==.',['二手']='二手蔷薇:BAAAKgADCgcIBwAAAA==.',['二次']='二次元暗魂:BAABKgAFFH8IAAIZAAIIcwfFDABNAAAZAAIIcwfFDABNAAAAAA==.',['云既']='云既无心出迶:BAAAKgAECgcIBwAAAA==.',['云树']='云树绕堤沙:BAAAKgAECggIEgABKgAFFAgIPQAXALogAA==.',['五个']='五个葫芦娃:BAAAKgAFFAIIAgAAAA==.',['京东']='京东热奶茶:BAAAKgAECgMIAwAAAA==.',['人性']='人性的背叛者:BAABKgAFFH8IAAIaAAgIWAZLBgBdAQAaAAgIWAZLBgBdAQAAAA==.',['人道']='人道是战神:BAABKgAFFH8IAAMBAAYInSGcBgA6AQABAAQIWCWcBgA6AQAaAAQIeR1KLwBSAAAAAA==.',['休闲']='休闲东东:BAACKgAFFH8RAAMYAAUIdBC4FQDXAAAYAAQIdBC4FQDXAAAbAAIIAARvIAA3AAAqAAQKfyAABBgACAgfGqkbAKgBABgACAgfGqkbAKgBABsAAwgDEXVyAJIAABwAAQhrB4ZJABoAAAAA.',['依然']='依然安菲尔德:BAAAKgAFFAIIAwAAAA==.',['信仰']='信仰之歌:BAAAKgAECgcIBwAAAA==.',['修若']='修若浔风:BAAAKgAFFAQIBAAAAA==.',['修逻']='修逻:BAABKgAECn9UAAIcAAgIECVHAgDgAgAcAAgIECVHAgDgAgAAAA==.',['倒影']='倒影红尘:BAACKgAFFH8cAAIHAAUIeBH8EgD1AAAHAAUIeBH8EgD1AAAqAAQKfysABAcACAifGBsQAEsBAAcABggFHRsQAEsBAAgACAiKDWRKADwBAA8ABwgOCa9XABcBAAAA.',['倾宇']='倾宇绝宙:BAAAKgADCgQIBAAAAA==.',['倾杯']='倾杯:BAABKgAECn8gAAMXAAgIwx+zCgBnAgAXAAgIwx+zCgBnAgAJAAEIFhi1bABHAAAAAA==.',['光阴']='光阴副本:BAACKgAFFH8JAAIQAAMI+BlaDwDtAAAQAAMI+BlaDwDtAAAqAAQKfyUAAhAACAhrI78EANgCABAACAhrI78EANgCAAEqAAUUAwgTAAgAYCQA.',['兔子']='兔子不会魔法:BAAAKgAFFAQIBAAAAA==.',['六千']='六千里丶:BAAAKgAECgEIAQAAAA==.',['六指']='六指琴魔:BAAAKgAFFAMIBAAAAA==.',['冰刃']='冰刃七連舞:BAAAKgAECgYIBgAAAA==.',['冷冷']='冷冷丶:BAAAKgAFFAYIBAAAAA==.',['冷色']='冷色气息:BAAAKgADCggICgAAAA==.',['几十']='几十个圣骑:BAAAKgADCggIFwAAAA==.几十个术仕:BAAAKgAECgUIBQAAAA==.几十个猎魔人:BAAAKgAECggIEgAAAA==.',['凡心']='凡心凡萨:BAAAKgAFFAIIAgAAAA==.',['凤凰']='凤凰使者:BAAAKgAECgcICgAAAA==.',['刘铁']='刘铁蛋:BAAAKgADCgIIAgAAAA==.',['制裁']='制裁丶:BAAAKgAECggICAAAAA==.',['刺骨']='刺骨寒寒:BAAAKgAFFAEIAQAAAA==.',['副手']='副手没盾牌:BAAAKgAECggIEwAAAA==.',['北大']='北大路五月:BAAAKgAECggIEwAAAA==.',['北极']='北极没有夏天:BAAAKgAFFAQIBAAAAA==.',['医德']='医德扶人:BAAAKgAECgUICwAAAA==.',['千手']='千手熊:BAAAKgAECgQIAwAAAA==.',['半个']='半个灵魂:BAAAKgADCgQIBAAAAA==.',['单纯']='单纯的小暴力:BAABKgAECn8VAAITAAcIJh75IADDAQATAAcIJh75IADDAQAAAA==.',['南户']='南户唯:BAAAKgAECggIDQAAAA==.',['参不']='参不透:BAAAKgAFFAYIBAAAAA==.',['只有']='只有狂风:BAABKgAFFH8GAAIRAAYIPBEmNAAwAAARAAYIPBEmNAAwAAAAAA==.',['吃鸡']='吃鸡仙人:BAAAKgAECgQIBAAAAA==.',['吾自']='吾自哀木涕:BAAAKgAECgQIBAAAAA==.',['哇啦']='哇啦哇啦:BAAAKgAECggIDQAAAA==.',['哈喉']='哈喉的老腊肉:BAAAKgAECggICAAAAA==.',['哈迪']='哈迪斯:BAAAKgAECggIEgAAAA==.',['哥变']='哥变的是寂寞:BAAAKgAECgIIAgAAAA==.',['哥哥']='哥哥猛不猛:BAAAKgAECgcIDgAAAA==.',['哪吒']='哪吒三:BAAAKgAECgcICAAAAA==.',['唠啦']='唠啦丶氪唠馥:BAACKgAFFH8SAAMDAAYI+RrdAQCLAQADAAYIyxHdAQCLAQACAAYIpRqCEwBaAQAqAAQKfxcAAwMACAj0H5YVACQCAAMACAj0H5YVACQCAAIAAQjKEq4JASsAAAAA.',['啦拉']='啦拉啦种太阳:BAABKgAECn81AAMDAAgImyCqDwB9AgADAAgI2x+qDwB9AgACAAgITxt2NAAjAgAAAA==.',['喝着']='喝着百事想你:BAAAKgADCgMIAwAAAA==.',['喷起']='喷起来丶:BAABKgAFFH8LAAMdAAQIXB3FCAAOAQAdAAQIXB3FCAAOAQAeAAEI7hOtCgBAAAAAAA==.',['嘚嘚']='嘚嘚以嘚嘚:BAAAKgAFFAQIBAAAAA==.',['圣光']='圣光之橙:BAAAKgAECgcIBwAAAA==.',['圣诞']='圣诞袜:BAAAKgAFFAgIBAAAAA==.',['地滚']='地滚雷:BAABKgAECn8YAAIQAAgInhMJIQCWAQAQAAgInhMJIQCWAQAAAA==.',['基维']='基维思:BAABKgAFFH8KAAINAAMIoRjnQwDnAAANAAMIoRjnQwDnAAAAAA==.',['堕落']='堕落的旧信仰:BAAAKgAECgcIBwAAAA==.',['夏悠']='夏悠然:BAAAKgADCgEIAQAAAA==.',['夜莺']='夜莺和风:BAAAKgADCgEIAQAAAA==.',['夜过']='夜过熙攘:BAAAKgAFFAQIBAAAAA==.',['夜鹰']='夜鹰之王:BAACKgAFFH8cAAINAAQIixAnUQDNAAANAAQIixAnUQDNAAAqAAQKfxoAAg0ACAhUEPOKAIEBAA0ACAhUEPOKAIEBAAAA.',['大凉']='大凉龙雀:BAAAKgAECgMIAwAAAA==.',['大叔']='大叔的乖萝卜:BAABKgAFFH8FAAIaAAMIDwoPJwB6AAAaAAMIDwoPJwB6AAAAAA==.大叔的美学:BAAAKgADCgQIBAAAAA==.',['大地']='大地忽悠着你:BAAAKgAFFAQIBAAAAA==.',['大师']='大师住腿:BAAAKgAECgQIBAAAAA==.',['大老']='大老千:BAAAKgAECgQIBwAAAA==.',['大耳']='大耳朵波波:BAAAKgAFFAMIAwAAAA==.',['大蕉']='大蕉丶:BAAAKgAECgEIAQAAAA==.',['大貓']='大貓:BAAAKgAECggICAAAAA==.',['大麦']='大麦兜兜茶:BAAAKgADCgMIAwAAAA==.',['天启']='天启不朽:BAABKgAFFH8HAAIaAAYIAwVXGQDXAAAaAAYIAwVXGQDXAAAAAA==.',['天姥']='天姥:BAAAKgAECgYICQAAAA==.',['天王']='天王之王:BAAAKgAECgQICgAAAA==.',['天界']='天界神龙:BAAAKgAECgcICAAAAA==.',['奈拉']='奈拉丝特娜:BAABKgAECn8UAAIMAAYI7xnxKgBvAQAMAAYI7xnxKgBvAQAAAA==.奈拉丝特拉:BAABKgAECn8YAAIGAAgIihghJgDZAQAGAAgIihghJgDZAQAAAA==.',['奶人']='奶人真难:BAAAKgADCggICAAAAA==.',['奶妈']='奶妈奶死你:BAAAKgAECgQIBgAAAA==.',['如意']='如意:BAAAKgADCggICAAAAA==.',['孙永']='孙永齐:BAABKgAECn8WAAINAAgICAtnOwAdAQANAAgICAtnOwAdAQAAAA==.',['安安']='安安逸:BAABKgAFFH8JAAIQAAYIQRFXCQBTAQAQAAYIQRFXCQBTAQAAAA==.',['安帕']='安帕赫:BAAAKgAECggICAABKgAFFAgIJgAMAFUmAA==.',['宋齐']='宋齐梁陈:BAAAKgAECgIIAgAAAA==.',['宝贝']='宝贝爱天使:BAABKgAECn8oAAMHAAgIfxP2OABlAQAHAAgI4RD2OABlAQAIAAgIbRBnLwBJAQAAAA==.',['客官']='客官喝茶吗:BAAAKgADCggICAAAAA==.',['家有']='家有暖宝:BAAAKgAECgUIBQAAAA==.',['宿世']='宿世:BAAAKgAECgUICgAAAA==.',['封之']='封之不死小德:BAAAKgADCggICAAAAA==.封之不死骑士:BAABKgAFFH8FAAINAAIImBvQNgCcAAANAAIImBvQNgCcAAAAAA==.',['射雕']='射雕灬小茉莉:BAAAKgAECgEIAgAAAA==.',['小兔']='小兔子不乖:BAAAKgADCgEIAgAAAA==.',['小熊']='小熊唐尼:BAAAKgADCgQIAwAAAA==.',['小犄']='小犄角长尾巴:BAABKgAECn8YAAIKAAgIjSGLKgDhAQAKAAgIjSGLKgDhAQAAAA==.',['小狐']='小狐抓抓:BAAAKgAECggICAAAAA==.',['小痴']='小痴不忧郁:BAAAKgAECggIEwAAAA==.',['小白']='小白人:BAAAKgAECgMIAwAAAA==.',['小肥']='小肥煋:BAACKgAFFH8aAAQWAAQIihLyDgDCAAAWAAQIihLyDgDCAAAVAAMIwQWGEwCiAAAMAAEIwwquTQA5AAAqAAQKfyAABBYACAh3IHAOAB0CABYACAiJHXAOAB0CABUABAjBHHYbAP4AAAwAAwjnHDVDAP4AAAAA.',['小茉']='小茉莉:BAAAKgAECggICAAAAA==.',['小黑']='小黑家的懒猪:BAAAKgADCggICAAAAA==.',['尔玛']='尔玛依娜:BAAAKgADCgIIAgAAAA==.',['局外']='局外人死神:BAAAKgAECgQIBAAAAA==.局外人浩爷:BAAAKgAECgQICwAAAA==.',['岗笨']='岗笨熊熊:BAAAKgAECgYIBwAAAA==.',['巨富']='巨富:BAAAKgAECggICAAAAA==.',['已风']='已风干的迷茫:BAAAKgAECggIEQAAAA==.',['布林']='布林顿五千:BAAAKgAFFAMIBAAAAA==.',['布蕾']='布蕾妮妮丶:BAAAKgADCgIIAgAAAA==.',['希路']='希路达:BAABKgAFFH8QAAIDAAgI4B/VAQCwAgADAAgI4B/VAQCwAgAAAA==.',['帝国']='帝国晨曦:BAABKgAFFH8GAAINAAYIZRaOGQCSAQANAAYIZRaOGQCSAQAAAA==.',['干妹']='干妹妹:BAAAKgAECgQICAAAAA==.',['幸福']='幸福白勺泡泡:BAABKgAFFH8MAAQIAAYIahcDCgAlAQAPAAYISxRlDgBYAQAIAAUITxoDCgAlAQAHAAEI1AONRQA8AAAAAA==.幸福白勺贝贝:BAABKgAFFH8QAAMYAAYIxxwZAQDFAQAYAAYIxxcZAQDFAQAbAAYIERVzCwCUAQAAAA==.',['幻丶']='幻丶月:BAABKgAFFH8IAAIKAAgI9RWKBQD8AQAKAAgI9RWKBQD8AQAAAA==.',['开心']='开心安逸:BAAAKgAECgUICQAAAA==.',['弈殇']='弈殇:BAAAKgAECgYIBgAAAA==.',['强力']='强力熊:BAABKgAECn8sAAIRAAgISxVpHQCdAQARAAgISxVpHQCdAQAAAA==.',['当红']='当红灬俊:BAABKgAECn8tAAICAAgIXh0yJQBfAgACAAgIXh0yJQBfAgAAAA==.',['德鲁']='德鲁:BAABKgAFFH8GAAMOAAYIexNZGgDnAAAOAAUISxBZGgDnAAAJAAEI9AEWMAA2AAABKgAFFAgICAAOALsjAA==.',['忧郁']='忧郁小痴:BAAAKgAECggICgAAAA==.',['怒光']='怒光歌:BAAAKgAECgQIBAAAAA==.',['怒血']='怒血公主:BAAAKgAECgEIAQAAAA==.',['怒雨']='怒雨:BAAAKgADCgMIAwAAAA==.',['恋恋']='恋恋四叶草:BAAAKgAECgcIDQAAAA==.',['恐虐']='恐虐神选者:BAACKgAFFH8jAAQBAAYIPhf9DAAHAQABAAUImRn9DAAHAQAaAAMIaAZ/LABhAAAfAAEIDBkzEgBMAAAqAAQKfzkABAEACAi8JQ0YAHACAAEACAheJQ0YAHACAB8ABghsJJ4QAJ0BABoAAQh1GshKAEoAAAAA.',['悬凝']='悬凝空:BAAAKgAFFAgIBAAAAA==.',['慢慢']='慢慢来:BAAAKgADCgEIAQAAAA==.',['憋个']='憋个大火球:BAAAKgAECggICAAAAA==.',['我厂']='我厂已崩:BAAAKgAECgYIDAABKgAFFAIIAwALAAAAAA==.',['我吃']='我吃牛肉干:BAAAKgAECgYICQAAAA==.',['我要']='我要双持蛋刀:BAACKgAFFH8FAAIRAAUIghqRAwCLAQARAAUIghqRAwCLAQAqAAQKfxQAAhEACAgdDcNAAD4BABEACAgdDcNAAD4BAAAA.',['战争']='战争残月:BAAAKgAECgMIBgAAAA==.',['战神']='战神将:BAAAKgAECgYIBAAAAA==.',['打不']='打不过就跑吧:BAABKgAECn8bAAIIAAgIdhsZBwA9AgAIAAgIdhsZBwA9AgAAAA==.',['抓哒']='抓哒你猛吸:BAAAKgAECgYIBgAAAA==.抓哒你猛砍:BAAAKgAECgYICAAAAA==.',['招招']='招招猎猎:BAABKgAECn8jAAICAAgI5RpaOADEAQACAAgI5RpaOADEAQAAAA==.',['提灯']='提灯:BAAAKgAFFAIIAgAAAA==.',['搞不']='搞不过也上:BAAAKgAECgQICgAAAA==.',['搞事']='搞事情:BAAAKgADCgEIAQAAAA==.',['方一']='方一然:BAABKgAECn8hAAIKAAgIRhIsPQCRAQAKAAgIRhIsPQCRAQAAAA==.',['方然']='方然:BAAAKgAECgYIBgAAAA==.',['方羽']='方羽墨:BAABKgAECn8UAAIWAAgIERrSDwAOAgAWAAgIERrSDwAOAgAAAA==.方羽然:BAABKgAECn8qAAIOAAgIMRmxJQC7AQAOAAgIMRmxJQC7AQAAAA==.方羽萌:BAAAKgAECggICAAAAA==.',['无敌']='无敌小胖子:BAAAKgAECgIIAwAAAA==.',['早苗']='早苗:BAAAKgAECgYICAAAAA==.',['明前']='明前:BAACKgAFFH8QAAMgAAQIoQKwEgBbAAAgAAQIoQKwEgBbAAANAAEIvwNAXgAxAAAqAAQKfyEAAg0ACAh9F95oAMgBAA0ACAh9F95oAMgBAAEqAAUUBQgjABwASwUA.',['星宇']='星宇星宇星:BAAAKgAFFAIIAgABKgAFFAgIBAALAAAAAA==.',['映夜']='映夜:BAAAKgAECggICQAAAA==.',['晒太']='晒太阳的家猫:BAAAKgADCggICAAAAA==.',['普路']='普路佟:BAAAKgAFFAgIBAAAAA==.',['暖阳']='暖阳:BAABKgAFFH8GAAINAAIIbxAAdgB+AAANAAIIbxAAdgB+AAAAAA==.',['暗影']='暗影的狩猎者:BAAAKgAECgYICAAAAA==.',['暮光']='暮光的微笑:BAAAKgAECgYIBgAAAA==.',['曌楽']='曌楽梓:BAAAKgAFFAQIBAAAAA==.',['最后']='最后一个老千:BAAAKgAECgYICQAAAA==.',['月夜']='月夜風暴:BAABKgAFFH8KAAMBAAYIXxG1FwBfAQABAAYIXxG1FwBfAQAaAAQIYAs3FgCdAAAAAA==.',['月如']='月如霜:BAAAKgAFFAYIBAAAAA==.',['望舒']='望舒生:BAAAKgAECgMIAwAAAA==.',['李丶']='李丶書文:BAAAKgAECgMIAwAAAA==.',['松饼']='松饼猫酱:BAACKgAFFH8vAAIZAAYIIg/3AgAOAQAZAAYIIg/3AgAOAQAqAAQKfzYAAhkACAiQE2EQAEYBABkACAiQE2EQAEYBAAAA.',['柏月']='柏月之影:BAAAKgAFFAMIAgAAAA==.',['桃地']='桃地灬再不斩:BAAAKgAECgIIAgAAAA==.',['桑铎']='桑铎克里冈:BAAAKgAFFAYIBAAAAA==.',['梁宫']='梁宫:BAAAKgADCggICAAAAA==.',['梦我']='梦我的甜甜:BAABKgAFFH8MAAQVAAYILyTKAABXAQAWAAUIBSTCAgBYAQAVAAQITCbKAABXAQAMAAII2BkuHACqAAAAAA==.',['梦溪']='梦溪笔谭:BAABKgAECn8XAAIZAAgIjRa0DgC8AQAZAAgIjRa0DgC8AQAAAA==.',['梦绮']='梦绮灬丨:BAAAKgADCgMIAwAAAA==.',['梶猗']='梶猗:BAABKgAFFH8eAAIdAAQIJxjnHwDEAAAdAAQIJxjnHwDEAAAAAA==.',['楽鸽']='楽鸽:BAABKgAFFH8jAAQIAAQI1Q6mGwCkAAAIAAQI1Q6mGwCkAAAHAAQILwdjMwCWAAAPAAII8gI0DABdAAAAAA==.',['欣欣']='欣欣好宝贝:BAABKgAECn8WAAINAAYIQhuCgACWAQANAAYIQhuCgACWAQAAAA==.',['欺雪']='欺雪凌霜:BAACKgAFFH81AAIBAAYIGBz+DgCpAQABAAYIGBz+DgCpAQAqAAQKfyQAAgEACAh3HLQqAAsCAAEACAh3HLQqAAsCAAAA.',['比鲁']='比鲁斯:BAAAKgAECgcICQAAAA==.',['汤汤']='汤汤水水:BAAAKgADCgMIAwAAAA==.',['沃尔']='沃尔科夫:BAAAKgAECgIIAgAAAA==.',['没事']='没事吹吹牛:BAAAKgADCggICAAAAA==.',['沧海']='沧海无名:BAAAKgAECggICAAAAA==.',['治疗']='治疗高手:BAAAKgAECggIEQABKgAFFAQIBAALAAAAAA==.',['法丝']='法丝不是很累:BAABKgAECn8bAAIIAAYI+yBILgC9AQAIAAYI+yBILgC9AQAAAA==.',['泗鱼']='泗鱼:BAAAKgAECgIIAgAAAA==.',['泡泡']='泡泡力娜:BAAAKgAFFAgIBAAAAA==.泡泡小小:BAABKgAFFH8GAAINAAYI5BcZGgCPAQANAAYI5BcZGgCPAQAAAA==.泡泡蝴蝶:BAABKgAFFH8NAAMOAAgICxS/BQDZAQAOAAgICxS/BQDZAQAJAAEIzBLiKgBHAAAAAA==.',['流星']='流星坠落:BAACKgAFFH8zAAMEAAgIFx29AwCeAgAEAAgIFx29AwCeAgAFAAQIahfpHwCrAAAqAAQKfxwABQQACAiSHt4cAFYCAAQACAiSHt4cAFYCAAUABAhvEhZQAKMAACEAAQhJBCgxACAAABkAAQhJCDA5ABUAAAAA.',['浣花']='浣花洗剑:BAACKgAFFH8jAAIcAAUISwUtEQBzAAAcAAUISwUtEQBzAAAqAAQKfycAAxgACAgRGVoUAO0BABgACAhjGFoUAO0BABwABQj6DQgkAOIAAAAA.',['海伦']='海伦娜:BAAAKgAFFAYIAgAAAA==.',['消防']='消防小妹:BAAAKgADCggICAAAAA==.',['淡淡']='淡淡的雨:BAABKgAFFH8dAAMOAAQIBhvBFACaAAAOAAQIBhvBFACaAAAXAAEIbQKPFwAjAAAAAA==.',['深渊']='深渊之喉:BAAAKgAECggICAAAAA==.',['清粥']='清粥小菜:BAABKgAECn8VAAICAAgIoBfHPQCuAQACAAgIoBfHPQCuAQABKgAFFAUIIwAcAEsFAA==.',['清风']='清风明月:BAAAKgAECgQIBAABKgAFFAUIIwAcAEsFAA==.',['渡鸦']='渡鸦六九九:BAAAKgAECgcIEwAAAA==.渡鸦六八八:BAABKgAECn8VAAQHAAgIWCLUDwB7AgAHAAgIWCLUDwB7AgAIAAIIqhymiQB7AAAPAAIIVw1RlwBBAAAAAA==.',['溧阳']='溧阳中关村:BAAAKgAECgEIAQAAAA==.溧阳凤凰公园:BAAAKgAECggIDgAAAA==.',['漫天']='漫天星光:BAAAKgAECgIIAgAAAA==.',['灬伊']='灬伊卡丶洛斯:BAAAKgAFFAgIBAAAAA==.',['灬焱']='灬焱炎炎灬:BAAAKgADCgEIAQAAAA==.',['炎之']='炎之审判:BAABKgAECn8VAAMWAAgIthR3BwDUAQAWAAgIghR3BwDUAQAMAAYIQQvSVgC6AAAAAA==.',['炫舞']='炫舞哥:BAAAKgAECgcIEwAAAA==.',['熊猫']='熊猫斌斌:BAAAKgAFFAQIBAAAAA==.',['爱缺']='爱缺:BAAAKgAFFAIIBAAAAA==.',['爸爸']='爸爸可以哦:BAAAKgAECggIDwAAAA==.',['牛三']='牛三刀:BAAAKgAECgYIBgAAAA==.',['牛逼']='牛逼哄哄:BAAAKgAECgIIAgAAAA==.',['牧渔']='牧渔人:BAABKgAFFH8NAAMXAAMIFhAlHQCvAAAXAAMIFhAlHQCvAAAJAAMIKQoFHQCdAAAAAA==.',['狂风']='狂风冷寂:BAABKgAFFH8IAAIBAAUIUgvKDwD6AAABAAUIUgvKDwD6AAAAAA==.狂风天玑:BAAAKgADCgIIAgAAAA==.狂风术神:BAAAKgAFFAMIAwAAAA==.狂风神龍:BAABKgAFFH8KAAINAAQINhJMUgDLAAANAAQINhJMUgDLAAAAAA==.狂风神龙:BAACKgAFFH8IAAMCAAQI3A8RNQC/AAACAAQI3A8RNQC/AAADAAEIzwEJVwAmAAAqAAQKfxcAAwMACAgDEcosAIYBAAMACAiDD8osAIYBAAIABQhjDmWmANkAAAAA.',['狐火']='狐火:BAAAKgAECgYIBgAAAA==.',['猎珑']='猎珑神:BAAAKgADCggICAAAAA==.',['猫熊']='猫熊:BAAAKgAECgYIBwAAAA==.',['猫猫']='猫猫酱:BAAAKgAECgEIAQAAAA==.',['玉凝']='玉凝:BAAAKgADCgQIBAAAAA==.',['玉腿']='玉腿肩上扛:BAABKgAFFH8IAAMVAAQIjBlyEAC1AAAVAAQIoA5yEAC1AAAMAAIItiLsKQBkAAAAAA==.',['王之']='王之喵呜:BAAAKgAFFAIIAgAAAA==.',['王初']='王初初:BAAAKgAECggIEgAAAA==.',['玖哒']='玖哒哒:BAAAKgAECgUIBQAAAA==.',['玛莲']='玛莲妮娅:BAABKgAFFH8GAAINAAYIKQ86LQAyAQANAAYIKQ86LQAyAQAAAA==.',['珀耳']='珀耳塞福涅:BAABKgAFFH8UAAMIAAgIMRt6AQBiAgAIAAgIMRt6AQBiAgAHAAQIgxMiKADCAAAAAA==.',['珂朵']='珂朵莉:BAABKgAFFH8TAAMEAAQIhSAdIwAOAQAEAAQIhSAdIwAOAQAFAAIIIgp/LQBkAAAAAA==.',['瑞贝']='瑞贝卡:BAAAKgAECggICAAAAA==.',['當年']='當年风流倜傥:BAAAKgADCgQIBAAAAA==.',['盲人']='盲人少女丶:BAAAKgAECgMIAwAAAA==.',['直男']='直男都夸我:BAAAKgADCggICQAAAA==.',['盾痴']='盾痴:BAAAKgAECggICQAAAA==.',['真是']='真是小矮子:BAAAKgAECgYIBwAAAA==.真是无语啦:BAAAKgADCgQIBAAAAA==.',['磁力']='磁力棒:BAABKgAFFH8IAAMiAAgI+BPFBQB3AQAiAAUI7xjFBQB3AQANAAMIrAmkdgB8AAAAAA==.',['祝我']='祝我万事如意:BAAAKgADCggICAAAAA==.',['神箭']='神箭丘比特:BAABKgAFFH8GAAIDAAYIyw9aFgAyAQADAAYIyw9aFgAyAQAAAA==.',['神隐']='神隐的八云紫:BAABKgAFFH8GAAIVAAYICx3nAwBPAQAVAAYICx3nAwBPAQAAAA==.',['福星']='福星:BAAAKgADCgEIAQAAAA==.',['秋季']='秋季萧雨:BAAAKgAFFAQIBAAAAA==.',['秋风']='秋风荡漾:BAAAKgAECgIIAgAAAA==.',['空想']='空想魔女:BAABKgAFFH8HAAIdAAcIFxUuCwC4AQAdAAcIFxUuCwC4AQAAAA==.',['簡匰']='簡匰啲萿著:BAACKgAFFH8XAAMgAAgIixjkBAD4AQAgAAgIixjkBAD4AQAiAAgIXBATAwDwAQAqAAQKfxQAAiIACAgQGEoWALwBACIACAgQGEoWALwBAAAA.',['米丨']='米丨小贼:BAABKgAECn8WAAIjAAgIewQhFQCCAAAjAAgIewQhFQCCAAAAAA==.',['米兰']='米兰哥三比零:BAAAKgAECggIDgABKgAFFAIIAwALAAAAAA==.',['粉笔']='粉笔学校才有:BAAAKgAECgcIBgAAAA==.',['精灵']='精灵的德鲁猪:BAABKgAFFH8YAAIEAAQIZhTPMgDMAAAEAAQIZhTPMgDMAAAAAA==.',['糖三']='糖三藏:BAAAKgADCggICAAAAA==.',['紫色']='紫色幽林:BAABKgAECn8ZAAIMAAgIjRoSEwAPAgAMAAgIjRoSEwAPAgAAAA==.',['紫苏']='紫苏青柠:BAAAKgAECggIDAAAAA==.',['紫血']='紫血冰枫:BAACKgAFFH8QAAMJAAMIYiIvDgAeAQAJAAMIYiIvDgAeAQAOAAIIgQkpOQBcAAAqAAQKf04AAwkACAg7JRcDAOoCAAkACAg7JRcDAOoCAA4ABAhxDW93AHkAAAEqAAUUAwgTAAgAYCQA.',['红袖']='红袖添乱:BAABKgAECn8UAAIYAAgIPRUsGADyAQAYAAgIPRUsGADyAQAAAA==.',['纳兹']='纳兹米:BAAAKgADCggICAAAAA==.',['终究']='终究是错付了:BAAAKgAECgIIAgABKgAFFAIIAwALAAAAAA==.',['给桃']='给桃子的信:BAAAKgAECgIIAgAAAA==.',['绿色']='绿色圣骑树:BAAAKgADCggICAAAAA==.',['缘译']='缘译时空:BAAAKgAFFAgIBAAAAA==.',['罔谈']='罔谈彼短:BAABKgAFFH8GAAIEAAYI+RuxEACaAQAEAAYI+RuxEACaAQAAAA==.',['罗祖']='罗祖:BAACKgAFFH8SAAIMAAMIchfZJQDcAAAMAAMIchfZJQDcAAAqAAQKf0QAAgwACAgzHu0NAEECAAwACAgzHu0NAEECAAAA.',['罘象']='罘象:BAAAKgADCgEIAQAAAA==.',['美丽']='美丽加芬:BAABKgAFFH8IAAINAAQI2xOmUgDLAAANAAQI2xOmUgDLAAAAAA==.',['美狄']='美狄亚:BAAAKgAECgMIBAAAAA==.',['聆風']='聆風聽雨:BAAAKgAFFAIIAgAAAA==.',['聪丶']='聪丶:BAABKgAFFH8KAAQVAAYI4BfdAwASAQAVAAQIfBvdAwASAQAMAAUIngnfMQCoAAAWAAEIqRebJwBKAAAAAA==.',['背元']='背元素周期表:BAAAKgAFFAIIBAAAAA==.',['脏牧']='脏牧:BAABKgAFFH8IAAIOAAgI3SEqAQCUAgAOAAgI3SEqAQCUAgAAAA==.',['腿毛']='腿毛飘飘:BAAAKgADCgcIBwAAAA==.',['舔狗']='舔狗阿韩:BAAAKgAECggICgAAAA==.',['艰苦']='艰苦时刻:BAAAKgADCgMIAwAAAA==.',['色眯']='色眯眯的小鱼:BAAAKgAECgYIDgAAAA==.色眯眯的猎手:BAAAKgAECgEIAQAAAA==.色眯眯的魚:BAABKgAECn8WAAMCAAgIRSLxEwCtAgACAAgIRSLxEwCtAgADAAQIiRHskQBWAAAAAA==.色眯眯的鱼:BAACKgAFFH8KAAMVAAYIyRtaAQC7AQAVAAYIyRtaAQC7AQAMAAQIrhxvJwDTAAAqAAQKfz8ABBYACAgXJEUFAIwCABYACAj9IkUFAIwCAAwABQgwG1xGAE8BABUACAiYEm4WACgBAAAA.',['色迷']='色迷迷的鱼:BAACKgAFFH8IAAIKAAgIyA2bBwDPAQAKAAgIyA2bBwDPAQAqAAQKfxwABBMACAiXEH0UAEgBABMABwjFEX0UAEgBAAoABQj8BsqQAIkAABQAAQiBCYogACgAAAAA.',['艾艾']='艾艾:BAABKgAECn85AAMCAAgInxuBLwDtAQACAAgInxuBLwDtAQADAAgIVhSoNACIAQABKgAFFAgICAACABcdAA==.',['艾萨']='艾萨:BAAAKgAECgcIBwAAAA==.',['艾露']='艾露莎:BAAAKgAFFAEIAQAAAA==.',['花开']='花开半夏:BAABKgAECn8XAAICAAgIghfSEwDtAQACAAgIghfSEwDtAQAAAA==.',['花花']='花花仙子:BAAAKgAECgQIBAAAAA==.',['花间']='花间蝶:BAAAKgAECggIAQAAAA==.',['莫全']='莫全都是:BAAAKgAECgcICAAAAA==.',['莲之']='莲之魔:BAAAKgADCggICQAAAA==.',['菊花']='菊花怪七号:BAABKgAECn8hAAIkAAgIxx2pCwBLAgAkAAgIxx2pCwBLAgAAAA==.',['萌萌']='萌萌咚咚:BAAAKgAECgMIBgAAAA==.',['萱萱']='萱萱法思:BAAAKgAECgQIBAAAAA==.',['蒜泥']='蒜泥啵啵浆水:BAACKgAFFH8MAAIRAAIIuR5MIACjAAARAAIIuR5MIACjAAAqAAQKfz4AAxEACAhZIQgQABsCABEACAhZIQgQABsCABAABAj5EsscAK8AAAAA.',['蒜蓉']='蒜蓉甜胚子:BAABKgAECn8eAAIiAAgIzRcGBwDVAQAiAAgIzRcGBwDVAQAAAA==.',['蓝放']='蓝放:BAAAKgAECgYIDAAAAA==.',['藤井']='藤井树:BAACKgAFFH8lAAMDAAYIDCAYDgB7AQADAAUIjSMYDgB7AQACAAYIchSwFABQAQAqAAQKfzMAAgMACAjUJJgIAL0CAAMACAjUJJgIAL0CAAEqAAUUCAghAAYAUhwA.',['蝉灬']='蝉灬唱:BAABKgAECn8YAAIKAAgI5geTYwAVAQAKAAgI5geTYwAVAQAAAA==.',['被圣']='被圣光灌注惹:BAAAKgAECgQIBgAAAA==.',['觅答']='觅答案:BAAAKgAFFAQIAgAAAA==.',['觉醒']='觉醒之后:BAAAKgAECgYIBwAAAA==.',['诅咒']='诅咒丶:BAABKgAFFH8UAAQWAAYI/RyMAABuAQAMAAYInBMEBAB6AQAWAAUIlR2MAABuAQAVAAEIgxcGGQBZAAAAAA==.',['诗歌']='诗歌除外:BAABKgAECn8eAAMaAAgIDgyFQAC8AAAaAAcIqQiFQAC8AAABAAUILg+RmwCYAAABKgAFFAUIIwAcAEsFAA==.',['谢尔']='谢尔盖:BAACKgAFFH8pAAIlAAUIUATrCwCVAAAlAAUIUATrCwCVAAAqAAQKfygAAiUACAg7C7EtABwBACUACAg7C7EtABwBAAAA.',['豊川']='豊川祥子:BAAAKgADCggICAAAAA==.',['赋凌']='赋凌云:BAAAKgAECgUIBQAAAA==.',['赛希']='赛希莉亚:BAAAKgADCgIIAgAAAA==.',['赛德']='赛德尼丶撒旦:BAAAKgADCgMIAwAAAA==.',['赛拉']='赛拉菲娜:BAAAKgADCgQIBAAAAA==.',['赛米']='赛米拉米斯:BAAAKgAECgUICAAAAA==.',['赫卡']='赫卡忒:BAAAKgAECgQIBAAAAA==.',['赫菲']='赫菲斯托斯:BAABKgAFFH8gAAIgAAgIcR85AgBYAgAgAAgIcR85AgBYAgAAAA==.',['趁微']='趁微风不噪:BAAAKgAECgEIAQAAAA==.',['跳蚤']='跳蚤恶魔:BAAAKgAECgMIAwAAAA==.',['踏歌']='踏歌冰雪:BAABKgAFFH8LAAMTAAMItwtXDwCoAAATAAMItwtXDwCoAAAKAAIIBgMBOQAxAAAAAA==.踏歌飞雪:BAACKgAFFH8GAAIQAAMItQ3fFQC5AAAQAAMItQ3fFQC5AAAqAAQKfyYAAxAACAhrEjQnAKgBABAACAhrEjQnAKgBABEABwgvDF9SAPEAAAAA.',['辉煌']='辉煌圣龙:BAAAKgAECgcIBwAAAA==.',['达令']='达令哥:BAAAKgAECgIIAgAAAA==.',['达达']='达达尔:BAAAKgAECgYICwAAAA==.',['迈克']='迈克尔红中:BAAAKgADCgMIAwAAAA==.',['这个']='这个小崽很酷:BAABKgAFFH8FAAIIAAUIaBdTCQAuAQAIAAUIaBdTCQAuAQAAAA==.',['迪亞']='迪亞波罗:BAAAKgAECggICAABKgAFFAgIDAABAPURAA==.',['道临']='道临哥:BAAAKgAECgUIBwAAAA==.',['遗失']='遗失的木棉:BAAAKgADCggICAAAAA==.',['遠方']='遠方的約定:BAACKgAFFH8QAAMYAAUIJxgUBwD3AAAYAAMIUhUUBwD3AAAbAAQIVh1FGQDyAAAqAAQKfxwAAxgACAhtIlILAG0CABgABwgTIVILAG0CABsABQhKI5woAJoBAAAA.',['那要']='那要得嘞:BAAAKgAECgUIBwAAAA==.',['鄙人']='鄙人张牧之:BAAAKgAECgYIBgAAAA==.',['酒笙']='酒笙清栀:BAAAKgAECgMIBAAAAA==.',['酒肆']='酒肆梦桃夭:BAABKgAFFH8GAAIKAAYIQQk/GAAgAQAKAAYIQQk/GAAgAQAAAA==.',['野原']='野原京香:BAAAKgAFFAEIAQAAAA==.野原啫哩:BAAAKgAECgUIBwAAAA==.野原结衣:BAAAKgAECgEIAQAAAA==.',['野良']='野良丨:BAABKgAFFH8GAAIKAAYI+gtrFAA0AQAKAAYI+gtrFAA0AQAAAA==.',['银痕']='银痕羽迹:BAAAKgADCgIIAgAAAA==.',['锤打']='锤打大萌德:BAAAKgADCgcIDwABKgAFFAYIBQARAIIaAA==.',['长征']='长征之旅:BAAAKgADCgcIBwAAAA==.',['闪电']='闪电猫:BAAAKgAECggICQAAAA==.',['阿波']='阿波克烈:BAABKgAFFH8GAAIbAAYI9iAgCgCrAQAbAAYI9iAgCgCrAQAAAA==.',['阿白']='阿白白丶:BAABKgAFFH8hAAMGAAgIUhzqCQDuAQAGAAgIUhzqCQDuAQAlAAMIzgb3GgB7AAAAAA==.',['阿芙']='阿芙洛忒弥:BAABKgAFFH8IAAIGAAgIIhKEBwAeAgAGAAgIIhKEBwAeAgAAAA==.',['陆地']='陆地最强:BAABKgAFFH8GAAIJAAYIexmkCgBVAQAJAAYIexmkCgBVAQAAAA==.',['隔壁']='隔壁丶老钱:BAACKgAFFH8yAAIMAAUI3A1YFADpAAAMAAUI3A1YFADpAAAqAAQKfy4AAgwACAjcF6MlAOUBAAwACAjcF6MlAOUBAAAA.',['隽云']='隽云庭:BAABKgAFFH8GAAINAAYImQxmKABGAQANAAYImQxmKABGAQAAAA==.',['雅儿']='雅儿贝德丶:BAABKgAFFH8IAAIMAAQIHBM5HQAdAQAMAAQIHBM5HQAdAQAAAA==.',['露蓰']='露蓰翽:BAAAKgAFFAEIAQAAAA==.',['霸天']='霸天道翼:BAAAKgAECggICAAAAA==.',['霸宋']='霸宋:BAAAKgAECgYIBgAAAA==.',['霸王']='霸王电影蛋:BAABKgAECn8fAAMWAAgICxeiGwCfAQAWAAcIbRWiGwCfAQAMAAYIaRPeUAAlAQAAAA==.',['霹雳']='霹雳暴龙儿:BAAAKgAFFAEIAQAAAA==.',['青树']='青树湖都:BAACKgAFFH80AAMOAAUIxB++CgAhAQAOAAUIxB++CgAhAQAXAAEIJAcKKABCAAAqAAQKfzsAAg4ACAgRIGMQAE8CAA4ACAgRIGMQAE8CAAAA.',['靓仔']='靓仔:BAAAKgADCggIDQAAAA==.',['靓妹']='靓妹:BAAAKgADCgMIAwAAAA==.',['风中']='风中樱:BAAAKgAECgQIBAAAAA==.',['风滢']='风滢:BAABKgAECn8dAAIOAAgInxMTDwCYAQAOAAgInxMTDwCYAQAAAA==.',['饶孙']='饶孙弟:BAAAKgAFFAQIBAAAAA==.',['香草']='香草可颂:BAAAKgAECggIDAAAAA==.',['驼背']='驼背哥:BAACKgAFFH8LAAIIAAMIFwfSFwB5AAAIAAMIFwfSFwB5AAAqAAQKfxUAAggACAghEFQzAKQBAAgACAghEFQzAKQBAAAA.',['骑马']='骑马与砍杀:BAAAKgAFFAIIAgAAAA==.',['魅影']='魅影:BAAAKgAECgEIAQAAAA==.',['魔丶']='魔丶方:BAABKgAFFH8GAAINAAYIYgfjLwApAQANAAYIYgfjLwApAQAAAA==.',['黄衣']='黄衣的阿肥:BAACKgAFFH8gAAQDAAQIKRluJQDWAAAmAAQI/Q4bAgDcAAADAAQIKRluJQDWAAACAAQIQxLRFwDTAAAqAAQKfxsAAwMACAhyHkghAPYBAAMACAhyHkghAPYBAAIAAQiOCXr/ADoAAAAA.',['黑夜']='黑夜问白天:BAACKgAFFH8TAAIIAAMIYCRzCQAsAQAIAAMIYCRzCQAsAQAqAAQKfz0AAggACAgaJnQCAAEDAAgACAgaJnQCAAEDAAAA.',['黑帝']='黑帝斯:BAAAKgAFFAgIBAAAAA==.',['黑瞳']='黑瞳浩軒:BAABKgAFFH8GAAIKAAMIMhokJwDaAAAKAAMIMhokJwDaAAABKgAFFAgIbQAbAFEiAA==.',['黑色']='黑色柳丁:BAABKgAECn8gAAMBAAgIaRoyOADQAQABAAgIkRgyOADQAQAaAAgI7RIQJABqAQABKgAFFAgIBgABAB0dAA==.',['黑骑']='黑骑士的挽歌:BAAAKgADCggICQAAAA==.',['龙人']='龙人之祖:BAAAKgAECgUICAAAAA==.',['龙啸']='龙啸八极:BAAAKgAECgcIEQAAAA==.',['龙妈']='龙妈:BAAAKgAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end