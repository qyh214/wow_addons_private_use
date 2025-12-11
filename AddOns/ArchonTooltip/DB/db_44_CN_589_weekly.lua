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
 local lookup = {'Paladin-Retribution','Paladin-Protection','DemonHunter-Havoc','Mage-Arcane','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','DeathKnight-Frost','Unknown-Unknown','Mage-Frost','Druid-Restoration','Shaman-Elemental','Priest-Holy','Hunter-Survival','DemonHunter-Vengeance','Paladin-Holy','Druid-Balance','Shaman-Restoration','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','DeathKnight-Unholy','Warrior-Fury','Warrior-Protection','Druid-Guardian','Rogue-Outlaw','DeathKnight-Blood','Warrior-Arms','Priest-Shadow','Rogue-Subtlety','Rogue-Assassination','Evoker-Devastation',}; local provider = {region='CN',realm='刺骨利刃',name='CN',type='weekly',zone=44,date='2025-12-06',data={Af='Afdjhl:BAACLAAFFH8gAAIBAAYIchzjEQC4AQABAAYIchzjEQC4AQAsAAQKfykAAgEACAj8IgkJAM4CAAEACAj8IgkJAM4CAAAA.',Am='Amiya:BAAALAADCgIIAgAAAA==.',An='Anthon:BAAALAAFFAEIAQAAAA==.Anthony:BAAALAAECgYIDAAAAA==.',Ap='Appstore:BAABLAAFFH8KAAICAAIIBhqNFACCAAACAAIIBhqNFACCAAAAAA==.Aptonk:BAAALAAECgYICQAAAA==.',As='Asassin:BAAALAAECgYIBgAAAA==.Ashen:BAABLAAFFH8HAAIDAAIIBATVZgA5AAADAAIIBATVZgA5AAABLAAFFAgIJAAEAEsjAA==.',Ba='Babymonster:BAAALAAECgYICQAAAA==.',Ca='Cancerbaby:BAAALAAECgIIAgAAAA==.',Cc='Ccrazy:BAABLAAFFH8QAAIFAAYIIhfwOQBZAQAFAAYIIhfwOQBZAQAAAA==.',Ch='Charlotte:BAAALAAFFAIIBAAAAA==.',Dr='Drow:BAABLAAFFH8uAAMGAAYIeRuKHQCoAQAGAAYIeRuKHQCoAQAHAAII4AnNGQCPAAAAAA==.',Ei='Eileen:BAAALAAECgcIEAAAAA==.',El='Elisn:BAAALAAECgIIAwAAAA==.Elohims:BAAALAADCgEIAQAAAA==.',Es='Esc:BAAALAADCggIFAAAAA==.',Fa='Fade:BAAALAAECgYICQAAAA==.',Fo='Fortytwofs:BAAALAAECggICAAAAA==.',Gh='Ghrdghdr:BAAALAADCgYIBgAAAA==.',Gi='Gianfilippo:BAAALAADCgUIBQAAAA==.',Go='Goud:BAAALAAFFAIIAgAAAA==.',Gr='Gr:BAAALAAECgYICAAAAA==.',Ha='Handsome:BAAALAAECgYIEgAAAA==.Hardcandy:BAAALAAFFAIIAgAAAA==.Hatethisgame:BAABLAAFFH8TAAIFAAYIbSEpEgD7AQAFAAYIbSEpEgD7AQABLAAFFAgIJAAEAEsjAA==.',He='Helianthus:BAAALAAECgQIBAAAAA==.',Ho='Homelander:BAABLAAFFH8IAAIIAAgIrRVzGQDTAQAIAAgIrRVzGQDTAQAAAA==.',Je='Jetaimeter:BAAALAAFFAIIAgAAAA==.Jetaimeun:BAABLAAFFH8HAAIEAAMIvxoAKQDvAAAEAAMIvxoAKQDvAAAAAA==.',Jv='Jvjq:BAAALAAFFAIIAgABLAAFFAIIBAAJAAAAAA==.',Ko='Kokia:BAAALAAFFAYIAwAAAA==.',La='Lanbao:BAABLAAFFH8HAAIHAAIIKh2cEQBJAAAHAAIIKh2cEQBJAAAAAA==.',Li='Lingren:BAACLAAFFH8kAAIEAAgISyOvAwC4AgAEAAgISyOvAwC4AgAsAAQKfz4AAwQACAgYJYgCAPACAAQACAgYJYgCAPACAAoAAQgKEzWXAC0AAAAA.',Lm='Lmsailcq:BAABLAAFFH8MAAILAAIIwRIgRQBlAAALAAIIwRIgRQBlAAAAAA==.',Lo='Lonely:BAAALAAECgYIDAAAAA==.',Lu='Luckboy:BAABLAAECn8WAAIFAAYIEBlHwgB8AQAFAAYIEBlHwgB8AQAAAA==.Luxuria:BAAALAAECgUIBgAAAA==.',Ly='Lya:BAABLAAFFH8PAAIMAAgIABqvBwAFAgAMAAgIABqvBwAFAgAAAA==.Lyb:BAABLAAFFH8KAAIMAAgI7R/2BACDAgAMAAgI7R/2BACDAgAAAA==.Lyc:BAABLAAFFH8OAAIMAAgI5x8BBQCBAgAMAAgI5x8BBQCBAgAAAA==.Lyd:BAABLAAFFH8ZAAIMAAgIrB5VBgBeAgAMAAgIrB5VBgBeAgAAAA==.',Ma='Marleiarlee:BAABLAAFFH8QAAIGAAMIHR8SMgCwAAAGAAMIHR8SMgCwAAAAAA==.',Mi='Missbig:BAAALAAECgcIBgAAAA==.',Mn='Mnmnmn:BAAALAAFFAEIAQAAAA==.',Ni='Nishuo:BAABLAAFFH8GAAINAAIIFRb/KQCXAAANAAIIFRb/KQCXAAAAAA==.',Nm='Nmixx:BAAALAAECgYICAAAAA==.',Nu='Nuclear:BAAALAAECgUIDAAAAA==.',Ok='Okiedokie:BAAALAAECgYIBgAAAA==.',Ol='Oliverquinn:BAABLAAECn8ZAAMOAAYIOxmPEACeAQAOAAYIbRaPEACeAQAFAAYIuxFcnQAdAQAAAA==.',Pa='Palatinus:BAAALAAFFAIIAgAAAA==.',Pe='Peekaboom:BAAALAAECgQIBAAAAA==.',Ro='Romance:BAAALAAECgQIBAAAAA==.Roxy:BAAALAADCgYIBgAAAA==.',Rr='Rrgg:BAAALAAECgUICwAAAA==.',Rt='Rt:BAABLAAECn8kAAIPAAYIrhGtFgDxAAAPAAYIrhGtFgDxAAAAAA==.',Se='Seaxuan:BAABLAAECn8hAAMBAAYIWx4jmwC/AQABAAYIWx4jmwC/AQAQAAYICRAhIgAyAQAAAA==.',Sh='Shinning:BAAALAAFFAIIBAAAAA==.',Si='Simon:BAAALAAECgEIAQAAAA==.',Sp='Sprog:BAAALAADCgYIDAAAAA==.',Su='Surprise:BAABLAAFFH8FAAIEAAMI2gQJTABhAAAEAAMI2gQJTABhAAAAAA==.',Ta='Takachiko:BAABLAAFFH8GAAIDAAYIYhXvBwAfAgADAAYIYhXvBwAfAgAAAA==.',Ws='Ws:BAAALAADCgcIBwAAAA==.',Xi='Xiaofdly:BAEALAAECgYIBgABLAAFFAgIPQARAGIiAA==.Xiaofdragon:BAEALAADCggICAABLAAFFAgIPQARAGIiAA==.',Ze='Zeva:BAABLAAFFH8IAAIIAAIIKRc0dABMAAAIAAIIKRc0dABMAAAAAA==.',Zz='Zzss:BAAALAAECgYIDgAAAA==.',['一只']='一只熊:BAAALAAECggIBwAAAA==.',['一叶']='一叶知秋:BAAALAAECgEIAQAAAA==.',['一声']='一声喵丶:BAACLAAFFH8kAAIIAAYItyCjFgDhAQAIAAYItyCjFgDhAQAsAAQKfyIAAggACAgwJecOADgDAAgACAgwJecOADgDAAAA.',['一月']='一月黑风高一:BAACLAAFFH8gAAMEAAUIrBKBNQAkAQAEAAUImRCBNQAkAQAKAAEIrBB9EgBOAAAsAAQKfzYAAwQACAgDGvs6AF4CAAQACAgDGvs6AF4CAAoABgirEr9FAFkBAAAA.',['一生']='一生何求:BAAALAAECgYIEgAAAA==.',['一身']='一身仙女味丶:BAAALAAECgYIBgAAAA==.',['一黯']='一黯稥一:BAAALAAECgcIEAAAAA==.',['丁丁']='丁丁专车:BAAALAAECgYICgAAAA==.丁丁快递:BAAALAAECgUIBQAAAA==.',['丄善']='丄善若水:BAAALAAECgYIBwAAAA==.',['万物']='万物终结:BAABLAAFFH8FAAISAAUIfwtBMQDnAAASAAUIfwtBMQDnAAAAAA==.',['三蹦']='三蹦子:BAAALAAECgUIBwAAAA==.',['上弦']='上弦月之殇:BAABLAAFFH8GAAIFAAMIzRmGLQDNAAAFAAMIzRmGLQDNAAAAAA==.',['上海']='上海伯爵:BAAALAAECgYIBgAAAA==.',['上輩']='上輩子是牧師:BAAALAADCgYIBgAAAA==.',['下班']='下班之后玩:BAAALAAECgMIAwAAAA==.下班归来:BAAALAAFFAIIAgAAAA==.',['不怕']='不怕上瘾:BAAALAAECgYIBgAAAA==.',['不能']='不能偷懒:BAAALAAECgYICgAAAA==.',['且聽']='且聽風吟:BAAALAAECgUIBQAAAA==.',['世间']='世间本无道:BAAALAAECgYIBgAAAA==.',['丨丶']='丨丶天空狠灰:BAAALAAECgIIAgAAAA==.丨丶龑:BAAALAAECgQIBAAAAA==.',['丨岚']='丨岚丨:BAAALAAECgMIAwAAAA==.',['丨未']='丨未曾丨:BAAALAAECgQIBgAAAA==.丨未至丨:BAAALAADCgYIBgAAAA==.',['丨池']='丨池墨:BAAALAAECgcIDQAAAA==.',['丶上']='丶上古噬魂者:BAAALAAECgMIAwAAAA==.',['丶小']='丶小花:BAAALAADCgEIAQAAAA==.',['举报']='举报人:BAAALAADCgUIBQAAAA==.',['乌龙']='乌龙蜜饯:BAAALAAECgcIBgAAAA==.',['乐高']='乐高乐高:BAAALAAECggICgAAAA==.',['乖啵']='乖啵啵:BAABLAAFFH8IAAIBAAIIUBhIXQBIAAABAAIIUBhIXQBIAAAAAA==.',['九把']='九把刀风扇:BAAALAAECgYIDAAAAA==.',['也许']='也许鬙懠:BAAALAAECgEIAQAAAA==.',['乱世']='乱世丶妖娆:BAAALAAECgEIAQAAAA==.',['乱舞']='乱舞的旋律:BAABLAAECn8XAAMTAAYIwA5EdAD/AAAFAAYIwA6E8gA/AQATAAYIzwpEdAD/AAAAAA==.',['云岸']='云岸净空:BAAALAAECgEIAQAAAA==.',['云柒']='云柒:BAABLAAFFH8FAAMPAAIISAniFgAoAAAPAAIISAniFgAoAAADAAEI4QE5dAAAAAAAAA==.',['亚格']='亚格斯:BAAALAAECggICgAAAA==.',['伊利']='伊利贝拉:BAAALAAECgYICQAAAA==.',['伊莎']='伊莎珼菈:BAAALAAECgYICgAAAA==.',['伊萨']='伊萨嗜神:BAAALAAECgIIAgAAAA==.',['伊黑']='伊黑小芭内:BAAALAAECgYICwAAAA==.',['休丶']='休丶杰克曼:BAABLAAFFH8KAAIIAAIIDA/BdgCNAAAIAAIIDA/BdgCNAAAAAA==.',['伦落']='伦落街尾:BAAALAADCgYIBgAAAA==.',['伽西']='伽西亚:BAAALAADCgMIAwAAAA==.',['你不']='你不懂打拳:BAAALAADCgYIBgAAAA==.',['你家']='你家叁哥:BAAALAAFFAIIBAAAAA==.',['你报']='你报警吧:BAAALAAECgIIAgAAAA==.',['信仰']='信仰圣光叭:BAAALAAECgUICQAAAA==.',['修微']='修微波炉:BAABLAAFFH8IAAIIAAQIGxFHUQDVAAAIAAQIGxFHUQDVAAAAAA==.',['修油']='修油烟机:BAAALAAFFAIIAwAAAA==.',['修煤']='修煤气灶:BAABLAAFFH8HAAMUAAIIpQe6FQB+AAAUAAIIpQe6FQB+AAAVAAII0AEpGABjAAAAAA==.',['倚劍']='倚劍行天下:BAAALAAECgMIAwAAAA==.',['偏不']='偏不:BAAALAAECgEIAQAAAA==.',['做你']='做你爱我的事:BAABLAAECn8mAAIFAAcIwR9SWgAoAgAFAAcIwR9SWgAoAgAAAA==.',['做我']='做我爱你的事:BAAALAAECgMIAwAAAA==.',['傲气']='傲气一一海哥:BAAALAAECgYIDwAAAA==.傲气游荡者:BAAALAAECgYICQAAAA==.傲气闽狼:BAAALAAECgYIBgAAAA==.傲气闽闽:BAAALAAECgYIBgAAAA==.',['傻不']='傻不邋叽:BAAALAADCgYIBgAAAA==.',['像花']='像花一样女人:BAAALAAECgQIBAAAAA==.',['元素']='元素背叛者:BAAALAAECgcIBwABLAAFFAYILQAMAKoWAA==.',['先森']='先森不调情:BAAALAAECgEIAQAAAA==.',['光明']='光明牛犊:BAAALAADCgQIBAAAAA==.',['克里']='克里斯提娜丶:BAAALAAECgQIBAAAAA==.',['农妇']='农妇三十拳:BAAALAAECgYIBgAAAA==.',['冥殇']='冥殇灬:BAAALAAECgYIBwAAAA==.',['冥渊']='冥渊:BAAALAADCgMIAwAAAA==.',['冰冷']='冰冷的心:BAABLAAFFH8GAAISAAIIgwMocwBGAAASAAIIgwMocwBGAAAAAA==.',['冰封']='冰封之炎:BAABLAAFFH8HAAIIAAMIuhMCXQCUAAAIAAMIuhMCXQCUAAAAAA==.冰封璀璨:BAACLAAFFH8GAAIFAAIIViAMhgBLAAAFAAIIViAMhgBLAAAsAAQKfx4AAgUABgg6JB0qAA8CAAUABgg6JB0qAA8CAAAA.',['冰棒']='冰棒:BAAALAADCgYICwAAAA==.',['冰灬']='冰灬帝:BAAALAAECgEIAQAAAA==.',['冰霜']='冰霜死骑:BAABLAAFFH8JAAMIAAIIaRTCWQCbAAAIAAIIaRTCWQCbAAAWAAEIqBXuHABRAAAAAA==.',['冲锋']='冲锋屁屁:BAABLAAFFH8HAAMXAAYInwYgLQD0AAAXAAUIuQUgLQD0AAAYAAII8Ap+MQAxAAAAAA==.',['凉笙']='凉笙:BAABLAAFFH8FAAIZAAMIFxouAgD4AAAZAAMIFxouAgD4AAAAAA==.',['凯诶']='凯诶撒思:BAAALAADCgYIBgAAAA==.',['出门']='出门不带电话:BAAALAAECgIIAgAAAA==.',['刘玄']='刘玄德:BAAALAAECgYICAAAAA==.',['初丶']='初丶二:BAABLAAFFH8HAAIXAAMI3hhvMgCwAAAXAAMI3hhvMgCwAAAAAA==.',['初十']='初十:BAAALAAECgYIBgAAAA==.',['刹那']='刹那:BAABLAAECn8kAAQLAAgIyxh8EwA4AgALAAgIyxh8EwA4AgARAAcIwBp/FADSAQAZAAEIiQE9LgAMAAAAAA==.',['剎那']='剎那丶:BAAALAAECgYIDAAAAA==.剎那灬:BAAALAAECggIDgAAAA==.剎那的宝贝:BAAALAAECgYIEQAAAA==.',['力力']='力力的小馒头:BAAALAAECgUIBwAAAA==.',['动情']='动情时刻最美:BAAALAAECgIIAwAAAA==.',['勇敢']='勇敢小德:BAAALAAECgYIBgAAAA==.勇敢熊熊:BAAALAAECgQIBAAAAA==.',['千云']='千云千夜:BAAALAADCgcIBwAAAA==.',['南风']='南风知我忆:BAABLAAFFH8LAAMQAAMInwUbIgCRAAAQAAMInwUbIgCRAAABAAEIshFDiQAAAAAAAA==.',['卡卡']='卡卡罗特:BAAALAAECgYIDQAAAA==.',['卡特']='卡特玲娜:BAABLAAFFH8VAAIGAAUI0gasQADtAAAGAAUI0gasQADtAAABLAAFFAYILwACAF0PAA==.',['叁队']='叁队骑士:BAAALAAECgYIDAAAAA==.',['双刀']='双刀猫:BAAALAAECgEIAQAAAA==.',['反手']='反手一个压制:BAAALAAFFAIIAgAAAA==.',['反浩']='反浩克机甲:BAAALAAECgcIEAAAAA==.',['取名']='取名好麻烦:BAAALAADCgEIAQAAAA==.',['古尔']='古尔彦祖丹:BAAALAAECgIIAgAAAA==.',['叫啥']='叫啥来的:BAAALAAECgIIAgAAAA==.',['可可']='可可熊的火舞:BAAALAAECgEIAQAAAA==.可可熊的爱恋:BAAALAADCgYIBwAAAA==.可可熊的馄饨:BAAALAADCgMIAwAAAA==.',['可爱']='可爱小夕睿:BAAALAAECgMIBQAAAA==.',['史诗']='史诗骑士:BAAALAAFFAIIBAAAAA==.',['司马']='司马村夫:BAAALAADCgYIBgAAAA==.',['吃鱼']='吃鱼的猫猫:BAAALAADCgYICQAAAA==.',['吉谙']='吉谙娜:BAAALAAECgQIBAAAAA==.',['吕钦']='吕钦杨:BAAALAAECgYIEAAAAA==.',['吸血']='吸血屁屁:BAAALAAFFAIIBAAAAA==.',['吾善']='吾善救人:BAAALAADCggICAAAAA==.',['周三']='周三下午茶:BAAALAAFFAIIBAAAAA==.',['命运']='命运田园小龙:BAABLAAFFH8TAAIFAAYIlRIIQABGAQAFAAYIlRIIQABGAQAAAA==.命运田园恶魔:BAABLAAFFH8JAAIDAAQIWAlNNgDLAAADAAQIWAlNNgDLAAAAAA==.',['咆哮']='咆哮女狼:BAAALAAECgYIDAAAAA==.',['咕啊']='咕啊咕啊咕:BAABLAAFFH8FAAILAAIIhCCIGQC8AAALAAIIhCCIGQC8AAAAAA==.',['咖啡']='咖啡加可乐:BAAALAAECggICQAAAA==.',['咸鱼']='咸鱼大王:BAABLAAECn8XAAMZAAYIIQXxKQC3AAAZAAYIIQXxKQC3AAALAAYI6ACZ4wA4AAAAAA==.',['哀伤']='哀伤陨落:BAAALAAECggICAAAAA==.',['哀木']='哀木涕乄:BAAALAAECgYIEAAAAA==.',['哈特']='哈特:BAAALAAECgYICwAAAA==.',['哥灬']='哥灬霸气侧漏:BAAALAAFFAIIBAAAAA==.',['啊呜']='啊呜灬啊呜:BAAALAAFFAIIAgAAAA==.',['啦丶']='啦丶啦:BAAALAAECgYICgAAAA==.',['啵啵']='啵啵比:BAAALAAFFAIIAgAAAA==.',['啾咪']='啾咪:BAAALAADCgUIBwAAAA==.',['喵喵']='喵喵怪:BAAALAAECgMIBwAAAA==.',['嚤羯']='嚤羯:BAAALAAECggICAAAAA==.',['回归']='回归的战神:BAAALAAECgMIBAAAAA==.',['囯产']='囯产零零久:BAACLAAFFH8GAAIWAAIIXBIAEQCVAAAWAAIIXBIAEQCVAAAsAAQKfxoAAhYABwgXG4YSADkCABYABwgXG4YSADkCAAEsAAUUAggIAA8AkhsA.',['困兽']='困兽之逗:BAAALAAECgYIBgAAAA==.',['国产']='国产零零久:BAAALAAECgYIBgAAAA==.',['国瞑']='国瞑贰奶:BAAALAAECgIIAwAAAA==.',['图刃']='图刃:BAAALAADCgIIAgAAAA==.',['图哆']='图哆哆:BAAALAAFFAIIBAAAAA==.',['图腾']='图腾屁屁:BAAALAAFFAIIBAAAAA==.',['國产']='國产零零久:BAACLAAFFH8IAAMPAAIIkhtLCgCkAAAPAAIIkhtLCgCkAAADAAIIHROWPwCaAAAsAAQKfy4AAw8ABwh5IgcOAH4CAAMABwgVIVQuAKMCAA8ABwjsHwcOAH4CAAAA.',['圣光']='圣光丨信仰:BAABLAAECn8aAAMBAAYIBw7XBwEeAQABAAYIBw7XBwEeAQAQAAYIzAqGTgAcAQAAAA==.圣光啲正义:BAAALAAECgMIAwAAAA==.圣光回响:BAAALAAECgYIDgAAAA==.',['圣剑']='圣剑:BAAALAADCgIIAgAAAA==.',['地狱']='地狱的怒吼:BAABLAAFFH8JAAIYAAUIzwd/GgDAAAAYAAUIzwd/GgDAAAAAAA==.地狱维纳斯:BAABLAAECn8eAAIKAAYIoSGRDQDkAQAKAAYIoSGRDQDkAQAAAA==.',['基克']='基克的使徒:BAAALAAECgYIBgAAAA==.',['复仇']='复仇者丨泥煤:BAAALAAECgYIBgAAAA==.',['夏天']='夏天之雨:BAAALAAFFAIIBAAAAA==.',['夙愿']='夙愿之箭:BAABLAAFFH8MAAIFAAYIqBNSQABGAQAFAAYIqBNSQABGAQAAAA==.',['夜丨']='夜丨目田:BAAALAADCgUIBQAAAA==.',['夜夜']='夜夜兮兮黑:BAAALAAECgUIBQAAAA==.',['夢落']='夢落繁花:BAAALAAECgUIBwAAAA==.',['大主']='大主教伊俐丹:BAAALAAECgYICQAAAA==.',['大力']='大力堃:BAAALAADCggICAAAAA==.',['大唐']='大唐:BAAALAAFFAEIAQAAAA==.',['大大']='大大地发丝:BAABLAAFFH8QAAMEAAUI/gtkOwDpAAAEAAUI/gtkOwDpAAAKAAEIJwZAIgA5AAAAAA==.大大地猎手:BAABLAAFFH8IAAIDAAYIzQ2fJQBhAQADAAYIzQ2fJQBhAQAAAA==.',['大顿']='大顿口:BAABLAAFFH8gAAIIAAYIYRWpKwDqAAAIAAYIYRWpKwDqAAAAAA==.',['天涯']='天涯藍藥師:BAAALAAECgYICgAAAA==.',['奈伊']='奈伊祖特:BAAALAAECgUIBgAAAA==.',['奈叶']='奈叶叶:BAAALAAFFAQIAQAAAA==.',['奈妮']='奈妮:BAAALAAFFAIIAgAAAA==.',['奥沙']='奥沙利亚:BAABLAAECn8eAAIXAAYIMiAzIQDmAQAXAAYIMiAzIQDmAQAAAA==.',['女丶']='女丶大丶学生:BAAALAADCgMIAwAAAA==.',['女子']='女子无才:BAACLAAFFH8LAAILAAUI7geqJQDrAAALAAUI7geqJQDrAAAsAAQKfxQAAwsABghjD2E/ABwBAAsABghjD2E/ABwBABEABQigECc7AM8AAAAA.',['如丿']='如丿初:BAABLAAFFH8NAAIIAAUIwhlFSAAYAQAIAAUIwhlFSAAYAQAAAA==.',['如果']='如果哀:BAAALAADCgYIBgAAAA==.',['妳非']='妳非莪桮茶灬:BAAALAADCgUIBQAAAA==.',['姐夫']='姐夫是叁哥:BAABLAAFFH8IAAIQAAIIcAlGIQCFAAAQAAIIcAlGIQCFAAAAAA==.',['威龙']='威龙圣骑:BAAALAADCgYIBgAAAA==.',['宅男']='宅男心不宅:BAABLAAFFH8LAAIYAAUI8g1bGADjAAAYAAUI8g1bGADjAAAAAA==.',['害羞']='害羞的番茄:BAAALAAECgYIBgAAAA==.',['寒丶']='寒丶霏丨尐煞:BAAALAAFFAIIBAAAAA==.',['寒月']='寒月醉酒:BAAALAAFFAIIBAAAAA==.',['寶貝']='寶貝各种抱:BAAALAADCgUIBQAAAA==.',['小丶']='小丶小:BAAALAAECgcIDAAAAA==.',['小伍']='小伍哥:BAAALAAECgEIAQAAAA==.',['小太']='小太子奶:BAAALAAECgYIBgAAAA==.',['小毅']='小毅帅帅:BAAALAAECgEIAQAAAA==.',['小红']='小红胖:BAAALAAECgMIAwAAAA==.',['小羊']='小羊肖恩:BAAALAAFFAIIAgABLAAFFAIIBAAJAAAAAA==.',['小老']='小老弟:BAABLAAFFH8GAAIZAAMIYAcrCwBCAAAZAAMIYAcrCwBCAAAAAA==.',['小菜']='小菜一碟:BAAALAAFFAIIBAAAAA==.',['小金']='小金连连:BAAALAADCggICAAAAA==.',['尐絮']='尐絮兒:BAAALAAECgMIAwAAAA==.',['就我']='就我在挨揍:BAAALAADCgQIBAAAAA==.',['就问']='就问你大不大:BAAALAAECgYIBgAAAA==.',['尼古']='尼古拉斯咆哮:BAAALAAECgUIBQAAAA==.',['尾巴']='尾巴短小:BAAALAAECgIIAgAAAA==.',['巴温']='巴温:BAAALAAECgUIBQAAAA==.',['希尔']='希尔瓦钢丝儿:BAAALAAFFAIIAgAAAA==.',['希璐']='希璐菲叶特:BAABLAAFFH8IAAILAAIIxhwMJACXAAALAAIIxhwMJACXAAAAAA==.',['帕拉']='帕拉梅猪:BAAALAAECgQIBgAAAA==.',['帝月']='帝月晨风:BAACLAAFFH8ZAAIXAAUIMCLeHQB6AQAXAAUIMCLeHQB6AQAsAAQKfzcAAhcACAhPJYAFAGgDABcACAhPJYAFAGgDAAAA.',['幕阜']='幕阜山散人:BAAALAADCgMIAwAAAA==.幕阜山闲人:BAAALAADCgMIAwAAAA==.',['幕雪']='幕雪:BAAALAAECgYICAAAAA==.',['幻灵']='幻灵丶猎:BAAALAAECgIIAgAAAA==.',['幽岚']='幽岚风暴:BAAALAAFFAIIAgAAAA==.',['库巴']='库巴:BAACLAAFFH8rAAIBAAYIlhy+EwCsAQABAAYIlhy+EwCsAQAsAAQKfyAAAgEACAiGI6IQADgDAAEACAiGI6IQADgDAAAA.',['弑鼪']='弑鼪辙:BAAALAAFFAIIAgAAAA==.',['弹道']='弹道偏左:BAAALAAFFAQIBAAAAA==.',['彩云']='彩云之北:BAAALAAFFAIIAgAAAA==.',['彳亍']='彳亍:BAAALAAFFAIIBAAAAA==.',['彼界']='彼界战神:BAEBLAAFFH8MAAIEAAMIfBUtOgCnAAAEAAMIfBUtOgCnAAABLAAFFAgIPQARAGIiAA==.',['往事']='往事清零:BAAALAAECggICAAAAA==.',['從林']='從林丶射手:BAAALAAFFAYIAgAAAA==.',['微笑']='微笑屁屁:BAAALAAFFAIIBAAAAA==.',['心惢']='心惢:BAACLAAFFH8TAAIaAAUIsxYJAgBLAQAaAAUIsxYJAgBLAQAsAAQKfyEAAhoACAiyH/8AAHsCABoACAiyH/8AAHsCAAAA.',['心潮']='心潮人不潮:BAAALAAECgEIAQAAAA==.',['忧郁']='忧郁的颜色:BAABLAAFFH8KAAIXAAIInwSnYAAzAAAXAAIInwSnYAAzAAAAAA==.',['怜媚']='怜媚:BAAALAADCgQIBAAAAA==.',['怡寳']='怡寳矿泉水:BAAALAAECgYIBgAAAA==.',['急冻']='急冻鸟:BAAALAADCgMIAwAAAA==.',['性感']='性感小猪:BAAALAAECgYIBgAAAA==.',['恋上']='恋上寒若雨:BAAALAAECggIDQABLAAFFAgIBgASABEgAA==.恋上筱小雨:BAAALAAECgUIBQAAAA==.',['恋伤']='恋伤小九九:BAAALAAECgYIBgAAAA==.恋伤小黑牛:BAABLAAFFH8FAAIBAAIIRCWpIgDHAAABAAIIRCWpIgDHAAAAAA==.',['恐惧']='恐惧达灵毛:BAAALAAECgIIAgAAAA==.',['恶靈']='恶靈之手毅少:BAAALAAECgYICgAAAA==.',['憨憨']='憨憨小老表:BAAALAAECgEIAQAAAA==.',['我你']='我你爱做的事:BAAALAADCggICAAAAA==.',['我加']='我加了洋葱:BAABLAAECn8XAAIIAAYIwRuDkADeAQAIAAYIwRuDkADeAQAAAA==.',['我卡']='我卡了啊:BAAALAAECgMIBQAAAA==.',['我当']='我当然是法神:BAABLAAFFH8HAAIEAAMIrBU1JAAIAQAEAAMIrBU1JAAIAQAAAA==.',['我是']='我是有老婆的:BAAALAAECgYICAAAAA==.',['我爱']='我爱百事可乐:BAAALAAECgYIBgAAAA==.我爱老婆大人:BAAALAAECgEIAQAAAA==.',['战姬']='战姬:BAAALAAECggICAAAAA==.',['战神']='战神牛嚒嚒:BAAALAAECgYIBgAAAA==.',['把头']='把头伸过来:BAABLAAFFH8JAAIXAAII+RCsNgCYAAAXAAII+RCsNgCYAAAAAA==.',['抹小']='抹小茶:BAAALAAFFAYIBAAAAA==.',['抹茶']='抹茶酱:BAABLAAFFH8IAAIFAAgI6hWzEgD3AQAFAAgI6hWzEgD3AQAAAA==.',['拂晓']='拂晓的黎明:BAAALAAFFAEIAQAAAA==.',['拉风']='拉风:BAABLAAFFH8mAAIYAAUIrgdxGgDBAAAYAAUIrgdxGgDBAAAAAA==.',['招魂']='招魂幡离忧:BAABLAAFFH8IAAINAAUIIgQOJwD7AAANAAUIIgQOJwD7AAAAAA==.',['探花']='探花遇到雨姐:BAABLAAFFH8HAAIFAAIIygefoAA+AAAFAAIIygefoAA+AAAAAA==.',['撒旦']='撒旦丶怒风:BAAALAAECgMIAwAAAA==.',['救不']='救不了在救:BAAALAAECgIIAgAAAA==.',['斌迪']='斌迪凯:BAAALAADCgcIBwAAAA==.',['斯巴']='斯巴而达:BAAALAAECgQIBAAAAA==.',['斷點']='斷點:BAACLAAFFH8SAAMLAAIIWhreOACIAAALAAIIWhreOACIAAAZAAIImArnCQBkAAAsAAQKfxsAAhkABwhzDNgdACYBABkABwhzDNgdACYBAAAA.',['无情']='无情碾骨:BAAALAAECgEIAQAAAA==.',['无所']='无所谓好与坏:BAABLAAFFH8LAAIYAAQIlwVYHwB/AAAYAAQIlwVYHwB/AAABLAAFFAYIDAANAIcFAA==.',['无敌']='无敌嘲讽:BAAALAAFFAIIBAAAAA==.无敌奔波霸:BAAALAAFFAIIBAAAAA==.',['明月']='明月爱赏咪:BAABLAAFFH8GAAIVAAIIRw0wFgBpAAAVAAIIRw0wFgBpAAAAAA==.明月爱赏喵:BAAALAADCgEIAQAAAA==.',['星丨']='星丨坠:BAAALAAECgcIBwAAAA==.',['星之']='星之圣痕:BAABLAAFFH8KAAIBAAIIAhcCOACkAAABAAIIAhcCOACkAAAAAA==.',['星亦']='星亦缺:BAAALAADCgEIAQAAAA==.',['星澜']='星澜如梦:BAAALAAFFAIIBAAAAA==.',['晚霞']='晚霞落日:BAAALAADCgMIAwAAAA==.',['暗夜']='暗夜之明月:BAAALAADCgEIAgAAAA==.',['暗翼']='暗翼天使:BAAALAAECgYICgAAAA==.',['暗香']='暗香丨德:BAAALAAECgYIDAAAAA==.暗香丨惡魔:BAAALAAECgYICAAAAA==.暗香丨戰:BAAALAAECgcIBQAAAA==.暗香丨武:BAAALAAECgYIAwAAAA==.暗香丨潛行:BAAALAAECgYIDgAAAA==.暗香丨薩:BAAALAAECgYIDgAAAA==.',['暮雲']='暮雲丶猎:BAAALAAFFAIIAgAAAA==.',['暴打']='暴打坤坤:BAAALAAECgIIAwAAAA==.',['暴躁']='暴躁老哥:BAAALAAECgIIAgAAAA==.',['曼联']='曼联马奎尔:BAAALAAECgMIBQAAAA==.',['最长']='最长情的告白:BAAALAAECgQIAwAAAA==.',['月下']='月下孤舞:BAACLAAFFH8FAAIFAAMItwR9fQBdAAAFAAMItwR9fQBdAAAsAAQKfx4AAgUACAjxFlFDAMMBAAUACAjxFlFDAMMBAAAA.月下星雨:BAAALAAECgYICgAAAA==.',['有谁']='有谁比我牛丶:BAAALAAECgMIAwAAAA==.',['村田']='村田小阿花:BAAALAAECgYIBgAAAA==.',['极限']='极限壁垒:BAAALAAFFAIIAgAAAA==.极限未亡人:BAAALAAECgEIAQAAAA==.',['枫德']='枫德:BAAALAAECgIIAgABLAAFFAgIAwAJAAAAAA==.',['枯楪']='枯楪:BAAALAAECgUIBQAAAA==.',['柒暮']='柒暮:BAABLAAFFH8MAAMBAAYInw3jJABMAQABAAYIjwzjJABMAQACAAIIyA0yHgAvAAAAAA==.',['树上']='树上的野人:BAAALAADCgYIBgAAAA==.',['梦幻']='梦幻丽莎发廊:BAAALAADCgYIBgAAAA==.',['楊逍']='楊逍:BAABLAAFFH8JAAIFAAIIXB3kfwBXAAAFAAIIXB3kfwBXAAAAAA==.',['榴莲']='榴莲一号:BAAALAADCgUIBQAAAA==.',['欧麦']='欧麦尬:BAAALAAECgYIDwAAAA==.',['步步']='步步花恋雨:BAABLAAECn8dAAIBAAgIpxuFQgB0AgABAAgIpxuFQgB0AgAAAA==.',['死亡']='死亡隂廕:BAAALAAECgYIBgAAAA==.死亡騎士:BAABLAAFFH8HAAIBAAII7hziNwCkAAABAAII7hziNwCkAAAAAA==.',['死肥']='死肥仔:BAAALAAFFAIIAgAAAA==.',['殇之']='殇之殇:BAAALAAECgYIDAAAAA==.',['殤丶']='殤丶:BAAALAAECgYIEgAAAA==.',['段月']='段月之光:BAAALAAECgQIBAAAAA==.',['水果']='水果布丁:BAAALAADCgcIBwAAAA==.水果绿茶:BAAALAAECgQIBAAAAA==.',['永远']='永远的存在:BAAALAADCgYIBgAAAA==.',['汉堡']='汉堡大将军:BAAALAAECgYICwAAAA==.',['汐阳']='汐阳:BAAALAAECgIIAgAAAA==.',['江湖']='江湖行者:BAAALAADCggICAAAAA==.',['沐筱']='沐筱筱:BAAALAAFFAIIAwABLAAFFAYIDAANAIcFAA==.',['沙罗']='沙罗娇娇:BAAALAAECggICAAAAA==.',['浅灰']='浅灰蓝:BAAALAAFFAIIAgAAAA==.',['海螺']='海螺:BAAALAAECgQIBAAAAA==.',['海贼']='海贼女帝:BAABLAAFFH8FAAIBAAMI7woJSAB6AAABAAMI7woJSAB6AAAAAA==.',['淡墨']='淡墨琉璃:BAABLAAECn8nAAMRAAYI6xrTOADUAQARAAYI6xrTOADUAQALAAYIABZBXQB8AQAAAA==.',['淡淡']='淡淡哋劃濄:BAABLAAECn8bAAIFAAYIBxDitQD8AAAFAAYIBxDitQD8AAAAAA==.',['清欢']='清欢:BAAALAAECgYICQAAAA==.',['清街']='清街酒馆:BAAALAAECgYICAAAAA==.',['渡驿']='渡驿站:BAAALAADCgQIBAAAAA==.',['温柔']='温柔一笑:BAACLAAFFH8GAAIFAAIIQBCVkwBDAAAFAAIIQBCVkwBDAAAsAAQKfxgAAgUACAg/FPNtAGcBAAUACAg/FPNtAGcBAAAA.',['滋滋']='滋滋咻啪:BAAALAAECgIIAgAAAA==.',['漫展']='漫展蓝龙牧:BAAALAADCgYIBgAAAA==.',['漫步']='漫步在雨季:BAAALAADCgcIBwAAAA==.',['潜行']='潜行屁屁:BAAALAAFFAIIBAAAAA==.',['灬失']='灬失:BAAALAAECgYICAAAAA==.',['灬泠']='灬泠泠:BAAALAADCgYIBgAAAA==.',['灬碧']='灬碧落灬:BAABLAAECn8VAAISAAYI8BvNOQB0AQASAAYI8BvNOQB0AQAAAA==.',['灬童']='灬童小寶灬:BAAALAAECgYIBgAAAA==.',['灰烬']='灰烬艾力克斯:BAABLAAFFH8GAAIPAAIIMRbNEgA4AAAPAAIIMRbNEgA4AAAAAA==.',['灿烂']='灿烂男孩:BAAALAAECgYIEQAAAA==.',['炫舞']='炫舞逸尘:BAABLAAFFH8LAAMKAAIIgB5ODgCWAAAKAAIIgB5ODgCWAAAEAAIIsAYSXQCBAAAAAA==.',['烈酒']='烈酒阿珂:BAAALAAECgYIBgAAAA==.',['热血']='热血美男:BAAALAAECgEIAQAAAA==.',['焰云']='焰云长霄:BAAALAADCgMIAwAAAA==.',['煮夫']='煮夫:BAAALAADCgQIBAAAAA==.',['熊德']='熊德艾力克斯:BAABLAAFFH8GAAILAAIIDw9bRgBiAAALAAIIDw9bRgBiAAAAAA==.',['燕云']='燕云穆丹:BAABLAAFFH8GAAISAAIIiwHveQA2AAASAAIIiwHveQA2AAAAAA==.',['燕飞']='燕飞飞:BAAALAADCgYICAAAAA==.',['爆发']='爆发者深度:BAAALAAECgcIDQAAAA==.',['爱上']='爱上层楼:BAABLAAFFH8JAAICAAUIPArqCwDXAAACAAUIPArqCwDXAAAAAA==.',['爱你']='爱你的人:BAAALAAECggICAAAAA==.',['爱周']='爱周周:BAAALAAFFAEIAQAAAA==.',['爱的']='爱的挽歌:BAAALAAECgIIAgAAAA==.',['版本']='版本之子:BAAALAAFFAIIBAAAAA==.',['牛哞']='牛哞哞灬:BAAALAAECggIAwAAAA==.',['牛妞']='牛妞向前冲:BAAALAADCggIEAAAAA==.',['牛气']='牛气冲天红:BAAALAADCgcIBwAAAA==.',['牛眼']='牛眼流牛油:BAABLAAFFH8MAAISAAIINw5rUgBqAAASAAIINw5rUgBqAAAAAA==.',['牧語']='牧語:BAAALAAECgEIAQAAAA==.',['牧野']='牧野风中:BAAALAAFFAIIAgABLAAFFAIIBAAJAAAAAA==.',['物华']='物华依旧:BAAALAAECgYIAwAAAA==.',['独享']='独享娱楽:BAAALAAFFAIIAgAAAA==.独享愚乐:BAAALAAFFAMIAwAAAA==.',['独孤']='独孤凰火:BAAALAAECggIDwAAAA==.',['狼灵']='狼灵骑士:BAACLAAFFH8uAAMIAAUI0xNrOADBAAAIAAUI0xNrOADBAAAbAAMIDAGhGABAAAAsAAQKfyQAAggABwh4FZpFAHEBAAgABwh4FZpFAHEBAAAA.',['猎丶']='猎丶人:BAAALAAECgYIDgAAAA==.',['猎矮']='猎矮子:BAAALAAFFAIIBAAAAA==.',['猎魔']='猎魔师:BAAALAADCgYIBwAAAA==.',['猫阿']='猫阿不:BAAALAADCgYIBgAAAA==.',['玄丶']='玄丶德:BAAALAAFFAIIAgAAAA==.',['理想']='理想王:BAABLAAFFH8GAAIIAAYItgjFOwBMAQAIAAYItgjFOwBMAQAAAA==.',['瑪维']='瑪维斯:BAABLAAFFH8GAAMHAAIInRPzGACRAAAGAAIInROUQgCVAAAHAAII/gvzGACRAAAAAA==.瑪维斯丶霜疫:BAAALAAECgEIAQAAAA==.',['瑾小']='瑾小主:BAAALAAECgQIBAAAAA==.',['白日']='白日梦想家:BAAALAADCgIIAgAAAA==.',['白羊']='白羊座小小雨:BAAALAAECgcIBwAAAA==.',['皮卡']='皮卡牛:BAAALAADCgIIAgAAAA==.',['盗帅']='盗帅夜留香:BAAALAAECgYICgAAAA==.',['相以']='相以沫:BAABLAAFFH8KAAMGAAIInAbKagA1AAAGAAIIBQbKagA1AAAHAAEICgdlIQAAAAAAAA==.',['相泽']='相泽南童年版:BAAALAAECgUIBQAAAA==.',['看偶']='看偶七十二变:BAAALAAECgYICQAAAA==.',['真缺']='真缺德:BAAALAAECgIIAgAAAA==.',['知我']='知我罪我:BAAALAAFFAYIAgAAAA==.',['碧海']='碧海晴天:BAAALAAFFAIIBAAAAA==.',['神祇']='神祇大领主:BAAALAAECgYIDgAAAA==.',['神聖']='神聖的騎士:BAAALAAECgUIBQAAAA==.',['神魔']='神魔钰钰:BAAALAADCgEIAQAAAA==.',['禁区']='禁区剩骑士:BAAALAADCgEIAQAAAA==.',['秋天']='秋天的落叶:BAABLAAFFH8FAAISAAMItQ7CSwCFAAASAAMItQ7CSwCFAAAAAA==.',['秋山']='秋山落叶:BAAALAAECggICwAAAA==.',['秋蝉']='秋蝉灬:BAAALAAECgYIBgAAAA==.',['稳定']='稳定:BAAALAAECgYIBwAAAA==.',['穆啦']='穆啦丁基:BAAALAAECggICAAAAA==.',['笨笨']='笨笨妖:BAAALAAECgYIBgAAAA==.',['简单']='简单蓝:BAAALAAECgMIAwAAAA==.简单随机:BAAALAADCgYIBgAAAA==.',['精靈']='精靈阿爾薩斯:BAAALAADCgcIBwAAAA==.',['糖妈']='糖妈:BAAALAAECgYICwAAAA==.',['糖果']='糖果妈咪:BAAALAAECgYIDQAAAA==.糖果爸比:BAAALAAECgYIDQAAAA==.糖果爹爹:BAAALAAECgUIBQAAAA==.',['糖爹']='糖爹:BAAALAAECgYIBgAAAA==.',['索莉']='索莉娅:BAAALAADCgYICQAAAA==.',['索菲']='索菲亚罗纳:BAAALAADCgMIAwAAAA==.索菲雅:BAAALAAECgYICAAAAA==.',['紫色']='紫色幽默:BAAALAAECgYIBgAAAA==.',['繁花']='繁花梦落:BAAALAAECgYICQAAAA==.',['红心']='红心瞎子:BAAALAADCgQIBAAAAA==.',['纷乱']='纷乱雪月花:BAABLAAFFH8IAAIcAAgIDwMaBwAWAAAcAAgIDwMaBwAWAAAAAA==.',['结城']='结城沙罗:BAAALAAECgYIBgAAAA==.',['给我']='给我自由:BAAALAADCgYIBgAAAA==.',['罗琳']='罗琳兽帝:BAAALAAECgEIAQAAAA==.',['翟星']='翟星星:BAAALAAECgIIAgAAAA==.',['翻滚']='翻滚吧萌子:BAABLAAFFH8GAAIIAAII+hoQbwBWAAAIAAII+hoQbwBWAAAAAA==.翻滚屁屁:BAAALAAFFAIIBAAAAA==.',['老孙']='老孙一骑:BAAALAADCgQIBAAAAA==.老孙驯兽师:BAAALAADCgMIAwAAAA==.',['老张']='老张迪凯:BAAALAAECgYICwAAAA==.',['老特']='老特拉福德德:BAAALAAECgEIAQAAAA==.',['老猎']='老猎:BAAALAADCgIIAgAAAA==.',['背着']='背着盾牌找矛:BAAALAAECgQIBQABLAAECgYICAAJAAAAAA==.',['胖胖']='胖胖的糯米鸡:BAAALAAECgYIEgAAAA==.',['腾飞']='腾飞:BAAALAADCgUIBQAAAA==.',['自体']='自体脂肪丰面:BAAALAADCgEIAQAAAA==.',['臭粑']='臭粑粑:BAABLAAFFH8KAAIBAAIIchbSSgCWAAABAAIIchbSSgCWAAAAAA==.',['艾琳']='艾琳娜鹿盔:BAAALAAECgYIBgAAAA==.',['艾维']='艾维娜丶:BAACLAAFFH8LAAIdAAUI0hWrEwA4AQAdAAUI0hWrEwA4AQAsAAQKfxsAAh0ABgi8HAwbAHABAB0ABgi8HAwbAHABAAEsAAUUBQgZABcAMCIA.',['芒果']='芒果豆:BAACLAAFFH8lAAIBAAUI2hQTKgAuAQABAAUI2hQTKgAuAQAsAAQKfyEAAgEACAjpHMU0AKACAAEACAjpHMU0AKACAAAA.芒果豆豆:BAAALAAECgcIEAAAAA==.',['花雨']='花雨川:BAAALAADCgIIAgAAAA==.',['若晓']='若晓慕:BAAALAAECgYIBgAAAA==.',['英雄']='英雄城下东莞:BAAALAAECgcIBwAAAA==.英雄城二师兄:BAAALAAECgYICQAAAA==.英雄城厨子:BAAALAAECgYIBgAAAA==.英雄城地狱吼:BAAALAADCgUIBQAAAA==.英雄城游侠:BAAALAAECgYIBgAAAA==.',['荒野']='荒野:BAAALAAECgYICAAAAA==.',['荷尔']='荷尔蒙:BAAALAAFFAIIBAAAAA==.',['荷辛']='荷辛橙:BAAALAADCgUIBQAAAA==.',['莉莉']='莉莉露卡:BAAALAAECggIEAAAAA==.',['莲妹']='莲妹:BAAALAADCgQIBAAAAA==.',['菊花']='菊花劈裂者:BAAALAAECgYICwAAAA==.菊花护卫者:BAABLAAFFH8IAAIBAAgImQooMwDpAAABAAgImQooMwDpAAAAAA==.菊花电击者:BAAALAAECgcIBwAAAA==.菊花碾碎者:BAAALAAECgYIDAAAAA==.菊花追裂者:BAABLAAFFH8GAAIFAAYIMwhraACUAAAFAAYIMwhraACUAAAAAA==.',['萌萌']='萌萌哒灬呆毛:BAAALAAECgYIBgAAAA==.萌萌哒灬小德:BAAALAAECgMIAwAAAA==.',['萨老']='萨老牛:BAAALAAECgIIAgAAAA==.',['蓝羽']='蓝羽浅葱:BAAALAAECgIIAgABLAAFFAYIBgAYAJcPAA==.',['蔡琴']='蔡琴:BAAALAADCgEIAQAAAA==.',['蔷薇']='蔷薇娃娃:BAAALAADCgUIBQAAAA==.',['蕾莉']='蕾莉婭:BAAALAAECgYIBgAAAA==.',['藿香']='藿香正气水:BAAALAAECgYIBgAAAA==.',['血糯']='血糯米丸子:BAAALAAECgYICwAAAA==.',['血红']='血红瑶瑶:BAAALAAECggICAAAAA==.',['行走']='行走的偆药:BAAALAAECgEIAQAAAA==.',['被狗']='被狗带:BAAALAAECggICAAAAA==.',['裘德']='裘德洛:BAABLAAFFH8IAAIEAAIIJA67UACQAAAEAAIIJA67UACQAAAAAA==.',['观铃']='观铃:BAACLAAFFH8OAAINAAUIGAf1JQAJAQANAAUIGAf1JQAJAQAsAAQKfykAAg0ACAjBD+4lAIUBAA0ACAjBD+4lAIUBAAAA.',['訫茹']='訫茹止水:BAAALAADCgIIAgAAAA==.',['諾娮']='諾娮:BAAALAADCgUIBQAAAA==.',['諾灬']='諾灬只如初見:BAAALAAECgYIBgAAAA==.',['谁的']='谁的肥婆奶奶:BAABLAAFFH8GAAIUAAYIswCMCwDHAAAUAAYIswCMCwDHAAAAAA==.',['调四']='调四钓二:BAABLAAFFH8VAAISAAYIWhuYDgD1AQASAAYIWhuYDgD1AQAAAA==.',['谢霆']='谢霆锋:BAAALAAECgQIBAAAAA==.',['贰拾']='贰拾肆伏:BAABLAAECn8bAAMSAAYIwxxDXgDNAQASAAYIwxxDXgDNAQAMAAYIVBXbXAChAQAAAA==.',['赏明']='赏明月的呜:BAAALAAECgUIBQAAAA==.',['超越']='超越无限:BAAALAADCgEIAQAAAA==.',['跑德']='跑德快:BAAALAAECgYIBgAAAA==.',['路易']='路易斯飞哥:BAAALAAECgYIDAAAAA==.',['躺牛']='躺牛:BAAALAAFFAIIAgAAAA==.',['轻装']='轻装前行:BAAALAADCggICAAAAA==.',['轻语']='轻语:BAAALAAECgYIDwAAAA==.',['辰月']='辰月之征:BAAALAAFFAIIAgAAAA==.',['达文']='达文西:BAAALAADCgQIBAAAAA==.',['这把']='这把放速度灭:BAAALAAFFAIIAgAAAA==.',['迪儿']='迪儿幽幽:BAAALAAECgIIAgAAAA==.',['迪斯']='迪斯奈特:BAAALAAECgYICwAAAA==.',['迷失']='迷失的麦兜:BAAALAAECgQIBAAAAA==.',['迷茫']='迷茫猎刃:BAAALAADCgYIBgAAAA==.',['速度']='速度灭这把放:BAABLAAFFH8FAAINAAIIUxFLOQB7AAANAAIIUxFLOQB7AAAAAA==.',['速速']='速速寿司叭:BAAALAAECgIIAgAAAA==.速速放这把灭:BAABLAAFFH8GAAIYAAII3g1zNAAuAAAYAAII3g1zNAAuAAAAAA==.',['道炬']='道炬:BAAALAAECggICAAAAA==.',['遗忘']='遗忘之盾:BAAALAADCggICgAAAA==.遗忘者丶咕咕:BAABLAAFFH8FAAILAAUIJyGADgDWAQALAAUIJyGADgDWAQAAAA==.',['遮沙']='遮沙避风了吧:BAAALAADCgYICAAAAA==.',['醉璀']='醉璀璨:BAABLAAECn8pAAIDAAYIBiHKHwDoAQADAAYIBiHKHwDoAQAAAA==.',['鐡麒']='鐡麒:BAAALAAECgQIBAAAAA==.',['鑫森']='鑫森淼焱圭:BAAALAAECgcIEQAAAA==.',['鑫耀']='鑫耀:BAAALAAECgYIBgAAAA==.',['钎钎']='钎钎可晴:BAAALAAECgYIBgAAAA==.',['钟离']='钟离:BAABLAAFFH8GAAIYAAYIlw/REwAiAQAYAAYIlw/REwAiAQAAAA==.',['钢霸']='钢霸天:BAACLAAFFH8MAAILAAUINg5QLAC8AAALAAUINg5QLAC8AAAsAAQKfxkAAgsABgizFqxgAHEBAAsABgizFqxgAHEBAAAA.',['镜子']='镜子里的你:BAAALAADCgMIAwAAAA==.',['镜花']='镜花水月丿:BAAALAAFFAIIAgAAAA==.',['闪电']='闪电神龙:BAAALAAECgEIAQAAAA==.',['阑珊']='阑珊倩影:BAABLAAFFH8FAAILAAII3ASNUwBNAAALAAII3ASNUwBNAAAAAA==.',['阴阳']='阴阳怪气:BAAALAAECgYIBgAAAA==.',['阿伊']='阿伊莎:BAAALAAECgYIEAAAAA==.',['阿喀']='阿喀:BAAALAAECgYICQAAAA==.阿喀硫斯:BAAALAAFFAIIAgAAAA==.',['阿尔']='阿尔丶:BAAALAAECgYIDAAAAA==.',['阿斯']='阿斯塔罗特:BAAALAAECgQIBAAAAA==.',['阿木']='阿木牧:BAAALAAECgUIBQAAAA==.',['阿牛']='阿牛:BAAALAAECgYICQAAAA==.',['陰丶']='陰丶天:BAABLAAFFH8FAAIIAAIIMgoXmgA5AAAIAAIIMgoXmgA5AAAAAA==.',['随风']='随风飞翔:BAAALAAECgUIBQAAAA==.',['雅痞']='雅痞丶教授:BAAALAAECgYICwAAAA==.',['集火']='集火那个小德:BAAALAADCgYIBgAAAA==.',['雨中']='雨中邂逅:BAACLAAFFH8hAAMFAAYIyRZ8MgBwAQAFAAYIyRZ8MgBwAQATAAEIfgMyOgAsAAAsAAQKfyAAAwUABgimIjBZACoCAAUABgimIjBZACoCABMAAQj7C+fJACYAAAAA.',['雨辰']='雨辰子木:BAABLAAFFH8HAAINAAII6ACdTgA+AAANAAII6ACdTgA+AAAAAA==.',['雪域']='雪域冰封:BAABLAAFFH8PAAIBAAUI9BUyKQAzAQABAAUI9BUyKQAzAQAAAA==.',['雪豹']='雪豹闭嘴:BAAALAAECgMIAwAAAA==.',['零度']='零度戦姬:BAACLAAFFH8TAAMIAAUIwxc0PwA+AQAIAAUIlRY0PwA+AQAWAAIINxCRGQBbAAAsAAQKfxkAAwgABwhUIr8dAAYCAAgABwgpHL8dAAYCABYABgjyIV8MAGsBAAEsAAUUBgghAAUAyRYA.',['雷法']='雷法:BAAALAAECgIIAgAAAA==.',['雷电']='雷电法亡:BAAALAAECgEIAQAAAA==.雷电法王:BAAALAAFFAIIBAAAAA==.',['青月']='青月伴孤影:BAAALAADCggICgAAAA==.',['非常']='非常忧郁射神:BAAALAAFFAQIBAAAAA==.',['靥丶']='靥丶:BAAALAAECgYIDgAAAA==.',['颗粒']='颗粒剂:BAAALAAECgYIBgAAAA==.',['额也']='额也叫哀木涕:BAAALAAFFAIIAwAAAA==.',['风之']='风之德:BAABLAAECn8gAAMRAAcIcBV+OQDRAQARAAcIcBV+OQDRAQALAAIIaAls2gBLAAAAAA==.风之恶:BAAALAAECgYIDAAAAA==.风之骑:BAAALAAECgIIAgAAAA==.',['风寒']='风寒刺骨:BAAALAADCgEIAQAAAA==.',['风暴']='风暴啤酒桶:BAAALAAECgQIBAAAAA==.风暴要火:BAACLAAFFH8LAAIeAAIISxj6EQBRAAAeAAIISxj6EQBRAAAsAAQKfxsAAh4ACAhrFScRACwCAB4ACAhrFScRACwCAAAA.',['风狼']='风狼君:BAAALAADCgIIAgAAAA==.',['风逍']='风逍遥:BAAALAAECgEIAQAAAA==.',['飞我']='飞我疯狂:BAAALAAECgQIBAAAAA==.',['香甜']='香甜冰淇淋:BAAALAAECgIIBAAAAA==.',['鬼魅']='鬼魅俪影:BAAALAAFFAIIAgAAAA==.',['魅影']='魅影圣光:BAAALAAECgYIBgAAAA==.',['魔法']='魔法圣帝:BAAALAAFFAIIAgAAAA==.魔法注意事项:BAAALAAECgYICgAAAA==.',['鱼满']='鱼满:BAAALAAECgUIBQABLAAFFAIIEAAfAJYdAA==.',['鱿鱼']='鱿鱼串:BAAALAADCgYIBgAAAA==.',['鲁迪']='鲁迪乌斯:BAAALAAECggICAAAAA==.',['鲜血']='鲜血:BAAALAAECgYICwAAAA==.',['鹌鹑']='鹌鹑鹌鹑:BAAALAADCgEIAQAAAA==.',['麦科']='麦科紧固件:BAAALAADCgQIBAAAAA==.',['黄灯']='黄灯亮:BAABLAAFFH8GAAIgAAII9Q/1HwA7AAAgAAII9Q/1HwA7AAAAAA==.',['黄焖']='黄焖煲仔饭:BAABLAAFFH8RAAIDAAYIvxf1GQCgAQADAAYIvxf1GQCgAQAAAA==.',['黑手']='黑手笼罩着伱:BAAALAADCgMIAwAAAA==.',['黑暗']='黑暗涅槃:BAABLAAECn8aAAIIAAgI+RQtewACAgAIAAgI+RQtewACAgAAAA==.',['黑锋']='黑锋领主:BAACLAAFFH8XAAIIAAYItQZWRAApAQAIAAYItQZWRAApAQAsAAQKfygAAggACAilE+gsAMIBAAgACAilE+gsAMIBAAAA.',['黯刃']='黯刃遗忘者:BAAALAAECgYICAAAAA==.',['黯淡']='黯淡曲奇:BAAALAAECgYIBwAAAA==.',['龍丿']='龍丿貓:BAABLAAFFH8pAAINAAYIhSWLBACLAgANAAYIhSWLBACLAgABLAAFFAgIPwAMAHUlAA==.',['龍哥']='龍哥丶:BAABLAAFFH8IAAIXAAIIVx+IIADEAAAXAAIIVx+IIADEAAAAAA==.',['龍灬']='龍灬貓:BAABLAAFFH8kAAIIAAYIUhz1HwC1AQAIAAYIUhz1HwC1AQABLAAFFAgIPwAMAHUlAA==.',['龙魂']='龙魂雨风:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end