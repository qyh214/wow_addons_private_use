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

local lookup = {'DeathKnight-Unholy','Monk-Windwalker','Warrior-Protection','Warrior-Fury','Hunter-BeastMastery','DemonHunter-Havoc','Mage-Frost','Shaman-Restoration','Priest-Discipline','Priest-Holy','Evoker-Devastation','Evoker-Augmentation','Hunter-Marksmanship','Unknown-Unknown','DemonHunter-Devourer','Paladin-Retribution','Hunter-Survival','Priest-Shadow','Evoker-Preservation','Warrior-Arms','Monk-Brewmaster','Mage-Arcane','Warlock-Demonology',}
local provider = {region='CN',realm='苏拉玛',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Aloong:BAABLgAFFH8IAAIBAAQJOR+CAgCOAQABAAQJOR+CAgCOAQAAAA==.',
Bl='Blackrocks:BAAALgAECgEJAQAAAA==.',
Ca='Catherine:BAAALgAECgEJAQAAAA==.',
Co='Columbina:BAAALgAFFAEJAQAAAA==.',
Ge='Geburah:BAAALgAECgQJBAAAAA==.',
He='Henryh:BAAALgAECgYJDAAAAA==.',
Hi='Higher:BAAALgAECgEJAQAAAA==.',
Kl='Klolinde:BAAALgAFFAIJAgAAAA==.',
Le='Leveilleur:BAAALgADCgcJBwAAAA==.',
Lo='Loongovo:BAACLgAFFH8NAAICAAQJMBP9AgAjAQACAAQJMBP9AgAjAQAuAAQKfxcAAgIACAntGV8SAGMCAAIACAntGV8SAGMCAAAA.',
Mo='Monochrome:BAACLgAFFH8HAAIDAAMJixxUAwAUAQADAAMJixxUAwAUAQAuAAQKfyAAAwMACAm9GhEKAHQCAAMACAm9GhEKAHQCAAQABAkLHsRmABgBAAAA.',
My='Mypreclous:BAABLgAFFH8GAAIFAAIJ5xn5EwCzAAAFAAIJ5xn5EwCzAAAAAA==.',
Oa='Oak:BAAALgADCgYJDQAAAA==.',
Pl='Playerbcfkun:BAAALgADCgIJAgAAAA==.Playernegrkw:BAAALgADCgYJBgAAAA==.',
Rd='Rdher:BAAALgAFFAUJBAAAAA==.Rdhqi:BAAALgAFFAQJBAAAAA==.Rdhsan:BAABLgAFFH8FAAIGAAUJUhqnAAB+AQAGAAUJUhqnAAB+AQAAAA==.Rdhsi:BAAALgAFFAUJBAAAAA==.',
Ro='Rovaniemi:BAAALgAECgYJEgAAAA==.',
Sc='Scowmn:BAAALgAECgYJDAAAAA==.',
Sw='Swindy:BAAALgAECgEJAQAAAA==.',
Te='Terraria:BAAALgADCgcJCwAAAA==.',
Vo='Voidthar:BAAALgAECgYJEAAAAA==.',
Wr='Wrath:BAAALgADCgQJBAAAAA==.',
Xz='Xzfcasf:BAABLgAFFH8GAAIHAAYJ3RRUBAAqAgAHAAYJ3RRUBAAqAgAAAA==.',
['一何']='一何事:BAABLgAECn8YAAIBAAkJhyJ+BACMAwABAAkJhyJ+BACMAwABLgAFFAQJBgABAL0YAA==.',
['一刀']='一刀飞:BAAALgAFFAEJAQAAAA==.',
['一样']='一样的烂摊子:BAAALgAECgYJEQAAAA==.',
['七宝']='七宝:BAAALgAECgYJCwAAAA==.',
['上就']='上就是干:BAAALgAECgEJAQAAAA==.',
['上山']='上山猎:BAAALgAECgYJDwAAAA==.',
['不一']='不一样的月光:BAAALgAFFAQJBAAAAA==.',
['不知']='不知红心丶:BAAALgAFFAEJAQAAAA==.',
['专业']='专业:BAABLgAFFH8HAAIBAAMJvBamKAD2AAABAAMJvBamKAD2AAAAAA==.',
['丨丧']='丨丧乄彪丨:BAAALgAECgkJCQAAAA==.',
['丨躯']='丨躯不坏丨:BAAALgAECgEJAQAAAA==.',
['丨长']='丨长琴无焰丨:BAAALgAECgEJAQAAAA==.',
['丶老']='丶老叁丨:BAAALgAFFAQJBAAAAA==.',
['丶阿']='丶阿猪同学:BAAALgAECgcJBwAAAA==.',
['乄德']='乄德兼三皇灬:BAAALgAECgYJBgAAAA==.',
['乄鲨']='乄鲨鱼辣椒乄:BAAALgAFFAQJBAAAAA==.',
['乌梅']='乌梅汁:BAAALgAECgEJAQAAAA==.',
['九月']='九月肃霜:BAAALgAECgYJBgAAAA==.',
['云梦']='云梦使者:BAAALgADCgcJBwAAAA==.',
['五道']='五道杠丶抓根:BAAALgAECgQJBAAAAA==.',
['亚妮']='亚妮拉丝:BAAALgAECgYJDAABLgAFFAMJBgAIAHIXAA==.',
['人生']='人生有几何:BAABLgAFFH8LAAIJAAYJTBrFAQAYAgAJAAYJTBrFAQAYAgAAAA==.',
['伤心']='伤心离别:BAAALgAECgQJBQAAAA==.',
['佰八']='佰八萬花開:BAABLgAECn8XAAIKAAcJ2CBLDACOAgAKAAcJ2CBLDACOAgAAAA==.',
['保安']='保安队长:BAAALgAECgEJAQAAAA==.',
['光明']='光明卫士:BAAALgADCgEJAQAAAA==.',
['六两']='六两银元:BAAALgAECgEJAgAAAA==.',
['冰洛']='冰洛洛:BAAALgAFFAUJAgAAAA==.',
['凉风']='凉风有幸:BAABLgAFFH8LAAIDAAMJcxwyAwAYAQADAAMJcxwyAwAYAQAAAA==.',
['华佗']='华佗:BAAALgADCgYJCwAAAA==.',
['卡布']='卡布丶:BAAALgAECgUJBgAAAA==.',
['卡西']='卡西奥佩娅:BAEBLgAFFH8RAAMLAAUJYhrkAADHAQALAAUJLBnkAADHAQAMAAQJ6A+8BQBHAQAAAA==.',
['可达']='可达鸭:BAAALgAFFAEJAgAAAA==.',
['后宫']='后宫王杜文博:BAAALgAECgYJBgAAAA==.',
['呼噜']='呼噜发:BAAALgAECgYJCAAAAA==.',
['咕咕']='咕咕嘎嘎:BAAALgADCgcJBwAAAA==.咕咕满天飞:BAAALgAECgMJAwAAAA==.',
['哈祭']='哈祭米:BAAALgAECgYJBgAAAA==.',
['嚒嚒']='嚒嚒茶:BAAALgADCgYJCgAAAA==.',
['圣骑']='圣骑牛牛:BAAALgAECgQJBAAAAA==.',
['塔塔']='塔塔撸:BAAALgAECgYJCQAAAA==.',
['大姨']='大姨妈耀眼红:BAAALgAFFAEJAQAAAA==.',
['大威']='大威天公将军:BAAALgAECgUJBQAAAA==.',
['天狐']='天狐玉初:BAAALgAECgYJDQAAAA==.天狐蒂亚:BAAALgAECgYJCwAAAA==.',
['天空']='天空中的飞鸟:BAAALgAECgcJCAAAAA==.',
['天馬']='天馬座的幻想:BAAALgAFFAEJAQAAAA==.',
['她永']='她永远是第一:BAAALgAECgEJAQAAAA==.',
['好老']='好老的大二:BAAALgAECgEJAQAAAA==.',
['好运']='好运自然来:BAAALgAECgUJCAAAAA==.',
['安娜']='安娜喵丶:BAAALgAECgcJBwAAAA==.',
['寂寞']='寂寞的尼克:BAAALgAECgYJBgAAAA==.',
['小步']='小步兵:BAAALgAECgMJAwAAAA==.',
['小火']='小火山:BAABLgAECn8ZAAIGAAcJyhZkHQDUAQAGAAcJyhZkHQDUAQAAAA==.',
['小猫']='小猫咪大笨蛋:BAAALgAECgYJCQAAAA==.',
['尐样']='尐样丶傻馒:BAAALgAECgcJBwAAAA==.',
['就是']='就是个骑士:BAAALgAECgcJBwAAAA==.',
['山雨']='山雨欲来也:BAAALgAECgYJBgAAAA==.',
['左右']='左右:BAAALgAECgYJBgAAAA==.',
['巨帅']='巨帅的熊猫人:BAAALgAECgEJAQAAAA==.',
['干锅']='干锅花菜:BAAALgAECgUJCAAAAA==.',
['幻歌']='幻歌:BAAALgAECgYJDAAAAA==.',
['德德']='德德不休:BAAALgAECgEJAQAAAA==.',
['忘了']='忘了哭:BAAALgADCgEJAQAAAA==.',
['恩赐']='恩赐解脱:BAAALgADCgcJBwAAAA==.',
['恶独']='恶独拾光:BAAALgADCgEJAQAAAA==.',
['悟空']='悟空丶战骑:BAAALgADCgUJBQAAAA==.',
['愚者']='愚者的片尾:BAAALgAFFAQJBAAAAA==.',
['我是']='我是乐子酒仙:BAAALgAFFAQJBAAAAA==.',
['战之']='战之凌:BAAALgAECgQJBAAAAA==.战之綾:BAAALgAECgYJDAAAAA==.战之翎:BAAALgADCgYJBgAAAA==.',
['戳你']='戳你膝盖:BAAALgAECgEJAQAAAA==.',
['拉到']='拉到就别想跑:BAAALgAECgQJBAAAAA==.',
['拉喜']='拉喜奥:BAAALgADCgUJBQAAAA==.',
['拉阿']='拉阿拉蕾:BAAALgADCgUJBQAAAA==.',
['拔地']='拔地而起:BAAALgAFFAEJAgAAAA==.',
['救救']='救救酒仙吧:BAAALgAECgUJBAAAAA==.',
['星之']='星之矢:BAAALgADCgEJAQAAAA==.',
['星弦']='星弦伊莉雅:BAAALgAECgcJBwAAAA==.',
['最后']='最后的轻语丶:BAAALgAECggJCAAAAA==.',
['最烈']='最烈的酒:BAABLgAFFH8FAAMNAAUJgROtCwBfAQANAAQJ0xKtCwBfAQAFAAEJjhXAIABfAAAAAA==.',
['未成']='未成年保护法:BAABLgAECn8WAAIHAAcJtQK/HwHAAAAHAAcJtQK/HwHAAAABLgAFFAIJBAAOAAAAAA==.',
['末丶']='末丶洛:BAABLgAECn8WAAMPAAkJsxbiIACMAgAPAAkJyhXiIACMAgAGAAYJ3hrnJACXAQABLgAFFAUJDgAQAE4mAA==.',
['杉杉']='杉杉:BAABLgAECn8XAAQFAAcJGSDZEgCgAgAFAAcJGSDZEgCgAgARAAQJWAQDJACsAAANAAEJBAEdmwAVAAAAAA==.',
['李剑']='李剑诗:BAAALgAFFAIJAgAAAA==.',
['村野']='村野阿蛮:BAAALgAECgEJAQAAAA==.',
['柒丶']='柒丶丨:BAAALgAECgUJBQAAAA==.',
['棂龙']='棂龙精酿:BAACLgAFFH8OAAQJAAQJAiCZBQCMAQAJAAQJAiCZBQCMAQAKAAIJXh+KCgC8AAASAAEJShKpDQBPAAAuAAQKfxsABAkABwlAJGUGAOICAAkABwlAJGUGAOICABIABQl0GW43ADIBAAoAAgl3HQBnAJEAAAAA.',
['椎名']='椎名立希本人:BAAALgADCgQJBAAAAA==.',
['欧阳']='欧阳震华:BAAALgAECggJDwAAAA==.',
['正在']='正在加载目标:BAAALgAECgEJAQAAAA==.',
['死鬼']='死鬼骑士:BAAALgAFFAYJBAAAAA==.',
['毛毛']='毛毛怪:BAAALgAFFAMJAwAAAA==.',
['永野']='永野芽郁:BAAALgAECgYJCAAAAA==.',
['泡芙']='泡芙冬夜凛:BAAALgAECgQJBQAAAA==.',
['洗洗']='洗洗日吧:BAAALgADCgUJBQAAAA==.',
['浅色']='浅色粉笔:BAAALgAFFAIJBAAAAA==.',
['淡定']='淡定乌禅:BAAALgAECgIJAgAAAA==.',
['深邃']='深邃流年:BAAALgAECgQJBAAAAA==.',
['潲水']='潲水潴丶:BAAALgAECgcJBwAAAA==.',
['灬道']='灬道不知:BAAALgADCgIJAgAAAA==.',
['灬青']='灬青丨歌灬:BAAALgAFFAEJAQAAAA==.',
['灰常']='灰常硬的葱总:BAAALgAECgMJBAAAAA==.',
['牛不']='牛不忙:BAAALgAECgIJAgAAAA==.',
['牧龙']='牧龙尊:BAAALgAFFAEJAQAAAA==.',
['狂人']='狂人老张:BAAALgAECgkJDQAAAA==.',
['狂怒']='狂怒丨之风:BAAALgADCgYJBgAAAA==.',
['狐咧']='狐咧猎:BAAALgADCgIJAgAAAA==.',
['猫之']='猫之呼吸:BAAALgAECgYJDAAAAA==.',
['猫猫']='猫猫头大魔王:BAAALgADCgEJAQAAAA==.',
['玛格']='玛格努丝:BAAALgAECgEJAQAAAA==.',
['田曦']='田曦薇:BAAALgAECgcJEgAAAA==.',
['电竞']='电竞小龙人:BAABLgAECn8eAAQMAAYJhg9xLwBJAQAMAAYJ+w5xLwBJAQATAAYJjQ3uJwA0AQALAAQJIgsjKwDEAAAAAA==.',
['番茄']='番茄骑士:BAACLgAFFH8UAAMUAAUJ+h31AAClAQAUAAUJzBj1AAClAQAEAAQJqhuSCABmAQAuAAQKfxUAAgQABwmVIhgcAGwCAAQABwmVIhgcAGwCAAAA.',
['知道']='知道丶不:BAAALgADCgYJBgAAAA==.',
['石玉']='石玉蝴蝶:BAAALgAECgIJAwAAAA==.',
['砂锅']='砂锅丨方便面:BAAALgAECgcJDgAAAA==.',
['碧玉']='碧玉妆成:BAAALgAECgcJBwAAAA==.',
['祖国']='祖国中年花朵:BAAALgAECgYJDAAAAA==.',
['神丶']='神丶白泽:BAABLgAFFH8FAAIHAAIJ6BorNADHAAAHAAIJ6BorNADHAAAAAA==.',
['秽浊']='秽浊:BAAALgADCgUJBQAAAA==.',
['第二']='第二根草:BAAALgAECgkJCwAAAA==.',
['织雾']='织雾行云:BAABLgAECn8UAAMVAAgJmh0kDwCmAgAVAAgJmh0kDwCmAgACAAUJfA1KRwD4AAAAAA==.',
['给你']='给你打出汁儿:BAAALgADCgYJBgAAAA==.',
['罂丶']='罂丶粟花奶:BAAALgAFFAEJAQAAAA==.',
['羽调']='羽调:BAAALgAECgkJCQAAAA==.',
['老熊']='老熊猫二号:BAAALgAECgEJAQAAAA==.',
['胖虎']='胖虎灬:BAAALgAECgIJAwAAAA==.',
['胖达']='胖达快跑:BAAALgAECgQJBQAAAA==.',
['胡开']='胡开心:BAABLgAECn8bAAIQAAcJRCKTIQCkAgAQAAcJRCKTIQCkAgAAAA==.',
['艾姬']='艾姬多娜:BAAALgADCgEJAQAAAA==.',
['芝芝']='芝芝桃桃:BAACLgAFFH8HAAMHAAQJ+yAPEACVAQAHAAQJ+yAPEACVAQAWAAEJ7hlkAQBYAAAuAAQKfxsAAxYABwkiIv8BAJACAAcABwnDHLI2AJkCABYABglzJv8BAJACAAAA.',
['茉莉']='茉莉的忧伤:BAABLgAECn8WAAIXAAkJViBrCQA0AwAXAAkJViBrCQA0AwAAAA==.',
['菩提']='菩提教兽:BAAALgAECgMJAwAAAA==.',
['萨灬']='萨灬老卡:BAAALgAECgkJDAAAAA==.',
['蓝牙']='蓝牙耳机:BAAALgAECgEJAgAAAA==.',
['蔡依']='蔡依林:BAAALgAECgYJDAAAAA==.',
['蔻幺']='蔻幺兔:BAAALgAECgYJBgAAAA==.',
['血法']='血法魔魂:BAAALgAECgEJAgAAAA==.',
['衫矶']='衫矶:BAAALgAECgIJAgAAAA==.',
['被遗']='被遗忘的流年:BAAALgAECggJDAAAAA==.',
['诗杰']='诗杰师姐:BAAALgAECgYJBgAAAA==.',
['超丶']='超丶电动丶棒:BAAALgAECgcJDgAAAA==.',
['跪子']='跪子斗:BAAALgAECgQJAwAAAA==.',
['转转']='转转腿:BAACLgAFFH8NAAIVAAQJGhaqCgAyAQAVAAQJGhaqCgAyAQAuAAQKfxQAAhUABgl1HFooAMQBABUABgl1HFooAMQBAAAA.',
['这个']='这个牙有点大:BAAALgADCgMJAwAAAA==.',
['迪门']='迪门修斯:BAAALgAECgkJCQAAAA==.',
['那夜']='那夜雪吹寒:BAAALgAECgYJDAAAAA==.',
['酸草']='酸草莓:BAAALgAECgkJEgAAAA==.',
['阿凡']='阿凡达雷首:BAAALgADCgUJBQAAAA==.',
['阿坎']='阿坎多尔:BAAALgADCgMJAwAAAA==.',
['阿坤']='阿坤哥小悦:BAABLgAECn8VAAMUAAYJzByFCwDpAQAUAAYJzByFCwDpAQAEAAEJpRdJoQA/AAAAAA==.',
['阿拉']='阿拉菲洛:BAAALgAECgEJAgAAAA==.',
['阿格']='阿格莱雅:BAAALgADCgEJAQAAAA==.',
['随时']='随时狩猎:BAAALgAECgYJAgAAAA==.',
['雨音']='雨音霜:BAAALgAECgcJBwAAAA==.',
['雷首']='雷首啸天:BAAALgAECgQJAQAAAA==.',
['青花']='青花椒:BAAALgADCgMJAwAAAA==.',
['风月']='风月同天:BAAALgAECgYJBgAAAA==.',
['飞镰']='飞镰:BAAALgADCgIJAgAAAA==.',
['马东']='马东锡:BAABLgAFFH8JAAIVAAUJMQ8KBgAxAQAVAAUJMQ8KBgAxAQAAAA==.',
['马尔']='马尔扎哈:BAAALgAECgcJBwAAAA==.',
['骑士']='骑士十三:BAAALgADCgUJBQAAAA==.',
['骑猪']='骑猪过马路:BAAALgADCgEJAQAAAA==.',
['鬼魅']='鬼魅无痕:BAAALgADCgMJAwAAAA==.',
['鲑鱼']='鲑鱼大帝:BAAALgAECgEJAQAAAA==.',
['黏黏']='黏黏鱼小朋友:BAAALgAECgcJBgAAAA==.',
['黑皮']='黑皮体育生阿:BAAALgAECgQJBAAAAA==.',
['龍雀']='龍雀:BAAALgAECgMJAwAAAA==.',
['龙虾']='龙虾之宠:BAAALgADCgYJBgAAAA==.龙虾之辉:BAAALgAECgcJDAAAAA==.',
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
