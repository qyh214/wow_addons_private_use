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
 local lookup = {'Hunter-BeastMastery','Rogue-Subtlety','Rogue-Assassination','Shaman-Restoration','Shaman-Elemental','Warrior-Fury','Rogue-Outlaw','Priest-Discipline','Priest-Holy','DeathKnight-Unholy','DeathKnight-Frost','Priest-Shadow','DemonHunter-Havoc','Shaman-Enhancement','Warrior-Protection','Warlock-Destruction','Unknown-Unknown','Druid-Restoration','Druid-Balance','Druid-Feral','DeathKnight-Blood','Mage-Arcane','Mage-Frost','Paladin-Holy','Paladin-Retribution','Paladin-Protection','Hunter-Marksmanship','Druid-Guardian','Warlock-Demonology','Hunter-Survival','DemonHunter-Vengeance','Evoker-Devastation','Evoker-Preservation','Warlock-Affliction','Monk-Mistweaver','Monk-Brewmaster','Evoker-Augmentation',}; local provider = {region='CN',realm='凯恩血蹄',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alxamuren:BAABLAAFFH8GAAIBAAYIDgqmSQAlAQABAAYIDgqmSQAlAQAAAA==.',Am='Ame:BAACLAAFFH8GAAICAAIIHAvgFACHAAACAAIIHAvgFACHAAAsAAQKfxQAAwIABggTHbIYANUBAAIABgg8HLIYANUBAAMABgipF14vALEBAAAA.',An='Angeliar:BAABLAAFFH8RAAMEAAYIPws8QAClAAAEAAMImBM8QAClAAAFAAYI4ALEOwBZAAAAAA==.',Bb='Bbt:BAACLAAFFH8IAAIGAAMIkxy8MwCmAAAGAAMIkxy8MwCmAAAsAAQKfyUAAgYACAgCHnYVADYCAAYACAgCHnYVADYCAAAA.',Bl='Blacksun:BAAALAADCgYIBgAAAA==.',Br='Breakbeat:BAABLAAECn8UAAIHAAcIrRJJDACpAQAHAAcIrRJJDACpAQAAAA==.',Ch='Christao:BAAALAAECgIIBgAAAA==.',Do='Doraemonc:BAAALAAECgIIAgAAAA==.',Em='Emor:BAABLAAFFH8JAAMIAAIIchMkAwCMAAAIAAIIchMkAwCMAAAJAAEI+QiaSQBCAAAAAA==.',Fl='Fliedmiles:BAAALAAECggIEwAAAA==.',Gb='Gb:BAAALAADCgMIAwAAAA==.',Gn='Gnaeus:BAAALAAECgYIBgAAAA==.',Gr='Grand:BAAALAAECgMIAwAAAA==.',He='Hela:BAAALAAECgYIBgAAAA==.',Ia='Iaintime:BAAALAAECgYIDwAAAA==.',Ic='Icebule:BAAALAAECgYIDQAAAA==.',Im='Imabadgirl:BAAALAAECgYICwAAAA==.',Ir='Irelia:BAABLAAFFH8KAAMKAAIIRQ7yEQBOAAAKAAIIRQ7yEQBOAAALAAEIQgzYogA3AAAAAA==.Irissa:BAAALAAECgUIBwAAAA==.',Li='Lichjin:BAAALAAECgEIAQABLAAFFAgIFQALAM4TAA==.Lina:BAAALAADCgIIAgAAAA==.Lizard:BAAALAAECgYIBgAAAA==.',Ll='Llucas:BAAALAADCgYICQAAAA==.',Lo='Lorele:BAACLAAFFH8SAAMJAAUI+R6HEAA4AQAJAAUI+R6HEAA4AQAMAAMImAfiIgBpAAAsAAQKfx4AAgkABwjpJBIUAMkCAAkABwjpJBIUAMkCAAEsAAUUBggRAAQAPwsA.',Ma='Mayden:BAAALAAECgMIAwAAAA==.',Mo='Mograine:BAAALAAECgQIBAAAAA==.',Mv='Mv:BAABLAAFFH8KAAINAAIIGBxjTQBLAAANAAIIGBxjTQBLAAAAAA==.',Na='Narassin:BAAALAAECgYIDgAAAA==.Natasha:BAAALAADCggICwAAAA==.',Nu='Nuit:BAAALAAECgYIEgAAAA==.',Ri='Rikivg:BAAALAADCggICAAAAA==.',Ro='Rogueedison:BAAALAAECgYIDgAAAA==.',Sa='Saoxingxing:BAABLAAFFH8vAAMFAAYI2iTKCgD/AQAFAAYIwiTKCgD/AQAOAAEIOyX7CABeAAAAAA==.',Sc='Scars:BAAALAAECgYIBwAAAA==.',Sh='Shiho:BAABLAAFFH8FAAIEAAII/wnqZgBUAAAEAAII/wnqZgBUAAAAAA==.',Vi='Vigaar:BAAALAAFFAIIBAAAAA==.Viggar:BAABLAAFFH8rAAIPAAYIJxcZBwCSAQAPAAYIJxcZBwCSAQAAAA==.',Wa='Warjin:BAAALAAECgYIBgAAAA==.',Wt='Wtfly:BAACLAAFFH8LAAIQAAIIsRAAQACYAAAQAAIIsRAAQACYAAAsAAQKfyEAAhAACAg3GpI0AGgCABAACAg3GpI0AGgCAAEsAAUUCAgEABEAAAAA.',Yh='Yhuofens:BAAALAAFFAIIBAAAAA==.',['一两']='一两怪味:BAAALAAFFAIIAgAAAA==.',['一条']='一条龙:BAAALAAECgYIBwAAAA==.',['一身']='一身正气:BAAALAAFFAMIAwAAAA==.',['一页']='一页书:BAAALAAECgYICgAAAA==.',['一饼']='一饼:BAAALAAFFAIIAgAAAA==.',['七七']='七七爱喝酸奶:BAAALAAECgYIDAAAAA==.',['三两']='三两素椒:BAAALAAECgQIBAAAAA==.',['三生']='三生法相:BAAALAAECgYIEwAAAA==.',['三筒']='三筒:BAAALAAECgYIAwAAAA==.',['三色']='三色同顺:BAAALAAECgYICwAAAA==.',['三问']='三问九摇头:BAAALAAECgUIBgAAAA==.',['下游']='下游的老人:BAAALAAECgIIAgAAAA==.',['两只']='两只小鸡仔:BAAALAAFFAQIAwAAAA==.',['丨丶']='丨丶戰丗:BAABLAAECn8VAAIGAAYIUxR3ewCRAQAGAAYIUxR3ewCRAQAAAA==.',['丨国']='丨国产专区丨:BAAALAAECgYIBgAAAA==.',['丨影']='丨影子丨:BAABLAAFFH8RAAIDAAYIyB5kBQDVAQADAAYIyB5kBQDVAQAAAA==.',['丨愛']='丨愛殇丨:BAAALAADCggIFgAAAA==.',['丨梦']='丨梦灬初醒丨:BAABLAAFFH8uAAMMAAYIdhjqCwCYAQAMAAYIdhjqCwCYAQAJAAUI8BdLDwBNAQAAAA==.',['丨灬']='丨灬天下:BAAALAAFFAMIAwAAAA==.',['丨饺']='丨饺子丨:BAABLAAFFH8OAAILAAYITx0DGwDLAQALAAYITx0DGwDLAQAAAA==.',['丨骨']='丨骨头盾丨:BAAALAADCgIIAgAAAA==.',['中指']='中指朝天立:BAABLAAFFH8GAAIQAAMIPASsUwBgAAAQAAMIPASsUwBgAAAAAA==.',['丶丨']='丶丨朮師:BAAALAAECgYIBwAAAA==.',['丶杰']='丶杰杀:BAAALAAECgEIAQAAAA==.',['丶氣']='丶氣質:BAABLAAFFH8LAAIPAAYIORgmBADwAQAPAAYIORgmBADwAQAAAA==.',['丿放']='丿放丶逐:BAAALAAECgIIAgAAAA==.',['乔霸']='乔霸霸丶:BAAALAAECgEIAQAAAA==.',['乖啊']='乖啊宝贝:BAABLAAFFH8KAAIBAAIIyCQcNQC6AAABAAIIyCQcNQC6AAAAAA==.',['九万']='九万:BAAALAAFFAIIAgAAAA==.',['九方']='九方赤命:BAAALAAECgYICQAAAA==.',['九筒']='九筒:BAAALAAFFAIIAwAAAA==.',['九重']='九重:BAAALAAECgcICQAAAA==.',['了布']='了布德:BAABLAAFFH8oAAQSAAcIJB2SBQBYAgASAAcIJB2SBQBYAgATAAMIuAzzHwC/AAAUAAIIhQp8DwCNAAAAAA==.',['事了']='事了拂身去:BAAALAAECgMIAwAAAA==.',['二两']='二两炸酱:BAAALAADCgQIBAAAAA==.',['二冲']='二冲:BAAALAAECgYICAAAAA==.',['二四']='二四零下铺:BAAALAAECgMIAwAAAA==.',['云岭']='云岭茉莉白:BAAALAAECgMIAwAAAA==.',['云隐']='云隐雷霆:BAABLAAFFH8RAAMEAAQIjBGVMgDeAAAEAAQIjBGVMgDeAAAFAAEIvwGbVAAkAAAAAA==.',['五皮']='五皮皮:BAAALAAFFAIIBAABLAAFFAYILgAMAHYYAA==.',['五筒']='五筒:BAAALAAFFAIIAgAAAA==.',['什么']='什么砖家:BAAALAAECgYIEAAAAA==.',['以刀']='以刀相许:BAAALAADCgEIAQAAAA==.',['众神']='众神波塞顿:BAAALAAECgYIBwAAAA==.',['伤别']='伤别离:BAAALAAECgYIEgAAAA==.',['你充']='你充币没:BAABLAAECn8WAAMLAAcIqRb3TwBVAQALAAcIMBb3TwBVAQAVAAEIgRCUSwA7AAAAAA==.',['你干']='你干嘛哎哟:BAABLAAFFH8iAAMSAAYI6hjZDgDSAQASAAYI6hjZDgDSAQATAAQIigI1KwBZAAABLAAFFAgIOAASAPIaAA==.',['你死']='你死我活:BAAALAAECgYIBgAAAA==.',['你还']='你还在等什么:BAAALAAECgQIBAAAAA==.',['俊克']='俊克总总:BAAALAAECgMIAwABLAAFFAgIAwARAAAAAA==.',['倍儿']='倍儿气质:BAAALAAFFAEIAQAAAA==.',['假装']='假装认真学习:BAABLAAFFH8GAAILAAMIkxR9LQDkAAALAAMIkxR9LQDkAAAAAA==.',['做大']='做大哥的无奈:BAAALAAECgIIAgAAAA==.',['偶心']='偶心飞翔:BAAALAAFFAIIAgAAAA==.',['傲尘']='傲尘:BAACLAAFFH8QAAIWAAYISBQAKwBlAQAWAAYISBQAKwBlAQAsAAQKfxcAAxcABwiDHRgpAOIBABYABwi+G3VQABMCABcABgiXHxgpAOIBAAAA.',['傲笑']='傲笑红尘:BAAALAAECgYIBgAAAA==.',['元素']='元素的大灰狼:BAAALAAECgUIBQAAAA==.',['光明']='光明大师:BAAALAAFFAYIAgAAAA==.',['光荣']='光荣屠夫:BAAALAAECgYIDAABLAAFFAIIAgARAAAAAA==.光荣崛起:BAAALAAFFAIIAgAAAA==.光荣领唱者:BAAALAAECgMIAwABLAAFFAIIAgARAAAAAA==.',['关键']='关键部位:BAAALAAECgEIAQAAAA==.',['内部']='内部:BAAALAAECgYIBgAAAA==.',['冰冰']='冰冰有火:BAACLAAFFH8QAAIYAAIImhG1HgCLAAAYAAIImhG1HgCLAAAsAAQKf1wABBgACAjdIdoDAOICABgACAjdIdoDAOICABkACAhgHEcgABsCABoAAQhIHktyAEUAAAAA.',['冰寒']='冰寒刺骨:BAAALAADCgQIBAAAAA==.',['冰封']='冰封雪雨:BAAALAAECgYIBgAAAA==.',['冷月']='冷月如霜:BAAALAAECgYICwAAAA==.',['凯恩']='凯恩血爪:BAABLAAECn8dAAMSAAcIyRR7WgCFAQASAAYIHxZ7WgCFAQATAAcILg06UgBtAQAAAA==.',['凶悍']='凶悍的亮亮:BAACLAAFFH8NAAINAAMI5AkIJADSAAANAAMI5AkIJADSAAAsAAQKfx0AAg0ABwjhIClGAE8CAA0ABwjhIClGAE8CAAAA.',['刀贱']='刀贱笑:BAAALAAECgQIBAAAAA==.',['刺血']='刺血箭梅:BAAALAADCgYIBgAAAA==.',['劣人']='劣人阿轰:BAABLAAFFH8WAAMBAAUIqhwzNwBhAQABAAUIqhwzNwBhAQAbAAMIPxq8FwCvAAAAAA==.',['北方']='北方阿一:BAAALAADCggIGQAAAA==.',['千鸟']='千鸟雷鸣:BAAALAAECgYIBgAAAA==.',['半个']='半个西瓜:BAABLAAFFH8IAAIJAAIIPAnZRABhAAAJAAIIPAnZRABhAAAAAA==.',['又见']='又见小哥:BAAALAAFFAMIBAAAAA==.',['史蒂']='史蒂夫考:BAAALAAFFAIIBAAAAA==.',['吉姆']='吉姆利丶铜须:BAAALAADCgIIAgAAAA==.吉姆利铜须:BAAALAADCgEIAQAAAA==.',['君岛']='君岛美緖:BAAALAAFFAIIBAAAAA==.',['吴风']='吴风:BAAALAAECgYIBgAAAA==.',['吾名']='吾名不浪:BAACLAAFFH8YAAMLAAUIvREERAArAQALAAUIvREERAArAQAKAAIIvxH0EQCRAAAsAAQKfxQAAwsABwgVIKVoACQCAAsABghaH6VoACQCAAoAAwjaFjM9APEAAAAA.',['周大']='周大意:BAABLAAFFH8nAAMEAAYIcxG4HAB2AQAEAAYIcxG4HAB2AQAFAAQIlwE7OgBrAAABLAAFFAgIOAASAPIaAA==.',['味淡']='味淡得卤一下:BAACLAAFFH8LAAMSAAQIOwhsIQCfAAASAAQIOwhsIQCfAAAcAAMIuwdGCQBUAAAsAAQKfxYAAhIACAiAFgUZAAYCABIACAiAFgUZAAYCAAAA.',['命逸']='命逸:BAAALAAFFAIIBAAAAA==.',['哀仇']='哀仇:BAAALAAFFAIIBAAAAA==.',['喔咪']='喔咪陀拂:BAABLAAFFH8HAAISAAMIWB+gJAD1AAASAAMIWB+gJAD1AAAAAA==.',['喵喵']='喵喵吥是猫猫:BAAALAAECgYICQAAAA==.喵喵是只猫:BAAALAAECgYIDAAAAA==.',['嘿巴']='嘿巴扎嘿:BAAALAAFFAIIAgAAAA==.',['噢佛']='噢佛歪特丶:BAAALAAFFAIIBAAAAA==.',['噢嘛']='噢嘛咪嘛咪吽:BAAALAADCgIIAgAAAA==.',['國王']='國王的訃告:BAAALAAECggIDQAAAA==.',['圣光']='圣光神圣:BAABLAAFFH8GAAIZAAUIOgoUNADhAAAZAAUIOgoUNADhAAAAAA==.',['圣意']='圣意女神娟娟:BAAALAAECgcICwAAAA==.',['圣殿']='圣殿丶流星:BAABLAAECn8VAAMXAAcINxqTHgAmAgAXAAcINxqTHgAmAgAWAAQIggmVYAB9AAAAAA==.',['坚毅']='坚毅铜:BAAALAAECgYIBgAAAA==.',['埃逗']='埃逗芙汝:BAAALAAECgYIBgAAAA==.',['塔格']='塔格奥:BAAALAAECgYIEQABLAAFFAIIAgARAAAAAA==.',['壹怒']='壹怒为红颜:BAAALAAECgMIAwAAAA==.',['壹米']='壹米捌壹:BAABLAAFFH8GAAIZAAIIRQvUdAA7AAAZAAIIRQvUdAA7AAAAAA==.壹米捌柒:BAABLAAFFH8HAAIBAAII5Qx6pwA7AAABAAII5Qx6pwA7AAAAAA==.壹米捌贰:BAAALAAFFAIIBAAAAA==.壹米捌零:BAABLAAFFH8GAAIFAAIIIQpNTwA2AAAFAAIIIQpNTwA2AAAAAA==.壹米柒柒:BAAALAAFFAIIAgAAAA==.',['夏多']='夏多雷:BAAALAAECgEIAQAAAA==.',['夕夜']='夕夜:BAAALAAECgYICAAAAA==.',['多项']='多项全能:BAAALAADCgIIAgAAAA==.',['夜游']='夜游神丶:BAAALAAECgcICAAAAA==.',['夜雨']='夜雨绯红:BAAALAADCgQIBAAAAA==.',['夜风']='夜风:BAAALAAECgYIDwAAAA==.',['大伯']='大伯:BAAALAAECgYIDwAAAA==.',['大力']='大力川川:BAAALAAECgYIEQAAAA==.',['大召']='大召唤之术:BAAALAAECgYIBgAAAA==.',['大地']='大地忽悠你:BAAALAAECgYIDgAAAA==.',['大棒']='大棒槌:BAABLAAFFH8GAAIZAAYIRhV1FwCWAQAZAAYIRhV1FwCWAQAAAA==.',['大熊']='大熊猫:BAABLAAFFH8JAAILAAMI9AvWZACCAAALAAMI9AvWZACCAAAAAA==.',['大鸿']='大鸿牛:BAAALAAECgEIAQAAAA==.',['天上']='天上云万朵:BAAALAAFFAYIAwABLAAFFAgIHgABADkbAA==.',['天佑']='天佑晨曦:BAAALAAECgYIDAAAAA==.',['天堂']='天堂猎手:BAAALAAECgMIAwAAAA==.天堂的蓝调:BAACLAAFFH8IAAIdAAIIERhcFwCVAAAdAAIIERhcFwCVAAAsAAQKfxcAAx0ABwhtG5caACUCAB0ABwj4GZcaACUCABAABQiXFXWcAEMBAAAA.',['天灾']='天灾符文:BAAALAADCgMIAwAAAA==.',['天王']='天王盖地虎丨:BAAALAAFFAIIBAAAAA==.',['天禄']='天禄貔貅:BAAALAAFFAIIAgAAAA==.',['天青']='天青涩等艳遇:BAAALAAFFAIIAgABLAAFFAMIDgASAPsfAA==.',['奎尔']='奎尔萨拉之王:BAAALAAECgcIDwAAAA==.',['奔放']='奔放的小番茄:BAAALAAECgEIAQAAAA==.',['女子']='女子无才:BAAALAAECgYICgAAAA==.',['好几']='好几百个恶魔:BAAALAAECgYIBgAAAA==.好几百个锤子:BAAALAAECgYIBgAAAA==.',['如影']='如影随行丶:BAAALAADCgYIBgAAAA==.',['如法']='如法炮制:BAAALAAECgYIDAAAAA==.',['妞妞']='妞妞:BAAALAADCgUIBQAAAA==.',['妩嫦']='妩嫦:BAAALAAECgYIDAAAAA==.妩嫦婧:BAABLAAECn8UAAIXAAYIgRCdSQBKAQAXAAYIgRCdSQBKAQAAAA==.',['姨妈']='姨妈喷发:BAACLAAFFH8dAAILAAYIXxc9JwCZAQALAAYIXxc9JwCZAQAsAAQKfxwAAwsACAiTGrQaABcCAAsACAiTGrQaABcCABUAAQhQAv41ABgAAAAA.',['子逸']='子逸:BAAALAAECggICAAAAA==.',['宇智']='宇智波卡卡西:BAABLAAECn8ZAAMbAAgICiXNBQA9AwAbAAgICiXNBQA9AwABAAYIlg6UtQD8AAAAAA==.',['安多']='安多利尔晨风:BAAALAAECgEIAQAAAA==.',['安洁']='安洁妮:BAAALAAECgYICgAAAA==.',['宝宝']='宝宝很凶:BAABLAAFFH8HAAMBAAII3Bk3UwCUAAABAAII3Bk3UwCUAAAeAAEIVBLeBwBQAAAAAA==.',['宝崽']='宝崽小朋友:BAABLAAFFH8YAAMbAAYIaBuvBwCiAQAbAAYIEhevBwCiAQABAAUIMRM1UAANAQAAAA==.',['害怕']='害怕怕:BAAALAAFFAIIAgAAAA==.',['寂寞']='寂寞丶风行者:BAAALAAECgMIBAAAAA==.',['富贵']='富贵:BAAALAAECgYIBgAAAA==.',['寻夜']='寻夜:BAAALAAECgYIBgAAAA==.',['射出']='射出精彩:BAABLAAFFH8FAAIBAAUIYgdjVQD4AAABAAUIYgdjVQD4AAABLAAFFAgIEgABAM0MAA==.',['小不']='小不拉叽:BAACLAAFFH8JAAIJAAMIcAvkMACnAAAJAAMIcAvkMACnAAAsAAQKfxQAAgkABgjpEm5lAEsBAAkABgjpEm5lAEsBAAAA.',['小哥']='小哥再现:BAABLAAFFH8IAAILAAIIMwrClgA7AAALAAIIMwrClgA7AAAAAA==.小哥来也:BAABLAAFFH8SAAIGAAUIJA39IADBAAAGAAUIJA39IADBAAAAAA==.',['小小']='小小怪:BAAALAAECgYIDAAAAA==.',['小弟']='小弟萌萌德:BAABLAAECn8UAAISAAcIEhZbQwDTAQASAAcIEhZbQwDTAQAAAA==.',['小浣']='小浣雄:BAAALAAECggICAAAAA==.',['小牛']='小牛儿娟娟:BAAALAAECgQIBAAAAA==.',['小狗']='小狗宝:BAAALAAECgIIAgAAAA==.',['小磊']='小磊:BAAALAAECgcIDwAAAA==.',['小茜']='小茜:BAAALAADCggIFAAAAA==.',['小詸']='小詸妹:BAAALAAFFAIIAgAAAA==.',['小赵']='小赵哥:BAAALAAECgYICQAAAA==.',['小野']='小野喵:BAAALAAECgYIBQAAAA==.',['小阿']='小阿飞丶:BAAALAAECgMIAwAAAA==.',['就是']='就是小哥:BAAALAAECgYICgAAAA==.',['尼古']='尼古拉斯凯骑:BAABLAAFFH8OAAILAAIIjxTYbQCRAAALAAIIjxTYbQCRAAAAAA==.',['尼艾']='尼艾沃玛:BAAALAAECgYICgAAAA==.',['尼酱']='尼酱的乖宝宝:BAACLAAFFH84AAMSAAgI8hrZAgCjAgASAAgI8hrZAgCjAgATAAUInQ1cGQANAQAsAAQKfxUAAhIABwhYI1MLAJcCABIABwhYI1MLAJcCAAAA.',['屠龙']='屠龙者:BAABLAAECn8hAAIBAAgIyxD9VgCVAQABAAgIyxD9VgCVAQAAAA==.',['嵿岌']='嵿岌心语:BAABLAAFFH8OAAMYAAIISQRQJQB3AAAYAAIISQRQJQB3AAAZAAIIPR8dTgBeAAAAAA==.',['嵿級']='嵿級牛牛:BAABLAAFFH8GAAISAAIIXA3kSABeAAASAAIIXA3kSABeAAAAAA==.',['工具']='工具人:BAABLAAFFH8MAAIQAAIIxQMNVwBnAAAQAAIIxQMNVwBnAAABLAAFFAgIOAASAPIaAA==.',['巫毒']='巫毒:BAAALAADCgEIAQAAAA==.',['布咕']='布咕:BAABLAAFFH8iAAISAAYIOh7ECAAgAgASAAYIOh7ECAAgAgABLAAFFAgIOAASAPIaAA==.',['帝保']='帝保罗:BAAALAAFFAIIAgAAAA==.',['平安']='平安喜乐:BAAALAAECgYIBgAAAA==.',['幻域']='幻域飘香浪:BAAALAAECgQIBAAAAA==.',['幻舞']='幻舞:BAAALAADCgEIAQAAAA==.',['异客']='异客:BAAALAAECgEIAQABLAAECgYIEgARAAAAAA==.',['张益']='张益德:BAAALAADCgIIAgAAAA==.',['弥离']='弥离:BAAALAAECggIAgABLAAFFAgIBwAdAMwgAA==.',['彪悍']='彪悍的亮亮:BAABLAAFFH8GAAIBAAMIehP+cAB/AAABAAMIehP+cAB/AAAAAA==.',['彭哥']='彭哥哥好帅:BAABLAAFFH87AAIJAAcIvh9HAwC2AgAJAAcIvh9HAwC2AgABLAAFFAgIOAASAPIaAA==.',['影熙']='影熙:BAAALAAFFAIIBAAAAA==.',['御命']='御命丹心:BAAALAAECgQIBAAAAA==.',['御用']='御用飛哥:BAAALAAFFAIIAgAAAA==.',['德莱']='德莱不是德鲁:BAAALAAFFAEIAQAAAA==.',['心灵']='心灵潜行:BAACLAAFFH8KAAMDAAIIkQqwHQBAAAADAAEInAqwHQBAAAACAAEIhgpWHgA9AAAsAAQKfyYAAwIACAhZFEggAJEBAAIABwjLEkggAJEBAAMABAiuFFRLABEBAAAA.',['心若']='心若暢然:BAAALAAFFAIIAwAAAA==.心若畅然:BAACLAAFFH8GAAILAAII5AndlwA7AAALAAII5AndlwA7AAAsAAQKfxwAAgsABgiWIOwtAL4BAAsABgiWIOwtAL4BAAAA.',['快乐']='快乐的流言:BAAALAADCggIDgAAAA==.',['念念']='念念不忘:BAABLAAECn8VAAIMAAYITxj8GgBxAQAMAAYITxj8GgBxAQABLAAFFAIIAgARAAAAAA==.',['怎么']='怎么隐藏:BAAALAAECgYICAAAAA==.',['总是']='总是小哥:BAABLAAFFH8IAAINAAIIFBSGUgBHAAANAAIIFBSGUgBHAAAAAA==.',['恨之']='恨之煞:BAABLAAFFH8QAAIGAAIINBEUUgBDAAAGAAIINBEUUgBDAAAAAA==.',['恩泽']='恩泽:BAAALAAECgUICgAAAA==.',['恶妇']='恶妇:BAAALAADCgYIBwAAAA==.',['恶魔']='恶魔之撃:BAAALAAECgYICgAAAA==.恶魔霸天:BAAALAAECgYIBgAAAA==.',['情趣']='情趣老板娘:BAAALAAECgMIAwAAAA==.',['愿君']='愿君多采撷:BAAALAAECgIIAgAAAA==.',['慈悲']='慈悲引渡魂:BAAALAAECgMIAwAAAA==.',['我会']='我会变树:BAAALAAECgYICQAAAA==.',['我只']='我只做小三:BAAALAAFFAYIBAAAAA==.',['我愛']='我愛壹條柴:BAAALAAECgYIBgAAAA==.',['我是']='我是小明:BAAALAAECgYIDQAAAA==.我是牛吗:BAAALAAECgcICwAAAA==.',['我的']='我的锅儿:BAAALAAFFAIIAgAAAA==.',['我觉']='我觉得行:BAAALAADCgYIBgAAAA==.',['战歌']='战歌血喉:BAAALAAFFAIIBAAAAA==.',['戦灬']='戦灬小万:BAAALAAECgYICgAAAA==.',['戴尔']='戴尔李斯阿卡:BAABLAAFFH8HAAINAAQIMQcrOQCqAAANAAQIMQcrOQCqAAAAAA==.',['拉克']='拉克西丝:BAAALAAFFAIIAgAAAA==.',['拉粑']='拉粑粑小魔仙:BAAALAADCgUIBQAAAA==.',['挽歌']='挽歌丶:BAAALAAECgYIBgAAAA==.',['捌佰']='捌佰鲍夜:BAAALAAECgYIBgAAAA==.',['捌级']='捌级大狂风:BAABLAAFFH8SAAIZAAUIQx8RHgDcAAAZAAUIQx8RHgDcAAAAAA==.',['探花']='探花朮:BAAALAAFFAIIAgAAAA==.',['揸枪']='揸枪妹子:BAAALAAECgYIBgAAAA==.',['搅厶']='搅厶棍:BAABLAAFFH8OAAIBAAUIzAliWQDkAAABAAUIzAliWQDkAAAAAA==.',['撒野']='撒野:BAAALAAECgIIAgAAAA==.',['放弃']='放弃速度灭:BAAALAADCgQIBAAAAA==.',['斯凯']='斯凯文奇:BAACLAAFFH8QAAIQAAMIfQ0qTgCCAAAQAAMIfQ0qTgCCAAAsAAQKfykAAhAACAihEiQuAJcBABAACAihEiQuAJcBAAAA.',['斯特']='斯特莱客:BAAALAADCgIIAgAAAA==.',['新手']='新手新:BAAALAADCgIIAgAAAA==.',['方向']='方向:BAAALAADCgEIAQAAAA==.',['无尽']='无尽的苍穹:BAABLAAFFH8OAAIXAAIIIySTBwDNAAAXAAIIIySTBwDNAAAAAA==.',['无情']='无情哈拉少:BAAALAAFFAIIBAAAAA==.',['无糖']='无糖可乐:BAAALAAECgUIBgAAAA==.',['无胜']='无胜利毋宁死:BAAALAAECgQIBAAAAA==.',['无风']='无风不起浪:BAAALAAECgYIBgAAAA==.',['昊凬']='昊凬:BAAALAAECgQIBAAAAA==.',['昊枫']='昊枫:BAAALAAECgYIBgAAAA==.',['昊沨']='昊沨:BAAALAADCgEIAQAAAA==.',['昊渢']='昊渢:BAAALAAECgIIAgAAAA==.',['昊风']='昊风:BAAALAAECgMIAwAAAA==.',['星云']='星云:BAAALAAECgYIEQAAAA==.',['是美']='是美雅呢:BAABLAAFFH8OAAIQAAYI4QxeMwBHAQAQAAYI4QxeMwBHAQAAAA==.',['晴天']='晴天沫沫:BAAALAAECgMIBQAAAA==.晴天漠漠:BAAALAAECgYIDgAAAA==.',['暧昧']='暧昧暖人心:BAAALAAECgYIBgAAAA==.',['暮枫']='暮枫残泪:BAAALAADCggICAAAAA==.',['曳曳']='曳曳风情:BAAALAAECggICAAAAA==.',['最后']='最后的救赎丶:BAAALAAECgUIBQAAAA==.',['月光']='月光下的清雨:BAAALAAFFAIIAgAAAA==.',['月夜']='月夜霜语:BAAALAAECggIAwAAAA==.',['月影']='月影鬼泣:BAAALAAECgIIAgAAAA==.',['月璃']='月璃殇:BAAALAAECgEIAQAAAA==.',['月蚀']='月蚀的假面:BAAALAADCgEIAQAAAA==.',['月读']='月读:BAAALAAECgEIAQAAAA==.',['有种']='有种嫁给我:BAAALAAECgUICgAAAA==.',['木林']='木林森:BAAALAAECgYICAAAAA==.',['末那']='末那:BAAALAAFFAEIAQAAAA==.',['术大']='术大招疯:BAAALAADCgcIBwAAAA==.',['杀戮']='杀戮天下:BAAALAAECgEIAQAAAA==.',['杆子']='杆子哥:BAAALAADCgIIAgAAAA==.',['来点']='来点合剂:BAABLAAFFH8qAAIJAAYIcCFxCABCAgAJAAYIcCFxCABCAgABLAAFFAgIOAASAPIaAA==.来点药水:BAABLAAFFH8uAAIJAAYIwiP3BQBtAgAJAAYIwiP3BQBtAgABLAAFFAgIOAASAPIaAA==.',['杨十']='杨十八:BAAALAAECgMIBQAAAA==.',['杨心']='杨心:BAAALAAECgIIAgAAAA==.',['杨豆']='杨豆花:BAAALAAECggIBgAAAA==.',['杰杀']='杰杀:BAAALAAECgYICAAAAA==.',['松烟']='松烟竹雾:BAAALAAECgMIAwAAAA==.',['林雷']='林雷之梦:BAACLAAFFH8QAAIYAAIIJBUiJACBAAAYAAIIJBUiJACBAAAsAAQKfyAABBkABwgzHrkqAOgBABkABwgzHrkqAOgBABgABgh+EOtKAC0BABoAAQi6FAZ0AD8AAAAA.',['枫叶']='枫叶烙痕:BAAALAAECggIDgAAAA==.枫叶红了:BAAALAAECgYIBgAAAA==.',['枸杞']='枸杞芽:BAAALAAECgUIBQAAAA==.',['柒桦']='柒桦:BAABLAAFFH8GAAIZAAUIjguTDQCBAQAZAAUIjguTDQCBAQAAAA==.',['柳岩']='柳岩姐姐:BAAALAAECgIIAgAAAA==.',['柳星']='柳星科技:BAABLAAFFH8IAAIaAAII9BhVEwCHAAAaAAII9BhVEwCHAAAAAA==.',['格哥']='格哥:BAAALAAECgYIBgAAAA==.',['梦回']='梦回珞珈:BAAALAAECgEIAQAAAA==.',['梦幻']='梦幻神兜兜:BAAALAAECgYIBgAAAA==.',['梦想']='梦想家:BAAALAADCgYIBgAAAA==.',['森林']='森林之心:BAABLAAFFH8GAAISAAIImghTTwBVAAASAAIImghTTwBVAAABLAAFFAQIEQAEAIwRAA==.',['楚芸']='楚芸:BAAALAAECgYIBwAAAA==.',['欧阳']='欧阳月儿:BAAALAAECgYIDQAAAA==.',['正在']='正在删除:BAAALAAECgUIBQAAAA==.',['死亡']='死亡之欹:BAABLAAFFH8IAAILAAIIEQUcmQA6AAALAAIIEQUcmQA6AAAAAA==.死亡军团判官:BAABLAAECn8VAAMPAAYIBBe0IQA3AQAPAAYIBBe0IQA3AQAGAAMIGgef8AB0AAAAAA==.',['死在']='死在天真里:BAABLAAECn8XAAIBAAcIjhkxhgDUAQABAAcIjhkxhgDUAQAAAA==.',['殛天']='殛天之翼:BAAALAAECgYIBgAAAA==.',['毛胖']='毛胖球:BAABLAAFFH8gAAMJAAgIGxuLBgDwAQAJAAcI/xmLBgDwAQAMAAQIJBSGEgBGAQABLAAFFAgIpAAJAAUkAA==.',['毛脸']='毛脸雷公嘴丶:BAAALAAECgEIAQAAAA==.',['气质']='气质丶:BAAALAAFFAIIAgAAAA==.',['氣質']='氣質丶:BAABLAAFFH8GAAIfAAIIAB4FCQCwAAAfAAIIAB4FCQCwAAAAAA==.',['水樱']='水樱宮葵:BAABLAAECn8eAAMJAAgIfxznDAB/AgAJAAgIfxznDAB/AgAMAAgIBx3fJABQAgABLAAFFAgIJAAgAAYcAA==.',['汤圆']='汤圆欧巴:BAAALAADCgIIAgAAAA==.',['沐少']='沐少爷丶稀瓜:BAAALAAECgQIBAAAAA==.',['没币']='没币了:BAAALAAECgEIAQAAAA==.',['法克']='法克:BAAALAAECgUICAAAAA==.',['波风']='波风皆人:BAABLAAFFH8GAAMCAAYIYRFeCAA6AQACAAUIhxReCAA6AQADAAEIpAFyHwA3AAAAAA==.',['泰蕾']='泰蕾莎:BAAALAAECgUIBwAAAA==.',['洒落']='洒落阴凉:BAAALAAECgYIBgAAAA==.',['洛侠']='洛侠:BAAALAADCggIGQAAAA==.',['洛璃']='洛璃:BAAALAAECgYICAAAAA==.',['流风']='流风若雪:BAAALAAFFAIIBAAAAA==.',['海螺']='海螺:BAABLAAFFH8IAAINAAIIVxz0NACiAAANAAIIVxz0NACiAAAAAA==.',['涅亚']='涅亚:BAAALAAFFAIIAgAAAA==.',['淞餮']='淞餮:BAABLAAFFH8MAAIEAAYIrhyMFAC8AQAEAAYIrhyMFAC8AQABLAAFFAgIDAAEADgSAA==.',['淡竹']='淡竹叶:BAABLAAFFH8GAAIgAAYITQDVJQAaAAAgAAYITQDVJQAaAAAAAA==.',['深藏']='深藏功与名:BAAALAAECgYIDAAAAA==.',['淹死']='淹死滴鱼:BAABLAAFFH8UAAIZAAUITxx8IABlAQAZAAUITxx8IABlAQAAAA==.',['淼轩']='淼轩轩:BAAALAAECgEIAQAAAA==.',['清辉']='清辉夜凝:BAAALAAECgQIBAAAAA==.',['游泣']='游泣:BAAALAAECgEIAQAAAA==.',['湮滅']='湮滅:BAAALAAECgQIBAAAAA==.',['源濑']='源濑氏丶佐田:BAABLAAFFH8LAAMbAAUIfxS8HACWAAAbAAIIQhy8HACWAAABAAQIkRHsbwCCAAABLAAFFAYILgAMAHYYAA==.',['滚滚']='滚滚儿:BAAALAADCgcIBwAAAA==.',['滴批']='滴批哎四下限:BAAALAAFFAUIAwAAAA==.',['潘潘']='潘潘吖:BAAALAAFFAIIBAAAAA==.',['潜规']='潜规则丶:BAAALAAECgUIBQAAAA==.',['灡泠']='灡泠:BAACLAAFFH8FAAIZAAIIuhHCeAA4AAAZAAIIuhHCeAA4AAAsAAQKfxsAAhkABgjyFrZeAEkBABkABgjyFrZeAEkBAAAA.',['火影']='火影小肥朵:BAABLAAFFH8mAAILAAYIeBGhLgCAAQALAAYIeBGhLgCAAQAAAA==.火影摇摆龙王:BAACLAAFFH8+AAIGAAYI/yFXDAD4AQAGAAYI/yFXDAD4AQAsAAQKfyIAAgYABwjsJPYMAIwCAAYABwjsJPYMAIwCAAAA.',['火焰']='火焰:BAAALAAFFAIIBAAAAA==.',['灭吧']='灭吧:BAABLAAFFH8wAAIJAAYIaSRNBQB7AgAJAAYIaSRNBQB7AgABLAAFFAgIOAASAPIaAA==.',['灵魂']='灵魂祷言:BAABLAAECn8ZAAIJAAgIkxTxGgDlAQAJAAgIkxTxGgDlAQAAAA==.灵魂附体:BAAALAAECgYICgAAAA==.',['灾难']='灾难丶狂欢:BAABLAAFFH8YAAIQAAYIDw1aIAAiAQAQAAYIDw1aIAAiAQAAAA==.',['炫爱']='炫爱教练:BAABLAAECn8ZAAMfAAgIPRDIEAA/AQAfAAgIAg/IEAA/AQANAAYIhgu52gAuAQAAAA==.',['烂木']='烂木头:BAACLAAFFH8IAAMdAAIImAckHACHAAAdAAIISwYkHACHAAAQAAIImAdoaAA4AAAsAAQKfy4AAx0ABgiWHYATAEMBABAABghSGEQ6AF8BAB0ABgiSHYATAEMBAAAA.',['烈风']='烈风行者:BAAALAAFFAIIAgAAAA==.',['烟行']='烟行媚视:BAAALAAECgYIBgAAAA==.',['焰之']='焰之曙光:BAABLAAFFH8SAAIZAAYI2xADIQBiAQAZAAYI2xADIQBiAQAAAA==.',['燕羽']='燕羽丶汗:BAAALAADCggIDQAAAA==.',['牛冰']='牛冰:BAAALAAFFAIIBAAAAA==.',['牛吽']='牛吽吽德:BAAALAAECgQIBAAAAA==.',['牛咕']='牛咕:BAAALAAFFAIIAgAAAA==.',['牛奶']='牛奶:BAABLAAFFH8HAAIEAAIIfA0LYQBfAAAEAAIIfA0LYQBfAAAAAA==.',['牛战']='牛战:BAABLAAFFH8IAAIPAAIIZQF+OwAWAAAPAAIIZQF+OwAWAAAAAA==.',['牛牛']='牛牛增幅器:BAABLAAFFH8JAAIgAAYItAisEQD7AAAgAAYItAisEQD7AAAAAA==.牛牛小公兽:BAABLAAFFH8RAAMLAAQIORtcTQDzAAALAAQIORtcTQDzAAAKAAEIZQMUIABDAAAAAA==.牛牛尐强:BAAALAAECgQIBAAAAA==.',['牛猎']='牛猎:BAAALAAFFAIIAgAAAA==.',['牛萌']='牛萌萌:BAAALAAECgYIBgAAAA==.',['牛血']='牛血沸腾:BAAALAAECgQICAAAAA==.',['牛顿']='牛顿学物理:BAAALAAECgYIEgAAAA==.',['牢天']='牢天:BAAALAADCgYIBgAAAA==.',['牢記']='牢記血海仇:BAAALAAECgYIEgAAAA==.',['牧尔']='牧尔布诗:BAAALAAECgYICwAAAA==.',['牧法']='牧法萨丶:BAAALAADCggICQAAAA==.',['狂想']='狂想镇魂曲:BAAALAAECgYIDQAAAA==.',['狂拽']='狂拽酷炫铞:BAAALAADCgMIAwAAAA==.',['狸迷']='狸迷言梦者丶:BAABLAAFFH8sAAIGAAYInSLWDQDqAQAGAAYInSLWDQDqAQAAAA==.',['猎物']='猎物者:BAAALAAECgEIAQAAAA==.',['猫咪']='猫咪不是胖橘:BAAALAAFFAIIAwAAAA==.',['玛奇']='玛奇玛:BAABLAAFFH8WAAIhAAYIGgVIEgD3AAAhAAYIGgVIEgD3AAABLAAFFAgIOAASAPIaAA==.',['玛莎']='玛莎喇蒂:BAABLAAFFH8RAAIYAAYIjh2cCwDKAQAYAAYIjh2cCwDKAQAAAA==.',['琉璃']='琉璃灯:BAAALAAECgYIBgAAAA==.',['生命']='生命之歌:BAAALAAECgUIBQAAAA==.',['男人']='男人和公狗:BAAALAAECgcIBwAAAA==.男人就是要准:BAAALAAECgEIAQAAAA==.',['癌丘']='癌丘:BAABLAAFFH8KAAIEAAMIbxcfNwDHAAAEAAMIbxcfNwDHAAAAAA==.',['白刀']='白刀子进去:BAABLAAFFH8FAAISAAMIpgpgOACKAAASAAMIpgpgOACKAAAAAA==.',['皮卡']='皮卡超人:BAAALAAECggICAAAAA==.',['皮咕']='皮咕:BAABLAAFFH8kAAISAAYIRx7pCAAeAgASAAYIRx7pCAAeAgABLAAFFAgIOAASAPIaAA==.',['盖亚']='盖亚拉夫:BAAALAAECgUIBwAAAA==.',['盗版']='盗版卡卡西:BAAALAAECggIDgAAAA==.',['真电']='真电游王:BAAALAAECgcIDQAAAA==.',['神农']='神农鼎:BAAALAAFFAQIBAABLAAFFAgIJQAWAIomAA==.',['神威']='神威杀魂:BAAALAADCggICAAAAA==.',['神罗']='神罗天征:BAAALAAECgYIBgAAAA==.',['神鸾']='神鸾京:BAAALAAECgYIDgAAAA==.',['禾谷']='禾谷镰刀菌:BAAALAAECgYIBgAAAA==.',['科洛']='科洛克:BAABLAAFFH8IAAMZAAYIAwLzTwBXAAAZAAYIAwLzTwBXAAAYAAEIFQGyMQAXAAAAAA==.',['秦始']='秦始皇:BAABLAAFFH8IAAIGAAYIuxJZGwCLAQAGAAYIuxJZGwCLAQAAAA==.',['简單']='简單粗暴:BAAALAAECgIIAwAAAA==.',['米宝']='米宝:BAAALAAECgYIAwAAAA==.',['米粒']='米粒丨:BAAALAAECgYIBgAAAA==.',['米逹']='米逹崙:BAAALAAECgcIDwAAAA==.',['精灵']='精灵大帅:BAAALAAECgQIBAAAAA==.',['精神']='精神歌:BAAALAADCgIIAgAAAA==.',['紛舞']='紛舞妖姬:BAAALAAFFAIIAgAAAA==.',['素主']='素主:BAABLAAFFH8eAAMSAAYIFh4NCAArAgASAAYIFh4NCAArAgATAAQIuATWIwCRAAABLAAFFAgIOAASAPIaAA==.',['索托']='索托斯:BAAALAADCggICAAAAA==.',['红山']='红山哥布林:BAABLAAFFH8QAAMcAAII6xSEBwB4AAAcAAII6xSEBwB4AAATAAIImwpHNgA5AAAAAA==.红山大红茶:BAABLAAFFH8dAAQdAAUIChpyBwCvAAAQAAQIghYwQgDcAAAdAAMIyB5yBwCvAAAiAAII+ANdCwAXAAAAAA==.',['红皮']='红皮熊:BAAALAAFFAIIBAAAAA==.',['红豆']='红豆天堂:BAAALAADCgQIBAAAAA==.红豆惩戒:BAAALAAECgEIAQAAAA==.',['纯綷']='纯綷:BAAALAAECgUIBQAAAA==.',['终相']='终相忘:BAABLAAFFH8IAAIZAAUI1RKZLQAZAQAZAAUI1RKZLQAZAQAAAA==.',['给你']='给你一棒槌:BAAALAAECgYICwAAAA==.',['绝世']='绝世芊颖:BAAALAAECgYIDAAAAA==.',['维樂']='维樂:BAABLAAFFH8KAAINAAIIdwrKTwCNAAANAAIIdwrKTwCNAAAAAA==.',['绿雨']='绿雨晓苒:BAAALAAECgcIBwAAAA==.',['美得']='美得太明显:BAAALAAECgEIAQAAAA==.',['羽痕']='羽痕:BAABLAAECn8WAAIJAAYIewWTSgCuAAAJAAYIewWTSgCuAAAAAA==.',['翘边']='翘边模子:BAAALAADCgcIHAAAAA==.',['老是']='老是小哥:BAAALAAECgQIAQAAAA==.',['老板']='老板凳丶:BAAALAAECgcIEwAAAA==.',['老牛']='老牛爱洗头:BAAALAADCgMIAwAAAA==.',['耂胡']='耂胡豆豆:BAABLAAFFH8GAAINAAMI6w93JADQAAANAAMI6w93JADQAAAAAA==.',['聖光']='聖光将熄:BAAALAAECgYICAAAAA==.',['背弃']='背弃圣光的猫:BAAALAAECgEIAQAAAA==.',['脑浆']='脑浆炸裂:BAABLAAECn8aAAISAAYIziV2IQBnAgASAAYIziV2IQBnAgAAAA==.',['自来']='自来火:BAABLAAFFH8WAAIQAAYIcAeEPQAKAQAQAAYIcAeEPQAKAQABLAAFFAgIOAASAPIaAA==.自来火会飞:BAABLAAFFH8SAAIjAAYIwwFQEAC1AAAjAAYIwwFQEAC1AAABLAAFFAgIOAASAPIaAA==.自来火火:BAABLAAFFH83AAMJAAYIRCNmBgBkAgAJAAYIRCNmBgBkAgAIAAEI5Aa6CQAbAAABLAAFFAgIOAASAPIaAA==.自来牛:BAABLAAFFH8qAAMSAAYIXyKNBQBYAgASAAYIXyKNBQBYAgATAAEIFBGgMABBAAABLAAFFAgIOAASAPIaAA==.',['自然']='自然丨随风:BAAALAAECgMIAwAAAA==.',['自由']='自由镇的狂魔:BAABLAAFFH8mAAIkAAYIkCW2BAAeAgAkAAYIkCW2BAAeAgAAAA==.',['至尊']='至尊魔王:BAACLAAFFH8GAAMcAAIINgr/CQBjAAAcAAIINgr/CQBjAAAUAAIIXAFWEgBdAAAsAAQKfyEAAxwABwgiFbAXAG4BABwABwjTErAXAG4BABQABggAEtklAF8BAAAA.',['至高']='至高图腾:BAAALAADCggICAAAAA==.',['芙蕾']='芙蕾雅:BAAALAAECgYICwAAAA==.',['花辞']='花辞树:BAAALAAECgEIAQAAAA==.',['芳菲']='芳菲主人:BAAALAAECgYIDAAAAA==.',['苍色']='苍色挽歌:BAACLAAFFH8IAAIMAAIIihJRHgCTAAAMAAIIihJRHgCTAAAsAAQKfyMAAgwABgi/IvUjAFYCAAwABgi/IvUjAFYCAAEsAAUUBggiAAEAmh4A.',['苏妲']='苏妲姬:BAABLAAECn8UAAIEAAYIxg3O0wDjAAAEAAYIxg3O0wDjAAAAAA==.',['茜饭']='茜饭:BAAALAADCgYIBgAAAA==.',['荔枝']='荔枝大红皮:BAABLAAFFH8LAAMLAAIIExYhXwCZAAALAAIIExYhXwCZAAAVAAIIXQxlEgB4AAAAAA==.',['莉亚']='莉亚灬风行者:BAAALAAECggICAAAAA==.',['菲雨']='菲雨非雪:BAAALAAECgYIBgAAAA==.',['萌灵']='萌灵:BAAALAAECgQIBAAAAA==.',['萤勾']='萤勾:BAAALAADCgYIBgAAAA==.',['萧瑟']='萧瑟:BAAALAAFFAIIBAAAAA==.',['萨厼']='萨厼:BAABLAAFFH8GAAIEAAYIjBDHKAAeAQAEAAYIjBDHKAAeAQABLAAFFAgIEwABAMYeAA==.',['萨斯']='萨斯给:BAAALAAECgUIBQAAAA==.',['萨飞']='萨飞罗斯:BAAALAAECgUICAAAAA==.',['萨髵']='萨髵:BAABLAAFFH8GAAIFAAYIVCD7DQDUAQAFAAYIVCD7DQDUAQAAAA==.',['落叶']='落叶不知处:BAAALAAECgEIAQAAAA==.',['落雪']='落雪无尘:BAAALAAECgYIBgAAAA==.',['葬剑']='葬剑为红颜:BAABLAAFFH8PAAIWAAMIiQ+oNAC2AAAWAAMIiQ+oNAC2AAAAAA==.',['蒙派']='蒙派:BAAALAAECgMIAwAAAA==.',['蓝胖']='蓝胖子噜噜:BAAALAAECgMIAwAAAA==.蓝胖子大噜:BAAALAADCgcIBwAAAA==.',['蓝色']='蓝色瘟疫:BAAALAAECgMIAwAAAA==.',['蔷歌']='蔷歌歌:BAAALAAECggIEAAAAA==.',['蕾拉']='蕾拉:BAAALAAECgEIAQAAAA==.',['薛八']='薛八一:BAABLAAFFH8sAAMSAAYIpx8nCAAqAgASAAYIpx8nCAAqAgATAAQIdQl+IgCeAAABLAAFFAgIOAASAPIaAA==.',['薩灬']='薩灬彵媽滴帥:BAAALAAECgUIBwAAAA==.',['蘾尐']='蘾尐殇:BAABLAAFFH8GAAIEAAIIggjcXQBiAAAEAAIIggjcXQBiAAAAAA==.蘾尐荶:BAABLAAFFH8IAAIdAAII5xw/DQCsAAAdAAII5xw/DQCsAAAAAA==.',['虚空']='虚空风行者:BAAALAAECgYICQAAAA==.',['蛋蛋']='蛋蛋菊花香:BAAALAAECgQIBAAAAA==.',['蜡筆']='蜡筆小旧:BAABLAAFFH8LAAISAAMIvhTDEwDYAAASAAMIvhTDEwDYAAAAAA==.',['螭吻']='螭吻:BAABLAAECn8YAAIZAAYIQyLnXQAwAgAZAAYIQyLnXQAwAgAAAA==.',['血之']='血之追猎者:BAABLAAFFH8SAAIBAAYIbw4lQwA8AQABAAYIbw4lQwA8AQAAAA==.',['血战']='血战丶狂杀:BAAALAAECgYIBgAAAA==.',['行云']='行云流水:BAAALAAECgMIAwAAAA==.',['西之']='西之莉芙露:BAAALAAECgMIAwAAAA==.',['西门']='西门丨夜雨:BAABLAAFFH8LAAIZAAIIwCEJUwBPAAAZAAIIwCEJUwBPAAAAAA==.西门丨怒风:BAAALAAFFAIIBAAAAA==.',['要猛']='要猛灬:BAAALAAECgYIBgAAAA==.',['见手']='见手青:BAAALAAECgYIEQAAAA==.',['解树']='解树:BAAALAAECgYICAAAAA==.',['让我']='让我来摸:BAABLAAFFH8qAAMEAAYI8xXhEQAsAQAEAAYI8xXhEQAsAQAFAAUILAShLADVAAABLAAFFAgIOAASAPIaAA==.',['诺亚']='诺亚:BAAALAAECgYIBQAAAA==.',['谁喝']='谁喝了蒙牛:BAAALAAECgEIAQAAAA==.',['贵阳']='贵阳装批王:BAAALAAECgMIAwAAAA==.',['走了']='走了那么久:BAAALAAECgUIBQAAAA==.',['超级']='超级奶爸:BAABLAAFFH8MAAMEAAYIOBIKDgBeAQAEAAYIOBIKDgBeAQAFAAEIBQT3PABJAAAAAA==.超级飞侠:BAAALAAECgMIAwAAAA==.',['输出']='输出职业:BAAALAAECgYIBgAAAA==.',['辛美']='辛美尔:BAABLAAFFH85AAIJAAYIqyHUBwBMAgAJAAYIqyHUBwBMAgABLAAFFAgIOAASAPIaAA==.',['辣妹']='辣妹:BAAALAAECgUIBQAAAA==.',['辰妹']='辰妹:BAABLAAFFH8LAAITAAMImBdTEADvAAATAAMImBdTEADvAAAAAA==.',['还是']='还是小哥:BAABLAAFFH8IAAIXAAII6ROiGAA+AAAXAAII6ROiGAA+AAAAAA==.',['这里']='这里缺德吗:BAAALAADCgIIAgAAAA==.',['迷醉']='迷醉之潮:BAAALAAECgYIBgAAAA==.',['逍遥']='逍遥扇:BAAALAAECgYIBgAAAA==.逍遥鱼:BAAALAAFFAIIAgAAAA==.',['避难']='避难所的牛:BAAALAAECgYIDAAAAA==.',['那个']='那个法克丶:BAAALAAECgYICgAAAA==.',['那只']='那只小怪:BAAALAAECgYIEwAAAA==.',['那咋']='那咋办嘛:BAAALAADCgYIBgAAAA==.',['那时']='那时的疯狂:BAABLAAFFH8TAAIEAAMI1hgNNQDRAAAEAAMI1hgNNQDRAAAAAA==.',['那時']='那時的瘋狂:BAAALAAFFAIIBAAAAA==.',['邪恶']='邪恶男爵:BAABLAAECn8VAAIXAAcIlRFZGgBPAQAXAAcIlRFZGgBPAQAAAA==.',['酒鬼']='酒鬼迈克:BAAALAADCgYIBgAAAA==.',['野性']='野性的呼唤:BAAALAAECgYIBwAAAA==.',['野蛮']='野蛮防损员:BAAALAAECgYIBgAAAA==.',['钢琴']='钢琴里的猫:BAAALAAFFAgIAgAAAA==.',['钰火']='钰火阳哥:BAACLAAFFH8OAAMEAAQI3RTyPQCsAAAEAAMIEBPyPQCsAAAFAAMIwAklNwB/AAAsAAQKfyYAAwUACAg9GHgVAP8BAAUACAg9GHgVAP8BAAQAAgh4E1+KAG4AAAAA.',['钱猎']='钱猎现:BAABLAAFFH81AAMSAAcIUhwsBwA7AgASAAcIUhwsBwA7AgATAAQIwwa7IgCbAAABLAAFFAgIOAASAPIaAA==.',['铭火']='铭火:BAABLAAFFH8wAAIJAAYIMiQTBgBrAgAJAAYIMiQTBgBrAgABLAAFFAgIOAASAPIaAA==.',['长了']='长了五厘米丶:BAAALAAECgQIBAAAAA==.',['闪伯']='闪伯利恒之星:BAAALAAECggICwAAAA==.',['问号']='问号:BAAALAAECgQIBwAAAA==.',['防不']='防不胜防:BAAALAAECgYICAAAAA==.',['阿兰']='阿兰蒂恩:BAABLAAFFH8MAAIfAAIIlgIzGwAcAAAfAAIIlgIzGwAcAAAAAA==.',['阿勀']='阿勀里斯:BAAALAAFFAYIAwAAAA==.',['阿尔']='阿尔丶萨斯:BAAALAAECgcIDQAAAA==.',['阿拉']='阿拉蕾:BAABLAAECn8dAAILAAYITh+8LADCAQALAAYITh+8LADCAQAAAA==.',['阿狄']='阿狄娜:BAAALAAECgQIBgAAAA==.',['阿萨']='阿萨丹姆:BAAALAAECgMIAwAAAA==.',['隐藏']='隐藏:BAABLAAFFH8QAAIWAAYIqBRnHABgAQAWAAYIqBRnHABgAQAAAA==.隐藏实力:BAACLAAFFH8FAAIWAAMIqQw0LwDRAAAWAAMIqQw0LwDRAAAsAAQKfx0AAxYACAg2HvI8AFcCABYACAg2HvI8AFcCABcAAQgzFweSADcAAAAA.',['雅少']='雅少:BAABLAAFFH8GAAIZAAIIWAR5fwAvAAAZAAIIWAR5fwAvAAAAAA==.',['雨烟']='雨烟纪程:BAAALAAFFAIIAgAAAA==.',['雪之']='雪之下雪乃:BAABLAAFFH8hAAIPAAYIVhpsDAB7AQAPAAYIVhpsDAB7AQAAAA==.',['雾丑']='雾丑丑:BAAALAAECgUIBQAAAA==.',['霜之']='霜之哀狼:BAAALAAFFAIIAgAAAA==.',['青山']='青山区所:BAAALAADCgIIAgAAAA==.',['青枝']='青枝玉叶:BAAALAAECgYICAAAAA==.',['靶鑲']='靶鑲亀薡:BAAALAADCgEIAQAAAA==.',['预见']='预见小哥:BAABLAAFFH8MAAIJAAIIxwhDQgBmAAAJAAIIxwhDQgBmAAAAAA==.',['风雷']='风雷电火:BAABLAAFFH8LAAIEAAMIdQoCTwB9AAAEAAMIdQoCTwB9AAAAAA==.',['飞尨']='飞尨在天:BAABLAAFFH8ZAAQgAAgIQxqzAgBnAgAgAAgIQxqzAgBnAgAhAAQIBhChCQAeAQAlAAUI2gcWCQD4AAAAAA==.',['飞翔']='飞翔的牛牛:BAAALAAECgYICgAAAA==.',['魔力']='魔力熊猫:BAABLAAFFH8JAAIWAAYIwxEWKABzAQAWAAYIwxEWKABzAQAAAA==.',['魔狼']='魔狼兽战:BAAALAAECgYICQAAAA==.',['鲜血']='鲜血与浓药:BAAALAAECgYIBwAAAA==.鲜血玛丽:BAACLAAFFH8SAAMLAAYI5ArUIwANAQALAAYI5ArUIwANAQAVAAEITQBCGQAuAAAsAAQKfywAAgsACAjSGIhYAEUCAAsACAjSGIhYAEUCAAAA.',['鲨鱼']='鲨鱼巨人:BAAALAAFFAIIAgAAAA==.鲨鱼拳击手:BAABLAAFFH8KAAINAAMIFhb/GwD9AAANAAMIFhb/GwD9AAAAAA==.鲨鱼辣椒:BAAALAAECgIIAgAAAA==.',['鳳山']='鳳山門外:BAAALAAECgYIDgAAAA==.',['鸟人']='鸟人的未来:BAAALAAFFAIIAgAAAA==.',['鸡公']='鸡公加蛋:BAAALAAECgcIBAAAAA==.',['鹅掌']='鹅掌包于:BAAALAAECgIIAgAAAA==.',['黄桃']='黄桃蛋挞:BAABLAAFFH8IAAMeAAIIqxtVAwCoAAAeAAIIqxtVAwCoAAABAAIIVBj0jgBFAAAAAA==.',['黄棒']='黄棒丶:BAAALAAECgcIEAAAAA==.',['黄沙']='黄沙百战:BAAALAADCgcIBwAAAA==.',['黑天']='黑天使:BAAALAADCgMIAwAAAA==.',['黑牛']='黑牛妞:BAAALAADCggICAAAAA==.',['黑羽']='黑羽悠苒:BAAALAAECgYIBgAAAA==.',['黑锋']='黑锋挽歌:BAAALAAECggIEQAAAA==.',['鼓岛']='鼓岛花児开:BAAALAAECgEIAQAAAA==.',['龘鑫']='龘鑫森淼焱垚:BAAALAAECgQIBAAAAA==.',['龙傲']='龙傲天带你:BAAALAAFFAIIAgAAAA==.',['龙皓']='龙皓辰:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end