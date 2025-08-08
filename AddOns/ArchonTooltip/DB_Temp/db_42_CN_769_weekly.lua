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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Shaman-Restoration','Hunter-Marksmanship','Hunter-BeastMastery','Warrior-Fury','Warrior-Arms','Priest-Holy','Paladin-Any','Monk-Mistweaver','Monk-Brewmaster','Warlock-Destruction','Warlock-Demonology','DeathKnight-Unholy','Warlock-Affliction','Evoker-Devastation','Evoker-Preservation','Priest-Discipline','Priest-Shadow','Mage-Arcane','Mage-Fire','Mage-Frost','DeathKnight-Blood','Druid-Restoration','Druid-Balance','DemonHunter-Havoc','Rogue-Assassination','Shaman-Elemental','DeathKnight-Frost','DemonHunter-Vengeance','Monk-Windwalker',}; local provider = {region='CN',realm='生态船',name='CN',type='weekly',zone=42,date='2025-08-08',data={At='Atom:BAAAKgADCgUIBQAAAA==.Atyourside:BAACKgAFFH8pAAIBAAQIgR7RGwAHAQABAAQIgR7RGwAHAQAqAAQKfyEAAwEACAh/G7xvAHcBAAEACAh/G7xvAHcBAAIAAQjuAS1vAAYAAAAA.',Br='Breezy:BAAAKgAECgcIBwAAAA==.',Ca='Carljiang:BAAAKgAECggIBQAAAA==.',Cl='Clav:BAABKgAFFH8QAAIDAAYInRz3CQCmAQADAAYInRz3CQCmAQAAAA==.',Da='Dalao:BAAAKgAECggICAAAAA==.',Dc='Dcgga:BAAAKgAECgYIEgAAAA==.',El='Elegancekill:BAAAKgAFFAQIBAAAAA==.Elementalist:BAAAKgAECggICAAAAA==.',Hu='Huntme:BAAAKgAFFAEIAQAAAA==.Huntmedown:BAAAKgAECggIDgAAAA==.',Im='Imperiusa:BAAAKgAECggICAAAAA==.',['Iâ']='Iâhateâyou:BAABKgAFFH8IAAMEAAgIpBJ4GQAfAQAEAAQIlhB4GQAfAQAFAAQIYRVnMADKAAAAAA==.',Ku='Kumomo:BAACKgAFFH8FAAMGAAIIjh3sGwCnAAAGAAIIjh3sGwCnAAAHAAEIOheAGABRAAAqAAQKfx8AAwYACAhJJXoHANACAAYACAjUJHoHANACAAcAAwiqITZHALIAAAAA.',Le='Leayn:BAAAKgAFFAIIAgAAAA==.',Lo='Lofalt:BAAAKgADCgEIAQAAAA==.',Lu='Lussim:BAAAKgAECgQIBgAAAA==.',Mi='Minath:BAAAKgADCgMIAwAAAA==.Minecrsft:BAABKgAFFH8NAAIBAAQI7CB6NAAYAQABAAQI7CB6NAAYAQAAAA==.Mineras:BAAAKgAECgQIBAAAAA==.',Pl='Plato:BAABKgAECn8XAAIIAAcIKBqvJwCSAQAIAAcIKBqvJwCSAQAAAA==.',Po='Porquetevas:BAAAKgAECgMIAwAAAA==.',Re='Redeagle:BAAAKgAECgIIAgAAAA==.',Se='Selenec:BAAAKgAECggIEAAAAA==.',Tu='Tugenden:BAAAKgAECgYIBgAAAA==.',Vi='Vitality:BAAAKgAFFAQIBAAAAA==.',Wi='Wingman:BAAAKgADCggICAAAAA==.',Wo='Workhard:BAAAKgAECgQIBQAAAA==.',Xy='Xyeternal:BAAAKgAFFAQIBAAAAA==.',Yi='Yijiandh:BAAAKgAFFAQIBAAAAA==.',Yo='Youcxss:BAAAKgADCgYIBgAAAA==.',Zz='Zzkings:BAABKgAFFH8GAAIJAAYILxEAAAAAAAABAAYILxEAAAAAAAAAAA==.',['一周']='一周五次:BAAAKgADCggICAAAAA==.',['一片']='一片情天:BAAAKgAECgQIBAAAAA==.',['一青']='一青菜一:BAAAKgADCggICAAAAA==.',['七仔']='七仔:BAABKgAFFH8VAAMKAAgIVRulAwARAgAKAAgIVRulAwARAgALAAQINA5DBQCdAAAAAA==.',['三生']='三生猎月:BAAAKgAECggICAAAAA==.',['下一']='下一把:BAABKgAFFH8SAAIDAAMI9QApJgBTAAADAAMI9QApJgBTAAAAAA==.',['专业']='专业拉人:BAAAKgADCggICAAAAA==.专业挖坑:BAAAKgAECgIIAgAAAA==.',['两个']='两个小矮:BAAAKgADCgYIDwAAAA==.',['临时']='临时工丶:BAABKgAECn8iAAIDAAgIZhZ2NAClAQADAAgIZhZ2NAClAQAAAA==.',['丶阿']='丶阿狸:BAAAKgAFFAEIAQAAAA==.',['为了']='为了洛丹伦:BAAAKgAECgcIBwAAAA==.',['丿丶']='丿丶浅唱:BAABKgAECn8jAAMMAAgIQxn0GQDWAQAMAAgIQxn0GQDWAQANAAcIMQ/JLgAuAQAAAA==.丿丶秋月爱莉:BAAAKgAECggICAAAAA==.',['丿灬']='丿灬蕝版妖嘼:BAAAKgAFFAYIBAAAAA==.',['乌设']='乌设尔:BAAAKgAECgIIAgAAAA==.',['九天']='九天境主:BAAAKgAECgQICgAAAA==.',['亅黑']='亅黑夜亅:BAAAKgADCggICAAAAA==.',['云天']='云天明:BAAAKgADCgUIBQAAAA==.',['云彩']='云彩儿:BAAAKgAFFAIIAgAAAA==.',['五河']='五河琴里丶:BAAAKgAFFAQIBAABKgAFFAgILQAFAMMeAA==.',['亦丶']='亦丶木:BAAAKgADCgYIBgAAAA==.',['人間']='人間凶器:BAABKgAFFH8IAAIFAAYIyhBYFgBFAQAFAAYIyhBYFgBFAQAAAA==.',['伊卡']='伊卡洛斯:BAACKgAFFH8FAAIBAAMIQhNFVADIAAABAAMIQhNFVADIAAAqAAQKfykAAgEACAjVI6MPAM8CAAEACAjVI6MPAM8CAAAA.',['伊瑞']='伊瑞安娜:BAAAKgAECgUIBwABKgAFFAgICwACAGkEAA==.',['众神']='众神裁决:BAAAKgAECgYIBgAAAA==.',['佛阁']='佛阁提米:BAAAKgAECgEIAQAAAA==.',['假死']='假死玩的溜啊:BAAAKgAECggIDQAAAA==.',['光之']='光之审判:BAAAKgAECgIIAgAAAA==.',['兔子']='兔子丶:BAAAKgAECgcICwAAAA==.',['全球']='全球可飞:BAABKgAFFH8GAAIFAAYIkBi0FABQAQAFAAYIkBi0FABQAQAAAA==.',['八佰']='八佰一锤:BAABKgAECn8VAAIBAAgIJiA3PAA6AgABAAgIJiA3PAA6AgAAAA==.',['公子']='公子丶城堡:BAAAKgADCgQIBAAAAA==.公子丶念:BAAAKgADCggICQAAAA==.公子丶晓:BAAAKgADCgMIAwAAAA==.',['六号']='六号床的老匡:BAAAKgAECggIDwAAAA==.',['关于']='关于信仰:BAAAKgAECgIIAgAAAA==.',['冰凛']='冰凛暗月:BAAAKgAECgIIAgAAAA==.',['冰镇']='冰镇蜂蜜:BAACKgAFFH8rAAMFAAgIKiLnBABYAgAFAAgIKiLnBABYAgAEAAEIzwdaUAA9AAAqAAQKfzkAAwUACAglJcoHAO4CAAUACAglJcoHAO4CAAQAAQhDF1KgADwAAAAA.',['刹那']='刹那烟云:BAAAKgAFFAEIAQAAAA==.',['剑神']='剑神叶孤城:BAAAKgAFFAIIAgAAAA==.',['十四']='十四丶白:BAAAKgAECgUIBQAAAA==.',['十字']='十字叹息:BAAAKgAFFAQIAgAAAA==.',['千古']='千古魔尊:BAAAKgAECgMIBQAAAA==.',['千斗']='千斗五十铃:BAABKgAFFH8FAAMEAAQIGhpuLAC5AAAEAAMIGhpuLAC5AAAFAAEIAABEZwAAAAAAAA==.',['升腾']='升腾助我丨来:BAAAKgAECggICAAAAA==.',['华优']='华优冰其斯:BAABKgAFFH8QAAIOAAYIMyXIBgAnAgAOAAYIMyXIBgAnAgAAAA==.',['南瓜']='南瓜二米粥:BAABKgAECn9DAAQNAAgIPCQPAwDNAgANAAgIPCQPAwDNAgAMAAcISx+UGQDZAQAPAAcIyxnoEQBTAQAAAA==.',['博氏']='博氏后:BAABKgAFFH8JAAMMAAYIyBI1FgBSAQAMAAYIyBI1FgBSAQANAAEIAAAWNQAAAAAAAA==.',['卡德']='卡德咖:BAAAKgADCggICAAAAA==.',['卢克']='卢克西西卡:BAAAKgAFFAQIBAAAAA==.',['収鈊']='収鈊懩性:BAABKgAECn8cAAIBAAgIJRcvVADAAQABAAgIJRcvVADAAQAAAA==.',['叛逆']='叛逆的鲁智深:BAAAKgAFFAQIAgAAAA==.',['口下']='口下有球:BAAAKgADCggICAAAAA==.',['口袋']='口袋里的冰:BAAAKgAECggIDQAAAA==.',['只想']='只想划划氺:BAABKgAECn8VAAMQAAYIWBS2OgDxAAAQAAYIWBS2OgDxAAARAAIIxh4oHQCWAAABKgAFFAgIBwAEAHQgAA==.',['叶飘']='叶飘零芊芊:BAAAKgADCgIIAgAAAA==.',['吊问']='吊问我:BAAAKgAECgQIBAAAAA==.',['后街']='后街少女:BAAAKgADCgUIBQAAAA==.',['呆瓜']='呆瓜小贼:BAAAKgAECgcICgAAAA==.',['命运']='命运高达:BAAAKgAECgcIDQAAAA==.',['哇袄']='哇袄:BAABKgAFFH8PAAIOAAgIVRRLCAAKAgAOAAgIVRRLCAAKAgAAAA==.',['唯乙']='唯乙安:BAAAKgAECgcIDgAAAA==.',['噜噜']='噜噜卡:BAABKgAFFH8GAAIBAAYIpBhVGwCIAQABAAYIpBhVGwCIAQAAAA==.',['圣光']='圣光丨門徒:BAAAKgAECgUIBQAAAA==.圣光丶格劳瑞:BAAAKgAECggICAAAAA==.圣光会奶死你:BAAAKgAECggIDgAAAA==.圣光的赦免:BAAAKgADCggICAAAAA==.圣光裁决:BAAAKgAECgMIAwAAAA==.',['圣羽']='圣羽安歌:BAABKgAFFH8IAAQSAAQIMwySKQBvAAASAAQI+AOSKQBvAAAIAAMIdRBkGwBhAAATAAEIMgUwHAAwAAABKgAFFAYIIQATAIoQAA==.',['圣舞']='圣舞精灵:BAAAKgAECgUIBQAAAA==.',['堕落']='堕落小朋友:BAAAKgAECgQIBAAAAA==.',['增强']='增强:BAABKgAECn8ZAAIDAAYIFyNaKADeAQADAAYIFyNaKADeAQAAAA==.',['壹转']='壹转攻势:BAACKgAFFH8LAAQUAAQIFgqHPQBoAAAUAAMIRQ2HPQBoAAAVAAMIgAE9NwBeAAAWAAEI8wK4LgArAAAqAAQKfx4ABBQACAjLGe4zAH8BABUACAjdDy5BAIcBABQABgj4Gu4zAH8BABYABwg9CDRXAAoBAAAA.',['夏季']='夏季八喷:BAAAKgADCgcIBwAAAA==.',['夏有']='夏有森光:BAABKgAFFH8NAAIQAAYIDhrhCwB5AQAQAAYIDhrhCwB5AQAAAA==.',['夕阳']='夕阳舞步:BAABKgAFFH8IAAIXAAYIzQo9FwDnAAAXAAYIzQo9FwDnAAAAAA==.',['夜之']='夜之闪魂:BAAAKgAFFAQIBAAAAA==.',['大宅']='大宅一子:BAABKgAFFH8QAAIMAAgILiK8AQCkAgAMAAgILiK8AQCkAgAAAA==.',['大将']='大将:BAAAKgAECgEIAQAAAA==.',['夭妞']='夭妞哆唻:BAAAKgADCggIBQAAAA==.夭妞的城堡:BAAAKgADCgIIAgAAAA==.',['奔波']='奔波儿壩:BAAAKgAECgUIBQAAAA==.',['奥尼']='奥尼席伟雅:BAAAKgAECgUIBQAAAA==.',['奥拉']='奥拉夫:BAACKgAFFH8MAAIGAAQIsQo3FQC7AAAGAAQIsQo3FQC7AAAqAAQKfyEAAgYACAgoGEwhAMkBAAYACAgoGEwhAMkBAAAA.',['女神']='女神的断翼:BAAAKgAECgQIBgAAAA==.',['奶白']='奶白白大雪子:BAAAKgAECgQIBQAAAA==.',['如此']='如此湿滑:BAAAKgADCgIIAgAAAA==.',['妙见']='妙见愁:BAAAKgAECgYICgAAAA==.',['嬲羊']='嬲羊羊:BAAAKgAECgMIAwAAAA==.',['学妹']='学妹上门:BAAAKgADCgEIAQAAAA==.',['安慰']='安慰剂:BAAAKgAFFAIIBAAAAA==.',['寂寞']='寂寞之怒:BAAAKgAECgcICgAAAA==.',['寧靜']='寧靜呢:BAACKgAFFH9YAAMYAAgI1SAQAQCQAgAYAAgI1SAQAQCQAgAZAAEIog4dMABAAAAqAAQKfywAAxgACAj9Iz8FALsCABgACAj9Iz8FALsCABkABwh7GMAUALkBAAAA.',['射你']='射你个小东西:BAABKgAFFH8MAAIFAAYIDhKPFQBKAQAFAAYIDhKPFQBKAQAAAA==.',['射兽']='射兽座:BAAAKgAFFAQIBAAAAA==.',['小佛']='小佛:BAAAKgAFFAYIBAAAAA==.',['小十']='小十字军:BAAAKgAFFAQIAwAAAA==.',['小小']='小小怪下士:BAAAKgADCgUIBQAAAA==.',['小文']='小文姐:BAAAKgADCgMIAwAAAA==.',['小洁']='小洁儿:BAABKgAECn8XAAMTAAgIARoGGgAHAgATAAgIARoGGgAHAgAIAAcIngP3XADKAAAAAA==.',['小脸']='小脸红扑扑丶:BAABKgAECn8hAAIBAAgIOCDQEABTAgABAAgIOCDQEABTAgAAAA==.',['小麟']='小麟烬:BAABKgAFFH8IAAIBAAgI7BIWCwAVAgABAAgI7BIWCwAVAgAAAA==.',['峰仙']='峰仙人:BAAAKgADCgcIBwAAAA==.',['峰少']='峰少:BAAAKgAFFAEIAQAAAA==.',['工丶']='工丶农联盟:BAAAKgAECgYICQAAAA==.',['希厼']='希厼瓦纳斯:BAAAKgAFFAYIAgAAAA==.',['帮灬']='帮灬绑帮绑帮:BAABKgAFFH8LAAMPAAMIPBSrDQDIAAAPAAMIUxGrDQDIAAAMAAMI7hOBKgDDAAAAAA==.',['幻影']='幻影飞天:BAAAKgAFFAIIAgAAAA==.',['幻月']='幻月猎手:BAAAKgAECggIDQAAAA==.',['幽兰']='幽兰酱:BAAAKgAECgYICAAAAA==.',['幽冥']='幽冥鬼主:BAAAKgAECgEIAQAAAA==.',['库洛']='库洛艾:BAAAKgAECgMIBAAAAA==.',['开始']='开始杀:BAAAKgADCgQICAAAAA==.',['忧郁']='忧郁的冬菇:BAAAKgADCggICAAAAA==.',['快乐']='快乐小阿月巴:BAABKgAECn8XAAIKAAgI0Rl1IADqAQAKAAgI0Rl1IADqAQAAAA==.',['想你']='想你的腋:BAAAKgAECgUIBQAAAA==.',['憨憨']='憨憨战:BAAAKgAECgMIAwAAAA==.',['我不']='我不要你懂丶:BAABKgAECn8bAAIWAAgIJyHjEABAAgAWAAgIJyHjEABAAgAAAA==.',['我老']='我老公回来了:BAAAKgADCgYIBgAAAA==.',['戰小']='戰小涛:BAAAKgAECgMIAwAAAA==.',['抒情']='抒情卡农:BAAAKgADCgQIBAAAAA==.',['拔个']='拔个垂杨柳:BAABKgAFFH8IAAIaAAQICxk4EQD6AAAaAAQICxk4EQD6AAAAAA==.',['拿老']='拿老公去換糖:BAAAKgAECgIIAgAAAA==.',['搓个']='搓个大火球:BAAAKgADCggIEAAAAA==.',['摸鱼']='摸鱼大王:BAAAKgAFFAIIBAAAAA==.',['支书']='支书:BAAAKgADCgcIBwAAAA==.',['新条']='新条茜:BAAAKgAECgQIBAAAAA==.',['无形']='无形之影:BAABKgAFFH8RAAIbAAYIdBZiAQDJAQAbAAYIdBZiAQDJAQAAAA==.',['无路']='无路塞:BAAAKgAECggIEwAAAA==.',['早蕨']='早蕨之舞:BAAAKgAFFAQIBAAAAA==.',['晓得']='晓得:BAAAKgAFFAgIAgAAAA==.',['晴岚']='晴岚小涛:BAACKgAFFH8MAAMDAAQIwAmtOACfAAADAAQIwAmtOACfAAAcAAMIywOBEgCDAAAqAAQKfxsAAgMACAjhCttZADEBAAMACAjhCttZADEBAAEqAAUUCAg5ABgAmxAA.',['暗夜']='暗夜之雪:BAAAKgAECgIIAgAAAA==.暗夜灬:BAABKgAFFH8JAAIdAAMI1gORDQCQAAAdAAMI1gORDQCQAAAAAA==.',['暗星']='暗星韦鲁斯:BAAAKgADCggICAAAAA==.',['曉濤']='曉濤:BAACKgAFFH85AAIYAAgImxDmBgClAQAYAAgImxDmBgClAQAqAAQKfyYAAhgACAiBFMckAKcBABgACAiBFMckAKcBAAAA.',['月祭']='月祭挽歌:BAABKgAFFH8RAAMTAAgI3gt0BACCAQATAAcIIg10BACCAQAIAAcIGQ5vCwBsAQAAAA==.',['望舒']='望舒:BAAAKgAECgcICAAAAA==.',['木三']='木三三:BAAAKgAECgYIDAAAAA==.',['木青']='木青:BAAAKgAFFAIIAgAAAA==.木青儿:BAABKgAFFH8IAAIDAAMIxAqeNwChAAADAAMIxAqeNwChAAAAAA==.',['末日']='末日之凌云:BAAAKgADCgIIAgAAAA==.',['林木']='林木秀:BAACKgAFFH8FAAIZAAMIIwj2IQCnAAAZAAMIIwj2IQCnAAAqAAQKfxgAAxgACAhJG6ELALYBABgACAhJG6ELALYBABkAAQj1FbpQAEUAAAAA.',['格德']='格德斯:BAAAKgADCggICAAAAA==.',['桀驁']='桀驁小涛:BAABKgAFFH8GAAMBAAMIkQRccQCIAAABAAMIkQRccQCIAAACAAEINwL9LQAhAAABKgAFFAgIOQAYAJsQAA==.',['桃之']='桃之妖妖:BAAAKgAECgEIAQAAAA==.',['桃子']='桃子上的血:BAABKgAECn8bAAIWAAgIZxo6GgDiAQAWAAgIZxo6GgDiAQAAAA==.',['棍儿']='棍儿哥:BAAAKgAECgYIBgAAAA==.',['森林']='森林迷惑:BAACKgAFFH8IAAIFAAMIfguBPgCkAAAFAAMIfguBPgCkAAAqAAQKfy8AAwUACAj1G7oMAEgCAAUACAj1G7oMAEgCAAQAAQi6A+O3ABUAAAAA.',['横空']='横空出世:BAAAKgAFFAYIBAAAAA==.',['次奥']='次奥次奥草:BAAAKgAECgMIBAAAAA==.',['欢欢']='欢欢:BAAAKgADCgEIAQAAAA==.',['欧普']='欧普瑞斯:BAAAKgAECgIIAgAAAA==.',['欧皇']='欧皇的任性:BAAAKgADCggICgAAAA==.欧皇的自由:BAAAKgADCggICAAAAA==.',['歪歪']='歪歪女:BAABKgAECn8bAAIBAAgIZyBAKQB4AgABAAgIZyBAKQB4AgAAAA==.',['残小']='残小龙:BAAAKgAECggICAAAAA==.',['残魂']='残魂断:BAAAKgAECgYICQAAAA==.',['水不']='水不鸣:BAAAKgAECgIIAgAAAA==.',['永恒']='永恒烈阳:BAAAKgADCgYIBgAAAA==.',['沈婷']='沈婷:BAAAKgADCggIDwAAAA==.',['沈行']='沈行之:BAAAKgAECgIIAgAAAA==.',['没把']='没把的美女:BAAAKgAECggICAAAAA==.',['流花']='流花火舞:BAAAKgAFFAIIAgAAAA==.',['浅唱']='浅唱灬遗忘:BAAAKgADCggIEAAAAA==.',['海天']='海天叉烧酱:BAAAKgAECgEIAQAAAA==.',['淡淡']='淡淡茶清香:BAAAKgADCgQIBAAAAA==.',['清蒸']='清蒸大白鲨:BAAAKgAFFAYIBAAAAA==.',['火暴']='火暴腰花儿:BAAAKgAECgEIAQAAAA==.',['火鸡']='火鸡味锅巴丶:BAAAKgADCgEIAQAAAA==.',['灬木']='灬木大木大:BAAAKgADCgMIAwAAAA==.',['灬残']='灬残灬阳灬:BAAAKgAECgUIBQAAAA==.',['灯下']='灯下黑:BAAAKgAECgIIAgAAAA==.',['灵魂']='灵魂舞动:BAABKgAFFH8NAAMcAAMI/hQyFADLAAAcAAMI/hQyFADLAAADAAIITxDpIwCLAAAAAA==.',['灼灼']='灼灼其华:BAAAKgADCggICAAAAA==.',['炎波']='炎波:BAABKgAFFH8IAAIKAAgIvBE5BgDjAQAKAAgIvBE5BgDjAQAAAA==.',['炎爆']='炎爆打脸法:BAAAKgAECgQICQAAAA==.',['為你']='為你瘋颠:BAABKgAECn8rAAIbAAgI3xEQGgCYAQAbAAgI3xEQGgCYAQAAAA==.',['炽郎']='炽郎:BAAAKgAECgcIBwAAAA==.',['煎饼']='煎饼果子丶:BAAAKgADCggICAAAAA==.',['爱吃']='爱吃爆米花:BAACKgAFFH8QAAMCAAYI7RXcAwA3AQACAAYIahHcAwA3AQABAAIIjxp+PwCJAAAqAAQKfyAAAwEACAg3JFg1AE8CAAEACAg3JFg1AE8CAAIACAhhEJUgAFEBAAAA.',['牙咩']='牙咩呆:BAAAKgAFFAMIAwABKgAFFAgIEAASANwaAA==.',['牛哥']='牛哥:BAABKgAFFH8SAAIXAAQIJQ8kEwCtAAAXAAQIJQ8kEwCtAAAAAA==.',['独领']='独领风流:BAAAKgAFFAEIAQAAAA==.',['狼来']='狼来了又去:BAAAKgADCgMIAwAAAA==.',['猪儿']='猪儿虫丶:BAABKgAFFH8GAAMZAAYILQ/HIQAWAQAZAAUIYhHHIQAWAQAYAAEISQXLNwA8AAAAAA==.',['王多']='王多鱼儿:BAAAKgADCggICAAAAA==.',['王琦']='王琦蕊:BAAAKgAECgQIBAAAAA==.',['瑶池']='瑶池醉酒:BAAAKgAECgcIBwAAAA==.',['瓔珞']='瓔珞小涛:BAAAKgAECgMIBwAAAA==.',['生吃']='生吃榴莲壳:BAAAKgAECgEIAQAAAA==.',['电音']='电音猎兽:BAAAKgADCgcIBwAAAA==.',['疯狂']='疯狂老猫:BAAAKgAECgYIAQAAAA==.',['痞痞']='痞痞:BAAAKgADCgQIBAAAAA==.',['白色']='白色枫叶:BAAAKgAECggIBQAAAA==.',['看你']='看你双眼冒光:BAAAKgAECgMIAwAAAA==.',['真的']='真的扛不住:BAABKgAFFH8KAAMeAAYIzhRlBAD6AAAaAAYICRIMFwBCAQAeAAQItRxlBAD6AAAAAA==.',['神之']='神之苍月:BAAAKgAFFAQIBAAAAA==.',['神隐']='神隐藏的少女:BAAAKgAFFAMIBAAAAA==.',['福丶']='福丶:BAAAKgADCgIIAgAAAA==.',['突然']='突然灬你姐:BAABKgAFFH8JAAIIAAYIeAvWEwAUAQAIAAYIeAvWEwAUAQAAAA==.',['竹戏']='竹戏残梦:BAAAKgAECgQIBAAAAA==.',['第一']='第一丶坑神:BAAAKgAECggICwAAAA==.',['米拉']='米拉娜:BAACKgAFFH8XAAIEAAYIkxR+CwBXAQAEAAYIkxR+CwBXAQAqAAQKfxQAAgQACAgKE/ZLACABAAQACAgKE/ZLACABAAAA.',['糯香']='糯香柠檬茶:BAAAKgAECgEIAQABKgAFFAgIFAAfAL4NAA==.',['红方']='红方片:BAAAKgADCggIDAAAAA==.',['红豆']='红豆很忙:BAAAKgAECggICwAAAA==.',['纯真']='纯真男孩:BAAAKgAECggIDAAAAA==.',['继清']='继清桀如新生:BAAAKgAFFAIIAgAAAA==.',['美子']='美子:BAAAKgAECggIEwAAAA==.',['群星']='群星之伤:BAAAKgADCggICQAAAA==.',['老兔']='老兔子:BAAAKgAECgMIAwAAAA==.',['联盟']='联盟游侠:BAAAKgAECgQIBwAAAA==.',['脑浆']='脑浆炸裂少女:BAABKgAFFH8hAAMIAAgIqRwBAwAlAgAIAAcIPB0BAwAlAgASAAcIJRV5BACqAQAAAA==.',['自在']='自在极意喵:BAAAKgAECgUIBQAAAA==.自在极意难崩:BAAAKgAECgYIAgAAAA==.',['舞双']='舞双刀的老妖:BAAAKgAECgQIBAAAAA==.',['舞娅']='舞娅儿:BAACKgAFFH8aAAIIAAQIYRbhIQC+AAAIAAQIYRbhIQC+AAAqAAQKfxcAAwgACAh3EyE+AEEBAAgACAh3EyE+AEEBABIAAQgsB6qZACQAAAAA.',['艾仒']='艾仒米:BAABKgAFFH8IAAMKAAMI9A+NHQCTAAAKAAMI9A+NHQCTAAAfAAEIPggrJwAxAAAAAA==.',['艾诺']='艾诺辛斯:BAABKgAECn8lAAIaAAgIyBVoEwDKAQAaAAgIyBVoEwDKAQAAAA==.',['芙兰']='芙兰达:BAAAKgAFFAYIBAAAAA==.',['花之']='花之淡色:BAAAKgADCgYIBgAAAA==.',['花开']='花开的季节:BAAAKgADCgIIAgAAAA==.',['花落']='花落丿忆流年:BAAAKgAECgUICwAAAA==.',['苦集']='苦集滅道:BAAAKgAECgYICwAAAA==.苦集灭道:BAAAKgAECgYICgAAAA==.',['英姿']='英姿萨爽:BAABKgAFFH8IAAIDAAgIlwRFCwBJAQADAAgIlwRFCwBJAQAAAA==.',['茶小']='茶小涛:BAABKgAFFH8KAAIKAAQIgA3hIQCbAAAKAAQIgA3hIQCbAAABKgAFFAgIOQAYAJsQAA==.',['荼蘼']='荼蘼小涛:BAACKgAFFH8HAAQTAAMIOwgQIQCCAAATAAMIOwgQIQCCAAASAAIIPApJKwBpAAAIAAEISQxYKAA1AAAqAAQKfxwAAwgACAgXChxDACwBAAgACAjhCRxDACwBABIABAh9BkNmAJAAAAEqAAUUCAg5ABgAmxAA.',['莪彵']='莪彵朩倁檤:BAAAKgAECggIEwAAAA==.',['莽林']='莽林莽林:BAAAKgADCggICAAAAA==.',['萌奶']='萌奶:BAAAKgAECgcIBwAAAA==.',['萧瑟']='萧瑟幽情:BAAAKgADCgEIAQAAAA==.',['萨不']='萨不满:BAAAKgAFFAIIBAAAAA==.',['落樱']='落樱乄死神:BAABKgAFFH8IAAIOAAgIJBRTBwAdAgAOAAgIJBRTBwAdAgAAAA==.',['葬小']='葬小涛:BAAAKgAECgMIBgABKgAFFAgIOQAYAJsQAA==.',['蒼天']='蒼天:BAAAKgADCggICAAAAA==.',['蓝色']='蓝色妖媚:BAAAKgAFFAMIAwAAAA==.',['薩魯']='薩魯法尓:BAAAKgAECgMIAwAAAA==.',['蘸点']='蘸点甜妹酱:BAAAKgAFFAIIBAAAAA==.',['虚空']='虚空暴风:BAAAKgADCgcIBwAAAA==.',['蜀城']='蜀城飞将:BAAAKgAECgMIAwAAAA==.',['謎丶']='謎丶語:BAAAKgAECggICAAAAA==.',['讲丶']='讲丶者:BAAAKgAECggICwAAAA==.',['诗人']='诗人握持:BAABKgAFFH8RAAIOAAYI0himFwBgAQAOAAYI0himFwBgAQAAAA==.',['诡异']='诡异的雷:BAAAKgAECgQIBAAAAA==.',['诡道']='诡道边边:BAABKgAFFH8SAAMZAAgIJxuVCwDcAQAZAAcItRmVCwDcAQAYAAEIawS+NgBAAAAAAA==.',['诸神']='诸神:BAAAKgAECgcIDgAAAA==.',['谁云']='谁云之思:BAAAKgAECgYIBgAAAA==.',['赌毒']='赌毒不共戴天:BAAAKgAECggICAAAAA==.',['赤伶']='赤伶:BAAAKgADCgEIAwAAAA==.',['踏破']='踏破贺兰山:BAABKgAECn8UAAIFAAgIihU5NgDMAQAFAAgIihU5NgDMAQAAAA==.',['蹦迪']='蹦迪小满满:BAAAKgAECgMIAwAAAA==.',['轩仔']='轩仔如枫:BAAAKgAECggICQAAAA==.',['辰光']='辰光风影:BAAAKgAECgcIBwAAAA==.',['边竹']='边竹:BAABKgAFFH8GAAMFAAMI3wqhOAC2AAAFAAMI3wqhOAC2AAAEAAMI4gI3IwBaAAAAAA==.',['迈克']='迈克尔唐玄奘:BAAAKgAECgIIAgAAAA==.',['远上']='远上寒山石径:BAAAKgADCggIDQAAAA==.',['迪凯']='迪凯:BAAAKgADCgEIAQAAAA==.',['追风']='追风箭:BAAAKgAECggIDAAAAA==.',['邂逅']='邂逅烟寒:BAAAKgAFFAYIAgAAAA==.',['那一']='那一炮的温柔:BAAAKgAFFAEIAwAAAA==.',['醒醒']='醒醒丿:BAAAKgAECgYIBwAAAA==.',['鎷维']='鎷维滢嗰:BAAAKgADCggICAAAAA==.',['银笺']='银笺别梦:BAAAKgAECgcICQAAAA==.',['镇魂']='镇魂灬撇:BAAAKgAFFAIIAgAAAA==.',['镜华']='镜华:BAABKgAECn8qAAMMAAgIHiRcBQDLAgAMAAgItiNcBQDLAgANAAMIohubUgCgAAAAAA==.',['闪电']='闪电疯子:BAAAKgAECgYIDAAAAA==.',['阿历']='阿历克斯滚筒:BAAAKgADCggICAAAAA==.',['阿斯']='阿斯迪纳:BAAAKgADCgcIBwAAAA==.',['阿狸']='阿狸路亚:BAAAKgAECggICgAAAA==.',['陕西']='陕西谢霆锋:BAAAKgAECgEIAQAAAA==.',['隆德']='隆德希尔:BAAAKgADCgMIAwAAAA==.',['雨木']='雨木:BAAAKgAFFAYIBAAAAA==.',['雪落']='雪落忧伤:BAAAKgADCgYIBgAAAA==.',['雲霄']='雲霄:BAAAKgAECgYIBgAAAA==.',['霸道']='霸道的葡萄:BAAAKgADCggICAAAAA==.',['青鸟']='青鸟飝鱼:BAAAKgAECgQIBAAAAA==.',['非常']='非常高端娴熟:BAAAKgAECgYIAQAAAA==.',['頑皮']='頑皮西米露:BAABKgAECn8dAAMFAAcISw8thQAoAQAFAAcISw8thQAoAQAEAAEIAgPblwAaAAAAAA==.',['飞扬']='飞扬小柒:BAAAKgADCgIIAgAAAA==.',['马有']='马有钱灬:BAAAKgADCgYIBgAAAA==.',['驱散']='驱散你滴美:BAAAKgADCggICAAAAA==.',['高斯']='高斯狙击手:BAAAKgADCgIIAgAAAA==.',['魔惑']='魔惑:BAAAKgADCggICAAAAA==.',['鱼泪']='鱼泪满江:BAAAKgAECgcICAAAAA==.',['黑色']='黑色逆流:BAABKgAFFH8UAAQNAAQIHQzUEAC3AAANAAQIHQzUEAC3AAAMAAMIoQuaJgB1AAAPAAIIGQQWHgBTAAAAAA==.',['龍小']='龍小涛:BAABKgAFFH8HAAMQAAQItgn0JgChAAAQAAQItgn0JgChAAARAAMIQwFHCQBfAAABKgAFFAgIOQAYAJsQAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end