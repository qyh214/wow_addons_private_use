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
 local lookup = {'DemonHunter-Havoc','Mage-Frost','Paladin-Retribution','Unknown-Unknown','Shaman-Restoration','Shaman-Elemental','Warlock-Destruction','DeathKnight-Unholy','DeathKnight-Blood','Priest-Shadow','Priest-Holy','Mage-Arcane','Warrior-Arms','Shaman-Enhancement','Monk-Windwalker','Mage-Fire','Hunter-Marksmanship','Hunter-BeastMastery','Rogue-Subtlety','Warrior-Fury','Druid-Balance','Druid-Guardian','Evoker-Devastation','Evoker-Preservation','Monk-Mistweaver','Monk-Brewmaster','Druid-Restoration','Paladin-Protection','Warlock-Demonology','Warlock-Affliction','Priest-Discipline','DemonHunter-Vengeance','Hunter-Survival','DeathKnight-Frost','Paladin-Holy',}; local provider = {region='CN',realm='地狱咆哮',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ar='Arashiwarp:BAABKgAECn8aAAIBAAcInws6KQABAQABAAcInws6KQABAQAAAA==.',At='Athenia:BAABKgAECn8aAAICAAgIaQodGAAJAQACAAgIaQodGAAJAQAAAA==.',Az='Azureocean:BAAAKgADCggICAAAAA==.Azurerain:BAAAKgAECgEIAQAAAA==.',Ba='Banananana:BAABKgAFFH8MAAIDAAQI7CCAFwD9AAADAAQI7CCAFwD9AAABKgAFFAgIAgAEAAAAAA==.',Be='Beastmaster:BAAAKgAFFAQIBAAAAA==.',Ch='Charli:BAAAKgAFFAIIAgAAAA==.',Cr='Cruelsummer:BAAAKgAECgUICAAAAA==.',De='Deadlytotem:BAABKgAFFH8IAAMFAAgIsA5vDAAzAQAFAAYI3QtvDAAzAQAGAAII1hlSEQCSAAAAAA==.',Ds='Dseperate:BAAAKgADCgIIAgAAAA==.',Ev='Evagelion:BAABKgAECn8VAAIHAAcINwx7IQDyAAAHAAcINwx7IQDyAAAAAA==.',Fu='Funnymudpee:BAABKgAFFH8GAAMIAAQIjCPSCAAjAQAIAAQIjCPSCAAjAQAJAAII7hXCGgCAAAAAAA==.',Gu='Guduowo:BAAAKgAECgMIAwAAAA==.',He='Helltyrant:BAAAKgAFFAQIBAAAAA==.',Ko='Kookazuma:BAACKgAFFH8HAAMKAAcIsQ7WEwDGAAAKAAUIYAzWEwDGAAALAAIIcg5cMQCAAAAqAAQKfywAAgsACAhrGpIaAOwBAAsACAhrGpIaAOwBAAAA.',Lo='Lovelt:BAAAKgADCgUIBQAAAA==.',Lu='Luminous:BAABKgAECn8WAAIHAAgIHSRsCQChAgAHAAgIHSRsCQChAgAAAA==.',Ma='Maiq:BAAAKgADCgIIAgAAAA==.',Me='Meltryllis:BAAAKgAFFAQIBAABKgAFFAgIDQADAOEYAA==.',Mi='Miyanoakemi:BAABKgAFFH8IAAMCAAgIjQi8BwBHAQACAAcIvAm8BwBHAQAMAAEIcQGQSQApAAAAAA==.',Mu='Murata:BAABKgAECn8XAAINAAcIWAiYFgDVAAANAAcIWAiYFgDVAAAAAA==.',No='Noordwolf:BAAAKgAECgYIBgAAAA==.Norimessiah:BAAAKgADCggIDAAAAA==.',Or='Orion:BAACKgAFFH8LAAIOAAMIWA56EwC7AAAOAAMIWA56EwC7AAAqAAQKfxUAAg4ACAh1GM0VALEBAA4ACAh1GM0VALEBAAAA.',Ov='Ovoo:BAAAKgAFFAQIBAAAAA==.',Pe='Penis:BAAAKgAECgIIAgAAAA==.',Pi='Piga:BAAAKgADCggICAAAAA==.',Qq='Qqy:BAABKgAFFH8FAAIPAAUILg3iAwBMAQAPAAUILg3iAwBMAQAAAA==.',Re='Resdayn:BAABKgAECn8UAAMQAAgIgSVAFgBvAgAQAAgIgSVAFgBvAgAMAAQICR2VVwDiAAAAAA==.',Ro='Rolandy:BAABKgAFFH8bAAMRAAgIWhyDAADjAQARAAgI8RuDAADjAQASAAYIjhX7EwBVAQAAAA==.',Su='Subject:BAAAKgAECgUIBQAAAA==.Sunrise:BAAAKgAECggICAAAAA==.',Th='Thesan:BAABKgAECn8XAAITAAgINRV0BQCpAQATAAgINRV0BQCpAQAAAA==.',Ti='Tinda:BAAAKgAFFAQIBAAAAA==.',Tm='Tmc:BAAAKgAECgMIAwAAAA==.',Xu='Xun:BAAAKgAFFAMIAwAAAA==.',['一发']='一发入魂:BAAAKgADCgcIBwAAAA==.',['一叶']='一叶:BAAAKgAECgUIBQAAAA==.',['一血']='一血色浪漫一:BAAAKgADCggICAAAAA==.',['一锤']='一锤敲死:BAABKgAFFH8GAAIDAAYI1RBbIwBeAQADAAYI1RBbIwBeAQAAAA==.',['万宝']='万宝宝:BAAAKgAFFAIIAgAAAA==.',['不能']='不能拳脚相向:BAABKgAFFH8GAAIPAAYI3ggbCAA8AQAPAAYI3ggbCAA8AQAAAA==.不能瞄准:BAAAKgAFFAQIBAAAAA==.',['临门']='临门一脚:BAAAKgADCgYIBgAAAA==.',['丶三']='丶三鹿奶粉:BAAAKgAECgEIAQAAAA==.',['丿灬']='丿灬祈福:BAAAKgAFFAQIBAAAAA==.',['义海']='义海豪情:BAAAKgADCggICAAAAA==.',['乘风']='乘风破浪:BAAAKgADCggICQAAAA==.',['二一']='二一添作五:BAAAKgADCggICAAAAA==.',['二向']='二向箔:BAAAKgAFFAQIBAAAAA==.',['云丶']='云丶飘飘:BAAAKgAECgIIAwAAAA==.',['云霆']='云霆:BAAAKgAECgcIBwAAAA==.',['亡魂']='亡魂密使:BAAAKgAFFAEIAQAAAA==.',['人如']='人如其名:BAAAKgAFFAEIAQAAAA==.',['仨都']='仨都不用:BAAAKgADCgMIAwAAAA==.',['伊谢']='伊谢尔伦的枫:BAABKgAFFH8IAAMNAAYIDBXhCAB8AQANAAYIDBXhCAB8AQAUAAII2gbDLACOAAAAAA==.',['伪装']='伪装单纯:BAAAKgAFFAYIBAAAAA==.',['似水']='似水逗逗:BAAAKgAECgYIBwAAAA==.',['你快']='你快悄你丶:BAAAKgAECgIIAgAAAA==.',['你想']='你想不到吧:BAABKgAECn8gAAMVAAgI4haDQAC0AQAVAAcIpRiDQAC0AQAWAAYINwzfHAC2AAAAAA==.',['修修']='修修:BAACKgAFFH8LAAMXAAMIhRppHQDTAAAXAAMIhRppHQDTAAAYAAIIPRRlCAB1AAAqAAQKfyEAAxcACAinHzEQAEsCABcACAinHzEQAEsCABgABgjvIO0JANkBAAAA.',['倾城']='倾城壹笑:BAAAKgAFFAEIAQAAAA==.',['做贼']='做贼心不虚:BAAAKgADCgMIAwAAAA==.',['偷吻']='偷吻你的绣发:BAAAKgAFFAMIBAAAAA==.',['傲之']='傲之囚牛:BAAAKgAECgYIBgAAAA==.',['光膀']='光膀子耍大斧:BAAAKgAECggICAAAAA==.',['八重']='八重桜:BAAAKgADCgEIAgAAAA==.',['冰封']='冰封的仆从:BAAAKgAECgQIBAAAAA==.',['冰汽']='冰汽水:BAABKgAFFH8WAAMLAAMISR3pGwDeAAALAAMISR3pGwDeAAAKAAMItRBiGQCyAAAAAA==.',['冰花']='冰花之狱丶:BAAAKgAECgEIAQAAAA==.',['冰铃']='冰铃丶:BAABKgAFFH8GAAIDAAYIBQugFQBEAQADAAYIBQugFQBEAQAAAA==.',['凋零']='凋零之翼:BAABKgAFFH8QAAIIAAgINAnEBwDMAQAIAAgINAnEBwDMAQAAAA==.',['凯尔']='凯尔斯塔里安:BAAAKgAECgEIAQAAAA==.',['凯莎']='凯莎:BAAAKgADCgMIAwAAAA==.',['凯蒂']='凯蒂:BAAAKgADCgEIAQAAAA==.',['凶珍']='凶珍大:BAAAKgAECgYIBgAAAA==.',['凹凸']='凹凸曼的牧:BAABKgAFFH8GAAILAAYI6wvWEQAjAQALAAYI6wvWEQAjAQAAAA==.',['刘十']='刘十二:BAAAKgAECgcIBwAAAA==.',['创世']='创世者:BAAAKgADCgEIAQAAAA==.',['别灬']='别灬奶:BAACKgAFFH8IAAMZAAII7xodGgCsAAAZAAII7xodGgCsAAAaAAEIxhD2CQA3AAAqAAQKfy0ABBkACAhOIAITAFACABkACAhOIAITAFACAA8AAwgQE7VZAJUAABoAAwiqDbwaAIgAAAAA.',['前门']='前门八条:BAABKgAFFH8GAAIMAAYI0RWADgB/AQAMAAYI0RWADgB/AQABKgAFFAgIDgACAPwaAA==.',['前面']='前面西西猛转:BAAAKgAECggICAAAAA==.',['加尓']='加尓鲁什丶:BAAAKgADCgEIAQAAAA==.',['勇地']='勇地飞侠:BAAAKgAECgUIBQAAAA==.',['北京']='北京新兴医院:BAAAKgAECgUIBQAAAA==.',['千乐']='千乐:BAAAKgAECgMIBQAAAA==.',['千水']='千水冰凝:BAAAKgADCggICAAAAA==.',['半岛']='半岛:BAAAKgADCgYIBgAAAA==.',['半弥']='半弥残沙丶:BAAAKgAFFAYIAgAAAA==.',['半疯']='半疯半癫:BAABKgAFFH8KAAIIAAgIgx6lAgCoAgAIAAgIgx6lAgCoAgAAAA==.',['半神']='半神的低语:BAAAKgADCgUIBQAAAA==.',['南丁']='南丁格尔:BAABKgAFFH8GAAILAAQIOxThKwCUAAALAAQIOxThKwCUAAAAAA==.',['南国']='南国先生:BAAAKgAFFAIIAgAAAA==.',['卡皮']='卡皮吧啦:BAAAKgADCgUIBQAAAA==.',['厕之']='厕之三父:BAAAKgAECggICQAAAA==.',['叔叔']='叔叔依然飘逸:BAAAKgADCgEIAQAAAA==.',['受祝']='受祝女士:BAAAKgADCgQIBAAAAA==.',['叫我']='叫我老辰就好:BAAAKgAECgEIAQAAAA==.',['吃根']='吃根冰棒吧:BAAAKgAECgYIDAAAAA==.',['吾辈']='吾辈楷模:BAABKgAECn8YAAIGAAgIwR4LDwB2AgAGAAgIwR4LDwB2AgAAAA==.',['咖啡']='咖啡咖喱:BAAAKgAECggICAAAAA==.咖啡奶香:BAAAKgAECggICAAAAA==.咖啡色的喵:BAABKgAFFH8IAAIZAAMIOA5gIgCZAAAZAAMIOA5gIgCZAAAAAA==.',['哇噻']='哇噻的小红河:BAAAKgAECggIDAAAAA==.',['哈士']='哈士骑着摩的:BAAAKgADCgEIAQAAAA==.',['哈尼']='哈尼小宝:BAAAKgAFFAgIBAAAAA==.',['哔卟']='哔卟哩哄丶:BAAAKgADCgEIAQAAAA==.',['唐吉']='唐吉訶德:BAAAKgADCggICAAAAA==.',['啪啪']='啪啪你少年:BAAAKgAECgUIBQAAAA==.',['善射']='善射养由基:BAAAKgAECggICAAAAA==.',['喵滴']='喵滴牛:BAABKgAFFH8OAAINAAgISxHwAwARAgANAAgISxHwAwARAgAAAA==.',['喷奶']='喷奶龙:BAACKgAFFH9EAAMYAAgIexqCAAB3AQAYAAcIdx6CAAB3AQAXAAcIHhP0DgBxAQAqAAQKf3AAAxgACAh4Jl4AAAMDABgACAh4Jl4AAAMDABcACAjDJTUCAPkCAAAA.',['嗨呆']='嗨呆呆:BAAAKgAFFAEIAQAAAA==.',['嘎哈']='嘎哈呢你:BAABKgAFFH8GAAIQAAYIeQ6/BwCIAQAQAAYIeQ6/BwCIAQAAAA==.',['因颜']='因颜:BAAAKgADCgEIAQAAAA==.',['土狗']='土狗蛋子:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光二零二四:BAAAKgADCgIIAgAAAA==.圣光外卖员:BAAAKgAECgIIAgAAAA==.圣光小牦牛:BAABKgAFFH8GAAIDAAYI+xk2EACdAQADAAYI+xk2EACdAQAAAA==.圣光护佑董晓:BAAAKgADCggICAAAAA==.',['地狱']='地狱火咔:BAAAKgAFFAIIAgAAAA==.',['垂死']='垂死梦境:BAAAKgAECgYIBgAAAA==.',['埃克']='埃克莱尔法隆:BAAAKgADCggICAAAAA==.',['塞伯']='塞伯坦之怒:BAAAKgAECgEIAQAAAA==.',['墨墨']='墨墨哒:BAACKgAFFH8JAAMGAAQIUR8oBQAOAQAGAAQIUR8oBQAOAQAFAAMI0BJhMQC0AAAqAAQKfx0AAgUACAjyHPIcABoCAAUACAjyHPIcABoCAAEqAAUUCAgCAAQAAAAA.',['壹嚸']='壹嚸:BAAAKgADCggICAAAAA==.',['夜了']='夜了又破晓:BAABKgAFFH8GAAIDAAYIuiHBEQDPAQADAAYIuiHBEQDPAQAAAA==.',['大橘']='大橘为重:BAAAKgAECgcIDwAAAA==.',['大狗']='大狗警长:BAAAKgAECgIIAgAAAA==.',['大秦']='大秦:BAAAKgAECgQIBAAAAA==.',['大笨']='大笨牛啊:BAAAKgAECgQIBAAAAA==.',['大肉']='大肉妞儿:BAABKgAFFH8HAAMSAAUIKBSWKwCjAAASAAIIlxeWKwCjAAARAAUIwA0BPACIAAAAAA==.',['大脸']='大脸猫:BAAAKgAECgQIBAAAAA==.',['大腿']='大腿乱蹬儿:BAAAKgADCgcIBwAAAA==.',['大鼻']='大鼻涕火牛:BAAAKgAECgQIBAAAAA==.',['头上']='头上有支角:BAAAKgADCggICAAAAA==.',['奶嘴']='奶嘴与嘟嘟:BAAAKgAECggIDwAAAA==.',['奶油']='奶油筱曦:BAAAKgADCgUIBQAAAA==.',['宇智']='宇智波老鬼:BAABKgAFFH8IAAILAAgIyRS0BAD3AQALAAgIyRS0BAD3AQAAAA==.',['守护']='守护荣耀之战:BAAAKgAECggIDwAAAA==.',['完美']='完美演绎:BAAAKgAECggIDwAAAA==.完美骷髅:BAABKgAECn8WAAIbAAgIJxJLKwB9AQAbAAgIJxJLKwB9AQAAAA==.',['定格']='定格那帧:BAABKgAECn8YAAIDAAgIPSEuHQCOAgADAAgIPSEuHQCOAgAAAA==.',['寂寞']='寂寞的羊羔:BAABKgAECn8UAAMcAAgI5gdRMwDIAAAcAAgIpgZRMwDIAAADAAIIJgtdWAFSAAAAAA==.',['寒丶']='寒丶芒:BAABKgAFFH8IAAIDAAgIgBSuHwDqAAADAAgIgBSuHwDqAAAAAA==.',['寰寰']='寰寰相扣:BAAAKgAECgEIAQAAAA==.',['寶唄']='寶唄格格:BAAAKgAECgUICwAAAA==.',['寿喜']='寿喜:BAABKgAFFH8GAAIDAAQINAv4NAAWAQADAAQINAv4NAAWAQAAAA==.',['小咕']='小咕噜:BAABKgAFFH8TAAMHAAYI+Rr8AQDIAQAHAAYI+Rr8AQDIAQAdAAUItA+OBQDdAAAAAA==.',['小垫']='小垫子:BAABKgAFFH8GAAIIAAYI1BWmFgBoAQAIAAYI1BWmFgBoAQAAAA==.',['小楼']='小楼:BAAAKgADCgMIAwAAAA==.',['小毯']='小毯子:BAAAKgAFFAYIBAAAAA==.',['小煎']='小煎饼:BAABKgAFFH8MAAMbAAYIrB3PBgCnAQAbAAYIrB3PBgCnAQAVAAYIDRl4FwBdAQABKgAFFAgIBAAEAAAAAA==.',['小皮']='小皮球:BAAAKgAFFAYIBAAAAA==.',['小紫']='小紫裤衩儿:BAABKgAFFH8MAAQdAAYIdxGQDwC+AAAHAAQIcQ1hJADmAAAdAAQIsgyQDwC+AAAeAAEIggU8IgBEAAAAAA==.',['小胖']='小胖几:BAAAKgAECgEIAQAAAA==.',['小艾']='小艾泉水叮咚:BAAAKgAECgYIBgAAAA==.小艾爱天空:BAABKgAECn8aAAIfAAgI5xcqIQDAAQAfAAgI5xcqIQDAAQAAAA==.',['小褥']='小褥子:BAAAKgAFFAIIAgAAAA==.',['小酒']='小酒窝子:BAAAKgADCggICAAAAA==.',['就我']='就我快乐:BAACKgAFFH8fAAISAAQIXCAbIQAHAQASAAQIXCAbIQAHAQAqAAQKfzEAAxIACAgTJPs2ABkCABIABwiRJPs2ABkCABEABAjmGElbALIAAAAA.',['就是']='就是德呀:BAABKgAECn8YAAIVAAcIAQ4magAcAQAVAAcIAQ4magAcAQAAAA==.',['尼禄']='尼禄丶呆毛:BAAAKgAECggICAAAAA==.',['尾巴']='尾巴藏不住:BAAAKgAECgUIBQAAAA==.',['巨阳']='巨阳小顽童:BAACKgAFFH8oAAINAAYIXiDcBQDFAQANAAYIXiDcBQDFAQAqAAQKfzUAAg0ACAgFJgMCAPcCAA0ACAgFJgMCAPcCAAEqAAUUCAgsABAAQxwA.',['布莱']='布莱克刘能:BAABKgAECn8XAAMUAAcIZRRNOwCLAQAUAAcINxNNOwCLAQANAAMIXAybRACbAAAAAA==.',['帅的']='帅的被人砍:BAAAKgAECggICgAAAA==.',['希瓦']='希瓦丶呆毛:BAAAKgAECgQIBAAAAA==.希瓦风行者:BAAAKgADCgQIBAAAAA==.',['平静']='平静思绪:BAABKgAFFH8QAAIHAAgIRBcpBABGAgAHAAgIRBcpBABGAgAAAA==.',['幽然']='幽然若梦:BAAAKgAECgEIAQAAAA==.',['开水']='开水白菜:BAAAKgAFFAEIAQAAAA==.',['弹你']='弹你脑瓜崩:BAAAKgAECgIIAgAAAA==.',['归尘']='归尘:BAAAKgAECggIEAAAAA==.',['影丶']='影丶坦:BAAAKgAFFAYIAgAAAA==.',['德玛']='德玛西亚赵四:BAAAKgAECgQIBAAAAA==.',['心无']='心无旁骛丶:BAAAKgAFFAQIBAAAAA==.',['忐忑']='忐忑忐忑:BAAAKgADCggICAABKgAFFAgIEgAHAAgSAA==.',['快乐']='快乐的骑士:BAAAKgAFFAIIAwAAAA==.',['忽悠']='忽悠你的圣光:BAAAKgAECgEIAQAAAA==.',['怀庆']='怀庆长公主:BAAAKgAFFAgIBAAAAA==.',['怒冲']='怒冲凌霄:BAAAKgAECgYIBgAAAA==.',['悠带']='悠带刀:BAABKgAECn8xAAIdAAgIiiSlAQDvAgAdAAgIiiSlAQDvAgAAAA==.',['慑天']='慑天:BAAAKgAFFAIIBAAAAA==.',['慕尘']='慕尘:BAAAKgAFFAMIAwAAAA==.',['戈尔']='戈尔洛什:BAAAKgAECgUIBQAAAA==.',['我也']='我也顶不住了:BAAAKgAECggICAAAAA==.',['我叫']='我叫小妹:BAABKgAFFH8IAAIFAAgIABaUAwA2AgAFAAgIABaUAwA2AgAAAA==.',['我好']='我好像站着:BAAAKgAECgIIAgAAAA==.',['我就']='我就是光与刀:BAAAKgADCgEIAQAAAA==.',['我有']='我有大弟弟:BAAAKgADCgQIBAAAAA==.',['战神']='战神:BAAAKgADCgUIBQAAAA==.',['托比']='托比吊:BAAAKgAFFAIIAgAAAA==.',['扯通']='扯通的线裤:BAAAKgAFFAYIBAAAAA==.',['拉粑']='拉粑粑小魔仙:BAAAKgAFFAIIAgAAAA==.',['提刀']='提刀就是干:BAAAKgAECggICgAAAA==.',['提弓']='提弓就是射:BAAAKgAECggIEgAAAA==.',['敬蚩']='敬蚩尤一杯酒:BAABKgAECn8YAAIaAAgIShEiDgBiAQAaAAgIShEiDgBiAQABKgAECggIGwAgADAYAA==.',['数湿']='数湿:BAAAKgADCgIIAgAAAA==.',['斯提']='斯提亚拉:BAAAKgAECgcIBwAAAA==.',['旋一']='旋一个:BAAAKgAECgcICAAAAA==.',['无双']='无双赵子龙:BAAAKgAECgcIDQAAAA==.',['无视']='无视痛苦:BAABKgAECn8aAAISAAgIxR5jPgD+AQASAAgIxR5jPgD+AQAAAA==.',['昊添']='昊添土豆:BAAAKgADCgEIAQAAAA==.',['易俗']='易俗河摸摸唱:BAAAKgADCgQIBAAAAA==.',['星魂']='星魂:BAAAKgADCgIIAgAAAA==.',['晨雾']='晨雾绿:BAACKgAFFH8tAAMUAAgIYSONAQDPAgAUAAgIYSONAQDPAgANAAEI/iKaFgBaAAAqAAQKfzoAAxQACAiyJngCAAMDABQACAiyJngCAAMDAA0AAgjMEs9RAIQAAAAA.',['暗夜']='暗夜火球:BAABKgAECn8gAAICAAgIDh2jJwDfAQACAAgIDh2jJwDfAQAAAA==.',['暗影']='暗影灵柩:BAABKgAFFH8KAAIHAAgILRmhCAAEAgAHAAgILRmhCAAEAgAAAA==.',['暗矛']='暗矛族长:BAAAKgAECgYIDAAAAA==.',['暴雨']='暴雨:BAAAKgAECgQIBAAAAA==.暴雨来了:BAABKgAFFH8LAAIFAAQIyxwoEgDpAAAFAAQIyxwoEgDpAAAAAA==.',['曲度']='曲度紫鸢:BAABKgAFFH8GAAIIAAYIBx9eAQDmAQAIAAYIBx9eAQDmAQAAAA==.',['最后']='最后一夜:BAABKgAFFH8HAAMbAAQIegptJgCMAAAbAAMIegptJgCMAAAVAAIIMQK9YwAsAAABKgAFFAgILgAcAD8LAA==.',['杨多']='杨多多:BAABKgAECn8YAAILAAUIMB0iRwAcAQALAAUIMB0iRwAcAQAAAA==.',['柄机']='柄机:BAAAKgAECgMIAwAAAA==.',['柱子']='柱子:BAAAKgAECgUICAAAAA==.',['桃失']='桃失:BAAAKgAECgQIBAABKgAECggIGwAgADAYAA==.',['桐镜']='桐镜:BAABKgAECn8bAAMgAAgIMBiCFQDoAQAgAAgIMBiCFQDoAQABAAQIlQqqgQC5AAAAAA==.',['梦中']='梦中的露露:BAABKgAFFH8GAAMLAAYIChdFBAAhAQALAAQIth1FBAAhAQAKAAII3Ax0GACfAAAAAA==.',['極其']='極其簡單的:BAABKgAFFH8KAAMCAAYIVBlNBACXAQACAAYIVBlNBACXAQAQAAIIwwwAAAAAAAAAAA==.',['正义']='正义之光:BAAAKgADCggICAAAAA==.',['正派']='正派牛牛:BAAAKgADCggICAAAAA==.',['正统']='正统大酋长:BAABKgAFFH8GAAINAAYI3BRXBQCdAQANAAYI3BRXBQCdAQAAAA==.正统部落萨满:BAAAKgAECgUIBQAAAA==.',['步川']='步川地窟:BAACKgAFFH8RAAMRAAMIZxd/LAC5AAARAAMIkBN/LAC5AAASAAMIMRQZLQCgAAAqAAQKf0oABBIACAjtIxUNANECABIACAjtIxUNANECABEACAhbHy8UAFcCACEAAwjGDMgYAG0AAAAA.',['歪比']='歪比歪比歪:BAAAKgAECgEIAQAAAA==.',['死星']='死星在闪耀:BAAAKgAFFAYIAwAAAA==.',['残冬']='残冬未尽:BAAAKgAECggICAAAAA==.',['残枫']='残枫秋落:BAAAKgAFFAMIAwAAAA==.',['比卡']='比卡比卡啾:BAABKgAFFH8GAAIFAAYIOhNbDgBqAQAFAAYIOhNbDgBqAQAAAA==.',['比由']='比由比由:BAABKgAFFH8OAAMCAAgI/QjdAwCxAQACAAgIdQjdAwCxAQAMAAYIHArODwAwAQAAAA==.',['水蓝']='水蓝蓝:BAAAKgAECgcICwAAAA==.',['水麟']='水麟二代目:BAAAKgADCgYIBgAAAA==.',['沐浴']='沐浴春风:BAABKgAECn8vAAQfAAgIxiEBFAAlAgAfAAgIxiEBFAAlAgAKAAgI2BY/FgDgAQALAAYIGxXiQAA2AQAAAA==.',['没门']='没门无糖:BAABKgAFFH8KAAMHAAYIIiNOCwDYAQAHAAYIIiNOCwDYAQAdAAQIpBGYDwC+AAAAAA==.',['沫茉']='沫茉:BAAAKgAFFAQIBAABKgAFFAgIBAAEAAAAAA==.',['洃羽']='洃羽傀儡:BAAAKgAECgMIAwAAAA==.',['海绵']='海绵派大星彡:BAAAKgAECgYIBgAAAA==.',['涅丶']='涅丶磐:BAAAKgAFFAQIBAAAAA==.',['渣男']='渣男渣到死:BAAAKgAECggICAAAAA==.',['湘潭']='湘潭县摸摸唱:BAAAKgADCggICAAAAA==.',['漩涡']='漩涡大雄:BAAAKgAECggIDgAAAA==.',['火柴']='火柴:BAACKgAFFH8mAAIIAAQIVhy/JAAAAQAIAAQIVhy/JAAAAQAqAAQKfxwAAggACAhxHtkVAF0CAAgACAhxHtkVAF0CAAAA.',['火照']='火照黑云:BAAAKgAFFAQIBAAAAA==.',['火鼹']='火鼹鼠:BAABKgAFFH8GAAIIAAYIYBYkEQCSAQAIAAYIYBYkEQCSAQAAAA==.',['灬拓']='灬拓风灬:BAAAKgAECgYIBgAAAA==.',['灬邪']='灬邪惡丨蔓延:BAABKgAFFH8aAAIIAAMI5gISHgBnAAAIAAMI5gISHgBnAAAAAA==.',['灰流']='灰流丽丶:BAAAKgAECggICAAAAA==.',['炼狱']='炼狱神魔:BAABKgAFFH8FAAIiAAMIzwU5DQCVAAAiAAMIzwU5DQCVAAAAAA==.',['烈烈']='烈烈大熊:BAAAKgAECgQIBAAAAA==.',['烟灰']='烟灰伍虒:BAABKgAECn8YAAIKAAgIXB2JDQBNAgAKAAgIXB2JDQBNAgAAAA==.',['热血']='热血大虎逼:BAABKgAFFH8GAAIVAAYIAA+UGQBMAQAVAAYIAA+UGQBMAQAAAA==.',['焚屿']='焚屿:BAABKgAFFH8GAAINAAYIHhjFBgCsAQANAAYIHhjFBgCsAQAAAA==.',['焦圈']='焦圈兒:BAAAKgAECggICAAAAA==.',['焱婆']='焱婆娑:BAAAKgADCgEIAQAAAA==.',['熊嘟']='熊嘟嘟大魔王:BAAAKgAECggICAAAAA==.',['熊猫']='熊猫两千:BAABKgAFFH8QAAIFAAUIhxlCDgBsAQAFAAUIhxlCDgBsAQAAAA==.',['爱喝']='爱喝桂馥兰香:BAAAKgAFFAQIBAAAAA==.',['爱我']='爱我永远:BAAAKgADCgIIAgAAAA==.',['牛奶']='牛奶特仑苏:BAAAKgADCggICAAAAA==.',['狼之']='狼之笑:BAACKgAFFH8KAAMFAAMIXBIxEwDXAAAFAAMIXBIxEwDXAAAGAAEI8QYKHQA7AAAqAAQKfxsAAwUACAhgE9w3AKcBAAUACAhgE9w3AKcBAAYACAjeDuIyAHUBAAAA.',['猪猪']='猪猪牛牛:BAAAKgADCgMIAwAAAA==.',['猫猫']='猫猫小天使:BAABKgAFFH8cAAMdAAgIQxpyAgBnAQAHAAcIgQ/kDAC9AQAdAAUI8x5yAgBnAQAAAA==.',['猫眯']='猫眯喵喵:BAAAKgADCggIDgAAAA==.',['王局']='王局说的是:BAABKgAFFH8MAAIDAAQI8RcBSADeAAADAAQI8RcBSADeAAAAAA==.',['玛德']='玛德:BAAAKgAECgQIBAAAAA==.',['玩个']='玩个鸟:BAAAKgADCgEIAQAAAA==.',['玩原']='玩原神玩的:BAAAKgAECggIDAAAAA==.',['用力']='用力过猛:BAAAKgAECgcICAAAAA==.',['疯狂']='疯狂天涯舞:BAAAKgAECggIDAAAAA==.',['百年']='百年孤独:BAAAKgADCgMIAwAAAA==.',['盗梦']='盗梦倥姐:BAABKgAECn8VAAIZAAgILxmGEwD4AQAZAAgILxmGEwD4AQAAAA==.',['相不']='相不相信光:BAAAKgAECgMIAwAAAA==.',['盾击']='盾击炖鸡盾击:BAAAKgADCggICAAAAA==.',['看晚']='看晚星多明亮:BAABKgAFFH8GAAIVAAYIdBH3GwA6AQAVAAYIdBH3GwA6AQAAAA==.',['看谁']='看谁都打冷颤:BAAAKgADCgIIAgAAAA==.',['睡着']='睡着的小鱼:BAAAKgADCggIDAAAAA==.',['砍不']='砍不动:BAAAKgADCgEIAQAAAA==.',['破晓']='破晓:BAABKgAFFH8GAAIQAAYIGRYbDQBmAQAQAAYIGRYbDQBmAQAAAA==.',['硝子']='硝子之花:BAAAKgAECgEIAQAAAA==.',['碎了']='碎了的阳光:BAABKgAFFH8OAAMFAAgIFQ8aCgClAQAFAAcIExAaCgClAQAGAAEImgqyJgBDAAAAAA==.',['神一']='神一样小豪总:BAAAKgAFFAQIAgABKgAFFAgIRwAQADUlAA==.',['神罚']='神罚:BAAAKgADCgYIBgAAAA==.神罚之刃:BAAAKgAFFAIIAgAAAA==.',['禁书']='禁书:BAABKgAFFH8dAAIDAAgIKyMEBgBrAgADAAgIKyMEBgBrAgAAAA==.',['福柯']='福柯:BAAAKgADCggICAAAAA==.',['科赛']='科赛拉:BAAAKgAECgQIBAAAAA==.',['空悟']='空悟圣大天齐:BAAAKgAECgIIAgAAAA==.',['站吊']='站吊:BAAAKgAECgUIBwAAAA==.',['竹子']='竹子青:BAABKgAFFH8FAAMZAAQI/gooLABnAAAZAAMIjwsoLABnAAAPAAIIkwdNGQBjAAAAAA==.',['第七']='第七夜:BAAAKgAECgYIBgAAAA==.第七夜丶听雪:BAAAKgAECggIBQAAAA==.',['筱牙']='筱牙:BAAAKgAFFAQIBAAAAA==.',['箭客']='箭客阿良:BAAAKgAECggICAAAAA==.',['紫清']='紫清:BAAAKgAECggIDgABKgAFFAgIRAAYAHsaAA==.',['紫青']='紫青:BAAAKgAECggICAABKgAFFAgIRAAYAHsaAA==.',['紫鵺']='紫鵺:BAABKgAFFH8IAAIDAAgINhH2CwAKAgADAAgINhH2CwAKAgAAAA==.',['红尘']='红尘丶二两:BAAAKgADCgYIBgAAAA==.',['红河']='红河老大爷:BAABKgAECn8XAAMRAAgIMh43FgBHAgARAAgIMh43FgBHAgASAAIIjg+i3QBzAAAAAA==.',['纯白']='纯白皮卡丘:BAAAKgAECgcIBwAAAA==.',['绿影']='绿影拂泽:BAAAKgADCggIHAAAAA==.',['绿皮']='绿皮侠:BAAAKgADCgYIBgAAAA==.',['罗丝']='罗丝萝瑞安:BAAAKgAECgQIBAAAAA==.',['罪恶']='罪恶的兔子:BAAAKgADCggIFgAAAA==.',['翳小']='翳小云:BAAAKgAECgQIBAAAAA==.',['老尔']='老尔丹:BAAAKgAECgEIAQAAAA==.',['胡桃']='胡桃桃:BAAAKgAECgYIBwAAAA==.',['能扛']='能扛能打:BAAAKgAFFAgIBAAAAA==.',['能摇']='能摇人儿:BAAAKgADCgMIAwAAAA==.',['膛线']='膛线:BAAAKgAFFAIIAgAAAA==.',['臭妮']='臭妮:BAAAKgADCggICAAAAA==.',['舞阳']='舞阳天凤:BAAAKgAECgMIAwAAAA==.',['艾瑞']='艾瑞恩:BAABKgAFFH8PAAIDAAYIjSHFFQCtAQADAAYIjSHFFQCtAQAAAA==.',['英雄']='英雄玛卡多:BAACKgAFFH8PAAIFAAMI9iJuGwARAQAFAAMI9iJuGwARAQAqAAQKf0UAAgUACAjyJe0CAOgCAAUACAjyJe0CAOgCAAAA.',['茂的']='茂的模:BAAAKgAECgYIBAAAAA==.',['菊花']='菊花盛宴:BAAAKgADCggICAAAAA==.',['落寞']='落寞丶煙愺菋:BAACKgAFFH8uAAQcAAgIPwu2BwBGAQAcAAgIOQu2BwBGAQADAAMInwcoLwCyAAAjAAMIZxU3DgCMAAAqAAQKfy0AAwMACAgAF06IAIcBAAMABwgeFk6IAIcBACMACAgOEnIeAG4BAAAA.',['葵花']='葵花点穴手:BAABKgAFFH8iAAMZAAgIRRtAAwAkAgAZAAgIRRtAAwAkAgAPAAEIGgHpIgAwAAAAAA==.',['蓉儿']='蓉儿:BAAAKgADCgQIBAAAAA==.',['蓝心']='蓝心忆雨:BAAAKgAECgYIBgAAAA==.',['蓝蓝']='蓝蓝萌萌哒:BAAAKgADCggICAAAAA==.',['蕾蜜']='蕾蜜恩妖女:BAAAKgAECgMIAwAAAA==.',['薪火']='薪火:BAAAKgAECgIIAgAAAA==.',['藤井']='藤井树:BAAAKgAFFAMIAwAAAA==.',['虎皮']='虎皮瑞士卷:BAACKgAFFH8GAAIDAAYIThp2GACaAQADAAYIThp2GACaAQAqAAQKfxYAAgMACAjEHhY5ABwCAAMACAjEHhY5ABwCAAAA.',['蛋蛋']='蛋蛋的裂变:BAAAKgAECgUIBQAAAA==.',['血之']='血之魔煞:BAAAKgAECggICAAAAA==.',['西瓜']='西瓜妹妹:BAAAKgAECgMIAwAAAA==.',['西西']='西西丶:BAAAKgAECggICAAAAA==.西西喵丶:BAAAKgAECggICAAAAA==.',['语文']='语文术学:BAAAKgAECggIDAAAAA==.',['请你']='请你吃冰糕:BAAAKgAECggICAAAAA==.',['诺斯']='诺斯提克:BAABKgAECn8kAAIUAAgIJhcqHQDqAQAUAAgIJhcqHQDqAQAAAA==.',['贝狄']='贝狄威尔:BAABKgAFFH8FAAIcAAQIXQ5fEgDqAAAcAAQIXQ5fEgDqAAAAAA==.',['贾斯']='贾斯汀逼波:BAAAKgAECggIDwAAAA==.',['赞美']='赞美丰饶:BAAAKgAECgMIAwAAAA==.',['赞达']='赞达拉护卫者:BAAAKgAECgEIAQAAAA==.',['赢丶']='赢丶:BAAAKgAECgUIBQAAAA==.',['超大']='超大榛果拿铁:BAABKgAECn8dAAIgAAgISBLIHwB7AQAgAAgISBLIHwB7AQAAAA==.',['超级']='超级莼菜:BAABKgAECn8VAAMCAAgIHBSuEgBNAQACAAgIHBSuEgBNAQAMAAEIkBJoRwA6AAAAAA==.超级鼻涕牛:BAAAKgADCgEIAQAAAA==.',['跢他']='跢他伽多耶:BAAAKgAECgEIAQAAAA==.',['轩么']='轩么哥:BAAAKgAECggICAAAAA==.',['转伍']='转伍拾给灌注:BAAAKgAECgYIEAABKgAECggIQwAiAEghAA==.',['轰炸']='轰炸鸡:BAAAKgADCgIIAwAAAA==.',['辉煌']='辉煌后的忧伤:BAAAKgAFFAQIAgAAAA==.',['辛红']='辛红辣椒:BAAAKgAECggICgAAAA==.',['辣油']='辣油:BAAAKgAECgIIAwAAAA==.',['辣鸡']='辣鸡有喜:BAABKgAECn8VAAIJAAgIxAWBNgCsAAAJAAgIxAWBNgCsAAAAAA==.',['还君']='还君明珠泪:BAAAKgADCgcIDgAAAA==.',['这货']='这货能打:BAAAKgAFFAgIAQAAAA==.',['迪卡']='迪卡斯迈:BAABKgAFFH8FAAMHAAMI5Q54IgBuAAAHAAIIxwx4IgBuAAAeAAEIIBPQIQBFAAAAAA==.',['逆天']='逆天剑魔:BAAAKgAFFAQIBAAAAA==.',['逆风']='逆风斩雨:BAAAKgAECgQIBAAAAA==.',['逐丶']='逐丶风:BAABKgAFFH8IAAIBAAgIGgImEgAOAQABAAgIGgImEgAOAQAAAA==.',['過過']='過過:BAAAKgAFFAIIAgAAAA==.',['那是']='那是鱼:BAAAKgADCgcIBwAAAA==.',['邪瞳']='邪瞳:BAAAKgAECgcIBwAAAA==.',['部落']='部落牛栏山:BAAAKgADCggICAAAAA==.',['醉后']='醉后一夜:BAAAKgADCgUIBQABKgAFFAgILgAcAD8LAA==.',['醉後']='醉後壹夜:BAABKgAFFH8IAAIOAAMIcwpJDQDaAAAOAAMIcwpJDQDaAAABKgAFFAgILgAcAD8LAA==.',['采药']='采药:BAABKgAFFH8IAAIVAAQIBSXMCAAoAQAVAAQIBSXMCAAoAQABKgAFFAgIUAAVABcmAA==.',['铁甲']='铁甲小宝:BAABKgAECn8VAAMFAAgIdxELRQB0AQAFAAgIdxELRQB0AQAGAAYI2iLQPgAwAQABKgAFFAgIDwAOAC4bAA==.',['锅子']='锅子盖:BAAAKgAFFAQIBAAAAA==.',['长空']='长空铁鹰:BAAAKgAECgUIBQAAAA==.',['间歇']='间歇发疯体:BAABKgAFFH8GAAIDAAMIFhKISQDbAAADAAMIFhKISQDbAAAAAA==.',['阎王']='阎王愁:BAAAKgAECgIIAwAAAA==.',['阿伦']='阿伦魏:BAAAKgADCgUIBQAAAA==.',['阿科']='阿科猛德:BAAAKgADCggICAAAAA==.',['雨中']='雨中行走:BAABKgAFFH8XAAMCAAQI+w8QDwCvAAAMAAQI+w+tKADAAAACAAMIuQgQDwCvAAAAAA==.',['雪域']='雪域寒冰:BAAAKgADCgIIAgAAAA==.',['雾丶']='雾丶茫茫:BAAAKgAECgYIBgAAAA==.',['霜火']='霜火法:BAAAKgAFFAEIAQAAAA==.',['露露']='露露逗你开心:BAABKgAFFH8GAAMDAAYI1hx8BgBNAQADAAQIOiV8BgBNAQAcAAIIQhC0DgCRAAAAAA==.',['静心']='静心:BAABKgAFFH8QAAMQAAYIWx9fAwDaAQAQAAYIKx5fAwDaAQACAAQIph/xBQABAQAAAA==.',['靛二']='靛二蛋:BAAAKgAFFAQIBAAAAA==.',['非崷']='非崷:BAAAKgAECggIDQAAAA==.',['非洲']='非洲之心:BAABKgAFFH8SAAQfAAgI6wa5DwAmAQAfAAQIXAe5DwAmAQALAAQIVQaULwCIAAAKAAMIDQdoIgB4AAAAAA==.',['韩芸']='韩芸汐:BAABKgAFFH8GAAIRAAUIaxTPEQDPAAARAAUIaxTPEQDPAAAAAA==.',['顽皮']='顽皮的小红河:BAAAKgAECgMIBAAAAA==.',['飍虎']='飍虎:BAAAKgAFFAQIBAAAAA==.飍虎巉瀺:BAABKgAFFH8JAAQHAAYIrhFHKgDEAAAHAAMI/RJHKgDEAAAeAAIIMg9bEgCUAAAdAAIIKgpAKwBEAAAAAA==.',['风逍']='风逍遥:BAAAKgAECgUIBgAAAA==.',['飞翔']='飞翔的甲壳虫:BAAAKgAFFAIIAwAAAA==.',['香菇']='香菇炖鸡面:BAABKgAFFH8GAAIbAAMIKAO/KwBwAAAbAAMIKAO/KwBwAAAAAA==.',['鬥魂']='鬥魂:BAAAKgAECgEIAQAAAA==.',['鬼畫']='鬼畫符:BAAAKgADCggICAAAAA==.',['魂巨']='魂巨人:BAABKgAFFH8GAAIJAAYIFRWFDABLAQAJAAYIFRWFDABLAQAAAA==.',['魂狩']='魂狩之神力:BAAAKgADCgYIBgAAAA==.',['魑魅']='魑魅狐:BAAAKgAECgIIAgAAAA==.',['魔幻']='魔幻山城:BAAAKgAFFAIIAwAAAA==.',['鮟鱇']='鮟鱇鱼:BAAAKgAECggIDgAAAA==.',['鱼脖']='鱼脖:BAAAKgADCgYIBgAAAA==.',['鹰角']='鹰角弓:BAABKgAFFH8IAAISAAgILQCtMgAhAAASAAgILQCtMgAhAAAAAA==.',['麦克']='麦克阿瑟:BAAAKgADCgUIBQAAAA==.',['黄皮']='黄皮耗子:BAAAKgAFFAQIAgAAAA==.',['黑壮']='黑壮村大叔:BAAAKgAECggICAAAAA==.',['黑手']='黑手小术:BAABKgAFFH8MAAIHAAYIphGkFQBWAQAHAAYIphGkFQBWAQAAAA==.',['齐德']='齐德龙:BAABKgAFFH8LAAIXAAYIxxDMEwAzAQAXAAYIxxDMEwAzAQAAAA==.',['齐格']='齐格非:BAABKgAECn8UAAMCAAgIGR1GMQCuAQACAAgIgxxGMQCuAQAQAAYItRkaTQBLAQAAAA==.',['龍裔']='龍裔:BAABKgAFFH8IAAIXAAQITBVBJACvAAAXAAQITBVBJACvAAAAAA==.',['龙姐']='龙姐不想黑:BAABKgAFFH8IAAIRAAQI0SCoCwDvAAARAAQI0SCoCwDvAAAAAA==.',['龙源']='龙源:BAAAKgAFFAMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end