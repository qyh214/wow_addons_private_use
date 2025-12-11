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
 local lookup = {'Shaman-Elemental','Shaman-Restoration','DeathKnight-Frost','Paladin-Retribution','Druid-Restoration','DemonHunter-Vengeance','DemonHunter-Havoc','Warrior-Fury','Mage-Arcane','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','Paladin-Holy','Hunter-Survival','Priest-Holy','Druid-Guardian','Druid-Balance','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Protection','Warlock-Affliction','Priest-Shadow','Evoker-Preservation','Evoker-Devastation','Paladin-Protection','Evoker-Augmentation','Priest-Discipline','Mage-Frost','Warrior-Arms','Monk-Mistweaver','Druid-Feral','Rogue-Assassination','Rogue-Subtlety','Monk-Windwalker','Monk-Brewmaster',}; local provider = {region='CN',realm='卡德罗斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Ace:BAAALAAECgYIDAAAAA==.',Ap='Apollo:BAAALAADCgIIAgAAAA==.',Ar='Ariana:BAACLAAFFH8LAAIBAAIItA4bSAA/AAABAAIItA4bSAA/AAAsAAQKfxQAAwEABwh/CZd0AGEBAAEABwh/CZd0AGEBAAIABgg8CgzgANAAAAAA.Aries:BAAALAAECgYIBgAAAA==.Armist:BAAALAAECgYICQAAAA==.',As='Astronomia:BAAALAAECgEIAQABLAAFFAMIEAADAPUeAA==.Asura:BAAALAAECgIIBAAAAA==.',Au='Automata:BAABLAAFFH8QAAIDAAMI9R6iKQDzAAADAAMI9R6iKQDzAAAAAA==.',Bl='Blueliu:BAAALAAECgMIAwAAAA==.',Bo='Boxter:BAACLAAFFH83AAIEAAcIgiOSAwBgAgAEAAcIgiOSAwBgAgAsAAQKfygAAgQACAiFJRoQADsDAAQACAiFJRoQADsDAAAA.',Cr='Cruelknight:BAAALAAECgcICwAAAA==.',Di='Dianna:BAAALAAFFAIIAgAAAA==.Divus:BAAALAAECgMIAwAAAA==.',Dr='Dreambreaker:BAABLAAFFH8SAAIEAAMIbBRqIADQAAAEAAMIbBRqIADQAAAAAA==.',En='Enthusiastic:BAAALAAECgYIBgAAAA==.Envy:BAAALAAECgYICQAAAA==.',Er='Erde:BAAALAAECgYIBwAAAA==.',Eu='Eustoma:BAAALAAECgYIBwAAAA==.',Fr='Frigg:BAAALAAECgYIEAAAAA==.',Ft='Fto:BAAALAAFFAUIAgAAAA==.',Ge='Gestapo:BAAALAAECgYIBgAAAA==.',Gy='Gyshentt:BAAALAAECggIBwAAAA==.',Hi='Hillr:BAAALAAECgYIBgAAAA==.',Ho='Hope:BAAALAAECgYIBgAAAA==.',Jo='Joker:BAAALAAECgYIBwAAAA==.',Ka='Kallen:BAAALAAECgYIEQAAAA==.',Ko='Komoechan:BAAALAAFFAEIAQAAAA==.',Kr='Kriccookie:BAABLAAFFH8FAAIFAAQINwADYwADAAAFAAQINwADYwADAAAAAA==.',La='Lancer:BAAALAAECgYIBgAAAA==.',Le='Leftism:BAAALAAECgUICAAAAA==.',Lo='Lotte:BAAALAADCggICQAAAA==.',Me='Mevius:BAAALAAFFAEIAQAAAA==.',Mi='Miku:BAAALAAFFAQIBAAAAA==.Miyo:BAABLAAFFH8QAAMGAAMInBbaBwC+AAAGAAMIMxbaBwC+AAAHAAIIkA0PYABuAAAAAA==.',Mo='Morkvarg:BAAALAAECgYIBgAAAA==.',Ne='Neuropathys:BAAALAAFFAIIBAAAAA==.',Nt='Ntr:BAABLAAFFH8aAAIIAAYIPBqABwAcAgAIAAYIPBqABwAcAgAAAA==.',Pl='Playergpfesv:BAAALAAECgQICgAAAA==.Pleasebugmen:BAAALAAECgEIAQAAAA==.',Pr='Prisdh:BAAALAAECggICwAAAA==.Priss:BAACLAAFFH8NAAIJAAMIrh5/IwAMAQAJAAMIrh5/IwAMAQAsAAQKfykAAgkACAjvJWAHAFQDAAkACAjvJWAHAFQDAAEsAAUUCAgEAAoAAAAA.',Pu='Punainen:BAAALAAECgcICwAAAA==.',Ro='Rootasa:BAAALAAECgMIBAAAAA==.',Sa='Sakamata:BAABLAAFFH8KAAMLAAYIWRo5AwAPAgALAAYIWRo5AwAPAgAMAAQIWxnAFwBSAQAAAA==.',Sk='Skycrystal:BAAALAAFFAIIAgAAAA==.Skysmooth:BAAALAAECgQIBAAAAA==.Skythunder:BAAALAAFFAIIBAAAAA==.Skywatert:BAAALAAECgYICgAAAA==.',Ss='Ssrpeach:BAAALAAECgQIBAAAAA==.',Su='Sunne:BAACLAAFFH8KAAIDAAMIhhC3LADmAAADAAMIhhC3LADmAAAsAAQKfyEAAgMACAi3FbdwABUCAAMACAi3FbdwABUCAAAA.',Th='Thoridal:BAABLAAFFH8LAAIMAAMI9A51fQBdAAAMAAMI9A51fQBdAAAAAA==.',To='Touchmebaby:BAABLAAFFH8IAAINAAIIzg2NRQCRAAANAAIIzg2NRQCRAAAAAA==.',Tr='Trissmeri:BAABLAAFFH8QAAMNAAIIihE0QwCUAAANAAIIihE0QwCUAAAOAAEI1xY3JgBSAAAAAA==.',Uz='Uzi:BAABLAAFFH8WAAIEAAYIECAIAwBHAgAEAAYIECAIAwBHAgAAAA==.',Ve='Vermelho:BAAALAAECgcIEQAAAA==.',Vi='Vigo:BAAALAAFFAIIBAAAAA==.',Wo='Wowmen:BAAALAAECgMIAwAAAA==.',Ya='Yangccpal:BAABLAAECn8lAAMPAAgIchiMGQBBAgAPAAgIchiMGQBBAgAEAAEIiwHpnQEOAAAAAA==.',Yu='Yukihunter:BAAALAAECgYIBgAAAA==.',Ze='Zeus:BAAALAAECgIIAgAAAA==.',Zo='Zodiac:BAAALAAECgYIBgAAAA==.',['一只']='一只狗古德佰:BAABLAAECn8hAAQMAAYI6SAQTgCpAQAMAAYIvh8QTgCpAQALAAUIFxp4VABlAQAQAAYIcRDAFQBPAQAAAA==.一只狗古德白:BAAALAAECgYIEgAAAA==.',['万兽']='万兽之缰:BAAALAAFFAIIBAAAAA==.',['万念']='万念俱灰:BAAALAAECgMIAwAAAA==.',['上帝']='上帝親閨女:BAAALAAECgYIBgAAAA==.',['下水']='下水道万人迷:BAAALAADCgQIBAAAAA==.',['不玩']='不玩歪歪:BAABLAAECn8UAAIFAAYIPRY+NQBNAQAFAAYIPRY+NQBNAQAAAA==.不玩贴吧:BAACLAAFFH8XAAIMAAUIjhstQwA8AQAMAAUIjhstQwA8AQAsAAQKfyIAAgwACAghH/MrAAkCAAwACAghH/MrAAkCAAAA.',['东东']='东东家的猫儿:BAAALAAECgYIDAAAAA==.',['丝西']='丝西娜:BAABLAAFFH8YAAIRAAYI6CAJBwDoAQARAAYI6CAJBwDoAQAAAA==.',['丨蛋']='丨蛋蛋:BAACLAAFFH8GAAMSAAIIWhZUCwBAAAASAAIIWhZUCwBAAAAFAAIIPAKhXgAuAAAsAAQKfxUABBIACAhRFjIMAHQBABIABggdGjIMAHQBAAUACAhaC5k7AC4BABMAAgg5B19bAEkAAAAA.',['丶不']='丶不会:BAABLAAFFH8GAAMDAAMIZCCjHwAlAQADAAMIZCCjHwAlAQAUAAEI3xtyGgBYAAABLAAFFAYIFwAEAIQVAA==.丶不炫燿:BAAALAAFFAYIAQAAAA==.丶不炫耀:BAABLAAFFH8XAAIEAAYIhBWWBQAOAgAEAAYIhBWWBQAOAgAAAA==.',['丶杺']='丶杺殇:BAAALAAECgIIAgAAAA==.',['丶肉']='丶肉蛋:BAACLAAFFH8GAAMDAAIIHwjWhwCBAAADAAII9QXWhwCBAAAVAAIIXQf/HAAtAAAsAAQKfxYAAgMACAhVF3pZAEMCAAMACAhVF3pZAEMCAAAA.',['丶蛋']='丶蛋卷:BAABLAAFFH8GAAIGAAIIXhJ/EwA0AAAGAAIIXhJ/EwA0AAAAAA==.',['丶鸽']='丶鸽子蛋:BAACLAAFFH8HAAIWAAII5QfPKgBnAAAWAAII5QfPKgBnAAAsAAQKfxsAAxYACAidGasbAFUCABYACAidGasbAFUCAAgABgi4Cpy/APwAAAAA.',['丽莎']='丽莎:BAAALAADCgUIBQAAAA==.',['丿初']='丿初丶一:BAABLAAECn8YAAQNAAcI+RsjggB7AQANAAUIVxsjggB7AQAXAAMIVQ0qJwCvAAAOAAMI7BsUJQCrAAAAAA==.',['丿灬']='丿灬滿滿:BAABLAAECn8cAAIBAAcICR/wJACQAQABAAcICR/wJACQAQAAAA==.',['丿神']='丿神之灬守护:BAAALAAECgYIDAAAAA==.',['么么']='么么小狐狸:BAABLAAFFH8MAAMDAAUI/xDjKAD1AAADAAQILhXjKAD1AAAUAAEIQACYFwAnAAABLAAFFAYIGwARAJMcAA==.么么小神骑:BAACLAAFFH8iAAMEAAYI0CNLCwDqAQAEAAYI0CNLCwDqAQAPAAMImhbEHQCNAAAsAAQKfxcAAgQABggVJf1BAHYCAAQABggVJf1BAHYCAAAA.么么小纯牛:BAAALAADCgEIAQABLAAFFAIIAgAKAAAAAA==.',['乌青']='乌青筠:BAABLAAFFH8TAAIEAAUIDhVaKAA4AQAEAAUIDhVaKAA4AQAAAA==.',['九幺']='九幺幺:BAAALAAECgQIBAAAAA==.',['九月']='九月九:BAAALAAECgYIBgAAAA==.',['云游']='云游只去青楼:BAAALAAECgMIBgAAAA==.',['五块']='五块钱的悲催:BAAALAAECgIIAQAAAA==.',['亡之']='亡之舞:BAABLAAFFH8GAAIDAAIIWA7FgwCEAAADAAIIWA7FgwCEAAAAAA==.',['人品']='人品王:BAABLAAFFH8JAAIIAAMIug4cPQB5AAAIAAMIug4cPQB5AAAAAA==.',['人间']='人间正道:BAAALAADCggICAAAAA==.',['仁剑']='仁剑仁爱:BAABLAAFFH8PAAIEAAUIaheGJgBDAQAEAAUIaheGJgBDAQAAAA==.',['仁箭']='仁箭仁爱:BAABLAAFFH8lAAIMAAYINh25HwCzAQAMAAYINh25HwCzAQAAAA==.',['以德']='以德服仁:BAABLAAFFH8KAAIFAAIINglTTQBYAAAFAAIINglTTQBYAAAAAA==.',['仨达']='仨达:BAAALAAFFAIIBAAAAA==.',['任逍']='任逍遥:BAAALAAECggICAAAAA==.',['伊利']='伊利单妮妹:BAAALAAECgMIAwAAAA==.伊利胖子:BAAALAAECgYIBgAAAA==.',['伊芙']='伊芙霖:BAAALAAECggIEAAAAA==.',['你惹']='你惹她干嘛:BAAALAAECgMIAwAAAA==.',['假酒']='假酒:BAAALAAECggICAAAAA==.',['傲视']='傲视部落:BAAALAAECgYICwAAAA==.',['先祖']='先祖:BAAALAAECggICAAAAA==.',['光之']='光之国美少女:BAABLAAFFH8NAAIPAAMILBUZHQC+AAAPAAMILBUZHQC+AAABLAAFFAgICgAIAKoiAA==.',['光头']='光头哥:BAAALAAECgcIBgAAAA==.',['光暗']='光暗娜娜米:BAACLAAFFH8oAAIYAAcIThw5AwBPAgAYAAcIThw5AwBPAgAsAAQKfyMAAhgACAjzI4sEALICABgACAjzI4sEALICAAAA.',['光殇']='光殇:BAACLAAFFH8LAAIPAAMIySIZDAAkAQAPAAMIySIZDAAkAQAsAAQKfy8AAw8ACAiLIqgDAOgCAA8ACAiLIqgDAOgCAAQAAQgOFtV8AUEAAAAA.',['光铸']='光铸晨曦:BAAALAAECgUIBQAAAA==.',['克罗']='克罗米尔:BAAALAAECgYIBgAAAA==.',['六月']='六月六:BAAALAAECgYIBgAAAA==.六月起航:BAAALAAECgcIBwAAAA==.',['其实']='其实我没错:BAAALAAECgMIAwAAAA==.',['兽兽']='兽兽的冬天:BAAALAAECgMIAwAAAA==.',['冬天']='冬天的水仙花:BAABLAAFFH8bAAMRAAYIkxz9DwDeAQARAAYIkxz9DwDeAQAYAAQIBgeyHACqAAAAAA==.',['冰娫']='冰娫:BAAALAADCgIIAgAAAA==.',['冰封']='冰封杜蕾丝:BAAALAAECgYIEAAAAA==.冰封第六感:BAACLAAFFH8GAAIFAAII4gsbSwBbAAAFAAII4gsbSwBbAAAsAAQKfxkAAwUACAgmHawNAHYCAAUACAgmHawNAHYCABMABAiWE2s0APAAAAAA.',['冷月']='冷月无极:BAAALAAECggICAABLAAFFAQIBAAKAAAAAA==.',['冻伤']='冻伤的骑士:BAAALAAECggICAAAAA==.',['凤凰']='凤凰翎:BAABLAAFFH8KAAIEAAYI9xiwDwBLAQAEAAYI9xiwDwBLAQAAAA==.',['凤独']='凤独影:BAAALAADCgUIBQAAAA==.',['函聿']='函聿小红手:BAAALAADCgIIAgAAAA==.',['别敷']='别敷衍我行吗:BAAALAAECgYIEgAAAA==.',['制造']='制造浪漫:BAAALAAECgYIEQAAAA==.',['加减']='加减法:BAAALAAECgMIAwAAAA==.',['勿谓']='勿谓言之不预:BAAALAAECgYIAgAAAA==.',['匁殇']='匁殇:BAAALAAECgYIBgAAAA==.',['北北']='北北贝贝:BAABLAAECn8WAAIEAAYIOw7ZjADmAAAEAAYIOw7ZjADmAAAAAA==.',['北城']='北城土地:BAAALAADCgIIAgAAAA==.',['北落']='北落:BAAALAADCgYIBgAAAA==.',['十月']='十月的颖:BAAALAAECgMIAwAAAA==.',['半口']='半口奶酪:BAAALAAFFAIIAgAAAA==.',['单调']='单调木头人:BAABLAAFFH8UAAMRAAMI/CMtEQAwAQARAAMI/CMtEQAwAQAYAAEIixp1KwBOAAAAAA==.',['南巴']='南巴妹:BAAALAAECgYICAAAAA==.',['南风']='南风:BAABLAAFFH8PAAIDAAUIQiCMOABZAQADAAUIQiCMOABZAQAAAA==.',['占有']='占有欲:BAABLAAFFH8IAAIYAAIIlyA4GACvAAAYAAIIlyA4GACvAAAAAA==.',['卯之']='卯之花烈:BAABLAAFFH8GAAINAAYIfAMiPQANAQANAAYIfAMiPQANAQAAAA==.',['厶亡']='厶亡靇烒:BAAALAAECgMIAwAAAA==.',['发型']='发型比较乱:BAAALAAFFAIIAgAAAA==.',['口耐']='口耐的阿三:BAAALAAECgQIBQAAAA==.',['古德']='古德千:BAAALAAECgYIDwAAAA==.古德坑狗:BAAALAAECgYIEQABLAAFFAgIAgAKAAAAAA==.',['只想']='只想变胖:BAABLAAFFH8HAAIDAAIISBT9VwCcAAADAAIISBT9VwCcAAAAAA==.',['可乐']='可乐加冰红茶:BAAALAAECgYIEQAAAA==.',['叶心']='叶心薇:BAABLAAECn8WAAIIAAYImBYZcwCkAQAIAAYImBYZcwCkAQAAAA==.',['吃不']='吃不醉的龙:BAACLAAFFH8dAAMZAAYIawoaDQDTAAAZAAUIFAsaDQDTAAAaAAUIQAXkFQCdAAAsAAQKfx8AAxkACAgiFtoRABUCABkACAgiFtoRABUCABoABwjeD0czAI4BAAAA.',['吃布']='吃布丁的胖丁:BAAALAAECgYIBgAAAA==.',['吃酒']='吃酒天下行:BAAALAAFFAIIAgAAAA==.',['吃酸']='吃酸奶喝西瓜:BAAALAAECggICwAAAA==.',['吃鱼']='吃鱼的果果:BAAALAAFFAIIAgABLAAFFAYIGQACAJwTAA==.',['吉爾']='吉爾伽美什:BAAALAADCggIDgAAAA==.',['味道']='味道牛牛嘚:BAAALAAECgQIBAAAAA==.',['咄咄']='咄咄逼人:BAAALAAECgYICwAAAA==.',['咆哮']='咆哮压迫众生:BAAALAAECggIDwAAAA==.咆哮游侠:BAABLAAFFH8KAAIMAAYIjRYEMQB1AQAMAAYIjRYEMQB1AQAAAA==.咆哮游影:BAAALAAECgUIBgAAAA==.咆哮阿狸:BAAALAAECgUIBwAAAA==.',['咖喱']='咖喱灬辣椒:BAAALAAECgQIBAAAAA==.',['哈七']='哈七搭八:BAAALAAECgYIBgAAAA==.',['啊伊']='啊伊丶:BAAALAADCgUIBQAAAA==.',['啊祖']='啊祖:BAAALAADCgYIBgAAAA==.',['啤啤']='啤啤猎:BAAALAAECgYIDgAAAA==.啤啤龙:BAAALAAECgYIDgAAAA==.',['噻克']='噻克西款爺:BAAALAAFFAIIBAAAAA==.',['圆环']='圆环之理法则:BAAALAAFFAIIAgAAAA==.',['圣光']='圣光娜雫米:BAACLAAFFH8FAAIEAAMIzRCWHgDZAAAEAAMIzRCWHgDZAAAsAAQKfxgAAgQACAgPI4g1AJ0CAAQACAgPI4g1AJ0CAAEsAAUUBwgoABgAThwA.圣光昭昭:BAAALAAFFAcIBAAAAA==.',['圣天']='圣天帝:BAAALAAECgMIAwAAAA==.',['圣洁']='圣洁之贞德:BAAALAAECgYIBgAAAA==.',['圭臬']='圭臬:BAABLAAFFH8HAAIJAAIIzhLdRwCYAAAJAAIIzhLdRwCYAAAAAA==.',['坏蛋']='坏蛋:BAAALAAECgEIAQAAAA==.',['埃欧']='埃欧雷克丶:BAAALAAECgYICAAAAA==.',['塞亚']='塞亚特之星:BAAALAADCgYIBwAAAA==.',['境界']='境界之空:BAACLAAFFH81AAIHAAcITCHoCAA4AgAHAAcITCHoCAA4AgAsAAQKfysAAgcACAi+JIYOADgDAAcACAi+JIYOADgDAAAA.',['壹口']='壹口白桃七:BAAALAAECgUICAAAAA==.',['夜夜']='夜夜殇:BAABLAAECn8jAAIIAAgI5R/gIgC7AgAIAAgI5R/gIgC7AgAAAA==.',['大松']='大松糕:BAABLAAFFH8KAAIbAAIIUyKtDwCbAAAbAAIIUyKtDwCbAAAAAA==.',['大角']='大角鼠鼠:BAAALAAFFAIIAgAAAA==.',['大道']='大道如青天:BAACLAAFFH8IAAIHAAMIexYoHQD2AAAHAAMIexYoHQD2AAAsAAQKfxoAAgcACAgnIjcbAPkCAAcACAgnIjcbAPkCAAAA.',['大魔']='大魔导术:BAAALAAECgIIAwAAAA==.',['大鹫']='大鹫:BAAALAAFFAIIBAAAAA==.',['天意']='天意十六:BAABLAAFFH8UAAMaAAcIIBkiCgB/AQAaAAYIfRoiCgB/AQAcAAEI8RBXDgBSAAAAAA==.',['天煞']='天煞孤星丶明:BAAALAADCgIIAgAAAA==.',['天神']='天神打击:BAAALAAFFAIIBAAAAA==.天神的怒吼:BAAALAAECgYIDAAAAA==.',['天罚']='天罚之雷:BAAALAAFFAEIAQAAAA==.',['头发']='头发刚拉直:BAAALAADCggICgAAAA==.',['套里']='套里都是水:BAAALAAECgcIBwAAAA==.',['奥克']='奥克塔维亚:BAAALAAECgIIAgAAAA==.',['奥扎']='奥扎格蕾:BAAALAAECggIDgAAAA==.',['女人']='女人狼精:BAABLAAFFH8KAAIMAAIIFg2ntAA0AAAMAAIIFg2ntAA0AAAAAA==.',['女神']='女神龙后裔:BAAALAAECgYIBgAAAA==.',['奶牛']='奶牛哥哥:BAABLAAFFH8GAAIMAAYIRBbmMQByAQAMAAYIRBbmMQByAQAAAA==.',['如梦']='如梦似水流年:BAABLAAECn8lAAIEAAgIph3bGABIAgAEAAgIph3bGABIAgAAAA==.',['妖怪']='妖怪之一:BAAALAADCgQIBAAAAA==.妖怪的妖:BAAALAADCgEIAQAAAA==.',['妖还']='妖还是怪:BAAALAADCgMIAwAAAA==.',['姜维']='姜维丨:BAAALAAECggICAAAAA==.',['娜奥']='娜奥美:BAACLAAFFH8aAAMYAAUIRBXVFAArAQAYAAUIRBXVFAArAQAdAAEIXAStBgA3AAAsAAQKfxcAAhgABwgjG5YqACsCABgABwgjG5YqACsCAAAA.',['孤星']='孤星银月:BAAALAADCgYIBgAAAA==.',['孤独']='孤独探戈:BAAALAADCgYIBgAAAA==.',['富贵']='富贵东:BAABLAAECn8dAAICAAgIrxVMVADnAQACAAgIrxVMVADnAQAAAA==.',['射射']='射射兄弟:BAABLAAFFH8dAAMDAAYI5x43DAD5AQADAAYI5x43DAD5AQAUAAEIxgosHgBNAAAAAA==.',['小丶']='小丶纯洁:BAABLAAFFH8fAAIMAAYIPCUcDwARAgAMAAYIPCUcDwARAgAAAA==.',['小姊']='小姊姊呀:BAAALAAFFAIIAgAAAA==.',['小宇']='小宇宙:BAAALAAECggICAAAAA==.',['小小']='小小大懒猫:BAACLAAFFH8iAAIZAAYIzBIsCwCgAQAZAAYIzBIsCwCgAQAsAAQKfxgAAhkACAiBIN8EAPcCABkACAiBIN8EAPcCAAAA.小小旭下士:BAABLAAFFH8GAAIMAAYIKRA4PABSAQAMAAYIKRA4PABSAQAAAA==.',['小帝']='小帝瓜:BAAALAAFFAIIBAAAAA==.',['小曹']='小曹你行不行:BAAALAADCgcIBwAAAA==.',['小月']='小月饼:BAABLAAECn8cAAMJAAgIxRuzIwCXAQAJAAgIexezIwCXAQAeAAIIeh1KQQBSAAAAAA==.',['小猫']='小猫驴儿:BAAALAAECgEIAQAAAA==.',['小球']='小球球:BAAALAAFFAIIAgAAAA==.',['小甜']='小甜筒:BAABLAAECn8XAAICAAYIwBbARwA7AQACAAYIwBbARwA7AQAAAA==.',['小脆']='小脆同学:BAACLAAFFH8RAAIRAAIIfhsUKgCXAAARAAIIfhsUKgCXAAAsAAQKfxsAAhEACAjFFSQbAOQBABEACAjFFSQbAOQBAAAA.',['小辣']='小辣鸡:BAACLAAFFH8HAAMMAAIIGB0WUwCUAAAMAAIIGB0WUwCUAAALAAEI9hKhFgBBAAAsAAQKfxwAAwwABggqJPE9AGwCAAwABggqJPE9AGwCAAsAAQhjFGO4AD4AAAAA.',['小透']='小透明:BAAALAAFFAIIAgAAAA==.',['小野']='小野茶茶:BAAALAAECgMIAwAAAA==.',['小饼']='小饼:BAAALAAFFAIIBAAAAA==.小饼干墩墩:BAAALAAECgEIAQAAAA==.小饼饼:BAAALAAFFAIIAgAAAA==.',['尝试']='尝试切他中路:BAAALAAFFAYIAwAAAA==.',['尴尬']='尴尬个啥:BAAALAAECgYIBgAAAA==.',['尼克']='尼克呢克尼:BAAALAAECggIBAAAAA==.尼克尼克昵:BAAALAAFFAIIAgAAAA==.',['屁儿']='屁儿痛:BAABLAAFFH8NAAMMAAMIfRVALADQAAAMAAMI1BJALADQAAALAAIIdBNyIwCBAAAAAA==.',['屠龙']='屠龙勇士:BAAALAAECggIEAAAAA==.',['峥嵘']='峥嵘岁月:BAAALAAECgYIBgAAAA==.',['左眼']='左眼看到鬼:BAABLAAFFH8GAAINAAIIwAM8bgAxAAANAAIIwAM8bgAxAAAAAA==.',['巨炮']='巨炮蜀黍:BAAALAAFFAIIBAAAAA==.',['巨蟹']='巨蟹座:BAACLAAFFH8MAAIJAAMIwx56JAAGAQAJAAMIwx56JAAGAQAsAAQKfxwAAgkABgg+JfAzAHoCAAkABgg+JfAzAHoCAAAA.',['巫敌']='巫敌小黑牛:BAAALAAECgYIDAAAAA==.',['帅帅']='帅帅:BAAALAADCgYIBgAAAA==.',['平静']='平静的柠檬:BAAALAAECgYIBgAAAA==.',['幻若']='幻若哀恸之魂:BAAALAAFFAEIAQAAAA==.幻若残缺之影:BAAALAAECgYIBgAAAA==.幻若流转之风:BAAALAAECgYIBgAAAA==.幻若消逝之影:BAAALAAECgEIAQAAAA==.',['床头']='床头柜:BAAALAAECgUIBQAAAA==.',['影魂']='影魂小六:BAABLAAFFH8OAAMRAAYIiAF2KgDWAAARAAYIiAF2KgDWAAAYAAIISQCOMQAtAAAAAA==.',['微微']='微微笑一笑:BAAALAAFFAIIAgAAAA==.',['德天']='德天尊:BAAALAAECgIIBAAAAA==.',['德布']='德布莱尼:BAABLAAFFH8FAAICAAII3AJ3agBVAAACAAII3AJ3agBVAAAAAA==.',['忧郁']='忧郁咕:BAABLAAFFH8QAAMDAAUIKxSEJAAJAQADAAQIFRWEJAAJAQAUAAEIhhCSEQBPAAAAAA==.',['快乐']='快乐吃手手:BAACLAAFFH8QAAMCAAMIPAyyKwCsAAACAAMIPAyyKwCsAAABAAIIpwqjSQA+AAAsAAQKfxcAAwIABgh7IHQ+ACMCAAIABgh7IHQ+ACMCAAEABgidFPZpAHwBAAAA.',['急则']='急则疲慌则乱:BAABLAAECn8XAAIEAAYIECLpUgBJAgAEAAYIECLpUgBJAgAAAA==.',['慕凉']='慕凉:BAACLAAFFH8XAAIJAAQIihxVOQABAQAJAAQIihxVOQABAQAsAAQKfx4AAgkABwgvGg0dAMIBAAkABwgvGg0dAMIBAAAA.',['我不']='我不胖吧:BAAALAAFFAIIBAAAAA==.',['我丶']='我丶爱小角:BAAALAADCgMIAwAAAA==.我丶爱莫西干:BAAALAADCggICQAAAA==.',['我忍']='我忍不了:BAAALAAFFAIIAgAAAA==.',['我是']='我是迈剃:BAABLAAFFH8ZAAIIAAYI+xteFwCkAQAIAAYI+xteFwCkAQAAAA==.我是迈特:BAACLAAFFH8QAAIDAAUISBULQgAzAQADAAUISBULQgAzAQAsAAQKfx4AAgMACAgNI6YLAJYCAAMACAgNI6YLAJYCAAAA.我是阿威:BAAALAAECgYIBgAAAA==.',['我最']='我最矮:BAAALAADCgQIBAAAAA==.',['我蔡']='我蔡我有李:BAAALAAECgYIBgAAAA==.',['战德']='战德宝宝:BAAALAADCgQICAAAAA==.',['战念']='战念:BAAALAAECggIEAAAAA==.',['战车']='战车牛牛:BAAALAAECgYIDAAAAA==.',['执念']='执念:BAAALAAECggIEAAAAA==.',['挖矿']='挖矿采药:BAABLAAFFH8HAAIIAAcItxExDAD6AQAIAAcItxExDAD6AQAAAA==.',['接下']='接下来干嘛:BAAALAADCgIIAgAAAA==.',['搁浅']='搁浅丶:BAABLAAFFH8HAAIGAAIIsBmECwCZAAAGAAIIsBmECwCZAAABLAAFFAMIEQADAP0hAA==.搁浅丿:BAAALAAFFAIIAgAAAA==.',['救赎']='救赎与信仰:BAAALAAECgYIDAAAAA==.',['文森']='文森特砖:BAAALAADCgIIAgAAAA==.',['斑尼']='斑尼迪克:BAAALAADCgUIBQAAAA==.',['新一']='新一代开山怪:BAAALAAECgYIDAAAAA==.',['新起']='新起之秀:BAAALAAECgYICwAAAA==.',['旋风']='旋风激光剑:BAACLAAFFH8RAAQIAAMItha3GwDsAAAIAAMItha3GwDsAAAWAAIIswmrJwBvAAAfAAEI8woMCQBEAAAsAAQKfxQABB8ACAjDFOobAD8BAAgABgiQFliBAIQBAB8ABgiMEOobAD8BABYACAhLDHNXACUBAAAA.',['无敌']='无敌猎枭王:BAABLAAFFH8FAAILAAIIkQ4fJQB9AAALAAIIkQ4fJQB9AAAAAA==.',['无极']='无极丶圣光:BAABLAAFFH8PAAIEAAIIfRwpUwBPAAAEAAIIfRwpUwBPAAAAAA==.无极丶明珠:BAAALAAECgYIBgAAAA==.无极丶暗箭:BAABLAAECn8eAAMOAAYIqg8jHQDoAAAOAAQImxEjHQDoAAANAAYICwpMYwDVAAAAAA==.无极丶溅射:BAAALAAFFAIIBAAAAA==.无极丶隐:BAAALAAECgYIBgAAAA==.无极猫妖:BAAALAAECgYIBgAAAA==.',['无聊']='无聊的魔兽:BAAALAADCggICQAAAA==.',['时光']='时光:BAAALAAECgcIDAAAAA==.',['明眸']='明眸靓眼:BAABLAAECn8fAAIHAAgIXBPiKAC3AQAHAAgIXBPiKAC3AQAAAA==.',['春风']='春风:BAAALAAECgIIAgAAAA==.',['是圣']='是圣光啊:BAAALAAFFAIIBAAAAA==.',['是毛']='是毛毛虫呀:BAABLAAECn8yAAIMAAgIgAl1vQDxAAAMAAgIgAl1vQDxAAAAAA==.',['是芥']='是芥末啊:BAABLAAFFH8MAAICAAIIlh5ZMAChAAACAAIIlh5ZMAChAAAAAA==.',['晓丶']='晓丶觉:BAAALAAECgIIAgAAAA==.',['暗绝']='暗绝杀:BAACLAAFFH8GAAIIAAII2QaJRwCBAAAIAAII2QaJRwCBAAAsAAQKfyQAAwgACAgVFT5BAFUBAAgACAglFD5BAFUBABYABghuFCQnABMBAAAA.',['暗香']='暗香销魂:BAAALAADCgYIBgAAAA==.',['暮雾']='暮雾:BAAALAAECgUICgAAAA==.',['最佳']='最佳男友:BAAALAADCggICAAAAA==.',['月城']='月城雪兔:BAAALAAECgYIBwAAAA==.',['月影']='月影舞流莹:BAAALAAECgYIBgAAAA==.',['有猫']='有猫饼:BAACLAAFFH8PAAIFAAIIvA8nRABnAAAFAAIIvA8nRABnAAAsAAQKfyUAAgUACAjnESQlAK4BAAUACAjnESQlAK4BAAAA.',['木叶']='木叶子:BAABLAAECn8UAAIVAAYIKBIpFwAbAQAVAAYIKBIpFwAbAQAAAA==.木叶甜馨:BAACLAAFFH8aAAIOAAYIPxB/AgB2AQAOAAYIPxB/AgB2AQAsAAQKfxUAAg4ACAhTFOQKALQBAA4ACAhTFOQKALQBAAAA.木叶秋晚:BAABLAAFFH8GAAISAAII4xbdCwA8AAASAAII4xbdCwA8AAAAAA==.',['机器']='机器熊猫:BAAALAADCgcIBwAAAA==.',['村里']='村里的希望:BAABLAAFFH8NAAMQAAIIUBeGBQCTAAAQAAIInhGGBQCTAAAMAAIIkhTAkABEAAAAAA==.',['杺殇']='杺殇:BAAALAAECgYIBgAAAA==.',['林桉']='林桉:BAAALAAECgYIBwAAAA==.',['柒小']='柒小雨:BAAALAAECgYICAAAAA==.',['柠檬']='柠檬汽水:BAAALAADCgMIAwAAAA==.',['梦幻']='梦幻之云:BAAALAADCgMIAwAAAA==.',['橘子']='橘子焦糖丶:BAABLAAFFH8JAAIVAAMIdwpqDACuAAAVAAMIdwpqDACuAAAAAA==.',['欧派']='欧派:BAAALAADCgUIBQAAAA==.',['武天']='武天帝:BAAALAAECgYIDAAAAA==.',['歪把']='歪把子机枪:BAAALAAECgEIAQAAAA==.',['死亡']='死亡狐步:BAABLAAFFH8LAAMUAAgIBhD6AwB7AQAUAAYIjQ/6AwB7AQADAAUIqgocMQDXAAAAAA==.',['水里']='水里捞:BAAALAADCgEIAQAAAA==.',['永恒']='永恒地星空:BAABLAAFFH8GAAIDAAYIaBP9XwCOAAADAAYIaBP9XwCOAAAAAA==.永恒的恶魔:BAABLAAFFH8LAAIHAAgI5Rv0NwC3AAAHAAgI5Rv0NwC3AAAAAA==.',['没事']='没事放个电:BAAALAADCgIIAgAAAA==.',['法天']='法天尊:BAAALAAECgQIBAAAAA==.',['洗翠']='洗翠投掷猴:BAABLAAECn8bAAIMAAgI6R7tFgBzAgAMAAgI6R7tFgBzAgAAAA==.',['洗脚']='洗脚神兽:BAAALAAECgUICAAAAA==.',['流星']='流星久久:BAAALAAECgYIBgAAAA==.流星伊利达雷:BAAALAAECgEIAQAAAA==.流星星冰乐:BAAALAAECgYIDAAAAA==.流星雨:BAAALAAFFAQIBAAAAA==.流星飞箭:BAAALAAECgYIBgAAAA==.',['浅柔']='浅柔:BAAALAAECgYICwAAAA==.',['浪里']='浪里个小白:BAAALAADCgYIBgABLAAECgcIDAAKAAAAAA==.',['海底']='海底捞人:BAAALAAECgYIBwAAAA==.',['海潮']='海潮沫:BAABLAAFFH8GAAIJAAIInwxHVACMAAAJAAIInwxHVACMAAABLAAFFAYIGQAgADcOAA==.海潮渊:BAABLAAFFH8LAAIDAAMIRhA3XQCZAAADAAMIRhA3XQCZAAABLAAFFAYIGQAgADcOAA==.海潮溟:BAACLAAFFH8ZAAIgAAYINw5UCAAYAQAgAAYINw5UCAAYAQAsAAQKfxsAAiAACAjVHvoJAMUCACAACAjVHvoJAMUCAAAA.',['淡落']='淡落芬芳:BAAALAAECgYIBgAAAA==.',['深蓝']='深蓝之月:BAAALAADCgIIAgAAAA==.',['溜德']='溜德滑:BAABLAAECn8YAAQFAAYIYhNsOwAvAQAFAAYIYhNsOwAvAQATAAQIhAxHfwDHAAAhAAMI1QjePgCHAAAAAA==.',['漠丶']='漠丶飞雪:BAAALAADCgIIAgAAAA==.',['潇洒']='潇洒天哥:BAAALAAECgYIEgAAAA==.潇洒的天哥:BAAALAAECgYICwAAAA==.',['火鸡']='火鸡味锅巴:BAAALAAECgYICwAAAA==.',['灰毛']='灰毛小红手:BAAALAAECgYIDAAAAA==.',['烈焰']='烈焰暖阳:BAAALAAECgYICQAAAA==.烈焰风行者:BAABLAAECn8ZAAMNAAcIoBchMwB/AQANAAcIoBchMwB/AQAOAAIIThX3gAB4AAAAAA==.',['無关']='無关风月:BAAALAAECgYICQAAAA==.',['無心']='無心问剣:BAAALAADCgYIBwABLAADCggIBwAKAAAAAA==.',['煌晶']='煌晶:BAAALAAECgYICgAAAA==.',['煎鱼']='煎鱼:BAAALAAFFAEIAQAAAA==.',['爱唱']='爱唱歌的贝贝:BAABLAAFFH8cAAMCAAgIDBGxDAB0AQACAAgIDBGxDAB0AQABAAQIxwoPMACuAAAAAA==.',['爱跳']='爱跳舞的晶晶:BAABLAAFFH8GAAIFAAMI9RfqEAD0AAAFAAMI9RfqEAD0AAAAAA==.',['牧天']='牧天尊:BAAALAAECgYIBwAAAA==.',['特斯']='特斯拉:BAAALAAECgYIBwAAAA==.',['特蓝']='特蓝克斯:BAAALAAECgYIDAAAAA==.',['狂晓']='狂晓牙:BAAALAAECggICAAAAA==.',['狐曦']='狐曦曦:BAABLAAFFH8FAAICAAMIIgWPVgBuAAACAAMIIgWPVgBuAAAAAA==.',['狠狠']='狠狠的偷:BAABLAAFFH8RAAMiAAYIWRlUCQCBAQAiAAYIkBRUCQCBAQAjAAIIpBfPDQCbAAAAAA==.',['猎刃']='猎刃风暴:BAABLAAFFH8GAAIMAAYIDArnFAB5AQAMAAYIDArnFAB5AQAAAA==.',['猎天']='猎天尊:BAAALAAECgMIBAAAAA==.',['玉落']='玉落星辰:BAAALAAECgIIAgAAAA==.',['玛格']='玛格汉西罗:BAAALAAECgYIBgAAAA==.',['玩偷']='玩偷袭的:BAAALAAFFAgIBAAAAA==.',['珑尊']='珑尊威德:BAAALAAECgYICgAAAA==.',['琉璃']='琉璃丶烟花:BAAALAADCgQIBAAAAA==.',['琥珀']='琥珀之意志:BAAALAAECgcIBwAAAA==.',['琳娜']='琳娜贝尔:BAABLAAECn8YAAIIAAYIxxfscQCnAQAIAAYIxxfscQCnAQAAAA==.',['瑟琳']='瑟琳娜丨圣焰:BAAALAAECgYIBgAAAA==.',['瓜子']='瓜子壳壳:BAAALAAECgYIBgAAAA==.',['瓦纳']='瓦纳斯旋风:BAAALAAECgUIBQAAAA==.',['瓦那']='瓦那斯:BAAALAAECgIIAgAAAA==.',['用晦']='用晦而明:BAAALAAECgYICAAAAA==.',['甲方']='甲方乙方:BAAALAAECgUIBQAAAA==.',['疑心']='疑心病:BAAALAAFFAIIAgAAAA==.',['疯狂']='疯狂的瓶子:BAAALAAECgIIAwAAAA==.',['痛风']='痛风:BAAALAADCggIBwAAAA==.',['瘦了']='瘦了没错:BAAALAAECgYIDAAAAA==.',['瘦点']='瘦点也很好:BAAALAAECgYIBgAAAA==.',['白菜']='白菜馄饨:BAAALAAECgYIBgAAAA==.',['盗天']='盗天帝:BAAALAAECgYICQAAAA==.',['盲风']='盲风乂怪雨:BAAALAADCgMIAwAAAA==.',['眼儿']='眼儿媚媚:BAAALAAECgUIBQAAAA==.',['祖龙']='祖龙神帝:BAAALAADCgcIBwAAAA==.',['神的']='神的棍棍:BAAALAAECgYIDAAAAA==.神的钢棍:BAAALAAECgYIBgABLAAECgYIDAAKAAAAAA==.',['福殇']='福殇:BAABLAAECn8WAAILAAYI2x0UMwD1AQALAAYI2x0UMwD1AQAAAA==.',['离人']='离人:BAABLAAFFH8GAAIDAAYI6wisPgBAAQADAAYI6wisPgBAAQAAAA==.',['离弦']='离弦之殇:BAABLAAECn8XAAIMAAYIZhVheQBTAQAMAAYIZhVheQBTAQAAAA==.',['秋初']='秋初看鈤落:BAAALAAECgYIBgAAAA==.',['秦梦']='秦梦瑶:BAAALAADCgEIAQAAAA==.',['稳重']='稳重的死骑:BAAALAAFFAIIAgAAAA==.',['端木']='端木樱:BAAALAADCgIIAgAAAA==.',['筱筱']='筱筱:BAAALAAFFAIIAgAAAA==.',['箭雨']='箭雨前夕:BAAALAAECgIIAgAAAA==.',['米兰']='米兰小暗号:BAAALAAECggIDQAAAA==.',['精灵']='精灵莱尼:BAAALAAFFAIIBAAAAA==.',['紅蓮']='紅蓮貳式:BAAALAAECgMIAwAAAA==.',['索纳']='索纳苟斯:BAAALAAECgEIAQAAAA==.',['紫色']='紫色灵珠:BAABLAAFFH8GAAICAAIIeQ51XwBcAAACAAIIeQ51XwBcAAAAAA==.',['紫金']='紫金浪子:BAABLAAFFH8JAAIPAAII6wjHKQBmAAAPAAII6wjHKQBmAAAAAA==.',['红牙']='红牙牙:BAAALAAECgIIAgAAAA==.',['纵横']='纵横战:BAAALAAECgYIBgAAAA==.纵横甘泉:BAAALAAECgcICAAAAA==.',['维岳']='维岳:BAAALAAECgQIDAAAAA==.',['绿翼']='绿翼天使:BAAALAADCgIIAgAAAA==.',['羊百']='羊百万:BAAALAAFFAIIBAABLAAFFAgINQADANwiAA==.',['羊肉']='羊肉串:BAAALAAECgYICwAAAA==.',['胖就']='胖就少少吃:BAABLAAFFH8IAAIIAAYI3AgtIwBUAQAIAAYI3AgtIwBUAQAAAA==.胖就胖了:BAACLAAFFH8GAAIEAAIIvxBZaQBCAAAEAAIIvxBZaQBCAAAsAAQKfxUAAgQACAieHoZyAAQCAAQACAieHoZyAAQCAAAA.',['胖点']='胖点错了吗:BAABLAAFFH8HAAIMAAMIaA8LUwCUAAAMAAMIaA8LUwCUAAAAAA==.',['自恋']='自恋狂:BAAALAAFFAIIAgAAAA==.',['舞之']='舞之凋零:BAAALAAECgYIDwAAAA==.',['艾利']='艾利欧格:BAAALAAFFAIIAgAAAA==.',['艾沙']='艾沙维尔:BAACLAAFFH8RAAMiAAMIfxjtDQD1AAAiAAMI4hPtDQD1AAAjAAEIKxgPGgAAAAAsAAQKfxgAAyIABgi0IPgeAB0CACIABgjFH/geAB0CACMABggeF+UgAI0BAAAA.',['艾琳']='艾琳:BAAALAAECgYIBgAAAA==.',['花督']='花督抜德鸟:BAAALAAECgYICwAAAA==.',['花间']='花间舞:BAAALAAECgcIDAAAAA==.',['苍狼']='苍狼破月刀:BAAALAADCgUIBQAAAA==.',['苏南']='苏南:BAABLAAFFH8PAAMJAAMIxx2XIQAbAQAJAAMIxx2XIQAbAQAeAAEInxIOIABDAAAAAA==.',['英普']='英普锐斯:BAAALAAECgYIBgAAAA==.',['茉黛']='茉黛尔丶破晓:BAABLAAFFH8KAAMIAAIIoxy9QQBVAAAWAAII4we2LgBcAAAIAAIIoxy9QQBVAAAAAA==.',['荼荼']='荼荼:BAAALAAFFAIIBAAAAA==.',['莜莜']='莜莜筱影:BAAALAAFFAEIAQAAAA==.',['萌丶']='萌丶圣光:BAAALAAFFAIIBAAAAA==.萌丶巨龙:BAAALAAFFAIIBAAAAA==.萌丶滚滚:BAACLAAFFH8FAAQkAAIIvg5SFQCAAAAkAAIImQhSFQCAAAAgAAEIEQORGgA1AAAlAAIIvg6tIAAyAAAsAAQKfyEABCUACAjiHIgHAPgBACUACAjiHIgHAPgBACQABggwFow5AFYBACAAAQgICbtXACMAAAAA.',['萌狼']='萌狼赫罗酱:BAAALAAECgIIAgAAAA==.',['萌萌']='萌萌哒小老虎:BAAALAAECgYIBgAAAA==.',['萧龙']='萧龙龙:BAAALAADCgQIBAAAAA==.',['萨天']='萨天尊:BAAALAAECgYIDgAAAA==.',['萨曼']='萨曼莎:BAAALAAECgUIBQAAAA==.',['萨鲁']='萨鲁曼:BAABLAAFFH8FAAIDAAUIQRgyQQA2AQADAAUIQRgyQQA2AQAAAA==.',['葛二']='葛二蛋:BAAALAADCgQIBAAAAA==.',['葡萄']='葡萄有点皮:BAAALAADCggICAAAAA==.',['蔥油']='蔥油拌麵:BAAALAAECgIIAgAAAA==.',['蘑咕']='蘑咕不咕:BAACLAAFFH8xAAICAAcIXBXGDwDoAQACAAcIXBXGDwDoAQAsAAQKfyMAAgIACAi2GP4/AB4CAAIACAi2GP4/AB4CAAAA.',['蛋疼']='蛋疼精英:BAAALAAECgUIBQAAAA==.',['蝴蝶']='蝴蝶丶流萤:BAAALAAECgYICgAAAA==.',['血凌']='血凌丶无极:BAAALAAFFAIIAgAAAA==.',['血龙']='血龙至尊宝:BAAALAAECgYIDAAAAA==.',['被放']='被放逐的光:BAABLAAFFH8OAAIHAAYItwBgbwAcAAAHAAYItwBgbwAcAAAAAA==.',['覆灭']='覆灭重生:BAACLAAFFH82AAMMAAYIaSMpCwDhAQAMAAYIaSMpCwDhAQALAAIIBhv0HgCNAAAsAAQKfxwAAwwACAhmJJkXAP8CAAwACAhmI5kXAP8CAAsABghdI/AkAEYCAAAA.',['诡秘']='诡秘之主:BAAALAAECgUICgAAAA==.',['诡诈']='诡诈藏锋:BAABLAAFFH8WAAMiAAYI4Bn9CACHAQAiAAYIrxj9CACHAQAjAAIIgBNbDgCTAAAAAA==.',['诶哟']='诶哟哟丶:BAACLAAFFH82AAMRAAYI3AurHQBgAQARAAYI3AurHQBgAQAYAAEIxwH1MQAqAAAsAAQKfzoABBEACAgtE2c9AOMBABEACAgtE2c9AOMBABgACAi8DU5OAH0BAB0AAQiPCGkgACQAAAAA.',['诶嘿']='诶嘿嘿丶:BAAALAAECgMIAwAAAA==.',['诺兹']='诺兹多母:BAAALAAECgIIAgAAAA==.',['豷天']='豷天世界:BAAALAAECggICQAAAA==.',['贵仔']='贵仔:BAACLAAFFH8KAAINAAIIdAtHTgCEAAANAAIIdAtHTgCEAAAsAAQKfxQAAg0ACAjXEttNABgBAA0ACAjXEttNABgBAAAA.',['赊旗']='赊旗:BAAALAAECgQIBAAAAA==.',['起司']='起司:BAABLAAFFH8NAAIhAAMIURX2CwBXAAAhAAMIURX2CwBXAAABLAAFFAgIAwAKAAAAAA==.',['路特']='路特:BAAALAAECgYICQAAAA==.',['软床']='软床等硬枪:BAAALAAECgcICwAAAA==.',['达摩']='达摩流浪者:BAAALAADCgcIBwAAAA==.',['迈尔']='迈尔斯:BAAALAADCgUIBQAAAA==.',['迪士']='迪士尼二号:BAAALAAECgYIBgAAAA==.',['迷人']='迷人的危险:BAAALAAECgYIBwAAAA==.',['逃课']='逃课疯子:BAAALAAECgYIEgAAAA==.',['逆殇']='逆殇丶:BAAALAAECgEIAQAAAA==.',['逐日']='逐日轩:BAAALAAECgYIDwAAAA==.',['這個']='這個小美女:BAAALAAFFAIIAgAAAA==.',['通通']='通通西开:BAAALAAECgYICQAAAA==.',['速度']='速度之靴:BAAALAADCggICAAAAA==.',['邂逅']='邂逅丶:BAACLAAFFH8FAAIGAAIIqwtmFwBYAAAGAAIIqwtmFwBYAAAsAAQKfxcAAwYABgjDE9kUAAgBAAcABggQDG/oABcBAAYABghkEtkUAAgBAAAA.邂逅丶圣:BAAALAAECgIIAgAAAA==.邂逅丶猎:BAABLAAFFH8IAAIMAAIIvgaregBxAAAMAAIIvgaregBxAAAAAA==.',['邪天']='邪天帝:BAAALAAECgEIAQAAAA==.',['金王']='金王之王:BAAALAAECgMIAwAAAA==.',['鈊殇']='鈊殇丶:BAAALAAECgQIBAAAAA==.',['银河']='银河冰城:BAAALAADCgMIAwAAAA==.',['闪电']='闪电姐:BAABLAAFFH8GAAMMAAYIawAPvwAmAAAMAAQIkwAPvwAmAAALAAIIGwBqHQAPAAAAAA==.',['队长']='队长丶是我:BAABLAAFFH8FAAIIAAIIHwRrXwA1AAAIAAIIHwRrXwA1AAAAAA==.',['阿姆']='阿姆斯特懒:BAAALAADCgYIBgAAAA==.',['阿德']='阿德德:BAABLAAFFH8OAAMFAAUIxhU2GgBbAQAFAAUIxhU2GgBbAQATAAIIkAgaOwAxAAAAAA==.',['阿特']='阿特別:BAABLAAFFH8GAAIEAAYIuQ70HwBoAQAEAAYIuQ70HwBoAQABLAAFFAgIBgAPAOIhAA==.',['阿瓦']='阿瓦隆铸剑师:BAABLAAFFH8MAAIMAAYIMROTHgARAQAMAAYIMROTHgARAQAAAA==.',['阿达']='阿达丽尔:BAAALAAECgEIAQAAAA==.',['阿鲁']='阿鲁尼拉:BAAALAAFFAIIBAAAAA==.',['陈一']='陈一发兒:BAACLAAFFH8uAAIMAAYIVRj5LACCAQAMAAYIVRj5LACCAQAsAAQKfzkAAgwACAhvI8kVAAgDAAwACAhvI8kVAAgDAAAA.',['陌上']='陌上花開:BAAALAAECgQIBAAAAA==.',['雨夜']='雨夜不带刀:BAABLAAFFH8GAAIDAAIIPQOKkAB2AAADAAIIPQOKkAB2AAAAAA==.',['零度']='零度万箭穿心:BAAALAAECggIAQAAAA==.零度龙龙:BAAALAAECgEIAQAAAA==.',['霜蹄']='霜蹄死鬃:BAAALAAECgMIAwAAAA==.',['韧血']='韧血:BAAALAAECgYIBgAAAA==.',['风华']='风华丶夜舞:BAAALAADCgQIBAAAAA==.',['风瑟']='风瑟:BAAALAAECgYICgAAAA==.',['飘逸']='飘逸的红哥:BAAALAAECgYIBgAAAA==.',['飛飛']='飛飛魚:BAAALAAECgYIEgAAAA==.',['飼養']='飼養師水晶:BAAALAAECgIIAgAAAA==.',['駄菓']='駄菓子屋:BAAALAADCggIEAAAAA==.',['驫龘']='驫龘殇:BAACLAAFFH8HAAINAAMIUgwpLQDRAAANAAMIUgwpLQDRAAAsAAQKfyoAAg0ACAjIGr80AGgCAA0ACAjIGr80AGgCAAAA.',['马应']='马应龙:BAAALAAECgYIBgAAAA==.',['高速']='高速公鹿:BAAALAAFFAYIAgAAAA==.',['魅魔']='魅魔饲养员:BAAALAAFFAIIAgAAAA==.',['魔天']='魔天帝:BAAALAAECgYIBwAAAA==.',['鸭子']='鸭子宝宝:BAAALAAECgQIBAAAAA==.',['鹅城']='鹅城憋佬:BAABLAAFFH8KAAIDAAIIph6OVACeAAADAAIIph6OVACeAAAAAA==.',['黑色']='黑色准男爵:BAAALAAECgYIDAAAAA==.',['龘龐']='龘龐瀣:BAAALAAFFAIIAgAAAA==.',['龙焰']='龙焰无极:BAAALAAFFAIIBAAAAA==.',['龙皓']='龙皓晨:BAAALAADCgQIBAAAAA==.',['龙舌']='龙舌兰姑娘:BAAALAAECgQIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end