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
 local lookup = {'Priest-Discipline','Druid-Balance','DeathKnight-Blood','Druid-Restoration','Mage-Frost','Warlock-Affliction','Paladin-Retribution','Rogue-Assassination','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Hunter-BeastMastery','Druid-Feral','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Hunter-Marksmanship','Shaman-Elemental','Shaman-Restoration','Druid-Guardian','Priest-Shadow','Priest-Holy','Warrior-Protection','Warrior-Arms','DemonHunter-Havoc','Unknown-Unknown','Evoker-Devastation','DeathKnight-Frost','Mage-Fire','Rogue-Outlaw','Warrior-Fury','Paladin-Protection','Paladin-Holy','Mage-Arcane',}; local provider = {region='CN',realm='艾莫莉丝',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Allen:BAAAKgAECgEIAQAAAA==.',An='Annde:BAAAKgAFFAEIAQAAAA==.',At='Atubo:BAAAKgAECgMIAwAAAA==.',Be='Behei:BAAAKgAECgEIAQAAAA==.',Ca='Carryorange:BAAAKgAFFAIIAgAAAA==.',Co='Comr:BAAAKgADCggICAAAAA==.',Cr='Crimanal:BAAAKgAFFAYIAQAAAA==.',Da='Daddy:BAABKgAFFH8IAAIBAAgIfReLAwAmAgABAAgIfReLAwAmAgABKgAFFAgIEgACAIIUAA==.',Dz='Dzsz:BAAAKgAFFAYIAgAAAA==.',Em='Emprorpan:BAABKgAECn8nAAIDAAgIahXLFwCZAQADAAgIahXLFwCZAQAAAA==.',Ex='Exertresidua:BAAAKgAECggICAAAAA==.Extreme:BAAAKgAECgcIDgAAAA==.',Fa='Faerie:BAAAKgAECggIDAAAAA==.',Fr='Friedrichix:BAAAKgADCgEIAgAAAA==.',Jo='Jonah:BAAAKgADCggICAAAAA==.',Ko='Kotori:BAAAKgADCgIIAgAAAA==.',Ly='Lylwlw:BAABKgAFFH8IAAMCAAgIuhUtFgBnAQACAAYIsxMtFgBnAQAEAAIIQQWGKwByAAAAAA==.',Ma='Mageslayer:BAABKgAFFH8KAAIFAAMIHxFsEgCWAAAFAAMIHxFsEgCWAAAAAA==.Magicorc:BAABKgAECn8hAAIGAAgICx2OBAA5AgAGAAgICx2OBAA5AgAAAA==.Marex:BAABKgAFFH8GAAIHAAYIixyNGwDzAAAHAAYIixyNGwDzAAAAAA==.',Mi='Missonyxla:BAAAKgADCggICAABKgAFFAgIBQAIAEkOAA==.',Mo='Mortal:BAAAKgAFFAIIAwAAAA==.',Ni='Nighwhih:BAAAKgAECgIIAgAAAA==.',Oo='Ooioi:BAAAKgAECggICAAAAA==.',Pa='Papi:BAAAKgAECgMIAwAAAA==.',Pk='Pknight:BAABKgAFFH8IAAMDAAgIHgvBFgDrAAADAAQI+AvBFgDrAAAJAAQI/Ak8GQDMAAAAAA==.',Qi='Qiqiqiq:BAAAKgADCggIDAAAAA==.',Sh='Sharkboy:BAAAKgADCggICAAAAA==.',Si='Sinon:BAAAKgADCggICAAAAA==.',St='Stjimmy:BAAAKgAFFAMIAwAAAA==.',Su='Sunblast:BAABKgAFFH8KAAMKAAYIJRcQCAD9AAALAAYItRJXFgBRAQAKAAQIzBoQCAD9AAAAAA==.',Sy='Sylphid:BAAAKgAECgIIAgAAAA==.',Ta='Tatne:BAAAKgAECgQIBwAAAA==.',Ti='Timoa:BAABKgAFFH8TAAIMAAYIeSGPCgDFAQAMAAYIeSGPCgDFAQAAAA==.',To='Toyly:BAAAKgAECggIAQAAAA==.',Tp='Tpm:BAAAKgAECgUIBQAAAA==.',['一一']='一一萌萌哒:BAACKgAFFH8FAAMCAAMI8Q1AJwCDAAACAAIIQxBAJwCDAAANAAEITgmNCQA7AAAqAAQKfyAABAIACAhuHfkhAEECAAIACAi8HPkhAEECAA0AAggqHW8nAFwAAAQAAgi1AVuYABIAAAAA.',['一不']='一不行:BAACKgAFFH8QAAMOAAYIaBGlDABbAQAOAAYIaBGlDABbAQAPAAIIMge1IwBGAAAqAAQKfxgABA8ACAirG7QbAAECAA8ACAirG7QbAAECAA4ABwhjFHQ6AFsBABAAAQjmBVgoACMAAAAA.',['一起']='一起猫喵喵:BAAAKgAFFAQIBAAAAA==.',['一路']='一路翔过:BAABKgAFFH8GAAIHAAYIqhezFgCmAQAHAAYIqhezFgCmAQAAAA==.',['一鹿']='一鹿向前:BAAAKgAECgQIBgAAAA==.',['万木']='万木霜天:BAABKgAFFH8GAAMRAAYI8g+BJADbAAARAAUItAyBJADbAAAMAAEI6RzUVwBMAAAAAA==.',['万雷']='万雷飞渡:BAAAKgAECgUICQAAAA==.',['三丶']='三丶刀:BAAAKgAECgUIBQAAAA==.',['三月']='三月三曰:BAAAKgADCgQIBAAAAA==.',['上官']='上官月半核心:BAABKgAFFH8KAAIJAAYIWRmnCACxAQAJAAYIWRmnCACxAQAAAA==.上官靈双:BAABKgAFFH8SAAIHAAgIBCARBgBfAgAHAAgIBCARBgBfAgAAAA==.',['不二']='不二鼎:BAAAKgAECggICAAAAA==.',['不笑']='不笑的朵拉:BAAAKgADCgcICwAAAA==.',['东京']='东京的夏天热:BAAAKgAECgMIAwAAAA==.',['丨五']='丨五彩凉山丶:BAABKgAFFH8HAAIHAAQIYxobDwAXAQAHAAQIYxobDwAXAQAAAA==.',['丨大']='丨大白丿:BAAAKgADCggIDgAAAA==.',['丨小']='丨小仙丨:BAAAKgADCgIIAgAAAA==.',['丨燧']='丨燧丶风丨:BAAAKgADCggICAAAAA==.',['丨魔']='丨魔丶羲丨:BAAAKgAECggICAAAAA==.',['丶亻']='丶亻昔口:BAABKgAFFH8JAAIHAAMIQRrMQQDsAAAHAAMIQRrMQQDsAAAAAA==.',['丶羊']='丶羊过小龙女:BAAAKgAECggICAAAAA==.',['丶长']='丶长脚:BAAAKgAECgYIDwAAAA==.',['丷大']='丷大海洋丷:BAAAKgAECgIIAgAAAA==.',['丷天']='丷天若澜丷:BAAAKgAFFAQIBAAAAA==.',['丷海']='丷海洋丷:BAAAKgADCggICAAAAA==.',['乘风']='乘风踏浪:BAABKgAFFH8GAAISAAYI6wmCCQAyAQASAAYI6wmCCQAyAQAAAA==.',['九头']='九头神鸟:BAAAKgAECgYICAAAAA==.',['二傻']='二傻:BAABKgAFFH8GAAIDAAYITQghGQDYAAADAAYITQghGQDYAAAAAA==.',['二哥']='二哥:BAAAKgAFFAIIAgAAAA==.',['亡之']='亡之叹息:BAAAKgAECgYIBwAAAA==.',['人形']='人形自走图腾:BAABKgAFFH8LAAITAAQIFSVqEwA7AQATAAQIFSVqEwA7AQAAAA==.',['仁小']='仁小登子:BAABKgAFFH8FAAIUAAMIWQLPDABMAAAUAAMIWQLPDABMAAAAAA==.',['他才']='他才是潘多拉:BAAAKgAFFAQIBAAAAA==.',['任性']='任性熊猫:BAAAKgAFFAQIBAABKgAFFAgIEAAVAFsKAA==.',['佛兰']='佛兰克:BAAAKgAFFAgIBAAAAA==.',['你好']='你好丑啊:BAAAKgAECgYICQAAAA==.',['你弟']='你弟突然:BAAAKgADCggIDQAAAA==.',['你望']='你望着很下饭:BAABKgAECn8hAAIWAAgIRSAyDgBbAgAWAAgIRSAyDgBbAgAAAA==.',['依然']='依然殇:BAABKgAECn8UAAIKAAcIfhZcIgB+AQAKAAcIfhZcIgB+AQAAAA==.',['修女']='修女:BAABKgAFFH8IAAIVAAMImBKCGAC4AAAVAAMImBKCGAC4AAAAAA==.',['假若']='假若时光有眼:BAAAKgAECgYICwAAAA==.',['做男']='做男人难啊:BAABKgAFFH8FAAIHAAMIKAl1XwCxAAAHAAMIKAl1XwCxAAAAAA==.',['傲视']='傲视魔天下:BAAAKgADCgIIAgAAAA==.',['充气']='充气阿勇:BAABKgAFFH8IAAMXAAQIFxmlCgC5AAAXAAQIFxmlCgC5AAAYAAQIUglHGwCxAAAAAA==.',['全需']='全需骑:BAAAKgADCgYIBgAAAA==.',['内陆']='内陆帝国:BAABKgAFFH8PAAMDAAYIOQ7VDwDBAAADAAYIOQ7VDwDBAAAJAAEIAAAhWQAAAAAAAA==.',['冬天']='冬天小鸡:BAAAKgAECgcIDAAAAA==.',['冰冰']='冰冰冷:BAAAKgAECgEIAQAAAA==.',['冰蓝']='冰蓝:BAAAKgADCggICAAAAA==.',['准备']='准备受死吧:BAABKgAFFH8GAAIZAAYIHR3KCgAfAQAZAAYIHR3KCgAfAQABKgAFFAgIEgACAIIUAA==.',['凯恩']='凯恩铁蹄:BAAAKgADCgUIBQAAAA==.',['利爪']='利爪之傲:BAACKgAFFH8oAAQCAAgImBJPCQACAgACAAgImBJPCQACAgANAAQIBA29AwDBAAAUAAQIuQQ4CwBgAAAqAAQKfy8AAg0ACAgzGIUKABMCAA0ACAgzGIUKABMCAAAA.',['刹风']='刹风:BAABKgAFFH8OAAIZAAYIah5+DAC8AQAZAAYIah5+DAC8AQABKgAFFAgIBAAaAAAAAA==.刹风之神:BAABKgAFFH8JAAMRAAYIShEQFQA7AQARAAYIcQ4QFQA7AQAMAAMIWBNLLgCdAAAAAA==.',['剑舞']='剑舞轻歌:BAAAKgAECgUIBgAAAA==.',['北丧']='北丧:BAACKgAFFH8SAAIJAAMItBUqLgDWAAAJAAMItBUqLgDWAAAqAAQKfzAAAgkACAgkHgMvAPcBAAkACAgkHgMvAPcBAAAA.',['北君']='北君:BAAAKgADCgcIBwAAAA==.',['十连']='十连出橙真君:BAABKgAFFH8GAAMJAAYI8QyrGwC7AAAJAAIITxWrGwC7AAADAAQIXQeMKgBrAAAAAA==.',['千寻']='千寻雨:BAAAKgAECgQIBAAAAA==.',['午夜']='午夜凡凡:BAAAKgAECggICAAAAA==.',['华北']='华北浪革:BAAAKgADCgIIAgAAAA==.',['卡诺']='卡诺:BAAAKgAECgcIBgAAAA==.',['卡迪']='卡迪南冥刃:BAABKgAFFH8IAAIIAAgIqxj6AwBnAgAIAAgIqxj6AwBnAgAAAA==.',['卧梅']='卧梅友闻花:BAAAKgAECgUIBgAAAA==.',['去野']='去野:BAAAKgAECgIIAgAAAA==.',['双木']='双木林:BAAAKgAFFAEIAQAAAA==.',['变态']='变态小朋友:BAAAKgAFFAIIBAAAAA==.',['可可']='可可露莉:BAAAKgAECgcIDAAAAA==.',['可爱']='可爱粉发女孩:BAAAKgAECgMIAwAAAA==.',['司命']='司命大人:BAAAKgAECgEIAQAAAA==.',['吃饭']='吃饭睡觉:BAAAKgAECgUIBQAAAA==.',['吕先']='吕先生:BAAAKgAECggIEwAAAA==.',['吭萌']='吭萌箉片:BAAAKgADCggICAAAAA==.',['呜喵']='呜喵猪:BAABKgAFFH8QAAIDAAgIqg6LBACpAQADAAgIqg6LBACpAQAAAA==.',['呮遈']='呮遈童話:BAABKgAFFH8IAAIBAAgInhg8AgAnAgABAAgInhg8AgAnAgAAAA==.',['哈尔']='哈尔扎克:BAABKgAFFH8HAAMBAAYIaR2bEQDQAAABAAYIaR2bEQDQAAAWAAEIfxJPIQBOAAAAAA==.',['哈库']='哈库哪玛塔塔:BAABKgAECn8aAAIZAAgIjhcjEgDcAQAZAAgIjhcjEgDcAQAAAA==.',['哈迪']='哈迪:BAABKgAFFH8KAAIbAAYIhBYWEwA5AQAbAAYIhBYWEwA5AQAAAA==.',['哑色']='哑色凯奇:BAAAKgAFFAgIAgAAAA==.哑色小狗:BAAAKgAECgYICgAAAA==.',['啦啦']='啦啦馨茹:BAAAKgAECgMIAwAAAA==.',['嗳洋']='嗳洋芋:BAABKgAECn8YAAIcAAgIjw8kDgBqAQAcAAgIjw8kDgBqAQAAAA==.',['四级']='四级床震:BAAAKgAECgIIAwAAAA==.',['土逗']='土逗儿:BAAAKgAECgYIBgAAAA==.',['圣光']='圣光橡皮擦:BAABKgAFFH8ZAAIHAAgIRyAKBwBYAgAHAAgIRyAKBwBYAgAAAA==.圣光的彼岸:BAAAKgAECgUIBQAAAA==.',['圣族']='圣族丨随风:BAABKgAFFH8OAAMRAAYInhQnBgAXAQARAAUIaRknBgAXAQAMAAYIUAw5MgDFAAABKgAFFAgICAAMAK4RAA==.圣族丨騎丶:BAABKgAFFH8OAAIHAAYIDh2yFAC2AQAHAAYIDh2yFAC2AQAAAA==.',['圣殿']='圣殿铁骑:BAAAKgAECggICAAAAA==.',['在睡']='在睡会:BAAAKgAECggICAAAAA==.',['坑德']='坑德鸡:BAAAKgAECgcICgAAAA==.',['坤帝']='坤帝:BAAAKgAECgYIBgAAAA==.',['城与']='城与诚:BAAAKgAECgMIBgAAAA==.',['城南']='城南花已开:BAAAKgAFFAgIBAAAAA==.',['塔兰']='塔兰基公主:BAAAKgAECgIIAgABKgAFFAgIDwAWAOgSAA==.',['墨咖']='墨咖啡:BAABKgAFFH8XAAIXAAMITwL1CwBSAAAXAAMITwL1CwBSAAAAAA==.',['夏日']='夏日回响:BAAAKgAECgMIAwAAAA==.夏日看雪:BAABKgAFFH8IAAILAAgIEhhBBQBHAgALAAgIEhhBBQBHAgAAAA==.',['夏沫']='夏沫青柠:BAAAKgAFFAQIBAAAAA==.',['夕照']='夕照神灬:BAABKgAFFH8HAAIWAAUIKRQeCgAxAQAWAAUIKRQeCgAxAQAAAA==.',['夜丨']='夜丨星语:BAAAKgAECggICAAAAA==.夜丨狐妖:BAACKgAFFH8RAAMFAAYIxB4gDgDzAAAdAAYI3x2UFgD0AAAFAAMISx8gDgDzAAAqAAQKfyIAAwUACAjqHaMcACECAAUACAjqHaMcACECAB0ABgjjCGRmANgAAAAA.',['夜丶']='夜丶青楼:BAAAKgADCggICgAAAA==.',['夜月']='夜月残影:BAAAKgAFFAQIBAAAAA==.',['夜灬']='夜灬你妹:BAABKgAFFH8MAAMMAAYI1hwMEQBvAQAMAAYI1hwMEQBvAQARAAQI6At8FAC9AAABKgAFFAgIEgACAIIUAA==.',['夜血']='夜血杀:BAABKgAECn8dAAIeAAgINBF7CwBrAQAeAAgINBF7CwBrAQAAAA==.',['大嫂']='大嫂爱插花:BAAAKgAECggICAAAAA==.',['大概']='大概是个汉子:BAABKgAECn8bAAITAAgItRWgLQDEAQATAAgItRWgLQDEAQABKgAFFAMIEQAfAJ0ZAA==.',['大牛']='大牛啊:BAAAKgADCggICAAAAA==.',['大通']='大通桥领主:BAAAKgADCgQIBAAAAA==.',['天下']='天下无恶:BAAAKgAFFAIIAgAAAA==.',['天人']='天人感应:BAABKgAFFH8KAAIHAAYIbhSAHgB3AQAHAAYIbhSAHgB3AQAAAA==.',['天凉']='天凉好个湫湫:BAAAKgAECgMIAwAAAA==.天凉好个球球:BAAAKgAECgIIAgAAAA==.',['天启']='天启武帝:BAAAKgADCggICAAAAA==.',['天命']='天命人:BAAAKgAECgEIAgAAAA==.',['奇奇']='奇奇怪怪小德:BAAAKgAECgEIAQAAAA==.',['奈落']='奈落丶沃:BAAAKgADCgMIAwAAAA==.',['奥古']='奥古斯特:BAABKgAFFH8GAAIDAAYI1ARiHQC3AAADAAYI1ARiHQC3AAABKgAFFAgIBgADABkJAA==.',['奶糖']='奶糖爸爸:BAAAKgAFFAQIBAAAAA==.',['威丨']='威丨慑:BAABKgAFFH8GAAIRAAMIFgvqMwCiAAARAAMIFgvqMwCiAAAAAA==.',['嫻熟']='嫻熟職業婉家:BAAAKgAECgIIAgAAAA==.',['安琪']='安琪拉粑粑:BAAAKgAECggIDwAAAA==.',['安由']='安由心生:BAABKgAFFH8GAAILAAYI6hbPFQBVAQALAAYI6hbPFQBVAQAAAA==.安由轻轻:BAAAKgAECgEIAQAAAA==.',['宝了']='宝了个贝的:BAAAKgADCggICAAAAA==.',['富二']='富二代:BAAAKgAECggICAAAAA==.',['寒舞']='寒舞清玥:BAAAKgAFFAYIBAAAAA==.',['小丶']='小丶欠欠儿:BAAAKgAECgQIBAAAAA==.',['小二']='小二子快快:BAAAKgAECgYIDAABKgAECggIPwAFAH0aAA==.',['小则']='小则又沐风:BAAAKgADCgIIAgAAAA==.',['小太']='小太孑奶:BAABKgAFFH8IAAQBAAQIDByxDADwAAABAAQIDByxDADwAAAVAAMIIyGDFADAAAAWAAEIngqtJAA/AAABKgAFFAgIBAAaAAAAAA==.',['小娇']='小娇情:BAAAKgAECgMIAwAAAA==.',['小子']='小子不要走:BAAAKgAFFAIIBAAAAA==.',['小小']='小小斯温:BAABKgAFFH8IAAMHAAQIZRQcKgDJAAAHAAQICxIcKgDJAAAgAAQISQneIQBzAAAAAA==.',['小文']='小文子的世界:BAAAKgAECgIIAgAAAA==.',['小易']='小易生:BAABKgAECn8WAAIJAAYIFx36RABeAQAJAAYIFx36RABeAQAAAA==.',['小术']='小术:BAAAKgADCggICAAAAA==.',['小狐']='小狐狐:BAAAKgAECgMIBQAAAA==.',['小白']='小白熊猫:BAAAKgAFFAIIAgAAAA==.',['小粒']='小粒花生米:BAAAKgAFFAgIBAAAAA==.',['小红']='小红豆:BAAAKgAECgcIDAAAAA==.',['小绿']='小绿皮人:BAAAKgAECgIIAgAAAA==.',['小羊']='小羊羊早安:BAAAKgAECggICAAAAA==.',['小花']='小花椒的爸比:BAAAKgAECgQICwAAAA==.',['小莲']='小莲:BAAAKgAECgUICgAAAA==.',['小雪']='小雪梨好养喔:BAABKgAECn8WAAIRAAgIZRjKHgDcAQARAAgIZRjKHgDcAQAAAA==.',['小青']='小青椒灬:BAEBKgAFFH8KAAMRAAQI9yFkCgD2AAARAAQIkCFkCgD2AAAMAAQITh+uKQDeAAAAAA==.',['尛丶']='尛丶安寳:BAAAKgADCggICAAAAA==.',['尛杏']='尛杏杏:BAAAKgAFFAMIAwAAAA==.',['山与']='山与:BAABKgAFFH8NAAMLAAUIsxiLGQC6AAALAAQI+xKLGQC6AAAGAAUIZxa7FQCPAAAAAA==.',['川奕']='川奕:BAAAKgAECggIEgAAAA==.',['希尔']='希尔丨瓦娜斯:BAAAKgAECgQIBAAAAA==.',['帝樽']='帝樽:BAAAKgADCggICAAAAA==.',['幻夜']='幻夜圣殇:BAAAKgAECgIIAgAAAA==.',['幻梦']='幻梦之晓:BAAAKgAFFAQIBAAAAA==.幻梦葉炎:BAAAKgAFFAgIAgAAAA==.',['幽冥']='幽冥之眼:BAAAKgAFFAIIAgAAAA==.幽冥小萨:BAAAKgADCggICAAAAA==.',['幽霜']='幽霜:BAABKgAFFH8JAAIcAAgIQwzuAgABAgAcAAgIQwzuAgABAgAAAA==.',['库勒']='库勒斯:BAAAKgADCgMIAwABKgAFFAUIBwAFADAQAA==.',['张关']='张关羽:BAAAKgADCggIBQAAAA==.',['张馨']='张馨艺:BAAAKgAECgYIBgAAAA==.',['归离']='归离乀:BAAAKgADCggICAAAAA==.',['影夜']='影夜:BAABKgAFFH8GAAIRAAYIxgKtJgDQAAARAAYIxgKtJgDQAAAAAA==.',['很安']='很安静的疼痛:BAACKgAFFH8TAAMKAAYIyxI+AgAjAQAKAAUI6A4+AgAjAQALAAQIrg7dKgDCAAAqAAQKf0kABAsACAh3Hy0NAEoCAAsACAh3Hy0NAEoCAAYABghHEIsfANwAAAoAAwjOD/EeAKcAAAAA.',['微微']='微微滴血:BAABKgAECn8iAAIFAAgIpRJNDgCVAQAFAAgIpRJNDgCVAQAAAA==.',['微笑']='微笑结局:BAAAKgADCgIIAgAAAA==.',['德妞']='德妞丶:BAAAKgAFFAgIBAAAAA==.',['忍必']='忍必氼:BAAAKgADCggICAAAAA==.忍必魅:BAAAKgAECgIIAQAAAA==.',['思念']='思念变成海:BAAAKgAFFAIIAgAAAA==.',['性感']='性感小野猫:BAAAKgAECgQIBgAAAA==.',['恶魔']='恶魔温柔:BAAAKgAECgUIBQAAAA==.',['悦鲸']='悦鲸舞莉:BAABKgAFFH8HAAIbAAcIpQqLCwCFAQAbAAcIpQqLCwCFAQAAAA==.',['惩罚']='惩罚者古儿麻:BAAAKgAECggIEAAAAA==.',['愤怒']='愤怒燃烧:BAABKgAFFH8IAAIXAAMILALWFABUAAAXAAMILALWFABUAAAAAA==.',['慕容']='慕容飛雪:BAACKgAFFH8nAAQNAAcIvRPfAQDKAQANAAYIFxDfAQDKAQACAAQIyhrRKgDoAAAUAAEIzQ4iDwAqAAAqAAQKfygABA0ACAhBGpsMAOYBAA0ACAhCFJsMAOYBAAIACAjoFWI8ALYBABQAAggdHjsVAGwAAAAA.',['戏脸']='戏脸壳:BAABKgAECn8mAAIZAAgIuRy7HgBMAgAZAAgIuRy7HgBMAgAAAA==.',['我不']='我不:BAAAKgAECgMIBAAAAA==.我不是冰法:BAAAKgAECgEIAQAAAA==.我不是小德:BAABKgAFFH8LAAMCAAYIbg/aJwD1AAACAAUIyA7aJwD1AAAEAAII6xFQMABXAAAAAA==.我不是烈人:BAAAKgAECgUIBQAAAA==.我不是骑士:BAAAKgAECgEIAQAAAA==.',['我心']='我心永恒:BAAAKgADCgQIBAAAAA==.',['我没']='我没有奶水:BAACKgAFFH8bAAIHAAYIvBHuIwBbAQAHAAYIvBHuIwBbAQAqAAQKfywAAgcACAiyH1A3AEkCAAcACAiyH1A3AEkCAAAA.',['我爱']='我爱橙子吖:BAAAKgAECgYIBgAAAA==.我爱橙子啊:BAAAKgAECgUIBgAAAA==.我爱橙子子:BAAAKgADCggICAAAAA==.',['我知']='我知乄道我帅:BAAAKgADCggICAAAAA==.',['我肥']='我肥来了:BAAAKgAECggICAAAAA==.',['扳姬']='扳姬:BAAAKgADCggICAAAAA==.',['折袖']='折袖:BAABKgAFFH8GAAIHAAYIZRuoGACYAQAHAAYIZRuoGACYAQAAAA==.',['披凉']='披凉皮的狼:BAAAKgAECgYICgAAAA==.',['拓斯']='拓斯叮勾:BAAAKgADCgQIBAAAAA==.',['揉不']='揉不到捌拾:BAAAKgAECgMIBAAAAA==.',['撵鸡']='撵鸡斗狗:BAAAKgAECggICAAAAA==.',['放开']='放开那位小妞:BAAAKgAECgIIAgAAAA==.',['施主']='施主奶吗:BAAAKgAECgEIAQAAAA==.',['无叶']='无叶:BAAAKgAECgMIAwAAAA==.',['无夜']='无夜:BAAAKgAECgIIAgAAAA==.',['无敌']='无敌丶小白:BAABKgAFFH8GAAIhAAYI9h/oAwDFAQAhAAYI9h/oAwDFAQAAAA==.',['昊仡']='昊仡大王:BAAAKgAECgUIBQAAAA==.',['星宇']='星宇洞察者:BAAAKgADCgIIAgAAAA==.',['显卡']='显卡克星:BAAAKgAFFAQIBAAAAA==.',['晓得']='晓得呀:BAABKgAFFH8FAAIEAAMI7BiLGQDUAAAEAAMI7BiLGQDUAAAAAA==.',['暖颜']='暖颜萨:BAAAKgAECgcIBwAAAA==.',['暗影']='暗影蘑菇:BAABKgAECn8cAAIMAAgIZxbBUwBgAQAMAAgIZxbBUwBgAQAAAA==.',['暗黑']='暗黑魔阴:BAAAKgADCgQIBAAAAA==.',['最可']='最可爱的人:BAAAKgAECggIDAAAAA==.',['月光']='月光族丨穷德:BAAAKgAFFAMIAwAAAA==.',['月刑']='月刑:BAABKgAFFH8QAAMMAAgIaBW2BwACAgAMAAgIQBO2BwACAgARAAgIpQwvCAC1AQAAAA==.',['月焚']='月焚:BAAAKgAECgEIAQAAAA==.',['有来']='有来丶有去:BAAAKgAECgEIAQAAAA==.',['木法']='木法沙:BAAAKgAECggICAAAAA==.',['未完']='未完待续:BAAAKgAECgYIBgAAAA==.',['来两']='来两个杀壹双:BAAAKgADCggICwAAAA==.',['枪杆']='枪杆:BAACKgAFFH8HAAIFAAUIMBCABQBVAQAFAAUIMBCABQBVAQAqAAQKfxQAAwUACAibH7MEAIcCAAUACAibH7MEAIcCACIAAQgAAKZTAAAAAAAA.',['枫落']='枫落寞丶:BAAAKgADCggICAAAAA==.',['桀克']='桀克:BAAAKgAECgcIEgAAAA==.',['梨花']='梨花若雪:BAAAKgAFFAQIBAAAAA==.',['梵人']='梵人的梵:BAAAKgADCggICAAAAA==.',['楊戬']='楊戬:BAAAKgAECgIIAgAAAA==.',['楽伊']='楽伊梨:BAABKgAFFH8IAAMEAAMIvgrWJQCOAAAEAAMIvgrWJQCOAAAUAAEIyADMEQANAAAAAA==.楽伊禮:BAABKgAECn8YAAMEAAgIyBB3NQBDAQAEAAgIyBB3NQBDAQACAAEIxw1MyQAyAAAAAA==.',['橘子']='橘子妹妹最乖:BAAAKgAECgcIDAAAAA==.',['橙子']='橙子耍牛虻:BAABKgAFFH8HAAIJAAcI7g1VAQDoAQAJAAcI7g1VAQDoAQAAAA==.',['正好']='正好五个字:BAAAKgAECgcICgAAAA==.',['正气']='正气牛:BAAAKgADCggICAAAAA==.',['死了']='死了再骑:BAAAKgAECgUIBwAAAA==.',['死亡']='死亡圈圈:BAAAKgAECggICAAAAA==.',['死侍']='死侍:BAABKgAFFH8GAAIJAAYIAR2kEACXAQAJAAYIAR2kEACXAQAAAA==.',['死小']='死小骑:BAAAKgAECggIAwABKgAFFAgICAAfALMSAA==.',['残暴']='残暴的小师叔:BAAAKgAECgIIAgAAAA==.',['毒島']='毒島冴子:BAAAKgAECgMIAwAAAA==.',['毛毛']='毛毛哒:BAACKgAFFH8MAAMMAAMIGxQRMgDGAAAMAAMIGxQRMgDGAAARAAEIxwfBVAAvAAAqAAQKfx4AAgwACAiKHSEwADMCAAwACAiKHSEwADMCAAAA.',['永远']='永远的十七岁:BAABKgAFFH8LAAMdAAgIvAfPBACmAQAdAAgIIQTPBACmAQAiAAMIRw/vFwC+AAAAAA==.',['汤圆']='汤圆儿:BAAAKgAECgIIAgABKgAFFAgIAwAaAAAAAA==.',['汨潙']='汨潙誰丶洏流:BAAAKgADCgIIAgAAAA==.',['沉默']='沉默:BAAAKgAFFAEIAQAAAA==.',['沔阳']='沔阳三棒槌:BAAAKgAECgQICgAAAA==.',['泰丶']='泰丶森:BAAAKgAECggIDAAAAA==.',['泽宇']='泽宇儿:BAAAKgAECgIIAgAAAA==.',['洋芋']='洋芋殇:BAABKgAECn9MAAMLAAgIwBueBgBCAgALAAgIwBueBgBCAgAKAAMIBgi+fAA0AAAAAA==.',['洛坎']='洛坎:BAAAKgADCgQIBAAAAA==.',['活捉']='活捉关晓彤:BAAAKgAECggIEAAAAA==.',['流云']='流云:BAAAKgADCgEIAQAAAA==.',['浅陌']='浅陌红尘:BAAAKgAECgEIAQAAAA==.',['海宇']='海宇古:BAAAKgAECgEIAQAAAA==.',['涅槃']='涅槃火鳳:BAABKgAFFH8GAAQiAAUIjgfcFADaAAAiAAQIyQbcFADaAAAFAAEI9BOMGwBRAAAdAAEIlQRlQAA3AAAAAA==.',['淡扫']='淡扫娥眉:BAAAKgADCgEIAQAAAA==.',['深海']='深海鱼:BAAAKgADCgIIAgAAAA==.',['深秋']='深秋已逝:BAAAKgADCggICAAAAA==.',['深蓝']='深蓝仲浅蓝:BAAAKgAECgcICAAAAA==.深蓝屮浅蓝:BAAAKgAECggICgAAAA==.',['清水']='清水无鱼:BAAAKgAFFAQIBAAAAA==.',['清清']='清清苹果香:BAAAKgAECgQIBAAAAA==.',['清潇']='清潇潇易水涵:BAAAKgAECgYICgAAAA==.',['清酒']='清酒沐春秋:BAAAKgAECgIIAgAAAA==.',['清风']='清风阁:BAABKgAFFH8GAAITAAMI6RWvFQDGAAATAAMI6RWvFQDGAAAAAA==.',['温丶']='温丶暖:BAAAKgAECggICAAAAA==.',['游吟']='游吟浪人:BAAAKgAFFAMIAwAAAA==.',['游戏']='游戏人生梦:BAAAKgADCggICAAAAA==.',['渼汁']='渼汁滋:BAAAKgADCgcIBwAAAA==.',['溜溜']='溜溜达达:BAAAKgADCggICAAAAA==.',['潘达']='潘达小帅:BAAAKgAECgQIBAAAAA==.',['灬德']='灬德丨行灬:BAAAKgAECgUIBQAAAA==.',['灬桃']='灬桃子桃灬:BAABKgAFFH8IAAIOAAQIRRE0FwDCAAAOAAQIRRE0FwDCAAAAAA==.',['灬無']='灬無丶情灬:BAAAKgADCggICAAAAA==.',['灬筒']='灬筒子筒灬:BAAAKgADCggIDAAAAA==.',['灬紫']='灬紫茉莉丶:BAABKgAECn8eAAIJAAgI7SMjBgDjAgAJAAgI7SMjBgDjAgAAAA==.',['灬阡']='灬阡陌晨昏:BAABKgAFFH8IAAIiAAgIvAkjCgDDAQAiAAgIvAkjCgDDAQAAAA==.',['灬鳯']='灬鳯丶鸢灬:BAAAKgAECgMIBAAAAA==.',['炮灬']='炮灬皇:BAAAKgAECgYIBgAAAA==.',['無盡']='無盡思念:BAAAKgADCgEIAQAAAA==.',['焦玛']='焦玛:BAABKgAFFH8KAAIFAAgICxNZAgAcAgAFAAgICxNZAgAcAgAAAA==.',['焰之']='焰之绯丶:BAAAKgAECggICgAAAA==.',['爱看']='爱看书的欣:BAABKgAFFH8OAAIHAAgIERbZDgC0AQAHAAgIERbZDgC0AQAAAA==.',['爱茵']='爱茵丝坦:BAAAKgAECggICAAAAA==.',['爱蓝']='爱蓝再献:BAABKgAFFH8XAAIZAAMIsBCjLgDCAAAZAAMIsBCjLgDCAAAAAA==.',['牛奶']='牛奶糖打豆豆:BAABKgAFFH8JAAILAAgISwmhDADCAQALAAgISwmhDADCAQAAAA==.',['牛牛']='牛牛黑棒:BAABKgAFFH8IAAMEAAgIQh7zBwCNAQAEAAQIIiHzBwCNAQACAAQImRWDOQC9AAAAAA==.',['特仑']='特仑苏:BAAAKgADCgYIBgAAAA==.',['狂野']='狂野大魔王:BAAAKgADCggICQAAAA==.',['猪排']='猪排盖浇面:BAAAKgAFFAYIAgABKgAFFAgIBAAaAAAAAA==.',['猫了']='猫了个眯:BAAAKgAECgEIAQAAAA==.',['王小']='王小样:BAAAKgAECgMIAwAAAA==.',['王总']='王总与公主:BAAAKgAFFAgIAgAAAA==.',['玖幽']='玖幽琰月:BAAAKgAECgQIBQAAAA==.',['玛娜']='玛娜娜:BAAAKgADCgMIAwAAAA==.',['琴羽']='琴羽飞:BAAAKgAECgMIBAAAAA==.',['瑞瓦']='瑞瓦肖:BAAAKgAFFAgIAgAAAA==.',['甜甜']='甜甜的阿悦:BAABKgAFFH8IAAIHAAgIkhNZCQAUAgAHAAgIkhNZCQAUAgAAAA==.',['电脑']='电脑:BAAAKgAECgIIAgAAAA==.',['留恋']='留恋丶易为殇:BAAAKgADCgEIAQAAAA==.',['番茄']='番茄加西红柿:BAABKgAFFH8IAAIDAAgIQQ86BAC4AQADAAgIQQ86BAC4AQAAAA==.',['白皮']='白皮猪往哪跑:BAAAKgADCggICAAAAA==.',['百公']='百公里一馒头:BAAAKgADCgMIAwAAAA==.',['真武']='真武帝君:BAAAKgAECgQIBAAAAA==.',['真羽']='真羽千夜:BAABKgAECn8hAAMJAAgIPRMdRQBdAQAJAAgIPRMdRQBdAQADAAIIzwPCHgA0AAAAAA==.',['碧萝']='碧萝黄泉:BAACKgAFFH8GAAIZAAUIkAqUDwBDAQAZAAUIkAqUDwBDAQAqAAQKfxQAAhkACAg6IcwwAOsBABkACAg6IcwwAOsBAAAA.',['神戟']='神戟:BAABKgAFFH8KAAMDAAYIthMxDgA4AQADAAYIthMxDgA4AQAJAAQIbg0sOgC0AAABKgAFFAgIAgAaAAAAAA==.',['神样']='神样的存在:BAABKgAFFH8HAAIHAAYIZA9EJABaAQAHAAYIZA9EJABaAQAAAA==.',['神棍']='神棍熊猫:BAAAKgAFFAMIAwABKgAFFAgICgAHAK0lAA==.',['神綺']='神綺:BAABKgAFFH8MAAIRAAQITRZ9LgCzAAARAAQITRZ9LgCzAAAAAA==.',['禁魔']='禁魔之殇:BAAAKgAECgYIBgAAAA==.',['福光']='福光降临:BAAAKgAECgMIBQAAAA==.',['空空']='空空伊:BAAAKgADCgEIAQAAAA==.',['空谷']='空谷乌龙青:BAAAKgAFFAgIAgAAAA==.',['筱丿']='筱丿凯凯:BAAAKgAECggICAAAAA==.',['粉丶']='粉丶楼:BAAAKgADCgYICgAAAA==.',['粉色']='粉色真好看:BAAAKgAECgYIBgAAAA==.',['红颜']='红颜灬夏天:BAAAKgAECgcIBwAAAA==.',['纯爱']='纯爱牛骑士:BAAAKgAECggICQAAAA==.',['绿色']='绿色的好:BAAAKgAECggIDAAAAA==.',['罗纳']='罗纳尔多:BAABKgAFFH8LAAMTAAcIDAcJDAA6AQATAAcIDAcJDAA6AQASAAQIJQr8GQCrAAAAAA==.',['羊仙']='羊仙儿:BAAAKgADCgEIAQAAAA==.',['羊排']='羊排盖浇面:BAABKgAFFH8JAAIHAAcIuBncDQDFAQAHAAcIuBncDQDFAQAAAA==.',['翎冫']='翎冫熙:BAAAKgAECgMIBQAAAA==.',['翠咖']='翠咖啡:BAACKgAFFH8hAAMQAAQIVgJ6CgBdAAAQAAQIVgJ6CgBdAAAOAAIIVAAIKgBCAAAqAAQKfxQABBAACAgbBvcWALsAABAACAgbBvcWALsAAA4ABQgIAuVuAIwAAA8AAQgAAD9yAAAAAAAA.',['老乄']='老乄费:BAAAKgAECgYIBwAAAA==.',['老臭']='老臭:BAAAKgAFFAYIAgAAAA==.',['胜天']='胜天半丶:BAAAKgAFFAQIBAAAAA==.',['胡灬']='胡灬图图:BAABKgAFFH8HAAISAAMIhQpKGQCwAAASAAMIhQpKGQCwAAAAAA==.',['艺声']='艺声:BAAAKgADCgYIBgAAAA==.',['艾克']='艾克丶:BAAAKgAFFAEIAQAAAA==.',['花殇']='花殇紫吟调:BAABKgAFFH8IAAMCAAgIFA6GDAC3AQACAAcIhA6GDAC3AQAEAAEIFwOMGAA6AAAAAA==.',['花泽']='花泽香菜:BAAAKgAFFAIIAgAAAA==.',['花痴']='花痴大脸叔丶:BAAAKgAECgEIAQAAAA==.花痴大脸猫丶:BAAAKgAECggICAAAAA==.',['花開']='花開荼蘼:BAAAKgAFFAMIBAAAAA==.',['苏丶']='苏丶楼:BAAAKgADCgcICAAAAA==.',['草原']='草原小萨满:BAAAKgAECggICAAAAA==.',['莜乐']='莜乐美:BAABKgAFFH8GAAIMAAYIfwvdGAA1AQAMAAYIfwvdGAA1AQAAAA==.',['菟牙']='菟牙:BAABKgAFFH8HAAQLAAYI8RinBgA5AQALAAQIsCWnBgA5AQAGAAEIyQbsIQBFAAAKAAII2wQ7LwA8AAAAAA==.',['萌萌']='萌萌德爷:BAAAKgAECggIDQAAAA==.',['萧壹']='萧壹月:BAAAKgADCgMIAwAAAA==.',['萧柒']='萧柒月:BAAAKgAFFAQIBAAAAA==.',['萧肆']='萧肆月:BAABKgAFFH8GAAIiAAYIrAzTFwAmAQAiAAYIrAzTFwAmAQAAAA==.',['萨日']='萨日朗:BAAAKgAECggICAAAAA==.',['落日']='落日珊瑚:BAAAKgAFFAYIBAAAAA==.',['葵竺']='葵竺熔岩烈酒:BAAAKgAECgIIAgAAAA==.',['蓝颜']='蓝颜灬炮总:BAAAKgAECggICQAAAA==.',['薄荷']='薄荷糖冰冰凉:BAAAKgAECgUIBQAAAA==.',['藏龙']='藏龙卧虎:BAABKgAFFH8IAAIMAAgItxIKBwAUAgAMAAgItxIKBwAUAgAAAA==.',['虔诚']='虔诚丸子:BAABKgAECn8XAAIWAAcIsRF2QAA3AQAWAAcIsRF2QAA3AQAAAA==.',['血德']='血德俱乐部:BAAAKgAFFAgIBAAAAA==.',['血翼']='血翼:BAAAKgAFFAQIBAAAAA==.',['表酱']='表酱紫看我:BAAAKgAFFAQIBAABKgAFFAgIBAAaAAAAAA==.',['被亵']='被亵渎的爱:BAAAKgAECgUIBQAAAA==.',['装忧']='装忧郁被狗追:BAAAKgADCgMIAwAAAA==.',['西湖']='西湖老甲鱼:BAABKgAFFH8KAAIZAAYIoRpVJQDjAAAZAAYIoRpVJQDjAAAAAA==.',['西溪']='西溪吼吼:BAACKgAFFH8QAAMPAAMIohjGEADdAAAPAAMIohjGEADdAAAOAAEIRQHiNQAlAAAqAAQKfxwAAw4ACAgVF2skANEBAA4ACAgVF2skANEBAA8ABQi1HlU2AAcBAAAA.',['请给']='请给我个面子:BAAAKgAFFAQIBAAAAA==.',['谁加']='谁加班谁是爹:BAAAKgADCggICAAAAA==.谁加班谁是班:BAAAKgADCggICAAAAA==.谁加班谁是苟:BAAAKgAECggIEAAAAA==.',['豆浆']='豆浆加糖:BAAAKgAECgQIBAAAAA==.',['豪鬼']='豪鬼爱骑马:BAACKgAFFH8PAAITAAMI5RYpMAC4AAATAAMI5RYpMAC4AAAqAAQKfxgAAhMACAhZGI1FAHIBABMACAhZGI1FAHIBAAAA.',['贰小']='贰小登子:BAAAKgADCggICAAAAA==.',['贼不']='贼不爱划水:BAAAKgADCgEIAQAAAA==.',['资深']='资深饿势力:BAABKgAFFH8HAAIHAAcIQh6qCQAoAgAHAAcIQh6qCQAoAgAAAA==.',['赤丶']='赤丶楼:BAAAKgADCggIEAAAAA==.',['超凶']='超凶:BAAAKgADCggICAAAAA==.',['超粉']='超粉芭比龙:BAAAKgAECgMIAwAAAA==.',['趣多']='趣多多:BAABKgAFFH8KAAMCAAQIhBqaMgDNAAACAAQIhBqaMgDNAAAEAAQIWRFQIQCkAAAAAA==.',['踏雪']='踏雪寻熊:BAAAKgAECgQIBAAAAA==.',['蹲在']='蹲在厕所玩蛆:BAAAKgAECgcICwAAAA==.',['转身']='转身后微笑:BAABKgAFFH8HAAIMAAUIWw00DgBKAQAMAAUIWw00DgBKAQAAAA==.',['这男']='这男人有大鸟:BAAAKgAFFAQIBAAAAA==.',['逍遥']='逍遥风间:BAABKgAECn8XAAIfAAgIaBU/JQD7AQAfAAgIaBU/JQD7AQAAAA==.',['逮虾']='逮虾妇:BAAAKgAFFAgIAwAAAA==.',['那罗']='那罗多:BAAAKgAECgcIBwAAAA==.',['邪魔']='邪魔天师:BAAAKgADCgIIAgAAAA==.',['都别']='都别理我:BAABKgAFFH8HAAILAAcIMhfmDgCgAQALAAcIMhfmDgCgAQAAAA==.',['酃丶']='酃丶楽楽:BAAAKgAECggICAAAAA==.',['酃灬']='酃灬喵喵:BAAAKgAECgYIBgAAAA==.',['酌酒']='酌酒揽清秋:BAABKgAFFH8IAAIHAAMIohhrIQDiAAAHAAMIohhrIQDiAAAAAA==.',['酥松']='酥松奶油曲奇:BAAAKgAECgQIBQAAAA==.',['酩酊']='酩酊奥特曼:BAAAKgAFFAgIBAAAAA==.',['野原']='野原向日葵:BAAAKgAFFAMIAwAAAA==.',['野生']='野生偷油婆:BAAAKgAECgYICwAAAA==.',['锅炉']='锅炉房王老汉:BAAAKgAECgYIAQABKgAFFAgIBQAIAEkOAA==.',['闪光']='闪光的索菲雅:BAAAKgAECggICgAAAA==.',['阿基']='阿基裏斯:BAAAKgAECgcICwAAAA==.',['阿波']='阿波痛击老六:BAABKgAFFH8SAAICAAYIghRHGABWAQACAAYIghRHGABWAQAAAA==.',['阿海']='阿海:BAAAKgAECggICwAAAA==.',['阿鬼']='阿鬼教你电:BAABKgAFFH8IAAMSAAQIaxToCgDYAAASAAQIaxToCgDYAAATAAQIYwLxHgCeAAABKgAFFAgICAAMAJ0HAA==.',['陆一']='陆一贫:BAAAKgAECgUICQAAAA==.',['陆大']='陆大善人:BAABKgAFFH8GAAIfAAYI6xVgCwCVAQAfAAYI6xVgCwCVAQAAAA==.',['陈丶']='陈丶贵州茅台:BAAAKgADCggIEAAAAA==.',['随风']='随风吻雨:BAABKgAECn8kAAIOAAgIyAlZOgDjAAAOAAgIyAlZOgDjAAAAAA==.',['雅俗']='雅俗共赏:BAAAKgADCgQIBAAAAA==.',['雅典']='雅典娜:BAAAKgAECgYICQAAAA==.',['雪千']='雪千寻灬:BAAAKgADCggICAAAAA==.',['雪山']='雪山千古冷:BAAAKgAECggICAAAAA==.',['零零']='零零後:BAAAKgAECgYIBgAAAA==.',['雷諾']='雷諾血蹄:BAAAKgADCggIEAAAAA==.',['雾里']='雾里:BAAAKgAECgcICQAAAA==.',['青丘']='青丘心月:BAAAKgAECgMIAwAAAA==.',['青潇']='青潇潇易水寒:BAACKgAFFH8IAAIXAAQIVxHcDACcAAAXAAQIVxHcDACcAAAqAAQKfygABBcACAgtHVARAKcBABcACAi8HFARAKcBABgABggiEyk5AP8AAB8ABAgyGGkiANUAAAAA.',['青灬']='青灬椒:BAAAKgAFFAQIBAAAAA==.',['青鸾']='青鸾丶烬瞳:BAABKgAFFH8FAAIZAAUIKBPvHwAEAQAZAAUIKBPvHwAEAQAAAA==.',['韭菜']='韭菜姐姐:BAAAKgAECgYICAAAAA==.',['顧懿']='顧懿:BAAAKgAFFAQIBAAAAA==.',['颍月']='颍月:BAABKgAFFH8bAAITAAYI3SRRBQABAgATAAYI3SRRBQABAgAAAA==.',['風雨']='風雨灬葑芯:BAAAKgAFFAgIAgAAAA==.',['风向']='风向之水瓶:BAABKgAFFH8OAAIbAAMIyA3CIwCxAAAbAAMIyA3CIwCxAAAAAA==.',['风崖']='风崖:BAABKgAFFH8HAAITAAUIoQbdEQDsAAATAAUIoQbdEQDsAAAAAA==.',['风舞']='风舞洋:BAAAKgAECgMIAwAAAA==.',['风行']='风行者灬:BAAAKgAFFAQIBAAAAA==.',['风雨']='风雨刑天:BAAAKgAFFAIIAgAAAA==.',['飘飘']='飘飘熊:BAAAKgAECggICAABKgAFFAgIRwAdADUlAA==.',['飞小']='飞小鸡:BAAAKgADCggIDwAAAA==.',['餐桌']='餐桌术卷轴:BAACKgAFFH8JAAMiAAMI+QhzOwBzAAAiAAIIJgtzOwBzAAAdAAIIbAaTKgBuAAAqAAQKfyAAAh0ACAi2E102AL0BAB0ACAi2E102AL0BAAAA.',['香脆']='香脆曲奇:BAAAKgAECgYIBgAAAA==.',['馬苏']='馬苏苏:BAAAKgAECggIEQAAAA==.',['骑着']='骑着马发个浪:BAABKgAFFH8GAAIHAAMIDg10VwDCAAAHAAMIDg10VwDCAAAAAA==.',['魂梦']='魂梦如烟:BAAAKgAFFAEIAQAAAA==.',['魔发']='魔发披风丿:BAABKgAFFH8SAAMRAAYITyIzCQDFAQARAAYIGCIzCQDFAQAMAAYIpxbKFABPAQABKgAFFAgIHAAiAPgfAA==.',['鸡肥']='鸡肥蛋大:BAAAKgADCgYIBgAAAA==.',['黎明']='黎明殺手:BAABKgAFFH8GAAIHAAYIwBN0IgBjAQAHAAYIwBN0IgBjAQAAAA==.',['黑白']='黑白之间:BAAAKgAECgIIAgAAAA==.',['黑种']='黑种猪:BAAAKgADCggIHwAAAA==.',['黑鹳']='黑鹳五号:BAAAKgAECgYICgAAAA==.',['點燃']='點燃閃電:BAAAKgAFFAMIAwAAAA==.',['黯隠']='黯隠修羅:BAABKgAFFH8GAAIFAAYIjh32AgDbAQAFAAYIjh32AgDbAQAAAA==.',['齐逼']='齐逼小背心:BAAAKgAECgIIAgABKgAECggIPwAFAH0aAA==.齐逼白衬衫:BAABKgAECn8/AAMFAAgIfRpzKADaAQAFAAgIfRpzKADaAQAiAAYIIRnvHQA0AQAAAA==.',['龘龘']='龘龘:BAAAKgAECgUIBgAAAA==.',['龙喷']='龙喷右边:BAAAKgADCgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end