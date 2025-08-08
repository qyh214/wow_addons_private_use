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
 local lookup = {'Paladin-Retribution','Priest-Holy','Priest-Discipline','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Protection','Warrior-Fury','Warrior-Protection','Rogue-Assassination','Mage-Frost','Mage-Fire','Priest-Shadow','DemonHunter-Havoc','Druid-Balance','Druid-Restoration','DemonHunter-Vengeance','Druid-Guardian','Druid-Feral','Shaman-Restoration','Evoker-Devastation','Monk-Mistweaver','Evoker-Preservation','Hunter-BeastMastery','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Hunter-Marksmanship','Monk-Brewmaster','Hunter-Survival','Monk-Windwalker','Mage-Arcane','Unknown-Unknown','Warrior-Arms','DeathKnight-Frost',}; local provider = {region='CN',realm='莱索恩',name='CN',type='weekly',zone=42,date='2025-08-08',data={Af='Affleck:BAAAKgAECggICAAAAA==.',Ar='Artemis:BAAAKgAECggICAAAAA==.',Co='Cortez:BAABKgAFFH8IAAIBAAgI0wnwJgBNAQABAAgI0wnwJgBNAQAAAA==.Cortezfly:BAABKgAFFH8KAAMCAAgIVhbkBQCyAQACAAYIbR7kBQCyAQADAAQI+AJ5EgAHAQAAAA==.',Cr='Crisytin:BAAAKgADCggICAAAAA==.',De='Deathrageous:BAABKgAFFH8GAAIEAAMIcgxmNgDAAAAEAAMIcgxmNgDAAAAAAA==.',Di='Diemark:BAAAKgADCgEIAgAAAA==.',Dk='Dkii:BAAAKgAECgMIAwAAAA==.',Ec='Ecarlos:BAAAKgADCggICAAAAA==.',Eo='Eotrisingsun:BAABKgAFFH8GAAIFAAYIuQFsDgCSAAAFAAYIuQFsDgCSAAAAAA==.',Fe='Fenton:BAAAKgAFFAIIAgAAAA==.',Fo='Forgétsong:BAABKgAFFH8GAAIGAAYIsQaiFQDLAAAGAAYIsQaiFQDLAAAAAA==.',Fr='Fragrant:BAAAKgAECgQIBgAAAA==.Free:BAAAKgAECggICAAAAA==.',Gr='Groms:BAACKgAFFH8JAAIHAAQIXxhXGQDyAAAHAAQIXxhXGQDyAAAqAAQKfxcAAgcACAj/Ge0gAMsBAAcACAj/Ge0gAMsBAAAA.',Ji='Jijimaoa:BAAAKgAECgMIAwAAAA==.',Ki='Kin:BAAAKgADCgEIAQAAAA==.',Lz='Lzo:BAAAKgAECggIEAAAAA==.',Ma='Marklh:BAAAKgAECggICAAAAA==.Masaharu:BAABKgAFFH8QAAIIAAgIGBE9AwCCAQAIAAgIGBE9AwCCAQAAAA==.',Mo='Molly:BAAAKgADCgEIAQAAAA==.Monfrereål:BAAAKgAFFAQIBAAAAA==.Moonoul:BAAAKgAECgIIAgAAAA==.',Or='Orianshow:BAAAKgAECgMIAwAAAA==.',Ov='Overmyheart:BAAAKgADCggICAAAAA==.',Re='Redio:BAAAKgADCgIIAgAAAA==.Reize:BAAAKgAFFAgIBAAAAA==.',Si='Silent:BAAAKgADCgUIBQAAAA==.',So='Sora:BAAAKgAECgcICQAAAA==.',Te='Teadance:BAAAKgAECggICAAAAA==.',Tl='Tlee:BAAAKgAECggIEQAAAA==.',['Ví']='Ví:BAABKgAFFH8GAAIJAAQIBx6EBgAWAQAJAAQIBx6EBgAWAQAAAA==.',['一个']='一个人得历史:BAAAKgADCggICAAAAA==.',['一冰']='一冰棍儿一:BAAAKgADCgYIDAAAAA==.',['一夜']='一夜白:BAAAKgAECgEIAQAAAA==.',['一恶']='一恶棍一:BAAAKgADCgQIBAAAAA==.',['一曲']='一曲震魂:BAABKgAFFH8OAAMKAAYIQRgPAwAkAQAKAAQI4yEPAwAkAQALAAIIzQkAAAAAAAABKgAFFAgIBQALAA8MAA==.',['一直']='一直很忧郁:BAAAKgAECgEIAQAAAA==.',['一神']='一神牧一:BAACKgAFFH8tAAQCAAgIxiIkBQDpAQADAAUIfCKjBAD+AQACAAcI1CIkBQDpAQAMAAEI3BPhKwBEAAAqAAQKfzwABAIACAiCJrgAAAgDAAIACAiCJrgAAAgDAAwABggQF7IuAGYBAAMAAQgnHz17AF4AAAAA.',['三月']='三月雨如烟:BAAAKgAFFAgIBAAAAA==.',['丨伊']='丨伊凰丨:BAAAKgAECgIIAgAAAA==.',['丨冬']='丨冬天丨:BAAAKgAFFAEIAQAAAA==.',['丨守']='丨守护的豆丨:BAABKgAECn8YAAIBAAcIdRxQZADSAQABAAcIdRxQZADSAQAAAA==.',['丨德']='丨德丨:BAAAKgAECgMIAQAAAA==.',['丶丨']='丶丨尐枫灬:BAAAKgAECgQIBAAAAA==.',['丶肉']='丶肉宝宝:BAAAKgAECggIDAAAAA==.',['丶長']='丶長生:BAAAKgAECgYIDAAAAA==.',['乄堕']='乄堕落魂舞:BAAAKgADCggICAAAAA==.',['义父']='义父:BAAAKgADCgEIAQAAAA==.',['九五']='九五罒二七:BAACKgAFFH8HAAIIAAMIkgpPDwCEAAAIAAMIkgpPDwCEAAAqAAQKfyIAAwgACAjGGE4RAM4BAAgACAjGGE4RAM4BAAcABAixD2MiANYAAAAA.',['云点']='云点灯:BAAAKgADCgMIAwAAAA==.',['人生']='人生没有再见:BAAAKgADCgIIAgAAAA==.',['代表']='代表圣光:BAAAKgAECgEIAgAAAA==.',['伊利']='伊利达雷之怒:BAABKgAFFH8KAAINAAYINRsoEwBhAQANAAYINRsoEwBhAQAAAA==.',['伊登']='伊登的苹果:BAAAKgAECgUICgAAAA==.',['会夢']='会夢之圈:BAACKgAFFH8UAAIOAAQI2hJgIAC4AAAOAAQI2hJgIAC4AAAqAAQKfxgAAw4ACAijFPE/ALYBAA4ACAijFPE/ALYBAA8ABwiqBRBXALIAAAAA.',['会梦']='会梦之卷:BAAAKgAECgEIAQAAAA==.会梦之圈:BAABKgAFFH8MAAICAAUIDhtdCgArAQACAAUIDhtdCgArAQAAAA==.会梦之巻:BAAAKgAECggICAAAAA==.',['你们']='你们的姥姥:BAAAKgADCggICQAAAA==.',['促醉']='促醉:BAABKgAFFH8IAAIHAAgI4wTACAC+AQAHAAgI4wTACAC+AQAAAA==.',['俢囉']='俢囉戰將:BAACKgAFFH8JAAIGAAMI/QYbEAB/AAAGAAMI/QYbEAB/AAAqAAQKfxYAAgYABwhmCAc9AJoAAAYABwhmCAc9AJoAAAAA.俢囉戰鉮:BAABKgAFFH8SAAIQAAQILg73CgCgAAAQAAQILg73CgCgAAAAAA==.俢囉戰魂:BAACKgAFFH8PAAQPAAMIiAxMEACVAAAPAAMIiAxMEACVAAARAAMI2w4cBQCJAAASAAII5AO4CwBpAAAqAAQKfxoAAhEACAgGD9cLABQBABEACAgGD9cLABQBAAAA.',['修儸']='修儸栤:BAABKgAFFH8LAAIFAAMIjgeYDwB/AAAFAAMIjgeYDwB/AAAAAA==.',['元素']='元素萨:BAABKgAFFH8RAAITAAMIoAqMNwCiAAATAAMIoAqMNwCiAAAAAA==.',['先森']='先森:BAAAKgAFFAgIBAAAAA==.',['兜兜']='兜兜有洞:BAAAKgAECgUICQAAAA==.',['公子']='公子放:BAABKgAFFH8IAAIUAAQIIQXoGwB7AAAUAAQIIQXoGwB7AAAAAA==.公子雷:BAAAKgAECggIEAAAAA==.',['兽戦']='兽戦:BAABKgAFFH8IAAIHAAgIRQPcCgByAQAHAAgIRQPcCgByAQAAAA==.',['冷似']='冷似冰心:BAAAKgADCggICAAAAA==.',['冷月']='冷月丄凝霜:BAAAKgAECgYIBAAAAA==.',['冷酷']='冷酷的泪:BAAAKgAECgYICQAAAA==.',['凝凝']='凝凝不睡觉:BAAAKgAECgQIBAAAAA==.',['凤丫']='凤丫头:BAAAKgAFFAIIAgAAAA==.',['前列']='前列缐碎击者:BAAAKgAECgYIEgAAAA==.',['剑啸']='剑啸龙吟:BAAAKgAECgEIAQAAAA==.',['剑潇']='剑潇潇风呼呼:BAABKgAECn8+AAIVAAgILxIoLQCfAQAVAAgILxIoLQCfAQAAAA==.',['剑舞']='剑舞风霜:BAAAKgADCgEIAQAAAA==.',['北笙']='北笙:BAABKgAFFH8QAAIKAAMI3gbEHQCXAAAKAAMI3gbEHQCXAAAAAA==.',['北职']='北职忍忍:BAAAKgADCgEIAQAAAA==.',['北饮']='北饮风:BAAAKgAECgcIEAAAAA==.',['匹諾']='匹諾曹:BAAAKgAECgcIBwAAAA==.',['十分']='十分有型:BAAAKgADCgUIBQAAAA==.',['十字']='十字軍咄咄:BAAAKgADCgEIAQAAAA==.',['千年']='千年妖狐:BAAAKgAECggIEQAAAA==.',['单小']='单小龙:BAACKgAFFH8SAAMWAAYI9B0vAgAOAQAWAAQIlRovAgAOAQAUAAQIIRbzEADNAAAqAAQKfxgAAhQACAjHGr0fALMBABQACAjHGr0fALMBAAAA.',['南歌']='南歌:BAAAKgAECgIIAgAAAA==.',['变一']='变一手:BAAAKgAECggIDgAAAA==.',['叶丿']='叶丿无双:BAAAKgAFFAEIAgAAAA==.叶丿晓霜:BAAAKgAFFAMIAgAAAA==.',['叽翅']='叽翅:BAAAKgAFFAQIBAAAAA==.',['吉真']='吉真:BAAAKgAECgcIBwAAAA==.',['名誉']='名誉:BAABKgAFFH8IAAIFAAgIAQrcBQBuAQAFAAgIAQrcBQBuAQAAAA==.',['吒斯']='吒斯特兎亦特:BAAAKgAFFAMIAwAAAA==.',['君不']='君不见云之夏:BAABKgAFFH8MAAMBAAMIaQRORwBvAAABAAIIgQRORwBvAAAGAAMIIAImGAA6AAAAAA==.',['周生']='周生:BAAAKgAECggIEQAAAA==.',['呲啦']='呲啦啦:BAAAKgADCgQIBAAAAA==.',['呼哈']='呼哈啥:BAAAKgADCgEIAQAAAA==.',['咕哒']='咕哒子本咕:BAAAKgAECgQICAAAAA==.',['咣当']='咣当:BAAAKgAFFAIIAgAAAA==.',['哈士']='哈士骑丶:BAAAKgAECgcIBwAAAA==.',['哞哞']='哞哞哒:BAAAKgAFFAIIAgAAAA==.',['啥爷']='啥爷不是爷:BAAAKgAECgcIBwAAAA==.',['喜多']='喜多啤梨丶:BAAAKgADCgcIAwAAAA==.',['喵喵']='喵喵:BAAAKgAECggIDQAAAA==.',['嗳我']='嗳我逍遥似仙:BAAAKgADCgEIAgAAAA==.',['嘎嘎']='嘎嘎:BAAAKgAFFAMIAwAAAA==.',['嘿鎍']='嘿鎍:BAAAKgAFFAMIAwAAAA==.',['土苟']='土苟丶:BAABKgAECn8VAAIXAAgIMR3oNAAiAgAXAAgIMR3oNAAiAgAAAA==.',['圣光']='圣光丨透心凉:BAAAKgAFFAEIAQAAAA==.圣光之莉:BAAAKgAECgcIBwAAAA==.',['地狱']='地狱术弑:BAACKgAFFH8VAAIYAAQIGAf/OACMAAAYAAQIGAf/OACMAAAqAAQKf1YAAhgACAjYF2ULAOQBABgACAjYF2ULAOQBAAAA.',['塞巴']='塞巴斯蒂安:BAAAKgADCggIEAAAAA==.',['墨丘']='墨丘利丶:BAACKgAFFH8kAAQZAAYIyx/hAQCZAQAZAAUIoxnhAQCZAQAYAAMINRo2EQDhAAAaAAQIuwwBBgDXAAAqAAQKfy0AAxoACAiqHi4MACgCABoACAgJHC4MACgCABkABwgWHiINAJABAAAA.',['多尼']='多尼多尼:BAAAKgAFFAIIAgAAAA==.',['夜怨']='夜怨丶凌风:BAAAKgADCgEIAQAAAA==.',['大尐']='大尐姐啊:BAAAKgAECggIAQAAAA==.',['大窑']='大窑:BAAAKgAECgIIAgAAAA==.',['天天']='天天对你:BAAAKgAECgYIBQAAAA==.',['天山']='天山新泰罗:BAAAKgADCggICAAAAA==.',['太贰']='太贰真人:BAAAKgADCgIIAgAAAA==.',['奉天']='奉天都督:BAAAKgAECgMIBQAAAA==.',['如沐']='如沐春风呀:BAAAKgAECggICAAAAA==.',['妮蔻']='妮蔻妮蔻:BAABKgAFFH8IAAITAAQIPyESBwAhAQATAAQIPyESBwAhAQAAAA==.',['姚总']='姚总休闲:BAAAKgAECgYICwAAAA==.姚总摆摊:BAAAKgAECgIIAwAAAA==.姚总摆烂:BAAAKgADCgEIAQAAAA==.姚总摸鱼:BAAAKgAECgUIBQAAAA==.',['孔子']='孔子吃午饭:BAAAKgAECggIEAAAAA==.',['孤狼']='孤狼望月:BAAAKgADCgEIAQAAAA==.',['射几']='射几箭:BAAAKgADCgIIAgAAAA==.',['小世']='小世:BAAAKgAECgYIEAAAAA==.',['小公']='小公该:BAAAKgAECgQIBAAAAA==.',['小可']='小可乃:BAAAKgADCggICAAAAA==.',['小小']='小小蛆:BAAAKgAECgIIAgAAAA==.',['小手']='小手拔拔凉:BAAAKgADCgEIAQAAAA==.',['小柠']='小柠萌吖:BAACKgAFFH8MAAMXAAYIgRu9DgCJAQAXAAYIgRu9DgCJAQAbAAQI2hPQCwDuAAAqAAQKfx8AAhcACAiyI6YVAIECABcACAiyI6YVAIECAAAA.',['小楚']='小楚子:BAABKgAFFH8GAAIMAAYIegsoCgA6AQAMAAYIegsoCgA6AQAAAA==.',['小胖']='小胖飞起来:BAABKgAFFH8GAAIXAAMIKhVDFgDcAAAXAAMIKhVDFgDcAAAAAA==.',['小酪']='小酪:BAABKgAECn8kAAIXAAgIQRoMOADFAQAXAAgIQRoMOADFAQAAAA==.',['尐孓']='尐孓賊婲:BAAAKgADCgcIBwAAAA==.',['少语']='少语:BAAAKgAFFAQIBAAAAA==.',['巍剑']='巍剑鸣:BAAAKgAECgYIBgAAAA==.',['巫即']='巫即:BAAAKgADCgMIAwAAAA==.',['巴啦']='巴啦啦:BAAAKgADCgEIAQAAAA==.',['巴子']='巴子沁:BAABKgAFFH8GAAIcAAYIBRYbAwArAQAcAAYIBRYbAwArAQAAAA==.',['希尔']='希尔瓦娜思:BAAAKgAECgEIAQAAAA==.',['幸福']='幸福的小八:BAAAKgAECgYIBwAAAA==.',['幽靈']='幽靈視覺:BAAAKgAECggIEQAAAA==.',['张灬']='张灬翼德:BAABKgAFFH8CAAIVAAIIUgoPIwB7AAAVAAIIUgoPIwB7AAAAAA==.',['御坂']='御坂灬美琴:BAACKgAFFH8OAAIXAAYIhSLiCwCxAQAXAAYIhSLiCwCxAQAqAAQKfxgABBsACAiIHc8pAMABABsACAhVGM8pAMABABcABwjFGsdzAFgBAB0AAgimHokYAHAAAAAA.',['德霸']='德霸天下:BAAAKgAFFAcIAwABKgAFFAgICgAbAM0ZAA==.',['思该']='思该:BAACKgAFFH8YAAIDAAQI4RmhFwDVAAADAAQI4RmhFwDVAAAqAAQKfyIAAgMACAj3HooEAD4CAAMACAj3HooEAD4CAAAA.',['恨别']='恨别鸟精心:BAAAKgADCggICAAAAA==.',['恶魔']='恶魔丨之心:BAAAKgAFFAIIAgAAAA==.',['情情']='情情:BAAAKgADCgEIAQAAAA==.',['惊爆']='惊爆旅行团:BAAAKgAECggICAAAAA==.',['憨地']='憨地神牛:BAAAKgAFFAYIBAAAAA==.',['我也']='我也滄海:BAAAKgAFFAcIAwAAAA==.',['我俏']='我俏丽吗:BAAAKgADCgEIAQAAAA==.',['戦灬']='戦灬軐:BAAAKgAECgUIBQAAAA==.',['扎克']='扎克油:BAAAKgADCgcIBwAAAA==.',['振袖']='振袖袖:BAAAKgAECggICAAAAA==.',['提小']='提小莫:BAAAKgADCgQIBAAAAA==.',['摩西']='摩西尐姐:BAAAKgAFFAQIBAAAAA==.',['撩蔭']='撩蔭手王五:BAABKgAFFH8LAAIeAAMIwBOpEgCaAAAeAAMIwBOpEgCaAAABKgAFFAgIDwADAM4XAA==.',['放牛']='放牛娃娃:BAAAKgAECgUIBQAAAA==.',['敬畏']='敬畏之心:BAABKgAFFH8FAAICAAUISiDXCwBmAQACAAUISiDXCwBmAQAAAA==.',['断水']='断水流小师妹:BAAAKgADCgcIBwABKgAFFAgILQAfAGQeAA==.',['施主']='施主留步:BAAAKgADCggICAAAAA==.',['无处']='无处停歇的风:BAAAKgAFFAQIBAAAAA==.',['无敌']='无敌嘲讽:BAAAKgADCgMIAwAAAA==.',['无良']='无良小僧:BAABKgAFFH8JAAMVAAQI9AsSIwCWAAAVAAQI9AsSIwCWAAAeAAEImwUfHwA/AAAAAA==.',['日兔']='日兔侠:BAAAKgAECggICAAAAA==.',['晨曦']='晨曦炛爻:BAAAKgAFFAIIAgABKgAFFAgIDAAEAPURAA==.',['晴天']='晴天:BAABKgAFFH8HAAIBAAcIZRS6CAAiAgABAAcIZRS6CAAiAgAAAA==.',['暗影']='暗影烧:BAAAKgADCggICAAAAA==.',['暨鈅']='暨鈅:BAABKgAFFH8GAAIBAAQIHiCtTgDSAAABAAQIHiCtTgDSAAAAAA==.',['暴躁']='暴躁小喵:BAABKgAFFH8MAAMXAAYIEhwOGgAuAQAXAAUIEhwOGgAuAQAbAAQImA0pGAChAAAAAA==.',['曼珠']='曼珠丶沙华:BAAAKgAECgEIAQAAAA==.',['最後']='最後的夏天:BAABKgAFFH8IAAIKAAMINxIrGQCxAAAKAAMINxIrGQCxAAAAAA==.',['月丶']='月丶运转:BAABKgAFFH8IAAMCAAgIsB3WBADYAQACAAcIJBzWBADYAQAMAAEIyAYSGgBDAAAAAA==.',['有一']='有一点淘气:BAAAKgAECgYIBwAAAA==.',['木仓']='木仓示申:BAAAKgAECgIIAgAAAA==.',['本命']='本命有希:BAAAKgADCgQIBAAAAA==.',['李一']='李一桐:BAAAKgAFFAQIBAAAAA==.',['柠檬']='柠檬味可乐:BAAAKgADCgYIBgAAAA==.',['柠萌']='柠萌:BAACKgAFFH8TAAMXAAYIkSRzAQDnAQAXAAYIjyRzAQDnAQAbAAQITxhYCQD9AAAqAAQKfx4AAxcACAjqJJwPAKgCABcACAjqJJwPAKgCABsABgiZGbNKAPIAAAEqAAUUCAgLABcA5xYA.柠萌冰激凌:BAACKgAFFH8GAAIXAAQIeg7BHwDZAAAXAAQIeg7BHwDZAAAqAAQKfxcAAhcACAi9HvIhADQCABcACAi9HvIhADQCAAAA.柠萌尐姐:BAAAKgAFFAQIBAABKgAFFAgIBAAgAAAAAA==.柠萌美琳娜:BAAAKgAECgMIAwAAAA==.柠萌达薇琪:BAAAKgAECggIDQAAAA==.',['梦丶']='梦丶点滴:BAAAKgAFFAEIAQAAAA==.梦丶点滴五世:BAAAKgAFFAEIAgAAAA==.梦丶点滴六世:BAAAKgAFFAEIAQAAAA==.',['梦点']='梦点滴四世:BAAAKgAFFAEIAQAAAA==.',['楓葉']='楓葉幽靈:BAAAKgAECggICQAAAA==.',['欢愉']='欢愉丶咖啡豆:BAAAKgAECgYIBwAAAA==.',['欧尼']='欧尼酱:BAAAKgAECgIIAgAAAA==.',['正义']='正义之光:BAAAKgADCgEIAQAAAA==.',['死亡']='死亡守望:BAAAKgAECgMIBwAAAA==.死亡预兆:BAABKgAFFH8NAAIaAAMIvQk6EgCuAAAaAAMIvQk6EgCuAAAAAA==.',['残阳']='残阳灬月落:BAAAKgAFFAEIAQAAAA==.',['殘淵']='殘淵之悅:BAAAKgAFFAMIAwAAAA==.',['殛殇']='殛殇之亡魂:BAAAKgADCggIEAAAAA==.殛殇之魂:BAAAKgADCggICAAAAA==.',['殿堂']='殿堂級的聖騎:BAAAKgADCgIIAgAAAA==.',['水晶']='水晶晶:BAABKgAFFH8KAAIEAAYIURl8EwB+AQAEAAYIURl8EwB+AQABKgAFFAgICAAHALMSAA==.',['汐寒']='汐寒丶:BAABKgAFFH8IAAIHAAgIEQf7BwDgAQAHAAgIEQf7BwDgAQAAAA==.',['汩汩']='汩汩:BAAAKgAFFAMIAwAAAA==.',['沐丶']='沐丶丝:BAAAKgAECgMIAwAAAA==.',['沫懿']='沫懿米:BAAAKgAECggIEQABKgAFFAYICQAKAOgZAA==.',['沾不']='沾不起的灬花:BAAAKgAECgYIBgAAAA==.',['波希']='波希:BAAAKgAFFAQIBAAAAA==.',['洛丹']='洛丹伦的秋叶:BAAAKgAFFAIIAgAAAA==.',['浅浅']='浅浅:BAABKgAFFH8KAAIBAAYILxztFgCkAQABAAYILxztFgCkAQAAAA==.',['浪李']='浪李个狼:BAAAKgADCggICAAAAA==.',['海苔']='海苔饭团:BAACKgAFFH8nAAIUAAgIVyArBQBTAgAUAAgIVyArBQBTAgAqAAQKfzkAAhQACAgoJAINAG4CABQACAgoJAINAG4CAAAA.',['淡烟']='淡烟流水:BAABKgAFFH8JAAITAAcIyRBIDACFAQATAAcIyRBIDACFAQABKgAFFAgICAATALsbAA==.',['深度']='深度死亡:BAAAKgADCggICAAAAA==.',['火火']='火火爱将:BAAAKgAECgIIAgAAAA==.',['灬之']='灬之糕緈:BAABKgAFFH8OAAMaAAYIUBdABgAVAQAYAAYIsg+LGQA4AQAaAAQIpCFABgAVAQAAAA==.',['灬夜']='灬夜雨凝伤:BAAAKgAECgUIBQABKgAFFAgIDAAOAHMZAA==.',['灬熙']='灬熙:BAACKgAFFH8LAAINAAcIrhnyBwAaAgANAAcIrhnyBwAaAgAqAAQKfxoAAg0ACAhAHbYeAA4CAA0ACAhAHbYeAA4CAAAA.',['灬神']='灬神谕逍遥灬:BAAAKgAECgcIBwAAAA==.',['灬薄']='灬薄情灬:BAAAKgADCggICAAAAA==.',['灰灰']='灰灰牛:BAAAKgAFFAIIAgAAAA==.',['灵灵']='灵灵發:BAAAKgAECgMIAwAAAA==.',['灵魂']='灵魂呐喊:BAAAKgADCgQIBAAAAA==.',['炊事']='炊事班长:BAAAKgAFFAIIAgAAAA==.',['炸毛']='炸毛男:BAAAKgADCgIIAgAAAA==.',['烈焰']='烈焰灼天:BAAAKgAECggIAQAAAA==.',['烈阳']='烈阳:BAAAKgADCggICAAAAA==.',['狂野']='狂野震天:BAAAKgADCggIDgAAAA==.',['狼殿']='狼殿下:BAABKgAFFH8NAAIBAAMI0wibZAClAAABAAMI0wibZAClAAAAAA==.',['猪小']='猪小熊:BAAAKgAECgUIBQAAAA==.猪小绮:BAAAKgADCgEIAwAAAA==.',['猫熊']='猫熊酒仙:BAACKgAFFH8bAAMhAAQINx96FgDSAAAhAAIIGSV6FgDSAAAHAAIIchMkNgBIAAAqAAQKfyEAAyEACAgKITYiAKQBACEABQj+ITYiAKQBAAcABAgaG01YAPkAAAAA.',['猫猫']='猫猫祟祟:BAAAKgAFFAQIAgAAAA==.',['瑶绫']='瑶绫瑶:BAAAKgADCgYIBgAAAA==.',['电网']='电网:BAAAKgAECggICAAAAA==.',['疑是']='疑是银河:BAABKgAECn8cAAIIAAgIIRwADgD/AQAIAAgIIRwADgD/AQAAAA==.',['疯狂']='疯狂的灬戦:BAAAKgADCgEIAQAAAA==.疯狂的灬骑:BAAAKgAECgYIBAAAAA==.',['盜丶']='盜丶賊:BAAAKgADCggICAAAAA==.',['盾牌']='盾牌护菊花:BAABKgAFFH8RAAIBAAgIIiDSBACJAgABAAgIIiDSBACJAgAAAA==.',['真墨']='真墨丘利:BAACKgAFFH8KAAIBAAMIPA6IJwDUAAABAAMIPA6IJwDUAAAqAAQKfxsAAgEACAjaItUgAJYCAAEACAjaItUgAJYCAAAA.',['真夜']='真夜灬随风:BAABKgAFFH8KAAIGAAYIog2lEQDzAAAGAAYIog2lEQDzAAABKgAFFAgIDQABAOEYAA==.',['瞅一']='瞅一下:BAAAKgAECggIEAAAAA==.',['瞎球']='瞎球哔哔:BAACKgAFFH8PAAIQAAMI1gfTGwB3AAAQAAMI1gfTGwB3AAAqAAQKfxgAAhAACAjxE4klAFQBABAACAjxE4klAFQBAAAA.',['瞬间']='瞬间丶忘却:BAAAKgADCggIDQAAAA==.瞬间丶永恒:BAAAKgAECgMIAwAAAA==.瞬间丶消逝:BAAAKgAECgMIAwAAAA==.',['祂人']='祂人难悟:BAAAKgAECgUIBQAAAA==.',['秦始']='秦始皇:BAAAKgADCgMIAwAAAA==.',['红发']='红发偷猎者:BAAAKgADCgEIAQAAAA==.',['绘梦']='绘梦之娟:BAAAKgAECgQIBAAAAA==.',['绝地']='绝地狂战:BAAAKgAECgMIAwAAAA==.',['统领']='统领牛牛:BAAAKgAECgYICQAAAA==.',['罗贝']='罗贝尔特:BAAAKgAECgUIBQAAAA==.',['罪恶']='罪恶痕迹:BAABKgAFFH8QAAQYAAgIqx9jAgCGAgAYAAgIjh5jAgCGAgAZAAIIHh3XDQC3AAAaAAIIniTnDgBsAAAAAA==.',['美丶']='美丶屡:BAAAKgADCgMIAQAAAA==.',['美艳']='美艳如花:BAABKgAFFH8GAAIPAAQITAlhEQCLAAAPAAQITAlhEQCLAAAAAA==.',['老茶']='老茶的第二天:BAAAKgAECggICQABKgAFFAgIDgAfACQgAA==.',['肥嘟']='肥嘟嘟:BAABKgAECn8VAAMaAAgIECGVBwB6AgAaAAgI+h+VBwB6AgAZAAgI4R5RBABCAgABKgAFFAgIFAAYALEhAA==.',['脏了']='脏了的雪:BAABKgAECn8aAAMLAAgIHwFQRgA7AAALAAgIHwFQRgA7AAAKAAYIAAAAAAAAAAAAAA==.',['芙蓉']='芙蓉王:BAAAKgAECgEIAQAAAA==.',['芳心']='芳心纵火犯:BAABKgAECn8UAAIBAAgI7B8DLABPAgABAAgI7B8DLABPAgAAAA==.',['苗淼']='苗淼开风车:BAAAKgADCggICAAAAA==.',['英勇']='英勇荣耀:BAABKgAFFH8IAAIhAAgI0hjuAgA8AgAhAAgI0hjuAgA8AgAAAA==.',['荣耀']='荣耀忄烈火:BAAAKgAECggIDQAAAA==.',['莱恩']='莱恩雪影:BAAAKgAFFAYIAgABKgAFFAgIAgAgAAAAAA==.',['萧萧']='萧萧木鱼:BAAAKgADCggICAAAAA==.',['萨拉']='萨拉塔坤:BAAAKgAECggICAAAAA==.',['萨西']='萨西布力:BAAAKgAECgUIBQAAAA==.',['萬物']='萬物皆可秒:BAAAKgAECgMIAwAAAA==.',['蓝莓']='蓝莓拿铁:BAAAKgAECgUIBQAAAA==.',['虚光']='虚光:BAAAKgADCgEIAQAAAA==.',['虚白']='虚白:BAAAKgADCgUIBgAAAA==.',['蚂蚁']='蚂蚁:BAAAKgAFFAgIAgAAAA==.',['血色']='血色的黄昏:BAABKgAFFH8GAAIKAAYI/RSGBwBMAQAKAAYI/RSGBwBMAQAAAA==.',['西鎍']='西鎍:BAABKgAFFH8FAAIXAAMIXwndQACbAAAXAAMIXwndQACbAAAAAA==.',['西门']='西门秦:BAABKgAFFH8FAAIEAAUI5RTSHAA4AQAEAAUI5RTSHAA4AQAAAA==.',['譕顔']='譕顔:BAABKgAFFH8NAAIBAAgIcyC/AgC6AgABAAgIcyC/AgC6AgAAAA==.',['诺言']='诺言:BAAAKgADCgQICAAAAA==.',['贝肯']='贝肯:BAAAKgAFFAQIBAAAAA==.',['贼快']='贼快乐:BAABKgAFFH8IAAIJAAQIXRX6DADXAAAJAAQIXRX6DADXAAAAAA==.',['贾小']='贾小白:BAAAKgAECggIDgAAAA==.',['赫本']='赫本:BAAAKgAECgIIAgAAAA==.',['逝去']='逝去的丶青春:BAAAKgADCgYIBgAAAA==.',['那个']='那个增强萨满:BAAAKgADCgIIAgAAAA==.',['那火']='那火:BAAAKgAECggICAAAAA==.',['邪念']='邪念:BAABKgAFFH8PAAMYAAgIlBRiDgCnAQAYAAgIlBRiDgCnAQAaAAEIAABeJAAAAAAAAA==.',['部落']='部落上等兵:BAAAKgAFFAIIAgAAAA==.',['酥脆']='酥脆曲奇:BAAAKgAFFAgIAgAAAA==.',['酸奶']='酸奶面包:BAAAKgAECgQIBAAAAA==.',['醉后']='醉后一螩喍:BAAAKgAECgUIBwAAAA==.',['醉爱']='醉爱杀戮:BAABKgAFFH8FAAIEAAMI1AoiOgC0AAAEAAMI1AoiOgC0AAAAAA==.',['醉笑']='醉笑人生:BAAAKgAECgIIAgAAAA==.',['醉风']='醉风行:BAAAKgAECgcIEQAAAA==.',['重生']='重生柠檬:BAAAKgADCggICAAAAA==.',['鐵心']='鐵心:BAABKgAFFH8IAAIFAAYIVw8wEgARAQAFAAYIVw8wEgARAQAAAA==.',['锦添']='锦添:BAAAKgAECgMIAwAAAA==.',['長生']='長生:BAABKgAFFH8IAAQKAAQIdRbpFgC6AAAKAAMIrhDpFgC6AAAfAAQIBQ57OACAAAALAAEIAAC1QwAAAAAAAA==.',['闭嘴']='闭嘴:BAAAKgAECgYICgAAAA==.',['阿洛']='阿洛伊斯塔萨:BAACKgAFFH8eAAIUAAUIHyKbCwCCAQAUAAUIHyKbCwCCAQAqAAQKf0MAAxQACAjTI/gFAMECABQACAjTI/gFAMECABYAAQhQClYpAC8AAAAA.',['阿芙']='阿芙罗狄蒂:BAAAKgAECgUIBQAAAA==.',['霓裳']='霓裳叮当:BAAAKgAECgEIAQAAAA==.',['霜吼']='霜吼:BAABKgAFFH8GAAIEAAYIdR9BDgCyAQAEAAYIdR9BDgCyAQAAAA==.',['霜牛']='霜牛猎:BAAAKgADCggICAAAAA==.',['露比']='露比小贝贝:BAAAKgAFFAgIAgAAAA==.',['霸道']='霸道的老二:BAABKgAFFH8FAAIiAAMIXARADQCUAAAiAAMIXARADQCUAAAAAA==.',['靈魂']='靈魂脫臼:BAACKgAFFH8GAAICAAYIDiM6BQDnAQACAAYIDiM6BQDnAQAqAAQKfx0AAgIACAguCxxFAP4AAAIACAguCxxFAP4AAAAA.',['青梅']='青梅小绿茶:BAAAKgAFFAYIAgAAAA==.',['静静']='静静熙熙无心:BAAAKgAECgQIBAAAAA==.',['頂尖']='頂尖高手:BAAAKgAECgcICgAAAA==.',['颜汐']='颜汐:BAAAKgAECgEIAQAAAA==.',['风帆']='风帆:BAAAKgAFFAIIAgAAAA==.',['风雷']='风雷之翼:BAABKgAECn8rAAIiAAgIwBzFBABeAgAiAAgIwBzFBABeAgAAAA==.',['饿昏']='饿昏的猪:BAAAKgAECgYIBgAAAA==.',['魅力']='魅力丨华少爷:BAAAKgAFFAIIAgAAAA==.',['魔鬼']='魔鬼绞肉机:BAAAKgAECgIIAwAAAA==.',['鴛鴦']='鴛鴦鬼骨:BAAAKgAFFAQIBAAAAA==.',['黑暗']='黑暗微笑:BAABKgAFFH8GAAIFAAYI9BlMCQCBAQAFAAYI9BlMCQCBAQAAAA==.',['黑骑']='黑骑士灬:BAAAKgAFFAMIAwAAAA==.',['龍丶']='龍丶熙熙:BAACKgAFFH8PAAMCAAII/gnQHQBsAAADAAIIFQlUIgBuAAACAAII/gnQHQBsAAAqAAQKfysAAwIACAh1F5kjAMgBAAIACAh0FZkjAMgBAAMABgi2DWxqAFwAAAAA.龍丶艳:BAAAKgAECgEIAQAAAA==.',['龍艳']='龍艳缘:BAAAKgAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end