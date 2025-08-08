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
 local lookup = {'Rogue-Assassination','Shaman-Enhancement','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','Paladin-Protection','Evoker-Devastation','Shaman-Elemental','Mage-Arcane','Mage-Frost','Priest-Shadow','Priest-Holy','Unknown-Unknown','Rogue-Subtlety','DemonHunter-Vengeance','DemonHunter-Havoc','Warrior-Protection','Paladin-Retribution','Paladin-Holy','Druid-Guardian','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','DeathKnight-Blood','Priest-Discipline','DeathKnight-Unholy','Warrior-Fury','Warrior-Arms','Mage-Fire','Druid-Feral','Warlock-Affliction',}; local provider = {region='CN',realm='祖尔金',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ak='Akuma:BAABKgAECn8uAAIBAAgIaxeqBgD3AQABAAgIaxeqBgD3AQAAAA==.',An='Anarchy:BAAAKgAECgIIAgAAAA==.',As='Astrid:BAABKgAFFH8GAAMCAAUIEhOOCwAUAQACAAUIEhOOCwAUAQADAAEIbSCHLgBXAAAAAA==.',Co='Convere:BAAAKgAECgcIBwAAAA==.',Em='Emilywxx:BAABKgAECn8iAAMEAAgIVhrVDQAXAgAEAAgIFBrVDQAXAgAFAAUIQxVwegCdAAABKgAFFAgICAAFAPkUAA==.Emilyxcc:BAAAKgAECgcIBwAAAA==.',Pl='Playerejeisy:BAAAKgAECgQIBAAAAA==.',Re='Reminiscence:BAABKgAFFH8LAAIGAAUITxCKGwCdAAAGAAUITxCKGwCdAAAAAA==.',Sa='Sad:BAAAKgAFFAQIBAAAAA==.',Ww='Wwddw:BAABKgAFFH8GAAIHAAYIhxB+EQBMAQAHAAYIhxB+EQBMAQAAAA==.',Yd='Ydear:BAAAKgAFFAQIBAAAAA==.',['一个']='一个白妹妹:BAACKgAFFH8pAAMDAAQIzyKDGQAaAQADAAQIzyKDGQAaAQAIAAQIcw93FgDAAAAqAAQKf0oABAMACAhxImANAIMCAAMACAhxImANAIMCAAgACAiDGpobAOwBAAIAAggSCj5UAGUAAAAA.',['一方']='一方通行:BAABKgAFFH8cAAMJAAgI6CF1AQDSAgAJAAgI6CF1AQDSAgAKAAQIdxI3DgDyAAAAAA==.',['一灯']='一灯和尚:BAAAKgAECgQIBAAAAA==.',['不朽']='不朽的传说:BAAAKgAECgMIAwAAAA==.',['丨齊']='丨齊天大聖丨:BAABKgAFFH8GAAIKAAMIqRSJEgDPAAAKAAMIqRSJEgDPAAAAAA==.',['丶概']='丶概率牧:BAABKgAFFH8GAAMLAAQIKBXHEwDfAAALAAMIVRLHEwDfAAAMAAIIAgZ5EQC2AAABKgAFFAgIBAANAAAAAA==.',['九二']='九二六:BAAAKgAECgIIAgAAAA==.',['二段']='二段媒介:BAABKgAFFH8JAAIOAAMIMQjBBQCiAAAOAAMIMQjBBQCiAAAAAA==.',['亚瑟']='亚瑟王:BAAAKgADCgYIBgAAAA==.',['今晚']='今晚打老狐:BAACKgAFFH8HAAMPAAUIMgqFIABeAAAPAAQIlQyFIABeAAAQAAIICQMrTAA5AAAqAAQKfzgAAg8ACAg0FyQZALQBAA8ACAg0FyQZALQBAAAA.',['以德']='以德唬人:BAAAKgAECgcICAAAAA==.',['低调']='低调的小牛:BAAAKgADCgEIAQAAAA==.',['依熊']='依熊共舞:BAAAKgAECgEIAQAAAA==.',['傷花']='傷花怒放:BAAAKgAFFAIIAgAAAA==.',['兄弟']='兄弟快跑:BAAAKgAFFAMIAwAAAA==.',['光之']='光之恋念:BAAAKgADCgMIAwAAAA==.',['划水']='划水运动员:BAAAKgADCgEIAQAAAA==.',['别对']='别对我谈情:BAABKgAECn8iAAIRAAgIkxQDEQCrAQARAAgIkxQDEQCrAQAAAA==.',['十三']='十三妹:BAAAKgADCggIDQAAAA==.',['卓嘎']='卓嘎:BAAAKgAECgIIBAAAAA==.',['卫星']='卫星闪灵:BAAAKgADCgEIAQAAAA==.',['压力']='压力大:BAAAKgAECgcICQAAAA==.',['哈尼']='哈尼小熊:BAABKgAFFH8IAAIDAAQILR/sLABmAAADAAQILR/sLABmAAABKgAFFAgIFAADAFUjAA==.哈尼智:BAAAKgAFFAgIBAAAAA==.哈尼皇骑:BAABKgAFFH8IAAMSAAQIAB7lCwAlAQASAAQIAB7lCwAlAQATAAQIpBPtBgDiAAAAAA==.',['啤酒']='啤酒王子:BAABKgAECn8mAAMSAAgIoBdOSADnAQASAAgIoBdOSADnAQATAAIIuAbrIgA4AAAAAA==.',['四两']='四两热干面:BAABKgAECn8nAAIUAAgIAQ9QEABHAQAUAAgIAQ9QEABHAQAAAA==.',['塔山']='塔山:BAACKgAFFH8GAAIVAAMIkAccIAChAAAVAAMIkAccIAChAAAqAAQKfy8ABBUACAjTFs84AMIBABUACAjTFs84AMIBABYABgjpDI5dAKsAABcAAgjUDkcMADIAAAAA.',['夜未']='夜未凉:BAAAKgADCgMIAwAAAA==.',['夜蔓']='夜蔓蔓:BAABKgAFFH8LAAMTAAgI3w+OBgAXAQATAAcIzw+OBgAXAQASAAEIfR/JSwBSAAAAAA==.',['大恶']='大恶魔:BAAAKgAECggIDgAAAA==.',['大炮']='大炮:BAAAKgAECggICAAAAA==.',['大锤']='大锤:BAAAKgADCgQIBAAAAA==.',['大雄']='大雄:BAAAKgADCgcICQAAAA==.',['天使']='天使玫:BAAAKgAECgQIBAAAAA==.',['小小']='小小土:BAAAKgAECgIIAgAAAA==.小小骑:BAAAKgAECgMIAwAAAA==.',['小气']='小气包:BAAAKgADCggICAAAAA==.',['希尔']='希尔哇纳斯:BAAAKgAECgYIBgAAAA==.',['帝上']='帝上的萨满:BAAAKgAECgUIBQAAAA==.',['广末']='广末凉子:BAAAKgAECgEIAQAAAA==.',['微笑']='微笑:BAAAKgAECggICAAAAA==.',['忧郁']='忧郁大帝:BAAAKgAECgEIAQAAAA==.',['怕伢']='怕伢落地:BAACKgAFFH8lAAIYAAYI8RFmEAAiAQAYAAYI8RFmEAAiAQAqAAQKfysAAhgACAgyGlYOAA8CABgACAgyGlYOAA8CAAAA.',['恰尔']='恰尔巴克:BAAAKgADCggICgAAAA==.',['我好']='我好咕嘟鸭:BAABKgAECn8bAAMZAAgINB5YFwAIAgAZAAgINB5YFwAIAgAMAAEICxhCfwA6AAAAAA==.',['战斗']='战斗大师:BAAAKgAECgYIBgAAAA==.',['拉崩']='拉崩崩:BAAAKgAFFAQIBAABKgAFFAgIDgAaAEoXAA==.',['拉稀']='拉稀巴雷:BAAAKgAFFAQIBAAAAA==.',['指环']='指环战:BAABKgAECn8uAAMbAAgIexh1CwDsAQAbAAgIexh1CwDsAQAcAAUIwhJrFAD1AAAAAA==.',['搞里']='搞里头:BAAAKgAECgcIBwAAAA==.',['敌在']='敌在兰若寺:BAAAKgAECggICAAAAA==.',['星云']='星云流水:BAAAKgADCggIBgAAAA==.',['晓晓']='晓晓法:BAAAKgAECgEIAQAAAA==.',['暴打']='暴打丶猕猴桃:BAABKgAFFH8QAAMQAAgILhYwBgBJAgAQAAgILhYwBgBJAgAPAAQIMBdoEQC3AAAAAA==.暴打丶芒果:BAAAKgAECgUICQAAAA==.暴打丶葡萄:BAABKgAFFH8KAAIFAAcI9RUeDQC6AQAFAAcI9RUeDQC6AQAAAA==.',['木更']='木更:BAAAKgADCggICAAAAA==.',['木瓜']='木瓜:BAAAKgADCgEIAQAAAA==.',['枯骨']='枯骨:BAAAKgAFFAQIBAAAAA==.',['汉加']='汉加诺:BAABKgAECn8UAAISAAgI3hVQeACmAQASAAgI3hVQeACmAQAAAA==.',['沧茫']='沧茫之泪:BAAAKgADCgIIAgAAAA==.',['泉水']='泉水姐姐:BAAAKgAECgEIAQAAAA==.',['泷泽']='泷泽:BAAAKgAECgYIBwAAAA==.',['消逝']='消逝的咖啡:BAAAKgAECgMIBAAAAA==.',['灵魂']='灵魂旋律:BAABKgAFFH8IAAISAAgIqwhaDgC8AQASAAgIqwhaDgC8AQAAAA==.',['炒小']='炒小白菜:BAABKgAECn8XAAQJAAgI3h/SBQAiAgAJAAgIMR7SBQAiAgAKAAgIVBxQIwD4AQAdAAUIrh/uQACIAQAAAA==.',['牛肉']='牛肉:BAAAKgAECgIIAgAAAA==.',['猪大']='猪大肠:BAAAKgADCgcIBwAAAA==.',['王者']='王者永生:BAABKgAFFH8FAAIYAAUI0AP8IgCQAAAYAAUI0AP8IgCQAAAAAA==.',['玛丽']='玛丽亚女爵:BAAAKgADCgIIAgAAAA==.',['珠泪']='珠泪哀歌族:BAAAKgADCgcIBwAAAA==.',['白狼']='白狼骚男:BAABKgAFFH8LAAMeAAMI7Qg2CQCXAAAeAAMICQY2CQCXAAAUAAIItQpsBwAzAAAAAA==.',['盖浇']='盖浇饭风筝:BAAAKgADCggICAAAAA==.',['盘古']='盘古大帝:BAAAKgAECgQIBwAAAA==.',['真红']='真红戟鬼:BAACKgAFFH8ZAAMFAAYIBSRPAgC6AQAFAAYIBSRPAgC6AQAfAAQIBSB+BgD2AAAqAAQKfyMABAUACAjBIgMKAJwCAAUACAjBIgMKAJwCAB8AAwg4FZwmAK4AAAQAAwjEHHdaAJUAAAAA.',['禅中']='禅中说缠:BAAAKgAFFAEIAQAAAA==.',['紫雨']='紫雨伊人:BAAAKgAECgEIAQAAAA==.',['缘念']='缘念:BAAAKgAECgQIBgAAAA==.',['缠中']='缠中说禅:BAAAKgAECgIIBAAAAA==.',['艾尔']='艾尔贝蕾斯:BAAAKgAECgUICAAAAA==.',['花月']='花月儿:BAACKgAFFH8PAAMWAAQIaBSYKADIAAAWAAQIaBSYKADIAAAVAAEIwQkLMAA6AAAqAAQKfxkAAhYACAj3GbsfAAECABYACAj3GbsfAAECAAAA.',['草原']='草原秋风狂:BAACKgAFFH8eAAISAAgIYB4HBQCDAgASAAgIYB4HBQCDAgAqAAQKfxMAAhIABwgIH5NCAPoBABIABwgIH5NCAPoBAAAA.',['萨满']='萨满:BAABKgAFFH8LAAMCAAYIjgMtCwAbAQACAAYIjgMtCwAbAQADAAQIrw4mNQCoAAAAAA==.',['葫芦']='葫芦头:BAAAKgADCggIEAAAAA==.',['血色']='血色狂刀:BAACKgAFFH8IAAIbAAMIuxFoIADSAAAbAAMIuxFoIADSAAAqAAQKfxYAAxsACAjQGBs0ALABABsACAjQGBs0ALABABEAAQgaDZtLACcAAAAA.',['裤衩']='裤衩教授:BAAAKgAECgUIAgAAAA==.',['西风']='西风不息:BAAAKgAECgIIAgAAAA==.',['貔貅']='貔貅快射火:BAAAKgAFFAUIBAAAAA==.',['贝如']='贝如塔:BAAAKgAECgIIAgAAAA==.',['赖赖']='赖赖呢:BAABKgAFFH8GAAIQAAYInB8HCgAlAQAQAAYInB8HCgAlAQAAAA==.',['迪迦']='迪迦:BAAAKgAFFAEIAQAAAA==.',['逸鲤']='逸鲤:BAAAKgAECggIEAAAAA==.',['那一']='那一箭的温蹂:BAAAKgAECgMIAwAAAA==.',['陌依']='陌依依:BAAAKgAECgYIBgAAAA==.',['雪花']='雪花啤酒:BAAAKgAFFAMIBAAAAA==.',['青岛']='青岛啤酒:BAABKgAFFH8IAAIDAAQIaxyGJADlAAADAAQIaxyGJADlAAAAAA==.',['靓牛']='靓牛小七:BAAAKgAECgEIAQAAAA==.',['风萧']='风萧水寒:BAAAKgADCgQIBAAAAA==.',['馋猫']='馋猫与鱼:BAACKgAFFH8GAAIKAAMIpAlDDQC1AAAKAAMIpAlDDQC1AAAqAAQKfyoAAwoACAhXFbcnAHsBAAoACAhXFbcnAHsBAAkAAQgAANitAAAAAAAA.',['香辣']='香辣烤面筋:BAAAKgADCgcIBwAAAA==.',['高嗒']='高嗒强:BAAAKgAECgcICAAAAA==.',['黑椒']='黑椒蛋堡:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end