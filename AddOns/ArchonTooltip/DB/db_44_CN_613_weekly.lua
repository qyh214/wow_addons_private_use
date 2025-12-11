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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Frost','DeathKnight-Blood','DemonHunter-Havoc','Paladin-Retribution','Paladin-Protection','Warrior-Fury','Hunter-BeastMastery','Priest-Holy','Mage-Arcane','Druid-Restoration','Druid-Balance','Druid-Guardian','DemonHunter-Any','Priest-Shadow','Warrior-Arms','Warrior-Protection','Monk-Mistweaver','Mage-Frost','Warlock-Destruction','Hunter-Marksmanship','DemonHunter-Vengeance','Unknown-Unknown','Shaman-Restoration','Paladin-Holy','Shaman-Elemental','Monk-Windwalker','Warlock-Demonology','Evoker-Preservation','Evoker-Devastation',}; local provider = {region='CN',realm='圣火神殿',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bu='Buorgdius:BAACLAAFFH8GAAMBAAIIsgx2EwCMAAABAAIIaAt2EwCMAAACAAIIJQjPiQB/AAAsAAQKfxcAAwIACAjOFsh/APoBAAIACAjOFsh/APoBAAMAAQhZGJlLADsAAAAA.',Co='Conquest:BAACLAAFFH8tAAICAAYIvRy/IgCpAQACAAYIvRy/IgCpAQAsAAQKfxQAAwIABwioGHTOAIUBAAIABwioGHTOAIUBAAEABAh/EY9CAMkAAAAA.',Da='Darius:BAAALAAFFAIIAgAAAA==.',De='Deathgun:BAAALAAECgQIBAAAAA==.Deviltol:BAAALAAECgYIDgAAAA==.',Dm='Dmobaia:BAABLAAFFH8HAAIEAAMIcg0pIgDdAAAEAAMIcg0pIgDdAAAAAA==.',Dz='Dzyang:BAAALAAECgIIAgAAAA==.',Ec='Echoma:BAAALAAECgMIAwAAAA==.',Fo='Foii:BAABLAAFFH8LAAIEAAYIeQjLIgDZAAAEAAYIeQjLIgDZAAAAAA==.',Ga='Gail:BAAALAADCggICQAAAA==.',Gh='Ghyhuijn:BAAALAADCgYICQAAAA==.',Ha='Harish:BAACLAAFFH8JAAIFAAMI/ROWQQCQAAAFAAMI/ROWQQCQAAAsAAQKfysAAwYABwi7HnUKAPkBAAUABwhKHZ5TAEcCAAYABwiwHHUKAPkBAAAA.',Jm='Jm:BAAALAAFFAIIAgAAAA==.Jmiracle:BAAALAAFFAIIAgAAAA==.',Ke='Kerwin:BAABLAAFFH8MAAIHAAMIiw9aOgCJAAAHAAMIiw9aOgCJAAAAAA==.',Li='Lierena:BAABLAAFFH8SAAIIAAMI2RkTbQCIAAAIAAMI2RkTbQCIAAAAAA==.',Mo='Mooncancer:BAAALAAECgEIAQAAAA==.Moss:BAABLAAFFH8RAAMCAAUIbhM5RgAhAQACAAUINw05RgAhAQABAAMI7hYZDACaAAAAAA==.',Oo='Ooxxd:BAAALAADCgcIBwAAAA==.Ooxxz:BAAALAADCgYIBgAAAA==.',Sa='Samana:BAAALAAECgEIAQAAAA==.',Tm='Tmskii:BAACLAAFFH8KAAIJAAII9A+TPABxAAAJAAII9A+TPABxAAAsAAQKfxsAAgkABwjnFKUqAGMBAAkABwjnFKUqAGMBAAAA.Tmxkii:BAABLAAFFH8IAAICAAIIxg/4bQCRAAACAAIIxg/4bQCRAAAAAA==.',Tv='Tvt:BAAALAADCgIIAgAAAA==.',Va='Valisere:BAAALAAECgYIBwAAAA==.',Wa='Waoh:BAABLAAFFH8GAAIIAAYIhgBhwQAdAAAIAAYIhgBhwQAdAAAAAA==.',Wq='Wqq:BAABLAAFFH8GAAIKAAYIog3TKwBgAQAKAAYIog3TKwBgAQAAAA==.',Yu='Yuanzhuo:BAAALAAFFAEIAQAAAA==.',['一岁']='一岁一枯荣:BAAALAADCgYIBgAAAA==.',['一幻']='一幻兽一:BAAALAAECgQIBAAAAA==.一幻化骑士一:BAAALAAECgIIAgAAAA==.一幻战一:BAAALAADCgEIAQAAAA==.一幻术一:BAAALAAECgYIBgAAAA==.一幻狼一:BAAALAADCgMIAwAAAA==.一幻骑一:BAAALAAECgEIAQAAAA==.',['一瞬']='一瞬千击:BAAALAADCgIIAgAAAA==.',['三國']='三國赵云:BAAALAAECgYIDAAAAA==.',['三生']='三生万物:BAAALAAECgYICAAAAA==.',['不会']='不会奶不会防:BAAALAAECgUIBgAAAA==.',['不可']='不可多德的德:BAACLAAFFH8SAAILAAgIMAV0LAC7AAALAAgIMAV0LAC7AAAsAAQKfyMABAwACAixGnogAF0CAAwABwhzHnogAF0CAAsABQjDGL88ACgBAA0ABgjbACk4ADwAAAAA.',['不哭']='不哭不闹:BAAALAAFFAIIAgAAAA==.',['不唱']='不唱情歌:BAAALAADCgYIBgAAAA==.',['不讲']='不讲理大王:BAAALAAECgYICwAAAA==.',['丑牛']='丑牛武德:BAABLAAFFH8PAAIHAAYIbhAuHgB4AQAHAAYIbhAuHgB4AQAAAA==.',['东大']='东大肥肠医院:BAAALAAECgYICQAAAA==.',['东风']='东风雷诺:BAAALAAFFAIIBAAAAA==.',['丨於']='丨於罪丨:BAAALAAECgIIAgAAAA==.',['丨祈']='丨祈愿丨:BAAALAAECgMIAwAAAA==.',['临时']='临时数据:BAABLAAFFH8tAAIIAAcIOSHaCQBEAgAIAAcIOSHaCQBEAgAAAA==.',['乐乐']='乐乐清风:BAAALAAFFAIIAgAAAA==.',['二五']='二五仔:BAAALAAECggIBgAAAA==.',['二大']='二大爷:BAABLAAFFH8GAAIDAAYIegkVDgAkAQADAAYIegkVDgAkAQAAAA==.',['亨利']='亨利天使:BAAALAAECgQIBAAAAA==.',['从不']='从不用美颜:BAABLAAFFH8GAAIOAAYIEQAAAAAAAAAEAAYIEQAAAAAAAAAAAA==.',['伍陆']='伍陆柒:BAAALAAECgIIAgAAAA==.',['休杰']='休杰克曼:BAAALAADCgQICAAAAA==.',['低调']='低调法爺:BAAALAAECgYIDgAAAA==.',['佟楛']='佟楛漱:BAAALAADCgUIBQAAAA==.',['依然']='依然十月:BAAALAAFFAIIAgAAAA==.依然在巅峰:BAAALAAECgQIBAAAAA==.',['光影']='光影使:BAAALAAECgMIAwAAAA==.',['兜兜']='兜兜有寂寞:BAAALAAFFAIIAgAAAA==.',['冰血']='冰血老中医:BAAALAAECgYIEAAAAA==.',['冰雪']='冰雪之影:BAAALAAECgEIAQAAAA==.冰雪之神:BAAALAADCgYIDAAAAA==.冰雪之蒂:BAABLAAECn8hAAIIAAYIqRqCdABbAQAIAAYIqRqCdABbAQAAAA==.冰雪梦幻:BAAALAAECgYIBgAAAA==.冰雪森林:BAAALAAECgQIBgAAAA==.冰雪银环:BAAALAAECgMIAwAAAA==.',['凤凰']='凤凰于飞:BAAALAAECgYIBgAAAA==.',['划水']='划水小能手丶:BAACLAAFFH8KAAMPAAYI7QEEIgB0AAAPAAYI7QEEIgB0AAAJAAIIvQorQQBoAAAsAAQKfxUAAwkABwhqFKgnAHgBAAkABwhqFKgnAHgBAA8AAwhkA4yWAEkAAAAA.',['剑吼']='剑吼西风:BAABLAAECn8WAAMHAAgI/QCCEwEsAAAHAAgIZACCEwEsAAAQAAgI+ACAQQAcAAAAAA==.',['勉励']='勉励狮子:BAAALAADCgUIAwAAAA==.',['北溟']='北溟雉:BAAALAADCgcIBwAAAA==.',['北燕']='北燕灬安易:BAAALAADCgYIDAAAAA==.',['十字']='十字银月:BAAALAADCgMIAwAAAA==.',['南小']='南小鸟:BAABLAAFFH8IAAMHAAMIZhKpMACeAAAHAAMIZhKpMACeAAARAAMIoAQqJQBUAAAAAA==.',['叁零']='叁零萨满:BAAALAAFFAIIBAABLAAFFAgIMgASAGojAA==.',['叨叨']='叨叨:BAABLAAFFH8RAAIJAAMIZR6nIAC7AAAJAAMIZR6nIAC7AAAAAA==.',['听风']='听风:BAACLAAFFH8OAAIKAAgIJRHSCwApAgAKAAgIJRHSCwApAgAsAAQKfxcAAhMACAhdGoIUAIoBABMACAhdGoIUAIoBAAAA.',['呆呆']='呆呆兽:BAAALAAFFAIIAgAAAA==.',['呼呼']='呼呼兒:BAAALAAECggICAAAAA==.',['和发']='和发个就:BAAALAAECgIIAgAAAA==.',['咕德']='咕德猫柠:BAABLAAFFH8IAAMLAAYIrxVpFQCLAQALAAYIrxVpFQCLAQAMAAII5QsuIQCIAAAAAA==.',['咯弄']='咯弄泥:BAAALAAECgYICQAAAA==.',['哎呀']='哎呀妈:BAAALAADCggIDgAAAA==.',['唯德']='唯德彦牌炒面:BAAALAADCgEIAQAAAA==.',['唯生']='唯生素:BAAALAAFFAIIAgAAAA==.',['嘟嘟']='嘟嘟噜:BAAALAAECggIDwAAAA==.',['回锅']='回锅的蛋蛋:BAABLAAFFH8MAAICAAIIVhvScQBPAAACAAIIVhvScQBPAAAAAA==.',['团一']='团一个:BAAALAAECgUIBQAAAA==.',['圣光']='圣光至上:BAAALAADCgYIBwAAAA==.',['在这']='在这狂混:BAABLAAECn8UAAIEAAYIJiTqOgB0AgAEAAYIJiTqOgB0AgAAAA==.',['坐忘']='坐忘道:BAAALAADCgQIBAAAAA==.',['埃辛']='埃辛诺斯瞎扯:BAAALAAECgcIEwAAAA==.',['夏茉']='夏茉:BAAALAADCgcIBwAAAA==.',['夜一']='夜一:BAABLAAFFH8YAAIUAAYI6xqXIQCVAQAUAAYI6xqXIQCVAQAAAA==.',['大力']='大力的一箭哟:BAAALAAECgYIBgAAAA==.',['大梦']='大梦一场:BAAALAAECgMIBQAAAA==.',['天棒']='天棒坤哥:BAAALAAECggICAAAAA==.',['天青']='天青色瞪眼鱼:BAABLAAFFH8IAAIFAAYIKgNlNgDOAAAFAAYIKgNlNgDOAAAAAA==.',['奇亚']='奇亚娜:BAABLAAFFH8GAAIEAAYICQ5/JwBVAQAEAAYICQ5/JwBVAQAAAA==.',['孤云']='孤云出岫:BAAALAADCgEIAQAAAA==.',['宇宙']='宇宙嘤嘤怪:BAABLAAFFH8gAAIIAAUIyBojQwA8AQAIAAUIyBojQwA8AQAAAA==.',['守护']='守护者大牙:BAAALAADCgYIBgAAAA==.',['密切']='密切联系群众:BAAALAAECgcIEgAAAA==.',['小中']='小中子:BAAALAADCggICQAAAA==.',['小小']='小小影月:BAAALAADCgEIAQAAAA==.',['小肥']='小肥爱嘉丽:BAAALAAECgYIDgAAAA==.',['小血']='小血恶魔:BAABLAAECn8XAAMIAAYIBRn/qgCcAQAIAAYIBRn/qgCcAQAVAAEImQpcyQAmAAAAAA==.',['小錘']='小錘錘拳你胸:BAACLAAFFH8rAAIFAAYIjx3BDgDOAQAFAAYIjx3BDgDOAQAsAAQKfxcAAgUABgg0InRYADwCAAUABgg0InRYADwCAAAA.',['山寨']='山寨之王:BAAALAAECgMIAwAAAA==.',['徐一']='徐一枫:BAAALAADCgUIBgAAAA==.',['恶魔']='恶魔挽歌:BAAALAAFFAIIBAAAAA==.',['悻虞']='悻虞悻愿:BAAALAAECgYIBgAAAA==.',['慌慌']='慌慌张张:BAAALAADCgUIBQAAAA==.',['打我']='打我正七头:BAAALAAECgMIAwAAAA==.',['接化']='接化发:BAAALAADCgIIAgAAAA==.',['推拉']='推拉蹲:BAABLAAFFH8FAAIHAAIIwgueVgA/AAAHAAIIwgueVgA/AAAAAA==.',['提百']='提百万:BAAALAAFFAYIAgAAAA==.',['摩诃']='摩诃大势至:BAABLAAFFH8bAAIHAAgIBSDNAwCwAgAHAAgIBSDNAwCwAgAAAA==.',['斯巴']='斯巴达:BAABLAAFFH8SAAMHAAgIXxe+BgBZAgAHAAgI9xS+BgBZAgARAAYIPxPfEABEAQAAAA==.',['旺德']='旺德发:BAAALAAECgYIDAAAAA==.',['星辰']='星辰之陨:BAAALAAFFAIIAgAAAA==.',['暗影']='暗影风尘:BAAALAAECgUIBgAAAA==.',['月未']='月未眠:BAAALAAECggICAAAAA==.',['月矢']='月矢:BAAALAADCgEIAQAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8IAAMLAAgIsw/XEQCwAQALAAcIaw/XEQCwAQAMAAEIAQckLQBKAAAAAA==.',['有种']='有种回归:BAAALAAFFAIIAgAAAA==.',['未燎']='未燎丶:BAAALAADCgcICwAAAA==.',['杀手']='杀手十三:BAAALAADCgQIBAAAAA==.',['李含']='李含笑:BAAALAADCgQIBAAAAA==.',['极道']='极道乐师:BAACLAAFFH8XAAICAAYINA0xOABbAQACAAYINA0xOABbAQAsAAQKfx8AAgIACAgeHVM+AIUCAAIACAgeHVM+AIUCAAAA.',['枭妖']='枭妖:BAAALAAFFAIIAgAAAA==.',['桐喵']='桐喵喵:BAAALAAECggIAQAAAA==.',['桐言']='桐言:BAAALAAFFAIIAgAAAA==.',['梅根']='梅根弗克斯:BAAALAAFFAIIAgAAAA==.',['梦回']='梦回吹角连营:BAACLAAFFH8IAAIWAAMI1xLwDABqAAAWAAMI1xLwDABqAAAsAAQKfx0AAxYABwibFkMMAI0BABYABwibFkMMAI0BAAQAAgi3C244AWwAAAAA.',['橙子']='橙子皮:BAAALAAFFAIIAgAAAA==.',['歌海']='歌海娜:BAAALAADCggICAAAAA==.',['正经']='正经人毛海峰:BAAALAAECgIIAgAAAA==.',['残剑']='残剑饮血:BAAALAAECgIIAgAAAA==.',['残酷']='残酷一丁:BAAALAAECgYIBgAAAA==.残酷一渣:BAAALAAECgYIBgAAAA==.',['毛海']='毛海峰:BAAALAADCgMIAwAAAA==.',['永安']='永安丶卿酒酒:BAAALAAECgIIAgAAAA==.永安丶夜游神:BAAALAAECgEIAQAAAA==.',['沈菁']='沈菁冰:BAAALAADCgYIBgAAAA==.',['泰籣']='泰籣徳灬忧伤:BAAALAAECgYIBgAAAA==.',['泽哈']='泽哈特:BAAALAADCgcIBwAAAA==.',['流氓']='流氓医生:BAAALAAFFAIIAgAAAA==.',['浅浅']='浅浅清茉:BAAALAAECgYIBgAAAA==.',['淑芊']='淑芊芊:BAAALAADCgEIAQAAAA==.',['清风']='清风明月:BAAALAADCgIIAgAAAA==.',['源氏']='源氏天下:BAAALAAECgQIBAAAAA==.',['滑溜']='滑溜的橘子:BAABLAAFFH8IAAIHAAIIyxSyRABPAAAHAAIIyxSyRABPAAAAAA==.',['滚滚']='滚滚的橙子:BAAALAAECggICgABLAAFFAgIBAAXAAAAAA==.',['潇洒']='潇洒拉面哥:BAAALAADCgYIBgAAAA==.',['炼狱']='炼狱杏寿郎:BAAALAAECgMIAwAAAA==.',['烈炎']='烈炎飞龙:BAAALAADCgEIAQAAAA==.',['烟雨']='烟雨楼台:BAAALAAECgYIBgAAAA==.',['焚涙']='焚涙灬樊华:BAAALAAFFAIIBAAAAA==.',['熊猫']='熊猫人谜雾:BAAALAAECgYICAAAAA==.',['燃烧']='燃烧嘚點卡:BAAALAAECgYIDAAAAA==.',['爱好']='爱好女:BAAALAAECgEIAQAAAA==.',['爱莉']='爱莉希雅:BAAALAAECgMIBgAAAA==.',['牛九']='牛九:BAAALAADCgYIBgAAAA==.',['牛奶']='牛奶吐司:BAAALAADCgUIBQAAAA==.',['狂徒']='狂徒丷:BAAALAADCggICAAAAA==.',['独步']='独步森林:BAAALAAECgUIBwAAAA==.',['猛卡']='猛卡丘:BAAALAAECgYIBgAAAA==.',['猛的']='猛的不得了:BAAALAAFFAIIAgAAAA==.',['猫猫']='猫猫人:BAAALAAECgcIEwAAAA==.',['猾鎏']='猾鎏鍀橘孑:BAAALAAFFAIIBAAAAA==.',['甄棋']='甄棋行:BAAALAAECgYIBgAAAA==.',['疾如']='疾如风:BAAALAAECgYIDAAAAA==.',['白歌']='白歌笑:BAABLAAFFH8HAAIYAAIIXx6CNQCWAAAYAAIIXx6CNQCWAAAAAA==.',['相逢']='相逢在巅峰:BAAALAAECgUIBQAAAA==.',['石烈']='石烈:BAAALAAECgYIDQAAAA==.',['破笑']='破笑灭:BAAALAAECgYIBgAAAA==.',['神侠']='神侠:BAAALAAECgYIBgAAAA==.',['神女']='神女归来:BAAALAAECgMIAwAAAA==.',['离别']='离别后的春天:BAAALAAECggIBAAAAA==.',['秋意']='秋意谣:BAAALAADCgYIBgAAAA==.',['箭落']='箭落惊鸿:BAAALAAECgUIBQAAAA==.',['糖粒']='糖粒粒:BAAALAAECgYIDAAAAA==.',['紧握']='紧握大锤:BAABLAAFFH8MAAIFAAMIUAoWSQB1AAAFAAMIUAoWSQB1AAAAAA==.',['紫堂']='紫堂堂:BAAALAADCgEIAQAAAA==.',['绯云']='绯云:BAAALAADCgIIAgAAAA==.',['缺曰']='缺曰:BAAALAAFFAIIAwAAAA==.',['罗伯']='罗伯欧猪丽叶:BAAALAAECgMIAwAAAA==.',['義母']='義母:BAAALAAECgMIAwAAAA==.',['耶耶']='耶耶很忙:BAAALAAFFAIIAgAAAA==.',['联盟']='联盟最辣鸡:BAAALAAECgYICAAAAA==.联盟炒股佬:BAAALAAECgYIDgAAAA==.',['肉丝']='肉丝:BAAALAAFFAIIBAAAAA==.',['肝霸']='肝霸帝:BAAALAAECgYIDAAAAA==.',['胖胖']='胖胖龙:BAACLAAFFH8bAAMFAAgIDR5hAgCVAgAFAAgIDR5hAgCVAgAZAAYIAxetDgCbAQAsAAQKfxwAAgUACAhfILlCAHQCAAUACAhfILlCAHQCAAAA.胖胖龙一:BAACLAAFFH8ZAAIIAAgI1xgaCQBPAgAIAAgI1xgaCQBPAgAsAAQKfxwAAggACAhgIYQaAPICAAgACAhgIYQaAPICAAAA.',['自然']='自然法則:BAAALAADCgMIAwAAAA==.',['自由']='自由变形:BAAALAAECgIIAgAAAA==.',['臭弟']='臭弟弟:BAAALAAECgYIBgAAAA==.',['艾尔']='艾尔达:BAAALAAECgYIDAAAAA==.',['艾比']='艾比斯:BAAALAAFFAIIAwAAAA==.',['芦苇']='芦苇:BAAALAADCgYIBgAAAA==.',['莫白']='莫白丨僧:BAAALAADCgcIBwAAAA==.莫白丨术:BAAALAADCggICAAAAA==.',['蓝色']='蓝色文化生:BAACLAAFFH8rAAMaAAYIhRXVFwB+AQAaAAYIhRXVFwB+AQAYAAQIywkaPACzAAAsAAQKfxcAAxoABgjGH1EfALQBABoABgjGH1EfALQBABgAAwjKAts1AUoAAAAA.',['蔡蔡']='蔡蔡的戴戴:BAAALAADCgQIBgAAAA==.',['蕾欧']='蕾欧娜:BAAALAADCgUIBQAAAA==.',['藏锋']='藏锋寻时:BAAALAAECggIDgAAAA==.',['虚妄']='虚妄之诺:BAAALAADCggICAAAAA==.',['血之']='血之欢愉:BAAALAAFFAIIAgAAAA==.',['血雨']='血雨小飞:BAAALAAECgYIBgAAAA==.',['西蜀']='西蜀一点红:BAAALAAFFAIIAgAAAA==.西蜀红尘飘:BAAALAAECgYIEAAAAA==.',['诸神']='诸神之黑:BAABLAAFFH8GAAIHAAQIRBBoOQCNAAAHAAQIRBBoOQCNAAAAAA==.',['谢谢']='谢谢特:BAAALAAECggICAAAAA==.',['贫僧']='贫僧不厚道:BAAALAAECgYIBgAAAA==.',['超级']='超级玛丽奥丶:BAAALAAFFAIIAgAAAA==.',['足下']='足下生风:BAACLAAFFH8yAAMSAAgIaiPRAAD4AgASAAgIaiPRAAD4AgAbAAEIqwMPGwAyAAAsAAQKfx8AAhIACAh9JRIEACYDABIACAh9JRIEACYDAAAA.',['跟我']='跟我走吧:BAAALAAECgcIEQAAAA==.',['蹄子']='蹄子太大:BAAALAAECgIIAgAAAA==.',['蹦极']='蹦极用猪试跳:BAAALAAECgUIBQAAAA==.',['轩辕']='轩辕之情:BAAALAAECgYICAAAAA==.轩辕之战:BAAALAAECgEIAQAAAA==.轩辕之爱:BAAALAAECgYICgAAAA==.轩辕猎手:BAAALAAECgYIDAAAAA==.',['轻尘']='轻尘:BAAALAADCgEIAQAAAA==.',['轻解']='轻解罗裳:BAAALAAECgEIAQAAAA==.',['过拉']='过拉丝噢:BAAALAAECgcIDwAAAA==.',['还是']='还是你缺德:BAAALAAECgcIBgAAAA==.',['这个']='这个我不行:BAAALAAECgMIAgAAAA==.',['进击']='进击的狗子:BAAALAAECgYIAwAAAA==.',['逝殇']='逝殇易云:BAAALAAECgUIBQAAAA==.',['達拉']='達拉然的光輝:BAAALAAFFAIIBAAAAA==.',['那年']='那年:BAAALAADCgUIBQAAAA==.',['部落']='部落大漂亮:BAABLAAECn8WAAMVAAYIoRBbeADzAAAIAAYI/A7PtwD5AAAVAAUIyQxbeADzAAAAAA==.',['鑫鑫']='鑫鑫金:BAACLAAFFH8NAAMUAAMIAge5UwBfAAAUAAMIAge5UwBfAAAcAAEI4AEDMgAyAAAsAAQKfxsAAxQACAj8EJg2AG8BABQACAj8EJg2AG8BABwABAgWChxsAMYAAAAA.',['钢琴']='钢琴里的猫:BAABLAAFFH8NAAIPAAgIVx3JAgB/AgAPAAgIVx3JAgB/AgAAAA==.',['阿克']='阿克孟德:BAAALAADCgEIAQAAAA==.',['阿尔']='阿尔忒弥诗:BAAALAADCgEIAQAAAA==.',['阿星']='阿星:BAAALAADCgMIAwAAAA==.',['隻狼']='隻狼:BAAALAAECgEIAQAAAA==.',['雨风']='雨风翼:BAAALAAECgIIAgAAAA==.',['雷炎']='雷炎之星:BAABLAAECn8YAAIHAAYIJBfBQABXAQAHAAYIJBfBQABXAQAAAA==.',['雷霆']='雷霆丶焰掌:BAAALAADCggICgAAAA==.',['霜冷']='霜冷长河丶:BAAALAAECgYIBgAAAA==.',['霹雳']='霹雳娇猛:BAACLAAFFH8KAAIdAAIIDw9WFACLAAAdAAIIDw9WFACLAAAsAAQKf0QAAx0ACAgTIR0HAMgCAB0ACAgTIR0HAMgCAB4ABghYEYg4AG8BAAAA.',['青龙']='青龙没眯眯:BAAALAADCgcIBwAAAA==.',['颜面']='颜面骑惩:BAAALAAFFAIIBAAAAA==.',['风蚀']='风蚀之弦:BAAALAAECgMIAwAAAA==.',['飞云']='飞云:BAABLAAFFH8JAAIIAAYIsAzySAAoAQAIAAYIsAzySAAoAQAAAA==.',['马踏']='马踏飞燕:BAAALAAECgYIBgAAAA==.',['马马']='马马呼呼:BAAALAADCgIIAgAAAA==.',['魂萦']='魂萦:BAAALAAFFAIIAgAAAA==.',['魔神']='魔神复诵:BAAALAAECgMIAwAAAA==.',['鲨鱼']='鲨鱼辣椒丶:BAAALAAECgYIDAAAAA==.',['黑色']='黑色幽默:BAABLAAECn8cAAMIAAYIkRzwYQB+AQAIAAYIkRzwYQB+AQAVAAII1AokqwBaAAAAAA==.',['黑蚀']='黑蚀丿乱:BAABLAAFFH8IAAIIAAMIkx2tIQD9AAAIAAMIkx2tIQD9AAAAAA==.',['齐天']='齐天大圣:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end