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
 local lookup = {'Rogue-Subtlety','Rogue-Assassination','Druid-Restoration','Druid-Balance','Shaman-Restoration','Paladin-Retribution','Warrior-Protection','Warrior-Fury','DeathKnight-Frost','Hunter-BeastMastery','Mage-Frost','Mage-Arcane','Priest-Holy','Priest-Shadow','Paladin-Holy','Hunter-Marksmanship','Warlock-Destruction','Warlock-Demonology','DeathKnight-Blood','Druid-Guardian','Rogue-Outlaw','DemonHunter-Havoc','Monk-Mistweaver','Paladin-Protection','Shaman-Elemental','DeathKnight-Unholy','Priest-Discipline','Warlock-Affliction','Warrior-Arms','Monk-Brewmaster','Druid-Feral','Monk-Windwalker','Evoker-Preservation','Evoker-Devastation','Unknown-Unknown','Hunter-Survival',}; local provider = {region='CN',realm='石锤',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ak='Akjustcall:BAAALAADCgMIAwAAAA==.',Au='Aurror:BAACLAAFFH8MAAIBAAIIOBU5EQCWAAABAAIIOBU5EQCWAAAsAAQKfy8AAwEACAg0GNsQADACAAEACAg0GNsQADACAAIABghjCcFIACIBAAAA.',Be='Bethoes:BAACLAAFFH8gAAIDAAYIBRx1DQDjAQADAAYIBRx1DQDjAQAsAAQKfxQAAwQABggKGsZEAKEBAAQABggKGsZEAKEBAAMABgjlFVxaAIUBAAEsAAUUBggxAAUAKiAA.',Bm='Bmozad:BAABLAAFFH8pAAIGAAYI0RTpGgCDAQAGAAYI0RTpGgCDAQAAAA==.',Bo='Bower:BAAALAAECgQIBAAAAA==.',Ce='Celeste:BAAALAAFFAYIBAAAAA==.',Cr='Crazylara:BAAALAAECgUIBQAAAA==.',Da='Dayfornight:BAAALAADCgUIBQAAAA==.',Dd='Ddk:BAAALAAFFAIIBAAAAA==.',De='Deadfish:BAACLAAFFH8dAAIHAAQIRwYrIQBwAAAHAAQIRwYrIQBwAAAsAAQKfzkAAgcACAhhDLsjACkBAAcACAhhDLsjACkBAAAA.',Di='Diegodie:BAAALAAFFAIIBAAAAA==.Dietodie:BAAALAAECgYIDwAAAA==.',Dl='Dlc:BAAALAADCgMIAwAAAA==.',En='Envision:BAABLAAECn8VAAIIAAYIRg6vmQBRAQAIAAYIRg6vmQBRAQAAAA==.',Fa='Fannys:BAAALAAECgYIBwAAAA==.',Ga='Gancuiwen:BAAALAAECgYICgAAAA==.',Ge='Gerry:BAAALAAECgIIAgAAAA==.',He='Hellride:BAABLAAFFH8GAAIJAAYIQxCQPQBFAQAJAAYIQxCQPQBFAQAAAA==.Hellstar:BAAALAAECgUIBQAAAA==.',Ho='Hokage:BAAALAADCgYICgAAAA==.',In='Ina:BAAALAAECgIIAgAAAA==.Indiansumme:BAAALAAECgYICQAAAA==.',Ja='January:BAAALAAECgEIAQAAAA==.',Je='Jeeq:BAAALAAECgUIBQAAAA==.',Le='Legola:BAABLAAFFH8LAAIKAAUI4RLWTQAWAQAKAAUI4RLWTQAWAQAAAA==.Lettle:BAABLAAFFH8HAAIIAAIIMxIxOQCVAAAIAAIIMxIxOQCVAAAAAA==.',Ma='Magixx:BAABLAAFFH8HAAMLAAIIawy1HwBEAAALAAEIEhG1HwBEAAAMAAEIxQdVZgA0AAAAAA==.',Me='Mecry:BAAALAAECgYIEgAAAA==.Meo:BAABLAAFFH8OAAIFAAMIZBDARgCSAAAFAAMIZBDARgCSAAAAAA==.',Mh='Mhjah:BAABLAAFFH8GAAIGAAIIbRtVYwBEAAAGAAIIbRtVYwBEAAAAAA==.',Na='Narcissus:BAAALAADCgEIAQAAAA==.',Ny='Nyx:BAAALAAFFAIIAgAAAA==.',Pl='Playeriltxvc:BAABLAAFFH8nAAMNAAgI+h9KCABEAgANAAYICyJKCABEAgAOAAII/hzYGwC7AAAAAA==.',Ri='Rinoa:BAABLAAECn8WAAIGAAYIhSAxOgCvAQAGAAYIhSAxOgCvAQAAAA==.',Ro='Royalkaka:BAAALAAFFAIIAgAAAA==.',Ry='Ryanme:BAABLAAECn8ZAAIIAAgIexq8GAAdAgAIAAgIexq8GAAdAgAAAA==.Ryanmi:BAAALAAECgcIDQAAAA==.',Sa='Sagittarius:BAAALAADCgEIAQAAAA==.',Se='Seoyoon:BAABLAAFFH8gAAMGAAYIchWhKAA2AQAGAAUIbBWhKAA2AQAPAAUIEAxrFwAYAQAAAA==.',Sh='Shadowman:BAAALAADCgIIAgAAAA==.',Sn='Snakeyuki:BAABLAAFFH8eAAIGAAYIhyAXDQDbAQAGAAYIhyAXDQDbAQAAAA==.',Te='Teackertony:BAAALAAECgYIBgAAAA==.',Th='Thunderfury:BAAALAAFFAIIAgAAAA==.',Un='Unrestrained:BAAALAAECgYIBgAAAA==.',Va='Vasily:BAACLAAFFH8OAAMQAAMItiFYGACrAAAKAAMIgSEmYQC5AAAQAAIIph5YGACrAAAsAAQKfzEAAwoACAj9I1kYAPwCAAoACAi2I1kYAPwCABAACAiYH8gSAM0CAAAA.',Ve='Veronika:BAAALAADCgIIAgAAAA==.',Vi='Vivir:BAABLAAFFH8xAAIIAAcIdxnsCAAlAgAIAAcIdxnsCAAlAgAAAA==.',Xi='Xidian:BAAALAAFFAIIBAAAAA==.',Yo='Yong:BAAALAAECgYIBwAAAA==.',Ys='Yshnag:BAAALAAECgYIBgAAAA==.',['一人']='一人一狗一弓:BAAALAAECgYICwAAAA==.',['一只']='一只小小从:BAACLAAFFH8SAAIEAAQINBSPHgDRAAAEAAQINBSPHgDRAAAsAAQKfxoAAgQABwjRHlceAG0CAAQABwjRHlceAG0CAAAA.',['一战']='一战背水:BAACLAAFFH8HAAIIAAIIwhAvOgCUAAAIAAIIwhAvOgCUAAAsAAQKfxcAAggACAiIHK4oAJwCAAgACAiIHK4oAJwCAAAA.',['一行']='一行:BAACLAAFFH8GAAIGAAIIoAe0VwCKAAAGAAIIoAe0VwCKAAAsAAQKfzcAAgYABwgyGKt+AO4BAAYABwgyGKt+AO4BAAAA.',['一西']='一西索一:BAAALAAECgEIAQAAAA==.',['一霸']='一霸霸一:BAAALAADCggICAAAAA==.',['七月']='七月灬挽歌:BAAALAAECgQIBwAAAA==.',['七煌']='七煌之焱:BAAALAADCgUIBQAAAA==.',['万紫']='万紫千红:BAAALAAECgYIBgAAAA==.',['三队']='三队奶德:BAAALAAECgYICgAAAA==.',['上汽']='上汽大众:BAACLAAFFH8bAAMRAAQIEh1tPwD6AAARAAQIEh1tPwD6AAASAAEIXBktJgBTAAAsAAQKfz8AAxEACAjwHpcoAKECABEACAjEHpcoAKECABIABQhgHBdEAF4BAAAA.',['上海']='上海企业贷款:BAAALAAECgUIBQAAAA==.',['不染']='不染心:BAABLAAFFH8MAAMSAAMIiA/HCQCFAAASAAMIXArHCQCFAAARAAIIqg6CagA2AAAAAA==.',['不要']='不要停下来啊:BAAALAAFFAMIAwAAAA==.',['丑咪']='丑咪:BAAALAAFFAIIAgAAAA==.',['世一']='世一羽猎:BAAALAAECgYIBgAAAA==.',['丧钟']='丧钟村长:BAAALAAECgYIBgAAAA==.',['中年']='中年丶奶爸:BAAALAAECgUIBQAAAA==.',['丶娜']='丶娜美丶:BAAALAAECgMIAwAAAA==.',['丶小']='丶小傻:BAABLAAFFH8kAAMJAAYIIh0sIgCrAQAJAAYIIh0sIgCrAQATAAEIfQAAAAAAAAAAAA==.',['丶月']='丶月咏丶:BAAALAAECgYIBgAAAA==.',['丿吖']='丿吖燕兒灬:BAAALAAECgEIAQAAAA==.',['乂一']='乂一乂:BAAALAAECgYIBgAAAA==.',['乂义']='乂义乂乂义乂:BAAALAAECgYIDAAAAA==.',['乄奶']='乄奶你媄:BAAALAAECgMIAwAAAA==.',['乄慈']='乄慈:BAABLAAFFH8dAAIUAAYIlALRBgCSAAAUAAYIlALRBgCSAAAAAA==.',['乄迷']='乄迷茫:BAAALAAECgIIAgAAAA==.',['乌瑞']='乌瑞恩之风:BAAALAAFFAIIBAAAAA==.',['九色']='九色交织:BAAALAAECgYIBgAAAA==.',['二五']='二五八万:BAAALAAECggICgAAAA==.',['二手']='二手跳蚤:BAAALAAECgYIDAAAAA==.',['二队']='二队奶萨:BAAALAAECgQICQAAAA==.',['五爪']='五爪:BAAALAADCggICwAAAA==.',['亞亞']='亞亞瘦到壹佰:BAAALAADCgYIBgAAAA==.',['今天']='今天你吃了么:BAAALAAECgYIBgAAAA==.',['今晚']='今晚早点睡:BAAALAAECggICAAAAA==.',['伊利']='伊利弹:BAAALAAECgYIBgAAAA==.伊利逗乳:BAAALAAECgYIDAAAAA==.',['伊灬']='伊灬利丹:BAAALAADCgEIAQAAAA==.',['伏安']='伏安法:BAABLAAFFH8RAAIFAAIIxhokSQCLAAAFAAIIxhokSQCLAAAAAA==.',['休格']='休格:BAAALAADCgEIAQAAAA==.',['休闲']='休闲派:BAAALAAECgMIAwAAAA==.',['你小']='你小妈:BAAALAADCgMIAwABLAAFFAUIGAAEAEwYAA==.',['佬佛']='佬佛爷:BAAALAAECgYIDAAAAA==.',['依依']='依依之恋:BAAALAAECgYIBgAAAA==.',['全世']='全世界大王:BAACLAAFFH8IAAIGAAIIwgt6bABAAAAGAAIIwgt6bABAAAAsAAQKfx0AAgYABwhgFqNVAF8BAAYABwhgFqNVAF8BAAAA.',['八十']='八十五度:BAAALAAECgUICAAAAA==.',['六二']='六二二同学:BAAALAAFFAEIAQAAAA==.',['关琪']='关琪儿:BAAALAAECgYIBgAAAA==.',['其其']='其其霞:BAAALAAECgQIBAAAAA==.',['其貌']='其貌不扬:BAAALAAECgYIBgABLAAFFAYIMQAFACogAA==.',['再战']='再战风云:BAAALAADCgQIBAAAAA==.',['冰冷']='冰冷刀锋:BAAALAADCgYIBgAAAA==.',['冰拿']='冰拿铁大欧皇:BAACLAAFFH8PAAIJAAUISiE5IwAQAQAJAAUISiE5IwAQAQAsAAQKfxYAAgkACAhnJHcWABcDAAkACAhnJHcWABcDAAAA.',['冰舞']='冰舞流火:BAAALAAECggICwAAAA==.',['凋零']='凋零之殇:BAAALAAECgEIAQAAAA==.',['几亿']='几亿光年:BAAALAAECgUIBgAAAA==.',['切茜']='切茜娅之手:BAAALAAFFAYIBAAAAA==.',['划水']='划水小奶撒:BAAALAAFFAIIAgAAAA==.划水的鱼:BAAALAAFFAMIAwAAAA==.',['刘啫']='刘啫喱:BAABLAAFFH8IAAMNAAIIbhFbLgCRAAANAAIIbhFbLgCRAAAOAAIIYRFIIgCIAAAAAA==.',['刘思']='刘思思:BAAALAAECgQIBAAAAA==.',['初木']='初木清寒:BAAALAAECgYIEQAAAA==.',['别骂']='别骂我小白:BAAALAAECgYIEwAAAA==.',['加加']='加加岛丶:BAAALAAFFAEIAQAAAA==.',['加拉']='加拉哈德:BAAALAAECgYICwAAAA==.',['加鲁']='加鲁鲁猎手:BAAALAADCgcIBwAAAA==.',['动感']='动感光波:BAAALAAECgYIBgAAAA==.',['劲爆']='劲爆鸡米花:BAAALAAECgYIBgAAAA==.',['勇敢']='勇敢熊熊:BAACLAAFFH8HAAIDAAIIlhJpQQBuAAADAAIIlhJpQQBuAAAsAAQKfyMAAgMACAhlF7AdAOQBAAMACAhlF7AdAOQBAAAA.',['十九']='十九摸:BAAALAAECgYIBwAAAA==.',['十月']='十月雪:BAAALAAECgYIDAAAAA==.',['半条']='半条咸鱼丶:BAACLAAFFH8RAAMCAAUIsQeMCAA3AQACAAUIsQeMCAA3AQABAAEI7gPpHABCAAAsAAQKfxcABBUACAgBGswCAM4BABUACAjyEswCAM4BAAIABwjvFOwsAMABAAEABggiGeoiAHwBAAAA.',['半袖']='半袖红妆:BAABLAAFFH8GAAIKAAIIGSEbgABWAAAKAAIIGSEbgABWAAAAAA==.',['卡卡']='卡卡西里:BAABLAAFFH8GAAIIAAIIOgYAWgA8AAAIAAIIOgYAWgA8AAAAAA==.',['卡尔']='卡尔维诺:BAABLAAFFH8GAAIKAAIIFxgBiwBHAAAKAAIIFxgBiwBHAAAAAA==.',['卩小']='卩小蒋哥灬:BAAALAAECgEIAQAAAA==.',['卷王']='卷王:BAAALAAECgYIBwAAAA==.',['卿雅']='卿雅歆:BAAALAAECgEIAQAAAA==.卿雅馨:BAAALAAECgEIAQAAAA==.',['去阿']='去阿任:BAAALAAECggICAAAAA==.',['双椒']='双椒摩卡:BAAALAADCgcIBwAAAA==.双椒牛腩:BAABLAAFFH8KAAILAAMIXgrZDgBwAAALAAMIXgrZDgBwAAAAAA==.',['双正']='双正弦马尾:BAAALAADCgMIAwAAAA==.',['发呆']='发呆小懒猪:BAAALAAECgcIEwAAAA==.',['口哟']='口哟咪:BAAALAAECgYIBgAAAA==.',['可乐']='可乐:BAAALAAFFAIIAgAAAA==.',['可爱']='可爱:BAAALAAECgIIAgAAAA==.',['叶一']='叶一一:BAABLAAFFH8FAAMVAAMILQmtAwCGAAAVAAMILQmtAwCGAAACAAIIPQKeHwA1AAAAAA==.',['吖丷']='吖丷頭:BAABLAAFFH8ZAAIWAAYIFiD1EQDRAQAWAAYIFiD1EQDRAQAAAA==.',['吖灬']='吖灬頭:BAAALAAECgYIBgAAAA==.',['君不']='君不弃:BAAALAADCgUICgAAAA==.',['君君']='君君:BAAALAAFFAIIAgAAAA==.',['听风']='听风的鲸:BAAALAADCgMIAwAAAA==.',['吻住']='吻住别动:BAAALAAFFAIIBAAAAA==.',['呆萌']='呆萌小浣熊:BAAALAAECgYICgAAAA==.',['呲呲']='呲呲:BAAALAAECgYIDQAAAA==.',['呵呵']='呵呵侠:BAAALAAECgYICQAAAA==.',['呼拉']='呼拉小子:BAABLAAFFH8FAAMPAAUI9g/OCwArAQAPAAQI9Q7OCwArAQAGAAEI2QeWZQBWAAAAAA==.',['咔吥']='咔吥基諾:BAAALAAECgQIBAAAAA==.',['咕咕']='咕咕鸡:BAAALAAECgMIAwAAAA==.',['哇塞']='哇塞又来了:BAAALAAECgYIBwAAAA==.',['哒哒']='哒哒:BAAALAAECgYICgAAAA==.',['哥是']='哥是联盟:BAAALAADCgYIBgABLAAFFAMIDgAMAIQfAA==.',['哥本']='哥本哈根拳师:BAABLAAFFH8JAAIXAAMInB9/DQAJAQAXAAMInB9/DQAJAQAAAA==.哥本哈根拳狮:BAAALAAECgIIAgAAAA==.',['唐尸']='唐尸三摆手:BAAALAAECgMIAwAAAA==.',['唯灬']='唯灬她命:BAABLAAFFH8TAAMKAAUIaBi/SQAkAQAKAAUIaBi/SQAkAQAQAAIILxLCIwCAAAAAAA==.',['唯爱']='唯爱艳红:BAAALAAFFAIIAgAAAA==.',['嗜血']='嗜血的叛逆:BAAALAAECgYICAAAAA==.',['嘻哈']='嘻哈小桃:BAABLAAFFH8pAAIYAAYIsANZDADLAAAYAAYIsANZDADLAAAAAA==.嘻哈小梨:BAABLAAFFH8jAAMYAAYI4AP2CwDXAAAYAAYI4AP2CwDXAAAGAAEIdgFcggAmAAABLAAFFAYIKQAYALADAA==.',['囍囍']='囍囍:BAABLAAFFH8OAAMNAAYINB+aDwDjAQANAAYINB+aDwDjAQAOAAEI6gfZKQBDAAAAAA==.',['四队']='四队小德:BAAALAAECgUIBQAAAA==.',['土地']='土地公:BAAALAAECgYIDAAAAA==.',['圣之']='圣之沐歌:BAAALAAECgYIBgAAAA==.',['圣光']='圣光的风采:BAAALAAFFAEIAQAAAA==.',['圣剑']='圣剑魂:BAAALAADCgQIBAAAAA==.',['圣小']='圣小狐:BAAALAAECgQIBAABLAAFFAgICAAWABMWAA==.',['地法']='地法:BAAALAAECgcIBwAAAA==.',['坠羽']='坠羽:BAAALAAECgYIBgAAAA==.',['埃吉']='埃吉尔:BAAALAAECgYIBgAAAA==.',['堕落']='堕落瓦里安:BAAALAAFFAIIBAAAAA==.',['墨名']='墨名棋妙:BAAALAADCgQIBAAAAA==.',['墨屿']='墨屿嬜懿:BAAALAAECgEIAQAAAA==.',['壁虎']='壁虎漫步:BAAALAADCgYIBwAAAA==.',['壹箭']='壹箭灬风情:BAAALAAECgYIBwAAAA==.',['夏天']='夏天飘的雪:BAACLAAFFH8xAAMFAAYIKiByDgD2AQAFAAYIKiByDgD2AQAZAAUIaCFPFQCRAQAsAAQKfxgAAxkACAgKFidLANsBABkABwgSFidLANsBAAUABwh/F21gAMgBAAAA.',['夏日']='夏日里的冰:BAAALAAECgIIAgAAAA==.',['夜叁']='夜叁霖:BAACLAAFFH8aAAMJAAYI+hh0JQCfAQAJAAYI+hh0JQCfAQAaAAEIWRRNGAAAAAAsAAQKfxgAAgkABwjXIDomAN0BAAkABwjXIDomAN0BAAAA.夜叁霖的圣光:BAACLAAFFH8TAAMGAAYItRkpFQCjAQAGAAYItRkpFQCjAQAPAAIIDgI+JwBpAAAsAAQKfyYAAwYABwiVImYZAEQCAAYABwiVImYZAEQCAA8ABgjWCcRRAA0BAAAA.',['夜的']='夜的拥抱:BAAALAADCgYIGwAAAA==.',['够猛']='够猛你别怕:BAABLAAFFH8FAAIIAAMI/AhlOwCEAAAIAAMI/AhlOwCEAAAAAA==.',['大员']='大员外:BAAALAAECggIDwAAAA==.',['大啵']='大啵妞:BAAALAAECgUIBQAAAA==.',['大山']='大山勇士:BAAALAAFFAYIAgAAAA==.大山勇士哦:BAAALAAECgYICQAAAA==.大山旅长:BAAALAAECgEIAgAAAA==.大山队长:BAABLAAECn8YAAMPAAcIkRb2FAC3AQAPAAcIkRb2FAC3AQAGAAEIOhiDdAFNAAAAAA==.',['大海']='大海狸:BAAALAAFFAIIBAAAAA==.',['大牛']='大牛犇犇:BAAALAADCgQIBAAAAA==.',['大红']='大红帽小灰狼:BAAALAAECgIIAgAAAA==.',['天坠']='天坠火:BAAALAADCgMIAwAAAA==.',['天涯']='天涯灬若熙:BAAALAAECggIDwAAAA==.',['天蠍']='天蠍座:BAABLAAECn8VAAIMAAYIyA61mgBUAQAMAAYIyA61mgBUAQAAAA==.',['天陨']='天陨烬山河:BAAALAAECgMIAwAAAA==.',['太多']='太多德:BAAALAAECgYIBgAAAA==.',['奇佐']='奇佐:BAACLAAFFH8bAAMGAAQIsBhbNADeAAAGAAQIsBhbNADeAAAPAAMISBF+GQCYAAAsAAQKf0kAAwYACAhgJM8GAOUCAAYACAhgJM8GAOUCAA8ACAigHhYVAGYCAAAA.',['套儿']='套儿:BAAALAAECgYICgAAAA==.',['套盾']='套盾大天使:BAAALAAECggICAAAAA==.',['奥术']='奥术敏锐:BAAALAAECgYIDAAAAA==.',['奥菲']='奥菲娅:BAAALAAECgYIBgAAAA==.',['女乃']='女乃萨奥里给:BAABLAAFFH8MAAIFAAUISQl9NADUAAAFAAUISQl9NADUAAABLAAFFAUIEAARAMwQAA==.',['奶白']='奶白靓仔:BAAALAAECgYIDQAAAA==.',['奶萨']='奶萨丶:BAAALAAFFAIIAgAAAA==.',['好感']='好感动:BAAALAAFFAEIAQAAAA==.',['姜戈']='姜戈:BAAALAAECggICAAAAA==.',['娇妹']='娇妹:BAABLAAFFH8NAAQTAAYIniMwBgDZAQATAAYIbyMwBgDZAQAJAAQIrCHGPwA8AQAaAAIIwA2VEwCLAAAAAA==.',['娶了']='娶了疯婆娘:BAAALAADCggICAAAAA==.',['季博']='季博昌:BAAALAAECgUICQAAAA==.',['季波']='季波鋹:BAABLAAFFH8KAAIGAAII2RxKMgCpAAAGAAII2RxKMgCpAAAAAA==.',['孤独']='孤独相对论:BAAALAAFFAIIBAAAAA==.',['宁采']='宁采臣敢鈤鬼:BAAALAAFFAIIAgAAAA==.',['宇智']='宇智波牧:BAACLAAFFH8dAAIOAAQIfCXEEQBPAQAOAAQIfCXEEQBPAQAsAAQKf0MAAg4ACAjBJWkBAAIDAA4ACAjBJWkBAAIDAAAA.',['守护']='守护战:BAAALAADCgIIAgAAAA==.守护法:BAAALAAECgYICwAAAA==.守护猎:BAAALAAECgQICAAAAA==.',['宗成']='宗成风:BAAALAAECgUIBQAAAA==.',['客官']='客官不要跑:BAAALAAECgYIBgAAAA==.',['寂落']='寂落:BAAALAAECgUIBQAAAA==.',['寒冷']='寒冷的心:BAAALAAECgcIDQAAAA==.',['射倒']='射倒一片妞:BAAALAAECgYICwAAAA==.',['將丶']='將丶:BAACLAAFFH8JAAIGAAMIZBpgKAC5AAAGAAMIZBpgKAC5AAAsAAQKfyUAAwYACAgnGpsnAPYBAAYACAgnGpsnAPYBAA8AAQg3FMRCADsAAAAA.',['小丶']='小丶粉:BAAALAAECgYIDgAAAA==.',['小哥']='小哥哥来了:BAAALAADCgIIAgAAAA==.',['小啄']='小啄木鸟:BAAALAADCggICAAAAA==.',['小小']='小小阚彤彤:BAABLAAFFH8IAAMMAAYIqxvmGQC0AQAMAAYIqxvmGQC0AQALAAIIPwMEIQAmAAAAAA==.',['小木']='小木头的怒火:BAAALAAECgYIBgAAAA==.',['小灬']='小灬曼:BAACLAAFFH8GAAMCAAIIdBYVGQCbAAACAAIIdBYVGQCbAAABAAEIWQmSHgA8AAAsAAQKfx8AAwIABgi+IKMuALYBAAIABQjGHaMuALYBAAEABAh+GdASAOEAAAAA.',['小猫']='小猫猫丶:BAAALAAECgYIDAAAAA==.',['小珊']='小珊瑚:BAABLAAFFH8GAAIbAAIIJxFfAwCJAAAbAAIIJxFfAwCJAAAAAA==.',['小祈']='小祈的天然呆:BAABLAAFFH8GAAIDAAYIZw9gGwBQAQADAAYIZw9gGwBQAQAAAA==.',['小素']='小素士:BAAALAAECgYIBgAAAA==.',['小蕊']='小蕊:BAAALAAECgYIBwAAAA==.',['小雪']='小雪球:BAAALAAECgYIBgAAAA==.',['小马']='小马快走:BAAALAAECgIIAgAAAA==.',['尤瑟']='尤瑟夫卡:BAACLAAFFH8GAAMRAAIIqgkITACIAAARAAIIqgkITACIAAASAAEIJQH5MQAzAAAsAAQKfxoABBEABwg5G+gyAIABABEABwg5G+gyAIABABwAAgiYCz4vAHoAABIAAQgQGfCQAEYAAAAA.',['就是']='就是辣么帅:BAACLAAFFH8IAAIFAAII6R6IKQCxAAAFAAII6R6IKQCxAAAsAAQKfx4AAgUABwhEH5QuAFgCAAUABwhEH5QuAFgCAAEsAAUUAwgXAAsAOx4A.',['尼塔']='尼塔犸彼德:BAAALAAFFAIIAgAAAA==.尼塔玛格彼德:BAABLAAFFH8HAAIJAAMIxhThYQCJAAAJAAMIxhThYQCJAAAAAA==.尼塔蚂格彼德:BAABLAAFFH8FAAIJAAIIAhUmYgCXAAAJAAIIAhUmYgCXAAAAAA==.尼塔马格彼德:BAAALAAFFAQIBAAAAA==.',['屁屁']='屁屁臭死了:BAAALAADCgQIBgAAAA==.',['居小']='居小糗:BAAALAAFFAIIAgAAAA==.',['山哥']='山哥哥:BAAALAAECgYIBwAAAA==.',['岛屿']='岛屿幽忧:BAAALAAECgYIDAAAAA==.',['巴黎']='巴黎世家:BAABLAAFFH8IAAIKAAII2wfpcgB8AAAKAAII2wfpcgB8AAAAAA==.',['帅是']='帅是一辈子的:BAAALAAFFAIIAgAAAA==.',['帅逼']='帅逼:BAABLAAFFH8FAAIJAAMIzxG9TgDpAAAJAAMIzxG9TgDpAAAAAA==.',['师太']='师太周芷若:BAAALAADCgcIBwAAAA==.',['希拉']='希拉:BAAALAADCgYICQAAAA==.',['帝王']='帝王:BAAALAAECgYIDAAAAA==.',['幂之']='幂之脚:BAAALAAECgYIBgAAAA==.',['幸福']='幸福落幕:BAAALAADCggICAAAAA==.',['延迟']='延迟一百秒:BAAALAAFFAEIAQAAAA==.',['弑冰']='弑冰:BAAALAAECgYIBgAAAA==.',['张诺']='张诺妍:BAAALAAECgUIBwAAAA==.',['彦祖']='彦祖玩龙喷:BAACLAAFFH8aAAIJAAUIQR+qNQBlAQAJAAUIQR+qNQBlAQAsAAQKfxYAAgkABwgrIElPAFoCAAkABwgrIElPAFoCAAAA.',['影魂']='影魂无痕:BAABLAAFFH8TAAIGAAYIMQXgLQAXAQAGAAYIMQXgLQAXAQAAAA==.',['待到']='待到山花烂漫:BAAALAAFFAIIAgAAAA==.',['御命']='御命十三:BAAALAAECgQIBAAAAA==.',['御坂']='御坂丑琴:BAAALAAFFAIIAQABLAAFFAMIDgAMAIQfAA==.',['德苓']='德苓:BAABLAAFFH8PAAIEAAYInxpTDgCBAQAEAAYInxpTDgCBAQAAAA==.',['德菱']='德菱:BAABLAAFFH8SAAIEAAYIWR1jCwCqAQAEAAYIWR1jCwCqAQAAAA==.',['德過']='德過且不過:BAABLAAFFH8IAAIDAAIIZCAMLgCzAAADAAIIZCAMLgCzAAAAAA==.',['心若']='心若曦:BAAALAAECgYIBgAAAA==.',['心语']='心语芯愿:BAACLAAFFH8YAAILAAMI+Bz6CwCaAAALAAMI+Bz6CwCaAAAsAAQKfz0AAgsACAhGIlIDAL8CAAsACAhGIlIDAL8CAAAA.',['忄魔']='忄魔:BAAALAAECgYICgAAAA==.',['忘夜']='忘夜的星星:BAAALAAECggIDgAAAA==.',['怒风']='怒风之哀伤:BAAALAAECgIIAgAAAA==.',['悬河']='悬河泻火:BAAALAAECgUIBQAAAA==.',['惡靈']='惡靈戰警:BAAALAAFFAIIBAAAAA==.',['感受']='感受这啊:BAAALAAFFAIIAgAAAA==.',['慧长']='慧长的秋怡:BAAALAAFFAIIBAAAAA==.',['成都']='成都刘玄德:BAAALAAECgcIEAAAAA==.',['我真']='我真的受伤了:BAABLAAFFH8KAAMSAAIICRdsDgCoAAASAAIICRdsDgCoAAARAAEIqg5NXgBHAAAAAA==.',['我邪']='我邪故我在:BAAALAAECgIIAgAAAA==.',['战天']='战天使阿丽塔:BAABLAAFFH8QAAQIAAYIUxNqHACFAQAIAAYIUxNqHACFAQAdAAEIHx4qBABTAAAHAAIIcRxEJwBIAAAAAA==.',['把我']='把我气笑了:BAAALAAFFAIIAgAAAA==.',['折戟']='折戟釒:BAABLAAFFH8KAAIIAAIIHR3ALACiAAAIAAIIHR3ALACiAAAAAA==.',['拜月']='拜月:BAABLAAFFH8NAAIJAAUIoR/cNQBkAQAJAAUIoR/cNQBkAQAAAA==.',['按倒']='按倒狂亲:BAAALAAECgIIAgAAAA==.',['挨打']='挨打会喵喵叫:BAAALAAECgYIDQAAAA==.',['挽晚']='挽晚:BAAALAAECgQIBAAAAA==.',['捣之']='捣之棒棒糖:BAABLAAFFH8KAAIWAAIIkiA8OACfAAAWAAIIkiA8OACfAAAAAA==.',['捷捷']='捷捷丶:BAAALAADCgcIBwAAAA==.',['掐指']='掐指一算缺德:BAAALAAECgYIBgAAAA==.',['掱丷']='掱丷箐灬:BAAALAAECgYICAAAAA==.',['摄魂']='摄魂:BAABLAAFFH8KAAIWAAIIIQyIYwA8AAAWAAIIIQyIYwA8AAAAAA==.',['摇丨']='摇丨摆:BAAALAAECgYIBgAAAA==.',['摇摆']='摇摆:BAABLAAFFH8IAAIHAAIIDAglMAAzAAAHAAIIDAglMAAzAAAAAA==.',['斩妖']='斩妖丶泣血:BAACLAAFFH8FAAMFAAMIZwpuUgBqAAAFAAMIZwpuUgBqAAAZAAEIqwEWQQAwAAAsAAQKfx4AAwUACAjDGEs7AC0CAAUACAjDGEs7AC0CABkABwh8D19uAHEBAAAA.',['断桥']='断桥烟雨:BAABLAAFFH8IAAMMAAYIlBaiKABxAQAMAAYIlBaiKABxAQALAAIItQ5mEwCHAAAAAA==.',['新月']='新月千夜:BAAALAAECgYICQAAAA==.',['方沧']='方沧兰:BAAALAADCgMIAwAAAA==.',['无敌']='无敌半把蛋刀:BAAALAAECgYICgAAAA==.无敌在哪里:BAAALAAECgMIAwAAAA==.无敌幽冥之王:BAAALAAECgYIBgAAAA==.无敌是寂寞的:BAAALAAECgUIBQAAAA==.无敌法神:BAAALAAECgUIBQAAAA==.无敌神农氏:BAAALAAECgYICgAAAA==.无敌赵子龙:BAAALAAECgYIBgAAAA==.',['明镜']='明镜台:BAAALAADCgMIAwAAAA==.',['星澄']='星澄心成:BAABLAAFFH8GAAIFAAIIYxlYTACDAAAFAAIIYxlYTACDAAAAAA==.',['星火']='星火燎原:BAABLAAFFH8JAAINAAIINQI+RQBhAAANAAIINQI+RQBhAAAAAA==.',['星辰']='星辰契约:BAAALAAECgQIAgAAAA==.',['星镶']='星镶夜阑:BAAALAAFFAIIAgAAAA==.',['星马']='星马风:BAAALAADCgYIBgAAAA==.',['春天']='春天故事:BAABLAAFFH8XAAIGAAYIKx9fDADgAQAGAAYIKx9fDADgAQAAAA==.',['晓晨']='晓晨:BAAALAAECgEIAQAAAA==.',['晓杻']='晓杻:BAAALAAECgQIBAAAAA==.',['晓雪']='晓雪球:BAABLAAFFH8FAAIJAAUIUA8ESQATAQAJAAUIUA8ESQATAQAAAA==.',['晚安']='晚安灬哒哒:BAABLAAECn8cAAIDAAgI3xW1NwABAgADAAgI3xW1NwABAgAAAA==.',['暖暖']='暖暖的风:BAABLAAFFH8GAAIMAAYI1wxLLwBLAQAMAAYI1wxLLwBLAQAAAA==.',['暗夜']='暗夜骑士:BAABLAAFFH8LAAIJAAMIqRYpXACXAAAJAAMIqRYpXACXAAAAAA==.',['暗杀']='暗杀者:BAAALAAFFAIIAgAAAA==.',['暮色']='暮色小同学:BAABLAAFFH8GAAIGAAIIhhbPYABGAAAGAAIIhhbPYABGAAAAAA==.',['暴怒']='暴怒的恩赐:BAAALAADCgMIAwAAAA==.',['暴燥']='暴燥的企鹅:BAAALAAECgUIBQAAAA==.',['暴走']='暴走伤痕:BAABLAAFFH8JAAIMAAII2AsYWACIAAAMAAII2AsYWACIAAAAAA==.暴走的小机机:BAAALAAECgQIBAAAAA==.',['暴躁']='暴躁德:BAAALAAECgYIBgAAAA==.暴躁的咕咕徳:BAAALAAECgYICAAAAA==.',['最吊']='最吊骑士:BAAALAAECgUIBQAAAA==.',['月光']='月光半糖:BAAALAAECgYIEAAAAA==.',['月夜']='月夜小天:BAAALAAECgUIBQAAAA==.',['有个']='有个骑士:BAABLAAFFH8GAAIFAAYI6A6jIgBJAQAFAAYI6A6jIgBJAQAAAA==.',['有德']='有德沒德:BAABLAAFFH8MAAIDAAIIhxwhMgChAAADAAIIhxwhMgChAAAAAA==.',['朋克']='朋克丶小林夕:BAAALAADCgcIBwAAAA==.',['末丶']='末丶洛:BAABLAAFFH8PAAIGAAYIth98AwA7AgAGAAYIth98AwA7AgAAAA==.',['术师']='术师好混:BAAALAAECgYICAAAAA==.',['村头']='村头狗瘦子:BAAALAAFFAMIAwAAAA==.',['来一']='来一碗牛来福:BAAALAAFFAYIAgAAAA==.',['极夜']='极夜:BAAALAADCgUIBQAAAA==.',['枕枫']='枕枫丶:BAAALAAFFAQIAgAAAA==.',['枕沨']='枕沨丶:BAAALAAFFAIIAgAAAA==.',['林北']='林北吼里西:BAAALAAECgYIBgAAAA==.',['枫舞']='枫舞风相随:BAAALAAECgEIAQAAAA==.',['树使']='树使丶文:BAAALAADCgYIBgAAAA==.',['桂妮']='桂妮薇儿:BAAALAAECgUIBQAAAA==.',['桃小']='桃小花:BAAALAAFFAIIBAAAAA==.',['梅林']='梅林的父亲:BAAALAAFFAIIAgAAAA==.',['梦落']='梦落倾城:BAAALAADCgYIBgAAAA==.',['棒呆']='棒呆的一棵松:BAAALAAFFAIIAgAAAA==.',['椰子']='椰子爹地:BAAALAAFFAIIAgAAAA==.',['樱菁']='樱菁:BAABLAAFFH8KAAMFAAIIkxpYNQCWAAAFAAIIkxpYNQCWAAAZAAII2AtQTAA6AAAAAA==.',['橙吧']='橙吧:BAAALAADCgcICAAAAA==.',['欧皇']='欧皇中的欧皇:BAAALAAECgYIBgAAAA==.',['歌楚']='歌楚狂人:BAAALAAECgUIBQAAAA==.',['正義']='正義審判:BAABLAAFFH8KAAIGAAIIWhTePgCfAAAGAAIIWhTePgCfAAAAAA==.',['死亡']='死亡丨阴影:BAAALAADCggICAAAAA==.死亡之手:BAAALAAECgEIAQAAAA==.死亡琦士:BAABLAAFFH8KAAIKAAIIBhWxWwCOAAAKAAIIBhWxWwCOAAAAAA==.死亡的哈气:BAAALAAFFAIIAgAAAA==.',['死棒']='死棒吉鲍勃:BAAALAADCgMIAwAAAA==.',['毒瘤']='毒瘤蛋:BAAALAAECgcIBgAAAA==.',['毛概']='毛概要学好:BAACLAAFFH8TAAIJAAQILhHkUADYAAAJAAQILhHkUADYAAAsAAQKfywAAgkACAhLHTk5AJQCAAkACAhLHTk5AJQCAAAA.',['汉尼']='汉尼拔新月:BAAALAAECgcICQAAAA==.汉尼拔的新月:BAAALAADCgEIAQAAAA==.',['江南']='江南花满楼:BAAALAAECgYICAAAAA==.',['江風']='江風:BAAALAAECgYIBwAAAA==.',['沉睡']='沉睡的森林灬:BAAALAAFFAIIAgAAAA==.',['沐叁']='沐叁槍:BAACLAAFFH8GAAIKAAII6AohmgBBAAAKAAII6AohmgBBAAAsAAQKfyIAAgoACAiLH7kXAG4CAAoACAiLH7kXAG4CAAAA.',['沐瞳']='沐瞳:BAAALAAECgYIDgAAAA==.',['沐阳']='沐阳:BAACLAAFFH8IAAIDAAMIsgz6MgCdAAADAAMIsgz6MgCdAAAsAAQKfxYAAgMABwjIG1UVACcCAAMABwjIG1UVACcCAAAA.',['沙塔']='沙塔斯城主:BAAALAAECgUIBQAAAA==.',['没学']='没学开门:BAAALAAECgYIBgAAAA==.',['沧灬']='沧灬桑:BAAALAAECgcICwAAAA==.沧灬沧:BAAALAAECgYICgAAAA==.',['沸腾']='沸腾的咖啡:BAABLAAECn8cAAMDAAgI+g4/PAArAQADAAgI+g4/PAArAQAEAAUI+Q+GPgDBAAAAAA==.',['泰达']='泰达希尔之殇:BAAALAAECgUIBQAAAA==.',['洞庭']='洞庭湖老麻雀:BAAALAAECgcIBwAAAA==.',['流逝']='流逝随风:BAAALAAECgYIBgAAAA==.',['浓情']='浓情水煎包:BAAALAAFFAIIAgAAAA==.',['浩唧']='浩唧唧:BAAALAAECgYIDAAAAA==.',['海宝']='海宝宝灬:BAAALAAFFAIIAwABLAAFFAIIBwALAGsMAA==.',['海螺']='海螺里的风:BAAALAAECgYIBgAAAA==.',['涂山']='涂山弘弘:BAAALAAFFAIIAgAAAA==.',['深藏']='深藏的红颜:BAAALAAECgIIAgAAAA==.',['混沌']='混沌岁月:BAACLAAFFH8WAAMZAAUIawsKKAAFAQAZAAUIawsKKAAFAQAFAAMIQg47SwCGAAAsAAQKf0cAAgUACAgKG00TAFgCAAUACAgKG00TAFgCAAAA.',['添宝']='添宝:BAAALAAECgYICAAAAA==.',['清月']='清月無夢:BAAALAAFFAEIAQAAAA==.',['清蒸']='清蒸鹌鹑:BAAALAAECgYIBgAAAA==.',['渣渣']='渣渣輝:BAAALAAECgQIBAAAAA==.',['温柔']='温柔的坏男人:BAAALAAFFAIIBAAAAA==.',['温良']='温良:BAAALAAECgYIEQAAAA==.',['温蕾']='温蕾萨风行者:BAAALAAECgYIBwAAAA==.',['渴口']='渴口可乐:BAAALAAECgYICwAAAA==.',['滴滴']='滴滴清纯:BAAALAAECgYIBgAAAA==.滴滴香甜:BAAALAAECgYIBgAAAA==.',['潇影']='潇影:BAAALAAFFAYIBAAAAA==.',['潳戮']='潳戮成性:BAAALAAECgcIBwAAAA==.',['火根']='火根哩:BAAALAAECgUICAAAAA==.',['灬李']='灬李慕君灬:BAAALAAFFAIIAgABLAAFFAIIBgAFAGMZAA==.',['灬水']='灬水源:BAACLAAFFH8MAAIJAAII9Q/nggBEAAAJAAII9Q/nggBEAAAsAAQKfxUAAgkACAhZEQ84AJoBAAkACAhZEQ84AJoBAAAA.',['灬甲']='灬甲乙丙丁:BAACLAAFFH8LAAIIAAMI+A/lNgCXAAAIAAMI+A/lNgCXAAAsAAQKfxQAAggABwg9GB0wAJkBAAgABwg9GB0wAJkBAAAA.',['灭世']='灭世灬魔变:BAAALAAECgEIAQAAAA==.',['灵梦']='灵梦:BAAALAADCgYICwAAAA==.',['炮灰']='炮灰向前沖:BAABLAAECn8XAAIGAAcI6hlNUQBrAQAGAAcI6hlNUQBrAQAAAA==.',['烈焰']='烈焰凤凰:BAAALAAECgYIDAAAAA==.',['烈焱']='烈焱吞天:BAAALAAFFAIIAgAAAA==.',['烨雨']='烨雨星:BAAALAADCgYIBgAAAA==.',['烬如']='烬如灀:BAABLAAECn8fAAMJAAgI1SMRHwDzAgAJAAgI1SMRHwDzAgAaAAgICRQhIgCqAQAAAA==.',['热吻']='热吻幻魔:BAABLAAFFH8FAAIRAAIIeBBRSACNAAARAAIIeBBRSACNAAAAAA==.',['無铭']='無铭:BAAALAADCgcIBwAAAA==.',['焦炎']='焦炎小盆友:BAAALAAFFAIIAgAAAA==.',['熊猫']='熊猫喵喵:BAAALAAFFAIIAgAAAA==.',['牛牛']='牛牛的梦想:BAABLAAFFH8OAAIFAAIIuA30YQBZAAAFAAIIuA30YQBZAAAAAA==.',['牧小']='牧小影:BAAALAAFFAIIBAAAAA==.',['物尽']='物尽天择:BAABLAAFFH8JAAIFAAII5glAZgBUAAAFAAII5glAZgBUAAAAAA==.',['特米']='特米内崔克斯:BAAALAAECgYIBgAAAA==.',['犇犇']='犇犇丶犇:BAAALAAFFAQIBAAAAA==.',['狼豹']='狼豹熊鸟鹿:BAAALAADCgcIBwAAAA==.',['猫小']='猫小夜:BAAALAADCgYIBgAAAA==.',['玄英']='玄英其凛:BAABLAAFFH8NAAIIAAIIxB/rJgCrAAAIAAIIxB/rJgCrAAAAAA==.',['玉钤']='玉钤珑:BAABLAAECn8UAAIKAAgI2xIsWwCMAQAKAAgI2xIsWwCMAQAAAA==.',['玛丽']='玛丽昂:BAABLAAECn8hAAIDAAYI/wTOYgCTAAADAAYI/wTOYgCTAAAAAA==.',['玛斯']='玛斯特灬:BAAALAAECgYIBgAAAA==.',['玩个']='玩个防战吧:BAAALAAECgYICQAAAA==.',['玩火']='玩火玩大了:BAAALAAFFAIIAgAAAA==.',['玲珑']='玲珑醉心:BAABLAAFFH8IAAIeAAYImQu2EQAuAQAeAAYImQu2EQAuAQAAAA==.',['瑾彤']='瑾彤:BAAALAAECgYIBgAAAA==.',['瓦尔']='瓦尔纳灬:BAAALAAECgQIBAAAAA==.',['瓦特']='瓦特多拉贡:BAABLAAFFH8OAAINAAIImRBoOwBzAAANAAIImRBoOwBzAAAAAA==.',['疯狂']='疯狂熊霸王:BAABLAAFFH8GAAMDAAIIdxK0MgBvAAADAAIIdxK0MgBvAAAfAAIIDRlxDABOAAAAAA==.',['瘦猴']='瘦猴子:BAAALAAFFAIIBAAAAA==.',['白发']='白发加纹身:BAAALAAFFAMIAwAAAA==.',['白猫']='白猫殿下:BAAALAAECgYIEQAAAA==.',['白色']='白色惡魔:BAAALAAECgMIAwAAAA==.',['皇家']='皇家卡卡:BAAALAAECgcICQAAAA==.',['真的']='真的很猛:BAAALAAFFAIIAgAAAA==.真的很矮:BAAALAAECgYICQAAAA==.',['短巴']='短巴姬:BAAALAAECgYIDAAAAA==.',['神奇']='神奇女侠:BAAALAAFFAIIBAAAAA==.',['神封']='神封:BAABLAAECn8XAAIXAAgIERbWFgASAgAXAAgIERbWFgASAgAAAA==.',['秒人']='秒人缝:BAAALAAFFAIIAgAAAA==.',['程伊']='程伊安安:BAACLAAFFH8HAAMgAAMIJBDpDwCaAAAgAAMIJBDpDwCaAAAXAAIIkwSLGQBTAAAsAAQKfxUAAiAACAjgGcgHADQCACAACAjgGcgHADQCAAAA.',['稳住']='稳住别动:BAAALAAFFAIIAgAAAA==.',['第二']='第二序列:BAAALAAECgQICAAAAA==.',['簡單']='簡單隨意:BAAALAAECgYIEQAAAA==.',['米囡']='米囡:BAAALAAECgYIDAAAAA==.',['米迦']='米迦勒:BAAALAAECgYIBgAAAA==.',['粉小']='粉小满:BAAALAAECgcIEAAAAA==.粉小雨:BAAALAAECgEIAQAAAA==.',['粉色']='粉色忧郁:BAAALAAECgYIBgAAAA==.',['糖醋']='糖醋灬萝卜:BAAALAADCgUIBQAAAA==.糖醋皮蛋:BAABLAAFFH8GAAIGAAIIeg6/ZwBCAAAGAAIIeg6/ZwBCAAAAAA==.',['紅丨']='紅丨汆灬兔:BAAALAAECgYIBgAAAA==.',['素椒']='素椒杂酱面:BAAALAAFFAIIBAAAAA==.',['红枣']='红枣汤面:BAAALAAFFAgIAgAAAA==.',['红烧']='红烧菠萝:BAAALAAECgMIBAAAAA==.',['纯情']='纯情的小火球:BAABLAAFFH8GAAIKAAII8RBsdAB6AAAKAAII8RBsdAB6AAAAAA==.',['纱灬']='纱灬迦:BAAALAAECgYIBgAAAA==.',['绝嗲']='绝嗲小小弯:BAAALAAECgYIDwAAAA==.',['绯血']='绯血玉沙:BAAALAAECgYIBgAAAA==.',['缝氏']='缝氏之术:BAAALAAFFAIIAgAAAA==.缝氏之猎:BAABLAAFFH8IAAIKAAIIGRRYjwBFAAAKAAIIGRRYjwBFAAAAAA==.',['羅布']='羅布:BAAALAAECgIIAgAAAA==.羅布大师:BAABLAAFFH8MAAIFAAYIfRmoFAC7AQAFAAYIfRmoFAC7AQAAAA==.',['翾楸']='翾楸:BAAALAAECgYICQAAAA==.',['老兵']='老兵克林:BAABLAAFFH8jAAIGAAYI3RpxFACoAQAGAAYI3RpxFACoAQAAAA==.',['老灬']='老灬萨满:BAAALAAECgQIBAAAAA==.',['老花']='老花生:BAAALAAECgUIBQAAAA==.',['联盟']='联盟圣光领主:BAAALAAECgYIBgAAAA==.联盟战争领主:BAAALAAECggIDgAAAA==.联盟死亡领主:BAAALAAECgYIBgAAAA==.',['聖丶']='聖丶壁垒:BAABLAAFFH8KAAIGAAUI7hxDHgByAQAGAAUI7hxDHgByAQAAAA==.',['聖骑']='聖骑士:BAAALAADCgMIAwAAAA==.',['肥尸']='肥尸:BAAALAAECgYIBgAAAA==.',['胡子']='胡子像大树:BAAALAAECgYIBgAAAA==.',['胡德']='胡德禄:BAAALAAECgYIEgAAAA==.',['胧夜']='胧夜:BAABLAAECn8XAAINAAcIMg/EXgBhAQANAAcIMg/EXgBhAQAAAA==.',['腹黑']='腹黑的喵星人:BAAALAAECggIDgAAAA==.',['至暗']='至暗之光:BAAALAAECgYICgAAAA==.',['舆世']='舆世界为敌:BAABLAAFFH8FAAIIAAUI8wsTKgAbAQAIAAUI8wsTKgAbAQAAAA==.',['舞动']='舞动在指尖:BAAALAADCggIDQAAAA==.',['艾蕾']='艾蕾什基伽尔:BAAALAAECgYIBgAAAA==.',['芊沫']='芊沫:BAAALAAECggICAAAAA==.',['芒果']='芒果酱宝贝:BAAALAAECgYIBgAAAA==.',['苏墨']='苏墨丶:BAABLAAECn8XAAIJAAYIBQhkigDUAAAJAAYIBQhkigDUAAAAAA==.',['苏小']='苏小妹:BAAALAAECgUIBQAAAA==.',['若熙']='若熙灬若熙:BAAALAAECggIDgAAAA==.',['茅山']='茅山道法天师:BAAALAADCgEIAQAAAA==.',['莉亚']='莉亚娜:BAAALAAECgYICwAAAA==.',['莉莉']='莉莉:BAABLAAFFH8GAAIJAAII3hxyTACkAAAJAAII3hxyTACkAAAAAA==.',['莫小']='莫小吖:BAAALAAECgMIBAAAAA==.莫小德:BAAALAAECgQIBAAAAA==.',['菜鸟']='菜鸟新手:BAACLAAFFH8QAAMRAAUIzBBXNwAxAQARAAUIzBBXNwAxAQASAAEINAO3GQAsAAAsAAQKfxcAAxEACAgYHXwRAFwCABEACAgYHXwRAFwCABIABgh7BLIkAK0AAAAA.',['萌丨']='萌丨点滴:BAAALAAECgYIBgAAAA==.',['萌萌']='萌萌的天宫德:BAABLAAECn8dAAMDAAgIAg1pVQDAAAADAAYI6glpVQDAAAAEAAIIcweMWwBIAAAAAA==.',['萤流']='萤流夏夜月:BAAALAAECgYIEQAAAA==.',['萨格']='萨格拉罗斯:BAAALAAECgIIAgAAAA==.',['萨灬']='萨灬满:BAAALAAECgYICAAAAA==.',['萨鲁']='萨鲁安都灵:BAAALAADCggICAAAAA==.',['落霜']='落霜:BAACLAAFFH8GAAIJAAIIFCBkNwDDAAAJAAIIFCBkNwDDAAAsAAQKfxQAAgkACAhWJjINAEADAAkACAhWJjINAEADAAEsAAUUAggIAAYAGhsA.',['董卓']='董卓:BAAALAAFFAIIAgAAAA==.',['蓝灵']='蓝灵落:BAAALAAECgEIAQAAAA==.',['蓝色']='蓝色妖姬:BAAALAAECgUIBQAAAA==.',['蓝调']='蓝调咖啡:BAAALAAECgQIBQAAAA==.',['蕝版']='蕝版尛妖籹:BAAALAAECgYIBgAAAA==.',['藤尤']='藤尤立香:BAAALAAECgcIBwAAAA==.',['蛇神']='蛇神:BAAALAAECgYICgAAAA==.',['蛋只']='蛋只有一粒:BAAALAAFFAIIBAAAAA==.',['蜘狩']='蜘狩遮天:BAAALAAECgMIAwAAAA==.',['蜡笔']='蜡笔猪小呆:BAABLAAFFH8NAAIIAAMIZxNtOQCNAAAIAAMIZxNtOQCNAAABLAAFFAgIBgAIAJYbAA==.',['血祭']='血祭丶文:BAAALAADCgUIBQAAAA==.',['街角']='街角华尔兹:BAAALAAFFAIIAgAAAA==.街角暧昧:BAAALAAFFAIIAgAAAA==.',['衣锐']='衣锐尔:BAAALAAECgYIBgAAAA==.',['西乡']='西乡吴彦祖啊:BAAALAADCgUIBQAAAA==.',['西庇']='西庇阿鹤翼:BAAALAAECgEIAQAAAA==.',['要你']='要你命三千:BAAALAAECgYIBgAAAA==.',['见死']='见死不救啊:BAACLAAFFH8aAAMhAAYIBRyiCwCVAQAhAAUIgRuiCwCVAQAiAAQIqwqUFAC4AAAsAAQKfyEAAiEACAiYGt8QACICACEACAiYGt8QACICAAAA.',['訫鐩']='訫鐩楓影:BAAALAAECgYICgAAAA==.',['誮訫']='誮訫囖啵:BAABLAAFFH8LAAIJAAUI1w+uRwAbAQAJAAUI1w+uRwAbAQAAAA==.',['諸葛']='諸葛云天:BAAALAAFFAIIAgAAAA==.諸葛流雲:BAACLAAFFH8LAAIJAAUI2Q09SAAYAQAJAAUI2Q09SAAYAQAsAAQKfxkAAwkABgg+GdZwAA0BAAkABgiMGNZwAA0BABoAAwgbFCkbAIQAAAAA.諸葛雲天:BAACLAAFFH8PAAMRAAUINAo0PwD9AAARAAUINAo0PwD9AAASAAII0AbQFwA6AAAsAAQKfxYAAxIABghzFEI7AH8BABIABgh+EkI7AH8BABEABgh/DxaTAFcBAAAA.諸葛鴻鈞:BAACLAAFFH8UAAINAAUItQ3PIQA2AQANAAUItQ3PIQA2AQAsAAQKfyAAAg0ABwg7EJ4vAEEBAA0ABwg7EJ4vAEEBAAAA.',['许我']='许我再少年:BAAALAAECgcIBwAAAA==.',['误导']='误导毁灭术:BAAALAADCgMIAwAAAA==.',['诸葛']='诸葛天涯:BAABLAAFFH8UAAMMAAUIiRAhNQAmAQAMAAUIiRAhNQAmAQALAAIICgI1IQAjAAAAAA==.',['谪仙']='谪仙:BAACLAAFFH8IAAIKAAIIkRysVACTAAAKAAIIkRysVACTAAAsAAQKfycAAgoACAhOHXQvAJsCAAoACAhOHXQvAJsCAAAA.',['败者']='败者食尘:BAAALAAFFAIIBAAAAA==.',['贰零']='贰零零:BAAALAAFFAIIBAAAAA==.',['赎罪']='赎罪者卢克:BAAALAADCggICAABLAAFFAgIAgAjAAAAAA==.',['赵乐']='赵乐意:BAAALAADCgMIAwAAAA==.',['赵神']='赵神经:BAAALAAECgYIBgAAAA==.',['赵精']='赵精神:BAAALAAECgcIBwAAAA==.',['越谷']='越谷小鞠:BAABLAAFFH8OAAIMAAMIhB8EMADMAAAMAAMIhB8EMADMAAAAAA==.',['跪求']='跪求一摸:BAAALAAECgYIBgAAAA==.',['踏岚']='踏岚风:BAABLAAFFH8FAAMeAAQImg1CGgBtAAAgAAIIuAWfFgB3AAAeAAMIhw9CGgBtAAAAAA==.',['身体']='身体被掏空:BAAALAADCgEIAQAAAA==.',['辰夢']='辰夢相依:BAAALAAECgQIBAAAAA==.',['近战']='近战法尸:BAAALAADCgYIBgAAAA==.',['逆戰']='逆戰灬兲漄:BAAALAAECggICwAAAA==.',['遁影']='遁影寻猎:BAAALAAECgYIBwAAAA==.',['邪能']='邪能鸡柳:BAABLAAFFH8GAAIJAAYIxRyeKwCKAQAJAAYIxRyeKwCKAQAAAA==.',['酒神']='酒神咖啡:BAAALAAECgIIAwAAAA==.',['醉酒']='醉酒一胜:BAAALAAECgYIBgAAAA==.',['醪糟']='醪糟蛋:BAAALAAFFAIIBAAAAA==.',['里昂']='里昂妮丝:BAABLAAFFH8JAAIKAAMIVRbciwBHAAAKAAMIVRbciwBHAAABLAAFFAYIIwAWAD0iAA==.',['重装']='重装南瓜:BAAALAAECgIIAgAAAA==.',['野猪']='野猪大胖:BAAALAADCgEIAQAAAA==.',['闪光']='闪光的夜囡囡:BAAALAAFFAIIAwAAAA==.',['闲庭']='闲庭信步:BAAALAAECggICAABLAAFFAgICAAMAMQcAA==.',['阚疃']='阚疃:BAAALAADCgYIBgAAAA==.',['阿克']='阿克萌德丶:BAAALAAFFAIIBAAAAA==.',['阿拉']='阿拉灬贡:BAAALAADCgMIAwAAAA==.',['陈程']='陈程:BAAALAAECgQIBAAAAA==.',['雨兮']='雨兮:BAAALAAECgYIAgAAAA==.',['雪莉']='雪莉娅:BAAALAAECgYICwABLAAFFAYIIwAWAD0iAA==.',['雷尐']='雷尐丘孑:BAAALAAECgEIAQAAAA==.',['露小']='露小缝:BAABLAAFFH8GAAIGAAIIQxNKYABGAAAGAAIIQxNKYABGAAAAAA==.',['露易']='露易絲丶萊恩:BAAALAAECgYIDQAAAA==.',['霸皇']='霸皇:BAAALAAECgUIBQAAAA==.',['霸道']='霸道天子:BAAALAAECgYICgAAAA==.',['青岚']='青岚丶:BAAALAAECgMIAwAAAA==.',['静谧']='静谧火花:BAACLAAFFH8GAAIKAAYIJQ87QQBDAQAKAAYIJQ87QQBDAQAsAAQKfxkABCQACAhYILEEAKECACQACAinH7EEAKECAAoABgjZHAOTAL8BABAABgieD6d2APgAAAAA.',['静赏']='静赏花落:BAAALAAFFAEIAQAAAA==.',['风吹']='风吹日晒:BAAALAAECgIIAgAAAA==.',['风精']='风精之羽:BAABLAAFFH8LAAIaAAYIVA8bBAB2AQAaAAYIVA8bBAB2AQAAAA==.风精恶魔:BAAALAAFFAIIAgAAAA==.',['飞天']='飞天小小妞:BAAALAAECgIIAgAAAA==.',['香香']='香香丶狐宝宝:BAAALAAFFAEIAQAAAA==.香香丶虎宝宝:BAAALAAFFAIIAgAAAA==.香香丶鹌鹑宝:BAAALAAECgIIAgAAAA==.',['高岭']='高岭爱花:BAAALAAECgYIDQAAAA==.',['鬼丶']='鬼丶父:BAAALAADCgUIDAAAAA==.',['鬼神']='鬼神刻瑞斯:BAABLAAFFH8GAAIGAAIIxwmPVwCKAAAGAAIIxwmPVwCKAAAAAA==.',['鱼水']='鱼水游:BAAALAAECgUIBQAAAA==.',['鲁啊']='鲁啊鲁:BAAALAAFFAIIAgAAAA==.',['鸡脖']='鸡脖昌:BAAALAADCgIIAgAAAA==.',['鸳鸳']='鸳鸳相抱:BAACLAAFFH8dAAIeAAQIGwhAGACVAAAeAAQIGwhAGACVAAAsAAQKfysAAh4ACAhjFOYMAHgBAB4ACAhjFOYMAHgBAAAA.',['麦兜']='麦兜:BAAALAAECgYIBgAAAA==.',['黄佳']='黄佳侣:BAABLAAFFH8IAAIKAAIIQw8bogA9AAAKAAIIQw8bogA9AAAAAA==.',['黄色']='黄色与艺术:BAACLAAFFH8KAAIHAAII+xgPGQCUAAAHAAII+xgPGQCUAAAsAAQKfxoAAwcABggPJIobAFUCAAcABggPI4obAFUCAAgABghoIbkhAOMBAAAA.',['黄道']='黄道十一宫:BAAALAAFFAIIBAAAAA==.黄道十三宫:BAAALAAECgcIBwAAAA==.黄道十二宫:BAAALAAECgIIAgAAAA==.',['黑夜']='黑夜传奇:BAAALAAFFAIIAgAAAA==.',['黑灬']='黑灬胡子:BAAALAAECgIIAgAAAA==.',['黑的']='黑的黑人:BAAALAADCgQIBAAAAA==.',['黯狱']='黯狱:BAAALAAECggICgAAAA==.',['齐公']='齐公子:BAAALAAECgYIBgAAAA==.',['齐木']='齐木楠雄:BAAALAAECgYICgAAAA==.',['龙玺']='龙玺儿:BAAALAAECgYIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end