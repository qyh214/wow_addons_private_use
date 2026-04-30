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
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Warlock-Demonology','Mage-Frost','Mage-Fire','Mage-Arcane','Shaman-Restoration','Shaman-Elemental','Priest-Discipline','Monk-Brewmaster','Warrior-Protection','Paladin-Retribution','Rogue-Subtlety','Rogue-Assassination','Unknown-Unknown','Monk-Windwalker','Monk-Mistweaver','Druid-Restoration','DeathKnight-Unholy','Warlock-Affliction','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Priest-Shadow','Priest-Holy','Warrior-Arms','DeathKnight-Blood','Druid-Balance',}
local provider = {region='CN',realm='羽月',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aisha:BAAALgAECgkJCQAAAA==.',
Ar='Arcueidbs:BAAALgADCgIJAgAAAA==.Artemisdw:BAAALgAFFAQJAwAAAA==.',
Bl='Blood:BAABLgAFFH8IAAIBAAQJ3B3wBABwAQABAAQJ3B3wBABwAQAAAA==.',
Cr='Crazyseven:BAAALgAECgYJCwAAAA==.',
Cx='Cxznb:BAAALgAECgQJBAAAAA==.',
Da='Daseinblume:BAAALgAECgYJBgAAAA==.',
Ed='Edward:BAAALgAECgEJAQAAAA==.',
El='Elza:BAAALgAFFAIJAwAAAA==.',
En='Enkrid:BAAALgAECgQJBAAAAA==.',
Fo='Formandy:BAAALgAECgUJBQAAAA==.',
Ic='Icespicy:BAAALgAECgIJAgAAAA==.',
Mi='Miinjure:BAAALgAFFAQJBAAAAA==.Mirrid:BAAALgAECgYJBwAAAA==.',
Pr='Prometheus:BAACLgAFFH8GAAMCAAMJyw6vIQCvAAACAAMJyw6vIQCvAAADAAEJ5geLAQBPAAAuAAQKfx4ABAMABwnWGwQFAHoBAAIABwl7GDB2AOYBAAMABAmAIgQFAHoBAAQAAgnWBvAVAGwAAAAA.',
Ri='Rita:BAAALgAECgQJBgAAAA==.',
Ro='Rosicky:BAAALgAECgcJBwAAAA==.',
Se='Serein:BAAALgADCgEJAQAAAA==.',
Sn='Snowteas:BAAALgAECggJCAAAAA==.',
Th='Thierry:BAABLgAECn8gAAMFAAgJ3iL6DQCrAgAFAAgJ3iL6DQCrAgAGAAcJZRenJADrAQABLgAFFAcJBwAHAJAaAA==.',
Xc='Xcjxcj:BAAALgAECgEJAQAAAA==.',
Ye='Yez:BAAALgAECgUJCQAAAA==.',
Ys='Ysasuka:BAAALgAECgQJCgAAAA==.',
Za='Zahzy:BAAALgAECgEJAQAAAA==.Zakty:BAAALgAECgUJCQAAAA==.Zaty:BAAALgAECgEJAQAAAA==.',
['一头']='一头大黑牛:BAAALgADCgIJAgAAAA==.',
['一箭']='一箭追月:BAAALgADCgcJCgAAAA==.',
['上弦']='上弦月:BAAALgAECgYJDwAAAA==.',
['不可']='不可撼动:BAAALgAECgYJBgABLgAECggJFQAIAFMMAA==.',
['不好']='不好点长肥了:BAAALgAECgMJAwABLgAFFAYJEwAJAC8ZAA==.',
['不懂']='不懂喝酒:BAAALgAECgkJCwAAAA==.',
['专属']='专属妳的温柔:BAAALgAECgYJCAAAAA==.',
['严禁']='严禁拍打喂食:BAAALgAECgUJBQAAAA==.',
['丨克']='丨克莱茵:BAACLgAFFH8KAAIKAAYJdwjdAQCKAQAKAAYJdwjdAQCKAQAuAAQKfxYAAgoACQnxFL1mALMBAAoACQnxFL1mALMBAAAA.',
['丨紫']='丨紫丶小囡:BAAALgAECgYJDAAAAA==.',
['乐无']='乐无忧:BAAALgAECgYJBwAAAA==.',
['五條']='五條悟:BAAALgAECgcJBwAAAA==.',
['交给']='交给小蜗吧:BAABLgAFFH8IAAMLAAQJPSHFAACiAQALAAQJVB7FAACiAQAMAAQJ/Bc/AQCDAQABLgAFFAUJEAALAC8lAA==.',
['今翅']='今翅扑街鸟:BAAALgAECgcJBwAAAA==.',
['伊本']='伊本人:BAAALgAECgQJBAAAAA==.',
['伊莎']='伊莎娜灬:BAAALgAECgMJAwAAAA==.伊莎娜灬塔林:BAAALgAECgUJAQAAAA==.',
['伊落']='伊落玛丽:BAAALgAECgcJEAABLgAECgIJAQANAAAAAA==.',
['伤懐']='伤懐:BAAALgAECgYJBgAAAA==.',
['低抛']='低抛高吸:BAAALgAECgkJBgAAAA==.',
['你你']='你你我我他他:BAAALgAECgQJBQAAAA==.',
['依能']='依能:BAAALgAECgYJBgAAAA==.',
['信仰']='信仰之依月:BAAALgAECggJDwAAAA==.信仰之依滢:BAAALgAECgYJBgAAAA==.',
['倚竹']='倚竹听风:BAABLgAECn8aAAMIAAcJGBewKwCvAQAIAAcJGBewKwCvAQAOAAIJYQxQbgBYAAAAAA==.',
['假面']='假面舞會:BAAALgAFFAIJAgAAAA==.',
['偷绝']='偷绝:BAAALgADCgEJAQAAAA==.',
['光灭']='光灭复生:BAAALgAECgUJBQAAAA==.',
['光辉']='光辉圣骑:BAAALgAECgEJAgAAAA==.',
['克己']='克己:BAACLgAFFH8HAAIIAAcJERkwAAAVAgAIAAcJERkwAAAVAgAuAAQKfxgABAgACQmVCvMsAKcBAAgACQmBCvMsAKcBAA4ABgn9BRpNAN0AAA8AAgmXAAR1AB0AAAAA.',
['克莉']='克莉斯灬塔林:BAAALgAECgUJBwAAAA==.',
['公子']='公子羽:BAABLgAECn8jAAICAAgJtROMXgAfAgACAAgJtROMXgAfAgAAAA==.',
['六月']='六月的橘子酱:BAAALgAFFAEJAQAAAA==.',
['冰一']='冰一一带小狗:BAAALgAECgEJAQAAAA==.',
['冰摇']='冰摇马提尼:BAAALgADCgEJAQAAAA==.',
['冰河']='冰河之恋:BAAALgADCgMJAwAAAA==.冰河剑虎:BAAALgAECgEJAQAAAA==.冰河永恒:BAAALgADCgYJBQAAAA==.',
['冰法']='冰法残渣:BAAALgAFFAEJAQAAAA==.',
['冰美']='冰美人:BAAALgAECgEJAQAAAA==.',
['冰鲜']='冰鲜柠檬水:BAAALgAECgcJDQAAAA==.',
['凡尔']='凡尔塞玫瑰:BAABLgAECn8VAAIQAAgJxhNGNQDTAQAQAAgJxhNGNQDTAQAAAA==.',
['凤凰']='凤凰浴火:BAAALgAECgEJAgAAAA==.',
['凨凪']='凨凪風夙:BAAALgAECgUJDAAAAA==.',
['切吧']='切吧切吧:BAAALgAECgQJBAAAAA==.',
['刘青']='刘青云:BAAALgAECgUJBQAAAA==.',
['加诺']='加诺德萨:BAAALgAECgMJBgAAAA==.',
['勇敢']='勇敢犇犇:BAAALgAECgMJAwAAAA==.勇敢的怪蜀黍:BAAALgADCgYJBgAAAA==.',
['北美']='北美小小灰狼:BAAALgAECgYJBgAAAA==.',
['十火']='十火:BAAALgADCgIJAgAAAA==.',
['卖盘']='卖盘枯竭:BAAALgAECgYJCgAAAA==.',
['卡米']='卡米奇亚:BAAALgAECgYJDAAAAA==.',
['却邪']='却邪:BAAALgAFFAIJAgAAAA==.',
['叠最']='叠最厚的甲:BAAALgAFFAEJAQAAAA==.',
['古城']='古城旧梦:BAAALgAECgIJAgAAAA==.',
['只会']='只会拉链子:BAAALgAECgQJCwAAAA==.',
['可以']='可以吗:BAAALgAECgYJCwAAAA==.',
['叶梓']='叶梓易:BAAALgAECgIJBAAAAA==.',
['吃个']='吃个糖:BAAALgADCgEJAQAAAA==.',
['吃菜']='吃菜不留饭:BAAALgAECggJCAAAAA==.',
['吉村']='吉村车钛:BAAALgAECgYJCgAAAA==.',
['名茶']='名茶:BAAALgAECgcJBwAAAA==.',
['和风']='和风细雨:BAABLgAFFH8IAAIKAAMJWx53DwAsAQAKAAMJWx53DwAsAQAAAA==.',
['咩咩']='咩咩毛:BAAALgAECgEJAQAAAA==.',
['咬一']='咬一口软糖:BAAALgAECgYJBgAAAA==.',
['喜欢']='喜欢你让我哭:BAABLgAFFH8IAAILAAQJ+CGdAACrAQALAAQJ+CGdAACrAQABLgAFFAUJEAALAC8lAA==.',
['喝酒']='喝酒不扶墙:BAAALgAECgcJDgAAAA==.',
['嘉琳']='嘉琳黛尔:BAAALgAFFAEJAQAAAA==.',
['国足']='国足四十强:BAAALgAECgEJAQAAAA==.',
['圆溜']='圆溜溜妈咪:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光永不灭:BAAALgAECgQJBAAAAA==.',
['圣剑']='圣剑之辉:BAAALgAECgEJAQAAAA==.',
['在魅']='在魅边:BAAALgAECgYJCgAAAA==.',
['塞恩']='塞恩希尔:BAAALgAECgEJAQAAAA==.',
['墨兰']='墨兰妮:BAAALgAECgIJAgAAAA==.',
['墩儿']='墩儿喵喵:BAAALgAECgEJAgAAAA==.',
['壹頁']='壹頁书:BAACLgAFFH8LAAICAAQJmRF8HABZAQACAAQJmRF8HABZAQAuAAQKfxgAAgIABwmHGRVsAP0BAAIABwmHGRVsAP0BAAAA.',
['夏莉']='夏莉欧:BAAALgAFFAQJBAABLgAFFAUJEAALAC8lAA==.',
['夏酌']='夏酌愁:BAAALgAECgUJBQAAAA==.',
['夜与']='夜与梦:BAABLgAECn8VAAIKAAcJwxyzNABPAgAKAAcJwxyzNABPAgAAAA==.',
['夜之']='夜之语:BAAALgAECggJEgAAAA==.',
['夜魇']='夜魇骑士:BAAALgAECgQJBQAAAA==.',
['天堂']='天堂之声:BAAALgAECgEJAQAAAA==.天堂的忧郁:BAAALgAECgEJAQAAAA==.天堂神光:BAAALgAECgYJCQAAAA==.',
['天海']='天海折秀:BAACLgAFFH8FAAIRAAIJfgyxIwCYAAARAAIJfgyxIwCYAAAuAAQKfxYAAhEABwkBHkdNAAsCABEABwkBHkdNAAsCAAAA.',
['天真']='天真:BAAALgAECgUJBQAAAA==.',
['太傻']='太傻太天真:BAAALgADCgcJEgAAAA==.',
['夹克']='夹克:BAAALgADCgUJBwAAAA==.',
['女施']='女施主:BAAALgAECgMJAwAAAA==.',
['奶雪']='奶雪:BAAALgAECgQJBAAAAA==.',
['如果']='如果:BAAALgAECgIJAwAAAA==.',
['如雷']='如雷的盛怒:BAAALgAFFAEJAQAAAA==.',
['妇科']='妇科手术大夫:BAABLgAECn8YAAMBAAcJ/iOWIQCQAgABAAcJ/iOWIQCQAgASAAEJAACsLwA/AAAAAA==.',
['妞牛']='妞牛纽拗:BAAALgAECgYJBwAAAA==.',
['婳珑']='婳珑:BAACLgAFFH8QAAMTAAUJEBlNAgBnAQATAAQJVhhNAgBnAQAUAAUJJQ79BQBEAQAuAAQKfxkABBMACQlvGe0HAGkCABMABwmjG+0HAGkCABQABAmNFx4yADgBABUAAgl5BflAAGMAAAAA.',
['完颜']='完颜兀术:BAAALgAECgEJAQAAAA==.',
['寂寞']='寂寞灬宿命:BAAALgADCgEJAQAAAA==.',
['寒碧']='寒碧琦:BAAALgAECgEJAQAAAA==.',
['寒芒']='寒芒:BAAALgAECgUJBwAAAA==.',
['小加']='小加诺:BAAALgAECgYJCwAAAA==.',
['小巧']='小巧一粒:BAAALgAECgEJAQAAAA==.',
['小时']='小时候爱尿炕:BAABLgAFFH8MAAIIAAQJGBjqBABDAQAIAAQJGBjqBABDAQAAAA==.',
['小柒']='小柒:BAAALgAECgYJBgAAAA==.',
['小沫']='小沫沫:BAAALgAECgYJBgAAAA==.',
['小爱']='小爱心:BAAALgAECgYJCQAAAA==.',
['小琦']='小琦琦殿下:BAAALgADCgUJBQAAAA==.',
['小甜']='小甜点:BAAALgAECgYJCAAAAA==.',
['小米']='小米嘟嘟:BAAALgAECgEJAQAAAA==.小米豆豆:BAAALgAECgEJAgAAAA==.',
['小舒']='小舒不想输:BAAALgAECgUJCAAAAA==.',
['小蚂']='小蚂蚁一只:BAAALgAECgQJCAAAAA==.',
['小鸟']='小鸟游星野:BAAALgAECgIJAQAAAA==.',
['屠夫']='屠夫誓言:BAAALgAECgMJAwAAAA==.',
['山水']='山水不相逢:BAAALgAECggJCAAAAA==.',
['布布']='布布不可以:BAAALgAECgEJAQAAAA==.布布不拉稀:BAAALgADCgEJAQAAAA==.',
['帅的']='帅的一逼:BAAALgADCgYJBgAAAA==.',
['帮你']='帮你打官司:BAABLgAFFH8FAAMWAAIJARSYDgCxAAAWAAIJARSYDgCxAAAXAAIJTxSpCwCoAAAAAA==.',
['幕后']='幕后凋零:BAAALgAECgkJCQAAAA==.',
['幻想']='幻想的可乐:BAAALgAECgYJCwAAAA==.',
['应是']='应是人間凬流:BAAALgAFFAMJAwAAAA==.',
['张小']='张小帅:BAABLgAFFH8GAAIRAAQJchKyFwBGAQARAAQJchKyFwBGAQAAAA==.',
['影心']='影心:BAAALgAFFAIJAgABLgAFFAMJBQAKAIMgAA==.',
['影袭']='影袭:BAAALgAECgEJAQAAAA==.',
['心爱']='心爱:BAAALgAECgMJAwAAAA==.',
['恶魔']='恶魔传说:BAAALgAECgIJAgAAAA==.',
['惊喜']='惊喜的星期四:BAAALgAECgEJAQAAAA==.',
['我不']='我不吃糖:BAAALgAECgMJBAAAAA==.',
['我喝']='我喝可乐:BAAALgAECggJDQAAAA==.',
['我感']='我感觉很难受:BAAALgAECgQJBAAAAA==.',
['扣子']='扣子:BAABLgAFFH8GAAMLAAQJ7SHUCgBBAQALAAMJbiPUCgBBAQAMAAEJbB0dBQBnAAABLgAFFAUJEAALAC8lAA==.',
['搞裙']='搞裙子:BAAALgAECggJCQABLgAFFAYJDQAYALEiAA==.',
['救世']='救世星龙:BAABLgAFFH8JAAIVAAUJrx+OAQDDAQAVAAUJrx+OAQDDAQAAAA==.',
['断了']='断了的恋:BAABLgAECn8VAAIZAAgJ9BwHCACnAgAZAAgJ9BwHCACnAgAAAA==.',
['斯露']='斯露恩邪眼:BAAALgAECgMJAwAAAA==.',
['无尽']='无尽暗夜猎手:BAAALgAFFAEJAQAAAA==.',
['无敌']='无敌夹克:BAAALgAECgYJDAAAAA==.无敌妞妞魔:BAAALgAECgMJBAAAAA==.',
['无极']='无极:BAAALgAECgUJBwAAAA==.',
['无禁']='无禁的风:BAAALgAECgYJBgAAAA==.',
['时间']='时间:BAAALgAECgUJBAAAAA==.时间就系我:BAAALgAECgQJBAABLgAECgYJBgANAAAAAA==.',
['昂热']='昂热校长:BAAALgAECgYJBgAAAA==.',
['星光']='星光永烁:BAAALgADCgYJBgAAAA==.',
['景灵']='景灵堂:BAAALgAFFAIJBAAAAA==.',
['暗影']='暗影之舞:BAACLgAFFH8HAAILAAQJhQz7CQBRAQALAAQJhQz7CQBRAQAuAAQKfyQAAgsABwkYG/MbACACAAsABwkYG/MbACACAAAA.',
['暗里']='暗里着迷:BAAALgAECgUJBQABLgAECggJFQAZAPQcAA==.',
['月夜']='月夜小可爱:BAAALgAECgUJBQABLgAFFAQJCAAaALEIAA==.',
['未来']='未来福音:BAAALgAECgUJBgAAAA==.',
['朽木']='朽木白哉丶:BAAALgAECgMJAwAAAA==.',
['李春']='李春梅:BAAALgAFFAEJAQAAAA==.',
['李知']='李知恩:BAAALgADCgQJBAAAAA==.',
['梦回']='梦回一零年:BAAALgAECgYJBgAAAA==.梦回长安:BAAALgAFFAEJAQAAAA==.',
['樱牧']='樱牧华稻:BAAALgAECgMJAwAAAA==.',
['欧洲']='欧洲小熊猫:BAAALgAFFAEJAgAAAA==.',
['欧阳']='欧阳耀泉:BAAALgAECggJDAAAAA==.欧阳震华:BAAALgAECgYJCwAAAA==.',
['欧陽']='欧陽震華:BAAALgAECgIJAgAAAA==.',
['歐阳']='歐阳菲儿:BAAALgAECgEJAQAAAA==.歐阳震华:BAAALgAECgYJBgAAAA==.',
['武僧']='武僧夹克:BAAALgAECgEJAQAAAA==.',
['歧途']='歧途悲歌:BAACLgAFFH8PAAIBAAQJXiGzAgCRAQABAAQJXiGzAgCRAQAuAAQKfxcAAgEACAkwI70KACcDAAEACAkwI70KACcDAAAA.',
['毒毒']='毒毒:BAABLgAFFH8HAAIKAAMJ+h7MBwAyAQAKAAMJ+h7MBwAyAQAAAA==.',
['永夜']='永夜丶無解:BAAALgAFFAIJBAAAAA==.',
['法拉']='法拉卡:BAAALgAECgEJAQAAAA==.',
['泪镞']='泪镞:BAAALgADCgYJBgAAAA==.',
['泰难']='泰难德:BAAALgAECgIJAgAAAA==.',
['流天']='流天类星龙:BAABLgAFFH8IAAIVAAUJ4xxdAQDQAQAVAAUJ4xxdAQDQAQABLgAFFAUJCQAVAK8fAA==.',
['温柔']='温柔风暴:BAAALgAECgEJAQAAAA==.',
['游子']='游子怀南:BAAALgAECgYJCQAAAA==.',
['满月']='满月居于崆:BAAALgAECgQJBAAAAA==.',
['潇湘']='潇湘云梦:BAABLgAECn8aAAIXAAcJCiFJAwBEAgAXAAcJCiFJAwBEAgAAAA==.',
['灰太']='灰太郎会变身:BAAALgADCgcJCgAAAA==.',
['灵感']='灵感菇:BAAALgAECgUJDAAAAA==.',
['炉心']='炉心融解:BAAALgAECgMJAwAAAA==.',
['熏烟']='熏烟海因:BAACLgAFFH8NAAIVAAQJlwe0BQAgAQAVAAQJlwe0BQAgAQAuAAQKfx0AAhUACAm4FOIRACACABUACAm4FOIRACACAAAA.',
['版本']='版本之子:BAAALgADCgEJAQABLgAECgYJBwANAAAAAA==.',
['牛里']='牛里牛气:BAAALgAECgMJAwAAAA==.',
['牧中']='牧中无仁:BAAALgAECgYJBgAAAA==.',
['特洛']='特洛伊悍马:BAAALgAECgYJBgAAAA==.特洛伊河马:BAAALgAECgYJBgAAAA==.特洛伊穗康码:BAAALgAECgYJBgAAAA==.',
['牽絲']='牽絲戲丶:BAAALgAECgYJBwAAAA==.',
['狂乱']='狂乱中年母鸡:BAAALgAECgYJDQAAAA==.',
['独孤']='独孤九箭:BAAALgAECgEJAQAAAA==.',
['獐麂']='獐麂神:BAAALgADCgEJAQABLgAECggJFQAIAFMMAA==.',
['玛莎']='玛莎的小事:BAAALgAECgIJAgAAAA==.',
['生命']='生命鼓动:BAAALgAECgMJAwAAAA==.',
['用亮']='用亮光闪瞎你:BAAALgAECgcJEwAAAA==.',
['甲贺']='甲贺忍蛙:BAABLgAFFH8IAAIPAAQJryThAQCvAQAPAAQJryThAQCvAQABLgAFFAUJCQAVAK8fAA==.',
['白姊']='白姊芸:BAABLgAFFH8IAAMLAAQJxiVdAADFAQALAAQJxiVdAADFAQAMAAEJBA7yBQBfAAABLgAFFAUJEAALAC8lAA==.',
['神奇']='神奇啪啦喵:BAABLgAECn8XAAMOAAkJvRdSGAAgAgAOAAgJ8hlSGAAgAgAIAAkJ4w9kIQD2AQAAAA==.',
['秋凛']='秋凛然:BAAALgAECgQJBAABLgAECgUJBQANAAAAAA==.',
['空气']='空气中密蔓:BAAALgAECgQJBgAAAA==.空气中弥漫:BAAALgAFFAEJAQAAAA==.空气中迷漫:BAAALgAECgEJAQAAAA==.',
['空见']='空见:BAABLgAECn8VAAIIAAgJUww5MQCPAQAIAAgJUww5MQCPAQAAAA==.',
['竹影']='竹影清瞳:BAAALgAECgcJCAAAAA==.',
['笑嘻']='笑嘻嘻:BAAALgAECgUJBQAAAA==.',
['笨笨']='笨笨白:BAAALgAECgEJAgAAAA==.',
['第二']='第二苟得住:BAAALgAECgMJAwAAAA==.',
['等不']='等不到天亮:BAAALgAFFAIJBAAAAA==.',
['米若']='米若是饭:BAAALgAECgUJBQAAAA==.',
['紫丶']='紫丶薇:BAAALgAECgEJAQAAAA==.',
['繁华']='繁华落尽時丨:BAAALgAECgYJCwAAAA==.',
['终一']='终一生渡世人:BAABLgAECn8XAAMXAAgJdRX5JQC7AQAXAAcJhBf5JQC7AQAWAAQJUQibRwDDAAAAAA==.',
['绚烂']='绚烂的烟花:BAAALgAECgEJAQAAAA==.',
['绝地']='绝地天通:BAAALgADCgEJAQAAAA==.',
['绝对']='绝对领袖:BAAALgAECgQJBAAAAA==.',
['绿豆']='绿豆芽:BAAALgAECggJCAAAAA==.',
['缺耳']='缺耳朵:BAAALgAECgIJAgAAAA==.',
['罗候']='罗候:BAAALgAECgcJCAAAAA==.',
['翱翔']='翱翔风之魂:BAAALgAECgYJDQAAAA==.',
['老枪']='老枪:BAAALgAECgYJCQAAAA==.',
['老油']='老油条子:BAAALgAECgcJDQABLgAFFAUJBQAaANURAA==.',
['聆夜']='聆夜雨:BAAALgAECgMJAwAAAA==.',
['胡子']='胡子王:BAAALgAECgEJAgAAAA==.',
['胤嗣']='胤嗣:BAAALgADCgcJBwAAAA==.',
['腿长']='腿长毛少:BAAALgAECgYJBgAAAA==.',
['艾爾']='艾爾萨灬:BAAALgAECgEJAQAAAA==.',
['艾萨']='艾萨丝挽歌:BAAALgAECggJCAAAAA==.',
['苍云']='苍云:BAAALgADCgYJBgAAAA==.',
['若叶']='若叶牧:BAAALgAECgUJCwAAAA==.',
['草莓']='草莓泡泡冰:BAAALgAECgkJBAAAAA==.',
['菜到']='菜到发芽:BAAALgAECgYJBwAAAA==.',
['菜头']='菜头粿:BAAALgADCgMJAwAAAA==.',
['萌萌']='萌萌丶:BAAALgAECgYJBgAAAA==.',
['萨拉']='萨拉瑟尔:BAAALgAECggJDAAAAA==.',
['葉靈']='葉靈兒:BAABLgAECn8YAAIKAAcJDw2/hQBvAQAKAAcJDw2/hQBvAQAAAA==.',
['蘹脾']='蘹脾气:BAAALgAECgkJDAABLgAFFAcJFwAKAHYcAA==.',
['蜻蜓']='蜻蜓:BAAALgAECgUJBQAAAA==.',
['衣之']='衣之哀伤:BAAALgAECgYJDgAAAA==.',
['装苯']='装苯:BAAALgADCgIJAgAAAA==.',
['誓羽']='誓羽:BAAALgAECgIJAwAAAA==.',
['许褚']='许褚丶:BAAALgAECgEJAQAAAA==.',
['豆拌']='豆拌克尔酥:BAAALgAECgYJCQAAAA==.',
['超铃']='超铃音:BAAALgADCgcJBwAAAA==.',
['超音']='超音鼠:BAAALgAECgEJAQAAAA==.',
['踏风']='踏风武僧:BAAALgAECgEJAQAAAA==.',
['辉刃']='辉刃丨默翼:BAAALgADCgEJAQAAAA==.',
['迦罗']='迦罗娜丶影杀:BAAALgAECgIJAgAAAA==.',
['道尊']='道尊骑青牛:BAAALgAECgcJCAAAAA==.',
['避刃']='避刃兔:BAAALgAECgMJAwAAAA==.',
['酌酒']='酌酒照三千:BAAALgAECgcJBwAAAA==.',
['采啊']='采啊采:BAAALgAECgYJBgAAAA==.',
['钟丽']='钟丽丽灬:BAAALgADCgMJAwAAAA==.',
['钢琴']='钢琴手苹果:BAAALgAECgEJAQAAAA==.',
['钢铁']='钢铁虾机霸奶:BAAALgADCgMJAwAAAA==.',
['钱前']='钱前乾:BAAALgAECggJDQAAAA==.',
['铗勊']='铗勊:BAAALgAECgYJBgAAAA==.',
['长沙']='长沙杠精:BAAALgAECgIJAgAAAA==.',
['阿尔']='阿尔托莉:BAAALgAECgYJEwAAAA==.阿尔托莉娅:BAAALgADCgcJBwAAAA==.',
['阿瓦']='阿瓦达啃大瓜:BAAALgAECgcJDgAAAA==.',
['阿维']='阿维:BAAALgADCgEJAQAAAA==.',
['雨花']='雨花丶:BAAALgADCgQJBAAAAA==.',
['雪山']='雪山千古冷:BAAALgAFFAMJAwAAAA==.',
['雷迪']='雷迪斯:BAAALgAECgQJBAAAAA==.',
['霸月']='霸月魅魂:BAAALgAECgUJBQAAAA==.',
['非诚']='非诚無扰:BAAALgAECgEJAQAAAA==.',
['风烛']='风烛残年:BAAALgAECgEJAQAAAA==.',
['风舞']='风舞烟:BAAALgADCgYJBgAAAA==.',
['飞行']='飞行阿瓜:BAAALgAECgUJCQAAAA==.',
['香葱']='香葱蛋炒饭:BAAALgAECgcJDAAAAA==.',
['马化']='马化腾亲哥哥:BAAALgAECgUJCAAAAA==.马化腾亲爸爸:BAAALgAECgYJDQAAAA==.',
['鹡鸰']='鹡鸰女神:BAAALgAECggJCAAAAA==.',
['鹿野']='鹿野千夏:BAAALgAECgYJCAAAAA==.',
['黑暗']='黑暗的枭鹰:BAAALgAECgEJAQAAAA==.',
['齐道']='齐道临:BAAALgAECgYJBwAAAA==.',
['龙晨']='龙晨燚:BAAALgADCgEJAQAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
