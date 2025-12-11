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
 local lookup = {'Shaman-Elemental','Paladin-Retribution','Warrior-Fury','Druid-Balance','Druid-Restoration','Druid-Feral','DeathKnight-Frost','Shaman-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Protection','Warlock-Destruction','DemonHunter-Havoc','DeathKnight-Blood','Druid-Guardian','Mage-Frost','Paladin-Holy',}; local provider = {region='CN',realm='黑手军团',name='CN',type='weekly',zone=44,date='2025-12-10',data={An='Angeleyes:BAAALAADCgcICAAAAA==.',Av='Avenger:BAAALAAECgYICQAAAA==.',Ba='Bangbanging:BAAALAADCggICgAAAA==.',Br='Brave:BAAALAAFFAIIBAAAAA==.',Ca='Calmer:BAABLAAFFH8LAAIBAAUIDgsjKQACAQABAAUIDgsjKQACAQAAAA==.',Cl='Closer:BAAALAADCggIEAAAAA==.',Da='Damnations:BAAALAAFFAIIBAAAAA==.',De='Defendeor:BAAALAAFFAIIBAAAAA==.',Fe='Fearless:BAAALAAFFAMIBAAAAA==.',Fo='Founderr:BAAALAAECgYIBgAAAA==.',Ji='Jinxx:BAAALAAECgMIAwAAAA==.',La='Lalaluok:BAAALAAECgYIBgAAAA==.',Ma='Makamakakaka:BAAALAAECgIIAgAAAA==.',Ra='Rational:BAAALAAECgIIAgAAAA==.',So='Soar:BAAALAAECgYIDQAAAA==.',Tr='Trapple:BAAALAAFFAIIBAAAAA==.',['Às']='Àskull:BAAALAAECgYIBgAAAA==.',['一怒']='一怒为红颜:BAAALAADCggICAAAAA==.',['七羽']='七羽:BAAALAAECgEIAQAAAA==.',['上官']='上官玉儿:BAAALAAECgIIAgAAAA==.',['上山']='上山打老虎:BAAALAAFFAIIBAAAAA==.',['不会']='不会开无敌:BAAALAAECgIIAgAAAA==.',['丶旱']='丶旱龙:BAABLAAFFH8JAAICAAUI4BQuKwAvAQACAAUI4BQuKwAvAQAAAA==.',['丶玄']='丶玄泽:BAAALAAFFAIIAgAAAA==.',['乌瑟']='乌瑟尔之魂:BAABLAAECn8UAAICAAYIvgxqgAACAQACAAYIvgxqgAACAQAAAA==.',['云笈']='云笈:BAABLAAFFH8FAAIDAAII7xANXAA8AAADAAII7xANXAA8AAAAAA==.',['五十']='五十斤的猫:BAAALAADCgIIAgAAAA==.',['他还']='他还是个孩子:BAAALAAECgYIBgAAAA==.',['低调']='低调的狂热:BAACLAAFFH80AAMEAAYI3iDGCADdAQAEAAYI3iDGCADdAQAFAAEIOQgGXQA3AAAsAAQKfzoAAwQACAhqJCAFAL8CAAQACAhqJCAFAL8CAAYAAgjfENsnAC8AAAAA.',['你瞅']='你瞅我干啥:BAABLAAFFH8HAAIHAAIIYQNpoQA2AAAHAAIIYQNpoQA2AAAAAA==.',['侠盗']='侠盗猎手:BAAALAAECgYIEAAAAA==.',['元气']='元气骑迈克斯:BAAALAAFFAQIAgAAAA==.',['元素']='元素精灵:BAAALAAECgYIDAAAAA==.',['光明']='光明之手:BAAALAAECgEIAQAAAA==.',['八宝']='八宝丶:BAAALAAFFAQIAgAAAA==.',['公海']='公海医疗船:BAAALAAECggICQABLAAFFAgICgAIAO4aAA==.',['凌风']='凌风小骑:BAAALAAECgYIAwAAAA==.',['别打']='别打了我招:BAAALAADCgYIDAAAAA==.',['勇敢']='勇敢贝拉:BAAALAAECgMIAwAAAA==.',['北國']='北國暁雨:BAAALAAFFAIIAgAAAA==.',['十年']='十年人参:BAABLAAFFH8JAAMJAAMIGBPbLgDJAAAJAAMIGBPbLgDJAAAKAAIIGg5lJwB5AAAAAA==.',['半岛']='半岛铁头:BAABLAAFFH8NAAILAAIIHgQMNwArAAALAAIIHgQMNwArAAAAAA==.',['双马']='双马尾暴徒:BAABLAAFFH8FAAIIAAIIlgVQdQBFAAAIAAIIlgVQdQBFAAAAAA==.',['右手']='右手丨烈焰:BAAALAAECgcIBgAAAA==.',['君无']='君无愁:BAAALAADCgYIBgAAAA==.',['咕咕']='咕咕哒:BAAALAAECgYICgAAAA==.',['咩妹']='咩妹控丶:BAAALAADCgYIBgAAAA==.',['唧唧']='唧唧不倦:BAABLAAFFH8UAAIHAAYIzg7oPABOAQAHAAYIzg7oPABOAQAAAA==.',['啊稻']='啊稻:BAAALAAFFAIIAgAAAA==.',['喇灬']='喇灬叭:BAAALAAECgEIAQAAAA==.',['回归']='回归到无:BAAALAADCgYIBgAAAA==.',['大咪']='大咪米:BAAALAADCgMIAwAAAA==.',['大火']='大火球:BAAALAAECgYICQAAAA==.',['大熊']='大熊哥哥:BAAALAADCgIIAgAAAA==.',['大肉']='大肉肉:BAAALAADCgIIAgAAAA==.',['奶德']='奶德五福:BAAALAAECgYIBwAAAA==.',['妖战']='妖战雯雯:BAAALAAECgYIBwAAAA==.',['娇艳']='娇艳的水仙:BAAALAAECgEIAQAAAA==.',['嫒孋']='嫒孋惏悦:BAABLAAFFH8tAAIHAAYIdBV5LQCJAQAHAAYIdBV5LQCJAQAAAA==.',['审判']='审判者丶:BAAALAAECgYICwAAAA==.',['小呲']='小呲花:BAABLAAFFH8PAAIMAAUI0AtdPwAFAQAMAAUI0AtdPwAFAQAAAA==.',['小滴']='小滴人儿:BAAALAAECggIDgAAAA==.',['小澍']='小澍提不起劲:BAAALAAECgYIBgAAAA==.',['小百']='小百:BAABLAAFFH8GAAINAAIIowuKSwCQAAANAAIIowuKSwCQAAAAAA==.',['小红']='小红手娇花:BAABLAAFFH8IAAIIAAIIHxUUUwB3AAAIAAIIHxUUUwB3AAAAAA==.',['小铁']='小铁槌:BAAALAAECgQIBAAAAA==.',['尐佐']='尐佐:BAAALAAECggIEAAAAA==.',['尼休']='尼休:BAAALAAECgIIAgAAAA==.',['尼格']='尼格猎手:BAAALAAECgcIBwAAAA==.',['屠尽']='屠尽日寇:BAABLAAFFH8IAAIOAAgIZgGfEADyAAAOAAgIZgGfEADyAAAAAA==.',['师傅']='师傅被抓走了:BAAALAAFFAIIAgABLAAFFAUIDQACAMoZAA==.',['希尔']='希尔瓦:BAAALAAECgQIBAAAAA==.',['怒斩']='怒斩残阳:BAAALAAECgIIBAAAAA==.',['恶魔']='恶魔古丹:BAAALAAECgQIBAAAAA==.',['惊奇']='惊奇队长:BAABLAAFFH8XAAIPAAUIlQslBgC0AAAPAAUIlQslBgC0AAAAAA==.',['愤怒']='愤怒的大馿:BAAALAAECgUIBQAAAA==.',['懐惗']='懐惗:BAAALAAECgEIAQAAAA==.懐惗过去:BAAALAAECgYIBgAAAA==.',['护夜']='护夜之瞳:BAAALAAECgcIBwAAAA==.',['抱她']='抱她:BAAALAAECgEIAQAAAA==.',['摩摩']='摩摩尔蛮鬃:BAABLAAFFH8GAAILAAYIrQ16BgClAQALAAYIrQ16BgClAQAAAA==.',['放一']='放一放:BAAALAAECgUIBwAAAA==.',['放开']='放开那小妮:BAAALAAFFAIIBAAAAA==.',['无尽']='无尽之海王:BAABLAAFFH8IAAIQAAgIeQNhFABHAAAQAAgIeQNhFABHAAAAAA==.',['曲头']='曲头头:BAAALAAFFAIIAgABLAAFFAgIDAAHAOUeAA==.',['替罪']='替罪的羊:BAACLAAFFH8GAAIHAAIIYRe5WgCbAAAHAAIIYRe5WgCbAAAsAAQKfxkAAgcACAjLHfcwAK8CAAcACAjLHfcwAK8CAAAA.',['月蚀']='月蚀:BAABLAAFFH8KAAIJAAIITRB4bwCAAAAJAAIITRB4bwCAAAAAAA==.',['服装']='服装厂黑保安:BAABLAAFFH8IAAIIAAIIqgTVcwBHAAAIAAIIqgTVcwBHAAAAAA==.',['李丶']='李丶弃儿:BAAALAAECgQIBAAAAA==.',['果丹']='果丹皮的花海:BAAALAADCggICAAAAA==.',['树莓']='树莓饼干:BAAALAAECgcIBwAAAA==.',['梦靥']='梦靥:BAAALAAECgYIDQAAAA==.',['正义']='正义之锤:BAAALAAECgYIBgAAAA==.',['死神']='死神丶来了:BAAALAADCggIDQAAAA==.',['死骑']='死骑给我打杂:BAAALAAFFAIIAgAAAA==.',['沐微']='沐微月:BAABLAAFFH8lAAIIAAYI9hrEEgDTAQAIAAYI9hrEEgDTAQAAAA==.',['波涛']='波涛汹涌:BAAALAAECgYIDgAAAA==.',['海岸']='海岸线:BAAALAAFFAEIAQAAAA==.',['湮灭']='湮灭八荒:BAACLAAFFH8tAAIOAAYI/QLkEQDOAAAOAAYI/QLkEQDOAAAsAAQKfyMAAg4ACAglDV8oADsBAA4ACAglDV8oADsBAAAA.',['滴滴']='滴滴六:BAAALAAECgYIDAAAAA==.',['熊熊']='熊熊燃起:BAACLAAFFH8VAAMHAAUILwruHgAqAQAHAAUIAwnuHgAqAQAOAAEIYgcvGAA+AAAsAAQKfy4AAgcACAgxHvw3AJgCAAcACAgxHvw3AJgCAAAA.',['爱情']='爱情绵绵海:BAAALAAECgYIBgAAAA==.',['牧野']='牧野:BAABLAAFFH8SAAICAAIIpQ8OUACSAAACAAIIpQ8OUACSAAAAAA==.',['狂风']='狂风:BAAALAAECgYIBwAAAA==.',['玉米']='玉米不带宝宝:BAAALAAECgYIBgAAAA==.',['白淺']='白淺:BAAALAAFFAIIBAAAAA==.',['皆为']='皆为云烟:BAAALAAECgYICAAAAA==.',['神奇']='神奇的阿修罗:BAAALAAECgcIDQAAAA==.',['秋风']='秋风夜雨:BAAALAAECgQIBAAAAA==.',['穿心']='穿心莲:BAAALAAECgMIAwAAAA==.',['窵傂']='窵傂:BAAALAAECgIIBAAAAA==.',['糖霜']='糖霜酥饼丶:BAAALAAFFAQIBAAAAA==.',['紫色']='紫色郁金香:BAAALAAECgYIBgAAAA==.',['红烧']='红烧剁椒鱼头:BAAALAAFFAIIBAAAAA==.',['老白']='老白干二号:BAABLAAECn8ZAAMJAAYIPwlm3gDFAAAJAAYIPwlm3gDFAAAKAAIIPgVQugA7AAAAAA==.',['艺灬']='艺灬夫:BAABLAAFFH8GAAIIAAIIQxnJNgCTAAAIAAIIQxnJNgCTAAAAAA==.',['艾维']='艾维娜:BAAALAAECgMIBAAAAA==.',['艾莉']='艾莉丝丶怒风:BAAALAADCggICAAAAA==.',['荣耀']='荣耀法爷:BAAALAAECgEIAQAAAA==.',['萨个']='萨个满:BAABLAAFFH8sAAIBAAYIXSKcDADrAQABAAYIXSKcDADrAQAAAA==.',['西维']='西维克特:BAACLAAFFH8NAAICAAUIyhn/JQBMAQACAAUIyhn/JQBMAQAsAAQKfxUAAgIABwgQH2NQAE8CAAIABwgQH2NQAE8CAAAA.',['许大']='许大豆儿:BAAALAAECggIDwAAAA==.',['谁家']='谁家呐小谁:BAABLAAECn8pAAIQAAgI6hy8CAA7AgAQAAgI6hy8CAA7AgAAAA==.',['赫天']='赫天晨:BAACLAAFFH8sAAIPAAYIdhRZAwA6AQAPAAYIdhRZAwA6AQAsAAQKfxUAAw8ACAglFpATAKcBAA8ACAglFpATAKcBAAUAAgiHBRPfAEIAAAAA.',['超大']='超大冰美式:BAAALAAECgUIBQAAAA==.',['逍遥']='逍遥亡命徒:BAABLAAECn8VAAIIAAYI1R13KQDHAQAIAAYI1R13KQDHAQAAAA==.逍遥圣光:BAABLAAECn8XAAIRAAgInw/SQQBWAQARAAgInw/SQQBWAQAAAA==.',['铭誠']='铭誠:BAAALAAECgYIBgAAAA==.',['阿儿']='阿儿萨斯:BAAALAAECgEIAQAAAA==.',['阿咪']='阿咪:BAACLAAFFH8MAAIQAAIIKBX0FQBEAAAQAAIIKBX0FQBEAAAsAAQKfxQAAhAABgh/Guk3AJYBABAABgh/Guk3AJYBAAAA.',['阿寶']='阿寶:BAABLAAFFH8JAAIIAAIIVwembgBOAAAIAAIIVwembgBOAAAAAA==.',['阿萨']='阿萨斯之怒:BAAALAADCggIEgAAAA==.',['雅凯']='雅凯:BAAALAAFFAIIAgAAAA==.',['顺心']='顺心如意丶:BAAALAAECgYIDAAAAA==.',['骑圣']='骑圣灵精血:BAAALAAECgYICAAAAA==.',['高手']='高手:BAAALAADCgYIBgAAAA==.',['黑手']='黑手的动物园:BAAALAAFFAQIAgABLAAFFAYICAAFAIEUAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end