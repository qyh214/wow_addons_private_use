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

local lookup = {'Paladin-Retribution','Mage-Frost','DemonHunter-Devourer','Warlock-Demonology','DemonHunter-Havoc','Shaman-Restoration','Evoker-Augmentation','Warlock-Affliction','Warlock-Destruction','Druid-Balance','Druid-Restoration','DeathKnight-Blood','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Survival','Unknown-Unknown','Paladin-Any','Evoker-Preservation','DemonHunter-Vengeance','Rogue-Subtlety','Priest-Discipline','Priest-Holy','Priest-Shadow','Paladin-Holy','Monk-Brewmaster','Shaman-Elemental','Hunter-Marksmanship','Druid-Guardian','Warrior-Fury','Warrior-Arms','Warrior-Protection','Paladin-Protection','Mage-Arcane','Evoker-Devastation','Monk-Windwalker','Monk-Mistweaver','Mage-Fire',}
local provider = {region='CN',realm='加兹鲁维',name='CN',type='weekly',zone=46,date='2026-04-25',data={Be='Beasny:BAAALgAECgIJAgAAAA==.',
Bl='Blameauxlady:BAAALgAFFAEJAQAAAA==.Bloodborne:BAABLgAECn8UAAIBAAkJgRjzFgDfAgABAAkJgRjzFgDfAgAAAA==.',
Co='Cobrak:BAAALgAECgIJAgAAAA==.Coollittle:BAAALgAECgEJAQAAAA==.',
Da='Darthvade:BAACLgAFFH8KAAICAAMJ8SMBIABHAQACAAMJ8SMBIABHAQAuAAQKfxoAAgIABwk/HuJUADoCAAIABwk/HuJUADoCAAAA.',
De='Deitymoon:BAAALgAECgUJBQAAAA==.',
Di='Divus:BAAALgAECgcJBwABLgAFFAUJCwADADANAA==.',
El='Elenonra:BAABLgAFFH8GAAIEAAIJWxFeNACqAAAEAAIJWxFeNACqAAAAAA==.',
Ev='Evangelion:BAAALgAFFAEJAgAAAA==.Evangelionr:BAAALgAECgIJAwAAAA==.',
Fl='Flyingmage:BAAALgAFFAMJBAAAAA==.',
Ga='Gazingsm:BAAALgAECgYJBgAAAA==.',
Ha='Hambella:BAAALgAECgUJBAAAAA==.Harley:BAAALgADCgMJAwAAAA==.',
He='Heartdh:BAAALgAECgMJAwAAAA==.Heartlong:BAAALgAECgIJAgAAAA==.Heartsm:BAAALgAECgcJBAAAAA==.',
Iv='Ivanwang:BAAALgAECgYJCwAAAA==.',
Ja='Java:BAAALgAECgYJCAAAAA==.',
Je='Jerryovo:BAABLgAECn8dAAIDAAgJeRFAEwBlAQADAAgJeRFAEwBlAQAAAA==.',
Ju='Judy:BAABLgAECn8dAAIFAAkJzBzJBAApAwAFAAkJzBzJBAApAwAAAA==.',
Ki='Kiana:BAAALgADCgUJBQAAAA==.',
Li='Lilith:BAAALgAECgUJBQAAAA==.Linkman:BAABLgAFFH8GAAIGAAMJzRKeDwDrAAAGAAMJzRKeDwDrAAAAAA==.',
Lo='Lolend:BAAALgADCgMJAwAAAA==.',
Mo='Momofa:BAAALgAECgcJBwAAAA==.Mordred:BAAALgAECgUJBQAAAA==.',
Ne='Nefaria:BAAALgAECgMJAwAAAA==.',
No='Noobjesfu:BAAALgAECgMJBgAAAA==.',
Pe='Peaks:BAAALgAFFAMJBAAAAA==.',
Pr='Providence:BAAALgAECgMJAwAAAA==.',
Re='Revvez:BAAALgAECgYJBgAAAA==.',
Ri='Rider:BAAALgAECgQJBAAAAA==.',
Rj='Rjj:BAAALgAFFAIJAgAAAA==.',
Ro='Rockman:BAAALgAECgEJAQAAAA==.',
Ru='Rumudamo:BAAALgAECgQJBgAAAA==.',
Si='Silvermagic:BAAALgAECgcJDAAAAA==.',
Sp='Sphoenix:BAAALgAECgEJAgAAAA==.',
St='Sthdracthyr:BAACLgAFFH8MAAIHAAUJxhj9BQCeAQAHAAUJxhj9BQCeAQAuAAQKfyIAAgcACAlaIm4QAHICAAcACAlaIm4QAHICAAAA.',
Su='Suffer:BAACLgAFFH8HAAIDAAMJQQ2JHQDpAAADAAMJQQ2JHQDpAAAuAAQKfyYAAgMACAnaGxAGABsCAAMACAnaGxAGABsCAAAA.',
['Sà']='Sà:BAAALgAECgYJDAAAAA==.',
Vl='Vladimir:BAABLgAECn8WAAQEAAgJfRDFTwDYAQAEAAgJHhDFTwDYAQAIAAIJ3Bg9HACRAAAJAAEJZgFffwAYAAAAAA==.',
Wa='Waye:BAAALgAECgQJBAAAAA==.',
Xt='Xt:BAACLgAFFH8FAAMKAAMJvwnpFQCVAAAKAAMJvwnpFQCVAAALAAEJXBL4JABGAAAuAAQKfyAAAwsACAlCGRgkACoCAAsABwm6GxgkACoCAAoACAmSGg8iAOwBAAAA.',
Yo='Yoyoma:BAAALgADCgYJBgAAAA==.',
Zl='Zloven:BAAALgAECgQJBAAAAA==.',
['一位']='一位父亲:BAACLgAFFH8LAAIMAAQJ7iSpAACrAQAMAAQJ7iSpAACrAQAuAAQKfxQAAwwACQluHXsHALQCAAwACQmdHHsHALQCAA0ABwmKE8mLAGkBAAAA.',
['一只']='一只小脑斧丶:BAAALgADCgYJBgAAAA==.一只小血兽:BAAALgAFFAEJAQAAAA==.',
['一蝶']='一蝶恋花一:BAAALgAECgIJAgAAAA==.',
['一饮']='一饮一啄:BAAALgAFFAIJAgABLgAFFAQJCwAMAO4kAA==.',
['一黎']='一黎阳光丿:BAAALgAECgMJBQAAAA==.',
['七夜']='七夜狂吻:BAAALgAECgcJDAAAAA==.',
['三七']='三七二十八:BAAALgADCgUJBQAAAA==.',
['三斤']='三斤丶恶魔猎:BAAALgAECgYJBgAAAA==.',
['三眼']='三眼仔:BAAALgAFFAIJAwAAAA==.',
['三鸡']='三鸡:BAAALgAFFAIJAwAAAA==.',
['上昂']='上昂建科财务:BAAALgAECgcJDQAAAA==.',
['丛林']='丛林猎手堆堆:BAACLgAFFH8NAAIOAAQJdhUBAwBdAQAOAAQJdhUBAwBdAQAuAAQKfygAAw4ACQl6G78GACIDAA4ACQl6G78GACIDAA8AAgkfCNoTAEEAAAAA.',
['东风']='东风谷早苗丿:BAAALgAFFAIJAgAAAA==.',
['丨丶']='丨丶东流:BAAALgAFFAIJAwAAAA==.',
['丨百']='丨百事可乐丨:BAAALgAECgUJCQAAAA==.',
['个子']='个子有点矮:BAAALgAECgYJDgAAAA==.',
['丶机']='丶机械猎:BAAALgAECgIJAwAAAA==.',
['丶柳']='丶柳如烟:BAAALgAECgIJAgABLgAECgMJBAAQAAAAAA==.',
['丿安']='丿安逸丶:BAAALgAECgcJCAAAAA==.',
['乀乛']='乀乛一乛乀:BAAALgAFFAIJBAABLgAFFAcJBgARANsXAA==.',
['乌鹃']='乌鹃:BAAALgADCgcJBwAAAA==.',
['乳齿']='乳齿纯洁:BAAALgADCgcJDgAAAA==.',
['于壮']='于壮壮:BAAALgAFFAEJAQAAAA==.',
['云舒']='云舒澍:BAABLgAECn8kAAICAAgJaRReEgCvAQACAAgJaRReEgCvAQAAAA==.',
['人间']='人间祸害:BAAALgAECgIJAwAAAA==.',
['伊利']='伊利达雷乂怒:BAAALgAECgYJCgAAAA==.',
['伍迪']='伍迪法:BAAALgADCgUJBQAAAA==.',
['伍零']='伍零柒:BAAALgAFFAIJBAAAAA==.',
['伐木']='伐木机:BAAALgAFFAMJBAAAAA==.',
['伸掌']='伸掌乳来:BAABLgAECn8dAAMLAAYJxBgXRACRAQALAAYJxBgXRACRAQAKAAEJtgBokgAMAAAAAA==.',
['佐骑']='佐骑:BAAALgAECgEJAQAAAA==.',
['你也']='你也龙了吗:BAAALgADCgEJAQAAAA==.',
['你們']='你們缺德吗:BAAALgAFFAEJAwAAAA==.',
['你聋']='你聋了吗:BAABLgAECn8hAAISAAcJBB13DgBPAgASAAcJBB13DgBPAgABLgAFFAIJAgAQAAAAAA==.',
['修灬']='修灬罗:BAABLgAFFH8JAAQDAAQJXxdTDwBTAQADAAQJXxdTDwBTAQATAAEJTB9eBABeAAAFAAEJ5g12DQBQAAAAAA==.',
['健康']='健康雨:BAAALgAECgEJAQABLgAFFAQJCwAMAO4kAA==.',
['元元']='元元加油:BAAALgAECgcJBAAAAA==.',
['克烈']='克烈辣舞:BAAALgADCgcJBwAAAA==.',
['八极']='八极定乾坤:BAABLgAECn8YAAIUAAcJqRqVFwBMAgAUAAcJqRqVFwBMAgAAAA==.',
['六月']='六月柒瓣雪:BAAALgAFFAMJBAAAAA==.',
['兰兰']='兰兰楠:BAAALgAECgcJBwAAAA==.',
['兰舍']='兰舍兰分:BAAALgAECgMJBgAAAA==.',
['冒德']='冒德:BAAALgAECgEJAQAAAA==.',
['冰澜']='冰澜:BAAALgADCgYJBgAAAA==.',
['冲锋']='冲锋给您按摩:BAAALgAECgYJBwAAAA==.',
['创世']='创世小超人:BAAALgAECgEJAQAAAA==.',
['别在']='别在他坟前哭:BAAALgADCgIJAgABLgAFFAIJAgAQAAAAAA==.',
['削死']='削死大咕咕:BAAALgAECgEJAQAAAA==.',
['剌剌']='剌剌四哥:BAAALgAECgEJAQAAAA==.',
['千里']='千里冰锋:BAAALgAECgQJBAAAAA==.',
['半夕']='半夕蝶梦:BAACLgAFFH8GAAMVAAMJJwQjEADLAAAVAAMJJwQjEADLAAAWAAEJVACHGAAnAAAuAAQKfx8ABBYACAnYDJc3AF4BABYABwkbDZc3AF4BABUABwk6BxMrAEEBABcABAkbC9REANYAAAAA.',
['半支']='半支烟的幻想:BAAALgAECgYJCgAAAA==.',
['卓卓']='卓卓一刀一个:BAAALgAECgQJBAAAAA==.',
['单纯']='单纯想杀你:BAAALgAECgEJAQAAAA==.',
['南兮']='南兮丶寒笙:BAABLgAECn8ZAAICAAcJ6Bm4ZQAMAgACAAcJ6Bm4ZQAMAgAAAA==.',
['南海']='南海归来:BAAALgAFFAEJAgAAAA==.',
['南熙']='南熙丶寒笙:BAAALgAECgYJCgAAAA==.',
['南门']='南门无敌:BAAALgAECgUJBQAAAA==.',
['南青']='南青辛:BAAALgAECgMJAwAAAA==.',
['卡卡']='卡卡西灬牧:BAAALgADCgIJAgAAAA==.卡卡西灬骑:BAAALgAECgQJBAAAAA==.卡卡西灬魔:BAAALgAECgcJCgAAAA==.',
['卡罗']='卡罗琳:BAAALgAECgQJBQAAAA==.',
['卷毛']='卷毛尐猪头:BAAALgAECgkJAwAAAA==.',
['厄欧']='厄欧斯圣光:BAAALgAFFAIJAwABLgAFFAMJBwAVAGsZAA==.厄欧斯微风:BAACLgAFFH8HAAIVAAMJaxnuDAAAAQAVAAMJaxnuDAAAAQAuAAQKfygAAxUACAlsI1EAAEgDABUACAlsI1EAAEgDABYABwlrGO0dAO8BAAAA.',
['厌倦']='厌倦了吗:BAAALgADCgcJBwAAAA==.',
['及时']='及时护住了眼:BAAALgAECgEJAgAAAA==.及时护住她:BAAALgAECgEJAQAAAA==.及时护住它:BAAALgAECgYJDQAAAA==.及时护住脸:BAABLgAECn8XAAMYAAYJ1RO+PwB5AQAYAAYJ1RO+PwB5AQABAAUJJA8TxwD6AAAAAA==.',
['双采']='双采小德:BAAALgADCgYJBgAAAA==.',
['口勿']='口勿一散落:BAAALgAECgcJBwAAAA==.',
['古岑']='古岑:BAABLgAECn8dAAIBAAkJmyB0BQB1AwABAAkJmyB0BQB1AwAAAA==.',
['叫我']='叫我丶坑:BAAALgADCgEJAQAAAA==.',
['可可']='可可幂丶:BAAALgAECgcJDAAAAA==.',
['可颜']='可颜可甜丶:BAAALgADCgUJBQAAAA==.',
['吃饭']='吃饭高手:BAAALgAECgEJAQAAAA==.',
['后会']='后会无期丶:BAAALgAECgYJDAAAAA==.',
['吴越']='吴越街流氓:BAAALgAECgUJBQAAAA==.',
['呆呆']='呆呆丶鸟:BAAALgAECgMJBAAAAA==.',
['咸咸']='咸咸哒:BAAALgAECgEJAQAAAA==.',
['哀之']='哀之熵:BAAALgAECgIJAgAAAA==.',
['哇好']='哇好靓啊:BAAALgAECgcJBwAAAA==.',
['哈利']='哈利丨神圣骑:BAAALgADCgEJAQAAAA==.',
['哥伦']='哥伦比娅:BAAALgAFFAEJAQAAAA==.',
['唱游']='唱游:BAAALgAECgEJAQAAAA==.',
['啊拉']='啊拉朵朵:BAAALgAECgYJDwAAAA==.',
['喜娃']='喜娃不进本:BAAALgADCgcJDAAAAA==.',
['喵喵']='喵喵不带宝宝:BAAALgAFFAIJBAAAAA==.喵喵糖门躺:BAAALgAECgIJAgAAAA==.',
['国宝']='国宝壹号:BAAALgAECgcJBwAAAA==.',
['国宾']='国宾七号:BAAALgAECgEJAQAAAA==.国宾二号:BAAALgAECgYJCgAAAA==.国宾六号:BAABLgAFFH8HAAIZAAIJIRr7GgCTAAAZAAIJIRr7GgCTAAAAAA==.',
['国服']='国服喷子:BAAALgAECgEJAQAAAA==.',
['圆圆']='圆圆滚滚:BAAALgADCgUJBQAAAA==.',
['圣博']='圣博:BAAALgAECgcJCQAAAA==.',
['圣弥']='圣弥陀:BAAALgAECgcJDAAAAA==.',
['圣浪']='圣浪:BAACLgAFFH8LAAIBAAQJpgMGCAAPAQABAAQJpgMGCAAPAQAuAAQKfxQAAgEACQkpEt0tAGwCAAEACQkpEt0tAGwCAAAA.',
['圣骑']='圣骑寺:BAAALgAECgIJAgAAAA==.',
['塔菈']='塔菈夏的狐狸:BAAALgAECgIJAwAAAA==.',
['境外']='境外拾荒者:BAAALgAFFAIJAwAAAA==.',
['复活']='复活的怕辣丁:BAAALgAFFAIJBAAAAA==.',
['夏殇']='夏殇丶:BAAALgAECgYJBgAAAA==.',
['夏缇']='夏缇雅:BAAALgAECgEJAQAAAA==.',
['夜之']='夜之子的遗产:BAAALgAECgIJAwAAAA==.',
['夜星']='夜星河舞:BAAALgAFFAIJAwAAAA==.',
['夜莺']='夜莺:BAAALgAECgEJAQAAAA==.',
['夜霜']='夜霜之哀:BAAALgAECgUJCAAAAA==.',
['大河']='大河豚:BAACLgAFFH8FAAIGAAMJwxhKDgD4AAAGAAMJwxhKDgD4AAAuAAQKfykAAwYACAn5JPADADYDAAYACAn5JPADADYDABoABgkuHEslAOcBAAAA.',
['大苍']='大苍蝇:BAAALgAECgYJEAAAAA==.',
['大酋']='大酋長:BAACLgAFFH8IAAINAAQJkx2GAgCJAQANAAQJkx2GAgCJAQAuAAQKfx8AAg0ACAnNH5ocANMCAA0ACAnNH5ocANMCAAAA.',
['大鸟']='大鸟伯德:BAAALgAECgcJCAAAAA==.',
['天丨']='天丨狱:BAACLgAFFH8GAAIOAAMJwBIGCwAJAQAOAAMJwBIGCwAJAQAuAAQKfygAAw4ACAmSIvoHABADAA4ACAmSIvoHABADABsABglSGNU4AH4BAAAA.',
['天凰']='天凰盖地虎:BAAALgAECgIJAgAAAA==.',
['天启']='天启强:BAAALgAECgQJAwAAAA==.',
['天婼']='天婼侑情:BAAALgAECgEJAQAAAA==.',
['天灬']='天灬狱:BAAALgADCgcJFQAAAA==.',
['天灾']='天灾与我同在:BAAALgAECgEJAQAAAA==.天灾之狼:BAAALgAECgEJAQAAAA==.',
['天然']='天然二:BAAALgADCgcJDQAAAA==.天然呆坑爹很:BAAALgAECgQJBAAAAA==.',
['天荒']='天荒盖地虎:BAAALgAECgIJBAAAAA==.',
['失去']='失去了理智:BAAALgAECgUJBQAAAA==.',
['奔跑']='奔跑的五花:BAACLgAFFH8GAAIOAAMJFxeECgANAQAOAAMJFxeECgANAQAuAAQKfygAAg4ACAlKJNYBAJsCAA4ACAlKJNYBAJsCAAAA.',
['奔雷']='奔雷:BAAALgAECgcJBwAAAA==.',
['女王']='女王丶箭头:BAAALgADCgcJBwAAAA==.',
['如情']='如情似水:BAAALgAECgUJBgAAAA==.',
['如故']='如故:BAAALgAFFAIJBAAAAA==.',
['如阳']='如阳:BAAALgADCgEJAQAAAA==.',
['嫡公']='嫡公主:BAAALgADCgIJAgAAAA==.',
['孑涩']='孑涩丶军师:BAAALgAECgYJDAAAAA==.',
['孤傲']='孤傲龙王:BAAALgAFFAQJBAAAAA==.',
['孤寂']='孤寂:BAAALgAECgQJAQAAAA==.',
['宇昕']='宇昕:BAAALgAFFAEJAgAAAA==.',
['审判']='审判之焱:BAAALgAECgcJCwAAAA==.',
['射穿']='射穿你的心:BAAALgAECgEJAQAAAA==.',
['小仙']='小仙仙丶:BAAALgAECgYJCQAAAA==.',
['小叮']='小叮当:BAAALgAECgUJBQAAAA==.',
['小咪']='小咪的冬天:BAAALgAECgYJBwAAAA==.小咪的秋天:BAAALgAECgUJBgAAAA==.',
['小喵']='小喵的喵喵:BAABLgAFFH8FAAIVAAIJkAP2FQCDAAAVAAIJkAP2FQCDAAAAAA==.',
['小小']='小小末丶:BAAALgAECgIJAgAAAA==.',
['小德']='小德永不为宠:BAACLgAFFH8FAAIcAAMJhARlBACHAAAcAAMJhARlBACHAAAuAAQKfygAAwsACAmkFC8PAGQBAAsACAmkFC8PAGQBAAoAAwksC7QVAKoAAAAA.',
['小托']='小托:BAAALgAECgMJAwAAAA==.',
['小木']='小木木骑:BAAALgAECgEJAQAAAA==.',
['小梁']='小梁:BAAALgADCgEJAQAAAA==.',
['小短']='小短袖:BAAALgAFFAIJAwAAAA==.',
['小花']='小花貓:BAAALgAECgEJAgAAAA==.',
['小软']='小软丶糖:BAAALgAECgcJBwAAAA==.',
['小高']='小高三号:BAAALgAFFAIJAwAAAA==.',
['小龙']='小龙人起飞:BAAALgAFFAQJBAAAAA==.',
['尘丶']='尘丶风:BAAALgAECgIJAgAAAA==.',
['左右']='左右为兰:BAAALgAECgQJBgAAAA==.',
['巨兰']='巨兰楠:BAAALgAECgEJAgAAAA==.',
['已经']='已经着魔:BAAALgADCgMJAwAAAA==.',
['希爾']='希爾梅丽雅:BAAALgAECgEJAgAAAA==.',
['幸运']='幸运的逗逼:BAAALgAECgUJBQAAAA==.',
['张小']='张小瑜:BAABLgAFFH8GAAILAAUJ+BqCAQC7AQALAAUJ+BqCAQC7AQAAAA==.张小瑜牧:BAACLgAFFH8QAAIVAAUJuhaGBAClAQAVAAUJuhaGBAClAQAuAAQKfyQAAhUACQlcHyUDAD0DABUACQlcHyUDAD0DAAAA.张小瑜龙:BAACLgAFFH8QAAISAAUJ4x8QAwDeAQASAAUJ4x8QAwDeAQAuAAQKfygAAxIACQkDIl8BAFECABIACAm6IV8BAFECAAcAAgnqD0lRAIUAAAAA.',
['彩字']='彩字铅笔:BAAALgAECgYJBwAAAA==.',
['徐尔']='徐尔丹:BAAALgAECgEJAgAAAA==.',
['徐锦']='徐锦江:BAAALgADCgUJBQAAAA==.',
['德行']='德行德很:BAAALgAECgYJDAAAAA==.',
['德鲁']='德鲁伊:BAAALgADCgUJBQAAAA==.',
['忒修']='忒修斯的船:BAAALgADCgcJCAAAAA==.',
['快乐']='快乐的南小鸟:BAACLgAFFH8IAAIDAAMJbx4lFQAqAQADAAMJbx4lFQAqAQAuAAQKfyYAAgMACAnYJH0CAI4CAAMACAnYJH0CAI4CAAAA.快乐的逗逼:BAAALgAECgYJBwAAAA==.',
['怀批']='怀批:BAABLgAECn8cAAQdAAgJMRcKKAAdAgAdAAcJQBoKKAAdAgAeAAUJRRY8EwBxAQAfAAEJ0wR9SAAtAAAAAA==.',
['怕辣']='怕辣丁同学:BAAALgAFFAIJAQABLgAFFAIJBAAQAAAAAA==.',
['怪诞']='怪诞心理学:BAAALgAECgUJCAAAAA==.',
['恰同']='恰同学少年:BAAALgAFFAIJAgAAAA==.',
['悠悠']='悠悠穆师:BAAALgAECgkJCQABLgAFFAUJBAAQAAAAAA==.',
['悦之']='悦之守护者:BAAALgAECgYJBgAAAA==.',
['悲酥']='悲酥淸风:BAAALgAECgkJEAAAAA==.',
['想咋']='想咋打就咋打:BAAALgAECgYJBgAAAA==.',
['感冒']='感冒灵丶冲剂:BAAALgADCgUJBQAAAA==.',
['愿大']='愿大地忽悠你:BAAALgAECgEJAQAAAA==.',
['愿风']='愿风载尘:BAAALgADCgEJAQAAAA==.',
['慕水']='慕水鱼:BAAALgADCgIJAgAAAA==.',
['懒德']='懒德鸟你:BAAALgAECgEJAgAAAA==.',
['我就']='我就是明明:BAAALgAFFAQJAwAAAA==.',
['我最']='我最大:BAAALgAECgEJAgAAAA==.',
['我没']='我没奶:BAAALgAECgMJCQAAAA==.',
['我色']='我色我痴情:BAAALgAECgEJAQAAAA==.',
['战争']='战争怒牛:BAAALgAECgYJDwAAAA==.',
['戢羽']='戢羽寒条:BAAALgAFFAIJAgABLgAFFAUJBAAQAAAAAA==.',
['抡完']='抡完就躺:BAAALgAECgEJAQAAAA==.',
['拂晓']='拂晓残阳:BAAALgAECgEJAQABLgAFFAQJBAAQAAAAAA==.',
['拖鞋']='拖鞋战神:BAABLgAECn8aAAICAAgJ2BSHUQBDAgACAAgJ2BSHUQBDAgAAAA==.',
['拯救']='拯救地球真累:BAAALgAECgQJCAAAAA==.',
['於音']='於音:BAAALgAFFAEJAQAAAA==.',
['无卝']='无卝风月:BAAALgAECgYJBwAAAA==.',
['日光']='日光析蓝丶:BAAALgAECgcJBwAAAA==.',
['日用']='日用而不觉:BAAALgAFFAIJAgABLgAFFAQJCwAMAO4kAA==.',
['时光']='时光骑:BAAALgAECgcJEwAAAA==.',
['明明']='明明蹬嶝僜:BAAALgAECgYJBgAAAA==.',
['星期']='星期天建号:BAAALgADCgcJBwAAAA==.',
['晓花']='晓花丶锅:BAAALgAECgUJCAAAAA==.',
['晚安']='晚安尐敏:BAAALgAFFAQJBAAAAA==.',
['晨曦']='晨曦圣光:BAABLgAECn8fAAIXAAgJQBXwFgAuAgAXAAgJQBXwFgAuAgAAAA==.',
['晴天']='晴天小蛋:BAAALgAECgUJBQAAAA==.',
['暗影']='暗影沉迷:BAAALgAECgEJAgAAAA==.',
['暗黑']='暗黑大菠萝:BAAALgAECgcJAgAAAA==.暗黑破坏神:BAABLgAECn8UAAIYAAYJcR7GIwAEAgAYAAYJcR7GIwAEAgAAAA==.',
['暮色']='暮色恩颜:BAAALgADCgEJAQAAAA==.',
['曼殊']='曼殊莎华:BAAALgADCgEJAQAAAA==.',
['月下']='月下忆江南:BAAALgAECgMJAwAAAA==.',
['有点']='有点猛:BAAALgAECgkJBwAAAA==.',
['有病']='有病的牛排:BAAALgAECgYJCwAAAA==.',
['木木']='木木马:BAAALgAECgEJAgAAAA==.',
['术爷']='术爷有砖:BAAALgAECgMJAwAAAA==.',
['李亚']='李亚军:BAABLgAECn8XAAMBAAcJaxThFgBpAQABAAcJaxThFgBpAQAgAAQJggaAOgBVAAAAAA==.',
['李斯']='李斯:BAABLgAFFH8HAAICAAMJrxVuKAASAQACAAMJrxVuKAASAQAAAA==.',
['杨沈']='杨沈怡:BAAALgAECgEJAQAAAA==.',
['杭州']='杭州猫:BAAALgAECgEJAQAAAA==.',
['枯法']='枯法者:BAAALgAECgYJBwAAAA==.',
['柒丶']='柒丶柒:BAAALgAECgEJAQAAAA==.',
['柒柒']='柒柒:BAAALgAECgkJAgAAAA==.',
['桑多']='桑多涅:BAACLgAFFH8GAAINAAMJbiU7FQBOAQANAAMJbiU7FQBOAQAuAAQKfyEAAg0ACAl7Jn0AAB8DAA0ACAl7Jn0AAB8DAAAA.',
['梦醒']='梦醒方知初:BAAALgAECgEJAQAAAA==.',
['梧桐']='梧桐射手:BAAALgAECgcJDQAAAA==.',
['椰子']='椰子啊椰子:BAABLgAFFH8FAAIOAAIJIR2RDwDLAAAOAAIJIR2RDwDLAAAAAA==.',
['橙兰']='橙兰楠:BAAALgAFFAIJAgAAAA==.',
['欧比']='欧比旺克诺比:BAAALgAECgkJEwAAAA==.',
['欧皇']='欧皇天:BAAALgAECgUJCQAAAA==.',
['歌神']='歌神黄绮三:BAAALgAFFAIJAwAAAA==.',
['步璃']='步璃璃:BAAALgAECgYJBgAAAA==.',
['武当']='武当三:BAAALgAFFAIJAgAAAA==.',
['殇之']='殇之橙影:BAAALgAECgYJDQAAAA==.',
['残月']='残月泣血:BAACLgAFFH8NAAINAAQJDiG8AgCEAQANAAQJDiG8AgCEAQAuAAQKfygAAg0ACQkpJKsCALADAA0ACQkpJKsCALADAAAA.',
['毅德']='毅德服人:BAAALgAFFAIJAgAAAA==.',
['毛球']='毛球:BAAALgAFFAEJAgAAAA==.',
['水管']='水管犀利哥:BAAALgAECgMJAQAAAA==.',
['水贼']='水贼:BAAALgAECgkJAQAAAA==.',
['水银']='水银丶燈:BAABLgAFFH8FAAMMAAIJyhbpDQCNAAAMAAIJyhbpDQCNAAANAAIJ3BMpIwBUAAAAAA==.',
['江南']='江南:BAAALgADCgcJBwAAAA==.',
['江雪']='江雪:BAAALgAECgMJAwAAAA==.',
['沈女']='沈女士:BAAALgAECgYJBgAAAA==.',
['沐雨']='沐雨橙風:BAABLgAECn8bAAMCAAcJqBrAYAAZAgACAAcJqBrAYAAZAgAhAAEJ4hClGgBDAAAAAA==.',
['没事']='没事跑着玩:BAAALgAECgIJAgAAAA==.',
['河浅']='河浅:BAAALgAECgUJCgAAAA==.',
['法力']='法力虚空:BAAALgAECgYJCAAAAA==.',
['泡泡']='泡泡守护神:BAAALgAECgQJBgAAAA==.',
['洛之']='洛之骑:BAAALgAECgkJCQAAAA==.',
['洛克']='洛克斯基:BAAALgAECgkJCQAAAA==.',
['洮姿']='洮姿仸仸:BAAALgAECgkJBwAAAA==.',
['流年']='流年兮:BAAALgAECgEJAgAAAA==.',
['海葵']='海葵花大官人:BAAALgAFFAIJBAAAAA==.',
['深海']='深海蓝蓝的蓝:BAAALgAECgYJDgAAAA==.',
['清晨']='清晨的小鹿:BAAALgADCgYJBgAAAA==.',
['游荡']='游荡者:BAAALgAFFAEJAQAAAA==.',
['溪云']='溪云初起:BAAALgAFFAIJAwAAAA==.',
['滴耶']='滴耶:BAACLgAFFH8NAAIKAAQJKhupBgB5AQAKAAQJKhupBgB5AQAuAAQKfxwAAwoACAmvJHMFAEcDAAoACAmvJHMFAEcDABwAAgmFGm0gAJsAAAAA.',
['潘凤']='潘凤上将:BAAALgAECgQJBQAAAA==.',
['潘达']='潘达超:BAAALgAFFAIJAgAAAA==.',
['火旺']='火旺:BAAALgADCgUJBQAAAA==.',
['灬玳']='灬玳灬:BAAALgAFFAMJAwAAAA==.',
['灬钢']='灬钢镚灬:BAAALgAECgcJDgAAAA==.',
['灵泛']='灵泛得乐:BAAALgAECgEJAQAAAA==.',
['灵魂']='灵魂:BAAALgADCgMJAwAAAA==.',
['炸洋']='炸洋芋叁元:BAAALgAECgYJAgABLgAFFAUJCQAZAI4YAA==.炸洋芋壹元:BAAALgAFFAQJBAABLgAFFAUJCQAZAI4YAA==.炸洋芋贰元:BAAALgAFFAQJBAABLgAFFAUJCQAZAI4YAA==.',
['烬魂']='烬魂焰:BAAALgADCgYJBwAAAA==.',
['热心']='热心的网友:BAAALgAECgcJCwAAAA==.',
['烽烟']='烽烟:BAAALgAECgcJDQAAAA==.',
['熊不']='熊不削就玩德:BAAALgADCgMJAwABLgAFFAIJAgAQAAAAAA==.',
['爆力']='爆力美学丶:BAAALgAECgcJDgAAAA==.',
['爱吃']='爱吃豆皮儿:BAAALgAFFAIJAwAAAA==.',
['牙买']='牙买代:BAAALgAECgYJDQAAAA==.',
['牜彁']='牜彁:BAAALgADCgcJBwAAAA==.',
['狂傲']='狂傲的小龙人:BAAALgAFFAMJAwAAAA==.',
['狂暴']='狂暴火旺:BAAALgADCgEJAQAAAA==.',
['狸洱']='狸洱狗:BAAALgAECgEJAQAAAA==.',
['狸狸']='狸狸哈哈:BAAALgAECgUJBQAAAA==.',
['猎修']='猎修缘:BAAALgADCgEJAQAAAA==.',
['猎爷']='猎爷:BAAALgAECgEJAgAAAA==.',
['猕猴']='猕猴桃丨:BAABLgAECn8eAAIcAAkJnCKRAACOAwAcAAkJnCKRAACOAwAAAA==.猕猴桃丶可可:BAABLgAFFH8FAAICAAMJ5witMADwAAACAAMJ5witMADwAAABLgAFFAQJCAADABIRAA==.猕猴桃可可:BAABLgAFFH8IAAIDAAQJEhGnBwA2AQADAAQJEhGnBwA2AQAAAA==.',
['猛猛']='猛猛超人:BAAALgADCgEJAQAAAA==.',
['獸人']='獸人永不爲奴:BAAALgAECgcJBwAAAA==.',
['珂朵']='珂朵莉:BAACLgAFFH8NAAIKAAQJcCMAAQCYAQAKAAQJcCMAAQCYAQAuAAQKfx0AAgoACQl4IkcCAJ4DAAoACQl4IkcCAJ4DAAAA.',
['瑟兰']='瑟兰婕拉娜:BAAALgAFFAIJAgAAAA==.瑟兰迪尼斯:BAACLgAFFH8HAAMHAAMJGBVdEAD/AAAHAAMJGBVdEAD/AAASAAEJkwk+FgBQAAAuAAQKfyAABAcACAlII8kJANkCAAcABwkUI8kJANkCACIABgmSJKkHAG8CABIAAQliCzFJADAAAAAA.',
['男上']='男上加兰:BAAALgAECgIJAQAAAA==.',
['略匮']='略匮明朝:BAACLgAFFH8LAAMfAAQJ8QhwBwDqAAAfAAQJNgdwBwDqAAAeAAEJgwmaDABOAAAuAAQKfxYABB4ABwnJFYEKAP4BAB4ABwm9FIEKAP4BAB0ABQk6D3NsAAQBAB8ABAn0DLA5AH0AAAAA.',
['瘦战']='瘦战愁:BAAALgAFFAEJAQAAAA==.',
['白藏']='白藏桂月:BAAALgAECgcJBwAAAA==.',
['白露']='白露:BAAALgAECgMJBAAAAA==.',
['皓月']='皓月婵娟:BAAALgAECggJCwABLgAFFAQJDQAKAHAjAA==.',
['皮皮']='皮皮猪我们走:BAAALgADCgEJAQAAAA==.',
['瞪谁']='瞪谁谁变性:BAAALgAECgMJAwAAAA==.',
['破空']='破空:BAAALgADCgIJAgAAAA==.',
['神以']='神以灵:BAAALgAECgcJBwAAAA==.',
['神兽']='神兽璐:BAABLgAECn8fAAICAAgJcRqaOQCPAgACAAgJcRqaOQCPAgAAAA==.',
['祺麟']='祺麟:BAAALgADCgcJCgAAAA==.',
['离珥']='离珥狗:BAAALgAECgkJAQAAAA==.',
['秋天']='秋天好阿:BAAALgAECgEJAQAAAA==.',
['笑面']='笑面毒奶啊:BAAALgAECgQJBAAAAA==.',
['第七']='第七军团法神:BAAALgAFFAIJAgAAAA==.第七军团骑士:BAAALgAECgYJDQAAAA==.',
['筱咪']='筱咪:BAAALgAECgYJBwAAAA==.',
['筱昊']='筱昊:BAAALgAECgcJCAAAAA==.',
['筱牛']='筱牛:BAAALgAECgMJBAAAAA==.',
['筱麛']='筱麛:BAAALgAECgEJAgAAAA==.',
['米飒']='米飒:BAAALgADCgYJBgAAAA==.',
['粉凤']='粉凤凰:BAAALgAFFAIJBAAAAA==.',
['粉拳']='粉拳为谁握:BAABLgAECn8VAAMjAAkJYB53DQCkAgAjAAgJhR13DQCkAgAkAAEJCgp2ZABAAAABLgAFFAQJCwAMAO4kAA==.',
['素颜']='素颜丶裕:BAAALgAFFAIJAwAAAA==.',
['紫夜']='紫夜心殇:BAAALgAECgEJAQAAAA==.',
['紫灵']='紫灵:BAAALgADCgMJAwAAAA==.',
['纠结']='纠结女王:BAAALgAECgEJAQAAAA==.',
['红尘']='红尘梦影:BAAALgAECgkJDgAAAA==.',
['红色']='红色大领主:BAAALgADCgMJAwAAAA==.',
['纳西']='纳西妲:BAAALgAFFAIJAgAAAA==.',
['绘梦']='绘梦:BAAALgAECgYJBgAAAA==.',
['绘梨']='绘梨衣:BAAALgAFFAEJAQAAAA==.',
['绵绵']='绵绵丶:BAAALgAECgMJAwAAAA==.',
['绽放']='绽放不锈:BAAALgADCgQJBAAAAA==.绽放仍锈:BAAALgAECgYJBgAAAA==.绽放卟锈:BAAALgADCgEJAQAAAA==.绽放狂绣:BAAALgAECgYJBgAAAA==.绽放狂锈:BAACLgAFFH8NAAIGAAQJ9Q8oCgAyAQAGAAQJ9Q8oCgAyAQAuAAQKfysAAgYACQmkF+MYAE8CAAYACQmkF+MYAE8CAAAA.绽放狅琇:BAAALgAFFAIJAgAAAA==.',
['缇里']='缇里西庇俄丝:BAACLgAFFH8JAAMXAAQJYhirCQAdAQAXAAQJYhirCQAdAQAVAAEJTQsfGQBMAAAuAAQKfx0AAhcABwkPIbsNAKcCABcABwkPIbsNAKcCAAAA.',
['缑婉']='缑婉妗:BAAALgADCgQJBAAAAA==.',
['罗斯']='罗斯邓肯:BAABLgAECn8VAAIUAAgJyRucDQDCAgAUAAgJyRucDQDCAgAAAA==.',
['羽穆']='羽穆丶:BAAALgADCgUJBQAAAA==.',
['翠玉']='翠玉录:BAAALgAFFAEJAQAAAA==.',
['老汤']='老汤米线:BAAALgAECgMJAwAAAA==.',
['老衲']='老衲法号帅哥:BAAALgAECgEJAQAAAA==.',
['老龍']='老龍凤:BAABLgAFFH8GAAILAAMJdiUpCQBBAQALAAMJdiUpCQBBAQAAAA==.',
['考林']='考林:BAAALgAFFAQJAgAAAA==.',
['胖达']='胖达仁:BAAALgADCgMJAwAAAA==.',
['能不']='能不能打死我:BAAALgADCgIJAgAAAA==.',
['自愿']='自愿回归生活:BAACLgAFFH8HAAIEAAMJLR0KGwAbAQAEAAMJLR0KGwAbAQAuAAQKfxwAAwQABwmAHEAxAEcCAAQABwmAHEAxAEcCAAkAAQkAAHJtADoAAAAA.',
['自由']='自由丶之翼:BAAALgAECgQJBgAAAA==.',
['自闭']='自闭一整天:BAABLgAECn8UAAMZAAkJoCF6AgByAwAZAAkJoCF6AgByAwAjAAkJMha7AQBIAgAAAA==.',
['舒眉']='舒眉筛月影:BAAALgAECgYJDwAAAA==.',
['芒果']='芒果布丁:BAABLgAECn8VAAINAAgJkx5cBABPAgANAAgJkx5cBABPAgAAAA==.',
['苍小']='苍小弓:BAAALgAECgEJAQAAAA==.',
['茄子']='茄子肉末:BAAALgAECgYJBgAAAA==.',
['茜熙']='茜熙:BAABLgAFFH8HAAIGAAMJmA92EgDQAAAGAAMJmA92EgDQAAAAAA==.',
['茜茜']='茜茜:BAAALgADCgMJAwAAAA==.',
['荆棘']='荆棘女王萨莎:BAAALgAECgYJDwAAAA==.',
['草叢']='草叢裏啲蛤蟆:BAACLgAFFH8FAAICAAMJ5AYGMAD1AAACAAMJ5AYGMAD1AAAuAAQKfxwAAwIACAm3GgxSAEECAAIACAllGAxSAEECACUABgl5HP0EAHwBAAAA.',
['莉娜']='莉娜英巴斯:BAAALgADCgYJBgAAAA==.',
['莉莉']='莉莉雅丶弗丁:BAAALgAECgEJAgAAAA==.',
['莫布']='莫布兰:BAAALgAECgYJCgAAAA==.',
['菲伦']='菲伦:BAACLgAFFH8KAAMEAAMJNCDDHAASAQAEAAMJJxvDHAASAQAJAAEJSSTwDwBrAAAuAAQKfyMABAQACAnkI9UCAHECAAQABglUJdUCAHECAAkAAwnsEk8xAPQAAAgAAQkAABAhAG0AAAAA.',
['菲林']='菲林斯:BAAALgAFFAMJBAAAAA==.',
['萌多']='萌多多:BAACLgAFFH8FAAIOAAMJ3RX6CQARAQAOAAMJ3RX6CQARAQAuAAQKfxYAAw4ACAlzHwYbAGUCAA4ACAlzHwYbAGUCABsAAgkJDq97AFUAAAAA.',
['萌炸']='萌炸天丶:BAAALgAFFAIJAgAAAA==.',
['萌牛']='萌牛牛爱大米:BAAALgAECgQJBwAAAA==.',
['萌萌']='萌萌的皮蛋:BAACLgAFFH8GAAINAAMJIB0uIgAPAQANAAMJIB0uIgAPAQAuAAQKfyYAAw0ACAmtH1YFADMCAA0ACAmfH1YFADMCAAwAAQndI1U7AGoAAAAA.',
['营长']='营长意大利炮:BAAALgAECgUJBAAAAA==.',
['萧亞']='萧亞轩:BAAALgAECgEJAQAAAA==.',
['萧峰']='萧峰:BAAALgAECgYJBgAAAA==.',
['萨恩']='萨恩的锁链:BAACLgAFFH8HAAMgAAMJnhtxAgDgAAABAAMJ+BEDFgD7AAAgAAMJVhVxAgDgAAAuAAQKfygAAiAACAmSIPQCAPcCACAACAmSIPQCAPcCAAAA.',
['萨满']='萨满技师:BAAALgAECgYJBgAAAA==.萨满殁提斯:BAAALgADCgQJBAAAAA==.',
['萨碧']='萨碧尔:BAAALgAECgUJBQAAAA==.',
['葉丶']='葉丶小喬:BAAALgADCgYJBgAAAA==.',
['蒜仔']='蒜仔:BAAALgADCgcJBwAAAA==.',
['蓝兰']='蓝兰楠:BAAALgAECgQJBAAAAA==.',
['蕾娜']='蕾娜米丽洁:BAAALgAECgYJBgAAAA==.',
['虎牙']='虎牙:BAAALgADCgQJBAAAAA==.',
['蚝香']='蚝香猞猁面:BAAALgAECgEJAQAAAA==.',
['蛟龙']='蛟龙吐口水:BAAALgADCgEJAQAAAA==.',
['蜜幺']='蜜幺欧:BAAALgAECgIJAgAAAA==.',
['蝶舞']='蝶舞梦魂:BAAALgADCgEJAQAAAA==.',
['血夜']='血夜灵猎:BAACLgAFFH8GAAIOAAIJvg8qGQCjAAAOAAIJvg8qGQCjAAAuAAQKfxgAAw4ACAlVGSckAC0CAA4ACAlVGSckAC0CABsAAQkPFGSCAD0AAAAA.血夜魔猎:BAAALgAECgMJAwAAAA==.',
['被圣']='被圣光晒黑了:BAAALgAECgQJBQAAAA==.',
['被禁']='被禁锢的亡魂:BAAALgAECgcJDwAAAA==.',
['西瓜']='西瓜汁:BAAALgAECgUJBwAAAA==.',
['覆盖']='覆盖全球:BAACLgAFFH8IAAIGAAQJ/hkVBgBnAQAGAAQJ/hkVBgBnAQAuAAQKfx4AAhoACAkWHl4OAL0CABoACAkWHl4OAL0CAAAA.',
['语矜']='语矜者:BAAALgAECgQJCAAAAA==.',
['貌似']='貌似丶武神:BAAALgADCgQJBAAAAA==.',
['赛罗']='赛罗:BAAALgAECgEJAQAAAA==.',
['赫咔']='赫咔忒:BAAALgADCgUJBQAAAA==.',
['起名']='起名那会正烦:BAABLgAFFH8HAAINAAMJjhwLHwAgAQANAAMJjhwLHwAgAQAAAA==.',
['起步']='起步三壶:BAAALgAECgcJBwABLgAFFAYJBAAQAAAAAA==.',
['路易']='路易十:BAAALgADCgIJAgAAAA==.',
['踏破']='踏破红尘:BAACLgAFFH8FAAIBAAMJTBNHFQAAAQABAAMJTBNHFQAAAQAuAAQKfycAAgEACAlbIjUCAKECAAEACAlbIjUCAKECAAAA.',
['轉身']='轉身丨迪氪:BAAALgAECgQJDQAAAA==.',
['转圈']='转圈圈:BAAALgADCgkJCQAAAA==.',
['迈克']='迈克阿瑟:BAAALgADCgUJBQAAAA==.',
['追忆']='追忆香薰:BAAALgAFFAIJBAAAAA==.',
['追风']='追风大侠:BAAALgAECgcJCgAAAA==.',
['送葬']='送葬者伊:BAAALgAECgcJDAAAAA==.',
['逆袭']='逆袭之风:BAAALgAECgUJBQAAAA==.',
['遗忘']='遗忘之雨:BAAALgAECgYJBgAAAA==.遗忘之风:BAAALgAECgUJBgAAAA==.',
['邪恶']='邪恶电风扇:BAAALgADCgUJBQAAAA==.',
['醉舞']='醉舞红妆:BAAALgAECgIJAQAAAA==.',
['野女']='野女子丶:BAAALgADCgYJBgAAAA==.',
['钉崎']='钉崎野蔷薇:BAAALgAECgIJAQAAAA==.',
['钱难']='钱难赚史还行:BAAALgADCgEJAQAAAA==.',
['铁翼']='铁翼飞旋:BAABLgAECn8cAAIFAAgJ5Rh7DQCLAgAFAAgJ5Rh7DQCLAgAAAA==.',
['锡麟']='锡麟街流氓:BAAALgAECgMJAQAAAA==.',
['锤你']='锤你妹:BAAALgADCgUJBQAAAA==.',
['闪现']='闪现打击:BAAALgAECgcJDQAAAA==.',
['问远']='问远:BAACLgAFFH8GAAQeAAMJJRaRAwANAQAeAAMJJRaRAwANAQAdAAIJDA7RGQCiAAAfAAEJ4wQuEQA6AAAuAAQKfygAAx4ACAkZIMYDAMICAB4ACAnMHMYDAMICAB0ABwkwIcghAEYCAAEuAAUUBwkNAB8AzhkA.',
['阁下']='阁下胸肌浮夸:BAAALgADCgEJAQAAAA==.',
['阝可']='阝可灬占戈:BAAALgAECgYJCAAAAA==.',
['阳光']='阳光牛牛:BAAALgAECgEJAQAAAA==.',
['阿克']='阿克杰瑞:BAAALgAECgQJBAAAAA==.',
['阿公']='阿公偏头痛:BAAALgAECgEJAQAAAA==.',
['阿尓']='阿尓忒尼斯:BAAALgAECgMJAwAAAA==.',
['阿库']='阿库玛芮妮:BAAALgAECgYJBwABLgAFFAMJBwAVAGsZAA==.',
['陆丶']='陆丶漓泉啤酒:BAAALgAECggJDQAAAA==.',
['陌夏']='陌夏残年:BAAALgAFFAIJBAAAAA==.',
['陸書']='陸書語:BAAALgADCgUJBQAAAA==.',
['雨倾']='雨倾城:BAAALgAECgEJAgAAAA==.',
['零号']='零号圣骑:BAAALgAFFAQJAQAAAA==.零号萨:BAAALgAECgEJAQAAAA==.',
['雷音']='雷音猎:BAAALgADCgIJAgAAAA==.',
['霜颅']='霜颅丨疫鬃:BAAALgAECgEJAQAAAA==.',
['霹雳']='霹雳豆仔:BAAALgAECgcJBwAAAA==.',
['青野']='青野:BAAALgAECgYJEwAAAA==.',
['靓坤']='靓坤:BAAALgADCgMJAwAAAA==.',
['非常']='非常可乐:BAAALgAECgMJBgAAAA==.',
['非洲']='非洲一朵花:BAAALgAECgMJAwAAAA==.',
['音無']='音無小夜:BAAALgAFFAQJBAAAAA==.',
['风中']='风中残叶:BAAALgAECgYJBwAAAA==.',
['风云']='风云:BAAALgADCgEJAQAAAA==.',
['香菜']='香菜牛肉:BAAALgAECgEJAQAAAA==.',
['魔之']='魔之小奇:BAABLgAFFH8JAAIBAAMJGhJ6FgD4AAABAAMJGhJ6FgD4AAAAAA==.',
['鱼虾']='鱼虾袋子定做:BAAALgAFFAIJAgAAAA==.',
['鲁小']='鲁小师:BAAALgADCgUJBQAAAA==.',
['鳪鸫']='鳪鸫:BAAALgAECgMJBAAAAA==.',
['鸡肉']='鸡肉味的旋律:BAABLgAECn8VAAMEAAcJ4glWlQAuAQAEAAcJ4glWlQAuAQAJAAEJgwNifAAjAAAAAA==.',
['鹤舞']='鹤舞霜华袖:BAAALgAECgYJBwAAAA==.',
['黄兰']='黄兰楠:BAAALgAECgIJAwAAAA==.',
['黑桑']='黑桑凤梨:BAAALgAECgcJBwAAAA==.',
['黑爪']='黑爪子:BAAALgADCgEJAQAAAA==.',
['黑锋']='黑锋大领主:BAAALgAECgQJCQAAAA==.',
['默尘']='默尘丶:BAAALgAFFAIJAgAAAA==.默尘丶丶:BAACLgAFFH8GAAIUAAIJNxLbCACwAAAUAAIJNxLbCACwAAAuAAQKfxcAAhQACAk/GWMTAH0CABQACAk/GWMTAH0CAAAA.',
['齁盐']='齁盐丶五齿:BAABLgAFFH8GAAIkAAIJ4hoqDwCoAAAkAAIJ4hoqDwCoAAAAAA==.',
['龍在']='龍在天涯:BAAALgAECgQJBAAAAA==.',
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
