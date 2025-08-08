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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Unholy','Paladin-Retribution','DemonHunter-Havoc','DemonHunter-Vengeance','Unknown-Unknown','DeathKnight-Blood','Warlock-Destruction','Warlock-Demonology','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Mage-Frost','Warrior-Fury','Warrior-Protection','Warlock-Affliction','Monk-Brewmaster','Monk-Windwalker','Hunter-Survival','Paladin-Protection','Druid-Guardian','Druid-Feral','Druid-Restoration','Rogue-Assassination','Priest-Shadow','Priest-Holy','Priest-Discipline','Rogue-Subtlety','Warrior-Arms','Druid-Balance','Monk-Mistweaver',}; local provider = {region='CN',realm='纳沙塔尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ba='Balles:BAAAKgAFFAQIBAAAAA==.',Bi='Bibo:BAAAKgADCggICAAAAA==.',Ca='Calm:BAAAKgADCgUIBQAAAA==.',Ch='Chiron:BAACKgAFFH8GAAIBAAII6Q9dGwCQAAABAAII6Q9dGwCQAAAqAAQKfxwAAwEACAhlGz0VACcCAAEACAhlGz0VACcCAAIAAgjNByH0AEwAAAAA.',Cr='Crazyyk:BAAAKgADCgEIAQAAAA==.',Ir='Ireliia:BAAAKgAFFAcIBAABKgAFFAgIFgADAGsZAA==.',Iv='Ivy:BAAAKgAECgYIBgAAAA==.',Ki='Kiki:BAAAKgADCgcIBwAAAA==.',Na='Nausicaa:BAABKgAECn8UAAIEAAcIzCOSJgBmAgAEAAcIzCOSJgBmAgAAAA==.',Ni='Nissen:BAAAKgAECgIIAgAAAA==.',Pl='Playerccgboe:BAAAKgADCgEIAQAAAA==.',Po='Poka:BAAAKgAECgYIBgAAAA==.',Re='Recovery:BAAAKgAECgcIDQAAAA==.',Ru='Ruico:BAAAKgAECgYIBgAAAA==.',Sa='Sayuki:BAAAKgAECggICAAAAA==.',St='Starplatinu:BAAAKgAECggIEAAAAA==.',Su='Supersaiyant:BAAAKgAFFAMIAwAAAA==.',Ts='Tsukuba:BAAAKgAFFAYIAgAAAA==.',Yi='Yigedh:BAACKgAFFH8NAAIFAAQI5iJrFQBPAQAFAAQI5iJrFQBPAQAqAAQKfxgAAwUACAhrIpIUAIsCAAUACAg8IJIUAIsCAAYAAQixIudZAGMAAAEqAAUUCAgEAAcAAAAA.',['一回']='一回头吓死牛:BAAAKgAECgUIBQAAAA==.',['一锤']='一锤定音:BAABKgAFFH8GAAIEAAYIoQdyGgASAQAEAAYIoQdyGgASAQAAAA==.',['一队']='一队的萨满:BAAAKgADCggIDwAAAA==.',['三魂']='三魂之玉:BAAAKgAECgUIBgAAAA==.',['丨湮']='丨湮滅浪魂丨:BAAAKgAECgUIBQAAAA==.',['二丫']='二丫儿:BAAAKgADCgMIAwAAAA==.',['二蛋']='二蛋夫人:BAABKgAFFH8KAAIIAAYIlw/EEwADAQAIAAYIlw/EEwADAQABKgAFFAgIIAAIAFUQAA==.',['五官']='五官比三观正:BAAAKgAECgQIBAAAAA==.',['伊德']='伊德海拉:BAABKgAFFH8IAAMJAAYIHQ6yJADjAAAJAAUIOw2yJADjAAAKAAEIoxF2KABIAAAAAA==.',['佩锦']='佩锦丶儿:BAAAKgAECgYIBgAAAA==.',['依文']='依文:BAACKgAFFH8GAAIIAAIIfQ1KIQBVAAAIAAIIfQ1KIQBVAAAqAAQKfx0AAggACAjWGu8SABMCAAgACAjWGu8SABMCAAAA.',['信仰']='信仰符文:BAAAKgADCgUIBQAAAA==.',['倦鸟']='倦鸟余花:BAAAKgAFFAIIAgAAAA==.',['偃月']='偃月:BAAAKgADCgQIBAAAAA==.',['偷塑']='偷塑料贼:BAACKgAFFH9FAAQLAAgItSMTAgDAAgALAAgItSMTAgDAAgAMAAMI2R8KAQARAQANAAEIBCPkCABqAAAqAAQKfykAAgsACAi4JIQJAJcCAAsACAi4JIQJAJcCAAAA.',['冰之']='冰之幽森:BAAAKgADCgUIBQAAAA==.',['冰封']='冰封牛:BAAAKgAECggIBAAAAA==.',['冰火']='冰火莱莱:BAAAKgAECgQIBAAAAA==.冰火齐发:BAABKgAECn8eAAIOAAgI2A3cQADsAAAOAAgI2A3cQADsAAAAAA==.',['冻感']='冻感钞人:BAAAKgAECggIBgAAAA==.',['凡事']='凡事:BAAAKgAFFAMIAwAAAA==.',['劍多']='劍多食广:BAAAKgADCggICAAAAA==.',['勇者']='勇者无畏:BAABKgAECn8bAAMPAAgIZAqmSADyAAAPAAcIAgumSADyAAAQAAIIyQVOIgA5AAAAAA==.',['北斗']='北斗圣启:BAAAKgAECgcICAAAAA==.北斗翳恴:BAAAKgAFFAEIAQAAAA==.',['十月']='十月星尘:BAAAKgAECgYICgAAAA==.',['升卿']='升卿玉:BAAAKgAECgIIAgAAAA==.',['半拉']='半拉柯基:BAACKgAFFH8vAAMFAAgIeRtABgBBAgAFAAgIeRtABgBBAgAGAAQI1xC7CwClAAAqAAQKf0AAAwUACAiVIwoMAKgCAAUACAiVIwoMAKgCAAYACAhrGwEeAIkBAAAA.',['南方']='南方小细妹:BAAAKgAECgQIBQAAAA==.',['卡琳']='卡琳:BAACKgAFFH8GAAMBAAIISAyZKgA6AAABAAEIQguZKgA6AAACAAEITg0PXwA4AAAqAAQKfx0AAwIACAjsHLQ3ABYCAAIACAh5G7Q3ABYCAAEABwhyFocpAJgBAAAA.',['卡破']='卡破玩:BAAAKgAECgQIBQAAAA==.',['古浪']='古浪县首富:BAAAKgAECgYIEAAAAA==.',['周米']='周米粒:BAAAKgAECggICAAAAA==.',['呼吸']='呼吸的痛:BAAAKgAECgYIDAAAAA==.',['咆哮']='咆哮之威:BAAAKgAECgcICwAAAA==.',['四枫']='四枫院夜一:BAACKgAFFH8QAAMJAAgIgBgMDgCtAQAJAAgIgBgMDgCtAQARAAEIlgZRIAA/AAAqAAQKfyUABAkACAjVHosYADACAAkACAiGHIsYADACABEABgiEHmUSAGMBAAoAAwiKGPpXAI8AAAAA.',['圣光']='圣光在上:BAAAKgAECgEIAQAAAA==.圣光忽悠着我:BAAAKgAECgQIBAAAAA==.圣光抚慰着你:BAAAKgADCggIDQAAAA==.',['堕天']='堕天使路西法:BAABKgAFFH8HAAIPAAYIYhTxDgBmAQAPAAYIYhTxDgBmAQAAAA==.',['大个']='大个:BAAAKgADCgQIBAAAAA==.',['大熊']='大熊猫:BAABKgAECn8aAAMSAAgIYQeZFgDBAAASAAgIYQeZFgDBAAATAAIIEwU/YgA7AAAAAA==.',['天水']='天水麒麟儿:BAAAKgADCgMIAwAAAA==.',['太极']='太极丶张三疯:BAAAKgAECgcIBQAAAA==.',['女尤']='女尤丶仓老师:BAAAKgAECggICAAAAA==.',['奶不']='奶不起来:BAAAKgAECgUIBQAAAA==.',['好脾']='好脾氣:BAABKgAFFH8MAAIBAAQIvB2rHAALAQABAAQIvB2rHAALAQAAAA==.',['如影']='如影随形:BAAAKgADCgMIAwAAAA==.',['如玉']='如玉:BAAAKgAFFAQIBAAAAA==.',['妈宝']='妈宝小周周:BAABKgAFFH8FAAIUAAMI9xb2AAABAQAUAAMI9xb2AAABAQAAAA==.',['姜赦']='姜赦:BAAAKgAFFAQIBAAAAA==.',['娜哥']='娜哥:BAAAKgADCgEIAgAAAA==.',['子非']='子非雨:BAAAKgAECggICAAAAA==.',['宿命']='宿命枷锁德:BAAAKgAECgYIBwAAAA==.',['尉迟']='尉迟无锋:BAAAKgAFFAIIAgAAAA==.',['小小']='小小卡破:BAAAKgAECgMIAwAAAA==.',['小影']='小影子:BAAAKgAECgIIAgAAAA==.',['小楼']='小楼听风:BAAAKgAECgYIDQAAAA==.',['少年']='少年丶天生傲:BAAAKgADCgQIBAAAAA==.',['尛茉']='尛茉:BAAAKgADCgQIBAAAAA==.',['希里']='希里:BAABKgAFFH8IAAIFAAgIcR7MAwCdAgAFAAgIcR7MAwCdAgAAAA==.',['强军']='强军先锋:BAABKgAECn8xAAMEAAgIBhHQLgBeAQAEAAgIBhHQLgBeAQAVAAMICAYIIwAyAAAAAA==.',['影之']='影之鬼:BAAAKgAFFAgIAwAAAA==.',['德帅']='德帅:BAABKgAECn8aAAMWAAgIbBK+BwCGAQAWAAgIbBK+BwCGAQAXAAMIEAeBFABKAAAAAA==.',['德鲁']='德鲁医生:BAABKgAECn8XAAMXAAgIphDFDQDMAQAXAAgIphDFDQDMAQAYAAgIRRKYJgBwAQAAAA==.德鲁猫:BAABKgAFFH8IAAIXAAIIJxvLCACgAAAXAAIIJxvLCACgAAAAAA==.',['怨灵']='怨灵射手:BAAAKgAECgcIEQAAAA==.怨灵杀手:BAABKgAFFH8GAAIZAAYITxFTDwBcAQAZAAYITxFTDwBcAQAAAA==.怨灵骑士:BAAAKgAECggIDwAAAA==.怨灵骑矢:BAABKgAECn8WAAIEAAgIrhcDXgClAQAEAAgIrhcDXgClAQAAAA==.',['恶魔']='恶魔天涯:BAAAKgADCgMIAQAAAA==.',['情授']='情授:BAAAKgAFFAcIAQAAAA==.',['戈德']='戈德莉亚:BAABKgAFFH8HAAIEAAYIrxz9EQDNAQAEAAYIrxz9EQDNAQABKgAFFAgICgAEAK0lAA==.',['我是']='我是胖子丶:BAAAKgAFFAIIAgAAAA==.',['扛不']='扛不住怪:BAAAKgAECgUIBQAAAA==.',['插棍']='插棍子:BAAAKgAECgYIBgAAAA==.',['攻守']='攻守之道:BAAAKgAECgUIBQAAAA==.',['敖蕾']='敖蕾莉亚:BAABKgAECn8hAAMBAAcIEggyawC0AAABAAcIEggyawC0AAACAAQIugVqswBbAAAAAA==.',['无敌']='无敌小娟:BAAAKgAECggIDgAAAA==.',['暗之']='暗之魔鬼修罗:BAABKgAECn8nAAIPAAgINBIZPwB4AQAPAAgINBIZPwB4AQAAAA==.',['暗影']='暗影之龙:BAAAKgAECgUIBQAAAA==.暗影天使:BAABKgAECn8aAAQaAAgIZwuNSACOAAAaAAYI+QmNSACOAAAbAAQI8QdCaAB7AAAcAAUIHAbhYQByAAAAAA==.',['月丸']='月丸吨:BAABKgAFFH8OAAMBAAYIEyRaCADXAQABAAYIEyRaCADXAQACAAIIgxTZNQCMAAAAAA==.',['杀破']='杀破羊:BAACKgAFFH8GAAMdAAII5QXTDgBlAAAdAAII1wLTDgBlAAAZAAII5QVWFwBcAAAqAAQKfx0AAx0ACAjCEpkQAOIBAB0ACAieEpkQAOIBABkABAiFC1kvAOIAAAAA.',['柯基']='柯基丶:BAABKgAFFH8KAAMDAAYIsw4nMQDOAAADAAQIfBEnMQDOAAAIAAIIhgrrKQBuAAAAAA==.',['核天']='核天下:BAAAKgAECgYIBgAAAA==.',['毁灭']='毁灭莱莱:BAAAKgAECggICgAAAA==.',['渐渐']='渐渐遠去的心:BAABKgAFFH8PAAMBAAMIFh6/NwCXAAABAAIIiBy/NwCXAAACAAEIMiF1QgBVAAAAAA==.',['滚动']='滚动字幕:BAAAKgAFFAQIBAABKgAFFAgIEQABAPEhAA==.',['火拳']='火拳:BAABKgAFFH8IAAIFAAgIoxCuCAD9AQAFAAgIoxCuCAD9AQAAAA==.',['炎耀']='炎耀天:BAABKgAECn8oAAMQAAgI4gmPJgDOAAAeAAgIZgVpOgDSAAAQAAcITwqPJgDOAAAAAA==.',['炒股']='炒股打牌喝茶:BAABKgAECn8aAAMEAAgIwAI9DQGkAAAEAAcIjgI9DQGkAAAVAAEI6wPebAALAAAAAA==.',['狂野']='狂野莱莱:BAAAKgAFFAgIBAAAAA==.',['猎神']='猎神莱莱:BAABKgAFFH8IAAMCAAgI/RlQFABTAQACAAQICxtQFABTAQABAAQIlhjKIwDfAAAAAA==.',['猫貓']='猫貓拳:BAAAKgAFFAIIAgAAAA==.',['瑜摆']='瑜摆摆:BAAAKgADCggICAAAAA==.',['盆心']='盆心源:BAAAKgAFFAEIAQAAAA==.',['砍瓜']='砍瓜切菜:BAABKgAFFH8GAAIDAAYIygo3DABDAQADAAYIygo3DABDAQAAAA==.',['破卡']='破卡:BAAAKgAECgUIEQAAAA==.',['祈求']='祈求神灵之人:BAACKgAFFH8oAAIEAAgIgxtGDwDoAQAEAAgIgxtGDwDoAQAqAAQKfxsAAwQABwiwJIQlAGoCAAQABwiwJIQlAGoCABUAAQhgFg1XAEIAAAAA.',['神不']='神不知鬼不觉:BAABKgAECn8eAAMPAAgIDhmLIwC6AQAPAAgIMhaLIwC6AQAeAAYIPRTsMgAoAQAAAA==.',['神圣']='神圣符文:BAAAKgAECgcIDAAAAA==.神圣闪烁:BAAAKgAECgUIBQAAAA==.',['禅意']='禅意人生:BAAAKgADCggICQAAAA==.',['科斯']='科斯塔:BAABKgAFFH8KAAMfAAMIGBKDNgDEAAAfAAMIGBKDNgDEAAAXAAEINgQdCgA8AAAAAA==.',['稻田']='稻田阿尼亚:BAAAKgAECgEIAQAAAA==.',['箭多']='箭多食广:BAAAKgADCgQIBwAAAA==.',['繁华']='繁华落尽丶:BAAAKgAFFAIIAwAAAA==.',['織部']='織部猎:BAAAKgAECgQIBAAAAA==.',['纷濑']='纷濑绘里:BAABKgAFFH8LAAIFAAYIsxIrFADwAAAFAAYIsxIrFADwAAAAAA==.',['美好']='美好的回忆:BAAAKgAECgQIBAAAAA==.',['羽泺']='羽泺:BAAAKgADCggICAAAAA==.',['耳膜']='耳膜之子:BAAAKgADCggICAAAAA==.',['自寻']='自寻死路丶:BAAAKgAECgIIAgAAAA==.',['芒果']='芒果暖洋洋:BAAAKgAECgYIEAAAAA==.',['花堪']='花堪折:BAAAKgAECgcIBwAAAA==.',['莫宁']='莫宁斯塔:BAAAKgAECggIBwAAAA==.',['莫小']='莫小加:BAACKgAFFH8GAAIYAAIIZgOCHQBeAAAYAAIIZgOCHQBeAAAqAAQKfx0AAxgACAgxCtI6ACkBABgACAgxCtI6ACkBAB8AAQgmC/fNACsAAAAA.',['莫问']='莫问:BAAAKgADCgEIAQAAAA==.',['蒂法']='蒂法索娅:BAABKgAFFH8MAAIbAAYI3xywBwCvAQAbAAYI3xywBwCvAQAAAA==.',['虾仁']='虾仁猪心:BAABKgAECn8UAAIFAAcItQ1yVgBLAQAFAAcItQ1yVgBLAQAAAA==.',['蛋疼']='蛋疼居士:BAABKgAFFH8KAAIDAAYINBZSGQDMAAADAAYINBZSGQDMAAABKgAFFAgIBAAHAAAAAA==.',['蛋黄']='蛋黄酥酥人人:BAAAKgADCggICAAAAA==.',['要坚']='要坚强:BAAAKgAECggICAAAAA==.',['超雄']='超雄马保国:BAAAKgAECggICAAAAA==.',['透明']='透明风:BAABKgAFFH8IAAMeAAgIwwXkEAAGAQAeAAQIOQTkEAAGAQAPAAQI0Af6JgCxAAAAAA==.',['遥远']='遥远的她:BAAAKgAECggICgAAAA==.',['邪歪']='邪歪歪:BAAAKgADCgEIAQAAAA==.',['郁雪']='郁雪落寞:BAABKgAFFH8MAAMfAAQIyRK4FwDfAAAfAAQIyRK4FwDfAAAYAAQImQxCJQCQAAAAAA==.',['都云']='都云谏:BAAAKgADCgYIBgAAAA==.',['释寰']='释寰:BAAAKgAECggICQABKgAFFAgIBgAgAFMhAA==.',['重生']='重生灰烬:BAAAKgAECggICQAAAA==.',['野笔']='野笔大雄:BAAAKgAFFAYIBAAAAA==.',['鑫茂']='鑫茂冰:BAAAKgAECgQIBAAAAA==.',['阿芒']='阿芒拿满:BAAAKgAECgQIBAAAAA==.',['雪尘']='雪尘:BAAAKgAFFAQIBAAAAA==.',['非常']='非常法:BAAAKgAECggIEgAAAA==.',['韩立']='韩立:BAAAKgAECggICgAAAA==.',['风中']='风中追风:BAAAKgAECggICAAAAA==.',['风暴']='风暴行者:BAAAKgADCggICAAAAA==.',['飞龙']='飞龙在天:BAAAKgAECggICwAAAA==.',['魔法']='魔法少女小朱:BAAAKgAECgIIAgAAAA==.',['魔羽']='魔羽飞狼:BAAAKgAECgYICgAAAA==.',['鲨鱼']='鲨鱼莱莱:BAAAKgAECggICAAAAA==.',['黄泉']='黄泉送葬:BAAAKgAECgQIBAAAAA==.',['黄色']='黄色真好:BAAAKgAECgUIBwAAAA==.',['黑夜']='黑夜知者:BAAAKgADCggICAAAAA==.',['黑星']='黑星:BAAAKgAECgcICgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end