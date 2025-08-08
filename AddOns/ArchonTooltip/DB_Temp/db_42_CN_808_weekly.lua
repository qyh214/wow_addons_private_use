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
 local lookup = {'Rogue-Assassination','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Paladin-Retribution','Paladin-Protection','Shaman-Restoration','Druid-Guardian','Druid-Balance','Hunter-Marksmanship','DemonHunter-Havoc','Mage-Frost','Mage-Fire','Mage-Arcane','Priest-Shadow','Priest-Holy','Druid-Restoration','DeathKnight-Unholy','Hunter-BeastMastery','Warrior-Fury','Paladin-Holy','Monk-Mistweaver','Priest-Discipline','Evoker-Devastation','DemonHunter-Vengeance',}; local provider = {region='CN',realm='范达尔鹿盔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alhena:BAABKgAFFH8KAAIBAAYI2BruAgCPAQABAAYI2BruAgCPAQAAAA==.',Cl='Clyne:BAACKgAFFH8UAAMCAAYIBiRuAAB+AQACAAUI/h9uAAB+AQADAAYIzRkZFgDMAAAqAAQKfyQAAwMACAg9JXkJAKECAAMACAg9JXkJAKECAAQACAh+HWMLAEICAAAA.',Co='Congbaobao:BAABKgAECn8rAAMFAAgIyiLMIACWAgAFAAgIyiLMIACWAgAGAAEIZAAAAAAAAAAAAA==.',In='Inch:BAABKgAFFH8IAAIGAAgI0hNdBQDkAQAGAAgI0hNdBQDkAQAAAA==.',Li='Lidia:BAAAKgAECgEIAQAAAA==.',Lu='Luoluo:BAAAKgAECgYIBgAAAA==.',Lz='Lzq:BAAAKgAECggICAAAAA==.',Mo='Moteheart:BAABKgAFFH8IAAIDAAYIBxX1FgBMAQADAAYIBxX1FgBMAQAAAA==.',Mu='Muskmeow:BAAAKgADCgQIBAAAAA==.',Pa='Pangpang:BAAAKgADCgEIAQAAAA==.',Pe='Persephonex:BAAAKgADCggICAAAAA==.',Po='Pooleroo:BAAAKgAECgcIBwAAAA==.',Ti='Tiffanyyoona:BAABKgAFFH8GAAIHAAYI4ApWFgAqAQAHAAYI4ApWFgAqAQAAAA==.',Wa='Walawaka:BAACKgAFFH8IAAIIAAMIKQ6+CACBAAAIAAMIKQ6+CACBAAAqAAQKfxYAAwkACAjDELkoAA4BAAkACAgDDLkoAA4BAAgABwjLD6AhANoAAAAA.',['一碗']='一碗蛋炒饭:BAAAKgAECgcICgAAAA==.',['一箭']='一箭要你命:BAAAKgAECgUICgAAAA==.',['丁神']='丁神:BAAAKgAECggICAAAAA==.',['丑娘']='丑娘娘:BAABKgAECn8hAAIHAAgI5xIQPACFAQAHAAgI5xIQPACFAQAAAA==.',['东方']='东方呆:BAAAKgAECgEIAQAAAA==.',['丢丢']='丢丢大宝贝:BAAAKgAECgUIBQAAAA==.',['丨二']='丨二愣子丨:BAABKgAFFH8IAAIKAAgIARJeBgAEAgAKAAgIARJeBgAEAgAAAA==.',['丨吃']='丨吃了就睡丨:BAABKgAFFH8QAAMDAAgIshefCQDyAQADAAgIshefCQDyAQACAAQIKAjYDADDAAAAAA==.',['丨流']='丨流氓丶貔貅:BAAAKgAECgcICQAAAA==.',['丶神']='丶神秀開天:BAAAKgAECgcIBwAAAA==.',['么力']='么力斯古:BAAAKgAECgcIBwAAAA==.',['九五']='九五二柒:BAAAKgADCgMIAwAAAA==.',['九号']='九号:BAAAKgADCgIIAgAAAA==.',['了凡']='了凡洋一:BAAAKgAFFAIIAgAAAA==.',['五重']='五重唱:BAAAKgAECgUIBQAAAA==.',['亼冇']='亼冇:BAAAKgADCgUIBQAAAA==.',['从小']='从小不学好:BAAAKgAECgUIBgAAAA==.',['伊瑞']='伊瑞尔救赎者:BAAAKgADCggICAAAAA==.',['伊薇']='伊薇丝猎龙者:BAAAKgAECgUIBQAAAA==.',['但书']='但书:BAAAKgADCgIIAgAAAA==.',['侢戰']='侢戰:BAABKgAFFH8FAAIGAAUIZxp8DQAjAQAGAAUIZxp8DQAjAQABKgAFFAgICAALAOcMAA==.',['凉夏']='凉夏:BAAAKgAFFAYIAgAAAA==.',['十一']='十一:BAABKgAFFH8IAAIFAAgI1BgVCgAiAgAFAAgI1BgVCgAiAgAAAA==.',['占戈']='占戈馬奇:BAAAKgAFFAIIAgAAAA==.',['双刺']='双刺:BAAAKgAECggICwAAAA==.',['吃宝']='吃宝石长大:BAAAKgAFFAIIAgAAAA==.',['哀伤']='哀伤:BAAAKgAECgMIAwAAAA==.',['回头']='回头一刀:BAABKgAECn80AAQMAAgIvB/6BgBAAgAMAAgIvB/6BgBAAgANAAIIkhMhOQB5AAAOAAEILA39ngAoAAAAAA==.',['圆滚']='圆滚滚的程程:BAAAKgAECgYICAAAAA==.',['圣光']='圣光小则:BAAAKgAFFAgIBAAAAA==.圣光没空罩你:BAAAKgAECgYIDgAAAA==.',['圣十']='圣十字天神:BAAAKgAECgcICgAAAA==.',['城市']='城市一劣人:BAABKgAFFH8MAAIKAAYIpxVLCwBdAQAKAAYIpxVLCwBdAQAAAA==.',['墨言']='墨言:BAABKgAECn8YAAMPAAgIjRUgDwCjAQAPAAgIjRUgDwCjAQAQAAIIygNQOAAzAAAAAA==.',['壹骑']='壹骑绝尘:BAAAKgAECgEIAQAAAA==.',['夏偌']='夏偌风依旧:BAABKgAFFH8JAAMRAAYIDQtqEQATAQARAAYIDQtqEQATAQAJAAEImQfjYAA2AAAAAA==.',['多巴']='多巴胺:BAAAKgAECggIAgAAAA==.',['夜阑']='夜阑谣:BAAAKgAFFAgIBAAAAA==.',['大灰']='大灰狼:BAAAKgADCgEIAQAAAA==.',['天堂']='天堂之焰:BAABKgAFFH8GAAIOAAYIHxxQCgDHAQAOAAYIHxxQCgDHAQAAAA==.',['太上']='太上老君:BAAAKgAECgUIAwAAAA==.',['头亮']='头亮才看得见:BAAAKgAFFAQIBAAAAA==.',['奇门']='奇门遁甲:BAABKgAFFH8VAAQDAAgIwRcmCQD7AQADAAgIZhYmCQD7AQACAAUIBQlsDgCyAAAEAAEI6xMXEwBZAAAAAA==.',['女猎']='女猎手:BAAAKgAECgEIAQAAAA==.',['姑奶']='姑奶奶的春天:BAAAKgAECggICAAAAA==.',['孤寂']='孤寂的精灵:BAAAKgADCgYIBgAAAA==.',['寂静']='寂静的黎明:BAAAKgAECggIEwAAAA==.',['小兔']='小兔吃饱了:BAAAKgAECgUICQAAAA==.',['小哪']='小哪吒:BAAAKgAFFAQIBAAAAA==.',['小悲']='小悲剧:BAAAKgAFFAQIBAABKgAFFAgIDAAOACITAA==.',['小短']='小短腿:BAAAKgADCgEIAgAAAA==.',['小笠']='小笠原茉由:BAAAKgAECgIIAwAAAA==.',['小霖']='小霖霖:BAAAKgAECggIDAAAAA==.',['小黄']='小黄黄:BAAAKgAECggICAAAAA==.',['尛萌']='尛萌兒:BAABKgAFFH8FAAISAAUISBEUHwAmAQASAAUISBEUHwAmAQAAAA==.',['就这']='就这样好了:BAAAKgAECgQIBAAAAA==.',['屁屁']='屁屁然:BAAAKgAFFAgIBAAAAA==.',['崩溃']='崩溃了:BAAAKgAECgYIBgAAAA==.',['带刀']='带刀蝴蝶:BAACKgAFFH9TAAMTAAgIuCNtAQDWAgATAAgIuCNtAQDWAgAKAAEIZRMxJQBMAAAqAAQKfzIAAhMACAiyJe8FAPoCABMACAiyJe8FAPoCAAAA.',['年年']='年年:BAAAKgAECggICAAAAA==.',['弓无']='弓无不克:BAAAKgAECgIIAgAAAA==.',['张含']='张含韵:BAAAKgADCgIIAgAAAA==.',['张翠']='张翠翠:BAAAKgAECgEIAQAAAA==.',['張喜']='張喜樂:BAABKgAECn8nAAIFAAgIZB2fLQBJAgAFAAgIZB2fLQBJAgAAAA==.',['心灵']='心灵守墓人:BAAAKgAECgQIBAAAAA==.',['怒风']='怒风月辛:BAAAKgAFFAQIBAAAAA==.',['怨念']='怨念的小牧:BAAAKgADCgEIAQAAAA==.',['恶魔']='恶魔小胖:BAAAKgAFFAIIAQABKgAFFAgIDgAFAKwkAA==.',['惊惶']='惊惶木:BAABKgAFFH8IAAIRAAQI7Rh+GADcAAARAAQI7Rh+GADcAAAAAA==.',['慈母']='慈母守中线:BAAAKgADCggICAAAAA==.',['慕白']='慕白:BAAAKgAFFAgIAQAAAA==.',['慷慨']='慷慨的尴尬:BAAAKgAFFAQIAQAAAA==.',['我不']='我不是萨:BAAAKgAECgcIBwAAAA==.',['战无']='战无不胜丶:BAAAKgAECgIIAgAAAA==.',['指原']='指原莉乃:BAAAKgADCggIEAAAAA==.',['挚爱']='挚爱丨丶永恒:BAABKgAFFH8GAAIQAAYIJCP/AwAMAgAQAAYIJCP/AwAMAgAAAA==.',['教授']='教授:BAABKgAFFH8OAAMPAAgIUBzGAAAKAgAPAAYIfSLGAAAKAgAQAAMIMA1kHgDQAAAAAA==.',['无限']='无限回忆:BAAAKgAFFAQIBAAAAA==.',['晋如']='晋如唐风:BAABKgAFFH8WAAMNAAgIxRcvBABUAgANAAgIxRcvBABUAgAOAAQI9ACIBwBOAAAAAA==.',['晓丶']='晓丶偏想:BAAAKgAECgEIAQAAAA==.',['最後']='最後的德萊尼:BAAAKgAECgYIBwAAAA==.最後的薩滿:BAAAKgAECggIEQAAAA==.',['月丶']='月丶完美倾城:BAAAKgAECgEIAQAAAA==.',['月夜']='月夜舞霓裳:BAAAKgAFFAQIBAAAAA==.',['月映']='月映幽游:BAAAKgADCgIIAgAAAA==.',['有有']='有有守护神:BAAAKgAECgEIAQAAAA==.',['有期']='有期三十天:BAABKgAFFH8GAAIGAAYIRAzYEQDxAAAGAAYIRAzYEQDxAAAAAA==.',['杏干']='杏干:BAABKgAFFH8OAAITAAMIzhmUJwDnAAATAAMIzhmUJwDnAAABKgAFFAgICAATAHkgAA==.',['梦满']='梦满枝:BAAAKgAFFAQIAQAAAA==.',['楚岚']='楚岚真人:BAAAKgADCgQIBAAAAA==.',['橙汁']='橙汁:BAAAKgAFFAEIAQAAAA==.',['沉醉']='沉醉不知归路:BAAAKgAECgcIBwAAAA==.',['泪梦']='泪梦红尘:BAAAKgAFFAQIBAAAAA==.',['洅不']='洅不斬:BAABKgAECn8WAAIUAAcIDxecJwCgAQAUAAcIDxecJwCgAQAAAA==.',['流星']='流星逐月:BAAAKgAECgEIAQAAAA==.',['浮元']='浮元兔兔:BAAAKgAECggIDQAAAA==.',['浮华']='浮华有梦:BAAAKgAFFAgIBAAAAA==.',['海豚']='海豚有海:BAAAKgAECgIIAgAAAA==.',['溜门']='溜门撬锁:BAAAKgADCgcIBwAAAA==.',['火工']='火工头陀:BAAAKgADCggICAAAAA==.',['火猫']='火猫的怨念:BAAAKgAECgIIAgAAAA==.',['灭世']='灭世者之影:BAACKgAFFH8MAAIBAAQIxRZ/GADkAAABAAQIxRZ/GADkAAAqAAQKfxYAAgEACAg0FE4bAKoBAAEACAg0FE4bAKoBAAAA.',['烧钱']='烧钱一号:BAAAKgAFFAQIAgAAAA==.',['牛牟']='牛牟犇:BAAAKgAFFAIIAgAAAA==.',['牛皮']='牛皮克拉斯:BAABKgAECn8VAAMVAAgIsBSRFQC9AQAVAAgIsBSRFQC9AQAFAAcIYAwnpwAAAQAAAA==.',['牛老']='牛老道:BAAAKgAFFAIIAgAAAA==.',['牛鼻']='牛鼻子:BAAAKgAECgUIBQAAAA==.',['猎艳']='猎艳人生:BAAAKgAECgQIBAAAAA==.',['玄冰']='玄冰烈火:BAAAKgAECgEIAQAAAA==.',['玉黛']='玉黛儿:BAAAKgADCggICAAAAA==.',['王闪']='王闪电:BAAAKgADCgIIAgAAAA==.',['电耗']='电耗儿皮卡丘:BAAAKgADCgUIBQAAAA==.',['痛定']='痛定思痛:BAAAKgAECgQIBwAAAA==.',['白富']='白富美:BAAAKgADCgEIAQAAAA==.',['白巧']='白巧克力豆奶:BAABKgAFFH8IAAIWAAYIeCB9CwBvAQAWAAYIeCB9CwBvAQAAAA==.',['白色']='白色的魅力:BAAAKgAECgIIAgAAAA==.',['盗亦']='盗亦有盗:BAAAKgAECgQIBAAAAA==.',['直面']='直面天命:BAAAKgAECgYIBgAAAA==.',['破妄']='破妄之瞳:BAAAKgADCgQIBAAAAA==.',['离离']='离离原上谱:BAAAKgAECggICAAAAA==.',['笑鱼']='笑鱼:BAAAKgAECgIIAgAAAA==.',['箭神']='箭神传说:BAAAKgAECgYIBgAAAA==.',['糊精']='糊精糊精:BAABKgAFFH8IAAIBAAgIcRWxBABQAgABAAgIcRWxBABQAgAAAA==.',['糊糊']='糊糊精精:BAABKgAFFH8IAAIXAAgIBQacBwCuAQAXAAgIBQacBwCuAQAAAA==.',['老冲']='老冲锋:BAAAKgADCggICQAAAA==.',['芯殇']='芯殇丨龙龙:BAABKgAFFH8QAAMXAAgIgB7ZAwAbAgAXAAcIaCDZAwAbAgAPAAYIehdzCwBHAQAAAA==.',['花仙']='花仙子粉丝:BAAAKgAFFAEIAQAAAA==.',['苹果']='苹果粘豆包:BAABKgAFFH8HAAIYAAcIOAlhDwBqAQAYAAcIOAlhDwBqAQAAAA==.',['范特']='范特:BAABKgAFFH8GAAIYAAYIaxHlEgA8AQAYAAYIaxHlEgA8AQAAAA==.',['草莓']='草莓粘豆包:BAAAKgAFFAIIAgAAAA==.',['菲雅']='菲雅:BAAAKgAECgYIBgAAAA==.',['萌萌']='萌萌的俊俊:BAAAKgAFFAMIAwAAAA==.萌萌的艾佳:BAABKgAFFH8eAAIHAAcIIRZ0CwBFAQAHAAcIIRZ0CwBFAQAAAA==.',['萧雨']='萧雨亦馨:BAAAKgAECgMIAwAAAA==.',['萬兽']='萬兽:BAAAKgAFFAgIAgAAAA==.',['落苏']='落苏:BAAAKgAECgUIBQAAAA==.',['落魄']='落魄灬怒风:BAABKgAFFH8GAAILAAYIoQWVEQAYAQALAAYIoQWVEQAYAQAAAA==.',['蒲荟']='蒲荟:BAAAKgAECgYIBgAAAA==.',['蕊肉']='蕊肉:BAABKgAFFH8IAAMGAAYIVRwTCQBxAQAGAAYIVRwTCQBxAQAFAAIIHgnBMACsAAAAAA==.',['蕾米']='蕾米尔:BAAAKgAECgUIBQAAAA==.',['螳螂']='螳螂:BAABKgAFFH8FAAIZAAMIVQQyDwBsAAAZAAMIVQQyDwBsAAAAAA==.',['觅夏']='觅夏:BAAAKgAECgIIAgAAAA==.',['贫道']='贫道不知道:BAAAKgAECggIDgAAAA==.',['达丽']='达丽安娜:BAAAKgAECgYIBwAAAA==.',['迷惘']='迷惘鬼余生:BAAAKgAECgMIBAAAAA==.',['逐猎']='逐猎者丶追月:BAAAKgADCgYIBgAAAA==.',['速度']='速度灭呀:BAABKgAFFH8GAAIOAAYIZwVJMwCWAAAOAAYIZwVJMwCWAAAAAA==.',['道友']='道友丶请留步:BAAAKgADCgEIAQAAAA==.',['里卡']='里卡鲁多:BAAAKgAECgQIBAAAAA==.',['门捷']='门捷列夫:BAABKgAFFH8KAAIHAAYIhBhTAQCnAQAHAAYIhBhTAQCnAQAAAA==.',['阳崽']='阳崽不吃羊:BAAAKgAECgcICQAAAA==.',['阿克']='阿克萌德丶:BAAAKgAECggICAAAAA==.',['阿莱']='阿莱克斯菲儿:BAAAKgAECggICAAAAA==.',['顺风']='顺风顺水顺财:BAAAKgADCgQIBAAAAA==.',['风烛']='风烛残年:BAAAKgADCgIIAgAAAA==.',['风轻']='风轻花落:BAAAKgAECgMIBAAAAA==.',['飞花']='飞花挞:BAAAKgAFFAgIBQAAAA==.',['马小']='马小花:BAAAKgAECgIIAgAAAA==.',['麽头']='麽头麽脑:BAABKgAFFH8JAAIMAAQImR4FDQD/AAAMAAQImR4FDQD/AAAAAA==.',['黑崎']='黑崎一护:BAAAKgAECgYICQAAAA==.',['龘龘']='龘龘:BAAAKgADCggICAAAAA==.',['龙魅']='龙魅:BAABKgAFFH8GAAIYAAYIRQw8FQAjAQAYAAYIRQw8FQAjAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end