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
 local lookup = {'Mage-Arcane','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Druid-Balance','Druid-Guardian','Unknown-Unknown','Warrior-Fury','Warrior-Arms','DeathKnight-Unholy','DeathKnight-Blood','Warlock-Demonology','Shaman-Restoration','DemonHunter-Vengeance','Warlock-Destruction','Rogue-Assassination','Shaman-Enhancement','Mage-Fire','Warlock-Affliction','Priest-Holy','Priest-Discipline','Shaman-Elemental','Mage-Frost','Paladin-Protection','Priest-Shadow',}; local provider = {region='CN',realm='凤凰之神',name='CN',type='subscribers',zone=42,date='2025-08-08',data={Da='Daimage:BAEBKgAFFH8GAAIBAAYIKBn7DQCGAQbBCwAAAQAxAMILAAABAFoAwwsAAAEARwDECwAAAQA2AMULAAABAFEAxgsAAAEAHAABAAYIKBn7DQCGAQbBCwAAAQAxAMILAAABAFoAwwsAAAEARwDECwAAAQA2AMULAAABAFEAxgsAAAEAHAAAAA==.',Fa='Fattywombat:BAEBKgAFFH8HAAMCAAYIDAxHGwAUAQbBCwAAAQAYAMILAAABABQAwwsAAAEACQDECwAAAQAqAMULAAACAB8AxgsAAAEARAACAAYIcwtHGwAUAQbBCwAAAQAYAMILAAABABQAwwsAAAEACQDECwAAAQAqAMULAAABABcAxgsAAAEARAADAAEISAyRKwBQAAHFCwAAAQAfAAEqAAUUCAghAAQAdB4A.',Mu='Muyuxd:BAECKgAFFH8JAAIFAAMIPh2MIwClAAPBCwAAAwBKAMMLAAAEAEsAxAsAAAIAJQAFAAMIPh2MIwClAAPBCwAAAwBKAMMLAAAEAEsAxAsAAAIAJQAqAAQKfyMAAwUACAgbITYXAHwCAAUACAgbITYXAHwCAAYAAQiKBXY8AAwAAAEqAAUUCAgnAAUApBkA.',['一把']='一把橙斧:BAEAKgAECgEIAQABKgAECgIIAgAHAAAAAA==.',['不努']='不努力丶丶:BAEBKgAFFH8SAAMIAAUIqCVNBQBEAQXBCwAABQBjAMILAAAFAGEAwwsAAAUAYADECwAAAgBjAMgLAAABAFsACAAFCBwkTQUARAEFwQsAAAQAYwDCCwAAAQBUAMMLAAADAF0AxAsAAAIAYwDICwAAAQBbAAkAAwhHJncPABoBA8ELAAABAGMAwgsAAAQAYQDDCwAAAgBgAAAA.',['丧彪']='丧彪灬:BAEBKgAFFH8SAAMKAAYIfSF4BgA9AQbBCwAABABhAMILAAAEAGAAwwsAAAQAVwDECwAABABhAMULAAABAEIAxgsAAAEAUQAKAAYIfSF4BgA9AQbBCwAAAwBhAMILAAADAGAAwwsAAAMAVwDECwAAAwBhAMULAAABAEIAxgsAAAEAUQALAAQIghSPIAChAATBCwAAAQA2AMILAAABAEEAwwsAAAEAJQDECwAAAQARAAEqAAUUCAgTAAwAqRkA.',['丨德']='丨德艺双馨:BAEAKgAECggICAAAAA==.',['丨月']='丨月魄丨:BAEBKgAFFH8HAAINAAYIiBhrCwCRAQbBCwAAAQBUAMILAAABAFoAwwsAAAEABADECwAAAQA5AMULAAABAD8AxgsAAAIARgANAAYIiBhrCwCRAQbBCwAAAQBUAMILAAABAFoAwwsAAAEABADECwAAAQA5AMULAAABAD8AxgsAAAIARgABKgAFFAgIEwAMAKkZAA==.',['丿风']='丿风色丶幻想:BAECKgAFFH8uAAIOAAgItCEJAQBUAQjBCwAADwBjAMILAAALAGMAwwsAAAoAYwDECwAABABjAMULAAACAEUAxgsAAAIARwDHCwAAAQBYAMgLAAABAEwADgAICLQhCQEAVAEIwQsAAA8AYwDCCwAACwBjAMMLAAAKAGMAxAsAAAQAYwDFCwAAAgBFAMYLAAACAEcAxwsAAAEAWADICwAAAQBMACoABAp/HAACDgAICHQmMAIA8wIADgAICHQmMAIA8wIAAAA=.',['余小']='余小徐:BAEAKgAECgMIAwAAAA==.',['全息']='全息玫瑰裂片:BAEAKgAECgcICQAAAA==.',['凪丶']='凪丶丶:BAEAKgAFFAgIBAABKgAFFAgIEwAMAKkZAA==.',['单推']='单推甜恩静:BAEBKgAFFH8MAAMPAAYIixbhFQBUAQbBCwAAAgA/AMILAAACAEgAwwsAAAIAUwDECwAAAgBGAMULAAACABIAxgsAAAIAMgAPAAYIXhXhFQBUAQbBCwAAAgA/AMILAAACAEgAwwsAAAIAUwDECwAAAgBGAMULAAABAAMAxgsAAAIAMgAMAAEIFwezLABBAAHFCwAAAQASAAEqAAUUCAgMABAA0SAA.',['南极']='南极料理人:BAEAKgAFFAgIAgABKgAFFAgIEwAMAKkZAA==.',['古月']='古月方源丨:BAECKgAFFH8xAAIKAAgIbCTuBgAlAgjBCwAADABhAMILAAAMAGEAwwsAAAwAYgDECwAABgBjAMULAAADAF8AxgsAAAIAXwDHCwAAAQBbAMgLAAABAE0ACgAICGwk7gYAJQIIwQsAAAwAYQDCCwAADABhAMMLAAAMAGIAxAsAAAYAYwDFCwAAAwBfAMYLAAACAF8AxwsAAAEAWwDICwAAAQBNACoABAp/JAACCgAICP4kzAcA3QIACgAICP4kzAcA3QIAAAA=.',['壮熊']='壮熊请留步:BAEBKgAFFH8MAAMRAAgIQA3cBADZAQjBCwAAAgAaAMILAAACAD8AwwsAAAIAEwDECwAAAgAZAMULAAABABgAxgsAAAEACQDHCwAAAQA7AMgLAAABACIAEQAICEAN3AQA2QEIwQsAAAEAGgDCCwAAAQA/AMMLAAABABMAxAsAAAEAGQDFCwAAAQAYAMYLAAABAAkAxwsAAAEAOwDICwAAAQAiAA0ABAgpCuAXAMUABMELAAABAAoAwgsAAAEAJQDDCwAAAQAdAMQLAAABABMAASoABRQICBMADACpGQA=.',['大灰']='大灰兔吃灰狼:BAEAKgAECgIIAgAAAA==.',['就吃']='就吃麦片:BAEBKgAFFH8KAAMBAAYIiB3qDwBtAQbBCwAAAgAtAMILAAACAFwAwwsAAAIAXgDECwAAAgAlAMULAAABADcAxgsAAAEAWwABAAYI0xvqDwBtAQbBCwAAAQAXAMILAAABAFwAwwsAAAEAXgDECwAAAQAlAMULAAABADcAxgsAAAEAWwASAAQIowuiIwDIAATBCwAAAQAtAMILAAABABsAwwsAAAEAEADECwAAAQAKAAAA.',['执手']='执手阳春丶:BAECKgAFFH8TAAQMAAUIqRklCQDwAAXBCwAABgAyAMILAAAHAEsAwwsAAAMAOgDECwAAAgATAMULAAABAE4ADAAECKkZJQkA8AAEwQsAAAYAMgDCCwAABwBLAMMLAAABADoAxQsAAAEATgATAAEIsQnSJAA7AAHDCwAAAQAYAA8AAgj0CvhNADkAAsMLAAABABwAxAsAAAIAEwAqAAQKf0EABAwACAiCIeAPAAICAA8ACAi9G64ZACgCAAwABwg7IeAPAAICABMAAwibE8kvAI8AAAAA.',['拟态']='拟态软泥涡虫:BAECKgAFFH8MAAIFAAYI2iA/AQDhAQbBCwAAAgBYAMILAAACAFIAwwsAAAIAUQDECwAAAgBgAMULAAACAGIAxgsAAAIARQAFAAYI2iA/AQDhAQbBCwAAAgBYAMILAAACAFIAwwsAAAIAUQDECwAAAgBgAMULAAACAGIAxgsAAAIARQAqAAQKfxYAAgUACAjhH24bAGQCAAUACAjhH24bAGQCAAAA.',['无耻']='无耻大米:BAEBKgAFFH8JAAIPAAUIiRfqDAD5AAXBCwAAAgAYAMILAAACAEQAwwsAAAIAQgDECwAAAgAZAMYLAAABAFEADwAFCIkX6gwA+QAFwQsAAAIAGADCCwAAAgBEAMMLAAACAEIAxAsAAAIAGQDGCwAAAQBRAAEqAAUUCAgTAAwAqRkA.',['本不']='本不该:BAEBKgAFFH8GAAMRAAQIoxahBwATAQTDCwAAAQBLAMQLAAADAGIAxQsAAAEAPADGCwAAAQAmABEABAijFqEHABMBBMMLAAABAEsAxAsAAAEAYgDFCwAAAQA8AMYLAAABACYADQABCAAAkToAAAABxAsAAAIAJwABKgAFFAgIEwAMAKkZAA==.',['梦七']='梦七姨:BAEAKgAFFAQIBAABKgAFFAgIEwAMAKkZAA==.',['氵筱']='氵筱萨陛:BAEBKgAFFH8KAAINAAYIiB26BAA4AQbBCwAAAgBeAMILAAACAFcAwwsAAAIAYADECwAAAgBWAMULAAABAC0AxgsAAAEANQANAAYIiB26BAA4AQbBCwAAAgBeAMILAAACAFcAwwsAAAIAYADECwAAAgBWAMULAAABAC0AxgsAAAEANQABKgAFFAgIEwAMAKkZAA==.',['没钱']='没钱买电脑:BAEAKgAECgcIBAABKgAFFAgIEwAMAKkZAA==.',['湖畔']='湖畔德:BAEAKgAFFAgIAwAAAA==.',['牛奶']='牛奶椰角:BAEAKgAECgUIBQABKgAECggIFQAUAIYjAA==.牛奶白莓:BAEBKgAECn8VAAMUAAgIhiMNCwB8AgjBCwAAAwBNAMILAAADAFsAwwsAAAMAXwDECwAAAwBfAMULAAADAF0AxgsAAAQAXQDHCwAAAQBhAMgLAAABAFYAFAAICIYjDQsAfAIIwQsAAAMATQDCCwAAAwBbAMMLAAADAF8AxAsAAAMAXwDFCwAAAwBdAMYLAAADAF0AxwsAAAEAYQDICwAAAQBWABUAAQgJHhR+AFgAAcYLAAABAEwAAAA=.牛奶黄瓜:BAEAKgADCgEIAQABKgAECggIFQAUAIYjAA==.',['牢大']='牢大黑肘:BAEBKgAFFH8FAAIRAAQI1w9pDADqAATBCwAAAQBGAMILAAACACMAwwsAAAEADwDECwAAAQAZABEABAjXD2kMAOoABMELAAABAEYAwgsAAAIAIwDDCwAAAQAPAMQLAAABABkAASoABRQICBMADACpGQA=.',['狼牙']='狼牙風風拳:BAEBKgAFFH8JAAMRAAUIuh3cCAAJAQXBCwAAAgBNAMILAAACADMAwwsAAAIAXwDECwAAAgATAMgLAAABAFAAEQAFCLod3AgACQEFwQsAAAEATQDCCwAAAQAzAMMLAAABAF8AxAsAAAEAEwDICwAAAQBQAA0ABAh1EwMPAOkABMELAAABABgAwgsAAAEAUwDDCwAAAQApAMQLAAABABYAASoABRQICBMADACpGQA=.',['算命']='算命小魔仙:BAEBKgAFFH8SAAMPAAQI6h2fIQD6AATBCwAABABVAMILAAAEAE4AwwsAAAUAQQDECwAABQBRAA8ABAjqHZ8hAPoABMELAAADAFUAwgsAAAQATgDDCwAABQBBAMQLAAAEAFEADAACCHMOAS0AQQACwQsAAAEAJADECwAAAQA5AAEqAAUUCAgTAAwAqRkA.',['粥鱼']='粥鱼:BAEAKgAFFAYIBAAAAA==.',['苏芷']='苏芷馨:BAEBKgAFFH8GAAIWAAYIXhBNBwBRAQbBCwAAAQA6AMILAAABADIAwwsAAAEAHgDECwAAAQAhAMULAAABABUAxgsAAAEAMQAWAAYIXhBNBwBRAQbBCwAAAQA6AMILAAABADIAwwsAAAEAHgDECwAAAQAhAMULAAABABUAxgsAAAEAMQABKgAFFAgIEwAMAKkZAA==.',['茉莉']='茉莉与香韵:BAEAKgADCgQIBAABKgAFFAgIEAADAJkcAA==.',['菰羽']='菰羽翎风:BAECKgAFFH8RAAQSAAYI9yCuCQCeAQbBCwAABABgAMILAAAEAF4AwwsAAAQAWwDECwAAAwBcAMULAAABAEsAxgsAAAEAPwASAAYI9yCuCQCeAQbBCwAAAQBgAMILAAADAF4AwwsAAAIAWwDECwAAAgBKAMULAAABAEsAxgsAAAEAPwAXAAQIdB/iBwDuAATBCwAAAgBfAMILAAABADoAwwsAAAEAVwDECwAAAQBcAAEAAggPG/43AIIAAsELAAABADQAwwsAAAEAVgAqAAQKfxQAAxcACAiDHnYmAOYBABcABggVI3YmAOYBABIACAjNGQIyANMBAAAA.',['落丨']='落丨叶舞殇:BAEAKgAFFAQIBAABKgAFFAgIEwAMAKkZAA==.',['请我']='请我吃石头:BAEAKgAFFAgIAgABKgAFFAgIEwAMAKkZAA==.',['诸神']='诸神黄昏丶:BAEBKgAFFH8JAAMNAAYIIwuyQQCBAAbBCwAAAgAcAMILAAABABYAwwsAAAEALQDECwAAAQA8AMULAAACACUAxgsAAAIACQANAAIIIAmyQQCBAALFCwAAAQAlAMYLAAABAAkAEQAGCEkb4BsAXQAGwQsAAAIAXgDCCwAAAQBZAMMLAAABACgAxAsAAAEAQwDFCwAAAQA+AMYLAAABAD8AASoABRQICBMADACpGQA=.',['门口']='门口的老頭:BAEAKgAFFAMIAwAAAA==.',['阿布']='阿布萊修德:BAEAKgAFFAgIBAABKgAFFAgIEwAMAKkZAA==.',['陆捌']='陆捌叁叁:BAECKgAFFH8fAAIYAAYIWRfPBgD2AAbBCwAACwBNAMILAAAIAE0AwwsAAAcARgDECwAAAQAGAMULAAACACYAxgsAAAIAIwAYAAYIWRfPBgD2AAbBCwAACwBNAMILAAAIAE0AwwsAAAcARgDECwAAAQAGAMULAAACACYAxgsAAAIAIwAqAAQKfycAAhgACAhsIYMKAF4CABgACAhsIYMKAF4CAAAA.',['风纪']='风纪委落叶:BAEAKgAFFAEIAQABKgAFFAgIEwAMAKkZAA==.',['骗喝']='骗喝的小婴儿:BAECKgAFFH8jAAMDAAYIcRaxFwA8AQbBCwAACABNAMILAAALAEsAwwsAAAoAVwDECwAABAALAMULAAABAB0AyAsAAAEAEAADAAYIcRaxFwA8AQbBCwAACABNAMILAAALAEsAwwsAAAYAVwDECwAABAALAMULAAABAB0AyAsAAAEAEAACAAEIiAbFUwAyAAHDCwAABAAQACoABAp/JQADAwAICC4L/4cAIQEAAwAHCP4J/4cAIQEAAgAGCK8HHV8ApgAAASoABRQICBMADACpGQA=.',['鱼灬']='鱼灬别灬丟:BAEBKgAFFH8GAAMNAAYIjhMmMAC4AAbBCwAAAQA5AMILAAABAEQAwwsAAAEACADECwAAAQA4AMULAAABACYAxgsAAAEATAANAAQIDQ8mMAC4AATCCwAAAQBEAMMLAAABAAgAxAsAAAEAOADFCwAAAQAmABYAAgigEYIeAIUAAsELAAABACMAxgsAAAEANgABKgAFFAgIEwAMAKkZAA==.',['麦片']='麦片帝凯:BAEBKgAFFH8KAAILAAYIVRZuDQBAAQbBCwAAAgBHAMILAAACADoAwwsAAAIALADECwAAAgBTAMULAAABADgAxgsAAAEANgALAAYIVRZuDQBAAQbBCwAAAgBHAMILAAACADoAwwsAAAIALADECwAAAgBTAMULAAABADgAxgsAAAEANgABKgAFFAYICgABAIgdAA==.麦片牧:BAEBKgAFFH8GAAIZAAYIUxjhCAB6AQbBCwAAAQBKAMILAAABAEYAwwsAAAEAPQDECwAAAQBVAMULAAABACIAxgsAAAEARQAZAAYIUxjhCAB6AQbBCwAAAQBKAMILAAABAEYAwwsAAAEAPQDECwAAAQBVAMULAAABACIAxgsAAAEARQABKgAFFAYICgABAIgdAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end