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
 local lookup = {'Priest-Holy','Shaman-Restoration','DemonHunter-Havoc','DemonHunter-Vengeance','Shaman-Elemental','Evoker-Preservation','Mage-Frost','Mage-Arcane','Druid-Restoration','Druid-Balance','Warrior-Fury','Paladin-Retribution','Hunter-BeastMastery','Warrior-Protection','Warlock-Demonology','Paladin-Holy','DeathKnight-Frost','Paladin-Protection','DeathKnight-Unholy','Druid-Guardian','Druid-Feral','Warlock-Destruction','Hunter-Marksmanship','Rogue-Assassination','Rogue-Subtlety','Monk-Windwalker','Monk-Brewmaster','Priest-Shadow','DeathKnight-Blood','Hunter-Survival','Mage-Fire','Evoker-Devastation','Warlock-Affliction',}; local provider = {region='CN',realm='布鲁塔卢斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Af='Afterglow:BAABLAAFFH8UAAIBAAUIzxprGgB8AQABAAUIzxprGgB8AQABLAAFFAYIOwACAFckAA==.',Al='Alanpriest:BAABLAAECn8VAAICAAgITSB/HAClAgACAAgITSB/HAClAgAAAA==.',Bi='Bigsprite:BAACLAAFFH8iAAIDAAYI3hQ3EgCAAQADAAYI3hQ3EgCAAQAsAAQKfyIAAwMACAiCHOk4AHsCAAMACAiCHOk4AHsCAAQAAgj7EE9aAGIAAAAA.',Br='Bravemonster:BAAALAADCgMIAwAAAA==.',Ch='Changesbhy:BAAALAAECgYIBgAAAA==.',Cl='Cloud:BAAALAAFFAIIAgAAAA==.',Co='Cool:BAAALAAECgcIBwAAAA==.',Cr='Crazyhunterm:BAAALAADCgYIBgAAAA==.',Da='Darkanglell:BAAALAAECgYICAAAAA==.',De='Determine:BAACLAAFFH87AAICAAYIVyQHBgBhAgACAAYIVyQHBgBhAgAsAAQKfyYAAwIACAghI+4KAAwDAAIACAghI+4KAAwDAAUABAhRD9ybAOkAAAAA.',Dm='Dmsm:BAABLAAFFH8mAAIFAAYImhknDQCuAQAFAAYImhknDQCuAQAAAA==.',Dr='Drunk:BAAALAAECgYIBgAAAA==.',Es='Esse:BAAALAAECgUIBQAAAA==.',Fe='Featmellow:BAAALAAECgYICQAAAA==.',Fr='Francesca:BAABLAAECn8aAAIGAAgIaBDLGQCvAQAGAAgIaBDLGQCvAQABLAAFFAYIOwACAFckAA==.',Gl='Glacia:BAABLAAFFH8MAAMHAAIIFCITCADHAAAHAAIIFCITCADHAAAIAAII8hTOVwBDAAAAAA==.',Ha='Harbinger:BAACLAAFFH8bAAMJAAYIUiIgBgBNAgAJAAYIUiIgBgBNAgAKAAMI3AUbKgBkAAAsAAQKfxcAAgkABgjmGskkALABAAkABgjmGskkALABAAEsAAUUBgg7AAIAVyQA.',Im='Immature:BAAALAADCgEIAQAAAA==.',Ki='Kidd:BAABLAAFFH8GAAILAAII4wwGVABBAAALAAII4wwGVABBAAAAAA==.Kitoli:BAABLAAFFH8FAAIMAAIIGBr4MQCpAAAMAAIIGBr4MQCpAAAAAA==.',Ky='Kylinblack:BAACLAAFFH8GAAINAAYIehJ4PQBPAQANAAYIehJ4PQBPAQAsAAQKfyAAAg0ABwhQJDwpALMCAA0ABwhQJDwpALMCAAAA.',La='Lairtance:BAAALAAECgYICgAAAA==.',Le='Legendary:BAACLAAFFH8hAAICAAYI4hSIDQBnAQACAAYI4hSIDQBnAQAsAAQKfxYAAgIACAjvGrM5ADICAAIACAjvGrM5ADICAAEsAAUUCAgXAAUA1R4A.',Ma='Maxholloway:BAABLAAFFH8NAAMLAAMItBMpNwCWAAALAAMItBMpNwCWAAAOAAIIJgTaLgBbAAAAAA==.',Mi='Miraclelight:BAABLAAFFH8KAAIMAAIIJyGNJgC9AAAMAAIIJyGNJgC9AAAAAA==.',Ny='Nymph:BAAALAADCggICAAAAA==.',Op='Opo:BAAALAAECgYICgAAAA==.',Ox='Oxox:BAAALAAECgQIBAAAAA==.',Pu='Puggf:BAAALAADCgcIDQAAAA==.',Re='Remorse:BAABLAAFFH8FAAIDAAMIihTVOwCcAAADAAMIihTVOwCcAAAAAA==.',Ss='Ssr:BAAALAAECgMIAwAAAA==.',Vo='Volkanovski:BAABLAAFFH8XAAMCAAYI1RcyIABaAQACAAYI1RcyIABaAQAFAAUIbgkAAAAAAAAAAA==.',Wa='Wakka:BAAALAAFFAIIAgAAAA==.',Xr='Xrjiuinia:BAAALAAECgEIAQAAAA==.',Xx='Xxo:BAAALAADCggICAAAAA==.',Yo='Yorathtee:BAAALAAECgEIAQAAAA==.',['一曲']='一曲肝肠断:BAABLAAECn8gAAIDAAgIHxvzQABfAgADAAgIHxvzQABfAgAAAA==.',['一棵']='一棵槐:BAAALAAFFAIIAgAAAA==.',['一牧']='一牧了燃:BAAALAAECgUIBQAAAA==.',['一页']='一页書:BAAALAAECgcICAAAAA==.',['三好']='三好体育生:BAAALAADCgEIAQAAAA==.',['三花']='三花大喵:BAAALAAFFAIIAgAAAA==.',['不曾']='不曾背叛:BAAALAAFFAIIAgAAAA==.',['不死']='不死不休:BAAALAAFFAIIBAAAAA==.',['不灭']='不灭饕餮:BAABLAAFFH8IAAIPAAMIbBW+CACXAAAPAAMIbBW+CACXAAAAAA==.',['丛林']='丛林守护神:BAAALAAECgIIAgAAAA==.',['东方']='东方白:BAACLAAFFH8TAAIJAAQI7x/CGABqAQAJAAQI7x/CGABqAQAsAAQKfxcAAwkACAiaIUkMAPgCAAkACAiaIUkMAPgCAAoAAQipBtGvAC4AAAAA.',['东西']='东西比较大:BAAALAAECgYIDAAAAA==.',['丶上']='丶上善若水:BAABLAAFFH8IAAMQAAIIYAZPKwBfAAAQAAIIYAZPKwBfAAAMAAIIKBNEYQBFAAAAAA==.',['丶乱']='丶乱飞:BAAALAAECgUIBQAAAA==.',['丶心']='丶心若止水:BAABLAAFFH8JAAICAAII3ws4ZQBVAAACAAII3ws4ZQBVAAAAAA==.',['丶旧']='丶旧年的惆怅:BAABLAAFFH8FAAIHAAIITxcrFgBDAAAHAAIITxcrFgBDAAAAAA==.',['丶烟']='丶烟雨的绸缪:BAAALAAFFAIIAgAAAA==.',['丶碉']='丶碉堡小熊猫:BAAALAAECgYICwAAAA==.丶碉堡小肥牧:BAAALAAFFAIIBAAAAA==.丶碉堡小肥猎:BAAALAAFFAIIAgAAAA==.',['丶葡']='丶葡萄跳跳糖:BAAALAAECgYICQAAAA==.',['丷萌']='丷萌胖胖:BAABLAAFFH8MAAMCAAYIARJyLQD/AAACAAQIFBVyLQD/AAAFAAQIQw7ELQDJAAAAAA==.',['为了']='为了咸鱼:BAAALAAECgYIDQAAAA==.',['九月']='九月的玫瑰:BAAALAAECgIIAgAAAA==.九月的蜗牛:BAAALAADCggICAAAAA==.',['九条']='九条:BAAALAAFFAIIAgAAAA==.',['乾坤']='乾坤一技:BAAALAAECgYIEAAAAA==.',['二舅']='二舅妈:BAAALAAECgQICgAAAA==.',['五星']='五星好市民:BAAALAAFFAIIBAAAAA==.',['五门']='五门茜:BAACLAAFFH8KAAIIAAIILwx3WgBBAAAIAAIILwx3WgBBAAAsAAQKfxgAAggABwiWGtgaANIBAAgABwiWGtgaANIBAAAA.',['从前']='从前的黯然:BAAALAAECgYIDAAAAA==.',['伊莱']='伊莱克斯:BAAALAAECgYIBgAAAA==.',['传奇']='传奇耐揍王:BAAALAAECgEIAQAAAA==.',['依依']='依依不吃香菜:BAAALAAECgYIBgAAAA==.依依爱吃香菜:BAACLAAFFH8KAAIRAAMIxhsgKgDxAAARAAMIxhsgKgDxAAAsAAQKfxkAAhEACAj5HGJPAFoCABEACAj5HGJPAFoCAAAA.',['依壁']='依壁雕造:BAAALAAFFAIIAgAAAA==.',['信仰']='信仰图腾:BAAALAAFFAIIAgAAAA==.',['儒雅']='儒雅随和:BAAALAAECgcICwAAAA==.',['光阴']='光阴故事:BAAALAAECgYIBgAAAA==.',['克里']='克里斯之刃:BAACLAAFFH8GAAIMAAMIYRItRACHAAAMAAMIYRItRACHAAAsAAQKfxcAAgwABwgOH744ALQBAAwABwgOH744ALQBAAAA.',['兔兔']='兔兔丶:BAAALAADCgMIAwAAAA==.兔兔辣么阔爱:BAAALAAECgUIBQAAAA==.',['兔纸']='兔纸是只喵:BAAALAADCgYIBgAAAA==.',['六千']='六千里:BAABLAAFFH8GAAIDAAIIFBXUSwBNAAADAAIIFBXUSwBNAAAAAA==.',['内田']='内田真礼:BAAALAAECgUICAAAAA==.',['冒牌']='冒牌上帝:BAAALAAECgYIDQAAAA==.',['冭徦']='冭徦丶訫:BAAALAAECgYIDQAAAA==.',['冰与']='冰与火芝歌:BAAALAAECgYIBgAAAA==.',['冰檒']='冰檒戦神:BAACLAAFFH8yAAIOAAYIOAhVFwDzAAAOAAYIOAhVFwDzAAAsAAQKfxoAAg4ACAhDGDoUAKcBAA4ACAhDGDoUAKcBAAAA.冰檒玥影:BAABLAAFFH8ZAAISAAYISwoACwDzAAASAAYISwoACwDzAAAAAA==.',['凶神']='凶神恶煞的神:BAAALAAFFAIIAgAAAA==.',['初一']='初一:BAAALAAFFAIIAgAAAA==.',['初音']='初音:BAAALAAECgYIBgAAAA==.',['加滕']='加滕鹰:BAAALAAECgMIAwAAAA==.',['勇彤']='勇彤:BAAALAADCgQIBAAAAA==.',['北風']='北風丶:BAAALAAECgIIAgAAAA==.',['十一']='十一呀:BAAALAADCgYIBgAAAA==.',['十三']='十三:BAABLAAFFH8IAAIRAAIIcwyTdQCNAAARAAIIcwyTdQCNAAAAAA==.',['十九']='十九:BAAALAADCggICAAAAA==.',['十色']='十色煌:BAABLAAECn8XAAIJAAcIGhOgWACLAQAJAAcIGhOgWACLAQAAAA==.',['午夜']='午夜屠猪郎:BAAALAAECgUICgAAAA==.',['卩儬']='卩儬電灬攨攨:BAABLAAFFH8KAAISAAIIqAqrHwAsAAASAAIIqAqrHwAsAAAAAA==.',['卩厶']='卩厶侽灬紸角:BAABLAAFFH8OAAMLAAIIQw9KSgBJAAAOAAIIKwV+LABjAAALAAIIQw9KSgBJAAAAAA==.',['卩灬']='卩灬尐鱼丨:BAAALAADCgYICQAAAA==.',['卬灬']='卬灬明天:BAAALAAECgMIAwAAAA==.',['厉飞']='厉飞羽:BAAALAADCgUIBQAAAA==.',['去埃']='去埃及拔草:BAAALAAECgQIBAAAAA==.',['叛道']='叛道之飏颺:BAAALAAECgYIBgAAAA==.',['古飞']='古飞扬:BAAALAAFFAIIAgAAAA==.',['叫我']='叫我帅哥就好:BAAALAAFFAEIAQAAAA==.叫我法爷:BAAALAAECgQIBwAAAA==.',['可爱']='可爱哆:BAAALAAECgYIBgAAAA==.',['吉普']='吉普赛囡囡:BAABLAAFFH8FAAIHAAII2BIFFABHAAAHAAII2BIFFABHAAAAAA==.',['吼哦']='吼哦哈啊:BAAALAAFFAIIAgAAAA==.',['呀咩']='呀咩呔:BAAALAADCggICAAAAA==.',['咕德']='咕德猫柠:BAABLAAFFH8MAAMJAAIInhU+QAByAAAJAAIInhU+QAByAAAKAAIIqQ9hPgApAAAAAA==.',['哈娜']='哈娜老师:BAABLAAFFH8GAAIRAAIIohQ2WACcAAARAAIIohQ2WACcAAAAAA==.',['啥瞒']='啥瞒:BAAALAAECgIIAgAAAA==.',['善丶']='善丶良:BAAALAADCgIIAgAAAA==.',['善良']='善良的孩子:BAAALAAFFAIIBAAAAA==.',['嗡嗡']='嗡嗡的复仇:BAAALAAECgMIBQAAAA==.',['嘬口']='嘬口泡泡糖:BAAALAAECgMIBAAAAA==.',['噬魂']='噬魂落魄:BAAALAAECgYIEgAAAA==.',['四皇']='四皇灬烈战天:BAAALAAECgYIDgAAAA==.',['回眸']='回眸谁浅笑丶:BAABLAAFFH8WAAIQAAUIOhfiEgBcAQAQAAUIOhfiEgBcAQAAAA==.',['团灭']='团灭制招者:BAAALAAECgUIBQAAAA==.',['圣光']='圣光嗷呜:BAAALAAECgMIAwAAAA==.',['圣殿']='圣殿骑士和道:BAAALAAECgYIBgABLAAFFAIIBgACACEKAA==.',['圣电']='圣电神风:BAAALAAECgQIBgAAAA==.',['在下']='在下坂本:BAAALAAECgYIBgAAAA==.',['地狱']='地狱大魔头:BAAALAAFFAIIAgAAAA==.',['塔兹']='塔兹米:BAAALAAECgUIBQAAAA==.',['墮落']='墮落隨風:BAAALAAECgYIDgAAAA==.',['墲訫']='墲訫墲舆:BAABLAAFFH8GAAMRAAYIiAxyFgCRAQARAAUIzQ5yFgCRAQATAAEILgHTGwBUAAAAAA==.',['壹地']='壹地灬雞毛:BAAALAAFFAIIAgAAAA==.',['夏雨']='夏雨点滴:BAAALAAECggICAAAAA==.',['夙怨']='夙怨:BAAALAAFFAIIBAAAAA==.',['大漠']='大漠孤烟:BAAALAAECgUIBQAAAA==.',['大脸']='大脸盘子:BAACLAAFFH8VAAIJAAMINyIGIAAgAQAJAAMINyIGIAAgAQAsAAQKfy0AAwkACAjRHl4NAHoCAAkABwgXIV4NAHoCAAoABwi8GQocAI0BAAAA.',['大香']='大香蕉:BAABLAAFFH8HAAMHAAMI5QumDwBlAAAHAAMI5QumDwBlAAAIAAIIJQKrbAATAAAAAA==.',['天涯']='天涯孓恋:BAAALAADCgYIDAAAAA==.天涯灬尣:BAAALAADCgEIAQAAAA==.',['奄鸟']='奄鸟亨鸟:BAABLAAFFH8aAAQJAAYIyhdwEQC0AQAJAAYIyhdwEQC0AQAUAAIIFBlrBgCHAAAVAAIIyQZ7EAA2AAAAAA==.',['奔跑']='奔跑的油条灬:BAAALAAECgUIBQAAAA==.',['奶泡']='奶泡:BAAALAAFFAIIAgAAAA==.',['好痛']='好痛好苦:BAABLAAFFH8HAAIWAAIIUwn4SACMAAAWAAIIUwn4SACMAAAAAA==.',['孤妾']='孤妾常独栖丶:BAAALAADCgQIBAAAAA==.',['小寒']='小寒羊:BAAALAAECggIAwAAAA==.',['小开']='小开的小猎:BAABLAAFFH8GAAMNAAIIgiCPNgC2AAANAAIIgiCPNgC2AAAXAAIIwxEKJQB9AAAAAA==.小开的牛战:BAAALAAFFAIIAgAAAA==.小开的血圣:BAABLAAFFH8FAAIMAAII7hvOKAC4AAAMAAII7hvOKAC4AAAAAA==.',['小歪']='小歪的乖乖:BAAALAADCgYIBgAAAA==.',['小野']='小野:BAAALAAECgMIAwAAAA==.小野无敌:BAAALAAECgEIAQAAAA==.',['小雪']='小雪人:BAAALAADCggICAAAAA==.',['尐灬']='尐灬明天:BAAALAAECgQIBgAAAA==.',['山武']='山武酒肆丶:BAAALAAECgYIBgAAAA==.',['岁月']='岁月灬静好:BAAALAAFFAIIBAAAAA==.',['左手']='左手牵龍:BAAALAAECgIIAQAAAA==.',['左腿']='左腿右邊:BAAALAADCgYIBgAAAA==.',['布丁']='布丁:BAAALAAECgYICAAAAA==.',['布洛']='布洛丶克斯:BAABLAAFFH8GAAILAAIIHg+xSwBIAAALAAIIHg+xSwBIAAAAAA==.',['带刀']='带刀炳哥:BAACLAAFFH8IAAIEAAII/gBdHAA3AAAEAAII/gBdHAA3AAAsAAQKfxkAAwQABgh9BjhIAL4AAAQABggXBjhIAL4AAAMAAwjCA/mmAEcAAAAA.',['幕夜']='幕夜舞稚:BAAALAAECgYICwAAAA==.',['幻化']='幻化成香蕉:BAAALAADCgIIAgAAAA==.',['康斯']='康斯坦丁:BAACLAAFFH8IAAIYAAIIlQpiHACLAAAYAAIIlQpiHACLAAAsAAQKfxUAAxgABggXHCkkAPcBABgABggXHCkkAPcBABkAAQjSD9xPADMAAAAA.',['廿三']='廿三:BAAALAADCgcIBwAAAA==.',['弗塞']='弗塞雷迦:BAAALAAECggICQAAAA==.',['弦舞']='弦舞:BAAALAAECgEIAQAAAA==.',['彼岸']='彼岸:BAAALAAECgcICQAAAA==.',['往事']='往事随风灬:BAAALAAFFAIIAgAAAA==.',['得了']='得了个德:BAAALAAECgIIAgAAAA==.',['念去']='念去去丶随心:BAAALAAFFAIIBAAAAA==.',['怒火']='怒火滔天:BAAALAAECggIEAAAAA==.',['您呀']='您呀:BAABLAAFFH8GAAIRAAYIwRDQLgB/AQARAAYIwRDQLgB/AQAAAA==.',['慕克']='慕克白:BAACLAAFFH8JAAIaAAQIEAqiDQCmAAAaAAQIEAqiDQCmAAAsAAQKfyAAAxoACAitGMEVAGUCABoACAitGMEVAGUCABsABwjMAjs8ALYAAAAA.',['憨憨']='憨憨小猫咪:BAABLAAFFH8FAAINAAMIXAaAeABrAAANAAMIXAaAeABrAAAAAA==.',['我是']='我是大哥大:BAAALAAECgYIBgAAAA==.',['战神']='战神子龙:BAABLAAFFH8IAAIMAAIIngm9dgA6AAAMAAIIngm9dgA6AAAAAA==.',['手发']='手发光中毒深:BAAALAAECgYICwAAAA==.',['拒绝']='拒绝者:BAAALAAECgUICQAAAA==.',['指尖']='指尖的旋律:BAABLAAFFH8FAAMcAAUIqAyFDwAiAQAcAAQIKQiFDwAiAQABAAEI0gmKRwBMAAAAAA==.',['提尔']='提尔没有手:BAAALAAECgYICwAAAA==.',['提拉']='提拉米兔丶:BAAALAAECgUIBgAAAA==.',['撼地']='撼地丿:BAABLAAFFH8IAAIOAAII8BvHHwB+AAAOAAII8BvHHwB+AAAAAA==.',['擎天']='擎天一炷香:BAABLAAECn8cAAMXAAYIKQ5PFgD0AAAXAAYIKQ5PFgD0AAANAAEIUQfSoQEtAAAAAA==.',['文雅']='文雅适合我:BAAALAAECggIAQABLAAFFAgIBwAPAMwgAA==.',['斜杠']='斜杠坐下:BAABLAAFFH8KAAINAAYI0BEbOgBZAQANAAYI0BEbOgBZAQAAAA==.',['断箭']='断箭离殇:BAAALAAECgYIEAAAAA==.',['无敌']='无敌小波龙:BAAALAADCgcICgAAAA==.无敌小荡爷:BAABLAAECn8lAAILAAgILhWpQgAsAgALAAgILhWpQgAsAgAAAA==.',['无语']='无语:BAAALAADCgYIBgAAAA==.',['星界']='星界:BAACLAAFFH8GAAIRAAYIdxHTMgBvAQARAAYIdxHTMgBvAQAsAAQKfxcAAhEABghdG8JpABsBABEABghdG8JpABsBAAAA.',['暮光']='暮光守祭:BAABLAAFFH8GAAIJAAII5RACMQByAAAJAAII5RACMQByAAAAAA==.',['暮灬']='暮灬光:BAAALAAECgUIBQAAAA==.',['暴力']='暴力鲨鱼:BAAALAAECgEIAQAAAA==.',['暴风']='暴风高尼茨:BAAALAADCgYIBgAAAA==.',['曹贼']='曹贼:BAAALAAFFAIIAgAAAA==.',['最爱']='最爱小猪:BAABLAAFFH8JAAMRAAYI0R//IwCkAQARAAYI0R//IwCkAQATAAEInx+eDwBWAAABLAAFFAgICQARAMwjAA==.',['月紳']='月紳埃露蒽:BAAALAAECgYIDgAAAA==.',['有何']='有何不可:BAAALAAECgYICwAAAA==.',['朝阳']='朝阳群众:BAABLAAFFH8JAAIRAAUIhwySSAAWAQARAAUIhwySSAAWAQAAAA==.',['木風']='木風:BAAALAADCggICAAAAA==.',['术手']='术手无策丶:BAAALAAECgIIAgAAAA==.',['杀猪']='杀猪的神:BAAALAADCgcIDQAAAA==.',['村口']='村口一蹲:BAAALAADCgYIBgAAAA==.',['杰克']='杰克丶:BAAALAAECgMIBQAAAA==.',['枫棠']='枫棠映夜:BAAALAAECgYICQAAAA==.',['桃乃']='桃乃木香奈:BAAALAADCgIIAgAAAA==.',['梦回']='梦回追忆:BAAALAAFFAIIBAAAAA==.',['梦霜']='梦霜:BAAALAAECgYIDwAAAA==.',['欧克']='欧克:BAAALAAECgQIBQAAAA==.',['死兽']='死兽:BAAALAAECgEIAQAAAA==.',['残兵']='残兵追猎者:BAAALAAFFAIIAgAAAA==.',['水果']='水果小牧:BAAALAADCgcIBwAAAA==.',['水随']='水随天去:BAAALAAFFAIIAgAAAA==.',['河南']='河南晚报:BAAALAAECgYICwAAAA==.',['法克']='法克米尼巫:BAAALAAECgYIDAAAAA==.法克米缪斯:BAAALAADCgYIBgAAAA==.',['洛里']='洛里山:BAAALAAECgYIBgAAAA==.',['流风']='流风回雪:BAABLAAFFH8MAAIGAAIIpAj1GwBhAAAGAAIIpAj1GwBhAAABLAAFFAgIBgAMAPMXAA==.',['浪人']='浪人无敌:BAAALAAECgYICQAAAA==.',['淡然']='淡然落幕:BAABLAAFFH8GAAMPAAII2R7XIQBgAAAPAAEIVSHXIQBgAAAWAAIIXxxjXgBAAAAAAA==.',['混世']='混世萨:BAAALAAECgMIAwAAAA==.',['湮灭']='湮灭:BAAALAAECgYIBgAAAA==.',['滅烟']='滅烟:BAAALAAECgYIBgAAAA==.',['灬如']='灬如此而已:BAAALAAFFAIIBAAAAA==.',['灬歲']='灬歲月靜好灬:BAAALAAFFAIIAgAAAA==.',['灬莫']='灬莫扎特:BAAALAAECgcIDwAAAA==.',['灭绝']='灭绝:BAAALAADCgQIBAAAAA==.',['灰色']='灰色年伦:BAAALAAECgQICAAAAA==.',['灵魂']='灵魂摆渡:BAAALAAFFAIIBAAAAA==.',['炎一']='炎一:BAAALAAECgIIAgAAAA==.',['烛火']='烛火温暖岁末:BAAALAAECgYICgAAAA==.',['烟酒']='烟酒生哥哥:BAABLAAFFH8HAAIBAAIIcSEZLACUAAABAAIIcSEZLACUAAAAAA==.',['烟雨']='烟雨荷花影:BAAALAADCgcIBwAAAA==.',['無懈']='無懈可击:BAAALAAECgYICgAAAA==.',['熊猫']='熊猫啊:BAAALAAECgUIBQAAAA==.',['狂野']='狂野辣妹:BAABLAAFFH8PAAIRAAMIywuYYwCFAAARAAMIywuYYwCFAAAAAA==.',['狐作']='狐作妃为:BAABLAAFFH8GAAICAAIIhxMYVgBvAAACAAIIhxMYVgBvAAAAAA==.',['狮心']='狮心:BAAALAAECgIIAgAAAA==.',['狸狸']='狸狸原上草:BAAALAAECgYIDAAAAA==.',['猎行']='猎行天下:BAAALAAFFAIIBAAAAA==.',['猪头']='猪头氵伯爵:BAAALAAECgUIBQAAAA==.',['獠牙']='獠牙很大:BAAALAAFFAIIAgAAAA==.',['玖丶']='玖丶箭:BAABLAAFFH8GAAINAAIIOAYhfwBlAAANAAIIOAYhfwBlAAAAAA==.',['疯狂']='疯狂的交作业:BAAALAAECgYIBgAAAA==.',['知了']='知了:BAAALAADCgIIAgAAAA==.',['石丶']='石丶头:BAAALAADCgMIAwAAAA==.',['碳烧']='碳烧熊猫:BAAALAAECgcIBwABLAAFFAgIBgAOAJwbAA==.',['神圣']='神圣之佑:BAABLAAFFH8IAAIQAAgIpgXiDAC2AQAQAAgIpgXiDAC2AQAAAA==.',['神枪']='神枪李书文:BAAALAAECgUICQAAAA==.',['神灯']='神灯:BAABLAAFFH8YAAIdAAYITgmOBgBnAQAdAAYITgmOBgBnAQAAAA==.',['离垢']='离垢:BAABLAAFFH8bAAIGAAYIvR68BwDyAQAGAAYIvR68BwDyAQAAAA==.',['秋小']='秋小秋:BAAALAAECgYICAAAAA==.',['秦人']='秦人老赵:BAAALAAECggICAAAAA==.',['稼轩']='稼轩:BAABLAAFFH8TAAQXAAUIZB4SEwDNAAANAAQICRlLVAD9AAAXAAQIHB8SEwDNAAAeAAMI6BmNAgCrAAAAAA==.',['站住']='站住不许走:BAAALAAFFAIIBAAAAA==.',['筱死']='筱死仁:BAAALAAECgYIBgAAAA==.',['筱老']='筱老头:BAAALAAECgUICQAAAA==.',['筱隆']='筱隆隆筱:BAAALAAECgYIBgAAAA==.',['系软']='系软绵绵君:BAAALAADCgcIBwAAAA==.',['索马']='索马里牛肉:BAABLAAFFH8MAAMKAAIIJw5qIwCDAAAKAAIIJw5qIwCDAAAUAAIIygeWEQAgAAAAAA==.',['綄羙']='綄羙灬杀戳:BAAALAAECgYICAAAAA==.',['繁龙']='繁龙你别烦:BAAALAAECgYIBgAAAA==.',['约德']='约德尔:BAAALAAECgYICwAAAA==.',['缕缕']='缕缕:BAAALAAFFAEIAQAAAA==.',['缺心']='缺心眼子:BAABLAAFFH8HAAIdAAMI3AMeFwBRAAAdAAMI3AMeFwBRAAAAAA==.',['群龙']='群龙天下:BAABLAAECn8VAAIIAAgIDRWzLwBWAQAIAAgIDRWzLwBWAQAAAA==.',['老罗']='老罗丶:BAABLAAFFH8GAAILAAQIJBS2LgDhAAALAAQIJBS2LgDhAAAAAA==.老罗灬:BAABLAAFFH8JAAIRAAUIlw0xSQASAQARAAUIlw0xSQASAQAAAA==.',['耗子']='耗子尾汁丶:BAAALAAECgMIAwAAAA==.',['肥肥']='肥肥的熊缺:BAABLAAFFH8KAAIKAAIIeBG6MwA8AAAKAAIIeBG6MwA8AAAAAA==.',['胜利']='胜利者:BAABLAAFFH8HAAIRAAIINgYmkAA+AAARAAIINgYmkAA+AAAAAA==.',['艾丽']='艾丽法:BAAALAADCgEIAQAAAA==.',['艾鑔']='艾鑔:BAAALAAECgQICAAAAA==.',['花石']='花石头:BAABLAAFFH8YAAMHAAUIFBM9CAAWAQAHAAUIFBM9CAAWAQAfAAEIKgmJDgA7AAAAAA==.',['花老']='花老师:BAAALAAECgMIAwAAAA==.',['花道']='花道仙:BAAALAAECgYIBgAAAA==.',['苏可']='苏可卷:BAAALAAFFAIIAgAAAA==.',['茉香']='茉香绿茶:BAAALAAFFAIIAgABLAAFFAgICAANAOEZAA==.',['茶叶']='茶叶罐:BAAALAAECgcICAAAAA==.',['茶茶']='茶茶景:BAAALAAECgEIAQAAAA==.',['莫大']='莫大叔:BAAALAAFFAIIAgAAAA==.',['莱昂']='莱昂梅西:BAABLAAECn8XAAIRAAYIzh9uOQCWAQARAAYIzh9uOQCWAQAAAA==.',['萌牛']='萌牛集团:BAAALAAFFAYIAgAAAA==.',['萤惑']='萤惑:BAAALAAFFAIIAgAAAA==.',['萨勒']='萨勒姆的女巫:BAAALAAECgQIBAAAAA==.',['落婲']='落婲丶无痕:BAAALAAECggIBgAAAA==.',['蔚蓝']='蔚蓝之拥:BAABLAAFFH8FAAIRAAIIhBQ0YQCXAAARAAIIhBQ0YQCXAAAAAA==.',['蛮胡']='蛮胡子丶:BAAALAAECgYIBgAAAA==.',['蛮骨']='蛮骨歹:BAABLAAFFH8IAAIWAAYIUBERDwDwAQAWAAYIUBERDwDwAQAAAA==.',['血燕']='血燕:BAABLAAFFH8GAAIgAAYIEBv7BwCpAQAgAAYIEBv7BwCpAQAAAA==.',['裊袅']='裊袅:BAAALAAECgEIAQAAAA==.',['誓约']='誓约的烙印:BAAALAAECgYIEQAAAA==.',['豆浆']='豆浆不甜:BAABLAAFFH8GAAIBAAIIzxFwNACIAAABAAIIzxFwNACIAAAAAA==.',['豹子']='豹子头林冲:BAAALAAFFAIIAgAAAA==.',['赵铁']='赵铁柱:BAAALAAECgYICwAAAA==.',['路子']='路子野:BAABLAAECn8bAAIHAAYIUhArJgDzAAAHAAYIUhArJgDzAAAAAA==.',['路西']='路西:BAAALAAECgYICAAAAA==.',['踏云']='踏云无痕:BAAALAAFFAgIAgAAAA==.',['踏梦']='踏梦有痕:BAABLAAFFH8GAAIOAAYI1xhhDAB8AQAOAAYI1xhhDAB8AQAAAA==.',['踏花']='踏花有痕:BAABLAAFFH8GAAMFAAYI3hsKHQBYAQAFAAUIWB0KHQBYAQACAAEImQeeegA0AAAAAA==.',['辛多']='辛多雷娱乐:BAAALAAECgYICQAAAA==.',['达克']='达克尼斯:BAAALAADCgEIAQAAAA==.',['达神']='达神:BAABLAAFFH8TAAILAAMIxyNPIADGAAALAAMIxyNPIADGAAAAAA==.',['这波']='这波肉蛋充饥:BAAALAAFFAMIAwAAAA==.',['进击']='进击的容么么:BAAALAAECgYIBwAAAA==.',['迪克']='迪克宰牛:BAAALAAECggIDgAAAA==.',['逆风']='逆风燎千里:BAABLAAFFH8bAAILAAUIyhnyIwBOAQALAAUIyhnyIwBOAQAAAA==.',['逐梦']='逐梦黑白:BAAALAAECgIIAgAAAA==.',['逛街']='逛街的樱桃:BAAALAAECgYIBgAAAA==.',['遗墨']='遗墨:BAAALAAECgYIBgAAAA==.',['部落']='部落电网:BAAALAAECgYIBgAAAA==.',['金牛']='金牛座小海:BAAALAADCggICAAAAA==.',['钢之']='钢之心:BAAALAAECgYIDAAAAA==.',['银河']='银河魍魉:BAAALAAECgQIBAAAAA==.',['银辉']='银辉銫:BAAALAAFFAIIAgAAAA==.',['长弓']='长弓弈天:BAAALAAECgIIAgAAAA==.',['防护']='防护员:BAACLAAFFH8MAAICAAII0SBvKQCxAAACAAII0SBvKQCxAAAsAAQKfyQAAgIACAjhIfAMAJcCAAIACAjhIfAMAJcCAAAA.',['阿伊']='阿伊土拉:BAAALAAFFAEIAQAAAA==.',['阿斯']='阿斯卡拉亲王:BAAALAAECgUIBQAAAA==.',['阿玛']='阿玛忒辣斯:BAAALAAECgYIBgAAAA==.',['陌上']='陌上丶花开:BAAALAAECgYICQAAAA==.',['雷古']='雷古鲁斯:BAABLAAFFH8SAAIRAAQI3hVVUADdAAARAAQI3hVVUADdAAAAAA==.',['雷霆']='雷霆霹雳:BAAALAADCgMIAwAAAA==.',['霖泉']='霖泉:BAABLAAFFH8FAAILAAUIBQhNKwAMAQALAAUIBQhNKwAMAQAAAA==.',['霸气']='霸气小兽兽:BAAALAAFFAQIBAAAAA==.',['面具']='面具:BAAALAAECgcIEgAAAA==.',['顔佬']='顔佬闆:BAACLAAFFH8IAAIWAAgIIQBCdQAKAAAWAAgIIQBCdQAKAAAsAAQKfxQAAhYABgiNFVVGADEBABYABgiNFVVGADEBAAAA.',['领丿']='领丿袖:BAAALAAFFAIIBAAAAA==.',['风小']='风小狐:BAAALAAFFAIIBAAAAA==.',['风影']='风影雪:BAAALAAECgYIBgAAAA==.',['马德']='马德法克儿:BAAALAADCgcIAgAAAA==.',['鬼大']='鬼大毛:BAAALAAECgYIBgAAAA==.',['鬼头']='鬼头明里:BAAALAAFFAIIAwAAAA==.',['鬼道']='鬼道幽幽:BAAALAAFFAIIAgAAAA==.鬼道幽幽丶:BAABLAAFFH8GAAILAAYIrxMtCQD/AQALAAYIrxMtCQD/AQAAAA==.',['魔域']='魔域猎手:BAABLAAFFH8FAAMEAAIIpBcGDQCMAAAEAAIIpBcGDQCMAAADAAEIQwBNaQAOAAAAAA==.',['魔月']='魔月丶骑士:BAAALAAECgYICwAAAA==.',['魔蝎']='魔蝎:BAAALAAECgIIAgAAAA==.',['鲨鱼']='鲨鱼辣椒:BAAALAADCggIAgAAAA==.',['麻酱']='麻酱肠粉:BAAALAAFFAIIBAAAAA==.',['黯然']='黯然销魂:BAABLAAECn8dAAQWAAcI3RRlOwBaAQAWAAcI3RRlOwBaAQAPAAMI9wwWcwCsAAAhAAEIiAYcQQA4AAAAAA==.',['龙骑']='龙骑士:BAABLAAECn8aAAMMAAYISiIwNADDAQAMAAYISiIwNADDAQAQAAYI0BioLwCxAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end