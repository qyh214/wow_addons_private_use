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
 local lookup = {'Warrior-Arms','DemonHunter-Havoc','Shaman-Restoration','Rogue-Assassination','Warrior-Fury','DeathKnight-Unholy','Paladin-Retribution','Warlock-Destruction','Warlock-Affliction','Druid-Balance','Druid-Restoration','Druid-Guardian','Priest-Holy','Priest-Shadow','Paladin-Protection','DemonHunter-Vengeance','Mage-Frost','Mage-Arcane','Hunter-Marksmanship','Hunter-BeastMastery','Shaman-Enhancement','Evoker-Devastation','Mage-Fire','Monk-Mistweaver','Monk-Brewmaster','DeathKnight-Blood','Warlock-Demonology','Paladin-Holy','Unknown-Unknown','Shaman-Elemental',}; local provider = {region='CN',realm='恶魔之翼',name='CN',type='weekly',zone=42,date='2025-08-08',data={Bi='Bigboss:BAABKgAFFH8GAAIBAAMIDARgEQB/AAABAAMIDARgEQB/AAAAAA==.',Cd='Cdd:BAAAKgADCgQIBQAAAA==.',Fe='Feifei:BAAAKgAECggIEQAAAA==.',Ho='Holy:BAAAKgAFFAEIAQAAAA==.',Ic='Icytail:BAAAKgAECgYIBgAAAA==.',Ka='Kaism:BAABKgAFFH8HAAICAAcIEhkFCAAPAgACAAcIEhkFCAAPAgAAAA==.',Ki='Killuayzy:BAABKgAFFH8LAAIDAAgI1QgRCwBNAQADAAgI1QgRCwBNAQAAAA==.Kinxin:BAAAKgAECgUIBQAAAA==.',Mi='Minfilia:BAABKgAFFH8GAAIEAAYIsh+iAAD4AQAEAAYIsh+iAAD4AQAAAA==.',Mo='Morals:BAAAKgAFFAQIBAABKgAFFAgIGAAFAMkfAA==.',On='One:BAAAKgADCggICAAAAA==.',Pe='Pellet:BAAAKgAECggIDQAAAA==.',Sa='Satomi:BAAAKgAFFAYIAgABKgAFFAgIGwACAI0bAA==.',Sc='Screaml:BAAAKgAECgYIBgAAAA==.',Tw='Twy:BAAAKgAECgYICgAAAA==.',We='Weirdoo:BAACKgAFFH8NAAIGAAQIhiACIwALAQAGAAQIhiACIwALAQAqAAQKf2MAAgYACAgkJR0FAO0CAAYACAgkJR0FAO0CAAAA.',Wh='Whosyourdad:BAABKgAFFH8HAAIHAAYIkRqcHACBAQAHAAYIkRqcHACBAQAAAA==.',['Ää']='Ää:BAAAKgAFFAEIAQAAAA==.',['一心']='一心为社团:BAABKgAFFH8MAAIFAAcI6BvkBAA4AgAFAAcI6BvkBAA4AgAAAA==.',['一易']='一易丶赛恩一:BAAAKgAECgMIAwAAAA==.',['七爷']='七爷灬:BAAAKgADCggICQAAAA==.',['三个']='三个五吖:BAAAKgADCgMIAwAAAA==.',['不灭']='不灭:BAAAKgAECggIDAAAAA==.',['不爱']='不爱吃肉:BAAAKgADCggIDQAAAA==.不爱吃饭:BAAAKgADCgEIAQAAAA==.',['不说']='不说晚安:BAAAKgAECgIIAgAAAA==.',['丑牛']='丑牛:BAAAKgADCggIEAAAAA==.',['丶玄']='丶玄煞:BAAAKgAECggICQAAAA==.',['丶老']='丶老韦不让玩:BAAAKgAECgYICgAAAA==.',['乔克']='乔克叔叔:BAAAKgADCgEIAQAAAA==.',['九个']='九个上悠亞:BAAAKgAECggICAAAAA==.',['也许']='也许明天:BAABKgAFFH8GAAIDAAYIRg3MFAAyAQADAAYIRg3MFAAyAQAAAA==.',['五尺']='五尺之徒:BAAAKgAECggICAAAAA==.',['人生']='人生如梦:BAAAKgAECgQIBAAAAA==.',['从小']='从小就很闲:BAAAKgADCggICAAAAA==.从小就很靓:BAAAKgADCgcIBwAAAA==.',['仙丶']='仙丶德瑞拉:BAAAKgAFFAYIBAAAAA==.',['你相']='你相信光吗:BAAAKgAFFAgIBAAAAA==.',['充满']='充满矛盾的鬼:BAACKgAFFH8oAAMIAAQIaxVRGgC1AAAIAAQIvRJRGgC1AAAJAAIIMwntGQByAAAqAAQKfxgAAwgACAiLHP8QACECAAgACAiLHP8QACECAAkAAQjdELRBAC0AAAAA.',['八卦']='八卦海:BAAAKgAFFAQIBAAAAA==.',['兰亭']='兰亭序:BAAAKgADCgEIAQAAAA==.',['冉冉']='冉冉德:BAABKgAECn8bAAQKAAgIGBWDNgDfAQAKAAgIGBWDNgDfAQALAAUIKwtfUADLAAAMAAEI6ArGNgAcAAAAAA==.',['冬絶']='冬絶纱:BAABKgAFFH8UAAMNAAgIECRzAADmAgANAAgIECRzAADmAgAOAAIILhPgHgCSAAAAAA==.',['前程']='前程旧梦:BAAAKgAECggICwAAAA==.',['劉富']='劉富贵:BAAAKgADCggICAAAAA==.',['十里']='十里水沉烟冷:BAAAKgAECggIDQAAAA==.',['卓雅']='卓雅:BAAAKgAFFAcIAwAAAA==.',['单身']='单身奶茶:BAACKgAFFH8RAAIHAAQIeR/cDQAdAQAHAAQIeR/cDQAdAQAqAAQKfxQAAwcACAhLJKMNAOICAAcACAhLJKMNAOICAA8AAQh4B/BfACgAAAAA.单身屠夫:BAACKgAFFH8XAAIKAAQI3iCyDgABAQAKAAQI3iCyDgABAQAqAAQKfxoAAwoACAglI3MUAI0CAAoACAglI3MUAI0CAAsAAQgBChyRACMAAAAA.',['原罪']='原罪之刃:BAAAKgAECggIEQAAAA==.',['叉烧']='叉烧包:BAAAKgADCggICAAAAA==.',['双持']='双持信用卡:BAAAKgAECgcIDgAAAA==.',['反派']='反派冷酷小猫:BAAAKgADCgIIAgAAAA==.',['只会']='只会站撸:BAAAKgADCggICAAAAA==.',['叫宝']='叫宝宝:BAAAKgAFFAMIAwAAAA==.',['叫我']='叫我起名废:BAAAKgADCgUIBgAAAA==.',['叮咛']='叮咛咚丶:BAABKgAECn8WAAMQAAgIoA28NQDlAAACAAcIAg1/WADoAAAQAAgIswu8NQDlAAAAAA==.',['可爱']='可爱女人:BAAAKgADCgEIAQAAAA==.',['叶子']='叶子飘飘:BAAAKgAECgIIAgAAAA==.',['吃素']='吃素的狼:BAABKgAFFH8IAAIIAAgIGhgcCgDqAQAIAAgIGhgcCgDqAQAAAA==.',['呃啊']='呃啊:BAAAKgAECgEIAQAAAA==.',['呼啦']='呼啦圈:BAABKgAFFH8HAAIHAAMIbQbPYwCnAAAHAAMIbQbPYwCnAAAAAA==.',['咕勇']='咕勇者:BAAAKgAECggICAAAAA==.',['啟示']='啟示錄:BAAAKgADCggICAAAAA==.',['嗨呀']='嗨呀打摩丝:BAAAKgAFFAMIAwAAAA==.',['嘛咪']='嘛咪嘛咪轰轰:BAAAKgADCgQIBAAAAA==.',['圆缺']='圆缺都是注定:BAAAKgADCggICAAAAA==.',['圣灵']='圣灵雪月:BAAAKgADCggICAAAAA==.',['地狱']='地狱边缘:BAAAKgAECgYIBgAAAA==.',['基耳']='基耳加丹:BAAAKgADCggICAAAAA==.',['壅暨']='壅暨:BAAAKgADCgcIBwAAAA==.',['夏禾']='夏禾星野:BAACKgAFFH8RAAMRAAMIzAnTGwCjAAARAAMIzAnTGwCjAAASAAMIaAXfMgCYAAAqAAQKfxcAAhEACAgEET1HAEkBABEACAgEET1HAEkBAAAA.',['夜丶']='夜丶夜丶夜:BAAAKgADCgYIBgAAAA==.',['夢魇']='夢魇:BAAAKgADCgUIBQAAAA==.',['大口']='大口有肉吃:BAAAKgAECgMIAwAAAA==.',['大谢']='大谢:BAAAKgAECgUIBQAAAA==.',['天尊']='天尊皇胤:BAABKgAFFH8KAAMTAAYI+h08CQD+AAATAAQIIRs8CQD+AAAUAAIIQSKLNwC5AAAAAA==.',['天灰']='天灰灰:BAAAKgAECggICAAAAA==.',['天赐']='天赐霐:BAAAKgAECggICAAAAA==.',['头发']='头发掉光了:BAAAKgAFFAQIBAAAAA==.',['奈文']='奈文丶摩尔:BAAAKgAECgUIBQAAAA==.',['妇科']='妇科聖手:BAABKgAECn8hAAIHAAgIpyMlJABwAgAHAAgIpyMlJABwAgAAAA==.',['妖丶']='妖丶弓:BAAAKgAECgMIAwAAAA==.',['宝宝']='宝宝小牛:BAEBKgAFFH8GAAIVAAYIrhNtBQCLAQAVAAYIrhNtBQCLAQAAAA==.',['小喵']='小喵豆豆:BAAAKgAECgIIAwAAAA==.',['小小']='小小一二三:BAABKgAECn8aAAMUAAgIAx3+JwASAgAUAAgIAx3+JwASAgATAAIIsRfMnwA9AAABKgAFFAgICwAPAGkEAA==.',['小晖']='小晖辉:BAABKgAFFH8PAAIWAAgIiiJsBABrAgAWAAgIiiJsBABrAgAAAA==.',['小白']='小白人品好:BAAAKgAECgEIAQAAAA==.',['小豆']='小豆丁:BAAAKgADCggIAgAAAA==.',['小龙']='小龙女过儿:BAAAKgAECgcICwAAAA==.',['尛丶']='尛丶圣光:BAAAKgADCgYIBgAAAA==.',['帝狱']='帝狱丨刨啸:BAAAKgAFFAQIBAAAAA==.',['廴厶']='廴厶乄凵丩乀:BAAAKgAECgMIAwAAAA==.',['忈笙']='忈笙茹夢:BAAAKgADCggICAAAAA==.',['快要']='快要吃土了:BAAAKgAECgQIBAAAAA==.',['恋上']='恋上月亮:BAAAKgAECggICgAAAA==.',['悲情']='悲情木头:BAAAKgAECgIIAgAAAA==.',['憨憨']='憨憨:BAAAKgAECgEIAQAAAA==.',['我不']='我不是术爷:BAAAKgAECgEIAQAAAA==.',['我似']='我似自愿的:BAAAKgAECgYIBgAAAA==.',['我的']='我的角好长:BAABKgAECn8YAAICAAgIIhTdLACxAQACAAgIIhTdLACxAQAAAA==.',['拂晓']='拂晓之心:BAABKgAECn8dAAMSAAgI3gKMiQBRAAASAAgI3gKMiQBRAAAXAAcIZgEpSgAwAAAAAA==.',['挽歌']='挽歌不终不止:BAABKgAFFH8cAAMRAAYIciLKAgDkAQARAAYIbR/KAgDkAQASAAYIsx/JDgB8AQAAAA==.',['插座']='插座我是插头:BAAAKgAECgQIBAAAAA==.',['摩卡']='摩卡加冰:BAAAKgAECgYICgAAAA==.',['摸鱼']='摸鱼拌饭:BAABKgAFFH8LAAIYAAcIohi7AAAnAgAYAAcIohi7AAAnAgAAAA==.',['散華']='散華礼弥:BAAAKgAECgEIAQAAAA==.',['斗牛']='斗牛:BAAAKgAECggICAAAAA==.',['方世']='方世远:BAAAKgAFFAIIBAAAAA==.',['方兴']='方兴未艾:BAABKgAFFH8IAAIYAAgIXwwcBwCTAQAYAAgIXwwcBwCTAQAAAA==.',['无限']='无限重生:BAAAKgADCgQIBAAAAA==.',['时光']='时光回溯:BAAAKgAFFAIIBAAAAA==.',['星辰']='星辰丶侠侣:BAABKgAFFH8GAAIZAAQIoQYUCQB5AAAZAAQIoQYUCQB5AAAAAA==.星辰丶制裁者:BAAAKgAECgcICQAAAA==.星辰丶刽子手:BAABKgAFFH8KAAIaAAQIpQagKgBrAAAaAAQIpQagKgBrAAAAAA==.星辰丶猎魔者:BAABKgAFFH8KAAIQAAMIRAhNDQCXAAAQAAMIRAhNDQCXAAAAAA==.',['月落']='月落丶神泣:BAAAKgAECgYIBgAAAA==.',['末法']='末法毁天道:BAAAKgAECgYIBgAAAA==.',['李大']='李大炮:BAABKgAFFH8FAAQIAAQIsB7JOACNAAAIAAMIyBbJOACNAAAJAAEIjSRjHABfAAAbAAEICBQAAAAAAAAAAA==.',['来瓶']='来瓶红牛:BAAAKgADCgIIAgAAAA==.',['柏卜']='柏卜正:BAACKgAFFH8JAAIUAAQIEB6BJwDoAAAUAAQIEB6BJwDoAAAqAAQKfxUAAhQACAihII87AAkCABQACAihII87AAkCAAEqAAUUCAgIABMAHyEA.',['桃花']='桃花恋:BAABKgAFFH8GAAIHAAYIuRmkIwBdAQAHAAYIuRmkIwBdAQAAAA==.',['梅迪']='梅迪尔丽:BAAAKgAECgEIAgAAAA==.',['梦屿']='梦屿:BAAAKgAFFAEIAQAAAA==.',['止战']='止战之殇:BAAAKgAECggICAAAAA==.',['止血']='止血瓶丶:BAAAKgAECgQIBAAAAA==.',['武动']='武动石头:BAAAKgAECgIIAgAAAA==.',['毛毛']='毛毛虫大帝:BAAAKgAECgMIAwAAAA==.',['水晶']='水晶:BAACKgAFFH8XAAIYAAUIOBHbBwAsAQAYAAUIOBHbBwAsAQAqAAQKfyEAAhgACAjfIOsMAIQCABgACAjfIOsMAIQCAAAA.水晶北碧:BAAAKgAFFAgIBAAAAA==.',['水榭']='水榭一夏:BAAAKgAFFAEIAQAAAA==.',['水牛']='水牛也疯狂:BAAAKgADCggICwAAAA==.',['江还']='江还是老的姜:BAABKgAFFH8IAAIHAAgI5A5fDgDxAQAHAAgI5A5fDgDxAQAAAA==.',['污以']='污以丶类聚:BAAAKgAFFAIIAwAAAA==.',['沃舒']='沃舒古哈利:BAAAKgAECggIDQAAAA==.',['法神']='法神张张:BAAAKgAECgQIBQAAAA==.',['法网']='法网恢恢:BAAAKgADCggICAAAAA==.',['泡姜']='泡姜:BAAAKgAECgYIBgAAAA==.',['流雲']='流雲行水:BAAAKgAECggIDwAAAA==.',['浮生']='浮生流年:BAAAKgAECgYIBAAAAA==.',['火不']='火不高兴:BAABKgAECn8UAAIPAAgI6R0ICwB7AQAPAAgI6R0ICwB7AQAAAA==.',['火之']='火之乐成狗:BAAAKgADCgIIAgAAAA==.',['灬狐']='灬狐你一脸:BAAAKgADCgcIBAAAAA==.',['热心']='热心村民:BAAAKgAFFAQIBAAAAA==.',['熊贰']='熊贰:BAAAKgAECgcICAAAAA==.',['爲所']='爲所欲为:BAAAKgAECgIIAgAAAA==.',['牛不']='牛不牛:BAAAKgAECgQIBAAAAA==.',['牛奶']='牛奶不外卖:BAAAKgADCgIIAgAAAA==.牛奶奶牛:BAAAKgADCgQIBQAAAA==.',['牛毛']='牛毛:BAAAKgAECgYICgAAAA==.',['猫巧']='猫巧:BAAAKgADCgIIAgAAAA==.',['玩个']='玩个骑士:BAABKgAFFH8KAAIPAAgIkQ/YBQCWAQAPAAgIkQ/YBQCWAQAAAA==.',['畫船']='畫船听雨眠:BAABKgAFFH8IAAISAAgIdxR8BgAfAgASAAgIdxR8BgAfAgAAAA==.',['疯狂']='疯狂水牛骑士:BAAAKgADCgEIAQAAAA==.',['白神']='白神:BAABKgAFFH8GAAINAAYIcyMZBQDqAQANAAYIcyMZBQDqAQAAAA==.',['白雪']='白雪莹莹:BAAAKgADCgIIAgAAAA==.',['皓阿']='皓阿七:BAAAKgADCgYIBgAAAA==.',['盖世']='盖世太保:BAAAKgAECgIIAgAAAA==.',['看头']='看头上有树:BAAAKgAECgQICAAAAA==.',['真是']='真是悲剧:BAACKgAFFH8UAAMBAAQINSRPDwCjAAAFAAMIRSSlGAC9AAABAAIIFCRPDwCjAAAqAAQKfycAAwEACAgpJLULAGkCAAEABwjJI7ULAGkCAAUABQhbIRQ+AH0BAAAA.',['瞑焱']='瞑焱:BAAAKgAECgcIBwAAAA==.',['砖治']='砖治牛人的丶:BAAAKgAECgIIAgAAAA==.',['磅丨']='磅丨礴:BAABKgAFFH8FAAIHAAMIahTQUwDJAAAHAAMIahTQUwDJAAAAAA==.',['祁煜']='祁煜:BAAAKgADCggICAAAAA==.',['神棍']='神棍缺牙巴:BAABKgAFFH8RAAIDAAQIWB1GEAD9AAADAAQIWB1GEAD9AAAAAA==.',['秋水']='秋水日潺湲:BAAAKgAFFAQIBAAAAA==.',['秦彻']='秦彻:BAABKgAFFH8IAAICAAQIlx5oCgAiAQACAAQIlx5oCgAiAQAAAA==.',['稀饭']='稀饭嘎啦:BAAAKgAECgYIEQAAAA==.',['筱筱']='筱筱布丁:BAABKgAFFH8OAAIEAAgIdRufAAD6AQAEAAgIdRufAAD6AQAAAA==.',['简单']='简单粗暴:BAAAKgAECggICAAAAA==.',['箭如']='箭如风:BAAAKgAFFAMIAwAAAA==.',['米拉']='米拉朵朵:BAAAKgAECgcIEQAAAA==.',['米浴']='米浴:BAABKgAFFH8TAAMOAAYIzB3/BQDPAQAOAAYIzB3/BQDPAQANAAQIoiPoDQDMAAAAAA==.',['粉色']='粉色海洋:BAAAKgAECggIBwAAAA==.',['糖丶']='糖丶德瑞拉:BAACKgAFFH8eAAIcAAYIvCKkAwDSAQAcAAYIvCKkAwDSAQAqAAQKfxkAAhwACAjUIwEFAJ0CABwACAjUIwEFAJ0CAAAA.',['糯米']='糯米:BAAAKgAECgEIAQAAAA==.',['素裳']='素裳:BAABKgAFFH8NAAMPAAcItA4WCgBbAQAPAAcItA4WCgBbAQAcAAQItxKVBwDaAAAAAA==.',['紫色']='紫色的星:BAAAKgADCgIIAgAAAA==.',['紫颜']='紫颜丿步阡:BAAAKgAECgUIBQAAAA==.',['纳格']='纳格兰守护者:BAABKgAFFH8NAAIDAAgIVBcNCwCWAQADAAgIVBcNCwCWAQAAAA==.',['终于']='终于有蛋刀了:BAAAKgAFFAgIBAAAAA==.',['给你']='给你一口毒奶:BAAAKgAECgYICwAAAA==.',['绵云']='绵云冷萃:BAABKgAFFH8GAAINAAYILgdyFQAJAQANAAYILgdyFQAJAQABKgAFFAgIDAANAI4SAA==.',['绿皮']='绿皮书:BAAAKgAECgYIEQAAAA==.',['美缕']='美缕:BAAAKgAFFAQIBAAAAA==.',['翾語']='翾語優香:BAAAKgAFFAEIAQAAAA==.',['聪聪']='聪聪:BAAAKgAECggIDwAAAA==.',['胖橘']='胖橘武僧:BAAAKgAFFAQIBAAAAA==.',['腹黑']='腹黑喵:BAAAKgAECgYICQAAAA==.',['自然']='自然的守护者:BAABKgAFFH8KAAILAAgISxNXBADsAQALAAgISxNXBADsAQAAAA==.',['艾卜']='艾卜:BAAAKgAECgYIAgAAAA==.',['艾斯']='艾斯:BAAAKgAECgcICAAAAA==.',['花渐']='花渐:BAABKgAFFH8VAAIKAAQIYxpkKADyAAAKAAQIYxpkKADyAAAAAA==.',['茴暃']='茴暃严乜:BAABKgAFFH8HAAIDAAQI8hZrHgChAAADAAQI8hZrHgChAAABKgAFFAgILwADANweAA==.',['莉娜']='莉娜兔:BAABKgAFFH8dAAMPAAYIBQ88EAACAQAPAAYI3A08EAACAQAHAAQIwQz5WgC7AAAAAA==.',['菊吻']='菊吻無名指:BAAAKgADCggIDQAAAA==.',['菊花']='菊花不是花:BAAAKgADCgQIBAAAAA==.',['菠萝']='菠萝头王子:BAABKgAFFH8XAAITAAgI6Aw9EwBJAQATAAgI6Aw9EwBJAQAAAA==.',['萌宝']='萌宝蛋:BAAAKgADCggIBQAAAA==.',['萌贼']='萌贼吥呆:BAAAKgAFFAQIAwABKgAFFAgIBAAdAAAAAA==.',['萨兰']='萨兰法鲁尔:BAAAKgADCgQIBAAAAA==.',['萨满']='萨满丶:BAAAKgAECgQIBAAAAA==.',['落落']='落落:BAABKgAECn8cAAIHAAcI0xomeQCkAQAHAAcI0xomeQCkAQAAAA==.',['蒂娅']='蒂娅:BAAAKgADCgMIAwAAAA==.',['蛋白']='蛋白质不受:BAAAKgAECgQIBAAAAA==.',['蛋碎']='蛋碎就拿去蒸:BAABKgAFFH8HAAIDAAMI/BXPFQDFAAADAAMI/BXPFQDFAAAAAA==.',['血月']='血月影羽:BAAAKgAFFAQIBAAAAA==.',['豌豆']='豌豆射手:BAAAKgAFFAQIBAAAAA==.',['豪客']='豪客来:BAAAKgAECgYIBgAAAA==.',['贰贰']='贰贰叁肆:BAABKgAFFH8IAAIDAAYIThoBDACIAQADAAYIThoBDACIAQAAAA==.',['赞吉']='赞吉尔的朋友:BAAAKgAFFAQIBAAAAA==.',['赤红']='赤红大灬根:BAABKgAFFH8FAAIHAAUIEgodHQD7AAAHAAUIEgodHQD7AAAAAA==.',['超级']='超级牛:BAABKgAECn8YAAQeAAgITBwNGQACAgAeAAgITBwNGQACAgADAAgIVhVjMwC5AQAVAAIIOgb6WABKAAAAAA==.',['轰龙']='轰龙龙:BAAAKgAECggIDgAAAA==.',['辛萨']='辛萨苟达:BAAAKgAECgcIDwAAAA==.',['这游']='这游戏很基情:BAABKgAFFH8IAAIcAAgI6gSKBACpAQAcAAgI6gSKBACpAQAAAA==.',['逍遥']='逍遥猎:BAAAKgAECggIEgAAAA==.',['速度']='速度放棄:BAABKgAFFH8IAAIaAAgIKxgJBAAYAgAaAAgIKxgJBAAYAgAAAA==.',['鏖丽']='鏖丽鶕魺:BAAAKgAECggIEQAAAA==.',['鑫丶']='鑫丶丶:BAAAKgAECgYICAAAAA==.',['钻们']='钻们拉宁:BAAAKgAECgUIBwAAAA==.',['铁拳']='铁拳张哥:BAAAKgAECgMIAwAAAA==.',['锅锅']='锅锅:BAAAKgAFFAIIAgAAAA==.',['防盗']='防盗门丶:BAAAKgAECgcIBwAAAA==.',['阿劣']='阿劣劣:BAAAKgAECgQICQAAAA==.',['阿布']='阿布在不斩:BAAAKgAECgcIEwAAAA==.',['阿香']='阿香:BAABKgAECn8bAAIcAAgIGhvBDAAnAgAcAAgIGhvBDAAnAgAAAA==.',['阿龙']='阿龙的左手:BAAAKgADCggICAAAAA==.',['隋随']='隋随:BAABKgAECn8bAAIRAAgIRh0NFABeAgARAAgIRh0NFABeAgAAAA==.',['随便']='随便你歪丶:BAABKgAFFH8IAAILAAgIPBXhAwD9AQALAAgIPBXhAwD9AQAAAA==.',['雨天']='雨天见:BAAAKgAECgEIAQAAAA==.',['雨露']='雨露均沾:BAAAKgAECgQIBAAAAA==.',['雪晴']='雪晴:BAAAKgAECgMIAwAAAA==.',['雷霆']='雷霆捍卫者:BAABKgAFFH8MAAMVAAYI4RrrAADiAQAVAAYI4RrrAADiAQADAAQIBgYYGwC1AAAAAA==.',['雾里']='雾里茫茫欲坠:BAAAKgADCggICAAAAA==.',['霜见']='霜见春潮:BAAAKgAECgYIBgAAAA==.',['霜霜']='霜霜哀伤:BAAAKgADCggICAAAAA==.',['霸波']='霸波尔奔:BAAAKgAECgEIAQAAAA==.',['青莲']='青莲:BAAAKgAECgQIBAAAAA==.',['非法']='非法走丝:BAAAKgAECgYICgAAAA==.',['风杞']='风杞:BAAAKgAECgIIAgAAAA==.',['骑士']='骑士的苦楚:BAACKgAFFH8KAAIaAAMIbwdWGgCDAAAaAAMIbwdWGgCDAAAqAAQKfxQAAhoACAgRFpgaAMABABoACAgRFpgaAMABAAAA.',['黄泉']='黄泉彼岸:BAABKgAFFH8cAAMaAAgI3CNjAQC5AgAGAAgI1yJ8AQC9AgAaAAgIBSJjAQC5AgAAAA==.',['黎明']='黎明:BAAAKgADCgEIAQAAAA==.',['黑吃']='黑吃皮:BAAAKgAECgQIBAAAAA==.',['黑夜']='黑夜龙王:BAAAKgAFFAEIAQAAAA==.',['黑炭']='黑炭:BAAAKgAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end