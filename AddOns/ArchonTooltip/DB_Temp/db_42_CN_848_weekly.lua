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
 local lookup = {'Warlock-Demonology','Warlock-Destruction','DemonHunter-Vengeance','DemonHunter-Havoc','Rogue-Subtlety','Rogue-Assassination','Druid-Balance','Druid-Restoration','Druid-Guardian','Priest-Holy','Priest-Discipline','Evoker-Devastation','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Arms','Hunter-BeastMastery','Hunter-Marksmanship','Mage-Frost','Mage-Arcane','Shaman-Restoration','Unknown-Unknown','Shaman-Elemental','Paladin-Protection','Warrior-Fury',}; local provider = {region='CN',realm='迪托马斯',name='CN',type='weekly',zone=42,date='2025-08-02',data={Ak='Akg:BAAAKgAECgMIAwAAAA==.',Ba='Baba:BAAAKgADCgYICgAAAA==.',Bi='Bin:BAAAKgAFFAEIAQAAAA==.',Co='Coolhot:BAABKgAECn8cAAMBAAgIFB8jDgAhAgABAAgIwR4jDgAhAgACAAMIFBlCWAC2AAAAAA==.',Da='Dallasdallas:BAAAKgAECggIDgAAAA==.',Ha='Hanass:BAAAKgAECgIIAgAAAA==.',Mo='Monstershua:BAAAKgAECgUIBQAAAA==.',Sa='Saroti:BAAAKgAFFAUIAQAAAA==.',Wa='Waga:BAAAKgAECgQICAAAAA==.Wanfeng:BAAAKgADCgUIBQAAAA==.',Yn='Ynot:BAABKgAECn8ZAAMDAAgItgz6FQDOAAADAAgIhAv6FQDOAAAEAAQI5wdxowBsAAAAAA==.',['一样']='一样枫隐:BAACKgAFFH8dAAMFAAQILArWAwC0AAAGAAQIEgr6HADFAAAFAAMIzgXWAwC0AAAqAAQKfx4AAwYACAjwEmEZAL4BAAYACAjwEmEZAL4BAAUABgh6BQ0kAOUAAAAA.一样枫飞:BAAAKgAECgQIBAAAAA==.',['七星']='七星天玑君:BAAAKgADCgUIBQAAAA==.',['丶圣']='丶圣皇:BAAAKgAFFAEIAQAAAA==.',['丹迪']='丹迪:BAAAKgAECgEIAQAAAA==.',['乌可']='乌可蓝:BAAAKgADCgcIDAAAAA==.',['九桑']='九桑达咩哟:BAAAKgAFFAYIAgAAAA==.',['二月']='二月的鱼:BAAAKgAECgMIAwAAAA==.',['人中']='人中如龙:BAAAKgAECgYICAAAAA==.',['伊利']='伊利玬丶怒风:BAAAKgAECggICwAAAA==.',['伐要']='伐要幫無姥卛:BAACKgAFFH8YAAMHAAYIViErCQAlAQAHAAYIViErCQAlAQAIAAQI1hCaIQCiAAAqAAQKfyQABAgACAjCCx9KAOUAAAgACAjCCx9KAOUAAAcABwj5CCCMALYAAAkAAQjoBpk6ABEAAAAA.伐要幫無姥牧:BAABKgAECn8WAAMKAAcIORxpJADDAQAKAAcIORxpJADDAQALAAEIGws/mAAmAAABKgAFFAYIGAAHAFYhAA==.',['佣兽']='佣兽:BAACKgAFFH8JAAIMAAYIQRJeCwC1AQAMAAYIQRJeCwC1AQAqAAQKfxcAAgwACAhhFJUfAL0BAAwACAhhFJUfAL0BAAAA.',['假日']='假日里的圣光:BAAAKgADCggICAAAAA==.',['傻吧']='傻吧拉叽:BAAAKgAFFAIIAgAAAA==.',['光与']='光与影:BAAAKgAECgMIAwAAAA==.',['冷月']='冷月无光:BAABKgAFFH8IAAINAAgIHwgkDwCtAQANAAgIHwgkDwCtAQAAAA==.',['冷酷']='冷酷孤影:BAAAKgAFFAQIBAAAAA==.',['凋零']='凋零夜月:BAABKgAFFH8FAAQOAAIIUw2tBgCDAAAOAAIIDwutBgCDAAAPAAEIFgvJVAA7AAAQAAEIjw+8JAA6AAAAAA==.',['凤御']='凤御:BAABKgAFFH8LAAIRAAYITR8fBQDjAQARAAYITR8fBQDjAQAAAA==.',['凤灵']='凤灵:BAABKgAFFH8GAAIKAAQI0BnMHQDUAAAKAAQI0BnMHQDUAAABKgAFFAgIFAAKACcUAA==.',['凤羽']='凤羽:BAABKgAFFH8UAAMSAAgIixjcCQDUAQASAAcIExHcCQDUAQATAAYIWxbjDQB+AQAAAA==.',['创世']='创世元神:BAAAKgAECggIEwAAAA==.',['利尼']='利尼斯参透四:BAABKgAFFH8LAAIEAAQIWwyWNQCqAAAEAAQIWwyWNQCqAAAAAA==.',['千里']='千里之外:BAAAKgAECgYICwAAAA==.',['卡珊']='卡珊德拉:BAAAKgAFFAMIBAAAAA==.',['可蓝']='可蓝:BAAAKgAECgYICwAAAA==.',['史塔']='史塔克:BAAAKgAECgQIBAAAAA==.',['史蒂']='史蒂芬周:BAAAKgADCgQIBAAAAA==.',['周杰']='周杰伦:BAABKgAFFH8GAAIQAAYIERM9DwAtAQAQAAYIERM9DwAtAQAAAA==.',['唯一']='唯一性人:BAACKgAFFH8VAAIHAAMI5BMYMwDMAAAHAAMI5BMYMwDMAAAqAAQKfyUAAgcACAidIqwMAMACAAcACAidIqwMAMACAAAA.',['嘟巿']='嘟巿蓅氓:BAAAKgAECgYICgAAAA==.',['塑料']='塑料袋:BAAAKgAECgMIAwAAAA==.',['大将']='大将军:BAAAKgADCgEIAwAAAA==.',['大玲']='大玲子:BAAAKgAECgMIAwAAAA==.',['大聪']='大聪明:BAAAKgADCggICAAAAA==.',['大腿']='大腿轻轻抚:BAABKgAECn8rAAMUAAgI0hw5FwD9AQAUAAgI0hw5FwD9AQAVAAIIEg5JiQBSAAABKgAFFAgIDgAUAPwaAA==.',['奥克']='奥克瑟威斯:BAAAKgADCgUIBQAAAA==.',['奶油']='奶油小僧:BAAAKgAFFAQIBAAAAA==.奶油蛋糕丶:BAAAKgAFFAIIAgAAAA==.',['妞妞']='妞妞侠:BAABKgAFFH8OAAIWAAYIOSYgAAA8AgAWAAYIOSYgAAA8AgABKgAFFAgIBAAXAAAAAA==.',['威猛']='威猛嘉豪:BAAAKgADCggICAAAAA==.',['安薇']='安薇娜提歌:BAAAKgAFFAIIAgAAAA==.',['寒夜']='寒夜丶:BAAAKgAECggIBQAAAA==.',['小小']='小小的萨满:BAABKgAFFH8GAAIWAAYI3wMmEgBDAQAWAAYI3wMmEgBDAQAAAA==.',['小暴']='小暴力:BAABKgAFFH8TAAMWAAUIKyDZDgBkAQAWAAUIKyDZDgBkAQAYAAQI2RLPFQDDAAAAAA==.',['小碗']='小碗二细:BAAAKgAECgMIBwAAAA==.',['小雨']='小雨堡堡:BAAAKgAECgUIBQABKgAFFAgIBgAQAJoXAA==.小雨饱饱:BAABKgAFFH8GAAIQAAYImhdxCwBaAQAQAAYImhdxCwBaAQAAAA==.',['小鹿']='小鹿鹏程:BAAAKgAFFAQIBAAAAA==.',['小黑']='小黑子:BAAAKgAFFAEIAQAAAA==.',['幼麟']='幼麟:BAABKgAFFH8QAAMGAAQItRa4CwDmAAAFAAQI0g8zCADsAAAGAAQItRa4CwDmAAAAAA==.',['弦上']='弦上新月:BAACKgAFFH8IAAITAAQIOAcBHACKAAATAAQIOAcBHACKAAAqAAQKfxQAAhMACAhNGcwfAAACABMACAhNGcwfAAACAAAA.',['恍然']='恍然如夢丶:BAAAKgAECgYIBgAAAA==.',['懒懒']='懒懒的缺缺:BAAAKgAECgMIBgAAAA==.',['房中']='房中术:BAAAKgADCggICAAAAA==.',['扫地']='扫地僧:BAAAKgAECgYIBgAAAA==.',['摩尔']='摩尔拿铁:BAAAKgAECggICAAAAA==.',['故乡']='故乡的人:BAAAKgADCggICAAAAA==.',['文橙']='文橙功主:BAAAKgAFFAMIAwAAAA==.',['日夜']='日夜五次狼:BAAAKgAFFAQIBAAAAA==.',['明人']='明人不放暗屁:BAAAKgADCggICAAAAA==.',['明月']='明月光影:BAAAKgAECgcICAAAAA==.明月无双:BAAAKgAECgMIAwAAAA==.',['明眸']='明眸善睐:BAAAKgAFFAIIAgAAAA==.',['星玥']='星玥清秋:BAABKgAFFH8GAAIEAAYIqhV7EQB0AQAEAAYIqhV7EQB0AQAAAA==.',['晓风']='晓风残月:BAAAKgAECgYIBgAAAA==.',['暴躁']='暴躁鱼鱼:BAAAKgAECgUICwAAAA==.',['木人']='木人:BAABKgAECn8kAAMTAAgI3SDfDAD9AQASAAgIYx97JwAWAgATAAgIPxvfDAD9AQAAAA==.',['朽沐']='朽沐白哉:BAAAKgAECgIIAgAAAA==.',['李子']='李子:BAAAKgAECgcIBwAAAA==.',['枫舞']='枫舞之梦:BAAAKgAECgIIAgAAAA==.',['歆夜']='歆夜月:BAAAKgADCggICAAAAA==.',['歹匕']='歹匕马奇:BAAAKgAECgIIAgAAAA==.',['江南']='江南一头牛:BAAAKgAECggIDwAAAA==.',['沛然']='沛然舞羽:BAAAKgAFFAQIBAAAAA==.',['泡泡']='泡泡龙:BAABKgAFFH8GAAIMAAYI/Q0vDgB9AQAMAAYI/Q0vDgB9AQAAAA==.',['浩劫']='浩劫:BAAAKgAECgUIBgAAAA==.',['深爱']='深爱着橘子:BAAAKgAECgYICQAAAA==.',['漆黑']='漆黑么么乌:BAAAKgAFFAIIAgAAAA==.',['演绎']='演绎完美:BAAAKgADCgMIAwAAAA==.',['烈火']='烈火狂僧:BAAAKgAECgMIAwAAAA==.',['爆炒']='爆炒回锅肉:BAAAKgADCggIEwAAAA==.',['爱梅']='爱梅特赛尔克:BAACKgAFFH8KAAMYAAMIwg60FgC+AAAYAAMIwg60FgC+AAAWAAEIDQuZUQA4AAAqAAQKfxUAAxgACAjhHectAG8BABgACAjhHectAG8BABYACAgKEvtCAGsBAAAA.',['狸子']='狸子:BAAAKgADCggICAAAAA==.',['猎魔']='猎魔夜月:BAAAKgAECgcIBwAAAA==.',['猫的']='猫的乔咪:BAABKgAFFH8FAAIPAAUIlhgrGwBEAQAPAAUIlhgrGwBEAQAAAA==.',['玛丽']='玛丽蕾珊斯卡:BAAAKgADCgYIBgAAAA==.',['玩命']='玩命抡大锤:BAAAKgADCgEIAQAAAA==.',['琅琊']='琅琊丽:BAAAKgAECgEIAQAAAA==.',['理子']='理子:BAABKgAFFH8FAAIIAAIIMg9jHQBfAAAIAAIIMg9jHQBfAAAAAA==.',['瑅里']='瑅里奥丶弗丁:BAAAKgAECggIDwABKgAFFAYIBgACAC8hAA==.',['盲目']='盲目乱扣:BAAAKgADCgIIAgAAAA==.',['石大']='石大猎:BAAAKgAFFAQIBAAAAA==.石大骑:BAABKgAFFH8KAAIZAAQI2By1BgD5AAAZAAQI2By1BgD5AAAAAA==.',['神启']='神启丷灭烬:BAAAKgAFFAQIAwABKgAFFAYIFAAHAFwXAA==.',['神圣']='神圣大救赎:BAAAKgAFFAYIAgAAAA==.',['纵火']='纵火狂魔:BAAAKgADCgEIAQAAAA==.',['细狗']='细狗行不行:BAABKgAFFH8GAAINAAYI1BT8IgBgAQANAAYI1BT8IgBgAQAAAA==.',['维熙']='维熙:BAAAKgAECgQIBAAAAA==.',['维萨']='维萨吉:BAAAKgAFFAIIAgAAAA==.',['色弱']='色弱:BAAAKgADCgQIBAAAAA==.',['艾可']='艾可:BAABKgAECn8UAAMTAAYIjxVqSAAuAQATAAYIHxVqSAAuAQASAAMINQ1+rgBkAAAAAA==.',['芝麻']='芝麻绿豆:BAABKgAFFH8IAAIKAAQIXRsVDwDXAAAKAAQIXRsVDwDXAAAAAA==.',['莉莉']='莉莉姆:BAAAKgADCgIIAgAAAA==.',['莫西']='莫西干:BAABKgAFFH8MAAMNAAQI7xcMIADpAAANAAQIBBIMIADpAAAZAAQIjRcoCgDCAAAAAA==.',['菲尔']='菲尔奈斯:BAAAKgADCggICwABKgAECggILgACAAMUAA==.',['蒐姐']='蒐姐炫拉菲:BAAAKgAFFAEIAQAAAA==.',['蓝疏']='蓝疏:BAAAKgADCgQIBAAAAA==.',['血色']='血色玫瑰:BAAAKgADCggICAAAAA==.',['觉醒']='觉醒春丽:BAAAKgADCggICAAAAA==.',['诸界']='诸界丶毁灭者:BAAAKgADCggICAAAAA==.',['豿日']='豿日战:BAABKgAFFH8FAAIaAAQIQg89IgDKAAAaAAQIQg89IgDKAAAAAA==.',['超级']='超级猪猪侠:BAAAKgADCggICAAAAA==.',['路坎']='路坎特骑士:BAAAKgAECgcIBwAAAA==.',['路大']='路大主教:BAAAKgAECgEIAQAAAA==.',['路小']='路小小白:BAAAKgAECggICAAAAA==.',['转世']='转世幻影:BAAAKgADCgMIAwAAAA==.',['遠离']='遠离尘嚣:BAAAKgAECgYIBgAAAA==.',['邪恶']='邪恶冷静:BAABKgAFFH8IAAIZAAgIqBdsBAALAgAZAAgIqBdsBAALAgAAAA==.',['鄢涩']='鄢涩遥:BAAAKgAECggICAAAAA==.',['银月']='银月血小贱:BAAAKgAECgQIBAAAAA==.',['阿斯']='阿斯顿:BAAAKgADCggIDwAAAA==.',['陛下']='陛下圣剑:BAAAKgADCgYIBgAAAA==.',['霍尔']='霍尔蒙克斯:BAABKgAECn8uAAMCAAgIAxQuKAB+AQACAAgImRMuKAB+AQABAAQIgxGHNwAFAQAAAA==.',['霸波']='霸波尔奔:BAABKgAFFH8OAAMTAAYIqR6/EABgAQATAAYIhBm/EABgAQASAAQIhRZWHgDeAAAAAA==.',['马托']='马托斯:BAAAKgADCgEIAQAAAA==.',['魔屠']='魔屠嚜嚜:BAACKgAFFH8MAAIWAAMIqgkaOQCeAAAWAAMIqgkaOQCeAAAqAAQKfysAAhYACAh/HaUbACECABYACAh/HaUbACECAAAA.魔屠行者:BAAAKgAFFAIIAgAAAA==.',['鲜血']='鲜血长河:BAAAKgAECggIDwAAAA==.',['鸢一']='鸢一折纸:BAAAKgADCgMIAwAAAA==.',['黑暗']='黑暗飯团:BAAAKgAFFAYIBAAAAA==.',['黑黑']='黑黑球萨满:BAAAKgAECggICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end