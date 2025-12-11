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
 local lookup = {'Warlock-Demonology','Warlock-Destruction','Rogue-Assassination','Rogue-Subtlety','Mage-Arcane','DeathKnight-Frost','DemonHunter-Havoc','Priest-Holy','DeathKnight-Blood','Mage-Frost','Paladin-Retribution','Warrior-Fury','Warrior-Protection','Hunter-Marksmanship','Druid-Restoration','Druid-Any','Druid-Balance','Hunter-BeastMastery','Evoker-Preservation','Evoker-Devastation','Shaman-Restoration','Shaman-Elemental','Monk-Windwalker','Monk-Mistweaver','Paladin-Holy','Hunter-Survival','Paladin-Protection','DemonHunter-Vengeance','Druid-Guardian','Warlock-Affliction','Druid-Feral',}; local provider = {region='CN',realm='普瑞斯托',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ad='Adencol:BAABLAAFFH8PAAMBAAMIOReGHwBvAAABAAEIMSWGHwBvAAACAAIIPBCeWABHAAAAAA==.',An='Anne:BAAALAAECggIDwAAAA==.',As='Asteria:BAAALAAECgYIEgAAAA==.',Ba='Bacterium:BAAALAAECgMIAwAAAA==.',Bl='Blazzer:BAAALAAECgQIBAAAAA==.Bleachdream:BAABLAAECn8UAAMCAAYIVwe4ZgDLAAACAAYIVwe4ZgDLAAABAAEIDgSBngAtAAAAAA==.Blindmaker:BAAALAAECgcIEAAAAA==.Blooddagger:BAACLAAFFH8aAAMDAAYI4xL/DAAAAQADAAQIjhb/DAAAAQAEAAQI2gsEDADXAAAsAAQKfyMAAwMACAgxHz8SAI0CAAMACAhxHD8SAI0CAAQABAh7GvwRAO0AAAAA.',Do='Doubleten:BAAALAAECgEIAQAAAA==.Dovahkiin:BAAALAADCgcIBwAAAA==.',Em='Emiliaclarke:BAAALAAECggIBQAAAA==.',Gi='Gin:BAAALAADCgIIAgAAAA==.',Gr='Greegirl:BAAALAAECgYIBgAAAA==.',Gu='Gugul:BAABLAAFFH8GAAIFAAIIDRrvPQCiAAAFAAIIDRrvPQCiAAAAAA==.',Ho='Howdoilove:BAAALAAFFAIIAgAAAA==.',Ju='Justitia:BAAALAADCgEIAQAAAA==.',Ma='Mahapralaya:BAAALAAFFAQIBAAAAA==.',Ni='Nikandjay:BAAALAADCgMIAwAAAA==.',Pa='Pangdie:BAAALAAECgQIBAAAAA==.',Pi='Piroteus:BAABLAAFFH8OAAIGAAII5BTYgQBFAAAGAAII5BTYgQBFAAAAAA==.',Se='Seaheart:BAAALAADCgUICQAAAA==.',Si='Silentrun:BAAALAAECgIIAgAAAA==.Sindweller:BAABLAAFFH8JAAIHAAIIjxRMSwBOAAAHAAIIjxRMSwBOAAAAAA==.',Sp='Sparkuggz:BAAALAAECgYIBgAAAA==.',Su='Suxing:BAAALAAECgEIAQAAAA==.',Td='Tdsky:BAAALAADCgcIBwAAAA==.',Te='Tend:BAABLAAFFH8IAAIIAAIIqRvXNACTAAAIAAIIqRvXNACTAAAAAA==.',To='Tonk:BAAALAAECgUIBgAAAA==.',Ul='Ulquiorra:BAAALAAFFAIIAgAAAA==.',Vo='Vov:BAAALAAECgYIDAAAAA==.',Wa='Wanaka:BAAALAAFFAIIBAAAAA==.',Wo='Wolfgonzalez:BAAALAAECggIEgAAAA==.',Xd='Xdj:BAAALAAECgEIAQAAAA==.',Yu='Yuina:BAAALAAFFAIIAgAAAA==.',['一弯']='一弯丹桂:BAAALAAECgYIBgAAAA==.',['一杯']='一杯红酒:BAAALAAECgYIDQAAAA==.',['一生']='一生有你:BAAALAAFFAIIAgAAAA==.',['一隼']='一隼一:BAAALAAFFAgIAgAAAA==.',['丄丅']='丄丅:BAAALAAECgYIDAAAAA==.',['三零']='三零八凤凰:BAAALAAFFAYIAgAAAA==.',['不思']='不思议妖妖:BAAALAAFFAIIAgAAAA==.',['不要']='不要乱开怪:BAABLAAECn8YAAIJAAgI3wZiGwDpAAAJAAgI3wZiGwDpAAAAAA==.',['丨淑']='丨淑丨:BAABLAAECn8VAAIKAAcIuRZCFQCBAQAKAAcIuRZCFQCBAQAAAA==.',['丨诺']='丨诺尼丨:BAAALAAECggIDQAAAA==.',['中碎']='中碎发荷叶头:BAAALAAECgQIBAAAAA==.',['临申']='临申:BAABLAAFFH8MAAILAAIIjQ3wZgBDAAALAAIIjQ3wZgBDAAAAAA==.',['丶熙']='丶熙寒:BAAALAAFFAIIAgAAAA==.',['为你']='为你落泪:BAAALAAECgEIAQAAAA==.',['为期']='为期:BAAALAAECgYIBgAAAA==.',['九月']='九月飞扬:BAAALAAECgMIAwAAAA==.',['乱丶']='乱丶:BAABLAAFFH8KAAIMAAMIPxFHGwDvAAAMAAMIPxFHGwDvAAABLAAFFAgICAANAFMBAA==.',['云屏']='云屏淡远山:BAABLAAFFH8GAAIHAAYIrgQnNgDOAAAHAAYIrgQnNgDOAAAAAA==.',['亢龙']='亢龙有悔:BAAALAAECgYIBgAAAA==.',['仙姬']='仙姬:BAAALAADCggIDwAAAA==.',['伊利']='伊利达雷血刃:BAAALAAECgYIBgAAAA==.',['伊诺']='伊诺的旺财:BAAALAAECgYIDgAAAA==.伊诺的狗蛋:BAAALAAFFAIIAgAAAA==.伊诺的猫猪:BAAALAADCgUIBQAAAA==.',['休闲']='休闲老司机:BAAALAADCgEIAQAAAA==.',['优雅']='优雅的胖子:BAAALAAECgIIAgAAAA==.',['会嗜']='会嗜血的萨满:BAAALAAECgYICQAAAA==.',['佐高']='佐高皖腾:BAAALAAFFAIIBAAAAA==.',['佢話']='佢話唔俾面:BAAALAAECgIIAgAAAA==.',['保安']='保安队长:BAAALAAFFAIIAgAAAA==.',['信箱']='信箱里的袋鼠:BAAALAAECgYIDwAAAA==.',['修仙']='修仙小蚂蚁:BAABLAAFFH8GAAIOAAYIGRvnAwD7AQAOAAYIGRvnAwD7AQAAAA==.',['俺是']='俺是晓徳:BAABLAAFFH8IAAIGAAQIbxXlQACyAAAGAAQIbxXlQACyAAAAAA==.',['倾听']='倾听安琪儿:BAAALAAFFAIIBAAAAA==.',['停杯']='停杯投箸:BAAALAADCgQIBAAAAA==.',['偶尔']='偶尔番茄一下:BAAALAAECgUIBQAAAA==.',['偷天']='偷天盗盗:BAAALAAECgYIDwAAAA==.',['元气']='元气猫师傅:BAAALAADCgcIBwAAAA==.',['光头']='光头德加暴击:BAAALAAECgYIBgAAAA==.',['克罗']='克罗撒:BAAALAAECgYIDQAAAA==.',['六一']='六一地板王:BAAALAAFFAIIAgAAAA==.',['兮戊']='兮戊辰:BAAALAAECgUICgAAAA==.',['兽群']='兽群之心:BAABLAAFFH8KAAIPAAIIhRsVOQCHAAAPAAIIhRsVOQCHAAAAAA==.',['兽血']='兽血沸腾:BAAALAAECgEIAQAAAA==.',['冰奶']='冰奶茶:BAAALAADCggICAAAAA==.',['冲丶']='冲丶锋:BAABLAAFFH8HAAINAAMILQ4QIgBqAAANAAMILQ4QIgBqAAAAAA==.',['决战']='决战华尔街:BAAALAAFFAIIAgAAAA==.',['冷月']='冷月清辉:BAABLAAFFH8GAAIQAAYIdgcAAAAAAAARAAYIdgcAAAAAAAAAAA==.',['凌风']='凌风御苍穹:BAABLAAFFH8HAAILAAcIogFGgAAuAAALAAcIogFGgAAuAAAAAA==.',['凯尔']='凯尔利斯:BAAALAAFFAIIBAAAAA==.',['凯文']='凯文愿竭心力:BAAALAAECgMIAwAAAA==.',['刀剑']='刀剑双辉:BAAALAAECgYIBgAAAA==.',['剑戟']='剑戟与塔盾:BAAALAAECgYIBgAAAA==.',['加鲁']='加鲁鲁:BAAALAAECgYICAAAAA==.',['北鼻']='北鼻儿:BAAALAAECgUIBQAAAA==.',['十分']='十分之二:BAABLAAFFH8GAAIGAAYIFACKrQABAAAGAAYIFACKrQABAAAAAA==.',['十年']='十年丶:BAAALAAECgUIBQAAAA==.',['千中']='千中由村:BAAALAAFFAIIAgAAAA==.',['卓耿']='卓耿:BAAALAAECgYIDQAAAA==.',['卷不']='卷不动:BAAALAAFFAgIAQAAAA==.',['叁拾']='叁拾柒丶洃色:BAAALAADCgMIAwAAAA==.',['反盟']='反盟:BAAALAAECgQIBAAAAA==.',['只虐']='只虐菜丶:BAAALAAFFAIIAgAAAA==.',['可别']='可别哎了:BAAALAAECgcIBwAAAA==.',['可愛']='可愛茉莉:BAABLAAECn8cAAIFAAgIZhM2VwD/AQAFAAgIZhM2VwD/AQAAAA==.',['叽叽']='叽叽咕咕:BAAALAAECgYICQAAAA==.',['各種']='各種酸甜:BAABLAAFFH8JAAILAAQI+xpyMAABAQALAAQI+xpyMAABAQAAAA==.',['吖咩']='吖咩咯:BAAALAAECgYIBwAAAA==.',['哎呀']='哎呀你的手:BAAALAADCgUIBQAAAA==.',['唤醒']='唤醒你:BAAALAADCgEIAQAAAA==.',['嘉嘉']='嘉嘉莉娅:BAAALAAECggICAAAAA==.',['嘿哞']='嘿哞凶:BAAALAAECgYIBgAAAA==.',['噜喵']='噜喵喵:BAABLAAFFH8WAAISAAUIihz6NwBfAQASAAUIihz6NwBfAQAAAA==.',['四季']='四季不觉晓:BAAALAADCgMIAwAAAA==.',['回眸']='回眸的安琪儿:BAAALAAFFAIIAgAAAA==.',['圆汐']='圆汐汐:BAAALAAECgYICAAAAA==.',['圣光']='圣光之荣耀:BAAALAADCgQIBAAAAA==.',['坐在']='坐在树下:BAAALAADCgYIBgAAAA==.',['增辉']='增辉龙:BAABLAAFFH8MAAMTAAIIXiS8DQDLAAATAAIIXiS8DQDLAAAUAAEIpwHHJQAwAAAAAA==.',['夔喾']='夔喾狼貉:BAAALAAECgYIBwAAAA==.',['外科']='外科医生:BAAALAAECgIIAgAAAA==.外科女医生:BAABLAAFFH8IAAIIAAII+xctNwCFAAAIAAII+xctNwCFAAAAAA==.',['夜中']='夜中的安琪儿:BAABLAAFFH8LAAMVAAMIZhceVABzAAAVAAIICxUeVABzAAAWAAII+wbSOQBvAAAAAA==.',['夜杀']='夜杀:BAAALAAECgUIBQAAAA==.',['夜法']='夜法:BAAALAADCgcIBwAAAA==.',['夜雨']='夜雨落西山:BAAALAADCggICAAAAA==.',['大保']='大保健:BAAALAAFFAIIAgAAAA==.',['大宗']='大宗师转死你:BAACLAAFFH8sAAIXAAcIGCNkAQBuAgAXAAcIGCNkAQBuAgAsAAQKfxoAAhcABggPJRcKAAUCABcABggPJRcKAAUCAAAA.',['大波']='大波浪:BAABLAAECn8VAAIFAAcIzAKwWwCSAAAFAAcIzAKwWwCSAAAAAA==.',['大熊']='大熊:BAAALAAECgIIAgAAAA==.',['大耳']='大耳朵王:BAAALAAECgQIBwAAAA==.',['天地']='天地绝月:BAAALAAECgYIDgAAAA==.',['天灵']='天灵灵地灵灵:BAAALAAFFAIIAgAAAA==.',['天那']='天那么黑:BAAALAADCgEIAQAAAA==.',['天际']='天际宝:BAAALAADCgQIBAAAAA==.天际猎:BAABLAAECn8UAAISAAgIOg0WngAcAQASAAgIOg0WngAcAQAAAA==.天际猎手:BAAALAAECgYIEwAAAA==.天际萨:BAAALAAECgIIAgAAAA==.',['夺命']='夺命狩猎者:BAAALAAECgYIBgAAAA==.',['奈兒']='奈兒:BAACLAAFFH8LAAIVAAIIVxyeQwCbAAAVAAIIVxyeQwCbAAAsAAQKfxYAAhUABwjuIPk6AC4CABUABwjuIPk6AC4CAAAA.',['女粉']='女粉很多的人:BAAALAAECgUIBQAAAA==.',['好米']='好米:BAAALAADCgUIBgAAAA==.',['妖丶']='妖丶血纹:BAABLAAFFH8eAAIGAAYIKRu9HADDAQAGAAYIKRu9HADDAQAAAA==.',['姜姜']='姜姜:BAABLAAFFH8GAAICAAYI9xzwGgC3AQACAAYI9xzwGgC3AQAAAA==.',['姬无']='姬无魂:BAAALAAFFAEIAQAAAA==.',['容赦']='容赦丶姬:BAAALAAECggICAAAAA==.',['寳銞']='寳銞:BAAALAADCgUIBQAAAA==.',['将登']='将登太行:BAAALAAFFAIIBAAAAA==.',['小小']='小小宋:BAAALAAECgIIAgAAAA==.小小的很可爱:BAAALAAECgYIBgABLAAFFAcILAAXABgjAA==.',['小手']='小手轻柔:BAABLAAFFH8GAAICAAYIvBl1CQApAgACAAYIvBl1CQApAgAAAA==.',['小米']='小米可乐:BAAALAAECgYIBgAAAA==.',['小美']='小美的大壮:BAAALAAECgIIAgAAAA==.',['小莫']='小莫非:BAAALAAECgMIAwAAAA==.',['小角']='小角漂亮:BAAALAAFFAEIAQAAAA==.',['小野']='小野泉熙:BAAALAAFFAIIAgAAAA==.',['少林']='少林十七铜人:BAAALAADCgQIBAAAAA==.',['尛萨']='尛萨满:BAAALAAECgMIAwAAAA==.',['就打']='就打德:BAACLAAFFH8SAAIPAAUIRBK2HABBAQAPAAUIRBK2HABBAQAsAAQKfxQAAg8ABgjQGXEkALIBAA8ABgjQGXEkALIBAAAA.',['嵝仨']='嵝仨肆:BAAALAAECgYICwAAAA==.',['巧心']='巧心柔:BAAALAAFFAIIAgAAAA==.',['帅俊']='帅俊算什么:BAAALAAECgMIBAAAAA==.',['师太']='师太借个吻:BAAALAAECgYIBgAAAA==.',['异步']='异步基金:BAAALAAFFAIIBAAAAA==.',['弑神']='弑神之刃:BAAALAAECgUIBQAAAA==.',['弑魔']='弑魔:BAACLAAFFH8GAAMSAAIIdx15bQCBAAASAAIICQ95bQCBAAAOAAEIXiEFMABgAAAsAAQKfxoAAw4ABwi+Icg/ALgBAA4ABggBG8g/ALgBABIABgg4HAagAKwBAAAA.',['引天']='引天行:BAAALAAECgUICQAAAA==.',['影月']='影月语:BAAALAAECggIDQAAAA==.',['影踪']='影踪派二少爷:BAAALAAECgYIBgAAAA==.',['往昔']='往昔记忆:BAAALAAECgYIBgAAAA==.',['忘忧']='忘忧:BAAALAAECgYIDgAAAA==.',['思念']='思念安琪儿:BAAALAAECgYIBgAAAA==.',['怡宝']='怡宝宝强:BAAALAAECgEIAQAAAA==.',['恩诺']='恩诺拉:BAAALAAECgYICAAAAA==.',['恰似']='恰似妳的温柔:BAAALAAECgYIBgAAAA==.',['想念']='想念安琪儿:BAAALAAECgYIBgAAAA==.',['慕辰']='慕辰:BAABLAAFFH8GAAIVAAYICxNICAC5AQAVAAYICxNICAC5AQAAAA==.',['我不']='我不是海绵:BAAALAAFFAIIAgAAAA==.',['我就']='我就这样:BAAALAADCgYIBgAAAA==.',['我开']='我开动物园:BAAALAADCgQIBAAAAA==.',['战斗']='战斗无限:BAAALAAECgQICAAAAA==.',['打不']='打不过就跑:BAABLAAECn8YAAINAAgIcgb+WwAVAQANAAgIcgb+WwAVAQAAAA==.',['扯起']='扯起一脚尖:BAAALAAECgQIBAAAAA==.',['扶老']='扶老奶奶过街:BAABLAAFFH8FAAIYAAMIUhIFEQCnAAAYAAMIUhIFEQCnAAAAAA==.',['护心']='护心毛:BAABLAAFFH8JAAICAAIIQgUSUwB5AAACAAIIQgUSUwB5AAAAAA==.',['拼图']='拼图爱吃西瓜:BAAALAAECgIIAwAAAA==.',['挥手']='挥手的瞬间:BAAALAAECgYIDAAAAA==.',['掌控']='掌控风暴:BAAALAAFFAQIBAAAAA==.',['揪眯']='揪眯眯:BAAALAAFFAIIAgAAAA==.',['摸摸']='摸摸金子:BAAALAAECgYIBgAAAA==.',['故作']='故作纯情:BAAALAADCgYIBgAAAA==.',['救赎']='救赎:BAAALAAECgYICgAAAA==.',['数字']='数字堡垒:BAAALAAECgYIDAAAAA==.',['新建']='新建小角色:BAABLAAFFH8GAAISAAIINRkhhQBLAAASAAIINRkhhQBLAAAAAA==.',['无名']='无名的人:BAABLAAFFH8IAAILAAQI+hLKWwBIAAALAAQI+hLKWwBIAAAAAA==.',['无忧']='无忧猎:BAAALAAECgYIBgAAAA==.',['无言']='无言啊:BAAALAAECgYICQAAAA==.',['无辜']='无辜者的悼词:BAABLAAFFH8HAAIZAAMITw3hHwCjAAAZAAMITw3hHwCjAAABLAAFFAYIOAABAH0kAA==.',['无道']='无道极法魔君:BAAALAAECgYIBgAAAA==.',['旭日']='旭日:BAABLAAFFH8GAAIZAAIIxgtfKABqAAAZAAIIxgtfKABqAAAAAA==.',['时分']='时分:BAACLAAFFH8IAAIKAAgIuAn+BwAcAQAKAAgIuAn+BwAcAQAsAAQKfxYAAwoABgi7HIAuAMMBAAoABgi7HIAuAMMBAAUABAioEoxVAK0AAAAA.',['星澜']='星澜:BAAALAAFFAQIBAAAAA==.',['星痕']='星痕:BAAALAAFFAIIAgAAAA==.',['星际']='星际飞梭:BAAALAAECgYIBgAAAA==.',['景井']='景井阳菜:BAAALAAFFAIIAgAAAA==.',['晴心']='晴心:BAAALAAECgUIBQAAAA==.',['晴風']='晴風:BAAALAADCgYIBgAAAA==.',['暗夜']='暗夜影子:BAAALAAFFAIIAgAAAA==.',['暗影']='暗影怒嚎:BAAALAAECgEIAQAAAA==.暗影惩罚者:BAAALAADCggICAAAAA==.',['暗紫']='暗紫色的奶:BAAALAADCggICwAAAA==.',['暴怒']='暴怒者格鲁:BAAALAAFFAIIAwAAAA==.',['月下']='月下丝丝:BAAALAADCgEIAQAAAA==.月下伊人:BAAALAADCgEIAQAAAA==.月下的安琪儿:BAABLAAFFH8SAAIGAAYI6hIJLgCCAQAGAAYI6hIJLgCCAQAAAA==.',['月影']='月影云际:BAAALAAECggICAAAAA==.',['有本']='有本事羊我啊:BAAALAAECgYICwAAAA==.',['有话']='有话好好说:BAAALAAECgcIDwAAAA==.',['望月']='望月穗波:BAACLAAFFH8pAAQOAAYIfCM5AgDrAQAOAAYIfCM5AgDrAQAaAAEIAghjCABKAAASAAEIJROBhgBJAAAsAAQKfysAAw4ACAhnImMPAOgCAA4ACAhnImMPAOgCABoAAwgkHqQaAO0AAAAA.',['未定']='未定之天命:BAAALAAECggICAAAAA==.',['术靈']='术靈:BAAALAAFFAEIAQAAAA==.',['朴实']='朴实:BAABLAAFFH8HAAISAAMIxBobjABHAAASAAMIxBobjABHAAABLAAFFAcILAAXABgjAA==.',['杀死']='杀死大黑:BAAALAADCgIIAgAAAA==.',['杀熊']='杀熊的拳志郎:BAAALAAFFAIIAgAAAA==.',['李寻']='李寻欢丶:BAAALAAFFAIIAgAAAA==.',['来自']='来自天涯:BAAALAADCgIIAgAAAA==.',['枇杷']='枇杷:BAAALAADCgYIBgAAAA==.',['柏拉']='柏拉图式爱情:BAAALAADCgMIAwAAAA==.',['格丽']='格丽乔:BAAALAAECgEIAQAAAA==.',['梦想']='梦想传说:BAAALAAFFAIIAgAAAA==.',['槲叶']='槲叶落山路:BAAALAAECgYIBgAAAA==.',['欧若']='欧若拉之星:BAAALAAECgYIEwAAAA==.',['正经']='正经小男孩:BAAALAAECgYIBAAAAA==.',['武战']='武战:BAAALAAECgQIBgAAAA==.',['死神']='死神之影:BAAALAAECgMIAgAAAA==.',['比翼']='比翼齐飞:BAABLAAFFH8cAAIFAAYIWxSaJQB+AQAFAAYIWxSaJQB+AQAAAA==.',['永不']='永不为奴:BAAALAAECggICAAAAA==.',['江南']='江南七夜雨:BAAALAAFFAIIAgAAAA==.江南凌剑天:BAAALAAECgYIBgAAAA==.江南春十三:BAAALAADCgIIAgAAAA==.江南烟雨楼:BAAALAAFFAIIAgAAAA==.江南超级帅哥:BAAALAAFFAgIAwAAAA==.',['江暗']='江暗雨欲来:BAAALAAECgIIAgAAAA==.',['沃里']='沃里克:BAAALAADCggIFAAAAA==.',['没关']='没关系:BAACLAAFFH8IAAIHAAQIfBJONQDZAAAHAAQIfBJONQDZAAAsAAQKfxQAAgcABggyHSA3AH0BAAcABggyHSA3AH0BAAEsAAUUBwgsABcAGCMA.没关系都神经:BAAALAADCgYIBgABLAAFFAcILAAXABgjAA==.',['没理']='没理走天下哦:BAAALAAECgIIAgAAAA==.',['沫小']='沫小逆:BAAALAAECgYICAAAAA==.',['波波']='波波头波妞:BAAALAAECgYIBgAAAA==.',['涅法']='涅法雷姆:BAAALAAECgYIBgAAAA==.',['深澜']='深澜:BAAALAADCgcIBwAAAA==.',['深蓝']='深蓝幻蓝:BAAALAAFFAEIAQAAAA==.',['渊恸']='渊恸:BAABLAAFFH8IAAIGAAYIAyKyIwClAQAGAAYIAyKyIwClAQABLAAFFAgIJgATAG0aAA==.',['温桑']='温桑批话多:BAAALAAECggICAAAAA==.',['游子']='游子:BAAALAAECgYIBgAAAA==.',['游戏']='游戏梦:BAAALAAFFAEIAQAAAA==.',['滚滚']='滚滚哈密瓜:BAAALAAFFAEIAQAAAA==.滚滚果粒多:BAAALAADCgMIBQAAAA==.',['漕泾']='漕泾战骑:BAAALAAECgYIDwAAAA==.',['灬过']='灬过来贴贴灬:BAAALAADCggICAAAAA==.',['灰野']='灰野:BAABLAAFFH8GAAIGAAIIbRynQwCuAAAGAAIIbRynQwCuAAAAAA==.',['烈焰']='烈焰重生:BAAALAAECgYICgAAAA==.',['烈玄']='烈玄:BAAALAADCggICAAAAA==.',['烟花']='烟花易冷:BAABLAAFFH8GAAIEAAYIUBWfAwD5AQAEAAYIUBWfAwD5AQAAAA==.',['烧酒']='烧酒:BAAALAAFFAIIAgAAAA==.',['熊迪']='熊迪芭拉怪:BAAALAAFFAEIAQAAAA==.',['燃烧']='燃烧灬青春:BAAALAAFFAQIAgAAAA==.',['爱睡']='爱睡觉的野猪:BAAALAADCgYIDgAAAA==.',['爱瞌']='爱瞌睡的喵酱:BAAALAADCgcIBwAAAA==.',['爱莉']='爱莉希雅:BAACLAAFFH8hAAILAAYISCYjBQAXAgALAAYISCYjBQAXAgAsAAQKfykAAwsACAghJY0LAFEDAAsACAghJY0LAFEDABsABQh1E3EjAPYAAAAA.',['爱醉']='爱醉的猫:BAAALAAECgYIBgAAAA==.',['牧有']='牧有鱼丸粗面:BAAALAAECgYICQAAAA==.',['猎龙']='猎龙专家:BAAALAAECgEIAQAAAA==.',['猕霓']='猕霓:BAAALAADCgEIAQAAAA==.',['璐璐']='璐璐小熊:BAAALAAECgYIEwAAAA==.',['疯狂']='疯狂小萨:BAAALAAECgYIBgAAAA==.',['百米']='百米冠军:BAAALAAECgYIBAAAAA==.',['真没']='真没关系吗:BAAALAAFFAIIBAAAAA==.',['碧螺']='碧螺春:BAABLAAFFH8GAAMHAAIICRLLSQCSAAAHAAIICRLLSQCSAAAcAAIIKglQFgBcAAAAAA==.',['神圣']='神圣丶:BAAALAAECgQIBAAAAA==.',['神奇']='神奇游侠:BAAALAAECgYIBgAAAA==.',['神里']='神里绫华:BAAALAADCggICAAAAA==.',['秋水']='秋水若漓:BAAALAAECgIIAgAAAA==.',['秋风']='秋风细语:BAAALAAECgQIBQAAAA==.',['积雪']='积雪浮云端:BAABLAAFFH8GAAMbAAYISgDnJQABAAAbAAIIZADnJQABAAALAAQIPACDigAAAAAAAA==.',['究极']='究极小强:BAABLAAFFH8KAAIMAAII+xYqOgCUAAAMAAII+xYqOgCUAAAAAA==.',['空青']='空青:BAAALAAFFAMIAwAAAA==.',['章鱼']='章鱼烧:BAABLAAFFH8MAAIVAAIIhwPfaQBWAAAVAAIIhwPfaQBWAAAAAA==.',['筑梦']='筑梦的安琪儿:BAAALAAECgYIBwAAAA==.',['筱黑']='筱黑牛:BAAALAADCgIIAgAAAA==.',['米奈']='米奈丶:BAACLAAFFH8KAAIOAAIIjCXJEQDZAAAOAAIIjCXJEQDZAAAsAAQKfxoAAw4ABghgJLMjAE4CAA4ABgg8I7MjAE4CABIAAQjEJR0TAWcAAAAA.',['米罗']='米罗:BAAALAADCggICAAAAA==.',['糯米']='糯米:BAAALAAECgYIBgAAAA==.',['索林']='索林:BAAALAAECgYIEAAAAA==.',['紫毓']='紫毓离歌丶:BAAALAAECgUICgAAAA==.',['紫陌']='紫陌阡玉:BAABLAAFFH8GAAIZAAYIGiOmBABbAgAZAAYIGiOmBABbAgAAAA==.',['红唇']='红唇一族:BAAALAAECgYIEwAAAA==.',['红彤']='红彤彤:BAAALAAECggICAAAAA==.',['纯洁']='纯洁小扁鹊:BAAALAAFFAIIAgAAAA==.',['终南']='终南阴岭秀:BAAALAADCgEIAQAAAA==.',['美白']='美白恶魔獵手:BAAALAAECgIIAgAAAA==.',['羽越']='羽越打豆芽:BAAALAAFFAIIBAAAAA==.',['老逮']='老逮:BAAALAAECgYIBwAAAA==.',['胸毛']='胸毛迎风飘:BAABLAAFFH8FAAISAAIIHAvraQCEAAASAAIIHAvraQCEAAAAAA==.',['色拉']='色拉:BAAALAADCgIIAgAAAA==.',['艾玛']='艾玛好:BAAALAAFFAIIAgAAAA==.',['花开']='花开十二:BAAALAAECgMIBgAAAA==.花开花落:BAABLAAFFH8GAAIPAAIIAxnYJACUAAAPAAIIAxnYJACUAAAAAA==.',['花样']='花样作死冠军:BAACLAAFFH85AAMOAAgIpCQuAADLAgAOAAcILCMuAADLAgASAAYIbSKsCgDmAQAsAAQKfykAAw4ACAjmJVsCAGYDAA4ACAjOJVsCAGYDABIAAgjGJGbUANAAAAAA.',['花舞']='花舞四季:BAAALAAFFAIIAgAAAA==.',['花里']='花里个花:BAAALAADCgYIBgAAAA==.',['苍月']='苍月之霜:BAABLAAFFH8KAAILAAYITBHTIABjAQALAAYITBHTIABjAQAAAA==.',['英魂']='英魂归来兮:BAAALAAECgQIBAAAAA==.',['莫奈']='莫奈:BAABLAAFFH8GAAIIAAII9wh3QgBmAAAIAAII9wh3QgBmAAAAAA==.',['莫小']='莫小逆:BAAALAAECgQIBAAAAA==.',['菜菜']='菜菜的德:BAAALAAECgUIBQAAAA==.',['萌萌']='萌萌的小萨:BAACLAAFFH82AAMVAAYIsB/eCACvAQAVAAYIsB/eCACvAQAWAAUIKhNdGAB7AQAsAAQKfyMAAxUABwhlH9cUAEsCABUABwhlH9cUAEsCABYABgjiFVZgAJcBAAAA.',['萨诺']='萨诺斯:BAAALAAFFAIIAgAAAA==.',['落日']='落日远:BAAALAAECgQIBAAAAA==.',['蒙牛']='蒙牛就是牛:BAAALAAECgMIAwAAAA==.',['蓬萊']='蓬萊山辉夜:BAABLAAFFH8aAAIMAAYIVxQFGgCUAQAMAAYIVxQFGgCUAQAAAA==.',['蘭伍']='蘭伍贰:BAAALAAECggIAwAAAA==.',['讷愚']='讷愚:BAABLAAFFH8IAAICAAgI/QABVgBPAAACAAgI/QABVgBPAAAAAA==.',['谜之']='谜之女主角:BAAALAAECgYIBgAAAA==.',['谭宁']='谭宁:BAABLAAECn8aAAISAAYInhk7nwCtAQASAAYInhk7nwCtAQAAAA==.',['贼喊']='贼喊捉贼:BAAALAAECgEIAQAAAA==.',['赖皮']='赖皮牛:BAABLAAFFH8GAAIdAAIIqQrECQBlAAAdAAIIqQrECQBlAAAAAA==.',['路飞']='路飞:BAABLAAFFH8aAAMCAAYImCHOKQBzAQACAAUIaiHOKQBzAQAeAAEIfyL2BQBiAAAAAA==.',['连晓']='连晓烁:BAAALAAECgYIDAAAAA==.',['迷之']='迷之倩影:BAAALAADCgYIBgAAAA==.',['邪恶']='邪恶终结:BAAALAAFFAIIAgAAAA==.',['金色']='金色美娇娘:BAAALAAFFAIIAgAAAA==.',['钻石']='钻石:BAAALAAFFAEIAQAAAA==.',['铁羽']='铁羽:BAAALAAFFAIIAgAAAA==.',['铭记']='铭记安琪儿:BAAALAAECgYIBgAAAA==.',['银月']='银月夜舞:BAAALAADCgQIBAAAAA==.',['长命']='长命熊:BAAALAAECgQIBAAAAA==.',['长风']='长风倚碧鸢:BAAALAAECgYIBgAAAA==.',['阿卡']='阿卡林:BAAALAADCggICAAAAA==.',['阿塔']='阿塔拉:BAAALAAECgYIDgAAAA==.',['阿尔']='阿尔芙:BAAALAAECgYIBwAAAA==.',['阿布']='阿布罗迪:BAAALAADCggICAAAAA==.',['陆雨']='陆雨琴诚:BAAALAAECgYIBgAAAA==.',['隐形']='隐形肌肉男:BAAALAADCgYIBgAAAA==.',['雨添']='雨添情:BAAALAAECgYIBwAAAA==.',['雨落']='雨落寒尘缘:BAABLAAECn8cAAQPAAYIIweOYgCUAAAPAAYIIweOYgCUAAARAAMIrgUSmgBjAAAdAAUIpwOWIwBaAAAAAA==.',['雷神']='雷神托尔:BAAALAAECgQIBAAAAA==.',['雾里']='雾里寻花:BAAALAAFFAIIBAABLAAFFAIIBgASAHcdAA==.',['雾雨']='雾雨广藿香:BAAALAAECgYIBgAAAA==.',['静脉']='静脉:BAAALAAECgYIBgAAAA==.',['風行']='風行者:BAABLAAFFH8NAAISAAUI8BGaTgATAQASAAUI8BGaTgATAQAAAA==.',['风浅']='风浅丶:BAABLAAFFH8FAAIRAAMIsBERKAB0AAARAAMIsBERKAB0AAAAAA==.',['风神']='风神忽悠着你:BAAALAADCgEIAQAAAA==.',['飞天']='飞天大脚:BAAALAADCgEIAQAAAA==.',['高莉']='高莉刺客:BAAALAAECgYICgAAAA==.',['高达']='高达正义必胜:BAACLAAFFH8GAAIRAAIINBh5HQCSAAARAAIINBh5HQCSAAAsAAQKfxUAAxEABgiIGqFHAJYBABEABgiIGqFHAJYBAB8AAQjDDdpKADgAAAAA.',['鳳舞']='鳳舞九天:BAABLAAFFH8MAAMHAAUIiA4HLQAwAQAHAAUIiA4HLQAwAQAcAAIIbQTAGgAeAAAAAA==.',['黎丶']='黎丶语风:BAABLAAFFH8GAAIPAAYIhgA+WQA9AAAPAAYIhgA+WQA9AAAAAA==.',['黑眼']='黑眼圈:BAAALAAECgQIBAAAAA==.',['黑豆']='黑豆:BAABLAAFFH8GAAIdAAIIRwbwCgBcAAAdAAIIRwbwCgBcAAAAAA==.',['黑龙']='黑龙王子:BAAALAAFFAIIBAAAAA==.',['黒荳']='黒荳:BAAALAAFFAIIBAAAAA==.',['龙舌']='龙舌籣:BAABLAAFFH8NAAIOAAIIwg6dLwBiAAAOAAIIwg6dLwBiAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end