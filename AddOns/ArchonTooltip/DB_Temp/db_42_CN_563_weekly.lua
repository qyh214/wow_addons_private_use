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
 local lookup = {'Druid-Restoration','Druid-Balance','Hunter-Marksmanship','Mage-Frost','Monk-Mistweaver','Warlock-Affliction','DeathKnight-Blood','DeathKnight-Unholy','Hunter-BeastMastery','Paladin-Protection','Warlock-Destruction','Priest-Holy','Priest-Shadow','Paladin-Holy','Paladin-Retribution','Warrior-Arms','Mage-Fire','Shaman-Restoration','Priest-Discipline','Unknown-Unknown','DemonHunter-Havoc','Shaman-Elemental','Warrior-Fury','Warrior-Protection','Warlock-Demonology','Monk-Windwalker','Rogue-Assassination','Hunter-Survival','DeathKnight-Frost','Mage-Arcane','Evoker-Preservation','Evoker-Devastation','Rogue-Outlaw','Rogue-Subtlety','DemonHunter-Vengeance',}; local provider = {region='CN',realm='丹莫德',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ab='Abababababa:BAABKgAFFH8WAAMBAAYIMyDcBQC/AQABAAYIMyDcBQC/AQACAAQIkBzLKgDoAAAAAA==.',Ap='Applejuice:BAABKgAFFH8IAAIDAAgIgxbRBQAUAgADAAgIgxbRBQAUAgAAAA==.',Ba='Baku:BAABKgAECn8XAAIEAAgIEBnBFQAMAgAEAAgIEBnBFQAMAgAAAA==.Baner:BAABKgAFFH8WAAMBAAgIpRgZAwAgAgABAAgIpRgZAwAgAgACAAUIRiBGGwBAAQAAAA==.',Be='Beauty:BAABKgAECn8UAAIFAAgIYglLNwDzAAAFAAgIYglLNwDzAAAAAA==.Beetomb:BAAAKgADCgcIBwAAAA==.',Co='Coldsama:BAABKgAFFH8MAAIDAAYIKyQVAAAjAgADAAYIKyQVAAAjAgABKgAFFAgIJQAGACEcAA==.Columbia:BAACKgAFFH8GAAIDAAYICw2HGwASAQADAAYICw2HGwASAQAqAAQKfyQAAgMACAiEIccNAI4CAAMACAiEIccNAI4CAAAA.Conjurs:BAABKgAFFH8MAAMHAAcIbxFsDgA1AQAHAAcIbxFsDgA1AQAIAAEIuxYyLgBRAAAAAA==.',De='Deathn:BAAAKgAFFAQIBAAAAA==.',Di='Disconice:BAAAKgAECgEIAQAAAA==.',Dl='Dloneyear:BAACKgAFFH8NAAMDAAYIuR8VBQAjAQADAAYIuR8VBQAjAQAJAAMI4Q4IOQCFAAAqAAQKfyIAAwMACAjdI4EMAHkCAAMACAiSI4EMAHkCAAkACAibHmgiAGsCAAAA.',Do='Doomghost:BAAAKgADCgMIAwAAAA==.Doublekiki:BAAAKgAECgYIBgAAAA==.',El='Eludecia:BAABKgAFFH8IAAIKAAgIQAiSCwA+AQAKAAgIQAiSCwA+AQAAAA==.',Fr='Frefh:BAAAKgAFFAgIBAAAAA==.',Fs='Fstb:BAAAKgAECgQIAwAAAA==.',Gi='Giveyou:BAAAKgAECgQIBAAAAA==.',Go='Gobang:BAAAKgAECgQIBAAAAA==.',Gu='Guerdan:BAABKgAFFH8GAAILAAMIZyCTCAAgAQALAAMIZyCTCAAgAQAAAA==.',Hb='Hbend:BAAAKgAFFAQIBAAAAA==.',Hr='Hrunting:BAAAKgAECggICAAAAA==.',Ko='Kosmso:BAABKgAFFH8IAAMMAAgIGR79BADuAQAMAAcIoh39BADuAQANAAEI3gs/LABDAAAAAA==.',Lo='Loosepusysy:BAABKgAFFH8QAAQOAAYIoCKBAwDYAQAOAAYIoCKBAwDYAQAKAAYIhQ7SAwA4AQAPAAQIqyPICQAxAQABKgAFFAgIJQAPAIshAA==.',Lu='Luckylife:BAABKgAFFH8HAAMCAAQIIRSVGgDVAAACAAQIIRSVGgDVAAABAAEIPBHVIABBAAAAAA==.',Ma='Magefire:BAAAKgADCggICAAAAA==.Mangojuice:BAABKgAFFH8HAAIIAAYIexsuEQCSAQAIAAYIexsuEQCSAQAAAA==.',Mi='Minix:BAAAKgAECgYIDQAAAA==.',Mo='Morall:BAAAKgADCggICAAAAA==.',Ne='Nevxvm:BAABKgAFFH8OAAICAAgIPxzUBAB9AgACAAgIPxzUBAB9AgAAAA==.',Pa='Paradise:BAAAKgAECgEIAQAAAA==.',Pr='Predator:BAAAKgAFFAYIAgAAAA==.',Pu='Punchme:BAAAKgADCgMIAwAAAA==.',Qo='Qosdjf:BAAAKgAECggICAAAAA==.',Se='Seiunsky:BAAAKgAECgMIAwAAAA==.',Sh='Shelby:BAAAKgAECgQIBQAAAA==.Shiinamahiru:BAAAKgAECgcICAAAAA==.',Si='Sincejuly:BAAAKgADCggICAAAAA==.',Sm='Smalldonkey:BAAAKgAFFAIIAwAAAA==.',Sp='Springmao:BAAAKgAECggIDgAAAA==.Spyfay:BAAAKgAFFAQIBAAAAA==.',St='Stillawinds:BAAAKgAFFAgIBAAAAA==.',Th='Themoonl:BAAAKgAFFAQIBAAAAA==.',Ti='Titanlol:BAAAKgADCggICAAAAA==.',Tr='Traps:BAAAKgAFFAEIAgAAAA==.Traxex:BAABKgAFFH8LAAIJAAQISyHEHQAZAQAJAAQISyHEHQAZAQAAAA==.',['Ãä']='Ãäãä:BAAAKgAFFAEIAQAAAA==.',['一代']='一代牧:BAAAKgAFFAMIAwAAAA==.',['一剑']='一剑攞伱命:BAAAKgADCgIIAgAAAA==.',['一条']='一条不归路:BAABKgAECn8UAAIPAAgIVCAbKQB4AgAPAAgIVCAbKQB4AgAAAA==.',['一生']='一生香伴:BAAAKgAFFAQIBAAAAA==.',['一起']='一起冲:BAAAKgAECgUIBwAAAA==.',['七喜']='七喜:BAAAKgADCggICAAAAA==.',['万花']='万花不点墨:BAAAKgAFFAMIAwAAAA==.',['不会']='不会取名:BAAAKgAECgcIBwAAAA==.不会取名骑:BAABKgAECn8ZAAMPAAgIshOHIwCjAQAPAAgIshOHIwCjAQAKAAIIwwaeIgA1AAAAAA==.不会黑了:BAABKgAFFH8GAAIQAAYIAg92DgAqAQAQAAYIAg92DgAqAQAAAA==.',['不带']='不带这么玩的:BAAAKgAECgMIAwAAAA==.',['不忘']='不忘初心小吼:BAAAKgADCggICAAAAA==.',['不死']='不死不转火:BAAAKgAECgUIBQAAAA==.',['不西']='不西的春天:BAAAKgAECggIAQAAAA==.',['东北']='东北的阿昆达:BAAAKgAFFAQIBAAAAA==.',['丢丢']='丢丢小锤子:BAACKgAFFH8RAAIKAAMIEQU6JABmAAAKAAMIEQU6JABmAAAqAAQKf0QAAgoACAgqF98SANcBAAoACAgqF98SANcBAAAA.',['两小']='两小儿辨曰:BAAAKgADCgEIAQAAAA==.两小儿辩曰:BAABKgAFFH8GAAIPAAYIdBgNGgCQAQAPAAYIdBgNGgCQAQAAAA==.',['丨女']='丨女骑士丨:BAAAKgADCgEIAQAAAA==.',['丨小']='丨小疯丶:BAABKgAFFH8QAAIRAAYIIRrIDABqAQARAAYIIRrIDABqAQAAAA==.',['丨玻']='丨玻璃大炮:BAABKgAFFH8HAAIJAAYI6w/lFwA7AQAJAAYI6w/lFwA7AQAAAA==.',['中岛']='中岛美雪:BAABKgAFFH8LAAILAAMIKRJJFgDLAAALAAMIKRJJFgDLAAAAAA==.',['丶尼']='丶尼克:BAABKgAECn8UAAISAAgI3xfnSwBLAQASAAgI3xfnSwBLAQAAAA==.',['丶张']='丶张柏芝:BAABKgAECn8fAAMJAAgI+yGbGgCPAgAJAAgI+yGbGgCPAgADAAMI/AR6gwBDAAAAAA==.',['丶无']='丶无忧:BAAAKgAFFAYIAgAAAA==.',['丶月']='丶月神:BAABKgAECn8YAAIPAAgIjg0hQwD8AAAPAAgIjg0hQwD8AAAAAA==.',['丶琛']='丶琛:BAAAKgADCgYIAwAAAA==.',['丶美']='丶美呆:BAABKgAFFH8GAAIMAAYISRZOCQBFAQAMAAYISRZOCQBFAQAAAA==.',['丶钢']='丶钢铁侠:BAAAKgAECgcIBwAAAA==.',['乃乃']='乃乃个熊:BAAAKgAECgUIBwAAAA==.',['乌斯']='乌斯:BAAAKgAECgYIBgAAAA==.',['乌瑟']='乌瑟儿:BAAAKgAECgMIAwAAAA==.',['九十']='九十斤:BAAAKgADCgUIBQAAAA==.',['乳牛']='乳牛特伦酥:BAAAKgADCggICgAAAA==.',['云汐']='云汐:BAAAKgAECggICwABKgAFFAgIDQAFAPgaAA==.',['云深']='云深蓝:BAABKgAFFH8IAAIPAAgICg9JCwDuAQAPAAgICg9JCwDuAQAAAA==.',['云紫']='云紫幽兰:BAABKgAFFH8IAAITAAgISA4wBAC6AQATAAgISA4wBAC6AQAAAA==.',['云若']='云若兮:BAAAKgAECgEIAQAAAA==.',['云葬']='云葬月:BAABKgAFFH8GAAIIAAYIZQisDAA4AQAIAAYIZQisDAA4AQAAAA==.',['亚煞']='亚煞极:BAAAKgAECgQIBAAAAA==.',['亡骑']='亡骑霸天:BAABKgAFFH8OAAMHAAYItx1YCwBcAQAHAAYIdhhYCwBcAQAIAAQIESDLJwDvAAAAAA==.',['亵渎']='亵渎杀戮:BAAAKgADCgEIAQAAAA==.',['人生']='人生休说痛苦:BAABKgAECn8YAAMDAAgIDhiDKgC8AQADAAgIlReDKgC8AQAJAAYITxK8gQAxAQABKgAFFAgIBAAUAAAAAA==.',['人造']='人造雷轰渣男:BAABKgAFFH8IAAISAAQIuB2mDgDrAAASAAQIuB2mDgDrAAAAAA==.',['亿叮']='亿叮定乾坤:BAABKgAFFH8MAAMPAAgIxyD3AwCfAgAPAAgIxyD3AwCfAgAOAAQIvho+CwD1AAAAAA==.',['仁科']='仁科百华:BAAAKgAECgEIAQAAAA==.',['伊丶']='伊丶利丶丹:BAABKgAFFH8LAAIVAAYIjB5cCwDSAQAVAAYIjB5cCwDSAQAAAA==.',['伊文']='伊文睿:BAAAKgAFFAMIAwAAAA==.',['伊老']='伊老猎头:BAAAKgAFFAQIAwAAAA==.',['伊莱']='伊莱克斯:BAAAKgAECgIIBAAAAA==.',['伏灬']='伏灬特加:BAAAKgAECgQIBAAAAA==.',['伐要']='伐要太难看:BAAAKgAECggIDwAAAA==.',['伟大']='伟大教员:BAAAKgAECgcIDAAAAA==.',['低等']='低等动物:BAAAKgAECggIEgAAAA==.',['余音']='余音丶:BAAAKgAFFAgIBAAAAA==.',['你带']='你带孩子先走:BAAAKgADCgEIAQAAAA==.',['你特']='你特么逗我呢:BAAAKgADCgEIAQAAAA==.',['你相']='你相信光嗎:BAAAKgADCggICAAAAA==.',['俺要']='俺要吃蜂蜜:BAABKgAFFH8FAAISAAMIxAWAIQB6AAASAAMIxAWAIQB6AAAAAA==.',['倚栏']='倚栏听风:BAAAKgAECgcIDAAAAA==.',['倚楼']='倚楼听春雨:BAAAKgAECgcIEgAAAA==.',['偏分']='偏分:BAAAKgADCggICAAAAA==.',['偶不']='偶不是天然呆:BAAAKgADCggICAAAAA==.',['傻傻']='傻傻的馒馒:BAABKgAFFH8IAAIWAAQIRBQcDQDDAAAWAAQIRBQcDQDDAAAAAA==.',['像只']='像只大虾:BAABKgAFFH8UAAMBAAYItxePAQCnAQABAAYItxePAQCnAQACAAUIqRN4GADcAAABKgAFFAgIBAAUAAAAAA==.',['先祖']='先祖之父:BAAAKgAECgYIBgAAAA==.',['光明']='光明圣泉:BAAAKgAECgQIBAAAAA==.',['克里']='克里斯丶:BAAAKgAECgMIAwAAAA==.',['兜兜']='兜兜木有豆豆:BAACKgAFFH8jAAMNAAgIsBhnDwAPAQANAAQIrRJnDwAPAQAMAAcIhw79HgDNAAAqAAQKfxgABAwACAj2IQYMAHYCAAwACAj2IQYMAHYCAA0ABAhbHTgmAFYBABMAAgiOBriGAEUAAAAA.',['入戯']='入戯丶冭深:BAACKgAFFH8IAAIXAAgIoQ05BwDxAQAXAAgIoQ05BwDxAQAqAAQKfyQAAxcACAipFqopAOQBABcACAipFqopAOQBABgABwiuCNMvALcAAAAA.',['全身']='全身都是毒:BAABKgAECn8eAAMJAAgIMxQCUQBpAQAJAAgI/RMCUQBpAQADAAMIpQ8wfgCBAAAAAA==.',['八爺']='八爺:BAAAKgADCggIEAAAAA==.',['六六']='六六霸霸:BAAAKgAECgYIBgAAAA==.',['再嘘']='再嘘也要社:BAACKgAFFH8GAAMDAAIILwqeSABeAAADAAIItAieSABeAAAJAAIIAAhWVQBYAAAqAAQKfyAAAwkACAh3GOw4ABICAAkACAh3GOw4ABICAAMAAgjoCeyXAEsAAAAA.',['再烦']='再烦打你哦:BAAAKgAECgUIBQAAAA==.',['冰封']='冰封球:BAAAKgAFFAEIAgAAAA==.',['冰山']='冰山大火:BAAAKgAECgMIAwAAAA==.',['初吻']='初吻给了酒杯:BAAAKgAECgcIBwAAAA==.',['别闹']='别闹丶揍他:BAABKgAFFH8HAAMDAAQI9xVFDADrAAADAAQIOhNFDADrAAAJAAMI7BDzSwB4AAAAAA==.',['刻于']='刻于星月之铭:BAAAKgAFFAMIAwAAAA==.',['剥皮']='剥皮小能手:BAAAKgAECgIIAgAAAA==.',['副主']='副主编:BAABKgAFFH8aAAISAAQIdSG+GQAZAQASAAQIdSG+GQAZAQAAAA==.',['功夫']='功夫魔头:BAAAKgAECgcICAAAAA==.',['勇士']='勇士们丶进攻:BAAAKgAECggIEAAAAA==.',['北川']='北川杏树:BAAAKgAECgUIBQAAAA==.',['南瓜']='南瓜:BAAAKgAECgEIAQAAAA==.',['博列']='博列别:BAABKgAFFH8IAAIHAAQIqwxeFQChAAAHAAQIqwxeFQChAAAAAA==.',['卡布']='卡布奇诺丶丶:BAAAKgAECgUIBgAAAA==.',['卡琳']='卡琳牧:BAAAKgADCgMIAwAAAA==.',['卡璐']='卡璐伊:BAAAKgADCggICAAAAA==.',['厄洛']='厄洛法特:BAAAKgADCggICAAAAA==.',['厕纸']='厕纸狂飞:BAAAKgADCgEIAQAAAA==.',['叁面']='叁面夏娃:BAAAKgAECgYICQAAAA==.',['只要']='只要喝可乐:BAAAKgAECgEIAQAAAA==.',['可靠']='可靠的女人:BAAAKgAECgUIBQAAAA==.',['叶月']='叶月抹茶:BAAAKgAECgUIBQAAAA==.',['吃瓜']='吃瓜丶群众:BAAAKgAECgQIBgAAAA==.',['吗马']='吗马:BAACKgAFFH8pAAMJAAcI/BzpEgBfAQAJAAcI/BzpEgBfAQADAAYIYxYkFwAtAQAqAAQKfy0AAgkACAizIigPAMUCAAkACAizIigPAMUCAAAA.',['君住']='君住长江头:BAABKgAFFH8IAAIBAAQIywPeEwBsAAABAAQIywPeEwBsAAAAAA==.',['君心']='君心我心:BAAAKgADCgIIAgAAAA==.',['吥髙']='吥髙興:BAABKgAFFH8WAAICAAgI7xlABABzAQACAAgI7xlABABzAQAAAA==.',['吾达']='吾达爷:BAAAKgADCgMIAwAAAA==.',['咋真']='咋真紧张:BAAAKgADCggICgAAAA==.',['和花']='和花花:BAAAKgADCgUIBQAAAA==.',['咖喱']='咖喱好吃丶:BAAAKgADCgIIAgAAAA==.',['咪咪']='咪咪虾条:BAABKgAFFH8IAAIIAAYI/RI1FwBjAQAIAAYI/RI1FwBjAQAAAA==.',['哇丶']='哇丶你的鸡丁:BAAAKgAECgIIAgAAAA==.',['响暮']='响暮崩云:BAAAKgAECgQIAwAAAA==.',['啊名']='啊名:BAAAKgAFFAgIBAAAAA==.',['啪啪']='啪啪君:BAAAKgADCgMIAwAAAA==.',['嘉然']='嘉然亡命天涯:BAAAKgAECgMIAwAAAA==.',['嘿丶']='嘿丶流氓:BAAAKgAECggICAAAAA==.',['四二']='四二五柳枝:BAAAKgADCgEIAQAAAA==.',['四季']='四季鲜奶吧:BAAAKgADCggICAAAAA==.',['囧猎']='囧猎囧:BAAAKgAFFAYIBAAAAA==.',['国宝']='国宝囡囡:BAABKgAFFH8TAAISAAMIJxVoLwC6AAASAAMIJxVoLwC6AAAAAA==.国宝是我:BAAAKgAFFAYIBAAAAA==.',['圣光']='圣光之牙:BAAAKgADCggICAAAAA==.',['圣火']='圣火喵喵教徒:BAABKgAFFH8FAAIPAAUI9AS1SADdAAAPAAUI9AS1SADdAAAAAA==.',['地狱']='地狱游神:BAABKgAFFH8GAAIJAAYIXRQ1EwBcAQAJAAYIXRQ1EwBcAQAAAA==.地狱猎头者:BAAAKgADCgYIBgAAAA==.',['坚果']='坚果:BAAAKgAECgUIBQAAAA==.',['堕落']='堕落丨恶魔:BAABKgAFFH8GAAIVAAYIPBK4FgBFAQAVAAYIPBK4FgBFAQAAAA==.',['墨汁']='墨汁缭乱:BAABKgAECn8XAAMLAAgIYBzZLQC8AQALAAYIeR7ZLQC8AQAZAAMIExjnWwCQAAABKgAFFAYIFwAaABMeAA==.',['墩墩']='墩墩:BAAAKgAECgIIAwAAAA==.',['壹壹']='壹壹得一:BAAAKgADCgIIAgABKgAFFAgICAAJAHkiAA==.',['夕阳']='夕阳:BAAAKgAFFAQIBAAAAA==.',['夜之']='夜之暗面:BAABKgAFFH8KAAIbAAYI7h9mBgAXAQAbAAYI7h9mBgAXAQABKgAFFAgIMwAbAOQgAA==.',['夜幕']='夜幕无言:BAAAKgADCggICAAAAA==.',['夜晚']='夜晚的圣光:BAAAKgAFFAQIBAAAAA==.',['夜未']='夜未央:BAAAKgAFFAMIBAABKgAFFAgIIwASAHYaAA==.',['夜雨']='夜雨灬灯落下:BAABKgAECn8bAAIEAAgICRNwEQBgAQAEAAgICRNwEQBgAQAAAA==.',['大伯']='大伯奶奶:BAAAKgAECgIIAgAAAA==.',['大哥']='大哥丿大:BAAAKgAECgcIDQAAAA==.',['大师']='大师在此:BAAAKgAECgIIAwAAAA==.',['大杯']='大杯杨枝甘露:BAAAKgADCgEIAQAAAA==.',['大桥']='大桥丶未久:BAAAKgAFFAIIAgAAAA==.',['大牛']='大牛仔:BAABKgAECn8jAAIPAAgINCU6GAClAgAPAAgINCU6GAClAgABKgAFFAYIDAABAG4MAA==.',['大经']='大经理:BAACKgAFFH8PAAMaAAYIJhlmEgDPAAAaAAMIvRZmEgDPAAAFAAQIKhvZHAC4AAAqAAQKfygAAwUACAjzHxwRAGACAAUACAjzHxwRAGACABoACAjpFBg1AE0BAAAA.',['大耳']='大耳朵:BAAAKgAECgIIAgAAAA==.',['大貔']='大貔貅:BAABKgAFFH8JAAILAAcIcCJZEQDgAAALAAcIcCJZEQDgAAAAAA==.',['大飞']='大飞:BAAAKgADCggICAAAAA==.',['大饼']='大饼迦油条:BAAAKgAECgEIAQAAAA==.',['天下']='天下牧:BAACKgAFFH8JAAITAAMI9RbHGADLAAATAAMI9RbHGADLAAAqAAQKfxQAAhMACAi6FG8eAKgBABMACAi6FG8eAKgBAAAA.',['天使']='天使会掉毛:BAABKgAFFH8GAAIHAAQIQxBwCQD3AAAHAAQIQxBwCQD3AAABKgAFFAgIEQADAPEhAA==.',['天宸']='天宸:BAAAKgAFFAYIBAAAAA==.',['天海']='天海春香:BAACKgAFFH8XAAIaAAYIEx6KBwCEAQAaAAYIEx6KBwCEAQAqAAQKfyEAAhoACAiJINcPAGgCABoACAiJINcPAGgCAAAA.',['天灾']='天灾小蚊香:BAAAKgADCgMIAwAAAA==.',['天选']='天选之子:BAAAKgADCgMIAwAAAA==.',['奈伊']='奈伊组忒:BAABKgAFFH8NAAIBAAQInR7dEwABAQABAAQInR7dEwABAQAAAA==.',['奥特']='奥特曼小怪兽:BAAAKgAFFAQIBAAAAA==.',['如今']='如今已然厌倦:BAAAKgAECgcIBwAAAA==.',['如沐']='如沐丶春风:BAACKgAFFH8OAAIPAAMIpRCwJwDTAAAPAAMIpRCwJwDTAAAqAAQKfxoAAg8ACAgDG/5JABMCAA8ACAgDG/5JABMCAAEqAAUUCAgjABIAdhoA.',['娇姐']='娇姐一米八:BAAAKgAECggICAAAAA==.',['娇婵']='娇婵:BAAAKgAECggIDgAAAA==.',['娇宠']='娇宠:BAAAKgADCgEIAQAAAA==.',['娇羞']='娇羞:BAAAKgAECgQIBAAAAA==.',['孤云']='孤云:BAAAKgAECgYIBgAAAA==.',['孤独']='孤独婉儿:BAAAKgADCgMIAwAAAA==.',['安康']='安康鱼:BAAAKgADCggICAAAAA==.',['安赛']='安赛龙:BAABKgAFFH8MAAIXAAYIpSAzCADXAQAXAAYIpSAzCADXAQAAAA==.',['宫肋']='宫肋咲良:BAABKgAECn8WAAIIAAgI9R7XCAALAgAIAAgI9R7XCAALAgAAAA==.',['寒蕊']='寒蕊:BAABKgAFFH8PAAITAAQISwp+IQCeAAATAAQISwp+IQCeAAAAAA==.',['射灬']='射灬射灬射灬:BAAAKgAFFAMIBAABKgAFFAgIEwAJAOUdAA==.',['小丶']='小丶跳蛙丨:BAAAKgAFFAIIAgAAAA==.',['小太']='小太爷孟烦了:BAAAKgAECgUICgAAAA==.',['小子']='小子蛮坏:BAABKgAECn9HAAQDAAgINSR/CQC1AgADAAgIYiN/CQC1AgAJAAgI0R9yKQBNAgAcAAIIsA6iGgBZAAAAAA==.',['小寶']='小寶歸來:BAAAKgAECgYIBgAAAA==.',['小小']='小小乙:BAAAKgAECgUIBQAAAA==.小小萨鲁法尔:BAACKgAFFH8FAAIIAAIIpQy4JQCPAAAIAAIIpQy4JQCPAAAqAAQKfyQAAwgACAhcH4QUAGcCAAgACAhwHoQUAGcCAB0ACAhMHXcOAK8BAAAA.',['小怪']='小怪兽凹凸曼:BAABKgAECn8cAAIJAAcIghXlVwBSAQAJAAcIghXlVwBSAQAAAA==.',['小憋']='小憋憋:BAAAKgAFFAgIAgAAAA==.',['小散']='小散仙:BAAAKgAFFAIIAgAAAA==.',['小朋']='小朋友飞起来:BAACKgAFFH8KAAIdAAMIjBOKBQCbAAAdAAMIjBOKBQCbAAAqAAQKfx0AAx0ACAjAH6oLAOcBAB0ABwg3IKoLAOcBAAgABQgzFkBbAFUBAAAA.',['小禽']='小禽獸丷:BAABKgAFFH8NAAIXAAQIXhgEGgDuAAAXAAQIXhgEGgDuAAAAAA==.',['小膏']='小膏药:BAAAKgAECgMIAwAAAA==.',['小龙']='小龙人菜:BAAAKgAECgQIBAAAAA==.',['尖椒']='尖椒肥肠盖饭:BAAAKgAECgcICQAAAA==.',['尾巴']='尾巴甩甩:BAAAKgAECggIEgAAAA==.',['岁月']='岁月兮无痕:BAABKgAFFH8GAAIDAAYInBjMBQAbAQADAAYInBjMBQAbAQAAAA==.',['布哪']='布哪那:BAAAKgAECgYIBgAAAA==.',['帅的']='帅的被人砍:BAAAKgAECgUIBQAAAA==.',['希女']='希女王丶:BAAAKgAFFAEIAQAAAA==.',['带你']='带你飞起来:BAAAKgAECgcIBwAAAA==.',['常巨']='常巨庆:BAABKgAFFH8KAAIWAAMIbghoHACXAAAWAAMIbghoHACXAAAAAA==.',['常庆']='常庆:BAAAKgAFFAEIAQAAAA==.',['干饭']='干饭小宝贝:BAAAKgAECgcIDAAAAA==.',['幻世']='幻世沧海:BAABKgAFFH8GAAMPAAQIbh9uGAD6AAAPAAQIbh9uGAD6AAAKAAIIGh2ZKQBDAAAAAA==.',['床头']='床头明月光:BAABKgAFFH8MAAMEAAQIzBGbCgDSAAAEAAMIWRGbCgDSAAAeAAQIIA+gGQCyAAAAAA==.',['弄大']='弄大你的奶娘:BAAAKgAECgIIAgAAAA==.',['当里']='当里个当:BAAAKgAECgcIDQAAAA==.',['影刃']='影刃:BAAAKgADCgMIAwAAAA==.',['影卝']='影卝帝:BAAAKgAECggICAAAAA==.',['往事']='往事誠迴:BAAAKgAECggICAAAAA==.',['得瑟']='得瑟猫:BAAAKgADCggICAAAAA==.',['微风']='微风吹:BAACKgAFFH8jAAISAAgIdhovBwDWAQASAAgIdhovBwDWAQAqAAQKfzIAAxIACAhPI20UAE4CABIACAhPI20UAE4CABYABQj9DIhUAKkAAAAA.',['德之']='德之我幸:BAABKgAFFH8LAAIBAAYIUiH9BADYAQABAAYIUiH9BADYAQABKgAFFAgIDgAMABEgAA==.',['心灵']='心灵纵火犯:BAABKgAFFH8WAAMEAAQIlRKHFwC4AAAEAAQIEhGHFwC4AAAeAAMI8AquOgB2AAAAAA==.',['心神']='心神风息:BAAAKgAECgQIBAAAAA==.',['悲伤']='悲伤奥利奥:BAABKgAFFH8PAAMeAAgIfx4QBgAsAgAeAAgI/RkQBgAsAgARAAQIMRcNFAD/AAAAAA==.',['惟馀']='惟馀莽莽:BAAAKgAECggICgAAAA==.',['慢慢']='慢慢地:BAAAKgADCgQIBAAAAA==.',['我妍']='我妍丶安希妍:BAAAKgAECgcICQAAAA==.我妍丶朴美妍:BAAAKgAFFAQIBAAAAA==.',['我希']='我希丶朱敏希:BAACKgAFFH8GAAIMAAMIswuYKgCZAAAMAAMIswuYKgCZAAAqAAQKfx0AAgwACAiUGdsrAHoBAAwACAiUGdsrAHoBAAAA.',['我要']='我要打十個:BAAAKgADCgIIAgAAAA==.',['战魂']='战魂之殇:BAAAKgAECgIIAgAAAA==.',['房裹']='房裹窝:BAABKgAECn8dAAMfAAgI6iA5BABoAgAfAAgI6iA5BABoAgAgAAUI8BPzQADIAAABKgAFFAgICAACAEQVAA==.',['托米']='托米大耳朵耶:BAAAKgAECgUIBgAAAA==.托米小粗腿耶:BAAAKgAFFAIIAgAAAA==.',['扯淡']='扯淡的世界:BAAAKgAECgEIAQAAAA==.',['扶摇']='扶摇丶:BAAAKgAECgUIBQAAAA==.',['指尖']='指尖流年:BAAAKgAECgUICgAAAA==.',['撕逼']='撕逼毁灭者:BAAAKgADCggIEAAAAA==.',['放学']='放学啃西瓜:BAAAKgAECggICwAAAA==.',['敖小']='敖小豆:BAAAKgAFFAYIBAAAAA==.',['敲他']='敲他烂番茄:BAAAKgADCggICAAAAA==.',['敲你']='敲你烂番茄:BAAAKgAECggIDQAAAA==.',['敲我']='敲我烂番茄:BAAAKgAECgMIAwAAAA==.',['无尘']='无尘三:BAABKgAFFH8IAAIeAAgILw6dCADtAQAeAAgILw6dCADtAQAAAA==.',['无尽']='无尽的江:BAABKgAFFH8OAAIFAAMIrxq2FwDjAAAFAAMIrxq2FwDjAAAAAA==.',['无敌']='无敌大波浪:BAAAKgAECgcIDQAAAA==.',['旧文']='旧文艺戏:BAAAKgAFFAQIBAAAAA==.',['时光']='时光的模样:BAAAKgAECgUICAAAAA==.',['明日']='明日香今日臭:BAAAKgAECgYIDgAAAA==.',['星空']='星空下的雨天:BAAAKgADCggICAAAAA==.',['星野']='星野丶瑞羽凉:BAAAKgAFFAIIAgAAAA==.',['昼奈']='昼奈儿丶:BAABKgAECn8UAAMKAAcILhOmJAAvAQAKAAcILhOmJAAvAQAPAAEIzAoXcgE3AAAAAA==.',['暖咚']='暖咚:BAAAKgAFFAQIAgAAAA==.',['暗夜']='暗夜阴影:BAAAKgADCgUIBQAAAA==.',['暗月']='暗月下的蓝:BAAAKgAECgQIBAAAAA==.',['暗黑']='暗黑破坏神:BAAAKgAFFAQIBAABKgAFFAgIDAALAMocAA==.',['曦仔']='曦仔:BAAAKgAECgYICQAAAA==.曦仔仔:BAAAKgAECggICAAAAA==.',['最终']='最终天堂:BAAAKgAECgYIBgAAAA==.',['有关']='有关单位:BAAAKgAECgIIAgAAAA==.',['来战']='来战个痛:BAACKgAFFH8RAAMhAAMIBCJlAgArAQAhAAMIBCJlAgArAQAiAAEIjQPpEgA8AAAqAAQKfxwABCEACAifHtILAGMBACIABggHG7IXAH4BACEABAgxINILAGMBABsABggKG1ERAAIBAAEqAAUUBggWAAEAMyAA.',['杨永']='杨永信丶:BAABKgAFFH8GAAMSAAYIZA7UJQDfAAASAAUI/ArUJQDfAAAWAAEIIwKxJwA9AAABKgAFFAgIDgASABkfAA==.',['枫糖']='枫糖费南雪:BAABKgAFFH8IAAILAAgI3g7VBgD/AQALAAgI3g7VBgD/AQAAAA==.',['柒肆']='柒肆带我飞:BAABKgAFFH8GAAIPAAYIMxwZEwDDAQAPAAYIMxwZEwDDAQAAAA==.',['柚木']='柚木缇娜:BAAAKgADCgEIAQAAAA==.',['栁岩']='栁岩:BAABKgAFFH8GAAIJAAYIvhkCEwBeAQAJAAYIvhkCEwBeAQAAAA==.',['栗子']='栗子:BAAAKgAECggICAAAAA==.',['桃田']='桃田賢斗:BAABKgAFFH8KAAMSAAQIvRfbDQDvAAASAAQIvRfbDQDvAAAWAAIInQr9FQByAAABKgAFFAgIAgAUAAAAAA==.',['梦中']='梦中花落多少:BAAAKgADCggICAAAAA==.',['梦幻']='梦幻华尔兹:BAAAKgADCggIDAAAAA==.',['椎名']='椎名真昼丶:BAAAKgAECgUIBQAAAA==.',['樱落']='樱落落:BAABKgAFFH8GAAIIAAYIIhKvCgBxAQAIAAYIIhKvCgBxAQAAAA==.',['橘子']='橘子汁:BAABKgAFFH8MAAILAAgIIxeIBAA6AgALAAgIIxeIBAA6AgAAAA==.',['橙南']='橙南:BAAAKgAECgEIAQAAAA==.',['橙色']='橙色的登爷:BAAAKgADCggICAAAAA==.',['欧泡']='欧泡:BAAAKgADCgEIAQAAAA==.',['武武']='武武:BAACKgAFFH8FAAIXAAIIigiVMQBsAAAXAAIIigiVMQBsAAAqAAQKfxQAAhcABwhmEkM2AE0BABcABwhmEkM2AE0BAAAA.',['歪搜']='歪搜希瑞斯:BAAAKgAFFAQIBAAAAA==.',['殛奶']='殛奶德:BAAAKgADCgEIAQAAAA==.',['殛萨']='殛萨满:BAAAKgAFFAMIAwAAAA==.',['毁灭']='毁灭旋律:BAABKgAFFH8OAAQEAAYIWRaGCwDSAAAEAAMIbA6GCwDSAAARAAQIKRY6HQDFAAAeAAIIohZjLwCmAAAAAA==.',['毕家']='毕家皮皮伟:BAAAKgAECgYICQAAAA==.',['毛秀']='毛秀才炒番茄:BAAAKgADCgIIAgAAAA==.',['氵灬']='氵灬尛漁丷:BAABKgAFFH8UAAMCAAgIRhbPCQD4AQACAAgIRhbPCQD4AQABAAQIwBNNDgC/AAAAAA==.',['江苏']='江苏吴彦祖丶:BAABKgAFFH8VAAIXAAYIDSHDAQC2AQAXAAYIDSHDAQC2AQAAAA==.',['沉默']='沉默的低调:BAABKgAFFH8IAAMLAAYIgx1CAQDsAQALAAYIgx1CAQDsAQAZAAEIHRWOEwBYAAAAAA==.沉默的幽灵:BAAAKgAECgYIAwAAAA==.',['沐锦']='沐锦:BAAAKgADCgIIAgAAAA==.',['没牛']='没牛牛的小犇:BAAAKgADCggICAAAAA==.',['油榨']='油榨街公牛:BAAAKgAECggICAAAAA==.',['油猫']='油猫丙:BAAAKgAECggIDQAAAA==.',['泌园']='泌园春雪:BAAAKgAECgcICgAAAA==.',['法如']='法如的龙木艮:BAABKgAFFH8KAAIXAAYIDR6KAAD+AQAXAAYIDR6KAAD+AQABKgAFFAgIBgAXABcZAA==.',['泥巴']='泥巴球:BAAAKgAFFAQIBAAAAA==.',['泰兰']='泰兰:BAABKgAFFH8IAAICAAgIHRy4BAB/AgACAAgIHRy4BAB/AgAAAA==.',['泰拦']='泰拦德的记忆:BAAAKgAFFAQIBAAAAA==.',['洛昂']='洛昂丨天角:BAAAKgADCggICAAAAA==.',['洛璃']='洛璃:BAABKgAFFH8NAAIbAAUI0xMZEgAxAQAbAAUI0xMZEgAxAQAAAA==.',['流星']='流星彗:BAAAKgAECgYIBgAAAA==.',['流浪']='流浪老头:BAABKgAFFH8GAAIJAAYI8A00EAAkAQAJAAYI8A00EAAkAQABKgAFFAgIBgAJAKcfAA==.',['浅浅']='浅浅灬:BAAAKgAECgMIBAAAAA==.',['海三']='海三鲜:BAAAKgAECgYICAAAAA==.',['海妖']='海妖丶:BAAAKgADCggICAAAAA==.',['深夏']='深夏:BAAAKgAECgYICgAAAA==.',['添香']='添香红袖:BAAAKgAECgMIAwAAAA==.',['清明']='清明微雨:BAABKgAFFH8IAAISAAQI2R3VCgACAQASAAQI2R3VCgACAQAAAA==.',['渥氏']='渥氏冰南蝶:BAAAKgAECgYICwAAAA==.',['湮灭']='湮灭回音:BAAAKgAECgQIBAAAAA==.',['源芯']='源芯:BAABKgAECn8VAAMCAAgI7hKHRQCVAQACAAgI7hKHRQCVAQABAAYIrgajVgCLAAAAAA==.',['满脸']='满脸狐渣:BAACKgAFFH8aAAQRAAUIPBvvEgAFAQARAAQI0RzvEgAFAQAeAAQIVBx+HgDyAAAEAAEIyw7YFABIAAAqAAQKfywABBEACAg6IjQMALMCABEACAgCIjQMALMCAAQAAwidIcNwALgAAB4AAQjeH2CGAFgAAAAA.',['漂浮']='漂浮群岛:BAACKgAFFH8LAAMjAAcIHRNyBgA5AQAjAAYIthRyBgA5AQAVAAEIIAvhSABMAAAqAAQKfyIAAxUACAieC0NcADQBABUACAieC0NcADQBACMAAQi5A2NsABMAAAAA.',['潺潺']='潺潺汩汩:BAAAKgADCgEIAQAAAA==.',['激励']='激励大黄蜂:BAAAKgAECgcIBwAAAA==.',['火山']='火山火山:BAAAKgAECggICAAAAA==.',['火舞']='火舞灬艳阳:BAAAKgAECggIDAAAAA==.',['火麟']='火麟德神:BAABKgAFFH8IAAIBAAgI3A9fBgCxAQABAAgI3A9fBgCxAQAAAA==.',['灬哪']='灬哪殤:BAAAKgAECggIEwAAAA==.',['灬天']='灬天真灬:BAAAKgADCggICAAAAA==.',['灯果']='灯果:BAAAKgADCgUIBQAAAA==.',['灵魂']='灵魂:BAAAKgAECgYIBgAAAA==.',['灾厄']='灾厄低语:BAACKgAFFH8iAAQbAAcIhxP8CwCNAQAbAAcIhxP8CwCNAQAiAAMIDAuVBQCpAAAhAAIIpgVbCgBdAAAqAAQKfyIAAyIACAg4GGgOAAICACIACAggFmgOAAICABsABAh6FAcqAAUBAAAA.',['烟雨']='烟雨浮生丶:BAAAKgAECggIDgAAAA==.',['煙歛']='煙歛寒林:BAAAKgADCggICAAAAA==.',['熊小']='熊小孩:BAAAKgADCgcIBwAAAA==.',['熊猫']='熊猫人学徒:BAAAKgAECgIIAgAAAA==.',['爱发']='爱发呆的笨猫:BAAAKgAFFAQIBAAAAA==.',['爱喝']='爱喝冰美式:BAAAKgADCggICAAAAA==.',['爵丶']='爵丶爷:BAAAKgAECgIIAgAAAA==.',['牛奶']='牛奶好喝丶:BAAAKgAFFAEIAQAAAA==.',['牛小']='牛小伟:BAAAKgAECgcIBwAAAA==.',['牛顿']='牛顿:BAAAKgAECgcIDQAAAA==.',['牧天']='牧天:BAAAKgAECggIEAAAAA==.',['牧牧']='牧牧神依:BAABKgAFFH8GAAITAAYINx3jAADwAQATAAYINx3jAADwAQAAAA==.',['特工']='特工小八:BAABKgAFFH8GAAQZAAQIgxn2EAC3AAAZAAMIBx72EAC3AAALAAIIgxEOMQBDAAAGAAEIUQcKIABAAAAAAA==.',['特长']='特长生:BAAAKgADCgEIAQAAAA==.',['独翼']='独翼天使:BAACKgAFFH8JAAMZAAMIHhVgDADSAAAZAAMIHhVgDADSAAALAAMICwsBGgCvAAAqAAQKfxUAAxkABwhRGtwuAC0BABkABwhRGtwuAC0BAAsAAQh7ExWmAD0AAAAA.',['狮蚀']='狮蚀胜于熊便:BAAAKgAECgMIAwAAAA==.',['猎王']='猎王战:BAAAKgADCgEIAQAAAA==.',['猛牛']='猛牛黑黑乳:BAAAKgADCggICAAAAA==.',['王炸']='王炸蛋:BAAAKgAECgMIAwAAAA==.',['瓦娜']='瓦娜斯:BAAAKgADCgEIAQAAAA==.',['生杀']='生杀予夺:BAAAKgAECgEIAQAAAA==.',['甩枪']='甩枪术:BAABKgAECn8XAAIDAAgINR58GwAeAgADAAgINR58GwAeAgAAAA==.',['男神']='男神:BAAAKgADCgYICQAAAA==.',['疯晴']='疯晴雪:BAAAKgADCgEIAQAAAA==.',['白不']='白不白:BAABKgAFFH8JAAIjAAMIMQj8IABbAAAjAAMIMQj8IABbAAAAAA==.',['白翼']='白翼誓约:BAABKgAECn88AAMbAAgICSLADQAqAgAbAAgICSLADQAqAgAiAAEIOApWOgApAAAAAA==.',['皇小']='皇小黄:BAAAKgADCggICAAAAA==.',['盔甲']='盔甲:BAABKgAFFH8TAAICAAMItxNGNADJAAACAAMItxNGNADJAAAAAA==.',['睿箖']='睿箖妈咪:BAAAKgAFFAQIBAAAAA==.',['瞎扯']='瞎扯蛋吧:BAAAKgADCgMIAwAAAA==.',['瞎指']='瞎指挥:BAAAKgAECgQIBAAAAA==.',['知天']='知天易逆天男:BAABKgAFFH8KAAMRAAUITBAPDAA8AQARAAUIOBAPDAA8AQAEAAQI8gwpDwCuAAAAAA==.',['石头']='石头碾侯爷:BAAAKgAECgMIAwAAAA==.',['硬硬']='硬硬的我:BAAAKgADCggICAAAAA==.',['硬笔']='硬笔的正反面:BAAAKgAECgYIBgAAAA==.',['神罗']='神罗天星:BAAAKgAECggICQAAAA==.',['神都']='神都为我哭泣:BAABKgAECn8cAAMNAAgI2R47EQAbAgANAAcIeR87EQAbAgAMAAMISAuxawBvAAAAAA==.',['秀爷']='秀爷:BAAAKgADCggICAAAAA==.',['穆拉']='穆拉甲铜须:BAAAKgAECgUIBQAAAA==.',['空间']='空间飞龙:BAABKgAFFH8KAAIFAAYIASIeBgDlAQAFAAYIASIeBgDlAQAAAA==.',['笑萨']='笑萨满:BAABKgAFFH8GAAMSAAYI5wtQKgDNAAASAAUIVgVQKgDNAAAWAAEI7AGPKAA4AAAAAA==.',['第一']='第一序列:BAAAKgADCggICAAAAA==.',['等风']='等风來灬:BAABKgAFFH8KAAMDAAYImxhUCgD3AAADAAQI1SBUCgD3AAAJAAIIRAxLQwCTAAAAAA==.',['箭啸']='箭啸:BAAAKgAECgYIBgAAAA==.',['精灵']='精灵丶荣耀:BAAAKgAECgYIBgAAAA==.',['糯糯']='糯糯的谁:BAAAKgADCggICAAAAA==.',['紅葉']='紅葉舞秋山:BAAAKgAECggIDAAAAA==.',['红色']='红色圆舞曲:BAAAKgADCgEIAQAAAA==.',['纳兰']='纳兰孤影:BAABKgAECn8aAAIPAAgIXxkOagCFAQAPAAgIXxkOagCFAQAAAA==.',['纳格']='纳格兰的夜空:BAAAKgADCgMIAwAAAA==.',['终是']='终是雾里看花:BAAAKgADCggICAAAAA==.',['终焉']='终焉骑士:BAAAKgAECgYIBgAAAA==.',['绝版']='绝版圣斗士:BAABKgAECn8hAAIJAAgIGRp4KAAQAgAJAAgIGRp4KAAQAgAAAA==.',['绯月']='绯月妖殇:BAABKgAFFH8KAAITAAYIiBbrCQB5AQATAAYIiBbrCQB5AQAAAA==.',['翼橙']='翼橙:BAACKgAFFH8fAAMJAAcIox6CCgDGAQAJAAcIox6CCgDGAQADAAMIUxNiFwCnAAAqAAQKfxwAAwkACAgFIjQmAFsCAAkACAgFIjQmAFsCAAMABAhvEJlPAN4AAAAA.',['老来']='老来多健忘:BAAAKgAECgQIBwAAAA==.',['老马']='老马最马虎:BAAAKgAECgIIAgAAAA==.',['聖光']='聖光苍穹:BAABKgAECn8gAAIPAAgIdiG6CgCZAgAPAAgIdiG6CgCZAgAAAA==.',['肥肠']='肥肠刺身盖饭:BAABKgAECn8dAAIZAAcIqxZ1HgCVAQAZAAcIqxZ1HgCVAQAAAA==.',['肮脏']='肮脏的世界:BAAAKgAECgEIAQAAAA==.',['胡子']='胡子大叔:BAABKgAFFH8fAAMHAAYIwxjECgBmAQAHAAYIwxjECgBmAQAIAAQImBHCEwDIAAAAAA==.',['胭脂']='胭脂桃花粉:BAAAKgAECgYIBgAAAA==.',['自由']='自由之羽:BAABKgAECn8gAAMFAAgIoRO1DABjAQAFAAgIoRO1DABjAQAaAAUIQhNrOwDpAAAAAA==.',['致命']='致命之剑丶:BAABKgAFFH8sAAIXAAQIAyXuEQA5AQAXAAQIAyXuEQA5AQAAAA==.',['舌形']='舌形刁手:BAABKgAFFH8LAAMRAAgI3CKMBABDAgARAAgIPB+MBABDAgAeAAIIXyBYKQC9AAAAAA==.',['舞力']='舞力拳鐦:BAAAKgAFFAIIAgAAAA==.',['艾欧']='艾欧里亚:BAABKgAFFH8HAAIVAAQIOCD0JQDgAAAVAAQIOCD0JQDgAAABKgAFFAgIBAAUAAAAAA==.',['艾琳']='艾琳纳:BAAAKgAECgIIAgAAAA==.',['花户']='花户小鸠:BAAAKgAECgQIBAAAAA==.',['花木']='花木兰丶:BAABKgAECn8YAAIJAAgIqxkSSgDVAQAJAAgIqxkSSgDVAQAAAA==.',['花沐']='花沐兰:BAAAKgADCggICAAAAA==.',['苍蝇']='苍蝇坐飞机:BAAAKgAECggICAAAAA==.',['苦练']='苦练维修工:BAAAKgAECgEIAQAAAA==.',['药不']='药不死:BAAAKgAECgYICwAAAA==.',['莉莉']='莉莉丝迷迭香:BAAAKgAECgQIBgAAAA==.莉莉灬尛果冻:BAAAKgAFFAQIBAAAAA==.',['莪吥']='莪吥嗳伱:BAABKgAFFH8SAAMHAAUI6BwABQBBAQAHAAUIHhgABQBBAQAIAAQIiCLECgAUAQABKgAFFAgICAAPAC8jAA==.',['菜菜']='菜菜衤:BAAAKgAECggIDgAAAA==.',['萌萌']='萌萌二次元:BAABKgAFFH8LAAMHAAYI3BoOCgBzAQAHAAYIpRcOCgBzAQAIAAUIcxHLHQAwAQAAAA==.',['萍野']='萍野:BAAAKgAECggIDwABKgAFFAgIMAAaAE0gAA==.',['萧瑟']='萧瑟弑光:BAACKgAFFH8LAAIVAAMI4hrrKwDKAAAVAAMI4hrrKwDKAAAqAAQKfxUAAhUACAiEIWYbAGACABUACAiEIWYbAGACAAEqAAUUBggMAAEAbgwA.',['萨满']='萨满吖:BAAAKgAECgcIBwAAAA==.萨满宝宝丶:BAAAKgAECgcICwAAAA==.',['落单']='落单:BAAAKgADCgEIAQAAAA==.',['落叶']='落叶叹秋冷:BAAAKgAECggIDwAAAA==.',['落幕']='落幕灬夕阳:BAAAKgAECggICAAAAA==.',['落羽']='落羽丶:BAAAKgAECgQIBAAAAA==.',['葡萄']='葡萄不淘:BAAAKgAECgQIBAAAAA==.',['蒸汽']='蒸汽朋克:BAAAKgADCggIEAAAAA==.',['蓝烟']='蓝烟灰:BAABKgAFFH8UAAMEAAYIlhjZBwBFAQAeAAYIPhOtEABkAQAEAAYIQxXZBwBFAQAAAA==.',['虾不']='虾不来虫:BAAAKgAECggIDAAAAA==.',['衣丢']='衣丢丢:BAAAKgADCgIIAgAAAA==.',['裁决']='裁决之杖:BAAAKgAECgIIAgAAAA==.',['裂人']='裂人:BAAAKgAECgMIAwAAAA==.',['親愛']='親愛德:BAAAKgAECgMICQAAAA==.',['詹尼']='詹尼佛丶傲风:BAAAKgADCggICAAAAA==.',['许瀛']='许瀛龙:BAAAKgAECgMIAwAAAA==.',['请轻']='请轻吻我的手:BAAAKgADCggIDgAAAA==.',['豆豆']='豆豆:BAAAKgAECgUICQAAAA==.',['豌豆']='豌豆颠颠:BAAAKgAECgYIBwAAAA==.',['赫丽']='赫丽贝尔丶:BAAAKgAECgYIBgAAAA==.',['赵琛']='赵琛的父亲:BAAAKgAECgQIBAAAAA==.',['超越']='超越战神:BAAAKgAFFAYIBAAAAA==.',['躺倒']='躺倒之龙:BAAAKgADCggICAAAAA==.',['軍团']='軍团总指挥:BAAAKgAFFAIIAgAAAA==.',['软妹']='软妹终结者:BAAAKgADCggICgAAAA==.',['软软']='软软的你:BAAAKgAECggICQAAAA==.',['辰风']='辰风去:BAAAKgAFFAcIAwAAAA==.',['达芬']='达芬奇画鸡蛋:BAAAKgADCggIEAAAAA==.',['达魔']='达魔瘋:BAAAKgAECgMIAwAAAA==.',['迅捷']='迅捷德:BAAAKgAFFAEIAQAAAA==.',['迎春']='迎春花儿开:BAAAKgAFFAcIAwAAAA==.迎春花儿笑:BAAAKgAECggICAAAAA==.',['迪亚']='迪亚贝尔斯塔:BAABKgAFFH8IAAQLAAQIhSCbDAD8AAALAAMIhSCbDAD8AAAGAAEIxgqKJAA8AAAZAAEIAAAiIwAAAAAAAA==.',['逆天']='逆天而行:BAAAKgAECgYICQAAAA==.',['逍遥']='逍遥丨选:BAAAKgADCggICAAAAA==.',['遇術']='遇術丨临瘋:BAAAKgADCgYIBgAAAA==.',['邦桑']='邦桑迪丷獸兮:BAAAKgAECgYIBgAAAA==.',['邪恶']='邪恶草莓熊:BAAAKgAECgEIAQAAAA==.',['部落']='部落一支花:BAAAKgAFFAEIAQAAAA==.',['醉之']='醉之剑:BAAAKgAECgIIAgAAAA==.',['醉渔']='醉渔唱晚:BAAAKgAECgQIBAAAAA==.',['野德']='野德新之助:BAAAKgAECgUICQAAAA==.',['铯铯']='铯铯一一:BAAAKgADCgQIBAAAAA==.',['镇海']='镇海一支開:BAABKgAFFH8IAAICAAgIqgGyFgD3AAACAAgIqgGyFgD3AAAAAA==.',['阳光']='阳光彩虹小马:BAAAKgAECgYICwAAAA==.',['阿尓']='阿尓萨斯:BAABKgAFFH8GAAIPAAYI9AO+PwDyAAAPAAYI9AO+PwDyAAAAAA==.',['阿尔']='阿尔媞妮斯:BAAAKgAECgMIAwAAAA==.',['阿巴']='阿巴贡丶黑硬:BAAAKgAECgEIAQAAAA==.',['阿斯']='阿斯达克斯:BAAAKgAECgcICQAAAA==.',['阿牛']='阿牛的山:BAAAKgAFFAgIBAAAAA==.',['阿西']='阿西罢:BAABKgAFFH8GAAIbAAYIVAvMAgCUAQAbAAYIVAvMAgCUAQAAAA==.',['陈皮']='陈皮糖:BAAAKgAECgEIAQAAAA==.',['降龍']='降龍伏虎掐:BAAAKgADCggICAAAAA==.',['除夕']='除夕丶:BAAAKgADCgEIAQAAAA==.',['陸七']='陸七七:BAAAKgADCggICAAAAA==.',['隨風']='隨風潛入夜:BAAAKgADCggICAAAAA==.',['雄鹰']='雄鹰一样男人:BAACKgAFFH8MAAMBAAYIbgycEQCoAAABAAQIRwacEQCoAAACAAYIKxkBKQCQAAAqAAQKfysAAwIACAhYII0uAAMCAAIACAhYII0uAAMCAAEABQiaEKs5AAIBAAAA.',['雨雪']='雨雪纷飞:BAAAKgAFFAIIAgAAAA==.',['雪中']='雪中君:BAAAKgAECgUIBQAAAA==.',['雪月']='雪月枫:BAABKgAECn8YAAIPAAgIYCLMSADmAQAPAAgIYCLMSADmAQAAAA==.',['雪雨']='雪雨纷飞:BAAAKgAECggIEQAAAA==.',['雷霆']='雷霆苍穹:BAABKgAECn9BAAMWAAgIDyJ3BgBTAgAWAAcIJiJ3BgBTAgASAAgIMxpUMwC5AQAAAA==.',['霸气']='霸气彳亍:BAAAKgAECgcICAAAAA==.霸气菊花残:BAAAKgADCggIEAAAAA==.',['風之']='風之铃音:BAAAKgAECgcIEgAAAA==.',['風铃']='風铃摇曳:BAAAKgAECgYIBwAAAA==.',['风月']='风月恋:BAAAKgAFFAEIAQAAAA==.',['风骚']='风骚沉鱼落雁:BAAAKgADCggIDwAAAA==.',['飘逸']='飘逸浩浩:BAAAKgAFFAgIAgAAAA==.',['飞竜']='飞竜丶在天:BAAAKgADCgMIAwAAAA==.',['首席']='首席老中医:BAAAKgAECggIEAAAAA==.',['驼爷']='驼爷:BAAAKgADCgEIAQAAAA==.',['骤夜']='骤夜:BAAAKgAECgYIBgAAAA==.',['骨头']='骨头是啊固:BAABKgAECn8cAAMDAAgIGx61LwChAQADAAgIbRq1LwChAQAJAAYIoB1IGwCgAQAAAA==.',['高垣']='高垣枫:BAABKgAFFH8XAAIVAAgIkhPMDAC3AQAVAAgIkhPMDAC3AQAAAA==.',['高登']='高登:BAAAKgADCgEIAQAAAA==.',['鬼王']='鬼王达:BAACKgAFFH8IAAIVAAMIehaQKgDNAAAVAAMIehaQKgDNAAAqAAQKfxkAAhUACAh9HfojAC0CABUACAh9HfojAC0CAAAA.',['魂灵']='魂灵风息:BAAAKgAECgUIBQAAAA==.',['魔界']='魔界小风:BAAAKgAECgYIBgAAAA==.',['魔预']='魔预者奶咕咕:BAAAKgAECgUIBwAAAA==.',['鷺沢']='鷺沢文香:BAAAKgAECgUIBgAAAA==.',['鹿鼎']='鹿鼎记丨阿珂:BAAAKgAECggIDgAAAA==.',['麻辣']='麻辣小鲜肉:BAAAKgADCggICAAAAA==.',['黄鱼']='黄鱼饺子:BAAAKgADCggICgAAAA==.',['黑暗']='黑暗的世界:BAAAKgADCgIIAgAAAA==.',['黑橘']='黑橘子好吃:BAABKgAFFH8GAAIRAAYINwzDEAA+AQARAAYINwzDEAA+AQAAAA==.',['黑皇']='黑皇哈特:BAAAKgAFFAQIBAAAAA==.',['鼓捣']='鼓捣猫呢:BAABKgAFFH8IAAISAAgILAguCQB7AQASAAgILAguCQB7AQAAAA==.',['龌龊']='龌龊的世界:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end