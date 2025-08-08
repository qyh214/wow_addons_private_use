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
 local lookup = {'Paladin-Retribution','Druid-Balance','Evoker-Devastation','Hunter-Marksmanship','DeathKnight-Unholy','Hunter-BeastMastery','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Mage-Frost','Mage-Arcane','Druid-Feral','Druid-Restoration','Warrior-Fury','Warrior-Arms','Warlock-Destruction','Warlock-Demonology','Mage-Fire','Priest-Holy','Unknown-Unknown','Paladin-Protection','Rogue-Outlaw','Rogue-Assassination','Hunter-Survival','Shaman-Restoration','Paladin-Holy','Evoker-Preservation','Priest-Discipline','Priest-Shadow','Shaman-Elemental','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Blood','Warrior-Protection','Warlock-Affliction','Rogue-Subtlety','Druid-Guardian',}; local provider = {region='CN',realm='冬泉谷',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Ailier:BAAAKgAECgEIAQAAAA==.',Ak='Akili:BAAAKgAECgEIAQAAAA==.',Al='Alier:BAAAKgADCgMIAwAAAA==.',Am='Ame:BAAAKgAECgEIAQAAAA==.',An='Aniun:BAAAKgADCgQIBAAAAA==.Aniuniu:BAAAKgADCgYICgAAAA==.',Bl='Blessingyou:BAAAKgAECgIIAgAAAA==.',Ch='Cherrin:BAAAKgADCggICAAAAA==.',Da='Datou:BAAAKgADCggICAAAAA==.',Di='Di:BAAAKgAFFAIIBAAAAA==.',Eb='Ebod:BAABKgAECn8bAQIBAAgI/SWNBgAAAwABAAgI/SWNBgAAAwAAAA==.Ebody:BAABKgAECn+ZAAIBAAgIPyWyCQDuAgABAAgIPyWyCQDuAgAAAA==.Ebone:BAABKgAECn9QAAIBAAgIfSPjBgDMAgABAAgIfSPjBgDMAgAAAA==.Ebtwo:BAABKgAECn8kAAIBAAgItyHZFwCnAgABAAgItyHZFwCnAgAAAA==.',Fr='Frankdruid:BAABKgAFFH8IAAICAAgI1gHlIQAVAQACAAgI1gHlIQAVAQAAAA==.',Ft='Ftwoa:BAAAKgADCggICAAAAA==.',Gh='Ghostshire:BAAAKgAECgcIBwAAAA==.',Hq='Hqm:BAAAKgAECgQIBAAAAA==.',Ku='Kungfudog:BAAAKgAECggICAAAAA==.',Lo='Longlongago:BAABKgAFFH8YAAIDAAMIbhaSHADaAAADAAMIbhaSHADaAAAAAA==.',Lu='Luckycows:BAAAKgAFFAIIBAAAAA==.',Na='Nahida:BAABKgAFFH8GAAIEAAYImhrGDwBpAQAEAAYImhrGDwBpAQAAAA==.',No='Nobodyy:BAABKgAECn8kAAIBAAgIriA4HQCOAgABAAgIriA4HQCOAgAAAA==.',Pl='Playerhotydn:BAABKgAFFH8GAAIFAAMI2gxeOQC2AAAFAAMI2gxeOQC2AAAAAA==.Playerwqhvlt:BAACKgAFFH8eAAIGAAQISR7mIQADAQAGAAQISR7mIQADAQAqAAQKfyIAAgYACAjNHXA9AAICAAYACAjNHXA9AAICAAAA.',Re='Rexg:BAABKgAFFH8gAAQHAAgIHx0OAwBTAgAHAAgIHx0OAwBTAgAIAAgIhBgFBAAfAgAJAAQI2wmqBQCUAAAAAA==.',Ri='Rikieasons:BAAAKgADCggIDwAAAA==.',Ry='Rylaicrestfa:BAEBKgAFFH8WAAMKAAgIsiBzAQBjAgAKAAgIlRxzAQBjAgALAAgIsiDPBQA/AgAAAA==.',Sd='Sdffsf:BAAAKgAECgIIAQAAAA==.',Ta='Tamamdh:BAACKgAFFH8jAAQMAAgI2hHeAQCaAQAMAAYIMRTeAQCaAQACAAYImgq9IAAbAQANAAEIHAQsJgAxAAAqAAQKfxwAAwwACAi+HLgOALcBAAwACAgaGrgOALcBAAIACAiJDiBmACwBAAAA.',Ti='Tiamat:BAAAKgADCggICAAAAA==.',Vm='Vmware:BAABKgAECn8YAAMNAAgIDhWNKgBWAQANAAgIDhWNKgBWAQACAAEIZgPf4AAhAAAAAA==.',Ya='Yamoodly:BAABKgAFFH8IAAMCAAgINgt0HAA4AQACAAQIrhF0HAA4AQANAAQIVgNrKwByAAAAAA==.',Zy='Zynn:BAAAKgAECgQIBAAAAA==.',['一个']='一个人失忆:BAAAKgAECggIDQAAAA==.',['一及']='一及格线一:BAAAKgAECgcIBwABKgAECggIGgALAHwcAA==.',['一心']='一心上山:BAAAKgAFFAQIBAAAAA==.',['一朵']='一朵懒女子:BAAAKgAECgYIBgAAAA==.',['一马']='一马当先:BAAAKgAECgcIBwAAAA==.',['七宗']='七宗罪丶傲慢:BAAAKgAECgEIAQAAAA==.',['七渡']='七渡胸间:BAAAKgAECgEIAQAAAA==.',['万丈']='万丈光芒丶:BAABKgAECn8dAAIOAAgIpRrXFAAwAgAOAAgIpRrXFAAwAgAAAA==.',['上白']='上白:BAAAKgADCggICAAAAA==.',['不了']='不了不了:BAABKgAFFH8KAAIPAAMIiBYzFADhAAAPAAMIiBYzFADhAAAAAA==.',['不是']='不是算了我的:BAABKgAFFH8MAAMQAAYIFSI/BgBBAQAQAAYIFSI/BgBBAQARAAEI4w2sKABIAAAAAA==.',['不灭']='不灭苍穹:BAAAKgAECgYIBwAAAA==.',['不用']='不用驱我能解:BAABKgAFFH8SAAQKAAYIXiTxAQANAgAKAAYIXiTxAQANAgASAAQI9B2lEQAMAQALAAQIpg45LQCvAAAAAA==.',['不由']='不由己自风流:BAAAKgAECgQIBQAAAA==.',['专业']='专业丶射手:BAAAKgAECggICAAAAA==.专业小偷:BAAAKgAECgMIAwAAAA==.',['丨兽']='丨兽灬兽丨:BAABKgAECn8uAAITAAgIWSHbDABpAgATAAgIWSHbDABpAgAAAA==.',['丨死']='丨死丨遠丶:BAAAKgADCgQIBAAAAA==.',['中郎']='中郎犟:BAAAKgADCggIFAAAAA==.',['丰川']='丰川祥子:BAAAKgAFFAYIBAABKgAFFAgIBAAUAAAAAA==.',['九洲']='九洲風神:BAAAKgAFFAQIBAAAAA==.',['也来']='也来一次:BAAAKgAECgEIAQAAAA==.',['亀派']='亀派气功:BAAAKgADCgMIAwAAAA==.',['云芗']='云芗:BAABKgAFFH8GAAIVAAYIMhk6CQBtAQAVAAYIMhk6CQBtAQAAAA==.',['亖亖']='亖亖:BAAAKgAECgcIBwABKgAECggIGgALAHwcAA==.',['亖及']='亖及格线亖:BAABKgAECn8aAAMLAAgIfBxbFwA1AgALAAgIfBxbFwA1AgAKAAcIcBLiLQBTAQAAAA==.',['京城']='京城圣骑:BAAAKgAECggIBgAAAA==.京城奶爸:BAAAKgAECgIIAgAAAA==.',['人称']='人称花哥:BAAAKgAECgIIAgAAAA==.',['今夜']='今夜賊寂寞:BAABKgAECn8nAAMWAAcIJQ6OCAAGAQAWAAcIJQ6OCAAGAQAXAAYIFATQOgB+AAAAAA==.',['今田']='今田美樱:BAAAKgAECgYIBwAAAA==.',['从我']='从我家里出去:BAACKgAFFH8GAAIYAAMI/geLAQDCAAAYAAMI/geLAQDCAAAqAAQKfxwAAxgACAhGGFEGAPoBABgACAhGGFEGAPoBAAQABgg7C19MAOsAAAAA.',['伊邪']='伊邪那美:BAAAKgAECgcIBwAAAA==.',['传说']='传说中的小猎:BAACKgAFFH8eAAMGAAYIKhYHGAA6AQAGAAYIohIHGAA6AQAEAAMImhxpIADzAAAqAAQKfyUAAgQACAjrIBcQAHkCAAQACAjrIBcQAHkCAAAA.传说中的战神:BAAAKgADCgcIBwAAAA==.',['你吃']='你吃个蛋蛋:BAAAKgADCgIIAgAAAA==.',['佩涅']='佩涅罗佩:BAABKgAFFH8IAAIBAAgIxBbPBwBHAgABAAgIxBbPBwBHAgAAAA==.',['依然']='依然瑷:BAAAKgAFFAYIBAAAAA==.',['傲慢']='傲慢与偏见丶:BAAAKgAECggIDAAAAA==.',['傻馒']='傻馒的河狸:BAAAKgAECggICQAAAA==.',['光头']='光头和桑:BAAAKgAECgIIBQAAAA==.',['兽戈']='兽戈戈:BAAAKgAECggICAAAAA==.',['冰风']='冰风骑士:BAAAKgAECggIDAAAAA==.',['几分']='几分中意:BAAAKgAFFAQIBAAAAA==.',['凡人']='凡人修仙:BAAAKgAECgIIAgAAAA==.',['刃下']='刃下心:BAAAKgAECggICAAAAA==.',['初如']='初如晴天丶:BAAAKgAFFAYIAgAAAA==.',['初樱']='初樱:BAAAKgADCgYIBgAAAA==.',['刮风']='刮风这天:BAAAKgAECggIDAAAAA==.',['半烟']='半烟丶星语:BAAAKgADCgIIAgAAAA==.',['半盏']='半盏凡事清:BAAAKgADCgEIAQAAAA==.',['卟爻']='卟爻:BAAAKgAECgUIBQAAAA==.',['厚甲']='厚甲载物:BAAAKgAFFAMIBAAAAA==.',['叁陆']='叁陆玖條:BAAAKgAFFAIIAgAAAA==.',['双子']='双子星嚤羯:BAAAKgAFFAEIAQABKgAFFAYIAQAUAAAAAA==.',['叫吾']='叫吾猎爹:BAAAKgADCgEIAQAAAA==.',['右手']='右手哥哥:BAAAKgADCggICAAAAA==.',['吃货']='吃货小豆泥:BAABKgAECn8XAAIZAAgIZhM6QgBuAQAZAAgIZhM6QgBuAQABKgAFFAYIAQAUAAAAAA==.',['君莫']='君莫邪:BAABKgAFFH8cAAQaAAYIYhv6AACBAQAaAAYIYhv6AACBAQABAAQImSQvLQAyAQAVAAYIgQsMFADYAAABKgAFFAgIBAAUAAAAAA==.',['吣慯']='吣慯:BAAAKgAECgEIAQAAAA==.',['咕咕']='咕咕不是猫:BAAAKgAFFAQIBAAAAA==.咕咕可以吗:BAAAKgAECgcIBwAAAA==.',['咸蛋']='咸蛋黄超人:BAABKgAFFH8GAAILAAYIWxGhEwBHAQALAAYIWxGhEwBHAQAAAA==.',['哎哟']='哎哟我去他:BAAAKgAECgUIDwAAAA==.',['哪里']='哪里亮了点哪:BAAAKgADCgYIBgAAAA==.',['嘦巭']='嘦巭深:BAABKgAECn9UAAIZAAgIEiQOCQCnAgAZAAgIEiQOCQCnAgAAAA==.',['嘿嘿']='嘿嘿:BAABKgAECn8ZAAIKAAgIMx8jDgBhAgAKAAgIMx8jDgBhAgAAAA==.',['噩噩']='噩噩:BAAAKgAECgUIBQAAAA==.',['嚣张']='嚣张的右手:BAAAKgADCgEIAQAAAA==.',['四季']='四季茶:BAACKgAFFH8FAAIDAAMIJQntEgC8AAADAAMIJQntEgC8AAAqAAQKfyIAAwMACAh9FzAbAOQBAAMACAh9FzAbAOQBABsACAi4EYMLALYBAAAA.',['图腾']='图腾代言人:BAAAKgAECgUIBQAAAA==.',['圣光']='圣光属于我们:BAAAKgAECgYIBgAAAA==.',['坠落']='坠落凤舞:BAABKgAECn8ZAAIFAAgIRQxxTwA2AQAFAAgIRQxxTwA2AQAAAA==.',['增强']='增强增强萨:BAACKgAFFH8IAAIKAAQIihIADADOAAAKAAQIihIADADOAAAqAAQKfxgAAwoACAj8IQcTAGYCAAoABwj8IQcTAGYCABIABQhXE6d3AJwAAAAA.',['大触']='大触:BAAAKgADCgIIAgAAAA==.',['大风']='大风歌术:BAABKgAFFH8GAAIQAAYIjQvBDwA8AQAQAAYIjQvBDwA8AQAAAA==.',['天堂']='天堂丶泪:BAAAKgADCgcIBwAAAA==.',['天涯']='天涯小僧:BAAAKgAFFAIIAgAAAA==.',['天灾']='天灾忠犬:BAAAKgAECgYICAAAAA==.',['天煞']='天煞灬孤星:BAABKgAECn8bAAMPAAgIOgovLAAtAQAPAAgIOgovLAAtAQAOAAUIPAOzdACLAAAAAA==.',['天钿']='天钿女命:BAAAKgAECgMIBAABKgAECggIGgALAHwcAA==.',['奈亚']='奈亚拉托提普:BAAAKgAECggIEQAAAA==.',['奔波']='奔波尔柴柴:BAAAKgADCggICAAAAA==.',['奶不']='奶不起:BAAAKgAECggIAQAAAA==.',['奶油']='奶油小饼干:BAACKgAFFH8KAAMPAAQIShNTHACoAAAPAAQICRJTHACoAAAOAAIIXweWIQCJAAAqAAQKfxwAAw4ACAidEug/AHQBAA4ABwjBEug/AHQBAA8ABwjhDz9AANcAAAAA.',['奶黄']='奶黄包丶:BAABKgAFFH8MAAMcAAMIbhrGFwDTAAAcAAMIbhrGFwDTAAAdAAEIwQWBMAA1AAAAAA==.',['好色']='好色北北:BAAAKgADCgYIBgAAAA==.',['好运']='好运气伴我:BAAAKgAECgEIAQAAAA==.',['如花']='如花叁:BAAAKgAECgEIAQAAAA==.如花壹:BAAAKgAECgEIAQAAAA==.如花贰:BAAAKgAECgEIAQAAAA==.',['妈妈']='妈妈:BAACKgAFFH8nAAMGAAgIBiUbAwCYAgAGAAgIBiUbAwCYAgAEAAIIIRYWJgBJAAAqAAQKfy0ABAYACAiaJvsTAIwCAAYACAiaJvsTAIwCAAQAAQhpI8d4AF0AABgAAQjPGX4XAEMAAAAA.',['妤卡']='妤卡:BAAAKgAFFAEIAQAAAA==.',['妺喜']='妺喜:BAAAKgADCgQIBAAAAA==.',['季伯']='季伯初:BAAAKgAFFAQIBAAAAA==.',['安东']='安东尼达斯:BAAAKgAFFAYIAgAAAA==.',['宝宝']='宝宝巴斯:BAABKgAFFH8FAAIEAAUI6A4CHwD8AAAEAAUI6A4CHwD8AAAAAA==.',['小司']='小司机:BAAAKgAFFAEIAQAAAA==.',['小宇']='小宇宙丶:BAAAKgAECgUIBQAAAA==.',['小小']='小小鸟德:BAAAKgAECgIIAgAAAA==.',['小棉']='小棉裤:BAAAKgAECgEIAQAAAA==.',['小步']='小步舞曲:BAAAKgAECgcIBwAAAA==.',['小泽']='小泽:BAABKgAECn81AAIKAAgIeiG3CgCLAgAKAAgIeiG3CgCLAgAAAA==.小泽又牧风:BAAAKgAFFAYIBAAAAA==.',['小牛']='小牛贝希:BAABKgAFFH8GAAIZAAYIewiaGAAfAQAZAAYIewiaGAAfAQAAAA==.',['小猛']='小猛兽:BAAAKgAECgEIAQAAAA==.',['小疯']='小疯狂:BAABKgAFFH8FAAMGAAQIRyC4EAAKAQAGAAQIGRu4EAAKAQAEAAEIciMoTQBKAAAAAA==.',['小脑']='小脑斧丶:BAAAKgADCgYIBgAAAA==.',['小脚']='小脚酷酷:BAAAKgAECgQIBQAAAA==.',['小蘑']='小蘑菇采姑娘:BAAAKgADCgEIAQAAAA==.',['小黄']='小黄人布拿拿:BAAAKgADCgUIBQAAAA==.',['小龙']='小龙人同仁堂:BAAAKgADCgUIBQAAAA==.',['尐色']='尐色:BAAAKgAECggICgAAAA==.',['尕尕']='尕尕:BAABKgAECn8wAAMZAAgIWh+IEQBiAgAZAAgIWh+IEQBiAgAeAAEIAQlWeQAtAAAAAA==.尕尕小张:BAAAKgAFFAQIBAAAAA==.',['尼哥']='尼哥买提:BAAAKgADCggICgAAAA==.',['尼采']='尼采:BAAAKgAECggIAwAAAA==.',['屹川']='屹川丶奶僧:BAAAKgAECgIIAgAAAA==.屹川丶奶德:BAAAKgAECgEIAQAAAA==.屹川丶奶骑:BAAAKgAECgMIAwAAAA==.屹川丶奶龙:BAAAKgADCgIIAgAAAA==.屹川丶戒律:BAAAKgAECgQIBQAAAA==.屹川丶撒亚人:BAAAKgAFFAEIAQAAAA==.屹川丶湮灭:BAAAKgAECgEIAQAAAA==.屹川丶熊德:BAAAKgADCggICAAAAA==.屹川丶狂徒:BAAAKgADCgQIBAAAAA==.',['巅峰']='巅峰丿修罗灬:BAAAKgAECggIDwAAAA==.',['平凡']='平凡的河狸:BAAAKgAECggIEQAAAA==.',['幻雨']='幻雨月光:BAAAKgAECgUIBQAAAA==.',['幻魔']='幻魔小妹儿:BAAAKgADCggICAAAAA==.',['幽灵']='幽灵芝阍:BAAAKgAECgMIAwAAAA==.',['康德']='康德:BAAAKgAECgEIAQAAAA==.',['强颈']='强颈怒:BAAAKgADCgMIAwAAAA==.',['影心']='影心:BAAAKgAFFAQIBAAAAA==.',['徐浩']='徐浩吃嘛果:BAACKgAFFH8PAAICAAUI9COVBwA0AQACAAUI9COVBwA0AQAqAAQKfyYAAgIACAi3JIIMAL8CAAIACAi3JIIMAL8CAAAA.',['德资']='德资:BAAAKgAECggIDgAAAA==.',['忘语']='忘语:BAAAKgADCgIIAgAAAA==.',['怨憎']='怨憎会:BAAAKgAECgcIEgAAAA==.',['憤怒']='憤怒的蜗牛:BAAAKgAECggICAAAAA==.',['我乃']='我乃上将潘凤:BAAAKgADCgQIBAAAAA==.',['我们']='我们的时代:BAAAKgAECgcICwAAAA==.',['我是']='我是吓大的:BAABKgAFFH8UAAICAAQIISTcCAAoAQACAAQIISTcCAAoAQAAAA==.',['我有']='我有一个想法:BAAAKgADCgYIBgAAAA==.',['战意']='战意滔天:BAAAKgAECgYIBgAAAA==.',['战无']='战无虚发:BAABKgAFFH8GAAIOAAYIsw8hCgCMAQAOAAYIsw8hCgCMAQAAAA==.',['戴蒙']='戴蒙亨特:BAAAKgAECgIIAgAAAA==.',['执剑']='执剑饮烈酒:BAABKgAECn8hAAIIAAgIqAp8GADeAAAIAAgIqAp8GADeAAAAAA==.',['批萨']='批萨猪:BAAAKgAFFAEIAQAAAA==.',['拉不']='拉不稳:BAABKgAFFH8IAAIfAAgImwlqDAC+AQAfAAgImwlqDAC+AQAAAA==.',['拼命']='拼命猫猫:BAAAKgADCgEIAQAAAA==.',['挑逗']='挑逗的嘴角:BAABKgAECn8lAAIBAAgIWB5nEwAzAgABAAgIWB5nEwAzAgAAAA==.',['撒旦']='撒旦之吻:BAABKgAECn8VAAIgAAgIZBCnEgAFAQAgAAgIZBCnEgAFAQAAAA==.',['敏龟']='敏龟的感头:BAABKgAFFH8GAAIZAAYI9g3uEgA+AQAZAAYI9g3uEgA+AQAAAA==.',['斩戈']='斩戈戈:BAAAKgAFFAQIBAABKgAFFAgIBgAhABkJAA==.',['断角']='断角的吃西瓜:BAAAKgAECgQIBAAAAA==.',['新一']='新一代东东:BAAAKgAECggIDwAAAA==.',['无敌']='无敌小使者:BAAAKgADCggICAAAAA==.无敌最凶狠:BAAAKgAFFAgIBAAAAA==.',['春绯']='春绯:BAABKgAFFH8HAAIHAAcIkgIXDAD6AAAHAAcIkgIXDAD6AAAAAA==.',['晚安']='晚安吾爱:BAAAKgAECgMIAwAAAA==.',['普罗']='普罗汀:BAAAKgAECgEIAQAAAA==.',['暴力']='暴力狂:BAAAKgAECggIEwAAAA==.暴力狂丶:BAABKgAFFH8iAAMCAAgILiFqBQBqAgACAAcI3CRqBQBqAgANAAEIegMrNwA/AAAAAA==.',['暴躁']='暴躁马铃薯:BAABKgAECn8YAAMGAAgIDxTbYwAsAQAGAAgIoBPbYwAsAQAEAAMIjg2PgAB8AAAAAA==.',['曜竹']='曜竹:BAABKgAECn8iAAIGAAgIkxOlTADNAQAGAAgIkxOlTADNAQAAAA==.',['月小']='月小半:BAAAKgAECggICAAAAA==.',['月痕']='月痕:BAAAKgAECgUICgAAAA==.',['朕羊']='朕羊你勿罪:BAABKgAECn8YAAIKAAgI/xBDKQBxAQAKAAgI/xBDKQBxAQAAAA==.',['李二']='李二狗:BAAAKgAECgcIBwAAAA==.',['杨丶']='杨丶超越:BAAAKgAFFAIIAgAAAA==.',['杰尼']='杰尼龟:BAAAKgAECggICAAAAA==.',['枭白']='枭白:BAAAKgADCgcIBwAAAA==.',['桃花']='桃花岛丶郭靖:BAABKgAFFH8GAAICAAYIvw9UGgBHAQACAAYIvw9UGgBHAQAAAA==.',['梅须']='梅须逊雪:BAAAKgAECgMIAwAAAA==.',['橘子']='橘子丶:BAAAKgAECgUIBQAAAA==.橘子味的猫鲨:BAAAKgAECggICAAAAA==.橘子猫:BAAAKgAECgMIAwAAAA==.',['橙色']='橙色的牛氓:BAACKgAFFH8UAAMOAAgIHB7LCADJAQAOAAgIHB7LCADJAQAiAAYIwQfaCQDHAAAqAAQKfxkAAw4ACAg0GMYgAM0BAA4ACAg0GMYgAM0BACIAAghmCPFMACIAAAAA.',['武神']='武神千千:BAABKgAECn89AAIIAAgIixtbEgAjAgAIAAgIixtbEgAjAgAAAA==.',['毛头']='毛头小术:BAACKgAFFH8LAAMjAAMIXSE5DgC0AAAQAAII9x5rLQC4AAAjAAMIuRg5DgC0AAAqAAQKfxwABCMACAihI9YQAHUBACMABAj2INYQAHUBABEABAh1I/EwACMBABAABAh8HoRCAAEBAAAA.',['毛线']='毛线猫:BAAAKgADCggICAAAAA==.',['永不']='永不停射:BAAAKgAFFAIIAgAAAA==.',['求不']='求不得:BAAAKgAECggIEgAAAA==.',['江湖']='江湖故人:BAAAKgAECgYIBgAAAA==.',['法天']='法天象帝:BAAAKgAFFAgIBAAAAA==.',['流逝']='流逝无痕:BAAAKgAECggICwAAAA==.',['清潼']='清潼:BAAAKgAFFAQIBAABKgAFFAgIDwAQAJIcAA==.',['渊博']='渊博的蜗牛:BAABKgAFFH8IAAIZAAgI7BP6BQDNAQAZAAgI7BP6BQDNAQAAAA==.',['渴死']='渴死的鱼:BAAAKgAFFAYIAwAAAA==.',['溏沫']='溏沫沫:BAABKgAFFH8IAAIQAAgISxbQBgAmAgAQAAgISxbQBgAmAgAAAA==.',['满船']='满船清梦:BAAAKgAECgEIAQAAAA==.',['滴血']='滴血亡魂:BAABKgAECn8aAAMQAAgIIw6sOgAhAQAQAAcI7A+sOgAhAQARAAgIiAlXNwAYAQAAAA==.',['漠丿']='漠丿小丹:BAAAKgAECgcICAAAAA==.',['漫步']='漫步的囡囡:BAAAKgAECgYICQAAAA==.',['潇洒']='潇洒狼:BAAAKgADCggIEAAAAA==.潇洒走一回:BAABKgAECn8cAAMBAAgIDQ23jAAzAQABAAgIDQ23jAAzAQAaAAcI6gsfLQADAQAAAA==.',['灬一']='灬一朵懒女子:BAAAKgAECgQIBAAAAA==.',['灰烬']='灰烬使者:BAABKgAFFH8OAAIBAAgIwh12BACSAgABAAgIwh12BACSAgAAAA==.',['炫裤']='炫裤之酷:BAAAKgADCgIIAgAAAA==.',['炫酷']='炫酷:BAAAKgADCgMIAwAAAA==.',['烈火']='烈火银狐:BAAAKgAECgIIAgAAAA==.',['烟花']='烟花易冷:BAAAKgAECgQIBQAAAA==.',['爱别']='爱别离:BAABKgAECn8tAAIEAAgIIx5VFABXAgAEAAgIIx5VFABXAgAAAA==.',['爱慕']='爱慕有法则:BAAAKgADCgEIAQAAAA==.',['爷爷']='爷爷:BAABKgAFFH8KAAIFAAYIjxzECACtAQAFAAYIjxzECACtAQABKgAFFAgIJwAGAAYlAA==.',['物部']='物部布都:BAAAKgADCggICAABKgAFFAYICgAHAL4TAA==.',['牵线']='牵线的木偶:BAAAKgAFFAQIAgAAAA==.',['狂魔']='狂魔图斯:BAAAKgAECgcICQAAAA==.',['狼叔']='狼叔丿:BAABKgAECn8bAAIGAAcI1SABIABAAgAGAAcI1SABIABAAgAAAA==.',['猛先']='猛先圣:BAABKgAFFH8OAAMGAAYI+xsaDwCFAQAGAAYI+xsaDwCFAQAEAAIIvRfkIwBRAAAAAA==.',['王力']='王力量:BAABKgAFFH8FAAMLAAMI0Qi4LgCpAAALAAMI0Qi4LgCpAAAKAAIIggS0JwBXAAAAAA==.',['瑶光']='瑶光丶:BAAAKgAECgQIBAAAAA==.',['男人']='男人无敌:BAAAKgAECgYICwAAAA==.',['當夏']='當夏末無蝉:BAABKgAECn8mAAIBAAgIqSQ7IQB9AgABAAgIqSQ7IQB9AgAAAA==.',['白上']='白上吹雪:BAAAKgAECggIEAABKgAFFAgIDwAhAN0KAA==.',['白梦']='白梦妍:BAAAKgAECggICAAAAA==.',['白银']='白银之膝盖:BAABKgAFFH8KAAMVAAYI3w9kDwAMAQAVAAYI2A1kDwAMAQABAAQIeBZnTADWAAABKgAFFAgIKAABAI8ZAA==.',['白首']='白首如新:BAAAKgAECgcIBwAAAA==.',['盖娅']='盖娅:BAAAKgADCggICAAAAA==.',['盼暖']='盼暖春来:BAAAKgAFFAQIBAAAAA==.',['磨剪']='磨剪子戗菜刀:BAAAKgAECggICAAAAA==.',['离群']='离群的大猫咪:BAAAKgAFFAQIBAAAAA==.',['秀秀']='秀秀:BAAAKgADCgMIAwAAAA==.',['秀逗']='秀逗魔导士:BAAAKgAECgcIBwAAAA==.',['秋天']='秋天深蓝:BAAAKgAECgMIAwAAAA==.',['稻香']='稻香:BAAAKgAECgUIBQAAAA==.',['童童']='童童:BAAAKgAECgEIAQAAAA==.',['简单']='简单如初:BAACKgAFFH8HAAIOAAMI+Al4GAC/AAAOAAMI+Al4GAC/AAAqAAQKfyMABA4ACAgHFzcqAOEBAA4ACAh9FTcqAOEBAA8ABghkD7orAF0BACIAAgjOE7UzAHkAAAAA.',['红发']='红发肥新:BAABKgAFFH8OAAIhAAgIchPmBQDbAQAhAAgIchPmBQDbAQAAAA==.',['细路']='细路囡:BAAAKgADCgIIAgAAAA==.',['绝亦']='绝亦:BAABKgAFFH8NAAMXAAgILiHaAQCuAgAXAAgIIiDaAQCuAgAkAAMILh+/CgCwAAAAAA==.',['维特']='维特根斯坦:BAAAKgAECggICAAAAA==.',['绵绵']='绵绵嘟:BAAAKgADCgEIAQAAAA==.',['绿色']='绿色枫叶:BAAAKgAFFAQIBAAAAA==.',['美国']='美国国王:BAAAKgADCggIEAAAAA==.',['美式']='美式坦克:BAABKgAECn8WAAINAAgI+hB8KQBdAQANAAgI+hB8KQBdAQAAAA==.',['美美']='美美魏胖胖:BAAAKgADCggICAAAAA==.',['耶耶']='耶耶瑟瑟:BAABKgAFFH8TAAMCAAgIkRdRBwA4AgACAAgIkRdRBwA4AgANAAgIsRESBADNAQAAAA==.',['职业']='职业打假人:BAABKgAFFH8JAAIBAAUImSOgFgD/AAABAAUImSOgFgD/AAAAAA==.',['联盟']='联盟组人:BAAAKgAECgIIAgAAAA==.',['肆倒']='肆倒影:BAAAKgAECggICAAAAA==.',['脆皮']='脆皮原味鸡:BAAAKgAECgUIBwAAAA==.',['舞零']='舞零舞:BAAAKgAECggIDgAAAA==.',['芋头']='芋头烧仙草:BAAAKgAECgUIBwAAAA==.',['芤曖']='芤曖:BAACKgAFFH8MAAIZAAMImxfIFADPAAAZAAMImxfIFADPAAAqAAQKfxUAAhkACAiAFdNXADcBABkACAiAFdNXADcBAAAA.',['花再']='花再:BAAAKgADCggIFwAAAA==.',['花尐']='花尐:BAAAKgAECgQIBAAAAA==.',['花开']='花开:BAAAKgAFFAgIBAAAAA==.',['花弗']='花弗:BAABKgAFFH8MAAIBAAYIRRtbEgB3AQABAAYIRRtbEgB3AQAAAA==.',['花椒']='花椒:BAACKgAFFH8JAAIPAAYIyRCqBQCJAQAPAAYIyRCqBQCJAQAqAAQKfxQAAw8ABwghH8URACoCAA8ABwghH8URACoCAA4ABgjXE1BHAEwBAAAA.',['花椰']='花椰菜之心:BAABKgAECn8ZAAIBAAgI0SDvHwCZAgABAAgI0SDvHwCZAgAAAA==.',['花沐']='花沐:BAAAKgADCggICAAAAA==.',['花泽']='花泽:BAAAKgAECgUIBwAAAA==.',['花羽']='花羽:BAAAKgADCgIIBAAAAA==.',['花落']='花落:BAAAKgAFFAQIBAAAAA==.',['花蔓']='花蔓:BAAAKgAECgUIBQAAAA==.',['花醒']='花醒:BAAAKgAECgUIBwAAAA==.',['苍狗']='苍狗君:BAAAKgAFFAQIBAAAAA==.',['苏格']='苏格拉底:BAACKgAFFH8GAAIaAAMIFhAqCwCjAAAaAAMIFhAqCwCjAAAqAAQKfyoAAxoACAhBF6IIAKcBABoACAhBF6IIAKcBAAEACAh9FyZqAIUBAAEqAAUUCAgOAAEAqxYA.',['英俊']='英俊:BAAAKgAFFAUIAQABKgAFFAgIBAAUAAAAAA==.',['范迪']='范迪塞尔:BAABKgAFFH8RAAMOAAgIzxtfAQDFAQAOAAYIKhVfAQDFAQAPAAQIFBfDDQA0AQAAAA==.',['茉崔']='茉崔蒂:BAAAKgAFFAEIAQABKgAFFAUIDwACAPQjAA==.',['茜公']='茜公舉殿下丶:BAABKgAECn81AAQCAAgISh3+HgBIAgACAAgISh3+HgBIAgANAAYIxQ3XXgCZAAAlAAEIhwriNAAgAAAAAA==.',['茨木']='茨木华扇:BAAAKgAECgMIAwAAAA==.',['荒天']='荒天帝:BAAAKgADCggIDgAAAA==.',['荒野']='荒野镖猎:BAAAKgAECgcIBwAAAA==.',['莉亚']='莉亚迪桑:BAABKgAECn9tAAMEAAgISR8QEwBhAgAEAAgISR8QEwBhAgAGAAEIRAvN/QA8AAAAAA==.',['莱尔']='莱尔逐日者:BAAAKgAFFAIIAgAAAA==.',['菈妮']='菈妮娅凯亚:BAAAKgADCggICAAAAA==.',['菲菲']='菲菲:BAAAKgADCgIIAgAAAA==.',['萌萌']='萌萌囧筱猎:BAABKgAFFH8GAAMEAAMIJAQ1RgBnAAAEAAMIfQM1RgBnAAAGAAEIywWkYAA1AAAAAA==.',['蒲公']='蒲公英:BAABKgAFFH8GAAIVAAMI0hE+GgCmAAAVAAMI0hE+GgCmAAAAAA==.',['虚空']='虚空猎杀者:BAAAKgAECgIIAgAAAA==.',['蚩尤']='蚩尤大帝:BAABKgAECn8eAAIQAAgI4xXdJQCLAQAQAAgI4xXdJQCLAQAAAA==.',['蛊尔']='蛊尔丹儿:BAABKgAFFH8IAAIQAAgIPwiXCwCSAQAQAAgIPwiXCwCSAQAAAA==.',['表弟']='表弟慢热手:BAAAKgAFFAgIAgAAAA==.',['诡谲']='诡谲:BAAAKgAECgUIBQAAAA==.',['谁又']='谁又明浪子心:BAAAKgADCggICAAAAA==.',['调皮']='调皮:BAAAKgAECggIEAAAAA==.',['豆包']='豆包:BAAAKgADCgQIBAAAAA==.',['贰哥']='贰哥:BAAAKgAECggIDQAAAA==.',['赞达']='赞达拉的救赎:BAABKgAECn8VAAIVAAgISRxnDQAhAgAVAAgISRxnDQAhAgAAAA==.',['赫萝']='赫萝:BAABKgAFFH8HAAQcAAQImBiqCAD6AAAcAAMIxRmqCAD6AAAdAAIIgRMtEwCVAAATAAEIERV3HwA+AAAAAA==.',['赵灵']='赵灵儿丶:BAABKgAFFH8HAAIXAAUICBO1DQB0AQAXAAUICBO1DQB0AQAAAA==.',['超威']='超威老炮:BAAAKgAFFAYIAQAAAA==.',['超速']='超速蜗牛:BAAAKgAECggIEgAAAA==.',['跑跑']='跑跑就是牛:BAABKgAECn8XAAIOAAgI3BjhFQBWAQAOAAgI3BjhFQBWAQAAAA==.',['迷嫣']='迷嫣:BAAAKgAECgUIBQAAAA==.',['遗弃']='遗弃新之助:BAAAKgADCggICAAAAA==.遗弃珐绅:BAAAKgADCggICAAAAA==.',['那个']='那个龙人:BAACKgAFFH8iAAMKAAYI6xhSBACVAQAKAAYI6xhSBACVAQASAAEI4g3qOgBHAAAqAAQKfzAAAwoACAg+JcQEAN8CAAoACAg+JcQEAN8CABIAAggjDv6NAF0AAAAA.',['邪恶']='邪恶之霸:BAACKgAFFH8MAAIjAAMIgBZ3DgDCAAAjAAMIgBZ3DgDCAAAqAAQKfxUABCMACAgxG38WAD0BACMABAj8GX8WAD0BABEABAgeHPxRALEAABAABAj3E7tzALAAAAAA.邪恶代言人:BAAAKgADCgIIAgAAAA==.',['郭小']='郭小囡:BAAAKgAECggICQAAAA==.',['酷鼻']='酷鼻卡:BAAAKgADCggICAAAAA==.',['醉梦']='醉梦无痕:BAAAKgAFFAQIBAAAAA==.',['醉翩']='醉翩翩:BAACKgAFFH8GAAILAAYIwhHJFAA+AQALAAYIwhHJFAA+AQAqAAQKfx0AAwoACAijD/AQAGkBAAoACAjeDvAQAGkBAAsABwhHC5tUAO0AAAAA.',['醉醉']='醉醉:BAABKgAFFH8OAAMFAAUIbxHcIAAaAQAFAAUI2Q7cIAAaAQAhAAMI2xEXIQCdAAAAAA==.',['野格']='野格格:BAAAKgAECgQIBAAAAA==.',['鋼鉄']='鋼鉄韵律:BAABKgAECn86AAIiAAgItRKAFgBjAQAiAAgItRKAFgBjAQAAAA==.',['铁血']='铁血防骑:BAAAKgAECggIDgAAAA==.',['阿冬']='阿冬灬:BAAAKgAECgYIBgAAAA==.',['阿尔']='阿尔卑斯:BAAAKgAECgUICQAAAA==.',['陌上']='陌上寸草:BAACKgAFFH8KAAIHAAQILhFPHgCvAAAHAAQILhFPHgCvAAAqAAQKfykAAgcACAg8HVcVAOUBAAcACAg8HVcVAOUBAAAA.',['陶小']='陶小胖:BAAAKgAECgcIBwAAAA==.',['隋风']='隋风踏青:BAAAKgAECgcIAQAAAA==.',['随风']='随风飘散丶:BAABKgAFFH8MAAICAAMIwBX3MADRAAACAAMIwBX3MADRAAAAAA==.随风飘远丶:BAABKgAFFH8HAAMEAAMIrhVVKgDBAAAEAAMIrhVVKgDBAAAGAAEIlgvlXQA7AAAAAA==.',['雪花']='雪花女神龙:BAABKgAECn8eAAIGAAgIbhCxTQB1AQAGAAgIbhCxTQB1AQAAAA==.',['零神']='零神瑟丝卡:BAAAKgADCgQIBAAAAA==.',['霍霍']='霍霍:BAABKgAFFH8RAAMcAAYIHyDEBQDcAQAcAAYIdh3EBQDcAQATAAYITx6ABwCyAQAAAA==.',['青菜']='青菜要放葱:BAAAKgAECgUIBQAAAA==.',['青青']='青青欲雨:BAABKgAFFH8GAAITAAYInQWIFgABAQATAAYInQWIFgABAQAAAA==.',['音音']='音音:BAAAKgADCgEIAQAAAA==.',['预言']='预言:BAAAKgADCgUIBQAAAA==.',['风风']='风风:BAABKgAFFH8TAAMBAAgIBxtKBgBYAgABAAgIBxtKBgBYAgAVAAEIiA49LQAlAAAAAA==.',['飝滒']='飝滒:BAAAKgADCgUIBQAAAA==.',['飝裓']='飝裓:BAAAKgAECggIBwAAAA==.',['馒萨']='馒萨:BAAAKgAFFAgIBAAAAA==.',['馬克']='馬克斯彡德:BAAAKgAECgUIBQAAAA==.馬克斯彡肖:BAAAKgAECgEIAQAAAA==.馬克斯彡萧:BAAAKgAECgEIAQAAAA==.',['骑士']='骑士的圣光:BAAAKgADCggICAAAAA==.',['鬼舞']='鬼舞拾柒:BAAAKgADCgYIBgAAAA==.',['魔兽']='魔兽排队打刀:BAAAKgAECgYIDQAAAA==.',['魯道']='魯道莫那:BAAAKgAECggICAAAAA==.',['鱼刺']='鱼刺丶:BAAAKgADCggICAAAAA==.',['黄陂']='黄陂太子皮几:BAAAKgAECgYIBgAAAA==.',['黑妞']='黑妞:BAAAKgAECgYIBgAAAA==.',['黑檀']='黑檀白榆:BAAAKgAFFAUIAgAAAA==.',['黑皮']='黑皮松花蛋:BAAAKgAFFAMIBAAAAA==.',['黯黑']='黯黑小念头:BAAAKgAECgUICgAAAA==.',['龘飝']='龘飝飍舞:BAAAKgAECggIEAAAAA==.',['龙卷']='龙卷风起:BAAAKgADCgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end