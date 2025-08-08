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
 local lookup = {'Druid-Balance','Priest-Discipline','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Priest-Holy','Priest-Shadow','Paladin-Retribution','Mage-Frost','Mage-Arcane','Warrior-Protection','DemonHunter-Vengeance','DemonHunter-Havoc','Mage-Fire','Hunter-Marksmanship','Druid-Guardian','Druid-Restoration','Paladin-Protection','DeathKnight-Blood','Hunter-BeastMastery','Warrior-Arms','Warrior-Fury','Shaman-Enhancement','Druid-Feral','Monk-Mistweaver','Monk-Windwalker','Evoker-Preservation','Evoker-Devastation','Monk-Brewmaster','DeathKnight-Frost','DeathKnight-Unholy','Shaman-Restoration',}; local provider = {region='CN',realm='刀塔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aw='Away:BAABKgAFFH8GAAIBAAYIPwWmJACVAAABAAYIPwWmJACVAAAAAA==.',Bo='Bose:BAAAKgAECgUIBQAAAA==.Botdly:BAAAKgAECgEIAQAAAA==.',Fe='Felix:BAAAKgAECgIIAgAAAA==.',Fo='Fortytwoqs:BAAAKgAFFAgIAwAAAA==.',Gu='Guldann:BAAAKgAECgYIDgAAAA==.Gusta:BAAAKgAECgcIEAAAAA==.',He='Hellmedivh:BAAAKgAECgMIAwAAAA==.',Mo='Moirathausan:BAAAKgAECgQIBAAAAA==.',Mu='Muran:BAAAKgAFFAQIBAAAAA==.Muranyuu:BAAAKgAFFAQIBAAAAA==.',Pe='Penguin:BAABKgAFFH8IAAICAAgI0RrdAQA+AgACAAgI0RrdAQA+AgAAAA==.',Se='Semmelweis:BAABKgAECn8fAAQDAAgIXxJyTAA2AQADAAcIPxFyTAA2AQAEAAMI1Q7vLQCZAAAFAAMI8QsrYgBxAAAAAA==.',Sm='Smilence:BAAAKgAECgYIBgAAAA==.',Su='Suga:BAACKgAFFH8FAAIGAAMI6CC/CwAPAQAGAAMI6CC/CwAPAQAqAAQKfzcABAYACAghJRYGALUCAAYACAghJRYGALUCAAcABAhUD/ZYAIgAAAIAAggOHs4qAEgAAAAA.',Th='Thislove:BAABKgAFFH8GAAIIAAYIWAfBLAA0AQAIAAYIWAfBLAA0AQAAAA==.',Ti='Tii:BAAAKgADCgYIBgAAAA==.',Vu='Vurtnes:BAAAKgAECgQIBAAAAA==.',Wh='Whisperer:BAABKgAECn8XAAMJAAgIUhJVJwB9AQAJAAgIUhJVJwB9AQAKAAYIFwb1dgB+AAAAAA==.',Zh='Zhendemeiyis:BAABKgAECn8cAAMJAAgIih52FgBMAgAJAAgIih52FgBMAgAKAAEIWBlnkABEAAAAAA==.',Zz='Zzd:BAAAKgADCgMIAwAAAA==.',['万剑']='万剑齐飞:BAAAKgADCgEIAQAAAA==.',['上帝']='上帝之骰:BAAAKgADCggICAAAAA==.',['不知']='不知纪英俊丶:BAABKgAFFH8IAAILAAgIRAnVAwBmAQALAAgIRAnVAwBmAQAAAA==.',['中庸']='中庸猫:BAAAKgAECgQIBAAAAA==.',['丰川']='丰川祥子:BAABKgAECn8qAAMMAAgIZRp/FAD0AQAMAAgIsRh/FAD0AQANAAcIwRaXQwCaAQAAAA==.',['丶猫']='丶猫祭:BAAAKgAECgIIAwAAAA==.',['云天']='云天明:BAABKgAFFH8IAAMKAAgIsRfMFAA+AQAKAAQI6xvMFAA+AQAOAAQIDhK4HADgAAAAAA==.',['云缥']='云缥缈:BAABKgAFFH8GAAIDAAYIPAo4HQAdAQADAAYIPAo4HQAdAQAAAA==.',['云门']='云门过何山:BAAAKgAECggIBQAAAA==.',['亚细']='亚细亚:BAAAKgAFFAcIAwAAAA==.',['伽罗']='伽罗皇后:BAABKgAFFH8GAAIPAAYI6RrTDgBzAQAPAAYI6RrTDgBzAQAAAA==.',['俠鵺']='俠鵺:BAAAKgAECggICQAAAA==.',['傲雪']='傲雪:BAAAKgAECggIDwAAAA==.',['六六']='六六大:BAAAKgAFFAUIAwAAAA==.',['凉栀']='凉栀丶丶:BAABKgAECn8cAAINAAgIVRbrXQAuAQANAAgIVRbrXQAuAQAAAA==.',['凯文']='凯文兄丶:BAABKgAFFH8LAAIIAAgI5xVICAArAgAIAAgI5xVICAArAgAAAA==.',['加二']='加二卤食:BAAAKgAFFAEIAQAAAA==.',['加藤']='加藤蝇:BAAAKgAECgYIDgAAAA==.',['匠作']='匠作:BAAAKgAECgQIBAAAAA==.',['十四']='十四是奶骑:BAABKgAFFH8IAAIIAAYImhhDAgDCAQAIAAYImhhDAgDCAQAAAA==.',['半截']='半截诗人:BAAAKgADCgEIAQAAAA==.',['卖糖']='卖糖果的:BAAAKgAECggIDAAAAA==.',['卧虎']='卧虎乄藏龙:BAAAKgAFFAQIBAAAAA==.',['古尔']='古尔单:BAAAKgAECggICAAAAA==.',['叫我']='叫我大强:BAAAKgAECggIEwAAAA==.',['可日']='可日可乐:BAAAKgAECgQIBQAAAA==.',['可爱']='可爱奶不来:BAAAKgAECggIEwAAAA==.可爱贼厉害:BAABKgAECn8WAAIIAAgI+x+9OAAdAgAIAAgI+x+9OAAdAgAAAA==.',['吉普']='吉普赛:BAAAKgADCgYIBgAAAA==.',['呱呱']='呱呱到处找:BAAAKgADCgEIAQAAAA==.',['喵丶']='喵丶:BAAAKgAECgUIBQAAAA==.',['喵了']='喵了戈咪:BAAAKgAFFAMIAwAAAA==.',['嗜血']='嗜血杀戮:BAAAKgADCggICAAAAA==.',['回雪']='回雪:BAAAKgAFFAIIAgAAAA==.',['圣光']='圣光丿皮卡丘:BAAAKgAECggIDgAAAA==.',['圣獠']='圣獠原:BAAAKgAECgYICAAAAA==.',['夏利']='夏利巴黎春雪:BAACKgAFFH8nAAMQAAUIXhLMAgCgAAAQAAUIXhLMAgCgAAABAAMISQOzJwCAAAAqAAQKfy0ABBAACAhOIDgGADECABAACAhOIDgGADECABEABQgsDLBaAKYAAAEABAi1BbfGAEgAAAAA.',['夏血']='夏血:BAAAKgAECgMIAwAAAA==.',['夜落']='夜落黄昏时:BAAAKgAECgQICAAAAA==.',['大豪']='大豪:BAAAKgADCgMIAwAAAA==.',['大锤']='大锤儿丶:BAABKgAFFH8GAAINAAYIjQ75FgBDAQANAAYIjQ75FgBDAQAAAA==.',['天之']='天之剑神:BAACKgAFFH8bAAILAAQIywXfEAB2AAALAAQIywXfEAB2AAAqAAQKfxkAAgsACAjXCR4rANYAAAsACAjXCR4rANYAAAAA.',['奶快']='奶快救我:BAABKgAFFH8KAAIIAAYIaxPEFAAFAQAIAAYIaxPEFAAFAQAAAA==.',['奶牛']='奶牛刺身:BAABKgAFFH8JAAMBAAMI1ACnMAA8AAABAAMI1ACnMAA8AAARAAIIwwGoOQAyAAAAAA==.',['奶舞']='奶舞影:BAAAKgAECgcIBwAAAA==.',['宫乄']='宫乄城:BAAAKgAFFAgIBAAAAA==.',['寄风']='寄风尘:BAAAKgAECgEIAQAAAA==.',['小勇']='小勇士:BAAAKgAECgMIAwAAAA==.',['小坏']='小坏爱小痒:BAAAKgAECgMIAwAAAA==.',['小欢']='小欢喜:BAAAKgADCggICAAAAA==.',['小青']='小青年:BAAAKgAECgEIAQAAAA==.',['小黑']='小黑黑:BAAAKgAECggICAAAAA==.',['山舆']='山舆海:BAAAKgADCgUIBQAAAA==.',['巩俐']='巩俐:BAAAKgAECgEIAQAAAA==.',['布莱']='布莱恩铜须丶:BAAAKgAECgYIBgAAAA==.',['幽灵']='幽灵骑士:BAABKgAFFH8IAAINAAQIvhkTEAAAAQANAAQIvhkTEAAAAQAAAA==.',['张哇']='张哇哇:BAABKgAFFH8IAAIJAAgItB9oAADOAgAJAAgItB9oAADOAgAAAA==.',['强尼']='强尼马托斯:BAAAKgADCgIIAgAAAA==.',['往北']='往北乄向南:BAAAKgAFFAQIBAAAAA==.',['徐脂']='徐脂虎:BAAAKgAECgEIAQAAAA==.',['德莫']='德莫霍的:BAAAKgAECgUIBQAAAA==.',['心灵']='心灵不震撼:BAABKgAFFH8KAAMSAAgIiSRIBQDoAQASAAYItCNIBQDoAQAIAAQIlCXLEgDGAQAAAA==.',['恩赐']='恩赐解脱:BAAAKgADCggICAAAAA==.',['成龙']='成龙:BAAAKgADCgEIAQAAAA==.',['我有']='我有两个密秘:BAAAKgAECggICAAAAA==.',['我爱']='我爱木贞吧:BAABKgAFFH8IAAIIAAgICw4JDwDqAQAIAAgICw4JDwDqAQAAAA==.',['找我']='找我有事吗:BAAAKgAECgEIAQAAAA==.',['无惦']='无惦念:BAAAKgADCggICAAAAA==.',['无所']='无所畏惧之人:BAAAKgADCgYIBgAAAA==.',['日居']='日居月诸灵土:BAAAKgADCgIIAwAAAA==.',['旺德']='旺德发:BAAAKgAECgYIBgAAAA==.',['明日']='明日香:BAAAKgAECgMIAwAAAA==.',['春天']='春天的跳动:BAAAKgAECgEIAQAAAA==.',['暗咩']='暗咩:BAAAKgAECgQIBAAAAA==.',['曼达']='曼达洛:BAAAKgAECgYIBgAAAA==.',['月亮']='月亮睡不睡:BAAAKgAFFAYIAgAAAA==.',['有个']='有个拽杰:BAAAKgAFFAIIAgAAAA==.',['李佑']='李佑霖:BAAAKgAECgYIBgAAAA==.',['极巨']='极巨水流:BAABKgAFFH8GAAIBAAYIFg5HGwBAAQABAAYIFg5HGwBAAQAAAA==.',['枫叶']='枫叶:BAAAKgAECgYICQAAAA==.',['柠檬']='柠檬味汽水:BAABKgAFFH8MAAINAAgI/g+CCQD3AQANAAgI/g+CCQD3AQAAAA==.',['椛开']='椛开丶:BAABKgAFFH8QAAITAAYInxo7CQCCAQATAAYInxo7CQCCAQAAAA==.',['橘白']='橘白:BAAAKgADCgIIAgAAAA==.',['江湖']='江湖猪肉郎:BAAAKgAECgUIBQAAAA==.',['污涩']='污涩儿:BAAAKgADCgMIAwAAAA==.',['沐沂']='沐沂:BAAAKgAECgEIAQAAAA==.',['浪荡']='浪荡公子哥:BAAAKgAECgIIBAAAAA==.浪荡公子爷:BAAAKgAECggIEQAAAA==.浪荡小公主:BAAAKgAECgYIBgAAAA==.浪荡小国宝:BAAAKgAECgUIBgAAAA==.浪荡小野兽:BAABKgAFFH8GAAIUAAYI5hixDgCJAQAUAAYI5hixDgCJAQAAAA==.浪荡未亡人:BAAAKgAECgIIAgAAAA==.',['海蒂']='海蒂:BAAAKgAECgIIAgAAAA==.',['海鸥']='海鸥魂:BAACKgAFFH8ZAAIVAAMIvCNuDQA5AQAVAAMIvCNuDQA5AQAqAAQKfyIAAxUACAgyIwIGALICABUACAgyIwIGALICABYAAQgAAHuIAAAAAAAA.',['渣男']='渣男偷心贼:BAAAKgAECggICAAAAA==.渣男大狼狗:BAAAKgAECgYIBgAAAA==.',['滋滋']='滋滋小土豆:BAABKgAFFH8IAAIXAAgIHxFBBAD9AQAXAAgIHxFBBAD9AQAAAA==.',['满穗']='满穗良仁:BAAAKgAECgIIAgAAAA==.',['火箭']='火箭龟:BAACKgAFFH8jAAMYAAQIcyV6AQAfAQAYAAMIcyV6AQAfAQABAAEIAADZZgAAAAAqAAQKfyUAAhgACAiJJfACALkCABgACAiJJfACALkCAAAA.',['灰灰']='灰灰:BAAAKgADCgYIBgAAAA==.',['炭烤']='炭烤小青龙:BAAAKgAECgYIBgAAAA==.',['炽魂']='炽魂魔导莉娜:BAAAKgADCgIIAgAAAA==.',['爱吃']='爱吃米饭:BAACKgAFFH8JAAIZAAgITQz1BgCXAQAZAAgITQz1BgCXAQAqAAQKfx8AAxkACAiYIlgCAKgCABkACAiYIlgCAKgCABoABAhkFQVEAPgAAAAA.',['爱喝']='爱喝啤酒:BAAAKgADCgMIAwAAAA==.',['爱如']='爱如烟忆流年:BAAAKgADCgYIBgAAAA==.',['狂干']='狂干瘸子好腿:BAAAKgADCgMIAwAAAA==.',['猛干']='猛干瘸子好腿:BAABKgAECn8eAAIDAAgI8w9zRABXAQADAAgI8w9zRABXAQAAAA==.',['理塘']='理塘猎码人:BAAAKgAFFAIIAgAAAA==.',['瑾年']='瑾年丨苍瞳:BAACKgAFFH8GAAIIAAYIKxRRIgBjAQAIAAYIKxRRIgBjAQAqAAQKfxcAAggACAjdI5JOAAcCAAgACAjdI5JOAAcCAAAA.',['生如']='生如芥子:BAAAKgAECgQIBAAAAA==.',['田曦']='田曦薇:BAABKgAFFH8SAAMbAAYIMCJ3AAB7AQAbAAUIzCF3AAB7AQAcAAYIhBioEQBKAQAAAA==.',['百变']='百变弓:BAAAKgAECgIIAgAAAA==.',['瞎玩']='瞎玩:BAAAKgAFFAEIAQAAAA==.',['神父']='神父:BAABKgAFFH8GAAIIAAYIsgk8LwArAQAIAAYIsgk8LwArAQAAAA==.',['秋风']='秋风洁雪:BAABKgAFFH8QAAIKAAgI2BK4BwABAgAKAAgI2BK4BwABAgAAAA==.',['紫霞']='紫霞小魔仙:BAAAKgAECggICwAAAA==.',['绿色']='绿色职业:BAABKgAFFH8IAAIPAAgIbwe2CwCbAQAPAAgIbwe2CwCbAQAAAA==.',['肥肚']='肥肚肚:BAABKgAFFH8IAAMUAAQIjQs5OgCyAAAUAAMIjQs5OgCyAAAPAAIISQPdKgApAAAAAA==.',['胖虎']='胖虎:BAACKgAFFH8TAAMLAAMIWw7fDgCJAAALAAMIWw7fDgCJAAAWAAIIdgO7MgBgAAAqAAQKfyQAAwsACAigFlAWAJIBAAsACAigFlAWAJIBABYABggOD+dMAC8BAAAA.',['胖达']='胖达:BAABKgAFFH8HAAISAAMIEQkpFQBYAAASAAMIEQkpFQBYAAAAAA==.',['至尊']='至尊奶妈:BAAAKgAFFAEIAQAAAA==.',['色鹤']='色鹤:BAAAKgAECggICAAAAA==.',['莱锅']='莱锅:BAACKgAFFH8JAAMVAAYIORc8FwBXAAAWAAUIHRtWJQBdAAAVAAEIrAc8FwBXAAAqAAQKfxgAAhYABwiuHzIqAOEBABYABwiuHzIqAOEBAAAA.',['蒼潼']='蒼潼:BAABKgAFFH8GAAIdAAYIUQjfAQANAQAdAAYIUQjfAQANAQABKgAFFAgIEwABAHMfAA==.',['蓝卿']='蓝卿:BAAAKgADCggIDAAAAA==.',['裂魂']='裂魂灬云殇:BAAAKgADCggICAAAAA==.',['调查']='调查员:BAAAKgADCgEIAQAAAA==.',['谜团']='谜团:BAACKgAFFH8OAAMeAAgI9xQKAgDhAQAeAAgISQsKAgDhAQATAAQIaCIEBgAxAQAqAAQKfxQAAx8ACAiYJhMCAA0DAB8ACAiYJhMCAA0DABMACAiKGecYANEBAAAA.',['谭雅']='谭雅丶:BAABKgAFFH8WAAMWAAQI0B6/DAAIAQAWAAQI0B6/DAAIAQAVAAEIkw6WGQBMAAAAAA==.',['贱谍']='贱谍大师裹网:BAABKgAFFH8GAAMgAAYIWxAYFgDNAAAgAAQIKxAYFgDNAAAXAAIIwg1HDwCzAAAAAA==.',['赫蘿']='赫蘿:BAABKgAFFH8IAAIRAAgIjw6EBAC4AQARAAgIjw6EBAC4AQAAAA==.',['超龄']='超龄老木:BAAAKgADCgEIAQAAAA==.',['跟我']='跟我一起来:BAAAKgAECgMIBAAAAA==.',['达拉']='达拉斯牛仔:BAAAKgAFFAMIAwAAAA==.',['逐风']='逐风游侠:BAAAKgAFFAgIBAAAAA==.',['酒醉']='酒醉包:BAAAKgAECgYIBgAAAA==.',['铁西']='铁西五虎龙少:BAAAKgAECgUIBgAAAA==.',['长高']='长高了一斤:BAAAKgADCggICAAAAA==.',['閉月']='閉月:BAABKgAFFH8LAAIPAAMInRKELwCwAAAPAAMInRKELwCwAAAAAA==.',['闻言']='闻言:BAAAKgAECgcICQAAAA==.',['随便']='随便奥奥:BAAAKgAECgQIBAAAAA==.随便死死:BAAAKgAECggIEQAAAA==.',['青山']='青山丶僧:BAACKgAFFH8HAAIZAAYIlBeZCACmAQAZAAYIlBeZCACmAQAqAAQKfyIAAhkACAjeGjYcAAkCABkACAjeGjYcAAkCAAAA.青山丶牧:BAAAKgAFFAQIBAAAAA==.青山原不老:BAABKgAFFH8GAAIgAAQI4RtPIgDvAAAgAAQI4RtPIgDvAAAAAA==.',['风车']='风车车:BAAAKgAFFAYIAgAAAA==.',['香泥']='香泥乐堡杯:BAAAKgAECgEIAQAAAA==.',['香蕉']='香蕉奶皮:BAAAKgAFFAIIAgAAAA==.香蕉麻瓜:BAABKgAFFH8GAAIeAAYI7Rb7AgCTAQAeAAYI7Rb7AgCTAQAAAA==.',['驰名']='驰名商标:BAAAKgADCgEIAQAAAA==.',['骑德']='骑德龙丿咚墙:BAACKgAFFH8JAAIcAAQI8g7cFQC6AAAcAAQI8g7cFQC6AAAqAAQKfxwAAhwACAizHjgFAG0CABwACAizHjgFAG0CAAEqAAUUCAgQAAIALRIA.',['鬼鬼']='鬼鬼的鬼:BAAAKgADCggICAAAAA==.',['魏期']='魏期有病毒:BAAAKgAECgcIBwAAAA==.',['鲨鲨']='鲨鲨遍地跑:BAAAKgADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end