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
 local lookup = {'Evoker-Devastation','Evoker-Preservation','Warlock-Destruction','Warlock-Affliction','Mage-Fire','DeathKnight-Unholy','Druid-Restoration','Evoker-Augmentation','Druid-Balance','Druid-Guardian','Priest-Holy','Warrior-Protection','Paladin-Protection','Mage-Frost','Mage-Arcane','Hunter-Marksmanship','DemonHunter-Havoc','Paladin-Retribution','Paladin-Holy','Monk-Mistweaver','Rogue-Assassination','Priest-Discipline','Warrior-Arms','Warrior-Fury','Unknown-Unknown','Monk-Windwalker','Warlock-Demonology','DeathKnight-Frost','Shaman-Restoration','Hunter-BeastMastery','Rogue-Outlaw','DeathKnight-Blood',}; local provider = {region='CN',realm='逐日者',name='CN',type='weekly',zone=42,date='2025-08-03',data={Al='Alfred:BAAAKgAECgIIAgAAAA==.',Be='Bearchief:BAAAKgAECgQIBAAAAA==.',Br='Brick:BAACKgAFFH8GAAIBAAYI4iLRAAAJAgABAAYI4iLRAAAJAgAqAAQKfycAAwEACAh+JC8DAOcCAAEACAh+JC8DAOcCAAIAAwjgHKUUAAwBAAAA.',Do='Doge:BAAAKgADCggICQAAAA==.',Dr='Drakeedog:BAABKgAFFH8OAAMDAAgIzh0VAwBoAgADAAgIzh0VAwBoAgAEAAIIOBqAEwCNAAAAAA==.',Dy='Dyyoo:BAAAKgADCgEIAQAAAA==.',Em='Emmy:BAABKgAFFH8IAAIFAAQI4xf2FgDyAAAFAAQI4xf2FgDyAAAAAA==.Emo:BAAAKgADCggICAAAAA==.',Ev='Evilddkdming:BAABKgAFFH8JAAIGAAQIbR16DAAKAQAGAAQIbR16DAAKAQAAAA==.',Ki='Kirby:BAAAKgAFFAIIBAAAAA==.',Lo='Loved:BAACKgAFFH8FAAMBAAUIFg3AFwCRAAABAAQIURHAFwCRAAACAAEI7QfBCwA3AAAqAAQKfyIAAwEACAg/JUkDAOYCAAEACAg/JUkDAOYCAAIABwixIc0BADoCAAEqAAUUCAgGAAEA4iIA.',Ls='Lsww:BAAAKgAECgQIBAAAAA==.',Ma='Manastorm:BAAAKgAECgUIBQAAAA==.Manchester:BAAAKgADCgEIAQAAAA==.',Na='Natsumi:BAAAKgAECggICAAAAA==.',Od='Odruido:BAABKgAFFH8GAAIHAAYIsAYgFgDwAAAHAAYIsAYgFgDwAAAAAA==.',On='Onion:BAACKgAFFH8GAAMBAAYItxJoBQBFAQABAAUITBdoBQBFAQACAAEIIQ8GCwA9AAAqAAQKfyYABAIACAiQIncBALMCAAIACAiQIncBALMCAAEACAhUI1ocANABAAgAAgjRIjoLALEAAAEqAAUUCAgGAAEA4iIA.',Ph='Phi:BAAAKgAECgQIBAAAAA==.Phil:BAACKgAFFH8NAAMJAAMIrCOVCAAqAQAJAAMIrCOVCAAqAQAHAAMIVAvyJQCOAAAqAAQKfyEAAwkACAgFJWAMAMACAAkACAgFJWAMAMACAAoABAiSFZ8gAOMAAAAA.',Pp='Pphil:BAAAKgAECgEIAQAAAA==.',Sa='Samentha:BAAAKgAFFAMIAwAAAA==.',Sh='Shieva:BAABKgAFFH8FAAILAAUI6gRHHADcAAALAAUI6gRHHADcAAAAAA==.',Si='Silhouette:BAABKgAFFH8FAAIMAAUIng7+CADVAAAMAAUIng7+CADVAAAAAA==.',So='Sophia:BAAAKgAECgEIAQAAAA==.',Th='Themisia:BAABKgAFFH8GAAINAAYIPgPxGgCiAAANAAYIPgPxGgCiAAAAAA==.',Vo='Voidstoria:BAAAKgAECgMIAwAAAA==.',Xi='Xingyuganlin:BAABKgAECn8kAAQOAAgICCKkCwCBAgAOAAgIhyGkCwCBAgAPAAcIHRgkMgCIAQAFAAYIdh7+TQBGAQAAAA==.',Ze='Zerting:BAAAKgAFFAgIBQAAAA==.',['一尺']='一尺天涯:BAAAKgADCggICAAAAA==.',['一雫']='一雫:BAAAKgADCgMIAwAAAA==.',['三六']='三六零:BAAAKgAECgQIBAAAAA==.',['上头']='上头猫:BAABKgAFFH8GAAIMAAMI+QGoFABVAAAMAAMI+QGoFABVAAAAAA==.',['不高']='不高兴先生:BAAAKgADCgYICgAAAA==.',['丨霸']='丨霸灬霸丨:BAAAKgAFFAIIAgAAAA==.',['乄晨']='乄晨乄曦乄:BAABKgAFFH8KAAIQAAgIeh59AwBhAgAQAAgIeh59AwBhAgAAAA==.',['九翼']='九翼黑君:BAAAKgADCgcICAAAAA==.',['二粒']='二粒蛋:BAAAKgAECgYIBwAAAA==.',['云之']='云之呢喃:BAAAKgAFFAQIBAAAAA==.',['人形']='人形高达:BAAAKgADCggIEAAAAA==.',['人红']='人红手黑:BAABKgAFFH8MAAIRAAQIkwfNHQDLAAARAAQIkwfNHQDLAAAAAA==.',['今汐']='今汐:BAAAKgAECgEIAQAAAA==.',['佳熙']='佳熙:BAACKgAFFH8KAAMNAAgIvhO2BQCZAQANAAgIoRC2BQCZAQASAAIIchcmZQCkAAAqAAQKfxQAAxIACAiBH1skAG8CABIACAiBH1skAG8CABMAAwihGf0SAOAAAAAA.',['信仰']='信仰的传说:BAAAKgADCgYIBgAAAA==.',['修一']='修一闲:BAAAKgAECgYIBgAAAA==.',['光羽']='光羽闪耀:BAAAKgAECgIIAgAAAA==.',['六合']='六合散人:BAAAKgAECgMIBAAAAA==.',['六月']='六月的小耳朵:BAAAKgAECgQIBAAAAA==.六月的骑耳朵:BAAAKgAECgUIBQAAAA==.',['冈特']='冈特:BAAAKgAECgYIBgAAAA==.',['冰之']='冰之精灵:BAAAKgAECgcICQAAAA==.',['冰点']='冰点水:BAAAKgADCgUIBQAAAA==.',['北京']='北京二零零八:BAAAKgAECgcICQAAAA==.',['北城']='北城别西城诀:BAABKgAFFH8PAAIUAAMImxdTHQC1AAAUAAMImxdTHQC1AAAAAA==.',['卑徒']='卑徒:BAAAKgAECgcIEwAAAA==.',['南宫']='南宫紫羽:BAAAKgAECgIIAgAAAA==.',['占戈']='占戈:BAAAKgADCggIDQAAAA==.',['原吉']='原吉的塬:BAAAKgAECggICQAAAA==.',['听愺']='听愺帽在唱歌:BAAAKgADCgEIAgAAAA==.',['吹落']='吹落樱花:BAAAKgAECgMIBAAAAA==.',['周老']='周老师:BAAAKgAECgIIAgAAAA==.',['和泉']='和泉妃爱丶:BAAAKgAFFAQIBAAAAA==.',['哆冻']='哆冻证:BAAAKgADCggICAAAAA==.',['四阿']='四阿哥:BAAAKgAECgUIBQAAAA==.',['圣光']='圣光女神:BAAAKgADCgMIAwAAAA==.圣光照耀黑暗:BAABKgAFFH8KAAINAAIIcgYKFgBPAAANAAIIcgYKFgBPAAAAAA==.',['士骑']='士骑亡死:BAABKgAFFH8IAAIGAAgINw3gCQDuAQAGAAgINw3gCQDuAQAAAA==.',['大梦']='大梦一场丶:BAAAKgADCggICwAAAA==.',['大猫']='大猫小猫:BAAAKgAFFAEIAQAAAA==.',['大荒']='大荒囚天:BAAAKgADCggICAAAAA==.',['天嗱']='天嗱你真矮丶:BAABKgAECn8uAAIRAAgIUSEsEACDAgARAAgIUSEsEACDAgAAAA==.',['天堂']='天堂灬心:BAAAKgADCggIDgAAAA==.',['天天']='天天快乐:BAAAKgAECgEIAQAAAA==.',['天谴']='天谴之雷霆:BAAAKgAECgEIAQAAAA==.',['夹夹']='夹夹两个栗子:BAAAKgAFFAYIBAAAAA==.',['好梦']='好梦:BAAAKgAECggIDwAAAA==.',['娜罗']='娜罗无双华:BAAAKgAFFAMIAwAAAA==.',['婳朵']='婳朵朵:BAAAKgAECgYIBwAAAA==.',['孤剑']='孤剑逍遥游:BAAAKgADCgQIBAAAAA==.',['孤城']='孤城乱舞:BAAAKgAECgYICwAAAA==.',['家有']='家有肥妞:BAAAKgAECgcICgAAAA==.',['小小']='小小书童:BAAAKgAECgUICAAAAA==.',['小工']='小工:BAABKgAFFH8IAAISAAQI3B4oDwAXAQASAAQI3B4oDwAXAQAAAA==.',['小李']='小李飞刀:BAAAKgAECgYIDQAAAA==.',['小流']='小流氓丶:BAAAKgAECgMIAwAAAA==.',['小缇']='小缇娜:BAAAKgAECggICAAAAA==.',['小西']='小西柚:BAAAKgAFFAgIAQAAAA==.',['小豆']='小豆包:BAAAKgAFFAQIBAAAAA==.',['小雨']='小雨小雨儿:BAAAKgADCggICQAAAA==.',['小龙']='小龙人它爷爷:BAAAKgADCggICAAAAA==.',['崩山']='崩山裂地:BAAAKgADCggICwAAAA==.',['川贝']='川贝枇杷膏:BAAAKgAECggICAAAAA==.',['帅爆']='帅爆的大鲸鱼:BAAAKgAECgQICAAAAA==.',['幻梦']='幻梦猛禽:BAAAKgADCgEIAQAAAA==.',['张益']='张益达:BAAAKgAECgYIBwAAAA==.张益达丶丶:BAAAKgAECgEIAQAAAA==.',['強殖']='強殖裝甲:BAAAKgADCgMIAwAAAA==.',['徐龙']='徐龙象:BAABKgAECn8ZAAIUAAcI9hb5IgB1AQAUAAcI9hb5IgB1AQAAAA==.',['心属']='心属壹芳:BAAAKgADCgIIAgAAAA==.',['心沉']='心沉梦境:BAAAKgAECgIIAgAAAA==.',['快龙']='快龙:BAAAKgAFFAQIBAAAAA==.',['思维']='思维放纵:BAAAKgADCggICAAAAA==.',['怪盗']='怪盗基德:BAABKgAFFH8GAAIVAAYIfhkPCgCvAQAVAAYIfhkPCgCvAQAAAA==.',['惡靈']='惡靈退散:BAAAKgADCggICAAAAA==.',['懒洋']='懒洋洋:BAAAKgAECggICAAAAA==.',['我头']='我头上有只角:BAABKgAFFH8FAAIWAAMI8xSVHACyAAAWAAMI8xSVHACyAAAAAA==.',['我要']='我要振刀了:BAABKgAFFH8IAAISAAMI1RB8TgDSAAASAAMI1RB8TgDSAAAAAA==.',['我身']='我身后有尾巴:BAABKgAFFH8FAAMHAAMIsgRKKgB5AAAHAAMIsgRKKgB5AAAKAAIIhQGbDgAzAAAAAA==.',['拉托']='拉托妮:BAAAKgADCggICAAAAA==.',['拉格']='拉格娜罗斯:BAABKgAECn8WAAIDAAgIHxTvNACbAQADAAgIHxTvNACbAQAAAA==.',['撒娇']='撒娇五花肉:BAAAKgAECggICgAAAA==.',['放火']='放火的:BAABKgAFFH8QAAIVAAgIsQfxBQDqAQAVAAgIsQfxBQDqAQAAAA==.',['斧头']='斧头帮弓箭手:BAAAKgADCggICQAAAA==.',['无中']='无中灬生有:BAAAKgAECgEIAQAAAA==.',['无心']='无心回忆:BAABKgAFFH8IAAMTAAQIfhsyBAAGAQATAAQIfhsyBAAGAQASAAII9QmkRwBtAAAAAA==.',['星丶']='星丶玥:BAABKgAFFH8JAAMXAAYIvw0MAgCfAQAXAAYITAwMAgCfAQAYAAMI9AzOFgDPAAAAAA==.',['星烁']='星烁:BAABKgAFFH8FAAILAAMI1QXSMACDAAALAAMI1QXSMACDAAAAAA==.',['星瞳']='星瞳:BAAAKgAECggICAAAAA==.',['晓山']='晓山瑞希:BAAAKgAECgcIBwABKgAFFAUIAgAZAAAAAA==.',['晓风']='晓风寒月:BAAAKgAECgEIAQAAAA==.',['晨昏']='晨昏蒙影:BAAAKgAECgIIAgAAAA==.',['曦之']='曦之:BAAAKgAECgQIBAAAAA==.曦之魅惑:BAAAKgADCgQIBAAAAA==.',['最强']='最强悍丨盾:BAAAKgAECgYICwAAAA==.',['朝天']='朝天棍:BAACKgAFFH8KAAMaAAIIWA0KHgB6AAAaAAIIWA0KHgB6AAAUAAII3QZxLwBYAAAqAAQKfysAAxoACAjBGHIHABICABoACAjBGHIHABICABQACAgzFAU7AFgBAAAA.',['未名']='未名二:BAAAKgAECgQIBAAAAA==.',['术术']='术术口:BAACKgAFFH8NAAIDAAMIig9+LQC3AAADAAMIig9+LQC3AAAqAAQKfyEAAwMACAgdHm8IABcCAAMACAj1HW8IABcCABsABAhkER9GANoAAAAA.',['来碗']='来碗红烧肉:BAAAKgADCgUIBQAAAA==.',['林薇']='林薇可:BAABKgAFFH8HAAIDAAYIWwx9GgAxAQADAAYIWwx9GgAxAQAAAA==.',['梨落']='梨落记忆:BAAAKgAECgIIAgAAAA==.',['森林']='森林狼:BAAAKgAECgEIAQAAAA==.',['椿鬼']='椿鬼:BAABKgAFFH8GAAIQAAYI2BQkCgC0AQAQAAYI2BQkCgC0AQAAAA==.',['榴莲']='榴莲派:BAABKgAFFH8IAAMIAAUIqwlkAgCTAAAIAAUILQlkAgCTAAABAAEI8wi9IAA2AAAAAA==.',['橘晶']='橘晶:BAAAKgADCggICAAAAA==.',['毒千']='毒千本:BAAAKgADCggICAAAAA==.',['永巷']='永巷丶:BAAAKgAECgMIBQAAAA==.',['永远']='永远沉睡吧:BAAAKgAECgMIAwAAAA==.',['没事']='没事吃西瓜:BAACKgAFFH8SAAMOAAQIfSJCDQD8AAAOAAMIlCFCDQD8AAAPAAIIKR7FQQBNAAAqAAQKfxwAAg4ACAjfIZINAJYCAA4ACAjfIZINAJYCAAAA.',['泉丶']='泉丶此方:BAACKgAFFH8MAAMPAAMIJxBoOQB8AAAPAAIIwxBoOQB8AAAFAAII+ArBMwB7AAAqAAQKfy4AAwUACAhWGyIhAC0CAAUACAiJGiIhAC0CAA8ABAiFFRhOAAUBAAAA.',['法号']='法号释怀:BAABKgAFFH8GAAIcAAYIeREwBABTAQAcAAYIeREwBABTAQAAAA==.',['波尔']='波尔塞福涅:BAAAKgAECgMIBQAAAA==.',['洪荒']='洪荒之力:BAAAKgADCggICAAAAA==.',['浦浦']='浦浦小飞侠:BAABKgAFFH8GAAIdAAYIww6iEwA5AQAdAAYIww6iEwA5AQAAAA==.',['海亚']='海亚:BAAAKgADCgYIBgAAAA==.',['海棠']='海棠丶未雨:BAAAKgADCggICAAAAA==.',['深蓝']='深蓝:BAAAKgADCgQIBQAAAA==.',['清晓']='清晓话梅:BAAAKgADCggICAAAAA==.',['灼眼']='灼眼的夏丶娜:BAABKgAFFH8FAAILAAQI4g/BKQCbAAALAAQI4g/BKQCbAAAAAA==.',['点点']='点点都似哎:BAAAKgAFFAgIBAAAAA==.点点都似唉:BAAAKgAFFAQIBAAAAA==.',['煾赐']='煾赐解脱:BAAAKgAECgcIBwAAAA==.',['熊萌']='熊萌儿:BAAAKgAFFAgIBAAAAA==.',['牛志']='牛志达:BAACKgAFFH8OAAISAAQIySFZOgADAQASAAQIySFZOgADAQAqAAQKfxwAAhIACAhaJJMbAKoCABIACAhaJJMbAKoCAAEqAAUUCAgIAB4AnQcA.',['狐狸']='狐狸侠:BAAAKgAECgYIBgAAAA==.',['猎心']='猎心:BAAAKgADCgMIBwAAAA==.',['猎风']='猎风之神:BAAAKgAFFAgIBAAAAA==.',['王仙']='王仙芝:BAABKgAECn8bAAMSAAgI3xChsAA2AQASAAgI3xChsAA2AQANAAYIZg0SMQDZAAAAAA==.',['琅博']='琅博旺:BAAAKgADCgQIBAAAAA==.',['璐娜']='璐娜:BAABKgAFFH8GAAIDAAYIlgtBHQAdAQADAAYIlgtBHQAdAQAAAA==.',['生如']='生如洋葱:BAABKgAECn8tAAMCAAgIWh//AwBwAgACAAgIWh//AwBwAgABAAgIYCGgDwBRAgABKgAFFAgIBgABAOIiAA==.',['瘸腿']='瘸腿大王:BAAAKgAECgUIBQAAAA==.',['睫毛']='睫毛弯弯:BAAAKgADCggICAAAAA==.',['知更']='知更鸟:BAABKgAFFH8HAAMEAAUIcxjBBQD+AAAEAAQIrx/BBQD+AAADAAMIQg7mFQDMAAAAAA==.',['破梦']='破梦:BAAAKgAECgYIBQAAAA==.',['神之']='神之长子:BAAAKgAECgQIBAAAAA==.',['神佑']='神佑骑士:BAAAKgAECgIIAgAAAA==.',['离人']='离人公子:BAAAKgAECgYIBgAAAA==.',['秘法']='秘法之星:BAABKgAECn8oAAQFAAgIVx6lKQAAAgAFAAgI7xelKQAAAgAOAAcI3xsHSwA5AQAPAAQIcxs2FgD4AAAAAA==.',['筱小']='筱小辉:BAAAKgAECggICAAAAA==.',['米线']='米线饵丝:BAACKgAFFH8OAAIGAAQILgoyFwCsAAAGAAQILgoyFwCsAAAqAAQKfzMAAwYACAg6HIcHACsCAAYACAhSGocHACsCABwAAwi3G50UAPYAAAAA.',['米迦']='米迦埃莉丝:BAABKgAECn8hAAIRAAcItRy3IwDqAQARAAcItRy3IwDqAQAAAA==.',['素商']='素商:BAABKgAECn8kAAMDAAgIshbwDwCeAQADAAgIshbwDwCeAQAbAAMITA0aIACXAAAAAA==.',['绯弹']='绯弹的亚里亚:BAAAKgAECgEIAQAAAA==.',['绿色']='绿色保护着你:BAAAKgAECgUIBgAAAA==.绿色小图腾:BAAAKgAECgIIAgAAAA==.',['缓慢']='缓慢且弱志:BAAAKgAECgcIBwAAAA==.',['群星']='群星间的低语:BAACKgAFFH8iAAISAAgI5iHyBgBZAgASAAgI5iHyBgBZAgAqAAQKfykAAhIACAg4IAQsAG8CABIACAg4IAQsAG8CAAAA.',['耐磨']='耐磨陀螺丸:BAAAKgAECggIDQAAAA==.',['肉山']='肉山大魔王:BAAAKgAECgYIBgAAAA==.',['自律']='自律的奶萨:BAAAKgADCggICAAAAA==.',['自深']='自深渊的暗影:BAAAKgADCgcIEwABKgAECggIJAAOAAgiAA==.',['自走']='自走虎:BAAAKgADCgEIAQAAAA==.',['若尘']='若尘:BAAAKgADCgcIDQAAAA==.',['荆棘']='荆棘十字:BAAAKgAECggICAAAAA==.',['落日']='落日之魅影:BAAAKgAECgUICQAAAA==.',['葡萄']='葡萄派:BAACKgAFFH8iAAMJAAYImxzgDwCjAQAJAAYImxzgDwCjAQAHAAEIXRDXIABBAAAqAAQKfzYABAkACAgxJdQFAO4CAAkACAgxJdQFAO4CAAoABAjrFoEPAMUAAAcABAiXEJpeAG8AAAAA.',['蛐蛐']='蛐蛐女仕:BAABKgAFFH8GAAIOAAYIThkuBQCMAQAOAAYIThkuBQCMAQAAAA==.蛐蛐魅影:BAABKgAFFH8HAAMEAAQIexcwFQCTAAADAAMI6B+bMQCoAAAEAAQIigUwFQCTAAAAAA==.',['血为']='血为命源:BAAAKgAECggICAAAAA==.',['血月']='血月丨:BAAAKgAECgYIBgAAAA==.',['谁要']='谁要男妈妈:BAAAKgAECgQIBAAAAA==.',['谷德']='谷德夯特:BAABKgAFFH8OAAMeAAgIyhzPAwB+AgAeAAgIVBzPAwB+AgAQAAYIPxURFQA7AQAAAA==.',['贫僧']='贫僧法号空虚:BAAAKgAECgQIBAAAAA==.',['赦影']='赦影尸丶:BAABKgAFFH8IAAMfAAgI4wrOAgDNAAAVAAQIOQyvEQA3AQAfAAQIGgnOAgDNAAAAAA==.',['赫潘']='赫潘丝:BAAAKgADCgIIAgAAAA==.',['超级']='超级升龙霸:BAAAKgAECgcIBwAAAA==.',['農婦']='農婦三拳:BAAAKgAFFAEIAQAAAA==.',['逆光']='逆光织影:BAAAKgADCgYIBgAAAA==.',['邪恶']='邪恶猫猫头:BAAAKgAECggICAAAAA==.',['镇元']='镇元斋:BAAAKgAECggICAAAAA==.',['闹不']='闹不机密:BAAAKgADCggICAAAAA==.',['阿兹']='阿兹特克酋长:BAACKgAFFH8GAAIeAAQIuAjUSwB4AAAeAAQIuAjUSwB4AAAqAAQKfyYAAh4ACAhUGZYuAPEBAB4ACAhUGZYuAPEBAAAA.',['阿巴']='阿巴阿巴:BAAAKgADCgcIBwAAAA==.',['陈墨']='陈墨瞳:BAABKgAFFH8OAAMgAAYIvRXuEwACAQAgAAYIAQ/uEwACAQAGAAQIGBkfKADtAAAAAA==.',['陈老']='陈老师:BAACKgAFFH8UAAIdAAQIsB5BEgDbAAAdAAQIsB5BEgDbAAAqAAQKfxcAAh0ACAhbCkBZADMBAB0ACAhbCkBZADMBAAAA.',['隔壁']='隔壁老王:BAAAKgAECgUIBgAAAA==.',['集团']='集团总裁:BAABKgAFFH8MAAIUAAMIQgCVNAAuAAAUAAMIQgCVNAAuAAAAAA==.',['雪术']='雪术:BAAAKgADCggIDwAAAA==.',['雪菲']='雪菲児:BAAAKgAECggICAAAAA==.',['雷塞']='雷塞克啦:BAAAKgADCgIIAgAAAA==.',['霹雳']='霹雳牛人:BAAAKgAECgEIAQAAAA==.',['青衫']='青衫隐:BAAAKgADCggICAAAAA==.',['须臾']='须臾涧:BAAAKgAFFAgIBAAAAA==.',['风之']='风之彩:BAABKgAECn8dAAIUAAcIxhqcJQDKAQAUAAcIxhqcJQDKAQAAAA==.',['香芋']='香芋派:BAAAKgAFFAEIAQAAAA==.',['马三']='马三娘:BAAAKgAFFAEIAQAAAA==.',['魔法']='魔法批风:BAABKgAFFH8LAAIPAAUIpQcHFgDJAAAPAAUIpQcHFgDJAAAAAA==.',['魔都']='魔都小妖:BAABKgAFFH8GAAIJAAYIGwgyEwAqAQAJAAYIGwgyEwAqAQAAAA==.',['黎明']='黎明风暴:BAABKgAFFH8RAAIdAAQIJBUEFwDJAAAdAAQIJBUEFwDJAAAAAA==.',['黑之']='黑之契约者:BAAAKgAECgYIBAAAAA==.',['黑叶']='黑叶:BAABKgAECn8lAAMHAAgI7BztEQA3AgAHAAgI7BztEQA3AgAJAAgIORmTNQDjAQAAAA==.',['龍舌']='龍舌蘭寶寶:BAACKgAFFH8IAAIBAAYIygYCEAAOAQABAAYIygYCEAAOAQAqAAQKfxwAAwEABwhwCCE6APQAAAEABwhwCCE6APQAAAgAAQhDAWkKAA8AAAAA.',['龙牧']='龙牧壮骨:BAABKgAFFH8FAAIWAAUInSG4CwBZAQAWAAUInSG4CwBZAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end