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
 local lookup = {'DeathKnight-Unholy','Paladin-Retribution','Priest-Discipline','Priest-Shadow','Priest-Holy','Monk-Mistweaver','Monk-Brewmaster','Paladin-Protection','DemonHunter-Vengeance','Druid-Restoration','DemonHunter-Havoc','Mage-Fire','Druid-Balance','Mage-Arcane','Warrior-Protection','Warrior-Arms','Unknown-Unknown','Rogue-Assassination','Rogue-Subtlety','Rogue-Outlaw','DeathKnight-Blood','Warrior-Fury','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Affliction','Warlock-Destruction','Mage-Frost','Shaman-Elemental','Druid-Guardian','Shaman-Restoration','Paladin-Holy','Warlock-Demonology','Evoker-Devastation','Shaman-Enhancement','DeathKnight-Frost','Monk-Windwalker','Druid-Feral',}; local provider = {region='CN',realm='千针石林',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Accorry:BAAAKgAECgEIAQAAAA==.',An='Anvena:BAAAKgADCgMIAwAAAA==.',Ar='Arditi:BAAAKgAFFAQIBAAAAA==.Areally:BAAAKgAECgYICgAAAA==.',At='Athenshecate:BAAAKgAECgYICAAAAA==.',Ay='Ayalegna:BAABKgAECn8XAAIBAAcIXh1eOQDLAQABAAcIXh1eOQDLAQAAAA==.',Bl='Blackjack:BAAAKgADCggICwAAAA==.',Do='Dobi:BAABKgAFFH8KAAICAAMIBRuaQADvAAACAAMIBRuaQADvAAAAAA==.',Du='Duskyabyss:BAABKgAFFH8GAAQDAAYIZglEHQCvAAADAAQI3w5EHQCvAAAEAAEICgIQMAA2AAAFAAEI8AC/QQAsAAAAAA==.',Fc='Fcrown:BAABKgAFFH8IAAMGAAQI2BWaEADkAAAGAAQI2BWaEADkAAAHAAQIWAKRBwBqAAAAAA==.',Fu='Future:BAABKgAECn8gAAICAAgIxQ/AfABXAQACAAgIxQ/AfABXAQAAAA==.',Ha='Ha:BAAAKgAECggICAAAAA==.',Ho='Holysprite:BAACKgAFFH8LAAIIAAMI+QocIAB9AAAIAAMI+QocIAB9AAAqAAQKfzUAAggACAiSGb8RAOcBAAgACAiSGb8RAOcBAAEqAAUUBAgOAAkAqRIA.',Hy='Hyehyo:BAABKgAFFH8IAAIKAAgIOQjYBwCQAQAKAAgIOQjYBwCQAQAAAA==.',Ii='Iilidann:BAABKgAFFH8OAAMJAAMIqRLQEgCtAAAJAAMIqRLQEgCtAAALAAEIoQ3YKABBAAAAAA==.',Ir='Iris:BAAAKgAFFAMIAwAAAA==.',Iv='Ivanka:BAAAKgADCgMIAwAAAA==.',Ki='Kirafree:BAAAKgAFFAQIBAAAAA==.',La='Laputa:BAAAKgAECgIIAgAAAA==.',Le='Leonardo:BAAAKgAECgYIBgAAAA==.Leondavinc:BAABKgAECn8cAAICAAgI5yHgDACAAgACAAgI5yHgDACAAgAAAA==.',Li='Littles:BAAAKgAFFAYIAgABKgAFFAgIBgAMAF8hAA==.',Ma='Maybehappy:BAAAKgADCgQIBAAAAA==.',Mi='Missdk:BAAAKgAFFAQIBAAAAA==.',Mo='Moonboy:BAABKgAFFH8WAAMNAAgIHxi/BQBfAgANAAgIHxi/BQBfAgAKAAgIxQ5FBQCVAQAAAA==.',Na='Nafen:BAABKgAFFH8IAAIOAAgIKCMoAQDhAgAOAAgIKCMoAQDhAgAAAA==.',Ru='Ruxii:BAAAKgAECgQIBAAAAA==.',Sa='Sacredhealer:BAABKgAFFH8GAAMEAAYIVRZPEgDRAAAEAAQIoA9PEgDRAAADAAII2xeTFAC6AAAAAA==.',Sc='Scarletti:BAABKgAFFH8GAAMPAAYIBhoABADWAAAPAAQI4hUABADWAAAQAAIIPCCBHACmAAABKgAFFAgIBAARAAAAAA==.',Sh='Shadowdance:BAABKgAECn8XAAMSAAgIlhQrIgBkAQASAAcIthErIgBkAQATAAYI6xKdGwBKAQAAAA==.',Si='Sixbuffs:BAABKgAFFH8OAAMSAAgIJRBoBgAdAgASAAgIJRBoBgAdAgAUAAQIBQeVBwCTAAAAAA==.Sixmilk:BAABKgAFFH8wAAMDAAgImhOjAQDBAQADAAgImhOjAQDBAQAFAAgItQZoDgBDAQAAAA==.Sixwheel:BAABKgAFFH8SAAMBAAgIhBZJBQBOAgABAAgIhBZJBQBOAgAVAAQIzwO3LABgAAAAAA==.',St='Stevefox:BAABKgAFFH8GAAICAAYIMQnoKgA7AQACAAYIMQnoKgA7AQAAAA==.',Th='Thislaypain:BAABKgAFFH8IAAIWAAMIsRL3HgDYAAAWAAMIsRL3HgDYAAAAAA==.',Tr='Treasur:BAAAKgAECgEIAQAAAA==.',Va='Vanityhunter:BAAAKgADCggIEAAAAA==.',Wo='Wombat:BAAAKgAECgMIAwAAAA==.',Ya='Ya:BAAAKgAECgYICAAAAA==.',['一不']='一不拉稀莫奇:BAAAKgAFFAgIAgAAAA==.',['一听']='一听小可乐:BAAAKgADCgEIAQAAAA==.',['一念']='一念成佛:BAABKgAFFH8GAAIBAAYIjAScHgAqAQABAAYIjAScHgAqAQAAAA==.',['一枕']='一枕江风梦:BAACKgAFFH8KAAIXAAYIDhkJDwBwAQAXAAYIDhkJDwBwAQAqAAQKfxQAAhgACAg3Hzk5ABECABgACAg3Hzk5ABECAAAA.',['一环']='一环路:BAAAKgADCggICAAAAA==.',['一罐']='一罐小可乐:BAAAKgADCggICAAAAA==.',['一颗']='一颗小糖果:BAACKgAFFH8MAAIGAAMIyhTiHQCxAAAGAAMIyhTiHQCxAAAqAAQKfyYAAgYACAhzFxYnAMABAAYACAhzFxYnAMABAAAA.',['三氧']='三氧化硫:BAAAKgAECgMIAwAAAA==.',['不锈']='不锈钢漠漠:BAAAKgADCggICAAAAA==.',['丘比']='丘比特之臻:BAABKgAFFH8IAAIOAAgIVxKABwAHAgAOAAgIVxKABwAHAgAAAA==.',['丨和']='丨和光同尘丨:BAAAKgAFFAMIAwAAAA==.',['丨小']='丨小灬飛丨:BAABKgAECn8fAAISAAgIwiEVCgBwAgASAAgIwiEVCgBwAgAAAA==.',['临坛']='临坛竹:BAABKgAFFH8oAAISAAgIQCAWBABkAgASAAgIQCAWBABkAgABKgAFFAgIKgASAFseAA==.',['临江']='临江仙:BAABKgAFFH8FAAMZAAUILQxsCgDYAAAZAAQIiQ9sCgDYAAAaAAEIHAL0TQA5AAAAAA==.',['丶朝']='丶朝阳:BAABKgAFFH8IAAIIAAgI0h7wAgBZAgAIAAgI0h7wAgBZAgAAAA==.',['丿影']='丿影之哀伤:BAAAKgAECgQIBQAAAA==.',['乍见']='乍见鸷欢:BAAAKgAFFAMIAwAAAA==.',['乔布']='乔布斯的诺言:BAABKgAFFH8IAAMZAAIItw0zHQBJAAAZAAEIvhEzHQBJAAAaAAEIsQn3NgA2AAAAAA==.',['二环']='二环路:BAAAKgADCgEIAQAAAA==.',['云欣']='云欣:BAAAKgAECgQIBAAAAA==.',['亚空']='亚空瘴气丶:BAACKgAFFH8IAAIXAAQI3RFmMwCkAAAXAAQI3RFmMwCkAAAqAAQKfxsAAhcACAjVHCIVACgCABcACAjVHCIVACgCAAAA.',['仙瑶']='仙瑶月影:BAAAKgAFFAQIBAAAAA==.',['以太']='以太的旅人:BAAAKgADCgUIBQAAAA==.',['伊丽']='伊丽莎白奥妹:BAAAKgAECgMIAwAAAA==.',['伊利']='伊利達雷:BAAAKgAECggICAAAAA==.',['伍子']='伍子胥:BAABKgAECn8jAAIGAAgINxcdIwDaAQAGAAgINxcdIwDaAQAAAA==.',['但偏']='但偏偏雨渐渐:BAABKgAFFH8GAAISAAYInRV6CwCUAQASAAYInRV6CwCUAQAAAA==.',['你不']='你不要慌啊:BAAAKgAFFAQIBAAAAA==.你不要挊:BAABKgAFFH8GAAICAAYI/CMiFQCzAQACAAYI/CMiFQCzAQAAAA==.',['俺也']='俺也一样:BAABKgAFFH8GAAIWAAYIpBdtDACFAQAWAAYIpBdtDACFAQAAAA==.',['兔斯']='兔斯拉:BAAAKgADCggICAABKgADCggIEAARAAAAAA==.',['兜兜']='兜兜爱糖:BAAAKgAFFAMIAwAAAA==.',['全部']='全部释放:BAAAKgAECggICwAAAA==.',['冬季']='冬季的苍白:BAAAKgAECgcIDwAAAA==.',['冰霜']='冰霜紫菱:BAABKgAFFH8IAAIKAAQIJRjQGgDLAAAKAAQIJRjQGgDLAAAAAA==.',['冲锋']='冲锋感觉:BAACKgAFFH8SAAMWAAUIyxWUDwD8AAAWAAUIyBOUDwD8AAAQAAEICxEvGQBOAAAqAAQKfygAAxAACAgOIe8SACACABAABgjvH+8SACACABYABQh5GwVIAEgBAAAA.',['冷火']='冷火秋烟:BAAAKgAFFAQIBAAAAA==.',['别叫']='别叫法爷:BAAAKgAECgIIAgAAAA==.',['制裁']='制裁之刃:BAABKgAFFH8IAAIIAAQIbBu5BwDlAAAIAAQIbBu5BwDlAAAAAA==.',['北大']='北大路花火:BAAAKgAECgIIAgAAAA==.',['十万']='十万个地瓜:BAAAKgAECgYIBgAAAA==.',['十月']='十月的戒灵:BAAAKgAECgcICwAAAA==.',['南葑']='南葑:BAAAKgADCggIFQAAAA==.',['卫老']='卫老师唷:BAAAKgAFFAIIAgAAAA==.卫老师是我呀:BAAAKgAECgYICQAAAA==.',['却邪']='却邪:BAAAKgADCggICAAAAA==.',['又见']='又见小百事:BAACKgAFFH8bAAIBAAgI6QmhIQAVAQABAAgI6QmhIQAVAQAqAAQKfzEAAgEACAguG8wqAAsCAAEACAguG8wqAAsCAAAA.又见那夜雨:BAABKgAFFH8HAAIDAAcIVw8eCACgAQADAAcIVw8eCACgAQAAAA==.',['发神']='发神经:BAAAKgAECgIIAgAAAA==.',['叫俺']='叫俺尹志平:BAAAKgAECgEIAQAAAA==.',['叫我']='叫我蜂蜜大人:BAAAKgADCggICAAAAA==.',['叮当']='叮当猫:BAAAKgADCggIDAAAAA==.',['叶工']='叶工好龙:BAAAKgAECgIIAgAAAA==.',['吟慧']='吟慧:BAACKgAFFH8PAAIBAAQIYhBNMwDIAAABAAQIYhBNMwDIAAAqAAQKfy0AAgEACAgEGpsxALABAAEACAgEGpsxALABAAAA.',['吾心']='吾心舒出:BAAAKgAFFAQIBAAAAA==.',['咣咣']='咣咣怼脸上:BAABKgAFFH8XAAMOAAcIrxwhCAD+AQAOAAcIYRohCAD+AQAbAAUIOhstEQDZAAAAAA==.',['哈基']='哈基米德:BAAAKgAFFAIIAwAAAA==.',['哈大']='哈大滴:BAAAKgADCgEIAQAAAA==.',['哎呀']='哎呀灬有联盟:BAAAKgAECgEIAgAAAA==.',['哦吼']='哦吼耶:BAABKgAECn8eAAICAAgIwRwpFgAYAgACAAgIwRwpFgAYAgAAAA==.',['喂升']='喂升经:BAAAKgAECgYIDAABKgAECggIEgARAAAAAA==.',['善丶']='善丶果:BAABKgAFFH8FAAIZAAUI+hp+AAB4AQAZAAUI+hp+AAB4AQAAAA==.',['嘉嘉']='嘉嘉布卢迦:BAABKgAFFH8IAAIXAAgI4Q35BwC7AQAXAAgI4Q35BwC7AQAAAA==.',['回忆']='回忆很沉重:BAAAKgAECgcICwAAAA==.',['困兽']='困兽:BAAAKgADCgMIAwAAAA==.',['图腾']='图腾德妹:BAABKgAFFH8IAAIcAAgIWQ3vAwDmAQAcAAgIWQ3vAwDmAQAAAA==.',['圡人']='圡人:BAAAKgADCggICAAAAA==.',['圣光']='圣光之傲:BAAAKgADCggICAAAAA==.圣光是信仰丶:BAABKgAFFH8IAAICAAQIzyInOAALAQACAAQIzyInOAALAQAAAA==.圣光的戈门:BAAAKgAFFAIIAgAAAA==.',['地狱']='地狱战舰:BAAAKgAECgQIBAAAAA==.',['壹个']='壹个死骑:BAAAKgAFFAQIBAABKgAFFAgIBgAVABkJAA==.',['夏妲']='夏妲:BAAAKgAECgMIAwAAAA==.',['夏洛']='夏洛洛丶往昔:BAAAKgAFFAQIBAAAAA==.',['夏至']='夏至天蓝:BAAAKgAECgQIBQAAAA==.夏至末末:BAAAKgAECggIDwAAAA==.',['夜之']='夜之羽:BAACKgAFFH8TAAMXAAQI3xkEKADKAAAXAAQIYRcEKADKAAAYAAMInRSPNgC7AAAqAAQKfxwAAxcABwjkHpApAMIBABcABwizHpApAMIBABgABwjQGPt3AE0BAAAA.',['大大']='大大的二号:BAABKgAECn8cAAMNAAYI7AYymwCeAAANAAYI7AYymwCeAAAKAAYI7Aa3VQCOAAAAAA==.大大飞:BAAAKgAECggIEAAAAA==.',['大殺']='大殺四方:BAABKgAFFH8GAAILAAMI2RldJQDjAAALAAMI2RldJQDjAAAAAA==.',['大熊']='大熊帝:BAAAKgADCggICAAAAA==.',['大白']='大白:BAABKgAFFH8IAAIOAAgIcRE0CAD2AQAOAAgIcRE0CAD2AQAAAA==.大白兔奶糖:BAAAKgAFFAQIAgAAAA==.',['大胡']='大胡子叔叔:BAAAKgAECgQIBAAAAA==.',['大青']='大青龙汤:BAAAKgAECggIDwAAAA==.',['天地']='天地悠悠:BAAAKgAECgQIBAAAAA==.',['太子']='太子妃:BAAAKgAFFAYIAgAAAA==.',['太空']='太空仔:BAABKgAECn8eAAMKAAgIdBB7KwBQAQAKAAgIdBB7KwBQAQAdAAEI1QnnNwAZAAAAAA==.',['夯夯']='夯夯:BAAAKgAFFAQIAgAAAA==.',['奇奇']='奇奇格:BAAAKgAECggIDAAAAA==.',['奇行']='奇行种:BAABKgAFFH8GAAICAAYIvxQGGwCKAQACAAYIvxQGGwCKAQAAAA==.',['奇迹']='奇迹行者:BAAAKgAECgEIAQAAAA==.',['奥斯']='奥斯丁莱克:BAAAKgADCggICAAAAA==.',['奥莉']='奥莉斯汀:BAAAKgAECgQIBAAAAA==.',['奧爾']='奧爾良:BAABKgAFFH8FAAIBAAUI/BxwFwBhAQABAAUI/BxwFwBhAQAAAA==.',['女院']='女院门房德爷:BAAAKgADCggICAAAAA==.',['奶油']='奶油西米露:BAAAKgAECgEIAQAAAA==.',['姿那']='姿那诺:BAAAKgAFFAIIAwAAAA==.',['威少']='威少:BAAAKgAFFAEIAQAAAA==.',['婀洛']='婀洛伊:BAAAKgADCggICgAAAA==.',['宁馨']='宁馨儿:BAAAKgAECggICwAAAA==.',['安安']='安安崽:BAABKgAFFH8MAAIeAAYIKh7SBwCcAQAeAAYIKh7SBwCcAQAAAA==.',['宝轩']='宝轩很无聊:BAAAKgAFFAQIBAAAAA==.',['寂寞']='寂寞碎舞心:BAAAKgADCgQIBAAAAA==.',['小小']='小小烂仔头:BAAAKgAECgQIBAAAAA==.',['小桥']='小桥:BAAAKgAECgQIBgAAAA==.',['小漫']='小漫猫:BAAAKgAECgYICwAAAA==.',['小牛']='小牛圣骑:BAABKgAFFH8KAAICAAYIwxRUIwBeAQACAAYIwxRUIwBeAQAAAA==.',['小秀']='小秀才:BAAAKgAECgYIDgAAAA==.',['小红']='小红牛:BAAAKgAECgcIDAAAAA==.',['小趴']='小趴菜:BAAAKgAECgMIAwAAAA==.',['小蹄']='小蹄子不用桨:BAAAKgAECgUIBQAAAA==.',['小鸟']='小鸟酱:BAAAKgADCggICAAAAA==.',['少女']='少女榨汁机:BAABKgAECn8bAAIbAAgIZQxYOgANAQAbAAgIZQxYOgANAQAAAA==.',['已发']='已发育:BAAAKgADCggICAAAAA==.',['巴萨']='巴萨诺瓦:BAABKgAFFH8MAAIWAAYIxRw4CwCXAQAWAAYIxRw4CwCXAQABKgAFFAgIAgARAAAAAA==.',['布兰']='布兰克斯:BAAAKgAECgIIAgAAAA==.',['常熟']='常熟伍佰:BAAAKgAECgQIBgABKgAFFAgIBgAHAPgLAA==.常熟第一深情:BAAAKgAECgIIAgAAAA==.',['干了']='干了你之后:BAAAKgADCggICAAAAA==.',['幼儿']='幼儿园男老师:BAAAKgAECgQIBAAAAA==.幼儿园骑士:BAAAKgAECgYICQAAAA==.',['开始']='开始你的表演:BAABKgAFFH8GAAICAAYIwBonGACcAQACAAYIwBonGACcAQAAAA==.',['张鳗']='张鳗鱼:BAACKgAFFH8SAAICAAQICyXuKABEAQACAAQICyXuKABEAQAqAAQKfxYAAgIACAjmJT8HAPwCAAIACAjmJT8HAPwCAAAA.',['当个']='当个人吧:BAAAKgADCgYIBgAAAA==.当个萨满:BAAAKgADCgIIAgAAAA==.',['彩色']='彩色的黒:BAAAKgAECgQIBAAAAA==.',['影柒']='影柒:BAABKgAFFH8LAAMCAAYIOyD2KQA/AQACAAUIuCD2KQA/AQAfAAQImhUzDwDIAAAAAA==.',['往前']='往前有座宝山:BAAAKgAECgUIBQAAAA==.',['往来']='往来井井:BAAAKgAECgcIEwAAAA==.',['徐州']='徐州洛馍卷饼:BAAAKgAECgMIBAAAAA==.',['德克']='德克拉盖里:BAAAKgAECggICAAAAA==.',['德神']='德神归来:BAAAKgAFFAMIAwAAAA==.',['快疗']='快疗和驱散:BAAAKgADCggICAAAAA==.',['思念']='思念逆流成河:BAAAKgAFFAYIAwAAAA==.',['急救']='急救者:BAAAKgAECgUIBQAAAA==.',['性感']='性感小妈:BAAAKgADCggIEAAAAA==.',['恶魔']='恶魔在身边:BAAAKgAECggIDwAAAA==.',['想你']='想你的每一天:BAAAKgAECgMIAwAAAA==.',['愉悦']='愉悦滴忧伤:BAAAKgAFFAQIBAABKgAFFAgIBAARAAAAAA==.',['我即']='我即圣光:BAAAKgAECgEIAQAAAA==.',['我好']='我好像卡了:BAAAKgAFFAQIBAAAAA==.',['我是']='我是亮仔:BAAAKgAECgcIBwAAAA==.',['我来']='我来组成头部:BAACKgAFFH8YAAMgAAQIeh/zEQCwAAAaAAQIohEiKwDBAAAgAAMIXx/zEQCwAAAqAAQKfyoAAyAACAiSIXINACkCACAABwiRIXINACkCABoABwh/FFtBAGQBAAAA.',['我的']='我的璨然:BAAAKgAECgQICAAAAA==.我的野蛮酸奶:BAAAKgAECgEIAQAAAA==.',['打咩']='打咩打咩打咩:BAABKgAECn8XAAIGAAgIbhBeEgADAQAGAAgIbhBeEgADAQAAAA==.',['扬州']='扬州慢丶:BAAAKgADCggICAABKgAFFAgIBAARAAAAAA==.',['扶我']='扶我起来:BAACKgAFFH8QAAIIAAMInQzoEgBuAAAIAAMInQzoEgBuAAAqAAQKfxQAAggACAi3E/UmABwBAAgACAi3E/UmABwBAAAA.',['抖吱']='抖吱:BAAAKgAECggICAAAAA==.',['拂晓']='拂晓小恶魔:BAAAKgADCgMIAwAAAA==.',['拌饭']='拌饭:BAAAKgAECgEIAQAAAA==.',['拔娜']='拔娜娜:BAAAKgAECgcIBwAAAA==.',['放开']='放开那正太:BAAAKgAECgIIAgAAAA==.',['放掉']='放掉那个正太:BAAAKgADCgEIAwAAAA==.放掉那只正太:BAAAKgADCgEIBAAAAA==.',['斐戾']='斐戾:BAAAKgAECgYICwAAAA==.',['新巴']='新巴克:BAAAKgAECgMIAwAAAA==.',['无敌']='无敌奶爸:BAABKgAECn8ZAAICAAgICRvDOABFAgACAAgICRvDOABFAgAAAA==.',['无聊']='无聊一至极:BAAAKgADCgEIAQAAAA==.',['时髦']='时髦小神仙:BAAAKgAECgIIAgAAAA==.',['旺仔']='旺仔小天:BAAAKgAECgQIBAAAAA==.',['昆明']='昆明风:BAAAKgAECgcIEAAAAA==.',['時雨']='時雨丶:BAABKgAFFH8FAAIMAAQIfw9DIQDRAAAMAAQIfw9DIQDRAAAAAA==.',['晓晓']='晓晓:BAAAKgADCgEIAQAAAA==.',['普雷']='普雷尔踢:BAAAKgAECgQIBwAAAA==.',['景甜']='景甜:BAAAKgAECgIIAgAAAA==.',['暗夜']='暗夜妖艳:BAAAKgADCggICQAAAA==.暗夜小美:BAABKgAECn8bAAIBAAgItBPUOgCIAQABAAgItBPUOgCIAQAAAA==.',['暴暴']='暴暴有点虚:BAAAKgAECgUIDgAAAA==.暴暴术爷:BAAAKgAECgQIDAAAAA==.暴暴死灵骑士:BAAAKgAECgMIAwAAAA==.暴暴熊猫:BAAAKgADCggICAAAAA==.暴暴风云:BAAAKgAECgQICAAAAA==.暴暴风尘:BAAAKgADCggICAAAAA==.暴暴风沙:BAAAKgADCgIIAgAAAA==.暴暴风雨:BAAAKgAECgYIBwAAAA==.暴暴风骚:BAAAKgAECgYIBgAAAA==.暴暴龙在天:BAAAKgAECgQIBAAAAA==.',['曦钥']='曦钥:BAABKgAFFH8GAAIIAAYIIQtQBQAVAQAIAAYIIQtQBQAVAQAAAA==.',['曾經']='曾經的人族:BAAAKgAECgMIAwAAAA==.',['月读']='月读:BAAAKgAECgMIAwAAAA==.',['月野']='月野兔:BAACKgAFFH8FAAMKAAMIkxZvIACpAAAKAAII1B9vIACpAAANAAIIggxCTwB5AAAqAAQKfx4AAwoACAgKGocYANsBAAoACAgKGocYANsBAA0ABgjGGfROAHMBAAAA.',['有梦']='有梦就怕路远:BAAAKgAECgQIBAAAAA==.',['李唐']='李唐李糖糖丶:BAACKgAFFH8SAAMIAAQIlBSvGACyAAAIAAQIlBSvGACyAAACAAMIEQl5ZgChAAAqAAQKfxsAAwgACAgZG1ElACkBAAgABgiHFVElACkBAAIABgh6GvamAAABAAAA.',['杰神']='杰神大妈:BAACKgAFFH84AAMYAAgIYxhXBwAKAgAYAAgIYxhXBwAKAgAXAAQIeQ3PNACfAAAqAAQKfzoAAxgACAiyIA4jAGkCABgACAiyIA4jAGkCABcAAQhpB06WAB4AAAAA.',['杺跳']='杺跳跳:BAAAKgAECgUIBQAAAA==.',['板甲']='板甲小脆皮:BAAAKgAECggICAAAAA==.',['极品']='极品护士:BAAAKgADCgEIAQAAAA==.',['林兒']='林兒:BAABKgAECn8kAAQEAAgIiRgoDgCyAQAEAAgIiRgoDgCyAQAFAAgIjhH8QAA2AQADAAIIHA4LbABYAAAAAA==.',['柳絮']='柳絮萦:BAABKgAFFH8HAAMXAAQIlSF8FwArAQAXAAQIlSF8FwArAQAYAAMIKw8VMgCUAAAAAA==.',['标星']='标星光:BAABKgAECn8cAAQfAAgI5h9uBgCFAgAfAAgI5h9uBgCFAgACAAII4xKj/wBwAAAIAAEIHQRYawAOAAAAAA==.',['梦游']='梦游的傻馒:BAAAKgAECggIEQAAAA==.',['棋棋']='棋棋格:BAAAKgAFFAQIBAAAAA==.',['椰奶']='椰奶凤梨:BAAAKgAECgcICQAAAA==.',['橙小']='橙小沫:BAAAKgAECgMIAwAAAA==.',['欢乐']='欢乐的锤锤:BAAAKgAECggIDAAAAA==.',['武英']='武英殿大学士:BAAAKgAFFAEIAgABKgAFFAgIEgACAJAWAA==.',['残酷']='残酷天使:BAAAKgAFFAIIAgAAAA==.',['毛毛']='毛毛爱小二:BAAAKgAFFAIIAgAAAA==.',['氤氲']='氤氲之雾:BAAAKgAECgIIAgAAAA==.',['水墨']='水墨清:BAAAKgAECggICAAAAA==.水墨濪:BAAAKgAECgUIBQAAAA==.水墨青:BAABKgAECn8VAAIbAAgIDh2jGwAnAgAbAAgIDh2jGwAnAgAAAA==.',['水月']='水月:BAACKgAFFH8MAAICAAYIkh/iDADUAQACAAYIkh/iDADUAQAqAAQKfzEAAgIACAiYIhQIAL0CAAIACAiYIhQIAL0CAAAA.',['汐水']='汐水如墨:BAAAKgAFFAIIAgABKgAFFAQIDgAJAKkSAA==.',['沙恩']='沙恩萨斯特:BAAAKgAECggICAAAAA==.',['没毛']='没毛:BAABKgAFFH8FAAIdAAMIMwGRDgA0AAAdAAMIMwGRDgA0AAAAAA==.',['沿途']='沿途右旋:BAABKgAFFH8QAAMIAAYINBEhAwBLAQAIAAYINBEhAwBLAQACAAQI/Ba3HQDuAAAAAA==.',['泠冷']='泠冷儿:BAAAKgAECgQIBQAAAA==.',['泰吾']='泰吾:BAAAKgADCgEIAQAAAA==.',['泰瑞']='泰瑞尔丶破晓:BAAAKgAFFAgIAgAAAA==.',['洗剪']='洗剪吹染焗烫:BAAAKgADCgEIAQAAAA==.',['洛馍']='洛馍卷肉:BAAAKgADCgMIBAAAAA==.',['浅倉']='浅倉南:BAAAKgADCggICAAAAA==.',['浅听']='浅听枫吟:BAABKgAFFH8LAAIBAAYIpSGKCwDVAQABAAYIpSGKCwDVAQAAAA==.',['海洋']='海洋不是羊:BAAAKgAECgYIBgAAAA==.',['涵姐']='涵姐姐:BAAAKgAECgcICQAAAA==.',['清淵']='清淵煙寂:BAAAKgAFFAEIAgAAAA==.',['渣渣']='渣渣非:BAAAKgAFFAQIBAAAAA==.',['湘胖']='湘胖子:BAABKgAFFH8GAAICAAYINhbOJgDXAAACAAYINhbOJgDXAAAAAA==.',['满江']='满江红:BAABKgAFFH8KAAMVAAYITQqSCgDZAAAVAAYInweSCgDZAAABAAQIbQoCFwCuAAAAAA==.',['滴血']='滴血残阳:BAAAKgAFFAIIAgAAAA==.',['澤風']='澤風大過:BAABKgAECn8UAAIGAAgIIx2ZDQA5AgAGAAgIIx2ZDQA5AgAAAA==.',['灬貂']='灬貂蝉:BAACKgAFFH8HAAIgAAQIJRIqBgAWAQAgAAQIJRIqBgAWAQAqAAQKfx8AAyAACAg4H6YJAFsCACAACAhbHqYJAFsCABoABAgVHOoxAEgBAAAA.',['灬阿']='灬阿爾薩斯灬:BAAAKgAECggIEwAAAA==.',['灬静']='灬静香源灬:BAAAKgAECgEIAQAAAA==.',['灰雾']='灰雾之殇:BAAAKgAFFAIIAgAAAA==.',['灵能']='灵能:BAAAKgAFFAgIBAAAAA==.',['热血']='热血猎神:BAACKgAFFH8LAAMYAAMISwcZIwCPAAAYAAMISwcZIwCPAAAXAAMI3wITQgBzAAAqAAQKfycAAxgACAgUEOJzAFgBABgACAgXD+JzAFgBABcABgi4CtVHAP4AAAAA.',['熊孩']='熊孩纸:BAAAKgAFFAYIBAAAAA==.',['熊猫']='熊猫不是猫:BAAAKgAECgYIDQAAAA==.熊猫圆滚滚:BAABKgAECn8cAAIYAAgIMhJrRwCKAQAYAAgIMhJrRwCKAQAAAA==.',['燃烧']='燃烧军团团长:BAACKgAFFH8FAAICAAMITRzgTQDTAAACAAMITRzgTQDTAAAqAAQKfxQAAgIACAghI9gZALACAAIACAghI9gZALACAAAA.',['燕同']='燕同心:BAABKgAFFH8qAAISAAgIWx5iAwB8AgASAAgIWx5iAwB8AgAAAA==.',['爆壳']='爆壳蟹:BAAAKgAECgYIBgAAAA==.',['爱之']='爱之修罗:BAAAKgAECggICAAAAA==.',['爱吃']='爱吃猫的鱼:BAAAKgAFFAgIBAAAAA==.',['爱的']='爱的火铳炮:BAAAKgAECggIEwAAAA==.',['牛妞']='牛妞公主:BAAAKgAECgQIBAAAAA==.牛妞王子:BAAAKgADCgMIAwAAAA==.',['牛爸']='牛爸爸:BAAAKgADCgEIAQAAAA==.',['牧有']='牧有治疗:BAAAKgAFFAYIBAAAAA==.',['狐大']='狐大娃:BAABKgAECn8aAAMGAAgI4gCImQAeAAAGAAcIggCImQAeAAAHAAEI9AEAAAAAAAAAAA==.',['猎王']='猎王:BAABKgAFFH8IAAIXAAgIZA59BwDJAQAXAAgIZA59BwDJAQAAAA==.',['猪八']='猪八戒酒:BAABKgAFFH8GAAIVAAYIVxIVDwAuAQAVAAYIVxIVDwAuAQAAAA==.',['王小']='王小萌:BAAAKgADCggICAAAAA==.',['玛依']='玛依娜:BAAAKgAECgQIBAAAAA==.',['瑞兹']='瑞兹:BAAAKgAECgMIBAAAAA==.',['生死']='生死由命:BAABKgAFFH8mAAICAAgIvh9+AwCsAgACAAgIvh9+AwCsAgAAAA==.',['电话']='电话沟通:BAAAKgAFFAQIBAAAAA==.',['男人']='男人老狗:BAAAKgAECgIIAgAAAA==.',['疯狂']='疯狂帽子:BAAAKgAECgEIAQAAAA==.疯狂打铁:BAAAKgAFFAQIBAAAAA==.',['瘦纳']='瘦纳乾坤:BAAAKgADCgEIAQAAAA==.',['白凤']='白凤九:BAAAKgAFFAcIBAABKgAFFAgICAAeALsbAA==.',['白虎']='白虎吐沫:BAAAKgAFFAYIAgAAAA==.',['百万']='百万大领主:BAAAKgAECgQIBAAAAA==.',['皮凉']='皮凉龙:BAABKgAFFH8LAAIhAAYIRxOBEQBLAQAhAAYIRxOBEQBLAQAAAA==.',['皮卡']='皮卡丢:BAAAKgAECggICQAAAA==.',['相当']='相当风韵:BAAAKgAFFAQIBAAAAA==.',['神圣']='神圣惩戒龙:BAABKgAFFH8GAAICAAQISh8tEgANAQACAAQISh8tEgANAQAAAA==.',['神燕']='神燕风雷:BAAAKgADCgUICAAAAA==.',['神说']='神说尼马了个:BAAAKgAECgQIBAAAAA==.',['神龙']='神龙孽凤:BAAAKgADCggICAAAAA==.',['禅武']='禅武踏风:BAAAKgAECgUIBgAAAA==.',['秋葵']='秋葵紫紫:BAAAKgAECgQIBAAAAA==.',['窝窝']='窝窝头一块捌:BAAAKgAECgEIAQAAAA==.',['竹影']='竹影清风:BAAAKgAECgUIBQAAAA==.',['笑忘']='笑忘书:BAAAKgAFFAMIAwABKgAFFAgIDgAaAPkhAA==.',['笙乄']='笙乄壹:BAABKgAFFH8HAAMEAAQIHBwKDQDyAAAEAAQIHBwKDQDyAAAFAAIIiQc0JgA8AAAAAA==.',['笙九']='笙九:BAAAKgAFFAYIBAAAAA==.',['第二']='第二条咸鱼:BAAAKgAFFAgIBAAAAA==.',['等到']='等到花開:BAABKgAFFH8KAAIiAAMIix7UBQAmAQAiAAMIix7UBQAmAQAAAA==.',['米兔']='米兔不是兔:BAAAKgAECggICQAAAA==.',['米饭']='米饭是菜:BAAAKgADCgQIBAAAAA==.',['糯米']='糯米兮兮:BAAAKgAFFAQIBAAAAA==.',['紅顏']='紅顏如霜:BAAAKgADCggICAAAAA==.',['純純']='純純欲動:BAAAKgAECgMIAwAAAA==.',['索拉']='索拉卡:BAAAKgAECgQIBAAAAA==.',['紫菱']='紫菱:BAABKgAFFH8IAAIXAAgIThKCBwDqAQAXAAgIThKCBwDqAQAAAA==.',['紫霞']='紫霞一仙子:BAACKgAFFH8JAAIbAAMIrhkCEADiAAAbAAMIrhkCEADiAAAqAAQKfy4AAhsACAhsIiwDALoCABsACAhsIiwDALoCAAAA.',['红眼']='红眼打火:BAABKgAECn8VAAMcAAgImAZkQwD6AAAcAAgImAZkQwD6AAAeAAcI5gSCgQCvAAAAAA==.',['纲手']='纲手:BAABKgAFFH8JAAIWAAgIZxmuAwCDAgAWAAgIZxmuAwCDAgAAAA==.',['给你']='给你一猫鞭:BAAAKgAECgYIBgAAAA==.',['美大']='美大汹:BAAAKgAECgYIBgAAAA==.',['翻斗']='翻斗花园徳哥:BAAAKgADCgEIAQAAAA==.',['老子']='老子信你的邪:BAAAKgAECggICAAAAA==.',['老玖']='老玖:BAACKgAFFH8IAAMWAAMIrhz7FQALAQAWAAMIrhz7FQALAQAQAAIIjwbyJABrAAAqAAQKfxgAAxAACAjoIroWANUBABAABwgIHroWANUBABYABwi3Il0aACYBAAAA.',['老财']='老财:BAAAKgAFFAEIAQAAAA==.',['聽雨']='聽雨:BAAAKgADCgIIAgAAAA==.',['肌肉']='肌肉神父老牛:BAAAKgAECgIIAgAAAA==.',['胆儿']='胆儿:BAABKgAFFH8IAAIDAAgIzBDcBAD3AQADAAgIzBDcBAD3AQAAAA==.',['背飞']='背飞凫:BAAAKgAFFAQIBAAAAA==.',['胡汉']='胡汉三:BAAAKgAFFAMIAwAAAA==.',['腋毛']='腋毛乱舞:BAACKgAFFH8IAAMeAAQIjAjuFwDFAAAeAAQIjAjuFwDFAAAcAAQIRgPEIAB4AAAqAAQKfyMAAxwACAilHmwjANUBABwACAilHmwjANUBAB4ACAg4GaI0ALQBAAAA.',['舞指']='舞指弹奏:BAAAKgAECgYIDQAAAA==.',['芥末']='芥末狼:BAAAKgAECggIEAAAAA==.',['苏丽']='苏丽珍:BAAAKgADCgQIBwAAAA==.',['茉茉']='茉茉菱菱:BAAAKgAFFAQIBAAAAA==.',['茜茜']='茜茜莉娅:BAABKgAFFH8GAAICAAYIRg85KQBCAQACAAYIRg85KQBCAQAAAA==.',['莫嘉']='莫嘉娜:BAAAKgAECgYICAAAAA==.',['菁媛']='菁媛:BAAAKgADCgYIBgAAAA==.',['菜就']='菜就躺下睡:BAAAKgAECgUIBQAAAA==.',['菜籽']='菜籽的老湿:BAAAKgAECggICAAAAA==.',['蒹葭']='蒹葭采采:BAAAKgADCgYIBgAAAA==.',['薇轩']='薇轩:BAAAKgAECgEIAQAAAA==.',['虚空']='虚空之触:BAAAKgAFFAQIBAAAAA==.',['蜥蜴']='蜥蜴必须死:BAACKgAFFH8mAAIhAAUIBxRDDwAfAQAhAAUIBxRDDwAfAQAqAAQKfy4AAiEACAiPHxYOAGECACEACAiPHxYOAGECAAAA.',['蠕虫']='蠕虫:BAAAKgAECggICAAAAA==.',['被秒']='被秒杀的帅哥:BAAAKgAFFAcIBAAAAA==.',['西玛']='西玛塔丶阿荔:BAAAKgADCggICAAAAA==.',['西非']='西非要西:BAAAKgAFFAQIBAAAAA==.',['要你']='要你小命三千:BAAAKgADCgYIBgAAAA==.',['誓言']='誓言无声:BAAAKgADCggICAAAAA==.',['變型']='變型伊蘭:BAAAKgAFFAEIAQAAAA==.',['诸位']='诸位听我一言:BAABKgAFFH8FAAINAAQIiQ8IHADPAAANAAQIiQ8IHADPAAAAAA==.',['豆沙']='豆沙逗豆豆:BAAAKgADCggICAAAAA==.',['豆豆']='豆豆逗豆沙:BAAAKgADCggIEAAAAA==.',['贝丶']='贝丶壳:BAAAKgAECggIAQAAAA==.',['起门']='起门拉人:BAAAKgADCgEIAQAAAA==.',['輪符']='輪符雨:BAAAKgADCgcIBwAAAA==.',['过氧']='过氧化酶:BAAAKgAECgMIAwAAAA==.',['近战']='近战是信仰丶:BAAAKgAECggIDQAAAA==.',['这个']='这个萨有点电:BAAAKgAFFAEIAQAAAA==.',['迷途']='迷途旧梦:BAAAKgAFFAUIAwABKgAFFAgIFAAOADQjAA==.',['透心']='透心凉灬:BAAAKgAECgYIBgAAAA==.',['逐日']='逐日伯爵:BAABKgAECn8WAAIUAAgIUBdIBwDfAQAUAAgIUBdIBwDfAQAAAA==.',['逝之']='逝之星辰:BAAAKgAECgQIBgAAAA==.',['遗忘']='遗忘者之殇:BAAAKgADCggIDgAAAA==.',['避税']='避税多就得查:BAAAKgAECgEIAQAAAA==.',['酸萝']='酸萝卜别吃丶:BAAAKgADCgIIAgAAAA==.',['醉逍']='醉逍遥:BAAAKgAECgUIBQAAAA==.',['重铸']='重铸恶魔之痕:BAAAKgAFFAQIBAAAAA==.',['野性']='野性不可驯服:BAAAKgADCggICAAAAA==.',['野野']='野野喔:BAAAKgAECggIEgAAAA==.',['金银']='金银财宝:BAAAKgAECgEIAQAAAA==.',['钟止']='钟止意难平:BAACKgAFFH8MAAMWAAMINAfdJwCrAAAWAAMIBgfdJwCrAAAQAAIIFQYPJQBpAAAqAAQKfxsAAxAABwiMEd8oAHMBABAABwhNEN8oAHMBABYABQjlD+RVAAMBAAAA.',['铁臂']='铁臂阿童木:BAAAKgAECggICAAAAA==.',['闪小']='闪小芳:BAABKgAFFH8FAAIXAAMIGQrMNgCZAAAXAAMIGQrMNgCZAAAAAA==.',['闪电']='闪电狐:BAAAKgADCgYIBgAAAA==.',['阳光']='阳光下的冰块:BAAAKgAECggIEAAAAA==.',['阿德']='阿德莱克:BAAAKgAECgMIAwAAAA==.',['阿斯']='阿斯卡:BAAAKgAECgUIBQAAAA==.',['阿柱']='阿柱:BAAAKgAECgUIBQAAAA==.',['阿格']='阿格莱雅:BAAAKgAECgQIBAAAAA==.',['陆柒']='陆柒捌带槽:BAABKgAFFH8KAAMIAAgIvyQ1AQDOAgAIAAgIvyQ1AQDOAgACAAII8BSbLQC5AAAAAA==.',['陇上']='陇上张不不:BAAAKgADCggIAgAAAA==.',['隐宗']='隐宗老鬼:BAAAKgAECggICAAAAA==.',['隨風']='隨風而逝:BAABKgAFFH8KAAMYAAYIaRu+EwBXAQAYAAYIeRO+EwBXAQAXAAQIDh9zIgDnAAAAAA==.',['雁山']='雁山之霭:BAAAKgAECgcIDQAAAA==.',['雨宫']='雨宫隼:BAAAKgAFFAYIAgAAAA==.',['雪奶']='雪奶的白子:BAAAKgADCgEIAQAAAA==.',['雾迷']='雾迷巫山:BAAAKgAECgQIAgAAAA==.',['露露']='露露缇娜:BAABKgAFFH8OAAIaAAgIYgxfDQC2AQAaAAgIYgxfDQC2AQAAAA==.',['青戈']='青戈:BAAAKgAECgEIAQAAAA==.',['面包']='面包丶童子:BAABKgAFFH8IAAIbAAgIbQ3tAgDsAQAbAAgIbQ3tAgDsAQAAAA==.',['颜色']='颜色丶岚:BAABKgAFFH8GAAIFAAYIchN+CQBAAQAFAAYIchN+CQBAAQAAAA==.',['风之']='风之慕语:BAABKgAECn8UAAMDAAcIHwwgPQD4AAADAAcIHwwgPQD4AAAEAAUIrQWyXAB8AAAAAA==.',['风吟']='风吟丶挽歌:BAAAKgAFFAgIAwAAAA==.',['风雪']='风雪星辰:BAABKgAECn8fAAIXAAgI6xxQHgDgAQAXAAgI6xxQHgDgAQAAAA==.风雪迹:BAAAKgAECggIEwAAAA==.',['飘飖']='飘飖兮若流风:BAAAKgAFFAEIAQAAAA==.',['飞翔']='飞翔:BAABKgAFFH8JAAIjAAQISRlKCADlAAAjAAQISRlKCADlAAAAAA==.飞翔归来:BAAAKgAFFAMIAwAAAA==.飞翔的犀牛:BAAAKgAECgQIBAAAAA==.',['馮婉']='馮婉貞:BAAAKgAFFAEIAQAAAA==.',['马东']='马东锡:BAAAKgADCggICAAAAA==.',['马保']='马保国丶:BAABKgAFFH8bAAIkAAYIDRkKBwCYAQAkAAYIDRkKBwCYAQAAAA==.',['高小']='高小恒:BAABKgAFFH8LAAILAAcIbBphBwApAgALAAcIbBphBwApAgAAAA==.',['魅力']='魅力小青龙:BAAAKgAECgIIAgAAAA==.',['魑魅']='魑魅蛊惑:BAAAKgAECgQIBAAAAA==.魑魅诱导:BAAAKgAECgYICQAAAA==.',['鱼小']='鱼小满:BAAAKgADCggIEAAAAA==.',['鸟飞']='鸟飞绝:BAABKgAECn8nAAMYAAgIhiB1EwCPAgAYAAgIhiB1EwCPAgAXAAEIIQ6krQAnAAAAAA==.',['鸡委']='鸡委发言人:BAACKgAFFH8KAAINAAQIqhqbKQDtAAANAAQIqhqbKQDtAAAqAAQKfxwAAw0ACAi6GtY3ANkBAA0ACAi6GtY3ANkBAAoAAQipA1qQACQAAAAA.',['麦芽']='麦芽:BAAAKgAECgMIBAAAAA==.',['麻雀']='麻雀:BAAAKgADCggICAAAAA==.',['黑妹']='黑妹儿:BAAAKgAECgYICQAAAA==.',['黑手']='黑手妖:BAAAKgAECgYIBwAAAA==.',['黑色']='黑色雨滴:BAAAKgAECggICAABKgAFFAgIDgAOACQgAA==.',['龍東']='龍東槍:BAACKgAFFH8kAAMNAAYIohN8FAAYAQANAAUIyRd8FAAYAQAlAAEIBQN7DQBBAAAqAAQKfykABA0ACAiWHxsxAOcBAA0ACAi3GxsxAOcBACUAAwieF/4bAMoAAAoABAiTCipSAJsAAAAA.',['龍躰']='龍躰被掏空:BAAAKgADCggIBgAAAA==.',['龍陀']='龍陀陀:BAAAKgAECgUICgAAAA==.',['龙冕']='龙冕:BAABKgAFFH8GAAIhAAYIDwa7EAACAQAhAAYIDwa7EAACAQAAAA==.',['龙牙']='龙牙鬼斩丨:BAAAKgADCgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end