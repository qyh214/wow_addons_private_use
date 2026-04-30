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

local lookup = {'Mage-Frost','Warlock-Demonology','Warlock-Destruction','Unknown-Unknown','Monk-Brewmaster','Warrior-Fury','Paladin-Protection','Paladin-Retribution','Paladin-Holy','Shaman-Elemental','Shaman-Restoration','Evoker-Augmentation','Priest-Shadow','Monk-Windwalker','Shaman-Enhancement','DeathKnight-Unholy','DeathKnight-Blood','Druid-Restoration','Druid-Balance','Druid-Guardian','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Priest-Holy',}
local provider = {region='CN',realm='死亡熔炉',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ae='Aee:BAAALgADCgYJBgAAAA==.',
Ak='Akunn:BAAALgAFFAEJAQAAAA==.',
Bi='Bierhoff:BAAALgAECgYJCAAAAA==.',
Br='Bridegroom:BAAALgAECgMJAwAAAA==.',
Ch='Charlemagne:BAAALgAECgYJBwAAAA==.',
Co='Cocoanuts:BAABLgAFFH8FAAIBAAIJkxZXOQC3AAABAAIJkxZXOQC3AAAAAA==.',
Cr='Cronusy:BAAALgAECgYJBgAAAA==.',
Dk='Dk:BAAALgAECggJEgAAAA==.',
Es='Esven:BAAALgAECgIJAgAAAA==.',
Fi='Fiona:BAAALgAECgYJDAAAAA==.',
Gi='Gilgameshs:BAAALgAECgYJBwAAAA==.',
Ir='Ironraven:BAAALgAECgMJAwAAAA==.',
Iv='Ivever:BAABLgAECn8XAAIBAAYJrhnJowCQAQABAAYJrhnJowCQAQAAAA==.',
Ja='Jackblack:BAAALgAECgYJBgAAAA==.',
Jo='Jojo:BAAALgAECgIJAgAAAA==.',
Li='Lilitwo:BAAALgADCgYJDQAAAA==.',
Mo='Mortis:BAAALgAECgEJAQAAAA==.',
Na='Naremdul:BAAALgAECgEJAQAAAA==.',
Ni='Nichousha:BAAALgADCgQJBAAAAA==.',
Pl='Playerelzocn:BAAALgADCgEJAQAAAA==.',
Sc='Schizophrene:BAAALgAECgcJDgAAAA==.',
Ss='Ssz:BAABLgAFFH8NAAMCAAcJ8R+qCgCHAQACAAYJPR2qCgCHAQADAAMJAiGICQC/AAAAAA==.',
['一只']='一只花來榴:BAAALgAECgMJAwAAAA==.',
['一斤']='一斤橙虾:BAAALgAECgMJBAAAAA==.',
['一机']='一机灵:BAAALgAECgIJAgAAAA==.',
['一首']='一首战歌:BAAALgAECgYJCQAAAA==.',
['七名']='七名:BAAALgAECgQJBQAAAA==.',
['万法']='万法:BAAALgAECgQJBAAAAA==.',
['三千']='三千大世界:BAAALgAECgkJCQAAAA==.',
['不缺']='不缺圣光:BAAALgADCgQJBAAAAA==.',
['不要']='不要再打啦:BAABLgAFFH8IAAIBAAQJNSA/EwB/AQABAAQJNSA/EwB/AQABLgAFFAUJBAAEAAAAAA==.',
['丶小']='丶小刘:BAAALgAECgYJCwAAAA==.',
['丶蹦']='丶蹦蹦跳跳:BAAALgAFFAEJAQAAAA==.',
['丿大']='丿大威天龍:BAABLgAECn8VAAIFAAcJXxyKHwAGAgAFAAcJXxyKHwAGAgAAAA==.',
['之祠']='之祠:BAAALgADCgEJAQAAAA==.',
['亚托']='亚托克斯:BAAALgAFFAEJAQAAAA==.',
['亚洲']='亚洲舞王赵四:BAAALgAECgEJAQAAAA==.',
['你吃']='你吃不吃薯片:BAAALgAECgYJCgAAAA==.',
['你石']='你石哥:BAAALgAECgUJBQAAAA==.',
['侠之']='侠之幻影:BAAALgAECgkJEAAAAA==.',
['六必']='六必居士:BAAALgAECgQJCQAAAA==.',
['六眼']='六眼飞鱼:BAAALgAECgIJBAAAAA==.',
['养猪']='养猪丨丨大户:BAAALgAFFAIJAgAAAA==.',
['兽王']='兽王猎:BAAALgAECgEJAQAAAA==.',
['再见']='再见牛栏山:BAAALgAECgYJBgAAAA==.',
['冥中']='冥中:BAAALgAECgUJCAAAAA==.',
['冫陈']='冫陈抟:BAAALgAECgQJBAAAAA==.',
['冰焰']='冰焰幻成魔:BAAALgAECgYJBQAAAA==.',
['冷冷']='冷冷夜:BAAALgAECgIJAwAAAA==.',
['凑合']='凑合活着:BAAALgAECgYJCgAAAA==.',
['力量']='力量的化身:BAAALgAECgcJEAAAAA==.',
['功夫']='功夫大熊猫:BAAALgAECgkJCQABLgAFFAUJBQAGAIAYAA==.',
['匪气']='匪气的梦游:BAAALgAECgUJDAAAAA==.',
['单曲']='单曲:BAACLgAFFH8IAAMHAAMJaBSlAgDWAAAHAAMJaBSlAgDWAAAIAAIJdRV/KgCHAAAuAAQKfyMABAgACAl+Hy48ADMCAAgACAmgHi48ADMCAAcABgmuHFIRALIBAAkABAlNDrNuAL8AAAAA.',
['原始']='原始天尊:BAACLgAFFH8LAAIKAAQJhxw1AwBBAQAKAAQJhxw1AwBBAQAuAAQKfxQAAgoABwmoIXoQAKQCAAoABwmoIXoQAKQCAAAA.',
['双鱼']='双鱼座小牛:BAAALgAECggJEAAAAA==.',
['叛逆']='叛逆之吻:BAAALgAECgEJAQAAAA==.',
['只冷']='只冷冻不保鲜:BAABLgAECn8UAAIBAAgJsBCueADgAQABAAgJsBCueADgAQAAAA==.',
['哇塞']='哇塞的挺自然:BAAALgAECgYJCAAAAA==.',
['哈里']='哈里波特别大:BAAALgAECgUJBgAAAA==.',
['唉末']='唉末替:BAAALgAECgIJAgAAAA==.',
['啊啊']='啊啊噢哦阿:BAACLgAFFH8HAAMKAAMJyBOEDwD4AAAKAAMJyBOEDwD4AAALAAEJwiFNHgBiAAAuAAQKfyQAAwsACAksF0kgAB0CAAsACAksF0kgAB0CAAoABgkQFX0SAOwAAAAA.',
['喵喵']='喵喵法:BAACLgAFFH8GAAIBAAMJrw5XLgD9AAABAAMJrw5XLgD9AAAuAAQKfxQAAgEABwmKGRFsAP0BAAEABwmKGRFsAP0BAAAA.',
['嗜洫']='嗜洫兲芐啉啉:BAAALgADCgEJAQAAAA==.',
['嗜血']='嗜血灬嚣张:BAAALgAECgUJBQAAAA==.',
['嗷呜']='嗷呜丶:BAABLgAFFH8KAAIMAAUJ+AfvBQArAQAMAAUJ+AfvBQArAQAAAA==.',
['嘿嘿']='嘿嘿灬:BAAALgAECgUJBQAAAA==.',
['圣光']='圣光好好:BAAALgAFFAMJBAAAAA==.',
['圣徒']='圣徒月歌:BAAALgADCgUJBQAAAA==.圣徒雅歌丶:BAAALgADCgEJAQAAAA==.',
['圣洁']='圣洁再临:BAAALgAECgMJAwAAAA==.圣洁大领主:BAAALgAECgcJDAAAAA==.',
['堕落']='堕落的小爱:BAABLgAFFH8GAAINAAIJzQyWDwCoAAANAAIJzQyWDwCoAAAAAA==.',
['墨影']='墨影禅师:BAAALgADCgMJAwAAAA==.',
['士官']='士官长:BAAALgAFFAIJAgAAAA==.',
['夜伴']='夜伴二锅头:BAAALgAECgYJCQAAAA==.',
['大哥']='大哥骑士:BAAALgAECgEJAQAAAA==.',
['大大']='大大超人:BAABLgAFFH8JAAIFAAUJ6xTABQB3AQAFAAUJ6xTABQB3AQAAAA==.',
['大威']='大威天龍:BAAALgAECgcJDgAAAA==.',
['大锤']='大锤仈拾:BAAALgAECgUJBQAAAA==.',
['如此']='如此肆意妄为:BAAALgAECgcJBgABLgAFFAcJBwADAE0eAA==.',
['孤云']='孤云烟客:BAABLgAFFH8IAAIOAAQJwQHqCADlAAAOAAQJwQHqCADlAAAAAA==.',
['審判']='審判之翼:BAAALgADCgcJBwAAAA==.',
['射狂']='射狂:BAAALgADCgQJBAAAAA==.',
['小丶']='小丶楼:BAAALgAECgYJBgAAAA==.',
['小贰']='小贰黑:BAAALgAECgQJBAAAAA==.',
['小黑']='小黑人儿:BAAALgAECgIJAgAAAA==.',
['小龍']='小龍人儿:BAAALgADCgEJAQAAAA==.',
['尐样']='尐样儿:BAAALgAECgEJAQAAAA==.',
['尼姑']='尼姑妹妹:BAACLgAFFH8MAAIOAAQJww7nBABAAQAOAAQJww7nBABAAQAuAAQKfyQAAg4ACAmZH5kHAAIDAA4ACAmZH5kHAAIDAAAA.',
['巳剑']='巳剑:BAACLgAFFH8NAAIKAAUJZB35AgDDAQAKAAUJZB35AgDDAQAuAAQKfx8AAwoACQnSILgKAOsCAAoACQnSILgKAOsCAA8ABgnlD9EWAFMBAAAA.',
['幽狱']='幽狱:BAAALgAECgEJAQAAAA==.',
['弹壳']='弹壳:BAAALgAECgIJAwAAAA==.',
['往事']='往事随風:BAAALgAECgcJDQAAAA==.',
['怎么']='怎么回事:BAABLgAFFH8RAAMQAAcJgyD2AgDbAQAQAAYJgyD2AgDbAQARAAEJAAA8GwAvAAAAAA==.怎么梳都卷:BAACLgAFFH8IAAIGAAMJjATSEwDfAAAGAAMJjATSEwDfAAAuAAQKfywAAgYACAmVFYghAEcCAAYACAmVFYghAEcCAAAA.怎么梳都菤:BAAALgADCgEJAQABLgAFFAMJCAAGAIwEAA==.',
['恬静']='恬静怀古:BAABLgAFFH8GAAISAAIJHQqhHQCGAAASAAIJHQqhHQCGAAAAAA==.',
['悟念']='悟念吾心:BAABLgAECn8UAAMLAAcJtB6kFgBhAgALAAcJtB6kFgBhAgAKAAYJ5hT5NQB9AQAAAA==.',
['我是']='我是圣骑士:BAAALgADCgUJBQAAAA==.',
['我爱']='我爱萌萌:BAAALgAECgIJAgAAAA==.',
['我谓']='我谓主宰:BAAALgADCgEJAQAAAA==.',
['执法']='执法如山:BAABLgAFFH8LAAIBAAUJvRwyCwDEAQABAAUJvRwyCwDEAQAAAA==.',
['挥汗']='挥汗如雨:BAAALgAECgYJBgAAAA==.',
['无敌']='无敌电灯泡:BAAALgAECgQJBQAAAA==.',
['无聊']='无聊的萨满:BAAALgAECgEJAQAAAA==.',
['星期']='星期巴:BAABLgAFFH8FAAIIAAIJOBVsKgCIAAAIAAIJOBVsKgCIAAAAAA==.',
['星空']='星空棒棒糖:BAABLgAECn8aAAICAAcJ6xpcMgBCAgACAAcJ6xpcMgBCAgAAAA==.',
['智爷']='智爷:BAAALgAECgQJBAAAAA==.',
['智高']='智高无上:BAAALgAECgEJAQAAAA==.',
['暴击']='暴击才是王道:BAAALgAECgIJAgAAAA==.',
['暴橙']='暴橙子:BAAALgAECgUJBQAAAA==.',
['有事']='有事偷着乐:BAAALgAECgcJBwAAAA==.有事偷着笑:BAAALgAECgYJCgAAAA==.',
['术不']='术不远送:BAAALgAECgYJDAAAAA==.',
['术了']='术了个士:BAAALgAECgcJEQAAAA==.',
['来生']='来生:BAAALgAFFAEJAQAAAA==.',
['某白']='某白:BAAALgAFFAEJAQAAAA==.',
['树士']='树士:BAAALgAECgEJAQAAAA==.',
['桂熙']='桂熙:BAAALgAECgIJAgAAAA==.',
['梦安']='梦安魂于九霄:BAAALgAECgEJAwAAAA==.',
['梦梦']='梦梦的小相公:BAABLgAECn8VAAMJAAcJuB/nAQCQAgAJAAcJuB/nAQCQAgAIAAcJQBoYPAAzAgAAAA==.梦梦的老公:BAAALgAECgQJCAAAAA==.',
['毛喷']='毛喷喷:BAAALgAECgYJCQAAAA==.',
['水墨']='水墨丹青:BAAALgAECgUJBQAAAA==.',
['永生']='永生神皇:BAAALgAECgEJAgAAAA==.',
['没事']='没事就下线:BAAALgAECgcJEwAAAA==.',
['没烟']='没烟啦:BAAALgADCgEJAQAAAA==.',
['沾血']='沾血紫薇:BAAALgADCgEJAQAAAA==.',
['法师']='法师:BAAALgAFFAUJBAABLgAFFAcJCgACAPQTAA==.',
['流云']='流云开一朵丶:BAAALgAFFAEJAQABLgAFFAYJFQATAHIhAA==.',
['流雲']='流雲:BAAALgAECgYJBgABLgAFFAQJBwACAPscAA==.',
['海坑']='海坑真是坑:BAAALgAECgcJDAAAAA==.',
['深寒']='深寒:BAAALgADCgMJBAAAAA==.',
['淺色']='淺色紙鳶:BAAALgAECgEJAgAAAA==.',
['満滿']='満滿的恛憶:BAAALgAECgQJBQAAAA==.',
['滴滴']='滴滴的牛牛:BAAALgAECgQJBwAAAA==.',
['火车']='火车侠:BAABLgAFFH8GAAISAAYJfCJsAABzAgASAAYJfCJsAABzAgAAAA==.',
['灰烬']='灰烬:BAAALgADCgMJAwAAAA==.',
['灰狐']='灰狐:BAAALgAECgYJCgAAAA==.',
['爱上']='爱上灬春天:BAAALgADCgEJAQAAAA==.',
['狐狸']='狐狸海星:BAAALgADCgYJBgAAAA==.',
['玉瀧']='玉瀧:BAAALgADCgYJBgAAAA==.',
['玥夜']='玥夜清风:BAAALgAECgYJCwAAAA==.',
['疯脸']='疯脸:BAAALgAECgUJBwAAAA==.',
['疯誑']='疯誑小虾米:BAAALgAECgYJDAAAAA==.',
['白的']='白的香的:BAAALgAECgQJBQAAAA==.',
['相剑']='相剑:BAAALgAECgYJCQAAAA==.',
['石总']='石总有理想:BAAALgAECgYJCgAAAA==.',
['磐石']='磐石丨麦德安:BAABLgAECn8UAAQTAAYJIRNIQQAsAQATAAUJjxdIQQAsAQASAAMJVAgltABcAAAUAAEJawGvOwAOAAAAAA==.',
['神圣']='神圣风暴:BAAALgAECgYJBgAAAA==.',
['神官']='神官:BAAALgAECgYJDgAAAA==.',
['科学']='科学:BAAALgAECgkJCQAAAA==.',
['管子']='管子罐子铁子:BAAALgAECgEJAQAAAA==.',
['素尘']='素尘:BAAALgAECgEJAQAAAA==.',
['素雪']='素雪:BAAALgAECgUJCgAAAA==.',
['绚岚']='绚岚:BAAALgADCgUJBQAAAA==.',
['维权']='维权企鹅:BAAALgAECgcJCQAAAA==.',
['维生']='维生:BAAALgAECgQJBQAAAA==.',
['老和']='老和:BAAALgAECgUJCgAAAA==.',
['老猎']='老猎:BAAALgADCgIJAgAAAA==.',
['脸滚']='脸滚键的教父:BAABLgAECn8WAAQIAAgJshfCYADCAQAIAAgJJhfCYADCAQAJAAUJ8wQHdgCiAAAHAAEJuBcAAAAAAAAAAA==.',
['臭认']='臭认真:BAABLgAECn8WAAIQAAgJ1BA2VAD1AQAQAAgJ1BA2VAD1AQAAAA==.',
['荣耀']='荣耀的圣剑:BAAALgAECgIJAgAAAA==.',
['莫逆']='莫逆丶烈与霜:BAAALgADCgYJBgAAAA==.',
['莽小']='莽小五:BAACLgAFFH8KAAIFAAMJ8BmbEQDvAAAFAAMJ8BmbEQDvAAAuAAQKfxsAAwUABwnlG3kgAP0BAAUABglPH3kgAP0BAA4AAQnPCl57ADUAAAAA.',
['華彫']='華彫風月:BAAALgAECgEJAQAAAA==.',
['葡萄']='葡萄丨柚子茶:BAAALgAECgEJAQAAAA==.',
['蘇小']='蘇小喵:BAAALgAECgQJBQAAAA==.',
['虽然']='虽然但是:BAAALgADCgUJBQAAAA==.',
['言肃']='言肃:BAAALgAECgYJBgAAAA==.',
['訫無']='訫無雜鲶:BAAALgAECgEJBAAAAA==.',
['谁在']='谁在雨中哭泣:BAAALgAFFAEJAQAAAA==.',
['超超']='超超级赛亞人:BAAALgADCgEJAQAAAA==.',
['蹄里']='蹄里奥:BAAALgADCgcJBwAAAA==.',
['逝去']='逝去的瓦里安:BAAALgAECgEJAQAAAA==.',
['郭龙']='郭龙凤:BAAALgAECgUJBQAAAA==.',
['镰刀']='镰刀和锤子:BAAALgAECgUJCAAAAA==.',
['长春']='长春丶吴彦祖:BAAALgADCgUJBQAAAA==.长春丶陳冠熙:BAAALgAECgUJBQAAAA==.',
['长歌']='长歌松:BAAALgAECgYJCQAAAA==.',
['除非']='除非包吃包住:BAAALgAECgQJBAAAAA==.',
['陶然']='陶然若梦:BAABLgAFFH8GAAMVAAQJHB2mAQCKAQAVAAQJHB2mAQCKAQAWAAEJuQ1yJgBQAAAAAA==.',
['雨凡']='雨凡:BAACLgAFFH8IAAIXAAMJpBLiDQDuAAAXAAMJpBLiDQDuAAAuAAQKfxcABBcABwnyFZsZAMwBABcABwnvFZsZAMwBABgAAwleEABlAJkAAA0AAQllCvBfADgAAAAA.',
['霸道']='霸道小民爷:BAAALgAECgIJAwAAAA==.',
['青涩']='青涩后妈:BAAALgAECgUJBQAAAA==.',
['饮月']='饮月灬:BAABLgAFFH8FAAILAAUJdRecAgC4AQALAAUJdRecAgC4AQAAAA==.',
['骑着']='骑着小萨摩:BAABLgAFFH8RAAIWAAcJUyChAQBqAgAWAAcJUyChAQBqAgAAAA==.',
['高贵']='高贵的冰迪克:BAAALgAECgYJBAAAAA==.',
['魔鬼']='魔鬼筋肉人:BAAALgADCgQJBAAAAA==.',
['鸟蛤']='鸟蛤咯咯哒:BAAALgAECgUJBQAAAA==.',
['麦当']='麦当当:BAAALgAECgQJBQAAAA==.',
['黑之']='黑之末日:BAAALgAECgUJDQAAAA==.',
['默默']='默默不语:BAAALgAECgYJCAAAAA==.',
['齐宣']='齐宣王田辟疆:BAAALgAECgcJCwAAAA==.',
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
