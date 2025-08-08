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
 local lookup = {'Rogue-Assassination','Warrior-Arms','Warlock-Destruction','Warlock-Demonology','Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Frost','DemonHunter-Havoc','DemonHunter-Vengeance','Priest-Discipline','Druid-Restoration','Mage-Frost','Mage-Arcane','Mage-Fire','Shaman-Restoration','Priest-Holy','Warrior-Fury','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','Unknown-Unknown','Shaman-Elemental','Druid-Balance','Monk-Brewmaster','Monk-Windwalker','Paladin-Protection','Shaman-Enhancement','Evoker-Devastation','Priest-Shadow','Warlock-Ranged','DeathKnight-Blood','Druid-Guardian','Monk-Mistweaver','Rogue-Subtlety','Warlock-Affliction','Paladin-Holy','Druid-Feral','Evoker-Preservation',}; local provider = {region='CN',realm='轻风之语',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ab='Abcs:BAAAKgADCgQIBAAAAA==.',Af='Aftertee:BAAAKgAFFAgIBAAAAA==.',Ba='Bazingaa:BAABKgAFFH8GAAIBAAYIiQwCCAB3AQABAAYIiQwCCAB3AQAAAA==.',Bo='Bosch:BAAAKgAECgYIBgAAAA==.',Ca='Cavalierb:BAAAKgAECgIIAgAAAA==.',Ch='Chelsea:BAAAKgAFFAQIBAAAAA==.Chiffon:BAAAKgAECgIIAwAAAA==.',Co='Coquettis:BAAAKgADCggICQAAAA==.',Cr='Crypticdly:BAAAKgADCgQIBAAAAA==.Crypticfashi:BAAAKgADCgEIAQAAAA==.',Da='Dalvin:BAAAKgAECggICgABKgAFFAgICAACADQMAA==.',De='Devils:BAABKgAECn8hAAMDAAgILCSzFQD6AQADAAcIyCKzFQD6AQAEAAUIVyOaJABxAQAAAA==.',Di='Divine:BAABKgAFFH8GAAIFAAYIIhyVFQCuAQAFAAYIIhyVFQCuAQAAAA==.',Do='Doyouhight:BAAAKgAECgYICwAAAA==.',Du='Dubaduba:BAAAKgAECgYIDgAAAA==.',Ex='Explosion:BAAAKgAECggIDwAAAA==.',Ey='Eyegs:BAAAKgADCggIDAAAAA==.',Fr='Francisee:BAABKgAFFH8LAAIDAAMIZw6WLwCwAAADAAMIZw6WLwCwAAAAAA==.',Gi='Giliya:BAACKgAFFH8ZAAIGAAMI2iR3DwD7AAAGAAMI2iR3DwD7AAAqAAQKf0IAAwYACAj+JNwHANQCAAYACAj+JNwHANQCAAcABgiiHFoKALQBAAAA.',Gr='Greemon:BAACKgAFFH8kAAMIAAYIoRp3DwCOAQAIAAYIoRp3DwCOAQAJAAQIWAuFFwCOAAAqAAQKfyoAAwgACAhNISUKAFwCAAgACAhNISUKAFwCAAkABwi4EXcoADkBAAAA.',He='Hello:BAAAKgAFFAQIBAAAAA==.',Hu='Hunterelise:BAAAKgAECgEIAQAAAA==.',Ia='Iamdc:BAAAKgAFFAgIAgAAAA==.',Im='Imissyou:BAAAKgAECgcIBwAAAA==.',In='Intotheblue:BAAAKgAFFAQIBAAAAA==.',Ko='Konurimaki:BAABKgAFFH8KAAIKAAYIDRoUAQDgAQAKAAYIDRoUAQDgAQAAAA==.',Lo='Lolita:BAAAKgADCgMIAwAAAA==.',Lu='Lucifero:BAABKgAFFH8GAAIIAAYIyAS3HgAOAQAIAAYIyAS3HgAOAQAAAA==.Luckygu:BAABKgAFFH8IAAILAAgIcQc0BgBoAQALAAgIcQc0BgBoAQAAAA==.',Ma='Marblebeard:BAAAKgAFFAIIAgAAAA==.',Mi='Mightnare:BAACKgAFFH8dAAMMAAcIPBuhAwC+AQANAAcIuBTMCADqAQAMAAYIJh+hAwC+AQAqAAQKfzYAAwwACAg8Jc4CAPwCAAwACAg8Jc4CAPwCAA4ABAh/BPKTAEoAAAAA.Mistheway:BAABKgAFFH8IAAIPAAMIAA92NgClAAAPAAMIAA92NgClAAAAAA==.',Mo='Montserk:BAAAKgADCgMIAwAAAA==.Moonmoon:BAAAKgAECgEIAQABKgAECggIZQAQAH0mAA==.',Pl='Playertenyjg:BAAAKgADCgYIBgAAAA==.',Ra='Raelag:BAABKgAFFH8MAAIOAAYI+iE+BADFAQAOAAYI+iE+BADFAQAAAA==.',Sa='Saramel:BAAAKgAECgEIAQAAAA==.',Sc='Scott:BAAAKgAECgQIBAAAAA==.',Sd='Sdgbn:BAAAKgADCggIBAAAAA==.',Sh='Shadownwork:BAAAKgAECgIIAgAAAA==.',So='Socute:BAAAKgAECgEIAQAAAA==.Soloprincess:BAAAKgAECggICAAAAA==.Sonicadi:BAAAKgAECgIIAwAAAA==.',Sp='Spike:BAAAKgAECgYIBgAAAA==.',Tl='Tlo:BAAAKgAECggIEwAAAA==.',To='Toofaraway:BAABKgAFFH8IAAIRAAgIngv4BgAFAgARAAgIngv4BgAFAgAAAA==.',Tr='Troubler:BAACKgAFFH8sAAMSAAgI/R2sAADYAQATAAgIYBnTBwD/AQASAAYIwRusAADYAQAqAAQKfyAAAxMACAgaINwjAGUCABMACAgaINwjAGUCABQAAggjErkcAEUAAAAA.',Wi='Windyevoker:BAAAKgAFFAgIBAAAAA==.',Ws='Ws:BAAAKgADCggICAAAAA==.',Yi='Yimoess:BAAAKgAECgIIAgAAAA==.',Yy='Yyxxy:BAAAKgAECggICQAAAA==.',['一小']='一小秋秋一:BAAAKgAFFAQIBAABKgAFFAgIBAAVAAAAAA==.',['一念']='一念成殇:BAAAKgAECgQIBgAAAA==.',['一情']='一情夢襲緣一:BAAAKgAECgcICwAAAA==.',['七月']='七月丶飞絮:BAABKgAFFH8KAAIQAAYInBRTCQBFAQAQAAYInBRTCQBFAQAAAA==.',['万物']='万物有时:BAAAKgADCgEIAQAAAA==.',['下次']='下次去哪吃:BAABKgAFFH8GAAIPAAYIbQMOIAD5AAAPAAYIbQMOIAD5AAAAAA==.',['业火']='业火重生:BAAAKgADCgUIBQAAAA==.',['东方']='东方梦想乡:BAAAKgAECggIDgAAAA==.',['丨白']='丨白居易丨:BAAAKgAECgUIBQAAAA==.',['临时']='临时洋流:BAABKgAECn8WAAMPAAgIhRyWGwAvAgAPAAgIhRyWGwAvAgAWAAgI2BxbIADsAQAAAA==.',['丶初']='丶初心:BAAAKgADCgEIAQAAAA==.',['丶把']='丶把酒作清欢:BAAAKgAECgQIBgAAAA==.',['丹妮']='丹妮莉斯:BAAAKgAECggICAAAAA==.',['乖囧']='乖囧猫:BAAAKgAECgEIAQAAAA==.',['九色']='九色牡丹:BAAAKgAECggIDQAAAA==.九色虹:BAAAKgADCggIDgAAAA==.',['九连']='九连玉:BAAAKgAECgMIBAAAAA==.',['二齐']='二齐:BAAAKgADCgUIBQAAAA==.',['云殇']='云殇:BAAAKgADCggICgAAAA==.',['五月']='五月丶飞华:BAACKgAFFH8iAAMSAAYIPiCMDgB2AQATAAYIwxs9CwCUAQASAAYIdh6MDgB2AQAqAAQKfxgAAhIACAiUFncbAPYBABIACAiUFncbAPYBAAEqAAUUCAgEABUAAAAA.',['亲亲']='亲亲魅影:BAABKgAFFH8IAAIBAAIIBA7kFgBmAAABAAIIBA7kFgBmAAAAAA==.',['人间']='人间世:BAAAKgAECggIDQAAAA==.',['仰望']='仰望星空:BAAAKgADCggICQAAAA==.',['任逍']='任逍遥依依:BAAAKgAFFAYIBAAAAA==.',['伊利']='伊利达雷之手:BAAAKgAFFAMIAwAAAA==.',['伊塔']='伊塔尼斯:BAAAKgAECgYIBgAAAA==.',['会扒']='会扒皮的狼:BAABKgAFFH8MAAITAAQIVguQHQCwAAATAAQIVguQHQCwAAABKgAFFAUIEAABAE8MAA==.',['会长']='会长是混子:BAAAKgADCggICAAAAA==.',['伟少']='伟少爷:BAAAKgAFFAcIBAAAAA==.',['伟爵']='伟爵爺:BAAAKgAECgcIBwAAAA==.',['传说']='传说中的球宝:BAABKgAFFH8IAAICAAgIUgMvCQB3AQACAAgIUgMvCQB3AQAAAA==.',['余琦']='余琦:BAABKgAFFH8jAAIXAAYIcCGOCgAaAQAXAAYIcCGOCgAaAQAAAA==.',['作甚']='作甚务甚:BAACKgAFFH8PAAMPAAMIghZjHwCcAAAPAAMIghZjHwCcAAAWAAIImgSyFQB1AAAqAAQKfx0AAw8ACAhtHwoUAFwCAA8ACAhtHwoUAFwCABYAAQhFERV+AD0AAAAA.',['你好']='你好像很好吃:BAAAKgAECggICQAAAA==.',['佩妮']='佩妮:BAAAKgAECggIEwAAAA==.',['倩儿']='倩儿:BAAAKgAFFAYIBAAAAA==.',['偏向']='偏向虎山行:BAAAKgAECgIIAgAAAA==.',['偶然']='偶然的魅惑:BAAAKgAECgcIDgAAAA==.',['僚机']='僚机大砍刀:BAAAKgAECgUIBQAAAA==.',['元夕']='元夕:BAABKgAFFH8JAAIMAAgI5BmRAQBYAgAMAAgI5BmRAQBYAgAAAA==.',['光与']='光与影的平衡:BAAAKgADCgMIAwAAAA==.',['克莱']='克莱因的海:BAAAKgAFFAMIAgAAAA==.',['兜兜']='兜兜丶玫瑰糖:BAACKgAFFH8GAAMDAAQI1xDzPwBtAAADAAMI1xDzPwBtAAAEAAIIlQqYLwA7AAAqAAQKfxUAAwMACAgSIvYnANkBAAMABggxI/YnANkBAAQAAwgRIItOAK4AAAAA.',['兵冷']='兵冷帝:BAAAKgAECgYICwAAAA==.',['其实']='其实我是英台:BAAAKgAECgUIBwAAAA==.',['冬季']='冬季来的女人:BAAAKgAECggIDQAAAA==.',['冰心']='冰心醉月:BAAAKgADCgEIAQAAAA==.',['冰河']='冰河:BAAAKgAECgMIAwAAAA==.',['冷对']='冷对人间冷暖:BAAAKgAECggICAAAAA==.',['凝芸']='凝芸:BAAAKgAECggICAAAAA==.',['凡妮']='凡妮娅:BAAAKgAECgIIAgAAAA==.',['别咬']='别咬我的龙:BAAAKgAECgEIAQAAAA==.',['刺猬']='刺猬爱蜗牛:BAABKgAFFH8IAAIXAAQI6CV1GABUAQAXAAQI6CV1GABUAQAAAA==.',['加血']='加血好累啊:BAAAKgAECgQIBAAAAA==.',['北岸']='北岸初晴:BAAAKgADCggICAAAAA==.',['北方']='北方哈士奇:BAAAKgAFFAQIBAAAAA==.',['十月']='十月豪情:BAABKgAFFH8QAAIBAAUITwwECgAcAQABAAUITwwECgAcAQAAAA==.',['半夏']='半夏泻心汤:BAAAKgAECgIIAgAAAA==.',['华莲']='华莲:BAAAKgAECgUIBQAAAA==.',['南影']='南影倾寒:BAAAKgAFFAEIAgAAAA==.',['南风']='南风啊吹来:BAAAKgAECggICAAAAA==.',['卡伊']='卡伊落斯:BAAAKgAECggICwAAAA==.',['原谷']='原谷:BAABKgAFFH8GAAISAAYIphu6DwBpAQASAAYIphu6DwBpAQAAAA==.',['变大']='变大变小:BAABKgAFFH8GAAILAAYIBQZlJACUAAALAAYIBQZlJACUAAAAAA==.',['口水']='口水流下来了:BAAAKgADCgYIBgAAAA==.',['古尔']='古尔双:BAAAKgAECgIIAgAAAA==.',['只会']='只会玩惩戒骑:BAAAKgAECgUIBQAAAA==.',['吉豆']='吉豆:BAAAKgADCggICgAAAA==.',['吐刀']='吐刀乐:BAAAKgAECggICQAAAA==.',['吕孤']='吕孤城:BAAAKgADCgQIBAAAAA==.',['启明']='启明星的指引:BAACKgAFFH8XAAMTAAQIxyKhCwAmAQATAAQIxyKhCwAmAQASAAMIaxVkJwDNAAAqAAQKfxgAAxIACAgnI9cWABkCABIABwiGIdcWABkCABMABgioImw2AMsBAAAA.',['呦呵']='呦呵哈嘿:BAABKgAFFH8MAAMYAAQI1A9bBQCbAAAZAAQI1A91FgC1AAAYAAQIIgtbBQCbAAAAAA==.',['咕噜']='咕噜咕噜滚:BAAAKgAECgYICQAAAA==.',['哇哦']='哇哦打的不错:BAAAKgAECgQIBgAAAA==.',['啊对']='啊对対対:BAAAKgAECgQIBAAAAA==.',['啊西']='啊西吧:BAAAKgAECgQIBAAAAA==.',['啵儿']='啵儿:BAABKgAFFH8IAAISAAgIGxfyBAAvAgASAAgIGxfyBAAvAgAAAA==.',['喜力']='喜力:BAABKgAFFH8KAAMQAAQImxYtCwDcAAAQAAQImxYtCwDcAAAKAAQIsAh7IgCaAAAAAA==.',['喜爱']='喜爱姐姐:BAAAKgAECgYIBgAAAA==.',['喵星']='喵星人入侵:BAAAKgAFFAEIAQAAAA==.',['嗷嗷']='嗷嗷砍:BAAAKgADCgIIAgAAAA==.',['因为']='因为可爱鸭:BAAAKgADCggICAAAAA==.',['团长']='团长你缺德吗:BAAAKgADCgMIAwAAAA==.',['土老']='土老帽:BAAAKgAFFAIIAgAAAA==.',['圣光']='圣光七匹狼:BAAAKgAECgcICwAAAA==.圣光杀非珑:BAABKgAFFH8KAAMaAAYIDhmNAQCXAQAaAAYIDhmNAQCXAQAFAAQIagVHLwCxAAAAAA==.',['圣园']='圣园未花:BAABKgAFFH8MAAIFAAQIHCF7OwD/AAAFAAQIHCF7OwD/AAAAAA==.',['圣堂']='圣堂花舞:BAABKgAFFH8SAAIaAAQIvQh8EAB5AAAaAAQIvQh8EAB5AAABKgAFFAUIEAABAE8MAA==.',['圣斗']='圣斗士星矢:BAAAKgAECgEIAQAAAA==.',['在宇']='在宇宙中歌唱:BAABKgAFFH8IAAMJAAQI+wx8CwCnAAAIAAQIMgytGgDaAAAJAAQIBAx8CwCnAAAAAA==.',['在水']='在水一方:BAABKgAFFH8MAAMKAAYIjB3oAADtAQAKAAYIjB3oAADtAQAQAAUIwBFYFwD7AAAAAA==.',['坚毅']='坚毅如风:BAACKgAFFH8RAAIFAAMIFxE1VgDEAAAFAAMIFxE1VgDEAAAqAAQKfx4AAgUACAhfGopWALoBAAUACAhfGopWALoBAAAA.',['堕落']='堕落辰星:BAABKgAFFH8GAAIGAAYIdhKsCgBxAQAGAAYIdhKsCgBxAQAAAA==.',['塔丽']='塔丽娜:BAABKgAFFH8GAAIPAAYIbRESEABWAQAPAAYIbRESEABWAQAAAA==.',['塞勒']='塞勒涅星歌:BAAAKgAECgQIBAAAAA==.',['墓尸']='墓尸:BAAAKgAFFAQIBAAAAA==.',['墨兰']='墨兰:BAAAKgAECgcICwAAAA==.',['夏心']='夏心:BAAAKgADCgYIBgAAAA==.',['夏无']='夏无蝉:BAABKgAFFH8HAAITAAQIQB26GADuAAATAAQIQB26GADuAAAAAA==.',['够钟']='够钟死心了:BAABKgAFFH8PAAIRAAYIRx05AQDNAQARAAYIRx05AQDNAQAAAA==.',['大侠']='大侠阿宝:BAAAKgADCgEIAQAAAA==.',['大凶']='大凶熊:BAAAKgAFFAQIAgAAAA==.',['大劈']='大劈叉:BAACKgAFFH8PAAIFAAcIXBv/CQAjAgAFAAcIXBv/CQAjAgAqAAQKfy0AAgUACAgkJj4DABUDAAUACAgkJj4DABUDAAAA.',['大嘴']='大嘴光光:BAAAKgADCgQIBAAAAA==.',['大多']='大多多:BAABKgAFFH8OAAIPAAgIpw8/BwCqAQAPAAgIpw8/BwCqAQAAAA==.',['大探']='大探险者:BAAAKgADCgUIBQAAAA==.',['大梦']='大梦三千:BAAAKgAECgYICAAAAA==.',['大雪']='大雪花儿:BAABKgAECn8yAAIXAAgI/CHTDwCpAgAXAAgI/CHTDwCpAgAAAA==.',['大齐']='大齐哥:BAAAKgADCggICAAAAA==.',['天使']='天使之赐:BAAAKgAECggICAAAAA==.',['天哪']='天哪您可真高:BAAAKgAECgQIBQAAAA==.',['天才']='天才少女:BAAAKgAECgMIBAAAAA==.',['天生']='天生比别人笨:BAAAKgADCggICAAAAA==.',['天蠍']='天蠍毒針:BAABKgAFFH8IAAIFAAgImwhTEQCKAQAFAAgImwhTEQCKAQAAAA==.天蠍猎手:BAABKgAFFH8GAAIIAAYIiRVnEQB1AQAIAAYIiRVnEQB1AQAAAA==.',['奈何']='奈何花落:BAAAKgAFFAQIBAAAAA==.奈何花落去:BAAAKgAECgEIAQAAAA==.',['奈克']='奈克塔耳:BAAAKgAECgQIBAAAAA==.',['奔跑']='奔跑的呼呼:BAABKgAFFH8SAAMbAAYILxL3BwBgAQAbAAYILxL3BwBgAQAPAAIIvxGuJQCGAAAAAA==.',['套盾']='套盾摩西:BAABKgAFFH8JAAMKAAYINybNAwAdAgAKAAYINybNAwAdAgAQAAEIvhaxPgA+AAAAAA==.',['奥摩']='奥摩伊:BAAAKgAFFAMIAwAAAA==.',['奥杜']='奥杜因:BAABKgAFFH8GAAIcAAYIIQtyDgAyAQAcAAYIIQtyDgAyAQAAAA==.',['奶妈']='奶妈真好玩:BAACKgAFFH8fAAQQAAcIYBXEGwDfAAAQAAQIyxrEGwDfAAAKAAQI1RLRGADLAAAdAAMIAw9WIQCAAAAqAAQKfykAAwoACAjWIFENAGMCAAoABwjrHlENAGMCABAACAhuHscqAJ4BAAAA.',['媳妇']='媳妇儿叫玉娇:BAAAKgAFFAIIAgAAAA==.',['孙一']='孙一诺的好友:BAAAKgAECggICAAAAA==.',['安妮']='安妮罗杰:BAAAKgAFFAQIBAAAAA==.',['宝贝']='宝贝你来呀:BAAAKgADCgEIAQAAAA==.宝贝小颖:BAAAKgAFFAgIBAAAAA==.宝贝颖颖:BAAAKgAFFAgIBAAAAA==.',['封兽']='封兽鵺:BAAAKgAECgMIAwAAAA==.',['小凶']='小凶猫:BAAAKgADCggICAAAAA==.',['小宁']='小宁宁:BAABKgAFFH8MAAIeAAYIsCAAAAAAAAADAAYIsCAAAAAAAAAAAA==.',['小小']='小小萱萱:BAABKgAFFH8HAAIFAAUI1Q5fHwDsAAAFAAUI1Q5fHwDsAAABKgAFFAgIEAATAKobAA==.小小颖:BAABKgAFFH8MAAIIAAQIJCKeEQD5AAAIAAQIJCKeEQD5AAAAAA==.',['小心']='小心心安安:BAAAKgAECgIIAgAAAA==.',['小树']='小树焦圈圈:BAAAKgAECgUIBQAAAA==.',['小浪']='小浪蹄子:BAAAKgAECgMIAwAAAA==.',['小百']='小百合帕帕喵:BAABKgAFFH8OAAMdAAYINBUjAwCjAQAdAAYINBUjAwCjAQAQAAQInhWHJACxAAAAAA==.',['小粉']='小粉毛洛莉娅:BAABKgAFFH8IAAMGAAgIGQHsFwCnAAAGAAYIaQHsFwCnAAAfAAIIUACKEwA/AAAAAA==.',['小葱']='小葱花:BAAAKgAECggIEQAAAA==.',['小辉']='小辉:BAAAKgADCgIIAgAAAA==.小辉辉:BAAAKgADCggIHAAAAA==.',['小青']='小青龙汤:BAAAKgADCgMIAwAAAA==.',['小马']='小马桶盖:BAAAKgAECggICAAAAA==.',['尐楠']='尐楠:BAAAKgADCgYIBgAAAA==.',['山伯']='山伯已死:BAAAKgADCggICAAAAA==.',['山茶']='山茶荼蘼:BAAAKgAECgIIAwAAAA==.',['岩心']='岩心:BAAAKgADCgIIAgAAAA==.',['崔佛']='崔佛丶菲利普:BAAAKgADCgQIBAAAAA==.',['巨大']='巨大的菊:BAAAKgAECgYICAAAAA==.',['布洛']='布洛芬:BAAAKgAFFAQIBAAAAA==.',['帅气']='帅气筱哈哈:BAABKgAFFH8YAAMOAAYIdCKNBgD4AQAOAAYIdCKNBgD4AQANAAYIVBiCEgBSAQABKgAFFAgIKAANABckAA==.帅气筱趴菜:BAABKgAFFH8GAAIIAAYIbQz0DgBSAQAIAAYIbQz0DgBSAQAAAA==.',['希丶']='希丶:BAAAKgAFFAIIAgAAAA==.',['帕斯']='帕斯丁:BAAAKgAECgcIBwAAAA==.',['常庆']='常庆:BAABKgAECn8UAAIJAAYIOxNxMAAMAQAJAAYIOxNxMAAMAQAAAA==.',['幽影']='幽影骑士:BAAAKgADCgIIAgAAAA==.',['废废']='废废:BAABKgAECn8aAAMQAAgIYhf+JAC/AQAQAAgIYhf+JAC/AQAdAAYIzxMFNQA9AQAAAA==.',['弑血']='弑血弑魂:BAAAKgADCggICAAAAA==.',['弓弦']='弓弦叶:BAAAKgAECgEIAQAAAA==.',['张三']='张三美丽:BAAAKgAECgMIAwAAAA==.',['彩虹']='彩虹梦之湖:BAAAKgAECgEIAQAAAA==.',['影子']='影子大香菜:BAAAKgAECgUIBQAAAA==.影子豆汁汁:BAACKgAFFH8aAAITAAQIxyM0GQAzAQATAAQIxyM0GQAzAQAqAAQKf0AAAhMACAi4JKAMANQCABMACAi4JKAMANQCAAAA.',['得道']='得道者:BAAAKgAECgUIBQAAAA==.',['御姐']='御姐之星:BAAAKgADCggICAAAAA==.',['御馔']='御馔津:BAAAKgAECgIIAgAAAA==.',['御龙']='御龙镜中影:BAAAKgADCgcIBwAAAA==.',['心雨']='心雨成湖:BAAAKgAECggIEQAAAA==.',['快乐']='快乐星球:BAACKgAFFH9CAAQXAAgIfyCaAQDNAQAXAAgIfyCaAQDNAQALAAQI2wKxKACCAAAgAAEIjQDgDwAjAAAqAAQKfx4AAxcACAh2HTFEAJkBABcABghIITFEAJkBAAsACAgwEDYxAFsBAAAA.',['怎么']='怎么又被冻了:BAAAKgAFFAgIAgAAAA==.',['怜星']='怜星儿:BAABKgAECn8UAAIQAAgIJA5xPAAlAQAQAAgIJA5xPAAlAQAAAA==.',['悟净']='悟净:BAAAKgAECgUIBgAAAA==.',['悟海']='悟海:BAAAKgAECgQIBgAAAA==.',['悠哉']='悠哉大王:BAAAKgADCggICAAAAA==.',['想你']='想你时风起:BAAAKgAFFAQIBAAAAA==.',['想慑']='想慑都难:BAAAKgAECggIDAAAAA==.',['想戒']='想戒都难:BAAAKgAECggICAAAAA==.',['想死']='想死都难:BAAAKgAECgMIAwAAAA==.',['慕雪']='慕雪惊风:BAAAKgADCggICAAAAA==.',['我不']='我不是小绵羊:BAABKgAFFH8TAAILAAQIdg9HHwCvAAALAAQIdg9HHwCvAAABKgAFFAUIEAABAE8MAA==.我不要橙色:BAAAKgADCgEIAQAAAA==.',['我将']='我将带头冲钅:BAABKgAFFH8GAAICAAYIIwnJBgBUAQACAAYIIwnJBgBUAQABKgAFFAgIFgAZAOkYAA==.',['我思']='我思故我在:BAAAKgADCgEIAQAAAA==.',['我愛']='我愛小刚:BAAAKgAECgUIBQAAAA==.',['我是']='我是你术式:BAAAKgADCgQIBAAAAA==.我是地狱:BAABKgAECn8iAAMPAAgItRMbQACGAQAPAAgItRMbQACGAQAWAAEItARrgAAcAAAAAA==.我是大丑逼:BAAAKgAFFAIIBAAAAA==.',['我有']='我有神经稟丶:BAAAKgAECgQIBAAAAA==.',['我知']='我知道你是谁:BAABKgAFFH8GAAIMAAYIzxdABwBSAQAMAAYIzxdABwBSAQAAAA==.',['我要']='我要为了部落:BAAAKgAFFAEIAQAAAA==.我要吃肉:BAAAKgADCgQIBAAAAA==.',['戕丶']='戕丶格拉墨:BAAAKgAECgcICgAAAA==.',['拉德']='拉德季晨风:BAAAKgAECggICAAAAA==.',['拉芬']='拉芬克莉丝:BAAAKgAECgIIAgAAAA==.拉芬克蕾丝:BAAAKgADCgcICAAAAA==.',['挚丶']='挚丶格拉墨:BAAAKgAECggICAAAAA==.',['捕风']='捕风:BAAAKgAECggIDwAAAA==.',['掌管']='掌管骰子的神:BAAAKgAECgYIDQAAAA==.',['擎丶']='擎丶格拉墨:BAAAKgAECgcICwAAAA==.',['故人']='故人醉:BAAAKgADCgEIAQAAAA==.',['无丷']='无丷双:BAABKgAFFH8KAAIhAAUIngQ0DQD7AAAhAAUIngQ0DQD7AAAAAA==.',['无幽']='无幽大神:BAAAKgADCggICAAAAA==.',['无极']='无极元素:BAABKgAFFH8IAAMMAAYI1hSbCADoAAAMAAQI9BubCADoAAANAAIIKgprNACQAAAAAA==.',['无畏']='无畏生死:BAAAKgAECgIIAgAAAA==.',['日向']='日向丨雏田:BAAAKgAECgcIBwAAAA==.',['时光']='时光漫步:BAAAKgAFFAQIBAAAAA==.',['昆德']='昆德拉:BAAAKgAECggICwAAAA==.',['昊熙']='昊熙:BAAAKgAECgcIBwAAAA==.',['明镜']='明镜止水:BAAAKgAECgIIBAAAAA==.',['星夜']='星夜绫:BAABKgAECn8tAAIiAAgIXR30AgAxAgAiAAgIXR30AgAxAgAAAA==.',['星屑']='星屑幻想:BAAAKgAECgIIAgAAAA==.',['春风']='春风细雨:BAAAKgAFFAEIAQAAAA==.',['是淳']='是淳罡啊:BAABKgAFFH8GAAIFAAYIjAH/cQCGAAAFAAYIjAH/cQCGAAAAAA==.',['晨鹜']='晨鹜:BAAAKgADCgUIBQABKgAECggIZQAQAH0mAA==.',['晴天']='晴天小妖女:BAAAKgAFFAMIAwAAAA==.',['暗夜']='暗夜雨露:BAABKgAECn8VAAMGAAgIcBV8PgB5AQAGAAgIyRB8PgB5AQAHAAcIKhTGFABjAQAAAA==.',['暗影']='暗影信仰:BAABKgAFFH8GAAIjAAYIPgyBAAB1AQAjAAYIPgyBAAB1AQABKgAFFAgIFgADAOgSAA==.暗影独行:BAABKgAFFH8IAAISAAgI3hJKBwDuAQASAAgI3hJKBwDuAQAAAA==.',['暗歌']='暗歌:BAABKgAFFH8KAAMjAAYIoQzBAABZAQAjAAYIBgnBAABZAQADAAQIjAuzMwA9AAAAAA==.',['暗黑']='暗黑冬瓜:BAAAKgAECgQIBAAAAA==.',['暴风']='暴风骤雨:BAAAKgADCgEIAQAAAA==.',['最佳']='最佳主人:BAABKgAFFH8IAAITAAQItCRUFgBFAQATAAQItCRUFgBFAQAAAA==.',['月光']='月光似水:BAABKgAECn8ZAAMXAAgIDRgXEQDoAQAXAAgIDRgXEQDoAQALAAIIfwUZOAAqAAAAAA==.',['月影']='月影呢喃:BAABKgAFFH8GAAITAAYI2QrfDgA8AQATAAYI2QrfDgA8AQAAAA==.月影离歌:BAAAKgADCgQIBQAAAA==.',['月格']='月格:BAAAKgAECgYIBQAAAA==.',['有话']='有话三月说:BAAAKgADCggIDgAAAA==.',['木叶']='木叶丨犬冢花:BAAAKgAECgQIBAAAAA==.',['朱敛']='朱敛:BAABKgAECn8WAAMQAAgIQhMULgBvAQAQAAgIQhMULgBvAQAdAAQItwzZTQB2AAAAAA==.',['朴朴']='朴朴酱:BAAAKgAECgYICQAAAA==.',['杀戮']='杀戮的悲伤:BAAAKgADCgcIDAAAAA==.',['松鼠']='松鼠零一七:BAABKgAFFH8VAAIkAAQImyGRCAAiAQAkAAQImyGRCAAiAQAAAA==.松鼠零一六:BAABKgAFFH8LAAIRAAMIWR3wFwD7AAARAAMIWR3wFwD7AAABKgAFFAQIFQAkAJshAA==.',['林深']='林深鹿潇:BAAAKgAECgYIBgAAAA==.',['枯葉']='枯葉之伤:BAABKgAECn8YAAMLAAgI3g7GOAAGAQALAAcIyw3GOAAGAQAXAAQI2RGzLQDrAAAAAA==.',['树儿']='树儿小葱花:BAAAKgAECgMIAwAAAA==.',['桃悠']='桃悠悠丨曦:BAAAKgAECgcICwAAAA==.桃悠悠丨樱:BAABKgAECn8aAAIQAAgINxxKFwAnAQAQAAgINxxKFwAnAQAAAA==.',['梅雨']='梅雨欣:BAAAKgADCgEIAQAAAA==.',['梦幻']='梦幻丫丫:BAAAKgADCgcIBwAAAA==.',['梦碎']='梦碎长安:BAAAKgAECggICAAAAA==.',['梦雪']='梦雪飞翎:BAAAKgADCgIIAgAAAA==.',['椎名']='椎名立希:BAABKgAECn8mAAMJAAgIrx68CgBiAgAJAAgIrx68CgBiAgAIAAMI+BI+fgDDAAAAAA==.',['榴莲']='榴莲皇后:BAABKgAFFH8IAAMdAAgI6xZEBgDFAQAdAAcI4xlEBgDFAQAQAAEIohozPQBHAAAAAA==.',['橙冠']='橙冠希:BAAAKgAECgUIBQAAAA==.',['橙子']='橙子:BAAAKgAECgMIAwAAAA==.',['欠她']='欠她的太多了:BAAAKgAECgUIBQAAAA==.',['欧米']='欧米茄苍炎:BAAAKgAFFAQIBAAAAA==.',['武僧']='武僧打虎:BAAAKgAFFAIIAgAAAA==.',['殘陽']='殘陽:BAAAKgAFFAQIBAAAAA==.',['毛绒']='毛绒小豆:BAAAKgAECgMIAwAAAA==.',['氧气']='氧气呀:BAAAKgAECggICAAAAA==.',['水影']='水影丨照美冥:BAAAKgAECgMIAwAAAA==.',['水某']='水某:BAAAKgADCggICAAAAA==.',['汐丶']='汐丶舊時光:BAABKgAFFH8GAAIJAAYIowGhCQCyAAAJAAYIowGhCQCyAAAAAA==.',['汐若']='汐若玥:BAABKgAFFH8FAAITAAUIAg7tEAAXAQATAAUIAg7tEAAXAQAAAA==.',['池田']='池田依来沙:BAAAKgADCgEIAQAAAA==.',['沦为']='沦为神:BAAAKgAFFAQIBAAAAA==.',['法号']='法号不萌:BAAAKgADCgQIBAAAAA==.',['泷汐']='泷汐澜:BAAAKgAECgIIAgAAAA==.',['泼墨']='泼墨大写意:BAAAKgADCggICAAAAA==.',['洛丹']='洛丹伦孝子:BAAAKgAECggIDgAAAA==.洛丹伦的黎明:BAAAKgAECgIIAgAAAA==.',['洛可']='洛可可:BAAAKgADCggICAAAAA==.',['流云']='流云若水:BAACKgAFFH8LAAIgAAMIfQuaCQB1AAAgAAMIfQuaCQB1AAAqAAQKfzsABCAACAg9F/kGAJ4BACAACAj/FvkGAJ4BABcABwh/EY8gAEkBACUAAQiEE6AVAD0AAAAA.',['流氺']='流氺无情:BAAAKgADCggICAAAAA==.',['浅夏']='浅夏:BAAAKgADCggICQABKgAECggIZQAQAH0mAA==.',['浅梦']='浅梦:BAAAKgAECgcICQAAAA==.',['浅沐']='浅沐:BAABKgAECn9lAAIQAAgIfSZxAAAPAwAQAAgIfSZxAAAPAwAAAA==.',['浅牧']='浅牧:BAAAKgAECgEIAQABKgAECggIZQAQAH0mAA==.',['浮尘']='浮尘飘洒:BAAAKgAECggIEAAAAA==.',['海澜']='海澜鲸落:BAAAKgAECggIAQABKgAECggIZQAQAH0mAA==.',['海盐']='海盐荔枝:BAAAKgAFFAQIBAAAAA==.',['海阔']='海阔天空:BAAAKgADCggICAAAAA==.',['淅雨']='淅雨:BAAAKgADCggICAAAAA==.',['淡淡']='淡淡月光:BAABKgAECn8aAAITAAgIaBwMHwBFAgATAAgIaBwMHwBFAgAAAA==.',['深海']='深海鹿屿森:BAAAKgAECggIDAAAAA==.',['淺沐']='淺沐:BAABKgAECn8VAAIQAAgIwiITBACJAgAQAAgIwiITBACJAgABKgAECggIZQAQAH0mAA==.',['清丶']='清丶橘:BAAAKgAECgUIBQABKgAECggIZQAQAH0mAA==.',['清风']='清风化煞:BAAAKgADCgMIBAAAAA==.清风治愈咱:BAAAKgADCggICAAAAA==.',['湖光']='湖光山色:BAABKgAFFH8IAAIDAAQIKhYvLAC9AAADAAQIKhYvLAC9AAAAAA==.',['漂漂']='漂漂拳大宗师:BAAAKgAECgUIBQAAAA==.',['漠土']='漠土之辰:BAAAKgADCgUIBQAAAA==.',['火灬']='火灬光:BAAAKgAFFAgIAgAAAA==.',['火考']='火考奄鸟享鸟:BAACKgAFFH8QAAMQAAYIthtIEwAYAQAQAAUIyhpIEwAYAQAdAAUIAxGdFAC/AAAqAAQKfxcAAwoACAj4HCATAC0CAAoACAj4HCATAC0CABAAAghsDeN3AEwAAAAA.',['灬萨']='灬萨鲁法尔灬:BAAAKgADCggICAAAAA==.',['灵魂']='灵魂的救赎:BAAAKgADCggICAAAAA==.灵魂的苏醒:BAAAKgADCggIBwAAAA==.灵魂的誓约:BAAAKgADCggICQAAAA==.',['点睛']='点睛:BAAAKgADCggICAAAAA==.',['烈焰']='烈焰之鑫:BAAAKgAECgEIAQAAAA==.',['烤我']='烤我就不起名:BAAAKgAECgIIAgAAAA==.',['熔丶']='熔丶格拉墨:BAAAKgAECggICAAAAA==.',['熬夜']='熬夜黑眼圈:BAAAKgAECgYIBQAAAA==.',['牛牛']='牛牛向前冲:BAAAKgAFFAQIBAAAAA==.牛牛大虎:BAAAKgADCgcIBwAAAA==.',['狂暴']='狂暴小鸭蛋:BAAAKgAECgcICAAAAA==.',['狂澜']='狂澜:BAAAKgAFFAEIAQAAAA==.',['狐哔']='狐哔哔:BAAAKgAECggIEQAAAA==.',['狠外']='狠外婆:BAABKgAECn8VAAMXAAcIIwz9egDtAAAXAAUIRA79egDtAAALAAcISQYZUACjAAAAAA==.',['狮心']='狮心瞬神:BAAAKgAFFAQIBAAAAA==.',['猎魔']='猎魔者寇丹:BAABKgAFFH8QAAIIAAgIsR5QAwCtAgAIAAgIsR5QAwCtAgAAAA==.',['献祭']='献祭水賊永生:BAAAKgADCgEIAQAAAA==.',['玄冥']='玄冥酒仙:BAAAKgADCgcIBwAAAA==.',['玉延']='玉延:BAAAKgAECggICAAAAA==.',['玉竹']='玉竹:BAAAKgAECgUIBQAAAA==.',['玛格']='玛格丽特牙花:BAAAKgAFFAUIBAAAAA==.玛格汗:BAAAKgAECggIDgAAAA==.',['玛沙']='玛沙绿意之触:BAACKgAFFH8pAAIhAAgIdxhfBAB4AQAhAAgIdxhfBAB4AQAqAAQKfxYAAiEACAgjHO0OACgCACEACAgjHO0OACgCAAAA.',['珊珊']='珊珊丶:BAAAKgAECggICAAAAA==.',['瓦里']='瓦里安蒙斯克:BAAAKgAECggIAgAAAA==.',['生死']='生死一瞬间:BAAAKgADCgUIBQAAAA==.',['电臀']='电臀德:BAAAKgAECgYIBgAAAA==.',['白七']='白七匹狼:BAABKgAECn8bAAIRAAcI1RNvFgBQAQARAAcI1RNvFgBQAQAAAA==.',['白筱']='白筱白:BAAAKgAECgUIBQAAAA==.',['白銫']='白銫芒果:BAABKgAECn8XAAIFAAgIFyBGMwBWAgAFAAgIFyBGMwBWAgAAAA==.',['白鹤']='白鹤亮翅:BAAAKgAECgYIDwAAAA==.',['百变']='百变氧气:BAAAKgAECgcIBwAAAA==.',['百思']='百思不得骑:BAAAKgAFFAMIAwAAAA==.',['真诚']='真诚的双眸:BAAAKgAECgYIBgABKgAFFAgIKAAFAI8ZAA==.',['矮油']='矮油卡拉:BAAAKgAECgIIAgAAAA==.',['碧玉']='碧玉刀:BAAAKgAECggIEgAAAA==.',['祎然']='祎然宝宝:BAABKgAECn8hAAMJAAgIbyD4DABBAgAJAAgIAh34DABBAgAIAAcIIx/0HAAbAgAAAA==.',['祖传']='祖传咸鱼:BAAAKgADCgYIBgAAAA==.',['神圣']='神圣星星:BAAAKgAECggICgAAAA==.',['神恩']='神恩警长:BAAAKgAFFAYIAgAAAA==.',['神机']='神机营长:BAABKgAECn8jAAITAAgIHR+DJAAmAgATAAgIHR+DJAAmAgAAAA==.',['神父']='神父:BAAAKgAECgIIAgAAAA==.',['神秘']='神秘地下堡:BAABKgAECn8UAAIDAAgI4AubUgDHAAADAAgI4AubUgDHAAAAAA==.',['神骑']='神骑侍:BAAAKgAECgYICQAAAA==.神骑帕拉丁:BAAAKgAECgcIEwAAAA==.',['福至']='福至心灵:BAAAKgADCggICAAAAA==.',['秋叶']='秋叶丷:BAABKgAFFH8EAAQjAAMIGCG1BwDAAAAjAAII4yG1BwDAAAAEAAEIgh8iEwBVAAADAAEI6hmcJgBOAAAAAA==.',['秋天']='秋天酱:BAAAKgAFFAEIAQAAAA==.',['秋小']='秋小妹:BAAAKgAECggIEwAAAA==.',['秋雾']='秋雾里:BAAAKgAECggIDQAAAA==.',['科技']='科技与狠活:BAAAKgADCgIIAgAAAA==.',['空语']='空语空灵:BAAAKgAECgMIAwAAAA==.',['等我']='等我搓个糖:BAAAKgAFFAQIBAAAAA==.',['米僧']='米僧:BAACKgAFFH8TAAIZAAMIfwz8DgDAAAAZAAMIfwz8DgDAAAAqAAQKfygAAhkACAjkGGUcAPsBABkACAjkGGUcAPsBAAAA.',['米达']='米达麦雅:BAAAKgAECgUIBQAAAA==.',['米饭']='米饭拌骨灰:BAAAKgAECgMIAQAAAA==.',['粽子']='粽子君:BAACKgAFFH8MAAIFAAMIoBauQwDoAAAFAAMIoBauQwDoAAAqAAQKfx0AAwUACAi2FzhwALgBAAUABwhOGzhwALgBABoAAQgqAg1vAAYAAAAA.',['糖果']='糖果巧克力:BAAAKgAECgUIBQAAAA==.糖果给你一颗:BAABKgAFFH8FAAIFAAIInA5YOwCSAAAFAAIInA5YOwCSAAAAAA==.',['糖糖']='糖糖可爱第一:BAAAKgAECgMIAwABKgAFFAgIIgAFAI8YAA==.糖糖很听话:BAAAKgAECgMIAwABKgAFFAgIIgAFAI8YAA==.',['紫薯']='紫薯鸡翅:BAAAKgADCgEIAQAAAA==.',['纳怡']='纳怡若玥:BAAAKgAFFAQIBAAAAA==.',['维多']='维多利雅:BAAAKgAECgQIBAAAAA==.',['维罗']='维罗尼卡:BAABKgAFFH8HAAIKAAQIpB7ZCwD2AAAKAAQIpB7ZCwD2AAABKgAFFAgIFAAKAHEaAA==.',['绿豆']='绿豆芽:BAABKgAECn9CAAIXAAgIOCUsBQDzAgAXAAgIOCUsBQDzAgABKgAFFAYIBgAXAOkUAA==.',['罗萨']='罗萨莱斯:BAABKgAFFH8IAAIIAAQI7xabHADSAAAIAAQI7xabHADSAAAAAA==.',['羊羊']='羊羊村村长:BAAAKgAFFAMIAwAAAA==.',['美国']='美国的华莱士:BAABKgAECn8eAAIXAAgIpRWkQwCnAQAXAAgIpRWkQwCnAQAAAA==.',['美屡']='美屡猎:BAAAKgAFFAgIBAAAAA==.',['翩蓝']='翩蓝:BAAAKgAECgQIBgAAAA==.',['老许']='老许:BAAAKgAECggIDgAAAA==.老许老了:BAAAKgAECgMIAwAAAA==.',['老马']='老马的小马:BAAAKgAECgUIDAAAAA==.',['老魔']='老魔头:BAAAKgADCggIDgAAAA==.',['聖光']='聖光懺悔:BAAAKgADCgIIAgAAAA==.',['聰明']='聰明的一休:BAAAKgAFFAQIBAAAAA==.',['肯瑞']='肯瑞托欧皇:BAABKgAFFH8KAAMMAAgInxchAgAwAgAMAAgI9hMhAgAwAgANAAII6higLACxAAAAAA==.',['肾骑']='肾骑士:BAAAKgAFFAIIBAAAAA==.',['自由']='自由之辷:BAAAKgAECgQIBAAAAA==.',['至尊']='至尊魔君:BAAAKgADCgMIAwAAAA==.',['艾莉']='艾莉希娜:BAABKgAFFH8IAAISAAgIshHXBgD4AQASAAgIshHXBgD4AQAAAA==.',['芒果']='芒果颖:BAAAKgAECgQIBAAAAA==.',['花下']='花下雾飞花:BAABKgAFFH8IAAINAAgIFgjaCgCxAQANAAgIFgjaCgCxAQAAAA==.',['芸妹']='芸妹:BAAAKgAECgEIAQAAAA==.',['芸芝']='芸芝:BAAAKgAFFAMIBAAAAA==.',['若不']='若不是遇见你:BAAAKgAFFAgIBAAAAA==.',['若叶']='若叶牧:BAAAKgAECgcIBwAAAA==.',['草莓']='草莓秋葵脆:BAAAKgAECgcIBwAAAA==.',['莫格']='莫格莱尼丶:BAAAKgAECggICAAAAA==.',['菜鸟']='菜鸟很傻:BAABKgAFFH8hAAMPAAYIcCLRBgAjAQAPAAYIcCLRBgAjAQAWAAIIeBhpHQCOAAABKgAFFAgIDgAPABUPAA==.',['萌呆']='萌呆贼:BAAAKgAECggICgAAAA==.',['萌新']='萌新练奶中:BAAAKgADCggICAAAAA==.',['萌月']='萌月小主:BAACKgAFFH8RAAISAAQIQgvwNQCcAAASAAQIQgvwNQCcAAAqAAQKf2oABBIACAgwHuQWAEACABIACAgwHuQWAEACABQAAggGBmkdAD0AABMAAQjoAWMTARsAAAAA.',['萨拉']='萨拉梅尔:BAAAKgADCgIIAgAAAA==.',['落入']='落入你的眼睛:BAABKgAFFH8UAAMcAAgIJB3RBQA/AgAcAAgIJB3RBQA/AgAmAAYIehM8AACcAQAAAA==.',['蓝染']='蓝染总队长:BAAAKgAECgQIAgAAAA==.',['蔚蓝']='蔚蓝之殇:BAAAKgAECgEIAQAAAA==.蔚蓝珊瑚海:BAABKgAECn8UAAIRAAcIGRNYQQBsAQARAAcIGRNYQQBsAQAAAA==.',['蔡萌']='蔡萌萌:BAABKgAFFH8GAAIdAAYIsgdqCAAjAQAdAAYIsgdqCAAjAQAAAA==.',['薩格']='薩格拉斯之剑:BAAAKgADCggICAABKgADCggICAAVAAAAAA==.薩格拉斯之弒:BAAAKgADCggICAAAAA==.',['行千']='行千里:BAAAKgAFFAMIBAAAAA==.',['行神']='行神艰巨:BAACKgAFFH8FAAIFAAIIKiDkKwDBAAAFAAIIKiDkKwDBAAAqAAQKfxUAAgUACAigIUwfAJwCAAUACAigIUwfAJwCAAAA.',['许牧']='许牧:BAAAKgADCggICAAAAA==.',['请输']='请输入丶名字:BAAAKgAECgUIBQAAAA==.',['谁说']='谁说俺不靓:BAAAKgAECgEIAQAAAA==.',['谜语']='谜语:BAABKgAFFH8QAAMXAAQIrRGrMwDKAAAXAAQIrRGrMwDKAAAgAAMIPgfFCgBnAAAAAA==.',['豌豆']='豌豆芽:BAABKgAECn9AAAIXAAgIvCX2BgDrAgAXAAgIvCX2BgDrAgABKgAFFAYIBgAXAOkUAA==.',['豪门']='豪门青雅:BAAAKgAECgcICwAAAA==.',['貓撲']='貓撲:BAAAKgADCgEIAQAAAA==.',['貝克']='貝克汉貓:BAAAKgADCggICAAAAA==.',['贝莉']='贝莉娜:BAAAKgAFFAgIAgAAAA==.',['败家']='败家凝旋:BAAAKgAECgYIDAAAAA==.',['走刀']='走刀口:BAAAKgADCgEIAQAAAA==.',['走马']='走马行酒:BAAAKgAECggICAAAAA==.',['超级']='超级小飞侠:BAAAKgAECgQIBgAAAA==.',['跃迁']='跃迁引擎启动:BAABKgAFFH8JAAMmAAYIshrPAABYAQAmAAUI3hfPAABYAQAcAAII5hWQFACsAAAAAA==.',['路人']='路人乙:BAAAKgADCggIDwAAAA==.',['跳舞']='跳舞括约肌:BAAAKgAECgIIAgAAAA==.',['轌皕']='轌皕:BAAAKgAECgMIAwAAAA==.',['辞霜']='辞霜生:BAACKgAFFH89AAMmAAgItSYpAAC5AgAmAAgItSYpAAC5AgAcAAEI7wgTIwAxAAAqAAQKf0AAAyYACAiqJn8AAPkCACYACAiqJn8AAPkCABwABAhLFsdGAKMAAAAA.',['辰熙']='辰熙:BAAAKgAECgYICwAAAA==.',['达瓦']='达瓦里希:BAAAKgADCggICAAAAA==.',['达达']='达达杜:BAAAKgAECgIIAwAAAA==.',['达馨']='达馨紫李:BAAAKgADCggIDwAAAA==.',['迅捷']='迅捷斥候:BAAAKgADCgEIAQAAAA==.',['还是']='还是男人周:BAAAKgAECgcIBwAAAA==.',['还能']='还能变身两次:BAABKgAFFH8KAAMXAAMIbxEbOwC5AAAXAAMIbxEbOwC5AAALAAIIyw7lFwB8AAAAAA==.',['迷惑']='迷惑鉴定师:BAAAKgAECgcIBwAAAA==.',['逐月']='逐月:BAABKgAFFH8GAAICAAYI5w9jCwBXAQACAAYI5w9jCwBXAQAAAA==.',['邻居']='邻居灬老刘:BAAAKgAECgIIAgAAAA==.',['重启']='重启:BAAAKgADCgEIAQAAAA==.',['野人']='野人他叔:BAAAKgAFFAIIAgAAAA==.野人他外甥:BAAAKgAECgcIBwAAAA==.野人他大爷:BAAAKgAECgQIBAAAAA==.',['金刚']='金刚狼人:BAABKgAFFH8IAAITAAgIGQFDTAB3AAATAAgIGQFDTAB3AAAAAA==.',['鎏丶']='鎏丶格拉墨:BAAAKgAECggICgAAAA==.',['鎲丶']='鎲丶格拉墨:BAAAKgAECgIIAgAAAA==.',['银杏']='银杏:BAAAKgAECgEIAQAAAA==.',['锤石']='锤石:BAAAKgAECggICAAAAA==.',['锦绣']='锦绣年华:BAAAKgADCggICwAAAA==.',['镇北']='镇北冰冰果儿:BAAAKgADCgQIBAAAAA==.镇北冰果果兒:BAAAKgADCgMIAwAAAA==.',['长生']='长生剑:BAAAKgAECggIEgAAAA==.',['闪电']='闪电尼克:BAAAKgADCgIIAgAAAA==.闪电朱迪:BAAAKgADCggIEAAAAA==.',['队友']='队友是我减伤:BAAAKgADCggIDwAAAA==.',['阿斯']='阿斯忒莉德:BAAAKgAECgEIAQAAAA==.',['阿沦']='阿沦:BAAAKgAFFAQIBAAAAA==.',['阿艾']='阿艾儿灬微光:BAABKgAFFH8IAAIFAAgIURIUCgAiAgAFAAgIURIUCgAiAgAAAA==.',['阿西']='阿西达卡:BAAAKgADCgEIAQAAAA==.',['陈老']='陈老师:BAAAKgADCggICAAAAA==.',['雨语']='雨语阑珊:BAAAKgAECggIEAAAAA==.',['雪山']='雪山飞骑:BAAAKgAECgEIAQAAAA==.',['雪映']='雪映流云:BAAAKgADCggICAAAAA==.',['雷殇']='雷殇魂:BAAAKgAFFAYIAgAAAA==.',['雷霆']='雷霆胖达:BAABKgAECn8VAAIPAAgIlxNuKwDdAAAPAAgIlxNuKwDdAAAAAA==.',['雾川']='雾川:BAAAKgAECgEIAQAAAA==.',['霆好']='霆好:BAAAKgAFFAUIBAAAAA==.',['霜天']='霜天之织:BAAAKgAECggICAAAAA==.',['霜生']='霜生:BAABKgAFFH8PAAMQAAQI8B3sGwDeAAAQAAMIRBbsGwDeAAAKAAMI9xs7DQChAAAAAA==.',['露娜']='露娜切露德:BAABKgAFFH8GAAILAAYIrCORAwAKAgALAAYIrCORAwAKAgAAAA==.',['霸丶']='霸丶格拉墨:BAAAKgAECgIIAgAAAA==.',['霸王']='霸王茶鸡:BAAAKgAECgYIBgAAAA==.',['青椒']='青椒啊青椒:BAACKgAFFH8iAAMFAAgIjxgHEQDXAQAFAAgIjxgHEQDXAQAaAAQIBQtrHwCBAAAqAAQKfzIABAUACAi2HlRCACgCAAUACAi2HlRCACgCACQABAhfEH86AKEAABoAAQglDx9WACwAAAAA.',['静流']='静流:BAAAKgAECgEIAQAAAA==.',['静静']='静静的小宝贝:BAAAKgAFFAUIBAAAAA==.静静的蓝孩纸:BAAAKgAECgUIBwAAAA==.',['風雪']='風雪夜歸人:BAACKgAFFH8cAAQDAAcIuQdqJADlAAADAAYI/AhqJADlAAAEAAEIZgE+MgAxAAAjAAEIAABxKQAAAAAqAAQKfzcAAwMACAgRHh8RAGECAAMACAgRHh8RAGECAAQAAQgrCcJ8ADQAAAAA.',['风怒']='风怒导灵者:BAAAKgADCggICAAAAA==.',['风暴']='风暴闪电:BAAAKgAECgQIBAAAAA==.',['风林']='风林火山:BAAAKgADCgcICgAAAA==.',['风梦']='风梦尘:BAABKgAFFH8OAAIRAAYIqhuHCgCkAQARAAYIqhuHCgCkAQAAAA==.',['风潇']='风潇雨落:BAAAKgADCggICAAAAA==.',['风起']='风起时想你:BAABKgAFFH8IAAISAAgIwRBiBgDwAQASAAgIwRBiBgDwAQABKgAFFAgICAAFAFESAA==.',['飘渺']='飘渺的幽灵:BAAAKgAECgYICQAAAA==.',['飘雨']='飘雨追风:BAAAKgAECgcICAAAAA==.',['飞凤']='飞凤传玉:BAABKgAECn8aAAMXAAgIRhSmOwC5AQAXAAgIRhSmOwC5AQAgAAEIygBtSQAEAAAAAA==.',['飞梦']='飞梦小枫猪:BAAAKgAECgUIBQAAAA==.',['馨风']='馨风之舞:BAAAKgAECggIDAAAAA==.',['马文']='马文才:BAAAKgAECgUIBQAAAA==.',['马达']='马达卡卡:BAABKgAFFH8QAAMSAAQIqBF5MACtAAASAAQIRg95MACtAAATAAIInBL1SQB+AAAAAA==.',['骁龙']='骁龙:BAAAKgADCgYIBgAAAA==.',['骄傲']='骄傲是小可怜:BAAAKgADCgYIBgAAAA==.',['高小']='高小琴:BAAAKgAFFAEIAwAAAA==.',['魔女']='魔女:BAAAKgAFFAEIAQAAAA==.',['魔神']='魔神坛斗士:BAAAKgAECgUICQAAAA==.',['魔鬼']='魔鬼代言人:BAAAKgAECgEIAQAAAA==.',['鱼帅']='鱼帅英俊:BAAAKgAFFAQIBAAAAA==.',['鸿晏']='鸿晏:BAAAKgAFFAQIBAAAAA==.',['鹿其']='鹿其:BAABKgAFFH8IAAIPAAQIeRmbJwDYAAAPAAQIeRmbJwDYAAAAAA==.',['黑光']='黑光:BAABKgAFFH8TAAMIAAYIbRu7BgBRAQAIAAYIpBq7BgBRAQAJAAYIohLYCAAXAQABKgAFFAgIDAAGAPURAA==.',['黑暗']='黑暗御風者:BAAAKgAECgMIAwAAAA==.黑暗游俠:BAAAKgAECgIIAgAAAA==.',['黑白']='黑白滚滚:BAAAKgAECgIIAgAAAA==.',['黑蜗']='黑蜗壳:BAAAKgAFFAYIBAABKgAFFAgICAAPALsbAA==.',['默而']='默而识之:BAABKgAFFH8UAAMXAAQImSZsDAANAQAXAAQImSZsDAANAQALAAQIxQvvJACSAAAAAA==.',['黯黑']='黯黑之光:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end