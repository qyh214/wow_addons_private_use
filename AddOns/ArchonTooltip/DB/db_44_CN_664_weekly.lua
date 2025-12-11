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
 local lookup = {'Priest-Holy','Priest-Shadow','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Frost','Druid-Restoration','Warrior-Fury','Warlock-Destruction','Warlock-Demonology','Mage-Arcane','Shaman-Restoration','Paladin-Holy','Mage-Frost','Warrior-Protection','DemonHunter-Havoc','Paladin-Retribution','Monk-Brewmaster','Monk-Windwalker','Monk-Mistweaver','Druid-Balance','Druid-Guardian','Shaman-Elemental','Paladin-Protection','DeathKnight-Blood','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Vengeance','Evoker-Devastation','DeathKnight-Unholy','Hunter-Survival','Druid-Feral',}; local provider = {region='CN',realm='巴瑟拉斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aa='Aaliyah:BAABLAAFFH8KAAMBAAIIEQQxSABaAAABAAIIEQQxSABaAAACAAEIJQFvMAAqAAAAAA==.',Ai='Airr:BAAALAAECgMIBAAAAA==.',Al='Allison:BAAALAAECgIIAgAAAA==.',Am='Ame:BAAALAAECgcICQAAAA==.',Aq='Aqua:BAAALAAECgYICwAAAA==.',At='Atlas:BAAALAAFFAIIAgAAAA==.Atrwicked:BAAALAAFFAIIAgAAAA==.',Ba='Balram:BAAALAAECgIIAgAAAA==.Banner:BAAALAAECgIIAgAAAA==.',Da='Darksun:BAAALAAFFAIIAgAAAA==.',Ex='Exorcist:BAABLAAFFH8GAAIDAAYIpRWiBgC5AQADAAYIpRWiBgC5AQABLAAFFAgIBwAEAGQVAA==.',Fi='Fixyou:BAABLAAFFH8GAAIFAAYI/huyBgA6AgAFAAYI/huyBgA6AgAAAA==.',Ga='Galhad:BAAALAAFFAIIAgAAAA==.',Ha='Hannuoye:BAAALAAFFAIIBAAAAA==.',If='Ifeeladorabl:BAAALAADCgQIBAAAAA==.',Ju='Jubileus:BAAALAAFFAIIAgAAAA==.Justin:BAABLAAFFH8HAAIGAAMITw5TNACYAAAGAAMITw5TNACYAAAAAA==.',Lm='Lmperio:BAAALAAFFAIIAgAAAA==.',Mg='Mglrmglmg:BAAALAAECgYIBgAAAA==.',Or='Oright:BAAALAAECgQIBAAAAA==.',Pa='Patent:BAAALAAFFAIIAgAAAA==.',Ra='Rainning:BAACLAAFFH8nAAIHAAYIex9KDADTAQAHAAYIex9KDADTAQAsAAQKfygAAgcABwhaIWEqAJMCAAcABwhaIWEqAJMCAAAA.',Sh='Shawnmendes:BAABLAAFFH8FAAMIAAIIiwrhSgCJAAAIAAIIeAjhSgCJAAAJAAEIvQtiLQBIAAAAAA==.',Su='Sucrestal:BAAALAAFFAEIAQAAAA==.',Sw='Sweelbbnmb:BAABLAAFFH8UAAIKAAgIox9nBACoAgAKAAgIox9nBACoAgAAAA==.',Ti='Timothyh:BAAALAAFFAIIAgAAAA==.Tizen:BAAALAAECgYIBgAAAA==.',Ul='Ultron:BAAALAAFFAQIBAAAAA==.',Va='Vavan:BAAALAADCgMIAwAAAA==.',Wi='Wizzard:BAAALAADCgIIAgAAAA==.',Ww='Wwczz:BAAALAAECgYIBgAAAA==.',Zt='Zti:BAAALAAFFAIIAgAAAA==.',['一刀']='一刀轮回:BAAALAAECgYIBgAAAA==.',['一只']='一只狸狸离:BAAALAAECgYIBwAAAA==.',['一月']='一月五号:BAABLAAFFH8GAAILAAIIFwMgawBVAAALAAIIFwMgawBVAAAAAA==.',['一梦']='一梦浮生:BAABLAAFFH8GAAIFAAYIIwttEADQAQAFAAYIIwttEADQAQAAAA==.',['一波']='一波拉:BAAALAAFFAEIAQAAAA==.一波拉完:BAAALAAFFAIIAgAAAA==.',['一直']='一直爱睿恩:BAAALAAECgYIDAAAAA==.',['一箭']='一箭万血:BAAALAADCgQIBAAAAA==.',['七尺']='七尺男儿:BAAALAAECgYICQAAAA==.',['三天']='三天没洗:BAAALAAECggICQAAAA==.',['三班']='三班班长:BAAALAAECgYIDAAAAA==.',['三粒']='三粒蛋蛋:BAAALAAECggIDAAAAA==.',['不了']='不了好:BAAALAAECgEIAQAAAA==.',['不吃']='不吃鱼的喵喵:BAAALAADCgEIAQAAAA==.',['不睡']='不睡觉的熠:BAABLAAFFH8NAAIMAAMIyRJBGACeAAAMAAMIyRJBGACeAAAAAA==.',['不缺']='不缺德不行:BAACLAAFFH8MAAIGAAYIkxOQFQCJAQAGAAYIkxOQFQCJAQAsAAQKfykAAgYABgg2F+ItAHgBAAYABgg2F+ItAHgBAAAA.',['且借']='且借一抹霞光:BAAALAAECgMIAwAAAA==.',['东古']='东古诺:BAAALAAECgYIEwAAAA==.',['两脚']='两脚发软:BAABLAAECn8eAAINAAYI6hlfGABiAQANAAYI6hlfGABiAQAAAA==.',['严冬']='严冬的鹅卵石:BAAALAAECgYIDQAAAA==.',['丨叶']='丨叶隐知心丨:BAAALAAECgEIAQAAAA==.',['丨琼']='丨琼丨:BAAALAAECgYIBgAAAA==.',['丶丨']='丶丨紫薯糖:BAAALAAECgMIAwAAAA==.',['丶丶']='丶丶狸猫先生:BAAALAAECgIIAgAAAA==.',['丶地']='丶地瓜:BAAALAAECgQIBAAAAA==.',['丶小']='丶小饼干:BAABLAAFFH8qAAIOAAgIiyGFAQCXAgAOAAgIiyGFAQCXAgAAAA==.',['丶很']='丶很开心:BAAALAAECgMIAwAAAA==.',['丶游']='丶游龙:BAABLAAFFH8qAAIOAAgISxjbAwAhAgAOAAgISxjbAwAhAgAAAA==.',['丶诺']='丶诺诺:BAAALAAECgYIBgAAAA==.',['丷郭']='丷郭靖丷:BAABLAAFFH8SAAIOAAYIpw4YFAAfAQAOAAYIpw4YFAAfAQAAAA==.',['丷麦']='丷麦辣鸡腿堡:BAAALAAECggICAAAAA==.',['丷黄']='丷黄蓉丷:BAABLAAFFH8oAAIOAAYIGhrACABbAQAOAAYIGhrACABbAQAAAA==.',['丹妃']='丹妃:BAAALAADCgUIBQAAAA==.',['举火']='举火烧天:BAACLAAFFH8QAAIIAAQI7R7MIwABAQAIAAQI7R7MIwABAQAsAAQKfxgAAggABggKJfEsAIwCAAgABggKJfEsAIwCAAAA.',['乄聖']='乄聖灬七夜:BAAALAAECgYIBgAAAA==.',['么看']='么看来:BAAALAADCgYIBgAAAA==.',['乐子']='乐子之无知:BAAALAAECgYIBgAAAA==.',['乐林']='乐林:BAAALAAECgYIDAAAAA==.',['乐牧']='乐牧:BAAALAAFFAIIAgAAAA==.',['乐皓']='乐皓:BAAALAAECgEIAQAAAA==.',['乐秋']='乐秋:BAAALAAECgYIAQAAAA==.',['乐莲']='乐莲:BAAALAAECgYIEwAAAA==.',['乐萨']='乐萨:BAAALAAFFAIIAgAAAA==.',['乐轩']='乐轩:BAAALAADCgIIAgAAAA==.',['乐飞']='乐飞:BAAALAAECgIIAgAAAA==.',['九十']='九十:BAAALAAECgMIAwAAAA==.',['九华']='九华山大师:BAABLAAFFH8JAAIBAAMIXA4CLwCwAAABAAMIXA4CLwCwAAABLAAFFAYIIQALAO0cAA==.',['乱斗']='乱斗之王:BAABLAAECn8ZAAIPAAYIXxsyMgCQAQAPAAYIXxsyMgCQAQAAAA==.',['事多']='事多:BAAALAAFFAcIBAAAAA==.',['二爺']='二爺要上岗:BAACLAAFFH8qAAIQAAYITyOkCAAEAgAQAAYITyOkCAAEAgAsAAQKfysAAhAACAi4JV4HAN8CABAACAi4JV4HAN8CAAAA.',['二电']='二电厂:BAAALAADCgUIBQAAAA==.',['二釢']='二釢要转正:BAACLAAFFH8MAAIQAAYIwh1IEgC1AQAQAAYIwh1IEgC1AQAsAAQKfxgAAhAABgjEItJqABQCABAABgjEItJqABQCAAAA.',['二零']='二零二五:BAAALAAECgYICQAAAA==.',['五岁']='五岁半:BAAALAADCgcIDQAAAA==.',['亚伦']='亚伦灬永在:BAAALAAECgEIAQAAAA==.',['亡魂']='亡魂序曲:BAABLAAECn8bAAINAAYIih6nIwADAgANAAYIih6nIwADAgAAAA==.',['交换']='交换機:BAAALAADCgEIAQAAAA==.',['亮哥']='亮哥最潇洒:BAAALAAECggICQAAAA==.',['人心']='人心不古:BAAALAAFFAEIAQAAAA==.',['今晚']='今晚我很强:BAABLAAFFH8eAAIOAAYIxxUMEQBCAQAOAAYIxxUMEQBCAQAAAA==.',['从未']='从未如此哀伤:BAABLAAFFH8YAAIQAAUI3Bc/JwA/AQAQAAUI3Bc/JwA/AQAAAA==.',['他只']='他只是男闺蜜:BAABLAAFFH8kAAIRAAgIDBMrBgD1AQARAAgIDBMrBgD1AQAAAA==.',['代号']='代号晓:BAAALAAECgEIAQAAAA==.代号零零一:BAAALAAECgYIBgAAAA==.',['以死']='以死的姿态:BAAALAAFFAMIAQAAAA==.',['仰望']='仰望天空:BAAALAAECggIDQAAAA==.仰望我的背影:BAAALAADCgYIBgAAAA==.',['企鹅']='企鹅鹅:BAAALAAECgQIBAAAAA==.',['伊力']='伊力丹:BAAALAADCgMIBAAAAA==.',['伊歌']='伊歌利特:BAAALAAECgYIDQAAAA==.',['伊莉']='伊莉雅丶:BAAALAAFFAIIAgAAAA==.',['休闲']='休闲呆呆:BAAALAAFFAIIAgAAAA==.休闲宝宝:BAABLAAFFH8ZAAQSAAYIrxqECABoAQASAAUI9RmECABoAQATAAYInQxRCwBPAQARAAIIig/3FQB3AAAAAA==.休闲白:BAACLAAFFH8hAAMGAAYIDxiKGQBhAQAGAAUIbxiKGQBhAQAUAAUIDxvzEwBFAQAsAAQKfx0ABAYABwhlHBwvACQCAAYABwhlHBwvACQCABUABgj+HckKAJABABQABginG+wbAI8BAAAA.',['会相']='会相遇呀:BAAALAADCgMIAwAAAA==.',['传说']='传说中丶小龙:BAAALAAFFAIIBAAAAA==.',['似画']='似画:BAAALAAECgUIBQAAAA==.',['低调']='低调人士:BAAALAAECgYIBgAAAA==.',['何必']='何必那么认真:BAAALAADCgEIAwAAAA==.',['你们']='你们不懂胖虎:BAAALAAECgYIDAAAAA==.',['你是']='你是干哈的:BAAALAAECggICAAAAA==.',['你跺']='你跺你也麻:BAAALAADCgMIAwAAAA==.',['你这']='你这是病得电:BAABLAAFFH8hAAMLAAYI7Rw7DgD4AQALAAYI7Rw7DgD4AQAWAAMILgWIOQBxAAAAAA==.',['依赖']='依赖:BAAALAADCgcIBwAAAA==.',['侧耳']='侧耳倾听:BAAALAAECgQIBAAAAA==.',['修纙']='修纙道:BAAALAAFFAIIBAAAAA==.',['偶原']='偶原来不帅:BAABLAAFFH8OAAIGAAII5RqUOACJAAAGAAII5RqUOACJAAAAAA==.',['光光']='光光要杀我:BAAALAAECgIIAgAAAA==.',['兜兜']='兜兜里有根烟:BAAALAAECgUIBQAAAA==.',['八十']='八十一锤:BAAALAADCgYIBwAAAA==.',['八级']='八级小狂風:BAABLAAFFH8TAAIXAAgIZxQ3AgD8AQAXAAgIZxQ3AgD8AQAAAA==.',['军阀']='军阀:BAAALAADCgMIAwAAAA==.',['冠军']='冠军侯哈基米:BAAALAAECgYICAAAAA==.',['冰天']='冰天动地:BAAALAAFFAMIAwAAAA==.',['冰帝']='冰帝凯:BAAALAAECgMIAwAAAA==.',['冰爽']='冰爽:BAAALAAFFAIIAwAAAA==.',['冷月']='冷月雪玲:BAAALAAECgIIAwAAAA==.',['冻工']='冻工:BAAALAAFFAIIBAAAAA==.',['凉城']='凉城孤影:BAAALAADCgYIBgAAAA==.',['凋谢']='凋谢:BAAALAAECgMIAwAAAA==.',['凛冬']='凛冬皎月:BAAALAAECgcICQAAAA==.',['凛月']='凛月十六夜:BAABLAAFFH8GAAIFAAIIXCF2dABMAAAFAAIIXCF2dABMAAAAAA==.',['凯西']='凯西:BAABLAAFFH8HAAIWAAIIMAIlVQAeAAAWAAIIMAIlVQAeAAAAAA==.',['到韩']='到韩国治丑病:BAAALAADCgQIBAAAAA==.',['制裁']='制裁之锤:BAAALAAECgUIBQAAAA==.',['剑舞']='剑舞星辰:BAAALAADCgcICwAAAA==.',['剑视']='剑视乄风云:BAAALAADCgIIAgAAAA==.',['加勒']='加勒比兵哥:BAAALAAECgEIAQAAAA==.',['升龙']='升龙烈破:BAAALAAFFAIIAgAAAA==.',['单调']='单调:BAACLAAFFH8YAAIEAAYIcRlVLQCAAQAEAAYIcRlVLQCAAQAsAAQKfxYAAwQABgjqIodRADsCAAQABgjqIodRADsCAAMAAQiICrrFACoAAAAA.',['南玻']='南玻斯瑞:BAAALAAECgYICAAAAA==.',['卜穴']='卜穴污术:BAAALAAECgUIBQAAAA==.',['卡司']='卡司特非:BAAALAADCggICAAAAA==.',['卡路']='卡路迪亚:BAAALAAFFAIIAgAAAA==.',['卡达']='卡达拉尔:BAAALAADCgQIBAAAAA==.',['叁贰']='叁贰捌:BAAALAAFFAIIBAAAAA==.',['又杀']='又杀一背刀:BAAALAAECgUIBQAAAA==.',['双全']='双全法:BAABLAAFFH8fAAMNAAYIUxevCwCgAAAKAAUI9BVNMQA/AQANAAQIaBGvCwCgAAAAAA==.',['取汁']='取汁有道:BAABLAAFFH8kAAIOAAYIKRkSDgBlAQAOAAYIKRkSDgBlAQAAAA==.',['只有']='只有半个蛋:BAAALAAECgYIDQAAAA==.',['叫我']='叫我萌萌德:BAAALAAECgIIAgAAAA==.',['可莉']='可莉不知道呀:BAAALAAFFAIIAgAAAA==.',['各种']='各种圣印:BAAALAAECgEIAQAAAA==.',['向太']='向太阳昂首:BAAALAAECgUIBgAAAA==.',['呀呀']='呀呀嘿:BAAALAAECgEIAQAAAA==.',['咕咕']='咕咕复咕咕:BAAALAAECgYICQAAAA==.咕咕老王:BAAALAADCgUIBQAAAA==.',['咖啡']='咖啡丶那么苦:BAAALAAFFAIIAgAAAA==.咖啡精灵:BAAALAAECgYIBgAAAA==.',['咸蛋']='咸蛋小超人丶:BAABLAAFFH8GAAIYAAYIHhSDAwDsAQAYAAYIHhSDAwDsAQAAAA==.',['哈利']='哈利菠特大:BAACLAAFFH8MAAIFAAIIuRg+hQBDAAAFAAIIuRg+hQBDAAAsAAQKfxUAAgUABwg6HZ1UAE4CAAUABwg6HZ1UAE4CAAAA.',['哎呀']='哎呀灬蛇:BAABLAAFFH8bAAIYAAgI8hxsAgBuAgAYAAgI8hxsAgBuAgAAAA==.',['哎哟']='哎哟喂打不着:BAAALAADCgMIAwAAAA==.',['唏嘘']='唏嘘胡茬子:BAAALAAECgYIBgAAAA==.',['唔系']='唔系呆包哎:BAAALAAECgYIBgAAAA==.',['喝水']='喝水的鱼:BAAALAADCgEIAQAAAA==.',['嗜血']='嗜血护术宝:BAABLAAFFH8qAAMIAAYIXBkQHgClAQAIAAYI0xgQHgClAQAJAAEI5SAfHQAAAAAAAA==.',['嘬口']='嘬口苦瓜叽:BAAALAAECggICAAAAA==.',['噬夜']='噬夜:BAABLAAFFH8KAAIHAAYIxAkrJgA+AQAHAAYIxAkrJgA+AQAAAA==.',['噬血']='噬血冥王:BAAALAAECgYIBQAAAA==.',['回到']='回到丶过去:BAABLAAECn8UAAIZAAYIuRu1JgDnAQAZAAYIuRu1JgDnAQAAAA==.',['图拉']='图拉羊:BAAALAADCgYICAAAAA==.',['團結']='團結丶:BAAALAAECgYIDAAAAA==.',['圣光']='圣光熊熊:BAABLAAECn8ZAAIQAAgI7SSgBwBmAwAQAAgI7SSgBwBmAwAAAA==.',['圣奶']='圣奶士:BAAALAAFFAMIAwAAAA==.',['圣血']='圣血恶魔:BAAALAAECgIIAgAAAA==.',['地里']='地里的瓜:BAAALAAECgMIAwAAAA==.',['坏叔']='坏叔叔:BAAALAADCgUICAAAAA==.',['堕落']='堕落偷:BAAALAAECgYIBwAAAA==.',['塔邀']='塔邀尼斯阿卡:BAAALAAFFAIIAgAAAA==.',['塞巴']='塞巴多拉贡:BAAALAAFFAEIAQAAAA==.',['墨灵']='墨灵:BAAALAAECggICgAAAA==.',['墲空']='墲空:BAACLAAFFH8FAAIaAAIIHgoCFwB8AAAaAAIIHgoCFwB8AAAsAAQKfx8AAxoACAhMFbUGAMcBABoACAhMFbUGAMcBABkAAwiDBXRdAI8AAAAA.',['壹圆']='壹圆陆角捌分:BAAALAAECgYIBgAAAA==.',['壹贰']='壹贰彡肆乄:BAAALAADCggIDQAAAA==.',['复往']='复往昔:BAAALAAECgYIDwAAAA==.',['夏雨']='夏雨的宁静:BAAALAAFFAIIAwAAAA==.',['多谢']='多谢乌蝇哥:BAABLAAFFH8MAAIRAAYIDw4fBwCNAQARAAYIDw4fBwCNAQAAAA==.',['夜笙']='夜笙哥:BAAALAAECgYICQAAAA==.夜笙歌:BAAALAAECgYICQAAAA==.',['大力']='大力牛:BAAALAAFFAYIAgAAAA==.',['大只']='大只奶牛:BAAALAADCgEIAQAAAA==.',['大尾']='大尾巴狼:BAAALAAECgEIAQAAAA==.',['大榴']='大榴莲:BAAALAAECgQIBgAAAA==.',['大甜']='大甜梨:BAAALAAECgYIBwAAAA==.',['大胡']='大胡子旋子:BAAALAADCgEIAQAAAA==.',['天使']='天使真央:BAABLAAFFH8FAAIJAAUIlQR1AQBdAQAJAAUIlQR1AQBdAQAAAA==.天使馒头:BAAALAADCgIIAgAAAA==.',['天可']='天可怜见:BAAALAADCgYIBgAAAA==.',['天权']='天权:BAABLAAECn8WAAIIAAgI5xn2HgDvAQAIAAgI5xn2HgDvAQAAAA==.',['天枢']='天枢:BAAALAAECgYIDAAAAA==.',['天涯']='天涯浪迹少年:BAAALAAECgUIBQAAAA==.',['天琁']='天琁:BAABLAAECn8eAAIEAAgIJCAhGABsAgAEAAgIJCAhGABsAgAAAA==.',['天空']='天空的引路人:BAAALAAFFAUIAQAAAA==.',['天黑']='天黑磨刀:BAAALAAECgcIBwAAAA==.',['头上']='头上有畸角:BAAALAAECgIIAgAAAA==.',['夺命']='夺命剪刀脚:BAAALAADCgUIBQAAAA==.',['奈斯']='奈斯:BAAALAADCgIIAgAAAA==.',['女王']='女王驾到:BAAALAAECgYIDAAAAA==.',['好牛']='好牛的滑子:BAAALAAFFAIIBAAAAA==.',['如你']='如你所愿少侠:BAAALAAECgIIAgAAAA==.',['如莑']='如莑:BAAALAAECgEIAQAAAA==.',['妖孽']='妖孽也彷徨:BAAALAADCggICAAAAA==.',['妮丫']='妮丫:BAABLAAFFH8GAAIJAAYIIwQ8BQD4AAAJAAYIIwQ8BQD4AAAAAA==.',['姬野']='姬野星奏:BAAALAAECgEIAQAAAA==.',['孤星']='孤星半月:BAABLAAFFH8GAAIQAAYIchpxBAAmAgAQAAYIchpxBAAmAgAAAA==.',['宛君']='宛君若在:BAAALAAECgUIBQAAAA==.',['宛陵']='宛陵湖:BAAALAAECgQIBwAAAA==.',['宝丿']='宝丿大:BAAALAAECgEIAQAAAA==.',['宝怪']='宝怪小炽炽:BAAALAAECgMIAwAAAA==.',['宫爆']='宫爆土豆:BAAALAAECgYICAAAAA==.',['对不']='对不起我想你:BAAALAAECgYIEwAAAA==.对不起我爱你:BAAALAAECgYIDQAAAA==.',['射中']='射中小菇凉:BAAALAAECggIAgABLAAFFAgICwAEAHceAA==.',['小南']='小南门彭于晏:BAAALAADCgMIAwAAAA==.',['小声']='小声开军舰:BAAALAAECgcIBwAAAA==.',['小姜']='小姜贼能秀丶:BAABLAAFFH8GAAIKAAUICAjLPQDNAAAKAAUICAjLPQDNAAAAAA==.',['小小']='小小多多:BAABLAAFFH8SAAIHAAYI+AtQJABMAQAHAAYI+AtQJABMAQAAAA==.',['小废']='小废废丶:BAAALAAECgYIBgAAAA==.',['小拉']='小拉格:BAAALAAECgEIAQAAAA==.',['小熊']='小熊水煮肉:BAAALAAECgYIDAAAAA==.',['小珑']='小珑女:BAAALAADCgcIDQAAAA==.',['小福']='小福狸:BAACLAAFFH8eAAMKAAUIOh3qMgA0AQAKAAUItBrqMgA0AQANAAEIPxdIEwBKAAAsAAQKfyUAAwoABwgrH5xGADQCAAoABwj2HpxGADQCAA0ABgj/GU4+AHgBAAEsAAUUCAgFAAQAvhAA.小福狸狐克丝:BAAALAAFFAIIAgAAAA==.',['小米']='小米粥:BAAALAADCggICAAAAA==.',['小红']='小红手玩咖:BAABLAAFFH8mAAIbAAgIHxawAQDuAQAbAAgIHxawAQDuAQAAAA==.',['尚武']='尚武乄罚款:BAAALAAECgYIBgAAAA==.',['尤丽']='尤丽亚:BAABLAAFFH8IAAINAAgI2wLcIAAnAAANAAgI2wLcIAAnAAAAAA==.',['就让']='就让一切随风:BAAALAAECgIIAgAAAA==.',['屁桃']='屁桃:BAABLAAFFH8MAAIFAAUIRBd0OwBNAQAFAAUIRBd0OwBNAQAAAA==.',['山岳']='山岳:BAAALAAECgYIEgAAAA==.',['左手']='左手之间:BAAALAAECgEIAQAAAA==.',['巨龙']='巨龙战:BAAALAAECgcIDwAAAA==.巨龙终结者:BAAALAAECgYIEQAAAA==.',['巫语']='巫语者:BAACLAAFFH8GAAIIAAYIChUYHwChAQAIAAYIChUYHwChAQAsAAQKfxoAAgkABgiCFjETAEYBAAkABgiCFjETAEYBAAAA.',['干了']='干了这碗:BAAALAADCgUIBQAAAA==.',['幽酷']='幽酷:BAAALAAECgYIBgAAAA==.',['幽雨']='幽雨:BAABLAAFFH8IAAIIAAII1gY5agA2AAAIAAII1gY5agA2AAAAAA==.',['开阳']='开阳:BAAALAAECgYIDAAAAA==.',['張老']='張老师:BAAALAAECgYIDAAAAA==.',['彤彤']='彤彤超市:BAABLAAFFH8KAAIcAAIIZw7AHwA8AAAcAAIIZw7AHwA8AAABLAAFFAYIIQALAO0cAA==.',['彦祖']='彦祖尔丹:BAAALAAECgYIDQAAAA==.',['影依']='影依:BAACLAAFFH86AAMBAAYIVQ1TGwB0AQABAAYIVQ1TGwB0AQACAAUInxDfEgDsAAAsAAQKfzYAAwEACAgSHEIeAIMCAAEACAgSHEIeAIMCAAIABwjVG6gvAA0CAAAA.',['影玄']='影玄风:BAAALAAFFAIIAwAAAA==.',['御箭']='御箭江湖:BAAALAAECgYIBgAAAA==.',['德川']='德川沐妇:BAAALAAECgUIBQAAAA==.',['心控']='心控:BAABLAAFFH8OAAIIAAUIxwvOPAAQAQAIAAUIxwvOPAAQAQAAAA==.',['忘乎']='忘乎所以:BAAALAAFFAIIAgAAAA==.',['忘记']='忘记过去:BAAALAAECgUICAAAAA==.',['念雪']='念雪慕鸿:BAABLAAFFH8JAAIEAAII4hEbXQCNAAAEAAII4hEbXQCNAAAAAA==.',['怀抱']='怀抱太阳:BAACLAAFFH8WAAIBAAUIRggyJQARAQABAAUIRggyJQARAQAsAAQKfxgAAgEACAimE6QgALEBAAEACAimE6QgALEBAAAA.',['恶魔']='恶魔熊熊:BAAALAAECggIEQAAAA==.',['惊鸿']='惊鸿:BAABLAAFFH8IAAIKAAYI/wTfOwDkAAAKAAYI/wTfOwDkAAAAAA==.',['想上']='想上房揭瓦:BAAALAADCgYIBgAAAA==.',['想你']='想你的睿恩:BAAALAAECgcIEQAAAA==.',['愁眠']='愁眠:BAABLAAFFH8MAAIOAAYI7hxaDQBuAQAOAAYI7hxaDQBuAQAAAA==.',['愤怒']='愤怒的猪猪:BAAALAADCggIDAAAAA==.',['我可']='我可莉害了:BAAALAAECggIBwAAAA==.',['我将']='我将带头冲钅:BAABLAAFFH8GAAMOAAIIJBH9MAAyAAAHAAIIlAa0RgCCAAAOAAIIJBH9MAAyAAAAAA==.我将带头升空:BAABLAAFFH8NAAIPAAUI/RrsKgA9AQAPAAUI/RrsKgA9AQAAAA==.',['我来']='我来组成头部:BAAALAADCgEIAQAAAA==.',['我爱']='我爱落小鸢:BAAALAAECgYIBgAAAA==.',['我醒']='我醒着做梦:BAAALAAECgYIDAAAAA==.',['战斗']='战斗熊熊:BAABLAAECn8+AAIHAAgIQSUXBgBkAwAHAAgIQSUXBgBkAwAAAA==.',['战神']='战神栓狗:BAABLAAFFH8gAAIbAAgIVxJ0AgDDAQAbAAgIVxJ0AgDDAQAAAA==.',['打伞']='打伞的小蘑菇:BAABLAAFFH8mAAIOAAYIPxZ7EABIAQAOAAYIPxZ7EABIAQAAAA==.',['打弓']='打弓崽:BAAALAAECgcIEwAAAA==.',['打拳']='打拳爹爹:BAAALAAECgMIAwAAAA==.',['抱抱']='抱抱豹豹:BAACLAAFFH8GAAIBAAIIzhmzMACNAAABAAIIzhmzMACNAAAsAAQKfxcAAgEABgjjIakpAEICAAEABgjjIakpAEICAAAA.',['抹了']='抹了油的猪:BAABLAAFFH8HAAIOAAMIjAoGIgBqAAAOAAMIjAoGIgBqAAABLAAFFAYIIQALAO0cAA==.',['拉斐']='拉斐尔桀:BAAALAAECgcIBwAAAA==.',['拉鸡']='拉鸡游戏:BAAALAAECggICAAAAA==.',['拾行']='拾行:BAAALAADCgEIAQAAAA==.',['指间']='指间的星光:BAAALAAECgYIBgAAAA==.',['捅主']='捅主任:BAABLAAFFH8GAAIZAAIIygJxHwA3AAAZAAIIygJxHwA3AAABLAAFFAYIIQALAO0cAA==.',['摸鱼']='摸鱼:BAAALAAECggICAAAAA==.',['教主']='教主万紫千橙:BAABLAAFFH8WAAIdAAYIghbBAgCrAQAdAAYIghbBAgCrAQAAAA==.',['斩真']='斩真狼牙:BAAALAAFFAIIBAAAAA==.',['无心']='无心入圣:BAABLAAECn8YAAIQAAYIrBhuUQBrAQAQAAYIrBhuUQBrAQAAAA==.无心无伤:BAAALAAFFAIIAgAAAA==.无心无僧:BAAALAAECgYICwAAAA==.无心无恶魔:BAAALAAECgYICAAAAA==.无心无竹:BAAALAAFFAIIAgAAAA==.无心無竹:BAAALAAECgQIBQAAAA==.',['无比']='无比的纠结:BAABLAAFFH8GAAIKAAIIwQ1dXACCAAAKAAIIwQ1dXACCAAAAAA==.',['时光']='时光扭曲:BAABLAAFFH8GAAINAAIIXgsZHgA0AAANAAIIXgsZHgA0AAABLAAFFAYIIQALAO0cAA==.',['昊锅']='昊锅锅丶:BAAALAAECgYIBgAAAA==.',['是的']='是的没错:BAAALAAECggIBAAAAA==.',['晴天']='晴天清茶:BAAALAADCgQIBAAAAA==.',['暗夜']='暗夜疯子:BAAALAADCgMIAwAAAA==.',['暴力']='暴力饼干:BAAALAAECgYICQAAAA==.',['暴走']='暴走的芙兰:BAAALAAECgYIEQAAAA==.',['曾耐']='曾耐超:BAAALAAECgEIAQAAAA==.',['最後']='最後啲宿命:BAAALAAECgYIBgAAAA==.',['月岛']='月岛萌夏:BAAALAADCgEIAQAAAA==.',['月忆']='月忆:BAABLAAECn8WAAIDAAYI8QRKjAC0AAADAAYI8QRKjAC0AAAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8IAAMGAAgIERaHDgDWAQAGAAcIYhWHDgDWAQAUAAEIzRphKwBYAAAAAA==.',['有点']='有点跳:BAABLAAFFH8GAAIPAAYIqRSlIgBzAQAPAAYIqRSlIgBzAQAAAA==.有点飘:BAAALAAFFAYIAgAAAA==.',['有球']='有球必硬:BAAALAAECgUICgAAAA==.',['有花']='有花有下士:BAAALAAECgUIBQAAAA==.',['木仓']='木仓:BAABLAAFFH8GAAIEAAYINwakWQDiAAAEAAYINwakWQDiAAAAAA==.',['木子']='木子:BAAALAAECgQIBAAAAA==.',['木木']='木木不搞暗牧:BAAALAAECggICgAAAA==.木木不搞防骑:BAAALAAECggICgAAAA==.',['木饭']='木饭:BAAALAAFFAEIAQAAAA==.',['机智']='机智萨哟:BAAALAAECgUIDwAAAA==.',['李嘉']='李嘉欣:BAABLAAFFH8KAAIGAAQILRSPJQDtAAAGAAQILRSPJQDtAAAAAA==.',['李毅']='李毅九:BAABLAAFFH8IAAIRAAYIZAX3FADwAAARAAYIZAX3FADwAAAAAA==.',['東星']='東星耀陽:BAAALAAECgYIBgAAAA==.',['枫枼']='枫枼:BAACLAAFFH80AAIUAAcIxCOyAwBoAgAUAAcIxCOyAwBoAgAsAAQKfxUAAhQACAiGImsRAN8CABQACAiGImsRAN8CAAAA.',['枭阳']='枭阳:BAABLAAFFH8MAAIPAAIIYxwOPgCbAAAPAAIIYxwOPgCbAAAAAA==.',['柳洳']='柳洳烟:BAAALAAECgYIBgAAAA==.',['树欲']='树欲静凨不止:BAABLAAFFH8dAAQQAAYIfR37GQCIAQAQAAUIDCH7GQCIAQAMAAYIBAh2FABFAQAXAAIIXBMAFACEAAAAAA==.',['桃小']='桃小妖夭:BAAALAAECgYIBgAAAA==.',['桃猎']='桃猎:BAAALAADCggICAAAAA==.',['椰绿']='椰绿芒果:BAABLAAFFH8WAAIRAAgIyRFfBgDwAQARAAgIyRFfBgDwAQAAAA==.',['武田']='武田信玄:BAACLAAFFH8IAAIEAAIIyQkGrwA3AAAEAAIIyQkGrwA3AAAsAAQKfxYAAgQABwi9D3vHAHUBAAQABwi9D3vHAHUBAAAA.',['死骑']='死骑没马骑:BAAALAAECgYIBgAAAA==.',['残剑']='残剑侠:BAAALAAECgMIAwAAAA==.',['残德']='残德灬界静:BAAALAAFFAQIAwAAAA==.',['毒殘']='毒殘雲:BAAALAADCggICwAAAA==.',['比新']='比新手还新:BAAALAAECgYIBgAAAA==.',['比狗']='比狗强一点:BAABLAAFFH8FAAIFAAUIvhFTSwADAQAFAAUIvhFTSwADAQAAAA==.比狗还要菜:BAABLAAFFH8GAAIQAAYIpRTGBQALAgAQAAYIpRTGBQALAgAAAA==.',['水無']='水無月沙耶:BAAALAAFFAIIAgAAAA==.',['永恒']='永恒封冰:BAAALAAFFAMIBAAAAA==.',['沉默']='沉默的狼:BAAALAADCgcIBwAAAA==.',['没意']='没意思:BAAALAADCgEIAwAAAA==.',['沫离']='沫离汐:BAAALAADCgYICQAAAA==.',['法丝']='法丝洛洛:BAAALAADCgcIBwAAAA==.',['活络']='活络丸:BAAALAAECggIDwAAAA==.',['流萤']='流萤:BAAALAAECgYIBgAAAA==.',['流麗']='流麗句律:BAAALAAECgYIDAAAAA==.',['浅一']='浅一葬花:BAABLAAFFH8MAAIVAAYIIwq9BADsAAAVAAYIIwq9BADsAAAAAA==.',['浅白']='浅白夜空:BAAALAAECgYIDwAAAA==.',['浅笑']='浅笑夜聆风:BAAALAAECgYIDAAAAA==.',['浪漫']='浪漫的牛:BAAALAAFFAIIBAAAAA==.',['浮云']='浮云骑神马:BAAALAAFFAIIBAABLAAFFAgICAALAOkWAA==.',['深渊']='深渊血骑:BAAALAAECgYIDwAAAA==.',['清水']='清水芙蓉:BAAALAAECgYIBQAAAA==.',['渐入']='渐入夹径:BAABLAAFFH8sAAIOAAYIDxf0CABUAQAOAAYIDxf0CABUAQAAAA==.',['游不']='游不动的鱼:BAAALAAECgYIBwAAAA==.',['湮灭']='湮灭:BAAALAAECgUIDwAAAA==.',['溡埫']='溡埫灬邦德:BAAALAAECgMIBAAAAA==.',['满穗']='满穗:BAABLAAFFH8JAAIWAAMIAAsVHQDOAAAWAAMIAAsVHQDOAAAAAA==.',['火箭']='火箭干脆面:BAAALAAECgMIAwAAAA==.',['灬紫']='灬紫了葡萄灬:BAABLAAFFH8JAAILAAYIvRlSGgCKAQALAAYIvRlSGgCKAQAAAA==.',['灵狐']='灵狐:BAAALAAECgMIAwAAAA==.',['炉石']='炉石萌新别打:BAABLAAFFH8hAAMQAAYImiXeBwAMAgAQAAYImiXeBwAMAgAMAAII5BMbGwCUAAAAAA==.',['炫顿']='炫顿自助:BAABLAAFFH8mAAMOAAgIlh1uBwDOAQAOAAgIrBhuBwDOAQAHAAUIkSD9IgBWAQAAAA==.',['点门']='点门拉人:BAAALAAECgMIAwAAAA==.',['烈火']='烈火战寒冰:BAABLAAFFH8GAAMNAAIIzhAvEwCHAAANAAIIzhAvEwCHAAAKAAII/AIJZABvAAAAAA==.',['烟丶']='烟丶瘾:BAAALAAECggIDAAAAA==.',['烤嫩']='烤嫩羊:BAABLAAFFH8PAAIEAAMIuQrMewBhAAAEAAMIuQrMewBhAAABLAAFFAYIIQALAO0cAA==.',['無心']='無心無傷:BAAALAAECgMIBwAAAA==.無心無竹:BAAALAAECgYIBgAAAA==.',['煌竹']='煌竹:BAAALAAFFAIIAgAAAA==.',['熏丶']='熏丶儿:BAABLAAFFH8UAAIXAAYIbhCFCAA0AQAXAAYIbhCFCAA0AQAAAA==.',['爆浆']='爆浆麻薯:BAACLAAFFH8GAAIHAAIInCJVJACyAAAHAAIInCJVJACyAAAsAAQKfyAAAgcABwgkJYAhAMMCAAcABwgkJYAhAMMCAAAA.',['爱憎']='爱憎的罗克珊:BAAALAAECgUIBQAAAA==.',['爱美']='爱美女的菠萝:BAACLAAFFH8HAAMDAAIIiBPPKgByAAADAAIIBAvPKgByAAAEAAIIiBN1oQA+AAAsAAQKfxkAAwQACAhgHICQAMQBAAQABwirGoCQAMQBAAMABQiNGLBZAFMBAAAA.',['牛呀']='牛呀牛呀:BAAALAADCgIIAgAAAA==.',['牛爪']='牛爪解衣:BAAALAAECgYIBwAAAA==.',['狮子']='狮子座流星:BAACLAAFFH8GAAIEAAYIchxIKQCOAQAEAAYIchxIKQCOAQAsAAQKfxQAAgQABgiKGQ1iAH4BAAQABgiKGQ1iAH4BAAAA.',['猎祖']='猎祖猎宗:BAABLAAFFH8HAAIeAAMIsQ/lAwCiAAAeAAMIsQ/lAwCiAAAAAA==.',['猪大']='猪大帝:BAAALAAECgMIAwAAAA==.',['獵魔']='獵魔:BAAALAADCgYIBgAAAA==.',['玛丽']='玛丽罗斯:BAABLAAFFH8iAAIYAAYImhzqBACzAQAYAAYImhzqBACzAQAAAA==.',['瓦格']='瓦格里女武神:BAAALAAECgYICQAAAA==.',['用血']='用血铸就荣耀:BAAALAAECgYICwAAAA==.',['男魔']='男魔:BAAALAADCgEIAQAAAA==.',['疯狂']='疯狂的丫头:BAAALAAECgIIAgAAAA==.',['瘦成']='瘦成一道闪电:BAAALAADCgEIAQAAAA==.',['白花']='白花恋诗:BAAALAADCgEIAQAAAA==.',['白衣']='白衣未央:BAAALAAECggICwAAAA==.',['百思']='百思不得琪姐:BAAALAAECgIIAgAAAA==.',['皮皮']='皮皮虾之怒:BAABLAAFFH8OAAIEAAIIMQx8mQBBAAAEAAIIMQx8mQBBAAAAAA==.皮皮辰:BAAALAAFFAQIBAAAAA==.',['盗魂']='盗魂之刃:BAAALAADCggICQAAAA==.',['盛放']='盛放的菊花:BAAALAAFFAIIAgAAAA==.',['眉霏']='眉霏色舞:BAAALAADCgIIAgAAAA==.',['看起']='看起就魁梧:BAAALAAECgYICAAAAA==.',['睡不']='睡不醒的撒旦:BAAALAAECggICAAAAA==.',['睿恩']='睿恩不要怕:BAABLAAECn8XAAMTAAYIIAdAIwCkAAATAAYIIAdAIwCkAAASAAEIXwkAAAAAAAAAAA==.',['瞌睡']='瞌睡虫虫:BAAALAADCgQIBQAAAA==.',['瞪誰']='瞪誰誰乱舞丶:BAAALAAECgIIAgAAAA==.',['矜持']='矜持丶先森:BAACLAAFFH8OAAINAAIIHiJXEACOAAANAAIIHiJXEACOAAAsAAQKfxYAAg0ABwh8I/QcADMCAA0ABwh8I/QcADMCAAAA.',['短脚']='短脚皮卡丘:BAABLAAFFH8IAAIPAAgIcwCRbgAjAAAPAAgIcwCRbgAjAAAAAA==.',['砍断']='砍断天柱:BAAALAADCgIIAgAAAA==.',['破哥']='破哥:BAAALAAECgMIBAAAAA==.',['破尔']='破尔萨斯:BAAALAAECgQIBQAAAA==.',['破碎']='破碎的残阳:BAAALAAFFAIIAwAAAA==.',['破鲁']='破鲁尔法:BAAALAAECgQIBAAAAA==.',['碎玉']='碎玉闪电:BAABLAAFFH8IAAIRAAIIiwmaIAAzAAARAAIIiwmaIAAzAAABLAAFFAYIIQALAO0cAA==.',['神箭']='神箭乄九天:BAAALAAECgQIBQAAAA==.',['秋风']='秋风恋雪:BAAALAAFFAIIAgAAAA==.',['稻草']='稻草人:BAAALAADCgYIBgAAAA==.',['穆小']='穆小青:BAABLAAFFH8FAAIGAAMI0AmINwCMAAAGAAMI0AmINwCMAAAAAA==.',['笘柴']='笘柴:BAAALAADCgQIBAAAAA==.',['笨啦']='笨啦等:BAAALAADCgYIBgAAAA==.',['笨笨']='笨笨丶有块糖:BAAALAADCgcIBwAAAA==.',['笼中']='笼中雀:BAAALAAECgQIBAAAAA==.',['等待']='等待援助:BAAALAAECgYIBgAAAA==.',['简单']='简单旋律:BAAALAAECggIDgAAAA==.',['米色']='米色糖:BAAALAADCgEIAQAAAA==.',['粪不']='粪不痼僧:BAAALAAECgMIAwAAAA==.',['粪法']='粪法涂墙:BAAALAAECgMIAwAAAA==.',['糖门']='糖门滚:BAABLAAFFH8SAAIIAAUIiBTRNQA5AQAIAAUIiBTRNQA5AQABLAAFFAYIIQALAO0cAA==.',['純丶']='純丶德:BAAALAAECgQIBQAAAA==.',['絶蝂']='絶蝂锋少:BAABLAAFFH80AAMQAAYIAyQrCAAJAgAQAAYIAyQrCAAJAgAMAAQIQhRfFgAoAQAAAA==.',['纯爱']='纯爱战神:BAAALAAECgYIBgAAAA==.',['终极']='终极菜鸟:BAABLAAFFH8IAAMQAAUI9AtVHQDgAAAQAAUISARVHQDgAAAXAAIIEhy4DgCiAAAAAA==.',['给力']='给力有木有:BAACLAAFFH8KAAIFAAIIIR1tRwCpAAAFAAIIIR1tRwCpAAAsAAQKfxUAAgUABgjuJLshAPIBAAUABgjuJLshAPIBAAAA.',['缺德']='缺德:BAABLAAFFH8MAAIGAAMIYBlPJwDdAAAGAAMIYBlPJwDdAAABLAAFFAYIIQALAO0cAA==.',['罗拉']='罗拉琼斯:BAAALAADCgQIBAAAAA==.',['羊大']='羊大仙儿:BAAALAAFFAMIAwAAAA==.羊大侠:BAABLAAFFH8RAAIEAAYI8RxAKgCLAQAEAAYI8RxAKgCLAQAAAA==.',['羊太']='羊太鲜儿:BAACLAAFFH8cAAIFAAcItCA0DAA4AgAFAAcItCA0DAA4AgAsAAQKfxgAAgUABgjsHhSeAMoBAAUABgjsHhSeAMoBAAAA.',['美人']='美人泪杯中酒:BAAALAAFFAEIAQAAAA==.',['美女']='美女记不住:BAAALAADCgIIAgAAAA==.',['老司']='老司机的阴谋:BAACLAAFFH8IAAMEAAIIcxJiswA1AAAEAAEI6QdiswA1AAADAAEI/RwRHgAAAAAsAAQKfxgAAwMABwgpHqkOAGABAAQABgjDFfdwAGIBAAMABgh8GqkOAGABAAAA.',['老牛']='老牛在腰間:BAAALAAECggIEgAAAA==.',['耶拉']='耶拉冈德:BAAALAAFFAIIAgAAAA==.',['聖光']='聖光裁决使者:BAAALAAECgIIAgAAAA==.',['聪明']='聪明的石头人:BAAALAAECgYICgAAAA==.',['肥德']='肥德肥肥的:BAABLAAECn8VAAMGAAYIBQy9YACZAAAGAAYIBQy9YACZAAAUAAMI5AqrigCZAAAAAA==.',['肥肉']='肥肉减伤:BAAALAAECgYIBgAAAA==.',['背叛']='背叛:BAAALAAFFAIIAgAAAA==.',['色精']='色精灵:BAABLAAFFH8RAAMMAAUIkw+TGAACAQAMAAQI3xGTGAACAQAQAAEIVwSadwA5AAABLAAFFAYIIQALAO0cAA==.',['艾斯']='艾斯蒂:BAAALAAECgYIDQAAAA==.',['艾欧']='艾欧灬洛斯:BAAALAAECgEIAQAAAA==.',['艾瑞']='艾瑞莉娅:BAAALAAECgUIBgAAAA==.',['艾萨']='艾萨琳:BAAALAAECgUICQAAAA==.',['艾达']='艾达晨光:BAAALAAECgMIAwAAAA==.',['花花']='花花:BAAALAADCgYIDAAAAA==.',['芹泽']='芹泽多魔雄:BAAALAAECgYIDgAAAA==.',['若水']='若水寒冰:BAABLAAFFH8GAAIHAAYIHAViLQDwAAAHAAYIHAViLQDwAAAAAA==.',['苦逼']='苦逼的他:BAACLAAFFH8KAAIHAAIIcB8wIwC2AAAHAAIIcB8wIwC2AAAsAAQKfx0AAgcACAgCH6EgAMgCAAcACAgCH6EgAMgCAAAA.',['苹果']='苹果放头上:BAABLAAECn8UAAMEAAYIbRNTkQAuAQAEAAYIbRNTkQAuAQADAAMIIgqgngB6AAAAAA==.',['莉娅']='莉娅娜:BAAALAADCgIIAgAAAA==.',['莫格']='莫格丨莱尼:BAAALAAFFAIIBAAAAA==.',['莫装']='莫装逼:BAAALAADCgQIBAAAAA==.',['萌萌']='萌萌小宝宝:BAABLAAFFH8HAAIQAAIIsxXxOgCiAAAQAAIIsxXxOgCiAAAAAA==.萌萌小宝宝哟:BAAALAAFFAIIAgAAAA==.萌萌小犇:BAAALAAECgIIAgAAAA==.',['萦梦']='萦梦丶巨龙:BAAALAAECggICgAAAA==.',['落葉']='落葉:BAAALAADCgEIAQAAAA==.',['蒲尼']='蒲尼阿摩:BAABLAAFFH8IAAIRAAgIjiFBAgCCAgARAAgIjiFBAgCCAgAAAA==.',['蓉熹']='蓉熹:BAAALAAECgYIBwAAAA==.',['蓝色']='蓝色空间:BAABLAAFFH8FAAIEAAUIvhDfTQAWAQAEAAUIvhDfTQAWAQAAAA==.蓝色草莓:BAAALAADCgcIEwAAAA==.',['蔷薇']='蔷薇与剑:BAAALAAECggICAAAAA==.',['薩菲']='薩菲羅斯丶:BAABLAAFFH8KAAIPAAIIOxL1WQBDAAAPAAIIOxL1WQBDAAAAAA==.',['虎痴']='虎痴:BAAALAAECgEIAQAAAA==.',['虎賁']='虎賁:BAAALAAECgEIAQAAAA==.',['蜡笔']='蜡笔丨小刚:BAACLAAFFH8uAAINAAYIiw44BgBSAQANAAYIiw44BgBSAQAsAAQKfzsAAw0ACAhNFnghABICAA0ACAhNFnghABICAAoAAghoBBP5AEsAAAAA.蜡笔丨小旧:BAABLAAFFH8YAAMHAAUIKQxcKgAXAQAHAAUIJQpcKgAXAQAOAAMIVwm2IwBeAAAAAA==.',['血无']='血无情:BAAALAADCggICAAAAA==.',['血柯']='血柯基:BAABLAAFFH8LAAIFAAMIGAn8aAByAAAFAAMIGAn8aAByAAABLAAFFAYIIQALAO0cAA==.',['血火']='血火同源:BAAALAADCgcICAAAAA==.',['血甲']='血甲丶龙龙:BAAALAAFFAIIAwAAAA==.',['血色']='血色灰壗:BAABLAAFFH8VAAIQAAYIAB2oFQChAQAQAAYIAB2oFQChAQAAAA==.血色飘舞:BAACLAAFFH8OAAIPAAYICBi5GgCcAQAPAAYICBi5GgCcAQAsAAQKfxwAAg8ACAj/HCoSAEwCAA8ACAj/HCoSAEwCAAAA.',['被阴']='被阴的小龍女:BAAALAAECgYICAAAAA==.',['西瓜']='西瓜是方的:BAAALAADCgYIBgAAAA==.',['记住']='记住爷背影:BAAALAAECgMIAwAAAA==.',['话多']='话多:BAABLAAFFH8GAAIRAAYIuh30CwCEAQARAAYIuh30CwCEAQAAAA==.',['谁爱']='谁爱上你的醉:BAAALAAECgcIEAAAAA==.',['贞德']='贞德:BAAALAADCggICAAAAA==.',['赛德']='赛德克巴莱:BAABLAAECn8eAAIQAAYIYxqWRQCLAQAQAAYIYxqWRQCLAQAAAA==.',['赛文']='赛文丶凹凸曼:BAAALAADCgQIBAAAAA==.',['走位']='走位很风骚:BAAALAAECgQIBAAAAA==.',['超级']='超级大腿:BAAALAAECgYIDAAAAA==.超级志:BAAALAAFFAYIAQAAAA==.',['超薄']='超薄也有距离:BAAALAAECgYIBgAAAA==.',['跳一']='跳一下:BAABLAAFFH8GAAIEAAYI9RGLDQDIAQAEAAYI9RGLDQDIAQAAAA==.',['辛多']='辛多雷之怒:BAAALAADCgYIBgAAAA==.',['达尔']='达尔盖的旗帜:BAAALAAECgYIBwAAAA==.',['达盖']='达盖尔先锋团:BAAALAADCggIDAAAAA==.',['迈巴']='迈巴赫:BAAALAAECgIIBAAAAA==.',['这个']='这个比较简单:BAAALAADCgIIAgAAAA==.',['远古']='远古巨龙:BAAALAAECgYICAAAAA==.',['迷雾']='迷雾:BAAALAAFFAIIAgAAAA==.',['追风']='追风射日:BAAALAAECgYIBQAAAA==.',['逍遥']='逍遥珑珠:BAAALAADCgYIBgAAAA==.逍遥魅影:BAAALAADCgEIAQAAAA==.',['逗乳']='逗乳大官人:BAAALAAECgYICwAAAA==.',['逝者']='逝者不死:BAAALAADCgIIAgAAAA==.',['速度']='速度:BAAALAADCgYIBgAAAA==.',['遗忘']='遗忘的白开水:BAACLAAFFH8NAAIFAAIIVRk+fwBGAAAFAAIIVRk+fwBGAAAsAAQKfyAAAgUACAhhG5QmANwBAAUACAhhG5QmANwBAAAA.',['邓太']='邓太阿:BAAALAAECgMIAwAAAA==.',['那个']='那个劣仁:BAAALAAECgQIBAAAAA==.',['酸哥']='酸哥:BAABLAAFFH8HAAIGAAIIjxW6KwB/AAAGAAIIjxW6KwB/AAAAAA==.',['銩昵']='銩昵佬姆:BAABLAAFFH8GAAIMAAYIBQRaFgApAQAMAAYIBQRaFgApAQAAAA==.',['铁血']='铁血牛牛:BAABLAAFFH8MAAIOAAYIvRBLEwApAQAOAAYIvRBLEwApAQAAAA==.',['锁甲']='锁甲第二废:BAAALAAECgYIBgAAAA==.',['键来']='键来:BAABLAAFFH8WAAIeAAII8R5HAwCpAAAeAAII8R5HAwCpAAAAAA==.',['阿炳']='阿炳:BAABLAAFFH8IAAIbAAIIshWtEgA5AAAbAAIIshWtEgA5AAABLAAFFAYIIQALAO0cAA==.',['雨夜']='雨夜惊魂:BAAALAADCgYIBgAAAA==.',['雪児']='雪児:BAAALAADCgYIBgAAAA==.',['雪后']='雪后初晴:BAAALAAFFAYIBAABLAAFFAgIFAAZANIFAA==.',['雪舞']='雪舞依:BAAALAADCggIDwAAAA==.',['零零']='零零龍:BAAALAAFFAIIAgAAAA==.',['零露']='零露瀼瀼:BAAALAAFFAIIBAAAAA==.',['雷霆']='雷霆嘎嘎:BAAALAADCgYIBgAAAA==.',['雾绕']='雾绕山空:BAAALAAECggIBgAAAA==.',['露基']='露基雅:BAAALAAECgYIEQAAAA==.',['露露']='露露的牛:BAAALAAFFAIIAgAAAA==.',['青提']='青提茉莉:BAABLAAFFH8dAAIRAAgIow5UBwDbAQARAAgIow5UBwDbAQAAAA==.',['青海']='青海少年:BAAALAAFFAIIAgAAAA==.',['静修']='静修之猎刃:BAABLAAFFH8FAAIEAAUIuAT6ZwCWAAAEAAUIuAT6ZwCWAAAAAA==.',['面摊']='面摊老板:BAABLAAFFH8QAAIOAAgIyh4xAgBqAgAOAAgIyh4xAgBqAgAAAA==.',['風主']='風主霜城:BAAALAAECgMIAwAAAA==.',['风白']='风白羽:BAAALAAECgYIBgAAAA==.',['风起']='风起叶落:BAAALAADCgEIAQAAAA==.',['飞翔']='飞翔的西瓜丶:BAAALAADCgcIBwAAAA==.',['饿虎']='饿虎残龙:BAAALAAECggICwAAAA==.',['馒头']='馒头泡:BAAALAAECgUIBQAAAA==.',['首席']='首席西厂侯爷:BAAALAAECgQIBAAAAA==.',['香蕉']='香蕉柠檬桔:BAAALAAFFAIIAwAAAA==.香蕉苹果橙:BAAALAAFFAIIAgAAAA==.',['驯狐']='驯狐师:BAABLAAFFH8IAAIEAAII6BU+VACTAAAEAAII6BU+VACTAAAAAA==.',['高级']='高级助理:BAABLAAFFH8GAAIFAAIIXBDzgwBEAAAFAAIIXBDzgwBEAAAAAA==.',['魂之']='魂之晚歌:BAAALAAECgYIDQAAAA==.',['魇魔']='魇魔夜疯:BAAALAADCgYIBgAAAA==.',['魔力']='魔力毁灭:BAAALAAECgUIBQAAAA==.',['魔牙']='魔牙玲玲:BAAALAAECgYIDQAAAA==.',['魔魔']='魔魔峰:BAABLAAFFH8KAAIGAAYIqAVoKQDNAAAGAAYIqAVoKQDNAAAAAA==.魔魔风:BAAALAADCggIDgAAAA==.',['鱼的']='鱼的花:BAAALAADCgIIAgAAAA==.',['鸽王']='鸽王:BAAALAAECggIDgABLAAFFAgIPgAfAMAlAA==.',['鹤唳']='鹤唳芳茶:BAAALAAECgYICgAAAA==.',['鹿茸']='鹿茸小绷带:BAABLAAFFH8QAAIGAAIITg50RgBiAAAGAAIITg50RgBiAAAAAA==.',['黑暗']='黑暗盛典:BAAALAAECgMIAwAAAA==.',['黑眼']='黑眼圈不黑:BAAALAADCgcIBwAAAA==.',['黑色']='黑色金属:BAAALAAECgYICwAAAA==.',['黑骑']='黑骑也风骚:BAABLAAFFH82AAIFAAYI1iCZFwDbAQAFAAYI1iCZFwDbAQAAAA==.',['鼻毛']='鼻毛怪叔叔:BAAALAADCgYIBgAAAA==.',['龙头']='龙头在胸口:BAAALAAECggIBwAAAA==.',['龙骑']='龙骑死:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end