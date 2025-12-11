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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Rogue-Subtlety','Rogue-Assassination','DemonHunter-Havoc','Monk-Brewmaster','Druid-Balance','Druid-Guardian','Unknown-Unknown','Shaman-Restoration','Paladin-Holy','Paladin-Retribution','Evoker-Devastation','Evoker-Preservation','DeathKnight-Frost','Mage-Arcane','Warrior-Fury','Warlock-Destruction','Druid-Restoration','DeathKnight-Blood','Paladin-Protection','Priest-Holy','Druid-Feral','Monk-Windwalker','Warrior-Protection','Monk-Mistweaver','Mage-Fire','Warlock-Affliction','Shaman-Elemental','Priest-Shadow',}; local provider = {region='CN',realm='激流堡',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aiden:BAABLAAFFH8GAAMBAAIIJRbVIwCAAAABAAIIyRDVIwCAAAACAAIIJRammgBAAAAAAA==.',Ca='Cake:BAAALAAECgQIBAAAAA==.',Dr='Dryads:BAAALAADCgEIAQAAAA==.',Fi='Firsthunter:BAACLAAFFH8GAAIDAAIIOQs4FQCGAAADAAIIOQs4FQCGAAAsAAQKfysAAwMACAheHB8IAMQCAAMACAheHB8IAMQCAAQABggSCxFFADkBAAAA.',Ia='Iamjudy:BAAALAAECgQIBAAAAA==.',Jz='Jzdblz:BAACLAAFFH8IAAIFAAII+BcgNACjAAAFAAII+BcgNACjAAAsAAQKfyAAAgUABgg5JLY5AHgCAAUABgg5JLY5AHgCAAAA.',La='Lastoneday:BAABLAAFFH8IAAIGAAgIHQywCQCsAQAGAAgIHQywCQCsAQAAAA==.',Li='Living:BAACLAAFFH8KAAMHAAIIlBAhHwCOAAAHAAIIlBAhHwCOAAAIAAIILw6vCABtAAAsAAQKfywAAwcACAhEGgAfAGkCAAcACAhEGgAfAGkCAAgABggDGKMTAKYBAAAA.',Lo='Lovelesslisa:BAAALAAECggIEgAAAA==.',Lu='Lupus:BAAALAAFFAIIAgAAAA==.',Mf='Mfbee:BAAALAAECgEIAQAAAA==.',Na='Nature:BAAALAAECgYIEgAAAA==.',Ne='Neverrepent:BAAALAAECgEIAQABLAAFFAgIBAAJAAAAAA==.',Op='Opk:BAAALAAECgYIDgAAAA==.',Pl='Playeruxjmte:BAAALAAECgMIAwAAAA==.',Ra='Rainoverme:BAABLAAFFH8LAAIKAAUI5hBKKgATAQAKAAUI5hBKKgATAQAAAA==.',Sc='Scilence:BAABLAAFFH8IAAIEAAgI3B0dAgB7AgAEAAgI3B0dAgB7AgAAAA==.',Sh='Sheldor:BAABLAAECn8bAAIFAAYIiBsmMwCMAQAFAAYIiBsmMwCMAQAAAA==.',Si='Silversky:BAACLAAFFH8GAAILAAIIOh44FgCrAAALAAIIOh44FgCrAAAsAAQKfxQAAwsABwhKHroWAFcCAAsABwhKHroWAFcCAAwAAQgiIKNsAVwAAAAA.',Th='Thegray:BAABLAAECn8YAAINAAYIpxaAMACgAQANAAYIpxaAMACgAQAAAA==.',Wo='Wonn:BAABLAAFFH8IAAIOAAgIyBSKCgCtAQAOAAgIyBSKCgCtAQAAAA==.',Za='Zaknafein:BAABLAAFFH8IAAIPAAIIZxnjbgCRAAAPAAIIZxnjbgCRAAAAAA==.',['一毛']='一毛子亥:BAABLAAFFH8IAAIQAAIIwQzlXgB+AAAQAAIIwQzlXgB+AAAAAA==.',['三叔']='三叔公:BAAALAAECgYIEQAAAA==.',['上帝']='上帝灬之手:BAAALAAECgMIAwAAAA==.',['不为']='不为:BAAALAAFFAEIAQAAAA==.',['不守']='不守鸟德:BAAALAAECgUIBQAAAA==.',['不老']='不老神仙:BAABLAAFFH8GAAIRAAIIHgWZWwA6AAARAAIIHgWZWwA6AAAAAA==.',['丨叶']='丨叶知秋:BAAALAADCgMIAwAAAA==.',['丨远']='丨远坂丶凛丨:BAAALAAFFAQIBAAAAA==.',['丫丫']='丫丫:BAABLAAFFH8FAAIHAAUIswZWHgDUAAAHAAUIswZWHgDUAAAAAA==.',['丰川']='丰川祥子:BAAALAADCgcIBwAAAA==.',['丶七']='丶七堇年华:BAABLAAFFH8IAAIPAAIIwRTYggBEAAAPAAIIwRTYggBEAAAAAA==.',['丶北']='丶北极:BAAALAAECgUIBQAAAA==.丶北极丨德:BAAALAADCgEIAQAAAA==.丶北极丨法:BAAALAAECgYIBgAAAA==.丶北极丨牧:BAAALAAECgcIDQAAAA==.丶北极丨骑:BAAALAAECgYIDAAAAA==.',['丶红']='丶红烧排骨:BAAALAAECgYIDgAAAA==.',['丿獨']='丿獨家丶記憶:BAABLAAFFH8KAAMMAAgIZBXBFgCaAQAMAAYIjhjBFgCaAQALAAQImhXjFAA/AQAAAA==.',['久旱']='久旱逢甘霖:BAAALAADCgUIBQAAAA==.',['乖宝']='乖宝宝小语:BAAALAADCgQIBAAAAA==.',['九唔']='九唔搭八:BAAALAADCggICAAAAA==.',['九死']='九死一生:BAAALAAECgIIAgAAAA==.',['于很']='于很横狗蛋:BAABLAAFFH8IAAISAAMIzwtPTQCFAAASAAMIzwtPTQCFAAAAAA==.',['亚顿']='亚顿之毛:BAAALAAFFAYIAgAAAA==.',['伊利']='伊利:BAACLAAFFH8TAAISAAQI6gvsRADAAAASAAQI6gvsRADAAAAsAAQKfxkAAhIACAjBGTUgAOYBABIACAjBGTUgAOYBAAAA.伊利达雷:BAABLAAFFH8IAAIFAAgIZRzbBACWAgAFAAgIZRzbBACWAgAAAA==.伊利达雷斯:BAAALAAECgUIBQAAAA==.',['低调']='低调的安静:BAAALAAECgQIBAAAAA==.',['保加']='保加利亚妖王:BAABLAAFFH8FAAITAAMI/QAFMwBuAAATAAMI/QAFMwBuAAAAAA==.',['八块']='八块腹肌:BAAALAAECgYIDAAAAA==.',['冠死']='冠死以冕:BAABLAAECn8ZAAIUAAYIdhbXFQAqAQAUAAYIdhbXFQAqAQABLAAFFAIIDAATAAoPAA==.',['冰斓']='冰斓:BAAALAADCgIIAgAAAA==.',['冰雪']='冰雪葬滿地傷:BAAALAADCgIIAgAAAA==.',['冰霜']='冰霜之心:BAABLAAFFH8pAAIPAAYIviX9CwD7AQAPAAYIviX9CwD7AQAAAA==.',['冷血']='冷血照:BAAALAAECgEIAQAAAA==.',['列王']='列王的意愿:BAAALAAECggICAAAAA==.',['加加']='加加:BAAALAAECgYIBgAAAA==.',['劲发']='劲发江潮落:BAAALAAECgYIDAABLAAFFAIIDAATAAoPAA==.',['北极']='北极的巨人:BAAALAAECgYIEgAAAA==.',['千斤']='千斤顶:BAAALAAECgIIAgAAAA==.',['卤蛋']='卤蛋:BAAALAAECgUIBQAAAA==.',['卷心']='卷心菜:BAABLAAFFH8GAAIQAAIIfyJ1MwC7AAAQAAIIfyJ1MwC7AAAAAA==.',['历战']='历战王煌雷龙:BAABLAAECn8lAAIBAAgIMxZ5MAADAgABAAgIMxZ5MAADAgAAAA==.',['叉棍']='叉棍二零二四:BAAALAAECgYICgAAAA==.',['双花']='双花大红棍:BAAALAADCgEIAQAAAA==.',['双魚']='双魚理:BAABLAAFFH8GAAIQAAIIgCTKPQDNAAAQAAIIgCTKPQDNAAAAAA==.',['取名']='取名困难症:BAAALAAECggICAAAAA==.',['召唤']='召唤职业:BAAALAAECgYICgAAAA==.',['史伐']='史伐龙:BAAALAADCggICAAAAA==.',['呜呜']='呜呜灵:BAAALAAFFAQIBAAAAA==.',['咻咻']='咻咻:BAAALAADCgIIAgAAAA==.',['哈雷']='哈雷顶真:BAAALAAECgEIAQAAAA==.',['喋得']='喋得杯落:BAAALAADCgIIAgAAAA==.',['嚣傻']='嚣傻:BAAALAAECgMIAwAAAA==.',['土疙']='土疙瘩萨满妹:BAAALAAECgYIBgAAAA==.',['圣剑']='圣剑缘缘:BAAALAAFFAEIAQAAAA==.',['大主']='大主教伊瑞尓:BAAALAAECgYIBwAAAA==.',['大头']='大头杨杨:BAAALAAECgcICAAAAA==.',['天悬']='天悬星河:BAABLAAFFH8GAAIVAAIIsgyQGQBzAAAVAAIIsgyQGQBzAAAAAA==.',['天涯']='天涯墨客:BAAALAAECgIIAgAAAA==.',['头上']='头上有犄角:BAABLAAECn8gAAMOAAgIRA+gDQCDAQAOAAgIRA+gDQCDAQANAAQIbAtcKQCOAAABLAAFFAIIDAATAAoPAA==.',['奈黎']='奈黎荫:BAAALAAFFAYIAgABLAAFFAgIDQAWAHkaAA==.',['奥利']='奥利奥炒田螺:BAAALAAECgYIAwAAAA==.',['女女']='女女我大晒:BAAALAAECgYIEQAAAA==.',['女王']='女王:BAABLAAFFH8HAAIRAAUI7hSAJABLAQARAAUI7hSAJABLAQAAAA==.',['女神']='女神:BAAALAAFFAIIAgAAAA==.',['奶白']='奶白色的雪子:BAABLAAFFH8GAAIFAAYICBX8HgCGAQAFAAYICBX8HgCGAQAAAA==.',['娜时']='娜时丨枫起:BAAALAADCgMIAwAAAA==.',['宫园']='宫园丶薰:BAACLAAFFH8TAAQHAAUI7hKdGgABAQAHAAUI7hKdGgABAQAXAAEIAwhHDgBCAAAIAAIIzBPsDQAsAAAsAAQKfyEAAwcACAhfHYkiAE8CAAcACAhfHYkiAE8CAAgAAwjzBQ8yAGYAAAAA.',['寂寞']='寂寞一根烟:BAABLAAECn8jAAICAAYI8hr7bgBlAQACAAYI8hr7bgBlAQAAAA==.',['小偷']='小偷小摸:BAAALAADCgcIBwAAAA==.',['小吴']='小吴没烦恼:BAAALAAFFAQIBAAAAA==.',['小峻']='小峻峻:BAABLAAFFH8GAAIKAAII7wyPUwBpAAAKAAII7wyPUwBpAAAAAA==.',['小铁']='小铁:BAABLAAFFH8GAAIMAAYI/wTbMwDjAAAMAAYI/wTbMwDjAAAAAA==.',['小鬼']='小鬼们给我上:BAAALAAECgEIAQAAAA==.',['小鸡']='小鸡:BAAALAAFFAIIBAAAAA==.',['小鹿']='小鹿妈妈:BAABLAAFFH8bAAILAAYI6RynCwDJAQALAAYI6RynCwDJAQAAAA==.',['尛基']='尛基萨:BAAALAAECggICAAAAA==.',['就叫']='就叫我阿牛吧:BAABLAAFFH8HAAIMAAII0BQlPAChAAAMAAII0BQlPAChAAAAAA==.',['山哥']='山哥:BAAALAAECgEIAQAAAA==.',['山田']='山田孝之:BAAALAAECgUIBQAAAA==.',['巧克']='巧克力丶楪祈:BAABLAAFFH8IAAIFAAIIEhCkSgCRAAAFAAIIEhCkSgCRAAAAAA==.',['巴斯']='巴斯罗宾:BAAALAAECgEIAQAAAA==.',['巴特']='巴特:BAABLAAFFH8IAAICAAYI+x22IQCrAQACAAYI+x22IQCrAQAAAA==.',['开水']='开水泡面:BAAALAAECgIIAgAAAA==.',['彼岸']='彼岸花开成海:BAAALAAECgIIAgAAAA==.',['徐夕']='徐夕瑶:BAAALAAECgUIDwAAAA==.',['德才']='德才兼备:BAAALAAECgYIBgAAAA==.',['德拉']='德拉罗萨:BAABLAAFFH8HAAITAAMIqBJZNACYAAATAAMIqBJZNACYAAAAAA==.',['忆梦']='忆梦:BAABLAAECn8cAAIVAAgItRozDgDEAQAVAAgItRozDgDEAQAAAA==.',['怜苍']='怜苍生:BAABLAAECn8UAAMGAAYISxNcJgBeAQAGAAYISxNcJgBeAQAYAAIIwAUvZgBIAAAAAA==.',['怨影']='怨影:BAAALAAECgYIBgAAAA==.',['怪侠']='怪侠一撮毛:BAAALAAECgIIAgAAAA==.',['恶意']='恶意触碰:BAACLAAFFH8KAAIVAAIIXBaTEgCKAAAVAAIIXBaTEgCKAAAsAAQKfzAAAhUACAh5H4oHADECABUACAh5H4oHADECAAAA.',['恶魔']='恶魔法则:BAAALAADCggICAAAAA==.',['惊蛰']='惊蛰:BAAALAAECgUIBQAAAA==.',['惠山']='惠山游侠:BAAALAAECgYICwAAAA==.惠山虚灵:BAAALAAFFAIIAgAAAA==.惠山阿喜:BAAALAAFFAIIAgAAAA==.惠山阿福:BAAALAAECgYIBgAAAA==.惠山阿虎:BAAALAAECgYICgAAAA==.',['惩戒']='惩戒之心:BAABLAAFFH8cAAIMAAUI3CWYDwBNAQAMAAUI3CWYDwBNAQABLAAFFAYIKQAPAL4lAA==.',['我心']='我心中有佛:BAAALAAECgIIAgAAAA==.',['我要']='我要做艾姆替:BAAALAADCgQIBAAAAA==.',['战天']='战天使:BAAALAAFFAIIAwAAAA==.',['战忽']='战忽局助理:BAAALAAECgQIBAAAAA==.',['打不']='打不过就躺:BAAALAADCgcIBwAAAA==.',['打铁']='打铁的妹子:BAABLAAFFH8FAAIMAAMI9AMHeQA4AAAMAAMI9AMHeQA4AAAAAA==.',['抗不']='抗不住:BAABLAAECn8YAAIZAAgIIRreGABpAgAZAAgIIRreGABpAgAAAA==.',['抱蕃']='抱蕃茄:BAACLAAFFH8HAAITAAUI7AyMIgAIAQATAAUI7AyMIgAIAQAsAAQKfxoAAhMACAjaG5IMAIUCABMACAjaG5IMAIUCAAAA.',['撕家']='撕家可可:BAAALAAECgYIDQAAAA==.',['撼地']='撼地者:BAACLAAFFH8MAAIKAAIIVgcqYABgAAAKAAIIVgcqYABgAAAsAAQKfxsAAgoACAgxER1tAKkBAAoACAgxER1tAKkBAAAA.',['斋啡']='斋啡:BAACLAAFFH8KAAIaAAIIRxAREwCCAAAaAAIIRxAREwCCAAAsAAQKf0AAAhoACAh1FMAPAK0BABoACAh1FMAPAK0BAAAA.',['斩天']='斩天灭地:BAAALAADCggICAAAAA==.',['无忌']='无忌无畏:BAAALAAECgYIDAAAAA==.',['无敌']='无敌咕咕大王:BAAALAAECgYIBgAAAA==.',['无聊']='无聊的小白:BAAALAAECgYIBwAAAA==.',['日月']='日月同辉:BAAALAAFFAEIAQAAAA==.',['明光']='明光:BAABLAAFFH8IAAICAAQIgxh5WQDkAAACAAQIgxh5WQDkAAAAAA==.',['明夜']='明夜:BAABLAAFFH8GAAICAAYICxZXMQB0AQACAAYICxZXMQB0AQAAAA==.',['明宇']='明宇:BAABLAAFFH8PAAICAAYIEB6RIQCsAQACAAYIEB6RIQCsAQAAAA==.',['明意']='明意:BAABLAAFFH8MAAICAAYIMRzuKACQAQACAAYIMRzuKACQAQAAAA==.',['明瑜']='明瑜:BAABLAAFFH8FAAICAAUI3RnUQQBBAQACAAUI3RnUQQBBAQAAAA==.',['明语']='明语:BAABLAAFFH8MAAICAAYIPh36IACuAQACAAYIPh36IACuAQAAAA==.',['明逸']='明逸:BAABLAAFFH8GAAICAAYIwRoYJAChAQACAAYIwRoYJAChAQAAAA==.',['明雨']='明雨:BAABLAAFFH8QAAICAAYIaRg3LQCBAQACAAYIaRg3LQCBAQAAAA==.',['春风']='春风惹细柳:BAAALAAECgEIAQAAAA==.',['時丶']='時丶雨:BAACLAAFFH83AAQVAAYIBhv2BACWAQAVAAYIUhr2BACWAQAMAAQIORc6MwDoAAALAAMI+gykEQDTAAAsAAQKfyIABAsACAgAFDI5AH8BAAsABgiAFDI5AH8BABUABwh7ETo3AGkBAAwAAwi3Efw1AcUAAAAA.',['晴川']='晴川风絮:BAAALAAECgYIBwAAAA==.',['暗影']='暗影突击鹅:BAAALAADCgUIBQAAAA==.',['月光']='月光罗刹:BAAALAADCgcIBwAAAA==.',['有邪']='有邪:BAAALAAECgYICQAAAA==.',['村上']='村上春树:BAAALAAECgYIBgAAAA==.',['村雨']='村雨:BAABLAAFFH8GAAIIAAII5xNmBwB5AAAIAAII5xNmBwB5AAABLAAFFAYINwAVAAYbAA==.',['杠开']='杠开:BAACLAAFFH8XAAMbAAcIyRlRAgCsAQAQAAcI2xaXFADXAQAbAAYIRhlRAgCsAQAsAAQKfxcAAxsABgjrHLYHAO4BABsABgjUG7YHAO4BABAABgiuFJs1ADoBAAAA.',['林浩']='林浩:BAAALAAECgYIEQAAAA==.',['树影']='树影丶婆娑:BAABLAAFFH8GAAISAAYIiQ9LLgBhAQASAAYIiQ9LLgBhAQAAAA==.',['梨落']='梨落春意晚:BAAALAAECgUIBQAAAA==.',['棋棋']='棋棋老师:BAAALAAECgYIBgAAAA==.',['毕方']='毕方:BAAALAAECgYIDAAAAA==.',['水城']='水城不知火:BAAALAAECgYIEAAAAA==.',['水淡']='水淡风清:BAAALAADCgYIBgAAAA==.',['永朱']='永朱波波子:BAABLAAFFH8gAAIFAAgItR2mBACcAgAFAAgItR2mBACcAgAAAA==.',['沐雨']='沐雨橙风:BAAALAADCgUIBQAAAA==.',['法爷']='法爷没得吃:BAAALAADCgEIAQAAAA==.',['泰蘭']='泰蘭德丶風暴:BAAALAADCgMIAwAAAA==.',['洋芋']='洋芋:BAAALAADCgYIBgAAAA==.',['海拔']='海拔一米三:BAAALAAFFAIIAgAAAA==.',['清凌']='清凌凌的水:BAAALAAECgIIAwAAAA==.',['滋电']='滋电之友友:BAAALAAECgcIBwAAAA==.',['灬索']='灬索利达尔灬:BAAALAAECgYICwAAAA==.',['炽天']='炽天使炎:BAABLAAFFH8KAAIQAAIIpRK4UQCPAAAQAAIIpRK4UQCPAAAAAA==.',['烟花']='烟花伊冷:BAAALAAECgQIBAAAAA==.',['烤年']='烤年糕:BAAALAADCgIIAgAAAA==.',['熊凶']='熊凶熊:BAAALAAECgYIBwAAAA==.',['熊猫']='熊猫人重生:BAAALAAECgYIBwAAAA==.',['牛胡']='牛胡子:BAAALAAECgQIBAAAAA==.',['牧羊']='牧羊人:BAAALAAECgUIBQAAAA==.',['狡猾']='狡猾的部落猪:BAACLAAFFH8KAAISAAIIDCM/LgDIAAASAAIIDCM/LgDIAAAsAAQKfzAAAxIACAi4I2AOAC4DABIACAi4I2AOAC4DABwAAgjKIiAmALcAAAAA.',['狡诈']='狡诈的部落猪:BAABLAAFFH8GAAISAAYI5xzOCwBDAgASAAYI5xzOCwBDAgAAAA==.',['猫爷']='猫爷:BAAALAAECgYIBgAAAA==.',['献血']='献血绽放:BAAALAAFFAIIAgAAAA==.',['甘礼']='甘礼两:BAAALAAECgYIDgAAAA==.',['番茄']='番茄斯皮尔斯:BAAALAADCgYIFAAAAA==.',['疯狂']='疯狂萝卜:BAABLAAFFH8GAAIZAAIIVRLdHgCAAAAZAAIIVRLdHgCAAAAAAA==.',['白菜']='白菜萝卜:BAABLAAFFH8GAAIIAAII8xuMBACnAAAIAAII8xuMBACnAAAAAA==.',['百宠']='百宠王:BAAALAAECgYIBgAAAA==.',['皇旸']='皇旸惊霆:BAAALAAFFAIIBAAAAA==.',['盖一']='盖一伦:BAAALAAECgUIBwAAAA==.',['直流']='直流发电机:BAAALAADCggICAAAAA==.',['真宫']='真宫寺樱:BAAALAAFFAQIBAAAAA==.',['矮胖']='矮胖小猪:BAAALAAECgYIBgAAAA==.',['神秘']='神秘纽头仁友:BAACLAAFFH8JAAICAAMITBkdZgCdAAACAAMITBkdZgCdAAAsAAQKfxQAAgIABwjmI6gXAG8CAAIABwjmI6gXAG8CAAEsAAUUBQgVAA4AbR8A.',['秘法']='秘法缘缘:BAABLAAECn8sAAIQAAYI3wuURQD0AAAQAAYI3wuURQD0AAAAAA==.',['筱雪']='筱雪精灵:BAAALAAECgYIEQAAAA==.',['简饅']='简饅頭:BAAALAADCgUIBQAAAA==.',['米饭']='米饭:BAABLAAFFH8TAAIdAAUIFBZDIgAwAQAdAAUIFBZDIgAwAQAAAA==.',['素雨']='素雨吃鱼:BAAALAAECgEIAQAAAA==.',['红尘']='红尘素衣:BAAALAAECgYIBgAAAA==.',['纳兰']='纳兰若雪:BAAALAAECgUICAAAAA==.',['美丽']='美丽不冻人:BAAALAAECgIIAgAAAA==.',['老薛']='老薛的劣人:BAAALAAFFAYIBAAAAA==.',['老蚂']='老蚂蚁:BAAALAADCgQIBAAAAA==.',['耶格']='耶格:BAAALAAECgIIAwAAAA==.',['联盟']='联盟战兽:BAAALAAECgQIBAAAAA==.',['肥猫']='肥猫氏某某:BAABLAAFFH8OAAIKAAII3ROFUwB0AAAKAAII3ROFUwB0AAAAAA==.',['膀大']='膀大腰圆:BAAALAAECgIIAgAAAA==.',['舒华']='舒华新力啤:BAAALAAECgMIAwAAAA==.',['芝士']='芝士雪豹:BAACLAAFFH8GAAIRAAIIVgXOXAA5AAARAAIIVgXOXAA5AAAsAAQKfxoAAhEACAiXEaguAKABABEACAiXEaguAKABAAAA.',['花豆']='花豆神月大人:BAAALAAFFAIIAwAAAA==.',['茧茧']='茧茧:BAAALAAFFAIIAgAAAA==.',['荆棘']='荆棘螺旋:BAAALAAECgYICAAAAA==.',['菠萝']='菠萝包:BAAALAAECggIDAAAAA==.',['萎缩']='萎缩相当萎缩:BAAALAAECgYICgAAAA==.',['落英']='落英清影:BAABLAAECn8cAAMCAAYIthzibABpAQACAAYIthzibABpAQABAAYIzwyzgQDWAAAAAA==.',['蒙恩']='蒙恩:BAAALAAECggICAAAAA==.',['蓝色']='蓝色精灵:BAAALAAECgUIBQAAAA==.',['虞山']='虞山竹叶青:BAAALAADCgYIBgAAAA==.',['蚂蚁']='蚂蚁骑士:BAAALAADCgMIAwAAAA==.',['蝶之']='蝶之影:BAACLAAFFH8KAAIeAAII1RbIGgCeAAAeAAII1RbIGgCeAAAsAAQKfyAAAh4ACAj9HFAZAKMCAB4ACAj9HFAZAKMCAAAA.蝶之舞:BAABLAAECn8YAAIMAAYIrRk7kADQAQAMAAYIrRk7kADQAQAAAA==.',['蝶羽']='蝶羽清影:BAAALAAFFAIIBAAAAA==.',['西瓜']='西瓜冰美式:BAAALAAECgQIBAAAAA==.',['见猎']='见猎心喜:BAAALAADCgYIBgAAAA==.',['谢谢']='谢谢在:BAAALAADCgMIAwAAAA==.',['谨记']='谨记泪琳:BAAALAADCgEIAQAAAA==.谨记闷死人咯:BAAALAAECgYIDAAAAA==.',['负载']='负载均衡:BAABLAAECn8fAAICAAcIiyWTFQB8AgACAAcIiyWTFQB8AgAAAA==.',['赫萝']='赫萝赫萝:BAABLAAFFH8IAAITAAcIJwxnFwB4AQATAAcIJwxnFwB4AQAAAA==.',['起手']='起手就无敌:BAABLAAFFH8IAAIMAAII8h0wMwCoAAAMAAII8h0wMwCoAAAAAA==.',['轩轩']='轩轩呀:BAABLAAFFH8HAAIPAAYIZhZ2LACHAQAPAAYIZhZ2LACHAQAAAA==.',['迪客']='迪客永恒:BAAALAADCgIIAgAAAA==.',['邪神']='邪神:BAAALAAECgIIAgAAAA==.',['邪能']='邪能水晶总代:BAACLAAFFH8gAAIFAAYItSLAEQDTAQAFAAYItSLAEQDTAQAsAAQKfyMAAgUACAgRJtMCAIIDAAUACAgRJtMCAIIDAAAA.',['部落']='部落永存:BAAALAADCgIIAgAAAA==.',['键盘']='键盘的烟灰:BAABLAAECn8UAAIPAAYI1hhJRwBtAQAPAAYI1hhJRwBtAQAAAA==.',['门萨']='门萨科多:BAAALAAECgEIAQAAAA==.门萨黛丽丝:BAAALAAFFAEIAQAAAA==.',['间桐']='间桐丶樱:BAAALAAECgYICQAAAA==.',['阴霾']='阴霾暗霜:BAAALAAECggICAAAAA==.',['阿哒']='阿哒:BAAALAAFFAIIAgAAAA==.',['阿尔']='阿尔托利雅:BAAALAAFFAIIBAAAAA==.阿尔法:BAAALAAFFAIIBAAAAA==.',['雪匕']='雪匕丶透心凉:BAABLAAFFH8GAAIFAAYIHAFyagAzAAAFAAYIHAFyagAzAAAAAA==.',['靑木']='靑木常春:BAAALAAECgYIBgAAAA==.',['青椒']='青椒炒肉絲:BAAALAADCgEIAQAAAA==.',['青菜']='青菜胖萝卜:BAAALAAECgUIBQAAAA==.',['非壕']='非壕勿扰:BAAALAADCgQIBAAAAA==.',['顽山']='顽山:BAABLAAFFH8LAAICAAYI7hqrJwCUAQACAAYI7hqrJwCUAQAAAA==.',['顽火']='顽火:BAABLAAFFH8SAAICAAYIABqlGgAxAQACAAYIABqlGgAxAQAAAA==.',['顽电']='顽电:BAABLAAFFH8MAAICAAYIahh4KQCOAQACAAYIahh4KQCOAQAAAA==.',['顽皮']='顽皮:BAABLAAFFH8MAAICAAYIgRknLwB7AQACAAYIgRknLwB7AQAAAA==.',['顽闪']='顽闪:BAABLAAFFH8HAAICAAYIEhWyMgBvAQACAAYIEhWyMgBvAQAAAA==.',['顽雷']='顽雷:BAABLAAFFH8FAAICAAUIAhUqMQDDAAACAAUIAhUqMQDDAAAAAA==.',['顽鸣']='顽鸣:BAABLAAFFH8JAAICAAYI7hd1LgB9AQACAAYI7hd1LgB9AQAAAA==.',['颖隳']='颖隳萧萧:BAAALAAECgEIAgAAAA==.',['风寂']='风寂寞雨逍遥:BAAALAAECgMIAwAAAA==.',['风御']='风御者:BAAALAAECgMIAwAAAA==.',['风暴']='风暴之灵:BAABLAAFFH8GAAIaAAIIagZkGABbAAAaAAIIagZkGABbAAAAAA==.',['飒飒']='飒飒水:BAAALAAECgYIBgAAAA==.',['飘叶']='飘叶:BAAALAAECggICAAAAA==.',['魂守']='魂守之矢:BAACLAAFFH8gAAMCAAYIHhk8LQCBAQACAAYIHhk8LQCBAQABAAIIAAafGQA4AAAsAAQKfyEAAwIACAhrIH0kAMYCAAIACAhrIH0kAMYCAAEAAgi+EOopAEsAAAAA.',['魚龍']='魚龍舞:BAAALAAECggIDwAAAA==.',['鱼龙']='鱼龙万千:BAAALAADCgEIAQAAAA==.',['鲜血']='鲜血小骑:BAAALAAFFAIIAgAAAA==.',['麻将']='麻将天才:BAAALAAFFAIIAgAAAA==.',['黑帅']='黑帅壹号:BAAALAAECgQIBwAAAA==.',['黑暗']='黑暗使者:BAAALAAECgUIBQAAAA==.',['黑潮']='黑潮:BAAALAAECgIIAgABLAAFFAYINwAVAAYbAA==.',['龙骑']='龙骑士:BAAALAAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end