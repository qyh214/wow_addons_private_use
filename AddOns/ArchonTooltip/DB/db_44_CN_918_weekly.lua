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
 local lookup = {'Evoker-Devastation','Priest-Shadow','Priest-Holy','DeathKnight-Blood','DeathKnight-Frost','Unknown-Unknown','Hunter-BeastMastery','Mage-Arcane','Paladin-Retribution','Warlock-Destruction','DeathKnight-Unholy','Warlock-Demonology','Mage-Frost','Evoker-Augmentation','Paladin-Holy','Shaman-Restoration','Warrior-Fury','Warrior-Arms','Warrior-Protection','DemonHunter-Havoc','DemonHunter-Vengeance','Paladin-Protection','Druid-Balance','Hunter-Marksmanship','Druid-Restoration','Shaman-Elemental','Monk-Brewmaster','Monk-Mistweaver','Rogue-Assassination','Mage-Fire','Evoker-Preservation','Druid-Feral',}; local provider = {region='CN',realm='兰娜瑟尔',name='CN',type='weekly',zone=44,date='2025-12-07',data={Ak='Akiepwp:BAAALAAECgYIBgAAAA==.',Al='Alissa:BAAALAAECgYIBgAAAA==.',Ar='Arwen:BAAALAAECgMIAwAAAA==.',Au='Augenstern:BAAALAAFFAIIAgAAAA==.',Av='Avicii:BAAALAAECgIIAgAAAA==.',Aw='Awl:BAAALAAECgYIBgAAAA==.',Br='Brand:BAAALAADCgUIBQAAAA==.',Ca='Canelevoker:BAABLAAFFH8FAAIBAAIIvBf+FwCTAAABAAIIvBf+FwCTAAAAAA==.Canelpriest:BAAALAAFFAIIBAAAAA==.Caraxes:BAABLAAFFH8MAAMCAAYI8A1PGQDsAAACAAMI+xdPGQDsAAADAAMIrhW1KwDKAAAAAA==.',Co='Conpanna:BAACLAAFFH8KAAIEAAIIyA8WGgA5AAAEAAIIyA8WGgA5AAAsAAQKfyEAAwQACAjtFkQUABQCAAQACAjcFUQUABQCAAUABwgLDuXhAGwBAAAA.',Du='Duramut:BAAALAAFFAQIBAAAAA==.',Ed='Edmundcz:BAAALAAECggICAABLAAFFAEIAQAGAAAAAA==.',Fg='Fghaq:BAACLAAFFH8hAAIHAAYIkBemLACFAQAHAAYIkBemLACFAQAsAAQKfxgAAgcABgj3GZd9AE0BAAcABgj3GZd9AE0BAAEsAAUUBwhEAAMArCAA.',Ga='Garmen:BAABLAAFFH8GAAIIAAIIMh1gOwClAAAIAAIIMh1gOwClAAABLAAFFAIIBgAJAIMhAA==.Gauss:BAABLAAFFH8SAAIKAAgIwhZaDQAyAgAKAAgIwhZaDQAyAgAAAA==.',He='Heath:BAABLAAFFH8RAAMEAAII5xfQDgCQAAAEAAII4xXQDgCQAAALAAEIkBlhGAAAAAABLAAFFAMIEQAMAHAhAA==.',Hi='Hideon:BAACLAAFFH8kAAMNAAUIdiPwAwCbAQANAAUIdiPwAwCbAQAIAAUIWxY3MgA7AQAsAAQKfzoAAw0ABwgtJi8SAJECAA0ABwgtJi8SAJECAAgABgiZIOBgAOIBAAAA.',Hy='Hydronxh:BAAALAAECgEIAQAAAA==.',Im='Imonical:BAABLAAECn8aAAIDAAgIvQt/WQBzAQADAAgIvQt/WQBzAQAAAA==.',Ka='Karmen:BAABLAAFFH8GAAIJAAIIgyFTJQDAAAAJAAIIgyFTJQDAAAAAAA==.Katrina:BAAALAAECgUICQAAAA==.',Li='Lipenny:BAACLAAFFH8RAAIMAAMIcCEHBwC6AAAMAAMIcCEHBwC6AAAsAAQKfywAAwwACAiyINEGAP0CAAwACAiyINEGAP0CAAoABgi5EDNTAAgBAAAA.Littlesmart:BAAALAAFFAIIBAAAAA==.',Ma='Maldivâ:BAABLAAFFH8GAAIKAAYIHgcgOgAkAQAKAAYIHgcgOgAkAQAAAA==.Mandeling:BAAALAAFFAMIAwAAAA==.',Mi='Mikey:BAAALAAFFAIIAwAAAA==.Missanna:BAABLAAFFH8QAAMDAAYIjB9oDwBLAQADAAQI/h1oDwBLAQACAAMIjhrbGAD0AAAAAA==.Misswarlock:BAAALAADCgEIAQAAAA==.',Ml='Mlxg:BAACLAAFFH8aAAIJAAYIyR1tEADEAQAJAAYIyR1tEADEAQAsAAQKfxUAAgkABwgbJPkSAHgCAAkABwgbJPkSAHgCAAAA.',Mo='Monline:BAAALAAECgYIDAAAAA==.',Ms='Msterashened:BAAALAAFFAIIBAAAAA==.',Na='Nanako:BAABLAAFFH8JAAMBAAYIYSBpCgBuAQABAAQI8x1pCgBuAQAOAAIIPiXVCQDcAAAAAA==.',No='Notatall:BAAALAAECgYIDwAAAA==.',Oc='Ocgg:BAABLAAFFH8ZAAIPAAgInx6xAQDfAgAPAAgInx6xAQDfAgAAAA==.',On='Onana:BAAALAAECgYIBwAAAA==.',Si='Sisibiu:BAABLAAFFH8PAAIQAAYIYQ+RIgBMAQAQAAYIYQ+RIgBMAQAAAA==.',So='Soranokiseki:BAAALAAECggICQAAAA==.',Sp='Splendi:BAACLAAFFH8FAAMRAAII6QdyVgBAAAARAAII6QdyVgBAAAASAAEI0QTMBgAqAAAsAAQKfxUABBEACAgQDzVrALcBABEACAjiDTVrALcBABIAAwhBCY0rAJgAABMAAQhGEseUADwAAAAA.',Sr='Srxtry:BAAALAAECgcICgAAAA==.',Su='Supercat:BAAALAAECgEIAQAAAA==.',Ve='Vermithor:BAAALAAFFAIIAgAAAA==.',Vi='Vikram:BAABLAAFFH8GAAIKAAYIEhe/JgCAAQAKAAYIEhe/JgCAAQAAAA==.',Vo='Volee:BAABLAAFFH8MAAIHAAYIGxytKACTAQAHAAYIGxytKACTAQAAAA==.',We='Werdd:BAAALAAECgcIDQAAAA==.',Ya='Yachin:BAAALAAECgYIDgAAAA==.',Yu='Yume:BAABLAAFFH8JAAIHAAUIHxK5TAAdAQAHAAUIHxK5TAAdAQAAAA==.',['Öö']='Öö:BAAALAAECgYIDAAAAA==.',['一刀']='一刀两蛋:BAACLAAFFH8MAAIUAAQIqQ6oNQDbAAAUAAQIqQ6oNQDbAAAsAAQKfyMAAhQACAhtGpkaAAoCABQACAhtGpkaAAoCAAAA.',['一匹']='一匹温柔的狼:BAAALAAECgQIBgAAAA==.',['一宛']='一宛:BAABLAAECn8lAAMNAAgIURWkJAD9AQANAAgIURWkJAD9AQAIAAEIOwOADQEjAAAAAA==.',['一骑']='一骑绝尘:BAABLAAFFH8GAAIJAAII2BqNXwBHAAAJAAII2BqNXwBHAAAAAA==.',['三娘']='三娘家熊宠物:BAAALAAECgYIDAAAAA==.',['三月']='三月七:BAAALAAFFAQIBAABLAAFFAcIMAADAG4iAA==.',['三片']='三片大好:BAABLAAFFH8OAAIUAAII5R+/NQCiAAAUAAII5R+/NQCiAAAAAA==.',['三行']='三行情书:BAAALAAECgUICgAAAA==.',['东升']='东升陈奕迅:BAAALAAECgEIAQAAAA==.',['东方']='东方补败:BAAALAADCgQIBAAAAA==.',['丝滑']='丝滑淡奶:BAAALAAECgYIBgAAAA==.',['丨黑']='丨黑灬妞丨:BAAALAAECgYIBgAAAA==.',['丶伊']='丶伊利达雷:BAAALAAECggIDgAAAA==.',['丶夏']='丶夏进奶牧:BAAALAADCgYIBgAAAA==.',['丶斩']='丶斩:BAAALAAECgYIBgAAAA==.',['丶暮']='丶暮色珊瑚:BAAALAAFFAIIBAAAAA==.',['丶装']='丶装逼裤衩:BAAALAAECgEIAQAAAA==.',['丶閃']='丶閃閃惹人愛:BAAALAAECgIIAwAAAA==.',['乌拉']='乌拉丶乌拉:BAACLAAFFH8KAAIFAAII9gopjABAAAAFAAII9gopjABAAAAsAAQKfxQAAgUACAilGuJFAHECAAUACAilGuJFAHECAAAA.',['乔妮']='乔妮娜熊样:BAAALAADCgMIAwAAAA==.',['二楼']='二楼的神:BAAALAAECgEIAQAAAA==.',['二片']='二片大好:BAAALAAFFAIIAgAAAA==.',['于卿']='于卿:BAAALAAECgUICAAAAA==.',['五斤']='五斤:BAAALAAECgcIBwAAAA==.',['五道']='五道杠丶:BAAALAAECgYIDgAAAA==.',['井蛙']='井蛙不语天:BAAALAAECggICAAAAA==.',['亚洲']='亚洲苦力:BAABLAAFFH8VAAIKAAYI4yVHDQAzAgAKAAYI4yVHDQAzAgAAAA==.',['亚里']='亚里士多德:BAABLAAFFH8GAAIJAAYIhgjHLgAVAQAJAAYIhgjHLgAVAQAAAA==.亚里士多贼:BAAALAAFFAQIBAAAAA==.亚里多士猎:BAABLAAFFH8NAAIHAAYIBB05JACjAQAHAAYIBB05JACjAQAAAA==.',['人生']='人生都是死:BAABLAAECn8VAAIFAAgIehUwaQAjAgAFAAgIehUwaQAjAgAAAA==.',['从不']='从不躲圈:BAAALAAECgYIDAABLAAFFAIIBgAJAIMhAA==.',['付轩']='付轩豪是九腿:BAABLAAFFH8IAAIRAAYIdRtUEwDAAQARAAYIdRtUEwDAAQAAAA==.付轩豪是八腿:BAABLAAFFH8MAAIRAAYIhxBCHgB5AQARAAYIhxBCHgB5AQAAAA==.',['伊丽']='伊丽莎白:BAABLAAFFH8SAAMUAAYI+xD7HwCDAQAUAAYI+xD7HwCDAQAVAAEIMgEKHAASAAAAAA==.',['会当']='会当凌绝顶:BAAALAADCgMIAwAAAA==.',['伟伦']='伟伦术:BAAALAADCgYICAAAAA==.伟伦牧:BAAALAAECgQIBAAAAA==.',['佐伊']='佐伊:BAAALAAFFAIIAgAAAA==.',['你叉']='你叉叉:BAABLAAFFH8OAAIKAAYIfSDuFgDVAQAKAAYIfSDuFgDVAQAAAA==.',['你这']='你这是在逗我:BAAALAAECgcIDQAAAA==.',['佬王']='佬王:BAAALAAECgYIBgAAAA==.',['假摔']='假摔丶:BAAALAADCgYICAAAAA==.',['假死']='假死高手:BAAALAAFFAIIAgAAAA==.',['光芒']='光芒万丈:BAAALAAECgYIBgAAAA==.',['克莉']='克莉斯汀娜:BAAALAAECggIBQAAAA==.',['冰冰']='冰冰红茶:BAAALAAECgIIAgABLAAFFAMIEQAMAHAhAA==.',['冰茶']='冰茶:BAABLAAFFH8OAAMWAAIIMxOcFgB7AAAWAAIIFhGcFgB7AAAJAAIITg8zZgBDAAABLAAFFAMIEQAMAHAhAA==.',['冲钅']='冲钅就释放:BAAALAADCgYIBgABLAAFFAYILgAQALMhAA==.',['冽九']='冽九:BAAALAADCggICAABLAAFFAYIHAAEAA4fAA==.',['凌虚']='凌虚灬御空:BAABLAAFFH8hAAIHAAYIIRi3KgCMAQAHAAYIIRi3KgCMAQAAAA==.',['凛妖']='凛妖妖:BAABLAAFFH8IAAIEAAgIUhmYAwA5AgAEAAgIUhmYAwA5AgAAAA==.',['动茨']='动茨哒刺:BAAALAADCgMIAwAAAA==.',['勇敢']='勇敢牛牛:BAAALAAECgYIBgAAAA==.',['十万']='十万伏特:BAAALAAECgYIDAABLAAFFAYILgAQALMhAA==.',['南墙']='南墙:BAAALAAECgUIBQAAAA==.',['南山']='南山笠下:BAAALAADCgEIAQAAAA==.',['博灬']='博灬奕:BAAALAAECgcIEAAAAA==.',['双生']='双生鬼乄獠牙:BAAALAAFFAIIAgAAAA==.',['口水']='口水鸡:BAABLAAFFH8HAAIFAAIIoRoiTACkAAAFAAIIoRoiTACkAAAAAA==.',['叮珰']='叮珰法术:BAABLAAFFH8QAAIKAAYIbSFhBwBDAgAKAAYIbSFhBwBDAgAAAA==.',['可乐']='可乐儿:BAAALAAECgYIBgAAAA==.',['叶灬']='叶灬傾云:BAAALAAFFAIIBAAAAA==.',['吴小']='吴小妞:BAAALAAECggIEAAAAA==.',['呆瓜']='呆瓜:BAAALAAECgYICwAAAA==.',['周杰']='周杰伦:BAAALAADCgYIBgAAAA==.',['和妲']='和妲己玩耍吧:BAAALAAECgYIBgAAAA==.',['哇哒']='哇哒西蛙:BAAALAAECgIIAgAAAA==.',['哈儿']='哈儿娜:BAAALAAECgQIBwAAAA==.',['哈莉']='哈莉丶莉:BAACLAAFFH8GAAIFAAIIcyCbQwCuAAAFAAIIcyCbQwCuAAAsAAQKfxkAAgUABghvIUlYAEYCAAUABghvIUlYAEYCAAAA.',['哎唷']='哎唷丶好疼:BAAALAAECgUIBgAAAA==.',['唤月']='唤月:BAAALAAFFAIIAgAAAA==.',['喵喵']='喵喵晕碳啦:BAABLAAFFH8MAAIPAAYIeBHtEAB8AQAPAAYIeBHtEAB8AQAAAA==.',['嘛咪']='嘛咪嘛咪哄:BAAALAAECgYIBgAAAA==.',['嘛嘎']='嘛嘎:BAAALAAFFAIIBAAAAA==.',['团子']='团子粥:BAAALAADCgIIAgAAAA==.',['土灵']='土灵伟圣:BAAALAAECgUIBQAAAA==.',['圣光']='圣光肘子:BAAALAAFFAIIBAAAAA==.',['圣诞']='圣诞老人:BAAALAAECgMIAwAAAA==.',['坏稳']='坏稳文:BAAALAAFFAIIBAAAAA==.',['埃列']='埃列什基伽勒:BAAALAADCgYIBgAAAA==.',['埃辛']='埃辛诺:BAAALAAECgYIBgAAAA==.',['基本']='基本忧郁:BAAALAAECgYICwAAAA==.',['墟里']='墟里烟丶:BAAALAADCgQIBAAAAA==.',['夏末']='夏末千寻:BAACLAAFFH8fAAIXAAcICxlMCADhAQAXAAcICxlMCADhAQAsAAQKfxUAAhcACAjNILgPAAoCABcACAjNILgPAAoCAAAA.夏末千雨:BAAALAAFFAIIAgAAAA==.',['夜羽']='夜羽:BAAALAAFFAIIBAABLAAFFAUIFgAHAGIXAA==.',['大人']='大人中:BAABLAAFFH8qAAMHAAcI4iFzCABeAgAHAAcI4iFzCABeAgAYAAQIThK4EQDaAAAAAA==.',['大愤']='大愤:BAACLAAFFH8hAAITAAUI0hA+FwD3AAATAAUI0hA+FwD3AAAsAAQKfxQAAhMACAgyFBcgAEQBABMACAgyFBcgAEQBAAAA.',['大災']='大災變丶:BAABLAAFFH8GAAMMAAYIOBSjCACbAAAKAAMIKBTdQQDkAAAMAAMISRSjCACbAAAAAA==.',['大秘']='大秘练习生:BAABLAAFFH8VAAMFAAUITBdYJwD8AAAFAAUIaRZYJwD8AAAEAAIIDBnbGQA6AAAAAA==.',['大胆']='大胆:BAABLAAFFH8IAAIZAAgIdx/kAgCjAgAZAAgIdx/kAgCjAgAAAA==.',['大风']='大风厂:BAABLAAFFH8GAAMEAAMIcgcZFwBTAAAEAAMIcgcZFwBTAAALAAEIMgBbIQAXAAAAAA==.',['天明']='天明:BAAALAAECgcIDQAAAA==.',['失落']='失落的人民:BAAALAAECgYIEQAAAA==.失落的猫咪:BAAALAAECgYIBgAAAA==.',['头顶']='头顶尖尖的:BAABLAAFFH8JAAIFAAMIMQ9YYQCMAAAFAAMIMQ9YYQCMAAAAAA==.',['夺进']='夺进霹雳面:BAACLAAFFH8FAAIJAAMIxhiTQACVAAAJAAMIxhiTQACVAAAsAAQKfxsAAgkABwgdIeQdACgCAAkABwgdIeQdACgCAAAA.',['奶酪']='奶酪块:BAABLAAECn8ZAAMRAAcImiCZJQDPAQARAAYIxiCZJQDPAQATAAEIkh+0igBcAAAAAA==.',['妖艳']='妖艳孕妇:BAAALAAECgYIBgAAAA==.',['娜娜']='娜娜米:BAAALAAECgYIBgABLAAFFAIIBgAJAIMhAA==.',['嫉妒']='嫉妒的罪孽:BAAALAAECgQIBAAAAA==.',['安之']='安之若命:BAABLAAFFH8GAAIaAAIIqQz3LQCNAAAaAAIIqQz3LQCNAAAAAA==.',['安冬']='安冬医生:BAAALAAFFAIIAgAAAA==.安冬射魔:BAABLAAFFH8FAAIHAAUInRRQVQD9AAAHAAUInRRQVQD9AAAAAA==.安冬霸霸:BAABLAAFFH8HAAIFAAMIPxfKXgCSAAAFAAMIPxfKXgCSAAAAAA==.',['宝贝']='宝贝儿二:BAAALAAFFAgIAwAAAA==.',['宾戈']='宾戈:BAAALAADCggICQAAAA==.',['小夜']='小夜时雨:BAABLAAFFH8GAAIKAAYImxdCQgDgAAAKAAYImxdCQgDgAAAAAA==.',['小小']='小小墨兰:BAAALAAECgYICwAAAA==.',['小法']='小法图图:BAAALAAECgQIBAAAAA==.',['小生']='小生意気:BAABLAAFFH8KAAIVAAII0gguFwAoAAAVAAII0gguFwAoAAAAAA==.',['尛灬']='尛灬奶片:BAAALAAECgQIBgAAAA==.',['山河']='山河故人:BAAALAADCgcIBwAAAA==.',['巴尔']='巴尔斯维克:BAAALAAECgYIBgAAAA==.',['布丽']='布丽吉特诺亚:BAAALAADCgUIBQAAAA==.',['帕普']='帕普迪玛斯:BAAALAADCggICAAAAA==.',['带头']='带头丶大哥:BAAALAAECgYIDQAAAA==.',['幻想']='幻想者:BAAALAAFFAIIBAAAAA==.',['幻象']='幻象之神:BAAALAAFFAIIAgAAAA==.',['幼儿']='幼儿园战神:BAAALAAECggICAAAAA==.',['幽霜']='幽霜:BAABLAAECn8VAAIFAAgIJR9VNgCdAgAFAAgIJR9VNgCdAgAAAA==.',['广成']='广成子:BAAALAAECgMIBAAAAA==.',['开山']='开山:BAAALAAECgUIBgAAAA==.',['弟弟']='弟弟不要丶啊:BAAALAAECgQIBAAAAA==.',['强植']='强植装甲:BAABLAAFFH8IAAMbAAYIJAbQEwALAQAbAAYIJAbQEwALAQAcAAII2wIjGgBOAAAAAA==.',['心盗']='心盗:BAAALAAECgQIBAAAAA==.',['志官']='志官货:BAAALAADCgIIAgAAAA==.',['志崎']='志崎桦音:BAABLAAFFH8MAAIdAAYIUA0nAwDPAQAdAAYIUA0nAwDPAQAAAA==.',['怀念']='怀念你的爱丶:BAAALAAECgQIBAAAAA==.',['惡魔']='惡魔暴珺丶:BAABLAAFFH8GAAIKAAYIDxoMIwCRAQAKAAYIDxoMIwCRAQAAAA==.',['感谢']='感谢队长带我:BAABLAAFFH8RAAIeAAYINAhABABBAQAeAAYINAhABABBAQAAAA==.',['愤怒']='愤怒的小母牛:BAAALAAECgIIAgAAAA==.愤怒的罪孽:BAAALAAECggIAQAAAA==.',['愿你']='愿你无忧恙:BAABLAAFFH8bAAITAAgIlCAqAgBuAgATAAgIlCAqAgBuAgAAAA==.',['懒锝']='懒锝虐你:BAAALAAECgYIBgAAAA==.',['我一']='我一个回春术:BAAALAAECgYIBgAAAA==.我一个滑铲:BAAALAAECgYIDgAAAA==.',['我叫']='我叫神:BAACLAAFFH8FAAITAAIIvQXwNgAqAAATAAIIvQXwNgAqAAAsAAQKfx4AAhMABwi5DfsqAP0AABMABwi5DfsqAP0AAAAA.',['我带']='我带翅膀你呢:BAAALAAECgQIBQAAAA==.',['我是']='我是杨恒力:BAAALAAECgQIBQAAAA==.',['打本']='打本机器:BAABLAAFFH8PAAIKAAYIgyK+DgDzAQAKAAYIgyK+DgDzAQAAAA==.',['打桩']='打桩模子:BAAALAAECgQIBAAAAA==.',['拔剑']='拔剑为红颜:BAAALAAECgYICQAAAA==.',['摘月']='摘月:BAABLAAFFH8GAAIFAAIIERG7gwBEAAAFAAIIERG7gwBEAAAAAA==.',['改日']='改日一天:BAAALAAECgIIAgAAAA==.',['故不']='故不顾:BAAALAAFFAQIBAAAAA==.',['敌法']='敌法爱你哟:BAAALAAECgYICwABLAAECgcICAAGAAAAAA==.',['散落']='散落的烟灰:BAAALAAECgYICQAAAA==.',['敲边']='敲边鼓:BAAALAAECgYIBgAAAA==.',['斋藤']='斋藤飞鸟:BAACLAAFFH8YAAIKAAYIjiP7BABnAgAKAAYIjiP7BABnAgAsAAQKfxcAAgoACAh6IwIeANcCAAoACAh6IwIeANcCAAAA.',['斐斐']='斐斐猪:BAAALAADCgIIAgAAAA==.',['方大']='方大哥最后的:BAACLAAFFH8uAAIEAAgImyBUAQBhAgAEAAgImyBUAQBhAgAsAAQKfxoAAgQACAhDJccEACMDAAQACAhDJccEACMDAAAA.',['无事']='无事勾栏听曲:BAAALAAECgEIAQAAAA==.',['无糖']='无糖美式:BAABLAAFFH8GAAIFAAYIhgURGgBbAQAFAAYIhgURGgBbAQAAAA==.',['旺汪']='旺汪旺:BAAALAAECgQIBAAAAA==.',['明月']='明月明月啊:BAABLAAFFH8GAAIXAAYILg7uFAA8AQAXAAYILg7uFAA8AQAAAA==.明月星星:BAABLAAFFH8OAAIXAAYILxvMDgB+AQAXAAYILxvMDgB+AQAAAA==.明月饭行:BAABLAAFFH8KAAIXAAYINxWdEQBeAQAXAAYINxWdEQBeAQAAAA==.',['星夜']='星夜巷尾雪猫:BAAALAAECgUIBQAAAA==.',['月儿']='月儿弯弯:BAABLAAFFH8aAAIKAAYIViW0DwAXAgAKAAYIViW0DwAXAgAAAA==.',['月児']='月児弯弯:BAABLAAFFH8NAAIKAAYIDCU6EQDaAQAKAAYIDCU6EQDaAQAAAA==.',['杀了']='杀了再埋:BAABLAAFFH8GAAITAAYILA7MDwDPAAATAAYILA7MDwDPAAAAAA==.',['杀杀']='杀杀怪:BAAALAAECgYIBwAAAA==.',['李俊']='李俊浩丶:BAABLAAFFH8fAAIZAAgIxRfdCAAiAgAZAAgIxRfdCAAiAgAAAA==.',['杨冬']='杨冬花:BAAALAAECgEIAQAAAA==.',['杨梅']='杨梅:BAAALAAECgQIBQAAAA==.',['杨秋']='杨秋花:BAAALAAECgIIAgAAAA==.',['杯子']='杯子丶壹:BAAALAADCgUIBQAAAA==.',['果啤']='果啤泡泡:BAAALAAECggICwAAAA==.',['果果']='果果:BAAALAADCgMIAwAAAA==.',['果然']='果然二:BAAALAADCgUIBQAAAA==.',['树三']='树三:BAABLAAFFH8QAAIPAAYIYCQJBQBSAgAPAAYIYCQJBQBSAgABLAAFFAgIBwAQADMRAA==.',['树丝']='树丝:BAABLAAFFH8MAAIPAAYI7B4OCwDXAQAPAAYI7B4OCwDXAQAAAA==.',['树二']='树二:BAABLAAFFH8MAAIPAAYIyCGxBgAqAgAPAAYIyCGxBgAqAgAAAA==.',['树大']='树大:BAACLAAFFH8GAAIPAAYIqx7FDwCNAQAPAAYIqx7FDwCNAQAsAAQKfxUAAg8ACAj/I90CAAEDAA8ACAj/I90CAAEDAAEsAAUUCAgHABAAMxEA.',['桥本']='桥本环奈:BAABLAAFFH8WAAINAAYIviGsAAAzAgANAAYIviGsAAAzAgAAAA==.',['橘子']='橘子酱:BAAALAAECggIEQAAAA==.',['橙子']='橙子小憨包:BAAALAAECgcIAwABLAAFFAIIAgAGAAAAAA==.橙子沁甜:BAAALAAFFAIIAgAAAA==.',['欧皇']='欧皇橙子:BAAALAAECgYIBQAAAA==.',['歆之']='歆之月:BAAALAAECgEIAQAAAA==.歆之毁灭:BAAALAAECgYIDAAAAA==.',['武术']='武术大师:BAAALAAFFAIIAgAAAA==.',['武状']='武状元:BAABLAAFFH8lAAIRAAgI6CD7BACPAgARAAgI6CD7BACPAgAAAA==.',['死在']='死在冲钅路上:BAAALAAECgYIBgABLAAFFAYILgAQALMhAA==.',['死神']='死神的怒吼:BAAALAAECgIIAgAAAA==.',['水妃']='水妃摩根:BAAALAAECgcIEgAAAA==.',['池鱼']='池鱼思故淵:BAABLAAFFH8GAAIbAAYICBeRDgBhAQAbAAYICBeRDgBhAQAAAA==.',['汽水']='汽水泡茶:BAABLAAFFH8IAAIJAAgIYgB7hwAMAAAJAAgIYgB7hwAMAAAAAA==.',['没时']='没时间啦:BAAALAAECgYIBgAAAA==.',['波纹']='波纹牧:BAAALAAECgIIAgAAAA==.',['注意']='注意打断:BAAALAAECgMIAwAAAA==.',['洛克']='洛克塔丶萝莉:BAAALAADCgYIBgAAAA==.',['浩劫']='浩劫赋伤:BAAALAAECgYIDAABLAAFFAQIBAAGAAAAAA==.',['海棠']='海棠溪江:BAAALAAECgEIAQAAAA==.',['混世']='混世刚:BAAALAADCgQIBAAAAA==.',['渧释']='渧释天:BAAALAAECgUIBQABLAAFFAgIKwAHAF4iAA==.',['湿太']='湿太:BAAALAAECgEIAQAAAA==.',['滴滴']='滴滴打德:BAAALAAECgUIBQAAAA==.',['濏濏']='濏濏滴凡尔赛:BAAALAAECgQIBAAAAA==.',['火神']='火神:BAAALAAECgYIBwAAAA==.',['灬冷']='灬冷眸丶:BAAALAADCggICAAAAA==.',['灬北']='灬北辰坏蛋丶:BAAALAADCgIIAgAAAA==.',['灬吴']='灬吴彦祖:BAAALAADCggICAAAAA==.',['灬小']='灬小鲁班灬:BAABLAAFFH8HAAIQAAIINhy2LwCiAAAQAAIINhy2LwCiAAAAAA==.',['灬御']='灬御坂美琴灬:BAABLAAECn8XAAMFAAgI1iRPEAAxAwAFAAgI1iRPEAAxAwALAAgIBRmPFwAEAgAAAA==.',['灭霸']='灭霸:BAAALAADCgQIBAAAAA==.',['灯泡']='灯泡丶:BAAALAAECgYIDAABLAAFFAIIBgAJAIMhAA==.',['点点']='点点郁金香:BAAALAADCgMIAwAAAA==.',['烟头']='烟头烧胸毛:BAAALAAECgEIAQAAAA==.',['熊一']='熊一红:BAAALAAFFAIIAgAAAA==.',['熊猫']='熊猫楞:BAAALAADCgEIAQAAAA==.',['熔芯']='熔芯巢猎者:BAAALAAECgMIAwAAAA==.',['爆炒']='爆炒肥肠:BAABLAAFFH8RAAINAAYI5AnKBwAkAQANAAYI5AnKBwAkAQAAAA==.',['牛妞']='牛妞妞:BAAALAAECgEIAwAAAA==.',['牛骑']='牛骑:BAABLAAFFH8JAAIJAAMIdhl4JwC6AAAJAAMIdhl4JwC6AAAAAA==.',['牢九']='牢九:BAAALAAECgYICwAAAA==.',['牧魂']='牧魂人:BAAALAADCgEIAQAAAA==.',['狂傲']='狂傲乂本性:BAAALAAECgUIBQAAAA==.',['狸猫']='狸猫是草莓味:BAAALAAECgUIBQAAAA==.',['猎武']='猎武杀神:BAAALAAECgcIDQAAAA==.',['猫猫']='猫猫头庇佑你:BAAALAAECgEIAQAAAA==.',['王城']='王城:BAAALAAECgYICAAAAA==.',['玛利']='玛利喀斯:BAABLAAFFH8JAAIWAAMI5R1wDQCxAAAWAAMI5R1wDQCxAAAAAA==.',['玩坦']='玩坦两天半:BAAALAAFFAIIAgAAAA==.',['珑九']='珑九:BAACLAAFFH8RAAQfAAUI+g0aEwDjAAAfAAQIWgsaEwDjAAABAAQI2hKXFAC7AAAOAAMIJBi8CwCUAAAsAAQKfxQAAwEABggDGRoUAGYBAAEABggDGRoUAGYBAB8ABgj0DRonACsBAAEsAAUUBggcAAQADh8A.',['琪九']='琪九:BAACLAAFFH8cAAMEAAYIDh+oBgDPAQAEAAYIDh+oBgDPAQAFAAMI/Rs6TwChAAAsAAQKfy0AAwQACAh4IcYDAJkCAAQACAgMIcYDAJkCAAUABQhmG731AFIBAAAA.',['瓦利']='瓦利安凯旋:BAABLAAFFH8GAAIJAAYIpwHhfQAzAAAJAAYIpwHhfQAzAAAAAA==.',['甜菜']='甜菜:BAAALAAFFAIIAgAAAA==.',['番茄']='番茄薯条:BAAALAADCgIIAgAAAA==.',['疯狂']='疯狂的音符:BAAALAAECgUIBwAAAA==.',['疲而']='疲而惫之:BAAALAAFFAIIBAAAAA==.',['病变']='病变:BAAALAAECgUICwAAAA==.',['盾牌']='盾牌:BAACLAAFFH8IAAITAAIIaw3LLgA1AAATAAIIaw3LLgA1AAAsAAQKfxQABBMABgiNDx8sAPYAABMABgjRDh8sAPYAABEABAgxCBjWAL0AABIAAwhcDbcoALMAAAAA.',['破镜']='破镜:BAAALAAECgYICQAAAA==.',['硫酸']='硫酸硝酸:BAABLAAFFH8FAAIFAAIIEg+ulAA9AAAFAAIIEg+ulAA9AAAAAA==.',['祎歆']='祎歆:BAABLAAFFH8FAAIZAAIIxgiSTQBYAAAZAAIIxgiSTQBYAAAAAA==.',['神雪']='神雪依:BAAALAADCggICQAAAA==.',['笨蛋']='笨蛋还在打我:BAAALAAFFAQIBAABLAAFFAYILgAJAJUhAA==.',['第一']='第一次玩奶:BAAALAAFFAIIAwAAAA==.',['米尼']='米尼:BAAALAAECgYIEAAAAA==.',['粉红']='粉红色回忆:BAABLAAFFH8LAAMWAAYI8gOYFABSAAAWAAYI8gOYFABSAAAJAAIIVQFagwAmAAAAAA==.',['粑粑']='粑粑大王:BAAALAAECgEIAgAAAA==.',['索拉']='索拉天刃:BAAALAAECgIIAgAAAA==.',['纯天']='纯天然无添加:BAAALAAECgYICQAAAA==.',['缺丶']='缺丶德:BAAALAAECgYIBgAAAA==.',['老太']='老太婆:BAAALAAFFAIIBAAAAA==.',['老狐']='老狐狸狸:BAAALAAECgIIAgAAAA==.',['胧月']='胧月:BAABLAAFFH8HAAIFAAYIWCTWEAAKAgAFAAYIWCTWEAAKAgAAAA==.',['脾气']='脾气三号:BAAALAADCgEIAQAAAA==.',['艾瑞']='艾瑞达之郎:BAAALAAFFAIIAgABLAAFFAYILgAQALMhAA==.',['艾蕾']='艾蕾:BAAALAADCgUIBQAAAA==.',['芙蓉']='芙蓉:BAAALAADCgEIAQAAAA==.',['花满']='花满楼:BAABLAAECn8ZAAIJAAgIUg0AmADEAQAJAAgIUg0AmADEAQAAAA==.',['苹果']='苹果雪梨煲鸽:BAAALAAECgcIDwAAAA==.',['茉莉']='茉莉小宝:BAAALAAECgIIAgAAAA==.',['茵蒂']='茵蒂克丝:BAAALAAECgUICAAAAA==.',['荧惑']='荧惑火德真君:BAAALAAECggICAAAAA==.',['莉欧']='莉欧妮:BAAALAAECgcIBwAAAA==.',['萌熊']='萌熊二:BAAALAADCgQIBAAAAA==.',['萨斯']='萨斯哆拉:BAAALAAFFAIIBAAAAA==.',['蒜泥']='蒜泥倒莓:BAABLAAFFH8GAAIPAAYIoQ4UEgBrAQAPAAYIoQ4UEgBrAQAAAA==.',['蒜鸟']='蒜鸟算鸟:BAABLAAFFH8FAAMNAAII8xbADACfAAANAAII8xbADACfAAAIAAEI3gesbQA9AAAAAA==.',['蔓荼']='蔓荼萝:BAAALAAECgEIAQAAAA==.',['蜜桃']='蜜桃气泡:BAABLAAFFH8GAAIHAAYISwBsxQAQAAAHAAYISwBsxQAQAAAAAA==.',['被解']='被解救的浆果:BAABLAAFFH8IAAIFAAMI7wcHawBrAAAFAAMI7wcHawBrAAAAAA==.',['观丶']='观丶人生百态:BAAALAADCgMIAwAAAA==.',['諏訪']='諏訪四郎勝頼:BAAALAAECgYIBgAAAA==.',['该删']='该删的删:BAAALAADCgUIBQAAAA==.',['诱酸']='诱酸乳:BAAALAADCgEIAQAAAA==.',['贼一']='贼一号:BAAALAAECgMIAwAAAA==.',['超超']='超超的跟班:BAAALAAECgcIBwAAAA==.',['转角']='转角丶撞到墙:BAAALAADCgQIBAAAAA==.',['辛之']='辛之月:BAAALAAECgYIBgAAAA==.',['迷人']='迷人的大沟蛋:BAAALAAECgIIAgAAAA==.',['邪恶']='邪恶的膏玩哥:BAABLAAFFH8LAAIZAAIIfRWcPwB1AAAZAAIIfRWcPwB1AAAAAA==.邪恶的高玩哥:BAACLAAFFH8PAAIRAAMIuhMXOACUAAARAAMIuhMXOACUAAAsAAQKfxwAAxEABgglIrU1AF8CABEABgglIrU1AF8CABIAAgjXE98uAH4AAAAA.',['邱淑']='邱淑贞:BAAALAAECgYIBgAAAA==.',['郑翔']='郑翔:BAAALAAECgMIBQAAAA==.',['酒尚']='酒尚温:BAAALAAECggICAAAAA==.',['野猿']='野猿顾之助:BAAALAAECgYIDQABLAAFFAQIBAAGAAAAAA==.',['量大']='量大管饱:BAAALAAECgYIBgAAAA==.',['钢琴']='钢琴里的猫:BAAALAAFFAgIAQAAAA==.',['银槍']='银槍小霸王:BAAALAAECgYIDAAAAA==.',['闪闪']='闪闪可露丽:BAABLAAFFH8QAAQXAAMIHA/cJACLAAAXAAMICQ3cJACLAAAZAAIIuxdxOwCCAAAgAAIIegjNDwA7AAAAAA==.',['闺蜜']='闺蜜必须死:BAAALAAFFAIIAgAAAA==.',['阴影']='阴影灬刃:BAAALAADCgcIBwAAAA==.',['阿玛']='阿玛忒拉斯:BAAALAADCgMIAwAAAA==.',['雷公']='雷公助我:BAAALAADCgIIAgAAAA==.',['青叫']='青叫我三哥:BAAALAADCgIIAgAAAA==.',['非洲']='非洲白猩猩:BAAALAAFFAIIAwAAAA==.',['风之']='风之颂:BAAALAAECgMIAwAAAA==.',['风暴']='风暴之锤打击:BAACLAAFFH8uAAIQAAYIsyEdCQA2AgAQAAYIsyEdCQA2AgAsAAQKfxsAAxAACAiWI8wJAMECABAACAiWI8wJAMECABoABwiqIV8NAFkCAAAA.风暴啤酒:BAAALAAECgEIAQAAAA==.',['风白']='风白羽丿:BAAALAAFFAIIAgAAAA==.',['马夏']='马夏尔:BAAALAAECgYICQAAAA==.',['马库']='马库思:BAAALAADCgEIAQAAAA==.',['骑女']='骑女子:BAAALAADCgEIAQAAAA==.',['魂之']='魂之归来:BAABLAAFFH8QAAIKAAYISBu0HQCqAQAKAAYISBu0HQCqAQAAAA==.',['鱼罐']='鱼罐头:BAAALAAECgMIAwAAAA==.',['鲍三']='鲍三娘:BAAALAADCgYIBgAAAA==.',['鹤仙']='鹤仙:BAAALAAECgYIBgAAAA==.',['麼丷']='麼丷唁:BAAALAAFFAIIAgAAAA==.',['黄河']='黄河啤酒:BAAALAAECgMIAwAAAA==.',['黑剑']='黑剑:BAAALAAFFAIIAgAAAA==.',['黑煤']='黑煤贵:BAAALAADCgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end