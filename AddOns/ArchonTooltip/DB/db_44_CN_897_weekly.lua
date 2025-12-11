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
 local lookup = {'Shaman-Elemental','Shaman-Restoration','Warlock-Destruction','Mage-Arcane','Mage-Frost','Paladin-Holy','Paladin-Retribution','Priest-Shadow','Priest-Holy','Rogue-Outlaw','Rogue-Subtlety','Rogue-Assassination','Priest-Discipline','DeathKnight-Frost','DeathKnight-Blood','Druid-Restoration','Druid-Balance','Druid-Feral','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Unholy','Warlock-Demonology','DemonHunter-Havoc','Unknown-Unknown','Mage-Fire','Warrior-Protection','Warrior-Fury','Monk-Brewmaster','Evoker-Preservation','Evoker-Devastation','Paladin-Protection','DemonHunter-Vengeance','Hunter-Survival','Monk-Mistweaver','Monk-Windwalker','Evoker-Augmentation',}; local provider = {region='CN',realm='黑暗虚空',name='CN',type='weekly',zone=44,date='2025-12-10',data={Ac='Acekillerlol:BAAALAAECgQIBAAAAA==.Acintosh:BAAALAAECgEIAQAAAA==.',Ag='Agoni:BAAALAAECgYIBgAAAA==.',As='Ashleyh:BAAALAAFFAIIBAAAAA==.',Br='Braker:BAAALAAECgUIBQAAAA==.',Cr='Crazypriest:BAACLAAFFH8lAAMBAAYIPh2iHABgAQABAAUIyB6iHABgAQACAAUILiAgEgApAQAsAAQKfykAAwIACAgIIVUcAKYCAAIACAgIIVUcAKYCAAEABgh3HvBQAMcBAAAA.',Da='Daniel:BAAALAADCgUIBQAAAA==.',Di='Divano:BAAALAAECgMIAwAAAA==.',Ed='Edogawa:BAABLAAFFH8IAAIDAAgIYQACawA3AAADAAgIYQACawA3AAAAAA==.',Es='Esmelada:BAAALAADCgQIBAAAAA==.',Fu='Furj:BAAALAAECgYIBQAAAA==.',Gg='Ggbood:BAACLAAFFH8KAAIEAAMIziNLIAApAQAEAAMIziNLIAApAQAsAAQKfyUAAwQACAhwJUILADoDAAQACAhwJUILADoDAAUAAQgGDSyVADEAAAAA.',Hd='Hdgzlgmwzy:BAACLAAFFH8VAAMGAAYInAiuGQD6AAAGAAUIYwWuGQD6AAAHAAUIVwcfNQDkAAAsAAQKfxUAAwYACAipFd1HADoBAAYABQhCEt1HADoBAAcABwhqComlALgAAAAA.',Hi='Hiaus:BAACLAAFFH8nAAMEAAYIQRdxIQCRAQAEAAYI3xVxIQCRAQAFAAEI7RIjFABIAAAsAAQKfxkAAwUACAghGMMpAN4BAAUABwhqGcMpAN4BAAQACAjzEQ5jANwBAAAA.Hibe:BAAALAAFFAIIAgAAAA==.',Im='Imwolf:BAAALAAECgcIDgAAAA==.',In='Insonmia:BAAALAAFFAIIAgAAAA==.',Is='Isyalvie:BAACLAAFFH8yAAMIAAYI4BG8EQBVAQAIAAYI4BG8EQBVAQAJAAUIrgIxKQDqAAAsAAQKfyoAAwgACAiiFFgsACACAAgACAiiFFgsACACAAkACAiCDgIwAEMBAAAA.',Iz='Izumi:BAAALAADCggICAAAAA==.',Ji='Jirogue:BAABLAAECn8cAAQKAAgI1CPvAwCLAQAKAAYIPCPvAwCLAQALAAUIMR3sKgBDAQAMAAMI4iVbRQA3AQAAAA==.',Ly='Lynnzt:BAABLAAFFH8MAAIHAAIIIyOWKQC2AAAHAAIIIyOWKQC2AAABLAAFFAIIEgABAOMfAA==.',Ma='Marviex:BAAALAAECgEIAQAAAA==.Maxmatch:BAAALAADCggICAAAAA==.Maylife:BAAALAAECgYIBgAAAA==.',Mi='Mimatch:BAAALAADCgMIAwAAAA==.Missyaal:BAABLAAECn8aAAMNAAgIZg0aDAA5AQAJAAgILwz+LwBEAQANAAcI+wsaDAA5AQAAAA==.',My='Mygame:BAAALAAECgYICQAAAA==.',Ne='Netfly:BAAALAAECgYICgAAAA==.',Ou='Ouroboros:BAACLAAFFH8kAAIHAAYItSAODwDRAQAHAAYItSAODwDRAQAsAAQKfyUAAgcACAhoIk4lANsCAAcACAhoIk4lANsCAAAA.',Pa='Pamper:BAAALAADCgQIBAAAAA==.',Ra='Rainbowsugar:BAAALAAECgMIAwAAAA==.',Sh='Shiroeazs:BAACLAAFFH8yAAIEAAYIiRWzJACDAQAEAAYIiRWzJACDAQAsAAQKfyQAAgQACAi6GbBBAEUCAAQACAi6GbBBAEUCAAAA.',Sk='Skrskr:BAAALAAECgYIDAAAAA==.',Sp='Spz:BAACLAAFFH8VAAIEAAUIbgx+LADgAAAEAAUIbgx+LADgAAAsAAQKfx4AAgQABwjGEOeBAI0BAAQABwjGEOeBAI0BAAAA.',To='Tomas:BAAALAAECgIIAQAAAA==.Tovarishch:BAAALAADCgQIBAAAAA==.',Us='Usk:BAABLAAFFH8MAAIDAAMI7hZOPACcAAADAAMI7hZOPACcAAAAAA==.',Wh='Wheelchair:BAABLAAECn8WAAIOAAcIFRmfRQB0AQAOAAcIFRmfRQB0AQAAAA==.',Wi='Wickedrnanny:BAAALAAECgYIBgAAAA==.',Xi='Xiaoxin:BAAALAAECgMIAwAAAA==.',Yu='Yuchihap:BAAALAAFFAIIBAAAAA==.',Yz='Yzolaphilo:BAABLAAFFH8sAAIPAAYIwgaEEAD1AAAPAAYIwgaEEAD1AAAAAA==.',['Àâ']='Àâãäcaroline:BAAALAAECgUIBgAAAA==.',['一一']='一一:BAAALAAFFAIIAgAAAA==.',['一七']='一七一会:BAABLAAFFH8GAAICAAIIGg46ZQBXAAACAAIIGg46ZQBXAAAAAA==.',['一刀']='一刀死:BAABLAAFFH8FAAIHAAMI8wyBSwBxAAAHAAMI8wyBSwBxAAAAAA==.',['一剑']='一剑三千甲:BAAALAAECgQICAAAAA==.',['一对']='一对獠牙:BAAALAAECgMIAwAAAA==.',['一氧']='一氧化二氢:BAACLAAFFH8XAAIQAAYIuhJ6GQBmAQAQAAYIuhJ6GQBmAQAsAAQKfx4AAhAACAjxGlkgANQBABAACAjxGlkgANQBAAAA.',['一生']='一生一火花丶:BAAALAAECgcIBwAAAA==.',['一禄']='一禄德:BAABLAAFFH8fAAQRAAYISx/UCgC6AQARAAYISx/UCgC6AQAQAAUIRxyOGABwAQASAAIIFxqNCgCoAAAAAA==.',['一笑']='一笑抚青萍:BAACLAAFFH8sAAMTAAYIWCO0GADbAQATAAYIWCO0GADbAQAUAAII0hjPIACHAAAsAAQKfx4AAxQACAjpHmQkAEkCABQACAglHWQkAEkCABMABggqIdZNAKwBAAAA.',['一级']='一级犀牛:BAAALAADCgIIAgAAAA==.',['一顿']='一顿吊锤:BAAALAADCggICAAAAA==.',['七月']='七月七日狼:BAAALAAECgYIBgAAAA==.七月七日雪:BAAALAAECgYICQAAAA==.',['万箭']='万箭齐发:BAAALAAFFAIIAgAAAA==.',['三丶']='三丶零四六:BAAALAAFFAIIAwAAAA==.',['三回']='三回归之魉风:BAABLAAFFH8FAAISAAIIVQXNEQAuAAASAAIIVQXNEQAuAAAAAA==.',['三色']='三色涂:BAAALAAFFAIIAgAAAA==.',['下大']='下大雨:BAAALAAECgYIDgAAAA==.',['不二']='不二不死:BAAALAAECgMIAwAAAA==.',['不准']='不准撒粉灬:BAACLAAFFH86AAQMAAYImyHICQAgAQAMAAQI0CLICQAgAQALAAQICxt2CgDxAAAKAAMIbRCBAwCRAAAsAAQKfzYABAsACAjAI6sIALkCAAsACAgqIasIALkCAAwABgicJUQIAO8BAAoAAQjHF/QdAEcAAAAA.',['不哭']='不哭死神丶:BAABLAAFFH8GAAIVAAYIJB8oAgDMAQAVAAYIJB8oAgDMAQAAAA==.',['不许']='不许敲自己:BAABLAAFFH8hAAIHAAYIISWqCAAJAgAHAAYIISWqCAAJAgABLAAFFAYIKQAWACgZAA==.',['世界']='世界萨搓炉石:BAABLAAFFH8LAAICAAIItAmNaQBTAAACAAIItAmNaQBTAAAAAA==.',['两佰']='两佰块就过夜:BAAALAADCgQIBAAAAA==.',['两面']='两面包夹芝士:BAACLAAFFH8uAAITAAYIoBlHFACAAQATAAYIoBlHFACAAQAsAAQKfzwAAxMACAgSIMMpALECABMACAgSIMMpALECABQAAwgSEhupAF4AAAAA.',['丨未']='丨未知丨:BAAALAAECgQIBAAAAA==.',['丶斯']='丶斯须:BAAALAAECgYICgAAAA==.',['丶皮']='丶皮卡丘:BAAALAADCgIIAgAAAA==.',['丶落']='丶落淸:BAABLAAFFH8GAAIXAAYI6QgXKABZAQAXAAYI6QgXKABZAQAAAA==.',['丿契']='丿契约:BAAALAAECggIBgAAAA==.',['乄媛']='乄媛儿灬:BAAALAAFFAIIAgABLAAFFAIIAgAYAAAAAA==.',['乌萨']='乌萨骑:BAAALAADCgYIBgABLAAECgYIBgAYAAAAAA==.',['乔德']='乔德尼吉尔英:BAAALAAFFAEIAQAAAA==.',['乘长']='乘长风:BAAALAAECgYIBgAAAA==.',['九夜']='九夜之冕:BAAALAAECgEIAQAAAA==.',['九天']='九天呆:BAAALAAFFAIIAgAAAA==.',['九龙']='九龙冰封:BAAALAAFFAMIAwAAAA==.',['乱花']='乱花迷人眼:BAAALAAECgYIBgAAAA==.',['乳小']='乳小奶稀:BAAALAADCgIIAgAAAA==.',['二十']='二十万个宠物:BAAALAAECgQIBAAAAA==.',['二流']='二流水鸭:BAABLAAFFH8GAAICAAIItxTZQACAAAACAAIItxTZQACAAAAAAA==.',['二营']='二营意大利炮:BAAALAADCgMIAwAAAA==.',['云丨']='云丨风行者:BAAALAAECgcIEQAAAA==.',['云卷']='云卷云舒:BAACLAAFFH8WAAMZAAYILyFvBQD/AAAEAAUI5SF3LABfAQAZAAMIRR5vBQD/AAAsAAQKfyAABAQACAjXITAfANMCAAQACAjXITAfANMCABkABAgoHaIHAD4BAAUAAQifG1eQADsAAAAA.',['云淡']='云淡风清:BAABLAAFFH8FAAIaAAII8hJYHwB/AAAaAAII8hJYHwB/AAAAAA==.',['亚当']='亚当:BAAALAAECgYIEgAAAA==.',['亦亦']='亦亦得失:BAAALAAFFAQIBAAAAA==.',['今晚']='今晚烤羊肉:BAABLAAFFH8FAAIEAAQITAY0QQCtAAAEAAQITAY0QQCtAAAAAA==.',['他和']='他和它:BAAALAAECgYIDQAAAA==.',['伍柒']='伍柒:BAAALAAFFAMIAwAAAA==.',['众所']='众所周知:BAAALAAECgMIAwAAAA==.',['低吟']='低吟的断剑:BAAALAAECgYIDAAAAA==.低吟的浅唱:BAAALAAECgYIEAAAAA==.低吟的涓溪:BAAALAAECgMIBwAAAA==.低吟的绝唱:BAABLAAFFH8MAAICAAIIoyWjNQDTAAACAAIIoyWjNQDTAAAAAA==.低吟的诅咒:BAABLAAFFH8IAAMFAAIIyhoyDQCcAAAFAAIIyhoyDQCcAAAEAAIITgQEYQB5AAAAAA==.',['佑鉺']='佑鉺環:BAABLAAFFH8LAAIHAAYIESH/CgDzAQAHAAYIESH/CgDzAQAAAA==.',['何处']='何处潇湘:BAAALAAFFAIIAgABLAAFFAYILAATAFgjAA==.',['你来']='你来就我来:BAAALAAECgYIBgAAAA==.',['侠客']='侠客行:BAAALAAECgYIBgAAAA==.',['俞大']='俞大妹:BAAALAAECgUIBQAAAA==.',['信仰']='信仰信仰圣光:BAAALAAECgYIDwAAAA==.',['倒数']='倒数第一:BAAALAAECgYIBgAAAA==.',['傑哥']='傑哥:BAAALAADCgYIBgAAAA==.',['傷之']='傷之影歌:BAABLAAFFH8FAAILAAUIIAUqCwDlAAALAAUIIAUqCwDlAAAAAA==.',['僵屍']='僵屍巴巴:BAAALAAECgMIAwAAAA==.僵屍辣椒:BAAALAAECgIIAgAAAA==.',['元始']='元始天尊:BAAALAAECgMIBgAAAA==.',['元气']='元气少女德彪:BAAALAAECgYIBgAAAA==.',['元素']='元素之怒:BAABLAAFFH8JAAMFAAMI9A5qBwDPAAAFAAMI9A5qBwDPAAAEAAEIBgTgbgA2AAAAAA==.',['光影']='光影传说:BAAALAAECgYIDAAAAA==.',['全部']='全部防出去了:BAACLAAFFH8SAAIGAAIIbR4ZHwCuAAAGAAIIbR4ZHwCuAAAsAAQKfx0AAgYACAjWGmQcACwCAAYACAjWGmQcACwCAAAA.',['八咫']='八咫琼:BAABLAAFFH8GAAIJAAIIzBECLgCRAAAJAAIIzBECLgCRAAAAAA==.',['八天']='八天丶巅:BAAALAAFFAIIAgAAAA==.',['八颗']='八颗苹果:BAABLAAFFH8FAAICAAIISBCuRQB4AAACAAIISBCuRQB4AAAAAA==.',['冬澪']='冬澪:BAABLAAFFH8NAAIOAAUIEx0MPQBOAQAOAAUIEx0MPQBOAQAAAA==.',['冰火']='冰火赞歌:BAAALAAECgcIEAAAAA==.',['冰雨']='冰雨飘零:BAAALAADCgYIBgAAAA==.',['冰风']='冰风玉术:BAAALAAECgYIEAAAAA==.冰风玉肌:BAABLAAECn8UAAIHAAYIygtcigDvAAAHAAYIygtcigDvAAAAAA==.',['冲锋']='冲锋俯身:BAABLAAFFH8GAAIbAAYI7AIjMADeAAAbAAYI7AIjMADeAAAAAA==.冲锋拦截斩杀:BAAALAADCgIIAgAAAA==.',['冷雨']='冷雨芭蕉:BAABLAAFFH8GAAIUAAYIEh0oAgAvAgAUAAYIEh0oAgAvAgAAAA==.',['凌宇']='凌宇:BAAALAADCgYIBgAAAA==.',['凌韵']='凌韵:BAAALAADCgEIAQAAAA==.',['凯伦']='凯伦丨凌:BAAALAADCgIIAQAAAA==.',['利刃']='利刃慧慧:BAAALAAECgYIBgAAAA==.',['别对']='别对莪放肆:BAACLAAFFH8IAAIBAAgINgCeWAAFAAABAAgINgCeWAAFAAAsAAQKfxsAAgEACAj/EdklAI4BAAEACAj/EdklAI4BAAAA.',['别急']='别急:BAAALAAECgEIAQAAAA==.',['别打']='别打我投降:BAAALAAECgYIDgAAAA==.',['剑丶']='剑丶仙:BAAALAADCgMIBgAAAA==.',['剑气']='剑气禅心:BAAALAAFFAYIAQAAAA==.',['加州']='加州旅馆:BAAALAAECgMIAwAAAA==.',['勇敢']='勇敢牛:BAAALAADCgMIAwAAAA==.',['勒是']='勒是雾都:BAAALAAECgYIBgAAAA==.',['十二']='十二月老司机:BAAALAAECgYIBgAAAA==.',['千丶']='千丶鹤:BAAALAAECgEIAQAAAA==.',['千小']='千小鹤:BAAALAADCgMIAwAAAA==.',['千岛']='千岛薇:BAAALAAFFAYIAwAAAA==.',['千嶂']='千嶂雪:BAAALAAECgMIAwABLAAFFAYILAATAFgjAA==.',['千羽']='千羽:BAAALAAECgUIBQAAAA==.',['千鶴']='千鶴:BAAALAAECgYIBgAAAA==.',['千鸟']='千鸟流:BAACLAAFFH8mAAIBAAcI8RjIDQDcAQABAAcI8RjIDQDcAQAsAAQKfxkAAgEACAioII4UAPACAAEACAioII4UAPACAAAA.',['午安']='午安小爱:BAAALAAECgUIBQABLAAFFAYIMgAXALUhAA==.',['午時']='午時已到:BAACLAAFFH8uAAIcAAYItg9hEQA7AQAcAAYItg9hEQA7AQAsAAQKfxgAAhwABwh2FwkeAKkBABwABwh2FwkeAKkBAAAA.',['南溟']='南溟:BAABLAAFFH8aAAMWAAUIxBcOBwDOAAADAAQI7Q4PQwDfAAAWAAIIzCQOBwDOAAABLAAFFAYINgAXACQmAA==.',['博丽']='博丽霊梦:BAAALAAECgYIBgAAAA==.',['卡布']='卡布奇诺伯爵:BAAALAAFFAMIAwAAAA==.',['卿先']='卿先生:BAABLAAFFH8GAAIbAAYIfRSxCAAHAgAbAAYIfRSxCAAHAgAAAA==.卿先笙:BAAALAAFFAQIBAAAAA==.',['叁子']='叁子:BAAALAAFFAIIBAAAAA==.',['又是']='又是把飞刀:BAAALAADCgYIBgAAAA==.',['发飙']='发飙的蜗牛丶:BAAALAAECgYICwAAAA==.',['古丹']='古丹丶:BAAALAAFFAMIBAAAAA==.',['叮叮']='叮叮噹噹:BAAALAAECgQIBAAAAA==.叮叮当当:BAAALAADCggIEwAAAA==.',['可乐']='可乐乐:BAAALAADCgEIAQAAAA==.',['右方']='右方之火丶:BAACLAAFFH8oAAMEAAYIyhtRGgCGAQAEAAYIyhtRGgCGAQAZAAEI3QM+DQBDAAAsAAQKfzQAAwQABwixIiUtAJcCAAQABwiKISUtAJcCAAUABggHImElAPgBAAAA.',['名门']='名门黑牛:BAAALAAFFAIIBAAAAA==.',['吖吥']='吖吥:BAAALAAECgYIBgAAAA==.',['吧喀']='吧喀吧喀:BAAALAAECgYIBwAAAA==.',['周末']='周末末:BAAALAAFFAYIBAAAAA==.',['咬人']='咬人小树丶:BAAALAAECgEIAQAAAA==.',['哇哦']='哇哦:BAAALAAECgEIAQAAAA==.',['哦斌']='哦斌:BAAALAAECgYIBgAAAA==.',['唤梦']='唤梦:BAACLAAFFH80AAIdAAcIbCWNAQD1AgAdAAcIbCWNAQD1AgAsAAQKf2oAAx0ACAi9JhoAAJADAB0ACAi9JhoAAJADAB4AAghtDcA0ADYAAAAA.',['唯岳']='唯岳丨凌:BAAALAADCgIIAgAAAA==.',['唯烟']='唯烟懂我心:BAABLAAECn8UAAMOAAgIdBCD0gB/AQAOAAYI4BWD0gB/AQAVAAgIGgBZZQACAAAAAA==.',['啊呜']='啊呜罗拉:BAACLAAFFH8rAAIHAAYIcSYZBgAoAgAHAAYIcSYZBgAoAgAsAAQKfyoAAgcACAhDI7kZAA0DAAcACAhDI7kZAA0DAAAA.',['喜感']='喜感的小小号:BAAALAAECggICAAAAA==.喜感的筱筱号:BAAALAAECgEIAQAAAA==.喜感的筱筱矮:BAAALAAECggICQAAAA==.',['喝奶']='喝奶奶不:BAABLAAECn8UAAIJAAcIVAmsegAOAQAJAAcIVAmsegAOAQAAAA==.',['嗜灬']='嗜灬魔灵:BAAALAAECgYIDQAAAA==.',['噢小']='噢小小德:BAAALAAECgYIBgAAAA==.',['噬魂']='噬魂者图拉糖:BAACLAAFFH8KAAMWAAYIxAzREgBHAAADAAQI7wiORQDHAAAWAAIIbRTREgBHAAAsAAQKfxcAAxYACAjLGtQfAAMCABYABwhRG9QfAAMCAAMABQjKGDmOAGEBAAAA.',['嚣张']='嚣张西西:BAAALAAFFAIIAgAAAA==.',['嚯嚯']='嚯嚯呵呵:BAABLAAECn8UAAIOAAgIAB/tIgDkAgAOAAgIAB/tIgDkAgAAAA==.',['四十']='四十三尾狐:BAAALAAECgYIBgABLAAFFAIICwAIAMglAA==.',['回忆']='回忆全部没收:BAAALAAECgcIEQAAAA==.',['因陀']='因陀罗:BAABLAAECn8fAAIfAAgIBBtxFwA8AgAfAAgIBBtxFwA8AgABLAAFFAYILAAPAMIGAA==.',['圖騰']='圖騰插滿一地:BAAALAADCgYIBwAAAA==.',['坦度']='坦度一般:BAAALAADCggICQAAAA==.',['城市']='城市之光:BAAALAAFFAIIAwAAAA==.',['堕落']='堕落:BAAALAAECgcICwAAAA==.堕落幽灵:BAAALAAECgYIBgAAAA==.',['墨玉']='墨玉臣:BAAALAAECgEIAQAAAA==.',['复仇']='复仇者脸萌:BAABLAAFFH8EAAIXAAIICgc7ZgA7AAAXAAIICgc7ZgA7AAAAAA==.',['夜半']='夜半惊风雨:BAAALAAECgEIAQAAAA==.',['夜风']='夜风之龙:BAABLAAFFH8GAAIFAAIITxEOGgA9AAAFAAIITxEOGgA9AAAAAA==.',['大薯']='大薯条子:BAAALAADCggICAAAAA==.',['天之']='天之哀霜:BAABLAAFFH8VAAITAAYIRRVMNQBtAQATAAYIRRVMNQBtAQAAAA==.',['天人']='天人合一:BAAALAAECgYIBgAAAA==.',['天堂']='天堂就不要你:BAABLAAECn8XAAIFAAYITxw6FACTAQAFAAYITxw6FACTAQAAAA==.',['天晨']='天晨:BAAALAAECggICAAAAA==.',['奥伯']='奥伯莱蒽裂魂:BAAALAAECgYICAAAAA==.',['奧格']='奧格瑞瑪步兵:BAABLAAFFH8IAAIbAAMIcwxBPgB7AAAbAAMIcwxBPgB7AAAAAA==.',['奶乃']='奶乃牛牛:BAABLAAFFH8GAAIQAAIIMRmLJACVAAAQAAIIMRmLJACVAAAAAA==.',['妙了']='妙了:BAAALAAECggICAAAAA==.',['妮咔']='妮咔妮叩:BAAALAAECggICAAAAA==.',['妮诺']='妮诺:BAAALAAFFAIIAgAAAA==.',['姐夫']='姐夫:BAAALAAECggICAAAAA==.',['宝贝']='宝贝赳赳:BAAALAAECggIDQAAAA==.',['宫崎']='宫崎英高:BAAALAAECggIDgAAAA==.',['富清']='富清:BAAALAADCgUIBQAAAA==.',['射射']='射射菌:BAAALAAFFAIIBAAAAA==.',['射鲸']='射鲸者:BAAALAAECggICAAAAA==.',['小吃']='小吃之板栗:BAAALAAFFAIIAgAAAA==.',['小啊']='小啊宸:BAAALAAFFAIIBAAAAA==.',['小妮']='小妮宝:BAAALAAECgEIAQAAAA==.',['小海']='小海洋:BAABLAAFFH8GAAIHAAUIYBSPLQAiAQAHAAUIYBSPLQAiAQAAAA==.',['小火']='小火车丶呜呜:BAAALAAECgUIBQAAAA==.',['小牛']='小牛奶丶:BAAALAADCgYIBgAAAA==.',['小狐']='小狐妮:BAAALAAFFAQIBAAAAA==.小狐狸:BAAALAADCgMIAwAAAA==.',['小白']='小白一个:BAAALAADCggICQAAAA==.',['小的']='小的魔法:BAABLAAFFH8IAAITAAII4Q+IYwCJAAATAAII4Q+IYwCJAAAAAA==.',['小馒']='小馒头:BAAALAAECgUIBQAAAA==.',['小鸡']='小鸡吃魔窟:BAAALAAECgUIDAAAAA==.',['尐仙']='尐仙女吖:BAACLAAFFH8PAAIJAAYIOweiIABKAQAJAAYIOweiIABKAQAsAAQKfxYAAgkABgjCHj8aAPABAAkABgjCHj8aAPABAAAA.',['尼古']='尼古拉斯丷曲:BAAALAAECgMIBAAAAA==.',['屠尽']='屠尽日寇:BAABLAAFFH8gAAIcAAgIVQ71BgDrAQAcAAgIVQ71BgDrAQAAAA==.',['山水']='山水有重逢:BAACLAAFFH8KAAMXAAYIvg8FJwBgAQAXAAYIvg8FJwBgAQAgAAIIbRIhEQBvAAAsAAQKfxUAAxcACAjPHjgxAJcCABcABwh6IDgxAJcCACAACAifD1oqAGQBAAEsAAUUBggsABMAWCMA.',['巨臀']='巨臀尤物:BAAALAAECgYIEQAAAA==.',['差不']='差不多调调:BAAALAAECgYIBgAAAA==.',['巴依']='巴依老爷没钱:BAAALAADCgIIAgAAAA==.',['巴适']='巴适克特波:BAAALAAECgYICQAAAA==.',['帅帅']='帅帅小魔头:BAAALAAECgMIAwAAAA==.帅帅艾象:BAAALAADCgEIAQAAAA==.',['师爷']='师爷包有为:BAAALAAFFAIIAgABLAAFFAIIAgAYAAAAAA==.',['帕秋']='帕秋莉诺雷姬:BAAALAAECgYICwAAAA==.',['帝国']='帝国斟茶兵:BAABLAAFFH8SAAIOAAYIfx+NIgCwAQAOAAYIfx+NIgCwAQAAAA==.',['带三']='带三个表:BAABLAAFFH8nAAIBAAYIjSVhCQAgAgABAAYIjSVhCQAgAgAAAA==.',['年迈']='年迈的德德:BAACLAAFFH8NAAIXAAIILRdmNACjAAAXAAIILRdmNACjAAAsAAQKfxUAAhcACAjMIG8cAPMCABcACAjMIG8cAPMCAAAA.',['幸福']='幸福猎手:BAAALAAFFAIIBAAAAA==.',['广严']='广严寺混子:BAAALAAFFAIIAgAAAA==.',['归归']='归归菌:BAAALAAFFAIIAwAAAA==.',['影逝']='影逝沙漏:BAAALAAECggICAAAAA==.',['徐宝']='徐宝宝:BAAALAAECgYIBgAAAA==.',['徐盼']='徐盼盼:BAABLAAFFH8GAAIcAAYICQAzJQARAAAcAAYICQAzJQARAAAAAA==.',['徐蛮']='徐蛮蛮:BAAALAAECggIBwAAAA==.',['德爷']='德爷:BAAALAAECgYIBgAAAA==.',['德鲁']='德鲁壹壹:BAAALAAECgIIAgAAAA==.',['心中']='心中有猛虎:BAACLAAFFH84AAIbAAcI4R63CAA0AgAbAAcI4R63CAA0AgAsAAQKf0sAAhsACAhmIxsRAB8DABsACAhmIxsRAB8DAAAA.',['心有']='心有丶林夕:BAAALAAECgYIBgAAAA==.',['心未']='心未倦:BAAALAAECgQIBAAAAA==.',['怀念']='怀念:BAAALAAECgIIAgAAAA==.',['恁恁']='恁恁菌:BAAALAAFFAIIAgAAAA==.',['恭喜']='恭喜发财:BAAALAAFFAIIBAAAAA==.',['惊呆']='惊呆小伙伴:BAAALAAECgYIDgAAAA==.',['愁城']='愁城丶:BAAALAADCgIIAgAAAA==.',['愈麒']='愈麒麟:BAABLAAECn8VAAIJAAYIHBiiJgCEAQAJAAYIHBiiJgCEAQAAAA==.',['意兴']='意兴阑珊:BAAALAAECgYICQAAAA==.',['意气']='意气风发:BAABLAAFFH8FAAIaAAMIEAYFFgCkAAAaAAMIEAYFFgCkAAAAAA==.',['愤怒']='愤怒滴香瓜:BAABLAAFFH8pAAIOAAYIBCKrFwDiAQAOAAYIBCKrFwDiAQAAAA==.愤怒的雷利:BAAALAAECgYIBgAAAA==.',['懒猫']='懒猫灰灰:BAAALAAECgYIBgAAAA==.',['我会']='我会魔法:BAABLAAFFH8GAAIFAAYIpgCBIQAoAAAFAAYIpgCBIQAoAAAAAA==.',['我就']='我就是黑暗:BAAALAAECgMIAwAAAA==.',['我快']='我快不行了:BAABLAAFFH8IAAIOAAII3BV5aQCTAAAOAAII3BV5aQCTAAAAAA==.',['我最']='我最乖:BAAALAAFFAIIAgAAAA==.',['我来']='我来你不来:BAAALAAECgIIAgAAAA==.',['我醉']='我醉乖:BAAALAAECgIIAgAAAA==.',['战丶']='战丶小糊涂:BAAALAAECgYIDgAAAA==.',['戰神']='戰神:BAABLAAFFH8GAAIaAAYI3wo1BwCPAQAaAAYI3wo1BwCPAQAAAA==.',['手残']='手残与信仰:BAAALAADCgYIBwAAAA==.',['抛弃']='抛弃温柔:BAAALAAFFAIIAgAAAA==.',['抹茶']='抹茶拿铁:BAAALAAECgYICAAAAA==.',['拾捌']='拾捌:BAAALAADCgcIDQAAAA==.',['振翅']='振翅星辰坠落:BAAALAADCggIFgAAAA==.',['挽弓']='挽弓如月射天:BAAALAADCgcIDAAAAA==.',['捣蛋']='捣蛋西西:BAACLAAFFH8wAAMMAAcIzR37AABEAgAMAAcIzR37AABEAgALAAEISgW9HwA2AAAsAAQKfzIAAwwACAgVJUsCAFsDAAwACAgVJUsCAFsDAAsABAhFGX8WALMAAAAA.',['攞琳']='攞琳莎娜:BAABLAAFFH8MAAMVAAMImBqEDgCiAAAVAAIIFBeEDgCiAAAOAAMImBp9XgCWAAAAAA==.',['救救']='救救我:BAAALAAECgIIAgAAAA==.',['敖蕲']='敖蕲之月:BAABLAAFFH8ZAAITAAYIExXoNABuAQATAAYIExXoNABuAQAAAA==.',['斯维']='斯维因:BAABLAAFFH8YAAIEAAYIzxdBCwAQAgAEAAYIzxdBCwAQAgAAAA==.',['新之']='新之助:BAACLAAFFH8mAAIOAAYI0xdoJgChAQAOAAYI0xdoJgChAQAsAAQKfx0AAg4ACAiDH1kkAN8CAA4ACAiDH1kkAN8CAAAA.',['无形']='无形尽寿:BAAALAAFFAIIBAAAAA==.',['无影']='无影炫酷酷:BAAALAAECgMIAwAAAA==.无影炫酷酷前:BAAALAAECgYIEAAAAA==.无影炫酷酷后:BAABLAAECn8YAAIOAAYIxCDkKgDMAQAOAAYIxCDkKgDMAQAAAA==.无影酷酷:BAAALAAECgcICgAAAA==.',['无罪']='无罪之魂:BAAALAAECgYIBgAAAA==.',['无衶']='无衶笙莜:BAAALAAFFAIIAgAAAA==.',['时代']='时代变了大人:BAAALAAECgYIBgAAAA==.',['时光']='时光瘦了:BAAALAAECgYIBgAAAA==.',['星河']='星河璀璨:BAAALAAECgQIBAAAAA==.',['星辰']='星辰玛利亚:BAAALAAECgIIAgAAAA==.',['春姬']='春姬:BAACLAAFFH8FAAIBAAUI/wB9PgBQAAABAAUI/wB9PgBQAAAsAAQKfyEAAgIACAipCArAAAQBAAIACAipCArAAAQBAAEsAAUUBggsAA8AwgYA.',['晓晓']='晓晓呐:BAAALAAECgUIBQAAAA==.',['晨雨']='晨雨:BAAALAAECgYICAAAAA==.',['暗影']='暗影之锋:BAAALAADCgIIAgAAAA==.',['暴戾']='暴戾野牛:BAAALAADCgEIAQAAAA==.',['暴走']='暴走的水龙头:BAAALAAECgIIAgAAAA==.',['暴风']='暴风怒焰:BAAALAAECgYIBgAAAA==.',['曼森']='曼森:BAAALAAECgYIDgAAAA==.',['曼陀']='曼陀罗:BAAALAAECgYICAAAAA==.',['曾经']='曾经的伱:BAAALAAECgYIBgAAAA==.',['最强']='最强女主播:BAABLAAFFH8GAAITAAYI8wgKSAAyAQATAAYI8wgKSAAyAQAAAA==.',['最狂']='最狂乱:BAABLAAFFH8IAAIbAAIIQgWeXAA7AAAbAAIIQgWeXAA7AAAAAA==.',['月下']='月下御剑:BAABLAAECn8XAAITAAYIaBOdzwBrAQATAAYIaBOdzwBrAQAAAA==.',['月五']='月五君:BAAALAADCgYIBgAAAA==.',['月影']='月影龍族:BAAALAAECgYIEAAAAA==.',['朝映']='朝映夕颜:BAAALAAECgQIBAAAAA==.',['木子']='木子:BAAALAAECgQIBQAAAA==.',['未吱']='未吱:BAAALAAECgUIBQAAAA==.',['朱砂']='朱砂痣:BAAALAAFFAIIAgAAAA==.',['朵唯']='朵唯:BAAALAAECgIIAgAAAA==.',['李志']='李志刚:BAAALAAFFAEIAQAAAA==.',['李西']='李西凡:BAABLAAECn8bAAIIAAgICAVlZQAjAQAIAAgICAVlZQAjAQAAAA==.',['杨狗']='杨狗哇哇叫:BAAALAAECgYIBgAAAA==.',['极乐']='极乐净土:BAAALAAECgIIAgAAAA==.',['枫丶']='枫丶叶:BAACLAAFFH8rAAIXAAYImhkOGgClAQAXAAYImhkOGgClAQAsAAQKfyAAAhcABggYHVpvAOcBABcABggYHVpvAOcBAAAA.',['枫叶']='枫叶随魂:BAAALAAECgUIBQAAAA==.',['枫雨']='枫雨树:BAACLAAFFH8MAAMTAAUI7A7aVgD8AAATAAUIuw7aVgD8AAAUAAEI+gi7NQA+AAAsAAQKfxcABBQACAjqFtNVAGEBABQACAjkDNNVAGEBABMABAj8F0EcAQgBACEABAglEC4aAPgAAAAA.',['柒月']='柒月寒枫:BAAALAAECgYICgAAAA==.柒月寒風:BAAALAAECgYIBgAAAA==.',['柒玥']='柒玥寒堸:BAAALAADCgcIBwAAAA==.柒玥寒楓:BAAALAAECgUIBQAAAA==.',['桂圆']='桂圆八宝:BAACLAAFFH8SAAMBAAII4x8uIACyAAABAAII4x8uIACyAAACAAIIUBQKPwCDAAAsAAQKfy4AAwEACAh6H+YUAO4CAAEACAh6H+YUAO4CAAIABghtHhhYAN0BAAAA.',['梅老']='梅老坎:BAABLAAFFH8GAAIHAAYIawi9KwAsAQAHAAYIawi9KwAsAQAAAA==.',['梅芙']='梅芙:BAAALAAECgYIBwAAAA==.',['梦峀']='梦峀魇:BAABLAAFFH8HAAMMAAUIUg3DDQA4AQAMAAUIUg3DDQA4AQALAAEIWwAKIQAkAAABLAAFFAYIGQATABMVAA==.',['棒棒']='棒棒糖不哭:BAAALAAFFAIIAgAAAA==.',['楓纹']='楓纹:BAAALAAECgIIAgAAAA==.',['樱桃']='樱桃尐丸子丶:BAACLAAFFH8tAAICAAYI6BMiDgBdAQACAAYI6BMiDgBdAQAsAAQKfx8AAgIACAjLIu4NAPgCAAIACAjLIu4NAPgCAAAA.',['樱花']='樱花雪月:BAAALAAECgUIBgAAAA==.',['橙双']='橙双橙对:BAAALAAECggICAAAAA==.',['欧尼']='欧尼酱丶:BAABLAAFFH8LAAIHAAIIqxexQACeAAAHAAIIqxexQACeAAAAAA==.',['止戈']='止戈流:BAAALAAECggICAAAAA==.',['武人']='武人仙风:BAABLAAFFH8RAAIiAAUIHQj/DQAEAQAiAAUIHQj/DQAEAQAAAA==.',['死贫']='死贫道活道友:BAAALAAFFAIIAgAAAA==.',['殇痕']='殇痕放逆:BAABLAAECn8WAAIDAAYIIRglcQCkAQADAAYIIRglcQCkAQAAAA==.',['比屋']='比屋定薩芬娜:BAAALAAECggIBgAAAA==.',['沐有']='沐有奈:BAAALAAECgEIAQAAAA==.',['沙痕']='沙痕幽咽:BAAALAAECgEIAQAAAA==.',['沧澜']='沧澜丶:BAAALAAECgYIBAAAAA==.',['法丶']='法丶小糊涂:BAAALAAECgUIBQAAAA==.',['洋芋']='洋芋丸子丶:BAABLAAFFH8GAAIEAAYIhRTWKgBoAQAEAAYIhRTWKgBoAQAAAA==.',['洪锐']='洪锐刚:BAAALAAECgIIAgAAAA==.',['流落']='流落在外:BAAALAAECgYIBwAAAA==.',['海洋']='海洋二号:BAAALAAECgYIAwAAAA==.',['海风']='海风微微甜:BAAALAAECgQIBAAAAA==.',['清风']='清风抚雨:BAAALAAFFAIIBAAAAA==.',['溅狗']='溅狗哇哇叫:BAAALAADCgcIBwAAAA==.',['漠世']='漠世魔梦:BAABLAAFFH8YAAIdAAcINyV3AQD6AgAdAAcINyV3AQD6AgABLAAFFAcINAAdAGwlAA==.',['潘伟']='潘伟:BAAALAAECgQIBwAAAA==.',['灏灬']='灏灬蛮:BAAALAAECgYICQAAAA==.',['火法']='火法帝:BAAALAAFFAQIBAAAAA==.',['火鹰']='火鹰:BAAALAAECgYICgAAAA==.',['灬云']='灬云姐灬:BAAALAAECggICAAAAA==.',['灬冬']='灬冬至灬:BAAALAAECgYIBgAAAA==.',['灬西']='灬西风灬:BAAALAAECgYICAAAAA==.',['灭队']='灭队发动机:BAAALAAECgMIAwAAAA==.',['灾虐']='灾虐:BAAALAADCgMIAwAAAA==.',['炎妃']='炎妃龙:BAAALAAECgYICQAAAA==.',['烤骨']='烤骨砖家:BAABLAAFFH8XAAMeAAYIdiF8CwBvAQAeAAUI9iF8CwBvAQAdAAEISAmIIAA+AAAAAA==.',['热烈']='热烈的马:BAAALAAECgYIDAAAAA==.',['烽纹']='烽纹:BAAALAAFFAIIBAAAAA==.',['無伈']='無伈戀愛:BAAALAAFFAIIAgAAAA==.',['熊熊']='熊熊不哭:BAAALAAECggICAAAAA==.',['熊猫']='熊猫烧香:BAAALAAFFAIIAgAAAA==.',['熊霸']='熊霸天下:BAACLAAFFH8dAAIcAAUIrQclEwCKAAAcAAUIrQclEwCKAAAsAAQKfyAAAyMACAiYFG4iAO4BACMACAhcFG4iAO4BABwABwg8C4csACsBAAAA.',['燃烧']='燃烧的胸毛:BAAALAAECgUIBgAAAA==.',['爆炸']='爆炸的榴莲:BAABLAAFFH8GAAIXAAYIlArQKQBNAQAXAAYIlArQKQBNAQAAAA==.',['爱上']='爱上孤独:BAABLAAECn8WAAIHAAgIsCExOACTAgAHAAgIsCExOACTAgABLAAFFAgIOgAHAGcgAA==.',['爱做']='爱做梦的小兔:BAAALAAECgIIAgAAAA==.爱做梦的小潴:BAAALAAECgYIBgAAAA==.',['爱尔']='爱尔特璐琪:BAAALAAFFAgIAgAAAA==.',['牛德']='牛德乂逼:BAAALAAECgYIDwAAAA==.牛德花:BAAALAAECgQIBAAAAA==.',['牛毛']='牛毛毛丶:BAAALAADCgcIBwAAAA==.',['牛灬']='牛灬盾:BAAALAAECgYIBgAAAA==.',['牛的']='牛的花:BAAALAAFFAIIAgAAAA==.',['牛肉']='牛肉脏汉:BAABLAAFFH8GAAIbAAUIkxE/DwCdAQAbAAUIkxE/DwCdAQAAAA==.',['牛郎']='牛郎射日:BAAALAADCgIIAgAAAA==.',['狂暴']='狂暴蜗牛:BAABLAAFFH8KAAIQAAMIgxcCKwDIAAAQAAMIgxcCKwDIAAAAAA==.',['狗蛋']='狗蛋兒:BAABLAAFFH8pAAMWAAYIKBklCQC/AAADAAYIKRg9JACOAQAWAAIIlCAlCQC/AAAAAA==.',['猎杀']='猎杀时刻:BAABLAAFFH8FAAITAAMIgwVgPACsAAATAAMIgwVgPACsAAAAAA==.',['猎猫']='猎猫猫人:BAAALAAECgYIBgABLAAECgYIBgAYAAAAAA==.',['猎风']='猎风之影:BAAALAAECgUICQAAAA==.',['猫咪']='猫咪弓爵:BAABLAAFFH8GAAITAAYIggEyxwASAAATAAYIggEyxwASAAAAAA==.',['獸人']='獸人吼吼:BAACLAAFFH8qAAIbAAYICCAIEgDNAQAbAAYICCAIEgDNAQAsAAQKfxkAAhsACAh6GgEsAIsCABsACAh6GgEsAIsCAAAA.',['玉玉']='玉玉与玊玊:BAAALAAECggICAAAAA==.',['玉藻']='玉藻:BAABLAAFFH8GAAIDAAYIcwzgEQDTAQADAAYIcwzgEQDTAQABLAAFFAgIAgAYAAAAAA==.',['王者']='王者:BAAALAAFFAIIBAAAAA==.',['玛丶']='玛丶奥拉基:BAABLAAFFH8YAAIBAAYIHBMFHABlAQABAAYIHBMFHABlAQAAAA==.',['玛洛']='玛洛恩:BAABLAAFFH8GAAIQAAIIaQyXOQBmAAAQAAIIaQyXOQBmAAABLAAFFAIICwACALQJAA==.',['玛莉']='玛莉亚:BAAALAAECgYIBwAAAA==.',['玲奈']='玲奈酱:BAAALAADCgMIAwAAAA==.',['珈蓝']='珈蓝叶:BAAALAAECgQIBAAAAA==.',['珍妮']='珍妮玛丶戴镜:BAAALAAFFAIIAgAAAA==.',['璟小']='璟小宝:BAAALAAECgcIBwAAAA==.',['璟怡']='璟怡铖:BAABLAAFFH8GAAIWAAYIFgThBQDlAAAWAAYIFgThBQDlAAAAAA==.',['瓦兰']='瓦兰奈尔:BAABLAAFFH8GAAIHAAIIXA4PXACDAAAHAAIIXA4PXACDAAAAAA==.',['甚至']='甚至二啊:BAACLAAFFH8/AAIXAAcItSUBAgCVAgAXAAcItSUBAgCVAgAsAAQKfyoAAhcACAjSJSsIAFsDABcACAjSJSsIAFsDAAAA.',['疏一']='疏一:BAAALAAECgYIBgAAAA==.',['疾风']='疾风之瞳:BAAALAADCgMIAwAAAA==.疾风小萨:BAAALAAFFAIIAgAAAA==.疾风骤雨:BAAALAADCggICAAAAA==.',['痛苦']='痛苦还是毁灭:BAAALAAECgQIBAAAAA==.',['白头']='白头:BAAALAAECgYIBwAAAA==.',['白狐']='白狐:BAAALAAECgYIBgAAAA==.',['皂滑']='皂滑弄人:BAAALAAECgYIBgAAAA==.',['盈盈']='盈盈一水间:BAACLAAFFH8yAAIQAAYIiiC/CAAmAgAQAAYIiiC/CAAmAgAsAAQKfyIAAhAACAiBJUAHACgDABAACAiBJUAHACgDAAAA.',['益生']='益生菌:BAAALAAFFAEIAQAAAA==.',['盗版']='盗版丿傻謾:BAABLAAFFH8FAAICAAIIEwSndABGAAACAAIIEwSndABGAAAAAA==.',['真的']='真的栓克油:BAABLAAFFH8IAAIHAAYIYgayQgCcAAAHAAYIYgayQgCcAAABLAAFFAgIHgATADkbAA==.',['眼盲']='眼盲心亮:BAABLAAFFH8GAAIXAAYIYgDUcgAPAAAXAAYIYgDUcgAPAAAAAA==.',['眼角']='眼角的错觉:BAAALAAFFAMIAwAAAA==.',['瞬吸']='瞬吸藍:BAAALAAECgYICQAAAA==.',['石广']='石广泉水:BAAALAAECggICAAAAA==.',['碎花']='碎花使者:BAAALAAFFAIIBAAAAA==.',['磁暴']='磁暴步兵杨某:BAABLAAFFH8GAAMBAAYIyw4IKgD7AAABAAUISQwIKgD7AAACAAEIfxfndQBEAAAAAA==.',['示申']='示申讠舌:BAAALAADCgMIBAAAAA==.',['祐禾']='祐禾:BAAALAAECgYIEQAAAA==.',['祖龙']='祖龙:BAABLAAFFH8MAAIOAAYIQgauSgAUAQAOAAYIQgauSgAUAQAAAA==.',['神域']='神域:BAAALAAFFAQIBAAAAA==.',['神戳']='神戳戳德:BAAALAAECgUIAgAAAA==.',['离丶']='离丶恨天:BAAALAAECgYIBgAAAA==.',['秃头']='秃头丶披风侠:BAAALAAECgYICQAAAA==.',['稀尔']='稀尔瓦娜丝:BAAALAAECgYIBgAAAA==.',['穿件']='穿件衣服吧:BAAALAADCgcIBwAAAA==.',['窈窕']='窈窕淑女:BAABLAAECn8YAAMWAAYIGxIcPQB4AQAWAAYIGxIcPQB4AQADAAEIsgdHCwEtAAAAAA==.',['符文']='符文乱舞:BAAALAAFFAIIBAAAAA==.',['笨笨']='笨笨大王:BAAALAAECgQIBAAAAA==.',['算命']='算命先生:BAAALAAECgYICAAAAA==.',['米尔']='米尔拉:BAABLAAFFH8GAAICAAYIGxmXGQCVAQACAAYIGxmXGQCVAQAAAA==.',['糖醋']='糖醋小丑鱼:BAAALAAECgYIDAAAAA==.糖醋鱼之息:BAAALAAECgEIAQAAAA==.',['红衣']='红衣大主教:BAAALAAFFAIIAgAAAA==.',['纹胸']='纹胸:BAABLAAFFH8FAAIDAAIIHAlsagA3AAADAAIIHAlsagA3AAAAAA==.',['终极']='终极排哥:BAABLAAECn8VAAIHAAYIfSX8HgAkAgAHAAYIfSX8HgAkAgAAAA==.',['继续']='继续颓废:BAACLAAFFH8FAAITAAIIuB27gABbAAATAAIIuB27gABbAAAsAAQKfyAAAxMACAgWIokNALcCABMACAgWIokNALcCABQAAggJDMmoAF8AAAAA.',['绯红']='绯红晨曦:BAABLAAECn8aAAIOAAgI3hJClwDUAQAOAAgI3hJClwDUAQAAAA==.',['网管']='网管:BAAALAAECgMIBAAAAA==.',['羊蹄']='羊蹄翘起来:BAAALAAECgIIAgABLAAECgMIAwAYAAAAAA==.',['美女']='美女爱英雄:BAAALAAECggICAAAAA==.',['翘嘴']='翘嘴巴鱼:BAAALAAECgIIAgAAAA==.',['翘首']='翘首恒寻:BAAALAAECgYIBwAAAA==.',['老四']='老四川牛尾汤:BAAALAAECgQIBAAAAA==.',['耂格']='耂格里:BAAALAAECgUIBQAAAA==.',['肆拾']='肆拾叁:BAAALAAECgYIBwAAAA==.',['肉魔']='肉魔方:BAAALAAECgYIBgAAAA==.',['胖占']='胖占戈士:BAABLAAFFH8GAAIbAAYIlwAeRgCEAAAbAAYIlwAeRgCEAAAAAA==.',['舞月']='舞月:BAAALAADCggICAAAAA==.',['艾斯']='艾斯的梦魇:BAAALAAECggIBwAAAA==.',['苟蛋']='苟蛋:BAAALAAECgMIAwAAAA==.',['荭咝']='荭咝袜:BAAALAAECgYIBgAAAA==.',['莓莓']='莓莓:BAABLAAFFH8HAAITAAQINwZ3ZwCkAAATAAQINwZ3ZwCkAAAAAA==.',['萨你']='萨你全家:BAAALAAECggICAAAAA==.',['萨满']='萨满兰奇:BAAALAAECgUIBQAAAA==.',['萨鲁']='萨鲁法尔:BAAALAAECgYIDwAAAA==.',['蒜苗']='蒜苗儿丶:BAAALAAECgMIBAAAAA==.',['蓝柠']='蓝柠:BAAALAADCgQIBAAAAA==.',['蘑菇']='蘑菇蛋蛋:BAAALAAECgYIBgAAAA==.',['虚伪']='虚伪灬永恒:BAABLAAFFH8KAAMDAAYIvBZHLgBlAQADAAYIyxVHLgBlAQAWAAIInRnzEABLAAAAAA==.',['虛無']='虛無中的舞者:BAACLAAFFH8yAAIIAAYI7xbgDACRAQAIAAYI7xbgDACRAQAsAAQKfzAAAggACAhwGeEeAHsCAAgACAhwGeEeAHsCAAAA.',['蛋嫂']='蛋嫂:BAAALAADCgYIBgAAAA==.',['蜜雪']='蜜雪很奶茶:BAAALAAECggIDgAAAA==.',['蝶舞']='蝶舞菱紗:BAABLAAFFH8GAAICAAYIkgRXMgDmAAACAAYIkgRXMgDmAAAAAA==.',['血戦']='血戦天下:BAAALAAECgEIAQAAAA==.',['裂蘑']='裂蘑人:BAAALAAECgQIBAAAAA==.',['西瓜']='西瓜棉花糖:BAAALAAECgYICQAAAA==.',['讀唱']='讀唱情歌:BAAALAAECggICwAAAA==.',['讨嫌']='讨嫌:BAAALAAFFAIIAwAAAA==.',['许我']='许我春朝:BAABLAAFFH8GAAIBAAYIWgJFLgDOAAABAAYIWgJFLgDOAAAAAA==.',['调停']='调停:BAAALAADCggICAAAAA==.',['谢小']='谢小炮:BAAALAAECgQIBAAAAA==.',['賊神']='賊神:BAACLAAFFH8MAAILAAIIqhR7EQCVAAALAAIIqhR7EQCVAAAsAAQKfzcAAgsACAglHhYLAI4CAAsACAglHhYLAI4CAAAA.',['贝勒']='贝勒里恩丶:BAABLAAFFH8GAAQkAAQIVgebCwCdAAAkAAIIBwqbCwCdAAAeAAIIpQQIJQAsAAAdAAEIkACvHQApAAAAAA==.',['贰拾']='贰拾叁:BAAALAAECgYIBgAAAA==.',['贴身']='贴身搂抱:BAAALAAECggIDgAAAA==.',['贼婆']='贼婆娘:BAAALAAECgYICwAAAA==.',['赞达']='赞达拉祭司:BAAALAAECgUIBwAAAA==.',['跳来']='跳来跳去:BAAALAAECgYICQAAAA==.',['迦南']='迦南灬夢:BAAALAAECgEIAQAAAA==.',['迪门']='迪门修斯:BAABLAAFFH8UAAIJAAYIHiHNCwAVAgAJAAYIHiHNCwAVAgAAAA==.',['逆马']='逆马不艾逆蝶:BAAALAAECgIIAgAAAA==.',['逍遥']='逍遥不无聊:BAAALAAECgYIDAAAAA==.逍遥小苹果:BAAALAAFFAIIAgAAAA==.',['遛六']='遛六遛:BAAALAAFFAIIAgAAAA==.',['那就']='那就叫小猎八:BAABLAAFFH8OAAITAAUIdhmqSAAwAQATAAUIdhmqSAAwAQABLAAFFAYIFAAOAIEfAA==.',['那我']='那我问你丶丶:BAABLAAFFH8IAAIQAAIIkhkbLQB8AAAQAAIIkhkbLQB8AAABLAAFFAIIEgABAOMfAA==.',['那是']='那是青藏高原:BAAALAADCgIIAgAAAA==.',['邪冰']='邪冰血:BAABLAAFFH8GAAIPAAYIvRRXCwBeAQAPAAYIvRRXCwBeAQABLAAFFAgIAQAYAAAAAA==.',['钢铁']='钢铁灬加鲁鲁:BAAALAAECgQIBAAAAA==.',['铁血']='铁血灬游龍:BAABLAAFFH8IAAIHAAIIdB+hMQCqAAAHAAIIdB+hMQCqAAAAAA==.',['镜雨']='镜雨:BAACLAAFFH8yAAIOAAYIYRBNLwDeAAAOAAYIYRBNLwDeAAAsAAQKfyoAAg4ACAj6F4B8AAACAA4ACAj6F4B8AAACAAAA.',['长泽']='长泽雅美:BAABLAAFFH8SAAIDAAMI3w56LQDOAAADAAMI3w56LQDOAAAAAA==.',['闪电']='闪电五连鞭丶:BAAALAAECgYIDAAAAA==.',['阴影']='阴影之光明:BAAALAAECggICAAAAA==.',['陈风']='陈风暴相机:BAABLAAFFH8IAAIbAAII6RGnMwCbAAAbAAII6RGnMwCbAAAAAA==.',['随风']='随风小法:BAAALAAECgYIEQAAAA==.',['雨丶']='雨丶君临:BAABLAAFFH8KAAIjAAgIOQ8FAwAFAgAjAAgIOQ8FAwAFAgAAAA==.雨丶启文:BAABLAAFFH8GAAIMAAII9w8kGgCXAAAMAAII9w8kGgCXAAAAAA==.雨丶旧时意:BAABLAAFFH8TAAIEAAgILBd9CgBCAgAEAAgILBd9CgBCAgAAAA==.雨丶泪:BAABLAAFFH8OAAITAAgIqRlxDwAVAgATAAgIqRlxDwAVAgAAAA==.雨丶耀扬:BAAALAAFFAIIBAAAAA==.雨丶辞镜:BAABLAAFFH8OAAMJAAgIyQ5yIwAsAQAJAAYI0g1yIwAsAQAIAAIIkheLHAC4AAAAAA==.',['雨泪']='雨泪:BAABLAAFFH8QAAIDAAgIeSOHBQCuAgADAAgIeSOHBQCuAgAAAA==.雨泪丶:BAABLAAFFH8SAAMRAAgIaRKXCgC+AQARAAcIJROXCgC+AQAQAAUIEg+vIgANAQAAAA==.',['雨瞳']='雨瞳:BAABLAAFFH8OAAITAAgIsRyvCgBCAgATAAgIsRyvCgBCAgAAAA==.',['雨苏']='雨苏:BAAALAAFFAYIBAAAAA==.',['雨落']='雨落如昔:BAABLAAFFH8KAAMPAAgIkxxHAgB2AgAPAAgIkxxHAgB2AgAOAAIIbQ6ingA4AAAAAA==.',['雪怜']='雪怜儿:BAAALAAECgYIEwAAAA==.',['雪落']='雪落人间:BAABLAAFFH8IAAIEAAIIuB2TOgCmAAAEAAIIuB2TOgCmAAAAAA==.',['雷声']='雷声普化天尊:BAAALAAECggICAAAAA==.',['雷霆']='雷霆法王:BAAALAAFFAIIAgAAAA==.',['震蛋']='震蛋打鸡:BAAALAAECgYIBgAAAA==.',['霸气']='霸气外泄:BAAALAAECgYICwAAAA==.',['颖儿']='颖儿么么哒:BAAALAAECgMIAwAAAA==.',['风扑']='风扑扑:BAACLAAFFH8yAAIXAAYItSHIEQDZAQAXAAYItSHIEQDZAQAsAAQKfyEAAhcACAjcHrUrAK4CABcACAjcHrUrAK4CAAAA.',['风纹']='风纹:BAAALAAFFAMIAwAAAA==.',['风英']='风英:BAABLAAFFH8JAAIfAAMIwQuKEgBiAAAfAAMIwQuKEgBiAAAAAA==.',['飒飒']='飒飒:BAAALAAFFAIIBAAAAA==.',['飞奔']='飞奔的蜗牛:BAAALAAFFAEIAQAAAA==.',['馥蕾']='馥蕾雪:BAABLAAFFH8GAAIQAAIILQV6VABOAAAQAAIILQV6VABOAAAAAA==.',['马老']='马老板之怒:BAAALAAFFAIIAwABLAAFFAcIDgAbAPoQAA==.',['骄傲']='骄傲的小火车:BAAALAAECgYIBgAAAA==.',['高老']='高老板之丶:BAAALAAECggIEAAAAA==.高老板之癫:BAAALAAECggIEAABLAAFFAcIIQAMABEfAA==.',['魅影']='魅影王者:BAAALAAECgYIBgAAAA==.魅影随风:BAAALAAECggIEAAAAA==.',['魍魉']='魍魉丑丑:BAAALAAECgYICAAAAA==.',['魔力']='魔力猫咪:BAAALAAECgYIBgAAAA==.魔力猫猫:BAAALAADCgQIBAABLAAECgYIBgAYAAAAAA==.',['鱼传']='鱼传尺素:BAAALAAFFAIIBAAAAA==.',['鱼摆']='鱼摆摆丶:BAABLAAFFH8MAAMJAAIIbRzpKACZAAAJAAIIbRzpKACZAAAIAAEIUAfiMAA0AAABLAAFFAIIEgABAOMfAA==.',['鲤鯉']='鲤鯉媛上草:BAABLAAFFH8FAAITAAMILgLacAB+AAATAAMILgLacAB+AAAAAA==.',['鲤鲤']='鲤鲤媛上草:BAAALAAECggIBgAAAA==.',['鳯纹']='鳯纹:BAAALAAFFAIIAgAAAA==.',['鹰眼']='鹰眼:BAAALAAECgYIBgAAAA==.',['黑将']='黑将:BAABLAAFFH8GAAIiAAIImwyDFAB8AAAiAAIImwyDFAB8AAAAAA==.',['黑暗']='黑暗使者牛頭:BAAALAAECgYIBwAAAA==.',['黧黑']='黧黑牧言:BAAALAAECgYIEQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end