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
 local lookup = {'Priest-Holy','Priest-Shadow','Shaman-Restoration','DeathKnight-Frost','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Retribution','Warrior-Fury','Warrior-Protection','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Shaman-Elemental','Paladin-Protection','Mage-Frost','Unknown-Unknown','Rogue-Assassination','Warlock-Destruction','Paladin-Holy','Druid-Restoration','Mage-Arcane','Druid-Guardian','Monk-Mistweaver','Monk-Brewmaster','Monk-Windwalker','Druid-Feral','Druid-Balance','Hunter-Survival','Evoker-Devastation','Warlock-Demonology','Rogue-Subtlety','Evoker-Preservation','Shaman-Enhancement','Warrior-Arms','Evoker-Augmentation','Rogue-Outlaw',}; local provider = {region='CN',realm='耐奥祖',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Always:BAACLAAFFH8HAAMBAAMIJQfYIAC6AAABAAMIJQfYIAC6AAACAAEIiQmgLgA4AAAsAAQKfxYAAwEABghEEIxsADUBAAEABghEEIxsADUBAAIABgjyC7tjACoBAAAA.',An='Anyway:BAABLAAFFH8GAAIDAAIIMxLxXQBfAAADAAIIMxLxXQBfAAAAAA==.',Ao='Aoao:BAABLAAFFH8KAAIBAAII1wt8PwBrAAABAAII1wt8PwBrAAAAAA==.',Ba='Bauklotze:BAABLAAFFH8IAAIEAAII0xDyjgA/AAAEAAII0xDyjgA/AAAAAA==.',Bl='Blackpearl:BAAALAAECggICAAAAA==.Bloodborne:BAAALAAECggICAAAAA==.',Ce='Cellvirus:BAABLAAFFH8HAAIFAAMI+A9MQwB9AAAFAAMI+A9MQwB9AAAAAA==.',Cl='Clara:BAABLAAECn8eAAIBAAYImhI/XABqAQABAAYImhI/XABqAQAAAA==.',Co='Constence:BAAALAAECgUICAAAAA==.',Cy='Cynthia:BAAALAAECggICAAAAA==.',Di='Dierwo:BAAALAAFFAIIAgAAAA==.',Fo='Forestben:BAAALAAECgMIAwAAAA==.',Fu='Furyxwolf:BAAALAAFFAIIAgAAAA==.',Ga='Gallagher:BAABLAAFFH8HAAIGAAMICAlODgBZAAAGAAMICAlODgBZAAAAAA==.',Gr='Grandpa:BAAALAAECgMIBgAAAA==.',Ha='Haohaa:BAACLAAFFH8YAAQHAAUIeRn0BwDuAAAEAAUIeRlzPwA9AQAHAAMIXRH0BwDuAAAIAAMIKxH8FAB0AAAsAAQKfyEAAwQABwhEIxp6AAQCAAQABQi1Ixp6AAQCAAcABAiNH6osAF4BAAAA.',Hd='Hdeyz:BAACLAAFFH8xAAIEAAYINiM0EwD2AQAEAAYINiM0EwD2AQAsAAQKfzYAAgQACAjfJFEOADoDAAQACAjfJFEOADoDAAAA.Hdyz:BAABLAAFFH8FAAIJAAMIcROTRACGAAAJAAMIcROTRACGAAAAAA==.',Hg='Hgsusan:BAAALAAECgQIBQAAAA==.',Ia='Iamabyss:BAAALAAECgUIBQAAAA==.Iamchosen:BAABLAAFFH8LAAICAAMIygwcFQDWAAACAAMIygwcFQDWAAAAAA==.',Im='Imnoone:BAAALAAFFAEIAQAAAA==.',In='Insecter:BAAALAAECgIIAgAAAA==.Insomniaa:BAAALAAECgIIAgAAAA==.Invincible:BAAALAAECgQIBAAAAA==.',Kb='Kboardroller:BAAALAAECgYIBwAAAA==.',La='Lain:BAAALAAECgYIDAAAAA==.Lakoo:BAAALAAECgYIBgAAAA==.Lamoo:BAAALAAECgEIAQAAAA==.',Li='Liliana:BAAALAAECgcIBwAAAA==.',Lo='Lottery:BAAALAAFFAIIBAAAAA==.',Mi='Minotaurs:BAAALAAECgQIBgABLAAFFAgIIAAKAN8dAA==.',Mo='Monikamt:BAABLAAFFH8JAAILAAYIaBVGEABKAQALAAYIaBVGEABKAQAAAA==.',Ni='Nicebody:BAAALAAECgYIBgAAAA==.',Po='Pogacar:BAAALAAECgYIBwAAAA==.',Re='Reachel:BAAALAAFFAIIAgAAAA==.',Ro='Rockman:BAAALAAECgQIBAAAAA==.Rolex:BAAALAAECgEIAQAAAA==.',Sa='Sapagaagonie:BAACLAAFFH89AAIKAAcIcRm/CgAKAgAKAAcIcRm/CgAKAgAsAAQKfyUAAgoACAj2HsQiALwCAAoACAj2HsQiALwCAAAA.',Sc='Scarlett:BAABLAAFFH8JAAMFAAMIoxLQMQCmAAAFAAMIoxLQMQCmAAAGAAIIfBEkEAB1AAABLAAFFAYIFgAFAFkcAA==.',Sl='Sloggi:BAAALAADCgcIBwAAAA==.',Sp='Springtime:BAAALAADCggICAAAAA==.',Sy='Sylvan:BAABLAAFFH8qAAIFAAYIKhytEgDMAQAFAAYIKhytEgDMAQAAAA==.Sylvane:BAAALAAFFAIIAwABLAAFFAYIKgAFACocAA==.',To='Topss:BAAALAAECgYIBgAAAA==.',Va='Vanéssa:BAABLAAFFH8GAAIFAAIIdxKsPQCbAAAFAAIIdxKsPQCbAAABLAAFFAYIKgAFACocAA==.',Vi='Vitam:BAAALAAFFAEIAQAAAA==.Vitaminvc:BAAALAAECgYIEQAAAA==.',Wt='Wtyandly:BAAALAAFFAIIAgAAAA==.',Za='Zandalarw:BAAALAAECgEIAQAAAA==.',Zi='Ziyuzile:BAACLAAFFH8vAAIMAAcIsxwKDgDCAQAMAAcIsxwKDgDCAQAsAAQKfycAAwwACAgQJb8kAMUCAAwACAgQJb8kAMUCAA0AAQjiE6K6ADoAAAAA.',['一夜']='一夜知秋:BAAALAAECgUIBQAAAA==.',['一布']='一布衣神相一:BAABLAAFFH8KAAIOAAIIOBZHBACEAAAOAAIIOBZHBACEAAAAAA==.',['一满']='一满满一:BAAALAADCgYICgAAAA==.',['一熊']='一熊大一:BAAALAAECgUIBQAAAA==.',['一爷']='一爷叔一:BAAALAAECgQIBAAAAA==.',['一脚']='一脚踩死你:BAABLAAFFH8GAAIDAAIIYwkmXgBhAAADAAIIYwkmXgBhAAAAAA==.',['一路']='一路天黑:BAABLAAFFH8PAAIPAAYIHB9iEQCzAQAPAAYIHB9iEQCzAQAAAA==.',['上古']='上古神经:BAAALAADCgEIAQAAAA==.',['下午']='下午凉茶:BAAALAAECgYICQAAAA==.',['不嘻']='不嘻嘻弗斯:BAACLAAFFH8jAAIPAAYITxQiGQB1AQAPAAYITxQiGQB1AQAsAAQKfyUAAg8ABwhbIikfAKsCAA8ABwhbIikfAKsCAAAA.',['东山']='东山兽爷:BAAALAAECgYIBgAAAA==.',['丢了']='丢了个橙:BAAALAAECgIIAgAAAA==.',['丢小']='丢小狐:BAAALAAFFAEIAQAAAA==.丢小龙:BAAALAAFFAEIAQAAAA==.',['丢那']='丢那咩鸡鳖:BAAALAAECgUIBQAAAA==.',['丨亡']='丨亡命灬丨:BAACLAAFFH8VAAIPAAcIvxvvDgDLAQAPAAcIvxvvDgDLAQAsAAQKfysAAg8ACAjTJUUDAO8CAA8ACAjTJUUDAO8CAAAA.',['丨客']='丨客心丨:BAAALAAECgYICgAAAA==.',['丨皮']='丨皮鞋擦亮灬:BAAALAAECgMIAwAAAA==.',['丨陛']='丨陛灬下丨:BAAALAAECgcIEQAAAA==.',['中年']='中年大叔:BAAALAADCgUIBQAAAA==.',['丶不']='丶不忘:BAAALAAECgMIAwAAAA==.',['丶钱']='丶钱多多:BAABLAAFFH8uAAIEAAYILyYgDAA6AgAEAAYILyYgDAA6AgABLAAFFAYINgAJAFkmAA==.',['丶青']='丶青汁丶:BAACLAAFFH8HAAIJAAIIlQ0rWABLAAAJAAIIlQ0rWABLAAAsAAQKfxYAAwkABggLG9pKAHwBAAkABgghGtpKAHwBABAAAQi4GiVyAEUAAAAA.',['为你']='为你执着:BAAALAAECggICAAAAA==.',['为啥']='为啥要我改名:BAABLAAFFH8HAAIRAAIICBqZFQBEAAARAAIICBqZFQBEAAAAAA==.',['举杯']='举杯吧朋友:BAABLAAFFH8GAAMJAAIINxfCYABGAAAJAAIINxfCYABGAAAQAAIIswo7IAArAAAAAA==.',['丿灬']='丿灬十年饮冰:BAAALAAFFAMIBAAAAA==.',['乔巴']='乔巴不五:BAAALAADCgYICgAAAA==.',['乾坤']='乾坤道长:BAAALAAECgEIAQAAAA==.',['了無']='了無所愛:BAAALAAFFAIIAgAAAA==.',['事业']='事业上上签:BAAALAADCgMIAwAAAA==.',['五丶']='五丶花肉:BAAALAAECgYIDQAAAA==.',['他避']='他避我锋芒:BAAALAAFFAEIAQAAAA==.',['付哥']='付哥哥哟:BAAALAADCgEIAQAAAA==.',['伊娃']='伊娃丶翠瞳:BAAALAADCggICAAAAA==.',['伊粒']='伊粒蛋:BAABLAAFFH8GAAIGAAYI8wvhBwDuAAAGAAYI8wvhBwDuAAAAAA==.',['伊莎']='伊莎贝莉:BAAALAADCgUICAAAAA==.',['伏梅']='伏梅轩:BAAALAADCgYIBgAAAA==.',['何似']='何似在人间:BAABLAAFFH8IAAIBAAIIyRNWOgB2AAABAAIIyRNWOgB2AAAAAA==.',['你壹']='你壹贱我壹箭:BAAALAAECgEIAQAAAA==.',['你好']='你好丶旅行者:BAAALAAECggICAAAAA==.你好帅:BAAALAAFFAIIAgABLAAFFAIIBAASAAAAAA==.你好美啊:BAABLAAFFH8GAAITAAIImhPSFwBZAAATAAIImhPSFwBZAAAAAA==.',['你看']='你看我硬不:BAAALAAFFAIIBAAAAA==.',['佰花']='佰花齐放:BAAALAADCgYIBgAAAA==.',['依然']='依然笑笑:BAAALAAFFAIIAgAAAA==.',['信圣']='信圣光不长虱:BAAALAAFFAIIBAAAAA==.',['俺没']='俺没得青光眼:BAABLAAFFH8IAAIEAAII4w6seQCLAAAEAAII4w6seQCLAAAAAA==.',['偷袭']='偷袭的小宋:BAAALAADCggICAAAAA==.',['傲气']='傲气领牛:BAAALAAFFAIIBAAAAA==.',['傷心']='傷心小栈:BAACLAAFFH8hAAMQAAUIbwyLDQCsAAAQAAUIywSLDQCsAAAJAAMIUBJ4QgCNAAAsAAQKfyIAAwkABwhZFx+LANkBAAkABwhZFx+LANkBABAABwhYBw9JAA0BAAAA.',['元素']='元素馒头:BAAALAAECgYICQAAAA==.',['光头']='光头才有杀气:BAAALAAECggIDQAAAA==.',['兜兕']='兜兕宫主:BAABLAAFFH8XAAIPAAUImBslHQBXAQAPAAUImBslHQBXAQAAAA==.',['全球']='全球打击:BAAALAAECgIIAgAAAA==.',['八七']='八七五回蓝:BAAALAAECgYIBgAAAA==.',['八头']='八头锅:BAAALAAECgYIDAAAAA==.',['八尺']='八尺:BAAALAADCgUIBQAAAA==.',['兽族']='兽族的意志:BAABLAAFFH8FAAIEAAII9QrZjQA/AAAEAAII9QrZjQA/AAAAAA==.',['冥花']='冥花有註:BAABLAAFFH8LAAIMAAYItB+0FwDaAQAMAAYItB+0FwDaAQAAAA==.',['冰丶']='冰丶:BAAALAAECgUICAAAAA==.',['冰峰']='冰峰之巅:BAAALAAFFAIIAgAAAA==.',['冰霜']='冰霜射手:BAAALAAECgQIBAAAAA==.',['冲灬']='冲灬干灬搞:BAABLAAFFH8FAAIKAAMI4xcTGQD+AAAKAAMI4xcTGQD+AAAAAA==.',['冲跳']='冲跳两年半:BAAALAAECgcIBwAAAA==.',['冷月']='冷月:BAACLAAFFH8JAAIUAAMIAQhULQDPAAAUAAMIAQhULQDPAAAsAAQKfxgAAhQACAgADX1oALoBABQACAgADX1oALoBAAAA.',['冷灬']='冷灬楓:BAAALAAECggICAAAAA==.',['准提']='准提道人:BAACLAAFFH84AAMQAAYI/xfABgBjAQAQAAYI/xfABgBjAQAJAAMI8heHPQCdAAAsAAQKf0MAAxAACAj1IeQGAD8CABAACAigIeQGAD8CAAkABgjSGg2wAJ8BAAAA.',['凤朝']='凤朝阳:BAABLAAFFH8NAAMVAAYIZRsQAwAdAgAVAAYIZRsQAwAdAgAJAAIIfBS/OQCjAAABLAAFFAgIDAAVAKUUAA==.',['凯瑞']='凯瑞斯:BAAALAADCggICAAAAA==.',['删灬']='删灬除:BAAALAAFFAIIAgAAAA==.',['删除']='删除灬灬:BAAALAAFFAIIAgAAAA==.',['刹古']='刹古拉:BAACLAAFFH8FAAIJAAMIlw7INADbAAAJAAMIlw7INADbAAAsAAQKfyQAAgkABghOHzZwAAkCAAkABghOHzZwAAkCAAAA.',['削着']='削着苹果走:BAAALAAECgUICQAAAA==.',['剑指']='剑指脚尖:BAAALAAECgYIBgAAAA==.',['劝君']='劝君酌:BAAALAAECggICAAAAA==.',['加拿']='加拿大电鳗:BAAALAAECgUIBQAAAA==.',['加里']='加里:BAABLAAFFH8GAAIGAAIIggyEFgApAAAGAAIIggyEFgApAAAAAA==.',['助祭']='助祭:BAAALAADCggICAAAAA==.',['勇敢']='勇敢的甜甜:BAAALAAFFAQIBAABLAAFFAgIBwAKAEIWAA==.勇敢者之心:BAAALAAECgYICwAAAA==.',['包小']='包小鱼:BAAALAAECgYIDAAAAA==.',['医生']='医生:BAABLAAECn8UAAMDAAYIWBUQOwBvAQADAAYIWBUQOwBvAQAPAAYIywzGfABKAQAAAA==.',['医翻']='医翻都流口水:BAAALAAECgcIBwAAAA==.',['十手']='十手奶萨:BAAALAAECggICAAAAA==.',['十殿']='十殿丨猎手:BAAALAADCgMIAwAAAA==.',['千枼']='千枼传奇:BAACLAAFFH8GAAIMAAIIyw7rmwBAAAAMAAIIyw7rmwBAAAAsAAQKfxcAAgwACAi1HZ8oALUCAAwACAi1HZ8oALUCAAAA.',['千流']='千流羽:BAAALAADCgMIAwAAAA==.',['千鸟']='千鸟守护神:BAAALAAECgcIDgAAAA==.',['午夜']='午夜幽光:BAABLAAFFH8GAAIWAAIIUBWJKgCDAAAWAAIIUBWJKgCDAAAAAA==.',['南城']='南城旧少年:BAAALAAFFAIIBAAAAA==.',['卡夫']='卡夫趣多多:BAAALAAECggIDgAAAA==.',['历飞']='历飞羽:BAAALAAECgYIBgAAAA==.',['原始']='原始的欲望:BAAALAAFFAIIAgAAAA==.',['去打']='去打那个老虎:BAAALAAECgIIAgAAAA==.',['又见']='又见鲜血:BAAALAAECgIIBAAAAA==.',['叉烧']='叉烧啾啾:BAACLAAFFH8MAAMRAAUIGh41DwCSAAAXAAUIGh5dMgA3AQARAAIIdhg1DwCSAAAsAAQKfx0AAxEABghdJScVAHMCABEABghdJScVAHMCABcABQjdG4Z9AJgBAAAA.叉烧行星:BAAALAAECgYIDQAAAA==.',['发条']='发条骑士:BAAALAADCggIBAAAAA==.',['口少']='口少口少:BAACLAAFFH81AAIYAAYIsxDHAQAeAQAYAAYIsxDHAQAeAQAsAAQKfzkAAhgACAgnFxMQANoBABgACAgnFxMQANoBAAAA.',['叫我']='叫我小陀螺:BAAALAADCggICAAAAA==.',['可乐']='可乐尾:BAAALAAECgcIBwAAAA==.',['名字']='名字真棒:BAAALAADCgcIBwABLAAECgYICQASAAAAAA==.',['后羿']='后羿:BAAALAAFFAIIBAAAAA==.后羿丶:BAAALAAECgMIAwAAAA==.',['向左']='向左走:BAAALAADCgYIBgAAAA==.',['吨吨']='吨吨噸:BAACLAAFFH8HAAMZAAIIAgyUFgBnAAAZAAIIAgyUFgBnAAAaAAIIbQKYIwAkAAAsAAQKfxgABBkABgiQFUwXADABABkABQgZFUwXADABABoABghWBgIcAKcAABsABgjHDV1aAIkAAAAA.',['呀奕']='呀奕啊:BAAALAADCggICAAAAA==.',['呀忽']='呀忽忽:BAAALAAECgMIAwAAAA==.',['呜喵']='呜喵王:BAAALAAECgYICgAAAA==.',['咕了']='咕了个咕:BAAALAAECgYIBgAAAA==.',['咕咕']='咕咕馒头:BAAALAAECgYIDAAAAA==.',['咖啡']='咖啡丶玫瑰:BAACLAAFFH8JAAICAAMI0RiIEQD8AAACAAMI0RiIEQD8AAAsAAQKfyIABAIABwhlIbQcAIoCAAIABwhlIbQcAIoCAAEABQjhDmqDAPcAAA4AAQjOErw8ADcAAAAA.咖啡喵:BAAALAADCgYIBgAAAA==.',['咚大']='咚大一鸭梨:BAACLAAFFH8SAAMMAAYImxQMNQBoAQAMAAYImxQMNQBoAQANAAIIwQgoLQBrAAAsAAQKfx0AAwwABggBIF9hAIABAAwABggBIF9hAIABAA0ABghOBW6OAK0AAAAA.',['咯咯']='咯咯哒征服者:BAAALAAFFAIIAgAAAA==.',['哈斯']='哈斯加特:BAABLAAFFH8KAAIDAAIIFhRUUgB2AAADAAIIFhRUUgB2AAAAAA==.',['哎呦']='哎呦好小:BAAALAADCgYIBgAAAA==.',['哞哞']='哞哞酿子:BAAALAAECgYIBgAAAA==.',['哞喵']='哞喵:BAABLAAFFH8NAAQWAAIIrhMNRABnAAAWAAIIrhMNRABnAAAYAAEI+wZZEAAkAAAcAAEICgZiEwAAAAAAAA==.哞喵完了:BAABLAAFFH8IAAMIAAII3QhLHQAsAAAEAAIIWQa5pAAwAAAIAAII3QhLHQAsAAAAAA==.',['唸丶']='唸丶:BAAALAAECggICAAAAA==.',['啊蕉']='啊蕉老师:BAAALAAFFAIIAgAAAA==.',['喀吐']='喀吐:BAAALAAECgEIAQAAAA==.',['喧茗']='喧茗:BAAALAAFFAEIAQAAAA==.',['喵星']='喵星渔:BAABLAAFFH8SAAMXAAMIdxZoQQCgAAAXAAMIHBZoQQCgAAARAAEIchdFHgBJAAAAAA==.',['嗜魂']='嗜魂飚颲:BAAALAAFFAIIBAAAAA==.',['嘟嘟']='嘟嘟:BAAALAAFFAIIAgAAAA==.',['嘣噔']='嘣噔你个嘣噔:BAAALAAECgEIAQAAAA==.',['噬魂']='噬魂羛弑鉮:BAAALAADCgMIAwAAAA==.',['四系']='四系飞舞炮灰:BAACLAAFFH8NAAMdAAMIcxgIEQDoAAAdAAMIcxgIEQDoAAAWAAIIDwvhOgBlAAAsAAQKfxYABB0ACAheGF8uAAkCAB0ABwi1Gl8uAAkCABYAAwjrCk7FAHsAABgAAQiEA7EsABsAAAAA.',['国色']='国色:BAAALAAECgIIAgAAAA==.',['土豆']='土豆丝:BAAALAADCgYIBgAAAA==.',['圣光']='圣光女骑士:BAAALAAECgMIAwAAAA==.',['圣骑']='圣骑与菊魔:BAABLAAECn8cAAMQAAcIpxzfJgDLAQAJAAYIDBwPkgDOAQAQAAcIKRffJgDLAQAAAA==.',['地狱']='地狱大酋长:BAAALAAECgYICAAAAA==.地狱守望使者:BAAALAADCggIAgAAAA==.',['坏蛋']='坏蛋馒头:BAAALAAECgQIBAAAAA==.',['埋女']='埋女孩的火柴:BAAALAADCggICAAAAA==.',['基里']='基里安姆巴佩:BAAALAAFFAMIAwAAAA==.',['塞拉']='塞拉赞恩:BAAALAAECggICAABLAAFFAgILAAUAJ4lAA==.',['境泽']='境泽言香:BAAALAADCgIIAgAAAA==.',['夏莉']='夏莉:BAAALAAECgEIAQAAAA==.',['外太']='外太空滴星星:BAAALAAFFAIIAgAAAA==.',['夜丶']='夜丶烛:BAAALAAECgQIBAAAAA==.',['夜幕']='夜幕刀贼:BAAALAAECggICAAAAA==.',['夜影']='夜影:BAAALAADCgYIBgAAAA==.',['夜里']='夜里夫假面:BAAALAAECgYICAAAAA==.',['大付']='大付刺客:BAAALAAECgMIAwAAAA==.大付哟:BAAALAAFFAIIBAAAAA==.大付战:BAAALAAECgIIAgABLAAFFAIIBAASAAAAAA==.',['大地']='大地之环:BAAALAAECgYICQAAAA==.',['大美']='大美美:BAAALAAECgYIBgAAAA==.',['大道']='大道不器:BAABLAAFFH8GAAIBAAIIiAxePwBrAAABAAIIiAxePwBrAAAAAA==.',['大龙']='大龙神佐德:BAAALAAECgQIBAAAAA==.',['天地']='天地血魔:BAAALAAECgQIBAAAAA==.',['天堂']='天堂咆哮:BAAALAADCgYIBgAAAA==.',['天棒']='天棒:BAABLAAFFH8FAAILAAUISBaVFAAZAQALAAUISBaVFAAZAQAAAA==.',['天涯']='天涯无命:BAAALAAECgYICwAAAA==.',['天災']='天災怨靈:BAAALAADCggIBgAAAA==.',['天真']='天真萌萌姐:BAAALAAECgYICQAAAA==.',['天者']='天者一一怒风:BAAALAAECgIIAgAAAA==.',['天萌']='天萌真真姐:BAAALAAECgYIDAAAAA==.',['奇异']='奇异博士:BAAALAAECgUIBgAAAA==.',['奥丁']='奥丁死亡之翼:BAAALAAECgYIBwAAAA==.',['奶桶']='奶桶傻馒:BAABLAAFFH8FAAIDAAIIYwgbbQBOAAADAAIIYwgbbQBOAAAAAA==.',['奶茶']='奶茶喵:BAAALAADCgEIAQAAAA==.',['好臭']='好臭好臭:BAAALAAECgIIAgAAAA==.',['好运']='好运小锦鲤:BAAALAADCgUIBQAAAA==.',['妮可']='妮可拉基芭岛:BAABLAAFFH8GAAIFAAIIrhe2SACTAAAFAAIIrhe2SACTAAAAAA==.',['孙半']='孙半城:BAACLAAFFH8KAAMJAAIIsgNiXgB+AAAJAAIIsgNiXgB+AAAVAAIIUhW/JAB8AAAsAAQKfxgABBUABghXFCc6AHoBABUABghXFCc6AHoBAAkABQhSED75ADUBABAAAQjLHkhsAFoAAAEsAAUUBggWAAUAWRwA.',['孙门']='孙门弄换:BAABLAAFFH8MAAMHAAIIRhoADgClAAAHAAIIVRgADgClAAAIAAII4QpoEwBxAAABLAAFFAYIFgAFAFkcAA==.',['孡凰']='孡凰:BAAALAADCgcIBwAAAA==.',['孤寂']='孤寂星火:BAAALAAECgYIDQAAAA==.',['孤翰']='孤翰念钦:BAAALAADCgMIAwAAAA==.',['家有']='家有捍妻:BAAALAAECgIIAgAAAA==.',['寒树']='寒树栖鸦:BAAALAAECggIAgAAAA==.',['寒風']='寒風飄零:BAAALAAECgYIBgAAAA==.',['寒风']='寒风依依:BAAALAAECgIIAgAAAA==.',['尋花']='尋花問柳:BAAALAAECgYIEQAAAA==.',['小小']='小小丶:BAAALAADCgEIAQAAAA==.小小丶三号机:BAABLAAFFH8OAAIMAAcI6RbrIACuAQAMAAcI6RbrIACuAQABLAAFFAgIIgAMACUeAA==.小小丶二号机:BAABLAAFFH8YAAMMAAgImhcSBgAeAgAMAAgImhcSBgAeAgANAAEItQZsMwBIAAABLAAFFAgIIgAMACUeAA==.小小丶初号机:BAABLAAFFH8iAAMMAAgIJR4sBgCGAgAMAAgIqh0sBgCGAgANAAYINh58AgAkAgAAAA==.小小丶劣人:BAABLAAFFH8bAAMMAAgIvRwwCQBOAgAMAAgIvRwwCQBOAgANAAEIPxeREwBMAAAAAA==.小小樱桃兒:BAAALAAECgEIAQAAAA==.',['小布']='小布:BAACLAAFFH8kAAMBAAYITxLnGACJAQABAAYITxLnGACJAQACAAYIbxmpDQCDAQAsAAQKfxkAAwEACAhzJD8EAFEDAAEACAhzJD8EAFEDAAIAAwhFEJx/AKgAAAEsAAUUBgglABQAvh4A.',['小拳']='小拳拳砸你:BAAALAADCgMIAwAAAA==.',['小晓']='小晓风:BAAALAADCggICAAAAA==.',['小栈']='小栈:BAAALAAFFAIIAwAAAA==.',['小熊']='小熊喵:BAAALAADCgIIAgAAAA==.',['小甜']='小甜甜:BAAALAADCggIDwAAAA==.',['小糊']='小糊仙:BAABLAAFFH8SAAMEAAYIwBlyJQCfAQAEAAYIwBlyJQCfAQAHAAEIlBjSGgBXAAAAAA==.',['小舞']='小舞:BAABLAAFFH8PAAIJAAMIBxllGgDxAAAJAAMIBxllGgDxAAAAAA==.',['小花']='小花宝:BAABLAAFFH8IAAIXAAIIUh9HQACfAAAXAAIIUh9HQACfAAABLAAFFAgIMQAXAK8aAA==.',['小落']='小落大叶:BAABLAAFFH8wAAIJAAYIcSWZBgAdAgAJAAYIcSWZBgAdAgAAAA==.',['小铁']='小铁蛋:BAABLAAFFH8OAAMKAAMIiA0qOACSAAAKAAMIvAsqOACSAAALAAII7wfLNAAtAAAAAA==.',['尛牧']='尛牧牧:BAABLAAFFH8GAAIOAAYIzAyJAQA4AQAOAAYIzAyJAQA4AQAAAA==.',['就这']='就这样吧:BAAALAAECgYIBgAAAA==.',['左转']='左转嘚暗恋:BAABLAAECn8ZAAIKAAcIKQqalABcAQAKAAcIKQqalABcAQAAAA==.',['巨硬']='巨硬:BAAALAAECgUIBQAAAA==.',['巫医']='巫医:BAABLAAFFH8GAAIDAAIIbgznWwBjAAADAAIIbgznWwBjAAAAAA==.',['巴巴']='巴巴托斯:BAABLAAFFH8FAAIKAAMIcwwCIADIAAAKAAMIcwwCIADIAAABLAAFFAgIDAAKACoMAA==.',['巴扎']='巴扎巴扎黑:BAAALAAFFAIIAgAAAA==.',['布兰']='布兰卡:BAAALAADCgEIAQAAAA==.',['幻胖']='幻胖:BAAALAAECgEIAQAAAA==.',['幽幽']='幽幽猫:BAAALAAECgYIEwAAAA==.',['幽梦']='幽梦伊馨:BAABLAAECn8eAAIDAAcIXw3YsQAeAQADAAcIXw3YsQAeAQAAAA==.',['幽蓝']='幽蓝紫月:BAACLAAFFH8qAAMMAAYIzR3aJACeAQAMAAYIzR3aJACeAQANAAEIRxw4MwBJAAAsAAQKfy8AAwwABwjpIP8rAAkCAAwABwjpIP8rAAkCAA0ABwh0FoQ8AMUBAAAA.',['幽音']='幽音绝花:BAABLAAFFH8JAAMWAAIIZxnEJQCRAAAWAAIIZxnEJQCRAAAcAAII8A1qDwA8AAABLAAFFAYIGQAFAB0XAA==.',['庞家']='庞家莱:BAABLAAFFH8GAAIUAAIISQX3awA0AAAUAAIISQX3awA0AAAAAA==.',['张二']='张二牛:BAACLAAFFH8GAAIWAAIIxRviIAChAAAWAAIIxRviIAChAAAsAAQKfxoAAxYACAhuF5A7APEBABYABwjtGJA7APEBABgABwgLDbUcADMBAAEsAAUUBggWAAUAWRwA.',['弯弓']='弯弓馒头:BAAALAAECgYICAAAAA==.',['彭摆']='彭摆鱼:BAAALAAECgYIBgAAAA==.',['影之']='影之旺财:BAAALAAECgYIAwAAAA==.',['影匿']='影匿之魂:BAAALAADCgMIAwAAAA==.',['德德']='德德戚戚:BAAALAAFFAIIBAAAAA==.',['德才']='德才兼备灬:BAABLAAFFH8JAAMYAAYIQxjtAwAVAQAYAAUISRjtAwAVAQAWAAEIoQLmXgAsAAAAAA==.',['快乐']='快乐的小跑跑:BAAALAADCgYIBgAAAA==.',['怀庆']='怀庆:BAAALAAECgEIAQAAAA==.',['思想']='思想钢印:BAAALAAECgUIBQAAAA==.',['恨世']='恨世生:BAACLAAFFH8UAAMNAAMIoxa4DwCAAAAMAAMIexH8bACIAAANAAMI6hO4DwCAAAAsAAQKf0YABA0ACAjcHt4HAO0BAA0ACAiJHN4HAO0BAB4ABwh5FecEAK8BAAwABAhCEC5OAbIAAAAA.',['恶龙']='恶龙咆哮:BAABLAAFFH8KAAIfAAYIThIRDQBPAQAfAAYIThIRDQBPAQAAAA==.恶龙咆哮丶:BAABLAAFFH8gAAIDAAYI0xwYDwDvAQADAAYI0xwYDwDvAQAAAA==.',['悍匪']='悍匪毛哥:BAABLAAFFH8FAAIMAAMIdgNWfQBdAAAMAAMIdgNWfQBdAAAAAA==.',['悲伤']='悲伤小调:BAAALAAECgMIAwAAAA==.',['惜霜']='惜霜:BAAALAAECgYIEgAAAA==.',['慕容']='慕容秋荻:BAABLAAFFH8GAAIFAAYICwKLNwC7AAAFAAYICwKLNwC7AAAAAA==.',['慕雨']='慕雨丶夜:BAACLAAFFH82AAMJAAYIWSZoBQAuAgAJAAYIWSZoBQAuAgAVAAYIPh2aCAAAAgAsAAQKfyAAAwkACAikJfkIAF8DAAkACAikJfkIAF8DABUABQg/Bn0zAKoAAAAA.',['憔悴']='憔悴的老奶奶:BAAALAAECgYIEAAAAA==.',['我不']='我不吃牛肉:BAAALAAECgMIAwAAAA==.',['我擦']='我擦叻:BAAALAAFFAIIAwAAAA==.',['我是']='我是傳奇:BAAALAADCgQIBAAAAA==.我是奶龙:BAAALAAECgYIEAAAAA==.',['我爱']='我爱高老庄:BAAALAAFFAIIAgAAAA==.',['战无']='战无霜:BAACLAAFFH8WAAMLAAMIlRH8IABxAAALAAMIlRH8IABxAAAKAAEIXwGRagAAAAAsAAQKfzkAAwsACAiPFsAUAKMBAAsACAj3FcAUAKMBAAoAAQhgEScHAUEAAAAA.',['战皇']='战皇:BAAALAAFFAIIAgAAAA==.',['战轩']='战轩辕:BAAALAAECgUIBQAAAA==.',['手留']='手留余香:BAACLAAFFH8IAAIEAAIIHw9cdwBKAAAEAAIIHw9cdwBKAAAsAAQKfxsAAwQABwjOFbNMAF4BAAQABwjOFbNMAF4BAAgABghyB2UhAK8AAAAA.',['扑湿']='扑湿玛丽:BAABLAAFFH8JAAMgAAII2BNRHQCBAAAgAAII4g5RHQCBAAAUAAII/w+lYwA8AAAAAA==.',['扫把']='扫把:BAAALAAECgEIAQAAAA==.',['挥翅']='挥翅膀的爷们:BAABLAAFFH8IAAIFAAII/w/tWgBCAAAFAAII/w/tWgBCAAAAAA==.',['撒豆']='撒豆成冰:BAAALAAECgEIAQAAAA==.',['撞死']='撞死四只鸡:BAAALAAFFAIIAgAAAA==.',['擎苍']='擎苍:BAABLAAFFH8GAAIKAAIITQm1WQA8AAAKAAIITQm1WQA8AAAAAA==.',['放弃']='放弃昨天:BAAALAADCggIEAAAAA==.',['斯文']='斯文白类:BAAALAADCggIFwAAAA==.',['新鲜']='新鲜的壊饅頭:BAAALAAECgYIBwAAAA==.',['无兄']='无兄弟不嗜血:BAAALAAECgEIAQAAAA==.',['无尽']='无尽的星空:BAAALAAECgcIDQAAAA==.',['时间']='时间煮雨:BAAALAAECgYIBgAAAA==.',['旺仔']='旺仔奶糖:BAABLAAFFH8GAAMQAAIIFBiJGAA7AAAQAAIIFBiJGAA7AAAJAAIIngehdQA6AAAAAA==.',['旺财']='旺财欧巴:BAAALAADCgMIAwAAAA==.',['昕宝']='昕宝儿:BAAALAAECgMIAwAAAA==.',['星仔']='星仔走天下:BAAALAADCgIIAgAAAA==.',['星枢']='星枢呈瑞:BAACLAAFFH8WAAMTAAUI9BftCQAeAQATAAQIPxntCQAeAQAhAAIIFRUUEwBLAAAsAAQKfzUAAxMACAjpHp0OALQCABMACAjpHp0OALQCACEABwg4EBUeAKMBAAAA.',['星辰']='星辰坠入深海:BAACLAAFFH8gAAMEAAYIyyC7GgDMAQAEAAYIyyC7GgDMAQAIAAIIxRS6FwBJAAAsAAQKfx8ABAQABwhoIV8aABkCAAQABwhoIV8aABkCAAgAAwiJF1Q/AIEAAAcAAQgYA6hhACcAAAAA.',['星铖']='星铖:BAABLAAFFH8GAAIEAAIIIxLCfABHAAAEAAIIIxLCfABHAAAAAA==.',['是我']='是我小可愛哒:BAABLAAFFH8GAAIcAAIIOBZ3EAA3AAAcAAIIOBZ3EAA3AAAAAA==.',['晴天']='晴天会下雨:BAAALAAECgIIAgAAAA==.',['暗殺']='暗殺尒泉:BAAALAAECgIIAgAAAA==.',['暮光']='暮光隐:BAAALAAECgYIBgAAAA==.',['暴力']='暴力:BAAALAAECgUIBQAAAA==.',['暴風']='暴風:BAAALAADCgcIBwAAAA==.',['曰落']='曰落空城:BAAALAADCgYIBgAAAA==.',['曾经']='曾经王者:BAAALAAFFAIIAgAAAA==.',['月下']='月下独酌:BAAALAAECgYIBgAAAA==.',['月之']='月之羁绊:BAAALAAECgIIAgAAAA==.',['月光']='月光莫里亚:BAACLAAFFH8HAAIZAAIIww8+EgCGAAAZAAIIww8+EgCGAAAsAAQKfxoABBkABggNGlEPALUBABkABggNGlEPALUBABsABAilFYpLAO8AABoABgjiCKU2AOEAAAAA.',['月夜']='月夜敏多多:BAAALAAECgIIAgAAAA==.',['有些']='有些问题:BAACLAAFFH8dAAMgAAYI1RUYBwC2AAAUAAMIFgt1RADFAAAgAAMIlSAYBwC2AAAsAAQKfzIAAyAACAhIH7IPAIICACAACAhIH7IPAIICABQABQjIE9FsALgAAAAA.',['木大']='木大木大木大:BAAALAAECgUIBQAAAA==.',['朱古']='朱古力:BAAALAADCgUIBQAAAA==.',['李有']='李有田:BAABLAAFFH8GAAIDAAIIrQi4XABiAAADAAIIrQi4XABiAAABLAAFFAYIFgAFAFkcAA==.',['李英']='李英俊:BAAALAAECgYIBgAAAA==.',['杏鲍']='杏鲍咕丷:BAABLAAFFH8NAAIWAAUIYQeCJwDbAAAWAAUIYQeCJwDbAAABLAAFFAYIGwABAPIaAA==.',['杠爆']='杠爆十三幺:BAAALAAECgQIBgAAAA==.',['来抛']='来抛洗晶:BAAALAAFFAIIBAAAAA==.',['林逸']='林逸达雷:BAAALAAECgYIBgAAAA==.',['枫之']='枫之恋:BAABLAAFFH8MAAIMAAIIwCCPfQBdAAAMAAIIwCCPfQBdAAAAAA==.',['柒月']='柒月鎏璃:BAAALAAECgEIAQAAAA==.',['核喵']='核喵汪:BAAALAAECgEIAQAAAA==.',['核桃']='核桃喵:BAAALAADCgEIAQAAAA==.核桃喵喵:BAAALAAECgYICgAAAA==.',['格温']='格温德林:BAAALAAECgEIAQABLAAFFAgIBgAVAOIhAA==.',['梦之']='梦之南:BAAALAAFFAIIBAAAAA==.',['梦喃']='梦喃:BAABLAAFFH8IAAIVAAIIoSHiEgDJAAAVAAIIoSHiEgDJAAAAAA==.',['梨雨']='梨雨春:BAABLAAFFH8GAAIMAAIIfxiFSACbAAAMAAIIfxiFSACbAAAAAA==.',['檸尛']='檸尛檬灬:BAABLAAFFH8bAAIBAAYI8hrRDQD1AQABAAYI8hrRDQD1AQAAAA==.',['欧皇']='欧皇猎影:BAAALAAECgUIBQAAAA==.',['武浅']='武浅静:BAABLAAFFH8IAAMaAAIIxxRsFAB/AAAbAAIIhguUEwCIAAAaAAIIiBJsFAB/AAAAAA==.',['残花']='残花莫開:BAABLAAFFH8FAAIEAAUILBD2RQAiAQAEAAUILBD2RQAiAQAAAA==.',['殘花']='殘花莫開:BAAALAAFFAMIAwAAAA==.',['殷家']='殷家道:BAABLAAECn8XAAIXAAcI1BMiJQCPAQAXAAcI1BMiJQCPAQAAAA==.',['每天']='每天做丝帕:BAAALAAECgYIBgAAAA==.',['毛毛']='毛毛呀:BAAALAAFFAIIAgAAAA==.',['水有']='水有意:BAABLAAFFH8KAAIdAAMIvw5vJQCFAAAdAAMIvw5vJQCFAAAAAA==.',['永远']='永远的圣光:BAABLAAFFH8MAAIJAAIIsxu/WABKAAAJAAIIsxu/WABKAAAAAA==.',['沉默']='沉默星河:BAAALAAECgcIDgABLAAFFAgIAgASAAAAAA==.沉默的小玄子:BAAALAADCggICwAAAA==.',['沙丽']='沙丽斯:BAAALAAECgYIBgAAAA==.',['沙瑞']='沙瑞斯:BAAALAAFFAIIAgAAAA==.',['没箭']='没箭拔牙射:BAAALAAECgYIBgAAAA==.',['法力']='法力风暴:BAAALAAECgYIBgAAAA==.',['泡老']='泡老板:BAAALAAECgYIBgAAAA==.',['泰丶']='泰丶兰德:BAAALAAECgYIBgAAAA==.',['浮士']='浮士唐红艳煞:BAAALAAECgYIBgAAAA==.',['海绵']='海绵表表:BAAALAAECgEIAQAAAA==.',['液态']='液态史莱姆:BAAALAAECgUICAAAAA==.',['淡淡']='淡淡的疼:BAAALAADCgIIAgAAAA==.',['深夜']='深夜不见人:BAABLAAFFH8VAAMTAAYI1RIWEAADAQATAAQILRUWEAADAQAhAAMIaQovDwCIAAABLAAFFAYIJQAUAL4eAA==.深夜召唤人:BAABLAAFFH8lAAIUAAYIvh7lGwCyAQAUAAYIvh7lGwCyAQAAAA==.深夜小黑牛:BAAALAAECgEIAQAAAA==.深夜小龙人:BAABLAAFFH8lAAMfAAYIfxZyCgB5AQAfAAYIfxZyCgB5AQAiAAYIwgthDgBWAQABLAAFFAYIJQAUAL4eAA==.深夜料理人:BAABLAAFFH8cAAIXAAYIOSCeGgCxAQAXAAYIOSCeGgCxAQABLAAFFAYIJQAUAL4eAA==.深夜熊喵人:BAABLAAFFH8fAAMZAAYIKBNeCQCDAQAZAAYIKBNeCQCDAQAbAAIITAQwEgB6AAABLAAFFAYIJQAUAL4eAA==.深夜熊猫人:BAABLAAFFH8gAAMPAAYI7R7hHgBKAQAPAAUIFx/hHgBKAQADAAUIVBOCLQD+AAABLAAFFAYIJQAUAL4eAA==.深夜蝙蝠人:BAABLAAFFH8WAAIFAAYIWRyiFQC5AQAFAAYIWRyiFQC5AQAAAA==.深夜赶尸人:BAABLAAFFH8YAAMHAAYIgxt5AgC4AQAHAAYIgxt5AgC4AQAEAAIISQ2tmwA4AAABLAAFFAYIJQAUAL4eAA==.',['混沌']='混沌猫:BAAALAAECgYIBwAAAA==.',['渔小']='渔小牧:BAABLAAECn8WAAIOAAgIQRN5DgDDAQAOAAgIQRN5DgDDAQAAAA==.',['渣渣']='渣渣灰:BAAALAADCgQIBQAAAA==.',['游戏']='游戏游戏:BAABLAAFFH8IAAMRAAIIQQUiIAAsAAARAAIIQQUiIAAsAAAXAAIIpgEgagAqAAAAAA==.游戏游术:BAAALAAECgYICAAAAA==.',['湾仔']='湾仔之火车神:BAAALAAFFAIIAgAAAA==.',['满目']='满目星河:BAAALAAECgYIBgAAAA==.',['漆黑']='漆黑眼眸:BAAALAADCggICAAAAA==.',['漠雨']='漠雨晚歌:BAAALAAECggIBgAAAA==.',['火山']='火山林风:BAABLAAECn8WAAIKAAcIWRNlMwCMAQAKAAcIWRNlMwCMAQAAAA==.',['火羽']='火羽的小黑骑:BAAALAADCgYIBwAAAA==.',['灬删']='灬删除灬:BAAALAAECgMIAwAAAA==.',['灬尐']='灬尐泗哥灬:BAAALAAECggICAAAAA==.',['灬萌']='灬萌牙牙灬:BAAALAAFFAIIBAAAAA==.',['灬雷']='灬雷霆万钧:BAABLAAFFH8IAAIDAAIIfwpJZQBVAAADAAIIfwpJZQBVAAAAAA==.',['灰烬']='灰烬佐德尔:BAAALAAECggICAAAAA==.',['灰谷']='灰谷蘭:BAAALAAECggICwABLAAFFAgICgADAO4aAA==.',['灵魂']='灵魂之寒:BAAALAAECgIIAgAAAA==.',['灾厄']='灾厄丶:BAABLAAFFH8GAAIEAAIIbQj0hACDAAAEAAIIbQj0hACDAAAAAA==.',['炙迷']='炙迷:BAAALAADCgUIBQAAAA==.',['炮咖']='炮咖灰:BAAALAAFFAIIAgAAAA==.',['炮灰']='炮灰四系飞舞:BAAALAAECgYIDwAAAA==.',['烟花']='烟花易冷丶:BAAALAAECgMIAwAAAA==.',['烬锋']='烬锋无赦:BAAALAAECgIIAgAAAA==.',['燕麦']='燕麦坚果:BAACLAAFFH8NAAIJAAMILhoKQACUAAAJAAMILhoKQACUAAAsAAQKfxkAAgkABgg3H5s0AMEBAAkABgg3H5s0AMEBAAAA.',['爱喝']='爱喝奶茶:BAAALAAFFAIIBAAAAA==.',['爱小']='爱小南:BAAALAAFFAIIAgAAAA==.',['爱斯']='爱斯普莱索:BAAALAADCggICAAAAA==.',['爷叔']='爷叔:BAAALAAECgUIBgAAAA==.',['牛氓']='牛氓:BAABLAAFFH8GAAIJAAQIsBcGNQDZAAAJAAQIsBcGNQDZAAAAAA==.',['牛腩']='牛腩河:BAAALAAECgIIAgAAAA==.',['牛蹄']='牛蹄:BAABLAAECn8dAAQdAAgIxxDcOQDPAQAdAAgIxxDcOQDPAQAWAAMIVxFktgCiAAAYAAUIlgULLAChAAAAAA==.',['犹大']='犹大:BAAALAAECgMIBgAAAA==.',['狂燊']='狂燊:BAABLAAFFH8dAAMNAAYILB9QBACdAQANAAYIvR1QBACdAQAMAAYIYxZhNgBkAQABLAAFFAYIJQAUAL4eAA==.',['狐言']='狐言狐语丶:BAAALAAECgYIBgAAAA==.',['狗熊']='狗熊掰包谷丶:BAAALAAFFAIIBAAAAA==.',['獄爧']='獄爧乄戦魂:BAABLAAFFH8FAAIWAAIILRBzRgBiAAAWAAIILRBzRgBiAAAAAA==.',['獣乄']='獣乄戰:BAAALAADCgcIBwAAAA==.',['玉厚']='玉厚老汉:BAAALAADCgYIBgAAAA==.',['王一']='王一宝:BAAALAAECgYIBgAAAA==.',['玥玥']='玥玥大月饼:BAAALAAFFAIIAgAAAA==.',['玥琳']='玥琳琅:BAAALAAECgYICQAAAA==.',['琴麻']='琴麻岛的海:BAAALAAECgYICgAAAA==.',['生不']='生不由己:BAABLAAFFH8IAAMTAAIINAoeHgBxAAATAAII7gceHgBxAAAhAAEIUwWTGwAAAAAAAA==.',['电击']='电击滴点蜡油:BAABLAAFFH8HAAIjAAIIvRXQBQChAAAjAAIIvRXQBQChAAAAAA==.',['疯癫']='疯癫与凡人:BAAALAAFFAIIBAAAAA==.',['痞子']='痞子牛:BAAALAAECgYIBgAAAA==.',['白宁']='白宁:BAAALAAECgIIAwAAAA==.',['白浅']='白浅浅:BAACLAAFFH8JAAIFAAII0x0ELgCuAAAFAAII0x0ELgCuAAAsAAQKfxQAAgUABgihIj5MAD0CAAUABgihIj5MAD0CAAAA.',['白熊']='白熊:BAAALAAECgYIDAAAAA==.',['白蝴']='白蝴蝶:BAAALAAECgYIBgAAAA==.',['皓月']='皓月成筠:BAAALAAECgUIBQAAAA==.',['皓燃']='皓燃:BAAALAAECgQIBAAAAA==.',['石器']='石器时代:BAAALAAECgEIAQAAAA==.',['石疙']='石疙瘩:BAAALAAECgYICAAAAA==.',['砍了']='砍了那只鸭:BAACLAAFFH8HAAIKAAMIihIXGgD3AAAKAAMIihIXGgD3AAAsAAQKfyYABCQABwjQHGUNAP8BACQABgjlHWUNAP8BAAoABQivHQhzAKQBAAsABwh2FTUdAFcBAAAA.',['碎心']='碎心将军:BAAALAAECgYICwAAAA==.',['神圣']='神圣风暴:BAAALAAECgMIBgAAAA==.',['神密']='神密人一号:BAAALAAECggIDgAAAA==.',['神靈']='神靈乄德铖:BAABLAAFFH8IAAIWAAIIGxuJMwCbAAAWAAIIGxuJMwCbAAAAAA==.',['离人']='离人心上箭:BAAALAAECgcICwAAAA==.',['秋灬']='秋灬叶:BAAALAAECgYIBgAAAA==.',['稳笨']='稳笨七:BAAALAAECgMIAwAAAA==.',['稳鸠']='稳鸠你笨七:BAAALAAECgYIBgAAAA==.',['突然']='突然累了:BAAALAAECgYIBwAAAA==.',['窒息']='窒息:BAAALAAFFAIIBAAAAA==.',['第六']='第六条银河:BAAALAAECgYIEAAAAA==.',['筱萨']='筱萨:BAAALAAECgIIAgAAAA==.',['筱鱼']='筱鱼鱼:BAAALAAECggIBQAAAA==.',['箭拔']='箭拔弩张:BAAALAAECgcIEQAAAA==.',['米卫']='米卫兵:BAAALAAFFAIIBAAAAA==.',['米战']='米战:BAAALAADCggICAAAAA==.',['粉色']='粉色丢丢:BAABLAAFFH8GAAIgAAIIeQdAFwA7AAAgAAIIeQdAFwA7AAAAAA==.粉色娘子军:BAAALAAECgEIAQAAAA==.',['糊糊']='糊糊:BAAALAAECgMIAwAAAA==.',['紫儿']='紫儿恋:BAAALAAECgIIAgAAAA==.',['紫灬']='紫灬安慕希:BAAALAADCgIIAgAAAA==.',['紫电']='紫电丶盲眼:BAAALAADCgcIBwABLAADCggICAASAAAAAA==.',['紫舞']='紫舞飞扬:BAAALAAECgcIBwAAAA==.',['紫飘']='紫飘龗:BAAALAAECgYIBgAAAA==.',['红伞']='红伞伞白杆杆:BAAALAAECgcIDwAAAA==.',['红发']='红发的安:BAACLAAFFH8KAAIMAAIICRhShABNAAAMAAIICRhShABNAAAsAAQKfx0AAgwABghuINdAAMoBAAwABghuINdAAMoBAAAA.',['红尘']='红尘已逝:BAABLAAFFH8FAAIUAAIIygfmZQA6AAAUAAIIygfmZQA6AAAAAA==.',['红福']='红福齐天:BAAALAAECgYIEwAAAA==.',['红糖']='红糖麻薯:BAAALAAECgUIBQAAAA==.',['红菱']='红菱舞姬:BAACLAAFFH8ZAAIFAAYIHRc5FwAhAQAFAAYIHRc5FwAhAQAsAAQKfyUAAgUACAh3JMsJAFEDAAUACAh3JMsJAFEDAAAA.',['红衣']='红衣大主教:BAABLAAFFH8KAAIBAAII9xu3NQCOAAABAAII9xu3NQCOAAAAAA==.',['红裤']='红裤衩炮弹:BAAALAAECgUIBQAAAA==.',['约汉']='约汉不留名:BAAALAAECgUIBQAAAA==.',['纸鹞']='纸鹞:BAAALAADCggIDAAAAA==.',['纹身']='纹身噶:BAABLAAFFH8MAAMhAAIIZhDzFACHAAATAAIIEwpdHACLAAAhAAIIng3zFACHAAAAAA==.',['给你']='给你一小鎚:BAAALAAECgYIDAAAAA==.',['给我']='给我回来:BAAALAAFFAIIAwAAAA==.',['罗克']='罗克西阿斯:BAABLAAFFH8UAAMNAAYISh71BgCxAQANAAYICA/1BgCxAQAMAAYI3x0FMAB4AQABLAAECggIGgADABEbAA==.',['罗大']='罗大米:BAAALAAECggICAAAAA==.',['老付']='老付哟:BAAALAAFFAEIAQABLAAFFAIIBAASAAAAAA==.',['老公']='老公你好猛:BAAALAAECgYIBgAAAA==.',['老渔']='老渔夫:BAAALAADCgIIAgAAAA==.',['老罗']='老罗克:BAABLAAECn8UAAIJAAYIQyKlLQDcAQAJAAYIQyKlLQDcAQAAAA==.',['耐奥']='耐奥柤:BAAALAAECgYIDAAAAA==.',['耶加']='耶加雪菲:BAAALAADCgEIAQAAAA==.',['肃清']='肃清的一刀:BAAALAAECgMIAwAAAA==.',['肉夹']='肉夹馍:BAAALAAECgYIBwAAAA==.',['肾启']='肾启示:BAAALAAFFAIIAgAAAA==.',['脆皮']='脆皮先生:BAAALAAECgUIBQAAAA==.',['脑电']='脑电波:BAAALAAECgYIBgAAAA==.',['舂偢']='舂偢嘸義戰:BAAALAADCgUIBQAAAA==.',['舞丶']='舞丶:BAABLAAFFH8IAAIdAAIIzBDnHgCOAAAdAAIIzBDnHgCOAAAAAA==.',['舞无']='舞无馒头:BAAALAAECgYIDAAAAA==.',['艳艳']='艳艳吃卟胖:BAABLAAFFH8KAAIEAAMIiBUbMQDXAAAEAAMIiBUbMQDXAAAAAA==.',['艾木']='艾木矶:BAAALAAECgIIAgAAAA==.',['艾琴']='艾琴摩根:BAAALAAECgYIEAAAAA==.',['芝士']='芝士条:BAAALAAECgMIAwABLAAECgQIBgASAAAAAA==.',['芭思']='芭思:BAAALAAECgYICwAAAA==.',['花花']='花花最可爱:BAABLAAFFH8IAAIYAAIIhA0zCgBiAAAYAAIIhA0zCgBiAAAAAA==.',['花魁']='花魁丶:BAABLAAFFH8IAAMgAAIIVRaREwCdAAAgAAIIVRaREwCdAAAUAAEIIgroXwBDAAAAAA==.',['苍清']='苍清雪:BAABLAAFFH8UAAMEAAgIRRVYCAAiAgAEAAgIHhRYCAAiAgAIAAYIuweHBgBpAQAAAA==.',['苍白']='苍白:BAAALAAECgYIBgAAAA==.',['苟且']='苟且的小宋:BAAALAAECgMIAwAAAA==.',['茵妲']='茵妲拉:BAABLAAFFH80AAICAAYI0CWxBAAsAgACAAYI0CWxBAAsAgAAAA==.',['茶与']='茶与暖阳丶:BAAALAAECgEIAQAAAA==.',['茶走']='茶走去冰:BAABLAAFFH8GAAIJAAYISg0bIQBiAQAJAAYISg0bIQBiAQAAAA==.',['草蛋']='草蛋的小宋:BAAALAAFFAIIAgAAAA==.',['莎丽']='莎丽丶魔刃:BAAALAAECgYIBgAAAA==.',['莎普']='莎普爱思:BAAALAAECgYIBgAAAA==.',['莱丁']='莱丁格:BAAALAAECgIIBAAAAA==.',['菠萝']='菠萝酱:BAAALAAECgYIDwAAAA==.',['萌蛮']='萌蛮:BAABLAAFFH8GAAIPAAIInhf9IwCgAAAPAAIInhf9IwCgAAAAAA==.',['萨丷']='萨丷满:BAAALAAECgYICAAAAA==.',['萬物']='萬物之源:BAAALAAECgYICgAAAA==.',['葬醴']='葬醴:BAAALAAECgEIAQAAAA==.',['蓝条']='蓝条空空:BAAALAAECgYIBgAAAA==.',['蓝色']='蓝色生死链:BAAALAADCgYICQAAAA==.',['蔚蓝']='蔚蓝丶破邪祟:BAAALAADCggICAAAAA==.',['虎炮']='虎炮:BAAALAAFFAIIAgAAAA==.',['蛋黄']='蛋黄酥:BAAALAAECgQIBgAAAA==.',['蛮牛']='蛮牛先生:BAABLAAFFH8GAAIKAAIIFQlRXAA6AAAKAAIIFQlRXAA6AAAAAA==.',['蜡笔']='蜡笔老乱:BAAALAADCgcIBwABLAAECgYIHgABAJoSAA==.',['血东']='血东东:BAAALAAECgcIDQAAAA==.',['血之']='血之羁绊:BAAALAAFFAIIAgAAAA==.',['血型']='血型爱丽丝:BAAALAADCgYIBgAAAA==.',['行走']='行走的偆药:BAAALAAECgYIDwAAAA==.',['要关']='要关服了:BAAALAAFFAIIAgAAAA==.',['请叫']='请叫我奶牛:BAAALAADCgQIBAAAAA==.',['请多']='请多多包涵:BAAALAADCgcIBwAAAA==.',['貌美']='貌美如花:BAAALAAECgYIBwAAAA==.貌美如贺:BAABLAAFFH8LAAMMAAUIHBYoSAAqAQAMAAUIHBYoSAAqAQANAAIIDgN6HAAnAAAAAA==.',['贡克']='贡克变形大师:BAAALAAFFAIIBAAAAA==.',['贰佰']='贰佰斤的瘦子:BAABLAAFFH8UAAMKAAYIqRDSIgBXAQAKAAYIqRDSIgBXAQALAAIIrwulNAAtAAABLAAFFAYIJQAUAL4eAA==.',['贺宝']='贺宝暴揍六饼:BAAALAADCgIIAgAAAA==.',['赤华']='赤华:BAAALAAECgYIEAAAAA==.',['起舞']='起舞弄清影:BAABLAAFFH8KAAIZAAII7A6aFQBsAAAZAAII7A6aFQBsAAAAAA==.',['超级']='超级大芭乐:BAAALAAECgcIEAAAAA==.超级春毛战神:BAABLAAECn8VAAIEAAcI0g1W5wBkAQAEAAcI0g1W5wBkAQAAAA==.',['跟风']='跟风起个龙:BAAALAAECggIAgAAAA==.',['跳啊']='跳啊跳兔兔:BAAALAAECgcIEgAAAA==.',['跷精']='跷精灵:BAAALAAFFAIIAgAAAA==.',['辞忧']='辞忧:BAABLAAFFH8IAAIJAAUIeA3ULgAPAQAJAAUIeA3ULgAPAQAAAA==.',['边渡']='边渡友茨子:BAAALAAFFAIIAgAAAA==.',['达纳']='达纳托斯:BAAALAAECgEIAQAAAA==.',['过期']='过期的毓婷:BAAALAAECgUICQAAAA==.',['远山']='远山含黛:BAAALAAECgYICQAAAA==.',['迪奥']='迪奥丝女仕:BAAALAAECgcIDQAAAA==.',['逐风']='逐风猎手:BAAALAAECgUIBQAAAA==.',['那小']='那小子真险:BAAALAAECgcICAAAAA==.',['部落']='部落猎奇:BAACLAAFFH8VAAIMAAMIwRABcgB9AAAMAAMIwRABcgB9AAAsAAQKfzAAAgwACAh3HYBHAFQCAAwACAh3HYBHAFQCAAAA.部落萨特:BAABLAAFFH8OAAMDAAIIpxFCVwBsAAADAAIIpxFCVwBsAAAPAAIIswYAAAAAAAAAAA==.',['酷酷']='酷酷小爷:BAAALAADCgYIDAAAAA==.',['醉月']='醉月流觞:BAAALAAECgYICQAAAA==.',['醴甘']='醴甘指凉:BAAALAAECgYIDQAAAA==.醴甘指涼:BAAALAAECgEIAQAAAA==.',['野火']='野火流云:BAABLAAFFH8XAAMUAAUIcw6uMAC3AAAUAAUIcw6uMAC3AAAgAAIIdQMaHgB6AAAAAA==.',['钟止']='钟止意难平:BAAALAAECgYIBwAAAA==.',['铁蛋']='铁蛋游击队:BAABLAAFFH8IAAMfAAIIpwQDIABvAAAfAAIIDgQDIABvAAAlAAII8APDEQAtAAAAAA==.',['银河']='银河修理员:BAABLAAFFH8NAAIRAAUIhhHlBwAfAQARAAUIhhHlBwAfAQAAAA==.',['问就']='问就二段跳:BAACLAAFFH8RAAIFAAUITBAvLgAnAQAFAAUITBAvLgAnAQAsAAQKfycAAgUABwiiHMweAO0BAAUABwiiHMweAO0BAAAA.',['阿古']='阿古路:BAABLAAFFH8GAAIVAAMIJBDJEADaAAAVAAMIJBDJEADaAAABLAAFFAgIHQAKAOIiAA==.',['阿呸']='阿呸呸:BAAALAAECggICgAAAA==.',['阿强']='阿强的好基友:BAAALAAFFAEIAQAAAA==.',['阿斯']='阿斯顿馬丁:BAAALAADCgcIBwAAAA==.',['阿曼']='阿曼达:BAAALAAFFAIIBAAAAA==.',['阿释']='阿释密达:BAABLAAFFH8KAAIJAAIIHBFWXwBGAAAJAAIIHBFWXwBGAAAAAA==.',['陶喆']='陶喆:BAAALAADCgYIBgAAAA==.',['隐之']='隐之猎:BAAALAADCgMIAwAAAA==.',['雅柏']='雅柏菲卡:BAABLAAFFH8IAAIEAAIIHBC8jABAAAAEAAIIHBC8jABAAAAAAA==.',['雅雅']='雅雅宝贝:BAAALAADCgYICAAAAA==.',['雨花']='雨花:BAAALAAECgYIBgAAAA==.',['雷廷']='雷廷嘎巴:BAAALAAECgYIBgAAAA==.',['霍小']='霍小小:BAAALAAECgMIAwAAAA==.',['霍董']='霍董:BAAALAAFFAIIAgAAAA==.',['霜之']='霜之羁绊:BAAALAAFFAIIAgAAAA==.',['靈魂']='靈魂收割:BAABLAAFFH8GAAIEAAYIWgnDPwA8AQAEAAYIWgnDPwA8AQAAAA==.',['青蓝']='青蓝:BAAALAADCgYIBgAAAA==.',['靓翘']='靓翘挺大瘦妞:BAABLAAFFH8GAAIJAAII6BeiTACVAAAJAAII6BeiTACVAAAAAA==.',['静候']='静候佳阴:BAAALAAFFAIIAgAAAA==.',['韓喧']='韓喧茗:BAACLAAFFH8nAAIDAAYI3xoJEwDKAQADAAYI3xoJEwDKAQAsAAQKfyQAAgMABwi0HpYYACwCAAMABwi0HpYYACwCAAAA.',['韩尛']='韩尛薇:BAABLAAFFH8RAAIBAAUIQBB3JQAPAQABAAUIQBB3JQAPAQAAAA==.',['風花']='風花雪夜:BAAALAAECgYIAQAAAA==.',['风云']='风云成章:BAAALAAECgYIBwAAAA==.',['风骚']='风骚动天下:BAAALAAECgYIBgAAAA==.',['香香']='香香牛奶糖:BAAALAAFFAIIAgAAAA==.',['马里']='马里奥英:BAABLAAFFH8MAAIKAAYIvBNIGQCYAQAKAAYIvBNIGQCYAQAAAA==.',['驽风']='驽风:BAAALAAECgEIAQAAAA==.',['骑个']='骑个烂摩托:BAAALAAECggICAAAAA==.',['骑母']='骑母猪看夕阳:BAAALAAECgMIAwAAAA==.骑母猪看日落:BAAALAAECgEIAQAAAA==.骑母猪看曰出:BAAALAAECgQIBAAAAA==.',['骷髅']='骷髅人王:BAAALAAECgYIBgAAAA==.',['高启']='高启强:BAABLAAFFH8KAAIaAAIIUAjbGQBlAAAaAAIIUAjbGQBlAAABLAAFFAYIFgAFAFkcAA==.',['高级']='高级大菠萝:BAACLAAFFH8NAAIXAAUIxgrmKwDiAAAXAAUIxgrmKwDiAAAsAAQKfxUAAhcABggEIZBVAAMCABcABggEIZBVAAMCAAAA.',['鬼手']='鬼手帕:BAAALAAECgYIBgAAAA==.鬼手斩:BAAALAAECgUIBQAAAA==.',['鬼舞']='鬼舞辻无惨:BAAALAAECggICQAAAA==.',['魔王']='魔王鲁鲁修:BAAALAADCgYIBQAAAA==.',['魔舞']='魔舞精灵:BAAALAAECgQIBAAAAA==.',['鱼塘']='鱼塘手红红:BAABLAAFFH8IAAIEAAMIYxV8KgDvAAAEAAMIYxV8KgDvAAAAAA==.鱼塘空荡荡:BAACLAAFFH8mAAMTAAcILR2ICAA4AQATAAUIrxyICAA4AQAhAAMIfhzCDACvAAAsAAQKfy0ABBMABwgxJLkJAMwBABMABgiGIbkJAMwBACEABAgeIj0hAIoBACYAAQgkFdEeADwAAAAA.鱼塘鱼多多:BAAALAAECgQIBAAAAA==.',['鲁西']='鲁西飞:BAAALAAECgYICgAAAA==.',['鳞介']='鳞介:BAAALAADCgMIBAAAAA==.',['麦麦']='麦麦脆汁鸡:BAABLAAFFH8lAAMdAAYIdiD3CQDCAQAdAAYIdiD3CQDCAQAWAAYIbBMyFgCDAQABLAAFFAYIJQAUAL4eAA==.',['麻辣']='麻辣腰果:BAAALAAECgIIAgAAAA==.',['麻雀']='麻雀变凤凰:BAAALAAECgYIEgAAAA==.',['黑暗']='黑暗会淹没你:BAAALAAECgMIAwAAAA==.',['黑色']='黑色法棍:BAAALAAECggIEgAAAA==.',['黯然']='黯然血月:BAAALAAFFAIIAgAAAA==.',['鼠鼠']='鼠鼠是术术:BAABLAAFFH8LAAIgAAIIuxbsEABKAAAgAAIIuxbsEABKAAAAAA==.',['龍葵']='龍葵:BAAALAAECgYIDAAAAA==.',['龙女']='龙女:BAAALAAECgMIAwAAAA==.',['龙鱼']='龙鱼:BAAALAADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end