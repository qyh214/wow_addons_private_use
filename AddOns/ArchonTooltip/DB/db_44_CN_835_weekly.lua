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
 local lookup = {'Hunter-BeastMastery','Paladin-Protection','Evoker-Devastation','Evoker-Augmentation','DeathKnight-Frost','DeathKnight-Blood','Warrior-Fury','Warrior-Protection','Mage-Frost','Paladin-Retribution','Paladin-Holy','Druid-Balance','Druid-Restoration','Priest-Holy','DemonHunter-Havoc','Monk-Windwalker','Warlock-Destruction','Warlock-Demonology','Hunter-Marksmanship','Shaman-Restoration','Unknown-Unknown','Evoker-Preservation','Priest-Discipline','Shaman-Elemental','Mage-Arcane',}; local provider = {region='CN',realm='达克萨隆',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Artemis:BAABLAAFFH8QAAIBAAUIKBITUQAMAQABAAUIKBITUQAMAQAAAA==.',Be='Bee:BAAALAAFFAIIAgAAAA==.',Br='Bride:BAAALAADCgYIBgAAAA==.',Cg='Cgmmi:BAABLAAFFH8FAAICAAMIjB2IDgCZAAACAAMIjB2IDgCZAAAAAA==.',Li='Lillness:BAACLAAFFH8IAAMDAAMI3BcBEADfAAADAAMI3BcBEADfAAAEAAEIVxWzCwBLAAAsAAQKfxwAAgMACAhBHvcZAE8CAAMACAhBHvcZAE8CAAEsAAUUCAgOAAMAdiUA.',Ma='Manjusaka:BAABLAAFFH8FAAMFAAMIkA1eWACcAAAFAAIIMhReWACcAAAGAAMI7gDfFABmAAAAAA==.',Pa='Panxxer:BAAALAAECgQIBAAAAA==.',Sb='Sbavc:BAACLAAFFH8gAAMHAAYIHQv+LQDsAAAHAAQIuw3+LQDsAAAIAAQI0AbHHgCHAAAsAAQKfyoAAwcABwg0Gbc5AHMBAAcABgjCHLc5AHMBAAgABwjDD/VGAGYBAAAA.',Sn='Snakiehollic:BAABLAAFFH8GAAIJAAYIugGmHQA2AAAJAAYIugGmHQA2AAAAAA==.',Va='Valeera:BAAALAAECgUIBQAAAA==.',['万丈']='万丈红尘:BAAALAAECgIIAgAAAA==.',['不玩']='不玩奶萨:BAAALAAECggIAwAAAA==.',['不闻']='不闻不问:BAAALAADCgQIBAAAAA==.',['丨丨']='丨丨:BAAALAADCgEIAQAAAA==.',['丩乄']='丩乄亅乊卩:BAABLAAFFH8GAAIDAAII7Qt3IQA3AAADAAII7Qt3IQA3AAAAAA==.',['丶拔']='丶拔帝倚天灬:BAAALAAECgcICAAAAA==.',['丶无']='丶无始无终:BAAALAAECgYIBgAAAA==.',['丶酋']='丶酋长:BAAALAAECgEIAQAAAA==.',['丶阿']='丶阿宝:BAAALAADCggICAAAAA==.',['为师']='为师略懂拳脚:BAAALAAECgEIAQAAAA==.',['九黎']='九黎蚩尤:BAAALAAECggIEAAAAA==.',['仙鹤']='仙鹤飞翔:BAAALAAECgYIEAAAAA==.',['伊悧']='伊悧丹:BAAALAAECgYIBgAAAA==.',['傻馒']='傻馒:BAAALAAECgYIBgAAAA==.',['冰中']='冰中的火焰:BAACLAAFFH8IAAIHAAIIYAsiQACMAAAHAAIIYAsiQACMAAAsAAQKfxwAAwcABgiZG+VYAOcBAAcABghfG+VYAOcBAAgAAwiRFORxAMEAAAAA.',['别雅']='别雅闲君:BAAALAAECgMIAwAAAA==.',['十香']='十香:BAABLAAFFH8GAAIIAAMIvA/mEgC3AAAIAAMIvA/mEgC3AAAAAA==.',['卡布']='卡布奇诺:BAAALAAFFAYIAgAAAA==.',['吉安']='吉安那:BAACLAAFFH8JAAMKAAMI1hJ4RgCBAAAKAAMIJxF4RgCBAAACAAIIQg61HAAxAAAsAAQKfxUABAsABwhdA6pXAPQAAAsABwhdA6pXAPQAAAIABAimFJQsALoAAAoAAghJEv7CAHUAAAAA.',['向日']='向日葵的寄托:BAAALAADCggICAAAAA==.',['哈哈']='哈哈不咳了:BAAALAAECgYIEgAAAA==.',['啊酷']='啊酷呐玛塔塔:BAAALAAFFAIIAgAAAA==.',['嗜血']='嗜血蚂蚁:BAAALAAECgQIBAAAAA==.',['嘿眼']='嘿眼圈:BAAALAAECggICAAAAA==.',['四系']='四系乃:BAAALAAFFAIIAgAAAA==.',['圣光']='圣光喵喵:BAAALAADCgYIBgAAAA==.',['坠明']='坠明:BAAALAAFFAIIBAAAAA==.',['壹贰']='壹贰叁:BAAALAAECgYIBgAAAA==.',['夏面']='夏面给你吃:BAAALAAFFAEIAQAAAA==.',['夜妈']='夜妈妈:BAAALAAFFAIIAgAAAA==.',['夜幕']='夜幕骑士:BAABLAAECn8WAAIFAAcIhhGvTABfAQAFAAcIhhGvTABfAQAAAA==.',['大熊']='大熊妹纸:BAABLAAFFH8MAAMMAAYImgNcHQDjAAAMAAYImgNcHQDjAAANAAIIIhN4PwB1AAAAAA==.',['天灾']='天灾:BAAALAAECgUIBQAAAA==.',['宇丙']='宇丙火长弓:BAAALAAECgcIBwAAAA==.',['寂寞']='寂寞的拾叁:BAAALAAECgMIAwAAAA==.',['寒冰']='寒冰新星:BAAALAADCgMIBQAAAA==.',['小丶']='小丶旋风:BAAALAAECgYIBgAAAA==.',['小红']='小红叶:BAAALAAFFAIIBAAAAA==.',['已老']='已老实:BAAALAAECgYIDwAAAA==.',['希尔']='希尔瓦男斯:BAAALAAECgIIAgAAAA==.',['帕瓦']='帕瓦:BAAALAAFFAIIAgAAAA==.',['慕斯']='慕斯泡:BAABLAAFFH8MAAIOAAYIyxDMGgB6AQAOAAYIyxDMGgB6AQAAAA==.',['我看']='我看好你喔:BAAALAAECgIIAgAAAA==.',['抹茶']='抹茶拿铁:BAAALAAFFAIIAgAAAA==.',['摩卡']='摩卡星冰乐:BAAALAAECgYIDAAAAA==.',['散花']='散花礼弥:BAAALAAFFAEIAQAAAA==.',['无始']='无始无终:BAABLAAFFH8GAAIPAAYITRk6BgA5AgAPAAYITRk6BgA5AgABLAAFFAgINgAQABIaAA==.',['无尽']='无尽的狩猎:BAAALAAECgIIAgAAAA==.',['星何']='星何滚烫:BAABLAAFFH8IAAIRAAYI2wFhRgCwAAARAAYI2wFhRgCwAAAAAA==.',['暗色']='暗色救赎:BAAALAADCgcIBwAAAA==.',['暴走']='暴走的捡漏王:BAABLAAFFH8SAAMKAAQIDhB6NwDHAAAKAAQIDhB6NwDHAAACAAEIzwHBIgAlAAAAAA==.',['月光']='月光舞夜:BAAALAAECgIIAgAAAA==.',['有你']='有你不寂寞:BAAALAAECgcIDwAAAA==.',['朵喵']='朵喵喵丶:BAABLAAFFH8UAAIBAAYIQhuaIwClAQABAAYIQhuaIwClAQAAAA==.',['梦之']='梦之砮:BAAALAAFFAIIAgAAAA==.',['梦玉']='梦玉挲:BAAALAAECgMIAwAAAA==.',['死亡']='死亡之翼:BAAALAAFFAIIAgAAAA==.',['水中']='水中的火焰:BAABLAAFFH8GAAMRAAII5gxGSQCMAAARAAII5gxGSQCMAAASAAEIQQUhLwBEAAAAAA==.',['沙耶']='沙耶丶:BAAALAAECggIDQAAAA==.',['沫阳']='沫阳:BAAALAAECgIIAgAAAA==.',['洋河']='洋河吴彦祖:BAAALAAECggIEgAAAA==.',['浩劫']='浩劫:BAAALAAECgYIBgAAAA==.',['游戏']='游戏菜鸟:BAAALAADCgMIAwAAAA==.',['激光']='激光剑:BAAALAAECgYIBgAAAA==.',['火山']='火山灰:BAABLAAECn8eAAMBAAgI2hkMZgAPAgABAAgIwRgMZgAPAgATAAgIgRPRQQCvAQAAAA==.',['灬阿']='灬阿蒙灬:BAAALAAECggICAAAAA==.',['灰烬']='灰烬之后:BAAALAADCgIIAgAAAA==.',['熊猫']='熊猫吃竹子:BAAALAAFFAIIAgAAAA==.熊猫吃粽:BAAALAAECgUIBQAAAA==.熊猫狂萨:BAABLAAFFH8QAAIUAAIISRSQQwB7AAAUAAIISRSQQwB7AAAAAA==.',['牦牛']='牦牛:BAAALAAECgYIEAAAAA==.',['牵芊']='牵芊公主:BAAALAAFFAIIBAAAAA==.',['狂战']='狂战:BAAALAADCggICAAAAA==.',['狂毛']='狂毛小怪:BAAALAAFFAIIAgAAAA==.',['猪儿']='猪儿虫:BAAALAAFFAIIAgAAAA==.',['玄牝']='玄牝之门:BAABLAAFFH8GAAIKAAQIgBL3DwBHAQAKAAQIgBL3DwBHAQAAAA==.',['玉之']='玉之砮:BAAALAAECgUIBgAAAA==.',['玛法']='玛法灬里奥:BAAALAAECgEIAQAAAA==.',['瑪琉']='瑪琉染柒:BAABLAAFFH8IAAIRAAgIdiC7BQCmAgARAAgIdiC7BQCmAgAAAA==.',['生椰']='生椰拿铁:BAAALAAECgQIBAAAAA==.',['白石']='白石麻衣:BAAALAAECgEIAQAAAA==.',['皂丨']='皂丨皂:BAAALAADCgEIAQAAAA==.',['简单']='简单点:BAAALAAECggIEAAAAA==.',['红丶']='红丶枣:BAAALAAECgYICQAAAA==.',['红叶']='红叶:BAABLAAFFH8vAAIPAAYIaxpIFwCwAQAPAAYIaxpIFwCwAQAAAA==.',['纯爱']='纯爱骑士:BAABLAAECn8WAAIKAAgI+R5KKgDIAgAKAAgI+R5KKgDIAgAAAA==.',['给你']='给你一大棒:BAABLAAFFH8WAAIBAAYIARwyHADDAQABAAYIARwyHADDAQAAAA==.',['老流']='老流氓丶:BAABLAAFFH8JAAIGAAYIRQvfDQAqAQAGAAYIRQvfDQAqAQAAAA==.',['胡豆']='胡豆豆:BAAALAAECgYIDgAAAA==.',['芷兮']='芷兮丶:BAABLAAFFH8SAAILAAYIAR3rCAD7AQALAAYIAR3rCAD7AQABLAAFFAYIFAABAEIbAA==.',['苍雪']='苍雪:BAABLAAECn8ZAAIPAAcIgR3kRwBKAgAPAAcIgR3kRwBKAgAAAA==.',['苦酒']='苦酒折柳:BAAALAAECgEIAQAAAA==.',['菲列']='菲列特莉加:BAAALAADCgMIAgAAAA==.',['萌譁']='萌譁:BAAALAAFFAIIAgAAAA==.',['萨麟']='萨麟穆:BAAALAADCgcIBwAAAA==.',['落地']='落地还钱:BAABLAAFFH8FAAIKAAIIZBYEWABLAAAKAAIIZBYEWABLAAABLAAFFAgIBAAVAAAAAA==.',['落霞']='落霞有个小慕:BAABLAAFFH8UAAIFAAgInx4/BQCsAgAFAAgInx4/BQCsAgAAAA==.',['著名']='著名街溜子:BAAALAAECgYIDgAAAA==.',['虫二']='虫二:BAAALAAECgYIBgAAAA==.',['裁决']='裁决:BAAALAAFFAIIBAAAAA==.',['诺格']='诺格弗格:BAAALAAECggICAAAAA==.',['运小']='运小喵:BAAALAAECgEIAQAAAA==.',['这一']='这一端的小猎:BAAALAAECgMIBAAAAA==.',['远山']='远山曲:BAEBLAAFFH86AAMWAAgI/xrrAwDjAQAWAAcI1B3rAwDjAQAEAAYI6hh/BACeAQABLAAFFAYIBgAXAP8QAA==.',['通碧']='通碧:BAAALAAECgYIBgAAAA==.',['邪能']='邪能之主:BAAALAAECggIEQAAAA==.',['醉酒']='醉酒狂暴:BAAALAAECgUIBgAAAA==.',['野蛮']='野蛮婆娘:BAAALAAECgYIDAAAAA==.',['钟意']='钟意:BAAALAAFFAIIAgAAAA==.',['阐释']='阐释者:BAABLAAFFH8SAAIYAAYIECFlDQDcAQAYAAYIECFlDQDcAQAAAA==.',['阴险']='阴险的蔡:BAAALAAECggIDwAAAA==.',['阿赖']='阿赖耶识:BAABLAAFFH8GAAMUAAYIbxLWKgAQAQAUAAUI7RLWKgAQAQAYAAEIMg2xQwBFAAAAAA==.',['阿达']='阿达西买买提:BAAALAAECgYIDQAAAA==.',['雪灬']='雪灬圣光:BAAALAAECgYIBgAAAA==.',['風行']='風行者:BAAALAAFFAIIAgAAAA==.',['飒霖']='飒霖牧:BAAALAADCgEIAQAAAA==.',['飛廉']='飛廉:BAAALAAECgYICQAAAA==.',['魔法']='魔法事:BAAALAAECgIIAgAAAA==.',['魔魂']='魔魂恶魄:BAACLAAFFH8aAAMJAAYITSN2AQAKAgAJAAYIcCF2AQAKAgAZAAIIBxlSUwBIAAAsAAQKfy4AAwkACAg5IzsHACADAAkACAiuIjsHACADABkACAjnF+cTAA4CAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end