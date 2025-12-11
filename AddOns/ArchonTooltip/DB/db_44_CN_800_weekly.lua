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
 local lookup = {'Warlock-Destruction','Paladin-Retribution','DeathKnight-Frost','Evoker-Preservation','Evoker-Devastation','Hunter-BeastMastery','Rogue-Assassination','Rogue-Subtlety','Hunter-Marksmanship','Paladin-Holy','Mage-Arcane','Unknown-Unknown','DemonHunter-Havoc','Druid-Guardian','Paladin-Protection','Shaman-Restoration','Warrior-Fury','Druid-Restoration','DeathKnight-Blood','Druid-Feral','Priest-Holy','Priest-Shadow','Warlock-Affliction','Monk-Mistweaver','Hunter-Survival','Monk-Brewmaster','Evoker-Augmentation',}; local provider = {region='CN',realm='艾维娜',name='CN',type='weekly',zone=44,date='2025-12-06',data={Au='Aurkus:BAAALAADCgYIBgAAAA==.',Be='Beser:BAABLAAFFH8bAAIBAAYIOyAiFwDRAQABAAYIOyAiFwDRAQAAAA==.',Ca='Cappuc:BAAALAAECggIAwAAAA==.Cappul:BAAALAAFFAIIBAAAAA==.',Cl='Clever:BAAALAADCgUIBQAAAA==.',De='Deuro:BAAALAAECgUIBwAAAA==.',Ho='Hosico:BAAALAADCgYIBgAAAA==.',Ik='Ikelefe:BAABLAAECn8JAAICAAYIERLs3QBdAQACAAYIERLs3QBdAQAAAA==.',Je='Jeanned:BAAALAAECgEIAgAAAA==.',Ne='Nevermore:BAABLAAFFH8IAAIDAAIIhCBlRwCpAAADAAIIhCBlRwCpAAAAAA==.',No='Nobuff:BAABLAAFFH8HAAMEAAMItwidFgB+AAAEAAIIYAidFgB+AAAFAAIIKgQjIwAyAAAAAA==.Noex:BAACLAAFFH8XAAIBAAUIwBYYNwAyAQABAAUIwBYYNwAyAQAsAAQKfyMAAgEACAivHiomAK4CAAEACAivHiomAK4CAAAA.',Ph='Phr:BAABLAAFFH8RAAICAAYIExJxIwBUAQACAAYIExJxIwBUAQAAAA==.Phrq:BAABLAAFFH8MAAIGAAUIJRY1SwAfAQAGAAUIJRY1SwAfAQAAAA==.',Pl='Playerojvhud:BAAALAAECgMIAgAAAA==.',Re='Reyna:BAAALAAECgEIAgAAAA==.',Ro='Rockingdz:BAAALAAFFAIIAgAAAA==.Rose:BAAALAAECggIBAAAAA==.',Sh='Shadow:BAACLAAFFH8IAAIHAAQILgwNDgArAQAHAAQILgwNDgArAQAsAAQKfzAAAwcACAh6GWQGAB0CAAcACAh6GWQGAB0CAAgABgheDzATANwAAAAA.',Su='Summertrain:BAAALAADCgcICgAAAA==.Suzu:BAAALAAFFAIIAgAAAA==.',Vi='Villa:BAABLAAECn8oAAMGAAgI/RtigwDYAQAGAAgI2hpigwDYAQAJAAYIXBfUXQBFAQAAAA==.Vincentia:BAABLAAFFH8UAAIKAAgIjhyXAgCqAgAKAAgIjhyXAgCqAgAAAA==.',Ws='Wsldqq:BAABLAAFFH8kAAILAAYIYx4YFgDNAQALAAYIYx4YFgDNAQAAAA==.',Wu='Wulibonbon:BAAALAAECgcIBgAAAA==.',['三坑']='三坑地头蛇:BAAALAAFFAIIAgAAAA==.',['三毛']='三毛流浪记:BAAALAADCgMIAwAAAA==.',['三角']='三角初华:BAAALAADCgYIBgAAAA==.',['丰川']='丰川祥子:BAAALAAFFAMIAwABLAAFFAIIAgAMAAAAAA==.',['丶浮']='丶浮生若梦:BAAALAAECgQIBQAAAA==.',['二零']='二零二二世界:BAAALAAECgUIBQAAAA==.',['今汐']='今汐:BAABLAAFFH8OAAMEAAMItA3CDQDLAAAEAAMItA3CDQDLAAAFAAMIdAxGGgBeAAAAAA==.',['伤丶']='伤丶断魂:BAAALAAECgMIAwAAAA==.',['伤断']='伤断魂:BAAALAAFFAMIAwAAAA==.',['伤痛']='伤痛独自尝:BAAALAAECgEIAQAAAA==.',['你别']='你别过来:BAAALAAFFAIIAgAAAA==.',['佳佳']='佳佳不鲁根:BAABLAAECn8XAAIBAAgIqwkPTAAdAQABAAgIqwkPTAAdAQAAAA==.',['依梦']='依梦玲:BAAALAAFFAIIAgAAAA==.',['傷断']='傷断魂:BAAALAAECgIIAwAAAA==.',['傻馒']='傻馒:BAAALAAECgYICwAAAA==.',['像风']='像风一样自由:BAAALAAECgYICQAAAA==.',['克拉']='克拉玛依:BAAALAAECgEIAQAAAA==.',['八卦']='八卦两极:BAAALAADCgIIAgAAAA==.',['八级']='八级大狂风:BAAALAADCgcIDQAAAA==.',['冷雪']='冷雪小美:BAAALAADCgEIAQAAAA==.',['凯瑟']='凯瑟琳娜:BAAALAAECgUIBQAAAA==.',['凰琊']='凰琊:BAAALAAECgYIBgAAAA==.',['别跟']='别跟我调皮:BAABLAAFFH8HAAINAAIIMRcJUQBIAAANAAIIMRcJUQBIAAAAAA==.',['剑意']='剑意凌清秋:BAAALAAECggICAAAAA==.',['千早']='千早素世:BAAALAAECgYIBgAAAA==.',['半夏']='半夏:BAAALAAECgYICQAAAA==.',['卡卡']='卡卡诺斯:BAACLAAFFH8qAAMEAAYI7h+nBQAvAgAEAAYI7h+nBQAvAgAFAAII4iASFACvAAAsAAQKfx8AAwQACAhHIzoBABwDAAQACAhHIzoBABwDAAUACAjaIbEXAGUCAAAA.',['卡托']='卡托丽:BAAALAAECgYICAAAAA==.卡托雷:BAAALAAECgYIBgAAAA==.',['卡碧']='卡碧尼:BAABLAAECn8VAAIGAAYIaR+xQADKAQAGAAYIaR+xQADKAQAAAA==.',['卡穆']='卡穆丶日行者:BAAALAAECgQIBAAAAA==.',['卷卷']='卷卷牌劣人:BAAALAAFFAIIAgAAAA==.卷卷牌苍蝇:BAAALAADCgcIBwAAAA==.卷卷牌迪凯:BAABLAAFFH8GAAIDAAIIJBNZYACYAAADAAIIJBNZYACYAAAAAA==.卷卷牌防战:BAAALAAFFAIIAgAAAA==.',['史提']='史提芬权:BAAALAAECgYIBwAAAA==.史提芬谢拉特:BAAALAAECgYIDAAAAA==.',['右边']='右边画彩虹:BAAALAAECgIIAgAAAA==.',['叶律']='叶律云:BAABLAAFFH8WAAMJAAIIRxqGHgCOAAAJAAIIrxWGHgCOAAAGAAIIRxpNkgBEAAAAAA==.',['君奉']='君奉天:BAAALAAECgYIBgAAAA==.',['吮指']='吮指原味咕:BAABLAAFFH8HAAIOAAQIRhT3BQCzAAAOAAQIRhT3BQCzAAABLAAFFAUIDQAPAHMbAA==.',['咋变']='咋变大树了:BAAALAAFFAIIAgAAAA==.',['咔咔']='咔咔贼:BAAALAADCgIIAgAAAA==.',['咕苏']='咕苏城外:BAABLAAECn8UAAIDAAcIJhVHogDDAQADAAcIJhVHogDDAQAAAA==.',['唐朝']='唐朝祭司:BAACLAAFFH8kAAIQAAUIKBfXIABVAQAQAAUIKBfXIABVAQAsAAQKfykAAhAABwheH6EbABYCABAABwheH6EbABYCAAAA.',['唤潮']='唤潮大妈:BAAALAADCggICAAAAA==.',['喜气']='喜气羊羊:BAAALAAECgEIAQAAAA==.',['回忆']='回忆往事:BAAALAAFFAIIAgAAAA==.',['壹隻']='壹隻珥:BAAALAAECgMIAwAAAA==.',['多多']='多多良小伞:BAAALAAECgQIBAAAAA==.',['夢醒']='夢醒時芬:BAAALAAFFAIIAgAAAA==.',['大扎']='大扎古:BAAALAAECggICAAAAA==.',['天使']='天使也郁闷:BAAALAADCgIIAgAAAA==.',['天才']='天才靓仔萧萧:BAAALAAECgMIAwAAAA==.',['奥斯']='奥斯卡丶尊龙:BAABLAAFFH8yAAIRAAYI9haQGACdAQARAAYI9haQGACdAQAAAA==.',['奶瓶']='奶瓶卷卷:BAAALAAFFAIIAgAAAA==.',['好戏']='好戏开场:BAAALAAFFAIIAgAAAA==.',['孤僻']='孤僻猎神:BAAALAADCgMIAwAAAA==.孤僻飞哥:BAAALAAECgUIBQAAAA==.孤僻龙少:BAAALAAECgYIBgAAAA==.',['守护']='守护阿梅:BAAALAAFFAYIBAAAAA==.',['安卓']='安卓玛丽:BAACLAAFFH8KAAISAAIIfhyaOACJAAASAAIIfhyaOACJAAAsAAQKfxoAAhIACAiBFs4kALABABIACAiBFs4kALABAAAA.',['安娜']='安娜斯塔希尔:BAAALAAECgYIBgAAAA==.',['宝貝']='宝貝儿:BAAALAAECgEIAQAAAA==.',['小兔']='小兔吃狼:BAAALAAECgYIBgAAAA==.',['小叶']='小叶青青:BAAALAADCgYICQAAAA==.',['小猫']='小猫猫熊:BAAALAADCgEIBAAAAA==.',['小糸']='小糸侑:BAAALAADCggICAAAAA==.',['小脸']='小脸骑士:BAAALAAFFAIIBAAAAA==.',['就这']='就这:BAAALAAFFAIIAgAAAA==.',['尾随']='尾随伏击骑:BAAALAAECgEIAQAAAA==.',['巨牛']='巨牛星魂:BAAALAADCgEIAQAAAA==.',['布丽']='布丽阿比迪斯:BAAALAAECggICAAAAA==.',['张天']='张天艾:BAAALAADCgIIAgAAAA==.',['很难']='很难:BAAALAAECgQIAQAAAA==.',['忍者']='忍者神龟:BAAALAADCggIEAAAAA==.',['我不']='我不信圣光:BAAALAAFFAIIAgAAAA==.',['戰国']='戰国:BAABLAAECn8XAAMGAAYIpSKcWQApAgAGAAYIpSKcWQApAgAJAAUIBxtjVQBiAQAAAA==.',['扌莫']='扌莫你穷:BAAALAAECgYICQAAAA==.',['拉斐']='拉斐尔琳:BAAALAAECgcIBwAAAA==.拉斐尔蕊:BAAALAAECgYIBgAAAA==.拉斐尔馨:BAAALAAFFAIIAgAAAA==.',['握紧']='握紧方向盘:BAAALAAECgYIDAAAAA==.',['摩摩']='摩摩尔:BAABLAAFFH8GAAIQAAIIXhqCSQCKAAAQAAIIXhqCSQCKAAAAAA==.',['敌人']='敌人的敌人:BAAALAAECgYIEgAAAA==.',['无敌']='无敌奥特曼:BAABLAAFFH8HAAILAAMIYhBFRwCFAAALAAMIYhBFRwCFAAAAAA==.',['明月']='明月空山雨:BAAALAAECgEIAQAAAA==.',['晚风']='晚风轻眠:BAAALAAECgYIBgAAAA==.',['普劳']='普劳德摩尔:BAABLAAECn8VAAIDAAgIwhnNGQAdAgADAAgIwhnNGQAdAgAAAA==.',['暗夜']='暗夜大婶:BAAALAAFFAIIAgAAAA==.暗夜守望队长:BAAALAAECgEIAQAAAA==.',['暴丶']='暴丶龙:BAACLAAFFH8bAAMDAAUIogonSwAEAQADAAUIogonSwAEAQATAAIIHAGTFwBGAAAsAAQKfx0AAxMACAitCDgdANUAABMACAjCBDgdANUAAAMAAghYFOdtAYgAAAAA.',['暴雨']='暴雨梨花丶沫:BAAALAADCgYIBgAAAA==.',['月冷']='月冷清秋:BAAALAADCgcIBwAAAA==.',['朴妹']='朴妹妹:BAAALAADCgYIDAAAAA==.',['東火']='東火神毉鼒:BAAALAAECgYIBgAAAA==.',['株洲']='株洲余文乐:BAAALAAECgYIBgAAAA==.株洲梁朝伟:BAAALAADCgYIBgAAAA==.',['格子']='格子:BAAALAAECgYIEQAAAA==.',['桑榆']='桑榆非晚:BAAALAADCggICgAAAA==.',['梅心']='梅心惊破:BAAALAADCgQIBAAAAA==.',['梦境']='梦境逐星:BAABLAAFFH8IAAMSAAIIxRBaRwBgAAASAAIIxRBaRwBgAAAUAAII6RWjDQBFAAAAAA==.',['橙心']='橙心橙意:BAABLAAFFH8FAAISAAII8BpvLAB9AAASAAII8BpvLAB9AAAAAA==.',['毒奶']='毒奶粉:BAAALAADCgEIAQAAAA==.',['毛胖']='毛胖球:BAABLAAFFH8oAAMVAAgIniK7AwCkAgAVAAcI+yK7AwCkAgAWAAUIpxjKDwBpAQABLAAFFAgIpAAVAAUkAA==.',['沙加']='沙加丶风行者:BAAALAADCgUIBQAAAA==.',['泥啦']='泥啦塞克:BAAALAAECgYIBgAAAA==.',['海神']='海神波塞冬:BAAALAAFFAIIBAAAAA==.',['海辰']='海辰波塞冬:BAAALAAFFAIIAgAAAA==.',['潘多']='潘多拉丶鬼泣:BAAALAAFFAIIBAAAAA==.',['火花']='火花带闪电:BAAALAADCgcIBwAAAA==.',['点一']='点一下门:BAACLAAFFH8yAAIBAAcIIhx4EQACAgABAAcIIhx4EQACAgAsAAQKfzYAAwEACAhkImIYAPUCAAEACAhkImIYAPUCABcAAgj5GIEpAJ8AAAAA.',['烙印']='烙印:BAAALAAECgYICQAAAA==.',['烟鬼']='烟鬼:BAAALAAECgQIBAAAAA==.',['燃烬']='燃烬之尘:BAAALAAECgEIAQAAAA==.',['燃雷']='燃雷之殛:BAAALAAECggICAAAAA==.',['燃风']='燃风之烬:BAAALAAECggICQAAAA==.',['爱莉']='爱莉希雅:BAAALAAFFAIIBAAAAA==.',['牛斯']='牛斯娜:BAAALAAFFAIIAgAAAA==.',['猎手']='猎手风云:BAAALAAFFAIIAgAAAA==.',['王坊']='王坊文理:BAAALAAECggIDwAAAA==.王坊文里:BAAALAAECgYIBgAAAA==.',['王小']='王小晴晴:BAABLAAFFH8GAAISAAIIyBkBOQCIAAASAAIIyBkBOQCIAAAAAA==.',['玫瑰']='玫瑰香芋奶茶:BAAALAAFFAIIAgAAAA==.',['疯狂']='疯狂的二雷:BAAALAAECgYIBgAAAA==.',['百事']='百事可乐:BAAALAAECgQIBAAAAA==.',['眉眼']='眉眼盈盈:BAAALAAECgIIAgAAAA==.',['离离']='离离原上咪:BAAALAAECgYIDQAAAA==.',['禾木']='禾木:BAABLAAECn8XAAMCAAgIZhY8VQBDAgACAAgIZhY8VQBDAgAPAAYInw1zJwDZAAAAAA==.',['窗外']='窗外的夜:BAAALAADCgYIBgABLAAFFAMIEQAYAJsiAA==.窗外的梦:BAACLAAFFH8RAAIYAAMImyK3BwAwAQAYAAMImyK3BwAwAQAsAAQKfzwAAhgACAitJIsCAEQDABgACAitJIsCAEQDAAAA.',['笑忘']='笑忘书:BAACLAAFFH8HAAICAAIIaRd+YgBFAAACAAIIaRd+YgBFAAAsAAQKfyAAAwIACAhAHj0WAFsCAAIACAhAHj0WAFsCAAoAAwiaAy5CAD4AAAAA.',['管仲']='管仲:BAABLAAECn8UAAIZAAYIaB8TDQDWAQAZAAYIaB8TDQDWAQAAAA==.',['米兰']='米兰的吸血鬼:BAAALAAECgYIBgABLAAFFAgICwAQAEofAA==.',['精灵']='精灵一族:BAACLAAFFH8GAAISAAII3QMnVQBKAAASAAII3QMnVQBKAAAsAAQKfxsAAhIACAjCCrN+ACEBABIACAjCCrN+ACEBAAAA.',['糖尐']='糖尐果:BAAALAAECgEIAQAAAA==.',['糖醋']='糖醋雪梨:BAAALAADCgYIBgAAAA==.',['紫欧']='紫欧:BAAALAADCgUIBQAAAA==.',['练习']='练习六年半:BAABLAAFFH8IAAIaAAgImAt5CADEAQAaAAgImAt5CADEAQAAAA==.',['美式']='美式拉个花:BAAALAAFFAIIBAAAAA==.',['耀光']='耀光改二:BAAALAAFFAMIAwAAAA==.耀光改二甲:BAACLAAFFH8YAAQEAAYIqiETBADeAQAEAAYIqiETBADeAQAbAAMINxQkDACGAAAFAAEIOhq7HQBCAAAsAAQKfxUAAwQABwjaJJwHAL0CAAQABwjaJJwHAL0CAAUAAQiqGA9lAEYAAAEsAAUUAggCAAwAAAAA.',['老玩']='老玩童:BAAALAADCgYIBgAAAA==.',['脸脸']='脸脸大猫:BAAALAAFFAIIAgAAAA==.',['自然']='自然之力暗月:BAAALAAECgYIDAAAAA==.',['芙宁']='芙宁娜:BAAALAAECggICAABLAAFFAgIEQALAAIjAA==.',['芯心']='芯心芯:BAAALAADCgEIAQAAAA==.',['茶树']='茶树咕:BAAALAAECgQIBAAAAA==.',['莎啦']='莎啦达尔:BAAALAADCgQIAQAAAA==.',['菜小']='菜小豆:BAAALAAECgQIBAAAAA==.',['萌新']='萌新牛:BAAALAAECgEIAQAAAA==.',['萨哈']='萨哈琳:BAABLAAECn8aAAMKAAYI5BoANQCUAQAKAAYI5BoANQCUAQACAAIIKAf6ZwFkAAAAAA==.',['薇尔']='薇尔莉特丶:BAAALAAECgEIAQAAAA==.',['血匕']='血匕丶透心涼:BAAALAAECggICAAAAA==.',['誓守']='誓守三千:BAAALAAECgYIDgAAAA==.',['诅咒']='诅咒大师:BAAALAAECgQIBAAAAA==.',['调皮']='调皮卷卷羊:BAAALAAECgYIBgAAAA==.',['贱贱']='贱贱惹人笑:BAAALAAECgEIAQAAAA==.',['还是']='还是坏蛋:BAACLAAFFH8TAAIRAAIIsgsBTQBGAAARAAIIsgsBTQBGAAAsAAQKfxYAAhEABgjaEkmRAGIBABEABgjaEkmRAGIBAAEsAAUUAggWAAkARxoA.',['这是']='这是咩呀:BAAALAAECgYIBgAAAA==.',['迪亞']='迪亞波罗:BAAALAADCggICAAAAA==.',['逍遥']='逍遥圣月:BAAALAAECgYICwAAAA==.',['那个']='那个萨满丶:BAABLAAFFH8eAAIKAAgIuhwqAgDCAgAKAAgIuhwqAgDCAgAAAA==.',['醉里']='醉里挑燈看箭:BAAALAAECgcIBwAAAA==.',['阳光']='阳光甜橙:BAAALAAECgEIAQAAAA==.',['阿曼']='阿曼达狄:BAAALAAECgUIBgAAAA==.',['阿栗']='阿栗:BAAALAAECgYIBgAAAA==.',['阿梅']='阿梅达希尔:BAAALAAFFAIIAgAAAA==.',['阿毛']='阿毛:BAAALAADCgYIBgAAAA==.',['阿道']='阿道夫洗发水:BAAALAAFFAIIAwAAAA==.',['陈陈']='陈陈风暴烈酒:BAAALAAECgQIBAAAAA==.',['随心']='随心牛:BAAALAAECgEIAQAAAA==.',['随芯']='随芯璇:BAAALAAECgIIAgAAAA==.',['随莘']='随莘璇:BAAALAAECgEIAQAAAA==.',['雅琳']='雅琳珂德:BAAALAAECggICAAAAA==.',['雨晴']='雨晴木子:BAAALAAFFAIIBAAAAA==.',['雨的']='雨的印记:BAAALAADCgUIBQAAAA==.',['雨送']='雨送:BAAALAAECgcICAAAAA==.',['雷娜']='雷娜:BAAALAAECggIDgAAAA==.',['雾岛']='雾岛听风丶:BAAALAADCgYIBgAAAA==.',['霖玲']='霖玲:BAABLAAECn8cAAIVAAgIuhrOEwAvAgAVAAgIuhrOEwAvAgAAAA==.',['面包']='面包恶魔:BAAALAAECgIIAgABLAAECgcIBwAMAAAAAA==.面包闪电:BAAALAADCgEIAQAAAA==.',['风暴']='风暴萨满:BAAALAAECgUIBQAAAA==.',['飞扬']='飞扬的元素:BAACLAAFFH8IAAIQAAII+QS7cABJAAAQAAII+QS7cABJAAAsAAQKfx4AAhAACAiiCG3JAPQAABAACAiiCG3JAPQAAAAA.',['香辣']='香辣咕腿堡:BAAALAAECgQIBgAAAA==.',['鱼儿']='鱼儿飞飞:BAAALAAFFAIIBAAAAA==.',['鱼塘']='鱼塘主波塞冬:BAAALAAECgUIBQAAAA==.',['麻辣']='麻辣回锅肉:BAAALAADCgcIBwAAAA==.',['龙奶']='龙奶:BAAALAADCgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end