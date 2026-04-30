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

local lookup = {'Unknown-Unknown','Paladin-Retribution','Mage-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Windwalker','DemonHunter-Devourer','DeathKnight-Unholy','Hunter-Survival','Priest-Shadow','DeathKnight-Blood','Priest-Holy','Druid-Restoration','Warrior-Fury','Warrior-Protection',}
local provider = {region='CN',realm='普瑞斯托',name='CN',type='weekly',zone=46,date='2026-04-25',data={Bl='Bleachdream:BAAALgADCgEJAQAAAA==.Blindmaker:BAAALgAECgEJAQAAAA==.',
Du='Duhunt:BAAALgAECgEJAQAAAA==.',
Gu='Gudetama:BAAALgAECgcJBwAAAA==.Gugul:BAAALgAFFAEJAQAAAA==.',
Ke='Kej:BAAALgAECgYJBgAAAA==.',
Ni='Nikandjay:BAAALgADCgEJAQAAAA==.',
Th='Thisbitch:BAAALgAECgIJAgAAAA==.',
Wa='Wanaka:BAAALgAECgEJAQAAAA==.',
['一弯']='一弯丹桂:BAAALgAECgkJCgABLgAFFAIJBAABAAAAAA==.',
['一笑']='一笑像你爷:BAAALgAECgIJAgAAAA==.',
['七丶']='七丶夜:BAAALgAECgEJAQAAAA==.',
['东边']='东边的太阳:BAAALgAECgYJDAAAAA==.',
['中碎']='中碎发荷叶头:BAAALgAECgQJBgAAAA==.',
['临申']='临申:BAABLgAECn8WAAICAAYJJx1WWQDWAQACAAYJJx1WWQDWAQAAAA==.',
['亲亲']='亲亲皮皮马:BAAALgADCgYJBwAAAA==.',
['伊比']='伊比利亚海胆:BAAALgAECgEJAQAAAA==.',
['伊诺']='伊诺的大仙:BAABLgAECn8WAAIDAAYJ8hQ1qQCHAQADAAYJ8hQ1qQCHAQAAAA==.伊诺的狗蛋:BAAALgAECgEJAQAAAA==.',
['休闲']='休闲老司机:BAAALgAECgIJAgAAAA==.',
['倾听']='倾听安琪儿:BAAALgAECgYJEQABLgAFFAIJBAABAAAAAA==.',
['傻大']='傻大猫:BAAALgADCgMJAwAAAA==.',
['元气']='元气猫师傅:BAAALgAECgIJAwAAAA==.',
['光辉']='光辉之手:BAAALgADCgMJAwAAAA==.',
['克罗']='克罗撒:BAAALgADCgUJBQAAAA==.',
['公子']='公子灬幽:BAAALgAECgIJAgAAAA==.',
['兽群']='兽群之心:BAAALgAECgYJDAAAAA==.',
['冷逸']='冷逸丶:BAAALgAFFAEJAQAAAA==.',
['刀剑']='刀剑双辉:BAAALgADCgQJBAAAAA==.',
['剑戟']='剑戟与塔盾:BAAALgADCgYJBgAAAA==.',
['华丽']='华丽的酱油瓶:BAAALgAECgYJDwAAAA==.',
['双马']='双马尾即正义:BAAALgAECgUJBgAAAA==.',
['可愛']='可愛茉莉:BAABLgAECn8gAAIDAAcJ3B6pRQBnAgADAAcJ3B6pRQBnAgAAAA==.',
['各種']='各種酸甜:BAAALgAECgYJDAAAAA==.',
['吕布']='吕布:BAAALgAECgUJCwAAAA==.',
['唯唯']='唯唯跟班啊贱:BAAALgADCgEJAQAAAA==.',
['啊姐']='啊姐姐:BAAALgAECgEJAQAAAA==.',
['噜喵']='噜喵喵:BAABLgAECn8kAAMEAAkJsBY+IgA4AgAEAAkJsBY+IgA4AgAFAAIJlgC9lAAlAAABLgAFFAEJAQABAAAAAA==.',
['圆汐']='圆汐汐:BAAALgAECgQJBAAAAA==.',
['大宗']='大宗师转死你:BAABLgAECn8UAAIGAAcJpSSODACxAgAGAAcJpSSODACxAgAAAA==.',
['大波']='大波浪:BAAALgAECgEJAQAAAA==.',
['天际']='天际猎:BAAALgADCgIJAgAAAA==.',
['容赦']='容赦丶姬:BAAALgAECgcJBwAAAA==.',
['小姜']='小姜饼:BAAALgAECgUJBQAAAA==.',
['小小']='小小的很可爱:BAAALgAECgEJAQABLgAECgcJFAAGAKUkAA==.',
['小莫']='小莫非:BAABLgAFFH8GAAIHAAQJkQVPCwAIAQAHAAQJkQVPCwAIAQAAAA==.',
['巧心']='巧心柔:BAAALgADCgEJAQAAAA==.',
['师太']='师太借个吻:BAAALgAECgIJAgAAAA==.',
['师娘']='师娘:BAAALgAECgEJAQAAAA==.',
['康拉']='康拉德丶科兹:BAAALgAECgcJBQAAAA==.',
['开发']='开发区供电所:BAAALgAECgcJBgAAAA==.',
['弦子']='弦子:BAAALgADCgEJAQAAAA==.',
['影踪']='影踪派二少爷:BAAALgAECgIJAwAAAA==.',
['快乐']='快乐小龙人:BAAALgAECgUJCQAAAA==.',
['思念']='思念安琪儿:BAAALgADCgQJBAAAAA==.',
['情人']='情人小叽:BAAALgAECgUJBwAAAA==.情人小唧:BAAALgAECgIJAgAAAA==.情人小疾:BAAALgAECgUJBQAAAA==.情人小虚:BAAALgADCgMJAwAAAA==.',
['我不']='我不是海绵:BAABLgAECn8WAAIIAAYJKhvIaQC4AQAIAAYJKhvIaQC4AQAAAA==.',
['新建']='新建小角色:BAAALgAECgEJAgAAAA==.',
['无法']='无法無天:BAAALgADCgYJBgAAAA==.',
['时分']='时分:BAAALgAECgcJCwAAAA==.',
['星际']='星际飞梭:BAAALgAECgUJBQAAAA==.',
['晓晓']='晓晓玄奴:BAAALgAECgcJBgAAAA==.',
['暴怒']='暴怒者格鲁:BAAALgADCgYJBgAAAA==.',
['月下']='月下的安琪儿:BAAALgAFFAIJBAAAAA==.',
['望月']='望月穗波:BAABLgAFFH8JAAMFAAMJERcjHAClAAAJAAMJgA4hBQCwAAAFAAIJORUjHAClAAAAAA==.',
['杨小']='杨小法:BAABLgAECn8WAAIDAAYJAg4BygBVAQADAAYJAg4BygBVAQAAAA==.',
['枸杞']='枸杞当零食:BAAALgAECgIJAgAAAA==.',
['格丽']='格丽乔:BAAALgAECgYJCwAAAA==.',
['椰椰']='椰椰芒芒:BAAALgADCgUJBQAAAA==.',
['比翼']='比翼齐飞:BAACLgAFFH8HAAIDAAMJxgqvLwD3AAADAAMJxgqvLwD3AAAuAAQKfxcAAgMABwnkHUFWADYCAAMABwnkHUFWADYCAAAA.',
['江树']='江树:BAAALgAECgIJAgAAAA==.',
['沃里']='沃里克:BAAALgADCgQJBQAAAA==.',
['沉静']='沉静陛下:BAAALgAECgcJBwAAAA==.',
['波波']='波波头波妞:BAAALgAECgYJBwAAAA==.',
['涅法']='涅法雷姆:BAAALgADCgEJAQAAAA==.',
['涛涛']='涛涛江水:BAABLgAECn8WAAICAAcJaBhNUADwAQACAAcJaBhNUADwAQAAAA==.',
['淇淇']='淇淇大魔王:BAAALgAECgYJDQAAAA==.',
['淡然']='淡然遮伤痕:BAAALgAECgQJBQAAAA==.',
['游子']='游子:BAABLgAECn8WAAIKAAYJ1RqNJgCjAQAKAAYJ1RqNJgCjAQAAAA==.',
['游戏']='游戏梦:BAAALgAECgYJEgAAAA==.',
['滚地']='滚地僧:BAAALgAECgIJAgAAAA==.',
['灰野']='灰野:BAABLgAECn8WAAILAAYJfRFtIwAlAQALAAYJfRFtIwAlAQAAAA==.',
['燃烧']='燃烧灬青春:BAABLgAECn8WAAIEAAYJZBjFQwChAQAEAAYJZBjFQwChAQAAAA==.',
['爱莉']='爱莉希雅:BAAALgAFFAQJBAAAAA==.',
['爽至']='爽至爱上:BAAALgAECgEJAQAAAA==.',
['牛牛']='牛牛的西北方:BAAALgAECgkJCQAAAA==.',
['牧有']='牧有鱼丸粗面:BAAALgAECgMJBAAAAA==.',
['甜丝']='甜丝丝:BAAALgAECgEJAQAAAA==.',
['电光']='电光石火:BAAALgAECgQJBAAAAA==.',
['瞄下']='瞄下就射:BAAALgADCgEJAQAAAA==.',
['碧螺']='碧螺春:BAAALgAECgMJBQAAAA==.',
['离殇']='离殇:BAAALgAFFAEJAQAAAA==.',
['究极']='究极小强:BAAALgAECgIJAwAAAA==.',
['窝是']='窝是土豆:BAAALgADCgcJDgAAAA==.',
['糯米']='糯米:BAABLgAECn8WAAIMAAYJdhDWPABGAQAMAAYJdhDWPABGAQAAAA==.',
['红唇']='红唇一族:BAAALgADCgMJAwAAAA==.',
['纯洁']='纯洁小扁鹊:BAAALgAECgUJCgAAAA==.',
['绯天']='绯天:BAAALgAECgEJAQAAAA==.',
['维维']='维维豆奶:BAAALgADCgUJAwAAAA==.',
['羽越']='羽越打豆芽:BAAALgADCgcJBwAAAA==.',
['肯德']='肯德土豆泥:BAAALgAFFAQJBAAAAA==.',
['胸毛']='胸毛迎风飘:BAAALgAECgIJBQAAAA==.',
['自然']='自然的柠乐:BAAALgAECgkJEgAAAA==.自然的柠檬:BAAALgAECgcJDQAAAA==.自然的牛奶:BAAALgAECgcJBwAAAA==.',
['艾玛']='艾玛萨:BAAALgADCgYJCwAAAA==.',
['芝芝']='芝芝绿妍茶:BAAALgADCgQJBAAAAA==.',
['芝麻']='芝麻:BAAALgADCgEJAQAAAA==.',
['花样']='花样作死冠军:BAACLgAFFH8cAAIFAAcJyxdFAQCGAgAFAAcJyxdFAQCGAgAuAAQKfxYAAgUABwlWIVEYAGcCAAUABwlWIVEYAGcCAAAA.',
['花舞']='花舞四季:BAAALgAECgYJCwAAAA==.',
['荆棘']='荆棘邪月:BAAALgADCgcJBwAAAA==.',
['荣耀']='荣耀圣光:BAAALgAECgcJDQAAAA==.',
['萌萌']='萌萌的小德:BAACLgAFFH8KAAINAAMJQyDCDAAZAQANAAMJQyDCDAAZAQAuAAQKfxYAAg0ABgl+JWgZAG0CAA0ABgl+JWgZAG0CAAAA.',
['落日']='落日远:BAAALgAECgcJBwAAAA==.',
['蓬萊']='蓬萊山辉夜:BAACLgAFFH8JAAMOAAQJzA5gCwBJAQAOAAQJzA5gCwBJAQAPAAEJWwBUEgAsAAAuAAQKfyIAAw4ACAlhHy0bAHICAA4ABwkzIS0bAHICAA8AAQlzFOhDAD4AAAAA.',
['藤田']='藤田言音:BAAALgADCgMJAwAAAA==.',
['讷愚']='讷愚:BAAALgAECgcJBwAAAA==.',
['诗乃']='诗乃:BAAALgAECgkJEAAAAA==.',
['赖皮']='赖皮牛:BAAALgAECgEJAQAAAA==.',
['路飞']='路飞:BAAALgAFFAEJAQAAAA==.',
['迷岛']='迷岛:BAAALgAECgMJAwAAAA==.',
['阿卡']='阿卡林:BAAALgADCgUJBQAAAA==.',
['阿塔']='阿塔拉:BAAALgAECgQJBAAAAA==.',
['阿布']='阿布奥:BAAALgAFFAQJBAAAAA==.阿布欧:BAABLgAFFH8JAAIPAAUJnxZuAgCNAQAPAAUJnxZuAgCNAQAAAA==.阿布盾:BAABLgAFFH8IAAIPAAQJEhTxBAAoAQAPAAQJEhTxBAAoAQAAAA==.',
['陆丨']='陆丨星语:BAAALgAECgYJEAAAAA==.',
['限量']='限量版图腾:BAAALgAECgEJAQAAAA==.',
['雨文']='雨文卡加斯:BAAALgAECgUJBQAAAA==.',
['雨落']='雨落寒尘缘:BAAALgAECgQJBQAAAA==.',
['霊魂']='霊魂二十一克:BAAALgAECgUJCgAAAA==.',
['风残']='风残云阙:BAAALgAECgEJAQAAAA==.',
['风神']='风神忽悠着你:BAAALgAECgEJAQAAAA==.',
['魔鬼']='魔鬼终结者:BAAALgAECgQJBgAAAA==.',
['麦当']='麦当劳薯饼:BAAALgADCgMJAwAAAA==.',
['黑豆']='黑豆:BAAALgAECgMJBQAAAA==.',
['黒荳']='黒荳:BAAALgAECgQJBQAAAA==.',
['黯然']='黯然赴黄昏:BAAALgAECgYJCAAAAA==.',
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
