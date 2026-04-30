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

local lookup = {'Shaman-Elemental','Shaman-Restoration','Warrior-Protection','Unknown-Unknown','Priest-Shadow','Priest-Holy','Priest-Discipline','Monk-Mistweaver','Druid-Balance','Paladin-Retribution','Druid-Restoration','Monk-Brewmaster','Hunter-Marksmanship','DemonHunter-Devourer','Rogue-Subtlety','Rogue-Assassination','Mage-Frost','Warrior-Fury','Warrior-Arms','Hunter-BeastMastery','DeathKnight-Unholy','Paladin-Protection','Warlock-Demonology','Warlock-Destruction','Evoker-Augmentation','DeathKnight-Blood',}
local provider = {region='CN',realm='拉格纳罗斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Aia:BAAALgADCgYJBgAAAA==.',
Da='Davincii:BAAALgAECgUJBQAAAA==.',
Dd='Ddkk:BAAALgAFFAEJAgAAAA==.',
Do='Dogfan:BAAALgAECgEJAwAAAA==.',
Es='Estel:BAAALgAECgUJBgAAAA==.',
Fa='Fallenknight:BAAALgAFFAEJAQAAAA==.',
Fo='Foxdie:BAACLgAFFH8RAAMBAAUJFCKyAQCBAQABAAUJFCKyAQCBAQACAAIJJQqBGwCLAAAuAAQKfx0AAwEACAmWIkkHAB8DAAEACAmWIkkHAB8DAAIABQnoE9FdABQBAAAA.',
Ko='Kohza:BAAALgAECgYJCgABLgAFFAQJCwADAEcPAA==.Koje:BAAALgADCgQJBAAAAA==.',
Ku='Kuonjialice:BAAALgAECgIJAwAAAA==.',
Ma='Magicmar:BAAALgAECgEJAwABLgAFFAgJAgAEAAAAAA==.Mar:BAAALgAFFAIJAwAAAA==.',
Mo='Mobius:BAAALgAFFAIJBAABLgAFFAMJBwAFAJ4bAA==.Morant:BAABLgAFFH8GAAMGAAIJkiM1BQDUAAAGAAIJkiM1BQDUAAAHAAIJZhjNEQCpAAAAAA==.',
Pl='Playerpysbtp:BAAALgADCgQJBAAAAA==.',
Ro='Rocveadeelan:BAABLgAFFH8GAAIIAAQJIhm4BgBYAQAIAAQJIhm4BgBYAQAAAA==.Rohsi:BAAALgADCgYJCwAAAA==.',
Sa='Saill:BAAALgAECgUJBwAAAA==.',
Sk='Skada:BAAALgAECgEJAQABLgAECgYJDQAEAAAAAA==.',
Vi='Vivi:BAAALgADCgcJCwAAAA==.',
Wh='Whatcolor:BAABLgAFFH8GAAIJAAQJmB5KBQCVAQAJAAQJmB5KBQCVAQABLgAFFAUJEQABABQiAA==.',
Xj='Xjg:BAAALgAECgUJBQAAAA==.',
['一声']='一声长叹:BAAALgADCgYJBgAAAA==.',
['一眼']='一眼万年:BAAALgAECgQJBAAAAA==.',
['一鹅']='一鹅:BAAALgAECgUJDAAAAA==.',
['三号']='三号死骑:BAAALgAECgkJBwAAAA==.三号骑士:BAAALgAECgYJCwAAAA==.',
['不搓']='不搓面包搓糖:BAAALgAECgkJEAAAAA==.',
['丶知']='丶知南:BAAALgAECgQJBAAAAA==.',
['九成']='九成熟:BAAALgAECgEJAQAAAA==.',
['二号']='二号死骑:BAAALgAECgYJBgAAAA==.二号骑士:BAABLgAECn8WAAIKAAcJ1R4rPQAwAgAKAAcJ1R4rPQAwAgAAAA==.',
['二星']='二星牛蛙:BAAALgAECgQJCQAAAA==.',
['亘古']='亘古:BAAALgAECgYJCgAAAA==.',
['人心']='人心薄凉丶伤:BAABLgAECn8UAAILAAcJwBXXOQC+AQALAAcJwBXXOQC+AQAAAA==.',
['伊伦']='伊伦:BAAALgAECgYJDAAAAA==.',
['伯牙']='伯牙绝弦丷:BAAALgAECgMJAwAAAA==.',
['低胸']='低胸不露背:BAAALgAECgYJDQAAAA==.',
['你的']='你的王大爷:BAAALgAECgQJBgAAAA==.',
['依大']='依大然:BAAALgAFFAQJBAAAAA==.',
['保国']='保国:BAABLgAECn8XAAIMAAgJ9iC7CAD7AgAMAAgJ9iC7CAD7AgAAAA==.',
['光之']='光之悲硩苏林:BAAALgAECggJEwAAAA==.',
['光头']='光头强:BAAALgAECgYJBAAAAA==.',
['光羽']='光羽:BAABLgAFFH8MAAINAAQJaQuBEQAgAQANAAQJaQuBEQAgAQAAAA==.',
['克莱']='克莱耶:BAAALgAECgYJCgAAAA==.',
['冥界']='冥界狂人:BAAALgADCgEJAQAAAA==.',
['冬天']='冬天吃西瓜:BAAALgAECgUJBQAAAA==.',
['出了']='出了名的能扛:BAAALgAECgQJBQABLgAFFAYJBgAOAGofAA==.',
['刀十']='刀十三:BAAALgADCgYJBgABLgAFFAIJBgAGAJIjAA==.',
['分割']='分割线从:BAAALgAECgcJBwAAAA==.',
['北冰']='北冰洋汽水丷:BAAALgAECgcJBwAAAA==.',
['千岛']='千岛之光:BAABLgAFFH8FAAIKAAIJSA80JQChAAAKAAIJSA80JQChAAAAAA==.',
['卿本']='卿本佳人:BAAALgAFFAEJAQAAAA==.',
['反方']='反方向的约定:BAAALgAECgYJCAAAAA==.',
['叶落']='叶落深秋:BAACLgAFFH8HAAIPAAMJ1RipDAAaAQAPAAMJ1RipDAAaAQAuAAQKfyIAAw8ACAmIHF0TAH4CAA8ABwnxHV0TAH4CABAAAQkVFDAcAEcAAAEuAAUUBgkWAA8AliAA.',
['吓着']='吓着我了你:BAAALgADCgUJBQAAAA==.',
['君君']='君君念:BAAALgAECgQJBAAAAA==.',
['呼噜']='呼噜呼噜:BAAALgADCgMJAwAAAA==.',
['咕咕']='咕咕吉:BAAALgAFFAIJBAAAAA==.',
['咖喱']='咖喱油条:BAAALgAECgEJAQAAAA==.',
['哈利']='哈利六呀:BAACLgAFFH8FAAIRAAIJKBLnPQCwAAARAAIJKBLnPQCwAAAuAAQKfxcAAhEABglWHXZvAPUBABEABglWHXZvAPUBAAAA.',
['哈基']='哈基米德丶:BAAALgAECgcJEAAAAA==.',
['啵啰']='啵啰啵啰咪:BAAALgAFFAQJAwAAAA==.',
['噼里']='噼里啪啦:BAAALgAECgcJBwAAAA==.',
['四号']='四号死骑:BAAALgAECgcJAwAAAA==.四号骑士:BAABLgAECn8UAAIKAAkJChKdPgArAgAKAAkJChKdPgArAgAAAA==.',
['圣光']='圣光在忽悠你:BAAALgAECgEJAQAAAA==.圣光斗士:BAAALgADCgYJBgAAAA==.圣光照耀我:BAABLgAFFH8FAAIKAAMJhxVlCwAJAQAKAAMJhxVlCwAJAQAAAA==.',
['圣血']='圣血天使:BAAALgAECgYJBgAAAA==.',
['坚果']='坚果:BAACLgAFFH8RAAISAAUJqCVVAACwAQASAAUJqCVVAACwAQAuAAQKfyEAAxIACAmfIwoIACoDABIACAlQIwoIACoDABMAAgl6IoAkAMkAAAAA.',
['壹号']='壹号死骑:BAAALgAECgcJCwAAAA==.壹号法师:BAAALgADCgMJAwAAAA==.壹号骑士:BAAALgAECgcJEwAAAA==.',
['夜妖']='夜妖娆莫言殇:BAAALgADCgEJAQAAAA==.',
['夜行']='夜行鬼之龙王:BAAALgAECgUJBgAAAA==.',
['夢想']='夢想的初衷:BAAALgADCgEJAQAAAA==.',
['大侠']='大侠爱吃汉堡:BAAALgADCgYJBgAAAA==.',
['大娃']='大娃:BAAALgAECgYJCAAAAA==.',
['大屁']='大屁孩:BAAALgAECgkJCQAAAA==.',
['大橘']='大橘有点重:BAABLgAFFH8QAAICAAUJth23AQDfAQACAAUJth23AQDfAQAAAA==.',
['大炮']='大炮林:BAAALgAECgQJBAAAAA==.',
['天堂']='天堂制造:BAABLgAECn8VAAQFAAgJ5RRDLgBuAQAFAAUJqRdDLgBuAQAHAAYJzgsqLAA6AQAGAAMJzxN4YACwAAAAAA==.',
['天琴']='天琴华樟:BAAALgAFFAMJBAAAAA==.',
['天罡']='天罡逆转:BAAALgAFFAEJAQAAAA==.',
['奥德']='奥德镳:BAAALgAECgYJBgAAAA==.',
['奶酪']='奶酪夹心大福:BAABLgAECn8aAAIKAAgJWx9uHgC1AgAKAAgJWx9uHgC1AgAAAA==.',
['妈妈']='妈妈:BAABLgAFFH8PAAIHAAUJFRbRBACdAQAHAAUJFRbRBACdAQAAAA==.',
['娜沫']='娜沫:BAAALgAECgcJBwAAAA==.',
['嫣然']='嫣然若雪:BAAALgAECgEJAQAAAA==.',
['寂寞']='寂寞亮了:BAABLgAFFH8HAAIBAAUJmx0OAwDAAQABAAUJmx0OAwDAAQAAAA==.',
['小丶']='小丶葡萄:BAABLgAFFH8FAAMUAAQJfRrJAgBxAQAUAAQJfRrJAgBxAQANAAEJMwR2KgBGAAAAAA==.',
['小傻']='小傻宝:BAAALgAECgMJBgAAAA==.小傻帽:BAAALgAECgEJAQAAAA==.',
['小屁']='小屁孩:BAAALgAFFAQJBAAAAA==.',
['小岛']='小岛同学:BAAALgAFFAIJAgAAAA==.小岛斌哥:BAAALgAECgYJCwAAAA==.',
['小趴']='小趴菜:BAAALgAECgQJBQAAAA==.',
['山水']='山水:BAAALgAECgQJBAAAAA==.',
['左右']='左右丶:BAAALgAFFAIJAgAAAA==.',
['幹枯']='幹枯大地丶風:BAABLgAECn8gAAMCAAgJxhw5EQCNAgACAAgJxhw5EQCNAgABAAUJMQ2ZTQARAQAAAA==.',
['张小']='张小凡雪琪:BAAALgAECgcJDwAAAA==.',
['心流']='心流:BAAALgAECgEJAQAAAA==.',
['志田']='志田千阳:BAAALgAECgEJAQAAAA==.',
['悦听']='悦听风吟:BAABLgAFFH8FAAIVAAMJ6g7+RgCWAAAVAAMJ6g7+RgCWAAAAAA==.',
['我就']='我就是刀刀:BAAALgAECggJEwAAAA==.',
['我爱']='我爱吃橘子:BAAALgAECgEJAQAAAA==.',
['我被']='我被你吓着了:BAAALgADCgEJAQAAAA==.',
['把妹']='把妹丶蓝精灵:BAAALgAECgcJCAAAAA==.把妹丶躺下面:BAAALgAECgYJDQAAAA==.',
['折桂']='折桂令丷:BAAALgAECgQJBgAAAA==.',
['提起']='提起脑壳耍:BAAALgAFFAIJAgAAAA==.',
['搞乐']='搞乐子:BAAALgAFFAEJAQAAAA==.',
['搞啥']='搞啥米:BAABLgAECn8WAAIRAAgJdhXMaQACAgARAAgJdhXMaQACAgAAAA==.',
['撒旦']='撒旦之邪力:BAAALgADCgUJBQAAAA==.',
['放养']='放养天堂星星:BAAALgADCgIJAgAAAA==.',
['既定']='既定天命:BAAALgAFFAEJAgAAAA==.',
['日落']='日落与星星:BAAALgAECgEJAQAAAA==.',
['早晨']='早晨织女星:BAABLgAFFH8NAAMTAAQJ7BDaAwADAQATAAMJIxLaAwADAQASAAIJPQzrEgBSAAAAAA==.',
['旺仔']='旺仔牛奶丷:BAABLgAECn8VAAIRAAcJlRSpdwDjAQARAAcJlRSpdwDjAQAAAA==.',
['村口']='村口阿花丶:BAAALgAFFAEJAQAAAA==.',
['来点']='来点干罗贝:BAAALgAECgUJCwAAAA==.来点玛萨拉:BAACLgAFFH8GAAMCAAMJgg3AGQCUAAACAAIJtgvAGQCUAAABAAIJ7gNSGgB5AAAuAAQKfxoAAwIABwluDc1IAF8BAAIABwluDc1IAF8BAAEABAnOGCRPAAoBAAAA.',
['柚叶']='柚叶枝希:BAAALgAFFAEJAQAAAA==.',
['柳如']='柳如烟:BAAALgAECgMJAwAAAA==.',
['梁上']='梁上君子:BAAALgADCgcJBwAAAA==.',
['梦倦']='梦倦还:BAAALgADCgIJAgAAAA==.',
['武丶']='武丶十壹:BAAALgAECgYJCgAAAA==.',
['武直']='武直:BAAALgADCgYJCQAAAA==.',
['永夜']='永夜之歌:BAAALgAECgMJBQAAAA==.',
['沐沐']='沐沐的小洋葱:BAAALgAECgEJAQAAAA==.',
['沙曼']='沙曼的小德:BAAALgADCgUJBQAAAA==.',
['沸腾']='沸腾的可乐:BAAALgAECgUJBQAAAA==.',
['法术']='法术暴师:BAABLgAFFH8HAAIRAAMJsBNaKQAPAQARAAMJsBNaKQAPAQAAAA==.',
['流光']='流光溢影:BAABLgAECn8YAAQGAAcJoRJYLQCQAQAGAAcJ8RFYLQCQAQAFAAIJig73UwB1AAAHAAIJSgwCSwBqAAAAAA==.',
['烟雨']='烟雨的野兽:BAAALgAECgQJBAAAAA==.烟雨缥缈:BAAALgAECgMJAgAAAA==.',
['煙雨']='煙雨縹緲:BAAALgADCgYJBgAAAA==.',
['燃烧']='燃烧军团使者:BAAALgADCgUJBQAAAA==.',
['牛嘿']='牛嘿:BAABLgAFFH8GAAMWAAMJ0hSJAwCuAAAWAAIJQByJAwCuAAAKAAIJ/QpwJQCgAAAAAA==.',
['牛毛']='牛毛裤:BAAALgAECgYJBwAAAA==.',
['牛气']='牛气的虎:BAAALgAECgEJAQABLgAECgUJBQAEAAAAAA==.',
['牛牛']='牛牛找男友:BAAALgAECgcJDQAAAA==.',
['猛牛']='猛牛娇羞:BAAALgAECgQJBAAAAA==.',
['玄天']='玄天大圣:BAAALgAECgYJBgAAAA==.',
['玉衡']='玉衡星刻晴:BAABLgAFFH8IAAIXAAMJERumEAALAQAXAAMJERumEAALAQAAAA==.',
['王不']='王不留行:BAAALgAFFAQJAQAAAA==.',
['王小']='王小色:BAAALgAECgYJCgAAAA==.',
['王某']='王某来了:BAAALgAECgYJCAAAAA==.',
['玲小']='玲小璐:BAAALgAECgYJBgAAAA==.',
['理塘']='理塘丁真:BAAALgAECgYJEwAAAA==.',
['甜甜']='甜甜糯米:BAAALgADCgEJAQAAAA==.',
['生存']='生存还是毁灭:BAAALgAECgEJAQAAAA==.',
['电光']='电光毒龙钻:BAAALgAFFAQJBAAAAA==.',
['略寒']='略寒德右手:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂钻石:BAAALgAECgMJAwAAAA==.',
['白切']='白切鸡:BAAALgADCgIJAgAAAA==.',
['白色']='白色均均:BAAALgAECgYJEAAAAA==.',
['白鑫']='白鑫之星:BAAALgADCgcJBwAAAA==.',
['瞬缘']='瞬缘雨:BAAALgAECgEJAQAAAA==.',
['知北']='知北丶:BAAALgADCgEJAQAAAA==.',
['知西']='知西:BAAALgAECgQJBAAAAA==.知西丶:BAAALgAECgIJAgAAAA==.',
['碎念']='碎念星河:BAAALgAFFAEJAgAAAA==.',
['祝踏']='祝踏岚:BAAALgAECgYJDAAAAA==.',
['神奇']='神奇灬冒险王:BAAALgAECgEJAQAAAA==.',
['神木']='神木與瞳:BAAALgAFFAEJAQAAAA==.',
['秩序']='秩序始源:BAABLgAFFH8JAAIMAAMJjw96FADTAAAMAAMJjw96FADTAAABLgAFFAUJEQAMAOwYAA==.',
['等怒']='等怒:BAABLgAFFH8GAAIKAAMJZBU3JACjAAAKAAMJZBU3JACjAAAAAA==.',
['米啊']='米啊内:BAAALgAECgUJBgAAAA==.',
['米布']='米布:BAAALgAFFAIJAgAAAA==.',
['糯米']='糯米甜甜:BAAALgAFFAEJAQAAAA==.',
['红烧']='红烧油条:BAAALgAECgYJCQAAAA==.红烧肉炖土豆:BAAALgADCgEJAQAAAA==.',
['纯阳']='纯阳贯地:BAAALgAECgEJAQAAAA==.',
['绝望']='绝望的乐乐:BAAALgAECgYJCgAAAA==.',
['绵羊']='绵羊菌:BAABLgAFFH8PAAMYAAUJth+FAABRAQAYAAUJth+FAABRAQAXAAEJtgNgUQBEAAAAAA==.',
['老零']='老零奶爸:BAAALgADCgMJAwAAAA==.',
['老顽']='老顽童:BAAALgAECgEJAQAAAA==.',
['耿鬼']='耿鬼:BAAALgAFFAIJAwABLgAFFAMJBQAZAEwPAA==.',
['聚地']='聚地弑:BAAALgAECgEJAQAAAA==.',
['胖牛']='胖牛牛:BAABLgAFFH8FAAMUAAIJNw70FACfAAAUAAIJnwf0FACfAAANAAIJ1gvCHwCWAAAAAA==.',
['舒克']='舒克大弟丶:BAAALgAFFAEJAQAAAA==.',
['艾丝']='艾丝德斯:BAAALgAECgYJCAAAAA==.',
['艾达']='艾达王:BAAALgADCgYJBQAAAA==.',
['苍蓝']='苍蓝星:BAAALgAFFAcJBAAAAA==.',
['莀莀']='莀莀:BAAALgAECgYJDgAAAA==.',
['莫笑']='莫笑化蝶飞:BAAALgAECgEJAgAAAA==.',
['萌丶']='萌丶小丶萌:BAAALgADCgkJCQAAAA==.',
['营养']='营养小甘薯:BAAALgAECgYJEgAAAA==.',
['葱爆']='葱爆油条:BAAALgAECgUJBQAAAA==.',
['西瓦']='西瓦的地狱火:BAABLgAFFH8IAAMXAAUJuBJsEAAMAQAXAAQJYRBsEAAMAQAYAAEJvxmYBABhAAAAAA==.西瓦的无常:BAABLgAFFH8PAAMXAAYJ6hZJCABRAQAXAAYJOhRJCABRAQAYAAIJdxfnAwBoAAAAAA==.西瓦的诅咒:BAABLgAFFH8IAAMXAAUJ8BKfEgAAAQAXAAQJXRCfEgAAAQAYAAEJqhqpEQBcAAAAAA==.西瓦的魔眼:BAABLgAFFH8OAAMXAAYJhxe1EQAFAQAXAAUJdxW1EQAFAQAYAAEJwx+TEABhAAAAAA==.',
['还年']='还年轻:BAABLgAFFH8LAAIaAAUJMgUHBgDjAAAaAAUJMgUHBgDjAAABLgAFFAQJDAAMAJoTAA==.',
['迪蒙']='迪蒙亨特:BAAALgAECgYJCAAAAA==.',
['铭泽']='铭泽:BAAALgAECgUJBQAAAA==.',
['锦猫']='锦猫灬灵灵法:BAAALgADCgMJBAAAAA==.',
['阿梨']='阿梨:BAAALgAECgMJAwAAAA==.',
['阿花']='阿花一:BAAALgAECgYJBgAAAA==.',
['雨霏']='雨霏:BAAALgAECgcJEgAAAA==.',
['霜之']='霜之快樂灬:BAABLgAECn8UAAIVAAgJ4RkvNQBiAgAVAAgJ4RkvNQBiAgAAAA==.',
['霸氣']='霸氣:BAAALgAECgEJAgAAAA==.',
['顶级']='顶级:BAAALgAFFAEJAQAAAA==.',
['風暴']='風暴之灵:BAAALgADCgcJBwAAAA==.',
['马鞍']='马鞍山吴彦祖:BAAALgAECgEJAgAAAA==.',
['鰻魚']='鰻魚児丶:BAAALgAECgMJAgAAAA==.',
['麒麟']='麒麟瞳:BAAALgADCgUJBQAAAA==.',
['黑暗']='黑暗遗忘者:BAAALgAECgcJEQAAAA==.',
['黑色']='黑色均均:BAAALgAFFAQJAwAAAA==.',
['黯乡']='黯乡魂:BAAALgAECgEJAQAAAA==.',
['龙葵']='龙葵:BAAALgAFFAIJAwAAAA==.',
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
