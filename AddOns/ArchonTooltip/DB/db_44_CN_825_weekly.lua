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
 local lookup = {'Shaman-Restoration','Shaman-Elemental','Priest-Shadow','Priest-Holy','DeathKnight-Frost','DeathKnight-Unholy','Paladin-Retribution','Mage-Frost','Mage-Arcane','Evoker-Devastation','Evoker-Preservation','Warrior-Protection','Warrior-Fury','Hunter-Marksmanship','Monk-Mistweaver','Rogue-Assassination','Hunter-BeastMastery','Druid-Restoration','DeathKnight-Blood','Paladin-Protection','DemonHunter-Havoc','Rogue-Subtlety','Paladin-Holy','Evoker-Augmentation','Druid-Guardian','Druid-Balance','Monk-Windwalker','Priest-Discipline','Mage-Fire','Monk-Brewmaster','Warlock-Destruction','Druid-Feral','Warlock-Demonology','Warlock-Affliction','Unknown-Unknown',}; local provider = {region='CN',realm='血羽',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aiyouou:BAABLAAFFH8VAAMBAAYIlBtQEQDbAQABAAYIlBtQEQDbAQACAAEI8wlHRQBDAAAAAA==.Aiyououmi:BAAALAADCgYIBgAAAA==.Aiyououmy:BAAALAAECggIDQAAAA==.Aiyouyoumn:BAAALAADCgIIAgAAAA==.',Al='Allurelove:BAAALAAECgcICgAAAA==.',Ar='Ardenrena:BAABLAAFFH8KAAMDAAIIOwfCJQB8AAADAAIIOwfCJQB8AAAEAAII8AAPTgBBAAAAAA==.',Bb='Bbudk:BAABLAAFFH8ZAAMFAAYI4CC5FQCbAQAFAAYI4CC5FQCbAQAGAAEIAhUXGABiAAAAAA==.Bbuqs:BAABLAAFFH8GAAIHAAIIthybKAC4AAAHAAIIthybKAC4AAAAAA==.',Bs='Bshadow:BAABLAAECn8hAAMIAAgIrR4rBgB1AgAIAAgIrR4rBgB1AgAJAAYI0Q6HVwClAAAAAA==.',Co='Corrup:BAAALAAECgYIBgAAAA==.',De='Destiny:BAAALAAECggICAAAAA==.',Ev='Evadu:BAAALAADCgYIBgAAAA==.',Fa='Fadaibeef:BAABLAAFFH8HAAIHAAQIEhQSMgD1AAAHAAQIEhQSMgD1AAAAAA==.Fadaichicken:BAABLAAFFH8NAAIJAAUI9g5PNAAsAQAJAAUI9g5PNAAsAQAAAA==.Fadaidragon:BAABLAAFFH8OAAMKAAUIGg9NEAAVAQAKAAUIGg9NEAAVAQALAAMIfQbQFwCMAAAAAA==.Fadaifish:BAABLAAFFH8GAAMMAAIIsRPxKgA6AAAMAAIIsRPxKgA6AAANAAIICQPNYwApAAAAAA==.Fadaihunt:BAABLAAFFH8IAAIOAAUIgw6qCgDxAAAOAAUIgw6qCgDxAAAAAA==.Fadaipanda:BAABLAAFFH8IAAIPAAIIJhKbFAB2AAAPAAIIJhKbFAB2AAAAAA==.Fadaipastor:BAABLAAFFH8GAAIEAAIIXQ+7PABxAAAEAAIIXQ+7PABxAAAAAA==.',Fu='Furiosd:BAAALAAFFAIIAgAAAA==.',Hi='Hideonbush:BAAALAAFFAIIAgAAAA==.',Hu='Hunterammy:BAAALAAECggICAAAAA==.',Ja='Jayden:BAAALAAECgYIBgAAAA==.',Ka='Katsumi:BAABLAAFFH8xAAINAAYIsSFZDQDwAQANAAYIsSFZDQDwAQABLAAFFAgINAAQAEkgAA==.',Ku='Kumo:BAAALAAFFAgIAgAAAA==.',La='Lawliet:BAAALAADCgQICAAAAA==.',Lc='Lclucifer:BAABLAAFFH8MAAIRAAIIpxV4VwCRAAARAAIIpxV4VwCRAAAAAA==.',Le='Lephistphele:BAAALAAECgYIBgAAAA==.',Li='Lifengzs:BAABLAAFFH8GAAIMAAYIFyK9BQDxAQAMAAYIFyK9BQDxAQAAAA==.',Lu='Luck:BAAALAAFFAIIAgAAAA==.Lugcy:BAABLAAFFH8KAAISAAIIfB82HgCqAAASAAIIfB82HgCqAAAAAA==.Luxshareict:BAAALAAFFAIIAgAAAA==.',Lz='Lzblood:BAABLAAFFH8bAAITAAgIwAUdCQCKAQATAAgIwAUdCQCKAQAAAA==.Lzpink:BAACLAAFFH8oAAMUAAYIeRvXBQAdAQAHAAYIeRt2FgCdAQAUAAYIJwjXBQAdAQAsAAQKfxQAAhQACAi6DmA+AEMBABQACAi6DmA+AEMBAAAA.',Ma='Martin:BAAALAAFFAIIBAAAAA==.',Me='Metalstorm:BAAALAAECgcIDgAAAA==.',Mi='Mizuki:BAABLAAFFH8kAAIVAAYIDySMCwARAgAVAAYIDySMCwARAgAAAA==.Mizukidk:BAABLAAFFH8pAAIFAAcIfB9lCQBlAgAFAAcIfB9lCQBlAgAAAA==.',Mo='Mourning:BAACLAAFFH8fAAMRAAYIxRcRFwBbAQARAAYIyhYRFwBbAQAOAAIIFxPjKgByAAAsAAQKfxQAAxEABgi6HGeNAMgBABEABgi6HGeNAMgBAA4ABggzB46ZAIkAAAEsAAUUCAg0ABAASSAA.',Nb='Nbdehunter:BAABLAAFFH8IAAIIAAgIHwKkIgAPAAAIAAgIHwKkIgAPAAAAAA==.',Ni='Nightdky:BAABLAAFFH8MAAIFAAYIOAmiPQBGAQAFAAYIOAmiPQBGAQABLAAFFAgINAAQAEkgAA==.',Oe='Oeoe:BAAALAAECgYIBgAAAA==.',Pl='Playersetpbc:BAAALAAECgUIBQAAAA==.',Ps='Psly:BAAALAAECgYIBgAAAA==.',Ry='Rye:BAAALAAECgYIEwAAAA==.',Si='Sickboy:BAAALAADCgMIAwAAAA==.',So='Socrazyman:BAAALAAFFAIIAgAAAA==.',Wa='Wayne:BAAALAAECgYICgAAAA==.',Xo='Xom:BAAALAAFFAIIBAAAAA==.Xopponent:BAAALAAECgYIBgAAAA==.Xorn:BAAALAAFFAIIBAAAAA==.',['一刀']='一刀阴死你:BAAALAAECgYIEgAAAA==.',['一只']='一只青团:BAABLAAFFH8QAAIRAAgI4AZvYADAAAARAAgI4AZvYADAAAAAAA==.',['一夜']='一夜飘零:BAAALAAECgMIAwAAAA==.',['一箱']='一箱染煞钱币:BAABLAAFFH8JAAIPAAMICQ8yEgCXAAAPAAMICQ8yEgCXAAAAAA==.',['一顿']='一顿仨馒头:BAACLAAFFH8LAAMLAAMIHx3fDQDKAAALAAIIICTfDQDKAAAKAAEIvguwHwA8AAAsAAQKfyIAAwsACAh7H/EGAMsCAAsACAh7H/EGAMsCAAoACAjqByZBAD0BAAEsAAUUAwgRAAQAkyIA.一顿俩鸡腿:BAACLAAFFH8RAAIEAAMIkyInEgAjAQAEAAMIkyInEgAjAQAsAAQKfyYAAgQABwgnJb8RANoCAAQABwgnJb8RANoCAAAA.',['七宗']='七宗罪灬恶魔:BAAALAAECgEIAQAAAA==.七宗罪灬狂:BAAALAADCgQIBAAAAA==.',['七月']='七月灬殇:BAAALAAFFAIIBAAAAA==.',['三去']='三去米青米申:BAAALAAECgEIAQAAAA==.',['三垚']='三垚:BAABLAAFFH8FAAIBAAMI0RPSHwDNAAABAAMI0RPSHwDNAAAAAA==.',['三笠']='三笠丶阿克曼:BAABLAAFFH8XAAMQAAUIuxpuBQCAAQAQAAUIRRZuBQCAAQAWAAIIexf+EgBLAAABLAAFFAgINAAQAEkgAA==.',['三郎']='三郎庙之王:BAAALAADCgQIBAAAAA==.',['不死']='不死骑士:BAABLAAFFH8GAAIFAAII8hm/TQCjAAAFAAII8hm/TQCjAAAAAA==.',['不能']='不能打不能抗:BAAALAADCgMIAwAAAA==.',['丝绒']='丝绒拿铁:BAAALAAECggICAAAAA==.',['丨吟']='丨吟灬天丨:BAABLAAFFH8SAAMHAAYIkxKKJwA/AQAHAAUI4RWKJwA/AQAXAAEIYwZxMAAzAAAAAA==.',['丨小']='丨小浣熊丨:BAAALAAFFAIIAgAAAA==.',['丨猎']='丨猎猎丨:BAAALAADCggICQAAAA==.',['丨魅']='丨魅灬影丨:BAAALAAFFAMIBAAAAA==.',['丶布']='丶布诺:BAABLAAECn8VAAIPAAcIbQzkHADrAAAPAAcIbQzkHADrAAAAAA==.',['丶浩']='丶浩然:BAAALAAFFAIIBAAAAA==.',['丶甲']='丶甲甲:BAABLAAFFH8UAAIPAAYIgBymBQD1AQAPAAYIgBymBQD1AQAAAA==.',['丷星']='丷星河:BAABLAAFFH8LAAIFAAYI+yLsEADMAQAFAAYI+yLsEADMAQAAAA==.',['为了']='为了忘却纪念:BAAALAADCggICAAAAA==.',['九思']='九思:BAAALAAECgIIAgAAAA==.',['也许']='也许可以:BAAALAAECgUICAAAAA==.',['二老']='二老表:BAAALAADCgQIBAAAAA==.',['云望']='云望舒:BAAALAAFFAIIAgAAAA==.',['五德']='五德会丶战:BAAALAAECggICAAAAA==.',['亢龙']='亢龙:BAABLAAECn8hAAIKAAYIsx72DwCbAQAKAAYIsx72DwCbAQAAAA==.',['今天']='今天下火雨:BAAALAAECgYIBgAAAA==.',['以下']='以下均不及格:BAAALAAECggICAAAAA==.',['伊垚']='伊垚:BAAALAAFFAMIAwAAAA==.',['伊格']='伊格尼丝:BAAALAAECggIEQAAAA==.',['休普']='休普诺斯:BAABLAAFFH8LAAISAAYIlyRKBAB2AgASAAYIlyRKBAB2AgAAAA==.',['众生']='众生同调奥秘:BAACLAAFFH8sAAMFAAgINCSyAAAOAwAFAAgIxiOyAAAOAwAGAAMIrh/ABQAaAQAsAAQKfxoAAwUACAhrJSU8AIwCAAUABwjuJSU8AIwCAAYAAwhtIo08APYAAAAA.',['优秀']='优秀的小满满:BAACLAAFFH8tAAIKAAgI5SKXAQCyAgAKAAgI5SKXAQCyAgAsAAQKfxcAAwoACAimF8MeACQCAAoACAi6FsMeACQCABgAAQjkC/YdACMAAAAA.',['低调']='低调丶萨满哥:BAAALAADCgQIBwAAAA==.低调是一种罪:BAAALAAFFAIIAgAAAA==.',['佐岸']='佐岸丨痴情:BAAALAAECgYIDAAAAA==.',['何来']='何来尘埃飞舞:BAAALAAECggICAAAAA==.',['余烬']='余烬之火:BAAALAAECgUIBQAAAA==.',['你们']='你们跑快点儿:BAABLAAFFH8GAAITAAYIQAQSEAD4AAATAAYIQAQSEAD4AAAAAA==.',['佬子']='佬子是光棍:BAAALAAFFAIIAgAAAA==.',['依然']='依然潇洒:BAABLAAFFH8UAAIHAAUIIxNZLAAjAQAHAAUIIxNZLAAjAQAAAA==.',['信我']='信我不超生:BAABLAAFFH8IAAIZAAIINAZ0EQAhAAAZAAIINAZ0EQAhAAAAAA==.',['借问']='借问酒家何处:BAAALAAECgIIAgAAAA==.',['做德']='做德要高调:BAAALAAECgUIBAAAAA==.',['停一']='停一下别打了:BAABLAAFFH8KAAINAAIIcA/GUQBDAAANAAIIcA/GUQBDAAAAAA==.',['傲气']='傲气残雨:BAAALAAECgUIBQAAAA==.',['元宝']='元宝:BAACLAAFFH9iAAIDAAgIAyOoAADuAgADAAgIAyOoAADuAgAsAAQKfxUAAgMACAjOJLUJACkDAAMACAjOJLUJACkDAAAA.',['元寶']='元寶:BAAALAAECgEIAQAAAA==.',['充电']='充电:BAABLAAFFH8GAAIEAAIIxwEdRABoAAAEAAIIxwEdRABoAAAAAA==.',['光头']='光头没毛:BAAALAAECgIIAgAAAA==.',['克里']='克里瑟历斯:BAAALAAFFAIIBAABLAAFFAgIGwATAPIcAA==.',['兎大']='兎大乖:BAAALAAFFAIIBAAAAA==.',['兎小']='兎小乖:BAABLAAECn8VAAIRAAYIJyCYXQAhAgARAAYIJyCYXQAhAgAAAA==.',['內个']='內个骑士:BAABLAAFFH8OAAIUAAII4gTpIAAqAAAUAAII4gTpIAAqAAAAAA==.',['全能']='全能牟牟牛:BAAALAAECgYICAAAAA==.',['八神']='八神嘉儿丶:BAABLAAFFH8jAAIRAAYIgBk6KgCMAQARAAYIgBk6KgCMAQAAAA==.',['公主']='公主的厷:BAAALAAECgYIDwAAAA==.',['六氟']='六氟化硫:BAAALAAECgEIAQAAAA==.',['兲遣']='兲遣:BAAALAAECggIDgAAAA==.',['兽花']='兽花灬绮罗生:BAAALAAFFAIIBAAAAA==.',['冥土']='冥土追魂:BAAALAAFFAIIAgAAAA==.',['冬日']='冬日暖阳啊:BAAALAAECgQIBAAAAA==.',['冰凝']='冰凝物语:BAAALAAECgcIDwAAAA==.',['冰封']='冰封雪恋:BAABLAAFFH8GAAIFAAYIrAw2QgAzAQAFAAYIrAw2QgAzAQAAAA==.',['冲锋']='冲锋我不亡:BAAALAADCggICwAAAA==.',['决战']='决战欧罗巴:BAAALAAECgEIAQAAAA==.',['冷锋']='冷锋:BAAALAAECgUIBQAAAA==.',['冻结']='冻结伤:BAAALAAECgMIAwAAAA==.',['凜冬']='凜冬:BAAALAAECgIIAgAAAA==.',['凝凝']='凝凝丶思念:BAAALAAECggICAAAAA==.',['刘春']='刘春的碟:BAAALAAECgYICAAAAA==.',['判屰']='判屰之刄:BAAALAAECgIIAgAAAA==.',['别乱']='别乱动:BAAALAAFFAIIAgAAAA==.',['剩界']='剩界王骑:BAAALAADCgEIAQAAAA==.',['十二']='十二载丶:BAABLAAFFH8MAAIQAAMIFxt2CwAOAQAQAAMIFxt2CwAOAQAAAA==.',['千里']='千里之目:BAAALAAECgIIAgAAAA==.',['午夜']='午夜心碎小熊:BAAALAAECggIEAAAAA==.',['半城']='半城飞花:BAAALAADCgUIBQAAAA==.',['卓哥']='卓哥卡奥:BAAALAAFFAIIAwAAAA==.',['单絮']='单絮:BAAALAAECggIEAAAAA==.',['南京']='南京九五:BAAALAAECgcIDQAAAA==.',['南天']='南天门计划:BAAALAAECgYIDgAAAA==.',['卤蛋']='卤蛋髭男:BAABLAAFFH8IAAINAAQIjRWlEQBYAQANAAQIjRWlEQBYAQAAAA==.',['原味']='原味绿皮肤:BAABLAAFFH8GAAINAAII1gJ5YQAxAAANAAII1gJ5YQAxAAAAAA==.',['双鱼']='双鱼座丶默默:BAAALAAECgYIDwAAAA==.',['发呆']='发呆牛肉:BAAALAAFFAIIAgAAAA==.',['古尔']='古尔旦:BAAALAADCgMIAwAAAA==.',['叶子']='叶子宝贝:BAAALAAFFAIIBAAAAA==.',['名字']='名字违规吗:BAAALAADCgIIAgAAAA==.',['听错']='听错了风:BAAALAAFFAIIAgABLAAFFAgIPgAYAOQkAA==.',['听风']='听风于野丶:BAABLAAFFH8FAAIBAAIIpiDdJwC1AAABAAIIpiDdJwC1AAAAAA==.',['吱吱']='吱吱:BAAALAAFFAIIAwAAAA==.',['吸血']='吸血鬼传说:BAAALAAECgUIBQAAAA==.',['呉朙']='呉朙丨二十:BAAALAAFFAgIBAAAAA==.呉朙丨二十一:BAABLAAFFH8GAAIEAAYIshuDFACyAQAEAAYIshuDFACyAQAAAA==.呉朙丨二十二:BAABLAAFFH8FAAIEAAUINxwDGACTAQAEAAUINxwDGACTAQAAAA==.呉朙丨二十六:BAABLAAFFH8GAAIEAAYIIxDGGgB6AQAEAAYIIxDGGgB6AQAAAA==.呉朙丨十九:BAABLAAFFH8GAAIEAAYIyRrwDAAAAgAEAAYIyRrwDAAAAgAAAA==.',['呦呦']='呦呦鹿鸣:BAACLAAFFH8eAAIHAAUILw/KLAAgAQAHAAUILw/KLAAgAQAsAAQKfz0AAgcACAh1INIZAEICAAcACAh1INIZAEICAAAA.',['咔咔']='咔咔小土豆:BAAALAAECgYIDAAAAA==.',['唰唰']='唰唰娃儿:BAABLAAFFH8KAAIVAAIIWwRiawAyAAAVAAIIWwRiawAyAAAAAA==.',['啊丶']='啊丶吴先森:BAABLAAFFH8GAAIaAAIIlR0dGACiAAAaAAIIlR0dGACiAAAAAA==.',['啪帕']='啪帕啪:BAAALAAECgYIDAAAAA==.',['喂我']='喂我花生:BAAALAAECgEIAQAAAA==.',['喵咕']='喵咕黎:BAABLAAFFH8SAAIZAAYIhQ73AwAUAQAZAAYIhQ73AwAUAQAAAA==.',['喵喵']='喵喵苗:BAAALAAECgQIBAAAAA==.',['喵大']='喵大人:BAAALAAFFAIIAgAAAA==.',['嘣嘣']='嘣嘣叭:BAABLAAFFH8IAAIRAAYIIB9LFACAAQARAAYIIB9LFACAAQAAAA==.',['噬血']='噬血天灾:BAAALAAECgYIBgAAAA==.',['回声']='回声鸭:BAAALAAECgMIAwAAAA==.',['国产']='国产丶小熊猫:BAABLAAFFH8IAAMbAAMIpRaTEACPAAAbAAMIpRaTEACPAAAPAAIIrgf5FwBfAAAAAA==.',['圆润']='圆润大王:BAAALAAECgYIDQAAAA==.',['圣光']='圣光灭亡:BAAALAAFFAIIBAAAAA==.',['地獄']='地獄咆哮:BAAALAAECgUIBQAAAA==.地獄獵人:BAAALAADCgEIAQAAAA==.',['坐忘']='坐忘道:BAAALAAFFAIIAgAAAA==.',['埋头']='埋头猛冲:BAAALAAFFAIIAQAAAA==.',['墩墩']='墩墩吖:BAAALAADCggICQAAAA==.',['声优']='声优都是怪物:BAABLAAFFH8GAAISAAIINyLxKgDFAAASAAIINyLxKgDFAAAAAA==.',['夏玛']='夏玛修:BAAALAAECgYIBgAAAA==.',['夜墨']='夜墨如歌:BAAALAAECgYIBgAAAA==.',['夜幕']='夜幕之血牙:BAAALAADCgIIAgAAAA==.',['夜空']='夜空最亮的星:BAABLAAECn8eAAIIAAYIbgkyLADOAAAIAAYIbgkyLADOAAAAAA==.',['夜落']='夜落空城:BAAALAAECgYIBgAAAA==.',['大哥']='大哥好得很呀:BAAALAADCgIIAgAAAA==.',['大地']='大地之环学徒:BAAALAAECgEIAQAAAA==.大地枝叶:BAABLAAFFH8IAAMBAAIIRA9HWwBlAAABAAIIRA9HWwBlAAACAAIISgnRSgA8AAAAAA==.',['大棕']='大棕师:BAAALAAFFAIIAgAAAA==.',['大猫']='大猫:BAAALAAECgEIAQAAAA==.',['大糯']='大糯糯:BAAALAADCgYICAAAAA==.',['大领']='大领主丶之怒:BAAALAAECgYIBgAAAA==.',['天天']='天天啃大骨头:BAAALAAECgUIBQAAAA==.',['天真']='天真骚年:BAAALAAECgYIBgAAAA==.',['天赋']='天赋型选手:BAABLAAECn8XAAIHAAgI9xfvLADgAQAHAAgI9xfvLADgAQAAAA==.',['天骑']='天骑士:BAABLAAFFH8GAAIHAAIIdxukNQCmAAAHAAIIdxukNQCmAAAAAA==.',['太空']='太空堡垒:BAAALAAFFAQIBAAAAA==.',['失落']='失落咆哮:BAAALAADCggICAAAAA==.',['头号']='头号大鸟:BAAALAAECgYIBgAAAA==.',['夸张']='夸张的微笑:BAAALAAFFAIIAgAAAA==.',['奈何']='奈何不能死:BAAALAAECgYIBwAAAA==.',['奈斯']='奈斯哦:BAAALAAFFAQIBAAAAA==.奈斯啊:BAABLAAFFH8JAAIBAAUI0w8LKwAPAQABAAUI0w8LKwAPAQAAAA==.',['奶一']='奶一下别看了:BAABLAAFFH8GAAIJAAIImBQpTwBPAAAJAAIImBQpTwBPAAAAAA==.',['奶糖']='奶糖卡布奇诺:BAABLAAFFH8GAAIcAAII2A+pAwCEAAAcAAII2A+pAwCEAAAAAA==.',['如梦']='如梦似幻:BAAALAADCggICQAAAA==.',['如薏']='如薏仐箍棒:BAAALAAECgQIBAAAAA==.',['妖厷']='妖厷墨羽:BAAALAAECgYIAwAAAA==.',['妲丨']='妲丨己:BAAALAAECgYIBwAAAA==.',['威尼']='威尼斯的水:BAAALAAECgYIBgAAAA==.',['娱乐']='娱乐角色:BAAALAAECgMIBQAAAA==.',['婉如']='婉如凝霜:BAAALAAFFAIIAgAAAA==.',['嫒尐']='嫒尐傑:BAAALAAFFAQIBAAAAA==.',['子了']='子了子了:BAABLAAFFH8GAAIRAAIIbA48pgA8AAARAAIIbA48pgA8AAAAAA==.',['孙小']='孙小美:BAAALAAECgQIBAAAAA==.',['孜然']='孜然风暴:BAABLAAFFH8KAAIBAAIIlCGJIwDBAAABAAIIlCGJIwDBAAABLAAFFAMIEQAEAJMiAA==.',['宁澜']='宁澜:BAABLAAFFH8KAAIFAAMIlwN3agBsAAAFAAMIlwN3agBsAAAAAA==.',['安東']='安東尼:BAAALAAFFAIIAgAAAA==.',['宋条']='宋条妍:BAAALAAECgIIAgAAAA==.',['宝宝']='宝宝引得怪:BAAALAAECgMIAwAAAA==.',['对对']='对对:BAAALAADCgMIAwAAAA==.',['射哪']='射哪儿呢:BAAALAAFFAIIAgAAAA==.',['将就']='将就加加血:BAAALAAECgYIDQAAAA==.',['小凌']='小凌丶:BAAALAAECgYIDQAAAA==.',['小学']='小学吃鲍鱼:BAAALAAFFAIIAgAAAA==.',['小时']='小时候浪:BAABLAAFFH8LAAIRAAUIsRIzJQDoAAARAAUIsRIzJQDoAAAAAA==.小时候狂:BAABLAAFFH8MAAIBAAUIcBgZIABcAQABAAUIcBgZIABcAQAAAA==.',['小熊']='小熊小羊:BAABLAAFFH8KAAQIAAQISA84EwBLAAAJAAMIgggKSwBuAAAIAAIIuBk4EwBLAAAdAAEI/QVLEQAAAAAAAA==.',['小蕙']='小蕙:BAAALAAECggICAAAAA==.',['小雨']='小雨一号:BAAALAADCgIIAwAAAA==.小雨四号:BAAALAADCgIIAgAAAA==.小雨滴答滴:BAAALAADCgEIAQAAAA==.',['小馬']='小馬爷:BAABLAAFFH8IAAIaAAYI1A9uFwAgAQAaAAYI1A9uFwAgAQABLAAFFAgINAAQAEkgAA==.',['尘缘']='尘缘不相误:BAAALAAECgIIAgAAAA==.',['尤菲']='尤菲如月:BAAALAAECgYIEgAAAA==.',['尸体']='尸体收割机:BAAALAAECgEIAQAAAA==.',['屁崩']='屁崩脚踏车:BAAALAAECggIDwAAAA==.',['居于']='居于不是积居:BAAALAAECgYIBgAAAA==.',['左手']='左手哈哈:BAAALAADCgEIAQAAAA==.',['布鲁']='布鲁的猎手:BAAALAAECggIAgAAAA==.',['帅的']='帅的不明显:BAAALAAFFAIIAgAAAA==.',['希尒']='希尒咓娜斯:BAAALAAECgYIDwAAAA==.',['希尔']='希尔丶:BAABLAAFFH8MAAIJAAYITyRADQAZAgAJAAYITyRADQAZAgAAAA==.希尔瓦叶斯:BAABLAAFFH8KAAIRAAQIsRVRXQDRAAARAAQIsRVRXQDRAAAAAA==.',['希格']='希格露恩:BAABLAAFFH8GAAMGAAIIRxdBEwBKAAAFAAIIZxOeggCFAAAGAAEI8xBBEwBKAAAAAA==.',['帕拉']='帕拉丁丶七段:BAAALAAECgQIBAAAAA==.',['带走']='带走你的灵魂:BAAALAAECgUICAAAAA==.',['幽瞳']='幽瞳蚀月:BAAALAAFFAIIAgAAAA==.',['弗洛']='弗洛伊德:BAAALAADCgYICgAAAA==.',['张果']='张果老:BAAALAADCggICAAAAA==.',['弩火']='弩火雷霆:BAAALAADCgIIAgAAAA==.',['强强']='强强战神:BAAALAAECgYIBgAAAA==.',['影灰']='影灰:BAAALAAECgUIBQAAAA==.',['影耀']='影耀之殇:BAAALAAECgYIBgAAAA==.',['彼岸']='彼岸丶星矢:BAAALAAFFAEIAQAAAA==.彼岸丶死骑:BAABLAAFFH8RAAIFAAUItxWKRQAmAQAFAAUItxWKRQAmAQAAAA==.彼岸丶神棍德:BAABLAAFFH8JAAISAAMIURtIJwDfAAASAAMIURtIJwDfAAAAAA==.彼岸有妞妞:BAABLAAFFH8FAAIFAAIIoBZEhABEAAAFAAIIoBZEhABEAAAAAA==.',['心静']='心静如麻:BAAALAADCggICAAAAA==.',['念白']='念白廿:BAABLAAFFH8IAAICAAcIGBFRCAD5AQACAAcIGBFRCAD5AQAAAA==.念白廿一:BAABLAAFFH8GAAICAAYIdQ8gHgBRAQACAAYIdQ8gHgBRAQAAAA==.',['怒焰']='怒焰追风:BAABLAAFFH8FAAIVAAMI8wKrRQBoAAAVAAMI8wKrRQBoAAAAAA==.',['怖小']='怖小布:BAAALAAECgQIBwAAAA==.',['性感']='性感的小眼睛:BAAALAAECgYICgAAAA==.',['怮傲']='怮傲孤訫:BAAALAAECgIIAgAAAA==.',['怼灬']='怼灬佛系兔:BAAALAAFFAIIAgAAAA==.',['恍若']='恍若隔世丶:BAACLAAFFH89AAIEAAYIBiGoCQAwAgAEAAYIBiGoCQAwAgAsAAQKfxcAAgQACAj/Fgk6APIBAAQACAj/Fgk6APIBAAAA.',['悲剧']='悲剧人物:BAAALAAFFAIIBAAAAA==.',['情义']='情义灬复仇:BAABLAAFFH8IAAIVAAIIOiDfLwCqAAAVAAIIOiDfLwCqAAAAAA==.情义灬猎爹:BAABLAAFFH8MAAIRAAYIBR5jIwCmAQARAAYIBR5jIwCmAQAAAA==.',['懒猫']='懒猫大神棍:BAAALAAECgYIDAAAAA==.',['我嗦']='我嗦叻蒜:BAAALAAECgcIEwAAAA==.',['我懷']='我懷念的:BAABLAAFFH8yAAQPAAYIzQ51CgBoAQAPAAYIzQ51CgBoAQAbAAUI9Ay+CwAZAQAeAAYIcwfiEwAJAQAAAA==.',['我看']='我看这个行:BAAALAAECgYICQAAAA==.',['我真']='我真的太难了:BAACLAAFFH8eAAIVAAcIMR11CABDAgAVAAcIMR11CABDAgAsAAQKfzMAAhUACAiJIPcWAA0DABUACAiJIPcWAA0DAAAA.',['我萨']='我萨:BAAALAAECgMIBQAAAA==.',['战吊']='战吊爱冲锋:BAABLAAFFH8GAAINAAIIFRc2LwCfAAANAAIIFRc2LwCfAAAAAA==.',['战斗']='战斗马里蛋:BAAALAAECggICAABLAAFFAgIFwACANUeAA==.',['战雕']='战雕:BAAALAAECgMIAwAAAA==.',['打死']='打死不耕田:BAAALAADCgYIBgAAAA==.',['打猎']='打猎的人:BAAALAAFFAIIAgAAAA==.',['抠鼻']='抠鼻星人:BAAALAAECgYIEAAAAA==.',['抹茶']='抹茶甜豆:BAAALAAFFAIIBAAAAA==.',['持剑']='持剑难诉离殇:BAACLAAFFH8HAAIFAAUIiAnvSQAPAQAFAAUIiAnvSQAPAQAsAAQKfxwAAgUABghKFnBQAFUBAAUABghKFnBQAFUBAAEsAAUUCAglAAcAsRQA.',['挖坑']='挖坑种活人:BAABLAAECn8ZAAIBAAYIIxtrKgDAAQABAAYIIxtrKgDAAQAAAA==.',['捏起']='捏起來肉肉哒:BAACLAAFFH9eAAQXAAgIaCUcAABNAwAXAAgIaCUcAABNAwAHAAUIER5mGACSAQAUAAYIgxErCAA9AQAsAAQKfxwAAxcACAgBJOQHAPACABcACAgBJOQHAPACAAcAAgi8GHhIAZ8AAAAA.捏起来肉肉哒:BAACLAAFFH87AAMPAAcILCN/AQCzAgAPAAcILCN/AQCzAgAbAAUITBiDCQBOAQAsAAQKfxUABA8ACAgyIcYUAC0CAA8ABgg9JMYUAC0CAB4AAgjHHdFBAIQAABsAAggLEgFdAHgAAAAA.',['摸头']='摸头点赞拒战:BAABLAAFFH8GAAIfAAIIHw1mRACSAAAfAAIIHw1mRACSAAAAAA==.',['文竹']='文竹:BAAALAADCgIIAgAAAA==.',['断一']='断一下别瘤了:BAAALAAFFAIIBAAAAA==.',['新疆']='新疆:BAABLAAFFH8GAAIHAAYIoxEuHgB0AQAHAAYIoxEuHgB0AQAAAA==.',['旋风']='旋风斩本斩:BAABLAAFFH8YAAINAAYIxh8QDwDgAQANAAYIxh8QDwDgAQABLAAFFAYIIQACABwjAA==.',['无幽']='无幽:BAAALAADCgQIBAAAAA==.',['无心']='无心:BAABLAAFFH8MAAIJAAYIiRaUJgB7AQAJAAYIiRaUJgB7AQAAAA==.',['无情']='无情风暴:BAAALAAECgYIBgAAAA==.',['时光']='时光流逝:BAAALAAECgIIAgAAAA==.',['昔何']='昔何:BAAALAAFFAIIBAAAAA==.',['星见']='星见雅:BAAALAAFFAIIBAAAAA==.',['晓炎']='晓炎:BAACLAAFFH8tAAIBAAYIuhlSEgDRAQABAAYIuhlSEgDRAQAsAAQKfxgAAwEACAieFJ9hAMUBAAEACAieFJ9hAMUBAAIAAgjLC0a+AGkAAAAA.',['晓猞']='晓猞猁:BAACLAAFFH8PAAIgAAQIhhN/CADHAAAgAAQIhhN/CADHAAAsAAQKfxkAAiAABwj7GI8XAO0BACAABwj7GI8XAO0BAAAA.',['晓表']='晓表弟:BAABLAAFFH8KAAIbAAII/xniFABJAAAbAAII/xniFABJAAAAAA==.',['晓龙']='晓龙:BAAALAAFFAYIBAAAAA==.',['晨曦']='晨曦守望:BAACLAAFFH8kAAMOAAUIHSL9BwCbAQAOAAUIPxn9BwCbAQARAAUI2CEIOABgAQAsAAQKfyUAAw4ABgjJJfQbAIUCAA4ABgj4JPQbAIUCABEABQj2JSVRAKIBAAAA.',['晴天']='晴天小小马:BAAALAADCgYIBgAAAA==.',['暗焰']='暗焰焚天:BAABLAAFFH8GAAIfAAMIAAR/UwBjAAAfAAMIAAR/UwBjAAAAAA==.',['暮光']='暮光浅语:BAAALAADCgYIBgAAAA==.',['暴力']='暴力的宝丽:BAAALAAECgYIEAAAAA==.',['曰仙']='曰仙:BAAALAAECgQIBgAAAA==.',['更木']='更木劍八:BAAALAAECgYIBgAAAA==.',['最后']='最后的教堂:BAAALAAFFAIIBAAAAA==.',['月亮']='月亮哥:BAABLAAFFH8IAAIFAAUIFxA6RQAnAQAFAAUIFxA6RQAnAQAAAA==.月亮阁:BAAALAAECgYIBgAAAA==.',['有点']='有点脾气:BAABLAAFFH8gAAMKAAYICB4ICACpAQAYAAYIShzkAwDBAQAKAAYIKRwICACpAQAAAA==.',['木小']='木小沫:BAABLAAFFH8FAAIHAAIIsQsAbwA/AAAHAAIIsQsAbwA/AAAAAA==.',['朴国']='朴国尝:BAAALAAECgYICQAAAA==.',['机智']='机智的小满满:BAAALAAECgYIBgABLAAFFAgILQAKAOUiAA==.',['李丹']='李丹丹保镖:BAABLAAECn8UAAIMAAcI7B6fHQBFAgAMAAcI7B6fHQBFAgAAAA==.',['李小']='李小玮:BAAALAAECgYIBgAAAA==.',['李达']='李达康:BAAALAAECgEIAQAAAA==.',['杜皮']='杜皮和帝皮:BAAALAAFFAIIBAAAAA==.',['来口']='来口芥末么:BAACLAAFFH8QAAIfAAYI2AuVGQB/AQAfAAYI2AuVGQB/AQAsAAQKfxYAAh8ABwjEHE8dAPoBAB8ABwjEHE8dAPoBAAAA.',['柳如']='柳如烟大帝:BAAALAAECgUIDgAAAA==.',['柳生']='柳生十兵卫茜:BAAALAAECgMIAwAAAA==.',['核桃']='核桃酥:BAAALAAECgIIAwAAAA==.',['桂花']='桂花树下:BAAALAAECggICAAAAA==.',['梦游']='梦游师:BAAALAAECgEIAQAAAA==.',['梦见']='梦见电子羊:BAAALAADCgYIBgAAAA==.',['梦醒']='梦醒时分:BAAALAAFFAIIBAAAAA==.',['梦魇']='梦魇破晓:BAACLAAFFH9pAAMbAAgIoyRmAADxAgAbAAgI7CJmAADxAgAeAAcINCQ+AgCEAgAsAAQKfxwAAxsACAiZJZ0IAAsDABsACAiZJZ0IAAsDAB4AAwhyHb4yAP0AAAAA.',['止殇']='止殇之光:BAAALAAECgYIDAAAAA==.',['武器']='武器防护狂暴:BAAALAAECgUIBQAAAA==.',['武魂']='武魂战魄:BAAALAAECgYIDAAAAA==.',['武魄']='武魄战魂:BAAALAADCgQIBAAAAA==.',['歪歪']='歪歪脖儿:BAAALAAECgYIDQAAAA==.',['毛毛']='毛毛熊:BAAALAAFFAIIBAAAAA==.',['氵莱']='氵莱因哈特彡:BAAALAAECgcIEQAAAA==.',['沃德']='沃德福德:BAABLAAECn8VAAISAAYIKRuQRgDIAQASAAYIKRuQRgDIAQAAAA==.',['沐雪']='沐雪微寒:BAACLAAFFH84AAIVAAgIWBylBgBuAgAVAAgIWBylBgBuAgAsAAQKfy0AAhUACAh1ImkGANQCABUACAh1ImkGANQCAAAA.',['沙白']='沙白填:BAAALAAECgcICgAAAA==.',['没事']='没事别瞎上:BAABLAAFFH8GAAIMAAMIEhLyIABzAAAMAAMIEhLyIABzAAAAAA==.没事瞎溜达:BAAALAADCgEIAQAAAA==.',['没减']='没减伤了:BAAALAAFFAIIAgAAAA==.',['没头']='没头脑:BAABLAAFFH8mAAIEAAYI/xsvDAAKAgAEAAYI/xsvDAAKAgAAAA==.没头脑呀:BAABLAAFFH87AAMHAAcI1iVHAgCcAgAHAAcI1iVHAgCcAgAUAAII8QokHABsAAAAAA==.',['没没']='没没木头:BAACLAAFFH81AAMSAAgIwCCUAQDtAgASAAgIwCCUAQDtAgAaAAEIlB78MwA8AAAsAAQKfxYAAhIABwjmIs4UALcCABIABwjmIs4UALcCAAAA.',['治愈']='治愈系芒果丶:BAABLAAFFH84AAMRAAgIZyJxAAD3AgARAAgIPCJxAAD3AgAOAAYIGB/yAwD6AQAAAA==.',['泡面']='泡面丶:BAAALAAECgEIAQAAAA==.',['波波']='波波丶奈奈酱:BAAALAAECgcICgAAAA==.',['泰兰']='泰兰徳丶语风:BAAALAAECgYIAwAAAA==.',['洛丹']='洛丹伦的太阳:BAABLAAFFH8GAAIQAAYI8gztCQB3AQAQAAYI8gztCQB3AQABLAAFFAgIDAAQADIiAA==.',['洛倾']='洛倾颜:BAAALAAECgYIBgAAAA==.',['济南']='济南王天放:BAAALAAFFAMIAwAAAA==.',['浩然']='浩然丶:BAAALAAECgEIAQAAAA==.',['海边']='海边微风起:BAAALAAFFAIIAgAAAA==.',['涅法']='涅法蕾姆:BAAALAAFFAIIAgAAAA==.',['涣然']='涣然冰凝:BAAALAAECgYICQAAAA==.',['淄博']='淄博赅溜子:BAAALAAFFAEIAQAAAA==.',['清风']='清风拂过:BAABLAAFFH8KAAIRAAIIWh0WSQCbAAARAAIIWh0WSQCbAAAAAA==.',['温拿']='温拿:BAAALAADCgQIBAAAAA==.',['湮沫']='湮沫:BAAALAAECggICAAAAA==.',['漂亮']='漂亮的回旋踢:BAAALAAFFAIIAgAAAA==.',['漩律']='漩律:BAAALAAECgQIBAAAAA==.',['潇湘']='潇湘剑雨:BAAALAADCgYIBgAAAA==.',['潇澜']='潇澜:BAACLAAFFH8GAAIVAAIICAXJWwB8AAAVAAIICAXJWwB8AAAsAAQKfxwAAhUACAiGGHpUACYCABUACAiGGHpUACYCAAAA.',['激渴']='激渴:BAACLAAFFH8FAAINAAMIshVPNwCWAAANAAMIshVPNwCWAAAsAAQKfxYAAg0ACAiHFz0gAO0BAA0ACAiHFz0gAO0BAAAA.激渴小龙人:BAAALAAFFAIIAgAAAA==.激渴白骑士:BAAALAAFFAIIBAAAAA==.激渴黑骑士:BAAALAAECgUIBQAAAA==.',['火云']='火云燃风:BAAALAAFFAIIBAAAAA==.',['灬惩']='灬惩戒骑灬:BAABLAAFFH8KAAIHAAIIIiSeSwBpAAAHAAIIIiSeSwBpAAAAAA==.',['灬莫']='灬莫奈灬:BAAALAADCgMIAwAAAA==.',['灬达']='灬达芬奇灬:BAAALAADCgYIBgAAAA==.',['灰太']='灰太狼:BAAALAAECgIIAgAAAA==.',['灰烬']='灰烬鼠者:BAABLAAFFH8FAAIHAAIIEBogOwCiAAAHAAIIEBogOwCiAAAAAA==.',['炮舰']='炮舰丶会卖萌:BAAALAAFFAIIBAAAAA==.',['炼狱']='炼狱久久:BAACLAAFFH88AAMJAAYI0iGrEwDeAQAJAAYI0iGrEwDeAQAIAAEImAR+IgA4AAAsAAQKfxUAAwgACAj4IMAlAPYBAAgABgjVIcAlAPYBAAkACAhFFZBxALYBAAAA.',['烈火']='烈火燎缘:BAAALAAECgYIBwAAAA==.',['烫头']='烫头王师傅:BAAALAAECgYIBgAAAA==.',['热风']='热风环流:BAAALAAECgQIBAAAAA==.',['焚烬']='焚烬:BAAALAADCgYIBgAAAA==.',['熊熊']='熊熊猫了丶:BAAALAAECgcICAAAAA==.',['燃星']='燃星:BAABLAAECn8jAAIHAAYIzw7PdgAUAQAHAAYIzw7PdgAUAQAAAA==.',['燃烧']='燃烧的稻草:BAABLAAFFH8GAAMNAAIIjA66XQA4AAANAAIIjA66XQA4AAAMAAEIggVzPQAAAAAAAA==.',['爆炸']='爆炸绵羊:BAAALAAECgYIBgAAAA==.',['爱吃']='爱吃小鱼干:BAAALAAFFAgIAgAAAA==.',['爱喝']='爱喝冰美式:BAAALAADCgEIAQAAAA==.',['版本']='版本答案:BAAALAAECggICAAAAA==.',['牛多']='牛多重:BAACLAAFFH8vAAMOAAcICR18AACLAgAOAAcIihp8AACLAgARAAQIYhkMIwD0AAAsAAQKfxcAAg4ACAiEIy8TAMoCAA4ACAiEIy8TAMoCAAAA.',['牛晓']='牛晓熊:BAABLAAFFH8aAAMSAAYIeAkNHwAsAQASAAYIeAkNHwAsAQAaAAII3AWBKAByAAAAAA==.',['牛牛']='牛牛信仰圣光:BAAALAAFFAEIAQAAAA==.',['特麽']='特麽劈我瓜:BAABLAAFFH8PAAIBAAMI2BiMNQDPAAABAAMI2BiMNQDPAAAAAA==.',['狂人']='狂人麦迪:BAACLAAFFH8+AAIRAAYIOh4nGgDOAQARAAYIOh4nGgDOAQAsAAQKfxgAAhEACAgTG6Z/AN8BABEACAgTG6Z/AN8BAAAA.',['狂暴']='狂暴手虫:BAAALAAECgYICgAAAA==.',['狐人']='狐人总冠军:BAACLAAFFH8zAAIBAAYI+yHtBwBFAgABAAYI+yHtBwBFAgAsAAQKfxQAAgEACAjWGBJXAOABAAEACAjWGBJXAOABAAAA.',['狡猾']='狡猾的狐狸:BAAALAADCgEIAQAAAA==.',['王不']='王不留行:BAABLAAFFH8PAAMGAAMIehWcBwD2AAAGAAMI2RScBwD2AAAFAAEI8RTjmwBMAAAAAA==.',['王子']='王子必须死:BAAALAAFFAIIAgAAAA==.',['王尿']='王尿性:BAABLAAFFH8zAAIFAAYICiI8EwD3AQAFAAYICiI8EwD3AQAAAA==.',['王栽']='王栽楞:BAACLAAFFH8iAAIRAAYIiCHRFQDlAQARAAYIiCHRFQDlAQAsAAQKfxkAAhEACAj1Ii8PAKkCABEACAj1Ii8PAKkCAAEsAAUUBggzAAUACiIA.',['玛蒂']='玛蒂尔兵棍儿:BAAALAADCgQIBAAAAA==.',['珠宝']='珠宝买买麦:BAABLAAECn8ZAAIBAAcIkAyBWAD+AAABAAcIkAyBWAD+AAAAAA==.',['瑞兹']='瑞兹:BAAALAAECgYIEAAAAA==.',['瑞德']='瑞德梦儿:BAABLAAFFH8oAAIRAAcIaiCFCABbAgARAAcIaiCFCABbAgAAAA==.瑞德萌儿:BAABLAAFFH8YAAIHAAYIah1KDwDMAQAHAAYIah1KDwDMAQAAAA==.',['瑞齐']='瑞齐:BAABLAAFFH8GAAIRAAYI0g14QQBDAQARAAYI0g14QQBDAQAAAA==.',['由加']='由加莉:BAABLAAFFH8qAAIHAAYI3SGFCwDpAQAHAAYI3SGFCwDpAQAAAA==.',['画甲']='画甲:BAAALAAFFAIIAgAAAA==.',['痞帅']='痞帅:BAABLAAFFH8GAAIHAAIIZQ1qZgBDAAAHAAIIZQ1qZgBDAAAAAA==.',['白釰']='白釰焰火:BAAALAAECgYICgAAAA==.',['百步']='百步穿杨:BAAALAAECgYIBgAAAA==.',['百花']='百花仙:BAAALAAECgEIAQAAAA==.',['皇城']='皇城冰魔:BAAALAAECgYIEwAAAA==.皇城宝少:BAAALAAECgYICAAAAA==.皇城少龙:BAACLAAFFH8FAAIVAAMIAQ0/QwB/AAAVAAMIAQ0/QwB/AAAsAAQKfxYAAhUABQjGDnd9ALIAABUABQjGDnd9ALIAAAAA.皇城月光:BAAALAAECgYIBgAAAA==.皇城魅影:BAAALAAECgMIAwAAAA==.皇城龙少:BAAALAAFFAIIAgAAAA==.',['皮兔']='皮兔叽:BAABLAAFFH8OAAIHAAYIDBIiHgB0AQAHAAYIDBIiHgB0AQAAAA==.',['皮叽']='皮叽兔:BAACLAAFFH9GAAIEAAcIQiT4AQDyAgAEAAcIQiT4AQDyAgAsAAQKfxUAAgQACAjnImIcAI8CAAQACAjnImIcAI8CAAEsAAUUCAhdAAEAdB0A.皮叽叽:BAACLAAFFH9dAAIBAAgIdB22AQBfAgABAAgIdB22AQBfAgAsAAQKfxgAAgEACAh3I4UZALUCAAEACAh3I4UZALUCAAAA.',['皮皮']='皮皮酷:BAABLAAFFH8GAAIEAAYIoQ8gGwB3AQAEAAYIoQ8gGwB3AQABLAAFFAgICAAEAHcWAA==.皮皮露:BAABLAAFFH8IAAIEAAYIdxaJGACOAQAEAAYIdxaJGACOAQAAAA==.',['相遇']='相遇在云端:BAAALAAECgQIBAAAAA==.',['眞祖']='眞祖將臣:BAAALAAECgQIBAAAAA==.',['眼镜']='眼镜琤琤亮:BAACLAAFFH8MAAIFAAIIwgPokwBuAAAFAAIIwgPokwBuAAAsAAQKfxwAAgUACAhVEcGQAN4BAAUACAhVEcGQAN4BAAAA.',['瞎眼']='瞎眼猎:BAAALAADCgYIEAAAAA==.',['矿石']='矿石终结者:BAABLAAFFH8KAAITAAIIDQk7HAAwAAATAAIIDQk7HAAwAAAAAA==.',['砍不']='砍不到人:BAAALAAECgYIBgAAAA==.',['破晓']='破晓之矢:BAACLAAFFH8PAAIOAAUIzxafCQASAQAOAAUIzxafCQASAQAsAAQKfy4AAg4ACAguIRoOAPICAA4ACAguIRoOAPICAAAA.',['碎星']='碎星:BAAALAAECgEIAQAAAA==.',['碧丽']='碧丽姐:BAAALAAECgYIEQAAAA==.',['祢豆']='祢豆子丶:BAACLAAFFH83AAIHAAYIGyOPDADgAQAHAAYIGyOPDADgAQAsAAQKfyQAAgcACAhQIx4WAB4DAAcACAhQIx4WAB4DAAAA.',['秦先']='秦先生:BAAALAAECgYIBgAAAA==.',['秦哥']='秦哥哥:BAAALAAFFAIIAgAAAA==.',['秦妈']='秦妈妈:BAACLAAFFH8GAAICAAII2BXOJACeAAACAAII2BXOJACeAAAsAAQKfxQAAgIABggsHphDAPcBAAIABggsHphDAPcBAAAA.',['秦媽']='秦媽媽:BAABLAAFFH8MAAIJAAIIlhlKSACYAAAJAAIIlhlKSACYAAAAAA==.',['秦某']='秦某:BAAALAAECgYIBgAAAA==.',['秦桑']='秦桑:BAAALAAECgYIBgAAAA==.',['笑面']='笑面狐:BAAALAAECgYICwAAAA==.',['等風']='等風也等你:BAAALAAECgYIEgAAAA==.',['筱月']='筱月儿:BAABLAAFFH8XAAIEAAYIQhPdFQClAQAEAAYIQhPdFQClAQAAAA==.',['米斯']='米斯思:BAABLAAFFH8yAAICAAcI8CGoBgBWAgACAAcI8CGoBgBWAgABLAAFFAgIYgADAAMjAA==.',['索尔']='索尔德林:BAAALAAFFAMIBAAAAA==.',['索沦']='索沦斯:BAABLAAECn8UAAIRAAYIJhX5vACDAQARAAYIJhX5vACDAQAAAA==.',['紫云']='紫云统夜:BAAALAAECggIAgAAAA==.',['紫色']='紫色纸鸢:BAACLAAFFH8jAAILAAYImyQOAQB5AgALAAYImyQOAQB5AgAsAAQKfzIAAgsACAirImYFAOsCAAsACAirImYFAOsCAAAA.紫色豆豆:BAAALAAECggICAAAAA==.',['红尘']='红尘续梦:BAAALAADCgIIAgAAAA==.',['细雨']='细雨纷霏:BAAALAADCgMIAwAAAA==.',['给个']='给个机会丶:BAAALAAFFAMIAwAAAA==.',['绣冬']='绣冬:BAAALAADCgQIBAAAAA==.',['绷不']='绷不住嘞:BAABLAAFFH8eAAIfAAgInhzxBABoAgAfAAgInhzxBABoAgAAAA==.',['缒路']='缒路:BAAALAAECggICAAAAA==.',['罪恶']='罪恶水果刀:BAAALAAFFAIIAgAAAA==.',['美味']='美味小脚:BAAALAADCgYIBgAAAA==.',['美拉']='美拉:BAAALAAECgUIBQAAAA==.',['翻墙']='翻墙头找红杏:BAAALAAECgUIBQAAAA==.',['翻滚']='翻滚吧兔宝宝:BAABLAAFFH8FAAIEAAIIISKEMQClAAAEAAIIISKEMQClAAAAAA==.',['老肩']='老肩巨滑:BAABLAAFFH8FAAMCAAUIKw1+NACNAAACAAMIHg5+NACNAAABAAIIFhKRVwBsAAABLAAFFAYIEwACALUbAA==.',['耳龙']='耳龙:BAABLAAFFH8+AAQYAAgI5CQTAQCXAgAYAAcIGSUTAQCXAgALAAcIrBf6AwDhAQAKAAQIPCGRDgA1AQAAAA==.',['聊疗']='聊疗你的心:BAAALAADCggIEAAAAA==.',['职业']='职业插棒棒:BAAALAAECgYICgAAAA==.',['聖光']='聖光無用:BAAALAAFFAIIBAAAAA==.',['肚皮']='肚皮君:BAABLAAFFH8MAAINAAYI7QuTIwBTAQANAAYI7QuTIwBTAQAAAA==.',['肥咕']='肥咕肥咕:BAACLAAFFH8NAAISAAMI4Q6FOQCHAAASAAMI4Q6FOQCHAAAsAAQKfxsAAhIABwg6GOY9AOgBABIABwg6GOY9AOgBAAAA.',['背刺']='背刺达人动视:BAABLAAFFH8IAAIRAAIIUhFEmQBBAAARAAIIUhFEmQBBAAAAAA==.',['背叛']='背叛圣光:BAAALAAFFAIIAgAAAA==.',['胖达']='胖达:BAAALAADCgMIAwAAAA==.',['胸小']='胸小还无脑:BAAALAAFFAIIAgAAAA==.',['臭屁']='臭屁月姐:BAAALAADCgUIBQAAAA==.',['艾德']='艾德里安娜:BAABLAAFFH8IAAIHAAIIpxX9QACdAAAHAAIIpxX9QACdAAAAAA==.',['芒果']='芒果呐丶:BAAALAAECgYICgAAAA==.芒果归来:BAAALAAECgYICQAAAA==.',['花儿']='花儿红:BAAALAAECgIIAgAAAA==.',['花甲']='花甲:BAAALAAFFAIIAgAAAA==.',['若心']='若心:BAAALAADCggICAAAAA==.',['若蓠']='若蓠:BAAALAADCgUIBQAAAA==.',['苦笑']='苦笑丶:BAAALAADCgMIAwAAAA==.',['茉莉']='茉莉雨:BAABLAAFFH8uAAQaAAgI1yBQAgCsAgAaAAgI1yBQAgCsAgASAAcIjRihCQAVAgAgAAMIMhkKBgD/AAABLAAFFAgIPgAYAOQkAA==.',['荳包']='荳包:BAAALAAFFAMIAwAAAA==.',['莳丶']='莳丶緔:BAAALAAFFAIIBAAAAA==.',['莼青']='莼青色灬:BAAALAAECgEIAQAAAA==.',['萌妹']='萌妹子潼潼:BAAALAAECgYIDgAAAA==.',['萌宝']='萌宝宝:BAAALAAECgUIBQAAAA==.',['萌萌']='萌萌小术:BAABLAAFFH8JAAIhAAMIrQ/WCQCEAAAhAAMIrQ/WCQCEAAAAAA==.',['萌面']='萌面大叔:BAABLAAFFH8FAAIMAAIIggj/KABsAAAMAAIIggj/KABsAAAAAA==.',['萝萨']='萝萨丽塔:BAAALAADCgIIAgAAAA==.',['萧逸']='萧逸血雨:BAAALAADCgYIBgAAAA==.',['落花']='落花踏尽:BAAALAAECgIIAgAAAA==.',['蓝娆']='蓝娆:BAAALAAECgYIBgAAAA==.',['蓝色']='蓝色妖姬:BAABLAAECn8bAAMJAAYI8w+KOwAfAQAJAAYIyQ+KOwAfAQAIAAEIfw9ASAAyAAAAAA==.',['蓝菱']='蓝菱儿:BAAALAADCgMIAwAAAA==.',['薄脆']='薄脆:BAAALAAECgUICQAAAA==.',['薄透']='薄透漏:BAABLAAFFH8MAAMQAAYIMiIpBAD9AQAQAAYIMiIpBAD9AQAWAAIIMhhIDgCtAAAAAA==.',['薯条']='薯条大人:BAAALAAECgYIBgAAAA==.',['虾炒']='虾炒肉丝:BAAALAADCgEIAQAAAA==.',['蛊毒']='蛊毒修罗:BAAALAAECgYIDQAAAA==.',['蜜蜂']='蜜蜂王:BAAALAADCgMIAwAAAA==.',['血中']='血中悍刀行:BAAALAAFFAEIAQAAAA==.',['血修']='血修冰骑士:BAABLAAFFH8NAAIFAAUIKw/cRwAcAQAFAAUIKw/cRwAcAQAAAA==.',['血小']='血小术:BAAALAADCgYIBgAAAA==.',['血祭']='血祭血神:BAABLAAFFH8hAAMCAAYIHCMGCgDeAQACAAUIpCMGCgDeAQABAAEI7B7TaABSAAAAAA==.',['血雨']='血雨爱丽丝:BAAALAAFFAIIAgAAAA==.',['衍月']='衍月:BAAALAADCgYIEQAAAA==.',['裁决']='裁决大神官儿:BAAALAAECgYIBgAAAA==.',['西咪']='西咪勾:BAAALAAECgYIAQAAAA==.',['西红']='西红柿炖牛腩:BAABLAAFFH8pAAIfAAYIvxXWIgCRAQAfAAYIvxXWIgCRAQAAAA==.',['要吃']='要吃牛牛奶吗:BAAALAADCgEIAQAAAA==.',['誰嗦']='誰嗦叻蒜:BAAALAAECgYIDAAAAA==.',['记忆']='记忆:BAAALAAECgcIDgAAAA==.',['诗人']='诗人的落寞:BAACLAAFFH8IAAMRAAIIZCAvNgC3AAARAAIIZCAvNgC3AAAOAAIINAjcLQBpAAAsAAQKfxQAAw4ABwhcHck6AM0BAA4ABgiuHck6AM0BABEABgizGGbqAEkBAAAA.',['语凝']='语凝:BAABLAAFFH8HAAIBAAIIgAe1awBPAAABAAIIgAe1awBPAAAAAA==.',['请叫']='请叫我阿山:BAAALAADCggICAAAAA==.',['豪豬']='豪豬吉列姆:BAACLAAFFH9oAAQfAAgI+yYOAAA5AwAfAAgI+yYOAAA5AwAiAAQI/CO7AAC2AQAhAAMIxCaOBQDpAAAsAAQKfxoAAx8ACAh8JvQIAFADAB8ACAh8JvQIAFADACIABggvGsYNANQBAAAA.',['贝簏']='贝簏丹尼:BAAALAAFFAEIAQAAAA==.',['贝罗']='贝罗妮卡:BAAALAAECgYIDAAAAA==.',['贝露']='贝露丹蒂:BAAALAAECgYICgAAAA==.',['赖皮']='赖皮蛇:BAAALAADCgUIBQAAAA==.',['赤炎']='赤炎马:BAACLAAFFH80AAMQAAgISSAxAQC/AgAQAAgIQyAxAQC/AgAWAAMIQR5TDQCkAAAsAAQKfxwAAxAACAi0IdcOALECABAACAgxINcOALECABYAAwj5Fr86AMUAAAAA.',['赤焰']='赤焰馬:BAAALAAECgMIBAAAAA==.赤焰马:BAABLAAFFH8cAAMfAAYIFBjXJACIAQAfAAYIFBjXJACIAQAhAAIIUAjcGgCMAAABLAAFFAgINAAQAEkgAA==.',['赤色']='赤色天下:BAAALAAECgYIDwAAAA==.',['越射']='越射越开心:BAAALAADCgMIAwAAAA==.',['路南']='路南十叁:BAABLAAFFH8NAAIBAAMI8RanNQDPAAABAAMI8RanNQDPAAAAAA==.',['身是']='身是心的囚笼:BAAALAAECgYIBgAAAA==.',['轉角']='轉角撞到牛:BAABLAAFFH8IAAINAAIIzggvVgBAAAANAAIIzggvVgBAAAAAAA==.轉角撞见牛:BAAALAAECgYIDQAAAA==.',['转一']='转一下别毛了:BAAALAAECgYICwAAAA==.',['辛达']='辛达苟萨灬灬:BAABLAAFFH8LAAMFAAIIrxjWUQCgAAAFAAIIaBfWUQCgAAATAAEIzxZCFwBLAAAAAA==.',['达瓦']='达瓦里氏:BAAALAAFFAYIBAAAAA==.',['还叫']='还叫捷克:BAAALAADCgEIAQAAAA==.',['迷人']='迷人的小土豆:BAABLAAFFH8GAAIRAAYIWASkXADVAAARAAYIWASkXADVAAAAAA==.',['追猎']='追猎者帅帅:BAAALAAECgYICAAAAA==.',['遗忘']='遗忘血腥:BAABLAAFFH8KAAIEAAIIrwv1QABpAAAEAAIIrwv1QABpAAABLAAFFAgICgABAO4aAA==.',['邦布']='邦布:BAAALAAECgYIDAAAAA==.',['都行']='都行丶:BAABLAAFFH8oAAMMAAcITwZbCABnAQAMAAcIGQRbCABnAQANAAEIChDFQQBXAAAAAA==.',['酒甁']='酒甁子:BAAALAADCggICAAAAA==.',['金月']='金月马太福音:BAAALAAECgIIAgAAAA==.',['鉄锅']='鉄锅炖大鹅:BAAALAAECgYICwABLAAFFAYIMwAFAAoiAA==.',['鋼鐵']='鋼鐵丧尸:BAAALAADCgMIBAAAAA==.',['钟佰']='钟佰:BAABLAAFFH8GAAIRAAYI0hruIwCjAQARAAYI0hruIwCjAQAAAA==.',['钢琴']='钢琴里的猫:BAAALAAFFAgIAgAAAA==.',['银月']='银月流霜:BAAALAAFFAIIAwAAAA==.',['银色']='银色天空:BAAALAAFFAIIAwAAAA==.',['长颈']='长颈鹿没脖子:BAAALAAECggIBwAAAA==.',['闲潭']='闲潭梦落花:BAAALAAECgYICgAAAA==.',['闷骚']='闷骚的花生:BAAALAAECgYIDAAAAA==.',['阿富']='阿富汗酋长:BAAALAAECgYICQAAAA==.',['阿散']='阿散井杨:BAAALAAFFAIIAgAAAA==.',['阿术']='阿术丶:BAACLAAFFH8QAAIfAAUIFBWIIAAfAQAfAAUIFBWIIAAfAQAsAAQKfxwAAh8ABwiHHeE6AE4CAB8ABwiHHeE6AE4CAAAA.',['随地']='随地乱叉:BAAALAAECgYICgAAAA==.',['随灬']='随灬风:BAAALAADCggIDwAAAA==.',['隐月']='隐月游云:BAABLAAFFH8FAAIRAAUIExddSAArAQARAAUIExddSAArAQAAAA==.',['雪悦']='雪悦:BAABLAAECn8YAAIRAAcIsRrKVgCWAQARAAcIsRrKVgCWAQAAAA==.',['雯竹']='雯竹:BAAALAADCgIIAgAAAA==.',['零度']='零度可乐:BAAALAAECgQIBAAAAA==.',['零点']='零点时刻:BAAALAAECgUIBQAAAA==.',['霁无']='霁无瑕:BAAALAAFFAIIBAAAAA==.',['霜与']='霜与混乱:BAAALAADCgQIBAAAAA==.',['霸气']='霸气丶小土贼:BAABLAAFFH8FAAIWAAMIuQfjDwB9AAAWAAMIuQfjDwB9AAAAAA==.',['青姣']='青姣:BAABLAAFFH8GAAIEAAYIKwT9IwAgAQAEAAYIKwT9IwAgAQAAAA==.',['青木']='青木弦:BAAALAAECgUIBQABLAAECgYIBgAjAAAAAA==.',['青青']='青青河边:BAAALAADCgQIBAAAAA==.',['顶级']='顶级手法:BAAALAAFFAIIAgABLAAFFAIIAgAjAAAAAA==.',['風雲']='風雲决:BAAALAAECgMIAwAAAA==.',['风暴']='风暴无尽:BAABLAAECn8UAAIBAAcILhtTUwDpAQABAAcILhtTUwDpAQAAAA==.',['飞翔']='飞翔的鹏鹏君:BAAALAAFFAIIAgAAAA==.',['饱了']='饱了横:BAABLAAFFH8OAAIFAAIIsRToYwCWAAAFAAIIsRToYwCWAAAAAA==.',['香勿']='香勿银:BAAALAAFFAIIAgAAAA==.',['香菜']='香菜咖啡:BAAALAAFFAIIBAAAAA==.',['马可']='马可波罗:BAABLAAFFH8hAAIHAAYItCVZBQAvAgAHAAYItCVZBQAvAgABLAAFFAgIEwAHAAEZAA==.',['高攀']='高攀不起的牛:BAAALAAECgUICAAAAA==.',['髭男']='髭男:BAABLAAFFH86AAQfAAcIsSZjBAC8AgAfAAcIsSZjBAC8AgAiAAMIaCU4AwDrAAAhAAEI7iXDCgBuAAABLAAFFAgIaAAfAPsmAA==.',['魅影']='魅影:BAAALAADCgYICAAAAA==.',['魔之']='魔之父:BAAALAAFFAIIAgAAAA==.',['魔芋']='魔芋爽:BAAALAAECgEIAQAAAA==.',['鱼龙']='鱼龙帮大军师:BAAALAADCgIIAgAAAA==.',['鸡少']='鸡少:BAAALAAECgUIBQAAAA==.',['鹿鸣']='鹿鸣丶星河:BAAALAAFFAIIBAAAAA==.鹿鸣幽谷:BAACLAAFFH8LAAIFAAMI/gpIaQByAAAFAAMI/gpIaQByAAAsAAQKfxcAAgUACAgSEc6NAOMBAAUACAgSEc6NAOMBAAAA.',['黄教']='黄教主驾到:BAAALAAECgYICAAAAA==.',['黎喵']='黎喵酱:BAABLAAFFH8MAAIMAAYIcw3SEwAkAQAMAAYIcw3SEwAkAQAAAA==.',['黑檀']='黑檀木白:BAAALAAECgYIDwAAAA==.',['黑白']='黑白无常:BAAALAAECgYIBgAAAA==.',['黑矮']='黑矮子骑士:BAABLAAFFH8ZAAIHAAYIshUwHQB4AQAHAAYIshUwHQB4AQAAAA==.',['龙琬']='龙琬重酿:BAABLAAECn8WAAMeAAcITA8oJgBfAQAeAAcITA8oJgBfAQAPAAUI1gfxQQCxAAAAAA==.',['龙痰']='龙痰泡面:BAACLAAFFH8TAAIXAAUIXiQPCQD4AQAXAAUIXiQPCQD4AQAsAAQKfxsAAhcACAi5JOMJANcCABcACAi5JOMJANcCAAAA.',['龙迪']='龙迪奥:BAAALAAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end