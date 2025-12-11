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
 local lookup = {'Warrior-Protection','Shaman-Elemental','Warrior-Fury','Priest-Shadow','Mage-Fire','Mage-Frost','Paladin-Retribution','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','DeathKnight-Frost','Shaman-Restoration','Evoker-Preservation','Hunter-BeastMastery','Paladin-Protection','Priest-Holy','Evoker-Devastation','Rogue-Assassination','Rogue-Subtlety','Paladin-Holy','Hunter-Marksmanship','Warrior-Arms','Evoker-Augmentation','Monk-Brewmaster','Druid-Balance','Unknown-Unknown','DemonHunter-Havoc','Mage-Arcane','DeathKnight-Unholy','DeathKnight-Blood','Monk-Windwalker','Druid-Restoration','DemonHunter-Vengeance','Druid-Guardian','Druid-Feral','Hunter-Survival',}; local provider = {region='CN',realm='安威玛尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bi='Bigjbbadboy:BAABLAAFFH8GAAIBAAYI9gmZFQALAQABAAYI9gmZFQALAQAAAA==.',Bl='Blackfrost:BAAALAAECgYIBgAAAA==.',Br='Brittany:BAABLAAFFH8GAAICAAYIHgJHMACrAAACAAYIHgJHMACrAAAAAA==.',Ct='Ct:BAABLAAFFH8lAAIDAAYIiCJ4CwACAgADAAYIiCJ4CwACAgABLAAFFAYIOgAEAE8mAA==.',Dy='Dyyi:BAABLAAFFH8HAAMFAAUIYQhIBgC9AAAFAAQIxAZIBgC9AAAGAAIIkgoPFgBDAAAAAA==.',El='Elam:BAAALAAECgMIAwAAAA==.',Ey='Eyd:BAAALAAECgYIDQAAAA==.',Fa='Fanya:BAAALAADCgMIAwAAAA==.',Fb='Fb:BAABLAAFFH8PAAIHAAUIpxjEEQAuAQAHAAUIpxjEEQAuAQAAAA==.',Gz='Gzr:BAABLAAFFH8IAAIIAAIIBAaMGABaAAAIAAIIBAaMGABaAAAAAA==.',Ja='Janine:BAAALAAECgYIBgAAAA==.Javne:BAABLAAFFH8ZAAMJAAUIWRujIQASAQAJAAUIWRujIQASAQAKAAII7Q1IGACTAAAAAA==.',Je='Jessejane:BAAALAAECgYIEgAAAA==.',Ko='Koupela:BAABLAAFFH8FAAILAAUI/BbGQwAsAQALAAUI/BbGQwAsAQAAAA==.',La='Labubu:BAAALAADCggICAAAAA==.',Lf='Lf:BAABLAAFFH8IAAIMAAIICwZZbgBMAAAMAAIICwZZbgBMAAAAAA==.',Lu='Luvsic:BAAALAAFFAIIAgAAAA==.',Ma='Maik:BAABLAAFFH8PAAIMAAMI/BljJQC8AAAMAAMI/BljJQC8AAABLAAFFAgIBwAMADMRAA==.',Mf='Mf:BAAALAAFFAIIAgAAAA==.',Ni='Nigbbor:BAEALAAECgcICQABLAAFFAMICAANAOslAA==.Nioline:BAEALAADCgMIAwABLAAFFAMICAANAOslAA==.',Oz='Ozma:BAABLAAFFH8bAAILAAYI0yMREwD3AQALAAYI0yMREwD3AQABLAAFFAYIOgAEAE8mAA==.',Pg='Pg:BAAALAAECgYIBgAAAA==.',Ph='Phebe:BAAALAAECgMIAwAAAA==.Phoebestar:BAAALAAECgQIBAAAAA==.',Qt='Qtsan:BAABLAAFFH8YAAILAAgIxB1DCAB1AgALAAgIxB1DCAB1AgAAAA==.',St='Stardemon:BAAALAAECgYIBgAAAA==.Starrysky:BAABLAAECn8cAAIOAAgI0CIhDAC/AgAOAAgI0CIhDAC/AgAAAA==.Staryy:BAACLAAFFH8YAAILAAMIHB9mTQCjAAALAAMIHB9mTQCjAAAsAAQKfzwAAgsACAizI1MIAL0CAAsACAizI1MIAL0CAAAA.',Te='Tenze:BAAALAAECgYIBgAAAA==.',Th='Theshy:BAAALAAFFAIIAgAAAA==.',Ti='Tinko:BAABLAAFFH8FAAMPAAIImgj6HABpAAAPAAIImgj6HABpAAAHAAEIBQFJbQAwAAABLAAFFAcIMQANALYaAA==.',Ve='Vel:BAACLAAFFH8MAAMQAAMIjwroMgCdAAAQAAMIjwroMgCdAAAEAAEIvAOBLwA3AAAsAAQKfygAAxAABwitFQVFAMIBABAABwitFQVFAMIBAAQABwgVBshpABEBAAAA.Veldra:BAABLAAECn8ZAAMNAAcIiBa3FQDhAQANAAcIiBa3FQDhAQARAAIIqws1YABjAAAAAA==.Velo:BAAALAAFFAMIAwAAAA==.',Yu='Yukn:BAABLAAFFH8IAAMKAAIIOxL4EwCcAAAKAAII1hD4EwCcAAAJAAIIOxLGWQBGAAAAAA==.',Zi='Zikio:BAAALAAFFAIIAgAAAA==.',['一夜']='一夜绯雪一:BAAALAAECgYIBgABLAAFFAIIBgAPAHYOAA==.',['一言']='一言难尽额:BAAALAADCgQIBAAAAA==.',['一雪']='一雪晴一:BAAALAAECgIIAgAAAA==.',['三个']='三个头一个大:BAAALAAECgEIAQAAAA==.',['三六']='三六九折:BAAALAADCgcIBwAAAA==.',['三指']='三指弹天:BAABLAAFFH8IAAIMAAIImwnDZwBTAAAMAAIImwnDZwBTAAAAAA==.',['不再']='不再瀟灑:BAAALAAECgYICwAAAA==.',['中熊']='中熊猫:BAAALAAECgYICQAAAA==.',['丶听']='丶听悲伤的歌:BAABLAAFFH8IAAMSAAIIbB/ZEwCuAAASAAIIyxnZEwCuAAATAAIIth7QEABhAAAAAA==.',['之青']='之青丶:BAAALAAECgIIAgAAAA==.',['九二']='九二四:BAAALAAECgYIBgAAAA==.',['云的']='云的思念:BAAALAAECgYIBgAAAA==.',['云间']='云间绘晚星:BAAALAADCgQIBAAAAA==.',['亚殇']='亚殇:BAAALAADCggICAAAAA==.',['今晚']='今晚抓只鸡:BAAALAAECgYIBgAAAA==.',['从小']='从小爱打滚丶:BAAALAAFFAIIAgABLAAFFAgIEQALAOEUAA==.',['以朕']='以朕之名:BAACLAAFFH8QAAMPAAMIHwh3EgBgAAAPAAMIHwh3EgBgAAAUAAEIKwVOKgA+AAAsAAQKf0YAAw8ACAi3HDIHADgCAA8ACAi3HDIHADgCABQABggJCP4tANUAAAAA.',['优势']='优势在我:BAAALAAFFAIIAgAAAA==.',['传说']='传说中的老大:BAAALAADCgIIAgAAAA==.',['你们']='你们缺德吗:BAAALAAECgYIDgAAAA==.',['你好']='你好啊:BAAALAAECgMIAwAAAA==.',['你是']='你是猎物:BAABLAAECn8aAAMOAAYIkxOF1QBkAQAOAAYIMhKF1QBkAQAVAAYIywqPdwD2AAAAAA==.',['佬灬']='佬灬油条:BAAALAADCgMIAwAAAA==.',['保加']='保加利亚妖王:BAABLAAFFH8GAAILAAIIhhIhYwCXAAALAAIIhhIhYwCXAAAAAA==.',['信仰']='信仰圣光半夏:BAAALAAFFAIIAgAAAA==.',['光铸']='光铸霸气侧漏:BAAALAAFFAIIBAAAAA==.',['兜兜']='兜兜颇了:BAAALAADCgcIBwAAAA==.',['六千']='六千里:BAAALAAECgYICgAAAA==.',['再回']='再回唐朝:BAAALAADCgYIBgAAAA==.',['写不']='写不完的温柔:BAAALAAECggICAAAAA==.',['冯提']='冯提莫:BAAALAAECgQIBAAAAA==.',['冰冻']='冰冻娃娃:BAAALAAECgQIBgAAAA==.',['冰封']='冰封往事:BAAALAAECgUIBQAAAA==.',['冰糖']='冰糖粽子:BAABLAAFFH8KAAIJAAYIKQ2oNwAvAQAJAAYIKQ2oNwAvAQABLAAFFAgIRAAJAGkhAA==.',['凯撒']='凯撒:BAABLAAFFH8hAAMDAAYIRxauGwCJAQADAAYIvRWuGwCJAQAWAAIILh7EAgC3AAABLAAFFAgINgAHAAQgAA==.',['刀客']='刀客二胖子:BAAALAAECgYIBgAAAA==.刀客啦啦噜:BAAALAADCggIDgAAAA==.',['刃落']='刃落无声:BAACLAAFFH8ZAAMTAAMI9hk5EACbAAASAAMIJBlaFAChAAATAAIIWxg5EACbAAAsAAQKf0kAAxIACAiiI44BANgCABIACAiiI44BANgCABMABwgmHw4NAG0CAAEsAAUUCAg4AAMAeCMA.',['初見']='初見:BAABLAAFFH8GAAIKAAIIRxVYEQChAAAKAAIIRxVYEQChAAAAAA==.',['别演']='别演了:BAAALAAFFAUIAwAAAA==.',['别被']='别被游戏玩:BAAALAAECgYIDAAAAA==.',['功夫']='功夫萨:BAAALAAECgMIAwAAAA==.',['北巷']='北巷:BAAALAAECgMIAwAAAA==.',['半夏']='半夏丨生梦:BAABLAAFFH8GAAIQAAIItw3kMgCLAAAQAAIItw3kMgCLAAAAAA==.',['南湾']='南湾:BAAALAAECgcIDAAAAA==.',['卡索']='卡索弥亚:BAACLAAFFH8GAAIPAAII4QfDHQBmAAAPAAII4QfDHQBmAAAsAAQKfxwAAw8ABwhgFOYwAIwBAA8ABwhoE+YwAIwBAAcABAj0ErkiAe0AAAAA.',['卡莉']='卡莉丝塔:BAAALAAECgYICAAAAA==.',['厄尔']='厄尔萨斯:BAAALAAECgYIBgAAAA==.',['原告']='原告五人:BAABLAAFFH8GAAIXAAMI7wGgDgBPAAAXAAMI7wGgDgBPAAABLAAFFAMIBwAYALsBAA==.',['又被']='又被帅醒了:BAAALAAFFAIIAgAAAA==.',['发発']='发発发开锁:BAAALAAECgYIDAAAAA==.',['古力']='古力娜扎:BAAALAAECgYIDAAAAA==.',['只是']='只是开门的:BAAALAAECgQIBAAAAA==.',['叫我']='叫我术爷:BAAALAADCggIFwABLAAFFAcIMQANALYaAA==.',['叮叮']='叮叮当当:BAAALAAFFAIIAgAAAA==.',['同归']='同归于醉:BAAALAADCggICgAAAA==.',['吞吞']='吞吞:BAAALAAECgYIDAAAAA==.',['听也']='听也听不懂:BAAALAADCggICAAAAA==.',['吳孟']='吳孟達:BAAALAAECgYIBgAAAA==.',['周三']='周三大决战:BAABLAAECn8kAAIZAAgIjyNiEADpAgAZAAgIjyNiEADpAgAAAA==.',['和顏']='和顏悅色:BAAALAAECgMIAwAAAA==.',['咖桑']='咖桑:BAAALAAFFAIIBAAAAA==.',['哎呦']='哎呦喂妞妞:BAABLAAECn8dAAIOAAgIEBubPgBrAgAOAAgIEBubPgBrAgAAAA==.',['哼哼']='哼哼最可爱:BAAALAADCgIIAgAAAA==.',['喔抱']='喔抱歉:BAAALAAECgUIBQAAAA==.',['嗖噱']='嗖噱噱:BAAALAAFFAIIAgAAAA==.',['嘲风']='嘲风:BAABLAAFFH8IAAIRAAMIyAmREgDDAAARAAMIyAmREgDDAAAAAA==.',['噬魂']='噬魂血:BAAALAAECggIDQAAAA==.',['圣斗']='圣斗士七曜:BAAALAAECgQIBAABLAAFFAgIAgAaAAAAAA==.',['在那']='在那遥远地方:BAABLAAFFH8IAAIbAAIIMhmFRwBZAAAbAAIIMhmFRwBZAAAAAA==.',['基尔']='基尔简单:BAAALAAECgYIDwAAAA==.',['堕落']='堕落的蜗牛:BAAALAAECgUICgAAAA==.',['塞班']='塞班:BAAALAAECgEIAQAAAA==.',['壹佬']='壹佬波:BAAALAAECgUIBQAAAA==.',['壹玖']='壹玖玖贰:BAAALAAECgYICQAAAA==.',['壹骑']='壹骑当千:BAAALAAECgYIBgABLAAFFAIIAgAaAAAAAA==.',['多情']='多情最累:BAAALAAFFAIIBAAAAA==.',['夜来']='夜来香:BAAALAAECgMIAwAAAA==.',['大地']='大地之翼:BAAALAADCggICwAAAA==.',['大掌']='大掌柜:BAAALAADCgcIBwAAAA==.',['大桥']='大桥未久酱:BAAALAADCgIIAgAAAA==.',['大流']='大流狼:BAAALAAECgcICQAAAA==.',['大眼']='大眼睛小美眉:BAAALAADCgYIBgAAAA==.',['大颗']='大颗粒丶:BAACLAAFFH8IAAIcAAIIWBRnQACfAAAcAAIIWBRnQACfAAAsAAQKfxcAAhwABgj/GQppAMwBABwABgj/GQppAMwBAAAA.',['天使']='天使笑傻了:BAACLAAFFH8XAAIcAAMIJR5mOwClAAAcAAMIJR5mOwClAAAsAAQKf0kAAxwACAjFJDcDAOICABwACAjFJDcDAOICAAUAAQgjIuoPAGUAAAAA.',['天狼']='天狼射月:BAAALAAECgYIEAAAAA==.',['天量']='天量天价:BAAALAAECgEIAQAAAA==.',['奥蕾']='奥蕾峲亚:BAAALAAECgYIBgAAAA==.',['奶茶']='奶茶小怪兽:BAAALAADCgIIAgAAAA==.',['如月']='如月爱:BAABLAAFFH8MAAIQAAIIHAz6PgBsAAAQAAIIHAz6PgBsAAAAAA==.',['妞妞']='妞妞:BAAALAAECgYIEwAAAA==.',['姣姣']='姣姣如月:BAACLAAFFH8IAAILAAYIrwC/pgArAAALAAYIrwC/pgArAAAsAAQKfxYAAgsACAhuBsZvAA8BAAsACAhuBsZvAA8BAAAA.',['娘親']='娘親喲:BAABLAAFFH8FAAIKAAMI2wK1DgBPAAAKAAMI2wK1DgBPAAAAAA==.',['孤星']='孤星望月:BAAALAAECgYIBgAAAA==.',['安以']='安以燕:BAABLAAECn8ZAAIDAAcIfxo+RQAjAgADAAcIfxo+RQAjAgAAAA==.',['寧静']='寧静:BAACLAAFFH8ZAAMLAAMIKRTkYACMAAALAAMIdhLkYACMAAAdAAEIGhbZGgBXAAAsAAQKf0YABAsACAg2IUcNAIYCAAsACAg9IEcNAIYCAB0ABQj4HhIdANEBAB4ABghFDvUaAO8AAAAA.',['射你']='射你埋墙:BAAALAAECgYIBgAAAA==.',['小宝']='小宝贝儿别怕:BAAALAADCgEIAQAAAA==.',['小小']='小小木桩:BAAALAADCgMIAwABLAAECgcICgAaAAAAAA==.小小王子:BAAALAADCgUIBQAAAA==.',['小帕']='小帕米:BAAALAAECgQIBAABLAAECgcICgAaAAAAAA==.',['小德']='小德永不为宠:BAAALAADCgQIBgAAAA==.',['小木']='小木勿爱:BAAALAADCgEIAQABLAAECgcICgAaAAAAAA==.',['小灬']='小灬脆果:BAAALAAECgUIBQAAAA==.',['小牛']='小牛牛:BAABLAAFFH8OAAMMAAQIMyThFwCeAQAMAAQIMyThFwCeAQACAAII4grOMACHAAAAAA==.',['小猪']='小猪向前冲:BAAALAAECgYIDAAAAA==.',['小红']='小红手周润发:BAAALAAECgQIBAAAAA==.',['小马']='小马过河:BAAALAAECgYIBgAAAA==.',['小骑']='小骑骑士:BAAALAAFFAIIAgAAAA==.',['巴彦']='巴彦博格达:BAAALAADCgIIAwAAAA==.',['帝殒']='帝殒:BAAALAAECgQIBAAAAA==.',['常州']='常州第一战:BAAALAADCgEIAQAAAA==.',['幻影']='幻影紫霞:BAACLAAFFH8ZAAIHAAMIHhnoKQC1AAAHAAMIHhnoKQC1AAAsAAQKfywAAgcACAirHlc5AJACAAcACAirHlc5AJACAAEsAAUUCAheABQAaCUA.',['幻梦']='幻梦灵咒者:BAAALAAECgEIAQAAAA==.',['开心']='开心小翅膀:BAAALAADCggICAABLAAFFAIIAgAaAAAAAA==.',['心碎']='心碎之梦想梦:BAAALAAECgYIBgAAAA==.',['恩择']='恩择:BAABLAAECn8aAAIcAAgIaBCMZADYAQAcAAgIaBCMZADYAQAAAA==.',['恶魔']='恶魔夂翼:BAAALAAECgYICAAAAA==.',['情傷']='情傷:BAACLAAFFH8kAAIMAAgIVhqZAwCWAgAMAAgIVhqZAwCWAgAsAAQKfyQAAgwACAj3GqQ4ADUCAAwACAj3GqQ4ADUCAAAA.',['愿世']='愿世无哀:BAAALAAECgYIDgAAAA==.愿世无战:BAAALAAECgYIDQAAAA==.',['慕南']='慕南栀:BAAALAAECgQICAAAAA==.',['慕怜']='慕怜:BAABLAAFFH8GAAILAAIISQsqfQCJAAALAAIISQsqfQCJAAAAAA==.',['戏言']='戏言人间:BAAALAAFFAIIBAAAAA==.',['我先']='我先拯救世界:BAAALAAFFAIIAgAAAA==.',['我容']='我容易么:BAABLAAECn8WAAMGAAcIfB4TFwBiAgAGAAcIfB4TFwBiAgAcAAYITxivcAC4AQABLAAECggIHwAGALshAA==.',['我想']='我想睡觉:BAAALAAECgEIAQAAAA==.',['战使']='战使:BAAALAAECgYIBgAAAA==.',['扇风']='扇风小能手:BAAALAADCgIIAgAAAA==.',['拂面']='拂面那一刹那:BAABLAAFFH8GAAILAAQInhdwTgDrAAALAAQInhdwTgDrAAAAAA==.',['拳击']='拳击手七曜:BAACLAAFFH8KAAIBAAMIlB6oEQDAAAABAAMIlB6oEQDAAAAsAAQKfykAAgEACAgDJJEEAKYCAAEACAgDJJEEAKYCAAAA.',['持枪']='持枪大叔:BAAALAAFFAIIAwAAAA==.',['捣江']='捣江湖俊俊:BAAALAAECgEIAQAAAA==.',['搓面']='搓面包解千愁:BAEBLAAFFH8rAAMGAAcIuxyOAwAxAQAcAAcIcRwMEgDpAQAGAAQI0RGOAwAxAQABLAAFFAYIJQAOAB8jAA==.',['撸自']='撸自身:BAAALAAECgYIBgAAAA==.',['文咏']='文咏珊:BAAALAADCggICAAAAA==.',['文藝']='文藝青年:BAACLAAFFH8MAAIHAAMIXwYSSgBwAAAHAAMIXwYSSgBwAAAsAAQKfzcAAgcACAhQE8s+AKABAAcACAhQE8s+AKABAAAA.',['斩怒']='斩怒风:BAAALAAECgYICgAAAA==.',['斩破']='斩破天:BAACLAAFFH8LAAMBAAMIKxabFgChAAABAAIIshybFgChAAADAAMILw3uOACPAAAsAAQKfxkABAMACAgkG5hPAAICAAMACAh0GJhPAAICAAEABQh4GTNHAGQBABYAAQgcDaA9AC8AAAAA.',['新远']='新远古枭兽:BAAALAAECgYIEQABLAAFFAMIBwAYALsBAA==.',['无尘']='无尘:BAEBLAAFFH8kAAIfAAYIVB9mBADNAQAfAAYIVB9mBADNAQABLAAFFAYIJQAOAB8jAA==.',['无忧']='无忧女士:BAAALAAECgIIAQAAAA==.',['无悬']='无悬无念:BAAALAAECgYIEgABLAAECgcICgAaAAAAAA==.',['无敌']='无敌的大象:BAAALAAECgYIDwAAAA==.',['无法']='无法无天如花:BAAALAAECgYIBgAAAA==.',['日久']='日久见人射:BAAALAADCgcIBwAAAA==.日久见人格:BAAALAAFFAIIAwAAAA==.',['旧梦']='旧梦:BAAALAAECgcIEAAAAA==.',['昊焱']='昊焱:BAAALAAECgYICAAAAA==.',['星河']='星河:BAAALAAFFAIIAgAAAA==.',['普拉']='普拉蒂纳斯:BAAALAADCggICgAAAA==.',['普莱']='普莱斯萨里奥:BAAALAADCggICAAAAA==.',['暗与']='暗与影之歌:BAABLAAFFH8GAAIJAAIIogPzUwB2AAAJAAIIogPzUwB2AAABLAAFFAMIBwAYALsBAA==.',['暴力']='暴力释加牟尼:BAACLAAFFH8FAAIDAAMIIwYRPwBmAAADAAMIIwYRPwBmAAAsAAQKfyMAAgMACAi+GUcoAL8BAAMACAi+GUcoAL8BAAAA.',['暴怒']='暴怒神龙:BAAALAADCgcIBwAAAA==.',['曦月']='曦月红尘:BAAALAADCgEIAQAAAA==.',['曲中']='曲中人:BAEBLAAFFH8eAAICAAUIrSBfHABdAQACAAUIrSBfHABdAQABLAAFFAYIJQAOAB8jAA==.',['最后']='最后那只猫:BAAALAAECgIIAgAAAA==.最后那朵花:BAAALAAECgEIAQAAAA==.',['月夜']='月夜:BAAALAAECggICAAAAA==.',['月泯']='月泯灭:BAAALAADCgIIAgAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8OAAMgAAgIFyBjAQBiAgAgAAcIHCBjAQBiAgAZAAEIQxrkKgBcAAAAAA==.',['木头']='木头桩子:BAAALAAECgYIDAABLAAECgcICgAaAAAAAA==.',['李依']='李依桐:BAAALAADCgcIBwAAAA==.',['李妙']='李妙真:BAAALAAECgYIBgAAAA==.',['条形']='条形码:BAABLAAFFH8GAAIJAAMIpQPqUwBdAAAJAAMIpQPqUwBdAAAAAA==.',['来吧']='来吧死鬼:BAACLAAFFH8RAAMbAAMInBeJKAC8AAAbAAMInBeJKAC8AAAhAAII7xbiDQCFAAAsAAQKfxQAAxsABwitIcslAMgCABsABwitIcslAMgCACEAAQjBGSRkAD8AAAEsAAUUBwgxAA0AthoA.',['柏林']='柏林:BAABLAAFFH8GAAIJAAYICgnLSgCPAAAJAAYICgnLSgCPAAAAAA==.',['染晓']='染晓轩:BAACLAAFFH8FAAIiAAIIwhGSDAA2AAAiAAIIwhGSDAA2AAAsAAQKfx8AAyMABghLFjoOAE8BACMABghLFjoOAE8BACAABQgbBDVuAGwAAAAA.',['柚子']='柚子:BAAALAAECgQIBAAAAA==.',['树不']='树不高:BAAALAAECgYIEgAAAA==.',['格拉']='格拉海德宗师:BAABLAAFFH8HAAMYAAMIuwEjHgA+AAAfAAIIUgKyGABcAAAYAAMIFQEjHgA+AAAAAA==.',['桃之']='桃之宝:BAAALAAECgcIDQAAAA==.',['桔叶']='桔叶:BAABLAAFFH8TAAIOAAYIYRQwNABrAQAOAAYIYRQwNABrAQAAAA==.',['梅歆']='梅歆芮:BAAALAAECgYIBgAAAA==.',['梦的']='梦的回忆:BAAALAAECgYICQAAAA==.',['梨形']='梨形身材:BAAALAAECgYIDAAAAA==.',['樱桃']='樱桃小朋友:BAAALAAFFAIIBAAAAA==.',['橙王']='橙王败寇:BAABLAAFFH8GAAIHAAMISQKCUABWAAAHAAMISQKCUABWAAAAAA==.',['欣欣']='欣欣心:BAAALAADCgIIAgAAAA==.',['欣爷']='欣爷千千岁:BAABLAAECn8UAAMWAAgIQQxOHwAbAQAWAAgIDAxOHwAbAQADAAMIGwdpmwBHAAAAAA==.',['欲魔']='欲魔丶紫夜:BAAALAAECgMIAwAAAA==.',['歳月']='歳月無聲:BAAALAAECgQIBAAAAA==.',['死亡']='死亡低语:BAACLAAFFH8jAAILAAYI6BLsJQCeAQALAAYI6BLsJQCeAQAsAAQKfyEAAgsACAgSFvYsAMEBAAsACAgSFvYsAMEBAAAA.',['毒電']='毒電波艳艳:BAABLAAFFH8FAAIkAAMIzQh8AwBlAAAkAAMIzQh8AwBlAAAAAA==.',['水無']='水無月涙:BAAALAAECgYIBgAAAA==.',['江南']='江南追忆:BAAALAADCggIDAAAAA==.',['沐水']='沐水菡:BAAALAAECgEIAQAAAA==.',['沐雪']='沐雪琳风:BAAALAAECgcICgAAAA==.',['流动']='流动幻夜:BAAALAAECgUICgAAAA==.',['浅陌']='浅陌:BAABLAAFFH8JAAIOAAMIlgtttAA0AAAOAAMIlgtttAA0AAAAAA==.',['浪漫']='浪漫小嘤:BAAALAAECgYIBgAAAA==.',['浮萩']='浮萩:BAAALAAFFAIIBAABLAAFFAcIMQANALYaAA==.',['清菡']='清菡:BAAALAAECgYIBgAAAA==.',['清辉']='清辉夜凝:BAAALAADCggICAAAAA==.',['温酒']='温酒醉人:BAABLAAECn8ZAAIJAAYInBqhZQDCAQAJAAYInBqhZQDCAQAAAA==.',['港城']='港城无邪祖爷:BAABLAAECn8XAAIDAAcI/RlMLACrAQADAAcI/RlMLACrAQAAAA==.',['漏网']='漏网的鱼:BAAALAADCggIDgAAAA==.',['漢雲']='漢雲之遙:BAAALAADCgMIAwAAAA==.',['澜海']='澜海辰龍:BAAALAAECgYICQAAAA==.澜海辰龙:BAAALAAECgYIBgAAAA==.',['火远']='火远山:BAAALAADCgYIBgABLAAECgcIDQAaAAAAAA==.',['炽天']='炽天之翼:BAAALAAECgYIBgAAAA==.',['炽翼']='炽翼:BAAALAAFFAIIBAAAAA==.',['焙焙']='焙焙:BAAALAAECgEIAQAAAA==.',['爆弹']='爆弹:BAAALAAFFAIIBAAAAA==.',['爱新']='爱新觉罗艳艳:BAABLAAECn8bAAMMAAgIZBBfMwCRAQAMAAgIZBBfMwCRAQACAAYI4gNXrQCkAAAAAA==.',['牛犇']='牛犇:BAAALAAECgUIBQAAAA==.',['狠头']='狠头铁牛:BAABLAAFFH8FAAIjAAIIRRPTDQBEAAAjAAIIRRPTDQBEAAAAAA==.',['独享']='独享忧愁:BAABLAAECn8YAAIEAAYI3BfpHQBXAQAEAAYI3BfpHQBXAQAAAA==.',['猎灬']='猎灬爹:BAAALAAECgYIBgAAAA==.',['猫猫']='猫猫咪呀:BAAALAAECgUIBQAAAA==.',['玖玖']='玖玖:BAABLAAFFH8IAAIOAAII+Qs+lgBCAAAOAAII+Qs+lgBCAAAAAA==.',['琉璃']='琉璃丶:BAABLAAFFH8GAAIHAAIIGR+QcAA+AAAHAAIIGR+QcAA+AAAAAA==.',['瓶了']='瓶了个邪:BAABLAAFFH8GAAIIAAIIrxZAEwCIAAAIAAIIrxZAEwCIAAAAAA==.',['电饭']='电饭煲吞奶奶:BAAALAAECgYIAwAAAA==.',['白萌']='白萌萌:BAAALAAECgMIBQAAAA==.',['白银']='白银的堕天使:BAABLAAECn8UAAIkAAgIIxPOBACyAQAkAAgIIxPOBACyAQAAAA==.',['百发']='百发百仲:BAAALAAECgYIBgAAAA==.',['百戰']='百戰菊花:BAAALAAECgYIDAAAAA==.',['的德']='的德得:BAAALAAECgMIAwAAAA==.',['皮卡']='皮卡丘:BAAALAAECggIEAAAAA==.',['盘古']='盘古:BAABLAAFFH8cAAQcAAUIHhs9MABFAQAcAAUIHhs9MABFAQAFAAEINwgTDgA/AAAGAAEIjQUJIgA7AAABLAAFFAYIOgAEAE8mAA==.',['相信']='相信你的龙:BAACLAAFFH8xAAINAAcIthqgBQAwAgANAAcIthqgBQAwAgAsAAQKfysAAw0ACAjsHqMGANICAA0ACAjsHqMGANICABEABQhXEVJKAAcBAAAA.',['睡不']='睡不醒:BAAALAAECgYIDAAAAA==.',['矮猎']='矮猎王:BAAALAAECgcIDAAAAA==.',['祝安']='祝安康:BAABLAAFFH8GAAIOAAMIsgYjeABsAAAOAAMIsgYjeABsAAABLAAFFAMIBwAYALsBAA==.',['离谱']='离谱:BAAALAAECggICAAAAA==.',['秃头']='秃头爸爸:BAABLAAFFH8GAAIcAAYI2yG5AwBsAgAcAAYI2yG5AwBsAgABLAAFFAgIBQAGAEMdAA==.',['竹汐']='竹汐:BAAALAAECgYICwABLAAECgcICgAaAAAAAA==.',['第七']='第七次日落:BAACLAAFFH8KAAIOAAMIJxWqcACAAAAOAAMIJxWqcACAAAAsAAQKfygAAg4ACAjeHswbAFUCAA4ACAjeHswbAFUCAAAA.',['索沫']='索沫儿:BAAALAADCgYIBgAAAA==.',['紫云']='紫云风:BAAALAADCgcIBwAAAA==.',['红眼']='红眼搏命:BAAALAADCgYIBgAAAA==.',['绯杨']='绯杨:BAAALAADCgcIBAAAAA==.',['绯红']='绯红女巫:BAABLAAECn8YAAMJAAcIRRUeWQD0AAAJAAYI3BIeWQD0AAAKAAUIcxG9JwCTAAAAAA==.',['绯雪']='绯雪:BAABLAAECn8YAAIJAAYISyABJQDJAQAJAAYISyABJQDJAQAAAA==.',['维纳']='维纳斯丶威爾:BAAALAAECgEIAQAAAA==.',['羞羞']='羞羞的小粉:BAAALAAECggICAAAAA==.',['羽裳']='羽裳:BAAALAADCggICAAAAA==.',['老二']='老二一米二:BAAALAAECgQICQAAAA==.',['老猎']='老猎比戈:BAAALAADCgIIAgAAAA==.',['聋子']='聋子太狼:BAAALAAFFAYIAwAAAA==.',['聖女']='聖女献身銀墮:BAAALAAFFAEIAQAAAA==.',['胆小']='胆小的安以默:BAAALAAECgMIAwAAAA==.',['艳艳']='艳艳啊妱娣呀:BAAALAAECgQIBAAAAA==.',['艾丽']='艾丽西亚韩:BAAALAAECggIEAABLAAFFAMIBwAYALsBAA==.',['艾斯']='艾斯艾木:BAAALAAFFAIIAgAAAA==.',['艾欧']='艾欧尼亚:BAAALAAECgYIBgAAAA==.',['艾罗']='艾罗小四爷:BAABLAAFFH8GAAICAAIIaQbbSwA7AAACAAIIaQbbSwA7AAAAAA==.',['花园']='花园雪:BAABLAAFFH8MAAIMAAIISAtVZABWAAAMAAIISAtVZABWAAAAAA==.',['花开']='花开富贵菇:BAAALAAFFAQIBAAAAA==.',['苏喂']='苏喂苏喂:BAABLAAECn8fAAMMAAcIVBobKADLAQAMAAcIVBobKADLAQACAAEIxgMA3AAiAAAAAA==.',['苏拉']='苏拉玛:BAAALAAECgYIBgAAAA==.',['苏破']='苏破灭:BAAALAAECgYIEQAAAA==.',['草不']='草不枯:BAAALAAECgYICQAAAA==.',['荒野']='荒野猴觉:BAAALAADCgYICgAAAA==.',['萌萌']='萌萌的半夏丶:BAABLAAFFH8FAAIYAAMIFxcwGQCCAAAYAAMIFxcwGQCCAAAAAA==.萌萌的小晨星:BAABLAAFFH8OAAIDAAgI1ww1JQBFAQADAAgI1ww1JQBFAQAAAA==.',['萌鸡']='萌鸡队长:BAAALAAECgQIBwAAAA==.',['萤焰']='萤焰:BAABLAAFFH8MAAIMAAMI6A2USwCFAAAMAAMI6A2USwCFAAAAAA==.',['萧炎']='萧炎:BAAALAADCggIDwAAAA==.',['萨晶']='萨晶晶:BAAALAAECgQIBAAAAA==.',['萨贝']='萨贝宁萨乌鸡:BAABLAAFFH8GAAIMAAIIeR/sKACzAAAMAAIIeR/sKACzAAAAAA==.',['蒙大']='蒙大奇:BAAALAAECgUIBQAAAA==.',['蒙奇']='蒙奇利德:BAAALAAECgYIEQAAAA==.',['蒙小']='蒙小齐:BAAALAAECgYICwAAAA==.',['蒶里']='蒶里尔:BAABLAAFFH8GAAIUAAYIHArCEwBQAQAUAAYIHArCEwBQAQAAAA==.',['蓝色']='蓝色的缘分:BAAALAAECgYIBwAAAA==.',['蘇破']='蘇破灭:BAAALAAECgYICAAAAA==.',['蛋蛋']='蛋蛋也忧伤:BAACLAAFFH8HAAIbAAIIFRdtUQBIAAAbAAIIFRdtUQBIAAAsAAQKfxgAAhsABwihHYsZAA8CABsABwihHYsZAA8CAAAA.',['蛮吉']='蛮吉:BAABLAAFFH8GAAIHAAMIOwXcSQBxAAAHAAMIOwXcSQBxAAAAAA==.',['血洗']='血洗少林:BAAALAAECgEIAQAAAA==.',['血眼']='血眼死狼:BAAALAAECgEIAQAAAA==.',['言倩']='言倩:BAEALAADCgQIBAABLAAFFAMICAANAOslAA==.',['變形']='變形大師:BAABLAAFFH8GAAIgAAII2iOWFgDJAAAgAAII2iOWFgDJAAAAAA==.',['话梅']='话梅甜:BAAALAAFFAMIAwAAAA==.',['豆沙']='豆沙:BAAALAAECgcIBwAAAA==.',['豆爹']='豆爹帝:BAAALAAECgYICQAAAA==.',['贝露']='贝露塞布布:BAABLAAFFH8TAAIgAAYIgxf3EQCvAQAgAAYIgxf3EQCvAQAAAA==.',['贰零']='贰零壹陆:BAAALAAECgYIBgAAAA==.',['赤杨']='赤杨:BAAALAAECgYIBgAAAA==.',['超能']='超能扛的半夏:BAAALAAFFAIIAgAAAA==.',['软饭']='软饭硬吃阿华:BAAALAAECggICAAAAA==.',['辉耀']='辉耀核爆姬:BAAALAAECgYIEAAAAA==.',['迪诺']='迪诺:BAAALAAECgQIBAAAAA==.',['迷路']='迷路的下野:BAACLAAFFH8ZAAIgAAMIThRxLwCtAAAgAAMIThRxLwCtAAAsAAQKf08AAyAACAjKHQMKAKgCACAACAjKHQMKAKgCABkACAgiFpcVAMcBAAAA.',['迷雨']='迷雨:BAABLAAFFH8GAAIUAAMILBeYGgDeAAAUAAMILBeYGgDeAAAAAA==.',['追求']='追求放假:BAAALAAECgcIEwAAAA==.',['逸月']='逸月:BAAALAAECgYIDAAAAA==.',['酒仙']='酒仙阿哒哒:BAACLAAFFH8FAAIYAAMIABi6EwCEAAAYAAMIABi6EwCEAAAsAAQKfxYAAhgABwgyInYFADUCABgABwgyInYFADUCAAAA.',['酷酷']='酷酷冰:BAABLAAECn8mAAILAAgIJCCSLQC8AgALAAgIJCCSLQC8AgAAAA==.酷酷弓:BAAALAAECgcIEQAAAA==.酷酷骑:BAAALAAECgYICgAAAA==.',['醉卧']='醉卧弑场:BAAALAADCgYICAABLAAECgcICgAaAAAAAA==.',['铜木']='铜木鱼:BAAALAAECgIIAgAAAA==.',['锤死']='锤死你丫的:BAAALAAECgYIDAAAAA==.',['门休']='门休斯:BAAALAAECgMIAwAAAA==.',['阿修']='阿修罗霸凰拳:BAAALAAECgcIEAAAAA==.',['阿尼']='阿尼姆斯:BAAALAAECgUIDgAAAA==.',['阿斯']='阿斯卡拉亲王:BAAALAAECggICAAAAA==.',['阿格']='阿格拉玛:BAAALAAECgQIBAAAAA==.',['阿福']='阿福丶:BAAALAAFFAIIBAAAAA==.',['雅典']='雅典:BAAALAAECgUIBQAAAA==.',['雨宮']='雨宮琴音:BAAALAAECgYIBgAAAA==.',['霸氣']='霸氣側漏:BAAALAAFFAIIBAAAAA==.',['非洲']='非洲张学友:BAAALAAFFAIIAgAAAA==.',['韩菱']='韩菱紗:BAAALAAECgMIAwAAAA==.',['项艳']='项艳艳大魔王:BAAALAADCgMIAwAAAA==.',['风之']='风之丹丹:BAAALAAECgYIBgAAAA==.风之无追:BAAALAAECgYICwAAAA==.风之猎神:BAAALAAECgYIBgAAAA==.',['风暴']='风暴卡卡:BAABLAAECn8aAAIOAAcIPRWOYwB7AQAOAAcIPRWOYwB7AQAAAA==.',['风雨']='风雨红尘:BAAALAAECgQIBAAAAA==.',['风颜']='风颜风语:BAAALAAFFAIIAgAAAA==.',['风鳞']='风鳞啸歌:BAECLAAFFH8sAAIRAAYIKSJzBgDOAQARAAYIKSJzBgDOAQAsAAQKfx0AAhEACAiWHokYAF0CABEACAiWHokYAF0CAAEsAAUUBgglAA4AHyMA.',['香雪']='香雪怡兰:BAABLAAECn8eAAIOAAYIGBykdABbAQAOAAYIGBykdABbAQAAAA==.',['高达']='高达变身:BAABLAAFFH8JAAMZAAYIHB3EDACVAQAZAAYIHB3EDACVAQAgAAEIqAEpTwA4AAAAAA==.',['高速']='高速过弯之秋:BAAALAAFFAYIAgAAAA==.',['魑魅']='魑魅魍魉鬼怪:BAABLAAFFH8GAAIDAAIIUgKwTQBtAAADAAIIUgKwTQBtAAAAAA==.',['鱼不']='鱼不游:BAAALAAECgYICgAAAA==.',['鳯凰']='鳯凰:BAAALAAECgcIEAAAAA==.',['黃鵝']='黃鵝收割者:BAAALAAECggIDAAAAA==.',['黄裁']='黄裁缝:BAAALAAFFAMIAwAAAA==.',['黑龙']='黑龙公主:BAAALAADCgYIBgAAAA==.',['龍姬']='龍姬:BAABLAAFFH8GAAIcAAIInBK4SgCVAAAcAAIInBK4SgCVAAAAAA==.',['龙之']='龙之骑:BAABLAAFFH8GAAIeAAII7wzxEQB7AAAeAAII7wzxEQB7AAAAAA==.',['龙城']='龙城夜如花:BAABLAAFFH8GAAIPAAIIdg7QGAB1AAAPAAIIdg7QGAB1AAAAAA==.龙城夜如雪:BAABLAAFFH8HAAIJAAIIvhdZOAChAAAJAAIIvhdZOAChAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end