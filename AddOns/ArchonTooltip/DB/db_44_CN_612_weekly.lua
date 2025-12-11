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
 local lookup = {'Priest-Holy','Priest-Shadow','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Monk-Mistweaver','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','DeathKnight-Frost','Warrior-Fury','Warrior-Protection','Unknown-Unknown','Paladin-Retribution','Shaman-Restoration','Paladin-Holy','Paladin-Protection','DeathKnight-Blood','Evoker-Augmentation','Evoker-Preservation','Mage-Arcane','DemonHunter-Vengeance','DeathKnight-Melee','Monk-Windwalker','Monk-Brewmaster','Druid-Restoration','Priest-Discipline','Evoker-Devastation','DeathKnight-Unholy','Shaman-Elemental','Rogue-Assassination','Druid-Guardian','Mage-Fire','Mage-Frost','Druid-Feral','Druid-Balance','Warrior-Arms','Hunter-Survival','Rogue-Subtlety',}; local provider = {region='CN',realm='图拉扬',name='CN',type='weekly',zone=44,date='2025-12-06',data={Aa='Aaronluo:BAAALAAECgEIAQAAAA==.Aaronworld:BAAALAAECgIIAgAAAA==.',An='Anemone:BAACLAAFFH8OAAMBAAII6hzLIQC0AAABAAII6hzLIQC0AAACAAEI8wSSMAAyAAAsAAQKfx0AAwIABgieGrU9AMYBAAIABgieGrU9AMYBAAEABgiKFrVRAJABAAAA.',At='Athena:BAAALAAFFAIIBAAAAA==.',Az='Azzinothbaby:BAABLAAFFH8MAAIDAAIIhiAaKQC7AAADAAIIhiAaKQC7AAAAAA==.',Ba='Bagandbag:BAACLAAFFH8ZAAMEAAUIzhafJADrAAAEAAUIfxafJADrAAAFAAMI+hi0FgC1AAAsAAQKfxsAAwQABgg2IK1gABoCAAQABgg+H61gABoCAAUABggJHo40AO0BAAEsAAUUBQgcAAYA6RwA.',Bu='Burpees:BAAALAAFFAIIAgAAAA==.',Ch='Charoon:BAAALAAECgIIAgAAAA==.Christiajean:BAAALAAECgIIAgAAAA==.',Ci='Cinderrella:BAAALAAECgUIBQAAAA==.',Cr='Cruusoe:BAABLAAECn8dAAQHAAgIiBndMwCeAQAIAAcIjBGAbQCtAQAHAAYIjRjdMwCeAQAJAAMIPBvsIQDcAAAAAA==.',De='Death:BAAALAADCgUIBQAAAA==.Deathhunter:BAAALAAECgIIAgAAAA==.',Dr='Drifting:BAABLAAFFH8HAAIDAAIIcARraAA3AAADAAIIcARraAA3AAABLAAFFAYIGAAEANUYAA==.Druiswid:BAAALAADCgYIBgAAAA==.',El='Eln:BAAALAAECgUICAAAAA==.',Fa='Fayee:BAAALAAFFAYIAgABLAAFFAgIBgAKAIwUAA==.Fayy:BAABLAAFFH8LAAMLAAYIyyB5EADUAQALAAYIyyB5EADUAQAMAAUIKA5qGADiAAAAAA==.',Fo='Fountine:BAAALAAECgUIBQABLAAFFAgIAgANAAAAAA==.',Io='Iovoi:BAAALAADCgEIAQAAAA==.',Ji='Jimmygejm:BAAALAAECgYICAAAAA==.',Ke='Kelseycat:BAABLAAFFH8aAAIKAAYIxRScLQCDAQAKAAYIxRScLQCDAQAAAA==.',La='Lanaru:BAAALAAECgcIBwAAAA==.Lanaya:BAAALAAECgQIBAAAAA==.Lazarus:BAAALAAECgYIBgAAAA==.',Li='Lisam:BAAALAAECgYICgAAAA==.',Ma='Mandriva:BAACLAAFFH9MAAIEAAgIzhrICABVAgAEAAgIzhrICABVAgAsAAQKfzQAAgQACAhCJOkgANYCAAQACAhCJOkgANYCAAAA.',Me='Mercy:BAAALAAECgYIBgAAAA==.',Ne='Newi:BAAALAAFFAIIBAAAAA==.',Ni='Niutousha:BAAALAAECgYIBgAAAA==.',No='Nostalie:BAACLAAFFH8zAAILAAYIoCAyDgDnAQALAAYIoCAyDgDnAQAsAAQKfz8AAgsACAhOJdUHAFgDAAsACAhOJdUHAFgDAAAA.',Ol='Ollie:BAAALAAECgUICQAAAA==.',Pa='Palad:BAAALAAFFAIIAgAAAA==.Pallas:BAACLAAFFH8cAAIOAAYIZROhFwAAAQAOAAYIZROhFwAAAQAsAAQKfzUAAg4ACAjHIZ0bAAUDAA4ACAjHIZ0bAAUDAAAA.',Pi='Pikachuu:BAABLAAFFH8IAAIPAAYIIhrbHgBlAQAPAAYIIhrbHgBlAQAAAA==.',Po='Poloniny:BAABLAAFFH8IAAMQAAIIvCIbEgDPAAAQAAIIvCIbEgDPAAARAAIIzAdyHgBjAAAAAA==.',Py='Pyrrla:BAAALAAECgYIDAAAAA==.',Ra='Rainbowg:BAAALAAECgcICgAAAA==.',Ru='Rushrush:BAAALAAFFAIIAgAAAA==.',Sa='Salgolagnia:BAABLAAFFH8aAAMHAAUIXBeqEQChAAAIAAUINBe4NQA6AQAHAAIIgBmqEQChAAAAAA==.',Sh='Shardows:BAABLAAFFH8hAAMIAAYI+RFUKwBtAQAIAAYI+RFUKwBtAQAHAAIIfQXKHACEAAAAAA==.',Si='Sickovode:BAABLAAFFH8IAAILAAYI4BeXFwCjAQALAAYI4BeXFwCjAQAAAA==.',Sk='Skrskr:BAAALAAECgQIBAAAAA==.Sky:BAAALAADCgQIBAAAAA==.',So='Solaris:BAABLAAECn8aAAIDAAYIBxkOjACuAQADAAYIBxkOjACuAQAAAA==.',St='Stormhunter:BAAALAAECgYIEwAAAA==.',Sw='Sweety:BAABLAAFFH8MAAMKAAIIIAtWjABAAAAKAAIIewdWjABAAAASAAIIHAsLHAAxAAAAAA==.',Ta='Taylormomsen:BAAALAAECggIDwAAAA==.',Th='Thanatoss:BAAALAAFFAIIAgAAAA==.Thnewss:BAABLAAFFH8fAAIEAAcI6h5yBwALAgAEAAcI6h5yBwALAgAAAA==.',Va='Valer:BAABLAAFFH8RAAMTAAYIZxeeBACZAQATAAYIZxeeBACZAQAUAAIIUgTEGwBiAAAAAA==.Valora:BAAALAAECgUIBQAAAA==.',Vo='Volock:BAAALAADCgIIAgAAAA==.',Wa='Warbringer:BAAALAADCggICAABLAAFFAMIDAAVAMYZAA==.',Wq='Wqhdkovo:BAAALAAFFAIIAgAAAA==.',Xy='Xygg:BAABLAAFFH8VAAIDAAYImBpfHACTAQADAAYImBpfHACTAQAAAA==.Xyook:BAABLAAFFH8GAAIOAAIIlBP+SQCXAAAOAAIIlBP+SQCXAAAAAA==.Xyzz:BAABLAAFFH8RAAIVAAUIbgwPNwAYAQAVAAUIbgwPNwAYAQABLAAFFAYIFQADAJgaAA==.',Ya='Yatoro:BAABLAAFFH8GAAIUAAYIhhZECwCeAQAUAAYIhhZECwCeAQAAAA==.',Yu='Yuukiasuna:BAAALAAFFAIIAgAAAA==.',Zn='Znlx:BAAALAADCgUIBQAAAA==.',['一剑']='一剑开心:BAABLAAFFH8dAAIOAAQISCDeLAAeAQAOAAQISCDeLAAeAQABLAAFFAYIGgAKAMUUAA==.',['一口']='一口酥:BAAALAAECggICAAAAA==.',['一朵']='一朵菊花台:BAABLAAFFH8LAAILAAIIxBZmQwBQAAALAAIIxBZmQwBQAAAAAA==.',['一枪']='一枪不发:BAAALAAECgEIAQAAAA==.',['一罐']='一罐可乐:BAAALAAECgYICQAAAA==.',['七月']='七月的风筝:BAAALAAECgIIAgAAAA==.',['七草']='七草荠:BAAALAAFFAIIAgAAAA==.',['万兽']='万兽之王:BAAALAAECgYIBgAAAA==.',['万岁']='万岁万岁:BAAALAAECgEIAQAAAA==.',['三个']='三个核桃圣骑:BAAALAAECgQIBAAAAA==.',['三叔']='三叔公:BAAALAADCggICAAAAA==.',['三段']='三段斗之气:BAABLAAFFH8OAAMRAAMI0h8OCwC+AAARAAMI0h8OCwC+AAAOAAIINA0tWACKAAAAAA==.',['三轩']='三轩家万智:BAACLAAFFH8NAAIPAAIIChL9UQBqAAAPAAIIChL9UQBqAAAsAAQKfyYAAg8ACAhDHS4nAHUCAA8ACAhDHS4nAHUCAAAA.',['三鹿']='三鹿奶粉:BAAALAAECgYIBgAAAA==.',['上帝']='上帝之怒:BAAALAAECgMIAwAAAA==.',['不会']='不会变羊:BAAALAAECgYIBgAAAA==.',['不要']='不要钱的阿喵:BAABLAAFFH8GAAMRAAIIaBYrEwCHAAAOAAIIpQ/JSwCWAAARAAIIfRIrEwCHAAAAAA==.',['与光']='与光同尘:BAABLAAFFH8HAAIKAAUIygqASgAJAQAKAAUIygqASgAJAQAAAA==.',['东尼']='东尼大木:BAAALAAECgcICQAAAA==.',['东部']='东部:BAAALAADCgEIAQAAAA==.',['丰川']='丰川祥子:BAAALAADCgIIAgAAAA==.',['丶全']='丶全村的希望:BAAALAAECgIIAQAAAA==.',['丶君']='丶君莫笑:BAABLAAFFH8IAAIOAAgIKAL9aQBBAAAOAAgIKAL9aQBBAAAAAA==.',['丶超']='丶超级小欧皇:BAAALAAFFAYIBAAAAA==.',['主角']='主角的好朋友:BAAALAAECggICAAAAA==.',['也门']='也门要战斗:BAAALAAFFAIIBAAAAA==.',['二路']='二路:BAAALAAECggICAAAAA==.',['亚瑟']='亚瑟斯:BAAALAADCgcIBwAAAA==.',['亞洲']='亞洲尊者:BAAALAAECgUIBQAAAA==.',['仙女']='仙女儿:BAABLAAFFH8MAAMBAAQIgxCGGADlAAABAAMIVBOGGADlAAACAAEIwwISLgBAAAAAAA==.',['伊利']='伊利一蒙牛:BAAALAAECgUIBQAAAA==.',['伊露']='伊露娜丶怒风:BAABLAAFFH8JAAMDAAMIaBRsHAD6AAADAAMIahNsHAD6AAAWAAIIvhfYDACNAAAAAA==.',['会长']='会长阿巴:BAAALAAECgEIAQAAAA==.',['传说']='传说呢袒克:BAAALAAECgMIAwAAAA==.',['伤敌']='伤敌一千:BAAALAAECgEIAQAAAA==.',['你不']='你不理人:BAAALAAECgUICAAAAA==.',['你们']='你们速度灭:BAABLAAFFH8GAAICAAIIlQstJACCAAACAAIIlQstJACCAAAAAA==.',['你叫']='你叫你吗讷:BAAALAADCgQIBgAAAA==.',['你喜']='你喜熊吗:BAAALAAECgEIAQAAAA==.',['保安']='保安爱上小丹:BAAALAAECgYIBgAAAA==.',['傻薇']='傻薇:BAAALAAFFAIIBAAAAA==.',['光与']='光与影之子:BAACLAAFFH8FAAIDAAIIiws0YAA/AAADAAIIiws0YAA/AAAsAAQKfxgAAgMABwiQGuhmAPoBAAMABwiQGuhmAPoBAAAA.',['光明']='光明聖殿士:BAAALAAECgcIBwAAAA==.',['光辉']='光辉魔月:BAAALAAECgUIBQAAAA==.',['克洛']='克洛諾斯:BAABLAAECn8UAAMWAAYIuhAYGgDNAAADAAUI4Q6tagDiAAAWAAYI9QsYGgDNAAABLAAFFAYIIQAIAPkRAA==.',['兜兜']='兜兜在召唤:BAAALAADCgMIAwAAAA==.',['八云']='八云紫:BAAALAAFFAIIAgAAAA==.',['再来']='再来十个丶:BAAALAAECgMIAwAAAA==.',['冻空']='冻空粉雪:BAABLAAFFH8LAAIQAAYInhy0AgAqAgAQAAYInhy0AgAqAgAAAA==.',['刀刀']='刀刀暴击丶:BAAALAADCgIIAgAAAA==.',['刁得']='刁得一:BAAALAAFFAIIBAAAAA==.',['别拖']='别拖我后腿:BAAALAAFFAIIAgAAAA==.',['别看']='别看了别看了:BAAALAADCgcIBwAAAA==.',['剑之']='剑之极:BAAALAAFFAIIAgAAAA==.',['剣指']='剣指酆都:BAAALAADCgEIAQAAAA==.',['剩骑']='剩骑士:BAAALAAECgQIBAAAAA==.',['包包']='包包沙:BAAALAAFFAEIAQAAAA==.',['十二']='十二:BAAALAAFFAIIAgAAAA==.',['千公']='千公男爵:BAAALAAECgEIAQAAAA==.',['单身']='单身狗:BAAALAAECgYIBgAAAA==.',['卡布']='卡布其诺长云:BAAALAAECgUICQAAAA==.',['原则']='原则上可以:BAACLAAFFH8HAAIIAAMIwhJRKgDiAAAIAAMIwhJRKgDiAAAsAAQKfxUAAwgABwicH+w1AGMCAAgABwicH+w1AGMCAAcAAQgDE8uRAEUAAAAA.',['变你']='变你个大头鬼:BAAALAAECggIEAAAAA==.',['只手']='只手摘星辰:BAAALAADCgIIAgAAAA==.',['召唤']='召唤大蠊:BAAALAADCggICAAAAA==.',['史蒂']='史蒂夫纳什:BAABLAAFFH8JAAIIAAYIkBSnKAB3AQAIAAYIkBSnKAB3AQAAAA==.',['吧吧']='吧吧巴巴:BAAALAAFFAIIAgAAAA==.',['呆板']='呆板黏:BAAALAAECgYICgAAAA==.',['呐滋']='呐滋咩:BAABLAAFFH8bAAIQAAYIJRY4CgBbAQAQAAYIJRY4CgBbAQAAAA==.',['呵呵']='呵呵哈哈丶:BAABLAAFFH8FAAIXAAUIbAkAAAAAAAAKAAUIbAkAAAAAAAAAAA==.',['咕噜']='咕噜噜冒泡泡:BAAALAADCgEIAQAAAA==.',['哈么']='哈么竟:BAAALAADCgEIAQAAAA==.',['哈维']='哈维斯:BAAALAAECgMIAwAAAA==.',['哎丶']='哎丶可惜啊:BAACLAAFFH8RAAMDAAMI5Ri+KQC5AAADAAMI5Ri+KQC5AAAWAAIIuxsxEgA8AAAsAAQKfyIAAwMACAjHHwElAMwCAAMACAhJHwElAMwCABYABgjYHeUYAP0BAAEsAAUUBQgcAAYA6RwA.',['唉丶']='唉丶怎么办:BAACLAAFFH8cAAMGAAUI6RwaCQCMAQAGAAUI6RwaCQCMAQAYAAQIOxMuDgDPAAAsAAQKfy0ABBgACAj+ItEXAE8CABgABgjyIdEXAE8CAAYACAi2GOsQAJUBABkABQgEHWQOAF0BAAAA.',['唤潮']='唤潮者米斯雷:BAAALAAECgMIAwAAAA==.',['啊辣']='啊辣辣九号:BAABLAAFFH8GAAIaAAYIGBnoDwDGAQAaAAYIGBnoDwDGAQAAAA==.',['啪啪']='啪啪以啪啪:BAAALAAECgUIBgAAAA==.',['喜欢']='喜欢跳丶:BAACLAAFFH8YAAMCAAUIVSLqBwDZAQACAAUIVSLqBwDZAQAbAAMIjxK+AgDAAAAsAAQKfzQAAgIACAg2Jv8CAG4DAAIACAg2Jv8CAG4DAAAA.',['四季']='四季崎记纪:BAABLAAFFH8GAAIKAAYIsx03BwAyAgAKAAYIsx03BwAyAgAAAA==.四季崎记纪伍:BAABLAAFFH8JAAIEAAYITCEdIwClAQAEAAYITCEdIwClAQAAAA==.',['四通']='四通:BAAALAAECgYIDQAAAA==.',['回天']='回天剑舞:BAAALAAECgUICAAAAA==.',['围观']='围观群衆:BAABLAAFFH8GAAISAAYIOQgMDwASAQASAAYIOQgMDwASAQAAAA==.',['圣光']='圣光狂暴战:BAAALAAECgYICwAAAA==.圣光霓裳:BAACLAAFFH8sAAIOAAUI4h+YIABkAQAOAAUI4h+YIABkAQAsAAQKfxoAAg4ACAh8IsgjAOMCAA4ACAh8IsgjAOMCAAAA.',['圣耀']='圣耀世人:BAABLAAFFH8JAAQQAAMIVhWtIgCNAAAQAAIIBR2tIgCNAAARAAMIfgf7EwBWAAAOAAIIeBkkZABEAAAAAA==.',['基因']='基因突变:BAAALAADCgQIBAAAAA==.',['堕落']='堕落萌天使:BAAALAAECgYIBgAAAA==.',['塞勒']='塞勒涅:BAACLAAFFH8SAAIaAAIIrBfoPgB2AAAaAAIIrBfoPgB2AAAsAAQKfxgAAhoABgg1FrhcAH4BABoABgg1FrhcAH4BAAAA.',['声微']='声微丶饭否:BAABLAAFFH8GAAISAAIIPRndDQCYAAASAAIIPRndDQCYAAAAAA==.',['夜凝']='夜凝霜:BAAALAAFFAIIAgAAAA==.',['夜雪']='夜雪:BAAALAADCgEIAQAAAA==.',['大一']='大一武一生:BAABLAAECn82AAMYAAYIBx/zIAD6AQAYAAYIBx/zIAD6AQAGAAYILhtTEQCNAQAAAA==.',['大地']='大地在忽悠你:BAABLAAECn8YAAIPAAYIThWNQQBUAQAPAAYIThWNQQBUAQAAAA==.',['大领']='大领主翠花:BAAALAADCgEIAQAAAA==.',['天上']='天上红绯:BAAALAAECgQIBAAAAA==.',['天使']='天使在流浪:BAAALAAECggICQAAAA==.',['天地']='天地无恒:BAAALAAECgQIBAAAAA==.',['天堂']='天堂倒影:BAAALAADCgQIBAAAAA==.天堂爆竹:BAABLAAECn8VAAIaAAgIYhS0OgD1AQAaAAgIYhS0OgD1AQAAAA==.',['天幕']='天幕之翼:BAAALAAECgQICQAAAA==.',['天选']='天选打工人:BAAALAAECgYIBgAAAA==.',['天道']='天道阿修罗:BAAALAAFFAYIAgAAAA==.',['天青']='天青色等煙雨:BAAALAAECgEIAQAAAA==.',['奈斩']='奈斩:BAABLAAECn8eAAIcAAgITR1eEACzAgAcAAgITR1eEACzAgAAAA==.',['奈斯']='奈斯兔米丘:BAAALAAECgYICgAAAA==.',['奶是']='奶是不可能的:BAABLAAFFH8HAAIBAAMIXQl7MgCfAAABAAMIXQl7MgCfAAAAAA==.',['如太']='如太阳般耀眼:BAAALAAECggIDwAAAA==.如太阳般闪耀:BAABLAAFFH8HAAIdAAUIFRuUBABhAQAdAAUIFRuUBABhAQAAAA==.',['妳聽']='妳聽得到:BAAALAAECgcIBQAAAA==.',['婲街']='婲街流血刃:BAAALAAECgQIBAAAAA==.',['嬴盈']='嬴盈:BAAALAAFFAIIAgAAAA==.',['安可']='安可:BAAALAADCggICQAAAA==.',['安奇']='安奇揦:BAACLAAFFH8KAAIGAAMIyCRMBwBEAQAGAAMIyCRMBwBEAQAsAAQKfxoAAgYABgjYF+ghAJoBAAYABgjYF+ghAJoBAAAA.安奇翋:BAACLAAFFH9OAAIBAAgIZSVnAABhAwABAAgIZSVnAABhAwAsAAQKfzoAAgEACAgDIuoVALsCAAEACAgDIuoVALsCAAAA.',['寂灭']='寂灭的往生:BAAALAAFFAIIAgAAAA==.',['密码']='密码六个八:BAAALAAECgYIBgAAAA==.',['寒春']='寒春的澜珊:BAAALAAFFAIIAgAAAA==.',['射手']='射手小小琴:BAABLAAFFH8WAAMEAAYI1BxdQgA/AQAEAAUIzR1dQgA/AQAFAAQImxfoFADAAAAAAA==.',['射爆']='射爆:BAAALAADCgIIAgAAAA==.',['小不']='小不点阿巴:BAAALAAECgYICAAAAA==.',['小奶']='小奶茉:BAAALAAFFAIIAgAAAA==.',['小小']='小小战:BAABLAAFFH8IAAILAAgI4QAdZgATAAALAAgI4QAdZgATAAAAAA==.小小舞深:BAAALAAECgYIDAAAAA==.小小龙人:BAAALAAECgMIAwAAAA==.',['小布']='小布尔乔亚丶:BAACLAAFFH8GAAIOAAUIGA98MgDvAAAOAAUIGA98MgDvAAAsAAQKfx8AAg4ACAhnI/8QADYDAA4ACAhnI/8QADYDAAAA.',['小海']='小海豹丶:BAAALAAECgYIEgAAAA==.',['小狗']='小狗急了:BAAALAAECggIDgAAAA==.',['小美']='小美:BAAALAAFFAIIAgAAAA==.',['小肚']='小肚皮:BAABLAAFFH8GAAMLAAMIbQYaPwBmAAAMAAIIQgiFKABtAAALAAMIjwMaPwBmAAAAAA==.',['小问']='小问号的朋友:BAAALAAECgYIBgAAAA==.',['小魚']='小魚尾巴:BAAALAAECgYIBwAAAA==.',['尕崔']='尕崔:BAAALAAECgYICgAAAA==.',['山里']='山里灵活的狗:BAAALAAECgYIBgAAAA==.',['差一']='差一骑:BAAALAAECgIIBAAAAA==.',['布懒']='布懒妮:BAAALAAECgYICwAAAA==.',['布朗']='布朗熊:BAABLAAFFH8GAAIDAAIIFAaFZgA5AAADAAIIFAaFZgA5AAAAAA==.',['幽幽']='幽幽白薯:BAAALAAECgQIBAAAAA==.',['归来']='归来的梦:BAAALAAECgMIBQAAAA==.归来的阿荣:BAAALAAFFAIIAgAAAA==.',['往雨']='往雨:BAAALAAFFAIIBAAAAA==.',['微笑']='微笑的特瑞纱:BAAALAADCggICAAAAA==.',['德鹿']='德鹿梦鱼:BAAALAAFFAgIBAAAAA==.',['忒玛']='忒玛德威什玛:BAAALAAECgQIBAAAAA==.',['忧伤']='忧伤做:BAABLAAFFH8IAAIIAAMI4hmrIwACAQAIAAMI4hmrIwACAQAAAA==.',['思菲']='思菲雅:BAAALAAECgIIBAAAAA==.',['怪不']='怪不理偶:BAACLAAFFH8OAAIKAAMIXBVmKgDvAAAKAAMIXBVmKgDvAAAsAAQKfywAAgoACAi0InUeAPYCAAoACAi0InUeAPYCAAAA.',['我本']='我本善良:BAAALAADCgQIBAAAAA==.',['我讲']='我讲武德:BAAALAADCgYIAQAAAA==.',['打擦']='打擦有福利气:BAACLAAFFH8fAAMPAAUIzxNyGgDhAAAPAAUIzxNyGgDhAAAeAAMIiQr7NwB7AAAsAAQKfy8AAw8ACAgxH54mAHcCAA8ABwjCIJ4mAHcCAB4AAwgaGFtNANsAAAAA.',['抓宝']='抓宝宝:BAABLAAECn8XAAIEAAYIKxniaABxAQAEAAYIKxniaABxAQAAAA==.',['抢了']='抢了貔貅的盾:BAAALAADCgEIAQAAAA==.',['抽不']='抽不死你棒槌:BAAALAAECgEIAQAAAA==.',['拉得']='拉得玩死卡:BAAALAAECgIIAgAAAA==.',['拉文']='拉文凯斯:BAAALAAECggICAAAAA==.',['拉露']='拉露恩:BAAALAAECgQIBAAAAA==.',['按箭']='按箭伤人:BAAALAAECgYIDAAAAA==.',['捉个']='捉个宠物:BAAALAADCgYIBgAAAA==.',['捌零']='捌零壹:BAAALAAECgYIBgAAAA==.',['捞捞']='捞捞居:BAAALAAECgUIBQAAAA==.',['提拉']='提拉加德:BAAALAADCggIDAAAAA==.',['提高']='提高实力:BAAALAAECgYIDAAAAA==.',['撤满']='撤满:BAAALAAECgIIAgAAAA==.',['擒兽']='擒兽达人:BAAALAADCgMIAwAAAA==.',['教练']='教练我行吗:BAABLAAFFH8HAAIVAAIIFRn3PACjAAAVAAIIFRn3PACjAAAAAA==.',['数值']='数值的美:BAAALAADCggICAAAAA==.',['斯蒂']='斯蒂芬马布里:BAABLAAFFH8JAAIIAAgIdhQIDgAmAgAIAAgIdhQIDgAmAgAAAA==.',['新海']='新海诚:BAAALAADCgYIBgAAAA==.',['无敌']='无敌重生:BAAALAAECgYIBgAAAA==.',['无锋']='无锋:BAAALAAFFAIIBAAAAA==.',['时间']='时间之王:BAAALAAECgQIBAAAAA==.',['明月']='明月下西楼:BAAALAADCgUIBQAAAA==.',['星天']='星天外:BAAALAAECgIIAgAAAA==.',['星梦']='星梦无痕:BAACLAAFFH8TAAIBAAMIVxSwKgDTAAABAAMIVxSwKgDTAAAsAAQKfxYAAgEABwiRGlgWABMCAAEABwiRGlgWABMCAAAA.',['星空']='星空嘟嘟:BAAALAAECgUIBQAAAA==.星空梦境:BAAALAAECgQIBAAAAA==.',['星辰']='星辰小德:BAAALAAECgUIDAAAAA==.',['是妮']='是妮蔻呀丿:BAABLAAECn8UAAIKAAYIrw7k+gBLAQAKAAYIrw7k+gBLAQAAAA==.',['昱洋']='昱洋:BAABLAAFFH8FAAIfAAIICBIlFwCiAAAfAAIICBIlFwCiAAAAAA==.',['晚上']='晚上吃点啥:BAAALAAECgYIBgAAAA==.',['智妞']='智妞妞:BAAALAAECgYICAAAAA==.',['暗夜']='暗夜天心:BAAALAADCgEIAQAAAA==.',['暗影']='暗影阿巴:BAAALAAECgYICgAAAA==.',['月之']='月之影影之海:BAABLAAFFH8OAAIgAAIIKgr9DgAoAAAgAAIIKgr9DgAoAAAAAA==.月之海:BAABLAAFFH8LAAIhAAMI5xAlBgCRAAAhAAMI5xAlBgCRAAAAAA==.',['月梦']='月梦墨瞳:BAAALAAECgQIBAAAAA==.',['月痕']='月痕星语:BAAALAAECgIIAgAAAA==.',['月神']='月神之恋:BAAALAAFFAIIAgAAAA==.',['有点']='有点儿小鸡冻:BAABLAAFFH8RAAQhAAYInySrAgCXAQAVAAYI5CM8EQDvAQAhAAYIUxirAgCXAQAiAAUITxp/BgBLAQAAAA==.',['朝花']='朝花夕露:BAAALAAECgYICQAAAA==.',['木与']='木与琛:BAAALAAFFAIIAgAAAA==.',['朱比']='朱比的红叶:BAABLAAFFH8GAAMiAAIIThyPEABbAAAiAAIIThyPEABbAAAVAAEIkQeEYAA7AAAAAA==.',['杀死']='杀死知更鸟:BAAALAADCggIDwAAAA==.',['杜维']='杜维:BAABLAAECn8dAAIeAAcIAAe1SwDhAAAeAAcIAAe1SwDhAAAAAA==.',['林寂']='林寂云:BAABLAAFFH8MAAQjAAYIjQXNCAC2AAAjAAQIdwbNCAC2AAAkAAYIMgIyIQCvAAAaAAIIygIQSQBSAAAAAA==.林寂灭:BAAALAAFFAIIBAAAAA==.',['格瑞']='格瑞司华尔德:BAAALAAECgYIBgAAAA==.',['梅狸']='梅狸猫:BAABLAAFFH8SAAIeAAUIpBhNIQA2AQAeAAUIpBhNIQA2AQAAAA==.',['梦里']='梦里花:BAAALAAECgUIBQAAAA==.',['棒棒']='棒棒冰:BAAALAAECgIIAgAAAA==.',['欧尼']='欧尼坦:BAAALAAFFAYIAgAAAA==.',['止战']='止战之殤:BAAALAAECgEIAQAAAA==.',['止水']='止水丶:BAABLAAFFH8JAAMPAAYIlQ1WJwAoAQAPAAYIlQ1WJwAoAQAeAAMICBtiFQAMAQAAAA==.',['死亡']='死亡进行时:BAAALAAECgIIAgAAAA==.',['残月']='残月脦凄美:BAAALAADCgQIBAAAAA==.',['毒鬼']='毒鬼:BAACLAAFFH8cAAILAAUIEA7TKQAeAQALAAUIEA7TKQAeAQAsAAQKfx4AAwsABgjlFws/AF4BAAsABgjlFws/AF4BACUAAQgQEas4AEMAAAAA.',['水月']='水月天天:BAAALAAFFAIIBAAAAA==.',['永远']='永远永远:BAABLAAFFH8GAAIKAAIItBW6aQCTAAAKAAIItBW6aQCTAAAAAA==.',['氼甙']='氼甙骞:BAABLAAFFH8NAAIYAAUIoRj4CQBDAQAYAAUIoRj4CQBDAQAAAA==.',['汪星']='汪星人的逆袭:BAABLAAFFH8GAAIIAAYIOQINRwCmAAAIAAYIOQINRwCmAAAAAA==.',['汹涌']='汹涌狂暴的眼:BAAALAAECggICAAAAA==.',['沃顿']='沃顿七号:BAABLAAFFH8GAAICAAYIbQ9OEABhAQACAAYIbQ9OEABhAQAAAA==.沃顿八号:BAABLAAFFH8GAAICAAYI6gmaCADIAQACAAYI6gmaCADIAQAAAA==.',['沐岚']='沐岚:BAAALAAECgcICQAAAA==.',['没岚']='没岚:BAAALAAECgQIBgAAAA==.',['法兰']='法兰地:BAAALAAECgQIBAAAAA==.',['波比']='波比娃娃:BAAALAAECgQIBAAAAA==.',['泰德']='泰德利斯:BAAALAAECgYIBgAAAA==.',['洛冰']='洛冰盈:BAABLAAFFH8NAAMPAAUIfwJ1cwBFAAAPAAIIqgV1cwBFAAAeAAQIewAaVwADAAAAAA==.',['流年']='流年小伍:BAAALAAECgYIDAAAAA==.',['浊心']='浊心斯卡蒂:BAAALAAFFAIIAgAAAA==.',['海深']='海深时浅:BAABLAAFFH8QAAIIAAUIpRJyNwAwAQAIAAUIpRJyNwAwAQAAAA==.',['淘米']='淘米鱼宝宝:BAAALAAECgcIBwAAAA==.',['混沌']='混沌之后:BAAALAAECgYIDAAAAA==.',['淺倉']='淺倉南:BAAALAADCggICwAAAA==.',['清角']='清角吹寒:BAABLAAFFH8MAAIRAAMIaR7ODQCmAAARAAMIaR7ODQCmAAAAAA==.',['温溪']='温溪啊猎:BAAALAAECgYIDgAAAA==.',['湄岚']='湄岚:BAAALAAECgYIDQAAAA==.',['潇岚']='潇岚:BAAALAAECgMIAwAAAA==.',['潇风']='潇风:BAAALAAECgYIBgAAAA==.',['潘岚']='潘岚:BAAALAAECgYICwAAAA==.',['澔岚']='澔岚:BAAALAAECgYIDQAAAA==.',['灬忆']='灬忆学时:BAABLAAFFH8TAAIHAAYIThDzAgBfAQAHAAYIThDzAgBfAQAAAA==.',['灬澄']='灬澄灬:BAAALAAECgQIBAAAAA==.',['灰姑']='灰姑娘彡:BAAALAAECgYIBgAAAA==.',['烟雨']='烟雨故人归:BAAALAAECgYIBwAAAA==.',['焚情']='焚情:BAAALAAECgMIAwAAAA==.',['無念']='無念星空:BAAALAAECgQICAAAAA==.',['無憂']='無憂:BAABLAAECn8cAAMMAAgIBAlkZwDtAAALAAgI0wWjvQABAQAMAAYIpAlkZwDtAAAAAA==.',['無毀']='無毀的湖光:BAAALAAECgYIDQAAAA==.',['無邪']='無邪星空:BAAALAAECgYIDAAAAA==.',['爱忽']='爱忽悠:BAAALAAFFAIIAgAAAA==.',['爱情']='爱情阿产:BAAALAAECgYIBgAAAA==.',['牧飞']='牧飞瑶:BAABLAAFFH8IAAIbAAMIfAQzBgBUAAAbAAMIfAQzBgBUAAAAAA==.',['特别']='特别会隐遁:BAAALAADCgYIBgAAAA==.特别想救你:BAAALAAFFAIIAgAAAA==.',['狐人']='狐人:BAAALAAFFAIIAgAAAA==.',['狼牙']='狼牙土豆:BAAALAAECgUIBgAAAA==.',['猪八']='猪八戒踢皮球:BAAALAAECgYIBgAAAA==.',['玄隆']='玄隆隆:BAABLAAECn8eAAMUAAcISBNwEQA6AQAUAAcISBNwEQA6AQAcAAUIRA23KACUAAAAAA==.',['珈特']='珈特琳:BAAALAAECgUIBQAAAA==.',['球霸']='球霸天:BAAALAADCgMIAwAAAA==.',['瓶在']='瓶在人在:BAAALAADCgEIAQAAAA==.',['生命']='生命之王:BAAALAAECgYIBwABLAAECgcIHgAUAEgTAA==.生命有價:BAACLAAFFH8oAAMIAAYI9SA/JQCFAQAIAAUIFSI/JQCFAQAJAAEIWRuqBgBbAAAsAAQKfxQAAggABwgNI70gAMoCAAgABwgNI70gAMoCAAAA.',['男巫']='男巫师:BAAALAAECggIEgAAAA==.',['疆场']='疆场浮浪:BAAALAADCggICQAAAA==.',['瘋狂']='瘋狂鑽石:BAAALAAECgYIBgAAAA==.',['白了']='白了兔提莫:BAAALAAECggICAAAAA==.',['白头']='白头佬:BAAALAADCggICAAAAA==.',['百步']='百步穿牛:BAAALAAECgYIDAAAAA==.',['百花']='百花凌风:BAAALAAFFAIIBAAAAA==.百花哲芷:BAACLAAFFH8kAAIEAAYIrRZ8IAAFAQAEAAYIrRZ8IAAFAQAsAAQKfxQAAwQACAjPHyM7AHQCAAQACAjPHyM7AHQCAAUAAghlFcqiAG4AAAAA.百花妖月:BAAALAAECgQIBgAAAA==.百花小萨:BAAALAAECgYIBgAAAA==.',['盗梦']='盗梦局士:BAAALAAECgYICAAAAA==.',['真水']='真水:BAAALAAECgYICQAAAA==.',['真的']='真的奶妈:BAAALAAECgUIDAAAAA==.',['瞬影']='瞬影剑:BAAALAADCgcIBwAAAA==.',['砍得']='砍得飞起:BAAALAAECgYIBgAAAA==.',['磁暴']='磁暴步兵丶沂:BAAALAAECgMIAwAAAA==.',['祈爱']='祈爱漫无天际:BAABLAAFFH8GAAIOAAIILx14MwCoAAAOAAIILx14MwCoAAAAAA==.',['神之']='神之子:BAAALAADCgEIAQAAAA==.',['神聖']='神聖骑士:BAAALAAECgQIBAAAAA==.',['禅亚']='禅亚塔:BAAALAAFFAIIAgAAAA==.',['离秋']='离秋的薪火:BAAALAAECggICAAAAA==.',['秋月']='秋月的私语:BAAALAADCgQIBAAAAA==.',['科比']='科比怖莱恩特:BAABLAAFFH8HAAIIAAUIyxLIOgAdAQAIAAUIyxLIOgAdAQAAAA==.',['穆拉']='穆拉嵿红须:BAAALAAECggICAAAAA==.',['穆诗']='穆诗:BAAALAAECgcIBwAAAA==.',['筱筱']='筱筱芯:BAAALAAECgMIAwAAAA==.',['箜箜']='箜箜小喃:BAABLAAFFH8QAAIaAAUIbQxDIgALAQAaAAUIbQxDIgALAQAAAA==.',['篠之']='篠之之帚:BAAALAAFFAIIAgAAAA==.',['米诺']='米诺菲:BAAALAAECgUIBQABLAAFFAUIEwAOADcfAA==.',['粉色']='粉色别点:BAABLAAFFH8yAAMKAAcI3iHvCgBMAgAKAAcI3iHvCgBMAgAdAAIIXA/DEwCKAAAAAA==.',['糖豆']='糖豆穿肠:BAAALAAECggICAAAAA==.',['糯米']='糯米团:BAACLAAFFH8NAAIOAAIIXhVpWwBJAAAOAAIIXhVpWwBJAAAsAAQKfyEAAg4ABggsIPA2ALkBAA4ABggsIPA2ALkBAAAA.',['紅紅']='紅紅火火恍惚:BAAALAAECgQIBAAAAA==.',['索科']='索科洛芙:BAAALAAECgIIAgAAAA==.',['紫薯']='紫薯蛋卷:BAAALAAECgYIBgAAAA==.',['緋色']='緋色碎片:BAAALAAECgQICgAAAA==.',['绝影']='绝影:BAABLAAFFH8mAAIDAAgIeR3EBACZAgADAAgIeR3EBACZAgAAAA==.',['绫波']='绫波丽:BAACLAAFFH8MAAIVAAMIxhklKQDvAAAVAAMIxhklKQDvAAAsAAQKfxwAAhUABwj/I9ApAKUCABUABwj/I9ApAKUCAAAA.',['绿色']='绿色火焰:BAAALAADCgMIAwAAAA==.',['缺德']='缺德的找我:BAACLAAFFH8RAAMaAAMIHRLbNACWAAAaAAMIHRLbNACWAAAkAAIIqAZqNgA5AAAsAAQKfxQAAyQABwh5HcIjAEgCACQABgjAIcIjAEgCABoAAgj2DJjWAFMAAAAA.',['美女']='美女祭司:BAAALAAECgYIDAAAAA==.',['美雨']='美雨:BAABLAAECn8UAAIEAAYIkRbsvgCBAQAEAAYIkRbsvgCBAQAAAA==.',['羽蛇']='羽蛇神:BAACLAAFFH8KAAIPAAIIhRlDSQCLAAAPAAIIhRlDSQCLAAAsAAQKfxgAAg8ABghrGHNHADwBAA8ABghrGHNHADwBAAAA.',['老乄']='老乄枪:BAAALAADCgIIAwAAAA==.',['老渣']='老渣男:BAAALAAECgUIBwAAAA==.',['联人']='联人圣:BAAALAAECgYIDAAAAA==.',['聖光']='聖光与汝同在:BAAALAAECgEIAQAAAA==.',['肥肥']='肥肥师兄:BAACLAAFFH8QAAIGAAIIGgmaFwBgAAAGAAIIGgmaFwBgAAAsAAQKf0wAAgYACAhAEWMRAI0BAAYACAhAEWMRAI0BAAAA.',['背叛']='背叛:BAAALAAFFAYIBAAAAA==.',['胖成']='胖成球的猫:BAAALAAECgEIAQAAAA==.',['胖达']='胖达饿了:BAAALAAECgYIDAAAAA==.',['胡图']='胡图图丨图腾:BAAALAAECgYICwAAAA==.胡图图丨射击:BAAALAAECgEIAQAAAA==.胡图图丨無敵:BAAALAAECgYIBgAAAA==.胡图图丨翻滚:BAAALAAECgYIBgAAAA==.',['脑袋']='脑袋尖尖的:BAAALAAFFAIIBAAAAA==.',['腐草']='腐草为萤丶:BAACLAAFFH8KAAMFAAIIaxH2JgB6AAAFAAIIRQ72JgB6AAAEAAEIqxTnhgBIAAAsAAQKfycABAUACAgyGzgoADICAAUACAhKGTgoADICAAQABQjNFoX1ADwBACYAAwiCEZYcAMIAAAAA.',['自闭']='自闭圣骑:BAAALAAECgUIBQAAAA==.',['艾尔']='艾尔斯岚:BAAALAAECgIIAgAAAA==.',['艾熙']='艾熙:BAACLAAFFH8oAAIEAAYIPSVxDQAeAgAEAAYIPSVxDQAeAgAsAAQKfxUAAgQABgjII5E9ANMBAAQABgjII5E9ANMBAAAA.',['艾露']='艾露嗯:BAAALAAECgYIBgAAAA==.',['芝士']='芝士滑鸡:BAAALAAFFAIIAgAAAA==.',['花中']='花中偏爱菊:BAABLAAFFH8KAAIKAAIIQB2TgQBFAAAKAAIIQB2TgQBFAAAAAA==.',['花想']='花想容:BAAALAAECgMIBAAAAA==.',['苏定']='苏定方:BAAALAAECgEIAQAAAA==.',['茶叶']='茶叶蛋:BAABLAAFFH8GAAIPAAIImhNXWgBmAAAPAAIImhNXWgBmAAAAAA==.',['草莓']='草莓蛋糕:BAABLAAFFH8JAAIeAAIIiBCFQgBGAAAeAAIIiBCFQgBGAAAAAA==.',['荔枝']='荔枝桂圆:BAABLAAECn8vAAIEAAYIuBR6ogAWAQAEAAYIuBR6ogAWAQAAAA==.',['莫小']='莫小言:BAAALAADCgMIAwAAAA==.',['菌王']='菌王锅:BAABLAAFFH8GAAIZAAYIeRHGEAA+AQAZAAYIeRHGEAA+AQAAAA==.',['萨格']='萨格顶顶:BAABLAAECn8jAAMeAAYIeBZzNgA1AQAeAAYIeBZzNgA1AQAPAAYI9RFEXQDuAAAAAA==.',['萨萨']='萨萨耶:BAAALAAECgQIBAAAAA==.',['葉無']='葉無風:BAACLAAFFH8LAAIEAAMIOxdpZQChAAAEAAMIOxdpZQChAAAsAAQKfxQAAwQACAgfGnxpAAgCAAQACAgfGnxpAAgCAAUAAQjYAzLTABgAAAAA.',['蒙奇']='蒙奇:BAAALAADCgEIAQAAAA==.',['蓝宝']='蓝宝石:BAABLAAFFH8MAAIVAAYIORhgIQAdAQAVAAYIORhgIQAdAQAAAA==.',['蔡蔡']='蔡蔡:BAAALAAECgIIAgAAAA==.',['虚假']='虚假圣光:BAAALAAECggIEAAAAA==.',['血色']='血色十一公主:BAAALAADCgYIBgAAAA==.',['补天']='补天石:BAAALAAFFAIIAgAAAA==.',['西伯']='西伯利亚黛玉:BAAALAAECgMIAQAAAA==.',['西露']='西露芙:BAAALAADCgYIBgAAAA==.',['请把']='请把我放盐里:BAAALAAECgYIDQAAAA==.',['谎言']='谎言显得可怜:BAAALAAFFAIIAgAAAA==.',['谦卑']='谦卑的糖门滚:BAAALAAECgUIBQAAAA==.',['豚豚']='豚豚:BAAALAAECgMIAwAAAA==.',['貔貅']='貔貅举起了盾:BAABLAAFFH8eAAMMAAYIUxyKCgCXAQAMAAYIUxyKCgCXAQALAAMIBhTWQgBRAAAAAA==.',['贝吉']='贝吉达:BAAALAADCgEIAQAAAA==.',['贵阳']='贵阳吴彦祖:BAAALAAFFAEIAQAAAA==.贵阳彭于晏:BAABLAAECn8lAAMWAAgIwhOLGwDiAQAWAAgIwhOLGwDiAQADAAQIBA0xiACUAAAAAA==.贵阳郭富城:BAAALAAECgUIBQAAAA==.',['贺走']='贺走走:BAAALAAECgUICgAAAA==.',['贺跑']='贺跑跑:BAAALAADCgMIAwAAAA==.',['赖赖']='赖赖救我:BAAALAAFFAIIAgAAAA==.',['超人']='超人哑哑:BAAALAADCggICAAAAA==.',['超雄']='超雄哈吉帅:BAACLAAFFH8GAAIMAAIIPCCaEQDBAAAMAAIIPCCaEQDBAAAsAAQKfxYABAwABwjvHjUmAAsCAAwABgi0HjUmAAsCACUABAjTHC8dADEBAAsABAgjHa5YAAsBAAAA.',['轨迹']='轨迹丨:BAACLAAFFH8SAAILAAII6SQzKQCnAAALAAII6SQzKQCnAAAsAAQKfzUAAgsACAjlI2UfAM4CAAsACAjlI2UfAM4CAAAA.',['辛弗']='辛弗尼尔:BAABLAAECn8mAAMCAAgIFhEFQwCtAQACAAgIFhEFQwCtAQAbAAYIiQoMHgAAAQAAAA==.',['还来']='还来就菊花:BAABLAAFFH8MAAMnAAII2gjoFwA3AAAfAAII2giHHQBBAAAnAAIIFgToFwA3AAAAAA==.',['迪力']='迪力木拉提:BAABLAAFFH8NAAIEAAcICxbHFQDkAQAEAAcICxbHFQDkAQAAAA==.',['道法']='道法自归来:BAAALAAECgUIBQAAAA==.',['邪恶']='邪恶小法:BAAALAADCgUIBQAAAA==.',['邪火']='邪火:BAAALAAECgIIAgAAAA==.',['邪灵']='邪灵猎手:BAAALAAECggIDgAAAA==.',['郁闷']='郁闷啊:BAAALAAECgYIBgAAAA==.',['郎情']='郎情妾意:BAAALAAECgYIBgAAAA==.',['醉九']='醉九生:BAAALAAECgUIBQAAAA==.',['醉语']='醉语嫣然:BAAALAAECgUIBQAAAA==.',['量子']='量子隧穿:BAABLAAECn8eAAMUAAgI9hnQDABjAgAUAAgI9hnQDABjAgAcAAUIcxb9PABUAQAAAA==.',['鎖骨']='鎖骨:BAABLAAFFH8GAAIKAAII+xRQfQBHAAAKAAII+xRQfQBHAAABLAAFFAYIDAAIAAwQAA==.',['铃子']='铃子:BAAALAAECgMIAwAAAA==.',['镜流']='镜流:BAAALAAECgYIBgAAAA==.',['长夜']='长夜咏叹调:BAAALAAECgYICwAAAA==.',['闯王']='闯王丶:BAABLAAFFH8LAAMEAAMIvRYLKADcAAAEAAMIvRYLKADcAAAFAAMI5gYKGQCnAAAAAA==.',['闷不']='闷不了就跑:BAAALAAECgQIBAAAAA==.',['阿什']='阿什米达:BAAALAAECgUIBwAAAA==.',['阿伦']='阿伦艾弗森:BAABLAAFFH8QAAIIAAgIaR2sBwCCAgAIAAgIaR2sBwCCAgAAAA==.',['阿尔']='阿尔娜斯:BAAALAAECggICAAAAA==.',['阿瑾']='阿瑾:BAAALAAECgYIDAAAAA==.',['阿睿']='阿睿:BAAALAAECgYIBgAAAA==.',['阿维']='阿维娜丶绒爪:BAABLAAFFH8MAAMaAAMI5xp/EwDaAAAaAAMI5xp/EwDaAAAkAAMI0g2CEgDYAAAAAA==.',['阿诺']='阿诺德:BAACLAAFFH8KAAIEAAIIOAXShABOAAAEAAIIOAXShABOAAAsAAQKfx0AAwQABgiaEP+yAAABAAQABggTEP+yAAABAAUABgjoCdV6AOwAAAAA.',['陈行']='陈行甲:BAAALAADCggICAAAAA==.',['随风']='随风潜入夜丶:BAAALAADCggICAAAAA==.',['隐者']='隐者嘉德丽雅:BAABLAAECn8UAAIHAAcIlBHSLgC0AQAHAAcIlBHSLgC0AQAAAA==.',['雅拉']='雅拉香布:BAAALAAFFAIIBAAAAA==.',['雅若']='雅若诗画:BAAALAAECgEIAQAAAA==.',['雕牌']='雕牌超能皂:BAAALAAECgYIBgAAAA==.',['雨下']='雨下一整晚:BAAALAAECggIAwAAAA==.',['雨山']='雨山前:BAAALAAFFAIIAgAAAA==.',['雪冰']='雪冰儿:BAACLAAFFH8GAAIBAAIIPQ6wPgBtAAABAAIIPQ6wPgBtAAAsAAQKfxkAAgEACAiHEu8+AN0BAAEACAiHEu8+AN0BAAAA.',['雷希']='雷希拉姆:BAAALAAECgUIBgAAAA==.',['雷阿']='雷阿伦:BAABLAAFFH8IAAIIAAYIeBl6HQCpAQAIAAYIeBl6HQCpAQAAAA==.',['雾岛']='雾岛董香:BAABLAAFFH8SAAIZAAMIByUvCQBIAQAZAAMIByUvCQBIAQAAAA==.',['霓夜']='霓夜椰:BAACLAAFFH8GAAIEAAMImRxmZgCcAAAEAAMImRxmZgCcAAAsAAQKfxoAAgQABgiHIjg1AOsBAAQABgiHIjg1AOsBAAAA.',['霸气']='霸气的南岸:BAABLAAFFH8LAAMLAAMIMhSGKwCkAAALAAMIMhSGKwCkAAAMAAEIfhL0PAAAAAAAAA==.',['面包']='面包嘟嘟:BAAALAAFFAIIAgAAAA==.',['韩非']='韩非子:BAABLAAFFH8NAAIaAAYIABgjHwApAQAaAAYIABgjHwApAQAAAA==.',['风之']='风之极:BAAALAAFFAIIAgAAAA==.',['风吟']='风吟铃:BAAALAAECgMIAwAAAA==.',['风翼']='风翼:BAABLAAFFH8SAAMVAAYInSHKBABaAgAVAAYInSHKBABaAgAhAAEI3xQSCgBUAAAAAA==.',['风萨']='风萨:BAABLAAFFH8GAAMPAAIIKQsFaABTAAAPAAIIKQsFaABTAAAeAAEIGQbfVwAAAAAAAA==.',['飞狐']='飞狐:BAAALAAECgMIBgAAAA==.',['飞羽']='飞羽归尘:BAACLAAFFH8KAAIEAAMI2QpreQBpAAAEAAMI2QpreQBpAAAsAAQKfxUAAwUABwh6F2BFAKABAAQABggkGNqdAK8BAAUABwgYFGBFAKABAAAA.',['马库']='马库斯坎比:BAABLAAFFH8KAAIIAAcIriAbEQAHAgAIAAcIriAbEQAHAgABLAAFFAgIEAAIAGkdAA==.',['骑马']='骑马天涯:BAAALAAECgEIAQAAAA==.',['高高']='高高瘦瘦:BAAALAAECgMIAwAAAA==.',['魅魔']='魅魔苏然:BAAALAAFFAMIAwAAAA==.',['魔法']='魔法之王:BAABLAAECn8WAAIVAAYI2QlpRwDsAAAVAAYI2QlpRwDsAAAAAA==.魔法厨师:BAAALAAECgYIDQAAAA==.',['魔界']='魔界客:BAAALAAECgYIAgAAAA==.',['鱼虾']='鱼虾一整碗:BAAALAAFFAQIAwAAAA==.',['鲜血']='鲜血扛把子:BAACLAAFFH8YAAIKAAYIbRvGIwClAQAKAAYIbRvGIwClAQAsAAQKfxYAAgoACAg1IccpAM4BAAoACAg1IccpAM4BAAAA.',['鲨鱼']='鲨鱼王:BAABLAAFFH8OAAIKAAYINhvCLgB/AQAKAAYINhvCLgB/AQAAAA==.',['鲨鳗']='鲨鳗:BAAALAAECgcIBwAAAA==.',['鸡汁']='鸡汁回卤干:BAAALAAFFAEIAQAAAA==.',['麟阁']='麟阁:BAACLAAFFH8MAAIDAAIIQQu/ZAA7AAADAAIIQQu/ZAA7AAAsAAQKfx4AAgMABwhYF285AHQBAAMABwhYF285AHQBAAAA.',['麦戈']='麦戈文:BAAALAAECggICAABLAAFFAgIAgANAAAAAA==.',['黑暗']='黑暗咆哮:BAAALAAECgYIDAAAAA==.',['黑色']='黑色闪电:BAAALAAFFAIIAgAAAA==.',['鼓鼓']='鼓鼓气鼓鼓:BAAALAAECgUIBQAAAA==.',['齐天']='齐天大圣:BAAALAAECgYIDAAAAA==.齐天大蠊:BAAALAAECgYIBwAAAA==.',['龙翱']='龙翱天:BAAALAAECgYIDAAAAA==.',['龙菲']='龙菲雨:BAAALAAECgMIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end