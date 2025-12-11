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
 local lookup = {'DeathKnight-Unholy','Paladin-Retribution','Paladin-Protection','Hunter-BeastMastery','Mage-Arcane','Mage-Frost','Shaman-Restoration','DemonHunter-Havoc','Druid-Restoration','Warlock-Affliction','Warlock-Destruction','DeathKnight-Frost','Warrior-Protection','Monk-Mistweaver','Druid-Balance','Warrior-Fury','Druid-Guardian','Shaman-Elemental','Shaman-Enhancement','Warlock-Demonology','Priest-Shadow','Priest-Holy','Unknown-Unknown','Priest-Discipline','Monk-Windwalker','Evoker-Preservation','Evoker-Augmentation','Monk-Brewmaster','Hunter-Marksmanship','DemonHunter-Vengeance','Paladin-Holy','Hunter-Survival','Evoker-Devastation',}; local provider = {region='CN',realm='死亡熔炉',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aironi:BAAALAAFFAIIAgAAAA==.',Bi='Bierhoff:BAABLAAECn8bAAIBAAYIaCHgFQAUAgABAAYIaCHgFQAUAgAAAA==.',Ch='Charlemagne:BAABLAAECn8YAAMCAAYIPRdqWgBTAQACAAYIPRdqWgBTAQADAAUIpgX7MwCJAAAAAA==.',Co='Cocoanut:BAABLAAFFH8QAAIEAAUIXxfqSQAkAQAEAAUIXxfqSQAkAQAAAA==.Cocoanuts:BAABLAAFFH8pAAMFAAYIKh2eFgDJAQAFAAYIHxyeFgDJAQAGAAIIzx47EgBQAAAAAA==.',De='Deathkey:BAABLAAFFH8HAAIHAAcIHh08BgBeAgAHAAcIHh08BgBeAgAAAA==.Dendroaspis:BAAALAAECgQIBAAAAA==.',Fa='Falcon:BAAALAAECgYIBwAAAA==.',Fi='Fiona:BAAALAAECgYIBgAAAA==.',Fl='Flyingdream:BAABLAAFFH8IAAIEAAYIRwY5UgAGAQAEAAYIRwY5UgAGAQAAAA==.Flyingshaman:BAAALAAECgEIAQAAAA==.',Ha='Happypeople:BAAALAAECgYICQAAAA==.',Iv='Ivever:BAAALAAECgYIBgAAAA==.',Ka='Kael:BAAALAAECgYIBgAAAA==.Kakuen:BAACLAAFFH8zAAIIAAgISR32BABOAgAIAAgISR32BABOAgAsAAQKfxsAAggACAirIqQgAOACAAgACAirIqQgAOACAAAA.',Ko='Kokoro:BAAALAAECgYIBgAAAA==.',Lj='Lj:BAAALAAECgYIBwAAAA==.',Lm='Lmaylr:BAABLAAFFH8JAAIEAAMI7wcfNwC1AAAEAAMI7wcfNwC1AAABLAAFFAgIBgAEADQGAA==.',Ma='Madtargaryen:BAAALAADCgEIAQAAAA==.',Mo='Mortis:BAABLAAFFH8GAAIJAAII/xl8JACVAAAJAAII/xl8JACVAAAAAA==.',Na='Naremdul:BAABLAAFFH8FAAICAAUITwiuLwAIAQACAAUITwiuLwAIAQAAAA==.',Os='Osris:BAABLAAFFH8MAAMKAAIIgw1VBACUAAAKAAIIgw1VBACUAAALAAIIdwbsZgA5AAAAAA==.',Pa='Palpal:BAAALAADCgEIAQAAAA==.Panacea:BAAALAAECgEIAQAAAA==.',Pl='Playerawhtgv:BAAALAADCgYIBgAAAA==.',Ro='Rockwang:BAAALAAFFAQIBAAAAA==.',Sc='Schizophrene:BAABLAAECn8dAAICAAYI/CLCLgDXAQACAAYI/CLCLgDXAQAAAA==.Schroeder:BAAALAAECgYIBgAAAA==.',Su='Sunshiny:BAAALAADCgIIAgAAAA==.',Ta='Tale:BAAALAAECgEIAQAAAA==.',To='Tom:BAAALAAFFAQIBAAAAA==.',Wo='Wojiaoqiao:BAABLAAFFH8GAAIMAAYI6QbXRAAnAQAMAAYI6QbXRAAnAQAAAA==.',Xx='Xxooxxoo:BAAALAAECgEIAQAAAA==.',Zi='Zimmermann:BAAALAAECgYIDgAAAA==.',Zs='Zsdevil:BAAALAADCgEIAQAAAA==.',['一万']='一万个恶魔:BAAALAAECgYICgAAAA==.',['一夕']='一夕意相左:BAAALAAECgQIBAAAAA==.',['一队']='一队的小德:BAAALAADCgYIBgAAAA==.',['一首']='一首双歌:BAAALAAECgIIAgAAAA==.一首战歌:BAAALAAFFAIIBAAAAA==.',['七名']='七名:BAABLAAFFH8FAAIJAAIIChu5NACWAAAJAAIIChu5NACWAAAAAA==.',['万法']='万法玄尊:BAAALAADCgEIAQAAAA==.',['三尖']='三尖两刃枪:BAABLAAECn8UAAIFAAYIIBrJaADNAQAFAAYIIBrJaADNAQAAAA==.',['三把']='三把蝴蝶叨:BAAALAADCgUIBQAAAA==.',['上青']='上青天揽明月:BAABLAAFFH8GAAIEAAYIzABPvwAlAAAEAAYIzABPvwAlAAAAAA==.',['不二']='不二心:BAAALAAECggICAAAAA==.',['不射']='不射一箭:BAAALAAECgYIBgAAAA==.',['不成']='不成熟的想法:BAAALAAECgYICgAAAA==.',['不缺']='不缺圣光:BAAALAAECgEIAQAAAA==.',['不舍']='不舍:BAAALAAECgYIBgAAAA==.',['不要']='不要再打啦:BAABLAAFFH8GAAIFAAYIniVTGgCyAQAFAAYIniVTGgCyAQABLAAFFAgIFgAFADMTAA==.',['专捅']='专捅腰子:BAAALAAECgYIDAAAAA==.',['东方']='东方维也纳:BAAALAAECgYIBgAAAA==.',['两胯']='两胯插刀:BAAALAAECgYIEQAAAA==.',['丨侧']='丨侧漏丨:BAABLAAFFH8FAAINAAII4QFxOgAhAAANAAII4QFxOgAhAAAAAA==.',['丨天']='丨天愛丨:BAAALAAECgYICwAAAA==.',['丨小']='丨小黄花丨:BAAALAAFFAIIAgAAAA==.',['丶一']='丶一抹风情:BAAALAADCgEIAQAAAA==.丶一枚小生:BAAALAADCgcIBwAAAA==.',['丶冰']='丶冰雨丶:BAAALAAECgIIAgAAAA==.',['丶小']='丶小辣椒丶:BAAALAAECgYIBgAAAA==.',['丶红']='丶红唇:BAAALAAECgYICAAAAA==.',['为了']='为了琞光:BAAALAAECgYICwAAAA==.',['为情']='为情而生:BAAALAAFFAIIAgAAAA==.',['丿大']='丿大威天龍:BAABLAAFFH8XAAIOAAMIeBsqCwDXAAAOAAMIeBsqCwDXAAAAAA==.',['乂灬']='乂灬尛柒:BAAALAAFFAIIAgAAAA==.',['乄乌']='乄乌鸦:BAAALAAECgYICQAAAA==.',['乄战']='乄战战乄:BAAALAADCggICAAAAA==.',['久旱']='久旱逢甘露:BAAALAAECgEIAQAAAA==.',['之祠']='之祠:BAAALAAECgMIAwAAAA==.',['乱豆']='乱豆豆大魔王:BAAALAAECgMIBAAAAA==.',['二队']='二队那个武僧:BAAALAAFFAEIAQAAAA==.',['云卷']='云卷舒:BAAALAADCgcIBwAAAA==.',['五名']='五名:BAABLAAFFH8FAAIHAAIIrg/RTQBtAAAHAAIIrg/RTQBtAAAAAA==.',['亚托']='亚托克斯:BAACLAAFFH8IAAICAAIIsRUNRwCZAAACAAIIsRUNRwCZAAAsAAQKfxgAAgIABggqGia6AJABAAIABggqGia6AJABAAAA.',['亞尔']='亞尔萨拉斯:BAAALAAFFAIIAgAAAA==.',['亦可']='亦可奶:BAAALAAECgYIEQAAAA==.',['仗剑']='仗剑天涯:BAAALAAECgIIAgAAAA==.',['仙儿']='仙儿:BAAALAAECgYIBgAAAA==.',['代達']='代達羅斯:BAAALAAECgYIBgAAAA==.',['以德']='以德服人:BAABLAAFFH8KAAMPAAUItQQ1JQCGAAAPAAUItQQ1JQCGAAAJAAIIRQsmSgBcAAAAAA==.',['你石']='你石哥:BAABLAAFFH8ZAAICAAYIUBrVFQCgAQACAAYIUBrVFQCgAQAAAA==.',['侧漏']='侧漏哥:BAAALAAFFAIIBAAAAA==.',['信仰']='信仰圣光吧丶:BAABLAAFFH8dAAIIAAYIGxpaGQCkAQAIAAYIGxpaGQCkAQAAAA==.信仰灬戰士:BAAALAAECgYIEQAAAA==.',['健壮']='健壮而纯洁:BAAALAAFFAIIAgAAAA==.',['兄奶']='兄奶小挤不出:BAAALAAECgEIAQAAAA==.',['光头']='光头凡:BAAALAADCgMIAwAAAA==.',['兜兜']='兜兜里的豆包:BAAALAAECgYIBgAAAA==.',['养猪']='养猪丨丨大户:BAABLAAFFH8IAAMQAAIIIBVxSQBJAAANAAIIeA6IJQBzAAAQAAIIIBVxSQBJAAAAAA==.',['冥狱']='冥狱女王:BAABLAAFFH8mAAIMAAYIgBdwKgCOAQAMAAYIgBdwKgCOAQAAAA==.',['凑合']='凑合活着:BAABLAAFFH8IAAIMAAIICBFtigBBAAAMAAIICBFtigBBAAAAAA==.',['凛冬']='凛冬之骑:BAAALAAFFAMIBAAAAA==.',['出溜']='出溜儿:BAAALAADCggICwAAAA==.',['划过']='划过天的烈焰:BAAALAAECgYIDwAAAA==.',['励志']='励志抓小德:BAAALAAFFAIIBAAAAA==.',['勇敢']='勇敢牛牛丶:BAAALAAECgYIBgAAAA==.',['北境']='北境星河:BAACLAAFFH8IAAIMAAIIoiIANQDKAAAMAAIIoiIANQDKAAAsAAQKfxoAAwwABwjDINt1AAwCAAwABgjzINt1AAwCAAEABgg1GfkmAIcBAAAA.',['卅小']='卅小王凤:BAAALAADCgIIAgAAAA==.',['升旗']='升旗:BAAALAADCgQIBAAAAA==.',['半生']='半生浮萍:BAAALAAECgYICQAAAA==.',['单曲']='单曲:BAACLAAFFH8cAAMCAAYIlRdOHAB8AQACAAYIlRdOHAB8AQADAAII6hCIFgB8AAAsAAQKfxoAAgMABghWHZQnAMYBAAMABghWHZQnAMYBAAAA.单曲灬循环:BAACLAAFFH8QAAIRAAIIjRU4DAA4AAARAAIIjRU4DAA4AAAsAAQKfxUAAxEABggjFaEZAFYBABEABggjFaEZAFYBAAkABghpET1xAEMBAAAA.',['南风']='南风知我意:BAAALAADCgEIAQAAAA==.',['卡拉']='卡拉蹦吧:BAAALAAECgIIAgAAAA==.',['卧龙']='卧龙:BAAALAADCgYIBwAAAA==.',['双刀']='双刀乱舞:BAAALAAECgYIDAAAAA==.',['叛逆']='叛逆:BAAALAAECgMIAwAAAA==.叛逆之吻:BAAALAAECgYICwAAAA==.',['只冷']='只冷冻不保鲜:BAABLAAFFH8JAAIFAAYIgAdQXQA+AAAFAAYIgAdQXQA+AAAAAA==.',['叫峰']='叫峰哥:BAAALAAECgYICQAAAA==.',['叫我']='叫我大人:BAAALAAECgYIBgAAAA==.',['可以']='可以更矮:BAAALAADCgYICQAAAA==.',['可能']='可能大概:BAAALAAFFAIIAgAAAA==.',['叶知']='叶知夏:BAAALAADCgUIBQAAAA==.',['叶落']='叶落无声:BAABLAAFFH8GAAICAAII7xF8PgCfAAACAAII7xF8PgCfAAAAAA==.',['后街']='后街老登:BAABLAAFFH8TAAIQAAYIJhaWFgCpAQAQAAYIJhaWFgCpAQABLAAFFAYIJQAEAFUlAA==.',['启迪']='启迪智慧:BAAALAAECgEIAQAAAA==.',['吻你']='吻你半小时:BAAALAAECgYICgAAAA==.',['和暖']='和暖的阳光:BAAALAAECgYIBgAAAA==.',['咕咕']='咕咕:BAABLAAFFH8MAAMJAAYI1BX6FgB8AQAJAAYI1BX6FgB8AQAPAAIIwg15JgB+AAAAAA==.',['咕咩']='咕咩呐噻丶:BAAALAADCggICAAAAA==.',['咸鱼']='咸鱼光环:BAABLAAFFH8gAAIMAAYIaw5HNQBnAQAMAAYIaw5HNQBnAQAAAA==.',['咸鸭']='咸鸭蛋大叔:BAAALAAECgUIBQAAAA==.',['哈士']='哈士骑:BAAALAAFFAIIAgAAAA==.',['啊啊']='啊啊噢哦阿:BAACLAAFFH8cAAQSAAYIDA2uKAD/AAASAAUIfwyuKAD/AAAHAAUI0g8ILgD7AAATAAII3QbnBgBIAAAsAAQKfyEAAwcACAg0GWQ5ADMCAAcACAg0GWQ5ADMCABMABwgrFSITALABAAAA.',['啊惹']='啊惹妞妞:BAAALAADCggICAAAAA==.',['啻丶']='啻丶:BAAALAAFFAMIAwAAAA==.',['喵喵']='喵喵丶喵:BAAALAAECggICQABLAAFFAgIHgAMAKscAA==.喵喵法:BAABLAAFFH8MAAIFAAIIPhCyUgCOAAAFAAIIPhCyUgCOAAAAAA==.',['嗜血']='嗜血灬嚣张:BAABLAAECn8bAAIEAAcIehaZXQCHAQAEAAcIehaZXQCHAQAAAA==.',['嘿嘿']='嘿嘿丶:BAABLAAFFH8OAAIEAAYILBjeMAB1AQAEAAYILBjeMAB1AQAAAA==.嘿嘿灬:BAAALAAFFAIIAgAAAA==.',['四型']='四型:BAAALAADCgUIBQAAAA==.',['土豆']='土豆豆:BAABLAAFFH8HAAICAAIIKB0FKgC1AAACAAIIKB0FKgC1AAAAAA==.土豆骑士:BAAALAAECgUIBQAAAA==.',['圣光']='圣光好好:BAAALAAFFAIIBAAAAA==.圣光灬骑士:BAABLAAECn8VAAMCAAYIjSU8HQArAgACAAYIjSU8HQArAgADAAEIDxySPQBQAAAAAA==.',['圣墟']='圣墟领主:BAAALAAFFAMIAwAAAA==.',['在世']='在世真龙:BAAALAAFFAIIAgAAAA==.',['地狱']='地狱烬苦:BAACLAAFFH8GAAILAAIIghApRACSAAALAAIIghApRACSAAAsAAQKfxUABAoABgj0Fw4ZAD8BAAsABgh6F1FwAKYBAAoABgi2CQ4ZAD8BABQAAwi1EQ12AKEAAAAA.',['坐享']='坐享其橙:BAABLAAFFH8GAAIFAAYI7xOEDgDzAQAFAAYI7xOEDgDzAQAAAA==.',['堕落']='堕落小猛猛:BAAALAAECggICAAAAA==.堕落灬东方:BAABLAAECn8fAAISAAYIxiFRGQDgAQASAAYIxiFRGQDgAQAAAA==.堕落灬西门:BAABLAAECn8xAAIEAAYIniQmMQD4AQAEAAYIniQmMQD4AQAAAA==.堕落的小爱:BAACLAAFFH8LAAIVAAMIpgpuIgBvAAAVAAMIpgpuIgBvAAAsAAQKfxUAAxUACAjMGHIsACACABUACAjMGHIsACACABYAAQglBKHDACgAAAAA.',['增强']='增强理理:BAAALAADCgQIBAABLAAFFAMIBAAXAAAAAA==.',['壮牛']='壮牛么么:BAAALAADCgUICQAAAA==.',['复古']='复古裝娕:BAAALAAECgEIAQAAAA==.',['夏多']='夏多蕾:BAAALAAECgYICwAAAA==.',['夜之']='夜之幽影:BAAALAAFFAIIAgAAAA==.',['夜伴']='夜伴二锅头:BAABLAAFFH8GAAIFAAIIqQfUWQCGAAAFAAIIqQfUWQCGAAAAAA==.',['夜幕']='夜幕降淋:BAABLAAFFH8GAAMUAAIIBBO/KQBOAAALAAEI8xYbWwBPAAAUAAEIFQ+/KQBOAAAAAA==.',['大丶']='大丶石:BAAALAAECgYIBgAAAA==.',['大主']='大主宰:BAAALAAECgQIBwAAAA==.',['大仙']='大仙儿:BAAALAAECgYIBgAAAA==.',['大叔']='大叔也不错:BAAALAAECgQIBwAAAA==.',['大只']='大只佬:BAAALAAECgYICQAAAA==.',['大哥']='大哥骑士:BAAALAAECgYIBgAAAA==.',['大威']='大威天龍:BAAALAAECgYICwAAAA==.',['大富']='大富豪:BAAALAADCgQIBAAAAA==.',['大日']='大日霊:BAAALAAFFAIIAgAAAA==.',['大水']='大水:BAAALAAECgYICQAAAA==.',['大酋']='大酋长丨恩佐:BAAALAAECgQIBAAAAA==.',['大锤']='大锤仈拾:BAAALAAECgYIDQAAAA==.',['天空']='天空依然蔚蓝:BAAALAAECgYIBgAAAA==.',['奈格']='奈格大坝:BAABLAAFFH8MAAMWAAIIIRk4NACWAAAWAAIIIRk4NACWAAAYAAEI4QrHCAArAAAAAA==.',['奶小']='奶小挤不出:BAAALAADCgQIBAAAAA==.',['如此']='如此肆意妄为:BAAALAAECggICQAAAA==.',['妹妹']='妹妹有大长腿:BAAALAAFFAIIAgAAAA==.',['威力']='威力无穷:BAAALAAECgQIBAAAAA==.',['媚驴']='媚驴:BAAALAADCgEIAQAAAA==.',['嫖姚']='嫖姚校尉:BAAALAADCgQIBAAAAA==.',['孔雀']='孔雀再战江湖:BAAALAAECgYIDAAAAA==.',['孤云']='孤云烟客:BAACLAAFFH8IAAIZAAYIlQRVDQDoAAAZAAYIlQRVDQDoAAAsAAQKfxkAAhkACAiGFUgWAFsBABkACAiGFUgWAFsBAAAA.',['孤月']='孤月:BAAALAAECgQIBAAAAA==.',['守护']='守护水瓶座:BAAALAAECgIIAgAAAA==.',['寂寞']='寂寞狩猎者:BAACLAAFFH8KAAIEAAMIQBnFZwCWAAAEAAMIQBnFZwCWAAAsAAQKfxgAAgQACAjII/QJANACAAQACAjII/QJANACAAAA.',['寂月']='寂月:BAABLAAFFH8QAAICAAYIFx01EgC2AQACAAYIFx01EgC2AQAAAA==.',['審判']='審判之翼:BAABLAAFFH8dAAICAAUI5hhiJgBEAQACAAUI5hhiJgBEAQAAAA==.',['寻找']='寻找我的她:BAABLAAFFH8FAAICAAMIaSA9EgApAQACAAMIaSA9EgApAQAAAA==.',['射狂']='射狂:BAAALAADCggICgAAAA==.',['射的']='射的稳跑的快:BAAALAAECgYIBgAAAA==.',['小丶']='小丶破孩:BAAALAAECgQIBAAAAA==.',['小云']='小云雀郁代:BAAALAAECgEIAQAAAA==.',['小小']='小小龙人:BAABLAAFFH8IAAMaAAMIwQKGHABdAAAaAAMIwQKGHABdAAAbAAMIbwTZDQBaAAAAAA==.',['小屁']='小屁孩源:BAAALAAECgYIBgAAAA==.',['小故']='小故事里的人:BAABLAAFFH8MAAMSAAYIKwF5OQBxAAASAAYIKwF5OQBxAAAHAAYI6ACoagBQAAAAAA==.',['小无']='小无吃了吗:BAAALAAECgEIAQAAAA==.',['小楊']='小楊丶:BAAALAAECgIIBAAAAA==.',['小灬']='小灬狐灬狸:BAABLAAFFH8KAAIEAAIITxIFmgBBAAAEAAIITxIFmgBBAAAAAA==.',['小点']='小点心:BAAALAAECgIIAgAAAA==.',['小盆']='小盆友:BAAALAAECgYICQAAAA==.',['小红']='小红袄:BAABLAAFFH8gAAMHAAYISCHNCAA4AgAHAAYISCHNCAA4AgASAAQIAheQLADWAAABLAAFFAYIJQAEAFUlAA==.',['小贰']='小贰黑:BAAALAAECgYICQAAAA==.',['小黑']='小黑脸:BAACLAAFFH8HAAINAAIICQVxLwBYAAANAAIICQVxLwBYAAAsAAQKfxgAAxAABwiBEQhxAMIAABAABgi+EQhxAMIAAA0ABQhLD8Y6AKgAAAAA.',['尐样']='尐样儿:BAAALAAFFAIIBAAAAA==.',['尔滨']='尔滨吴彦祖:BAAALAAECgUIBwAAAA==.',['尖嘴']='尖嘴嘴:BAAALAAECgQIBAAAAA==.',['尖耳']='尖耳朵:BAAALAADCgcIBwAAAA==.',['尘枫']='尘枫乀:BAAALAADCgEIAQAAAA==.',['就想']='就想试一试:BAABLAAFFH8eAAMMAAYIrx14IgCqAQAMAAYIVxx4IgCqAQABAAQIghogCAD+AAABLAAFFAYIJQAEAFUlAA==.',['就是']='就是想试试:BAAALAADCgMIAwAAAA==.',['尼姑']='尼姑妹妹:BAACLAAFFH88AAMZAAcI9huEAgAXAgAZAAcI9huEAgAXAgAcAAIIOwZ3IAAzAAAsAAQKfyEAAhkACAj1ILoLAOECABkACAj1ILoLAOECAAAA.',['岁朵']='岁朵朵:BAAALAADCgIIAgAAAA==.',['巨野']='巨野大:BAAALAAECgMIBgAAAA==.',['布洛']='布洛灬克斯:BAAALAAECgYIBgAAAA==.',['布莱']='布莱克曼:BAAALAAFFAEIAQAAAA==.',['带感']='带感:BAAALAAFFAIIAgAAAA==.',['平地']='平地摔跤:BAAALAAECgEIAQAAAA==.',['幽之']='幽之夜:BAAALAAECgYIDAAAAA==.',['幽灵']='幽灵幻影:BAAALAAECgUIBQAAAA==.',['幽狱']='幽狱:BAAALAAECgQIBAAAAA==.',['庄生']='庄生梦蝶丶:BAAALAAECggICAAAAA==.',['弟奶']='弟奶小挤不出:BAAALAAECgcIDQAAAA==.',['彦祖']='彦祖:BAABLAAFFH8HAAILAAIIPiCcMAC4AAALAAIIPiCcMAC4AAAAAA==.',['德雷']='德雷:BAAALAAECgMIAwAAAA==.',['忘尘']='忘尘:BAABLAAFFH8GAAIIAAYIlgW8QACLAAAIAAYIlgW8QACLAAAAAA==.',['快拉']='快拉倒吧:BAAALAAECgQIBQAAAA==.',['念旧']='念旧的人:BAAALAAFFAIIBAAAAA==.',['怎么']='怎么梳都倦:BAABLAAFFH8MAAICAAUIPQu2LwAIAQACAAUIPQu2LwAIAQABLAAFFAYIIwAMAEUOAA==.怎么梳都卷:BAACLAAFFH8eAAMQAAUIbRiMJABKAQAQAAUIbRiMJABKAQANAAEIxAE6NAAqAAAsAAQKfzUAAhAACAhXHfoqAJACABAACAhXHfoqAJACAAEsAAUUBggjAAwARQ4A.怎么梳都弮:BAAALAAFFAIIAgAAAA==.怎么梳都菤:BAACLAAFFH8jAAIMAAYIRQ7rMQBzAQAMAAYIRQ7rMQBzAQAsAAQKfxkAAgwACAj+EwlXAEQBAAwACAj+EwlXAEQBAAAA.',['恐怖']='恐怖图腾:BAAALAAECgYIEQAAAA==.',['恶魔']='恶魔戒灵:BAACLAAFFH8VAAMKAAUIHw0xBACqAAALAAQIyAzgRADBAAAKAAQIVwoxBACqAAAsAAQKfxUAAwoABgjSE+QRAJcBAAoABgirE+QRAJcBAAsABQhJDDS5AAIBAAAA.恶魔狩猎你:BAAALAAECgQIBQAAAA==.',['情誼']='情誼承諾:BAAALAAECgMIAwAAAA==.',['我头']='我头上有犄角:BAAALAAECgMIAwAAAA==.',['我想']='我想静静:BAAALAAFFAEIAQAAAA==.',['我是']='我是一小青龙:BAAALAAECgYIEwAAAA==.',['我有']='我有多少秘密:BAAALAAECgYIBgAAAA==.',['我牛']='我牛我怕谁:BAAALAAECggICAAAAA==.',['我的']='我的圣光啊丶:BAAALAADCgIIAgAAAA==.',['我身']='我身後有尾巴:BAAALAAECgYIDQAAAA==.',['战斗']='战斗吧:BAAALAAECgYICQAAAA==.',['戰士']='戰士不愛你:BAAALAAECgYIBgAAAA==.',['抹茶']='抹茶豆沙包:BAAALAAECgYICAAAAA==.',['拯救']='拯救你的心:BAABLAAFFH8GAAIIAAYIshRlBwAnAgAIAAYIshRlBwAnAgAAAA==.拯救果果丶:BAABLAAFFH8GAAIQAAYIXRJdCAAMAgAQAAYIXRJdCAAMAgAAAA==.',['指甲']='指甲刀:BAAALAADCggICAAAAA==.',['握紧']='握紧拳头:BAAALAAECgIIAgAAAA==.',['搓个']='搓个大雪球:BAAALAAECgYIBwABLAAFFAgIGgAEACEOAA==.',['救赎']='救赎:BAAALAADCgIIAwAAAA==.',['无名']='无名王女:BAAALAAFFAIIAgAAAA==.',['无心']='无心小法:BAAALAAFFAIIAgAAAA==.',['无敌']='无敌电灯泡:BAAALAAECgUIBQAAAA==.',['无聊']='无聊的萨满:BAABLAAFFH8JAAIHAAIIXxlONgCUAAAHAAIIXxlONgCUAAAAAA==.',['无量']='无量天尊:BAABLAAECn8XAAIWAAcIYBYRQADXAQAWAAcIYBYRQADXAQAAAA==.',['星星']='星星会变羊:BAAALAAECggICAAAAA==.',['星期']='星期仈:BAAALAAECgMIAwAAAA==.星期八:BAAALAAECgUICAAAAA==.星期叭:BAAALAAECgEIAQAAAA==.',['星河']='星河自梦来:BAAALAAFFAIIBAAAAA==.',['春回']='春回天下:BAAALAADCgUIBgAAAA==.',['是狐']='是狐狸呢:BAAALAAFFAIIAgAAAA==.',['晓灬']='晓灬雨:BAAALAADCgMIAwAAAA==.',['智爷']='智爷:BAABLAAFFH8HAAMdAAIIFQtCKwBxAAAEAAII8whgbQCBAAAdAAIINApCKwBxAAAAAA==.',['智高']='智高无上:BAABLAAFFH8pAAILAAUIkx6DLQBkAQALAAUIkx6DLQBkAQAAAA==.',['暗之']='暗之郭德纲灬:BAAALAAECggICAAAAA==.',['暗号']='暗号:BAAALAADCgEIAQAAAA==.',['暗夜']='暗夜:BAAALAAECggICAAAAA==.',['暴橙']='暴橙子:BAAALAAECgYICwAAAA==.',['有事']='有事偷着乐:BAABLAAFFH8IAAICAAQIkRRINgDPAAACAAQIkRRINgDPAAAAAA==.有事偷着笑:BAACLAAFFH8UAAMEAAYIzBppKACRAQAEAAYIzBppKACRAQAdAAIIahrvGwCZAAAsAAQKfxUAAh0ABwgIIzcWALECAB0ABwgIIzcWALECAAAA.',['望天']='望天数星星:BAAALAADCgEIAQAAAA==.',['木桃']='木桃爸爸:BAABLAAFFH8IAAIeAAIIpAWWGABUAAAeAAIIpAWWGABUAAAAAA==.',['未未']='未未:BAAALAAECgEIAQAAAA==.',['末邪']='末邪:BAAALAAECgYIBgAAAA==.',['术不']='术不远送:BAAALAAECgUIBgAAAA==.',['术了']='术了个士:BAACLAAFFH8GAAILAAIIYRjZRgCPAAALAAIIYRjZRgCPAAAsAAQKfxsAAwsABwhrHwAbAAkCAAsABwhrHwAbAAkCABQABAj+HZJIAE4BAAAA.',['朵大']='朵大爷:BAAALAAECgYICQAAAA==.',['李太']='李太白:BAAALAAFFAIIBAAAAA==.',['某白']='某白:BAABLAAFFH8IAAICAAIIDhDSSACYAAACAAIIDhDSSACYAAAAAA==.',['梦回']='梦回铁骑:BAABLAAFFH8GAAICAAYIRQFegwAhAAACAAYIRQFegwAhAAAAAA==.',['梦珑']='梦珑:BAAALAADCgEIAQAAAA==.',['步兵']='步兵:BAAALAAFFAIIBAABLAAFFAIIBgACAMoJAA==.',['武老']='武老二:BAAALAAECgYIEAAAAA==.武老贰:BAAALAAECgMIAwAAAA==.',['死亡']='死亡信使:BAAALAAECgYIDAAAAA==.',['殺戮']='殺戮天使:BAAALAAFFAIIAgAAAA==.',['毛喷']='毛喷喷:BAAALAAECgYICwAAAA==.',['毛大']='毛大爷:BAAALAAECgYIBwAAAA==.',['毛奶']='毛奶奶:BAABLAAFFH8GAAIcAAYIuSG5AQBjAgAcAAYIuSG5AQBjAgAAAA==.',['水墨']='水墨青花:BAAALAAFFAIIAgAAAA==.',['水鬼']='水鬼:BAAALAADCgIIAgAAAA==.',['沐北']='沐北清歌寒:BAABLAAFFH8KAAILAAII7xmjNACnAAALAAII7xmjNACnAAAAAA==.',['沐沐']='沐沐赞歌:BAAALAAECgYIBgAAAA==.',['没事']='没事就下线:BAABLAAFFH8MAAIHAAMI7xlzOQC9AAAHAAMI7xlzOQC9AAAAAA==.',['没妞']='没妞啦:BAAALAAECgYICwAAAA==.',['没烟']='没烟啦:BAAALAAECgYICwAAAA==.',['沧海']='沧海龙腾:BAAALAAECgYIDQAAAA==.',['沫灬']='沫灬小陌:BAAALAAECgUIBQAAAA==.沫灬尐陌:BAAALAAECggICAAAAA==.沫灬尛陌:BAAALAAECgYIBgAAAA==.',['法不']='法不溯及既往:BAAALAAECgYIBgAAAA==.',['法力']='法力无边丶:BAAALAAFFAIIBAAAAA==.',['泛泛']='泛泛格调:BAABLAAFFH8IAAICAAIIJw7aRgCZAAACAAIIJw7aRgCZAAAAAA==.',['泰蘭']='泰蘭德丨牧:BAAALAAECgYIBgAAAA==.',['洋锅']='洋锅:BAACLAAFFH8GAAIfAAIIQw4DHgCNAAAfAAIIQw4DHgCNAAAsAAQKfywAAwIACAjvHEE6AI0CAAIABwh1H0E6AI0CAB8ACAgeGZAdACMCAAAA.',['洛璃']='洛璃:BAAALAADCgEIAQAAAA==.',['津门']='津门川哥:BAAALAADCgUIBQAAAA==.',['流年']='流年外:BAAALAAECgYIBgAAAA==.',['流雲']='流雲:BAABLAAFFH8QAAIFAAMIXR07JgD7AAAFAAMIXR07JgD7AAABLAAFFAYIAwAXAAAAAA==.',['海坑']='海坑真是坑:BAAALAAECgYICgAAAA==.',['海边']='海边的菩提树:BAACLAAFFH8lAAIEAAYIVSWMDgAVAgAEAAYIVSWMDgAVAgAsAAQKfxkAAgQACAgxIj4qAA8CAAQACAgxIj4qAA8CAAAA.',['涅槃']='涅槃骑士:BAAALAADCgUIBgAAAA==.',['淘气']='淘气鬼:BAAALAAFFAIIAgAAAA==.',['淺色']='淺色紙鳶:BAAALAAECgEIAQAAAA==.',['源烨']='源烨:BAAALAADCggICAAAAA==.',['滴滴']='滴滴的大哥:BAABLAAFFH8MAAIcAAIIQAYnGwBfAAAcAAIIQAYnGwBfAAAAAA==.滴滴的小龙龙:BAAALAADCgMIAwAAAA==.滴滴的弟弟:BAAALAAECgEIAQAAAA==.',['火野']='火野丽:BAAALAAECgIIAgAAAA==.',['灬嗜']='灬嗜血:BAAALAADCgMIAwAAAA==.',['灬艾']='灬艾丨林艾程:BAAALAADCggICAAAAA==.',['灰狐']='灰狐:BAAALAAECgUIBQAAAA==.',['点烟']='点烟冲锋释放:BAAALAAECgMIAwAAAA==.',['烟雨']='烟雨石:BAAALAADCgQIBAAAAA==.',['烧包']='烧包萌:BAAALAADCgYIDAAAAA==.',['烧烤']='烧烤:BAAALAAECgYIDAAAAA==.',['烧豆']='烧豆腐:BAAALAADCgEIAQAAAA==.',['燃烧']='燃烧的射手座:BAABLAAFFH8GAAIEAAII6wduqwA5AAAEAAII6wduqwA5AAAAAA==.',['爱上']='爱上灬冬天:BAAALAADCgYICgAAAA==.爱上灬春天:BAAALAADCgYIBgAAAA==.爱上灬秋天:BAAALAADCgYIBgAAAA==.',['牛力']='牛力大仙:BAABLAAECn8bAAMNAAYI/RJPJAAlAQANAAYI/RJPJAAlAQAQAAYIEgAdIwEDAAAAAA==.',['牛大']='牛大爷:BAAALAAECgQIBQAAAA==.',['牛牛']='牛牛萨:BAAALAAECgYIBgAAAA==.',['牛肉']='牛肉面不要面:BAABLAAFFH8SAAICAAYIqhw0DwDLAQACAAYIqhw0DwDLAQAAAA==.',['牛虱']='牛虱:BAAALAADCgUIBQAAAA==.',['狂妃']='狂妃紫月:BAACLAAFFH8mAAICAAYIrAncEgAjAQACAAYIrAncEgAjAQAsAAQKfzwAAgIACAiuGp5EAG4CAAIACAiuGp5EAG4CAAAA.',['狂野']='狂野灬猎神:BAAALAAECgEIAQAAAA==.',['狼牙']='狼牙刺客:BAAALAAECgIIAwAAAA==.狼牙壮汉:BAAALAAECgYIDQAAAA==.狼牙武僧:BAAALAAECgYIBwAAAA==.狼牙猎手:BAAALAAECgYIBgAAAA==.狼牙闪电:BAAALAAECgIIAgAAAA==.狼牙骑士:BAAALAAECggIDwAAAA==.',['猛踢']='猛踢瘸子好腿:BAAALAAECgYIBgAAAA==.',['猫猫']='猫猫打了茂茂:BAAALAAFFAIIBAAAAA==.',['玛德']='玛德法克:BAAALAAECgEIAQAAAA==.玛德法克奥夫:BAAALAAFFAIIBAAAAA==.玛德珐科奥夫:BAAALAAECgUICAAAAA==.',['玥夜']='玥夜清风:BAAALAAFFAIIAgAAAA==.',['玩耍']='玩耍:BAABLAAFFH8GAAMSAAYIKBWCCwDIAQASAAUIbxeCCwDIAQAHAAEIKQaGcwA7AAAAAA==.',['珊蛮']='珊蛮:BAAALAADCgYIBgAAAA==.',['琺外']='琺外狂徒:BAAALAAECgUIBgAAAA==.',['瑞文']='瑞文戴尓:BAAALAAECgYIBgAAAA==.',['甲人']='甲人路:BAAALAADCgUIBQAAAA==.',['疯狂']='疯狂小马:BAABLAAFFH8GAAIMAAYI0QdTRgAhAQAMAAYI0QdTRgAhAQAAAA==.疯狂的杨梅:BAABLAAFFH8GAAMfAAIImASyKwBeAAAfAAIImASyKwBeAAACAAIIsBTsWwBIAAAAAA==.疯狂的荔枝:BAAALAADCgYIBgAAAA==.',['痕灬']='痕灬迹:BAABLAAFFH8GAAIDAAII3A/FFgB7AAADAAII3A/FFgB7AAAAAA==.',['白月']='白月光丶:BAAALAAECgQIBQAAAA==.',['白银']='白银之手:BAAALAAECgYICgAAAA==.',['看剑']='看剑念奴娇:BAAALAADCgYIBgAAAA==.',['睚眦']='睚眦必报:BAAALAAFFAQIBAAAAA==.',['石总']='石总有理想:BAABLAAFFH8HAAMSAAUIWAfnKgDnAAASAAUIWAfnKgDnAAAHAAII4ARccABKAAAAAA==.',['破法']='破法:BAAALAADCgQIBAAAAA==.',['磐石']='磐石丨麦德安:BAAALAAECgQIBQAAAA==.',['磨你']='磨你的血:BAAALAADCggICwAAAA==.',['神仙']='神仙佳偶也:BAAALAAFFAIIBAAAAA==.',['神官']='神官:BAAALAAECgYIEAAAAA==.',['神行']='神行太保:BAABLAAFFH8iAAMfAAYIaiQZBABtAgAfAAYIaiQZBABtAgACAAQIZBJkNgDOAAABLAAFFAYIJQAEAFUlAA==.',['神龙']='神龙大侠壹号:BAAALAADCgEIAQAAAA==.',['福生']='福生玄黄天尊:BAAALAAECgYIBgAAAA==.',['秋枫']='秋枫落:BAABLAAFFH8nAAIEAAcIlCNrBwBuAgAEAAcIlCNrBwBuAgAAAA==.',['秋雨']='秋雨:BAAALAAECgIIAgAAAA==.',['窗外']='窗外下了雨:BAAALAAECgIIAgAAAA==.',['立地']='立地太岁:BAABLAAFFH8XAAIWAAYIFg/yFwDoAAAWAAYIFg/yFwDoAAABLAAFFAYIJQAEAFUlAA==.',['立风']='立风:BAAALAAFFAIIBAAAAA==.',['站在']='站在我前面:BAAALAAECgIIAgAAAA==.',['竞技']='竞技之光:BAAALAAECgIIAgAAAA==.竞技猎手:BAAALAAECgEIAQAAAA==.',['筱筱']='筱筱:BAAALAAECgYIBgAAAA==.',['米安']='米安妮:BAAALAAECgYIBgAAAA==.',['粟小']='粟小真:BAAALAAFFAIIAgAAAA==.',['精灵']='精灵赞歌:BAAALAAECgYICwAAAA==.',['紫羽']='紫羽灬雨:BAAALAAECgYIDwAAAA==.',['紫龙']='紫龙:BAAALAAECgcIEAAAAA==.',['红灵']='红灵火羽:BAAALAAECgYICAAAAA==.',['约德']='约德尔:BAAALAAECgIIAgAAAA==.',['纳闷']='纳闷中:BAAALAAFFAIIAgAAAA==.',['给我']='给我来一碗:BAAALAADCgcIBwAAAA==.',['绯雪']='绯雪千夜:BAAALAAFFAIIBAAAAA==.',['网恋']='网恋秀被图:BAAALAAFFAMIAwAAAA==.',['罗斯']='罗斯特:BAAALAAFFAIIAgAAAA==.',['美人']='美人儿坯:BAAALAAECgYIEQAAAA==.美人坯子:BAAALAAECgYICQAAAA==.',['美式']='美式加冰:BAAALAADCgQIBAAAAA==.',['美食']='美食:BAAALAAECgYIBgAAAA==.',['美驴']='美驴姐:BAAALAADCgcIBwAAAA==.',['老和']='老和:BAABLAAFFH8eAAMEAAYI4xXuNgBiAQAEAAYIqhTuNgBiAQAgAAII+BlSAwCpAAAAAA==.',['老猎']='老猎:BAAALAAECgYIBgAAAA==.',['老白']='老白猎:BAAALAAECgUIBQAAAA==.',['考拉']='考拉牛牛:BAAALAAECgQICAAAAA==.',['聖丶']='聖丶光:BAAALAAECgUIBAAAAA==.',['能打']='能打能抗:BAAALAAECgYIEQAAAA==.',['脸滚']='脸滚键的教父:BAABLAAECn8XAAMfAAgIphFHFQCyAQAfAAgIphFHFQCyAQACAAIIOAfu6QAwAAAAAA==.',['自制']='自制牛肉堡:BAAALAADCgUIBQAAAA==.',['艾尔']='艾尔罗格:BAAALAAECgYIBgAAAA==.',['芸啟']='芸啟芸逻:BAAALAAFFAIIBAAAAA==.',['苗裔']='苗裔之斯:BAAALAAECgIIAgAAAA==.',['苦的']='苦的哇哇哭:BAABLAAECn8VAAMUAAcIIBs6IAABAgAUAAcIHRg6IAABAgAKAAUIxBaFFwBRAQAAAA==.',['范尼']='范尼斯特鲁伊:BAAALAADCgcIBwAAAA==.',['茶几']='茶几上的悲剧:BAAALAADCgMIAwAAAA==.',['草履']='草履虫:BAAALAAECgYIDAABLAAFFAgIHwAIAEEkAA==.',['荣耀']='荣耀灬哀木踢:BAAALAAECgYIBgAAAA==.荣耀灬怒风:BAAALAAECgEIAQAAAA==.荣耀的圣剑:BAACLAAFFH8MAAICAAUIFBrIJQBHAQACAAUIFBrIJQBHAQAsAAQKfyUAAgIABwjLH2weACQCAAIABwjLH2weACQCAAAA.',['莫逆']='莫逆丶烈与霜:BAAALAAECgIIAgAAAA==.',['莫邪']='莫邪血殇:BAAALAAECgYIBgAAAA==.',['菜菜']='菜菜森:BAACLAAFFH8LAAIcAAMIHBEEFQB8AAAcAAMIHBEEFQB8AAAsAAQKfx8AAhwACAj/HxsIAOUCABwACAj/HxsIAOUCAAAA.',['葛优']='葛优:BAAALAADCgIIAgAAAA==.',['葡萄']='葡萄丨柚子茶:BAAALAAECgUIBQAAAA==.',['蘇小']='蘇小喵:BAAALAAECgYIEQAAAA==.',['虽然']='虽然但是:BAACLAAFFH8gAAIEAAUIKhlyRwAtAQAEAAUIKhlyRwAtAQAsAAQKfyMAAwQABwj3ID5IAFECAAQABwjAID5IAFECAB0ABAhHGLx3APUAAAAA.',['蜘蛛']='蜘蛛侦探:BAABLAAECn8XAAMEAAcIWR+IcwD1AQAEAAcIvB2IcwD1AQAdAAQIKCHWVABkAQAAAA==.',['血色']='血色大蘑菇:BAAALAAECgEIAQAAAA==.血色爱恋:BAAALAAECgYIBgAAAA==.血色飘雨:BAACLAAFFH8KAAIMAAUIvBEIRAAqAQAMAAUIvBEIRAAqAQAsAAQKfx4AAgwABgipHYczAKoBAAwABgipHYczAKoBAAAA.',['血驴']='血驴哥:BAAALAAECgMIAwAAAA==.',['西伯']='西伯利亚快车:BAAALAAFFAIIBAAAAA==.',['西门']='西门吹牛:BAABLAAFFH8IAAIRAAIIJRDsDgAoAAARAAIIJRDsDgAoAAAAAA==.',['见风']='见风倒:BAAALAAECgEIAQAAAA==.',['见饭']='见饭饿:BAAALAAECgYICwAAAA==.',['视觉']='视觉震撼:BAAALAAECgYIDAAAAA==.',['诗羽']='诗羽:BAAALAAECgEIAQAAAA==.',['请叫']='请叫我小甜甜:BAABLAAFFH8YAAMPAAYIKRQFEQBjAQAPAAYIKRQFEQBjAQAJAAUIhRRqIAAcAQAAAA==.',['谁也']='谁也不知道:BAAALAAECgQIBgAAAA==.',['谁在']='谁在雨中哭泣:BAAALAAECgYIDwAAAA==.',['贰叁']='贰叁:BAAALAADCgUIBQAAAA==.',['超级']='超级大白牛:BAAALAAECgYICgAAAA==.',['超超']='超超级赛亞人:BAAALAAECggIDgAAAA==.',['越野']='越野流光:BAAALAAECgYICQAAAA==.',['跨省']='跨省通缉犯:BAAALAAECgIIAgAAAA==.',['踏我']='踏我的风:BAAALAADCgYIBgAAAA==.',['蹦蹦']='蹦蹦熊彡:BAAALAAECgEIAQAAAA==.',['辛多']='辛多蕾:BAAALAAECgYIBgAAAA==.',['迷茫']='迷茫小琦:BAAALAAECgQIBAAAAA==.迷茫小骑:BAABLAAFFH8PAAICAAUIhQvaLwAGAQACAAUIhQvaLwAGAQAAAA==.',['追忆']='追忆雷霆:BAACLAAFFH8JAAMQAAMIEQY8PgBuAAAQAAMIEQY8PgBuAAANAAIIQgIzOgAiAAAsAAQKfxoAAw0ABwgEDuEqAPwAAA0ABwg4DeEqAPwAABAABQjFCBzQAM4AAAAA.',['逝水']='逝水流年如梦:BAAALAADCgIIAgAAAA==.',['道路']='道路概预算:BAAALAAFFAIIAgAAAA==.',['邓布']='邓布利多:BAABLAAFFH8GAAMGAAIIGgkIHQA3AAAFAAIISwIGZQBqAAAGAAIIGgkIHQA3AAAAAA==.',['部落']='部落一红牛:BAAALAADCgMIBAAAAA==.',['醉丶']='醉丶千愁:BAAALAAECgYIEQAAAA==.',['重返']='重返德军总部:BAABLAAFFH8PAAIJAAUIIg8bIAAfAQAJAAUIIg8bIAAfAQAAAA==.',['野兽']='野兽主宰:BAAALAAECgYIBgAAAA==.',['野生']='野生火爆猴:BAAALAADCgEIAQAAAA==.野生的萨满:BAAALAAECgUIBwAAAA==.',['野驴']='野驴哥:BAAALAAECgYIEwAAAA==.',['钾腿']='钾腿:BAAALAAFFAIIAgAAAA==.',['铃儿']='铃儿小叮当丶:BAAALAAECgUIBQAAAA==.',['铝腿']='铝腿:BAAALAAFFAIIBAAAAA==.',['长春']='长春丶吴彦祖:BAAALAAECgIIAgAAAA==.',['长歌']='长歌松:BAABLAAFFH8IAAIFAAIIuA5XTgCSAAAFAAIIuA5XTgCSAAAAAA==.',['阳光']='阳光在照耀:BAAALAAECgQIBAAAAA==.阳光雨大地:BAAALAAECgYICwAAAA==.',['阿兹']='阿兹大魔王丶:BAABLAAECn8VAAIEAAYIRRdYcABjAQAEAAYIRRdYcABjAQAAAA==.',['阿门']='阿门:BAAALAAECgYIBgAAAA==.',['陆观']='陆观仙人:BAABLAAFFH8KAAIMAAIIVA6WjQA/AAAMAAIIVA6WjQA/AAAAAA==.',['除非']='除非包吃包住:BAAALAADCggIDwAAAA==.',['陶然']='陶然若梦:BAABLAAFFH8wAAMEAAcI1CUzBQCbAgAEAAcI1CUzBQCbAgAdAAII2gqaDwCBAAAAAA==.',['雨落']='雨落寒沙:BAAALAAECgYIEAAAAA==.',['雲喏']='雲喏喏:BAAALAAECgUIDAAAAA==.',['零度']='零度:BAAALAADCgEIAQAAAA==.',['零浩']='零浩:BAAALAADCgcIBwAAAA==.',['霆霓']='霆霓快雨:BAAALAAECgYICAAAAA==.',['霜之']='霜之守护者:BAABLAAFFH8FAAIMAAMIyhEyLwDeAAAMAAMIyhEyLwDeAAAAAA==.',['霸道']='霸道小死骑:BAAALAADCgUIBQAAAA==.',['青旋']='青旋:BAAALAADCgIIAgAAAA==.',['青涩']='青涩后妈:BAACLAAFFH8UAAQaAAYIHhlwBgCNAQAaAAUIvhhwBgCNAQAbAAIIyxCSCgBdAAAhAAIIzhK9IQA2AAAsAAQKfxQABBoABghFGG8eAHsBABoABghFGG8eAHsBACEABQjmGyMbABoBABsAAQhUC0IcADgAAAAA.',['飞起']='飞起的梦游:BAAALAAECgEIAQAAAA==.',['香辣']='香辣小龙虾:BAAALAAECgYIBgAAAA==.',['马达']='马达加鲁鲁:BAAALAAECgYICQAAAA==.',['骇人']='骇人鲸:BAABLAAFFH8ZAAIQAAYIbhpOFQCxAQAQAAYIbhpOFQCxAQAAAA==.',['骑兵']='骑兵:BAABLAAFFH8GAAICAAIIygm8UQCRAAACAAIIygm8UQCRAAAAAA==.',['骑着']='骑着小萨摩:BAAALAAFFAgIAwAAAA==.',['骷髅']='骷髅小射手:BAAALAADCgIIBAAAAA==.',['高小']='高小歪丶:BAAALAAECgUICQAAAA==.',['鬟髻']='鬟髻青衣:BAABLAAFFH8GAAICAAYI1A1rNgDOAAACAAYI1A1rNgDOAAAAAA==.',['鸢尾']='鸢尾轻绽:BAAALAADCgMIAwAAAA==.',['麦当']='麦当当:BAABLAAFFH8OAAIMAAII3R2GVwCcAAAMAAII3R2GVwCcAAAAAA==.',['黑之']='黑之末日:BAAALAAFFAIIBAAAAA==.',['黑手']='黑手丿:BAAALAAECgYIBgAAAA==.',['黑的']='黑的臭的:BAABLAAFFH8GAAIQAAMIbApSPgBtAAAQAAMIbApSPgBtAAAAAA==.',['默默']='默默不语:BAACLAAFFH8zAAILAAcI5RwuDwDvAQALAAcI5RwuDwDvAQAsAAQKfyYAAgsACAhiI7cVAAQDAAsACAhiI7cVAAQDAAAA.',['黙灬']='黙灬小陌:BAAALAAECgYICgAAAA==.',['黯羽']='黯羽:BAAALAAECgUICAAAAA==.',['齐宣']='齐宣王田辟疆:BAAALAAECgYIDQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end