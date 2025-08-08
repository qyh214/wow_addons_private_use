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
 local lookup = {'Evoker-Devastation','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Druid-Balance','Priest-Holy','Priest-Discipline','Hunter-Marksmanship','Hunter-BeastMastery','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Arms','Warrior-Fury','Paladin-Protection','Paladin-Holy','Paladin-Retribution','Druid-Restoration','Mage-Arcane','DemonHunter-Havoc','Mage-Frost','Monk-Mistweaver','Monk-Brewmaster','Mage-Fire','Evoker-Preservation','Shaman-Restoration','Monk-Windwalker','Rogue-Assassination','Shaman-Elemental','DemonHunter-Vengeance','Priest-Shadow','Warrior-Protection','Druid-Guardian','DeathKnight-Frost','Shaman-Enhancement',}; local provider = {region='CN',realm='哈卡',name='CN',type='weekly',zone=42,date='2025-08-08',data={As='Ashkandi:BAABKgAFFH8IAAIBAAgIzQV8CwCHAQABAAgIzQV8CwCHAQAAAA==.',Au='Au:BAABKgAFFH8PAAQCAAYIVx9vAgC0AQACAAUIRB9vAgC0AQADAAQIyB3NCwDVAAAEAAEIAABcJAAAAAAAAA==.Autoback:BAAAKgAFFAYIAQABKgAFFAgIFgAFAN8iAA==.Autocad:BAACKgAFFH8QAAMGAAgIISMoAQCVAgAGAAgIISMoAQCVAgAHAAIIFSHsCgDEAAAqAAQKfxcAAgYACAg2HRERAD8CAAYACAg2HRERAD8CAAEqAAUUCAgWAAUA3yIA.Autodesk:BAAAKgAFFAQIBAABKgAFFAgIFgAFAN8iAA==.',Co='Cocobaby:BAAAKgADCgEIAQAAAA==.',Cr='Cross:BAAAKgAECgIIAgAAAA==.',Da='Darkseid:BAAAKgAFFAgIBAAAAA==.',De='Desolater:BAAAKgAECgYIBgAAAA==.Devilish:BAAAKgAECgUIBQAAAA==.',Dr='Dracarys:BAAAKgADCgIIAwAAAA==.Dragonstar:BAAAKgADCggICAAAAA==.',Et='Eto:BAAAKgAECgEIAQAAAA==.',Ha='Halcyon:BAAAKgADCgMIAwAAAA==.',Il='Illustrator:BAACKgAFFH8MAAMIAAQIEBVzMQCqAAAIAAQIEBVzMQCqAAAJAAIIqxJXIACgAAAqAAQKfxcAAwkACAjeHkoiADICAAkACAh+HUoiADICAAgABwisHVs3AFABAAEqAAUUCAgEAAoAAAAA.',In='Install:BAAAKgADCggICAAAAA==.',La='Labubu:BAAAKgAFFAQIBAABKgAFFAgIEwAGAMsVAA==.Lastslayer:BAAAKgAFFAQIBAAAAA==.',Lo='Lori:BAABKgAECn8aAAIJAAgI0h61JAAlAgAJAAgI0h61JAAlAgAAAA==.',Ma='Malphas:BAAAKgAECggICQAAAA==.Maya:BAABKgAECn8YAAILAAgIPB5NLAAEAgALAAgIPB5NLAAEAgABKgAFFAgIFgAFAN8iAA==.',Me='Mediocreman:BAABKgAFFH8TAAMLAAgILR3JAgCjAgALAAgILR3JAgCjAgAMAAEIkAdGMgA8AAAAAA==.Melia:BAAAKgAFFAQIBAAAAA==.',Mo='Monte:BAABKgAFFH8YAAMNAAYIqxm4BgCtAQANAAYIqxm4BgCtAQAOAAQInQkwFQDfAAABKgAFFAgIBgAOABcZAA==.',Na='Nagedk:BAAAKgADCgMIAwAAAA==.',Ni='Nightfall:BAAAKgAFFAgIBAAAAA==.',No='Nocastting:BAAAKgAECgcIBwAAAA==.',Ol='Oldwan:BAAAKgADCgEIAQAAAA==.',Pa='Paradisekiss:BAAAKgAECgQIBAAAAA==.',Qw='Qwert:BAACKgAFFH8OAAMPAAYI7R7lBgCtAQAPAAYI7R7lBgCtAQAQAAQIHR19BAACAQAqAAQKfxcAAxAACAjJIsQEAKICABAACAjJIsQEAKICABEAAghtDd8QAVoAAAEqAAUUCAgoABEAjxkA.',Ra='Raúl:BAAAKgAECggICAAAAA==.',Re='Reallichee:BAAAKgADCgcIBwAAAA==.',Ru='Ruigo:BAABKgAFFH8HAAQDAAYItg9PEgCUAAADAAIIahlPEgCUAAACAAQIPgnoOQCIAAAEAAEIAAD1IgAAAAAAAA==.',Sa='Sangels:BAAAKgADCggICAAAAA==.',Sk='Sketchup:BAABKgAFFH8WAAMFAAgI3yKEBACEAgAFAAgI3yKEBACEAgASAAQIKCT9DQAxAQAAAA==.',So='Soulreaper:BAABKgAFFH8FAAITAAUItxzpEABiAQATAAUItxzpEABiAQABKgAFFAgIBgATALAdAA==.',St='Stephentrial:BAAAKgAECggIDgAAAA==.',Sx='Sxdtlw:BAACKgAFFH8WAAIIAAUImQrINACgAAAIAAUImQrINACgAAAqAAQKfzkAAwgACAhIGekjALoBAAgACAhIGekjALoBAAkAAQjMDb4KASoAAAAA.',To='Toys:BAABKgAFFH8GAAIRAAYI2g5fFABYAQARAAYI2g5fFABYAQAAAA==.',Tr='Triniity:BAAAKgAECgcIBwAAAA==.',Ul='Ultrasdalian:BAAAKgAFFAQIBAABKgAFFAYIAgAKAAAAAA==.',Un='Unscarred:BAAAKgAECgcIDgAAAA==.',Up='Upup:BAAAKgAECgEIAQAAAA==.',Va='Vayan:BAAAKgAECgUIBQAAAA==.',Zp='Zpr:BAABKgAECn8YAAMGAAgIfh7hDgBcAgAGAAgIqx3hDgBcAgAHAAgIcBdqHgDVAQAAAA==.',['一筒']='一筒:BAAAKgAFFAQIBAAAAA==.',['一美']='一美美一:BAAAKgAECgYICAAAAA==.',['一闪']='一闪靓一:BAACKgAFFH8kAAIPAAYI/Q+KDQCbAAAPAAYI/Q+KDQCbAAAqAAQKf0YAAg8ACAhcFyAbAIgBAA8ACAhcFyAbAIgBAAAA.',['七千']='七千一个:BAAAKgAECggICAAAAA==.',['万事']='万事不求人:BAAAKgAECgcIBwAAAA==.',['万亿']='万亿天:BAAAKgAFFAEIAQAAAA==.',['三山']='三山有杏:BAAAKgAECgUIBQAAAA==.',['三德']='三德子:BAAAKgAFFAMIAwAAAA==.',['且听']='且听风吟丶:BAAAKgADCgEIAQAAAA==.',['丘离']='丘离:BAAAKgAECgMICAAAAA==.',['东方']='东方小小妖:BAAAKgADCgcIBwAAAA==.',['丨潇']='丨潇湘夜雨丨:BAAAKgAFFAQIBAAAAA==.',['丨逐']='丨逐星丨丨:BAAAKgAECggIEQABKgAFFAMIEAAIAPobAA==.',['丶丶']='丶丶逐星丶:BAAAKgAFFAQIAgABKgAFFAMIEAAIAPobAA==.',['丶慌']='丶慌了丨:BAAAKgADCgQIBAAAAA==.',['丶浩']='丶浩瀚泗海丶:BAAAKgAECgUIBQAAAA==.',['丷珊']='丷珊珊酱丷:BAAAKgAECggICAAAAA==.',['丿晓']='丿晓星尘:BAAAKgAFFAEIAQAAAA==.',['乄丷']='乄丷漂白丶:BAAAKgAECgEIAQAAAA==.',['乙巳']='乙巳元宵节:BAAAKgAECgYIBgAAAA==.乙巳嘀咳骑士:BAAAKgADCgQIBAAAAA==.',['五十']='五十六:BAAAKgAECggICAAAAA==.',['亡魂']='亡魂者:BAAAKgADCgIIAgAAAA==.',['以前']='以前没得选:BAAAKgADCggICAAAAA==.',['以梦']='以梦梦为马:BAAAKgAECgEIAQAAAA==.',['伊琳']='伊琳娜:BAAAKgAECgQIBAAAAA==.',['伊瑞']='伊瑞尔:BAAAKgADCgEIAgAAAA==.',['优雅']='优雅铁憨憨:BAACKgAFFH8JAAIOAAMIIxTMGwDlAAAOAAMIIxTMGwDlAAAqAAQKfygAAg4ACAjLHV4RAFMCAA4ACAjLHV4RAFMCAAAA.',['你迷']='你迷路了么:BAAAKgAECgYIBgAAAA==.',['侠之']='侠之大者:BAAAKgAECgMIAwAAAA==.',['元宝']='元宝老爹:BAABKgAFFH8KAAIRAAgIYQy9NwAMAQARAAgIYQy9NwAMAQAAAA==.',['光启']='光启:BAAAKgAECgMIAwAAAA==.',['兔爷']='兔爷兒:BAABKgAFFH8KAAIUAAYINA8jGgDcAAAUAAYINA8jGgDcAAAAAA==.',['兔酱']='兔酱:BAACKgAFFH8JAAMJAAQIIyNxGgAsAQAJAAQIIyNxGgAsAQAIAAIIDg3ZHACIAAAqAAQKfxcAAggABwjnGzsmAKsBAAgABwjnGzsmAKsBAAAA.',['六六']='六六陆:BAAAKgAECgIIAgAAAA==.',['冰激']='冰激凌奶茶:BAACKgAFFH8FAAIVAAMITxIDFQDCAAAVAAMITxIDFQDCAAAqAAQKfyYAAhUACAg8IIkKAI8CABUACAg8IIkKAI8CAAAA.',['冰释']='冰释前嫌:BAABKgAFFH8IAAIOAAgInxaYBQAgAgAOAAgInxaYBQAgAgAAAA==.',['决战']='决战牧:BAABKgAFFH8IAAMHAAMI5xVnGADOAAAHAAMI5xVnGADOAAAGAAEIHABeRAAHAAABKgAFFAgIBAAKAAAAAA==.',['冷萃']='冷萃冰爽椰:BAAAKgAECgUIBQAAAA==.',['凌霄']='凌霄:BAABKgAFFH8IAAMWAAQIIBDREQDdAAAWAAQIIBDREQDdAAAXAAQI1A8SBQChAAAAAA==.',['初吻']='初吻給了奶嘴:BAAAKgAFFAgIBAAAAA==.',['别西']='别西卜:BAAAKgAECgUICAAAAA==.',['别跑']='别跑小哥哥:BAAAKgAECgEIAQAAAA==.',['刮刮']='刮刮乐:BAAAKgAECgYIBgAAAA==.',['剑在']='剑在人在丶:BAAAKgADCgEIAQAAAA==.',['化身']='化身巨熊:BAABKgAFFH8PAAMFAAYIixznEACYAQAFAAYIixznEACYAQASAAIImxrqIACmAAAAAA==.',['千變']='千變万化:BAAAKgAECgUIBQAAAA==.',['卖饼']='卖饼的阿花:BAACKgAFFH8FAAIYAAMIjRZcGQDqAAAYAAMIjRZcGQDqAAAqAAQKfzAAAxgACAg+I9kWAGsCABgACAg+I9kWAGsCABUAAwjOE12HAIEAAAAA.',['南山']='南山落梅花:BAAAKgAECgIIAgAAAA==.',['去有']='去有风的地方:BAAAKgADCggICQAAAA==.',['变身']='变身小萝莉:BAAAKgADCggICAAAAA==.',['史莱']='史莱克:BAAAKgADCggICAAAAA==.',['名门']='名门:BAAAKgAECgYIEQAAAA==.',['听风']='听风逝夜:BAABKgAFFH8LAAMPAAYIMRUUCwBHAQAPAAYIMRUUCwBHAQARAAMIbgPiOQB1AAAAAA==.',['吴丶']='吴丶精酿啤酒:BAABKgAFFH8FAAIWAAUItRPbIQCbAAAWAAUItRPbIQCbAAAAAA==.',['吴小']='吴小锤:BAAAKgAECggICAAAAA==.',['吴火']='吴火球:BAAAKgAECggICAAAAA==.',['周次']='周次元:BAAAKgAECgMIAwAAAA==.',['咕什']='咕什么咕:BAAAKgAFFAgIBAAAAA==.',['咕咕']='咕咕哒丶:BAAAKgAECgIIAgAAAA==.',['哇不']='哇不哇塞:BAAAKgAECgEIAQAAAA==.',['哈哈']='哈哈酱:BAAAKgAECgIIAgABKgAECgQIBAAKAAAAAA==.',['唉你']='唉你欠骂:BAABKgAFFH8UAAMBAAgIKR22DACYAQABAAcIqBy2DACYAQAZAAQI3hxMAwDpAAAAAA==.',['啾啾']='啾啾嘚啾:BAAAKgADCggICAAAAA==.',['喵薄']='喵薄荷:BAAAKgAFFAEIAQAAAA==.',['嗜血']='嗜血回忆:BAAAKgADCgcIBwABKgAFFAgIBgALAIIjAA==.',['嘤嘤']='嘤嘤子:BAAAKgAFFAQIBAAAAA==.',['嘻哈']='嘻哈人生:BAAAKgAECgEIAQAAAA==.',['土萨']='土萨:BAAAKgADCggICAAAAA==.',['圣光']='圣光喜乐安康:BAAAKgADCgYIBgAAAA==.',['地狱']='地狱战火:BAAAKgAECgcICgAAAA==.',['坎萨']='坎萨斯丶暗星:BAAAKgAECgQIBAAAAA==.',['坚如']='坚如磐石:BAABKgAFFH8IAAIaAAMIsRlqQwB4AAAaAAMIsRlqQwB4AAAAAA==.',['基本']='基本法:BAAAKgAECggIDQAAAA==.',['塑料']='塑料娃娃:BAACKgAFFH8WAAQRAAYILxeuFwAtAQARAAUIXRuuFwAtAQAQAAQIywmGDACQAAAPAAEIdgYJFgAtAAAqAAQKfxcABBEACAidHDGnAEkBABEABwi4IDGnAEkBABAAAwjVB+xPAEIAAA8AAwjTAopWACsAAAAA.',['墙外']='墙外等小歪歪:BAABKgAFFH8GAAIJAAYI8AwBGgAvAQAJAAYI8AwBGgAvAQAAAA==.',['墨咏']='墨咏:BAAAKgAECgYICgAAAA==.墨咏咏:BAAAKgAECgUIBQAAAA==.',['墨與']='墨與言:BAABKgAECn8eAAIWAAgIqRfJNAB3AQAWAAgIqRfJNAB3AQAAAA==.',['夏木']='夏木:BAAAKgADCgIIAgAAAA==.',['夏箩']='夏箩儿:BAAAKgAECgEIAQAAAA==.',['夜行']='夜行:BAAAKgAECgEIAQAAAA==.',['大帝']='大帝累了:BAABKgAECn8UAAIBAAgIHhz/FgAKAgABAAgIHhz/FgAKAgAAAA==.大帝雷德:BAACKgAFFH8JAAIbAAMIDQ+RDQDPAAAbAAMIDQ+RDQDPAAAqAAQKfyQAAhsACAg2II0iAMoBABsACAg2II0iAMoBAAAA.',['大彪']='大彪哥哥啊:BAAAKgAFFAQIBAAAAA==.',['大米']='大米职业选手:BAAAKgAFFAgIBAAAAA==.',['天使']='天使献祭之厅:BAABKgAFFH8SAAIEAAQIog7lCAC6AAAEAAQIog7lCAC6AAAAAA==.',['失落']='失落伊甸园:BAACKgAFFH8MAAMNAAMIJhqoDgCnAAANAAIIuBmoDgCnAAAOAAIIaxajHACkAAAqAAQKfyQAAw0ACAjbIhURADECAA0ABwgIIhURADECAA4ACAhYF24zALQBAAAA.',['好友']='好友根:BAAAKgAECgYIDQAAAA==.',['如龙']='如龙:BAAAKgAECgMIAwAAAA==.',['妖精']='妖精一九尾:BAAAKgADCggIHAAAAA==.',['姬伯']='姬伯昌:BAABKgAFFH8IAAIcAAgI9REVBwAKAgAcAAgI9REVBwAKAgAAAA==.',['姬狐']='姬狐丨娇爃:BAAAKgADCgEIAQABKgAFFAQIDAAFAPwIAA==.姬狐丨庇韄:BAACKgAFFH8MAAIFAAQI/AgoHwC/AAAFAAQI/AgoHwC/AAAqAAQKfxwAAgUACAiGFRQ/ALoBAAUACAiGFRQ/ALoBAAAA.姬狐丨怜悯:BAAAKgAFFAIIAgABKgAFFAQIDAAFAPwIAA==.姬狐丨智慧:BAAAKgADCggICAAAAA==.',['娃儿']='娃儿十九岁:BAABKgAECn8cAAIJAAgI8AnwdgDzAAAJAAgI8AnwdgDzAAAAAA==.',['婷婷']='婷婷中宝宝:BAAAKgADCgEIAQAAAA==.婷婷小宝宝:BAAAKgADCgEIAQAAAA==.',['嫣然']='嫣然梦璃:BAAAKgADCggICAAAAA==.',['子非']='子非术:BAABKgAFFH8MAAQEAAQIFQzXEAC3AAAEAAMIvgvXEAC3AAADAAII2Ae+CwCHAAACAAMICQuQIQB3AAAAAA==.',['孤浪']='孤浪大魔王:BAACKgAFFH8IAAILAAMIWQtcFgC0AAALAAMIWQtcFgC0AAAqAAQKfzoAAgsACAjJGs4oABUCAAsACAjJGs4oABUCAAAA.',['宇智']='宇智坡佐助:BAAAKgADCggICAAAAA==.',['寂寞']='寂寞的海洋:BAAAKgAECgEIAQAAAA==.寂寞的独行者:BAABKgAECn8gAAIRAAgILyGtFwCoAgARAAgILyGtFwCoAgAAAA==.',['寒烟']='寒烟拓跋野:BAABKgAFFH8GAAINAAYI5RHxCAB7AQANAAYI5RHxCAB7AQAAAA==.',['对丶']='对丶我叫乔:BAABKgAFFH8FAAIUAAUITAK9JwDXAAAUAAUITAK9JwDXAAAAAA==.',['小城']='小城大事:BAAAKgAECggICAAAAA==.',['小奶']='小奶龙:BAAAKgADCggICAAAAA==.',['小明']='小明和春娇:BAAAKgADCgEIAQAAAA==.',['小桃']='小桃红:BAACKgAFFH8IAAIdAAMItQ6YGAC0AAAdAAMItQ6YGAC0AAAqAAQKfzEAAh0ACAgiHvoFAGMCAB0ACAgiHvoFAGMCAAAA.',['小椰']='小椰奶:BAAAKgAFFAQIAgAAAA==.小椰子:BAAAKgAFFAUIAwAAAA==.',['小猎']='小猎卡卡:BAAAKgADCgQIBwAAAA==.',['小的']='小的們给我上:BAAAKgAECgcICwAAAA==.',['小红']='小红帽快来:BAABKgAECn8bAAMEAAgISSGeBQCYAgAEAAcIDCGeBQCYAgACAAYI4hm1XwDvAAAAAA==.',['小萨']='小萨卡卡:BAAAKgADCgEIAQAAAA==.',['岛了']='岛了半铁盒:BAAAKgAFFAIIAgAAAA==.',['差点']='差点没死成:BAAAKgADCgcIBwAAAA==.',['布吉']='布吉盗:BAAAKgAECgcIEwAAAA==.',['布德']='布德鸟:BAAAKgAECgcIBwAAAA==.',['帆婷']='帆婷淇宝宝:BAACKgAFFH8jAAIUAAYIERHwHwAEAQAUAAYIERHwHwAEAQAqAAQKf0sAAhQACAgzHvMsAP4BABQACAgzHvMsAP4BAAAA.',['帆帆']='帆帆大宝宝:BAAAKgADCgEIAQAAAA==.',['希尔']='希尔瓦娜思:BAABKgAECn8kAAIJAAgIxxtEJwAXAgAJAAgIxxtEJwAXAgAAAA==.',['帝神']='帝神牛:BAAAKgADCggICwAAAA==.',['幸福']='幸福小次狼:BAAAKgADCgYICgAAAA==.',['开心']='开心鱼腩煲:BAABKgAFFH8MAAILAAYI8hdDEgCHAQALAAYI8hdDEgCHAQAAAA==.',['弈剑']='弈剑听风雨:BAAAKgADCgQIBAAAAA==.',['弘农']='弘农猎:BAAAKgAECgIIAgAAAA==.',['归来']='归来仍是战神:BAAAKgAFFAgIBAAAAA==.',['归远']='归远:BAAAKgAECgYICAAAAA==.',['後發']='後發:BAABKgAFFH8IAAILAAgIBQhaCAC6AQALAAgIBQhaCAC6AQAAAA==.',['微光']='微光炼狱骑士:BAAAKgAFFAQIBAAAAA==.',['心里']='心里有术:BAACKgAFFH8FAAICAAMI/gfBMwCgAAACAAMI/gfBMwCgAAAqAAQKfxwAAwIACAgyFGpFAFMBAAIACAgyFGpFAFMBAAQAAgh1BC6CACgAAAAA.',['性感']='性感母蟑螂丶:BAAAKgAECgYIBwAAAA==.',['恶魔']='恶魔奴隶:BAAAKgADCgcIBwAAAA==.恶魔来玩啊:BAAAKgADCgEIAQAAAA==.',['悠悠']='悠悠麦:BAABKgAFFH8GAAIeAAYIegaPBQDkAAAeAAYIegaPBQDkAAAAAA==.',['惩戒']='惩戒骑:BAAAKgADCgEIAQAAAA==.',['慕容']='慕容舞:BAAAKgADCgUIBgAAAA==.慕容舞倾城:BAAAKgADCgIIAgAAAA==.',['我叫']='我叫色牛:BAABKgAFFH8NAAISAAMIJBBhIQCjAAASAAMIJBBhIQCjAAAAAA==.',['我将']='我将点燃星海:BAABKgAFFH8IAAIdAAQIYhuLEgDUAAAdAAQIYhuLEgDUAAAAAA==.',['我开']='我开无敌:BAAAKgADCggIEAAAAA==.',['我是']='我是演员:BAABKgAFFH8MAAQEAAYIyR/BAgBYAQACAAYIyR8TCADjAQAEAAUIUBzBAgBYAQADAAEINghIIQBHAAABKgAFFAgIDQACAMghAA==.',['我有']='我有真奥妙:BAAAKgAFFAgIBAAAAA==.',['我还']='我还能撑住:BAABKgAFFH8GAAMLAAQIkQouPgClAAALAAQIRwouPgClAAAMAAII0gt0LgBXAAAAAA==.',['戒律']='戒律闪电喵:BAABKgAFFH8QAAQHAAYIthstBABVAQAHAAUIoxUtBABVAQAGAAUI1huPFQAIAQAfAAIIwxLfGACcAAAAAA==.',['戦弑']='戦弑:BAABKgAECn8cAAIgAAgISRU7EAC2AQAgAAgISRU7EAC2AQAAAA==.',['戳你']='戳你小脑瓜:BAAAKgADCgYIBgAAAA==.',['手一']='手一挥死一堆:BAAAKgAECgYIBgAAAA==.',['抿著']='抿著小嘴兒:BAAAKgAECgcIBwAAAA==.',['振翅']='振翅第一名:BAABKgAFFH8IAAIFAAQI9xRYLwDWAAAFAAQI9xRYLwDWAAAAAA==.',['捉小']='捉小乌龟:BAAAKgAECgQIBwAAAA==.',['捶斯']='捶斯你丫的:BAAAKgAFFAEIAQAAAA==.',['接着']='接着忽悠:BAAAKgAECgYIBgAAAA==.',['提拉']='提拉米苏:BAAAKgAECgUIBQAAAA==.',['擎川']='擎川:BAAAKgAECgcIBwAAAA==.',['收手']='收手吧丿阿祖:BAACKgAFFH8KAAIFAAQIBgehJQCdAAAFAAQIBgehJQCdAAAqAAQKfxQAAgUACAglFHFAALQBAAUACAglFHFAALQBAAAA.',['放开']='放开那只羊:BAAAKgAECgYIBgAAAA==.',['放羊']='放羊的老狼:BAAAKgAECgcIDwAAAA==.',['敢问']='敢问路在何方:BAAAKgADCgQIBAAAAA==.',['整不']='整不了:BAAAKgAFFAMIAwAAAA==.',['斯内']='斯内克:BAAAKgAFFAIIAgAAAA==.',['斯铭']='斯铭:BAAAKgADCgUIBQAAAA==.',['无惧']='无惧之战:BAAAKgAFFAMIAwAAAA==.',['无扶']='无扶我青云志:BAAAKgAFFAUIAwAAAA==.',['无敌']='无敌小萝莉:BAABKgAECn8UAAIRAAgIdhTcXwDcAQARAAgIdhTcXwDcAQAAAA==.',['旺旺']='旺旺大魔神:BAAAKgAFFAYIAgABKgAECggIFQALALcdAA==.',['昏睡']='昏睡:BAAAKgAFFAYIAgAAAA==.',['星屿']='星屿:BAAAKgAFFAQIBAAAAA==.',['星痕']='星痕:BAABKgAFFH8LAAICAAgI2xQVCgDqAQACAAgI2xQVCgDqAQAAAA==.',['星野']='星野:BAAAKgAECgUIBQAAAA==.',['晓星']='晓星尘:BAACKgAFFH8KAAMSAAQI0RJoHQC6AAASAAQI0RJoHQC6AAAFAAMIlQX4LgBzAAAqAAQKfxQAAgUACAieEu9HAJcBAAUACAieEu9HAJcBAAAA.',['晨血']='晨血丨飓风:BAAAKgADCgEIAQAAAA==.',['暗影']='暗影主宰:BAAAKgAECgIIAwAAAA==.',['月如']='月如一:BAABKgAECn8YAAIJAAgI/BQiOwC4AQAJAAgI/BQiOwC4AQAAAA==.',['月落']='月落丶佛爷:BAAAKgAECgIIAgAAAA==.月落丶冬至:BAABKgAFFH8NAAIJAAYICht8AQDmAQAJAAYICht8AQDmAQAAAA==.月落丶圣堂:BAAAKgAFFAQIBAAAAA==.',['有毛']='有毛猕猴桃:BAABKgAECn8cAAIJAAgIHB7cHwBAAgAJAAgIHB7cHwBAAgAAAA==.',['木木']='木木啊:BAAAKgAECggICAAAAA==.',['木林']='木林:BAAAKgAFFAQIBAABKgAFFAgIFgACAIQaAA==.',['李四']='李四:BAAAKgAFFAQIBAABKgAFFAgIGAADAKAdAA==.',['杖一']='杖一挥骨一堆:BAABKgAFFH8GAAITAAYInQuJFwAoAQATAAYInQuJFwAoAQAAAA==.',['杨二']='杨二正:BAACKgAFFH8kAAIOAAYIShtBDwBhAQAOAAYIShtBDwBhAQAqAAQKf0YAAg4ACAg6I+sLAKcCAA4ACAg6I+sLAKcCAAAA.',['林小']='林小溪:BAABKgAFFH8OAAIHAAYIYBwDCQCMAQAHAAYIYBwDCQCMAQAAAA==.',['林溪']='林溪:BAABKgAFFH8FAAIIAAUIDBxdAgBiAQAIAAUIDBxdAgBiAQAAAA==.',['格兰']='格兰伲:BAAAKgAECgYIBgAAAA==.',['梦中']='梦中梦:BAAAKgADCggICAAAAA==.',['梦境']='梦境回廊:BAABKgAFFH8IAAIWAAMI6hcvGQDVAAAWAAMI6hcvGQDVAAAAAA==.',['欠血']='欠血的骑:BAAAKgAECgUICAAAAA==.',['欢乐']='欢乐天神:BAABKgAFFH8IAAMFAAQIoxt+DgACAQAFAAQIoxt+DgACAQASAAMIDBPAFgCBAAAAAA==.欢乐的宝:BAAAKgADCgQIBQAAAA==.',['欢喜']='欢喜糖糖:BAAAKgAECgcIDAAAAA==.',['欧泡']='欧泡欧泡:BAABKgAFFH8TAAMGAAgIyxXLAwACAgAGAAgIyxXLAwACAgAHAAcIlQz/BQBeAQAAAA==.',['欧皇']='欧皇丶:BAABKgAECn8ZAAMGAAgIsSX0AQDsAgAGAAgIsSX0AQDsAgAfAAII1xfuTQB2AAABKgAFFAgICgAGANkWAA==.',['死亡']='死亡來襲:BAAAKgADCgUIBQAAAA==.',['水绕']='水绕指柔:BAAAKgAECgQIBAAAAA==.',['沉默']='沉默圣光:BAABKgAFFH8GAAIRAAMI9xZ9SgDZAAARAAMI9xZ9SgDZAAAAAA==.沉默的背后:BAAAKgAECggIDAAAAA==.',['沐丿']='沐丿丶肖宇:BAAAKgADCgIIAgAAAA==.',['沙漠']='沙漠萌妹:BAABKgAFFH8LAAIJAAQIHRqCGADvAAAJAAQIHRqCGADvAAAAAA==.',['没有']='没有愛的季節:BAABKgAFFH8KAAIVAAQIsBV7BwDyAAAVAAQIsBV7BwDyAAAAAA==.',['没湿']='没湿找抽:BAABKgAECn8VAAICAAcIkgigVgC7AAACAAcIkgigVgC7AAAAAA==.',['沿着']='沿着光的人:BAAAKgADCgIIAgAAAA==.',['泉麻']='泉麻那:BAAAKgADCgUIBQAAAA==.',['法力']='法力残渣:BAAAKgAECgYICgAAAA==.',['波尔']='波尔霸奔:BAAAKgAECgcIBwAAAA==.',['洺閄']='洺閄灬三刀:BAAAKgAECggICQAAAA==.',['活着']='活着有啥意思:BAAAKgADCgIIAgAAAA==.活着没嘛意思:BAAAKgADCgcICAAAAA==.活着没意思:BAAAKgADCgEIAQAAAA==.活着没意思呢:BAAAKgADCgUIBgAAAA==.活着没意思啊:BAAAKgADCgEIAQAAAA==.活着没有意思:BAAAKgADCgEIAQAAAA==.活着真没意思:BAAAKgADCgEIAwAAAA==.',['浅水']='浅水:BAABKgAFFH8JAAMIAAYIvQ3bFwApAQAIAAYIvQ3bFwApAQAJAAMIFQdmUABqAAAAAA==.',['淇淇']='淇淇大宝宝:BAAAKgADCgMIBAAAAA==.淇淇小宝宝:BAAAKgADCgMIAgAAAA==.',['滅世']='滅世一愉悦:BAAAKgADCggIGQAAAA==.',['潇湘']='潇湘宇:BAAAKgADCggICAAAAA==.',['潜水']='潜水员伊鲁米:BAABKgAFFH8MAAIcAAYIlxgxCQDGAQAcAAYIlxgxCQDGAQAAAA==.',['火柴']='火柴:BAAAKgAECggIBAAAAA==.',['火流']='火流独舞:BAAAKgADCggICAAAAA==.',['火炎']='火炎焱炎火:BAAAKgAECggIEAAAAA==.',['灬孟']='灬孟星魂灬:BAAAKgAECgUIBgAAAA==.',['灬霓']='灬霓裳葳蕤灬:BAAAKgAFFAQIBAAAAA==.',['灭世']='灭世魔眼:BAAAKgAFFAQIBAAAAA==.',['灰色']='灰色郁金香:BAAAKgADCgMIAwAAAA==.',['烟绕']='烟绕指柔:BAAAKgAECgcIDQAAAA==.',['热罗']='热罗尼莫:BAAAKgAECgcIBwAAAA==.',['焚河']='焚河:BAACKgAFFH8SAAIOAAQIXRMVGwCsAAAOAAQIXRMVGwCsAAAqAAQKfx4AAg4ACAj4Ge4lAPgBAA4ACAj4Ge4lAPgBAAAA.',['爱吃']='爱吃小芒果:BAACKgAFFH8LAAMCAAUItA/FGAA+AQACAAUIgA/FGAA+AQAEAAIILAUXHgBrAAAqAAQKfxYAAwQACAjwEQAwADgBAAQACAiKDAAwADgBAAIABAgQFfMeAAgBAAAA.',['爱喝']='爱喝小可乐:BAAAKgAECggICAAAAA==.爱喝小旺仔:BAABKgAFFH8GAAIHAAQIpgUkJACRAAAHAAQIpgUkJACRAAAAAA==.',['牛轉']='牛轉乾坤:BAABKgAFFH8IAAIFAAYI6hDhEABZAQAFAAYI6hDhEABZAQABKgAFFAgIEwAGAMsVAA==.',['牧丶']='牧丶小冷丿咒:BAAAKgADCggICAAAAA==.',['独猎']='独猎:BAAAKgAECggICAAAAA==.',['猎丨']='猎丨魔丨人:BAAAKgAECgUICQAAAA==.',['猪八']='猪八咪:BAABKgAFFH8IAAIOAAgIbQWKCADFAQAOAAgIbQWKCADFAQAAAA==.',['献祭']='献祭天使:BAACKgAFFH8XAAMUAAQI7wg1HQCoAAAUAAQI/wc1HQCoAAAeAAQIqAbMDQB9AAAqAAQKfxUAAx4ACAgnEkksACABAB4ACAiXDUksACABABQAAwjwF8MtAOAAAAAA.',['玉铃']='玉铃铛:BAACKgAFFH8MAAMEAAMIUA9iEAC6AAAEAAMIUA9iEAC6AAACAAMIAwf5HQCVAAAqAAQKfyIAAwQACAgXINQFAJUCAAQACAgXINQFAJUCAAIACAhUFSQ0AD4BAAAA.',['王同']='王同学阿丶:BAABKgAFFH8FAAICAAQIhAjtNgCVAAACAAQIhAjtNgCVAAAAAA==.',['玛德']='玛德法科:BAAAKgAECgYICQAAAA==.',['生之']='生之如舟:BAAAKgAECgEIAQAAAA==.',['生命']='生命收割:BAABKgAFFH8KAAMDAAYImRKoDADPAAACAAYIKQ9TGwArAQADAAQIOheoDADPAAAAAA==.',['田师']='田师傅:BAACKgAFFH8kAAMFAAYIpBBLMQDQAAAFAAUIshFLMQDQAAASAAMIJwrlGAB3AAAqAAQKf0YABAUACAhiHjohAEUCAAUACAhiHjohAEUCABIACAiUFHgiALYBACEAAwiBD7MuAHoAAAAA.',['疯狂']='疯狂小恶鸡:BAABKgAFFH8KAAIRAAQICyKvNQAUAQARAAQICyKvNQAUAQAAAA==.',['白丶']='白丶:BAAAKgAECgIIAgAAAA==.',['白袍']='白袍血小贱:BAAAKgADCgEIAQAAAA==.',['白马']='白马义从:BAAAKgADCggICAAAAA==.',['百医']='百医:BAABKgAFFH8RAAQHAAYIChm0AgCJAQAHAAYI2g+0AgCJAQAGAAMIfxv0HADYAAAfAAQIrg/WGwCkAAABKgAFFAgIEwACADQUAA==.',['盗亦']='盗亦有刀:BAAAKgAECgYICQAAAA==.',['真理']='真理所在:BAACKgAFFH8NAAIVAAMIFxyVDgDvAAAVAAMIFxyVDgDvAAAqAAQKfxQAAhUACAgiHxkYAD8CABUACAgiHxkYAD8CAAAA.',['砍斯']='砍斯伲丫的:BAAAKgAECgQIBAAAAA==.',['破坏']='破坏猪猪侠:BAAAKgADCgIIAgAAAA==.',['硬梆']='硬梆梆的我:BAACKgAFFH8dAAILAAgIYiT/AwB2AgALAAgIYiT/AwB2AgAqAAQKfzcAAgsACAi4JmABABUDAAsACAi4JmABABUDAAAA.',['碧云']='碧云涛:BAAAKgAECgYIBgAAAA==.',['社会']='社会小哥:BAAAKgAECgMIAwAAAA==.',['祎涵']='祎涵:BAAAKgAECgEIAQAAAA==.',['神小']='神小雨:BAACKgAFFH8LAAMfAAUIwQohHgB5AAAfAAMIKAchHgB5AAAGAAQIsggpGgBvAAAqAAQKfycAAx8ACAjQFS0fANwBAB8ACAjQFS0fANwBAAYACAh/F/soAKgBAAAA.',['神牛']='神牛听我滴:BAAAKgAECgIIAgAAAA==.',['神里']='神里绫华:BAACKgAFFH8FAAIiAAQIzxUECQDbAAAiAAQIzxUECQDbAAAqAAQKfxoAAiIACAheIDIIADgCACIACAheIDIIADgCAAAA.',['穷鬼']='穷鬼盾:BAAAKgADCgMIAwAAAA==.',['等一']='等一个夏天:BAAAKgADCggICAAAAA==.',['等风']='等风的云:BAAAKgAECgIIAgAAAA==.',['米兰']='米兰小铁匠:BAAAKgADCggICAAAAA==.',['米盖']='米盖尔:BAAAKgAECgQIBAAAAA==.',['精灵']='精灵布丁:BAABKgAFFH8OAAMCAAYIRRq+FABeAQACAAYIRRq+FABeAQADAAQIyQvhCwDMAAAAAA==.',['終不']='終不似少年遊:BAABKgAFFH8FAAIMAAUI7h93CwBaAQAMAAUI7h93CwBaAQAAAA==.',['繁华']='繁华:BAABKgAECn8WAAMSAAgIExnnFwDgAQASAAgIExnnFwDgAQAFAAYIZAV8ogCOAAAAAA==.',['红世']='红世:BAABKgAECn8UAAMCAAcINh1HCgD5AQACAAcIdxxHCgD5AQAEAAYI9hcZDQBpAQAAAA==.',['红旗']='红旗大块:BAAAKgAECggIDQAAAA==.',['红色']='红色萨满:BAABKgAFFH8HAAMaAAYIZRE7HgADAQAaAAUIThE7HgADAQAdAAEI9g4XJgBGAAAAAA==.',['红豆']='红豆泥:BAAAKgADCgIIAgAAAA==.',['纪伯']='纪伯张:BAAAKgAECgIIAgAAAA==.',['绝对']='绝对零度:BAAAKgAFFAQIBAAAAA==.',['维什']='维什戴尔:BAAAKgAECgQIBAAAAA==.',['罗大']='罗大佑丶:BAAAKgAECgYIAwAAAA==.',['美术']='美术老师:BAAAKgAECgEIAQAAAA==.',['老牛']='老牛拉小车:BAAAKgADCgcIBwAAAA==.',['老董']='老董:BAABKgAFFH8SAAIUAAYIHiauAAA5AgAUAAYIHiauAAA5AgAAAA==.',['肆海']='肆海凉生欢:BAACKgAFFH8OAAMJAAMIPRZILADVAAAJAAMIPRZILADVAAAIAAIIWwboJgBCAAAqAAQKfxsAAwkACAjAHN49AK4BAAkACAgEG949AK4BAAgABQjKGZcjAPsAAAAA.',['背对']='背对天堂:BAAAKgADCgMIAwAAAA==.',['胖熊']='胖熊:BAAAKgAECgYIBgAAAA==.',['舍瓦']='舍瓦:BAAAKgADCgMIAwAAAA==.',['芣嬞']='芣嬞卻娤狠嬞:BAAAKgAECgEIAQAAAA==.',['花谢']='花谢亦会开:BAAAKgADCggICQAAAA==.',['苍冥']='苍冥孤心:BAABKgAFFH8MAAICAAYIGBNYFwBIAQACAAYIGBNYFwBIAQABKgAFFAgICgACAD4WAA==.',['英雄']='英雄所见略同:BAAAKgADCgQIBAAAAA==.',['荒野']='荒野之息:BAABKgAFFH8KAAIIAAYImQ+eFQA3AQAIAAYImQ+eFQA3AQAAAA==.',['莐醉']='莐醉:BAAAKgADCggICAAAAA==.',['莫德']='莫德雷德:BAAAKgADCgcIBwAAAA==.',['萤宝']='萤宝:BAABKgAFFH8GAAIaAAYImgXeEQDsAAAaAAYImgXeEQDsAAAAAA==.',['萨斯']='萨斯避雷:BAABKgAFFH8YAAMdAAgIixomBADbAQAdAAcIixomBADbAQAaAAYIwhHEDwBZAQAAAA==.',['董老']='董老师:BAAAKgAECggICAAAAA==.',['蓝巧']='蓝巧蓝莓慕斯:BAAAKgAECgMIAQABKgAFFAgIDwAjAC4bAA==.',['虎年']='虎年萨满:BAAAKgAECgQIBAAAAA==.',['虎皮']='虎皮鹦鹉:BAACKgAFFH8IAAIRAAgINRnVBgBbAgARAAgINRnVBgBbAgAqAAQKfx8AAxEACAivJQEMAOkCABEACAivJQEMAOkCAA8AAQjzAYVjAAQAAAAA.',['虚空']='虚空主宰:BAABKgAFFH8IAAMfAAgIBQW2CgAmAQAfAAcIDQW2CgAmAQAHAAEIxAL7FQA7AAAAAA==.虚空行者:BAAAKgAECgYIBgAAAA==.',['蟹不']='蟹不二:BAABKgAFFH8IAAMEAAQIkgJPEABoAAAEAAQIkgJPEABoAAACAAIIZQAVVQAQAAAAAA==.',['血月']='血月狂人:BAAAKgAECgUICAAAAA==.',['血狼']='血狼:BAABKgAFFH8GAAIeAAYIaxBcAQBJAQAeAAYIaxBcAQBJAQAAAA==.',['血色']='血色残锋:BAABKgAFFH8MAAMRAAYInRiANwANAQARAAUIOxaANwANAQAQAAEI6iBFEgBpAAAAAA==.',['西瓜']='西瓜很二:BAABKgAFFH8GAAMCAAYIPA/FHgASAQACAAUIrRDFHgASAQAEAAEIdwlTKgBFAAAAAA==.',['诳虚']='诳虚诞:BAAAKgADCgYIBgAAAA==.',['豪玖']='豪玖邀明月:BAACKgAFFH8LAAIbAAMI2AtSFwCvAAAbAAMI2AtSFwCvAAAqAAQKfxkAAhsACAhRG1QXAOwBABsACAhRG1QXAOwBAAAA.',['起门']='起门拉猪:BAAAKgADCggICAAAAA==.',['软绵']='软绵绵的我:BAABKgAECn8RAAIIAAgIhR/4FgAYAgAIAAgIhR/4FgAYAgAAAA==.',['辣个']='辣个武僧:BAAAKgADCgQIBAAAAA==.',['辣神']='辣神:BAABKgAFFH8IAAIRAAQILiNRHgDtAAARAAQILiNRHgDtAAABKgAFFAgIEAAfAFsKAA==.',['达达']='达达黑骑士:BAAAKgAECggIDAAAAA==.',['还是']='还是费电:BAACKgAFFH8RAAMUAAMIYA5EGQDEAAAUAAMIYA5EGQDEAAAeAAMI5wnQGACHAAAqAAQKfyQAAx4ACAhEF5woAD4BAB4ACAiWE5woAD4BABQABghiFhtEADsBAAAA.',['迪波']='迪波威:BAAAKgADCggICAAAAA==.',['迷丶']='迷丶墨墨:BAAAKgAFFAcIBAAAAA==.',['迷雾']='迷雾大师:BAAAKgAECggIDgAAAA==.',['逐星']='逐星猎丶:BAACKgAFFH8QAAIIAAMI+hs+JQDYAAAIAAMI+hs+JQDYAAAqAAQKfxQAAwgACAiIIl8LAIUCAAgACAiRIV8LAIUCAAkABQjuHCSqANEAAAAA.',['邪活']='邪活:BAAAKgAECgQIBAABKgAECgQIBAAKAAAAAA==.',['醉梦']='醉梦卧兰亭:BAAAKgAECggICAAAAA==.醉梦洛丹伦:BAAAKgAFFAEIAQAAAA==.',['里苏']='里苏特:BAAAKgAECgYIBgAAAA==.',['野蛮']='野蛮艺术:BAABKgAFFH8NAAMaAAgIcxNUBQABAgAaAAgIcxNUBQABAgAjAAEIAAA3IAAAAAAAAA==.',['釭凶']='釭凶滴碰碰:BAAAKgAECgIIBAAAAA==.',['鉄胆']='鉄胆火車俠:BAAAKgAECgIIBAAAAA==.',['铁锅']='铁锅炖自己:BAAAKgAFFAgIAgAAAA==.',['铭酱']='铭酱:BAAAKgAECgEIAQAAAA==.',['银月']='银月之傲:BAAAKgAECggIDgAAAA==.',['闪电']='闪电喵变身:BAABKgAFFH8IAAIFAAQIayJnDAANAQAFAAQIayJnDAANAQAAAA==.',['问风']='问风:BAAAKgAFFAQIAgAAAA==.',['闷骚']='闷骚式寂寞:BAAAKgAECgIIAgAAAA==.',['阿丽']='阿丽塔:BAABKgAFFH8HAAILAAQIIBglEQDkAAALAAQIIBglEQDkAAAAAA==.',['阿尔']='阿尔卑斯:BAAAKgAECgYIBwAAAA==.阿尔娜特:BAAAKgAECgYICQAAAA==.阿尔萨斯:BAABKgAFFH8GAAILAAYISQMaEADzAAALAAYISQMaEADzAAAAAA==.',['陌下']='陌下浅眠:BAAAKgAECgEIAQAAAA==.',['随丨']='随丨水寒:BAABKgAFFH8KAAMHAAYICA3zFgCpAAAHAAIILArzFgCpAAAfAAQIOAbLFwCkAAAAAA==.',['随地']='随地大小变:BAAAKgAECgMIAwAAAA==.',['雷丶']='雷丶霆:BAAAKgADCgQIBgAAAA==.',['雷電']='雷電丶萨尓:BAABKgAFFH8GAAIjAAYINAuzCABPAQAjAAYINAuzCABPAQAAAA==.',['雷霆']='雷霆之刃:BAABKgAFFH8IAAMaAAgIlQMNIQD1AAAaAAUIqwMNIQD1AAAdAAMITARpGwCgAAAAAA==.',['霍小']='霍小狐:BAAAKgADCgUIBwAAAA==.',['露娜']='露娜啵鲁鲁:BAAAKgAECggICAAAAA==.',['霸气']='霸气凌天:BAAAKgADCgIIAgAAAA==.',['青鸾']='青鸾:BAAAKgAECgYIEgAAAA==.',['顺德']='顺德者昌:BAABKgAFFH8IAAIFAAMIswW/RACbAAAFAAMIswW/RACbAAAAAA==.',['领着']='领着白菜逛街:BAAAKgAECggIDgAAAA==.',['风暴']='风暴之主:BAABKgAECn8bAAMaAAgIrhtgHwAZAgAaAAgIrhtgHwAZAgAdAAYIrR8PQwAZAQABKgAFFAgIFgAHAIwTAA==.',['风起']='风起云魂:BAAAKgAECgQICAAAAA==.',['风雷']='风雷丿惢惢:BAABKgAFFH8GAAQCAAQIZSMHEACQAQACAAQIZSMHEACQAQAEAAEI6Rb7JgBLAAADAAEIFAkUIQBHAAAAAA==.',['马洛']='马洛洛:BAAAKgAFFAEIAgAAAA==.',['魔鬼']='魔鬼客星:BAABKgAFFH8RAAMOAAQIkxVWDwD9AAAOAAQIkxVWDwD9AAAgAAMIcAUBEQB1AAAAAA==.',['鲜血']='鲜血之翼:BAAAKgAECggIEAAAAA==.',['鹅鹅']='鹅鹅饿:BAAAKgAECgEIAQAAAA==.',['鹏程']='鹏程无限:BAAAKgAECgUIBQAAAA==.',['黄瓜']='黄瓜也疯狂:BAAAKgADCgIIAgAAAA==.',['黑皇']='黑皇后:BAAAKgAFFAgIBAAAAA==.',['黑色']='黑色的郁金香:BAAAKgADCgYICAAAAA==.',['龙二']='龙二:BAABKgAFFH8OAAMBAAYIIhdQAwCFAQABAAYIIhdQAwCFAQAZAAQIXRCXBADKAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end