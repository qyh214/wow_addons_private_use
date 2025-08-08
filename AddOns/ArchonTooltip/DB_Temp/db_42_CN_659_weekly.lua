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
 local lookup = {'Shaman-Restoration','Priest-Shadow','Priest-Discipline','Priest-Holy','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Hunter-Marksmanship','Hunter-BeastMastery','Druid-Balance','Druid-Restoration','Paladin-Retribution','Shaman-Enhancement','Shaman-Elemental','DeathKnight-Unholy','Rogue-Assassination','Rogue-Subtlety','Mage-Fire','Mage-Arcane','Mage-Frost','DeathKnight-Blood','Unknown-Unknown','Rogue-Outlaw','Paladin-Protection','Paladin-Holy','Monk-Mistweaver','Evoker-Devastation','Evoker-Preservation','Monk-Windwalker','DemonHunter-Havoc','Warrior-Fury','Warrior-Arms','Hunter-Survival','Monk-Brewmaster','DeathKnight-Frost','Warrior-Protection','Druid-Guardian',}; local provider = {region='CN',realm='屠魔山谷',name='CN',type='weekly',zone=42,date='2025-08-08',data={Bl='Bloodelfadon:BAAAKgAECgUIBQAAAA==.',Ch='Characow:BAAAKgAFFAQIBAAAAA==.',Cx='Cxx:BAAAKgAFFAYIBAAAAA==.',Da='Damonn:BAABKgAFFH8IAAIBAAQIKRwTJgDeAAABAAQIKRwTJgDeAAAAAA==.Darkside:BAACKgAFFH8sAAQCAAcIjBnQBAD+AQACAAcIjBnQBAD+AQADAAQI1BaxHwClAAAEAAEIhhbAIgBFAAAqAAQKfyUABAIACAhtGxsbAP0BAAIACAhtGxsbAP0BAAMAAwhlEkhSAM4AAAQABwhKCNNbAM4AAAAA.',Dr='Dragonz:BAAAKgADCgQIBAAAAA==.',Fl='Flora:BAAAKgADCggICAAAAA==.',Ho='Horo:BAACKgAFFH8tAAQFAAcI0RxLBABFAQAGAAYI3BurDQCyAQAFAAQIcxlLBABFAQAHAAIIJxTqJgBLAAAqAAQKfygABAUACAi/Ix0IAPABAAUABwiTIh0IAPABAAYABQisIrUpAHYBAAcABQiOHw4nAFYBAAAA.',Hy='Hypgr:BAABKgAFFH8gAAMIAAUIER4YGAAoAQAIAAUIER4YGAAoAQAJAAIInw8LWwBCAAAAAA==.Hypgrdly:BAACKgAFFH8NAAMKAAQIARfQRwCRAAAKAAMI1RTQRwCRAAALAAIIvhnqJgCKAAAqAAQKfxoAAwsACAi0H2AMAFMCAAsACAi0H2AMAFMCAAoAAgjGB7LGAEgAAAEqAAUUBQggAAgAER4A.',In='Ingbuffing:BAAAKgAECgQIBgAAAA==.',Ji='Jie:BAAAKgAECgQIBAAAAA==.',Li='Littleseal:BAABKgAFFH8NAAMKAAQI0RtzLQDdAAAKAAQI0RtzLQDdAAALAAEICQlUOQA0AAAAAA==.',Na='Nairobi:BAAAKgAECgQIBAAAAA==.',Ne='Nexusprime:BAABKgAECn8eAAMCAAgIHRi3FADyAQACAAgIHRi3FADyAQAEAAgIjAd9RgAfAQAAAA==.',Ni='Nixbt:BAAAKgADCggICgAAAA==.',Qn='Qnima:BAAAKgAECgYICwAAAA==.',Sa='Satansapostl:BAAAKgAECgUIBgAAAA==.',Si='Simulacra:BAABKgAFFH8OAAIMAAYIHxqSAwCYAQAMAAYIHxqSAwCYAQAAAA==.',Ty='Tyleness:BAAAKgAECgcIDgAAAA==.',Vo='Voyagers:BAAAKgAECgQIBAAAAA==.',Vv='Vvmyli:BAAAKgAECggIDgAAAA==.',['一个']='一个小目标:BAAAKgADCgQIBAAAAA==.',['一介']='一介匹夫:BAABKgAFFH8MAAMLAAYIexHoAQCRAQALAAYIexHoAQCRAQAKAAQI2BOHGADcAAAAAA==.',['一只']='一只小萨:BAABKgAFFH8KAAQNAAQIzA6VEQDKAAANAAQIzA6VEQDKAAAOAAMI9AWVIgBsAAABAAEI4AbaUQA3AAAAAA==.一只死亡猎:BAAAKgAFFAIIBAAAAA==.一只生存骑士:BAABKgAFFH8IAAIPAAMIzgitKACCAAAPAAMIzgitKACCAAAAAA==.',['一攸']='一攸贝贝一:BAAAKgAECgYIBgAAAA==.',['一溜']='一溜字母:BAAAKgAECggIEAAAAA==.',['一牧']='一牧了燃:BAABKgAFFH8GAAIEAAYIJxh3CgB6AQAEAAYIJxh3CgB6AQAAAA==.',['一穆']='一穆一:BAABKgAFFH8GAAIHAAMIrga5EwClAAAHAAMIrga5EwClAAAAAA==.',['一箭']='一箭定终身:BAAAKgAECggICwAAAA==.',['一辣']='一辣手回春一:BAAAKgADCgQICAAAAA==.',['不会']='不会射箭:BAAAKgAECggICAAAAA==.',['不好']='不好的贼:BAABKgAFFH8MAAMQAAgIQxf+BQAqAgAQAAgIQxf+BQAqAgARAAEIAACTCgAAAAAAAA==.',['不按']='不按套路来:BAAAKgAFFAMIBAAAAA==.',['不羁']='不羁的呼吸:BAAAKgADCgEIAQAAAA==.',['不胜']='不胜利毋宁死:BAAAKgAECggICAAAAA==.',['世纪']='世纪末的神:BAAAKgADCgEIAQAAAA==.世纪末的魔:BAABKgAFFH8MAAQFAAYIySWKAAAoAgAFAAYIySWKAAAoAgAGAAQIgAuGKgDDAAAHAAIIdBuZJgBMAAABKgAFFAgIDwAGAJIcAA==.',['丛锌']='丛锌揩室:BAAAKgADCggICAAAAA==.',['丨怪']='丨怪咖丨:BAACKgAFFH8IAAMSAAQInCP5FAD7AAASAAQIrB35FAD7AAATAAQI6hzUHwDqAAAqAAQKfyYABBMACAhVHB0ZACcCABMACAhVHB0ZACcCABIABQiREtFhAOoAABQAAwhZFjBqAMwAAAAA.',['丨癫']='丨癫灬狂丨:BAAAKgAFFAIIAgAAAA==.',['丶叫']='丶叫我傲气:BAAAKgAECggICAAAAA==.',['丶娘']='丶娘娘丶:BAAAKgAECgUIBQAAAA==.',['丶尼']='丶尼克偶吧:BAAAKgAFFAYIAQAAAA==.',['丶玥']='丶玥梦希:BAAAKgAFFAYIAwAAAA==.',['丶瓦']='丶瓦里安丶:BAAAKgADCgEIAQAAAA==.',['丿胖']='丿胖多多:BAABKgAFFH8IAAIUAAQIvg/NGgCpAAAUAAQIvg/NGgCpAAAAAA==.',['乱世']='乱世紫瞳:BAAAKgAFFAgIBAAAAA==.',['二大']='二大爷:BAAAKgADCggIFwAAAA==.',['今夕']='今夕何夕:BAABKgAFFH8GAAIIAAYIRBsWLQC3AAAIAAYIRBsWLQC3AAAAAA==.',['今朝']='今朝易在梦里:BAAAKgAFFAQIBAAAAA==.',['仓鼠']='仓鼠:BAAAKgAECgQIBAAAAA==.仓鼠的牧:BAAAKgAECgIIAgAAAA==.',['伊咕']='伊咕哔咕:BAAAKgAECggICgAAAA==.',['伊洛']='伊洛曼希斯:BAABKgAFFH8KAAMPAAQIWhu+DwD6AAAPAAQIWhu+DwD6AAAVAAII2BZoGwB8AAAAAA==.',['伊莉']='伊莉莎:BAAAKgAFFAIIAgAAAA==.',['伽椰']='伽椰子:BAAAKgADCgYIBgABKgAFFAQIBAAWAAAAAA==.',['依赖']='依赖:BAABKgAECn8UAAMGAAgIZx7REgBUAgAGAAgIxx3REgBUAgAHAAcITBcvMwApAQAAAA==.',['信用']='信用债:BAAAKgAFFAQIBAAAAA==.',['倔强']='倔强的蜗牛:BAAAKgADCgMIAwAAAA==.',['偷袭']='偷袭不爽:BAAAKgAFFAgIBAAAAA==.',['元气']='元气弹:BAAAKgAECgcIBwAAAA==.',['光翼']='光翼展开:BAAAKgAFFAIIAgABKgAFFAgIBAAWAAAAAA==.',['兔斯']='兔斯耶夫斯基:BAAAKgAECgcIDgAAAA==.',['公正']='公正怜悯谦卑:BAAAKgAECgYIBgAAAA==.',['兰瑞']='兰瑞莎:BAAAKgADCgQIBAAAAA==.',['冰块']='冰块好吃:BAABKgAECn8WAAMLAAgIaB09FAABAgALAAgIaB09FAABAgAKAAYIgSCDNQDTAQAAAA==.',['冰璃']='冰璃:BAAAKgAECggIDgAAAA==.',['凯美']='凯美瑞:BAABKgAFFH8OAAIMAAgIZRFECgACAgAMAAgIZRFECgACAgAAAA==.',['加尔']='加尔鲁:BAAAKgADCgQIBAAAAA==.',['十五']='十五术:BAACKgAFFH8gAAMGAAQIAx1lIgD1AAAGAAQIAx1lIgD1AAAHAAEIAAChNQAAAAAqAAQKfzQAAwYACAiAHi4UAAYCAAYABwgbHy4UAAYCAAcAAwiAETFQAKgAAAAA.',['千歲']='千歲:BAAAKgAECggICAABKgAFFAgILAAXAMEgAA==.',['千锤']='千锤百炼:BAAAKgAECgEIAQAAAA==.',['午夜']='午夜:BAABKgAECn8VAAICAAgIECBcBACXAgACAAgIECBcBACXAgAAAA==.',['卖茶']='卖茶叶的:BAAAKgADCgMIAwAAAA==.',['卡卡']='卡卡西:BAAAKgAECgIIAgAAAA==.',['卡库']='卡库萨:BAABKgAFFH8FAAIPAAUIdwTYEgDQAAAPAAUIdwTYEgDQAAAAAA==.',['又帅']='又帅又拽:BAABKgAFFH8KAAIGAAYI2AtrHgAVAQAGAAYI2AtrHgAVAQAAAA==.又帅又衰:BAAAKgAFFAQIBAAAAA==.',['发糖']='发糖使者:BAAAKgADCggIHwAAAA==.',['变异']='变异牛:BAAAKgADCgQIBAAAAA==.',['可心']='可心可心:BAAAKgAECgYIBgAAAA==.',['可爱']='可爱又迷人:BAAAKgAFFAEIAQAAAA==.',['吃人']='吃人晨:BAAAKgADCgYIBgAAAA==.',['吃宝']='吃宝心情好:BAAAKgAECgMIAwAAAA==.',['合原']='合原圣骑:BAAAKgAFFAEIAgAAAA==.',['吐舌']='吐舌头:BAABKgAECn8XAAMHAAcI7BhaHQCcAQAHAAcIqxdaHQCcAQAGAAMIfAzRfQCTAAAAAA==.',['呐尼']='呐尼:BAAAKgAECgQIBAAAAA==.',['哎呀']='哎呀嘿嗨咻:BAAAKgADCgMIAwAAAA==.',['哞利']='哞利斯塔:BAAAKgAECgIIAgAAAA==.',['唐门']='唐门衮衮:BAABKgAFFH8YAAMHAAcIgxT/DQDHAAAGAAQIMBZCGwAsAQAHAAMIRxL/DQDHAAAAAA==.',['回噫']='回噫曾经:BAABKgAFFH8GAAMSAAYIbw7+FQAEAQASAAUIwBD+FQAEAQAUAAEIKwU3LQA0AAAAAA==.',['土丶']='土丶灵:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光妠利塔:BAAAKgAECgIIAgAAAA==.圣光永远超神:BAABKgAFFH8FAAMMAAMIwAQENwCFAAAMAAMIwAQENwCFAAAYAAEIfwHsHAAgAAAAAA==.',['圣殿']='圣殿丶骑士:BAAAKgAECgMIAwAAAA==.',['圣牛']='圣牛克赛:BAAAKgADCggICAAAAA==.',['圣白']='圣白莲:BAAAKgAFFAEIAQAAAA==.',['圣踪']='圣踪:BAAAKgADCgQIBAAAAA==.',['埃兰']='埃兰的臭鞋:BAAAKgAECgEIAQAAAA==.',['基地']='基地蛋花:BAAAKgADCgEIAQAAAA==.',['塔戈']='塔戈拉恩:BAABKgAFFH8IAAIKAAgIdAGGGADkAAAKAAgIdAGGGADkAAAAAA==.',['声声']='声声慢:BAAAKgAECggICAAAAA==.声声漫:BAAAKgAECgQICgAAAA==.',['夏尔']='夏尔提雅:BAAAKgAECgEIAQAAAA==.',['多米']='多米糯:BAAAKgADCgIIAgAAAA==.',['夜语']='夜语瞳:BAAAKgADCgEIAQAAAA==.',['夢珂']='夢珂丶珂:BAAAKgAFFAIIBAAAAA==.',['大哥']='大哥曾:BAABKgAECn8dAAIPAAgIViHtDgCqAgAPAAgIViHtDgCqAgAAAA==.',['大守']='大守密者:BAAAKgAECgEIAQAAAA==.',['大跳']='大跳飞尸:BAAAKgAFFAEIAQAAAA==.',['天涯']='天涯若比邻:BAAAKgAFFAgIBAAAAA==.',['天鹅']='天鹅湾网格员:BAACKgAFFH8IAAITAAQIGxBKGgCuAAATAAQIGxBKGgCuAAAqAAQKfykAAhMACAhAHk0UAFICABMACAhAHk0UAFICAAAA.',['奈亚']='奈亚拉托提普:BAAAKgADCgcIBwAAAA==.',['奎因']='奎因:BAAAKgAECgUIBQAAAA==.',['奔放']='奔放的生理期:BAAAKgAFFAIIAgAAAA==.',['奔雷']='奔雷剑主大奔:BAAAKgAFFAQIAwABKgAFFAgIGAADAOgeAA==.',['她永']='她永远第一:BAAAKgAECggICAAAAA==.',['妹纸']='妹纸你是谁:BAAAKgAECgIIAgAAAA==.',['姬天']='姬天双:BAAAKgADCggICAAAAA==.',['娇羞']='娇羞的生理期:BAACKgAFFH8VAAIZAAMIPhsfDgDSAAAZAAMIPhsfDgDSAAAqAAQKfxkAAhkACAimGv8OAAoCABkACAimGv8OAAoCAAAA.',['宇宙']='宇宙圣骑:BAAAKgAECgcIBwAAAA==.',['宝宝']='宝宝的小花花:BAAAKgAFFAQIBAAAAA==.宝宝胖花:BAABKgAFFH8GAAIaAAYIMANxFwDmAAAaAAYIMANxFwDmAAAAAA==.',['寻花']='寻花千百度:BAABKgAFFH8LAAIBAAgILhQiAgB/AQABAAgILhQiAgB/AQAAAA==.',['射手']='射手座:BAAAKgAECggICgAAAA==.',['小卒']='小卒子:BAAAKgADCgIIAgAAAA==.',['小咔']='小咔啦米:BAAAKgAFFAQIBAAAAA==.',['小多']='小多米:BAABKgAFFH8IAAIbAAgI4Q4AFwAQAQAbAAgI4Q4AFwAQAQAAAA==.',['小洗']='小洗只狼:BAABKgAECn9VAAIaAAgIXBkrIADsAQAaAAgIXBkrIADsAQAAAA==.',['小熊']='小熊丶蛋包饭:BAAAKgAFFAcIAgAAAA==.',['小竹']='小竹子想熊猫:BAAAKgAECgYICwAAAA==.',['小萨']='小萨鲁法尔:BAAAKgAECggIEAAAAA==.',['小血']='小血兽不了啦:BAAAKgAECgIIAgAAAA==.',['小野']='小野马:BAAAKgAFFAgIBAAAAA==.',['小阿']='小阿的女人:BAABKgAFFH8LAAIPAAMI5Ac9PQCoAAAPAAMI5Ac9PQCoAAAAAA==.',['小霞']='小霞:BAAAKgAECgYIBgAAAA==.',['小骚']='小骚气:BAAAKgADCgMIAwAAAA==.',['就不']='就不告诉你:BAAAKgADCggICAAAAA==.',['尼奥']='尼奥法:BAABKgAFFH8HAAITAAcIxAnSDAB8AQATAAcIxAnSDAB8AQAAAA==.尼奥骑:BAABKgAFFH8IAAIYAAgI0wpmBgCDAQAYAAgI0wpmBgCDAQAAAA==.',['山一']='山一程:BAAAKgAFFAgIBAAAAA==.',['帅武']='帅武:BAAAKgAFFAIIAgAAAA==.',['帅气']='帅气十足风:BAABKgAECn8UAAMUAAcIuQ9CQADwAAAUAAcIuQ9CQADwAAASAAEImQEArAAUAAAAAA==.',['幽明']='幽明:BAAAKgAECggICAAAAA==.',['弥丨']='弥丨海砂:BAAAKgAECggIDQABKgAFFAQIBAAWAAAAAA==.',['張牙']='張牙丶舞爪:BAABKgAFFH8QAAMbAAgIeRG+BwD3AQAbAAgIeRG+BwD3AQAcAAQIgQyJBgCiAAAAAA==.',['彻悟']='彻悟德:BAAAKgADCgQIBAAAAA==.',['心灭']='心灭遗言:BAAAKgAFFAIIAwABKgAFFAgIEQAGADYhAA==.',['念无']='念无应:BAAAKgAFFAQIBAABKgAFFAgIKAAMAI8ZAA==.',['怀民']='怀民亦未寝:BAACKgAFFH8YAAIaAAcIHBjEBADmAQAaAAcIHBjEBADmAQAqAAQKfysAAxoACAghGa8eAPYBABoACAghGa8eAPYBAB0ABAjzCPdQAH0AAAAA.',['悦悦']='悦悦:BAABKgAFFH8GAAIJAAII4QnhUABpAAAJAAII4QnhUABpAAAAAA==.',['惟愿']='惟愿岁月静好:BAAAKgADCggICAAAAA==.',['我先']='我先来:BAAAKgAECggICAAAAA==.',['我叫']='我叫梅办法:BAAAKgAECggIEQAAAA==.',['我就']='我就嗖一下:BAAAKgAFFAYIBAAAAA==.',['我怎']='我怎么还没似:BAAAKgADCgMIAwABKgAFFAgIAgAWAAAAAA==.',['我憨']='我憨憨:BAAAKgAECgYIBgAAAA==.',['我提']='我提丶一杯:BAAAKgAFFAgIBAAAAA==.',['我芳']='我芳芳郁金香:BAAAKgAECgUIBgAAAA==.',['戦訷']='戦訷:BAAAKgAECgYIEAAAAA==.',['戰凰']='戰凰:BAABKgAECn8dAAIMAAgInRQIaACLAQAMAAgInRQIaACLAQAAAA==.',['拉不']='拉不拉多:BAAAKgADCgIIAgAAAA==.',['攒劲']='攒劲甜斯:BAAAKgAECgYIBgAAAA==.',['放开']='放开她让我来:BAABKgAECn8mAAMMAAgI/h5FJQBrAgAMAAgIbB5FJQBrAgAYAAIIDhh7GQCGAAAAAA==.',['放開']='放開那個女孩:BAACKgAFFH8TAAMBAAYIDBWrDQB0AQABAAYIDBWrDQB0AQAOAAMIOxlfDwDrAAAqAAQKfxsAAg4ABgj4IjcQAFYCAA4ABgj4IjcQAFYCAAAA.',['救赎']='救赎丶無用:BAAAKgADCggICAAAAA==.',['斑点']='斑点刺猬:BAAAKgAECgMIAwAAAA==.',['斯巴']='斯巴达克:BAAAKgADCggICQAAAA==.',['斿俠']='斿俠:BAAAKgADCggICQAAAA==.',['旋涡']='旋涡异族:BAABKgAFFH8YAAIeAAYIMBq1DQCnAQAeAAYIMBq1DQCnAQAAAA==.',['旋风']='旋风剑主达达:BAAAKgAFFAIIAgAAAA==.',['星之']='星之金幣:BAAAKgADCggICAAAAA==.',['星月']='星月唤羽:BAAAKgAECgEIAQAAAA==.',['星野']='星野琉璃:BAAAKgAFFAYIBAAAAA==.',['昼丶']='昼丶酒:BAAAKgAFFAgIBAAAAA==.',['晋南']='晋南李敏镐:BAABKgAFFH8GAAIKAAYICB3cAAD6AQAKAAYICB3cAAD6AQAAAA==.',['晓丶']='晓丶骑士:BAAAKgAECgYICwAAAA==.',['晴空']='晴空破晓:BAAAKgAECgIIAgAAAA==.',['暖羊']='暖羊羊:BAABKgAFFH8MAAMUAAQIZhjVCADnAAAUAAQIGhfVCADnAAATAAQI5RRoKwC2AAAAAA==.',['暴力']='暴力双鱼:BAACKgAFFH8JAAIKAAMI4giIQgCjAAAKAAMI4giIQgCjAAAqAAQKfxcAAgoACAi7FcE1ANEBAAoACAi7FcE1ANEBAAAA.',['暴打']='暴打奴隶:BAAAKgAECgYIBgAAAA==.',['最后']='最后的角色:BAABKgAFFH8HAAIbAAYIMBdGEwA4AQAbAAYIMBdGEwA4AQABKgAFFAgIGwAbACwhAA==.',['月野']='月野兔:BAAAKgADCgEIAQAAAA==.',['木木']='木木禾术:BAAAKgAFFAYIBAAAAA==.',['木辛']='木辛珺:BAABKgAFFH8GAAIMAAYIhiDoFAC1AQAMAAYIhiDoFAC1AQAAAA==.',['朽木']='朽木白哉:BAAAKgAECggICAAAAA==.',['杀戮']='杀戮术:BAABKgAECn8dAAMHAAgIFQjCQADvAAAHAAgICgbCQADvAAAGAAQIUwm5LgCeAAAAAA==.',['李火']='李火旺:BAABKgAFFH8QAAQFAAYIzhtmAgAoAQAGAAQI8CEvBwAyAQAFAAUIgBpmAgAoAQAHAAEIdwwgGABLAAAAAA==.',['杰克']='杰克逊:BAAAKgADCggICAAAAA==.',['松尾']='松尾芭蕉:BAAAKgAFFAQIBAAAAA==.',['果粒']='果粒橙哇哈哈:BAABKgAFFH8GAAIMAAYI+QdiFwAxAQAMAAYI+QdiFwAxAQAAAA==.',['柒璨']='柒璨:BAAAKgAFFAQIBAABKgAFFAYIDgAYAHsUAA==.',['柴干']='柴干:BAAAKgADCgcIBwABKgAFFAgIBgATABsRAA==.',['梵小']='梵小凡:BAACKgAFFH8VAAIGAAQIBBtMJQDfAAAGAAQIBBtMJQDfAAAqAAQKfyoAAwYACAjrIPQDAIkCAAYACAjsH/QDAIkCAAcAAwhxI31aAIgAAAAA.',['橘子']='橘子猫:BAAAKgAECggICAAAAA==.',['橹西']='橹西:BAACKgAFFH8IAAMMAAcIvxy0HACBAQAMAAQIaSO0HACBAQAZAAMIaA+PCwCeAAAqAAQKfxgAAxkACAhBHzgIAGYCABkACAhBHzgIAGYCAAwABQi0GhncAO0AAAAA.',['欲术']='欲术丶临疯:BAAAKgAFFAQIBAAAAA==.',['毕德']='毕德:BAAAKgAFFAYIAwAAAA==.',['气定']='气定神闲:BAAAKgAFFAQIBAAAAA==.',['永恒']='永恒精灵皇:BAAAKgADCggIDAAAAA==.',['汕村']='汕村貞子:BAAAKgADCggIDgABKgAFFAQIBAAWAAAAAA==.',['池田']='池田依来沙:BAAAKgAECggICAAAAA==.',['污药']='污药王:BAAAKgAECgYIBgAAAA==.',['沁梦']='沁梦:BAAAKgADCggICAAAAA==.',['沈阳']='沈阳虎哥:BAAAKgAECggIDAABKgAECggIHQAPAFYhAA==.',['没事']='没事只想躺:BAAAKgAECgMIAwAAAA==.',['没有']='没有亡法啦:BAAAKgAECgEIAQAAAA==.',['泥泥']='泥泥洋:BAAAKgAFFAEIAQAAAA==.',['洛森']='洛森德:BAAAKgADCgYIBgAAAA==.',['深情']='深情终被辜负:BAAAKgAFFAIIAgABKgAFFAgIBgAfABcZAA==.',['混乱']='混乱风暴:BAAAKgADCggICAAAAA==.',['淺墨']='淺墨:BAAAKgAECgUIBgAAAA==.',['清灬']='清灬凈:BAAAKgAECgEIAQABKgAFFAgIEgAMAEYfAA==.',['温柔']='温柔狂刀:BAAAKgAECggICwAAAA==.',['濑户']='濑户灿:BAAAKgAECggICAAAAA==.',['灬哔']='灬哔哩哔哩:BAAAKgAECgYIBgAAAA==.',['灬春']='灬春丨圆灬:BAAAKgAECgIIAgAAAA==.',['灬欧']='灬欧布:BAAAKgAFFAQIBAAAAA==.',['灬血']='灬血枭坠影灬:BAAAKgAFFAMIAgAAAA==.',['灬赛']='灬赛罗:BAABKgAFFH8KAAIBAAYIURRZAQCmAQABAAYIURRZAQCmAQAAAA==.',['烤面']='烤面:BAAAKgADCggIDgAAAA==.',['热乂']='热乂夏:BAAAKgAECgEIAwAAAA==.',['焰之']='焰之魂:BAAAKgAFFAcIBAAAAA==.',['熊喵']='熊喵舞:BAAAKgAECgMIAwAAAA==.',['爱天']='爱天使的紫:BAAAKgAECgMIAwAAAA==.',['爱露']='爱露翼帝:BAAAKgAECgMIAwAAAA==.',['牧色']='牧色撩人:BAAAKgADCggICAAAAA==.',['牧语']='牧语安然:BAAAKgADCgUIBQAAAA==.',['猪是']='猪是谁念倒谁:BAAAKgAFFAIIAgABKgAFFAgICAAJABcdAA==.',['玉面']='玉面小飞龙:BAABKgAFFH8IAAIbAAgIoQ/GCADuAQAbAAgIoQ/GCADuAQAAAA==.',['玛哈']='玛哈嘎拉:BAABKgAFFH8HAAMgAAYIkxnKCgDFAAAfAAQIRBc2IADTAAAgAAIICh3KCgDFAAAAAA==.',['生命']='生命因你火热:BAAAKgAECggIBgAAAA==.',['电动']='电动御姐:BAACKgAFFH8KAAIfAAUIXB0PAwCIAQAfAAUIXB0PAwCIAQAqAAQKfxUAAh8ACAjEHh8UADgCAB8ACAjEHh8UADgCAAAA.电动萝莉:BAAAKgAFFAgIAQAAAA==.',['疯狂']='疯狂之法爷:BAAAKgAECgQIBAAAAA==.',['疾风']='疾风怒涛之计:BAAAKgAFFAYIAgAAAA==.',['白浅']='白浅:BAAAKgAECgQIBQAAAA==.',['白衣']='白衣麒麟:BAABKgAFFH8IAAMEAAgINhuIBQC/AQAEAAcIjxmIBQC/AQACAAEI5QF3GwA2AAAAAA==.',['皓宝']='皓宝:BAACKgAFFH8GAAIMAAQIQh73LAAzAQAMAAQIQh73LAAzAQAqAAQKfxUAAgwACAh4InE6AD8CAAwACAh4InE6AD8CAAAA.',['破灭']='破灭:BAAAKgAFFAIIAgAAAA==.',['破風']='破風生霊:BAAAKgAECgMIAwAAAA==.',['社会']='社会王:BAAAKgAECgIIAgAAAA==.',['神棍']='神棍儿:BAAAKgAECgIIAgAAAA==.',['秋舞']='秋舞灬風:BAACKgAFFH8SAAMJAAMI7hF0KQCqAAAJAAMI7hF0KQCqAAAIAAIIjAeSSgBWAAAqAAQKfyUABAkACAhkGu9DAOoBAAkACAghGe9DAOoBAAgABgijExE/ACgBACEAAgggHUoXAH4AAAAA.',['米米']='米米:BAAAKgADCgQIBAAAAA==.',['糖醋']='糖醋面筋:BAAAKgAECgUICAAAAA==.',['紫夜']='紫夜之心:BAAAKgAECggICQAAAA==.',['红旗']='红旗下的圣光:BAABKgAFFH8QAAMEAAQIKRJbFACcAAAEAAMIKRJbFACcAAADAAQIQwtCEgBmAAAAAA==.',['终日']='终日打雁:BAAAKgADCggICAAAAA==.',['网管']='网管李大爷:BAACKgAFFH8qAAIKAAYILBZ3FgBkAQAKAAYILBZ3FgBkAQAqAAQKfy4AAgoACAidIZodAFgCAAoACAidIZodAFgCAAAA.',['羽人']='羽人飞境:BAAAKgADCggICAAAAA==.',['羽咲']='羽咲:BAACKgAFFH8SAAMdAAgINBVfAQDWAQAdAAYIThZfAQDWAQAaAAQI5gqXEgAVAQAqAAQKfxgABB0ACAgRFQAiAI4BAB0ACAh2EgAiAI4BABoABwiHD4c/AEMBACIAAgi0FQUgAGgAAAAA.',['聆听']='聆听过往的诗:BAAAKgADCggICAAAAA==.',['聖光']='聖光祷言:BAABKgAFFH8GAAIDAAYIZgmmAwBkAQADAAYIZgmmAwBkAQAAAA==.',['肉夹']='肉夹馍:BAAAKgAFFAgIBAAAAA==.',['肉肉']='肉肉大:BAAAKgAECgYIEgAAAA==.',['胜灵']='胜灵王:BAAAKgADCgEIAwAAAA==.',['舒克']='舒克丶舒克:BAAAKgAECgYIBgAAAA==.',['舞雾']='舞雾我:BAAAKgAFFAQIBAAAAA==.',['艾妮']='艾妮雅:BAAAKgADCggICAAAAA==.',['花子']='花子:BAAAKgAECgcIDwABKgAFFAQIBAAWAAAAAA==.',['花海']='花海丶寻觅:BAAAKgADCggICAAAAA==.',['花都']='花都酒剑仙:BAAAKgAFFAIIAgAAAA==.',['范达']='范达尔鹿盔丶:BAAAKgADCggICAAAAA==.',['茨木']='茨木华扇:BAAAKgAECgYICwAAAA==.',['荷棠']='荷棠月色:BAAAKgAECgMIAwAAAA==.',['莎布']='莎布尼古拉斯:BAAAKgAECggIDQAAAA==.',['萌萌']='萌萌哒肉肉:BAAAKgAFFAQIBAAAAA==.',['萨瓦']='萨瓦熊熊:BAAAKgAFFAQIBAAAAA==.',['萨莱']='萨莱因:BAAAKgAECgYICwAAAA==.',['蓝色']='蓝色梦幻:BAAAKgADCgIIAgAAAA==.',['蓝雾']='蓝雾:BAAAKgADCgQIBAAAAA==.',['蔷薇']='蔷薇猎手:BAABKgAFFH8UAAMJAAYIvSGuBACKAQAJAAYIvSGuBACKAQAIAAQIZRJsDwDcAAAAAA==.',['虎皮']='虎皮鹦鹉:BAAAKgAECggICAAAAA==.',['蛋蛋']='蛋蛋丶僧:BAABKgAFFH8KAAMaAAQIHiU8BgBHAQAaAAQIHiU8BgBHAQAiAAIIrQaKCABXAAAAAA==.蛋蛋灬忧桑:BAABKgAFFH8MAAIYAAUI5QkRCgDDAAAYAAUI5QkRCgDDAAAAAA==.',['蜘蛛']='蜘蛛侦探:BAAAKgADCgEIAQAAAA==.',['蜡笔']='蜡笔小心眼子:BAAAKgAFFAQIBAAAAA==.',['蟑螂']='蟑螂恶霸:BAAAKgAFFAYIBAABKgAFFAgICAAIALMfAA==.',['血朦']='血朦胧:BAAAKgAECggICAAAAA==.',['血玉']='血玉麒麟:BAAAKgAFFAMIAwAAAA==.',['被腐']='被腐蚀的圣光:BAAAKgAECgUIBQAAAA==.',['被虚']='被虚空吞噬:BAAAKgADCggICAAAAA==.',['西属']='西属撒哈拉:BAAAKgAECgYIAgAAAA==.',['解散']='解散公会:BAABKgAFFH8RAAMEAAgIcQ7/BgCMAQAEAAgI+gv/BgCMAQADAAYIxQgwCQDrAAAAAA==.解散门徒:BAABKgAFFH8lAAIZAAgI1xSvAgAHAgAZAAgI1xSvAgAHAgAAAA==.',['记忆']='记忆中小小:BAACKgAFFH8LAAIfAAMIQhIdIADTAAAfAAMIQhIdIADTAAAqAAQKfyMAAh8ACAgrHf4GAFUCAB8ACAgrHf4GAFUCAAAA.记忆中的怀念:BAABKgAFFH8QAAIMAAMIWBSDIwDaAAAMAAMIWBSDIwDaAAAAAA==.记忆中的思念:BAABKgAFFH8JAAIEAAMIAApCFwCGAAAEAAMIAApCFwCGAAAAAA==.记忆中的想念:BAABKgAFFH8IAAIeAAMIjAfJNQCqAAAeAAMIjAfJNQCqAAAAAA==.记忆中的理念:BAACKgAFFH8JAAIbAAMItwWkGQCUAAAbAAMItwWkGQCUAAAqAAQKfz4AAhsACAhIF4EKAOABABsACAhIF4EKAOABAAAA.记忆中的纪念:BAACKgAFFH8PAAIJAAMIZhXiLQDQAAAJAAMIZhXiLQDQAAAqAAQKfxoAAgkACAgOHx8bAF4CAAkACAgOHx8bAF4CAAAA.记忆随风流逝:BAACKgAFFH8MAAIUAAMInghzHACgAAAUAAMInghzHACgAAAqAAQKfxcAAhQACAg3GNsZAOUBABQACAg3GNsZAOUBAAAA.',['貂蝉']='貂蝉思吕布:BAAAKgAFFAQIBAAAAA==.',['贰玥']='贰玥丶:BAABKgAFFH8HAAIZAAQICBjABQDvAAAZAAQICBjABQDvAAABKgAFFAgIEQAKAEEeAA==.',['赤红']='赤红天使:BAABKgAECn8cAAIMAAgIEh97IgCQAgAMAAgIEh97IgCQAgAAAA==.',['越长']='越长大越寂寞:BAABKgAFFH8GAAMKAAYIfQz5HwAgAQAKAAUIRg35HwAgAQALAAEICxA0NABIAAAAAA==.',['路过']='路过皆是浪漫:BAAAKgAFFAgIBAAAAA==.',['踏云']='踏云剑歌:BAAAKgADCggICAAAAA==.',['过油']='过油肉拌面:BAAAKgAECgQIBAAAAA==.',['迪萨']='迪萨斯:BAAAKgAECggIDQAAAA==.',['迪迪']='迪迪小微:BAAAKgAECgMIBAAAAA==.',['迷踪']='迷踪猎寻:BAAAKgADCgUIBQAAAA==.',['逝丶']='逝丶去:BAAAKgAECgUIBwAAAA==.',['遗忘']='遗忘丶痛苦:BAABKgAECn8VAAMKAAgIaRXeUAB0AQAKAAgIaRXeUAB0AQALAAcIyhAbMgApAQAAAA==.遗忘战神:BAAAKgAECgQIBAAAAA==.',['酒汣']='酒汣:BAAAKgAECggICgAAAA==.',['酸萝']='酸萝卜别吃:BAAAKgAECgYIBgAAAA==.',['钢棍']='钢棍尚师傅:BAABKgAFFH8IAAMiAAQIaQrwBgCaAAAiAAQIaQrwBgCaAAAdAAQITAEAFQBMAAAAAA==.',['钢镚']='钢镚儿:BAAAKgAECgIIAgAAAA==.',['铁皮']='铁皮:BAAAKgAFFAMIAwAAAA==.',['银魂']='银魂:BAABKgAECn8VAAIjAAgIUx96BgBiAgAjAAgIUx96BgBiAgAAAA==.',['阳光']='阳光丨晨歌:BAABKgAFFH8VAAMUAAYI7CTuAQAOAgAUAAYI7CTuAQAOAgASAAYIDhc4CgCUAQAAAA==.',['阿塔']='阿塔兰塔:BAAAKgAECgQIBAAAAA==.',['阿斯']='阿斯达的勇士:BAAAKgAECgIIAgAAAA==.',['阿牧']='阿牧:BAABKgAECn8gAAQDAAcIHxZfLQBIAQADAAcIHxZfLQBIAQAEAAUIJQfuawCZAAACAAIIqQJKdAAzAAAAAA==.',['陈魁']='陈魁锋:BAAAKgADCgcICAAAAA==.',['隔壁']='隔壁老劉:BAABKgAECn8/AAILAAgI/x0GBQBUAgALAAgI/x0GBQBUAgAAAA==.',['雅芽']='雅芽:BAAAKgADCgcIBwAAAA==.',['雨陌']='雨陌:BAAAKgADCgQICAAAAA==.',['雪山']='雪山飞狐:BAAAKgADCggICgAAAA==.',['震荡']='震荡波:BAAAKgAFFAIIAgAAAA==.',['霓裳']='霓裳舞:BAAAKgAECgIIBAAAAA==.',['青丘']='青丘丶白凤九:BAAAKgAFFAYIBAABKgAFFAgIHQAFAOkaAA==.',['青山']='青山白云:BAABKgAFFH8FAAIMAAUIUAjvPwDxAAAMAAUIUAjvPwDxAAAAAA==.',['非法']='非法咔咔:BAAAKgAECgIIBAAAAA==.',['非要']='非要去美黑:BAAAKgADCgcIBwAAAA==.非要画个妆:BAABKgAFFH8QAAIPAAQISxYtEgDXAAAPAAQISxYtEgDXAAAAAA==.',['面包']='面包制造者:BAAAKgAECgMIBAAAAA==.',['頭鼑']='頭鼑冭胤曐:BAAAKgAECgIIAgAAAA==.',['风一']='风一程:BAAAKgAECggICAAAAA==.',['风吟']='风吟雪啸:BAABKgAECn8RAAIPAAgIjhwaIgAHAgAPAAgIjhwaIgAHAgAAAA==.',['风骚']='风骚的三胖子:BAABKgAFFH8UAAIYAAgIsCCbBAADAgAYAAgIsCCbBAADAgAAAA==.',['飒蠻']='飒蠻:BAAAKgAECgcIBAABKgAFFAgIEQADADMcAA==.',['飛鳥']='飛鳥华:BAAAKgAFFAYIBAAAAA==.飛鳥華:BAAAKgAECgYICQAAAA==.',['饭饭']='饭饭:BAACKgAFFH8NAAQkAAYIuxIRAwD2AAAgAAYIDRAWCwBcAQAkAAUImgoRAwD2AAAfAAII8hs+HQChAAAqAAQKfyEAAh8ACAihGQ0aAAECAB8ACAihGQ0aAAECAAAA.',['香蕉']='香蕉牛奶牛:BAABKgAFFH8IAAITAAgIAwqLCgDCAQATAAgIAwqLCgDCAQAAAA==.',['骚气']='骚气:BAAAKgAECgQIBAAAAA==.',['魔人']='魔人东东:BAAAKgADCgEIAQAAAA==.',['魔兽']='魔兽小爱:BAAAKgADCgUIBQAAAA==.',['魔戈']='魔戈莱妮:BAABKgAFFH8JAAIMAAUIziNNGAD7AAAMAAUIziNNGAD7AAABKgAFFAgIBAAWAAAAAA==.',['魔纹']='魔纹:BAAAKgAECgEIAQABKgAECggIHAAMABIfAA==.',['麻兄']='麻兄弟包谷:BAACKgAFFH8KAAIKAAQIrRHmHgDBAAAKAAQIrRHmHgDBAAAqAAQKfx8ABAoACAgtGWA6AL4BAAoABQg0ImA6AL4BAAsABwgEC21DAAEBACUAAQhqBOM2ABwAAAAA.',['黑暗']='黑暗飓风:BAAAKgADCgMIAwAAAA==.',['黑茶']='黑茶:BAAAKgAECgEIAQAAAA==.',['默玲']='默玲儿:BAAAKgAECgQIBAAAAA==.',['黛影']='黛影:BAAAKgAFFAQIBAAAAA==.',['龍天']='龍天裔:BAAAKgAECgEIAQAAAA==.',['龙之']='龙之幽幽:BAAAKgADCgMIAwAAAA==.',['龙人']='龙人按摩:BAAAKgAFFAIIAgAAAA==.',['龙希']='龙希尔战坦:BAAAKgAECgYICgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end