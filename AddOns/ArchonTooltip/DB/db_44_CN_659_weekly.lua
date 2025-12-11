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
 local lookup = {'Shaman-Restoration','Mage-Arcane','Paladin-Retribution','Warlock-Destruction','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Shaman-Elemental','Monk-Windwalker','Monk-Brewmaster','DemonHunter-Havoc','Warrior-Fury','Mage-Frost','Warlock-Demonology','Priest-Shadow','Warrior-Protection','Druid-Feral','Druid-Restoration','Paladin-Holy','Rogue-Subtlety','Rogue-Assassination','Monk-Mistweaver','Evoker-Devastation','Evoker-Preservation','Evoker-Augmentation','Unknown-Unknown','Warrior-Arms','Priest-Holy','Mage-Fire','Rogue-Outlaw',}; local provider = {region='CN',realm='屠魔山谷',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aiyouyou:BAAALAAFFAIIAwAAAA==.',Al='Alone:BAAALAAFFAYIAgAAAA==.',Ao='Aofa:BAAALAADCggICAAAAA==.Aotiantian:BAAALAAECgYIEAAAAA==.',Aq='Aqui:BAAALAADCgMIAwAAAA==.',Da='Danko:BAAALAAECgYIBwAAAA==.',De='Deathknight:BAAALAAFFAIIAgAAAA==.Deepseeko:BAAALAADCgIIAgAAAA==.Deepseeks:BAAALAADCgIIAgAAAA==.',Dr='Dragon:BAAALAAECgIIAgAAAA==.',Ec='Ecarlate:BAAALAAECggICAAAAA==.',Fl='Flloo:BAAALAAECggIAQAAAA==.Flora:BAABLAAFFH8FAAIBAAII0ASlcABJAAABAAII0ASlcABJAAAAAA==.',Fo='Fools:BAABLAAFFH8LAAICAAYImhDwGACYAQACAAYImhDwGACYAQAAAA==.',Hi='Hikaru:BAAALAADCggICAAAAA==.',Ji='Jie:BAABLAAFFH8HAAIDAAUIQhVOJwA/AQADAAUIQhVOJwA/AQAAAA==.',Ju='Juzco:BAABLAAFFH8UAAIEAAUIfxDpOgAdAQAEAAUIfxDpOgAdAQAAAA==.',Ka='Kaldordraigo:BAAALAAECgcIBwAAAA==.',La='Lampdk:BAABLAAFFH8UAAQFAAUIRCGsPABIAQAFAAUIRCGsPABIAQAGAAIIqxLLDwCJAAAHAAEIEA+pIAA+AAAAAA==.Lava:BAAALAADCgYIBgAAAA==.',Lg='Lgniaozi:BAABLAAECn8aAAMIAAgI6x+wJgC9AgAIAAgI6x+wJgC9AgAJAAgIeQ+hTACDAQAAAA==.',Li='Lissa:BAAALAAECgIIAgAAAA==.Littleseal:BAABLAAFFH8GAAIKAAII7hM9GwCXAAAKAAII7hM9GwCXAAAAAA==.',Ma='Macellaio:BAAALAAECgYIBgAAAA==.Manon:BAABLAAECn8rAAILAAcISBcrKwBrAQALAAcISBcrKwBrAQAAAA==.',Ne='Nexusprime:BAAALAAECgYIDAAAAA==.',Pi='Pikapika:BAAALAADCgMIAwAAAA==.',Pl='Playervrndto:BAAALAADCgEIAQAAAA==.',Si='Simulacra:BAABLAAECn8ZAAIDAAYI1BvHgwDlAQADAAYI1BvHgwDlAQAAAA==.',Ss='Sskyxz:BAAALAAECgIIAgAAAA==.',Tu='Turiaf:BAAALAADCgEIAQAAAA==.',Ty='Tyleness:BAABLAAECn8eAAIFAAgI7x0nMwCoAgAFAAgI7x0nMwCoAgAAAA==.',Vi='Victoria:BAAALAAECggIDgAAAA==.',Wi='Witega:BAAALAAECgIIAgAAAA==.',Yu='Yunaleasca:BAAALAADCgEIAQAAAA==.Yunica:BAAALAAECgYIDAAAAA==.',['一介']='一介匹夫:BAAALAAFFAMIAgAAAA==.',['一只']='一只竹子:BAABLAAFFH8gAAMMAAYI9R8EBADZAQAMAAYI9R8EBADZAQANAAIIggzrIAAxAAAAAA==.',['一奎']='一奎爷一:BAAALAAECgcIDQAAAA==.',['一战']='一战定乾坤:BAAALAAECgQIBQAAAA==.',['一法']='一法入魂:BAAALAADCgEIAQAAAA==.',['一穆']='一穆一:BAAALAAFFAIIBAAAAA==.',['一箭']='一箭定终身:BAAALAAECgYIDAAAAA==.',['一脸']='一脸萌懂:BAACLAAFFH8HAAIOAAYIGAqsKgA/AQAOAAYIGAqsKgA/AQAsAAQKfxgAAg4ACAhiG/44AHsCAA4ACAhiG/44AHsCAAAA.',['一龙']='一龙笑天:BAAALAAECgYICQAAAA==.',['不懂']='不懂浪漫的帅:BAAALAAECgQIBwAAAA==.',['不按']='不按套路来:BAAALAAECgIIAgAAAA==.',['不羁']='不羁的呼吸:BAABLAAFFH8kAAMFAAYIdR6TFwDcAQAFAAYIdR6TFwDcAQAGAAEITgJHGwA0AAAAAA==.',['不胜']='不胜利毋宁死:BAAALAAECgYICgAAAA==.',['不要']='不要乱来:BAAALAAECgYIAgAAAA==.',['与你']='与你无瓜:BAAALAAECgIIAgAAAA==.',['东东']='东东不乖:BAACLAAFFH8LAAIDAAII9x+9KgC0AAADAAII9x+9KgC0AAAsAAQKfx0AAgMACAjbHZIXAFICAAMACAjbHZIXAFICAAAA.',['丨癫']='丨癫灬狂丨:BAACLAAFFH8HAAIPAAIITQV7WgA8AAAPAAIITQV7WgA8AAAsAAQKfxcAAg8ACAj1FFcqALQBAA8ACAj1FFcqALQBAAAA.',['丨饭']='丨饭饭丨:BAAALAAECgMIAwAAAA==.',['中州']='中州我最狂:BAAALAAECgYICwAAAA==.',['丶仅']='丶仅有的傲气:BAABLAAFFH8RAAMNAAYInBJ6EABDAQANAAYISw56EABDAQAMAAQITBFCDwCpAAAAAA==.',['丶傲']='丶傲气啊:BAAALAAFFAIIBAAAAA==.',['丶叫']='丶叫我傲气:BAABLAAFFH8TAAQHAAYI6RYHAwChAQAHAAYI6RYHAwChAQAFAAIIpQ6tbQCRAAAGAAII2QsREgB6AAAAAA==.',['丶安']='丶安静丶:BAAALAADCgUIBQAAAA==.',['丶就']='丶就是傲气:BAABLAAFFH8GAAIQAAIIWB6uCgCtAAAQAAIIWB6uCgCtAAAAAA==.',['丶漒']='丶漒顔灬歡笶:BAAALAAECgYICAAAAA==.',['丶灬']='丶灬小柒:BAAALAAFFAIIAgAAAA==.',['丶羊']='丶羊角儿:BAAALAAFFAIIAgAAAA==.',['丶那']='丶那个贼:BAAALAAFFAEIAQAAAA==.',['主教']='主教:BAAALAAECgYIEgAAAA==.',['丿尛']='丿尛丶柒:BAAALAAECgMIAwAAAA==.',['乌龙']='乌龙茶:BAAALAAECgYIEQAAAA==.',['九月']='九月又鹰飞:BAAALAADCggICAAAAA==.',['二大']='二大爷:BAAALAADCgIIAgAAAA==.',['亡治']='亡治核:BAACLAAFFH8JAAIBAAIIVxftVABxAAABAAIIVxftVABxAAAsAAQKfxQAAgEACAibGZtCABYCAAEACAibGZtCABYCAAAA.',['伊夜']='伊夜柒次狼:BAAALAAECgYIBgAAAA==.',['伏地']='伏地老萨满:BAAALAADCgEIAQAAAA==.',['休息']='休息休息:BAAALAAFFAQIBAAAAA==.',['伸手']='伸手表影:BAAALAADCgYIBgAAAA==.',['佚名']='佚名奕:BAAALAAECgYIBgAAAA==.佚名逸:BAAALAAECgQIBQAAAA==.',['你们']='你们缺德不:BAAALAADCggICAAAAA==.你们缺德嘛:BAAALAAECgQIBAAAAA==.',['你跟']='你跟谁俩呢:BAAALAAECgYICwAAAA==.',['依然']='依然灬楓落:BAABLAAFFH8JAAMEAAMIXg0AUAB6AAAEAAMIUQ0AUAB6AAARAAEIDBc0HwAAAAAAAA==.',['修女']='修女:BAAALAAECgYIDAAAAA==.',['倔强']='倔强的蚂蚁:BAAALAADCgQIBAAAAA==.',['倚枪']='倚枪笑红尘:BAAALAAFFAIIAgAAAA==.',['偷偷']='偷偷摸摸:BAAALAAECgYIAwAAAA==.',['傻傻']='傻傻的傻妞:BAAALAAECgUIBQAAAA==.',['兔斯']='兔斯猎夫斯基:BAAALAAECgUIBQAAAA==.',['全聚']='全聚德男鸭:BAAALAAECgYICwAAAA==.',['公正']='公正怜悯谦卑:BAAALAAECgYICwAAAA==.',['内酷']='内酷玫川:BAABLAAFFH8PAAILAAQIMg5WLQDOAAALAAQIMg5WLQDOAAAAAA==.',['冰封']='冰封無情:BAAALAAFFAQIBAAAAA==.',['冲锋']='冲锋拦截:BAAALAAECgUIBQAAAA==.',['决战']='决战巴哈:BAAALAAECgYIDQAAAA==.',['剎那']='剎那芳华:BAAALAAECgYICQAAAA==.',['劳资']='劳资无罪:BAAALAAECgIIAgAAAA==.',['十二']='十二蒲柔:BAAALAADCgcIBwAAAA==.',['千年']='千年丶咸蛋:BAAALAAECgUICQAAAA==.',['千锤']='千锤百炼:BAAALAAECgYIEgAAAA==.',['午夜']='午夜:BAABLAAECn8WAAISAAcIIBguHABmAQASAAcIIBguHABmAQAAAA==.',['华丽']='华丽谢幕:BAAALAAECgYICwAAAA==.',['华风']='华风:BAAALAAFFAIIAgAAAA==.',['南冥']='南冥:BAAALAAECgYIBgAAAA==.',['卡卡']='卡卡西:BAAALAAECgQIBAAAAA==.',['卡纱']='卡纱布蓝卡:BAAALAAECgUICQAAAA==.',['卸你']='卸你篮子:BAABLAAFFH8HAAMTAAYIeAqTBwCEAQATAAYIeAqTBwCEAQAPAAEIuwNTVQA4AAAAAA==.',['叁点']='叁点壹肆壹伍:BAAALAADCgMIAwAAAA==.',['双刀']='双刀火鸡:BAAALAAECgYIBgAAAA==.',['变异']='变异牛:BAAALAADCgIIAgAAAA==.',['古尔']='古尔单之颅:BAAALAAECgYIBgAAAA==.',['古德']='古德莱克:BAABLAAFFH8kAAQKAAYIoB5LCwCsAQAKAAYIVh5LCwCsAQAUAAMIShPHCQCRAAAVAAEIBQOaUgAoAAAAAA==.古德阿芙特嫩:BAABLAAFFH8IAAICAAQIZgvWSwBjAAACAAQIZgvWSwBjAAABLAAFFAYICQABAFcXAA==.',['可心']='可心可心:BAAALAAECgcIEwAAAA==.',['可爱']='可爱又迷人:BAAALAAFFAMIBAAAAA==.',['吃人']='吃人晨:BAABLAAFFH8GAAIIAAIIyQvLcwB7AAAIAAIIyQvLcwB7AAAAAA==.',['同在']='同在的圣光:BAAALAAFFAIIAgAAAA==.',['吟赏']='吟赏烟霞:BAAALAAECgYIBgAAAA==.',['吴彦']='吴彦祖:BAAALAAECgYIBgAAAA==.',['吴筱']='吴筱闹:BAAALAAECgQIBAAAAA==.',['呜喵']='呜喵不怕:BAAALAAFFAIIBAAAAA==.',['咕嘚']='咕嘚呗:BAAALAAECgYICQAAAA==.',['哎呀']='哎呀嘿嗨哟:BAAALAAECgQIBAAAAA==.',['唐门']='唐门衮衮:BAABLAAFFH8GAAIRAAIIkgiFGgCNAAARAAIIkgiFGgCNAAAAAA==.',['唯一']='唯一:BAAALAAECgUIBgAAAA==.',['喧闹']='喧闹的孤独:BAAALAADCgMIAwAAAA==.',['噬魂']='噬魂邪僧:BAAALAAECgEIAQAAAA==.',['四年']='四年级班干部:BAACLAAFFH8HAAIIAAIIHBCpZACIAAAIAAIIHBCpZACIAAAsAAQKfxQAAwkACAjTF/sMAH0BAAkACAjAEPsMAH0BAAgACAjTF590AFsBAAAA.',['回噫']='回噫曾经:BAABLAAFFH8JAAIQAAII8SGiDACgAAAQAAII8SGiDACgAAAAAA==.',['回忆']='回忆灬逝去:BAAALAAECgEIAQAAAA==.',['团灭']='团灭丨发动机:BAABLAAFFH8LAAIWAAYIsBzQCgDYAQAWAAYIsBzQCgDYAQAAAA==.',['圣光']='圣光妠利塔:BAAALAADCgYIBgAAAA==.圣光永远超神:BAAALAAFFAIIAgAAAA==.圣光派左卫:BAAALAAECggICAAAAA==.',['圣斗']='圣斗士圣骑:BAAALAAECgYIBgAAAA==.',['圣殿']='圣殿丶骑士:BAAALAAECgYIBwAAAA==.',['圣白']='圣白莲:BAAALAAECgUIBQAAAA==.',['堕髓']='堕髓亡骑:BAAALAAECgYIEQAAAA==.',['墨羽']='墨羽:BAAALAAECgEIAQAAAA==.',['声声']='声声漫:BAAALAAFFAIIBAAAAA==.',['多巴']='多巴胺牛:BAAALAAECgYIDQAAAA==.',['夜行']='夜行妞妞:BAAALAAECgUIBQAAAA==.',['大地']='大地之魂:BAAALAADCgEIAQAAAA==.',['大漠']='大漠孤烟:BAAALAAFFAYIAgAAAA==.',['大猫']='大猫:BAABLAAECn8XAAIUAAgI7hGGHwCZAQAUAAgI7hGGHwCZAQAAAA==.',['天涯']='天涯若比邻:BAACLAAFFH8KAAMQAAIIQh2fCwCmAAAQAAIIQh2fCwCmAAACAAIIvhojTgBRAAAsAAQKfxUAAxAABgg2GjBtALkAAAIABAhLFKfAAPYAABAABAjIHTBtALkAAAAA.',['天鹅']='天鹅湾网格员:BAABLAAFFH8UAAICAAUIBRX8LADdAAACAAUIBRX8LADdAAAAAA==.',['太阳']='太阳的来财:BAAALAAECgIIAgAAAA==.',['头顶']='头顶大波斯菊:BAAALAAFFAIIBAAAAA==.',['夺命']='夺命乌苏:BAAALAAFFAIIAgAAAA==.',['奔放']='奔放的生理期:BAACLAAFFH8KAAIVAAIIzR3eHgCnAAAVAAIIzR3eHgCnAAAsAAQKfxgAAhUACAhHHrgVALACABUACAhHHrgVALACAAAA.',['奔波']='奔波霸:BAAALAAECgYIBAAAAA==.',['奔雷']='奔雷剑主大奔:BAAALAAFFAMIBAAAAA==.',['奥蕾']='奥蕾莉哑:BAAALAAECgYIBgAAAA==.',['奥麦']='奥麦嘎德:BAAALAAECgEIAQAAAA==.',['奶酪']='奶酪:BAAALAAECgEIAQAAAA==.',['她永']='她永远第一:BAAALAAFFAIIAgAAAA==.',['好嗨']='好嗨瑶:BAAALAAECggIAgAAAA==.',['妙狩']='妙狩空空:BAAALAAECgQIBAAAAA==.',['孑孓']='孑孓:BAAALAAECgYIDAAAAA==.',['宇宙']='宇宙圣骑:BAAALAAECgcIDwAAAA==.宇宙无敌猹猹:BAAALAAFFAIIAgAAAA==.',['宇智']='宇智波止水:BAAALAAFFAIIAgAAAA==.',['安吉']='安吉利托疤:BAAALAADCgYIBgAAAA==.',['安屠']='安屠村疼话:BAAALAADCgcIBwAAAA==.',['宝宝']='宝宝的小花花:BAAALAAECggICAABLAAFFAYIBgACACcFAA==.',['宫爆']='宫爆鸡丁:BAABLAAFFH8IAAMBAAgIPRdzHQBxAQABAAYIxBZzHQBxAQALAAIIZhHlMACkAAAAAA==.',['寳气']='寳气:BAAALAADCgUIBQAAAA==.',['寻你']='寻你千百度:BAAALAAECgUIBQAAAA==.',['封神']='封神冥月:BAACLAAFFH8mAAMXAAYIDhrTDACuAAAYAAQIIBM0EAABAQAXAAMImBzTDACuAAAsAAQKfxYAAxgACAiJHWAKAL8BABgACAimGGAKAL8BABcAAwgAIEcWALMAAAAA.',['小伙']='小伙伴:BAAALAAECgYIDgAAAA==.',['小卒']='小卒子:BAAALAADCgMIAwAAAA==.',['小小']='小小拓跋菩萨:BAABLAAFFH8FAAIOAAMIMgj9RABtAAAOAAMIMgj9RABtAAAAAA==.',['小洗']='小洗只狼:BAACLAAFFH8aAAIZAAUI6RKxCwBDAQAZAAUI6RKxCwBDAQAsAAQKfx8AAhkACAi4GysKABwCABkACAi4GysKABwCAAEsAAUUBggfAAEA2yAA.',['小熊']='小熊丶蛋包饭:BAAALAAECgMIAwAAAA==.',['小竹']='小竹子想熊猫:BAAALAAECgYICwAAAA==.',['小红']='小红薯:BAAALAAFFAIIBAAAAA==.',['小萨']='小萨鲁法尔:BAAALAAECgYIBgAAAA==.',['小阿']='小阿的女人:BAABLAAFFH8GAAIFAAIIYgqpgwCEAAAFAAIIYgqpgwCEAAAAAA==.',['小鱼']='小鱼幽幽:BAAALAAECgIIAgAAAA==.',['小黄']='小黄山帅:BAAALAAECgcICwAAAA==.小黄山火:BAAALAADCggICAAAAA==.',['尼傲']='尼傲兹:BAABLAAFFH8MAAINAAYIKhUrBgCuAQANAAYIKhUrBgCuAQAAAA==.',['尼奥']='尼奥兹:BAABLAAFFH8FAAIVAAQIhgcMLAC9AAAVAAQIhgcMLAC9AAAAAA==.尼奥奥龙:BAABLAAFFH8MAAMaAAYI9BEjEQAFAQAaAAUIQREjEQAFAQAbAAUIeQWUEgDuAAAAAA==.尼奥奥龙龙:BAABLAAFFH8NAAMbAAUIbQqZEQAIAQAbAAUIbQqZEQAIAQAcAAMIZBJ/DAB+AAAAAA==.尼奥战:BAABLAAECn8XAAIPAAgI7xg5OQBQAgAPAAgI7xg5OQBQAgAAAA==.尼奥术:BAABLAAFFH8WAAIEAAYISCMVFgDYAQAEAAYISCMVFgDYAQAAAA==.尼奥萨:BAACLAAFFH8lAAMLAAYI6h9gGAB7AQALAAUI1CBgGAB7AQABAAUIxA8qJgC6AAAsAAQKfxYAAwEACAg/FFJXAN8BAAEACAg/FFJXAN8BAAsABgj7Ig0bANIBAAAA.尼奥骑:BAAALAAFFAIIAgAAAA==.尼奥龙:BAABLAAFFH8oAAMaAAYI6B7gCQB9AQAaAAUIByDgCQB9AQAbAAUIJROfCAA+AQAAAA==.尼奥龙龙:BAABLAAFFH8VAAQcAAYIPBO3CAAFAQAcAAUIlg63CAAFAQAaAAQIPQ/2FACvAAAbAAIIuArRGQBwAAAAAA==.',['尼尼']='尼尼奥龙:BAABLAAFFH8KAAMbAAYI+QxAEQAQAQAbAAUIpAtAEQAQAQAcAAIIZAWvDAB6AAAAAA==.',['川上']='川上富江:BAABLAAECn8cAAIDAAYI7SXvHQAnAgADAAYI7SXvHQAnAgABLAAFFAIIAgAdAAAAAA==.',['工大']='工大小贼:BAABLAAFFH8FAAIYAAMIPQ91DQD7AAAYAAMIPQ91DQD7AAAAAA==.',['差太']='差太多了:BAABLAAFFH8IAAIEAAIIvRpyVwBKAAAEAAIIvRpyVwBKAAAAAA==.',['帅武']='帅武:BAAALAAFFAIIAgAAAA==.',['希尔']='希尔瑟拉夜哀:BAABLAAECn8YAAIJAAYIZg8KYgA4AQAJAAYIZg8KYgA4AQAAAA==.希尔瓦娜娜思:BAAALAAECgcIBwAAAA==.',['幽幽']='幽幽寒:BAAALAAECgUIBQAAAA==.',['康杰']='康杰丶骄子:BAAALAAFFAIIAgAAAA==.',['廉颇']='廉颇老矣:BAAALAAECgYIDQAAAA==.',['弗拉']='弗拉基米尔丶:BAAALAAECgMIAwAAAA==.',['张飞']='张飞倍黑:BAABLAAFFH8IAAIFAAIIIAjMiABCAAAFAAIIIAjMiABCAAAAAA==.',['弥丨']='弥丨海砂:BAAALAAFFAIIAgAAAA==.',['彻悟']='彻悟德:BAAALAAFFAIIAgAAAA==.',['徐老']='徐老御用保镖:BAAALAAECgMIAwAAAA==.',['德智']='德智体美:BAAALAADCgIIAwAAAA==.',['德菜']='德菜兼备:BAAALAAECgUIBQAAAA==.',['心灭']='心灭遗言:BAABLAAFFH8GAAMYAAII4gwdIQBUAAAYAAEIBxAdIQBUAAAXAAEIvAlUHgA9AAABLAAFFAIIBwAOANMRAA==.',['怒斩']='怒斩:BAAALAAECgYIEwAAAA==.',['恰同']='恰同学少年:BAAALAAFFAIIAgAAAA==.',['恶臭']='恶臭熏死你们:BAAALAAECgYIEQAAAA==.',['悦悦']='悦悦:BAAALAAECgIIAgAAAA==.',['我冲']='我冲锋呢:BAAALAAECggICAABLAAFFAYIJQAYAL0TAA==.',['我叫']='我叫梅办法:BAAALAAECgEIAQAAAA==.',['我有']='我有两个蜜蜂:BAAALAAFFAIIAwAAAA==.',['我见']='我见花开:BAAALAADCgYIBgAAAA==.',['战野']='战野八荒:BAAALAAECggICAAAAA==.',['戦訷']='戦訷:BAAALAAECgYICwAAAA==.',['戰凰']='戰凰:BAACLAAFFH8FAAIDAAIIcwu+ZwBCAAADAAIIcwu+ZwBCAAAsAAQKfxgAAgMABgiqGQRGAIoBAAMABgiqGQRGAIoBAAAA.',['手绢']='手绢:BAAALAAECgYIBwAAAA==.',['把低']='把低俗变高雅:BAAALAADCgIIAgAAAA==.',['把尼']='把尼们都鲨了:BAAALAAECggIEwAAAA==.',['抹茶']='抹茶拿铁丶:BAAALAAFFAMIAwAAAA==.',['拓跋']='拓跋菩萨:BAABLAAFFH8FAAIIAAMIZAVxeQBpAAAIAAMIZAVxeQBpAAAAAA==.',['放开']='放开她让我来:BAACLAAFFH8OAAMWAAUI1h3vCwDFAQAWAAUI1h3vCwDFAQADAAMI/xOHPACiAAAsAAQKfyMAAxYACAgNIAcEAN8CABYACAgNIAcEAN8CAAMABAjbGhz8ADABAAAA.',['放開']='放開那個女孩:BAACLAAFFH8YAAILAAMIvhU6GQDqAAALAAMIvhU6GQDqAAAsAAQKfzEAAgsABwjxIHAkAIsCAAsABwjxIHAkAIsCAAAA.',['救赎']='救赎丶無用:BAAALAAECgYICgAAAA==.',['斯巴']='斯巴达克:BAAALAADCgIIAgAAAA==.',['斯摩']='斯摩格:BAAALAAFFAIIAgAAAA==.',['旋涡']='旋涡异族:BAACLAAFFH8IAAIOAAMITQbmJQDIAAAOAAMITQbmJQDIAAAsAAQKfxgAAg4ACAjxGrJBAF0CAA4ACAjxGrJBAF0CAAAA.',['旋风']='旋风剑主达达:BAABLAAFFH8HAAIFAAIIcxrKZACWAAAFAAIIcxrKZACWAAAAAA==.',['无敌']='无敌最凶狠:BAABLAAFFH8VAAMLAAgI4RWUBwA+AgALAAgI4RWUBwA+AgABAAUIKghaMwDaAAAAAA==.',['早安']='早安晚安:BAAALAAECgYIBwAAAA==.',['旺仔']='旺仔乌龙茶:BAAALAADCgUIBQAAAA==.',['星之']='星之金幣:BAAALAAECgYICwAAAA==.',['星刹']='星刹:BAAALAADCgIIAgAAAA==.',['晋钢']='晋钢罗斯:BAABLAAFFH8GAAIJAAYI0yBBBACgAQAJAAYI0yBBBACgAQAAAA==.晋钢葫芦娃:BAABLAAFFH8uAAIIAAgIOSYoAAAlAwAIAAgIOSYoAAAlAwAAAA==.晋钢螺丝:BAABLAAFFH8KAAIIAAgIfhZwDQAeAgAIAAgIfhZwDQAeAgAAAA==.',['晓丶']='晓丶猎手:BAAALAAECgYIBgAAAA==.晓丶骑士:BAAALAADCgUIBQAAAA==.',['晚来']='晚来天欲雪:BAAALAAFFAIIAgAAAA==.',['暖羊']='暖羊羊:BAAALAAECggIBwAAAA==.',['暴力']='暴力双鱼:BAABLAAFFH8HAAIVAAMIXxEwLQC3AAAVAAMIXxEwLQC3AAAAAA==.',['暴山']='暴山大爷:BAAALAAFFAEIAQAAAA==.',['暴走']='暴走兔兔:BAAALAAECgYICwAAAA==.',['曼陀']='曼陀罗:BAAALAAECgQIBgAAAA==.',['朗姆']='朗姆青提丶:BAAALAAECgIIAgAAAA==.',['朮爷']='朮爷灬:BAAALAAECgYICgAAAA==.',['朽木']='朽木白哉:BAAALAAECgYIBgAAAA==.',['杀戮']='杀戮术:BAAALAAECgMIAwAAAA==.',['李富']='李富贵:BAAALAAECgYIDAAAAA==.',['李秋']='李秋水:BAAALAAECgYIBgAAAA==.',['杨梅']='杨梅酪酪:BAABLAAFFH8JAAIFAAIIqx4ZWgCbAAAFAAIIqx4ZWgCbAAAAAA==.',['杰克']='杰克逊:BAAALAAECgUIBQAAAA==.',['杰洛']='杰洛丶齐贝林:BAAALAAECgEIAQAAAA==.',['柴干']='柴干:BAAALAAECgIIAgAAAA==.',['核心']='核心价值观:BAAALAAECgQIBAAAAA==.',['桂花']='桂花引:BAAALAAECgYIBgAAAA==.',['梦想']='梦想天生:BAAALAAECgYICQAAAA==.',['梨花']='梨花糕糕:BAAALAAECggIEAAAAA==.',['梵凡']='梵凡:BAACLAAFFH8yAAIEAAcIDhf7FgDSAQAEAAcIDhf7FgDSAQAsAAQKfxsAAgQACAjuIXsPAG8CAAQACAjuIXsPAG8CAAAA.',['橘子']='橘子猫:BAABLAAFFH8MAAIVAAIInRrjNwCLAAAVAAIInRrjNwCLAAAAAA==.',['橙多']='橙多多:BAAALAAECgYIBgAAAA==.',['武敌']='武敌:BAAALAAECgYICgAAAA==.',['死亡']='死亡傳說:BAAALAAECgMIAwAAAA==.',['死灵']='死灵:BAAALAAECgYICAAAAA==.',['汕村']='汕村貞子:BAAALAAECgUIBwABLAAFFAIIAgAdAAAAAA==.',['江大']='江大荒:BAAALAAECgEIAQAAAA==.',['污药']='污药王:BAAALAAECgQIBAAAAA==.',['沙漠']='沙漠死骑:BAAALAAECgEIAQAAAA==.沙漠灬之狐:BAAALAAECgUICQAAAA==.',['没事']='没事只想躺:BAABLAAECn8iAAIIAAcI1RWWmgC0AQAIAAcI1RWWmgC0AQAAAA==.',['法爆']='法爆异常:BAAALAADCgUIBQAAAA==.',['泥泥']='泥泥洋:BAAALAAECgYIDAAAAA==.',['流浪']='流浪的小丑:BAAALAAECggICAAAAA==.',['浅唱']='浅唱丶幽蓝:BAACLAAFFH8gAAQPAAYIqRK8HACDAQAPAAYIqRK8HACDAQATAAIIrAwDJAB2AAAeAAIIRgZTBgA3AAAsAAQKfxYAAw8ABgiPHcwxAJIBAA8ABgg0HcwxAJIBABMABgjCFQI9AJEBAAAA.',['海南']='海南黄花梨:BAAALAAFFAMIAwAAAA==.',['深情']='深情的独白:BAAALAADCgMIAwAAAA==.深情终被辜负:BAAALAAFFAIIAgAAAA==.',['深水']='深水大弹:BAAALAAECgIIAgAAAA==.',['清灬']='清灬凈:BAAALAAECgIIAgABLAAFFAgIBAAdAAAAAA==.',['温柔']='温柔狂刀:BAAALAAECgYIBgAAAA==.',['湮灭']='湮灭心扉:BAAALAADCgIIAgAAAA==.',['滚卒']='滚卒子:BAAALAADCgIIAwAAAA==.',['潮涌']='潮涌之歌:BAAALAAECggICAAAAA==.',['澜沧']='澜沧骑士:BAAALAAFFAIIAgAAAA==.',['火之']='火之泪:BAAALAAECgQICAAAAA==.',['灬卡']='灬卡露蜜拉:BAABLAAFFH8HAAIFAAMIrgqXawBjAAAFAAMIrgqXawBjAAAAAA==.',['灬嘟']='灬嘟噜嘟:BAAALAAFFAMIBAAAAA==.',['灬天']='灬天启灬:BAAALAAECgEIAQAAAA==.',['灬潜']='灬潜龍灬:BAAALAAECggIBwAAAA==.',['灬血']='灬血魂祭影灬:BAABLAAFFH8MAAMBAAYISRUWCQCsAQABAAYISRUWCQCsAQALAAUIdw4pJwANAQAAAA==.',['灬赛']='灬赛罗:BAABLAAFFH8LAAIBAAMI4h54LAAEAQABAAMI4h54LAAEAQAAAA==.',['灵魂']='灵魂汁子浇給:BAAALAADCgEIAQAAAA==.',['炒河']='炒河粉加俩蛋:BAAALAAFFAIIAgAAAA==.',['炽焰']='炽焰晴风:BAAALAAFFAIIAwAAAA==.',['烈焰']='烈焰达尼兹:BAAALAAECgYICwAAAA==.',['热乂']='热乂夏:BAAALAAFFAIIAgAAAA==.',['热情']='热情过了头:BAABLAAFFH8bAAIIAAcI8AxyPQBPAQAIAAcI8AxyPQBPAQAAAA==.',['無盡']='無盡的不结冰:BAABLAAFFH8MAAIFAAYInAFwVAC8AAAFAAYInAFwVAC8AAAAAA==.無盡的嘿炮卜:BAABLAAFFH8JAAMfAAMIUgOVSABZAAAfAAIIWwSVSABZAAASAAMIYQVsJQBPAAAAAA==.',['無限']='無限:BAAALAAECgMIAwAAAA==.',['熊喵']='熊喵舞:BAAALAAECgUIBQAAAA==.',['爱尔']='爱尔仙克:BAAALAAECgMIAwAAAA==.',['爱英']='爱英雄:BAAALAAFFAMIAwAAAA==.',['牛气']='牛气霸天:BAAALAAECgUIBQAAAA==.',['牛牛']='牛牛气冲天:BAAALAAECgYICgAAAA==.',['牧色']='牧色撩人:BAAALAAECgYIBwAAAA==.',['狂奔']='狂奔的兔子:BAAALAAFFAIIAgAAAA==.',['猛牛']='猛牛硝酸乳:BAAALAAECgYIDQAAAA==.',['猫猫']='猫猫啲诅咒:BAAALAAFFAIIAgAAAA==.',['王的']='王的女人:BAAALAAECgYIEAAAAA==.',['王维']='王维:BAAALAAFFAIIAgAAAA==.',['玖玖']='玖玖宝贝:BAABLAAFFH8HAAILAAMISw41GwDdAAALAAMISw41GwDdAAAAAA==.',['玛哈']='玛哈嘎拉:BAAALAAECgQICQAAAA==.',['玛莲']='玛莲妮亚:BAAALAAECgYIBgAAAA==.',['球迷']='球迷杏眼的帅:BAAALAAECgYIDwAAAA==.',['琥珀']='琥珀看守者:BAABLAAFFH8JAAIDAAIIDCPlIwDDAAADAAIIDCPlIwDDAAAAAA==.',['生命']='生命因你火热:BAAALAAECggICAAAAA==.',['田德']='田德莉娜:BAAALAADCgEIAQAAAA==.',['疯狂']='疯狂之法爷:BAAALAADCgEIAQAAAA==.',['白浅']='白浅:BAAALAADCggICAAAAA==.',['白白']='白白净净:BAAALAAECgYICAAAAA==.',['白银']='白银判官:BAABLAAECn8UAAIFAAYI6QwfbgASAQAFAAYI6QwfbgASAQAAAA==.',['白露']='白露未晞:BAAALAAFFAYIAgAAAA==.',['百鬼']='百鬼夜行:BAAALAADCgYIBwAAAA==.',['皓宝']='皓宝:BAABLAAFFH8NAAIDAAUINSHRGgCEAQADAAUINSHRGgCEAQABLAAFFAgIFQAEAJMbAA==.',['盗尛']='盗尛妹:BAAALAADCggICAAAAA==.',['真好']='真好玩:BAAALAAECgYICgAAAA==.',['真是']='真是厉害:BAAALAAECgQIBAAAAA==.',['瞎小']='瞎小瞎:BAABLAAECn8dAAIOAAYIkxyDdwDWAQAOAAYIkxyDdwDWAQAAAA==.',['破風']='破風生霊:BAACLAAFFH8vAAMLAAgI8xghBwAOAgALAAcI+BchBwAOAgABAAYIuBHxHADWAAAsAAQKfzAAAwsACAjYI2MmAIACAAsABgieJGMmAIACAAEACAhNF/N1AJYBAAAA.',['社会']='社会王:BAAALAAECgIIAgAAAA==.',['神农']='神农架三胖子:BAAALAAECggICAAAAA==.',['秃哥']='秃哥亲亲我:BAABLAAFFH8bAAIPAAYIFSCmDwDbAQAPAAYIFSCmDwDbAQAAAA==.秃哥抱抱我:BAABLAAFFH8XAAMQAAYIZR2PAgDLAQAQAAYIZR2PAgDLAQAgAAYInw3bAwBYAQAAAA==.秃哥玩犭昔人:BAABLAAFFH8iAAIIAAYIdSMMFQDpAQAIAAYIdSMMFQDpAQAAAA==.',['秃头']='秃头骑士:BAACLAAFFH8tAAMFAAYI3CQnDgAgAgAFAAYI3CQnDgAgAgAGAAEI6AGMHgAnAAAsAAQKfxkAAwUACAiII9tBAHwCAAUACAjUIdtBAHwCAAYACAjXGtodAKABAAAA.',['秋香']='秋香:BAAALAAECgMIAwAAAA==.',['筱恶']='筱恶魔:BAAALAAECgUIBQAAAA==.',['箭雨']='箭雨卷岚的酥:BAAALAAECgYIEgAAAA==.',['篱掌']='篱掌:BAAALAAECgEIAQAAAA==.',['米唐']='米唐门氵衮:BAAALAAFFAEIAQAAAA==.',['米歇']='米歇尔如烟:BAAALAAECgMIAwAAAA==.',['类似']='类似香水:BAACLAAFFH8YAAMYAAUIWhk0DABKAQAYAAUIWhk0DABKAQAXAAIImQnIFQCDAAAsAAQKfxcAAxcABwi9F1YfAJkBABgABggtGNgxAKIBABcABwhnEVYfAJkBAAAA.',['粉面']='粉面鸡蛋:BAAALAADCgYIBgAAAA==.',['糖醋']='糖醋面筋:BAAALAAFFAIIAwAAAA==.',['糖門']='糖門滚:BAAALAAECgEIAQAAAA==.',['紫龍']='紫龍:BAAALAAFFAQIBAAAAA==.',['纠杰']='纠杰伦:BAAALAADCgUIAQAAAA==.',['维伦']='维伦黛儿:BAAALAADCgUIBQAAAA==.',['网管']='网管李大爷:BAACLAAFFH8bAAIKAAYI8BPMEgBQAQAKAAYI8BPMEgBQAQAsAAQKfzgAAgoACAi3IlQTAM0CAAoACAi3IlQTAM0CAAAA.',['罪域']='罪域丶骨王:BAAALAAECgIIAgAAAA==.',['美杜']='美杜莎狐狐:BAAALAAECgYICgAAAA==.',['翠花']='翠花上酸菜:BAAALAAECgYIBwAAAA==.翠花骑酸菜:BAAALAAFFAEIAQAAAA==.',['翩若']='翩若惊鸿:BAAALAAFFAYIBAAAAA==.',['老恭']='老恭:BAAALAAECggIDgAAAA==.',['耳朵']='耳朵大有狐:BAAALAAECgMIAwAAAA==.',['聆听']='聆听过往的诗:BAAALAAECgYIBgAAAA==.',['至尊']='至尊奶爸:BAAALAAECgUIBQAAAA==.',['舒达']='舒达吉:BAAALAAECgYIBgAAAA==.',['舞雾']='舞雾我:BAAALAAECgYIBwAAAA==.',['花子']='花子:BAAALAAECgYICQABLAAFFAIIAgAdAAAAAA==.',['苍鹰']='苍鹰姿色:BAAALAAECgYIBgAAAA==.',['范达']='范达尔鹿盔丶:BAAALAAECgYIBgAAAA==.',['荣耀']='荣耀的子弹:BAAALAAECgYIBgAAAA==.',['莎琪']='莎琪玛:BAAALAAECgYIEAAAAA==.',['莫狼']='莫狼:BAABLAAFFH8QAAIIAAMIfBwNMADGAAAIAAMIfBwNMADGAAAAAA==.',['萨尓']='萨尓曼德兰:BAAALAADCgEIAQAAAA==.',['萨满']='萨满咋回血:BAAALAAFFAEIAQAAAA==.',['萨珂']='萨珂麦蒂克:BAAALAAFFAMIAwABLAAFFAYICQABAFcXAA==.',['萨莱']='萨莱因:BAAALAAECgEIAQAAAA==.',['落月']='落月无痕:BAAALAADCgcIBwAAAA==.',['葫芦']='葫芦小晋钢:BAABLAAFFH8qAAIIAAgIzyV6AAAVAwAIAAgIzyV6AAAVAwAAAA==.',['蓝莓']='蓝莓黑巧丶:BAAALAAFFAMIAwAAAA==.',['蓬莱']='蓬莱人偶:BAAALAAFFAMIAwAAAA==.',['蔷薇']='蔷薇猎手:BAABLAAFFH8JAAMIAAIIxBAFnwA+AAAJAAIIEAn0LwBhAAAIAAIIxBAFnwA+AAAAAA==.',['虚九']='虚九戒:BAABLAAFFH8GAAIWAAIIbQqaIwB9AAAWAAIIbQqaIwB9AAAAAA==.',['虚空']='虚空之女:BAAALAAECgMIAwAAAA==.',['蛋蛋']='蛋蛋丶小肥牛:BAAALAADCgUIBQAAAA==.蛋蛋灬忧桑:BAAALAAFFAYIBAAAAA==.',['蜂蜜']='蜂蜜慕斯:BAAALAAECgEIAQAAAA==.',['蜘蛛']='蜘蛛侦探:BAABLAAFFH8GAAIDAAII/hT1PwCeAAADAAII/hT1PwCeAAAAAA==.',['蟑螂']='蟑螂恶霸:BAABLAAFFH8LAAMJAAIIKyMgEwDNAAAJAAIIKyMgEwDNAAAIAAIIXRlAlABDAAAAAA==.',['血朦']='血朦胧:BAAALAAECggICAAAAA==.',['行二']='行二可:BAAALAAECgUIBQAAAA==.',['被腐']='被腐蚀的圣光:BAAALAAECgYIBgAAAA==.',['装备']='装备库:BAAALAAECgYIDAAAAA==.',['裤子']='裤子顶起来:BAAALAAECgYIBgAAAA==.',['西属']='西属撒哈拉:BAAALAAFFAIIBAAAAA==.',['西红']='西红柿大明星:BAAALAAECgYIBgAAAA==.',['解散']='解散门徒:BAACLAAFFH9LAAMWAAgINSSEAAA+AwAWAAgINSSEAAA+AwADAAEIHAGxhQASAAAsAAQKfykAAhYACAhGIzwEACIDABYACAhGIzwEACIDAAAA.',['觸景']='觸景傷情:BAABLAAECn8XAAICAAYI+R2FKgByAQACAAYI+R2FKgByAQAAAA==.',['记忆']='记忆中小小:BAACLAAFFH8RAAIPAAUIJAofKgAbAQAPAAUIJAofKgAbAQAsAAQKfxoAAg8ACAjAFqE0AIcBAA8ACAjAFqE0AIcBAAAA.记忆中的怀念:BAACLAAFFH8OAAIDAAMIHxRgQgCNAAADAAMIHxRgQgCNAAAsAAQKfyAAAgMACAiZH/sqAMUCAAMACAiZH/sqAMUCAAAA.记忆中的思念:BAACLAAFFH8RAAIfAAUIshRTHgBZAQAfAAUIshRTHgBZAQAsAAQKfxkAAx8ACAiqG+sSADkCAB8ABggcIesSADkCABIAAgjCA62fADEAAAAA.记忆中的想念:BAABLAAFFH8GAAIOAAIIOxHzSQBPAAAOAAIIOxHzSQBPAAAAAA==.记忆中的执念:BAAALAAFFAIIAgAAAA==.记忆中的理念:BAAALAAFFAIIBAAAAA==.记忆中的纪念:BAACLAAFFH8KAAIIAAIItxK0YACLAAAIAAIItxK0YACLAAAsAAQKfxUAAggACAhTHXAqAA4CAAgACAhTHXAqAA4CAAAA.记忆随风流浙:BAAALAAFFAIIAgAAAA==.记忆随风流逝:BAACLAAFFH8IAAIQAAIILBEWFwBBAAAQAAIILBEWFwBBAAAsAAQKfxgAAhAABggGGLcyAK0BABAABggGGLcyAK0BAAAA.',['豹纹']='豹纹奶爸:BAAALAAFFAIIAgAAAA==.',['贝果']='贝果儿:BAAALAAECgYIAQAAAA==.',['贰玥']='贰玥丶:BAAALAAECggICAAAAA==.',['贱賊']='贱賊賊贱:BAABLAAFFH8HAAIhAAMIIhNMAgDsAAAhAAMIIhNMAgDsAAAAAA==.',['费舍']='费舍尔丶泰格:BAAALAAECgYICwAAAA==.',['费雷']='费雷罗:BAAALAAECgcIDgAAAA==.',['贼丨']='贼丨皇:BAAALAAECgYIBwAAAA==.',['贼来']='贼来贼去:BAAALAAFFAIIAgAAAA==.',['赎罪']='赎罪的流浪人:BAABLAAFFH8PAAIEAAUIcgwmOwAbAQAEAAUIcgwmOwAbAQAAAA==.',['赞达']='赞达拉大王:BAAALAAECgUIBgAAAA==.',['越长']='越长大越寂寞:BAABLAAFFH8FAAIVAAMIIQhBOgCEAAAVAAMIIQhBOgCEAAAAAA==.',['路过']='路过皆是浪漫:BAAALAAECgMIAgABLAAFFAgIMwAYAOQjAA==.',['跳刀']='跳刀灬跳刀:BAAALAAFFAEIAQAAAA==.',['辉煌']='辉煌小小辰:BAAALAAECggIBgAAAA==.',['辛辣']='辛辣天赛:BAAALAAECgYICgAAAA==.',['达卡']='达卡夜阿:BAAALAAECgYIBwAAAA==.',['这回']='这回不偷偷:BAABLAAECn8ZAAIDAAYI7RmFUABtAQADAAYI7RmFUABtAQAAAA==.',['进击']='进击的小明:BAABLAAFFH8HAAIOAAII0xGUQQCYAAAOAAII0xGUQQCYAAAAAA==.',['迷霧']='迷霧天使:BAAALAAECgYIAQAAAA==.',['追忆']='追忆魔姬:BAAALAAECgYICQAAAA==.',['追月']='追月无痕:BAAALAADCggIDAAAAA==.',['逍遥']='逍遥牧:BAAALAAECgIIAgAAAA==.',['逝丶']='逝丶去:BAAALAAECgUIBgAAAA==.',['遗珠']='遗珠之憾:BAAALAAECgYIEgAAAA==.',['邓恩']='邓恩史密斯:BAAALAADCgUIBQAAAA==.',['那个']='那个谁:BAABLAAFFH8GAAICAAYIKBhHJwB3AQACAAYIKBhHJwB3AQAAAA==.',['邪丨']='邪丨皇:BAAALAAFFAIIBAAAAA==.',['酷酷']='酷酷小女人:BAAALAADCggIEwAAAA==.',['铁骥']='铁骥八旗:BAAALAAECgYIDQAAAA==.',['银魂']='银魂:BAABLAAFFH8IAAIFAAII7Rq+SQCmAAAFAAII7Rq+SQCmAAAAAA==.',['锋锋']='锋锋:BAAALAAECgYIDAAAAA==.',['长虹']='长虹剑主虹猫:BAAALAADCgYIBgAAAA==.',['闭着']='闭着眼看你:BAAALAADCgUIBQAAAA==.',['闹丶']='闹丶塔纳托斯:BAAALAAECgYIBgAAAA==.闹丶塔莉萨:BAAALAAECgYIDQAAAA==.闹丶穆拉钉:BAAALAAECgEIAQAAAA==.闹丶萨鲁法尔:BAAALAAECgYICQAAAA==.',['阿克']='阿克夏:BAABLAAFFH8GAAIVAAIIzQZlUABTAAAVAAIIzQZlUABTAAAAAA==.',['阿塔']='阿塔兰塔:BAAALAAECgYIBgAAAA==.',['阿姆']='阿姆克西亚:BAAALAAECgMIAgAAAA==.',['阿拉']='阿拉西奇:BAAALAAECgYICwAAAA==.',['阿斯']='阿斯达的勇士:BAABLAAFFH8JAAIDAAMIKQv9RgB+AAADAAMIKQv9RgB+AAAAAA==.',['阿莱']='阿莱西斯:BAABLAAFFH8GAAIFAAII6gX2kAB1AAAFAAII6gX2kAB1AAAAAA==.',['陌陌']='陌陌轻寒:BAAALAAECgUIBQAAAA==.',['雅儿']='雅儿贝德:BAAALAAFFAEIAQAAAA==.',['雪境']='雪境:BAAALAAECgYIAQAAAA==.',['雪山']='雪山飞狐:BAAALAAECgEIAQAAAA==.',['雪霏']='雪霏:BAAALAAFFAEIAQAAAA==.',['霜凝']='霜凝的终结:BAABLAAFFH8OAAIFAAgITwFmZACDAAAFAAgITwFmZACDAAAAAA==.',['霸王']='霸王龙刘能儿:BAAALAADCgYIBgAAAA==.',['青丘']='青丘丶白凤九:BAABLAAFFH8IAAIEAAYIwhH6LwBZAQAEAAYIwhH6LwBZAQAAAA==.',['青霜']='青霜丶重影:BAAALAAFFAIIBAAAAA==.',['青黛']='青黛丶:BAAALAAECgYICQAAAA==.',['頭鼑']='頭鼑冭胤曐:BAAALAAECgYIBgAAAA==.',['風凌']='風凌雪:BAAALAAECgUIAgAAAA==.',['风吹']='风吹半夏:BAAALAAFFAIIBAAAAA==.',['风暴']='风暴之影:BAAALAAECggICAAAAA==.风暴击倒大树:BAAALAAECgYICgAAAA==.风暴烈酒丶杨:BAAALAAECgEIAQAAAA==.',['飒蠻']='飒蠻:BAAALAAECgYIDQABLAAFFAgICAAIAOEZAA==.',['飛鳥']='飛鳥华:BAAALAAECgEIAQAAAA==.飛鳥芲:BAAALAAECgYICgAAAA==.飛鳥華:BAAALAAECgcIDAAAAA==.飛鳥鏵:BAAALAAECgYIBgAAAA==.',['飞舞']='飞舞的草莓:BAAALAAECgQIBAAAAA==.',['饥荒']='饥荒行者:BAAALAAECgUICAAAAA==.',['饭饭']='饭饭:BAABLAAFFH8GAAIPAAIIWhLrSABKAAAPAAIIWhLrSABKAAAAAA==.',['饿狼']='饿狼咆哮嗷呜:BAAALAADCgEIAQAAAA==.',['香吉']='香吉士:BAAALAAECgYICQAAAA==.',['香蕉']='香蕉牛奶牛:BAAALAAECgcICgAAAA==.',['驯兽']='驯兽小猎:BAAALAAECgEIAQAAAA==.',['骚气']='骚气:BAAALAAFFAIIBAAAAA==.',['骨汤']='骨汤一号:BAABLAAFFH8MAAINAAYItwuqEQAvAQANAAYItwuqEQAvAQAAAA==.骨汤七号:BAAALAAFFAYIAgAAAA==.骨汤三号:BAABLAAFFH8SAAINAAYIkg1YEABFAQANAAYIkg1YEABFAQAAAA==.骨汤九号:BAABLAAFFH8GAAINAAYIqQdQEwASAQANAAYIqQdQEwASAQAAAA==.骨汤二号:BAABLAAFFH8PAAINAAYIfxB0EABDAQANAAYIfxB0EABDAQAAAA==.骨汤五号:BAABLAAFFH8SAAINAAYIzwuBEQAyAQANAAYIzwuBEQAyAQAAAA==.骨汤八号:BAABLAAFFH8GAAINAAYInQvfEQAsAQANAAYInQvfEQAsAQAAAA==.骨汤六号:BAABLAAFFH8PAAINAAYIQA4sEQA3AQANAAYIQA4sEQA3AQAAAA==.骨汤四号:BAABLAAFFH8GAAINAAYIQgxDEQA2AQANAAYIQgxDEQA2AQAAAA==.',['鬼冢']='鬼冢黑骑一护:BAAALAAECggICAAAAA==.',['鬼迷']='鬼迷溜眼的丨:BAAALAAECgYIDAAAAA==.',['魔人']='魔人东东:BAACLAAFFH8GAAIKAAII+gkOJwB2AAAKAAII+gkOJwB2AAAsAAQKfxQAAgoACAgzFu8gAGcBAAoACAgzFu8gAGcBAAAA.魔人坏坏:BAAALAAECgYIBwAAAA==.',['魔兽']='魔兽小爱:BAABLAAECn8gAAMIAAgIbhrvKQAQAgAIAAgIbhrvKQAQAgAJAAQIpQXLngB5AAAAAA==.',['魔界']='魔界流氓会巭:BAAALAADCgIIAgAAAA==.',['魔罗']='魔罗:BAAALAAECgMIAwAAAA==.',['魔魂']='魔魂:BAAALAAFFAIIAgAAAA==.',['鲁尔']='鲁尔哈姆:BAAALAADCgcICgAAAA==.',['鸡蛋']='鸡蛋塞烧饼:BAAALAAECgQIBAAAAA==.',['麦克']='麦克爱慕二:BAAALAADCgEIAQAAAA==.',['麻辣']='麻辣老祖:BAAALAADCgYIBgAAAA==.',['黄少']='黄少天:BAAALAAECgYIDgAAAA==.',['黄油']='黄油小能:BAAALAADCgEIAQAAAA==.',['黑三']='黑三:BAAALAAECgEIAQAAAA==.',['黑暗']='黑暗飓风:BAAALAADCgUIBQAAAA==.',['黑黜']='黑黜哩滴:BAAALAAECgcIBwAAAA==.',['黛兮']='黛兮:BAABLAAFFH8FAAIFAAUIQxzCFQDmAQAFAAUIQxzCFQDmAQAAAA==.',['龙之']='龙之幽幽:BAAALAAECgUIBQAAAA==.',['龙女']='龙女之声:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end