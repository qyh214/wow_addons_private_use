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

local lookup = {'Warrior-Fury','DemonHunter-Havoc','Mage-Frost','Druid-Guardian','DemonHunter-Devourer','Druid-Restoration','Unknown-Unknown','Paladin-Retribution','Priest-Discipline','Priest-Holy','DeathKnight-Blood','Rogue-Subtlety','Monk-Mistweaver','Evoker-Augmentation','Evoker-Devastation','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Monk-Brewmaster','DeathKnight-Unholy','Warrior-Protection','Evoker-Preservation','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','Druid-Balance','Shaman-Restoration','Shaman-Elemental','Paladin-Holy','Shaman-Enhancement','Monk-Windwalker','Warrior-Arms',}
local provider = {region='CN',realm='索瑞森',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Allkill:BAAALgADCgIJAgAAAA==.',
Am='Amicus:BAAALgAFFAEJAQAAAA==.',
Be='Beasty:BAAALgAECgEJAgAAAA==.Bengbeng:BAAALgAECgcJEQAAAA==.',
Bl='Blacklotuso:BAABLgAFFH8GAAIBAAIJNAvJGgCdAAABAAIJNAvJGgCdAAAAAA==.',
Co='Cobabyco:BAAALgAECgIJAgAAAA==.',
Ct='Ctopfreedom:BAAALgADCgIJAgAAAA==.',
Cy='Cyrus:BAAALgAECgMJAwAAAA==.',
De='Demonhunters:BAABLgAFFH8FAAICAAMJ6RdBBQAJAQACAAMJ6RdBBQAJAQAAAA==.',
Di='Dinsprinfall:BAAALgAECgMJAwAAAA==.',
Do='Dorislols:BAAALgAECgcJBwAAAA==.',
Ec='Ecchi:BAAALgAECgMJAwAAAA==.',
El='Elfenlied:BAAALgAECgEJAQAAAA==.Elysee:BAABLgAECn8WAAIDAAYJHCCEHACKAQADAAYJHCCEHACKAQAAAA==.',
Er='Erichappyf:BAAALgAECgcJBgAAAA==.',
Es='Estrelia:BAABLgAFFH8HAAIEAAMJGwu+AwClAAAEAAMJGwu+AwClAAAAAA==.Estrella:BAAALgAECgcJBwAAAA==.',
Fe='Fefab:BAAALgAECgYJDgAAAA==.',
Gg='Ggkr:BAABLgAFFH8IAAIFAAUJpwqvDABtAQAFAAUJpwqvDABtAQAAAA==.',
Gh='Ghostface:BAAALgAECgEJAgAAAA==.',
Gi='Giants:BAAALgAFFAEJAwAAAA==.',
Ha='Halestorm:BAAALgAFFAEJAQAAAA==.Hamuvei:BAAALgAECgYJBgAAAA==.',
He='Hercule:BAAALgAECgMJAwAAAA==.',
Hf='Hfx:BAAALgAECgEJAQAAAA==.',
Iv='Ivy:BAAALgAECgEJAgAAAA==.',
Ku='Kuojmlv:BAAALgADCgEJAQAAAA==.',
Le='Leot:BAAALgAECgcJCAAAAA==.',
Li='Likkas:BAAALgAECgQJBwAAAA==.',
Ma='Magicchoi:BAAALgAECgQJAwAAAA==.Massage:BAABLgAECn8bAAIGAAgJ8RlSGAB0AgAGAAgJ8RlSGAB0AgAAAA==.',
Mi='Minamikotori:BAAALgADCgkJCQABLgAECgcJBwAHAAAAAA==.Ministrus:BAAALgADCgQJBAAAAA==.',
Mo='Mojo:BAAALgAECgcJEAAAAA==.',
Mu='Mustafa:BAAALgAECgYJBwAAAA==.',
Na='Nange:BAAALgADCgcJBwAAAA==.Nashty:BAAALgAECgEJAQAAAA==.',
Ni='Nightandyee:BAAALgAECgEJAQAAAA==.Nightandylao:BAAALgAECgcJDgAAAA==.',
No='Nottoday:BAAALgAECgUJDgAAAA==.Novel:BAAALgAECgYJCwAAAA==.',
Pa='Paradise:BAAALgADCgUJBQAAAA==.',
Pl='Play:BAAALgAECgEJAQAAAA==.Playerexwuzi:BAAALgAFFAIJAQAAAA==.',
Pu='Pucky:BAAALgAECgEJAQAAAA==.',
Ra='Rainkiss:BAAALgAECgYJDQAAAA==.',
Re='Retribution:BAAALgAECgcJBwAAAA==.',
Ro='Roselia:BAABLgAFFH8JAAIDAAQJtSF+DwCbAQADAAQJtSF+DwCbAQABLgAFFAYJFgAIAFMjAA==.',
Sa='Sarcasm:BAAALgAECgYJBwAAAA==.',
Sh='Shakes:BAAALgAECgIJAgAAAA==.Shugochara:BAAALgADCgcJDAABLgAECgcJBwAHAAAAAA==.',
Si='Silversniper:BAAALgAECgkJCQAAAA==.',
Sp='Spanisheye:BAAALgAECgMJAwAAAA==.',
Yk='Yks:BAAALgADCgYJBwAAAA==.',
Yo='Yourk:BAABLgAFFH8GAAMJAAIJiRFnEwCaAAAJAAIJiRFnEwCaAAAKAAEJ+wBUGAAwAAAAAA==.',
['一二']='一二三:BAAALgADCgEJAQAAAA==.',
['一拉']='一拉一个亮神:BAAALgADCgYJBgAAAA==.',
['一电']='一电你就笑:BAAALgAECgEJAQABLgAECgkJDgAHAAAAAA==.',
['一粒']='一粒王富贵:BAAALgAECgIJBQAAAA==.',
['一职']='一职业玩家一:BAAALgADCgYJBgAAAA==.',
['一魅']='一魅影一:BAAALgAECgIJBAAAAA==.',
['万物']='万物一口:BAAALgAFFAEJAQAAAA==.',
['三万']='三万种人生:BAAALgAECgEJAQAAAA==.',
['三层']='三层楼那么高:BAAALgAECgYJDwAAAA==.',
['不一']='不一样的火焰:BAAALgAECgYJCgAAAA==.',
['不会']='不会拉怪:BAAALgAECgQJBAAAAA==.',
['不似']='不似少年游:BAAALgAFFAUJAQAAAA==.',
['不太']='不太乖:BAAALgAECgQJBAAAAA==.',
['与一']='与一丶:BAAALgAECgcJBwAAAA==.',
['丛林']='丛林之王:BAAALgAECgQJBAAAAA==.',
['东姐']='东姐丶:BAAALgAECgEJAQAAAA==.',
['丞上']='丞上祈下:BAAALgAECgQJBwAAAA==.',
['丢你']='丢你家窗户:BAAALgAECgkJEAAAAA==.',
['丧飚']='丧飚:BAAALgAECgYJDAAAAA==.',
['丨一']='丨一巨霸一丨:BAAALgADCgYJBgAAAA==.',
['丨夜']='丨夜魅小妖丨:BAAALgADCgUJBwAAAA==.',
['丨巫']='丨巫毒丨娃娃:BAAALgAECggJDgAAAA==.',
['丨阿']='丨阿尔泰丨:BAABLgAFFH8GAAILAAMJphAnBgDeAAALAAMJphAnBgDeAAAAAA==.',
['丫大']='丫大:BAAALgAECgcJEwAAAA==.',
['丶小']='丶小布丁丶:BAAALgAECgcJBwAAAA==.',
['丶焦']='丶焦糖玛奇朵:BAAALgAECgEJAQAAAA==.',
['丶萌']='丶萌萌哒:BAAALgAECgkJCQAAAA==.',
['丸子']='丸子喵喵拳:BAAALgAECgMJAwAAAA==.',
['丹阳']='丹阳法爷:BAAALgAFFAIJAgAAAA==.',
['么么']='么么冻:BAABLgAECn8UAAIDAAcJoxQsiADBAQADAAcJoxQsiADBAQAAAA==.么么猪:BAAALgAECgEJAQAAAA==.',
['九粒']='九粒蛋:BAAALgAECgYJEAABLgAFFAQJCQAMALwTAA==.',
['书院']='书院大师姐:BAAALgAFFAEJAQAAAA==.',
['乱了']='乱了浮生:BAAALgAECgYJBwAAAA==.',
['二点']='二点五条悟:BAAALgAECgYJCQAAAA==.',
['二费']='二费射箭:BAAALgAECgYJCQAAAA==.',
['亡靈']='亡靈殺手:BAAALgAECgQJBAAAAA==.',
['亡魂']='亡魂咏叹:BAAALgAECgUJCAAAAA==.',
['亦真']='亦真丶亦幻:BAAALgAECgEJAQAAAA==.',
['以德']='以德一服人:BAAALgADCgIJAgAAAA==.',
['伊人']='伊人風度翩翩:BAAALgAECgQJBAAAAA==.',
['伊立']='伊立丹怒火:BAAALgAECgYJBwAAAA==.',
['传说']='传说中的忘川:BAAALgAFFAEJAQAAAA==.',
['伯符']='伯符:BAAALgAECgEJAQAAAA==.',
['何似']='何似人间:BAAALgAECgYJCgAAAA==.',
['你妹']='你妹与我同在:BAABLgAFFH8KAAINAAUJMBa2AgCJAQANAAUJMBa2AgCJAQAAAA==.',
['你我']='你我的回忆:BAACLgAFFH8MAAIOAAYJlBonBADRAQAOAAYJlBonBADRAQAuAAQKfxwAAw4ACAnzJDgGAB0DAA4ACAnzJDgGAB0DAA8ABglwEtsbAFEBAAAA.',
['佳丞']='佳丞:BAAALgAECgEJAgAAAA==.',
['信手']='信手斬龍:BAAALgAECgcJBwAAAA==.',
['偷鸡']='偷鸡摸狗:BAAALgAECgYJBgAAAA==.',
['光的']='光的湮灭:BAAALgAFFAEJAQAAAA==.',
['兔总']='兔总说你不行:BAAALgAECgIJAgAAAA==.',
['八宝']='八宝山:BAABLgAECn8bAAIBAAcJSxZ+CgCWAQABAAcJSxZ+CgCWAQAAAA==.',
['关你']='关你什么柿:BAAALgADCgYJBgAAAA==.',
['兹拉']='兹拉坦:BAAALgAECgIJAgAAAA==.',
['冰箱']='冰箱在厨房里:BAAALgADCgEJAQAAAA==.',
['冰风']='冰风冰炎:BAAALgAECgQJBQAAAA==.冰风火焰:BAAALgAECgEJAQAAAA==.',
['冲锋']='冲锋队长达兹:BAAALgAECgUJBwAAAA==.',
['冷紫']='冷紫馨:BAAALgAECgMJAwAAAA==.',
['刀鋒']='刀鋒天使:BAAALgADCgcJBwAAAA==.',
['刘华']='刘华强:BAAALgAECgEJAQAAAA==.',
['别吃']='别吃了别吃了:BAAALgAECgEJAQAAAA==.',
['剑宗']='剑宗正宗:BAAALgADCgcJDAAAAA==.',
['劍舞']='劍舞輕歌丶:BAAALgAECgcJBwAAAA==.',
['北极']='北极点:BAAALgAECgQJBwAAAA==.',
['千早']='千早爱音:BAACLgAFFH8MAAINAAQJIyZFAwDEAQANAAQJIyZFAwDEAQAuAAQKfxYAAg0ACAnCJAgEADEDAA0ACAnCJAgEADEDAAAA.',
['千本']='千本丸子:BAAALgADCgEJAQABLgAECgEJAgAHAAAAAA==.',
['半夏']='半夏之光:BAAALgAECgIJAgAAAA==.半夏夜光:BAAALgADCgEJAQAAAA==.半夏星光:BAAALgAECgEJAQAAAA==.',
['华删']='华删派人正飞:BAAALgAECgMJAwAAAA==.',
['卡尔']='卡尔萨斯丶曲:BAAALgAECgYJBgAAAA==.',
['厶谮']='厶谮:BAACLgAFFH8GAAIQAAQJ5AgrFwA3AQAQAAQJ5AgrFwA3AQAuAAQKfygAAxAACQneIO4TAN0CABAACQneIO4TAN0CABEAAQkAAGVjAEgAAAAA.',
['变态']='变态辣:BAAALgADCgIJAgAAAA==.',
['只為']='只為輪迴成魔:BAAALgAECgMJAwAAAA==.',
['可乐']='可乐要加冰灬:BAAALgAFFAIJAwAAAA==.',
['可爱']='可爱小板鸭:BAAALgAFFAMJBAAAAA==.可爱小羊毛:BAAALgAFFAIJAgAAAA==.',
['司澜']='司澜:BAAALgAFFAMJBAABLgAFFAUJBQAFAN8aAA==.',
['吃你']='吃你煮的鱼:BAAALgAECggJDgAAAA==.',
['名字']='名字取什么好:BAAALgAECgEJAQAAAA==.名字战无不胜:BAAALgAECgYJDAAAAA==.',
['后海']='后海大鲨鱼:BAAALgAECgQJBQAAAA==.',
['君临']='君临魔兽:BAAALgAECgEJAQAAAA==.',
['吾射']='吾射不亦准乎:BAAALgAECgYJBgAAAA==.',
['吾王']='吾王的呆毛:BAAALgAECgMJBQAAAA==.',
['呆毛']='呆毛王:BAAALgAECgYJDwAAAA==.',
['呜咪']='呜咪:BAAALgAECgYJDwAAAA==.',
['咕咏']='咕咏啫:BAAALgAECgUJCAAAAA==.',
['咸鱼']='咸鱼酱:BAABLgAECn8bAAQQAAcJCx1YRgD4AQAQAAYJCx1YRgD4AQARAAIJPQQ+WABmAAASAAEJJwNNNwAlAAAAAA==.',
['哈基']='哈基米大王:BAAALgAECgQJDAAAAA==.',
['哼奇']='哼奇奇:BAAALgAECgIJAgAAAA==.',
['唐三']='唐三彩:BAAALgAECgQJCQAAAA==.',
['啊修']='啊修罗王:BAAALgAECgMJAwAAAA==.',
['善良']='善良的河道蟹:BAABLgAFFH8FAAIIAAMJqxfuEQC4AAAIAAMJqxfuEQC4AAAAAA==.',
['嗜血']='嗜血狂牧:BAAALgAECgkJCQABLgAFFAcJBgAOADUaAA==.',
['嘎佳']='嘎佳熙:BAAALgAECgYJDgAAAA==.',
['嘘别']='嘘别说话:BAAALgAFFAUJAgAAAA==.',
['回忆']='回忆的叶子夏:BAAALgADCgcJBwAAAA==.',
['回想']='回想:BAAALgAECgMJBwAAAA==.',
['团团']='团团鸡哔你:BAAALgADCgEJAQAAAA==.',
['国新']='国新:BAAALgAFFAEJAQAAAA==.',
['圣光']='圣光土间埋:BAAALgADCgUJBgAAAA==.',
['圣曲']='圣曲:BAAALgAECgMJCAAAAA==.',
['地铁']='地铁后视镜:BAAALgAFFAMJBAAAAA==.',
['坦德']='坦德利安:BAAALgAECgkJDQAAAA==.',
['夏青']='夏青橙:BAAALgAECgYJDQAAAA==.',
['夜魅']='夜魅丶小妖:BAAALgADCgMJAwAAAA==.夜魅小妖丶九:BAAALgADCgUJBQAAAA==.',
['大呆']='大呆球:BAABLgAFFH8GAAIQAAMJRSWsFwDdAAAQAAMJRSWsFwDdAAAAAA==.',
['大家']='大家懂德:BAAALgAFFAEJAQAAAA==.',
['大猫']='大猫在冰箱里:BAAALgAECgYJCwAAAA==.',
['大聪']='大聪明贝拉捏:BAAALgAFFAEJAQAAAA==.',
['大菠']='大菠萝丶:BAAALgAECgEJAQAAAA==.',
['大阿']='大阿福:BAAALgAECgMJBQAAAA==.',
['天动']='天动万象:BAACLgAFFH8HAAMNAAMJIQNUDwCmAAANAAMJIQNUDwCmAAATAAIJSQKpIQBoAAAuAAQKfxYAAxMABwnMDmI9AFEBABMABgmZEWI9AFEBAA0AAgmxASxrACwAAAAA.',
['天生']='天生奥特曼:BAAALgAECgEJAQAAAA==.天生肉盾丶:BAAALgAFFAIJBAAAAA==.',
['天阳']='天阳烈愿:BAAALgAECgIJAgAAAA==.',
['天隙']='天隙流光:BAAALgAECgIJAgAAAA==.',
['奇罗']='奇罗:BAAALgAECgQJBAAAAA==.',
['奈美']='奈美西斯:BAAALgAECgYJBgAAAA==.',
['奈萨']='奈萨:BAAALgADCgEJAQAAAA==.',
['奶牛']='奶牛小子:BAAALgAFFAEJAQAAAA==.',
['她还']='她还遗憾吧:BAABLgAFFH8GAAIFAAMJ3gsUGgCaAAAFAAMJ3gsUGgCaAAAAAA==.',
['好像']='好像很好吃:BAAALgAECgYJBgAAAA==.',
['如故']='如故丶:BAABLgAECn8UAAMUAAkJjyAJDwAkAwAUAAkJjyAJDwAkAwALAAEJ6yN1PQBcAAAAAA==.',
['妖精']='妖精的裁决:BAAALgAECgEJAQAAAA==.',
['娜塔']='娜塔莉塞林:BAAALgAECggJDgAAAA==.',
['季末']='季末很寂寞:BAAALgAECgEJAQAAAA==.',
['孫尛']='孫尛熊:BAACLgAFFH8NAAIVAAQJXxBgAwASAQAVAAQJXxBgAwASAQAuAAQKfxgAAxUACAmpGcEKAGUCABUACAmpGcEKAGUCAAEAAQkAAPilADkAAAAA.',
['安东']='安东奎因:BAAALgADCgYJCQAAAA==.',
['完美']='完美战战:BAAALgAECgMJAwAAAA==.完美骑骑:BAAALgAECgYJDAAAAA==.',
['宝山']='宝山大叔:BAABLgAECn8VAAIDAAYJPhaUOAASAQADAAYJPhaUOAASAQAAAA==.',
['宝贝']='宝贝小红手:BAAALgAECgQJBAAAAA==.',
['小兔']='小兔几丷:BAAALgAECgYJBgAAAA==.小兔花灯:BAABLgAFFH8GAAMWAAMJ/RmPDQADAQAWAAMJ/RmPDQADAQAPAAEJSwvnCQBTAAAAAA==.',
['小号']='小号三号:BAAALgAECgcJCwAAAA==.',
['小呆']='小呆球:BAAALgADCgYJBwAAAA==.',
['小咕']='小咕咕丶:BAAALgAECgYJBwAAAA==.',
['小園']='小園:BAAALgAECgUJBQAAAA==.',
['小小']='小小帅帅司马:BAAALgAECgUJBQAAAA==.小小灰太郎:BAAALgAFFAEJAQAAAA==.小小赵:BAAALgAECgEJAQABLgAFFAcJBQAUAPEgAA==.',
['小德']='小德术爷战复:BAAALgAECgEJAQABLgAFFAYJFQALAE4QAA==.',
['小心']='小心爱上妮:BAABLgAECn8XAAIXAAkJzh+5AQC9AgAXAAkJzh+5AQC9AgAAAA==.',
['小怪']='小怪也要温暖:BAAALgAECgYJAwAAAA==.',
['小手']='小手有点冰:BAAALgAECgMJAwAAAA==.',
['小晓']='小晓乖:BAAALgADCgMJAwAAAA==.',
['小熊']='小熊喵喵:BAAALgAFFAMJBAAAAA==.',
['小爆']='小爆爆:BAAALgAECgUJCAAAAA==.',
['小牛']='小牛陶:BAABLgAFFH8JAAIVAAQJtAgbCADaAAAVAAQJtAgbCADaAAAAAA==.',
['小狮']='小狮半藏:BAAALgADCgIJAgAAAA==.',
['小缅']='小缅因:BAAALgAECgYJEwAAAA==.',
['小雪']='小雪儿:BAAALgAECgYJBgAAAA==.',
['小風']='小風波:BAAALgAECgcJBwAAAA==.',
['少帅']='少帅:BAAALgAECgYJBgAAAA==.',
['少昊']='少昊:BAAALgAECgcJEgAAAA==.',
['尘心']='尘心丶逝火:BAAALgAECgYJCQAAAA==.尘心似火:BAAALgAFFAEJAwAAAA==.',
['就你']='就你话多:BAABLgAFFH8GAAIUAAUJmBMeCABMAQAUAAUJmBMeCABMAQAAAA==.',
['就是']='就是喝芬达:BAAALgAFFAQJAwAAAA==.',
['就爱']='就爱吃汉堡:BAAALgAECggJEwAAAA==.',
['尼克']='尼克:BAAALgAECgYJCwAAAA==.',
['尼古']='尼古拉斯赵肆:BAABLgAECn8cAAMBAAgJERQaPgCsAQABAAUJUxwaPgCsAQAVAAgJ6AlCHQBcAQAAAA==.',
['嵐渃']='嵐渃玥:BAAALgAECgQJBAAAAA==.',
['嶌葵']='嶌葵灬:BAAALgADCgEJAQAAAA==.',
['巨人']='巨人术:BAAALgAECgYJDAAAAA==.',
['巨馍']='巨馍洒漫:BAAALgAECgEJAQAAAA==.',
['巴斯']='巴斯光年:BAAALgADCgEJAQAAAA==.',
['布莱']='布莱克麻吉:BAAALgAFFAEJAQAAAA==.布莱恩:BAAALgADCgQJBAAAAA==.',
['希希']='希希小可爱:BAAALgADCgEJAQAAAA==.',
['希诺']='希诺宁:BAABLgAECn8YAAITAAcJQxxPIgDvAQATAAcJQxxPIgDvAQAAAA==.',
['帕瓦']='帕瓦林科:BAAALgAECgQJBgAAAA==.',
['带带']='带带恶魔术:BAAALgAFFAIJAgABLgAFFAYJAwAHAAAAAA==.',
['常山']='常山之蛇:BAAALgAECgEJAQAAAA==.',
['幻梦']='幻梦夕色:BAAALgAFFAIJAwABLgAFFAUJBQAUAFUTAA==.',
['幽小']='幽小邪:BAACLgAFFH8GAAIQAAMJPiJIGAAuAQAQAAMJPiJIGAAuAQAuAAQKfxcAAxAABwmBIzUpAGwCABAABgmCIzUpAGwCABEAAgm+HOdCAKkAAAAA.',
['开心']='开心小拳手:BAAALgAECgIJAgAAAA==.',
['张大']='张大炮:BAAALgAECgYJBgABLgAFFAcJDQAVAM4ZAA==.',
['影戰']='影戰丶:BAAALgADCgEJAQAAAA==.',
['影瞳']='影瞳:BAAALgADCgYJBgAAAA==.',
['往事']='往事隨風丶:BAAALgAFFAEJAQABLgAFFAIJAwAHAAAAAA==.',
['徐国']='徐国斗:BAAALgAECgcJCQABLgAFFAMJCAAQAE0WAA==.',
['德天']='德天使:BAAALgADCgEJAQAAAA==.',
['德隆']='德隆:BAAALgAECgMJBAAAAA==.',
['志丨']='志丨明:BAAALgAECgUJBQAAAA==.',
['恶魔']='恶魔寿司:BAAALgAECgcJBwAAAA==.恶魔的无奈:BAAALgADCgUJCgAAAA==.',
['悲催']='悲催的结尾:BAAALgAECgEJAQAAAA==.悲催莱纳:BAABLgAECn8ZAAMWAAgJYB4dBwDOAgAWAAgJYB4dBwDOAgAOAAMJ8xJKFwDCAAAAAA==.',
['惜阳']='惜阳:BAAALgAECgQJCQAAAA==.',
['惩戒']='惩戒魅魔:BAABLgAFFH8GAAMQAAMJYQh3OwCcAAAQAAIJkwt3OwCcAAARAAEJ/QGGGgBEAAAAAA==.',
['惩罚']='惩罚队友浩劫:BAAALgADCgYJBgAAAA==.',
['想要']='想要无敌:BAAALgAECgcJDQAAAA==.',
['愤怒']='愤怒的青椒:BAABLgAFFH8GAAMFAAQJ9QC6FgCyAAAFAAQJ9QC6FgCyAAACAAEJtAAeEAA9AAAAAA==.',
['我不']='我不是增辉:BAAALgAECgEJAgAAAA==.我不是抹茶丶:BAAALgADCgMJAQAAAA==.',
['我即']='我即丨元素:BAAALgADCgEJAQAAAA==.',
['我只']='我只是个演员:BAAALgAECgYJBwAAAA==.',
['我喝']='我喝健力宝:BAABLgAFFH8FAAIUAAQJ8RTbEAAEAQAUAAQJ8RTbEAAEAQAAAA==.',
['我欲']='我欲乘风:BAAALgAFFAEJAgAAAA==.',
['我滚']='我滚了:BAAALgAECgYJBgAAAA==.',
['我爱']='我爱喝雪碧:BAAALgAFFAQJAgAAAA==.',
['我的']='我的小鸭鸭:BAAALgAECgEJAQAAAA==.我的风:BAAALgAECgEJAgAAAA==.',
['戦不']='戦不休:BAAALgAECgcJDQAAAA==.',
['戦丨']='戦丨不休:BAAALgADCgkJCQAAAA==.',
['抗住']='抗住:BAAALgAECgYJCgAAAA==.',
['抹茶']='抹茶丶:BAAALgAECgIJAgAAAA==.',
['抽抽']='抽抽丶:BAAALgAECgEJAQAAAA==.',
['拉布']='拉布布风行者:BAAALgADCgEJAQAAAA==.',
['拖雷']='拖雷:BAAALgAECgYJBgAAAA==.',
['振鳞']='振鳞奋翼:BAAALgADCgYJBgAAAA==.',
['揍敌']='揍敌客:BAAALgAECgMJAwAAAA==.',
['攀高']='攀高几重楼:BAAALgAFFAQJBAAAAA==.',
['故人']='故人今在否:BAAALgAECgYJCwAAAA==.',
['散场']='散场预演:BAABLgAFFH8HAAQYAAMJACN5GADLAAAYAAIJ/iJ5GADLAAAXAAIJeyNNHgBlAAAZAAEJVBOPBgBVAAAAAA==.',
['无休']='无休之锋:BAAALgAECgYJBwAAAA==.',
['无双']='无双倾城:BAAALgADCgQJBAAAAA==.',
['无常']='无常风烛:BAAALgAECgUJCAAAAA==.',
['无敌']='无敌马库斯:BAAALgAECggJDgAAAA==.',
['无邪']='无邪:BAAALgAECgYJCQAAAA==.',
['日日']='日日下:BAAALgAECgUJBQAAAA==.',
['时间']='时间要加速了:BAAALgAECgMJAwAAAA==.',
['昆仑']='昆仑二世祖:BAAALgAECgEJAQAAAA==.昆仑的回忆:BAAALgAFFAQJBAAAAA==.',
['昆沙']='昆沙门天:BAAALgAECgIJAgAAAA==.',
['明镜']='明镜亦非苔丶:BAAALgAFFAIJAwAAAA==.',
['星夜']='星夜很行:BAAALgAECgcJBwAAAA==.星夜红杏出墙:BAAALgAECgcJBwAAAA==.星夜靡靡饼:BAAALgAECgcJBwAAAA==.',
['晓山']='晓山瑞希:BAAALgAFFAIJAgAAAA==.',
['晚云']='晚云:BAAALgADCgMJAwAAAA==.',
['暖暖']='暖暖小棉袄:BAAALgAECgYJBgAAAA==.',
['暴小']='暴小躁:BAAALgAECgYJCQAAAA==.',
['曙光']='曙光之曜:BAAALgADCgUJBgAAAA==.',
['曲水']='曲水兰亭:BAAALgAECgEJAQAAAA==.',
['最後']='最後希望:BAAALgAECgEJAQAAAA==.',
['月殒']='月殒:BAAALgADCgUJBQAAAA==.',
['有个']='有个萨满:BAAALgAECgUJCgAAAA==.',
['有翼']='有翼之暗:BAAALgAECgEJAgAAAA==.',
['有龙']='有龙乃大:BAAALgAECgUJBQAAAA==.',
['望仙']='望仙园园长:BAABLgAFFH8FAAIQAAMJlxeAIQD+AAAQAAMJlxeAIQD+AAAAAA==.',
['木耳']='木耳杀手:BAAALgAECgcJBwAAAA==.',
['未来']='未来牧场:BAACLgAFFH8KAAIKAAQJXhZXAwBgAQAKAAQJXhZXAwBgAQAuAAQKfxoAAgoACAkCHmgLAJoCAAoACAkCHmgLAJoCAAAA.',
['末路']='末路红颜:BAABLgAECn8aAAIaAAcJQRXxKAC3AQAaAAcJQRXxKAC3AQAAAA==.',
['术学']='术学家:BAAALgAECgEJAQAAAA==.',
['杀生']='杀生院:BAAALgAECgMJAwAAAA==.',
['杂修']='杂修:BAAALgAFFAQJBAAAAA==.',
['李乐']='李乐乐哦:BAAALgAECgcJBwAAAA==.',
['杨涬']='杨涬茹丶:BAAALgAECgUJBgAAAA==.',
['松隆']='松隆子:BAAALgAFFAQJBAAAAA==.',
['板凳']='板凳腿:BAAALgADCgEJAgAAAA==.',
['枪王']='枪王祁同伟:BAAALgAECgMJAwAAAA==.',
['枫影']='枫影神伤:BAAALgAECgQJCwAAAA==.',
['枯叶']='枯叶寒冰皮:BAAALgAECgUJBQAAAA==.',
['桃桃']='桃桃丸丸子:BAAALgAECgQJBQAAAA==.',
['桃谷']='桃谷绘里香:BAAALgADCgEJAQAAAA==.',
['桓猪']='桓猪哥哥曾棒:BAAALgAFFAEJAQAAAA==.',
['梟墨']='梟墨:BAABLgAFFH8LAAIUAAMJww82KwDuAAAUAAMJww82KwDuAAAAAA==.',
['梦丶']='梦丶火:BAAALgADCgUJBQAAAA==.',
['梦泽']='梦泽寻鹿:BAAALgAFFAIJAwABLgAFFAIJBgAOAEQGAA==.',
['棒棒']='棒棒棠:BAAALgAECgUJCgAAAA==.',
['楠瓜']='楠瓜小恶魔:BAAALgAECgEJAQAAAA==.',
['極樂']='極樂淨土:BAAALgAECgEJAQAAAA==.',
['楼上']='楼上老王:BAAALgADCgEJAQAAAA==.',
['榴莲']='榴莲糖:BAAALgAFFAIJAgAAAA==.',
['槟榔']='槟榔没办法:BAAALgADCgYJBgAAAA==.槟榔真扎嘴:BAAALgAECgYJBAAAAA==.',
['樂樂']='樂樂味丶猫:BAAALgAFFAEJAQAAAA==.',
['橘子']='橘子味的猫:BAAALgADCgIJAgAAAA==.',
['橙月']='橙月霜刃:BAAALgAECgEJAgAAAA==.',
['欧蕾']='欧蕾莉亚:BAAALgADCgMJAwAAAA==.',
['正宗']='正宗百搭:BAAALgADCgEJAQAAAA==.',
['武力']='武力至上:BAAALgAECgQJBAAAAA==.',
['死亡']='死亡仔:BAAALgAECgYJBgAAAA==.',
['死的']='死的很冤:BAAALgAECgYJBgAAAA==.',
['殘寺']='殘寺派丶曲:BAAALgAECgYJBgAAAA==.',
['毒奶']='毒奶骑:BAAALgADCgcJBwAAAA==.',
['毒鼠']='毒鼠仔:BAAALgAECgYJBgAAAA==.',
['比格']='比格凯特:BAAALgAFFAEJAQAAAA==.比格堕拉公:BAAALgAECgYJCQAAAA==.',
['永远']='永远的楠瓜:BAAALgAECgIJAgAAAA==.',
['汏帥']='汏帥戨:BAAALgAECgEJAQAAAA==.',
['沁血']='沁血之霊:BAABLgAFFH8HAAMbAAMJRyQ6CABEAQAbAAMJRyQ6CABEAQAcAAEJFxG6EABTAAAAAA==.',
['沉卝']='沉卝香:BAAALgADCgkJCQAAAA==.',
['沐雨']='沐雨橙风暗月:BAAALgADCgUJBQAAAA==.',
['沙条']='沙条绫香丶:BAABLgAFFH8FAAIFAAIJgiE8IQDHAAAFAAIJgiE8IQDHAAAAAA==.',
['没有']='没有你的夏天:BAAALgAECgEJAQAAAA==.',
['没牙']='没牙的小老虎:BAAALgAECgQJBQAAAA==.',
['法力']='法力无边:BAAALgAECgEJAQAAAA==.',
['法师']='法师狗都不玩:BAAALgAECgEJAQAAAA==.',
['波若']='波若糖守座:BAAALgAECgcJBwAAAA==.',
['泪魇']='泪魇如花:BAAALgAECgYJBgAAAA==.',
['泰澜']='泰澜德丶怒风:BAAALgAECgYJDgAAAA==.',
['流云']='流云逝尽之空:BAAALgAECgkJCQAAAA==.',
['海格']='海格力斯灬:BAAALgAECgQJBgAAAA==.',
['涛歌']='涛歌哥:BAAALgADCgMJAwAAAA==.',
['涵封']='涵封:BAAALgAECgQJBwAAAA==.',
['淋雨']='淋雨心念:BAAALgAECgQJCwAAAA==.',
['淡淡']='淡淡嬷嬷茶:BAAALgADCgkJDwAAAA==.淡淡慕晚:BAAALgAECgMJAwAAAA==.',
['清清']='清清宝贝:BAAALgAECgkJCQAAAA==.',
['清祠']='清祠:BAAALgAECgYJDAAAAA==.',
['清雨']='清雨柚子茶:BAAALgAECgMJAwAAAA==.',
['清风']='清风灬飞雪:BAAALgAECgEJAgAAAA==.',
['渣渣']='渣渣牧:BAAALgAECgYJBwAAAA==.',
['潇洒']='潇洒苦茶子:BAAALgADCgYJBQAAAA==.',
['潮霸']='潮霸:BAAALgAFFAQJBAAAAA==.',
['潴潴']='潴潴丨杰:BAAALgADCgkJCQAAAA==.潴潴灬杰:BAAALgAECggJDgAAAA==.',
['火儿']='火儿:BAAALgADCgQJBAAAAA==.',
['火土']='火土风暴:BAAALgAECgEJAQAAAA==.',
['火眼']='火眼瞎:BAAALgADCgUJBQAAAA==.',
['火车']='火车后视镜:BAAALgAECggJDgABLgAFFAQJCAAFAJMQAA==.',
['灬喔']='灬喔喔奶糖灬:BAACLgAFFH8HAAIdAAQJdQ6RDwDgAAAdAAQJdQ6RDwDgAAAuAAQKfxgAAx0ABwnDHOskAP0BAB0ABwnDHOskAP0BAAgAAQmTBglPASwAAAAA.',
['灬大']='灬大鱼:BAAALgADCgcJBwAAAA==.',
['灭世']='灭世鬼鬼:BAAALgAECgQJBQAAAA==.',
['灭团']='灭团小骑士:BAAALgAECgMJAwAAAA==.',
['灵魂']='灵魂狂徒:BAABLgAECn8jAAMcAAgJHR+DAwAlAgAcAAgJHR+DAwAlAgAeAAEJcw+ELAA0AAAAAA==.',
['灼眼']='灼眼的夏娜酱:BAAALgAECgQJDAAAAA==.',
['熊喵']='熊喵星人:BAAALgAFFAEJAQAAAA==.',
['爬爬']='爬爬怪:BAAALgADCgEJAQAAAA==.',
['爱困']='爱困告:BAAALgAFFAIJAwAAAA==.',
['牛大']='牛大发:BAAALgAECgIJAgAAAA==.',
['牛岛']='牛岛若利:BAAALgAFFAIJAwAAAA==.',
['牛油']='牛油果:BAAALgADCgYJBgAAAA==.',
['牛肉']='牛肉饼:BAAALgAECgMJAgAAAA==.',
['牛花']='牛花:BAAALgAFFAEJAQAAAA==.',
['牛頭']='牛頭热:BAAALgAECgQJBgAAAA==.',
['牧神']='牧神小潘潘:BAAALgAFFAIJAwAAAA==.',
['狂煞']='狂煞夺魂:BAAALgADCgUJBQAAAA==.',
['狐粮']='狐粮狐饮:BAAALgAECgcJDwAAAA==.',
['狮子']='狮子头:BAABLgAFFH8FAAITAAMJwhOpDgCiAAATAAMJwhOpDgCiAAAAAA==.',
['猛挥']='猛挥吹叫脸迎:BAAALgAECgQJBwAAAA==.',
['猪闷']='猪闷儿丶:BAAALgAECgYJDgAAAA==.',
['猫丸']='猫丸:BAAALgAECgcJDgAAAA==.',
['猫了']='猫了个喵:BAAALgADCgYJBgAAAA==.',
['猫猫']='猫猫吃不辣:BAAALgADCgEJAQAAAA==.猫猫熊小钰:BAAALgAECgEJAQAAAA==.',
['玛琪']='玛琪朶:BAABLgAECn8aAAIIAAcJWCFnIQClAgAIAAcJWCFnIQClAgAAAA==.',
['琦玉']='琦玉老师丶:BAAALgADCgQJBAAAAA==.',
['瑟里']='瑟里夫丶耀鬃:BAAALgAFFAEJAQAAAA==.瑟里夫丶黑蹄:BAABLgAECn8VAAITAAYJ2xQpNwBvAQATAAYJ2xQpNwBvAQAAAA==.',
['瓜皮']='瓜皮惩戒骑:BAAALgAFFAIJAwAAAA==.',
['甜甜']='甜甜小学:BAAALgAECgMJAwABLgAFFAMJBgADAHAHAA==.',
['生杀']='生杀予夺:BAABLgAECn8XAAIMAAcJBhWmHQARAgAMAAcJBhWmHQARAgAAAA==.',
['生涯']='生涯现役:BAAALgAECgYJBwAAAA==.',
['电波']='电波发射站长:BAAALgAECgIJBQAAAA==.',
['疯狂']='疯狂输出:BAAALgAECgEJAgAAAA==.',
['疾咒']='疾咒冰法丶:BAAALgAFFAQJBAAAAA==.',
['白奶']='白奶泡芙:BAAALgAECgYJBgAAAA==.',
['白衣']='白衣卿相三变:BAAALgAECgcJDQAAAA==.',
['白馒']='白馒头:BAAALgAECgMJAwAAAA==.',
['皮的']='皮的不行:BAAALgAFFAEJAQAAAA==.',
['盲人']='盲人狙击手:BAAALgAECgIJAgAAAA==.',
['看似']='看似奈何:BAAALgAECgMJAwAAAA==.',
['石矶']='石矶娘娘:BAAALgAECgEJAQAAAA==.',
['碧空']='碧空之歌:BAABLgAECn8hAAMQAAcJ+xYuEgCfAQAQAAYJ+xYuEgCfAQARAAIJtAwjSwCMAAAAAA==.',
['社日']='社日:BAAALgAECgQJBAAAAA==.',
['神奇']='神奇的阿哥:BAAALgAECgEJAQAAAA==.',
['神秘']='神秘战神:BAAALgAECgkJBgAAAA==.',
['离岛']='离岛奏:BAACLgAFFH8JAAIMAAQJvBMeCABmAQAMAAQJvBMeCABmAQAuAAQKfxUAAgwABwnYHAgYAEgCAAwABwnYHAgYAEgCAAAA.',
['秀儿']='秀儿:BAAALgAECgYJCQAAAA==.',
['秋丶']='秋丶秋:BAAALgAECgkJCgAAAA==.',
['秋刀']='秋刀鱼骨头:BAAALgAFFAMJAwAAAA==.',
['科里']='科里斯汀:BAAALgAECgYJCQAAAA==.',
['秘法']='秘法正宗:BAAALgADCgMJAwAAAA==.',
['稀饭']='稀饭酱丶:BAAALgAECgEJAQAAAA==.',
['空之']='空之眺望者:BAAALgADCgUJBQAAAA==.',
['穿云']='穿云挽风飒飒:BAAALgAECgkJBQAAAA==.',
['竹影']='竹影清风:BAABLgAECn8aAAMNAAcJjxuXFQAZAgANAAcJjxuXFQAZAgAfAAMJQxNFVADAAAAAAA==.',
['第三']='第三稳限:BAAALgAECgkJBwAAAA==.',
['筱枫']='筱枫小天:BAABLgAFFH8HAAMUAAYJDBH4BACyAQAUAAUJDBH4BACyAQALAAEJAADjGwAqAAAAAA==.',
['筱筱']='筱筱娉婷:BAAALgAECgMJBAAAAA==.',
['米口']='米口:BAAALgAECgYJCwAAAA==.',
['糖囡']='糖囡囡:BAABLgAECn8UAAIXAAcJwxdjMQDqAQAXAAcJwxdjMQDqAQAAAA==.',
['糖糖']='糖糖果果:BAAALgAECgQJBQAAAA==.',
['糖门']='糖门大师兄:BAAALgAECgMJAwAAAA==.',
['红星']='红星闪耀少年:BAAALgADCgQJBAAAAA==.',
['红色']='红色体育生:BAAALgAECgUJCAAAAA==.',
['红莲']='红莲染尽发絲:BAAALgAECgMJAwAAAA==.红莲染尽髪絲:BAAALgAFFAMJAwAAAA==.',
['纯情']='纯情小熊:BAAALgAFFAEJAQAAAA==.',
['绝对']='绝对的力量:BAAALgAECgYJCQAAAA==.',
['绝望']='绝望吖:BAAALgAECgIJAgAAAA==.',
['绫濑']='绫濑小天使丶:BAAALgAECgYJCwABLgAECgkJCQAHAAAAAA==.',
['罗斯']='罗斯福满多:BAAALgADCgIJAgAAAA==.',
['美国']='美国大坏蛋灬:BAAALgAECgcJDAAAAA==.',
['美酒']='美酒肥肉:BAAALgADCgIJAgAAAA==.',
['羽果']='羽果:BAAALgADCgcJBwAAAA==.',
['老二']='老二:BAAALgAECgEJAQAAAA==.',
['老年']='老年区一号位:BAAALgAECgkJDwAAAA==.',
['老白']='老白兔:BAAALgADCgIJAgAAAA==.',
['聖乳']='聖乳奶咖:BAAALgAECgEJAQAAAA==.',
['脚滑']='脚滑狐狸:BAAALgAECgYJDQAAAA==.',
['腹膜']='腹膜炎三联征:BAAALgAFFAYJAwAAAA==.',
['臣妾']='臣妾丨坐不到:BAAALgAECgcJBwABLgAFFAgJAQAHAAAAAA==.',
['臭爷']='臭爷丶:BAAALgAFFAEJAQAAAA==.',
['艾尔']='艾尔之光:BAAALgAECgUJBwAAAA==.',
['芒椰']='芒椰灬小丸子:BAAALgAECgEJAQAAAA==.',
['花月']='花月:BAAALgADCgcJEAAAAA==.',
['花火']='花火武:BAAALgADCgUJBQAAAA==.',
['花落']='花落花舞:BAAALgAECgEJAQAAAA==.',
['花蝶']='花蝶舞:BAAALgAECgEJAQAAAA==.',
['花颜']='花颜笑:BAAALgAECgYJCQAAAA==.',
['芳澤']='芳澤霞:BAABLgAECn8VAAIDAAYJzB0NcQDxAQADAAYJzB0NcQDxAQAAAA==.',
['苏梦']='苏梦枕:BAAALgAECgIJAgAAAA==.',
['若風']='若風:BAAALgADCgEJAQAAAA==.',
['茉莉']='茉莉红茶:BAAALgAFFAEJAQAAAA==.',
['草是']='草是你吗:BAAALgAECgcJBwAAAA==.',
['荒野']='荒野铭记不朽:BAAALgAFFAIJAgAAAA==.',
['荔枝']='荔枝果冻丶:BAAALgAECgYJDwAAAA==.',
['荧歌']='荧歌:BAAALgAECgEJAQAAAA==.',
['莫德']='莫德凯撒丶曲:BAAALgAECgUJBgAAAA==.',
['莱昂']='莱昂纳多丶:BAAALgAECgIJAgAAAA==.',
['莵菈']='莵菈玫:BAAALgAECgEJAgAAAA==.',
['莽夫']='莽夫:BAAALgAECgIJAgAAAA==.',
['菊深']='菊深熊大:BAAALgAECgQJBgAAAA==.',
['菩提']='菩提:BAAALgADCgcJCAAAAA==.',
['萌萌']='萌萌小凤梨:BAAALgADCgEJAQAAAA==.萌萌小牛:BAAALgAECgYJCgAAAA==.',
['葱油']='葱油饼:BAAALgAECgIJAgAAAA==.',
['蓁蓁']='蓁蓁宝贝:BAABLgAECn8XAAIDAAcJCRoQTQBPAgADAAcJCRoQTQBPAgAAAA==.',
['蓝梅']='蓝梅子:BAAALgADCgEJAgABLgAFFAMJBgADAHAHAA==.蓝梅籽:BAACLgAFFH8GAAIDAAMJcAe3LwD2AAADAAMJcAe3LwD2AAAuAAQKfxQAAgMABwlUGWQWALEBAAMABwlUGWQWALEBAAAA.',
['蓝牛']='蓝牛:BAAALgAECgQJBAAAAA==.蓝牛蛙:BAABLgAFFH8GAAIUAAIJWh1yGgC7AAAUAAIJWh1yGgC7AAAAAA==.',
['蓝色']='蓝色幽默小人:BAAALgAECgMJAwAAAA==.',
['蔚來']='蔚來:BAAALgAECgYJBgAAAA==.',
['藍蓮']='藍蓮:BAAALgADCgIJBAAAAA==.',
['虚空']='虚空之眼:BAAALgAECgcJCgAAAA==.',
['蚂蚁']='蚂蚁看海:BAAALgADCgcJBwAAAA==.',
['蚕蚕']='蚕蚕:BAAALgAECgMJAwAAAA==.',
['蜂蜜']='蜂蜜丶:BAAALgAECgIJAgAAAA==.',
['血兽']='血兽来快活呀:BAAALgAFFAEJAQAAAA==.',
['衔蝉']='衔蝉:BAAALgAECgcJDAAAAA==.',
['裂蛋']='裂蛋爆鸟拳:BAAALgAECgYJBgAAAA==.',
['誓約']='誓約灬焱:BAAALgAECgEJAQAAAA==.',
['让戦']='让戦士进本吧:BAAALgAECgEJAQAAAA==.',
['诶呀']='诶呀诶呀:BAAALgAECgEJAQAAAA==.',
['谙丶']='谙丶戦:BAABLgAFFH8JAAIQAAQJIhsqDwBlAQAQAAQJIhsqDwBlAQAAAA==.',
['谶无']='谶无所应:BAACLgAFFH8HAAMPAAQJDxUqBAAEAQAPAAMJ+xIqBAAEAQAOAAEJTBsMFABbAAAuAAQKfxgAAw8ABwm8IoYFAKQCAA8ABwm8IoYFAKQCAA4ABAk7HHsuAE4BAAAA.',
['贝啦']='贝啦啦贝拉:BAABLgAFFH8HAAIUAAMJrCHnHAAvAQAUAAMJrCHnHAAvAQAAAA==.',
['赤龍']='赤龍翔天:BAAALgAECgEJAQAAAA==.',
['赤龙']='赤龙影:BAAALgAECgEJAQAAAA==.',
['超新']='超新星暴白熊:BAAALgAECgYJCwAAAA==.',
['超级']='超级中官人:BAABLgAECn8aAAMbAAcJrRTMMwC1AQAbAAcJrRTMMwC1AQAcAAYJFBXaNQB9AQAAAA==.',
['越狱']='越狱兔丶:BAAALgAECgYJCwAAAA==.',
['跑的']='跑的快:BAABLgAFFH8LAAIBAAQJpxIuCAD8AAABAAQJpxIuCAD8AAAAAA==.',
['踏风']='踏风丶风:BAAALgAECgMJAwAAAA==.',
['踢爆']='踢爆春袋:BAAALgAECgMJAwAAAA==.',
['蹦蹦']='蹦蹦炸蛋:BAABLgAFFH8GAAMZAAIJkR+CBQC8AAAYAAIJkR8aGQDBAAAZAAIJqxSCBQC8AAAAAA==.',
['辛茜']='辛茜娅:BAAALgAFFAIJBAAAAA==.',
['达利']='达利乌斯:BAAALgAECgcJDQABLgAFFAEJAQAHAAAAAA==.',
['迪凯']='迪凯晓伊:BAAALgAFFAUJBAAAAA==.',
['迪奥']='迪奥西斯:BAAALgAECgcJDQAAAA==.',
['逆天']='逆天灬轰鸣:BAAALgAFFAQJBAAAAA==.逆天轰鸣灬:BAAALgAECgMJAwAAAA==.',
['逍遥']='逍遥術:BAAALgAECgYJCQAAAA==.',
['邪辟']='邪辟罪惡:BAAALgAFFAEJAQAAAA==.',
['郭子']='郭子仪:BAAALgAECgcJBwAAAA==.',
['都是']='都是世界的错:BAAALgAECgIJAgABLgAFFAMJBwANACEDAA==.',
['都给']='都给我哭:BAAALgADCgQJBAAAAA==.',
['酱爆']='酱爆牛排:BAAALgAECgYJBAAAAA==.',
['醒目']='醒目狂:BAAALgADCgIJAgAAAA==.',
['钱一']='钱一毛:BAAALgAECgEJAQAAAA==.',
['锡兰']='锡兰:BAAALgAECgcJBwAAAA==.',
['闹宝']='闹宝呗萌:BAAALgAECgEJAQAAAA==.',
['闹闹']='闹闹猫:BAAALgAECgYJCQAAAA==.',
['阳光']='阳光小绵羊:BAAALgAECgUJCAAAAA==.',
['阴律']='阴律师之职:BAAALgAECgYJCwAAAA==.',
['阿修']='阿修罗王:BAAALgAECgQJBQAAAA==.',
['阿努']='阿努比司:BAAALgAECgcJCgAAAA==.',
['阿呆']='阿呆不想动:BAAALgADCgIJAgAAAA==.',
['阿啦']='阿啦斯嘉:BAAALgADCgUJBQAAAA==.',
['阿尔']='阿尔忒弥斯:BAAALgAECgcJBwAAAA==.',
['阿拉']='阿拉斯家:BAAALgADCgEJAQAAAA==.阿拉斯迦:BAAALgAECgEJAQABLgAECgEJAgAHAAAAAA==.',
['阿曼']='阿曼达:BAAALgAECggJCAAAAA==.',
['阿这']='阿这:BAAALgAECgMJAwAAAA==.',
['阿飘']='阿飘丶:BAAALgAFFAEJAQAAAA==.',
['阿骨']='阿骨打:BAAALgADCgIJAgAAAA==.',
['陆风']='陆风:BAAALgADCgYJBgAAAA==.',
['陈佰']='陈佰忠:BAAALgAECgEJAQAAAA==.',
['陈大']='陈大师:BAAALgAECgEJAQAAAA==.',
['陌上']='陌上灬花開:BAAALgAECgYJEQAAAA==.',
['陌路']='陌路混混:BAAALgAECgYJDwAAAA==.',
['随意']='随意:BAAALgADCgEJAQAAAA==.',
['隐杀']='隐杀:BAAALgAECgcJCwAAAA==.',
['雨下']='雨下个不停:BAAALgADCgcJBwAAAA==.',
['雨后']='雨后天晴:BAACLgAFFH8JAAIZAAQJqxgOAQB4AQAZAAQJqxgOAQB4AQAuAAQKfxUAAhkABwlZIHIJAEkCABkABwlZIHIJAEkCAAAA.',
['雨夜']='雨夜追寻丶:BAABLgAECn8eAAMFAAgJvRcdMQA2AgAFAAgJvBUdMQA2AgACAAYJKhsVKwBuAQAAAA==.',
['零下']='零下八度:BAAALgAFFAEJAgAAAA==.',
['雾灵']='雾灵之忆:BAAALgAECgYJCwAAAA==.',
['雾隼']='雾隼:BAAALgAECgYJDAAAAA==.',
['霸天']='霸天煞:BAAALgADCgYJBgAAAA==.',
['青琬']='青琬茗:BAAALgAECgYJEQAAAA==.',
['静听']='静听花落:BAAALgAECgYJCwAAAA==.',
['非布']='非布司他:BAAALgADCgYJBgAAAA==.',
['非常']='非常帅的騎士:BAAALgAECgcJBgAAAA==.',
['顺我']='顺我者昌:BAABLgAFFH8GAAIUAAIJph7EGQDBAAAUAAIJph7EGQDBAAAAAA==.',
['风自']='风自由飘:BAAALgADCgEJAQAAAA==.',
['飘零']='飘零枫:BAAALgADCgIJAgAAAA==.',
['飛羽']='飛羽:BAAALgADCgkJBQAAAA==.',
['飞升']='飞升疾走:BAABLgAFFH8FAAIMAAMJuhSEBgARAQAMAAMJuhSEBgARAQAAAA==.',
['飞舞']='飞舞的钢蛋:BAAALgAECgEJAQABLgAFFAcJCwAgAP0dAA==.飞舞的钢蛋儿:BAAALgADCgEJAQAAAA==.',
['饮清']='饮清露藉秋风:BAAALgAECgQJAgAAAA==.',
['香舞']='香舞凝:BAABLgAFFH8IAAIQAAMJTRaoHwAFAQAQAAMJTRaoHwAFAQAAAA==.',
['骑风']='骑风走得人:BAAALgAECgcJBwAAAA==.',
['骨头']='骨头:BAACLgAFFH8IAAIaAAQJoA6sCgBAAQAaAAQJoA6sCgBAAQAuAAQKfxYAAhoABwkUH+gbACICABoABwkUH+gbACICAAAA.',
['魅力']='魅力新广州:BAAALgAECgYJBgAAAA==.',
['魍魉']='魍魉魑魅丶:BAAALgAECgUJCAAAAA==.',
['魔力']='魔力枯法者:BAAALgAECgUJBQAAAA==.',
['魔宠']='魔宠野兽:BAAALgADCgMJAwAAAA==.',
['魔明']='魔明奇妙:BAAALgAECgUJBwAAAA==.',
['魔鬼']='魔鬼牛肉人:BAAALgAECgcJBwAAAA==.',
['鲜虾']='鲜虾云吞:BAAALgAECgYJBgAAAA==.',
['鲨鱼']='鲨鱼小公主:BAAALgAECgEJAgAAAA==.',
['鸟在']='鸟在海里游:BAAALgADCgEJAQAAAA==.',
['鸭梨']='鸭梨不大:BAAALgAECgEJAQAAAA==.',
['鸭鸭']='鸭鸭虾:BAAALgAECgEJAQAAAA==.',
['鹿依']='鹿依依:BAAALgAECgcJBwAAAA==.',
['鹿梦']='鹿梦辰:BAABLgAFFH8GAAMOAAIJRAZkGwCTAAAOAAIJRAZkGwCTAAAWAAIJ8RGyFgBLAAAAAA==.',
['黎明']='黎明神剑:BAAALgAECgcJCwABLgAECgcJGAATAEMcAA==.',
['黑则']='黑则明:BAAALgAECggJEQAAAA==.',
['黑夜']='黑夜的新途:BAACLgAFFH8OAAMRAAUJqQaBBQAcAQARAAQJ6QSBBQAcAQAQAAQJRwSaGgDBAAAuAAQKfyAAAxEACAmfG4kKABYCABEABgkjH4kKABYCABAABQktEISeABsBAAAA.',
['黑怕']='黑怕不怕黑:BAAALgAECgEJAQAAAA==.',
['黑月']='黑月义父:BAAALgAFFAEJAQAAAA==.',
['黑游']='黑游侠领主:BAABLgAECn8bAAIXAAgJJBaXIQA8AgAXAAgJJBaXIQA8AgAAAA==.',
['黯丶']='黯丶戦:BAAALgAFFAIJAgAAAA==.',
['龙希']='龙希颜:BAAALgAECgcJDgABLgAECgcJGAATAEMcAA==.',
['龙息']='龙息之怒:BAAALgAECgYJCAAAAA==.',
['龙腾']='龙腾大模大样:BAAALgAECgEJAQAAAA==.龙腾小七:BAAALgADCgYJBgAAAA==.龙腾飞飞:BAAALgAECgEJAQAAAA==.',
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
