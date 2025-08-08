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
 local lookup = {'Monk-Mistweaver','Monk-Windwalker','DemonHunter-Havoc','Warrior-Fury','DeathKnight-Unholy','DeathKnight-Frost','DeathKnight-Blood','Paladin-Retribution','Mage-Arcane','Shaman-Restoration','Shaman-Elemental','Druid-Restoration','Priest-Discipline','Rogue-Outlaw','Rogue-Subtlety','Druid-Balance','Hunter-BeastMastery','Mage-Fire','Rogue-Assassination','DemonHunter-Vengeance','Warrior-Protection','Warrior-Arms','Paladin-Protection','Paladin-Holy','Hunter-Marksmanship','Warlock-Destruction','Shaman-Enhancement','Mage-Frost','Evoker-Devastation','Evoker-Preservation','Priest-Holy','Druid-Feral','Warlock-Demonology','Priest-Shadow','Unknown-Unknown','Monk-Brewmaster',}; local provider = {region='CN',realm='阿拉索',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ac='Achaser:BAAAKgAFFAUIAwAAAA==.',Al='Alexanderthe:BAAAKgADCgYIBgAAAA==.',An='Angelamerkel:BAABKgAFFH8yAAMBAAgIQxlmAwAbAgABAAgIQxlmAwAbAgACAAQIVhJnEwDIAAAAAA==.',Ch='Chaneler:BAAAKgAECggIDAAAAA==.',Da='Davinci:BAABKgAFFH8QAAIDAAYIgBlEEwBgAQADAAYIgBlEEwBgAQAAAA==.',De='Deen:BAAAKgAECgMIAwAAAA==.',Dr='Drakepower:BAAAKgAECggICAAAAA==.Draketalon:BAAAKgAECggICAAAAA==.',En='Eni:BAAAKgAECgQIBAAAAA==.',Fe='Feisca:BAAAKgAECgIIAgAAAA==.',Ge='Geminiice:BAAAKgAFFAcIAgAAAA==.',Gh='Ghorn:BAABKgAFFH8JAAIDAAMIVSHMGwAhAQADAAMIVSHMGwAhAQAAAA==.Ghostday:BAAAKgADCgMIAwAAAA==.',Gu='Gunmen:BAABKgAFFH8GAAIEAAYIwRCbDwBbAQAEAAYIwRCbDwBbAQAAAA==.Gunpla:BAABKgAECn8lAAQFAAgIuhXhRQBaAQAFAAcI0hThRQBaAQAGAAYILRUZFwAqAQAHAAgIAAxtJwAOAQAAAA==.',Ho='Holylight:BAACKgAFFH8RAAIIAAQIYSXwJwBIAQAIAAQIYSXwJwBIAQAqAAQKfxYAAggACAgiJkUNANsCAAgACAgiJkUNANsCAAAA.',In='Infotv:BAABKgAFFH8HAAIJAAQIDBbeIwDTAAAJAAQIDBbeIwDTAAAAAA==.',Ju='Junmoxiaodk:BAABKgAFFH8FAAIFAAMI2wowOgC0AAAFAAMI2wowOgC0AAAAAA==.',Ka='Kakathy:BAABKgAFFH8KAAMKAAYIew3qFAAxAQAKAAYIew3qFAAxAQALAAQI5RrxDADGAAAAAA==.Kami:BAAAKgADCgQIBAAAAA==.Kandr:BAABKgAFFH8FAAIMAAUIxxeiDQA0AQAMAAUIxxeiDQA0AQAAAA==.',Ki='Kilin:BAAAKgAECgQIBAAAAA==.',Le='Legendseeker:BAAAKgAFFAcIAwAAAA==.',Lu='Luckylin:BAAAKgAECgIIAwAAAA==.Lunara:BAAAKgAFFAgIBAAAAA==.',Me='Mercyou:BAAAKgAFFAMIAwAAAA==.Mercyu:BAABKgAFFH8JAAINAAMIlQ4ZHwCnAAANAAMIlQ4ZHwCnAAAAAA==.',Mi='Misskidney:BAACKgAFFH8zAAMOAAQI3xhUAwDtAAAOAAQI3xhUAwDtAAAPAAMIEBOFCADoAAAqAAQKfyoAAw8ACAgIHacJAE8CAA8ACAgIHacJAE8CAA4ABAjnDdwSAM4AAAAA.',Mo='Moonsaber:BAAAKgADCggICAAAAA==.',Na='Naowh:BAABKgAFFH8IAAIDAAQIWhrCFQDrAAADAAQIWhrCFQDrAAAAAA==.',Ne='Nene:BAAAKgADCggICAAAAA==.',Pa='Paladinlpc:BAAAKgAFFAQIBAAAAA==.Panda:BAAAKgAFFAIIAgAAAA==.Pandawoman:BAAAKgAECgQICAAAAA==.',Pr='Prinsophia:BAAAKgAECgIIAgAAAA==.',Re='Reid:BAABKgAFFH8IAAIIAAMI4QUhMgCZAAAIAAMI4QUhMgCZAAAAAA==.',Ro='Rockin:BAABKgAFFH8LAAMLAAQIShdFCQDkAAALAAQIShdFCQDkAAAKAAQIHhpyKgDNAAAAAA==.',Se='Sevenr:BAAAKgADCgYIBgAAAA==.',So='Softywywinch:BAAAKgAECgYIBgAAAA==.',St='Stepphy:BAABKgAFFH8IAAIKAAgI9haeAwA1AgAKAAgI9haeAwA1AgAAAA==.',Te='Tears:BAAAKgAECgIIAgAAAA==.',Ti='Timberlake:BAABKgAECn8WAAIIAAgI+SGuJgBlAgAIAAgI+SGuJgBlAgAAAA==.',Wi='Winng:BAACKgAFFH8IAAMQAAQIiRisDwD8AAAQAAQIiRisDwD8AAAMAAQITAsxJgCNAAAqAAQKfx4AAhAACAgSGuUpAAoCABAACAgSGuUpAAoCAAEqAAUUCAgqABEAIyAA.',Yo='Yool:BAABKgAFFH8GAAIIAAYIZRh6FgCoAQAIAAYIZRh6FgCoAQAAAA==.',['一代']='一代宗师:BAAAKgAECggIDgAAAA==.',['一刀']='一刀戳:BAAAKgAFFAMIBAAAAA==.',['一圣']='一圣王一:BAABKgAFFH8aAAIIAAUI9h9JHADxAAAIAAUI9h9JHADxAAAAAA==.',['一抹']='一抹情肆意:BAAAKgAFFAMIAwAAAA==.',['一路']='一路生花:BAAAKgADCggICAAAAA==.',['一邪']='一邪神一:BAAAKgAFFAMIAwAAAA==.',['三修']='三修神棍:BAABKgAFFH8QAAISAAYI4hQaBgCiAQASAAYI4hQaBgCiAQAAAA==.',['三四']='三四层楼甘高:BAAAKgAECggICAAAAA==.',['三藩']='三藩市:BAAAKgAFFAgIAQAAAA==.',['上帝']='上帝之宠:BAAAKgAECgYICAAAAA==.',['东方']='东方恒飞扬:BAAAKgAECgYIEwAAAA==.东方沐瀧:BAAAKgAECgQICQAAAA==.',['东门']='东门:BAAAKgAECgMIAwAAAA==.',['两板']='两板斧:BAABKgAFFH8LAAIIAAMIIBg5RQDkAAAIAAMIIBg5RQDkAAAAAA==.',['丨暗']='丨暗雪蓝痕丨:BAAAKgADCgIIAgAAAA==.',['丨柚']='丨柚如何丶:BAABKgAFFH8SAAITAAYIWyWJAgCeAQATAAYIWyWJAgCeAQABKgAFFAgIDQAFAHkKAA==.',['丶拉']='丶拉斐尔:BAAAKgAECgcIBwAAAA==.',['丶玛']='丶玛奇朵:BAAAKgAECgcIBwAAAA==.',['丶西']='丶西瓜粥:BAAAKgAFFAIIAgAAAA==.',['丶邪']='丶邪能灰烬:BAAAKgAECgIIAgAAAA==.',['丷噜']='丷噜噜:BAAAKgAECgYIDQAAAA==.丷噜班:BAAAKgAECgUIBQAAAA==.',['主攻']='主攻下三路:BAACKgAFFH8NAAITAAYI8RpFDACIAQATAAYI8RpFDACIAQAqAAQKfxUAAhMACAiOHkYLAFECABMACAiOHkYLAFECAAAA.',['丽秋']='丽秋:BAAAKgADCggIDgAAAA==.',['丿无']='丿无法沟通:BAAAKgAECgYIBgABKgAECggIGAABAM8UAA==.',['九星']='九星飞伏:BAAAKgAECgMIAgAAAA==.',['二十']='二十娭毑:BAAAKgAECgYICAAAAA==.',['云变']='云变神:BAAAKgADCgIIAgAAAA==.',['云舒']='云舒丶黑锋:BAABKgAFFH8OAAIFAAQIEB2NKADrAAAFAAQIEB2NKADrAAAAAA==.',['井芹']='井芹仁菜:BAAAKgAECggICAAAAA==.',['仲系']='仲系小明:BAAAKgADCgYIBgAAAA==.',['伊萨']='伊萨洛伊:BAABKgAFFH8MAAMUAAYI0xTqCgD9AAADAAYI8xP5FgBDAQAUAAYIDQ3qCgD9AAAAAA==.',['优雅']='优雅的小圈圈:BAAAKgAFFAQIBAAAAA==.',['会功']='会功夫的猫:BAAAKgADCggICAAAAA==.',['伦琴']='伦琴:BAAAKgADCggIDQAAAA==.',['伴我']='伴我乄同行:BAAAKgAECgcIBgAAAA==.',['何田']='何田田丶:BAAAKgAECgEIAQAAAA==.',['你好']='你好棒:BAAAKgAECgEIAQAAAA==.',['依然']='依然:BAAAKgAECgYICgAAAA==.',['侦测']='侦测到在途的:BAABKgAFFH8OAAIIAAQI4Bx6PQD5AAAIAAQI4Bx6PQD5AAAAAA==.',['侵略']='侵略督军:BAAAKgAFFAMIAwAAAA==.',['信仰']='信仰战神:BAACKgAFFH8PAAMEAAMI0RIzIQDPAAAEAAMIKxIzIQDPAAAVAAIIFhFMEgBqAAAqAAQKfzIABAQACAhoHr8TADsCAAQACAjZHL8TADsCABUABQiuF00cAFEBABYAAQjbE8FjAEAAAAAA.',['傲慢']='傲慢与傲娇:BAAAKgAECgQIBAAAAA==.',['傲气']='傲气十足:BAABKgAFFH8GAAIXAAYIPBWKDAAvAQAXAAYIPBWKDAAvAQAAAA==.',['元素']='元素之怒:BAAAKgADCgEIAQAAAA==.',['光明']='光明乄黑暗:BAAAKgAECgYIDQAAAA==.光明正确伟大:BAABKgAFFH8GAAIHAAQIowaEKgBrAAAHAAQIowaEKgBrAAAAAA==.',['兔年']='兔年发大财:BAAAKgADCgMIAwAAAA==.',['兔白']='兔白:BAABKgAFFH8HAAMFAAcIBRc0AgDJAQAFAAYIAhk0AgDJAQAHAAEIEA3iMQA/AAAAAA==.',['六爻']='六爻:BAAAKgAECgYIBgAAAA==.',['兰斯']='兰斯洛特:BAAAKgADCgEIAQAAAA==.兰斯特:BAABKgAFFH8IAAIIAAgIYQlLDQDMAQAIAAgIYQlLDQDMAQAAAA==.',['兵临']='兵临城下:BAABKgAFFH8JAAIYAAMIuRNZDwDHAAAYAAMIuRNZDwDHAAAAAA==.',['兽皇']='兽皇:BAABKgAFFH8OAAIZAAUIIRQgKgDBAAAZAAUIIRQgKgDBAAAAAA==.',['农夫']='农夫三泉:BAAAKgAFFAQIBAAAAA==.',['冰冰']='冰冰有李:BAAAKgADCgIIAgAAAA==.',['冰山']='冰山无角:BAABKgAECn8YAAIaAAcI2x8uIwDyAQAaAAcI2x8uIwDyAQAAAA==.',['冰美']='冰美式:BAAAKgAECggIBwAAAA==.',['冷冷']='冷冷酱:BAABKgAFFH8RAAMZAAQIPQ10GwCPAAAZAAQIPQ10GwCPAAARAAIImAQAQABoAAAAAA==.',['冷墨']='冷墨乄倾城:BAAAKgAECgEIAQAAAA==.',['冷漠']='冷漠的风:BAAAKgADCgQIBAAAAA==.',['冷焰']='冷焰:BAAAKgAFFAMIAwAAAA==.',['冷酷']='冷酷暗猎:BAAAKgAFFAIIAgAAAA==.',['凉凉']='凉凉哟:BAAAKgAECgIIAgAAAA==.',['凛冬']='凛冬罪歌:BAAAKgAECgcIBwAAAA==.',['凤凰']='凤凰水仙:BAAAKgADCggICAAAAA==.',['别烦']='别烦夏天丶:BAAAKgAFFAIIAwAAAA==.',['制造']='制造法术师:BAAAKgADCgIIAgAAAA==.',['剑语']='剑语墨尘:BAAAKgAECgcICQAAAA==.',['剪桑']='剪桑丶:BAAAKgAECgYIBgAAAA==.',['勇丶']='勇丶气:BAAAKgADCggICAAAAA==.',['勿嗔']='勿嗔:BAAAKgAECggIEQAAAA==.',['十万']='十万伏特:BAAAKgAECgQIBAAAAA==.',['千与']='千与:BAABKgAECn8VAAMFAAgIqhAlUAB6AQAFAAcIcBMlUAB6AQAHAAgIDAAicgACAAAAAA==.',['半颗']='半颗薄荷糖:BAAAKgADCggIGAAAAA==.',['单手']='单手甩尾:BAABKgAFFH8UAAMLAAMIqQ/JFgC+AAALAAMIqQ/JFgC+AAAKAAMIIRDxMQCxAAABKgAFFAgIOQATAI8cAA==.',['卡尼']='卡尼贰:BAAAKgAECggICAAAAA==.',['卡拉']='卡拉永远欧克:BAAAKgAECgQIBgAAAA==.',['古斯']='古斯塔夫:BAAAKgADCggICAAAAA==.',['吉丶']='吉丶安娜:BAAAKgAECgQIBAAAAA==.',['向往']='向往的生活梦:BAAAKgAECggICQAAAA==.',['君莫']='君莫笑哇:BAAAKgAECgIIAQAAAA==.',['吥摇']='吥摇壁莲:BAAAKgAFFAgIAgAAAA==.吥摇璧蓮:BAAAKgADCgEIAQAAAA==.',['吴明']='吴明龙:BAAAKgADCgYIBwAAAA==.',['吼哥']='吼哥:BAAAKgADCggICAAAAA==.',['呆萌']='呆萌杭特:BAABKgAFFH8QAAMDAAQIXwmQHQDMAAADAAQIXwmQHQDMAAAUAAEI6gDeHAAhAAAAAA==.',['呦佑']='呦佑:BAAAKgAECgMIAwAAAA==.',['咪咕']='咪咕:BAAAKgAFFAQIBAAAAA==.',['咸蛋']='咸蛋蛋灬:BAAAKgAFFAQIBAAAAA==.',['哇哦']='哇哦我超凶:BAAAKgAECggICAAAAA==.',['哑童']='哑童:BAAAKgAECgYIDwAAAA==.',['哼哼']='哼哼就饱了:BAAAKgAECgIIAgAAAA==.',['啊沁']='啊沁:BAAAKgAECgYIBgAAAA==.',['啊菇']='啊菇云:BAABKgAFFH8GAAMKAAYIYxqKDwDmAAAKAAQIoxSKDwDmAAAbAAIIlSJAFAC0AAAAAA==.',['啪丶']='啪丶抬高点:BAAAKgAFFAIIAgAAAA==.',['喜欢']='喜欢后射:BAABKgAFFH8NAAIRAAMIahy3LADUAAARAAMIahy3LADUAAAAAA==.',['嘉妮']='嘉妮特:BAABKgAECn8YAAIcAAgI9gE0jwBvAAAcAAgI9gE0jwBvAAAAAA==.',['四队']='四队骑士:BAAAKgAECgEIAQAAAA==.',['回忆']='回忆依然:BAAAKgAFFAIIAgAAAA==.',['因瑟']='因瑟瑞児:BAAAKgAFFAIIAgAAAA==.',['囡囡']='囡囡大魔王:BAAAKgAECggIDgAAAA==.',['圣光']='圣光丶审判者:BAAAKgAECgcIDwAAAA==.圣光之影:BAABKgAECn8wAAIIAAgIixxaGAD/AQAIAAgIixxaGAD/AQAAAA==.',['圣灵']='圣灵卵卵:BAABKgAECn8VAAIUAAgIShIaIAB4AQAUAAgIShIaIAB4AQAAAA==.圣灵小羽:BAABKgAFFH8FAAIDAAMIexDkLADHAAADAAMIexDkLADHAAAAAA==.圣灵晓羽:BAABKgAFFH8GAAILAAMIHQurDgCuAAALAAMIHQurDgCuAAAAAA==.圣灵晓翼:BAABKgAFFH8GAAIIAAMI8BiqIwDYAAAIAAMI8BiqIwDYAAAAAA==.圣灵灵儿:BAABKgAFFH8GAAIQAAMIZAp8HwC0AAAQAAMIZAp8HwC0AAAAAA==.',['在他']='在他乡:BAAAKgAECgUIBQAAAA==.',['埃塞']='埃塞俄丶比亚:BAACKgAFFH8HAAIIAAMILRX+TgDRAAAIAAMILRX+TgDRAAAqAAQKfxoAAggACAgMIiMiAJECAAgACAgMIiMiAJECAAAA.',['埃莘']='埃莘諾斯:BAAAKgADCgUIBQAAAA==.',['塔娜']='塔娜托斯:BAAAKgAECgcICwAAAA==.',['壟訡']='壟訡灬惊天变:BAABKgAFFH8NAAIXAAYI4RYGCgBcAQAXAAYI4RYGCgBcAQABKgAFFAgIDgAFAEoXAA==.',['夏天']='夏天吃西瓜:BAAAKgAECggICAAAAA==.',['夏日']='夏日麽麽茶丶:BAABKgAFFH8LAAIDAAYIIhoCAgDZAQADAAYIIhoCAgDZAQAAAA==.',['多卵']='多卵鱼:BAAAKgAECggICAAAAA==.',['多情']='多情应笑我:BAAAKgADCgcIBwAAAA==.',['夜鸣']='夜鸣丶:BAAAKgAECgEIAQAAAA==.',['大名']='大名丨鼎鼎:BAABKgAECn8kAAIJAAgIZB9GEAB3AgAJAAgIZB9GEAB3AgAAAA==.',['大師']='大師:BAACKgAFFH8JAAIEAAMIlyGUFAAaAQAEAAMIlyGUFAAaAQAqAAQKfzgAAgQACAiAISsJAKsCAAQACAiAISsJAKsCAAAA.',['大盘']='大盘鸡下饭:BAACKgAFFH8jAAIRAAYI7BtpFQD4AAARAAYI7BtpFQD4AAAqAAQKfyEAAhEACAguIsYVAIACABEACAguIsYVAIACAAAA.',['天丶']='天丶使:BAAAKgAECgUIBQAAAA==.',['天使']='天使在歌唱:BAABKgAFFH8GAAIRAAYItwkwHAAhAQARAAYItwkwHAAhAQAAAA==.',['太古']='太古抠脚天尊:BAACKgAFFH8FAAIdAAUISxWeCgD5AAAdAAUISxWeCgD5AAAqAAQKfxgAAx4ACAi8F34IAPcBAB4ACAi8F34IAPcBAB0ACAg1IPcuAEkBAAAA.',['奉圣']='奉圣灵之名:BAABKgAFFH8gAAMZAAQIkw8AMACuAAAZAAQIkw8AMACuAAARAAIIlwkQOwB/AAAAAA==.',['奥蕾']='奥蕾莉:BAABKgAFFH8HAAIaAAMIwAxsNQCaAAAaAAMIwAxsNQCaAAAAAA==.',['奶包']='奶包:BAAAKgAECgQIBAAAAA==.',['奶声']='奶声奶气:BAAAKgAECgUIBQAAAA==.',['奶小']='奶小僧:BAACKgAFFH8UAAIBAAYISRBhEgAWAQABAAYISRBhEgAWAQAqAAQKfyEAAgEACAgRHn4QAGYCAAEACAgRHn4QAGYCAAAA.',['奶骑']='奶骑:BAABKgAFFH8GAAIIAAYIXSUoCgAhAgAIAAYIXSUoCgAhAgABKgAFFAgIDAAIAJIXAA==.',['她不']='她不值得思念:BAABKgAFFH8OAAMUAAMIBRkVEgCzAAADAAMI/RTZKgDNAAAUAAMIQRMVEgCzAAAAAA==.',['她的']='她的离岛:BAAAKgAECggIEQAAAA==.',['好名']='好名字:BAABKgAFFH8GAAIIAAYIDx5WFAC5AQAIAAYIDx5WFAC5AQAAAA==.',['如光']='如光似影:BAAAKgAECggIDQAAAA==.',['娜娜']='娜娜赛玛鲁:BAAAKgADCggICAAAAA==.',['宝石']='宝石土坷垃:BAAAKgAECgUIBgAAAA==.',['寂寞']='寂寞流常:BAAAKgAECgQIBQAAAA==.寂寞的游侠:BAAAKgAFFAIIAgAAAA==.',['寒蝉']='寒蝉:BAAAKgAECgQICAAAAA==.',['小嘴']='小嘴香香:BAABKgAFFH8TAAMRAAQIziNlFwA+AQARAAQIziNlFwA+AQAZAAQILREzMgCnAAAAAA==.',['小土']='小土豆丶:BAAAKgADCggICAAAAA==.',['小孩']='小孩的恋爱:BAABKgAECn8bAAIbAAgIfBW3HgDSAQAbAAgIfBW3HgDSAQAAAA==.',['小小']='小小毛毛虫:BAAAKgAECgcIBwAAAA==.小小色调:BAAAKgAECgQIBAAAAA==.',['小白']='小白好菜:BAAAKgAECgEIAQAAAA==.',['山茶']='山茶:BAAAKgAFFAMIAwAAAA==.',['崇鋿']='崇鋿荣誉:BAAAKgADCgQIBAAAAA==.',['巅峰']='巅峰大鲨鱼:BAAAKgAECgEIAQAAAA==.',['左丶']='左丶翼:BAAAKgAECggICAAAAA==.',['巴利']='巴利斯坦:BAAAKgAECgMIAwAAAA==.',['市一']='市一中林志玲:BAAAKgAFFAQIBAAAAA==.',['帅刀']='帅刀客:BAABKgAFFH8FAAIEAAMI0QYnJwCwAAAEAAMI0QYnJwCwAAAAAA==.',['帅气']='帅气逼人:BAABKgAFFH8KAAIIAAYIuCLPDAABAgAIAAYIuCLPDAABAgAAAA==.',['希尔']='希尔丶瓦娜斯:BAAAKgAECgMIBQAAAA==.',['希爾']='希爾瓦娜斯:BAAAKgAECggICAAAAA==.',['幻影']='幻影流光:BAAAKgAFFAQIBAABKgAFFAgIFAAcAPAZAA==.',['开尔']='开尔杀死:BAAAKgAECgIIAQAAAA==.开尔铜须:BAAAKgAECgUIBAAAAA==.',['当仁']='当仁不让:BAAAKgAECggICQAAAA==.',['影歌']='影歌:BAAAKgAFFAYIBAAAAA==.',['影缝']='影缝者:BAAAKgAECgEIAQAAAA==.',['心的']='心的召唤:BAAAKgADCggICAAAAA==.',['忏悔']='忏悔罪歌:BAAAKgAECgEIAQAAAA==.',['怀特']='怀特邁恩:BAAAKgAECggIEAAAAA==.',['思文']='思文:BAAAKgAFFAMIAwAAAA==.',['思暮']='思暮浓:BAAAKgADCggICAAAAA==.',['恢恢']='恢恢:BAABKgAFFH8EAAIBAAQISRtjFwDmAAABAAQISRtjFwDmAAAAAA==.',['恶魔']='恶魔宝宝:BAAAKgAECgIIAgAAAA==.',['感觉']='感觉要到位:BAACKgAFFH8UAAIfAAMIrSI+EgAgAQAfAAMIrSI+EgAgAQAqAAQKfxYAAx8ACAi5IOcLAHcCAB8ACAi5IOcLAHcCAA0AAwgEE8FfAKMAAAAA.',['懒懒']='懒懒的冰狼:BAABKgAECn8VAAMRAAcI3g6ufwDZAAARAAcIRg6ufwDZAAAZAAYIqgnUcACkAAAAAA==.',['我以']='我以為:BAAAKgAFFAYIAQAAAA==.',['我是']='我是灵牙:BAABKgAECn8UAAIQAAcI3xzvSwB+AQAQAAcI3xzvSwB+AQAAAA==.',['我最']='我最棒:BAAAKgADCggICAAAAA==.',['我没']='我没瞎:BAABKgAFFH8OAAMUAAgIchoNAwC4AQADAAgI6RHbCgDbAQAUAAYIkx8NAwC4AQAAAA==.',['我还']='我还行厶:BAAAKgAECgYIBgAAAA==.',['战灬']='战灬鬼绪:BAAAKgAECgMIAwAAAA==.',['打麻']='打麻将赚点卡:BAAAKgAECgcIBwAAAA==.',['执行']='执行官丶謝:BAAAKgAECgcIEwAAAA==.',['扶苏']='扶苏:BAAAKgADCggICAAAAA==.',['拳少']='拳少:BAAAKgAECgYIDAAAAA==.',['指间']='指间刹:BAAAKgAFFAEIAQAAAA==.',['掌心']='掌心的凌乱:BAAAKgAFFAIIAgAAAA==.',['提克']='提克之子:BAAAKgAECggIEAAAAA==.',['摘星']='摘星:BAABKgAFFH8IAAIcAAQIVBPOCQDdAAAcAAQIVBPOCQDdAAAAAA==.',['撒玛']='撒玛之神:BAABKgAFFH8GAAIKAAMI5BFzLQDBAAAKAAMI5BFzLQDBAAAAAA==.',['新一']='新一代:BAAAKgADCgIIAgAAAA==.',['无灬']='无灬月:BAAAKgAECggICAAAAA==.无灬焱:BAAAKgAECgcIBwAAAA==.',['无花']='无花:BAAAKgAECgYIBgAAAA==.',['旧吉']='旧吉他:BAAAKgADCggICAAAAA==.',['时光']='时光乄荏苒:BAAAKgAECggIDgAAAA==.',['星星']='星星:BAABKgAFFH8FAAIZAAMIYAy3EQDQAAAZAAMIYAy3EQDQAAAAAA==.',['星澜']='星澜月影:BAAAKgAECgMIAwAAAA==.',['春桃']='春桃:BAAAKgAECgYIDAAAAA==.',['春生']='春生:BAAAKgAECgcICQAAAA==.',['春風']='春風:BAAAKgAFFAYIAgAAAA==.',['晓哓']='晓哓德:BAAAKgAECgcICAAAAA==.',['暗寻']='暗寻:BAAAKgAECgcICwAAAA==.',['暗留']='暗留香:BAAAKgAECgIIAgAAAA==.',['暮雨']='暮雨撒江天:BAAAKgAFFAgIBAAAAA==.',['暴力']='暴力福娃:BAAAKgAECgYIBwAAAA==.',['暴躁']='暴躁喷火娃:BAAAKgAECgMIAwAAAA==.',['曼猫']='曼猫:BAABKgAFFH8GAAMMAAYI9hsdFAD/AAAMAAQIdR4dFAD/AAAQAAIIFR64QACpAAAAAA==.',['曾经']='曾经是棵树:BAABKgAFFH8IAAMQAAgIaRQ8DADRAQAQAAcIWBY8DADRAQAMAAEIOA6fNABHAAAAAA==.',['會钓']='會钓鱼的猫:BAAAKgAECgYIBgAAAA==.',['月之']='月之羁绊:BAAAKgADCgIIAgAAAA==.',['月御']='月御:BAAAKgADCgEIAQAAAA==.',['有点']='有点味道:BAAAKgAECgcIDAAAAA==.',['有辱']='有辱斯文:BAABKgAFFH8tAAMgAAQIQBkvBQDuAAAgAAMIQBkvBQDuAAAQAAMIsAn0KQBrAAAAAA==.',['朴灬']='朴灬汉升:BAABKgAFFH8IAAIZAAgIHRStBQAZAgAZAAgIHRStBQAZAgAAAA==.',['杀手']='杀手二号:BAAAKgAECggICwAAAA==.',['村长']='村长:BAAAKgAECggICAAAAA==.',['杜仲']='杜仲:BAAAKgADCggICAAAAA==.',['東京']='東京:BAAAKgAECgEIAQAAAA==.',['東方']='東方吥败丶丶:BAAAKgAFFAIIAgAAAA==.',['某海']='某海辛:BAAAKgAECgUIBQAAAA==.',['柒分']='柒分半糖:BAAAKgAECgIIAgAAAA==.',['格格']='格格丶巫:BAAAKgAECgcIEQAAAA==.',['桃瑞']='桃瑞斯蒂娜:BAAAKgAECgEIAQAAAA==.桃瑞斯诺伊:BAAAKgADCgEIAQAAAA==.',['梅菲']='梅菲儿:BAAAKgAECggICAAAAA==.',['梦回']='梦回吹角连营:BAAAKgADCgQIBAAAAA==.',['梦境']='梦境丶記忆丶:BAAAKgAFFAMIAwAAAA==.',['楚天']='楚天乄狂歌:BAAAKgAECgcIBwAAAA==.',['楪祈']='楪祈公主:BAAAKgAECgQIBQAAAA==.',['樱木']='樱木凛:BAABKgAFFH8JAAIIAAMICwp/YQCtAAAIAAMICwp/YQCtAAAAAA==.',['歌妮']='歌妮薇尔:BAABKgAFFH8IAAMXAAgICAojFwC/AAAXAAQIiAcjFwC/AAAIAAQIXQ3eWQC9AAAAAA==.',['正版']='正版授权:BAAAKgADCgEIAQAAAA==.',['武林']='武林至尊:BAAAKgAECgMIAwAAAA==.',['死亡']='死亡零一:BAAAKgAECgMIAwAAAA==.',['死牧']='死牧板:BAAAKgAECgcIBwAAAA==.',['死骑']='死骑乄信仰:BAAAKgAECgIIAgAAAA==.',['死魂']='死魂小超市:BAAAKgAECgcIBwAAAA==.死魂灵:BAABKgAFFH8HAAIRAAMIgAzJPACpAAARAAMIgAzJPACpAAAAAA==.死魂行者:BAAAKgAECgYICwAAAA==.',['水王']='水王龍驕:BAAAKgAECgUIDQAAAA==.',['永恒']='永恒的二十:BAABKgAFFH8LAAIRAAMIMR9+JQDxAAARAAMIMR9+JQDxAAAAAA==.',['江海']='江海寄余生:BAAAKgADCgEIAgAAAA==.',['汤姆']='汤姆克噜斯:BAABKgAFFH8OAAMWAAQIWSIvBgACAQAEAAQINSDyEwAhAQAWAAMIMhwvBgACAQAAAA==.',['汪小']='汪小猪:BAAAKgAFFAQIBAAAAA==.',['沃克']='沃克:BAAAKgAECgUIBQAAAA==.',['沒心']='沒心沒肺:BAAAKgAECggIEAAAAA==.',['沙漠']='沙漠里的泥鳅:BAAAKgADCgEIAQAAAA==.',['没事']='没事搞事:BAAAKgAECgMIAwAAAA==.',['没糖']='没糖兜兜:BAABKgAFFH8IAAMaAAUIUBedJwDSAAAaAAQINxydJwDSAAAhAAIImwgJLQBBAAABKgAFFAgIDwAaAJIcAA==.',['法天']='法天相地:BAAAKgADCggICAAAAA==.',['洛奇']='洛奇巴尔博:BAABKgAFFH8MAAIZAAYI3RyIDACQAQAZAAYI3RyIDACQAQAAAA==.',['洛羽']='洛羽:BAABKgAFFH8QAAMRAAMIJhrKKQDeAAARAAMIJhrKKQDeAAAZAAIIEAq/RABrAAAAAA==.',['洛贝']='洛贝琳:BAAAKgAECggICAAAAA==.',['活力']='活力魔法水:BAAAKgAECgQIBQAAAA==.',['浠宝']='浠宝:BAABKgAFFH8NAAIcAAMIWRW3FADEAAAcAAMIWRW3FADEAAAAAA==.',['浪漫']='浪漫土耳其:BAABKgAFFH8GAAIXAAYIyRHYDgASAQAXAAYIyRHYDgASAQAAAA==.浪漫无用:BAABKgAFFH8OAAIIAAQI3CSxKQBAAQAIAAQI3CSxKQBAAQAAAA==.',['浪花']='浪花倾城:BAAAKgAECgcIEgAAAA==.',['浪里']='浪里格花:BAAAKgAECgMIAwAAAA==.',['浮浮']='浮浮橙橙:BAAAKgAECgcIDQAAAA==.',['游骑']='游骑兵过的晵:BAAAKgAECgYIBgAAAA==.',['溜溜']='溜溜蛋:BAABKgAFFH8GAAIIAAYIcCLVDAAAAgAIAAYIcCLVDAAAAgAAAA==.',['满满']='满满:BAAAKgADCggICgAAAA==.',['滴血']='滴血青霜:BAABKgAFFH8IAAIcAAQIxSKHCgAdAQAcAAQIxSKHCgAdAQAAAA==.',['潇洒']='潇洒双刃:BAAAKgAFFAQIBAAAAA==.',['潇湘']='潇湘风笛:BAABKgAECn8bAAMEAAcINhBUSABHAQAEAAYIeQ9USABHAQAWAAUIwwliSACsAAAAAA==.',['潜伏']='潜伏乄风筝:BAAAKgAECgcIDAAAAA==.',['灬没']='灬没睡醒:BAAAKgAECgcICAAAAA==.',['灬猪']='灬猪才怪:BAAAKgAECgEIAQAAAA==.',['灬莫']='灬莫甘娜灬:BAAAKgADCggICAAAAA==.',['灰色']='灰色的雾:BAAAKgAECgcICgAAAA==.',['灵采']='灵采神:BAABKgAFFH8cAAIGAAUIehkDBgAtAQAGAAUIehkDBgAtAQAAAA==.',['灸丨']='灸丨无情灬丨:BAABKgAFFH8FAAIEAAMImhNtHQDeAAAEAAMImhNtHQDeAAAAAA==.',['灿然']='灿然:BAAAKgADCggICAAAAA==.',['烈风']='烈风灰手:BAAAKgADCggICwAAAA==.',['烟火']='烟火:BAAAKgAECgIIAgAAAA==.',['無氧']='無氧旅人:BAAAKgAECgMIAwAAAA==.',['焮燃']='焮燃:BAABKgAFFH8uAAMGAAQI5BGeCgDLAAAGAAQI5BGeCgDLAAAFAAMISQrJOAC4AAAAAA==.',['煌天']='煌天第一射:BAAAKgADCggICAAAAA==.',['煎猪']='煎猪排超人:BAAAKgADCgEIAQAAAA==.',['熊大']='熊大蛋:BAAAKgAECgYIBgAAAA==.',['熊少']='熊少:BAAAKgAECggIEAAAAA==.',['熊熊']='熊熊的锤子:BAAAKgAECgcIDgAAAA==.',['牛牛']='牛牛笙歌:BAAAKgADCgEIAQAAAA==.',['牛玄']='牛玄德:BAAAKgADCggICAAAAA==.',['物死']='物死人非:BAAAKgADCgQIBAAAAA==.',['特斯']='特斯拉:BAAAKgAFFAgIBAAAAA==.',['特萨']='特萨维斯邪刃:BAABKgAFFH8KAAIUAAQIfRRIEgCxAAAUAAQIfRRIEgCxAAAAAA==.',['狼外']='狼外婆啊灬:BAAAKgAECgQIBAAAAA==.',['猫小']='猫小白:BAACKgAFFH8JAAMRAAQIpSUQBwBTAQARAAQIpSUQBwBTAQAZAAQIHxCfLwCvAAAqAAQKfyoAAxEACAhRH2cqAEoCABEACAh7HmcqAEoCABkABwjhGUcwAJ4BAAAA.',['猫猫']='猫猫:BAAAKgAECgQICAABKgAFFAQICQARAKUlAA==.',['猴不']='猴不语:BAAAKgADCgcICgAAAA==.',['玉皇']='玉皇:BAAAKgAFFAEIAQAAAA==.',['王者']='王者归涞:BAAAKgAECggIDgAAAA==.',['玛莉']='玛莉亚:BAAAKgAECgYIBgAAAA==.',['玫瑰']='玫瑰气泡水:BAAAKgAECgUIBQAAAA==.',['珠仙']='珠仙剑阵决:BAAAKgAECgIIAgAAAA==.',['琼恩']='琼恩丶雪诺:BAAAKgADCggICAAAAA==.',['生生']='生生:BAABKgAFFH8GAAINAAYIZA1fDgA0AQANAAYIZA1fDgA0AQAAAA==.',['生田']='生田绘梨花:BAAAKgAECgIIAgAAAA==.',['番茄']='番茄的最爱:BAAAKgADCgEIAQAAAA==.',['痴情']='痴情香菜:BAAAKgADCgIIAgAAAA==.',['癫龘']='癫龘:BAAAKgAECgEIAQAAAA==.',['白眉']='白眉毛:BAAAKgAFFAQIAwAAAA==.',['皓卡']='皓卡:BAAAKgADCggICAAAAA==.',['皓月']='皓月少年:BAAAKgADCgMIAwAAAA==.',['祝丫']='祝丫丫:BAAAKgADCggICAAAAA==.',['神秘']='神秘剑修者:BAABKgAFFH8UAAMEAAgINw69BQA1AgAEAAgINw69BQA1AgAWAAQIiwsHGQDBAAAAAA==.',['神经']='神经才子:BAAAKgADCgMIAwAAAA==.',['秋匊']='秋匊:BAAAKgAECgMIAwAAAA==.',['秋月']='秋月風夏:BAAAKgAECgYIBgAAAA==.',['秋池']='秋池渊:BAAAKgAECgIIAwAAAA==.',['空空']='空空儿:BAAAKgAECgMIAwAAAA==.',['笑著']='笑著離開:BAAAKgADCggICAAAAA==.',['笣俎']='笣俎婆:BAABKgAFFH8IAAIDAAgIgg9VCAAJAgADAAgIgg9VCAAJAgAAAA==.',['筱树']='筱树叶:BAABKgAFFH8IAAIIAAgIPRo+CABAAgAIAAgIPRo+CABAAgAAAA==.',['简绣']='简绣:BAAAKgAECggIDgAAAA==.',['箭出']='箭出封喉:BAAAKgADCggICgAAAA==.',['米开']='米开朗基罗:BAAAKgAECgIIAgAAAA==.',['米耐']='米耐希爾:BAAAKgAECgYIDwAAAA==.',['紫月']='紫月音:BAAAKgAECggIDwAAAA==.',['紫龙']='紫龙:BAAAKgAECggICAAAAA==.',['絡凡']='絡凡:BAAAKgAECgEIAQAAAA==.',['絡叶']='絡叶:BAAAKgAECgcIDQAAAA==.',['纯情']='纯情小火鸡:BAAAKgAECgQIBAAAAA==.',['练习']='练习三:BAAAKgADCgYIBgAAAA==.',['继承']='继承者:BAABKgAFFH8MAAIaAAMIbg/OGQCvAAAaAAMIbg/OGQCvAAAAAA==.',['羅賓']='羅賓漢:BAAAKgAFFAYIBAAAAA==.',['羲和']='羲和:BAACKgAFFH8gAAMYAAUIYiDABQB3AQAYAAUIYiDABQB3AQAIAAMIXglGKgDJAAAqAAQKfzEAAxgACAgWI9kCAMMCABgACAgWI9kCAMMCAAgACAhUHZ07ADwCAAAA.',['翎袭']='翎袭风的宠物:BAABKgAFFH8IAAIQAAgI1xUsBwAyAgAQAAgI1xUsBwAyAgAAAA==.',['翗丶']='翗丶破空晓月:BAAAKgAECgYIBgAAAA==.',['翗雨']='翗雨丶燎原:BAABKgAECn8XAAMZAAgI1w+bUgAGAQAZAAgI1w+bUgAGAQARAAIIXQmV6QBfAAAAAA==.',['翩然']='翩然雪海間:BAAAKgAFFAMIAwAAAA==.',['翼克']='翼克赛艇:BAAAKgADCgMIAwAAAA==.',['老地']='老地方见:BAAAKgAECgUIBwAAAA==.',['老婆']='老婆的毛毛虫:BAAAKgAECgMIBQAAAA==.',['老年']='老年奎托斯:BAAAKgADCgQIBAAAAA==.',['老树']='老树潘安:BAAAKgAECggIEAAAAA==.',['胥高']='胥高:BAAAKgAFFAIIAgAAAA==.',['自摸']='自摸二五八:BAABKgAFFH8UAAIIAAgIgBpEBwBTAgAIAAgIgBpEBwBTAgAAAA==.',['自然']='自然乄和谐:BAAAKgAECgcIEQAAAA==.',['自由']='自由的灵魂:BAAAKgAECgEIAwAAAA==.',['色呆']='色呆呆:BAABKgAFFH8GAAIHAAYI3QE+DQCkAAAHAAYI3QE+DQCkAAAAAA==.',['艾丽']='艾丽娅娜:BAABKgAECn8aAAIRAAgIUyLFDwDCAgARAAgIUyLFDwDCAgAAAA==.',['艾什']='艾什可逗烖:BAAAKgAECgYIBgAAAA==.',['艾利']='艾利亚纳:BAAAKgAECggIBwAAAA==.',['花天']='花天乄狂骨:BAAAKgAECggICgAAAA==.',['花季']='花季灬懵懵丿:BAAAKgADCggICAAAAA==.',['花开']='花开只为她:BAABKgAFFH8HAAIIAAcIHBjMEADZAQAIAAcIHBjMEADZAQAAAA==.',['花生']='花生奶牛:BAAAKgADCgQIBAAAAA==.',['花舞']='花舞林夕:BAAAKgAECggICwAAAA==.',['苍穹']='苍穹蔚蓝:BAABKgAFFH8RAAQNAAYIMxx9AQDIAQANAAYI5Rt9AQDIAQAfAAUIfg27HQDUAAAiAAII7QkiGACiAAAAAA==.',['苏格']='苏格拉底:BAAAKgADCggICAAAAA==.',['苞租']='苞租公:BAABKgAFFH8GAAMQAAYICBRwHQAxAQAQAAUIlBhwHQAxAQAMAAEICw+QNABHAAAAAA==.',['荆楚']='荆楚乄大地:BAAAKgAECgYIBgAAAA==.',['荣誉']='荣誉即好命:BAAAKgAECgcICwAAAA==.',['莎儿']='莎儿娃娃:BAAAKgADCggICAAAAA==.',['莫名']='莫名一股邪火:BAAAKgADCgUIBQAAAA==.',['萌尐']='萌尐骑:BAAAKgADCgIIAgABKgAECggIGAABAM8UAA==.',['落花']='落花小僧:BAABKgAFFH8GAAIBAAYIFA2YCgAeAQABAAYIFA2YCgAeAQAAAA==.',['葉奈']='葉奈法:BAABKgAECn8gAAMcAAgIbhsDHgAYAgAcAAgIYRkDHgAYAgAJAAcIjBjOKQC0AQAAAA==.',['薛紫']='薛紫夜丶:BAABKgAFFH8GAAIBAAYIawx6BAB0AQABAAYIawx6BAB0AQAAAA==.',['虚空']='虚空侵染者:BAAAKgADCgEIAQAAAA==.',['蛇喰']='蛇喰梦子丨:BAABKgAECn8WAAIDAAgI9RpSLAACAgADAAgI9RpSLAACAgAAAA==.',['蛊惑']='蛊惑烊:BAAAKgADCgUIBQAAAA==.',['蛋糕']='蛋糕:BAAAKgAECgMIAwAAAA==.',['蜗牛']='蜗牛漫步:BAAAKgAECgcIDQAAAA==.',['血染']='血染樱花:BAAAKgADCgIIAgAAAA==.',['血沐']='血沐:BAAAKgADCggICAAAAA==.',['衣莉']='衣莉丹:BAAAKgAFFAMIAwAAAA==.',['被鱼']='被鱼欺负的猫:BAAAKgAECgUIBQAAAA==.',['西红']='西红柿将军丶:BAAAKgADCgQIBAAAAA==.',['覚侑']='覚侑卜甚修罗:BAABKgAFFH8FAAIEAAUIBx3aEABHAQAEAAUIBx3aEABHAQAAAA==.',['解语']='解语花:BAAAKgAECgcICgAAAA==.',['諫山']='諫山黄泉:BAAAKgAECgEIAQAAAA==.',['词穷']='词穷乄墨尽:BAAAKgAECggICwAAAA==.',['调野']='调野太祥:BAABKgAFFH8JAAIIAAIITBTVPwCIAAAIAAIITBTVPwCIAAAAAA==.调野武佐:BAABKgAFFH8GAAIfAAMIHgT3MQB+AAAfAAMIHgT3MQB+AAAAAA==.',['豌杂']='豌杂:BAABKgAFFH8IAAIFAAUIWRLrCwBJAQAFAAUIWRLrCwBJAQAAAA==.',['贼帅']='贼帅:BAABKgAFFH8IAAITAAgIyQYbBgDiAQATAAgIyQYbBgDiAQAAAA==.',['赤犬']='赤犬:BAAAKgADCggICAAAAA==.',['路西']='路西法屮晨星:BAAAKgAFFAEIAQAAAA==.',['踏天']='踏天猎穹斩:BAAAKgAECgUIBgAAAA==.',['输出']='输出的心:BAAAKgAECgMIAwAAAA==.',['边渡']='边渡友次子:BAAAKgADCggICAAAAA==.',['达丶']='达丶摩:BAAAKgADCggICAAAAA==.',['这萨']='这萨真强:BAAAKgADCggICQAAAA==.',['远丨']='远丨行丨者:BAABKgAFFH8MAAIKAAYIvBGNEQBIAQAKAAYIvBGNEQBIAQABKgAFFAgIBAAjAAAAAA==.',['迷茫']='迷茫小刀:BAAAKgAECgYIBgAAAA==.迷茫小猎:BAAAKgAECgYIBgAAAA==.迷茫小萨:BAAAKgAECgYIBgAAAA==.',['迷路']='迷路的风筝:BAAAKgAECgQIBAAAAA==.',['逍遥']='逍遥貓:BAAAKgADCggICAAAAA==.',['道法']='道法乄自然:BAAAKgAECggICAAAAA==.道法释然:BAABKgAFFH8GAAIBAAYIcAMfDgDLAAABAAYIcAMfDgDLAAAAAA==.',['酱酱']='酱酱包:BAAAKgAFFAMIAwAAAA==.',['醉光']='醉光阴:BAAAKgAECgEIAQAAAA==.',['醉春']='醉春烟:BAAAKgAECgYIBgAAAA==.',['醉雨']='醉雨听月:BAABKgAFFH8OAAMfAAYIig6yGQDrAAAfAAUIMw6yGQDrAAAiAAEIogHtLwA3AAAAAA==.',['野性']='野性的鹌鹑:BAAAKgAFFAIIAgABKgAFFAgIUAAQABcmAA==.',['钢铁']='钢铁骇浪:BAABKgAFFH8FAAIEAAMImgYkKACpAAAEAAMImgYkKACpAAAAAA==.',['钢骨']='钢骨铁拳:BAAAKgAECgQIBgAAAA==.',['钱堆']='钱堆儿:BAACKgAFFH8PAAIIAAMIbx+AGgAQAQAIAAMIbx+AGgAQAQAqAAQKfx8ABAgACAgPIlkgAIECAAgACAgPIlkgAIECABgABQg3EE04AK4AABcAAQgaAkNjAAQAAAAA.',['铁头']='铁头:BAAAKgAECggICAAAAA==.',['错与']='错与对:BAAAKgAFFAQIAwAAAA==.',['锤子']='锤子超大号:BAACKgAFFH8MAAIKAAMIJCStFQAtAQAKAAMIJCStFQAtAQAqAAQKfxgAAgoABwjKIfcYAGgBAAoABwjKIfcYAGgBAAAA.',['长言']='长言歌:BAAAKgADCggICAAAAA==.',['闪小']='闪小侠:BAAAKgADCgEIAQAAAA==.',['闪耀']='闪耀:BAABKgAFFH8GAAIYAAQI2BFsEAC/AAAYAAQI2BFsEAC/AAAAAA==.',['队长']='队长先撤:BAAAKgADCgIIAgAAAA==.',['阿华']='阿华:BAAAKgAECgYIBQAAAA==.',['阿吗']='阿吗尼:BAABKgAFFH8KAAMkAAMIrgSwCQBtAAAkAAMIrgSwCQBtAAABAAEI5AnELQA3AAAAAA==.',['阿尓']='阿尓萨斯:BAAAKgAECgEIAQAAAA==.',['阿斯']='阿斯兰精灵:BAAAKgAECgcICwAAAA==.阿斯蒂芬丶谌:BAAAKgAECgEIAQAAAA==.',['陈巧']='陈巧洁:BAABKgAECn8ZAAIIAAgIfBJInwAPAQAIAAgIfBJInwAPAQAAAA==.',['雨宫']='雨宫喵喵子:BAAAKgAECgIIAgAAAA==.',['雪月']='雪月梦境:BAABKgAFFH8IAAIMAAgIrAU6CQB0AQAMAAgIrAU6CQB0AQAAAA==.',['雲過']='雲過無痕:BAABKgAECn8gAAIcAAgILxoiFgAIAgAcAAgILxoiFgAIAgAAAA==.',['零星']='零星叶:BAAAKgAECgMIAwAAAA==.',['雷铭']='雷铭:BAAAKgAECgQIBwAAAA==.',['霜伊']='霜伊:BAAAKgAECggICAAAAA==.',['霸少']='霸少:BAAAKgAECgcIBwAAAA==.',['霸王']='霸王牛蹄:BAAAKgADCgIIAgAAAA==.',['青雉']='青雉:BAAAKgAECgEIAQAAAA==.',['静嘤']='静嘤嘤:BAAAKgAECggICAAAAA==.',['鞋不']='鞋不肉:BAACKgAFFH8gAAIEAAYIzxUSDgBxAQAEAAYIzxUSDgBxAQAqAAQKfxQAAgQACAiJGVAhABICAAQACAiJGVAhABICAAEqAAUUCAgMABcAHhMA.',['顽强']='顽强的凯瑟琳:BAAAKgAFFAMIAwAAAA==.',['领主']='领主又领盒饭:BAAAKgAECgIIAgAAAA==.',['风丨']='风丨行丨者:BAAAKgAFFAIIBAAAAA==.',['风之']='风之记忆:BAAAKgAECggIEAABKgAFFAgICgAIAK0lAA==.',['风凡']='风凡:BAAAKgAECgQIBAAAAA==.',['风尊']='风尊:BAAAKgAFFAYIAQAAAA==.',['风暴']='风暴妹妹:BAAAKgADCggICAAAAA==.',['风的']='风的北极:BAAAKgAFFAcIAwAAAA==.',['飘渺']='飘渺红尘:BAAAKgADCgEIAQAAAA==.',['饱饱']='饱饱:BAAAKgADCgMIAwAAAA==.',['香抹']='香抹冰激灵:BAABKgAFFH8GAAIBAAYIogn1EgARAQABAAYIogn1EgARAQAAAA==.',['马维']='马维影之歌:BAABKgAECn8WAAMTAAgIVyKBCQB4AgATAAgIrCCBCQB4AgAPAAgIwR/VBwBuAgAAAA==.',['马老']='马老熊:BAAAKgADCggICAABKgAFFAgIBAAjAAAAAA==.',['骑士']='骑士奥德彪:BAAAKgAECgMIAwAAAA==.骑士来了:BAACKgAFFH8RAAIIAAMIEh0gNwAOAQAIAAMIEh0gNwAOAQAqAAQKfxsAAwgACAiDHL5bAOYBAAgACAiDHL5bAOYBABcABwgXFXAiAEMBAAAA.',['骑妇']='骑妇难下:BAAAKgADCgIIAgAAAA==.',['高考']='高考零分:BAAAKgADCggIEAABKgAECgQIBAAjAAAAAA==.',['鬽鬽']='鬽鬽:BAAAKgAFFAMIAwAAAA==.',['魅雪']='魅雪邪姬:BAAAKgAECgIIAgAAAA==.',['魔女']='魔女克拉娜:BAABKgAFFH8FAAMcAAIIEQ8/FACNAAAcAAIIEQ8/FACNAAAJAAEI9QOVSAAvAAAAAA==.',['魔法']='魔法穆穆:BAABKgAFFH8TAAIiAAMIoxcRFQDTAAAiAAMIoxcRFQDTAAAAAA==.',['鱼跃']='鱼跃晴空:BAAAKgADCggICAAAAA==.',['鲸让']='鲸让我照望海:BAAAKgADCggICAAAAA==.',['鸡哔']='鸡哔你:BAAAKgAECgYIBgAAAA==.',['鸿品']='鸿品德一:BAAAKgAFFAQIBAAAAA==.',['麦克']='麦克尼:BAAAKgADCgIIAgAAAA==.',['齐丹']='齐丹就是牛:BAAAKgAECgYICAAAAA==.',['龍仔']='龍仔史:BAAAKgAECggIEQAAAA==.',['龍神']='龍神:BAAAKgAECggIDgAAAA==.',['龙仔']='龙仔史:BAAAKgAECgIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end