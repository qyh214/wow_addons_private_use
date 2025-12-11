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
 local lookup = {'Paladin-Holy','Warrior-Protection','Warlock-Destruction','Monk-Brewmaster','Paladin-Retribution','Druid-Restoration','Shaman-Restoration','Shaman-Elemental','Paladin-Protection','Rogue-Assassination','Warrior-Fury','Priest-Holy','Hunter-BeastMastery','Druid-Balance','DeathKnight-Frost','Priest-Shadow','Shaman-Enhancement','Mage-Arcane','Warrior-Arms','Hunter-Survival',}; local provider = {region='CN',realm='塞泰克',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Antimage:BAAALAAECgYIBgAAAA==.',As='Ashestria:BAAALAAECgYICQAAAA==.',Di='Dior:BAAALAADCgYIBgAAAA==.',Gg='Ggtg:BAAALAAECgIIAgAAAA==.',Hu='Hunt:BAAALAAECgYIBgAAAA==.',Ju='Jukka:BAABLAAFFH8RAAIBAAMIFhRAHADHAAABAAMIFhRAHADHAAAAAA==.',Li='Lifengzs:BAABLAAFFH8MAAICAAYIKR69CQCmAQACAAYIKR69CQCmAQAAAA==.',Mi='Mithrandir:BAACLAAFFH8iAAICAAgIYBwWAwAXAgACAAgIYBwWAwAXAgAsAAQKfxoAAgIACAh3I/0LAA0CAAIACAh3I/0LAA0CAAAA.',Td='Td:BAAALAADCgYIBgAAAA==.',Te='Tensai:BAAALAADCgcIBwAAAA==.',Xb='Xbqnb:BAAALAADCgcIBwAAAA==.',Ya='Yangon:BAABLAAFFH8WAAIDAAYIBRhpIwCNAQADAAYIBRhpIwCNAQAAAA==.',Ze='Zero:BAAALAAECgYIBgAAAA==.',['一叶']='一叶飘零:BAAALAADCgUIBQAAAA==.',['一宠']='一宠你就笑:BAAALAAECgMIAwAAAA==.',['一点']='一点不小:BAAALAAFFAIIBAAAAA==.',['七一']='七一:BAAALAAECgcICgAAAA==.',['万能']='万能小酱油:BAABLAAFFH8VAAIEAAYILRWRCQA6AQAEAAYILRWRCQA6AQAAAA==.',['不萌']='不萌不术:BAABLAAFFH8HAAIDAAcINRZQFADnAQADAAcINRZQFADnAQAAAA==.',['东征']='东征的十字军:BAABLAAFFH8FAAIFAAMI0w/tRgB/AAAFAAMI0w/tRgB/AAAAAA==.',['丨蕾']='丨蕾絲守護丨:BAAALAAECgEIAQAAAA==.',['为了']='为了梦想飞翔:BAAALAAFFAIIAgAAAA==.',['为梦']='为梦想哈哈:BAAALAAFFAIIAgAAAA==.',['二郎']='二郎:BAAALAADCgcIBwAAAA==.',['从不']='从不熬夜:BAAALAAFFAIIAgAAAA==.',['倚栄']='倚栄慟緂:BAAALAAECggICAAAAA==.',['倪克']='倪克斯:BAAALAAECgYIBgAAAA==.',['克里']='克里斯哲别:BAAALAAECgIIAwAAAA==.',['凯塞']='凯塞多:BAABLAAFFH8HAAIGAAUIXQvsIwD8AAAGAAUIXQvsIwD8AAAAAA==.',['切尔']='切尔西的蓝:BAABLAAFFH8gAAMHAAYIEh1zCQCmAQAHAAYIEh1zCQCmAQAIAAUIBR7nHgBKAQAAAA==.',['刕磊']='刕磊掱:BAAALAAECgYIBgAAAA==.',['初阳']='初阳:BAAALAAECgcICAAAAA==.',['劲凉']='劲凉脉动:BAAALAAECgYIDwAAAA==.',['十二']='十二月的骑迹:BAAALAAECgEIAQAAAA==.',['十项']='十项全能:BAABLAAECn8XAAQFAAgIqSGxHwDzAgAFAAgIqSGxHwDzAgAJAAcIURM0LwCWAQABAAMIqhK6ZgChAAAAAA==.',['千莎']='千莎赛高:BAAALAADCgcIDQABLAAFFAgIKgAKAHwZAA==.',['卡比']='卡比亚修斯:BAABLAAFFH8IAAILAAgIpgHANwCTAAALAAgIpgHANwCTAAAAAA==.',['卤蛋']='卤蛋蛋光头头:BAAALAAECgYIBgAAAA==.卤蛋蛋棍花花:BAAALAAECgYICQAAAA==.卤蛋蛋死球球:BAAALAAFFAIIAgAAAA==.卤蛋蛋火炮炮:BAAALAAECgYIBgAAAA==.',['可爱']='可爱捏:BAAALAAECgUICAAAAA==.',['吆吆']='吆吆丁丁阔:BAAALAAECgMIAwAAAA==.',['名叫']='名叫傻馒:BAAALAAECgYICQAAAA==.',['周杰']='周杰伦:BAAALAAECgIIAgAAAA==.',['命运']='命运的铲宩官:BAAALAAECgcICgAAAA==.',['哈拉']='哈拉少:BAAALAAECgEIAQAAAA==.',['圣夜']='圣夜:BAAALAAECgYIBgAAAA==.',['坑人']='坑人的天意:BAAALAADCgUIBQAAAA==.',['夏日']='夏日青提拿铁:BAAALAAFFAIIAgAAAA==.',['夏晓']='夏晓:BAAALAAFFAIIAgAAAA==.',['夏至']='夏至晓晓:BAACLAAFFH8NAAILAAII3xzGQABaAAALAAII3xzGQABaAAAsAAQKfxoAAgsACAgHGdYbAAgCAAsACAgHGdYbAAgCAAAA.',['夜德']='夜德明:BAAALAAECgYIBgAAAA==.',['大明']='大明永乐:BAABLAAFFH8RAAIFAAYIThn2GACNAQAFAAYIThn2GACNAQAAAA==.',['大狼']='大狼狗灬:BAAALAAFFAIIBAAAAA==.',['大玉']='大玉兒:BAABLAAFFH8VAAIMAAYI6A9dGgB8AQAMAAYI6A9dGgB8AQAAAA==.',['太吓']='太吓人了:BAAALAADCgIIAgAAAA==.',['好家']='好家伙:BAAALAAECgYICgAAAA==.',['妳德']='妳德狼君:BAABLAAFFH8JAAIGAAUI+BdAGQBlAQAGAAUI+BdAGQBlAQAAAA==.',['安多']='安多米尔:BAAALAAECgYICwAAAA==.',['小飞']='小飞丶:BAAALAADCgYIBgAAAA==.',['小骚']='小骚蹄子:BAABLAAFFH8FAAIHAAQI8QiJPQCuAAAHAAQI8QiJPQCuAAAAAA==.',['屠尽']='屠尽日寇:BAABLAAFFH8eAAIEAAgIaA0oBwDfAQAEAAgIaA0oBwDfAQAAAA==.',['帕尔']='帕尔默:BAAALAAECgMIAwAAAA==.',['帮帮']='帮帮我:BAABLAAFFH8JAAINAAcIGgjZbgCEAAANAAcIGgjZbgCEAAAAAA==.',['幻云']='幻云颂哥:BAAALAAECgcIEQAAAA==.',['德財']='德財兼唄:BAAALAAECgYIDAAAAA==.',['心绪']='心绪零碎:BAAALAAECggICgAAAA==.',['快斗']='快斗:BAAALAAECgQIBAAAAA==.',['恢复']='恢复之树:BAABLAAFFH8QAAMOAAYI0RAOCQCkAQAOAAUI8BMOCQCkAQAGAAMIrBWeFQDOAAAAAA==.',['想要']='想要睡觉:BAABLAAFFH8IAAIPAAIInRrFdgBLAAAPAAIInRrFdgBLAAAAAA==.',['托呢']='托呢:BAABLAAECn8kAAILAAYI0xofaQC9AQALAAYI0xofaQC9AQAAAA==.',['找寻']='找寻答案:BAAALAAECgYIBgAAAA==.',['掱刕']='掱刕磊:BAAALAAECgYIAQAAAA==.',['斗魄']='斗魄丶僧:BAAALAAECgYIBgAAAA==.斗魄丶圣:BAAALAAECgYIBgAAAA==.斗魄丶戬:BAAALAAFFAIIAgAAAA==.斗魄丶萨:BAAALAAECgEIAQAAAA==.斗魄丶血:BAAALAAECgYICAAAAA==.',['时间']='时间在打烊:BAAALAADCgQIBAAAAA==.',['晓白']='晓白:BAAALAADCgIIAgAAAA==.',['晨惜']='晨惜惜:BAAALAADCgMIAwAAAA==.',['晨曦']='晨曦曦:BAAALAAECgIIAgAAAA==.',['暗黑']='暗黑汤圆:BAAALAADCggICAAAAA==.',['暴力']='暴力天堂:BAAALAAECgMIAwAAAA==.',['朗基']='朗基努斯:BAAALAAECgYIDQAAAA==.',['梦仍']='梦仍是一样:BAAALAAECgMIAwAAAA==.',['棋棋']='棋棋老师:BAAALAAECgIIAgAAAA==.',['椰青']='椰青冰萃美式:BAAALAAFFAIIBAAAAA==.',['樱岛']='樱岛麻衣:BAAALAAECgYICAAAAA==.',['橘汁']='橘汁:BAAALAADCgIIAgAAAA==.',['武喵']='武喵王:BAABLAAFFH8ZAAIPAAYIYhrgJQCeAQAPAAYIYhrgJQCeAQAAAA==.',['死亡']='死亡黑金属:BAAALAAECgYIBgAAAA==.',['毛团']='毛团曾经:BAABLAAECn8fAAIPAAgIeQpGUABUAQAPAAgIeQpGUABUAQAAAA==.',['永远']='永远爱果果:BAAALAAFFAMIAwAAAA==.永远的艾斯:BAAALAAECgMIAwAAAA==.',['汐汐']='汐汐酱:BAAALAAECgcIDQAAAA==.',['涵宝']='涵宝儿:BAAALAAECgUIBQAAAA==.',['火焰']='火焰飞丝:BAAALAAECgQIBAAAAA==.',['灬死']='灬死夜灬:BAAALAADCgYIBgAAAA==.',['然然']='然然:BAABLAAFFH8MAAIIAAYIaRRBHABeAQAIAAYIaRRBHABeAQAAAA==.',['爱吃']='爱吃馒头:BAAALAAECgQIBAAAAA==.',['牛不']='牛不牛:BAAALAADCgUIBQAAAA==.',['狩猎']='狩猎之花:BAAALAAECgEIAQAAAA==.',['现金']='现金银行:BAABLAAFFH8HAAIQAAIIgBQKJwBKAAAQAAIIgBQKJwBKAAAAAA==.',['琳酱']='琳酱:BAAALAAECgQIBAAAAA==.',['琴伤']='琴伤:BAAALAAFFAgIAwAAAA==.',['痞子']='痞子:BAAALAAECgYICwAAAA==.',['白狼']='白狼杰洛特:BAAALAAECgYICwAAAA==.',['白白']='白白的大蜜:BAAALAAECgUIBgAAAA==.',['白茶']='白茶丶:BAACLAAFFH8pAAIHAAYImxLtHgBkAQAHAAYImxLtHgBkAQAsAAQKfyUAAxEACAguGtcFALQBABEABwjEGNcFALQBAAcABAgSFvLDAP4AAAAA.',['砂弃']='砂弃:BAAALAAECgYIBwAAAA==.',['碳酸']='碳酸可乐怪:BAABLAAFFH8JAAISAAQIswrGPQDNAAASAAQIswrGPQDNAAAAAA==.',['笑忘']='笑忘歌丶:BAAALAAECgYICAAAAA==.',['筱筱']='筱筱术:BAAALAAECgYICAAAAA==.筱筱猎:BAAALAAECgQIBQAAAA==.',['米娜']='米娜:BAAALAADCgEIAQAAAA==.',['紫云']='紫云丶大元帅:BAACLAAFFH8GAAICAAYIGRfcDwBQAQACAAYIGRfcDwBQAQAsAAQKfxcAAxMABwgZB7oLANwAABMABwgZB7oLANwAAAsABQibA5DiAJoAAAAA.',['纓絡']='纓絡:BAAALAAECgMIAwAAAA==.',['绯红']='绯红的亚里亚:BAAALAAECgYIBgABLAAFFAQIEAASAE0eAA==.',['罗夏']='罗夏的面具:BAAALAADCgMIAwAAAA==.',['舞袖']='舞袖伊伊:BAAALAAFFAIIAgAAAA==.舞袖夕茗:BAAALAAECgYIBwAAAA==.',['花菜']='花菜:BAAALAADCgIIAgAAAA==.',['英菲']='英菲昵迪:BAAALAADCgYIBgAAAA==.',['菩提']='菩提港:BAAALAAECgUIBQAAAA==.',['萌死']='萌死了死萌:BAAALAAECgYICwAAAA==.',['落纸']='落纸雨墨:BAAALAAECgYICwAAAA==.',['葡萄']='葡萄冰萃美式:BAAALAAFFAIIAgAAAA==.',['蒙塔']='蒙塔鸡钢蛋:BAAALAAFFAIIAgAAAA==.',['蓝小']='蓝小小:BAABLAAFFH8XAAMNAAYI9BU5MAB3AQANAAYI9BU5MAB3AQAUAAEImBJaBwAAAAAAAA==.',['蓝屁']='蓝屁屁:BAAALAAFFAIIAgAAAA==.',['蓝猫']='蓝猫猫:BAABLAAFFH8VAAIPAAUI0wtTSgAKAQAPAAUI0wtTSgAKAQAAAA==.',['譕法']='譕法譕天:BAAALAADCggIDQAAAA==.',['跟风']='跟风恕丶:BAABLAAFFH8GAAIDAAYIRRbYLQBjAQADAAYIRRbYLQBjAQAAAA==.',['这河']='这河狸吗:BAAALAAECgQIBAAAAA==.',['远子']='远子:BAABLAAFFH8hAAISAAYI3R9dEwDfAQASAAYI3R9dEwDfAQAAAA==.',['迷彩']='迷彩小当家:BAAALAAFFAIIAgAAAA==.',['銀塵']='銀塵:BAAALAAECgEIAQAAAA==.',['钙奶']='钙奶饼干:BAAALAADCggICAAAAA==.',['闹不']='闹不住蘑菇:BAAALAAFFAIIAgAAAA==.',['阿拉']='阿拉巴:BAAALAADCggICAAAAA==.',['阿莱']='阿莱克斯:BAABLAAFFH8FAAIDAAIIewclawA1AAADAAIIewclawA1AAAAAA==.',['陆雪']='陆雪琪:BAAALAADCggICAAAAA==.',['隔壁']='隔壁射鸡的:BAABLAAFFH8NAAINAAUIqAwvXwDEAAANAAUIqAwvXwDEAAAAAA==.隔壁老王五号:BAAALAADCgIIAgAAAA==.',['雷丶']='雷丶风暴烈酒:BAAALAAECgYIDAAAAA==.',['霜花']='霜花:BAAALAADCgQIBAAAAA==.',['霸气']='霸气侧漏:BAAALAAFFAQIBAAAAA==.',['靈魂']='靈魂犄角:BAAALAAFFAIIBAAAAA==.',['青柑']='青柑柠檬茶:BAAALAAECggICwAAAA==.',['面包']='面包人:BAAALAAFFAIIBAAAAA==.',['韋琪']='韋琪:BAAALAAFFAMIAwAAAA==.',['风清']='风清云淡月明:BAAALAAECgYIBgAAAA==.',['风起']='风起黄昏:BAABLAAFFH8SAAMLAAMIdh7bFAAiAQALAAMIdh7bFAAiAQATAAEIoB9PBwBdAAAAAA==.',['馨梦']='馨梦:BAACLAAFFH8RAAIFAAUIpxOcKAA2AQAFAAUIpxOcKAA2AQAsAAQKfxYAAgUACAimH4wSAHoCAAUACAimH4wSAHoCAAAA.',['魅影']='魅影毛团:BAAALAAECggIEgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end