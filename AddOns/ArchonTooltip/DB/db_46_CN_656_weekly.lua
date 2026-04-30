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

local lookup = {'DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Druid-Restoration','DemonHunter-Devourer','Unknown-Unknown','Druid-Guardian','Druid-Balance','Shaman-Elemental','Shaman-Enhancement','Shaman-Restoration','Paladin-Holy','Monk-Windwalker','Priest-Shadow','Priest-Discipline','DeathKnight-Frost','DeathKnight-Blood','Mage-Frost','Evoker-Devastation','Evoker-Augmentation','Hunter-Marksmanship','Priest-Holy','Monk-Brewmaster','Warrior-Fury','Paladin-Retribution','Paladin-Protection','Warrior-Protection','Warrior-Arms','Warlock-Affliction','Evoker-Preservation','Monk-Mistweaver','Hunter-BeastMastery','Hunter-Survival',}
local provider = {region='CN',realm='密林游侠',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Angryapple:BAAALgADCgEJAQAAAA==.',
Ar='Arcadias:BAAALgAFFAEJAQAAAA==.',
Ba='Baldur:BAAALgADCgUJBgAAAA==.Bayoneta:BAAALgAECgYJCgAAAA==.',
Bo='Bomber:BAAALgAFFAEJAQABLgAFFAUJBQABAFUTAA==.',
Co='Cokezero:BAAALgAECgQJBAAAAA==.Convers:BAAALgAECgYJAwAAAA==.',
De='Demonpang:BAAALgAECgMJBAAAAA==.',
Dm='Dm:BAACLgAFFH8RAAICAAUJmSC7CgCGAQACAAUJmSC7CgCGAQAuAAQKfxUAAwIABwkjJQwVANcCAAIABwkjJQwVANcCAAMAAQlDDfJvADYAAAAA.',
Do='Doloress:BAEALgAECgQJCAAAAA==.',
En='Endurance:BAAALgAECgcJDAAAAA==.',
Gd='Gd:BAABLgAFFH8GAAIEAAMJQBv3DQAIAQAEAAMJQBv3DQAIAQAAAA==.',
Gi='Giselle:BAAALgAECgcJDAAAAA==.',
Ho='Holytroll:BAAALgAECgkJCgAAAA==.',
Ib='Ibuki:BAAALgADCgIJAgAAAA==.',
Je='Jeannedarc:BAAALgADCgUJBQAAAA==.',
Kn='Knife:BAABLgAFFH8HAAIFAAMJsxR5DAD6AAAFAAMJsxR5DAD6AAAAAA==.',
Ku='Kuangtu:BAAALgAECgQJCAAAAA==.',
Ky='Kyo:BAEALgAECgEJAQABLgAECgQJCAAGAAAAAA==.',
Li='Lighter:BAABLgAECn8UAAMHAAcJ8BaOCwDWAQAHAAcJ8BaOCwDWAQAIAAMJ9AVfbQBpAAAAAA==.Livio:BAAALgAECgYJBwABLgAFFAUJBgAFAJwcAA==.',
Ls='Lslvet:BAACLgAFFH8PAAMCAAUJ/iXvBwCoAQACAAUJ/iXvBwCoAQADAAEJAiEQEQBeAAAuAAQKfxYAAwMABgmkJkUgAFABAAIAAwkAJz6AAFoBAAMAAwkcJkUgAFABAAAA.',
Ma='Maaya:BAAALgAECgYJEQAAAA==.Maodimaodi:BAAALgAECgUJBQAAAA==.',
Me='Metha:BAABLgAFFH8GAAIJAAIJNhM/FQClAAAJAAIJNhM/FQClAAAAAA==.',
Mi='Minipanda:BAAALgADCgYJBgAAAA==.',
Mo='Mononoke:BAAALgADCgQJBAAAAA==.',
Na='Nasty:BAAALgAECgEJAgAAAA==.Naturefans:BAAALgAECgEJAQAAAA==.',
['Nä']='Näusicää:BAAALgAECgYJCwAAAA==.',
Sh='Shadow:BAAALgAECgUJBgAAAA==.',
Sk='Skal:BAAALgADCgYJBQAAAA==.',
Sp='Spaceboy:BAABLgAFFH8OAAMKAAUJoAu3AgAdAQAKAAQJoAu3AgAdAQALAAQJ6RgNDAAYAQAAAA==.',
Su='Suesaman:BAAALgAECgMJAwAAAA==.',
Tc='Tck:BAAALgAECgYJCAAAAA==.',
Wi='Windflowers:BAABLgAECn8VAAIMAAcJ1RNBOgCRAQAMAAcJ1RNBOgCRAQABLgAFFAIJAgAGAAAAAA==.',
Yo='Yogg:BAABLgAFFH8FAAINAAQJbwcTBgAeAQANAAQJbwcTBgAeAQAAAA==.',
Zb='Zbv:BAAALgAECgYJCgAAAA==.',
Zh='Zhubv:BAAALgAECgEJAQAAAA==.',
['一方']='一方神圣:BAAALgAECgEJAQAAAA==.',
['一蚊']='一蚊鸡:BAAALgAECgEJAgAAAA==.',
['三千']='三千月夏:BAABLgAFFH8JAAMOAAYJ+RZRAgDbAQAOAAUJZRpRAgDbAQAPAAEJKRBwFwBYAAAAAA==.',
['丝情']='丝情袜意:BAAALgAFFAIJBAAAAA==.',
['丨灬']='丨灬萩水依人:BAAALgAECgYJBgAAAA==.',
['丨灰']='丨灰加丨:BAACLgAFFH8RAAIIAAUJHBx0BwBpAQAIAAUJHBx0BwBpAQAuAAQKfxgAAggABwkAINgQAJgCAAgABwkAINgQAJgCAAAA.',
['丶红']='丶红色:BAAALgAECgIJAwAAAA==.',
['丿桃']='丿桃之妖妖:BAAALgAECgYJBgAAAA==.',
['之零']='之零:BAABLgAECn8UAAICAAcJ8BvsCwC7AQACAAcJ8BvsCwC7AQAAAA==.',
['乐清']='乐清清:BAABLgAFFH8GAAMBAAMJqh5WMwC7AAABAAMJqh5WMwC7AAAQAAEJTQIAAAAAAAAAAA==.',
['云淡']='云淡风轻:BAAALgADCgUJBQAAAA==.',
['云长']='云长:BAAALgAFFAIJAgAAAA==.',
['亨瑟']='亨瑟西:BAAALgAECgQJBQAAAA==.',
['人狠']='人狠话不多:BAAALgAECgEJAQAAAA==.',
['任逍']='任逍遥:BAAALgAECgYJEgAAAA==.',
['伏迪']='伏迪魔:BAAALgADCgYJBgAAAA==.',
['何事']='何事五:BAABLgAECn8eAAMBAAkJaRZgWADpAQABAAcJDxxgWADpAQARAAkJxgsTGQCNAQAAAA==.',
['信德']='信德维拉:BAAALgAECgYJDAABLgAFFAIJAgAGAAAAAA==.',
['傻斯']='傻斯比亚:BAABLgAFFH8IAAMJAAMJ5gmoFwCYAAAJAAMJ5gmoFwCYAAALAAEJnQqhJABDAAAAAA==.',
['光之']='光之掠影:BAAALgAECgQJBAABLgAECgYJAwAGAAAAAA==.',
['六楼']='六楼的未来:BAAALgADCgMJAwAAAA==.',
['兰兰']='兰兰璐:BAAALgAECgEJAQAAAA==.',
['内秘']='内秘心書:BAACLgAFFH8RAAISAAUJgxinGQBkAQASAAUJgxinGQBkAQAuAAQKfxcAAhIABwmwIZtEAGoCABIABwmwIZtEAGoCAAAA.',
['军团']='军团长:BAAALgAECgEJAQAAAA==.',
['冬瓜']='冬瓜蜀黍:BAAALgADCgEJAQAAAA==.',
['冰霜']='冰霜之柱:BAAALgAECgkJCQAAAA==.',
['冲锋']='冲锋:BAAALgAECgcJBwAAAA==.',
['凯恩']='凯恩牛盲:BAAALgADCgUJBQAAAA==.',
['刹那']='刹那快感:BAAALgAECgEJAQAAAA==.',
['剑开']='剑开丶天门:BAAALgADCgMJAwAAAA==.',
['剑惊']='剑惊风:BAAALgAECgQJBgABLgAECgcJFAAHAPAWAA==.',
['勧腝']='勧腝莥錼:BAAALgADCgEJAQAAAA==.',
['十年']='十年梦:BAAALgAECgIJAgAAAA==.',
['十随']='十随心所欲十:BAAALgAECgQJBQAAAA==.',
['千般']='千般随风逝:BAAALgAECgYJBwAAAA==.',
['千鸟']='千鸟晓光:BAAALgAECgQJBAAAAA==.',
['半吨']='半吨肥猫漫步:BAAALgAECgcJBAAAAA==.',
['半城']='半城繁華:BAAALgAECgYJDQAAAA==.',
['华氏']='华氏九度:BAAALgAFFAQJBAAAAA==.',
['发财']='发财:BAAALgAECgcJEwAAAA==.',
['只用']='只用高露洁:BAAALgAECgYJBgAAAA==.',
['叶小']='叶小陶:BAAALgADCgEJAQAAAA==.',
['叶灬']='叶灬傾云:BAAALgAECgYJDAAAAA==.',
['叶玲']='叶玲珑:BAAALgAECgEJAQAAAA==.',
['吃泡']='吃泡面必加肠:BAAALgAECgEJAQAAAA==.',
['吾辈']='吾辈何以爲战:BAAALgADCgYJBgAAAA==.',
['咏叹']='咏叹的哀歌:BAAALgAECgkJBwAAAA==.',
['哀伤']='哀伤天下:BAAALgAECgMJAwAAAA==.',
['哈利']='哈利博特大:BAAALgADCgEJAQAAAA==.',
['唱歌']='唱歌:BAAALgAECgIJAwAAAA==.',
['啃竹']='啃竹子的鼠鼠:BAAALgADCgEJAQAAAA==.',
['喪尸']='喪尸暴龍獸:BAAALgAFFAIJAgAAAA==.',
['因帅']='因帅判死缓了:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光大忽悠丶:BAAALgAECgEJAQAAAA==.圣光打工人:BAAALgADCgEJAQAAAA==.',
['圣手']='圣手:BAAALgAECgQJBQAAAA==.',
['圣神']='圣神归来兮:BAAALgAECgEJAQAAAA==.',
['圣鵺']='圣鵺:BAAALgAECgIJAgAAAA==.',
['埃尔']='埃尔菲莉丝:BAAALgAECgEJAQAAAA==.',
['塔奎']='塔奎琳:BAAALgADCgEJAQAAAA==.',
['复仇']='复仇圣斗士:BAAALgAECgMJBAAAAA==.',
['夕莉']='夕莉小龙人:BAABLgAFFH8MAAMTAAUJEhBEBAABAQATAAUJEhBEBAABAQAUAAIJVQNWHQCEAAAAAA==.',
['夙夜']='夙夜无泪:BAAALgAECgMJAwAAAA==.',
['多玩']='多玩游戏:BAAALgAECgQJBAAAAA==.',
['夜的']='夜的进行曲:BAAALgAECgYJCgAAAA==.',
['夜盗']='夜盗朱雀:BAAALgAECgYJBwAAAA==.',
['夜袭']='夜袭之:BAAALgADCgEJAQAAAA==.',
['大力']='大力董墩:BAAALgAFFAEJAQAAAA==.',
['大霖']='大霖子:BAAALgADCgEJAQAAAA==.',
['天下']='天下会:BAAALgAECgEJAgAAAA==.',
['天妒']='天妒我吊:BAACLgAFFH8NAAIVAAQJbyNJBwCnAQAVAAQJbyNJBwCnAQAuAAQKfxgAAhUABwmgI3gPAMECABUABwmgI3gPAMECAAEuAAUUBQkGAAUAnBwA.',
['天晓']='天晓德:BAAALgADCgYJBgAAAA==.',
['天紫']='天紫月:BAABLgAFFH8GAAIRAAIJwAYUEQBqAAARAAIJwAYUEQBqAAAAAA==.',
['天青']='天青色等煙雨:BAAALgAECgUJBgAAAA==.',
['夹心']='夹心饼干:BAAALgAECgEJAQAAAA==.',
['奥奥']='奥奥卡米:BAAALgAECgIJAwAAAA==.',
['奶酪']='奶酪小魔王:BAAALgAECgYJBgAAAA==.',
['妖怪']='妖怪哥哥:BAAALgAECgYJBwAAAA==.',
['妞妞']='妞妞牛牛:BAAALgAFFAIJAgAAAA==.',
['娃哈']='娃哈蛤:BAABLgAFFH8FAAISAAIJlAoBRwCiAAASAAIJlAoBRwCiAAAAAA==.',
['孤影']='孤影丶:BAAALgAECgQJBAAAAA==.孤影任我行:BAAALgAECgcJBwAAAA==.',
['宁波']='宁波地狱火:BAAALgAECgcJBQAAAA==.宁波年糕团:BAAALgAECgcJBwABLgAFFAYJFwAWANsRAA==.宁波德爷:BAAALgAECgYJBgAAAA==.宁波扣鸡的:BAAALgAECgYJBgAAAA==.宁波柱子爷:BAAALgAECgQJAwAAAA==.宁波海棠开:BAAALgAECgcJBwAAAA==.',
['安然']='安然丨道:BAAALgAECgQJBgAAAA==.',
['官人']='官人不要:BAAALgAECgYJBwAAAA==.',
['寥寥']='寥寥此生虚度:BAAALgAECgEJAQABLgAFFAMJCAAXAIYVAA==.',
['寻剑']='寻剑之鞘:BAAALgAFFAIJAgABLgAFFAUJAQAGAAAAAA==.',
['小学']='小学徒丷呆呆:BAAALgADCgEJAQAAAA==.',
['小山']='小山风雨:BAAALgAECgYJDgAAAA==.',
['小时']='小时候帅帅哒:BAAALgAECgYJCAABLgAFFAQJCgACANMOAA==.小时候闹闹的:BAAALgAECgEJAQABLgAFFAQJCgACANMOAA==.',
['小样']='小样迩:BAAALgAECgQJBAABLgAFFAMJCAAXAIYVAA==.',
['小熊']='小熊包:BAAALgAECgUJCQAAAA==.',
['小约']='小约翰尼:BAAALgAECgEJAgAAAA==.',
['小阿']='小阿布:BAAALgAECgQJCgAAAA==.',
['尸骑']='尸骑李颢:BAACLgAFFH8JAAIWAAQJ3ApECADkAAAWAAQJ3ApECADkAAAuAAQKfxgAAxYABwlrDbo8AEcBABYABgllDro8AEcBAA8AAQmNB6tbACsAAAAA.',
['尼古']='尼古拉斯铠骑:BAAALgAECgkJCQAAAA==.',
['山野']='山野一:BAAALgADCgIJAgAAAA==.',
['工倶']='工倶人:BAAALgADCgUJBQAAAA==.',
['巧囡']='巧囡宝:BAAALgAECgEJAQAAAA==.',
['巨馍']='巨馍丶蘸酱:BAACLgAFFH8NAAIYAAQJURK0CgBQAQAYAAQJURK0CgBQAQAuAAQKfygAAhgABwljH3YFANcBABgABwljH3YFANcBAAAA.',
['帕拉']='帕拉朵珂丝:BAAALgADCgUJBQABLgAFFAYJGAAUACkgAA==.',
['帕蒂']='帕蒂塔:BAAALgAECgUJBAAAAA==.',
['年初']='年初一:BAAALgAECgYJCAAAAA==.',
['庙小']='庙小妖风大:BAAALgAECgQJBgAAAA==.',
['很心']='很心动:BAAALgAECgYJBgABLgAFFAcJEgAPAEEVAA==.',
['忧伤']='忧伤魔术师:BAAALgAECgEJAQAAAA==.',
['恋爱']='恋爱脑:BAAALgAECgIJAwAAAA==.',
['惊无']='惊无命:BAAALgAECgcJDQAAAA==.惊无忌:BAABLgAECn8VAAMZAAcJ4Q96eQCHAQAZAAcJ2w56eQCHAQAaAAMJ3g4hRgAoAAAAAA==.',
['愛言']='愛言葉:BAABLgAFFH8LAAMOAAYJLBG+AwCrAQAOAAUJNRS+AwCrAQAPAAEJngY/GABQAAAAAA==.',
['我就']='我就是未来:BAAALgAFFAIJAgAAAA==.',
['我已']='我已经无敌了:BAABLgAFFH8GAAIFAAUJnBzMKACfAAAFAAUJnBzMKACfAAAAAA==.',
['我很']='我很温柔:BAAALgADCgQJBAAAAA==.',
['我想']='我想养猫:BAAALgADCgMJAwAAAA==.',
['我是']='我是火车王:BAAALgADCgIJAgAAAA==.',
['我有']='我有第一次:BAAALgAECgQJCwAAAA==.',
['我要']='我要去放羊啦:BAAALgADCgUJBQAAAA==.',
['战神']='战神归来兮:BAAALgAECgEJAQAAAA==.',
['打爆']='打爆宝宝牛:BAAALgADCgcJCgAAAA==.',
['执笔']='执笔画卿妍:BAAALgAECgYJBwAAAA==.',
['搞还']='搞还是你会搞:BAABLgAFFH8OAAMbAAUJTha6BAAvAQAbAAQJTha6BAAvAQAcAAEJAAAAAAAAAAAAAA==.',
['摩羯']='摩羯座的鱼:BAAALgAECgYJCgAAAA==.',
['断肠']='断肠崖养蜜蜂:BAAALgAECgcJBwAAAA==.',
['无敌']='无敌:BAAALgAECgIJAgAAAA==.',
['时空']='时空猎手艾伦:BAAALgAECgQJCAAAAA==.',
['星球']='星球坠落:BAAALgAFFAIJAgABLgAFFAMJCQALAGogAA==.',
['星辰']='星辰夜风:BAAALgAFFAIJAwAAAA==.',
['春风']='春风十菀里:BAAALgAECgIJAgAAAA==.',
['是喵']='是喵装熊:BAAALgAFFAEJAQABLgAFFAMJBwAFALMUAA==.',
['晴羽']='晴羽乐:BAAALgAECgYJBgAAAA==.',
['暗梦']='暗梦贝斯特:BAABLgAFFH8FAAICAAMJ8hEuIQD/AAACAAMJ8hEuIQD/AAAAAA==.',
['最后']='最后一舞:BAAALgAECgYJBgABLgAFFAUJBgAFAJwcAA==.',
['月翼']='月翼猫头鹰:BAAALgAFFAQJAwAAAA==.',
['月见']='月见桜:BAAALgAECgUJCAAAAA==.',
['月貓']='月貓:BAAALgAECgUJBgAAAA==.',
['月雾']='月雾:BAAALgAECgIJAgAAAA==.',
['有德']='有德有诗:BAAALgAECgEJAQAAAA==.',
['本王']='本王朝酒晚舞:BAAALgADCgEJAQAAAA==.',
['朱诺']='朱诺:BAAALgAFFAMJAwAAAA==.',
['杀死']='杀死小绝爵:BAAALgAECgUJBgAAAA==.',
['林哥']='林哥:BAAALgAECgkJCQAAAA==.',
['枫叶']='枫叶扫过星辰:BAABLgAFFH8FAAMMAAMJThjkEwCjAAAMAAIJzBnkEwCjAAAZAAEJRgQAAAAAAAAAAA==.',
['柒海']='柒海:BAAALgAECgEJAQAAAA==.',
['树旁']='树旁丶落叶:BAAALgAECgUJCwAAAA==.',
['格调']='格调丶:BAAALgADCgIJAgAAAA==.',
['桃兔']='桃兔兔:BAAALgADCgUJBQAAAA==.',
['梅川']='梅川哇子:BAAALgAECgYJBgAAAA==.',
['森之']='森之千手:BAAALgAECgcJBwAAAA==.',
['欢乐']='欢乐水牛:BAAALgAECgYJBwAAAA==.',
['歆然']='歆然:BAACLgAFFH8IAAISAAMJaBIGLAAGAQASAAMJaBIGLAAGAQAuAAQKfxwAAhIACAmvH9QtALoCABIACAmvH9QtALoCAAAA.',
['武哥']='武哥:BAAALgAFFAIJAgAAAA==.武哥哥本色:BAABLgAECn8VAAQDAAcJEQ/zMQDxAAADAAQJ3hHzMQDxAAAdAAIJAA+jHACNAAACAAQJ9AdL7ACCAAAAAA==.',
['武神']='武神归来兮:BAAALgAECgEJAQAAAA==.',
['毛蛋']='毛蛋:BAAALgADCgIJAgAAAA==.',
['水水']='水水牧:BAAALgAECggJCAAAAA==.',
['沙僧']='沙僧没人爱:BAAALgAECgUJBgAAAA==.',
['沙拉']='沙拉酱酱:BAAALgAECgUJBAAAAA==.',
['沙音']='沙音:BAAALgAECgEJAQAAAA==.',
['泪眼']='泪眼冰:BAAALgAECgIJAgAAAA==.',
['泪雨']='泪雨纷飞:BAAALgAECgIJAgAAAA==.',
['流恋']='流恋的已太久:BAAALgAECgEJAQAAAA==.',
['流氓']='流氓丶砍:BAAALgAECgEJAQAAAA==.',
['浦宝']='浦宝:BAAALgAFFAMJBAAAAA==.',
['淡淡']='淡淡丶:BAAALgAECgYJEAAAAA==.',
['淡若']='淡若清风:BAAALgAECgQJBAAAAA==.',
['清书']='清书:BAAALgADCgEJAQAAAA==.',
['温酒']='温酒醉人:BAAALgAECgIJAwAAAA==.',
['火上']='火上弄冰:BAAALgAECgYJDwAAAA==.',
['火花']='火花:BAAALgAECgEJAQAAAA==.',
['灬刀']='灬刀刀:BAAALgAECgEJAQAAAA==.',
['灬叨']='灬叨逼叨:BAACLgAFFH8MAAMcAAQJbxWSAgBAAQAcAAQJbxWSAgBAAQAYAAIJAgn+GgCcAAAuAAQKfyEAAxwABwnmIsAGAFoCABgABwlBIm0aAHgCABwABgmwIMAGAFoCAAAA.',
['灬朷']='灬朷朷:BAAALgAECgQJBAAAAA==.',
['灰色']='灰色天空丨:BAAALgAECgkJCQABLgAFFAYJEwAZAMggAA==.',
['灰败']='灰败的蔷薇:BAABLgAFFH8FAAIZAAIJ1AeuKACWAAAZAAIJ1AeuKACWAAAAAA==.',
['灵魂']='灵魂奶霸:BAAALgAECgMJAwAAAA==.',
['灼眼']='灼眼的小菜鸡:BAAALgAECgcJEQAAAA==.',
['無雙']='無雙丶:BAAALgAECgcJDQAAAA==.',
['熊宝']='熊宝花花:BAAALgADCgEJAQAAAA==.',
['熊猫']='熊猫女酒仙:BAAALgAECgcJCwAAAA==.',
['爱哎']='爱哎艾:BAAALgADCgEJAQAAAA==.',
['爱弥']='爱弥斯:BAAALgAECgIJAgAAAA==.',
['牛图']='牛图图:BAAALgAECgMJAgAAAA==.',
['牛妞']='牛妞扭扭:BAAALgADCgQJBAAAAA==.',
['牛逼']='牛逼轰轰:BAAALgADCgQJBAAAAA==.',
['猎袭']='猎袭柯:BAAALgAECgQJAgAAAA==.',
['瑀哥']='瑀哥:BAAALgAFFAEJAQAAAA==.',
['疾风']='疾风:BAAALgAECgQJBgAAAA==.',
['白泽']='白泽:BAAALgAECgEJAQAAAA==.',
['百变']='百变丶熊猫:BAAALgAECgUJBQABLgAECgYJBgAGAAAAAA==.',
['百折']='百折与蜂鸟:BAAALgAECgUJBQAAAA==.',
['盐津']='盐津枣:BAABLgAFFH8GAAIYAAIJKRpuFQC8AAAYAAIJKRpuFQC8AAAAAA==.',
['神符']='神符影之歌:BAAALgAECgYJCgAAAA==.',
['神经']='神经妇科:BAAALgAECgUJBQAAAA==.',
['秋森']='秋森晚:BAACLgAFFH8MAAMTAAQJ5ATFBgCjAAATAAIJMAjFBgCjAAAeAAMJ8RgGEgCfAAAuAAQKfx4AAx4ACAngH4IGANsCAB4ACAngH4IGANsCABMAAQnUGeQ5AEsAAAAA.',
['穆穆']='穆穆:BAAALgAECgQJCAAAAA==.',
['粉色']='粉色:BAAALgAECgEJAgAAAA==.',
['素素']='素素丨:BAAALgAECgEJAQAAAA==.',
['紫雨']='紫雨凝香:BAACLgAFFH8RAAMMAAUJQxHqCQA5AQAMAAUJQxHqCQA5AQAaAAIJPQuBBQBsAAAuAAQKfxgAAxoABwmEEn8TAJMBABoABwmEEn8TAJMBAAwAAwlpCuJ3AJkAAAAA.',
['红皮']='红皮猴子丶:BAAALgAECgYJBgAAAA==.',
['纳格']='纳格兰的天空:BAAALgAECgcJDQAAAA==.',
['纳西']='纳西妲灬:BAAALgAFFAQJBAAAAA==.',
['绯玉']='绯玉丸:BAAALgADCgUJBQABLgAECgYJDgAGAAAAAA==.',
['绯英']='绯英:BAAALgAECgYJDgAAAA==.',
['绿色']='绿色天然呆:BAACLgAFFH8GAAIfAAMJehc6DwCnAAAfAAMJehc6DwCnAAAuAAQKfyQAAh8ABwmrIvYKAKMCAB8ABwmrIvYKAKMCAAAA.',
['缇娅']='缇娅娜:BAAALgAECgEJAgAAAA==.',
['群主']='群主趴一下:BAAALgAECgkJCQABLgAFFAUJBQAEAJkcAA==.',
['翻墙']='翻墙采红杏:BAAALgAECgUJDAAAAA==.',
['耳鼻']='耳鼻你居然:BAAALgAECgEJAQAAAA==.',
['胖的']='胖的滚不动:BAAALgADCgUJBQAAAA==.',
['胭脂']='胭脂凝泪:BAAALgAECgUJBQAAAA==.',
['芙莉']='芙莉莲梦露:BAACLgAFFH8RAAISAAUJqSMnDgCpAQASAAUJqSMnDgCpAQAuAAQKfxgAAhIABwk8JnkaAA0DABIABwk8JnkaAA0DAAAA.',
['芝麻']='芝麻酱:BAAALgADCgcJBwAAAA==.',
['花果']='花果山大统领:BAAALgADCgQJBAAAAA==.花果山话事人:BAAALgAECgQJBAAAAA==.',
['苍岑']='苍岑:BAAALgAECgUJBwAAAA==.',
['茅台']='茅台酒:BAAALgAFFAMJBAAAAA==.',
['莫格']='莫格莱尼伯爵:BAAALgAECgYJBgAAAA==.',
['菜叶']='菜叶子:BAAALgADCgUJBQABLgAFFAIJAgAGAAAAAA==.',
['萌牛']='萌牛萌牛:BAAALgADCgEJAQAAAA==.',
['萌萌']='萌萌灬小钰:BAAALgAECgEJAQAAAA==.',
['落羽']='落羽炼狱:BAAALgAECgcJBwAAAA==.',
['蒙牛']='蒙牛丹:BAAALgADCgQJBAAAAA==.',
['蓝蓝']='蓝蓝的懒胖胖:BAAALgAECgMJBAAAAA==.',
['蛊妖']='蛊妖:BAAALgAECgIJAgAAAA==.',
['蝶步']='蝶步韶华:BAAALgAFFAIJAgAAAA==.',
['被封']='被封印的绘影:BAAALgAECgEJAQAAAA==.',
['西园']='西园寺:BAAALgAECgMJAwAAAA==.',
['触手']='触手猴:BAAALgAFFAEJAQAAAA==.',
['请叫']='请叫我国宝:BAAALgAECgQJBAAAAA==.',
['贝尔']='贝尔武夫:BAAALgAECgEJAQAAAA==.',
['贪玩']='贪玩兰月:BAAALgAFFAEJAgAAAA==.',
['超级']='超级小龙人:BAAALgAECgYJBQABLgAFFAUJBAAGAAAAAA==.',
['这是']='这是长难句:BAAALgAECgYJBgAAAA==.',
['迷路']='迷路的小筱猫:BAAALgAECgMJAwAAAA==.',
['遛鸟']='遛鸟的二爷:BAAALgADCgEJAQAAAA==.',
['邪能']='邪能柯:BAAALgAECgkJBwAAAA==.',
['部落']='部落主宰者:BAAALgAECgEJAgAAAA==.',
['酒酿']='酒酿小元宵:BAAALgAECgMJBQAAAA==.',
['醉里']='醉里论道:BAAALgAFFAQJBAAAAA==.',
['野狗']='野狗:BAAALgAFFAMJAwAAAA==.',
['锦书']='锦书念君安:BAAALgAECgEJAQAAAA==.',
['闪光']='闪光灿灿:BAAALgADCgcJBwAAAA==.',
['阳月']='阳月拾贰:BAABLgAECn8VAAISAAYJLB5ybwD1AQASAAYJLB5ybwD1AQAAAA==.',
['阴魂']='阴魂恶煞:BAAALgAECgUJCAAAAA==.',
['阿威']='阿威拾捌式:BAAALgAECgYJBgAAAA==.',
['阿尔']='阿尔可:BAAALgAECgYJDAAAAA==.',
['陌上']='陌上桑:BAAALgAECgEJAgAAAA==.',
['集火']='集火武器战:BAAALgAECgYJBgAAAA==.',
['霸霸']='霸霸:BAAALgAECgQJBAAAAA==.',
['青丝']='青丝烫口丶:BAAALgAECgQJBAAAAA==.',
['青柠']='青柠檬单杯:BAAALgAFFAIJAgAAAA==.',
['青瓷']='青瓷若水:BAABLgAFFH8HAAISAAMJ6yABMwDRAAASAAMJ6yABMwDRAAAAAA==.',
['青笺']='青笺画卿妍:BAAALgAECgYJCAAAAA==.',
['青花']='青花瓷:BAAALgAECgMJBgAAAA==.',
['青貔']='青貔貅:BAAALgAECgYJAwAAAA==.',
['青龙']='青龙寺:BAAALgAECgEJAQAAAA==.',
['非常']='非常人贩:BAABLgAFFH8MAAQgAAQJrBDYCwC6AAAVAAMJxg3hFQDsAAAgAAIJqRXYCwC6AAAhAAEJnQE8CAA5AAAAAA==.',
['面朝']='面朝丨大海:BAAALgAECgYJBgAAAA==.',
['风之']='风之泣:BAAALgAECgUJCgAAAA==.',
['风揽']='风揽月:BAAALgAFFAEJAQAAAA==.',
['飓风']='飓风之音:BAAALgAECgEJAQAAAA==.',
['飛天']='飛天牛牛:BAAALgADCgUJBQAAAA==.',
['飞天']='飞天肥龙:BAAALgAECgcJAQAAAA==.',
['骁骁']='骁骁爸比:BAAALgAECgQJBAABLgAFFAMJCAAXAIYVAA==.',
['骑士']='骑士奶奶:BAAALgAECgcJCgAAAA==.骑士小莺:BAAALgAECgEJAQAAAA==.',
['魁魑']='魁魑魅:BAABLgAECn8aAAMCAAYJoSUWIwCIAgACAAYJoSUWIwCIAgADAAEJAACPWABlAAABLgAFFAMJBwAFALMUAA==.',
['魅影']='魅影帅帅:BAAALgAECgQJBQAAAA==.魅影重重:BAAALgAECgEJAgAAAA==.',
['魔神']='魔神归来兮:BAAALgAECgEJAgAAAA==.',
['黑暗']='黑暗海濑:BAACLgAFFH8HAAIBAAMJkCF+HwAeAQABAAMJkCF+HwAeAQAuAAQKfxgAAgEACQldH7wKAEUDAAEACQldH7wKAEUDAAAA.',
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
