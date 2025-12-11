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
 local lookup = {'DemonHunter-Havoc','Hunter-BeastMastery','Shaman-Restoration','Mage-Frost','Mage-Arcane','Paladin-Retribution','Paladin-Protection','Druid-Balance','DemonHunter-Vengeance','DeathKnight-Frost','Monk-Mistweaver','Unknown-Unknown','Shaman-Elemental','Monk-Windwalker','Warrior-Fury','Priest-Discipline','Paladin-Holy','Monk-Brewmaster','Rogue-Assassination','Rogue-Subtlety','Druid-Restoration','Hunter-Marksmanship',}; local provider = {region='CN',realm='埃雷达尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aj='Ajjaj:BAAALAAFFAEIAQAAAA==.',An='Anesidora:BAAALAAFFAIIBAAAAA==.',Bl='Blackangel:BAAALAAECgYIDAAAAA==.',Em='Emiria:BAAALAAFFAIIBAAAAA==.',Fi='Fino:BAAALAAFFAIIBAAAAA==.',He='Hera:BAAALAAFFAIIBAAAAA==.',La='Lafee:BAAALAAECgQIBAAAAA==.',Lu='Luciferss:BAAALAAFFAIIAgAAAA==.Luckyu:BAAALAAECgQIBAAAAA==.',Ma='Maievlol:BAABLAAFFH8GAAIBAAIIjQm6YwA8AAABAAIIjQm6YwA8AAAAAA==.',Mo='Mofei:BAAALAADCgEIAQAAAA==.',Or='Orangehwang:BAABLAAFFH8GAAICAAIIxBIMmABBAAACAAIIxBIMmABBAAAAAA==.',Pa='Pandoralol:BAABLAAFFH8GAAIDAAIIARiOWwBkAAADAAIIARiOWwBkAAAAAA==.',Pe='Persialol:BAAALAAFFAIIBAAAAA==.',Ph='Phantasos:BAACLAAFFH8KAAMEAAIIThSDGQA9AAAFAAII+gOsYQB3AAAEAAIIThSDGQA9AAAsAAQKfx0AAwQABwjuGWEtAMkBAAQABwjuGWEtAMkBAAUAAwjNECfSAL4AAAAA.',Ry='Rye:BAAALAAECgYICAAAAA==.',Si='Silverdagger:BAAALAAECgUIBQAAAA==.',Sk='Skirmisher:BAACLAAFFH8YAAICAAYI1RgkNABrAQACAAYI1RgkNABrAQAsAAQKfx0AAgIACAiMHxkvAP8BAAIACAiMHxkvAP8BAAAA.',Sw='Swallowyy:BAAALAAFFAIIBAAAAA==.',Ve='Vermouth:BAAALAAECgYICwAAAA==.',['一头']='一头大黑牛:BAAALAADCgYIBgAAAA==.',['三重']='三重恐惧:BAAALAADCgMIAwAAAA==.',['上五']='上五楼的快活:BAAALAAECgQIBwAAAA==.',['丰川']='丰川祥子:BAAALAAECgYIBgABLAAFFAUICwACAJoZAA==.',['临圣']='临圣:BAAALAAECgEIAQAAAA==.',['五彩']='五彩人生:BAAALAADCgYIBgAAAA==.',['亲卿']='亲卿倾心:BAAALAAECgMIAwAAAA==.',['你有']='你有点香:BAAALAAECggIEAAAAA==.',['你来']='你来打我啊:BAAALAAECgEIAQAAAA==.',['你迟']='你迟来的爱:BAABLAAFFH8PAAMGAAYIlAdxLgASAQAGAAYIlAdxLgASAQAHAAEIOwmiIwAyAAAAAA==.',['典狱']='典狱长卡琳:BAAALAAECgQIBgAAAA==.',['加尔']='加尔的长发:BAACLAAFFH8gAAIIAAYIDRYuEQBhAQAIAAYIDRYuEQBhAQAsAAQKfxgAAggABwiIGjg1AOYBAAgABwiIGjg1AOYBAAAA.',['十字']='十字街骑士:BAAALAADCgEIAQAAAA==.',['卡妙']='卡妙:BAABLAAFFH8KAAIJAAIIPAJ6GwAaAAAJAAIIPAJ6GwAaAAAAAA==.',['卡尼']='卡尼:BAAALAAECgYICgAAAA==.',['叁城']='叁城味火锅:BAAALAAECgIIAgAAAA==.',['叁成']='叁成味火锅:BAACLAAFFH8RAAIDAAUIZA6QLQD+AAADAAUIZA6QLQD+AAAsAAQKfxcAAgMABwitEvWIAG0BAAMABwitEvWIAG0BAAAA.',['古德']='古德猫宁:BAAALAAECgEIAQAAAA==.',['叶知']='叶知秋:BAAALAAECggIDwAAAA==.',['周打']='周打爆:BAABLAAFFH8GAAIKAAIIfBJ+XACaAAAKAAIIfBJ+XACaAAAAAA==.',['哈雅']='哈雅:BAABLAAFFH8PAAILAAUI4wizDQADAQALAAUI4wizDQADAQABLAAFFAYIGAACANUYAA==.',['嘶吼']='嘶吼:BAAALAAECggICAAAAA==.',['地质']='地质狼老三:BAAALAADCgcIBwAAAA==.',['埃尔']='埃尔路德:BAAALAAECggIBQABLAAFFAgIAgAMAAAAAA==.',['堕落']='堕落为神:BAAALAAECgYIBgAAAA==.',['塞雷']='塞雷尼卡:BAAALAAECgEIAQAAAA==.',['墜落']='墜落之羽:BAAALAAECgYICQAAAA==.',['大吉']='大吉岭茶:BAACLAAFFH86AAMNAAgIMiZdAAAgAwANAAgIMiZdAAAgAwADAAEInQWacwA7AAAsAAQKfx8AAg0ACAhhJRIHAFUDAA0ACAhhJRIHAFUDAAAA.',['大威']='大威白白:BAAALAAECgMIAwAAAA==.',['大蛮']='大蛮:BAACLAAFFH8IAAIOAAIIkxxUFABOAAAOAAIIkxxUFABOAAAsAAQKfxoAAw4ABgijGkATAH8BAA4ABgijGkATAH8BAAsAAQjpAdVaABcAAAAA.',['天涯']='天涯晚风:BAAALAAECgYICwAAAA==.',['奔跑']='奔跑的小猪:BAAALAAECgYIDAAAAA==.',['妹妹']='妹妹:BAAALAAFFAMIBAABLAAFFAUICwACAJoZAA==.',['威武']='威武的大元宝:BAAALAAECgYICQAAAA==.',['子瑜']='子瑜:BAAALAAFFAIIAwAAAA==.',['小小']='小小漾:BAABLAAFFH8GAAIPAAII/Av1UgBCAAAPAAII/Av1UgBCAAAAAA==.小小花花:BAABLAAECn8YAAIQAAYIrhMaCgBhAQAQAAYIrhMaCgBhAQAAAA==.小小菜青虫:BAABLAAFFH8KAAIGAAII4A74cgA8AAAGAAII4A74cgA8AAAAAA==.',['小爪']='小爪子:BAAALAADCggICAAAAA==.',['小莓']='小莓女大越越:BAABLAAFFH8GAAIQAAYIwgFtCAAzAAAQAAYIwgFtCAAzAAAAAA==.',['尾巴']='尾巴甩甩出橙:BAABLAAFFH8GAAMRAAIIeAlyKQBnAAARAAIIeAlyKQBnAAAGAAIIYgvybgA/AAAAAA==.',['巧克']='巧克力豆豆:BAAALAADCgYIBwAAAA==.',['帕德']='帕德伊德尔歌:BAAALAAFFAIIAgAAAA==.',['幻天']='幻天雨:BAAALAAECgYIBgAAAA==.',['幽冥']='幽冥之舞:BAAALAAECgYIEQAAAA==.',['幽灵']='幽灵特使:BAABLAAFFH8OAAIHAAUISRjBCAAvAQAHAAUISRjBCAAvAQABLAAFFAYIGgAFAEgcAA==.',['幽雅']='幽雅冰岚:BAAALAAECgYIBwAAAA==.',['广智']='广智救我:BAABLAAFFH8IAAISAAgI/wZqCgCfAQASAAgI/wZqCgCfAQAAAA==.',['彤曉']='彤曉:BAAALAADCgYIBgAAAA==.',['德德']='德德哋:BAAALAAECgYIBgAAAA==.',['恶魔']='恶魔终结者:BAABLAAECn8pAAIBAAcImArXXAAHAQABAAcImArXXAAHAQAAAA==.',['悲歌']='悲歌死士:BAAALAADCggICgAAAA==.',['惩戒']='惩戒魅魔:BAAALAAECgUIBQAAAA==.',['愿得']='愿得一人心:BAACLAAFFH8eAAIGAAUIXSQkEwCwAQAGAAUIXSQkEwCwAQAsAAQKfxwAAgYACAhxHz5WAEECAAYACAhxHz5WAEECAAAA.',['抓了']='抓了只大咕咕:BAABLAAFFH8OAAICAAIINBFnWwCPAAACAAIINBFnWwCPAAAAAA==.',['无名']='无名小龙人:BAAALAAECgYIBwAAAA==.',['无眠']='无眠之夜:BAABLAAFFH8GAAIFAAYIXgc/NwAWAQAFAAYIXgc/NwAWAQAAAA==.',['无间']='无间的杀戮:BAAALAAECgYIBgAAAA==.',['既黑']='既黑非白:BAAALAAECgUIBQAAAA==.',['星野']='星野诗羽:BAAALAAFFAIIAgAAAA==.',['暗月']='暗月星辰:BAABLAAFFH8NAAIBAAMIfB+7GQALAQABAAMIfB+7GQALAQAAAA==.暗月风华:BAACLAAFFH8IAAITAAMIVxWxDQD4AAATAAMIVxWxDQD4AAAsAAQKfxcAAxMABghrIHslAO8BABMABgiwHHslAO8BABQABQhUGyYmAGQBAAAA.',['暴走']='暴走丷豆子:BAABLAAFFH8FAAMDAAUIyxAvJQC8AAADAAMIzxIvJQC8AAANAAIIZwycMQCcAAAAAA==.',['最后']='最后一葉:BAAALAAFFAIIAgAAAA==.',['月下']='月下舞娘:BAAALAADCgQIBAAAAA==.',['朮士']='朮士:BAAALAADCgEIAQAAAA==.',['柳残']='柳残阳:BAAALAAECgYIBgAAAA==.',['梅露']='梅露露丽斯冫:BAAALAADCgMIAwAAAA==.梅露露利斯:BAAALAAECgMIAwAAAA==.梅露露莉丝灬:BAAALAAECgYIBgAAAA==.',['楚昭']='楚昭儿:BAAALAADCggICAAAAA==.',['樱空']='樱空桃:BAAALAAECgYIBgAAAA==.',['歸途']='歸途過愘:BAACLAAFFH8TAAIGAAUIng9xLAAgAQAGAAUIng9xLAAgAQAsAAQKfyYAAwYACAgrHO4dACcCAAYACAgrHO4dACcCAAcAAQigDHJEAC8AAAAA.',['氺晶']='氺晶留香:BAAALAAFFAIIAgAAAA==.',['氺甁']='氺甁座:BAABLAAFFH8SAAMRAAYI2gS4FgAiAQARAAYI2gS4FgAiAQAHAAIIcQKmIwAiAAAAAA==.',['洗脚']='洗脚兽:BAAALAAECgYIAwAAAA==.',['浪火']='浪火夺:BAAALAAECgcIDQAAAA==.',['涅磬']='涅磬苍穹:BAAALAAECgcIDQAAAA==.',['清风']='清风醉:BAAALAAECgMIAwAAAA==.',['温妮']='温妮莎班尼特:BAAALAAECgUIBwAAAA==.',['火影']='火影武神:BAAALAADCgQIBAAAAA==.',['炒肉']='炒肉先上浆:BAAALAAECgYIBgAAAA==.',['烈焰']='烈焰伤神:BAABLAAFFH8GAAICAAYI2RZaKgCKAQACAAYI2RZaKgCKAQAAAA==.',['無名']='無名之人:BAAALAAECgUIBQAAAA==.',['爆炸']='爆炸頭大德:BAABLAAFFH8GAAIVAAIIihLLRQBjAAAVAAIIihLLRQBjAAAAAA==.爆炸頭長老:BAABLAAFFH8GAAMLAAII2AY6GABdAAALAAII2AY6GABdAAASAAIIgQEAAAAAAAAAAA==.',['爱在']='爱在今朝:BAAALAAECgQIBAAAAA==.',['狂暴']='狂暴的小白:BAAALAADCggIEAAAAA==.',['狂秒']='狂秒:BAAALAADCggIDgAAAA==.',['猛龙']='猛龙咆哮:BAAALAADCgQIBAAAAA==.',['瓦利']='瓦利埃尔:BAAALAAECgYIBwAAAA==.',['瓦格']='瓦格哈尔:BAAALAADCgIIAgAAAA==.',['硬扎']='硬扎:BAAALAAECgIIAgAAAA==.',['神之']='神之乐:BAABLAAFFH8IAAIDAAIIagj+XABiAAADAAIIagj+XABiAAAAAA==.',['秀雪']='秀雪嫣:BAAALAAECgUIBwAAAA==.',['笑起']='笑起来很美:BAAALAAECgMIAwAAAA==.',['米悠']='米悠咪咕:BAAALAAECgYIBgAAAA==.',['绣秀']='绣秀:BAAALAAECgYICAAAAA==.',['绿叶']='绿叶:BAAALAAECgYIBgAAAA==.',['羊教']='羊教授之吻:BAAALAAECgYIBgAAAA==.',['翱族']='翱族之心:BAAALAAECgYIDAAAAA==.',['艾淮']='艾淮骑士:BAAALAADCggICAAAAA==.',['花谢']='花谢若相惜:BAAALAAECgQIBAAAAA==.',['莲影']='莲影:BAABLAAFFH8IAAMCAAIIEAqhqAA7AAACAAIIEAqhqAA7AAAWAAIIsAW1HAAkAAAAAA==.',['虚空']='虚空小蛮腰:BAAALAAECgYICAAAAA==.',['补充']='补充维生素:BAAALAAECgYIDQAAAA==.',['裂空']='裂空之息:BAAALAAECggICAAAAA==.',['角斗']='角斗士丶大郎:BAAALAAECgYICgAAAA==.角斗士丶阿宝:BAAALAAECgQIBAAAAA==.',['货拳']='货拳肉斯:BAAALAAECgQIBAAAAA==.',['踏踏']='踏踏:BAAALAADCgMIAwAAAA==.',['返朴']='返朴归真:BAAALAADCgEIAQAAAA==.',['酸酸']='酸酸甜甜的:BAAALAAECgYIBgAAAA==.',['钝刀']='钝刀割肉:BAAALAADCgcIBwAAAA==.',['铁剑']='铁剑灵魂:BAAALAADCggICAAAAA==.',['银月']='银月下:BAAALAADCgEIAQAAAA==.',['铸之']='铸之魂:BAACLAAFFH8aAAIFAAYISBx1HQCjAQAFAAYISBx1HQCjAQAsAAQKfxoAAgUACAg7ILQQAC8CAAUACAg7ILQQAC8CAAAA.',['阳谷']='阳谷坞老干部:BAAALAAECgYICQAAAA==.',['雀圣']='雀圣:BAACLAAFFH8IAAMCAAMIOwpQgwBPAAACAAMIOwpQgwBPAAAWAAIIeAWOHQALAAAsAAQKfxoAAwIABwgeHA86AN0BAAIABwgCGA86AN0BABYABwgiFok4ANgBAAAA.',['雨之']='雨之昊天:BAACLAAFFH8JAAIGAAYIZQTOMgDsAAAGAAYIZQTOMgDsAAAsAAQKfyoAAgYACAjxEsdEAI0BAAYACAjxEsdEAI0BAAAA.',['霓虹']='霓虹恶魔:BAAALAAECggICQAAAA==.',['靓仔']='靓仔:BAAALAADCgYIBgAAAA==.',['面对']='面对圣光吧:BAAALAAFFAIIBAAAAA==.',['风之']='风之力:BAABLAAFFH8OAAICAAUILxESTwARAQACAAUILxESTwARAQAAAA==.',['风霜']='风霜剑晓:BAAALAAECgQIBAAAAA==.',['鬼爪']='鬼爪子:BAAALAADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end