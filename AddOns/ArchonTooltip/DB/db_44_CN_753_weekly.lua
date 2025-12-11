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
 local lookup = {'Druid-Restoration','DeathKnight-Unholy','Shaman-Elemental','Shaman-Restoration','Unknown-Unknown','Priest-Holy','Evoker-Devastation','Druid-Feral','Paladin-Protection','Mage-Frost','Mage-Arcane','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Mistweaver','Monk-Windwalker','Warrior-Protection','Priest-Shadow','DeathKnight-Frost','Warrior-Fury','DemonHunter-Havoc','Monk-Brewmaster','Druid-Guardian','Druid-Balance','Rogue-Assassination','Rogue-Subtlety','Paladin-Retribution','DemonHunter-Vengeance','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Paladin-Holy','Mage-Fire','Evoker-Preservation','Evoker-Augmentation',}; local provider = {region='CN',realm='爱斯特纳',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aimee:BAAALAAECgYICgAAAA==.',Av='Avna:BAAALAAECgUIBQAAAA==.',Bl='Blem:BAAALAADCgYIBwAAAA==.',Bo='Bobo:BAAALAAECgMIBAAAAA==.Boo:BAAALAAECgUIBQAAAA==.',By='Byun:BAAALAADCggICAAAAA==.',Ch='Charlotte:BAAALAAFFAYIBAAAAA==.',Co='Commiseratio:BAAALAAECgUICAAAAA==.',Cr='Crusinginst:BAAALAAECgIIAgAAAA==.',Do='Dopamine:BAAALAAECgYIDAAAAA==.',Dr='Dream:BAAALAAECgYIDwAAAA==.Drmloveysk:BAAALAADCgEIAQAAAA==.',En='Envystar:BAABLAAFFH8FAAIBAAMIEw7SKgCCAAABAAMIEw7SKgCCAAAAAA==.',Es='Est:BAAALAADCgYIBgAAAA==.',Fi='Firebat:BAAALAADCgEIAQAAAA==.',Ha='Hanzo:BAAALAAECgYIBgAAAA==.Hardcoree:BAAALAAECgYIDgAAAA==.',Hi='Hisense:BAABLAAFFH8JAAICAAII5Bh3DgCiAAACAAII5Bh3DgCiAAAAAA==.',Ho='Hockey:BAAALAAFFAIIBAAAAA==.',Lu='Luvian:BAAALAAECgMIAwAAAA==.',Mk='Mkml:BAAALAAECgQIBAAAAA==.',Mo='Moira:BAAALAAECgEIAQAAAA==.',Ns='Ns:BAABLAAFFH8FAAMDAAUIcQaAPQBQAAADAAMIDAKAPQBQAAAEAAIIyQLMbQBNAAAAAA==.',Oh='Ohlala:BAAALAAECgYICAABLAAECgcIDAAFAAAAAA==.',Sk='Skullheart:BAACLAAFFH8OAAICAAMIqCOoCADdAAACAAMIqCOoCADdAAAsAAQKfxkAAgIACAh1JRACAE4DAAIACAh1JRACAE4DAAAA.',Sm='Smartism:BAAALAAECgYIDgABLAAECgcIDAAFAAAAAA==.',So='Sombra:BAAALAAECgYIBgAAAA==.',Sp='Spy:BAAALAAECgYIBgAAAA==.',Va='Vanel:BAAALAADCggICAAAAA==.',Wi='Winston:BAAALAADCgUIBQAAAA==.',Yr='Yrel:BAAALAADCgQIBAAAAA==.',Za='Zafkiel:BAABLAAFFH8KAAIGAAII3RMpLQCSAAAGAAII3RMpLQCSAAAAAA==.',Zh='Zhangwuji:BAAALAAECgcICgAAAA==.',['一只']='一只柯基吖:BAAALAAECgYICQAAAA==.',['一毛']='一毛丶:BAAALAAECgcIDAAAAA==.',['一角']='一角:BAACLAAFFH8TAAIHAAUI5BOIDAApAQAHAAUI5BOIDAApAQAsAAQKfxoAAgcACAgfHhMaAE4CAAcACAgfHhMaAE4CAAAA.',['三花']='三花小卷:BAABLAAECn8XAAMBAAYIJRM9PgAiAQABAAYIJRM9PgAiAQAIAAIIuBQIHgB/AAAAAA==.',['上海']='上海人形:BAAALAAECgYIBgAAAA==.',['上班']='上班咯:BAACLAAFFH8KAAIJAAII8g2VGAB2AAAJAAII8g2VGAB2AAAsAAQKfxQAAgkABwjWHCwfAAACAAkABwjWHCwfAAACAAAA.',['不吃']='不吃橙子:BAAALAADCgQIBAAAAA==.',['不如']='不如狗:BAABLAAFFH8JAAIEAAMILhARRwB2AAAEAAMILhARRwB2AAABLAAFFAUIEwAHAOQTAA==.',['不懂']='不懂丶:BAAALAAECgYICAAAAA==.',['丝柯']='丝柯克:BAAALAAECgYIDgAAAA==.',['丨凛']='丨凛冬丨:BAACLAAFFH8IAAMKAAIItgubFwB7AAAKAAIItgubFwB7AAALAAIIzQPeZABrAAAsAAQKfx0AAgoACAgcGgEeACsCAAoACAgcGgEeACsCAAAA.',['丨崇']='丨崇尚暴力:BAAALAADCgUIBQAAAA==.',['丶能']='丶能量灌注:BAAALAADCggICAAAAA==.',['丶野']='丶野火炸彈:BAABLAAFFH8GAAIMAAYIrQ0hPgBMAQAMAAYIrQ0hPgBMAQAAAA==.',['丷烽']='丷烽火连城丷:BAABLAAECn8gAAMMAAgIzRa9eADsAQAMAAgIzRa9eADsAQANAAEIdgR+0AAdAAAAAA==.',['为你']='为你等万年:BAAALAAFFAMIAwAAAA==.',['丿致']='丿致命灬射击:BAAALAAECggICAAAAA==.',['乖乖']='乖乖术:BAAALAADCgQIBAAAAA==.乖乖龙:BAAALAADCgQIBAAAAA==.',['乞力']='乞力马扎罗雪:BAAALAAECgIIAgAAAA==.',['五枝']='五枝梅:BAAALAAFFAIIAgAAAA==.',['亣山']='亣山:BAAALAAECgIIAgAAAA==.',['今天']='今天不太忙:BAAALAAECgYIBgAAAA==.今天也很忙:BAAALAAECgUIBQAAAA==.',['仓储']='仓储负责人:BAAALAAFFAEIAQAAAA==.',['仔仔']='仔仔:BAAALAAFFAIIAgAAAA==.仔仔之豆:BAAALAAECggICwAAAA==.仔仔之骑:BAAALAAECgcIBwAAAA==.',['仙亦']='仙亦慕红尘:BAAALAAECgYIBgAAAA==.',['伊丷']='伊丷利丹:BAAALAAECgYIEwAAAA==.',['伊什']='伊什塔尔:BAAALAAFFAIIAgAAAA==.',['伊利']='伊利丶:BAAALAAECgEIAQAAAA==.',['伊历']='伊历丹:BAAALAADCgIIAgAAAA==.',['会飞']='会飞的小胖:BAACLAAFFH8LAAINAAYIthHaBQDLAQANAAYIthHaBQDLAQAsAAQKfyYAAg0ACAjsIvgRANMCAA0ACAjsIvgRANMCAAAA.会飞的许浩:BAAALAAECggIDAAAAA==.',['你是']='你是我的荣誉:BAAALAAECggICwAAAA==.',['你知']='你知道的太多:BAAALAADCgIIAgAAAA==.',['你艾']='你艾西我奶妈:BAAALAAECgEIAQAAAA==.',['例外']='例外:BAACLAAFFH8OAAIGAAQIcw5oKQDhAAAGAAQIcw5oKQDhAAAsAAQKfxQAAgYABghiH2k7AOwBAAYABghiH2k7AOwBAAEsAAUUBQgTAAcA5BMA.',['依然']='依然丶流星:BAAALAAFFAIIAgAAAA==.',['侠肠']='侠肠无医:BAACLAAFFH8uAAIOAAYImw+iCgBjAQAOAAYImw+iCgBjAQAsAAQKfyUAAw4ACAgGFqkaAOUBAA4ABwhAGKkaAOUBAA8AAQjRCKJtAC4AAAAA.',['俏无']='俏无双:BAAALAAFFAIIBAAAAA==.',['傻馒']='傻馒丶:BAAALAAECgIIAgAAAA==.',['关门']='关门灬放狗:BAAALAAECgYIBgAAAA==.',['冥之']='冥之爱过:BAAALAADCgYIBgABLAAECgcIDAAFAAAAAA==.',['冰山']='冰山上得羊:BAAALAADCgUIBgAAAA==.',['冰蝕']='冰蝕:BAAALAAECgIIAgAAAA==.',['冲锋']='冲锋:BAAALAAECgEIAQAAAA==.',['冷血']='冷血之鹰:BAAALAAECgUIDQAAAA==.冷血秋枫:BAAALAAECgYIBgAAAA==.',['凌风']='凌风旋律:BAABLAAFFH8MAAIQAAYIKRLZEQA4AQAQAAYIKRLZEQA4AQAAAA==.',['别拿']='别拿我图腾:BAAALAAECgIIAgAAAA==.',['到底']='到底有多难玩:BAAALAAECggICAAAAA==.',['千尺']='千尺血:BAAALAAECgIIAgAAAA==.',['千山']='千山鸟飞不绝:BAAALAAECgYIBwAAAA==.',['千年']='千年之光:BAAALAAFFAIIAgAAAA==.千年那天:BAABLAAFFH8GAAIRAAII4B5wGQClAAARAAII4B5wGQClAAAAAA==.',['半盏']='半盏流年:BAAALAAECgYIBgAAAA==.',['南宫']='南宫和风:BAAALAAECgEIAQAAAA==.',['占戈']='占戈示申:BAAALAADCgUICAAAAA==.',['古一']='古一:BAAALAADCgcIBwAAAA==.',['古因']='古因达鲁:BAABLAAECn8ZAAIEAAcIahyTHwD8AQAEAAcIahyTHwD8AQAAAA==.',['古而']='古而单:BAAALAAECgYICwAAAA==.',['只能']='只能喝三杯:BAAALAAECggIEAAAAA==.',['叫声']='叫声主人听:BAAALAAECggICgAAAA==.',['叫我']='叫我张三爷:BAAALAAECgIIAgAAAA==.',['司徒']='司徒圣光:BAAALAAECgMIAwAAAA==.',['听雨']='听雨:BAAALAAECgEIAQAAAA==.',['周防']='周防有希:BAAALAAECgYIBwAAAA==.',['哈库']='哈库纳玛塔:BAAALAADCgUIBQAAAA==.',['哈熊']='哈熊:BAAALAAECgcIEAAAAA==.',['唐伯']='唐伯虎点蚊香:BAAALAAECgYICQAAAA==.',['唾液']='唾液王:BAACLAAFFH8mAAMSAAYIhB/0HgC5AQASAAYIpB70HgC5AQACAAQIFyAIBwAbAQAsAAQKfx0AAxIACAhqIsYZAB0CABIACAgQIsYZAB0CAAIAAwh9IXsXALYAAAAA.',['喜欢']='喜欢乐子人:BAAALAAECgYIBgAAAA==.',['喵喵']='喵喵猫:BAAALAADCgMIAwAAAA==.',['四不']='四不四洒:BAAALAAECgYIBgAAAA==.',['困兔']='困兔兔:BAAALAAFFAIIAgABLAAFFAUIEwAHAOQTAA==.',['圣光']='圣光泯灭:BAAALAADCgYIDAAAAA==.',['地狱']='地狱叫唤:BAAALAAECggICAAAAA==.',['塔图']='塔图:BAAALAAECgYIBgAAAA==.',['墨一']='墨一抹丶暖年:BAAALAAECggIDwAAAA==.',['壹死']='壹死:BAABLAAFFH8PAAIMAAUIuhPxTgASAQAMAAUIuhPxTgASAQABLAAFFAUIEwAHAOQTAA==.',['复材']='复材小生:BAAALAAFFAIIBAAAAA==.',['夏其']='夏其拉:BAAALAAECgIIAgAAAA==.',['夏天']='夏天的肥皂泡:BAAALAADCgYIBgAAAA==.',['多喝']='多喝热水:BAABLAAFFH8IAAISAAIIdBiBaACUAAASAAIIdBiBaACUAAAAAA==.',['夜穆']='夜穆图腾:BAAALAADCgcIDgAAAA==.',['夜雨']='夜雨声煩:BAAALAAECggIAwAAAA==.',['大藶']='大藶出奇迹:BAAALAAECgEIAQAAAA==.',['大酋']='大酋长:BAAALAADCgIIAgAAAA==.',['天下']='天下无:BAAALAAECgMIAwABLAAECgcIDAAFAAAAAA==.',['天兵']='天兵神折:BAAALAAECgIIAgAAAA==.',['天山']='天山雪踪迷:BAAALAAECgEIAQAAAA==.',['失忆']='失忆的乖乖:BAAALAADCgcIBwAAAA==.',['失眠']='失眠吐司:BAAALAAECgIIAgAAAA==.',['失落']='失落的乖乖:BAAALAADCggIDgAAAA==.',['奶香']='奶香土豆泥:BAAALAAECgYIDAAAAA==.',['好起']='好起来了:BAAALAADCgIIAgAAAA==.',['妈妈']='妈妈不让说:BAAALAAECgYIDwAAAA==.',['妖月']='妖月:BAAALAAECgQIBwAAAA==.',['姬儿']='姬儿加蛋:BAAALAAECgYIBwAAAA==.',['姬刕']='姬刕骧:BAAALAAECggICAAAAA==.',['娜尼']='娜尼雅:BAAALAADCgYIBgAAAA==.',['学徒']='学徒肖恩:BAAALAAECgYIEQAAAA==.',['宇文']='宇文无过:BAAALAAFFAIIAgAAAA==.',['守妮']='守妮:BAAALAADCgEIAQAAAA==.',['安和']='安和昴:BAABLAAFFH8MAAINAAYIhA9yCAA5AQANAAYIhA9yCAA5AQAAAA==.',['安思']='安思塔利亚:BAAALAADCgcIBwAAAA==.',['安格']='安格隆:BAABLAAFFH8GAAITAAQIbgMkIADHAAATAAQIbgMkIADHAAAAAA==.',['小半']='小半:BAAALAAECgYIBgAAAA==.',['小小']='小小豌豆:BAABLAAECn8VAAIUAAgIAhfEJgDBAQAUAAgIAhfEJgDBAQAAAA==.',['小开']='小开开二号:BAABLAAFFH8HAAIVAAYIAA5xEQAzAQAVAAYIAA5xEQAzAQAAAA==.小开开四号:BAABLAAFFH8GAAIWAAIICQW7EQAfAAAWAAIICQW7EQAfAAAAAA==.',['小德']='小德儿:BAAALAADCggICAAAAA==.小德怎么又:BAAALAAECgUIBgAAAA==.',['小熊']='小熊软糖:BAABLAAFFH8sAAMBAAcI1RqpCQATAgABAAcI1RqpCQATAgAXAAIIuAiSJwB3AAAAAA==.',['小男']='小男恶魔:BAAALAAECgYIAQAAAA==.小男术:BAAALAAECgIIAgABLAAECgYIBgAFAAAAAA==.小男贼:BAAALAAECgYIBgAAAA==.',['小米']='小米饭:BAACLAAFFH8IAAIYAAIIRRlHFwChAAAYAAIIRRlHFwChAAAsAAQKfxwAAhgABgivG3YqAM8BABgABgivG3YqAM8BAAAA.',['小萨']='小萨儿:BAAALAAECgMIAwAAAA==.',['小飒']='小飒无敌:BAAALAADCgcIBwAAAA==.',['小马']='小马萨:BAAALAAFFAIIAgAAAA==.',['就是']='就是拽狂:BAAALAAECgYICgAAAA==.',['差不']='差不咄德勒:BAAALAAECgUIBQAAAA==.',['布丁']='布丁:BAAALAAECgYIBgAAAA==.',['布料']='布料店:BAAALAAECgMIAwAAAA==.',['希瓦']='希瓦丶:BAABLAAECn8cAAIMAAYIHBpllQC8AQAMAAYIHBpllQC8AQAAAA==.',['干了']='干了这杯黄泉:BAAALAAECggIBgAAAA==.',['并非']='并非永恒:BAAALAAECgYIBgAAAA==.',['幽兰']='幽兰戴尔:BAAALAAFFAIIBAAAAA==.',['广寒']='广寒宫:BAAALAAECggICgAAAA==.',['库拉']='库拉:BAABLAAFFH8XAAMZAAYIzyH+BQCNAQAZAAUIpx/+BQCNAQAYAAMIoCBnDgAkAQAAAA==.',['开开']='开开一号:BAABLAAFFH8IAAIQAAYILh38CwCCAQAQAAYILh38CwCCAQAAAA==.',['弹指']='弹指红颜:BAAALAAECgYICQAAAA==.',['强哥']='强哥的女人:BAAALAAECgQIBQAAAA==.',['彩云']='彩云的回忆:BAAALAAECgYIDgAAAA==.',['彩熠']='彩熠:BAAALAADCgYIBgAAAA==.',['彩翼']='彩翼:BAAALAAFFAIIAgAAAA==.',['御风']='御风菁云:BAAALAADCgMIAwAAAA==.',['微笑']='微笑的蒂蕾莎:BAAALAADCgQIBAAAAA==.',['忆梦']='忆梦:BAAALAAECggIEAAAAA==.',['忧伤']='忧伤的乖乖:BAAALAADCgIIAgAAAA==.',['忧郁']='忧郁的乖乖:BAAALAADCggICwAAAA==.',['快乐']='快乐随心:BAABLAAFFH8GAAIBAAIIFAQEVABMAAABAAIIFAQEVABMAAAAAA==.',['怀批']='怀批:BAACLAAFFH8sAAIaAAYIBCLYDADdAQAaAAYIBCLYDADdAQAsAAQKfy8AAhoABwjxItMtALoCABoABwjxItMtALoCAAAA.',['总有']='总有:BAAALAAFFAIIBAABLAAFFAUIEwAHAOQTAA==.',['恐惧']='恐惧之裤:BAAALAAECgYIDgAAAA==.',['恰梦']='恰梦想:BAABLAAFFH8GAAIMAAYI0Bj9NwBfAQAMAAYI0Bj9NwBfAQAAAA==.',['悠悠']='悠悠曲奇:BAAALAADCggICAAAAA==.',['悠然']='悠然骑士:BAAALAAECgUIBQAAAA==.',['愤怒']='愤怒的胖红:BAAALAADCgMIAwAAAA==.',['我只']='我只吃素:BAAALAADCgYIBgAAAA==.',['抠动']='抠动扳机:BAAALAAECgIIAgAAAA==.',['拉世']='拉世传奇:BAABLAAFFH8JAAIMAAMINwgadwBwAAAMAAMINwgadwBwAAAAAA==.',['拙劣']='拙劣的马奎:BAAALAAFFAIIAgAAAA==.',['拾灬']='拾灬叁:BAAALAAECgYICAAAAA==.',['持枪']='持枪威胁:BAAALAAECgYIBgAAAA==.',['撕袜']='撕袜骑士:BAABLAAFFH8GAAISAAYIjR+0JgCbAQASAAYIjR+0JgCbAQAAAA==.',['收割']='收割一手:BAAALAAECgMIAwAAAA==.',['敗家']='敗家丶劈叉:BAAALAADCgEIAQAAAA==.',['无力']='无力的小弹弓:BAAALAAECgMIAgAAAA==.',['无口']='无口森田:BAAALAAECgYIBgAAAA==.',['无敌']='无敌的仔仔:BAAALAAFFAIIAgAAAA==.',['无独']='无独三:BAAALAADCgYICgAAAA==.',['无琰']='无琰无形:BAAALAADCgEIAQAAAA==.',['无聊']='无聊的羊:BAAALAAECgUIBQAAAA==.',['星罗']='星罗:BAABLAAECn8cAAIaAAYI7yF+LwDVAQAaAAYI7yF+LwDVAQAAAA==.',['晤夏']='晤夏:BAAALAADCgQIAgAAAA==.',['景甜']='景甜:BAAALAADCgEIAQAAAA==.',['暗影']='暗影丨随行:BAABLAAFFH8MAAMUAAQIbQjjQQCGAAAUAAIIJQbjQQCGAAAbAAIItgr6FgAoAAAAAA==.',['暗燃']='暗燃小红:BAAALAAECgYICAABLAAECgcIDAAFAAAAAA==.',['暮雨']='暮雨醉秋梦:BAAALAAECgYICgAAAA==.',['暴走']='暴走的公牛:BAAALAAECgcIBwAAAA==.',['暴风']='暴风游侠:BAAALAADCggIDgAAAA==.',['月兔']='月兔兔:BAABLAAFFH8NAAITAAMIvxTsNgCXAAATAAMIvxTsNgCXAAABLAAFFAUIEwAHAOQTAA==.',['朋也']='朋也:BAAALAADCgMIBQAAAA==.',['术业']='术业有成:BAAALAADCgIIAgAAAA==.',['李七']='李七夜:BAAALAAECgEIAQAAAA==.',['树莓']='树莓奶冻:BAAALAAECgMIAwAAAA==.',['桂妮']='桂妮薇尔:BAACLAAFFH8HAAIcAAQI/BkeGwBmAQAcAAQI/BkeGwBmAQAsAAQKfyMABB0ACAgQJO4FAA0DABwACAi7Iu8RABoDAB0ACAh/IO4FAA0DAB4AAwgIBZcoAKQAAAAA.',['橙色']='橙色长鼻象:BAAALAADCggIDgAAAA==.',['欧皇']='欧皇大冰刺:BAABLAAECn8gAAIKAAgI9hWEIQARAgAKAAgI9hWEIQARAgAAAA==.',['死猫']='死猫子:BAAALAADCgQIBAAAAA==.',['死骑']='死骑不骑马:BAAALAADCgMIAwAAAA==.',['毛利']='毛利丶兰:BAACLAAFFH8UAAMMAAQInxGIMgC/AAAMAAQInxGIMgC/AAANAAEIQwVsOQAxAAAsAAQKfyIAAgwACAgxHq0pALECAAwACAgxHq0pALECAAAA.',['永恒']='永恒的三哥:BAABLAAFFH8GAAIaAAIIURsISgCXAAAaAAIIURsISgCXAAAAAA==.',['沈阳']='沈阳制造:BAAALAADCgYIDAAAAA==.',['法神']='法神:BAAALAAECgYIBgAAAA==.',['泗水']='泗水流:BAAALAADCgIIAgAAAA==.',['洛塔']='洛塔拉萨琳:BAABLAAFFH8IAAIMAAYIzAcUVwDwAAAMAAYIzAcUVwDwAAAAAA==.',['洛神']='洛神:BAAALAADCgEIAQAAAA==.',['流光']='流光疫法:BAAALAAECgYIBwAAAA==.',['流觞']='流觞曲水:BAAALAADCgYIBgAAAA==.',['浪丶']='浪丶婓儿:BAAALAAECgYICgAAAA==.',['深色']='深色幽兰:BAAALAAECgYIBgAAAA==.',['清醒']='清醒:BAABLAAFFH8NAAIaAAMINR0fIwDGAAAaAAMINR0fIwDGAAAAAA==.',['清风']='清风十井:BAAALAAECgQICAAAAA==.',['渐入']='渐入佳境:BAAALAADCgEIAQAAAA==.',['游侠']='游侠小黑:BAABLAAFFH8KAAMMAAMInwUMfwBZAAAMAAMInwUMfwBZAAANAAII1QJvHAAnAAAAAA==.',['火法']='火法:BAAALAAECggIEwAAAA==.',['火血']='火血化雨:BAAALAAECgYICAAAAA==.',['灬哈']='灬哈哈灬:BAAALAADCgQIBgAAAA==.',['灬涅']='灬涅槃灬:BAABLAAFFH8GAAIfAAMInh43GgDlAAAfAAMInh43GgDlAAAAAA==.',['灬醉']='灬醉梦:BAAALAAECgYIDQAAAA==.',['点点']='点点阳光:BAAALAADCgQIBAAAAA==.',['焦糖']='焦糖薯片:BAAALAAECgYICQAAAA==.',['然然']='然然:BAAALAAFFAYIBAAAAA==.',['熊猫']='熊猫骑士:BAAALAAECgYIBgAAAA==.',['燃烧']='燃烧的青春:BAAALAAECgQIBAAAAA==.',['爆米']='爆米花:BAAALAAECgMIAwAAAA==.',['爆雨']='爆雨梨花:BAABLAAFFH8IAAIMAAIICB/5SgCZAAAMAAIICB/5SgCZAAABLAAFFAgIHAAXAOIkAA==.',['爱与']='爱与事业:BAAALAAECgIIAgAAAA==.',['爱丝']='爱丝特娜:BAABLAAFFH8GAAMLAAYINxdWFQC5AQALAAUIXxZWFQC5AQAgAAEIbhtQCQBYAAAAAA==.',['牛人']='牛人熊猫:BAAALAADCgYIBgAAAA==.',['狂丶']='狂丶战:BAAALAADCgMIBAAAAA==.',['狂杀']='狂杀斩:BAAALAADCgUIBQAAAA==.',['独自']='独自伤悲:BAAALAADCgMIBAAAAA==.',['猎丶']='猎丶魇:BAAALAAECgEIAQAAAA==.',['猫在']='猫在家:BAAALAAECgQIBwAAAA==.',['玄武']='玄武禅师:BAAALAAECgQIBAAAAA==.',['王嫱']='王嫱:BAAALAADCgYIBgAAAA==.',['王小']='王小布丁:BAACLAAFFH8JAAIcAAMIhQVRWABIAAAcAAMIhQVRWABIAAAsAAQKfxsAAhwACAjnCCWUAFUBABwACAjnCCWUAFUBAAAA.',['玛德']='玛德法克:BAAALAADCgEIAQAAAA==.',['玛格']='玛格汉兽小猎:BAAALAAECgYIEQAAAA==.',['珊瑚']='珊瑚宫心海:BAAALAAECgIIAgAAAA==.',['男神']='男神:BAAALAAECgcICQAAAA==.',['疫无']='疫无反孤:BAAALAADCgcIBwAAAA==.',['痴灬']='痴灬鬼:BAAALAAECgUIBQAAAA==.',['白哔']='白哔哔:BAAALAAFFAIIAgAAAA==.',['白玉']='白玉:BAAALAADCgIIAgAAAA==.',['看那']='看那东风:BAAALAAECgMIAwAAAA==.',['破灭']='破灭之司:BAAALAADCgQIBAAAAA==.',['示申']='示申:BAAALAADCgIIAgAAAA==.',['神圣']='神圣的小胖:BAABLAAECn8pAAIaAAgIZiEcKADRAgAaAAgIZiEcKADRAgAAAA==.',['神尾']='神尾观铃:BAAALAAECggICgAAAA==.',['秋岚']='秋岚:BAAALAAFFAEIAQAAAA==.',['空舞']='空舞:BAAALAAFFAIIAgAAAA==.',['笨笨']='笨笨罗刹熊:BAAALAADCgUIBAAAAA==.',['缘起']='缘起缘灭:BAABLAAFFH8eAAISAAYIzxgXIwCoAQASAAYIzxgXIwCoAQAAAA==.',['美味']='美味蟹黄堡:BAABLAAECn8VAAMJAAgILA0hMwCAAQAJAAgILA0hMwCAAQAfAAgI6QpSPABvAQAAAA==.',['美少']='美少女:BAAALAADCgYIBgAAAA==.',['美麗']='美麗身影:BAAALAAECgYIBgAAAA==.',['脸萌']='脸萌圣骑丝:BAAALAAECgYIBgAAAA==.',['致死']='致死不渝:BAAALAAECgEIAQAAAA==.',['艾利']='艾利婕丶血歌:BAAALAADCggIDgAAAA==.',['艾蕾']='艾蕾什基嘉勒:BAABLAAFFH8SAAMRAAYIRB5gCQC+AQARAAYIRB5gCQC+AQAGAAQInSCtIABCAQAAAA==.',['芜了']='芜了个小敌敌:BAABLAAFFH8IAAIbAAMIHAafDACPAAAbAAMIHAafDACPAAAAAA==.',['花与']='花与夕阳共舞:BAAALAAECgYIBwAAAA==.',['花活']='花活:BAABLAAFFH8GAAIcAAYIWQJHUgBtAAAcAAYIWQJHUgBtAAAAAA==.',['苍龍']='苍龍七宿:BAACLAAFFH8FAAIhAAII3h3TDwCwAAAhAAII3h3TDwCwAAAsAAQKfxgAAyIABwjfHQQIAAgCACIABghPHgQIAAgCACEABwgRGK8VAOEBAAAA.',['苏菲']='苏菲玛索:BAAALAADCgIIAgAAAA==.',['若离']='若离:BAAALAAECgMIAwAAAA==.',['荒野']='荒野星魂:BAAALAADCgcIBwAAAA==.',['荔枝']='荔枝果酱:BAAALAAECgEIAQAAAA==.',['莜苒']='莜苒:BAAALAAFFAIIBAAAAA==.',['莯浴']='莯浴阳光:BAABLAAFFH8KAAIYAAgIngsOBAAAAgAYAAgIngsOBAAAAgAAAA==.',['莱因']='莱因哈特:BAAALAAECgEIAQAAAA==.',['落無']='落無風:BAAALAAECgcIDAAAAA==.',['蕊仔']='蕊仔一号:BAAALAAECgQIBAAAAA==.蕊仔零号:BAAALAAFFAIIAgAAAA==.',['藏不']='藏不住的老鼠:BAACLAAFFH8XAAIUAAMIlgwJQQCKAAAUAAMIlgwJQQCKAAAsAAQKfyIAAhQABghKFkudAJABABQABghKFkudAJABAAAA.',['蟹堡']='蟹堡王小海绵:BAACLAAFFH8TAAIMAAMIxhfPSACbAAAMAAMIxhfPSACbAAAsAAQKfzcAAgwACAhTIp4lAMICAAwACAhTIp4lAMICAAAA.蟹堡王派总:BAAALAADCgMIAwAAAA==.',['血羅']='血羅蓝:BAAALAAFFAIIAgAAAA==.',['血莉']='血莉莲:BAAALAAECgUIBQAAAA==.',['血莹']='血莹:BAAALAAFFAIIBAAAAA==.',['补药']='补药打窝:BAAALAAECgEIAQAAAA==.',['袁罡']='袁罡:BAAALAADCgEIAQAAAA==.',['西凉']='西凉河葛三叔:BAAALAADCgIIAgAAAA==.',['西凡']='西凡纳斯:BAAALAADCgYIBgAAAA==.',['西瓜']='西瓜籽儿:BAAALAAFFAIIBAAAAA==.',['话梅']='话梅:BAAALAAECgMIAwAAAA==.',['诱人']='诱人小恶魔:BAAALAAECgYICAAAAA==.',['请叫']='请叫我术爷:BAAALAAECgEIAQAAAA==.',['诸神']='诸神之怒:BAAALAADCgMIAwAAAA==.',['谷雨']='谷雨:BAAALAAECggICAAAAA==.',['跑题']='跑题大王:BAAALAAECgYIDwAAAA==.',['踏雪']='踏雪無痕:BAAALAAECgEIAQAAAA==.',['身材']='身材魔鬼:BAAALAADCgUICQAAAA==.',['达娜']='达娜夜风:BAAALAADCgIIAgAAAA==.',['迷离']='迷离兔:BAAALAAFFAIIAgAAAA==.',['逗包']='逗包:BAAALAADCgEIAQAAAA==.',['逻神']='逻神:BAAALAADCgQIBAAAAA==.',['那个']='那个奶德:BAAALAADCggICAAAAA==.',['那些']='那些多事之秋:BAAALAADCgYIBgAAAA==.',['邪恶']='邪恶白毛熊:BAABLAAFFH8HAAMEAAcIMxH/CwB/AQAEAAUIJRT/CwB/AQADAAIIzwUxKwCRAAAAAA==.',['部落']='部落肉贩子:BAABLAAFFH8TAAIaAAYIeyD1EQC4AQAaAAYIeyD1EQC4AQAAAA==.',['重返']='重返十三岁:BAAALAADCgMIAwAAAA==.',['野蛮']='野蛮冲锋:BAAALAADCgYICAAAAA==.野蛮牛牛:BAAALAADCgYIBgAAAA==.',['银眼']='银眼泰蓝德:BAAALAADCggICAAAAA==.',['長崎']='長崎素世:BAABLAAFFH8LAAMdAAIIXCZ6BQDkAAAdAAIIXCZ6BQDkAAAcAAEICSBhWgBFAAAAAA==.',['门前']='门前大桥下:BAAALAAFFAIIAgAAAA==.',['闪闪']='闪闪:BAAALAAECgcIDwAAAA==.',['阿薇']='阿薇十八式:BAAALAAFFAIIAgAAAA==.',['随便']='随便丶:BAACLAAFFH8KAAIBAAMIBxPCMACnAAABAAMIBxPCMACnAAAsAAQKfxYABAEABghIFJRtAE0BAAEABghIFJRtAE0BAAgABQh8EQMWAN0AABcAAQhOBWdoACEAAAAA.',['雨宫']='雨宫莲:BAAALAAFFAIIBAAAAA==.',['霸魃']='霸魃紅:BAABLAAFFH8FAAISAAUIqBBqRQAlAQASAAUIqBBqRQAlAQAAAA==.',['霹雳']='霹雳丘秋:BAEALAAECgQIBAAAAA==.',['靓牛']='靓牛:BAAALAAECgMIAwAAAA==.',['静静']='静静的兢鱼儿:BAABLAAECn8dAAIaAAcIQRJAUgBpAQAaAAcIQRJAUgBpAQAAAA==.',['风中']='风中的叹息:BAAALAAECgMIAwAAAA==.风中苍月:BAAALAADCgQIBAAAAA==.',['风之']='风之冰霜:BAAALAAFFAQIBAAAAA==.风之语灬星眸:BAAALAAFFAIIAgAAAA==.',['风流']='风流丶:BAABLAAECn8eAAIKAAYIDh7SEgCdAQAKAAYIDh7SEgCdAQAAAA==.',['风灵']='风灵月影:BAAALAAECgUIBQAAAA==.',['风走']='风走云流:BAAALAADCgYIBgAAAA==.',['风铃']='风铃语:BAABLAAFFH8wAAIGAAcIgx8JBACZAgAGAAcIgx8JBACZAgAAAA==.',['风骚']='风骚小双双:BAAALAAFFAMIAwAAAA==.',['飞天']='飞天一击:BAAALAAECgYICQAAAA==.',['飞虎']='飞虎队:BAAALAAECggIEgAAAA==.',['香烟']='香烟吥离手:BAAALAADCggICwAAAA==.',['高富']='高富帅历险记:BAAALAADCgMIAwAAAA==.',['魅瞳']='魅瞳:BAABLAAFFH8JAAISAAgIXxnGBwB9AgASAAgIXxnGBwB9AgAAAA==.',['魔法']='魔法的法:BAAALAADCgQIBQAAAA==.',['魔界']='魔界玄武:BAAALAAECgEIAQAAAA==.',['黄昏']='黄昏倚小楼:BAAALAAFFAIIAwAAAA==.黄昏傍树影:BAAALAAFFAIIAgAAAA==.',['黑色']='黑色的长鼻象:BAAALAADCgIIAgAAAA==.',['黑风']='黑风岭的猎户:BAAALAADCgIIAgAAAA==.',['齊天']='齊天乖乖:BAAALAAECgYIBgAAAA==.',['龙城']='龙城飞将:BAAALAADCgEIAQAAAA==.',['龙龙']='龙龙哦:BAAALAAECgcICQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end