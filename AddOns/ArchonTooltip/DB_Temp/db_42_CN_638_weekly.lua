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
 local lookup = {'DeathKnight-Blood','Paladin-Retribution','Shaman-Restoration','Shaman-Elemental','DeathKnight-Frost','DemonHunter-Vengeance','Paladin-Holy','Paladin-Protection','Druid-Balance','Hunter-Marksmanship','Druid-Restoration','Monk-Mistweaver','DeathKnight-Unholy','Evoker-Devastation','Mage-Arcane','Mage-Fire','Mage-Frost','DemonHunter-Havoc','Unknown-Unknown','Priest-Holy','Warrior-Fury','Warrior-Arms','Monk-Windwalker','Rogue-Outlaw','Warlock-Demonology','Warlock-Destruction','Priest-Discipline','Priest-Shadow','Hunter-BeastMastery',}; local provider = {region='CN',realm='奎尔丹纳斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={As='Asunasama:BAAAKgAFFAYIAgAAAA==.',Cr='Crazed:BAAAKgAFFAIIAQAAAA==.',Df='Dfh:BAABKgAFFH8FAAIBAAUIcA5iGgDPAAABAAUIcA5iGgDPAAAAAA==.',Fi='Fish:BAAAKgAECgIIAgAAAA==.',Ma='Manaj:BAAAKgAECgEIAQAAAA==.',Mi='Minig:BAAAKgAECgIIAgAAAA==.',Mo='Moonn:BAAAKgAECgUIDAAAAA==.',Sh='Shallow:BAAAKgADCggICAAAAA==.',['三修']='三修:BAAAKgAECggICAAAAA==.',['三千']='三千烦恼风:BAAAKgAECgQIBAAAAA==.',['丨折']='丨折戟沉沙丨:BAABKgAFFH8GAAICAAYIQwiiLAA1AQACAAYIQwiiLAA1AQAAAA==.',['丨血']='丨血月织梦丨:BAABKgAFFH8GAAIBAAYIFAvCFgDrAAABAAYIFAvCFgDrAAAAAA==.',['丶小']='丶小学生:BAAAKgADCggICwAAAA==.丶小骚情:BAAAKgADCggICAAAAA==.',['丹卡']='丹卡拉比:BAAAKgAECgYIDgAAAA==.',['亡束']='亡束丶:BAAAKgAECgIIAgAAAA==.',['亡雍']='亡雍丶:BAAAKgAECgYICwAAAA==.',['低头']='低头等你吻:BAAAKgAFFAQIBAAAAA==.',['傻不']='傻不哭:BAACKgAFFH8HAAIDAAYIHh3GCQCpAQADAAYIHh3GCQCpAQAqAAQKfxUAAwQACAgsF+EeANIBAAQABwj4GuEeANIBAAMACAh+FgQtAMcBAAAA.',['兰德']='兰德里:BAAAKgADCgMIAwAAAA==.',['冬晚']='冬晚聚:BAAAKgADCgUIBQAAAA==.',['冬瓜']='冬瓜炖豆腐:BAAAKgADCggICAAAAA==.',['冰冬']='冰冬兜:BAAAKgAFFAEIAQAAAA==.',['冰冷']='冰冷的小米:BAAAKgAECgQIBAAAAA==.',['刃乱']='刃乱之吻:BAAAKgAECgYIEQAAAA==.',['剑月']='剑月琴星:BAABKgAECn8WAAIFAAgIGyD5BgBbAgAFAAgIGyD5BgBbAgAAAA==.',['努尔']='努尔哈茨:BAABKgAFFH8HAAIGAAUI+gD5DACJAAAGAAUI+gD5DACJAAAAAA==.',['半醉']='半醉丶:BAAAKgAECgEIAQAAAA==.',['古辰']='古辰海:BAABKgAFFH8KAAQHAAYIgB5jBAADAQAHAAQIqh1jBAADAQAIAAIIMAyAEQBrAAACAAEI3xkAAAAAAAAAAA==.',['只管']='只管卖萌:BAABKgAFFH8LAAIJAAYIQRtNCAAtAQAJAAYIQRtNCAAtAQAAAA==.',['可乐']='可乐有点甜:BAAAKgAECgUIBQAAAA==.',['史蒂']='史蒂芬大叔:BAABKgAFFH8HAAIKAAcIWA/ICQCHAQAKAAcIWA/ICQCHAQAAAA==.',['吕布']='吕布:BAAAKgAFFAEIAQAAAA==.',['吾不']='吾不是咕咕呀:BAAAKgAECggIBgABKgAFFAgICAALAFIeAA==.',['善良']='善良的阿良:BAAAKgAECgMIAwAAAA==.',['回忆']='回忆正在继续:BAAAKgAECggICAAAAA==.回忆那一刻:BAAAKgAFFAQIBAAAAA==.',['困在']='困在那天:BAAAKgADCggICAAAAA==.',['塔达']='塔达:BAAAKgAECggIDgAAAA==.',['墓诗']='墓诗丶:BAAAKgAECgQIBAAAAA==.',['夏绯']='夏绯:BAAAKgADCggICQAAAA==.',['大聋']='大聋人:BAAAKgAFFAgIAgAAAA==.',['娘娘']='娘娘千岁:BAABKgAFFH8HAAIMAAUIXhBkCgAnAQAMAAUIXhBkCgAnAQAAAA==.',['婀弗']='婀弗詻狄忒:BAAAKgAFFAgIAwAAAA==.',['孤独']='孤独丶旅行者:BAAAKgAECggICQAAAA==.',['宇少']='宇少小德:BAAAKgAECgYIBgAAAA==.宇少小萨:BAABKgAFFH8HAAIDAAYIowOAIwDqAAADAAYIowOAIwDqAAAAAA==.',['小吼']='小吼意难平:BAACKgAFFH8GAAINAAQIxRLwMwDGAAANAAQIxRLwMwDGAAAqAAQKfxkAAg0ACAjFFm0lAPIBAA0ACAjFFm0lAPIBAAEqAAUUCAgIAAEAvR4A.',['小坏']='小坏东西:BAAAKgAFFAIIAgAAAA==.',['小聋']='小聋人:BAABKgAFFH8PAAIOAAgIaCDrBgAgAgAOAAgIaCDrBgAgAgAAAA==.',['少司']='少司命:BAAAKgAECgYIBgAAAA==.',['岁岁']='岁岁大王:BAAAKgAFFAEIAQAAAA==.',['巨无']='巨无霸:BAAAKgADCggICQAAAA==.',['希儿']='希儿之怒:BAAAKgAECggIDQAAAA==.',['带小']='带小孩的流氓:BAABKgAFFH8GAAICAAYIziC5EwC+AQACAAYIziC5EwC+AQAAAA==.',['幸福']='幸福的坦克:BAAAKgADCgcIDgAAAA==.',['忠艾']='忠艾一生:BAAAKgAECgIIAgAAAA==.',['悠悠']='悠悠起很晚:BAABKgAFFH8aAAQPAAgIyw05CwCnAQAPAAgI5AY5CwCnAQAQAAYIqRGqGQDpAAARAAIIFgLiLQAxAAAAAA==.',['愤怒']='愤怒之锤:BAAAKgAFFAIIAgAAAA==.',['慕容']='慕容萨满:BAAAKgAECgUIAQAAAA==.慕容醉猫:BAAAKgAECgUIBgAAAA==.',['懂事']='懂事的她:BAAAKgAECggICAAAAA==.',['戎马']='戎马一身:BAAAKgAECgMIAwAAAA==.',['我很']='我很抱歉:BAABKgAFFH8LAAMSAAQIZx8yHwAKAQASAAQIZx8yHwAKAQAGAAMIgwsIDACUAAAAAA==.',['我渴']='我渴望鲜血:BAAAKgAFFAQIBAAAAA==.',['拂晓']='拂晓之剑:BAAAKgAECgQIBAAAAA==.',['撒满']='撒满基斯:BAAAKgAECgMIAwAAAA==.',['断德']='断德:BAABKgAFFH8FAAIBAAUIxwaWIAChAAABAAUIxwaWIAChAAABKgAFFAgIBAATAAAAAA==.',['方大']='方大同:BAAAKgADCgQIBAAAAA==.',['明明']='明明很好吃:BAAAKgAECgYIBwAAAA==.',['晨曦']='晨曦骄阳:BAAAKgAECgYIBgAAAA==.',['暗夜']='暗夜水蜜桃:BAAAKgAFFAEIAQAAAA==.',['有钱']='有钱任性:BAAAKgAECgMIAwAAAA==.',['朝夕']='朝夕:BAAAKgADCggICAAAAA==.',['木易']='木易京日天:BAAAKgAECgMIAwABKgAFFAIIBwAUAFQTAA==.',['木石']='木石:BAAAKgADCgEIAQAAAA==.',['杀生']='杀生灭众生:BAAAKgADCggICAAAAA==.',['杯莫']='杯莫停:BAABKgAFFH8PAAMVAAYIcRlLCgCoAQAVAAYIUxhLCgCoAQAWAAYI7xEXCwBcAQAAAA==.',['武憎']='武憎:BAABKgAFFH8MAAMXAAgIaBGDCgA5AQAXAAgIaBGDCgA5AQAMAAQIIwgFFwDDAAAAAA==.',['沙砾']='沙砾丶:BAABKgAFFH8GAAIRAAIITSEYGQCxAAARAAIITSEYGQCxAAAAAA==.',['泰七']='泰七七:BAAAKgADCgEIAQAAAA==.',['浅殇']='浅殇花树:BAAAKgAECgMIAwAAAA==.',['混子']='混子:BAABKgAECn8UAAIYAAcIVhjzAwDPAQAYAAcIVhjzAwDPAQAAAA==.混子不混:BAAAKgAECgUIBQAAAA==.',['温柔']='温柔一锤:BAABKgAFFH8GAAICAAYIswmmLAA0AQACAAYIswmmLAA0AQAAAA==.',['满身']='满身肌肉灰:BAAAKgADCgQIBAAAAA==.',['灰飞']='灰飞德熊:BAAAKgAECggICAAAAA==.',['灼眼']='灼眼的夏亚:BAABKgAFFH8FAAISAAUIcxb3DACEAQASAAUIcxb3DACEAQAAAA==.',['熊猫']='熊猫星:BAAAKgADCgYIBgAAAA==.',['熙喵']='熙喵喵的天空:BAAAKgAFFAQIBAAAAA==.',['熙阳']='熙阳皓月:BAAAKgADCggICAAAAA==.',['牛小']='牛小胖:BAABKgAFFH8FAAMJAAMIax4AEwDuAAAJAAMIax4AEwDuAAALAAIIiRXLFgCBAAABKgAFFAgIBAATAAAAAA==.',['猫猫']='猫猫:BAAAKgAFFAIIAQAAAA==.',['环保']='环保春哥:BAABKgAECn8YAAMZAAgIaBeNGAC8AQAZAAgIWRaNGAC8AQAaAAUILhlEOgAiAQAAAA==.',['瓦里']='瓦里安乌瑞恩:BAABKgAFFH8LAAIWAAYIhwmrAwA0AQAWAAYIhwmrAwA0AQAAAA==.',['白豌']='白豌豆:BAABKgAECn8bAAMCAAgI+yJYGwCXAgACAAgI+yJYGwCXAgAHAAcIkR3XDwD/AQAAAA==.',['真皮']='真皮:BAABKgAECn8fAAMDAAgInxUcPACFAQADAAcIbxgcPACFAQAEAAcIjBWqEQBwAQAAAA==.',['破晓']='破晓临离:BAABKgAFFH8HAAIbAAYIExNJDgDkAAAbAAYIExNJDgDkAAAAAA==.',['破空']='破空大月:BAABKgAFFH8IAAMaAAgIHBYBFABlAQAaAAQIeB0BFABlAQAZAAQITQwbEgCvAAAAAA==.',['秀你']='秀你一臉:BAAAKgAFFAEIAQAAAA==.',['穷疯']='穷疯的小羊:BAAAKgAECgQIBAAAAA==.',['粉嘟']='粉嘟嘟小仙女:BAABKgAFFH8HAAIQAAQI+wVmJwCzAAAQAAQI+wVmJwCzAAAAAA==.',['紫色']='紫色的圈圈:BAAAKgAFFAEIAQAAAA==.',['红皮']='红皮白肉:BAAAKgAECgEIAQAAAA==.',['练习']='练习两年半:BAABKgAFFH8GAAIRAAYIJBsMCABCAQARAAYIJBsMCABCAQAAAA==.',['绝情']='绝情右手:BAAAKgAECgYICwAAAA==.',['维生']='维生素:BAAAKgADCgEIAQAAAA==.',['缇宝']='缇宝:BAACKgAFFH8HAAIUAAIIVBMaFgCQAAAUAAIIVBMaFgCQAAAqAAQKfx8AAhQACAhQHE0XABoCABQACAhQHE0XABoCAAAA.',['老亡']='老亡丶:BAAAKgADCggIDgAAAA==.',['肉肉']='肉肉去哪了:BAABKgAECn8WAAIbAAgIox/GCQByAgAbAAgIox/GCQByAgAAAA==.',['脆皮']='脆皮杀手:BAAAKgAFFAQIBAAAAA==.',['自愚']='自愚自乐:BAABKgAFFH8OAAQbAAgIvQwxDwArAQAbAAQInQkxDwArAQAcAAQIwBbxDgDlAAAUAAIIawtaGwB5AAAAAA==.',['舞夜']='舞夜悠靈:BAAAKgAFFAIIAgAAAA==.',['艾伦']='艾伦:BAABKgAFFH8IAAIdAAgIJg/TBwD6AQAdAAgIJg/TBwD6AQAAAA==.',['花言']='花言花:BAAAKgAFFAYIBAAAAA==.',['苍穹']='苍穹丶无垠:BAABKgAFFH8KAAIdAAYIIhmgEAB0AQAdAAYIIhmgEAB0AQAAAA==.苍穹之兵火:BAAAKgAECgIIAgAAAA==.',['莪叫']='莪叫小选:BAAAKgAFFAQIBAAAAA==.',['觉非']='觉非:BAAAKgAFFAQIAQAAAA==.',['诚实']='诚实的小菠萝:BAAAKgAECgIIAgAAAA==.',['财神']='财神的保镖:BAAAKgADCgUIBQAAAA==.',['赵我']='赵我说的做:BAACKgAFFH8QAAIaAAMIthU/KgDFAAAaAAMIthU/KgDFAAAqAAQKfyEAAhoACAj2HNETAAkCABoACAj2HNETAAkCAAAA.',['躺板']='躺板板:BAABKgAECn8UAAMWAAcIdhhhGwCqAQAWAAcIdhhhGwCqAQAVAAEIAABEQQAAAAAAAA==.',['轩辕']='轩辕的小圣歌:BAAAKgADCgQIBAAAAA==.',['辛多']='辛多雷血骑士:BAACKgAFFH8GAAICAAMI8hY7IQDjAAACAAMI8hY7IQDjAAAqAAQKfx8AAwIACAiqIwIaAJ0CAAIACAiqIwIaAJ0CAAcABgghDggxAOoAAAAA.',['还得']='还得是你:BAAAKgADCgEIAQAAAA==.',['迷虹']='迷虹:BAAAKgAFFAYIBAAAAA==.',['追风']='追风赶月:BAABKgAFFH8WAAMJAAgIRSXRAQDbAgAJAAgIRSXRAQDbAgALAAYIHR8dBwChAQAAAA==.',['遠古']='遠古巫灵:BAABKgAFFH8KAAIEAAYIfxdxBwBmAQAEAAYIfxdxBwBmAQAAAA==.',['醉卧']='醉卧云岚:BAAAKgAECggICQAAAA==.',['釢白']='釢白的雪子:BAAAKgAFFAIIAgAAAA==.',['锁甲']='锁甲下面没货:BAAAKgADCggICAAAAA==.',['锝镥']='锝镥铱:BAAAKgADCgEIAQAAAA==.',['镂尘']='镂尘欥影:BAAAKgAECgEIAQAAAA==.',['长眉']='长眉毛:BAAAKgADCgYICAAAAA==.',['阿亡']='阿亡丶:BAAAKgAECgEIAQAAAA==.',['陈書']='陈書:BAABKgAFFH8HAAIBAAUINgH6DgCJAAABAAUINgH6DgCJAAAAAA==.',['陌路']='陌路以西:BAAAKgAFFAIIAgAAAA==.',['霓虹']='霓虹:BAAAKgAFFAEIAQAAAA==.',['非洲']='非洲帝凯:BAAAKgAECggIDgAAAA==.',['颜值']='颜值超标:BAAAKgAECgEIAQAAAA==.颜值过高:BAABKgAFFH8MAAMHAAQIlhZRBwDdAAAHAAQIlhZRBwDdAAAIAAQILBVrCgC+AAAAAA==.',['风怒']='风怒丶:BAAAKgAECgYIBgAAAA==.',['骑着']='骑着狼放羊:BAAAKgAECgIIAgAAAA==.',['鲜果']='鲜果橙:BAAAKgAECgYIBgAAAA==.',['鹿王']='鹿王河:BAAAKgAFFAIIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end