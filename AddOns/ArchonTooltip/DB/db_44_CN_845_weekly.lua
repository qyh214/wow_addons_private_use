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
 local lookup = {'DemonHunter-Vengeance','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Rogue-Assassination','Rogue-Subtlety','Mage-Arcane','Shaman-Elemental','Shaman-Restoration','Paladin-Retribution','Warlock-Demonology','Warrior-Fury','Priest-Holy','Priest-Shadow','Warrior-Protection','Druid-Balance','Unknown-Unknown','Rogue-Outlaw','Paladin-Protection','Mage-Frost','Paladin-Holy','DeathKnight-Frost','DeathKnight-Blood','Druid-Feral','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','DeathKnight-Unholy',}; local provider = {region='CN',realm='迦玛兰',name='CN',type='weekly',zone=44,date='2025-12-08',data={Ai='Aily:BAAALAAECgUIBQAAAA==.Aiyibao:BAAALAAFFAIIAwAAAA==.',Ak='Akiyama:BAAALAAECgYIEAAAAA==.',Av='Avis:BAAALAAECgUIBQAAAA==.',Dh='Dh:BAABLAAECn8UAAMBAAgIzhDEDQB0AQABAAgIzhDEDQB0AQACAAIIrwKnUAE+AAAAAA==.',Fa='Fayewong:BAAALAAECgYICwAAAA==.',Li='Lilbaby:BAAALAADCggICAAAAA==.',Lr='Lr:BAACLAAFFH8KAAIDAAUIXA5vXADYAAADAAUIXA5vXADYAAAsAAQKfxgAAwMABghjGxKBAN0BAAMABghjGxKBAN0BAAQABggeD+VpAB4BAAAA.',Mi='Miao:BAAALAAECgIIAgAAAA==.',No='Nogamenolife:BAABLAAFFH8GAAIFAAIIlxByagA2AAAFAAIIlxByagA2AAAAAA==.',Ov='Overdark:BAAALAADCgIIAgAAAA==.',Ph='Phim:BAAALAAECgYIBgAAAA==.',Pl='Playerczbgns:BAAALAAECgYIBgAAAA==.',Ri='Rivering:BAAALAAECgYICQAAAA==.',Su='Sunnimabio:BAAALAAFFAEIAQAAAA==.Superhero:BAAALAAECggICAAAAA==.',Ti='Tirisfal:BAAALAADCgYIBwAAAA==.',Un='Unholygigach:BAAALAAFFAIIAwAAAA==.',Vi='Vimutti:BAAALAAFFAUIAgAAAA==.',Wo='Wongfaye:BAAALAAECgYIBgAAAA==.',Ze='Zeppelin:BAAALAAECgUIBQAAAA==.',['一四']='一四七澫:BAACLAAFFH8GAAIGAAUITwZQFACjAAAGAAUITwZQFACjAAAsAAQKfxkAAwYACAghGQkIAPMBAAYACAghGQkIAPMBAAcAAgiqDzVGAGwAAAAA.',['三六']='三六九澫:BAAALAAECgYICAAAAA==.',['丑姑']='丑姑娘:BAAALAAECgYIBwAAAA==.',['两岸']='两岸统一:BAABLAAFFH8IAAIIAAIIjiPIMwC6AAAIAAIIjiPIMwC6AAAAAA==.',['丨晴']='丨晴天丶霹雳:BAAALAAFFAIIAgAAAA==.',['丨电']='丨电闪丶雷鸣:BAABLAAFFH8YAAIJAAUIvhWqIQA3AQAJAAUIvhWqIQA3AQAAAA==.',['乌鲁']='乌鲁鲁:BAABLAAFFH8NAAIKAAUIYBcQDAB+AQAKAAUIYBcQDAB+AQAAAA==.',['乐猫']='乐猫儿:BAAALAADCggICAAAAA==.',['乾坤']='乾坤无极:BAAALAADCgUIBQAAAA==.',['二郎']='二郎险胜真君:BAAALAADCggICAAAAA==.',['二阶']='二阶堂白丸:BAAALAAECgQIBAAAAA==.',['今夜']='今夜不会醉:BAABLAAFFH8iAAIKAAYIMwwEJgAzAQAKAAYIMwwEJgAzAQAAAA==.',['他喵']='他喵熊的力量:BAAALAAECgYIBwAAAA==.',['伊泽']='伊泽瑞尔:BAAALAAECgYIBgAAAA==.',['伊莉']='伊莉萨娜:BAABLAAFFH8GAAIBAAYIsQAHDwBUAAABAAYIsQAHDwBUAAAAAA==.',['倾天']='倾天圣威:BAABLAAFFH8HAAILAAMIfQwWTABpAAALAAMIfQwWTABpAAAAAA==.',['健哥']='健哥仔:BAAALAAECgYIDAAAAA==.',['冯宝']='冯宝宝:BAAALAADCgcICwAAAA==.',['卡卡']='卡卡:BAACLAAFFH8OAAMMAAQIQRdYBwCyAAAMAAMIax5YBwCyAAAFAAIIcQILcAAvAAAsAAQKfxYAAgwABgiKIM8WAEICAAwABgiKIM8WAEICAAAA.卡卡队长:BAABLAAFFH8QAAINAAYIDg8/IQBkAQANAAYIDg8/IQBkAQAAAA==.',['卷毛']='卷毛小泡面:BAAALAAFFAIIBAAAAA==.',['口与']='口与瓜:BAACLAAFFH8MAAMOAAUIsx8VBgD6AQAOAAUIsx8VBgD6AQAPAAEIlAK7LwA1AAAsAAQKfx8AAw4ACAhhIhMMAAcDAA4ACAhhIhMMAAcDAA8AAQjeHUCUAFIAAAAA.',['古天']='古天乐:BAABLAAFFH8MAAMQAAYIEg56FwD1AAAQAAYINwh6FwD1AAANAAMInA+NTQBHAAAAAA==.',['叨刀']='叨刀:BAACLAAFFH8OAAILAAII+SN5IgDHAAALAAII+SN5IgDHAAAsAAQKfykAAgsACAhyIkIfAPUCAAsACAhyIkIfAPUCAAAA.',['咕咕']='咕咕卡卡:BAABLAAFFH8IAAIRAAYIMQYNHQDqAAARAAYIMQYNHQDqAAAAAA==.',['咕德']='咕德猫宁:BAAALAAFFAIIAgAAAA==.',['哒滴']='哒滴滴哒:BAAALAAECgMIAwAAAA==.',['唇香']='唇香绕齿柔丶:BAAALAAECgMIAwAAAA==.',['嘟嘟']='嘟嘟秒黑市:BAAALAAFFAMIAwABLAAFFAgIAQASAAAAAA==.',['噗嗤']='噗嗤:BAAALAADCggICAAAAA==.',['圣光']='圣光钢管舞:BAAALAAECgYIBgAAAA==.',['壹发']='壹发入魂:BAAALAAECgMIAwAAAA==.',['夕立']='夕立丹:BAABLAAFFH8KAAMPAAYInBDbDwBpAQAPAAYInBDbDwBpAQAOAAIIShYEKQCYAAAAAA==.',['大榴']='大榴莲想喝酒:BAAALAAECgYIBgABLAAFFAYIKwAHAHwgAA==.大榴莲想滋人:BAAALAAECgUIBQABLAAFFAYIKwAHAHwgAA==.大榴莲想背刺:BAACLAAFFH8rAAQHAAYIfCBTCQAHAQAGAAQI4RuGDwARAQAHAAUIcR5TCQAHAQATAAIIcwcKBgCEAAAsAAQKfx8ABAcABwisHXoSABsCAAcABwh1HXoSABsCAAYABAiUGD4YAPoAABMAAwj3FeYXAKkAAAAA.',['大爷']='大爷:BAAALAADCgMIAwAAAA==.',['天乐']='天乐:BAABLAAFFH8VAAMLAAYInxHxKwAnAQALAAUIHxDxKwAnAQAUAAQIMg42DQC3AAAAAA==.',['天堂']='天堂圣骑:BAAALAAECgYIDgAAAA==.',['天才']='天才大坑:BAAALAAFFAIIBAAAAA==.',['天蓝']='天蓝卡卡:BAABLAAFFH8ZAAIVAAYIHB5GAwC0AQAVAAYIHB5GAwC0AQAAAA==.',['奈何']='奈何与天齐:BAABLAAECn8dAAICAAYIOh17MQCUAQACAAYIOh17MQCUAQAAAA==.',['好苗']='好苗苗:BAAALAAFFAQIBAAAAA==.',['如沐']='如沐欣荣:BAAALAADCgYIBgAAAA==.',['娴瞑']='娴瞑游龙:BAAALAADCggIDwAAAA==.',['季末']='季末云微笑:BAAALAADCgEIAQAAAA==.',['孤鹜']='孤鹜:BAACLAAFFH8SAAIKAAYI+QtQDQBqAQAKAAYI+QtQDQBqAQAsAAQKfx8AAgoACAhaIyYPAPACAAoACAhaIyYPAPACAAAA.',['学石']='学石油毁一生:BAAALAAECgUIBgAAAA==.',['射狩']='射狩:BAAALAADCgYIBgAAAA==.',['小浪']='小浪漫师:BAAALAAECgYICgAAAA==.',['小清']='小清新小纯洁:BAAALAAFFAIIAgAAAA==.',['小罗']='小罗曼司:BAABLAAECn8aAAQUAAYILSRFCQARAgAUAAYILSRFCQARAgAWAAQIMQ50MgC2AAALAAIIBRh5uQCMAAAAAA==.',['小诺']='小诺:BAAALAAECggICAAAAA==.',['师兄']='师兄断水流:BAAALAADCgcICgAAAA==.',['幽灵']='幽灵人间:BAAALAADCgUIBQAAAA==.',['库附']='库附魔:BAACLAAFFH8xAAIOAAcIvRvnBgDqAQAOAAcIvRvnBgDqAQAsAAQKfzMAAw4ACAgbHYgaAJsCAA4ACAgbHYgaAJsCAA8ABQj1DfpAAGsAAAAA.',['张江']='张江王大陆:BAAALAAECgYICAAAAA==.',['影墨']='影墨:BAAALAAFFAIIBAAAAA==.',['待一']='待一故人归:BAAALAAECgYIBgAAAA==.',['德玛']='德玛西亚:BAAALAAECgYIDAAAAA==.',['忄丨']='忄丨忄:BAABLAAFFH8KAAMXAAgI0BDRCgAGAgAXAAgI0BDRCgAGAgAYAAIIOAywHAAvAAAAAA==.',['恶灵']='恶灵之缚:BAABLAAECn8ZAAIDAAYIvRP30gBnAQADAAYIvRP30gBnAQAAAA==.',['愛喝']='愛喝啤酒的咪:BAAALAAECgUIBQAAAA==.愛喝睥酒的喵:BAAALAAECgYIBgAAAA==.',['我就']='我就看看:BAAALAAECgMIAwAAAA==.',['我想']='我想唱首歌:BAAALAAECgMIAwAAAA==.',['我有']='我有个大宝贝:BAAALAAECgEIAQAAAA==.',['我随']='我随便看看:BAAALAAECgIIAgAAAA==.',['拉克']='拉克絲丶:BAACLAAFFH8GAAIWAAII+QYuJAB7AAAWAAII+QYuJAB7AAAsAAQKfyUAAhYABggrHSAnAOQBABYABggrHSAnAOQBAAAA.',['摸鱼']='摸鱼北:BAAALAADCgEIAQAAAA==.',['撩婶']='撩婶大汉:BAAALAAECgYIBwAAAA==.',['故事']='故事的小黄花:BAAALAAECgYIDwAAAA==.',['无敌']='无敌大坑:BAABLAAFFH8GAAIXAAIIwBMjXgCZAAAXAAIIwBMjXgCZAAAAAA==.',['明神']='明神:BAAALAAECgIIAgAAAA==.',['星臣']='星臣罪厄:BAAALAADCggICAAAAA==.',['晴舞']='晴舞青猫:BAACLAAFFH8OAAIFAAMIIxINTgCEAAAFAAMIIxINTgCEAAAsAAQKfxYAAgUACAjTFhYkANABAAUACAjTFhYkANABAAAA.',['木木']='木木夕雨霞:BAAALAAECggIDgAAAA==.',['来个']='来个盾呗:BAAALAAECgMIAwAAAA==.',['来条']='来条小鱼干:BAAALAADCggIDwAAAA==.',['柽子']='柽子:BAAALAAECgYIEQAAAA==.',['标哥']='标哥:BAAALAAFFAIIAgAAAA==.标哥的表哥:BAAALAAECggIDgAAAA==.',['树忄']='树忄爿:BAAALAAFFAIIAgAAAA==.',['梦破']='梦破:BAABLAAFFH8GAAIPAAIIiQouKQBkAAAPAAIIiQouKQBkAAAAAA==.',['椒盐']='椒盐锅巴:BAAALAAECgYIBgAAAA==.',['死了']='死了没埋:BAAALAAECgYIBgAAAA==.',['毅格']='毅格:BAACLAAFFH8uAAMEAAgIsBvVAwD+AQADAAgIuxcKDgAbAgAEAAYIyB3VAwD+AQAsAAQKfy0AAwQACAiqJJsIACIDAAQACAh7JJsIACIDAAMAAggsJG/XAM4AAAAA.',['毛死']='毛死阿鲁昂:BAAALAAECgUIBQAAAA==.',['法丝']='法丝:BAAALAAECgYICQAAAA==.',['法克']='法克劳斯特:BAACLAAFFH8HAAIZAAIIiBngCgCmAAAZAAIIiBngCgCmAAAsAAQKfyIAAhkABwhkGc4LAIIBABkABwhkGc4LAIIBAAAA.',['洛丹']='洛丹伦的风:BAAALAADCggICAAAAA==.',['活力']='活力咕串:BAAALAAFFAIIAgAAAA==.',['淝唣']='淝唣侠:BAAALAADCggIEAAAAA==.',['淡蓝']='淡蓝卡卡:BAABLAAFFH8UAAIVAAUIuRxJBgBSAQAVAAUIuRxJBgBSAQAAAA==.',['深蓝']='深蓝彼岸:BAACLAAFFH8JAAIDAAMIkxXDbwCEAAADAAMIkxXDbwCEAAAsAAQKfzIAAgMACAhaI1EKAM4CAAMACAhaI1EKAM4CAAAA.',['湮灭']='湮灭法至尊:BAAALAAFFAIIAgAAAA==.湮灭魔至尊:BAAALAAECgYICgAAAA==.',['源木']='源木叁:BAAALAAECgQIBAAAAA==.',['溱白']='溱白丨:BAAALAAECgYIBgAAAA==.',['溱黑']='溱黑丶:BAABLAAFFH8NAAIDAAgITxdDDgAZAgADAAgITxdDDgAZAgAAAA==.',['激流']='激流洗脚水:BAABLAAFFH8IAAIKAAIItyWNHADYAAAKAAIItyWNHADYAAAAAA==.',['灯丶']='灯丶:BAAALAAFFAIIBAAAAA==.',['灯神']='灯神:BAAALAADCgIIAgAAAA==.',['焚影']='焚影:BAAALAAFFAIIAgAAAA==.',['熵陨']='熵陨弦歌丶:BAABLAAFFH8GAAIEAAYI3B7SBACPAQAEAAYI3B7SBACPAQAAAA==.',['爱上']='爱上咖啡涩:BAAALAAFFAIIAgAAAA==.',['爱意']='爱意随钟起:BAAALAAFFAIIAgAAAA==.',['爱的']='爱的浪漫史:BAAALAAECgMIBAAAAA==.爱的罗曼司:BAAALAAECgUIBQAAAA==.爱的罗曼式:BAAALAAECgYIDQAAAA==.爱的罗曼斯:BAAALAAECgYIBgAAAA==.爱的罗猫史:BAABLAAECn8WAAQaAAYIgxayEQCKAQAaAAYIgxayEQCKAQAbAAYIXBfvDgBWAQAcAAMIdRdPJADVAAAAAA==.',['猫猫']='猫猫小可爱:BAAALAADCgEIAQAAAA==.',['玛里']='玛里苟斯:BAACLAAFFH8MAAQdAAIIjxgsFwCWAAAdAAIIjxgsFwCWAAAeAAIIpRLrGAB8AAAfAAEI0BbVEgAAAAAsAAQKfxwABB4ABwhmIXQHABoCAB4ABgjTIHQHABoCAB0ABghLHwwVAFsBAB8AAgiMHtMLAKUAAAAA.',['玩票']='玩票:BAAALAADCgYIBgAAAA==.',['玲琳']='玲琳小骑:BAABLAAFFH8GAAMUAAIIug0bHgAvAAAUAAIIug0bHgAvAAALAAIIFwE1hgAVAAAAAA==.',['生存']='生存猎:BAAALAAECgYICwAAAA==.',['疾风']='疾风者狂爆:BAABLAAFFH8FAAIDAAUIzQ4HFQB3AQADAAUIzQ4HFQB3AQAAAA==.',['破日']='破日狂魔:BAAALAAECggICAABLAAFFAgICAAVAF4GAA==.',['碎雨']='碎雨:BAAALAAECgYIBgAAAA==.',['神秘']='神秘:BAAALAAECgIIAgAAAA==.',['祭奠']='祭奠逝去滴:BAAALAAECgEIAQAAAA==.',['秋晓']='秋晓:BAABLAAFFH8NAAINAAUIPBBVJwA3AQANAAUIPBBVJwA3AQAAAA==.',['秋晚']='秋晚枫:BAAALAAFFAIIBAAAAA==.',['箭影']='箭影:BAAALAADCgUIBQAAAA==.',['紫色']='紫色卡卡:BAAALAAFFAIIAgAAAA==.',['紫蕾']='紫蕾:BAABLAAFFH8kAAIXAAYI2hqfHwC4AQAXAAYI2hqfHwC4AQAAAA==.',['繁星']='繁星蚀月:BAAALAADCggIHAAAAA==.',['红色']='红色卡卡:BAABLAAFFH8IAAIXAAYIIwT9SQARAQAXAAYIIwT9SQARAQAAAA==.',['绿绿']='绿绿的交际花:BAABLAAFFH8FAAIEAAUIHRFrCgD7AAAEAAUIHRFrCgD7AAAAAA==.',['美超']='美超風:BAAALAAECgYIBgAAAA==.',['聖丶']='聖丶法天神霊:BAABLAAFFH8IAAIKAAIIJAgubABPAAAKAAIIJAgubABPAAABLAAFFAgIAgASAAAAAA==.',['聖靈']='聖靈一狐:BAAALAAECgYIBgAAAA==.',['胸藏']='胸藏三聚氰:BAAALAAFFAIIAgAAAA==.',['臭臭']='臭臭的丶:BAABLAAFFH8cAAMVAAYI8Q/pCAD+AAAIAAYI8Q9TJgB9AQAVAAUIIQ3pCAD+AAAAAA==.',['花花']='花花灼灼:BAAALAAFFAIIAgAAAA==.',['苍天']='苍天已死:BAAALAAECgMIAwAAAA==.',['苏察']='苏察哈尔灿:BAAALAAFFAIIAgAAAA==.',['若无']='若无其事:BAAALAAECgYIBwAAAA==.',['莫菲']='莫菲奥:BAAALAAECgIIAgAAAA==.',['菠萝']='菠萝大神:BAABLAAFFH8wAAIFAAYIViBfIACcAQAFAAYIViBfIACcAQAAAA==.',['萌面']='萌面宝友:BAAALAAECgYIBgAAAA==.',['蓝夏']='蓝夏千寻丶猎:BAAALAAECgYIBgAAAA==.',['蓝色']='蓝色卡卡:BAABLAAFFH8IAAMJAAYIqwWWJQAdAQAJAAYIqwWWJQAdAQAKAAIIwAK7dQBCAAAAAA==.',['虚荣']='虚荣灬:BAAALAAECgYIDAAAAA==.',['血染']='血染弓弦:BAAALAAFFAMIAwAAAA==.',['血色']='血色伯爵:BAAALAAECgIIAgAAAA==.',['親獣']='親獣:BAABLAAFFH8GAAMOAAQIKwqgHADRAAAOAAMIFgygHADRAAAPAAMIbQIMLQBFAAAAAA==.',['话木']='话木兰:BAAALAADCgYIBgAAAA==.',['说相']='说相声的:BAAALAAECgQIAwAAAA==.',['谢逊']='谢逊:BAAALAAECgYIDAAAAA==.',['谷稻']='谷稻:BAAALAAECgYIBgAAAA==.',['贾家']='贾家的小顽童:BAAALAADCgEIAQAAAA==.',['遗忘']='遗忘的圣骑:BAABLAAECn8dAAILAAcIvhwRKgDsAQALAAcIvhwRKgDsAQAAAA==.',['那年']='那年物是人非:BAAALAAECggIEwAAAA==.',['释星']='释星魂:BAACLAAFFH8GAAILAAIIERn1KgCzAAALAAIIERn1KgCzAAAsAAQKfyEAAgsABgj5Im4lAAICAAsABgj5Im4lAAICAAAA.',['阿宝']='阿宝同学:BAABLAAFFH8JAAIVAAII7hhaEACOAAAVAAII7hhaEACOAAAAAA==.',['阿萨']='阿萨斯砍:BAACLAAFFH8OAAQgAAII5B/sGABeAAAgAAEIVB3sGABeAAAXAAEIdSJ/lwBdAAAYAAIIFAN2FgBWAAAsAAQKfyQABBcACAiUIOZBAH0BABcABgiNIeZBAH0BABgABwhFEXUnAEIBACAAAwgjHTZCAMsAAAAA.',['陈年']='陈年丨:BAAALAAFFAIIAgAAAA==.',['陈灬']='陈灬风暴烈酒:BAAALAADCgYIBgAAAA==.',['随風']='随風之葉:BAAALAADCgYIBgAAAA==.',['青色']='青色卡卡:BAABLAAFFH8LAAIDAAMI1RibaQCTAAADAAMI1RibaQCTAAAAAA==.',['風寒']='風寒:BAACLAAFFH8MAAIDAAIIEBoCPwCoAAADAAIIEBoCPwCoAAAsAAQKfxoAAgMABgj1HoxlABACAAMABgj1HoxlABACAAAA.',['风火']='风火雷电雨:BAABLAAFFH8IAAIKAAgIxArZGQCPAQAKAAgIxArZGQCPAQAAAA==.',['鲦鱼']='鲦鱼:BAAALAAECgQIBAAAAA==.',['鹃丨']='鹃丨寳唄:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end