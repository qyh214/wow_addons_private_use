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
 local lookup = {'Paladin-Retribution','Druid-Balance','Druid-Restoration','DemonHunter-Havoc','Hunter-Marksmanship','Hunter-BeastMastery','Paladin-Protection','Warrior-Fury','Mage-Frost','Mage-Arcane','Shaman-Restoration','Rogue-Outlaw','Rogue-Assassination','Rogue-Subtlety','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Mage-Fire','Warlock-Destruction','DeathKnight-Unholy','Mage-Ranged','Priest-Holy','Priest-Discipline','Warrior-Arms','Monk-Mistweaver','Monk-Windwalker','Warlock-Demonology','Warlock-Affliction','Druid-Guardian','DeathKnight-Blood','Warrior-Protection','Shaman-Enhancement','Priest-Shadow','Paladin-Holy','Shaman-Elemental',}; local provider = {region='CN',realm='暗影迷宫',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ap='Apfelschorle:BAAAKgAECgYICQAAAA==.',Ca='Callmemt:BAAAKgAECgQIBwAAAA==.',Cr='Crusaddao:BAAAKgADCggICAAAAA==.',Cw='Cwj:BAABKgAFFH8GAAIBAAYIQA9pKQBCAQABAAYIQA9pKQBCAQAAAA==.',Cy='Cyka:BAAAKgAFFAIIBAAAAA==.',De='Demondragon:BAABKgAFFH8IAAMCAAgIhBV5CgDsAQACAAcIPhh5CgDsAQADAAEIYACeOQAzAAAAAA==.',Dr='Druiddao:BAAAKgADCgEIAQAAAA==.',Dw='Dwarff:BAAAKgADCgEIAQAAAA==.',Fu='Fushidao:BAAAKgADCgEIAQAAAA==.',Gu='Guyzz:BAABKgAFFH8NAAIEAAcIihMKCwC4AQAEAAcIihMKCwC4AQAAAA==.',He='Hellow:BAABKgAFFH8GAAMFAAMIHQfvOACTAAAFAAMIGAfvOACTAAAGAAEI/QI7YQAzAAAAAA==.',Ho='Hollytrail:BAABKgAFFH8KAAMBAAYIVCEbAQDzAQABAAYIUSAbAQDzAQAHAAQIkRw1FADXAAABKgAFFAgIFgAIANkUAA==.',Ic='Icecrowns:BAAAKgADCggICAAAAA==.',Je='Jean:BAACKgAFFH8OAAIEAAQIWxzBDAARAQAEAAQIWxzBDAARAQAqAAQKfxYAAgQABwhLIOMnABkCAAQABwhLIOMnABkCAAAA.Jenniekim:BAAAKgAFFAEIAQAAAA==.',Ko='Konatsu:BAABKgAFFH8IAAIBAAgIhgXvEACRAQABAAgIhgXvEACRAQAAAA==.',Ku='Kungfupanda:BAAAKgAFFAYIBAAAAA==.',La='Laa:BAABKgAFFH8OAAMJAAQIkyLpCwAMAQAJAAQIzB3pCwAMAQAKAAQIixoOFQDXAAABKgAFFAcIJwABAAYhAA==.',Nk='Nkk:BAAAKgAECgUIBQAAAA==.',Os='Oshero:BAABKgAFFH8QAAILAAYIlR+UAADxAQALAAYIlR+UAADxAQAAAA==.',Qq='Qqss:BAAAKgAECgIIAgAAAA==.',Sa='Saberr:BAAAKgAECgMIBAAAAA==.Saint:BAAAKgAECgEIAQAAAA==.',Se='Seed:BAAAKgAECgYICgAAAA==.',St='Stella:BAACKgAFFH8MAAQMAAMItBWbBQC/AAAMAAMIIBGbBQC/AAANAAIISgu+FgBqAAAOAAIIUws9EQBHAAAqAAQKfzYABA0ACAiJH6AJAHYCAA0ACAiJH6AJAHYCAA4ABQjsGAAeACsBAAwABAg5FlUPABABAAAA.',Sy='Syue:BAAAKgADCgMIAwAAAA==.',Ty='Tyro:BAACKgAFFH8nAAQPAAUIGBmbAgA+AQAPAAUIGBmbAgA+AQAQAAMIXhmiDgDdAAARAAEI4h8iBABOAAAqAAQKfzoABBAACAg7IPELAHoCABAACAgVIPELAHoCAA8ACAjPEI4MAKEBABEABAixIy8FAIgBAAAA.',Vl='Vladivostok:BAAAKgAECgYIBgAAAA==.',Wa='Wanda:BAAAKgADCgMIAwAAAA==.',We='Wenda:BAAAKgAECgIIAgAAAA==.',Xg='Xg:BAAAKgAECgQIBQAAAA==.',Yu='Yueguangxiao:BAAAKgAECgYICAAAAA==.',Zh='Zhhc:BAABKgAECn8VAAQJAAgI2SIGGAD2AQAJAAYIHyMGGAD2AQAKAAYIHxa3QQA5AQASAAMIqh+7IwAUAQAAAA==.',['一刀']='一刀了:BAAAKgADCggICQAAAA==.',['一包']='一包香脆薯条:BAAAKgAECgIIAgAAAA==.',['一夢']='一夢灬絕塵:BAAAKgAECggIEgAAAA==.',['一得']='一得阁拉米:BAAAKgAECggIBQABKgAFFAYIDQATAPMZAA==.',['一时']='一时任性:BAAAKgADCggICAAAAA==.一时猎任性:BAAAKgAECgEIAQAAAA==.一时的任性:BAAAKgAECgYICgAAAA==.',['一箭']='一箭穿星:BAAAKgADCgIIAgAAAA==.',['一锤']='一锤捣似:BAAAKgAFFAMIBAAAAA==.',['不丶']='不丶二:BAAAKgADCgEIAQAAAA==.',['不会']='不会冲锋:BAAAKgAECgYIEgAAAA==.',['不想']='不想这样:BAABKgAFFH8IAAIUAAgINxAnBgAFAgAUAAgINxAnBgAFAgAAAA==.',['不看']='不看书的康纳:BAAAKgAFFAIIAwAAAA==.',['不解']='不解清风意:BAAAKgADCggICAAAAA==.',['与子']='与子:BAAAKgADCgUIBQAAAA==.',['世界']='世界尽头炎爆:BAABKgAFFH8HAAIVAAYIwBMAAAAAAAAKAAYIwBMAAAAAAAAAAA==.',['东方']='东方嗨啊嗨啊:BAAAKgAFFAEIAQAAAA==.东方嗯啊嘤噢:BAABKgAECn8pAAIIAAgIJBqkCgD+AQAIAAgIJBqkCgD+AQAAAA==.东方碎碎念念:BAAAKgAECgcIDwAAAA==.',['两个']='两个神仙:BAAAKgADCgUIBQAAAA==.',['两仪']='两仪未娜:BAAAKgAECgcIBwAAAA==.',['两杆']='两杆大烟枪:BAAAKgAECggICAAAAA==.',['两炮']='两炮泯恩仇:BAABKgAECn8VAAITAAcIGxzIHgCzAQATAAcIGxzIHgCzAQAAAA==.',['中号']='中号卷貳点零:BAABKgAFFH8GAAIUAAYIhCOjDADGAQAUAAYIhCOjDADGAQAAAA==.',['为联']='为联盟:BAAAKgADCgIIAgAAAA==.',['丿闪']='丿闪丨:BAABKgAECn8oAAILAAgIuyNPCQClAgALAAgIuyNPCQClAgAAAA==.',['乂粒']='乂粒蛋:BAAAKgAFFAIIAgAAAA==.',['乌尔']='乌尔奇奥拉:BAAAKgAECgQIBAAAAA==.',['乖乖']='乖乖咙嘀咚:BAAAKgADCggICAAAAA==.',['九盏']='九盏琉璃:BAAAKgAECgEIAQAAAA==.',['九青']='九青冠:BAAAKgADCgUIBQAAAA==.',['九黎']='九黎:BAAAKgAECgMIAwAAAA==.',['也许']='也许是离黎:BAAAKgAECgUIBQAAAA==.',['买菜']='买菜市民老王:BAAAKgAECgIIAgAAAA==.',['于人']='于人海:BAAAKgADCggICAAAAA==.',['云幕']='云幕山:BAAAKgAECggICAAAAA==.',['优秀']='优秀的娃:BAABKgAFFH8FAAIEAAQIFBRjFADvAAAEAAQIFBRjFADvAAAAAA==.',['佛主']='佛主:BAAAKgAECggICAAAAA==.',['俺直']='俺直接一牛牛:BAAAKgADCggICAAAAA==.',['僵尸']='僵尸屠夫:BAAAKgAFFAIIAgAAAA==.',['八宝']='八宝琉璃:BAAAKgAECgIIAgAAAA==.',['兽医']='兽医丶不奶人:BAABKgAFFH8IAAMWAAgINQluEwAXAQAWAAYIWQtuEwAXAQAXAAII3AMGJQCMAAAAAA==.',['冬己']='冬己:BAABKgAFFH8IAAIWAAgIZAE8DAAIAQAWAAgIZAE8DAAIAQAAAA==.',['冰糖']='冰糖球:BAABKgAFFH8JAAMJAAcIaBTHCAA2AQAKAAQIKxOmFAA/AQAJAAUI4Q7HCAA2AQAAAA==.',['刀丢']='刀丢了我找找:BAAAKgAECgYIBQAAAA==.',['刀锋']='刀锋霸主:BAAAKgADCgMIAwAAAA==.',['初代']='初代千手柱间:BAAAKgAECggICAAAAA==.',['剁椒']='剁椒鱼头:BAAAKgADCgEIAQAAAA==.',['剑气']='剑气四射:BAABKgAFFH8GAAIYAAYIZwXbDgAjAQAYAAYIZwXbDgAjAQAAAA==.',['剣丨']='剣丨聖:BAAAKgAECggICAAAAA==.',['剪下']='剪下的云呢:BAAAKgAECgUIAwAAAA==.',['加尓']='加尓鲁仕:BAAAKgADCgQIBAAAAA==.',['北野']='北野武:BAAAKgAFFAQIBAAAAA==.',['千霖']='千霖:BAAAKgAECgQICQAAAA==.',['半夜']='半夜洗屁屁:BAABKgAECn8ZAAIGAAgIUiAACQCCAgAGAAgIUiAACQCCAgAAAA==.',['卡牛']='卡牛寺:BAACKgAFFH8KAAIZAAYIgAwBEwARAQAZAAYIgAwBEwARAQAqAAQKfxgAAhkACAiFDQQwAB4BABkACAiFDQQwAB4BAAAA.',['卡鲁']='卡鲁克特:BAAAKgAECgQIBAAAAA==.',['历久']='历久成絮:BAABKgAFFH8GAAIaAAIIqwsdFwB9AAAaAAIIqwsdFwB9AAAAAA==.',['受不']='受不了受不了:BAABKgAECn8UAAIBAAgINB7EXADjAQABAAgINB7EXADjAQAAAA==.',['古德']='古德阿芙特怒:BAAAKgAECgEIAQAAAA==.',['古杖']='古杖技奇人:BAABKgAECn8bAAQbAAgINiKzEAA1AQATAAMIEyWfFwBHAQAbAAQI7yOzEAA1AQAcAAIIIRwJKgCYAAAAAA==.',['吉你']='吉你一下:BAABKgAFFH8LAAIIAAYIpgq1FgAEAQAIAAYIpgq1FgAEAQAAAA==.',['后跳']='后跳假死:BAAAKgAFFAgIBAAAAA==.',['君唇']='君唇为谁红:BAACKgAFFH8GAAISAAYIlBsHCgCYAQASAAYIlBsHCgCYAQAqAAQKfyoAAhIACAjeIAkGAJACABIACAjeIAkGAJACAAAA.',['君子']='君子言:BAABKgAECn8VAAQDAAgIaw/pOQAuAQADAAcIJRDpOQAuAQACAAQInRkzcQAIAQAdAAEI5giXNwAaAAAAAA==.',['吴亦']='吴亦几:BAAAKgADCgYICgAAAA==.',['咚此']='咚此打次:BAAAKgAECgUIBQAAAA==.',['哈基']='哈基咪:BAAAKgAECgIIAgAAAA==.',['哈尔']='哈尔滨第七帅:BAAAKgAECgQIBAAAAA==.',['哈德']='哈德曼妖怪:BAAAKgADCgYIBgAAAA==.',['唤瞳']='唤瞳:BAABKgAFFH8OAAIQAAYIOSFrCgDKAQAQAAYIOSFrCgDKAQAAAA==.',['善意']='善意的谎言:BAAAKgADCgIIAgAAAA==.',['嘟嘟']='嘟嘟奶茶:BAAAKgAECggIDwAAAA==.',['团长']='团长载嫖:BAABKgAFFH8GAAIUAAYIkxkcDgC0AQAUAAYIkxkcDgC0AQAAAA==.',['图腾']='图腾波比:BAAAKgADCgEIAQAAAA==.',['圣丶']='圣丶心:BAAAKgAECggICAAAAA==.',['圣约']='圣约翰:BAAAKgAECgUIBQAAAA==.',['在下']='在下拎壶冲:BAAAKgADCggIDwAAAA==.',['地板']='地板骑士:BAAAKgAECgUIBQAAAA==.',['埃蒙']='埃蒙:BAACKgAFFH8KAAIBAAMInRICJgDPAAABAAMInRICJgDPAAAqAAQKfyEAAwEACAjzHiA4ACACAAEACAjzHiA4ACACAAcAAQhZAhZvAAYAAAAA.',['塔露']='塔露拉:BAABKgAFFH8QAAIQAAQITR8XDwDZAAAQAAQITR8XDwDZAAAAAA==.',['增辉']='增辉谁玩啊:BAABKgAFFH8GAAIQAAYIdxv6CgC9AQAQAAYIdxv6CgC9AQAAAA==.',['夜之']='夜之魇:BAAAKgAECgUIBQAAAA==.',['夜曈']='夜曈:BAAAKgAECgIIAwAAAA==.',['大壳']='大壳大兄:BAAAKgAECgEIAQAAAA==.',['大奎']='大奎思:BAAAKgAECgYIBgAAAA==.',['大概']='大概是离黎:BAAAKgAECgIIAwAAAA==.',['大浣']='大浣熊魔法味:BAAAKgADCgYIBgAAAA==.',['大红']='大红袍:BAAAKgAECgUICAAAAA==.',['大背']='大背头:BAAAKgAECgMIAwAAAA==.',['大花']='大花生:BAABKgAFFH8GAAIHAAMICQTBFgBGAAAHAAMICQTBFgBGAAAAAA==.',['天草']='天草四郎时珍:BAABKgAECn8UAAMJAAcIERCFNAAsAQAJAAcIERCFNAAsAQAKAAMIIgjDRABEAAAAAA==.',['奇袭']='奇袭:BAAAKgAFFAgIBAAAAA==.',['奈斯']='奈斯可以了:BAAAKgADCggICAAAAA==.',['奥斯']='奥斯克路:BAAAKgAFFAgIBAAAAA==.',['奶王']='奶王之王:BAAAKgAECgQIBAAAAA==.',['妃丨']='妃丨英理:BAABKgAFFH8FAAIeAAUINwcGIQCeAAAeAAUINwcGIQCeAAABKgAFFAgIDwAUAH4XAA==.',['妮妮']='妮妮:BAAAKgADCggIDgAAAA==.',['婉婷']='婉婷:BAAAKgADCggICAAAAA==.',['孤独']='孤独的一郎:BAAAKgAECgUIBQAAAA==.孤独的蜗牛:BAAAKgAECggICAAAAA==.',['宿命']='宿命仑回:BAAAKgAFFAYIAQAAAA==.',['將丨']='將丨軍:BAABKgAFFH8IAAIIAAgI1RVVBABSAgAIAAgI1RVVBABSAgAAAA==.',['小哈']='小哈迪斯:BAAAKgAECgYICgAAAA==.',['小小']='小小沙曼:BAAAKgAECgYIBwAAAA==.',['小弥']='小弥:BAAAKgAFFAIIAgAAAA==.',['小德']='小德仑回:BAAAKgAECgYIBwAAAA==.',['小指']='小指头:BAAAKgADCggICAAAAA==.',['小撒']='小撒你来了:BAAAKgADCgcIBwAAAA==.',['小晓']='小晓小晓然:BAAAKgAECggICAAAAA==.',['小楼']='小楼灰影:BAAAKgADCgMIAwAAAA==.',['小汤']='小汤圆:BAAAKgAFFAQIAgAAAA==.',['小鬼']='小鬼当家:BAAAKgAECgQIBAAAAA==.',['尘夜']='尘夜凌风散:BAAAKgAECgUIBQAAAA==.',['尛同']='尛同学:BAAAKgADCggICAAAAA==.',['尛童']='尛童泶:BAAAKgAECgEIAQAAAA==.',['屈臣']='屈臣小德:BAAAKgAFFAgIAgAAAA==.',['山海']='山海白泽:BAABKgAFFH8GAAITAAYIAQv6DwA3AQATAAYIAQv6DwA3AQAAAA==.',['巫王']='巫王的罪歌:BAAAKgAECgQIBAAAAA==.',['希尔']='希尔瓦娜心:BAABKgAECn8eAAIGAAgIuBkqMQDlAQAGAAgIuBkqMQDlAQAAAA==.',['帕拉']='帕拉斯:BAACKgAFFH8JAAMCAAQIqBeSKQDtAAACAAQIqBeSKQDtAAADAAEISQuzOAA4AAAqAAQKfxMAAwMACAiLHL0QAEMCAAMACAiLHL0QAEMCAAIABAgEFvFzAAABAAEqAAUUCAgqAAYAIyAA.',['幸福']='幸福阿拉蕾:BAAAKgAECgMIAwAAAA==.',['幼稚']='幼稚园扛把子:BAAAKgAECgcICAAAAA==.',['强壮']='强壮的杜龙坦:BAAAKgADCggIGAAAAA==.',['强衰']='强衰:BAAAKgAECgYIBgAAAA==.',['德不']='德不劳累:BAAAKgAECgQIBAAAAA==.',['德偿']='德偿所愿:BAAAKgADCggICAAAAA==.',['德尔']='德尔海伦娜:BAAAKgAECggIEAAAAA==.',['德意']='德意妄为:BAAAKgADCggICAAAAA==.',['心跳']='心跳吗:BAAAKgAECgYIDwAAAA==.',['快使']='快使用军体拳:BAABKgAFFH8FAAMaAAIIOAViIQBeAAAaAAIIOAViIQBeAAAZAAIIvAk6MwA6AAAAAA==.',['快走']='快走:BAABKgAFFH8MAAIGAAUIyBMdGwAoAQAGAAUIyBMdGwAoAQAAAA==.',['念原']='念原额:BAABKgAECn8eAAQbAAgIuSIvIwBvAQAbAAUIuCIvIwBvAQATAAUIRyCsGwAlAQAcAAII7h1PKQCcAAAAAA==.',['性感']='性感火鸡面:BAAAKgAFFAEIAQAAAA==.',['愣头']='愣头青:BAAAKgADCggICAAAAA==.',['慢慢']='慢慢亦漫漫:BAAAKgAECggICAAAAA==.',['我不']='我不会奶啊:BAABKgAFFH8GAAILAAMI6BQgLQDCAAALAAMI6BQgLQDCAAAAAA==.我不是奶龙:BAAAKgAECgQIBAAAAA==.',['我弓']='我弓呢:BAAAKgAECgMIAwAAAA==.',['我断']='我断紫菱:BAABKgAECn8WAAIIAAgIcREPMQC/AQAIAAgIcREPMQC/AQAAAA==.',['我直']='我直接一刀:BAACKgAFFH8HAAMNAAYIpRa9CwCQAQANAAYIpRa9CwCQAQAMAAEIlhUhBgBQAAAqAAQKfxwAAwwACAiDJWsAAAkDAAwACAiDJWsAAAkDAA4ABgj3GmUYAHQBAAAA.我直接一振翅:BAAAKgAECgYIBgAAAA==.',['我真']='我真的是个奶:BAAAKgADCggICAAAAA==.',['我网']='我网真的很卡:BAAAKgAECgcIDQAAAA==.',['或许']='或许是离黎:BAAAKgADCggICAAAAA==.',['战至']='战至终章:BAABKgAECn8VAAIfAAgIaQmQKADpAAAfAAgIaQmQKADpAAAAAA==.',['打野']='打野给个蓝:BAAAKgAFFAQIBAAAAA==.',['扔飞']='扔飞盘踩奉献:BAAAKgAECgYIEAAAAA==.',['把把']='把把空车:BAABKgAECn8VAAIUAAgIYyOcIQA5AgAUAAgIYyOcIQA5AgAAAA==.',['抓紧']='抓紧速度灭:BAAAKgADCggICAAAAA==.',['抠脚']='抠脚大汗:BAABKgAFFH8FAAIJAAMIawkCHACiAAAJAAMIawkCHACiAAAAAA==.',['抽空']='抽空打点输出:BAAAKgAECggIDAAAAA==.',['拂晓']='拂晓晨曦:BAAAKgAECggICAAAAA==.',['拧头']='拧头骑:BAAAKgAECgcIBwAAAA==.',['整个']='整个奶妈:BAAAKgADCgQIBAAAAA==.',['方人']='方人:BAAAKgAECgUIBQAAAA==.',['方片']='方片三:BAAAKgAECgYIBgAAAA==.',['旋转']='旋转的战吊:BAAAKgAECggICAAAAA==.',['无敌']='无敌大可爱:BAAAKgADCgMIAwAAAA==.无敌大牛奶:BAAAKgAECggIDAAAAA==.',['旺旺']='旺旺掀被:BAAAKgAECgcICwAAAA==.',['晨訫']='晨訫:BAAAKgAFFAEIAQAAAA==.',['普罗']='普罗德莫尔:BAAAKgAECgEIAQAAAA==.',['暗黑']='暗黑团子:BAAAKgAECgYIBgAAAA==.',['月亮']='月亮上放风筝:BAAAKgAECgYICwAAAA==.',['月光']='月光女妖:BAAAKgAECgQIAgAAAA==.月光小战:BAAAKgAECgQIBAAAAA==.月光小旗:BAAAKgAECgYICwAAAA==.月光小火:BAAAKgAECgIIAgAAAA==.月光小牧:BAAAKgAECgYIDgAAAA==.',['有本']='有本事刀我:BAAAKgAECgUICQAAAA==.',['木木']='木木不木:BAAAKgAECggICAAAAA==.',['术小']='术小光:BAAAKgAECgMIAwAAAA==.',['术灬']='术灬释:BAAAKgAECgEIAQAAAA==.',['朱虾']='朱虾仁:BAAAKgAECgEIAQAAAA==.',['机车']='机车裤头:BAABKgAFFH8IAAIBAAgIngdrDwCqAQABAAgIngdrDwCqAQAAAA==.',['来只']='来只爆炸小鸡:BAAAKgADCgMIAwAAAA==.',['来鸭']='来鸭:BAAAKgADCgMIAwAAAA==.',['杭州']='杭州湾宋仲基:BAAAKgAFFAQIBAAAAA==.',['析木']='析木:BAAAKgADCggICwAAAA==.',['某神']='某神秘迪凯:BAABKgAFFH8FAAIUAAUIEBOxHgApAQAUAAUIEBOxHgApAQAAAA==.',['柚子']='柚子与柠檬:BAAAKgADCggICAAAAA==.柚子与樱桃:BAAAKgAECggIDQAAAA==.柚子与甜瓜:BAAAKgAFFAIIAgAAAA==.',['柠檬']='柠檬味嘎嘣脆:BAAAKgAFFAQIBAAAAA==.',['柳媚']='柳媚:BAABKgAFFH8IAAMDAAgIeQyfAgBqAQADAAQIvQ6fAgBqAQACAAQIXgdcSQCMAAAAAA==.',['梁保']='梁保海:BAAAKgADCgIIAgAAAA==.',['梨涡']='梨涡浅笑:BAABKgAECn8nAAIGAAgIsCG2DgCuAgAGAAgIsCG2DgCuAgAAAA==.',['椒丘']='椒丘:BAAAKgAFFAQIBAAAAA==.',['楚丶']='楚丶枫:BAAAKgAECgQIBAAAAA==.',['槲叶']='槲叶:BAAAKgAECgQIBAAAAA==.',['欢乐']='欢乐阿拉蕾:BAAAKgAECgUIBQAAAA==.',['欢喜']='欢喜阿拉蕾:BAAAKgADCgIIAgAAAA==.',['欧皇']='欧皇贰号:BAAAKgAFFAMIAwAAAA==.',['武僧']='武僧之王:BAAAKgAECgYIBgAAAA==.',['歪比']='歪比巴卜:BAABKgAFFH8IAAIEAAQIzg+3FwDkAAAEAAQIzg+3FwDkAAAAAA==.',['死亡']='死亡大牛角:BAAAKgAECgYICgAAAA==.',['毒奶']='毒奶骑士:BAAAKgADCgQIBAAAAA==.',['水成']='水成文:BAAAKgADCgMIAwAAAA==.',['江南']='江南大学:BAAAKgAECgEIAQAAAA==.',['沦陷']='沦陷:BAABKgAECn8WAAIEAAgICSBeGABzAgAEAAgICSBeGABzAgAAAA==.',['河南']='河南人要自信:BAAAKgAECgcIBwAAAA==.河南彭于晏:BAAAKgAECgIIAgAAAA==.',['泯灭']='泯灭良知:BAAAKgADCggIDQAAAA==.',['泽岚']='泽岚:BAAAKgAFFAQIBAABKgAFFAgIFgAIANkUAA==.',['津津']='津津殄殄:BAAAKgADCggICAAAAA==.',['派大']='派大兴:BAABKgAFFH8IAAIBAAMIgwZxMwCVAAABAAMIgwZxMwCVAAAAAA==.派大新:BAAAKgAECgUIBQAAAA==.派大行:BAABKgAECn8WAAMWAAcI0wwmSwDlAAAWAAcIagsmSwDlAAAXAAQIgAxKawCDAAAAAA==.',['淑娟']='淑娟:BAAAKgAFFAEIAQAAAA==.',['满地']='满地插棍:BAAAKgAFFAEIAQAAAA==.',['漫长']='漫长季节:BAAAKgAECgYIBwAAAA==.',['火球']='火球火球:BAAAKgADCgYIBgAAAA==.',['火盆']='火盆烧烤:BAAAKgAFFAQIBAAAAA==.',['火鸡']='火鸡味锅芭丶:BAACKgAFFH8JAAIBAAMIzRqdOwD/AAABAAMIzRqdOwD/AAAqAAQKfxsAAgEACAg2Ix06AEACAAEACAg2Ix06AEACAAAA.',['灵魂']='灵魂之引:BAAAKgADCgQIBAAAAA==.',['炁体']='炁体丨源流:BAABKgAECn8aAAMZAAgIIhvwGgCxAQAZAAgIIhvwGgCxAQAaAAIIugxXYwB0AAAAAA==.',['炽蓝']='炽蓝仙野的殇:BAAAKgADCgEIAQAAAA==.',['烤馕']='烤馕仙人:BAAAKgAFFAgIBAAAAA==.',['煎饼']='煎饼年糕片:BAAAKgADCgYIBgAAAA==.',['燎窕']='燎窕:BAAAKgAECgQIBAAAAA==.',['爱夏']='爱夏:BAAAKgAFFAIIAgAAAA==.',['牛娃']='牛娃子:BAAAKgAFFAEIAQAAAA==.',['牛春']='牛春兰:BAAAKgAECgcICgAAAA==.',['狂暴']='狂暴野牛:BAAAKgAECggIDAAAAA==.',['狡猾']='狡猾的杰瑞:BAAAKgADCgcIBwAAAA==.狡猾的牛:BAACKgAFFH8IAAIfAAMInww5CQCTAAAfAAMInww5CQCTAAAqAAQKfxcAAh8ACAhBFDYXAFsBAB8ACAhBFDYXAFsBAAAA.狡猾的狗子:BAAAKgAECgQIBAAAAA==.',['独孤']='独孤小猎:BAAAKgAECgYIBgAAAA==.',['独灬']='独灬半吨:BAABKgAECn8/AAITAAgI9QmFQgABAQATAAgI9QmFQgABAQAAAA==.',['狼族']='狼族光中光:BAAAKgAECgIIAgAAAA==.狼族变中变:BAABKgAFFH8MAAMDAAYIMBhsCQBxAQADAAYIMBhsCQBxAQACAAYIWgyPHQAwAQAAAA==.狼族恶中恶:BAABKgAFFH8GAAITAAYImB/fDwCSAQATAAYImB/fDwCSAQAAAA==.狼族流瘦:BAAAKgAFFAEIAQAAAA==.狼族狂中狂:BAAAKgAECggICwAAAA==.狼族猛中猛:BAABKgAFFH8HAAMgAAYIMAX9CgAeAQAgAAYIMAX9CgAeAQALAAEIOQRIUABAAAAAAA==.狼族花和尚:BAAAKgAECgYIBgAAAA==.狼族虎中虎:BAABKgAFFH8FAAIIAAUIjwhhBgA1AQAIAAUIjwhhBgA1AQAAAA==.狼族虎忠虎:BAABKgAFFH8GAAIeAAYIUAnLFwDiAAAeAAYIUAnLFwDiAAAAAA==.狼族贼中贼:BAAAKgAECgUIBQAAAA==.',['玉指']='玉指擒龙:BAAAKgAECgYIDAAAAA==.',['王一']='王一博:BAAAKgAFFAUIBAAAAA==.',['瓜瓜']='瓜瓜子:BAAAKgAFFAIIAgAAAA==.',['白刀']='白刀进红刀出:BAABKgAECn8mAAINAAgIFxltDwAQAgANAAgIFxltDwAQAgAAAA==.',['白日']='白日梦夜里吊:BAAAKgAECggIDwAAAA==.白日梦夜里疯:BAAAKgAECggICAAAAA==.',['白瑜']='白瑜哈梗:BAAAKgADCgMIAwAAAA==.',['白衣']='白衣天使:BAABKgAFFH8OAAQWAAYI0hyYAQBRAQAWAAUIWBiYAQBRAQAhAAIIqQomGQCaAAAXAAMIsRikGQCWAAABKgAFFAgICAALAO0XAA==.',['百年']='百年好合:BAAAKgAECgIIAgAAAA==.',['皮老']='皮老木反:BAACKgAFFH8GAAILAAMIUwuzOACfAAALAAMIUwuzOACfAAAqAAQKfxYAAgsACAg3EYBCAGwBAAsACAg3EYBCAGwBAAAA.皮老版:BAABKgAFFH8LAAIDAAMIiRYADQC9AAADAAMIiRYADQC9AAAAAA==.',['盯洱']='盯洱咚咚:BAAAKgAECgUIBQAAAA==.',['看看']='看看侃栞栞刊:BAABKgAECn8YAAIJAAgI/CV1AwDyAgAJAAgI/CV1AwDyAgAAAA==.',['真的']='真的别搞了:BAAAKgAECgEIAQAAAA==.',['知易']='知易行:BAAAKgADCgYIBgAAAA==.',['短咦']='短咦巴兔:BAAAKgAFFAEIAgAAAA==.',['破镜']='破镜难圆:BAAAKgADCgQIBAAAAA==.',['碎镜']='碎镜难圆:BAAAKgADCggICAAAAA==.',['神圣']='神圣赞歌:BAAAKgAECgMIAwAAAA==.',['福星']='福星阿拉蕾:BAAAKgADCggIEAAAAA==.',['离黎']='离黎:BAAAKgADCgEIAQAAAA==.',['秋分']='秋分落日:BAAAKgAFFAIIAgAAAA==.',['米娜']='米娜桑:BAAAKgAECgEIAQAAAA==.',['粉指']='粉指导:BAAAKgAECgcIBwAAAA==.',['糖龙']='糖龙龙:BAABKgAFFH8GAAIQAAYIOBnXDwBjAQAQAAYIOBnXDwBjAQAAAA==.',['索林']='索林丶橡木盾:BAAAKgAFFAEIAQAAAA==.',['红色']='红色浪漫:BAAAKgAECgIIAgAAAA==.',['纯爱']='纯爱战神丶丶:BAAAKgADCggICAAAAA==.',['细戏']='细戏:BAAAKgADCgUIBQAAAA==.',['给我']='给我圣疗:BAACKgAFFH8HAAMBAAMI2RlRXgC0AAABAAII5yJRXgC0AAAHAAEIvQdPLgAfAAAqAAQKfx8AAgEACAjdJDYbAJcCAAEACAjdJDYbAJcCAAAA.',['维拉']='维拉兹:BAAAKgAFFAMIAwAAAA==.',['网上']='网上邻居:BAAAKgAFFAIIAgAAAA==.',['肉泥']='肉泥:BAAAKgADCgYIBgAAAA==.',['肥屁']='肥屁是我:BAAAKgADCgMIAwAAAA==.',['背后']='背后大人:BAAAKgAECgMIAwAAAA==.',['脚滑']='脚滑的骑士:BAAAKgAFFAMIAwAAAA==.',['自然']='自然之糖:BAAAKgAECgUIBQAAAA==.',['臭猴']='臭猴子:BAAAKgAECgIIAgAAAA==.',['艾克']='艾克塞琳:BAABKgAFFH8KAAMBAAQI+BKHWgC8AAABAAMI+BKHWgC8AAAiAAMI6BK2FgB/AAAAAA==.',['芋圆']='芋圆:BAABKgAFFH8UAAMWAAYI6huhBwCwAQAWAAYI6huhBwCwAQAhAAQInxj7EwDdAAAAAA==.',['芝士']='芝士山山:BAAAKgAECggIEQAAAA==.',['花僧']='花僧:BAABKgAFFH8GAAIaAAYIugUTDAAbAQAaAAYIugUTDAAbAQAAAA==.',['茅茅']='茅茅虫:BAAAKgAECgIIAgAAAA==.',['茗丶']='茗丶芳:BAAAKgAECgQIBAAAAA==.',['荣昌']='荣昌迷你怪:BAAAKgADCggICAAAAA==.',['菜菜']='菜菜的骑士:BAAAKgAFFAEIAQAAAA==.',['菩提']='菩提子晒鲍鱼:BAAAKgADCgMIAwAAAA==.',['萌小']='萌小呗:BAAAKgADCgMIAwAAAA==.',['萌新']='萌新大头虎:BAAAKgAECgUIBAAAAA==.',['萧瑟']='萧瑟仙贝:BAAAKgAECgMIAwAAAA==.',['落佑']='落佑:BAAAKgAFFAMIAwAAAA==.',['葛力']='葛力姆喬:BAAAKgADCggICAAAAA==.',['薇尔']='薇尔莉特:BAABKgAFFH8GAAICAAYI4BScFgBkAQACAAYI4BScFgBkAQAAAA==.',['虚无']='虚无缥缈:BAAAKgAECggICAAAAA==.',['西城']='西城:BAABKgAFFH8FAAIFAAMIJwQrPQCDAAAFAAMIJwQrPQCDAAAAAA==.',['西布']='西布克:BAAAKgAECggIDgAAAA==.',['西行']='西行寺刹那:BAAAKgAECggICAAAAA==.',['要命']='要命小野猫:BAAAKgADCggIDAAAAA==.',['见心']='见心:BAAAKgAECggIDwAAAA==.',['贝七']='贝七:BAAAKgADCggICAAAAA==.',['贼猛']='贼猛:BAAAKgAECgIIAgAAAA==.',['赛博']='赛博企鹅:BAABKgAFFH8GAAILAAUIxB/TBQDRAQALAAUIxB/TBQDRAQAAAA==.',['起名']='起名是真费劲:BAAAKgAECgIIAgAAAA==.',['趴下']='趴下别动:BAAAKgAECgMIAwAAAA==.',['跳起']='跳起一嘴锤:BAABKgAECn8XAAIGAAgIhhOmTwDDAQAGAAgIhhOmTwDDAQAAAA==.',['踏马']='踏马德:BAACKgAFFH8NAAMCAAYIExglEgCMAQACAAYIExglEgCMAQAdAAEIrQfpEAAZAAAqAAQKfxQAAwIACAhiHcMeAFECAAIACAhiHcMeAFECAB0AAQiaGDUsAEcAAAAA.',['蹦蹦']='蹦蹦跳跳糖:BAAAKgAFFAEIAQAAAA==.',['这是']='这是一个恶人:BAAAKgAFFAEIAQAAAA==.',['这枪']='这枪热辣滚烫:BAAAKgADCggICAAAAA==.',['这瓜']='这瓜多钱一斤:BAABKgAECn8xAAIDAAgI2yRuAwDUAgADAAgI2yRuAwDUAgAAAA==.',['迪丽']='迪丽热巴的狗:BAAAKgAFFAgIBAAAAA==.',['邪火']='邪火:BAAAKgADCgYIBgAAAA==.',['邪能']='邪能了解一下:BAAAKgAECgYIBgAAAA==.',['醉拳']='醉拳甘奶迪:BAAAKgADCggICAAAAA==.',['野牛']='野牛野牛:BAAAKgADCggICAAAAA==.',['锤王']='锤王:BAAAKgAECgMIAwAAAA==.',['阵白']='阵白冶:BAAAKgAECgcIDgAAAA==.',['阿土']='阿土伯:BAAAKgADCgIIAgAAAA==.',['阿圣']='阿圣呐:BAAAKgAECgIIAgAAAA==.',['阿寳']='阿寳小將軍:BAAAKgAECggIEAAAAA==.',['阿猎']='阿猎呦:BAAAKgAECgMIAwAAAA==.',['阿莱']='阿莱丝塔烬誓:BAAAKgADCgEIAQAAAA==.阿莱莎:BAABKgAECn8YAAIFAAgINSJICQCbAgAFAAgINSJICQCbAgAAAA==.',['陈丶']='陈丶风暴劣酒:BAAAKgADCggICgAAAA==.',['随风']='随风意难平:BAAAKgADCggICAAAAA==.',['雷雨']='雷雨:BAAAKgADCgYIBgAAAA==.',['雾瞳']='雾瞳:BAAAKgAECgQIBAAAAA==.',['霹雳']='霹雳小飞侠:BAABKgAFFH8FAAIQAAMIkQdfHABpAAAQAAMIkQdfHABpAAAAAA==.',['青灯']='青灯伴佳人:BAAAKgAFFAIIAgAAAA==.',['風之']='風之蒼怒:BAAAKgADCgEIAQAAAA==.',['颰詀']='颰詀迩嘚僾:BAAAKgAECgIIAgAAAA==.',['香蕉']='香蕉个卜娜娜:BAAAKgAECgIIAgAAAA==.',['騩手']='騩手:BAAAKgADCgQIBAAAAA==.',['骑士']='骑士骑驴:BAAAKgADCgYICQAAAA==.',['骨杖']='骨杖技奇人:BAAAKgADCggIEAAAAA==.',['鬓发']='鬓发斌:BAAAKgADCgMIAwAAAA==.',['鬣丶']='鬣丶心:BAAAKgAFFAQIBAABKgAFFAgIEQAXADMcAA==.',['鬼多']='鬼多是重:BAABKgAFFH8HAAMUAAYIzA1oGgDEAAAUAAYIoQpoGgDEAAAeAAEIhSLeHgBnAAAAAA==.',['鬼灬']='鬼灬鬼:BAAAKgADCggICAAAAA==.',['魃魈']='魃魈魑魅魍魉:BAABKgAFFH8MAAITAAMIVQ6cLQC3AAATAAMIVQ6cLQC3AAAAAA==.',['魔力']='魔力海鹦:BAAAKgADCgEIAQAAAA==.',['魔幻']='魔幻阿拉蕾:BAAAKgAECggICAAAAA==.',['鱼鱼']='鱼鱼猪:BAAAKgAECggICAAAAA==.',['鲜风']='鲜风永航:BAAAKgAFFAMIAwAAAA==.',['黑指']='黑指甲油:BAAAKgADCgMIAwAAAA==.',['黑狗']='黑狗萨满:BAABKgAECn8iAAIjAAgI7SSpBgDEAgAjAAgI7SSpBgDEAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end