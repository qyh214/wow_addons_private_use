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
 local lookup = {'Hunter-BeastMastery','Paladin-Retribution','Hunter-Marksmanship','Paladin-Holy','Priest-Discipline','Priest-Holy','DeathKnight-Unholy','Rogue-Assassination','Mage-Frost','Mage-Fire','Mage-Arcane','Priest-Shadow','Evoker-Devastation','Shaman-Enhancement','Druid-Restoration','Druid-Balance','Warrior-Protection','Warrior-Arms','DemonHunter-Havoc','DemonHunter-Vengeance','Monk-Mistweaver','Evoker-Preservation','Warrior-Fury','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','DeathKnight-Blood','Monk-Brewmaster','Shaman-Elemental','Hunter-Survival','Warlock-Affliction','Paladin-Protection','DeathKnight-Frost','Druid-Guardian','Monk-Windwalker','Unknown-Unknown',}; local provider = {region='CN',realm='铜龙军团',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ac='Acaker:BAAAKgAECgcIBwAAAA==.',Ak='Ak:BAABKgAFFH8FAAIBAAUI9Q2lSQB+AAABAAUI9Q2lSQB+AAAAAA==.',Al='Along:BAABKgAECn8UAAICAAgIOxjtZgDMAQACAAgIOxjtZgDMAQAAAA==.',An='Andromalius:BAAAKgADCgEIAQAAAA==.',At='Athlonwang:BAAAKgADCggICAAAAA==.',Az='Azis:BAAAKgAECggICAAAAA==.',Ba='Babayago:BAAAKgADCgMIAwAAAA==.',Be='Bern:BAABKgAFFH8GAAIDAAYIHAqjDgANAQADAAYIHAqjDgANAQAAAA==.',Ca='Call:BAAAKgADCggIBgAAAA==.',Ce='Cery:BAAAKgAECgYIBwAAAA==.',Dh='Dh:BAAAKgADCgQIBAAAAA==.',Dr='Dreamh:BAAAKgAECgMIBQAAAA==.Dreamwriter:BAACKgAFFH8pAAIEAAYI3gttBwA8AQAEAAYI3gttBwA8AQAqAAQKfyoAAgQACAivHFMLADoCAAQACAivHFMLADoCAAAA.',Fl='Flydog:BAAAKgAECgUIBQAAAA==.',Fs='Fs:BAAAKgADCgQICAAAAA==.',Gr='Greeny:BAABKgAECn8UAAMFAAcIxAt0RgD6AAAFAAcIxAt0RgD6AAAGAAEIyADwoQAUAAAAAA==.',Ha='Hailey:BAAAKgAFFAMIAwAAAA==.Hatsunem:BAAAKgAFFAIIAgAAAA==.',Hi='Hillamaris:BAABKgAECn8WAAIHAAgIIhg+LQAAAgAHAAgIIhg+LQAAAgAAAA==.',Hu='Hui:BAAAKgAECgMIAwAAAA==.',Ic='Icymaple:BAABKgAFFH8LAAIDAAQIABQ1KwC9AAADAAQIABQ1KwC9AAAAAA==.',Ki='Kire:BAAAKgAECgMIBQAAAA==.Kizuna:BAABKgAECn8WAAMGAAgIgRZOJgC4AQAGAAgIRBVOJgC4AQAFAAQI8BAsZACWAAAAAA==.',Kk='Kkye:BAAAKgAFFAIIAgAAAA==.',La='Laiban:BAAAKgAECgIIAwAAAA==.',Le='Leo:BAAAKgAECgMIBQAAAA==.',Li='Liamjames:BAAAKgAFFAMIAwAAAA==.',Lm='Lmmdz:BAAAKgAECggICAABKgAFFAgIBQAIAEkOAA==.Lmmfs:BAACKgAFFH8JAAQJAAQIWSQ8DgDyAAAKAAQImR/sFAD7AAAJAAQIWSQ8DgDyAAALAAEIAABoSwAAAAAqAAQKfxoAAwoACAiPJUMPAJ4CAAoACAiPJUMPAJ4CAAkAAghLI6FsAMQAAAAA.',Ly='Lycan:BAAAKgAECggICAAAAA==.',Mi='Minji:BAAAKgAECggICAAAAA==.Misaki:BAAAKgAECggICAAAAA==.Mistiness:BAACKgAFFH8rAAMGAAcIMRNxDQBOAQAGAAcIMRNxDQBOAQAMAAEIAAAnNQAAAAAqAAQKfycAAwYACAjmGUIgAN0BAAYACAjmGUIgAN0BAAwABAjzEuk+AAEBAAAA.',Mu='Muldermonk:BAAAKgAECgEIAQAAAA==.',Ne='Nekoo:BAAAKgAFFAQIBAABKgAFFAYIIQAMAIoQAA==.',Ni='Nicoles:BAAAKgAECgYIBwAAAA==.Nifmd:BAAAKgAECgYIBgAAAA==.Niubiglass:BAAAKgAECggICAAAAA==.',Oc='Oceciliao:BAABKgAECn8tAAIGAAgI4g02PQAhAQAGAAgI4g02PQAhAQAAAA==.',Ra='Rafael:BAABKgAFFH8IAAILAAgIeBQQBgAsAgALAAgIeBQQBgAsAgAAAA==.',Ro='Rover:BAABKgAFFH8RAAINAAYIUhh0DgB5AQANAAYIUhh0DgB5AQAAAA==.',Sa='Sasa:BAABKgAFFH8HAAIBAAYIbRR9AwClAQABAAYIbRR9AwClAQAAAA==.',Se='Serily:BAAAKgADCggICAAAAA==.',Sh='Shadowsoul:BAAAKgAFFAgIAgAAAA==.',Si='Siaem:BAABKgAFFH8IAAIOAAgInRfhAwAPAgAOAAgInRfhAwAPAgAAAA==.Silver:BAABKgAFFH8KAAMPAAYIFhjlFAD5AAAPAAQIgR7lFAD5AAAQAAYIyRKbFgDiAAAAAA==.',Sn='Snooplr:BAACKgAFFH8YAAMBAAYIeyb6BQAyAgABAAYIeyb6BQAyAgADAAEIAAAlWQAAAAAqAAQKfyUAAgEACAjyJlcAACsDAAEACAjyJlcAACsDAAAA.',So='Sologsy:BAABKgAFFH8KAAICAAQIHAsKKwDFAAACAAQIHAsKKwDFAAAAAA==.Soulchaos:BAABKgAECn8WAAMRAAgI1hctDQDpAQARAAgI1hctDQDpAQASAAcIegu9QADUAAAAAA==.',Wa='Waterfork:BAABKgAFFH8GAAICAAYIVBAnJwBMAQACAAYIVBAnJwBMAQAAAA==.',Xy='Xyearnv:BAAAKgAFFAQIBAAAAA==.',Ya='Yayahiyo:BAAAKgAECgEIAQAAAA==.',Ze='Zeppli:BAAAKgADCgQIBAAAAA==.',Zh='Zhou:BAAAKgAECgMIBQAAAA==.',['一一']='一一荡漾一一:BAAAKgAECgQIBAAAAA==.',['一笑']='一笑惊魂:BAAAKgAECgMIAwAAAA==.',['一血']='一血小分队:BAAAKgAECgcICAAAAA==.',['一麥']='一麥:BAABKgAFFH8IAAIHAAgImxF6BQAZAgAHAAgImxF6BQAZAgAAAA==.',['万恶']='万恶的陈师傅:BAAAKgAFFAIIAgAAAA==.',['万物']='万物丶生息:BAAAKgAECgMIBQAAAA==.',['三万']='三万敌法秒躺:BAABKgAFFH8MAAMTAAgIchgPCQD1AQATAAgIchgPCQD1AQAUAAQIOgTdDgBuAAAAAA==.',['三条']='三条杠:BAAAKgADCgQIBAAAAA==.',['三零']='三零三:BAABKgAECn8gAAIMAAYIAhJgMQAMAQAMAAYIAhJgMQAMAQAAAA==.',['不晓']='不晓得:BAAAKgAECggICAAAAA==.',['不死']='不死川实弥:BAAAKgADCgIIAgAAAA==.',['不说']='不说话装高手:BAAAKgAECggICAABKgAFFAgIFAAVAMYaAA==.',['与狼']='与狼共舞:BAAAKgAECgcIBwAAAA==.',['专业']='专业战复:BAAAKgAECgEIAQAAAA==.',['丨墨']='丨墨悲丝染丨:BAAAKgADCgUIBQAAAA==.',['丨贱']='丨贱咗萌丨:BAAAKgAECgUIBQAAAA==.丨贱袏萌丨:BAACKgAFFH8GAAICAAMILgYPawCVAAACAAMILgYPawCVAAAqAAQKfx8AAgIACAiTDpWZAGQBAAIACAiTDpWZAGQBAAAA.',['丰饶']='丰饶孤屿:BAAAKgAECggICgAAAA==.丰饶孤岛:BAABKgAFFH8LAAMNAAgIhRymCQDaAQANAAcIXh2mCQDaAQAWAAEIiRMvCgBLAAAAAA==.',['丶南']='丶南吕九:BAABKgAFFH8IAAITAAQI/hVsMQC5AAATAAQI/hVsMQC5AAAAAA==.',['丶夜']='丶夜未央:BAAAKgAFFAYIBAAAAA==.',['丶屁']='丶屁屁能泛光:BAAAKgADCgEIAQAAAA==.',['丶无']='丶无罪:BAAAKgAECgUIBgAAAA==.',['丶浴']='丶浴火凤凰灬:BAABKgAFFH8KAAICAAYIwh2lEwC/AQACAAYIwh2lEwC/AQAAAA==.',['丶潇']='丶潇湘夜雨:BAABKgAFFH8IAAMSAAQIjhr4CQDPAAAXAAQIjhrCGQDvAAASAAQIRw34CQDPAAAAAA==.',['丶猎']='丶猎手:BAAAKgAFFAEIAQAAAA==.',['丷大']='丷大汪丷:BAAAKgAECgQIBAAAAA==.',['乌鸦']='乌鸦坐飞机:BAABKgAFFH8GAAIHAAYIkwwbCwBhAQAHAAYIkwwbCwBhAQAAAA==.',['二代']='二代目宸宸:BAAAKgAECgEIAQABKgAFFAYIJAAHAN8GAA==.',['二六']='二六的遗志:BAAAKgAECgUIBQAAAA==.',['二次']='二次小晴天:BAABKgAFFH8GAAIGAAMIShWoIgC6AAAGAAMIShWoIgC6AAAAAA==.',['二郎']='二郎:BAAAKgADCgUIBQAAAA==.',['于老']='于老大:BAABKgAFFH8IAAIBAAgIAwc9CgCwAQABAAgIAwc9CgCwAQAAAA==.',['人才']='人才銷售:BAAAKgAECgYIBgAAAA==.',['什么']='什么赛博酷刑:BAAAKgAECgEIAQAAAA==.',['今天']='今天出坐骑:BAAAKgAECgcIDQAAAA==.',['从头']='从头开始:BAAAKgAECggIEgAAAA==.',['伊扎']='伊扎克真:BAAAKgAECgMIAwAAAA==.',['伊格']='伊格尼斯:BAAAKgADCgMIAwAAAA==.',['佐邊']='佐邊是鼬:BAAAKgAECgUIBQAAAA==.',['佑逝']='佑逝:BAABKgAECn8rAAIGAAgIHhK1JwCvAQAGAAgIHhK1JwCvAQAAAA==.',['何以']='何以报德:BAAAKgADCggIEAAAAA==.',['你的']='你的男爵:BAACKgAFFH8RAAIYAAQICBe5FgC9AAAYAAQICBe5FgC9AAAqAAQKfxsAAhgACAiGGAU1AKIBABgACAiGGAU1AKIBAAAA.',['依然']='依然不惊:BAAAKgAECggICwAAAA==.',['俺老']='俺老娘也姓毕:BAAAKgADCgEIAQAAAA==.',['做什']='做什么好呢:BAAAKgAECgIIAgAAAA==.',['光明']='光明布丁:BAAAKgADCgEIAQAAAA==.',['光灬']='光灬耀:BAAAKgAECgYIDgAAAA==.',['光铸']='光铸十八籽:BAABKgAFFH8QAAICAAQIeiRgCAA7AQACAAQIeiRgCAA7AQABKgAFFAgIBAAVAAcHAA==.',['兔缺']='兔缺缺:BAACKgAFFH8vAAIPAAgIJh3oAQBQAgAPAAgIJh3oAQBQAgAqAAQKfxwAAg8ACAjUJfECAN0CAA8ACAjUJfECAN0CAAAA.',['公主']='公主请上车:BAABKgAFFH8WAAMZAAYIgxt/BwADAQAaAAYIgxsJEgB4AQAZAAUIBg1/BwADAQAAAA==.',['公子']='公子冥:BAAAKgADCgYIBgAAAA==.',['六六']='六六爸的劣人:BAAAKgAECgUIBQAAAA==.',['六道']='六道众神:BAAAKgAECggICAAAAA==.',['兽神']='兽神骑士:BAAAKgAECgEIAQAAAA==.',['冰火']='冰火羽翼:BAAAKgADCgcIAwAAAA==.',['冰瓜']='冰瓜:BAACKgAFFH8FAAMbAAIIoRFqHQBwAAAHAAIIFAtKJwCJAAAbAAIIdA9qHQBwAAAqAAQKfxoAAwcACAj9IcwOAKsCAAcACAj9IcwOAKsCABsAAQhrCIhoACYAAAAA.',['凌汐']='凌汐丶:BAAAKgAFFAQIAQAAAA==.',['凯瑟']='凯瑟琳之殇:BAAAKgAFFAgIBAAAAA==.',['凯莉']='凯莉根:BAAAKgAFFAMIAwAAAA==.',['凶煞']='凶煞邪神:BAAAKgADCgUIBQAAAA==.',['凸毕']='凸毕呐波丸:BAAAKgAECgYIDAAAAA==.',['刀刀']='刀刀射射:BAAAKgAFFAMIAwAAAA==.',['利利']='利利亚:BAAAKgAFFAMIAwAAAA==.',['别撕']='别撕我喜欢脱:BAAAKgAECgEIAgAAAA==.',['加莎']='加莎莉亚:BAAAKgAECgQIBQAAAA==.',['加菲']='加菲猫贼可爱:BAAAKgADCgEIAQAAAA==.',['勇敢']='勇敢的蚊子:BAAAKgAFFAIIAgAAAA==.',['十五']='十五码上树:BAAAKgAECgIIAgAAAA==.',['南宫']='南宫九:BAABKgAFFH8PAAICAAYIuyG1EwC+AQACAAYIuyG1EwC+AQABKgAFFAgIDgACAAwlAA==.',['卡达']='卡达恰恰:BAABKgAFFH8IAAITAAYI/RfGDgAGAQATAAYI/RfGDgAGAQAAAA==.',['原味']='原味少女心:BAAAKgAECggIEAAAAA==.原味贝果:BAAAKgAECgYICAAAAA==.',['古爸']='古爸爸三号:BAABKgAECn8VAAIYAAgIQyACJwDkAQAYAAgIQyACJwDkAQAAAA==.古爸爸二号:BAAAKgAECgYIBgAAAA==.古爸爸五号:BAABKgAECn8dAAMGAAcIuyLFEgAvAgAGAAcIuyLFEgAvAgAFAAEIXQcHhwAfAAAAAA==.',['吃猫']='吃猫老鼠:BAAAKgADCgMIAwAAAA==.',['吉多']='吉多多:BAAAKgAECgIIAgAAAA==.',['吟得']='吟得一首好诗:BAAAKgADCgcIBwAAAA==.',['听它']='听它的:BAAAKgAECgYIBgAAAA==.',['听说']='听说:BAAAKgADCggICQAAAA==.',['吼姆']='吼姆拉灬:BAAAKgADCggICAAAAA==.',['咕咕']='咕咕噜噜:BAAAKgAECgcIBgAAAA==.',['哲哲']='哲哲不可以:BAAAKgAECgUIBQABKgAFFAgILwAPACYdAA==.',['唔西']='唔西迪西:BAABKgAECn8sAAICAAgIlyFSGQCgAgACAAgIlyFSGQCgAgAAAA==.',['唯恋']='唯恋慧:BAABKgAFFH8MAAIbAAYIyhGJBABJAQAbAAYIyhGJBABJAQABKgAFFAgIIAAbAFUQAA==.',['噌丶']='噌丶风暴假酒:BAABKgAECn8dAAIUAAgI4x/YCQB+AgAUAAgI4x/YCQB+AgABKgAFFAgIMgAcAAgQAA==.',['囫囵']='囫囵:BAAAKgAECgEIAQAAAA==.',['国有']='国有国法丶:BAAAKgAECggIEQAAAA==.',['土司']='土司:BAACKgAFFH8YAAIJAAQI4Q/LGQCuAAAJAAQI4Q/LGQCuAAAqAAQKfzgAAgkACAgWG9YgAAcCAAkACAgWG9YgAAcCAAAA.',['圣之']='圣之意羽:BAAAKgAFFAgIBAAAAA==.',['圣彼']='圣彼得:BAABKgAECn8bAAICAAgIhSOCBQDbAgACAAgIhSOCBQDbAgAAAA==.',['地心']='地心之战一号:BAAAKgAECgEIAQAAAA==.',['地狱']='地狱莫斯利安:BAABKgAECn8WAAICAAgIuxA6iwA3AQACAAgIuxA6iwA3AQAAAA==.',['地獄']='地獄丘比特:BAAAKgAECggICQAAAA==.',['坟头']='坟头种树:BAAAKgAECgEIAQAAAA==.',['坠碧']='坠碧简殇映:BAAAKgAECgMIAwAAAA==.',['埃塞']='埃塞拉丝特:BAAAKgAFFAQIBAAAAA==.',['城下']='城下一会:BAAAKgADCggICwAAAA==.',['基德']='基德爵士:BAAAKgADCgMIAwAAAA==.',['声东']='声东击西嘻嘻:BAABKgAFFH8IAAIBAAgI0RPOBgAZAgABAAgI0RPOBgAZAgAAAA==.',['处刑']='处刑者:BAAAKgAFFAgIAQAAAA==.',['复苏']='复苏之风:BAAAKgAFFAEIAQAAAA==.',['夏松']='夏松桥:BAAAKgAECgMIBQAAAA==.',['多啦']='多啦唉梦:BAABKgAECn8cAAMdAAgIXBu2EgA8AgAdAAgIXBu2EgA8AgAYAAQIUw8moABkAAAAAA==.',['夢灯']='夢灯籠:BAAAKgAFFAQIBAAAAA==.',['夢痕']='夢痕潸然東去:BAAAKgADCggICAAAAA==.',['大山']='大山弯弯:BAAAKgAFFAQIBAAAAA==.',['大角']='大角牛历险记:BAAAKgAFFAEIAQAAAA==.',['天台']='天台云水:BAAAKgAECggICAAAAA==.',['天塌']='天塌下来我顶:BAAAKgADCgEIAQAAAA==.',['天宇']='天宇寒星:BAACKgAFFH8GAAIDAAMIsgd6HQCBAAADAAMIsgd6HQCBAAAqAAQKfyAAAwMACAjtEWsnAKQBAAMACAjtEWsnAKQBAB4ABQh4C7kUAJwAAAAA.',['天格']='天格一品:BAAAKgADCgIIAgAAAA==.',['失忆']='失忆的惆怅:BAAAKgAECgYIBgAAAA==.',['奈茶']='奈茶的雪:BAACKgAFFH8NAAIBAAQIyCXMCQA0AQABAAQIyCXMCQA0AQAqAAQKfxYAAgEACAiwItsMANICAAEACAiwItsMANICAAAA.',['女民']='女民兵队长:BAABKgAECn8cAAMDAAgIhR/OFABSAgADAAgIhR/OFABSAgABAAcIaxO4iwC5AAAAAA==.',['她的']='她的名字:BAAAKgADCgMIAwAAAA==.',['好叻']='好叻没丶哥:BAACKgAFFH8TAAIaAAgIHxL7CgDcAQAaAAgIHxL7CgDcAQAqAAQKfx4AAhoACAggGTsgAAMCABoACAggGTsgAAMCAAAA.',['好吃']='好吃看得见:BAAAKgAECgQIBAAAAA==.',['妮娜']='妮娜李贝特:BAAAKgAECgMIAwAAAA==.',['姜岁']='姜岁岁:BAAAKgAECgQICAAAAA==.',['婆卢']='婆卢羯啼:BAAAKgADCggICAAAAA==.',['嫫失']='嫫失镆忘:BAAAKgAFFAgIBAAAAA==.',['孤勇']='孤勇者:BAAAKgAFFAQIBAAAAA==.',['孤雨']='孤雨随风:BAAAKgAECgEIAQAAAA==.',['孪蛇']='孪蛇:BAAAKgAECgcICgAAAA==.',['安妮']='安妮弗妮佩尔:BAABKgAFFH8GAAIIAAYIvhbHCwCQAQAIAAYIvhbHCwCQAQAAAA==.',['宝宝']='宝宝大人:BAABKgAFFH8GAAINAAYIrhaFDwBoAQANAAYIrhaFDwBoAQAAAA==.',['富态']='富态武僧:BAABKgAFFH8IAAIVAAQIFRpaGADcAAAVAAQIFRpaGADcAAAAAA==.',['寒潭']='寒潭雁渡:BAABKgAFFH8KAAITAAQIuyGVDQANAQATAAQIuyGVDQANAQAAAA==.',['射穿']='射穿紫弓:BAAAKgAFFAIIAgAAAA==.',['小井']='小井丿丹丹:BAACKgAFFH8KAAMfAAMIZBgnEACiAAAfAAIIjBgnEACiAAAaAAIIRROOIgCGAAAqAAQKfycABBoACAj0HUwsAMMBABoABwjAHkwsAMMBAB8ABAhSHSQZACcBABkAAwiMEwFbAIcAAAAA.',['小奕']='小奕辰:BAAAKgADCgIIAgAAAA==.',['小小']='小小姗姗:BAAAKgAECgEIAQAAAA==.小小熊奶糖:BAABKgAECn8WAAITAAgIoBHJQgCdAQATAAgIoBHJQgCdAQAAAA==.小小熊水果糖:BAABKgAFFH8JAAIaAAMINhHeMACrAAAaAAMINhHeMACrAAAAAA==.',['小布']='小布丁两块:BAAAKgADCgUIBwAAAA==.',['小徐']='小徐搞人王:BAAAKgAECgMIAwAAAA==.',['小愚']='小愚:BAAAKgAECgIIAgAAAA==.',['小泰']='小泰的男友:BAAAKgADCgIIAwAAAA==.',['小猪']='小猪趴趴:BAABKgAECn8dAAMgAAUIfwggPQCQAAAgAAUIzwcgPQCQAAACAAQIbgZgYgCBAAAAAA==.',['小猫']='小猫咪丫:BAAAKgAFFAEIAgAAAA==.',['小玛']='小玛:BAAAKgAECggIDwABKgAFFAcIIQAaAM0ZAA==.',['小紫']='小紫苏:BAABKgAFFH8KAAITAAQIChQkKwDMAAATAAQIChQkKwDMAAAAAA==.',['小车']='小车车:BAAAKgAFFAIIAgAAAA==.',['小鱼']='小鱼兒:BAAAKgAECgQIBQAAAA==.',['小鸡']='小鸡嚼:BAABKgAFFH8SAAIMAAQIowYaIACKAAAMAAQIowYaIACKAAAAAA==.',['就爱']='就爱插菊花:BAAAKgAFFAMIBAAAAA==.',['屁奇']='屁奇猪:BAABKgAFFH8OAAIFAAgIXhkJAwA8AgAFAAgIXhkJAwA8AgAAAA==.',['山鸡']='山鸡爷:BAABKgAFFH8GAAMLAAIIrhk+MwCWAAALAAIIrhk+MwCWAAAJAAEIChclKgBCAAAAAA==.',['岂有']='岂有此理呀:BAAAKgADCggICAAAAA==.',['巧乐']='巧乐兹六块五:BAABKgAFFH8FAAIXAAMIJhRKGwDoAAAXAAMIJhRKGwDoAAAAAA==.',['巴度']='巴度妖:BAABKgAFFH8IAAMbAAYI6BS/DQA8AQAbAAYI6BS/DQA8AQAHAAIIig40RgCHAAAAAA==.',['帅本']='帅本无罪:BAAAKgAECgYIEgAAAA==.',['希尔']='希尔丶佳丽斯:BAACKgAFFH8zAAIXAAgIshfFCADKAQAXAAgIshfFCADKAQAqAAQKfzIAAhcACAjoI2wGANoCABcACAjoI2wGANoCAAAA.',['帕奎']='帕奎尔:BAAAKgAECgEIAQAAAA==.',['帕德']='帕德梅:BAABKgAFFH8GAAIJAAMIPxgCEQDaAAAJAAMIPxgCEQDaAAABKgAFFAYIMgACANEkAA==.',['带甜']='带甜的微笑:BAAAKgAECgYIBgAAAA==.',['年少']='年少雪吻:BAABKgAFFH8SAAIDAAYI1R92DgB3AQADAAYI1R92DgB3AQAAAA==.',['幸福']='幸福大哥:BAAAKgAECgUIBQAAAA==.幸福滴味道:BAAAKgAECgcIBwAAAA==.',['幽梦']='幽梦影:BAABKgAFFH8GAAIVAAQI2htADQD6AAAVAAQI2htADQD6AAAAAA==.',['幽灵']='幽灵鲨:BAAAKgAECgYICQAAAA==.',['廉颇']='廉颇老矣:BAAAKgAFFAYIAQABKgAFFAgIEAAFAC0SAA==.',['开门']='开门五百:BAAAKgAECgUICAAAAA==.',['异彩']='异彩流觞:BAAAKgADCggIEAAAAA==.',['弥灬']='弥灬生:BAAAKgADCgQIBAAAAA==.',['强韧']='强韧无敌最强:BAAAKgAECggIEQABKgAFFAMIBQASAI0XAA==.',['影之']='影之愤怒:BAABKgAECn8gAAMTAAgIMSH1EgCVAgATAAgIrCD1EgCVAgAUAAIIqhDKVgBsAAAAAA==.',['徐地']='徐地过往:BAAAKgAECgYIBgAAAA==.',['徐总']='徐总牛逼:BAAAKgAFFAQIBAAAAA==.',['微风']='微风轻抚丶:BAAAKgAECgQIBAAAAA==.',['德德']='德德鲁的逆袭:BAABKgAFFH8GAAIQAAYIiRlcEgCKAQAQAAYIiRlcEgCKAQAAAA==.',['德拉']='德拉諾:BAAAKgADCgcIBwAAAA==.',['心如']='心如芷水:BAAAKgAECgEIAQAAAA==.',['心心']='心心念念:BAAAKgAECgEIAQAAAA==.',['忆之']='忆之破魂:BAAAKgAECgIIAgAAAA==.',['忆枫']='忆枫圣:BAAAKgAFFAQIBAAAAA==.',['恋恋']='恋恋清纯:BAAAKgADCgEIAwAAAA==.',['恋生']='恋生花:BAABKgAECn8cAAIKAAgI0BRrNwC3AQAKAAgI0BRrNwC3AQAAAA==.',['恶魔']='恶魔之歌:BAAAKgAECgUIBwAAAA==.恶魔破晓:BAACKgAFFH8XAAITAAMIRR3aIgDxAAATAAMIRR3aIgDxAAAqAAQKf14AAxMACAiuInYLAK0CABMACAiuInYLAK0CABQABgheDxY1AOkAAAAA.恶魔神猎手:BAAAKgAECggIEAAAAA==.',['悍颜']='悍颜霸乳:BAAAKgAFFAgIBAAAAA==.',['悲雕']='悲雕的木木:BAAAKgAECgYIDAAAAA==.',['想笑']='想笑:BAAAKgADCgcIBwAAAA==.',['憨憨']='憨憨禕:BAABKgAECn8ZAAICAAgIkB4DLQBLAgACAAgIkB4DLQBLAgAAAA==.',['我不']='我不是神是人:BAAAKgADCgUIBQAAAA==.',['我将']='我将带头冲釒:BAACKgAFFH8FAAISAAMIjRdFBwD0AAASAAMIjRdFBwD0AAAqAAQKfyMAAxIACAhGILsLAGgCABIACAhGILsLAGgCABcAAQhzEfeNAD0AAAAA.',['我就']='我就是小红:BAACKgAFFH8kAAIhAAgIkhs5AgDOAQAhAAgIkhs5AgDOAQAqAAQKfzEAAiEACAhvJQACAN8CACEACAhvJQACAN8CAAAA.',['我有']='我有点烦:BAABKgAFFH8IAAILAAQIvgdXOwB0AAALAAQIvgdXOwB0AAAAAA==.',['我非']='我非落花:BAABKgAFFH8OAAMCAAQI+woILQCwAAACAAQI8QgILQCwAAAgAAMILginIgBuAAAAAA==.',['戒糖']='戒糖失败:BAABKgAFFH8VAAMaAAYISRNxDgBUAQAaAAUISRNxDgBUAQAZAAEIAAB1NwAAAAAAAA==.',['战争']='战争大师黑角:BAAAKgAECgEIAQAAAA==.战争小土人:BAAAKgAECgEIAQAAAA==.',['战圭']='战圭:BAAAKgADCggICAAAAA==.',['戦场']='戦场原荡漾:BAACKgAFFH8GAAIgAAYIAxxlCACDAQAgAAYIAxxlCACDAQAqAAQKfx4AAgIACAiQIfAeAIcCAAIACAiQIfAeAIcCAAAA.',['戦颜']='戦颜丶纳兰:BAAAKgAECgMIBQAAAA==.戦颜丶雪伊:BAAAKgAECggICgAAAA==.',['打土']='打土豪:BAAAKgADCgQIBAABKgAECggIGwAJACUXAA==.',['折戟']='折戟沉沙:BAAAKgAFFAQIBAAAAA==.',['抽抽']='抽抽丶晚汐:BAAAKgAFFAIIAgAAAA==.',['指尖']='指尖上的圣光:BAABKgAFFH8IAAIFAAgIYg3PBQDaAQAFAAgIYg3PBQDaAQAAAA==.',['挊他']='挊他:BAABKgAFFH8GAAIHAAYItBFVGQBSAQAHAAYItBFVGQBSAQAAAA==.',['掌控']='掌控未来力量:BAAAKgAECgEIAQAAAA==.',['搓搓']='搓搓球:BAAAKgAFFAIIAgAAAA==.',['摩蝎']='摩蝎:BAAAKgAECgUIBgAAAA==.',['文姜']='文姜:BAABKgAFFH8GAAIbAAYITA7dEgALAQAbAAYITA7dEgALAQAAAA==.',['无忌']='无忌哥哥:BAAAKgAECgQIBQAAAA==.',['无情']='无情的大哥:BAAAKgAECgcICQAAAA==.无情的梅子:BAABKgAFFH8JAAIYAAQIph+UHwD8AAAYAAQIph+UHwD8AAAAAA==.无情的梨子:BAACKgAFFH8vAAIQAAgIISPLBwAiAgAQAAgIISPLBwAiAgAqAAQKfy4AAxAACAg2Jv0IANYCABAACAg2Jv0IANYCACIAAQjxC9MyACUAAAAA.',['无海']='无海无崖:BAAAKgAECgYIBgAAAA==.',['无罪']='无罪丶:BAAAKgAECgUICwAAAA==.',['无花']='无花果:BAABKgAFFH8KAAIHAAgIzRonAACEAgAHAAgIzRonAACEAgAAAA==.',['无边']='无边落牧:BAABKgAECn8VAAMGAAgIVRKQNABLAQAGAAgIVRKQNABLAQAFAAYIAwfhWwCuAAAAAA==.',['日出']='日出江花红:BAABKgAFFH8GAAICAAYIwxXzHAB/AQACAAYIwxXzHAB/AQAAAA==.',['时透']='时透无一郎:BAAAKgAECggIDQAAAA==.',['星宿']='星宿佬仙:BAABKgAFFH8IAAINAAgIDgkVDACmAQANAAgIDgkVDACmAQAAAA==.',['星降']='星降:BAAAKgAECggIDAAAAA==.',['春丽']='春丽:BAAAKgADCgMIAwAAAA==.',['晨光']='晨光牧:BAAAKgAECgcICgAAAA==.',['普蕾']='普蕾希亚:BAAAKgAECggIDQAAAA==.',['暗炉']='暗炉堡钢蛋儿:BAAAKgAECgYICgAAAA==.',['暮雪']='暮雪海棠:BAAAKgAECgUICAAAAA==.',['曦月']='曦月情:BAABKgAECn8UAAIYAAYIJxfOUQBJAQAYAAYIJxfOUQBJAQABKgAFFAgICgAgADIWAA==.',['月步']='月步:BAABKgAFFH8GAAIIAAYIfBLpDAB+AQAIAAYIfBLpDAB+AQAAAA==.',['月爪']='月爪:BAAAKgAECgEIAQAAAA==.',['月飞']='月飞:BAAAKgAECgcIBwAAAA==.',['杀神']='杀神白起:BAABKgAFFH8IAAISAAgIahv1AQCAAgASAAgIahv1AQCAAgAAAA==.',['杨贵']='杨贵妃:BAAAKgADCgMIAwAAAA==.',['杨超']='杨超越:BAAAKgADCggICAAAAA==.',['极度']='极度小红帽:BAAAKgAECgMIAwAAAA==.极度砖砖:BAACKgAFFH8FAAQRAAUI3gzFDwCBAAASAAIIlQ1pEACPAAARAAIISQ/FDwCBAAAXAAEIlwb/HwA6AAAqAAQKfxkABBEABwiuEfAgAPsAABcABgjREGNNAC0BABEABwiFDPAgAPsAABIAAwg/EEJJAKgAAAAA.',['极速']='极速风:BAAAKgAECggICAAAAA==.',['林深']='林深不知处:BAABKgAFFH8HAAMQAAQIEAyoHgDCAAAQAAMIEAyoHgDCAAAPAAQIqRQzHADBAAAAAA==.',['某蓝']='某蓝知名主播:BAABKgAFFH8HAAMFAAQIFA/bEQDOAAAFAAQI1g3bEQDOAAAGAAMImQpKGACFAAAAAA==.',['柒仈']='柒仈玖:BAABKgAECn8qAAIQAAgIBxrnDAAlAgAQAAgIBxrnDAAlAgAAAA==.',['柚酱']='柚酱:BAAAKgAECgcIDAAAAA==.',['柠檬']='柠檬苏打:BAAAKgADCgIIAgAAAA==.',['柳北']='柳北奥沙利文:BAAAKgAECgMIAwAAAA==.',['树摇']='树摇红雨落丶:BAAAKgAECggICwAAAA==.',['根浴']='根浴上门到家:BAAAKgAECgEIAQAAAA==.',['格琳']='格琳希尔:BAABKgAECn8UAAICAAgIGBttcwCxAQACAAgIGBttcwCxAQAAAA==.',['桃浦']='桃浦落船花:BAAAKgAFFAIIAgAAAA==.',['桑贾']='桑贾尔:BAAAKgAECgYIEgAAAA==.',['梦魁']='梦魁:BAAAKgADCgEIAQAAAA==.',['棠四']='棠四火:BAAAKgAFFAYIAQAAAA==.',['楊排']='楊排风:BAAAKgAECgQIBAAAAA==.',['榛名']='榛名改二:BAAAKgAECgcICgAAAA==.',['榴芒']='榴芒:BAACKgAFFH8PAAMQAAYICxk+CwAVAQAQAAQICx4+CwAVAQAPAAYI5Q5OEQCrAAAqAAQKfxgAAxAACAiUIOIbAGICABAACAiUIOIbAGICACIAAQieCxJAACIAAAAA.',['橡皮']='橡皮尼:BAAAKgAECgQIBAAAAA==.',['欧美']='欧美专区:BAABKgAFFH8LAAMHAAYIaR0/EACbAQAHAAYIaR0/EACbAQAbAAQIMhAoIQCdAAAAAA==.',['正太']='正太脸大叔心:BAABKgAFFH8IAAIDAAgIHhXRBQATAgADAAgIHhXRBQATAgAAAA==.',['步步']='步步生花:BAAAKgADCggIDQAAAA==.',['武曾']='武曾:BAAAKgAECgYIBgAAAA==.',['歪睿']='歪睿古德:BAABKgAFFH8LAAMQAAYI1hA5GQBPAQAQAAYI1hA5GQBPAQAPAAQI/wkhJwCJAAAAAA==.',['殇玥']='殇玥:BAABKgAFFH8IAAMOAAQIFhgQCwD5AAAOAAQIFhgQCwD5AAAYAAQIawpMGADDAAAAAA==.',['永不']='永不停射:BAAAKgADCgQIBAAAAA==.',['永恆']='永恆愛你:BAAAKgAFFAQIBAAAAA==.',['氺琥']='氺琥珀:BAAAKgAECgYIBgAAAA==.',['沉默']='沉默乂分钟:BAABKgAECn8UAAINAAgIYBrDIQCsAQANAAgIYBrDIQCsAQAAAA==.沉默的大姨妈:BAABKgAFFH8GAAIGAAYIGByyBwCuAQAGAAYIGByyBwCuAQAAAA==.',['没法']='没法捏脸啊:BAACKgAFFH8rAAQMAAgIzxNrCgBaAQAMAAYI2BZrCgBaAQAFAAUINBJUHACzAAAGAAQIiAYeGAB+AAAqAAQKfzUABAUACAgHHFwXAAgCAAUACAgHHFwXAAgCAAwABQjZExA1AD0BAAYACAjWB3xaAKsAAAAA.',['沧溟']='沧溟之末:BAAAKgAECgEIAQAAAA==.',['河莉']='河莉秀:BAAAKgAECgIIAgAAAA==.',['泡馍']='泡馍:BAAAKgAECggIDAAAAA==.',['泰蘭']='泰蘭德的天空:BAABKgAFFH8GAAIQAAYIDg+YEABcAQAQAAYIDg+YEABcAQAAAA==.',['洒满']='洒满基斯:BAABKgAECn8VAAIdAAgImBO4OABTAQAdAAgImBO4OABTAQAAAA==.',['洗猫']='洗猫:BAACKgAFFH8NAAIZAAMIICBDBgAVAQAZAAMIICBDBgAVAQAqAAQKfxQAAhkACAgDHVAOABICABkACAgDHVAOABICAAAA.',['洛妮']='洛妮卡:BAABKgAECn8VAAIXAAgI1QjrQABuAQAXAAgI1QjrQABuAQAAAA==.',['洛德']='洛德曼:BAAAKgAECgcICgAAAA==.',['洞洞']='洞洞糕:BAAAKgADCgIIAgABKgAFFAQIDgACAPsKAA==.',['流光']='流光斜:BAAAKgAECgYIBgAAAA==.',['流萤']='流萤:BAABKgAFFH8IAAIIAAMIGAymHADHAAAIAAMIGAymHADHAAAAAA==.',['浅仓']='浅仓小南:BAAAKgAECgQIBAAAAA==.',['浩宇']='浩宇之影:BAAAKgAFFAYIAgAAAA==.',['消失']='消失的锤子:BAAAKgAECgYIDAAAAA==.',['深蓝']='深蓝的爱:BAAAKgAECgEIAQAAAA==.',['清新']='清新雅致:BAAAKgADCgEIAQAAAA==.',['滕冈']='滕冈春绯:BAABKgAFFH8GAAICAAYIahHiEgBvAQACAAYIahHiEgBvAQAAAA==.',['滚滚']='滚滚:BAAAKgAECgUIBQAAAA==.',['滴屁']='滴屁爱斯帝伊:BAAAKgADCggICAAAAA==.',['演丶']='演丶丶员:BAABKgAECn8UAAMYAAgIeBccNQCyAQAYAAgIeBccNQCyAQAdAAEIlweENAAlAAAAAA==.演丶员:BAAAKgAECggIEwAAAA==.',['灌江']='灌江口话事人:BAAAKgAECgEIAQAAAA==.',['火羽']='火羽冰翼:BAAAKgADCggICwAAAA==.',['灰原']='灰原哀:BAAAKgAECgQICAAAAA==.',['灵魂']='灵魂秒杀:BAAAKgAECgEIAQAAAA==.',['炎月']='炎月冷钢:BAAAKgAECgYIBgAAAA==.',['烛龙']='烛龙思烛夜:BAABKgAFFH8FAAMZAAMI/hRxFgCUAAAZAAIIKxVxFgCUAAAfAAEIoxSwIABIAAAAAA==.',['烟雨']='烟雨牧牧:BAABKgAFFH8FAAMFAAUIlAvPEgDIAAAFAAQI2gjPEgDIAAAMAAEIuRxxIABhAAAAAA==.烟雨霏霏:BAABKgAFFH8GAAIRAAYI1gg+CADkAAARAAYI1gg+CADkAAAAAA==.',['烧焦']='烧焦的火:BAAAKgAFFAQIBAAAAA==.',['烹茶']='烹茶煮酒:BAABKgAFFH8FAAMVAAUInQnQIwCUAAAVAAQIDwrQIwCUAAAjAAEIPgU3FQBIAAAAAA==.',['煌凰']='煌凰:BAAAKgAECgEIAQAAAA==.',['熊熊']='熊熊胸凶:BAAAKgADCgYIBgAAAA==.',['爬墙']='爬墙看美女:BAABKgAFFH8GAAIBAAYIVAvhHQDfAAABAAYIVAvhHQDfAAAAAA==.',['爱吃']='爱吃波罗蜜:BAAAKgAECggICAAAAA==.',['爱笑']='爱笑的天天艺:BAAAKgAFFAIIAgAAAA==.',['牧帅']='牧帅:BAAAKgAECgUICQAAAA==.',['牧牧']='牧牧姐:BAABKgAFFH8FAAMGAAMIIgSTFACbAAAGAAMIOQKTFACbAAAFAAEI9gYsKwA4AAAAAA==.',['狄安']='狄安娜:BAAAKgADCggICAAAAA==.',['狐人']='狐人总冠军:BAABKgAECn8VAAIYAAcIqhrYMgC8AQAYAAcIqhrYMgC8AQAAAA==.',['狡小']='狡小狐:BAAAKgADCggICAAAAA==.',['独爱']='独爱小宝:BAAAKgAECgEIAQAAAA==.',['猎爸']='猎爸灬天下:BAAAKgAFFAQIBAAAAA==.',['猟人']='猟人:BAAAKgADCgQIBAAAAA==.',['猦曟']='猦曟哋颩:BAAAKgADCgEIAQAAAA==.',['猫憨']='猫憨憨:BAAAKgADCgUIBQAAAA==.',['猴宝']='猴宝子:BAAAKgAECgIIAgAAAA==.',['玛尔']='玛尔斯:BAACKgAFFH8yAAICAAYI0SSVDAAiAQACAAYI0SSVDAAiAQAqAAQKf0AAAgIACAg8JkQcAKcCAAIACAg8JkQcAKcCAAAA.',['玥戰']='玥戰:BAABKgAFFH8GAAISAAYI5g9ACwBaAQASAAYI5g9ACwBaAQAAAA==.',['珩珩']='珩珩:BAABKgAFFH8UAAMgAAgI+BzFAwAtAgAgAAgIrhvFAwAtAgACAAQIQBokFAAHAQAAAA==.',['珩龙']='珩龙龙:BAABKgAFFH8OAAMHAAgIugo1BwDcAQAHAAgI8gk1BwDcAQAbAAYIeQcrGgDRAAAAAA==.',['琥珀']='琥珀风之歌:BAAAKgAFFAMIAwAAAA==.',['瓦丨']='瓦丨解:BAAAKgAECgQIBAAAAA==.',['生腌']='生腌海鲜:BAAAKgAFFAQIBAAAAA==.',['电刀']='电刀波比:BAAAKgAECgUIBQAAAA==.',['男人']='男人无泪:BAAAKgAECggIEwAAAA==.',['當归']='當归:BAAAKgAECggIDwAAAA==.',['疯狂']='疯狂的吉多多:BAAAKgAECgIIAgAAAA==.',['白天']='白天做梦:BAAAKgAECgUICQAAAA==.',['白木']='白木公主:BAEAKgAECggICAAAAA==.',['白楼']='白楼独舞:BAABKgAFFH8IAAICAAgISQynCwDnAQACAAgISQynCwDnAQAAAA==.',['白沐']='白沐鱼:BAABKgAFFH8IAAITAAgILSB6BACDAgATAAgILSB6BACDAgAAAA==.',['盛开']='盛开的菊花:BAABKgAECn8kAAMQAAgIrByLHwBEAgAQAAgIrByLHwBEAgAPAAMIlg6YZACHAAAAAA==.',['真的']='真的好痛:BAABKgAFFH8SAAMaAAYIDx2qEACIAQAaAAYIDx2qEACIAQAZAAIIaBUhEwBUAAAAAA==.',['睦灬']='睦灬月:BAAAKgAECgUIBQAAAA==.',['知乎']='知乎者也:BAABKgAFFH8GAAIBAAYIUBPYEwBWAQABAAYIUBPYEwBWAQAAAA==.',['知我']='知我:BAABKgAECn8YAAIHAAgIrh7nLwDzAQAHAAgIrh7nLwDzAQAAAA==.',['硬玩']='硬玩火法:BAAAKgAFFAEIAQABKgAFFAgIDQAKAPEVAA==.',['礼仪']='礼仪之邦梆梆:BAAAKgAECggICAAAAA==.',['社报']='社报上天:BAAAKgAECgIIAgAAAA==.',['祝踏']='祝踏岚:BAABKgAECn8kAAMVAAgIpB1+FgA0AgAVAAgIpB1+FgA0AgAjAAMI8hhKSADjAAAAAA==.',['移花']='移花接玉:BAABKgAFFH8LAAIPAAQITxSSEACRAAAPAAQITxSSEACRAAAAAA==.',['空之']='空之执杖铛铛:BAAAKgAECggICAAAAA==.',['笨笨']='笨笨的小熊:BAAAKgAECgcICAAAAA==.',['第亿']='第亿代死神:BAABKgAFFH8OAAMVAAYIZhkpCQCaAQAVAAYIZhkpCQCaAQAjAAEI1QHCIQA2AAAAAA==.',['第十']='第十类危险品:BAABKgAFFH8KAAIDAAYI7B6VDwBrAQADAAYI7B6VDwBrAQAAAA==.',['第贰']='第贰梦:BAAAKgADCgUIBQAAAA==.',['箭神']='箭神:BAAAKgAFFAEIAQAAAA==.',['米帅']='米帅:BAAAKgAECggIEwAAAA==.',['米米']='米米可可:BAABKgAFFH8JAAIFAAMINQQlJQCLAAAFAAMINQQlJQCLAAAAAA==.',['紫妮']='紫妮:BAACKgAFFH8rAAMeAAgIQhvcAABkAQAeAAYIUBzcAABkAQABAAYIoxUdHwASAQAqAAQKfzEAAx4ACAiIJcYAAPECAB4ACAiIJcYAAPECAAEABwgQIMasAMsAAAAA.',['紫色']='紫色猫灵:BAABKgAFFH8MAAMQAAQIowssOwC4AAAQAAQIowssOwC4AAAPAAQIwwfYEACuAAAAAA==.',['纪浮']='纪浮生:BAABKgAFFH8OAAMLAAMIoRibIADmAAALAAMIoRibIADmAAAJAAMIeAxdGwCmAAAAAA==.',['给我']='给我三百块:BAAAKgAECgMIAwAAAA==.',['绿糖']='绿糖有毒:BAAAKgADCggICAAAAA==.',['缘木']='缘木:BAAAKgADCgQIBAAAAA==.',['羊驼']='羊驼大仙:BAAAKgAECggIBAAAAA==.',['群狼']='群狼啸月:BAABKgAFFH8GAAIDAAYIrg7EFQA2AQADAAYIrg7EFQA2AQAAAA==.',['羽毛']='羽毛球:BAAAKgAECggICAAAAA==.',['老白']='老白丶:BAABKgAECn8uAAIJAAgIdCFxCwCoAgAJAAgIdCFxCwCoAgAAAA==.',['老肩']='老肩巨滑:BAABKgAFFH8IAAIXAAQIIA5iIgDJAAAXAAQIIA5iIgDJAAAAAA==.',['老黄']='老黄忠:BAABKgAFFH8WAAMBAAgIbR0gAwCXAgABAAgIbR0gAwCXAgADAAQIoRGOGQCbAAAAAA==.',['聖姬']='聖姬:BAAAKgADCgQIBAAAAA==.',['聖骑']='聖骑:BAAAKgAFFAEIAQAAAA==.',['肉球']='肉球:BAAAKgAECgEIAQAAAA==.',['肉粉']='肉粉:BAAAKgAECgYIBgAAAA==.',['肥泡']='肥泡泡:BAACKgAFFH8tAAMMAAUIcBtNCQBVAQAMAAUIcBtNCQBVAQAGAAQIZiI2AwAvAQAqAAQKfxoAAgYACAg2HegYAA0CAAYACAg2HegYAA0CAAEqAAUUCAgvAA8AJh0A.',['肺找']='肺找肺:BAAAKgAECgQIBAAAAA==.',['背黑']='背黑锅的我来:BAAAKgAECgIIAgAAAA==.',['胧胭']='胧胭:BAAAKgAECgQIBAAAAA==.',['能打']='能打能加能扛:BAAAKgAFFAMIAwAAAA==.',['脱水']='脱水水:BAAAKgAFFAIIAgAAAA==.',['艾西']='艾西妲:BAABKgAFFH8IAAILAAQI9BHOAgDHAAALAAQI9BHOAgDHAAAAAA==.',['芒果']='芒果很黄:BAABKgAFFH8FAAITAAQIciEAGwDZAAATAAQIciEAGwDZAAAAAA==.',['芬碧']='芬碧雪乐可达:BAAAKgAECgUIBQAAAA==.',['花开']='花开富贵:BAAAKgADCggICAAAAA==.',['芹泽']='芹泽千枝实:BAABKgAECn8WAAIDAAgIaRWrHwDWAQADAAgIaRWrHwDWAQAAAA==.',['苍白']='苍白骸骨:BAAAKgAECggIEQAAAA==.',['苏暖']='苏暖暖:BAABKgAFFH8KAAMNAAYIMx9SAQDeAQANAAYIMx9SAQDeAQAWAAQICQXOBQClAAAAAA==.',['苔丝']='苔丝丽:BAAAKgAECgUIBQAAAA==.',['草莓']='草莓小熊软糖:BAAAKgAECgUIBAAAAA==.',['荻荻']='荻荻:BAACKgAFFH8LAAIYAAYIQx+ICQCtAQAYAAYIQx+ICQCtAQAqAAQKfxsAAhgACAhaFGsdAEEBABgACAhaFGsdAEEBAAAA.',['莉娜']='莉娜茵芭斯:BAABKgAFFH8aAAMJAAYI2yXeAQAQAgAJAAYINyXeAQAQAgALAAYI6SK/CADqAQABKgAFFAgIFAALADQjAA==.',['莪杺']='莪杺畩舊:BAACKgAFFH8FAAIIAAMIOhABGwDTAAAIAAMIOhABGwDTAAAqAAQKfykAAggACAiiHI4NAEYCAAgACAiiHI4NAEYCAAEqAAUUCAgFAAgASQ4A.',['莫瑞']='莫瑞斯:BAABKgAFFH8IAAIbAAgIgBP5BQDYAQAbAAgIgBP5BQDYAQAAAA==.',['莱戈']='莱戈拉斯绿叶:BAAAKgADCgMIAwAAAA==.',['萌倒']='萌倒一片:BAAAKgAECgQIBAAAAA==.',['萝莉']='萝莉骑士:BAABKgAFFH8MAAICAAQIlB4JGQD5AAACAAQIlB4JGQD5AAAAAA==.',['萨飞']='萨飞:BAAAKgADCggICAAAAA==.',['落九']='落九天:BAACKgAFFH8oAAQHAAYIDxXaEQDyAAAHAAUIwBbaEQDyAAAbAAQIrhHHHwCmAAAhAAEISg5SEABQAAAqAAQKfzoAAwcACAjpH9cYAEYCAAcACAjpH9cYAEYCABsABAj5D0tFAF8AAAAA.',['落花']='落花无情:BAABKgAFFH8MAAMOAAYIKwt8CABUAQAOAAYIKwt8CABUAQAdAAIIugGyJQBKAAAAAA==.',['蒙牛']='蒙牛丹:BAAAKgAFFAIIAgAAAA==.',['蓝色']='蓝色悠闲:BAAAKgAECgQIBQAAAA==.',['蔑视']='蔑视星辰:BAAAKgAECgMIAwAAAA==.',['蕾妮']='蕾妮斯梅:BAABKgAFFH8GAAIOAAYIrx1QBQDAAQAOAAYIrx1QBQDAAQAAAA==.',['蕾娜']='蕾娜菈丶:BAAAKgAFFAEIAQAAAA==.',['薄暮']='薄暮回风:BAAAKgAECgMIAQAAAA==.',['薰馥']='薰馥可乐:BAABKgAFFH8GAAIDAAYIWRieDwBrAQADAAYIWRieDwBrAQAAAA==.',['蘑菇']='蘑菇爆:BAACKgAFFH8xAAIYAAgImiEOBgDvAQAYAAgImiEOBgDvAQAqAAQKfyYAAhgACAi7IrkNAIoCABgACAi7IrkNAIoCAAAA.',['虎跑']='虎跑梦泉:BAAAKgAECgIIAgAAAA==.',['虚空']='虚空布丁:BAAAKgAECgIIAgAAAA==.',['蛇喰']='蛇喰梦子:BAAAKgAECgYIEAAAAA==.',['蛋黄']='蛋黄咸肉粽:BAAAKgAECgYICQAAAA==.蛋黄鲜肉粽:BAABKgAECn8UAAITAAgItxg5DgARAgATAAgItxg5DgARAgAAAA==.',['血焱']='血焱菱:BAAAKgAECgYICQABKgAECgcIBwAkAAAAAA==.',['衣衣']='衣衣:BAAAKgAFFAQIBAAAAA==.',['西湖']='西湖里游泳:BAAAKgAECgEIAQAAAA==.',['西葫']='西葫芦真好吃:BAAAKgAFFAQIBAAAAA==.',['西门']='西门德:BAAAKgAFFAQIBAAAAA==.',['见悉']='见悉牡师:BAABKgAECn8UAAMMAAgI5BWeHACjAQAMAAgI5BWeHACjAQAGAAYIjRMfTgDZAAAAAA==.',['谈笑']='谈笑有鸿儒:BAAAKgADCgEIAQAAAA==.',['豆干']='豆干:BAAAKgAECgIIAgAAAA==.',['贝小']='贝小七:BAAAKgAFFAIIAgAAAA==.',['贤贤']='贤贤驴:BAAAKgAFFAMIAwAAAA==.',['贱佑']='贱佑萌:BAACKgAFFH8VAAIGAAQI9wLpMgB5AAAGAAQI9wLpMgB5AAAqAAQKfyEAAgYACAgED+s8AEYBAAYACAgED+s8AEYBAAAA.',['贱宥']='贱宥萌:BAAAKgAFFAMIAwAAAA==.',['贱贱']='贱贱的蛋炒饭:BAABKgAECn8bAAMPAAgIViHoCgB+AgAPAAgIViHoCgB+AgAQAAgI1g1sZgArAQAAAA==.',['赊月']='赊月入怀:BAAAKgAECggICAAAAA==.',['超炸']='超炸的文少爷:BAABKgAFFH8FAAICAAMIkiOkKQBBAQACAAMIkiOkKQBBAQAAAA==.',['跳跳']='跳跳舞殺殺猪:BAAAKgAFFAEIAQAAAA==.',['达克']='达克妮丝丶:BAAAKgAECggICAAAAA==.',['达米']='达米亚休斯:BAAAKgADCgQIBgAAAA==.达米亚克罗:BAAAKgADCggIEAAAAA==.达米亚妮娜:BAAAKgADCggIFAAAAA==.达米亚希尔:BAAAKgADCggIEAAAAA==.达米亚欧娜:BAAAKgADCgIIAwAAAA==.',['运输']='运输队长:BAAAKgAECgQIBAAAAA==.',['进击']='进击的涛砸丶:BAAAKgAECgcIEwAAAA==.',['迷提']='迷提布莉姆:BAABKgAECn8bAAMJAAgIJRctPAB7AQAKAAcIaBPmQgB+AQAJAAYItRotPAB7AQAAAA==.',['迷雾']='迷雾夜行:BAAAKgADCggICAAAAA==.',['邝恭']='邝恭:BAAAKgAECggIDwAAAA==.',['郗爾']='郗爾佤娜斯:BAAAKgAECggICAAAAA==.',['都射']='都射给你:BAAAKgAECgQIBgAAAA==.',['酷酷']='酷酷帅丶:BAAAKgAECggICAAAAA==.',['醉竹']='醉竹:BAABKgAFFH8IAAIVAAgIiQicBwCBAQAVAAgIiQicBwCBAQAAAA==.',['鐵甲']='鐵甲萬能俠:BAAAKgADCggICAAAAA==.',['钢笔']='钢笔老旧:BAAAKgAECgYIDAAAAA==.',['铁甲']='铁甲光能侠:BAAAKgADCgIIAgABKgAFFAgICAACAEkMAA==.',['长门']='长门丶有希:BAACKgAFFH8JAAMJAAMIBCCMEQDVAAAJAAMIBCCMEQDVAAALAAEIwhJjRABBAAAqAAQKfykAAwkACAi3JPQLAKMCAAkACAi3JPQLAKMCAAoAAQiEEhOcADcAAAEqAAUUBAgTABAAhSAA.',['闪灵']='闪灵归来:BAABKgAECn8eAAIYAAgIgA7nTABHAQAYAAgIgA7nTABHAQAAAA==.',['闵行']='闵行孙一峰:BAAAKgAECgYIBwAAAA==.',['闻雪']='闻雪:BAAAKgAECgIIAgAAAA==.',['阿加']='阿加洛斯:BAAAKgAECgIIAgAAAA==.',['阿尓']='阿尓忒弥斯:BAAAKgADCggIDAAAAA==.',['阿布']='阿布罗狄:BAAAKgAECgIIAgAAAA==.',['阿抽']='阿抽:BAAAKgAECgYIBgAAAA==.',['阿沐']='阿沐牧:BAAAKgAECgYICwAAAA==.',['陈丶']='陈丶风暴假酒:BAACKgAFFH8yAAIcAAgICBCsAQAYAQAcAAgICBCsAQAYAQAqAAQKfywAAhwACAi3JegAAPECABwACAi3JegAAPECAAAA.陈丶风暴烈酒:BAABKgAFFH8NAAIVAAYIoAgxFAAGAQAVAAYIoAgxFAAGAQAAAA==.',['陈某']='陈某人:BAAAKgAECgUIBQAAAA==.',['陌陌']='陌陌君丶:BAAAKgAECgEIAQAAAA==.',['陨石']='陨石:BAAAKgAECgMIBAAAAA==.',['随媛']='随媛:BAAAKgAECgQIBAAAAA==.',['随行']='随行如影:BAAAKgADCggICAAAAA==.随行茹影:BAAAKgAECggIEwAAAA==.随行铷影:BAAAKgAECgQIBAAAAA==.',['随风']='随风潜入夜:BAABKgAFFH8HAAIIAAUIkhE5EQA9AQAIAAUIkhE5EQA9AQAAAA==.',['雍正']='雍正大帝:BAAAKgAFFAQIBAAAAA==.',['難逃']='難逃法網:BAACKgAFFH8UAAIJAAQIrhdPEQDYAAAJAAQIrhdPEQDYAAAqAAQKfyEAAwkACAiAICYaADECAAkACAiAICYaADECAAoAAQigA+5PABoAAAAA.',['雪风']='雪风楼柳如烟:BAAAKgAECggICgAAAA==.雪风楼花魁:BAACKgAFFH8HAAMYAAIILB1UHQCoAAAYAAIILB1UHQCoAAAdAAIIag4lEwCMAAAqAAQKfykAAxgACAhTIakLAJkCABgACAhTIakLAJkCAB0ACAjBHq8YACUCAAAA.',['雪高']='雪高:BAACKgAFFH8IAAIfAAYIRRjAAwBUAQAfAAYIRRjAAwBUAQAqAAQKfxQAAh8ACAiaG14IAOsBAB8ACAiaG14IAOsBAAAA.',['雲柚']='雲柚雪:BAAAKgAECggIDQAAAA==.',['青蘋']='青蘋之末:BAAAKgAFFAIIAgABKgAFFAgICAAaAPUYAA==.',['青衣']='青衣灬羽毛:BAABKgAFFH8PAAMSAAYImCIOAgCfAQASAAYImCIOAgCfAQAXAAMIbBJhHAClAAABKgAFFAgIDgACACocAA==.',['領主']='領主王大錘:BAAAKgAECgQIBAAAAA==.',['風夏']='風夏:BAAAKgAFFAgIAQAAAA==.',['风来']='风来吴山:BAABKgAECn8dAAIKAAgItRpmKAAGAgAKAAgItRpmKAAGAgAAAA==.',['风泪']='风泪的小奇奇:BAABKgAFFH8IAAMFAAYIawvfDwAkAQAFAAYIawvfDwAkAQAMAAIIdgLaIQBVAAAAAA==.',['风逝']='风逝:BAABKgAFFH8GAAIQAAYIiQbqFQD/AAAQAAYIiQbqFQD/AAAAAA==.',['飛蘭']='飛蘭:BAAAKgAECgQIBAAAAA==.',['飞翼']='飞翼灵:BAAAKgAECgYIBgAAAA==.',['马中']='马中卢布:BAABKgAFFH8PAAMCAAQINCXBLAA0AQACAAQINCXBLAA0AQAgAAQIMBvkEwDaAAAAAA==.',['骁瑪']='骁瑪:BAACKgAFFH8hAAQaAAcIzRlyAgC0AQAaAAcIzRlyAgC0AQAfAAQIKg/uEACzAAAZAAMIlxamGACIAAAqAAQKfy8ABBoACAhrISIUAEwCABoACAjGHiIUAEwCABkABgjUHlciAHQBAB8AAwhxGtMuAHoAAAAA.',['骑蚂']='骑蚂蚱看日出:BAAAKgAECgQIBgAAAA==.',['鬼秋']='鬼秋:BAAAKgAECgcIDgAAAA==.',['魅影']='魅影兽灵:BAAAKgAECgcICAAAAA==.魅影巫术:BAABKgAECn8VAAIaAAcIIxOxPAB5AQAaAAcIIxOxPAB5AQAAAA==.魅影影风:BAAAKgAECgcICwAAAA==.魅影风影:BAAAKgAECgcIBwAAAA==.',['魔晨']='魔晨:BAAAKgADCgEIAQAAAA==.',['鸡屁']='鸡屁股的马仔:BAACKgAFFH8uAAINAAgIhBTfBwAaAQANAAgIhBTfBwAaAQAqAAQKfy4AAg0ACAj3I1IGAL0CAA0ACAj3I1IGAL0CAAAA.',['鸣镝']='鸣镝贰贰:BAAAKgADCgEIAQAAAA==.',['麦当']='麦当劳:BAAAKgAFFAQIBAAAAA==.',['黑乎']='黑乎乎的圣光:BAAAKgAECggICAAAAA==.',['黑旋']='黑旋风八戒:BAABKgAFFH8GAAIaAAYIexvdCQASAQAaAAYIexvdCQASAQAAAA==.',['黑神']='黑神话羊驼:BAAAKgAECgUIBQAAAA==.',['默苍']='默苍离:BAABKgAFFH8OAAMJAAQIpSP9CAAzAQAJAAQIpSP9CAAzAQALAAEIvBMyQwBFAAAAAA==.',['龍龍']='龍龍:BAAAKgAFFAgIBAAAAA==.',['龙之']='龙之小雨:BAABKgAFFH8GAAIGAAYIzBWMDQBNAQAGAAYIzBWMDQBNAQAAAA==.',['龙争']='龙争虎闘:BAAAKgAECgMIAwAAAA==.',['龙哥']='龙哥:BAAAKgAECgYIDQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end