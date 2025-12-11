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
 local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','Warrior-Fury','Mage-Arcane','DeathKnight-Blood','DemonHunter-Vengeance','DemonHunter-Havoc','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','Hunter-BeastMastery','Shaman-Restoration','Paladin-Holy','Paladin-Retribution','Paladin-Protection','Warrior-Protection','Hunter-Marksmanship','Mage-Frost','Shaman-Elemental','Warrior-Arms','Mage-Fire','Priest-Holy','Druid-Feral','Warlock-Destruction','Druid-Restoration','Warlock-Demonology','Monk-Brewmaster','Monk-Mistweaver','Monk-Windwalker','Druid-Balance','Evoker-Preservation','Priest-Discipline','Warlock-Affliction','Unknown-Unknown','Hunter-Survival',}; local provider = {region='CN',realm='提尔之手',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ab='Abolianlina:BAAALAAFFAIIBAAAAA==.',Al='Alexanderamy:BAACLAAFFH8MAAIBAAMIIBMYRQCsAAABAAMIIBMYRQCsAAAsAAQKfycAAwEACAhGIFwOAHsCAAEACAhGIFwOAHsCAAIABAglDcZDAL8AAAAA.Alexia:BAAALAAECggICAAAAA==.',Ba='Baga:BAACLAAFFH8vAAIDAAgIBhhnBwBIAgADAAgIBhhnBwBIAgAsAAQKfzgAAgMACAhRIvMPAGwCAAMACAhRIvMPAGwCAAAA.',Ca='Candycoco:BAABLAAFFH8KAAIEAAIIgAxAUgCPAAAEAAIIgAxAUgCPAAAAAA==.Carolpeletie:BAAALAAFFAIIBAAAAA==.',Ci='Cirilla:BAAALAAECgYIEQAAAA==.',Cl='Cleinmoretti:BAABLAAFFH8XAAIBAAYIlx+tGgDMAQABAAYIlx+tGgDMAQAAAA==.',Co='Coincidence:BAAALAAECgQIBAAAAA==.Cokotta:BAAALAAECgYIBgAAAA==.',Cy='Cynthia:BAABLAAFFH8HAAIFAAcIfwVXCwBZAQAFAAcIfwVXCwBZAQAAAA==.',Dh='Dhwaltz:BAACLAAFFH8UAAMGAAYIbA7uBgALAQAGAAYI2A3uBgALAQAHAAEI4giHTQBLAAAsAAQKfyYAAwYACAhdF1EdANIBAAYACAhDF1EdANIBAAcABAhfEQz4APgAAAAA.',Di='Diamond:BAAALAAECgcIEgAAAA==.Disappeared:BAABLAAFFH8IAAIBAAMI8RH8XACaAAABAAMI8RH8XACaAAAAAA==.',Do='Doubble:BAAALAAECgMIAgAAAA==.',Dr='Dracarys:BAAALAAFFAIIBAAAAA==.',El='Ellen:BAAALAAFFAQIBAAAAA==.',Fi='Firewaltz:BAABLAAFFH8TAAIEAAYIKhb1IQCOAQAEAAYIKhb1IQCOAQAAAA==.',Fu='Fumahavoc:BAAALAAFFAIIBAAAAA==.',Gh='Ghost:BAABLAAFFH8GAAIHAAIIVBCDUgBHAAAHAAIIVBCDUgBHAAAAAA==.',Ho='Holdsun:BAAALAADCgMIAwAAAA==.',Im='Imalive:BAAALAAFFAIIAgAAAA==.Imarogue:BAAALAADCgcIBwAAAA==.Imfine:BAAALAADCgYIBgAAAA==.',Ka='Kayw:BAABLAAFFH8fAAMBAAYIfBovPABKAQABAAYIfBovPABKAQAFAAIIfQ73EACBAAAAAA==.',Kd='Kderboys:BAAALAAECgIIAgAAAA==.',Ko='Kopiluwha:BAABLAAFFH8OAAQIAAUITRCmCQASAQAIAAUIGwymCQASAQAJAAMIgBB9FACfAAAKAAIIDhDnBACWAAABLAAFFAcINQALABkhAA==.',Li='Liesbey:BAAALAAECgYIBgAAAA==.Liesboy:BAAALAAECggIEQAAAA==.',Lu='Luxaky:BAAALAAFFAEIAQAAAA==.',Mi='Miraitowa:BAAALAAECgIIAgAAAA==.',Mo='Monk:BAAALAAECgYIBgABLAAFFAMIGwAMAGASAA==.',No='Noisy:BAABLAAFFH8NAAINAAUIqQwBGwDYAAANAAUIqQwBGwDYAAAAAA==.',Oo='Ooningoo:BAABLAAFFH8jAAMOAAYI9CKPCAAFAgAOAAYI9CKPCAAFAgAPAAEILhYZJgAAAAABLAAFFAcINQALABkhAA==.',Os='Ostrudy:BAAALAAECgIIAgAAAA==.',Ou='Ou:BAAALAADCgQIBAAAAA==.',Oz='Ozakii:BAAALAAFFAIIBAAAAA==.',Pl='Playeropmzlj:BAAALAAFFAIIAgAAAA==.Playerpussbp:BAAALAAECgcIDQAAAA==.',Pw='Pwp:BAAALAAECgMIAwAAAA==.',Qs='Qswaltz:BAABLAAFFH8WAAIPAAYIsxYtBwBWAQAPAAYIsxYtBwBWAQAAAA==.',Qu='Quinlan:BAAALAAFFAEIAQAAAA==.',Rh='Rhythmic:BAABLAAFFH8IAAIBAAIIMiKqOgC8AAABAAIIMiKqOgC8AAAAAA==.',Se='Serven:BAAALAAECgIIAgAAAA==.',Sh='Shinoda:BAAALAADCgUIBQAAAA==.',Si='Silenttnight:BAABLAAFFH8MAAIBAAIItyF8PAC5AAABAAIItyF8PAC5AAAAAA==.',Sl='Slang:BAAALAADCggICAAAAA==.',So='Sore:BAAALAAECgQIBQAAAA==.',St='Stellarsea:BAABLAAFFH8IAAMDAAYI5SMzAwBvAgADAAYI5SMzAwBvAgAQAAIIlQjNLQA2AAABLAAFFAgIDAADACoMAA==.',Ta='Taily:BAABLAAFFH8FAAIBAAIITg0uigBBAAABAAIITg0uigBBAAAAAA==.',Te='Teny:BAACLAAFFH8IAAILAAQIbg+EYQC2AAALAAQIbg+EYQC2AAAsAAQKfyMAAwsABwj1IAJNAKsBABEABgjgHqw0AOwBAAsABwgCIAJNAKsBAAAA.',Th='Thebrutalt:BAAALAAECgYIBwAAAA==.',To='Tomoyo:BAAALAADCgUIAwAAAA==.Toyly:BAAALAAFFAYIAgAAAA==.',['一双']='一双大白兔:BAABLAAFFH8IAAILAAMIgQw8cQB/AAALAAMIgQw8cQB/AAAAAA==.',['一只']='一只酸奶牛:BAAALAAECgMIAwAAAA==.',['一对']='一对儿大白兔:BAAALAAECgYICAAAAA==.',['一抹']='一抹天蓝色:BAACLAAFFH8YAAISAAYIDBwuBACTAQASAAYIDBwuBACTAQAsAAQKfyAAAhIACAjBI7cGACgDABIACAjBI7cGACgDAAAA.',['一楽']='一楽拉面:BAAALAAECgIIAgAAAA==.',['一点']='一点点:BAAALAAECgIIAgAAAA==.',['万象']='万象更新:BAAALAAECgYICwAAAA==.',['三十']='三十六帝飞机:BAABLAAFFH8oAAMMAAYIJxjoFgCnAQAMAAYIJxjoFgCnAQATAAUIgxdHHgBPAQABLAAFFAcINQALABkhAA==.',['三年']='三年:BAAALAAECgYIBgAAAA==.',['三鹿']='三鹿请安:BAAALAAECgYIDgAAAA==.',['上校']='上校:BAABLAAFFH8YAAIBAAUIkwkDTAD+AAABAAUIkwkDTAD+AAAAAA==.',['不万']='不万能的青年:BAACLAAFFH8XAAIDAAYIcSRODAD5AQADAAYIcSRODAD5AQAsAAQKfyEAAwMACAg1IxgTABQDAAMACAg1IxgTABQDABQAAQiuJKUyAGUAAAAA.',['丨某']='丨某个椛间丨:BAAALAAFFAIIBAAAAA==.丨某个莳间丨:BAABLAAFFH8IAAMEAAYIFwUsQACrAAAEAAQI8gQsQACrAAAVAAIIYgWODABFAAAAAA==.',['丨棄']='丨棄天帝丨:BAAALAAFFAIIBAAAAA==.',['丨素']='丨素还真丨:BAACLAAFFH8cAAIBAAYIgB1yIwCmAQABAAYIgB1yIwCmAQAsAAQKfxsAAgEACAi1IF05AJQCAAEACAi1IF05AJQCAAAA.',['丶楪']='丶楪祈:BAABLAAFFH8GAAILAAUIeAxuZgCcAAALAAUIeAxuZgCcAAABLAAFFAYIFQAHAOkSAA==.',['主力']='主力治疗:BAABLAAFFH8FAAIWAAMIDgStNQCOAAAWAAMIDgStNQCOAAAAAA==.',['丿小']='丿小灬橘子:BAABLAAFFH8GAAIMAAIIrgW/ZgBaAAAMAAIIrgW/ZgBaAAAAAA==.',['乄起']='乄起风了:BAACLAAFFH8VAAIHAAYI6RLyIgBxAQAHAAYI6RLyIgBxAQAsAAQKfxsAAgcACAjtIAEkANACAAcACAjtIAEkANACAAAA.',['九天']='九天揽月:BAAALAADCgIIAgAAAA==.',['二龙']='二龙湖商葛:BAABLAAFFH8GAAILAAYIEwEXiwBHAAALAAYIEwEXiwBHAAAAAA==.',['云泽']='云泽:BAAALAAECgcICgAAAA==.',['五德']='五德充沛:BAABLAAFFH8HAAINAAIINhQgIwCKAAANAAIINhQgIwCKAAAAAA==.',['五晨']='五晨寺炎掌门:BAAALAAECgUIBwAAAA==.',['五爱']='五爱市场:BAAALAAECgUIBQAAAA==.',['亚夏']='亚夏拉:BAAALAAECggICAAAAA==.',['京基']='京基一百:BAAALAAECgIIAgAAAA==.',['亵渎']='亵渎杀戮:BAAALAAECgcIBwAAAA==.',['人造']='人造兔十八号:BAABLAAFFH8GAAIXAAIIjwndDwA6AAAXAAIIjwndDwA6AAABLAAFFAYIGQALADQRAA==.',['仿若']='仿若暮夏:BAABLAAFFH8GAAILAAIIlA2FYwCJAAALAAIIlA2FYwCJAAAAAA==.',['佚名']='佚名翼:BAAALAAECgYIDQAAAA==.',['佛罗']='佛罗伦娜:BAAALAADCgMIAwAAAA==.',['你不']='你不怕大雨吗:BAAALAAECgYIDwABLAAFFAcINQALABkhAA==.',['修仙']='修仙地板王:BAABLAAFFH8GAAIOAAII9A01awBBAAAOAAII9A01awBBAAAAAA==.',['兔子']='兔子啃骨头:BAABLAAFFH8GAAISAAIItxMHGAA/AAASAAIItxMHGAA/AAABLAAFFAYIGQALADQRAA==.',['兔本']='兔本无情:BAABLAAFFH8QAAIOAAQINQ6iYgBFAAAOAAQINQ6iYgBFAAABLAAFFAYIGQALADQRAA==.',['兔维']='兔维斯:BAAALAAECgYIBgAAAA==.',['六元']='六元梦七:BAAALAADCgMIAwAAAA==.',['再见']='再见了青春:BAAALAADCgIIAgAAAA==.',['冬天']='冬天的兔子:BAABLAAFFH8ZAAILAAYINBH9PABQAQALAAYINBH9PABQAQAAAA==.',['冰峰']='冰峰零度:BAABLAAFFH8LAAIYAAYISRa/DAAJAgAYAAYISRa/DAAJAgAAAA==.',['冰美']='冰美式:BAABLAAFFH8MAAIBAAIIyg+SdACOAAABAAIIyg+SdACOAAAAAA==.',['冷淡']='冷淡的英雄:BAABLAAFFH8gAAILAAUI2xOPTgATAQALAAUI2xOPTgATAQAAAA==.',['冷酷']='冷酷幻:BAAALAADCgUIBQAAAA==.',['凨雲']='凨雲劣人:BAAALAAECgQIBwAAAA==.凨雲墓师:BAAALAAECgYIDAAAAA==.凨雲小战:BAAALAAECgYICAAAAA==.凨雲术丝:BAAALAAECgYIDAAAAA==.凨雲武僧:BAAALAAECgYICAAAAA==.凨雲法丝:BAAALAAECgYIEQAAAA==.凨雲洒满:BAAALAAECgYIBgAAAA==.凨雲骑士:BAAALAAECgQIBAAAAA==.',['刺客']='刺客信仰:BAABLAAFFH8GAAIJAAYIZQC+IAAMAAAJAAYIZQC+IAAMAAAAAA==.',['勤受']='勤受:BAAALAAECgYIDQAAAA==.',['北极']='北极牛:BAAALAADCgQIBAAAAA==.',['十八']='十八坡战神:BAAALAAECgEIAQAAAA==.',['半盏']='半盏观山海:BAABLAAFFH8RAAIZAAUIQA2HHwAmAQAZAAUIQA2HHwAmAQABLAAFFAYIFwATALoCAA==.',['去吧']='去吧皮卡丘:BAAALAAECgEIAQAAAA==.',['叁横']='叁横壹竖:BAAALAAECgYIBgAAAA==.',['双榆']='双榆树:BAAALAADCgEIAQAAAA==.',['变形']='变形叮当:BAAALAAECggICAAAAA==.',['古琪']='古琪:BAAALAAECgYIDQAAAA==.',['只剑']='只剑截江流:BAABLAAFFH8LAAMBAAUIywZ6VwCoAAABAAQI9gd6VwCoAAAFAAMINAKMFwBMAAABLAAFFAYIFwATALoCAA==.',['叫我']='叫我莫莫:BAABLAAFFH8dAAMaAAUIZRUICgB+AAAYAAUIuxQdNABDAQAaAAMIxxMICgB+AAAAAA==.',['吃不']='吃不饱兜着走:BAAALAAECgYIDQAAAA==.',['后门']='后门口扛把子:BAAALAAECgIIAwAAAA==.',['吓人']='吓人的犬夜叉:BAACLAAFFH8IAAILAAIInBLzUgCUAAALAAIInBLzUgCUAAAsAAQKfxkAAxEABwg2Fy5vAA4BABEABAjHGC5vAA4BAAsABgjuFHAbAQkBAAAA.',['命运']='命运萌萌:BAACLAAFFH8OAAMIAAMIkRt+CQAEAQAIAAMIlBd+CQAEAQAJAAMIMhdwFgCkAAAsAAQKfxwAAwgACAgPHQMSACECAAgABwhnHAMSACECAAkABwhQG24hAAwCAAAA.',['咕噜']='咕噜咕噜圆:BAACLAAFFH8gAAIbAAYIhhnBDAB5AQAbAAYIhhnBDAB5AQAsAAQKfyQABBsACAiVHA0QAFgCABsACAgwHA0QAFgCABwABgg7FUMTAG0BAB0AAwhFE5QwAG0AAAAA.咕噜圆:BAAALAADCggICAAAAA==.',['咖喱']='咖喱给给:BAAALAAFFAQIAgAAAA==.',['品茶']='品茶:BAAALAAECgUIBQAAAA==.',['哈力']='哈力克:BAABLAAFFH8GAAIEAAIIhgSrYgA5AAAEAAIIhgSrYgA5AAAAAA==.',['哈士']='哈士奇大帝:BAABLAAFFH8VAAIQAAYICA+hEgAvAQAQAAYICA+hEgAvAQABLAAFFAYIFwATALoCAA==.',['唤魔']='唤魔师:BAABLAAFFH8HAAIEAAMIFg3JSAB9AAAEAAMIFg3JSAB9AAAAAA==.',['啦啦']='啦啦呀:BAACLAAFFH8OAAIcAAQICRBgDgDsAAAcAAQICRBgDgDsAAAsAAQKfxgAAhwABgjtE4IWADwBABwABgjtE4IWADwBAAAA.',['啾啾']='啾啾风行者:BAABLAAFFH8KAAILAAUIQxB0TwAQAQALAAUIQxB0TwAQAQAAAA==.',['喵喵']='喵喵小猎:BAAALAAECgYIBgAAAA==.喵喵果果:BAAALAAECgYIDAAAAA==.喵喵萨:BAAALAAECgYICgAAAA==.喵喵骑:BAAALAAECgQIBAAAAA==.',['嚣张']='嚣张不解释:BAABLAAFFH8IAAIMAAIIISLfOAC/AAAMAAIIISLfOAC/AAAAAA==.',['困卡']='困卡:BAAALAAECgYIEAAAAA==.',['土土']='土土:BAAALAAECgYICAAAAA==.',['土豆']='土豆片:BAABLAAFFH8GAAIHAAYIow3jJQBgAQAHAAYIow3jJQBgAQAAAA==.',['圣光']='圣光丶哀沐涕:BAAALAAECgYIBgAAAA==.圣光曼巴:BAAALAAECgYIBgAAAA==.',['圣骑']='圣骑小拉丁:BAAALAADCggICQAAAA==.圣骑我最拽:BAAALAAECgYICQAAAA==.',['埃文']='埃文塔多:BAABLAAFFH8GAAIBAAIItwnylAA8AAABAAIItwnylAA8AAAAAA==.',['基尔']='基尔加丹:BAABLAAFFH8MAAIZAAYIERExFgCDAQAZAAYIERExFgCDAQAAAA==.',['夏夜']='夏夜微凉:BAAALAADCgEIAQAAAA==.',['夏天']='夏天的茶叶:BAACLAAFFH8MAAIOAAMIYRH4RgB+AAAOAAMIYRH4RgB+AAAsAAQKfxoAAg4ABgjhGO6sAKMBAA4ABgjhGO6sAKMBAAAA.',['夏赛']='夏赛赛:BAAALAAFFAgIBAAAAA==.',['夕无']='夕无霜:BAAALAADCgIIAgAAAA==.',['夜小']='夜小夕:BAABLAAFFH8GAAIOAAYIjwCCgwAgAAAOAAYIjwCCgwAgAAAAAA==.',['大尾']='大尾巴鱼:BAABLAAFFH8qAAIYAAUICBs9MABXAQAYAAUICBs9MABXAQAAAA==.',['大滋']='大滋水枪:BAABLAAFFH8iAAIOAAYI1yLPCwDmAQAOAAYI1yLPCwDmAQAAAA==.',['天堂']='天堂光光:BAAALAAECgEIAQAAAA==.天堂在左:BAABLAAFFH8MAAMDAAIIyxkPLQCiAAADAAIIyxkPLQCiAAAQAAII5Q3MLwAzAAAAAA==.',['头昏']='头昏昏:BAABLAAECn8UAAIZAAgICBK2MgBcAQAZAAgICBK2MgBcAQAAAA==.',['奥斯']='奥斯吉拉迪:BAAALAADCgEIAQAAAA==.',['好有']='好有型:BAAALAAECgIIAgAAAA==.',['如是']='如是自来也:BAACLAAFFH8fAAMZAAcIZhTTDgDTAQAZAAcIZhTTDgDTAQAeAAMIowtTKAByAAAsAAQKfyQAAxkACAizHiwTAMICABkACAizHiwTAMICAB4ABQh7ECpBALYAAAAA.',['妈妈']='妈妈:BAABLAAFFH8TAAIWAAgIRR7IAgDLAgAWAAgIRR7IAgDLAgAAAA==.',['姗蒂']='姗蒂斯羽月:BAAALAADCgcIBwAAAA==.',['实在']='实在是小:BAABLAAECn8gAAIDAAgIwRdyMQCUAQADAAgIwRdyMQCUAQAAAA==.',['审判']='审判官之手:BAAALAADCgYIBgAAAA==.',['寸铁']='寸铁:BAABLAAFFH8LAAIXAAUIzxcXBgA6AQAXAAUIzxcXBgA6AQAAAA==.',['小九']='小九月:BAABLAAFFH8GAAIfAAYIbxcmBADbAQAfAAYIbxcmBADbAQAAAA==.',['小倩']='小倩乖:BAACLAAFFH81AAILAAcIGSGeCABYAgALAAcIGSGeCABYAgAsAAQKfyIAAgsACAjyJaMDAHUDAAsACAjyJaMDAHUDAAAA.',['小兔']='小兔叽:BAAALAADCgEIAQAAAA==.',['小呆']='小呆守护者:BAACLAAFFH8fAAIEAAcIsRkhEgDVAQAEAAcIsRkhEgDVAQAsAAQKfyMAAwQACAgAI/oOACUDAAQACAgAI/oOACUDABIAAwhuGiB0AJwAAAAA.',['小呜']='小呜喵王:BAAALAAECgYICAAAAA==.',['小小']='小小抱米花:BAABLAAECn8UAAIWAAYIeBosTAClAQAWAAYIeBosTAClAQAAAA==.小小芳芳:BAACLAAFFH8qAAMcAAYITSO9AgBkAgAcAAYITSO9AgBkAgAdAAEIngnDGAA9AAAsAAQKfzoAAxwACAhbI6sFAAoDABwACAhbI6sFAAoDAB0AAwhoDYdYAJUAAAAA.',['小橙']='小橙子:BAAALAAECgQIBAAAAA==.',['小滋']='小滋水枪:BAABLAAFFH8jAAIEAAYIgR+GGQC3AQAEAAYIgR+GGQC3AQAAAA==.',['小羊']='小羊的爷爷:BAACLAAFFH8GAAIHAAIIDQJeYABsAAAHAAIIDQJeYABsAAAsAAQKfxgAAgcABggGCDfpABUBAAcABggGCDfpABUBAAAA.',['小阿']='小阿哥:BAABLAAFFH8QAAIZAAQIIhFxIgAJAQAZAAQIIhFxIgAJAQAAAA==.',['岳火']='岳火术:BAABLAAFFH8JAAMZAAUIHwqrOQCGAAAZAAMIxwirOQCGAAAeAAIIxQ9QJQCGAAAAAA==.',['崽崽']='崽崽熊:BAAALAAECgUIBQAAAA==.',['巨鲨']='巨鲨:BAAALAAECgcIDAAAAA==.',['巴掌']='巴掌:BAAALAAECgYICgAAAA==.',['希尔']='希尔哇娜丝:BAABLAAECn8bAAIgAAYImB9UCwD2AQAgAAYImB9UCwD2AQAAAA==.',['幕冉']='幕冉尘:BAAALAADCgUIBQAAAA==.',['幻若']='幻若流光:BAAALAAECgYICAAAAA==.',['强悍']='强悍的疯牛:BAAALAAECgYIBgAAAA==.',['德彪']='德彪:BAAALAAECgYIDQAAAA==.',['心之']='心之所向:BAAALAADCgMIAwAAAA==.',['心奇']='心奇爆龙:BAAALAAECgEIAQAAAA==.',['怀中']='怀中抱妹杀:BAAALAADCgQIBAAAAA==.',['怀瑾']='怀瑾握瑜:BAABLAAECn8UAAQYAAYIkhbZogA2AQAYAAUIJBLZogA2AQAaAAQI5g0RawDKAAAhAAII/RIULACNAAAAAA==.',['性哥']='性哥:BAAALAAECgYICwAAAA==.',['怪獸']='怪獸:BAAALAAFFAEIAQAAAA==.',['恨你']='恨你的犬夜叉:BAABLAAFFH8KAAIQAAIIdwofMQAyAAAQAAIIdwofMQAyAAAAAA==.',['愤怒']='愤怒爆米花:BAAALAAECgEIAQAAAA==.',['慧儿']='慧儿:BAABLAAFFH8GAAIOAAIIVB8XJQDAAAAOAAIIVB8XJQDAAAAAAA==.',['我不']='我不是治疗啊:BAAALAADCgEIAQAAAA==.',['我只']='我只是术丝啊:BAABLAAFFH8GAAIYAAII8QlHUACAAAAYAAII8QlHUACAAAAAAA==.',['我最']='我最萌:BAACLAAFFH8LAAIMAAYIngljLgD5AAAMAAYIngljLgD5AAAsAAQKfxQAAgwABgizHTEjAOcBAAwABgizHTEjAOcBAAAA.',['我爱']='我爱大白兔:BAAALAAECgYIBgAAAA==.',['我要']='我要你背我:BAAALAADCgcIBwAAAA==.',['打浦']='打浦小白李:BAAALAADCgQIBAAAAA==.',['打蛋']='打蛋蛋:BAABLAAFFH8OAAILAAUI5xVwTQAYAQALAAUI5xVwTQAYAQAAAA==.',['扫地']='扫地僧丶:BAAALAAECgUICwAAAA==.',['抗住']='抗住吖犄角:BAAALAAFFAIIAgAAAA==.',['抹茶']='抹茶碎碎冰:BAAALAADCgQIBwAAAA==.',['指尖']='指尖的圣光:BAAALAAECgYIBgAAAA==.指尖的暗影:BAABLAAECn8ZAAIYAAYIpRNYRQA0AQAYAAYIpRNYRQA0AQAAAA==.',['挚爱']='挚爱无悔:BAAALAAECgYIEAAAAA==.',['捞面']='捞面多放卤:BAAALAADCgEIAQAAAA==.',['捣蛋']='捣蛋鬼别捣蛋:BAABLAAFFH8FAAISAAIIxxwxDwCSAAASAAIIxxwxDwCSAAAAAA==.',['掏蛋']='掏蛋王:BAAALAADCgMIAwAAAA==.',['斟满']='斟满一杯酒:BAACLAAFFH8OAAIPAAUIsApdDADLAAAPAAUIsApdDADLAAAsAAQKfxwAAw8ABwhfFzASAJEBAA8ABwhfFzASAJEBAA4ABAhdA2JRAY0AAAEsAAUUBggXABMAugIA.',['无悔']='无悔挚爱:BAAALAAECgYIDgAAAA==.',['无相']='无相劫:BAAALAAECgYIDgAAAA==.',['旮旯']='旮旯兔奶糖:BAABLAAFFH8IAAMaAAII2g6IIABpAAAaAAII2g6IIABpAAAYAAIIfgO/cgAiAAABLAAFFAYIGQALADQRAA==.',['昆仑']='昆仑:BAAALAAECggICAAAAA==.',['星空']='星空:BAAALAAFFAIIBAAAAA==.',['春秋']='春秋剑甲:BAACLAAFFH8cAAIbAAYIJRTyCwDsAAAbAAYIJRTyCwDsAAAsAAQKfxgAAhsACAjDGl4PAGMCABsACAjDGl4PAGMCAAAA.春秋琴甲:BAAALAADCgIIAgAAAA==.',['晟晟']='晟晟大王:BAAALAAECgYIBgAAAA==.',['智力']='智力高乐高:BAABLAAFFH8FAAIEAAIIiwdfZgA0AAAEAAIIiwdfZgA0AAAAAA==.',['暗语']='暗语宥辰:BAAALAAFFAIIAgAAAA==.',['最美']='最美不是冬天:BAAALAAFFAQIBAAAAA==.',['月光']='月光如盐丶:BAABLAAFFH8JAAILAAMIfhLQagCNAAALAAMIfhLQagCNAAAAAA==.',['月离']='月离:BAAALAAECgYIDAAAAA==.',['有才']='有才必有德:BAAALAAFFAIIBAAAAA==.',['杀戮']='杀戮圆舞曲:BAABLAAFFH8HAAIDAAUIJA24KQAfAQADAAUIJA24KQAfAQAAAA==.',['李逵']='李逵:BAAALAAECgYICQAAAA==.',['李队']='李队长:BAABLAAFFH8IAAMUAAYISQIGBgA9AAAQAAIIFAQALgBeAAAUAAYIVgEGBgA9AAAAAA==.',['来俩']='来俩人点门:BAAALAAECgEIAQAAAA==.',['极度']='极度无糖:BAAALAADCgIIAgAAAA==.',['构筑']='构筑者:BAAALAAECgIIAgAAAA==.',['林晓']='林晓美:BAAALAAECggICAAAAA==.',['林花']='林花谢了春红:BAABLAAFFH8GAAIOAAUIDwsDNgDRAAAOAAUIDwsDNgDRAAAAAA==.',['柒千']='柒千:BAAALAAFFAIIBAAAAA==.',['棒棒']='棒棒:BAAALAADCgUIBQAAAA==.',['橙橙']='橙橙登橙橙:BAABLAAFFH8KAAIZAAMIqBgSHACyAAAZAAMIqBgSHACyAAAAAA==.',['欧皇']='欧皇之皇:BAAALAAECgYIDAAAAA==.',['正义']='正义的小羊:BAAALAAECggIEwAAAA==.',['死亡']='死亡宣告:BAAALAAFFAIIBAAAAA==.',['死骑']='死骑不帅:BAAALAADCgMIAwAAAA==.',['残月']='残月双刃:BAAALAAECgYICgABLAAECggIHgAQAIIbAA==.残月驾鹤:BAAALAAECgIIAgAAAA==.',['毁灭']='毁灭曼巴:BAAALAAECgYIBgAAAA==.',['毒凰']='毒凰:BAAALAAECgYIBgAAAA==.',['池鱼']='池鱼:BAAALAAECgIIAgAAAA==.',['沏上']='沏上一壶茶:BAABLAAFFH8VAAIWAAUITQt1IwAkAQAWAAUITQt1IwAkAQABLAAFFAYIFwATALoCAA==.',['油茶']='油茶蛋糕:BAABLAAECn8ZAAIZAAgIqBVlQgDWAQAZAAgIqBVlQgDWAQAAAA==.',['泰国']='泰国的小短腿:BAAALAADCgYIBgAAAA==.',['洁云']='洁云:BAAALAAECgYICwAAAA==.',['洗剪']='洗剪吹吹炊:BAAALAAECgYICwAAAA==.',['洛尘']='洛尘:BAAALAAECgUIBQAAAA==.',['流年']='流年丶:BAAALAAECgMIBAAAAA==.',['浮士']='浮士德二夫人:BAABLAAFFH8OAAINAAMIRxD9HgCqAAANAAMIRxD9HgCqAAAAAA==.浮士德刺蛇:BAABLAAFFH8FAAIfAAMIRQZsGACCAAAfAAMIRQZsGACCAAAAAA==.浮士德国战车:BAAALAAECggICwAAAA==.浮士德夫人:BAABLAAFFH8MAAIYAAMIKQ4dTgCCAAAYAAMIKQ4dTgCCAAAAAA==.',['浮生']='浮生回觎:BAAALAAFFAIIAgAAAA==.浮生若云年:BAAALAAECggICAAAAA==.',['海豹']='海豹仙游:BAAALAAECgYIBgAAAA==.',['清风']='清风:BAACLAAFFH8IAAIOAAIIthE5SwCWAAAOAAIIthE5SwCWAAAsAAQKfxQAAg4ABgglHeF4APgBAA4ABgglHeF4APgBAAAA.',['渡鸦']='渡鸦:BAAALAAECgMIAwAAAA==.',['温上']='温上一壶酒:BAABLAAFFH8OAAIEAAUIDQQ0PADgAAAEAAUIDQQ0PADgAAABLAAFFAYIFwATALoCAA==.',['满天']='满天星亮晶晶:BAABLAAFFH8HAAIDAAcIBRSJDQDtAQADAAcIBRSJDQDtAQAAAA==.',['漫不']='漫不经心:BAABLAAFFH8TAAIMAAYIUw9AHgBqAQAMAAYIUw9AHgBqAQAAAA==.',['漫步']='漫步远征路:BAAALAADCgYIBgAAAA==.',['火星']='火星君:BAABLAAFFH8GAAINAAYIpAz/BgC9AQANAAYIpAz/BgC9AQAAAA==.',['火羽']='火羽星璇:BAABLAAFFH8IAAIZAAII2ggxRQBZAAAZAAII2ggxRQBZAAABLAAFFAMIEAAfAJUPAA==.',['灵荫']='灵荫:BAACLAAFFH8KAAIZAAIIBiDpGQC6AAAZAAIIBiDpGQC6AAAsAAQKfysAAhkACAjMInsEAAoDABkACAjMInsEAAoDAAAA.',['点燃']='点燃一支烟:BAACLAAFFH8XAAMTAAYIugJfLQDOAAATAAYIugJfLQDOAAAMAAUIfgSUOgC4AAAsAAQKfx8AAgwABgiwFms+AGEBAAwABgiwFms+AGEBAAAA.',['爱意']='爱意随钟起:BAACLAAFFH8wAAIBAAYIICTzDQAiAgABAAYIICTzDQAiAgAsAAQKfxQAAgEABwheHjk8AI0BAAEABwheHjk8AI0BAAAA.',['爱狗']='爱狗者赵威克:BAABLAAFFH8GAAILAAYINhUlOwBWAQALAAYINhUlOwBWAQAAAA==.',['爸气']='爸气歪露:BAAALAAECgYIBwAAAA==.',['片羽']='片羽渡寒渊:BAABLAAFFH8cAAIGAAUIJgnLCQCzAAAGAAUIJgnLCQCzAAABLAAFFAYIFwATALoCAA==.',['版本']='版本之子:BAABLAAFFH8IAAIMAAIIMhxPMAChAAAMAAIIMhxPMAChAAAAAA==.',['牛头']='牛头人:BAACLAAFFH8YAAIWAAYI4x63EQDNAQAWAAYI4x63EQDNAQAsAAQKfx8AAhYACAiQH6kRANsCABYACAiQH6kRANsCAAAA.',['牛牛']='牛牛犇犇:BAACLAAFFH8IAAMDAAYILhEMHQCAAQADAAYI7BAMHQCAAQAQAAIIZA8TIQB7AAAsAAQKfx4AAgMABghqH+9IABYCAAMABghqH+9IABYCAAAA.',['牧牧']='牧牧:BAAALAAECgYICwAAAA==.',['特兰']='特兰奇亚:BAAALAAECgYIEQAAAA==.',['狐狐']='狐狐牧:BAAALAADCgYIBgABLAAECgMIAwAiAAAAAA==.',['狩王']='狩王归来:BAABLAAFFH8KAAILAAIInhp+WQCQAAALAAIInhp+WQCQAAAAAA==.',['猎心']='猎心雷:BAAALAAFFAIIAgAAAA==.',['猪猪']='猪猪别跑:BAAALAAECgQIBwAAAA==.',['猫依']='猫依让刃:BAABLAAFFH8OAAIDAAIIUhqkKACoAAADAAIIUhqkKACoAAAAAA==.',['猫帝']='猫帝嘎嘎:BAABLAAECn8nAAIMAAgI1RySLQBcAgAMAAgI1RySLQBcAgAAAA==.',['王府']='王府家丁丁:BAAALAAECgEIAQAAAA==.',['琉璃']='琉璃槿:BAAALAADCggICAAAAA==.',['瑶瑶']='瑶瑶的兔子:BAABLAAFFH8GAAMLAAIIAiDONwC0AAALAAIIAiDONwC0AAARAAIIuAEKMwBLAAAAAA==.',['田鼠']='田鼠凶巴巴:BAABLAAFFH8JAAIQAAII3Qz7MAAyAAAQAAII3Qz7MAAyAAAAAA==.田鼠笑嘻嘻:BAABLAAFFH8GAAIeAAIIbQ7IMgA+AAAeAAIIbQ7IMgA+AAAAAA==.田鼠笑眯眯:BAABLAAFFH8GAAIGAAII4Q3sFAAsAAAGAAII4Q3sFAAsAAAAAA==.田鼠胖乎乎:BAABLAAFFH8IAAIBAAIIwhbjbABdAAABAAIIwhbjbABdAAAAAA==.',['疾影']='疾影蜂:BAAALAAECgUIBQAAAA==.',['白凤']='白凤九:BAAALAAFFAIIAgAAAA==.',['白小']='白小丑:BAAALAADCgIIAgAAAA==.',['盘不']='盘不盘他:BAAALAAECgYICwAAAA==.盘不盘你:BAABLAAECn8YAAILAAYIER7LfwDfAQALAAYIER7LfwDfAQAAAA==.',['盛夏']='盛夏七月:BAAALAAFFAMIAwAAAA==.',['盾御']='盾御天下:BAABLAAFFH8IAAIOAAIIDiCEPQCgAAAOAAIIDiCEPQCgAAAAAA==.',['睿智']='睿智的雪球:BAAALAAECggIDwAAAA==.',['瞎髻']='瞎髻墢飋:BAAALAADCgYIBgAAAA==.',['瞬间']='瞬间爆表:BAACLAAFFH8LAAIDAAII3yYXHQDhAAADAAII3yYXHQDhAAAsAAQKfxkAAgMABgjvJvQWACoCAAMABgjvJvQWACoCAAAA.',['短歌']='短歌行:BAAALAAFFAIIAgAAAA==.',['破碎']='破碎的星辰:BAABLAAFFH8HAAIOAAIIMR3xVgBLAAAOAAIIMR3xVgBLAAAAAA==.',['祖传']='祖传体臭:BAAALAADCgcIBwAAAA==.',['神猎']='神猎手:BAACLAAFFH8TAAIHAAUIHxTHGgAEAQAHAAUIHxTHGgAEAQAsAAQKfyUAAgcACAj9HLIqALICAAcACAj9HLIqALICAAAA.',['神裂']='神裂火織:BAACLAAFFH8UAAQjAAUI+BvVAQAbAQAjAAQIzB7VAQAbAQALAAUIuA5qXwDDAAARAAMInBLxGAA6AAAsAAQKfxoABCMABwi7HwkHAFcCACMABwjqHgkHAFcCAAsABQjzGSgVARIBABEAAwgkDmgoAFMAAAAA.',['秋兮']='秋兮剪水:BAAALAAECgQIBAAAAA==.',['秦始']='秦始皇:BAAALAAECgIIAgAAAA==.',['稍息']='稍息:BAAALAAECgYIBgAAAA==.',['糖丶']='糖丶罐罐:BAAALAAECgQIBAAAAA==.',['糖半']='糖半藏:BAAALAAECgYIBgAAAA==.',['糖果']='糖果不甜了:BAAALAADCgMIAwAAAA==.糖果是甜的:BAACLAAFFH8mAAIBAAYIuCLEEQAAAgABAAYIuCLEEQAAAgAsAAQKfxcAAwEABgi8H9s3AJsBAAEABghZHts3AJsBAAUAAQjFIJlEAF4AAAEsAAUUBwg1AAsAGSEA.糖果贩子:BAAALAAECgIIAwAAAA==.',['素灵']='素灵:BAAALAAECgMIAwAAAA==.',['縌愛']='縌愛緈諨:BAAALAADCggICAAAAA==.',['红颜']='红颜惹人醉:BAAALAAFFAIIAgAAAA==.',['绝对']='绝对核心:BAAALAAECgMIAwAAAA==.',['缇娜']='缇娜斯普朗特:BAAALAAFFAIIAgAAAA==.',['罗斯']='罗斯特:BAACLAAFFH8YAAMTAAUIlhVhFwD3AAATAAUIlhVhFwD3AAAMAAIIyhtBMgCdAAAsAAQKfyAAAxMACAh0G6kuAFQCABMABwi7HakuAFQCAAwACAixGi5AAB0CAAAA.',['羽落']='羽落星辰:BAAALAADCgQIBAAAAA==.',['翡翠']='翡翠绿豆糕:BAAALAAFFAIIAgAAAA==.',['老三']='老三与吕端:BAAALAADCgQIBAAAAA==.',['老父']='老父亲:BAAALAAECgEIAQABLAAECgMIAwAiAAAAAA==.',['耗儿']='耗儿鱼:BAABLAAFFH8HAAITAAIItw6pSgA8AAATAAIItw6pSgA8AAABLAAFFAgIIwATACQcAA==.',['肉肉']='肉肉啊肉肉:BAAALAAECgQIBAAAAA==.',['肯定']='肯定不玩:BAAALAAFFAIIAgAAAA==.',['胡华']='胡华师者:BAAALAAECgYIBgAAAA==.',['脚丫']='脚丫曾被亵渎:BAAALAAFFAIIBAAAAA==.',['自爆']='自爆卵:BAAALAAECgUIBQABLAAFFAUIGwAMADImAA==.',['艾瑞']='艾瑞达:BAABLAAFFH8IAAIPAAIIEBG5HABqAAAPAAIIEBG5HABqAAAAAA==.',['艾莉']='艾莉桑卓:BAAALAAFFAIIBAAAAA==.',['艾露']='艾露恩:BAAALAAECgIIAgAAAA==.',['芙瑰']='芙瑰璃:BAAALAAFFAEIAQAAAA==.',['芥舟']='芥舟纳四溟:BAAALAAECgIIAgAAAA==.',['花蝴']='花蝴蝶:BAAALAADCgIIAgAAAA==.',['花香']='花香小叶:BAABLAAFFH8HAAIBAAMINAa8ZwB4AAABAAMINAa8ZwB4AAABLAAFFAUIHgAaABMcAA==.',['苏坦']='苏坦妮:BAAALAADCgUIBQAAAA==.',['苹儿']='苹儿:BAAALAADCgQIBAAAAA==.',['茉莉']='茉莉蜜茶:BAAALAAECgQIBAAAAA==.',['莱尔']='莱尔特酋长:BAAALAAFFAIIBAAAAA==.',['菊花']='菊花不好:BAAALAADCgYIBgAAAA==.菊花残:BAAALAAECgQIBAAAAA==.',['菜点']='菜点怎么辣:BAABLAAFFH8SAAINAAYIBw9OEQByAQANAAYIBw9OEQByAQAAAA==.',['萌哆']='萌哆不萌:BAABLAAFFH8jAAILAAcIahq3FQDkAQALAAcIahq3FQDkAQAAAA==.',['萧晓']='萧晓筱:BAAALAAECgcICQAAAA==.',['萨格']='萨格拉满:BAAALAAECgMICQAAAA==.',['蓝皮']='蓝皮罗密欧:BAAALAAFFAIIAgAAAA==.',['薄雾']='薄雾:BAAALAAECgMIAwAAAA==.',['虞星']='虞星辰:BAAALAAECgYICwAAAA==.',['蛋卷']='蛋卷冰淇淋:BAAALAAECgUIBQAAAA==.蛋卷王子:BAABLAAFFH8OAAIMAAIImhxaRwCQAAAMAAIImhxaRwCQAAAAAA==.蛋卷皇:BAABLAAFFH8IAAIQAAIIeRSRKgA6AAAQAAIIeRSRKgA6AAAAAA==.',['螭鱼']='螭鱼:BAAALAAECgQIBAAAAA==.',['街溜']='街溜子来了:BAAALAAECgMIBQAAAA==.',['衡州']='衡州之刃:BAAALAAECgIIAgAAAA==.',['西方']='西方惑:BAAALAAFFAIIBAAAAA==.',['西瓜']='西瓜多:BAAALAADCgcIBwAAAA==.',['親丶']='親丶爱的:BAAALAADCgcIDAAAAA==.',['詹姆']='詹姆斯:BAAALAAFFAIIAgAAAA==.',['谢谢']='谢谢你的爱:BAAALAADCgYICAAAAA==.',['豪痞']='豪痞图腾:BAAALAAECgYICgAAAA==.豪痞重来:BAAALAAECgYIEwAAAA==.',['貓吢']='貓吢詠恆:BAAALAAECgQIBQAAAA==.',['贼灬']='贼灬萌:BAAALAAECgYIBgAAAA==.',['赦天']='赦天琴姬:BAACLAAFFH8LAAIEAAII0xUaRQCbAAAEAAII0xUaRQCbAAAsAAQKfxkAAwQABwj/GfgeALUBAAQABwj/GfgeALUBABIAAQi5CpiTADQAAAAA.',['跳舞']='跳舞的梵谷:BAABLAAFFH8SAAMOAAYIcxogGgCHAQAOAAYIHRkgGgCHAQAPAAIIiSN6CQDNAAAAAA==.',['车七']='车七七:BAABLAAECn8UAAIZAAYIOA7DTgDZAAAZAAYIOA7DTgDZAAAAAA==.',['追风']='追风逐猎者:BAAALAAFFAIIAgAAAA==.',['退后']='退后我葽装逼:BAAALAAECgYIBgABLAAECggIHgAQAIIbAA==.退后我要装逼:BAABLAAECn8eAAMQAAgIghsCDAAMAgAQAAgIBxoCDAAMAgADAAYIXhpANQCEAQAAAA==.',['部落']='部落大表哥:BAAALAAECgUIBQAAAA==.',['鄊田']='鄊田龍司:BAABLAAFFH8GAAIOAAQIkwh2OwCoAAAOAAQIkwh2OwCoAAAAAA==.',['锅巴']='锅巴的义祖父:BAAALAAECggICgAAAA==.',['阿修']='阿修罗:BAAALAAECgEIAQAAAA==.',['阿倩']='阿倩的:BAAALAAECgYIEAABLAAFFAcINQALABkhAA==.',['阿尔']='阿尔卑斯丶:BAAALAAECgYIBgAAAA==.',['阿巴']='阿巴瑟三:BAACLAAFFH8PAAIfAAIIqibYCwDlAAAfAAIIqibYCwDlAAAsAAQKfzoAAh8ACAisJdoAAGcDAB8ACAisJdoAAGcDAAEsAAUUBggtAAwAGiMA.阿巴瑟瑟:BAACLAAFFH8tAAMMAAYIGiNJCQAyAgAMAAYIGiNJCQAyAgATAAUI4Rj5HABYAQAsAAQKf1AAAwwACAi4JvsAAHADAAwACAi4JvsAAHADABMACAinIUkXAN8CAAAA.',['阿科']='阿科:BAABLAAFFH8GAAIMAAYICxygFQCzAQAMAAYICxygFQCzAQAAAA==.',['阿隆']='阿隆萨尓:BAABLAAFFH8KAAIBAAIInhx8RQCrAAABAAIInhx8RQCrAAAAAA==.',['阿馥']='阿馥奇朵:BAAALAADCgYIBgAAAA==.',['际统']='际统阿:BAAALAAECgEIAQAAAA==.',['陆佩']='陆佩璃:BAAALAAECgMIBwAAAA==.',['隐术']='隐术:BAAALAAECgYICQAAAA==.',['零度']='零度幻想:BAAALAAFFAIIBAAAAA==.零度火焰:BAAALAAECgYIBgAAAA==.',['霜之']='霜之痕:BAABLAAFFH8GAAIBAAIIghAmZQCWAAABAAIIghAmZQCWAAAAAA==.',['霜冷']='霜冷长河:BAABLAAFFH8IAAIBAAYIQAJwhwBCAAABAAYIQAJwhwBCAAAAAA==.',['霸气']='霸气的老牛:BAAALAAECgIIAgAAAA==.',['靓靓']='靓靓:BAAALAAECgYICgAAAA==.',['风之']='风之痕迹:BAAALAAECgYICgAAAA==.',['风来']='风来花自舞:BAAALAAECgMIAwAAAA==.',['风殇']='风殇之梦:BAACLAAFFH8FAAIZAAIIhhWAPgB3AAAZAAIIhhWAPgB3AAAsAAQKfyYAAhkABwhxGUkgANABABkABwhxGUkgANABAAAA.',['风的']='风的痕迹:BAAALAAECgIIAgAAAA==.',['风驰']='风驰:BAACLAAFFH8aAAIGAAUIrRUyBwADAQAGAAUIrRUyBwADAQAsAAQKfxcAAgYABgjNHt4KAKsBAAYABgjNHt4KAKsBAAEsAAUUCAgMAAcAZRkA.',['首席']='首席黑巧拿铁:BAAALAADCggICAAAAA==.',['香芋']='香芋地瓜丸:BAAALAAFFAIIAwAAAA==.',['馨语']='馨语筱卿:BAAALAAFFAEIAQAAAA==.',['马国']='马国成:BAAALAAECgYICwAAAA==.',['马论']='马论:BAABLAAFFH8MAAINAAYIzh4rCgDiAQANAAYIzh4rCgDiAQAAAA==.',['骑摩']='骑摩托拾荒:BAABLAAFFH8TAAILAAYIbg7QOwBUAQALAAYIbg7QOwBUAQABLAAFFAYIFwATALoCAA==.',['鬼神']='鬼神下凡:BAAALAAFFAIIAgAAAA==.鬼神下凡三代:BAAALAAFFAIIBAAAAA==.鬼神下凡二代:BAAALAAECgYIBgAAAA==.鬼神宝宝:BAAALAAECgYICQAAAA==.鬼神轨道炮:BAAALAAECgYICAAAAA==.',['魔剑']='魔剑创造:BAABLAAFFH8HAAIeAAYI5Qr2FAA5AQAeAAYI5Qr2FAA5AQAAAA==.',['魔枢']='魔枢氏:BAAALAAECgYIDQAAAA==.',['鱼少']='鱼少:BAAALAAECgUIBQAAAA==.',['鸭头']='鸭头肉:BAABLAAFFH8GAAIOAAMIPQ9IKgC1AAAOAAMIPQ9IKgC1AAAAAA==.',['麦姬']='麦姬珂:BAABLAAFFH8PAAIEAAUISA4KNwAYAQAEAAUISA4KNwAYAQAAAA==.',['麦田']='麦田射手:BAABLAAFFH8MAAILAAYI3xhrDgC+AQALAAYI3xhrDgC+AQAAAA==.',['黄焖']='黄焖牛肉:BAACLAAFFH8GAAIMAAIImw0PYgBZAAAMAAIImw0PYgBZAAAsAAQKfxUAAgwABghgFBGRAFwBAAwABghgFBGRAFwBAAAA.',['黑凤']='黑凤九:BAAALAAFFAIIBAAAAA==.',['黑涩']='黑涩蕾丝:BAAALAADCgYIDAAAAA==.',['黑猪']='黑猪泡杨叫兽:BAAALAADCgIIBAAAAA==.',['黑胡']='黑胡子哥:BAAALAAECgUIBQAAAA==.',['黑锋']='黑锋骑士:BAAALAAECgEIAQAAAA==.',['默默']='默默不玩:BAACLAAFFH8IAAIcAAMIYQnNDADCAAAcAAMIYQnNDADCAAAsAAQKfx4AAhwABwgKG0sVACYCABwABwgKG0sVACYCAAAA.',['黯灵']='黯灵的愤怒:BAAALAAECgYIDwAAAA==.',['龍龍']='龍龍:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end