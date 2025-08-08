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
 local lookup = {'DemonHunter-Havoc','Hunter-Marksmanship','Shaman-Restoration','Shaman-Enhancement','Shaman-Elemental','Hunter-BeastMastery','Warlock-Destruction','Priest-Discipline','Priest-Shadow','Priest-Holy','DeathKnight-Unholy','Mage-Arcane','Paladin-Protection','Paladin-Retribution','Druid-Balance','Druid-Restoration','Druid-Guardian','Warrior-Protection','Warrior-Fury','Monk-Windwalker','Mage-Fire','Paladin-Holy','Monk-Brewmaster','Monk-Mistweaver','Rogue-Assassination','Evoker-Devastation','Evoker-Preservation','Mage-Frost','DeathKnight-Blood','DemonHunter-Vengeance','Druid-Feral','Unknown-Unknown','Warrior-Arms','Warlock-Affliction','DeathKnight-Frost',}; local provider = {region='CN',realm='达隆米尔',name='CN',type='weekly',zone=42,date='2025-08-02',data={Aj='Aj:BAAAKgAECgYIDAAAAA==.',Cp='Cpdd:BAAAKgAECgEIAgAAAA==.',De='Destinyl:BAAAKgAECgUIBQAAAA==.',Er='Ergergsdf:BAAAKgAECgYIBgAAAA==.',Ga='Gamecraft:BAAAKgADCgEIAQAAAA==.',Gr='Greatman:BAAAKgAECgEIAQAAAA==.',Ha='Hamwong:BAAAKgAECgYICAAAAA==.Han:BAAAKgAECgQIBAAAAA==.',Ic='Icce:BAAAKgAECgcIDQAAAA==.',Ii='Iicee:BAABKgAFFH8GAAIBAAYImw6uDQBxAQABAAYImw6uDQBxAQABKgAFFAgIBgABAOsJAA==.',Je='Jeannelapuce:BAAAKgAECggIDwAAAA==.',Ki='Kimtang:BAAAKgAECgYICAAAAA==.',Ko='Koice:BAAAKgAECgIIAgAAAA==.',Mm='Mmnf:BAAAKgAECgIIAgAAAA==.',Mn='Mnboi:BAAAKgADCgMIAwAAAA==.',Po='Popodh:BAAAKgAFFAQIBAAAAA==.Popolrx:BAABKgAFFH8IAAICAAgIHwthCACrAQACAAgIHwthCACrAQAAAA==.Poposma:BAABKgAFFH8GAAIDAAYIChV/CwBDAQADAAYIChV/CwBDAQAAAA==.',Pr='Prussia:BAAAKgAECgYIBwAAAA==.',So='Sorcererfs:BAAAKgAECggIEwAAAA==.',Vi='Vic:BAABKgAFFH8UAAQDAAYIaBADFwDJAAADAAUI4g4DFwDJAAAEAAYIWhf/FQBeAAAFAAEIGBLbJQBIAAAAAA==.',['一碗']='一碗四百:BAAAKgAFFAIIAgAAAA==.',['七实']='七实:BAAAKgAECgIIBAABKgAFFAIICAADAJ0mAA==.',['万箭']='万箭:BAAAKgAECgUIBwAAAA==.',['下一']='下一站離開:BAAAKgAECgcIBwAAAA==.',['世界']='世界萨彡:BAAAKgAECgYICAAAAA==.',['丨沛']='丨沛艾丨:BAACKgAFFH8GAAIGAAIIoQWaUgBjAAAGAAIIoQWaUgBjAAAqAAQKfyUAAgYACAgaE3BVALEBAAYACAgaE3BVALEBAAAA.',['中煎']='中煎人:BAAAKgAECgEIAQAAAA==.',['丶吃']='丶吃人:BAABKgAFFH8GAAIHAAYIIRGOFwBHAQAHAAYIIRGOFwBHAQAAAA==.',['丶沙']='丶沙奈朵:BAABKgAFFH8QAAQIAAgIChL7CQAFAQAIAAQIHxn7CQAFAQAJAAYI+AxxEwDJAAAKAAMI5wlaIwC2AAAAAA==.',['丿丶']='丿丶冷楓丶:BAAAKgAECgQIBQAAAA==.',['乖乖']='乖乖小公主:BAAAKgAECgYICAAAAA==.',['乳白']='乳白色:BAAAKgAECgUICAAAAA==.',['二十']='二十四孝:BAABKgAFFH8GAAILAAIIbRkeQQCaAAALAAIIbRkeQQCaAAAAAA==.',['五福']='五福监門:BAAAKgADCggICAAAAA==.',['伊里']='伊里娅特弦灵:BAABKgAFFH8GAAIGAAYIyBG/DABqAQAGAAYIyBG/DABqAQAAAA==.',['会抓']='会抓鱼的熊:BAAAKgAECgMIAwAAAA==.',['估算']='估算师:BAABKgAFFH8HAAIMAAcI8hYqCgDKAQAMAAcI8hYqCgDKAQAAAA==.',['你们']='你们冲我掩护:BAAAKgAECggIEQAAAA==.',['倒霉']='倒霉蛋儿:BAABKgAFFH8KAAINAAYIIiJdBQDkAQANAAYIIiJdBQDkAQABKgAFFAgIEgAOAEYfAA==.',['傲世']='傲世丶神王:BAAAKgAECggICQAAAA==.',['元述']='元述:BAACKgAFFH8jAAICAAcIchmsEQBWAQACAAcIchmsEQBWAQAqAAQKfyEAAwIACAjXH2cRAEoCAAIACAjXH2cRAEoCAAYAAQj5EsT7AD8AAAAA.',['兄弟']='兄弟:BAAAKgAECgcIBwAAAA==.',['兎笓']='兎笓:BAACKgAFFH8IAAMPAAIIPSU7LgDaAAAPAAIIPSU7LgDaAAAQAAIImhFyLABrAAAqAAQKfx0AAw8ACAixItwhAEICAA8ACAixItwhAEICABAAAgj8DoxuAGsAAAAA.',['兰茜']='兰茜娅:BAABKgAFFH8IAAIOAAgIzgleDQDKAQAOAAgIzgleDQDKAQAAAA==.',['关历']='关历亥士:BAAAKgADCggIDgAAAA==.',['冰糖']='冰糖雪梨丶:BAAAKgAECgQIBgAAAA==.',['冰霜']='冰霜大领主:BAAAKgAECgYIBgAAAA==.',['凯瑟']='凯瑟琳:BAAAKgADCgQIBAAAAA==.',['出逃']='出逃玫瑰:BAAAKgAECggICAAAAA==.',['刘爷']='刘爷:BAABKgAFFH8MAAIRAAMI3g2YCACEAAARAAMI3g2YCACEAAAAAA==.',['刘瑾']='刘瑾优:BAABKgAECn8ZAAISAAgI7RHyFgBeAQASAAgI7RHyFgBeAQAAAA==.',['北欧']='北欧王座:BAAAKgADCggICAAAAA==.',['南瓜']='南瓜豆豆:BAACKgAFFH8KAAITAAMIYB8hFQAUAQATAAMIYB8hFQAUAQAqAAQKfyUAAhMACAiAG/geAB8CABMACAiAG/geAB8CAAAA.',['博博']='博博:BAAAKgAFFAEIAQAAAA==.',['原野']='原野:BAAAKgAECggIDgAAAA==.',['发育']='发育不全:BAABKgAFFH8GAAIHAAYIQB7uDAC9AQAHAAYIQB7uDAC9AQAAAA==.',['叛逆']='叛逆魯魯:BAABKgAFFH8QAAIOAAYILiQZCQA2AQAOAAYILiQZCQA2AQAAAA==.',['古德']='古德猫灵:BAAAKgADCgYIBgAAAA==.',['叫我']='叫我哥:BAAAKgAECgUIBQAAAA==.',['史迪']='史迪奇:BAABKgAFFH8GAAIFAAYIFwpPCgAmAQAFAAYIFwpPCgAmAQAAAA==.',['吉米']='吉米仔:BAAAKgAECgIIBAAAAA==.',['听风']='听风海螺:BAAAKgAECggIDgAAAA==.',['命运']='命运之手:BAAAKgAECgcICgAAAA==.',['咕德']='咕德猫宁:BAABKgAFFH8IAAIPAAQIQg8pPAC2AAAPAAQIQg8pPAC2AAAAAA==.',['咖啡']='咖啡苦酒:BAAAKgAECgQIBAAAAA==.',['哭孑']='哭孑誰疼:BAAAKgADCgYICAAAAA==.',['哼珩']='哼珩哈嘿:BAAAKgAECgMIAwAAAA==.',['商雀']='商雀:BAABKgAFFH8GAAIOAAYIOA4lIwBfAQAOAAYIOA4lIwBfAQAAAA==.',['啊嘛']='啊嘛忒拉斯:BAAAKgAECggICAAAAA==.',['嘉仕']='嘉仕伯爵:BAAAKgADCgMIAwAAAA==.',['噬心']='噬心隐为者:BAABKgAFFH8IAAIGAAYIRBk7AwCqAQAGAAYIRBk7AwCqAQAAAA==.',['嚯霍']='嚯霍嚯霍嚯霍:BAAAKgADCggIEAAAAA==.',['四阿']='四阿哥:BAAAKgAECgUIBgAAAA==.',['圈圈']='圈圈肉:BAABKgAECn8dAAIUAAgIMB9YGgAMAgAUAAgIMB9YGgAMAgAAAA==.',['堕落']='堕落的叉烧包:BAAAKgADCggICQAAAA==.',['夜色']='夜色薇魉:BAAAKgADCggICAAAAA==.',['大油']='大油边:BAAAKgAECgQIBAABKgAFFAgIHAAVAAoiAA==.',['大海']='大海神:BAAAKgADCgcIBwAAAA==.',['天空']='天空打手:BAAAKgAECgcIBwAAAA==.',['太平']='太平洋的眼泪:BAACKgAFFH8oAAQOAAgIfiJJDQD7AQAOAAgIfiJJDQD7AQAWAAEIzB35GgBUAAANAAEILwXMLgAbAAAqAAQKfxoAAw4ACAjfJGYSAM4CAA4ACAjfJGYSAM4CAA0AAQjpCt1YACMAAAAA.',['太熊']='太熊猫了:BAAAKgAFFAIIAgAAAA==.',['太牛']='太牛掰了:BAAAKgAECgYIBgAAAA==.',['太邪']='太邪恶了:BAAAKgAECgQIBAAAAA==.',['太顽']='太顽皮了:BAAAKgAECgIIAgAAAA==.',['失落']='失落的人:BAAAKgAECgYIDgAAAA==.',['奥帝']='奥帝努斯:BAAAKgAFFAIIBAAAAA==.',['如瑶']='如瑶:BAAAKgADCgYIBgAAAA==.',['妖祸']='妖祸喰:BAAAKgAECggIEAAAAA==.',['娶灬']='娶灬紅太狼:BAAAKgAECgcIEQAAAA==.',['娶紅']='娶紅太狼:BAAAKgADCgIIAgAAAA==.',['学长']='学长不凶:BAACKgAFFH8nAAIXAAYIVgxVBAD1AAAXAAYIVgxVBAD1AAAqAAQKfx0AAhcACAgCD2IQADkBABcACAgCD2IQADkBAAAA.',['射太']='射太阳的后羿:BAAAKgADCgUIBQAAAA==.',['小光']='小光明:BAAAKgAECgQIBAAAAA==.',['小吉']='小吉湾:BAAAKgAECgYIBgAAAA==.',['小楠']='小楠楠:BAAAKgADCgEIAQAAAA==.',['小激']='小激凌:BAAAKgAFFAgIAgAAAA==.',['小熊']='小熊摊手:BAABKgAFFH8GAAIHAAYI9QPwKQDGAAAHAAYI9QPwKQDGAAAAAA==.',['小白']='小白爱蛋蛋:BAAAKgADCgUIBQAAAA==.',['小雨']='小雨喵喵:BAAAKgAECgEIAQAAAA==.',['尐姐']='尐姐貴婞:BAAAKgAFFAQIBAAAAA==.',['屋檐']='屋檐下的一抹:BAAAKgAECgQIBAAAAA==.',['岚心']='岚心贝贝:BAABKgAFFH8FAAITAAUIkgsrDQAkAQATAAUIkgsrDQAkAQAAAA==.',['已离']='已离线三年:BAAAKgADCgIIAgAAAA==.',['希尔']='希尔瓦拉斯:BAAAKgAFFAgIBAAAAA==.',['幻想']='幻想曲:BAAAKgAFFAMIAwAAAA==.',['幽兰']='幽兰拿铁:BAABKgAFFH8KAAMQAAgIlwwRDABFAQAQAAYIyw8RDABFAQAPAAQItAixIwAKAQAAAA==.',['弗丶']='弗丶拉基米尔:BAAAKgAECgUICgAAAA==.',['归晴']='归晴:BAAAKgADCggICAAAAA==.',['德德']='德德哋:BAAAKgAECgQIBAAAAA==.',['德神']='德神:BAAAKgAECgQIBQAAAA==.',['心上']='心上之秋:BAAAKgADCgYIBgAAAA==.',['心宽']='心宽体更胖:BAABKgAECn8mAAMXAAgISxs2BwAMAgAXAAgISxs2BwAMAgAYAAIITQ1RdAB6AAAAAA==.',['心忧']='心忧灵曦:BAAAKgAECgQIBgAAAA==.',['恐惧']='恐惧扩散:BAAAKgAFFAYIAgAAAA==.',['悟空']='悟空不空:BAAAKgADCgIIAgAAAA==.',['悠闲']='悠闲:BAABKgAFFH8KAAIOAAYILRmhIQBnAQAOAAYILRmhIQBnAQAAAA==.',['悲殤']='悲殤述裞微笑:BAAAKgAECgQIBAAAAA==.',['懲怒']='懲怒:BAAAKgAFFAQIBAAAAA==.',['我妚']='我妚哠訴你:BAAAKgAECgMIBgAAAA==.',['我遇']='我遇女心惊:BAAAKgAECggIEgAAAA==.',['戰骑']='戰骑:BAAAKgADCggICAAAAA==.',['打啵']='打啵浪子:BAABKgAFFH8ZAAIDAAQIqxhNKADVAAADAAQIqxhNKADVAAAAAA==.',['打地']='打地鼠:BAAAKgAECgQIBAAAAA==.',['执酒']='执酒笑白衣丶:BAAAKgAECggICAAAAA==.',['抽象']='抽象仙人:BAAAKgADCggICAAAAA==.',['摩羯']='摩羯座:BAAAKgAECgEIAQAAAA==.',['摸摸']='摸摸熊:BAAAKgAECgcIDQAAAA==.',['斯迪']='斯迪维尔:BAAAKgAECggICAAAAA==.',['新兵']='新兵蛋子:BAAAKgAECgQIBAAAAA==.',['无所']='无所谓去:BAAAKgAFFAIIAgAAAA==.',['无敌']='无敌偶秀:BAAAKgAECgYICwAAAA==.无敌小猪:BAAAKgAECgEIAQAAAA==.无敌小秀:BAABKgAECn8UAAIDAAgIfB0cFgBPAgADAAgIfB0cFgBPAgAAAA==.',['昼夜']='昼夜乱了和谐:BAABKgAFFH8MAAINAAYINRyRBwCZAQANAAYINRyRBwCZAQABKgAFFAgIFgAPALQWAA==.',['晓寒']='晓寒轻:BAAAKgAFFAQIBAABKgAFFAgICAAGAPYWAA==.',['晓影']='晓影乄:BAAAKgAFFAYIBAABKgAFFAgIBQAZAEkOAA==.',['晚霞']='晚霞与你:BAAAKgAECgcIBwAAAA==.',['景中']='景中水月:BAAAKgAECggICgAAAA==.',['晴天']='晴天:BAABKgAFFH8OAAIaAAgIMRIjCAD+AQAaAAgIMRIjCAD+AQAAAA==.',['暴龙']='暴龙哥:BAAAKgAECgMIAwAAAA==.',['有什']='有什么喂什么:BAABKgAFFH8GAAIGAAYIrgnHGgAqAQAGAAYIrgnHGgAqAQAAAA==.',['李葵']='李葵:BAAAKgAECgIIAwAAAA==.',['林夕']='林夕魅儿:BAABKgAFFH8eAAMDAAcIJBfQFQAtAQADAAYIWhXQFQAtAQAFAAMIswtlEQCPAAAAAA==.林夕龙二:BAABKgAECn8WAAMaAAgIWBOnKgBmAQAaAAgIWBOnKgBmAQAbAAMIlg28GQBeAAAAAA==.',['枫叶']='枫叶丶:BAABKgAFFH8IAAIBAAgIERuHBAB1AgABAAgIERuHBAB1AgAAAA==.',['枫天']='枫天璇:BAAAKgAECgEIAQAAAA==.',['枫明']='枫明乄:BAAAKgAFFAgIBAAAAA==.',['柒汐']='柒汐汐丶:BAAAKgAECggICQAAAA==.',['柒玥']='柒玥丶:BAAAKgAECgYIBgAAAA==.',['柠檬']='柠檬叶子:BAAAKgAECgcIBwAAAA==.',['栗子']='栗子:BAAAKgAECgIIAgAAAA==.',['梅林']='梅林丶转生:BAAAKgAECgYIBgAAAA==.',['梦若']='梦若心莲:BAAAKgAFFAIIAgAAAA==.',['梦醒']='梦醒:BAAAKgAECgYIDAAAAA==.',['梧桐']='梧桐乄:BAABKgAFFH8JAAMMAAgI7w+yCADrAQAMAAgIiA2yCADrAQAcAAEIFxzPEwBRAAAAAA==.',['森林']='森林中的美女:BAAAKgAFFAIIAgAAAA==.',['棱丶']='棱丶镜:BAAAKgAECgMIAwAAAA==.',['椰岛']='椰岛雄风:BAAAKgAECgEIAQAAAA==.',['楚雨']='楚雨荨:BAAAKgADCgUIBQAAAA==.',['橙色']='橙色憂鬱:BAAAKgAECggIDQAAAA==.',['正方']='正方形铁板:BAAAKgAFFAIIAgAAAA==.',['汪者']='汪者归来:BAAAKgADCggIDAAAAA==.',['没事']='没事做:BAAAKgADCgIIAgAAAA==.',['没活']='没活儿:BAAAKgADCgEIAQAAAA==.',['漆黑']='漆黑之王:BAAAKgAFFAIIAgAAAA==.',['潄石']='潄石:BAAAKgAFFAMIAwAAAA==.',['灬囵']='灬囵:BAAAKgAECgQIBAAAAA==.',['灬圣']='灬圣光灬:BAAAKgAECgUICgAAAA==.',['灭炎']='灭炎:BAACKgAFFH8IAAIDAAIInSZnJQDhAAADAAIInSZnJQDhAAAqAAQKfyAAAwMACAhJHZsZADoCAAMACAhJHZsZADoCAAUAAwiJBPxmAGIAAAAA.',['灰色']='灰色憂鬱:BAAAKgAECggIEgAAAA==.',['灵韵']='灵韵之峰:BAAAKgAECgIIAgAAAA==.灵韵之风:BAACKgAFFH8GAAIKAAIIJRIRMQCBAAAKAAIIJRIRMQCBAAAqAAQKfyMAAwoACAiDEtQzAE8BAAoACAiyEdQzAE8BAAgAAgj1FMZeAHwAAAAA.',['炸酱']='炸酱面:BAAAKgAECgUIBgAAAA==.',['煮熟']='煮熟的螃蟹猎:BAAAKgADCggICAAAAA==.',['燃烧']='燃烧:BAAAKgAECgIIAwAAAA==.燃烧的胸毛丶:BAAAKgAFFAYIAgAAAA==.',['爆打']='爆打红烧肉:BAACKgAFFH8cAAQVAAgICiIXBQAuAgAMAAgIBhdABQBMAgAVAAgIEhoXBQAuAgAcAAYITBvkAwCuAQAqAAQKfyEABBwACAhlH9kSAGgCABwACAhlH9kSAGgCABUABQiWECYlAAgBAAwABAgyFmogAJEAAAAA.',['爱已']='爱已成风:BAAAKgAECgIIAgAAAA==.',['爸爸']='爸爸:BAABKgAFFH8MAAMLAAYIiBEcFgBrAQALAAYI9BAcFgBrAQAdAAYIgwuuFgDsAAABKgAFFAgIDgALAEoXAA==.',['爹地']='爹地:BAABKgAFFH8RAAMaAAYIVhbsBABOAQAaAAUI9xnsBABOAQAbAAUIeAs5AgAMAQABKgAFFAgIGgAaAIoUAA==.',['狼鸢']='狼鸢狩:BAABKgAFFH8OAAICAAgIPCLpAwBTAgACAAgIPCLpAwBTAgAAAA==.',['王叔']='王叔:BAAAKgAECgUIBwAAAA==.',['王爷']='王爷:BAAAKgADCgIIBAAAAA==.',['玛丽']='玛丽卡:BAAAKgAFFAQIBAAAAA==.',['玛卡']='玛卡巴卡欣:BAABKgAFFH8GAAIOAAII3A7YcwCCAAAOAAII3A7YcwCCAAAAAA==.',['珑仁']='珑仁乄:BAABKgAFFH8GAAIaAAYInQbmGAD8AAAaAAYInQbmGAD8AAAAAA==.',['理塘']='理塘带法司:BAAAKgAECggIDQAAAA==.',['白色']='白色憂鬱:BAAAKgAECggIDQAAAA==.',['神王']='神王僧:BAAAKgAECgMIAwAAAA==.神王德:BAAAKgAECgUIBQAAAA==.神王猎:BAAAKgAECgYIBwAAAA==.',['福井']='福井:BAAAKgADCggICAAAAA==.',['离振']='离振:BAAAKgADCgMIAwAAAA==.',['离美']='离美人:BAABKgAFFH8GAAIKAAYIWBcPCgCAAQAKAAYIWBcPCgCAAQAAAA==.',['种星']='种星星:BAABKgAECn8cAAMBAAgIJR91HABZAgABAAgIJR91HABZAgAeAAEIJxzoXwBSAAAAAA==.',['种月']='种月亮:BAAAKgAECgIIAgAAAA==.',['科妮']='科妮:BAAAKgAECgQIBwAAAA==.',['空山']='空山清雨:BAAAKgAECgUIBwAAAA==.',['竹笋']='竹笋爱好者:BAAAKgAECgQIBAAAAA==.',['笑看']='笑看浮华苍生:BAAAKgAECgEIAQAAAA==.',['筝筝']='筝筝纸鸢:BAAAKgAFFAQIBAAAAA==.',['箖笓']='箖笓:BAAAKgAECgMIAwAAAA==.',['米欧']='米欧珂:BAABKgAFFH8GAAIPAAYITx/5DgCuAQAPAAYITx/5DgCuAQAAAA==.',['米浆']='米浆粑粑:BAACKgAFFH8tAAMPAAYInhoxHAA5AQAPAAYInhoxHAA5AQAQAAQIShi9DADKAAAqAAQKfyMABA8ACAgqIadAALMBAA8ACAgqIadAALMBABAABwhaHYsmAJoBAB8AAQjlFRQrAEIAAAAA.',['素笺']='素笺流年:BAABKgAFFH8UAAQIAAYIcCKTBAAAAgAIAAYIcCKTBAAAAgAJAAYIdhrsAQDHAQAKAAQIdBUPCwDdAAAAAA==.',['紫灵']='紫灵:BAABKgAFFH8IAAMJAAYIcxw3AgC8AQAJAAYIcxw3AgC8AQAIAAII5wWXFwCjAAAAAA==.',['紫色']='紫色憂鬱:BAAAKgAECgIIAgAAAA==.',['紫薯']='紫薯芋泥:BAAAKgAECggICAAAAA==.',['红色']='红色憂鬱:BAABKgAECn8WAAMTAAgINRLHJwCfAQATAAgINRLHJwCfAQASAAIIxAphHgBRAAAAAA==.',['绿术']='绿术临风:BAAAKgADCggIDQAAAA==.',['罹之']='罹之天烬:BAAAKgADCggICAAAAA==.',['羽落']='羽落荷包蛋:BAAAKgADCggICAAAAA==.',['老白']='老白涮肉坊:BAABKgAFFH8GAAITAAYI2A2iDwBbAQATAAYI2A2iDwBbAQABKgAFFAgIAgAgAAAAAA==.',['老骑']='老骑:BAAAKgADCgQIBAAAAA==.',['耶萌']='耶萌迦徳:BAABKgAECn8aAAITAAgI/w7mMABrAQATAAgI/w7mMABrAQAAAA==.',['艾尼']='艾尼维亚:BAAAKgAFFAgIBAAAAA==.',['茉莉']='茉莉雨:BAABKgAECn8ZAAIPAAgIJyBwEwCTAgAPAAgIJyBwEwCTAgAAAA==.',['草莓']='草莓啵啵:BAABKgAFFH8IAAIIAAgIZg2tBQDdAQAIAAgIZg2tBQDdAQAAAA==.',['莱恩']='莱恩斯:BAAAKgAECgIIBAAAAA==.',['菈妮']='菈妮:BAAAKgAFFAIIBAAAAA==.',['萨满']='萨满中的矮子:BAAAKgAFFAQIBAAAAA==.',['萨菲']='萨菲罗斯:BAAAKgAECggIEwAAAA==.',['落霞']='落霞斑斓:BAAAKgAECgcIBwAAAA==.',['蓝色']='蓝色憂鬱:BAAAKgAECgcICQAAAA==.',['蘭陵']='蘭陵笑笑生:BAAAKgAFFAYIBAAAAA==.',['虚无']='虚无术:BAAAKgADCgEIAQAAAA==.',['虚空']='虚空牢大:BAAAKgAECggIDAAAAA==.',['裴青']='裴青依:BAAAKgAECgEIAQAAAA==.',['褐色']='褐色憂鬱:BAAAKgAECggICAAAAA==.',['西风']='西风谷早苗:BAAAKgAECgcIBwAAAA==.',['请叫']='请叫我倾城君:BAAAKgAECggIEgAAAA==.请叫我黑哥哥:BAABKgAFFH8xAAIdAAgIeiGsAQCeAgAdAAgIeiGsAQCeAgAAAA==.',['豆沙']='豆沙:BAAAKgAECgUICwAAAA==.',['赞赞']='赞赞猪:BAABKgAECn8UAAITAAgIuhgiIQATAgATAAgIuhgiIQATAgAAAA==.',['赫拉']='赫拉克勒斯:BAAAKgAECgEIAQAAAA==.',['超市']='超市里扫货:BAABKgAFFH8UAAMTAAgIFxgqBABvAgATAAgItRYqBABvAgAhAAII1QxjHwCTAAAAAA==.',['过来']='过来人:BAAAKgAECgQIBAAAAA==.',['迷雾']='迷雾:BAAAKgAFFAQIBAAAAA==.',['逃离']='逃离温柔:BAAAKgAECgUICAAAAA==.',['那你']='那你咋整嘛:BAAAKgAECgQIBAAAAA==.',['邪气']='邪气男子:BAAAKgADCgUIBQAAAA==.',['酒醉']='酒醉迷人眼丶:BAAAKgAECgUIBgAAAA==.',['钱来']='钱来钱来:BAABKgAFFH8IAAMcAAUINRaABQAFAQAcAAMI/hmABQAFAQAMAAUIshKUQQBOAAAAAA==.',['门口']='门口江:BAAAKgAFFAIIBAAAAA==.',['阳光']='阳光下的矮子:BAABKgAFFH8KAAIOAAYIEhcGIABwAQAOAAYIEhcGIABwAQAAAA==.',['阿怜']='阿怜:BAAAKgAFFAgIBAAAAA==.',['阿斯']='阿斯忒莉亚:BAAAKgADCggICAAAAA==.',['阿赞']='阿赞:BAAAKgAECgcIBwAAAA==.',['随风']='随风漂流:BAAAKgAECgQICQAAAA==.',['隐秘']='隐秘果实:BAABKgAFFH8GAAICAAMIyQ0+MACtAAACAAMIyQ0+MACtAAAAAA==.',['雨落']='雨落凡尘:BAAAKgAECgYIDwAAAA==.',['雷霆']='雷霆脑瓜崩:BAABKgAECn8UAAIGAAgI8xgDQQD1AQAGAAgI8xgDQQD1AQAAAA==.',['霜雨']='霜雨丶:BAABKgAFFH8GAAICAAQIex0+KQDFAAACAAQIex0+KQDFAAAAAA==.',['青柠']='青柠玛奇朵:BAAAKgAECgEIAQAAAA==.',['青色']='青色憂鬱:BAAAKgAECgEIAQAAAA==.',['非常']='非常迷幻:BAAAKgAECgEIAQAAAA==.',['顾影']='顾影:BAAAKgAFFAIIBAAAAA==.',['顾韶']='顾韶颜:BAABKgAFFH8IAAMPAAQIXhoiKgDqAAAPAAQIXhoiKgDqAAAQAAII5g17GAA5AAAAAA==.',['风中']='风中玫瑰:BAAAKgADCgQIBAAAAA==.',['风之']='风之利刃:BAAAKgAECgQIBgAAAA==.',['风吹']='风吹尿叁章:BAAAKgAECgYICgAAAA==.',['风怒']='风怒丹利伊:BAAAKgAECgUIDgAAAA==.',['风神']='风神摇曳灬:BAABKgAFFH8IAAMHAAQI1Rt0IwDsAAAHAAQIVht0IwDsAAAiAAQI3w/0EQCWAAAAAA==.',['风羽']='风羽燕归来:BAACKgAFFH8UAAIDAAQI9B6bJwDYAAADAAQI9B6bJwDYAAAqAAQKfx0AAgMACAj5GS4tAMYBAAMACAj5GS4tAMYBAAAA.',['风般']='风般的美男子:BAACKgAFFH8NAAIDAAMIBB5YIwDqAAADAAMIBB5YIwDqAAAqAAQKfzAABAMACAgIGBQ1AKIBAAMACAgIGBQ1AKIBAAUACAhFDTE7ACMBAAQABAiVCSZLAJMAAAAA.',['风语']='风语燕归来:BAACKgAFFH8JAAIGAAMI4BeCKgDbAAAGAAMI4BeCKgDbAAAqAAQKfysAAwYACAhtH6YxAC4CAAYACAg/H6YxAC4CAAIABwjEEzJUAAABAAAA.',['馊裤']='馊裤泰裤辣:BAABKgAFFH8GAAIjAAYI3SDlAQDsAQAjAAYI3SDlAQDsAQAAAA==.',['骑了']='骑了个怪:BAAAKgAECgQICAAAAA==.',['骑空']='骑空士:BAABKgAFFH8GAAIZAAYIMhXvCgCdAQAZAAYIMhXvCgCdAQAAAA==.',['高贵']='高贵的树根:BAAAKgAECgIIAgAAAA==.',['黃色']='黃色憂鬱:BAAAKgAECggICgAAAA==.',['黑色']='黑色憂鬱:BAAAKgAECggIBwAAAA==.',['龍拳']='龍拳果实:BAABKgAECn8gAAIYAAgItxMgIACJAQAYAAgItxMgIACJAQAAAA==.',['龍龙']='龍龙侠:BAAAKgADCgEIAQAAAA==.',['龙与']='龙与玫瑰:BAACKgAFFH8GAAILAAIIoRHZRQCIAAALAAIIoRHZRQCIAAAqAAQKfxoAAgsABwhBG+4+ALUBAAsABwhBG+4+ALUBAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end