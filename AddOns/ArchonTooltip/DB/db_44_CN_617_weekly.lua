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
 local lookup = {'Shaman-Elemental','Warlock-Destruction','Warrior-Fury','Warrior-Arms','Mage-Arcane','Mage-Frost','DeathKnight-Frost','Druid-Restoration','Druid-Balance','Shaman-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Druid-Guardian','DemonHunter-Havoc','Paladin-Retribution','DeathKnight-Blood','Priest-Shadow','Priest-Holy','Paladin-Holy','DemonHunter-Vengeance','Druid-Feral','Warlock-Demonology','Priest-Discipline','Warrior-Protection','Warlock-Affliction','Rogue-Assassination','Monk-Brewmaster','Rogue-Subtlety','Paladin-Protection',}; local provider = {region='CN',realm='埃加洛尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ae='Aersas:BAAALAAECgEIAQAAAA==.',Ao='Aobtt:BAABLAAFFH8OAAIBAAgI5BevBwA7AgABAAgI5BevBwA7AgAAAA==.',Ar='Arturia:BAAALAAECgYIBgAAAA==.',Ba='Baboy:BAAALAAECgUIBQAAAA==.Badjuju:BAABLAAFFH8GAAICAAYIIB3BBwA+AgACAAYIIB3BBwA+AgAAAA==.Balagan:BAACLAAFFH8HAAIDAAcIrwl+GwDtAAADAAcIrwl+GwDtAAAsAAQKfyEAAwMACAgLHXwlAK4CAAMACAgLHXwlAK4CAAQAAQhMETU5AEAAAAAA.',Be='Benson:BAACLAAFFH8QAAIFAAgIVhHsDAAcAgAFAAgIVhHsDAAcAgAsAAQKfxQAAwUACAgqGExlANYBAAUACAjUF0xlANYBAAYABgikEwwfACcBAAAA.',Bl='Bleachz:BAABLAAFFH8UAAIHAAgI+wjOWQCbAAAHAAgI+wjOWQCbAAAAAA==.',Ce='Cezhegan:BAABLAAFFH8JAAMIAAYITgp0HgAwAQAIAAYITgp0HgAwAQAJAAII2wV1OwAxAAAAAA==.',Cl='Clime:BAAALAAECgMIAwAAAA==.',Co='Connie:BAAALAAECgIIAgAAAA==.Copy:BAAALAAECgYICAAAAA==.',De='Demondan:BAAALAADCgIIAgAAAA==.',El='Elaras:BAAALAAFFAEIAQAAAA==.',Em='Emocore:BAAALAAFFAIIBAAAAA==.',Ev='Evaccaneer:BAACLAAFFH8IAAIKAAIIRhOwTgBtAAAKAAIIRhOwTgBtAAAsAAQKfxwAAwoACAgDExBkAL8BAAoACAgDExBkAL8BAAEAAQiJA/jWACwAAAAA.',Fr='Frostweaver:BAABLAAECn8ZAAMFAAgIlxSCIQCkAQAFAAgIlxSCIQCkAQAGAAYIFg8uTwA2AQAAAA==.',Gu='Guldaneye:BAACLAAFFH8IAAICAAIIyhHoYAA+AAACAAIIyhHoYAA+AAAsAAQKfxYAAgIABgiRGB1rALMBAAIABgiRGB1rALMBAAAA.',Hh='Hhotk:BAAALAAECgMIAwAAAA==.',Hi='Hiz:BAAALAAFFAIIBAAAAA==.',Hu='Hunterbleach:BAABLAAFFH8IAAILAAII7SJfMgDAAAALAAII7SJfMgDAAAAAAA==.',Ja='Jamila:BAAALAAECggIBwAAAA==.',Je='Jezd:BAAALAAECggIDgAAAA==.',Ju='June:BAABLAAFFH8QAAMLAAIIVCRJeABsAAALAAIIVCRJeABsAAAMAAEICgeFOAA1AAAAAA==.',Ku='Kuroe:BAAALAAECgYIDQAAAA==.',Li='Littefat:BAABLAAFFH8KAAQNAAgIYQ0+CABMAQANAAUI8gw+CABMAQAOAAQIBxHmBwAeAQAPAAEINB3YIQBaAAAAAA==.',Lr='Lrzhkb:BAABLAAFFH8HAAIFAAIIQxrLUQBKAAAFAAIIQxrLUQBKAAAAAA==.',Mi='Miss:BAABLAAFFH8LAAIQAAYIgQOpBQDAAAAQAAYIgQOpBQDAAAAAAA==.',Mo='Moouse:BAABLAAFFH8GAAIRAAIInBP8SwCQAAARAAIInBP8SwCQAAAAAA==.',Ne='Nevailsun:BAACLAAFFH8HAAICAAMICRGeTwB7AAACAAMICRGeTwB7AAAsAAQKfx0AAgIACAjtHHMRAFwCAAIACAjtHHMRAFwCAAAA.',Oh='Oh:BAABLAAFFH8NAAISAAMIbxUXQwCLAAASAAMIbxUXQwCLAAABLAAFFAYIBwAHAIQEAA==.',Qw='Qwertyui:BAAALAAECgIIAgAAAA==.',Ra='Rachelmoore:BAAALAAECgQIBAAAAA==.',Ro='Robinsona:BAAALAAECgUIEAAAAA==.Rory:BAABLAAFFH8GAAMKAAQIjBe8EQAuAQAKAAQIjBe8EQAuAQABAAIIdxmOJQCcAAAAAA==.',Sa='Sahur:BAAALAAECgYICQAAAA==.Savitar:BAABLAAFFH8SAAILAAYIbyCGBwAKAgALAAYIbyCGBwAKAgAAAA==.',Sd='Sdll:BAABLAAFFH8HAAIHAAMIDQIAbgBZAAAHAAMIDQIAbgBZAAAAAA==.',Sh='Sheyidi:BAABLAAECn8cAAILAAgIeh7nNgCBAgALAAgIeh7nNgCBAgAAAA==.',St='Stig:BAAALAAECggIAgAAAA==.',Sw='Sweetend:BAAALAAECggICAAAAA==.',Sz='Szh:BAACLAAFFH8OAAIGAAIIsiD5DgCTAAAGAAIIsiD5DgCTAAAsAAQKfxcAAgYACAjIH34GAGwCAAYACAjIH34GAGwCAAAA.',Th='Thundersm:BAACLAAFFH8GAAIBAAIIYBc4LgCMAAABAAIIYBc4LgCMAAAsAAQKfxYAAwEABwhLFVRlAIkBAAEABwhLFVRlAIkBAAoAAgiuEsWJAG8AAAAA.',Tu='Tuolagan:BAABLAAFFH8QAAMHAAgItRlECgANAgATAAgIsxYgBAAhAgAHAAYIHRVECgANAgAAAA==.',Vi='Vincent:BAABLAAECn8gAAISAAgIKSBxJADfAgASAAgIKSBxJADfAgABLAAFFAgIEAAHALUZAA==.Vitaminc:BAAALAAECgYICAAAAA==.',Vu='Vurtne:BAABLAAECn8UAAMGAAYIvx0+EAC/AQAGAAYIvx0+EAC/AQAFAAII6RONXgCFAAAAAA==.',Wh='Whiteablack:BAACLAAFFH8hAAMUAAYImBCRFwAEAQAUAAUIXgyRFwAEAQAVAAUIKAdmHgDIAAAsAAQKfy0AAxUACAiUC3dVAIEBABUACAiUC3dVAIEBABQAAwiaEet6AL8AAAAA.',Xi='Xiaoguitou:BAABLAAFFH8KAAICAAYIbB3GGgBsAQACAAYIbB3GGgBsAQAAAA==.',Yu='Yukiho:BAAALAAECgYIBgAAAA==.',Ze='Zerodal:BAABLAAECn8ZAAIFAAYIPSAqTAAhAgAFAAYIPSAqTAAhAgAAAA==.Zeronine:BAABLAAFFH8IAAISAAII9yJrPAChAAASAAII9yJrPAChAAAAAA==.',['一万']='一万个人:BAAALAADCgQIBAAAAA==.',['七箭']='七箭:BAAALAAECgYICgAAAA==.',['三七']='三七九:BAAALAAFFAEIAQAAAA==.',['三万']='三万英尺:BAAALAAFFAIIBAAAAA==.',['三鹿']='三鹿:BAAALAAECgEIAQAAAA==.',['不听']='不听后来了:BAABLAAFFH8QAAIRAAUI9RHdLAAwAQARAAUI9RHdLAAwAQAAAA==.',['不學']='不學灬無術:BAAALAAFFAIIAgAAAA==.',['不怕']='不怕潜规则:BAAALAAECgYIEQAAAA==.',['不思']='不思议妖妖:BAAALAAECgUIBQAAAA==.',['不灭']='不灭风华:BAAALAAECgYIDgAAAA==.',['不错']='不错的兽医:BAAALAADCgYIAgAAAA==.',['且行']='且行且惜:BAABLAAECn8WAAMSAAcIaxiPcwACAgASAAcIaxiPcwACAgAWAAYIowmIUwAFAQAAAA==.',['丨丶']='丨丶半颗心:BAAALAAECggIEAAAAA==.丨丶半颗糖:BAAALAAECgIIAgAAAA==.',['丨喵']='丨喵乄喵丨:BAAALAAFFAEIAQAAAA==.',['丨懒']='丨懒虫灬西墙:BAAALAAECgYIBwAAAA==.',['丶妖']='丶妖小妖:BAABLAAFFH8VAAIVAAMIrhYwGADnAAAVAAMIrhYwGADnAAAAAA==.',['丶泡']='丶泡沫丶:BAABLAAFFH8FAAIHAAUIswc1TwDlAAAHAAUIswc1TwDlAAAAAA==.',['丷一']='丷一箭钟情丷:BAAALAADCggICAAAAA==.',['乄对']='乄对我弹琴乄:BAAALAAECgYIBgAAAA==.',['乄血']='乄血与沙乄:BAAALAAECgQIBAAAAA==.',['乌鸡']='乌鸡:BAAALAAECgYIBgAAAA==.',['九龙']='九龙十八海:BAAALAADCgYIBgAAAA==.',['也也']='也也:BAAALAAECgEIAQAAAA==.',['乱世']='乱世:BAABLAAFFH8IAAIDAAII5BEjSgBJAAADAAII5BEjSgBJAAABLAAFFAIIDQAOAOsRAA==.',['二果']='二果:BAAALAAECgYIBgAAAA==.',['五显']='五显财神:BAAALAAECgYIEgAAAA==.',['亚历']='亚历山大:BAABLAAFFH8eAAITAAUI6g2TEADoAAATAAUI6g2TEADoAAAAAA==.',['亚妮']='亚妮拉丝:BAAALAAECgUIBQAAAA==.',['亮亮']='亮亮牛:BAAALAAECgYIBgAAAA==.',['今夕']='今夕丶何夕:BAAALAAECgEIAQAAAA==.',['今天']='今天吃饭了吗:BAAALAAFFAIIAgAAAA==.',['今晚']='今晚不大老虎:BAAALAAECgUIBQAAAA==.',['从不']='从不缺德:BAABLAAFFH8HAAIIAAQITg7zJQDpAAAIAAQITg7zJQDpAAAAAA==.',['以戰']='以戰丨止戰:BAABLAAFFH8KAAIDAAIISwgjXAA6AAADAAIISwgjXAA6AAAAAA==.',['伊利']='伊利蛋怒風:BAABLAAFFH8KAAIRAAIIzx3bRQBkAAARAAIIzx3bRQBkAAAAAA==.',['伊森']='伊森丨哈德:BAAALAAFFAIIAgAAAA==.',['你丫']='你丫给我上:BAAALAAECgIIAgAAAA==.',['你刚']='你刚:BAABLAAFFH8PAAITAAYIhx+TBgDPAQATAAYIhx+TBgDPAQAAAA==.',['你就']='你就给我爆:BAACLAAFFH8nAAIGAAYIBA/4BQBZAQAGAAYIBA/4BQBZAQAsAAQKfyYAAwYACAiUFmcgABkCAAYACAiUFmcgABkCAAUABwgYA4PKANcAAAAA.',['你有']='你有去死之道:BAAALAAECgYICAAAAA==.',['使者']='使者:BAAALAADCggICwAAAA==.',['侦查']='侦查骑士安柏:BAAALAADCgcIBwAAAA==.',['倒背']='倒背如流:BAABLAAECn8gAAIXAAYIrxaWEgAmAQAXAAYIrxaWEgAmAQAAAA==.',['倾城']='倾城如歌:BAAALAAECgYIBgAAAA==.',['傲世']='傲世:BAACLAAFFH8NAAMOAAII6xGSCACSAAAOAAIImAySCACSAAAPAAII6xF4HgA/AAAsAAQKfx0AAw4ACAiFGgoGAEwCAA4ACAiFGgoGAEwCAA8ABQjnDiJOAO4AAAAA.',['元祖']='元祖咖喱:BAACLAAFFH8cAAIYAAYI7xo+BABVAQAYAAYI7xo+BABVAQAsAAQKfyAAAhgABwi9H+0NAG8CABgABwi9H+0NAG8CAAAA.',['光捶']='光捶捶:BAAALAAECgMIAwAAAA==.',['兜里']='兜里有糖:BAAALAAECgEIAQAAAA==.兜里没钱:BAABLAAECn8ZAAMLAAYIoBOEjwAwAQALAAYIoBOEjwAwAQAMAAEIkgJi1QASAAAAAA==.',['兰丽']='兰丽雅:BAAALAAFFAIIAwAAAA==.',['兰博']='兰博兔:BAAALAAFFAIIAgAAAA==.',['冥火']='冥火拜伦沃斯:BAABLAAFFH8IAAIHAAgIwwASqgAXAAAHAAgIwwASqgAXAAAAAA==.',['冬天']='冬天的酒:BAAALAAECgIIAgAAAA==.',['冬马']='冬马和纱:BAAALAAECgIIAgAAAA==.',['冰鉴']='冰鉴:BAAALAAECgUIBQAAAA==.',['冰镇']='冰镇玻璃杯:BAAALAAFFAIIAgAAAA==.',['凌跑']='凌跑跑:BAAALAAECgMIAwAAAA==.',['出淤']='出淤泥而全染:BAAALAAECgYIBgAAAA==.',['切尔']='切尔斯:BAAALAADCgMIBAAAAA==.',['刘诗']='刘诗诗:BAACLAAFFH8KAAICAAQIyQviKQDkAAACAAQIyQviKQDkAAAsAAQKfxcAAwIACAicHPsyAHACAAIACAhrG/syAHACABkABgiGHRgzAKEBAAAA.',['剡月']='剡月:BAAALAAFFAIIAgAAAA==.',['加塞']='加塞拉:BAABLAAFFH8LAAIIAAMI2wuuRABmAAAIAAMI2wuuRABmAAAAAA==.',['加尔']='加尔鲁弒:BAAALAAECgMIBQAAAA==.',['动次']='动次打次啪啪:BAAALAAECgIIAgAAAA==.',['劭年']='劭年老成:BAAALAAECgQIBAAAAA==.',['十字']='十字东征:BAAALAAECgYIBgAAAA==.',['十方']='十方俱灭:BAAALAADCggICAAAAA==.',['千丶']='千丶秋:BAABLAAECn8UAAILAAcIVRv7ZQAPAgALAAcIVRv7ZQAPAgAAAA==.',['千华']='千华留:BAACLAAFFH8zAAILAAYInR62IwCjAQALAAYInR62IwCjAQAsAAQKf0cAAgsACAipJNgMALoCAAsACAipJNgMALoCAAAA.',['南小']='南小鸟:BAABLAAFFH8LAAMVAAYIKRCjDACEAQAVAAUI7hCjDACEAQAUAAIIwg1vGQClAAAAAA==.',['卡布']='卡布锜诺:BAAALAADCgUIBQAAAA==.',['压路']='压路机:BAAALAAECgYICAAAAA==.',['参天']='参天大刘欢:BAAALAAFFAIIAgAAAA==.',['又见']='又见彩虹:BAAALAADCggIAgAAAA==.',['双刃']='双刃刺心:BAAALAAFFAIIBAAAAA==.',['可可']='可可派:BAAALAAECgYIBwAAAA==.',['可爱']='可爱的川川:BAABLAAFFH8RAAIFAAMI9xikJAAFAQAFAAMI9xikJAAFAQAAAA==.',['可萌']='可萌可猛:BAAALAAECgUIBQAAAA==.',['司徒']='司徒:BAAALAAECgYIBgAAAA==.',['啊布']='啊布:BAABLAAFFH8MAAISAAIIXxzPQwCbAAASAAIIXxzPQwCbAAAAAA==.',['喜乐']='喜乐乐:BAAALAAECgIIAgAAAA==.',['嘿嘿']='嘿嘿小白:BAAALAADCggICAAAAA==.',['因风']='因风飞过蔷薇:BAABLAAECn8YAAIRAAYI3Q5cXAAJAQARAAYI3Q5cXAAJAQAAAA==.',['圆脸']='圆脸包:BAAALAAECgcICwAAAA==.',['土特']='土特维德:BAAALAAECgYIEgAAAA==.',['圣光']='圣光审判者:BAAALAAECggICAAAAA==.圣光暖暖:BAAALAAECgYIBgAAAA==.',['地亩']='地亩:BAAALAAECgYIBgAAAA==.',['地狱']='地狱狂魔:BAAALAAECgUIBQAAAA==.',['地魔']='地魔猎手:BAACLAAFFH8VAAIRAAQIRxnIGAATAQARAAQIRxnIGAATAQAsAAQKfyEAAhEACAj3HCwzAI8CABEACAj3HCwzAI8CAAEsAAUUBggPAAUANRgA.',['塞勒']='塞勒尼:BAAALAAECgcIBwAAAA==.',['墨墨']='墨墨玩帝剋:BAAALAAECgYIEQAAAA==.',['壹剑']='壹剑倾程:BAAALAADCggICAAAAA==.',['夕立']='夕立加油:BAAALAAECgYIBgAAAA==.',['夕阳']='夕阳狂歌:BAABLAAFFH8PAAITAAYI2wO/EADkAAATAAYI2wO/EADkAAAAAA==.',['大伟']='大伟哥:BAABLAAFFH8IAAIRAAgIDRj2BwBMAgARAAgIDRj2BwBMAgAAAA==.',['大圣']='大圣没娶我:BAAALAAFFAIIBAAAAA==.',['大天']='大天使长凯尔:BAAALAAFFAMIAwAAAA==.大天堂之信仰:BAAALAAECggIDwAAAA==.',['大慰']='大慰哥:BAABLAAFFH8GAAIFAAYIrhY0MABGAQAFAAYIrhY0MABGAQAAAA==.',['大扛']='大扛霖:BAABLAAFFH8FAAIXAAIIRBRFDwB7AAAXAAIIRBRFDwB7AAAAAA==.',['大果']='大果:BAABLAAECn8YAAMUAAYIFQ3KKQD9AAAUAAYIFQ3KKQD9AAAaAAEI5AfKIAAhAAAAAA==.',['大梵']='大梵:BAAALAAFFAYIBAAAAA==.',['大筒']='大筒木羽衣:BAAALAAECgcIEQAAAA==.',['大米']='大米花:BAAALAAECgYIBgAAAA==.',['大脚']='大脚怪:BAACLAAFFH8MAAMbAAII2xpHHwB/AAADAAIIlhhXNACaAAAbAAII7RVHHwB/AAAsAAQKfxgAAxsABgixHU8pAPgBABsABgiTHE8pAPgBAAMABghFG6M0AIcBAAEsAAUUBAgKAAIAyQsA.',['天獅']='天獅嫙嵂:BAAALAAFFAIIAgAAAA==.',['天馳']='天馳哥哥:BAAALAAECgIIAgAAAA==.天馳妹妹丶:BAABLAAFFH8GAAINAAYI+hD4BAC/AQANAAYI+hD4BAC/AQAAAA==.',['天魂']='天魂无双:BAAALAAECgIIAgAAAA==.',['奇幻']='奇幻龙羽:BAAALAAECgQIBQAAAA==.',['奥买']='奥买呷德:BAAALAAECgEIAQAAAA==.',['奶灬']='奶灬罐子:BAAALAAECgIIAQAAAA==.',['好吃']='好吃啊:BAAALAAECgYIEgAAAA==.',['如何']='如何回忆我:BAAALAAFFAMIAwAAAA==.',['妞萌']='妞萌萌:BAAALAAECgYIBwAAAA==.',['姓大']='姓大名奶:BAAALAAFFAIIBAAAAA==.',['嫩非']='嫩非牛:BAACLAAFFH8QAAIHAAIInBSYZQCVAAAHAAIInBSYZQCVAAAsAAQKfywAAgcACAhGHik3AJoCAAcACAhGHik3AJoCAAAA.',['子夜']='子夜晨曦:BAAALAAECgYIBgAAAA==.子夜月歌:BAAALAAECgEIAQAAAA==.子夜流火:BAAALAAECgIIAgAAAA==.',['孤烟']='孤烟:BAABLAAECn8fAAILAAYIdBNg3ABbAQALAAYIdBNg3ABbAQAAAA==.',['孤独']='孤独的错:BAAALAADCggICAAAAA==.',['守护']='守护永恒:BAAALAAECgUIBgAAAA==.',['安洁']='安洁莉卡:BAAALAAECgYIBgAAAA==.',['宝多']='宝多六花:BAAALAAECgYIDQAAAA==.',['寅虎']='寅虎:BAAALAAECgIIAgAAAA==.',['寒宵']='寒宵:BAAALAAFFAIIAgAAAA==.',['寒霜']='寒霜伯爵:BAAALAAECgYIBgAAAA==.',['對我']='對我彈琴:BAAALAAFFAIIAgAAAA==.',['小偷']='小偷:BAABLAAFFH8HAAIFAAIICwTZZAA2AAAFAAIICwTZZAA2AAAAAA==.',['小光']='小光青:BAAALAAFFAIIAgAAAA==.',['小兔']='小兔子嘚嘚帅:BAAALAADCgUIBQAAAA==.',['小小']='小小白一只:BAAALAADCgMIAwAAAA==.',['小情']='小情歌丶:BAAALAAECgUIDAAAAA==.',['小时']='小时候崴过腿:BAAALAAECgIIAgAAAA==.',['小白']='小白的老大:BAAALAAECgIIAgAAAA==.',['小聋']='小聋人丶:BAAALAAECgYICAAAAA==.',['小豆']='小豆芽:BAAALAADCgMIAwAAAA==.小豆苗呜呜:BAABLAAECn8VAAIDAAcIHBiUQwBNAQADAAcIHBiUQwBNAQAAAA==.',['小青']='小青光:BAABLAAFFH8LAAIVAAUIxAwBIwApAQAVAAUIxAwBIwApAQAAAA==.',['小鱼']='小鱼儿:BAAALAAECggIEAAAAA==.',['小龙']='小龙虾女神:BAAALAADCgcIBwAAAA==.',['尛尛']='尛尛熊丶:BAABLAAECn8cAAISAAcIxB10JAAFAgASAAcIxB10JAAFAgAAAA==.',['屠戮']='屠戮狂杀:BAAALAAECgYICAAAAA==.',['崔大']='崔大胖:BAAALAAECgQIBAAAAA==.',['左为']='左为门:BAABLAAFFH8sAAQCAAcI8RyVEAAMAgACAAcI8RyVEAAMAgAZAAIIwRf3IgBaAAAcAAEIwg95CQBHAAAAAA==.',['左手']='左手握右手:BAAALAAECgYIBgAAAA==.',['左未']='左未门:BAAALAAFFAIIAgAAAA==.',['市芄']='市芄银:BAABLAAFFH8YAAMLAAUIOA9cUwABAQALAAUIOA9cUwABAQAMAAIIigqmLABtAAAAAA==.',['希尔']='希尔瓦那斯:BAACLAAFFH8MAAILAAII9xYBlQBDAAALAAII9xYBlQBDAAAsAAQKfxoAAwsABgjXH3RBAMgBAAsABgjXH3RBAMgBAAwABggMEy9ZAFQBAAAA.',['帝殒']='帝殒之刃:BAAALAAECgEIAQAAAA==.',['带眼']='带眼镜小流氓:BAAALAAECggIEwAAAA==.带眼镜流氓:BAAALAAECgUIBQAAAA==.带眼镜的流氓:BAABLAAECn8WAAIDAAYIexFySwA0AQADAAYIexFySwA0AQAAAA==.带眼镜的程龙:BAAALAAECgYIBgAAAA==.',['平凡']='平凡过完这生:BAAALAADCgIIAgAAAA==.',['幼发']='幼发拉底河:BAAALAAECgYIDQAAAA==.',['彡天']='彡天使之翼彡:BAABLAAFFH8FAAILAAMI/Q6QeABrAAALAAMI/Q6QeABrAAAAAA==.',['彬酱']='彬酱:BAAALAADCgQIBAAAAA==.',['德道']='德道之鸟:BAAALAAECgcIDQAAAA==.',['忠诚']='忠诚的信士:BAAALAAECgcIBwAAAA==.',['忧傷']='忧傷调:BAACLAAFFH8tAAICAAcIIyLECAAxAgACAAcIIyLECAAxAgAsAAQKfzcABAIACAibJd0KAEMDAAIACAibJd0KAEMDABwABQjFF4kWAFsBABkAAwiXG/VqAMsAAAAA.',['快组']='快组我王瞾飞:BAAALAAFFAQIBAAAAA==.',['忽丨']='忽丨毙灬猎:BAAALAADCgUIBwAAAA==.',['恶魔']='恶魔之击:BAACLAAFFH8PAAIdAAII6RaWFwCgAAAdAAII6RaWFwCgAAAsAAQKfxUAAh0ABgjeGfkvAKwBAB0ABgjeGfkvAKwBAAAA.',['悄悄']='悄悄:BAAALAADCgQIBAAAAA==.',['惊羽']='惊羽:BAABLAAFFH8GAAILAAIIrho6QwChAAALAAIIrho6QwChAAAAAA==.',['愤怒']='愤怒的老二:BAAALAADCgQIBAAAAA==.',['慕思']='慕思秋水:BAABLAAFFH8FAAIVAAIIpA89PgBtAAAVAAIIpA89PgBtAAAAAA==.',['憨憨']='憨憨的土耳骑:BAAALAADCgQIBAAAAA==.',['懒虫']='懒虫灬混沌:BAAALAAECgYIBgAAAA==.',['我看']='我看你就行:BAAALAADCgYIBgAAAA==.',['战争']='战争机器:BAABLAAFFH8HAAIDAAIIZg51TwBFAAADAAIIZg51TwBFAAAAAA==.',['戦芸']='戦芸燚:BAAALAAECgUICAAAAA==.',['戴眼']='戴眼镜小流氓:BAAALAAECgYICQAAAA==.戴眼镜流氓:BAAALAAECgYICAAAAA==.',['户松']='户松遥:BAAALAAECgUIBQAAAA==.',['找大']='找大妈:BAABLAAFFH8NAAISAAMIBBEySwBqAAASAAMIBBEySwBqAAAAAA==.找大扎:BAAALAAFFAIIAgAAAA==.找大桃:BAACLAAFFH8MAAIPAAUIbAoxEgDxAAAPAAUIbAoxEgDxAAAsAAQKfxQAAw8ACAhNFSgQAJgBAA8ACAhNFSgQAJgBAA0AAwiIDT4eAH8AAAAA.找大瓜:BAACLAAFFH80AAMZAAYIuRiJAwAUAQACAAYIIRW3HwAqAQAZAAMIURqJAwAUAQAsAAQKfzIABBkACAhHH9UcABYCAAIACAgYHbM2AGACABkABwi6GdUcABYCABwAAwgbELwmALIAAAAA.找大蛙:BAAALAAFFAIIAgAAAA==.找大驴:BAABLAAFFH8HAAIeAAIIEA0NGwBfAAAeAAIIEA0NGwBfAAAAAA==.',['抓来']='抓来一顿捶:BAAALAAECgYIDwAAAA==.',['抖动']='抖动的双波:BAABLAAFFH8XAAIeAAYI3wlkEgAjAQAeAAYI3wlkEgAjAQAAAA==.',['抬手']='抬手揪毛:BAABLAAFFH8PAAIRAAYIvRL6IQB3AQARAAYIvRL6IQB3AQAAAA==.',['抽飞']='抽飞机:BAABLAAFFH8LAAMWAAYI2xfYBADvAQAWAAYI2xfYBADvAQASAAEInhZ9ZQBWAAAAAA==.',['招财']='招财小笨猫:BAABLAAFFH8HAAIGAAII2BXEFgBBAAAGAAII2BXEFgBBAAAAAA==.',['捉五']='捉五素本:BAAALAAECgYIDAAAAA==.',['攻强']='攻强:BAAALAADCggICAAAAA==.',['数师']='数师:BAAALAAFFAgIBAAAAA==.',['文君']='文君小宝贝儿:BAAALAADCgMIAwAAAA==.',['无风']='无风也无晴:BAAALAAFFAEIAgAAAA==.',['旺旺']='旺旺砕氷氷丶:BAAALAAECgYIEQAAAA==.',['明灬']='明灬千恩:BAABLAAECn8cAAMZAAYI3h6NHgALAgAZAAYI3h6NHgALAgACAAMIJgef5wB9AAAAAA==.明灬千骑:BAAALAADCgEIAQAAAA==.明灬重黎:BAAALAAECgYICgAAAA==.',['星之']='星之恶魔:BAAALAAECgYIBgAAAA==.星之裁决:BAAALAAECgYIBgAAAA==.',['星崎']='星崎八:BAAALAAECgcIBwAAAA==.',['春也']='春也迟迟:BAAALAAFFAEIAQAAAA==.',['春寒']='春寒料峭:BAAALAADCgYIBgAAAA==.',['春风']='春风十里:BAABLAAECn8XAAMDAAYIfhe1PwBcAQADAAYIfhe1PwBcAQAbAAIIoA2TWgAVAAAAAA==.',['晓舞']='晓舞:BAAALAAECgYIDAAAAA==.',['晓薇']='晓薇:BAAALAADCgYIBgAAAA==.',['晚睡']='晚睡的兔兔:BAABLAAFFH8PAAIeAAMI5gSbHABJAAAeAAMI5gSbHABJAAABLAAFFAUIHgATAOoNAA==.晚睡的猫猫:BAAALAAECggIDgABLAAFFAUIHgATAOoNAA==.',['晴天']='晴天之之:BAAALAAFFAIIAgAAAA==.',['暗影']='暗影术神:BAABLAAFFH8KAAICAAYIbRkSCgAjAgACAAYIbRkSCgAjAgAAAA==.暗影狂乱:BAAALAAFFAIIAgABLAAFFAYIMwAFAFQmAA==.',['暗黑']='暗黑凋零:BAAALAAECgcIBwAAAA==.暗黑破壞神:BAACLAAFFH8JAAMFAAMILwwQMgDBAAAFAAMIQAYQMgDBAAAGAAIIyw/jFQCBAAAsAAQKfyAAAwYABwhiIkUTAIYCAAYABwhiIkUTAIYCAAUABghXCj2lADwBAAAA.',['月下']='月下擒龙:BAAALAAECgYIBgABLAAFFAYIBgAXADcKAA==.',['月亮']='月亮祭司:BAABLAAFFH8MAAMVAAgIVB47AgDhAgAVAAgIVB47AgDhAgAUAAQIYg62GgDRAAAAAA==.',['月半']='月半小夜曲:BAAALAAECgYICQAAAA==.',['月海']='月海亭甘雨:BAAALAADCggICgAAAA==.',['朝夕']='朝夕夕:BAAALAADCggICAAAAA==.',['朝息']='朝息息:BAAALAADCgIIAgAAAA==.',['朱古']='朱古力:BAAALAAECgYIBgAAAA==.',['杏子']='杏子林:BAAALAAECgIIAgAAAA==.',['杠开']='杠开甩素本:BAAALAAECgYICQAAAA==.',['来自']='来自异界:BAAALAAECgcIBwAAAA==.',['杰小']='杰小宝:BAAALAAECgIIAwAAAA==.',['杰洛']='杰洛尼莫:BAAALAAECgYIBQAAAA==.',['板烧']='板烧鸡腿:BAABLAAECn8nAAISAAgIaxTkOwCpAQASAAgIaxTkOwCpAQAAAA==.',['极地']='极地狼神:BAABLAAFFH8FAAISAAUIKAoPOADAAAASAAUIKAoPOADAAAAAAA==.',['果蓖']='果蓖儿:BAAALAAECgYIBAABLAAFFAIIBQAHAEUMAA==.',['柒小']='柒小少:BAAALAAECgYIEwAAAA==.',['梦中']='梦中夏娜:BAAALAAECgYIBgAAAA==.',['梦想']='梦想天空:BAABLAAFFH8HAAIfAAMI7gmKDQC3AAAfAAMI7gmKDQC3AAAAAA==.',['梦游']='梦游精灵:BAAALAAECgYIBgAAAA==.',['楚鳳']='楚鳳琉璃:BAAALAADCgIIBAAAAA==.',['樊春']='樊春沐雨:BAAALAADCgIIAgAAAA==.',['樱丶']='樱丶謎離:BAAALAAECgUIBQAAAA==.',['止戰']='止戰灬之殇:BAABLAAFFH8MAAICAAYIaQ9GMABXAQACAAYIaQ9GMABXAQAAAA==.',['正版']='正版菜鸟:BAAALAAECgYIBgAAAA==.',['水星']='水星上的萌货:BAAALAAECgQIDAAAAA==.',['永恒']='永恒的骑士:BAAALAAECgYIBgAAAA==.',['汪汪']='汪汪饺饺狗:BAAALAAECggICAAAAA==.',['泌月']='泌月:BAAALAAFFAIIBAAAAA==.',['法師']='法師:BAAALAAFFAYIBAAAAA==.',['注意']='注意宝珠:BAAALAADCggICAAAAA==.',['泪天']='泪天宇:BAAALAAECgYICQAAAA==.',['洛斯']='洛斯福:BAACLAAFFH8HAAIHAAYIhATUSAAUAQAHAAYIhATUSAAUAQAsAAQKfyUAAgcABghlG247AI8BAAcABghlG247AI8BAAAA.',['洛枫']='洛枫丶:BAABLAAFFH8GAAILAAYIqhv7MwBrAQALAAYIqhv7MwBrAQAAAA==.',['活的']='活的无可取代:BAAALAAECgYIBgAAAA==.',['浪子']='浪子云翼:BAAALAADCgUIBQAAAA==.',['浮笙']='浮笙:BAAALAADCggICAAAAA==.',['混沌']='混沌灾星:BAACLAAFFH8IAAMEAAIIrRAQBgCBAAADAAIIrRAkNACaAAAEAAIInwcQBgCBAAAsAAQKfxgAAwQABwhtF5kRALwBAAMABwjfEvpoAL0BAAQABwigFpkRALwBAAAA.',['溜哒']='溜哒丶:BAAALAADCgEIAQAAAA==.',['漂亮']='漂亮不打折:BAAALAADCgUIBQAAAA==.',['漫天']='漫天花雨:BAAALAAECgYICgAAAA==.',['潇洒']='潇洒小哲哥:BAAALAADCgcIBwAAAA==.',['灬一']='灬一条龙灬:BAABLAAECn8YAAIdAAYI4BKOEgA+AQAdAAYI4BKOEgA+AQAAAA==.',['灬丨']='灬丨异灵丨灬:BAACLAAFFH8FAAIZAAUIWwkGAgA+AQAZAAUIWwkGAgA+AQAsAAQKfxQAAxkACAjUIQMOAJQCABkABwgdIwMOAJQCAAIAAQjXGK7/AD8AAAAA.灬丨影魅丨灬:BAAALAAFFAEIAQAAAA==.',['灬绝']='灬绝色妖姬灬:BAAALAAFFAIIBAAAAA==.',['灬闰']='灬闰土灬:BAAALAAECgcIEwAAAA==.',['灭天']='灭天一箭:BAAALAADCggICAAAAA==.',['炎菲']='炎菲:BAABLAAFFH8IAAIMAAYI7QNzCwDbAAAMAAYI7QNzCwDbAAAAAA==.',['烟雨']='烟雨踏歌行:BAABLAAFFH8HAAIbAAIIoQ05IwB3AAAbAAIIoQ05IwB3AAAAAA==.',['热心']='热心市民黑熊:BAAALAAECgYIEgAAAA==.',['热血']='热血:BAACLAAFFH8NAAISAAIIpBI4ZQBEAAASAAIIpBI4ZQBEAAAsAAQKfxQAAhIABgi+HX9HAIYBABIABgi+HX9HAIYBAAAA.',['無颜']='無颜之月:BAABLAAFFH8IAAISAAYIfRajBQANAgASAAYIfRajBQANAgAAAA==.',['焱森']='焱森靐淼飍:BAACLAAFFH8PAAIFAAYINRgMJQCAAQAFAAYINRgMJQCAAQAsAAQKfx8AAgUACAipG6ksAJkCAAUACAipG6ksAJkCAAAA.',['焱菲']='焱菲:BAAALAAECgYIBgAAAA==.',['燃烧']='燃烧的鸡翅:BAAALAADCgEIAQAAAA==.',['爪击']='爪击:BAAALAAECgYIBgAAAA==.',['爱你']='爱你一小下:BAAALAAECgYIBwAAAA==.',['爱吃']='爱吃酱油拌饭:BAAALAAFFAYIAwAAAA==.',['爺恐']='爺恐怖人物:BAAALAAFFAIIAwAAAA==.',['牛呣']='牛呣呣:BAAALAAFFAIIAgAAAA==.',['牛萨']='牛萨:BAACLAAFFH8HAAIKAAIIORpTRQCWAAAKAAIIORpTRQCWAAAsAAQKfxYAAgoACAjZD6OtACUBAAoACAjZD6OtACUBAAAA.',['犄角']='犄角长见识短:BAAALAAFFAIIBAAAAA==.',['狂烈']='狂烈:BAAALAAECgUIBQAAAA==.',['狂龍']='狂龍戰魔:BAAALAAECggICAAAAA==.',['狼哥']='狼哥:BAAALAADCgIIAgAAAA==.',['猎狞']='猎狞人:BAABLAAFFH8YAAILAAUI/RLqTAAZAQALAAUI/RLqTAAZAQAAAA==.',['猎王']='猎王:BAAALAAECgUIBQAAAA==.',['猛张']='猛张飛:BAAALAAECgIIAgAAAA==.',['献世']='献世:BAACLAAFFH8IAAIVAAIIBwL0SgBRAAAVAAIIBwL0SgBRAAAsAAQKfxgAAhUABgg0Dxo6AAABABUABgg0Dxo6AAABAAEsAAUUAggNAA4A6xEA.',['王曌']='王曌飞丶:BAAALAAECggIAgAAAA==.',['玖儿']='玖儿呀:BAAALAADCggICAAAAA==.',['甄尐']='甄尐妃:BAAALAAECgQIBQAAAA==.',['甜小']='甜小甜:BAABLAAFFH8JAAICAAUI0wcVPgAGAQACAAUI0wcVPgAGAQAAAA==.',['番茄']='番茄蛋:BAACLAAFFH8vAAIBAAYIIh1KEQC0AQABAAYIIh1KEQC0AQAsAAQKfzQAAgEACAglI0gOAB0DAAEACAglI0gOAB0DAAAA.',['疯吃']='疯吃毛豆角:BAAALAAECgYIBgAAAA==.',['疯狂']='疯狂大炮:BAAALAAECgcIBwAAAA==.疯狂小萨:BAACLAAFFH8HAAIKAAMI8ga3WQBnAAAKAAMI8ga3WQBnAAAsAAQKfxwAAgoACAi9EoQ8AGkBAAoACAi9EoQ8AGkBAAAA.疯狂的胖子丶:BAAALAAECgEIAQAAAA==.',['看秘']='看秘密教学:BAAALAAECggIDgAAAA==.',['真心']='真心不灭:BAAALAAECgMIAwAAAA==.',['真部']='真部落无敌:BAABLAAFFH8KAAQJAAgIMQS/LgBEAAAJAAYIXQW/LgBEAAAQAAEIRAHWEgAFAAAYAAEIFwAaEwACAAAAAA==.',['瞎眼']='瞎眼老六丶:BAAALAAECgUICAAAAA==.',['矮丑']='矮丑法王:BAACLAAFFH8gAAIKAAYIpx54CwAXAgAKAAYIpx54CwAXAgAsAAQKfxQAAgoABwjZIakjAIQCAAoABwjZIakjAIQCAAAA.',['石榴']='石榴儿:BAAALAAFFAIIAgAAAA==.',['破天']='破天刈剑:BAAALAAECgQIBAAAAA==.',['破碎']='破碎精灵:BAABLAAFFH8GAAIdAAIIyhAxFwCiAAAdAAIIyhAxFwCiAAAAAA==.',['碎月']='碎月沉星:BAAALAAECgMIAwAAAA==.',['祖龙']='祖龙游道:BAAALAAECgYIDAAAAA==.',['神秘']='神秘之神秘:BAAALAAECgIIAwAAAA==.',['笑一']='笑一笑吓死人:BAACLAAFFH8GAAILAAIIHhXngwBNAAALAAIIHhXngwBNAAAsAAQKfxYAAgsABghFHvFIALUBAAsABghFHvFIALUBAAAA.',['米奈']='米奈希尔:BAABLAAECn8XAAISAAYIeBxqggDnAQASAAYIeBxqggDnAQAAAA==.',['米娅']='米娅:BAAALAAECgUIBQAAAA==.',['糖果']='糖果哈尼:BAAALAAECggIEAAAAA==.',['素酒']='素酒:BAAALAAECgQIBAAAAA==.',['索伦']='索伦灬辉须:BAAALAAECgIIAgAAAA==.',['紫色']='紫色皮皮虾:BAAALAAECggIEAAAAA==.',['纯冰']='纯冰羊:BAAALAAECgYIBgAAAA==.',['给力']='给力:BAAALAAECgUIBQAAAA==.',['罗得']='罗得里克斯:BAABLAAFFH8MAAIFAAMIehRGLgDXAAAFAAMIehRGLgDXAAAAAA==.',['老关']='老关头:BAAALAAECgYIBgAAAA==.',['聂伯']='聂伯岚:BAACLAAFFH8KAAIbAAII6RKcHgCBAAAbAAII6RKcHgCBAAAsAAQKfxUAAhsABggPGeBBAHwBABsABggPGeBBAHwBAAEsAAUUAggMABIAXxwA.',['肉少']='肉少抗不住:BAABLAAFFH8VAAIeAAYIShOSDwBQAQAeAAYIShOSDwBQAQAAAA==.',['胖宝']='胖宝宝:BAAALAAECgYIBgAAAA==.',['自奏']='自奏圣乐:BAACLAAFFH8zAAIFAAYIVCauCwArAgAFAAYIVCauCwArAgAsAAQKfysAAgUACAg2JOoGAKkCAAUACAg2JOoGAKkCAAAA.',['自鸣']='自鸣天琴:BAAALAAFFAEIAQABLAAFFAYIMwAFAFQmAA==.',['花子']='花子:BAACLAAFFH8NAAIFAAMIJBkoNQC0AAAFAAMIJBkoNQC0AAAsAAQKfyIAAgUACAjpHT8uAJICAAUACAjpHT8uAJICAAAA.',['苍山']='苍山雪:BAAALAAECgUIBgAAAA==.',['苍白']='苍白歌者:BAAALAADCggICgAAAA==.',['苏醒']='苏醒的哈利:BAABLAAECn8YAAILAAcIMRzbWgAnAgALAAcIMRzbWgAnAgAAAA==.苏醒的背叛:BAAALAAECgUIBAAAAA==.',['英俊']='英俊少年:BAAALAAECgYIBgAAAA==.',['范达']='范达尔偷盔:BAAALAAECggIEQAAAA==.',['茵蒂']='茵蒂克丝:BAAALAAECgEIAQAAAA==.',['草莓']='草莓硬糖:BAAALAAECgYIDAAAAA==.草莓酱:BAAALAAFFAIIAgAAAA==.',['莉娅']='莉娅:BAAALAAECgEIAQAAAA==.',['莱恩']='莱恩曼妮:BAACLAAFFH8xAAICAAYIaw4SMABYAQACAAYIaw4SMABYAQAsAAQKfzwAAgIACAiRGf46AE0CAAIACAiRGf46AE0CAAAA.',['菲洛']='菲洛不会飞:BAAALAAECgYIDAAAAA==.',['萨安']='萨安德萨:BAAALAAECgQIBAAAAA==.',['萨拉']='萨拉曼蒂妮:BAAALAAECgYIDAAAAA==.',['蓝色']='蓝色皮卡丘:BAAALAAECgYICwAAAA==.',['薇尔']='薇尔莉特:BAAALAAECgYICAAAAA==.',['见时']='见时难别亦难:BAAALAAECgYIDQAAAA==.',['诅咒']='诅咒:BAABLAAFFH8QAAIUAAIIQxbVJgBKAAAUAAIIQxbVJgBKAAAAAA==.',['谁是']='谁是谁菲:BAACLAAFFH8MAAIGAAIIGQwJHABdAAAGAAIIGQwJHABdAAAsAAQKf0AAAgYACAjaE84sAMwBAAYACAjaE84sAMwBAAAA.',['贝尔']='贝尔蒙特:BAAALAADCgEIAQAAAA==.',['赵曰']='赵曰天大魔王:BAABLAAFFH8KAAICAAYIrh3dHACsAQACAAYIrh3dHACsAQAAAA==.',['踌海']='踌海:BAABLAAFFH8JAAMKAAMILg+APACIAAAKAAMILg+APACIAAABAAIILwMdOAByAAAAAA==.',['达分']='达分奇:BAABLAAFFH8OAAILAAIIEhqnlwBBAAALAAIIEhqnlwBBAAAAAA==.',['达文']='达文西:BAAALAADCggICAAAAA==.',['过河']='过河卒:BAAALAAECgMIAwAAAA==.',['速度']='速度灭啊:BAABLAAFFH8LAAMIAAMIBBtyHACxAAAIAAIImh9yHACxAAAQAAMIoAEhDQAxAAAAAA==.',['遮天']='遮天斬:BAAALAADCgEIAQAAAA==.',['遵纪']='遵纪守法:BAAALAAECgEIAQAAAA==.',['邪王']='邪王真眼:BAAALAAECgcIDQAAAA==.',['鑫森']='鑫森淼焱垚燚:BAAALAAECgYICwAAAA==.',['防护']='防护林:BAABLAAFFH8IAAIKAAIIgRj5QACAAAAKAAIIgRj5QACAAAAAAA==.',['阿尔']='阿尔塞斯之怒:BAAALAAECggIAwAAAA==.',['雨天']='雨天农村喂鸡:BAABLAAFFH8JAAMGAAIIxhIHFgCAAAAGAAIIqQwHFgCAAAAFAAIIxhIvUQBLAAAAAA==.',['雪拉']='雪拉扎德:BAAALAAECgUIBQAAAA==.',['雷磷']='雷磷:BAAALAAECggICAABLAAFFAYIDwAFADUYAA==.',['雷霆']='雷霆灬嘎巴:BAAALAADCgcIBwAAAA==.',['非常']='非常牛:BAAALAAECgcIEwAAAA==.',['非牛']='非牛类:BAACLAAFFH8MAAILAAIIVBahWwCOAAALAAIIVBahWwCOAAAsAAQKfzUAAwsACAj1HRMwAJkCAAsACAj1HRMwAJkCAAwAAQimA2rQAB0AAAEsAAUUAggQAAcAnBQA.',['音调']='音调:BAAALAAFFAQIBAAAAA==.',['须弥']='须弥:BAAALAAECgEIAQAAAA==.',['颜柏']='颜柏:BAAALAAECgYICgAAAA==.',['首府']='首府老大爷:BAAALAAECgQIBAAAAA==.',['高大']='高大善人变形:BAACLAAFFH8pAAIQAAYIjApAAQBkAQAQAAYIjApAAQBkAQAsAAQKfx0AAhAACAiaE04QANgBABAACAiaE04QANgBAAEsAAUUBwguACAAqBUA.',['鬼麟']='鬼麟丨小乐:BAABLAAECn8mAAQSAAcItxtVMQDNAQASAAcItxtVMQDNAQAWAAYIpwZtVwD0AAAgAAUIvwcHNgB6AAAAAA==.',['魔焰']='魔焰梅尔德拉:BAAALAAECgIIAgAAAA==.',['魔王']='魔王复活:BAABLAAFFH8fAAIRAAYITxZaHQCOAQARAAYITxZaHQCOAQAAAA==.',['鱼片']='鱼片儿:BAABLAAFFH8MAAIRAAUIVwxMMAAUAQARAAUIVwxMMAAUAQAAAA==.',['鱼香']='鱼香肉丝:BAAALAADCgYIBgAAAA==.',['鱼骨']='鱼骨铮铮:BAAALAAECgYIBgAAAA==.',['鸭梨']='鸭梨黎:BAACLAAFFH8GAAIRAAMIUAkEQwB/AAARAAMIUAkEQwB/AAAsAAQKfxcAAhEACAhLDRpIAEIBABEACAhLDRpIAEIBAAAA.',['黑胡']='黑胡椒喷嚏:BAABLAAECn8cAAQYAAcIfBGPDwA5AQAYAAQIahqPDwA5AQAIAAYIWQy3SQDvAAAQAAYI5QbAJgDTAAAAAA==.',['黯月']='黯月织法:BAAALAAECgMIAwAAAA==.',['龙息']='龙息玛莎拉:BAAALAAFFAIIAgAAAA==.',['龙逸']='龙逸轩:BAACLAAFFH8IAAISAAIIfBMJRQCbAAASAAIIfBMJRQCbAAAsAAQKfysAAhIACAjdITwiAOgCABIACAjdITwiAOgCAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end