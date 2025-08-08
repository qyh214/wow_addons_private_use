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
 local lookup = {'Mage-Arcane','Mage-Frost','Mage-Fire','Rogue-Assassination','Rogue-Subtlety','Unknown-Unknown','Druid-Balance','Druid-Restoration','Warrior-Fury','Warlock-Destruction','Shaman-Elemental','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Devastation','Shaman-Restoration','Warlock-Affliction','Priest-Holy',}; local provider = {region='CN',realm='埃雷达尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aiout:BAAAKgAECgcIDAAAAA==.',Cr='Crucis:BAABKgAFFH8IAAIBAAgI4hDJBwAHAgABAAgI4hDJBwAHAgAAAA==.',He='Hera:BAAAKgAFFAQIBAABKgAFFAgIKAABABckAA==.',Lu='Luckyu:BAAAKgAECgUIBQAAAA==.',Pa='Pandoralol:BAAAKgADCgIIAgAAAA==.',Ph='Phantasos:BAABKgAFFH8JAAMCAAMIFg8NGAC1AAACAAMIFg8NGAC1AAADAAEIaAEhQgAtAAAAAA==.',Sk='Skirmisher:BAAAKgAECgYIBgAAAA==.',Sl='Slowdive:BAABKgAFFH8MAAMEAAgImxC/EQA2AQAEAAgI1w6/EQA2AQAFAAQI0wvMCADlAAAAAA==.',Vo='Voovvo:BAAAKgAECgQIBwAAAA==.',['不组']='不组奶僧僧:BAAAKgADCgUIBQAAAA==.',['东东']='东东龙:BAAAKgAFFAMIAwAAAA==.',['丰川']='丰川祥子:BAAAKgAECgUIDAABKgAFFAQIBAAGAAAAAA==.',['丶咸']='丶咸蛋丨超人:BAAAKgAECggIEQAAAA==.',['亦颉']='亦颉:BAAAKgADCgEIAQAAAA==.',['似慵']='似慵懒乖猫:BAABKgAFFH8MAAMHAAgIgxnpDwCjAQAHAAYItBvpDwCjAQAIAAII5BVsIwCZAAAAAA==.',['你来']='你来打我啊:BAAAKgAECgcIDgAAAA==.',['冲锋']='冲锋倒:BAABKgAFFH8QAAIJAAQIVAyCEwDqAAAJAAQIVAyCEwDqAAAAAA==.',['加尔']='加尔的长发:BAACKgAFFH8NAAIHAAMIIhktNQDHAAAHAAMIIhktNQDHAAAqAAQKfyYAAgcACAhiIt8eAFECAAcACAhiIt8eAFECAAAA.加尔福特:BAAAKgADCgMIAwAAAA==.',['十六']='十六夜咲夜:BAAAKgAFFAMIAwABKgAFFAQIBAAGAAAAAA==.',['叁城']='叁城味火锅:BAABKgAFFH8IAAMHAAgIURJkDQDBAQAHAAcIfxFkDQDBAQAIAAEIlgCTOQAzAAAAAA==.',['叁成']='叁成味火锅:BAAAKgAFFAQIBAAAAA==.',['又到']='又到芒种时:BAAAKgAECggICAABKgAFFAgIAwAGAAAAAA==.',['古德']='古德猫宁:BAAAKgADCgQIBAAAAA==.',['吹风']='吹风机:BAAAKgAECggIBwABKgAFFAgICgAKAI4cAA==.',['咏春']='咏春听桥:BAAAKgAECggICAAAAA==.',['圣园']='圣园未花:BAAAKgAECgYIBgABKgAFFAQIBAAGAAAAAA==.',['塞雷']='塞雷尼卡:BAAAKgAECgIIAgAAAA==.',['墜落']='墜落之羽:BAAAKgAFFAgIBAAAAA==.',['夏末']='夏末之殇:BAAAKgAFFAQIAgAAAA==.',['大吉']='大吉岭茶:BAACKgAFFH8bAAILAAQIdiZkBQALAQALAAQIdiZkBQALAQAqAAQKfyQAAgsACAgdJuUDAOYCAAsACAgdJuUDAOYCAAAA.',['天降']='天降斯巴达:BAAAKgAECgcIBwAAAA==.',['奔跑']='奔跑的小猪:BAABKgAECn8mAAMCAAgIYBUwEAB1AQACAAgIYBUwEAB1AQABAAEI5QlBSwArAAAAAA==.',['妹妹']='妹妹:BAAAKgAFFAQIBAAAAA==.',['寒羽']='寒羽良辰:BAAAKgAECgYIBgAAAA==.',['小小']='小小漾:BAABKgAECn8UAAIJAAgIoBrIGABFAgAJAAgIoBrIGABFAgAAAA==.小小煌:BAAAKgAECggICAAAAA==.小小羙:BAAAKgAFFAgIBAAAAA==.小小菜青虫:BAAAKgAECgIIAwAAAA==.小小鱡:BAAAKgAECgIIAgAAAA==.',['幸运']='幸运卜卜:BAABKgAFFH8IAAIMAAgIEBvpBQBiAgAMAAgIEBvpBQBiAgAAAA==.',['幽灵']='幽灵特使:BAAAKgAECgcIDAAAAA==.',['忏悔']='忏悔:BAABKgAFFH8KAAIBAAYIrw+vFAA/AQABAAYIrw+vFAA/AQAAAA==.',['恶魔']='恶魔终结者:BAAAKgAECgcIBwAAAA==.',['悲歌']='悲歌死士:BAAAKgAECgQIBQAAAA==.',['慕容']='慕容双双:BAAAKgADCgQIBAAAAA==.',['抓了']='抓了只大咕咕:BAABKgAFFH8GAAMNAAIIaQawPQB1AAANAAIIJwWwPQB1AAAOAAIIxQLXKwA2AAAAAA==.',['施主']='施主吃我一拳:BAAAKgAECgEIAQAAAA==.',['无间']='无间的杀戮:BAAAKgAECgQIBAAAAA==.',['时光']='时光之息:BAABKgAFFH8SAAIPAAgIMxwsBABfAgAPAAgIMxwsBABfAgAAAA==.',['时迁']='时迁:BAAAKgAECgMIAwAAAA==.',['星辰']='星辰的光辉:BAABKgAFFH8IAAIMAAgIiBN1DQD6AQAMAAgIiBN1DQD6AQAAAA==.',['星野']='星野诗羽:BAAAKgAECgUIBQAAAA==.',['暗月']='暗月风华:BAAAKgAECgMIAwAAAA==.',['暮雪']='暮雪霜狼:BAAAKgAECgIIAgAAAA==.',['暴走']='暴走丷豆子:BAAAKgAFFAQIBAAAAA==.',['最后']='最后一葉:BAAAKgAFFAQIBAAAAA==.',['月夜']='月夜魔神舒然:BAAAKgAECgMIAwAAAA==.',['月葵']='月葵:BAAAKgAFFAEIAQAAAA==.',['東東']='東東龍:BAABKgAFFH8KAAIQAAYIVh7TCQCoAQAQAAYIVh7TCQCoAQAAAA==.',['楚昭']='楚昭儿:BAAAKgAECggICAAAAA==.',['歸途']='歸途過愘:BAACKgAFFH8YAAIMAAQIoRRMTQDUAAAMAAQIoRRMTQDUAAAqAAQKfzgAAgwACAj0HVcvAEICAAwACAj0HVcvAEICAAAA.',['水晶']='水晶秀秀:BAAAKgAECgIIAgAAAA==.',['氵卖']='氵卖衤申柒:BAAAKgAECgcICAAAAA==.',['洋卜']='洋卜卜:BAAAKgAECggIBgAAAA==.',['洗脚']='洗脚兽:BAAAKgAECgMIAwAAAA==.',['浩然']='浩然正气:BAAAKgAECgMIAwAAAA==.',['浪火']='浪火夺:BAACKgAFFH8JAAIRAAQICA51BwDFAAARAAQICA51BwDFAAAqAAQKfxoAAhEACAjfFl4MAKkBABEACAjfFl4MAKkBAAAA.',['海之']='海之灵:BAAAKgADCggICAAAAA==.',['涅磬']='涅磬苍穹:BAAAKgAECgIIAgAAAA==.',['温蕾']='温蕾萨:BAABKgAFFH8JAAIOAAYIKR2aCQC+AQAOAAYIKR2aCQC+AQAAAA==.',['炒肉']='炒肉先上浆:BAAAKgADCgMIAwAAAA==.',['痉挛']='痉挛重鸡手:BAABKgAFFH8GAAIMAAYI+gW2LwApAQAMAAYI+gW2LwApAQAAAA==.',['盒子']='盒子萨:BAAAKgAECgMIAwAAAA==.',['硬扎']='硬扎:BAAAKgAECgMIAwAAAA==.',['秀雪']='秀雪嫣:BAAAKgADCggICAAAAA==.',['米定']='米定论:BAAAKgAFFAIIAgAAAA==.',['米浴']='米浴:BAAAKgAECgEIAQABKgAFFAQIBAAGAAAAAA==.',['终极']='终极肉盾:BAAAKgADCgMIAgAAAA==.',['缥缈']='缥缈:BAAAKgAECgYIBgAAAA==.',['芒种']='芒种小小:BAACKgAFFH8KAAMNAAYIthQ+GAA5AQANAAYILBI+GAA5AQAOAAQIvBD/MwCiAAAqAAQKfxYAAg0ACAjvHoIlAF4CAA0ACAjvHoIlAF4CAAAA.',['花钱']='花钱悦下:BAAAKgADCgEIAQAAAA==.',['莲影']='莲影:BAAAKgAFFAEIAQAAAA==.',['虞姬']='虞姬丶:BAAAKgAECgIIAgAAAA==.',['蝈蝈']='蝈蝈骑士:BAAAKgADCgEIAQAAAA==.',['血色']='血色启示:BAAAKgADCggICAAAAA==.',['贾樱']='贾樱樱:BAABKgAFFH8GAAISAAYI7wPSEADDAAASAAYI7wPSEADDAAAAAA==.',['路上']='路上的盒子:BAABKgAECn8hAAICAAgIMyWuDQCVAgACAAgIMyWuDQCVAgAAAA==.',['车厘']='车厘小丸子:BAAAKgAECgQIBAAAAA==.',['这波']='这波没我:BAAAKgAECgYIBgAAAA==.',['铸之']='铸之魂:BAABKgAECn8eAAQBAAgI8yESGwAYAgABAAcIFx8SGwAYAgACAAgIfh+MIgD9AQADAAII6QZASwAsAAAAAA==.',['阿呆']='阿呆:BAAAKgAECgYIBgAAAA==.',['陌上']='陌上初寒:BAAAKgAECggICAAAAA==.',['雨之']='雨之昊天:BAACKgAFFH8bAAIMAAQIYA/yVADHAAAMAAQIYA/yVADHAAAqAAQKf0MAAgwACAg7GqkdANABAAwACAg7GqkdANABAAAA.',['雾蒽']='雾蒽:BAAAKgAECggICQAAAA==.',['风之']='风之力:BAAAKgAFFAIIAgAAAA==.',['魔蝎']='魔蝎座:BAACKgAFFH8VAAMNAAQIjCNpHQAaAQANAAQIjCNpHQAaAQAOAAEIfxZtJgBEAAAqAAQKfxUAAw0ACAi6ISM8AAcCAA0ACAhtISM8AAcCAA4ABAhgGqtQAA4BAAAA.',['龙之']='龙之火:BAAAKgADCgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end