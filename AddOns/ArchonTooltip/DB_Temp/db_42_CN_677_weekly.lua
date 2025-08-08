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
 local lookup = {'Hunter-Marksmanship','Mage-Frost','Druid-Restoration','Warrior-Fury','Hunter-BeastMastery','Monk-Mistweaver','Warlock-Destruction','DemonHunter-Vengeance','DemonHunter-Havoc','Mage-Fire','Rogue-Assassination','Paladin-Holy','Paladin-Protection','Warrior-Arms','Warrior-Protection','Warlock-Affliction','Warlock-Demonology','Druid-Feral','Druid-Balance','Mage-Arcane','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Retribution','Priest-Holy','Shaman-Elemental','Monk-Brewmaster','Monk-Windwalker','DeathKnight-Frost','Unknown-Unknown','Shaman-Restoration','Priest-Shadow','Priest-Discipline','Shaman-Enhancement','Hunter-Survival','Druid-Guardian','Evoker-Devastation','Rogue-Outlaw','Rogue-Subtlety','Evoker-Preservation',}; local provider = {region='CN',realm='影牙要塞',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Aliencen:BAAAKgAFFAYIAgABKgAFFAgICAABAGcbAA==.Allenlverson:BAACKgAFFH8WAAICAAMIChv4DQD1AAACAAMIChv4DQD1AAAqAAQKfyUAAgIACAi8IFoEAJUCAAIACAi8IFoEAJUCAAAA.',Am='Amateurhealr:BAABKgAECn8YAAIDAAgI0xWSHQCwAQADAAgI0xWSHQCwAQABKgAFFAgIDgAEAMYXAA==.Amber:BAAAKgADCggICAAAAA==.',An='Aneyybabby:BAAAKgAECggICAAAAA==.',Ar='Archons:BAAAKgAECggICwAAAA==.',Ba='Backtrack:BAABKgAFFH8UAAMBAAYIyRxkAQCrAQABAAYIyRxkAQCrAQAFAAQILh5UGADvAAAAAA==.',Be='Beastpoi:BAABKgAFFH8LAAIGAAQIXBtlEADlAAAGAAQIXBtlEADlAAAAAA==.',Ch='Chiq:BAAAKgAECgUIBQAAAA==.Chronic:BAABKgAECn8YAAIHAAgItxHxGQA0AQAHAAgItxHxGQA0AQAAAA==.',Ci='Cirilla:BAABKgAFFH8GAAMIAAQI/A1KGACKAAAJAAIIZhGLKgCKAAAIAAQIDAtKGACKAAAAAA==.',Co='Cosmas:BAABKgAECn8UAAIFAAgIjQf/kQAIAQAFAAgIjQf/kQAIAQAAAA==.',De='Deadbody:BAABKgAECn8WAAMKAAcIWBkzOgCqAQAKAAcIWBkzOgCqAQACAAQIKgsQjgByAAAAAA==.Dentata:BAAAKgAFFAQIAwAAAA==.',Dg='Dgugu:BAABKgAFFH8GAAIDAAYIKgwgDgAwAQADAAYIKgwgDgAwAQAAAA==.',Di='Dico:BAAAKgAECgUIBgAAAA==.',Dr='Dragonxx:BAAAKgAECgYIBgAAAA==.',El='Elfdruid:BAAAKgADCgcIBwAAAA==.',Er='Erawalker:BAAAKgADCggICAAAAA==.',Ev='Evankai:BAACKgAFFH8FAAILAAMI0hG+EACqAAALAAMI0hG+EACqAAAqAAQKfysAAgsACAjVHG4MAFQCAAsACAjVHG4MAFQCAAAA.Evantatu:BAABKgAECn8VAAMMAAgIIxYrHQB3AQAMAAcIZRQrHQB3AQANAAUIPQ1DQgB2AAAAAA==.',He='Hellsream:BAACKgAFFH8GAAIOAAMI0BiRFADfAAAOAAMI0BiRFADfAAAqAAQKf0YABA4ACAiJI5UEAM0CAA4ACAiJI5UEAM0CAAQACAgHIFYNAHwCAA8AAggVHFs8AFEAAAEqAAUUCAgOAAQAxhcA.',Hq='Hqx:BAAAKgAFFAgIBAAAAA==.',In='Incubus:BAAAKgAECggICgAAAA==.',Ja='Jameson:BAAAKgAECggIDgAAAA==.',Ka='Kaylly:BAAAKgAECgMIBAAAAA==.',Ln='Lnteme:BAAAKgAECgIIAwAAAA==.',Lo='Lorewalkerz:BAAAKgAECggIDwABKgAFFAgIDgAEAMYXAA==.',Lu='Lucky:BAABKgAFFH8MAAIFAAMIBSFQIAAMAQAFAAMIBSFQIAAMAQAAAA==.',Ly='Lys:BAAAKgAFFAMIBAAAAA==.',Ma='Madison:BAABKgAFFH8GAAQHAAYI9x6wBwAqAQAHAAMIXCGwBwAqAQAQAAII3iZ8FgBzAAARAAEI4w/yEwBWAAAAAA==.Magister:BAAAKgAECgMIAwAAAA==.',My='Mygirl:BAAAKgAFFAEIAQAAAA==.',Ni='Nice:BAAAKgAECgEIAQAAAA==.',Os='Ostrovsky:BAABKgAFFH8FAAISAAMIlAy7BwC7AAASAAMIlAy7BwC7AAAAAA==.',Pa='Parkinson:BAABKgAFFH8KAAITAAYI+R8KAQDvAQATAAYI+R8KAQDvAQAAAA==.',Pl='Playmx:BAAAKgAECgQIBAAAAA==.',Po='Poka:BAABKgAFFH8MAAIUAAYIxRIDEwBNAQAUAAYIxRIDEwBNAQAAAA==.',Pr='Pryce:BAAAKgADCggICAAAAA==.',Pu='Purpleelf:BAAAKgAFFAIIAgAAAA==.',Qw='Qwb:BAAAKgAECgEIAQAAAA==.',Ra='Raptor:BAAAKgAECggICQAAAA==.Raptors:BAAAKgAECgEIAQAAAA==.',Re='Redempt:BAABKgAFFH8YAAMVAAYIGCRuBgDJAQAVAAYIMSFuBgDJAQAWAAYImiHhEACVAQABKgAFFAgIGgANADghAA==.',Sa='Sacredpal:BAAAKgAECgUIBQAAAA==.',Sc='Scorpior:BAAAKgADCggICAABKgAFFAUICwALAOoaAA==.',Si='Sindera:BAAAKgAECgcIBwAAAA==.',Sj='Sj:BAACKgAFFH8TAAIOAAMIZR9YEAAMAQAOAAMIZR9YEAAMAQAqAAQKfx0AAg4ACAgFHMMNAFMCAA4ACAgFHMMNAFMCAAAA.',Te='Tenaissance:BAAAKgAECgQIBAAAAA==.',Th='Thetinyevil:BAAAKgAECgcIDAABKgAFFAgIDgAEAMYXAA==.',Ti='Tianar:BAAAKgAECgMIAwAAAA==.Tictok:BAAAKgAFFAYIAwAAAA==.',Ts='Tsubaki:BAAAKgAFFAEIAQAAAA==.',Ve='Vestige:BAAAKgAECgUIBQAAAA==.',Vi='Vivien:BAAAKgAFFAIIAgAAAA==.',Wa='Waterloo:BAABKgAFFH8IAAMDAAYIlxx1EwAEAQADAAQIsRl1EwAEAQATAAQItQ7PIQCwAAAAAA==.',Wi='Winterp:BAABKgAFFH8IAAIFAAgI8wi/CQDAAQAFAAgI8wi/CQDAAQAAAA==.',Wy='Wyz:BAABKgAFFH8JAAITAAYIAhKMIgARAQATAAYIAhKMIgARAQAAAA==.',Yo='Yohko:BAAAKgAFFAIIAgAAAA==.',['一北']='一北风吹:BAAAKgADCggICAAAAA==.',['一只']='一只小叨叨:BAAAKgADCggICAAAAA==.一只小漫漫:BAAAKgADCgIIAgAAAA==.一只小烈烈:BAAAKgAFFAMIBAAAAA==.一只小牧牧:BAAAKgADCgQIBAAAAA==.一只小芝芝:BAAAKgADCggICAAAAA==.一只小诗诗:BAAAKgADCggICAAAAA==.',['一心']='一心一剑:BAAAKgAFFAMIAwAAAA==.',['一把']='一把烟花放完:BAAAKgADCggICAAAAA==.',['一笑']='一笑丶一尘缘:BAACKgAFFH8LAAMXAAQIiBQeIwDbAAAXAAMIiBQeIwDbAAAMAAQIJhIoCADUAAAqAAQKfx4AAwwACAj1INoJAEwCAAwACAj1INoJAEwCABcABggFFOukAE4BAAAA.',['一袋']='一袋薯条:BAABKgAFFH8LAAIUAAMIZhUvJQDNAAAUAAMIZhUvJQDNAAAAAA==.',['丁尼']='丁尼格非:BAAAKgAECgQIBwAAAA==.',['七叶']='七叶重楼:BAAAKgAECgIIAgAAAA==.',['万华']='万华未央:BAAAKgAFFAEIAgABKgAFFAMIBQAYAFYSAA==.',['三分']='三分姬:BAAAKgAECgUIBQAAAA==.',['三钱']='三钱当归:BAAAKgADCggICAAAAA==.',['下班']='下班双采:BAAAKgAECgUIBQAAAA==.',['不关']='不关鸭鸭事:BAAAKgAECgEIAQAAAA==.',['不晚']='不晚睡:BAAAKgAECgQIBAAAAA==.不晚睡死骑:BAACKgAFFH8OAAMWAAUIHiAsDADMAQAWAAUIHiAsDADMAQAVAAIIBBhUIwCOAAAqAAQKfxQAAhYACAglHTocAC0CABYACAglHTocAC0CAAAA.不晚睡猎手:BAAAKgAFFAEIAQAAAA==.',['与魔']='与魔共舞:BAAAKgADCgIIAgAAAA==.',['丢圈']='丢圈圈:BAABKgAFFH8GAAIYAAYICRaMDABbAQAYAAYICRaMDABbAQAAAA==.',['中年']='中年男人:BAAAKgAFFAQIBAAAAA==.',['丶利']='丶利刃丶:BAAAKgAECgYIDgAAAA==.',['丶离']='丶离陌:BAAAKgADCggIDwAAAA==.',['乌力']='乌力格勒:BAAAKgAECgEIAQAAAA==.',['乌鸦']='乌鸦坐飞机:BAAAKgAECgQIBAAAAA==.',['乐乐']='乐乐狂魔:BAAAKgAECgUIBQAAAA==.',['九七']='九七至尊:BAAAKgAECgcICAAAAA==.',['二丶']='二丶酱:BAAAKgAECgIIAgAAAA==.',['二五']='二五八:BAABKgAECn8gAAIZAAgI1w/lLQBvAQAZAAgI1w/lLQBvAQAAAA==.',['二福']='二福:BAAAKgAECggIDwAAAA==.',['二酱']='二酱:BAAAKgAECgUIBQAAAA==.',['亚罗']='亚罗:BAAAKgAFFAQIBAAAAA==.',['他们']='他们心跳加快:BAAAKgAECgcICgAAAA==.',['以太']='以太贤者:BAACKgAFFH8IAAICAAMIeARbEACNAAACAAMIeARbEACNAAAqAAQKfxUAAgIACAiFCcMWABkBAAIACAiFCcMWABkBAAAA.',['以橙']='以橙服人:BAABKgAECn8WAAITAAgIIxzwLQAGAgATAAgIIxzwLQAGAgAAAA==.',['仲夏']='仲夏夜之夢丶:BAAAKgADCgcIBwAAAA==.',['伊利']='伊利达雷之怒:BAABKgAFFH8GAAIJAAIIxBCOKQCOAAAJAAIIxBCOKQCOAAABKgAFFAgIDQAJAIcmAA==.',['伊敖']='伊敖:BAABKgAECn8WAAQHAAgIvBO2NQCYAQAHAAcIRBW2NQCYAQARAAMIIAfYYAB0AAAQAAEIjAqARAA3AAABKgAFFAgIDQAGAEUOAA==.',['似水']='似水琉华:BAAAKgAFFAQIBAABKgAFFAgIDAATAHMZAA==.',['低调']='低调的召唤者:BAAAKgAECgMIAwAAAA==.',['佑书']='佑书:BAAAKgADCgUIBQAAAA==.',['佑曦']='佑曦:BAABKgAFFH8QAAMaAAQIKxdGBgC3AAAaAAQIKxdGBgC3AAAbAAQIFA4oFgC3AAAAAA==.',['你抗']='你抗我打:BAAAKgAECggICAAAAA==.',['你若']='你若盛开丶:BAAAKgAECgEIAQAAAA==.',['倒了']='倒了别怨奶:BAABKgAFFH8GAAIGAAYILBFWAwCSAQAGAAYILBFWAwCSAQABKgAFFAgIBgAGAAQhAA==.',['倚楼']='倚楼丶听风雨:BAAAKgAECggICAAAAA==.',['傲笑']='傲笑红尘:BAAAKgAECgcIDAAAAA==.',['光之']='光之圣歌:BAAAKgAECgEIAQAAAA==.',['光影']='光影之子:BAABKgAFFH8QAAIIAAQIpg+iCgCkAAAIAAQIpg+iCgCkAAAAAA==.',['光明']='光明丶黑暗:BAAAKgAECgUIDQAAAA==.',['克劳']='克劳德:BAAAKgAFFAQIBAAAAA==.',['兔兔']='兔兔快跑:BAAAKgADCggICAAAAA==.',['六合']='六合飞蓬:BAAAKgADCgQIBAAAAA==.',['六月']='六月得雨:BAAAKgAFFAYIBAAAAA==.',['兰兰']='兰兰女王大人:BAAAKgAECgcIBwAAAA==.',['养由']='养由羿:BAAAKgAECgIIAgAAAA==.',['再朔']='再朔人生:BAAAKgAFFAIIBAAAAA==.',['再见']='再见了磨兽:BAAAKgAECgUIBgAAAA==.',['冠位']='冠位梅林:BAABKgAFFH8KAAMCAAYIqhoTBQCPAQACAAYIGRoTBQCPAQAUAAQIbx2JGgARAQAAAA==.',['冬晴']='冬晴:BAACKgAFFH8WAAIHAAMIaiNGHAAkAQAHAAMIaiNGHAAkAQAqAAQKfywAAwcACAi3I5AHALMCAAcACAi3I5AHALMCABEAAQgVFSJ7AD0AAAAA.',['冰天']='冰天雪地:BAAAKgAECggIDwAAAA==.',['冷月']='冷月嫣:BAAAKgADCgQIBAAAAA==.',['冷眼']='冷眼玛吉:BAAAKgAECggICAAAAA==.',['冻冻']='冻冻捌:BAAAKgAECgMIAwAAAA==.',['出笙']='出笙指南:BAACKgAFFH8GAAMWAAYInBfeIgAMAQAWAAQIMyHeIgAMAQAVAAIIOgkAAAAAAAAqAAQKfxQAAxYACAghGSkxAO4BABYACAgeGSkxAO4BABwACAiTDtcTAFsBAAAA.',['初一']='初一:BAABKgAFFH8GAAIWAAYIUQ5LFwBiAQAWAAYIUQ5LFwBiAQAAAA==.',['剑菟']='剑菟泓:BAAAKgAECgMIAwAAAA==.',['剩小']='剩小丸子:BAAAKgADCgEIAQAAAA==.',['勾八']='勾八飞飞灰:BAAAKgAFFAcIAQAAAA==.',['十三']='十三太妹:BAAAKgAECgEIAQAAAA==.',['午后']='午后的雨:BAAAKgAECgMIBQAAAA==.',['半夜']='半夜去偷蛇:BAAAKgAECgEIAQAAAA==.',['卫宫']='卫宫士龙:BAABKgAFFH8GAAIBAAYIyg4sEADZAAABAAYIyg4sEADZAAAAAA==.',['双叶']='双叶杏:BAAAKgAECgEIAQAAAA==.',['双持']='双持辣条:BAABKgAFFH8GAAIJAAYIyxejDwCMAQAJAAYIyxejDwCMAQAAAA==.',['双核']='双核心橙:BAABKgAFFH8GAAILAAMIpxJkGQDdAAALAAMIpxJkGQDdAAAAAA==.',['发发']='发发擦:BAAAKgAECgcIBwAAAA==.',['叫磊']='叫磊哥:BAAAKgADCggIDwAAAA==.',['可爱']='可爱的清九九:BAAAKgAECgcIDAAAAA==.',['史德']='史德利古尔:BAABKgAFFH8cAAMEAAYIKSIqAQDQAQAEAAYIQR8qAQDQAQAOAAYIihgxAQDAAQAAAA==.',['右代']='右代宫绘羽:BAAAKgADCggICAAAAA==.',['叹息']='叹息夜星无眠:BAABKgAFFH8JAAILAAYI8BdyAQDGAQALAAYI8BdyAQDGAQAAAA==.',['吉姆']='吉姆莎:BAAAKgAECgYIBwAAAA==.',['向善']='向善:BAABKgAFFH8IAAIPAAgImw9HAwCJAQAPAAgImw9HAwCJAQAAAA==.',['向鈤']='向鈤葵丶微笑:BAAAKgADCgEIAQAAAA==.',['君醉']='君醉早還:BAAAKgADCgUIBgAAAA==.',['呼哈']='呼哈呼哈:BAAAKgAFFAYIBAABKgAFFAgIKgAFACMgAA==.',['咕咕']='咕咕不太冷:BAAAKgAECgYIBgAAAA==.',['哎哟']='哎哟喂真菜:BAAAKgADCgIIAgAAAA==.',['哥胖']='哥胖之翼天:BAABKgAFFH8QAAMUAAgI9xn8FAA9AQAUAAQIpxr8FAA9AQAKAAQIDRnmGwDjAAAAAA==.',['嗷丶']='嗷丶呜:BAAAKgAECgYICAAAAA==.',['嗷嗷']='嗷嗷丶嗷:BAAAKgADCgEIAQAAAA==.',['嘟嘟']='嘟嘟噜噜:BAAAKgAECgQIBAAAAA==.',['噗蕾']='噗蕾:BAAAKgAECgIIAgABKgAECgQIBAAdAAAAAA==.',['噢啦']='噢啦啦:BAAAKgAFFAQIBAAAAA==.',['四时']='四时花楹:BAAAKgADCgEIAQAAAA==.',['国宝']='国宝中的国宝:BAAAKgADCgMIAwAAAA==.',['圣光']='圣光之主:BAAAKgADCggIDwAAAA==.圣光啊老兄:BAAAKgAFFAEIAQAAAA==.圣光楷模:BAABKgAFFH8GAAIJAAYIjAfmEAAlAQAJAAYIjAfmEAAlAQAAAA==.',['在朔']='在朔人生:BAAAKgAFFAIIBAAAAA==.',['地獄']='地獄咆哮:BAABKgAFFH8GAAIEAAYI+w7VDgBnAQAEAAYI+w7VDgBnAQAAAA==.',['地萨']='地萨:BAAAKgAFFAQIBAABKgAFFAgIEAAeACIVAA==.',['坦尼']='坦尼:BAAAKgAECgIIAgAAAA==.',['墨忘']='墨忘道:BAAAKgAFFAIIAwAAAA==.',['夏沫']='夏沫未至:BAAAKgAECggICAAAAA==.',['夏灬']='夏灬梦懿:BAABKgAFFH8IAAIJAAgIKxo0BQBqAgAJAAgIKxo0BQBqAgAAAA==.夏灬梦落:BAAAKgAECgYICwAAAA==.夏灬梦葉:BAABKgAFFH8GAAIKAAYIOBvTCwB5AQAKAAYIOBvTCwB5AQAAAA==.夏灬梦述:BAAAKgADCggICAAAAA==.',['夜兰']='夜兰:BAAAKgAECgEIAQAAAA==.',['夜幕']='夜幕阴影:BAAAKgAECgEIAQAAAA==.',['夜行']='夜行者:BAAAKgAECgcIBwAAAA==.',['夜阑']='夜阑听书语:BAAAKgAECgYIBgAAAA==.',['够鲜']='够鲜艳了吗:BAAAKgAECgMIAwAAAA==.',['大叔']='大叔随心:BAAAKgAECgYIBAAAAA==.',['大建']='大建走过:BAAAKgAECgEIAQAAAA==.',['大烦']='大烦薯:BAAAKgAECggIDAAAAA==.',['大胡']='大胡子:BAAAKgAFFAIIAgAAAA==.',['大魔']='大魔导师丽娜:BAAAKgAECggIDgAAAA==.',['大鼻']='大鼻子猪:BAAAKgAECgQIBAAAAA==.',['天之']='天之志雷马:BAAAKgAECgYICgAAAA==.',['天元']='天元突破:BAAAKgADCgIIAgAAAA==.',['天地']='天地缓缓:BAABKgAFFH8GAAIGAAYIBCG8BwC5AQAGAAYIBCG8BwC5AQAAAA==.',['天神']='天神怒罚:BAAAKgAECgMIBAAAAA==.',['天青']='天青色等烟花:BAAAKgAECgIIAgAAAA==.',['女人']='女人如兰:BAAAKgADCgMIAwAAAA==.',['奶父']='奶父无犬子:BAACKgAFFH8GAAIfAAYIdROmAwCXAQAfAAYIdROmAwCXAQAqAAQKfxQAAyAACAgYIJsMAGsCACAACAgYIJsMAGsCAB8ABggOFGQ/AP4AAAEqAAUUCAgGAAYABCEA.',['好帥']='好帥旳爸爸:BAAAKgAECgMIAwAAAA==.',['妖妖']='妖妖灵:BAAAKgAECgMIAwAAAA==.',['妮可']='妮可囉濱:BAAAKgADCgQIBAAAAA==.妮可基德曼:BAAAKgADCggIDwAAAA==.',['婉在']='婉在水中芷:BAAAKgAECgMIAwAAAA==.',['孤月']='孤月心:BAAAKgAECgYIBgAAAA==.',['学医']='学医救不了国:BAABKgAFFH8GAAIGAAYILg/2DQBGAQAGAAYILg/2DQBGAQAAAA==.',['守护']='守护女王:BAAAKgAECggIDgAAAA==.',['安吉']='安吉拉齐格勒:BAACKgAFFH8FAAIYAAMIVhLqFACYAAAYAAMIVhLqFACYAAAqAAQKfxkAAhgABwimIH4WAB8CABgABwimIH4WAB8CAAAA.',['安静']='安静丶雨夜:BAAAKgAECgYIBgAAAA==.',['宝石']='宝石老头:BAAAKgADCgEIAQAAAA==.',['寒冰']='寒冰心语:BAABKgAFFH8MAAMUAAgIHBBtBwAJAgAUAAgIHBBtBwAJAgACAAQIURXRFQC/AAAAAA==.',['寻找']='寻找一个人:BAAAKgAECggICgAAAA==.',['小凯']='小凯特:BAABKgAFFH8GAAIKAAYIsRDGDgBUAQAKAAYIsRDGDgBUAQAAAA==.',['小咪']='小咪咪猫:BAABKgAFFH8IAAMCAAgIxxOlBACDAQACAAYIYRelBACDAQAUAAIIxgrhHACcAAAAAA==.',['小奶']='小奶酪君儿:BAAAKgAECggICAAAAA==.',['小婉']='小婉儿:BAAAKgAECgcIBwAAAA==.',['小小']='小小婉婉:BAAAKgAECgEIAQAAAA==.',['小影']='小影爸爸:BAAAKgAECgUIBQAAAA==.',['小松']='小松未可子:BAAAKgAECgMIAwAAAA==.',['小步']='小步舞曲:BAACKgAFFH8IAAMhAAQI9g0REQDPAAAhAAMILw0REQDPAAAZAAMIDQqRGgCmAAAqAAQKfxQAAyEACAiaHCoSANkBACEABghtGyoSANkBABkACAhaFTQ5AFABAAEqAAUUCAgCAB0AAAAA.',['小爬']='小爬爬呀:BAAAKgAFFAQIBAAAAA==.',['小破']='小破弓:BAABKgAFFH8IAAMFAAMIsAb+RQCJAAAFAAMIsAb+RQCJAAAiAAEIfwHxBQAgAAAAAA==.',['小笔']='小笔兜:BAAAKgAECgYIBgAAAA==.',['小豆']='小豆芽:BAAAKgADCgcIBwAAAA==.',['小镇']='小镇的流逝:BAACKgAFFH8HAAILAAMI5gdSHgC4AAALAAMI5gdSHgC4AAAqAAQKf0IAAgsACAhFG44RAPUBAAsACAhFG44RAPUBAAAA.',['少年']='少年游:BAAAKgADCgIIAgAAAA==.',['尼克']='尼克尔:BAAAKgAECggIEgAAAA==.',['尽是']='尽是风流:BAACKgAFFH8eAAQCAAcIkBd/CQArAQACAAcITRd/CQArAQAUAAMIpRchJADSAAAKAAII0Rq9LQBMAAAqAAQKfygABAoACAhBI9wJAEACAAoACAjVHNwJAEACAAIABghCIIc0AJ4BABQAAwj6GOBdAMsAAAAA.',['巫巫']='巫巫火车王:BAAAKgAECgEIAQAAAA==.',['已经']='已经超神:BAAAKgADCggICwAAAA==.',['布布']='布布女王殿下:BAAAKgAECgYIBgAAAA==.',['幽冥']='幽冥一啸:BAAAKgAECgYIBgAAAA==.',['幽夜']='幽夜的灵能者:BAAAKgAFFAYIAwAAAA==.',['幽游']='幽游客:BAAAKgADCggIDAAAAA==.幽游猎手:BAAAKgADCgYIBgAAAA==.',['张无']='张无基:BAACKgAFFH8cAAIbAAcIQRg3CABuAQAbAAcIQRg3CABuAQAqAAQKfyQAAhsACAiAIR0OAFQCABsACAiAIR0OAFQCAAAA.',['彡山']='彡山丘彡:BAAAKgADCgIIAgAAAA==.',['彩灬']='彩灬虹:BAABKgAFFH8IAAIBAAgIRxT7BgD1AQABAAgIRxT7BgD1AQAAAA==.',['往事']='往事如尘:BAAAKgADCggICAAAAA==.',['德丶']='德丶神:BAAAKgAECgcICQABKgAFFAMIBwAYAKAVAA==.',['德制']='德制翼:BAACKgAFFH8HAAQYAAMIoBWjIQC/AAAYAAMIXhWjIQC/AAAfAAIIOgheHgB3AAAgAAEI8BukJQBMAAAqAAQKfy0ABB8ACAgUHdoUAPABAB8ACAgUHdoUAPABABgACAgOHZkwAIEBACAABgisG+ctAHEBAAAA.',['心御']='心御丨圣裁:BAAAKgADCgcIBwAAAA==.',['快点']='快点呀埃德伽:BAAAKgAECgIIAgAAAA==.',['态变']='态变老个一:BAAAKgAFFAgIBAAAAA==.',['思念']='思念亦是泪:BAAAKgAECgEIAQAAAA==.思念洂是泪:BAAAKgAECgYICgAAAA==.思念金属:BAAAKgAFFAMIAwAAAA==.',['思淰']='思淰洂是泪:BAAAKgADCgIIAgAAAA==.',['懒鸠']='懒鸠叻:BAABKgAFFH8GAAIVAAYI4SXzAwAaAgAVAAYI4SXzAwAaAgABKgAFFAgIGgAWAEwhAA==.',['我会']='我会寒冰箭:BAAAKgADCgYICQAAAA==.',['我在']='我在马路边儿:BAAAKgADCgEIAgAAAA==.',['我有']='我有一只狼:BAAAKgADCgIIAgAAAA==.',['我爱']='我爱透熊猫:BAABKgAFFH8IAAMVAAQIjQ9YFQChAAAWAAQI3QtZPACsAAAVAAQIaQxYFQChAAAAAA==.',['我的']='我的老公很呆:BAAAKgAECgMIBQAAAA==.我的那个发:BAAAKgAECgEIAQAAAA==.',['我瞎']='我瞎故我帅:BAAAKgADCgMIAwAAAA==.',['我腰']='我腰疼:BAACKgAFFH8RAAIBAAMImCRPFQA5AQABAAMImCRPFQA5AQAqAAQKfxcAAgEABwgzJC8OAGgCAAEABwgzJC8OAGgCAAAA.',['我还']='我还是很牛:BAAAKgAECgMIAwAAAA==.',['战斗']='战斗大尸:BAAAKgAECgYIBgAAAA==.',['执政']='执政少女:BAAAKgAFFAYIAQAAAA==.',['扭动']='扭动的大皮股:BAAAKgAECgcICgAAAA==.',['抗揍']='抗揍才能胜利:BAABKgAFFH8FAAIeAAMIDAOGQQCBAAAeAAMIDAOGQQCBAAAAAA==.',['拭抹']='拭抹陽光:BAAAKgAECgEIAQABKgAFFAQIEAAIAKYPAA==.',['描边']='描边大师:BAAAKgAFFAEIAQAAAA==.',['提卡']='提卡:BAAAKgAECgQIBgAAAA==.',['提默']='提默斯奥丁:BAACKgAFFH8OAAIXAAMIrhaqSwDXAAAXAAMIrhaqSwDXAAAqAAQKfxkAAhcACAisH7M8ADkCABcACAisH7M8ADkCAAAA.',['敌方']='敌方眼中圣骑:BAAAKgAECgIIAgAAAA==.',['斗篷']='斗篷与匕首:BAAAKgADCgYIBgAAAA==.',['斟唐']='斟唐已垂垂:BAAAKgAECgEIAQAAAA==.',['斯普']='斯普挼斯:BAAAKgADCgMIAwAAAA==.',['无以']='无以森林:BAACKgAFFH8IAAIOAAgIsxTyAgA7AgAOAAgIsxTyAgA7AgAqAAQKfxUAAgQACAjzF/wcAOsBAAQACAjzF/wcAOsBAAAA.无以猎灵:BAAAKgAECgMIAwAAAA==.',['无头']='无头一七五:BAAAKgAECgcICwAAAA==.',['无心']='无心恋战:BAAAKgADCgYIBgAAAA==.',['无畏']='无畏的切糕:BAAAKgAECgQIBgAAAA==.',['无糖']='无糖可乐:BAAAKgADCggICAAAAA==.',['日落']='日落归山海:BAAAKgAFFAEIAQAAAA==.',['日高']='日高里菜:BAAAKgAECggIDAAAAA==.',['昔曰']='昔曰鸣响:BAACKgAFFH8WAAQUAAQIeR6sHgDxAAAUAAQIDRysHgDxAAAKAAIImhGwLwCMAAACAAIILhfMIQB8AAAqAAQKfyYABAIACAhtIA8tAMMBAAIABgj+IQ8tAMMBAAoABggUFpFMAE4BABQABAiyHfg/AEIBAAAA.',['星丶']='星丶如雨:BAAAKgADCgIIAgAAAA==.',['星期']='星期八的大神:BAAAKgADCgEIAgAAAA==.',['星霜']='星霜落满归途:BAABKgAFFH8GAAIBAAQInA/nIQDqAAABAAQInA/nIQDqAAAAAA==.',['春风']='春风橙辰:BAAAKgAFFAgIBAAAAA==.',['時小']='時小雨丶:BAAAKgAFFAIIAgABKgAFFAgIDgAEAMYXAA==.',['晓晓']='晓晓来抓你咯:BAABKgAFFH8IAAIOAAgIww28BQDKAQAOAAgIww28BQDKAQAAAA==.',['晨星']='晨星之翎:BAABKgAFFH8QAAIXAAgIFCB7AAAaAgAXAAgIFCB7AAAaAgAAAA==.',['晨风']='晨风飘落:BAAAKgAECgIIAwAAAA==.',['暗月']='暗月星星:BAAAKgAECgIIAgAAAA==.',['暮夏']='暮夏丶皮皮:BAAAKgAECggICgAAAA==.',['暴躁']='暴躁老头:BAAAKgAECgYIBgAAAA==.',['月光']='月光之花:BAAAKgADCgMIBAAAAA==.',['月嬷']='月嬷嬷:BAAAKgADCgIIAgAAAA==.',['月色']='月色凝霜:BAAAKgAECggICAAAAA==.',['木兰']='木兰何所思:BAAAKgAFFAgIAwAAAA==.',['朱雀']='朱雀七宿一井:BAAAKgAFFAIIAgAAAA==.朱雀七宿一張:BAAAKgAECggIDwAAAA==.朱雀七宿一星:BAAAKgAFFAMIAwAAAA==.朱雀七宿一柳:BAAAKgAECgUIBQAAAA==.朱雀七宿一翼:BAAAKgADCggICQAAAA==.朱雀七宿一軫:BAAAKgAFFAEIAQAAAA==.',['李老']='李老汉:BAABKgAFFH8MAAMHAAYIyRraDQBiAQAHAAYIuhnaDQBiAQARAAEI7gzNFABUAAAAAA==.',['松鼠']='松鼠悠着点:BAABKgAECn8kAAMTAAgI/RjsNQDRAQATAAgIshbsNQDRAQAjAAgI9xAkFgBUAQABKgAFFAMIBwAFALQKAA==.',['林北']='林北打灵打:BAAAKgAECgUICQAAAA==.',['林多']='林多米尔:BAABKgAFFH8GAAIeAAYIaxgAAQC/AQAeAAYIaxgAAQC/AQAAAA==.',['枫之']='枫之殇:BAAAKgAECgIIAgAAAA==.',['枫林']='枫林菲舞:BAAAKgAFFAgIBAAAAA==.',['枫舞']='枫舞丨湮灭:BAABKgAECn8hAAIWAAgIWxfxKADdAQAWAAgIWxfxKADdAQAAAA==.',['枭龙']='枭龙银:BAAAKgAECgcICwAAAA==.',['柏舟']='柏舟:BAABKgAFFH8lAAIGAAYI7hZ4DABeAQAGAAYI7hZ4DABeAQAAAA==.',['柒块']='柒块腹肌:BAABKgAECn8cAAIZAAgI2weRSQDbAAAZAAgI2weRSQDbAAAAAA==.',['柠檬']='柠檬苏打水:BAAAKgAECgEIAQAAAA==.',['柴可']='柴可夫斯基:BAACKgAFFH8QAAQHAAQIEx6sIgDzAAAHAAMIEx6sIgDzAAAQAAMIGQo4EgCqAAARAAIIaQM2MgAyAAAqAAQKfx4AAwcACAjaH+IbABsCAAcABwhQIOIbABsCABEAAghQHc1XAJAAAAAA.',['核芯']='核芯橙:BAAAKgAECgMICgAAAA==.',['桂馥']='桂馥兰香:BAABKgAFFH8KAAQRAAUIHREEFgCXAAAHAAUIwgvxGwCrAAARAAIIBRgEFgCXAAAQAAEI7wvQJQA4AAAAAA==.',['桃蜀']='桃蜀:BAABKgAFFH8IAAIYAAgIFxC4BwCuAQAYAAgIFxC4BwCuAQAAAA==.',['桔梗']='桔梗:BAAAKgAECgEIAQAAAA==.',['梅琳']='梅琳娜的锋刃:BAAAKgAECgYIBwAAAA==.',['梦莎']='梦莎:BAACKgAFFH8WAAIYAAQI9RtqIADFAAAYAAQI9RtqIADFAAAqAAQKfy8AAhgACAjcICYYABMCABgACAjcICYYABMCAAAA.',['榔头']='榔头镰刀红旗:BAAAKgAFFAEIAQAAAA==.',['樱桃']='樱桃狮子头:BAAAKgAECgYICAAAAA==.',['欢乐']='欢乐逗弟主:BAAAKgAFFAQIBAAAAA==.',['欣赏']='欣赏我的丑:BAAAKgAFFAYIAgABKgAFFAgIAQAdAAAAAA==.欣赏我的萌:BAAAKgAFFAgIBAAAAA==.',['武僧']='武僧伊傲:BAACKgAFFH8NAAIGAAgIRQ4aBwDIAQAGAAgIRQ4aBwDIAQAqAAQKfxwABAYACAhkHalBADoBAAYABQiTG6lBADoBABsABgiWDQExACgBABoABwifDFcQACYBAAAA.',['死亡']='死亡剑骑丶羽:BAAAKgAECgIIAgAAAA==.',['死神']='死神灬灰灰:BAAAKgADCgcIBwAAAA==.',['死靈']='死靈若龍:BAACKgAFFH8GAAIHAAMIAQkmOQCLAAAHAAMIAQkmOQCLAAAqAAQKfxsAAgcACAhtGTYaANQBAAcACAhtGTYaANQBAAAA.',['残月']='残月丶破晓:BAAAKgAECgUIBQAAAA==.',['毛丫']='毛丫:BAACKgAFFH8HAAIFAAMI3QLUPwBpAAAFAAMI3QLUPwBpAAAqAAQKfyUAAgUACAgTCuR0AFUBAAUACAgTCuR0AFUBAAAA.',['水之']='水之加罗温:BAABKgAFFH8NAAQHAAQIzxDLLgCyAAAHAAMIAQ/LLgCyAAAQAAIIrQVFGwBoAAARAAIIAg6MLQBAAAAAAA==.',['水卜']='水卜樱:BAAAKgAFFAQIBAAAAA==.',['水杯']='水杯泡枸杞:BAAAKgAFFAIIAgAAAA==.',['汪汪']='汪汪队:BAAAKgADCggIDwAAAA==.',['沈申']='沈申木:BAABKgAFFH8IAAIYAAgIXwN8CQBAAQAYAAgIXwN8CQBAAQAAAA==.',['沐雨']='沐雨阑珊:BAACKgAFFH8QAAIGAAUI4BGfFADQAAAGAAUI4BGfFADQAAAqAAQKfx4AAxsACAgDDi4vAHIBABsACAgDDi4vAHIBAAYACAglDeMyAA0BAAAA.',['沙砾']='沙砾蚂蚁:BAABKgAFFH8IAAIBAAgIEhraAgB+AgABAAgIEhraAgB+AgAAAA==.',['没有']='没有小尾巴:BAAAKgADCgUIBQAAAA==.',['泉彼']='泉彼方:BAABKgAFFH8HAAIIAAMIPho8CgCzAAAIAAMIPho8CgCzAAAAAA==.',['泰勒']='泰勒斯威芙特:BAAAKgADCgYICwAAAA==.',['泰蘭']='泰蘭德的記憶:BAAAKgADCgQIBAAAAA==.',['泰达']='泰达希尔:BAAAKgAECgYIBgAAAA==.',['流剑']='流剑:BAAAKgAECggIDwAAAA==.',['浅唱']='浅唱依月:BAAAKgAECggICwAAAA==.',['海棠']='海棠丶朵朵:BAABKgAFFH8IAAITAAgIdBdVBwA3AgATAAgIdBdVBwA3AgAAAA==.',['润丨']='润丨之:BAAAKgAFFAMIAwAAAA==.',['涸泽']='涸泽而渔:BAABKgAFFH8IAAIBAAgI6Q2qCQC9AQABAAgI6Q2qCQC9AQAAAA==.',['淡漠']='淡漠三六九:BAAAKgAECgcICwAAAA==.淡漠之间:BAACKgAFFH8RAAIBAAMIRBMEKgDCAAABAAMIRBMEKgDCAAAqAAQKfxUAAwEACAjIF0A8AGQBAAEACAgOFkA8AGQBAAUAAwjcG2+WAJ0AAAAA.淡漠秋云:BAAAKgAFFAMIAwAAAA==.淡漠青风:BAACKgAFFH8KAAIBAAMIahNhKwC9AAABAAMIahNhKwC9AAAqAAQKfxsAAwEACAicHsQSAGMCAAEACAicHsQSAGMCAAUABQiPG1JhADQBAAAA.',['深田']='深田杏璃:BAAAKgAECgQIBAAAAA==.',['清泉']='清泉俊秀:BAAAKgADCggICAAAAA==.',['清清']='清清暮雨:BAAAKgADCgIIAgAAAA==.',['清纯']='清纯男大学生:BAAAKgADCgUIBQAAAA==.',['清醒']='清醒梦境:BAABKgAFFH8KAAIXAAYIIB3/EQANAQAXAAYIIB3/EQANAQAAAA==.',['清风']='清风徐来丶:BAAAKgAECgMIAwAAAA==.',['游佐']='游佐遥:BAAAKgADCggIDwAAAA==.',['游荡']='游荡的熊:BAAAKgAECgYIBgAAAA==.',['滑稽']='滑稽的波波:BAAAKgADCgEIAQAAAA==.',['满穗']='满穗:BAAAKgAECgIIAgAAAA==.',['火鸡']='火鸡面:BAABKgAECn8WAAIhAAYIrhBYJwATAQAhAAYIrhBYJwATAQAAAA==.',['灬龙']='灬龙丨女灬:BAAAKgAFFAQIBAAAAA==.',['灵魂']='灵魂:BAAAKgAECgEIAQAAAA==.灵魂丶狩卫:BAAAKgAECgYIBwAAAA==.',['灵龍']='灵龍心物:BAAAKgAECgIIAgAAAA==.',['烈云']='烈云冰灾:BAAAKgADCggICAAAAA==.',['烟灰']='烟灰灬二呆:BAAAKgAECgIIAgAAAA==.',['熊掌']='熊掌奶酪:BAAAKgAECgcIBwAAAA==.',['熊迪']='熊迪凯:BAAAKgAECgMIAwAAAA==.',['燃烧']='燃烧青春:BAAAKgAECgYICAAAAA==.',['爬爬']='爬爬小样:BAABKgAFFH8GAAIEAAYIrAX7EQA5AQAEAAYIrAX7EQA5AQAAAA==.',['爱丽']='爱丽丝之魂:BAABKgAECn8cAAMWAAgIfBOrSACTAQAWAAgIfBOrSACTAQAVAAcISQc+PwDCAAAAAA==.',['爱到']='爱到飞蛾扑火:BAAAKgAFFAIIAgAAAA==.',['爱吃']='爱吃辣椒的猫:BAAAKgAECgYIBwAAAA==.',['爱宝']='爱宝纱:BAAAKgAECgQIBAABKgAECggIHAAWAHwTAA==.',['爱罗']='爱罗:BAAAKgAFFAIIAwAAAA==.',['牛人']='牛人头猎手:BAAAKgAECgMIAwAAAA==.',['牧彦']='牧彦:BAAAKgADCgQIBAAAAA==.',['狂血']='狂血之战:BAAAKgAECgcICQAAAA==.',['狠黄']='狠黄狠暴力:BAABKgAECn8WAAIXAAgIEhGPeQBeAQAXAAgIEhGPeQBeAQAAAA==.',['狼魂']='狼魂之影:BAACKgAFFH8HAAIXAAMIpxP7TgDRAAAXAAMIpxP7TgDRAAAqAAQKfykABBcACAg1HL+XAGcBABcACAg1HL+XAGcBAA0ABQg6EEgsAPYAAAwABQg2DGA5ALcAAAAA.',['玉树']='玉树樱:BAAAKgAECgEIAQAAAA==.',['玉琪']='玉琪:BAACKgAFFH8WAAITAAYIdQ/GEABcAQATAAYIdQ/GEABcAQAqAAQKfykAAxMACAhIIEIYAHUCABMACAhIIEIYAHUCAAMAAQhOB2l/ACIAAAAA.',['玉米']='玉米:BAABKgAFFH8IAAIXAAgIIiHoBACHAgAXAAgIIiHoBACHAgAAAA==.',['玛拉']='玛拉艾尔:BAACKgAFFH8GAAIfAAYIRCIeBwCpAQAfAAYIRCIeBwCpAQAqAAQKfxUABB8ACAgDDbAvABYBAB8ACAgDDbAvABYBABgABAg1DtRsAJcAACAAAQiJD0yUACwAAAAA.',['玛鄙']='玛鄙里奥恕风:BAABKgAFFH8GAAIDAAYIuwgTCgDxAAADAAYIuwgTCgDxAAAAAA==.',['玩个']='玩个德:BAAAKgAECgUIBQAAAA==.',['玫瑰']='玫瑰灬:BAAAKgADCggICAAAAA==.',['珈百']='珈百璃:BAAAKgAECgMIAwAAAA==.',['琅幽']='琅幽殒:BAAAKgAFFAgIBAAAAA==.',['琻煋']='琻煋:BAABKgAECn8VAAIRAAgI+QtFLQBEAQARAAgI+QtFLQBEAQAAAA==.',['瑕光']='瑕光:BAAAKgAECgYIBgAAAA==.',['璀璨']='璀璨丶星河:BAAAKgADCggIEAABKgAFFAMIBwAYAKAVAA==.',['甩手']='甩手掌柜:BAAAKgAECggICAAAAA==.',['电光']='电光俏臀:BAACKgAFFH8hAAMeAAYIIxUtDQB6AQAeAAYIIxUtDQB6AQAhAAQIMQxiDADqAAAqAAQKfxYAAh4ACAhnDmleAA8BAB4ACAhnDmleAA8BAAAA.',['疯狂']='疯狂大保健:BAAAKgAECgIIBAAAAA==.',['白月']='白月初:BAABKgAFFH8HAAMfAAcI8gYVCwAbAQAfAAYIbAYVCwAbAQAYAAEIIQzvHgBCAAAAAA==.',['白流']='白流苏:BAAAKgAECgcIDAAAAA==.',['白羊']='白羊蓙:BAAAKgADCgEIAQAAAA==.',['白霞']='白霞丨罚:BAAAKgADCggIEAAAAA==.',['皇家']='皇家十三骑士:BAABKgAECn8aAAMXAAYIxx4ggACXAQAXAAYIxx4ggACXAQANAAQIwBDFPwCPAAAAAA==.',['皎月']='皎月丶影舞:BAAAKgADCggICAAAAA==.',['目视']='目视:BAAAKgAECgQIBQAAAA==.',['知音']='知音女记者:BAABKgAECn8aAAIeAAgIhBkFKwDeAQAeAAgIhBkFKwDeAQAAAA==.',['碧雪']='碧雪怜心:BAAAKgAECgcIBwAAAA==.',['神聖']='神聖贊美詩:BAABKgAFFH8OAAQYAAQIfB5PBQAUAQAYAAQIohxPBQAUAQAgAAMI+CRmDwDdAAAfAAEIMiC4IABeAAABKgAFFAgIEAAfAFsKAA==.',['秋之']='秋之魂:BAAAKgAECggIDAAAAA==.',['秘制']='秘制烤鸡翅:BAAAKgAECgMIAwAAAA==.',['童子']='童子功护体:BAAAKgAECgYIBgAAAA==.',['笑红']='笑红尘:BAAAKgADCggICAAAAA==.',['等过']='等过几个秋:BAAAKgAECgUICQAAAA==.',['糖长']='糖长老:BAABKgAFFH8IAAITAAQI5RhzEwDtAAATAAQI5RhzEwDtAAAAAA==.',['索瑞']='索瑞森二世:BAAAKgAFFAIIAgAAAA==.',['紫嫙']='紫嫙玥:BAAAKgAECgMIAwAAAA==.',['紫潆']='紫潆:BAAAKgAECgYIBgAAAA==.',['繁星']='繁星丶春水:BAABKgAFFH8KAAIkAAYIYBqODgB4AQAkAAYIYBqODgB4AQAAAA==.',['红莲']='红莲之矢:BAABKgAFFH8GAAIFAAYI4SKpCQDYAQAFAAYI4SKpCQDYAQAAAA==.',['红雪']='红雪:BAAAKgAECgQIBAAAAA==.',['缘戒']='缘戒:BAAAKgAECgMIAwAAAA==.',['羅波']='羅波特德尼罗:BAAAKgADCggICQAAAA==.',['美丽']='美丽大银刀:BAABKgAFFH8JAAMTAAQIqiB1CgAaAQATAAQIqiB1CgAaAQADAAQImhxuFwDlAAAAAA==.美丽的麻花辫:BAAAKgAECgYIBgAAAA==.',['美食']='美食的俘虏:BAAAKgAECggIDQAAAA==.',['翠花']='翠花花:BAABKgAECn8WAAMNAAgIrAIaRwBgAAANAAgIrAIaRwBgAAAXAAIIlABpVgECAAAAAA==.',['肉苁']='肉苁蓉:BAAAKgAFFAYIBAABKgAFFAgIDQAXAOEYAA==.',['自娱']='自娱自乐:BAAAKgAECgQIBAAAAA==.',['自然']='自然平衡:BAABKgAFFH8OAAMTAAQIwxnlDwD7AAATAAQIwxnlDwD7AAADAAEIngTvJQAyAAAAAA==.',['舒莱']='舒莱曼尼:BAAAKgADCgEIAQAAAA==.',['舞原']='舞原圣:BAAAKgADCggIDgAAAA==.',['良丶']='良丶:BAAAKgAECgEIAQAAAA==.',['艾丽']='艾丽思的假期:BAAAKgAECggICAABKgAFFAgIDgAbANAQAA==.',['艾虂']='艾虂莎:BAAAKgADCggICAAAAA==.',['芙莉']='芙莉莲:BAACKgAFFH8MAAIbAAMIkiFzBgAVAQAbAAMIkiFzBgAVAQAqAAQKfyUAAhsACAj4JQcDAPQCABsACAj4JQcDAPQCAAEqAAUUBggVABUAshUA.',['芝麻']='芝麻牛:BAAAKgAECggIDAAAAA==.',['花晨']='花晨:BAAAKgAECgcIBwAAAA==.',['苦痛']='苦痛冈布奥:BAAAKgADCggICAAAAA==.',['草沐']='草沐灰:BAABKgAECn8YAAIHAAgIlxPeEwBwAQAHAAgIlxPeEwBwAQAAAA==.',['莱戈']='莱戈拉斯绿叶:BAAAKgAECgcIDQAAAA==.',['菈妮']='菈妮的锋刃:BAAAKgAECggIEQAAAA==.',['菌菇']='菌菇:BAAAKgAECgUIBgAAAA==.',['菲菲']='菲菲酱:BAABKgAFFH8KAAITAAQIrR3EDAALAQATAAQIrR3EDAALAQAAAA==.',['萌兽']='萌兽侠:BAAAKgAECgUICwAAAA==.',['萌新']='萌新来啦:BAAAKgAECgIIAgAAAA==.',['萌糖']='萌糖喵:BAAAKgAECgIIAgAAAA==.',['萌萌']='萌萌狼魂:BAAAKgAECgEIAQABKgAFFAMIBQAYAFYSAA==.',['萝莉']='萝莉的时间:BAAAKgAECggIEQAAAA==.',['落入']='落入凡间精灵:BAAAKgAFFAYIBAAAAA==.',['落樱']='落樱丶飘雪:BAAAKgADCgQIBAAAAA==.',['落红']='落红尘:BAAAKgAFFAgIAwAAAA==.',['葉無']='葉無:BAAAKgADCggICAAAAA==.',['蒂蕾']='蒂蕾劳牧:BAAAKgADCgEIAQAAAA==.',['蕾丝']='蕾丝花边儿控:BAAAKgAECgYIBgAAAA==.',['薄荷']='薄荷味切糕:BAAAKgAECgYIDwAAAA==.',['螺丝']='螺丝刀:BAAAKgADCgcIBwAAAA==.',['血兰']='血兰:BAAAKgAECgUIDgABKgAFFAMIBwAYAKAVAA==.',['血骑']='血骑部落:BAAAKgAECgIIAgAAAA==.',['褆渤']='褆渤斯:BAAAKgADCgUIBQAAAA==.',['西瓜']='西瓜皮:BAAAKgAECgQICAAAAA==.',['詩尐']='詩尐枫:BAAAKgAECgYIBQAAAA==.',['训练']='训练有素医生:BAABKgAECn8UAAMlAAgIHRbNCACxAQAlAAcI3xfNCACxAQALAAEIkAs/SQAtAAAAAA==.',['说好']='说好的人头呢:BAAAKgAFFAQIAwAAAA==.',['诺风']='诺风:BAABKgAFFH8IAAIUAAgI8gzBCADrAQAUAAgI8gzBCADrAQAAAA==.',['谷灬']='谷灬巴比伦:BAAAKgAECgIIAgAAAA==.',['豆腐']='豆腐丨表弟:BAAAKgAECgQIBAAAAA==.豆腐姐姐:BAACKgAFFH8HAAIeAAMIIhFiIgCPAAAeAAMIIhFiIgCPAAAqAAQKf0QAAx4ACAifHowVAFMCAB4ACAifHowVAFMCABkABwiFE749ABYBAAAA.豆腐脑别加糖:BAAAKgAECgIIAgAAAA==.',['贝儿']='贝儿的姐姐:BAAAKgAECgEIAQAAAA==.',['责任']='责任感:BAAAKgAECgEIAQAAAA==.',['超壮']='超壮的大鱼:BAAAKgAECgIIAgAAAA==.',['超神']='超神的切糕:BAAAKgAECgUICAAAAA==.',['路曦']='路曦法:BAACKgAFFH8FAAICAAIIYxC7FACLAAACAAIIYxC7FACLAAAqAAQKfzgAAwIACAiEHwcQAIACAAIACAiEHwcQAIACABQAAwhDEUoxAKIAAAAA.',['车幺']='车幺妹儿:BAAAKgAFFAMIAwAAAA==.',['轶璐']='轶璐相随:BAAAKgAECgMIAwAAAA==.',['辛达']='辛达狗萨:BAABKgAFFH8LAAIkAAYINRojDwBuAQAkAAYINRojDwBuAQABKgAFFAgICAAZAEwYAA==.',['迅影']='迅影贼:BAAAKgAECgUIBgAAAA==.',['这个']='这个圣骑:BAABKgAFFH8FAAIXAAUIMRalMAAmAQAXAAUIMRalMAAmAQAAAA==.',['迪丽']='迪丽冷九:BAAAKgAECgYIBgAAAA==.',['迪克']='迪克小妹:BAACKgAFFH8FAAIWAAMIVAkiQACdAAAWAAMIVAkiQACdAAAqAAQKfxUAAhYACAjpF/E1ANkBABYACAjpF/E1ANkBAAAA.',['遨游']='遨游天际:BAAAKgAECgUICAAAAA==.',['邋遢']='邋遢的小满:BAAAKgAECggICwAAAA==.',['邓紫']='邓紫棋:BAACKgAFFH8RAAMlAAQIrQ88AwAGAQAlAAQIrQ88AwAGAQAmAAMIIgicCQDXAAAqAAQKfzUAAyUACAiXIYkCAJ8CACUACAiXIYkCAJ8CACYACAg0FfoQANwBAAAA.',['那年']='那年没咖啡:BAACKgAFFH8rAAIEAAgIiBSVCgCiAQAEAAgIiBSVCgCiAQAqAAQKfzwAAgQACAhGHqoUADICAAQACAhGHqoUADICAAAA.',['酒酿']='酒酿的贼人:BAABKgAFFH8IAAILAAgIIBi3BABPAgALAAgIIBi3BABPAgAAAA==.',['醉红']='醉红颜:BAAAKgAFFAQIBAAAAA==.',['采菱']='采菱渡头风急:BAAAKgAFFAIIAgABKgAFFAgICgAXAK0lAA==.',['野兽']='野兽追猎者:BAACKgAFFH8HAAIiAAMIXBBDAgCiAAAiAAMIXBBDAgCiAAAqAAQKfxwAAiIACAjCFWAIALsBACIACAjCFWAIALsBAAAA.',['钟無']='钟無艳:BAAAKgAECgMIBwAAAA==.',['钢神']='钢神柱:BAABKgAECn8XAAIWAAgIMQj2YQD4AAAWAAgIMQj2YQD4AAAAAA==.',['钵兰']='钵兰街阿劲:BAAAKgAFFAQIBAAAAA==.',['铠甲']='铠甲下的戏谑:BAAAKgAECgYIBgAAAA==.',['银鞍']='银鞍照白馬丶:BAABKgAFFH8IAAITAAgItQT9DgCBAQATAAgItQT9DgCBAQAAAA==.',['闪刀']='闪刀姬露世:BAAAKgAFFAYIBAAAAA==.',['阳光']='阳光丽影:BAAAKgAFFAYIAgAAAA==.',['阿包']='阿包:BAAAKgAECgUIBQAAAA==.',['阿奎']='阿奎利亚斯:BAABKgAECn8hAAIFAAgINhmJRwCKAQAFAAgINhmJRwCKAQAAAA==.',['阿波']='阿波尼亚:BAAAKgAECgcIDQAAAA==.',['阿牛']='阿牛哥:BAAAKgAFFAMIAwAAAA==.',['阿诺']='阿诺德莱西:BAAAKgADCgEIAQAAAA==.',['陈式']='陈式灬门徒:BAAAKgAECggICAAAAA==.',['雨中']='雨中忆孤影:BAAAKgAECgYIEAAAAA==.雨中的苦行僧:BAAAKgAFFAgIBAAAAA==.',['雪中']='雪中送炭:BAAAKgADCggICAAAAA==.',['雪百']='雪百合:BAAAKgAECgYIBgABKgAFFAMIBwAYAKAVAA==.',['雾桜']='雾桜:BAAAKgAFFAEIAQABKgAFFAgICwAGANEeAA==.',['霍青']='霍青思:BAAAKgADCgYIBgAAAA==.',['霜序']='霜序丶小葱:BAAAKgADCgEIAQAAAA==.',['靈龍']='靈龍心物:BAAAKgADCgIIAgAAAA==.',['靑樓']='靑樓夢:BAAAKgAFFAMIBAAAAA==.',['風刄']='風刄飃雪:BAAAKgAECgIIAgAAAA==.',['风一']='风一样的老头:BAAAKgADCgEIAQAAAA==.',['风之']='风之兰斯塔:BAAAKgAECgYIBgAAAA==.',['风云']='风云十三:BAAAKgADCgMIAwAAAA==.',['风和']='风和辉光:BAACKgAFFH8NAAQXAAYI4Ri9SwDXAAAXAAQILRy9SwDXAAANAAYIDA26DwCEAAAMAAEIDgyqFQA9AAAqAAQKfxkAAgwACAi+CRgkAD4BAAwACAi+CRgkAD4BAAAA.',['风火']='风火电掣:BAAAKgAECgUIBQAAAA==.',['风禾']='风禾:BAAAKgADCgEIAQAAAA==.',['风舞']='风舞湮灭:BAAAKgADCggICAAAAA==.',['风若']='风若渡:BAAAKgADCggICAAAAA==.',['飒格']='飒格拉斯:BAAAKgAFFAQIBAAAAA==.',['飞翔']='飞翔灬:BAAAKgAFFAMIAwAAAA==.',['香吉']='香吉:BAAAKgAECgQIBAAAAA==.',['香飘']='香飘票风:BAAAKgAECgcIDwAAAA==.',['馮玉']='馮玉祥:BAAAKgADCggICAAAAA==.',['驴肉']='驴肉火烧:BAAAKgAECggICAAAAA==.',['骑术']='骑术不精:BAAAKgAECgUICAAAAA==.',['骨肉']='骨肉香莲:BAAAKgAECggICAAAAA==.',['高义']='高义:BAAAKgAECgYIBwAAAA==.',['高尔']='高尔基:BAACKgAFFH8tAAIJAAgICR83BgBIAgAJAAgICR83BgBIAgAqAAQKfx0AAgkACAjZHXokACoCAAkACAjZHXokACoCAAAA.',['魂归']='魂归悲风丶:BAABKgAECn8eAAQLAAgI6iFZCACGAgALAAgI6iFZCACGAgAmAAYI2RZOHQAzAQAlAAIIHhgIFwCOAAABKgAFFAgIEwALAC0cAA==.',['魂狩']='魂狩:BAAAKgAFFAQIBAAAAA==.',['魂猎']='魂猎:BAAAKgAFFAQIBAAAAA==.',['魔猎']='魔猎:BAAAKgAECgQIBAAAAA==.',['魚儿']='魚儿游:BAABKgAFFH8QAAMeAAUI5xmvGQAZAQAeAAUI5xmvGQAZAQAZAAQILRxnDwDrAAAAAA==.',['鱼叉']='鱼叉打鸡:BAAAKgADCggICAAAAA==.',['鱼尔']='鱼尔萨斯:BAABKgAFFH8IAAMVAAgIZgAaKwBpAAAVAAMIlwAaKwBpAAAWAAUIQgCOVgAxAAAAAA==.',['麦兜']='麦兜响当当:BAAAKgAECgYICAAAAA==.',['黄泉']='黄泉木:BAABKgAECn8XAAIYAAcIzA/4QwADAQAYAAcIzA/4QwADAQAAAA==.',['黑木']='黑木儿:BAAAKgAECgEIAQABKgAFFAMIBwAYAKAVAA==.',['黑色']='黑色妹:BAAAKgAECgQIBAAAAA==.',['黯然']='黯然缥缈:BAAAKgADCgUIBQAAAA==.',['龍児']='龍児:BAAAKgAECgIIAgAAAA==.',['龍魂']='龍魂弱水叁仟:BAAAKgAFFAQIBAAAAA==.',['龙卷']='龙卷風:BAAAKgAECgUIBwAAAA==.',['龙形']='龙形态爬爬:BAABKgAFFH8KAAMkAAYIjxI6EwA4AQAkAAYIjxI6EwA4AQAnAAQI0wocBQC9AAAAAA==.',['龙霸']='龙霸天:BAAAKgAECggIEAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end