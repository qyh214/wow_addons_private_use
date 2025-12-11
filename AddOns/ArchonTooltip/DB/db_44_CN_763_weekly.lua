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
 local lookup = {'Warrior-Fury','Warrior-Protection','Shaman-Restoration','Priest-Holy','Mage-Arcane','Priest-Shadow','Druid-Restoration','Monk-Windwalker','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Blood','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Havoc','Paladin-Protection','Warlock-Destruction','Monk-Mistweaver','Monk-Brewmaster','Unknown-Unknown','DemonHunter-Vengeance','Paladin-Holy','Mage-Frost','Warlock-Affliction','Warrior-Arms','Rogue-Assassination','Warlock-Demonology',}; local provider = {region='CN',realm='瑞文戴尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aima:BAAALAADCgMIAwAAAA==.Aimieyishi:BAAALAAECgQIBQAAAA==.',Ba='Barbatos:BAAALAAECgYIBgAAAA==.',Ca='Cafe:BAAALAAECgMIAwAAAA==.',Ch='Chloe:BAAALAAECgEIAgAAAA==.',De='Depraved:BAAALAAECgMIAwAAAA==.',El='Elaine:BAAALAAECgEIAQAAAA==.',Fa='Fallenalien:BAAALAAFFAIIBAAAAA==.',Fi='Finalshow:BAAALAAFFAEIAQAAAA==.',Hi='Hidesuwa:BAABLAAFFH8GAAMBAAYIpATxQABZAAABAAUIewXxQABZAAACAAEIbQCEPAADAAAAAA==.',Ho='Hollo:BAAALAAECgMIAwAAAA==.',Hu='Huziy:BAAALAAECgYIBgAAAA==.',Js='Jsp:BAAALAAECgYIBgAAAA==.',Lu='Lunaestrella:BAAALAAECgMIBgAAAA==.',Ma='Manman:BAAALAAECgUICQAAAA==.',Mi='Mimu:BAAALAAECgEIAQAAAA==.',Na='Naibadx:BAAALAAFFAIIAgAAAA==.',No='Nodejs:BAAALAADCgUICgAAAA==.',Pa='Parkjiyeon:BAAALAAECgYIDAAAAA==.',Pl='Playerugvzga:BAAALAADCgMIAwAAAA==.',Ro='Romy:BAAALAAECgYICQAAAA==.Roomny:BAAALAAFFAIIBAAAAA==.',Sa='Sanity:BAABLAAFFH8VAAIDAAYI2yEWCQA1AgADAAYI2yEWCQA1AgABLAAFFAgIBgAEAKwPAA==.',Si='Siennamiller:BAAALAAFFAIIAgAAAA==.',Sn='Snovv:BAAALAAFFAIIAgAAAA==.',So='Solg:BAAALAAECgUIAwAAAA==.',Su='Summer:BAAALAAECgEIAQAAAA==.',Ti='Tiffanya:BAAALAAFFAIIAgAAAA==.',Ts='Ts:BAAALAADCgUIBQAAAA==.',Xi='Xiximao:BAAALAAECgEIAQAAAA==.',Xx='Xxboy:BAAALAAECggIEwAAAA==.',Yu='Yuchi:BAAALAAFFAIIBAAAAA==.Yuna:BAAALAAECggICAAAAA==.',Zi='Zio:BAAALAAECgYIBgAAAA==.',['一姐']='一姐夫一:BAAALAADCggIDQAAAA==.',['一尘']='一尘一劫:BAABLAAFFH8SAAIFAAMI3BcVQgCcAAAFAAMI3BcVQgCcAAAAAA==.',['一帆']='一帆青月:BAAALAAECgEIAQAAAA==.',['一船']='一船沁水:BAAALAAECgEIAQAAAA==.',['一艾']='一艾格雯一:BAAALAAECgYIBgAAAA==.',['一路']='一路在:BAAALAAECgYIBgAAAA==.',['三千']='三千院风:BAAALAAECgYIBgAAAA==.',['下雨']='下雨还是天晴:BAACLAAFFH8HAAMGAAIIvhd/GwCcAAAGAAIIvhd/GwCcAAAEAAII3BTgKwCUAAAsAAQKfxYAAwYABwh0HXYlAEwCAAYABwh0HXYlAEwCAAQABQiYHuNZAHIBAAEsAAUUAwgNAAcAZSYA.',['丨萨']='丨萨尓丨:BAAALAAECgYIBgAAAA==.',['中式']='中式熊猫武僧:BAABLAAFFH8KAAIIAAII/Qz7FQB8AAAIAAII/Qz7FQB8AAAAAA==.',['丶胖']='丶胖丶虎丶:BAAALAAECgEIAQAAAA==.',['丶醉']='丶醉心:BAAALAAECgYIDAAAAA==.',['丹特']='丹特丽安:BAABLAAFFH8NAAMEAAUIwwtkJAAaAQAEAAUIwwtkJAAaAQAGAAIIkQsQKgBCAAABLAAFFAYIFAADABsaAA==.',['乄燚']='乄燚焱乄:BAAALAADCgQIBAAAAA==.',['久木']='久木乔一:BAABLAAFFH8GAAIJAAIIQw8xYABGAAAJAAIIQw8xYABGAAAAAA==.',['九天']='九天冰龙隐:BAAALAAECgIIAgAAAA==.',['二二']='二二三四:BAABLAAFFH8IAAMKAAIIyRYtXQCZAAAKAAIIZxMtXQCZAAALAAEIfhl0FwBIAAAAAA==.',['人小']='人小龟大:BAAALAAECgYIBgAAAA==.',['今晚']='今晚砍老虎:BAAALAAFFAIIAwAAAA==.',['从天']='从天堂到地狱:BAAALAAECgIIAgAAAA==.',['从良']='从良剪青丝:BAAALAAECgIIAwAAAA==.',['伊丽']='伊丽傻白:BAAALAADCggIDgAAAA==.',['伊利']='伊利蛋怒刃:BAAALAAFFAIIAgAAAA==.',['伊古']='伊古尼鲁:BAAALAAECgUIBQAAAA==.',['传奇']='传奇小和尚:BAAALAADCgYIBgAAAA==.',['你看']='你看不见我:BAAALAAECgYIDQAAAA==.',['你真']='你真叫胖子么:BAAALAAECggIDAAAAA==.',['偷偷']='偷偷来一下:BAAALAAECgUIBAAAAA==.',['兜兜']='兜兜缺水:BAAALAADCgQICAAAAA==.兜兜缺竹:BAAALAADCgIIAgAAAA==.',['全能']='全能钢铁侠:BAABLAAFFH8KAAICAAYIXR15DAB6AQACAAYIXR15DAB6AQAAAA==.',['六宝']='六宝烛:BAAALAADCgYIDAAAAA==.',['兰博']='兰博万:BAAALAAECgMIBAAAAA==.',['冈格']='冈格尼尔:BAABLAAFFH8IAAIKAAIIggY5hgCCAAAKAAIIggY5hgCCAAAAAA==.',['冯宝']='冯宝宝:BAAALAAECgMIAgAAAA==.',['几百']='几百个基老:BAAALAAECgYIDgAAAA==.',['凯洛']='凯洛:BAAALAAECgYIEgAAAA==.',['刀光']='刀光贱影:BAAALAAECgYIBgAAAA==.',['初音']='初音:BAAALAAECgYIBgAAAA==.',['别来']='别来沾边:BAAALAAECgQIBAAAAA==.',['前女']='前女友:BAAALAAFFAIIAgAAAA==.',['加斯']='加斯特:BAAALAAECggICAAAAA==.',['北坡']='北坡杏花:BAAALAAECgYIBgAAAA==.',['北陂']='北陂杏花:BAABLAAFFH8ZAAIBAAMIpxywMgCuAAABAAMIpxywMgCuAAAAAA==.',['十个']='十个射击猎:BAAALAAECgYIBgAAAA==.',['千味']='千味涮:BAAALAAFFAIIBAAAAA==.',['半世']='半世浮沉丶:BAAALAAFFAIIAgAAAA==.',['半夏']='半夏如烟:BAABLAAFFH8OAAMMAAUIRBazTAAaAQAMAAUIQxWzTAAaAQANAAII2Q4kJQB9AAAAAA==.',['华丽']='华丽邂逅:BAAALAAECgYIBgAAAA==.',['华庭']='华庭笙歌:BAAALAAECgYIBgAAAA==.',['卖元']='卖元宵:BAAALAAECgMIBQAAAA==.',['卖油']='卖油条:BAABLAAECn8WAAIOAAYIVBmTOQB0AQAOAAYIVBmTOQB0AQAAAA==.',['卖烧']='卖烧饼:BAAALAAECgYIEAAAAA==.卖烧麦:BAABLAAFFH8HAAIKAAcIxiQJBgCcAgAKAAcIxiQJBgCcAgAAAA==.',['卖煎']='卖煎饼:BAAALAAECgYICwAAAA==.',['卖米']='卖米粉:BAAALAADCggICQAAAA==.',['卖葫']='卖葫芦:BAAALAAECggIEQAAAA==.',['卖饺']='卖饺子:BAABLAAECn8WAAMJAAYIgRcfVgBeAQAJAAYI/RYfVgBeAQAPAAYIFBBVQAA5AQAAAA==.',['卖馄']='卖馄饨:BAAALAADCggICAAAAA==.',['南天']='南天一剑:BAABLAAFFH8SAAIBAAYI0QoqKAAuAQABAAYI0QoqKAAuAQAAAA==.',['博玨']='博玨幽幽:BAABLAAFFH8HAAIMAAUIeRV5SwAeAQAMAAUIeRV5SwAeAQAAAA==.',['卡塔']='卡塔库栗:BAAALAAECgYIBgAAAA==.',['又一']='又一个倒下了:BAAALAAECgEIAQAAAA==.',['双刀']='双刀英雄:BAAALAADCgIIAgAAAA==.',['可爱']='可爱满满:BAAALAAECgIIAgAAAA==.',['吉按']='吉按娜:BAAALAAFFAIIBAAAAA==.',['名字']='名字很不重要:BAAALAAECgYIDgAAAA==.',['呆呆']='呆呆去哪儿:BAAALAADCgIIAgAAAA==.',['命运']='命运木马:BAAALAADCgIIAgAAAA==.',['咸鱼']='咸鱼饭:BAAALAADCgMIAwAAAA==.',['喜茶']='喜茶:BAAALAAFFAIIAgAAAA==.',['嘟嘟']='嘟嘟丶:BAAALAAECgEIAQAAAA==.',['嚼到']='嚼到你昏迷:BAAALAAECgUICQAAAA==.',['在此']='在此彼方:BAAALAAECgYICwAAAA==.',['地狱']='地狱火男爵:BAAALAADCgEIAQAAAA==.',['夜雨']='夜雨佾佾:BAAALAAECggICAAAAA==.',['大得']='大得瑟:BAAALAADCggIDgAAAA==.',['大耳']='大耳朵图图:BAAALAAECgEIAQAAAA==.',['天堂']='天堂之:BAAALAAECgQIBAAAAA==.天堂咆哮:BAAALAAECgYIBgAAAA==.',['天然']='天然战:BAAALAADCgYIBgAAAA==.',['天窗']='天窗:BAAALAAECgQIBAAAAA==.',['头巾']='头巾骆驼:BAAALAAECgMIAwAAAA==.',['奀芝']='奀芝芝:BAAALAAECgYICAAAAA==.',['奶不']='奶不动你的错:BAAALAAECgYIBgAAAA==.',['好样']='好样的布鲁斯:BAAALAAECgYIBwAAAA==.',['妖妖']='妖妖玲:BAAALAADCgQIBAAAAA==.',['姐夫']='姐夫:BAAALAAECgMIAwAAAA==.',['姬無']='姬無雙:BAABLAAFFH8KAAMNAAIISAlgFwA/AAANAAIIPQlgFwA/AAAMAAIIAQcSrAA5AAAAAA==.',['婉若']='婉若清风:BAABLAAFFH8HAAIKAAII6AyrgACGAAAKAAII6AyrgACGAAAAAA==.',['嬾潴']='嬾潴嘚釢甁:BAAALAAECgQIBAAAAA==.',['安度']='安度因乌瑞恩:BAAALAADCgYIBgAAAA==.',['射魂']='射魂猎心:BAAALAAECgYIBwAAAA==.',['小二']='小二上酒:BAAALAAECgYIBgAAAA==.',['小姽']='小姽婳:BAABLAAFFH8GAAIBAAII4xlKQwBRAAABAAII4xlKQwBRAAAAAA==.',['小暗']='小暗之殇:BAAALAAECggICwAAAA==.',['小梅']='小梅花:BAAALAADCgIIAgAAAA==.',['小棉']='小棉袄:BAAALAAECgYIBgAAAA==.',['小气']='小气天使:BAAALAADCgQIBAAAAA==.',['小灬']='小灬野:BAAALAAECgEIAQAAAA==.',['小珍']='小珍珠:BAABLAAFFH8GAAIQAAII6gy+SQCLAAAQAAII6gy+SQCLAAAAAA==.',['小絔']='小絔骑士:BAABLAAFFH8FAAIJAAIItwN4fQAzAAAJAAIItwN4fQAzAAAAAA==.',['小船']='小船儿:BAAALAAECggIEwAAAA==.',['小茉']='小茉莉:BAAALAADCgcIBwAAAA==.',['小野']='小野大輔:BAAALAAECgIIAgAAAA==.',['就差']='就差干饭了:BAAALAAECgYIBgAAAA==.',['就瞅']='就瞅你了:BAAALAAECgUIBQAAAA==.',['山姆']='山姆大叔:BAAALAAECgIIAgAAAA==.',['左手']='左手写爱:BAAALAAECgYIBgAAAA==.',['帅似']='帅似王大治:BAABLAAFFH8GAAIFAAUICwNwPgDEAAAFAAUICwNwPgDEAAAAAA==.',['带子']='带子双排:BAAALAAECgYIEAAAAA==.',['幸福']='幸福的战神:BAABLAAFFH8XAAIBAAYI0BT2GACaAQABAAYI0BT2GACaAQAAAA==.',['幽兰']='幽兰蝶梦:BAAALAAECgQIBAAAAA==.',['往事']='往事如影:BAAALAAECgIIAgAAAA==.',['得梅']='得梅因:BAABLAAFFH8GAAMRAAIIZgQnFwBsAAARAAIIZgQnFwBsAAASAAIIdwMOJAAhAAAAAA==.',['悲伤']='悲伤斜刘海:BAAALAADCgIIAgAAAA==.',['惩戒']='惩戒之光:BAAALAAFFAIIAwAAAA==.',['我想']='我想有个昵称:BAAALAADCgMIAwAAAA==.',['我是']='我是你的球迷:BAAALAADCgcIBwAAAA==.我是烙饼:BAAALAADCgEIAQAAAA==.我是黄蓉:BAAALAAECgYIBgAAAA==.',['我本']='我本无心:BAABLAAFFH8KAAIHAAIIKwvGSgBbAAAHAAIIKwvGSgBbAAAAAA==.',['戰活']='戰活下去:BAAALAAECgYICAAAAA==.',['房御']='房御术:BAAALAAECgYIEQAAAA==.',['挺好']='挺好看的:BAAALAAECgMIAwAAAA==.',['插地']='插地奶:BAAALAAFFAQIBAAAAA==.',['搜查']='搜查官:BAAALAAFFAIIAgAAAA==.',['擎道']='擎道京殿:BAAALAAFFAIIAgAAAA==.擎道淳圣:BAAALAAFFAIIAgAAAA==.',['故事']='故事的小黄瓜:BAAALAAECgEIAQAAAA==.',['文树']='文树:BAAALAAECgIIAgAAAA==.',['断片']='断片者:BAAALAAECgQIBAABLAAECgYIDgATAAAAAA==.',['旋律']='旋律烟花坠:BAAALAADCgMIAwAAAA==.',['无敌']='无敌帝王:BAAALAADCgIIAgAAAA==.',['无糖']='无糖不加冰:BAACLAAFFH8NAAIHAAMIZSYeCwBNAQAHAAMIZSYeCwBNAQAsAAQKfxwAAgcACAiIIv8HACEDAAcACAiIIv8HACEDAAAA.',['无限']='无限飞弹:BAAALAAECggICAAAAA==.',['时光']='时光:BAAALAADCgIIAgAAAA==.时光之房御:BAABLAAECn8WAAIJAAYImh6mRACOAQAJAAYImh6mRACOAQAAAA==.时光似箭:BAAALAAECgQIBAAAAA==.',['旷世']='旷世枭雄:BAAALAAFFAQIAwAAAA==.',['晚安']='晚安只对你说:BAABLAAFFH8fAAIOAAcIuBxqCgAfAgAOAAcIuBxqCgAfAgAAAA==.',['暗影']='暗影精灵:BAAALAADCgIIAgAAAA==.',['暮雪']='暮雪丶:BAAALAAECgYIDAAAAA==.',['暴力']='暴力的阿宝:BAAALAAECgQIBAAAAA==.',['最美']='最美的月光:BAABLAAFFH8KAAIHAAUI0w79IAAXAQAHAAUI0w79IAAXAQAAAA==.',['李寻']='李寻歡:BAAALAAECgcIEQABLAAFFAIIAgATAAAAAA==.',['李莫']='李莫愁:BAAALAADCgQIBAAAAA==.',['来之']='来之天堂的我:BAAALAAFFAIIBAAAAA==.',['枫殇']='枫殇:BAAALAADCggICAAAAA==.',['枫飘']='枫飘棂:BAABLAAFFH8IAAIMAAgIGhbNJgCXAQAMAAgIGhbNJgCXAQAAAA==.',['柑蕉']='柑蕉桔梨萝柚:BAAALAAECgYIBgAAAA==.',['桔桔']='桔桔咬桔:BAAALAADCgIIAgAAAA==.',['梅利']='梅利凯碎风:BAABLAAFFH8IAAIDAAIIDwgYagBRAAADAAIIDwgYagBRAAAAAA==.',['楓飘']='楓飘棂:BAAALAAECggIBQAAAA==.',['楷楷']='楷楷丶:BAAALAAECgYICQAAAA==.',['橙子']='橙子要吃肉:BAABLAAECn8VAAIKAAYIQBcDXwAyAQAKAAYIQBcDXwAyAQAAAA==.',['止攻']='止攻:BAAALAADCgYIBgAAAA==.',['死亡']='死亡咆哮者:BAAALAADCgEIAQAAAA==.',['比利']='比利丶王:BAACLAAFFH8FAAILAAII2hADEgB6AAALAAII2hADEgB6AAAsAAQKfxcAAgsACAgNEiQkAGIBAAsACAgNEiQkAGIBAAAA.',['毛就']='毛就完了:BAAALAAECgYICwAAAA==.',['水水']='水水獭:BAABLAAFFH8KAAIMAAQI/AyiLADPAAAMAAQI/AyiLADPAAAAAA==.',['水牧']='水牧年华:BAAALAADCgQIBAAAAA==.',['水秀']='水秀:BAAALAADCgcIBwAAAA==.',['永夜']='永夜星辰:BAABLAAFFH8HAAMUAAMIzgt7EwA0AAAOAAIIBg9CSACTAAAUAAMIsgV7EwA0AAAAAA==.',['永远']='永远的小火鸡:BAAALAAECgQIBAAAAA==.',['江湖']='江湖再见:BAAALAAECgYIBgAAAA==.',['沙绘']='沙绘子:BAAALAAFFAIIAgAAAA==.',['波灬']='波灬波:BAAALAAECgYIBgAAAA==.',['泰兰']='泰兰丶弗丁:BAAALAADCgMIAwAAAA==.',['流涟']='流涟黄荤:BAAALAAFFAIIAgAAAA==.',['海蓝']='海蓝蓝:BAACLAAFFH8MAAIJAAMI9BgHPQCfAAAJAAMI9BgHPQCfAAAsAAQKfxUAAwkABghzIYhYADwCAAkABghzIYhYADwCABUABggLFdBFAEMBAAAA.',['消失']='消失叔叔:BAAALAAECgQIBgAAAA==.',['漫步']='漫步云端:BAAALAADCgcIBwAAAA==.',['潇洒']='潇洒四爷:BAABLAAFFH8HAAIWAAMIcgYlEQBWAAAWAAMIcgYlEQBWAAAAAA==.',['濦诗']='濦诗吟到湿:BAAALAAFFAMIAwAAAA==.',['火雷']='火雷蚀刻:BAAALAADCgcIBwAAAA==.',['灬銶']='灬銶型戰榊灬:BAAALAAECgYIDwAAAA==.',['灰色']='灰色夜曲:BAAALAADCgUIBQAAAA==.',['炎枪']='炎枪素笺鸣:BAABLAAFFH8IAAIMAAYIuAC+tgAyAAAMAAYIuAC+tgAyAAAAAA==.',['烟雨']='烟雨凄迷丶:BAAALAAECgIIAgAAAA==.',['焦厚']='焦厚根:BAAALAAECgYIBgAAAA==.',['熊猫']='熊猫饼干:BAAALAAECgIIAgAAAA==.',['熊胆']='熊胆粉:BAAALAADCgYIBgAAAA==.',['熔冰']='熔冰者:BAAALAAECgEIAQABLAAECgYIDgATAAAAAA==.',['燀焯']='燀焯饭:BAAALAAECgYIBgAAAA==.',['爱上']='爱上猫猫的狗:BAAALAAECgEIAQAAAA==.',['爱允']='爱允宝:BAABLAAFFH8GAAIWAAIIwBeqEACOAAAWAAIIwBeqEACOAAAAAA==.',['爱飘']='爱飘零:BAAALAAECgYIBgAAAA==.',['狂偑']='狂偑:BAAALAAECgYIEwAAAA==.',['狂枫']='狂枫:BAAALAAECgYIBwAAAA==.',['狐狸']='狐狸狸:BAAALAAFFAIIAgAAAA==.',['独照']='独照:BAAALAAECgYIBgAAAA==.',['猎猎']='猎猎风中:BAABLAAFFH8PAAIMAAUIORwmNgBkAQAMAAUIORwmNgBkAQAAAA==.',['猎魔']='猎魔天使丶女:BAABLAAFFH8HAAIUAAQIcg00BQDxAAAUAAQIcg00BQDxAAAAAA==.',['猛将']='猛将之首:BAAALAAFFAIIBAAAAA==.',['王大']='王大牛:BAAALAAECgYIBgAAAA==.',['玛丽']='玛丽娅贝尔:BAABLAAFFH8QAAIQAAYI3hbUIQCUAQAQAAYI3hbUIQCUAQAAAA==.',['玥不']='玥不再:BAAALAAECggICAAAAA==.',['球王']='球王贝拉:BAAALAAECgYICwAAAA==.',['电费']='电费术:BAAALAADCgQIBAAAAA==.',['疑霜']='疑霜者:BAAALAADCgYICQABLAAECgYIDgATAAAAAA==.',['疯狂']='疯狂兔子:BAAALAAECgQIBAAAAA==.',['盾牌']='盾牌煎鸡蛋:BAAALAAECgEIAQAAAA==.',['瞅你']='瞅你咋滴:BAAALAAECgIIAgAAAA==.',['瞧你']='瞧你那样:BAAALAAECgYIEwAAAA==.',['砍你']='砍你没理由:BAAALAAECgYICwAAAA==.',['破碎']='破碎星光:BAABLAAFFH8IAAIJAAIIgxdWNACnAAAJAAIIgxdWNACnAAAAAA==.',['神圣']='神圣的翅膀:BAAALAADCgMIAwAAAA==.',['祭奠']='祭奠死去老陈:BAAALAAECgYIDwAAAA==.',['穿森']='穿森者:BAAALAADCggICAABLAAECgYIDgATAAAAAA==.',['竹子']='竹子:BAAALAAECgYICQAAAA==.',['第五']='第五人格:BAAALAADCgMIAwAAAA==.',['粉红']='粉红侠:BAAALAADCgIIAgAAAA==.',['红皮']='红皮火车:BAAALAAFFAIIAgAAAA==.',['纳芈']='纳芈:BAACLAAFFH8LAAIQAAQILxJ8QwDPAAAQAAQILxJ8QwDPAAAsAAQKfxQAAxAABwifHPNIABkCABAABwizGvNIABkCABcABAjpFJ4eAP8AAAAA.',['经风']='经风雨见彩虹:BAAALAADCggICgAAAA==.',['给爷']='给爷笑一个:BAAALAAECgUIBQAAAA==.',['绝对']='绝对黑人:BAABLAAFFH8GAAICAAIIRBPrMQAxAAACAAIIRBPrMQAxAAAAAA==.',['续集']='续集:BAAALAAECgIIAgAAAA==.',['网瘾']='网瘾李大爷:BAAALAAECgMIAwAAAA==.',['考拉']='考拉:BAAALAAECgcIBwAAAA==.考拉就是猴:BAABLAAFFH8IAAIKAAgIKSB2AwDOAgAKAAgIKSB2AwDOAgAAAA==.',['肉米']='肉米:BAACLAAFFH8tAAIUAAcIvSVRAACYAgAUAAcIvSVRAACYAgAsAAQKfyMAAhQACAhvJtoAAH4DABQACAhvJtoAAH4DAAAA.',['脱严']='脱严正:BAAALAAECgcIEwAAAA==.',['脸萌']='脸萌即使正义:BAACLAAFFH8lAAIMAAYIpSEHFQDpAQAMAAYIpSEHFQDpAQAsAAQKfysAAwwACAhuI1UdAOUCAAwACAhuI1UdAOUCAA0AAQjaFkO+ADMAAAAA.',['自然']='自然之声:BAAALAAECggIEAAAAA==.',['至爱']='至爱凡舒:BAAALAAFFAIIAgAAAA==.至爱疏影:BAAALAADCggIDQAAAA==.至爱米麒:BAAALAAECgIIAgAAAA==.',['艾菲']='艾菲斯:BAABLAAFFH8IAAIMAAgIygHCogA9AAAMAAgIygHCogA9AAAAAA==.',['芹泽']='芹泽多摩雄:BAABLAAFFH8JAAIMAAII/QnStAA0AAAMAAII/QnStAA0AAAAAA==.',['苗翠']='苗翠花:BAAALAAECgMIAwAAAA==.',['苗若']='苗若兰:BAAALAADCgEIAQAAAA==.',['若影']='若影千面:BAAALAAECgQIBAAAAA==.',['若雪']='若雪未汐:BAAALAADCgEIAQAAAA==.',['莱茵']='莱茵里昂:BAAALAAECgYIEwABLAAFFAIIAgATAAAAAA==.',['萌叔']='萌叔丶:BAAALAADCggICAAAAA==.',['萌萌']='萌萌蕾:BAACLAAFFH8gAAMGAAcIwBD7CADEAQAGAAcIwBD7CADEAQAEAAEIngGZUQAvAAAsAAQKfy0AAgYACAhvGeUmAEICAAYACAhvGeUmAEICAAAA.',['萨斯']='萨斯必雷:BAAALAAECggICgAAAA==.',['葬愛']='葬愛:BAAALAAECgQIBgAAAA==.',['葱油']='葱油面加素鸡:BAAALAAECgQIBAAAAA==.',['蒽楠']='蒽楠:BAAALAAECgUIBQAAAA==.',['蓝色']='蓝色幽灵火:BAAALAADCgIIAgAAAA==.',['蕾菲']='蕾菲娜:BAABLAAFFH8FAAMBAAUIrgR5MgCwAAABAAQISAN5MgCwAAAYAAEIQwr4BQA+AAAAAA==.',['薇妲']='薇妲:BAABLAAFFH8RAAMWAAUIvQ65CAACAQAWAAUIpA65CAACAQAFAAMIownkRgCHAAAAAA==.',['虚渺']='虚渺淡然逝去:BAABLAAFFH8QAAIFAAUIxhDhKwDjAAAFAAUIxhDhKwDjAAABLAAFFAYIDwAJAAscAA==.',['蜜丫']='蜜丫:BAAALAAFFAIIAgAAAA==.',['蝎子']='蝎子莱莱灬:BAABLAAFFH8GAAIDAAYIawCFgQAXAAADAAYIawCFgQAXAAAAAA==.',['袁紫']='袁紫衣:BAAALAAECggICAAAAA==.',['角落']='角落的尘埃:BAACLAAFFH8WAAIZAAUIVBOMDQA1AQAZAAUIVBOMDQA1AQAsAAQKfxYAAhkACAihGmsVAG4CABkACAihGmsVAG4CAAAA.',['谁是']='谁是小松鼠:BAAALAAFFAIIBAAAAA==.',['贝多']='贝多芬的眼泪:BAAALAAECgYIDAAAAA==.',['败者']='败者食尘:BAAALAADCgEIAQAAAA==.',['赤地']='赤地雪:BAAALAAECgYIDgAAAA==.',['跟师']='跟师太抢秃驴:BAACLAAFFH8xAAMQAAYIHhWDKgBwAQAQAAYIHhWDKgBwAQAaAAEIPgdwLgBGAAAsAAQKfyoABBAABwgGHjI+AEECABAABgj6IDI+AEECABoABwiIEbwyAKMBABcAAghtA042AFgAAAAA.',['路窄']='路窄江寒:BAAALAADCgYICAAAAA==.',['输入']='输入法记住你:BAAALAAECgIIAgABLAAECgYIBgATAAAAAA==.',['这比']='这比有诈:BAAALAAFFAMIAgAAAA==.',['追火']='追火者:BAAALAAECgYIBgABLAAECgYIDgATAAAAAA==.',['追风']='追风筝的胖子:BAACLAAFFH8GAAIOAAII/xKHQACZAAAOAAII/xKHQACZAAAsAAQKfxUAAg4ABwh5Hs8+AGYCAA4ABwh5Hs8+AGYCAAAA.',['逐风']='逐风者阿光:BAABLAAFFH8IAAICAAIIfxqOGQCSAAACAAIIfxqOGQCSAAAAAA==.',['遥远']='遥远的星叹:BAAALAAECgEIAQAAAA==.',['那个']='那个滴凯:BAAALAAFFAMIAwAAAA==.',['邪能']='邪能辣翅:BAAALAAECgYIBgAAAA==.',['醉訫']='醉訫丶:BAAALAAECgYICgAAAA==.醉訫呀丶:BAAALAAECgYIEwAAAA==.醉訫哟丶:BAAALAAECgYIDQAAAA==.',['释火']='释火者:BAAALAAECgYICQABLAAECgYIDgATAAAAAA==.',['镜影']='镜影湖光:BAACLAAFFH8GAAIZAAII7g4TGQCbAAAZAAII7g4TGQCbAAAsAAQKfxUAAhkACAiaFg0gABYCABkACAiaFg0gABYCAAAA.',['闪电']='闪电小旋风:BAAALAAECgYIBgAAAA==.',['阐影']='阐影者:BAAALAADCgYIBgAAAA==.',['阿多']='阿多多丶:BAAALAAECgQIBAAAAA==.',['阿尔']='阿尔萨凘:BAAALAAFFAIIBAAAAA==.',['阿拉']='阿拉丁铜须:BAAALAADCgEIAQAAAA==.',['阿迩']='阿迩萨嘶:BAAALAAECgEIAQAAAA==.',['阿鷄']='阿鷄:BAAALAAECgYIDwAAAA==.',['降维']='降维攻击:BAACLAAFFH8GAAIJAAIIOhYyWABKAAAJAAIIOhYyWABKAAAsAAQKfxYAAgkABghkHvaDAOUBAAkABghkHvaDAOUBAAAA.',['降龙']='降龙十九掌:BAAALAADCgYIBgAAAA==.',['随缘']='随缘箭法:BAAALAAECgQIBAAAAA==.',['雨泽']='雨泽:BAAALAADCgEIAQAAAA==.',['霹雳']='霹雳啪啦:BAAALAAFFAIIAgAAAA==.',['静听']='静听疯吼:BAAALAAECgUIBQAAAA==.静听风吼:BAAALAAECgQICQAAAA==.',['面面']='面面:BAABLAAFFH8FAAIKAAIINQ+jbACSAAAKAAIINQ+jbACSAAAAAA==.',['韦恩']='韦恩切克闹:BAAALAAECgMIAwAAAA==.',['風輕']='風輕雲淡:BAABLAAFFH8XAAIDAAUI2xwLIwBGAQADAAUI2xwLIwBGAQAAAA==.',['风哈']='风哈拉哨:BAAALAAECgEIAQAAAA==.',['风流']='风流七少:BAAALAAFFAIIAgAAAA==.',['飘零']='飘零一生丶:BAAALAAFFAEIAQAAAA==.',['骑汝']='骑汝步红尘:BAAALAAECgQIBAAAAA==.',['魔法']='魔法猫粮:BAAALAAECgEIAQAAAA==.',['鸡肉']='鸡肉臊面:BAAALAAECgMIAwAAAA==.',['鸭咩']='鸭咩蝶:BAAALAAECgMIAwAAAA==.',['麦兜']='麦兜:BAAALAAECgYIBgAAAA==.',['黑人']='黑人兄弟:BAABLAAFFH8FAAIMAAII1AqXsAA3AAAMAAII1AqXsAA3AAAAAA==.',['黑色']='黑色拉面:BAAALAAECgYIBgAAAA==.',['黑蛋']='黑蛋儿:BAAALAAECgYICgAAAA==.',['黑风']='黑风小萨:BAAALAAECgYICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end