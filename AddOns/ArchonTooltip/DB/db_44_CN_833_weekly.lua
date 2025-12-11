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
 local lookup = {'Paladin-Retribution','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','DeathKnight-Frost','Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','Priest-Shadow','DeathKnight-Blood','Rogue-Subtlety','Rogue-Assassination','Mage-Frost','Mage-Arcane','Warrior-Fury','Shaman-Restoration','Shaman-Elemental','Druid-Restoration','Monk-Mistweaver','Monk-Windwalker','Warlock-Destruction','Shaman-Enhancement','Warrior-Protection','Paladin-Protection','DeathKnight-Unholy','Paladin-Holy','Priest-Holy','Warlock-Demonology','Druid-Balance','Hunter-Survival','Warlock-Affliction','Monk-Brewmaster','Rogue-Outlaw','Unknown-Unknown','Druid-Feral',}; local provider = {region='CN',realm='踏梦者',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aa='Aabbdk:BAAALAAFFAYIAQAAAA==.',Ar='Aresgalaxy:BAAALAAFFAIIAgAAAA==.Aruun:BAABLAAFFH8GAAIBAAYInQhDNwDJAAABAAYInQhDNwDJAAAAAA==.',Be='Beforeafter:BAABLAAECn8YAAMCAAgIxB7VEACvAgACAAgIxB7VEACvAgADAAgISRgRDwA/AgABLAAFFAgIQAACAMEdAA==.',Bi='Bittergourd:BAABLAAECn8WAAMDAAgIVh3BCACmAgADAAgIVh3BCACmAgACAAgI0hprGABeAgABLAAFFAgIQAACAMEdAA==.',Bl='Blackwarlock:BAAALAAECgYIBwAAAA==.Blessing:BAABLAAECn8hAAQCAAgIUiBiEACzAgACAAgIHCBiEACzAgADAAcI8h8fHgB/AQAEAAIIiCDHFwCFAAABLAAFFAgIQAACAMEdAA==.',Ca='Cartethyia:BAAALAAECgEIAQAAAA==.',Ck='Ckk:BAACLAAFFH8NAAIFAAMI/grFMgDRAAAFAAMI/grFMgDRAAAsAAQKfyEAAgUACAiqIAMQAG0CAAUACAiqIAMQAG0CAAAA.',Cl='Cliffburton:BAAALAAECggICAAAAA==.',Da='Dark:BAACLAAFFH8FAAIGAAUIXwZZDwCCAAAGAAUIXwZZDwCCAAAsAAQKfyIAAwYACAi7Fh0zAPUBAAYACAiBFR0zAPUBAAcABwj6FP5aAI0BAAAA.',Dh='Dhqaq:BAABLAAFFH8GAAIIAAYIOBpSFADCAQAIAAYIOBpSFADCAQAAAA==.',Di='Dih:BAAALAAECgIIAgAAAA==.',Dr='Dru:BAAALAAECgYIBgAAAA==.',Ec='Ecw:BAABLAAFFH8PAAIFAAgIbCApBQCuAgAFAAgIbCApBQCuAgAAAA==.',Fr='Frostmaster:BAABLAAFFH8VAAIJAAgIXh+KAQDFAgAJAAgIXh+KAQDFAgAAAA==.',Fu='Fusro:BAAALAAECgUIBQAAAA==.',Ha='Hatsunemiku:BAAALAAECgYIDwAAAA==.',Hi='Hillmanq:BAAALAADCggICAAAAA==.',Hu='Hua:BAAALAAECgEIAQAAAA==.',Hy='Hydedk:BAAALAAECggICAAAAA==.',Ja='Jackie:BAAALAAECgUIBQAAAA==.Jaina:BAABLAAFFH8eAAMFAAgIdyO3AgDeAgAFAAgIdyO3AgDeAgAKAAEIqQOaHgAnAAAAAA==.',Ka='Kalimaste:BAABLAAFFH8MAAMLAAYIngSwCgDwAAALAAYIQgSwCgDwAAAMAAII+wPXHwA0AAAAAA==.Karina:BAAALAAECgcIDQABLAAFFAcINQAIAEYhAA==.',Kk='Kkc:BAAALAAECgMIBAAAAA==.',Lo='Loyomi:BAAALAAECgEIAQAAAA==.',Ls='Lsblood:BAAALAAECgcIBwAAAA==.',Lu='Luckydruid:BAAALAAFFAIIAgAAAA==.Luckyknight:BAAALAAFFAgIAgAAAA==.',Ma='Magnaaegwynn:BAABLAAFFH8MAAMNAAYIgAKYEABcAAAOAAYIdAEUQQCkAAANAAMIOwOYEABcAAAAAA==.',Sa='Saurfang:BAAALAAECgIIAgAAAA==.Savage:BAAALAAFFAIIAgAAAA==.',Sk='Skyblade:BAABLAAECn8MAAIPAAYIlhVZdwCaAQAPAAYIlhVZdwCaAQAAAA==.',Sm='Smackdown:BAABLAAFFH8UAAIPAAgIVhdPBgBnAgAPAAgIVhdPBgBnAgAAAA==.',Sy='Sylvanasscy:BAACLAAFFH8aAAIBAAYIxRnkFgCaAQABAAYIxRnkFgCaAQAsAAQKfyIAAgEACAhyIMQUAGgCAAEACAhyIMQUAGgCAAAA.',Te='Tearsbiubiu:BAABLAAFFH8IAAINAAIIuBaPDgCVAAANAAIIuBaPDgCVAAABLAAFFAIICQABAGkPAA==.Tearsprince:BAABLAAFFH8JAAIBAAIIaQ+tSwCWAAABAAIIaQ+tSwCWAAAAAA==.',Tm='Tmmz:BAAALAAECgQIBAAAAA==.',Ww='Wwe:BAABLAAFFH8kAAIFAAgIfiQBAgDsAgAFAAgIfiQBAgDsAgAAAA==.Wwf:BAABLAAFFH8jAAIFAAgIwCSLAQD2AgAFAAgIwCSLAQD2AgAAAA==.',Yc='Ycrogue:BAAALAADCgQIBAAAAA==.',Yr='Yraax:BAAALAAECgYICAAAAA==.',['一弯']='一弯孤月:BAABLAAFFH8GAAIHAAMIeBR0bwCEAAAHAAMIeBR0bwCEAAABLAAFFAgIEgAHAM0MAA==.',['一德']='一德唬人:BAAALAAECgUIBQAAAA==.',['一脚']='一脚开牢门:BAABLAAFFH8FAAIFAAMI8wsEZwB8AAAFAAMI8wsEZwB8AAAAAA==.',['万事']='万事如意菇:BAABLAAFFH8IAAIQAAYIfRBuIwBEAQAQAAYIfRBuIwBEAQAAAA==.',['万物']='万物初始之风:BAAALAAECgYIDAAAAA==.',['三伞']='三伞闪上:BAAALAAFFAIIAgAAAA==.',['上官']='上官丶呆哔:BAACLAAFFH8VAAIRAAYIQBdNBwALAgARAAYIQBdNBwALAgAsAAQKfzUAAhEACAjPJF8FAGMDABEACAjPJF8FAGMDAAAA.',['不发']='不发标很多年:BAAALAADCgEIAQAAAA==.',['不死']='不死法医:BAAALAAECgYIBgAAAA==.',['不祥']='不祥之刃:BAAALAAECgYICAAAAA==.',['世界']='世界通用:BAAALAAECgMIAwAAAA==.',['两天']='两天一夜:BAAALAAECgYIDQAAAA==.',['丨懒']='丨懒大王丨:BAABLAAFFH8SAAISAAUIgxtSFgCDAQASAAUIgxtSFgCDAQAAAA==.',['丨潇']='丨潇洒哥丨:BAAALAAFFAEIAQAAAA==.',['丨绯']='丨绯瑾丨:BAABLAAFFH8GAAMLAAYIpAq1CQARAQALAAUIGwy1CQARAQAMAAEIUgNrHgA+AAAAAA==.',['丨行']='丨行不晚丨:BAABLAAECn8VAAMTAAcIWiMnCgDCAgATAAcIWiMnCgDCAgAUAAIIlgeCZABRAAAAAA==.',['丨长']='丨长生天丨:BAABLAAFFH8RAAIQAAYIJRgvEwDKAQAQAAYIJRgvEwDKAQAAAA==.',['丰兄']='丰兄婲鸡:BAAALAAFFAMIAwAAAA==.',['丶叶']='丶叶隐娘:BAAALAAFFAIIBAAAAA==.',['丶牙']='丶牙牙丶:BAAALAAECgYIDAAAAA==.',['丶至']='丶至死方休丶:BAABLAAFFH8HAAIBAAQIphfBDwBLAQABAAQIphfBDwBLAQAAAA==.',['丶雷']='丶雷霆之怒丶:BAAALAAECgEIAQAAAA==.',['主人']='主人降临:BAAALAAECgYIEAAAAA==.',['乌尔']='乌尔扎戈:BAAALAAECgUIDAAAAA==.',['乔伊']='乔伊斯:BAABLAAFFH8PAAIFAAgIYiNOAwDSAgAFAAgIYiNOAwDSAgAAAA==.',['乘黄']='乘黄御风:BAAALAAFFAMIAwAAAA==.',['九十']='九十个萨满:BAAALAAECgYICAAAAA==.',['事了']='事了拂衣:BAACLAAFFH8OAAIVAAII5hM7QACXAAAVAAII5hM7QACXAAAsAAQKfxwAAhUABgglHQBcANwBABUABgglHQBcANwBAAAA.',['云梦']='云梦谣:BAAALAAFFAIIAgABLAAFFAgICgAQAO4aAA==.',['云泽']='云泽:BAAALAAECgcIEwAAAA==.',['亚丽']='亚丽雅:BAAALAAECggIAgAAAA==.',['亚契']='亚契:BAABLAAFFH8GAAIFAAYI7xOHNQBnAQAFAAYI7xOHNQBnAQAAAA==.',['亜菲']='亜菲利欧:BAACLAAFFH87AAMCAAgIMiXuAAClAgACAAgIMiXuAAClAgAEAAEIEyL8DQBZAAAsAAQKfzQAAwIACAggJpcDAFIDAAIACAgTJpcDAFIDAAQABghPJcEEAH4CAAAA.',['人形']='人形自走炮:BAAALAAECgMIAwAAAA==.',['人间']='人间失格:BAAALAAECgIIAgAAAA==.',['他它']='他它:BAAALAAECgEIAQAAAA==.',['仙剑']='仙剑丶李逍遥:BAAALAADCgEIAQAAAA==.',['伊利']='伊利舟:BAAALAADCgIIAgAAAA==.',['伊瑟']='伊瑟尔德:BAAALAAFFAMIAwAAAA==.',['众星']='众星:BAACLAAFFH8rAAMEAAgIXB0FAQCbAgAEAAgIXB0FAQCbAgADAAIIbQWwGQBnAAAsAAQKfygAAwQACAjNHfACAMwCAAQACAjNHfACAMwCAAMACAhqCNMjAEgBAAEsAAUUBQgrABMAdCYA.',['会飞']='会飞的猪:BAAALAAECgYIBgAAAA==.',['伯德']='伯德满:BAAALAAECgYIDgAAAA==.',['佳佳']='佳佳奶糖:BAABLAAFFH8sAAIFAAgI2CMIAgDrAgAFAAgI2CMIAgDrAgAAAA==.',['依晨']='依晨卫:BAAALAADCgIIAgAAAA==.',['侬刚']='侬刚侬刚伐:BAAALAAECggICAAAAA==.',['八級']='八級大狂風:BAABLAAFFH8GAAIHAAYIXQjlRgAwAQAHAAYIXQjlRgAwAQAAAA==.',['公孙']='公孙轩辕:BAAALAAECgYIBgAAAA==.',['兽血']='兽血沸腾丶:BAABLAAECn8eAAMRAAgIxSEHFQDtAgARAAgIiSEHFQDtAgAWAAgIyhtPAgBlAgAAAA==.',['冰之']='冰之梦魇:BAAALAAFFAIIBAAAAA==.',['冰河']='冰河:BAAALAAECggICgAAAA==.',['冲锋']='冲锋不乱阵脚:BAABLAAFFH8MAAIPAAIIrgWeVwA/AAAPAAIIrgWeVwA/AAAAAA==.冲锋接暴扣:BAACLAAFFH8RAAIXAAYI3RntAwD4AQAXAAYI3RntAwD4AQAsAAQKfxgAAhcACAjhITgMAOoCABcACAjhITgMAOoCAAAA.',['凤凰']='凤凰单枞:BAABLAAFFH8GAAIFAAYICxF3OABbAQAFAAYICxF3OABbAQAAAA==.凤凰琴到手:BAAALAAECgYIBgAAAA==.',['刃舞']='刃舞倾城:BAAALAAECgQIBAAAAA==.',['分身']='分身无术:BAAALAAECgYICwAAAA==.',['功夫']='功夫小鱼:BAABLAAFFH8LAAIBAAMI9xk0GAD9AAABAAMI9xk0GAD9AAAAAA==.',['加鲁']='加鲁:BAAALAAFFAIIBAAAAA==.',['北风']='北风其凉:BAAALAAECgEIAQAAAA==.',['半刀']='半刀甜:BAABLAAFFH8UAAIQAAYItRMdHQB0AQAQAAYItRMdHQB0AQAAAA==.',['卫戎']='卫戎:BAAALAADCggICAAAAA==.',['叁月']='叁月:BAAALAAFFAIIBAAAAA==.叁月眔:BAAALAAECgYIBgAAAA==.',['叁灬']='叁灬月:BAAALAAECgQIBAAAAA==.',['又初']='又初恋了:BAAALAAECggICwAAAA==.',['又活']='又活一天:BAAALAAECgEIAQAAAA==.',['叫姐']='叫姐就奶你:BAAALAADCggICAAAAA==.',['召尸']='召尸丨墓响:BAAALAAECgYIBgAAAA==.',['叮咚']='叮咚:BAAALAADCgMIAwAAAA==.',['可乐']='可乐碎碎冰:BAAALAAECgYIBwAAAA==.',['台词']='台词而以:BAABLAAFFH8SAAMYAAYIlAVRDQCzAAAYAAUIFwZRDQCzAAABAAEIBQPmhAAaAAAAAA==.台词而已:BAABLAAFFH8bAAIXAAcI+A9tDQBuAQAXAAcI+A9tDQBuAQAAAA==.',['叱咤']='叱咤红人:BAAALAAECgMIAwAAAA==.',['叶熙']='叶熙佑:BAAALAAECgYIBgAAAA==.',['叶瞬']='叶瞬光:BAABLAAFFH8TAAIFAAgIHiAIBQCwAgAFAAgIHiAIBQCwAgAAAA==.',['叽叽']='叽叽喳喳:BAAALAAECgMIBAAAAA==.',['吃土']='吃土不吃饭:BAAALAAECgMIAwAAAA==.',['吃货']='吃货怕饿梦:BAABLAAFFH8FAAIIAAII9wblVwCDAAAIAAII9wblVwCDAAAAAA==.',['君子']='君子不器:BAAALAADCggICAAAAA==.',['吞下']='吞下一整根:BAABLAAFFH8KAAIIAAgIVRxRBgB3AgAIAAgIVRxRBgB3AgAAAA==.',['告辞']='告辞:BAAALAADCgIIAgAAAA==.',['命运']='命运之神:BAACLAAFFH8SAAIPAAMIug4mHADpAAAPAAMIug4mHADpAAAsAAQKfxkAAg8ABghYIY9PAAICAA8ABghYIY9PAAICAAAA.',['咩瑞']='咩瑞:BAAALAAECgYIBgAAAA==.',['哇呀']='哇呀呀:BAAALAAECgUIBwAAAA==.',['哎一']='哎一吖:BAAALAAECgYICwAAAA==.',['哎呀']='哎呀咚咚锵:BAAALAAECgYIBgAAAA==.',['哦小']='哦小点点:BAACLAAFFH8PAAIZAAUIDAuaBgAoAQAZAAUIDAuaBgAoAQAsAAQKfx4AAhkACAjODaENAFQBABkACAjODaENAFQBAAAA.',['唧唧']='唧唧歪歪:BAAALAAECgIIAgAAAA==.',['啊咕']='啊咕思:BAAALAADCgUIBQAAAA==.',['喝不']='喝不完的豆奶:BAAALAAECgQICAAAAA==.',['喝完']='喝完的啤酒:BAAALAAFFAIIBAAAAA==.',['喵狐']='喵狐仙:BAAALAAFFAIIAgAAAA==.',['嗖嗖']='嗖嗖:BAAALAAECgQIBAAAAA==.',['嗷嗷']='嗷嗷呜:BAAALAAECgMIAwAAAA==.',['嘿咻']='嘿咻咻灬:BAABLAAFFH8WAAMaAAgIAxhpCgBVAQAaAAYI1BZpCgBVAQABAAIIpg3xQACSAAAAAA==.',['嚣张']='嚣张大少:BAAALAAECgcIDAAAAA==.',['團滅']='團滅之星:BAABLAAFFH8NAAMBAAYIpA8zIABoAQABAAYIpA8zIABoAQAaAAIIGxN+JAB/AAAAAA==.',['圣光']='圣光回响:BAAALAAFFAMIAwABLAAFFAYIGQAbAEASAA==.圣光在下:BAAALAAECgUIBQAAAA==.圣光小鸭哥:BAAALAAFFAIIAgAAAA==.',['圣域']='圣域追风:BAACLAAFFH8LAAIBAAUItA4oLwAPAQABAAUItA4oLwAPAQAsAAQKfxkAAgEACAi5FaOEAOQBAAEACAi5FaOEAOQBAAAA.',['圣子']='圣子川:BAAALAAECgQIBAAAAA==.',['圣灵']='圣灵骑士:BAAALAAECgEIAQAAAA==.',['坏女']='坏女人:BAAALAADCgUIBQAAAA==.',['埃索']='埃索达:BAABLAAFFH8IAAIFAAQIHhdbSwAFAQAFAAQIHhdbSwAFAQAAAA==.',['基安']='基安蒂丶:BAABLAAFFH8KAAIMAAYIWBxJBwCpAQAMAAYIWBxJBwCpAQAAAA==.',['塞蕾']='塞蕾丝缇雅:BAAALAAFFAEIAQAAAA==.',['墨璃']='墨璃:BAAALAAECgYIDAAAAA==.',['夏明']='夏明朗中校:BAAALAADCgMIAwAAAA==.',['夜月']='夜月之复仇:BAAALAAECgEIAQAAAA==.',['夜王']='夜王:BAAALAADCggIDAAAAA==.',['夜的']='夜的第一章:BAAALAAECgQIBwAAAA==.夜的第三章:BAAALAAECggICAAAAA==.',['夜醉']='夜醉:BAAALAAFFAIIAgAAAA==.',['夜雨']='夜雨戚戚:BAAALAAECgQIAwAAAA==.',['夜风']='夜风星月:BAAALAAECgUIDAAAAA==.',['大力']='大力出奇迹:BAAALAAECgIIAgAAAA==.',['大弗']='大弗弗:BAACLAAFFH8aAAIKAAYIVhppAgAfAgAKAAYIVhppAgAfAgAsAAQKfzEAAwoACAiXI8gHAOYCAAoACAiXI8gHAOYCAAUABQiDHYinALsBAAAA.',['大水']='大水汼:BAABLAAECn8XAAIFAAYIvBGvagAaAQAFAAYIvBGvagAaAQAAAA==.',['大耳']='大耳贼:BAAALAADCgEIAQAAAA==.',['大轰']='大轰龙:BAAALAAECgUIBQAAAA==.',['天河']='天河雪琼:BAAALAAECgEIAQAAAA==.',['夹馍']='夹馍:BAAALAADCgMIAwAAAA==.',['奥丽']='奥丽佛:BAABLAAFFH8GAAIQAAIIOhjoSACNAAAQAAIIOhjoSACNAAAAAA==.',['奥蕾']='奥蕾莉娅:BAAALAAECgUIBQAAAA==.',['奥赛']='奥赛利亚:BAABLAAFFH8IAAMcAAIINRfVEgBHAAAcAAIIqhbVEgBHAAAVAAIItgtOWgBFAAAAAA==.',['女战']='女战神乐桐:BAAALAAECgMIAwAAAA==.',['奶糖']='奶糖佳佳:BAABLAAFFH8gAAIFAAgI1yF3BgA9AgAFAAgI1yF3BgA9AgAAAA==.',['好喜']='好喜欢艾草:BAAALAAECgYICAAAAA==.',['妮露']='妮露狸:BAABLAAFFH8MAAIFAAYINhl3JQCgAQAFAAYINhl3JQCgAQAAAA==.',['威格']='威格大领主:BAABLAAECn8WAAIBAAgI4RnyKADwAQABAAgI4RnyKADwAQAAAA==.',['嫩嫩']='嫩嫩炖蛋出炉:BAAALAAECgYIDQAAAA==.',['孤星']='孤星的眼泪:BAAALAAECgYIBgAAAA==.',['孤枫']='孤枫持刃:BAABLAAFFH8GAAIIAAII/wVFZgA6AAAIAAII/wVFZgA6AAAAAA==.',['安嘉']='安嘉和:BAAALAAECgYICgAAAA==.',['安知']='安知鱼:BAAALAAECgYICgAAAA==.',['安若']='安若清风:BAAALAAFFAIIAgAAAA==.',['官山']='官山:BAAALAADCgUIBgAAAA==.',['宝贝']='宝贝灬佳佳:BAABLAAFFH8XAAIFAAcIbRKLHAA9AQAFAAcIbRKLHAA9AQAAAA==.宝贝灬别摸我:BAAALAAECgYIEwABLAAFFAcIFwAFAG0SAA==.宝贝灬咕咕:BAABLAAFFH8RAAIdAAIIzhshHACVAAAdAAIIzhshHACVAAABLAAFFAcIFwAFAG0SAA==.宝贝灬大领主:BAABLAAFFH8RAAIBAAMIBBd8QwCLAAABAAMIBBd8QwCLAAABLAAFFAcIFwAFAG0SAA==.宝贝灬小佳佳:BAACLAAFFH8dAAIOAAUIKhYMJgD8AAAOAAUIKhYMJgD8AAAsAAQKfx4AAg4ABwjsH6E5AGMCAA4ABwjsH6E5AGMCAAEsAAUUBwgXAAUAbRIA.宝贝灬神射手:BAACLAAFFH8mAAMGAAYIph1sCgBYAQAGAAUIOxdsCgBYAQAHAAYIAxv+HAAcAQAsAAQKfyoAAwYACAgUILcYAJ0CAAYACAhWH7cYAJ0CAAcABgjqHvh4AOsBAAEsAAUUBwgXAAUAbRIA.',['家有']='家有大猫:BAAALAAECgQIAwAAAA==.',['寂寞']='寂寞幽灵:BAAALAAECgYIDAAAAA==.',['寄居']='寄居云端:BAACLAAFFH8GAAMaAAYIDBM1CQCAAQAaAAUIuRI1CQCAAQABAAEICwXTaABKAAAsAAQKfxUABBoACAi5CzI3AIkBABoACAi5CzI3AIkBABgABgjmDcZNAPUAAAEAAwgUE0SgAMAAAAAA.',['寒冰']='寒冰之墙丶:BAAALAAFFAIIAgAAAA==.',['寸長']='寸長:BAAALAADCgcIBwAAAA==.',['小兇']='小兇许:BAABLAAFFH8LAAIVAAYIXSbKEgD3AQAVAAYIXSbKEgD3AQAAAA==.',['小兔']='小兔瑞贝卡卡:BAABLAAFFH8KAAIQAAIIGBEmXQBhAAAQAAIIGBEmXQBhAAAAAA==.小兔瑞贝德:BAABLAAFFH8MAAMdAAYIMxTnGQAIAQAdAAUI+RDnGQAIAQASAAMILAYjOgCFAAAAAA==.',['小小']='小小花裤衩:BAAALAAECgYIBgAAAA==.',['小楼']='小楼逢雨月:BAAALAAECgcIBwAAAA==.',['小欣']='小欣欣:BAAALAADCgUICAAAAA==.',['小浣']='小浣熊:BAABLAAFFH8IAAIOAAIIgRlBPgChAAAOAAIIgRlBPgChAAAAAA==.',['小爹']='小爹地:BAAALAAECgYIBgAAAA==.',['小牛']='小牛牛来了:BAAALAAFFAMIAwAAAA==.',['小猎']='小猎刄:BAABLAAFFH8GAAIHAAIIQBJ6ngA/AAAHAAIIQBJ6ngA/AAAAAA==.',['小白']='小白兔长大了:BAAALAAECggICAAAAA==.小白菜:BAAALAAECgYIBgAAAA==.',['小算']='小算啦:BAAALAAECgMIAwAAAA==.',['小肚']='小肚皮:BAAALAAFFAIIAgAAAA==.',['小锤']='小锤锤你胸口:BAABLAAFFH8HAAIBAAIIGRttMwCoAAABAAIIGRttMwCoAAAAAA==.',['小鲁']='小鲁班八号:BAABLAAFFH8KAAIHAAMItBPIUgCUAAAHAAMItBPIUgCUAAAAAA==.',['就看']='就看你虚不虚:BAABLAAECn8VAAMHAAcITBRnpAClAQAHAAcIMRRnpAClAQAeAAcIOAtQEgCFAQAAAA==.',['尺犬']='尺犬之主:BAAALAADCgIIAgAAAA==.',['山丘']='山丘之土:BAAALAADCgEIAQAAAA==.',['山高']='山高水深:BAABLAAFFH8FAAIFAAIIWwRxqAAnAAAFAAIIWwRxqAAnAAAAAA==.',['岁月']='岁月的杀猪刀:BAAALAAECgQIBAAAAA==.',['川大']='川大智胜:BAAALAAECggICAAAAA==.',['市丸']='市丸银:BAAALAAFFAIIAgAAAA==.',['布斯']='布斯人:BAAALAAECgYICAAAAA==.',['帅气']='帅气的骨头:BAAALAAECgYIDgAAAA==.',['希尔']='希尔佤娜斯:BAAALAAECgYICAAAAA==.',['帝国']='帝国之心:BAABLAAFFH8FAAIBAAUIIhLuKgArAQABAAUIIhLuKgArAQAAAA==.帝国之殇:BAABLAAFFH8KAAIIAAYIwQ7DKABOAQAIAAYIwQ7DKABOAQAAAA==.帝国之狼:BAABLAAFFH8GAAIOAAYIEBywIQCQAQAOAAYIEBywIQCQAQAAAA==.帝国之翼:BAABLAAFFH8GAAISAAYIBgm6HwAlAQASAAYIBgm6HwAlAQAAAA==.',['幻梦']='幻梦琉璃剑:BAAALAADCgYIBgAAAA==.',['幻灭']='幻灭之梦:BAAALAAECgYICwAAAA==.',['幼儿']='幼儿园小喵喵:BAAALAAECgEIAQAAAA==.',['幽冥']='幽冥小鹅毛:BAAALAAECgYIAwAAAA==.幽冥狂刹:BAAALAAECgYIBgAAAA==.',['幽灵']='幽灵喂面:BAAALAAECgYICAAAAA==.幽灵的老刀:BAAALAAECgIIAgAAAA==.',['开始']='开始的悲哀:BAABLAAFFH8FAAIBAAIIoxccNwClAAABAAIIoxccNwClAAAAAA==.',['张大']='张大夫:BAACLAAFFH8OAAIIAAIIVBk+SwBOAAAIAAIIVBk+SwBOAAAsAAQKfxQAAggABggOHnwrAK0BAAgABggOHnwrAK0BAAAA.',['张月']='张月玲:BAAALAAECgYIBgAAAA==.',['彩鳞']='彩鳞:BAAALAAECgYIBwAAAA==.',['徐列']='徐列如林:BAAALAADCgEIAQAAAA==.',['微笑']='微笑著哭泣:BAAALAAECgYIBgAAAA==.',['德一']='德一忘形:BAAALAADCgMIAwAAAA==.',['德性']='德性天下:BAABLAAECn8UAAMSAAYI/BFRSQDyAAASAAYI/BFRSQDyAAAdAAUIRQ1hdgDsAAAAAA==.',['心碎']='心碎小牧:BAAALAAFFAIIAgABLAAFFAUIGgAOALYdAA==.',['怠惰']='怠惰带司教:BAAALAAECgYICgAAAA==.',['恭喜']='恭喜发财丷:BAABLAAFFH8QAAIOAAYI0x9XFwDGAQAOAAYI0x9XFwDGAQAAAA==.',['惊谪']='惊谪:BAAALAAECgEIAQAAAA==.',['想也']='想也有罪:BAAALAAECgcIDwAAAA==.',['我叫']='我叫小乖:BAAALAAFFAIIBAAAAA==.',['我想']='我想当风:BAAALAAECgQIBQAAAA==.',['战天']='战天丷傲刃:BAAALAAECgYIBgAAAA==.战天丷孤狼:BAAALAAFFAIIAgAAAA==.战天丷皮卡丘:BAAALAAECgYIBgAAAA==.',['戦之']='戦之哀殇:BAAALAAECgYIDAAAAA==.',['扎瑞']='扎瑞尔:BAACLAAFFH8aAAMVAAUI9R5lNQA9AQAVAAUImxxlNQA9AQAfAAEIKSCoBgBbAAAsAAQKfx8AAxUACAjXH1EWAAEDABUACAjXH1EWAAEDAB8AAwgfIs4LAL0AAAAA.',['打死']='打死一只兔:BAABLAAFFH8NAAIBAAMIexYTSAB7AAABAAMIexYTSAB7AAABLAAFFAUIEAAOAHoRAA==.打死一只猪:BAABLAAFFH8QAAIOAAUIehEjNgAhAQAOAAUIehEjNgAhAQAAAA==.打死一只鸡:BAABLAAFFH8GAAIIAAIILhOhWQBDAAAIAAIILhOhWQBDAAABLAAFFAUIEAAOAHoRAA==.',['抽完']='抽完的烟锅巴:BAAALAAECgEIAQAAAA==.抽完的香烟:BAAALAAFFAIIAgAAAA==.',['指路']='指路明灯:BAABLAAFFH8GAAIZAAII5RIpEACZAAAZAAII5RIpEACZAAAAAA==.',['挽昼']='挽昼:BAABLAAFFH8ZAAIFAAgIeyWtAAAPAwAFAAgIeyWtAAAPAwAAAA==.',['摇摆']='摇摆中的屁屁:BAAALAAECgEIAQAAAA==.',['放开']='放开那位大婶:BAAALAAECgQIBAAAAA==.',['新年']='新年快乐丷:BAAALAAFFAIIBAAAAA==.',['新手']='新手村萨满:BAAALAADCgMIAwAAAA==.',['方块']='方块安全:BAABLAAFFH8FAAIXAAUI3ArUGQDOAAAXAAUI3ArUGQDOAAAAAA==.',['无敌']='无敌小二妹:BAAALAADCgIIAgAAAA==.无敌爆爆龙:BAAALAAECgUIBQAAAA==.',['无赖']='无赖鼻祖:BAABLAAFFH8IAAIBAAIIQw83bgA/AAABAAIIQw83bgA/AAAAAA==.',['无赦']='无赦罪痕:BAAALAADCgMIAwAAAA==.',['无非']='无非想快乐:BAABLAAFFH8KAAQDAAII2iDBDgC/AAADAAII2iDBDgC/AAAEAAIIqhnKBwCgAAACAAEI6xemIwBGAAABLAAFFAgIQAACAMEdAA==.',['日明']='日明:BAAALAAFFAIIBAAAAA==.',['昊哥']='昊哥:BAAALAAECgIIAgAAAA==.',['晚风']='晚风很刺眼:BAAALAADCgIIAgAAAA==.',['普六']='普六茹豆:BAAALAADCgEIAQAAAA==.',['暗盾']='暗盾一族:BAAALAAECgYIDQAAAA==.',['最后']='最后一舞:BAAALAAECgQIBAAAAA==.',['有来']='有来有去:BAAALAAECgMIAgAAAA==.',['有点']='有点小晕晕:BAABLAAFFH8JAAIOAAII5hUzRwCZAAAOAAII5hUzRwCZAAAAAA==.',['有种']='有种盗我德号:BAABLAAFFH8MAAMdAAYIwAm/GgABAQAdAAYIwAm/GgABAQASAAIIaQfLTwBUAAABLAAFFAgIDQAdAKoDAA==.',['木豆']='木豆琥珀糖:BAAALAADCgUIDQAAAA==.',['朲冭']='朲冭帅:BAAALAAECgcIEgAAAA==.',['杀死']='杀死尔比:BAABLAAFFH8YAAIHAAYIBiQGDwATAgAHAAYIBiQGDwATAgAAAA==.',['李小']='李小龙:BAACLAAFFH8MAAIUAAIITx1gDAC2AAAUAAIITx1gDAC2AAAsAAQKfzoAAhQABgjVJT8JABYCABQABgjVJT8JABYCAAAA.',['枫之']='枫之耀舞:BAAALAAECgcIBwABLAAFFAgIJAACAAYcAA==.',['枫叶']='枫叶灵:BAAALAAECgIIAgAAAA==.',['格鲁']='格鲁姆地狱吼:BAAALAAECgYIDAAAAA==.',['椰果']='椰果奶绿:BAACLAAFFH8rAAIgAAgIah78AgBiAgAgAAgIah78AgBiAgAsAAQKfxYAAiAACAhvFN4aAM0BACAACAhvFN4aAM0BAAAA.',['楪祈']='楪祈:BAABLAAFFH8RAAIbAAYIeBzkEgDDAQAbAAYIeBzkEgDDAQAAAA==.',['武德']='武德的化身:BAAALAADCgMIAwAAAA==.',['死也']='死也要在一起:BAAALAAECgUIBgAAAA==.',['死亡']='死亡使者小萨:BAAALAAECgUIDgAAAA==.',['残夜']='残夜心凄凉:BAAALAAECgYIBwAAAA==.',['毁灭']='毁灭叹息:BAAALAAECgYIBgAAAA==.',['毅魂']='毅魂魅影:BAAALAAECgYICgAAAA==.',['池鱼']='池鱼思故淵:BAABLAAFFH8OAAIDAAgIIR8nAgDFAgADAAgIIR8nAgDFAgAAAA==.',['没有']='没有信仰的牛:BAABLAAECn8UAAIBAAgIuRelTQBWAgABAAgIuRelTQBWAgAAAA==.',['法力']='法力残渣丶:BAAALAADCgUIBQAAAA==.',['浑身']='浑身都是节懆:BAAALAAECgYIEwAAAA==.',['浪之']='浪之幻影:BAABLAAECn8hAAIBAAgICx9oUgBKAgABAAgICx9oUgBKAgAAAA==.',['浮生']='浮生明月:BAABLAAFFH8GAAMRAAYI1Q7mDgCSAQARAAUIPBDmDgCSAQAQAAEImg8kcgBDAAAAAA==.',['海落']='海落迟梦:BAABLAAFFH8GAAIbAAIIexMlOgB4AAAbAAIIexMlOgB4AAAAAA==.',['滅团']='滅团灾星:BAABLAAFFH8GAAIIAAYIvwXjNADgAAAIAAYIvwXjNADgAAAAAA==.',['滅團']='滅團災星:BAABLAAFFH8KAAIPAAYI0wudIwBTAQAPAAYI0wudIwBTAQAAAA==.滅團灾星:BAABLAAFFH8WAAIFAAgIbhCSKQCRAQAFAAgIbhCSKQCRAQAAAA==.',['漂邈']='漂邈:BAABLAAFFH8QAAIbAAQIjyAGGwB4AQAbAAQIjyAGGwB4AQAAAA==.',['潇潇']='潇潇洒洒:BAABLAAFFH8GAAIQAAYI/CLVBwBGAgAQAAYI/CLVBwBGAgAAAA==.',['潇然']='潇然尘外:BAABLAAFFH8JAAINAAIIFyC7CwClAAANAAIIFyC7CwClAAAAAA==.',['澄大']='澄大卜:BAAALAAFFAIIAgAAAA==.',['火花']='火花皮卡丘:BAAALAAFFAIIAgAAAA==.',['灵魂']='灵魂屠戮者:BAAALAAECgYIDAAAAA==.',['烈焰']='烈焰咕咕:BAAALAADCggIEQAAAA==.',['焱帝']='焱帝弑天:BAABLAAFFH8HAAIFAAMImxgqWgCdAAAFAAMImxgqWgCdAAAAAA==.',['煲湯']='煲湯牛:BAAALAAECgYIBgAAAA==.',['爱如']='爱如潮水:BAAALAAECgYIDwAAAA==.',['爱的']='爱的奉献:BAAALAAECgYICwAAAA==.',['牛哔']='牛哔:BAAALAAECgYIBgAAAA==.',['牛小']='牛小花灬:BAABLAAFFH8dAAMaAAcIERwtDAAiAQAaAAUIhxotDAAiAQABAAIIoBCSPgCaAAAAAA==.',['牛牛']='牛牛小二妹:BAABLAAFFH8GAAISAAYIhR5NAgAyAgASAAYIhR5NAgAyAgAAAA==.牛牛小骑士:BAABLAAFFH8IAAIYAAIIQhc9GQA5AAAYAAIIQhc9GQA5AAAAAA==.',['牛鞭']='牛鞭:BAAALAADCgUIBQAAAA==.',['牧星']='牧星:BAAALAAECgMIAwAAAA==.',['犹犹']='犹犹豫豫:BAABLAAFFH8GAAISAAYIPwnBIAAbAQASAAYIPwnBIAAbAQAAAA==.',['狐大']='狐大爷:BAAALAADCgYIBgAAAA==.',['狐术']='狐术虚空:BAAALAAECgYIBgAAAA==.',['狐莱']='狐莱:BAAALAAECgQIBAAAAA==.',['狗熊']='狗熊:BAABLAAECn8dAAISAAYIsw+4QAAXAQASAAYIsw+4QAAXAQAAAA==.',['猛不']='猛不猛很猛:BAAALAAECgYIBgAAAA==.',['猜火']='猜火车:BAAALAAFFAIIBAAAAA==.',['猩红']='猩红收割者:BAAALAADCgYIBgAAAA==.',['獠牙']='獠牙巨兽:BAABLAAECn8WAAQMAAgIIyCoEQCTAgAMAAgIHh+oEQCTAgAhAAgIPxPiBwAXAgALAAEIVQ90TgA5AAAAAA==.',['疯狂']='疯狂的老刀:BAAALAAECgIIAgAAAA==.疯狂皮卡丘:BAACLAAFFH8JAAIQAAMIKxnNNQDOAAAQAAMIKxnNNQDOAAAsAAQKfygAAxAACAh/HfoeAJkCABAACAh/HfoeAJkCABEABAhOF+o7AB4BAAAA.',['白羽']='白羽:BAABLAAFFH8KAAIbAAYIeCABDAAMAgAbAAYIeCABDAAMAgAAAA==.',['睿智']='睿智的眼神:BAABLAAFFH8SAAICAAYIogDPJQAcAAACAAYIogDPJQAcAAAAAA==.',['瞅你']='瞅你能咋地:BAABLAAFFH8eAAIFAAYI7xkGKgCQAQAFAAYI7xkGKgCQAQAAAA==.',['知悉']='知悉:BAACLAAFFH8ZAAIQAAMIkxmFOADCAAAQAAMIkxmFOADCAAAsAAQKf0kAAhAACAgoIG0MAJ4CABAACAgoIG0MAJ4CAAAA.',['破天']='破天丶濑由衣:BAAALAAFFAIIAgAAAA==.',['简阿']='简阿普:BAAALAAECgYIBgAAAA==.',['算来']='算来一梦浮生:BAAALAAECgIIAgABLAAECgYIBgAiAAAAAA==.',['納哥']='納哥大领主:BAAALAAECgQIBAAAAA==.',['红熊']='红熊猫:BAAALAAECgYICAAAAA==.',['绒球']='绒球儿:BAAALAAECgIIAgAAAA==.',['绿影']='绿影:BAAALAAECgYIBwAAAA==.',['绿箭']='绿箭奥利弗:BAAALAAECgEIAQAAAA==.',['缺爱']='缺爱不缺钙:BAAALAAECgMIAwAAAA==.',['羅徳']='羅徳徳丨七:BAABLAAFFH8GAAISAAIIdRhVNQCVAAASAAIIdRhVNQCVAAAAAA==.羅徳徳丨伍:BAAALAAFFAgIBAAAAA==.羅徳徳丨八:BAABLAAFFH8HAAISAAcIPBlHBgDBAQASAAcIPBlHBgDBAQAAAA==.羅徳徳丨十:BAABLAAFFH8FAAISAAQIUhHDGQC7AAASAAQIUhHDGQC7AAAAAA==.羅徳徳丨叁:BAABLAAFFH8KAAISAAgIMhnXBQBUAgASAAgIMhnXBQBUAgAAAA==.羅徳徳丨壹:BAABLAAFFH8JAAISAAgI2RaQBwA1AgASAAgI2RaQBwA1AgAAAA==.羅徳徳丨玖:BAABLAAFFH8GAAISAAYIOhWBFACVAQASAAYIOhWBFACVAQAAAA==.羅徳徳丨肆:BAABLAAFFH8GAAISAAYIBBVfBQDWAQASAAYIBBVfBQDWAQAAAA==.羅徳徳丨贰:BAAALAAFFAgIAQAAAA==.羅徳徳丨陆:BAABLAAFFH8GAAISAAYI+ReYJgDlAAASAAYI+ReYJgDlAAAAAA==.',['群星']='群星:BAAALAADCgIIAgAAAA==.群星萝莉:BAAALAAFFAMIAwAAAA==.',['老刀']='老刀来了:BAAALAAECgYIBgAAAA==.',['耐法']='耐法利安:BAABLAAECn8oAAIPAAgIrBKtNACIAQAPAAgIrBKtNACIAQAAAA==.',['肚肚']='肚肚打雷啦:BAABLAAFFH8GAAIHAAYIkAzRPABSAQAHAAYIkAzRPABSAQAAAA==.',['肝腰']='肝腰合炒:BAAALAADCgEIAQAAAA==.',['肥罗']='肥罗:BAAALAAECgYICQAAAA==.',['般若']='般若:BAAALAAECgYIBgAAAA==.',['芥末']='芥末贰号:BAABLAAFFH8UAAIIAAgIdiCQAwC9AgAIAAgIdiCQAwC9AgAAAA==.',['花开']='花开任平生:BAABLAAFFH8GAAIHAAYIDhruOABdAQAHAAYIDhruOABdAQAAAA==.',['花生']='花生花:BAACLAAFFH8IAAMEAAIIEQWeEQAxAAAEAAIIEQWeEQAxAAADAAEIiAnSIQAvAAAsAAQKfx4AAwMABgiUDrwmAC8BAAMABgiUDrwmAC8BAAQABghgEGIIAAsBAAAA.',['苏沫']='苏沫沫:BAAALAADCgcIBwAAAA==.',['英雄']='英雄莫問出處:BAAALAADCgcIBwAAAA==.',['苾蓝']='苾蓝芬:BAAALAAECggIEAAAAA==.',['范迪']='范迪塞尔:BAAALAAFFAIIAwAAAA==.范迪赛尔:BAAALAAFFAIIAgAAAA==.',['菠萝']='菠萝:BAAALAAECgYICQAAAA==.',['萨之']='萨之霊:BAACLAAFFH8YAAIQAAUIZA5oLwDzAAAQAAUIZA5oLwDzAAAsAAQKfx4AAhAABwjEE8hHADwBABAABwjEE8hHADwBAAAA.',['萨菲']='萨菲若丝:BAAALAAECggIDwAAAA==.萨菲鼬:BAAALAAFFAIIAgAAAA==.',['萨鲁']='萨鲁法尔大王:BAAALAAECgYIEAAAAA==.萨鲁法尔霸王:BAAALAAECgYICwAAAA==.',['落叶']='落叶繁花:BAAALAADCgYIBgAAAA==.',['蒋欣']='蒋欣:BAAALAAECgIIAgAAAA==.',['蓄意']='蓄意鞭笞丶:BAABLAAFFH8IAAIJAAII5AdzJQB9AAAJAAII5AdzJQB9AAAAAA==.',['蔓菁']='蔓菁:BAABLAAFFH8IAAITAAYIjQgJDQAZAQATAAYIjQgJDQAZAQAAAA==.',['虔诚']='虔诚拜三拜:BAAALAADCgcICAAAAA==.',['蛋蛋']='蛋蛋不瞎:BAAALAAECgMIAwAAAA==.',['蜜幂']='蜜幂:BAAALAAECgMIAwAAAA==.',['表弟']='表弟慢一手:BAAALAADCgYIBgAAAA==.',['计划']='计划大王:BAAALAADCgYIBgAAAA==.',['诸界']='诸界的毁灭者:BAAALAAFFAIIAgAAAA==.',['谁是']='谁是奶龙:BAAALAAECgEIAQAAAA==.',['谁的']='谁的眼泪在飞:BAAALAAECgYIAwAAAA==.',['豆丝']='豆丝:BAAALAAECgIIAgAAAA==.',['豆豆']='豆豆哟:BAAALAAFFAIIAgAAAA==.',['豆运']='豆运星:BAAALAAFFAIIBAAAAA==.',['貝爾']='貝爾尼尼:BAAALAAECgYIBgAAAA==.',['财源']='财源滚滚丷:BAABLAAFFH8IAAIIAAIIwxdARgCUAAAIAAIIwxdARgCUAAAAAA==.',['赏侬']='赏侬十巴掌:BAAALAAECggICgAAAA==.',['赤奥']='赤奥尼老爹:BAABLAAFFH8GAAIjAAYIggDQEgAMAAAjAAYIggDQEgAMAAAAAA==.赤奥尼老牧:BAABLAAFFH8UAAMbAAYITgn5DQBqAQAbAAUIawr5DQBqAQAJAAYIOATpGADxAAAAAA==.',['赫尔']='赫尔墨斯:BAAALAAECgYIDAAAAA==.',['超級']='超級大怪獸:BAABLAAFFH8GAAIaAAYI1RPoDgCZAQAaAAYI1RPoDgCZAQAAAA==.',['超级']='超级冯:BAABLAAFFH8fAAIPAAgIuB7iAwCwAgAPAAgIuB7iAwCwAgAAAA==.超级可:BAABLAAFFH8lAAIFAAgIMiUOAQAFAwAFAAgIMiUOAQAFAwAAAA==.超级大康娜:BAABLAAFFH8pAAIFAAgITyUEAQAFAwAFAAgITyUEAQAFAwAAAA==.超级小康纳:BAABLAAFFH8mAAIFAAgIGiNjAgDkAgAFAAgIGiNjAgDkAgAAAA==.超级康纳:BAABLAAFFH86AAIFAAgIxSR3AQD5AgAFAAgIxSR3AQD5AgAAAA==.超级谢忞明:BAAALAAFFAYIAwAAAA==.',['跟随']='跟随寂寞:BAAALAAECgIIAgAAAA==.',['踏梦']='踏梦第一人:BAAALAAECgUICAAAAA==.',['逢山']='逢山鬼泣:BAAALAAFFAIIAgAAAA==.',['部落']='部落第一勇士:BAAALAAECgMIAwAAAA==.',['酷尔']='酷尔啼拉丝:BAAALAAECgIIAgAAAA==.',['醉后']='醉后一杯喵:BAABLAAECn8iAAITAAgIzhxvBwBeAgATAAgIzhxvBwBeAgAAAA==.',['重燃']='重燃:BAAALAAECgYIBgAAAA==.',['镉球']='镉球:BAABLAAFFH8IAAIgAAIImwsbGQBpAAAgAAIImwsbGQBpAAAAAA==.',['闪电']='闪电猎手:BAAALAAECgYIDgAAAA==.',['阑夜']='阑夜微凉:BAAALAAFFAIIAgAAAA==.',['阡陌']='阡陌红尘:BAABLAAECn8UAAIBAAYI9BQ0eQAOAQABAAYI9BQ0eQAOAQAAAA==.',['阿什']='阿什顿:BAAALAAECggICAAAAA==.',['阿牛']='阿牛:BAAALAADCgIIAgAAAA==.',['阿紫']='阿紫魔蛋:BAAALAAECgYIBgAAAA==.',['随便']='随便瞅瞅:BAAALAAFFAYIAgAAAA==.',['随风']='随风潜入夜:BAAALAAECgUIBQAAAA==.',['难民']='难民营营长:BAAALAAFFAYIBAAAAA==.',['雷克']='雷克巴赫:BAAALAAFFAIIAgAAAA==.',['雷多']='雷多多:BAAALAAECgYICwAAAA==.',['雾非']='雾非雾:BAAALAAECgUICAAAAA==.',['青春']='青春小二妹:BAABLAAFFH8GAAIKAAYINA2jDQAvAQAKAAYINA2jDQAvAQAAAA==.',['青涩']='青涩后妈:BAAALAADCgcIBwAAAA==.',['青玄']='青玄大鹿:BAAALAAFFAIIAgAAAA==.',['青瓷']='青瓷:BAAALAAECgEIAQAAAA==.',['風之']='風之暮雨:BAAALAAECgQIBAAAAA==.',['风切']='风切:BAAALAAECgUIAwAAAA==.',['风牛']='风牛九号:BAAALAADCgYIBgAAAA==.',['飞哥']='飞哥来了:BAAALAAECgYICAAAAA==.',['飬一']='飬一只死一只:BAABLAAFFH8LAAIHAAUIJhJZWgDhAAAHAAUIJhJZWgDhAAAAAA==.',['香香']='香香蕉:BAAALAAECgYIBgAAAA==.',['馬大']='馬大帅:BAAALAAECgIIAgAAAA==.',['马佩']='马佩佩:BAACLAAFFH86AAMSAAgI/iPPAACMAgASAAgI/iPPAACMAgAdAAEIxgRtOQA1AAAsAAQKfzEABBIACAjkIzwLAAIDABIACAjkIzwLAAIDACMABQibC78yAPYAAB0AAwgXGcx5AN4AAAAA.',['骑嘚']='骑嘚隆咚呛:BAAALAADCgYIBgAAAA==.',['魅影']='魅影燃天:BAAALAAECgYIBgAAAA==.魅影祖阿玛尼:BAAALAAECgYIEgAAAA==.',['魔狱']='魔狱疯语者:BAABLAAFFH8GAAIQAAIITwh1aQBSAAAQAAIITwh1aQBSAAAAAA==.',['鸽骑']='鸽骑:BAABLAAFFH8aAAMFAAYIsCKuDAD0AQAFAAUI/iCuDAD0AQAZAAMICh8yBAA2AQAAAA==.',['鸿雁']='鸿雁于飞:BAAALAAECgYIDwAAAA==.',['鹰翎']='鹰翎:BAAALAAECgYIBgAAAA==.',['鹿七']='鹿七:BAAALAAFFAIIBAAAAA==.',['麦桐']='麦桐:BAACLAAFFH8YAAIHAAUIlyJmKgCMAQAHAAUIlyJmKgCMAQAsAAQKfyMAAgcACAgBImYXAAADAAcACAgBImYXAAADAAAA.',['黄昏']='黄昏之歌:BAABLAAFFH8OAAMSAAYIFgvLJQDsAAASAAUIqwnLJQDsAAAdAAMIDwUmKwBbAAAAAA==.',['黑翼']='黑翼之翔:BAABLAAFFH8JAAIFAAMIEAetaQBwAAAFAAMIEAetaQBwAAAAAA==.',['龙希']='龙希尔唤魔师:BAAALAAECgcIDQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end