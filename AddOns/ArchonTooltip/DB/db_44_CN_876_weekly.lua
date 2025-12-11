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
 local lookup = {'DeathKnight-Frost','Shaman-Elemental','Shaman-Enhancement','Unknown-Unknown','DeathKnight-Blood','Hunter-BeastMastery','DeathKnight-Unholy','Shaman-Restoration','Hunter-Marksmanship','DemonHunter-Havoc','Druid-Restoration','Druid-Balance','Evoker-Preservation','Evoker-Devastation','Warlock-Destruction','Mage-Arcane','Mage-Frost','Paladin-Protection','Warlock-Affliction','Warlock-Demonology','Warrior-Fury','Paladin-Retribution','Monk-Mistweaver','Paladin-Holy','Monk-Windwalker','Rogue-Subtlety','Druid-Guardian','Rogue-Outlaw','Priest-Holy','Priest-Shadow','DemonHunter-Vengeance',}; local provider = {region='CN',realm='雷霆之怒',name='CN',type='weekly',zone=44,date='2025-12-09',data={Al='Alon:BAAALAAECgcIBwAAAA==.',Ar='Arronshi:BAAALAAFFAQIBAAAAA==.',As='Astrovoyager:BAABLAAFFH8MAAIBAAYIFQcRQABAAQABAAYIFQcRQABAAQAAAA==.',Be='Believeme:BAAALAADCggICAAAAA==.Bellemere:BAAALAAECgYIBgAAAA==.',Br='Brigittede:BAAALAAFFAIIAgAAAA==.',Ch='Churchill:BAAALAAECgUIBQAAAA==.',Cj='Cjr:BAAALAAFFAMIAwAAAA==.',Dt='Dtllte:BAAALAADCgQIBAAAAA==.',En='Enhancement:BAACLAAFFH8MAAICAAUIJBZCIwAtAQACAAUIJBZCIwAtAQAsAAQKfxcAAwIACAhQHAoqAGwCAAIACAjAGgoqAGwCAAMABwgaGYERAMoBAAAA.',Fa='Facaishu:BAAALAAECgQIBAAAAA==.Favorite:BAAALAAFFAIIBAAAAA==.',Fk='Fkysowhat:BAAALAAECgYIBgAAAA==.',Fr='Fridays:BAAALAAECgQIBAAAAA==.',Gl='Glitch:BAAALAAFFAIIBAAAAA==.',Ji='Jinhsi:BAAALAAECgYICgABLAAFFAIIBAAEAAAAAA==.',Lo='Logan:BAAALAAECgYICQAAAA==.Lot:BAAALAAECgYIBgAAAA==.Lovemotto:BAAALAAECgcIEgAAAA==.',Me='Mercyde:BAAALAAFFAIIAgAAAA==.',Ne='Neon:BAAALAAECgYIEQAAAA==.',Ni='Nicebody:BAAALAAECgYIDQAAAA==.',Pl='Playerljtptl:BAAALAAECgEIAQAAAA==.',Re='Reaperde:BAACLAAFFH8OAAMFAAIIcAeXFABpAAAFAAIIcAeXFABpAAABAAEISAEvqwAeAAAsAAQKf0cAAwUACAhODiMYABQBAAUACAiaDCMYABQBAAEABQhTDY0mAQwBAAAA.Resurrection:BAAALAAECgYIBgAAAA==.Reze:BAABLAAFFH8GAAIGAAIITiMvMwC+AAAGAAIITiMvMwC+AAABLAAFFAIIBAAEAAAAAA==.',Sa='Saurfang:BAABLAAFFH8GAAMHAAIIjw5VFACHAAABAAIIgg7ccACQAAAHAAIIHgxVFACHAAAAAA==.',Tr='Tropical:BAAALAAFFAMIAgAAAA==.',Vn='Vn:BAAALAAECggICQAAAA==.',Ye='Yellowbaby:BAAALAAECgQIBgAAAA==.',['一原']='一原点一:BAAALAAECgcIAwAAAA==.',['一破']='一破灬晓一:BAAALAAECggICAAAAA==.',['一起']='一起去旅行:BAAALAADCggICAAAAA==.',['三体']='三体星人:BAABLAAFFH8IAAIIAAII+hm1TACFAAAIAAII+hm1TACFAAAAAA==.',['与子']='与子彤鉴:BAACLAAFFH8QAAIJAAIIqSbMEADkAAAJAAIIqSbMEADkAAAsAAQKf0cAAgkACAikJk4AABEDAAkACAikJk4AABEDAAAA.',['东北']='东北小术:BAAALAAECgIIAgAAAA==.',['东来']='东来也灬:BAAALAAFFAIIBAAAAA==.',['丨捌']='丨捌灵体育生:BAABLAAFFH8GAAIKAAYIeAqxJwBaAQAKAAYIeAqxJwBaAQAAAA==.',['丶摩']='丶摩斯:BAAALAADCggICAAAAA==.',['丶槿']='丶槿花:BAAALAAECgIIAgAAAA==.',['丶缺']='丶缺德:BAABLAAFFH8FAAMLAAIIEwL+XAA2AAALAAIIEwL+XAA2AAAMAAIIPghuPgAsAAAAAA==.',['丸子']='丸子花花德:BAAALAAFFAIIAgAAAA==.',['丹阳']='丹阳子:BAAALAAECgIIAgAAAA==.',['为爱']='为爱变坏了:BAAALAAECggIBgAAAA==.',['丿槿']='丿槿花:BAAALAAECgIIAwAAAA==.',['乌利']='乌利麻利:BAAALAAECgMIAwAAAA==.',['乌哭']='乌哭:BAACLAAFFH8GAAIBAAIIIw08cgCPAAABAAIIIw08cgCPAAAsAAQKfyYAAwEACAhqGOovALgBAAEACAhqGOovALgBAAUAAwhDBLUwADsAAAAA.',['乐融']='乐融融的梦:BAACLAAFFH8ZAAIGAAYIRRz2KQCRAQAGAAYIRRz2KQCRAQAsAAQKfxoAAwYABgigI4ktAAYCAAYABgigI4ktAAYCAAkAAQj0E1rGACoAAAAA.',['乳酪']='乳酪戯芢:BAACLAAFFH8OAAIFAAII7BHGEACCAAAFAAII7BHGEACCAAAsAAQKfz0AAgUACAg+G2UPAFsCAAUACAg+G2UPAFsCAAAA.',['二到']='二到家:BAAALAAECgYIDQAAAA==.',['二十']='二十个萨满:BAABLAAFFH8GAAICAAYI3wQ3KAAKAQACAAYI3wQ3KAAKAQAAAA==.',['云麟']='云麟栖泽:BAAALAAECgMIAwAAAA==.',['从小']='从小就很美:BAAALAAECgUIBQAAAA==.',['低语']='低语:BAAALAAECgYIBwAAAA==.',['你就']='你就是只咕咕:BAAALAAECgUIBQAAAA==.你就是只爬爬:BAACLAAFFH8VAAMNAAYIAxIKEAA0AQANAAUI7hEKEAA0AQAOAAUIXwtQEgDGAAAsAAQKfxgAAw0ACAgzFAMaAK0BAA0ABwjeEwMaAK0BAA4ACAjNEow4AG8BAAEsAAUUBggPAAMAQRkA.',['你爱']='你爱的小黄瓜:BAAALAAECgEIAQAAAA==.',['兜兜']='兜兜里藏信仰:BAAALAAFFAEIAQAAAA==.',['兜里']='兜里有熊:BAACLAAFFH8cAAIMAAYIXBmiDwB3AQAMAAYIXBmiDwB3AQAsAAQKfy0AAgwABwh2I+8VALUCAAwABwh2I+8VALUCAAAA.',['八级']='八级小狂枫:BAAALAAECggIEAAAAA==.',['八雲']='八雲紫:BAABLAAFFH8MAAIPAAYI+BLXGgBrAQAPAAYI+BLXGgBrAQAAAA==.',['六毛']='六毛:BAABLAAECn8UAAIQAAYIDBdteQCiAQAQAAYIDBdteQCiAQAAAA==.',['兮烂']='兮烂:BAABLAAFFH8KAAIRAAIIXRclFQCDAAARAAIIXRclFQCDAAAAAA==.',['冇伱']='冇伱旳未来:BAAALAAECgYIBgAAAA==.',['冬果']='冬果王:BAABLAAFFH8JAAMCAAUIKRAIMgCiAAACAAQIow0IMgCiAAAIAAMIhBIuQwCfAAABLAAFFAYIEwASAIoRAA==.',['冰落']='冰落无心:BAAALAAFFAIIBAAAAA==.',['别用']='别用鼠标点我:BAAALAADCgYIBgAAAA==.',['到哪']='到哪都是大哥:BAAALAAFFAQIBAAAAA==.',['剑舞']='剑舞乄影殇:BAAALAAECggICAAAAA==.',['包元']='包元天尊:BAABLAAFFH8GAAIPAAYIlRepKQB2AQAPAAYIlRepKQB2AQAAAA==.',['包来']='包来恩:BAABLAAFFH8KAAMTAAYI8xzoAwC4AAAPAAYIIhhgJwB/AQATAAIIjx7oAwC4AAAAAA==.',['包莱']='包莱蒽:BAABLAAFFH8SAAMPAAYIUyFMFQDkAQAPAAYIGyFMFQDkAQATAAIIfyRrAwDcAAAAAA==.',['化劲']='化劲马保国:BAACLAAFFH8SAAMUAAUIUBlpBgDVAAAUAAMI+SJpBgDVAAAPAAQIKxJlRgC6AAAsAAQKf04ABBQACAiGJnAAABADABQACAiGJnAAABADAA8ACAjpH4ceANUCABMAAQjPGmc4AE0AAAAA.',['化粪']='化粪池爆破手:BAAALAAFFAYIAgAAAA==.',['千寻']='千寻:BAAALAAECgYIBgAAAA==.',['千灵']='千灵灵:BAAALAAECgEIAQAAAA==.',['千门']='千门:BAAALAAECgcIBwAAAA==.',['千魔']='千魔:BAAALAAECgYICwAAAA==.',['半疯']='半疯半癫:BAAALAADCgIIAgAAAA==.',['卡壐']='卡壐鄔釲:BAAALAAECgIIAgAAAA==.',['双角']='双角红茶:BAAALAAECgYIBwAAAA==.',['古神']='古神守墓者:BAAALAADCgYIBgAAAA==.',['叽哩']='叽哩咕噜嚓:BAAALAAECgYIDAAAAA==.',['吉贝']='吉贝克之劍:BAABLAAFFH8FAAIVAAMIlg+fOQCQAAAVAAMIlg+fOQCQAAAAAA==.',['呆小']='呆小布:BAAALAAECgMIAwAAAA==.',['咕咕']='咕咕嘎嘎:BAAALAAECgcIEwAAAA==.',['咪咔']='咪咔莎:BAAALAAECggIDgAAAA==.',['嗑药']='嗑药丶:BAAALAADCgYIBgAAAA==.',['回忆']='回忆:BAAALAAECgcIEAAAAA==.',['圣义']='圣义:BAAALAAECgYIBgAAAA==.',['圣光']='圣光晒得:BAAALAAECgYIBwAAAA==.',['塞勒']='塞勒涅:BAAALAAFFAIIBAAAAA==.',['塞洛']='塞洛斯:BAABLAAECn8XAAIWAAgILyTXDwA8AwAWAAgILyTXDwA8AwAAAA==.',['墙面']='墙面上的黑白:BAAALAAECgMIAwAAAA==.',['壹丄']='壹丄生:BAAALAAECggIDQAAAA==.',['复仇']='复仇者联盟:BAAALAAECgQIDAAAAA==.',['外星']='外星人战神:BAAALAADCgIIAgAAAA==.',['夜阑']='夜阑兮:BAABLAAFFH8KAAIBAAgICB5uDgAkAgABAAgICB5uDgAkAgAAAA==.',['夢蝶']='夢蝶:BAAALAAECggIEgAAAA==.',['大人']='大人小样:BAABLAAFFH8GAAIKAAYIZhn0GgCgAQAKAAYIZhn0GgCgAQAAAA==.',['大地']='大地母亲:BAAALAADCgMIAwAAAA==.',['大神']='大神之路:BAAALAAFFAEIAQAAAA==.',['大肉']='大肉哥:BAAALAAECgYIBgAAAA==.',['大胖']='大胖子石头:BAAALAAECgIIAgAAAA==.',['大蝇']='大蝇子:BAABLAAFFH8HAAIKAAMIaRorGQAQAQAKAAMIaRorGQAQAQAAAA==.',['大豬']='大豬落玉盤:BAABLAAFFH8MAAIWAAYIqBKMHgB1AQAWAAYIqBKMHgB1AQAAAA==.',['大酋']='大酋长丶来子:BAAALAAECgIIAgAAAA==.',['天上']='天上有头牛:BAAALAAECgYIEgAAAA==.',['天使']='天使丶审判:BAAALAAECgYIDAAAAA==.',['天界']='天界自由:BAACLAAFFH8RAAMSAAUIURgfCwD1AAASAAUIWhMfCwD1AAAWAAIILSBJUgBUAAAsAAQKfxMAAhYABwigIA5iACYCABYABwigIA5iACYCAAAA.天界自由丶:BAABLAAFFH8HAAIQAAII+QTaZABrAAAQAAII+QTaZABrAAAAAA==.',['天禄']='天禄:BAABLAAFFH8KAAIXAAMIKQy+EQCgAAAXAAMIKQy+EQCgAAAAAA==.',['天降']='天降胖贼:BAAALAADCgIIAgAAAA==.',['好跟']='好跟土豪呀:BAAALAADCgQIBQAAAA==.',['孙越']='孙越:BAAALAAECgYIBgAAAA==.',['宋雨']='宋雨骑:BAABLAAFFH8GAAIYAAIIOxKmGwCSAAAYAAIIOxKmGwCSAAAAAA==.',['寒歌']='寒歌傲雪:BAAALAAECgYIEAAAAA==.',['射在']='射在你女脸上:BAAALAADCgEIAQAAAA==.',['小为']='小为爱:BAAALAAFFAIIAgAAAA==.',['小小']='小小伊卡洛斯:BAABLAAFFH8KAAIBAAYIKBOlNQBqAQABAAYIKBOlNQBqAQAAAA==.小小酱叔:BAAALAAECgUIBwABLAAFFAIIBgAYADsSAA==.',['小尾']='小尾巴丶球球:BAABLAAECn8fAAMZAAcIcBaNLgCYAQAZAAcIcBaNLgCYAQAXAAYI+gjsOQDjAAAAAA==.',['小心']='小心追云鬼:BAABLAAECn8WAAMWAAgIoBacWABaAQAWAAUIDx2cWABaAQASAAgILwuRIAAPAQAAAA==.',['小战']='小战很狂:BAAALAADCgYICwAAAA==.',['小橙']='小橙橙:BAAALAAECgIIAwAAAA==.',['小洛']='小洛:BAAALAAFFAIIBAAAAA==.',['小狗']='小狗:BAAALAAFFAIIBAAAAA==.',['小猪']='小猪腰子丶:BAAALAAFFAIIBAAAAA==.',['小箭']='小箭心伤:BAABLAAECn8ZAAIGAAgIRBAJagBxAQAGAAgIRBAJagBxAQAAAA==.',['小胖']='小胖熊:BAAALAAFFAIIAgAAAA==.小胖龙:BAAALAAECgYIBgAAAA==.',['小胡']='小胡子哥:BAAALAAECgYIBgAAAA==.',['尐了']='尐了辣了椒:BAACLAAFFH8jAAMYAAYIYRYrDwCaAQAYAAYIYRYrDwCaAQAWAAEI2QY0bABAAAAsAAQKfyEAAhgACAgFI/cBACIDABgACAgFI/cBACIDAAAA.',['尐歘']='尐歘歘:BAAALAAECgEIAQAAAA==.尐歘灬歘:BAAALAAECgYIBwAAAA==.',['尐灬']='尐灬歘歘:BAAALAAECgYIBgAAAA==.',['山君']='山君:BAAALAADCgMIBQAAAA==.',['山海']='山海淮南子:BAAALAAECgYICQAAAA==.',['峰中']='峰中追风:BAAALAADCgEIAQAAAA==.',['巧克']='巧克力甜甜圈:BAAALAAFFAIIAgAAAA==.',['年年']='年年岁岁念念:BAABLAAFFH8FAAIGAAUINRNTTgAbAQAGAAUINRNTTgAbAQAAAA==.',['幸玉']='幸玉强:BAABLAAFFH8FAAIaAAII2Rr+DwCdAAAaAAII2Rr+DwCdAAAAAA==.',['幽兰']='幽兰茗萫:BAAALAAECgYICwAAAA==.',['弑壆']='弑壆霊韵:BAAALAAFFAIIAgAAAA==.',['弓不']='弓不留行:BAABLAAFFH8GAAIJAAYIzRAHBgDHAQAJAAYIzRAHBgDHAQAAAA==.',['很犀']='很犀利:BAABLAAFFH8GAAMGAAIIyAx3YgCKAAAGAAIIyAx3YgCKAAAJAAEI3QFBOgAsAAAAAA==.',['御风']='御风踏雪:BAABLAAFFH8GAAIGAAYIjgCqxAAaAAAGAAYIjgCqxAAaAAAAAA==.',['德不']='德不常失:BAAALAAECgIIAgAAAA==.',['德艺']='德艺双鑫:BAAALAAECgUIBQAAAA==.',['恋灬']='恋灬霜:BAAALAAECgYIDQAAAA==.',['愤怒']='愤怒的影魔:BAAALAAECgEIAQAAAA==.愤怒的鲨鱼:BAABLAAFFH8bAAIGAAYIIByBJgCdAQAGAAYIIByBJgCdAQAAAA==.',['战尸']='战尸妹纸:BAAALAADCgEIAQAAAA==.',['战神']='战神归来:BAABLAAFFH8GAAIBAAMIMwXDZwB+AAABAAMIMwXDZwB+AAAAAA==.战神龙之舞:BAABLAAFFH8GAAIVAAIIpAdgVwBAAAAVAAIIpAdgVwBAAAAAAA==.战神龙舞:BAACLAAFFH8JAAIWAAIILAsMcgA9AAAWAAIILAsMcgA9AAAsAAQKfxgAAhYABwhOEO+kAK8BABYABwhOEO+kAK8BAAAA.',['手刃']='手刃降服重创:BAAALAAECgYICgABLAAFFAIICAABAJIeAA==.',['打工']='打工包三号:BAABLAAFFH8MAAMTAAYIVyCuAgAtAQAPAAUIGBl6NgA6AQATAAMIHR6uAgAtAQAAAA==.打工包贰号:BAABLAAFFH8LAAMPAAYICCLfHACwAQAPAAYIMh7fHACwAQATAAII/SN6AwDVAAAAAA==.',['拴柱']='拴柱:BAAALAAECgYICAAAAA==.',['据説']='据説真的有神:BAAALAAECggICAABLAAFFAYIBgAYAAEOAA==.',['搞快']='搞快点:BAAALAAECgYIBgABLAAFFAIIBgAYADsSAA==.',['擒兽']='擒兽:BAAALAAFFAIIAgAAAA==.',['敬愛']='敬愛以痛吻我:BAABLAAFFH8FAAIBAAMIHxJjKwDrAAABAAMIHxJjKwDrAAAAAA==.',['斗战']='斗战胜丶:BAAALAAECgYIBgAAAA==.',['无尽']='无尽夏:BAAALAAECgIIAgAAAA==.',['无影']='无影的柏芝:BAAALAAECgYIBgAAAA==.',['无忧']='无忧德:BAAALAAECgYICgAAAA==.',['无极']='无极魔尊:BAAALAAECgYIBgAAAA==.',['旧事']='旧事随风去:BAAALAAECgYIBgAAAA==.',['星辰']='星辰之恋:BAAALAAECgQIBgAAAA==.',['是小']='是小柒啊:BAABLAAFFH8JAAIIAAYIUQ31JwApAQAIAAYIUQ31JwApAQAAAA==.',['晓苹']='晓苹果:BAAALAADCgcIBwAAAA==.',['晚安']='晚安:BAABLAAFFH8GAAIGAAIIhh3SfABlAAAGAAIIhh3SfABlAAAAAA==.',['晴么']='晴么么:BAABLAAFFH8HAAIIAAIINRqLQQB/AAAIAAIINRqLQQB/AAAAAA==.',['晴雨']='晴雨丶:BAAALAAECgYIEgAAAA==.',['暗云']='暗云映月:BAAALAADCgEIAQAAAA==.',['暗度']='暗度陈仓:BAAALAAECgYIBgAAAA==.',['暗影']='暗影之翼:BAAALAADCgcICwAAAA==.',['曹丶']='曹丶孟德:BAAALAAFFAIIBAAAAA==.',['最后']='最后曙光:BAAALAADCgEIAQAAAA==.',['月半']='月半小月半:BAAALAAECgQIBAAAAA==.',['月魔']='月魔小猫:BAAALAAECgYIDwAAAA==.',['有德']='有德丨比有湿:BAABLAAFFH8IAAIbAAgIigFjDwAoAAAbAAgIigFjDwAoAAAAAA==.',['朢夢']='朢夢鑽實:BAAALAAECggICgAAAA==.',['未名']='未名:BAAALAADCggIDgAAAA==.',['术师']='术师不太冷:BAABLAAFFH8IAAIUAAII2RTeEQCgAAAUAAII2RTeEQCgAAAAAA==.',['杂兵']='杂兵清理器:BAAALAAECgcIEQAAAA==.',['李逵']='李逵:BAAALAAFFAIIAgAAAA==.',['条嘢']='条嘢太狼:BAAALAAECgUIBQAAAA==.',['林夕']='林夕:BAACLAAFFH8VAAIKAAYI0RL7HgCKAQAKAAYI0RL7HgCKAQAsAAQKfxUAAgoACAgOIc86AHQCAAoACAgOIc86AHQCAAAA.林夕灬梦:BAAALAAECgcIBwAAAA==.',['林宝']='林宝包:BAABLAAFFH8GAAIPAAYILR/iGADJAQAPAAYILR/iGADJAQAAAA==.',['枫晓']='枫晓萨:BAAALAAECgYIBgAAAA==.',['枭月']='枭月伊德:BAAALAAECgIIAgAAAA==.',['柔情']='柔情如此似火:BAABLAAFFH8JAAIKAAYIMRWxHQCRAQAKAAYIMRWxHQCRAQAAAA==.',['校服']='校服到婚纱:BAACLAAFFH8KAAIWAAII1SRNIADQAAAWAAII1SRNIADQAAAsAAQKfxkAAhYACAhdIG0UAGwCABYACAhdIG0UAGwCAAEsAAUUAggQAAkAqSYA.',['桀骜']='桀骜之鹿:BAAALAAECgYIBwAAAA==.',['桃楽']='桃楽思思丶:BAAALAAFFAMIAwAAAA==.',['桜崎']='桜崎雉禹:BAAALAAECgcIDgAAAA==.',['梦一']='梦一魇:BAAALAADCgYIBgAAAA==.',['梦魇']='梦魇祝福:BAAALAAECgUIBAAAAA==.',['森林']='森林之灵希亚:BAAALAADCggICAAAAA==.森林之王:BAAALAAECgUIBQAAAA==.',['欧蕾']='欧蕾欧蕾欧蕾:BAAALAAECgcICwAAAA==.',['歌谣']='歌谣丶:BAAALAAECgYIBgAAAA==.',['正义']='正义芝士:BAABLAAECn8TAAIcAAYIvBw1CgDXAQAcAAYIvBw1CgDXAQABLAAFFAgIPwAGANslAA==.',['死亡']='死亡缠绕:BAAALAAECgIIAgAAAA==.',['残月']='残月:BAAALAAFFAIIBAAAAA==.',['残风']='残风墨月:BAACLAAFFH8JAAMLAAIIEx4zNgCUAAALAAIIEx4zNgCUAAAMAAIIcgj1OAA2AAAsAAQKf0kAAwwACAhtGfwPAAkCAAwACAhtGfwPAAkCAAsABwjjGjBCANcBAAAA.',['毅枚']='毅枚窝窝:BAAALAAECgcIDwAAAA==.',['毛毛']='毛毛大网红:BAACLAAFFH8GAAIKAAIIIw9nSACTAAAKAAIIIw9nSACTAAAsAAQKfxYAAgoABghtHuB0ANsBAAoABghtHuB0ANsBAAAA.',['沉沦']='沉沦梦境:BAAALAAECgMIAwAAAA==.',['沙思']='沙思牛:BAAALAAECgYICAAAAA==.',['油腻']='油腻浪人:BAAALAAECggICgAAAA==.',['法丝']='法丝的发师:BAAALAAECgYIDQAAAA==.',['泡泡']='泡泡汐:BAABLAAFFH8OAAIWAAYIzRgzGgCLAQAWAAYIzRgzGgCLAQAAAA==.',['波澜']='波澜不惊:BAAALAAECgYIDQAAAA==.',['泪繖']='泪繖星辰:BAABLAAFFH8cAAIVAAYIBBdcGAChAQAVAAYIBBdcGAChAQAAAA==.',['洗刷']='洗刷刷:BAAALAAECgYIBgAAAA==.',['洛丹']='洛丹伦的挽歌:BAAALAAECgcIBwAAAA==.',['洪福']='洪福齐天:BAAALAADCgIIAgAAAA==.',['淘气']='淘气的团团:BAAALAADCgcIBwAAAA==.',['清风']='清风不解风情:BAACLAAFFH8KAAIWAAIIex79KQC1AAAWAAIIex79KQC1AAAsAAQKfxYAAhYACAjBImkXABgDABYACAjBImkXABgDAAAA.清风浮尘:BAACLAAFFH8JAAIGAAIIGSHyQQCjAAAGAAIIGSHyQQCjAAAsAAQKfxYAAgYACAi0IsQSABYDAAYACAi0IsQSABYDAAAA.',['火舞']='火舞冰山:BAAALAADCggIDwAAAA==.',['灬傲']='灬傲丨丗灬:BAAALAAECggIBAAAAA==.灬傲丶世灬:BAAALAAECggICAAAAA==.灬傲丶丗灬:BAAALAAECggIDgAAAA==.',['灬奎']='灬奎托斯灬:BAAALAAECgIIAgAAAA==.',['灬柚']='灬柚木提娜灬:BAAALAAECgIIAgAAAA==.',['灭神']='灭神天尊:BAAALAAECgYIBwAAAA==.',['灭血']='灭血小星彩:BAABLAAECn8UAAIWAAgI/xOeSACFAQAWAAgI/xOeSACFAQAAAA==.',['灰灬']='灰灬太狼:BAACLAAFFH8OAAIVAAIIyB0NKQCoAAAVAAIIyB0NKQCoAAAsAAQKfxcAAhUABgg8JeApAJUCABUABgg8JeApAJUCAAEsAAUUAggQAAkAqSYA.',['灰烬']='灰烬帝皇:BAAALAADCgQIBAAAAA==.',['牙膏']='牙膏丶:BAAALAAFFAEIAQAAAA==.',['牛不']='牛不留行:BAABLAAFFH8GAAIIAAYI4BR+CAC2AQAIAAYI4BR+CAC2AQAAAA==.',['牛人']='牛人:BAAALAAECgYIDAAAAA==.',['犇牛']='犇牛犇:BAAALAAECggICAAAAA==.',['犯困']='犯困小喵丶:BAAALAAECgYIBgAAAA==.',['狂蹬']='狂蹬自行车:BAAALAAECggICAAAAA==.',['狐狸']='狐狸尼克:BAACLAAFFH8IAAIIAAIIeiXHHADXAAAIAAIIeiXHHADXAAAsAAQKfx4AAggABwjUJZERAOECAAgABwjUJZERAOECAAAA.',['独照']='独照峨嵋峰:BAAALAADCgIIAgAAAA==.',['王不']='王不留行:BAAALAAECgYIBgAAAA==.',['王源']='王源:BAABLAAFFH8FAAIGAAIIoBY3iABLAAAGAAIIoBY3iABLAAABLAAFFAIIBgAYADsSAA==.',['珠宝']='珠宝袋:BAAALAAECgEIAQAAAA==.',['琼斯']='琼斯教授:BAAALAAECgQIBAAAAA==.',['瓜牛']='瓜牛:BAAALAAFFAMIAwAAAA==.',['瓦瑞']='瓦瑞安:BAAALAAECgcIBwAAAA==.',['生命']='生命树:BAAALAAECgEIAQAAAA==.',['畸形']='畸形突变体:BAAALAADCgYIBgAAAA==.',['白酒']='白酒醉蟹:BAAALAAFFAIIAgAAAA==.',['盈月']='盈月之末:BAAALAAECgMIAwAAAA==.',['盛夏']='盛夏之初:BAAALAAECgYIDgAAAA==.',['瞎眼']='瞎眼女孩:BAAALAAECgUIBQAAAA==.',['砍不']='砍不死的怪:BAABLAAFFH8SAAIBAAMIIRf4WwCbAAABAAMIIRf4WwCbAAAAAA==.',['破碎']='破碎光年:BAAALAAFFAIIBAAAAA==.',['硝酸']='硝酸柠檬:BAAALAADCgcIDQAAAA==.',['离人']='离人不挽丶:BAAALAAFFAEIAQABLAAFFAgICAAGAOEZAA==.',['究极']='究极暴龙:BAABLAAFFH8GAAMOAAIImBPZFwCUAAAOAAIImBPZFwCUAAANAAIIzgg7FgCAAAAAAA==.',['笨与']='笨与傻的故事:BAAALAAECgIIAgABLAAECggIDwAEAAAAAA==.',['糖三']='糖三角:BAAALAAFFAIIAgAAAA==.',['絶伦']='絶伦逸羣:BAAALAAFFAIIAgAAAA==.',['红尘']='红尘胧影:BAAALAAECgYIBgAAAA==.红尘魔术师:BAAALAADCgQIBAAAAA==.',['纣虎']='纣虎:BAAALAAECgEIAQAAAA==.',['绝二']='绝二十一:BAABLAAFFH8sAAIGAAgIsySzAQDxAgAGAAgIsySzAQDxAgAAAA==.',['耐法']='耐法兰圣辉:BAACLAAFFH8HAAIdAAIIBhAZPgBvAAAdAAIIBhAZPgBvAAAsAAQKfxoAAx4ACAi/FrUTALwBAB4ABwjFGLUTALwBAB0ABwg+GB1QAJYBAAAA.耐法兰拂尘:BAACLAAFFH8KAAIXAAIItxukEgCUAAAXAAIItxukEgCUAAAsAAQKfzQAAxkACAh7HHEGAF0CABkACAh7HHEGAF0CABcACAj6EvgPAK0BAAAA.耐法兰星陨:BAAALAAFFAIIAwAAAA==.',['肉冻']='肉冻大魔王:BAABLAAFFH8VAAIBAAcIIBUqHABAAQABAAcIIBUqHABAAQAAAA==.',['能黑']='能黑能白:BAAALAADCgIIAgAAAA==.',['腿毛']='腿毛缚绳师:BAAALAAFFAIIAgAAAA==.',['芜菁']='芜菁沙袋:BAAALAAECgYICAAAAA==.',['花与']='花与剑:BAAALAADCggICAAAAA==.',['花落']='花落:BAABLAAFFH8GAAIPAAIIzBBDQgCVAAAPAAIIzBBDQgCVAAAAAA==.',['芳叶']='芳叶:BAAALAAECgUIBQAAAA==.',['苹果']='苹果慕斯:BAAALAAECggIDwAAAA==.',['草莓']='草莓味地狱火:BAABLAAFFH8GAAIPAAIIORDGPwCYAAAPAAIIORDGPwCYAAAAAA==.',['菲蕾']='菲蕾雅:BAAALAAECgEIAQAAAA==.',['萨丶']='萨丶神:BAAALAADCggICAAAAA==.',['萨哈']='萨哈哈:BAABLAAFFH8GAAIIAAIIUhLKSABzAAAIAAIIUhLKSABzAAAAAA==.',['萨满']='萨满满:BAABLAAFFH8GAAIIAAII2wJFdgBCAAAIAAII2wJFdgBCAAAAAA==.',['萨西']='萨西摩尔:BAAALAAFFAIIAwAAAA==.',['落地']='落地舞雪:BAAALAAECgYIBwAAAA==.',['葬湮']='葬湮忁影:BAAALAAECgYIBgAAAA==.',['蛮力']='蛮力肉哥:BAAALAADCgIIAgAAAA==.蛮力肉肉:BAAALAADCgEIAQAAAA==.',['蝴蝶']='蝴蝶:BAAALAAECgcIBwAAAA==.',['血夜']='血夜:BAACLAAFFH9NAAMFAAgInCR1AAD2AgAFAAgInCR1AAD2AgABAAUI5xpEPABPAQAsAAQKfzcAAgUACAgaJqcAAA4DAAUACAgaJqcAAA4DAAAA.',['衞青']='衞青:BAAALAADCgMIAwAAAA==.',['见孤']='见孤不拜:BAAALAADCgUIBQAAAA==.',['见我']='见我不拜:BAAALAAECgYIBgAAAA==.',['见神']='见神龙:BAAALAAECgMIAwAAAA==.',['见者']='见者尽灭:BAAALAADCgUIBQABLAAFFAIIBAAEAAAAAA==.',['见郑']='见郑不拜:BAAALAADCgcIBwAAAA==.',['訷話']='訷話丶凹凸曼:BAABLAAFFH8ZAAIWAAYICw2hGwDrAAAWAAYICw2hGwDrAAABLAAECggIBwAEAAAAAA==.',['誓约']='誓约胜利:BAAALAADCggICQAAAA==.',['谜兔']='谜兔丶:BAAALAAECggICAAAAA==.',['谜情']='谜情丶:BAAALAAECggICwAAAA==.',['谜璐']='谜璐丶:BAABLAAECn8UAAQBAAgI5hbZmgDOAQABAAgILRXZmgDOAQAHAAQI7BASPgDqAAAFAAgIpAM5MwDkAAAAAA==.',['谜笙']='谜笙丶:BAAALAADCgUIBQAAAA==.',['豆包']='豆包小魔王:BAABLAAFFH8KAAIKAAYIWRjkIgB3AQAKAAYIWRjkIgB3AQAAAA==.',['豬姯']='豬姯寶氣:BAAALAAECgEIAQAAAA==.',['貔貎']='貔貎刄峫:BAAALAAECgYIBgAAAA==.',['败家']='败家火爆:BAAALAAECgUIBQAAAA==.',['贰丄']='贰丄蛋:BAAALAAFFAIIBAAAAA==.',['赛天']='赛天娇:BAAALAAECgYIDQAAAA==.',['赫尔']='赫尔利:BAABLAAFFH8IAAIKAAUIFAkWMgAKAQAKAAUIFAkWMgAKAQABLAAFFAYIEgAPAC8PAA==.',['轻风']='轻风物語:BAAALAAECgIIAgAAAA==.',['辉格']='辉格炮:BAAALAADCgQIBAAAAA==.',['达尔']='达尔文:BAABLAAFFH8SAAMPAAYILw89MQBWAQAPAAYILw89MQBWAQAUAAEIPAdOLgBHAAAAAA==.',['这就']='这就是自由么:BAAALAAECgYIBgAAAA==.',['这是']='这是自寻死路:BAAALAADCggICAAAAA==.',['逆天']='逆天亡战:BAAALAAECgYIBgAAAA==.',['邦桑']='邦桑迪之息:BAAALAAFFAIIBAAAAA==.',['邪能']='邪能丨马保国:BAAALAAECgYIBgAAAA==.',['都放']='都放弃速度死:BAAALAAFFAIIBAAAAA==.',['酥糖']='酥糖小萨:BAAALAAFFAIIBAAAAA==.酥糖小蝶:BAACLAAFFH8OAAIYAAII1QdOIgCCAAAYAAII1QdOIgCCAAAsAAQKf0gAAxgACAgmIC8GAKMCABgACAgmIC8GAKMCABYABgiECnCTANwAAAAA.',['重楼']='重楼:BAAALAAECgMICAAAAA==.',['钱兔']='钱兔无量丶:BAABLAAECn8fAAMKAAgI3hzMPABtAgAKAAgIYxzMPABtAgAfAAgI1A3fKABwAQAAAA==.',['闪电']='闪电贱:BAAALAADCgYIBgAAAA==.',['阳光']='阳光普照:BAAALAAECgIIAwAAAA==.',['阿仕']='阿仕匹灵:BAAALAAECgUIBQAAAA==.',['阿尔']='阿尔忒弥斯:BAAALAAFFAIIBAAAAA==.',['阿迷']='阿迷:BAAALAAECgUIBQABLAAFFAgIPwAGANslAA==.',['阿靓']='阿靓妹:BAAALAAFFAIIAgAAAA==.',['雪诺']='雪诺丶:BAAALAAECgUIBQAAAA==.',['雸言']='雸言乔川:BAAALAAECgYIBgAAAA==.',['霁月']='霁月柔心丶:BAAALAAECggIEAAAAA==.',['霚幻']='霚幻淺影:BAAALAAECgQIBAAAAA==.',['霸王']='霸王灬霸王:BAAALAAECgQICQAAAA==.',['青提']='青提:BAAALAADCgMIAwAAAA==.',['颅献']='颅献颅座:BAABLAAFFH8IAAMBAAIIkh7IQQCwAAABAAIIkh7IQQCwAAAHAAEIoAHkIAA6AAAAAA==.',['风之']='风之舞:BAABLAAECn8VAAMGAAcI6hdIZgB4AQAGAAcI6hdIZgB4AQAJAAEIzAbozAAiAAAAAA==.',['风间']='风间滄月:BAAALAAFFAIIAgAAAA==.',['餓死']='餓死鬼:BAAALAADCgIIAgAAAA==.',['饭米']='饭米粒儿:BAABLAAFFH8GAAIWAAYI9g4bHwBzAQAWAAYI9g4bHwBzAQAAAA==.',['饿魔']='饿魔之握:BAABLAAFFH8HAAIBAAcIqSASDQA1AgABAAcIqSASDQA1AgAAAA==.',['马匪']='马匪:BAAALAAECgUIBQAAAA==.',['魂牵']='魂牵的小猎:BAABLAAFFH8KAAIGAAUI4BIjVAAGAQAGAAUI4BIjVAAGAQAAAA==.',['鸭梨']='鸭梨山达:BAAALAAFFAEIAQAAAA==.',['鹰之']='鹰之怒:BAAALAADCgQIBAAAAA==.',['麦朵']='麦朵:BAAALAAFFAIIAgAAAA==.',['黎明']='黎明死星:BAACLAAFFH8fAAIBAAYIEBdPKQCWAQABAAYIEBdPKQCWAQAsAAQKfyAAAgEACAjOHZEVAD4CAAEACAjOHZEVAD4CAAAA.',['黑芝']='黑芝麻薯:BAAALAAECgYIBgAAAA==.',['黑飘']='黑飘雪:BAAALAADCgIIAgAAAA==.',['鼠鼠']='鼠鼠大运营:BAABLAAECn8WAAIKAAYIehQZsQBwAQAKAAYIehQZsQBwAQAAAA==.',['龙之']='龙之狂舞:BAAALAAFFAIIAwAAAA==.龙之舞:BAAALAAECgcIDQAAAA==.',['龙老']='龙老龙:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end