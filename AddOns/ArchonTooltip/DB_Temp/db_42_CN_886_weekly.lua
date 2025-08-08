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
 local lookup = {'Paladin-Retribution','Warrior-Protection','Warrior-Arms','Shaman-Restoration','Rogue-Assassination','Hunter-BeastMastery','Mage-Fire','Mage-Frost','DemonHunter-Havoc','Hunter-Marksmanship','Warlock-Demonology','Warlock-Destruction','DemonHunter-Vengeance','Druid-Balance','Warrior-Fury','Unknown-Unknown','Priest-Discipline','Priest-Shadow','Priest-Holy','Mage-Arcane','Rogue-Subtlety','Rogue-Outlaw','Warlock-Affliction','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Protection','Monk-Mistweaver','Evoker-Devastation','Shaman-Elemental','Monk-Brewmaster','Monk-Windwalker','Evoker-Preservation','Paladin-Holy','Druid-Restoration','Druid-Guardian','Shaman-Enhancement','Hunter-Survival',}; local provider = {region='CN',realm='风行者',name='CN',type='weekly',zone=42,date='2025-08-04',data={Ab='Abies:BAABKgAECn8XAAIBAAgIux4WUwD7AQABAAgIux4WUwD7AQAAAA==.',Ad='Adioscowboei:BAAAKgAECgUIDQABKgAFFAYIDwACAAwiAA==.Adioscowboy:BAACKgAFFH8PAAMCAAMIDCLXBQAaAQACAAMIDCLXBQAaAQADAAIIBB7LGgC0AAAqAAQKfyAAAgIACAi+JHkCAM8CAAIACAi+JHkCAM8CAAAA.',An='Andoin:BAAAKgAECgMIBQAAAA==.Andoing:BAAAKgAECgQIBAAAAA==.Anduin:BAAAKgADCggIDQAAAA==.',Aq='Aqua:BAAAKgAECgYICAAAAA==.',Ar='Arantir:BAABKgAFFH8GAAIEAAYIChT2DQBwAQAEAAYIChT2DQBwAQAAAA==.',As='Astra:BAAAKgAFFAgIBAAAAA==.',At='Atom:BAABKgAECn8YAAIFAAgI7BpRDABAAgAFAAgI7BpRDABAAgAAAA==.',Au='Aulol:BAAAKgAECgIIAgAAAA==.',Av='Avid:BAACKgAFFH8GAAIBAAUIUxStLwApAQABAAUIUxStLwApAQAqAAQKfxkAAgEABwgHHOt6AKEBAAEABwgHHOt6AKEBAAAA.',Aw='Awuh:BAAAKgAFFAYIAQAAAA==.',Ba='Baby:BAABKgAFFH8LAAIGAAQIwSMaEQAIAQAGAAQIwSMaEQAIAQAAAA==.',Bu='Buffoon:BAAAKgAECgUIBwAAAA==.',Ch='Chatgpt:BAAAKgAECgEIAQAAAA==.',Co='Cooyi:BAAAKgAECgYIBgAAAA==.',Da='Dark:BAABKgAFFH8HAAIBAAQIASFsDAAjAQABAAQIASFsDAAjAQABKgAFFAgICAAGAHMNAA==.',De='Deepsick:BAAAKgAFFAQIBAAAAA==.',Em='Emiliatan:BAAAKgAFFAQIBAAAAA==.',En='Enneagram:BAABKgAFFH8IAAIBAAgIoBkzBgBZAgABAAgIoBkzBgBZAgAAAA==.Ensiferum:BAAAKgAECggICAAAAA==.',Fe='Fetta:BAAAKgAECgQIBAAAAA==.Feynman:BAAAKgAFFAEIAQAAAA==.',Fu='Fuz:BAABKgAECn8eAAMHAAgIWBpdOQCuAQAHAAgI+BJdOQCuAQAIAAYIiB/ZQABlAQAAAA==.',Gh='Ghosthammer:BAAAKgAECgQIBAAAAA==.',Go='Goodfaith:BAABKgAFFH8GAAIJAAYI0hNsFABWAQAJAAYI0hNsFABWAQAAAA==.',Ha='Hardrock:BAACKgAFFH8WAAMKAAcIOBSZCwBRAQAKAAUILhCZCwBRAQAGAAUIVRdDHwARAQAqAAQKfxYAAwoACAgbHccWAHYBAAoABQijHMcWAHYBAAYABgjIGgafAIcAAAAA.Havesk:BAABKgAFFH8IAAMLAAMIAhbyCwDVAAALAAMIAhbyCwDVAAAMAAIIZAhDQQBnAAAAAA==.',Hi='Hi:BAAAKgAECgMIAwAAAA==.',Hy='Hypocrisy:BAAAKgAECgYIEAAAAA==.',Is='Isshiki:BAAAKgAFFAgIAgAAAA==.Iszeraelune:BAABKgAFFH8FAAMKAAQI7hTvDADoAAAKAAQI7hTvDADoAAAGAAEIAAD/VAAAAAABKgAFFAgIDgADAPAdAA==.',Iv='Ives:BAACKgAFFH8GAAIJAAYI7hGYFwA+AQAJAAYI7hGYFwA+AQAqAAQKfxgAAwkACAgxHgUVAFkCAAkACAgxHgUVAFkCAA0AAQgAAGB7AAAAAAAA.',Jh='Jhwtiancai:BAAAKgAFFAgIBAAAAA==.Jhwwudi:BAAAKgAECgIIAgAAAA==.',Ka='Kalmah:BAAAKgAECgYIBgAAAA==.Kayzen:BAAAKgAECggIDgAAAA==.',Ko='Korospo:BAAAKgAFFAQIBAAAAA==.Kosaka:BAAAKgADCgUIBQAAAA==.',La='La:BAABKgAFFH8MAAIOAAQIeyQZKQDvAAAOAAQIeyQZKQDvAAAAAA==.Lastdance:BAAAKgAFFAgIAwAAAA==.Lastwarrior:BAAAKgAECggIDwAAAA==.',Lo='Loen:BAABKgAECn8gAAQDAAgI3BnHEwD0AQADAAgIjxnHEwD0AQAPAAQIsxTtUwC9AAACAAMIlA/UPwBbAAAAAA==.',Lu='Lucifee:BAABKgAFFH8GAAIBAAMI3SA2HQD5AAABAAMI3SA2HQD5AAAAAA==.',Ma='Maboroshi:BAAAKgADCggICAAAAA==.Manta:BAAAKgAFFAUIAwAAAA==.Mass:BAAAKgAECgYIBgAAAA==.',Mi='Mikasa:BAAAKgAFFAQIBAAAAA==.',Mu='Murazel:BAAAKgAFFAQIBAABKgAFFAgIBAAQAAAAAA==.',Ne='Neytiri:BAABKgAECn8iAAMGAAgIjiHNLABAAgAGAAgI5iDNLABAAgAKAAUIghxFRQA8AQAAAA==.',No='Norther:BAAAKgAECgYICQAAAA==.',Ny='Nymphe:BAACKgAFFH8LAAIRAAMIeA/mHwCkAAARAAMIeA/mHwCkAAAqAAQKfysAAxEACAjCILcIAJQCABEACAjCILcIAJQCABIABAh2GDk8AMsAAAAA.',Ol='Ollier:BAAAKgAECgEIAQAAAA==.',On='Onion:BAABKgAFFH8GAAITAAYIuAnXEwAUAQATAAYIuAnXEwAUAQAAAA==.',Pi='Piscesangel:BAAAKgAECgUIAgAAAA==.',Pl='Playerdspozk:BAAAKgADCggICAAAAA==.Plzfthx:BAECKgAFFH8LAAMUAAMI5gsDLgCsAAAUAAMI5gsDLgCsAAAIAAIIcgkGGAB3AAAqAAQKfyUABAgACAjwHdIbACYCAAgACAgwG9IbACYCABQABghlGoE3AGwBAAcAAQgiA7SoAB4AAAAA.',Ps='Psysafely:BAABKgAFFH8FAAIJAAUIJhLvGwAgAQAJAAUIJhLvGwAgAQABKgAFFAgIBAAQAAAAAA==.',Re='Rebornlyqaq:BAACKgAFFH8OAAQVAAMInhozAwD2AAAVAAMIKhkzAwD2AAAWAAIIeA0xCQB2AAAFAAEIuQMtGwA8AAAqAAQKfzoABBUACAjOIG4GAIcCABUACAh9IG4GAIcCABYABwj9GmIIALwBAAUAAgjMB0JJADoAAAAA.Red:BAAAKgAFFAQIBAAAAA==.',Sa='Saylor:BAAAKgAECggIEAABKgAFFAgIAgAQAAAAAA==.',Sf='Sflash:BAAAKgADCgQIBAAAAA==.',Sk='Skrskr:BAAAKgAECgMIBAAAAA==.',Sl='Slan:BAAAKgADCggICAAAAA==.',St='Stiveni:BAABKgAECn8pAAMFAAgIWhsBDQBMAgAFAAgIWhsBDQBMAgAVAAcIDw0bGQBrAQAAAA==.',Su='Superfan:BAAAKgAECgYIBgAAAA==.',Sy='Sylleria:BAABKgAFFH8FAAISAAUI8hW/BAB6AQASAAUI8hW/BAB6AQABKgAFFAgIDwADAJAUAA==.',['Sà']='Sàber:BAAAKgADCggICgAAAA==.',Th='Thehunters:BAABKgAFFH8IAAIGAAQINRMsMwDDAAAGAAQINRMsMwDDAAAAAA==.',Us='Usexz:BAAAKgAECgYIBgAAAA==.',Ve='Veerene:BAAAKgAECggIEAAAAA==.',Vi='Virtuosa:BAAAKgADCggIEAAAAA==.Viva:BAAAKgAFFAQIBAAAAA==.',Wr='Wr:BAAAKgAECgQIDAAAAA==.',Xd='Xd:BAAAKgADCgQIBAAAAA==.',Xl='Xlight:BAACKgAFFH8LAAMUAAMI+hu7IgDZAAAUAAMIjhq7IgDZAAAIAAIIsxzWGwCjAAAqAAQKfx0ABAgACAj/IWASAGsCAAgACAiAIWASAGsCAAcAAwglFA6FAHUAABQAAQh+IoGEAFwAAAAA.',Yb='Ybab:BAAAKgAFFAQIBAAAAA==.',Yl='Ylaya:BAABKgAFFH8OAAQLAAYIWBtUBgDRAAAMAAYIWBvNEgBwAQALAAQIQw5UBgDRAAAXAAEIAACPJAAAAAAAAA==.',Yu='Yuikk:BAAAKgAECgIIAgAAAA==.',['一只']='一只鸟德:BAABKgAFFH8IAAIKAAgIpw1aCgCxAQAKAAgIpw1aCgCxAQAAAA==.',['一哚']='一哚小黄錵:BAABKgAFFH8IAAMYAAQIrhaxEwCqAAAZAAQIrhZUMwDIAAAYAAQIvQ6xEwCqAAAAAA==.',['一头']='一头老绵羊:BAABKgAFFH8GAAIGAAQI8ApKRwCGAAAGAAQI8ApKRwCGAAAAAA==.',['一根']='一根贱骨头:BAAAKgADCggICAAAAA==.',['一点']='一点霸道:BAABKgAFFH8MAAIZAAQI9xdcKADsAAAZAAQI9xdcKADsAAAAAA==.',['一瞎']='一瞎一:BAAAKgADCgIIAgAAAA==.',['一般']='一般给力:BAACKgAFFH8OAAMaAAMIQwPDEQBnAAABAAMIdQLncgCEAAAaAAMIQQPDEQBnAAAqAAQKfyQAAwEACAj8EIN2AGYBAAEACAj8EIN2AGYBABoABQi6BGtEAGsAAAAA.',['七枷']='七枷社:BAAAKgAFFAIIAgAAAA==.',['上帝']='上帝是女的:BAABKgAFFH8KAAIBAAgIXRLfJwBIAQABAAgIXRLfJwBIAQAAAA==.',['下面']='下面的嫂子:BAAAKgAFFAQIBAAAAA==.',['不想']='不想加班:BAAAKgAECgUIBQAAAA==.',['丑兔']='丑兔:BAAAKgAECggICAABKgAFFAgIAgAQAAAAAA==.',['东了']='东了个东呀:BAABKgAFFH8IAAIEAAQISBixJgDcAAAEAAQISBixJgDcAAAAAA==.',['东呀']='东呀么东:BAAAKgAECggICAAAAA==.',['东煌']='东煌太一:BAABKgAFFH8GAAIBAAYIshdFIgBkAQABAAYIshdFIgBkAQABKgAFFAgIGAABAAMcAA==.',['东皇']='东皇贼溜灬:BAABKgAFFH8GAAIBAAUIAxM5MQAkAQABAAUIAxM5MQAkAQAAAA==.',['东阳']='东阳彦祖:BAAAKgAFFAYIAQAAAA==.',['两年']='两年半:BAABKgAFFH8IAAIPAAQIdBp4GgCvAAAPAAQIdBp4GgCvAAAAAA==.',['丨北']='丨北风丨:BAAAKgAECgEIAQAAAA==.',['丨澄']='丨澄澄丨:BAAAKgADCggICAAAAA==.',['丨瘸']='丨瘸子:BAAAKgAECgcIBwAAAA==.',['丨风']='丨风动丨:BAAAKgADCgMIAwAAAA==.',['丶爲']='丶爲妳而战:BAAAKgAECgMIAwABKgAFFAgIAgAQAAAAAA==.',['丷看']='丷看不见我丷:BAAAKgAECggICAAAAA==.',['丷霜']='丷霜血领主:BAAAKgAECgQIBAAAAA==.',['丿幻']='丿幻世:BAABKgAFFH8GAAIJAAYI4x+REACAAQAJAAYI4x+REACAAQAAAA==.',['丿花']='丿花钱滔滔灬:BAABKgAECn8WAAIGAAgIEiB8BwCbAgAGAAgIEiB8BwCbAgAAAA==.',['九九']='九九堂:BAABKgAFFH8OAAIDAAYI/BseCQB4AQADAAYI/BseCQB4AQAAAA==.',['九千']='九千七:BAAAKgAFFAYIAgAAAA==.',['了欲']='了欲:BAAAKgAECgUIBQAAAA==.',['二丈']='二丈三:BAAAKgAFFAIIAwAAAA==.',['二娜']='二娜:BAAAKgADCggICAAAAA==.',['二狗']='二狗:BAABKgAFFH8GAAIEAAYISw4WFAA2AQAEAAYISw4WFAA2AQAAAA==.',['京城']='京城大叔:BAABKgAFFH8IAAIYAAgIBR28AgBSAgAYAAgIBR28AgBSAgAAAA==.',['从前']='从前有小猪:BAAAKgAECggICQAAAA==.',['仓木']='仓木丶麻衣:BAAAKgAECgUIBQAAAA==.',['仙风']='仙风:BAAAKgAECgQIBAAAAA==.',['伊格']='伊格尼斯:BAAAKgAECgEIAQAAAA==.',['伊瑞']='伊瑞儿:BAAAKgAECgYIBgABKgAFFAQIGQARAFsdAA==.',['会滑']='会滑翔的阿福:BAAAKgAECgcICgAAAA==.',['伪爱']='伪爱国青年:BAAAKgAECgYICQAAAA==.',['低调']='低调丨团子:BAAAKgAFFAQIBAAAAA==.',['体育']='体育生丶:BAAAKgAECgIIAgAAAA==.',['何晨']='何晨光弹道:BAAAKgAECgEIAQAAAA==.',['你也']='你也叫蝶:BAAAKgAECgcIBwAAAA==.',['停电']='停电寄:BAAAKgAECgQIBAAAAA==.',['傲霜']='傲霜丶:BAABKgAFFH8IAAIMAAgIrAasCgClAQAMAAgIrAasCgClAQAAAA==.',['允执']='允执厥中:BAAAKgAECggIDgAAAA==.',['先走']='先走一步:BAAAKgADCggICAAAAA==.',['光明']='光明正大:BAABKgAFFH8IAAIFAAgIORBqBgAcAgAFAAgIORBqBgAcAgAAAA==.',['兔学']='兔学姐:BAAAKgAECggIDgAAAA==.',['六六']='六六折:BAABKgAFFH8JAAMUAAYIzBBEJgDJAAAUAAQI4hREJgDJAAAHAAQIQAzQLQCSAAABKgAFFAgIDgAUACQgAA==.',['兼职']='兼职兽医:BAAAKgAFFAQIBAAAAA==.',['冥凰']='冥凰:BAABKgAECn8lAAIMAAgIMSDJAwCOAgAMAAgIMSDJAwCOAgAAAA==.',['冰山']='冰山烈焰:BAAAKgADCgQIBAAAAA==.',['冰雪']='冰雪糖糖:BAAAKgAFFAgIBAAAAA==.',['冰雷']='冰雷雷:BAAAKgAFFAIIAgABKgAFFAgICAAMANASAA==.',['冰霜']='冰霜序曲:BAAAKgAFFAYIBAABKgAFFAgIFAAUACkjAA==.',['冷訫']='冷訫在线:BAABKgAFFH8VAAMIAAYIxB+GAwDCAQAIAAYInByGAwDCAQAUAAMI2xjkMgCYAAAAAA==.',['凛风']='凛风丷:BAAAKgADCgQIBAAAAA==.凛风风丷:BAAAKgADCgIIAgAAAA==.',['凹吐']='凹吐卤丝:BAAAKgADCgIIAgAAAA==.',['出鞘']='出鞘狂刃:BAAAKgAFFAYIAQAAAA==.',['刀乐']='刀乐法诗:BAABKgAFFH8GAAIUAAYI+A8BEwBNAQAUAAYI+A8BEwBNAQAAAA==.',['别跟']='别跟我地葛:BAAAKgAECggICgAAAA==.',['勇敢']='勇敢的油条:BAAAKgADCgEIAQAAAA==.',['北山']='北山冰皇:BAAAKgAECgMIAwAAAA==.',['十七']='十七连击坦:BAAAKgAECgQIBgAAAA==.',['千印']='千印:BAAAKgAECgEIAQAAAA==.',['千斤']='千斤墜:BAABKgAECn8iAAICAAgISAQ6JwDJAAACAAgISAQ6JwDJAAAAAA==.',['千秋']='千秋亦永恒:BAAAKgADCggICAABKgAFFAgIBAAQAAAAAA==.',['半月']='半月树啊:BAABKgAFFH8FAAIYAAUIHwofHgCyAAAYAAUIHwofHgCyAAAAAA==.',['半糖']='半糖:BAAAKgAECggIDAAAAA==.',['华年']='华年:BAABKgAFFH8MAAQSAAQIRiMRBwA7AQASAAQIRiMRBwA7AQARAAQIJyBLEwD+AAATAAEIqQIAAAAAAAAAAA==.',['华胥']='华胥灬永眠:BAAAKgAECgIIAgAAAA==.',['南巷']='南巷清风:BAAAKgAFFAQIBAAAAA==.',['卡卡']='卡卡罗:BAABKgAECn8ZAAIbAAgIiR4tCgBlAgAbAAgIiR4tCgBlAgABKgAFFAgIHQAcAB8iAA==.',['卧式']='卧式尼霸霸:BAAAKgAECggICAAAAA==.',['卩小']='卩小菇凉巛:BAAAKgAFFAYIAQAAAA==.',['卵惊']='卵惊天:BAAAKgAECgQIBAAAAA==.',['双手']='双手跳舞:BAAAKgAECgMIBAAAAA==.',['发呆']='发呆的软泥乖:BAAAKgAECgIIAgAAAA==.',['只会']='只会大风车:BAAAKgAFFAQIBAAAAA==.',['叮咚']='叮咚呛呛:BAABKgAFFH8IAAIGAAYImiDVWABIAAAGAAYImiDVWABIAAAAAA==.叮咚坤:BAAAKgAFFAQIBAAAAA==.叮咚铛铛:BAABKgAFFH8GAAIPAAYIThKeDwBbAQAPAAYIThKeDwBbAQAAAA==.',['可楽']='可楽:BAAAKgAFFAMIBAAAAA==.',['吃我']='吃我豆腐:BAABKgAFFH8MAAMEAAgIAxVZBwDTAQAEAAcIbBdZBwDTAQAdAAEIWhEyJQBQAAAAAA==.',['各种']='各种手法:BAAAKgAECgQIBAAAAA==.',['后悔']='后悔毒药:BAACKgAFFH8cAAMYAAQIKwYHEAB4AAAYAAQIKwYHEAB4AAAZAAMIDgIRHgBmAAAqAAQKfxcAAxkACAhPDmpGAFgBABkACAhPDmpGAFgBABgACAijB00+AIEAAAAA.',['听风']='听风语:BAABKgAFFH8JAAIFAAQIIR5cGADlAAAFAAQIIR5cGADlAAABKgAFFAgIMwAFAOQgAA==.',['吴彦']='吴彦祖:BAABKgAFFH8XAAILAAQIMxR0BwDMAAALAAQIMxR0BwDMAAAAAA==.',['呆毛']='呆毛王:BAAAKgADCgIIAgAAAA==.',['咘咕']='咘咕:BAAAKgAECggICAAAAA==.',['咩玖']='咩玖:BAAAKgAECgUIDQAAAA==.',['哈利']='哈利露露:BAABKgAFFH8IAAIJAAgIMAyrCQDfAQAJAAgIMAyrCQDfAQAAAA==.',['哞哞']='哞哞小小母牛:BAAAKgADCgEIAQAAAA==.',['唯你']='唯你是青山:BAAAKgAECgEIAQAAAA==.',['啊哒']='啊哒哒鸭:BAAAKgAECgUIBgAAAA==.',['喜欢']='喜欢谧静:BAAAKgAECggICAAAAA==.',['嘿歌']='嘿歌:BAABKgAECn8ZAAMbAAgIIRE7PABTAQAbAAgIIRE7PABTAQAeAAYIcAJkIgA4AAAAAA==.',['四喜']='四喜团子:BAAAKgAECgYIBgAAAA==.',['团分']='团分十万:BAAAKgAECgIIAgAAAA==.',['图南']='图南:BAABKgAFFH8GAAIDAAYIKRrgBAC1AQADAAYIKRrgBAC1AQAAAA==.',['土猫']='土猫:BAAAKgAFFAMIAwAAAA==.',['土豆']='土豆土豆:BAAAKgAFFAgIBAAAAA==.',['圣光']='圣光丨崩碎:BAAAKgAECggIDAABKgAFFAgIBAAQAAAAAA==.圣光闪瞎狗眼:BAAAKgAFFAgIAwAAAA==.',['地精']='地精:BAACKgAFFH8hAAIYAAQIbw1cIwCNAAAYAAQIbw1cIwCNAAAqAAQKfyAAAhgACAjSE+UXAJgBABgACAjSE+UXAJgBAAAA.',['埖喵']='埖喵喵丶:BAABKgAFFH8QAAMJAAMIpRrKJQDgAAAJAAMIpRrKJQDgAAANAAEIfwdDEwAuAAAAAA==.',['墨方']='墨方:BAABKgAECn8dAAIfAAgInR4nFgAvAgAfAAgInR4nFgAvAgAAAA==.',['墨染']='墨染丹青:BAAAKgADCggICAAAAA==.',['夕阳']='夕阳丿白訫:BAAAKgADCgQIBAAAAA==.',['夕颜']='夕颜西:BAABKgAECn8XAAIBAAgI9RzxLwBhAgABAAgI9RzxLwBhAgAAAA==.',['夜幕']='夜幕丶繁星:BAAAKgADCgIIAgAAAA==.',['夜羽']='夜羽:BAACKgAFFH80AAMGAAgISiS8AwCfAQAGAAcIgiO8AwCfAQAKAAUI0CTfDQB+AQAqAAQKf0IAAwYACAgFJi8HAPICAAYACAgFJi8HAPICAAoABwguHHRJAPcAAAAA.',['大云']='大云雀来海:BAAAKgAECgQIBAAAAA==.',['大夢']='大夢如來:BAAAKgAECgIIAgAAAA==.',['大头']='大头居然:BAAAKgAFFAYIBAAAAA==.',['大姨']='大姨妈归来:BAABKgAFFH8NAAIKAAMIuAeKNwCXAAAKAAMIuAeKNwCXAAAAAA==.',['大米']='大米冲层死骑:BAAAKgADCggIDgAAAA==.',['大罐']='大罐树奶:BAAAKgADCggIDgAAAA==.',['天不']='天不长地不久:BAAAKgAECgMIAwAAAA==.',['天使']='天使安琪兒:BAAAKgAECgEIAQAAAA==.天使霹雳:BAAAKgADCgEIAQAAAA==.',['天呐']='天呐我太酷辣:BAACKgAFFH8FAAIDAAUI/BikCwBSAQADAAUI/BikCwBSAQAqAAQKfxgAAwMACAjCHRAEAHECAAMACAifHRAEAHECAA8ABwheGs0LAOUBAAAA.',['天地']='天地久长:BAAAKgADCgMIAwAAAA==.',['天涯']='天涯客:BAAAKgAECgYIBgAAAA==.天涯风云:BAABKgAECn8UAAIBAAgIIhW9awCBAQABAAgIIhW9awCBAQAAAA==.',['天辣']='天辣我好酷欸:BAACKgAFFH8KAAIbAAYIZxCJDABdAQAbAAYIZxCJDABdAQAqAAQKfxUAAxsACAjIIVECAKgCABsACAjIIVECAKgCAB8AAQgAAByHAAAAAAAA.',['天音']='天音化物:BAABKgAFFH8KAAMaAAgIMgpdCAAtAQAaAAgIlwRdCAAtAQABAAIIUhZWbQCQAAAAAA==.',['太丨']='太丨素:BAAAKgAECgIIAgAAAA==.',['奥法']='奥法:BAAAKgADCgYIBgAAAA==.',['奥类']='奥类莉亚:BAACKgAFFH8NAAIBAAQIcBsqKADGAAABAAQIcBsqKADGAAAqAAQKfxUAAgEACAh/GiRVAL4BAAEACAh/GiRVAL4BAAAA.',['奥雷']='奥雷莉亚斯:BAACKgAFFH8lAAIJAAYIBxcYHgASAQAJAAYIBxcYHgASAQAqAAQKfx8AAwkACAijHd0kACgCAAkACAijHd0kACgCAA0ABgh/FNYrACMBAAAA.',['奶酪']='奶酪不甜:BAABKgAFFH8LAAIBAAYI7R/1FAC0AQABAAYI7R/1FAC0AQAAAA==.',['如意']='如意小阿发:BAAAKgAECggICAAAAA==.',['妮珂']='妮珂基德曼:BAABKgAECn8ZAAMGAAgIdhsBMgAtAgAGAAgIuBoBMgAtAgAKAAYIlhOnHgAjAQAAAA==.',['娇花']='娇花她们:BAAAKgADCgEIAQAAAA==.',['孤丨']='孤丨影:BAACKgAFFH8IAAMDAAMI7RGpEACaAAADAAMImRGpEACaAAAPAAIImAhQJABrAAAqAAQKfywAAwMACAjuHnYOAEsCAAMACAjrHnYOAEsCAA8ABggtHHg3AJ8BAAAA.',['孤单']='孤单海毛虫:BAAAKgADCggIEAAAAA==.',['孤蚂']='孤蚂:BAABKgAFFH8IAAIKAAQIdBQpEwDGAAAKAAQIdBQpEwDGAAAAAA==.',['宇宙']='宇宙公司马总:BAACKgAFFH8TAAIBAAYIjx8SFwCjAQABAAYIjx8SFwCjAQAqAAQKfxwAAgEACAixIEFBACsCAAEACAixIEFBACsCAAEqAAUUCAgEABAAAAAA.',['守护']='守护神的光芒:BAABKgAECn8mAAIMAAgIexQaLgC7AQAMAAgIexQaLgC7AQABKgAFFAgICAAMANMNAA==.',['安吉']='安吉拉:BAAAKgAECgEIAQAAAA==.',['安琪']='安琪不哭:BAABKgAFFH8GAAMMAAYI/hTWBQBIAQAMAAUILhfWBQBIAQALAAEIQQwlFQBTAAAAAA==.',['安静']='安静的湮灭:BAAAKgAECggICAAAAA==.',['小医']='小医仙丶:BAAAKgAECgUIBQAAAA==.',['小土']='小土虫:BAAAKgAFFAIIAgAAAA==.',['小小']='小小的软泥怪:BAAAKgAFFAQIBAAAAA==.小小龙咕:BAAAKgAFFAYIAgAAAA==.',['小木']='小木俏:BAAAKgAECgIIAgAAAA==.',['小海']='小海獭:BAAAKgAECgEIAQAAAA==.',['小红']='小红手未來:BAAAKgAECgEIAQAAAA==.',['小罐']='小罐龙奶:BAAAKgADCggICgAAAA==.',['小胖']='小胖子丶:BAAAKgAECgYIBwAAAA==.',['小艾']='小艾弗:BAABKgAFFH8IAAIBAAQINSI+EAATAQABAAQINSI+EAATAQABKgAFFAgIBAAQAAAAAA==.',['小雨']='小雨绵绵:BAAAKgAECgEIAQAAAA==.',['小鞋']='小鞋匠呀:BAAAKgAECggICAAAAA==.',['尛胡']='尛胡狸:BAAAKgADCgcIBwAAAA==.',['尤里']='尤里安:BAAAKgADCggICAABKgAECgIIAgAQAAAAAA==.',['尨影']='尨影:BAAAKgAFFAQIAQABKgAFFAgIEwAMAAUSAA==.',['尼姆']='尼姆戳啰嗦:BAAAKgAFFAgIAQAAAA==.',['山乂']='山乂魈:BAAAKgAECgEIAQAAAA==.',['川川']='川川欧巴:BAAAKgAECgYICwAAAA==.',['希尔']='希尔瓦蕾丝:BAAAKgAECgMIBgAAAA==.希尔袜娜丝:BAAAKgAECggICAABKgAFFAgIBgATAKsLAA==.',['希沃']='希沃斯:BAABKgAFFH8VAAMdAAYIJBjLBQCXAQAdAAYIJBjLBQCXAQAEAAQI6yMuBAA/AQABKgAFFAgIEQAaAFUbAA==.',['希达']='希达:BAABKgAFFH8QAAIFAAYIKyFuCADeAQAFAAYIKyFuCADeAQAAAA==.',['帝霹']='帝霹哎丝:BAAAKgAFFAYIAgABKgAFFAgILQAGAMMeAA==.',['带带']='带带我:BAABKgAECn8/AAIFAAgIRxxuEAAjAgAFAAgIRxxuEAAjAgAAAA==.',['弱势']='弱势:BAAAKgADCgQIBQAAAA==.',['弹道']='弹道偏左:BAABKgAFFH8KAAIGAAMIowh3LwCaAAAGAAMIowh3LwCaAAAAAA==.',['强效']='强效萨满精华:BAAAKgAECggICAAAAA==.',['彩色']='彩色小恐龙:BAAAKgAECggIDgAAAA==.',['彩虹']='彩虹捕手:BAAAKgAECgEIAQAAAA==.',['得不']='得不掉就毁到:BAAAKgADCggICAAAAA==.',['微笑']='微笑的泰蕾紗:BAABKgAFFH8GAAIYAAYIsxVXBgBYAQAYAAYIsxVXBgBYAQAAAA==.',['心如']='心如冰雪:BAAAKgAECggIEAAAAA==.',['心火']='心火炽烈:BAABKgAFFH8MAAMgAAcI5ReOAwDsAAAgAAUINxOOAwDsAAAcAAIIhQHZHABsAAAAAA==.',['忧丶']='忧丶迪安:BAAAKgADCgUIBQAAAA==.',['快来']='快来摸我蛋蛋:BAAAKgAECgQIBAAAAA==.',['怒之']='怒之鬼眼:BAAAKgAECggIBwAAAA==.',['恶灵']='恶灵噬魂:BAABKgAFFH8IAAMZAAQI7BNxGgBJAQAZAAQI7BNxGgBJAQAYAAQIYgS/GwDEAAAAAA==.',['恶魔']='恶魔的猫猫:BAAAKgAECggICQAAAA==.',['想你']='想你的腋:BAAAKgAECgcICgAAAA==.',['感观']='感观先生:BAAAKgAFFAMIAwAAAA==.',['慎独']='慎独:BAAAKgAFFAEIAQAAAA==.',['慕鸢']='慕鸢丶:BAAAKgAECgcIDQAAAA==.',['我卖']='我卖萌你杀敌:BAAAKgAECgUIBQAAAA==.',['我将']='我将点燃大海:BAAAKgAECgEIAQAAAA==.',['我是']='我是一个保安:BAABKgAFFH8GAAMLAAYITx2sFgCTAAAMAAQIzh7qJgDVAAALAAIIEBusFgCTAAABKgAFFAgIDAAXAMkiAA==.我是来拉矢的:BAABKgAFFH8KAAMGAAYI2hW7FgBCAQAGAAYIHBK7FgBCAQAKAAQIXhHDNACgAAAAAA==.我是自然守护:BAAAKgAECgcIDAAAAA==.',['我有']='我有玉玉症:BAAAKgAECgcICgAAAA==.',['我的']='我的精灵:BAABKgAFFH8IAAIhAAgI0hCpAgAMAgAhAAgI0hCpAgAMAgAAAA==.',['我脑']='我脑子扔家了:BAAAKgAECgQICAAAAA==.',['手可']='手可摘星辰:BAABKgAFFH8WAAICAAQIHAHaDABDAAACAAQIHAHaDABDAAAAAA==.',['打篮']='打篮球的胡僧:BAAAKgAFFAYIBAAAAA==.',['托内']='托内莉可:BAACKgAFFH8jAAIaAAgItRwEBAAfAgAaAAgItRwEBAAfAgAqAAQKfycAAxoACAgdI9AGAPABABoACAgdI9AGAPABACEAAwikIvU0AMEAAAAA.',['托故']='托故改思:BAAAKgAECggIEAAAAA==.',['扯丶']='扯丶:BAAAKgAECgIIAgAAAA==.',['抖擞']='抖擞:BAAAKgADCgQIBwAAAA==.',['换日']='换日:BAAAKgADCggICAAAAA==.',['放僧']='放僧萝卜:BAABKgAFFH8FAAITAAQI0QdDLgCMAAATAAQI0QdDLgCMAAABKgAFFAgIDgASAIUYAA==.',['斩杀']='斩杀者:BAAAKgAECgIIAgAAAA==.',['时尚']='时尚的滑板鞋:BAABKgAFFH8LAAMOAAYI1xeXAgCtAQAOAAYI1xeXAgCtAQAiAAQIdhVYCwDVAAAAAA==.',['时间']='时间不是解药:BAAAKgAECgYIBgAAAA==.',['星陨']='星陨:BAACKgAFFH8oAAIGAAcIxRKZDQBYAQAGAAcIxRKZDQBYAQAqAAQKfy4AAgYACAjcH7o4ABMCAAYACAjcH7o4ABMCAAAA.',['是墓']='是墓尸:BAAAKgAFFAMIAwABKgAFFAMICwAUAPobAA==.',['晨光']='晨光之惊叹:BAAAKgAECgIIAgAAAA==.',['普通']='普通小栗:BAAAKgAFFAEIAQAAAA==.',['暗夜']='暗夜祭司:BAAAKgADCgIIAgAAAA==.',['暗影']='暗影之主:BAAAKgAECgEIAQAAAA==.暗影老八:BAAAKgADCggICAAAAA==.',['暮色']='暮色钻石:BAAAKgADCgcIBwAAAA==.',['月光']='月光之惊叹:BAAAKgAECggICAAAAA==.',['月华']='月华如练:BAAAKgAFFAQIBAABKgAFFAgIBAAQAAAAAA==.',['月岛']='月岛雯:BAAAKgAFFAgIBAAAAA==.月岛青莲:BAAAKgAFFAIIAwAAAA==.',['月火']='月火:BAAAKgADCggICAAAAA==.',['有一']='有一场梦:BAAAKgAFFAQIBAAAAA==.',['有事']='有事请上坟:BAABKgAFFH8MAAMZAAQI/yGsDQAfAQAZAAQI/yGsDQAfAQAYAAQItQE7LwBSAAAAAA==.',['有种']='有种痛叫等待:BAAAKgADCgYIBgAAAA==.',['有草']='有草就行:BAAAKgADCgIIAgAAAA==.',['朝凪']='朝凪:BAAAKgAECgMIBAAAAA==.',['朴老']='朴老师:BAAAKgADCgMIAwAAAA==.',['李丨']='李丨寻雨:BAAAKgADCgcIBwAAAA==.',['杖一']='杖一抬死一排:BAAAKgAECgEIAQAAAA==.',['杰杰']='杰杰你杰杰:BAAAKgAECgIIAgAAAA==.',['枕骨']='枕骨大孔:BAABKgAFFH8GAAIPAAYIJhIfDgBwAQAPAAYIJhIfDgBwAQAAAA==.',['枪与']='枪与玫瑰:BAABKgAFFH8PAAIPAAMIhhGQEgDZAAAPAAMIhhGQEgDZAAAAAA==.',['枫芯']='枫芯:BAACKgAFFH8LAAMIAAYIchOLCQDiAAAUAAYIwhFtFABBAQAIAAQIhRaLCQDiAAAqAAQKfxQAAggACAj4GGYXAPwBAAgACAj4GGYXAPwBAAAA.',['柚子']='柚子:BAABKgAECn8cAAMTAAgI9xOcLQCOAQATAAgIbxGcLQCOAQARAAgIeg9NMQBeAQAAAA==.',['柴五']='柴五麻子:BAABKgAFFH8IAAIhAAgIkAcYBAC7AQAhAAgIkAcYBAC7AQAAAA==.',['柴四']='柴四麻子:BAABKgAFFH8HAAIEAAQISRB0EwDXAAAEAAQISRB0EwDXAAAAAA==.',['栀晨']='栀晨:BAAAKgADCggICAAAAA==.',['桔梗']='桔梗仙冬月:BAAAKgAECgIIAgAAAA==.',['梅迪']='梅迪恩:BAAAKgAECggIDgAAAA==.',['梦兮']='梦兮绘笔谈:BAACKgAFFH8NAAMSAAMIlAxBHACiAAASAAMIlAxBHACiAAARAAEIZBdBMgA/AAAqAAQKfzQAAxIACAgzHqscAPEBABIABwgDHascAPEBABMACAi3HTghANcBAAAA.',['梦想']='梦想抓个德:BAAAKgAFFAYIAgAAAA==.',['梦比']='梦比的保镖:BAAAKgADCggICAAAAA==.梦比的医生:BAAAKgAECgIIAgAAAA==.梦比的宠物:BAAAKgADCgEIAQAAAA==.',['椒盐']='椒盐酸萝卜:BAAAKgAECgYIBgAAAA==.',['榆树']='榆树街的噩梦:BAABKgAFFH8FAAIFAAQIvhHZCwDkAAAFAAQIvhHZCwDkAAAAAA==.',['横竖']='横竖横:BAABKgAFFH8GAAIYAAYIUgZnHAC/AAAYAAYIUgZnHAC/AAABKgAFFAgIBgAYABkJAA==.',['樱丶']='樱丶散落:BAAAKgAECgUIBQAAAA==.',['橙子']='橙子丶:BAAAKgAECgEIAQAAAA==.',['橙熟']='橙熟:BAAAKgADCgYIBgAAAA==.',['橴汌']='橴汌傷:BAAAKgAECggICAAAAA==.',['欢喜']='欢喜的蓝猫:BAAAKgAFFAYIBAAAAA==.',['欧若']='欧若拉:BAABKgAFFH8MAAMhAAYIKQZfAQBaAQAhAAYIKQZfAQBaAQAaAAYI+ha4CgBOAQAAAA==.',['歐陽']='歐陽婉唲:BAAAKgAECggICAAAAA==.',['止战']='止战:BAABKgAFFH8NAAMPAAYI3RcwCgCqAQAPAAYI3RcwCgCqAQADAAIIKgQLIQCJAAAAAA==.',['正气']='正气水:BAACKgAFFH8fAAIGAAYIWh4GCQDkAQAGAAYIWh4GCQDkAQAqAAQKfzsAAgYACAirJIQKAN4CAAYACAirJIQKAN4CAAAA.',['步布']='步布不可以:BAACKgAFFH8FAAIYAAIIphjFFwCTAAAYAAIIphjFFwCTAAAqAAQKfysAAhgACAhZHaEOAEYCABgACAhZHaEOAEYCAAAA.',['死亡']='死亡丨绿皮:BAABKgAECn8YAAMGAAgIwxiMWACnAQAGAAgIwxiMWACnAQAKAAMI+AuUbQB7AAAAAA==.',['死骑']='死骑大姨妈:BAAAKgAFFAEIAQAAAA==.',['殘乄']='殘乄神:BAAAKgADCgQIBAAAAA==.',['殤骑']='殤骑:BAAAKgAFFAQIBAAAAA==.',['气势']='气势非常到位:BAAAKgAECggICAAAAA==.',['水师']='水师提督之子:BAABKgAFFH8GAAIbAAYISQmdEwALAQAbAAYISQmdEwALAQAAAA==.',['水银']='水银灯里:BAAAKgAFFAYIAwABKgAFFAgIBgAYABkJAA==.',['永恒']='永恒黎明:BAAAKgAFFAMIAwAAAA==.',['汉库']='汉库克:BAABKgAFFH8IAAIBAAQI9h/QNQATAQABAAQI9h/QNQATAQABKgAFFAgIBAAQAAAAAA==.',['汗水']='汗水与幽默:BAAAKgAFFAIIAgAAAA==.',['沧阑']='沧阑:BAAAKgAECggIEQAAAA==.',['河原']='河原木桃香:BAABKgAECn8XAAMYAAgIQBmYFQD0AQAYAAgI/hiYFQD0AQAZAAgISA7wWwBTAQAAAA==.',['法老']='法老耍好:BAAAKgAECgEIAgAAAA==.法老耍宝:BAAAKgAECgYIBgAAAA==.法老耍跳:BAAAKgAECgcICgAAAA==.',['泪丨']='泪丨影:BAAAKgADCggICAAAAA==.',['洅绪']='洅绪倩缘:BAAAKgADCggICAAAAA==.',['洛里']='洛里兹:BAAAKgAFFAIIAgAAAA==.',['浪客']='浪客猎心:BAAAKgAFFAEIAQAAAA==.',['海拉']='海拉鲁可口岩:BAABKgAECn8dAAIBAAgIcRfuGQDxAQABAAgIcRfuGQDxAQAAAA==.',['淡如']='淡如清水:BAAAKgAFFAgIBAAAAA==.',['淡定']='淡定从容:BAABKgAFFH8PAAIUAAgIASCrAgCcAgAUAAgIASCrAgCcAgAAAA==.',['清浊']='清浊丶:BAAAKgADCgUIBQAAAA==.',['渔樵']='渔樵问答:BAAAKgAECgQIBwAAAA==.',['溫蕾']='溫蕾萨:BAABKgAFFH8MAAIKAAQIlxwEIwDkAAAKAAQIlxwEIwDkAAAAAA==.',['滑蹓']='滑蹓蹓:BAAAKgAECgQIBwAAAA==.',['滚筒']='滚筒洗衣机丶:BAAAKgAECggICAAAAA==.',['潇潇']='潇潇雨:BAAAKgAECgQIBwAAAA==.',['激进']='激进的软泥乖:BAACKgAFFH8FAAMBAAMICA2KNACPAAABAAIIeBGKNACPAAAhAAEInABJHgArAAAqAAQKfxsAAwEACAhtHe0SADYCAAEACAhtHe0SADYCACEAAggSC4lLAFYAAAAA.',['灬愿']='灬愿望灬:BAABKgAFFH8GAAIYAAYI0AJcDQCjAAAYAAYI0AJcDQCjAAAAAA==.',['灬残']='灬残月:BAABKgAFFH8IAAIMAAgI0BKYCgDiAQAMAAgI0BKYCgDiAQAAAA==.',['灬賊']='灬賊贼灬:BAAAKgADCgEIAQAAAA==.',['灬龍']='灬龍影:BAAAKgAECggICAAAAA==.',['灵丶']='灵丶:BAAAKgAECggICAABKgAFFAgIEgAFADAgAA==.',['灵动']='灵动死亡:BAAAKgAECgcIBwABKgAFFAgIBAAQAAAAAA==.',['灵魂']='灵魂的觉醒:BAAAKgAECggIEAAAAA==.',['点鼠']='点鼠标:BAAAKgAECgMIAwAAAA==.',['炽宴']='炽宴丶:BAABKgAFFH8GAAIJAAYIQxp0DgCcAQAJAAYIQxp0DgCcAQABKgAFFAgIGgAGAKUbAA==.',['烟灬']='烟灬圈:BAABKgAFFH8GAAIBAAYICyOOEADbAQABAAYICyOOEADbAQAAAA==.',['烧卖']='烧卖头子:BAAAKgAECgUIBQAAAA==.',['熊猫']='熊猫胖乎乎丶:BAABKgAECn8cAAIeAAgIfRL8DABpAQAeAAgIfRL8DABpAQABKgAFFAgIGgAZAEwhAA==.',['爱婧']='爱婧:BAAAKgAECggICAAAAA==.',['爱已']='爱已成伤:BAAAKgAFFAgIBAAAAA==.',['爱的']='爱的喷射鸡:BAAAKgAFFAQIBAAAAA==.',['爱笑']='爱笑的小米:BAAAKgADCggIDgAAAA==.',['牛丶']='牛丶牪丶犇:BAACKgAFFH8IAAIjAAII8QjbBQBPAAAjAAII8QjbBQBPAAAqAAQKfykAAyMACAjXG6UQAEEBAA4ABwg+HKBDAKcBACMACAgkEKUQAEEBAAAA.',['牛德']='牛德德:BAABKgAFFH8GAAIiAAYI9hPKCgBZAQAiAAYI9hPKCgBZAQAAAA==.',['牛牛']='牛牛推车:BAAAKgAECgYICQAAAA==.',['物尽']='物尽天择:BAACKgAFFH8WAAMCAAMIywpKDwCFAAACAAMIywpKDwCFAAAPAAIIHQFfOAA+AAAqAAQKfykABAIACAgIESUgAAEBAAIACAgIESUgAAEBAA8ABwg2ChhNANsAAAMAAQinB+JfAC4AAAAA.',['狂奔']='狂奔的白白本:BAAAKgAFFAIIAgAAAA==.',['狂暴']='狂暴的锤子:BAAAKgADCgUIBQAAAA==.',['狙翎']='狙翎:BAAAKgAECgIIAgAAAA==.',['猛地']='猛地给你七下:BAAAKgAECgMIAwAAAA==.',['玉玉']='玉玉症好了:BAAAKgAECgIIAgAAAA==.',['玖寳']='玖寳児:BAAAKgAFFAgIAgAAAA==.',['玛尔']='玛尔加尼斯:BAAAKgADCgEIAQAAAA==.',['珠玉']='珠玉:BAABKgAFFH8IAAIKAAgIGQRECwBbAQAKAAgIGQRECwBbAQAAAA==.',['琦琦']='琦琦小朋友:BAAAKgAECgcIDgAAAA==.',['琴岛']='琴岛龙之子:BAAAKgAECggIDwAAAA==.',['瓶中']='瓶中信仰:BAAAKgAECgcIDgAAAA==.',['甜心']='甜心包菜:BAAAKgADCggICAAAAA==.',['画斗']='画斗:BAAAKgAFFAgIBAAAAA==.',['疯狂']='疯狂的术虱:BAAAKgAECgMIAwAAAA==.',['痛苦']='痛苦湮灭:BAAAKgADCgUIBQAAAA==.',['白白']='白白空:BAAAKgAFFAQIBAAAAA==.白白胖胖丶:BAAAKgAECgEIAQAAAA==.',['白練']='白練秋:BAAAKgADCgEIAQAAAA==.',['白色']='白色纽扣:BAAAKgAECggIDwAAAA==.',['白鲸']='白鲸丨:BAABKgAFFH8IAAMOAAYI7g7dGwA7AQAOAAYI7g7dGwA7AQAiAAIIGQWlKACCAAAAAA==.白鲸氵:BAABKgAFFH8IAAQSAAgInQ3kEwDeAAASAAMImAvkEwDeAAARAAQIjwQCFwCoAAATAAEI8wWNPgA/AAAAAA==.',['百变']='百变灬:BAABKgAFFH8RAAIiAAcIORCUBwAyAQAiAAcIORCUBwAyAQAAAA==.',['百思']='百思不得其姐:BAAAKgAECggIDgAAAA==.',['皮蛋']='皮蛋:BAAAKgAECgUIDAAAAA==.皮蛋廋肉粥:BAAAKgAFFAEIAQAAAA==.',['盐语']='盐语糖:BAABKgAECn8UAAIBAAgISCLULABsAgABAAgISCLULABsAgAAAA==.',['盒子']='盒子圣骑:BAAAKgAFFAEIAQAAAA==.',['盖世']='盖世牧:BAAAKgAECgMIAwAAAA==.',['眼界']='眼界唔准:BAAAKgADCgEIAQAAAA==.',['知彼']='知彼知己:BAACKgAFFH8GAAMEAAYISg/ONgCkAAAEAAQIJAPONgCkAAAdAAIIqguQIAB5AAAqAAQKfzsAAx0ACAgsIecJAKYCAB0ACAgsIecJAKYCAAQACAgLHEgkAPIBAAAA.',['硬得']='硬得可怕:BAAAKgADCggICAAAAA==.',['祝踏']='祝踏喵:BAAAKgADCggICAAAAA==.',['福义']='福义飞飞:BAAAKgADCggICAAAAA==.',['福将']='福将:BAACKgAFFH8FAAIBAAMIZxlPVwDCAAABAAMIZxlPVwDCAAAqAAQKfy8AAgEACAhiJAwKAPICAAEACAhiJAwKAPICAAAA.',['秋月']='秋月春风:BAABKgAFFH8YAAIBAAgIAxxVBQBxAgABAAgIAxxVBQBxAgAAAA==.',['程熠']='程熠熠:BAAAKgAECgMIBAAAAA==.',['稳牛']='稳牛:BAACKgAFFH8GAAIaAAMIUxE6EgBzAAAaAAMIUxE6EgBzAAAqAAQKfx0AAxoACAj7GUoQAAoCABoACAj7GUoQAAoCAAEAAQicA/6RARUAAAAA.',['空丶']='空丶白:BAAAKgAECggICwAAAA==.',['空白']='空白丶:BAABKgAFFH8SAAMFAAgIMCAfAAC0AgAFAAgIMCAfAAC0AgAVAAQIlBtuBgD9AAAAAA==.',['穿锁']='穿锁甲的电工:BAAAKgAFFAIIAgAAAA==.',['突然']='突然变了:BAAAKgAFFAYIAgAAAA==.突然变龍:BAABKgAFFH8GAAIcAAYIyAl3FgAWAQAcAAYIyAl3FgAWAQAAAA==.突然圣光:BAAAKgAFFAYIAQAAAA==.突然肥了:BAAAKgAFFAMIAwAAAA==.突然飙起:BAABKgAFFH8GAAIIAAYIehMlBQBlAQAIAAYIehMlBQBlAQAAAA==.',['窥视']='窥视狂:BAAAKgAECgYIBgAAAA==.',['等猪']='等猪撞小树:BAAAKgAFFAgIAgAAAA==.',['等等']='等等我:BAAAKgAECgUIBQAAAA==.',['简单']='简单不简单:BAAAKgAFFAIIAgAAAA==.',['糊糊']='糊糊宝宝:BAAAKgAECgIIAgAAAA==.',['紫苏']='紫苏炒花甲:BAAAKgAFFAMIAQAAAA==.',['红星']='红星:BAABKgAFFH8FAAIJAAQIexMGFQDtAAAJAAQIexMGFQDtAAAAAA==.红星漫山:BAABKgAFFH8IAAIZAAgIahYiBABMAgAZAAgIahYiBABMAgAAAA==.',['红桔']='红桔梗空棒:BAAAKgAECgQIBAAAAA==.',['约吗']='约吗:BAAAKgAECggICAAAAA==.',['约翰']='约翰雪豹:BAAAKgAFFAYIBAABKgAFFAgIAgAQAAAAAA==.',['纯情']='纯情女大:BAAAKgADCggICAAAAA==.',['纳克']='纳克印痕:BAABKgAECn8oAAIEAAgIEBiqLADJAQAEAAgIEBiqLADJAQAAAA==.',['纳兰']='纳兰迦:BAAAKgAECgMIAwAAAA==.',['纹身']='纹身小妹:BAAAKgAECgQIBAAAAA==.',['细雨']='细雨亲香腮:BAAAKgAECgIIAwAAAA==.',['织光']='织光丶:BAABKgAFFH8OAAMRAAYIyh8RCAAZAQARAAUIqR4RCAAZAQASAAIIoR1PHQCbAAAAAA==.',['群星']='群星之怒:BAABKgAFFH8MAAIKAAYI2yEFCQDIAQAKAAYI2yEFCQDIAQAAAA==.',['老男']='老男孩:BAAAKgAECggICwAAAA==.',['耐信']='耐信:BAAAKgAFFAQIAwAAAA==.',['肉宝']='肉宝肉肉:BAAAKgADCgEIAQAAAA==.',['肌肉']='肌肉丶达人:BAAAKgAECggIDgAAAA==.',['肌霸']='肌霸戰士:BAAAKgADCggICAAAAA==.',['肥大']='肥大民:BAABKgAECn8oAAILAAgIzhuJBAAkAgALAAgIzhuJBAAkAgAAAA==.',['舒茉']='舒茉:BAACKgAFFH8RAAIYAAQIahszDADgAAAYAAQIahszDADgAAAqAAQKfx4AAhgACAgQIEwMAGQCABgACAgQIEwMAGQCAAEqAAUUCAgjABoAtRwA.',['艾丽']='艾丽莎:BAABKgAFFH8IAAIEAAgIlw7bBgDdAQAEAAgIlw7bBgDdAQAAAA==.',['艾力']='艾力克:BAAAKgADCgYIBgAAAA==.',['艾莉']='艾莉希娅:BAAAKgAECgEIAQAAAA==.',['芋泥']='芋泥贝果:BAABKgAFFH8HAAISAAUIwguiCAAfAQASAAUIwguiCAAfAQABKgAFFAgIBgATAKsLAA==.',['芝士']='芝士土虫:BAAAKgAECgIIAgAAAA==.',['芯茹']='芯茹花木:BAAAKgAECggIEwAAAA==.',['英仙']='英仙座丶:BAABKgAECn8/AgIEAAgIHyNICgCjAgAEAAgIHyNICgCjAgAAAA==.',['草喵']='草喵喵:BAACKgAFFH8SAAMRAAQI6RTEDgDhAAARAAQI6RTEDgDhAAATAAMIhg7mJwCiAAAqAAQKfxYAAxMACAhgDtZQAPUAABMACAhKDdZQAPUAABEABQgZB+FsAH8AAAAA.',['草莓']='草莓:BAAAKgAECggICwAAAA==.',['莉冬']='莉冬:BAAAKgAECgIIAgAAAA==.',['菜徐']='菜徐坤:BAAAKgADCgUIBQAAAA==.',['菩萨']='菩萨哥:BAABKgAFFH8IAAIZAAgIDxOoBgDwAQAZAAgIDxOoBgDwAQAAAA==.',['萌兰']='萌兰:BAAAKgAECgUIBQAAAA==.',['萨暗']='萨暗的萨:BAABKgAFFH8KAAMEAAQIHxOhDQDwAAAEAAQIHxOhDQDwAAAkAAQI7BECEwC/AAAAAA==.',['萨满']='萨满强哥:BAAAKgADCgMIAwAAAA==.',['董大']='董大胖:BAAAKgAECgUICQAAAA==.',['葬铭']='葬铭:BAAAKgAECgIIAgAAAA==.',['蒲牢']='蒲牢丶:BAABKgAFFH8GAAIOAAYIjB80AQDkAQAOAAYIjB80AQDkAQAAAA==.',['蔡大']='蔡大宝:BAAAKgADCggICAAAAA==.',['蕾娜']='蕾娜莉亚:BAACKgAFFH8ZAAIRAAQIWx3TCwD2AAARAAQIWx3TCwD2AAAqAAQKf0QAAhEACAj3JHIFAL0CABEACAj3JHIFAL0CAAAA.',['虎牙']='虎牙吖吖:BAAAKgADCgEIAQAAAA==.',['虎虎']='虎虎嘿嘿:BAAAKgADCgQIBAAAAA==.虎虎奔奔:BAAAKgAECgEIAQAAAA==.虎虎犇犇:BAAAKgADCgcIBAAAAA==.',['蛋疼']='蛋疼骑士:BAAAKgADCggICAAAAA==.',['蟋蟀']='蟋蟀的哥哥:BAACKgAFFH8RAAMlAAMIAQ4xAwDDAAAlAAMIAQ4xAwDDAAAGAAMIygUfQwCTAAAqAAQKfxgAAyUABwgvE+ANAPwAAAYABwh0DqOQAAsBACUABQhWFuANAPwAAAAA.',['西山']='西山吹雪:BAAAKgAECgUIBQAAAA==.',['西格']='西格玛男人:BAAAKgAECgMIAwAAAA==.',['西楼']='西楼梦影:BAAAKgAECgYIBwAAAA==.',['西门']='西门吹雪男:BAAAKgAECgEIAQAAAA==.',['詮釋']='詮釋神話:BAABKgAFFH8HAAIFAAQI6RM/CwDrAAAFAAQI6RM/CwDrAAAAAA==.',['詹尼']='詹尼丶:BAACKgAFFH8IAAMGAAQIvCO8HwDZAAAKAAQIvCNkIQDuAAAGAAQI4hS8HwDZAAAqAAQKfxoAAgoACAjVGZcdAOUBAAoACAjVGZcdAOUBAAEqAAUUCAgIAAoAGQQA.',['誷事']='誷事如风:BAABKgAFFH8OAAINAAMIiwZKGwB5AAANAAMIiwZKGwB5AAAAAA==.',['试墨']='试墨临池:BAAAKgAECggIEQAAAA==.',['诶滴']='诶滴盖奶:BAAAKgAFFAgIAwAAAA==.',['谁言']='谁言玉非尘:BAAAKgADCggICAAAAA==.',['豆豆']='豆豆丶:BAABKgAFFH8GAAMKAAMIqAsQNACiAAAKAAMIqAsQNACiAAAGAAEIOw1fXgA6AAAAAA==.',['貝貝']='貝貝丶:BAABKgAFFH8IAAIiAAgIVQGqDgArAQAiAAgIVQGqDgArAQAAAA==.',['贝尔']='贝尔摩德:BAAAKgADCggICAAAAA==.',['贪欲']='贪欲狂:BAAAKgAECgIIAgAAAA==.',['赤座']='赤座燈裡:BAABKgAFFH8GAAIBAAMI8xmoIQDgAAABAAMI8xmoIQDgAAABKgAFFAgICQARAPceAA==.',['赫卡']='赫卡蒂:BAAAKgADCgIIAgAAAA==.',['走过']='走过孤独:BAABKgAFFH8GAAMgAAYI+xasAABnAQAgAAUInRmsAABnAQAcAAEILhR0HQBbAAAAAA==.',['赵子']='赵子龙:BAAAKgAECgIIAgAAAA==.',['起舞']='起舞枫林间:BAAAKgAECgMIAwAAAA==.',['超屁']='超屁:BAABKgAECn8eAAIPAAgICyQCBgDVAgAPAAgICyQCBgDVAgAAAA==.',['超级']='超级大笨蛋:BAABKgAFFH8GAAIaAAMIThyhBgD6AAAaAAMIThyhBgD6AAAAAA==.超级小能:BAAAKgAECggIDgAAAA==.',['跟踪']='跟踪狂:BAAAKgAECgYIBgAAAA==.',['踋鮣']='踋鮣:BAAAKgAECggICAAAAA==.',['轻烟']='轻烟薄暮:BAAAKgAFFAEIAQAAAA==.',['过期']='过期南瓜:BAABKgAFFH8GAAIZAAYIchmoDwCiAQAZAAYIchmoDwCiAQAAAA==.',['还我']='还我漂漂拳:BAACKgAFFH8GAAIbAAYIowxsEQAfAQAbAAYIowxsEQAfAQAqAAQKfxQAAhsACAhbF5ceAJQBABsACAhbF5ceAJQBAAAA.',['进击']='进击的绯皇:BAAAKgAECgIIAgAAAA==.',['进发']='进发主宇宙:BAAAKgAECgYIBwAAAA==.',['迷路']='迷路的胖墩:BAAAKgAECgUICQAAAA==.',['追憶']='追憶残骸:BAABKgAFFH8LAAMZAAQIrxPWMwDHAAAZAAQIrxPWMwDHAAAYAAQIDQhKKQBxAAAAAA==.',['逗逼']='逗逼德:BAABKgAFFH8QAAMOAAgI9R8YBQBWAQAOAAcIVSMYBQBWAQAiAAEI1BSiMwBKAAAAAA==.',['遐想']='遐想狂:BAAAKgAECgYIBgAAAA==.',['那各']='那各法湿:BAABKgAFFH8FAAIBAAQIrSUKBgBSAQABAAQIrSUKBgBSAQAAAA==.',['郑秀']='郑秀晶:BAAAKgADCgcIBwAAAA==.',['部落']='部落兽灵:BAAAKgAECgMIAwAAAA==.',['酥酥']='酥酥:BAAAKgAECggIEQAAAA==.',['醉德']='醉德逸:BAAAKgAECgIIAgAAAA==.',['醒来']='醒来一箭入魂:BAAAKgAECgEIAQAAAA==.醒来就吃土:BAAAKgADCggICwAAAA==.',['野生']='野生肯泰罗:BAABKgAFFH8QAAIDAAYItx+kBQDPAQADAAYItx+kBQDPAQAAAA==.',['野菊']='野菊花:BAAAKgADCgMIAwAAAA==.',['钵兰']='钵兰街十三妹:BAACKgAFFH8aAAIBAAUImRQ+GgD2AAABAAUImRQ+GgD2AAAqAAQKfy0AAgEACAjrILQiAI8CAAEACAjrILQiAI8CAAAA.',['铭刻']='铭刻星光:BAAAKgAECgQIBAAAAA==.',['镜花']='镜花水月灬灬:BAAAKgAECggIBQAAAA==.',['開襠']='開襠褲:BAAAKgAECgYIBgAAAA==.',['闪光']='闪光的拉内特:BAAAKgAECgMIAwAAAA==.',['闲云']='闲云晓牧:BAABKgAECn8cAAITAAgInhc0IgC1AQATAAgInhc0IgC1AQABKgAECggIHwAKAE0gAA==.',['闲听']='闲听落花:BAAAKgADCggIDQAAAA==.',['闹丶']='闹丶:BAAAKgADCggICAAAAA==.',['阿姆']='阿姆的:BAABKgAFFH8GAAIGAAYIyRxWCwC5AQAGAAYIyRxWCwC5AQAAAA==.',['阿昆']='阿昆达:BAAAKgAECggICAAAAA==.',['雪豹']='雪豹闭嘴:BAABKgAFFH8GAAIPAAYIGCZkBgAIAgAPAAYIGCZkBgAIAgAAAA==.',['雪风']='雪风妖精:BAAAKgAECggIEAAAAA==.',['霝灬']='霝灬:BAAAKgAECggICAAAAA==.',['靈魂']='靈魂独舞:BAAAKgAECgYIBgAAAA==.',['青瓷']='青瓷白画殇:BAAAKgAECgYIBwAAAA==.',['风向']='风向逆转:BAAAKgADCgEIAQAAAA==.',['风拳']='风拳:BAAAKgADCgcICAAAAA==.',['风永']='风永远的使徒:BAAAKgAECgIIAwAAAA==.',['馒头']='馒头墩儿:BAACKgAFFH8LAAMJAAQItyQVGAA7AQAJAAQItyQVGAA7AQANAAEIyAtHGgA0AAAqAAQKfxoAAwkACAiGI+YXAEICAAkACAiGI+YXAEICAA0ACAhZFGseAJABAAAA.',['香艳']='香艳的野:BAABKgAFFH8IAAIbAAgI6whxBwCFAQAbAAgI6whxBwCFAQAAAA==.',['骑士']='骑士小强:BAAAKgADCggIEAAAAA==.',['骑牛']='骑牛跑世界:BAAAKgAECggICgAAAA==.',['骷髅']='骷髅:BAABKgAECn8YAAIJAAgIJxsIHgATAgAJAAgIJxsIHgATAgAAAA==.',['高山']='高山云清:BAAAKgADCgYIBgAAAA==.',['高文']='高文:BAAAKgAECggIAwAAAA==.',['鬼怪']='鬼怪之盗:BAABKgAFFH8KAAIFAAgIhxZBBgAiAgAFAAgIhxZBBgAiAgAAAA==.',['魂佑']='魂佑:BAAAKgADCggIEAAAAA==.',['魂曲']='魂曲:BAAAKgADCggIDAAAAA==.',['魔界']='魔界法王:BAAAKgAECgUIBQAAAA==.',['鹤爺']='鹤爺:BAAAKgADCgIIAgAAAA==.',['鹤鹤']='鹤鹤:BAAAKgAECgEIAQAAAA==.',['鹿小']='鹿小咪:BAABKgAFFH8LAAIEAAMIGQuFOACgAAAEAAMIGQuFOACgAAAAAA==.鹿小心:BAAAKgAECgUIBQAAAA==.',['麦克']='麦克白:BAAAKgAECgEIAQAAAA==.',['黑皮']='黑皮体育生:BAAAKgADCgMIAwAAAA==.',['黑锋']='黑锋骑士:BAAAKgAECgIIAgAAAA==.',['齐得']='齐得隆冬呛:BAAAKgADCggICAAAAA==.',['龍影']='龍影灬:BAAAKgAFFAgIBAAAAA==.',['龍武']='龍武聖域:BAAAKgAECggICAAAAA==.',['龙与']='龙与虎:BAAAKgAECggICAAAAA==.',['龙之']='龙之骄子:BAAAKgAECggICwAAAA==.',['龙啸']='龙啸圣骑:BAAAKgAFFAQIBAAAAA==.',['龙西']='龙西:BAABKgAFFH8JAAMOAAQI1h6AFgDiAAAOAAQI1h6AFgDiAAAiAAEIAAC7PQAAAAAAAA==.',['龙马']='龙马:BAAAKgAECgUIBQAAAA==.',['龙魂']='龙魂镇九州:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end