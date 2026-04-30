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

local lookup = {'DemonHunter-Devourer','Warrior-Protection','Rogue-Subtlety','Mage-Frost','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Rogue-Assassination','Priest-Holy','Warrior-Arms','Priest-Discipline','Paladin-Retribution','Shaman-Restoration','DemonHunter-Havoc','Evoker-Augmentation','Priest-Shadow','Monk-Brewmaster','Monk-Windwalker','Hunter-BeastMastery','Mage-Arcane','Druid-Feral','DeathKnight-Blood','Paladin-Holy','Shaman-Elemental','Shaman-Enhancement','Evoker-Preservation','Unknown-Unknown','DemonHunter-DPS',}
local provider = {region='CN',realm='玛洛加尔',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Animone:BAAALgAECgcJBwAAAA==.',
Ar='Aruka:BAAALgAECgUJAwAAAA==.',
Be='Beyourmyth:BAAALgAECgcJBwAAAA==.',
Bi='Biubiujj:BAAALgAECgYJCgAAAA==.',
Bl='Blaumeux:BAAALgAECgUJBQAAAA==.',
Ch='Cherryfox:BAAALgAECgMJBQAAAA==.',
Co='Colter:BAAALgAECggJEAAAAA==.',
Da='Database:BAAALgAECgcJDgABLgAFFAMJBQABAHYbAA==.',
Fu='Fuzer:BAAALgAECgYJCQAAAA==.',
Ge='Geminorum:BAAALgAECgEJAQAAAA==.',
Gu='Gump:BAACLgAFFH8RAAICAAQJOR77AgBtAQACAAQJOR77AgBtAQAuAAQKfycAAgIACAlqJCgCAFADAAIACAlqJCgCAFADAAAA.',
He='Heylone:BAAALgADCgQJBAAAAA==.',
Hz='Hzhunterba:BAAALgAFFAQJBAAAAA==.',
Mo='Mortalcoil:BAAALgADCgEJAQAAAA==.',
Mx='Mxy:BAAALgAECgkJEgAAAA==.',
Ol='Olivine:BAABLgAFFH8GAAIDAAQJ6xrMAQB2AQADAAQJ6xrMAQB2AQAAAA==.',
Pa='Pasir:BAAALgAECgQJBAAAAA==.',
Sa='Samllsam:BAAALgAECgEJAQAAAA==.',
Sc='Scrooge:BAABLgAFFH8JAAIEAAQJoBhbGABoAQAEAAQJoBhbGABoAQAAAA==.',
Sm='Smilecat:BAAALgAECgEJAQAAAA==.',
So='Sorakam:BAAALgAECgEJAQAAAA==.',
St='Stellar:BAAALgAFFAIJAwABLgAFFAcJBQAFAPEgAA==.Stephenamel:BAAALgAECgYJBgAAAA==.',
Sy='Syliva:BAAALgAECgYJDAAAAA==.',
Te='Terrifiblade:BAAALgADCgEJAQAAAA==.',
Tn='Tnk:BAAALgADCgUJBQAAAA==.',
['一剑']='一剑问情:BAAALgAECgYJDwAAAA==.',
['一拳']='一拳超熊:BAAALgADCgcJDQAAAA==.',
['一朝']='一朝悲欢离合:BAABLgAFFH8HAAIFAAMJ5R2iIwAHAQAFAAMJ5R2iIwAHAQAAAA==.',
['一杯']='一杯敬月光:BAAALgAECgEJAgAAAA==.',
['一骑']='一骑当千:BAAALgAECgEJAQAAAA==.',
['丁短']='丁短短:BAAALgAECgMJAwAAAA==.',
['丁长']='丁长长:BAAALgAECgEJAQAAAA==.',
['万总']='万总要吃鱻:BAAALgADCgYJBgAAAA==.',
['三级']='三级演员:BAABLgAFFH8IAAIFAAMJihk3DgAEAQAFAAMJihk3DgAEAQAAAA==.',
['下次']='下次我请丶:BAAALgAECgMJAwAAAA==.',
['不变']='不变的星空:BAACLgAFFH8LAAIGAAQJbR99BQBfAQAGAAQJbR99BQBfAQAuAAQKfx0ABAYACAk0I8EhAI8CAAYABwmOHsEhAI8CAAcABAl9GEEvAP4AAAgAAQkAAKElAFsAAAAA.',
['专拉']='专拉小朋友:BAAALgAECgYJBgAAAA==.',
['临衿']='临衿:BAAALgAECgEJAQAAAA==.',
['丶一']='丶一叽咕:BAAALgADCgEJAQAAAA==.',
['丶喵']='丶喵尛兔:BAAALgAECgEJAgAAAA==.',
['丶泉']='丶泉丶:BAAALgADCgEJAQAAAA==.',
['丶選']='丶選擇遺莣灬:BAAALgAECgcJDQAAAA==.',
['丶释']='丶释年:BAAALgAECgYJDAAAAA==.',
['丶雪']='丶雪色年华:BAAALgAECgYJEwAAAA==.',
['丹丹']='丹丹的沙漏:BAAALgAECgYJCQAAAA==.',
['为毛']='为毛追我:BAAALgAECgMJBAAAAA==.',
['丿嘲']='丿嘲風:BAAALgAECgYJBwAAAA==.',
['么么']='么么术丶:BAAALgAECgEJAQAAAA==.',
['之狼']='之狼:BAAALgADCgYJBgAAAA==.',
['二两']='二两燃面:BAAALgAECgEJAQAAAA==.',
['二拾']='二拾酒:BAAALgAECgcJBwAAAA==.',
['二等']='二等兵肝:BAAALgAECgYJBgAAAA==.',
['五根']='五根香蕉:BAAALgADCgEJAQAAAA==.',
['亡镰']='亡镰:BAAALgAECggJEAAAAA==.',
['伊集']='伊集院隼人:BAAALgADCgEJAQAAAA==.',
['你也']='你也配吃奶:BAAALgAECgEJAQAAAA==.',
['你是']='你是真畜:BAAALgAFFAEJAQAAAA==.你是真軥:BAAALgAECgYJBgAAAA==.',
['依丶']='依丶然:BAAALgAECgQJAgAAAA==.',
['光头']='光头鬼鬼丶:BAABLgAECn8gAAMDAAgJPBqNHgAHAgADAAgJPBqNHgAHAgAJAAMJxRAFEwDSAAAAAA==.',
['光明']='光明恶魔:BAAALgADCgEJAQAAAA==.',
['兜兜']='兜兜裏的糖糖:BAABLgAECn8UAAIKAAcJGA/ILwCDAQAKAAcJGA/ILwCDAQAAAA==.',
['六碗']='六碗头有角:BAAALgAECgYJBgABLgAFFAUJBQALADUPAA==.六碗爱洗澡:BAAALgAECgYJBgABLgAFFAUJBQALADUPAA==.',
['兽能']='兽能:BAAALgAECgEJAQAAAA==.',
['军团']='军团香蕉:BAAALgAECgEJAQAAAA==.',
['冥丶']='冥丶:BAAALgADCgMJAwAAAA==.',
['冬姐']='冬姐来了:BAAALgAECgcJCAAAAA==.',
['冰丨']='冰丨锐:BAAALgADCgIJAgAAAA==.',
['冰莓']='冰莓:BAAALgAFFAIJAwAAAA==.',
['冰雨']='冰雨之戀:BAAALgAECgEJAQAAAA==.',
['凉情']='凉情薄心:BAAALgAFFAQJBAAAAA==.',
['凯饵']='凯饵萨斯:BAAALgAECgIJAgAAAA==.',
['初夏']='初夏夏冰凉:BAAALgAECgcJBwAAAA==.初夏夏微凉:BAAALgAECgYJBgAAAA==.',
['别关']='别关灯:BAAALgAECgUJBQAAAA==.',
['劳阿']='劳阿柏:BAAALgAECgQJCAABLgAFFAQJBgABABkaAA==.',
['勿忆']='勿忆:BAAALgAECgEJAQAAAA==.',
['包射']='包射:BAAALgAECgcJCgAAAA==.',
['北城']='北城花已开:BAAALgADCgYJCgAAAA==.',
['十多']='十多亿个骑士:BAAALgAECgQJBQAAAA==.',
['午夜']='午夜飞鱼:BAAALgAECgQJBAAAAA==.',
['单刷']='单刷女生寝:BAAALgADCgYJBgAAAA==.',
['南风']='南风猎:BAAALgAECgMJAwAAAA==.',
['卡加']='卡加德之滣:BAAALgAECgcJDgAAAA==.',
['卤蛋']='卤蛋:BAAALgAECgkJBwAAAA==.',
['卸饭']='卸饭美琴:BAAALgAECgEJAQAAAA==.',
['原乡']='原乡情浓:BAAALgADCgEJAQAAAA==.',
['发芽']='发芽的小土豆:BAAALgAECgEJAQAAAA==.',
['变身']='变身斗士:BAAALgAFFAEJAQAAAA==.',
['古利']='古利特:BAAALgAECgYJBgAAAA==.',
['古德']='古德依舞林:BAAALgAECgEJAgAAAA==.',
['叭噶']='叭噶酱丶:BAAALgAECgIJAgAAAA==.',
['可口']='可口冰西瓜:BAAALgAECgEJAQAAAA==.',
['可怕']='可怕的大熊猫:BAABLgAFFH8LAAMKAAQJVRCrBQAoAQAKAAQJYQ+rBQAoAQAMAAEJsQg6GQBLAAAAAA==.',
['可爱']='可爱到爆:BAAALgAECgIJAQAAAA==.',
['叶久']='叶久一:BAAALgAFFAEJAQAAAA==.',
['名字']='名字也是醉了:BAAALgAECgcJEQAAAA==.',
['向昕']='向昕:BAAALgADCgEJAQAAAA==.',
['听风']='听风嘛:BAAALgAECgYJCwAAAA==.',
['吾彦']='吾彦祖:BAAALgAECgEJAQAAAA==.',
['咕喵']='咕喵:BAAALgADCgYJBgAAAA==.',
['哔哔']='哔哔壮丶:BAAALgADCgYJBgAAAA==.',
['哟灬']='哟灬尛柯:BAAALgAECgIJAgAAAA==.',
['唔战']='唔战:BAAALgAECgYJDAAAAA==.',
['啤酒']='啤酒能喝二斤:BAAALgAECgEJAQAAAA==.',
['嗨起']='嗨起来騛:BAAALgAECgQJBwAAAA==.',
['噬魔']='噬魔帝君:BAAALgADCgQJBAAAAA==.',
['四千']='四千六:BAAALgADCgEJAQAAAA==.',
['四根']='四根香蕉:BAABLgAFFH8FAAIFAAIJjhl/OACqAAAFAAIJjhl/OACqAAAAAA==.',
['团团']='团团饲养员:BAAALgAECgIJAgAAAA==.',
['国服']='国服知名聋人:BAAALgAECgEJAQAAAA==.',
['圣光']='圣光凡凡:BAAALgAECgEJAQAAAA==.圣光照瞎你:BAAALgAECgQJBAAAAA==.圣光玛卖花:BAAALgAECgEJAQAAAA==.',
['圣殿']='圣殿风:BAAALgAECgYJCAAAAA==.圣殿骑士丨殇:BAACLgAFFH8FAAINAAQJNQcxGgDRAAANAAQJNQcxGgDRAAAuAAQKfyMAAg0ABgmIHl9CAB0CAA0ABgmIHl9CAB0CAAAA.',
['地主']='地主爷:BAAALgAECgMJAwAAAA==.',
['地狱']='地狱行者:BAAALgAECgYJBwAAAA==.',
['堕落']='堕落丶梵音:BAAALgAECgYJDAAAAA==.',
['墨染']='墨染珋年:BAAALgAFFAIJAgAAAA==.',
['墨轻']='墨轻语:BAAALgADCgIJAgAAAA==.',
['夏丶']='夏丶紫薇:BAAALgADCgYJBgAAAA==.',
['夏璐']='夏璐璐:BAAALgAECgUJBQAAAA==.',
['夙丝']='夙丝丝:BAAALgADCgEJAQAAAA==.',
['多娜']='多娜多娜:BAAALgADCggJCAAAAA==.',
['夜之']='夜之优菈:BAAALgAECgEJAQAAAA==.',
['夜灬']='夜灬月眠:BAAALgAECgYJBwAAAA==.',
['大姜']='大姜东去:BAAALgAECgYJCwAAAA==.',
['大脸']='大脸王二号:BAAALgAECggJEwAAAA==.',
['大迪']='大迪凯:BAAALgAECgMJAwAAAA==.',
['大领']='大领主卡加:BAAALgADCgMJAwAAAA==.',
['天命']='天命主宰欺诈:BAAALgAFFAEJAQAAAA==.',
['奔波']='奔波儿:BAAALgAECgEJAQAAAA==.',
['奔跑']='奔跑的开水:BAAALgADCgEJAQAAAA==.',
['女装']='女装山脉:BAAALgADCggJBgAAAA==.',
['妞妞']='妞妞熊:BAAALgAECgUJBQAAAA==.',
['娇羞']='娇羞罗刹:BAAALgADCgUJBgAAAA==.',
['孙贰']='孙贰娘:BAAALgAECgQJBQAAAA==.',
['守护']='守护天使灬:BAAALgAFFAIJAgAAAA==.',
['宾利']='宾利也将就:BAAALgADCgYJBgAAAA==.',
['对魔']='对魔忍:BAAALgADCgYJBgAAAA==.',
['小丑']='小丑勿语:BAAALgAECgEJAQAAAA==.',
['小丶']='小丶东:BAABLgAFFH8HAAIOAAMJhArQEQDYAAAOAAMJhArQEQDYAAAAAA==.',
['小囧']='小囧囧兔:BAAALgAECgYJBgABLgAFFAYJCgAOAHYKAA==.',
['小小']='小小乃和:BAAALgAECgMJBAAAAA==.小小翠花:BAAALgAECgQJBAAAAA==.',
['小橘']='小橘:BAAALgAECgUJCgAAAA==.',
['小波']='小波浪卷:BAAALgAECgEJAQAAAA==.',
['小烟']='小烟熏:BAAALgAECgkJCQAAAA==.',
['小甜']='小甜水:BAAALgAECgcJEAAAAA==.',
['小表']='小表弟丶:BAAALgAFFAMJAwAAAA==.',
['小麦']='小麦:BAAALgAECgMJAwAAAA==.',
['少年']='少年阿宾:BAAALgADCgIJAgAAAA==.',
['尛邋']='尛邋遢:BAABLgAFFH8FAAIOAAIJ/yAtEwDHAAAOAAIJ/yAtEwDHAAAAAA==.',
['尤努']='尤努斯:BAAALgAECgUJBQAAAA==.',
['巧克']='巧克力与香草:BAAALgADCgkJDwAAAA==.',
['巫小']='巫小巫:BAAALgADCgUJBQAAAA==.',
['巴吉']='巴吉纳:BAAALgAFFAIJAgAAAA==.',
['巴扎']='巴扎黑大王:BAAALgAECgcJDAAAAA==.',
['常四']='常四爷:BAAALgAECgYJBwAAAA==.',
['年瑾']='年瑾已往:BAAALgADCgIJAwAAAA==.',
['年糕']='年糕脚:BAAALgADCgEJAQAAAA==.',
['幼稚']='幼稚源:BAAALgAECgcJDAAAAA==.',
['弑冰']='弑冰丶黑暗:BAAALgAECgQJBQAAAA==.',
['影丶']='影丶子:BAAALgADCgQJBAAAAA==.',
['得是']='得是得:BAABLgAECn8VAAIPAAcJ/xFjIQCxAQAPAAcJ/xFjIQCxAQAAAA==.',
['德德']='德德胖:BAAALgADCgUJBQAAAA==.',
['德的']='德的奶也有毒:BAAALgAFFAEJAgAAAA==.',
['快乐']='快乐射手:BAAALgAECgEJAQAAAA==.快乐逍遥:BAAALgAECgEJAQAAAA==.',
['情傷']='情傷:BAACLgAFFH8FAAIOAAQJ+xHmCAA+AQAOAAQJ+xHmCAA+AQAuAAQKfyEAAg4ACQl6IIYFABkDAA4ACQl6IIYFABkDAAAA.',
['惜别']='惜别洛神:BAAALgAECgEJAQAAAA==.',
['愢愢']='愢愢丨嘂嘂:BAAALgAFFAMJAwAAAA==.',
['慧萌']='慧萌:BAAALgAECgQJBAAAAA==.',
['慧风']='慧风倩影:BAAALgAECgYJCwAAAA==.',
['我最']='我最近挺好:BAAALgAECgEJAQAAAA==.',
['托莉']='托莉莲睡拿:BAABLgAFFH8GAAIQAAIJnxBWGQCdAAAQAAIJnxBWGQCdAAAAAA==.',
['掛橋']='掛橋沙耶香:BAAALgAFFAEJAQAAAA==.',
['搞里']='搞里头:BAAALgAECgMJAwAAAA==.',
['放开']='放开那个靓女:BAAALgAFFAIJAwAAAA==.',
['斋藤']='斋藤飛鸟:BAAALgAECgcJCAAAAA==.',
['无敌']='无敌大角牛:BAAALgAECgEJAQAAAA==.',
['昆仑']='昆仑巅江湖远:BAAALgAECgEJAQAAAA==.',
['明明']='明明就丶:BAAALgAECgUJBwAAAA==.',
['昕羊']='昕羊是真的:BAAALgAECggJEwAAAA==.',
['昨晚']='昨晚又没睡好:BAAALgAECgYJBQAAAA==.',
['晚情']='晚情思晚意:BAAALgAECgEJAQAAAA==.',
['晚晚']='晚晚折风丶:BAAALgAFFAEJAQAAAA==.',
['晴空']='晴空万厘:BAAALgAECgYJCwAAAA==.',
['暗影']='暗影契约:BAAALgAECgEJAQAAAA==.',
['月下']='月下飛舞:BAAALgAFFAEJAgAAAA==.',
['月半']='月半小和尚:BAAALgAECgMJAwAAAA==.月半月半:BAAALgAECgEJAQAAAA==.',
['服侍']='服侍少爷好累:BAAALgAECgIJAgAAAA==.',
['木木']='木木示:BAAALgAECgEJAgAAAA==.木木示丶:BAAALgAECgQJBwAAAA==.',
['本城']='本城丶俊明:BAAALgAFFAQJBAAAAA==.',
['林怡']='林怡佳:BAAALgADCgMJBAAAAA==.',
['枫叶']='枫叶绿洲:BAAALgADCgEJAQAAAA==.',
['栀子']='栀子扇掩笑颜:BAAALgAECgUJBgAAAA==.',
['栤雙']='栤雙兒:BAABLgAECn8cAAQMAAcJ+ha6GADVAQAMAAcJ+ha6GADVAQARAAcJcAzMKwB+AQAKAAQJmxFLWADUAAAAAA==.',
['棕色']='棕色毒奶:BAAALgAECgIJAwAAAA==.',
['橙橙']='橙橙西瓜:BAAALgAFFAIJAQAAAA==.',
['武圣']='武圣:BAAALgAECgcJCwAAAA==.',
['武神']='武神赵子龙:BAAALgAECgEJAQAAAA==.',
['死亡']='死亡冰血:BAAALgAECgEJAQAAAA==.',
['每天']='每天吃不饱:BAAALgAECgYJDQAAAA==.',
['永盛']='永盛之花:BAAALgAECgYJDAAAAA==.',
['汪汪']='汪汪少帅:BAAALgAFFAMJAwAAAA==.',
['沉淀']='沉淀一下:BAAALgAECgcJCAAAAA==.',
['沖繩']='沖繩奴隸島:BAAALgAECgcJDQAAAA==.',
['法图']='法图麦丶:BAAALgADCgUJBQAAAA==.',
['法爷']='法爷丶仰望:BAAALgAECgYJBgAAAA==.',
['流影']='流影箭手:BAAALgADCgQJBAAAAA==.',
['海军']='海军元帅战国:BAACLgAFFH8HAAISAAMJ9QdHFgDBAAASAAMJ9QdHFgDBAAAuAAQKfyAAAxIACAnOF5ocAB4CABIACAnOF5ocAB4CABMAAQnfAEWPAAsAAAAA.',
['涌涌']='涌涌的圣光:BAAALgAECgEJAQAAAA==.',
['淋雨']='淋雨的小火苗:BAAALgAECgIJAgAAAA==.',
['清水']='清水丶:BAAALgAECgIJAgAAAA==.',
['游侠']='游侠:BAAALgAECgEJAQAAAA==.',
['滞涨']='滞涨:BAACLgAFFH8LAAIFAAQJmxvTBwBIAQAFAAQJmxvTBwBIAQAuAAQKfxYAAgUACQncHeUdAM0CAAUACQncHeUdAM0CAAAA.',
['漓江']='漓江韩庚:BAAALgAECgEJAgAAAA==.',
['火祭']='火祭:BAAALgADCgEJAQAAAA==.',
['灬嗜']='灬嗜血烈焰:BAAALgAECgEJAQAAAA==.',
['灰格']='灰格小青年:BAAALgAECgcJDgAAAA==.',
['灵魂']='灵魂鬼步:BAAALgAECgYJBgAAAA==.',
['炎青']='炎青成:BAAALgAECgIJAgAAAA==.',
['烫烫']='烫烫茂:BAAALgAECgEJAQAAAA==.',
['煎餠']='煎餠丶:BAAALgAECgYJDAAAAA==.',
['爪爪']='爪爪冰棒啦:BAABLgAECn8XAAINAAkJMRygFADvAgANAAkJMRygFADvAgAAAA==.',
['爱刷']='爱刷牙的蚂蚁:BAAALgAECgYJBwAAAA==.',
['爸爸']='爸爸奶我:BAAALgAECgkJDQAAAA==.',
['牛有']='牛有财:BAAALgADCgUJBQAAAA==.',
['牛油']='牛油果芝士:BAAALgAECgkJCQAAAA==.',
['特雷']='特雷尔公爵:BAAALgAECgEJAgAAAA==.',
['狂暴']='狂暴的斧头:BAAALgAECgYJCQAAAA==.',
['狐狸']='狐狸狐气:BAAALgAECgMJAwAAAA==.',
['狗头']='狗头毛毛:BAAALgAECgkJDwAAAA==.',
['狼行']='狼行:BAAALgAECgkJCQABLgAFFAUJBQALADUPAA==.',
['猎魂']='猎魂师:BAAALgADCgQJBAAAAA==.',
['猫小']='猫小豆豆:BAAALgAECgQJBQAAAA==.',
['獣人']='獣人丶武僧:BAAALgAECgMJAQAAAA==.獣人丶萨满:BAAALgAECgkJCQAAAA==.',
['玉米']='玉米丨穗穗:BAABLgAFFH8HAAIUAAIJBSZfDgDcAAAUAAIJBSZfDgDcAAAAAA==.玉米丨粒粒:BAABLgAFFH8FAAMEAAIJkRR4PACyAAAEAAIJkRR4PACyAAAVAAEJfAy0AQBRAAAAAA==.',
['玛丽']='玛丽丶雷姬:BAAALgAECgcJBwAAAA==.',
['玛利']='玛利亚索普:BAAALgAECgEJAQAAAA==.',
['琥珀']='琥珀:BAAALgADCgUJBQAAAA==.',
['用心']='用心去感受:BAABLgAECn8bAAIEAAcJDRxuUQBDAgAEAAcJDRxuUQBDAgAAAA==.',
['番茄']='番茄炒蛋吗:BAAALgADCgIJAgAAAA==.',
['百变']='百变小爹:BAAALgADCgEJAQAAAA==.',
['盗宝']='盗宝奔波灞:BAAALgAECgEJAQAAAA==.',
['相信']='相信国运:BAAALgAECgMJAwAAAA==.',
['看门']='看门人郑大风:BAAALgAECgQJBAAAAA==.',
['眼眸']='眼眸丶:BAAALgAFFAIJAwAAAA==.',
['碧海']='碧海曜日:BAAALgAFFAQJBAAAAA==.',
['祝丶']='祝丶踏风:BAAALgAECgIJAgAAAA==.',
['章蕾']='章蕾:BAAALgAFFAQJBAAAAA==.',
['竹子']='竹子里有:BAAALgAECgUJBQAAAA==.',
['笨笨']='笨笨丶酱:BAACLgAFFH8FAAIGAAMJhgnyOgCdAAAGAAMJhgnyOgCdAAAuAAQKfx4AAwYACAklFK1ZALsBAAYABgnzFK1ZALsBAAcABAkVESoqABkBAAEuAAUUBAkHABYANxEA.',
['精盐']='精盐加味精:BAAALgAECgcJCgAAAA==.',
['糕手']='糕手凡凡:BAAALgAECgcJCwAAAA==.',
['紫衣']='紫衣不赴约:BAAALgAECgUJBQAAAA==.',
['绛雨']='绛雨:BAAALgAECgEJAQAAAA==.',
['续写']='续写丶一念沙:BAAALgAECgcJDQAAAA==.',
['维纳']='维纳斯之血:BAAALgAECgUJBQAAAA==.',
['缘猫']='缘猫伍:BAAALgAFFAQJBAAAAA==.缘猫叁:BAAALgAECgkJEAAAAA==.缘猫壹:BAAALgAECgcJBwAAAA==.缘猫拾:BAAALgAECgYJBgAAAA==.缘猫捌:BAAALgAFFAQJBAAAAA==.缘猫柒:BAAALgAECgkJEAAAAA==.缘猫肆:BAAALgAECgcJBwAAAA==.缘猫贰:BAAALgAECgkJCQAAAA==.缘猫陆:BAAALgAECgcJBwAAAA==.',
['翻滚']='翻滚吧麦旋风:BAAALgAECgYJBgAAAA==.',
['老沈']='老沈的小小:BAAALgAECgIJAgAAAA==.',
['耳朵']='耳朵先撒了謊:BAAALgAECgMJAwAAAA==.',
['聖咣']='聖咣丶牧:BAAALgAECgYJCQAAAA==.',
['肇事']='肇事咕儿:BAAALgAECgIJAgAAAA==.',
['胡姬']='胡姬:BAAALgADCgcJBwAAAA==.',
['胭脂']='胭脂:BAAALgADCgkJCgAAAA==.',
['脆脆']='脆脆鲨:BAABLgAECn8XAAMBAAcJ4hJ2TADDAQABAAcJ4hJ2TADDAQAPAAUJ9Au0QAD4AAAAAA==.',
['自律']='自律的小光头:BAAALgADCgEJAQAAAA==.自律的我:BAAALgAECgUJCAAAAA==.',
['舞动']='舞动青春:BAAALgAECgMJBAAAAA==.',
['艾拉']='艾拉瑞丽:BAAALgAECgYJDwAAAA==.',
['芥末']='芥末牛:BAAALgAECgIJAgAAAA==.',
['花星']='花星彩:BAAALgAECgMJAwAAAA==.',
['花泽']='花泽三郎二:BAABLgAFFH8FAAMFAAUJFhRUEwBUAQAFAAQJFhRUEwBUAQAXAAEJAACuEwBVAAAAAA==.',
['若水']='若水灬伶星:BAAALgAFFAEJAQAAAA==.若水灬怜纱:BAAALgAECgQJBAAAAA==.',
['茹此']='茹此德魔魔:BAAALgAECgEJAgAAAA==.',
['荣耀']='荣耀丨伽尔:BAAALgAECgQJCwAAAA==.',
['荳荳']='荳荳爸爸:BAAALgAECgQJBAAAAA==.',
['萌萌']='萌萌的小虎牙:BAAALgADCgcJBwAAAA==.萌萌的鬣人:BAAALgAECgEJAQAAAA==.',
['萨帕']='萨帕:BAAALgAECgQJDAAAAA==.',
['萨满']='萨满大叔:BAAALgAECgEJAQAAAA==.',
['落叶']='落叶秋:BAAALgAFFAEJAQAAAA==.',
['蒙古']='蒙古海军:BAAALgADCgUJBQAAAA==.',
['藤田']='藤田琴音:BAAALgADCgEJAQAAAA==.',
['虎门']='虎门抽烟:BAAALgAECgEJAgAAAA==.',
['蛋砕']='蛋砕满地伤:BAAALgAECgYJCwAAAA==.',
['观月']='观月:BAABLgAECn8VAAIYAAgJcB5YEACQAgAYAAgJcB5YEACQAgAAAA==.',
['記號']='記號:BAAALgAECgkJCAAAAA==.',
['讲唔']='讲唔掂甘串:BAAALgAFFAQJBAAAAA==.',
['说再']='说再见会再见:BAAALgAECgEJAQAAAA==.',
['费基']='费基尔沓:BAAALgADCgEJAQAAAA==.费基尔达:BAAALgAECgYJEgAAAA==.',
['贾布']='贾布里勒:BAAALgAECgQJBgAAAA==.',
['赠君']='赠君一壶酒:BAAALgAECgYJDQAAAA==.',
['超级']='超级软绵绵:BAACLgAFFH8MAAIEAAQJtA6rHwBJAQAEAAQJtA6rHwBJAQAuAAQKfyAAAgQACAmTHu8+AHwCAAQACAmTHu8+AHwCAAAA.',
['轨道']='轨道迫降:BAAALgADCgUJBQAAAA==.',
['轩辕']='轩辕劣人:BAAALgADCgEJAQAAAA==.',
['达拉']='达拉蹦吧:BAAALgADCgEJAQAAAA==.',
['过去']='过去的现在:BAAALgADCgMJAwAAAA==.',
['迪亚']='迪亚奈拉:BAAALgAFFAIJAgAAAA==.',
['迷迭']='迷迭香丶:BAAALgAECgUJBQAAAA==.',
['迷魂']='迷魂曲丶:BAAALgAECgYJBgAAAA==.',
['速趴']='速趴贝吉塔:BAAALgAECgEJAQAAAA==.',
['逢坂']='逢坂大河:BAAALgADCgUJBQAAAA==.',
['遗忘']='遗忘的梅菜:BAAALgAECgMJAwAAAA==.',
['那个']='那个冰法丶:BAAALgAECgQJBAAAAA==.那个熊德丶:BAAALgAECgYJDAAAAA==.',
['邪丶']='邪丶飲血饕鬄:BAABLgAECn8XAAIFAAcJcxxUSgAUAgAFAAcJcxxUSgAUAgAAAA==.',
['邪修']='邪修:BAAALgAECgYJBgAAAA==.',
['邪恶']='邪恶背叛:BAAALgAFFAEJAgAAAA==.',
['邵兰']='邵兰生:BAAALgAECgcJBgAAAA==.',
['重生']='重生之不做人:BAAALgAECgQJBQAAAA==.',
['野原']='野原葵丶:BAAALgAECgYJCQAAAA==.',
['钱多']='钱多多:BAAALgADCgEJAQAAAA==.',
['银白']='银白审判:BAAALgAECgEJAgAAAA==.',
['长城']='长城炮:BAAALgAFFAEJAQAAAA==.',
['门尼']='门尼:BAABLgAFFH8FAAIEAAMJvghPQgCqAAAEAAMJvghPQgCqAAAAAA==.',
['闪光']='闪光大菠萝:BAAALgAECgYJDAAAAA==.',
['阑风']='阑风伏雨:BAAALgADCgUJBQAAAA==.',
['阵列']='阵列感应成像:BAAALgAECgYJCAAAAA==.',
['阿丽']='阿丽:BAAALgADCgYJBgAAAA==.',
['阿兹']='阿兹阿亚:BAAALgAECgYJCgAAAA==.',
['阿大']='阿大龙:BAAALgADCgYJBgAAAA==.',
['阿牜']='阿牜:BAAALgAECgcJBwAAAA==.',
['阿痛']='阿痛木:BAABLgAECn8fAAMZAAgJsB8DDgDDAgAZAAgJsB8DDgDDAgAaAAUJ/BihFABxAQAAAA==.',
['阿莫']='阿莫很可爱:BAABLgAECn8UAAMbAAcJoww9IgBoAQAbAAcJoww9IgBoAQAQAAQJggQ7GQByAAAAAA==.',
['阿达']='阿达贡:BAAALgADCgUJBQAAAA==.',
['陆地']='陆地飞仙:BAAALgAECgEJAgAAAA==.',
['雨绮']='雨绮吃冰激凌:BAAALgAECgEJAgAAAA==.',
['雪如']='雪如诗:BAAALgAECgEJAwAAAA==.',
['雪晶']='雪晶菱:BAAALgAECgYJDQAAAA==.',
['雷加']='雷加尔:BAAALgAFFAIJBAAAAA==.',
['霸波']='霸波尔坤:BAAALgADCgMJAwAAAA==.',
['青璐']='青璐:BAAALgAECgkJDAABLgAFFAYJAwAcAAAAAA==.',
['韩素']='韩素薇:BAABLgAECn8YAAIEAAcJNh1dSQBbAgAEAAcJNh1dSQBbAgAAAA==.',
['飒飒']='飒飒撒萨:BAABLgAECn8gAAIZAAgJjB98DwCwAgAZAAgJjB98DwCwAgAAAA==.',
['飞一']='飞一般的鲁鲁:BAAALgAFFAQJBAAAAA==.',
['飞了']='飞了二个机:BAAALgAECgcJCQAAAA==.',
['飞叶']='飞叶快刀:BAAALgADCgUJBQAAAA==.',
['驱魔']='驱魔:BAAALgAECgEJAQAAAA==.',
['骤雨']='骤雨阵阵:BAABLgAFFH8GAAIdAAYJHwcAAAAAAAABAAYJHwcAAAAAAAAAAA==.',
['高大']='高大富帅:BAAALgAECgUJBwAAAA==.',
['鬼丶']='鬼丶灵:BAAALgAECgYJBgAAAA==.',
['魂色']='魂色冰封:BAAALgADCgEJAQAAAA==.',
['魂魄']='魂魄囧梦:BAAALgAFFAIJAgAAAA==.',
['黑鍋']='黑鍋我來背:BAAALgADCgQJBAAAAA==.',
['黛烟']='黛烟:BAAALgAECgMJBAAAAA==.',
['龙冬']='龙冬强:BAAALgAECgEJAQAAAA==.',
['龙的']='龙的艺术家:BAAALgAFFAQJBAAAAA==.',
['龙蛋']='龙蛋:BAAALgAECgUJCQAAAA==.',
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
