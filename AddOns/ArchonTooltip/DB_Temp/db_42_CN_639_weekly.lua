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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Hunter-Marksmanship','DemonHunter-Havoc','Paladin-Retribution','DeathKnight-Blood','Druid-Balance','Priest-Holy','Priest-Discipline','Shaman-Restoration','Paladin-Protection','Mage-Frost','Mage-Arcane','Warlock-Affliction','Hunter-BeastMastery','DeathKnight-Unholy','Priest-Shadow','Monk-Windwalker','Monk-Mistweaver','Unknown-Unknown','Warrior-Fury','Warrior-Arms','Evoker-Devastation','Shaman-Enhancement','Druid-Restoration',}; local provider = {region='CN',realm='奎尔萨拉斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Au='Augenstern:BAAAKgAECggICAAAAA==.',Be='Beback:BAACKgAFFH8IAAIBAAMIKQdlOgCGAAABAAMIKQdlOgCGAAAqAAQKfyYAAwEACAicGBoQAJ8BAAEACAicGBoQAJ8BAAIAAgiIBelzAE8AAAAA.',Bi='Bitoy:BAAAKgAECgUICwAAAA==.',Bo='Boomshakalka:BAABKgAFFH8IAAIDAAgI3AqdCACqAQADAAgI3AqdCACqAQAAAA==.',Em='Emergence:BAABKgAFFH8aAAIEAAgIkBRMDwCQAQAEAAgIkBRMDwCQAQAAAA==.',Jy='Jyguygf:BAAAKgAECggICAAAAA==.',Lu='Lunaelune:BAAAKgAECggICAAAAA==.',Pl='Playerczljhy:BAAAKgADCgQIBAAAAA==.',Po='Pointer:BAAAKgADCgEIAQAAAA==.',Si='Silentter:BAAAKgAECggIDAAAAA==.',['一点']='一点红:BAAAKgAECgQIBAAAAA==.',['一胡']='一胡萝卜一:BAAAKgAECgEIAQAAAA==.',['万鬼']='万鬼断魂荒:BAAAKgAFFAQIBAAAAA==.',['不喝']='不喝牛奶:BAAAKgAECgEIAQAAAA==.',['丷小']='丷小领主丷:BAABKgAECn8oAAIFAAgI8SAXGgCcAgAFAAgI8SAXGgCcAgAAAA==.',['丿艾']='丿艾希灬:BAAAKgADCggICAAAAA==.',['乄铭']='乄铭孤独:BAABKgAFFH8KAAIGAAYIGgr+FgDpAAAGAAYIGgr+FgDpAAABKgAFFAgICAAHAJkWAA==.',['予我']='予我孤獨:BAAAKgAECgcIBwAAAA==.',['今天']='今天喝绿茶:BAABKgAFFH8HAAIFAAMI3w0vVwDCAAAFAAMI3w0vVwDCAAAAAA==.',['从善']='从善如劉先生:BAAAKgAECgUIBgAAAA==.',['从小']='从小就狂:BAAAKgAFFAEIAQAAAA==.从小就甜:BAAAKgAFFAcIAwAAAA==.从小就美:BAAAKgAECgEIAQAAAA==.从小就雷:BAAAKgAFFAIIAgAAAA==.',['伊丽']='伊丽煞白晴天:BAAAKgAECgUIBQAAAA==.',['你丫']='你丫找射吧:BAAAKgADCgYIBgAAAA==.',['你们']='你们真缺徳:BAAAKgAECgYIBgAAAA==.',['你猜']='你猜:BAAAKgAECgQIBQAAAA==.',['八零']='八零后厶飛哥:BAAAKgADCgQIBAAAAA==.',['六十']='六十五退休:BAABKgAFFH8FAAMIAAUIhxWuEgAdAQAIAAMIRxyuEgAdAQAJAAIIZwv3HwB8AAAAAA==.',['再見']='再見灬青春:BAAAKgAECgEIAQAAAA==.',['冰箱']='冰箱里有恶魔:BAABKgAFFH8IAAIBAAgI5gkGCwCgAQABAAgI5gkGCwCgAQAAAA==.',['冷空']='冷空气:BAAAKgAECggIEQAAAA==.',['切口']='切口:BAAAKgAECgIIAgAAAA==.',['到处']='到处乱插:BAACKgAFFH8KAAIKAAMIKQ3ANgCkAAAKAAMIKQ3ANgCkAAAqAAQKfxkAAgoABwiTCp1xAO0AAAoABwiTCp1xAO0AAAAA.',['刺盾']='刺盾:BAABKgAFFH8QAAMFAAgI/w8lGAD7AAAFAAQIRRUlGAD7AAALAAQICwziEwDaAAAAAA==.',['加不']='加不住啊:BAAAKgAFFAMIAwAAAA==.',['区区']='区区蕾丝:BAAAKgADCggICwAAAA==.',['十三']='十三妹:BAABKgAFFH8GAAIMAAYICxeKBQCBAQAMAAYICxeKBQCBAQABKgAFFAgIDAANACITAA==.',['十八']='十八般武艺:BAAAKgADCggICAAAAA==.',['只是']='只是牧牧:BAABKgAFFH8GAAIJAAYIqwQQBQBDAQAJAAYIqwQQBQBDAQAAAA==.',['叮咚']='叮咚咚叮:BAAAKgAECggICAAAAA==.叮咚羌羌:BAAAKgAFFAEIAQAAAA==.',['哇酷']='哇酷哇酷:BAACKgAFFH8XAAQOAAQIVh0MCQDzAAAOAAQIVh0MCQDzAAACAAEIERekKgBFAAABAAEINhWMSwA/AAAqAAQKfysABAIACAgSHkEOABICAAIACAi4GkEOABICAAEACAgoGQMlAOkBAA4ABQi8FIslAMwAAAAA.',['啸男']='啸男蝴:BAAAKgAECgIIAgAAAA==.',['喵一']='喵一咪:BAABKgAFFH8IAAIHAAgIpwtZCgDtAQAHAAgIpwtZCgDtAQAAAA==.',['喵的']='喵的宝:BAAAKgAFFAQIBAAAAA==.',['嘟哟']='嘟哟哟:BAAAKgAECgQIBAAAAA==.',['圆滚']='圆滚滚:BAAAKgADCgIIAgAAAA==.',['圣光']='圣光大黑手:BAAAKgAECgQIBAAAAA==.',['圣罗']='圣罗德里格斯:BAABKgAFFH8IAAIFAAYIxRJ6JgDYAAAFAAYIxRJ6JgDYAAABKgAFFAgIEwAPAOUdAA==.',['堕落']='堕落嘚圣灵:BAAAKgAECgcIBwAAAA==.',['塔尔']='塔尔多娜:BAAAKgAECgYIBwAAAA==.',['夏天']='夏天小小号:BAAAKgADCggICAAAAA==.夏天的雪:BAAAKgAECgMIBAAAAA==.夏天的风雪:BAAAKgAECgEIAQAAAA==.',['夜之']='夜之影殇:BAABKgAFFH8GAAIQAAYIGhgsFAB5AQAQAAYIGhgsFAB5AQAAAA==.',['夜牧']='夜牧降临:BAABKgAFFH8IAAMRAAQIdxwOFQC7AAARAAMI5iEOFQC7AAAIAAMIBhRfGACFAAABKgAFFAgICgAIANkWAA==.',['大家']='大家长:BAACKgAFFH8LAAIBAAQIBgxjHACpAAABAAQIBgxjHACpAAAqAAQKfyAAAgEACAjdEvY1AJcBAAEACAjdEvY1AJcBAAAA.',['大寂']='大寂灭神:BAACKgAFFH8XAAISAAMIgRscDwDvAAASAAMIgRscDwDvAAAqAAQKfy0AAxIACAjPGfQXAOYBABIACAjPGfQXAOYBABMAAQhWAa2cAAsAAAAA.',['大肚']='大肚子:BAAAKgADCggIDwAAAA==.',['天天']='天天跑步的猪:BAAAKgAFFAQIBAAAAA==.',['妙淇']='妙淇:BAAAKgADCggICAAAAA==.',['妮露']='妮露:BAAAKgAECggICAABKgAFFAgIAgAUAAAAAA==.',['娜缇']='娜缇灬洸茗:BAACKgAFFH8FAAIFAAUIlxz3FwCdAQAFAAUIlxz3FwCdAQAqAAQKfxYAAgUACAi8IVwiAHgCAAUACAi8IVwiAHgCAAAA.',['孤影']='孤影:BAAAKgAECgUIBQAAAA==.',['寂寞']='寂寞灬恶魔:BAABKgAFFH8SAAIPAAMIZRTNMADJAAAPAAMIZRTNMADJAAAAAA==.',['小熊']='小熊饼干:BAABKgAFFH8GAAMVAAYIYRhZCAAiAQAVAAQI0hxZCAAiAQAWAAIIuRHLHgCXAAAAAA==.',['小龙']='小龙之神:BAACKgAFFH8NAAIXAAMIJg1jFgC0AAAXAAMIJg1jFgC0AAAqAAQKfxoAAhcACAiIHCMSADUCABcACAiIHCMSADUCAAEqAAUUBggXABIAgRsA.',['山主']='山主:BAABKgAFFH8GAAISAAYIzAU8DQAHAQASAAYIzAU8DQAHAQABKgAFFAgIJgAWAHgcAA==.',['山洞']='山洞颠覆:BAAAKgAFFAMIAwAAAA==.',['帝释']='帝释天王:BAAAKgAFFAgIBAAAAA==.',['幽幽']='幽幽鹿鳴:BAABKgAECn8WAAIBAAgICRqSEgAUAgABAAgICRqSEgAUAgAAAA==.',['张大']='张大爷:BAAAKgAECgYICwAAAA==.',['御手']='御手洗洁:BAAAKgAFFAUIAgAAAA==.',['思南']='思南:BAABKgAFFH8IAAIFAAYIxRp3FwCgAQAFAAYIxRp3FwCgAQAAAA==.',['悠悠']='悠悠雪:BAAAKgADCggICAAAAA==.',['想明']='想明白了:BAABKgAECn8bAAIMAAgI9RfwGgDcAQAMAAgI9RfwGgDcAQAAAA==.',['我都']='我都明白:BAAAKgADCggICAAAAA==.',['折戟']='折戟灬壁垒:BAAAKgADCggICAAAAA==.',['摸鱼']='摸鱼的胖狐狸:BAAAKgADCggICAAAAA==.',['星野']='星野介:BAAAKgADCggICAAAAA==.',['暗之']='暗之游侠:BAABKgAFFH8MAAIDAAgIcRKuBgDmAQADAAgIcRKuBgDmAQAAAA==.',['暗天']='暗天使:BAAAKgAECggICAAAAA==.',['暗灬']='暗灬慯:BAAAKgAECgQIBAAAAA==.',['曉乔']='曉乔灬:BAAAKgADCgIIAgAAAA==.',['最爱']='最爱吃炸鸡:BAAAKgAECggIAwAAAA==.',['朴人']='朴人猛:BAAAKgAECgMIAwAAAA==.',['机器']='机器丶猫:BAABKgAFFH8PAAMQAAYI8x7kDADCAQAQAAYI8x7kDADCAQAGAAQIdQ/hEgCuAAAAAA==.',['柯锦']='柯锦:BAAAKgAFFAgIBAAAAA==.',['橙色']='橙色芷萌:BAAAKgAFFAQIBAAAAA==.',['江上']='江上射帆:BAAAKgADCgQIBQAAAA==.',['江老']='江老板劈啪斩:BAAAKgADCggICAAAAA==.江老板带小鬼:BAAAKgADCgIIAgAAAA==.江老板紫飞侠:BAAAKgAFFAIIAgAAAA==.',['没事']='没事就睡觉:BAAAKgAECgYIDAAAAA==.没事睡会觉:BAAAKgAECgEIAQAAAA==.',['泪桥']='泪桥:BAAAKgAECggICgAAAA==.',['清纯']='清纯姑姑:BAABKgAECn8XAAQBAAgITxskLgBcAQABAAcIexQkLgBcAQAOAAQIuxUpGwABAQACAAMIPRlvRgDZAAAAAA==.',['游侠']='游侠:BAAAKgAFFAgIBAAAAA==.',['澄夜']='澄夜:BAAAKgAFFAIIAgAAAA==.',['灬喜']='灬喜乐灬:BAABKgAFFH8LAAMYAAYIcwX2BgArAQAYAAYIcwX2BgArAQAKAAUI2BaNDQAgAQAAAA==.',['灬硳']='灬硳瞳灬:BAAAKgAFFAgIBAAAAA==.',['灰色']='灰色琴弦:BAAAKgADCgEIAQAAAA==.',['灵云']='灵云:BAAAKgAFFAQIBAAAAA==.',['烟花']='烟花不堪剪:BAAAKgAECgEIAQAAAA==.',['烧鹅']='烧鹅菜菜:BAACKgAFFH81AAIZAAgIaCbQAgAvAgAZAAgIaCbQAgAvAgAqAAQKfxQAAhkACAjOI0EFALECABkACAjOI0EFALECAAAA.',['爆椒']='爆椒牛肉面:BAABKgAFFH8NAAIQAAMI9Q9XNgDAAAAQAAMI9Q9XNgDAAAAAAA==.',['牛得']='牛得一比:BAAAKgAECgcIDgAAAA==.',['特仑']='特仑苏有机奶:BAAAKgADCgMIAwAAAA==.',['狡诈']='狡诈的猎狐者:BAAAKgAFFAYIAQAAAA==.',['狼子']='狼子炽天使:BAAAKgADCgEIAQAAAA==.',['看你']='看你妹:BAAAKgAECggIEgAAAA==.',['真德']='真德劲:BAAAKgADCgUIBQAAAA==.',['祖国']='祖国的绿萝:BAABKgAFFH8HAAIEAAMIfhdjJQDjAAAEAAMIfhdjJQDjAAAAAA==.',['神光']='神光之神:BAAAKgAECgYIDgABKgAFFAYIFwASAIEbAA==.',['神圣']='神圣女王:BAABKgAECn8XAAIFAAgIHBogPgAJAgAFAAgIHBogPgAJAgAAAA==.',['素衫']='素衫甜儿:BAAAKgAECgcIBwAAAA==.',['紫薯']='紫薯:BAAAKgAFFAQIBAABKgAFFAgIBgAOAGobAA==.',['繁华']='繁华遗失:BAABKgAFFH8IAAMBAAQI2BnOEgDaAAABAAMI6BTOEgDaAAAOAAIIkCPjFwBkAAAAAA==.',['繁星']='繁星冷月:BAAAKgADCggICAAAAA==.',['胖叔']='胖叔叔的武僧:BAACKgAFFH8IAAITAAYIlx33CAAgAQATAAYIlx33CAAgAQAqAAQKfxoAAxMACAjEFm4vAJIBABMACAjEFm4vAJIBABIABgjIGU0oAGEBAAAA.',['致命']='致命弧线:BAABKgAFFH8GAAIFAAYI6CASGwCJAQAFAAYI6CASGwCJAQAAAA==.',['艾克']='艾克莉西娅:BAAAKgAECgcIBwAAAA==.',['艾司']='艾司唑侖:BAAAKgAECggIEAAAAA==.',['艾尔']='艾尔萨:BAAAKgADCgMIAwAAAA==.',['花会']='花会沿路盛开:BAABKgAFFH8KAAIFAAYI2iH8EwC8AQAFAAYI2iH8EwC8AQAAAA==.',['苦瓜']='苦瓜伴黄芪:BAAAKgAECgIIAgAAAA==.苦瓜伴黄连:BAAAKgADCggICAAAAA==.苦瓜扮黄连:BAAAKgADCggICAAAAA==.',['茉莉']='茉莉烤奶:BAAAKgADCgcIBwAAAA==.',['荇灬']='荇灬小爱:BAAAKgAECggICAAAAA==.',['萨拉']='萨拉克斯:BAABKgAECn8aAAMPAAgIFBMsYwCIAQAPAAgI/g0sYwCIAQADAAUIzhdNQgAZAQAAAA==.萨拉明明:BAAAKgADCgUIBQAAAA==.',['蒜鸟']='蒜鸟蒜鸟:BAABKgAECn8fAAIFAAgIDhxgMQA5AgAFAAgIDhxgMQA5AgAAAA==.',['言其']='言其不语:BAABKgAFFH8jAAIQAAQI/CLQIAAbAQAQAAQI/CLQIAAbAQAAAA==.',['让我']='让我射两箭:BAAAKgADCgEIAQAAAA==.',['谏者']='谏者无域:BAAAKgADCggICAAAAA==.',['辛德']='辛德维拉:BAABKgAFFH8KAAIEAAIIyhZMJACgAAAEAAIIyhZMJACgAAAAAA==.',['达芬']='达芬奇大领主:BAAAKgAECggIDgAAAA==.',['远赴']='远赴人间:BAACKgAFFH8GAAIFAAUIOBgnNgCdAAAFAAUIOBgnNgCdAAAqAAQKfy8AAgUACAjfI+cOANICAAUACAjfI+cOANICAAAA.',['遥远']='遥远的神秘:BAAAKgAECgIIAgAAAA==.',['醋海']='醋海带的说:BAAAKgADCgYIBgAAAA==.',['钻石']='钻石芙蓉王:BAAAKgADCgQIBAAAAA==.',['阿尔']='阿尔喵:BAAAKgAECggIDAAAAA==.',['阿爾']='阿爾德德:BAAAKgAECgcICwAAAA==.',['雨丶']='雨丶宠児:BAABKgAFFH8KAAMJAAMIpA9eHgCqAAAJAAMIYA1eHgCqAAAIAAMIaAs9GwBjAAAAAA==.',['雪夜']='雪夜异乡人:BAABKgAFFH8GAAIQAAYIRhFdFwBiAQAQAAYIRhFdFwBiAQAAAA==.',['靈魂']='靈魂丶擺渡者:BAAAKgAFFAYIBAAAAA==.',['顺心']='顺心如意:BAAAKgAFFAYIAwAAAA==.',['风铃']='风铃回忆:BAABKgAFFH8MAAIFAAYIHBmCEgB1AQAFAAYIHBmCEgB1AQAAAA==.',['飞影']='飞影战神:BAAAKgAECggICAAAAA==.飞影狐仙:BAAAKgAECgEIAQAAAA==.',['饭团']='饭团子:BAAAKgADCgEIAQAAAA==.',['首席']='首席奥术师:BAAAKgAECgYICQAAAA==.',['香丫']='香丫丫:BAAAKgAECggIEQAAAA==.',['黑夜']='黑夜冰晶:BAAAKgADCgMIAwAAAA==.',['黑暗']='黑暗騎士:BAAAKgADCggICAAAAA==.',['黑眼']='黑眼圈会放电:BAAAKgAECgEIAQAAAA==.',['龙归']='龙归诺尔:BAAAKgAECgUICQAAAA==.',['龙狼']='龙狼:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end