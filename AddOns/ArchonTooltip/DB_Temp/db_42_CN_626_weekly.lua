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
 local lookup = {'Paladin-Retribution','Mage-Frost','Mage-Fire','Rogue-Assassination','Paladin-Protection','Paladin-Holy','Priest-Discipline','Priest-Holy','DeathKnight-Frost','DeathKnight-Unholy','Monk-Mistweaver','Shaman-Restoration','Priest-Shadow','DemonHunter-Havoc','Hunter-BeastMastery','Warrior-Arms','Shaman-Enhancement','Mage-Arcane','Hunter-Marksmanship','Druid-Feral',}; local provider = {region='CN',realm='塞泰克',name='CN',type='weekly',zone=42,date='2025-08-08',data={Di='Disenchanted:BAAAKgAECgYICQAAAA==.',Sv='Sven:BAABKgAFFH8IAAIBAAgIuRUlCQAwAgABAAgIuRUlCQAwAgAAAA==.',Te='Tensai:BAAAKgAECgEIAQAAAA==.',Wo='Wokaokaokao:BAAAKgADCgQIBAAAAA==.',['一叶']='一叶飘零:BAAAKgAFFAEIBAAAAA==.',['七一']='七一:BAAAKgAECgMIAwAAAA==.',['上上']='上上签无敌:BAABKgAECn8YAAMCAAgIEhCzYQDmAAADAAcIrAYiXwD2AAACAAgI2A+zYQDmAAAAAA==.',['与鱼']='与鱼:BAAAKgAECgUIBQAAAA==.',['九宝']='九宝琉璃塔:BAAAKgAFFAQIBAAAAA==.',['云渡']='云渡:BAAAKgADCgQIBAAAAA==.',['伦巴']='伦巴:BAABKgAFFH8JAAIEAAYIKQbREwAVAQAEAAYIKQbREwAVAQAAAA==.',['似熊']='似熊非熊:BAAAKgADCgQIBAAAAA==.',['八角']='八角玄冰草:BAAAKgAFFAQIBAAAAA==.',['冰摇']='冰摇黑加仑:BAAAKgAECgEIAQAAAA==.',['凤凰']='凤凰木:BAAAKgAECggICAAAAA==.',['凯塞']='凯塞多:BAAAKgADCggICAAAAA==.',['切尔']='切尔西的蓝:BAAAKgAECgcICgAAAA==.',['刕磊']='刕磊掱:BAAAKgAECggIDgAAAA==.',['劲凉']='劲凉脉动:BAAAKgAECgYIBgAAAA==.',['勇者']='勇者无敌:BAAAKgAFFAEIAwAAAA==.',['十项']='十项全能:BAABKgAFFH8QAAQFAAgIFhI5DwANAQABAAUIGRGbFgA5AQAFAAQIJhQ5DwANAQAGAAQIFhRtCgC4AAAAAA==.',['卤蛋']='卤蛋蛋光头头:BAAAKgAECgEIAQAAAA==.卤蛋蛋棍花花:BAAAKgAECgUIBQAAAA==.',['厚浪']='厚浪:BAAAKgAECgMIAwAAAA==.',['双采']='双采德:BAAAKgAFFAEIAQAAAA==.',['吆吆']='吆吆钉钉阔:BAABKgAECn8YAAMHAAcIqQ2hPAD6AAAHAAYI2Q+hPAD6AAAIAAUI9gUxXwCaAAAAAA==.',['哥布']='哥布林突击:BAAAKgAFFAEIAQAAAA==.',['喵喵']='喵喵的烘焙坊:BAAAKgAECggIDwAAAA==.喵喵的面包店:BAABKgAECn8aAAIBAAgI6iMpIQCVAgABAAgI6iMpIQCVAgAAAA==.',['嗜血']='嗜血玫瑰:BAAAKgAECgMIAwAAAA==.',['圣痕']='圣痕不灭:BAAAKgADCgMIAwAAAA==.圣痕乄追星:BAAAKgADCggICQAAAA==.',['坏家']='坏家伙:BAAAKgAFFAMIAwAAAA==.',['坐忘']='坐忘道:BAAAKgAFFAQIBAAAAA==.',['复活']='复活之吻:BAAAKgAECgEIAQAAAA==.',['夜德']='夜德明:BAABKgAECn8YAAMJAAgIFhf7DwCmAQAJAAgI2hX7DwCmAQAKAAEIRBy0oABTAAAAAA==.',['大明']='大明永乐:BAACKgAFFH8GAAIBAAMIVRIYTQDVAAABAAMIVRIYTQDVAAAqAAQKfxQAAgEACAhFGvQ9AAoCAAEACAhFGvQ9AAoCAAAA.',['大玉']='大玉兒:BAAAKgAFFAIIAgAAAA==.',['天道']='天道承负:BAABKgAFFH8IAAILAAQI8Q8GIAClAAALAAQI8Q8GIAClAAABKgAFFAgIDAAMAEUTAA==.',['好家']='好家伙:BAAAKgAECgMIAwAAAA==.',['小样']='小样别瞎闹:BAAAKgAECggIEAAAAA==.',['尼古']='尼古拉斯凯撒:BAAAKgADCgQIBAAAAA==.',['左之']='左之丶神韵:BAABKgAFFH8IAAIFAAQISQkSEACFAAAFAAQISQkSEACFAAAAAA==.',['帕尔']='帕尔默:BAAAKgAECgcIBwAAAA==.',['幽林']='幽林雪灵:BAAAKgADCgQIBAAAAA==.',['心绪']='心绪零碎:BAABKgAFFH8FAAINAAUIXyDxCAB4AQANAAUIXyDxCAB4AQAAAA==.',['恶魔']='恶魔在人间:BAABKgAFFH8JAAIOAAUIkxw6DADCAQAOAAUIkxw6DADCAQAAAA==.',['憨蛋']='憨蛋一号:BAAAKgADCggIDgAAAA==.',['我德']='我德行天下:BAAAKgAECgQIBAAAAA==.',['托尼']='托尼丶克罗斯:BAAAKgAFFAEIAQAAAA==.',['日落']='日落在山边:BAAAKgAECgYIDAAAAA==.',['晓晓']='晓晓飞雪儿:BAABKgAFFH8GAAIPAAYIAA3MGAA1AQAPAAYIAA3MGAA1AQAAAA==.',['晨嘻']='晨嘻嘻:BAAAKgAECgEIAQAAAA==.',['晨惜']='晨惜惜:BAAAKgAECggIEQAAAA==.',['晨曦']='晨曦曦:BAAAKgAECgIIAgAAAA==.',['有丶']='有丶射:BAAAKgAECgcIBwAAAA==.',['柠檬']='柠檬柚子茶:BAAAKgAECgIIAgAAAA==.',['梦境']='梦境掌控者:BAABKgAFFH8JAAIBAAYINBdiSwDYAAABAAYINBdiSwDYAAAAAA==.',['武喵']='武喵王:BAAAKgAECgQIBAAAAA==.',['毛团']='毛团曾经:BAAAKgADCggICgAAAA==.',['水一']='水一样的沐沐:BAAAKgAECgEIAQAAAA==.',['没名']='没名字啊:BAAAKgAECggICQAAAA==.',['温州']='温州第一深情:BAABKgAFFH8YAAIOAAgIsB7LAwCeAgAOAAgIsB7LAwCeAgAAAA==.',['火焰']='火焰飞丝:BAAAKgAECgIIAwAAAA==.',['灵玄']='灵玄:BAAAKgAECgcIBwAAAA==.',['烙戈']='烙戈什:BAABKgAFFH8IAAIQAAgI9R0OCgBrAQAQAAgI9R0OCgBrAQAAAA==.',['燕燕']='燕燕酱:BAAAKgADCgEIAQAAAA==.',['爱与']='爱与雷霆:BAAAKgADCggICAAAAA==.',['爱吃']='爱吃馒头:BAAAKgAFFAQIBAAAAA==.',['狩猎']='狩猎之花:BAAAKgAECgIIAgAAAA==.',['玄绯']='玄绯花月:BAAAKgAFFAQIBAAAAA==.',['玛莉']='玛莉伊莎:BAAAKgAECgcICgAAAA==.',['现金']='现金银行:BAAAKgAECgcIDQAAAA==.',['琳酱']='琳酱:BAABKgAFFH8GAAIHAAMIGAsZDwCOAAAHAAMIGAsZDwCOAAAAAA==.',['白狼']='白狼杰洛特:BAAAKgAECggICgAAAA==.',['白茶']='白茶丶:BAACKgAFFH8QAAMMAAMI2Rk7JADmAAAMAAMI2Rk7JADmAAARAAMIhg/PCQDIAAAqAAQKfyQAAwwACAi3ER9DAGsBAAwACAi3ER9DAGsBABEABQiFE6Q6APQAAAAA.',['磊掱']='磊掱刕:BAAAKgAECgcICAAAAA==.',['竹影']='竹影丶:BAAAKgADCggICwAAAA==.',['笑忘']='笑忘歌丶:BAABKgAECn8oAAIBAAgI1Bk8QwD4AQABAAgI1Bk8QwD4AQAAAA==.',['舞袖']='舞袖伊伊:BAAAKgAECgYICgAAAA==.舞袖夕茗:BAABKgAECn8kAAICAAgIjx+vDABzAgACAAgIjx+vDABzAgAAAA==.',['英菲']='英菲昵迪:BAAAKgAECgUIBQAAAA==.',['蒙塔']='蒙塔鸡钢蛋:BAAAKgAFFAgIAgAAAA==.',['蓝小']='蓝小小:BAAAKgAFFAIIAgAAAA==.',['蓝猫']='蓝猫猫:BAABKgAFFH8GAAIKAAMIRhPkLQDXAAAKAAMIRhPkLQDXAAAAAA==.',['蛮蛮']='蛮蛮鱼:BAAAKgADCggICAAAAA==.',['迅捷']='迅捷女王缰绳:BAAAKgAECgQIBAAAAA==.',['远子']='远子:BAABKgAECn8VAAISAAgIMx+3BQAlAgASAAgIMx+3BQAlAgAAAA==.',['迷彩']='迷彩小当家:BAAAKgADCgIIAgAAAA==.',['遗弃']='遗弃紫玫瑰:BAABKgAFFH8MAAMDAAQIkhSoHgDbAAADAAQI/Q6oHgDbAAACAAQIqhAgGgCsAAAAAA==.',['银色']='银色百合:BAAAKgAECggICwAAAA==.',['长大']='长大上大学:BAAAKgAECgMIAwAAAA==.',['隔壁']='隔壁射鸡的:BAABKgAFFH8MAAMPAAYIZxzoGADuAAATAAQIYCJNGgAaAQAPAAQIXRfoGADuAAAAAA==.',['静电']='静电天鹅绒:BAAAKgAECgcICgAAAA==.',['非法']='非法存在:BAAAKgADCggICAAAAA==.',['风一']='风一样的木木:BAAAKgADCgEIAQAAAA==.',['风起']='风起黄昏:BAAAKgAFFAYIAgAAAA==.',['馨梦']='馨梦:BAACKgAFFH8SAAIBAAYIyB7aEgDFAQABAAYIyB7aEgDFAQAqAAQKfxgAAgEACAi6FMllAJEBAAEACAi6FMllAJEBAAAA.',['马库']='马库斯之器:BAAAKgADCggICAAAAA==.',['高岭']='高岭之花:BAABKgAECn8ZAAIUAAgIZxbRDAC3AQAUAAgIZxbRDAC3AQAAAA==.',['高戈']='高戈罗克:BAAAKgADCgQIBAAAAA==.',['魅影']='魅影毛团:BAAAKgAECggICwAAAA==.',['黄昏']='黄昏:BAABKgAFFH8GAAIQAAIIlyA2CwDBAAAQAAIIlyA2CwDBAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end