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
 local lookup = {'Rogue-Assassination','Paladin-Retribution','DeathKnight-Frost','Druid-Restoration','Paladin-Protection','Mage-Arcane','Priest-Holy','DemonHunter-Vengeance','Shaman-Restoration','Shaman-Elemental','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Fury','DemonHunter-Havoc','Druid-Balance','DeathKnight-Unholy','Druid-Feral','Mage-Frost','Druid-Guardian','Warrior-Protection','DeathKnight-Blood',}; local provider = {region='CN',realm='阿卡玛',name='CN',type='weekly',zone=44,date='2025-12-09',data={Di='Dio:BAAALAADCgYIBgAAAA==.',Do='Dokidoki:BAAALAAECgcIBQAAAA==.',Dy='Dym:BAAALAAECgUIAgAAAA==.',Mo='Morty:BAAALAAECggIBQAAAA==.',Sa='Samjun:BAACLAAFFH8PAAIBAAMI7grFFgCIAAABAAMI7grFFgCIAAAsAAQKfxoAAgEACAiqEq4LAKoBAAEACAiqEq4LAKoBAAAA.',Sh='Shadowfiend:BAACLAAFFH8YAAICAAUILx88GQD4AAACAAUILx88GQD4AAAsAAQKfx0AAgIABwiLHnV6APUBAAIABwiLHnV6APUBAAAA.',Ta='Tansy:BAAALAADCgIIAgAAAA==.',To='Toot:BAAALAADCgYIDAAAAA==.',Wa='Wakuwaku:BAAALAAECgMIAwAAAA==.',['一土']='一土推木机:BAAALAAFFAMIAwAAAA==.',['一小']='一小猎一:BAAALAADCgQIBgAAAA==.',['一斩']='一斩杀一:BAAALAAECgQIBAAAAA==.',['七月']='七月辛:BAAALAAECgMIAwAAAA==.',['丨狼']='丨狼头丨:BAABLAAFFH8MAAIDAAIIzhOXZwCUAAADAAIIzhOXZwCUAAAAAA==.',['二二']='二二三四:BAAALAAECgIIAgABLAAFFAIIBgAEACcPAA==.',['云溪']='云溪仙子:BAAALAAECgYICQAAAA==.',['云烟']='云烟贵酒:BAABLAAECn8jAAMCAAcIsBzhKgDqAQACAAcIMxzhKgDqAQAFAAYIpBjuFQBsAQAAAA==.',['云飞']='云飞飞丶丶:BAAALAAECgUIBgAAAA==.',['亦杨']='亦杨宝贝点点:BAACLAAFFH8NAAICAAYIOAZ7LwATAQACAAYIOAZ7LwATAQAsAAQKfx8AAgIABwhuE8qcALwBAAIABwhuE8qcALwBAAAA.',['人來']='人來瘋:BAAALAAECggICwAAAA==.',['传说']='传说骑士:BAAALAAECgQIBAAAAA==.',['伤心']='伤心女人:BAABLAAFFH8IAAIGAAIICwXCXgB+AAAGAAIICwXCXgB+AAAAAA==.',['你的']='你的牢牧:BAABLAAFFH8GAAIHAAIIrBFkPgBvAAAHAAIIrBFkPgBvAAAAAA==.',['兄弟']='兄弟伙:BAAALAAECgYICAAAAA==.',['克莱']='克莱文:BAAALAAECgYIEgAAAA==.',['典型']='典型的臭屁:BAAALAAECgEIAQAAAA==.',['内个']='内个带孩子的:BAAALAADCgQIBAAAAA==.',['冰霜']='冰霜小骷髅:BAAALAAECgMIBAABLAAFFAIIBQAHAPwSAA==.',['凡尘']='凡尘丶若梦:BAAALAAECgIIAgAAAA==.',['凤舞']='凤舞九天:BAAALAAECgYIBwAAAA==.',['凯撒']='凯撒尔曼:BAAALAAFFAIIAgAAAA==.',['凸守']='凸守丶丹生谷:BAAALAAECgUIBQAAAA==.',['刘肥']='刘肥:BAAALAAECggICAAAAA==.',['刺客']='刺客信条:BAAALAADCgUIBQAAAA==.',['半句']='半句人之怒:BAABLAAFFH8FAAIIAAIIAwPaGgAfAAAIAAIIAwPaGgAfAAABLAAFFAcILwACAGUkAA==.',['双刀']='双刀灬流:BAAALAAFFAIIAgAAAA==.',['叢雨']='叢雨:BAABLAAFFH8OAAICAAYI1hjXAwA1AgACAAYI1hjXAwA1AgAAAA==.',['吃我']='吃我一拳:BAAALAAFFAIIAgAAAA==.',['吉姆']='吉姆干爹:BAAALAAECgYIDAAAAA==.',['吉川']='吉川啵啵:BAAALAAFFAMIBAAAAA==.',['吟荡']='吟荡小喇叭:BAAALAAECgcICQAAAA==.',['和光']='和光同尘:BAACLAAFFH8GAAIJAAII5w4wWgBkAAAJAAII5w4wWgBkAAAsAAQKfycAAwkACAiIF9o4AHsBAAkACAiIF9o4AHsBAAoABgiwDEBPANYAAAAA.',['哥谭']='哥谭小绵羊:BAAALAAECgEIAQAAAA==.',['啊小']='啊小叮当:BAABLAAFFH8IAAILAAYICh6eNABuAQALAAYICh6eNABuAQAAAA==.',['啊手']='啊手动阀:BAAALAAFFAIIBAAAAA==.',['啤酒']='啤酒兔:BAABLAAFFH8cAAILAAYIRhUvNQBtAQALAAYIRhUvNQBtAQAAAA==.',['啰完']='啰完了吗:BAAALAAFFAIIAgAAAA==.',['围观']='围观群众贰号:BAAALAAECgYIBAAAAA==.',['囷囷']='囷囷:BAAALAAECggICAAAAA==.',['圆头']='圆头耄耋:BAAALAAECgMIAwAAAA==.',['圣主']='圣主:BAAALAADCgYIBgAAAA==.',['圣光']='圣光狂想曲:BAACLAAFFH8ZAAICAAYI/xUPHACCAQACAAYI/xUPHACCAQAsAAQKfxQAAgIACAgVHJFWAEACAAIACAgVHJFWAEACAAAA.',['圣神']='圣神之锤:BAAALAADCgMIAwAAAA==.',['城市']='城市猎者:BAAALAAECgEIAQAAAA==.',['夜魑']='夜魑:BAAALAADCgYIBgAAAA==.',['大唐']='大唐歌妃:BAABLAAFFH8GAAIJAAYI5ADAbABPAAAJAAYI5ADAbABPAAAAAA==.',['大条']='大条:BAAALAAECgYIBgAAAA==.',['大水']='大水猫:BAAALAAECgYIDgAAAA==.',['天神']='天神丶使徒:BAAALAAECgYICgAAAA==.',['头好']='头好痒丶:BAAALAAECggICAAAAA==.',['妖娃']='妖娃娃:BAAALAADCgEIAQAAAA==.',['娘子']='娘子:BAABLAAFFH8MAAIJAAIIRyNZPAC1AAAJAAIIRyNZPAC1AAAAAA==.',['宇髓']='宇髓天元:BAABLAAFFH8LAAICAAYI/gaiLAAmAQACAAYI/gaiLAAmAQAAAA==.',['小丶']='小丶小妹:BAABLAAFFH8GAAIDAAIIIRaLXwCYAAADAAIIIRaLXwCYAAAAAA==.',['小战']='小战:BAAALAADCgEIAQAAAA==.',['小星']='小星点点:BAAALAAECggICAAAAA==.',['小白']='小白的死骑:BAABLAAFFH8GAAIDAAIInQlyjQB7AAADAAIInQlyjQB7AAAAAA==.',['岁月']='岁月朦胧:BAACLAAFFH8LAAICAAUIFg5QMQAEAQACAAUIFg5QMQAEAQAsAAQKfxQAAgIABggzHpE2AL0BAAIABggzHpE2AL0BAAAA.',['帅气']='帅气伟伟:BAAALAAECgQIBgAAAA==.',['希尔']='希尔瓦纳斯:BAACLAAFFH8gAAMMAAYITSHKAgDVAQAMAAYITSHKAgDVAQALAAIIeRv+PQCpAAAsAAQKfxkAAgwABwjrJZ8LAAYDAAwABwjrJZ8LAAYDAAEsAAUUCAgOAAIA1hgA.',['幸好']='幸好有你:BAAALAADCgQIBAAAAA==.',['影子']='影子冷鋒:BAAALAAFFAQIBAAAAA==.',['德艺']='德艺又又馨:BAAALAADCgQIBAAAAA==.',['心急']='心急:BAAALAAFFAQIBAAAAA==.',['忍受']='忍受的是对方:BAAALAAECgYIBwAAAA==.',['怀瑾']='怀瑾握瑜:BAAALAAECgIIAgAAAA==.',['我跟']='我跟你拼了:BAAALAAECgYIBgAAAA==.',['战斗']='战斗爽:BAAALAADCgUICAAAAA==.',['手下']='手下败将:BAAALAAECggICAAAAA==.',['打我']='打我我就发财:BAAALAAECggIEAAAAA==.',['打猎']='打猎的小狐狸:BAACLAAFFH8NAAMLAAIIxReYVQCSAAALAAIIxReYVQCSAAAMAAEIQQByOwAUAAAsAAQKfxUAAwsABgihIeRSADgCAAsABgihIeRSADgCAAwAAwgZDumbAIIAAAAA.',['抬头']='抬头看月又沉:BAAALAAECgYIBgAAAA==.',['挥棒']='挥棒断情丝:BAABLAAECn8bAAMJAAcIfQ1bxQD7AAAJAAYISw1bxQD7AAAKAAEIOwxUfAAzAAAAAA==.',['撒塔']='撒塔妮亚:BAAALAAECgEIAQAAAA==.',['撼地']='撼地天残脚:BAAALAAECgYICQAAAA==.',['文西']='文西是只狗:BAAALAAECgIIAgAAAA==.',['斯威']='斯威夫特:BAAALAAECgYIBgAAAA==.',['日照']='日照砍王:BAABLAAECn8VAAINAAYIaRUwVgAUAQANAAYIaRUwVgAUAQAAAA==.',['春日']='春日无尾熊:BAAALAAECgcIBwAAAA==.',['晓丿']='晓丿小战:BAAALAAECgIIAgAAAA==.晓丿小骑:BAAALAAECgYIEgAAAA==.',['晴空']='晴空尐尐:BAAALAAFFAMIAwAAAA==.',['暗影']='暗影使徒:BAAALAAECgIIAgAAAA==.',['暴风']='暴风纹画:BAAALAAECgYICwAAAA==.',['曰久']='曰久剑人心:BAAALAAECgYICQAAAA==.',['月夜']='月夜归来:BAAALAAECggICAAAAA==.月夜黄昏:BAAALAAECgYIBgAAAA==.',['月轻']='月轻轻:BAAALAAFFAIIBAAAAA==.',['月隐']='月隐:BAABLAAFFH8cAAIOAAgIKyDLAwC7AgAOAAgIKyDLAwC7AgAAAA==.',['有医']='有医保的先上:BAAALAAFFAMIAwAAAA==.',['朦胧']='朦胧默默:BAAALAAECgYIBgAAAA==.',['杀手']='杀手皇后:BAAALAAFFAIIBAAAAA==.',['杀死']='杀死鲍比:BAAALAADCgQIBAAAAA==.',['林惊']='林惊羽:BAAALAAECgcIEwAAAA==.',['柒小']='柒小柒:BAAALAAECggICAAAAA==.',['棒冰']='棒冰:BAAALAAFFAIIAgAAAA==.',['橙多']='橙多多:BAAALAAECggICAAAAA==.',['欧尔']='欧尔莉亚:BAABLAAECn8lAAIMAAgIWBrxBwDtAQAMAAgIWBrxBwDtAQAAAA==.',['殛滅']='殛滅:BAAALAAECgYIBgAAAA==.',['毁天']='毁天灭地:BAAALAAFFAIIAgAAAA==.',['毒奶']='毒奶罐子:BAAALAADCgQIBAAAAA==.',['水晶']='水晶兰:BAAALAADCgYIBgAAAA==.',['治疗']='治疗链丢歪了:BAAALAAECgYIBgABLAAFFAIIBgAEACcPAA==.',['洛欣']='洛欣:BAACLAAFFH8GAAIEAAIIJw8MNgBqAAAEAAIIJw8MNgBqAAAsAAQKfxYAAwQABwgRGiwiAMYBAAQABwgRGiwiAMYBAA8AAgjBEmdSAG4AAAAA.',['流光']='流光映影:BAABLAAFFH8OAAIQAAUIlxHxBQA8AQAQAAUIlxHxBQA8AQAAAA==.',['浮尘']='浮尘:BAAALAAECgIIAgAAAA==.',['淡墨']='淡墨画须弥:BAABLAAFFH8VAAIHAAYIIhxADAAOAgAHAAYIIhxADAAOAgAAAA==.',['清羽']='清羽微笑:BAAALAADCgIIAgAAAA==.',['点点']='点点宝贝:BAABLAAFFH8NAAILAAYIagWSWgDoAAALAAYIagWSWgDoAAABLAAFFAYIDQACADgGAA==.',['烈焰']='烈焰凤凰雨:BAAALAAECgYIDAAAAA==.',['牛人']='牛人的信仰:BAABLAAECn8WAAIRAAcIKBYZFwDyAQARAAcIKBYZFwDyAQAAAA==.',['牛叉']='牛叉侏死骑:BAAALAAECgYIBgAAAA==.牛叉王:BAAALAAECgUIBQAAAA==.',['牛肉']='牛肉粉:BAAALAADCgYIBgAAAA==.',['狂暴']='狂暴兽战:BAAALAAECgYIBwAAAA==.',['猫咪']='猫咪叫妲己:BAAALAAECgYIBwAAAA==.',['王者']='王者尤文:BAAALAAFFAIIAwAAAA==.',['甜妹']='甜妹弥汐:BAABLAAFFH8FAAIHAAII/BKiOQB9AAAHAAII/BKiOQB9AAAAAA==.',['略懂']='略懂:BAACLAAFFH8YAAICAAYI9xFOHwBxAQACAAYI9xFOHwBxAQAsAAQKfx8AAgIACAjbG3NLAFsCAAIACAjbG3NLAFsCAAAA.',['疯人']='疯人院長:BAAALAAECgEIAQAAAA==.',['眉清']='眉清目秀二狗:BAAALAADCgYIBgAAAA==.',['稀有']='稀有的帅:BAACLAAFFH8PAAMSAAIIdxDbFgB+AAAGAAIIzgwXUQCQAAASAAIIdxDbFgB+AAAsAAQKfyUAAwYACAiGF+RYAPkBAAYACAjDE+RYAPkBABIABQhvF/ZHAFABAAEsAAUUAwgFAAIArRIA.',['空山']='空山灵羽:BAABLAAFFH8KAAIHAAYIORtIEgDMAQAHAAYIORtIEgDMAQAAAA==.',['紫薇']='紫薇乱舞:BAAALAADCgIIAgAAAA==.',['纯属']='纯属渔乐:BAAALAAECgQIBwAAAA==.',['绿皮']='绿皮萨:BAAALAAECggICAAAAA==.',['考虑']='考虑生活:BAAALAADCgYIBgAAAA==.',['耳东']='耳东死骑:BAAALAADCgQIBAAAAA==.',['腼腼']='腼腼雪:BAAALAADCgcIBwAAAA==.',['至高']='至高尤文:BAAALAAECgYIBgAAAA==.',['芸烟']='芸烟贵酒:BAABLAAECn8kAAQPAAYIEBbkJwA6AQAPAAYIEBbkJwA6AQAEAAYIrwaaYACfAAATAAEIeAWLLQAbAAAAAA==.',['苍崎']='苍崎青子:BAABLAAFFH8KAAMJAAIIvhXPTgCAAAAJAAIIvhXPTgCAAAAKAAII0AedNgB5AAAAAA==.',['菲小']='菲小稻:BAABLAAFFH8MAAIDAAYISwCOrQAMAAADAAYISwCOrQAMAAAAAA==.',['萝卜']='萝卜烧肥肠:BAACLAAFFH8HAAIJAAII/AzdUgBpAAAJAAII/AzdUgBpAAAsAAQKfxgAAgkACAgjEEF9AIYBAAkACAgjEEF9AIYBAAAA.',['萧萧']='萧萧丿如花:BAAALAAECgYIDAAAAA==.',['萨骑']='萨骑马:BAAALAAFFAIIAgAAAA==.',['落地']='落地请开手机:BAAALAAECgMIAwAAAA==.',['蒙牛']='蒙牛:BAAALAAECgYIDAAAAA==.',['薛籍']='薛籍嚣:BAAALAADCgcIBwAAAA==.',['蘑菇']='蘑菇仙贝:BAAALAAECgYIBgAAAA==.',['装备']='装备车间:BAAALAAECgIIAgAAAA==.',['西几']='西几丸:BAAALAADCgYIBgAAAA==.',['西雅']='西雅图:BAAALAAECgYIEQAAAA==.',['诗之']='诗之语:BAAALAAECgQIBAAAAA==.',['诗语']='诗语:BAAALAAECgYIDgAAAA==.',['说完']='说完了嘛:BAAALAAFFAIIAgAAAA==.',['谋曹']='谋曹丕:BAAALAAFFAIIBAAAAA==.',['谋黄']='谋黄忠:BAAALAAFFAIIAgAAAA==.',['赞骑']='赞骑尤文:BAAALAAECgcICwAAAA==.',['超高']='超高压热干面:BAAALAAECgYICgAAAA==.',['轰轰']='轰轰烈烈:BAAALAAECgIIAgAAAA==.',['辉耀']='辉耀之麟:BAAALAAECgMIAwAAAA==.',['逝去']='逝去的温柔:BAAALAAFFAIIAgAAAA==.',['重案']='重案组之虎:BAAALAADCgEIAQAAAA==.',['金枝']='金枝玉叶:BAAALAAECgYIEAAAAA==.',['银月']='银月浪漫:BAACLAAFFH8pAAICAAYIphpLCgDCAQACAAYIphpLCgDCAQAsAAQKfyIAAgIACAhVIkAcAAEDAAIACAhVIkAcAAEDAAAA.',['阿尔']='阿尔丽斯:BAABLAAFFH8NAAIDAAIIkx4WYQCYAAADAAIIkx4WYQCYAAAAAA==.',['阿法']='阿法牛:BAAALAAECgYICAAAAA==.',['阿芙']='阿芙珞蒂忒:BAAALAAFFAIIBAAAAA==.',['阿萩']='阿萩莎:BAAALAAECgYIBwAAAA==.',['阿蒂']='阿蒂珥安娜:BAAALAAFFAIIBAAAAA==.',['阿贾']='阿贾克斯:BAAALAAECgYIDAAAAA==.',['青元']='青元玄歌:BAACLAAFFH8wAAIDAAYI/Q+WMADZAAADAAYI/Q+WMADZAAAsAAQKfx8AAgMACAhAHKJAAH8CAAMACAhAHKJAAH8CAAAA.',['青花']='青花:BAAALAAECggIBgAAAA==.',['青龙']='青龙白虎:BAAALAADCgQIBAAAAA==.',['风火']='风火连天:BAAALAAFFAIIBAAAAA==.',['风见']='风见幽香:BAAALAAECgYICgAAAA==.风见月夜:BAABLAAFFH8GAAIUAAII3Ai9NgArAAAUAAII3Ai9NgArAAAAAA==.',['风起']='风起月明:BAABLAAFFH8GAAIVAAYIjBO9CwBWAQAVAAYIjBO9CwBWAQAAAA==.',['飒沓']='飒沓照山河:BAAALAAECgUIBQAAAA==.',['飞发']='飞发走丝:BAAALAAECgMIAwAAAA==.',['骨渊']='骨渊:BAAALAAECgQIBgAAAA==.',['鬼魅']='鬼魅花葬:BAAALAAFFAIIBAAAAA==.',['魔刃']='魔刃:BAAALAAECgEIAQAAAA==.',['鰢琺']='鰢琺裡襖:BAAALAAECgYIDAAAAA==.',['黑蛋']='黑蛋萨穆罗:BAAALAAECgYIDAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end