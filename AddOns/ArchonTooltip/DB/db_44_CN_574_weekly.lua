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
 local lookup = {'Rogue-Assassination','DeathKnight-Frost','Paladin-Retribution','Druid-Restoration','Hunter-BeastMastery','Evoker-Preservation','Warlock-Destruction','DeathKnight-Blood','DeathKnight-Unholy','Hunter-Marksmanship','Priest-Holy','Shaman-Restoration','Monk-Mistweaver','Monk-Brewmaster','Shaman-Elemental','DemonHunter-Havoc','Druid-Feral','Priest-Shadow','Mage-Arcane','Mage-Frost','Warrior-Fury','Warrior-Arms','Hunter-Survival','Warrior-Protection','DemonHunter-Vengeance','Warlock-Demonology','Priest-Discipline','Paladin-Holy','Paladin-Protection','Monk-Windwalker','Shaman-Enhancement','Unknown-Unknown','Evoker-Devastation',}; local provider = {region='CN',realm='元素之力',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ay='Ayanamirei:BAACLAAFFH86AAIBAAcIcRsrBACsAQABAAcIcRsrBACsAQAsAAQKf0YAAgEACAjDIIgJAO4CAAEACAjDIIgJAO4CAAAA.',Cc='Ccone:BAABLAAFFH8IAAICAAIIrwyOjgA/AAACAAIIrwyOjgA/AAAAAA==.',Da='Daniel:BAAALAADCgYIBgAAAA==.',De='Devilkin:BAACLAAFFH8eAAICAAUIwQxCMADaAAACAAUIwQxCMADaAAAsAAQKfxoAAgIACAhgHRYaABsCAAIACAhgHRYaABsCAAAA.',Ez='Ezreal:BAAALAAECgIIAgAAAA==.',Fd='Fdsa:BAAALAADCgMIAwAAAA==.',Fu='Futura:BAAALAAECgMIAwAAAA==.',Gl='Glitch:BAAALAAFFAIIAwAAAA==.',Hy='Hymen:BAABLAAFFH8IAAIDAAMIYx1OPQCeAAADAAMIYx1OPQCeAAAAAA==.',Ka='Kazekami:BAABLAAFFH8YAAIEAAUIIR8UEADEAQAEAAUIIR8UEADEAQAAAA==.',Ma='Maddk:BAABLAAFFH8GAAICAAIIexmXcQBQAAACAAIIexmXcQBQAAAAAA==.Madmagic:BAAALAAECgMIBAAAAA==.',Me='Mediumraree:BAAALAAFFAIIAgAAAA==.',No='Norton:BAABLAAFFH8SAAIFAAYIRRibLwB5AQAFAAYIRRibLwB5AQAAAA==.',Ok='Okb:BAABLAAFFH8GAAIGAAYIvx7KBwDwAQAGAAYIvx7KBwDwAQAAAA==.',Pl='Playeredmtrt:BAAALAAFFAIIAgAAAA==.',Qi='Qingyi:BAAALAAECgYIAQAAAA==.',Ra='Ray:BAAALAAFFAQIBAAAAA==.',Re='Reveke:BAAALAAECggIEAAAAA==.',Sa='Sar:BAABLAAFFH8IAAIHAAYInAoYGACUAQAHAAYInAoYGACUAQAAAA==.Savina:BAACLAAFFH8JAAMCAAMIUQ+7MwDOAAACAAMI3Q67MwDOAAAIAAEIDAPSGAA2AAAsAAQKfxgAAwIACAhAHNZdADoCAAIABwi8H9ZdADoCAAkAAwjXEe9GAKgAAAAA.',Se='Seira:BAAALAADCgIIAgAAAA==.',So='Solusek:BAAALAAECggICAAAAA==.',Ta='Tanker:BAAALAAECgIIAgAAAA==.',Th='Thenewday:BAAALAAECgEIAQAAAA==.',Vi='Visenna:BAAALAAECgMIAwAAAA==.',We='Weiorange:BAAALAAECgcIBwAAAA==.',Zh='Zhleo:BAAALAADCggICAAAAA==.',['一分']='一分熟透:BAACLAAFFH8JAAIFAAMIKBtCQgCjAAAFAAMIKBtCQgCjAAAsAAQKfx8AAwUACAjdIQwZAGYCAAUACAjdIQwZAGYCAAoAAQgFDufAAC8AAAAA.',['七星']='七星乱舞:BAAALAAECgYIBgAAAA==.',['三分']='三分熟:BAAALAAECgYIBwAAAA==.',['不老']='不老:BAAALAAECgQIBAAAAA==.不老亡魂:BAACLAAFFH8KAAILAAMIKQfONACTAAALAAMIKQfONACTAAAsAAQKfy0AAgsACAjWEX9CAM0BAAsACAjWEX9CAM0BAAAA.',['且随']='且随风行:BAABLAAFFH8JAAIDAAMISxC5HADkAAADAAMISxC5HADkAAAAAA==.',['东方']='东方烧饼:BAACLAAFFH8OAAMCAAYIGQ5ARAApAQACAAUItxBARAApAQAIAAEIAwGCIAARAAAsAAQKfxgAAgIABggwFmZfADABAAIABggwFmZfADABAAEsAAUUBggSAAUARRgA.',['丝丝']='丝丝:BAAALAADCgMIAwAAAA==.',['两蛋']='两蛋一鸡:BAAALAADCgYIBgAAAA==.',['丶壊']='丶壊丨囝囝:BAABLAAFFH8GAAICAAYIrgmlGQBjAQACAAYIrgmlGQBjAQAAAA==.',['丶莉']='丶莉亚丨德瞎:BAAALAAFFAIIAgAAAA==.',['丿少']='丿少女的噩梦:BAAALAAECgcIBwAAAA==.',['乌白']='乌白菜:BAAALAAECgUIBQAAAA==.',['乔克']='乔克叔叔:BAAALAADCgcICAAAAA==.',['九一']='九一大神:BAAALAADCggICAAAAA==.',['事后']='事后清晨:BAAALAAFFAIIAwAAAA==.',['云冰']='云冰吟:BAAALAAECgUIBQAAAA==.',['亚路']='亚路基:BAAALAAECgYIBgAAAA==.',['亦乐']='亦乐:BAAALAAECgUICAAAAA==.',['你不']='你不要过来呀:BAAALAAECgEIAQAAAA==.',['你没']='你没四件套吗:BAAALAAECgUIBQAAAA==.',['你的']='你的柔情似水:BAAALAAECgYICgAAAA==.',['你选']='你选择你喜欢:BAABLAAFFH8FAAIMAAII7gkuZgBUAAAMAAII7gkuZgBUAAAAAA==.',['佫啰']='佫啰姆丶狗蛋:BAAALAAECgYIDQAAAA==.',['佳期']='佳期如梦丶:BAACLAAFFH8pAAMNAAYIZRasBwC2AQANAAYIZRasBwC2AQAOAAEIWgATIAAdAAAsAAQKfxgAAg0ABggCIygKABwCAA0ABggCIygKABwCAAAA.',['侯里']='侯里斯骑天:BAAALAAFFAMIBAAAAA==.',['元素']='元素飒:BAAALAAECgYICQAAAA==.',['克洛']='克洛:BAAALAAECgYIBwAAAA==.',['兜兜']='兜兜松松:BAAALAAFFAgIAgAAAA==.',['养牛']='养牛专业户:BAACLAAFFH8KAAMPAAMIThtHJQCdAAAPAAMIThtHJQCdAAAMAAEIhRJidAA3AAAsAAQKfzsAAwwACAihJPcFADUDAAwACAihJPcFADUDAA8ACAiYIRsTAPsCAAAA.',['冯寳']='冯寳寳:BAAALAAFFAIIAgAAAA==.',['冰坦']='冰坦:BAAALAADCgEIAQAAAA==.',['凌彻']='凌彻:BAABLAAFFH8IAAIQAAYIESP2DQD0AQAQAAYIESP2DQD0AQAAAA==.',['凌晨']='凌晨一点钟:BAAALAAECgYIDAAAAA==.凌晨一點鐘:BAABLAAFFH8FAAIRAAMIpAntCgB4AAARAAMIpAntCgB4AAABLAAFFAYIEgAFAEUYAA==.',['凡天']='凡天:BAAALAAECgUIBQAAAA==.',['凯雷']='凯雷德:BAAALAAECgUIBQAAAA==.',['刀刀']='刀刀斋丶:BAAALAAECgIIAgAAAA==.',['刘老']='刘老师:BAAALAADCgcIBwAAAA==.',['别急']='别急读条呢:BAAALAADCgQICAAAAA==.',['别惹']='别惹小野猪:BAAALAADCgYIBgAAAA==.',['勇敢']='勇敢的虫虫:BAABLAAECn8dAAIQAAYIaxunOAB3AQAQAAYIaxunOAB3AQAAAA==.',['千何']='千何小依:BAAALAAECgYIBgAAAA==.',['千荷']='千荷图图:BAAALAAECgQIBAAAAA==.千荷壹:BAACLAAFFH8JAAILAAIIaRrbJQChAAALAAIIaRrbJQChAAAsAAQKfxsAAwsACAhgFyAwACACAAsACAhgFyAwACACABIAAQg1AaOpABUAAAAA.千荷小德:BAAALAAECgUICgAAAA==.',['卖火']='卖火柴的傻馒:BAABLAAFFH8HAAMPAAYILwMLOQB0AAAPAAYILwMLOQB0AAAMAAEI8wHngAAeAAAAAA==.卖火柴的悟空:BAAALAAFFAYIAgAAAA==.卖火柴的朮丗:BAAALAAFFAIIAgAAAA==.',['卡罗']='卡罗卡曼:BAAALAAECgIIAgAAAA==.',['反冻']='反冻派:BAABLAAFFH8TAAITAAYIvA8zKwBkAQATAAYIvA8zKwBkAQAAAA==.',['只有']='只有香如故:BAAALAADCgEIAQAAAA==.',['可爱']='可爱灰兔:BAABLAAFFH8GAAIOAAYIaguREQAwAQAOAAYIaguREQAwAQAAAA==.',['史忽']='史忽浩佷:BAACLAAFFH8cAAMMAAYIhyLVBgBUAgAMAAYIhyLVBgBUAgAPAAIIXBFFMwCRAAAsAAQKfx0AAw8ACAg5Er0vAFQBAA8ABgj/Fr0vAFQBAAwACAixEg9RABcBAAAA.',['右手']='右手黑暗:BAAALAAFFAIIAgAAAA==.',['名字']='名字想半天:BAAALAAECgYIDQAAAA==.',['吠陀']='吠陀:BAAALAAECgIIAwAAAA==.',['听风']='听风的蚕:BAACLAAFFH8FAAIFAAII/AiWcQB9AAAFAAII/AiWcQB9AAAsAAQKfxkAAgUABwhnF3mCANoBAAUABwhnF3mCANoBAAAA.听风看海:BAAALAADCgYIBgAAAA==.',['吴钩']='吴钩似雪:BAAALAAECgYIBgAAAA==.',['呼阿']='呼阿优丶:BAAALAADCgEIAQAAAA==.',['咕噜']='咕噜咯呜嗯:BAAALAAECgMIBAAAAA==.',['咸鱼']='咸鱼小熊猫:BAAALAADCgQIBAAAAA==.',['哈库']='哈库拉嗨比:BAABLAAFFH8HAAIDAAIIthUtfAA1AAADAAIIthUtfAA1AAAAAA==.',['哈莉']='哈莉贝瑞:BAABLAAFFH8JAAIMAAIIERvURQCUAAAMAAIIERvURQCUAAAAAA==.',['唯夜']='唯夜丶:BAAALAAFFAIIAgAAAA==.',['喔胖']='喔胖大叔:BAABLAAFFH8GAAICAAIIiRpHWgCbAAACAAIIiRpHWgCbAAAAAA==.',['噬魂']='噬魂草草:BAAALAADCgEIAQAAAA==.',['四十']='四十个萨满:BAAALAAECggIEAAAAA==.',['回家']='回家的呆呆:BAAALAAFFAIIAwAAAA==.',['回归']='回归:BAAALAAECgYICQAAAA==.',['团长']='团长我躺哪儿:BAACLAAFFH8gAAIUAAYItR2QAwCnAQAUAAYItR2QAwCnAQAsAAQKfyIAAhQABgh8JMoKAA8CABQABgh8JMoKAA8CAAEsAAUUCAhCABMAxiEA.',['圣光']='圣光小罗莉:BAABLAAFFH8GAAIDAAIIfRfhRwCZAAADAAIIfRfhRwCZAAAAAA==.',['地狱']='地狱小吼:BAACLAAFFH8GAAIVAAMIFAxMPAB/AAAVAAMIFAxMPAB/AAAsAAQKfx4AAxUACAjjGg81AGECABUACAgFGQ81AGECABYABwjMFiMPAOIBAAAA.',['地蛋']='地蛋:BAAALAAFFAIIBAABLAAFFAYIEgAFAEUYAA==.',['埃估']='埃估漬帅帅:BAAALAAECggICQAAAA==.',['墨雾']='墨雾烧:BAABLAAECn8VAAIVAAcIrRg5KAC/AQAVAAcIrRg5KAC/AQAAAA==.',['壹身']='壹身痞气:BAAALAAFFAIIAgAAAA==.',['夜子']='夜子寒:BAAALAAECgYIBgAAAA==.',['夜孑']='夜孑寒:BAAALAAECgEIAQAAAA==.',['大佬']='大佬黑:BAACLAAFFH8NAAIFAAMI9RcYaACVAAAFAAMI9RcYaACVAAAsAAQKfxsABAUACAhnH+cmALwCAAUACAgCH+cmALwCABcABQhvGsoSAH8BAAoABAiXEz6AANsAAAAA.',['大白']='大白兔奶牛:BAAALAAECggIDgABLAAFFAgIDAAEAIIjAA==.',['天下']='天下我最吼:BAABLAAECn8ZAAQWAAgI2w71FgB3AQAWAAcI6w31FgB3AQAVAAUI2wq+wAD5AAAYAAQIZAfMfQCPAAAAAA==.',['天天']='天天得开心:BAAALAAFFAIIAgAAAA==.天天都开心:BAAALAAFFAIIBAAAAA==.天天须开心:BAAALAAFFAIIAwAAAA==.',['天机']='天机丶蒂尼:BAAALAAFFAIIAQAAAA==.',['天棒']='天棒:BAAALAAECgQIBAAAAA==.',['天空']='天空捌号丶:BAABLAAFFH8JAAIMAAYI9hpyDwDrAQAMAAYI9hpyDwDrAQAAAA==.天空柒号丶:BAABLAAFFH8WAAIMAAYILB5xDQABAgAMAAYILB5xDQABAgAAAA==.天空玖号丶:BAABLAAFFH8HAAIMAAYIxRMSHAB7AQAMAAYIxRMSHAB7AQAAAA==.',['太乙']='太乙真人:BAAALAAECgMIAwAAAA==.',['头顶']='头顶尖尖的:BAAALAAECgYIBgAAAA==.',['奥术']='奥术射击:BAAALAAECggICAAAAA==.',['女为']='女为曰己者容:BAAALAAFFAMIAwAAAA==.',['奶水']='奶水丶不够:BAAALAADCgcIBwAAAA==.',['威武']='威武牛战:BAAALAAFFAMIAwAAAA==.',['婷婷']='婷婷:BAAALAAECgYIEQAAAA==.',['嫒嫒']='嫒嫒的小母牛:BAAALAAECgIIAgAAAA==.',['宇宙']='宇宙无敌暴龙:BAABLAAFFH8FAAIZAAII9QORGQBQAAAZAAII9QORGQBQAAAAAA==.',['寒舞']='寒舞寂:BAACLAAFFH8zAAMFAAcIZhQHFgBqAQAFAAcIZhQHFgBqAQAKAAMISAX8GwCZAAAsAAQKfzEAAwUACAiDH8AwAJYCAAUACAiDH8AwAJYCAAoACAg7FZk2AOMBAAAA.',['小乌']='小乌云:BAAALAAECgQICQAAAA==.',['小仓']='小仓貮号:BAAALAAECgUIBgAAAA==.',['小光']='小光头:BAABLAAFFH8JAAITAAIIXw6QVQBFAAATAAIIXw6QVQBFAAAAAA==.',['小学']='小学生丶:BAAALAAECgMIAwAAAA==.',['小心']='小心超人:BAAALAAFFAIIAgAAAA==.',['小杆']='小杆子:BAAALAAECgUIAgAAAA==.',['小汪']='小汪睡不醒:BAAALAAECgEIAQAAAA==.',['小海']='小海狗:BAAALAAECgIIAwAAAA==.',['小猫']='小猫夏绿蒂:BAAALAAECgUIBQAAAA==.小猫躲猫猫:BAAALAAECgMIAgAAAA==.',['小肥']='小肥桐:BAABLAAFFH8HAAIaAAIIbBnLDgBPAAAaAAIIbBnLDgBPAAAAAA==.',['小胖']='小胖哼:BAAALAAECgEIAQAAAA==.',['小蛋']='小蛋糕呀:BAABLAAECn8XAAIFAAcIGyKHUgA5AgAFAAcIGyKHUgA5AgAAAA==.',['小风']='小风瑾:BAAALAAFFAIIBAAAAA==.',['尐枕']='尐枕头跟着跑:BAAALAAFFAIIBAAAAA==.',['少年']='少年王之怒:BAACLAAFFH8KAAIIAAMIShJwEACEAAAIAAMIShJwEACEAAAsAAQKfx0AAggACAiWGJERADoCAAgACAiWGJERADoCAAAA.',['巫喵']='巫喵王:BAAALAAECgYIBAAAAA==.',['布珞']='布珞克斯:BAAALAAFFAMIAwAAAA==.',['希尔']='希尔瓦丶娜斯:BAAALAAECgYIBgAAAA==.',['希露']='希露菲叶特:BAABLAAFFH8PAAMLAAYIrBe0FQClAQALAAYIrBe0FQClAQASAAEIfQLALwA1AAAAAA==.',['席尔']='席尔瓦纳斯:BAACLAAFFH8IAAIaAAMIIRY1CQCPAAAaAAMIIRY1CQCPAAAsAAQKfy0AAhoACAgcH08JANUCABoACAgcH08JANUCAAAA.',['干掉']='干掉大飞哥:BAABLAAFFH8KAAIPAAYIHwWgKgDqAAAPAAYIHwWgKgDqAAAAAA==.',['干趴']='干趴大飞哥:BAAALAAECgYICwABLAAFFAYICgAPAB8FAA==.',['开黑']='开黑吗我选源:BAABLAAFFH8IAAIZAAII4wtSFABiAAAZAAII4wtSFABiAAAAAA==.',['归心']='归心:BAAALAADCggICAAAAA==.',['德神']='德神:BAABLAAECn8ZAAIEAAYIbB3VIQDEAQAEAAYIbB3VIQDEAQAAAA==.',['怎么']='怎么也睡不够:BAAALAAECgMIAwAAAA==.',['怒刚']='怒刚烈:BAAALAAECgYIBgAAAA==.',['性感']='性感美臀:BAAALAADCgMIAwAAAA==.',['恶来']='恶来:BAAALAAFFAIIAgAAAA==.',['恶魔']='恶魔蔻小琪:BAAALAAECgYICgAAAA==.',['悟嗳']='悟嗳慲訫:BAACLAAFFH8oAAQLAAYIWBM1FQCqAQALAAYIWBM1FQCqAQAbAAMIXQspBACIAAASAAIIvAIEMQAwAAAsAAQKfyAABBIACAgpD/1CAK0BABIACAgpD/1CAK0BAAsACAh4C6NsADUBABsABwirDn0PAOwAAAEsAAUUBwgzAAUAZhQA.',['愤丶']='愤丶怒之兽:BAAALAAECgMIBQAAAA==.',['我不']='我不配:BAAALAAECgYIDAAAAA==.',['我先']='我先端三个:BAABLAAFFH8KAAMCAAYIphPMGQBfAQAIAAYIlgdJBgB4AQACAAQIsRjMGQBfAQAAAA==.',['我的']='我的小可愛丶:BAAALAAECgMIAwAAAA==.',['我要']='我要壹个胖纸:BAAALAAFFAIIBAAAAA==.',['战将']='战将帝之情:BAAALAAECgYIDAAAAA==.',['戳死']='戳死联盟:BAAALAADCgIIAgAAAA==.',['打望']='打望:BAAALAAECgcIDQAAAA==.',['扶阿']='扶阿奶闯红灯:BAACLAAFFH8IAAIDAAMIbgrqRgB/AAADAAMIbgrqRgB/AAAsAAQKfx8AAgMACAjgGUZDAHICAAMACAjgGUZDAHICAAAA.',['拖拉']='拖拉鸡:BAAALAAECgEIAQAAAA==.',['捉鬼']='捉鬼小能手:BAABLAAFFH8IAAMYAAIIABT/KQA9AAAVAAII7QwuVgA/AAAYAAIIABT/KQA9AAABLAAFFAYIEgAFAEUYAA==.',['掉了']='掉了只月野兔:BAABLAAFFH8MAAIMAAIIqBJKVwBsAAAMAAIIqBJKVwBsAAAAAA==.',['摄政']='摄政王妃:BAAALAAECgEIAQAAAA==.',['撒哈']='撒哈拉哟吼:BAAALAAECgYICQAAAA==.',['擎天']='擎天柱:BAAALAAECgYICgAAAA==.',['文化']='文化流氓:BAAALAAECgYICAAAAA==.',['断箭']='断箭残血:BAAALAAECgMIAwAAAA==.',['新手']='新手中的大神:BAAALAAECgYIDAAAAA==.',['旗鼓']='旗鼓相当的鸟:BAABLAAFFH8GAAIIAAYI/BawAwDkAQAIAAYI/BawAwDkAQAAAA==.',['无敌']='无敌砍王:BAAALAAFFAEIAQAAAA==.无敌罗莉:BAAALAAECggICAAAAA==.无敌赛亚人:BAAALAAECgYIBgAAAA==.',['昔归']='昔归:BAAALAAECgEIAQAAAA==.',['星月']='星月相随:BAAALAAFFAIIBAAAAA==.',['是风']='是风就该自由:BAACLAAFFH8YAAIPAAYIex67EgCmAQAPAAYIex67EgCmAQAsAAQKfxgAAg8ABgixIhgcAMsBAA8ABgixIhgcAMsBAAAA.',['暗影']='暗影追风:BAAALAADCgEIAQAAAA==.',['暗想']='暗想:BAAALAAECgUIBQAAAA==.',['暴躁']='暴躁狐爷:BAAALAAECgYIBgAAAA==.',['最大']='最大西瓜:BAACLAAFFH8FAAIPAAII2QLFUQAwAAAPAAII2QLFUQAwAAAsAAQKfxUAAg8ABghQC9NSAMUAAA8ABghQC9NSAMUAAAAA.',['月璃']='月璃牧梦:BAAALAAFFAIIBAAAAA==.',['木头']='木头贝贝:BAACLAAFFH8GAAMaAAII9waNHgB2AAAaAAII9waNHgB2AAAHAAEILgOhcQAoAAAsAAQKfxgAAwcACAjyEJd4AJEBAAcABwiPD5d4AJEBABoABghlCzslAKkAAAAA.',['来治']='来治猩猩的你:BAABLAAECn8UAAIFAAYIXR+lcQD5AQAFAAYIXR+lcQD5AQAAAA==.',['柑橘']='柑橘乌云:BAAALAADCgIIAgAAAA==.',['柠檬']='柠檬树下:BAAALAAECgIIAgAAAA==.',['柳智']='柳智敏:BAABLAAFFH8OAAILAAQIjCBhDACJAQALAAQIjCBhDACJAQAAAA==.',['栨客']='栨客:BAAALAADCggICAAAAA==.',['梓嫣']='梓嫣宝蜜:BAABLAAFFH8UAAMLAAYI0glwHgBYAQALAAYI0glwHgBYAQAbAAEI6wHtCQAUAAAAAA==.',['梦中']='梦中的浮空城:BAAALAAFFAIIAwAAAA==.',['梨涡']='梨涡浅笑:BAABLAAFFH8GAAIQAAYI1RBqCwDsAQAQAAYI1RBqCwDsAQAAAA==.',['椰子']='椰子水:BAABLAAFFH8FAAIDAAIIhhS7PACgAAADAAIIhhS7PACgAAAAAA==.',['欧欧']='欧欧叉叉:BAABLAAFFH8IAAIMAAIIkyEXOgC6AAAMAAIIkyEXOgC6AAAAAA==.',['此螺']='此螺非彼狼:BAAALAAECggIEAAAAA==.',['武力']='武力压制:BAAALAAECgYIBgAAAA==.',['死亡']='死亡小狐狸:BAAALAAFFAIIAgAAAA==.死亡美感:BAAALAADCgYIBgAAAA==.',['每天']='每天都开心:BAABLAAFFH8GAAIHAAII/Q/LQQCVAAAHAAII/Q/LQQCVAAAAAA==.',['水工']='水工稳:BAAALAADCgQIBAAAAA==.',['沐丷']='沐丷苒:BAABLAAFFH8GAAMUAAIIwg96HQBOAAATAAIIBQRIYQB4AAAUAAEIthp6HQBOAAAAAA==.',['油老']='油老师狂热粉:BAAALAAFFAIIAgAAAA==.',['油面']='油面筋:BAABLAAFFH8JAAINAAMIWgloEgCUAAANAAMIWgloEgCUAAAAAA==.',['洛琪']='洛琪希:BAAALAAFFAIIAwABLAAFFAYIDwALAKwXAA==.',['浪打']='浪打郎:BAABLAAFFH8PAAIJAAMIzw4PDQCKAAAJAAMIzw4PDQCKAAAAAA==.',['清晨']='清晨:BAAALAAFFAIIBAAAAA==.',['清源']='清源妙道真君:BAAALAADCgUIBQAAAA==.',['清衣']='清衣晚风:BAABLAAFFH8JAAIUAAIIDSO8CAC/AAAUAAIIDSO8CAC/AAAAAA==.',['灵长']='灵长类:BAAALAAECgQIBAAAAA==.',['烟雨']='烟雨伊风:BAABLAAECn8XAAIDAAgIMh2BTwBRAgADAAgIMh2BTwBRAgAAAA==.',['熊老']='熊老师:BAAALAAECgQIBAAAAA==.',['熠闪']='熠闪:BAAALAADCgEIAQAAAA==.',['爱慕']='爱慕:BAAALAADCgUIBQAAAA==.',['爱沵']='爱沵妹旳情:BAAALAAFFAIIBAAAAA==.',['牌坊']='牌坊老男人:BAAALAAECgUIEAAAAA==.',['牛拾']='牛拾三:BAAALAADCgcIBwAAAA==.',['牛栏']='牛栏:BAAALAAFFAIIAgAAAA==.',['牧筱']='牧筱晓:BAAALAAFFAIIAgAAAA==.',['狐戈']='狐戈:BAAALAAECgYIBgAAAA==.',['猫迩']='猫迩葉:BAABLAAECn8bAAICAAgIThowSQBpAgACAAgIThowSQBpAgAAAA==.',['王魔']='王魔牛零零七:BAAALAAECgQIBAAAAA==.',['理性']='理性论马:BAABLAAFFH8MAAIMAAYIvhlUBQDxAQAMAAYIvhlUBQDxAQAAAA==.',['琐映']='琐映寒枫:BAACLAAFFH8HAAIcAAIIXQf7IgCAAAAcAAIIXQf7IgCAAAAsAAQKfxcABBwABghnEldBAFgBABwABghnEldBAFgBAAMAAwgvFtUuAdQAAB0AAgjdG1hoAGsAAAAA.',['田小']='田小菊花:BAAALAAECgQIBwAAAA==.',['病蕉']='病蕉:BAAALAADCgEIAQAAAA==.',['白白']='白白净净:BAAALAADCggICAAAAA==.',['白菜']='白菜:BAABLAAECn8XAAIDAAgIihzoTgBSAgADAAgIihzoTgBSAgAAAA==.',['白马']='白马非马:BAAALAAFFAIIAgAAAA==.',['百变']='百变怪:BAAALAAFFAIIAgAAAA==.',['百撕']='百撕吥得骑姐:BAAALAAECgIIAgAAAA==.',['盆鱼']='盆鱼宴:BAAALAAECgYIDAAAAA==.',['盗亦']='盗亦可道:BAAALAADCgcIBwAAAA==.',['眼神']='眼神秒杀:BAAALAAECgQIBAAAAA==.',['砰砰']='砰砰咻咻:BAAALAAECgYIBgAAAA==.',['碎锤']='碎锤:BAAALAADCgMIAwAAAA==.',['神僧']='神僧:BAAALAAFFAIIAwAAAA==.',['立正']='立正站好:BAAALAAECgUIBQAAAA==.',['等风']='等风来丶:BAAALAAECgYIDAAAAA==.',['筱晓']='筱晓:BAAALAAECgEIAQAAAA==.',['篱笆']='篱笆菜菜子:BAAALAAECgYIBgAAAA==.',['米砾']='米砾:BAAALAAECgIIAgAAAA==.',['糖门']='糖门不可无主:BAAALAAECgYIDAAAAA==.',['红一']='红一下求求了:BAAALAAFFAIIAgAAAA==.',['红楼']='红楼梦靥:BAABLAAFFH8NAAMeAAIIBgtjFwBwAAAeAAIIAgVjFwBwAAAOAAIIJwlBHABYAAABLAAFFAYIEgAFAEUYAA==.',['线性']='线性代数:BAABLAAFFH8XAAICAAQIERzYLwDcAAACAAQIERzYLwDcAAAAAA==.',['绝世']='绝世狐魔王:BAAALAAECgUIBQAAAA==.',['绞肉']='绞肉机:BAABLAAFFH8IAAIYAAIIiwqmJgBxAAAYAAIIiwqmJgBxAAAAAA==.',['缇啦']='缇啦米酥:BAAALAAECgMIAwAAAA==.',['群魔']='群魔大舞:BAAALAAECgQIBgAAAA==.',['老大']='老大:BAABLAAFFH8IAAMCAAMInwhVaQBwAAACAAMInwhVaQBwAAAIAAEIhAGMGQAkAAAAAA==.',['老杆']='老杆子:BAAALAAFFAIIBAAAAA==.',['老杨']='老杨:BAAALAAECgIIAgAAAA==.',['耶加']='耶加雪菲:BAAALAADCggICAAAAA==.',['腰肥']='腰肥屁大:BAAALAAECgMIAwAAAA==.',['自然']='自然随风:BAAALAADCgIIAgAAAA==.',['艺术']='艺术成分很高:BAAALAADCggICAAAAA==.',['艾米']='艾米莉安:BAAALAAECggIEQAAAA==.',['艾莉']='艾莉丝:BAAALAAFFAYIBAABLAAFFAYIDwALAKwXAA==.',['艾莲']='艾莲:BAABLAAFFH8KAAIUAAIIyCVsDwBoAAAUAAIIyCVsDwBoAAAAAA==.',['芋儿']='芋儿鸡:BAAALAAECgEIAQAAAA==.',['芙芙']='芙芙:BAABLAAFFH8WAAMMAAUI6Q1oIwDCAAAMAAUI6Q1oIwDCAAAPAAEIKAMOWAAAAAABLAAFFAcILQACAAwlAA==.',['花意']='花意:BAAALAAECgYIBgAAAA==.',['花醉']='花醉三千:BAAALAAECgUIBQAAAA==.',['若水']='若水夕颜:BAAALAAECgUICQAAAA==.',['苹果']='苹果梨:BAAALAAECgMIAwAAAA==.',['莎拉']='莎拉格雷拉特:BAAALAAFFAMIBAABLAAFFAYIDwALAKwXAA==.',['莫里']='莫里娅蒂教授:BAAALAAECgQIBAAAAA==.',['萌新']='萌新小撒:BAABLAAFFH8GAAIMAAII7w3wYgBYAAAMAAII7w3wYgBYAAAAAA==.',['萨儿']='萨儿玛格:BAAALAAECgcIDQAAAA==.',['萨满']='萨满朵特:BAABLAAECn8bAAQfAAgIIBcIDQAVAgAfAAgINxQIDQAVAgAMAAYIXR0tUADxAQAPAAYI9hVXWwClAQAAAA==.',['萨米']='萨米娜:BAABLAAECn8ZAAIDAAYISxrXSQB/AQADAAYISxrXSQB/AQAAAA==.萨米法:BAAALAAECgUIBQAAAA==.',['萨萨']='萨萨狐:BAAALAAFFAEIAQABLAAFFAIIAgAgAAAAAA==.萨萨里安:BAAALAAFFAIIAgAAAA==.',['蓝羌']='蓝羌:BAAALAAECgMIAwAAAA==.',['蔡丶']='蔡丶徐丶坤:BAAALAAECgUICgAAAA==.',['蔻小']='蔻小琪:BAAALAAECgYICgAAAA==.',['蕨根']='蕨根龙师天:BAAALAAECgQIBAAAAA==.',['虞术']='虞术则不达:BAAALAADCgQIBAAAAA==.',['蛋糕']='蛋糕仔仔丶:BAAALAAECgYICAAAAA==.',['要啥']='要啥自行车:BAAALAADCgcIBwAAAA==.',['让你']='让你射惊了:BAABLAAFFH8GAAIFAAYI6gDTxQAJAAAFAAYI6gDTxQAJAAAAAA==.',['讲个']='讲个笑话:BAAALAAECgEIAQAAAA==.',['诸神']='诸神的凋零:BAABLAAFFH8GAAICAAYIhAXOQwArAQACAAYIhAXOQwArAQAAAA==.',['豆芽']='豆芽菜:BAAALAADCgEIAQAAAA==.',['豆豆']='豆豆逗豆本豆:BAAALAAECgIIAgAAAA==.',['资深']='资深读书人:BAAALAAFFAMIAwAAAA==.',['赤虎']='赤虎:BAAALAADCgEIAQAAAA==.',['踏破']='踏破虚空:BAAALAAECgUIBQAAAA==.',['转身']='转身謝幕:BAAALAAECgUIBQAAAA==.',['辛洛']='辛洛斯之牙:BAAALAAECgYIBgAAAA==.',['这个']='这个人有点冰:BAAALAAFFAIIBAAAAA==.这个人有点冷:BAABLAAFFH8NAAITAAMIfhMpQwCWAAATAAMIfhMpQwCWAAAAAA==.',['迷失']='迷失的星辰:BAAALAADCgcIBwAAAA==.',['追杀']='追杀令:BAAALAAFFAIIAgAAAA==.',['逝水']='逝水无痕:BAACLAAFFH8KAAIQAAMIRwpFQwB+AAAQAAMIRwpFQwB+AAAsAAQKfxwAAxAACAjNE1ODAL8BABAACAgaEVODAL8BABkABwj1D88xADQBAAAA.',['速度']='速度之鸣:BAAALAADCgYIBgAAAA==.',['那就']='那就这样不见:BAAALAAFFAIIAgABLAAFFAIIBgAHAAIRAA==.',['邪恶']='邪恶:BAABLAAFFH8IAAICAAYIeAmmUADaAAACAAYIeAmmUADaAAAAAA==.',['酒窝']='酒窝:BAABLAAFFH8GAAIEAAIINAKkVwBCAAAEAAIINAKkVwBCAAAAAA==.',['酷酷']='酷酷:BAAALAAECgcIEgAAAA==.',['释水']='释水无痕:BAAALAAECgQIBAABLAAECggIEQAgAAAAAA==.',['野兽']='野兽之心丶:BAAALAAFFAIIAgAAAA==.',['量子']='量子纠缠:BAAALAAECggICAAAAA==.',['铜头']='铜头铁皮:BAAALAAFFAIIAwAAAA==.',['锦瑟']='锦瑟丸子:BAAALAAECgYIDgAAAA==.',['闊靛']='闊靛緥婧愮偣:BAAALAADCgcIBwAAAA==.',['闯进']='闯进狼圈的羊:BAAALAAECgUIBQAAAA==.',['闹翻']='闹翻天:BAAALAADCgYIBgAAAA==.',['阿发']='阿发古:BAACLAAFFH8GAAICAAIIuRUyegCLAAACAAIIuRUyegCLAAAsAAQKfxUAAgIABgiiHyUqAM0BAAIABgiiHyUqAM0BAAAA.',['阿司']='阿司匹林:BAAALAAECgYIBgAAAA==.',['阿尔']='阿尔坎牧场:BAACLAAFFH81AAIdAAYIByW4AQAYAgAdAAYIByW4AQAYAgAsAAQKfxkAAh0ABghjJKAJAAgCAB0ABghjJKAJAAgCAAAA.',['阿茶']='阿茶:BAABLAAECn8XAAIFAAgI7h+TcwD1AQAFAAgI7h+TcwD1AQAAAA==.阿茶茶:BAAALAAECgYIBgABLAAECggIFwAFAO4fAA==.',['雷光']='雷光:BAAALAAFFAIIBAAAAA==.',['雷霆']='雷霆嘎巴:BAABLAAFFH8GAAICAAIIjRdMVQCeAAACAAIIjRdMVQCeAAAAAA==.',['霸气']='霸气狂煞:BAAALAAFFAIIAgAAAA==.',['青焰']='青焰:BAAALAAECgYIDgAAAA==.',['青青']='青青子衿:BAAALAAECgYIDAAAAA==.',['非诚']='非诚勿扰:BAABLAAFFH8LAAITAAYITyNlEQDbAQATAAYITyNlEQDbAQAAAA==.',['韭菜']='韭菜鸡蛋:BAAALAAFFAEIAQAAAA==.',['颠覆']='颠覆小妖:BAAALAAFFAIIBAAAAA==.',['风暴']='风暴来临:BAAALAADCgYIBgAAAA==.',['风车']='风车车:BAAALAAECgIIAgAAAA==.',['飞星']='飞星寻龙:BAABLAAFFH8KAAIhAAIIvho+GACSAAAhAAIIvho+GACSAAAAAA==.',['饮胜']='饮胜:BAABLAAFFH8KAAMNAAQIDQwdDwDVAAANAAQIDQwdDwDVAAAOAAIILAwuHwA5AAAAAA==.',['骨尴']='骨尴美:BAAALAAFFAQIBAAAAA==.',['魅魔']='魅魔:BAAALAAECgEIAQAAAA==.',['鸟枪']='鸟枪换炮:BAAALAADCgIIAgAAAA==.',['黄昏']='黄昏的日落:BAAALAAECgYICwAAAA==.',['黑兽']='黑兽:BAABLAAFFH8IAAIFAAIIEB6whgBKAAAFAAIIEB6whgBKAAAAAA==.',['黑山']='黑山小兽:BAAALAADCgIIAgAAAA==.',['黑黑']='黑黑猫警长:BAAALAAECgYIDQAAAA==.',['齐拉']='齐拉:BAAALAAECgYIBgABLAAFFAgIBwAFAGQVAA==.',['龙先']='龙先生:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end