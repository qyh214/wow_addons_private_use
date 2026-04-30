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

local lookup = {'Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','Priest-Discipline','Priest-Holy','DeathKnight-Unholy','Unknown-Unknown','Paladin-Retribution','Paladin-Protection','DemonHunter-Havoc','Warlock-Demonology','Mage-Frost','DemonHunter-Devourer','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Affliction','Paladin-Holy','Monk-Brewmaster','Monk-Mistweaver','Druid-Balance','Mage-Fire','Warrior-Fury','DeathKnight-Blood','Druid-Feral','Priest-Shadow','Druid-Restoration','Shaman-Restoration','Shaman-Elemental','Monk-Windwalker','Warrior-Protection','Rogue-Subtlety','Warlock-Destruction','Hunter-Survival','Warrior-Arms',}
local provider = {region='CN',realm='万色星辰',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Ado:BAAALgADCgIJAgAAAA==.',
Al='Alando:BAAALgAECgMJAwAAAA==.Althyk:BAAALgAFFAMJAwAAAA==.',
An='Anna:BAAALgAECgUJBQAAAA==.',
As='Assumi:BAAALgAECgQJBAAAAA==.',
Bl='Bloodmary:BAAALgAECgYJCgAAAA==.',
Bo='Bo:BAAALgAECgEJAQAAAA==.',
Ca='Caldorei:BAACLgAFFH8GAAIBAAMJHRF7DgDuAAABAAMJHRF7DgDuAAAuAAQKfx0ABAIACAl1GfYHAGkCAAIACAnUGPYHAGkCAAMACAmaEI8bAOwBAAEAAQkVCpFJAC8AAAAA.',
Co='Costel:BAABLgAFFH8FAAMEAAIJJhFUEwCbAAAEAAIJgRBUEwCbAAAFAAEJ7w4AAAAAAAAAAA==.',
Da='Darktimes:BAAALgADCgcJBwABLgAFFAQJEAAGAP0eAA==.',
Dc='Dcarian:BAAALgAECgEJAQAAAA==.',
De='Deaniter:BAAALgAECgEJAQAAAA==.Demii:BAAALgAECgQJBQAAAA==.Denomo:BAAALgAECgMJBQAAAA==.',
Dl='Dlndk:BAAALgADCgYJBgAAAA==.',
Do='Doripuff:BAAALgAECgYJBgAAAA==.',
Dr='Draestrellas:BAAALgAECgcJBwAAAA==.Drama:BAAALgADCgYJCQAAAA==.',
Es='Ess:BAAALgAECgQJBAAAAA==.',
Eu='Europa:BAAALgAFFAQJBAAAAA==.',
Fl='Fluffy:BAAALgAECgEJAQABLgAECgUJBQAHAAAAAA==.',
Fu='Fullhouse:BAAALgAFFAEJAQAAAA==.',
Gi='Girlbandcry:BAAALgAECgEJAQAAAA==.',
He='Heartu:BAAALgAECgcJDAAAAA==.',
In='Indigowhite:BAABLgAECn8aAAMIAAgJux7nKQB9AgAIAAgJux7nKQB9AgAJAAEJ6QhERAAuAAAAAA==.',
Iu='Iusih:BAAALgAFFAEJAQAAAA==.',
Ma='Magic:BAAALgAECgkJCQAAAA==.Magicx:BAAALgAECgYJDQAAAA==.',
Mi='Miaryzo:BAAALgAECgIJAgAAAA==.Midori:BAABLgAECn8fAAMBAAgJ3Bj9EQAeAgABAAgJ3Bj9EQAeAgADAAcJlBboHADfAQAAAA==.Minapapa:BAAALgADCgUJBQAAAA==.',
No='Noonmoon:BAAALgAFFAIJAgAAAA==.',
Ob='Oblivionis:BAABLgAFFH8FAAIIAAIJuBTyIwCkAAAIAAIJuBTyIwCkAAAAAA==.',
Pa='Panini:BAABLgAFFH8NAAIGAAQJyiEkCACQAQAGAAQJyiEkCACQAQAAAA==.Pato:BAAALgAECgcJBgAAAA==.',
Pg='Pgwjh:BAAALgAECgUJCQAAAA==.',
Ph='Phage:BAABLgAECn8XAAIKAAcJChXOBQBkAQAKAAcJChXOBQBkAQAAAA==.',
Ri='Riddlek:BAABLgAFFH8FAAILAAMJ5RzVCgAfAQALAAMJ5RzVCgAfAQAAAA==.',
Ru='Ruinlol:BAAALgAECgMJAwAAAA==.',
Sl='Sleepwalking:BAAALgAECgYJEAAAAA==.',
Sm='Smallgirl:BAAALgAECgEJAQAAAA==.',
So='Solcatt:BAAALgAECgYJBgAAAA==.Songofdeath:BAAALgAECgYJDwABLgAFFAYJGAAIANYaAA==.',
Su='Sua:BAAALgAFFAQJBAAAAA==.',
Ti='Timelessws:BAAALgAECgkJAgAAAA==.Timelessxt:BAAALgAECgkJBQAAAA==.',
To='Toonagoni:BAABLgAFFH8FAAIMAAIJyRnwNQC/AAAMAAIJyRnwNQC/AAAAAA==.',
Va='Vally:BAAALgADCgYJBgAAAA==.',
Wa='Wanyerhert:BAAALgAECggJCgAAAA==.',
Wk='Wk:BAAALgADCgUJBQAAAA==.',
Ye='Yeah:BAABLgAFFH8HAAIGAAQJ/BV2EQBbAQAGAAQJ/BV2EQBbAQAAAA==.Yerell:BAAALgAECgcJEgAAAA==.',
Yt='Ytdbb:BAABLgAFFH8FAAINAAIJsBpsJACtAAANAAIJsBpsJACtAAABLgAFFAQJCQALAHkbAA==.',
Yu='Yuumi:BAAALgAFFAEJAQAAAA==.',
Yy='Yyh:BAABLgAFFH8IAAIIAAQJkRWlAwBeAQAIAAQJkRWlAwBeAQAAAA==.',
['一刀']='一刀和刀刀:BAAALgAECgUJBQAAAA==.',
['一叶']='一叶知秋丶:BAABLgAFFH8LAAMOAAQJwhr2CAD4AAAOAAQJKBT2CAD4AAAPAAIJeBmQGQC5AAAAAA==.',
['一灰']='一灰烬使者一:BAAALgAFFAUJAwAAAA==.',
['七月']='七月七:BAAALgAECgEJAQAAAA==.',
['七濑']='七濑悠月:BAAALgAECgcJCAAAAA==.',
['万魔']='万魔归一:BAAALgAECgEJAQAAAA==.',
['三千']='三千情诗:BAAALgAECgYJCQAAAA==.',
['下午']='下午茶:BAAALgAFFAEJAQAAAA==.',
['不是']='不是哥们儿:BAAALgAECgUJBQAAAA==.不是雨天:BAAALgAECgcJBwAAAA==.',
['与夜']='与夜共来:BAAALgAECgYJBgAAAA==.',
['丨上']='丨上帝光头丨:BAABLgAFFH8FAAIQAAMJIBSUAAAaAQAQAAMJIBSUAAAaAQAAAA==.',
['丨泡']='丨泡泡糖丨:BAAALgAECgYJEAAAAA==.',
['丨深']='丨深深怀念丨:BAAALgADCgQJBAAAAA==.',
['丨紫']='丨紫丶小薇:BAAALgAECgUJBQAAAA==.',
['丨胧']='丨胧寐丨:BAAALgAECgIJAgAAAA==.',
['丨逮']='丨逮虾户丨:BAAALgADCgcJBwAAAA==.',
['丫丫']='丫丫:BAABLgAECn8WAAMRAAcJJCQlCgDSAgARAAcJJCQlCgDSAgAIAAYJxREZKAAEAQAAAA==.',
['丶安']='丶安东尼达斯:BAAALgAECgYJBgAAAA==.',
['丷福']='丷福生:BAAALgAECgQJBwAAAA==.',
['为己']='为己:BAAALgADCgEJAQAAAA==.',
['丿風']='丿風行灬雅:BAAALgAECgkJDAAAAA==.',
['乄圣']='乄圣:BAAALgADCgIJAgAAAA==.',
['义父']='义父:BAAALgAECgEJAgAAAA==.',
['二宮']='二宮飛鳥:BAAALgAECgUJEQAAAA==.',
['二红']='二红袖添乱二:BAAALgAECgMJAwAAAA==.',
['二阶']='二阶堂希罗:BAAALgADCgQJBAAAAA==.',
['云汐']='云汐:BAAALgAFFAEJAQAAAA==.',
['云游']='云游者丨彼得:BAACLgAFFH8PAAISAAQJNRrAAwBFAQASAAQJNRrAAwBFAQAuAAQKfx8AAxIABwksItoPAJ4CABIABwksItoPAJ4CABMAAQn1CYZsACoAAAAA.',
['五百']='五百个法丝:BAAALgAECgcJEQAAAA==.',
['亮劍']='亮劍:BAAALgAFFAIJAwAAAA==.',
['亲我']='亲我叫我老公:BAACLgAFFH8HAAMOAAIJ9xFPFwCpAAAOAAIJ9xFPFwCpAAAPAAIJbwFIIgB+AAAuAAQKfxoAAw8ACAmNF/cfACMCAA8ACAlhFPcfACMCAA4ABAmkGEE1AGoAAAAA.',
['今晚']='今晚月色很美:BAAALgADCgYJBgAAAA==.',
['仑伐']='仑伐替尼:BAAALgAECgIJAwAAAA==.',
['仓鼠']='仓鼠不发电:BAAALgAECgEJAQAAAA==.',
['代号']='代号穿山甲:BAAALgAECgUJBQABLgAFFAMJBAAHAAAAAA==.',
['仪剑']='仪剑江湖:BAAALgAECgIJAgAAAA==.',
['伊利']='伊利单怒风:BAAALgAFFAQJBAAAAA==.',
['伊德']='伊德莉拉:BAAALgAECgUJBQAAAA==.',
['伊芙']='伊芙林:BAAALgAECgkJAgAAAA==.',
['伞木']='伞木希美:BAAALgAECggJEQABLgAFFAUJDgAUAKMmAA==.',
['伤害']='伤害加倍:BAABLgAECn8XAAMMAAgJmhFLZgALAgAMAAgJmhFLZgALAgAVAAEJagPcEQAkAAAAAA==.',
['伤心']='伤心的舵手:BAAALgAECgUJCgAAAA==.',
['伯朗']='伯朗咖啡:BAAALgAECgcJDAABLgAECgkJCQAHAAAAAA==.',
['佐伊']='佐伊纳尔:BAAALgAECgIJAgAAAA==.',
['余香']='余香萦袖:BAAALgAECgkJBwAAAA==.',
['佛系']='佛系少牛:BAAALgAECgEJAQABLgAFFAQJEAAGAP0eAA==.',
['你看']='你看那天多蓝:BAAALgAECgYJEAAAAA==.你看那草多绿:BAAALgAECgQJBAAAAA==.',
['佳佳']='佳佳才是大王:BAAALgADCgMJAwAAAA==.',
['依零']='依零:BAAALgAFFAEJAQAAAA==.',
['俺寻']='俺寻思之力:BAAALgAECgUJBQAAAA==.',
['傅文']='傅文佩:BAAALgAECgMJAwABLgAECggJHAAOAAAgAA==.',
['僧猫']='僧猫:BAAALgAFFAIJAwAAAA==.',
['光誓']='光誓影耀:BAAALgAECgMJAwAAAA==.',
['光铸']='光铸牛牛:BAAALgAECgEJAQAAAA==.',
['全知']='全知全能之树:BAABLgAFFH8KAAIBAAYJhwslCwA4AQABAAYJhwslCwA4AQAAAA==.',
['全自']='全自动早餐机:BAAALgAECgcJEQAAAA==.',
['兰霍']='兰霍特:BAAALgADCgcJBwAAAA==.',
['兽性']='兽性狂飙乄:BAAALgAECgEJAQAAAA==.',
['冒险']='冒险者号:BAAALgAECgEJAQAAAA==.',
['军团']='军团无敌武僧:BAAALgAECgMJAwAAAA==.',
['冬至']='冬至坚宝:BAAALgADCgYJBgAAAA==.',
['冬虫']='冬虫夏草:BAAALgADCgUJBQABLgAECgcJCwAHAAAAAA==.',
['冰冻']='冰冻我的心:BAABLgAFFH8FAAIMAAMJVhTJKQANAQAMAAMJVhTJKQANAQABLgAFFAYJGAAIANYaAA==.',
['冰凌']='冰凌盛夏:BAAALgAFFAIJAwAAAA==.',
['冰沁']='冰沁紫语:BAAALgAFFAIJAgAAAA==.',
['冰鲜']='冰鲜的黄花蟹:BAAALgADCgEJAQAAAA==.',
['冷光']='冷光:BAAALgAECgEJAQABLgAECgQJBAAHAAAAAA==.',
['出山']='出山:BAAALgAECgQJBAAAAA==.',
['刀丶']='刀丶锋:BAAALgADCgMJAwAAAA==.',
['分劣']='分劣:BAAALgAECgEJAQAAAA==.',
['别说']='别说话刎我:BAAALgAECgYJBgAAAA==.',
['别问']='别问法力残渣:BAAALgAECgYJBwABLgAFFAcJHAAMAKwbAA==.',
['剧本']='剧本:BAAALgAECgEJAQAAAA==.',
['北冥']='北冥都天剑:BAAALgAECgEJAQAAAA==.',
['北风']='北风呼啸:BAAALgAECgcJDAAAAA==.',
['十字']='十字军:BAAALgADCgYJBgAAAA==.十字心:BAAALgAECgYJBgAAAA==.',
['十殿']='十殿阎罗:BAAALgAECgMJAwAAAA==.',
['十进']='十进制:BAABLgAECn8UAAIWAAcJ/hRVDwA1AQAWAAcJ/hRVDwA1AQAAAA==.',
['十進']='十進制:BAAALgADCgYJBgAAAA==.',
['十里']='十里坡小道士:BAAALgAECgEJAwAAAA==.',
['千言']='千言不如一默:BAAALgADCgcJBwAAAA==.',
['卓尔']='卓尔精灵梭莫:BAAALgADCgIJAgAAAA==.',
['卢瑟']='卢瑟福:BAAALgADCgEJAQAAAA==.',
['卧室']='卧室里的女人:BAAALgAECgMJAwAAAA==.',
['卿轻']='卿轻语:BAAALgAECgEJBAAAAA==.',
['厄祸']='厄祸:BAAALgAECgcJBwAAAA==.',
['双疯']='双疯插芸:BAAALgAECgEJAQAAAA==.',
['双笙']='双笙:BAAALgAFFAEJAQAAAA==.',
['双花']='双花紅棍:BAAALgADCgUJBQAAAA==.',
['可芋']='可芋:BAABLgAFFH8KAAIPAAUJkQpdBwClAQAPAAUJkQpdBwClAQAAAA==.',
['叶问']='叶问丶:BAABLgAFFH8IAAISAAQJDBuzDgAOAQASAAQJDBuzDgAOAQAAAA==.',
['司马']='司马肺脾:BAAALgAECgQJBAAAAA==.',
['听弦']='听弦束箭惊衣:BAAALgAECgcJBgAAAA==.',
['听风']='听风的九月:BAAALgAFFAIJBAAAAA==.',
['呆到']='呆到自然萌:BAAALgADCgUJBQAAAA==.',
['呆西']='呆西一号:BAABLgAFFH8GAAIDAAUJThtfEAD/AAADAAUJThtfEAD/AAAAAA==.呆西三号:BAABLgAFFH8KAAIDAAUJcx9TDwAMAQADAAUJcx9TDwAMAQAAAA==.呆西二号:BAABLgAFFH8GAAIDAAQJGBYKCQBdAQADAAQJGBYKCQBdAQAAAA==.呆西四号:BAABLgAFFH8IAAIDAAUJGhSIBQCoAQADAAUJGhSIBQCoAQAAAA==.',
['咕德']='咕德白:BAAALgAFFAIJBAAAAA==.',
['咿呀']='咿呀壹:BAABLgAFFH8FAAIDAAUJ0hToCwCtAAADAAUJ0hToCwCtAAAAAA==.',
['哈酒']='哈酒理理:BAABLgAECn8UAAISAAcJixt4HAAfAgASAAcJixt4HAAfAgAAAA==.',
['商业']='商业街头:BAAALgAECgYJCAAAAA==.',
['啊牧']='啊牧:BAAALgAECgUJBQAAAA==.',
['啪嗒']='啪嗒啪嗒:BAAALgAECgcJEQAAAA==.',
['喧嚣']='喧嚣屮:BAAALgADCgcJBwAAAA==.',
['嘟嘟']='嘟嘟涵月亮丶:BAAALgADCgUJBQAAAA==.',
['嘻嘻']='嘻嘻不西西:BAAALgAFFAEJAQAAAA==.',
['嘿丶']='嘿丶小刀子:BAAALgAECgYJDwAAAA==.',
['噬丨']='噬丨影:BAABLgAFFH8LAAMOAAQJPBJ/DAD/AAAOAAQJZBF/DAD/AAAPAAMJswvRFgDjAAAAAA==.',
['回收']='回收再改造:BAABLgAECn8UAAIWAAgJPh1zDwDXAgAWAAgJPh1zDwDXAgAAAA==.',
['图图']='图图不糊涂:BAAALgAECgYJBgAAAA==.',
['圣光']='圣光在下:BAAALgAECgYJBgAAAA==.圣光照耀我:BAACLgAFFH8YAAIIAAYJ1hqqAAC1AQAIAAYJ1hqqAAC1AQAuAAQKfyEAAggACAneJU0HAF0DAAgACAneJU0HAF0DAAAA.圣光的周末:BAAALgADCgUJBQAAAA==.',
['圣骑']='圣骑的帮手:BAABLgAECn8gAAQIAAcJtBxBNABRAgAIAAcJGRxBNABRAgAJAAcJaxAfGgA/AQARAAEJOgwAAAAAAAAAAA==.',
['城南']='城南旧事丶:BAAALgAECgEJAQAAAA==.',
['城崎']='城崎诺亚:BAABLgAFFH8JAAIXAAUJoA0FBAAAAQAXAAUJoA0FBAAAAQAAAA==.',
['基尔']='基尔黑:BAAALgAECgIJAgAAAA==.',
['基德']='基德肯:BAAALgAFFAEJAQAAAA==.',
['堕落']='堕落的手电筒:BAAALgAECggJAQAAAA==.',
['墨染']='墨染芸汐:BAAALgAECgIJAQAAAA==.',
['墨水']='墨水芯:BAAALgAECgcJBQAAAA==.',
['壮壮']='壮壮北级熊:BAAALgADCgUJCQAAAA==.',
['壹袋']='壹袋米扛几楼:BAABLgAECn8VAAINAAgJvBhyLABMAgANAAgJvBhyLABMAgAAAA==.',
['壹贰']='壹贰叁肆:BAAALgAFFAEJAQAAAA==.',
['夏目']='夏目蓝:BAAALgAECgkJBgABLgAFFAUJDgAUAKMmAA==.',
['多余']='多余的解释:BAAALgADCgEJAQAAAA==.',
['多娜']='多娜多娜:BAABLgAECn8XAAMYAAgJvg9aDgDMAQAYAAgJvg9aDgDMAQAUAAEJsgcAAAAAAAAAAA==.',
['夜爲']='夜爲央:BAAALgAECgkJAQABLgAFFAcJBwAZACQaAA==.',
['夜皎']='夜皎:BAAALgAECggJCAAAAA==.',
['夜雨']='夜雨星河:BAAALgAECgYJBgAAAA==.',
['大五']='大五:BAAALgAFFAQJBAAAAA==.',
['大六']='大六:BAAALgAFFAQJBAAAAA==.',
['大四']='大四:BAAALgAFFAQJBAAAAA==.',
['大锤']='大锤捌拾:BAAALgAECgIJAgAAAA==.',
['天也']='天也不懂情:BAAALgAECgYJCgAAAA==.',
['天地']='天地玄黄:BAAALgADCgIJAgAAAA==.',
['天堂']='天堂之力:BAAALgAECgQJBwAAAA==.',
['天天']='天天红:BAAALgAECgUJBQAAAA==.',
['天意']='天意四象:BAACLgAFFH8IAAIaAAQJGCDOBACQAQAaAAQJGCDOBACQAQAuAAQKfy0AAhoACAnKItEIAAIDABoACAnKItEIAAIDAAAA.',
['天神']='天神小法:BAAALgADCgcJBwAAAA==.',
['天胤']='天胤:BAAALgAECgEJAQAAAA==.',
['奇诺']='奇诺哥哥:BAAALgAFFAEJAQAAAA==.',
['奋斗']='奋斗与梦想:BAAALgAECgUJCQAAAA==.',
['奎特']='奎特玛尼斯:BAAALgAFFAEJAQAAAA==.',
['奥丽']='奥丽维亚:BAAALgAECgEJAgAAAA==.',
['奥肥']='奥肥利亚:BAABLgAECn8fAAIbAAgJ8h5sEwB6AgAbAAgJ8h5sEwB6AgABLgAFFAYJFgAcAMUZAA==.',
['奶咖']='奶咖奶咖:BAAALgAECgUJBQAAAA==.',
['奶嘴']='奶嘴:BAAALgADCgYJBgAAAA==.',
['她还']='她还盛开吗:BAAALgAECgMJAwAAAA==.',
['好心']='好心情:BAAALgADCgUJBQAAAA==.',
['如创']='如创国之举:BAAALgAFFAIJAQABLgAFFAYJCAABAHsGAA==.',
['如果']='如果喵:BAAALgADCgYJAQAAAA==.',
['妇科']='妇科圣手:BAAALgAECgYJBgAAAA==.',
['妖姬']='妖姬乜蓅涙:BAAALgAECgMJAwAAAA==.',
['威廉']='威廉萌:BAAALgAECgMJAwAAAA==.',
['娜莎']='娜莎丶月殇:BAAALgAFFAEJAQAAAA==.',
['娜贝']='娜贝拉:BAAALgAECgMJBAAAAA==.',
['娜露']='娜露梅亚:BAABLgAFFH8PAAINAAUJKhwFBwCzAQANAAUJKhwFBwCzAQAAAA==.',
['子言']='子言孟注:BAAALgAECgYJCwAAAA==.',
['宁静']='宁静的心灵:BAAALgAECgcJEQAAAA==.',
['守密']='守密人:BAAALgAECgQJBAABLgAFFAQJDAAcAMoaAA==.',
['安静']='安静丶:BAABLgAFFH8FAAIDAAUJiBIqBABQAQADAAUJiBIqBABQAQAAAA==.安静的躺会:BAAALgAECgEJAQAAAA==.',
['宛如']='宛如初见:BAAALgAECgEJAQAAAA==.',
['宝木']='宝木:BAAALgAECgQJBAAAAA==.',
['宝生']='宝生玛格:BAABLgAFFH8KAAIXAAUJFBLYBABYAQAXAAUJFBLYBABYAQAAAA==.',
['实在']='实在没名字取:BAAALgAECgYJCAAAAA==.',
['家守']='家守雾子:BAABLgAFFH8HAAILAAQJkxWfEgBSAQALAAQJkxWfEgBSAQABLgAFFAUJCgALANMcAA==.',
['寒焱']='寒焱:BAAALgAECgYJBQAAAA==.',
['小太']='小太阳狮子:BAAALgAECgUJBgAAAA==.',
['小小']='小小酥:BAAALgAECgYJCAAAAA==.',
['小星']='小星云:BAABLgAFFH8GAAIRAAMJnA/PDwDcAAARAAMJnA/PDwDcAAAAAA==.小星榆:BAAALgAECgEJAQAAAA==.',
['小牧']='小牧诗:BAAALgADCgQJBAAAAA==.',
['小白']='小白龙:BAAALgAFFAIJAgAAAA==.',
['小辰']='小辰:BAACLgAFFH8NAAIIAAUJYCP1AQD0AQAIAAUJYCP1AQD0AQAuAAQKfx4AAggACAn8I84KADkDAAgACAn8I84KADkDAAAA.',
['小逝']='小逝一下:BAAALgAFFAEJAQAAAA==.',
['小野']='小野马:BAAALgADCgYJBgAAAA==.',
['小雾']='小雾:BAAALgAFFAEJAQAAAA==.',
['小黄']='小黄毛:BAAALgAECgIJAgAAAA==.',
['小黑']='小黑豹:BAACLgAFFH8MAAIdAAUJSSOYAAAQAgAdAAUJSSOYAAAQAgAuAAQKfx0AAh0ACAmcJWQCAHcDAB0ACAmcJWQCAHcDAAAA.',
['小龙']='小龙猫:BAAALgADCgYJBgAAAA==.',
['巨大']='巨大的破局:BAABLgAFFH8FAAIBAAUJygq6BgCEAQABAAUJygq6BgCEAQAAAA==.',
['巴西']='巴西利亚:BAAALgAECgQJCgAAAA==.',
['布加']='布加林:BAAALgAECgMJBAAAAA==.',
['布布']='布布鲁:BAAALgAECgkJAQAAAA==.',
['布斯']='布斯:BAAALgAECgYJBgAAAA==.',
['布林']='布林灬:BAAALgAFFAEJAgAAAA==.',
['布甲']='布甲之光:BAAALgAECgIJBAAAAA==.',
['布莱']='布莱恩丶铜须:BAAALgAECgQJBAAAAA==.',
['希尔']='希尔菲德:BAAALgAECgYJBwABLgAFFAMJCAAMAO8fAA==.',
['希波']='希波丹姆:BAAALgAECgQJAgAAAA==.',
['希瑶']='希瑶:BAAALgAECgUJAwAAAA==.',
['希糖']='希糖心:BAAALgADCgIJAgAAAA==.',
['常应']='常应常静:BAAALgAECgMJAwAAAA==.',
['幸福']='幸福的左边:BAABLgAFFH8MAAMWAAQJ+w6+DAA7AQAWAAQJJA6+DAA7AQAeAAEJ/wQpEQA6AAAAAA==.',
['幻景']='幻景:BAAALgAFFAIJAgAAAA==.',
['弑血']='弑血丶冰魄:BAAALgADCgYJBgAAAA==.',
['弥托']='弥托:BAAALgADCgcJBwAAAA==.',
['归思']='归思难收:BAAALgAFFAQJBAAAAA==.',
['得鹿']='得鹿梦鱼:BAAALgAECgIJAgAAAA==.',
['御风']='御风饮海:BAABLgAFFH8UAAISAAUJ0iKoAQD5AQASAAUJ0iKoAQD5AQAAAA==.',
['微风']='微风冬至:BAAALgADCgkJCQAAAA==.',
['德如']='德如意:BAAALgADCgIJAgAAAA==.',
['德弗']='德弗伦:BAAALgADCgEJAQAAAA==.',
['德芙']='德芙薄荷:BAAALgAFFAIJAgAAAA==.',
['心咒']='心咒咒:BAAALgAECgEJAQAAAA==.',
['心如']='心如芷水:BAAALgAECgEJAQAAAA==.',
['快开']='快开英勇:BAAALgAECgQJBQAAAA==.',
['快速']='快速治疗机器:BAABLgAFFH8FAAIZAAIJjyCZDgCwAAAZAAIJjyCZDgCwAAAAAA==.',
['怎么']='怎么跟狗一样:BAAALgAECgkJEwAAAA==.怎么那么自私:BAABLgAFFH8GAAIfAAQJHhFyCABjAQAfAAQJHhFyCABjAQAAAA==.',
['恩赐']='恩赐回忆:BAAALgADCgIJAgAAAA==.',
['恶猎']='恶猎宁:BAAALgADCgQJAwAAAA==.',
['情深']='情深深:BAAALgAECgYJBwAAAA==.',
['惊蛰']='惊蛰之风:BAAALgADCgMJAwAAAA==.',
['愤怒']='愤怒的能量:BAAALgADCgYJBgAAAA==.愤怒的风行者:BAAALgADCgEJAQAAAA==.',
['我嘞']='我嘞个熊熊:BAAALgADCgQJBAAAAA==.',
['我才']='我才是奶龙:BAAALgAECgcJAQAAAA==.',
['我是']='我是虚空之影:BAAALgAECgUJBgAAAA==.',
['我的']='我的刀盾:BAACLgAFFH8HAAMgAAQJRhcYDACqAAALAAIJIx0zLQC6AAAgAAIJaREYDACqAAAuAAQKfxYAAwsACQn5HsQMABQDAAsACQm1HsQMABQDACAABQnqIeMcAGcBAAAA.',
['我要']='我要驗牌:BAAALgAFFAEJAgAAAA==.',
['我超']='我超漂亮的:BAAALgAFFAIJAgAAAA==.',
['战疫']='战疫:BAAALgAECgYJCAAAAA==.',
['截云']='截云:BAAALgAECgMJAwAAAA==.',
['戰帝']='戰帝:BAAALgAECgYJCgAAAA==.',
['房东']='房东的猫徳:BAAALgAECgEJAQAAAA==.',
['打小']='打小就色:BAAALgADCgEJAQAAAA==.',
['把妹']='把妹丶不知道:BAAALgAECgYJEgAAAA==.',
['投河']='投河自尽的鱼:BAAALgAECgEJAgAAAA==.',
['拉普']='拉普兰德:BAABLgAFFH8GAAIBAAUJDAaNBwBzAQABAAUJDAaNBwBzAQAAAA==.',
['拉萨']='拉萨多:BAAALgAECgIJAgAAAA==.',
['挽手']='挽手润余生丶:BAAALgAECgMJAwAAAA==.',
['推进']='推进之王丶:BAAALgADCgEJAQAAAA==.',
['擢升']='擢升:BAAALgAFFAIJAgAAAA==.',
['数万']='数万箴言:BAABLgAFFH8JAAIBAAUJBA1IBgCOAQABAAUJBA1IBgCOAQABLgAFFAYJCAABAHsGAA==.',
['斗宗']='斗宗强者:BAAALgAECgYJCwAAAA==.',
['斯特']='斯特克林:BAAALgAECgUJBQAAAA==.',
['新欢']='新欢灬:BAAALgAECgMJAQAAAA==.',
['方缘']='方缘三百骑:BAAALgADCgEJAQAAAA==.方缘两百里:BAAALgAECgEJAQAAAA==.',
['旅人']='旅人与歌者:BAAALgAECgcJBwAAAA==.',
['无何']='无何有之国:BAAALgAECgYJDAABLgAFFAYJCAABAHsGAA==.',
['无双']='无双大黄瓜:BAABLgAECn8cAAQOAAgJACDjGwBfAgAOAAcJfiDjGwBfAgAPAAYJQRn0SgAmAQAhAAEJHhEAAAAAAAAAAA==.',
['无敌']='无敌最俊朗:BAAALgAECgMJAwAAAA==.无敌肥猪:BAAALgAECgEJAQAAAA==.',
['无暧']='无暧灬:BAAALgAECgEJAQAAAA==.',
['无毛']='无毛猫椰子:BAAALgAECgQJBwAAAA==.',
['星之']='星之彩:BAACLgAFFH8TAAMFAAUJyyY4AABCAgAFAAUJyyY4AABCAgAEAAIJZBAvCACjAAAuAAQKfyUAAgUACAkaIxQDADADAAUACAkaIxQDADADAAAA.',
['星哥']='星哥:BAAALgAECgYJCgAAAA==.',
['星幻']='星幻无痕:BAAALgAECgQJBgAAAA==.',
['星霄']='星霄之暗:BAAALgADCgIJAgAAAA==.',
['晓得']='晓得鸟:BAAALgAECgUJBwAAAA==.',
['晓红']='晓红帽:BAAALgAECgcJEQAAAA==.',
['晚照']='晚照:BAAALgAECgQJBAAAAA==.',
['晨城']='晨城成沉尘:BAAALgAECgEJAQAAAA==.',
['晨星']='晨星对不对:BAAALgAECgYJAwABLgAFFAYJEAAGAC0hAA==.',
['晨晨']='晨晨:BAAALgAFFAIJAgAAAA==.',
['景辰']='景辰:BAAALgAECgYJCwABLgAFFAUJDQAIAGAjAA==.',
['暗夜']='暗夜复仇者:BAAALgADCgcJBwAAAA==.',
['暮色']='暮色夜语:BAABLgAFFH8GAAIIAAIJLxukDQC1AAAIAAIJLxukDQC1AAAAAA==.',
['暴富']='暴富哚:BAAALgADCgcJBwAAAA==.',
['暴龙']='暴龙战士:BAAALgAFFAMJBAAAAA==.',
['月下']='月下独饮:BAAALgADCgUJBQAAAA==.',
['月团']='月团团:BAAALgADCgYJBgAAAA==.',
['月落']='月落叁横丶:BAABLgAFFH8GAAMGAAQJ5wm7LgDeAAAGAAMJ5wm7LgDeAAAXAAEJAAAOFwA+AAAAAA==.月落弓鸣:BAAALgAFFAEJAQAAAA==.',
['有女']='有女梓彤梓嫣:BAAALgAFFAIJAwAAAA==.',
['有求']='有求必硬:BAAALgAECgEJAQAAAA==.',
['有牛']='有牛啊:BAABLgAECn8dAAIIAAkJCx0dFQDrAgAIAAkJCx0dFQDrAgAAAA==.',
['朝小']='朝小树丶:BAAALgAFFAIJBAAAAA==.',
['朝行']='朝行雨:BAAALgAECgUJCAAAAA==.',
['朦胧']='朦胧夜色:BAAALgAECgcJCQAAAA==.',
['木叶']='木叶舞王:BAAALgAECgcJDgAAAA==.',
['木琦']='木琦流光三号:BAABLgAFFH8IAAIPAAUJZRngBwCcAQAPAAUJZRngBwCcAQAAAA==.木琦流光四号:BAAALgAECgYJBgAAAA==.',
['木香']='木香:BAAALgADCgIJAgAAAA==.',
['术神']='术神夜:BAAALgADCgUJBQAAAA==.',
['朽丶']='朽丶:BAABLgAFFH8HAAIWAAMJyxtVFwCsAAAWAAMJyxtVFwCsAAAAAA==.',
['杏树']='杏树纱奈:BAAALgADCgEJAQAAAA==.',
['条码']='条码人:BAAALgAECgcJCwAAAA==.',
['来一']='来一发电疗呗:BAAALgADCgkJCQAAAA==.',
['松云']='松云:BAABLgAFFH8IAAMUAAMJ7wJCBwDKAAAUAAMJ7wJCBwDKAAAaAAMJSgKYFgCsAAAAAA==.',
['柏拉']='柏拉圖式爱情:BAAALgADCgUJBQAAAA==.',
['柠柒']='柠柒丶:BAAALgADCgEJAQAAAA==.',
['柳木']='柳木诗梦:BAAALgAFFAQJBAAAAA==.',
['桃小']='桃小德:BAAALgADCgUJBQAAAA==.',
['桜雨']='桜雨:BAAALgAECgcJBwABLgAFFAQJEAAbAJckAA==.',
['梦满']='梦满枝头:BAABLgAFFH8JAAIGAAMJkiFcEgDQAAAGAAMJkiFcEgDQAAAAAA==.',
['梦醒']='梦醒时夜续:BAAALgAFFAEJAgAAAA==.',
['梦雨']='梦雨:BAAALgAECgcJCgAAAA==.',
['梦魇']='梦魇异音:BAAALgAFFAMJAwABLgAFFAQJCgABABsSAA==.',
['梳碧']='梳碧湖砍柴人:BAABLgAFFH8FAAIIAAIJKBibIQCpAAAIAAIJKBibIQCpAAAAAA==.',
['森亚']='森亚琉琉歌:BAAALgAFFAIJAgAAAA==.',
['森高']='森高千里:BAAALgAECgYJAgAAAA==.',
['橘雪']='橘雪莉:BAAALgAECgEJAwAAAA==.',
['橙色']='橙色正版咕咕:BAAALgAFFAEJAQAAAA==.',
['武打']='武打明星:BAAALgAECgYJBgAAAA==.',
['死亡']='死亡之疫:BAAALgAECgEJAQAAAA==.死亡天使:BAAALgAECgcJDQAAAA==.死亡麻辣:BAAALgAFFAIJAgAAAA==.',
['死尸']='死尸累生死郎:BAAALgAFFAcJAgABLgAFFAYJCAABAHsGAA==.',
['死灵']='死灵之殇:BAACLgAFFH8HAAIEAAIJCyJ8EADDAAAEAAIJCyJ8EADDAAAuAAQKfycAAwQACAluIXMJAKMCAAQACAluIXMJAKMCABkABwmVG2IWADQCAAAA.',
['死神']='死神蔷薇:BAAALgAFFAMJBAAAAA==.',
['殘一']='殘一劍:BAAALgAFFAEJAQAAAA==.',
['殷夜']='殷夜来丶:BAABLgAFFH8IAAIXAAUJ1gzoAwAEAQAXAAUJ1gzoAwAEAQAAAA==.',
['比比']='比比拉布:BAACLgAFFH8DAAILAAMJgxbNMQCvAAALAAMJgxbNMQCvAAAuAAQKfyAAAwsABwlRJNkaALQCAAsABwlRJNkaALQCACAAAgnFFexKAI0AAAAA.',
['毕月']='毕月乌丶:BAAALgAFFAIJAwAAAA==.',
['水干']='水干蛋:BAACLgAFFH8IAAMLAAQJUxmjCgAhAQALAAMJix2jCgAhAQAgAAEJrAzzBABZAAAuAAQKfxsAAwsACQm7IA4GAFwDAAsACQm7IA4GAFwDACAABgk6G9MWAJMBAAAA.',
['水水']='水水蛋:BAABLgAFFH8IAAMLAAQJbBxGFgA9AQALAAMJeSRGFgA9AQAgAAEJQwTSGABMAAAAAA==.',
['水蛋']='水蛋蛋:BAAALgADCgYJBgAAAA==.',
['永世']='永世锻炉:BAAALgAECgEJAQAAAA==.',
['永夜']='永夜骑士:BAAALgAECgMJBAAAAA==.',
['永恒']='永恒娘:BAAALgAECgUJBQAAAA==.永恒武道:BAAALgAECgYJDgAAAA==.',
['永空']='永空大师:BAAALgAECgIJAgAAAA==.',
['汐汐']='汐汐:BAAALgAECgEJAQAAAA==.',
['沐雨']='沐雨灬言诗:BAAALgAECgQJCAAAAA==.',
['没笑']='没笑美咲:BAAALgAECgcJEgAAAA==.',
['油腻']='油腻中年人:BAAALgAECgEJAQAAAA==.',
['法小']='法小喵:BAAALgAECgEJAQAAAA==.',
['泡利']='泡利:BAAALgAECgYJCwAAAA==.',
['波兰']='波兰:BAAALgAECgEJAgAAAA==.',
['泰沙']='泰沙拉克:BAAALgADCgYJBgAAAA==.',
['洁羽']='洁羽之光:BAAALgAECgIJAgAAAA==.',
['洗洗']='洗洗:BAAALgAECgEJAQAAAA==.',
['洛泽']='洛泽:BAAALgAECgUJBQAAAA==.',
['洛羽']='洛羽:BAAALgAECgcJEgAAAA==.',
['流今']='流今辰:BAAALgAECgEJAQAAAA==.',
['流浪']='流浪的光:BAAALgAECgYJBgAAAA==.',
['浅唱']='浅唱栀浓:BAACLgAFFH8GAAILAAIJ2iU4JwDgAAALAAIJ2iU4JwDgAAAuAAQKfxoAAgsABwl8JcURAO0CAAsABwl8JcURAO0CAAAA.',
['浅蓝']='浅蓝:BAAALgAECgQJBAAAAA==.',
['海与']='海与昔洲:BAAALgAECgIJAgAAAA==.海与昔洲丶:BAAALgAECgYJCgAAAA==.海与西洲:BAAALgAECgMJAwAAAA==.海与西洲丶:BAAALgAECgUJCAAAAA==.',
['海棠']='海棠醉日丶:BAAALgAFFAUJAwAAAA==.',
['海瑟']='海瑟音:BAAALgAECgQJBAAAAA==.',
['海绵']='海绵寳寳:BAAALgAECgYJBgAAAA==.',
['清风']='清风执剑:BAAALgAFFAEJAQAAAA==.清风未晚:BAAALgADCgEJAQAAAA==.清风淡云:BAAALgAECgMJAwAAAA==.清风灬防战:BAAALgAECgIJAgAAAA==.清风灬驭兽:BAAALgAECgUJBgAAAA==.',
['渡边']='渡边曜:BAACLgAFFH8IAAIMAAQJNxEFHgBSAQAMAAQJNxEFHgBSAQAuAAQKfxoAAgwABwn/IhQ5AJECAAwABwn/IhQ5AJECAAAA.',
['游医']='游医:BAAALgADCgEJAQAAAA==.',
['湮灭']='湮灭龙:BAABLgAECn8VAAIDAAgJqRdIFQAxAgADAAgJqRdIFQAxAgAAAA==.',
['溜达']='溜达儿:BAAALgAECgYJBgAAAA==.',
['滚出']='滚出切:BAABLgAECn8UAAIfAAkJIRjfDgCzAgAfAAkJIRjfDgCzAgAAAA==.',
['滴尅']='滴尅丶:BAAALgAECgQJBAAAAA==.',
['潇黑']='潇黑猫:BAAALgAFFAIJAgAAAA==.',
['火干']='火干蛋:BAAALgAFFAQJBAAAAA==.火干蛋一丶:BAAALgADCgcJBwAAAA==.火干蛋三:BAAALgADCgcJBwAAAA==.',
['火火']='火火蛋:BAAALgADCgMJAwAAAA==.',
['火蛋']='火蛋蛋:BAAALgADCgUJBQAAAA==.',
['灬火']='灬火焱火灬:BAAALgAECgEJAQAAAA==.',
['灬莉']='灬莉奈德林灬:BAAALgAECgEJAQAAAA==.',
['灬血']='灬血灬鈊:BAAALgAECgcJAQAAAA==.',
['灰袍']='灰袍甘道夫丶:BAAALgAECgYJEAAAAA==.',
['灼亘']='灼亘:BAAALgAECgcJBwAAAA==.',
['炎头']='炎头队长:BAAALgAECgcJBwAAAA==.',
['点灬']='点灬绛唇:BAAALgAECgYJDQAAAA==.',
['炽燃']='炽燃龙女:BAAALgADCgEJAQAAAA==.',
['烟斗']='烟斗没烟了:BAAALgADCgcJBwAAAA==.',
['烟色']='烟色萦绕丶:BAAALgADCgUJBQAAAA==.',
['烨神']='烨神:BAAALgAECgYJBwAAAA==.',
['热敏']='热敏:BAAALgAECgYJBgAAAA==.',
['热烈']='热烈而自由:BAAALgADCgEJAQAAAA==.',
['烷渼']='烷渼瞬间:BAAALgAFFAEJAQAAAA==.',
['無人']='無人生還:BAABLgAFFH8LAAIGAAUJWSK/AgDhAQAGAAUJWSK/AgDhAQAAAA==.',
['爆力']='爆力:BAAALgAECgYJCwAAAA==.',
['爱冒']='爱冒险的梦:BAAALgADCgUJBQAAAA==.',
['爱恰']='爱恰小熊饼干:BAAALgADCgUJBwAAAA==.',
['爱莉']='爱莉希雅丶:BAACLgAFFH8NAAMPAAUJmBhwBwCkAQAPAAUJmBhwBwCkAQAOAAEJSRE6IwBZAAAuAAQKfx4AAw8ACAl4H34UAIwCAA8ACAlnG34UAIwCAA4AAgkcHNeXAKYAAAAA.',
['牙牙']='牙牙的火火:BAAALgADCgYJBgAAAA==.',
['牛肉']='牛肉小蛋糕:BAAALgAECgEJAQAAAA==.牛肉汉堡:BAAALgAECgEJAQAAAA==.',
['牧丶']='牧丶狐:BAAALgADCgEJAQAAAA==.',
['牧宁']='牧宁:BAAALgAECgQJBAAAAA==.',
['特别']='特别的特别:BAAALgAECgEJAQAAAA==.',
['特大']='特大可乐:BAAALgAECgEJAQAAAA==.特大布丁:BAABLgAECn8UAAISAAYJZhaTNAB8AQASAAYJZhaTNAB8AQAAAA==.',
['特莉']='特莉斯:BAAALgADCgkJCQABLgAFFAQJEAAGAP0eAA==.',
['特蕾']='特蕾西娅:BAAALgAECgYJCQAAAA==.',
['牺牲']='牺牲祝福:BAAALgADCgQJBAAAAA==.',
['狐小']='狐小奶:BAAALgAECgUJBQAAAA==.',
['狡猾']='狡猾的慧慧:BAAALgAFFAQJBAAAAA==.',
['狩约']='狩约:BAAALgAECgEJAQAAAA==.',
['独步']='独步油条丶:BAAALgAECgcJBgABLgAFFAYJDgAUAP8PAA==.',
['猎焰']='猎焰龙:BAAALgAECgUJBgAAAA==.',
['猪踏']='猪踏栏:BAABLgAECn8fAAMOAAgJKSFyCAAKAwAOAAgJKSFyCAAKAwAPAAIJYR4UbACOAAAAAA==.',
['猫头']='猫头之星:BAAALgAECgYJBgAAAA==.',
['王三']='王三叁叁:BAABLgAFFH8KAAIKAAMJFh61BAAfAQAKAAMJFh61BAAfAQAAAA==.',
['王嘉']='王嘉尔:BAAALgADCgIJAgAAAA==.',
['玛卡']='玛卡巴卡:BAAALgAECgcJDQAAAA==.',
['环境']='环境净化员:BAAALgAECgYJCQAAAA==.',
['琥珀']='琥珀封印:BAAALgAECgEJAQAAAA==.',
['琳琳']='琳琳:BAAALgAECgQJCAAAAA==.',
['瑞德']='瑞德哞丶:BAAALgADCgcJBwAAAA==.',
['瓦不']='瓦不行:BAACLgAFFH8HAAIRAAMJTRz1DQD4AAARAAMJTRz1DQD4AAAuAAQKfysAAxEACAlgIcUIAOMCABEACAlgIcUIAOMCAAkABAnbEIooAMUAAAAA.',
['甘织']='甘织玲奈子:BAAALgAECgQJBQAAAA==.',
['甜甜']='甜甜宝贝:BAAALgAECgYJDwAAAA==.',
['生死']='生死答问:BAAALgAFFAQJBAAAAA==.',
['申一']='申一了然:BAAALgADCgQJBAAAAA==.',
['画眉']='画眉深浅处丶:BAAALgAFFAIJAgAAAA==.',
['疯了']='疯了般想你:BAAALgAECgEJAQAAAA==.',
['疾风']='疾风怒涛之计:BAAALgAECgUJBAABLgAFFAIJAgAHAAAAAA==.疾风踏影:BAAALgADCgIJAgAAAA==.',
['病变']='病变:BAAALgAECgkJDgAAAA==.',
['登徒']='登徒浪子服帖:BAAALgAECgUJBgAAAA==.',
['白厄']='白厄:BAABLgAECn8hAAMGAAcJAR1iRQAlAgAGAAcJAR1iRQAlAgAXAAcJ3w93JwADAQAAAA==.',
['白大']='白大拿:BAAALgAECgYJBgAAAA==.',
['白色']='白色死神:BAAALgAECggJEwAAAA==.',
['白菜']='白菜君丶:BAAALgAECgkJCgAAAA==.',
['白龙']='白龙武士:BAACLgAFFH8OAAIIAAQJ7CAOAgB7AQAIAAQJ7CAOAgB7AQAuAAQKfx4AAggACAlFJCwKAD8DAAgACAlFJCwKAD8DAAAA.',
['百地']='百地希留耶:BAABLgAFFH8IAAIMAAMJ7x8RKAATAQAMAAMJ7x8RKAATAQAAAA==.',
['的卢']='的卢的马:BAAALgADCgYJBwAAAA==.',
['皮尔']='皮尔卡松:BAAALgAECgUJBgAAAA==.',
['目光']='目光所及:BAAALgADCgEJAQAAAA==.',
['盲者']='盲者:BAAALgAECgYJCgAAAA==.',
['直男']='直男:BAAALgAECgUJCAABLgAFFAIJAgAHAAAAAA==.',
['睡不']='睡不醒的海嗨:BAAALgAECgUJCgAAAA==.',
['瞬间']='瞬间击杀:BAAALgAECgEJAwAAAA==.',
['知音']='知音梦里寻:BAAALgAECgEJAgAAAA==.',
['矮猎']='矮猎库:BAAALgADCgUJBQAAAA==.',
['碧蓝']='碧蓝航线高手:BAABLgAECn8iAAIJAAgJIg5MFACIAQAJAAgJIg5MFACIAQAAAA==.',
['磐石']='磐石玉生烟:BAAALgAECgYJCAAAAA==.',
['礼墨']='礼墨酥米:BAAALgAFFAIJAgAAAA==.',
['神机']='神机妙术:BAAALgAECgYJEQAAAA==.',
['神蛊']='神蛊温皇呀:BAAALgADCgUJCAAAAA==.',
['禁止']='禁止随地野战:BAAALgAECgQJBgAAAA==.',
['科比']='科比布莱恩特:BAAALgAECgcJEAAAAA==.',
['科长']='科长一号:BAAALgAFFAQJAgAAAA==.科长七号:BAABLgAFFH8IAAIcAAUJpxytAgDNAQAcAAUJpxytAgDNAQAAAA==.',
['秦梦']='秦梦:BAAALgAFFAIJBAAAAA==.',
['穿格']='穿格子的猫:BAAALgADCgYJCQAAAA==.',
['穿黑']='穿黑斯不灭团:BAAALgAECgcJDwAAAA==.',
['笑忘']='笑忘录:BAAALgADCgEJAQAAAA==.',
['等一']='等一场大雨:BAAALgAFFAMJAwAAAA==.',
['簡單']='簡單丶點:BAAALgAECgYJCwABLgAFFAEJAQAHAAAAAA==.',
['籁阿']='籁阿弥:BAABLgAFFH8FAAIBAAQJpgtfCwA0AQABAAQJpgtfCwA0AQAAAA==.',
['米丶']='米丶迦丶勒:BAAALgAFFAEJAQAAAA==.',
['米利']='米利安多:BAAALgAECgEJAQAAAA==.',
['糖门']='糖门滚丶橘子:BAAALgADCgQJBAAAAA==.',
['素乄']='素乄问:BAAALgAECgEJAQAAAA==.',
['索洛']='索洛托:BAABLgAECn8gAAIIAAgJ8yTtAADpAgAIAAgJ8yTtAADpAgAAAA==.',
['紫藤']='紫藤亚里莎:BAABLgAFFH8IAAIXAAQJLRSXAgAwAQAXAAQJLRSXAgAwAQAAAA==.',
['红莲']='红莲极意:BAABLgAFFH8QAAISAAQJDiGPAgBhAQASAAQJDiGPAgBhAQAAAA==.',
['约顿']='约顿海姆之手:BAAALgAECgcJEgAAAA==.',
['纳瓦']='纳瓦霍:BAAALgAECgcJAgAAAA==.',
['终结']='终结:BAAALgAECgcJEgAAAA==.',
['缘团']='缘团三:BAAALgAECgEJAQAAAA==.',
['羽鳥']='羽鳥:BAAALgAECgEJAQAAAA==.',
['老头']='老头一个:BAAALgAECgkJCQAAAA==.',
['聖德']='聖德:BAAALgADCgMJAwAAAA==.',
['肘不']='肘不开的尾王:BAAALgAECgYJEQAAAA==.肘不开的舱门:BAAALgAECgMJAwAAAA==.',
['脳殘']='脳殘的牛:BAAALgAECgcJEAAAAA==.',
['自摸']='自摸:BAAALgAFFAUJBAAAAA==.',
['至暗']='至暗之夜:BAAALgAECgUJBgAAAA==.',
['航道']='航道冒医:BAAALgAFFAEJAQAAAA==.',
['艺恩']='艺恩小主:BAAALgAECgYJBwAAAA==.',
['芙露']='芙露德莉斯:BAABLgAFFH8KAAMKAAQJiw/QBQD5AAAKAAMJlxDQBQD5AAANAAQJyAobEADUAAAAAA==.',
['花凋']='花凋零:BAAALgADCgUJFAAAAA==.',
['花泽']='花泽乄香菜:BAAALgAFFAEJAQAAAA==.',
['花田']='花田喜事:BAAALgAECgEJAQAAAA==.',
['芽麦']='芽麦呆:BAAALgAFFAIJAgAAAA==.',
['苏伦']='苏伦:BAAALgADCgIJAgAAAA==.',
['英普']='英普瑞斯:BAABLgAECn8fAAMRAAcJLhYgLgDLAQARAAcJLhYgLgDLAQAIAAcJwxR1XgDIAQAAAA==.',
['茄茄']='茄茄是晴天:BAAALgAECgYJBgAAAA==.',
['草莓']='草莓冰淇淋:BAAALgAFFAIJAwAAAA==.',
['莫拉']='莫拉塔:BAAALgAFFAIJAgAAAA==.',
['莫莫']='莫莫:BAAALgAECgMJBgAAAA==.',
['莱妮']='莱妮丝:BAAALgAECgEJAQAAAA==.',
['莱德']='莱德莉丝琳:BAAALgAECgEJAgAAAA==.',
['莲见']='莲见蕾雅:BAABLgAFFH8IAAIXAAQJ+BDgAgAmAQAXAAQJ+BDgAgAmAQABLgAFFAcJDgAcAA8kAA==.',
['菠萝']='菠萝鸡腿堡:BAAALgAECgYJBgAAAA==.',
['萨卡']='萨卡:BAAALgAECgYJBgAAAA==.',
['萨迈']='萨迈迩:BAAALgAECgcJCwAAAA==.',
['蒸坦']='蒸坦克不灭团:BAAALgADCgcJCAAAAA==.',
['蓝染']='蓝染惣右介:BAAALgAECgIJAgAAAA==.',
['蕾菈']='蕾菈娜:BAAALgAECgcJEgAAAA==.',
['薩布']='薩布拉克:BAAALgADCgYJBgAAAA==.',
['蛋干']='蛋干火:BAAALgAECgYJBgAAAA==.',
['蜃杀']='蜃杀楼:BAAALgAFFAQJAwABLgAFFAYJCAABAHsGAA==.',
['蜃殁']='蜃殁交抵之湖:BAABLgAFFH8TAAIBAAYJWBXjAADeAQABAAYJWBXjAADeAQABLgAFFAYJCAABAHsGAA==.',
['血血']='血血宝宝:BAABLgAECn8UAAIIAAgJZRsOLQBvAgAIAAgJZRsOLQBvAgAAAA==.',
['西洲']='西洲与海丶:BAAALgAECgUJDgAAAA==.西洲与海底:BAAALgAECgEJAQAAAA==.',
['西瓜']='西瓜不甜丶:BAAALgADCgcJBwAAAA==.',
['让我']='让我吃了你吧:BAAALgADCgEJAQAAAA==.',
['说好']='说好不玩德:BAAALgAECgUJBQAAAA==.',
['豆包']='豆包丶:BAAALgAFFAIJBAAAAA==.',
['贞德']='贞德既是正义:BAABLgAECn8bAAIUAAgJsBmHFQBkAgAUAAgJsBmHFQBkAgAAAA==.',
['赈早']='赈早见琥珀主:BAABLgAFFH8WAAIBAAcJCRVHAAA5AgABAAcJCRVHAAA5AgABLgAFFAYJCAABAHsGAA==.',
['赖床']='赖床:BAAALgAECgEJAwAAAA==.',
['赤隼']='赤隼:BAAALgAECggJCgAAAA==.',
['赵子']='赵子龙:BAABLgAFFH8JAAIIAAUJRQ8xBgCMAQAIAAUJRQ8xBgCMAQAAAA==.',
['超级']='超级咸鱼欧皇:BAAALgADCgEJAQAAAA==.',
['越爱']='越爱越难:BAAALgAECgkJCQAAAA==.',
['趴趴']='趴趴小丸子:BAAALgAECgQJBQAAAA==.',
['跑得']='跑得快刷得快:BAAALgAECgMJBQAAAA==.',
['软肋']='软肋:BAAALgAECgQJBAAAAA==.',
['轰鸣']='轰鸣:BAAALgAECgQJBAABLgAFFAMJCQAeAI8aAA==.',
['辰州']='辰州白:BAAALgADCgcJCAAAAA==.',
['边塞']='边塞诗人兀术:BAAALgAECgQJBQAAAA==.',
['达达']='达达牛:BAAALgADCgMJAwAAAA==.',
['运气']='运气爆棚九九:BAAALgAECgYJDwAAAA==.',
['还要']='还要:BAAALgAECgMJAwAAAA==.',
['迪亚']='迪亚吥羅:BAAALgAECgMJAwAAAA==.',
['逍遥']='逍遥丨蝶仙:BAAALgAFFAEJAQAAAA==.',
['逐颜']='逐颜旖旎时丶:BAAALgAECgYJCAAAAA==.',
['逗起']='逗起耍:BAABLgAFFH8JAAIeAAMJ/Bv5AgAHAQAeAAMJ/Bv5AgAHAQAAAA==.',
['通通']='通通:BAAALgAECgEJAQAAAA==.',
['造物']='造物鱼像条蛆:BAABLgAECn8UAAIIAAcJhhNQYQDBAQAIAAcJhhNQYQDBAQAAAA==.',
['遗失']='遗失的足迹:BAABLgAECn8WAAIIAAcJIxucQgAcAgAIAAcJIxucQgAcAgAAAA==.',
['邪能']='邪能火干蛋:BAAALgAFFAIJAgAAAA==.邪能火干蛋蛋:BAAALgAFFAQJBAAAAA==.邪能范丽琴:BAAALgAFFAIJAgAAAA==.邪能范家发:BAAALgAFFAMJAwAAAA==.邪能范小勇:BAAALgAFFAIJBAAAAA==.邪能范小勤:BAACLgAFFH8FAAMLAAQJmxkSEwDOAAALAAMJGh8SEwDOAAAgAAEJHQleBQBVAAAuAAQKfxUAAwsACQkXHVkLACADAAsACQkXHVkLACADACAABgnhGs4WAJMBAAAA.邪能马芸:BAAALgAFFAIJBAAAAA==.',
['郁盛']='郁盛:BAAALgAFFAIJAgAAAA==.',
['都月']='都月琉衣紗:BAAALgADCgQJBAAAAA==.',
['酒尽']='酒尽人亦醉:BAAALgAECgYJEAAAAA==.',
['酱鸡']='酱鸡:BAAALgADCgUJAQAAAA==.',
['醉意']='醉意丶:BAAALgAECgcJEwAAAA==.',
['醉饮']='醉饮千觞:BAAALgADCgYJBgAAAA==.',
['铠冢']='铠冢霙:BAAALgAFFAQJBAABLgAFFAUJDgAUAKMmAA==.',
['长犄']='长犄溯时:BAABLgAFFH8IAAIBAAYJewZyEgCaAAABAAYJewZyEgCaAAAAAA==.',
['闪电']='闪电果:BAABLgAFFH8FAAIbAAIJuB+OFAC2AAAbAAIJuB+OFAC2AAAAAA==.',
['闪耀']='闪耀莴苣:BAABLgAFFH8FAAIaAAMJhA9YEQDfAAAaAAMJhA9YEQDfAAAAAA==.',
['阴阳']='阴阳割昏晓:BAAALgAECggJCwAAAA==.',
['阿伏']='阿伏伽德罗:BAAALgAECgQJBgAAAA==.',
['阿克']='阿克恩:BAAALgAECgQJBAAAAA==.',
['阿卡']='阿卡丽:BAAALgAECgMJAQAAAA==.',
['阿孝']='阿孝一号:BAABLgAFFH8LAAMBAAQJxQJSDQAJAQABAAQJxQJSDQAJAQADAAQJ5AF5CAD6AAAAAA==.',
['阿萝']='阿萝拉:BAAALgADCgYJBgAAAA==.',
['陪吃']='陪吃陪喝:BAAALgAECgIJAgAAAA==.',
['雨微']='雨微:BAAALgAECgEJAQAAAA==.',
['雨月']='雨月睡不醒:BAAALgADCgcJBwABLgAECgIJAQAHAAAAAA==.',
['雪灵']='雪灵:BAAALgADCgQJBAAAAA==.',
['雪落']='雪落时见你:BAAALgAECgQJBAAAAA==.',
['露米']='露米娅:BAAALgAECgkJCQAAAA==.',
['靈武']='靈武尒帝:BAAALgAECgcJDQAAAA==.',
['青衣']='青衣居士:BAAALgAECgUJBQAAAA==.',
['靳痕']='靳痕月恸:BAAALgAECgQJBgAAAA==.',
['音尘']='音尘绝:BAAALgAFFAQJAQAAAA==.',
['顺应']='顺应潮流:BAAALgAECgMJAwAAAA==.',
['顺风']='顺风皮卡丘:BAAALgAFFAEJAQAAAA==.',
['预定']='预定调和:BAAALgADCgIJAgAAAA==.',
['领跑']='领跑:BAACLgAFFH8NAAMiAAQJ7AqMAgBCAQAiAAQJ7AqMAgBCAQAWAAEJXAA+JwA3AAAuAAQKfxsAAiIACAnjGB0FAI8CACIACAnjGB0FAI8CAAAA.',
['风之']='风之纱:BAABLgAECn8aAAMcAAkJBh2jFwBaAgAcAAgJhR+jFwBaAgAbAAkJVgzKLADYAQAAAA==.',
['风吹']='风吹丹顶鹤:BAACLgAFFH8KAAIKAAQJjyXvAAC3AQAKAAQJjyXvAAC3AQAuAAQKfx0AAgoACAlKJrIBAIkDAAoACAlKJrIBAIkDAAAA.',
['风怒']='风怒的汤姆猫:BAAALgADCgQJBAAAAA==.',
['风暴']='风暴灬烈酒:BAAALgAFFAIJAgAAAA==.风暴烈酒丶陈:BAAALgAECgMJAwAAAA==.',
['风歌']='风歌:BAABLgAECn8YAAMBAAgJIBVfGADQAQABAAcJeBVfGADQAQADAAgJhwk9KAB7AQAAAA==.',
['风若']='风若水:BAAALgAFFAIJAwAAAA==.',
['风语']='风语驯兽师:BAAALgADCgEJAQAAAA==.',
['风雪']='风雪千山:BAAALgAECgkJDAAAAA==.',
['飞行']='飞行雪绒:BAAALgAECgUJBgAAAA==.',
['香布']='香布布:BAAALgAECgYJBwAAAA==.',
['骑丶']='骑丶世:BAAALgAECgMJAwAAAA==.',
['高松']='高松燈:BAABLgAFFH8RAAIGAAYJ8B/TDwBiAQAGAAYJ8B/TDwBiAQAAAA==.',
['魔幻']='魔幻贝贝:BAAALgAECgEJAQAAAA==.',
['魔神']='魔神一月风一:BAAALgAECgEJAQAAAA==.魔神猎手:BAAALgAECgcJCAAAAA==.',
['鱿鱼']='鱿鱼大宝贝:BAAALgADCgIJAgAAAA==.',
['鲸鱼']='鲸鱼:BAAALgAECgQJBAAAAA==.',
['鸟语']='鸟语花香:BAAALgADCgYJCAAAAA==.',
['鸿福']='鸿福记:BAAALgAECgUJCgAAAA==.',
['鹤舞']='鹤舞白沙:BAAALgAECgEJAQAAAA==.',
['麥情']='麥情灬肆涩:BAAALgADCgQJBAAAAA==.',
['麦迪']='麦迪逊花园:BAACLgAFFH8TAAIEAAUJTSGEAgDwAQAEAAUJTSGEAgDwAQAuAAQKfxoAAwQACAmJI0QHAM8CAAQABwlvJEQHAM8CAAUABwkuIlQNAIICAAAA.',
['黄粱']='黄粱虞梦:BAAALgAECgIJAgAAAA==.',
['黎曼']='黎曼鲁司:BAAALgAECgkJCQAAAA==.',
['黑风']='黑风内:BAAALgAECgQJBgAAAA==.',
['鼠鼠']='鼠鼠变鸟扇你:BAAALgAECgUJBwAAAA==.鼠鼠热饮:BAAALgAFFAUJBAAAAA==.',
['龙川']='龙川天天:BAAALgAECgUJBQAAAA==.',
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
