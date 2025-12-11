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
 local lookup = {'Shaman-Restoration','Warrior-Protection','Evoker-Preservation','Evoker-Devastation','Monk-Brewmaster','DeathKnight-Frost','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Druid-Restoration','Mage-Frost','DemonHunter-Havoc','DeathKnight-Blood','DemonHunter-Vengeance','Druid-Guardian','Paladin-Retribution','Warrior-Fury','Mage-Arcane','Shaman-Elemental','Rogue-Assassination','Monk-Mistweaver','Monk-Windwalker','Druid-Balance','Paladin-Holy','Mage-Fire','Unknown-Unknown','Hunter-Survival','Warrior-Arms','Paladin-Protection','Priest-Shadow','Priest-Discipline',}; local provider = {region='CN',realm='玛诺洛斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ah='Ahrui:BAAALAADCgYIBgAAAA==.',Ai='Airx:BAABLAAFFH8MAAIBAAIIOw8WTABvAAABAAIIOw8WTABvAAAAAA==.',Al='Alastorcrazy:BAAALAADCgYIBgAAAA==.Alitoleh:BAAALAADCgEIAQAAAA==.',An='Angelcry:BAAALAAECgMIAwAAAA==.',Ap='Apsara:BAAALAAECgYICAABLAAFFAgICAACAFMBAA==.',As='Asbfjb:BAAALAAECggIDgAAAA==.Ash:BAAALAAECggICAAAAA==.Astrea:BAAALAAFFAIIAgAAAA==.Asuka:BAACLAAFFH8IAAIDAAIIMw5FGgBsAAADAAIIMw5FGgBsAAAsAAQKfxYAAwMABggMF6EeAHoBAAMABggMF6EeAHoBAAQABQhWC6sjAMUAAAAA.',Ba='Bamboocm:BAABLAAFFH8KAAIFAAIIig4jGgBkAAAFAAIIig4jGgBkAAAAAA==.',Be='Beyoncé:BAAALAADCgIIAgAAAA==.',Br='Breathefish:BAAALAAECgYIBgAAAA==.Brynhild:BAAALAAECgQIBwAAAA==.',Bu='Bubbly:BAAALAAECgQIBAAAAA==.',Ch='Choul:BAAALAAFFAIIAgAAAA==.',Cl='Classes:BAAALAADCgYIBgAAAA==.',Co='Constantin:BAAALAADCgEIAQAAAA==.Cosmodo:BAAALAAECgMIAwAAAA==.',Cy='Cybershot:BAAALAAECgIIAgAAAA==.Cynthia:BAAALAAECgYIBwAAAA==.',Da='Darkavenger:BAAALAAFFAEIAQAAAA==.',De='Deathknite:BAAALAAECggICAAAAA==.',Dk='Dkingever:BAABLAAFFH8HAAIGAAMIrhWxYgCHAAAGAAMIrhWxYgCHAAAAAA==.',Dr='Dragdance:BAAALAAFFAIIAgAAAA==.',Fu='Fuzzypuzzle:BAAALAAFFAEIAQAAAA==.',Gr='Greens:BAAALAAECgQIBwAAAA==.',Hi='Himmels:BAAALAAECgIIAgAAAA==.Hipp:BAAALAAECgMIAwAAAA==.',Ho='Home:BAAALAAECggICAAAAA==.',Hu='Hui:BAAALAADCgUIBQAAAA==.',Ik='Ikun:BAAALAAECgcIBwAAAA==.',Is='Isha:BAAALAADCgUIBQAAAA==.',Jp='Jpush:BAAALAAECgYICwAAAA==.',Ka='Kaka:BAABLAAFFH8MAAICAAII6ghQLQBhAAACAAII6ghQLQBhAAAAAA==.',La='Layoomirty:BAAALAAECgYIBgAAAA==.',Le='Lemon:BAABLAAFFH8lAAICAAUI0ReDBwCFAQACAAUI0ReDBwCFAQAAAA==.',Lo='Lovesara:BAAALAAECgMIAwAAAA==.',Ma='Malenia:BAAALAADCggICAAAAA==.',Me='Medog:BAAALAAFFAIIAgAAAA==.',Mi='Mint:BAAALAAECgQIBAAAAA==.',Ne='Neall:BAAALAAFFAIIAgAAAA==.',Ni='Nimadeww:BAAALAADCgEIAQAAAA==.',On='Onethousand:BAAALAAECgIIAgAAAA==.',Pa='Paripi:BAAALAADCgEIAQAAAA==.',Pr='Prada:BAABLAAFFH8JAAIGAAMI0waUiQBBAAAGAAMI0waUiQBBAAAAAA==.',Qh='Qhnc:BAACLAAFFH8tAAMHAAcIsyOUBABuAgAHAAcIsyOUBABuAgAIAAIIqBTjBwBSAAAsAAQKfyAAAwcACAgLJPgWAP0CAAcACAgLJPgWAP0CAAkAAwgDHs5jAOgAAAAA.Qhns:BAABLAAFFH8GAAIBAAYIEAFJVgBuAAABAAYIEAFJVgBuAAAAAA==.',Ra='Raver:BAABLAAFFH8bAAMKAAYIRhy6JACfAQAKAAYIRhy6JACfAQALAAIIRxP0IwCAAAABLAAFFAcINQAKACkZAA==.',Se='Semoon:BAAALAAFFAQIBAAAAA==.Seraphs:BAAALAAECgUICwAAAA==.',Sh='Shamanpriest:BAAALAAECgMIAwAAAA==.Shantina:BAAALAAECgYICwAAAA==.',Si='Silverdream:BAAALAAECgMIAwAAAA==.',Sm='Smilefox:BAABLAAFFH8FAAIMAAIIXhMnLwCQAAAMAAIIXhMnLwCQAAAAAA==.',So='Solanin:BAAALAADCgUIBQAAAA==.',St='Stargosa:BAABLAAFFH8KAAIGAAgIcBKiEAAJAgAGAAgIcBKiEAAJAgAAAA==.Stefe:BAAALAAECgYICAAAAA==.',Ti='Tizzy:BAABLAAFFH8GAAIGAAYIbRdKKACVAQAGAAYIbRdKKACVAQAAAA==.Tizzydh:BAAALAAFFAIIAgAAAA==.Tizzydk:BAABLAAFFH8GAAIGAAYIwCAZFQDpAQAGAAYIwCAZFQDpAQAAAA==.Tizzylr:BAABLAAFFH8HAAIKAAYIlh7uJQCaAQAKAAYIlh7uJQCaAQAAAA==.Tizzyxd:BAABLAAFFH8GAAINAAYIahgYEgCtAQANAAYIahgYEgCtAQAAAA==.',To='Tonymontana:BAAALAAECgYIBgAAAA==.',Ul='Ulibaoying:BAAALAAECgYIBgAAAA==.',Un='Unno:BAAALAAECgYIBgAAAA==.',Va='Varlina:BAABLAAFFH8GAAIOAAYIaxU+BQBxAQAOAAYIaxU+BQBxAQAAAA==.',['一世']='一世一琉璃:BAAALAAECgYIBgAAAA==.',['一九']='一九尾一:BAAALAADCgEIAQAAAA==.',['一代']='一代食神:BAAALAAECgYIBgAAAA==.',['一刀']='一刀火葬:BAAALAADCgMIAwAAAA==.',['一发']='一发透到胃:BAABLAAFFH8HAAIPAAMIdQ4HQQCKAAAPAAMIdQ4HQQCKAAAAAA==.',['一头']='一头奶牛:BAABLAAFFH8MAAIBAAIIgRLFWQBnAAABAAIIgRLFWQBnAAAAAA==.',['一抹']='一抹无邪:BAAALAAFFAEIAQAAAA==.',['一流']='一流身材:BAABLAAFFH8MAAIGAAIIDhlzZACWAAAGAAIIDhlzZACWAAAAAA==.',['一点']='一点点:BAAALAAECgMIAwAAAA==.',['一盘']='一盘水煮鱼丶:BAAALAAECgYICQAAAA==.',['上邪']='上邪:BAAALAAECgYIBQAAAA==.',['不夜']='不夜橙:BAAALAAECggICAAAAA==.',['专门']='专门打你的脸:BAAALAAECgEIAQAAAA==.',['世界']='世界第一坦:BAACLAAFFH8TAAIQAAYIjhHSCwBQAQAQAAYIjhHSCwBQAQAsAAQKfxUAAhAABginDBYyAOwAABAABginDBYyAOwAAAAA.',['丝般']='丝般幼滑:BAAALAAECgYIDAAAAA==.',['丢你']='丢你老弟:BAAALAAECgUIBQAAAA==.',['丨玥']='丨玥丨玥丨:BAABLAAFFH8IAAIPAAgItACacAAQAAAPAAgItACacAAQAAAAAA==.',['丨蕃']='丨蕃茄丨:BAACLAAFFH8KAAIRAAII1RPXEgBoAAARAAII1RPXEgBoAAAsAAQKfxUAAxEACAhWFeIhAKgBABEABgiOGOIhAKgBAA8ACAi4ChCtAHYBAAAA.',['丶死']='丶死亡騎士:BAAALAAECgUIBgAAAA==.',['丶风']='丶风铃:BAAALAAECgYICQAAAA==.',['丷大']='丷大老登丷:BAAALAAFFAIIAgAAAA==.',['为何']='为何这般:BAAALAADCgMIAwAAAA==.',['丿自']='丿自尋死路丶:BAAALAADCgUIBQAAAA==.',['乂崽']='乂崽崽乂:BAACLAAFFH8mAAINAAYIEiGjBwAyAgANAAYIEiGjBwAyAgAsAAQKfxgAAxIABghPGloNAGABABIABghPGloNAGABAA0ABQgNHJVnAF4BAAAA.',['乌瑟']='乌瑟尔的左手:BAABLAAFFH8FAAITAAIIVhURQwCcAAATAAIIVhURQwCcAAABLAAFFAUIDgANABEMAA==.',['乐知']='乐知:BAAALAADCgcIBwAAAA==.',['书包']='书包佬:BAAALAAFFAMIAgAAAA==.',['二两']='二两米粉:BAABLAAFFH8FAAIGAAII4RrkbgBWAAAGAAII4RrkbgBWAAAAAA==.',['云天']='云天收夏色:BAAALAAECgYIEQAAAA==.',['云朵']='云朵棉花糖:BAAALAAECgYIBgAAAA==.',['云治']='云治:BAABLAAFFH8KAAIKAAgIwQ08FgDhAQAKAAgIwQ08FgDhAQAAAA==.',['五花']='五花肉:BAAALAADCgIIAgAAAA==.',['亡者']='亡者之触:BAAALAAECgUICQAAAA==.',['亡语']='亡语裂心:BAAALAAECgYIBgAAAA==.',['他来']='他来自木星:BAABLAAECn8UAAIUAAgIVB1cFwAnAgAUAAgIVB1cFwAnAgAAAA==.',['以德']='以德服人丶:BAAALAAECgYIBgAAAA==.',['以父']='以父之名:BAAALAAECgYIBgAAAA==.',['伊利']='伊利单怒疯:BAAALAAECgQIBAAAAA==.',['伊奇']='伊奇卡小十:BAAALAAECgYIDgAAAA==.',['伊希']='伊希斯:BAAALAAECgIIAgAAAA==.',['伊拉']='伊拉贡圣光:BAAALAAECgQIBAAAAA==.',['伏月']='伏月之神:BAABLAAFFH8GAAIKAAIIdBCRnAA/AAAKAAIIdBCRnAA/AAAAAA==.',['会射']='会射才行:BAAALAAECgYIBgAAAA==.',['会飞']='会飞的蜥蜴:BAAALAAECgYIBgAAAA==.',['伤心']='伤心的号丢了:BAAALAAECgIIAgAAAA==.',['佑灬']='佑灬:BAABLAAFFH8FAAINAAIIlxBFMQByAAANAAIIlxBFMQByAAAAAA==.',['佳萘']='佳萘:BAABLAAFFH8IAAIMAAII4BuQMgCfAAAMAAII4BuQMgCfAAAAAA==.',['修真']='修真:BAAALAAECggICAAAAA==.',['修罗']='修罗丿七宗罪:BAACLAAFFH8GAAIGAAIIxxFHhgBDAAAGAAIIxxFHhgBDAAAsAAQKfxkAAgYABgj9G/5AAH4BAAYABgj9G/5AAH4BAAAA.修罗刂七宗罪:BAAALAAFFAIIBAAAAA==.',['傻满']='傻满:BAAALAAECggICAAAAA==.',['元首']='元首丶愤怒了:BAABLAAFFH8GAAIGAAII/BU/UgCfAAAGAAII/BU/UgCfAAAAAA==.',['光之']='光之风月:BAAALAAFFAYIAwAAAA==.',['光影']='光影之羽:BAAALAAECgYICwAAAA==.',['全垒']='全垒冰法:BAAALAAFFAIIAgAAAA==.全垒德:BAAALAAFFAIIAgAAAA==.全垒手:BAAALAAFFAIIAgAAAA==.全垒猎手:BAAALAAECgYIBgAAAA==.',['八变']='八变莽妹:BAAALAAECgYICgAAAA==.',['六道']='六道湾小泡芙:BAABLAAFFH8FAAIVAAMIbwbeSgBuAAAVAAMIbwbeSgBuAAAAAA==.',['其实']='其实我是鱼:BAAALAAECgYIDgAAAA==.',['冥火']='冥火之怒丶匪:BAABLAAFFH8WAAIGAAUIfhmqOQBUAQAGAAUIfhmqOQBUAQAAAA==.冥火之怒丶貅:BAABLAAFFH8OAAMKAAUIghm/QQBBAQAKAAUITxm/QQBBAQALAAEIzgy9FQBEAAAAAA==.冥火之怒丶雷:BAABLAAFFH8QAAMPAAYI8g2UIwBuAQAPAAYI8g2UIwBuAQARAAII/QZTGQBRAAAAAA==.',['冥王']='冥王丨哈迪斯:BAAALAAECgYIBgAAAA==.',['冬天']='冬天第一杯酒:BAABLAAECn8UAAMKAAcIWR5RTgBDAgAKAAcIjxxRTgBDAgALAAcIWRalOgDOAQAAAA==.',['冰冻']='冰冻西红柿:BAABLAAFFH8GAAIGAAYIMxpqKwCKAQAGAAYIMxpqKwCKAQAAAA==.',['冰柠']='冰柠茶:BAABLAAFFH8RAAIBAAYIcxFtHwBgAQABAAYIcxFtHwBgAQABLAAFFAgIGgAWANMhAA==.',['冰飞']='冰飞茫:BAAALAAECgMIAwAAAA==.',['冲锋']='冲锋砍他:BAAALAAECgQIBQAAAA==.',['冻拧']='冻拧奶茶:BAAALAADCgIIAgAAAA==.',['凤老']='凤老师来了:BAAALAAECgcICgAAAA==.',['切莫']='切莫逗逗瞎:BAABLAAFFH8GAAIPAAYIpgKsOACvAAAPAAYIpgKsOACvAAAAAA==.',['刹那']='刹那:BAAALAAECgMIAwAAAA==.',['剑庭']='剑庭月心:BAAALAAECgYICwAAAA==.',['剑抹']='剑抹天河:BAACLAAFFH8fAAIXAAYIXBeWAwDBAQAXAAYIXBeWAwDBAQAsAAQKfysAAhcACAhKIzIOALkCABcACAhKIzIOALkCAAAA.',['功夫']='功夫菜刀:BAAALAAECgYIEwAAAA==.',['十一']='十一月的萧邦:BAAALAAECgIIAgAAAA==.',['十全']='十全十一美:BAAALAAECgYIDgAAAA==.',['千剑']='千剑:BAAALAAECgYICwAAAA==.',['千寻']='千寻:BAAALAAECgYIDQAAAA==.',['半天']='半天雷:BAAALAAECgYIBgAAAA==.',['半巨']='半巨人的橙诺:BAAALAAECgEIAQAAAA==.',['华丽']='华丽打击:BAABLAAFFH8IAAITAAIINR+NOgCiAAATAAIINR+NOgCiAAAAAA==.',['卖肉']='卖肉丝的猫:BAAALAAECgYICAAAAA==.',['南极']='南极熊:BAAALAAECgYIBgAAAA==.',['卡比']='卡比兽天天:BAAALAAECgEIAQAAAA==.',['卡米']='卡米先森:BAAALAAFFAIIBAAAAA==.',['卡麗']='卡麗熙:BAAALAADCgUIBQAAAA==.',['危险']='危险牛:BAAALAADCgIIBAAAAA==.危险红:BAABLAAFFH8HAAIBAAII7g8mSAB0AAABAAII7g8mSAB0AAAAAA==.',['厄梦']='厄梦丶:BAAALAAFFAIIBAAAAA==.',['原来']='原来也可以:BAABLAAECn8WAAITAAYIoRjttACYAQATAAYIoRjttACYAQAAAA==.',['原罪']='原罪嫉妒:BAABLAAFFH8TAAMVAAYIfwqILwBKAQAVAAYIJQqILwBKAQAOAAEIhg0jFwBBAAAAAA==.',['双刀']='双刀神话:BAAALAAECgQIBgAAAA==.',['双城']='双城一笙:BAAALAADCgMIAwAAAA==.',['可以']='可以:BAAALAAECgMIAwAAAA==.',['可爱']='可爱的汤包:BAACLAAFFH8kAAIYAAYILRtJBgB9AQAYAAYILRtJBgB9AQAsAAQKfxQAAxgACAj9H04OAIUCABgACAj9H04OAIUCABkABgjZE7I5AFYBAAAA.',['叶王']='叶王麻仓叶:BAAALAAECgYICwAAAA==.',['叶知']='叶知秋:BAAALAAECgIIAgAAAA==.',['叶落']='叶落无声:BAAALAAECgYIDgAAAA==.',['吖乄']='吖乄啵:BAAALAAECgUIBQAAAA==.',['君饯']='君饯新亭:BAABLAAECn8VAAMOAAYIRB/WIAAWAgAOAAYIRB/WIAAWAgAVAAEIBg6vdQAwAAAAAA==.',['吻舞']='吻舞定终生:BAAALAAECgYIBgAAAA==.',['咕噜']='咕噜袁:BAAALAADCggIDAAAAA==.',['咩咩']='咩咩德:BAABLAAFFH8IAAQNAAQIvAsLSABfAAANAAMIIg0LSABfAAASAAIIhAwPEQAiAAAaAAMIEQYAAAAAAAAAAA==.',['咸鸭']='咸鸭鸭蛋:BAAALAADCgEIAQAAAA==.',['哈里']='哈里路大旋风:BAAALAAFFAIIBAAAAA==.',['哼哼']='哼哼啊咻:BAAALAAECgYIBgAAAA==.',['唐朝']='唐朝诡事录:BAABLAAFFH8GAAIbAAYItR6hCgDaAQAbAAYItR6hCgDaAQAAAA==.',['啫啫']='啫啫煲:BAABLAAFFH8MAAIWAAYIuBFGGwBlAQAWAAYIuBFGGwBlAQAAAA==.',['喜欢']='喜欢晒太阳:BAABLAAFFH8FAAITAAMI5he+PQCcAAATAAMI5he+PQCcAAAAAA==.',['喝酒']='喝酒没问题:BAAALAAFFAIIAgAAAA==.',['喷啊']='喷啊勾吧勾:BAAALAADCgYIBgAAAA==.',['喷的']='喷的很久:BAAALAAECgYIBgAAAA==.',['嗜血']='嗜血战魂:BAAALAADCgIIAgAAAA==.嗜血的火龙果:BAABLAAFFH8GAAIGAAYItyPEEgD5AQAGAAYItyPEEgD5AQAAAA==.嗜血的爱:BAAALAAECgYIBgAAAA==.',['嘎吱']='嘎吱嘎吱:BAAALAAECgYIEAAAAA==.',['嘚悳']='嘚悳德:BAABLAAFFH8GAAINAAII6Ac+TgBWAAANAAII6Ac+TgBWAAAAAA==.',['嘴兒']='嘴兒微張:BAABLAAFFH8IAAIMAAIImwG5RABlAAAMAAIImwG5RABlAAAAAA==.',['四風']='四風月影:BAABLAAECn8sAAMPAAcInB9KHwDqAQAPAAcInB9KHwDqAQARAAEIZBHhZwAxAAAAAA==.四風铸光:BAACLAAFFH8LAAITAAYIjxIpHAB9AQATAAYIjxIpHAB9AQAsAAQKfxQAAhMABgh9IdJnABoCABMABgh9IdJnABoCAAAA.四風雪寂:BAAALAAECgYICgAAAA==.',['囡囡']='囡囡:BAAALAAECggICAAAAA==.',['圆咕']='圆咕噜:BAAALAADCgYIDAAAAA==.',['圣光']='圣光之死:BAAALAAECgUIBQAAAA==.圣光之耀:BAABLAAFFH8GAAITAAYIxhDNHwBpAQATAAYIxhDNHwBpAQAAAA==.',['圣骑']='圣骑妇联主任:BAAALAAECgYIDAAAAA==.',['墨染']='墨染丶:BAABLAAFFH8OAAQcAAQIdRPyBQDSAAAcAAMInw/yBQDSAAAVAAIIcBkcRACcAAAOAAEIJQbfIQA8AAAAAA==.',['墨水']='墨水:BAABLAAFFH8LAAMOAAYIHhx0AwCrAQAOAAYIHhx0AwCrAQAVAAIIqxNXRgCZAAAAAA==.',['复活']='复活的凹凸慢:BAAALAAECgUIBgAAAA==.',['多放']='多放香菜:BAAALAAECgEIAQAAAA==.',['多肉']='多肉椰奶冻:BAABLAAFFH8FAAITAAUIuhncJABMAQATAAUIuhncJABMAQAAAA==.',['夜晨']='夜晨:BAAALAAFFAIIAgAAAA==.',['夜魇']='夜魇舞曲:BAAALAAECgYICwAAAA==.',['大叔']='大叔的荣耀:BAAALAAECgYICwAAAA==.',['大浪']='大浪蹄子:BAAALAAECgYIBgAAAA==.',['大胖']='大胖虎:BAAALAAECgQIBAABLAAECgYICgAdAAAAAA==.',['大锤']='大锤八十:BAAALAAECgYIBgAAAA==.',['大风']='大风丸:BAAALAAECgYICQAAAA==.',['天使']='天使康康:BAAALAAECgQIBQAAAA==.',['天启']='天启骑士厄运:BAAALAAECgYICwAAAA==.',['天呐']='天呐你好傻:BAAALAADCgcIBwAAAA==.',['天啊']='天啊丶你真高:BAABLAAFFH8eAAIGAAYIsx9sGQDTAQAGAAYIsx9sGQDTAQAAAA==.',['天国']='天国的倒计时:BAABLAAFFH8SAAIBAAUIBBVWHwBhAQABAAUIBBVWHwBhAQABLAAFFAcIBgABALwHAA==.',['天空']='天空伊然:BAAALAAECgcIDwAAAA==.天空依然:BAABLAAFFH8JAAMeAAMINBbRAwBZAAALAAIIiggOEQBrAAAeAAIIdR/RAwBZAAAAAA==.天空卫士:BAABLAAFFH8QAAMLAAUI3xbgCgDtAAALAAMIKRngCgDtAAAeAAIIcBNqBABNAAAAAA==.天空未逝:BAAALAAFFAIIAwAAAA==.',['天行']='天行旅行:BAAALAADCgQIBAAAAA==.',['天驱']='天驱:BAAALAADCgEIAQAAAA==.',['天黑']='天黑就变身:BAAALAAECggIBgAAAA==.',['夹心']='夹心蛋黄派:BAAALAAECgYIBgAAAA==.',['奶嘴']='奶嘴:BAABLAAFFH8UAAITAAUIxwP7NQDRAAATAAUIxwP7NQDRAAAAAA==.',['好想']='好想抓德撸依:BAAALAAECggICAAAAA==.',['妖萝']='妖萝刀仙:BAAALAAECgYICQAAAA==.',['妙丨']='妙丨脆角:BAAALAAECgEIAQAAAA==.',['妙言']='妙言噜啦啦:BAAALAADCgcIBwAAAA==.',['妮雪']='妮雪:BAAALAADCgYIBgAAAA==.',['子不']='子不语夏沫:BAAALAAECgYIBgAAAA==.子不语秋初:BAAALAAECggIDgAAAA==.',['孟德']='孟德偲鸠:BAAALAAECgYIBgAAAA==.',['孤小']='孤小影:BAAALAAECgIIAgAAAA==.',['孤葬']='孤葬爱云凯:BAABLAAFFH8GAAICAAIIMAQ2OgAiAAACAAIIMAQ2OgAiAAAAAA==.',['宇文']='宇文:BAAALAAECgYICQAAAA==.',['守卫']='守卫者火羽:BAAALAAECgUIBQAAAA==.',['宝宝']='宝宝渔:BAAALAAECgcIBwAAAA==.',['家里']='家里有个人:BAAALAAECgIIAgAAAA==.',['寞离']='寞离乂铭:BAABLAAFFH8GAAINAAIIBgfTTwBUAAANAAIIBgfTTwBUAAAAAA==.',['寶寶']='寶寶白:BAACLAAFFH8NAAIBAAQI7Q7yOQC7AAABAAQI7Q7yOQC7AAAsAAQKfxYAAgEACAiQFdJRAO0BAAEACAiQFdJRAO0BAAAA.',['封肆']='封肆:BAABLAAFFH8PAAQeAAYIeQ+9AwBcAAAKAAQIgAxtZQChAAALAAMILhF8IQCFAAAeAAEIZxq9AwBcAAAAAA==.',['射你']='射你要理由吗:BAAALAADCgUIBQAAAA==.',['射手']='射手不在伤心:BAAALAAECgYICQAAAA==.',['小丑']='小丑萨:BAAALAAFFAEIAQAAAA==.',['小北']='小北冥:BAAALAADCgYIBgAAAA==.小北门:BAAALAAFFAIIAgAAAA==.',['小小']='小小柚:BAAALAADCggIFAAAAA==.小小浩:BAAALAAFFAIIAgAAAA==.',['小彤']='小彤彤宝贝:BAAALAAECgIIAgAAAA==.',['小心']='小心身后:BAAALAAECgEIAQAAAA==.',['小火']='小火龙:BAACLAAFFH8NAAINAAMI9RELMgChAAANAAMI9RELMgChAAAsAAQKfxQAAg0ABgirHT9OAKwBAA0ABgirHT9OAKwBAAAA.',['小绯']='小绯村剑心:BAAALAAECgMIAwAAAA==.',['小羽']='小羽:BAAALAAECgMIBgAAAA==.',['小翼']='小翼之枫:BAAALAAECggICAAAAA==.',['小能']='小能貓:BAABLAAFFH8IAAIUAAYIABphFQCxAQAUAAYIABphFQCxAQAAAA==.',['小雪']='小雪凝:BAABLAAFFH8IAAIMAAIIExwLIwCtAAAMAAIIExwLIwCtAAAAAA==.',['少年']='少年剑砍山岳:BAAALAAECgEIAQAAAA==.',['就是']='就是不吃鱼丶:BAAALAAECgYICgAAAA==.',['岁岁']='岁岁平安:BAAALAADCgQIBAAAAA==.',['崔希']='崔希丝:BAAALAAECgYIBgAAAA==.',['左耳']='左耳:BAAALAADCggICwAAAA==.',['巧沁']='巧沁兰心:BAAALAAECgQIBAAAAA==.',['巫马']='巫马:BAABLAAFFH8tAAIHAAYI3xyKHwCeAQAHAAYI3xyKHwCeAQAAAA==.',['布袋']='布袋:BAAALAAECgUIBQAAAA==.',['布鲁']='布鲁斯韦恩:BAAALAAECgMIAwAAAA==.',['帅哥']='帅哥哈哈:BAAALAADCgMIAwAAAA==.',['帕雷']='帕雷托:BAAALAAECgYICwAAAA==.帕雷托的红色:BAAALAAECgYIDAAAAA==.帕雷托的骑士:BAAALAAECgYIBwAAAA==.',['帥哥']='帥哥:BAAALAAFFAIIAgAAAA==.帥哥丶:BAABLAAFFH8OAAIPAAYIOSB5DwDlAQAPAAYIOSB5DwDlAQAAAA==.',['幻境']='幻境:BAAALAAECgEIAgAAAA==.',['幻灵']='幻灵倾心:BAAALAAECgYIEAAAAA==.幻灵清心:BAAALAAECgcIEwAAAA==.',['幻风']='幻风灵月:BAABLAAECn8hAAIOAAgIzxcHEADCAQAOAAgIzxcHEADCAQAAAA==.',['幽影']='幽影猎手:BAAALAAECgYIBgAAAA==.',['庶爺']='庶爺:BAAALAAECgIIAgAAAA==.',['弘忍']='弘忍:BAABLAAFFH8pAAIZAAYIHxaxBgCQAQAZAAYIHxaxBgCQAQAAAA==.',['影守']='影守:BAABLAAFFH8FAAILAAUIyQ9UCgD/AAALAAUIyQ9UCgD/AAAAAA==.',['影末']='影末:BAAALAAFFAYIBAAAAA==.',['心棱']='心棱丶:BAAALAAECgYIDAAAAA==.',['忘者']='忘者归来:BAAALAAECgYICgAAAA==.',['忠不']='忠不可言:BAAALAAFFAIIAgAAAA==.',['快到']='快到碗里来噢:BAAALAAECgYIBwAAAA==.',['恁堞']='恁堞来了:BAAALAAECggICAAAAA==.',['恆河']='恆河大水牛:BAABLAAFFH8LAAIGAAYI7QwzLADoAAAGAAYI7QwzLADoAAAAAA==.',['恶魔']='恶魔丶守望:BAAALAADCgEIAQAAAA==.',['悄悄']='悄悄片:BAABLAAFFH80AAIGAAYIZx8OHADGAQAGAAYIZx8OHADGAQAAAA==.',['慯心']='慯心心:BAAALAAFFAIIBAAAAA==.',['憨豆']='憨豆狗骑兵:BAAALAAECgYICgAAAA==.',['我可']='我可以啊:BAABLAAFFH8GAAIfAAIIRwzrBQA/AAAfAAIIRwzrBQA/AAAAAA==.',['我家']='我家猫叫老板:BAACLAAFFH8FAAIgAAIIjQwGGQB1AAAgAAIIjQwGGQB1AAAsAAQKfx4AAiAABghHIpQLAOgBACAABghHIpQLAOgBAAAA.我家猫是老板:BAAALAAECgYIEgAAAA==.',['我必']='我必须被遗忘:BAABLAAECn8YAAITAAYIRRQe1QBpAQATAAYIRRQe1QBpAQAAAA==.',['我恐']='我恐怖咩:BAAALAAFFAEIAQAAAA==.',['我是']='我是骑尸:BAAALAAECgYIDAAAAA==.',['我爱']='我爱小狮子:BAAALAAECgYIBgAAAA==.',['我玩']='我玩宗师:BAABLAAFFH8HAAIBAAIImgdTbABOAAABAAIImgdTbABOAAAAAA==.',['戰丨']='戰丨刀斧手:BAAALAAECgQIBAAAAA==.戰丨割草鸡:BAAALAAECgQIBAAAAA==.戰丨咏春拳:BAAALAAECgMIAwAAAA==.',['扯淡']='扯淡的圣光:BAAALAAECgYICgAAAA==.',['扶风']='扶风若柳:BAAALAAECgEIAQAAAA==.',['抓住']='抓住缅缅啦:BAAALAAECgYICQABLAAECgYICgAdAAAAAA==.',['抓贼']='抓贼一把手:BAAALAAECgUICgAAAA==.',['抱布']='抱布贸丝:BAAALAAECggICQAAAA==.',['捕风']='捕风汉子:BAAALAADCgQIBAAAAA==.',['掌控']='掌控者:BAAALAADCgYIBwAAAA==.',['排脓']='排脓次得:BAAALAAECgYIBgAAAA==.',['摘日']='摘日月揽星辰:BAABLAAFFH8HAAIKAAIIZwjLrwA3AAAKAAIIZwjLrwA3AAAAAA==.',['撒点']='撒点孜然:BAAALAAFFAIIAwAAAA==.',['撸铁']='撸铁夫斯:BAAALAAFFAIIAgAAAA==.',['无双']='无双丶:BAABLAAECn8VAAICAAYI3R1xFAClAQACAAYI3R1xFAClAQAAAA==.',['无敌']='无敌小火龙:BAAALAAECgQIBAAAAA==.',['无辜']='无辜肉盾:BAABLAAFFH8GAAITAAII7wWldQA6AAATAAII7wWldQA6AAAAAA==.',['日冕']='日冕之影:BAAALAAECgQIBAAAAA==.',['日斤']='日斤达:BAAALAAECgYICQAAAA==.',['时分']='时分时秒:BAAALAAECgQIBAAAAA==.',['旺财']='旺财:BAAALAADCgYIBgAAAA==.',['昔我']='昔我往矣:BAAALAAFFAIIAgAAAA==.',['星光']='星光小鴨:BAACLAAFFH8NAAIUAAMIxRFLOgCJAAAUAAMIxRFLOgCJAAAsAAQKfxwAAhQACAgUHlcXACcCABQACAgUHlcXACcCAAAA.',['星月']='星月之光:BAAALAADCgcICwAAAA==.星月之魇:BAAALAAECgMIAwAAAA==.',['星空']='星空低语:BAAALAAECgYICgAAAA==.',['晓德']='晓德小德:BAAALAADCgEIAQAAAA==.',['晓梦']='晓梦谜蝶月:BAABLAAECn8YAAIPAAgILBB4dQDaAQAPAAgILBB4dQDaAQAAAA==.',['智慧']='智慧果丶:BAAALAAECggICAAAAA==.',['暗夜']='暗夜微光:BAAALAAECgYICwAAAA==.暗夜界:BAABLAAFFH8KAAMBAAUIkA1LSACNAAABAAMIDglLSACNAAAWAAMIZBFVNgCDAAAAAA==.',['暮光']='暮光领域:BAAALAADCgYIBgAAAA==.',['暮雨']='暮雨晨曦:BAABLAAFFH8PAAIOAAIINh8FDACkAAAOAAIINh8FDACkAAAAAA==.',['曦辉']='曦辉川二号机:BAAALAAECggIEAAAAA==.曦辉川初号机:BAAALAADCgQIBAAAAA==.',['曾囍']='曾囍囍:BAAALAADCggICAAAAA==.',['曾经']='曾经美好回忆:BAAALAAECgEIAQAAAA==.',['最后']='最后的荣耀:BAAALAAFFAIIAgAAAA==.',['最好']='最好的我们:BAAALAADCgMIAwAAAA==.',['最终']='最终审判:BAABLAAFFH8IAAITAAIIxiMOVABNAAATAAIIxiMOVABNAAAAAA==.',['月夜']='月夜浪骑:BAAALAAECgIIAgAAAA==.月夜飘雪:BAAALAAECgYICgAAAA==.',['月影']='月影星落:BAAALAAECgMIAwAAAA==.',['月殇']='月殇零度:BAABLAAFFH8NAAIVAAMIuxloQgCaAAAVAAMIuxloQgCaAAAAAA==.',['月焱']='月焱之銘:BAAALAAECgYIBwAAAA==.',['朦朦']='朦朦恶魔:BAABLAAECn8WAAIhAAgIlBsVKQA1AgAhAAgIlBsVKQA1AgAAAA==.',['末再']='末再:BAAALAAFFAIIAgAAAA==.',['末日']='末日修罗:BAAALAAECgYIBgAAAA==.末日吟萨:BAAALAADCgYIBgAAAA==.末日木寸女古:BAAALAADCgYIBgAAAA==.末日猎杀:BAAALAAECgYIBgAAAA==.末日疾风:BAABLAAFFH8GAAIKAAIIfxO5UACVAAAKAAIIfxO5UACVAAAAAA==.',['末末']='末末沫:BAABLAAFFH8cAAMNAAYIHh7dCgADAgANAAYIHh7dCgADAgAaAAUI+RQxGAAYAQAAAA==.',['杀戮']='杀戮战神:BAABLAAFFH8GAAIUAAIIQQRJZAAjAAAUAAIIQQRJZAAjAAAAAA==.',['杀猪']='杀猪帝:BAAALAADCggIFgAAAA==.',['松岛']='松岛菜菜子:BAAALAADCgQIBAAAAA==.',['林深']='林深抚月痕:BAACLAAFFH8XAAIKAAYIiRXILQB/AQAKAAYIiRXILQB/AQAsAAQKfyAAAwoABgjoIls4AOIBAAoABgjoIls4AOIBAAsAAQjHCde/ADEAAAAA.',['果冻']='果冻柠檬茶:BAAALAAECgUIBQAAAA==.',['柒夕']='柒夕可能是神:BAAALAAECgYIBwAAAA==.',['柳烟']='柳烟:BAABLAAFFH8GAAIVAAYIEw+PEQDaAQAVAAYIEw+PEQDaAQAAAA==.',['柳絮']='柳絮:BAAALAAECgMIAwAAAA==.',['桂妮']='桂妮维亚:BAAALAADCgMIAwAAAA==.',['桃散']='桃散散:BAAALAAECgYIDwAAAA==.',['桜绒']='桜绒:BAABLAAFFH8GAAIhAAIIoh5VHwCRAAAhAAIIoh5VHwCRAAAAAA==.',['梦魇']='梦魇妖姬:BAAALAADCgEIAQAAAA==.',['梨丶']='梨丶莫颜:BAAALAADCgIIAgAAAA==.',['梨花']='梨花淺笑:BAAALAADCgYIBgAAAA==.',['棒棒']='棒棒冰:BAAALAAFFAEIAQAAAA==.',['樱与']='樱与桃:BAAALAAFFAIIAgAAAA==.',['橘橘']='橘橘子丶:BAAALAAECgYICAAAAA==.',['橘生']='橘生淮南为枳:BAAALAADCgYIBgAAAA==.',['檬心']='檬心丶:BAABLAAFFH8GAAIKAAYIdhgANgBlAQAKAAYIdhgANgBlAQABLAAFFAgIMwAGAFkjAA==.',['止水']='止水:BAABLAAFFH8cAAIPAAgIuxuMBQCGAgAPAAgIuxuMBQCGAgAAAA==.',['武艺']='武艺:BAABLAAFFH8uAAIUAAYIAxcLGACgAQAUAAYIAxcLGACgAQAAAA==.',['武贰']='武贰蛋:BAAALAAECgYIBgAAAA==.',['死亡']='死亡之角虫:BAAALAAECgUIDQAAAA==.死亡灬乐章:BAACLAAFFH8XAAIGAAUI/xlJPwA9AQAGAAUI/xlJPwA9AQAsAAQKfxwAAgYABghBIndRAFUCAAYABghBIndRAFUCAAAA.',['死骑']='死骑蒂可:BAAALAAECgYIBgAAAA==.',['残风']='残风:BAABLAAFFH8GAAIKAAYIphnaIwCiAQAKAAYIphnaIwCiAQAAAA==.',['毁灭']='毁灭就是正义:BAABLAAFFH8MAAICAAYIzSNCBQD7AQACAAYIzSNCBQD7AQAAAA==.',['比克']='比克鲁斯:BAABLAAECn8VAAIKAAcIBQnJHgEEAQAKAAcIBQnJHgEEAQAAAA==.',['毛胖']='毛胖球:BAABLAAFFH8GAAMMAAYI6RGCJgACAQAMAAQIZRKCJgACAQAhAAIIEAwLHwCQAAABLAAFFAgIpAAMAAUkAA==.',['水为']='水为之:BAAALAAECgEIAQAAAA==.',['水里']='水里游的鱼:BAAALAAECgEIAQAAAA==.水里飞的鱼:BAAALAADCgQIBAAAAA==.',['汐玥']='汐玥:BAAALAAECgcIBwAAAA==.',['江南']='江南雪绘:BAAALAAFFAQIAgAAAA==.',['江户']='江户川丶柯南:BAABLAAFFH8IAAITAAQIHxFsNwDFAAATAAQIHxFsNwDFAAAAAA==.',['沉默']='沉默圣光:BAAALAAECgYIDwAAAA==.沉默的喜羊羊:BAAALAADCgYICgAAAA==.',['沩偁']='沩偁縌:BAAALAAECgYIBgAAAA==.',['治疗']='治疗萨满:BAAALAAFFAIIAgAAAA==.',['泰蕾']='泰蕾芶萨:BAAALAAECgYIBgAAAA==.',['洛枳']='洛枳:BAAALAAECgMIBgAAAA==.',['洪小']='洪小宝:BAAALAAECgYIDAAAAA==.',['浅浅']='浅浅法:BAABLAAFFH8GAAIOAAYILhrYAwCdAQAOAAYILhrYAwCdAQAAAA==.',['浓浓']='浓浓曲奇:BAAALAAECgMIAwAAAA==.',['浪里']='浪里个西:BAAALAAFFAIIAgAAAA==.',['浴火']='浴火凤凰浴火:BAAALAAECgUIBQAAAA==.',['消失']='消失的世界:BAAALAADCgIIAgAAAA==.',['深深']='深深夜轻语:BAABLAAFFH8IAAIBAAIInxK0XQBgAAABAAIInxK0XQBgAAAAAA==.',['渐行']='渐行渐远灬:BAAALAAECgcIDQAAAA==.',['温柔']='温柔一撇:BAAALAAECgIIAgAAAA==.温柔波波:BAAALAAECgYICQAAAA==.',['源氏']='源氏在此:BAAALAAECgIIAgAAAA==.',['漢堡']='漢堡在對我笑:BAAALAAECgEIAQAAAA==.漢堡神偷:BAAALAAFFAQIBAAAAA==.',['火羽']='火羽丶流星:BAAALAAECgYIBgAAAA==.',['灬安']='灬安娜灬:BAAALAAFFAIIAgAAAA==.',['灬汪']='灬汪汪猪灬:BAACLAAFFH8NAAIKAAIIuxGtXwCMAAAKAAIIuxGtXwCMAAAsAAQKfywAAgoABwiHHcRCAMQBAAoABwiHHcRCAMQBAAAA.',['灬老']='灬老猪子灬:BAAALAADCggICgAAAA==.',['灰太']='灰太狼之殇:BAAALAAECgYICgAAAA==.',['灵魂']='灵魂不包邮:BAAALAADCgEIAQAAAA==.灵魂收割者:BAAALAADCgMIAwAAAA==.灵魂治疗:BAAALAADCgMIAwAAAA==.',['炎汐']='炎汐:BAAALAAECgEIAQAAAA==.',['炎阳']='炎阳:BAAALAAECgcIBwAAAA==.',['烟雨']='烟雨淡淡香:BAAALAAECgYIBgAAAA==.',['热卤']='热卤电视机:BAAALAAECgYIAwAAAA==.',['無霖']='無霖神画:BAABLAAFFH8GAAIPAAYInBWoHACSAQAPAAYInBWoHACSAQAAAA==.',['熱乾']='熱乾麵:BAAALAAECgYIDQAAAA==.熱乾麵伽油:BAAALAAECgYIDAAAAA==.',['爱一']='爱一个人:BAAALAAECgIIAgAAAA==.',['爱意']='爱意随风起:BAABLAAFFH8KAAIPAAIIgQwfZQA7AAAPAAIIgQwfZQA7AAAAAA==.',['牛可']='牛可:BAAALAAFFAIIAgAAAA==.',['牛德']='牛德華:BAAALAADCgEIAQAAAA==.',['牛油']='牛油果:BAAALAAECgYIEQAAAA==.',['牛顿']='牛顿魔:BAAALAADCgEIAQAAAA==.',['牛魔']='牛魔鬼:BAAALAADCgQIBAAAAA==.',['牧幽']='牧幽兰:BAAALAAECgEIAQAAAA==.',['犇犇']='犇犇:BAAALAAFFAEIAQAAAA==.',['狂野']='狂野的小辣椒:BAABLAAFFH8GAAIKAAYIaCJEFQDnAQAKAAYIaCJEFQDnAQAAAA==.',['狠萌']='狠萌狠好推:BAAALAADCgEIAQAAAA==.',['独孤']='独孤月:BAAALAAECgUIBQAAAA==.',['狸花']='狸花喵:BAAALAAECgUIBQAAAA==.',['狼教']='狼教授:BAAALAAFFAIIAgAAAA==.',['猪肉']='猪肉脚斗士:BAAALAADCgYIDAAAAA==.',['猫也']='猫也笨笨:BAAALAAFFAIIBAAAAA==.',['玄天']='玄天无相:BAAALAAECgYIDAAAAA==.',['王司']='王司徒:BAAALAAECgcIBQABLAAFFAgIAgAdAAAAAA==.',['王大']='王大猫:BAAALAAFFAEIAQAAAA==.',['玖肆']='玖肆贰肆:BAAALAAECgYIBgAAAA==.',['留不']='留不住的回忆:BAAALAADCgEIAQAAAA==.',['白附']='白附子:BAAALAAECgQIBAAAAA==.',['白雪']='白雪茫茫:BAAALAAECgQIBAAAAA==.',['白鬼']='白鬼夜王:BAAALAAECgYICwAAAA==.',['皮卡']='皮卡丘天天:BAABLAAFFH8IAAMBAAYInwY4NADVAAABAAUIkwc4NADVAAAWAAEIQQrPRABDAAAAAA==.',['盖亚']='盖亚的拥抱:BAACLAAFFH8IAAIBAAIItxAdWgBnAAABAAIItxAdWgBnAAAsAAQKfxYAAgEABwhEGYlBAFQBAAEABwhEGYlBAFQBAAAA.',['相映']='相映面趣:BAAALAADCgIIAgAAAA==.',['盾牌']='盾牌亦可破:BAAALAAFFAYIAgAAAA==.',['看俺']='看俺一挑三:BAAALAADCgQIBAAAAA==.',['真的']='真的可以吗:BAAALAADCgQIBAAAAA==.',['瞎子']='瞎子阿炳:BAAALAAFFAEIAQAAAA==.',['瞬间']='瞬间瞬间瞬间:BAABLAAFFH8FAAIVAAUILQM1PwC5AAAVAAUILQM1PwC5AAABLAAFFAgIBQAOAEMdAA==.',['短笛']='短笛大魔王:BAAALAADCgYIBgAAAA==.',['砍你']='砍你没商量:BAAALAAFFAIIBAAAAA==.',['碎月']='碎月二号:BAAALAAECgYIBgAAAA==.',['祖马']='祖马猎:BAAALAAFFAIIAgAAAA==.祖马辽:BAAALAAFFAIIBAAAAA==.',['神一']='神一卡雯:BAAALAAFFAQIBAAAAA==.',['神圣']='神圣赞美姬:BAAALAAECgYIBgAAAA==.',['神罚']='神罚之箭:BAABLAAFFH8LAAMKAAMIvx8lYQC5AAAKAAMIvx8lYQC5AAAeAAIIlxK1BABLAAAAAA==.',['神魔']='神魔至尊:BAAALAAECgMIAwAAAA==.',['祭血']='祭血关山:BAAALAAFFAIIAgAAAA==.',['秋流']='秋流到冬:BAAALAAECgYIBgAAAA==.',['空虚']='空虚虚空:BAAALAADCgYIBgAAAA==.',['笑傲']='笑傲九重天:BAAALAAECgYIEwAAAA==.',['笑行']='笑行天下:BAAALAADCgIIAgAAAA==.',['筱淡']='筱淡淡:BAAALAADCggICAAAAA==.',['筱麦']='筱麦:BAAALAAECgUIBwAAAA==.',['简言']='简言噜啦啦:BAAALAAECgUIBQAAAA==.',['箭随']='箭随枫舞:BAAALAAFFAcIAgAAAA==.',['米拉']='米拉娜丶夜影:BAABLAAECn8iAAIKAAcIlx1fJwAaAgAKAAcIlx1fJwAaAgAAAA==.',['糖门']='糖门宗主:BAABLAAFFH8QAAIHAAUI/x85IQAXAQAHAAUI/x85IQAXAQAAAA==.',['納祎']='納祎:BAAALAAECgYIBgAAAA==.',['素顔']='素顔丶:BAAALAAECggICQAAAA==.',['紫啧']='紫啧不要:BAAALAADCggICAAAAA==.',['紫樱']='紫樱飞舞:BAABLAAFFH8GAAITAAII+xWyYwBEAAATAAII+xWyYwBEAAAAAA==.',['紫苏']='紫苏:BAAALAAECgYICAAAAA==.',['紫荆']='紫荆骑士:BAAALAADCgYIBgAAAA==.',['红紫']='红紫:BAAALAAECgYICgAAAA==.',['红色']='红色的曲线:BAABLAAFFH8GAAINAAIIJAW3UgBPAAANAAIIJAW3UgBPAAAAAA==.',['纯香']='纯香咖啡:BAAALAADCgQIBAAAAA==.',['绝影']='绝影:BAABLAAFFH8qAAIPAAgIgRtzBgBxAgAPAAgIgRtzBgBxAgAAAA==.',['继续']='继续么么:BAAALAAFFAIIBAAAAA==.继续么么哒:BAAALAADCgYIBgAAAA==.继续叮叮:BAAALAAFFAIIBAAAAA==.继续哈哈:BAAALAAECgYIBgAAAA==.继续微笑:BAAALAAFFAIIBAAAAA==.',['绿洲']='绿洲星彩:BAAALAAECgQIBAAAAA==.绿洲星爆:BAAALAADCgcICAAAAA==.绿洲星瑶:BAABLAAECn8VAAITAAYIYBbzZAA6AQATAAYIYBbzZAA6AQAAAA==.绿洲星陨:BAAALAAECgUIBQAAAA==.',['罗志']='罗志祥:BAABLAAECn8YAAMfAAYIISAhDAAVAgAfAAYI3x4hDAAVAgACAAYIeRs0MQDMAQABLAAFFAYIMwAVAHUXAA==.',['美心']='美心面包:BAAALAADCggICwAAAA==.',['群友']='群友情绪价值:BAABLAAFFH8GAAIKAAYIyRVFPwBJAQAKAAYIyRVFPwBJAQAAAA==.',['老子']='老子碉堡了:BAAALAADCggIDgAAAA==.',['老萨']='老萨尓:BAAALAAECgYIBgAAAA==.',['老衲']='老衲法号不急:BAAALAAECgYIBgAAAA==.',['联盟']='联盟的国王:BAAALAAECgYIDQAAAA==.',['肖东']='肖东第一枪:BAABLAAFFH8DAAIKAAMIohQDawCMAAAKAAMIohQDawCMAAAAAA==.',['自寻']='自寻烦恼:BAAALAADCgYIBgAAAA==.',['至尊']='至尊战德:BAACLAAFFH8GAAINAAIIkAsWOgBmAAANAAIIkAsWOgBmAAAsAAQKfxQAAg0ABggXGZJMALIBAA0ABggXGZJMALIBAAAA.',['舞夜']='舞夜幽兰:BAABLAAFFH8FAAMiAAMIewM8CQAkAAAMAAIIXAFrTABJAAAiAAEIugc8CQAkAAAAAA==.',['般若']='般若波罗蜜:BAAALAAECgQIAgAAAA==.',['艾伦']='艾伦家的李白:BAABLAAFFH8MAAIKAAMIthJSbwCDAAAKAAMIthJSbwCDAAAAAA==.艾伦家的杜牧:BAAALAAECgIIAwAAAA==.艾伦家的班昭:BAABLAAFFH8JAAITAAQI9Q0oNwDHAAATAAQI9Q0oNwDHAAAAAA==.艾伦家的陆游:BAABLAAFFH8GAAIEAAYIDQFdHwA9AAAEAAYIDQFdHwA9AAAAAA==.',['芋圆']='芋圆:BAABLAAFFH8FAAIMAAIImQhVOQCBAAAMAAIImQhVOQCBAAAAAA==.',['芫荽']='芫荽:BAAALAAFFAEIAQAAAA==.',['花与']='花与琴的流星:BAAALAAECggICAAAAA==.',['花间']='花间乱:BAABLAAFFH8KAAIGAAIIZRlQXgCZAAAGAAIIZRlQXgCZAAAAAA==.',['花香']='花香柚美:BAAALAAECgEIAQAAAA==.',['芳菲']='芳菲杜若:BAAALAAECgYIDgAAAA==.',['苍天']='苍天之鹰:BAAALAAECgIIAgAAAA==.',['苦情']='苦情大表姐:BAAALAAECgYIDQAAAA==.',['莱维']='莱维贝贝:BAAALAAECgQIBAAAAA==.',['菜猪']='菜猪:BAAALAAECgYICQAAAA==.',['萌萌']='萌萌的呆呆:BAAALAADCgQIBAAAAA==.萌萌的德德:BAAALAAFFAIIAwAAAA==.',['萝筱']='萝筱莉:BAABLAAFFH8GAAMKAAYIFxf/TgASAQAKAAUIwBT/TgASAQALAAEIySIjEgBaAAAAAA==.',['萤之']='萤之光:BAAALAAFFAIIBAAAAA==.',['萨米']='萨米娜:BAACLAAFFH8dAAMOAAUIjRc3BQD7AAAVAAUIehRkMwAxAQAOAAMIrhk3BQD7AAAsAAQKfzAAAxUACAiDHMYpAHUBABUACAjPGMYpAHUBAA4ABAg8HkNBAGsBAAAA.',['落幕']='落幕殇多少:BAAALAAECgYICgAAAA==.',['葬爱']='葬爱丶风少:BAAALAAECgYIEgAAAA==.',['蒋天']='蒋天生:BAACLAAFFH8MAAIKAAUIlh+fNABpAQAKAAUIlh+fNABpAQAsAAQKfxQAAwoABggZJcIoABUCAAoABggZJcIoABUCAB4AAgg3GXsQAE4AAAAA.',['蓉嚒']='蓉嚒嚒:BAAALAAECgYIBgAAAA==.',['蓝古']='蓝古瑞萨:BAAALAAECgEIAQAAAA==.',['蕾丝']='蕾丝兎宝宝:BAAALAAECgIIAgAAAA==.',['虎皮']='虎皮蛋黄派:BAAALAAECgYIBgAAAA==.',['虾仁']='虾仁不眨眼:BAABLAAFFH8GAAMBAAIImQ1/YQBZAAABAAIImQ1/YQBZAAAWAAEIfQP/PwA5AAAAAA==.',['蛋炒']='蛋炒米粉:BAAALAAECgUIBgAAAA==.',['蛙叔']='蛙叔信仰圣光:BAABLAAFFH8GAAITAAYIPg02CADjAQATAAYIPg02CADjAQAAAA==.蛙叔的风暴萨:BAAALAADCgIIAgAAAA==.',['蟹蟹']='蟹蟹的誓言:BAAALAAECgUICAAAAA==.',['血之']='血之制裁:BAAALAAECgYIBgAAAA==.',['血怒']='血怒丶咆哮:BAAALAAECgQIBAAAAA==.',['西方']='西方树液:BAAALAADCgQIBAAAAA==.',['西瓜']='西瓜没有籽:BAAALAAECgYICQAAAA==.',['视力']='视力差不是瞎:BAAALAAECgUIBQAAAA==.',['让哥']='让哥来一刀:BAABLAAFFH8GAAIUAAIIfAvqVQBAAAAUAAIIfAvqVQBAAAAAAA==.让哥来一发:BAABLAAFFH8IAAIKAAMI3hWCaACUAAAKAAMI3hWCaACUAAAAAA==.让哥来一法:BAABLAAFFH8FAAIOAAII+w5/GQA9AAAOAAII+w5/GQA9AAAAAA==.',['诗鸣']='诗鸣画妳:BAAALAAFFAIIBAAAAA==.',['话唠']='话唠唠:BAAALAAECgYICAAAAA==.',['语薇']='语薇:BAAALAAECgYIBgAAAA==.',['诸葛']='诸葛湘屛:BAAALAAECgUIBQAAAA==.',['读灬']='读灬条:BAAALAAECgIIAgAAAA==.',['豉汁']='豉汁蒸排骨:BAAALAADCgEIAQAAAA==.',['财务']='财务萨:BAAALAAECgUIBQAAAA==.',['贪狼']='贪狼星阎罗令:BAABLAAFFH8FAAIHAAIItQOoVABzAAAHAAIItQOoVABzAAAAAA==.',['贪玩']='贪玩的小柚子:BAAALAAECgIIAgAAAA==.',['贰辻']='贰辻捌:BAAALAAFFAIIBAAAAA==.',['赛亚']='赛亚人巴达克:BAABLAAFFH8MAAIUAAYIlhk2FgCsAQAUAAYIlhk2FgCsAQAAAA==.',['起飞']='起飞的奶:BAAALAAECgYIBgAAAA==.',['超级']='超级小火龙:BAAALAAECgEIAQAAAA==.',['超越']='超越恐惧:BAAALAAECgIIBAAAAA==.',['路过']='路过来搞我:BAAALAAFFAIIAgAAAA==.',['身材']='身材魁梧:BAABLAAFFH8KAAIKAAIImRlYRgCdAAAKAAIImRlYRgCdAAAAAA==.',['轩辕']='轩辕婼韵:BAAALAAECgYIDwAAAA==.轩辕弈羽:BAAALAAECgUIBQAAAA==.',['输出']='输出手软:BAAALAAFFAIIBAAAAA==.',['违规']='违规名称:BAAALAADCgEIAQAAAA==.',['迪兰']='迪兰:BAABLAAFFH8FAAIKAAUIrALIagCNAAAKAAUIrALIagCNAAAAAA==.',['迷失']='迷失的浪子:BAAALAAECgYIBwAAAA==.',['追光']='追光者:BAAALAAECggICAAAAA==.',['追到']='追到就打死:BAAALAADCgEIAQAAAA==.',['逖耶']='逖耶里亚:BAAALAAECgYIDAAAAA==.',['遂心']='遂心迩迵:BAAALAAECgUIBgAAAA==.',['道法']='道法天成:BAAALAADCgQIBAAAAA==.',['那一']='那一抹丶殘:BAAALAAECgYIDAAAAA==.',['那个']='那个术尸:BAAALAAECgQIBAAAAA==.那个站尸:BAAALAAECgYICAAAAA==.那个術士:BAABLAAFFH8GAAIHAAYIXhCnMABVAQAHAAYIXhCnMABVAQAAAA==.',['那抹']='那抹殇丶慙:BAAALAAECgYIBgAAAA==.那抹殇丶葬訫:BAAALAAECgUIBQAAAA==.那抹璨丶殇:BAAALAAECgYICAAAAA==.',['那时']='那时还年轻:BAAALAAECgcIEAAAAA==.',['部落']='部落守护者:BAAALAAECgYICAAAAA==.',['酸菜']='酸菜汁淬毒刃:BAAALAAFFAQIBAABLAAFFAYIEQAhAGYWAA==.',['酸酸']='酸酸乳:BAABLAAFFH8JAAICAAUINAf6GQDJAAACAAUINAf6GQDJAAAAAA==.',['醉爱']='醉爱砂锅鱼头:BAABLAAFFH8MAAMKAAQIDxQLQgCjAAAKAAQIDxQLQgCjAAALAAIIlAN1MgBPAAAAAA==.',['重组']='重组辉煌:BAAALAAECgYIBgAAAA==.',['野蛮']='野蛮射尊:BAABLAAECn8ZAAMKAAYIGhi9gQBFAQAKAAYIGhi9gQBFAQALAAII3AY2sQBNAAAAAA==.',['鋼達']='鋼達:BAAALAAFFAIIBAAAAA==.',['钟薛']='钟薛高:BAAALAAECgYIBgABLAAECgYIBwAdAAAAAA==.',['铁脑']='铁脑阔:BAAALAADCggIEAAAAA==.',['银月']='银月之耀:BAAALAAECgYIDwAAAA==.',['银河']='银河系小牛:BAAALAAECgUIBQAAAA==.',['镜偌']='镜偌:BAAALAAECgcIEwAAAA==.',['长不']='长不大的喵喵:BAAALAAECggIAgAAAA==.',['长沙']='长沙望城战神:BAACLAAFFH8JAAIKAAQIIhN/YgCxAAAKAAQIIhN/YgCxAAAsAAQKfxkABAoABgj9HVlmAHYBAAoABggNHFlmAHYBAB4AAwhsGLIaAOwAAAsAAwgpFO2OAKsAAAAA.',['长赢']='长赢:BAAALAADCggICAAAAA==.',['闪舞']='闪舞精灵:BAABLAAFFH8IAAIXAAMIxhNlFQCVAAAXAAMIxhNlFQCVAAAAAA==.',['闲云']='闲云:BAAALAAECgEIAQAAAA==.',['阅读']='阅读速度过快:BAAALAAECgUIBQAAAA==.',['阿塔']='阿塔兰忒:BAAALAADCgMIAwAAAA==.',['阿时']='阿时的法国:BAAALAADCgIIAgAAAA==.',['陌客']='陌客殇残:BAAALAAECgQIBAAAAA==.',['随缘']='随缘鬣人:BAAALAAECgYIDAAAAA==.',['雨丶']='雨丶不停:BAAALAAECgYIBgAAAA==.',['雪泪']='雪泪丶寒:BAABLAAFFH8GAAIKAAYIuwh8ZACmAAAKAAYIuwh8ZACmAAAAAA==.',['雪舞']='雪舞耶米:BAABLAAFFH8VAAIKAAYIsiGqFQDlAQAKAAYIsiGqFQDlAQABLAAFFAgIRQAhAJomAA==.',['雪衣']='雪衣吥染塵:BAAALAADCgcIBwAAAA==.雪衣黙黙僾:BAAALAAECgYIBwAAAA==.',['雷偌']='雷偌:BAAALAADCgEIAQAAAA==.',['雾弧']='雾弧祁非:BAAALAAECgYICgAAAA==.',['霄月']='霄月:BAAALAAECgYICQAAAA==.',['霖薇']='霖薇丶蓉:BAABLAAFFH8GAAIMAAYI+Q2bGwByAQAMAAYI+Q2bGwByAQAAAA==.',['顽皮']='顽皮的水无悔:BAAALAAECgEIAQAAAA==.',['颜值']='颜值高输出低:BAAALAAFFAIIAgAAAA==.',['風丿']='風丿雲丨誑謸:BAAALAAFFAIIAwAAAA==.',['风与']='风与尘:BAAALAAFFAEIAQAAAA==.',['风舞']='风舞之殇:BAAALAAECgcICQAAAA==.',['风魈']='风魈魑:BAAALAAFFAIIBAAAAA==.',['风鹰']='风鹰长啸:BAACLAAFFH8IAAINAAIIghQRQABzAAANAAIIghQRQABzAAAsAAQKfyEAAg0ABgivHJ0gAM0BAA0ABgivHJ0gAM0BAAAA.',['飛鸟']='飛鸟涼:BAAALAADCgMIAwAAAA==.',['飞飞']='飞飞骑:BAAALAAECggICAAAAA==.',['香奈']='香奈儿丶:BAAALAAECgIIAgAAAA==.',['馮宝']='馮宝宝:BAAALAAECgYIEAAAAA==.',['马容']='马容易劈腿:BAAALAAECgQIBAAAAA==.',['马杀']='马杀姬:BAAALAAECgEIAQAAAA==.',['马甲']='马甲号:BAAALAAECgUIBQAAAA==.',['骇浪']='骇浪漫步者:BAAALAAECgUICQAAAA==.',['高日']='高日德:BAABLAAECn8WAAIKAAYI7Rd7lQAoAQAKAAYI7Rd7lQAoAQAAAA==.',['高玩']='高玩小六六:BAAALAAECgYIDwAAAA==.',['高详']='高详情数:BAABLAAFFH8LAAISAAII4AtmDwAnAAASAAII4AtmDwAnAAAAAA==.',['鬼舞']='鬼舞丹丹:BAAALAAECgUIBwAAAA==.鬼舞死骑:BAAALAAECgMIAwAAAA==.鬼舞猎神:BAAALAAECgYICAAAAA==.',['魂灵']='魂灵:BAABLAAFFH8NAAIOAAII6RQVFwBBAAAOAAII6RQVFwBBAAAAAA==.',['魔惑']='魔惑聖尊:BAAALAAFFAIIAgAAAA==.',['魔法']='魔法柚柚:BAAALAADCgYIDAAAAA==.',['鸿飞']='鸿飞:BAABLAAFFH8KAAMKAAII2Q8qnwA+AAAKAAIIYwkqnwA+AAALAAIIswzlGQA3AAAAAA==.',['鹤溪']='鹤溪:BAABLAAFFH8JAAIKAAUIHAvqVAD7AAAKAAUIHAvqVAD7AAAAAA==.',['鹤锡']='鹤锡:BAAALAAFFAMIBAAAAA==.',['鹰眼']='鹰眼:BAABLAAFFH8GAAMKAAYIcw9DGgA1AQAKAAQIDBFDGgA1AQALAAIIQQwPHACYAAAAAA==.',['麦林']='麦林咻咻:BAAALAAECgQIBAAAAA==.',['麦茶']='麦茶者:BAAALAADCggICAAAAA==.',['黄昏']='黄昏:BAACLAAFFH9JAAIPAAgIPiXaAQDuAgAPAAgIPiXaAQDuAgAsAAQKfyEAAg8ACAjIJKUYAAUDAA8ACAjIJKUYAAUDAAAA.',['黄正']='黄正经:BAAALAADCggICAAAAA==.',['黑妞']='黑妞无敌:BAAALAAECgYICQAAAA==.',['黑桃']='黑桃玖玖:BAAALAAECgYIEAAAAA==.',['黙黙']='黙黙僾:BAAALAADCgUIBQAAAA==.',['黯然']='黯然的神伤:BAAALAAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end