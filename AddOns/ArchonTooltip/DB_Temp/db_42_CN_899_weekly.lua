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
 local lookup = {'Mage-Arcane','Hunter-Marksmanship','DemonHunter-Havoc','Shaman-Restoration','Mage-Frost','Mage-Fire','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Holy','Paladin-Retribution','Unknown-Unknown','Warlock-Destruction','Rogue-Assassination','Druid-Guardian','Druid-Balance','Shaman-Enhancement','Monk-Mistweaver','Druid-Restoration','Monk-Windwalker','Evoker-Devastation','Evoker-Preservation','Priest-Holy','Hunter-BeastMastery','Warlock-Demonology','Priest-Discipline','Warrior-Fury','Priest-Shadow','Shaman-Elemental','DemonHunter-Vengeance','Paladin-Protection','Warlock-Affliction','Rogue-Subtlety','Monk-Brewmaster',}; local provider = {region='CN',realm='黑石尖塔',name='CN',type='weekly',zone=42,date='2025-08-04',data={An='Andersonlee:BAAAKgADCggICAAAAA==.Andromeda:BAAAKgAECggICAAAAA==.',Ar='Arcangle:BAAAKgADCgUIBQAAAA==.Arhkam:BAABKgAFFH8FAAIBAAMIjw8nKQC+AAABAAMIjw8nKQC+AAAAAA==.',Ba='Babysz:BAABKgAFFH8FAAICAAUIrh5nEwBHAQACAAUIrh5nEwBHAQAAAA==.',Br='Brightcat:BAAAKgAFFAQIBAAAAA==.',Da='David:BAAAKgAFFAQIBAAAAA==.',De='Deepyyds:BAABKgAFFH8GAAIDAAYI9gvmDgBQAQADAAYI9gvmDgBQAQAAAA==.',Dr='Drextar:BAABKgAFFH8OAAIEAAgI6RYuAwBGAgAEAAgI6RYuAwBGAgAAAA==.',Dt='Dtmiss:BAAAKgAECgEIAQAAAA==.',Ey='Eyjafjamonk:BAAAKgAECggICAAAAA==.',Ga='Galliano:BAAAKgAECgYICQAAAA==.',Gu='Guinevere:BAAAKgAECggICAAAAA==.',Ic='Iceage:BAAAKgAECgIIAgAAAA==.',Ja='Jacobs:BAAAKgAECgMIAwAAAA==.Janmy:BAABKgAFFH8KAAQFAAgIOhRAFACNAAABAAIIRhjPLwClAAAFAAQIYxpAFACNAAAGAAMIGgVQKAB+AAAAAA==.',Jl='Jl:BAABKgAFFH8NAAMHAAYIgBsPCQCFAQAHAAYIgBsPCQCFAQAIAAEIzxpRUQBOAAAAAA==.',Le='Le:BAAAKgAECgcICAAAAA==.',Lk='Lkll:BAAAKgAECgQICgAAAA==.',Lo='Lower:BAAAKgADCgEIAQAAAA==.',Ma='Magicelf:BAACKgAFFH8IAAMJAAMIRBx0CwDyAAAJAAMIRBx0CwDyAAAKAAEIfQQzjwAzAAAqAAQKfxYAAwoACAj0FSl+AFMBAAoABwjZEyl+AFMBAAkABAihGCkyAOMAAAAA.',Mu='Munn:BAAAKgAECgQIBAAAAA==.',Ni='Nicknik:BAABKgAFFH8HAAIKAAcIHws9EQCKAQAKAAcIHws9EQCKAQAAAA==.',Pe='Pecan:BAAAKgADCgIIAgAAAA==.',Ro='Rosel:BAAAKgAECgEIAQABKgAECgYICQALAAAAAA==.',Sh='Sheo:BAABKgAFFH8KAAIKAAgIPhcyCwAUAgAKAAgIPhcyCwAUAgAAAA==.',Sk='Skylove:BAAAKgAECgYIBgAAAA==.',So='Soulwhisper:BAAAKgAFFAYIAgABKgAFFAgICgAMAI4cAA==.',Tc='Tcxx:BAAAKgAFFAMIAwAAAA==.',Ti='Tion:BAAAKgAECgIIAgAAAA==.',Tr='Traceblood:BAAAKgAECggICAAAAA==.',Ve='Ventar:BAAAKgADCgQIBAAAAA==.',We='Website:BAABKgAFFH8GAAINAAYIKhgeCgD1AAANAAYIKhgeCgD1AAAAAA==.',Yi='Yiyiicee:BAAAKgAECgMIBAAAAA==.Yiyiiceq:BAAAKgADCgIIAgAAAA==.Yiyiicez:BAAAKgADCggICwAAAA==.',Yo='Yolin:BAAAKgAECgUIBQAAAA==.',['一个']='一个小肉包:BAAAKgAECggICAABKgAFFAgIEAABAHkTAA==.',['一大']='一大新手:BAABKgAFFH8GAAIOAAMI8QlbCQB4AAAOAAMI8QlbCQB4AAAAAA==.',['一撮']='一撮毛:BAABKgAFFH8GAAIPAAYIbxqqEgCHAQAPAAYIbxqqEgCHAQAAAA==.',['一无']='一无霜一:BAAAKgAECgQIBAAAAA==.',['一牛']='一牛当千:BAAAKgAFFAIIAgAAAA==.',['一直']='一直读愈合:BAAAKgADCggICAAAAA==.',['一背']='一背叛一:BAAAKgAFFAMIAwAAAA==.',['三联']='三联帮柯志华:BAAAKgADCgIIAgAAAA==.',['不会']='不会翻跟斗:BAABKgAFFH8MAAICAAMIxAu6MwCjAAACAAMIxAu6MwCjAAAAAA==.',['丨坐']='丨坐享其橙丨:BAAAKgADCggICAAAAA==.',['丨水']='丨水无月丨:BAACKgAFFH8QAAIGAAMIUhfaGQDaAAAGAAMIUhfaGQDaAAAqAAQKfxgAAwYACAhRFvwvAN0BAAYACAhRFvwvAN0BAAEABAjRE6IWAPMAAAAA.',['丨温']='丨温润如雨丨:BAAAKgAFFAQIAwABKgAFFAgIGQAJAK4GAA==.',['丨荒']='丨荒丨:BAAAKgAFFAcIBAAAAA==.',['九耀']='九耀丶巡天:BAAAKgAECggICwAAAA==.',['五皇']='五皇子玄造:BAAAKgAFFAQIAgAAAA==.',['亚森']='亚森罗萍:BAAAKgADCggICAAAAA==.',['人民']='人民志愿牛:BAAAKgADCgEIAQAAAA==.',['仙儿']='仙儿:BAACKgAFFH8sAAIQAAgIeBhrBQC6AQAQAAgIeBhrBQC6AQAqAAQKfzcAAhAACAiBJesBAP0CABAACAiBJesBAP0CAAAA.',['以父']='以父之名:BAAAKgADCgMIAwAAAA==.',['伊利']='伊利达雷力量:BAAAKgAFFAIIAgAAAA==.',['你又']='你又咋啦:BAAAKgAFFAgIAgAAAA==.',['你看']='你看我黑不黑:BAACKgAFFH8JAAIGAAUIxBppCgBQAQAGAAUIxBppCgBQAQAqAAQKfxcABAYACAjVHzobAFECAAYACAiBHzobAFECAAEAAwgdFsVyAIoAAAUAAQhdHzxsAFIAAAEqAAUUCAgWAAwA6BIA.',['依缘']='依缘:BAAAKgADCggICQAAAA==.',['八十']='八十八十:BAABKgAFFH8OAAIKAAYIuhvOEQDPAQAKAAYIuhvOEQDPAQAAAA==.',['公瑾']='公瑾周:BAAAKgADCgMIAwAAAA==.',['兰小']='兰小鱼:BAAAKgADCggICAAAAA==.',['册那']='册那丶队长:BAACKgAFFH8TAAIRAAQIzSASEgAZAQARAAQIzSASEgAZAQAqAAQKfxgAAhEACAjEG8kTAPUBABEACAjEG8kTAPUBAAEqAAUUBggtAAQAYSUA.',['再战']='再战明天:BAABKgAFFH8MAAISAAgImg0rBgC3AQASAAgImg0rBgC3AQAAAA==.',['冰糖']='冰糖葫芦:BAAAKgADCgcIDQAAAA==.',['凤雏']='凤雏丶:BAAAKgAFFAIIAgAAAA==.',['别致']='别致牛哥:BAAAKgAECgEIAQAAAA==.',['剥壳']='剥壳凹槽:BAAAKgADCgEIAQAAAA==.',['加君']='加君鹏:BAAAKgADCggICQAAAA==.',['勤出']='勤出宝:BAAAKgAFFAgIBAAAAA==.',['十三']='十三点切粑粑:BAAAKgADCgEIAQAAAA==.',['千早']='千早爱音:BAAAKgAECgEIAQAAAA==.',['千祥']='千祥龟:BAAAKgAECggICAAAAA==.',['南希']='南希:BAABKgAFFH8IAAITAAgIHBqDAgB5AgATAAgIHBqDAgB5AgAAAA==.',['卡内']='卡内奇:BAABKgAFFH8LAAIKAAYIvxEdKgA/AQAKAAYIvxEdKgA/AQAAAA==.',['卡奇']='卡奇诺软糖:BAAAKgAFFAQIAgAAAA==.',['卡米']='卡米娜:BAAAKgAECgUIBQAAAA==.',['卷卷']='卷卷尾小兔子:BAAAKgAFFAMIAwAAAA==.',['双采']='双采增辉:BAACKgAFFH8OAAMUAAQIFxq3IAC/AAAUAAQIFxq3IAC/AAAVAAII9BbwBgCGAAAqAAQKfx4AAxQACAhvGEkbAOMBABQACAhvGEkbAOMBABUABQgUFzgQAFkBAAAA.',['古二']='古二爷:BAABKgAECn8VAAQPAAgIhxGLSACKAQAPAAgIZBGLSACKAQAOAAEI2gnVNwAZAAASAAEIvAKvlgAZAAAAAA==.',['可爱']='可爱的小涩郎:BAACKgAFFH8SAAIWAAMILBPGJACwAAAWAAMILBPGJACwAAAqAAQKfxUAAhYACAgYEaouAIkBABYACAgYEaouAIkBAAAA.',['右手']='右手的战释:BAAAKgAFFAQIBAAAAA==.',['叶凌']='叶凌枫:BAABKgAFFH8IAAINAAMI6xczGADmAAANAAMI6xczGADmAAAAAA==.',['叶赫']='叶赫樱雪飝蕜:BAAAKgAECgEIAQAAAA==.',['同济']='同济大药房:BAAAKgADCgYIBgABKgADCggICAALAAAAAA==.',['君子']='君子自强:BAAAKgAECgEIAQAAAA==.',['呆丨']='呆丨呆弟:BAAAKgAECgYIEQAAAA==.',['呆小']='呆小弟:BAAAKgAECgQICAAAAA==.',['呆弟']='呆弟弟:BAAAKgAFFAIIAwAAAA==.',['咖啡']='咖啡乌:BAABKgAFFH8HAAIDAAQIMBI3LQDGAAADAAQIMBI3LQDGAAAAAA==.',['咩咩']='咩咩兔丶:BAAAKgAFFAQIAwAAAA==.',['哈丽']='哈丽波特:BAABKgAFFH8GAAIEAAYINgtnFwAkAQAEAAYINgtnFwAkAQAAAA==.',['哑巴']='哑巴湖大水怪:BAAAKgADCgQIBAAAAA==.',['哥们']='哥们打酱油滴:BAAAKgAECgMIAwAAAA==.',['唐小']='唐小粑:BAAAKgAECgMIBgAAAA==.',['唢呐']='唢呐流氓:BAAAKgAECggICAAAAA==.',['啊对']='啊对对:BAAAKgAECgQIBAAAAA==.',['喵见']='喵见团子:BAAAKgAECgIIAgAAAA==.',['回灬']='回灬憶:BAABKgAFFH8NAAMHAAQIjRPAIQCZAAAIAAQIswzTOAC4AAAHAAQIjRPAIQCZAAAAAA==.',['土萌']='土萌萤:BAABKgAFFH8IAAIXAAgI+w3XBwD5AQAXAAgI+w3XBwD5AQAAAA==.',['圣光']='圣光之心:BAAAKgAECgIIAgAAAA==.圣光暗陌玤:BAAAKgAECggICAAAAA==.圣光释小槐:BAAAKgAFFAIIAgAAAA==.',['在干']='在干嘛鸭:BAAAKgAECggICAAAAA==.',['坠落']='坠落不停:BAAAKgAFFAYIAQAAAA==.',['堕落']='堕落之焮:BAABKgAFFH8IAAMMAAcIjBgvAgDAAQAMAAYISRcvAgDAAQAYAAEI2R57EQBdAAAAAA==.',['夜夕']='夜夕梦:BAABKgAFFH8PAAMZAAYILBKrFQDnAAAZAAQIJRirFQDnAAAWAAIINgnVLwCHAAAAAA==.',['夜巡']='夜巡灵:BAAAKgAECggICAAAAA==.',['夜牧']='夜牧:BAABKgAFFH8GAAIZAAIIchxqFwCkAAAZAAIIchxqFwCkAAAAAA==.',['夜风']='夜风澜落:BAAAKgADCgEIAQAAAA==.',['大偉']='大偉爺:BAAAKgADCgIIAgAAAA==.',['大地']='大地守护者:BAAAKgAECgYIBgAAAA==.',['大瓦']='大瓦力:BAAAKgAECggICAAAAA==.',['大航']='大航海时代:BAAAKgADCgQIBAAAAA==.',['天南']='天南第一剑修:BAAAKgAECgQICAAAAA==.',['天山']='天山美少女:BAABKgAECn8lAAMJAAgIlhqSGwCFAQAJAAgIlhqSGwCFAQAKAAQIQRiRxADMAAAAAA==.',['失眠']='失眠丶画家:BAABKgAFFH8GAAIHAAYIsBYoDABQAQAHAAYIsBYoDABQAQAAAA==.',['夷有']='夷有个靓仔:BAAAKgADCgMIAwABKgADCggICAALAAAAAA==.',['奈奈']='奈奈:BAAAKgADCgYIBgAAAA==.',['奥古']='奥古斯塔丶:BAAAKgAFFAIIAgAAAA==.',['奥妮']='奥妮克希:BAAAKgAFFAIIAgAAAA==.',['奥巴']='奥巴牛:BAAAKgADCgQIBAAAAA==.',['奥格']='奥格之斧:BAABKgAFFH8GAAIaAAYIyAszEQBDAQAaAAYIyAszEQBDAQAAAA==.',['奶一']='奶一口小白兔:BAAAKgAFFAgIAgAAAA==.',['奶油']='奶油烩饭粒:BAAAKgAFFAgIBAAAAA==.',['奶瓶']='奶瓶子:BAAAKgADCggICAAAAA==.',['好身']='好身材看得见:BAAAKgAECgYIBgAAAA==.',['妖狐']='妖狐:BAAAKgAECgIIAwAAAA==.',['姜似']='姜似:BAAAKgAECgQIAwAAAA==.',['媛小']='媛小贝丶:BAAAKgAECggICAABKgAFFAgIEQAPAEEeAA==.',['嫒之']='嫒之矢影歌:BAABKgAECn8eAAIXAAgIDx3LQAD1AQAXAAgIDx3LQAD1AQAAAA==.嫒之语影风:BAAAKgADCggICAAAAA==.',['孟德']='孟德思旧:BAAAKgAFFAEIAQAAAA==.',['宇间']='宇间星痕:BAABKgAFFH8IAAIGAAQIwB/VEwAAAQAGAAQIwB/VEwAAAQAAAA==.',['安度']='安度因丶:BAABKgAFFH8JAAIKAAgIARR8GgD2AAAKAAgIARR8GgD2AAAAAA==.',['宋帝']='宋帝丶:BAAAKgADCgUIBQAAAA==.',['完颜']='完颜容:BAAAKgAFFAgIBAAAAA==.',['宝哥']='宝哥哥:BAAAKgAECgUIBwAAAA==.',['宵町']='宵町忍:BAAAKgADCgIIAgAAAA==.',['寂静']='寂静的猎弓:BAAAKgAFFAYIBAABKgAFFAgIBAALAAAAAA==.',['寒殇']='寒殇:BAAAKgAECgQIBAAAAA==.',['寶寶']='寶寶真乖:BAAAKgAECggICAAAAA==.',['寻道']='寻道:BAAAKgAFFAQIBAAAAA==.',['将功']='将功成万骨枯:BAAAKgAFFAIIAgAAAA==.',['小井']='小井亚津子:BAAAKgAECgYIBwAAAA==.',['小坏']='小坏:BAABKgAFFH8GAAIMAAYIOgsbGgA0AQAMAAYIOgsbGgA0AQAAAA==.',['小抱']='小抱枕:BAAAKgADCgYIBgAAAA==.',['小栗']='小栗子:BAAAKgADCgIIAgAAAA==.',['小熊']='小熊欧妮酱:BAABKgAFFH8vAAMMAAgIqyTJAgCSAgAMAAgIqyTJAgCSAgAYAAUIoR/jBAAoAQAAAA==.',['小紅']='小紅豆:BAABKgAFFH8GAAIBAAYIZAt1DwA2AQABAAYIZAt1DwA2AQAAAA==.',['小红']='小红手张雨霏:BAAAKgAFFAQIBAAAAA==.小红手脖子:BAAAKgAECgMIAQAAAA==.',['就打']='就打德:BAABKgAFFH8IAAMPAAgIAg04DgCOAQAPAAcI3Ao4DgCOAQASAAEIvQJvGAA6AAAAAA==.',['山碧']='山碧空:BAAAKgAECgEIAQAAAA==.',['山鬼']='山鬼花钱:BAAAKgAFFAQIBAAAAA==.',['巧克']='巧克力冰淇淋:BAAAKgADCgQIBAAAAA==.',['巴吉']='巴吉度:BAAAKgADCgEIAQAAAA==.',['布冧']='布冧果酱:BAAAKgAECggIEwAAAA==.',['布谷']='布谷鳥:BAABKgAFFH8IAAIXAAgIWRfoBQA0AgAXAAgIWRfoBQA0AgAAAA==.',['希贝']='希贝尔:BAAAKgAECgYICAAAAA==.',['帕瑟']='帕瑟芬尼:BAAAKgADCgEIAgAAAA==.',['幺妹']='幺妹来一发吧:BAABKgAFFH8IAAMCAAYIxw17GAAlAQACAAYIxw17GAAlAQAXAAIIgwIFTAA/AAAAAA==.',['幻兽']='幻兽钠鲁:BAACKgAFFH8TAAMbAAUIHBHiEwDeAAAbAAUIHBHiEwDeAAAZAAII9RaxGwCNAAAqAAQKfyUABBsACAgUIwYJAKwCABsACAgUIwYJAKwCABYABQjUJKo4AFoBABkAAwizDJ9bAK8AAAEqAAUUCAglABQACCEA.',['弃天']='弃天帝:BAAAKgAFFAQIBAAAAA==.',['德不']='德不尝尸米:BAAAKgAECgEIAQAAAA==.',['念念']='念念美好时光:BAABKgAFFH8GAAIGAAYILxAuBwCSAQAGAAYILxAuBwCSAQAAAA==.',['恋花']='恋花蝶舞:BAABKgAFFH8NAAMYAAMIzA04KQBHAAAMAAIIMQkLQABsAAAYAAEIAhc4KQBHAAAAAA==.',['恋静']='恋静曦:BAACKgAFFH8NAAIGAAMIVBniGADjAAAGAAMIVBniGADjAAAqAAQKfx4AAgYACAiaHSAaAFcCAAYACAiaHSAaAFcCAAAA.',['恶龙']='恶龙咆哮喔:BAAAKgAECgYIBgAAAA==.',['慕容']='慕容重复:BAAAKgAFFAgIBAAAAA==.',['慕小']='慕小兮:BAAAKgAFFAQIBAABKgAFFAgICgAWANkWAA==.',['我叫']='我叫焰焰:BAACKgAFFH8IAAIXAAMIKw3VNwC4AAAXAAMIKw3VNwC4AAAqAAQKfx4AAhcACAivHisdAFECABcACAivHisdAFECAAAA.',['我是']='我是红牛:BAAAKgADCggICAAAAA==.',['战争']='战争雷霆:BAAAKgAECgUIBQAAAA==.',['战江']='战江湖:BAAAKgAECgMIAwAAAA==.',['抽动']='抽动的挣扎:BAAAKgADCgUIBQAAAA==.',['拓跋']='拓跋珪:BAABKgAFFH8IAAIKAAQImBjMJgDXAAAKAAQImBjMJgDXAAAAAA==.',['招蜂']='招蜂引蝶:BAAAKgAFFAEIAQAAAA==.',['掌控']='掌控大菊:BAABKgAFFH8OAAMEAAYIiiKYBQD6AQAEAAYIiiKYBQD6AQAcAAMIahBlHwCAAAABKgAFFAgIFAAEAFUjAA==.',['揮霍']='揮霍夏天:BAAAKgAFFAIIAgAAAA==.',['敏菲']='敏菲利亚:BAABKgAFFH8YAAMCAAgIFAZ9CgBwAQAXAAgIlgOVDABwAQACAAgI0QV9CgBwAQAAAA==.',['整点']='整点薯条:BAAAKgAECgYICAABKgAFFAgICAAaALMSAA==.',['斩地']='斩地乄:BAAAKgAECgMIAwAAAA==.',['新手']='新手村村花:BAAAKgAECgUIBgAAAA==.',['无妄']='无妄者:BAAAKgADCgIIAgAAAA==.',['无形']='无形之刃丶:BAACKgAFFH8oAAIDAAYIaxq8DwCKAQADAAYIaxq8DwCKAQAqAAQKfycAAgMACAiKH3kcAFkCAAMACAiKH3kcAFkCAAAA.',['时雨']='时雨:BAAAKgAECgUIBQABKgAECgYICQALAAAAAA==.',['星语']='星语星原:BAAAKgAECgQIBAAAAA==.',['晨曦']='晨曦风行耀:BAAAKgAFFAIIAgAAAA==.',['暗之']='暗之星光:BAAAKgAFFAQIBAAAAA==.',['曰理']='曰理万基:BAABKgAECn8cAAIEAAgIOhhHOACUAQAEAAgIOhhHOACUAQAAAA==.',['杀耳']='杀耳:BAAAKgADCgQIBAAAAA==.',['杏仁']='杏仁核桃饼:BAAAKgAECgUIBQAAAA==.',['极度']='极度重犯:BAAAKgAFFAEIAQAAAA==.',['枫棂']='枫棂:BAAAKgAECgMIAwAAAA==.',['枯法']='枯法者:BAABKgAFFH8OAAIMAAgIcxQMBwAhAgAMAAgIcxQMBwAhAgAAAA==.',['梁小']='梁小朋友:BAAAKgADCggICAAAAA==.',['榨菜']='榨菜牛肉:BAAAKgAECgUIBQAAAA==.',['欲星']='欲星移:BAABKgAFFH8IAAMWAAgIJgN1EAAvAQAWAAcI7AJ1EAAvAQAZAAEIgQTcMQBDAAAAAA==.',['水佩']='水佩风赏:BAAAKgAFFAUIBAAAAA==.',['永不']='永不落幕:BAAAKgAECggIEAAAAA==.',['汐水']='汐水如嫣丶:BAABKgAFFH8MAAMDAAYIkA9vFQBPAQADAAYIUg9vFQBPAQAdAAYIuwZ9DQDdAAABKgAFFAgIEAAIAFIZAA==.',['江勋']='江勋惠:BAAAKgAECgEIAQAAAA==.',['江南']='江南一盗:BAABKgAFFH8GAAINAAYI0g+wDgBmAQANAAYI0g+wDgBmAQAAAA==.江南一邪:BAABKgAFFH8MAAMHAAYIIRPPAgByAQAIAAYIqgh4BAB5AQAHAAYIIRPPAgByAQAAAA==.',['沉鱼']='沉鱼:BAAAKgAECggICwAAAA==.',['沧海']='沧海日:BAAAKgADCggICAAAAA==.',['河马']='河马睡大觉:BAAAKgAFFAgIBAAAAA==.',['法号']='法号破色:BAAAKgAFFAEIAQAAAA==.',['洵子']='洵子:BAABKgAFFH8FAAMBAAQIdhpCJwDFAAABAAQIdhpCJwDFAAAFAAEIAADtJgAAAAAAAA==.',['流水']='流水无弦:BAACKgAFFH8lAAMUAAYICCGEDACcAQAUAAYICCGEDACcAQAVAAUIpB+fAABrAQAqAAQKfxsAAxUACAgnGRkIAAECABUACAgnGRkIAAECABQACAhXFt8sAFMBAAAA.',['浮沉']='浮沉:BAAAKgAFFAgIBAAAAA==.',['涩小']='涩小美:BAABKgAFFH8HAAIEAAMIihGsMgCvAAAEAAMIihGsMgCvAAAAAA==.',['混乱']='混乱的塔罗斯:BAAAKgADCggICAAAAA==.',['清雨']='清雨:BAAAKgAECgIIAgAAAA==.',['清音']='清音:BAABKgAFFH8KAAQWAAYIHBahGwDgAAAWAAQIeSGhGwDgAAAbAAIIzxqyHQCZAAAZAAIILw6gKQBvAAAAAA==.',['火云']='火云邪神:BAABKgAFFH8IAAMBAAgIqQunFwAnAQABAAQIRwynFwAnAQAFAAQI1gq6HgCQAAAAAA==.',['火炎']='火炎焱艾:BAAAKgADCggICAAAAA==.',['灰烬']='灰烬:BAABKgAFFH8MAAMeAAgIkxNWBgDAAQAeAAgIkxNWBgDAAQAJAAQIYgrqCQC+AAAAAA==.',['灰色']='灰色战火:BAAAKgAECgUIBgABKgAFFAMIDQAFAOsXAA==.',['灵魂']='灵魂引导者:BAABKgAFFH8GAAMZAAYIrwECIgCbAAAZAAUIUAECIgCbAAAWAAEILAMaPgBCAAABKgAFFAgIHAAPADYlAA==.灵魂得叹息:BAACKgAFFH8vAAIaAAgIiSEFAgC5AgAaAAgIiSEFAgC5AgAqAAQKfzIAAhoACAjeJYMFAOMCABoACAjeJYMFAOMCAAAA.',['炫烈']='炫烈风尘:BAAAKgADCggICAAAAA==.',['然然']='然然带我走吧:BAABKgAFFH8NAAIXAAMIGg3FOQCzAAAXAAMIGg3FOQCzAAAAAA==.',['煙熏']='煙熏鱼籽醬:BAABKgAFFH8IAAIZAAgIChvxAQBtAgAZAAgIChvxAQBtAgAAAA==.',['燃烧']='燃烧吧少年:BAACKgAFFH8GAAIFAAMINxPnFQC/AAAFAAMINxPnFQC/AAAqAAQKfx4AAgUACAgZGzAlAO0BAAUACAgZGzAlAO0BAAAA.',['爱尔']='爱尔兰小花生:BAABKgAFFH8IAAMCAAQIwyEhBAAwAQACAAQITiEhBAAwAQAXAAQIwhhgFQD4AAAAAA==.',['爱梅']='爱梅特赛尔号:BAABKgAECn8WAAIGAAgIjQdtJwD2AAAGAAgIjQdtJwD2AAAAAA==.',['牛哥']='牛哥锤双灯:BAAAKgAECgMIAwAAAA==.牛哥锤双胸:BAABKgAFFH8IAAINAAgIpg/iBAAlAgANAAgIpg/iBAAlAgAAAA==.',['牛市']='牛市变熊市:BAAAKgADCgQIBAAAAA==.',['牛牛']='牛牛不洗澡:BAACKgAFFH8NAAIKAAYI0B98FgCoAQAKAAYI0B98FgCoAQAqAAQKfygAAgoACAgbJVQNAOMCAAoACAgbJVQNAOMCAAEqAAUUCAgsABAAeBgA.',['牛的']='牛的草:BAAAKgADCggICAAAAA==.',['牛肉']='牛肉烤肠丶:BAAAKgADCgIIAgAAAA==.',['牛鞭']='牛鞭老妖:BAAAKgADCgEIAQAAAA==.',['狂暴']='狂暴之伤:BAAAKgAECggIEQAAAA==.',['狂狂']='狂狂小威威:BAABKgAFFH8HAAMMAAQIHhOnKQDHAAAMAAQIHhOnKQDHAAAfAAMIaw6OFwCCAAAAAA==.',['狂风']='狂风小小猎:BAAAKgADCggICAAAAA==.',['玖尾']='玖尾妖猫:BAABKgAFFH8IAAIPAAQIixFwIAC4AAAPAAQIixFwIAC4AAAAAA==.',['玖战']='玖战:BAAAKgAFFAQIBAAAAA==.',['玖星']='玖星连珠:BAABKgAFFH8IAAMZAAQIkxITDQDtAAAZAAQIkxITDQDtAAAWAAQIhAOtNABuAAAAAA==.',['玖玖']='玖玖归一:BAABKgAFFH8IAAIHAAQIBBY6FgCdAAAHAAQIBBY6FgCdAAAAAA==.',['玛玛']='玛玛米雅:BAABKgAFFH8MAAMPAAYIUg+hEABcAQAPAAYIUg+hEABcAQASAAYIkgNcGADdAAAAAA==.',['班开']='班开电:BAAAKgAFFAYIAgAAAA==.',['瓦格']='瓦格翰德:BAAAKgAECgIIAgAAAA==.',['甜到']='甜到你心里:BAAAKgAFFAIIAgAAAA==.',['甲辰']='甲辰一号:BAACKgAFFH8IAAIFAAMIVRQkFgC+AAAFAAMIVRQkFgC+AAAqAAQKfx4AAgUACAhAHMMXAEICAAUACAhAHMMXAEICAAEqAAUUCAgOAAYAwyIA.',['电萨']='电萨:BAAAKgADCggICAAAAA==.',['疯狂']='疯狂大黑熊:BAAAKgAECggICAAAAA==.疯狂大黑牛:BAABKgAFFH8MAAMXAAgIMiCuEQBqAQAXAAgIJR6uEQBqAQACAAQIJxfFKQDDAAAAAA==.',['發财']='發财:BAAAKgADCgIIAgAAAA==.',['白色']='白色伊布:BAAAKgAECgYIBgAAAA==.',['站在']='站在云端的鸡:BAAAKgAECggIEgAAAA==.',['简简']='简简丶单单:BAAAKgADCgMIAwAAAA==.',['簡簡']='簡簡丶單單:BAAAKgAECgEIAQAAAA==.',['紫玫']='紫玫瑰:BAAAKgAFFAgIAgAAAA==.',['紫颜']='紫颜:BAAAKgAFFAgIAQAAAA==.',['红之']='红之机神将:BAABKgAECn8WAAIKAAgI7g0nrAD3AAAKAAgI7g0nrAD3AAAAAA==.',['纳阿']='纳阿鲁之力:BAAAKgAECgQIBAAAAA==.',['纳马']='纳马丽丽:BAAAKgAFFAQIBAAAAA==.',['绫波']='绫波俪:BAABKgAFFH8IAAICAAgIBBJxCADVAQACAAgIBBJxCADVAQAAAA==.',['维斯']='维斯:BAAAKgAFFAIIBAAAAA==.',['缪言']='缪言:BAAAKgADCgEIAQAAAA==.',['胡帕']='胡帕:BAAAKgAFFAYIBAAAAA==.',['腰骨']='腰骨太硬了:BAAAKgADCgYIBgAAAA==.',['臭迪']='臭迪:BAAAKgADCgUIBQAAAA==.',['苏西']='苏西玛丽苏:BAACKgAFFH8tAAIEAAQIYSWFBgAlAQAEAAQIYSWFBgAlAQAqAAQKfx8AAgQACAgDIycJAK0CAAQACAgDIycJAK0CAAAA.',['莉莉']='莉莉哈特:BAAAKgAECgQIBQAAAA==.',['莱轲']='莱轲尼:BAAAKgADCggIFAAAAA==.',['菊花']='菊花喂米青:BAAAKgADCgIIAgAAAA==.',['菠萝']='菠萝山大王:BAAAKgAECgQIBAAAAA==.',['菲龙']='菲龙在天:BAAAKgAECgcIBwAAAA==.',['萌萌']='萌萌德开水:BAAAKgAECggIEwAAAA==.',['蓝色']='蓝色闪电:BAABKgAFFH8GAAIQAAYI1BqkBgCEAQAQAAYI1BqkBgCEAQABKgAFFAgIBAALAAAAAA==.',['蕾茉']='蕾茉妮雅:BAABKgAFFH8IAAIZAAgInRlKAgAkAgAZAAgInRlKAgAkAgAAAA==.',['藏马']='藏马:BAAAKgAFFAEIAQAAAA==.',['螺旋']='螺旋棉花棒:BAAAKgAFFAYIBAAAAA==.',['血之']='血之沸腾:BAAAKgAFFAQIBAAAAA==.',['血饮']='血饮狂刀:BAAAKgAFFAEIAQAAAA==.',['请容']='请容我失礼了:BAABKgAFFH8OAAMHAAYIgxH2EQATAQAHAAYINg/2EQATAQAIAAQInBO8MQDMAAABKgAFFAgIDgAIAEoXAA==.',['豆沙']='豆沙包:BAABKgAFFH8KAAMKAAYILBrxLQAwAQAKAAUIEh/xLQAwAQAJAAUIiQYoDADoAAAAAA==.',['豹子']='豹子头丶林冲:BAABKgAECn8WAAMCAAgILSIWEgBoAgACAAgILSIWEgBoAgAXAAMImhzwlgD8AAAAAA==.',['貝璐']='貝璐丹蒂:BAAAKgAECgMIBAAAAA==.',['贰月']='贰月丶逆流:BAAAKgAFFAQIBAAAAA==.',['赫连']='赫连宝:BAAAKgAFFAQIBAAAAA==.',['转角']='转角遇见你:BAAAKgADCgIIAgAAAA==.',['辉月']='辉月:BAAAKgADCgMIAwABKgAFFAQICAAGAMAfAA==.',['过期']='过期芬达:BAAAKgAECgYIDQAAAA==.',['郁闷']='郁闷小牛:BAAAKgAFFAgIAgAAAA==.',['释槐']='释槐:BAACKgAFFH82AAMEAAYIASJHBAA+AQAEAAYIASJHBAA+AQAcAAUIIxGiCwATAQAqAAQKfx8AAgQACAhWHSoeACACAAQACAhWHSoeACACAAAA.',['野蔷']='野蔷薇妹妹:BAAAKgAECggICAAAAA==.',['铁邦']='铁邦邦:BAABKgAFFH8KAAMUAAYIXxYjEwA5AQAUAAYIXxYjEwA5AQAVAAQIBSAXAgARAQAAAA==.',['锺離']='锺離有糖:BAAAKgAFFAQIBAAAAA==.',['长情']='长情君:BAAAKgAFFAQIAwABKgAFFAgIAwALAAAAAA==.',['闪电']='闪电五牛鞭:BAAAKgADCgYIAwAAAA==.',['阿勒']='阿勒斯蠱:BAAAKgADCgYIBgAAAA==.',['阿卡']='阿卡西斯:BAAAKgADCgYIBgAAAA==.',['阿塔']='阿塔岚忒:BAAAKgAFFAQIAQAAAA==.',['阿柏']='阿柏柏:BAABKgAFFH8IAAICAAgI8RL0BgD2AQACAAgI8RL0BgD2AQAAAA==.',['阿歪']='阿歪:BAABKgAFFH8IAAIIAAQIzh6jDAAJAQAIAAQIzh6jDAAJAQAAAA==.',['阿离']='阿离:BAAAKgADCggICAABKgAFFAQICAAGAMAfAA==.',['陆柒']='陆柒夜:BAABKgAFFH8IAAIZAAQIehu7CgD/AAAZAAQIehu7CgD/AAAAAA==.',['雨过']='雨过留影:BAAAKgAFFAQIBAAAAA==.',['零捌']='零捌伍肆:BAABKgAFFH8PAAMWAAYIlRa1AQBOAQAWAAUIyRu1AQBOAQAZAAUIwwrtBwAaAQAAAA==.',['雷霆']='雷霆萨萨:BAAAKgADCggICAAAAA==.',['霜之']='霜之哀觞:BAAAKgADCgMIAwAAAA==.',['霜杯']='霜杯雪盏:BAAAKgAFFAgIBAAAAA==.',['静幽']='静幽暗魔丶:BAAAKgAFFAgIAQAAAA==.静幽菠忒丶:BAABKgAFFH8KAAMYAAYIxht7AgAdAQAYAAQIMCN7AgAdAQAMAAIIqBAAAAAAAAAAAA==.',['風之']='風之圣痕:BAAAKgAECgYIBwAAAA==.',['风之']='风之迅捷:BAABKgAFFH8KAAMXAAcIyRkwDQAcAQAXAAQIgCAwDQAcAQACAAMIEhNIEgDZAAAAAA==.',['风语']='风语之魂:BAACKgAFFH8IAAIRAAMIhBILHAC9AAARAAMIhBILHAC9AAAqAAQKfxUAAhEACAiYHGMTAE0CABEACAiYHGMTAE0CAAAA.',['风骚']='风骚猎神:BAABKgAFFH8PAAMCAAYIax68DQB/AQACAAYIax68DQB/AQAXAAIIxQckPwBtAAAAAA==.',['馒头']='馒头哥:BAAAKgADCgYIBgAAAA==.',['馨颜']='馨颜:BAAAKgAECggICAAAAA==.',['马鬃']='马鬃蛇:BAAAKgADCggICAAAAA==.',['骑不']='骑不动马:BAABKgAFFH8OAAIKAAMIaB8cPwD0AAAKAAMIaB8cPwD0AAAAAA==.',['骑皇']='骑皇下凡:BAAAKgAFFAIIAgAAAA==.',['骑马']='骑马的王子:BAAAKgADCgYICAAAAA==.',['骨感']='骨感美人:BAAAKgAECgYIBgAAAA==.',['魅惑']='魅惑芯莘:BAACKgAFFH8KAAMNAAYIGyKaAAD8AQANAAYIoSGaAAD8AQAgAAQIjSHcAwAaAQAqAAQKfxYAAg0ACAh3EAkbAKwBAA0ACAh3EAkbAKwBAAEqAAUUCAgFAA0ASQ4A.',['鹤鸣']='鹤鸣九皋:BAAAKgAECgcIDwAAAA==.',['麥满']='麥满分:BAABKgAFFH8iAAQTAAYI3RW0CABhAQATAAYIahW0CABhAQAhAAQIDhu7AgDgAAARAAYIfQyJEgDaAAAAAA==.',['麥茬']='麥茬麥茶:BAABKgAFFH8JAAICAAMICAWNPgB+AAACAAMICAWNPgB+AAAAAA==.',['麦克']='麦克絲丶:BAABKgAECn8XAAQYAAgIrB2nIACIAQAYAAUItBmnIACIAQAMAAcIlhj+LABiAQAfAAEI0QdVQQAuAAAAAA==.',['麻酱']='麻酱姑娘:BAABKgAFFH8RAAQMAAcIyRQ0AwCYAQAMAAcIgxM0AwCYAQAfAAQIEBOUEgCoAAAYAAEIJwGKHABAAAAAAA==.',['麽哈']='麽哈:BAAAKgAECgIIAgAAAA==.',['黄艺']='黄艺博:BAAAKgAFFAMIAwAAAA==.',['黑石']='黑石萌主:BAAAKgAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end