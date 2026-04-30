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

local lookup = {'DeathKnight-Unholy','Evoker-Augmentation','Warlock-Demonology','Mage-Frost','Hunter-BeastMastery','Hunter-Survival','DeathKnight-Blood','Monk-Brewmaster','Unknown-Unknown','Druid-Restoration','Druid-Balance','Paladin-Retribution','Hunter-Marksmanship','Evoker-Preservation','Priest-Discipline','Monk-Mistweaver','Druid-Guardian','Priest-Holy','Shaman-Elemental','Shaman-Restoration','Paladin-Holy','Warrior-Protection','DemonHunter-Devourer','Rogue-Subtlety','Warlock-Destruction',}
local provider = {region='CN',realm='轻风之语',name='CN',type='weekly',zone=46,date='2026-04-25',data={Af='Aftertee:BAAALgAECgYJBwAAAA==.',
Ar='Arya:BAAALgAECgMJAwAAAA==.',
As='Assassynale:BAAALgAECgQJBAAAAA==.',
Bi='Bigshow:BAAALgAECgEJAQAAAA==.',
Bk='Bkb:BAAALgAECgYJCQAAAA==.',
Ch='Chelsea:BAAALgAFFAIJBAAAAA==.',
Cj='Cjcj:BAAALgADCgEJAQAAAA==.',
Co='Cocoxo:BAAALgAECgYJBgAAAA==.',
Cr='Crypticdly:BAAALgADCgQJBAAAAA==.Crypticfashi:BAAALgADCgQJBAAAAA==.Cryptichunt:BAAALgADCgEJAQAAAA==.Crypticwus:BAAALgADCgYJBgAAAA==.',
Da='Dalvin:BAAALgAECgcJBQAAAA==.',
De='Deving:BAAALgAECgEJAQAAAA==.',
Dk='Dkkdd:BAAALgAECgEJAQAAAA==.',
Do='Doyouhight:BAAALgAECgYJDQAAAA==.',
El='Elaine:BAAALgAECgEJAQAAAA==.',
Ev='Evandon:BAAALgAFFAEJAQAAAA==.',
Fe='Felix:BAAALgADCgYJCwAAAA==.',
Fo='Fornever:BAAALgAECgEJAQAAAA==.',
Gi='Giliya:BAACLgAFFH8GAAIBAAMJ8yIpGwA3AQABAAMJ8yIpGwA3AQAuAAQKfxoAAgEABwlSIpEHACICAAEABwlSIpEHACICAAAA.',
Ho='Hollis:BAAALgAECgMJAwAAAA==.',
Ic='Ichthyophile:BAACLgAFFH8KAAICAAQJLBI4BQBOAQACAAQJLBI4BQBOAQAuAAQKfykAAgIACAmuI5QFAC0DAAIACAmuI5QFAC0DAAAA.',
Im='Imissyou:BAAALgADCgUJBQAAAA==.',
In='Intotheblue:BAAALgAECgYJEAAAAA==.',
Is='Issca:BAAALgAFFAIJAwAAAA==.',
Ka='Kamin:BAABLgAFFH8FAAIDAAMJ1xhkFQDvAAADAAMJ1xhkFQDvAAAAAA==.',
Lo='Loong:BAAALgAECgcJBwAAAA==.Lovezero:BAAALgAECgMJAgAAAA==.',
Ma='Maxium:BAAALgAECgMJAwAAAA==.',
Mi='Mightnare:BAACLgAFFH8UAAIEAAUJHRbGDAC2AQAEAAUJHRbGDAC2AQAuAAQKfyAAAgQACAmIJAERAEIDAAQACAmIJAERAEIDAAAA.',
Mo='Molly:BAAALgADCgYJBgAAAA==.Moreorless:BAAALgAECgEJAgAAAA==.Mornye:BAAALgAECgEJAQAAAA==.Mortis:BAAALgAECgEJAQAAAA==.',
Or='Orianna:BAAALgAECgYJEQAAAA==.',
Pa='Pandaduang:BAAALgAECgQJBgAAAA==.',
Po='Ponytail:BAAALgAECgYJDwAAAA==.',
Ra='Raelag:BAABLgAFFH8JAAIEAAMJch7bIwAoAQAEAAMJch7bIwAoAQABLgAFFAUJDgAEABkeAA==.',
Ro='Rookieever:BAAALgADCgUJBQAAAA==.',
Sd='Sdgbn:BAAALgADCgEJAQAAAA==.',
So='Sonicadi:BAAALgAECgEJAwAAAA==.Soulkeeper:BAABLgAFFH8IAAIDAAMJGyQCCQBLAQADAAMJGyQCCQBLAQAAAA==.',
Td='Tdk:BAABLgAECn8YAAIEAAcJAhxFTgBMAgAEAAcJAhxFTgBMAgAAAA==.',
Tr='Troubler:BAACLgAFFH8NAAIFAAQJEhiqAwBjAQAFAAQJEhiqAwBjAQAuAAQKfyEAAwUABwlOInIYAHYCAAUABwlOInIYAHYCAAYABQmFGJwbABoBAAAA.',
['一刀']='一刀跪:BAAALgAECgEJAQAAAA==.',
['一朵']='一朵花儿:BAAALgAECgEJAQAAAA==.',
['上学']='上学过敏:BAAALgADCgYJBgAAAA==.',
['下次']='下次去哪吃:BAAALgAECgkJCQAAAA==.',
['不二']='不二做:BAAALgAECgUJBQAAAA==.',
['不屈']='不屈不挠之策:BAAALgAFFAQJBAAAAA==.',
['不是']='不是丶哥们:BAACLgAFFH8JAAIBAAIJEB5OOgCoAAABAAIJEB5OOgCoAAAuAAQKfxYAAwEABglZIPdiAMsBAAEABglZIPdiAMsBAAcAAwmpDC04AIEAAAAA.',
['不灭']='不灭月华:BAABLgAECn8YAAIIAAkJmRlJDgCwAgAIAAkJmRlJDgCwAgAAAA==.',
['东方']='东方深秘录:BAAALgAECgEJAQAAAA==.',
['丨无']='丨无畏丨:BAAALgAECgEJAQAAAA==.',
['丨萨']='丨萨拉菲娜丨:BAAALgAECgUJBQAAAA==.',
['丶头']='丶头上小犄角:BAAALgAECgQJBAAAAA==.',
['丶惊']='丶惊蛰:BAAALgAFFAIJAgAAAA==.',
['丶玩']='丶玩命狂龙:BAAALgAECgMJAwAAAA==.',
['丹妮']='丹妮莉斯:BAAALgAECgEJAQAAAA==.',
['二善']='二善人:BAAALgAECgEJAQAAAA==.',
['五月']='五月丶飞华:BAAALgAECgkJBwABLgAFFAYJEAAFAPgfAA==.五月五号:BAAALgADCgQJBAAAAA==.',
['五条']='五条悟:BAAALgADCgEJAQABLgAECgQJBgAJAAAAAA==.',
['亡者']='亡者领域:BAAALgAECgQJCAAAAA==.',
['亮晶']='亮晶晶天上星:BAABLgAECn8aAAIKAAcJhxtNCgDfAQAKAAcJhxtNCgDfAQAAAA==.',
['仰望']='仰望星空:BAAALgAECgEJAQAAAA==.',
['伊芙']='伊芙利特噬灵:BAAALgAECgQJBgAAAA==.',
['伊蕾']='伊蕾娜:BAABLgAFFH8IAAILAAQJWiVfAwC8AQALAAQJWiVfAwC8AQABLgAFFAUJDgALAKMmAA==.',
['余琦']='余琦:BAACLgAFFH8MAAILAAMJfSZ8AwBVAQALAAMJfSZ8AwBVAQAuAAQKfxoAAgsACAmmJVsEAF4DAAsACAmmJVsEAF4DAAAA.',
['你们']='你们的星痕哥:BAABLgAFFH8GAAIMAAMJ6Q73DQD1AAAMAAMJ6Q73DQD1AAAAAA==.',
['使个']='使个锤子:BAAALgADCgUJBQAAAA==.',
['信仰']='信仰圣光不:BAAALgAECgYJAQAAAA==.信仰蜜饯:BAAALgAECgYJBwAAAA==.',
['偶尔']='偶尔:BAAALgAECgEJAQAAAA==.',
['偶然']='偶然的魅惑:BAAALgAECgYJCgAAAA==.',
['先生']='先生丶不行:BAAALgAECgcJCAAAAA==.',
['光熙']='光熙:BAAALgADCgEJAQAAAA==.',
['光鑄']='光鑄戰士:BAAALgAECgEJAgAAAA==.',
['克洛']='克洛斯丶:BAAALgAECgkJEgAAAA==.',
['克落']='克落落:BAAALgAECgQJBgAAAA==.',
['全能']='全能型迅捷咕:BAAALgAECgUJCAAAAA==.',
['兰生']='兰生幽谷:BAAALgAECgcJBwAAAA==.',
['其实']='其实我是英台:BAAALgAECgQJBQAAAA==.',
['再来']='再来我就冰箱:BAAALgAECgYJBgAAAA==.',
['冬瓜']='冬瓜骑士:BAAALgAECgcJCAAAAA==.',
['冰河']='冰河:BAAALgAFFAIJAwAAAA==.',
['冷泡']='冷泡丶帕帕尤:BAAALgAECgQJBgAAAA==.',
['加藤']='加藤惠:BAAALgAECgkJCQAAAA==.',
['勇敢']='勇敢大牛牛:BAAALgADCgUJBQABLgAECgQJBgAJAAAAAA==.',
['勇猛']='勇猛战:BAAALgAECgEJAQAAAA==.',
['十八']='十八闲客:BAAALgAECgYJBwAAAA==.',
['十里']='十里坡战神:BAAALgAFFAIJAgAAAA==.',
['卖核']='卖核弹的圆酱:BAAALgAECgEJAQAAAA==.',
['博徒']='博徒:BAAALgADCgEJAQAAAA==.',
['卟高']='卟高兴:BAAALgAFFAIJAgAAAA==.',
['卡丽']='卡丽灬湮灭者:BAAALgAECgEJAQAAAA==.',
['卡修']='卡修斯:BAAALgADCgIJAgAAAA==.',
['卡西']='卡西米亚:BAABLgAFFH8FAAMGAAMJqxIRBAACAQAGAAMJwgoRBAACAQANAAIJQxdNGwCqAAAAAA==.',
['危乎']='危乎高哉:BAAALgAECgQJBAAAAA==.',
['卷毛']='卷毛猎手:BAAALgAECgEJAQAAAA==.',
['卷积']='卷积核:BAAALgAECgkJCQAAAA==.',
['双马']='双马尾咕咕酱:BAAALgAECgMJAwAAAA==.',
['古尔']='古尔胆:BAAALgAECgQJBgAAAA==.',
['可爱']='可爱七仔:BAAALgAECgIJAQAAAA==.可爱的老子:BAAALgAECgQJBAAAAA==.',
['叶塞']='叶塞丽冰瞳:BAAALgAECgQJBAAAAA==.',
['叹息']='叹息之盾:BAAALgAECgQJBAAAAA==.',
['吃竹']='吃竹子:BAAALgAECgEJAQAAAA==.',
['吉豆']='吉豆咕咕:BAAALgAECgYJCAAAAA==.',
['同一']='同一种调调:BAAALgAECgEJAQAAAA==.',
['吐刀']='吐刀乐:BAAALgAECgUJBQAAAA==.',
['吾诺']='吾诺:BAAALgAECgEJAQAAAA==.',
['咪姆']='咪姆:BAAALgAECggJDAAAAA==.',
['咬人']='咬人怪兽:BAACLgAFFH8KAAMOAAQJGQkbDAAnAQAOAAQJGQkbDAAnAQACAAIJHAKfEgB3AAAuAAQKfyEAAw4ABwl5FYUVAPIBAA4ABwl5FYUVAPIBAAIABwnZE5cfAMUBAAAA.',
['哎呀']='哎呀啊呀:BAAALgAFFAEJAQAAAA==.',
['哦嗨']='哦嗨哟:BAAALgADCgYJCAAAAA==.',
['啊哒']='啊哒哒霍呀:BAAALgAFFAMJAwAAAA==.',
['嘿奴']='嘿奴来了:BAAALgAECgQJBAAAAA==.',
['四季']='四季夜姬:BAAALgADCgMJAwAAAA==.',
['团长']='团长你缺德吗:BAACLgAFFH8LAAIKAAQJOSJUBACaAQAKAAQJOSJUBACaAQAuAAQKfxsAAwoABwnCI0gbAGECAAoABwnCI0gbAGECAAsABgnjF8I4AFUBAAAA.',
['国服']='国服第一可爱:BAAALgAECgMJAwAAAA==.',
['圆圆']='圆圆的冬瓜:BAAALgAECgQJBAAAAA==.',
['土老']='土老帽:BAAALgAFFAEJAQAAAA==.',
['土行']='土行者:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光小浪蹄:BAAALgADCgEJAQAAAA==.',
['在宇']='在宇宙中歌唱:BAAALgAECgYJCwAAAA==.',
['塔丽']='塔丽娜:BAAALgADCgUJBQAAAA==.',
['墨杜']='墨杜萨丶:BAAALgAFFAEJAQAAAA==.',
['墨澜']='墨澜奎茵:BAAALgAECgMJAwAAAA==.墨澜邪魅:BAAALgAECgMJAwAAAA==.',
['士气']='士气高扬之策:BAABLgAFFH8KAAIPAAQJ4yN9AgCsAQAPAAQJ4yN9AgCsAQAAAA==.',
['夏侯']='夏侯风:BAAALgADCgcJBwAAAA==.',
['多多']='多多妈:BAAALgAECgEJAQAAAA==.',
['多洛']='多洛米蒂:BAAALgADCgUJBQAAAA==.',
['多美']='多美多吉亚:BAAALgAECgUJBQAAAA==.',
['大劈']='大劈叉:BAAALgAECgcJBwAAAA==.',
['大探']='大探险者:BAAALgAECgQJBQAAAA==.',
['天空']='天空是蓝色的:BAAALgADCgUJBQAAAA==.',
['奈亚']='奈亚拉托提普:BAAALgAECgcJDwAAAA==.',
['奈何']='奈何花落:BAAALgAECgEJAgAAAA==.奈何花落去:BAAALgADCgIJAgAAAA==.',
['奥蕾']='奥蕾莉烬羽:BAAALgAECgEJAQAAAA==.',
['好的']='好的好的好的:BAAALgAECgYJDwAAAA==.',
['妲壆']='妲壆笙:BAABLgAFFH8HAAIDAAIJYg2IIQCjAAADAAIJYg2IIQCjAAAAAA==.',
['孙一']='孙一诺的基友:BAAALgAFFAMJBAAAAA==.孙一诺的密友:BAAALgAECgQJBAAAAA==.',
['宝贝']='宝贝你来呀:BAAALgAECgEJAQAAAA==.',
['寂耳']='寂耳听心音:BAAALgAECgcJBwABLgAFFAMJDAAQAHIYAA==.',
['小姑']='小姑奶奶呀:BAAALgADCgcJBwAAAA==.',
['小手']='小手超红:BAAALgAECgIJAgAAAA==.',
['小扑']='小扑满:BAAALgAECgUJDQAAAA==.',
['小树']='小树焦圈圈:BAAALgAECgUJBQAAAA==.',
['小桃']='小桃悠:BAAALgAECgIJAgAAAA==.',
['小浪']='小浪蹄子:BAAALgAECgUJBQAAAA==.',
['小灵']='小灵界使者:BAAALgADCgIJAgAAAA==.',
['小葱']='小葱花:BAAALgADCgUJAwAAAA==.',
['小钻']='小钻风来也:BAAALgAECgQJBgAAAA==.',
['尐楠']='尐楠:BAAALgAECgYJCgAAAA==.',
['少年']='少年春衫薄:BAABLgAECn8YAAIIAAkJzhnEDADDAgAIAAkJzhnEDADDAgAAAA==.',
['尘世']='尘世闲游:BAABLgAECn8XAAIIAAkJKhjgEACSAgAIAAkJKhjgEACSAgAAAA==.',
['就会']='就会无敌:BAAALgADCgYJBgAAAA==.',
['屋里']='屋里香:BAAALgAECgcJDQAAAA==.',
['山猪']='山猪山猪:BAAALgADCgMJAwAAAA==.',
['山茶']='山茶荼蘼:BAAALgADCgUJBQAAAA==.',
['岩心']='岩心:BAAALgADCgIJAgAAAA==.',
['巳巳']='巳巳如意:BAAALgAECgYJBgAAAA==.',
['布洛']='布洛芬:BAAALgAECgYJCwAAAA==.',
['帅气']='帅气筱哈哈:BAAALgAFFAEJAQAAAA==.',
['幽影']='幽影骑士:BAAALgAECgIJAwAAAA==.',
['废废']='废废:BAAALgAECgIJAgAAAA==.',
['廖韵']='廖韵格:BAAALgAECgIJAgAAAA==.',
['开摆']='开摆:BAAALgADCggJCQAAAA==.',
['式微']='式微式微:BAAALgAECgYJBgAAAA==.',
['弗栗']='弗栗多:BAAALgAFFAQJBAAAAA==.',
['御龙']='御龙镜中影:BAAALgADCggJDQAAAA==.',
['循循']='循循守月:BAAALgAECgkJEgAAAA==.',
['心妍']='心妍:BAAALgAECgYJBgAAAA==.',
['快乐']='快乐星球:BAABLgAFFH8XAAMRAAcJrwv1AACOAQARAAYJ6gf1AACOAQALAAUJVQ6ZBgB6AQAAAA==.',
['怜星']='怜星儿:BAAALgAECgIJAgAAAA==.',
['恋月']='恋月骑士:BAAALgADCgcJBwAAAA==.',
['意气']='意气轩昂之策:BAABLgAFFH8KAAIPAAQJBSPTBACdAQAPAAQJBSPTBACdAQAAAA==.',
['我会']='我会影遁:BAAALgAECgMJBQAAAA==.',
['我就']='我就念了首诗:BAAALgAFFAEJAQABLgAFFAEJAQAJAAAAAA==.',
['我是']='我是地狱:BAAALgAECgQJBAAAAA==.我是大丑逼:BAAALgAFFAEJAgAAAA==.',
['我的']='我的刀盾:BAAALgAECgcJBgAAAA==.',
['我要']='我要为了部落:BAAALgAECgUJCAAAAA==.',
['戕丶']='戕丶格拉墨:BAABLgAFFH8LAAIRAAQJMhFOAQAgAQARAAQJMhFOAQAgAQABLgAFFAIJBQAHAKkaAA==.',
['把自']='把自己坑了:BAAALgADCgYJBwAAAA==.',
['折耳']='折耳猫:BAAALgAFFAEJAQAAAA==.',
['提瑞']='提瑞斯法之冕:BAAALgAFFAQJBAAAAA==.',
['擎丶']='擎丶格拉墨:BAAALgAFFAIJAwABLgAFFAIJBQAHAKkaAA==.',
['无人']='无人知我乐:BAACLgAFFH8GAAIEAAMJfBxhMwDNAAAEAAMJfBxhMwDNAAAuAAQKfxsAAgQABwmVJdMgAPACAAQABwmVJdMgAPACAAAA.',
['无偿']='无偿捐赠:BAAALgAECgYJCwAAAA==.',
['无声']='无声铃鹿:BAAALgAECgQJAwAAAA==.',
['无害']='无害甜度:BAABLgAECn8ZAAIIAAgJ7BmjEgB+AgAIAAgJ7BmjEgB+AgAAAA==.',
['无敌']='无敌炉石:BAAALgADCgcJBwAAAA==.',
['无炁']='无炁源通:BAAALgADCgMJAwAAAA==.',
['时年']='时年:BAAALgADCgQJBAAAAA==.',
['明镜']='明镜止水:BAAALgAFFAEJAQAAAA==.',
['星夜']='星夜绫:BAAALgAECgEJAQAAAA==.星夜翎:BAAALgAECgEJAQAAAA==.',
['星穹']='星穹:BAAALgAECgUJCAABLgAFFAUJDwASAA4iAA==.',
['星空']='星空丶:BAAALgAFFAMJAwAAAA==.',
['春风']='春风不知归:BAAALgAECgIJAgAAAA==.',
['晟荫']='晟荫:BAAALgADCgYJBgAAAA==.',
['晨曦']='晨曦之烁:BAAALgAECgQJBAAAAA==.',
['晴天']='晴天的小雨:BAABLgAECn8aAAIKAAYJHh9/KAASAgAKAAYJHh9/KAASAgAAAA==.',
['暗夜']='暗夜雨露:BAAALgAECgYJCgAAAA==.',
['暗影']='暗影奔行者:BAAALgAECgQJBAAAAA==.',
['暗德']='暗德:BAAALgAFFAIJAgAAAA==.',
['暮色']='暮色清寒:BAAALgAECgUJBQAAAA==.',
['月下']='月下哈猎:BAAALgADCgUJBQAAAA==.',
['朱敛']='朱敛:BAAALgAECgYJDAAAAA==.',
['杀戮']='杀戮的悲伤:BAAALgADCgEJAQAAAA==.',
['李嘉']='李嘉橙:BAAALgAECgIJAwAAAA==.',
['格拉']='格拉尔丶:BAAALgAECgkJDwAAAA==.',
['格里']='格里菲斯袜:BAAALgAECgUJBQAAAA==.',
['桃悠']='桃悠悠丨樱:BAAALgAFFAEJAgAAAA==.',
['梦幻']='梦幻幽火:BAAALgADCgQJBAAAAA==.',
['梦碎']='梦碎长安:BAAALgAECgcJBwAAAA==.',
['梦风']='梦风:BAAALgADCgcJBwAAAA==.梦风风:BAAALgAECggJBgAAAA==.',
['棕发']='棕发妖精:BAAALgAECgEJAQAAAA==.',
['棱彩']='棱彩器灵:BAAALgAECgYJBgAAAA==.',
['椰子']='椰子冷冻再吃:BAAALgADCgYJBgAAAA==.',
['榴芒']='榴芒德:BAAALgAECgUJBgAAAA==.',
['止心']='止心若水:BAAALgAECgYJCwAAAA==.',
['歪比']='歪比吧卜:BAAALgAECgMJAgAAAA==.',
['死亡']='死亡骑士:BAAALgAECgEJAQAAAA==.',
['毛驴']='毛驴:BAAALgAECgcJBwAAAA==.',
['气人']='气人:BAAALgAECgYJBgAAAA==.',
['永不']='永不言败:BAAALgADCgEJAQAAAA==.',
['没頭']='没頭脑:BAAALgAECgcJEAAAAA==.',
['沦为']='沦为神:BAAALgAFFAEJAgAAAA==.',
['泪落']='泪落天心:BAAALgADCgIJAgAAAA==.',
['泰岚']='泰岚德丨语風:BAAALgAECgQJBQAAAA==.',
['泽莲']='泽莲娜:BAAALgAECgEJAQAAAA==.',
['流云']='流云若水:BAAALgAFFAMJAwAAAA==.',
['浅木']='浅木:BAAALgADCgUJBQABLgAFFAUJDwASAA4iAA==.',
['浅沐']='浅沐:BAABLgAECn8aAAISAAYJtCY1CwCcAgASAAYJtCY1CwCcAgABLgAFFAUJDwASAA4iAA==.',
['浅牧']='浅牧:BAAALgADCgYJCwABLgAFFAUJDwASAA4iAA==.',
['浮云']='浮云散:BAAALgAECgYJCAAAAA==.',
['海澜']='海澜鲸落:BAAALgAECgIJAwABLgAFFAUJDwASAA4iAA==.',
['涅法']='涅法莎灬影狼:BAAALgAECgQJBAAAAA==.',
['淡淡']='淡淡月光:BAAALgAFFAEJAQAAAA==.',
['深谋']='深谋远虑之策:BAABLgAFFH8IAAIPAAQJxCPbAgCdAQAPAAQJxCPbAgCdAQAAAA==.',
['淺沐']='淺沐:BAACLgAFFH8PAAISAAUJDiI2AAD9AQASAAUJDiI2AAD9AQAuAAQKfy8AAhIACAmtJOYBAFcDABIACAmtJOYBAFcDAAAA.',
['清水']='清水徤:BAAALgAECgEJAQAAAA==.',
['清风']='清风拂山岗:BAAALgADCgYJBgAAAA==.',
['清香']='清香乌龙:BAAALgADCgIJAgAAAA==.',
['渲染']='渲染灬千秋雪:BAAALgADCgUJBQAAAA==.',
['湮灭']='湮灭丶:BAAALgAECgYJDwAAAA==.',
['溙兰']='溙兰德枫雨:BAAALgADCgEJAQAAAA==.',
['满月']='满月雕弓:BAAALgADCgcJDAAAAA==.',
['火中']='火中做自己:BAAALgADCgEJAQAAAA==.',
['火光']='火光织恋:BAAALgAECgkJEwAAAA==.',
['灵咪']='灵咪:BAAALgAECgEJAQAAAA==.',
['灵魂']='灵魂尽头:BAAALgADCgcJBwAAAA==.',
['烤我']='烤我就不起名:BAAALgAECgUJBQAAAA==.',
['热带']='热带冰爽:BAAALgAECgYJBgAAAA==.',
['焚寂']='焚寂冥:BAAALgAECgYJCwAAAA==.',
['熊丶']='熊丶布来克:BAAALgADCgEJAQAAAA==.',
['熊力']='熊力大仙:BAAALgAECgUJCAAAAA==.',
['熊孩']='熊孩子蜀黍:BAAALgAECgYJCgAAAA==.',
['熊德']='熊德墨瞳:BAAALgAECgMJAwAAAA==.',
['狂暴']='狂暴的香蕉:BAAALgADCgcJBwAAAA==.',
['狗盛']='狗盛子:BAAALgADCgEJAQABLgAECgMJAwAJAAAAAA==.',
['狠外']='狠外婆:BAAALgAFFAEJAQAAAA==.',
['猎之']='猎之晴空:BAABLgAECn8UAAMFAAYJyBwJXgBOAQAFAAUJAx8JXgBOAQANAAQJ+RZoVgDuAAAAAA==.',
['玄冥']='玄冥酒仙:BAAALgADCgMJAwAAAA==.',
['玄奘']='玄奘大和尚:BAAALgAECgEJAQAAAA==.',
['王子']='王子殿下与喵:BAAALgAECgcJCAAAAA==.',
['玛沙']='玛沙绿意之触:BAAALgAFFAIJBAAAAA==.',
['玛肉']='玛肉刺身:BAAALgAFFAEJAQAAAA==.',
['玻璃']='玻璃花:BAAALgAECgYJEAAAAA==.',
['珂镇']='珂镇恶:BAAALgAECgYJBgAAAA==.',
['田曦']='田曦薇:BAAALgAECgYJBgAAAA==.',
['痕星']='痕星:BAAALgAECgYJBwAAAA==.',
['白七']='白七匹狼:BAAALgAECgcJEwAAAA==.',
['白露']='白露為霜:BAABLgAECn8UAAIKAAcJdSOSBQBHAgAKAAcJdSOSBQBHAgABLgAFFAYJCgATAKULAA==.',
['皓月']='皓月灬薇露:BAAALgAECgcJCQAAAA==.',
['破阵']='破阵:BAABLgAFFH8IAAIIAAMJew56CwDcAAAIAAMJew56CwDcAAAAAA==.',
['神修']='神修:BAAALgAECgEJAQAAAA==.',
['神恩']='神恩警长:BAAALgAECgYJBgAAAA==.',
['神机']='神机营长:BAAALgAECgYJDAAAAA==.',
['神避']='神避:BAAALgAECgYJCgAAAA==.',
['神骑']='神骑帕拉丁:BAAALgAECgcJBwAAAA==.',
['秋小']='秋小妹:BAABLgAFFH8FAAIUAAMJ+BMlCQDoAAAUAAMJ+BMlCQDoAAAAAA==.',
['笠老']='笠老魔:BAAALgAECgIJAgAAAA==.',
['等我']='等我搓个糖:BAAALgAFFAEJAQAAAA==.',
['筱熙']='筱熙:BAABLgAFFH8GAAMVAAIJJgxqFgCQAAAVAAIJJgxqFgCQAAAMAAEJ7ABAJQA6AAAAAA==.',
['箜哉']='箜哉:BAAALgAECgQJBQAAAA==.',
['糖果']='糖果巧克力:BAAALgAECgQJBAAAAA==.',
['糖糖']='糖糖有糖:BAAALgADCgMJAwAAAA==.',
['紫罗']='紫罗兰公主:BAAALgADCgQJBAAAAA==.',
['红心']='红心大橙子:BAAALgAECgYJBgAAAA==.',
['红豆']='红豆树:BAAALgAECgEJAQAAAA==.',
['红颜']='红颜壹笑:BAAALgAFFAEJAQAAAA==.',
['绿七']='绿七匹狼:BAAALgAECgYJCwAAAA==.',
['绿豆']='绿豆芽:BAAALgAECggJBQABLgAECgkJEAAJAAAAAA==.',
['罗萨']='罗萨莱斯:BAAALgAECgkJDwAAAA==.',
['羊村']='羊村村霸:BAAALgAECgEJAQAAAA==.',
['羊羊']='羊羊村村长:BAAALgAECgYJBgAAAA==.',
['美国']='美国的华莱士:BAAALgAFFAEJAQAAAA==.',
['美屡']='美屡猎:BAAALgAECgcJBwABLgAFFAQJBQANAD4PAA==.',
['老许']='老许老了:BAAALgADCgEJAQAAAA==.',
['老马']='老马实图:BAAALgAECgYJCgAAAA==.',
['聖灬']='聖灬青丝:BAAALgAECgEJAwAAAA==.',
['肯瑞']='肯瑞托欧皇:BAAALgAECgcJBgAAAA==.',
['脱兔']='脱兔:BAAALgAECgcJDQAAAA==.',
['至暗']='至暗之战:BAAALgAECgYJEQAAAA==.',
['艾尔']='艾尔希恩:BAAALgADCgEJAQAAAA==.',
['艾瑞']='艾瑞达尔:BAAALgADCgQJBwAAAA==.',
['艾达']='艾达瑞尔:BAAALgAECgEJAQAAAA==.',
['芒果']='芒果颖:BAAALgAECgQJCQAAAA==.',
['芸妹']='芸妹:BAAALgADCgUJBQAAAA==.',
['芸芝']='芸芝:BAAALgAFFAEJAQAAAA==.',
['荆棘']='荆棘行者:BAAALgAECgMJBgAAAA==.',
['草莓']='草莓秋葵脆:BAAALgADCgEJAQAAAA==.',
['莓莓']='莓莓桑内:BAAALgAECgYJBgAAAA==.',
['莫兰']='莫兰娜:BAAALgADCgMJAwAAAA==.',
['莫古']='莫古力:BAAALgAFFAQJBAAAAA==.',
['莱恩']='莱恩那丶:BAAALgAECgkJDgAAAA==.',
['萌新']='萌新猛的萌德:BAAALgADCgQJBAAAAA==.',
['萌萌']='萌萌哒面包师:BAAALgAECgkJDwAAAA==.',
['萌面']='萌面骑士:BAAALgADCgEJAQAAAA==.',
['萨希']='萨希米:BAAALgADCgEJAQAAAA==.',
['蔚蓝']='蔚蓝珊瑚海:BAAALgAECgYJDQAAAA==.',
['蔡萌']='蔡萌萌:BAABLgAFFH8HAAISAAMJDRYVBQDYAAASAAMJDRYVBQDYAAAAAA==.',
['薇洛']='薇洛妮卡:BAAALgADCgYJBgAAAA==.',
['藤上']='藤上风铃:BAAALgAECgQJBAAAAA==.',
['蚱蜢']='蚱蜢:BAAALgAECgQJAwAAAA==.',
['蛇蝎']='蛇蝎美人:BAAALgAECgUJBAAAAA==.',
['蜗牛']='蜗牛在漫步:BAAALgAECgcJDQAAAA==.',
['蝶舞']='蝶舞丶莫相言:BAAALgAECgEJAQAAAA==.',
['血领']='血领主无幽:BAAALgAECgEJAgAAAA==.',
['西瓜']='西瓜皮:BAAALgAECgEJAQAAAA==.',
['谁也']='谁也不知道:BAAALgAECgUJBgAAAA==.',
['谜语']='谜语:BAAALgAECgIJAgAAAA==.',
['豆豆']='豆豆柴:BAABLgAFFH8KAAIPAAQJdSQyAgC5AQAPAAQJdSQyAgC5AQAAAA==.',
['豌豆']='豌豆芽:BAAALgAECgkJEAAAAA==.',
['豪门']='豪门青雅:BAAALgADCgEJAQAAAA==.',
['败家']='败家麽麽:BAAALgAECgYJCgAAAA==.',
['赤箭']='赤箭玖:BAAALgADCgUJBQAAAA==.',
['超级']='超级小飞侠:BAAALgAECgIJAgAAAA==.',
['路明']='路明非参上:BAAALgAECgcJBwAAAA==.',
['踏酒']='踏酒鹤云归:BAABLgAFFH8MAAIQAAMJchj3BgDxAAAQAAMJchj3BgDxAAAAAA==.',
['轻描']='轻描淡写:BAAALgAECgQJCAAAAA==.',
['辞霜']='辞霜生:BAABLgAFFH8IAAIOAAMJFyZWCQBUAQAOAAMJFyZWCQBUAQAAAA==.',
['达馨']='达馨紫李:BAAALgAECgUJCgAAAA==.',
['近战']='近战停手:BAAALgAECgQJBQAAAA==.',
['还是']='还是石头:BAAALgAECgQJBAAAAA==.',
['还能']='还能变身两次:BAAALgADCgkJCgAAAA==.',
['远航']='远航星:BAAALgAECgEJAQAAAA==.',
['追魂']='追魂铁游夏:BAAALgAECgEJAgAAAA==.',
['邻居']='邻居灬老刘:BAAALgAECgYJBwAAAA==.邻居灬老张:BAABLgAFFH8GAAIWAAMJEwqTBQDBAAAWAAMJEwqTBQDBAAAAAA==.邻居灬老苑:BAAALgAFFAEJAQAAAA==.',
['酒酵']='酒酵瑰夏:BAAALgAECgQJBgAAAA==.',
['金属']='金属枪神:BAAALgAECgMJAwAAAA==.',
['鎲丶']='鎲丶格拉墨:BAABLgAFFH8FAAIWAAIJexKwCwCOAAAWAAIJexKwCwCOAAABLgAFFAIJBQAHAKkaAA==.',
['钟灵']='钟灵儿:BAAALgAECgcJBwAAAA==.',
['铁腿']='铁腿水上漂:BAAALgAECgYJBwAAAA==.',
['银山']='银山雀儿:BAABLgAFFH8IAAIPAAQJlh8vBgB/AQAPAAQJlh8vBgB/AQAAAA==.',
['长夜']='长夜梦旅:BAAALgAFFAEJAQABLgAFFAIJBgAXABUVAA==.',
['闪电']='闪电大王:BAAALgAFFAQJBAAAAA==.',
['阿克']='阿克图瑞斯:BAAALgAECgQJBAAAAA==.阿克莱丶:BAAALgAFFAIJAgAAAA==.',
['阿兰']='阿兰娜:BAAALgAECgcJDAAAAA==.',
['阿尔']='阿尔利亚:BAAALgAECgEJAwAAAA==.',
['阿沦']='阿沦:BAAALgADCgEJAQAAAA==.',
['阿福']='阿福:BAAALgADCgEJAQAAAA==.',
['陆行']='陆行鸟:BAABLgAFFH8GAAIPAAQJKCAaBQCXAQAPAAQJKCAaBQCXAQAAAA==.',
['雨璐']='雨璐:BAABLgAECn8VAAIBAAgJ2wqldwCVAQABAAgJ2wqldwCVAQAAAA==.',
['雪名']='雪名:BAAALgADCgEJAQAAAA==.',
['雪域']='雪域白:BAAALgADCgEJAQAAAA==.',
['雪霁']='雪霁梅香:BAABLgAECn8ZAAIIAAkJNRrJCwDRAgAIAAkJNRrJCwDRAgAAAA==.',
['雷无']='雷无双:BAAALgAECgEJAQAAAA==.',
['雷殇']='雷殇魂:BAABLgAFFH8LAAIYAAQJ0xjsCwAkAQAYAAQJ0xjsCwAkAQAAAA==.',
['雾隐']='雾隐千山:BAAALgAECgEJAQAAAA==.',
['霸丶']='霸丶格拉墨:BAACLgAFFH8IAAIIAAMJmRcvEQD0AAAIAAMJmRcvEQD0AAAuAAQKfxoAAwgABwnbHC4XAE0CAAgABwnbHC4XAE0CABAAAQnNCVlsACoAAAEuAAUUAgkFAAcAqRoA.',
['青柠']='青柠薄荷冰:BAAALgAECgUJBwAAAA==.青柠薄荷糖:BAAALgAECgYJBgAAAA==.',
['靓眉']='靓眉眉:BAAALgAECgYJBgAAAA==.',
['顺昌']='顺昌逆亡:BAAALgAECgYJCgAAAA==.',
['風雪']='風雪夜歸人:BAACLgAFFH8JAAIDAAQJqgYkGQAoAQADAAQJqgYkGQAoAQAuAAQKfyEAAwMABwnKFkZhAKYBAAMABgkJFUZhAKYBABkAAwlMCks8AMMAAAAA.',
['风已']='风已逝去:BAABLgAECn8WAAMDAAcJKR9NLQBYAgADAAcJph5NLQBYAgAZAAIJBh2UPwC2AAAAAA==.',
['风怒']='风怒导灵者:BAABLgAECn8dAAIUAAgJCRnOCQDNAQAUAAgJCRnOCQDNAQAAAA==.',
['风林']='风林火山:BAAALgADCgQJBAAAAA==.',
['风梦']='风梦尘:BAAALgAECgIJAwAAAA==.',
['飘雨']='飘雨追风:BAAALgAECgEJAQAAAA==.',
['飞梦']='飞梦小枫猪:BAAALgAECgIJAwAAAA==.',
['饿饿']='饿饿饭饭:BAAALgAECgcJBwAAAA==.',
['馨风']='馨风之舞:BAAALgAECgIJAwAAAA==.',
['魂锁']='魂锁典狱长:BAAALgAECgEJAQAAAA==.',
['鲜血']='鲜血之忆:BAAALgAECgEJAgAAAA==.',
['黎明']='黎明之刃:BAAALgAECgcJCAAAAA==.',
['黑光']='黑光:BAAALgAECgcJBwAAAA==.',
['黑暗']='黑暗御風者:BAAALgAFFAIJAwAAAA==.',
['默而']='默而识之:BAABLgAFFH8FAAILAAIJLhd9CgCrAAALAAIJLhd9CgCrAAAAAA==.',
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
