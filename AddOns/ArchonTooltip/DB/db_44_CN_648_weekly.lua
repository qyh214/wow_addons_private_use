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
 local lookup = {'Paladin-Holy','DemonHunter-Havoc','Warlock-Destruction','Warlock-Affliction','Warrior-Fury','Shaman-Restoration','DeathKnight-Frost','Paladin-Retribution','Paladin-Protection','Evoker-Preservation','Evoker-Devastation','Priest-Shadow','Priest-Holy','Shaman-Elemental','Hunter-BeastMastery','Mage-Arcane','Mage-Frost','Druid-Restoration','Druid-Guardian','Warrior-Protection','Evoker-Augmentation','Druid-Balance','Monk-Windwalker','DemonHunter-Vengeance','Unknown-Unknown','Monk-Brewmaster','Rogue-Assassination','Shaman-Enhancement','Druid-Feral','Warrior-Arms','Warlock-Demonology','DeathKnight-Unholy',}; local provider = {region='CN',realm='安其拉',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Aleen:BAAALAAFFAIIBAAAAA==.',At='Atailande:BAAALAAECgEIAQAAAA==.',Ba='Battlefield:BAABLAAFFH8HAAIBAAUIMRDLFQAyAQABAAUIMRDLFQAyAQAAAA==.',Ch='Cherry:BAAALAAFFAIIBAAAAA==.',Dr='Dreamer:BAABLAAFFH8GAAICAAYI2wvZJwBTAQACAAYI2wvZJwBTAQAAAA==.',Fs='Fshow:BAAALAAECgcIBwAAAA==.',Fu='Fulgrim:BAAALAAECgYIBgAAAA==.',Jb='Jbl:BAAALAAFFAIIAgAAAA==.',Ko='Kobus:BAAALAAFFAIIAgAAAA==.',La='Labubu:BAAALAADCggICAAAAA==.',Lb='Lbennyl:BAAALAAECgYIBgAAAA==.',Lo='Locer:BAACLAAFFH8aAAIDAAUIfhNANwAxAQADAAUIfhNANwAxAQAsAAQKf0YAAwMACAhEH/YQAGECAAMACAhEH/YQAGECAAQAAQigC5o9AD8AAAAA.',Mo='Monstr:BAAALAAECgYICAAAAA==.',Ne='Newstart:BAABLAAFFH8FAAIDAAMIxRIpSwCOAAADAAMIxRIpSwCOAAAAAA==.',On='Onesavior:BAAALAAECgQIBAAAAA==.Ontheway:BAAALAAECgQICAAAAA==.',Ot='Ot:BAAALAAECgUICgAAAA==.',Pl='Playerridmnj:BAAALAAECgYIBgAAAA==.',Re='Realize:BAAALAADCgYIBgAAAA==.Reddargon:BAAALAADCgYICgAAAA==.',Sa='Sarden:BAAALAAFFAIIAgAAAA==.',Se='Sergius:BAAALAADCgIIAgAAAA==.',Si='Simpleline:BAAALAAECgYICgAAAA==.',Te='Teslax:BAAALAAECgYIDAAAAA==.',Ti='Titan:BAAALAAECgYIBwAAAA==.',Vi='Vindisel:BAAALAAECgUIBQAAAA==.Vita:BAAALAADCgEIAQAAAA==.',Wi='Winte:BAAALAAECgcIBwAAAA==.',Wv='Wvvw:BAAALAAECgQIBAAAAA==.',Yc='Ycy:BAAALAAFFAIIAgAAAA==.',Zz='Zzx:BAABLAAFFH8IAAIFAAII4xTqLwCfAAAFAAII4xTqLwCfAAAAAA==.',['一一']='一一雪儿一一:BAAALAADCgIIAgAAAA==.',['一千']='一千百度一:BAAALAAECgMIAwAAAA==.',['一女']='一女乃并瓦一:BAAALAADCggICAAAAA==.',['一屋']='一屋化骨龙:BAABLAAFFH8KAAIGAAIIagk2awBQAAAGAAIIagk2awBQAAAAAA==.',['一潜']='一潜规则一:BAAALAADCggICAAAAA==.',['一蕾']='一蕾欧娜一:BAAALAADCgMIAwAAAA==.',['一身']='一身排骨:BAAALAAFFAIIAgAAAA==.',['万物']='万物归一:BAAALAAFFAgIAwAAAA==.',['三圈']='三圈布鲁根:BAAALAAECgIIAgAAAA==.',['三魁']='三魁:BAAALAAFFAIIBAAAAA==.',['不好']='不好吃啊:BAABLAAFFH8IAAIHAAcI7BHQQAA3AQAHAAcI7BHQQAA3AQAAAA==.不好吃噢:BAAALAAECgYIBgAAAA==.',['不敢']='不敢点天赋:BAAALAADCgIIAgAAAA==.',['不落']='不落仓库:BAAALAADCggICAAAAA==.不落战世:BAAALAADCgQIBAAAAA==.',['与你']='与你无关:BAAALAADCgYIBgAAAA==.',['与我']='与我相关:BAAALAAECgQIBAAAAA==.',['专家']='专家:BAABLAAFFH8LAAIBAAUIoxW8EwBQAQABAAUIoxW8EwBQAQAAAA==.',['东浪']='东浪青龙:BAAALAAECgYICgAAAA==.',['丨闇']='丨闇牙丨:BAAALAADCggICAAAAA==.',['丶大']='丶大鸭梨:BAABLAAFFH8IAAMIAAYIbQf2OAC5AAAIAAYIKwP2OAC5AAAJAAIIxA/xJQABAAAAAA==.',['丿丿']='丿丿:BAAALAAECgYIBgAAAA==.',['之前']='之前:BAAALAADCgYIBgAAAA==.',['九月']='九月清晨:BAAALAAECgYIBgAAAA==.',['云斩']='云斩月:BAAALAAECgYIBgAAAA==.',['今夏']='今夏:BAAALAADCgUIBQAAAA==.',['以祺']='以祺丶:BAAALAADCgMIAwAAAA==.',['伊俐']='伊俐蛋蛋:BAAALAADCggICAAAAA==.',['伊莉']='伊莉丹丶怒風:BAAALAADCgIIAgAAAA==.',['会飞']='会飞的小萝莉:BAAALAAFFAIIAwAAAA==.',['余生']='余生如雨绵绵:BAABLAAECn8XAAMKAAgI/SXsAABlAwAKAAgI/SXsAABlAwALAAcIHQAAAAAAAAAAAA==.',['你一']='你一定很大:BAAALAAECgQIBAAAAA==.',['保存']='保存心情:BAAALAADCggIDgAAAA==.',['偶尔']='偶尔会难过:BAAALAADCgEIAQAAAA==.',['傲骨']='傲骨:BAAALAAECgcIBwAAAA==.',['先躺']='先躺为敬:BAABLAAFFH8QAAIDAAYInRmBJQCEAQADAAYInRmBJQCEAQAAAA==.',['光明']='光明研究员:BAABLAAFFH8GAAIBAAMI4AfrIQCTAAABAAMI4AfrIQCTAAAAAA==.',['光翼']='光翼:BAAALAAECgYIBgAAAA==.',['克耳']='克耳苏加德:BAAALAAECgMIAwAAAA==.',['兔斯']='兔斯基:BAABLAAECn8eAAIIAAYIGBprWwBRAQAIAAYIGBprWwBRAQAAAA==.',['八奈']='八奈见:BAACLAAFFH8KAAMIAAIIvQaYWgCGAAAIAAIIvQaYWgCGAAABAAIIJAoRIwB/AAAsAAQKfxQABAkABghmHosRAJgBAAgABgjwGL2rAKUBAAkABgitHYsRAJgBAAEAAwgyB0BrAIYAAAEsAAUUBQggAAoAZCAA.',['八零']='八零後的涛叔:BAAALAAECgYICQAAAA==.',['养不']='养不活:BAAALAAECgcIDQAAAA==.',['军犬']='军犬:BAABLAAFFH8GAAIGAAIIXB01LACrAAAGAAIIXB01LACrAAAAAA==.',['冰鲜']='冰鲜柠檬水:BAAALAAECgUIBQAAAA==.',['冷月']='冷月大王:BAAALAAECgQIBwAAAA==.',['冻结']='冻结的南瓜:BAAALAAECgcICQAAAA==.',['凤求']='凤求凰丶:BAABLAAFFH8GAAICAAIIKBH9SwCQAAACAAIIKBH9SwCQAAAAAA==.',['勇敢']='勇敢的心:BAABLAAECn8UAAIIAAYIqQc0lgDTAAAIAAYIqQc0lgDTAAAAAA==.',['千介']='千介丶茶会凉:BAAALAAFFAQIBAAAAA==.',['卜露']='卜露露:BAAALAAECgEIAQAAAA==.',['卡布']='卡布奇丶諾:BAAALAADCgUIBQAAAA==.',['去伪']='去伪求真:BAAALAAFFAQIBAAAAA==.',['叛逆']='叛逆滴瑜瑜:BAAALAAECgEIAQAAAA==.',['叫我']='叫我女王陛下:BAAALAADCggICQAAAA==.',['叹息']='叹息的微笑:BAAALAAFFAIIAgAAAA==.',['吉姆']='吉姆格霖:BAAALAAECgYICQAAAA==.吉姆格麟:BAABLAAFFH8OAAIGAAQIWREbSwBwAAAGAAQIWREbSwBwAAAAAA==.',['吴英']='吴英俊:BAAALAAFFAIIBAAAAA==.',['周润']='周润發:BAAALAAFFAIIAgAAAA==.',['咕噜']='咕噜哈休:BAAALAAECgYICAAAAA==.',['咖啡']='咖啡加点糖:BAAALAAECgcICQAAAA==.',['啥都']='啥都想试试:BAAALAAFFAEIAQAAAA==.',['嗜血']='嗜血弄生:BAAALAAECgEIAQAAAA==.',['嘉拉']='嘉拉迪雅:BAAALAAFFAMIAwAAAA==.',['嘿丶']='嘿丶嘿嘿:BAAALAADCgEIAQAAAA==.',['噩梦']='噩梦铁锤:BAAALAAECgIIAgAAAA==.',['嚎呦']='嚎呦跟:BAAALAAECgYIBgAAAA==.',['四骑']='四骑:BAAALAADCgQIBAAAAA==.',['圣光']='圣光之殇:BAABLAAFFH8LAAIIAAIIEyX0IQDJAAAIAAIIEyX0IQDJAAABLAAFFAgICQABAIYjAA==.圣光指引:BAAALAAECgYIBgAAAA==.圣光狐児:BAAALAAFFAIIAgAAAA==.圣光的罪孽:BAAALAAECgYICAAAAA==.',['圣歌']='圣歌乐章:BAAALAAFFAEIAQAAAA==.',['圣骑']='圣骑小妹:BAAALAAFFAIIAgAAAA==.',['坦格']='坦格利安:BAACLAAFFH8GAAIFAAIIOxRQMgCcAAAFAAIIOxRQMgCcAAAsAAQKfxwAAgUACAiCGyUvAHwCAAUACAiCGyUvAHwCAAAA.',['塞斯']='塞斯恨:BAABLAAFFH8GAAIBAAIIxQabKgBiAAABAAIIxQabKgBiAAAAAA==.',['复活']='复活节环环:BAABLAAFFH8jAAMMAAYI/BwkDgB+AQAMAAUIFiAkDgB+AQANAAEIbAcBTwA8AAABLAAFFAcIKAAOAHUjAA==.复活节酒桶:BAAALAAECgYIBgAAAA==.',['夏夕']='夏夕言:BAAALAADCgYICAAAAA==.',['夏颉']='夏颉:BAAALAAECgUICgAAAA==.',['大刀']='大刀咔嚓:BAAALAADCgYIBgAAAA==.',['大壮']='大壮的溜溜球:BAAALAAECgcIDwAAAA==.',['大妖']='大妖兽:BAAALAAECgYIBgAAAA==.',['大崎']='大崎娜娜:BAAALAAECgEIAQAAAA==.',['大爱']='大爱仙尊:BAAALAAECgUIBQAAAA==.',['大聪']='大聪明殿下:BAAALAAECgYIBgAAAA==.',['天下']='天下第一魔女:BAAALAAECgQIBQAAAA==.',['天亟']='天亟血影:BAAALAAECgYIDAAAAA==.',['天殛']='天殛血影:BAAALAAECgQIBAAAAA==.',['天涯']='天涯帅帅:BAABLAAFFH8GAAIFAAIIzBUiSgBJAAAFAAIIzBUiSgBJAAAAAA==.',['天真']='天真的橡皮:BAAALAAECgQIBAAAAA==.',['天空']='天空的畅想:BAAALAAECgYIDwAAAA==.',['天行']='天行九歌:BAAALAADCggICAAAAA==.',['天道']='天道有眷:BAABLAAFFH8LAAIHAAMIexOsYQCKAAAHAAMIexOsYQCKAAAAAA==.',['天音']='天音音:BAAALAAECgIIAgAAAA==.',['奥德']='奥德斯:BAACLAAFFH8JAAIPAAQIjhAFbQCIAAAPAAQIjhAFbQCIAAAsAAQKfyYAAg8ABwgCITwfAEECAA8ABwgCITwfAEECAAAA.',['妖豓']='妖豓涂鴉:BAAALAAECgUIBQAAAA==.',['媳妇']='媳妇是只猫:BAAALAAECgYIBgAAAA==.',['媾合']='媾合:BAABLAAECn8YAAIIAAYI9BcWmgDAAQAIAAYI9BcWmgDAAQAAAA==.',['学习']='学习与实践:BAACLAAFFH8oAAIOAAcIdSN6BgBbAgAOAAcIdSN6BgBbAgAsAAQKf10AAg4ACAgnJqkCAPkCAA4ACAgnJqkCAPkCAAAA.',['学术']='学术混子:BAAALAAFFAIIBAAAAA==.',['寻星']='寻星:BAAALAADCggICAAAAA==.',['封于']='封于修:BAAALAAECgEIAQAAAA==.',['射你']='射你丫的:BAAALAAFFAYIBAAAAA==.',['尊尸']='尊尸重盗乀:BAAALAAECgIIAgAAAA==.',['小动']='小动物终结者:BAAALAAECgYICgAAAA==.',['小桃']='小桃子奶爸:BAAALAADCgUIBQAAAA==.',['小牛']='小牛来救你:BAAALAAECgMIAwAAAA==.',['小皮']='小皮娘:BAABLAAECn8XAAIDAAgIDyHVHADeAgADAAgIDyHVHADeAgAAAA==.',['小软']='小软丶追殇:BAAALAAECgEIAQAAAA==.',['尐七']='尐七:BAACLAAFFH8SAAMQAAUIBA99MwAxAQAQAAUIBA99MwAxAQARAAEIawihFgBCAAAsAAQKfx8AAxAABwhAE+eEAIYBABAABwhAE+eEAIYBABEABQhpCnpkAOAAAAAA.',['尐柒']='尐柒:BAABLAAECn8YAAMSAAcIhREPMgBgAQASAAYIHRQPMgBgAQATAAEIFAMuLgANAAAAAA==.',['尒掱']='尒掱栤栤凉:BAAALAADCgYIBgAAAA==.',['尘墨']='尘墨池:BAAALAAFFAIIAgAAAA==.',['尘封']='尘封的旋律:BAABLAAFFH8MAAMFAAUIfwYsLgDnAAAFAAUIfwYsLgDnAAAUAAIIxQDmMQBCAAAAAA==.',['尤娜']='尤娜塔斯:BAACLAAFFH8gAAMKAAUIZCDJCADVAQAKAAUIZCDJCADVAQAVAAIIsAoxEQA0AAAsAAQKfyAAAgoACAiVHzwJAJ0CAAoACAiVHzwJAJ0CAAAA.',['就丑']='就丑一点点:BAAALAAECgYIBgAAAA==.',['岩小']='岩小岩:BAABLAAFFH8KAAISAAIIYRVsPAB9AAASAAIIYRVsPAB9AAAAAA==.',['岸然']='岸然狼哥:BAAALAAECgQIBAAAAA==.',['巧克']='巧克力曲奇:BAAALAAECgYICAAAAA==.',['布袋']='布袋果子:BAAALAAECgIIAgAAAA==.',['希岛']='希岛丶爱里:BAAALAADCgEIAQAAAA==.',['希德']='希德尼娅:BAAALAAFFAIIBAAAAA==.',['幻夏']='幻夏丶:BAAALAAECgYIBgAAAA==.',['影丶']='影丶雪武:BAAALAADCggICAAAAA==.',['德智']='德智体美劳:BAAALAADCgEIAQAAAA==.',['念念']='念念:BAAALAAECgIIAgAAAA==.',['怀念']='怀念那种风情:BAAALAAECggICAAAAA==.',['恶魔']='恶魔术:BAAALAADCgEIAQAAAA==.',['慢半']='慢半拍快半拍:BAAALAAECgYIBgAAAA==.',['我在']='我在你心:BAAALAADCgcIEgAAAA==.',['我本']='我本良人:BAAALAADCgYIBgAAAA==.',['戰天']='戰天龍:BAABLAAFFH8GAAIIAAMIPBsGOgCxAAAIAAMIPBsGOgCxAAAAAA==.',['扒蒜']='扒蒜老洪:BAAALAAECgUIBQAAAA==.',['抒情']='抒情贵公牛:BAAALAAECgYIDAAAAA==.抒情贵谷子:BAAALAAECgcIAwAAAA==.',['抓那']='抓那个小德:BAAALAAECgIIAgAAAA==.',['拂晓']='拂晓吹:BAAALAADCggICAAAAA==.',['拉克']='拉克丝克莱因:BAAALAAECgUIBQAAAA==.',['拿铁']='拿铁加冰:BAABLAAFFH8MAAMWAAYIjxqDFgAoAQAWAAUIJxqDFgAoAQASAAEI7BBcWQA9AAAAAA==.',['持久']='持久的阿昆达:BAABLAAECn8UAAIXAAgIGBy1EACfAgAXAAgIGBy1EACfAgAAAA==.',['挡我']='挡我死:BAAALAADCgYIBgAAAA==.',['摸一']='摸一嗷:BAAALAAECggICAAAAA==.',['撇啊']='撇啊撇:BAAALAAFFAIIAgAAAA==.',['新叁']='新叁各呆镖:BAAALAAECgYIEgAAAA==.',['施主']='施主请留步:BAAALAADCgQIBAAAAA==.',['无尽']='无尽夜幕:BAAALAAECgEIAQAAAA==.',['无敌']='无敌嘟嘟:BAAALAAECgYICgAAAA==.',['无穷']='无穷的火焰:BAABLAAECn8fAAMRAAYI2iJXDgDYAQARAAYI2iJXDgDYAQAQAAYIyxhiMwBEAQAAAA==.',['日小']='日小蛮:BAAALAADCgEIAQAAAA==.',['星月']='星月迷途:BAAALAAECggICQAAAA==.',['暗里']='暗里着迷:BAABLAAECn8aAAIHAAYIWR/MagAgAgAHAAYIWR/MagAgAgAAAA==.',['曉七']='曉七:BAABLAAECn8eAAIHAAYI4Rh7UQBRAQAHAAYI4Rh7UQBRAQAAAA==.',['曉柒']='曉柒:BAAALAAECgYICAAAAA==.',['曾艳']='曾艳芬:BAAALAAFFAIIAwAAAA==.',['會飛']='會飛的狐:BAAALAAECgYICwAAAA==.',['杰瑞']='杰瑞的汤姆猫:BAAALAAECgYIBgAAAA==.',['柒絕']='柒絕鬼牧:BAABLAAFFH8FAAMNAAMIRQRIRgBeAAANAAIIAQZIRgBeAAAMAAMIPAGHLgA5AAAAAA==.',['栤咖']='栤咖啡:BAAALAAFFAIIAgAAAA==.',['栽楞']='栽楞:BAABLAAFFH8HAAICAAMIHg2yQwB6AAACAAMIHg2yQwB6AAAAAA==.',['森林']='森林里的椰子:BAAALAAFFAIIAgABLAAFFAgIEwALAKUiAA==.',['欧迈']='欧迈蕾蒂:BAACLAAFFH8KAAIIAAIIRBt0LwCsAAAIAAIIRBt0LwCsAAAsAAQKfxUAAggABgieICxcADMCAAgABgieICxcADMCAAAA.',['武学']='武学研究员:BAAALAAFFAIIAgAAAA==.',['残隠']='残隠殇丶玥:BAAALAADCggICAABLAAFFAgIBQARAEMdAA==.',['氵水']='氵水犭苗:BAAALAADCgYIAwAAAA==.',['永无']='永无止境:BAABLAAFFH8JAAIJAAIIYwqoHgAuAAAJAAIIYwqoHgAuAAAAAA==.',['沉默']='沉默的高洋:BAABLAAFFH8JAAMQAAYIoBv/BQBJAgAQAAYIoBv/BQBJAgARAAIIfgeoHgAzAAAAAA==.',['沙克']='沙克:BAAALAADCgcIBwAAAA==.',['波波']='波波:BAABLAAFFH8SAAMYAAUIaA4eCwCQAAACAAUIQAqWLwAbAQAYAAQIEw0eCwCQAAABLAAFFAYIIgAHAPYUAA==.',['浅唱']='浅唱灬寂寞:BAAALAAECgYIBgAAAA==.',['浅笑']='浅笑倾安:BAAALAADCgIIAgAAAA==.',['深田']='深田丶由美:BAAALAAECgQIBAAAAA==.',['火刃']='火刃:BAAALAAECgEIAQAAAA==.',['灵灵']='灵灵六:BAAALAAECgEIAQAAAA==.',['灵魂']='灵魂的触摸:BAAALAADCggICAAAAA==.',['炫翼']='炫翼天使:BAAALAADCgQIBAAAAA==.',['炮火']='炮火玫瑰:BAAALAAECgYIDAAAAA==.',['版本']='版本答案:BAAALAAFFAIIAgAAAA==.',['牛中']='牛中的战斗牛:BAAALAAFFAIIAgABLAAFFAIIAgAZAAAAAA==.',['牛小']='牛小鑫:BAAALAAFFAIIAgAAAA==.',['牛氓']='牛氓界扛把子:BAAALAAFFAIIBAAAAA==.',['牧光']='牧光星野:BAAALAAECgUICAAAAA==.',['牧术']='牧术法:BAAALAAECgMIAwAAAA==.',['狂浪']='狂浪啊狂浪:BAAALAAECggIEAABLAAFFAgIDAAaAAwdAA==.',['狂野']='狂野白犀:BAAALAADCgUIBQAAAA==.',['独嗨']='独嗨:BAABLAAFFH8FAAIPAAIIaQtOqgA6AAAPAAIIaQtOqgA6AAAAAA==.',['猎兔']='猎兔犬:BAAALAAECgMIAwAAAA==.',['猎小']='猎小猎:BAAALAAFFAIIAwAAAA==.',['猪丫']='猪丫头:BAAALAAFFAIIBAAAAA==.',['玉米']='玉米:BAABLAAFFH8GAAIIAAII5hLIPgCfAAAIAAII5hLIPgCfAAAAAA==.玉米粒:BAAALAAECgYIBgAAAA==.',['王者']='王者之剑:BAAALAADCgMIAwAAAA==.',['玩好']='玩好就去学习:BAABLAAFFH8JAAIRAAII+hxwFABGAAARAAII+hxwFABGAAAAAA==.玩好立刻学习:BAABLAAFFH8GAAICAAIIERMvTgBLAAACAAIIERMvTgBLAAABLAAFFAgIAQAZAAAAAA==.',['玩完']='玩完就去学习:BAAALAAFFAIIAgAAAA==.玩完马上学习:BAABLAAFFH8HAAIbAAIIvwpHHABFAAAbAAIIvwpHHABFAAAAAA==.',['玲珑']='玲珑仔仔:BAAALAADCgEIAQAAAA==.',['瓦利']='瓦利椰:BAABLAAFFH8GAAIPAAIIcBBckQBEAAAPAAIIcBBckQBEAAAAAA==.',['瓦勒']='瓦勒个驱:BAAALAAECgMIAwAAAA==.',['甜蜜']='甜蜜的烏瑟尔:BAAALAAECgUIBQAAAA==.',['电疗']='电疗萨:BAABLAAFFH8GAAIcAAIIEwZUCAA6AAAcAAIIEwZUCAA6AAAAAA==.',['白孔']='白孔雀:BAAALAADCggICgAAAA==.',['白旗']='白旗大表哥:BAAALAAECgcIDQAAAA==.',['白骑']='白骑大队长:BAAALAAFFAIIBAAAAA==.',['看你']='看你那猴样:BAAALAAECgIIAwAAAA==.',['眷恋']='眷恋咖啡:BAAALAAFFAIIAgAAAA==.',['睡不']='睡不醒:BAAALAAECgYIBgAAAA==.',['神之']='神之小锅:BAAALAAECggICAAAAA==.',['神德']='神德小妞妞:BAABLAAFFH8JAAISAAIIOhUNPAB+AAASAAIIOhUNPAB+AAAAAA==.',['禁忌']='禁忌誓约者:BAAALAAFFAMIAwAAAA==.',['空白']='空白人生:BAABLAAFFH8KAAMTAAII8gzkDgApAAATAAII8gzkDgApAAAdAAIIxQPrEQAnAAAAAA==.',['窝窝']='窝窝四一:BAABLAAFFH8GAAMNAAYIKQMiKADuAAANAAUIPAMiKADuAAAMAAEIsQQvLQA8AAAAAA==.窝窝四七:BAABLAAFFH8LAAMNAAYIIRGxGwBxAQANAAYIIRGxGwBxAQAMAAEIwwFpMAAyAAAAAA==.窝窝四二:BAABLAAFFH8GAAMNAAYIDwhUJgAEAQANAAUIEAZUJgAEAQAMAAEIqAOdLQA7AAAAAA==.窝窝四八:BAABLAAFFH8MAAMNAAYIhAxXHQBiAQANAAYIhAxXHQBiAQAMAAEIMwS2LQA7AAAAAA==.窝窝四四:BAABLAAFFH8GAAMNAAYImAQTJwD7AAANAAUI7QQTJwD7AAAMAAEIqARJLQA8AAAAAA==.窝窝四零:BAAALAAFFAgIBAAAAA==.',['米诺']='米诺桃:BAAALAAECgYIBgAAAA==.',['粥润']='粥润发:BAACLAAFFH8+AAMeAAcIaQ7VAAA+AQAeAAUIXhLVAAA+AQAUAAcIMggxDAAFAQAsAAQKfxgAAx4ABggPDFENALkAAB4ABQh5DVENALkAABQABgjtBLV0ALYAAAAA.',['绿肥']='绿肥紅瘦:BAAALAADCgMIAwAAAA==.',['群尸']='群尸玩过界:BAABLAAECn8WAAINAAYI4RU2YABdAQANAAYI4RU2YABdAQAAAA==.',['翎兰']='翎兰:BAABLAAFFH8JAAIIAAYIZwUbDwBXAQAIAAYIZwUbDwBXAQAAAA==.',['翡翠']='翡翠捕梦者:BAACLAAFFH8lAAIWAAcIKyQBBABaAgAWAAcIKyQBBABaAgAsAAQKfxsAAhYACAjDJFUGAE0DABYACAjDJFUGAE0DAAAA.',['老孟']='老孟:BAAALAAECgcICwAAAA==.',['耳语']='耳语声烦:BAABLAAFFH8GAAICAAYI8xDNIQB4AQACAAYI8xDNIQB4AQAAAA==.',['聖徒']='聖徒:BAAALAAFFAIIAgAAAA==.',['肌肉']='肌肉是美德:BAAALAAECgcIBwAAAA==.',['肥暴']='肥暴猎:BAAALAADCgMIAwAAAA==.',['肾光']='肾光的力量:BAAALAAECgMIAwAAAA==.',['自己']='自己做主:BAABLAAECn8UAAIIAAYIewyImwDJAAAIAAYIewyImwDJAAAAAA==.',['舍弃']='舍弃的刀锋:BAAALAADCgIIBAAAAA==.',['艾薇']='艾薇儿拉惟尼:BAAALAADCgIIAgAAAA==.',['节约']='节约:BAABLAAFFH8KAAIDAAII1BG1TgCDAAADAAII1BG1TgCDAAAAAA==.',['芋圆']='芋圆葡萄:BAAALAAECgYICQAAAA==.',['芒果']='芒果超人:BAAALAAECgYICgAAAA==.',['芝士']='芝士奶盖红茶:BAAALAAECgYICwAAAA==.',['芡甩']='芡甩尒崬覀:BAAALAAECgYIBgAAAA==.',['芹泽']='芹泽多余熊:BAAALAADCgYIAwAAAA==.芹泽多摩熊:BAAALAADCggICAAAAA==.',['英雄']='英雄的心恶魔:BAAALAAECgQIBQAAAA==.',['菠萝']='菠萝百香果:BAAALAAECgYIDAAAAA==.',['萨哇']='萨哇迪咖:BAAALAADCgIIAgAAAA==.',['落星']='落星丶末世:BAAALAAECgcIDAAAAA==.',['薛神']='薛神:BAAALAADCgEIAQAAAA==.',['蜂蜜']='蜂蜜柚子茶:BAAALAAECgIIAgAAAA==.',['蜡笔']='蜡笔灬小萨:BAABLAAFFH8HAAIGAAMIOQ60RgCSAAAGAAMIOQ60RgCSAAAAAA==.',['血之']='血之光辉:BAAALAADCgEIAQAAAA==.',['血腥']='血腥飝非飛:BAACLAAFFH8GAAIRAAIIbhmVDwCRAAARAAIIbhmVDwCRAAAsAAQKfx4AAhEACAjgIrYHABkDABEACAjgIrYHABkDAAAA.',['血魔']='血魔猎首:BAAALAADCgIIAgAAAA==.',['谁是']='谁是老登:BAAALAAECgYICAAAAA==.',['贝阿']='贝阿朵莉切卿:BAACLAAFFH8HAAICAAQIyRczMwDvAAACAAQIyRczMwDvAAAsAAQKfyEAAgIACAidIEUKAKICAAIACAidIEUKAKICAAAA.',['贝露']='贝露丹蒂:BAAALAAECgYICgAAAA==.',['赞赞']='赞赞敲可爱:BAABLAAFFH8FAAIPAAIIrAVTuwAtAAAPAAIIrAVTuwAtAAAAAA==.',['越努']='越努力越努力:BAABLAAECn8dAAIGAAgIDRZcSQADAgAGAAgIDRZcSQADAgAAAA==.',['躺尸']='躺尸老板:BAAALAAFFAIIBAAAAA==.',['辰曦']='辰曦:BAACLAAFFH8aAAIIAAUIURL5KAA0AQAIAAUIURL5KAA0AQAsAAQKf1QAAggACAiAHmcTAHICAAgACAiAHmcTAHICAAAA.',['这是']='这是个国宝:BAAALAAECgYIBgAAAA==.',['迪俪']='迪俪热巴:BAAALAAFFAIIBAAAAA==.',['追风']='追风之影:BAAALAAECgYIBgAAAA==.',['逍遥']='逍遥灬神话:BAAALAAECgQIBAAAAA==.',['遇术']='遇术淋疯:BAAALAAECgMIAwAAAA==.',['邪恶']='邪恶的南瓜:BAABLAAECn8bAAQEAAgInR0rHwD5AAAfAAMI4B72XAADAQAEAAMIcyArHwD5AAADAAQI1xhUdQCeAAAAAA==.',['酒仙']='酒仙:BAAALAAECggICAABLAAFFAgIBgABAOIhAA==.',['酒醉']='酒醉無眠:BAABLAAECn8XAAIgAAYIcBfLIgClAQAgAAYIcBfLIgClAQAAAA==.',['金刚']='金刚护体:BAAALAAECggIEAAAAA==.',['鉛华']='鉛华淡淡妆成:BAAALAAECgYIBgAAAA==.',['鉛華']='鉛華淡淡妝成:BAAALAAECgYIBgAAAA==.',['钢铁']='钢铁巅峰:BAABLAAFFH8GAAIUAAYIxgfoFgD5AAAUAAYIxgfoFgD5AAAAAA==.',['锐雯']='锐雯:BAAALAAFFAIIBAAAAA==.',['阿伊']='阿伊古丽娜:BAAALAAECgQIBAAAAA==.',['零零']='零零八:BAAALAAECgYICQAAAA==.零零小龙人:BAAALAAECgQIBAAAAA==.',['雾漫']='雾漫了風景:BAABLAAFFH8KAAIPAAIIagwNbQCCAAAPAAIIagwNbQCCAAAAAA==.',['霍森']='霍森布鲁兹丶:BAABLAAFFH8KAAIPAAIIdiQ/KQDZAAAPAAIIdiQ/KQDZAAAAAA==.',['青一']='青一鸟:BAAALAAECgMIAwAAAA==.',['青提']='青提肉多多:BAAALAADCgUIBQAAAA==.',['风暴']='风暴霜语:BAAALAADCggICAAAAA==.',['飞天']='飞天遁地:BAABLAAECn8WAAICAAYIViBwVwAfAgACAAYIViBwVwAfAgAAAA==.',['馨雨']='馨雨雲梦:BAAALAADCggICAAAAA==.',['驱灵']='驱灵人:BAABLAAFFH8KAAMNAAYIbyXSBACFAgANAAYIbyXSBACFAgAMAAMIDB1yHQCgAAAAAA==.',['骑士']='骑士传奇:BAAALAAECgYIBgAAAA==.',['骑猪']='骑猪去流浪:BAABLAAFFH8JAAMgAAIIZhuNCwC5AAAgAAIIZhuNCwC5AAAHAAIIXQ3+hgBCAAAAAA==.',['鯊魚']='鯊魚辣椒:BAAALAAECgQIBgAAAA==.',['鱼丸']='鱼丸粗面:BAAALAAECgYICgAAAA==.',['鷄丶']='鷄丶:BAAALAADCgEIAQAAAA==.',['鸡腿']='鸡腿好香:BAAALAAECgYICwAAAA==.',['黎明']='黎明前的圣光:BAAALAAECgYIBwAAAA==.',['黑吃']='黑吃黑:BAAALAAECgYIBgAAAA==.',['黑夜']='黑夜丶传说:BAAALAAECgUIBAAAAA==.',['黑暗']='黑暗阿尔法:BAAALAAECgYIBgAAAA==.',['黑石']='黑石山老兵:BAAALAAFFAIIAgAAAA==.',['黑銫']='黑銫葬禮灬:BAAALAAECgMIAwAAAA==.',['龙血']='龙血之刃:BAACLAAFFH8GAAMRAAYImwB+IgAPAAAQAAQISwDSbAARAAARAAIIOgF+IgAPAAAsAAQKfxkAAxEACAjJF4oOANYBABEACAjJF4oOANYBABAAAggFBVJ9AA0AAAAA.',['龙雪']='龙雪幻象:BAAALAAFFAMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end