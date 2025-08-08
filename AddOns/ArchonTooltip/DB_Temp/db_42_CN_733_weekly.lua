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
 local lookup = {'Priest-Holy','Priest-Discipline','Shaman-Restoration','Shaman-Enhancement','Paladin-Retribution','Warlock-Destruction','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Mage-Fire','Mage-Frost','DeathKnight-Unholy','Druid-Restoration','Warrior-Fury','Mage-Arcane','Warlock-Demonology','Shaman-Elemental','Unknown-Unknown','Paladin-Holy','Paladin-Protection','Priest-Shadow','Druid-Balance','Evoker-Devastation','Warrior-Arms','Monk-Windwalker','Rogue-Assassination','Rogue-Subtlety','Warlock-Affliction','DemonHunter-Havoc','Monk-Mistweaver','Monk-Brewmaster','DemonHunter-Vengeance','Rogue-Melee','Rogue-Outlaw','Hunter-Survival','Warrior-Protection','Druid-Feral',}; local provider = {region='CN',realm='海加尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Accuracysiyi:BAAAKgAECgIIAgAAAA==.',Ap='Apacky:BAAAKgAECgEIAQAAAA==.',Bl='Blackdh:BAAAKgAECgYICQAAAA==.Blackdk:BAAAKgAECggIEAAAAA==.Blackhorseq:BAAAKgAECgcIDwAAAA==.Blackmonk:BAAAKgAECgUIBQAAAA==.Blackq:BAABKgAECn8UAAMBAAgINxNQKQCIAQABAAgINxNQKQCIAQACAAIIgAh9dABGAAAAAA==.Blackshaman:BAABKgAECn8wAAMDAAgI1B0iJADzAQADAAgI1B0iJADzAQAEAAYIhRKeIwAzAQAAAA==.Blackss:BAAAKgAECggICgAAAA==.',Ca='Calmity:BAABKgAFFH8OAAIFAAYI9B6lBwBAAQAFAAYI9B6lBwBAAQAAAA==.Carrycarrie:BAABKgAFFH8FAAIGAAQIWiB7JwDSAAAGAAQIWiB7JwDSAAAAAA==.',Ch='Chan:BAABKgAECn8dAAIBAAgIpR8MFQAbAgABAAgIpR8MFQAbAgAAAA==.',Co='Combust:BAACKgAFFH8WAAMHAAMIDh+hKACtAAAHAAIIPCChKACtAAAIAAEIsRyPJQBKAAAqAAQKfy8AAwcACAjCIEUdAIICAAcACAjCIEUdAIICAAgABQi+GZM/ACYBAAAA.',Cr='Cryolite:BAAAKgADCggICAAAAA==.',De='Defiantpupil:BAABKgAFFH8GAAIJAAYIKA2JFAD+AAAJAAYIKA2JFAD+AAAAAA==.Demonszzy:BAABKgAFFH8TAAMKAAgIYxQGBgAMAgAKAAgIYxQGBgAMAgALAAEIAADaMAAAAAAAAA==.Deviltears:BAAAKgAECgQIBgAAAA==.',Di='Dioa:BAAAKgAECgIIAgAAAA==.Diox:BAAAKgADCggICAAAAA==.',Do='Domo:BAABKgAFFH8IAAMJAAQIVQk6GwB+AAAMAAQIVQkqPQCpAAAJAAQIhAQ6GwB+AAAAAA==.',Dr='Drama:BAABKgAFFH8MAAINAAgIhQjzCAB5AQANAAgIhQjzCAB5AQAAAA==.',Et='Eternalstar:BAAAKgAECgUIBQAAAA==.',Fi='Fightfouyou:BAAAKgADCgEIAQAAAA==.Fireworm:BAAAKgADCgMIAwAAAA==.',Fo='Foogy:BAAAKgAFFAIIAgAAAA==.',He='Herbivoree:BAAAKgADCggICAAAAA==.',Ho='Holyz:BAACKgAFFH8OAAIBAAMIHx7HFgD/AAABAAMIHx7HFgD/AAAqAAQKfyAAAgEACAgvH1wRADsCAAEACAgvH1wRADsCAAAA.',Hu='Humankeeper:BAAAKgAECgUIBwAAAA==.',Ic='Iceymo:BAABKgAFFH8MAAMHAAYIohyREQBrAQAHAAYI7xmREQBrAQAIAAUINhfuCQD6AAAAAA==.',Ke='Kevinnine:BAAAKgAFFAMIAwAAAA==.',Ku='Kurtie:BAABKgAFFH8IAAIOAAYIXxaFAQDAAQAOAAYIXxaFAQDAAQAAAA==.Kurtlol:BAABKgAFFH8OAAMPAAgIPBsVBABsAgAPAAgIPBsVBABsAgALAAYIuhAECABCAQAAAA==.',La='Lalaguer:BAABKgAFFH8KAAMGAAYIfx+uHAAiAQAGAAUIkB6uHAAiAQAQAAIIOiMCIgBYAAAAAA==.',Li='Lionkk:BAABKgAFFH8IAAIIAAQIESHIBwAJAQAIAAQIESHIBwAJAQAAAA==.',Lo='Lokawesa:BAABKgAFFH8QAAMIAAgIVB2fBwDnAQAIAAgIABqfBwDnAQAHAAQI/RjvFwA7AQAAAA==.Lookmyeyes:BAAAKgAECggIEAABKgAFFAgIDgAMAEoXAA==.',Lp='Lpacky:BAAAKgAECgEIAQAAAA==.',Ma='Magicstar:BAAAKgAECggICAAAAA==.Marcel:BAABKgAFFH8NAAQEAAUIZh/mAQC0AQAEAAUIZh/mAQC0AQADAAQIEB6bHQAGAQARAAQI0xD8CwDPAAABKgAFFAgIBAASAAAAAA==.',Me='Merida:BAAAKgADCgQIBAAAAA==.',Mi='Mightyhunter:BAABKgAECn8YAAIHAAgIuR9UHQBQAgAHAAgIuR9UHQBQAgAAAA==.',Na='Naturesiyi:BAAAKgAECgEIAQAAAA==.',Ni='Nivs:BAAAKgAECgUICAAAAA==.',Ob='Oblivionis:BAACKgAFFH8TAAICAAYI+BplBwCzAQACAAYI+BplBwCzAQAqAAQKfxUAAgIACAh8HzwMAG8CAAIACAh8HzwMAG8CAAAA.',Pa='Packey:BAAAKgAECggICgAAAA==.Packy:BAAAKgAECgcICAAAAA==.Payne:BAAAKgAECgQIBAAAAA==.',Pl='Playeremnqmh:BAAAKgADCggIGAAAAA==.',Pr='Praddo:BAAAKgAFFAQIBAAAAA==.',Re='Rebroken:BAABKgAFFH8NAAMLAAcIOBg+AACwAQAKAAcI1RJ7AgD0AQALAAYIXBY+AACwAQAAAA==.',Ro='Roxette:BAABKgAFFH8MAAMLAAYIshCpCgDZAAALAAQIKRWpCgDZAAAKAAYInA4tHwDZAAAAAA==.',Sa='Sandor:BAAAKgAECgYIDAAAAA==.',Sd='Sdl:BAAAKgADCgUIBQAAAA==.',Se='Senko:BAAAKgAECgcIBAAAAA==.',Sj='Sjach:BAAAKgADCggICAAAAA==.',St='Starfang:BAABKgAFFH8FAAMCAAMIjhquCwD3AAACAAMIjhquCwD3AAABAAII6gIAIABaAAAAAA==.Stavrianos:BAAAKgAFFAQIBAAAAA==.',Sw='Swordartol:BAAAKgAECggIDgAAAA==.',['Sà']='Sàriel:BAAAKgAFFAMIAwAAAA==.',['Sá']='Sáriel:BAAAKgAECgcIEwAAAA==.',Ts='Tshadows:BAAAKgAECggICAAAAA==.',Vi='Viscum:BAAAKgAFFAIIAgAAAA==.',['一声']='一声再见:BAAAKgAECgcIDQAAAA==.',['一拳']='一拳打鼠你:BAAAKgADCgMIAwAAAA==.',['一瞬']='一瞬之光:BAAAKgAECggIEwAAAA==.',['一级']='一级开始:BAAAKgAECgMIAwAAAA==.',['七月']='七月流火:BAAAKgAECgEIAQAAAA==.',['不变']='不变的回忆:BAAAKgAECggICQAAAA==.',['不灭']='不灭狂灵:BAAAKgAECgcICgAAAA==.',['不要']='不要迷恋四哥:BAAAKgAECgIIAgAAAA==.',['专抢']='专抢小孩棒糖:BAAAKgAFFAMIAwAAAA==.',['专注']='专注蜀黍:BAABKgAECn8aAAMFAAgIRiYmBwAAAwAFAAgIRiYmBwAAAwATAAgISQhDJQA0AQABKgAFFAgIDAAMAPURAA==.',['丘处']='丘处机:BAAAKgADCggICAAAAA==.',['丨当']='丨当:BAAAKgAECggIEwAAAA==.',['丶刺']='丶刺:BAAAKgAECgMIBQAAAA==.',['丶执']='丶执念:BAAAKgADCgIIAgAAAA==.',['丶錵']='丶錵:BAABKgAFFH8IAAIUAAgI8gsECgBcAQAUAAgI8gsECgBcAQAAAA==.',['乃尼']='乃尼梅亞:BAAAKgAECgcICAAAAA==.',['义薄']='义薄云天丶:BAAAKgAFFAEIAQAAAA==.',['九有']='九有钱:BAAAKgAFFAQIBAAAAA==.',['乱战']='乱战蓝娇:BAABKgAECn8VAAIOAAgIexXuKgDdAQAOAAgIexXuKgDdAQAAAA==.',['亡心']='亡心:BAAAKgAECggIDgAAAA==.亡心丨射:BAAAKgADCggICAAAAA==.亡心丨燚:BAAAKgAECgMIBAAAAA==.',['亡者']='亡者荣耀:BAAAKgAFFAIIAgAAAA==.',['伊公']='伊公子乂:BAAAKgADCgcIBwAAAA==.',['你五']='你五岁了吗:BAACKgAFFH8JAAIKAAMIcxKLIQDQAAAKAAMIcxKLIQDQAAAqAAQKfzAAAgoACAiIIjENAKwCAAoACAiIIjENAKwCAAAA.',['你才']='你才是妹子丶:BAAAKgAECgEIAQAAAA==.',['你这']='你这么整是吧:BAABKgAFFH8NAAIMAAcIkBQVCADCAQAMAAcIkBQVCADCAQAAAA==.',['倚崖']='倚崖映斜阳:BAABKgAFFH8GAAIFAAYI+AQmHAAEAQAFAAYI+AQmHAAEAQAAAA==.',['做梦']='做梦国足夺冠:BAAAKgADCggICAAAAA==.',['元元']='元元的晴朗:BAAAKgAECgYIBgABKgAFFAgICAAHAHMNAA==.',['光与']='光与暗的抉择:BAABKgAFFH8RAAQCAAgIqBaUCwD4AAACAAQI+RSUCwD4AAAVAAcIexQaEgDwAAABAAMIIxXIDwDQAAAAAA==.',['光羽']='光羽佳:BAAAKgADCgEIAQAAAA==.',['光芒']='光芒在前:BAAAKgAECgIIAwAAAA==.',['光铸']='光铸艾瑞达:BAAAKgAFFAYIAwAAAA==.',['八神']='八神月姬:BAABKgAFFH8GAAILAAQIyg72GwCiAAALAAQIyg72GwCiAAAAAA==.',['六十']='六十五退休:BAAAKgAECgEIAQAAAA==.',['其实']='其实:BAABKgAFFH8MAAIFAAMIWBMWUwDKAAAFAAMIWBMWUwDKAAAAAA==.',['兽大']='兽大大兽:BAAAKgAECgMIAwAAAA==.',['内牛']='内牛小萨:BAAAKgAECggIEQAAAA==.内牛满面:BAACKgAFFH8LAAIWAAMIxBkjLgDaAAAWAAMIxBkjLgDaAAAqAAQKfxUAAxYACAiwHpYqABYCABYACAiwHpYqABYCAA0AAghtBvWBAD4AAAAA.',['再度']='再度:BAAAKgAFFAQIBAAAAA==.',['冬天']='冬天的罗卜:BAACKgAFFH8FAAIFAAMIwxpEUwDJAAAFAAMIwxpEUwDJAAAqAAQKfzIAAwUACAgAJkMGAAQDAAUACAgAJkMGAAQDABQAAQgRBD1rAA4AAAAA.',['冬暖']='冬暖夏凉:BAAAKgAECgEIAQAAAA==.',['冰城']='冰城之巅:BAAAKgADCgMIAwAAAA==.',['冰封']='冰封的回忆:BAAAKgAFFAIIAgAAAA==.',['冰火']='冰火洗礼:BAAAKgAFFAEIAQAAAA==.',['冰珑']='冰珑如玉:BAAAKgAFFAQIBAAAAA==.',['准备']='准备出发:BAAAKgAFFAcIBAAAAA==.',['凯厄']='凯厄斯:BAABKgAFFH8PAAIFAAMIVBl/RgDhAAAFAAMIVBl/RgDhAAAAAA==.',['凯瑟']='凯瑟琳冰儿:BAABKgAFFH8SAAMKAAgIsBVWBwDhAQAKAAgIXBBWBwDhAQALAAQIrBTcCQDfAAAAAA==.凯瑟琳咒术师:BAABKgAFFH8GAAIGAAYIMhL6EwBmAQAGAAYIMhL6EwBmAQAAAA==.凯瑟琳守护者:BAAAKgAFFAgIAgAAAA==.凯瑟琳游侠:BAABKgAFFH8GAAIHAAYIUQYgHwASAQAHAAYIUQYgHwASAQAAAA==.',['刘小']='刘小猫小妖精:BAAAKgADCgEIAQAAAA==.',['别划']='别划走:BAABKgAFFH8NAAMIAAYIYwjZEADvAAAIAAYIQAjZEADvAAAHAAIIswesKABjAAAAAA==.',['前野']='前野智昭:BAAAKgAECggICAAAAA==.',['动之']='动之九天之辰:BAABKgAFFH8GAAIMAAYIeAqRGgBIAQAMAAYIeAqRGgBIAQAAAA==.',['动于']='动于九天之上:BAABKgAFFH8GAAIFAAYIawj0KgA7AQAFAAYIawj0KgA7AQAAAA==.',['勇敢']='勇敢的加多宝:BAABKgAFFH8IAAIOAAQIGQTyFwCdAAAOAAQIGQTyFwCdAAAAAA==.',['勤劳']='勤劳的卡比兽:BAACKgAFFH8LAAIFAAYI7CJuFQCwAQAFAAYI7CJuFQCwAQAqAAQKfxcAAgUACAjLJf4fAJkCAAUACAjLJf4fAJkCAAAA.',['勺子']='勺子战:BAAAKgAFFAMIAwAAAA==.勺子梅猫饼:BAABKgAFFH8PAAMIAAMILRhYDQDmAAAIAAMILRhYDQDmAAAHAAIIXg7vNgCKAAAAAA==.',['十五']='十五的猩猩:BAAAKgAECgQIBQAAAA==.',['十六']='十六:BAAAKgAFFAYIAgAAAA==.',['千里']='千里独舞:BAAAKgAFFAgIAwAAAA==.',['半神']='半神灬沫沫子:BAABKgAFFH8IAAIXAAgIgR0HBAB6AgAXAAgIgR0HBAB6AgAAAA==.',['南极']='南极以北:BAAAKgAFFAYIBAAAAA==.',['博丽']='博丽魔理沙:BAACKgAFFH8HAAQKAAYIUhS+EwAeAQAKAAUIARe+EwAeAQAPAAEIlgkqCQA/AAALAAEIAADdJgAAAAAqAAQKfyEAAw8ACAjuHy0CAJwCAA8ACAjuHy0CAJwCAAoABgjbB4RmANgAAAAA.',['卡尔']='卡尔库克:BAAAKgAECgcICQAAAA==.',['卡蕾']='卡蕾拉晨风:BAABKgAECn8gAAIBAAgILhZuMgBWAQABAAgILhZuMgBWAQAAAA==.',['原村']='原村和:BAAAKgADCggICAAAAA==.',['去旅']='去旅游吧:BAAAKgAECgQIBAAAAA==.',['叙利']='叙利亚悍妇:BAAAKgADCgYIBgAAAA==.',['吃了']='吃了个奥特蛋:BAABKgAFFH8LAAMWAAYIvA49GABWAQAWAAYIvA49GABWAQANAAUI1gJkHwCvAAAAAA==.',['名士']='名士自风流:BAABKgAFFH8MAAMOAAgIoQ2mHwDVAAAOAAQIhQ+mHwDVAAAYAAgIOQwAAAAAAAAAAA==.',['君临']='君临天下:BAABKgAFFH8IAAIZAAYIjAnOCgAzAQAZAAYIjAnOCgAzAQAAAA==.',['君凌']='君凌天下:BAABKgAFFH8KAAIGAAYIsRCeFgBOAQAGAAYIsRCeFgBOAQAAAA==.',['君子']='君子见机:BAACKgAFFH8IAAMaAAMIKg60EgCcAAAaAAMIKg60EgCcAAAbAAEI9AFuEwA1AAAqAAQKfykAAxoACAgjI5kEAL0CABoACAi2IpkEAL0CABsABgjDFMYaAFUBAAAA.',['吹比']='吹比猎手:BAAAKgAECggICgAAAA==.',['吹风']='吹风法神:BAAAKgAECggICAAAAA==.',['咆哮']='咆哮的砖头:BAAAKgAECggICAAAAA==.',['咩咩']='咩咩小羊:BAAAKgADCgEIAwAAAA==.',['哈哈']='哈哈水月:BAAAKgADCgIIAgAAAA==.',['哦麦']='哦麦嘎:BAAAKgAECgUIBwAAAA==.',['唐雨']='唐雨柔:BAAAKgADCggICAAAAA==.',['唯美']='唯美情殇:BAABKgAECn8XAAIDAAgInBMjVQArAQADAAgInBMjVQArAQAAAA==.',['啵乐']='啵乐啵乐乐:BAABKgAFFH8GAAIWAAYIHRv3EgCEAQAWAAYIHRv3EgCEAQAAAA==.',['喵大']='喵大爷:BAAAKgAECgQIBgAAAA==.',['喵妖']='喵妖王:BAABKgAECn8aAAMDAAgILxNCTgBUAQADAAgILxNCTgBUAQARAAIIRAbOawBSAAAAAA==.',['喵妮']='喵妮格米:BAAAKgADCgcIBwAAAA==.',['喵爷']='喵爷:BAAAKgAECgYICAAAAA==.',['喵老']='喵老二:BAAAKgADCgUIAgAAAA==.',['嘤灬']='嘤灬嘤嘤:BAACKgAFFH8PAAMcAAQIjhiLDgDCAAAGAAMIGBPSKgDCAAAcAAQIjhiLDgDCAAAqAAQKfycAAwYACAjSHIkWADwCAAYACAjSHIkWADwCABwAAQiiFsNDADkAAAAA.',['噬渊']='噬渊王者:BAAAKgAECgIIAgAAAA==.',['噯我']='噯我去:BAAAKgADCgYIBwAAAA==.',['四个']='四个雪糕棍:BAABKgAFFH8NAAMGAAgIkR3VBgA2AQAGAAgIkR3VBgA2AQAcAAEIgAV4GwBNAAAAAA==.',['困困']='困困儿:BAAAKgADCgEIAQAAAA==.',['圣光']='圣光保佑你:BAAAKgAECgcIBwAAAA==.',['圣辉']='圣辉闪耀:BAABKgAFFH8GAAIFAAMIOAmyLQCvAAAFAAMIOAmyLQCvAAAAAA==.',['在下']='在下乘风而起:BAACKgAFFH8UAAIZAAMIaiA5BwAKAQAZAAMIaiA5BwAKAQAqAAQKfzUAAhkACAhZJEsGAM4CABkACAhZJEsGAM4CAAAA.',['坚强']='坚强地活下去:BAABKgAFFH8OAAIHAAYIXRrjAQDTAQAHAAYIXRrjAQDTAQABKgAFFAgIEwAHAOUdAA==.',['埃辛']='埃辛诺斯战葱:BAAAKgAFFAQIBAAAAA==.',['堕落']='堕落飒:BAAAKgAECgEIAQAAAA==.',['塞隆']='塞隆:BAAAKgAECgQIBAAAAA==.',['壹丶']='壹丶戾丶髧:BAAAKgAECgEIAQAAAA==.',['夏日']='夏日冰美式:BAAAKgAECggIBgAAAA==.',['夜灬']='夜灬桜雪:BAAAKgAECggICAABKgAFFAgIDQAMAHkKAA==.',['夜露']='夜露死苦:BAAAKgADCgEIAQAAAA==.',['夜青']='夜青:BAABKgAECn8WAAILAAYIMByOHgC8AQALAAYIMByOHgC8AQAAAA==.',['大友']='大友郁弥:BAAAKgAFFAQIBAABKgAFFAgIBAASAAAAAA==.',['大嘿']='大嘿牛:BAAAKgADCgYIBgAAAA==.',['大泷']='大泷悟郎:BAAAKgAECgYIEgAAAA==.',['大燕']='大燕儿:BAAAKgAECgEIAQAAAA==.',['大王']='大王爷:BAAAKgAECggIDQAAAA==.',['大象']='大象腿飞机场:BAAAKgAECgUIDAAAAA==.',['大连']='大连街达文西:BAAAKgADCgEIAQAAAA==.',['大鹏']='大鹏展翅:BAAAKgAECgEIAQAAAA==.',['天使']='天使紫罗兰:BAABKgAFFH8GAAIUAAYIjAYJCADfAAAUAAYIjAYJCADfAAABKgAFFAgIGwAdAI0bAA==.',['天选']='天选的阿昆达:BAACKgAFFH8RAAIJAAMItQ7hGACNAAAJAAMItQ7hGACNAAAqAAQKfzUAAgkACAiJH38PADsCAAkACAiJH38PADsCAAAA.',['奈何']='奈何:BAABKgAFFH8HAAQQAAQIzg7oGwB1AAAGAAQIgwlbOACPAAAQAAIIeQroGwB1AAAcAAEIKQm9JQA4AAAAAA==.',['奥麦']='奥麦噶德:BAAAKgAECgMIAwAAAA==.',['奶白']='奶白沙果儿:BAAAKgAECgYIBgAAAA==.',['好了']='好了别说了:BAACKgAFFH8aAAIeAAgImhmeBwC7AQAeAAgImhmeBwC7AQAqAAQKfxcAAh4ACAgwHMEQAGMCAB4ACAgwHMEQAGMCAAAA.',['妩媚']='妩媚黑妞:BAAAKgAECgQIBgAAAA==.',['始乱']='始乱未二:BAABKgAFFH8nAAQcAAgINCQaAQBLAQAGAAgIWSOYCQDyAQAcAAUI8SIaAQBLAQAQAAMIPCFxEgCtAAAAAA==.',['威廉']='威廉米莉:BAAAKgAECgQIBwAAAA==.',['娜然']='娜然:BAAAKgAFFAIIAgAAAA==.',['娜美']='娜美小宝儿:BAABKgAFFH8OAAIFAAYIUiJ6IABuAQAFAAYIUiJ6IABuAQAAAA==.',['孟德']='孟德雅痞:BAABKgAECn8ZAAMJAAgISRUvJABoAQAJAAgISRUvJABoAQAMAAEIpAd0vAAlAAAAAA==.',['季末']='季末碎心:BAAAKgAECgcIBwAAAA==.',['宁宁']='宁宁闹他:BAABKgAFFH8IAAIcAAQI4x6yBAAIAQAcAAQI4x6yBAAIAQAAAA==.',['宁静']='宁静致远:BAAAKgAECgYIBgAAAA==.',['宅老']='宅老师:BAABKgAFFH8FAAMQAAUIDA+6DADQAAAQAAMIPBK6DADQAAAGAAIIRAo6OACQAAAAAA==.',['安圣']='安圣鲁斯:BAAAKgAECgUIBQAAAA==.',['安德']='安德洛斯:BAAAKgAECgcIBwAAAA==.',['安戰']='安戰五渣:BAAAKgADCggICAAAAA==.',['宝芝']='宝芝琳:BAAAKgADCggICQAAAA==.',['寂寞']='寂寞狐狸:BAACKgAFFH8ZAAMFAAMI2CLuDQAcAQAFAAMI2CLuDQAcAQATAAMIABh3CgC3AAAqAAQKfycAAxMACAjXJKIBAOICABMACAjXJKIBAOICAAUACAhaI5cVAMECAAAA.',['密林']='密林游侠:BAAAKgAECggICAAAAA==.',['小儿']='小儿郎:BAAAKgAECgcIEAAAAA==.',['小唏']='小唏姐姐:BAAAKgADCgMIBgAAAA==.',['小壞']='小壞氮:BAAAKgAECgYICwAAAA==.',['小小']='小小兔宝宝:BAACKgAFFH8QAAIFAAMINRvVGgD1AAAFAAMINRvVGgD1AAAqAAQKfyMAAgUACAj+JGgUAMYCAAUACAj+JGgUAMYCAAAA.小小武僧:BAABKgAFFH8IAAIfAAQIJB1JAgD3AAAfAAQIJB1JAgD3AAAAAA==.',['小岛']='小岛元太:BAAAKgAECgcIBwAAAA==.',['小摸']='小摸鱼的余墨:BAABKgAFFH8FAAIeAAMIbgkBJQCPAAAeAAMIbgkBJQCPAAAAAA==.',['小样']='小样别追我:BAAAKgAECgQICAAAAA==.',['小猴']='小猴子睡猫:BAAAKgADCggIEAAAAA==.',['小疯']='小疯仔:BAAAKgAECgMIBwAAAA==.',['小砑']='小砑:BAABKgAFFH8FAAIFAAMIIAerYwCoAAAFAAMIIAerYwCoAAAAAA==.',['小蜥']='小蜥蜴:BAAAKgADCgYIBgAAAA==.',['小象']='小象嘟嘟:BAAAKgAECggICAAAAA==.',['小锋']='小锋子:BAAAKgADCgMIAwAAAA==.',['小鱼']='小鱼吞猫:BAAAKgAECggIDQAAAA==.',['展展']='展展:BAAAKgAECgcIBwAAAA==.',['岁三']='岁三:BAABKgAFFH8OAAMMAAYICRyDDgCvAQAMAAYICRyDDgCvAQAJAAQIHwwNJgB/AAAAAA==.',['帅的']='帅的批爆:BAAAKgAFFAEIAQAAAA==.',['帝皇']='帝皇毒刃:BAAAKgADCgIIAgAAAA==.',['常扇']='常扇赵子龙丶:BAAAKgAECgQIBAAAAA==.',['干煸']='干煸老肉丁:BAAAKgAFFAMIAwAAAA==.',['年华']='年华弹指间:BAABKgAECn8rAAIIAAgIwBxJGwD3AQAIAAgIwBxJGwD3AQAAAA==.',['幸运']='幸运星:BAAAKgAECgQIBwAAAA==.',['幻患']='幻患幻:BAAAKgAFFAIIAgAAAA==.',['幻灬']='幻灬爷:BAAAKgAECgYIBgAAAA==.',['幻龙']='幻龙逐星辰:BAAAKgADCgIIAgAAAA==.',['库克']='库克噜噜:BAACKgAFFH8MAAMGAAYIaRUEBQBZAQAGAAUIhxgEBQBZAQAQAAMICQzrGgB7AAAqAAQKfxcAAxAACAhBFao3AAUBAAYABwguEApOADABABAABgjhFKo3AAUBAAAA.库克皮皮:BAABKgAECn8WAAMOAAgIjRa9DgC0AQAOAAcIaRe9DgC0AQAYAAgIsw7qMgAoAQAAAA==.',['往矣']='往矣矣:BAAAKgAECgUIBQAAAA==.',['征尘']='征尘:BAAAKgAECgEIAQAAAA==.',['很小']='很小心:BAAAKgAECgIIAgAAAA==.',['德克']='德克兰丶血蹄:BAAAKgAFFAIIAgAAAA==.',['心弦']='心弦乄梦:BAACKgAFFH8RAAIBAAQIfRuPDQDOAAABAAQIfRuPDQDOAAAqAAQKfyQAAwEACAgpGc0qAH8BAAEACAjsFs0qAH8BAAIABgj3EjJPANgAAAAA.',['心有']='心有灵犀:BAAAKgADCgQIBAAAAA==.',['心為']='心為誰痛:BAAAKgADCggIFgAAAA==.',['忆兮']='忆兮思黄昏:BAABKgAFFH8FAAICAAUIQhKVEAAcAQACAAUIQhKVEAAcAQAAAA==.',['快快']='快快变大:BAAAKgAECgcIBwAAAA==.',['恩佐']='恩佐斯奶骑:BAAAKgAFFAgIBAAAAA==.',['恶毒']='恶毒的心灵:BAAAKgAECggIEQAAAA==.',['恶魔']='恶魔的加多宝:BAAAKgAFFAQIBAAAAA==.',['情楚']='情楚怀幽:BAAAKgAFFAYIBAAAAA==.',['惩戒']='惩戒:BAAAKgAECgcICQAAAA==.',['惬意']='惬意由心丶:BAAAKgADCgYIBgAAAA==.',['慷慨']='慷慨激昂:BAACKgAFFH8JAAIHAAMIJiQwGAA5AQAHAAMIJiQwGAA5AQAqAAQKfx0AAgcACAh2I6cEAM4CAAcACAh2I6cEAM4CAAAA.',['我不']='我不要名:BAABKgAECn8ZAAIgAAgIJgXjQQC5AAAgAAgIJgXjQQC5AAAAAA==.',['我丑']='我丑我不温柔:BAAAKgADCggICAAAAA==.',['我小']='我小飞侠:BAABKgAFFH8IAAIOAAgItgjkBgAJAgAOAAgItgjkBgAJAgAAAA==.',['我怎']='我怎么是武僧:BAABKgAFFH8MAAIeAAYI1BQWDABlAQAeAAYI1BQWDABlAQAAAA==.',['我是']='我是当跟我走:BAABKgAECn8XAAIHAAgIxRcxMgDgAQAHAAgIxRcxMgDgAQAAAA==.',['我的']='我的哥:BAAAKgAECggIEgAAAA==.',['我真']='我真的没有名:BAABKgAECn8bAAILAAgIAh+VDgBbAgALAAgIAh+VDgBbAgAAAA==.',['战斗']='战斗吧少年:BAABKgAFFH8PAAIZAAUIyBo2BQArAQAZAAUIyBo2BQArAQAAAA==.',['扛把']='扛把子:BAAAKgAFFAQIBAAAAA==.',['拉科']='拉科:BAAAKgAFFAIIAgAAAA==.',['拉菲']='拉菲尔:BAAAKgAECgEIAQAAAA==.',['拨清']='拨清啵:BAAAKgADCgUIBQAAAA==.',['损友']='损友:BAABKgAFFH8FAAIhAAUIBwkAAAAAAAAaAAUIBwkAAAAAAAAAAA==.',['插花']='插花弄玉:BAAAKgAFFAQIBAAAAA==.',['故事']='故事未完待续:BAAAKgAFFAYIBAAAAA==.',['斗牛']='斗牛大骑士:BAABKgAECn8UAAIFAAgIFxzgMAA7AgAFAAgIFxzgMAA7AgAAAA==.',['斩风']='斩风:BAAAKgAFFAUIAQABKgAFFAgIFAAHAK8jAA==.',['断霞']='断霞残肆丶:BAAAKgADCgYIBgAAAA==.',['断风']='断风尘:BAACKgAFFH8PAAQcAAQIFxpEBwDvAAAcAAMIOxhEBwDvAAAGAAEIqR8eRQBVAAAQAAEIKgLAIAAsAAAqAAQKfyIABBwACAhkHkYMAKsBABwACAjRHEYMAKsBABAABQiaGRItADYBAAYABAjsDQB6AJ4AAAAA.',['无敌']='无敌圣光:BAABKgAFFH8FAAIUAAUIwwTcCwCsAAAUAAUIwwTcCwCsAAABKgAFFAgIEwAUAA0TAA==.',['星丷']='星丷灿:BAAAKgAECgYIDQAAAA==.',['星奥']='星奥:BAAAKgAECggIDwAAAA==.',['星璨']='星璨:BAAAKgAECggICAAAAA==.',['晓疯']='晓疯子:BAABKgAFFH8IAAQiAAMIOgzaCAB8AAAiAAMIEwTaCAB8AAAaAAIIggacJQB3AAAbAAIITg3dCABDAAAAAA==.',['晓赫']='晓赫:BAABKgAECn8VAAMFAAgIXiEJMQA7AgAFAAgIXiEJMQA7AgAUAAEIZAAAAAAAAAAAAA==.',['晨晨']='晨晨同学:BAAAKgAECgIIAgAAAA==.',['晴丷']='晴丷朗:BAAAKgAECgYIBgAAAA==.',['晴天']='晴天小丹:BAAAKgAFFAgIBAAAAA==.',['晴朗']='晴朗:BAAAKgAECgYIBgAAAA==.',['暗影']='暗影萨满卢克:BAAAKgAFFAgIBAAAAA==.',['暴力']='暴力输出:BAAAKgAFFAIIAgAAAA==.',['暴怒']='暴怒斩杀:BAAAKgAECgUICgAAAA==.',['暴躁']='暴躁的心灵:BAAAKgAECggIDQAAAA==.',['曦影']='曦影:BAAAKgADCgIIAgAAAA==.',['曼珠']='曼珠沙华:BAAAKgAECgUIDAAAAA==.',['曾经']='曾经的执着:BAAAKgAECggICgAAAA==.',['月影']='月影星澜:BAAAKgAECggICAAAAA==.',['月照']='月照心自明:BAABKgAFFH8FAAICAAMIGRHWEADUAAACAAMIGRHWEADUAAAAAA==.',['未始']='未始乱二:BAAAKgAFFAYIBAAAAA==.',['朮學']='朮學老師:BAABKgAECn8UAAMQAAgIKBGsKgBQAQAQAAgIKBGsKgBQAQAGAAEIVQllqwAzAAAAAA==.',['朱利']='朱利叶斯欧文:BAACKgAFFH8GAAIHAAYIfh1pDwCCAQAHAAYIfh1pDwCCAQAqAAQKfxQABAgACAhCJMgPAFgCAAgACAhCJMgPAFgCAAcABAhwFAd8AOQAACMAAghLBAMZADEAAAAA.',['机智']='机智的呆呆兽:BAABKgAFFH8XAAIGAAgIsyDZAQC9AgAGAAgIsyDZAQC9AgAAAA==.',['杨树']='杨树林:BAABKgAFFH8JAAIFAAQITyVUJgBPAQAFAAQITyVUJgBPAQAAAA==.',['果壳']='果壳:BAABKgAECn8cAAIDAAgIrREFTABKAQADAAgIrREFTABKAQAAAA==.',['树勇']='树勇买买提:BAABKgAFFH8cAAMHAAYI0yO9CADqAQAHAAYI0yO9CADqAQAIAAYIVwrVDwD9AAAAAA==.',['梅琳']='梅琳娜宅:BAABKgAFFH8HAAMYAAMIwhR3FQDZAAAYAAMIwhR3FQDZAAAOAAEIbgn1NwBAAAAAAA==.',['梨树']='梨树落梨花:BAABKgAFFH8QAAIXAAgIQB8/AwB9AgAXAAgIQB8/AwB9AgAAAA==.',['森海']='森海飞霞:BAAAKgAECgUIBQAAAA==.',['橘子']='橘子酒:BAAAKgAFFAQIBAAAAA==.',['橙玥']='橙玥:BAACKgAFFH8MAAMUAAUIXRpBCQAOAQAUAAUIyxdBCQAOAQAFAAII/yLQMgClAAAqAAQKfywAAgUACAhzIjkeAJ8CAAUACAhzIjkeAJ8CAAAA.',['檸檬']='檸檬沙拉:BAABKgAECn8nAAIVAAgIgxdaKwB/AQAVAAgIgxdaKwB/AQAAAA==.',['止水']='止水:BAAAKgADCgYIBgAAAA==.',['此昵']='此昵称不存在:BAABKgAECn8dAAIIAAgICBc4KADKAQAIAAgICBc4KADKAQAAAA==.',['死亡']='死亡宅妹:BAAAKgAFFAgIAwAAAA==.',['殇之']='殇之刹那:BAAAKgADCggIEAAAAA==.',['毁灭']='毁灭之握:BAAAKgADCggICAAAAA==.',['氵木']='氵木子告魔彡:BAAAKgAECgYIBwAAAA==.',['永夜']='永夜:BAABKgAECn8WAAQCAAgIjBxwLgBuAQACAAYIhhtwLgBuAQABAAYIPBgvTwD8AAAVAAQImRKmUgChAAAAAA==.',['永広']='永広:BAABKgAECn8bAAIEAAcIHhNIKgBxAQAEAAcIHhNIKgBxAQAAAA==.',['永紫']='永紫:BAACKgAFFH8WAAIOAAMI4hfdGgDqAAAOAAMI4hfdGgDqAAAqAAQKfxwAAg4ACAgLHUQaADwCAA4ACAgLHUQaADwCAAAA.',['沃腴']='沃腴:BAAAKgAECgUIBQAAAA==.',['沉默']='沉默的大酋长:BAACKgAFFH8GAAIOAAQIsxBLEQD1AAAOAAQIsxBLEQD1AAAqAAQKfx0AAw4ACAhDHuUlAPgBAA4ACAhDHuUlAPgBACQABAgIELQxAIUAAAEqAAUUCAgOAAcAQh8A.沉默的小德:BAAAKgAECgcIBwAAAA==.沉默的牧師:BAABKgAECn9DAAQCAAgI1R0YDQBLAgACAAgI1R0YDQBLAgAVAAgIoxMaJQCuAQABAAMIdwzBeQBzAAAAAA==.沉默的秘术师:BAAAKgADCgMIAwAAAA==.沉默的魔王:BAABKgAECn8SAAIOAAgIZiB2HwDXAQAOAAgIZiB2HwDXAQAAAA==.',['沙漏']='沙漏:BAACKgAFFH8OAAIHAAMIbhXyLgDOAAAHAAMIbhXyLgDOAAAqAAQKfxsAAwcABQi0ITkwAOoBAAcABQi0ITkwAOoBAAgAAQj2GKqZAEgAAAAA.',['没有']='没有肉肉:BAACKgAFFH8NAAMRAAMIUB7YBwDwAAARAAMIUB7YBwDwAAADAAMIjBMbLADGAAAqAAQKfz4AAhEACAgRJekGAMECABEACAgRJekGAMECAAAA.',['没梦']='没梦想的腊肉:BAAAKgAFFAIIAgABKgAFFAMIDQARAFAeAA==.',['法国']='法国熊:BAAAKgAFFAgIAgAAAA==.',['法湿']='法湿:BAAAKgAECgQIBAAAAA==.',['洎巳']='洎巳:BAABKgAFFH8GAAIFAAYIDhzyIABrAQAFAAYIDhzyIABrAQAAAA==.',['洒家']='洒家略胖:BAAAKgAECgYIDAAAAA==.',['洪荒']='洪荒丶恋空:BAABKgAECn8WAAMBAAgIGBmoHwDhAQABAAgIGBmoHwDhAQAVAAYIxwrORwDSAAAAAA==.',['活着']='活着开心就好:BAAAKgAECggIBgAAAA==.',['流星']='流星能飞多久:BAAAKgAECgIIAgAAAA==.',['流浪']='流浪刀刀:BAAAKgAFFAgIBAAAAA==.',['浓睡']='浓睡不醒残酒:BAABKgAFFH8QAAMHAAYIax8sBwBRAQAIAAYI4RqfDwBrAQAHAAQIkRosBwBRAQAAAA==.',['清风']='清风明月:BAAAKgAECggICQAAAA==.',['游侠']='游侠之猎:BAAAKgAECgIIAgAAAA==.',['湖人']='湖人小骑士:BAAAKgAECggICAAAAA==.',['湿蛋']='湿蛋蛋的湿蛋:BAABKgAFFH8OAAIEAAYIESCmAAAHAgAEAAYIESCmAAAHAgAAAA==.',['潮风']='潮风:BAAAKgAECgYIBgAAAA==.',['灬山']='灬山治灬:BAAAKgAECgEIAQAAAA==.',['灬没']='灬没名灬:BAAAKgAECgYIDwAAAA==.',['炯炯']='炯炯有神的眼:BAAAKgAECgIIAgAAAA==.',['点水']='点水:BAABKgAFFH8KAAMKAAYIzwieDwAZAQAKAAYIzwieDwAZAQALAAQInAbYEgCUAAAAAA==.',['点鱼']='点鱼长:BAABKgAFFH8OAAIYAAUIbg41EQACAQAYAAUIbg41EQACAQAAAA==.',['烈焰']='烈焰火鬼:BAAAKgAECggIDAAAAA==.烈焰灬灼心:BAACKgAFFH8WAAIdAAMIFBWGHADSAAAdAAMIFBWGHADSAAAqAAQKfzwAAh0ACAjAILINACACAB0ACAjAILINACACAAAA.',['無敵']='無敵:BAAAKgADCgYIBgAAAA==.',['無盡']='無盡火球:BAAAKgAECgYIBgAAAA==.無盡蟲泡泡:BAABKgAFFH8IAAIdAAgIlA5DCAAIAgAdAAgIlA5DCAAIAgAAAA==.',['熊猫']='熊猫快快跑灬:BAAAKgAECgcIBwAAAA==.',['燃烧']='燃烧的勇气:BAAAKgAECgYIBwAAAA==.',['爆头']='爆头专家:BAAAKgAECgYIDAAAAA==.',['爆裂']='爆裂灬龍術:BAAAKgAECggIEAAAAA==.',['爱乃']='爱乃娜美:BAAAKgADCggICAAAAA==.',['爱蜜']='爱蜜莉雅:BAAAKgADCggICAAAAA==.',['牛什']='牛什么啊:BAAAKgAECgEIAQAAAA==.',['牛毛']='牛毛豆:BAABKgAFFH8OAAMYAAYIBQqrBgBYAQAYAAYIBQqrBgBYAQAkAAQI3QYPCwB4AAAAAA==.',['牛肉']='牛肉人人不爱:BAAAKgAFFAIIAgAAAA==.',['牛黄']='牛黄豆:BAACKgAFFH8mAAMEAAUIsheyCABPAQAEAAUIsheyCABPAQADAAUIHxQBGAAiAQAqAAQKfzAAAwQACAj/H9oSADoCAAQACAj/H9oSADoCAAMAAwiSEDqbAIMAAAAA.',['狐小']='狐小喵:BAABKgAECn8jAAMTAAgIpSLwAwCvAgATAAgIpSLwAwCvAgAFAAEI4h5tWgFPAAAAAA==.',['猎魔']='猎魔人:BAAAKgAECggIDwAAAA==.',['猛牛']='猛牛酸酸乳丶:BAAAKgAECggICQAAAA==.',['猫不']='猫不满:BAAAKgAECgYICAAAAA==.',['猫儿']='猫儿五二零:BAABKgAECn8aAAMNAAgI7hnsFAD7AQANAAgI7hnsFAD7AQAlAAQI5xo1GwDUAAAAAA==.',['猫哆']='猫哆哆:BAAAKgADCgQIBAAAAA==.',['王微']='王微笑:BAABKgAFFH8IAAIPAAgIuhJVBwAVAgAPAAgIuhJVBwAVAgAAAA==.',['玛丽']='玛丽亚凯莉:BAAAKgADCgUIBQAAAA==.',['珍惜']='珍惜這段情:BAAAKgAECggIEQAAAA==.',['瑶瑶']='瑶瑶乐:BAAAKgAECgUIBgAAAA==.',['瑾丶']='瑾丶年:BAAAKgADCgQIBQAAAA==.',['瓦莱']='瓦莱塔:BAAAKgADCgEIAQAAAA==.',['生气']='生气的圣骑:BAAAKgADCgEIAgAAAA==.',['疯中']='疯中追风:BAAAKgAECggIDAAAAA==.',['白河']='白河愁:BAABKgAFFH8JAAMPAAYIDR5vDwBzAQAPAAYI0xZvDwBzAQAKAAMIniIHFwD4AAAAAA==.',['白胡']='白胡子亨特:BAAAKgADCgMIAwAAAA==.',['皓月']='皓月酩心:BAABKgAFFH8GAAIJAAYIzBFSDgA2AQAJAAYIzBFSDgA2AQABKgAFFAgIDgAMAEoXAA==.',['皤魑']='皤魑傀儡公:BAABKgAECn8aAAQkAAgIpA2PIwAPAQAkAAcIPw+PIwAPAQAYAAcIxgXLUwB8AAAOAAUIKAJTgwBdAAAAAA==.',['盘丝']='盘丝儿大仙:BAAAKgAECgYIBgAAAA==.',['眾耳']='眾耳:BAAAKgAECgQIAwAAAA==.',['瞬发']='瞬发炉石:BAABKgAFFH8JAAMRAAQILxIMDADOAAARAAQILxIMDADOAAADAAEI/QT5NAA8AAABKgAFFAgICAADALsbAA==.',['矿老']='矿老爷:BAABKgAFFH8GAAIGAAYIuBIzFgBSAQAGAAYIuBIzFgBSAQAAAA==.',['破裂']='破裂人偶:BAAAKgAFFAMIAwAAAA==.',['神乐']='神乐沧月:BAAAKgAECggIDgAAAA==.',['神圣']='神圣魔幻:BAAAKgAECgMIAwAAAA==.',['神奇']='神奇的胖胖:BAAAKgAECgUIBQAAAA==.',['禅宗']='禅宗不灭:BAAAKgADCggICAAAAA==.',['离落']='离落霜魂:BAAAKgAFFAEIAQAAAA==.',['秦始']='秦始皇二一四:BAACKgAFFH8UAAIDAAYITh/IAADUAQADAAYITh/IAADUAQAqAAQKf0UAAwMACAisI1YIALMCAAMACAisI1YIALMCAAQAAQh0B15JACsAAAAA.',['穷途']='穷途:BAAAKgAECgQIBAAAAA==.',['空谷']='空谷残聲:BAABKgAFFH8GAAIVAAYIeRskBwCoAQAVAAYIeRskBwCoAQAAAA==.',['筱丶']='筱丶熙:BAAAKgAECgIIAgAAAA==.',['简单']='简单的幸福:BAAAKgAECgcICgAAAA==.',['粉红']='粉红小天才:BAAAKgAECgMIAwAAAA==.',['粮票']='粮票的故事:BAABKgAFFH8UAAIDAAYI6CIFCgCmAQADAAYI6CIFCgCmAQAAAA==.',['索克']='索克雷茨:BAACKgAFFH8OAAMLAAQIKhCzFQCGAAALAAQImg2zFQCGAAAPAAEIOxBSRQA9AAAqAAQKfxUAAwsACAglFr48AHkBAAsACAglFr48AHkBAA8ABgilEJNSAPQAAAEqAAUUBggZAAcAeR0A.',['紫川']='紫川:BAAAKgAECggIEAAAAA==.',['紫月']='紫月重明:BAAAKgAFFAQIBAAAAA==.',['紫霞']='紫霞:BAAAKgAECgIIAgAAAA==.',['红名']='红名:BAAAKgAECgYIBgAAAA==.',['红猫']='红猫:BAABKgAFFH8GAAMCAAYIPxdCGADPAAACAAQIdRlCGADPAAABAAII7hOOKgCZAAAAAA==.',['绚丽']='绚丽音符:BAABKgAFFH8GAAILAAMI7guXDAC9AAALAAMI7guXDAC9AAAAAA==.',['维克']='维克多莉雅:BAAAKgAFFAEIAQAAAA==.',['维生']='维生素二细:BAAAKgAECggICwAAAA==.',['绿巨']='绿巨人丨九峰:BAAAKgADCggICAAAAA==.',['绿豆']='绿豆奶茶:BAABKgAECn8VAAMWAAgIpRSZOgC9AQAWAAgIpRSZOgC9AQANAAQIzAlwXwCXAAAAAA==.',['缚魂']='缚魂者丶焰击:BAAAKgAECggIEwAAAA==.',['罐罐']='罐罐奶:BAAAKgAECgYIBgAAAA==.',['罗宾']='罗宾汉:BAAAKgADCgcIBwAAAA==.',['罩的']='罩的住丶:BAAAKgADCggICAAAAA==.',['罪孽']='罪孽烙印:BAABKgAFFH8IAAIMAAgInxICBwAjAgAMAAgInxICBwAjAgAAAA==.',['羊村']='羊村第一打手:BAAAKgADCggICAAAAA==.',['聖光']='聖光忽悠:BAAAKgAECggIEwAAAA==.',['肉松']='肉松脆:BAAAKgAECgYICQAAAA==.',['肥肥']='肥肥是只喵:BAABKgAFFH8LAAMIAAYIsCDoBwDhAQAIAAYIsCDoBwDhAQAHAAQIHQbpJgC2AAAAAA==.',['腐魂']='腐魂者焰击:BAABKgAECn8UAAMGAAcIphTdNgAyAQAGAAYIQRbdNgAyAQAQAAUIDwegWACbAAAAAA==.',['自由']='自由永不落伍:BAAAKgAECgYIBwAAAA==.',['至高']='至高牛的幸福:BAAAKgAECggIEgAAAA==.',['致命']='致命拜访:BAAAKgAECggIDgAAAA==.',['艾蕾']='艾蕾莉亚晨风:BAAAKgAECgIIBAABKgAECggIIAABAC4WAA==.',['艾辛']='艾辛诺斯:BAAAKgAECgIIAgAAAA==.',['花殇']='花殇紫幽幽:BAAAKgADCggICAAAAA==.',['芳丶']='芳丶华:BAAAKgAECgYIBgAAAA==.',['茶饼']='茶饼:BAAAKgADCgMIAwAAAA==.',['荣耀']='荣耀与忧伤:BAAAKgAFFAIIAgAAAA==.',['莽撞']='莽撞人:BAAAKgAFFAQIBAAAAA==.',['菱枫']='菱枫:BAABKgAFFH8GAAICAAYIBQqZAwBmAQACAAYIBQqZAwBmAQAAAA==.',['萌有']='萌有萌的萌法:BAABKgAFFH8OAAIPAAgIfhYZBQBIAgAPAAgIfhYZBQBIAgAAAA==.',['萌萌']='萌萌哒小兔叽:BAAAKgAECgIIAgAAAA==.萌萌哒小兔姬:BAABKgAFFH8IAAIMAAQI/AVuQACcAAAMAAQI/AVuQACcAAABKgAFFAgIDAAdAO8dAA==.',['萧瑟']='萧瑟萧瑟:BAAAKgAFFAQIBAAAAA==.萧瑟骑士:BAABKgAFFH8FAAIMAAUIXBAEIwALAQAMAAUIXBAEIwALAQABKgAFFAgIEwAGADQUAA==.',['萨格']='萨格拉丝:BAAAKgAECggIDgAAAA==.',['萨牛']='萨牛儿:BAABKgAFFH8UAAMRAAgIRg3AAwDxAQARAAgIRg3AAwDxAQADAAgIAwyuCwCMAQAAAA==.',['萩原']='萩原千速:BAAAKgAECgYIBgAAAA==.',['葬魂']='葬魂丷:BAAAKgADCggICAAAAA==.',['蒜泥']='蒜泥宝贝:BAAAKgAECgcIBQAAAA==.',['蓬荜']='蓬荜生辉:BAAAKgAECggICwAAAA==.',['蕾姆']='蕾姆:BAAAKgADCgIIAgAAAA==.',['藤林']='藤林奈绪江:BAAAKgAFFAQIBAAAAA==.',['虫虫']='虫虫冲:BAAAKgAFFAgIBAAAAA==.',['虾仁']='虾仁:BAAAKgAECgMIBAAAAA==.',['蜜拉']='蜜拉娜:BAAAKgADCgcIBwAAAA==.',['蠢羊']='蠢羊:BAAAKgAECgEIAQAAAA==.',['见习']='见习萨满银矿:BAAAKgAECgUIBQAAAA==.',['許鱼']='許鱼:BAABKgAFFH8GAAMRAAMIchWGEQCXAAARAAMIchWGEQCXAAADAAEIsgB+VQAmAAAAAA==.',['让我']='让我看看:BAABKgAFFH8RAAQCAAYIyyDHAgCIAQACAAYIHRvHAgCIAQABAAIIkCTbHwDIAAAVAAEI2BjCJQBIAAAAAA==.',['许鱼']='许鱼:BAABKgAFFH8FAAILAAII+RppDwCrAAALAAII+RppDwCrAAAAAA==.',['请阅']='请阅示:BAABKgAFFH8GAAIdAAYIvg3wBQBnAQAdAAYIvg3wBQBnAQAAAA==.',['谜之']='谜之真相:BAABKgAFFH8FAAMUAAUIKhMBHACZAAAFAAMIsg3mXAC3AAAUAAIIXRsBHACZAAABKgAFFAgIEAAFAIwiAA==.',['谢雨']='谢雨辰丶:BAABKgAFFH8KAAMeAAYI+g49CgAsAQAeAAYI+g49CgAsAQAZAAQISxYmCwDkAAAAAA==.',['豆到']='豆到碗里来:BAAAKgAFFAQIBAAAAA==.',['豌豆']='豌豆太岁爷:BAAAKgADCgEIAQAAAA==.',['赛弥']='赛弥亚已阵亡:BAAAKgAECgIIAgAAAA==.',['赤井']='赤井秀一:BAAAKgAECgYIDQAAAA==.',['赵灵']='赵灵儿:BAAAKgADCggIBwAAAA==.',['路西']='路西法叮叮:BAABKgAFFH8IAAIaAAgI/xWYBQA0AgAaAAgI/xWYBQA0AgAAAA==.',['踏月']='踏月的熊:BAAAKgAECggIDQAAAA==.',['躺赢']='躺赢:BAABKgAECn8XAAMRAAgIQRn2MACBAQARAAcI/Bf2MACBAQADAAgIXQ0FUABPAQAAAA==.',['轩鸢']='轩鸢丶:BAAAKgADCggICAAAAA==.',['辉煌']='辉煌:BAABKgAFFH8GAAIGAAYI7R2sDQCyAQAGAAYI7R2sDQCyAQAAAA==.',['辣炒']='辣炒小花蛤:BAACKgAFFH8RAAIeAAMIdhdqFADRAAAeAAMIdhdqFADRAAAqAAQKfy8AAh4ACAicIXwMAIgCAB4ACAicIXwMAIgCAAAA.',['达文']='达文克苏斯:BAAAKgAECgIIAQAAAA==.',['达维']='达维斯威莉:BAAAKgAECggICAAAAA==.',['过叶']='过叶风:BAAAKgADCgYIBgAAAA==.',['运动']='运动牛牛:BAABKgAFFH8QAAMYAAgIoxS3AADYAQAYAAYIYxm3AADYAQAOAAYIvgkZEgA4AQAAAA==.',['这毫']='这毫王意义:BAAAKgAECgcICAAAAA==.',['迟到']='迟到的幸福:BAAAKgAECgMIAwAAAA==.',['迪桑']='迪桑信仰者:BAAAKgAECgQIBAAAAA==.',['醉里']='醉里挑灯看劍:BAAAKgADCgUICAAAAA==.',['醒目']='醒目丨葡萄味:BAABKgAECn8aAAIFAAgIgRZFYQCcAQAFAAgIgRZFYQCcAQAAAA==.',['铭初']='铭初:BAAAKgAECgMIBQAAAA==.',['银色']='银色羽翼:BAAAKgAFFAYIAgAAAA==.',['锅盖']='锅盖小盖哥:BAAAKgADCgUIBQAAAA==.',['開鈊']='開鈊小豬:BAABKgAECn82AAIdAAgIkSHXBgCZAgAdAAgIkSHXBgCZAgAAAA==.',['闪动']='闪动:BAAAKgADCgQIBAAAAA==.',['闪电']='闪电旋风劈灬:BAACKgAFFH8PAAQEAAgIJh6FAwAiAgAEAAgIPRmFAwAiAgARAAMILR8oCwAaAQADAAEIDwTrTwBDAAAqAAQKfxQAAxEACAikCplFAA0BABEACAikCplFAA0BAAMABghaBPSLAKcAAAAA.',['闲云']='闲云飘渺:BAAAKgADCggICAAAAA==.',['闻之']='闻之残阳落日:BAAAKgAFFAYIBAAAAA==.闻之浅忆悠蓝:BAABKgAFFH8GAAIDAAYIugXvHAAJAQADAAYIugXvHAAJAQAAAA==.闻之潇潇落雨:BAABKgAECn8bAAMBAAgIzgSmYAC+AAABAAgIzgSmYAC+AAACAAIIgwDcowALAAAAAA==.闻之过眼雲烟:BAABKgAFFH8KAAMHAAYIQAqwGQAwAQAHAAYIQAqwGQAwAQAIAAQInwrQNQCcAAAAAA==.闻之风卷残云:BAABKgAFFH8GAAIdAAYIkQrGFwA9AQAdAAYIkQrGFwA9AQAAAA==.',['阿凉']='阿凉是哪个:BAAAKgADCggIDQAAAA==.',['阿尔']='阿尔弗雷德:BAAAKgADCgUIBQAAAA==.',['阿蒙']='阿蒙格勒:BAAAKgAECgUIBwAAAA==.',['阿非']='阿非:BAABKgAECn8ZAAIRAAgIVRpuCQAFAgARAAgIVRpuCQAFAgAAAA==.',['陆小']='陆小凤:BAAAKgAECgQIBAAAAA==.',['集合']='集合石大师:BAACKgAFFH8JAAIMAAMIuhguLwDTAAAMAAMIuhguLwDTAAAqAAQKfxkAAgwACAgiI5YLAMICAAwACAgiI5YLAMICAAAA.',['雨夜']='雨夜潇湘:BAAAKgAECgMIAwAAAA==.',['雨林']='雨林:BAAAKgAECgUICAAAAA==.',['雷帝']='雷帝歐斯:BAAAKgAECggICAAAAA==.',['雷龙']='雷龙:BAAAKgADCggICAAAAA==.',['雾雨']='雾雨灵梦:BAABKgAECn8WAAIeAAgIZxaXGgC0AQAeAAgIZxaXGgC0AQAAAA==.',['霓虹']='霓虹甜心:BAAAKgAECggIBwAAAA==.',['霜火']='霜火协奏:BAAAKgAECggICAAAAA==.',['霹雳']='霹雳五:BAABKgAFFH8eAAMDAAYI0yDWCAC6AQADAAYI0yDWCAC6AQARAAIIFh8IGQCxAAAAAA==.',['面包']='面包熊:BAABKgAFFH8IAAIfAAMI2AzGBwCUAAAfAAMI2AzGBwCUAAABKgAFFAgICAAaAJIaAA==.',['韩能']='韩能射:BAAAKgAECgQIBAAAAA==.韩能抗:BAAAKgAECgYIBwAAAA==.',['音速']='音速飞行:BAAAKgADCgEIAgAAAA==.',['順其']='順其自然:BAAAKgADCgcIBwAAAA==.',['风雷']='风雷火电:BAABKgAFFH8NAAMDAAYI/wqqDwAFAQADAAYI/wqqDwAFAQAEAAMI4Qs7CgDBAAAAAA==.',['飞天']='飞天打卤面:BAAAKgAECgYIBgABKgAFFAgIBAASAAAAAA==.',['饼干']='饼干熊:BAABKgAFFH8LAAIHAAMI1hd0KQDfAAAHAAMI1hd0KQDfAAAAAA==.',['骁老']='骁老豆:BAABKgAFFH8LAAIdAAMIVhnlJgDbAAAdAAMIVhnlJgDbAAAAAA==.',['高圆']='高圆圆老公:BAABKgAECn8XAAIMAAgIkRqxMgDnAQAMAAgIkRqxMgDnAQAAAA==.',['魔兽']='魔兽我最菜:BAABKgAECn80AAIBAAgILCVOBADMAgABAAgILCVOBADMAgAAAA==.',['魔幻']='魔幻的加多宝:BAAAKgAECggIAwAAAA==.',['鱼生']='鱼生:BAAAKgAECggIDwAAAA==.',['鳝恶']='鳝恶有鲍:BAAAKgAECgcIBwAAAA==.',['麟迴']='麟迴转圈圈:BAACKgAFFH8WAAIdAAMIxxhNJQDjAAAdAAMIxxhNJQDjAAAqAAQKfy4AAh0ACAiWH94dAFECAB0ACAiWH94dAFECAAAA.',['黑暗']='黑暗中跳支舞:BAAAKgAECggICAAAAA==.',['黑翼']='黑翼尖刀:BAAAKgAECggICAAAAA==.',['黑镜']='黑镜:BAAAKgADCgUIBQAAAA==.',['黯然']='黯然失落:BAAAKgAFFAMIBAAAAA==.黯然销魂:BAAAKgAECgUIBQAAAA==.',['龍将']='龍将:BAAAKgADCggICAAAAA==.',['龙云']='龙云凤:BAACKgAFFH8WAAMHAAQIcCIBKADlAAAHAAQIcCIBKADlAAAIAAQIgxlLIwDiAAAqAAQKfxwAAwcACAgSGsZLAM8BAAcACAjyE8ZLAM8BAAgABwitGWE1AIUBAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end