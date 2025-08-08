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
 local lookup = {'Mage-Arcane','Warrior-Arms','Warrior-Fury','DemonHunter-Vengeance','DemonHunter-Havoc','Monk-Windwalker','Monk-Mistweaver','Shaman-Restoration','Shaman-Elemental','Hunter-BeastMastery','Mage-Fire','Priest-Shadow','Priest-Holy','Mage-Frost','Unknown-Unknown','DeathKnight-Blood','Paladin-Holy','Paladin-Retribution','Warlock-Destruction','Evoker-Devastation','Evoker-Preservation','Druid-Restoration','Paladin-Protection','DeathKnight-Unholy','Druid-Balance','Hunter-Marksmanship','Warlock-Demonology','Priest-Discipline','Warlock-Affliction','Rogue-Assassination','Monk-Brewmaster','Warrior-Protection','DeathKnight-Frost','Rogue-Subtlety','Druid-Feral','Rogue-Outlaw',}; local provider = {region='CN',realm='达尔坎',name='CN',type='weekly',zone=42,date='2025-08-02',data={Ar='Arcteryx:BAAAKgAECgcIBwAAAA==.',Au='Austing:BAABKgAFFH8GAAIBAAYIAhCHEQBbAQABAAYIAhCHEQBbAQAAAA==.',Ca='Cavalierjoj:BAAAKgADCggICAAAAA==.',Cu='Cuteyile:BAAAKgAFFAYIBAAAAA==.',De='Dermi:BAAAKgAFFAIIAwAAAA==.',Eu='Europa:BAAAKgAECgYIBgAAAA==.',Hi='Hirachel:BAAAKgAECgEIAQAAAA==.',Hy='Hyzmage:BAAAKgAECggICgAAAA==.',Ju='Juwoyaer:BAAAKgAECgYIDAAAAA==.',Ku='Kumashi:BAAAKgAFFAQIBAAAAA==.',My='Mycc:BAABKgAFFH8MAAMCAAMIghEDFwDOAAACAAMIghEDFwDOAAADAAMIEAakGACUAAAAAA==.',Ni='Nineties:BAAAKgAFFAgIBAAAAA==.',Pe='Perula:BAACKgAFFH8cAAMEAAUImR4CAgA2AQAEAAUImR4CAgA2AQAFAAQInhNLNgCoAAAqAAQKfygAAgQACAg4JEUEANECAAQACAg4JEUEANECAAAA.',Pl='Playerjwlqmt:BAABKgAECn8XAAMDAAgI7Ra3IQDGAQADAAcIYhi3IQDGAQACAAcIrBI6JQBeAQAAAA==.Playerjzhykn:BAABKgAFFH8IAAIGAAgIIgw7BQDjAQAGAAgIIgw7BQDjAQAAAA==.',Ra='Rainbowmiss:BAAAKgAFFAQIBAAAAA==.',Re='Redwolf:BAAAKgAECgQIBAAAAA==.',Sq='Squirrel:BAAAKgADCggICAAAAA==.',Su='Supermilk:BAAAKgADCgQIBAAAAA==.',Te='Teentine:BAAAKgAFFAEIAQAAAA==.',To='Tojimo:BAAAKgAFFAQIBAAAAA==.Topjiji:BAAAKgAECgEIAQAAAA==.',Tr='Trency:BAABKgAFFH8JAAIEAAMIFwe8HAByAAAEAAMIFwe8HAByAAABKgAFFAgIDwAHAMcVAA==.',Vt='Vturn:BAACKgAFFH8MAAIIAAQIkxfSJADjAAAIAAQIkxfSJADjAAAqAAQKfxgAAwgACAiPH8kZADkCAAgACAiPH8kZADkCAAkABAguEcJTAKwAAAAA.',Wa='Walch:BAAAKgADCggICAAAAA==.',['一则']='一则驴:BAAAKgAFFAIIAgAAAA==.',['一定']='一定抗的住:BAAAKgAECgQIBAAAAA==.',['一杆']='一杆鱼叉猎:BAABKgAFFH8IAAIKAAgI/g2WCQDZAQAKAAgI/g2WCQDZAQAAAA==.',['一梦']='一梦:BAAAKgADCggICAAAAA==.',['一点']='一点三:BAAAKgAFFAQIBAAAAA==.',['一米']='一米曙光:BAABKgAFFH8IAAILAAQIjRfTHADgAAALAAQIjRfTHADgAAAAAA==.',['一花']='一花事了一:BAAAKgAECgYIBgAAAA==.',['一起']='一起哈啤:BAAAKgAFFAEIAQAAAA==.',['一队']='一队奶骑:BAAAKgAECgcIDgAAAA==.',['三星']='三星坏女人:BAABKgAFFH8JAAMMAAUIRBDICAAdAQAMAAUIRBDICAAdAQANAAQIzgSyEgCsAAAAAA==.',['三花']='三花绽放:BAAAKgAECgEIAQAAAA==.',['三荒']='三荒烬灭:BAAAKgAECgQIBAAAAA==.',['不明']='不明白:BAAAKgADCgcICQAAAA==.',['不死']='不死坠灬天心:BAAAKgAECgEIAQAAAA==.',['不羁']='不羁的大妈:BAAAKgAECgIIAgAAAA==.',['专业']='专业萨爹:BAABKgAFFH8PAAIIAAMI8BiTJwDYAAAIAAMI8BiTJwDYAAAAAA==.',['东方']='东方:BAABKgAFFH8HAAMLAAMIeRwgIAC1AAALAAIIFyAgIAC1AAAOAAEIPRVTKgBBAAAAAA==.',['丨回']='丨回忆如风丨:BAAAKgAFFAYIAgAAAA==.',['丨天']='丨天罚丨:BAAAKgAECgIIAgAAAA==.',['丨萌']='丨萌萌哒丨:BAAAKgAFFAQIAgAAAA==.',['丶丨']='丶丨凌乱:BAAAKgAECgcICgAAAA==.',['丶丶']='丶丶嚜丶丶:BAAAKgAECggICQAAAA==.',['丶吟']='丶吟诗:BAAAKgADCggICAAAAA==.',['丶寶']='丶寶児:BAAAKgADCgQIBAAAAA==.',['丶小']='丶小红手:BAAAKgAFFAgIBAAAAA==.',['丶怼']='丶怼誰:BAAAKgADCgIIAgABKgAECgUIBQAPAAAAAA==.',['丶神']='丶神避:BAAAKgAFFAYIBAAAAA==.',['丶菜']='丶菜菜丶:BAAAKgAFFAQIBAABKgAFFAgIEgAQALUfAA==.',['丶蛋']='丶蛋蛋丶:BAAAKgAFFAMIAwAAAA==.',['举着']='举着伞淋着雨:BAAAKgADCgEIAQAAAA==.',['丿灬']='丿灬潺潺:BAAAKgADCggICAAAAA==.',['丿祭']='丿祭灬血:BAAAKgAFFAEIAQAAAA==.',['乃青']='乃青交融:BAACKgAFFH8JAAMLAAQIrhqGIADUAAALAAQIkBmGIADUAAAOAAEIwRt7HQBGAAAqAAQKfx8AAg4ACAggG7YfAA4CAA4ACAggG7YfAA4CAAAA.',['乌萨']='乌萨奇:BAAAKgAECgcIBwAAAA==.',['乌鸦']='乌鸦坐飞鸡:BAAAKgADCgMIAwAAAA==.',['二狗']='二狗子三精:BAABKgAFFH8OAAMRAAYIIyKZAwDTAQARAAYIIyKZAwDTAQASAAQInBleFwD9AAAAAA==.',['云朵']='云朵:BAAAKgAECgcIDAAAAA==.',['五代']='五代天王:BAABKgAFFH8GAAITAAYI3iMzCAAMAgATAAYI3iMzCAAMAgAAAA==.',['五码']='五码圣光:BAAAKgADCggIEAAAAA==.',['亚利']='亚利斯塔图铎:BAAAKgADCgIIAgAAAA==.',['伊斯']='伊斯特拉:BAAAKgADCgcICAAAAA==.',['伊萨']='伊萨伯安特:BAAAKgAECgYIBgAAAA==.',['伊露']='伊露维塔:BAACKgAFFH8YAAMUAAUINwlkFQCjAAAUAAQIWwlkFQCjAAAVAAEICAWsBwAyAAAqAAQKfywAAxQACAgED+woAHMBABQACAgED+woAHMBABUACAgLDWQRAM4AAAAA.',['佛氏']='佛氏崇拜:BAABKgAFFH8HAAIWAAMI0xEYIACrAAAWAAMI0xEYIACrAAAAAA==.',['你在']='你在掩饰什么:BAABKgAFFH8IAAIXAAgI3Q0AFQDQAAAXAAgI3Q0AFQDQAAAAAA==.',['你想']='你想跟我拼枪:BAAAKgAECgEIAQAAAA==.',['佳能']='佳能照相机:BAABKgAFFH8LAAISAAQIwCMeCAA9AQASAAQIwCMeCAA9AQAAAA==.',['俞情']='俞情未了:BAABKgAFFH8UAAMQAAQIGwMnLgBYAAAQAAQIGwMnLgBYAAAYAAEIwwDfVwAgAAAAAA==.',['信仰']='信仰决定力量:BAAAKgADCggICAAAAA==.',['倾城']='倾城小牧牧:BAAAKgAECgYIBgABKgAFFAYILwAIAAsTAA==.倾城小龙牧:BAAAKgAFFAQIBAABKgAFFAYILwAIAAsTAA==.',['傲霸']='傲霸狂男:BAAAKgADCggICAAAAA==.',['光暗']='光暗倒影:BAAAKgAECgMIAwAAAA==.',['內麽']='內麽屡:BAAAKgAFFAgIBAAAAA==.',['八楼']='八楼有寒风:BAAAKgAFFAIIAgAAAA==.',['兰森']='兰森德尔:BAAAKgAECgEIAQAAAA==.',['冚屲']='冚屲屲冚:BAAAKgAECgcICAAAAA==.',['冰封']='冰封的心:BAAAKgAECgYICQAAAA==.',['凌波']='凌波丽丶:BAABKgAFFH8IAAIYAAQIrRrZEQDyAAAYAAQIrRrZEQDyAAAAAA==.',['凌雲']='凌雲:BAAAKgAFFAIIAgAAAA==.',['凶飞']='凶飞杀手:BAAAKgADCggICAAAAA==.',['切茜']='切茜娅:BAAAKgAFFAIIAgAAAA==.',['创世']='创世神魔:BAAAKgAECgQIBAAAAA==.',['制毒']='制毒二十年:BAAAKgADCggICwAAAA==.',['功夫']='功夫喘:BAABKgAFFH8UAAIGAAYIKBJTAgCkAQAGAAYIKBJTAgCkAQAAAA==.',['加勒']='加勒比灬海带:BAABKgAFFH8QAAMBAAgInBIFCwC6AQABAAgI5wgFCwC6AQAOAAQIRCBBCwDUAAABKgAFFAgIRwALADUlAA==.',['劳资']='劳资蜀道伞:BAAAKgAECgUIBQAAAA==.',['十鬼']='十鬼神王马:BAABKgAFFH8PAAISAAYIqhXkAgCvAQASAAYIqhXkAgCvAQAAAA==.',['千山']='千山万水:BAAAKgAECggICAAAAA==.',['华尔']='华尔街沃夫:BAABKgAFFH8JAAISAAMIHg2uKgC7AAASAAMIHg2uKgC7AAAAAA==.',['单手']='单手煎鸡蛋:BAAAKgADCgEIAQAAAA==.',['卩死']='卩死丶灵丨:BAAAKgAECggICAAAAA==.',['厌即']='厌即是恋:BAAAKgADCggICAAAAA==.',['原來']='原來很緊:BAAAKgAECgIIAgAAAA==.',['又硬']='又硬又粗:BAAAKgAFFAQIAgAAAA==.',['双鱼']='双鱼蛮蛮:BAAAKgAECgUICQAAAA==.',['变形']='变形金刚霸天:BAABKgAFFH8GAAMZAAYIsQhmGgDUAAAZAAUIzQVmGgDUAAAWAAEIzwfXGAA1AAAAAA==.',['口水']='口水娃丶:BAAAKgAFFAQIBAAAAA==.',['古怪']='古怪生长:BAAAKgADCgMIAwAAAA==.',['叫我']='叫我小浪就好:BAABKgAECn8aAAMRAAgIBg25IQBSAQARAAgIBg25IQBSAQASAAMIhxKF/QC6AAAAAA==.',['可乐']='可乐墩墩:BAABKgAFFH8RAAIZAAUIkhgqLwDXAAAZAAUIkhgqLwDXAAAAAA==.可乐鸦鸦:BAABKgAFFH8FAAIZAAMIhQtGLACDAAAZAAMIhQtGLACDAAAAAA==.',['右誓']='右誓:BAAAKgAFFAMIAwAAAA==.',['吃过']='吃过饭了:BAAAKgAFFAMIAwAAAA==.吃过饭了么:BAAAKgAECgEIAQAAAA==.吃过饭了吗:BAAAKgADCggICAAAAA==.吃过饭了吧:BAAAKgAFFAMIAwAAAA==.吃过饭了呀:BAAAKgAECgIIAgAAAA==.吃过饭了嘛:BAAAKgAECgQIBAAAAA==.',['吖噗']='吖噗丷吖噗:BAABKgAFFH8GAAIEAAMI+wOYDgBxAAAEAAMI+wOYDgBxAAAAAA==.',['君战']='君战:BAAAKgAECggIEgAAAA==.',['听花']='听花黎落:BAAAKgAECgcICwAAAA==.',['启迪']='启迪大豆豆:BAAAKgAECgcICQAAAA==.',['吾去']='吾去脱她依:BAAAKgAECggIEAAAAA==.',['周星']='周星星:BAAAKgAFFAgIBAAAAA==.',['哈喽']='哈喽凯蒂:BAAAKgAECgYIBgAAAA==.哈喽剀帝:BAABKgAFFH8HAAIDAAMI0A4YEgDdAAADAAMI0A4YEgDdAAAAAA==.',['哈库']='哈库纳玛塔塔:BAAAKgAECgQIBAAAAA==.',['哈莉']='哈莉奎茵:BAAAKgADCgYIBgAAAA==.',['唸风']='唸风语者:BAAAKgAECgMIAwAAAA==.',['啸啸']='啸啸家长:BAAAKgAECgYICgAAAA==.',['啸老']='啸老板:BAAAKgAECgQIBQAAAA==.',['喝喝']='喝喝酒:BAAAKgAECggICAAAAA==.',['喵与']='喵与荆芥:BAACKgAFFH8GAAIFAAMISgkFIQC1AAAFAAMISgkFIQC1AAAqAAQKfx8AAgUACAhkEntAAKYBAAUACAhkEntAAKYBAAAA.',['囧囧']='囧囧小猎:BAABKgAFFH8IAAIKAAgIbQq4CADdAQAKAAgIbQq4CADdAQAAAA==.',['土豆']='土豆薇:BAAAKgAECgIIAgAAAA==.',['圣光']='圣光之翼:BAAAKgAECgIIAgAAAA==.',['圣叉']='圣叉叉:BAAAKgAECgYIBwAAAA==.',['夏丶']='夏丶纠结:BAAAKgADCggICAAAAA==.',['夏纠']='夏纠结:BAAAKgAECgYIBgAAAA==.',['夏鈊']='夏鈊:BAAAKgADCggICAAAAA==.',['夜小']='夜小瞳:BAABKgAECn8aAAIFAAgIDgkBMADKAAAFAAgIDgkBMADKAAAAAA==.',['夜雨']='夜雨染青衫:BAAAKgAFFAYIBAAAAA==.',['大悦']='大悦悦:BAAAKgAECggICAAAAA==.',['大雾']='大雾怪:BAAAKgAECgYICwAAAA==.',['大鼻']='大鼻子王源:BAABKgAFFH8UAAIFAAcIJRDuDwCIAQAFAAcIJRDuDwCIAQAAAA==.',['天天']='天天只有你:BAAAKgADCggICAAAAA==.',['天宇']='天宇之心:BAABKgAFFH8JAAISAAMIPRaDRwDfAAASAAMIPRaDRwDfAAAAAA==.',['天涯']='天涯丨炫血:BAAAKgADCggICAAAAA==.',['天灾']='天灾骨钟:BAABKgAECn9DAAIKAAgIMhteJgAcAgAKAAgIMhteJgAcAgAAAA==.',['天神']='天神下瀿:BAAAKgAECgIIAgAAAA==.',['如丨']='如丨果:BAAAKgADCgMIBAAAAA==.',['姬如']='姬如雪:BAABKgAFFH8IAAIFAAgIcBeVBgA+AgAFAAgIcBeVBgA+AgAAAA==.',['姬莉']='姬莉丶哈泽尔:BAAAKgADCggIEQAAAA==.',['威風']='威風堂堂:BAABKgAECn8aAAMJAAgIGySjDQByAgAJAAcIiySjDQByAgAIAAgImxlrJgD1AQAAAA==.',['娇嫩']='娇嫩爽歪歪:BAAAKgAECgIIAgAAAA==.',['子不']='子不语灬:BAAAKgAECgIIAwAAAA==.',['孖桶']='孖桶洗衣机:BAAAKgAECgcIBwAAAA==.',['宇宙']='宇宙骑士利炮:BAAAKgAECgMIBAAAAA==.',['守心']='守心:BAABKgAECn8WAAMaAAgI5h22EABQAgAaAAgI5h22EABQAgAKAAMI0BLs7QBXAAAAAA==.',['寂寞']='寂寞先生丶:BAAAKgAFFAQIBAAAAA==.',['寒霜']='寒霜雪:BAABKgAFFH8UAAIQAAgIlxdKBgDNAQAQAAgIlxdKBgDNAQAAAA==.',['小小']='小小牛:BAAAKgADCgEIAQAAAA==.',['小布']='小布丁糖:BAABKgAECn8aAAMbAAgIwhFhDABvAQAbAAgIyRBhDABvAQATAAIIChH0NgBmAAAAAA==.',['小泽']='小泽又沐风:BAAAKgAFFAQIBAAAAA==.',['小烟']='小烟凌:BAAAKgAFFAYIAgABKgAFFAgICAAXAPYSAA==.',['小白']='小白下楼梯:BAAAKgADCggICwAAAA==.小白聋:BAAAKgADCgEIAQAAAA==.',['小聋']='小聋瞎:BAAAKgAECgEIAQAAAA==.',['小艳']='小艳玲:BAAAKgAFFAgIBAAAAA==.',['尐尐']='尐尐老爹:BAAAKgADCgcIBgAAAA==.',['尼哥']='尼哥:BAAAKgAECgIIAgAAAA==.',['山海']='山海觀霧:BAABKgAFFH8IAAILAAQIfSIBEQAPAQALAAQIfSIBEQAPAQAAAA==.',['岁岁']='岁岁安澜丶:BAAAKgADCggICAAAAA==.',['左之']='左之神猎:BAAAKgAECggICAAAAA==.',['巧克']='巧克力麻薯:BAAAKgAECgYIBgAAAA==.',['巨龙']='巨龙降临:BAABKgAFFH8IAAMaAAQIxALaIABoAAAaAAQIxALaIABoAAAKAAQIAQFzLwA7AAAAAA==.',['巫洛']='巫洛丶克:BAACKgAFFH8aAAIHAAgIHx2VAQDXAQAHAAgIHx2VAQDXAQAqAAQKf0QAAwcACAirFyMpALUBAAcACAirFyMpALUBAAYACAjDGoQpAJkBAAAA.',['布丁']='布丁不听:BAAAKgAECgcICAAAAA==.布丁糖:BAAAKgAECgIIAgAAAA==.',['布索']='布索匹灬拳须:BAABKgAECn8WAAIHAAcIOx9rGADIAQAHAAcIOx9rGADIAQAAAA==.',['帅气']='帅气复苏:BAAAKgAECgQIBgAAAA==.',['帆布']='帆布鞋的骄傲:BAAAKgAFFAgIBAAAAA==.',['幺鸡']='幺鸡小一条:BAABKgAFFH8IAAMcAAQIpBZeCwD5AAAcAAQIpBZeCwD5AAANAAQILwp9EQC2AAABKgAFFAgIEAAcANwaAA==.',['开水']='开水白菜:BAAAKgAECgIIAgAAAA==.',['张呣']='张呣呣:BAAAKgAFFAIIAgAAAA==.',['张大']='张大彪:BAAAKgADCgMIAwAAAA==.',['张谋']='张谋人:BAAAKgADCggICAAAAA==.',['当铺']='当铺丶:BAABKgAFFH8KAAMTAAYI5hNYBQBSAQATAAYIkQdYBQBSAQAdAAMIVR/MBQD9AAABKgAFFAgIFgATAOgSAA==.',['影仕']='影仕:BAABKgAFFH8bAAIeAAYIURdCCgCrAQAeAAYIURdCCgCrAQAAAA==.',['微笑']='微笑灬:BAAAKgAFFAIIAgAAAA==.',['快乐']='快乐小闪电:BAAAKgAECgcIDgAAAA==.',['忽必']='忽必猎:BAAAKgAECgMIAwAAAA==.',['思思']='思思灬:BAAAKgAECggICwAAAA==.',['恋恋']='恋恋风歌:BAABKgAFFH8GAAMKAAYIAhtFEwAAAQAKAAQI7BpFEwAAAQAaAAIIIxt+NgCaAAAAAA==.',['恶魔']='恶魔血怒:BAAAKgAECggICAAAAA==.',['悠悠']='悠悠崽崽:BAAAKgAECgYICgAAAA==.',['悠然']='悠然自得:BAAAKgAECggICAAAAA==.',['愤怒']='愤怒:BAABKgAFFH8GAAITAAYI/R7bDAC+AQATAAYI/R7bDAC+AQAAAA==.',['慈观']='慈观寺:BAAAKgAECgUIBQAAAA==.',['慎独']='慎独:BAABKgAFFH8GAAIOAAYIsxYSBgBxAQAOAAYIsxYSBgBxAQAAAA==.',['慕斯']='慕斯牧丝慕思:BAABKgAFFH8FAAINAAQIHxL0LwCGAAANAAQIHxL0LwCGAAAAAA==.',['憨包']='憨包猪超可爱:BAAAKgAFFAgIBAAAAA==.憨包猪超级凶:BAAAKgAFFAQIBAAAAA==.',['懒洋']='懒洋洋的妖妖:BAAAKgAECgMIBQAAAA==.',['我也']='我也不是恶魔:BAAAKgAECgQIBAAAAA==.',['我就']='我就是昆丁:BAAAKgADCgMIAwAAAA==.',['我握']='我握住了希望:BAAAKgAFFAQIBAAAAA==.',['我是']='我是变异男:BAABKgAFFH8IAAIHAAgIixQQBgDmAQAHAAgIixQQBgDmAQAAAA==.',['我爱']='我爱潇洒哥:BAAAKgAECgUICAAAAA==.',['战狂']='战狂:BAAAKgAECggICgAAAA==.',['战神']='战神的姐姐:BAAAKgAECgYIBgAAAA==.',['所以']='所以我放弃了:BAAAKgAECgQIBwAAAA==.',['扭头']='扭头灵魂:BAAAKgAECggICAAAAA==.',['拂晓']='拂晓神丫:BAACKgAFFH8FAAMfAAQIvAJ+CgBdAAAfAAQIvAJ+CgBdAAAHAAEIyQsRLgA2AAAqAAQKfzEAAgcACAizJc8BAO4CAAcACAizJc8BAO4CAAAA.',['拽的']='拽的有志气:BAABKgAFFH8KAAMEAAYI7hhOBQBOAQAEAAYIOBdOBQBOAQAFAAQIYRIqLQDGAAAAAA==.',['持斧']='持斧大只佬:BAAAKgAFFAgIAgAAAA==.',['推倒']='推倒少女:BAAAKgAECgQIBAAAAA==.',['撸灬']='撸灬至深丶:BAAAKgADCgEIAQAAAA==.',['放肆']='放肆丶那纠结:BAABKgAFFH8HAAMdAAMIRxDmEwCLAAAdAAMIpw/mEwCLAAATAAIIaA2eQwBcAAAAAA==.',['敌法']='敌法爱你哦:BAAAKgAFFAQIBAAAAA==.',['敌羞']='敌羞拖沓依:BAAAKgAFFAgIBAAAAA==.',['新手']='新手村的猎:BAAAKgAECgUIBQAAAA==.',['方丈']='方丈的娇师太:BAABKgAFFH8GAAILAAYImBWbBgCaAQALAAYImBWbBgCaAQAAAA==.',['旅途']='旅途终点:BAABKgAFFH8GAAIYAAYIOQnQGgBGAQAYAAYIOQnQGgBGAQAAAA==.',['旋转']='旋转小陀螺:BAAAKgADCgYIBgAAAA==.',['无法']='无法无影:BAAAKgAECgYICwAAAA==.',['无限']='无限虚空:BAAAKgAECgQIBQAAAA==.',['旧时']='旧时光的来信:BAAAKgAECgMIAwAAAA==.',['易秋']='易秋顔:BAAAKgAECgYICwAAAA==.',['星夜']='星夜汐:BAAAKgAFFAEIAQAAAA==.',['晓丶']='晓丶圣光:BAABKgAECn8VAAISAAgIyRnlGQDtAQASAAgIyRnlGQDtAQAAAA==.晓丶猎心:BAABKgAECn8ZAAIFAAgImRs3EQDhAQAFAAgImRs3EQDhAQAAAA==.晓丶瞄准:BAAAKgAECgcIDAAAAA==.',['晓羽']='晓羽丅蕾姆:BAAAKgAECggICAAAAA==.',['普拉']='普拉普拉灰:BAAAKgAECgUIBgAAAA==.',['暮思']='暮思丶:BAAAKgAECgEIAQAAAA==.暮思丶丶:BAAAKgAECggIDQAAAA==.',['暴富']='暴富灬前行:BAABKgAFFH8RAAIeAAYIKRDBDQBzAQAeAAYIKRDBDQBzAQAAAA==.暴富灬回响:BAABKgAFFH8OAAIbAAQIEBnrCgDeAAAbAAQIEBnrCgDeAAAAAA==.暴富灬解忧:BAABKgAFFH8QAAIIAAQIwhwFIgDwAAAIAAQIwhwFIgDwAAAAAA==.暴富牛:BAABKgAFFH8TAAIYAAMIQxGPMgDKAAAYAAMIQxGPMgDKAAAAAA==.',['曾经']='曾经我野清纯:BAABKgAFFH8GAAIXAAYIzgskEwDiAAAXAAYIzgskEwDiAAAAAA==.',['月光']='月光的救赎:BAAAKgAECggICgAAAA==.',['有朋']='有朋自远方来:BAAAKgAECgYIBgAAAA==.',['朝凪']='朝凪:BAABKgAECn8fAAIHAAgIDhQUJgDHAQAHAAgIDhQUJgDHAQAAAA==.',['木兰']='木兰没及:BAAAKgAECgMIAwAAAA==.',['木头']='木头薇:BAAAKgADCgMIAwAAAA==.',['机器']='机器:BAABKgAFFH8FAAMgAAUINwvUBwDsAAAgAAQINwvUBwDsAAADAAEIAAAVPQAAAAAAAA==.机器人:BAAAKgAECggIBQAAAA==.',['杨教']='杨教授乄:BAABKgAFFH8IAAIXAAgIVhI3BwCjAQAXAAgIVhI3BwCjAQAAAA==.',['杰僧']='杰僧:BAAAKgAECgYIBgAAAA==.',['杲晴']='杲晴旖旎:BAAAKgAECggIDgAAAA==.',['极速']='极速火炮:BAAAKgAECgMIBAAAAA==.',['枫叶']='枫叶的思绪:BAAAKgADCggICQAAAA==.',['柒号']='柒号花茗册:BAAAKgAFFAQIBAAAAA==.',['桃园']='桃园奈奈生:BAAAKgADCgEIAQAAAA==.',['梅老']='梅老板不慌:BAAAKgAFFAMIAwAAAA==.',['梅西']='梅西慌的一逼:BAABKgAECn8UAAMKAAgI2g4zIABxAQAKAAgI2g4zIABxAQAaAAII8AbxoAA7AAAAAA==.',['梦倾']='梦倾笙:BAAAKgADCggICAAAAA==.',['樓蘭']='樓蘭芷殇:BAAAKgAECgMIAwAAAA==.',['樱花']='樱花兔耳萌:BAAAKgAECgIIAgAAAA==.',['橙吉']='橙吉斯汗:BAAAKgAECggICAAAAA==.',['死亡']='死亡巨热:BAAAKgADCgEIAQAAAA==.',['残念']='残念的路人:BAAAKgADCgYIBgAAAA==.',['残暴']='残暴丶魍魉:BAAAKgAECgYIBgAAAA==.',['殷传']='殷传如:BAAAKgADCgUIBQAAAA==.',['水牛']='水牛:BAAAKgADCggICAAAAA==.',['永恒']='永恒的下巴:BAAAKgAFFAYIBAABKgAFFAgIDgAYAA8XAA==.',['汉堡']='汉堡包爱圣光:BAABKgAFFH8HAAISAAQIrRAEWQC/AAASAAQIrRAEWQC/AAAAAA==.',['江湖']='江湖相见:BAAAKgAECgQIBAAAAA==.',['沐沐']='沐沐小棉袄:BAAAKgAECgIIAgAAAA==.沐沐小肉包:BAAAKgAECgEIAQAAAA==.',['沫晓']='沫晓柒:BAAAKgADCgIIAgAAAA==.',['河源']='河源:BAAAKgAECgcIBwAAAA==.',['油焖']='油焖秋芛:BAAAKgAECgUIBQAAAA==.',['洋葱']='洋葱葱:BAAAKgAFFAIIAgAAAA==.',['洛唲']='洛唲丶:BAAAKgAECggICAAAAA==.',['洛晚']='洛晚风:BAAAKgADCgcIBwAAAA==.',['洛清']='洛清烟:BAAAKgADCgUIBQAAAA==.洛清舞:BAAAKgADCggICAAAAA==.',['浴血']='浴血默寞:BAAAKgAECgMIAwAAAA==.',['涂山']='涂山我罩的:BAAAKgAECgMIBQAAAA==.',['涼白']='涼白開:BAAAKgAECgUIBQAAAA==.',['清初']='清初倾冶丷:BAABKgAFFH8GAAIKAAYIpx/PDACjAQAKAAYIpx/PDACjAQAAAA==.',['清渊']='清渊:BAAAKgADCgYIBgAAAA==.',['清辉']='清辉夜凝:BAABKgAFFH8GAAMNAAMINA03KgCaAAANAAMINA03KgCaAAAcAAEIyQFDNgAnAAAAAA==.',['游婴']='游婴:BAABKgAFFH8IAAIaAAgICxPNCADNAQAaAAgICxPNCADNAQAAAA==.',['溟殇']='溟殇:BAABKgAFFH8VAAIYAAMIDBhjLgDWAAAYAAMIDBhjLgDWAAAAAA==.',['灬橙']='灬橙冠希:BAAAKgAECgUIBQAAAA==.',['灬那']='灬那个妹子:BAAAKgAECgUIBQAAAA==.',['灰灰']='灰灰:BAAAKgAECggIBgABKgAFFAgICwAIAP4jAA==.灰灰的小雨天:BAABKgAECn8dAAMYAAgITSABFgB8AgAYAAgITSABFgB8AgAhAAMIGxzYIwCgAAAAAA==.',['灰烬']='灰烬:BAAAKgAECggIEAAAAA==.',['炖菜']='炖菜:BAABKgAFFH8LAAISAAMIJhpFUQDNAAASAAMIJhpFUQDNAAAAAA==.',['烈烈']='烈烈:BAAAKgAECggIDgAAAA==.',['焦你']='焦你作仁:BAAAKgAECggIDAAAAA==.',['熊猫']='熊猫人:BAACKgAFFH8hAAIHAAYIvh/7AQDBAQAHAAYIvh/7AQDBAQAqAAQKfyYAAgcACAgvHmQVAD0CAAcACAgvHmQVAD0CAAEqAAUUCAgFAA0AHxIA.熊猫大扫除:BAAAKgAECgQIBAAAAA==.',['熟了']='熟了的牛排:BAABKgAFFH8IAAIgAAgIagtIAwCIAQAgAAgIagtIAwCIAQAAAA==.',['爆爆']='爆爆小肥牛:BAAAKgADCgQIBwAAAA==.',['爱丽']='爱丽斯菲尔:BAAAKgAECgQIBAAAAA==.',['爱的']='爱的魔力圈圈:BAAAKgAECgQIBAAAAA==.',['牛叉']='牛叉叉:BAAAKgADCgEIAQAAAA==.',['牛某']='牛某某:BAAAKgAFFAQIAgAAAA==.',['牢力']='牢力士丶:BAABKgAFFH8GAAIgAAYIVRpTAwCFAQAgAAYIVRpTAwCFAQAAAA==.',['牧云']='牧云左龙:BAAAKgAECgQIBAAAAA==.',['牧色']='牧色回响:BAAAKgADCgIIAgAAAA==.',['狂牛']='狂牛犇犇:BAAAKgADCgEIAQAAAA==.',['狂野']='狂野银江:BAAAKgAECgQIBAAAAA==.',['狂风']='狂风太子奶:BAABKgAECn8WAAISAAgI5hnkOwARAgASAAgI5hnkOwARAgAAAA==.',['狂魔']='狂魔血:BAAAKgAECggICAAAAA==.',['狗哥']='狗哥的小弟:BAAAKgADCgEIAQAAAA==.',['猎手']='猎手丶卢米安:BAAAKgAFFAEIAQAAAA==.',['猎空']='猎空:BAAAKgAECgIIAgAAAA==.',['猛牛']='猛牛酸酸乳:BAAAKgADCgYIBgAAAA==.',['玛法']='玛法里德:BAAAKgAECgYIBwAAAA==.',['玩命']='玩命一輝:BAAAKgAECgQIBAAAAA==.玩命小獵:BAAAKgADCgUIBQAAAA==.',['琳琳']='琳琳宝:BAAAKgAECggIDwAAAA==.',['甜蜜']='甜蜜兒:BAABKgAFFH8GAAISAAQI3BEtNwCbAAASAAQI3BEtNwCbAAAAAA==.',['瘋牛']='瘋牛卟咬魜:BAABKgAFFH8VAAMBAAUIahNcJgDIAAABAAUIXhBcJgDIAAAOAAIIThZqDwCYAAAAAA==.',['皓前']='皓前月:BAABKgAFFH8QAAMbAAgI4BkRBQAlAQATAAgIxRkjCQD7AQAbAAUIghwRBQAlAQAAAA==.',['皮丶']='皮丶点点:BAAAKgAECgcICQAAAA==.',['皮卡']='皮卡松:BAAAKgAECgIIAgAAAA==.',['目黑']='目黑将司:BAAAKgAECgUIBQAAAA==.',['眼子']='眼子寒:BAAAKgAFFAYIBAAAAA==.',['碇真']='碇真嗣丶:BAACKgAFFH8jAAIYAAYIph86DQC9AQAYAAYIph86DQC9AQAqAAQKfxcAAxgACAh/Gg5AAHIBABgACAgEFw5AAHIBACEABQjoG4QdAN0AAAAA.',['碱水']='碱水小面包:BAABKgAFFH8HAAMZAAUIaA/NFgDiAAAZAAQIMxTNFgDiAAAWAAEIdgr1NQBDAAABKgAFFAYIFAAGACgSAA==.',['神圣']='神圣牛肉人:BAAAKgAECgUICgAAAA==.',['神牧']='神牧娜娜:BAACKgAFFH8jAAMNAAQIvRpxCwDaAAANAAQIvRpxCwDaAAAcAAIIbwWYIgBsAAAqAAQKfzMAAxwACAhYGIQpAIsBABwACAiYEIQpAIsBAA0ACAhHFRQyAHkBAAAA.',['神罚']='神罚之剑:BAAAKgAECggICAAAAA==.',['穿尿']='穿尿布不好惹:BAAAKgAECgUIBQAAAA==.',['穿着']='穿着熊:BAAAKgAECgQIBAAAAA==.',['突然']='突然范特西:BAABKgAFFH8GAAIXAAYIJhJIDQAlAQAXAAYIJhJIDQAlAQABKgAFFAgIDgAYAEoXAA==.',['第一']='第一毒奶:BAAAKgAECgQIBAAAAA==.',['米斯']='米斯特丶圆:BAAAKgADCggICAAAAA==.',['紹興']='紹興老酒:BAACKgAFFH8YAAIIAAUIYBeRFQDPAAAIAAUIYBeRFQDPAAAqAAQKfywAAwgACAjmHR4gABYCAAgACAjmHR4gABYCAAkABgi2CUxMAOsAAAAA.',['红皮']='红皮小野猪:BAAAKgAFFAQIBAAAAA==.',['红茶']='红茶黑巧拿铁:BAAAKgAECggICAAAAA==.',['纯情']='纯情丶小正太:BAAAKgADCgQIBAAAAA==.纯情丶小翅膀:BAAAKgADCgUIBQAAAA==.',['纳格']='纳格兰花:BAAAKgAFFAQIBAAAAA==.',['织田']='织田七海:BAAAKgAECgMIAwAAAA==.',['终极']='终极炖菜:BAAAKgAECggICAAAAA==.',['羽风']='羽风:BAAAKgAFFAYIBAAAAA==.',['耀眼']='耀眼牧:BAAAKgAECggIBgAAAA==.',['老子']='老子很痛苦:BAAAKgAFFAgIBAAAAA==.',['聖者']='聖者:BAAAKgADCgIIAgAAAA==.',['聖銧']='聖銧:BAAAKgADCggICAAAAA==.',['脑袋']='脑袋砸核桃:BAAAKgAECgQIBwAAAA==.',['舞艷']='舞艷:BAAAKgAECgcIBwAAAA==.',['芥末']='芥末丶优质肝:BAAAKgADCgIIAgAAAA==.',['花小']='花小瞳:BAAAKgAECgcIBwAAAA==.',['苏格']='苏格兰丨调情:BAAAKgAECgUIBQAAAA==.',['范佛']='范佛里特弹药:BAAAKgADCgEIAgAAAA==.',['茉莉']='茉莉缇娜:BAAAKgADCgEIAQAAAA==.',['茶冻']='茶冻乌龙:BAACKgAFFH8vAAMIAAQI6SROEgBCAQAIAAQI6SROEgBCAQAJAAQITxZ2DQC+AAAqAAQKfy4AAwgACAi+HugwAMQBAAgACAi+HugwAMQBAAkACAiMGwArAKMBAAAA.',['荡漾']='荡漾波老师:BAAAKgAECgUIBQAAAA==.',['荷尔']='荷尔蒙公主:BAABKgAECn8kAAIOAAgIghCcDwB1AQAOAAgIghCcDwB1AQAAAA==.荷尔蒙兽兽:BAABKgAECn8fAAIiAAgIfw8KAwB3AQAiAAgIfw8KAwB3AQAAAA==.荷尔蒙烎士:BAABKgAECn8iAAITAAcI+hPWFABdAQATAAcI+hPWFABdAQAAAA==.',['莉艾']='莉艾拉:BAAAKgAFFAQIBAAAAA==.',['莉莉']='莉莉雅:BAABKgAECn8XAAIUAAgIviFlBwCwAgAUAAgIviFlBwCwAgAAAA==.',['萌妞']='萌妞柔柔:BAAAKgAECgQIBAAAAA==.',['萤火']='萤火眠海:BAAAKgADCggICAAAAA==.',['萨刃']='萨刃如麻:BAABKgAFFH8GAAIIAAIIoxrVKAB8AAAIAAIIoxrVKAB8AAAAAA==.',['蓦然']='蓦然等待:BAABKgAFFH8GAAIjAAMIpwYuBgCqAAAjAAMIpwYuBgCqAAAAAA==.',['蔷薇']='蔷薇花开:BAAAKgAECgIIAgAAAA==.',['蕃茄']='蕃茄:BAABKgAFFH8SAAIKAAMIuRxSJAD2AAAKAAMIuRxSJAD2AAAAAA==.',['薛敌']='薛敌忾:BAAAKgAECgEIAwAAAA==.',['虚空']='虚空鲶鱼:BAACKgAFFH8LAAITAAMILxSzKgDCAAATAAMILxSzKgDCAAAqAAQKfyUABBMACAjlG8gWAPEBABMACAjTG8gWAPEBAB0AAQj2FmoYAEYAABsAAghyE5J7AD0AAAAA.',['蛮子']='蛮子丶:BAAAKgADCgcIBwAAAA==.',['血色']='血色守护:BAAAKgAECgMIAwAAAA==.',['血魔']='血魔之舞:BAAAKgADCgIIAgAAAA==.',['血鸣']='血鸣:BAAAKgAFFAMIAQAAAA==.',['西瓜']='西瓜人:BAAAKgADCggIDAAAAA==.西瓜薇:BAAAKgAECgMIBQAAAA==.',['言不']='言不由衷丶:BAAAKgAFFAQIBAAAAA==.',['言无']='言无不禁:BAABKgAFFH8MAAIIAAMI5xyCIQDzAAAIAAMI5xyCIQDzAAAAAA==.',['諾亜']='諾亜灬雪儿:BAABKgAECn8lAAIKAAgImCVVCQDlAgAKAAgImCVVCQDlAgAAAA==.',['諾亞']='諾亞灬奶嘴:BAABKgAECn8UAAIIAAgI8BvuHAAoAgAIAAgI8BvuHAAoAgABKgAECggIJQAKAJglAA==.諾亞灬樰児:BAAAKgAECgYIBgAAAA==.諾亞灬雪儿:BAAAKgAECgUIBQAAAA==.諾亞灬雪兒:BAAAKgAECgcIBwAAAA==.',['语兰']='语兰枫:BAAAKgAECgQIBAAAAA==.',['豆柿']='豆柿辣鸡:BAABKgAECn8UAAIkAAgI9w9eDQA8AQAkAAgI9w9eDQA8AQAAAA==.',['貌似']='貌似伯虎:BAAAKgAECgYIDQAAAA==.',['贪吃']='贪吃猪猪:BAACKgAFFH8bAAIZAAQIIAuUPQCyAAAZAAQIIAuUPQCyAAAqAAQKfyUAAhkACAjlE/Q8AMMBABkACAjlE/Q8AMMBAAAA.',['贰樓']='贰樓後座:BAAAKgAECggICAAAAA==.',['赞达']='赞达拉男模:BAAAKgAECgUIBQAAAA==.赞达拉非酋:BAACKgAFFH8WAAMSAAUIhRMELQC7AAASAAUIZg8ELQC7AAAXAAQI1hflFwC5AAAqAAQKfzgAAxEACAg4FloTANsBABEACAg4FloTANsBABIACAh+FPBgANoBAAAA.',['超级']='超级伐木机:BAAAKgADCgIIAgAAAA==.',['路西']='路西法杰:BAAAKgAECgcICAAAAA==.',['踹你']='踹你一蹄子:BAAAKgAECgEIAQAAAA==.',['软软']='软软:BAAAKgADCggICQAAAA==.',['辉辉']='辉辉一擎天:BAAAKgADCgUIBgAAAA==.',['迷路']='迷路灬牛:BAAAKgAFFAQIBAAAAA==.',['逍遥']='逍遥星河:BAABKgAECn8UAAISAAgIOA5CMQBIAQASAAgIOA5CMQBIAQAAAA==.',['逐风']='逐风者丶熊猫:BAAAKgADCgEIAQAAAA==.',['遮沙']='遮沙避风了:BAACKgAFFH8KAAMcAAQI8iDMCAARAQAcAAQIbB/MCAARAQANAAIIoBUQFQCYAAAqAAQKfxwABBwACAjBIHAjALIBABwABwg/HXAjALIBAA0ABghWHCgwAIMBAAwAAgh4EuNoAFMAAAAA.',['那天']='那天雨:BAAAKgAECggICAAAAA==.',['部落']='部落的男子汉:BAAAKgADCgYIBgAAAA==.',['酒舞']='酒舞无心:BAAAKgAFFAIIAgAAAA==.',['酸草']='酸草莓:BAAAKgAECgMIAwAAAA==.',['醉光']='醉光阴:BAAAKgADCgUIBwAAAA==.',['鈡楚']='鈡楚红颜:BAAAKgADCgEIAQAAAA==.',['鉴宝']='鉴宝专家:BAAAKgAECgcIBwAAAA==.',['钱包']='钱包古古:BAAAKgADCggICAAAAA==.',['钻石']='钻石男高:BAABKgAFFH8MAAIIAAYIqQIkIQD1AAAIAAYIqQIkIQD1AAAAAA==.',['错的']='错的人:BAAAKgAECgEIAQAAAA==.',['镇丶']='镇丶岳:BAAAKgAFFAIIAwAAAA==.',['长孙']='长孙慕语:BAABKgAFFH8FAAISAAUI6w/+awCTAAASAAUI6w/+awCTAAAAAA==.',['闹麻']='闹麻了:BAABKgAFFH8GAAIYAAYIhw/pGABWAQAYAAYIhw/pGABWAQAAAA==.',['阿尔']='阿尔缇米斯:BAAAKgAECgYIDgAAAA==.',['阿猫']='阿猫师傅:BAAAKgAECgYIBgAAAA==.',['阿祖']='阿祖丶收手吧:BAAAKgAECgYIBgAAAA==.',['陈嘉']='陈嘉轩:BAAAKgAFFAYIBAAAAA==.',['随处']='随处飘流的风:BAAAKgADCgcIBwAAAA==.',['随芯']='随芯:BAAAKgAECgEIAQAAAA==.',['雄雄']='雄雄威威:BAAAKgAECgEIAQAAAA==.',['雨濛']='雨濛濛:BAAAKgAECgMIAwAAAA==.',['雪山']='雪山飞侠:BAABKgAFFH8bAAMaAAYI5SCqCwCbAQAKAAYIsB3ECQC9AQAaAAYIPR6qCwCbAQABKgAFFAgIAwAPAAAAAA==.',['雪映']='雪映流光:BAAAKgAECgcICAAAAA==.',['雪曦']='雪曦:BAABKgAFFH8FAAIRAAUIrQ55BwD2AAARAAUIrQ55BwD2AAAAAA==.',['雪鲜']='雪鲜:BAAAKgADCggICAAAAA==.',['零度']='零度久战:BAABKgAECn8YAAICAAgIFRnSGQC2AQACAAgIFRnSGQC2AQAAAA==.',['露露']='露露麓齐尔:BAAAKgADCgUIBQAAAA==.',['青龙']='青龙圣僧:BAAAKgAFFAgIBAAAAA==.',['靓小']='靓小丫:BAAAKgAECgEIAQAAAA==.',['面包']='面包老大:BAAAKgAECgIIAgAAAA==.',['鞠我']='鞠我芽儿嘛:BAAAKgAECgIIAgAAAA==.',['韦小']='韦小宝丶射:BAABKgAFFH8IAAIKAAYIABq2EQBqAQAKAAYIABq2EQBqAQAAAA==.韦小宝丶斩:BAABKgAFFH8IAAIDAAgI+RleAwCMAgADAAgI+RleAwCMAgAAAA==.',['韩小']='韩小雪:BAAAKgAECgYIBgAAAA==.',['顔如']='顔如玉丶:BAAAKgAECggICAAAAA==.',['颠倒']='颠倒:BAAAKgAECgYIBgAAAA==.',['风吹']='风吹你的裙角:BAAAKgADCggICAAAAA==.',['风喵']='风喵酱:BAAAKgAECgIIAgAAAA==.',['风暴']='风暴萨满:BAAAKgADCggIDQAAAA==.',['风雅']='风雅颂:BAAAKgAECggIEAAAAA==.',['香草']='香草拿铁:BAAAKgAECgQIBAAAAA==.',['骤雨']='骤雨不终日:BAAAKgAECggIDAAAAA==.',['鬼月']='鬼月丨邪:BAABKgAFFH8HAAIFAAYIcg4tGQAzAQAFAAYIcg4tGQAzAQAAAA==.',['魁丶']='魁丶拔:BAACKgAFFH8GAAIYAAYIkxkoEACdAQAYAAYIkxkoEACdAQAqAAQKfxQAAhgACAg4HO4pAA8CABgACAg4HO4pAA8CAAAA.',['魅男']='魅男子:BAAAKgAECggICAAAAA==.',['魑魅']='魑魅魍魎:BAAAKgADCgEIAQAAAA==.',['魔杰']='魔杰:BAAAKgAECgEIAQAAAA==.',['鲨鱼']='鲨鱼丨:BAAAKgAECgMIAwAAAA==.',['麦芽']='麦芽糖吖:BAABKgAFFH8OAAIIAAgIvBI4BgDsAQAIAAgIvBI4BgDsAQAAAA==.',['麦麦']='麦麦橙汁:BAAAKgAECgIIAgAAAA==.麦麦脆汁鸡:BAAAKgAFFAYIAgABKgAFFAgIHgAWAKEbAA==.麦麦薯条:BAABKgAFFH8IAAMUAAQIbRORDgDdAAAUAAQIbRORDgDdAAAVAAQIqQTEBQCmAAAAAA==.',['黎明']='黎明寂寞:BAAAKgAECgQIBAAAAA==.',['黑夜']='黑夜魅魔:BAAAKgADCggICAAAAA==.',['黑帥']='黑帥:BAAAKgAECgIIAgAAAA==.',['黑暗']='黑暗左手:BAACKgAFFH8WAAISAAQISSGcMAAmAQASAAQISSGcMAAmAQAqAAQKfxgAAhIACAiuGwlRAMsBABIACAiuGwlRAMsBAAAA.',['黑角']='黑角杆:BAAAKgAECgEIAQAAAA==.',['龍飛']='龍飛鳳舞丶:BAABKgAFFH8PAAISAAcIpxphAQDjAQASAAcIpxphAQDjAQAAAA==.',['龙大']='龙大力:BAAAKgAFFAQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end