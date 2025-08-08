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
 local lookup = {'DeathKnight-Frost','Shaman-Restoration','Shaman-Elemental','Mage-Arcane','Mage-Fire','Paladin-Holy','Paladin-Retribution','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Unholy','Warrior-Fury','Monk-Mistweaver','DemonHunter-Havoc','Unknown-Unknown','Warlock-Demonology','Mage-Frost','Shaman-Enhancement','Evoker-Devastation',}; local provider = {region='CN',realm='嚎风峡湾',name='CN',type='weekly',zone=42,date='2025-08-08',data={As='Ashenshroud:BAAAKgAECgYIDQAAAA==.',Cr='Crazyz:BAACKgAFFH8PAAIBAAMImwzjCgC+AAABAAMImwzjCgC+AAAqAAQKfxsAAgEABwgiF/MQAJgBAAEABwgiF/MQAJgBAAAA.',Cs='Csaehj:BAAAKgAECgIIAgAAAA==.',Ct='Ctmafk:BAACKgAFFH8nAAMCAAcIrRMxDQB6AQACAAcIrRMxDQB6AQADAAEIaADlKwAgAAAqAAQKfzEAAwIACAh4IBoUAFwCAAIACAh4IBoUAFwCAAMAAwh4BV5lAGgAAAAA.',Ji='Jianghe:BAABKgAFFH8FAAMEAAUI1wu/NwCDAAAFAAIIIwRjJgCIAAAEAAMIixO/NwCDAAAAAA==.',Ko='Korfax:BAABKgAFFH8GAAIGAAYI4AQlCQAXAQAGAAYI4AQlCQAXAQAAAA==.',Me='Meeng:BAAAKgADCgUIBQAAAA==.',Sc='Schittering:BAAAKgAECggICAAAAA==.',So='Solong:BAAAKgADCgIIAgAAAA==.',['丶预']='丶预谋丶:BAAAKgAECgEIAQAAAA==.',['主宰']='主宰之剑:BAABKgAFFH8IAAIHAAQIkR2yGwDzAAAHAAQIkR2yGwDzAAAAAA==.',['代理']='代理人:BAAAKgADCggIDQAAAA==.代理骑士:BAAAKgAECgIIAgAAAA==.',['伴伴']='伴伴巧:BAABKgAFFH8GAAIIAAYIsxiEDQCCAQAIAAYIsxiEDQCCAQAAAA==.',['你快']='你快乐就好:BAAAKgAECgYIEQAAAA==.',['使徒']='使徒行者:BAABKgAFFH8WAAIHAAMI1xQSSQDcAAAHAAMI1xQSSQDcAAAAAA==.',['依蕊']='依蕊儿:BAAAKgAECgUIBQAAAA==.',['俺不']='俺不会治疗:BAAAKgAECgYIDwAAAA==.',['傻傻']='傻傻滴小兽兽:BAABKgAFFH8IAAIJAAgIUAgkCgC1AQAJAAgIUAgkCgC1AQAAAA==.',['冰霜']='冰霜风暴:BAABKgAFFH8IAAIKAAgIJBE1CAALAgAKAAgIJBE1CAALAgAAAA==.',['吞吞']='吞吞:BAAAKgAECgEIAQAAAA==.',['土灵']='土灵咆哮叕:BAAAKgADCggICAAAAA==.',['土豆']='土豆呵呵:BAAAKgADCgIIAgAAAA==.土豆嘿嘿:BAAAKgAECgcIEAAAAA==.',['坠星']='坠星者薇娅:BAAAKgAECggICAAAAA==.',['天神']='天神:BAABKgAFFH8PAAILAAMIgg7MIADQAAALAAMIgg7MIADQAAAAAA==.',['安宝']='安宝宝:BAAAKgADCgEIAQAAAA==.',['客官']='客官丶伍:BAAAKgADCgMIAwAAAA==.',['尼斯']='尼斯那沙比:BAAAKgAECgEIAQAAAA==.',['帅帅']='帅帅小黑角:BAAAKgADCgMIAwAAAA==.',['张伟']='张伟事务所:BAABKgAFFH8KAAIMAAYINQrdEgASAQAMAAYINQrdEgASAQAAAA==.张伟律师所:BAABKgAECn8gAAMJAAgIAR91OQAQAgAJAAgIqx51OQAQAgAIAAYIsg7+SAD5AAAAAA==.',['总是']='总是迷璐:BAAAKgAECgcIBwAAAA==.',['惡魔']='惡魔獵手:BAABKgAFFH8GAAINAAMI2Q53GQDDAAANAAMI2Q53GQDDAAAAAA==.',['我头']='我头发是真发:BAAAKgAECgMIAwAAAA==.',['抠你']='抠你屁屁:BAAAKgAECggICAAAAA==.',['易燃']='易燃易爆炸:BAAAKgADCgEIAQAAAA==.',['星野']='星野:BAAAKgAFFAIIAwAAAA==.',['暗月']='暗月斩:BAAAKgAECgcIBwAAAA==.',['暴力']='暴力坦克:BAAAKgADCgIIAgAAAA==.',['曹老']='曹老师的粉笔:BAABKgAFFH8HAAIBAAQIOiM9BQAqAQABAAQIOiM9BQAqAQABKgAFFAgIAwAOAAAAAA==.',['村姑']='村姑妹:BAABKgAFFH8JAAMJAAMIgAgcQQCbAAAJAAMIBwccQQCbAAAIAAIIIAaoSABdAAAAAA==.',['死神']='死神的梦魇:BAACKgAFFH8RAAIPAAMIMBLTDADPAAAPAAMIMBLTDADPAAAqAAQKfxkAAg8ACAhzF0ARAP8BAA8ACAhzF0ARAP8BAAAA.',['泡泡']='泡泡糖:BAAAKgADCggICAAAAA==.',['淡淡']='淡淡:BAAAKgAECgYIBgAAAA==.',['混枪']='混枪水:BAAAKgADCgIIAgAAAA==.',['烟雨']='烟雨霓裳:BAACKgAFFH8RAAIJAAMIyxC3MwDCAAAJAAMIyxC3MwDCAAAqAAQKfxkAAgkACAjCF69GAOEBAAkACAjCF69GAOEBAAAA.',['盲人']='盲人按摩丶:BAAAKgAECggICAAAAA==.',['瞄准']='瞄准的咕咕:BAABKgAFFH8NAAMJAAYIsBVaFQBLAQAJAAYIsBVaFQBLAQAIAAQIjwyEMwCjAAAAAA==.',['积积']='积积阳阳德:BAAAKgAECgQIBAAAAA==.',['精灵']='精灵魅魔:BAAAKgADCggICAAAAA==.',['罗斯']='罗斯上校:BAAAKgADCggIEAAAAA==.',['老牛']='老牛牟牟:BAAAKgADCgYIBgAAAA==.',['肆叁']='肆叁贰壹:BAAAKgADCgEIAQAAAA==.',['脆皮']='脆皮法式筒:BAACKgAFFH8RAAQQAAMIfA6XEwCRAAAEAAMIWgkJMACjAAAQAAMILA2XEwCRAAAFAAEINgByQwAOAAAqAAQKf0AABBAACAjGG8weABMCABAACAhzGsweABMCAAQABghLG9cUAJQBAAUABgitDy5UACgBAAAA.',['荆红']='荆红雪:BAABKgAFFH8MAAIJAAQIjB3yEQAFAQAJAAQIjB3yEQAFAQAAAA==.',['萝莉']='萝莉正义:BAAAKgAECgYIBgAAAA==.',['血腥']='血腥上帝:BAAAKgAECgQIAQAAAA==.',['血莫']='血莫有兮:BAAAKgAECgEIAQAAAA==.',['要走']='要走不必再说:BAAAKgAECgQIBQAAAA==.',['贫僧']='贫僧不奶:BAAAKgADCggICAAAAA==.',['赛文']='赛文:BAAAKgADCgEIAQAAAA==.',['酒馆']='酒馆小哥到:BAAAKgAECggICAAAAA==.',['钢板']='钢板最给力:BAAAKgADCggIDgAAAA==.',['铳梦']='铳梦:BAAAKgAECgQIBAAAAA==.',['闪电']='闪电与烈焰:BAAAKgAECgIIAgAAAA==.',['阿亚']='阿亚达:BAAAKgAECgIIAgAAAA==.',['阿彻']='阿彻里斯:BAAAKgADCgEIAQAAAA==.',['陆烟']='陆烟儿:BAAAKgAECgEIAQAAAA==.',['风暴']='风暴打鸡:BAABKgAECn8dAAIRAAgILBnZDgAFAgARAAgILBnZDgAFAgAAAA==.',['飘丶']='飘丶:BAAAKgAECgMIAwAAAA==.',['髪詩']='髪詩:BAAAKgAECgUIBQAAAA==.',['魔兽']='魔兽胖叔:BAAAKgADCggICAAAAA==.',['鸽鸽']='鸽鸽叫咕咕:BAAAKgAFFAgIBAAAAA==.',['龙曦']='龙曦:BAABKgAFFH8IAAISAAgI5xWVEgA/AQASAAgI5xWVEgA/AQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end