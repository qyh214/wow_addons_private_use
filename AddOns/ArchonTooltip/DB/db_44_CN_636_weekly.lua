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
 local lookup = {'Warlock-Destruction','Shaman-Restoration','Priest-Holy','Priest-Discipline','Paladin-Retribution','DeathKnight-Frost','Shaman-Elemental','Hunter-BeastMastery','Druid-Restoration','Druid-Guardian','DemonHunter-Any','DemonHunter-Vengeance','Hunter-Marksmanship','Warrior-Fury','Paladin-Protection','Mage-Frost','Mage-Arcane','DemonHunter-Havoc','Rogue-Assassination','Rogue-Subtlety','Warlock-Demonology','Priest-Shadow','Paladin-Holy','Druid-Feral','Druid-Balance','Warrior-Protection','Unknown-Unknown','Warlock-Affliction',}; local provider = {region='CN',realm='奈法利安',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ba='Bakc:BAAALAAFFAIIAgAAAA==.',Bt='Btsrh:BAABLAAECn8jAAIBAAgI9BqOGgAMAgABAAgI9BqOGgAMAgAAAA==.',De='Devilcraft:BAAALAADCgEIAQAAAA==.',Go='Gonara:BAAALAAECgUIAQAAAA==.',Gr='Graves:BAAALAAFFAIIAgABLAAFFAgIBQACAMEjAA==.',He='Hebrewprinc:BAAALAAECgYICgAAAA==.',Ir='Iris:BAAALAAFFAIIAgAAAA==.',Jo='Jojo:BAAALAAECgEIAQAAAA==.',Ki='Kimtaiyeon:BAAALAAECgYIDQAAAA==.',La='Labubu:BAACLAAFFH8VAAIDAAMIUBYGLQC9AAADAAMIUBYGLQC9AAAsAAQKfyoAAwMACAgQH8AlAFcCAAMACAgQH8AlAFcCAAQAAQj1BmFDACYAAAAA.Lappe:BAAALAAECgIIAgAAAA==.',Ma='Maga:BAAALAAECgUIBwAAAA==.',Mu='Mu:BAAALAAFFAQIBAAAAA==.',Ny='Nyxara:BAAALAADCgMIAwAAAA==.',Re='Repent:BAAALAAECgMIAwAAAA==.',Ri='Riceballs:BAAALAADCgIIAgAAAA==.',Va='Vavo:BAAALAAFFAIIAgAAAA==.',Vi='Violetmoon:BAAALAADCggIFgAAAA==.',Vu='Vurtne:BAAALAADCgIIAgAAAA==.',Wo='Woshishaman:BAAALAADCgIIAgAAAA==.',['Ïð']='Ïðïðïðïðïðïï:BAAALAAFFAIIAgAAAA==.',['一以']='一以德服人一:BAAALAAECgYIBgAAAA==.',['一克']='一克拉青春:BAAALAAECgQIAgAAAA==.',['一支']='一支间羟胺:BAAALAAECgYIDwAAAA==.',['一期']='一期一会:BAAALAAFFAIIAgAAAA==.',['一言']='一言不合:BAAALAADCgQIBAAAAA==.',['万影']='万影:BAAALAAECgYIBgAAAA==.',['万羽']='万羽:BAAALAAECgYIBgAAAA==.',['不舒']='不舒服:BAAALAAECgUIBQAAAA==.',['东方']='东方灬怒风:BAAALAAECgcIDAAAAA==.',['丨神']='丨神威丨:BAAALAAECgYIDwAAAA==.',['中流']='中流砥柱:BAAALAADCgcIBwAAAA==.',['丶王']='丶王迪恺:BAAALAAECgYIBgAAAA==.',['丶白']='丶白水:BAAALAAECgUIBgAAAA==.',['么么']='么么向前冲:BAAALAAFFAMIAgAAAA==.',['乳酸']='乳酸俊:BAAALAAFFAMIAwAAAA==.',['京战']='京战阁:BAAALAAECgIIAgAAAA==.',['从未']='从未拥有:BAABLAAFFH8FAAIFAAMIzBomPgCaAAAFAAMIzBomPgCaAAAAAA==.',['仲达']='仲达:BAAALAAECgYIBgAAAA==.',['伊斯']='伊斯瑞尔:BAAALAAECgQIBQAAAA==.',['佗罗']='佗罗夫斯基:BAAALAADCgQIBAAAAA==.',['你好']='你好:BAAALAAECgUIBQAAAA==.',['倾城']='倾城歌衫:BAAALAAECgcIDQAAAA==.',['假面']='假面辣椒:BAAALAAECgQIDwAAAA==.',['兔纳']='兔纳厄运:BAAALAADCgIIAgAAAA==.',['六库']='六库仙贼:BAAALAAECgMIAwAAAA==.',['六等']='六等星:BAAALAAECgYIBgAAAA==.',['兽震']='兽震四方:BAAALAAECgEIAQAAAA==.',['冬郭']='冬郭先生:BAAALAAECgcIEwAAAA==.',['冰雪']='冰雪月虹:BAAALAAECgYIBwAAAA==.',['冷血']='冷血图腾:BAABLAAFFH8JAAICAAIIYwvKYwBXAAACAAIIYwvKYwBXAAAAAA==.',['冷静']='冷静一下:BAAALAADCgYIBgAAAA==.',['凌云']='凌云壮志:BAAALAAECgUIBQAAAA==.',['凡斋']='凡斋:BAAALAAFFAIIAgAAAA==.',['剑斩']='剑斩雷霆:BAAALAAECgEIAQAAAA==.',['加勒']='加勒个游:BAAALAAECgUIBAAAAA==.',['北海']='北海丨夜:BAAALAAECgYICQAAAA==.',['十方']='十方俱灭丶:BAAALAAECggIEwABLAAFFAgIBgAGALoRAA==.',['千山']='千山墨雪:BAAALAAFFAIIBAAAAA==.',['千幻']='千幻丶:BAABLAAFFH8xAAIHAAYIbSRpCQAXAgAHAAYIbSRpCQAXAgAAAA==.',['单挑']='单挑你的嘴:BAAALAAECggIDQAAAA==.',['单程']='单程票:BAAALAAECgEIAQAAAA==.',['卟離']='卟離卟棄:BAABLAAFFH8SAAIIAAYI/iHUAgBfAgAIAAYI/iHUAgBfAgAAAA==.',['右手']='右手写爱:BAABLAAFFH8RAAMJAAUIVRYFGwBUAQAJAAUIVRYFGwBUAQAKAAII9AObEQAfAAAAAA==.',['后丶']='后丶羿:BAAALAAFFAIIBAAAAA==.',['后羿']='后羿丶:BAAALAAECgYIBgAAAA==.',['吹得']='吹得我头疼:BAAALAAECgYIDAAAAA==.',['咖啡']='咖啡味啾啾:BAAALAAECgEIAQAAAA==.咖啡拌糖:BAAALAAECgYICAAAAA==.',['咸蛋']='咸蛋黄:BAABLAAFFH8GAAICAAYI5Bj9BQDjAQACAAYI5Bj9BQDjAQAAAA==.',['哀木']='哀木涕丶丶:BAAALAADCgIIAgAAAA==.',['哀穆']='哀穆梯:BAAALAAECgYICwAAAA==.',['哈伦']='哈伦斯:BAAALAAECgYIBgAAAA==.',['哎是']='哎是:BAAALAAECgEIAQAAAA==.',['哼哈']='哼哈二将:BAABLAAFFH8GAAILAAYI7BEAAAAAAAAMAAYI7BEAAAAAAAAAAA==.',['啪啪']='啪啪一啪啪:BAAALAAECgYIDQAAAA==.',['嘟嘟']='嘟嘟胖:BAAALAADCgUICgAAAA==.',['嘼血']='嘼血沸腾:BAAALAADCgEIAQAAAA==.',['四季']='四季逗:BAAALAAECgUIBQAAAA==.',['团队']='团队毒瘤:BAAALAAECgYICwAAAA==.',['圣光']='圣光无名:BAABLAAFFH8rAAIFAAYI/SQoBQAXAgAFAAYI/SQoBQAXAgAAAA==.',['垃圾']='垃圾病毒:BAAALAADCgMIBgAAAA==.',['埃之']='埃之:BAAALAAECgcICAAAAA==.埃之魂:BAAALAAECgUIBQAAAA==.',['埃辛']='埃辛诺:BAAALAAECgQICAAAAA==.埃辛诺斯之魂:BAAALAAECgUIBQAAAA==.埃辛诺斯之魄:BAAALAAECgYIBgAAAA==.',['城墙']='城墙:BAAALAAFFAIIAgAAAA==.',['塞薇']='塞薇莉雅丶:BAAALAADCgQIBQAAAA==.',['壹玖']='壹玖玖贰:BAAALAAECgMIAwAAAA==.',['夜激']='夜激舞情:BAAALAAECgYICwAAAA==.',['夜瓣']='夜瓣无眠:BAABLAAECn8cAAMNAAYIkBGFFAAKAQANAAYIRBCFFAAKAQAIAAQI2w16+ACXAAAAAA==.',['奈我']='奈我和:BAAALAAECgYIEQAAAA==.',['奥尔']='奥尔托斯:BAAALAADCggICQAAAA==.',['奥斯']='奥斯卡飞机:BAAALAADCgUIBQAAAA==.',['女施']='女施主请上炕:BAAALAAECgIIAgAAAA==.',['女神']='女神的圣斗士:BAAALAAECgcIBwAAAA==.',['奶油']='奶油图图:BAABLAAFFH8GAAIOAAYIzwMVLAABAQAOAAYIzwMVLAABAQAAAA==.',['妖娆']='妖娆小晴:BAAALAADCggIDwAAAA==.',['妖怪']='妖怪:BAAALAAECgIIAgAAAA==.',['嬹嫡']='嬹嫡雅:BAAALAAECgIIAgAAAA==.',['孓夜']='孓夜丱狂想:BAAALAAECggIDwAAAA==.',['宁姚']='宁姚:BAAALAAECgcIDQAAAA==.',['守护']='守护冰灵:BAABLAAFFH8LAAMPAAMI6BxsDgCaAAAPAAMI6BxsDgCaAAAFAAIIkAaFdwA5AAAAAA==.',['定江']='定江山:BAABLAAECn8XAAIFAAYIcBx4RACOAQAFAAYIcBx4RACOAQAAAA==.',['宛若']='宛若清风:BAAALAAECgYIDAAAAA==.',['寒丶']='寒丶傷:BAAALAAFFAIIAgAAAA==.',['小嘴']='小嘴真甜:BAABLAAECn8hAAIQAAgIRxp9GABWAgAQAAgIRxp9GABWAgAAAA==.',['小张']='小张丶魔:BAAALAAECgYIBgAAAA==.',['尐刀']='尐刀:BAABLAAFFH8oAAIFAAYIKiWQAwA6AgAFAAYIKiWQAwA6AgABLAAFFAgIBQAGAPUhAA==.',['尐宝']='尐宝宝:BAABLAAFFH8GAAIIAAYIxhfuCwDZAQAIAAYIxhfuCwDZAQAAAA==.',['尐寒']='尐寒焰:BAABLAAFFH8RAAIRAAYIxx0YGgCzAQARAAYIxx0YGgCzAQAAAA==.',['尐德']='尐德:BAABLAAFFH8GAAIJAAYIZA3nCACEAQAJAAYIZA3nCACEAQAAAA==.',['尐恶']='尐恶魔:BAABLAAFFH8NAAISAAYISRnQHgCHAQASAAYISRnQHgCHAQAAAA==.',['尐战']='尐战:BAABLAAFFH8uAAIOAAYItiGhBgAsAgAOAAYItiGhBgAsAgAAAA==.',['尐术']='尐术:BAABLAAFFH8FAAIBAAUIaiXALABnAQABAAUIaiXALABnAQAAAA==.',['尐死']='尐死骑:BAABLAAFFH8oAAIGAAYIWCPYFQDlAQAGAAYIWCPYFQDlAQAAAA==.',['尐毛']='尐毛贼:BAABLAAFFH8rAAMTAAYI6x+tAwC9AQATAAYIpR+tAwC9AQAUAAIICA56DwCEAAAAAA==.',['尐浩']='尐浩天:BAABLAAFFH80AAIOAAYIjCH4BQA4AgAOAAYIjCH4BQA4AgAAAA==.',['尐灬']='尐灬情话:BAABLAAFFH8GAAMBAAQIVBk5HQBKAQABAAQIVBk5HQBKAQAVAAIIiwjHFgA9AAAAAA==.尐灬月影逐魂:BAAALAAECggIDgAAAA==.',['尐牧']='尐牧:BAABLAAFFH8RAAMDAAYIdx+gAwAwAgADAAYIdx+gAwAwAgAWAAEI+BbAJABSAAAAAA==.',['尐闪']='尐闪电:BAABLAAFFH8MAAMCAAYIwByjAwAaAgACAAYIwByjAwAaAgAHAAEI1AGdUAAzAAAAAA==.',['尛丨']='尛丨坤坤:BAAALAAECgIIAgAAAA==.',['就你']='就你叫夏洛啊:BAAALAAECgYIBgAAAA==.',['山海']='山海丨草東:BAAALAAECgYIEgAAAA==.',['巧里']='巧里洼:BAACLAAFFH8TAAIUAAUIZA/6CgDpAAAUAAUIZA/6CgDpAAAsAAQKfyEAAxQACAgvHBoKAJ4CABQACAgvHBoKAJ4CABMABgg/EuE7AGoBAAAA.',['市场']='市场监管丶:BAAALAAECgQIBAAAAA==.',['布尔']='布尔凯索之子:BAAALAAECgEIAQAAAA==.',['布雷']='布雷克斯希伽:BAAALAAECggICAAAAA==.',['幻夜']='幻夜圣灵王:BAAALAAFFAIIAgAAAA==.',['建维']='建维:BAAALAAECgYIBgAAAA==.',['彪悍']='彪悍纯牛:BAAALAAECgcIDQAAAA==.',['德古']='德古拉复活:BAAALAAECgYIDQAAAA==.',['心一']='心一:BAABLAAFFH8kAAIGAAYIYh0oGwDKAQAGAAYIYh0oGwDKAQAAAA==.心一丶:BAACLAAFFH8fAAIFAAYIvCDnDQDVAQAFAAYIvCDnDQDVAQAsAAQKfxQAAwUABggLI0VQAE8CAAUABggLI0VQAE8CABcAAQjTEXFDADYAAAAA.',['心梦']='心梦缘飞:BAAALAAFFAIIAgAAAA==.',['怒风']='怒风丹丹:BAAALAAECgYIEgAAAA==.',['恩地']='恩地:BAAALAAFFAUIAwAAAA==.',['惊心']='惊心:BAAALAAECgYIDQAAAA==.',['惺火']='惺火燎源:BAABLAAFFH8IAAIGAAMI1Q+WYACMAAAGAAMI1Q+WYACMAAAAAA==.',['慕斯']='慕斯小奶糕:BAAALAAECgYIBgAAAA==.',['我你']='我你本良人:BAAALAAECgYIEAAAAA==.',['我后']='我后面有人:BAAALAAECgYICAAAAA==.',['我太']='我太狂:BAAALAAECgYIBwAAAA==.',['我带']='我带地狱犬:BAAALAAFFAYIBAAAAA==.',['我是']='我是你炎哥:BAAALAAECgUIBQAAAA==.我是防骑:BAAALAAECgYICgAAAA==.',['戦神']='戦神阿怒:BAAALAAECgQIBQAAAA==.',['拒绝']='拒绝崇拜:BAAALAADCgEIAQAAAA==.',['拘灵']='拘灵遣将:BAABLAAECn8YAAMVAAYIORd4LwCxAQAVAAYIORd4LwCxAQABAAUIFAu5awC8AAAAAA==.',['推倒']='推倒怪力女:BAAALAAECgQIBAAAAA==.',['摸鱼']='摸鱼儿:BAAALAAECggICAAAAA==.',['救赎']='救赎的瞬间:BAAALAAECggICAAAAA==.',['教父']='教父阿杰:BAAALAAECgcICQAAAA==.',['旋风']='旋风丶小张:BAAALAAECgYIBgAAAA==.',['无忌']='无忌丶暖暖:BAAALAADCgcIBwAAAA==.',['时光']='时光守卫:BAACLAAFFH8IAAIFAAIIzhFfRgCaAAAFAAIIzhFfRgCaAAAsAAQKfxYAAgUABwgDGISIAN0BAAUABwgDGISIAN0BAAAA.',['星之']='星之救世主:BAABLAAECn8WAAIYAAcI2xSEDQBeAQAYAAcI2xSEDQBeAQAAAA==.',['春风']='春风沐宇:BAAALAAECgcICgAAAA==.',['是猫']='是猫不是熊:BAAALAAECgQIBwAAAA==.',['晨昏']='晨昏线:BAABLAAFFH8NAAIGAAMITQajZwB5AAAGAAMITQajZwB5AAAAAA==.',['晨曦']='晨曦朝霞:BAAALAAFFAIIAgAAAA==.',['晨露']='晨露咏叹:BAACLAAFFH8IAAMEAAIItAzOBQBbAAAEAAIItAzOBQBbAAAWAAIIRQPmMQAqAAAsAAQKfysAAwQACAg9FXEEABoCAAQACAg9FXEEABoCABYAAgi0CrFBAGQAAAAA.',['暮色']='暮色部落:BAAALAAFFAIIBAAAAA==.',['暴走']='暴走的方便面:BAAALAAECgYICQAAAA==.',['曉静']='曉静同學:BAAALAADCgcIBwAAAA==.',['月光']='月光终成沙漠:BAAALAAECgYIBgAAAA==.',['木槿']='木槿:BAAALAAECgYIBgAAAA==.',['本人']='本人二四未婚:BAABLAAFFH8KAAIGAAIIWBhkVACeAAAGAAIIWBhkVACeAAAAAA==.本人十八未婚:BAAALAAFFAIIAwABLAAFFAgIOgABAPghAA==.',['术数']='术数数术:BAABLAAECn8UAAIBAAgIgBR6UQD9AQABAAgIgBR6UQD9AQAAAA==.',['杨小']='杨小萌:BAAALAAECgcIDwAAAA==.',['杨菊']='杨菊花:BAAALAAECgYIBQAAAA==.',['枫可']='枫可恋:BAAALAAECgYIDAAAAA==.',['桂兰']='桂兰:BAACLAAFFH8GAAMIAAII4x82hwBKAAANAAEIsx18MQBXAAAIAAIIlx82hwBKAAAsAAQKfxUAAwgABghRHztbAIwBAAgABghRHztbAIwBAA0ABgiFEEZhADoBAAAA.',['梦琪']='梦琪小可爱:BAAALAAECgQIBAAAAA==.',['棉花']='棉花囡囡:BAABLAAFFH8IAAICAAIIGQRPcgBHAAACAAIIGQRPcgBHAAAAAA==.',['椰椰']='椰椰芒芒:BAABLAAFFH8FAAMZAAIIsA9lHwCNAAAZAAIIsA9lHwCNAAAJAAEI7AaKUAAxAAABLAAFFAYICAAXACUkAA==.',['椰芒']='椰芒奶昔:BAABLAAFFH8GAAMOAAIISx91JACyAAAOAAIISx91JACyAAAaAAEIUgzpMgA6AAABLAAFFAYICAAXACUkAA==.',['正玩']='正玩着呢:BAAALAADCgIIAgAAAA==.',['毗沙']='毗沙门天:BAAALAAECgUIBQAAAA==.',['水上']='水上花:BAAALAAFFAIIBAAAAA==.',['沉鱼']='沉鱼落雁:BAAALAAECgMIAwAAAA==.',['洗浴']='洗浴德:BAABLAAFFH8YAAIJAAUIpxJTHgAyAQAJAAUIpxJTHgAyAQAAAA==.',['流年']='流年浮世:BAAALAAECgUIBQAAAA==.',['浅雪']='浅雪:BAAALAAFFAIIAwAAAA==.',['涅冫']='涅冫槃:BAAALAAECgYIBwAAAA==.',['消失']='消失的下雨天:BAAALAADCgEIAQAAAA==.',['深海']='深海萝莉凤灬:BAAALAAECgIIAQAAAA==.',['温暖']='温暖的弦:BAAALAADCgYIBgAAAA==.',['渲染']='渲染了离别:BAAALAADCgYIBgABLAADCggICAAbAAAAAA==.',['滴滴']='滴滴代喝:BAAALAADCgIIAgAAAA==.',['澎湃']='澎湃的小哥:BAAALAAECgYIDAAAAA==.',['火妖']='火妖法:BAABLAAECn8UAAMQAAcI1BrUHwAdAgAQAAcI1BrUHwAdAgARAAEILwiMBwEuAAAAAA==.',['灬浅']='灬浅黛微妆灬:BAAALAAECgYICwAAAA==.',['灬渲']='灬渲染了离别:BAAALAADCggICAAAAA==.',['灬闷']='灬闷骚气质哥:BAAALAAECgMIAwAAAA==.',['灬隐']='灬隐三市灬:BAABLAAFFH8GAAIJAAIIgBm7NwCMAAAJAAIIgBm7NwCMAAAAAA==.',['灯露']='灯露椎:BAAALAAFFAIIAgAAAA==.',['灵思']='灵思风:BAAALAADCgEIAQAAAA==.',['炎哥']='炎哥哥好帅:BAAALAAECgEIAQAAAA==.',['熊丨']='熊丨生之响往:BAAALAAECgYICAAAAA==.',['熊猫']='熊猫人一武僧:BAAALAADCgIIAgAAAA==.',['爱苹']='爱苹果爱香橙:BAAALAAECgYIBgAAAA==.',['爽了']='爽了就喊出来:BAAALAADCgQIBAAAAA==.',['牛爆']='牛爆:BAAALAAECgEIAQAAAA==.',['牛胖']='牛胖胖:BAAALAAECggIDwAAAA==.',['牛马']='牛马:BAAALAAECgMIAwAAAA==.',['特里']='特里斯蒂娅:BAABLAAFFH8GAAIFAAIIhQrocQA9AAAFAAIIhQrocQA9AAAAAA==.',['犇啵']='犇啵儿霸:BAAALAAECgUIBQAAAA==.',['猫咪']='猫咪公主:BAABLAAFFH8GAAIDAAIIahyTLACTAAADAAIIahyTLACTAAAAAA==.',['玄一']='玄一:BAABLAAECn8WAAIJAAYICBQoOAA+AQAJAAYICBQoOAA+AQAAAA==.',['王小']='王小叁:BAAALAAECgUIBQAAAA==.',['玛法']='玛法里奧:BAAALAAECgMIAwAAAA==.',['玲娜']='玲娜贝儿:BAAALAAECgYICwAAAA==.',['瓦尔']='瓦尔基丽娅:BAAALAADCgYIBgAAAA==.',['甜橙']='甜橙好吃:BAAALAADCgIIAgAAAA==.甜橙好吃呀:BAAALAAECgQIBgAAAA==.甜橙真好吃:BAAALAAECgIIAwAAAA==.',['甲状']='甲状腺:BAAALAADCgIIAgAAAA==.',['番茄']='番茄意面:BAAALAAECgYIDgAAAA==.',['监察']='监察执法丶:BAAALAADCgEIAQAAAA==.',['盖世']='盖世无双:BAAALAAFFAIIBAAAAA==.',['碧雲']='碧雲光环:BAAALAAECgcIEgAAAA==.',['神偷']='神偷奶牛:BAAALAADCgYIBgAAAA==.',['神圣']='神圣照耀大地:BAAALAAECgYIDAAAAA==.',['神奇']='神奇的豆豆:BAAALAAECgEIAQAAAA==.',['神明']='神明灵:BAAALAAECgYICgAAAA==.',['私人']='私人定制:BAAALAAECgYICgAAAA==.',['秋叶']='秋叶原的贼皇:BAAALAAECgIIAgAAAA==.',['笑忘']='笑忘歌:BAAALAAECgUIEAAAAA==.',['精灵']='精灵的挽歌:BAAALAADCgYIBgAAAA==.',['糖豆']='糖豆好大颗:BAAALAADCgMIAwAAAA==.',['索尼']='索尼灬克:BAABLAAECn8VAAIIAAYI4Bk7cQBhAQAIAAYI4Bk7cQBhAQAAAA==.',['紫仑']='紫仑:BAAALAAECgYIDAAAAA==.',['紫韵']='紫韵梧桐:BAAALAAECgYIBgAAAA==.',['维丶']='维丶他丶命:BAAALAAECgYIBgAAAA==.',['绽放']='绽放死亡:BAAALAAFFAIIBAAAAA==.',['老衲']='老衲法号射牛:BAAALAAECgYIBgAAAA==.',['老雪']='老雪花丶冰蓝:BAAALAAFFAQIBAAAAA==.',['聖骑']='聖骑:BAAALAADCgcIBwAAAA==.',['胧月']='胧月丶夜悠然:BAAALAADCgEIAQAAAA==.',['至高']='至高大牛:BAAALAAECgIIAgAAAA==.',['艺高']='艺高人胆大:BAAALAADCgcIBgAAAA==.',['艾丽']='艾丽索兰德:BAAALAADCgQIBgAAAA==.',['芝士']='芝士芒芒:BAACLAAFFH8IAAIXAAIIJSQwEQDXAAAXAAIIJSQwEQDXAAAsAAQKfxQAAhcABgjsIYscACoCABcABgjsIYscACoCAAAA.',['苏拉']='苏拉:BAAALAADCggICAAAAA==.',['苏沐']='苏沐橙:BAACLAAFFH8gAAICAAYIwRvZDwDoAQACAAYIwRvZDwDoAQAsAAQKfx0AAgIACAjPHg9GAAwCAAIACAjPHg9GAAwCAAAA.',['苯妥']='苯妥英钠:BAABLAAECn8VAAIDAAYIjRLuZQBKAQADAAYIjRLuZQBKAQAAAA==.',['英俊']='英俊的青年人:BAAALAAECgQIBQAAAA==.',['莉亚']='莉亚徳琳:BAAALAAECgMIAwAAAA==.',['莫晚']='莫晚云:BAABLAAECn8VAAIDAAgImhGySACzAQADAAgImhGySACzAQAAAA==.',['菲利']='菲利斯多:BAABLAAFFH8GAAICAAYIMiEEAgBQAgACAAYIMiEEAgBQAgAAAA==.',['萌妹']='萌妹子呀:BAAALAAECgQIBAAAAA==.',['萌悳']='萌悳很:BAAALAAFFAIIAgAAAA==.',['萌的']='萌的很:BAAALAAFFAIIBAAAAA==.',['落山']='落山鸡:BAAALAAECgMIAQAAAA==.',['落落']='落落无情:BAAALAAECggICAAAAA==.',['落雁']='落雁:BAAALAAECgQIBAAAAA==.',['薄荷']='薄荷小奶酪:BAAALAAECgYIBgAAAA==.',['蘑菇']='蘑菇劣:BAAALAAFFAIIAgAAAA==.',['蜜桃']='蜜桃乌龙茶:BAAALAADCgIIAgAAAA==.',['血咒']='血咒战歌:BAABLAAFFH8GAAIFAAYIPhP+HQB0AQAFAAYIPhP+HQB0AQAAAA==.',['血色']='血色英博:BAAALAAECgYIBgAAAA==.',['行于']='行于流逝的岸:BAAALAAECgUIBQAAAA==.',['誓言']='誓言谎言:BAAALAAFFAIIAgAAAA==.',['诅咒']='诅咒圆舞曲:BAAALAAECgYIDQAAAA==.',['请神']='请神儿啦:BAAALAAECgEIAQAAAA==.',['赢焰']='赢焰:BAAALAAECgYIBgAAAA==.',['赫卡']='赫卡忒光明:BAAALAAECgMIAwAAAA==.',['轩轩']='轩轩吾儿:BAABLAAFFH8HAAIFAAYIvQ8/PACjAAAFAAYIvQ8/PACjAAAAAA==.',['转丶']='转丶身:BAAALAADCgEIAQAAAA==.',['这牛']='这牛有点意思:BAAALAAECgYICQAAAA==.',['迪亚']='迪亚菠萝:BAAALAAECgIIAgAAAA==.',['迪西']='迪西唔西:BAAALAAECgUIBQAAAA==.',['迪门']='迪门修斯:BAAALAADCgMIAwAAAA==.',['追风']='追风小恶魔:BAABLAAFFH8GAAIMAAIIoBMNEwA2AAAMAAIIoBMNEwA2AAAAAA==.追风小牧:BAAALAAECggICAAAAA==.追风小猫熊:BAAALAAFFAIIBAAAAA==.追风小邪:BAAALAAFFAIIBAAAAA==.追风小骑:BAABLAAFFH8GAAIPAAIIjBr9FQBJAAAPAAIIjBr9FQBJAAAAAA==.',['逍遥']='逍遥小战:BAABLAAFFH8FAAIaAAIIhwnUNgAqAAAaAAIIhwnUNgAqAAAAAA==.逍遥追风:BAABLAAFFH8TAAQKAAYIcRt4BwB5AAAZAAQIgxy1GwD2AAAJAAIIchOBOgCDAAAKAAMItxR4BwB5AAAAAA==.',['逸秋']='逸秋:BAAALAAECgIIAgAAAA==.',['逻辑']='逻辑死角:BAABLAAFFH8GAAISAAIIcRH+TwBJAAASAAIIcRH+TwBJAAAAAA==.',['醉美']='醉美肖梦琪:BAAALAAECggIBgAAAA==.',['重炮']='重炮:BAAALAAECgMIAwAAAA==.',['野蛮']='野蛮人:BAABLAAECn8hAAIOAAYImxvxMgCOAQAOAAYImxvxMgCOAQAAAA==.',['錦木']='錦木千束:BAAALAADCgIIAgAAAA==.',['鍩鍩']='鍩鍩:BAAALAAECgYIBgAAAA==.',['铁公']='铁公鸡:BAAALAADCggICAAAAA==.',['银流']='银流:BAAALAAECgcIBwAAAA==.',['银火']='银火:BAAALAAECgIIAgAAAA==.',['锤不']='锤不死:BAAALAADCgUIBQAAAA==.',['阴眸']='阴眸:BAAALAADCgcIDQAAAA==.',['阿兰']='阿兰娜:BAAALAADCgYIBgAAAA==.',['阿凡']='阿凡昂神:BAAALAAECgYIEgAAAA==.',['阿狼']='阿狼:BAAALAAECgYIBgAAAA==.',['随地']='随地乱插:BAAALAADCgYIBgAAAA==.随地插棍:BAAALAADCggICAAAAA==.',['雲深']='雲深不知处:BAAALAAECgUIBQAAAA==.',['零度']='零度基因:BAABLAAFFH8IAAMQAAIIyApeHAA4AAAQAAIIyApeHAA4AAARAAIIlgVGZAA3AAAAAA==.',['雷神']='雷神丿之怒:BAAALAAECgYIBgAAAA==.',['雷鸣']='雷鸣寒爆:BAAALAAECgEIAQAAAA==.',['非常']='非常黑了:BAAALAAECggICAAAAA==.',['顽灬']='顽灬固:BAAALAAECgMIAwAAAA==.',['风云']='风云再起:BAAALAAECgIIAwAAAA==.风云小妖:BAAALAAECgYICAAAAA==.',['风骚']='风骚的炎哥:BAAALAAECgYICwAAAA==.',['饮怒']='饮怒:BAAALAAECgEIAQAAAA==.',['驴小']='驴小德:BAAALAAECgYIBgAAAA==.驴小懒:BAABLAAFFH8HAAICAAMIQASRWABqAAACAAMIQASRWABqAAAAAA==.',['魅舞']='魅舞:BAAALAAECgYIBgAAAA==.',['魔界']='魔界天晶:BAAALAAECgUIBQAAAA==.',['鲜血']='鲜血女皇:BAACLAAFFH8SAAMBAAMIjBWmJwDuAAABAAMIjBWmJwDuAAAVAAIIDxE+KgBNAAAsAAQKfxsABAEACAhrHSosAI8CAAEACAhrHSosAI8CABUABQilFUVGAFYBABwAAQgZEwI7AEYAAAAA.',['黑龙']='黑龙也是龙:BAAALAAECgYIBgAAAA==.',['默听']='默听风啸:BAAALAAECgYIBgAAAA==.',['黯然']='黯然飘渺丶风:BAAALAAECgYIBgAAAA==.',['黯熙']='黯熙徵伖:BAAALAAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end