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

local lookup = {'Shaman-Restoration','Paladin-Retribution','Warlock-Demonology','Priest-Holy','DeathKnight-Blood','Priest-Discipline','Monk-Brewmaster','DeathKnight-Frost','Hunter-BeastMastery','Hunter-Marksmanship','Unknown-Unknown','DeathKnight-Unholy','Paladin-Holy','Priest-Shadow','Mage-Frost','Mage-Fire','Evoker-Devastation','Evoker-Augmentation','Warlock-Destruction','Monk-Windwalker','DemonHunter-Devourer',}
local provider = {region='CN',realm='末日祷告祭坛',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Andy:BAAALgAECgEJAQAAAA==.',
Be='Beyllos:BAAALgAFFAEJAQAAAA==.',
Ch='Chenelle:BAAALgAECgUJCQAAAA==.',
Co='Comet:BAAALgAECgUJBgAAAA==.',
Cr='Crucible:BAAALgAECgEJAQAAAA==.',
Di='Dina:BAAALgAECgEJAgAAAA==.',
Fa='Faris:BAAALgAECgkJDwAAAA==.',
Ho='Hoh:BAAALgADCgEJAQAAAA==.Hohohh:BAAALgAECggJDgAAAA==.',
Ja='Jasonwswswws:BAAALgAECgIJAgAAAA==.',
Ke='Keluotar:BAABLgAECn8cAAIBAAcJbheILADZAQABAAcJbheILADZAQAAAA==.',
Kr='Kristing:BAAALgAECgEJAQAAAA==.',
Li='Lilamy:BAAALgAECgEJAgAAAA==.',
Ma='Maple:BAAALgAECgQJBAAAAA==.',
Nb='Nb:BAAALgAECgcJDQAAAA==.',
Ne='Neticle:BAAALgAECgcJDQAAAA==.',
Ni='Nirvanapal:BAACLgAFFH8FAAICAAIJPgqHEQCYAAACAAIJPgqHEQCYAAAuAAQKfykAAgIACAkhF1c2AEkCAAIACAkhF1c2AEkCAAAA.',
Pr='Prionailurus:BAAALgAECgcJDgABLgAFFAUJCQABAHoNAA==.',
Pu='Purplemaple:BAAALgADCgUJBQAAAA==.',
Sh='Shallowdream:BAACLgAFFH8DAAIDAAIJ4xx2RABaAAADAAIJ4xx2RABaAAAuAAQKfw8AAgMACAkKIZEkAIECAAMACAkKIZEkAIECAAAA.',
To='Tolerance:BAAALgAECgYJBgAAAA==.Touchme:BAAALgAECgkJDAAAAA==.',
Tt='Ttcc:BAAALgADCgEJAQAAAA==.',
Wa='Warglaive:BAAALgAFFAIJAgAAAA==.',
Wh='Whatcanisay:BAAALgADCgEJAQAAAA==.',
Xi='Xiya:BAAALgAECgkJCQAAAA==.',
['一口']='一口啃死你:BAAALgADCgYJBgAAAA==.',
['一只']='一只小笨熊:BAAALgADCgMJAwAAAA==.',
['一碗']='一碗烧肉:BAAALgADCgYJBgAAAA==.',
['一锅']='一锅烧肉:BAABLgAECn8WAAIEAAcJ7yQUBgDuAgAEAAcJ7yQUBgDuAgAAAA==.',
['万剑']='万剑穿心:BAAALgAFFAEJAgAAAA==.',
['三冄']='三冄初:BAAALgAECgIJAgAAAA==.',
['三聚']='三聚氰胺丶:BAAALgADCgEJAQAAAA==.',
['不空']='不空劫:BAABLgAFFH8IAAIFAAUJdA0pBgA1AQAFAAUJdA0pBgA1AQAAAA==.',
['丨丶']='丨丶燕京:BAAALgAECgEJAQAAAA==.',
['丨天']='丨天火丨:BAAALgAFFAIJAgAAAA==.',
['丨小']='丨小熊宝宝丨:BAAALgADCgYJBgAAAA==.',
['丨泡']='丨泡泡茶壶丨:BAAALgAECgUJBQAAAA==.',
['丶玛']='丶玛丽莲曼森:BAAALgAFFAEJAQAAAA==.',
['为国']='为国捐躯:BAAALgAECgEJAQAAAA==.',
['乱射']='乱射丶:BAAALgAECgEJAgAAAA==.',
['亦丶']='亦丶如歌:BAAALgADCgcJBwABLgAFFAIJCQAGAIMkAA==.',
['亲灬']='亲灬爱灬的:BAAALgAECgEJAwAAAA==.',
['人生']='人生三状态:BAAALgAECgEJAQAAAA==.',
['今宵']='今宵别梦寒:BAACLgAFFH8HAAIHAAIJxRbAGgCUAAAHAAIJxRbAGgCUAAAuAAQKfxYAAgcACAm2IMEMAMQCAAcACAm2IMEMAMQCAAAA.',
['今晚']='今晚吃点好的:BAAALgAECgYJCQAAAA==.',
['代达']='代达罗斯之殇:BAAALgADCgEJAQAAAA==.',
['伊露']='伊露露:BAAALgADCgEJAQAAAA==.',
['伞明']='伞明月:BAAALgAECgIJAgAAAA==.',
['佩恩']='佩恩苍穹:BAAALgADCgEJAQAAAA==.',
['依赖']='依赖彼此丶:BAAALgAECgUJBQAAAA==.',
['兮兮']='兮兮赫赫:BAAALgAECgMJAwAAAA==.',
['农妇']='农妇灬三拳:BAAALgADCgcJBwAAAA==.',
['农村']='农村三四等人:BAAALgAECgQJBQAAAA==.',
['冷吟']='冷吟闲醉:BAAALgAECgkJCAAAAA==.',
['凭负']='凭负轻狂丶:BAAALgAECgEJAQAAAA==.',
['凯南']='凯南开大啊:BAAALgAECgYJBgAAAA==.',
['划伤']='划伤天空的泪:BAABLgAFFH8IAAIIAAMJ5RjTAAAdAQAIAAMJ5RjTAAAdAQAAAA==.',
['别云']='别云涧:BAAALgAFFAEJAQAAAA==.',
['加茂']='加茂宪纪:BAAALgADCgUJBQAAAA==.',
['十五']='十五五:BAAALgAECgEJAQAAAA==.',
['华北']='华北第一痴情:BAAALgAECgYJBgAAAA==.',
['南梵']='南梵:BAAALgAECgYJDAAAAA==.',
['博文']='博文丶风行者:BAACLgAFFH8HAAIJAAIJkRxAEQC/AAAJAAIJkRxAEQC/AAAuAAQKfxYAAwkACAn7IPcOAMQCAAkACAn7IPcOAMQCAAoAAQnuCaONAC0AAAAA.',
['卡卡']='卡卡罗特密:BAAALgAECgQJBQABLgAECgYJCgALAAAAAA==.',
['卷卷']='卷卷:BAAALgAECgYJCAAAAA==.',
['又睡']='又睡卌一分钟:BAAALgAFFAUJBAAAAA==.',
['古尔']='古尔加个丹:BAAALgAECgEJAQAAAA==.古尔加个蛋:BAAALgADCgMJAwAAAA==.',
['只吃']='只吃画的饼:BAAALgAFFAIJAgAAAA==.',
['咕噜']='咕噜:BAAALgAECgEJAQAAAA==.',
['咸鱼']='咸鱼草莓:BAABLgAFFH8FAAIMAAMJ6RvgIQAQAQAMAAMJ6RvgIQAQAQAAAA==.',
['啊豺']='啊豺:BAAALgADCgMJAwAAAA==.',
['喜碧']='喜碧:BAAALgAFFAIJBAAAAA==.',
['喵哆']='喵哆哩:BAAALgAECgUJBgAAAA==.',
['四象']='四象祖:BAAALgADCgUJBQAAAA==.',
['圆脸']='圆脸的小西瓜:BAAALgAECgUJBwAAAA==.',
['圣光']='圣光的荣耀:BAAALgAECgUJBwAAAA==.',
['地誓']='地誓:BAABLgAFFH8NAAINAAUJYgh7BgBwAQANAAUJYgh7BgBwAQAAAA==.',
['坠茵']='坠茵落溷:BAAALgAFFAEJAQAAAA==.',
['大肥']='大肥龙:BAAALgADCgUJBQAAAA==.',
['大饼']='大饼卷万物:BAAALgAECgYJBgAAAA==.',
['天珩']='天珩:BAABLgAFFH8MAAINAAQJYQcgBQAWAQANAAQJYQcgBQAWAQAAAA==.',
['天青']='天青色等焑雨:BAACLgAFFH8JAAIGAAIJgyScDwDVAAAGAAIJgyScDwDVAAAuAAQKfxQABAQABwmSICoeAO0BAAQABgkLICoeAO0BAA4ABgkbGk0jAL0BAAYABAnQFq0zAAUBAAAA.',
['失眠']='失眠阿:BAAALgAECgEJBAAAAA==.',
['奈莫']='奈莫:BAAALgAECgYJDwAAAA==.',
['宇文']='宇文姑姑:BAAALgAECgYJCwAAAA==.',
['宛如']='宛如少女的猫:BAAALgAECgcJBgABLgAFFAQJCgAKAGEcAA==.',
['害人']='害人饿瘦:BAAALgADCgMJAwAAAA==.',
['小小']='小小之兽术:BAAALgAECgEJAQAAAA==.小小萨丶:BAAALgAECgYJBgABLgAFFAEJAQALAAAAAA==.',
['小灬']='小灬蝈蝈:BAACLgAFFH8HAAIPAAMJ1h/vIwAnAQAPAAMJ1h/vIwAnAQAuAAQKfxYAAw8ACAkMF7dKAFcCAA8ACAkMF7dKAFcCABAAAQnYBA4RAC4AAAAA.',
['小狐']='小狐涂神:BAAALgAECgEJAQAAAA==.',
['小白']='小白心里软:BAAALgAECgYJBgAAAA==.',
['小蛋']='小蛋仔:BAAALgAECgIJAgAAAA==.',
['小蜜']='小蜜蜂摸电门:BAAALgADCgIJAgAAAA==.',
['小龙']='小龙虾:BAACLgAFFH8KAAIRAAQJQxCKAwAkAQARAAQJQxCKAwAkAQAuAAQKfyMAAxEACAlvHsYDANwCABEACAlvHsYDANwCABIABAlqCd5MAJ4AAAAA.',
['尙丶']='尙丶小德:BAACLgAFFH8FAAIKAAUJGSBMBQDWAQAKAAUJGSBMBQDWAQAuAAQKfxQAAgkACAlRFjMhAD4CAAkACAlRFjMhAD4CAAAA.',
['巧克']='巧克力酸奶:BAAALgAECgYJCgAAAA==.',
['布劳']='布劳缪克斯:BAAALgAFFAIJAgAAAA==.',
['广式']='广式陈皮兔球:BAAALgAFFAQJBAAAAA==.',
['当我']='当我宠物好么:BAAALgAECgMJAwAAAA==.',
['徐林']='徐林森:BAAALgADCggJCAAAAA==.',
['忽闪']='忽闪忽现:BAAALgAECgYJBwAAAA==.',
['怒丶']='怒丶风:BAAALgAECgMJBQAAAA==.',
['我慢']='我慢:BAAALgAECgIJAgAAAA==.',
['我零']='我零落的思絮:BAAALgAECgEJAQAAAA==.',
['户山']='户山香澄:BAAALgAECgYJBgAAAA==.',
['招风']='招风耳:BAAALgAECgEJAQAAAA==.',
['拾字']='拾字路口:BAAALgAECgEJAQAAAA==.',
['撒娇']='撒娇艳后:BAAALgAECgIJAgAAAA==.',
['教堂']='教堂丶:BAACLgAFFH8GAAIDAAMJTw0TEADzAAADAAMJTw0TEADzAAAuAAQKfxYAAxMACAmsFi4pAB0BABMABAlyGC4pAB0BAAMABAlXFeSzAPEAAAAA.',
['斯卡']='斯卡文奴隶鼠:BAAALgAECgEJAQAAAA==.',
['无尽']='无尽顿悟:BAAALgAECgEJAQAAAA==.',
['无所']='无所不用其极:BAAALgAECgYJBwAAAA==.',
['无敌']='无敌格瓦拉:BAAALgAECgIJAgAAAA==.',
['无酒']='无酒我亦癫:BAAALgAECgMJAwAAAA==.',
['时雨']='时雨秋风:BAAALgAECgYJBwAAAA==.',
['星光']='星光不坠:BAABLgAFFH8JAAIPAAMJsRa5KAARAQAPAAMJsRa5KAARAQAAAA==.',
['星空']='星空下的风:BAAALgAECgEJAQAAAA==.星空葬闲:BAAALgADCgUJBQAAAA==.',
['昨夜']='昨夜长安:BAAALgAFFAEJAQAAAA==.',
['暗夜']='暗夜呢喃:BAAALgAECgUJBQAAAA==.',
['暗黑']='暗黑黄晓明:BAAALgAECgYJBgAAAA==.',
['月城']='月城丶博文:BAAALgAECgUJBQAAAA==.',
['杂烩']='杂烩饭丶:BAAALgAECgQJBQAAAA==.',
['枯法']='枯法:BAAALgADCgUJBQAAAA==.',
['桶装']='桶装天才:BAAALgADCggJCAAAAA==.',
['梅里']='梅里奥达斯:BAAALgAECgcJCwAAAA==.',
['歪比']='歪比巴布:BAAALgAFFAIJAwAAAA==.',
['死亡']='死亡低吟者:BAAALgADCgUJBQAAAA==.',
['水無']='水無月白:BAABLgAECn8cAAIUAAgJaR4hDQCoAgAUAAgJaR4hDQCoAgAAAA==.',
['永不']='永不复还:BAAALgAECgIJAgAAAA==.',
['沉默']='沉默能换钱:BAAALgAECgIJAgAAAA==.',
['沐清']='沐清歌:BAAALgAECgIJAwAAAA==.',
['没事']='没事来看看:BAAALgAECgEJAQAAAA==.',
['河豚']='河豚住在水里:BAAALgAECgcJCgAAAA==.',
['泡泡']='泡泡丶茶壶:BAAALgADCgMJAQAAAA==.',
['洛河']='洛河之灵:BAAALgAECgQJBAAAAA==.',
['洛繁']='洛繁希:BAAALgAECgcJEQAAAA==.',
['渡我']='渡我十方:BAAALgAECgYJDAABLgAECgYJHAAPAMUjAA==.',
['渣叔']='渣叔丶:BAAALgAECggJDgAAAA==.',
['漫磋']='漫磋嗟:BAAALgAECgIJAgAAAA==.',
['澳龙']='澳龙:BAAALgAECgYJCgABLgAFFAQJCgARAEMQAA==.',
['灌注']='灌注来喽:BAAALgAECgEJAQAAAA==.',
['火锅']='火锅仙人:BAAALgAFFAIJBAABLgAFFAYJFAAMAJgcAA==.',
['灬初']='灬初丶心灬:BAAALgAECgUJBQAAAA==.',
['灬怀']='灬怀念灬:BAAALgAECgIJBAAAAA==.',
['灬惠']='灬惠灬:BAAALgAECgYJCAAAAA==.',
['灬流']='灬流灬年灬:BAAALgAECgEJAgAAAA==.',
['灬神']='灬神丶韵灬:BAAALgAECgEJAQAAAA==.',
['灬闪']='灬闪丨电灬:BAAALgADCgUJBQAAAA==.',
['烟雨']='烟雨丶任平生:BAAALgAECgEJAQAAAA==.',
['烫最']='烫最靓的头:BAAALgAECgYJCQAAAA==.',
['煞尾']='煞尾:BAAALgAECgQJBgAAAA==.',
['熙阳']='熙阳:BAAALgADCgEJAQAAAA==.',
['燚龖']='燚龖:BAAALgAECgYJBgAAAA==.',
['爱灵']='爱灵灵:BAAALgAECgkJAQAAAA==.',
['牛牛']='牛牛也学法:BAAALgADCgMJAwAAAA==.',
['牧歌']='牧歌:BAAALgAECgYJBgAAAA==.',
['狂划']='狂划水:BAAALgAECgYJBgAAAA==.',
['狄奥']='狄奥尼索斯:BAAALgAFFAEJAQAAAA==.',
['独角']='独角戏丶:BAAALgAECgEJAQAAAA==.',
['猛又']='猛又壮:BAAALgAECgEJAQAAAA==.',
['王出']='王出去:BAAALgAECgQJBgAAAA==.',
['王失']='王失眠:BAAALgAECgIJAwAAAA==.',
['疯狂']='疯狂的蛋挞:BAAALgAECgQJBAAAAA==.',
['瘦肉']='瘦肉丸子:BAAALgAECgEJAgAAAA==.',
['白日']='白日夢:BAAALgAECgQJCAAAAA==.',
['白昼']='白昼夣:BAAALgADCgYJBgAAAA==.',
['白流']='白流苏:BAAALgAECgEJAQAAAA==.',
['白花']='白花蛇草水:BAAALgAECgYJBgAAAA==.',
['白铁']='白铁氏族:BAAALgAECgQJBAAAAA==.白铁氏族狗蛋:BAAALgAFFAIJAwAAAA==.',
['百发']='百发零中:BAAALgADCgYJCQAAAA==.',
['真壁']='真壁政宗君:BAAALgAECgYJBgAAAA==.',
['祐天']='祐天寺喵梦:BAAALgAECgEJAQAAAA==.',
['祖拉']='祖拉莱克:BAABLgAFFH8MAAINAAUJxAWmAgBvAQANAAUJxAWmAgBvAQAAAA==.',
['禅雅']='禅雅塔:BAAALgAECgMJAwAAAA==.',
['穷凶']='穷凶丶极恶:BAAALgAECgcJBwAAAA==.',
['穷奇']='穷奇丶:BAABLgAFFH8FAAINAAUJUALSBwBUAQANAAUJUALSBwBUAQAAAA==.',
['笑笑']='笑笑小奶狸:BAABLgAFFH8FAAIBAAMJPCIpCgAyAQABAAMJPCIpCgAyAQAAAA==.',
['米尔']='米尔汀:BAAALgADCgYJBgAAAA==.',
['精灵']='精灵宝宝:BAAALgADCgIJAQABLgAECgYJCgALAAAAAA==.精灵者法也:BAAALgAECgEJAQAAAA==.',
['糖皮']='糖皮儿:BAAALgADCgUJBQAAAA==.',
['紳士']='紳士范丶:BAAALgAECgcJBwAAAA==.',
['红太']='红太阳:BAAALgAECgUJBQAAAA==.',
['红豆']='红豆绵绵冰:BAAALgAFFAEJAQAAAA==.',
['网恋']='网恋秀牛被录:BAABLgAFFH8JAAISAAQJWxqgCQBVAQASAAQJWxqgCQBVAQAAAA==.',
['肉蚌']='肉蚌冲鸡:BAAALgAECgEJAQAAAA==.',
['胡恩']='胡恩丶高岭:BAAALgADCgIJAgAAAA==.',
['膨胀']='膨胀的酒桶:BAAALgAECgUJBQAAAA==.',
['芃芃']='芃芃其麦:BAAALgAECgYJBgAAAA==.',
['芥末']='芥末玛奇朵:BAAALgADCgIJAgAAAA==.',
['花小']='花小惩:BAAALgAECgMJAwAAAA==.',
['花重']='花重锦官:BAAALgAECgYJCgAAAA==.',
['荼毒']='荼毒:BAAALgADCgUJBQAAAA==.',
['莫莫']='莫莫:BAABLgAECn8VAAIJAAcJgwxVQwCiAQAJAAcJgwxVQwCiAQAAAA==.',
['萨拉']='萨拉塔斯的狗:BAAALgADCgYJBgAAAA==.',
['蓝雾']='蓝雾碎碎冰:BAABLgAECn8cAAIPAAYJxSNqQAB4AgAPAAYJxSNqQAB4AgAAAA==.',
['薄荷']='薄荷灬凉音弦:BAAALgADCgcJBwAAAA==.',
['蘑蘑']='蘑蘑:BAAALgAECgEJAQAAAA==.',
['虚空']='虚空丶别天神:BAAALgAECgYJBgAAAA==.虚空丶残星泪:BAAALgADCgQJBAAAAA==.虚空丶深藏:BAAALgADCgUJBQABLgAECgEJAQALAAAAAA==.虚空丶肆季:BAAALgAECgYJBgAAAA==.虚空丶藏功名:BAAALgAECggJBwAAAA==.',
['血月']='血月星河:BAAALgAECgUJBgAAAA==.',
['行者']='行者丶风:BAAALgAECgYJBgAAAA==.',
['西瓜']='西瓜西瓜:BAAALgAECgYJBgAAAA==.',
['记忆']='记忆的线丶:BAAALgAECgEJAQAAAA==.',
['诗情']='诗情画意得雪:BAAALgAECgYJCgABLgAFFAYJDgADAA8YAA==.',
['诣太']='诣太素:BAAALgAFFAUJBAABLgAFFAUJCAAFAHQNAA==.',
['诸葛']='诸葛高兴:BAAALgAECgcJDQAAAA==.',
['谁的']='谁的神话:BAAALgAECgQJCAAAAA==.',
['谐能']='谐能领主:BAAALgADCgYJBgAAAA==.',
['豌豆']='豌豆荚:BAAALgADCgEJAQAAAA==.',
['轰二']='轰二零:BAAALgAECgEJAQAAAA==.',
['轻轻']='轻轻松啦丶:BAABLgAFFH8JAAIVAAMJfggQLgCOAAAVAAMJfggQLgCOAAAAAA==.',
['轻雨']='轻雨涟漪:BAAALgAECgYJCwAAAA==.',
['辣翅']='辣翅:BAAALgAECgYJCAAAAA==.',
['迪克']='迪克牛崽:BAAALgAFFAEJAQAAAA==.',
['醉梦']='醉梦韶华:BAAALgADCgEJAQABLgAFFAUJAgALAAAAAA==.',
['醉迷']='醉迷人最危险:BAAALgAECgYJCAAAAA==.',
['铁哥']='铁哥们:BAAALgAECgUJBQAAAA==.',
['阿兰']='阿兰克斯:BAABLgAECn8WAAIMAAYJOxn2dACcAQAMAAYJOxn2dACcAQAAAA==.',
['阿尔']='阿尔托莉娅丿:BAAALgADCgMJAwAAAA==.',
['阿席']='阿席达卡:BAAALgAFFAQJAwAAAA==.',
['阿曼']='阿曼苏尔预见:BAAALgAECgEJAQAAAA==.',
['雪落']='雪落丶轻语:BAAALgAECgEJAQAAAA==.',
['顺其']='顺其自然:BAAALgAECgIJAgAAAA==.',
['飘渺']='飘渺灬幻梦:BAAALgAECgEJAQAAAA==.',
['饕餮']='饕餮:BAABLgAFFH8PAAINAAUJEwvgBQB9AQANAAUJEwvgBQB9AQAAAA==.',
['马论']='马论:BAAALgAECgYJBgAAAA==.',
['驯猪']='驯猪高手:BAAALgAECgcJDQAAAA==.',
['驲川']='驲川冈坂:BAAALgAECgUJBwAAAA==.',
['鸟熊']='鸟熊猫:BAAALgAECgIJAgAAAA==.',
['麋鹿']='麋鹿遇见菟:BAAALgAFFAIJAgAAAA==.',
['黑土']='黑土丶:BAABLgAFFH8IAAINAAQJoge4BAAkAQANAAQJoge4BAAkAQAAAA==.',
['龙卷']='龙卷风停车场:BAAALgAECgEJAQAAAA==.',
['龙渊']='龙渊:BAAALgAECgcJCAAAAA==.',
['龙野']='龙野:BAAALgADCgMJAwAAAA==.',
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
