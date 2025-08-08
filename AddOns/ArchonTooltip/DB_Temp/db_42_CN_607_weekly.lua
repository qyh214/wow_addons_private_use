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
 local lookup = {'Warrior-Arms','Shaman-Restoration','Priest-Discipline','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Druid-Balance','DeathKnight-Blood','Warlock-Destruction','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Unholy','DeathKnight-Frost','Hunter-Marksmanship','Hunter-BeastMastery','Unknown-Unknown','DemonHunter-Havoc','Paladin-Retribution','DemonHunter-Vengeance','Mage-Arcane','Druid-Restoration','Shaman-Elemental','Paladin-Holy',}; local provider = {region='CN',realm='哈兰',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ca='Candykiss:BAABKgAECn8oAAIBAAgIpR7gAwB6AgABAAgIpR7gAwB6AgAAAA==.',Ci='Cicci:BAAAKgAFFAMIAwAAAA==.',Cx='Cx:BAAAKgAFFAEIAQAAAA==.',De='Devilil:BAAAKgAECggICAAAAA==.',Fw='Fwy:BAAAKgADCgEIAQAAAA==.',Go='Goodjobs:BAABKgAFFH8ZAAICAAQIwxZRKQDRAAACAAQIwxZRKQDRAAAAAA==.',Ju='Justgame:BAABKgAFFH8IAAIDAAQIZhPGCwC1AAADAAQIZhPGCwC1AAABKgAFFAgIOAADAE8jAA==.',Ni='Nionjiujiudi:BAAAKgAECggIDwAAAA==.',Vl='Vlai:BAAAKgADCgEIAQAAAA==.',We='Weiyan:BAAAKgAFFAMIAwAAAA==.',['一曲']='一曲安神:BAAAKgAECggICwAAAA==.一曲漓殇:BAAAKgAECggICQAAAA==.',['下雪']='下雪的哈尔滨:BAAAKgAECgcIBAAAAA==.',['不信']='不信仰圣光:BAAAKgAFFAEIAQAAAA==.',['不能']='不能喝酒:BAACKgAFFH8HAAMEAAUIgQpoBQAnAQAEAAQIcwxoBQAnAQAFAAEIWwBwKwA+AAAqAAQKfy4AAwQACAiqIE8SAFECAAQACAiEIE8SAFECAAYABggGH/IQAC8BAAAA.',['世界']='世界一刘:BAABKgAECn8eAAMGAAgIVgLAHABvAAAGAAcIbALAHABvAAAFAAcIhQEufQBkAAAAAA==.',['丶冲']='丶冲锋就崴脚:BAAAKgAFFAgIBAAAAA==.',['丹之']='丹之殇:BAAAKgADCgQIBgAAAA==.',['乔巴']='乔巴:BAAAKgADCgEIAQAAAA==.',['也许']='也许是爱:BAABKgAFFH8MAAIHAAQITA5/GgDVAAAHAAQITA5/GgDVAAAAAA==.',['你还']='你还要我怎样:BAABKgAFFH8KAAIIAAYIzg7ZEAAdAQAIAAYIzg7ZEAAdAQAAAA==.',['停车']='停车枫林晚丨:BAAAKgAECgEIAQAAAA==.停车枫林晚丿:BAAAKgADCgIIAgAAAA==.',['傲世']='傲世小不点:BAAAKgAECgEIAQAAAA==.',['八宝']='八宝弓米弓:BAAAKgAECgUIBgAAAA==.',['其实']='其实丶你不乖:BAAAKgAECggICAAAAA==.其实很可爱:BAAAKgADCggICwAAAA==.',['冰疫']='冰疫刃舞:BAAAKgAECgcIBwAAAA==.',['剑三']='剑三:BAAAKgADCgUIBwAAAA==.',['十字']='十字军流浪:BAACKgAFFH8FAAIFAAIIdxgtJwCGAAAFAAIIdxgtJwCGAAAqAAQKfyAAAgUACAjqHgMUAEgCAAUACAjqHgMUAEgCAAEqAAUUAwgKAAIADSIA.',['千颂']='千颂伊:BAAAKgADCgUIBQAAAA==.',['南宫']='南宫丶冰灵:BAAAKgADCgEIAQAAAA==.南宫丶婉:BAAAKgADCgEIAQAAAA==.南宫丶影:BAAAKgADCgEIAQAAAA==.南宫丶魅影:BAAAKgADCggICAAAAA==.',['古墓']='古墓丶龙战:BAAAKgADCgEIAQAAAA==.古墓丶龙术:BAAAKgADCgEIAQAAAA==.',['听风']='听风的卡尔:BAAAKgAECgUICgAAAA==.',['吴碧']='吴碧辽:BAABKgAECn8UAAICAAgI4wZDbQDlAAACAAgI4wZDbQDlAAAAAA==.',['吸血']='吸血鬼丨小可:BAABKgAECn8VAAIJAAgIsxKSEQCMAQAJAAgIsxKSEQCMAQAAAA==.',['命硬']='命硬脾气大:BAAAKgAFFAQIAQAAAA==.',['咔咔']='咔咔起:BAABKgAFFH8JAAMKAAUIMxBgDADeAAAKAAQIfRBgDADeAAALAAEIVA/uDgBhAAAAAA==.',['哈克']='哈克克:BAABKgAECn8XAAMMAAgIHiBQNgDYAQAMAAgIkh1QNgDYAQANAAgIeh8nFgA4AQAAAA==.',['哈士']='哈士奇丶:BAAAKgAECgQIBAAAAA==.',['哈蓝']='哈蓝:BAABKgAFFH8GAAMOAAYI9BjyHAAJAQAOAAUI2BryHAAJAQAPAAEIZxEUXQA9AAAAAA==.',['嘦你']='嘦你:BAAAKgAECgYIBwAAAA==.',['四条']='四条一百:BAAAKgAECgYIBgAAAA==.',['因为']='因为有你:BAAAKgADCgEIAQABKgAFFAgIBAAQAAAAAA==.',['圣光']='圣光的庇护:BAAAKgADCggICAAAAA==.',['地狱']='地狱灬黄昏:BAAAKgADCgYIBgAAAA==.',['堕落']='堕落的椅子:BAAAKgAECgEIAQAAAA==.',['墨颜']='墨颜:BAABKgAFFH8IAAIRAAQIFhrqDwAAAQARAAQIFhrqDwAAAQAAAA==.',['多多']='多多良小伞:BAAAKgAECgYIEQAAAA==.',['大尾']='大尾巴狸狸:BAAAKgADCggICAAAAA==.',['大米']='大米弓米弓:BAABKgAECn8bAAISAAgIPSOxCAC0AgASAAgIPSOxCAC0AgAAAA==.',['大豆']='大豆包:BAAAKgAFFAQIBAAAAA==.',['娜美']='娜美:BAAAKgAECgEIAQAAAA==.',['孟秋']='孟秋之月:BAABKgAFFH8PAAITAAYIvQ67CQC3AAATAAYIvQ67CQC3AAAAAA==.',['孤灯']='孤灯长巷:BAAAKgADCggICAAAAA==.',['完美']='完美:BAAAKgADCgUIBQAAAA==.',['小南']='小南南陪你:BAAAKgADCggICAAAAA==.',['小火']='小火车呜唔污:BAABKgAECn85AAMPAAgIhh7LCgBnAgAPAAgIhh7LCgBnAgAOAAQIOxggJgDmAAAAAA==.',['小狐']='小狐狸:BAAAKgADCgMIBgAAAA==.',['小骑']='小骑:BAAAKgAECggICAAAAA==.',['巫索']='巫索普:BAAAKgAECgcIDQAAAA==.',['布鲁']='布鲁克:BAAAKgADCgEIAQAAAA==.',['幻灬']='幻灬亓:BAAAKgAECgEIAQAAAA==.',['开泰']='开泰克的贝塔:BAABKgAFFH8GAAIPAAYIMwhmGwAmAQAPAAYIMwhmGwAmAQAAAA==.',['开飞']='开飞机的舒克:BAABKgAFFH8GAAIUAAYIIxRSDQBuAQAUAAYIIxRSDQBuAQABKgAFFAgIBgAUALAdAA==.',['弹弓']='弹弓虽小:BAAAKgAECgIIAgAAAA==.',['御天']='御天荒神:BAAAKgAFFAMIAwAAAA==.',['微风']='微风与露:BAABKgAFFH8MAAISAAYIxBqeGACYAQASAAYIxBqeGACYAQABKgAFFAgIDAAMAPURAA==.',['快乐']='快乐的小兽:BAAAKgADCggICAAAAA==.',['怎么']='怎么变都有型:BAAAKgADCggICAAAAA==.',['我紧']='我紧张:BAAAKgAECgYIBgAAAA==.',['放开']='放开那只熊猫:BAAAKgAECgcIDgAAAA==.',['星天']='星天:BAAAKgADCgYIBgAAAA==.',['晌午']='晌午:BAAAKgAECgQIBAAAAA==.',['格鲁']='格鲁特:BAAAKgADCgUIBQAAAA==.',['梦魇']='梦魇缠身:BAAAKgADCgMIAwAAAA==.',['死亡']='死亡之吻:BAAAKgADCggICAAAAA==.',['死而']='死而后生:BAAAKgADCggICAAAAA==.',['氧乐']='氧乐果:BAAAKgAECgIIAgAAAA==.',['没奶']='没奶别找我:BAAAKgAECgMIAwAAAA==.',['泰兰']='泰兰徳语风:BAAAKgADCgIIAgAAAA==.',['火魂']='火魂:BAAAKgADCgEIAgAAAA==.',['灭团']='灭团奶德:BAABKgAFFH8JAAMHAAQIbh5DCwAUAQAHAAQIbh5DCwAUAQAVAAEIAAA/KQAAAAAAAA==.',['爱抱']='爱抱抱:BAAAKgADCgEIAQAAAA==.',['爱木']='爱木兮:BAAAKgADCgIIAgAAAA==.',['猎欣']='猎欣欣:BAAAKgADCgEIAQAAAA==.',['猩红']='猩红乄王冠:BAAAKgAECggICAAAAA==.',['王者']='王者的使命:BAAAKgADCgEIAQAAAA==.',['疯熊']='疯熊猫:BAACKgAFFH8UAAIFAAQIVx6OCwAHAQAFAAQIVx6OCwAHAQAqAAQKfyoAAwUACAg+ICwZACACAAUACAg+ICwZACACAAYAAQj0AQAAAAAAAAEqAAUUBwgRAAMAtxsA.',['百缘']='百缘:BAAAKgADCgEIAQAAAA==.',['盗什']='盗什么贼:BAAAKgADCgEIAgAAAA==.',['相敬']='相敬灬如宾:BAACKgAFFH8FAAIWAAIILAOvJABXAAAWAAIILAOvJABXAAAqAAQKfxwAAhYACAhVDD41AGcBABYACAhVDD41AGcBAAAA.',['矝枔']='矝枔:BAAAKgADCggICAAAAA==.',['红心']='红心盼:BAAAKgAECgcICQAAAA==.',['老斯']='老斯特:BAAAKgAECggICAAAAA==.',['肉肉']='肉肉鱼:BAAAKgADCgEIAgAAAA==.',['自然']='自然蚀刻:BAAAKgAECgcIDQAAAA==.',['芙芙']='芙芙向前冲:BAABKgAFFH8QAAMCAAQIBRQ5FADUAAACAAQIBRQ5FADUAAAWAAQIAgQSHQCRAAAAAA==.',['英仙']='英仙座:BAAAKgAECgMIAwAAAA==.',['莫小']='莫小魔:BAAAKgADCggIIAAAAA==.',['落花']='落花有意丷:BAAAKgAFFAQIBAAAAA==.',['蓝琭']='蓝琭琭:BAAAKgAECgYIBgAAAA==.',['辛灬']='辛灬巴:BAAAKgAECgEIAQAAAA==.',['达司']='达司雷玛:BAAAKgAECggICwAAAA==.',['迪斯']='迪斯路亚:BAABKgAFFH8FAAIIAAUIAwO5GADbAAAIAAUIAwO5GADbAAAAAA==.',['追光']='追光者:BAABKgAFFH8LAAMXAAQILhXgBgDiAAAXAAQILhXgBgDiAAASAAEIYwFxWQA6AAAAAA==.',['部落']='部落:BAAAKgAECgYICgAAAA==.',['金色']='金色精灵:BAAAKgAECgQIBAAAAA==.',['鑨灬']='鑨灬飝:BAAAKgADCgIIAgAAAA==.',['铁戛']='铁戛:BAABKgAFFH8QAAMVAAUIPBv/EAAXAQAVAAQIPBv/EAAXAQAHAAQI6QvvHgDBAAAAAA==.',['阿尒']='阿尒托莉雅:BAAAKgAECgQIBAAAAA==.',['雪纳']='雪纳瑞丶:BAAAKgAECgcIDAAAAA==.',['静默']='静默灬淡颜:BAABKgAFFH8VAAMKAAcIZBmPCQC8AQAKAAcIZBmPCQC8AQALAAEIGgMUCgAyAAAAAA==.静默采花:BAAAKgAECggICAAAAA==.',['风中']='风中的木鱼:BAAAKgAECgMIBAAAAA==.',['鬼歌']='鬼歌拉杰尔:BAAAKgADCggICAAAAA==.',['麻匪']='麻匪张麻子:BAAAKgAECgEIAQAAAA==.',['默默']='默默无声丶:BAACKgAFFH8GAAIHAAYIOBBBGQBPAQAHAAYIOBBBGQBPAQAqAAQKfxcAAgcACAidEOccAGkBAAcACAidEOccAGkBAAAA.',['龙小']='龙小满:BAAAKgAECggICwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end