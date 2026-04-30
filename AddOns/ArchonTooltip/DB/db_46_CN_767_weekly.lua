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

local lookup = {'Druid-Balance','Druid-Restoration','Mage-Frost','Hunter-BeastMastery','DeathKnight-Unholy','Warlock-Destruction','Warlock-Demonology','DemonHunter-Devourer','Hunter-Survival','Hunter-Marksmanship','Warrior-Protection','Monk-Mistweaver','Monk-Windwalker','Paladin-Retribution',}
local provider = {region='CN',realm='瓦里玛萨斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={As='Asetulip:BAAALgAFFAIJAwAAAA==.',
Fq='Fq:BAAALgAECgcJDAAAAA==.',
Gj='Gjing:BAAALgAECgEJAQAAAA==.',
Ma='Mascar:BAAALgADCgYJBgAAAA==.',
So='Sotk:BAAALgAECgIJAwAAAA==.',
Su='Summet:BAAALgAECgIJBwAAAA==.',
Th='Thelight:BAAALgAECgEJAgAAAA==.',
Ve='Venn:BAAALgADCgcJBwAAAA==.',
['一森']='一森林一:BAACLgAFFH8XAAMBAAYJ5R3kAQD4AQABAAUJZCPkAQD4AQACAAEJHQkaIwBOAAAuAAQKfyEAAgEACAm2I2UGADIDAAEACAm2I2UGADIDAAAA.',
['不羁']='不羁之风:BAAALgADCgYJBgAAAA==.',
['丝路']='丝路花雨:BAAALgAECgEJAwAAAA==.',
['丨女']='丨女神丨:BAAALgADCgEJAQAAAA==.',
['丨我']='丨我宝宝呢:BAAALgADCgYJBgAAAA==.',
['丰收']='丰收女巫赫萝:BAAALgAECgcJBgAAAA==.',
['丽影']='丽影鬼魅:BAAALgADCgMJAwAAAA==.',
['九宝']='九宝:BAABLgAECn8UAAIDAAcJUR1ZSQBbAgADAAcJUR1ZSQBbAgABLgAFFAYJCwADAL0cAA==.',
['九羅']='九羅:BAAALgAECgEJAQAAAA==.',
['二人']='二人组约瑟夫:BAAALgAECgQJBAAAAA==.',
['二月']='二月红:BAAALgADCgIJAgAAAA==.',
['你太']='你太有才了:BAAALgAECgcJBwAAAA==.',
['你疯']='你疯了吧:BAAALgADCgMJAgAAAA==.',
['你瞅']='你瞅啥:BAABLgAECn8cAAIEAAYJBiLrDADCAQAEAAYJBiLrDADCAQAAAA==.',
['倾城']='倾城月:BAAALgAECgQJBAAAAA==.',
['元气']='元气包:BAAALgADCgcJDAAAAA==.',
['冯万']='冯万宁别整我:BAAALgAECgEJAQAAAA==.',
['冰镇']='冰镇饮料:BAAALgADCgEJAQAAAA==.',
['冷彻']='冷彻心扉:BAAALgAECgUJBQAAAA==.',
['冷猫']='冷猫:BAAALgAECgMJBAAAAA==.',
['冷血']='冷血菠萝:BAABLgAECn8WAAIFAAYJchwhYgDNAQAFAAYJchwhYgDNAQAAAA==.',
['减肥']='减肥后刘波:BAABLgAFFH8FAAMGAAUJKhsxBQAlAQAGAAMJ9R8xBQAlAQAHAAIJYBaGLwC0AAAAAA==.',
['刺客']='刺客大哥:BAAALgAECgUJBQAAAA==.',
['北城']='北城骑士:BAAALgAECgQJBQAAAA==.',
['卑劣']='卑劣之人:BAAALgAECgkJAgAAAA==.',
['双生']='双生火焰:BAAALgAECgMJAwAAAA==.',
['发光']='发光的蹄妹:BAAALgAECgUJBQAAAA==.',
['取名']='取名废:BAAALgAECgYJDwAAAA==.',
['吃苹']='吃苹果:BAAALgADCgEJAQAAAA==.',
['周流']='周流六虚:BAAALgAECgQJBgAAAA==.',
['圣光']='圣光小熊:BAAALgAECgEJAQAAAA==.',
['圣翼']='圣翼七芒星:BAAALgADCgcJBwAAAA==.',
['圣菲']='圣菲尔璐丝:BAAALgADCggJCAAAAA==.',
['壮哉']='壮哉我大圣堂:BAAALgAFFAEJAQAAAA==.',
['大菊']='大菊已定:BAAALgADCgEJAQAAAA==.',
['奥利']='奥利维亚:BAAALgAECgYJBgAAAA==.',
['奶白']='奶白滴雪子:BAAALgAECgMJAwAAAA==.',
['奶非']='奶非天:BAAALgAECgYJDgAAAA==.',
['妖铃']='妖铃铃捌陆:BAAALgAECgYJCQAAAA==.',
['妹妹']='妹妹去哪了:BAAALgAECgYJDAAAAA==.',
['完美']='完美净化:BAAALgAECgYJEAAAAA==.',
['宜家']='宜家:BAAALgADCgYJBgAAAA==.',
['射月']='射月战将:BAAALgADCgYJBgAAAA==.',
['小乔']='小乔刘水人家:BAAALgAFFAEJAQAAAA==.',
['小德']='小德玛利亚:BAAALgADCgQJBAAAAA==.',
['小恶']='小恶魔在哪:BAAALgAECgQJBwAAAA==.',
['小食']='小食尸鬼:BAAALgADCgEJAQAAAA==.',
['小魚']='小魚:BAAALgAECgMJBgAAAA==.',
['尿高']='尿高只为遮泪:BAAALgAECgkJBAAAAA==.',
['屋顶']='屋顶丨:BAACLgAFFH8JAAIIAAMJZh4SFgAhAQAIAAMJZh4SFgAhAQAuAAQKfxoAAggACAkDGj8rAFMCAAgACAkDGj8rAFMCAAAA.',
['幽幽']='幽幽天崀:BAAALgAFFAIJAgABLgAFFAMJCAAJACwWAA==.幽幽天狼:BAACLgAFFH8IAAQJAAMJLBa/BQC4AAAJAAIJNxK/BQC4AAAKAAIJxxT9GwCmAAAEAAEJqQ5jIgBbAAAuAAQKfxUAAgoABwmwHTgcAEMCAAoABwmwHTgcAEMCAAAA.幽幽天笛:BAAALgAECgYJBgAAAA==.',
['建御']='建御名方:BAACLgAFFH8FAAILAAIJMgttDACDAAALAAIJMgttDACDAAAuAAQKfxkAAgsACAnoCxwaAH4BAAsACAnoCxwaAH4BAAAA.',
['异次']='异次心动:BAAALgAECgEJAQAAAA==.',
['微风']='微风:BAACLgAFFH8HAAMMAAMJxAVBCQC2AAAMAAMJxAVBCQC2AAANAAIJCQ2fDACeAAAuAAQKfxUAAw0ACAlDGzElAK0BAA0ABgkgHDElAK0BAAwABAmTE7o8APUAAAAA.',
['怒海']='怒海孤鸿:BAAALgAECgEJAQAAAA==.',
['悟丨']='悟丨空:BAAALgAECgYJDAAAAA==.',
['悲凉']='悲凉的西风:BAAALgAECgEJAQAAAA==.',
['慈溪']='慈溪太后:BAAALgAECgQJBAAAAA==.',
['我迪']='我迪迦在东北:BAAALgAECgEJAQAAAA==.',
['戮丶']='戮丶盾:BAAALgAECgQJBwAAAA==.',
['抵抗']='抵抗之弧领袖:BAAALgAFFAIJBAAAAA==.',
['提伯']='提伯斯:BAAALgADCgUJBQAAAA==.',
['敬海']='敬海之源:BAAALgAECgMJAwAAAA==.',
['断角']='断角之赫比昂:BAAALgADCgIJAgAAAA==.',
['无聊']='无聊而已:BAAALgADCgUJBQAAAA==.',
['旺旺']='旺旺小小酥:BAAALgAECgEJAQAAAA==.',
['暗夜']='暗夜之弓:BAAALgADCgEJAQAAAA==.暗夜魅姬:BAAALgAECgIJAgAAAA==.',
['月舞']='月舞:BAAALgAECgQJBAAAAA==.',
['桃之']='桃之幺幺:BAAALgADCgIJAgAAAA==.',
['欧阳']='欧阳翠竹:BAAALgAECgQJBAAAAA==.',
['比格']='比格耶洛:BAAALgADCgcJBwAAAA==.',
['没带']='没带猫头鹰:BAAALgADCgEJAQAAAA==.',
['法西']='法西路:BAAALgAFFAIJAwAAAA==.',
['流氓']='流氓兎:BAAALgAECgcJDwAAAA==.',
['淡蛋']='淡蛋的忧伤:BAAALgAFFAQJBAAAAA==.',
['清风']='清风朗月:BAAALgAECgYJCQAAAA==.清风清风:BAAALgAECgcJCAAAAA==.',
['潘达']='潘达玛莉亚:BAAALgAECgQJBAAAAA==.',
['灬梦']='灬梦冰灬:BAAALgAFFAIJAgAAAA==.',
['熊德']='熊德:BAAALgAECgYJBgAAAA==.',
['熊熊']='熊熊来不及:BAAALgADCgkJCQAAAA==.',
['特利']='特利丝杰娜:BAABLgAFFH8HAAIDAAUJdxJiCwDCAQADAAUJdxJiCwDCAQAAAA==.',
['特立']='特立独行的猪:BAAALgADCgMJAwAAAA==.',
['狐人']='狐人小麦迪:BAAALgADCgUJBQAAAA==.',
['猎天']='猎天女:BAAALgAECgEJAQAAAA==.',
['猎杀']='猎杀新手:BAAALgAFFAEJAQAAAA==.',
['王半']='王半斤:BAAALgAECgEJAQAAAA==.',
['王大']='王大锤丶:BAAALgADCgcJDAAAAA==.',
['琉璃']='琉璃:BAAALgAECgQJBAAAAA==.',
['疯浣']='疯浣熊:BAAALgADCgEJAQAAAA==.',
['白银']='白银之灵:BAAALgADCgMJAwAAAA==.',
['皓天']='皓天心动:BAAALgAECgUJBQAAAA==.',
['稻天']='稻天盗地:BAAALgAECgMJAwAAAA==.',
['紫之']='紫之上:BAAALgADCgcJBwAAAA==.',
['绯丶']='绯丶翠:BAAALgAECgYJDAAAAA==.',
['羽薇']='羽薇:BAAALgADCgUJBQAAAA==.',
['老炮']='老炮儿:BAAALgADCgQJBAAAAA==.',
['脱战']='脱战了才假死:BAAALgAECgQJBwAAAA==.',
['花果']='花果山:BAAALgAECgUJBQAAAA==.',
['花花']='花花下的太阳:BAAALgADCgUJBQAAAA==.',
['苍炎']='苍炎之米利亚:BAAALgADCgIJAgAAAA==.',
['苏达']='苏达姬:BAAALgAECgEJAQAAAA==.',
['蓝色']='蓝色幺鸡:BAAALgAECgEJAQAAAA==.蓝色游魂:BAABLgAFFH8GAAIEAAIJthiSEAC1AAAEAAIJthiSEAC1AAAAAA==.',
['虛空']='虛空大君:BAAALgAECgcJBwAAAA==.',
['虬髯']='虬髯:BAAALgADCgEJAQAAAA==.',
['蛋总']='蛋总归来:BAAALgAECgYJBgAAAA==.',
['蛤蟆']='蛤蟆先生:BAAALgAECgMJAwAAAA==.',
['蜡笔']='蜡笔不二熊:BAAALgADCgcJBwAAAA==.',
['血酬']='血酬定律:BAAALgAECgEJAgAAAA==.',
['袴田']='袴田日向:BAACLgAFFH8HAAIOAAQJvRW3CwBOAQAOAAQJvRW3CwBOAQAuAAQKfxoAAg4ACAkUJP0LAC4DAA4ACAkUJP0LAC4DAAAA.',
['贝塔']='贝塔:BAAALgAECgMJAwAAAA==.',
['赵八']='赵八两:BAAALgAECgEJAgAAAA==.',
['路长']='路长梦短:BAABLgAECn8bAAMEAAgJVhNLPgC2AQAKAAgJag7gLADGAQAEAAcJMBJLPgC2AQAAAA==.',
['醉美']='醉美是相遇:BAABLgAFFH8FAAIMAAUJbArfBQBzAQAMAAUJbArfBQBzAQAAAA==.',
['里希']='里希:BAAALgAECgkJDQAAAA==.',
['野生']='野生的小白吐:BAAALgAECgEJAQAAAA==.',
['闪电']='闪电奔涌:BAAALgAECgQJBAAAAA==.',
['阿斯']='阿斯图利亚斯:BAAALgAFFAEJAQAAAA==.',
['陳丶']='陳丶風暴煭酒:BAAALgAECgUJBgAAAA==.',
['难德']='难德糊涂:BAAALgAECgEJAQAAAA==.',
['雁舞']='雁舞流云:BAAALgAECgkJDgAAAA==.',
['雪花']='雪花菈米:BAAALgAECgUJCgAAAA==.',
['靓仔']='靓仔麦迪:BAAALgADCgYJBwAAAA==.',
['顿吉']='顿吉:BAAALgADCgYJAQAAAA==.',
['风之']='风之彩:BAAALgADCgYJBgAAAA==.',
['飞翔']='飞翔的虚空箭:BAAALgAECgEJAQAAAA==.',
['马戏']='马戏团出来的:BAAALgAECgUJBQAAAA==.',
['骄矜']='骄矜必败:BAAALgAECgEJAQAAAA==.',
['骑士']='骑士科特:BAAALgAECgQJBAAAAA==.',
['骨龙']='骨龙牙:BAAALgAECgQJBAAAAA==.',
['高子']='高子小是天生:BAACLgAFFH8GAAIEAAIJ2yHyEgC3AAAEAAIJ2yHyEgC3AAAuAAQKfyEAAgQABwkhHzsaAGoCAAQABwkhHzsaAGoCAAAA.',
['麦乐']='麦乐送:BAAALgADCgEJAQAAAA==.',
['黄胖']='黄胖子的武僧:BAAALgAECgEJAQAAAA==.',
['龙吟']='龙吟瑶瑶:BAAALgAECgUJBgAAAA==.',
['龙血']='龙血藤:BAAALgAECgQJBAAAAA==.',
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
