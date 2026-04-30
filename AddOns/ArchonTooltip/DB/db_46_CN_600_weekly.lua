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

local lookup = {'Warlock-Demonology','Warlock-Destruction','DemonHunter-Devourer','DeathKnight-Blood','DeathKnight-Unholy','Evoker-Augmentation','Monk-Windwalker','Monk-Mistweaver','Mage-Frost','Priest-Shadow','Paladin-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Devastation','Monk-Brewmaster','Priest-Holy','Shaman-Restoration','Paladin-Retribution','Warrior-Arms','Warrior-Fury','Druid-Restoration','Hunter-Survival','Druid-Balance','Rogue-Subtlety','Warrior-Protection','Evoker-Preservation','Priest-Discipline','Druid-Guardian','DemonHunter-Havoc','Rogue-Assassination','Unknown-Unknown','Shaman-Enhancement',}
local provider = {region='CN',realm='卡拉赞',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ao='Aokaka:BAAALgAFFAEJAQAAAA==.',
Co='Conversation:BAAALgAFFAEJAQAAAA==.',
Cr='Crasslii:BAAALgAECgEJAQAAAA==.',
De='Demonlord:BAACLgAFFH8KAAMBAAQJaxFYGQAmAQABAAQJMQ5YGQAmAQACAAEJQhRlFABWAAAuAAQKfyIAAwIABwmQIAwOAOYBAAIABgl1HQwOAOYBAAEABQkiGXl1AHIBAAAA.',
El='Elysia:BAAALgADCgYJBgABLgAECggJJAADANshAA==.',
En='Enshown:BAAALgAECgEJAgAAAA==.',
Gr='Grimbatore:BAACLgAFFH8KAAIEAAQJMRL2BwANAQAEAAQJMRL2BwANAQAuAAQKfx0AAwQACAmVGz4LAGECAAQACAmVGz4LAGECAAUAAQmNBmIqASsAAAAA.',
Ha='Happyyr:BAAALgAECgUJBgAAAA==.Harry:BAAALgAFFAYJBAAAAA==.',
Ka='Karsa:BAAALgAECgEJAQAAAA==.',
La='Lamimi:BAAALgAECgYJAgAAAA==.',
Le='Leoni:BAAALgADCgUJBQAAAA==.',
Ll='Llemon:BAAALgADCgUJBQAAAA==.',
Me='Megumin:BAAALgAECgcJBwABLgAFFAcJGQAGAPggAA==.',
Mi='Mirae:BAACLgAFFH8JAAIHAAQJ5x/VAgB/AQAHAAQJ5x/VAgB/AQAuAAQKfxkAAwcACAkIJT4GAB0DAAcACAkIJT4GAB0DAAgAAwnHAU5kAEAAAAAA.',
No='Nozuo:BAAALgADCgEJAQAAAA==.',
Ot='Otamendi:BAAALgAECgEJAQAAAA==.',
Pr='Precious:BAAALgAECgEJAQAAAA==.',
Sa='Savemekill:BAABLgAFFH8FAAIHAAQJWxbsEABQAAAHAAQJWxbsEABQAAAAAA==.Saybose:BAAALgADCgEJAQAAAA==.',
Ti='Tig:BAAALgAFFAMJAwAAAA==.',
Vi='Vila:BAACLgAFFH8GAAIJAAMJgxesKAARAQAJAAMJgxesKAARAQAuAAQKfxkAAgkACAlqIWAbAAkDAAkACAlqIWAbAAkDAAAA.',
Wu='Wuhenlr:BAAALgAECgkJCgABLgAFFAQJDAAKABkGAA==.',
Yu='Yuge:BAAALgAFFAEJAQAAAA==.',
['一个']='一个纯洁的人:BAAALgAECgEJAQAAAA==.',
['一只']='一只大帅哥:BAAALgAECgEJAQAAAA==.一只好恶魔:BAAALgAECgYJBwAAAA==.',
['一叶']='一叶灬之秋:BAAALgAECgMJBwAAAA==.',
['一大']='一大波妹纸:BAAALgADCgMJAwAAAA==.',
['一忍']='一忍:BAAALgADCgEJAQAAAA==.',
['一斩']='一斩杀一:BAAALgAECgIJAgAAAA==.',
['七小']='七小月:BAAALgAECgEJAQAAAA==.',
['三叶']='三叶草:BAABLgAECn8UAAIJAAYJVCZwNAChAgAJAAYJVCZwNAChAgAAAA==.',
['三好']='三好市民:BAAALgAFFAEJAQAAAA==.',
['三角']='三角初华:BAAALgAECgUJEwAAAA==.',
['不要']='不要非主流:BAABLgAFFH8FAAIJAAMJoQO/MQDkAAAJAAMJoQO/MQDkAAAAAA==.',
['东厂']='东厂仅一位:BAAALgAFFAEJAQAAAA==.',
['东方']='东方鈈败:BAAALgAFFAIJBAAAAA==.',
['东陵']='东陵大盗:BAAALgAECgMJBgAAAA==.',
['丨冷']='丨冷丨:BAAALgAECgMJAwAAAA==.',
['丨糖']='丨糖丨:BAACLgAFFH8KAAICAAMJLgRbAgCLAAACAAMJLgRbAgCLAAAuAAQKfxUAAwIACAkGFEEqABgBAAEABwktDOdyAHkBAAIABwneEkEqABgBAAAA.',
['丫抢']='丫抢我爽歪歪:BAAALgAECgYJEgAAAA==.',
['临光']='临光:BAAALgAECgMJAwAAAA==.',
['丶某']='丶某处:BAABLgAFFH8FAAILAAMJaQp4CQCQAAALAAMJaQp4CQCQAAAAAA==.',
['丷熊']='丷熊熊丷:BAAALgAECgEJAgAAAA==.',
['为你']='为你疯魔:BAAALgADCgUJBQAAAA==.',
['乌发']='乌发五天:BAAALgAECgQJBgAAAA==.',
['五六']='五六七之奶骑:BAAALgAECgEJAQAAAA==.',
['亣厈']='亣厈:BAAALgADCgEJAQAAAA==.',
['他怎']='他怎么会:BAAALgAECgYJCwAAAA==.',
['伊多']='伊多多:BAAALgAECgYJCwAAAA==.',
['伊蒙']='伊蒙:BAAALgADCgUJBQAAAA==.',
['会长']='会长的二大爷:BAAALgAECgYJDQAAAA==.',
['伤心']='伤心小狗:BAAALgAECgYJDgAAAA==.',
['依莉']='依莉雅丝菲尔:BAAALgAECgIJAgAAAA==.',
['兄弟']='兄弟情义重:BAABLgAFFH8KAAMMAAMJhB2iBAA1AQAMAAMJhB2iBAA1AQANAAIJXgsaIACVAAAAAA==.',
['兔曦']='兔曦曦:BAAALgAECgEJAQAAAA==.',
['全球']='全球鹰:BAAALgADCgYJBgAAAA==.',
['八六']='八六年健力宝:BAACLgAFFH8MAAIFAAUJ9CAOEwBWAQAFAAUJ9CAOEwBWAQAuAAQKfyYAAgUACAkyJAkUAAMDAAUACAkyJAkUAAMDAAAA.',
['八幡']='八幡海铃:BAAALgAECgEJAQAAAA==.',
['兽兽']='兽兽惹人爱:BAAALgAFFAIJBAAAAA==.',
['冰冷']='冰冷:BAAALgAECgcJBwAAAA==.',
['冰木']='冰木:BAAALgAECgYJBgAAAA==.',
['冰风']='冰风传奇:BAAALgAECgMJAwAAAA==.',
['凶猛']='凶猛又天眞:BAACLgAFFH8KAAIGAAQJgw3WDQAiAQAGAAQJgw3WDQAiAQAuAAQKfx4AAwYACAkSIEcIAPQCAAYACAkSIEcIAPQCAA4AAgl3Bz04AFYAAAAA.',
['加一']='加一:BAAALgADCgQJBAAAAA==.',
['加油']='加油吧英雄:BAACLgAFFH8IAAIPAAMJUQXuFgC6AAAPAAMJUQXuFgC6AAAuAAQKfxkAAw8ABwl0EPM8AFMBAA8ABgnjEvM8AFMBAAcAAQlKBGGHACgAAAAA.',
['十级']='十级电焊工:BAAALgAECgMJAwAAAA==.',
['千寻']='千寻守护:BAAALgAFFAIJAwAAAA==.',
['华叔']='华叔:BAAALgADCgEJAQAAAA==.',
['南海']='南海小虾:BAAALgAECgEJAQAAAA==.',
['卡伦']='卡伦蒂斯:BAAALgADCgEJAQAAAA==.',
['卡萨']='卡萨布兰咔:BAAALgADCgEJAQAAAA==.',
['又丑']='又丑又漂亮:BAAALgAECgEJAQAAAA==.',
['变形']='变形铜刚:BAAALgAECgYJDAAAAA==.',
['叮噹']='叮噹猫:BAAALgADCggJCAAAAA==.',
['吃小']='吃小闹:BAAALgAECgQJCAAAAA==.',
['吉吉']='吉吉思密达:BAAALgAECgEJAQAAAA==.',
['后沙']='后沙峪何广智:BAAALgAECgEJAQAAAA==.',
['咀乐']='咀乐逗奶:BAAALgAECgEJAgAAAA==.',
['哀木']='哀木涕搞毛啊:BAAALgAECgEJAgAAAA==.',
['品茗']='品茗听雨:BAAALgADCgYJBgAAAA==.',
['四张']='四张机:BAAALgAECgkJCQABLgAFFAUJCQAQAHomAA==.',
['四道']='四道风:BAAALgAECgEJBAAAAA==.',
['圖樣']='圖樣灬圖森魄:BAABLgAFFH8GAAIRAAIJFSOaCADJAAARAAIJFSOaCADJAAAAAA==.',
['圣光']='圣光灬丫丫:BAAALgAECgIJAwAAAA==.圣光瞎了眼:BAABLgAECn8XAAISAAcJ1B3/OwA0AgASAAcJ1B3/OwA0AgAAAA==.',
['圣弃']='圣弃疗:BAAALgADCgYJBgAAAA==.',
['塞尔']='塞尔提:BAAALgAECgUJBgAAAA==.',
['壮壮']='壮壮:BAABLgAFFH8MAAMTAAQJ1QH/BQCzAAAUAAQJSAFlEQD8AAATAAQJygH/BQCzAAABLgAFFAYJBwADAGYTAA==.',
['备用']='备用牛排:BAACLgAFFH8LAAIVAAQJXBKECwAoAQAVAAQJXBKECwAoAQAuAAQKfx4AAhUACAl0IKkOAMQCABUACAl0IKkOAMQCAAAA.',
['夏尔']='夏尔:BAAALgAECgIJAgAAAA==.',
['夜伴']='夜伴钟声:BAAALgAECgEJAQAAAA==.',
['夜灬']='夜灬如此耀眼:BAAALgAECgEJAQAAAA==.',
['夜落']='夜落知秋:BAAALgAECgIJAwAAAA==.',
['大帝']='大帝丶:BAAALgAECgYJBgAAAA==.',
['大酋']='大酋长:BAAALgAECgMJAwAAAA==.',
['大顺']='大顺儿:BAAALgAECgUJBQAAAA==.',
['天之']='天之傷痕:BAAALgAECgEJAQAAAA==.',
['天命']='天命之人:BAABLgAFFH8EAAIBAAIJdRaKMACxAAABAAIJdRaKMACxAAAAAA==.',
['夷丁']='夷丁突骑:BAAALgAECgkJCQAAAA==.',
['奇迹']='奇迹于你:BAAALgADCgEJAQAAAA==.',
['奥卡']='奥卡卡:BAAALgAECgEJAQAAAA==.',
['奶萨']='奶萨:BAAALgAECgcJAQAAAA==.',
['妈妈']='妈妈:BAAALgAFFAQJBAAAAA==.',
['威廉']='威廉迪特:BAAALgAFFAIJBAAAAA==.',
['孜然']='孜然:BAAALgADCgUJBQAAAA==.',
['孤狼']='孤狼的挽歌:BAAALgAFFAIJAgAAAA==.',
['安颜']='安颜:BAAALgAFFAIJBAAAAA==.',
['宸谐']='宸谐音尘:BAAALgAFFAUJBAAAAA==.',
['射射']='射射社会摇:BAAALgADCgEJAQAAAA==.',
['将近']='将近酒丶:BAAALgADCgEJAQAAAA==.',
['小动']='小动物饲养员:BAACLgAFFH8JAAMMAAQJ6RlNGACmAAANAAIJ5R8BGgC0AAAMAAMJGxRNGACmAAAuAAQKfxoABA0ACAkfJeMOAMgCAA0ABwldJOMOAMgCAAwABwlGJX0pABECABYAAQkAABYrAFIAAAEuAAUUBAkKAAYAgw0A.',
['小卷']='小卷:BAAALgAECgYJBgAAAA==.',
['小埋']='小埋:BAAALgAECgcJCwAAAA==.',
['小捣']='小捣蛋:BAAALgAECgcJCwAAAA==.',
['小白']='小白菇凉丶:BAAALgAECgcJAQAAAA==.',
['小红']='小红花:BAAALgAECgQJBQAAAA==.',
['小脚']='小脚掌:BAAALgAECgQJBAAAAA==.',
['小葵']='小葵:BAAALgAECgEJAQAAAA==.',
['小部']='小部德德:BAABLgAFFH8GAAIXAAQJURCtCgBAAQAXAAQJURCtCgBAAQAAAA==.',
['尛悍']='尛悍妇:BAAALgADCgcJBwAAAA==.',
['就叫']='就叫我公子:BAAALgAECgYJBwAAAA==.',
['就差']='就差一丢丢儿:BAAALgAECggJDgAAAA==.',
['山水']='山水映月湾:BAAALgADCgQJBAAAAA==.',
['岱宗']='岱宗又如何:BAAALgAECgUJBQAAAA==.',
['巨无']='巨无霸侠:BAAALgAECgkJBwAAAA==.',
['带上']='带上一头猪:BAAALgAECgEJAQAAAA==.',
['平衡']='平衡动力学:BAAALgAECgEJAwAAAA==.',
['年迈']='年迈的父皇:BAAALgAECgQJBAAAAA==.',
['库克']='库克塞顿:BAAALgAFFAEJAQAAAA==.',
['库库']='库库的亡骑:BAAALgAECgYJDAAAAA==.库库的德:BAAALgAECgIJAgAAAA==.',
['彡再']='彡再燃香烟彡:BAAALgAECgYJCAAAAA==.',
['影魂']='影魂丨:BAACLgAFFH8LAAISAAQJ1CapAgDWAQASAAQJ1CapAgDWAQAuAAQKfx4AAhIACAlHJqgEAIIDABIACAlHJqgEAIIDAAAA.',
['往事']='往事如烟:BAAALgADCgEJAQAAAA==.',
['御姐']='御姐有三好:BAAALgAECgEJAQAAAA==.',
['御龙']='御龙品青梅:BAABLgAECn8WAAIBAAgJuhkLLgBVAgABAAgJuhkLLgBVAgAAAA==.',
['微雨']='微雨波:BAAALgAECgcJBwAAAA==.',
['德不']='德不到的德:BAAALgAFFAEJAQAAAA==.德不配喂:BAAALgAECgEJAQAAAA==.',
['德克']='德克萨斯之手:BAAALgAECgcJBwAAAA==.',
['思空']='思空摘星:BAACLgAFFH8IAAIYAAMJAxpsDAAdAQAYAAMJAxpsDAAdAQAuAAQKfx4AAhgACAmgIYkIAAkDABgACAmgIYkIAAkDAAAA.',
['悪丿']='悪丿召使:BAAALgAECgQJBwAAAA==.',
['我栖']='我栖春山:BAABLgAECn8ZAAMZAAkJzyCSAQBuAwAZAAkJgiCSAQBuAwAUAAkJ4BvSCwD8AgABLgAFFAYJEwAZAC8ZAA==.',
['戒酒']='戒酒中:BAAALgADCgIJAgAAAA==.',
['折射']='折射:BAAALgAECgEJAQAAAA==.',
['抹茶']='抹茶小懒:BAAALgADCgUJBQAAAA==.',
['指尖']='指尖沙:BAAALgAECgYJCQAAAA==.',
['挥剑']='挥剑舞忧伤:BAABLgAFFH8FAAMFAAUJKhqmEABeAQAFAAQJKhqmEABeAQAEAAEJAAAREQBqAAAAAA==.',
['捣乱']='捣乱的糖果:BAAALgAECgEJAQAAAA==.',
['提里']='提里奧丶弗丁:BAAALgAECgQJBAAAAA==.',
['摇曳']='摇曳露营:BAAALgAECgMJBgAAAA==.',
['撕裂']='撕裂:BAAALgAFFAQJBAAAAA==.',
['收丶']='收丶破烂儿:BAAALgAECgYJDQAAAA==.',
['敖鲁']='敖鲁古雅:BAAALgAECgcJDgAAAA==.',
['敗者']='敗者食尘:BAAALgAECgEJAQAAAA==.',
['斩炎']='斩炎丶:BAAALgAECgMJAwABLgAFFAQJCgAGAIMNAA==.',
['旋风']='旋风战戟:BAAALgAECgEJAQAAAA==.',
['无心']='无心灬残月:BAAALgAFFAIJAgAAAA==.',
['无甜']='无甜蜜不生活:BAAALgAECgcJDgAAAA==.',
['时光']='时光战:BAAALgAECgEJAQAAAA==.',
['昂特']='昂特丶理沃堡:BAAALgAECgEJAQAAAA==.',
['明珠']='明珠暗投:BAAALgAECgEJAQAAAA==.',
['星位']='星位合图:BAABLgAFFH8SAAIaAAUJJxU0BQCkAQAaAAUJJxU0BQCkAQAAAA==.',
['星河']='星河归烬:BAAALgAFFAIJBAAAAA==.',
['星海']='星海尽散:BAAALgADCgYJBgAAAA==.',
['星灭']='星灭:BAAALgAECgYJDgAAAA==.',
['暗轨']='暗轨:BAAALgAECggJAgAAAA==.',
['最终']='最终天堂:BAABLgAFFH8JAAIIAAcJIhQsBgBqAQAIAAcJIhQsBgBqAQAAAA==.',
['月影']='月影残空:BAAALgAECgcJDQAAAA==.月影轩辕圣:BAAALgAECgIJAgAAAA==.',
['月色']='月色润青石:BAAALgAFFAIJAgAAAA==.',
['月见']='月见桜:BAAALgAECgUJBgAAAA==.月见澪:BAACLgAFFH8KAAIbAAQJNRNhCQBIAQAbAAQJNRNhCQBIAQAuAAQKfygAAhsACAlvIbMBAHECABsACAlvIbMBAHECAAAA.',
['木偶']='木偶:BAAALgAECgMJAQAAAA==.木偶师:BAAALgAECgcJBwAAAA==.',
['末丶']='末丶洛:BAACLgAFFH8FAAISAAQJxh9NBwB8AQASAAQJxh9NBwB8AQAuAAQKfxkAAhIACQlmH+wTAPQCABIACQlmH+wTAPQCAAEuAAUUBQkOABIATiYA.',
['机智']='机智的蛋卷呀:BAAALgAFFAMJAwAAAA==.',
['杭白']='杭白菊:BAAALgADCgUJBQAAAA==.',
['果冻']='果冻牛肉罐头:BAAALgAECgYJBQAAAA==.',
['枪乄']='枪乄火:BAAALgAECgYJBAAAAA==.',
['格鲁']='格鲁古古:BAAALgAECgEJAQAAAA==.',
['梦游']='梦游仙境之旅:BAAALgAECgEJAQAAAA==.',
['棠梨']='棠梨煎雪:BAAALgAECgkJCQAAAA==.',
['楚池']='楚池:BAAALgAECgYJDAAAAA==.',
['止痛']='止痛药:BAAALgAECgcJEgAAAA==.',
['武圣']='武圣石先锋:BAAALgAECgEJAQAAAA==.',
['死之']='死之先锋:BAAALgAECgYJEgAAAA==.',
['死亡']='死亡領主:BAABLgAFFH8HAAIFAAMJ9BDaKwDrAAAFAAMJ9BDaKwDrAAAAAA==.',
['永不']='永不停日:BAAALgADCgkJCQAAAA==.',
['永夜']='永夜丶怒风:BAAALgADCgcJBwAAAA==.永夜蔷薇:BAAALgAECgYJCAAAAA==.',
['求上']='求上岸:BAAALgAFFAQJBAAAAA==.',
['江月']='江月年年:BAAALgAECgQJBAAAAA==.',
['沐川']='沐川內枯:BAACLgAFFH8LAAQUAAQJriZeAwC/AQAUAAQJriZeAwC/AQATAAEJXx1CCQBfAAAZAAEJsA1aEABBAAAuAAQKfxkABBQACAn3JYEcAGkCABQABglhIIEcAGkCABMABQlXJcsNAMABABkAAQkfJRk8AGsAAAEuAAUUBwkNABkAzhkA.',
['沙条']='沙条爱歌:BAABLgAECn8VAAMQAAYJDB5FHQD0AQAQAAYJDB5FHQD0AQAKAAYJDhPfNgA2AQAAAA==.',
['没棱']='没棱角的石头:BAAALgAECgQJBQAAAA==.',
['法爷']='法爷:BAAALgAECgQJBQAAAA==.',
['泥煤']='泥煤琥珀艾尔:BAAALgAECgcJCwAAAA==.',
['洗脚']='洗脚的章鱼:BAACLgAFFH8IAAISAAMJSwTFCwDZAAASAAMJSwTFCwDZAAAuAAQKfxgAAhIACAkUHOgtAGsCABIACAkUHOgtAGsCAAAA.',
['浪德']='浪德须名:BAAALgAECgQJBwAAAA==.',
['浮光']='浮光织梦:BAAALgAECgEJAQAAAA==.',
['海纳']='海纳无穷:BAAALgADCgEJAQAAAA==.',
['海蓝']='海蓝色:BAAALgAFFAEJAQAAAA==.',
['消消']='消消牧:BAAALgADCgEJAQAAAA==.',
['淡定']='淡定的整死你:BAAALgAECgEJAQAAAA==.',
['清浅']='清浅流年:BAAALgADCgEJAQAAAA==.',
['溜了']='溜了:BAAALgAECgYJBwAAAA==.',
['滚滚']='滚滚武僧:BAAALgAECgEJAQAAAA==.',
['火神']='火神丶睿:BAAALgAECgEJAQAAAA==.',
['灬呼']='灬呼哈灬:BAACLgAFFH8MAAIFAAQJdRNdFgBKAQAFAAQJdRNdFgBKAQAuAAQKfxoAAgUACAn5HoczAGgCAAUACAn5HoczAGgCAAAA.',
['灬磊']='灬磊子灬:BAAALgAECgEJAQAAAA==.',
['灬趣']='灬趣多多灬:BAAALgAECgUJBQAAAA==.',
['灬霜']='灬霜丶火灬:BAAALgAECgYJDAAAAA==.',
['烽痞']='烽痞巴拉刚:BAABLgAFFH8GAAIFAAQJABmBIQASAQAFAAQJABmBIQASAQAAAA==.',
['烽谜']='烽谜大刚:BAAALgAFFAIJAwAAAA==.',
['照灬']='照灬影:BAAALgAFFAQJBAAAAA==.',
['熊猫']='熊猫圆圆:BAAALgADCgEJAQAAAA==.',
['燃宝']='燃宝哥哥:BAABLgAFFH8GAAIcAAIJfwMRAwBWAAAcAAIJfwMRAwBWAAAAAA==.',
['燕返']='燕返:BAAALgAECgIJAwAAAA==.',
['爱吃']='爱吃土豆丝:BAAALgAECgcJDAAAAA==.',
['爱捣']='爱捣蛋呢:BAACLgAFFH8NAAIBAAUJACJ9AwDqAQABAAUJACJ9AwDqAQAuAAQKfx0AAgEACAngJf0HAEMDAAEACAngJf0HAEMDAAAA.',
['牛之']='牛之德:BAAALgADCgcJBwAAAA==.',
['牛牛']='牛牛大作战:BAAALgAECgkJCQAAAA==.牛牛棒棒粗丶:BAAALgADCgIJAgAAAA==.',
['牧得']='牧得感情:BAAALgAFFAEJAQAAAA==.',
['特狼']='特狼朴:BAAALgAECgIJAgAAAA==.',
['狂燃']='狂燃:BAAALgAECgYJBgAAAA==.',
['狐礼']='狐礼狐屠:BAAALgAECgcJBwAAAA==.',
['狮子']='狮子歌歌:BAAALgAECggJEQAAAA==.',
['猪肘']='猪肘堡大魔王:BAAALgADCgYJBgAAAA==.',
['猫荷']='猫荷:BAAALgAECgYJCAAAAA==.',
['猴皮']='猴皮筋弹弓王:BAAALgAECgIJAgAAAA==.',
['玉米']='玉米枝什:BAAALgADCgEJAQAAAA==.',
['现场']='现场直播:BAAALgAECgUJCQAAAA==.',
['珍娜']='珍娜的姑妈:BAAALgADCgUJBQAAAA==.',
['班主']='班主任:BAAALgAECgkJCgAAAA==.',
['琳琅']='琳琅丶:BAAALgADCgUJBQAAAA==.',
['生气']='生气使无敌:BAAALgAECgEJAQAAAA==.',
['电哥']='电哥刷大白:BAAALgAECgEJAQAAAA==.',
['疯狂']='疯狂屠戮:BAACLgAFFH8HAAISAAQJTAtADwAuAQASAAQJTAtADwAuAQAuAAQKfx4AAhIACAmGHMgiAJ4CABIACAmGHMgiAJ4CAAAA.',
['白银']='白银之扌:BAAALgAECgEJAQAAAA==.',
['皮皮']='皮皮法:BAABLgAFFH8OAAIJAAYJNhMMAgCtAQAJAAYJNhMMAgCtAQAAAA==.',
['看晚']='看晚霞落尽:BAAALgADCgEJAQAAAA==.',
['真不']='真不吃香菜:BAAALgAECgYJDAAAAA==.',
['破天']='破天倚箭:BAAALgAECgQJBAAAAA==.',
['神之']='神之守护丶喵:BAAALgAECgcJCwAAAA==.',
['神张']='神张角:BAAALgAECgUJBAAAAA==.',
['神棍']='神棍御雷诀:BAAALgAECgEJAQAAAA==.',
['禁止']='禁止投喂:BAAALgAECgkJCQAAAA==.',
['禅神']='禅神:BAAALgADCgEJAQAAAA==.',
['秋名']='秋名山山神:BAABLgAFFH8HAAIdAAUJAx5xAgBpAQAdAAUJAx5xAgBpAQAAAA==.',
['答案']='答案死骑:BAAALgAECgEJAgAAAA==.',
['糖棉']='糖棉花:BAACLgAFFH8LAAIYAAQJCBQcCQBdAQAYAAQJCBQcCQBdAQAuAAQKfxkAAxgACAmaIscIAAUDABgACAmaIscIAAUDAB4AAQmGA1IiACMAAAAA.',
['糖糖']='糖糖果:BAAALgAECgUJBQAAAA==.',
['紫术']='紫术虾米:BAAALgAECgQJBAAAAA==.',
['絕灬']='絕灬戀:BAAALgAFFAIJAgAAAA==.',
['红糖']='红糖雪糕:BAAALgAECgMJCQAAAA==.',
['红鼻']='红鼻毛船长:BAAALgAECgEJAQAAAA==.',
['纸糊']='纸糊的大咕咕:BAAALgAECgEJAQAAAA==.',
['绿毛']='绿毛饲养员:BAAALgAECgQJBQAAAA==.',
['绿色']='绿色游侠:BAAALgAECgEJAQABLgAECgEJAQAfAAAAAA==.',
['罖罖']='罖罖亽亽:BAAALgAECgYJDAAAAA==.',
['美妙']='美妙梦幻之旅:BAAALgADCgUJBQAAAA==.',
['老捣']='老捣乱呢:BAAALgAFFAMJBAABLgAFFAUJDQABAAAiAA==.老捣蛋呢:BAAALgAECgUJBgAAAA==.',
['老猫']='老猫的怨念:BAABLgAECn8UAAMRAAcJFw4TSQBdAQARAAcJFw4TSQBdAQAgAAEJkAE8DwAjAAAAAA==.',
['老鬼']='老鬼丶:BAAALgAECgIJAgAAAA==.',
['联盟']='联盟滴好基友:BAAALgADCgEJAQAAAA==.',
['聖也']='聖也:BAABLgAECn8VAAMLAAYJpRAASQBTAQALAAYJpRAASQBTAQASAAUJgAZ5MwDMAAAAAA==.',
['肥龘']='肥龘:BAAALgAECgYJCAAAAA==.',
['背向']='背向天堂:BAAALgAECgIJAgAAAA==.',
['脚踝']='脚踝终结者:BAAALgAECgYJBwAAAA==.',
['至高']='至高领:BAAALgAECgcJDgAAAA==.',
['艾瑞']='艾瑞莉娅丶:BAAALgAECgYJBgAAAA==.',
['芝丗']='芝丗玉米:BAAALgADCgYJBgAAAA==.',
['芝士']='芝士聋人:BAABLgAFFH8NAAIGAAUJARo/BADNAQAGAAUJARo/BADNAQAAAA==.',
['芬必']='芬必德:BAAALgAECgEJAQAAAA==.',
['苍天']='苍天饶过谁:BAAALgADCgEJAQAAAA==.',
['英国']='英国大力士:BAACLgAFFH8GAAIPAAMJrBDEEwDaAAAPAAMJrBDEEwDaAAAuAAQKfxkAAg8ABwknGk8iAO8BAA8ABwknGk8iAO8BAAAA.',
['英维']='英维安娜:BAAALgAFFAQJBAABLgAFFAUJDQAFAC8WAA==.',
['茉諾']='茉諾瑞:BAAALgAECgEJAQAAAA==.',
['茨木']='茨木:BAAALgADCgQJBAAAAA==.',
['荣耀']='荣耀勋爵归来:BAAALgAECgIJAwAAAA==.',
['莫颂']='莫颂:BAAALgAECgIJAgAAAA==.',
['莲滢']='莲滢:BAAALgAECgcJBwAAAA==.',
['菈妮']='菈妮丨:BAACLgAFFH8HAAISAAQJ/gcDEAAnAQASAAQJ/gcDEAAnAQAuAAQKfxcAAhIACAn8GV4yAFkCABIACAn8GV4yAFkCAAAA.',
['萌萌']='萌萌哒芒果丶:BAAALgAECgIJAgAAAA==.',
['落樱']='落樱如雪:BAAALgAECgQJBAAAAA==.',
['葳蕤']='葳蕤赫谙:BAAALgAECgUJBQAAAA==.',
['蒂珐']='蒂珐:BAAALgAECgQJBAAAAA==.',
['蒙齐']='蒙齐路飞:BAAALgAECgYJBgABLgAFFAQJDAAKABkGAA==.',
['蓝瑟']='蓝瑟铁骑:BAAALgAFFAEJAgAAAA==.',
['蜜小']='蜜小宝:BAABLgAFFH8FAAIFAAMJUhHHKAD2AAAFAAMJUhHHKAD2AAAAAA==.',
['血线']='血线操盘手:BAABLgAECn8XAAMbAAgJVx8yBQAAAwAbAAgJVx8yBQAAAwAQAAEJdgjogAAxAAAAAA==.',
['血色']='血色天涯:BAAALgAECgYJEQAAAA==.',
['被迫']='被迫转岗:BAAALgAECgYJBgAAAA==.',
['西格']='西格玛战:BAAALgAECgEJAQAAAA==.西格玛术:BAAALgAECgEJAQAAAA==.',
['西炎']='西炎山大祭司:BAAALgAECgUJBwAAAA==.',
['訫随']='訫随风飘逝:BAAALgAECgQJBAAAAA==.',
['计都']='计都罗睺:BAAALgAECgUJBQAAAA==.',
['讲情']='讲情面:BAAALgADCgIJAgAAAA==.',
['诅咒']='诅咒之锤:BAAALgADCgEJAQAAAA==.',
['诸罪']='诸罪加身:BAAALgAECgEJAQAAAA==.',
['贞子']='贞子:BAAALgAECgUJBQAAAA==.',
['贪财']='贪财好色俗人:BAAALgAFFAIJAwAAAA==.',
['踏歌']='踏歌行:BAAALgAECgIJAgAAAA==.',
['边哭']='边哭边嗦粉:BAAALgAECgQJBAAAAA==.',
['近战']='近战我最强:BAAALgAECgIJAgAAAA==.',
['追忆']='追忆丶猎:BAAALgAECgEJAQAAAA==.',
['逼满']='逼满:BAAALgAECgEJAQAAAA==.',
['遇见']='遇见夏天:BAAALgAFFAIJAgAAAA==.',
['遗忘']='遗忘的桃花源:BAAALgAECgEJAQAAAA==.',
['遥知']='遥知不是雪:BAAALgAECgYJBgAAAA==.',
['酋长']='酋长的传令官:BAAALgAECgYJDAAAAA==.酋长的微笑:BAAALgAECgcJCAAAAA==.',
['醇鹿']='醇鹿人:BAABLgAECn8WAAIXAAYJ5hDkPABAAQAXAAYJ5hDkPABAAQAAAA==.',
['野性']='野性灬召唤:BAAALgAECgEJAgAAAA==.',
['鎏枫']='鎏枫:BAAALgAECgIJAgAAAA==.',
['镜花']='镜花缘:BAAALgAFFAQJAwAAAA==.',
['阳光']='阳光沐老歌:BAABLgAFFH8IAAMMAAQJYyHhBQBFAQAMAAMJHyPhBQBFAQANAAMJZhcZFQDzAAAAAA==.',
['阿晨']='阿晨:BAAALgAECgEJAQAAAA==.',
['阿纳']='阿纳贝尔卡多:BAACLgAFFH8KAAMCAAQJSiYsCADmAAABAAIJOyY9EQDoAAACAAIJWiYsCADmAAAuAAQKfxUAAwEACAnJJXMgAJYCAAEABgnqJXMgAJYCAAIAAgn/JPE1AN4AAAAA.',
['阿葵']='阿葵娅莉阿斯:BAAALgAFFAEJAQAAAA==.',
['陆道']='陆道风:BAAALgADCgUJDwAAAA==.',
['隔壁']='隔壁小圣:BAAALgAECgEJAQAAAA==.',
['难忘']='难忘遗殇:BAAALgAECgMJAwAAAA==.',
['雨遥']='雨遥:BAAALgAECgYJDgAAAA==.',
['雪碧']='雪碧的奶萨:BAAALgADCgUJBQAAAA==.',
['雷霆']='雷霆小帅:BAAALgADCgEJAQAAAA==.',
['非烟']='非烟飞血:BAAALgAECgEJAQAAAA==.',
['风光']='风光:BAAALgAECgkJDwABLgAFFAQJDAAKABkGAA==.',
['风舞']='风舞苍莲:BAACLgAFFH8GAAIJAAMJDhcOJwAWAQAJAAMJDhcOJwAWAQAuAAQKfxwAAgkABwmLIdYvALMCAAkABwmLIdYvALMCAAAA.',
['风雷']='风雷天下:BAAALgAECgQJCQABLgAECgYJDAAfAAAAAA==.',
['騎士']='騎士精魂:BAAALgAECgUJBQAAAA==.',
['魂体']='魂体双分:BAAALgAECgYJBgAAAA==.',
['鱼苗']='鱼苗:BAACLgAFFH8NAAIEAAUJiyWBAgCpAQAEAAUJiyWBAgCpAQAuAAQKfxYAAgQACAmTI6cDAB0DAAQACAmTI6cDAB0DAAAA.',
['鸭黄']='鸭黄豆角:BAAALgADCgUJBQAAAA==.',
['黑桐']='黑桐月:BAAALgAECgQJAgAAAA==.',
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
