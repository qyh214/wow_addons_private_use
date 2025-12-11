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
 local lookup = {'DemonHunter-Vengeance','Evoker-Preservation','Evoker-Devastation','DeathKnight-Frost','Shaman-Elemental','Shaman-Restoration','Paladin-Retribution','Priest-Shadow','Priest-Holy','Monk-Brewmaster','Warrior-Protection','Mage-Arcane','Rogue-Assassination','Hunter-BeastMastery','Hunter-Survival','Unknown-Unknown','Druid-Balance','Druid-Restoration','Warrior-Fury','Warlock-Demonology','Paladin-Protection','Hunter-Marksmanship','DemonHunter-Havoc','Paladin-Holy','Druid-Feral','Monk-Mistweaver','Rogue-Subtlety','Mage-Frost','Warlock-Affliction','Warlock-Destruction','DeathKnight-Blood','Mage-Fire','Monk-Windwalker','Evoker-Augmentation',}; local provider = {region='CN',realm='拉格纳罗斯',name='CN',type='weekly',zone=44,date='2025-12-07',data={Aa='Aayb:BAAALAAFFAIIAgAAAA==.',Al='Alpha:BAAALAAFFAIIAgAAAA==.Aluckyc:BAAALAAECgIIAgAAAA==.',Ao='Aotu:BAAALAAECgQIBAAAAA==.',Ar='Arrebol:BAAALAAECgcIEgAAAA==.',As='Asako:BAAALAAECgYIDAAAAA==.',Bl='Bluedh:BAABLAAFFH8IAAIBAAII5Q1xFgBbAAABAAII5Q1xFgBbAAAAAA==.Bluemag:BAAALAAECgUIBQAAAA==.',Bu='Bukaded:BAAALAAFFAMIAwAAAA==.',Cl='Cl:BAABLAAFFH8KAAMCAAIIYg0dGwBoAAACAAIIYg0dGwBoAAADAAEITQQvJQA5AAAAAA==.Clean:BAAALAAECggICAAAAA==.',Cy='Cyrus:BAAALAAECgEIAQAAAA==.',Da='Davincii:BAAALAAFFAIIBAAAAA==.',Dd='Ddkk:BAABLAAFFH8HAAIEAAIIOR5/OgC9AAAEAAIIOR5/OgC9AAAAAA==.',Fo='Foxdie:BAACLAAFFH8qAAMFAAYIIiXOCgABAgAFAAYIIiXOCgABAgAGAAEIlRLjeQA4AAAsAAQKfzEAAwUACAgdJnYCAH8DAAUACAgdJnYCAH8DAAYAAQhvGoA0AUwAAAAA.',Is='Isml:BAABLAAFFH8HAAIGAAIINxANUABrAAAGAAIINxANUABrAAAAAA==.',Ka='Karenkim:BAABLAAFFH8JAAIHAAUI2xPtKgAtAQAHAAUI2xPtKgAtAQAAAA==.Katarina:BAAALAAECgMIBQAAAA==.Kayla:BAAALAAECgEIAQAAAA==.',Ke='Kelsey:BAABLAAFFH8LAAMIAAUI6A1NGAD8AAAIAAQI4wdNGAD8AAAJAAIIxQp4NwCEAAAAAA==.',Kn='Knoye:BAAALAAECgYICgAAAA==.',Ko='Kohza:BAABLAAFFH8LAAIKAAYIuiC4BwDWAQAKAAYIuiC4BwDWAQABLAAFFAcILQALAPslAA==.Kongfy:BAAALAAECgYICgAAAA==.',Lu='Luangrte:BAAALAAFFAIIAgAAAA==.Luminara:BAAALAADCggICAAAAA==.',Ma='Maggie:BAAALAAECgYICwAAAA==.Magicmar:BAAALAAECgUIAwABLAAFFAgIGAAMAAomAA==.Mar:BAAALAAECgMIBAAAAA==.',Me='Me:BAAALAAECgIIAgAAAA==.',Mi='Millia:BAAALAADCgQIBAAAAA==.',Mo='Mobius:BAABLAAFFH8iAAINAAYIDh9mBQDXAQANAAYIDh9mBQDXAQABLAAFFAYIOgAIAE8mAA==.Morphy:BAAALAAECgIIAgAAAA==.',Ne='Newnew:BAAALAADCgcIBwAAAA==.',Pl='Playerpysbtp:BAAALAADCgMIAwAAAA==.',Ra='Ramie:BAAALAAECgYICgAAAA==.',Re='Realman:BAABLAAECn8VAAMOAAYIyAmu3ADGAAAOAAYIyAmu3ADGAAAPAAMInQSUEgAuAAAAAA==.',Sa='Saill:BAAALAAFFAIIAgAAAA==.',Sd='Sdf:BAAALAAECgQIBAAAAA==.',Se='Sebasmin:BAAALAADCggICwAAAA==.Serein:BAABLAAFFH8FAAIGAAMI2R09LQACAQAGAAMI2R09LQACAQAAAA==.',Sk='Skada:BAAALAAECgMIAwABLAAECgYIEAAQAAAAAA==.',Te='Telamon:BAAALAAFFAMIAQAAAA==.',Wa='Wahaha:BAABLAAFFH8GAAIHAAIIuAvicAA+AAAHAAIIuAvicAA+AAAAAA==.',Wh='Whatcolor:BAACLAAFFH8fAAIRAAUI2iGmEABpAQARAAUI2iGmEABpAQAsAAQKfzQAAxEACAi0JKsFAFQDABEACAi0JKsFAFQDABIACAiwHckWAKgCAAEsAAUUBggqAAUAIiUA.',Xx='Xxml:BAAALAAECgUIBwAAAA==.',Xy='Xy:BAAALAAECgQIBAAAAA==.',Yu='Yume:BAAALAAECgYIBgAAAA==.Yuxi:BAABLAAFFH8SAAIEAAQIAgkUYgCLAAAEAAQIAgkUYgCLAAAAAA==.',Zh='Zhslhj:BAABLAAFFH8FAAITAAIIIxhrLACjAAATAAIIIxhrLACjAAAAAA==.',Zi='Ziyun:BAACLAAFFH8GAAITAAIIWRTMTQBGAAATAAIIWRTMTQBGAAAsAAQKfx0AAhMABggsGfU3AHoBABMABggsGfU3AHoBAAEsAAUUBAgSAAQAAgkA.',['一念']='一念天堂:BAAALAAECgIIAgAAAA==.',['一星']='一星牛蛙:BAAALAADCgMIAwAAAA==.',['七月']='七月稻:BAABLAAFFH8HAAIMAAMIIw1ARwCHAAAMAAMIIw1ARwCHAAAAAA==.',['三丶']='三丶月丶八:BAAALAAECgQIBAAAAA==.',['不会']='不会加耐:BAAALAAECgMIBQAAAA==.',['不吃']='不吃辣椒丶:BAABLAAFFH8KAAIUAAYIiwZyBAAhAQAUAAYIiwZyBAAhAQAAAA==.',['不死']='不死神牛:BAAALAAECgQIBAAAAA==.',['东方']='东方玉:BAAALAADCgEIAQAAAA==.',['丶柳']='丶柳千鲤丶:BAABLAAECn8fAAMRAAgIghnpLwABAgARAAgIghnpLwABAgASAAUIixNUdwAzAQAAAA==.',['丷不']='丷不要圣光:BAABLAAFFH8aAAMHAAYIDh1CBQAVAgAHAAYIDh1CBQAVAgAVAAMIqQ/uCgC/AAAAAA==.',['亘古']='亘古:BAAALAAECggICAAAAA==.',['人心']='人心薄凉丶伤:BAABLAAFFH8GAAISAAIINhDJOgCEAAASAAIINhDJOgCEAAAAAA==.',['仇小']='仇小痴:BAAALAAECgYIBgAAAA==.',['今天']='今天一定早睡:BAAALAADCggICAAAAA==.',['令狐']='令狐冲:BAABLAAFFH8OAAIFAAYIXxfSFwCBAQAFAAYIXxfSFwCBAQAAAA==.',['任天']='任天堂乌托邦:BAAALAADCgQIBAAAAA==.',['伊利']='伊利蛋怒风:BAAALAAECgIIAwAAAA==.',['优雅']='优雅:BAAALAAECgYICwAAAA==.',['你丶']='你丶瞅啥:BAAALAAECgUIBgAAAA==.',['你懂']='你懂我意思吗:BAAALAAECgMIBAAAAA==.',['你无']='你无敌了:BAAALAAECgUIBQAAAA==.',['佩罗']='佩罗罗奇丶:BAAALAAECgIIAgAAAA==.',['俊俊']='俊俊:BAAALAAECgcIDgAAAA==.',['俊哥']='俊哥儿:BAAALAAECgMIAwAAAA==.',['做好']='做好事要留名:BAABLAAECn8dAAIHAAYIqhscjADXAQAHAAYIqhscjADXAQAAAA==.',['光羽']='光羽:BAABLAAFFH8kAAIWAAYI4Ro2BQCFAQAWAAYI4Ro2BQCFAQAAAA==.',['八哥']='八哥你真霸气:BAAALAAECggICAAAAA==.',['八奈']='八奈見杏菜:BAAALAAFFAMIAwAAAA==.',['再加']='再加一碗饭:BAAALAAECggIEAAAAA==.',['冒险']='冒险者:BAAALAAECgYICQAAAA==.',['冥界']='冥界狂人:BAAALAADCgQIBAAAAA==.',['冰漓']='冰漓:BAAALAAECgcIBwAAAA==.',['冰火']='冰火牧羊女:BAAALAAFFAEIAQAAAA==.',['冰霜']='冰霜之镰:BAAALAAECgYICAAAAA==.',['冷灬']='冷灬月:BAABLAAFFH8TAAIHAAYIoRQNHACAAQAHAAYIoRQNHACAAQAAAA==.',['出了']='出了名的能扛:BAAALAAECgYIDAABLAAFFAgICgAXAJ0EAA==.',['刀十']='刀十三:BAACLAAFFH88AAIYAAgIrCKOAAA7AwAYAAgIrCKOAAA7AwAsAAQKfzUAAhgACAiyJQ8BAGMDABgACAiyJQ8BAGMDAAAA.刀十五:BAABLAAFFH8LAAISAAUIcBC1IAAcAQASAAUIcBC1IAAcAQABLAAFFAgIPAAYAKwiAA==.',['列那']='列那狐:BAAALAADCgIIAgAAAA==.',['刺客']='刺客伍六七:BAAALAADCgUIBQAAAA==.',['剑仙']='剑仙:BAAALAAECgYIBgAAAA==.',['加勒']='加勒比丶优子:BAABLAAFFH8FAAIGAAII1AeocABKAAAGAAII1AeocABKAAAAAA==.',['动物']='动物朋友:BAABLAAFFH8GAAQRAAII6w57HwCNAAARAAII6w57HwCNAAASAAIIIwy8OQBmAAAZAAEICguHEwBGAAAAAA==.',['十丶']='十丶三:BAABLAAECn8UAAIaAAcIiwr+MAAeAQAaAAcIiwr+MAAeAQAAAA==.',['千岛']='千岛之光:BAABLAAFFH8KAAIHAAYIExgEGACWAQAHAAYIExgEGACWAQAAAA==.千岛斌哥:BAAALAAFFAIIAwAAAA==.',['卡璞']='卡璞猩猩:BAAALAAECgUIBQAAAA==.',['卤煮']='卤煮:BAABLAAFFH8HAAIRAAMInQxeEwDNAAARAAMInQxeEwDNAAAAAA==.',['卿本']='卿本佳人:BAAALAAECgIIAQAAAA==.',['反方']='反方向的约定:BAAALAAECgEIAQAAAA==.',['口口']='口口线:BAABLAAFFH8QAAIHAAUICA3lLwALAQAHAAUICA3lLwALAQAAAA==.',['可丶']='可丶莉:BAAALAADCgMIAwAAAA==.',['可琳']='可琳酱:BAAALAAECgQIBAAAAA==.',['叶落']='叶落深秋:BAACLAAFFH8lAAMNAAYI8hnQBgC1AQANAAYI8hnQBgC1AQAbAAEI6wW6HwA2AAAsAAQKfzAAAw0ACAhqIyUEADkDAA0ACAhqIyUEADkDABsAAggoFxNCAIsAAAEsAAUUBwghAA0AER8A.',['吉利']='吉利豆:BAAALAAECgQIBQAAAA==.',['向前']='向前進:BAAALAADCgMIAwAAAA==.',['君子']='君子行义:BAAALAADCgEIAQAAAA==.',['呼噜']='呼噜呼噜:BAAALAAECgMIAwAAAA==.',['咕咕']='咕咕吉:BAAALAAFFAMIAwAAAA==.',['哀木']='哀木涕小歪:BAAALAAECgIIAgAAAA==.',['哈利']='哈利六呀:BAACLAAFFH8PAAIMAAIIqxDvXAA/AAAMAAIIqxDvXAA/AAAsAAQKfy4AAgwABwgdHFMYAOYBAAwABwgdHFMYAOYBAAAA.',['唐太']='唐太宗:BAAALAADCgEIAQAAAA==.',['啵啰']='啵啰啵啰咪:BAABLAAECn8UAAMcAAYIbhWyQgBlAQAMAAYIxxLujwBsAQAcAAYItRSyQgBlAQAAAA==.',['喜喜']='喜喜不喜喜:BAAALAADCgYIBwAAAA==.',['喵呜']='喵呜不呜:BAABLAAFFH8GAAITAAYI+QKVMwCqAAATAAYI+QKVMwCqAAAAAA==.',['喵喵']='喵喵也疯狂:BAAALAADCgcIBwAAAA==.',['嘉士']='嘉士伯:BAAALAADCgEIAQAAAA==.',['嘎尔']='嘎尔萨斯:BAAALAAECgYIBgAAAA==.',['国宝']='国宝小胸猫:BAABLAAFFH8GAAIGAAIIrRzLQQCiAAAGAAIIrRzLQQCiAAAAAA==.',['圣光']='圣光在忽悠你:BAAALAADCgYIBgAAAA==.',['圣甲']='圣甲虫:BAAALAAECgYIBwAAAA==.',['在你']='在你耳旁低语:BAAALAAECgMIAwAAAA==.',['地狱']='地狱衰仔蕉:BAAALAAECgYIEwAAAA==.',['均均']='均均:BAABLAAFFH8HAAIGAAYIthFVHwBkAQAGAAYIthFVHwBkAQAAAA==.',['坚果']='坚果:BAACLAAFFH8lAAITAAYI0yT8CAACAgATAAYI0yT8CAACAgAsAAQKfy8AAxMACAiHJbYHAFgDABMACAiHJbYHAFgDAAsAAgizF6N/AIcAAAAA.',['坦院']='坦院一神迹:BAAALAAFFAIIAgAAAA==.',['堂西']='堂西灬尐五:BAAALAAECgYICQAAAA==.',['壮烈']='壮烈成仁:BAAALAAECgYIBgAAAA==.',['夜雨']='夜雨戏澜珊:BAAALAAECgYIBgAAAA==.',['夜鸢']='夜鸢丶:BAABLAAFFH8JAAIHAAMILBvbOgCwAAAHAAMILBvbOgCwAAAAAA==.',['大卤']='大卤蛋过马路:BAABLAAFFH8GAAIWAAYIpxfsAwD6AQAWAAYIpxfsAwD6AQAAAA==.',['大地']='大地熊王:BAAALAAECgYICAAAAA==.',['大头']='大头大头:BAAALAAECgUIBQAAAA==.',['大橘']='大橘有点重:BAACLAAFFH8TAAIGAAYIYRWCGACaAQAGAAYIYRWCGACaAQAsAAQKfxUAAgYACAiTF2dEABECAAYACAiTF2dEABECAAAA.',['大重']='大重九:BAAALAAFFAIIBAAAAA==.',['天堂']='天堂制造:BAAALAAECgMIAwAAAA==.',['天琴']='天琴华樟:BAACLAAFFH8SAAIGAAQIvxWULgD6AAAGAAQIvxWULgD6AAAsAAQKfxcAAgYACAj5FIFiAMMBAAYACAj5FIFiAMMBAAAA.',['天罡']='天罡逆转:BAABLAAFFH8GAAIGAAIIhx4aKgCwAAAGAAIIhx4aKgCwAAAAAA==.',['太难']='太难德:BAAALAAECgEIAQAAAA==.',['夺命']='夺命奥利奥:BAAALAAECgUIBQAAAA==.',['奔州']='奔州太狼:BAAALAAECgUIBQAAAA==.',['奶油']='奶油饼干:BAAALAADCgYIBgAAAA==.',['奶茶']='奶茶:BAAALAAECgMIAwAAAA==.',['奶酪']='奶酪夹心大福:BAAALAAECgEIAQAAAA==.',['妈妈']='妈妈:BAABLAAFFH8gAAMJAAgIIR9IAgDhAgAJAAgIIR9IAgDhAgAIAAIISBJhHQCkAAAAAA==.',['娜呗']='娜呗:BAAALAAECgEIAQAAAA==.',['娜夏']='娜夏:BAAALAADCgcIBwAAAA==.',['娜沫']='娜沫:BAAALAAFFAEIAQAAAA==.',['安丶']='安丶老丶六:BAAALAADCggICAAAAA==.',['家住']='家住雷霆涯:BAAALAAECgYIBwAAAA==.',['寂寞']='寂寞亮了:BAAALAAFFAQIAgAAAA==.',['寒江']='寒江印月:BAAALAAECgQIBAAAAA==.',['寒雪']='寒雪无忆:BAAALAAFFAQIBAAAAA==.',['小傻']='小傻妮:BAAALAAECgYIBgAAAA==.小傻帽:BAAALAAECggIBgAAAA==.',['小卡']='小卡:BAABLAAECn8gAAQdAAgIKyBNBwBYAgAdAAgIzhtNBwBYAgAeAAgI0BqpTQAJAgAUAAYI7hk3EwBIAQAAAA==.',['小妞']='小妞嘴一个:BAAALAAFFAIIAgAAAA==.',['小岛']='小岛斌哥:BAABLAAFFH8MAAIOAAYIIQtTRQA3AQAOAAYIIQtTRQA3AQAAAA==.',['小桃']='小桃:BAAALAAECgYIDAAAAA==.',['小江']='小江同学:BAAALAAFFAIIBAAAAA==.',['小癞']='小癞子丶:BAAALAAECgQIBAAAAA==.',['小突']='小突突:BAAALAAFFAIIBAAAAA==.',['小酒']='小酒一壶:BAAALAADCgEIAQAAAA==.',['尧十']='尧十一:BAAALAADCggICgAAAA==.',['山水']='山水:BAAALAAECgYIDQAAAA==.',['巾帼']='巾帼刺客:BAAALAADCgUIBQAAAA==.',['布赖']='布赖恩铁须:BAAALAADCggICAAAAA==.',['帅帅']='帅帅呆呆:BAAALAAECgUIBgAAAA==.',['帅气']='帅气绿毛:BAAALAAECgYIDQAAAA==.',['希娃']='希娃:BAAALAAECgEIAQAAAA==.',['带味']='带味的裤衩子:BAAALAAECgUICQAAAA==.',['年轻']='年轻就要对味:BAAALAADCggICAAAAA==.',['并非']='并非术神:BAACLAAFFH8LAAIeAAUIQhkXFAC9AQAeAAUIQhkXFAC9AQAsAAQKfyAABB4ACAipJecGAF8DAB4ACAipJecGAF8DAB0ABAjGHlYYAEcBABQAAgh/GYp/AHwAAAAA.',['幹枯']='幹枯大地丶風:BAACLAAFFH8aAAMFAAYIEAgyKwDpAAAFAAUIVAcyKwDpAAAGAAMI3Aw3XQBiAAAsAAQKfyMAAwUABwhgFHtUALsBAAUABwhgFHtUALsBAAYABwhnGbEsALQBAAAA.',['幻影']='幻影天翔:BAAALAAECggICQAAAA==.',['庚辰']='庚辰:BAAALAADCgMIAwAAAA==.',['彼界']='彼界花开:BAAALAAECgYIBgAAAA==.',['德拉']='德拉克洛瓦:BAAALAAFFAIIBAAAAA==.',['德比']='德比地:BAAALAAFFAYIAwAAAA==.',['心情']='心情不好:BAABLAAFFH8GAAIXAAYI1gLjPwCRAAAXAAYI1gLjPwCRAAAAAA==.',['忆莫']='忆莫寂:BAAALAADCgcIBwAAAA==.',['志田']='志田千阳:BAABLAAFFH8ZAAMeAAYIJQ8sLQBoAQAeAAYIQA4sLQBoAQAUAAEIfg/GKQBOAAAAAA==.',['念皆']='念皆星河:BAAALAAECgMIAwAAAA==.',['性感']='性感蕾丝妹:BAAALAADCgIIAgAAAA==.',['懂都']='懂都不懂:BAAALAAECggIBgAAAA==.',['戈德']='戈德米斯:BAAALAAECgYIBgAAAA==.',['我就']='我就是刀刀:BAAALAAECgMIBwAAAA==.',['我灬']='我灬不是劣人:BAAALAAFFAIIAwAAAA==.',['战刀']='战刀:BAABLAAFFH8QAAIfAAQI8QqJCAAKAQAfAAQI8QqJCAAKAQAAAA==.',['战神']='战神玛尔斯:BAAALAAECgYIBgAAAA==.',['戴斯']='戴斯:BAAALAADCgUIBQAAAA==.',['打死']='打死也不听:BAAALAADCgcIDQAAAA==.',['把弓']='把弓递给我:BAAALAAECgYIBgAAAA==.',['折桂']='折桂令丷:BAAALAAECgYIBwAAAA==.',['折跃']='折跃之翼:BAAALAAFFAIIAgAAAA==.',['拓野']='拓野逐霞:BAAALAAECggIDgAAAA==.',['搞乐']='搞乐子:BAACLAAFFH8TAAISAAUIMxXXGwBOAQASAAUIMxXXGwBOAQAsAAQKfxUAAhIACAhDGYolAFECABIACAhDGYolAFECAAAA.',['放逐']='放逐明:BAAALAADCgIIAgAAAA==.',['文若']='文若小庸之:BAABLAAFFH8MAAMEAAYILBMXMwBxAQAEAAYIABIXMwBxAQAfAAYI+gnUDgAZAQAAAA==.',['既定']='既定天命:BAABLAAFFH8UAAIbAAYIqRjxBgBdAQAbAAYIqRjxBgBdAQAAAA==.',['日落']='日落與星星:BAAALAAFFAIIBAAAAA==.',['昨天']='昨天的回忆:BAAALAAECgQIBAAAAA==.',['晨钟']='晨钟丶暮鸣:BAAALAAECgYIBwAAAA==.',['暗冰']='暗冰:BAACLAAFFH8IAAIEAAIIRQrvlQA8AAAEAAIIRQrvlQA8AAAsAAQKfxoAAwQABwgkF040AKgBAAQABwgkF040AKgBAB8AAgi9CE8tAE4AAAAA.',['暗夜']='暗夜流星:BAABLAAFFH8MAAIOAAIIEQwDoQA+AAAOAAIIEQwDoQA+AAAAAA==.',['暗灬']='暗灬暗:BAAALAAECgYIDgAAAA==.',['曦歌']='曦歌:BAAALAAECgMIBQAAAA==.',['有個']='有個騎士:BAABLAAFFH8IAAIHAAYIAxXoIQBgAQAHAAYIAxXoIQBgAQAAAA==.',['有火']='有火没有烟:BAAALAADCgUIBQAAAA==.',['朱张']='朱张正义:BAAALAADCgEIAQAAAA==.',['村口']='村口阿花:BAABLAAFFH8HAAITAAUIqBJgJwA3AQATAAUIqBJgJwA3AQAAAA==.村口阿花丶:BAABLAAFFH8QAAIEAAYIqRGzNABrAQAEAAYIqRGzNABrAQAAAA==.',['来点']='来点玛萨拉:BAACLAAFFH8IAAIGAAIIWRzMLgCkAAAGAAIIWRzMLgCkAAAsAAQKfxQAAgYACAhGD/KEAHYBAAYACAhGD/KEAHYBAAAA.',['桃桃']='桃桃小丸子:BAAALAADCgYIBgAAAA==.',['梁上']='梁上君子:BAAALAAECgcIBwAAAA==.',['梦倦']='梦倦还:BAACLAAFFH8bAAIZAAYI/xSpBAByAQAZAAYI/xSpBAByAQAsAAQKfxcAAhkABgg0JIgHAOABABkABgg0JIgHAOABAAAA.',['梦想']='梦想的初衷:BAAALAAFFAIIBAAAAA==.',['椰子']='椰子汁:BAACLAAFFH8IAAIMAAIIVgsuXgB/AAAMAAIIVgsuXgB/AAAsAAQKfx8AAwwABggdGWkpAHYBAAwABggdGWkpAHYBACAABAhhCuENAI0AAAAA.',['橙子']='橙子帆布鞋:BAAALAADCgQIBAAAAA==.',['欧神']='欧神降临:BAAALAAECgYICQAAAA==.',['武汉']='武汉川川:BAABLAAFFH8FAAIOAAUIWg7MUQALAQAOAAUIWg7MUQALAQAAAA==.',['残雨']='残雨千念:BAAALAAECggICgAAAA==.',['江浙']='江浙沪包邮:BAAALAADCgMIAwAAAA==.',['池边']='池边小草:BAAALAAECgMIAwAAAA==.',['沒沒']='沒沒:BAAALAAECgcIDQAAAA==.',['沙曼']='沙曼暗星之魂:BAAALAAECggICAABLAAFFAgIBwATAEIWAA==.沙曼暴风之语:BAAALAAECggICAABLAAFFAgIHgAEAKscAA==.',['沸腾']='沸腾的可乐:BAAALAAECgYIBgABLAAECgYICgAQAAAAAA==.沸腾的芬达:BAAALAAECgYICgAAAA==.',['法术']='法术暴师:BAABLAAFFH8FAAMcAAQIVxdoDACSAAAcAAMIyhloDACSAAAMAAIIpwiMSwBsAAAAAA==.',['泡泡']='泡泡茶壷丶:BAAALAADCgQIBAAAAA==.',['洛杉']='洛杉矶丶狐人:BAAALAAECgEIAQAAAA==.',['流亡']='流亡之魂:BAAALAAECgYIBgAAAA==.',['流光']='流光溢影:BAACLAAFFH8IAAMIAAIIQQRtJwByAAAIAAIIQQRtJwByAAAJAAIIBAFjRQBgAAAsAAQKfysAAwgACAhnFw4rACgCAAgABwiBGQ4rACgCAAkABwjDCzZrADkBAAAA.',['湮婲']='湮婲亂飘飘:BAAALAAECgIIAgAAAA==.',['漆黑']='漆黑圣典:BAAALAAECggICAAAAA==.',['灬是']='灬是德克啊灬:BAABLAAFFH8KAAIEAAIIZRbghgBDAAAEAAIIZRbghgBDAAAAAA==.',['灵鸢']='灵鸢丶:BAAALAAECgYIEwAAAA==.',['炼狱']='炼狱红茶:BAAALAAECgYICwAAAA==.',['烛娢']='烛娢露:BAAALAAECggICAAAAA==.',['烟雨']='烟雨缥缈:BAAALAADCggICAAAAA==.',['煖月']='煖月花魂:BAABLAAFFH8FAAIHAAQI+QcvRACKAAAHAAQI+QcvRACKAAAAAA==.',['熊有']='熊有熊德:BAAALAAFFAIIBAAAAA==.',['熬夜']='熬夜冠军:BAAALAAFFAIIAwAAAA==.',['牛嘿']='牛嘿:BAAALAAECgYIBgAAAA==.',['牛大']='牛大壮:BAAALAAECgYIBgAAAA==.',['牛气']='牛气的虎:BAAALAAECgYIBgABLAAECgYICgAQAAAAAA==.',['牛牛']='牛牛忽悠你:BAABLAAFFH8MAAMGAAYIXAaNTgCAAAAGAAQIKQONTgCAAAAFAAQIHwIZOQB4AAAAAA==.',['牧野']='牧野青空:BAAALAAECggICAABLAAFFAgIBgAYAOIhAA==.',['特兰']='特兰克斯:BAAALAAECgEIAQAAAA==.',['狂奔']='狂奔的牛牛:BAAALAAECgQIBAAAAA==.',['狂得']='狂得冒泡:BAAALAAECgYIBgAAAA==.',['狐狐']='狐狐狸狸:BAACLAAFFH8XAAIBAAUIBw+GCADcAAABAAUIBw+GCADcAAAsAAQKfxwAAwEABwgwD7UuAEYBAAEABwgvD7UuAEYBABcABwhfBqLdACoBAAAA.',['獠牙']='獠牙之猎:BAAALAADCgYIBgAAAA==.',['玉衡']='玉衡星刻晴:BAABLAAFFH8NAAIeAAYI7SBOBQBiAgAeAAYI7SBOBQBiAgAAAA==.',['王不']='王不留行:BAAALAAECgMIAwAAAA==.',['玲小']='玲小冰:BAAALAAECggICAAAAA==.',['甜小']='甜小歆:BAAALAAECgQIBAAAAA==.',['甜甜']='甜甜糯米:BAAALAADCggICAAAAA==.',['电光']='电光毒龙钻:BAAALAAECggICAAAAA==.',['白切']='白切鸡:BAAALAAFFAQIBAAAAA==.',['白发']='白发魔牛:BAABLAAFFH8JAAIGAAIITQcCYgBeAAAGAAIITQcCYgBeAAAAAA==.',['白巧']='白巧克力薄脆:BAAALAAECggIEgAAAA==.',['百斩']='百斩乂:BAAALAAECgcIDQAAAA==.',['皮卡']='皮卡丘丶:BAAALAAECggIEAAAAA==.',['盐焗']='盐焗鸡:BAAALAAECgEIAQAAAA==.',['瞬缘']='瞬缘雨:BAABLAAFFH8FAAIHAAII8BUMOgCiAAAHAAII8BUMOgCiAAAAAA==.',['知北']='知北丶:BAAALAAECgQIBAAAAA==.',['祝踏']='祝踏岚:BAAALAAECgYICgAAAA==.',['神木']='神木與瞳:BAAALAAFFAMIAwAAAA==.',['神迹']='神迹丶怒风:BAAALAAFFAIIAgAAAA==.',['祺狠']='祺狠子:BAAALAAECgYIDAAAAA==.',['祺猛']='祺猛懵:BAAALAAECgEIAQAAAA==.祺猛法神:BAAALAAECgEIAQAAAA==.',['秋水']='秋水:BAAALAADCgIIAgAAAA==.',['秋物']='秋物叙事曲:BAABLAAFFH8RAAIFAAMI7hNUNQCKAAAFAAMI7hNUNQCKAAAAAA==.',['秩序']='秩序始源:BAACLAAFFH8UAAMKAAUIBB9hEQA2AQAKAAUIBB9hEQA2AQAhAAIITgMYGABnAAAsAAQKfy4AAwoABgjqIrIQAFACAAoABgjqIrIQAFACACEABggmDjQ+AD0BAAEsAAUUCAg8ACEAnBUA.',['突然']='突然好想你:BAAALAAECggICAABLAAFFAYIEQAIAGYWAA==.',['等怒']='等怒:BAABLAAFFH8iAAIHAAYIDiCZDADgAQAHAAYIDiCZDADgAQAAAA==.',['等演']='等演:BAABLAAFFH8IAAIcAAII1wteFQCCAAAcAAII1wteFQCCAAAAAA==.',['米啊']='米啊内:BAAALAAECgYIBgAAAA==.',['糯米']='糯米甜甜:BAACLAAFFH8KAAIHAAMIUg+cTQBiAAAHAAMIUg+cTQBiAAAsAAQKfx4AAgcACAjRGcVDAHECAAcACAjRGcVDAHECAAAA.',['索尔']='索尔恺撒:BAABLAAFFH8QAAISAAMI8xMiLAC/AAASAAMI8xMiLAC/AAABLAAFFAYIHAAMAO4SAA==.',['索昭']='索昭:BAAALAAECgYIBgAAAA==.',['纯阳']='纯阳贯地:BAAALAAECgYIEQAAAA==.',['绯月']='绯月流影:BAAALAAECgYIBgAAAA==.',['绵羊']='绵羊菌:BAACLAAFFH8iAAMeAAYIvhuIJACKAQAeAAYIvhuIJACKAQAdAAEILRV+BwBRAAAsAAQKfyAAAx4ACAgWJGUVAAYDAB4ACAh8I2UVAAYDABQAAgi9IlRrAMkAAAAA.',['绿皮']='绿皮契弟:BAAALAAECgEIAQAAAA==.',['罗丶']='罗丶伯丶丝:BAAALAAECgEIAQAAAA==.',['罗体']='罗体:BAABLAAFFH8LAAIGAAQIyhYMEQA2AQAGAAQIyhYMEQA2AQAAAA==.',['羊角']='羊角大王:BAAALAAFFAIIBAAAAA==.',['美吕']='美吕:BAAALAADCgIIAgAAAA==.',['美的']='美的泡泡:BAAALAAFFAIIAgAAAA==.',['老尼']='老尼法号靓女:BAAALAAECgMIAwAAAA==.',['老睡']='老睡觉大王:BAAALAAECgMIAwAAAA==.',['老頭']='老頭兒:BAAALAADCgIIAgAAAA==.',['聚天']='聚天弒:BAAALAADCgEIAQAAAA==.',['胖牛']='胖牛牛:BAABLAAFFH8RAAIOAAUI+A7yVwDxAAAOAAUI+A7yVwDxAAAAAA==.',['自然']='自然木鳞龙:BAAALAADCgEIAQAAAA==.',['芬达']='芬达:BAAALAADCgcIBwAAAA==.',['苍蓝']='苍蓝星:BAABLAAFFH8FAAIOAAUI4xfTSQAoAQAOAAUI4xfTSQAoAQAAAA==.',['苏豆']='苏豆腐脑:BAAALAAFFAIIAgAAAA==.',['草枝']='草枝摆:BAAALAAECgYIBgAAAA==.',['荒芜']='荒芜拉普兰德:BAAALAAECgQICAAAAA==.',['莀莀']='莀莀:BAAALAAECgUIBQAAAA==.',['莉萝']='莉萝艾:BAABLAAFFH8GAAIGAAIISAzBVABoAAAGAAIISAzBVABoAAAAAA==.',['莫笑']='莫笑化蝶飞:BAABLAAFFH8HAAIOAAIIgx20hABOAAAOAAIIgx20hABOAAAAAA==.',['菠萝']='菠萝牛奶冰:BAAALAAECggICAAAAA==.',['萌丶']='萌丶小丶萌:BAABLAAFFH8KAAMeAAIIQwy3ZQA7AAAeAAEIrQq3ZQA7AAAUAAEI2Q2jIAAAAAAAAA==.',['萌新']='萌新凑热闹:BAAALAAFFAIIBAAAAA==.',['萌瑟']='萌瑟瑟:BAABLAAFFH8FAAIXAAIIIQXwXAB6AAAXAAIIIQXwXAB6AAAAAA==.',['营养']='营养小甘薯:BAAALAAECgEIAQAAAA==.',['萨丁']='萨丁丁:BAAALAAECgYIEgAAAA==.',['葬一']='葬一殇:BAAALAADCgIIAgAAAA==.',['葱油']='葱油鸡:BAAALAAECgYIDAAAAA==.',['蒲公']='蒲公英约定:BAAALAAECgYIBgAAAA==.',['蒼翠']='蒼翠冰刀:BAAALAAFFAMIAgAAAA==.',['蓝焰']='蓝焰:BAAALAADCgEIAQAAAA==.',['虚虚']='虚虚猎:BAABLAAFFH8MAAIOAAYI5g3ERwAvAQAOAAYI5g3ERwAvAQAAAA==.',['蜜蜂']='蜜蜂宝宝:BAAALAAECgcIAgAAAA==.',['裤衩']='裤衩子的传说:BAAALAADCgYIBgAAAA==.',['西桥']='西桥:BAAALAAECgMIBQAAAA==.',['西瓦']='西瓦的地狱火:BAABLAAFFH8GAAIeAAYIDwzLEQDUAQAeAAYIDwzLEQDUAQAAAA==.西瓦的无常:BAABLAAFFH8OAAIeAAgISxukCAB2AgAeAAgISxukCAB2AgAAAA==.西瓦的诅咒:BAAALAAFFAgIAgAAAA==.',['许我']='许我再少年:BAAALAAECgUICgAAAA==.',['诗酒']='诗酒年华:BAAALAAFFAIIAgAAAA==.',['豉油']='豉油鸡:BAAALAADCgUIBQAAAA==.',['豊川']='豊川祥子:BAAALAAECgQIBAAAAA==.',['豪豪']='豪豪丸:BAAALAAECgYIDwAAAA==.',['財源']='財源廣進進:BAAALAAECggIAgAAAA==.',['贝尔']='贝尔巴托夫:BAAALAAECgIIAgAAAA==.',['贝贝']='贝贝牛:BAAALAADCgcIBwAAAA==.',['踏破']='踏破贺兰山阕:BAAALAAECgYIBgAAAA==.',['辉之']='辉之鲁伊:BAAALAAECgIIAgAAAA==.',['辛德']='辛德维拉:BAAALAADCggICAAAAA==.',['远方']='远方的你:BAAALAADCgYIDAAAAA==.',['迪迪']='迪迪妞:BAAALAAFFAIIAgAAAA==.',['迷人']='迷人的狐狸:BAAALAAFFAMIAwAAAA==.迷人的风之画:BAABLAAFFH8NAAIeAAUIpwQvRwCqAAAeAAUIpwQvRwCqAAAAAA==.',['野生']='野生小鬼:BAAALAAECgYIBgAAAA==.',['镜爆']='镜爆爆:BAAALAADCgQIBAAAAA==.',['队长']='队长:BAAALAADCgEIAQAAAA==.',['阳光']='阳光丨雨露:BAAALAADCgMIAwAAAA==.',['阿梨']='阿梨:BAAALAADCgEIAQAAAA==.',['隐者']='隐者之紫:BAAALAAECgYIBgAAAA==.',['隔壁']='隔壁张叔叔:BAAALAAECgYICAAAAA==.隔壁老张:BAABLAAFFH8GAAIOAAIIbhusVQCSAAAOAAIIbhusVQCSAAAAAA==.',['雅丶']='雅丶蠛丶蝶:BAAALAAECgYICwAAAA==.',['雨霏']='雨霏:BAAALAAECgYIDAAAAA==.',['霸都']='霸都十二少:BAAALAAECgIIAgAAAA==.',['风停']='风停了又起:BAAALAADCggIDgAAAA==.',['风舞']='风舞小柒:BAAALAAFFAQIAgAAAA==.风舞小法:BAAALAAECggIBgAAAA==.',['风起']='风起爱已散:BAAALAAECgYIBgAAAA==.',['饭量']='饭量贼大:BAAALAAFFAIIAgAAAA==.',['马容']='马容易劈腿:BAAALAAFFAIIAgAAAA==.',['骑老']='骑老牛:BAAALAAECgEIAQAAAA==.',['鰻魚']='鰻魚児丶:BAABLAAFFH8MAAMXAAYIQgnTLAA0AQAXAAYIogTTLAA0AQABAAMIog3QDQBfAAAAAA==.',['鱼鱼']='鱼鱼吃猫猫:BAAALAAECgYICgAAAA==.',['鸳鸯']='鸳鸯鸡:BAAALAAECgEIAQAAAA==.',['黑色']='黑色均均:BAABLAAFFH8HAAICAAMI/RppCwDtAAACAAMI/RppCwDtAAAAAA==.',['龙大']='龙大:BAAALAAFFAIIAgAAAA==.',['龙葵']='龙葵:BAABLAAFFH8gAAMDAAYIWhd1CACfAQADAAYI0RZ1CACfAQAiAAUInBGJBQD6AAAAAA==.',['龙门']='龙门乞丐鸡:BAAALAAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end