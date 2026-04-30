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

local lookup = {'Warlock-Destruction','DeathKnight-Blood','Unknown-Unknown','Mage-Frost','Priest-Holy','DeathKnight-Unholy','Warlock-Demonology','Shaman-Restoration','DemonHunter-Havoc','Hunter-BeastMastery','Monk-Brewmaster','Paladin-Retribution','Priest-Discipline','Druid-Guardian','DemonHunter-Devourer','Priest-Shadow','Hunter-Marksmanship','Hunter-Survival','Druid-Balance','Druid-Restoration','Monk-Windwalker',}
local provider = {region='CN',realm='桑德兰',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Aldursky:BAAALgAECgYJBgAAAA==.',
Bi='Bigdandan:BAAALgAECgIJBgAAAA==.',
Ch='Chatgpt:BAAALgAECgQJBQAAAA==.',
Co='Couk:BAAALgAECgcJBwAAAA==.',
De='Deathdeep:BAAALgAFFAEJAQAAAA==.',
Fr='Freedom:BAAALgADCgEJAQAAAA==.',
Li='Lichki:BAAALgAECgMJAwAAAA==.',
Lo='Loyesasaki:BAAALgAFFAEJAQABLgAFFAUJEwABAAAcAA==.',
Lu='Lunana:BAABLgAFFH8FAAICAAUJBxY4BQBQAQACAAUJBxY4BQBQAQAAAA==.',
Mi='Mindo:BAAALgAECgIJAgAAAA==.Missa:BAAALgAECgUJBwAAAA==.',
Mo='Moshi:BAAALgAECgEJAQAAAA==.',
Na='Naturalabyss:BAAALgAECgYJCwABLgAECgcJBwADAAAAAA==.',
Pp='Ppooee:BAAALgAECgkJDQAAAA==.',
Ra='Rabi:BAAALgADCgQJBAAAAA==.Razor:BAAALgAFFAEJAQAAAA==.',
Ro='Romance:BAAALgAECgIJAgAAAA==.',
Sa='Samael:BAABLgAECn8XAAIEAAgJpgt8jQC4AQAEAAgJpgt8jQC4AQAAAA==.',
Te='Teat:BAAALgADCgYJBgAAAA==.',
Tt='Ttea:BAAALgAECgEJAgAAAA==.',
Ya='Yanis:BAAALgAECgIJAgAAAA==.',
['一世']='一世菱殁:BAAALgAECgEJAQAAAA==.',
['一个']='一个人灬垂钓:BAAALgADCgMJAwAAAA==.',
['一碗']='一碗蛋炒饭:BAAALgAFFAIJAgAAAA==.',
['一零']='一零陆玖:BAAALgADCgcJBwAAAA==.',
['一頖']='一頖乄縌一:BAAALgADCgEJAQAAAA==.',
['七丶']='七丶年丨:BAAALgAECgYJBgAAAA==.',
['三七']='三七:BAAALgAECgIJBQAAAA==.',
['不良']='不良书生:BAAALgAECgMJAwAAAA==.',
['两岁']='两岁半:BAAALgAECgYJBgAAAA==.',
['丨吕']='丨吕小咘丶:BAAALgADCgMJBAAAAA==.',
['丨灼']='丨灼热之痛丨:BAABLgAFFH8FAAIFAAIJEQijBgB9AAAFAAIJEQijBgB9AAAAAA==.',
['中海']='中海石油:BAAALgAECgQJAQAAAA==.',
['丶蒲']='丶蒲式蛋挞:BAAALgAECgcJBwAAAA==.',
['丶酒']='丶酒桶:BAAALgAFFAEJAwAAAA==.',
['丶飞']='丶飞扬的使徒:BAAALgAECgEJAQAAAA==.',
['为之']='为之奈何:BAAALgAECgYJCAAAAA==.',
['为乐']='为乐当及时:BAAALgAECgIJAgAAAA==.',
['乄铁']='乄铁牛乄:BAAALgAFFAEJAQAAAA==.',
['乌瑞']='乌瑞恩之弓:BAAALgAFFAEJAQAAAA==.',
['九品']='九品:BAAALgAECgcJCAABLgAFFAUJEAAEAFIlAA==.',
['二丶']='二丶娃:BAAALgAECgYJBwAAAA==.',
['二鲨']='二鲨子:BAABLgAFFH8HAAIGAAQJ3xR3DwBjAQAGAAQJ3xR3DwBjAQAAAA==.',
['云岭']='云岭茉莉白:BAABLgAFFH8LAAIHAAQJSRyODwBjAQAHAAQJSRyODwBjAQAAAA==.',
['亚麻']='亚麻德:BAAALgAECgEJAQAAAA==.',
['人随']='人随倦鸟归:BAABLgAFFH8GAAIIAAIJNBPbGgCPAAAIAAIJNBPbGgCPAAAAAA==.',
['今夕']='今夕是何年:BAAALgAECgcJEwAAAA==.',
['伊利']='伊利妖郎:BAAALgADCgUJBgAAAA==.',
['伊歌']='伊歌思琪:BAAALgAECgYJDAAAAA==.',
['会加']='会加血的法丝:BAAALgADCgEJAQAAAA==.',
['余生']='余生:BAABLgAECn8UAAIJAAcJ1QwLKwBuAQAJAAcJ1QwLKwBuAQAAAA==.',
['依然']='依然的侠岚:BAAALgADCgEJAQAAAA==.',
['偶有']='偶有爱宠:BAABLgAFFH8HAAIKAAMJuA7vDAD6AAAKAAMJuA7vDAD6AAAAAA==.',
['傲雪']='傲雪丶凌霜:BAAALgAECgYJBgABLgAFFAUJEwABAAAcAA==.',
['兔兔']='兔兔爱丽丝:BAAALgAFFAIJAwAAAA==.',
['六便']='六便士:BAACLgAFFH8PAAILAAQJvAvOBgAGAQALAAQJvAvOBgAGAQAuAAQKfxwAAgsACAnRFwMhAPkBAAsACAnRFwMhAPkBAAAA.',
['兹拜']='兹拜因巴哈:BAAALgAECgEJAgAAAA==.',
['内心']='内心天堂:BAAALgAECgEJAQAAAA==.',
['冰封']='冰封的旅程:BAAALgAECgYJDAAAAA==.',
['冰点']='冰点雪域:BAAALgAFFAEJAQAAAA==.',
['冷月']='冷月初晴:BAAALgAECgMJAwAAAA==.',
['凋零']='凋零的花瓣:BAAALgAECgYJBwAAAA==.',
['几孤']='几孤星辰:BAAALgAECgcJCAAAAA==.几孤风月:BAAALgAECgEJAQAAAA==.',
['分不']='分不开的黑白:BAAALgADCgQJBAAAAA==.',
['刘书']='刘书睿:BAAALgAFFAEJAQAAAA==.',
['别惹']='别惹我行吗:BAAALgAECgcJDAAAAA==.',
['别抓']='别抓我啊:BAAALgADCgEJAQAAAA==.',
['前妻']='前妻丨:BAAALgAECgEJAQAAAA==.',
['又菜']='又菜又爱玩吖:BAAALgAFFAEJAQAAAA==.',
['变形']='变形钢筋:BAAALgAECgEJAQAAAA==.',
['只若']='只若初见:BAAALgAECgYJCQAAAA==.',
['可惜']='可惜不是你丷:BAAALgAECgIJAgAAAA==.',
['可爱']='可爱萌萌德:BAAALgAECgcJDQAAAA==.',
['叽里']='叽里咕噜猴:BAAALgADCgEJAQAAAA==.',
['吉林']='吉林农险:BAABLgAFFH8GAAIGAAIJ4xr5MwC4AAAGAAIJ4xr5MwC4AAABLgAFFAYJBwAGAEUUAA==.',
['向阳']='向阳而生:BAABLgAECn8WAAIGAAkJzR1SCwBAAwAGAAkJzR1SCwBAAwAAAA==.',
['听风']='听风的蚕:BAAALgAFFAEJAQAAAA==.',
['吾父']='吾父:BAAALgAECgYJBwAAAA==.',
['呆灬']='呆灬槑槑:BAABLgAECn8VAAMCAAcJ/w/THABkAQACAAcJ1Q/THABkAQAGAAIJmAvvCQFhAAAAAA==.',
['咕咕']='咕咕哒哒:BAAALgAFFAEJAQAAAA==.',
['哈喇']='哈喇卡拉:BAAALgADCgUJBQAAAA==.',
['哪个']='哪个德:BAAALgAECgMJAwAAAA==.',
['唯吉']='唯吉妮亚:BAAALgAECgEJAgAAAA==.',
['唸唸']='唸唸:BAAALgAECgIJAwAAAA==.',
['喝奶']='喝奶茶不:BAAALgAECgYJCwAAAA==.',
['喵呜']='喵呜灬樱桃:BAAALgADCgcJBwAAAA==.',
['喵猫']='喵猫的守护兽:BAAALgAECgUJBQAAAA==.',
['噬血']='噬血修罗:BAAALgAECgcJDQAAAA==.',
['四连']='四连鞭:BAAALgAECgMJAwAAAA==.',
['圣布']='圣布丁:BAACLgAFFH8PAAIMAAUJ0B6xAgDVAQAMAAUJ0B6xAgDVAQAuAAQKfxQAAgwACAm6IskPABADAAwACAm6IskPABADAAAA.',
['圣斗']='圣斗士亮仔:BAAALgADCgQJBAAAAA==.',
['圣殿']='圣殿大领主:BAAALgAECgIJAgAAAA==.',
['夜袭']='夜袭尼姑庵:BAAALgAECgYJCQAAAA==.',
['大不']='大不猎爹:BAAALgAECgYJCQAAAA==.',
['大空']='大空异:BAABLgAECn8UAAIFAAkJDA/DJgC3AQAFAAkJDA/DJgC3AQAAAA==.',
['大葱']='大葱丶:BAAALgAECgYJCQAAAA==.',
['大长']='大长腿小艾:BAAALgAECgIJAwAAAA==.',
['天丨']='天丨佑:BAAALgAECgEJAQAAAA==.',
['天使']='天使也低调:BAAALgAFFAEJAQAAAA==.',
['太麻']='太麻烦:BAAALgAECgUJCQAAAA==.',
['威尔']='威尔谢尔:BAABLgAECn8VAAIEAAgJ5x5eKwDFAgAEAAgJ5x5eKwDFAgAAAA==.',
['娜比']='娜比:BAAALgAECgQJBAAAAA==.',
['孤单']='孤单的阳仔:BAAALgAECgEJAgABLgAFFAEJAQADAAAAAA==.',
['宣萱']='宣萱:BAABLgAFFH8GAAIIAAMJ5yJwCQA6AQAIAAMJ5yJwCQA6AQAAAA==.',
['宸紫']='宸紫:BAAALgAECgEJAQAAAA==.',
['寂寞']='寂寞的火龙:BAAALgAECgEJAQAAAA==.',
['寒山']='寒山之巅:BAAALgAECgIJAgAAAA==.',
['射巛']='射巛钢板:BAAALgAECgQJBAAAAA==.',
['小奶']='小奶水:BAAALgAECgIJAgAAAA==.',
['小新']='小新临沂炒鸡:BAAALgAFFAEJAQAAAA==.',
['小智']='小智乄贼:BAAALgAECgcJBwAAAA==.',
['小泡']='小泡芙:BAAALgAECgEJAQAAAA==.',
['小狐']='小狐狸尾巴:BAAALgAFFAIJAwAAAA==.',
['小白']='小白肚皮:BAAALgADCgEJAQAAAA==.',
['小睐']='小睐尼:BAAALgAECgQJCAAAAA==.',
['小红']='小红手裙裙:BAAALgAECgQJBAAAAA==.',
['小肉']='小肉墩儿:BAAALgAECgYJBwAAAA==.',
['小胖']='小胖仔:BAAALgAECgkJBgAAAA==.',
['小陶']='小陶子:BAAALgADCgEJAQAAAA==.',
['小骑']='小骑士骑大马:BAAALgAECgUJBwAAAA==.',
['小魔']='小魔龙:BAAALgADCgIJAgAAAA==.',
['小鱼']='小鱼小树:BAAALgADCgcJDQAAAA==.',
['就叫']='就叫小龙人丷:BAAALgAECgMJAwAAAA==.',
['尾生']='尾生抱柱:BAAALgADCgEJAQAAAA==.',
['巧克']='巧克力曲奇:BAAALgAECgMJBAAAAA==.',
['布丁']='布丁很忙:BAAALgAECgYJBgAAAA==.',
['布拉']='布拉维砍屠夫:BAABLgAECn8VAAIGAAcJpBcIYgDNAQAGAAcJpBcIYgDNAQAAAA==.',
['带电']='带电小球:BAACLgAFFH8NAAIEAAQJHSJPEACTAQAEAAQJHSJPEACTAQAuAAQKfxwAAgQACAmlI9sSADYDAAQACAmlI9sSADYDAAAA.',
['常怀']='常怀千岁忧:BAAALgAFFAEJAgAAAA==.',
['干豆']='干豆腐:BAAALgADCgIJAgAAAA==.',
['广场']='广场舞王:BAAALgAECgYJCAAAAA==.',
['异物']='异物:BAAALgADCgEJAQAAAA==.',
['归途']='归途有风:BAAALgAECgcJDQAAAA==.',
['当哩']='当哩个当当:BAAALgAECgYJCgAAAA==.',
['彩虹']='彩虹色琥珀:BAAALgAECgkJCQAAAA==.',
['影色']='影色舞:BAAALgAECgQJBAAAAA==.',
['影薍']='影薍:BAAALgAECgQJBAAAAA==.',
['彼岸']='彼岸茶荼:BAAALgAECgEJAQAAAA==.',
['德道']='德道:BAAALgAECgQJBQAAAA==.',
['怎么']='怎么嗨了:BAAALgAECgEJAQAAAA==.',
['思密']='思密达灬兔子:BAAALgAFFAIJAgAAAA==.',
['思甜']='思甜:BAAALgAECgEJAQAAAA==.',
['恒真']='恒真:BAABLgAFFH8FAAIEAAIJNhtdNgC+AAAEAAIJNhtdNgC+AAAAAA==.',
['恶灵']='恶灵丶缠绕:BAAALgAECgQJBwAAAA==.',
['恶魔']='恶魔灬德:BAAALgAECgYJCwAAAA==.恶魔瓶:BAAALgAECgUJBQAAAA==.恶魔米迦勒:BAAALgADCgIJAgAAAA==.恶魔还是毁灭:BAAALgAECgIJAgAAAA==.',
['惔看']='惔看茳湖踛:BAAALgAECgEJAQAAAA==.',
['懶貓']='懶貓:BAAALgAECgUJBQAAAA==.',
['扯猫']='扯猫篓子:BAAALgAECgIJAgAAAA==.',
['扶摇']='扶摇的回忆:BAAALgAECgEJAQAAAA==.',
['折翼']='折翼的守护:BAAALgAECgQJCgAAAA==.',
['折鸢']='折鸢丶:BAAALgADCgEJAQAAAA==.',
['括弧']='括弧丶摔:BAAALgAECgIJAgAAAA==.',
['故里']='故里草木深:BAAALgAECgUJDgAAAA==.',
['斯銘']='斯銘:BAAALgAECgYJCgAAAA==.',
['无上']='无上神罚:BAAALgAECgEJAQAAAA==.',
['无牌']='无牌驯养师:BAAALgAECgQJBgAAAA==.',
['无痕']='无痕清波:BAABLgAECn8VAAIMAAgJZxJoXQDLAQAMAAgJZxJoXQDLAQAAAA==.',
['春雷']='春雷:BAAALgAECgYJBAAAAA==.',
['是风']='是风无影:BAAALgAECgIJAgAAAA==.',
['普罗']='普罗斯佩罗:BAAALgAFFAIJAwAAAA==.',
['暗夜']='暗夜纤儿:BAAALgADCgUJBQAAAA==.',
['暗小']='暗小曼:BAAALgAECgEJAQAAAA==.',
['暗痕']='暗痕刺青:BAAALgAFFAEJAQAAAA==.',
['曉丨']='曉丨灰狼:BAAALgAECgYJDQAAAA==.',
['最后']='最后的胜利:BAAALgADCgYJCAAAAA==.',
['月下']='月下等风来:BAAALgADCgcJBwAAAA==.',
['月光']='月光伤对论:BAAALgAECgEJAQAAAA==.月光光照大船:BAAALgAECgcJEwAAAA==.',
['月舞']='月舞倾城:BAAALgAECgcJBwAAAA==.月舞花熙:BAABLgAECn8WAAIMAAcJ3RgUQQAiAgAMAAcJ3RgUQQAiAgABLgAFFAQJBAADAAAAAA==.',
['月落']='月落霜华:BAAALgAECgQJBAAAAA==.',
['有兄']='有兄乃大:BAAALgAECgQJAQAAAA==.',
['未知']='未知的旅途:BAAALgAFFAIJAgAAAA==.',
['朮灬']='朮灬仕:BAAALgAECgUJBQAAAA==.',
['术丶']='术丶仕小哥哥:BAAALgAECgEJAQAAAA==.',
['松鼠']='松鼠布丁:BAAALgAECgcJBwAAAA==.',
['林云']='林云儿:BAAALgAECgUJCAAAAA==.',
['栾舒']='栾舒初:BAAALgAECgcJCQAAAA==.',
['桃花']='桃花朵朵:BAAALgAECgYJBgAAAA==.',
['梦修']='梦修罗:BAABLgAECn8hAAMFAAgJhBnLFQAuAgAFAAgJnxjLFQAuAgANAAYJOhNMJgBjAQAAAA==.',
['梦小']='梦小妖:BAACLgAFFH8LAAIIAAQJpg7wCQA1AQAIAAQJpg7wCQA1AQAuAAQKfyQAAggACAktGbgnAPIBAAgACAktGbgnAPIBAAAA.',
['梦里']='梦里灬花开:BAAALgAECgMJBgAAAA==.',
['楚逸']='楚逸君:BAAALgAECgYJEAAAAA==.',
['欢迎']='欢迎光临:BAAALgAECgMJAwAAAA==.',
['欧皇']='欧皇哼哼:BAAALgADCgMJAwAAAA==.',
['武帝']='武帝卢氏:BAABLgAFFH8IAAIMAAMJpQ9zJACjAAAMAAMJpQ9zJACjAAAAAA==.',
['死亡']='死亡一凋零:BAAALgAECgQJBAAAAA==.',
['比奇']='比奇堡大聪明:BAAALgAECgcJDgAAAA==.',
['水裙']='水裙蝶衣:BAAALgAECgQJBAAAAA==.',
['氵妖']='氵妖姬:BAAALgAFFAEJAgAAAA==.',
['江小']='江小皮的双彩:BAAALgAECgYJCQAAAA==.',
['江山']='江山如此多娇:BAAALgAECgIJAwAAAA==.',
['池御']='池御:BAAALgAFFAUJAQAAAA==.',
['沐丶']='沐丶神:BAAALgAECgYJCwAAAA==.',
['泡芙']='泡芙小妞:BAAALgAECgIJAgAAAA==.',
['泰德']='泰德:BAAALgAECgMJBgAAAA==.',
['深海']='深海灬孤獨:BAAALgAECgYJCgAAAA==.',
['清晨']='清晨小萨:BAAALgAECgIJAwAAAA==.',
['滴墨']='滴墨成殇:BAAALgAECgcJCQAAAA==.',
['灬女']='灬女乃流香灬:BAAALgAECgEJAQAAAA==.',
['灬影']='灬影刃刺青灬:BAAALgAECgQJBwAAAA==.',
['灬德']='灬德灬:BAAALgAECgEJAQAAAA==.',
['灬東']='灬東灬:BAAALgAECgMJBAAAAA==.',
['灬聖']='灬聖灬:BAAALgADCgEJAQAAAA==.',
['灼华']='灼华:BAAALgAECgQJBAAAAA==.',
['熊大']='熊大力:BAABLgAFFH8FAAIOAAIJZgRBAwBMAAAOAAIJZgRBAwBMAAAAAA==.',
['熊心']='熊心豹子胆:BAAALgADCgIJAwAAAA==.',
['熊猫']='熊猫人盛宴:BAAALgAECgYJCQAAAA==.',
['燃烧']='燃烧小情人:BAAALgADCgQJBAAAAA==.',
['牛先']='牛先僧:BAABLgAFFH8FAAILAAIJPQ2JHQCGAAALAAIJPQ2JHQCGAAAAAA==.',
['牛擦']='牛擦:BAAALgAFFAEJAQAAAA==.',
['牛牛']='牛牛玩妞妞:BAAALgADCgIJAgAAAA==.',
['牛皮']='牛皮豆:BAAALgAECgUJBgAAAA==.',
['牧天']='牧天:BAAALgAECgUJCwAAAA==.',
['物理']='物理張指导:BAAALgADCgEJAQAAAA==.',
['猛小']='猛小牛:BAAALgAECgIJAgAAAA==.',
['猩红']='猩红血番茄:BAAALgADCgQJBAAAAA==.',
['王十']='王十三:BAAALgADCgIJAgAAAA==.',
['王风']='王风夏:BAAALgAECgYJCgAAAA==.',
['玛露']='玛露希尔:BAAALgAECgEJAQAAAA==.',
['玦丶']='玦丶珏:BAAALgADCgcJDQAAAA==.',
['珍妮']='珍妮玛:BAAALgADCgEJAQAAAA==.',
['理塘']='理塘动物朋友:BAAALgADCgUJBQAAAA==.',
['瓦王']='瓦王丶列车:BAAALgAECgQJAgAAAA==.',
['生涯']='生涯守尸:BAAALgADCgUJBQAAAA==.',
['田园']='田园丨牧歌:BAAALgAECgIJAgAAAA==.',
['电压']='电压一万伏:BAAALgAECgYJDAAAAA==.',
['白拉']='白拉黑:BAAALgAECgEJAgAAAA==.',
['白鲸']='白鲸:BAAALgAECgYJBgAAAA==.',
['瞎仔']='瞎仔:BAAALgAECgIJAgAAAA==.',
['码头']='码头整瓶可乐:BAAALgAECgQJBAAAAA==.码头整瓶雪碧:BAAALgAFFAIJBAAAAA==.',
['破俩']='破俩莫:BAAALgAECgEJAQAAAA==.',
['碎蜂']='碎蜂:BAAALgAECgYJBgAAAA==.',
['祝踏']='祝踏岚:BAAALgAECgUJCQAAAA==.',
['祝遝']='祝遝岚:BAAALgADCgEJAQAAAA==.',
['神经']='神经刀老九:BAAALgAECgEJAQAAAA==.',
['禅宗']='禅宗六祖:BAAALgAECgEJAgAAAA==.',
['秋雨']='秋雨纷飞:BAAALgAECgEJAwAAAA==.',
['秒无']='秒无敌:BAAALgAECgIJAgAAAA==.',
['稚田']='稚田:BAAALgAECgQJBgAAAA==.',
['稳中']='稳中带皮丶:BAAALgAECgEJAQAAAA==.',
['站撸']='站撸专业户:BAAALgAECgYJBgAAAA==.',
['符娃']='符娃:BAAALgAECgEJAQAAAA==.',
['米姑']='米姑蜜柑:BAAALgAECgQJBgABLgAFFAEJAQADAAAAAA==.',
['糖寶']='糖寶沒有糖:BAAALgADCgMJAwAAAA==.',
['糖快']='糖快儿:BAAALgADCgYJBgAAAA==.',
['糖葫']='糖葫芦丶不甜:BAAALgAFFAEJAQAAAA==.',
['素食']='素食:BAAALgAECgEJAQAAAA==.',
['纸呛']='纸呛:BAAALgAECgYJBwAAAA==.',
['终结']='终结乌瑟尔:BAAALgAECgIJAgAAAA==.',
['罗幕']='罗幕轻寒:BAAALgAECgEJAQAAAA==.',
['罗莉']='罗莉安:BAAALgAECgUJCAAAAA==.',
['老从']='老从家小熊:BAAALgAECgMJAwAAAA==.',
['老牛']='老牛哥:BAAALgADCgYJBgAAAA==.',
['聆夜']='聆夜:BAAALgAECgUJBQAAAA==.',
['聋希']='聋希尔:BAAALgAECgEJAQAAAA==.',
['胖柚']='胖柚:BAAALgAECgIJAgAAAA==.',
['胖鱼']='胖鱼:BAAALgAECgEJAQAAAA==.',
['脂包']='脂包肌的狼狗:BAAALgAECgYJCgAAAA==.',
['脱油']='脱油瓶儿:BAAALgAECgYJCgAAAA==.',
['花落']='花落丶若相离:BAAALgAECgUJCAAAAA==.',
['花葬']='花葬鶄:BAAALgAECgEJAgAAAA==.',
['苏大']='苏大强:BAABLgAFFH8HAAMPAAIJthOkJgCmAAAPAAIJthOkJgCmAAAJAAEJDQ7ODQBPAAAAAA==.',
['苏打']='苏打冰棒:BAAALgAECgYJBgAAAA==.',
['苏醒']='苏醒的旋律:BAACLgAFFH8KAAIFAAQJkQPXCgC2AAAFAAQJkQPXCgC2AAAuAAQKfxsABBAACAkgD6UJAFUBABAACAkgD6UJAFUBAA0ABglvCIAvACQBAAUABAnADIVZAM4AAAAA.',
['荷笠']='荷笠戴夕阳:BAAALgAECgUJBwAAAA==.',
['萌萌']='萌萌的电耗子:BAAALgAECgUJCAAAAA==.',
['落霞']='落霞:BAAALgAECgMJAwAAAA==.',
['葵司']='葵司丶:BAAALgAECgIJAgAAAA==.',
['蓝德']='蓝德莉亚:BAAALgAECgEJAQAAAA==.',
['蓝胖']='蓝胖祖宗:BAABLgAFFH8FAAMKAAMJdh3OBwAmAQAKAAMJdh3OBwAmAQARAAEJmAmKLABAAAAAAA==.',
['蕾米']='蕾米尔:BAAALgAECgQJBAAAAA==.',
['蚩眼']='蚩眼:BAAALgADCgcJBwAAAA==.',
['西南']='西南人:BAAALgADCgIJAgAAAA==.',
['西弗']='西弗吉尼亚:BAAALgAECgIJAgAAAA==.',
['西悠']='西悠瓦拉:BAABLgAECn8XAAIKAAYJ6xSpVQBnAQAKAAYJ6xSpVQBnAQAAAA==.',
['见崎']='见崎鸣:BAAALgADCgMJBAAAAA==.',
['诺达']='诺达希尔的风:BAAALgAECgEJAQAAAA==.',
['豆丁']='豆丁的愿望:BAAALgADCgUJBQAAAA==.',
['豌豆']='豌豆卡卡:BAAALgAECgYJBgAAAA==.',
['赐机']='赐机:BAAALgADCgEJAQAAAA==.',
['赵得']='赵得住同学:BAAALgADCgUJBQAAAA==.',
['赵灵']='赵灵儿:BAAALgAECgYJBwAAAA==.',
['身体']='身体好上东:BAAALgAFFAIJAgAAAA==.',
['软甜']='软甜超可爱的:BAAALgAECgkJCgAAAA==.',
['轻如']='轻如夢:BAAALgAECgUJBQAAAA==.',
['还是']='还是我乖:BAAALgAECgEJAgAAAA==.',
['这个']='这个人很傲:BAAALgAFFAMJBAAAAA==.',
['造孽']='造孽丶:BAAALgADCgIJAgAAAA==.',
['酸奶']='酸奶味:BAAALgAECgQJBAAAAA==.',
['醉卧']='醉卧魅人:BAAALgAECgEJAQAAAA==.',
['醉弃']='醉弃红颜:BAAALgAECgMJAwAAAA==.',
['醉驾']='醉驾老司机:BAAALgADCgcJBwAAAA==.',
['醋溜']='醋溜土豆:BAAALgAECgUJBwAAAA==.',
['鈊砕']='鈊砕宝贝:BAAALgAECgQJAwAAAA==.',
['钱小']='钱小琥:BAACLgAFFH8HAAQKAAMJlxuOEADDAAAKAAIJrB2OEADDAAARAAEJdASPKwBEAAASAAIJOxAAAAAAAAAuAAQKfxUABAoABwklH1MuAPkBAAoABQlZIlMuAPkBABEABQnQGB0/AF0BABIAAwmEDgAAAAAAAAAA.',
['铠甲']='铠甲勇士:BAAALgAECgUJBQAAAA==.',
['长夜']='长夜月:BAAALgAECgQJCAAAAA==.',
['阿卡']='阿卡托什:BAAALgAECgIJAgAAAA==.',
['阿玛']='阿玛塔拉斯:BAABLgAECn8WAAMTAAcJ7BslIgDrAQATAAYJeCAlIgDrAQAUAAIJ6QcOuQBTAAAAAA==.',
['陌上']='陌上人茹玉:BAAALgADCgEJAQAAAA==.',
['降临']='降临:BAAALgAECgkJBgAAAA==.',
['限界']='限界突破:BAACLgAFFH8GAAMVAAQJ/hHdBABBAQAVAAQJ2Q/dBABBAQALAAEJ4xYAAAAAAAAuAAQKfyMAAwsACAlCGXsFALYBAAsACAlCGXsFALYBABUABQn5CqNJAOwAAAAA.',
['隔壁']='隔壁小王:BAAALgAECgIJAgAAAA==.',
['雅典']='雅典娜之盾:BAAALgAECgUJBQAAAA==.',
['雨落']='雨落八月:BAAALgAFFAQJBAABLgAFFAUJCwAUAFUPAA==.',
['雪域']='雪域炎炎:BAAALgADCgcJBwABLgAFFAEJAQADAAAAAA==.',
['雾凉']='雾凉丷:BAAALgAECgQJCAAAAA==.',
['雾霾']='雾霾终结者:BAAALgAECgcJDQAAAA==.',
['青春']='青春不能散场:BAAALgAECgEJAQAAAA==.',
['静夜']='静夜风起:BAAALgAECgQJBAAAAA==.',
['风雨']='风雨夜归魂:BAAALgAECgEJAgAAAA==.',
['飘渺']='飘渺丶彤彤:BAAALgADCgIJAQAAAA==.',
['香林']='香林:BAAALgAECgEJAQAAAA==.',
['香蕉']='香蕉咘呐呐:BAAALgADCgQJBAAAAA==.',
['馬路']='馬路:BAAALgAECgEJAQAAAA==.',
['骑骑']='骑骑猫:BAEALgAECgcJBwAAAA==.',
['黑灬']='黑灬夜:BAAALgADCgQJBAAAAA==.',
['黑白']='黑白胖熊:BAAALgADCgEJAQAAAA==.黑白艺术家:BAACLgAFFH8GAAIGAAQJ8w/QRgCWAAAGAAQJ8w/QRgCWAAAuAAQKfxgAAgYACQmzGeAiALQCAAYACQmzGeAiALQCAAAA.',
['黑羽']='黑羽殁使:BAAALgAECgQJCAAAAA==.',
['龙昂']='龙昂一:BAAALgAECgEJAwAAAA==.',
['龙舌']='龙舌兰:BAAALgADCgUJBQAAAA==.',
['龙魂']='龙魂毁:BAAALgAFFAEJAQAAAA==.',
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
