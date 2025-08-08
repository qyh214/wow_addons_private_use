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
 local lookup = {'Priest-Discipline','Priest-Shadow','Priest-Holy','Shaman-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Brewmaster','Monk-Windwalker','Shaman-Enhancement','Shaman-Elemental','Mage-Arcane','Warrior-Arms','Warlock-Destruction','Mage-Fire','Warrior-Fury','Druid-Restoration','Druid-Balance','Monk-Mistweaver','Paladin-Protection','Druid-Guardian','Mage-Frost','Paladin-Retribution','Unknown-Unknown','DeathKnight-Unholy','DeathKnight-Frost','Warrior-Protection','Warlock-Affliction','Warlock-Demonology','DemonHunter-Havoc',}; local provider = {region='CN',realm='火羽山',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Ailc:BAAAKgAECgEIAQAAAA==.',Bo='Bonnie:BAAAKgADCgEIAQAAAA==.',Cr='Cristina:BAAAKgAFFAQIBAAAAA==.',De='Deepsee:BAAAKgAECgMIAwAAAA==.',Ev='Evilkiller:BAAAKgAFFAUIBAAAAA==.',Fr='Franklin:BAAAKgAECgUIBQAAAA==.',Gi='Gimbe:BAAAKgAFFAgIAgAAAA==.',Ha='Hakikor:BAAAKgADCgIIAgAAAA==.',Je='Jeanerent:BAACKgAFFH8XAAMBAAQIGw2gEwDCAAABAAQIGw2gEwDCAAACAAEIGyEhIABkAAAqAAQKfyQAAwEACAgUHU8VABoCAAEACAgUHU8VABoCAAMAAgiLHOWGAFEAAAAA.',Kc='Kckiiris:BAABKgAFFH8IAAIDAAgIABWdBAD6AQADAAgIABWdBAD6AQAAAA==.',Lo='Love:BAAAKgAECgMIAwAAAA==.',Om='Omimi:BAAAKgAFFAQIAgAAAA==.',Ra='Rayun:BAAAKgAECgQIBAAAAA==.',Su='Superrailgun:BAABKgAFFH8GAAIEAAIIsREMIgB1AAAEAAIIsREMIgB1AAAAAA==.',Tm='Tmto:BAAAKgAECgQIBwAAAA==.',['一个']='一个人丶:BAAAKgADCgIIAgAAAA==.',['一笑']='一笑风一:BAAAKgADCggICAAAAA==.',['一箭']='一箭倾心:BAABKgAECn8bAAMFAAgIPSIALgA8AgAFAAgI+R0ALgA8AgAGAAgIGR9OJAC3AQAAAA==.',['三戒']='三戒圣:BAAAKgAECgUIDgAAAA==.',['三系']='三系都废:BAAAKgAFFAYIBAAAAA==.',['不小']='不小:BAAAKgADCgUIBQAAAA==.',['世界']='世界斑斑:BAACKgAFFH8FAAMGAAQIywucMwCjAAAGAAQIywucMwCjAAAFAAEIyADzUwAcAAAqAAQKfxsAAwUABwiPEyJsAG4BAAUABwiPEyJsAG4BAAYABgi2DflTAM0AAAAA.',['世间']='世间:BAAAKgAFFAIIAgAAAA==.',['两全']='两全法:BAACKgAFFH8RAAIHAAMIQhURBAC3AAAHAAMIQhURBAC3AAAqAAQKfxUAAgcACAi9GBYLAKcBAAcACAi9GBYLAKcBAAEqAAUUCAgIAAgAuQsA.',['丨空']='丨空寂丶:BAAAKgADCggICAAAAA==.',['丶不']='丶不灭决心:BAAAKgADCggICAAAAA==.',['丶文']='丶文老师:BAACKgAFFH8KAAIEAAMIfxIyIACXAAAEAAMIfxIyIACXAAAqAAQKfzMABAQACAgoHcMmAPMBAAQACAgoHcMmAPMBAAkABAh1BSI5AIoAAAoAAQgAAAeHAAAAAAAA.',['丶沐']='丶沐月:BAAAKgAECgYIBgAAAA==.',['丶糯']='丶糯米多:BAAAKgAECgEIAQAAAA==.',['丹妮']='丹妮丝:BAABKgAFFH8HAAIDAAcIIxV+BgCfAQADAAcIIxV+BgCfAQAAAA==.',['乐爷']='乐爷猎:BAAAKgADCgEIAQAAAA==.',['乖巧']='乖巧的糖喵喵:BAAAKgAFFAgIAgAAAA==.',['九阕']='九阕梦华:BAAAKgAECggIDQAAAA==.',['云泽']='云泽哥:BAABKgAFFH8GAAIEAAYIUQ4kFAA2AQAEAAYIUQ4kFAA2AQAAAA==.',['云端']='云端的灯塔:BAABKgAFFH8IAAILAAMI1QJWIgBwAAALAAMI1QJWIgBwAAAAAA==.',['五五']='五五开:BAABKgAFFH8IAAIMAAgIUyBLAQCxAgAMAAgIUyBLAQCxAgAAAA==.',['以德']='以德伏牛:BAAAKgAECgUIEQAAAA==.',['仲未']='仲未够啊:BAAAKgADCggICAAAAA==.',['你是']='你是我的碗:BAAAKgAFFAEIAQAAAA==.',['倾城']='倾城斩月:BAAAKgADCggIGQAAAA==.',['倾盆']='倾盆大雨:BAAAKgAECgEIAQAAAA==.',['像个']='像个人:BAAAKgAFFAIIAgAAAA==.',['元気']='元気満満:BAABKgAFFH8GAAINAAYIgRzzDgCgAQANAAYIgRzzDgCgAQAAAA==.',['兔子']='兔子发言人:BAAAKgAECgYIBgAAAA==.',['冯宝']='冯宝宝:BAABKgAFFH8IAAINAAgI8hvIAwBwAgANAAgI8hvIAwBwAgAAAA==.',['冰冰']='冰冰凉红茶:BAAAKgAECggICAAAAA==.',['冰凝']='冰凝瑞雪:BAAAKgADCgYIBgAAAA==.',['冰火']='冰火奥义:BAABKgAECn8YAAIOAAgI8iJlEQCPAgAOAAgI8iJlEQCPAgABKgAFFAgIDAALACITAA==.',['出来']='出来找妹子的:BAABKgAFFH8IAAIPAAgIdgukBgATAgAPAAgIdgukBgATAgAAAA==.',['刘小']='刘小德:BAAAKgADCgUIBQAAAA==.刘小贼:BAAAKgADCggICAAAAA==.',['初始']='初始丶绮罗香:BAACKgAFFH8IAAIPAAYICBOFCQCjAQAPAAYICBOFCQCjAQAqAAQKfxYAAg8ACAjdHrwYAEUCAA8ACAjdHrwYAEUCAAAA.',['功夫']='功夫女孩:BAAAKgAECggICQAAAA==.功夫法神:BAAAKgAFFAYIBAAAAA==.',['十六']='十六夜:BAAAKgADCgQIBAAAAA==.',['午后']='午后红茶:BAAAKgAECgYIBgAAAA==.',['半杯']='半杯冰美式:BAAAKgADCgMIAwAAAA==.',['南山']='南山神:BAAAKgAECggICAAAAA==.南山门:BAAAKgAECgcIBwAAAA==.',['厄鬼']='厄鬼椪:BAAAKgAFFAQIBAAAAA==.',['叙利']='叙利亚招魂师:BAABKgAFFH8UAAMQAAYIJxKDAgBwAQAQAAYIJxKDAgBwAQARAAUIgBdxDQAIAQAAAA==.',['口函']='口函天宪:BAABKgAFFH8SAAINAAYIAhubEgBzAQANAAYIAhubEgBzAQAAAA==.',['只会']='只会玩蓝猫:BAABKgAFFH8MAAMRAAQIFiFCLwDWAAARAAQIFiFCLwDWAAAQAAQI4Qw6DgC/AAAAAA==.',['可凡']='可凡:BAAAKgADCgcIBwAAAA==.',['可爱']='可爱的小钱钱:BAAAKgAFFAIIAQAAAA==.',['叹息']='叹息风中:BAAAKgAFFAIIAwAAAA==.',['叽叽']='叽叽嘎嘎:BAAAKgAFFAQIBAAAAA==.',['吕布']='吕布:BAAAKgAECgMIAQAAAA==.',['呆毛']='呆毛猪猪:BAABKgAFFH8IAAILAAgI6BRFBgAmAgALAAgI6BRFBgAmAgAAAA==.',['呗呗']='呗呗僧:BAABKgAFFH8GAAISAAYIKhmlCgB9AQASAAYIKhmlCgB9AQAAAA==.',['呼你']='呼你熊脸:BAAAKgAECggIEgAAAA==.',['哒哒']='哒哒么:BAAAKgADCgEIAgAAAA==.',['喵喵']='喵喵爱你哟:BAAAKgAECgYIBgAAAA==.',['喷火']='喷火龙丶:BAABKgAFFH8FAAIOAAUIcyX9BAC3AQAOAAUIcyX9BAC3AQAAAA==.',['回忆']='回忆丶终难忘:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光之炎:BAAAKgAFFAcIBAAAAA==.',['圣骑']='圣骑:BAABKgAFFH8GAAITAAYI9RG6DQAgAQATAAYI9RG6DQAgAQAAAA==.',['坏女']='坏女人:BAAAKgAECgEIAgAAAA==.',['基罗']='基罗格:BAABKgAFFH8GAAINAAYI5yKyBgACAgANAAYI5yKyBgACAgAAAA==.',['复仇']='复仇之焰:BAAAKgADCgMIAwAAAA==.',['多唻']='多唻米:BAAAKgADCggIEgAAAA==.',['多来']='多来咪:BAAAKgADCgQICAAAAA==.',['夜侠']='夜侠:BAAAKgAECgQIBAAAAA==.',['夜影']='夜影柳柳:BAACKgAFFH8SAAIUAAMILBTEAgChAAAUAAMILBTEAgChAAAqAAQKfyQAAxQACAiRG0sIAPcBABQACAiRG0sIAPcBABAAAQiPBPSMACkAAAAA.',['夜神']='夜神:BAAAKgAECgcIDQAAAA==.',['夜邪']='夜邪:BAAAKgAECgUICwAAAA==.',['大婉']='大婉婉熊妞妞:BAAAKgAECgcICwAAAA==.',['大脚']='大脚德:BAAAKgAECgMIAwAAAA==.',['天下']='天下第一战:BAAAKgAFFAMIAQABKgAFFAgIEwATAPkTAA==.',['奶牛']='奶牛奶奶:BAACKgAFFH8LAAIEAAMIExggFwC7AAAEAAMIExggFwC7AAAqAAQKfyQAAwQACAj5FikwALgBAAQACAj5FikwALgBAAoABAigESMiALIAAAAA.',['姬丝']='姬丝秀忒:BAABKgAFFH8FAAINAAMIlw9rLgC0AAANAAMIlw9rLgC0AAAAAA==.',['子夜']='子夜无涯:BAAAKgAECgYICgAAAA==.',['孤独']='孤独小萌萌:BAABKgAECn8VAAILAAgImhoSIwDfAQALAAgImhoSIwDfAQAAAA==.',['宇智']='宇智波白华:BAAAKgAFFAgIAgAAAA==.',['安东']='安东尼:BAAAKgADCgQIBAAAAA==.',['容容']='容容的饲养员:BAAAKgADCggIDAAAAA==.',['寥若']='寥若晨星:BAAAKgAECgEIAQAAAA==.寥若晨汐:BAABKgAECn8aAAIVAAgIQSE4EgBsAgAVAAgIQSE4EgBsAgAAAA==.',['寸板']='寸板:BAAAKgAECggICQAAAA==.',['小小']='小小丶小猎:BAAAKgAFFAMIAwAAAA==.',['小洛']='小洛洛:BAABKgAFFH8KAAIFAAYIxxlREgBkAQAFAAYIxxlREgBkAQAAAA==.',['小狂']='小狂狂:BAAAKgAFFAQIBAAAAA==.',['小蝦']='小蝦米:BAAAKgADCgEIAQAAAA==.',['小逢']='小逢逢:BAAAKgAECggICAAAAA==.',['己随']='己随风:BAAAKgAECggIBwAAAA==.',['布伊']='布伊索尔:BAAAKgAECgMIAwAAAA==.',['帅妞']='帅妞:BAAAKgAECgQIBwAAAA==.',['帕琪']='帕琪维克:BAAAKgAECgcIBwAAAA==.',['幸运']='幸运的萨鲁曼:BAAAKgAECggICAAAAA==.',['幻影']='幻影狼洛根:BAAAKgADCggIEwAAAA==.',['幽霜']='幽霜:BAAAKgAECggIDwAAAA==.',['库丘']='库丘林:BAAAKgAECggIDQAAAA==.',['开门']='开门小能手:BAAAKgAECgQIBAAAAA==.',['张利']='张利霞:BAAAKgADCggIDQAAAA==.',['张小']='张小美:BAAAKgAECgUIBQAAAA==.张小飒:BAAAKgAECggIDAAAAA==.',['彝族']='彝族酒仙:BAAAKgAECggICQAAAA==.',['徐电']='徐电电:BAABKgAFFH8FAAIGAAUIeB5gEABjAQAGAAUIeB5gEABjAQAAAA==.',['御前']='御前侍卫:BAAAKgAECggIAwAAAA==.',['忧伤']='忧伤不会的:BAAAKgAFFAgIAQAAAA==.',['怒斩']='怒斩高富帅:BAAAKgAECgUIBQAAAA==.',['总冠']='总冠军:BAABKgAFFH8MAAMKAAMItxXADADEAAAJAAMI8xOgCADiAAAKAAMIkRLADADEAAAAAA==.',['悠幽']='悠幽:BAAAKgAECggIDwAAAA==.',['懿可']='懿可:BAABKgAFFH8HAAMHAAQIiBd2AwDHAAAHAAQIjBV2AwDHAAAIAAMIShLYHQB7AAAAAA==.',['我乀']='我乀千与千寻:BAABKgAECn8XAAIVAAgIuxFjEAByAQAVAAgIuxFjEAByAQAAAA==.',['我有']='我有两只猫:BAABKgAECn8xAAIEAAgIFCHUFABXAgAEAAgIFCHUFABXAgAAAA==.',['打死']='打死不练牛:BAABKgAFFH8IAAIWAAgIZRluCAA9AgAWAAgIZRluCAA9AgAAAA==.',['把快']='把快乐还给我:BAAAKgAECgMIAwAAAA==.',['拉帝']='拉帝欧斯:BAAAKgAFFAQIBAAAAA==.',['拳头']='拳头君丶:BAAAKgADCgcIBwAAAA==.',['新钙']='新钙中钙:BAAAKgADCggICAAAAA==.',['无雨']='无雨恋风:BAAAKgAECggICAAAAA==.',['明懿']='明懿香:BAAAKgAECgYIDAAAAA==.',['星空']='星空下的美好:BAAAKgAECggICAAAAA==.',['是糖']='是糖乀喵喵呀:BAABKgAECn8XAAIPAAgIEBHOKgCNAQAPAAgIEBHOKgCNAQABKgAFFAgIKwAPAC4VAA==.是糖喵喵啊:BAABKgAECn8VAAIBAAgIAxq4EgAMAgABAAgIAxq4EgAMAgAAAA==.',['晴空']='晴空无垠:BAAAKgAECgEIAQAAAA==.',['暴风']='暴风老人物:BAACKgAFFH8QAAITAAQIVhSNGAC0AAATAAQIVhSNGAC0AAAqAAQKf0EAAxMACAjSEEIMAF4BABMACAjSEEIMAF4BABYAAwinA6kiAUUAAAAA.',['最后']='最后的工具人:BAABKgAFFH8GAAISAAYIcwrLEgATAQASAAYIcwrLEgATAQAAAA==.',['有洁']='有洁僻的细菌:BAAAKgADCggICAAAAA==.',['术猫']='术猫儿:BAAAKgAECgUIBQAAAA==.',['朽木']='朽木冬子:BAAAKgAFFAYIBAAAAA==.',['李太']='李太医:BAABKgAFFH8NAAMDAAMICBoIIQDCAAADAAMICBoIIQDCAAACAAMIlA6IEACwAAAAAA==.',['李沐']='李沐恩:BAABKgAFFH8LAAIIAAMImxFNDADLAAAIAAMImxFNDADLAAAAAA==.',['李鎏']='李鎏昕:BAAAKgAECgQICAAAAA==.',['桑妮']='桑妮:BAABKgAFFH8FAAIWAAMIpx0/OAALAQAWAAMIpx0/OAALAQAAAA==.',['樊笼']='樊笼之鸟:BAABKgAFFH8eAAIWAAYIkCO1AAAKAgAWAAYIkCO1AAAKAgAAAA==.',['此奶']='此奶不详之罩:BAAAKgAECgIIAgAAAA==.',['歲月']='歲月龍龍:BAAAKgAECggICAAAAA==.',['永远']='永远深夜:BAAAKgAFFAYIBAAAAA==.',['沙华']='沙华凋零:BAAAKgAFFAgIAgAAAA==.',['沧海']='沧海遗粟邓:BAAAKgAFFAgIAwAAAA==.',['洋葱']='洋葱头:BAAAKgADCggIHgAAAA==.',['洛洛']='洛洛娜:BAABKgAFFH8UAAMRAAYIJRd+HwAjAQARAAQI1RZ+HwAjAQAQAAUIYxSnFQD0AAAAAA==.',['洪猫']='洪猫:BAAAKgADCgIIAgAAAA==.',['浓腐']='浓腐酸泉:BAAAKgAECggICAAAAA==.',['涓涓']='涓涓细流:BAAAKgADCgMIBQAAAA==.',['滚来']='滚来滚去香肠:BAABKgAECn8UAAIWAAgIABAnfACfAQAWAAgIABAnfACfAQAAAA==.',['漫天']='漫天枫痕:BAAAKgAFFAYIAgAAAA==.',['潮柒']='潮柒洛:BAABKgAFFH8IAAIEAAgIcRzaAgA7AgAEAAgIcRzaAgA7AgABKgAFFAgIEgANAAIbAA==.',['熊二']='熊二娃:BAABKgAFFH8IAAISAAgIoQvfCACgAQASAAgIoQvfCACgAQAAAA==.',['燃烧']='燃烧卡:BAABKgAECn8lAAIOAAgIYAm7IAAuAQAOAAgIYAm7IAAuAQAAAA==.',['爱丝']='爱丝鸡磨人:BAACKgAFFH8MAAMFAAYIzRRGHAC4AAAFAAMIUAhGHAC4AAAGAAUIVBlHPACHAAAqAAQKfyIAAwUACAgAGchWAKwBAAUACAgaFMhWAKwBAAYAAghrJUxlAMYAAAAA.',['牛油']='牛油果:BAAAKgAECggICQAAAA==.',['牛犇']='牛犇犇丶:BAAAKgAECgYIBgAAAA==.',['牛肉']='牛肉干的妈妈:BAABKgAFFH8IAAIDAAMIcwsCGwB7AAADAAMIcwsCGwB7AAAAAA==.牛肉干的妹妹:BAAAKgAFFAMIBAAAAA==.牛肉干的爸爸:BAAAKgAFFAIIAgAAAA==.',['牛逼']='牛逼坏了:BAAAKgAECggIEwAAAA==.',['狂暴']='狂暴怒怒:BAABKgAECn9BAAMPAAgIZCJdCQCpAgAPAAgIZCJdCQCpAgAMAAEIsRnkVgBMAAAAAA==.',['独角']='独角仙:BAAAKgADCggICgAAAA==.',['猜猜']='猜猜:BAAAKgAECgEIAQAAAA==.',['王力']='王力宏:BAABKgAECn85AAQDAAgILB7dGAD6AQADAAcIKh/dGAD6AQACAAgI/hPqIQDGAQABAAgIBhRJIACbAQABKgAFFAgIBAAXAAAAAA==.',['王宝']='王宝琛:BAAAKgAECgUIBwAAAA==.',['王靖']='王靖玟:BAAAKgAECgMIAwAAAA==.',['环境']='环境一大飞哥:BAAAKgAECgQIBAAAAA==.',['班门']='班门弄大斧:BAAAKgAFFAMIAQAAAA==.',['痛苦']='痛苦女王:BAAAKgAECggICAAAAA==.',['白生']='白生生:BAAAKgAECggICAAAAA==.',['白袍']='白袍干豆腐:BAAAKgAECgcICQAAAA==.',['百步']='百步剑方:BAAAKgAECgcICQAAAA==.',['皮卡']='皮卡丷秋:BAAAKgADCgIIAgAAAA==.',['睿爹']='睿爹:BAAAKgAECggICAAAAA==.',['神賜']='神賜:BAAAKgADCggIDgAAAA==.',['童飘']='童飘云:BAAAKgADCgMIAwABKgAFFAgICgAVALglAA==.',['红日']='红日一号:BAAAKgADCggICAAAAA==.',['红的']='红的发紫:BAABKgAECn8dAAIYAAgIxhoOIgAHAgAYAAgIxhoOIgAHAgAAAA==.',['绵绵']='绵绵冰:BAAAKgAECgYIBgAAAA==.',['绿豆']='绿豆大的胆:BAACKgAFFH8xAAIZAAYISheSBQBMAQAZAAYISheSBQBMAQAqAAQKf1cAAhkACAiWIkUDAJUCABkACAiWIkUDAJUCAAAA.',['羽落']='羽落梵尘:BAAAKgAECggIEQAAAA==.',['聪明']='聪明的峰峰:BAAAKgAFFAgIBAAAAA==.',['胡不']='胡不归兮:BAAAKgAECgMIAwAAAA==.',['胺杀']='胺杀者:BAAAKgAECgQIBAAAAA==.',['脱色']='脱色牛仔裤:BAAAKgAECgUIBQAAAA==.',['花海']='花海:BAAAKgAECgUICQAAAA==.',['花田']='花田灬月下:BAAAKgAECgUIBQAAAA==.',['茂爷']='茂爷的召唤:BAAAKgADCggICgAAAA==.茂爷的图腾:BAABKgAFFH8FAAIEAAMI8wSjPQCRAAAEAAMI8wSjPQCRAAAAAA==.茂爷的审判:BAAAKgAECgEIAQAAAA==.',['茂的']='茂的眼棱:BAAAKgAECgIIAwAAAA==.',['草飞']='草飞机:BAAAKgAECgEIAQAAAA==.',['莎拉']='莎拉菌:BAAAKgADCggICgAAAA==.',['莫狸']='莫狸:BAAAKgADCggICwAAAA==.',['莫若']='莫若不在:BAAAKgADCgMIAwAAAA==.',['莽夫']='莽夫:BAACKgAFFH81AAMMAAgIuCC5AQCMAgAMAAgIjyC5AQCMAgAPAAQITBagGwCpAAAqAAQKfywABAwACAj7JAEJAIgCAAwACAjoJAEJAIgCAA8ABwhEH0dCAGYBABoAAQhkAAAAAAAAAAAA.',['萌萌']='萌萌小独孤:BAACKgAFFH8ZAAQbAAUIDyNiAwAZAQAbAAQIPiJiAwAZAQAcAAQIuiIwBgAWAQANAAIIWx1JHwCWAAAqAAQKfy0AAxsACAggJR8BAL0CABsACAggJR8BAL0CABwAAQhqIQF/AC8AAAAA.萌萌小独孤丶:BAACKgAFFH8wAAIGAAgIySPSAADbAgAGAAgIySPSAADbAgAqAAQKfxoAAgYACAheJE8EANcCAAYACAheJE8EANcCAAAA.',['萨拉']='萨拉峻:BAAAKgADCggIEgAAAA==.',['蓝翔']='蓝翔技工羽毛:BAAAKgAECggICAAAAA==.',['薄荷']='薄荷冰美式:BAAAKgAECggIEwAAAA==.',['虎豆']='虎豆豆:BAACKgAFFH8TAAMJAAYI1A5SAgCkAQAJAAYI1A5SAgCkAQAEAAYIxiRKCgCiAQAqAAQKfyAAAgQACAgdHvgmAPIBAAQACAgdHvgmAPIBAAAA.',['蝎子']='蝎子萊萊:BAAAKgADCgIIAgAAAA==.',['術士']='術士大叔邓:BAAAKgAECgUIBQAAAA==.',['西夏']='西夏啤酒:BAAAKgADCggICQAAAA==.',['计本']='计本六班:BAAAKgAECgUIBQAAAA==.',['诸葛']='诸葛亮:BAAAKgAFFAEIAQAAAA==.',['路妃']='路妃:BAAAKgAECgcICgAAAA==.',['躺下']='躺下就呲花:BAABKgAFFH8HAAIaAAcIVQ+nAwB0AQAaAAcIVQ+nAwB0AQAAAA==.',['轩辕']='轩辕乔丹哥:BAAAKgADCggICgAAAA==.轩辕乔丹歌:BAAAKgAECgMIAwAAAA==.',['轻歌']='轻歌丶挽妆:BAABKgAFFH8FAAIRAAUIbRnZDgCvAQARAAUIbRnZDgCvAQAAAA==.',['辣椒']='辣椒皮皮:BAACKgAFFH8GAAIWAAQI6RBVMwCkAAAWAAQI6RBVMwCkAAAqAAQKfzwAAhYACAiwJMwVALECABYACAiwJMwVALECAAAA.',['还在']='还在毛:BAAAKgAFFAQIBAAAAA==.',['邪战']='邪战:BAABKgAECn8WAAIaAAgIXQWaOgB2AAAaAAgIXQWaOgB2AAAAAA==.',['野火']='野火:BAAAKgAECgYIBgAAAA==.',['野百']='野百合:BAAAKgADCggICAAAAA==.',['钟吾']='钟吾奇奇:BAABKgAECn8XAAITAAgIBReZFADSAQATAAgIBReZFADSAQAAAA==.钟吾小德:BAAAKgAECgYIBgAAAA==.钟吾小熊:BAAAKgAECgIIAgAAAA==.钟吾飞雪:BAABKgAECn8nAAMVAAgIsBftJQDpAQAVAAgIsBftJQDpAQALAAgIkw5PPwBFAQAAAA==.',['露营']='露营必须酒:BAAAKgAFFAQIBAAAAA==.',['青青']='青青国王:BAABKgAFFH8GAAIGAAIIEwmYRQBpAAAGAAIIEwmYRQBpAAAAAA==.',['飒拉']='飒拉俊:BAAAKgADCgMIAwAAAA==.',['飘落']='飘落枫叶:BAAAKgAECgEIAgAAAA==.',['飞不']='飞不动的猫:BAAAKgAECgEIAQAAAA==.',['飞花']='飞花令:BAAAKgAECggICAAAAA==.',['飞飞']='飞飞:BAABKgAFFH8GAAIRAAYI9SRwAAAYAgARAAYI9SRwAAAYAgAAAA==.',['高速']='高速婆婆:BAAAKgADCgUIBQAAAA==.',['魔王']='魔王大人:BAABKgAFFH8HAAIFAAQItA5kHQAaAQAFAAQItA5kHQAaAQAAAA==.',['黄帝']='黄帝昭曰:BAAAKgAECgcIBwAAAA==.',['黄昏']='黄昏的凄美:BAAAKgAECgIIAgAAAA==.',['黑呆']='黑呆毛:BAAAKgAECgMIAwABKgAFFAgIDQAdAIAbAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end