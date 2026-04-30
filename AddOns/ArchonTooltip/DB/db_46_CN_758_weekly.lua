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
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'DeathKnight-Unholy','Paladin-Retribution','Evoker-Augmentation','Warrior-Fury','Unknown-Unknown','Monk-Mistweaver','DemonHunter-Havoc','DemonHunter-Devourer','Druid-Feral','Druid-Guardian','Paladin-Protection','Mage-Frost','Priest-Discipline','Monk-Windwalker','Monk-Brewmaster','Druid-Balance','Druid-Restoration','Warlock-Demonology','Shaman-Restoration','Warlock-Destruction','Shaman-Elemental','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Priest-Shadow','Priest-Holy','Evoker-Devastation',}
local provider = {region='CN',realm='玛法里奥',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Angelina:BAAALgAFFAIJBAAAAA==.',
Bp='Bpdine:BAABLgAECn8hAAIBAAgJdhgbPgA/AgABAAgJdhgbPgA/AgAAAA==.',
Ca='Cancer:BAAALgAECgYJBgAAAA==.',
Ch='Chanelcoco:BAAALgADCgcJDgAAAA==.',
Cl='Clytemnestra:BAAALgADCgYJBgAAAA==.',
El='Elsterdohle:BAAALgAECgMJAwAAAA==.',
Ff='Ff:BAAALgADCgUJBQAAAA==.',
Ho='Hori:BAAALgAECgYJBgAAAA==.',
Ka='Katherina:BAABLgAECn8gAAICAAgJ4BQ9SAAKAgACAAgJ4BQ9SAAKAgAAAA==.',
Ku='Kumo:BAAALgAFFAQJBAAAAA==.',
Ll='Llanowar:BAAALgAECgYJDAAAAA==.',
Lu='Lucretia:BAAALgAECgIJAgAAAA==.',
Ly='Lynx:BAAALgAECgYJBgAAAA==.',
Mp='Mplusempress:BAAALgAECgYJBQABLgAFFAMJCAADAPULAA==.',
Pa='Pajamas:BAACLgAFFH8JAAIBAAQJOhn2FgBIAQABAAQJOhn2FgBIAQAuAAQKfxYAAgEACAkPIpgcANMCAAEACAkPIpgcANMCAAAA.Paradisekiss:BAABLgAFFH8PAAIEAAQJkhQ+CwBLAQAEAAQJkhQ+CwBLAQAAAA==.',
Pu='Purpler:BAAALgAECgcJDQAAAA==.',
Ra='Rad:BAAALgAECgIJAgAAAA==.',
Re='Restore:BAAALgAECgMJBQAAAA==.',
Se='Serendipity:BAAALgAECgYJBgAAAA==.',
Si='Sistina:BAAALgAECgEJAQAAAA==.',
St='Stefsunyanzi:BAAALgAECgEJAQAAAA==.Stormfish:BAAALgAECgEJAQAAAA==.',
Su='Sumton:BAAALgAECgYJCAAAAA==.',
Ve='Velantra:BAAALgAECgkJCAABLgAFFAIJAwAFAAAAAA==.',
Wo='Wolftotme:BAAALgAECgEJAQAAAA==.',
Xx='Xxby:BAAALgAECgQJBAAAAA==.',
Yu='Yuliana:BAAALgADCgUJBQAAAA==.',
Zd='Zd:BAAALgAECgUJCAAAAA==.',
['一路']='一路奶粉:BAACLgAFFH8GAAIGAAMJKBRqCwDuAAAGAAMJKBRqCwDuAAAuAAQKfyAAAgYACAm9IA4IANYCAAYACAm9IA4IANYCAAAA.',
['七小']='七小度:BAAALgADCgEJAQAAAA==.',
['三路']='三路奶粉:BAAALgAFFAIJAgAAAA==.',
['不要']='不要丶布托:BAAALgAECgEJAQAAAA==.不要丶德嘚:BAAALgAECgcJBwAAAA==.',
['不语']='不语锋芒:BAABLgAECn8lAAMHAAkJ8hTeDgB1AgAHAAkJ7hPeDgB1AgAIAAgJ0guUVwCbAQAAAA==.',
['东东']='东东包的武僧:BAAALgAECgYJBgAAAA==.',
['两千']='两千次全胜:BAABLgAFFH8HAAIBAAIJvRX8OgCnAAABAAIJvRX8OgCnAAABLgAFFAQJDwAEAJIUAA==.',
['丨今']='丨今日说法丨:BAAALgAECgcJAgAAAA==.',
['丶抄']='丶抄手:BAAALgAECgQJCQAAAA==.',
['丶暮']='丶暮霞:BAAALgAECggJCQAAAA==.',
['乐乐']='乐乐球球:BAAALgAECgEJAQAAAA==.',
['乱者']='乱者:BAAALgADCgYJBgAAAA==.',
['付豪']='付豪:BAABLgAFFH8NAAIBAAUJ/w0qBwBQAQABAAUJ/w0qBwBQAQAAAA==.',
['仧小']='仧小吉:BAAALgAECgIJBAAAAA==.',
['伯尔']='伯尔尼奇迹:BAAALgAECgUJCgAAAA==.',
['伴山']='伴山河入眠:BAACLgAFFH8FAAIJAAMJmArRAgACAQAJAAMJmArRAgACAQAuAAQKfx4AAwkABwlQFOgPAK8BAAkABwm+E+gPAK8BAAoAAglZFAAAAAAAAAAA.',
['伽利']='伽利猎:BAAALgAFFAEJAQAAAA==.',
['先斩']='先斩后揍:BAAALgADCgEJAQAAAA==.',
['光之']='光之怒吼:BAAALgAECgIJAwAAAA==.',
['六翼']='六翼使徒:BAABLgAECn8hAAILAAgJPBtpBgCDAgALAAgJPBtpBgCDAgAAAA==.',
['冰封']='冰封的恋:BAAALgAFFAIJAgAAAA==.',
['冰箱']='冰箱里的胖丁:BAABLgAFFH8FAAIMAAIJ1QpLQQCsAAAMAAIJ1QpLQQCsAAAAAA==.',
['冷瞳']='冷瞳:BAAALgAECgMJBQAAAA==.',
['冻干']='冻干柠檬片:BAAALgAECgQJBgAAAA==.',
['刘坤']='刘坤:BAAALgAFFAQJBAABLgAFFAUJDQABAGsZAA==.',
['刘浩']='刘浩存:BAAALgAECgEJAQAAAA==.',
['刺儿']='刺儿丫头:BAAALgADCgIJAgAAAA==.',
['劣人']='劣人甲:BAAALgAECggJCAAAAA==.',
['千颜']='千颜人仙:BAAALgADCgIJAgAAAA==.',
['原价']='原价:BAAALgAECgcJDgAAAA==.',
['叁岁']='叁岁:BAAALgAFFAMJAwAAAA==.',
['吕布']='吕布上马:BAAALgAECgMJAwAAAA==.',
['咏春']='咏春别问:BAACLgAFFH8FAAIGAAIJzw7ZEACVAAAGAAIJzw7ZEACVAAAuAAQKfxUAAgYABgnAHaIZAO8BAAYABgnAHaIZAO8BAAAA.',
['喜王']='喜王其系:BAAALgADCgMJBAAAAA==.',
['喵儿']='喵儿哇:BAAALgAECgEJAgAAAA==.',
['喻知']='喻知:BAAALgAECgIJAwAAAA==.',
['嗨嗨']='嗨嗨人生:BAAALgAECgcJDQAAAA==.',
['国成']='国成付豪爷爷:BAABLgAFFH8IAAIBAAUJUQk6HwAfAQABAAUJUQk6HwAfAQAAAA==.',
['圣光']='圣光奥斯卡:BAAALgAECgUJDQAAAA==.圣光萌主:BAAALgAECgQJBAAAAA==.',
['均衡']='均衡之镰:BAAALgADCgEJAQABLgAFFAEJAgAFAAAAAA==.',
['坚果']='坚果墙丶:BAAALgAECgQJCAAAAA==.',
['城南']='城南慕北:BAAALgAECgcJBgAAAA==.',
['基里']='基里曼:BAAALgADCgUJBQAAAA==.',
['塞勒']='塞勒斯汀:BAAALgADCgMJAwAAAA==.',
['外道']='外道:BAAALgAECgYJBgAAAA==.',
['多隆']='多隆巴鲁托:BAAALgAECgYJBwABLgAFFAQJDQABAHAZAA==.',
['夜雨']='夜雨霄霄:BAAALgAECgcJCgAAAA==.',
['大螃']='大螃蟹:BAAALgAECgEJAQAAAA==.',
['太乙']='太乙真人:BAAALgADCgYJBgAAAA==.',
['太有']='太有波哈了:BAAALgAECgQJBAAAAA==.',
['奎托']='奎托斯:BAAALgAECgEJAQAAAA==.',
['奧博']='奧博倫影歌:BAAALgAECgQJBQAAAA==.',
['如熙']='如熙:BAAALgAECgIJAwAAAA==.',
['妖妖']='妖妖白玉猫:BAAALgAECgQJDAAAAA==.',
['妮丝']='妮丝蒂尔:BAAALgAECgEJAQAAAA==.',
['威武']='威武梁会长:BAAALgAECgYJCwAAAA==.',
['娜宝']='娜宝宝:BAAALgAECgYJEwAAAA==.',
['学历']='学历有水分丶:BAAALgAECgkJDwAAAA==.',
['安七']='安七炫:BAAALgAECgQJBAAAAA==.',
['小吱']='小吱吱:BAAALgAFFAIJAgAAAA==.',
['小小']='小小微微:BAAALgAECgQJBAAAAA==.',
['小櫳']='小櫳:BAAALgADCgcJBwAAAA==.',
['小花']='小花毛毛妈妈:BAABLgAFFH8FAAIBAAQJnAXyEADtAAABAAQJnAXyEADtAAAAAA==.',
['小鈅']='小鈅鈅:BAAALgADCgEJAQAAAA==.',
['小陈']='小陈不吃苹果:BAAALgADCgYJBwAAAA==.',
['小鱼']='小鱼三旋:BAABLgAFFH8GAAINAAMJigKXEADAAAANAAMJigKXEADAAAAAAA==.',
['就是']='就是不让骑:BAAALgADCgYJBgAAAA==.',
['岁岁']='岁岁:BAAALgAECgcJBwAAAA==.',
['岚之']='岚之山:BAAALgAECgkJEAAAAA==.',
['崔诚']='崔诚:BAAALgAECgcJBwAAAA==.',
['布拉']='布拉多尔:BAAALgAECgMJAwAAAA==.',
['布鲁']='布鲁克血魂:BAAALgAECgYJEwAAAA==.',
['希尔']='希尔梅斯:BAAALgAECgQJBAAAAA==.',
['幻境']='幻境重生:BAAALgADCgEJAgAAAA==.',
['张小']='张小弟:BAACLgAFFH8QAAIOAAUJ2iCPAgCJAQAOAAUJ2iCPAgCJAQAuAAQKfyAAAw4ABwn/Iy8KANUCAA4ABwn/Iy8KANUCAA8ABQl6IMMtAKMBAAAA.',
['彩虹']='彩虹旅行记:BAAALgAFFAEJAgAAAA==.',
['微风']='微风:BAAALgAECgUJBQAAAA==.',
['德亦']='德亦双薪:BAABLgAFFH8GAAMQAAMJ5BW/EwClAAAQAAIJ2Q+/EwClAAARAAIJBQRwHwB8AAAAAA==.',
['德莫']='德莫娜冰晨:BAAALgADCgIJAwAAAA==.',
['心宅']='心宅人厚:BAAALgAECgkJDwAAAA==.',
['恩熙']='恩熙:BAAALgAECgYJCgAAAA==.',
['惹我']='惹我就冰箱:BAABLgAECn8UAAISAAcJfw4wFwBXAQASAAcJfw4wFwBXAQAAAA==.',
['我刚']='我刚睡醒:BAAALgAECgQJBAAAAA==.',
['我心']='我心已绝:BAAALgAECgQJBgAAAA==.',
['我是']='我是涅奶:BAAALgADCgcJBwAAAA==.',
['或许']='或许会离别:BAAALgAECgEJAQAAAA==.',
['抓一']='抓一只是一只:BAAALgAECgkJBwAAAA==.',
['拽一']='拽一起:BAAALgAECgMJBQAAAA==.',
['擦郎']='擦郎哈密答:BAAALgAECgMJBAAAAA==.',
['新叶']='新叶喵:BAAALgAFFAEJAgAAAA==.',
['无能']='无能勤快:BAAALgAECgQJBAAAAA==.',
['昂寇']='昂寇:BAABLgAECn8WAAIBAAcJXR7kFgBbAQABAAcJXR7kFgBbAQAAAA==.',
['易燃']='易燃易炸:BAAALgAFFAEJAgAAAA==.',
['暗刃']='暗刃风:BAAALgAECgcJEwAAAA==.',
['暗夜']='暗夜星灵:BAAALgAECgcJCQAAAA==.',
['月舞']='月舞星魂:BAAALgAECgYJBwAAAA==.',
['木瓜']='木瓜很瞌睡:BAAALgAFFAEJAQAAAA==.',
['李子']='李子谦:BAABLgAFFH8KAAIBAAUJMA/hEQBaAQABAAUJMA/hEQBaAQAAAA==.',
['杨雨']='杨雨父:BAAALgAFFAEJAQABLgAFFAIJAgAFAAAAAA==.',
['桥也']='桥也星河:BAAALgAECgYJDQAAAA==.桥也银河:BAAALgAECgEJAQAAAA==.',
['梦深']='梦深渊:BAAALgAECgMJAwAAAA==.',
['橘子']='橘子:BAAALgADCgYJAgAAAA==.',
['死咪']='死咪羊眼:BAAALgAECgYJBgAAAA==.',
['残影']='残影:BAABLgAECn8YAAMHAAcJvAzfKgBvAQAHAAcJvAzfKgBvAQAIAAEJfgFT9QAZAAAAAA==.',
['毁灭']='毁灭烈:BAAALgAECgYJDAAAAA==.',
['江天']='江天君:BAABLgAECn8cAAITAAgJGSRyBgALAwATAAgJGSRyBgALAwAAAA==.',
['江湖']='江湖小法:BAAALgAECgEJAgAAAA==.',
['沁水']='沁水流萤:BAAALgADCgEJAQAAAA==.',
['沿海']='沿海地带:BAAALgAECgYJBgAAAA==.',
['法力']='法力惊人:BAAALgAECgQJBwAAAA==.',
['泪流']='泪流满面:BAAALgAECgYJBgAAAA==.',
['泰达']='泰达希尔之殇:BAAALgAECgEJAQAAAA==.',
['流浪']='流浪的螺丝钉:BAAALgAECgEJAQAAAA==.',
['海格']='海格拉:BAAALgAECgEJAQAAAA==.',
['涅槃']='涅槃丨獵:BAAALgAECgEJAgAAAA==.涅槃丨琺:BAAALgAECgEJAwAAAA==.',
['溪下']='溪下雪舞:BAAALgAECgQJBgAAAA==.',
['灬緣']='灬緣芳灬:BAAALgAECgEJAQAAAA==.',
['灾难']='灾难慢我一步:BAAALgAECgEJAQAAAA==.',
['热带']='热带鱼:BAABLgAECn8dAAIMAAcJwR/EPQCBAgAMAAcJwR/EPQCBAgAAAA==.',
['焰色']='焰色记弋:BAAALgAECgkJCQAAAA==.',
['熊丶']='熊丶小兔:BAAALgAECgEJAgAAAA==.',
['爆一']='爆一只响一只:BAAALgAECgkJBwAAAA==.',
['爆三']='爆三只响三只:BAAALgAECgkJBAAAAA==.',
['爆两']='爆两只响两只:BAABLgAECn8VAAMSAAkJxhEaOQAnAgASAAkJxhEaOQAnAgAUAAEJAAAWbQA6AAAAAA==.',
['爆五']='爆五只响五只:BAAALgAECgkJEQAAAA==.',
['爆肆']='爆肆只响肆只:BAAALgAECgkJCQAAAA==.',
['狂怒']='狂怒腾德尔:BAAALgAECgQJBAAAAA==.',
['狂扁']='狂扁小朋友:BAAALgAECgEJAQAAAA==.',
['狂风']='狂风怒号:BAACLgAFFH8PAAITAAQJoR+SAgBmAQATAAQJoR+SAgBmAQAuAAQKfysAAxMACQkzIaAGAAgDABMACQkzIaAGAAgDABUABwniHa8rALoBAAAA.',
['狸花']='狸花猫丶:BAAALgADCgcJCgAAAA==.',
['猛男']='猛男:BAAALgADCgUJBQAAAA==.',
['王照']='王照东:BAAALgAECgEJAQAAAA==.',
['番茄']='番茄炒番茄:BAAALgAFFAQJBAAAAA==.番茄鸡肉:BAAALgAFFAQJBAAAAA==.番茄鼻诗:BAAALgAFFAQJBAAAAA==.',
['疙瘩']='疙瘩刘坤爸爸:BAABLgAFFH8HAAIBAAUJMAUzHwAgAQABAAUJMAUzHwAgAQAAAA==.',
['白帝']='白帝:BAAALgAECgEJAgAAAA==.',
['白狼']='白狼丶:BAAALgADCgUJBQAAAA==.',
['白色']='白色暴雨:BAAALgAECgMJAwAAAA==.',
['瞬曦']='瞬曦:BAAALgADCgEJAQAAAA==.',
['矢心']='矢心无二:BAAALgAECgcJCQAAAA==.',
['神都']='神都扛得住:BAAALgAECgMJAwAAAA==.',
['童磨']='童磨:BAAALgAFFAIJAgAAAA==.',
['紫氣']='紫氣东来:BAAALgADCgIJAgAAAA==.',
['红樱']='红樱粟丶花火:BAABLgAECn8ZAAIMAAkJMhsyGgAPAwAMAAkJMhsyGgAPAwAAAA==.',
['终觉']='终觉浅:BAAALgAECgEJAgAAAA==.',
['群众']='群众里有坏人:BAAALgAECgEJAQAAAA==.',
['耐奶']='耐奶德:BAAALgAECgIJAgAAAA==.',
['聆岚']='聆岚:BAAALgAFFAIJBAAAAA==.',
['胖橘']='胖橘子:BAAALgADCgYJCAAAAA==.',
['胡子']='胡子圣骑:BAAALgAECgkJCQAAAA==.',
['花卷']='花卷一号:BAAALgAECgkJEAAAAA==.花卷二号:BAAALgAECgkJDAAAAA==.',
['苦咖']='苦咖啡:BAAALgADCgUJBQAAAA==.',
['萬次']='萬次:BAAALgAECgYJCAAAAA==.',
['蒲公']='蒲公英不会飞:BAAALgAECgUJCAAAAA==.',
['蓦然']='蓦然回首:BAAALgADCgQJBAAAAA==.',
['藏镜']='藏镜人:BAAALgAFFAEJAgAAAA==.',
['蝉悠']='蝉悠悠:BAAALgAECgkJCQAAAA==.',
['訬吥']='訬吥钶唁:BAAALgADCgEJAQAAAA==.',
['说你']='说你爱我:BAAALgAECgIJAQAAAA==.',
['诸神']='诸神丶心雨:BAABLgAFFH8IAAQWAAUJRhm/HQBnAAAWAAEJ0SG/HQBnAAAXAAEJ+RILJgBRAAAYAAUJOxYAAAAAAAABLgAFFAUJEAADAGccAA==.',
['诸葛']='诸葛暗:BAAALgADCgYJBgAAAA==.',
['走路']='走路抖露手:BAAALgAFFAQJBAAAAA==.',
['走错']='走错:BAAALgAFFAIJAwAAAA==.',
['超大']='超大的西瓜:BAAALgAECgQJBQAAAA==.',
['轩辕']='轩辕阿骨打:BAACLgAFFH8RAAIBAAYJIRtnAgDvAQABAAYJIRtnAgDvAQAuAAQKfxYAAgEACAlPIfYkAKkCAAEACAlPIfYkAKkCAAAA.',
['辛多']='辛多雷的荣耀:BAAALgAFFAEJAgAAAA==.',
['逍遥']='逍遥之德:BAAALgAECgYJCwAAAA==.',
['遇见']='遇见晴天:BAAALgAECgEJAQAAAA==.',
['邦桑']='邦桑迪:BAAALgAECgcJBgAAAA==.',
['郊外']='郊外达西姆:BAAALgAECgMJBQAAAA==.',
['铁锈']='铁锈:BAAALgAECgUJBwAAAA==.',
['银发']='银发阿基多:BAAALgAECgIJAQAAAA==.',
['阿叁']='阿叁:BAAALgAECgYJDAAAAA==.',
['阿法']='阿法修罗:BAAALgADCgcJDAAAAA==.',
['阿良']='阿良丶:BAAALgAECgkJCwAAAA==.',
['陈平']='陈平安:BAABLgAFFH8JAAICAAUJvhbJBACkAQACAAUJvhbJBACkAQAAAA==.陈平安丶:BAAALgAECgQJBAAAAA==.',
['陶陶']='陶陶是老大:BAAALgAECgEJAgAAAA==.',
['雪白']='雪白奶牧:BAACLgAFFH8JAAMZAAQJpghADADtAAAZAAMJBglADADtAAANAAIJshB8EgChAAAuAAQKfyEABBkACAlMHGUQAIECABkABwm9H2UQAIECAA0ABwlBHPwSABkCABoAAQniJHtxAGEAAAAA.',
['雷熔']='雷熔:BAAALgAECgMJBAAAAA==.',
['静大']='静大人的猫:BAAALgAECgUJCAAAAA==.',
['风灵']='风灵薇:BAAALgAECgIJAgAAAA==.',
['飞羽']='飞羽狂魔:BAAALgADCgEJAQAAAA==.',
['首席']='首席烤串儿:BAAALgADCgYJBgAAAA==.',
['魅惑']='魅惑嗳:BAABLgAECn8WAAISAAkJSxDmOAAoAgASAAkJSxDmOAAoAgAAAA==.',
['鸑鷟']='鸑鷟之时:BAAALgAECgEJAQAAAA==.',
['龙希']='龙希尔瓦纳斯:BAACLgAFFH8QAAMDAAUJZxyEBADDAQADAAUJZxyEBADDAQAbAAMJQxB7BAD6AAAuAAQKfx8AAwMACAkyINgIAOoCAAMACAnpH9gIAOoCABsABwmQFS0RAMwBAAAA.',
['龙龙']='龙龙来喔:BAAALgAFFAMJBAABLgAFFAQJDQABAHAZAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
