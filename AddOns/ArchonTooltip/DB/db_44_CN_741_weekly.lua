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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Paladin-Holy','Shaman-Restoration','Hunter-BeastMastery','DemonHunter-Havoc','DeathKnight-Frost','DeathKnight-Blood','Druid-Balance','Priest-Holy','Evoker-Augmentation','Warrior-Protection','Paladin-Retribution','Priest-Shadow','Shaman-Elemental','Hunter-Survival','Hunter-Marksmanship','Monk-Windwalker','Monk-Mistweaver','Evoker-Preservation','Druid-Restoration','Paladin-Protection','Monk-Brewmaster','Mage-Arcane','Warrior-Fury','Mage-Frost','Priest-Discipline',}; local provider = {region='CN',realm='火烟之谷',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ah='Ahnqiraj:BAABLAAFFH8QAAMBAAMIYQehUgBqAAABAAMIqAShUgBqAAACAAEIxAtRKwBMAAAAAA==.',Al='Alabibi:BAABLAAFFH8GAAIDAAIItxdBIgCQAAADAAIItxdBIgCQAAAAAA==.',Bl='Blackpeople:BAAALAAECgIIAgAAAA==.',Ca='Catiam:BAAALAAFFAIIAgAAAA==.',Cl='Cleanhh:BAABLAAFFH8JAAIEAAII1g6mWQBnAAAEAAII1g6mWQBnAAAAAA==.',Cs='Csniper:BAAALAAFFAEIAQAAAA==.',De='Deathknight:BAAALAAECgMIAwAAAA==.',Do='Dorabbit:BAAALAAFFAIIAgAAAA==.',Eo='Eos:BAAALAAECgMIAwABLAAFFAIIBgAFAIMTAA==.',Fi='Fishiam:BAAALAAFFAIIAgABLAAFFAYICwAGALgKAA==.Fiveci:BAAALAAFFAIIAQAAAA==.',Fo='Fourthlk:BAABLAAFFH8KAAIHAAYIFQvWPgA/AQAHAAYIFQvWPgA/AQAAAA==.',Hy='Hyperrun:BAACLAAFFH8LAAIGAAYIuArAKABMAQAGAAYIuArAKABMAQAsAAQKfxcAAgYABgiLHZQ0AIYBAAYABgiLHZQ0AIYBAAAA.',Jo='Joannate:BAAALAAECgIIAgAAAA==.',Jy='Jyjyjy:BAAALAAFFAIIBAAAAA==.',Ke='Kenshinmage:BAAALAAECggICAAAAA==.',Lo='Lorabbit:BAAALAAFFAIIAgAAAA==.',Ma='Macan:BAAALAAECgQICAAAAA==.',Me='Meroy:BAAALAAECggICAAAAA==.',Mi='Miller:BAAALAADCgQIBAAAAA==.',Mo='Mograine:BAAALAAFFAIIAgABLAAFFAgIGwAIAPIcAA==.',No='Nopmop:BAABLAAFFH8HAAIJAAYI1AaBGwD4AAAJAAYI1AaBGwD4AAAAAA==.',Nt='Ntr:BAACLAAFFH8QAAIHAAMIth4tSwClAAAHAAMIth4tSwClAAAsAAQKfxsAAgcABwhpILNeADgCAAcABwhpILNeADgCAAAA.',Ol='Oldtang:BAAALAAECgYIBgAAAA==.Oldwang:BAAALAAECgYIBwAAAA==.',Pa='Paladinzero:BAAALAAECggICAAAAA==.',Ra='Ralegh:BAAALAAFFAQIBAAAAA==.',Sa='Salute:BAABLAAFFH8GAAIKAAYIig7BGwBwAQAKAAYIig7BGwBwAQABLAAFFAgIIgALADcYAA==.',St='Stoneheart:BAAALAAECgYIBgAAAA==.',Sx='Sxmama:BAAALAAECgIIAgAAAA==.',Tr='Trickster:BAAALAAFFAIIBAAAAA==.',Vo='Voidelfmage:BAAALAAFFAYIAgAAAA==.',Wr='Wr:BAAALAAECgYIBgAAAA==.',Wu='Wuyulunbi:BAABLAAECn8VAAIGAAYIah2zdgDYAQAGAAYIah2zdgDYAQAAAA==.',['一生']='一生荣耀:BAABLAAFFH8GAAIFAAIIOx9KQgCjAAAFAAIIOx9KQgCjAAAAAA==.',['一秒']='一秒六棍:BAABLAAFFH8GAAIMAAYIAgqMFQANAQAMAAYIAgqMFQANAQAAAA==.',['万日']='万日亿:BAAALAAECgYIBgAAAA==.',['三脚']='三脚猫丶跑:BAABLAAFFH8GAAIEAAYI6xe3FAC6AQAEAAYI6xe3FAC6AQABLAAFFAgIDQAEAGwSAA==.',['不吃']='不吃人头:BAABLAAFFH8GAAIIAAYIXQmdDgAbAQAIAAYIXQmdDgAbAQAAAA==.',['不要']='不要问问题:BAABLAAFFH8GAAINAAIIhwrPbABAAAANAAIIhwrPbABAAAAAAA==.',['丗界']='丗界:BAAALAADCgMIAwAAAA==.',['东师']='东师第一死骑:BAAALAAFFAIIBAAAAA==.',['丢失']='丢失:BAAALAAECgYIBgABLAAFFAgIHAAJAOIkAA==.',['两仪']='两仪未那丶:BAAALAAECggIDQAAAA==.',['丨悠']='丨悠悠丨:BAAALAADCggICwAAAA==.',['中大']='中大渣网速:BAAALAAECggIBQAAAA==.中大烧火棍:BAAALAAECgYIBgABLAAFFAgIEgAJAHkdAA==.',['丶好']='丶好人兄:BAABLAAFFH8FAAIFAAUIwwzCVQD2AAAFAAUIwwzCVQD2AAAAAA==.',['丶晴']='丶晴空:BAAALAAECgEIAQAAAA==.',['丶梵']='丶梵:BAABLAAFFH8GAAMKAAYIqhS2HQBfAQAKAAUIlRW2HQBfAQAOAAEIcxNDJQBPAAAAAA==.',['丶楼']='丶楼影:BAAALAAECgYIBgAAAA==.',['丶流']='丶流萤:BAAALAAECgYICAAAAA==.',['丶瑶']='丶瑶:BAAALAAECgYIDAAAAA==.',['丷小']='丷小老登丷:BAAALAAECggIBgAAAA==.',['为爱']='为爱战死床头:BAAALAAECgYIEwAAAA==.',['乧嵿']='乧嵿:BAAALAADCgcIBwAAAA==.',['云刀']='云刀斩仙:BAAALAADCgYIBgAAAA==.',['云想']='云想衣裳:BAAALAAECgIIAgAAAA==.',['亚里']='亚里莎:BAABLAAFFH8GAAIFAAYIGApnRQA0AQAFAAYIGApnRQA0AQAAAA==.',['今晚']='今晚吃鸡:BAAALAAECggIBAAAAA==.',['从新']='从新开始:BAACLAAFFH8IAAINAAUIMBHJKQAwAQANAAUIMBHJKQAwAQAsAAQKfyQAAg0ABghyIMI5ALABAA0ABghyIMI5ALABAAAA.',['仙熊']='仙熊掌和鱼:BAAALAAECgYIDAAAAA==.',['以德']='以德福人:BAAALAAECgYICwAAAA==.',['伯牙']='伯牙绝弦:BAAALAAECgYIBgAAAA==.',['何灬']='何灬必:BAAALAAECgYIBgAAAA==.',['你看']='你看我肥吗:BAABLAAFFH8SAAMPAAYIihWIDAC3AQAPAAUI3hWIDAC3AQAEAAUI2xxQHQByAQABLAAFFAgIEgAPAIQYAA==.',['傀影']='傀影:BAAALAAECgUIBQAAAA==.',['入夜']='入夜:BAAALAAFFAIIAQAAAA==.',['公正']='公正使者:BAAALAAFFAIIAgAAAA==.',['冬瓜']='冬瓜煲腿:BAAALAADCgEIAQAAAA==.',['冰淇']='冰淇淋哭了:BAAALAAECgQIBAAAAA==.',['冷血']='冷血:BAAALAAFFAIIBAAAAA==.',['割头']='割头者:BAAALAAFFAMIBAAAAA==.',['劣人']='劣人突然:BAAALAAFFAQIBAAAAA==.',['劫持']='劫持上帝:BAABLAAFFH8NAAIPAAIIKxwAIwCjAAAPAAIIKxwAIwCjAAAAAA==.',['勇敢']='勇敢牛牛不怕:BAAALAAFFAIIAgAAAA==.',['十分']='十分:BAAALAADCgcIBwAAAA==.',['千面']='千面红:BAACLAAFFH8FAAIFAAIIKA8llABDAAAFAAIIKA8llABDAAAsAAQKfxwABAUACAgQD1WwAAMBABAABQi4ClcYACABAAUACAgTClWwAAMBABEABQgWDfJ+AN8AAAAA.',['南波']='南波菟:BAABLAAECn8VAAMSAAYIzQZpJwC6AAASAAYIzQZpJwC6AAATAAYInQceIgCwAAAAAA==.',['叫我']='叫我蘑菇头:BAAALAADCgYIBgAAAA==.',['可乐']='可乐:BAAALAAFFAEIAQAAAA==.',['吾皇']='吾皇公孙:BAAALAADCgMIAwAAAA==.',['咔叽']='咔叽丶麻辣油:BAAALAAECgMICAAAAA==.',['哈基']='哈基米哈基米:BAABLAAFFH8JAAIUAAgIghTZHgBJAAAUAAgIghTZHgBJAAAAAA==.',['啊哦']='啊哦水水:BAABLAAFFH8HAAMJAAYILQupFgAnAQAJAAYILQupFgAnAQAVAAEIEQjbWwA2AAAAAA==.',['囗一']='囗一囗:BAAALAAFFAIIBAAAAA==.',['囗毌']='囗毌囗:BAAALAAECgEIAQAAAA==.',['囗罒']='囗罒囗:BAAALAAECgYIBgAAAA==.',['圆头']='圆头耄耋:BAAALAAFFAgIBAAAAA==.',['圣光']='圣光崽崽:BAAALAAECggIBgAAAA==.圣光毛豆:BAAALAAECgMIAwAAAA==.圣光湛橙:BAABLAAFFH8GAAIBAAIImAmrSwCIAAABAAIImAmrSwCIAAAAAA==.',['圣骑']='圣骑式:BAAALAAECgYIBgAAAA==.',['墨二']='墨二:BAAALAAECgQIBAAAAA==.',['复姓']='复姓上官:BAAALAAECgYIEAAAAA==.',['夕月']='夕月:BAAALAAECgYIBgAAAA==.',['多特']='多特萌德:BAABLAAFFH8GAAIGAAIIxhETVgBFAAAGAAIIxhETVgBFAAAAAA==.',['夜之']='夜之穗:BAAALAAFFAMIAwAAAA==.夜之颂:BAAALAAFFAIIAgAAAA==.',['夜澜']='夜澜:BAAALAAECggICAAAAA==.',['夜的']='夜的渡船:BAABLAAFFH8LAAMJAAUIOBgtJwB6AAAJAAMIKw8tJwB6AAAVAAMILg7oPQB5AAAAAA==.',['夜羽']='夜羽:BAAALAAFFAIIAgAAAA==.',['天气']='天气晴朗:BAAALAAECgEIAQAAAA==.',['天要']='天要下雨:BAAALAAECgIIAgAAAA==.',['天道']='天道人和:BAAALAAFFAMIAwAAAA==.',['太年']='太年轻:BAAALAAFFAIIAgAAAA==.',['女王']='女王不叫:BAAALAAECgMICAAAAA==.',['女祭']='女祭司:BAAALAAECgYICAAAAA==.',['好气']='好气宝宝:BAAALAAECgMIBgAAAA==.',['好猫']='好猫二丫:BAAALAADCgYIBgAAAA==.',['如果']='如果丶尐圣:BAACLAAFFH8GAAINAAQIrQ4qRwB+AAANAAQIrQ4qRwB+AAAsAAQKfxcAAw0ACAgCHFlKAF4CAA0ACAh8GllKAF4CABYABghBEr8+AEEBAAAA.',['孤独']='孤独根号三:BAACLAAFFH8OAAIMAAMIVAfSFwCaAAAMAAMIVAfSFwCaAAAsAAQKfxoAAgwABwj5Fy4lAB8BAAwABwj5Fy4lAB8BAAAA.',['宇智']='宇智波丶全需:BAABLAAFFH8GAAIXAAYIaw+WEABBAQAXAAYIaw+WEABBAQAAAA==.',['安卓']='安卓:BAAALAAECgYIEwAAAA==.',['完美']='完美无瑕:BAAALAAECggIEAAAAA==.',['宝宝']='宝宝勋:BAAALAAECggICAAAAA==.',['富贵']='富贵丶:BAAALAAFFAYIBAAAAA==.',['对唔']='对唔嗨住啊:BAABLAAECn8WAAQFAAgIch0NQgBhAgAFAAgIQxwNQgBhAgAQAAUI9QlTGAAgAQARAAMIrhhXhADNAAAAAA==.',['小倩']='小倩儿:BAAALAAECgYIBgAAAA==.',['小小']='小小懒河:BAABLAAFFH8GAAIUAAYIpgorBgCYAQAUAAYIpgorBgCYAQAAAA==.小小檑:BAABLAAFFH8GAAIYAAYI7AOEOQD/AAAYAAYI7AOEOQD/AAAAAA==.小小雷:BAABLAAFFH8GAAIZAAYIyBOJHgB1AQAZAAYIyBOJHgB1AQAAAA==.',['小屠']='小屠屠逐日者:BAAALAAFFAEIAQAAAA==.',['小愛']='小愛丶吥糾結:BAABLAAFFH8GAAIFAAYIag+qPgBLAQAFAAYIag+qPgBLAQAAAA==.',['小熊']='小熊我爱你:BAABLAAFFH8MAAIHAAIIeBPyXQCZAAAHAAIIeBPyXQCZAAAAAA==.',['小牛']='小牛叉:BAAALAAECgQIBgAAAA==.',['小狐']='小狐娘:BAAALAAECgYICQAAAA==.',['小说']='小说两句:BAABLAAFFH8GAAIEAAYIihtBEQDaAQAEAAYIihtBEQDaAQAAAA==.',['小趴']='小趴河:BAABLAAFFH8IAAIUAAYIcRr4BgAHAgAUAAYIcRr4BgAHAgAAAA==.',['小锤']='小锤十八丶:BAAALAAECgMIAwAAAA==.',['小风']='小风车:BAAALAADCgIIAgAAAA==.',['小鱼']='小鱼儿:BAAALAAECgYICgAAAA==.',['尛丫']='尛丫头:BAAALAAECgUICAAAAA==.',['尛娟']='尛娟娟:BAABLAAFFH8LAAIGAAYIfx6dCAAVAgAGAAYIfx6dCAAVAgAAAA==.',['山南']='山南:BAAALAAECgUIBQAAAA==.',['布甲']='布甲玩家:BAAALAAFFAIIBAAAAA==.',['帅就']='帅就可以了:BAAALAADCgIIAgAAAA==.',['帅气']='帅气小贼:BAAALAAFFAEIAQAAAA==.',['幼儿']='幼儿园战神:BAAALAAECgMIAwAAAA==.',['幽暗']='幽暗的天空:BAAALAAECggIDgAAAA==.',['库来']='库来鲁:BAABLAAFFH8YAAIUAAgISBiiAQBOAgAUAAgISBiiAQBOAgAAAA==.',['弑杀']='弑杀末日:BAAALAAECgQIAQAAAA==.',['当零']='当零钓翘嘴:BAAALAADCggICAAAAA==.',['很多']='很多人突然:BAAALAAECggICAAAAA==.',['微风']='微风游龙:BAABLAAFFH8KAAIBAAUITBWcNABAAQABAAUITBWcNABAAQAAAA==.',['德世']='德世:BAAALAADCgcIBwAAAA==.',['德拉']='德拉克:BAAALAAFFAgIBAAAAA==.',['德玛']='德玛西亚之翼:BAABLAAECn8XAAIFAAcIYx4UUwCdAQAFAAcIYx4UUwCdAQAAAA==.',['心跳']='心跳零距离:BAAALAADCgMIAwAAAA==.',['忘了']='忘了忘记:BAAALAAFFAIIBAAAAA==.',['念香']='念香:BAAALAAFFAEIAQAAAA==.',['憨态']='憨态可鞠:BAAALAAECgIIAgAAAA==.',['憨憨']='憨憨猪大虫:BAABLAAFFH8GAAIUAAYI7wW8EAAdAQAUAAYI7wW8EAAdAQAAAA==.',['成都']='成都优熊:BAAALAAECggICAAAAA==.',['我爱']='我爱苹果:BAAALAAECggICAAAAA==.',['战争']='战争制造者:BAABLAAFFH8MAAIZAAYIcBkJDADXAQAZAAYIcBkJDADXAQAAAA==.',['手打']='手打龙肉丸:BAABLAAFFH8IAAIUAAgIAAqWBwD2AQAUAAgIAAqWBwD2AQAAAA==.',['拉莎']='拉莎加尔:BAAALAAFFAIIAgAAAA==.',['挡你']='挡你的虔诚:BAAALAAFFAEIAQAAAA==.',['搞灬']='搞灬毛:BAAALAAECgYIDwAAAA==.',['搞部']='搞部落:BAAALAAECgYICgAAAA==.',['斯嘉']='斯嘉蒂之眼:BAAALAADCggICAAAAA==.',['方飞']='方飞卧熏鸡蛋:BAABLAAFFH8GAAIGAAIIAxYdOQCfAAAGAAIIAxYdOQCfAAAAAA==.',['时间']='时间都去哪了:BAAALAAFFAIIAgAAAA==.',['昊天']='昊天女夭:BAAALAAECgYICQAAAA==.',['暗之']='暗之六:BAAALAAFFAIIAgAAAA==.暗之刚:BAAALAAFFAMIAwAAAA==.',['暮光']='暮光幼龙:BAAALAAECgQIBgAAAA==.',['暴力']='暴力柚柚:BAAALAAECgYICAAAAA==.',['曼波']='曼波哈基米:BAABLAAFFH8IAAIUAAgItBAbBgAhAgAUAAgItBAbBgAhAgAAAA==.',['曾经']='曾经很小德:BAAALAAECgYIBgAAAA==.',['月意']='月意紫影:BAAALAAECgQIBAAAAA==.',['板子']='板子依然在:BAAALAAECgIIAgAAAA==.',['板都']='板都板不脱:BAABLAAFFH8VAAINAAYIqwv0KQAvAQANAAYIqwv0KQAvAQAAAA==.',['桃之']='桃之妖妖:BAAALAAFFAIIBAAAAA==.',['梦境']='梦境守护者:BAAALAAECgYICAAAAA==.',['梧夜']='梧夜飘逝:BAABLAAFFH8IAAIDAAIIAwENKABeAAADAAIIAwENKABeAAAAAA==.',['梧桐']='梧桐栖凤:BAAALAAECgIIAgAAAA==.',['森萝']='森萝小鹿:BAAALAAFFAMIAwAAAA==.',['楓葉']='楓葉:BAABLAAECn8bAAIHAAYIkSCaMAC0AQAHAAYIkSCaMAC0AQAAAA==.',['楼小']='楼小影:BAAALAAECgYICgAAAA==.',['欧曼']='欧曼之伤:BAAALAAECgUIBgAAAA==.',['武装']='武装戍卫:BAAALAADCgMIAwAAAA==.',['泥巴']='泥巴女人和狗:BAAALAAECgQIBAAAAA==.',['泼墨']='泼墨宣白丶:BAAALAAECgYIBwAAAA==.',['洛必']='洛必达法则:BAAALAAECgUIBwAAAA==.',['洛莉']='洛莉塔:BAAALAAECgcIBwAAAA==.',['津门']='津门一条龙:BAAALAAFFAIIAgAAAA==.',['浏生']='浏生生:BAAALAAFFAIIBAAAAA==.',['浩劫']='浩劫:BAAALAAFFAEIAQAAAA==.',['浪里']='浪里小白:BAAALAAECgMIAwAAAA==.',['淘气']='淘气女孩:BAABLAAECn8lAAQNAAgIuh76EQB+AgANAAgIuh76EQB+AgAWAAcI4g/TGwAyAQADAAIIOQdBdgBNAAAAAA==.',['深刈']='深刈:BAAALAAECgMIAwAAAA==.',['温驯']='温驯的马尾:BAAALAAFFAIIAgAAAA==.',['滚豆']='滚豆豆:BAAALAAECgMIBAAAAA==.',['漂亮']='漂亮的美眉:BAABLAAFFH8MAAIHAAIIdxLMgQBFAAAHAAIIdxLMgQBFAAAAAA==.',['火车']='火车华:BAAALAAECgYIBgAAAA==.',['灵魂']='灵魂猪:BAABLAAFFH8GAAIMAAYIvwViHACgAAAMAAYIvwViHACgAAAAAA==.',['烈刃']='烈刃:BAACLAAFFH8RAAIFAAUIDg8NVAD/AAAFAAUIDg8NVAD/AAAsAAQKfxkAAgUABwjvHWsqAA4CAAUABwjvHWsqAA4CAAAA.',['焱调']='焱调调:BAAALAADCgYIBgAAAA==.',['煞蛮']='煞蛮姬咝:BAABLAAFFH8JAAIEAAII/BnfRACXAAAEAAII/BnfRACXAAAAAA==.',['熊熊']='熊熊我爱你:BAAALAAECgYIBgAAAA==.',['犯困']='犯困的水煮蛋:BAABLAAFFH8IAAIYAAIICBxSPwCgAAAYAAIICBxSPwCgAAABLAAFFAgICAAYAMQcAA==.犯困的溏心蛋:BAABLAAFFH8PAAIZAAUIRwrTLAD3AAAZAAUIRwrTLAD3AAAAAA==.犯困的荷包蛋:BAABLAAFFH8IAAIBAAIILRKdPACbAAABAAIILRKdPACbAAAAAA==.',['狂怒']='狂怒咩咩:BAAALAAFFAIIAgAAAA==.',['狂暴']='狂暴的女人:BAAALAAECgYICwAAAA==.',['独闯']='独闯夜店:BAAALAAECgUIBQAAAA==.',['猎丶']='猎丶人幻影:BAAALAAFFAEIAQAAAA==.',['猎尽']='猎尽天下靓妞:BAABLAAECn8ZAAIFAAcIzA0PpQATAQAFAAcIzA0PpQATAQAAAA==.',['珍妮']='珍妮玛丶待劲:BAAALAAECgYIDQAAAA==.珍妮玛丶戴静:BAAALAAECgIIAgAAAA==.',['番石']='番石榴榨汁:BAAALAADCgcIBwAAAA==.',['皓皓']='皓皓我爱你:BAAALAAFFAIIAgAAAA==.',['皮卡']='皮卡丘一号:BAAALAAECgYICwAAAA==.',['皮蛋']='皮蛋龙肉粥:BAABLAAFFH8HAAIUAAcIcQ+lCQDAAQAUAAcIcQ+lCQDAAQAAAA==.',['盖侬']='盖侬:BAAALAAECggIDQAAAA==.',['矮壮']='矮壮郭富城:BAAALAAECgYIDwAAAA==.',['碧涟']='碧涟含烟:BAAALAAECgYIBgAAAA==.',['空明']='空明:BAAALAAECggICAAAAA==.',['米拉']='米拉:BAAALAAECgMIAwAAAA==.',['絕戀']='絕戀:BAACLAAFFH8GAAINAAIIWBvqVABNAAANAAIIWBvqVABNAAAsAAQKfxgAAg0ACAgtHzNJAGECAA0ACAgtHzNJAGECAAAA.',['红疙']='红疙瘩:BAAALAAECgUIBQAAAA==.',['罡哥']='罡哥股票涨停:BAAALAAFFAIIAwAAAA==.',['美美']='美美桑内:BAABLAAFFH8WAAIKAAYIgRZrFwCWAQAKAAYIgRZrFwCWAQAAAA==.',['老奶']='老奶奶战:BAABLAAFFH8KAAIMAAYINBc+DQBwAQAMAAYINBc+DQBwAQAAAA==.老奶奶过马路:BAABLAAFFH8XAAMWAAYIpCBrAwDNAQAWAAYIpCBrAwDNAQANAAQI3Q2INQDVAAAAAA==.',['老硬']='老硬币:BAAALAAECgEIAQAAAA==.',['老船']='老船长丢火车:BAAALAAECgIIAgAAAA==.',['耄耋']='耄耋:BAAALAAFFAgIAQAAAA==.',['背丶']='背丶危险:BAAALAAFFAEIAQAAAA==.',['胖鸡']='胖鸡玩猫巴:BAABLAAFFH8GAAIHAAYIFxjcNABoAQAHAAYIFxjcNABoAQAAAA==.',['脉动']='脉动:BAAALAAECgYIBgAAAA==.',['舞池']='舞池电音:BAAALAADCgYIBgAAAA==.',['艾利']='艾利茜娅:BAAALAAECgYIDAAAAA==.',['艾斯']='艾斯蒂西亚:BAAALAAFFAUIAgAAAA==.',['芋艿']='芋艿小酋长:BAAALAAFFAEIAQAAAA==.',['芝士']='芝士狐狸:BAABLAAFFH8GAAMKAAIIBBUDKwCVAAAKAAIIBBUDKwCVAAAOAAIIIAPRMQArAAAAAA==.',['苏小']='苏小毛:BAABLAAFFH8GAAIUAAYIAghdDwBAAQAUAAYIAghdDwBAAQAAAA==.',['荔枝']='荔枝蜜:BAAALAAFFAIIAgAAAA==.',['荸荠']='荸荠:BAAALAAECgYICwAAAA==.',['莎丨']='莎丨蔓:BAAALAAECgYIDAAAAA==.',['菠菜']='菠菜五条腿:BAABLAAFFH8GAAIUAAYIngz8BQCeAQAUAAYIngz8BQCeAQAAAA==.',['菠萝']='菠萝到处浪啊:BAABLAAFFH8LAAIaAAIIBh4eEgBQAAAaAAIIBh4eEgBQAAAAAA==.',['萌新']='萌新小牧:BAABLAAFFH8PAAMbAAYIrQ0iAwCvAAAKAAYI5gzRHABnAQAbAAMIxRAiAwCvAAABLAAFFAYINQAPAKcdAA==.萌新小萨:BAACLAAFFH81AAMPAAYIpx0wCgDbAQAPAAUIPSEwCgDbAQAEAAYICCJLFAC/AQAsAAQKfx0AAw8ABwjuJAUXAOECAA8ABwjuJAUXAOECAAQABgijJsIMAJoCAAAA.',['萌狐']='萌狐小施:BAAALAAECgYIEQAAAA==.',['萌萌']='萌萌德小施:BAABLAAECn8ZAAIVAAcIgR77DwBaAgAVAAcIgR77DwBaAgAAAA==.萌萌的兰导:BAAALAAECgIIAgAAAA==.',['萌飒']='萌飒飒小施:BAAALAAECgIIAgAAAA==.',['萨特']='萨特曼:BAABLAAFFH8RAAIPAAUIbBimHwBEAQAPAAUIbBimHwBEAQAAAA==.',['萨萌']='萨萌檬:BAABLAAFFH8MAAIEAAIIcxXATwB8AAAEAAIIcxXATwB8AAAAAA==.萨萌萌:BAABLAAFFH8JAAIEAAMIEA7wSACMAAAEAAMIEA7wSACMAAAAAA==.',['蒙面']='蒙面张学友:BAABLAAECn8YAAIEAAYIqQ/FsAAfAQAEAAYIqQ/FsAAfAQAAAA==.',['蓁蓁']='蓁蓁的保镖:BAAALAAECggICAAAAA==.',['蕾依']='蕾依莉雅:BAAALAAECgIIAgAAAA==.',['虎先']='虎先锋:BAAALAADCgYIBgAAAA==.',['虚空']='虚空夜月:BAABLAAFFH8HAAMFAAIIHhizSACbAAAFAAIIHhizSACbAAARAAII+A2JKAB3AAAAAA==.',['蠱惑']='蠱惑崽:BAAALAAECgEIAQAAAA==.',['血色']='血色刀锋:BAAALAAECgMIBgAAAA==.',['西蒙']='西蒙海耶:BAABLAAFFH8GAAMFAAIIgxOoVQCSAAAFAAIIgxOoVQCSAAARAAIIkAlDLABuAAAAAA==.',['赏你']='赏你个痛快:BAAALAAECgQIBgAAAA==.',['赤宵']='赤宵战魂:BAAALAAECgcIEwAAAA==.',['越射']='越射越开心:BAAALAAFFAIIAgAAAA==.',['趴墙']='趴墙上等红杏:BAAALAAFFAEIAQAAAA==.',['趴菜']='趴菜小德:BAABLAAFFH8jAAMVAAcI0xbEDgDTAQAVAAcI0xbEDgDTAQAJAAMIiwp8KABxAAAAAA==.',['躲在']='躲在你的衣柜:BAAALAAFFAEIAQAAAA==.',['辣多']='辣多一点:BAAALAAECgcIDgAAAA==.',['这啤']='这啤就是纯麦:BAAALAAECgYICQAAAA==.',['通宵']='通宵罚站丶:BAAALAAFFAMIAwAAAA==.',['逛来']='逛来逛去:BAAALAAECggICwABLAAFFAgIFwAPANUeAA==.',['邪邪']='邪邪笙歌:BAAALAAECgYICgAAAA==.',['酋长']='酋长毛结棍:BAABLAAFFH8MAAIHAAIIRhwAUAChAAAHAAIIRhwAUAChAAAAAA==.',['酒亦']='酒亦醉情易碎:BAAALAAECgYIBgAAAA==.',['酥小']='酥小小:BAAALAAECgYIDgAAAA==.',['鑢七']='鑢七实:BAAALAAFFAQIAgAAAA==.',['钱美']='钱美丽:BAAALAADCgIIAgAAAA==.',['铁血']='铁血少年团壹:BAABLAAFFH8iAAINAAYIyRx2EgC0AQANAAYIyRx2EgC0AQAAAA==.',['锃光']='锃光瓦亮:BAAALAAECggIAQAAAA==.',['闷声']='闷声发大财:BAABLAAFFH8HAAIGAAQIzApHOQCpAAAGAAQIzApHOQCpAAAAAA==.',['阳阳']='阳阳:BAABLAAFFH8NAAINAAUIHA14LwAKAQANAAUIHA14LwAKAQAAAA==.',['阿勒']='阿勒泰:BAAALAAECgUICQAAAA==.',['阿呆']='阿呆呆:BAABLAAFFH8IAAIBAAYIZA6FMgBMAQABAAYIZA6FMgBMAQABLAAFFAgISgABAEcmAA==.阿呆来吃肉:BAABLAAFFH8JAAIBAAUI9hUENQA+AQABAAUI9hUENQA+AQAAAA==.',['阿萨']='阿萨丽斯:BAAALAADCgYIBgAAAA==.',['阿贵']='阿贵儿:BAABLAAFFH8FAAIBAAUIzAoOPwD+AAABAAUIzAoOPwD+AAAAAA==.',['雅尔']='雅尔贝德:BAABLAAFFH8GAAMPAAYI8xD4JQAXAQAPAAUIqRH4JQAXAQAEAAEI4AHdfgAoAAAAAA==.',['雪花']='雪花沉睡:BAAALAAFFAEIAQAAAA==.',['雷电']='雷电影:BAAALAAECgYIDAAAAA==.',['雷神']='雷神索尔:BAABLAAFFH8GAAIHAAYImgsFPwA/AQAHAAYImgsFPwA/AQAAAA==.',['青椒']='青椒炒肉:BAAALAAECgYIBgAAAA==.',['静初']='静初静默:BAABLAAFFH8MAAMaAAIIThKYEQCLAAAaAAIIThKYEQCLAAAYAAIIbwa/ZQA1AAAAAA==.',['韩跑']='韩跑跑:BAABLAAFFH8GAAIUAAYIzxGGCQDCAQAUAAYIzxGGCQDCAQAAAA==.',['風雲']='風雲:BAAALAAECgIIBQAAAA==.',['风丶']='风丶花雪月:BAAALAAECgMIAwAAAA==.',['风从']='风从发梢吹过:BAAALAAFFAQIBAAAAA==.',['风影']='风影啸:BAAALAAFFAEIAQAAAA==.',['飛天']='飛天豬寶寶:BAAALAAECgYIDQAAAA==.',['马叮']='马叮当:BAABLAAECn8WAAIFAAcI1iOtMwCMAgAFAAcI1iOtMwCMAgAAAA==.',['马啦']='马啦啦:BAAALAAFFAIIAgAAAA==.',['马尔']='马尔泰灬若曦:BAAALAAECgYIBgAAAA==.',['马维']='马维:BAAALAAFFAIIAgAAAA==.',['骑着']='骑着老奶奶:BAAALAAECgMIAwAAAA==.',['高个']='高个子:BAAALAAECgYIBgAAAA==.',['高山']='高山一崩:BAAALAAECgUIBQAAAA==.',['髪丝']='髪丝:BAAALAADCgIIAgAAAA==.',['鬼人']='鬼人正邪:BAAALAAECgIIAgAAAA==.',['魂之']='魂之挽歌:BAAALAADCgEIAQAAAA==.',['魔暴']='魔暴龙:BAAALAAECgYIDAAAAA==.',['麦辣']='麦辣龙腿堡:BAABLAAFFH8FAAIUAAUIrhcADQB0AQAUAAUIrhcADQB0AQAAAA==.',['麻雀']='麻雀丶发炎:BAAALAAFFAIIBAAAAA==.',['黯淡']='黯淡天行者:BAAALAAFFAMIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end