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

local lookup = {'Priest-Holy','Priest-Discipline','Unknown-Unknown','Shaman-Elemental','Paladin-Retribution','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Demonology','Warlock-Destruction','Mage-Frost','Shaman-Restoration','DeathKnight-Blood','Rogue-Subtlety','Paladin-Holy','DemonHunter-Devourer','Monk-Windwalker','Shaman-Enhancement','Monk-Brewmaster','Druid-Balance','Druid-Restoration','Rogue-Assassination','Warrior-Arms','Druid-Feral','Hunter-Survival','Monk-Mistweaver',}
local provider = {region='CN',realm='斯坦索姆',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adavak:BAABLgAECn8bAAMBAAkJlCLZAACLAwABAAkJlCLZAACLAwACAAIJOBV3RQCNAAAAAA==.',
Ae='Aeolos:BAAALgADCgcJDQAAAA==.',
Ak='Akio:BAAALgAECgQJBAAAAA==.',
At='Atrueno:BAAALgAECgkJEAAAAA==.',
Be='Beaiuo:BAAALgAECgQJBAABLgAFFAEJAQADAAAAAA==.',
Bl='Blight:BAAALgAECgMJBAAAAA==.',
Bt='Btrueno:BAABLgAFFH8FAAIEAAQJ1RdAFACrAAAEAAQJ1RdAFACrAAAAAA==.',
Co='Coastbreaker:BAABLgAFFH8GAAIFAAMJqyT2CwBMAQAFAAMJqyT2CwBMAQAAAA==.',
Cr='Creepwj:BAAALgAECgIJBAAAAA==.Crixus:BAAALgAFFAQJBAAAAA==.',
Ct='Ctrueno:BAABLgAFFH8IAAIEAAQJuhxmCABVAQAEAAQJuhxmCABVAQAAAA==.',
Cu='Cutemiaomiao:BAAALgAECgcJDgAAAA==.',
Da='Damforce:BAAALgAECgEJAQAAAA==.',
De='Deepsuck:BAAALgAECgEJAQAAAA==.',
Do='Dodo:BAAALgAFFAEJAgAAAA==.',
Dt='Dtrueno:BAABLgAFFH8GAAIEAAQJcRdnAgBWAQAEAAQJcRdnAgBWAQAAAA==.',
Eg='Ego:BAABLgAFFH8JAAMGAAUJNRFvCAABAQAGAAMJsQ5vCAABAQAHAAMJXxX2FQDrAAAAAA==.',
El='Elidibus:BAAALgAECgEJAQAAAA==.',
Fu='Fukmonk:BAAALgAECgYJBgAAAA==.',
Gr='Grayhowl:BAAALgAFFAIJAgABLgAFFAEJAQADAAAAAA==.',
Ic='Icefish:BAAALgAECgQJBQAAAA==.',
It='Itrueno:BAAALgAECgkJBwAAAA==.',
Ji='Jienne:BAAALgAECgUJDAAAAA==.',
Jt='Jtrueno:BAACLgAFFH8IAAIEAAQJJx2sBgBwAQAEAAQJJx2sBgBwAQAuAAQKfxYAAgQACQntHVgEAFgDAAQACQntHVgEAFgDAAAA.',
Ka='Kathera:BAAALgAECgYJBgABLgAFFAEJAQADAAAAAA==.',
Kc='Kcalb:BAAALgAECgcJBwAAAA==.',
Kt='Ktrueno:BAAALgAECgkJEAAAAA==.',
Le='Leblanc:BAAALgAECgUJCAAAAA==.',
Ly='Lynn:BAAALgAECgYJCgAAAA==.',
Ma='Magician:BAACLgAFFH8QAAMIAAUJXSQsFABJAQAIAAMJwiUsFABJAQAJAAIJ+CK8CADRAAAuAAQKfyQAAwgACAkFI9cdAKMCAAgABwmKItcdAKMCAAkABQndGbgbAG8BAAAA.',
Mi='Mirala:BAAALgAECgUJBgAAAA==.',
Mt='Mtrueno:BAAALgAFFAQJBAAAAA==.',
Nt='Ntrueno:BAAALgAECgkJBwAAAA==.',
On='Onblind:BAAALgAECgEJAQAAAA==.',
Ov='Overdue:BAAALgADCgEJAQAAAA==.',
Pe='Pekka:BAACLgAFFH8OAAIIAAUJlBopBgC+AQAIAAUJlBopBgC+AQAuAAQKfywAAwgACQleIlYpAGsCAAgACAlTIlYpAGsCAAkABAl/IAYdAGYBAAAA.',
Pi='Pinkhh:BAAALgAECgEJAQAAAA==.',
Pl='Playerkvhsfy:BAAALgADCgcJBwAAAA==.',
Rq='Rqwesfsa:BAABLgAFFH8GAAIKAAYJoRRtAQDLAQAKAAYJoRRtAQDLAQAAAA==.',
St='Stillsexy:BAAALgAFFAEJAQABLgAFFAUJEAAKAJURAA==.',
Th='Thieve:BAAALgAECgYJBgABLgAFFAEJAQADAAAAAA==.',
To='Toohot:BAAALgAFFAEJAQAAAA==.',
Tr='Trueno:BAAALgAECgcJBgAAAA==.',
Tt='Ttrueno:BAAALgAECgkJBAAAAA==.',
Tu='Tuyy:BAAALgAECgcJDQAAAA==.',
Ut='Utrueno:BAAALgAECgkJCQAAAA==.',
Yl='Yl:BAAALgAECgUJBQAAAA==.',
Zu='Zuluxidesg:BAAALgADCgUJBQAAAA==.',
['一于']='一于放生队友:BAAALgAECgUJBQAAAA==.',
['一只']='一只烤鸭丶:BAAALgADCgEJAQAAAA==.',
['一啪']='一啪即合:BAAALgAFFAEJAgAAAA==.',
['一灯']='一灯亅大师:BAAALgAECgIJAgAAAA==.',
['丁香']='丁香與醋栗:BAAALgAECgUJBQAAAA==.',
['万万']='万万:BAAALgAECgYJBwAAAA==.',
['世纪']='世纪末魔术师:BAAALgAECgEJAQAAAA==.',
['丨仗']='丨仗箭行天下:BAAALgAECgQJBgAAAA==.',
['丶夜']='丶夜刃豹:BAAALgADCgYJBgAAAA==.',
['丶微']='丶微蒙:BAAALgAECgEJAQAAAA==.',
['丶木']='丶木:BAAALgADCgkJCQAAAA==.',
['丶清']='丶清风无痕:BAAALgAECgEJAQAAAA==.',
['丶雪']='丶雪落无痕:BAAALgAECgEJAQAAAA==.',
['丶风']='丶风过无痕:BAAALgAECgEJAQAAAA==.',
['丷小']='丷小绿龙儿丷:BAAALgADCgQJBAAAAA==.',
['乀邪']='乀邪念:BAAALgAECgQJBAAAAA==.',
['乌瑟']='乌瑟尔乄剑:BAAALgAECgEJAQAAAA==.',
['九九']='九九八:BAAALgAECgYJDAAAAA==.',
['五四']='五四三二一上:BAAALgAFFAEJAgAAAA==.',
['亡影']='亡影:BAAALgAECgQJBQAAAA==.',
['京都']='京都灬樱花落:BAAALgAECgQJBwAAAA==.',
['亲亲']='亲亲奶黄包:BAAALgAECgQJBQABLgAFFAYJEgALAG8iAA==.',
['人菜']='人菜瘾还大:BAAALgADCgUJBQAAAA==.',
['什么']='什么祭司:BAAALgAECgEJAwAAAA==.',
['伊索']='伊索尔的鸟:BAAALgADCgEJAQAAAA==.',
['会飞']='会飞的小猫:BAAALgAECgUJBQAAAA==.',
['伱鼎']='伱鼎涡仙伞:BAAALgAECgUJBQAAAA==.',
['佛丁']='佛丁姐姐:BAAALgAFFAEJAQAAAA==.',
['保濟']='保濟丸:BAABLgAFFH8IAAIFAAUJ9hhJBACtAQAFAAUJ9hhJBACtAQAAAA==.',
['借口']='借口那么好:BAAALgAFFAEJAQAAAA==.',
['傻狍']='傻狍子丶:BAAALgAFFAEJAQAAAA==.',
['光头']='光头战:BAAALgAECgYJBQAAAA==.',
['光铸']='光铸月淡霜:BAAALgAECgMJAgAAAA==.',
['六月']='六月的奶龙:BAAALgAECgEJAwAAAA==.',
['其九']='其九:BAAALgAFFAEJAQAAAA==.',
['再无']='再无可失:BAAALgAFFAEJAQAAAA==.',
['冬阳']='冬阳夏云:BAAALgADCgEJAQAAAA==.',
['冷不']='冷不丁邦一拳:BAAALgAECgcJBwABLgAFFAcJBgAHAG4FAA==.',
['凛冬']='凛冬将至丨:BAAALgAECgcJCAAAAA==.',
['切尾']='切尾巴抓宝宝:BAAALgAECgUJBQAAAA==.',
['刘大']='刘大佳:BAABLgAFFH8GAAIMAAIJOwqgBwBsAAAMAAIJOwqgBwBsAAAAAA==.',
['刺客']='刺客女:BAABLgAECn8UAAINAAcJaBgyHQAVAgANAAcJaBgyHQAVAgAAAA==.',
['刻师']='刻师傅:BAAALgAECgQJAwABLgAFFAUJBQAOABYhAA==.',
['劳资']='劳资蜀道山:BAAALgAECgMJBQAAAA==.',
['勤劳']='勤劳的打工仔:BAAALgAECgMJAwAAAA==.',
['十一']='十一哥:BAAALgADCgEJAQAAAA==.',
['十年']='十年灬梦空城:BAAALgAECgYJDAAAAA==.',
['南京']='南京犇波尔霸:BAAALgADCgIJAgAAAA==.',
['卯之']='卯之花灬烈:BAAALgADCgcJBwAAAA==.',
['又一']='又一朵菊花:BAAALgAECgcJCQAAAA==.',
['只想']='只想练个德:BAAALgADCgYJBgAAAA==.',
['可可']='可可味的人儿:BAAALgAECgQJBAAAAA==.',
['可曾']='可曾记得爱:BAAALgADCgcJBwAAAA==.',
['叶沐']='叶沐:BAAALgAECgMJAgAAAA==.',
['叶蓝']='叶蓝秋丶:BAAALgAECgcJEgAAAA==.',
['向左']='向左丶:BAACLgAFFH8LAAIKAAQJISAtEACVAQAKAAQJISAtEACVAQAuAAQKfxUAAgoACQnOITQKAHIDAAoACQnOITQKAHIDAAAA.',
['吾醉']='吾醉吾醒:BAAALgAECgEJAQAAAA==.',
['咆哮']='咆哮之吼:BAAALgAECgYJBgAAAA==.',
['咕噜']='咕噜咕噜:BAAALgAECgMJAwAAAA==.',
['咕德']='咕德白:BAAALgADCgUJBQAAAA==.',
['咖啡']='咖啡豆子:BAAALgADCgEJAQAAAA==.',
['哈默']='哈默雷特:BAAALgAECgIJAgAAAA==.',
['哎呀']='哎呀米诺:BAAALgAECgcJCAAAAA==.',
['喵骨']='喵骨:BAAALgADCgkJHwAAAA==.',
['四川']='四川扛把子:BAAALgADCgQJBQAAAA==.',
['因为']='因为每个所以:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光面筋:BAAALgADCgkJDwAAAA==.',
['圣十']='圣十字的恶魔:BAAALgAECgcJCQAAAA==.',
['圣者']='圣者归来:BAAALgAECgYJBgAAAA==.',
['坠落']='坠落之源:BAAALgAECgEJAQAAAA==.',
['墓尸']='墓尸小三:BAAALgADCggJCAAAAA==.',
['墨提']='墨提丝:BAAALgAFFAIJAgAAAA==.',
['夜丨']='夜丨雨声烦:BAAALgAECgMJAgAAAA==.',
['夜无']='夜无恒:BAAALgAECgcJDQAAAA==.',
['夜璃']='夜璃:BAAALgAECgYJCwAAAA==.',
['夜话']='夜话:BAAALgADCgEJAQAAAA==.',
['大乃']='大乃隆:BAAALgAECgUJBQAAAA==.',
['大松']='大松狮:BAAALgADCgYJBgAAAA==.',
['天下']='天下哥哥:BAAALgAECgYJBQAAAA==.',
['天野']='天野遠子:BAAALgAECgkJAgAAAA==.',
['太性']='太性情了哥们:BAAALgAECggJBgAAAA==.',
['奥买']='奥买鸭德:BAAALgADCgEJAQAAAA==.',
['奥尔']='奥尔夫:BAAALgAECgIJBAAAAA==.',
['奶到']='奶到你起飞:BAAALgAECgEJAQAAAA==.',
['奶斯']='奶斯兔米兔:BAAALgAECgkJCQAAAA==.',
['妖蝶']='妖蝶:BAAALgAECgQJBAAAAA==.',
['妙静']='妙静:BAAALgAECgkJCQAAAA==.',
['妹妹']='妹妹你别跑:BAAALgAECgQJBAAAAA==.',
['姐姐']='姐姐别乱来:BAAALgAECgIJAgAAAA==.',
['婳锦']='婳锦:BAAALgAECgUJCgAAAA==.',
['守备']='守备官伊瑞尔:BAAALgAECgUJCQAAAA==.',
['守护']='守护者帕拉丁:BAABLgAFFH8HAAIFAAQJAQVbBwAYAQAFAAQJAQVbBwAYAQAAAA==.',
['安丽']='安丽埃特:BAAALgAFFAQJBAAAAA==.',
['安杜']='安杜恩:BAAALgAFFAEJAQAAAA==.',
['宝马']='宝马星宿老仙:BAAALgAECgYJDAAAAA==.',
['宿命']='宿命:BAAALgAECgMJAwAAAA==.',
['寂寞']='寂寞的洋洋:BAAALgAECgkJDgAAAA==.寂寞的甜甜:BAAALgAECgcJBwABLgAFFAUJBQAPAN8aAA==.寂寞的米米:BAAALgAECggJDgAAAA==.寂寞的美女:BAAALgAECggJAgAAAA==.寂寞的考拉:BAAALgAECgYJBgABLgAFFAUJBgAKADQdAA==.寂寞的豆豆:BAAALgAECgkJDwAAAA==.',
['寒芒']='寒芒杀戮:BAAALgADCgEJAQAAAA==.',
['寶马']='寶马不讲术德:BAAALgAECgcJBwAAAA==.',
['小妖']='小妖姬:BAAALgAECgEJAQAAAA==.',
['小寳']='小寳寳:BAAALgAECgIJAgAAAA==.',
['小寶']='小寶寶:BAAALgAECgcJCgAAAA==.',
['小牧']='小牧丶蕾婷:BAAALgAECgUJBQAAAA==.',
['小綠']='小綠人:BAAALgADCgUJBQAAAA==.',
['小雪']='小雪时愿:BAAALgADCgMJAwAAAA==.',
['小黄']='小黄鱼小树人:BAAALgADCgIJAgAAAA==.小黄鱼龙人:BAAALgAECgUJBQAAAA==.',
['尐智']='尐智:BAAALgADCgEJAQAAAA==.',
['干丶']='干丶月之星:BAAALgAECgkJEgABLgAFFAQJDAAQACwTAA==.',
['幸运']='幸运波:BAAALgAECgIJAgAAAA==.',
['幻之']='幻之樱空释:BAAALgAECgUJBwAAAA==.',
['幽默']='幽默绿苍蝇:BAAALgAECgMJAwAAAA==.',
['康娜']='康娜:BAAALgAECgcJBwAAAA==.',
['弒魂']='弒魂殺魄:BAAALgADCgMJAwAAAA==.',
['弟劈']='弟劈而死丨:BAAALgAECgEJAQAAAA==.',
['張晓']='張晓冉:BAAALgADCgYJCwAAAA==.',
['影坠']='影坠:BAAALgADCgUJBQAAAA==.',
['德天']='德天毒后:BAAALgAECgcJDAAAAA==.',
['心丶']='心丶愿:BAAALgADCgEJAQAAAA==.',
['思丶']='思丶未央:BAAALgADCgEJAQAAAA==.',
['性感']='性感丶大短褲:BAAALgAECgIJAgAAAA==.性感丶小短裤:BAAALgAECgQJBAAAAA==.',
['恐虐']='恐虐神选丶:BAAALgAFFAQJAQAAAA==.',
['恶来']='恶来:BAAALgADCgEJAQAAAA==.',
['懒觉']='懒觉喂醒:BAAALgAECgQJBQAAAA==.',
['戈壁']='戈壁冷气:BAAALgAECgEJAQAAAA==.',
['我叫']='我叫麦兜:BAAALgAECgEJAQAAAA==.',
['我是']='我是洒满:BAABLgAECn8YAAILAAYJfgfsZAD6AAALAAYJfgfsZAD6AAAAAA==.',
['我玩']='我玩你牧:BAAALgAECgYJDgAAAA==.',
['打死']='打死不奶:BAACLgAFFH8MAAMLAAQJ7QejBQALAQALAAQJ7QejBQALAQARAAEJUQGABwBAAAAuAAQKfxUAAxEACAmYF3YTAIIBABEABgl4F3YTAIIBAAsAAwmNDfgkAGAAAAAA.',
['托拉']='托拉基斯鸡:BAAALgADCgEJAQAAAA==.',
['抵制']='抵制烤鹌鹑:BAAALgAFFAYJAwAAAA==.',
['挑水']='挑水混混:BAAALgAECgQJCAAAAA==.',
['提欧']='提欧:BAAALgAECgYJCAAAAA==.',
['攻强']='攻强机器:BAAALgAECgEJAQAAAA==.',
['新妹']='新妹妹:BAAALgAECgMJAwAAAA==.',
['无奈']='无奈逍遥:BAAALgADCgYJBgAAAA==.',
['无影']='无影灯:BAAALgAECgYJCAAAAA==.',
['明婧']='明婧止水:BAAALgAECgkJDgAAAA==.',
['明日']='明日祈愿:BAAALgAECgYJDQAAAA==.',
['明静']='明静止水:BAAALgAECgYJBgABLgAFFAQJBgASAFUbAA==.',
['昙花']='昙花丨现:BAAALgAECgcJCQAAAA==.',
['星空']='星空美幸:BAAALgADCgIJAgAAAA==.',
['晚上']='晚上看流星:BAABLgAECn8VAAMOAAYJwhiVLgDJAQAOAAYJwhiVLgDJAQAFAAMJKQrvRwEwAAAAAA==.',
['普兰']='普兰特扳手:BAAALgAECgQJBAAAAA==.',
['晴海']='晴海:BAAALgAECgIJAgAAAA==.',
['暗夜']='暗夜枭德:BAAALgAECgEJAQAAAA==.',
['暴风']='暴风雪乄凯特:BAABLgAFFH8JAAIGAAUJugwfCgDWAAAGAAUJugwfCgDWAAAAAA==.',
['最丶']='最丶逍遥:BAAALgAECgIJAwAAAA==.',
['最爱']='最爱洗面奶:BAAALgADCgEJAQAAAA==.',
['月影']='月影乄:BAACLgAFFH8MAAITAAQJdxpFCABdAQATAAQJdxpFCABdAQAuAAQKfyMAAxMACQlkIM0EAFQDABMACQlkIM0EAFQDABQABAmLFwAAAAAAAAAA.',
['有梦']='有梦的神仙:BAAALgAECgcJBwAAAA==.',
['有种']='有种正面丄我:BAAALgAECgYJBgAAAA==.',
['木之']='木之芽风:BAAALgADCgUJBQAAAA==.',
['末日']='末日天启:BAAALgAECgQJBAAAAA==.',
['本色']='本色闹太套:BAAALgAECgEJAQAAAA==.本色鹌鹑侠:BAAALgAFFAMJAwAAAA==.',
['朱朱']='朱朱开心果:BAAALgAECgIJAwAAAA==.',
['李狗']='李狗蛋:BAACLgAFFH8GAAMNAAQJVBpzDAAdAQANAAMJQRxzDAAdAQAVAAEJjhQIBgBeAAAuAAQKfxUAAxUACAkKJEwDAJsCABUABwmmH0wDAJsCAA0ACAkKJA8TAIICAAEuAAUUBQkKABYA8xwA.',
['枯矾']='枯矾:BAAALgAECgcJDQAAAA==.',
['桌椅']='桌椅:BAAALgAFFAEJAgAAAA==.',
['梦之']='梦之蓝手工班:BAAALgADCgQJBAAAAA==.',
['梦回']='梦回韶华:BAAALgAECgkJCAAAAA==.',
['殒落']='殒落丶哀伤:BAAALgADCgYJBgAAAA==.',
['殤灬']='殤灬阿塔兰忒:BAAALgAECgEJAQAAAA==.',
['水粉']='水粉画:BAAALgADCgEJAQAAAA==.',
['没有']='没有迷:BAABLgAECn8UAAIOAAkJNBwZCADsAgAOAAkJNBwZCADsAgAAAA==.',
['波里']='波里个浪浪:BAAALgAECgUJBQAAAA==.',
['洛云']='洛云:BAAALgAECgYJEwAAAA==.',
['流莹']='流莹丷:BAAALgAECgcJDwAAAA==.',
['浪剑']='浪剑归心:BAAALgADCgUJBQAAAA==.',
['深岚']='深岚:BAAALgAECgYJCAAAAA==.',
['深海']='深海少女:BAAALgAECgQJBAAAAA==.',
['渝冬']='渝冬时雨:BAAALgAECgEJAQAAAA==.',
['游学']='游学者周卓丶:BAABLgAECn8WAAMSAAcJoxyDGQA3AgASAAcJihuDGQA3AgAQAAQJLw/uSgDmAAAAAA==.',
['游戏']='游戏要啸着玩:BAAALgAFFAQJBAAAAA==.',
['火舞']='火舞:BAAALgADCgYJBgAAAA==.火舞狂飙:BAAALgAECgMJAwAAAA==.',
['炎和']='炎和永远:BAAALgAECgEJAQAAAA==.',
['炎夔']='炎夔:BAAALgAECgUJCAAAAA==.',
['煦光']='煦光尘灵:BAAALgADCgEJAQAAAA==.',
['燃烧']='燃烧的花生米:BAAALgAECgYJCwAAAA==.',
['爱满']='爱满天心:BAAALgADCgMJAwAAAA==.',
['犇牛']='犇牛犇牛犇:BAAALgAFFAQJBAAAAA==.',
['猎风']='猎风无影:BAAALgAECgEJAQAAAA==.',
['猫头']='猫头嘤:BAABLgAECn8WAAIXAAgJixcqAgDIAQAXAAgJixcqAgDIAQAAAA==.',
['玉爧']='玉爧瓏:BAABLgAECn8WAAMGAAcJnBhCKQASAgAGAAcJnBhCKQASAgAYAAIJUwMdLABEAAAAAA==.',
['王師']='王師傅:BAAALgAECgcJBwAAAA==.',
['玫瑰']='玫瑰豆沙包:BAAALgAECgYJCAAAAA==.玫瑰饼:BAAALgAECgMJAwAAAA==.',
['球爷']='球爷:BAAALgAECgMJBQABLgAECgQJBQADAAAAAA==.',
['瓦达']='瓦达西:BAAALgADCgUJBQAAAA==.',
['瓶中']='瓶中的法力源:BAAALgAECgcJDwAAAA==.',
['白血']='白血乌鸦:BAAALgAECgYJBgAAAA==.',
['皇室']='皇室家人:BAAALgAECgUJCAAAAA==.',
['盐氵']='盐氵水:BAAALgAFFAIJBAAAAA==.',
['瞎士']='瞎士奇:BAAALgADCgkJDgAAAA==.',
['石斛']='石斛兰二世:BAAALgAECgUJBQAAAA==.',
['硬要']='硬要玩增辉:BAAALgAECgUJAwAAAA==.',
['碎霜']='碎霜:BAAALgAECgIJAgAAAA==.',
['神之']='神之力:BAAALgAECgkJAQAAAA==.',
['神圣']='神圣堡垒:BAAALgAECgUJCgAAAA==.',
['神户']='神户牛排:BAAALgADCgIJAgAAAA==.',
['福禄']='福禄号思:BAAALgAECgYJCAAAAA==.',
['秋咪']='秋咪秋咪:BAAALgAECgIJAgAAAA==.',
['秋月']='秋月丶星空:BAAALgAECgYJDQAAAA==.秋月丶爱莉:BAAALgAECgYJCgAAAA==.',
['秋雅']='秋雅:BAABLgAFFH8FAAIKAAIJzxifOgC1AAAKAAIJzxifOgC1AAAAAA==.',
['穹兵']='穹兵黩武僧:BAAALgADCgEJAQAAAA==.',
['空帽']='空帽子:BAABLgAFFH8FAAIZAAIJySDdDQDCAAAZAAIJySDdDQDCAAABLgAFFAMJBAADAAAAAA==.',
['窈窕']='窈窕猫娘:BAAALgAFFAEJAQAAAA==.',
['笨晓']='笨晓孩:BAAALgADCgIJAgAAAA==.',
['笨蛋']='笨蛋美人:BAAALgAECgcJBwAAAA==.',
['答辩']='答辩代课老师:BAAALgADCgcJBwAAAA==.答辩隆:BAAALgADCgEJAQAAAA==.',
['米涅']='米涅鲁:BAAALgADCgEJAQAAAA==.',
['約克']='約克尼尼:BAAALgADCgEJAQAAAA==.',
['紫凝']='紫凝嫂嫂:BAAALgAECgcJCwAAAA==.',
['紫哒']='紫哒丨:BAAALgAECgQJBAAAAA==.',
['紫夜']='紫夜雲:BAAALgAECgUJBgAAAA==.',
['纳兹']='纳兹苏尔:BAAALgAECgMJAwAAAA==.',
['织田']='织田鳞长:BAAALgAECgMJAwAAAA==.',
['经典']='经典丶奶茶:BAABLgAFFH8KAAIWAAUJ8xyjAADRAQAWAAUJ8xyjAADRAQAAAA==.',
['维康']='维康妮亚:BAAALgAECgQJBAAAAA==.',
['翻滚']='翻滚汉堡:BAAALgAECgEJAQAAAA==.',
['老术']='老术盘根:BAAALgAECgYJBgAAAA==.',
['老路']='老路灯:BAAALgAECgYJBwAAAA==.',
['肥肥']='肥肥的德:BAAALgAECgQJBgAAAA==.',
['艾琳']='艾琳塞克:BAAALgADCgMJAwAAAA==.',
['艾维']='艾维娜影辰:BAAALgAECgMJAgAAAA==.艾维娜逐星:BAAALgADCgEJAQAAAA==.',
['艾露']='艾露蒽:BAAALgAECgYJCgAAAA==.',
['芒果']='芒果糯叽叽:BAAALgAECgUJBQAAAA==.',
['花痴']='花痴宝宝:BAAALgAECgEJAQAAAA==.',
['芷若']='芷若:BAAALgADCgUJCAAAAA==.',
['若是']='若是你不淡漠:BAAALgAFFAEJAQAAAA==.',
['英式']='英式风情茶:BAAALgAECgcJDwAAAA==.',
['苹果']='苹果灬牛奶:BAAALgAECgYJDAAAAA==.',
['茕茕']='茕茕白兔:BAAALgADCgYJBgAAAA==.',
['菊花']='菊花微微一颤:BAAALgAECgEJAgAAAA==.',
['萨斯']='萨斯滴锅:BAAALgAECgMJAwAAAA==.',
['葫芦']='葫芦娃呼噜:BAAALgAECgYJBgAAAA==.葫芦娃呼噜噜:BAABLgAFFH8JAAIFAAQJ3RXICgBWAQAFAAQJ3RXICgBWAQAAAA==.',
['葳小']='葳小蕤:BAAALgAECgIJAgAAAA==.',
['蓝白']='蓝白之翼:BAAALgADCgIJAwAAAA==.',
['虎吉']='虎吉:BAAALgAFFAMJAwAAAA==.',
['虎狼']='虎狼之吻:BAAALgAECgMJAQAAAA==.',
['虔诚']='虔诚信仰:BAAALgAECgYJCgAAAA==.',
['覅俄']='覅俄方:BAAALgAECgYJDQAAAA==.',
['赛恩']='赛恩铁锤:BAAALgADCgYJBwAAAA==.',
['赤山']='赤山茶之恋:BAAALgAECgkJBwAAAA==.',
['赫蘿']='赫蘿:BAAALgAECgEJAQAAAA==.',
['越看']='越看越丑:BAAALgAFFAIJAgAAAA==.',
['辰枭']='辰枭:BAAALgADCgYJBgAAAA==.',
['达勃']='达勃斯德摩特:BAAALgAFFAMJBAABLgAFFAYJFQATAIwQAA==.',
['迷路']='迷路的毛绒绒:BAACLgAFFH8KAAILAAMJkw5eEADlAAALAAMJkw5eEADlAAAuAAQKfx0AAgsABwmHDvM/AIEBAAsABwmHDvM/AIEBAAAA.',
['迷迭']='迷迭:BAAALgAECgMJAwAAAA==.',
['迷途']='迷途的哓海:BAAALgAFFAIJAgAAAA==.',
['逍遥']='逍遥之王:BAAALgAECgYJBgAAAA==.',
['那个']='那个萨满丶:BAAALgAECgIJAwAAAA==.',
['邪君']='邪君:BAAALgAECgYJBwAAAA==.',
['邪血']='邪血之寒:BAAALgAFFAIJAwAAAA==.',
['酋长']='酋长的耻辱:BAAALgAECgUJCAAAAA==.',
['醉饮']='醉饮禅意:BAABLgAECn8gAAISAAYJJhwfJQDaAQASAAYJJhwfJQDaAQAAAA==.',
['释然']='释然的人:BAABLgAECn8UAAQGAAcJwRo6OwDCAQAGAAYJYhk6OwDCAQAHAAYJOxmOPQBlAQAYAAEJ8B8AAAAAAAAAAA==.',
['释迦']='释迦摩佛:BAAALgAECgUJBQAAAA==.',
['野狐']='野狐禅:BAAALgAECgIJAgAAAA==.',
['钮祜']='钮祜禄丶小白:BAAALgAECgEJAQAAAA==.',
['铁头']='铁头:BAAALgAECgQJBAAAAA==.',
['铜镜']='铜镜:BAACLgAFFH8FAAILAAMJSwwdIgBKAAALAAMJSwwdIgBKAAAuAAQKfxYAAgsABwmNFRcuANEBAAsABwmNFRcuANEBAAAA.',
['银月']='银月大公主:BAAALgADCgUJBQAAAA==.',
['销魂']='销魂一射:BAAALgAFFAIJAgAAAA==.',
['锈刃']='锈刃又锋:BAAALgAFFAEJAgAAAA==.',
['锐雯']='锐雯丶戴尔:BAAALgAECgcJAQAAAA==.',
['镰刀']='镰刀召唤法阵:BAAALgAECgMJBgAAAA==.',
['闇口']='闇口崩子:BAAALgAECgYJBQAAAA==.',
['闲云']='闲云:BAAALgADCgUJBQAAAA==.',
['闻香']='闻香识男人:BAAALgAFFAEJAQAAAA==.',
['阿尔']='阿尔缪斯:BAAALgAECgQJBgAAAA==.',
['阿莱']='阿莱柯思塔萨:BAAALgAFFAEJAQAAAA==.',
['陆子']='陆子诚:BAAALgAECgYJBgAAAA==.',
['陈伟']='陈伟霆:BAAALgAFFAEJAQAAAA==.',
['雨之']='雨之殇:BAAALgADCgMJAwAAAA==.',
['雨琪']='雨琪:BAAALgAECgIJAgAAAA==.',
['雪绒']='雪绒花:BAAALgAECgQJBgAAAA==.',
['雪见']='雪见:BAAALgAECgEJAgAAAA==.',
['零叁']='零叁:BAAALgADCgEJAQAAAA==.',
['露西']='露西法之梦:BAAALgAECgYJBgAAAA==.',
['霸气']='霸气的葱:BAAALgAECgQJBAAAAA==.',
['青柠']='青柠晾茶:BAAALgAECgIJAwAAAA==.',
['青鳞']='青鳞咒师:BAAALgAECgEJAQAAAA==.',
['顾凌']='顾凌天:BAAALgAFFAIJAgAAAA==.',
['顾城']='顾城:BAAALgAFFAQJDgAAAQ==.',
['风之']='风之小祈:BAAALgAECgQJBAAAAA==.',
['风尘']='风尘中人:BAAALgAECgcJEgAAAA==.',
['风骚']='风骚的笨笨熊:BAAALgAECgUJBQAAAA==.',
['饿磨']='饿磨裂手:BAAALgADCgQJBgAAAA==.',
['鬼灭']='鬼灭仇:BAAALgAECgYJDQAAAA==.',
['鱼粥']='鱼粥:BAAALgAECgEJAQAAAA==.',
['鲁卡']='鲁卡:BAACLgAFFH8FAAIIAAIJ2ghSGgCeAAAIAAIJ2ghSGgCeAAAuAAQKfxYAAwkABgmUGn0gAE8BAAgABQn8Gh9yAHoBAAkABgnaEn0gAE8BAAAA.',
['麦芽']='麦芽糖:BAAALgADCgYJBgAAAA==.',
['黑乎']='黑乎乎的黑:BAAALgAECgUJBgAAAA==.',
['黑化']='黑化:BAACLgAFFH8IAAMIAAQJSR5JDQBxAQAIAAQJyBpJDQBxAQAJAAEJYg69FQBTAAAuAAQKfx8AAwgACAnDI/YWAMsCAAgACAn2IfYWAMsCAAkABAmnHcQfAFQBAAAA.',
['龟猫']='龟猫警长:BAAALgAECgUJCAAAAA==.',
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
