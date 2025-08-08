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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Paladin-Holy','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','DeathKnight-Unholy','Shaman-Enhancement','DemonHunter-Havoc','Shaman-Restoration','Mage-Frost','Mage-Arcane','Paladin-Retribution','DemonHunter-Vengeance','Warrior-Protection','Unknown-Unknown','Rogue-Outlaw','Hunter-Survival','Warrior-Fury','Druid-Restoration','Warrior-Arms','DeathKnight-Frost','DeathKnight-Blood','Priest-Shadow','Priest-Holy','Priest-Discipline','Warlock-Affliction','Monk-Brewmaster','Druid-Balance','Paladin-Protection','Rogue-Assassination','Shaman-Elemental',}; local provider = {region='CN',realm='暮色森林',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Allsun:BAABKgAFFH8MAAMBAAgIQRBeDQC2AQABAAgIQRBeDQC2AQACAAEIAADqIgAAAAAAAA==.',Au='Augustus:BAABKgAECn8cAAIDAAgIiRwrCQCZAQADAAgIiRwrCQCZAQAAAA==.',Cc='Ccnc:BAAAKgAECgUIBQAAAA==.',Cl='Close:BAAAKgAECgMIAwAAAA==.',Co='Contorl:BAAAKgAECgYICAAAAA==.Cowboy:BAAAKgADCggIEQAAAA==.',De='Demondan:BAAAKgADCggICAAAAA==.',Dr='Dragonfang:BAAAKgADCggICAAAAA==.',Ed='Edith:BAABKgAFFH8KAAIEAAYIrBF5GgAZAQAEAAYIrBF5GgAZAQABKgAFFAgICAAFAHMNAA==.',Em='Embracew:BAABKgAFFH8FAAIGAAQIYQq/JACQAAAGAAQIYQq/JACQAAAAAA==.',Ex='Existed:BAABKgAFFH8cAAIHAAcI5RuqDQC4AQAHAAcI5RuqDQC4AQAAAA==.Existing:BAACKgAFFH8LAAIIAAMIxRXECQACAQAIAAMIxRXECQACAQAqAAQKfyEAAggACAjQIoYHALICAAgACAjQIoYHALICAAAA.',Fe='Fellblade:BAABKgAFFH8GAAIJAAYI3hJ2FQBOAQAJAAYI3hJ2FQBOAQAAAA==.',Fi='Firenze:BAAAKgADCgMIAwAAAA==.',Fl='Float:BAAAKgAECgQIBAAAAA==.',Fo='Forcelovecc:BAAAKgAECgUIBQAAAA==.',Ge='Gevjon:BAABKgAFFH8KAAMEAAQIFiIwBwANAQAFAAQIDiJBDwARAQAEAAQI3B0wBwANAQAAAA==.',Gi='Gingi:BAAAKgAECgUIBQAAAA==.',Lu='Lucashaman:BAAAKgAFFAQIBAAAAA==.',Ma='Malestorm:BAABKgAECn8cAAIKAAgI0xPOFwB4AQAKAAgI0xPOFwB4AQAAAA==.Maxime:BAAAKgADCggICAAAAA==.',Me='Mezii:BAAAKgADCggICQAAAA==.',Mi='Mice:BAACKgAFFH8HAAMLAAMIDg2KGgCqAAALAAMIDg2KGgCqAAAMAAEI5QVsRwA1AAAqAAQKfyIAAwsACAhfFKQyAKcBAAsACAgVFKQyAKcBAAwABgjCCPJlALAAAAAA.',Na='Naturaldan:BAAAKgADCgUIBQAAAA==.',Ne='Nephalem:BAAAKgAFFAQIBAAAAA==.',No='Nola:BAAAKgADCgMIAwAAAA==.Notexist:BAACKgAFFH85AAINAAgI2CTVAQDlAgANAAgI2CTVAQDlAgAqAAQKfyoAAg0ACAgCJQYVAMMCAA0ACAgCJQYVAMMCAAAA.Notoobad:BAAAKgADCgUICQAAAA==.',Pl='Playerblvocy:BAAAKgAFFAIIAgAAAA==.',Pr='Priestdan:BAAAKgADCgIIAgAAAA==.',Qr='Qredm:BAABKgAECn8ZAAIOAAYI2xXPJwBEAQAOAAYI2xXPJwBEAQAAAA==.',Ra='Radiosasa:BAAAKgADCggICAAAAA==.',Se='Serendipia:BAAAKgAFFAIIAgAAAA==.',So='Soom:BAABKgAFFH8MAAIMAAYIeBryDACXAQAMAAYIeBryDACXAQAAAA==.',Su='Sulla:BAAAKgAECgYIBgAAAA==.',Sy='Syhylc:BAAAKgADCggICAAAAA==.',Tr='Tristan:BAAAKgADCgIIAgAAAA==.',Va='Vampire:BAAAKgAECgYIDAABKgAFFAgICAAJALwWAA==.',['一我']='一我一闪一:BAAAKgAECgIIAgAAAA==.',['一発']='一発入魂:BAABKgAFFH8KAAIEAAMIgghKNwCYAAAEAAMIgghKNwCYAAAAAA==.',['一祺']='一祺一会:BAAAKgADCgQIBAAAAA==.',['一般']='一般般吧:BAABKgAECn8wAAILAAgIdSIODgBiAgALAAgIdSIODgBiAgAAAA==.',['不知']='不知名的萨满:BAAAKgAECgcIEAAAAA==.',['不要']='不要醒太早:BAAAKgAECggICAAAAA==.',['丛林']='丛林有情狼:BAAAKgADCgEIAQAAAA==.',['两仪']='两仪式樣:BAABKgAECn8WAAIPAAYILw5jKwDVAAAPAAYILw5jKwDVAAABKgAECggIDwAQAAAAAA==.',['丰川']='丰川祥子様:BAAAKgADCgIIAgABKgAFFAQICwARANAkAA==.',['丶冷']='丶冷月:BAABKgAECn8VAAINAAgISR1ENgBNAgANAAgISR1ENgBNAgAAAA==.',['云出']='云出无迹:BAAAKgADCggICAAAAA==.',['云衶']='云衶心:BAABKgAFFH8LAAILAAMIshh/EADeAAALAAMIshh/EADeAAAAAA==.',['井芹']='井芹仁菜樣:BAAAKgADCggIFQABKgAFFAQICwARANAkAA==.',['亚沙']='亚沙沙:BAAAKgAECgYIBQAAAA==.',['亚煞']='亚煞极:BAAAKgAECggICAAAAA==.',['人偶']='人偶忧瞳:BAABKgAFFH8FAAILAAUIrBm1BwBIAQALAAUIrBm1BwBIAQAAAA==.',['伞木']='伞木希美様:BAABKgAECn8dAAQSAAcIAyHDAwA3AgASAAcImyDDAwA3AgAEAAYIVRlCMgBqAQAFAAIIJgzutwBSAAABKgAFFAQICwARANAkAA==.',['似水']='似水归堂:BAAAKgAECgQIBAAAAA==.',['你的']='你的誓言:BAAAKgADCgIIAgAAAA==.',['依依']='依依汉南:BAAAKgADCgYIBgAAAA==.',['侬册']='侬册那:BAABKgAFFH8GAAIGAAQIaB6SCQAZAQAGAAQIaB6SCQAZAQABKgAFFAgIKgAFACMgAA==.',['侽茼']='侽茼茄耗油:BAABKgAFFH8QAAITAAYIqibfBQAWAgATAAYIqibfBQAWAgAAAA==.',['修谱']='修谱丿诺斯丨:BAAAKgAFFAgIBAAAAA==.',['再看']='再看我就揍你:BAAAKgADCgEIAQAAAA==.',['包六']='包六件包件:BAAAKgAECgYIBgAAAA==.',['千早']='千早爱音樣:BAABKgAECn8kAAMJAAgIfRyGIABCAgAJAAgImRuGIABCAgAOAAcIHhfPIQBxAQABKgAFFAQICwARANAkAA==.',['卟觉']='卟觉离伤:BAAAKgADCgMIAwAAAA==.',['卡門']='卡門碎星者:BAABKgAECn8aAAIKAAcIkR0BJwDkAQAKAAcIkR0BJwDkAQAAAA==.',['卿卿']='卿卿:BAAAKgAECgYICwAAAA==.',['可爱']='可爱吕:BAAAKgAECggIDgAAAA==.',['吃大']='吃大米长大个:BAAAKgAECgMIAwAAAA==.',['吖捌']='吖捌蔡斯:BAABKgAECn8fAAIUAAgI4yByCQCNAgAUAAgI4yByCQCNAgABKgAFFAgIUQAJAGYhAA==.',['呆萌']='呆萌萌:BAAAKgAFFAQIBAAAAA==.',['周末']='周末不上班:BAABKgAFFH8KAAIJAAYI9RYgFgBKAQAJAAYI9RYgFgBKAQAAAA==.',['咕咕']='咕咕鸡:BAAAKgAECgEIAQAAAA==.',['咕嘟']='咕嘟咕嘟小五:BAAAKgAECgYIBgAAAA==.',['哥哥']='哥哥我是嫂子:BAAAKgAECgIIAgAAAA==.',['唔呼']='唔呼呼:BAAAKgAECggIEwAAAA==.',['啤酒']='啤酒花大怪兽:BAAAKgAFFAgIAgAAAA==.',['回忆']='回忆满满:BAAAKgAECgEIAQAAAA==.',['团灭']='团灭发动机:BAABKgAFFH8FAAIVAAUIMBdKDQA7AQAVAAUIMBdKDQA7AQAAAA==.',['圣光']='圣光的赐福:BAAAKgADCgEIAQAAAA==.',['壅鑍']='壅鑍:BAAAKgAFFAEIAQAAAA==.',['夜风']='夜风入你梦:BAAAKgAECgMIAwAAAA==.',['够姜']='够姜来战:BAAAKgAECgIIAgAAAA==.',['大丶']='大丶神:BAAAKgAECgMIAwAAAA==.',['大气']='大气球口子:BAAAKgAECgMIAwAAAA==.',['大蒜']='大蒜和咖啡:BAAAKgADCggICgAAAA==.',['大衆']='大衆老司機:BAAAKgAECgYIBgAAAA==.',['天命']='天命:BAAAKgAECgMIBQAAAA==.',['天尊']='天尊大帝:BAAAKgAECgcIBwAAAA==.',['天萨']='天萨:BAAAKgADCgEIAQAAAA==.',['奥丶']='奥丶姑:BAAAKgAECgIIAgAAAA==.',['妖怪']='妖怪们的妖:BAAAKgAECgQIBAAAAA==.',['嫂子']='嫂子我是我哥:BAAAKgAECgIIAgAAAA==.',['孤罒']='孤罒鸿:BAAAKgADCgMIAwAAAA==.',['安和']='安和昴樣:BAAAKgADCgMIAwABKgAFFAQICwARANAkAA==.',['安度']='安度因乌瑞恩:BAAAKgAFFAgIAgAAAA==.安度因落萨:BAABKgAFFH8IAAIVAAQIWCCGBAAcAQAVAAQIWCCGBAAcAQAAAA==.',['寒依']='寒依依:BAAAKgAFFAYIBAAAAA==.',['寒风']='寒风入你心:BAAAKgADCgMIAwAAAA==.',['小亓']='小亓不要跑:BAABKgAECn8bAAIHAAgIUBn3KgDRAQAHAAgIUBn3KgDRAQAAAA==.',['小妹']='小妹妹我来了:BAAAKgAECgYIEAAAAA==.',['小小']='小小钟:BAABKgAFFH8PAAMHAAgI8SImAQDkAgAHAAgI8SImAQDkAgAWAAQIVxqZBwDxAAAAAA==.',['小德']='小德酷酷儿:BAAAKgADCgcIBwAAAA==.',['小晓']='小晓蛸:BAABKgAFFH8HAAIBAAcI3g8wEACOAQABAAcI3g8wEACOAQAAAA==.',['小河']='小河豚:BAAAKgADCggICAAAAA==.',['小洛']='小洛:BAAAKgADCgMIAwAAAA==.',['小熊']='小熊软糖:BAABKgAECn8cAAMXAAgIPRUCFwCgAQAXAAgIPRUCFwCgAQAHAAIIOgdyqgBBAAAAAA==.',['小甜']='小甜甜:BAABKgAFFH8LAAIJAAUI3hS+EAApAQAJAAUI3hS+EAApAQAAAA==.',['小竹']='小竹竹:BAAAKgADCgQIBAAAAA==.',['小闲']='小闲闲丶:BAAAKgADCgMIAwAAAA==.',['小鱼']='小鱼丸:BAABKgAFFH8VAAQYAAgI3BU8AgC8AQAYAAYIjRs8AgC8AQAZAAUIzAsnEQC5AAAaAAEIrgQOMQBLAAAAAA==.',['岁月']='岁月如刀:BAACKgAFFH8bAAMBAAQIMxqvJQDdAAABAAQIMxqvJQDdAAACAAEIKAXaMQAzAAAqAAQKfxwAAwEACAg5G0IeAA4CAAEACAg5G0IeAA4CAAIABAiDFZhSAK8AAAAA.',['已婚']='已婚油腻男人:BAABKgAFFH8IAAIMAAgI9SOwAAD7AgAMAAgI9SOwAAD7AgAAAA==.',['帕力']='帕力:BAAAKgAECgYIBgAAAA==.',['幻紫']='幻紫雨林:BAABKgAFFH8MAAQBAAYI6xabBQBNAQABAAUI3hubBQBNAQAbAAII+QqkFgByAAACAAEIHgOPGQBIAAAAAA==.',['弑噬']='弑噬:BAAAKgAECggICAAAAA==.',['彼岸']='彼岸花:BAAAKgADCgQIBAAAAA==.',['总踩']='总踩雷霆脚麻:BAAAKgAECggIEAAAAA==.',['恨意']='恨意的单行道:BAAAKgAECgcICgAAAA==.',['愤怒']='愤怒的小蛋壳:BAAAKgADCgMIAwAAAA==.',['打不']='打不过就加入:BAAAKgAECgMIBQAAAA==.',['扬眉']='扬眉一笑:BAAAKgADCgEIAgAAAA==.',['披着']='披着凉皮的糖:BAAAKgAECgYICgAAAA==.',['掼蛋']='掼蛋皇城:BAABKgAFFH8RAAIBAAMIywYWOACQAAABAAMIywYWOACQAAAAAA==.',['插头']='插头:BAABKgAFFH8HAAIKAAMIzhjhJgDbAAAKAAMIzhjhJgDbAAAAAA==.',['救命']='救命土豆泥:BAAAKgAFFAYIBAAAAA==.',['教练']='教练我想打球:BAACKgAFFH8JAAIcAAMIWQnUCAB9AAAcAAMIWQnUCAB9AAAqAAQKfxoAAhwACAhgDjgQADwBABwACAhgDjgQADwBAAAA.',['斜晖']='斜晖脉脉:BAAAKgAECggICQABKgAFFAcIBwACAMsMAA==.',['易水']='易水寒庭:BAAAKgAFFAQIBAAAAA==.',['星月']='星月瞳影:BAABKgAFFH8GAAINAAYIxRpeGgCOAQANAAYIxRpeGgCOAQAAAA==.星月菇:BAAAKgAFFAQIBAAAAA==.',['春去']='春去秋来:BAAAKgAECgcIBwAAAA==.',['晒毛']='晒毛毛:BAABKgAFFH8IAAIZAAgIfQwrBgCpAQAZAAgIfQwrBgCpAQAAAA==.',['晓月']='晓月迷霜:BAAAKgADCgIIAgAAAA==.',['月之']='月之影:BAAAKgAECggICwAAAA==.',['月雅']='月雅儿:BAACKgAFFH8GAAIFAAYIoRZWEgBkAQAFAAYIoRZWEgBkAQAqAAQKfxgAAgUACAg5HuMqAEgCAAUACAg5HuMqAEgCAAAA.',['有心']='有心事的狸:BAAAKgADCggIDQAAAA==.',['枫花']='枫花雅:BAAAKgADCgEIAQAAAA==.',['树洞']='树洞王狠扎心:BAABKgAFFH8GAAMUAAYIDRIWGwDJAAAUAAQInxMWGwDJAAAdAAII0hnFPwCsAAAAAA==.',['栗子']='栗子蒙布朗:BAAAKgADCgUIBQAAAA==.',['格斯']='格斯蛙乔:BAAAKgAFFAQIBAAAAA==.',['梅凉']='梅凉馨:BAABKgAFFH8NAAMCAAYIDiC4BwC6AAABAAYIpR0AFABlAQACAAMIPx+4BwC6AAABKgAFFAgIDAABAMocAA==.',['梦幻']='梦幻米莉亚:BAABKgAFFH8GAAIHAAYICBc4FAB5AQAHAAYICBc4FAB5AQAAAA==.',['椎名']='椎名立希樣:BAAAKgADCgIIAwABKgAFFAQICwARANAkAA==.',['椒盐']='椒盐皮皮虾:BAAAKgADCgcIBwAAAA==.',['楚王']='楚王爷:BAABKgAFFH8HAAITAAMIRAPGGQCJAAATAAMIRAPGGQCJAAAAAA==.',['殊途']='殊途:BAACKgAFFH8zAAIFAAgIjSCPCADuAQAFAAgIjSCPCADuAQAqAAQKf0MAAwUACAgbJcMEAMwCAAUACAgbJcMEAMwCAAQAAwhQDdVxAHAAAAAA.',['沙和']='沙和尚:BAAAKgAECgYIBgAAAA==.',['河下']='河下文楼:BAAAKgAFFAIIBAAAAA==.',['河原']='河原木桃香樣:BAAAKgADCggIDAABKgAFFAQICwARANAkAA==.',['法布']='法布雷嘉斯:BAAAKgAECgMIAwAAAA==.',['流氓']='流氓龍:BAAAKgAECgMIBAAAAA==.',['海老']='海老冢智樣:BAAAKgADCggIEgABKgAFFAQICwARANAkAA==.',['清雾']='清雾星沂:BAABKgAFFH8HAAMCAAMIywzgFACeAAACAAMIFgzgFACeAAABAAEI+Qx3KgA6AAAAAA==.',['清风']='清风丶雷鸣:BAAAKgAECgYIBgAAAA==.',['渎神']='渎神腾跃:BAAAKgAFFAQIBAAAAA==.',['渣女']='渣女:BAAAKgAECggIEAAAAA==.',['湛蓝']='湛蓝色的天空:BAAAKgAECgIIAgAAAA==.',['漆月']='漆月:BAAAKgAECgcIBwAAAA==.',['潘南']='潘南奎:BAAAKgAECgUIBgAAAA==.',['灬菜']='灬菜虚鲲灬:BAAAKgAECgYIBgAAAA==.',['灰常']='灰常博爱:BAAAKgAECgcIBwAAAA==.灰常小屁孩:BAAAKgAECgcIDQAAAA==.灰常爱干净:BAABKgAECn8mAAMNAAgIyx9bNQBPAgANAAgIyx9bNQBPAgAeAAUIAQkwQACAAAAAAA==.',['炮灰']='炮灰式小角:BAABKgAFFH8IAAIBAAYISiaaBgAqAgABAAYISiaaBgAqAgAAAA==.炮灰式稻草:BAABKgAFFH8HAAIFAAQIrSQ7FgD2AAAFAAQIrSQ7FgD2AAAAAA==.',['熊德']='熊德一匹:BAAAKgAECggICwAAAA==.',['牛小']='牛小软:BAAAKgAECgQIBQAAAA==.',['特斯']='特斯塔罗莎:BAAAKgADCgEIAgAAAA==.',['狮子']='狮子座:BAAAKgAECgQIBAAAAA==.',['玛里']='玛里奥:BAAAKgADCggICAAAAA==.',['珐斯']='珐斯様:BAAAKgADCgEIAQABKgAFFAQICwARANAkAA==.',['珸玥']='珸玥:BAAAKgADCgMIAwAAAA==.',['电虐']='电虐大师:BAAAKgADCgYIBgAAAA==.',['白云']='白云黄鹤间:BAAAKgAECggIEQAAAA==.',['白牛']='白牛青汁:BAAAKgAECgcIDwAAAA==.',['白胡']='白胡子老爹:BAAAKgAECgcICQAAAA==.',['真靈']='真靈行者無疆:BAAAKgADCgcIBwAAAA==.',['睡得']='睡得非常早:BAABKgAFFH8KAAIaAAYIChx+BACoAQAaAAYIChx+BACoAQAAAA==.',['睿知']='睿知:BAAAKgAECgYIBgAAAA==.',['神龙']='神龙大侠阿宝:BAAAKgADCgcIBwAAAA==.',['秋心']='秋心拆两半:BAABKgAECn8xAAMNAAgINha3ZgDNAQANAAgIcBO3ZgDNAQAeAAgIQhFiHwBcAQAAAA==.',['笨笨']='笨笨爱吃肉:BAAAKgAECgMIAwAAAA==.',['简单']='简单二号:BAAAKgAECggICQAAAA==.简单亿点:BAABKgAFFH8HAAIeAAcInhbhBgCuAQAeAAcInhbhBgCuAQAAAA==.',['糖果']='糖果:BAAAKgADCggICQAAAA==.',['紫电']='紫电:BAAAKgADCgEIAQAAAA==.',['紫罗']='紫罗兰图腾:BAAAKgAECgUICgAAAA==.',['絕怼']='絕怼铃木:BAAAKgADCgMIAwAAAA==.',['絕懟']='絕懟零下:BAAAKgAECgQIBAAAAA==.',['红曜']='红曜石:BAAAKgADCgEIAgAAAA==.',['绝对']='绝对零下:BAAAKgADCggIAwAAAA==.绝对零度:BAAAKgADCggICAAAAA==.',['绿谷']='绿谷:BAAAKgAECgcIDQAAAA==.绿谷无情:BAAAKgAECggIEAAAAA==.绿谷风情:BAABKgAECn8YAAIKAAgIkyAeEQBlAgAKAAgIkyAeEQBlAgAAAA==.',['羁绊']='羁绊达成:BAAAKgADCgYIBgAAAA==.',['美女']='美女抓宝宝:BAABKgAFFH8GAAIEAAYIzgvnGQAdAQAEAAYIzgvnGQAdAQAAAA==.',['美如']='美如花赛天仙:BAABKgAECn8UAAIBAAgIbxWUHwCuAQABAAgIbxWUHwCuAQAAAA==.',['美娅']='美娅:BAAAKgAECgUIBQAAAA==.',['翡月']='翡月:BAAAKgAECgYIBwAAAA==.',['聂小']='聂小倩丶:BAAAKgADCgQIBAAAAA==.',['肝道']='肝道夫:BAAAKgAECgQIBgAAAA==.',['胆顾']='胆顾宁:BAAAKgADCgcIEAAAAA==.',['艾利']='艾利西亚:BAABKgAFFH8IAAIEAAgItRtwBQAgAgAEAAgItRtwBQAgAgAAAA==.',['艾卡']='艾卡西亚:BAAAKgAFFAgIAQAAAA==.',['艾尔']='艾尔艾尔圣光:BAAAKgAECgQIBAAAAA==.',['芊芊']='芊芊吖啊:BAAAKgAFFAQIBAAAAA==.',['芝士']='芝士菌:BAAAKgAECgEIAgAAAA==.',['花之']='花之翼:BAAAKgAECgMIAwAAAA==.',['苍之']='苍之深渊:BAAAKgADCgEIAwAAAA==.',['苏沐']='苏沐橙:BAAAKgAECgQIBAAAAA==.',['若言']='若言誓言:BAABKgAFFH8GAAIfAAYIdRjsDAB+AQAfAAYIdRjsDAB+AQAAAA==.',['苹熊']='苹熊美奈子:BAAAKgADCgIIAgAAAA==.',['菲伦']='菲伦:BAACKgAFFH8aAAMMAAQIpBj/EwDmAAAMAAQIpBj/EwDmAAALAAMIJxEkEwCTAAAqAAQKfyQAAwsACAhqIIcaAC4CAAsACAhDHYcaAC4CAAwABwjIHBwhAOwBAAAA.',['萨鲁']='萨鲁法尔大王:BAABKgAFFH8LAAMVAAgINBlbBwDzAAAVAAcIuRdbBwDzAAATAAQIGhlTGwDoAAAAAA==.',['蛮蛮']='蛮蛮一片荒:BAAAKgAECgMIAwAAAA==.',['血腥']='血腥之王:BAABKgAFFH8IAAMeAAQIfw5oDQCcAAANAAMI+gsOKwC7AAAeAAQIfw5oDQCcAAAAAA==.血腥之魔:BAAAKgAECgcICAAAAA==.',['被告']='被告:BAAAKgAECgcICAAAAA==.',['被圣']='被圣光晒伤了:BAABKgAFFH8GAAINAAYIzhCuIwBdAQANAAYIzhCuIwBdAQAAAA==.',['要乐']='要乐奈樣:BAAAKgAECgQIBAABKgAFFAQICwARANAkAA==.',['见崎']='见崎鸣樣:BAAAKgAECggIDwAAAA==.',['豪龙']='豪龙胆:BAAAKgADCgEIAQAAAA==.',['赞佩']='赞佩里尼:BAAAKgADCggICAAAAA==.',['赤叶']='赤叶萌香:BAAAKgAECgUIBQAAAA==.',['赫莱']='赫莱森:BAAAKgADCggICAAAAA==.',['那个']='那个奇士:BAAAKgAECggICwAAAA==.',['醉舞']='醉舞仙疯:BAAAKgAECgQIBgAAAA==.',['野啊']='野啊:BAAAKgADCgUIBQAAAA==.',['钱多']='钱多拿来烧:BAAAKgADCggIDAAAAA==.',['铠塚']='铠塚霙樣:BAACKgAFFH8LAAIRAAMI0CQZAgA+AQARAAMI0CQZAgA+AQAqAAQKfx8AAhEACAg+H3YEAEcCABEACAg+H3YEAEcCAAAA.',['银翼']='银翼凶星:BAAAKgAECgIIAgAAAA==.',['键盘']='键盘侠:BAAAKgADCggICAAAAA==.',['长崎']='长崎素世樣:BAAAKgAECgUICwABKgAFFAQICwARANAkAA==.',['阿卡']='阿卡迪亚思:BAAAKgAFFAQIBAAAAA==.',['随遇']='随遇丶而安:BAAAKgAECgYIDQAAAA==.',['隠隠']='隠隠莋痛:BAABKgAECn8VAAMNAAgIGCKNIgCQAgANAAgIGCKNIgCQAgADAAgIgxyDEQDvAQAAAA==.',['雪尽']='雪尽苍穹:BAAAKgAECgEIAgAAAA==.',['雪满']='雪满天飞:BAABKgAECn8bAAIZAAgIqBMFDwCZAQAZAAgIqBMFDwCZAQAAAA==.',['霸气']='霸气雄途:BAABKgAECn8XAAIJAAgIhxNDHgBZAQAJAAgIhxNDHgBZAQAAAA==.',['静女']='静女如英:BAAAKgADCgIIAgAAAA==.静女桃夭:BAAAKgADCgIIAgAAAA==.',['须丶']='须丶佐:BAAAKgADCgEIAQAAAA==.',['飞天']='飞天神小猪:BAAAKgADCgIIAgAAAA==.',['香菜']='香菜丸子:BAAAKgAFFAMIAwAAAA==.',['高松']='高松灯樣:BAABKgAECn8WAAMKAAYI4xr+QAByAQAKAAYI4xr+QAByAQAIAAYI6RZGIwA1AQABKgAFFAQICwARANAkAA==.',['魂火']='魂火:BAABKgAFFH8GAAIgAAYITyEiBADbAQAgAAYITyEiBADbAQAAAA==.',['鲜花']='鲜花缤纷:BAABKgAFFH8IAAIFAAMIoAF4WABJAAAFAAMIoAF4WABJAAAAAA==.',['麦克']='麦克雷:BAABKgAFFH8JAAIJAAMIkAFHJgBYAAAJAAMIkAFHJgBYAAAAAA==.',['麦兜']='麦兜武士猫:BAAAKgAECgIIAgAAAA==.',['黄汪']='黄汪汪冠名:BAAAKgAFFAQIBAAAAA==.',['黎明']='黎明之剑:BAAAKgAECgUIBQAAAA==.',['黑手']='黑手大人:BAAAKgADCgQIBAAAAA==.',['黑木']='黑木丶黑木:BAAAKgAFFAIIBAABKgAFFAgIUAAdABcmAA==.',['龍帝']='龍帝:BAAAKgAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end