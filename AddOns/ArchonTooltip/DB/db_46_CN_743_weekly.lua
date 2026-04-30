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

local lookup = {'Paladin-Holy','Mage-Frost','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Druid-Guardian','Druid-Restoration','DemonHunter-Devourer','Unknown-Unknown','Shaman-Restoration','Priest-Discipline','Warrior-Protection','Warrior-Fury','Priest-Holy','Warrior-Arms','Druid-Balance','Monk-Mistweaver',}
local provider = {region='CN',realm='火羽山',name='CN',type='weekly',zone=46,date='2026-04-25',data={Fl='Flxsdiy:BAAALgAECgQJDgAAAA==.',
Ke='Keany:BAAALgAECgcJEwAAAA==.',
Nu='Nuoyiqsk:BAABLgAFFH8KAAIBAAYJ0RTLBwBVAQABAAYJ0RTLBwBVAQAAAA==.',
Pl='Playerztfqqg:BAAALgADCgEJAQAAAA==.',
Sc='Scrunch:BAABLgAECn8UAAICAAcJbSCegQDOAQACAAcJbSCegQDOAQAAAA==.',
Sh='Shmilyyd:BAAALgAECgcJDQAAAA==.',
So='Soberr:BAAALgAECgYJDAAAAA==.',
Tm='Tmto:BAAALgAECgUJBAAAAA==.',
['一十']='一十八:BAAALgAECgcJDwAAAA==.',
['三十']='三十五熊猫:BAAALgADCgcJBwAAAA==.',
['世界']='世界斑斑:BAAALgAECgQJBAAAAA==.',
['丨克']='丨克拉苏斯丨:BAAALgAECgQJBAAAAA==.',
['丶小']='丶小乐意:BAAALgAFFAMJAwAAAA==.',
['丷火']='丷火羽山丷:BAAALgAECggJDgAAAA==.',
['乌莲']='乌莲娜的曙光:BAAALgADCgYJBgAAAA==.',
['乖巧']='乖巧的糖喵喵:BAAALgAECgYJBgAAAA==.',
['乙骨']='乙骨忧太:BAABLgAFFH8NAAIDAAQJ1B4PCgCBAQADAAQJ1B4PCgCBAQAAAA==.',
['九九']='九九一十八:BAAALgADCgQJBAAAAA==.',
['乡村']='乡村教法:BAAALgADCgYJBgAAAA==.',
['五五']='五五开:BAAALgADCgYJBgAAAA==.',
['人间']='人间四月:BAAALgAECgIJAgAAAA==.',
['傷物']='傷物语:BAAALgADCgEJAgAAAA==.',
['关羽']='关羽:BAAALgAECgcJEQAAAA==.',
['冰凝']='冰凝瑞雪:BAAALgAECgYJCQAAAA==.',
['凑凑']='凑凑哈:BAAALgAECgEJAQAAAA==.',
['凝霜']='凝霜飞雪:BAAALgADCgEJAQAAAA==.',
['厄运']='厄运常伴:BAAALgADCgEJAQAAAA==.',
['发丘']='发丘将军丶:BAAALgAECgYJCQAAAA==.',
['口函']='口函天宪:BAACLgAFFH8GAAIEAAIJWiL5KADRAAAEAAIJWiL5KADRAAAuAAQKfxsAAwQACAk0I74JADADAAQACAk0I74JADADAAUAAQkAAHxuADgAAAAA.',
['另一']='另一粒丹:BAAALgADCgQJBAAAAA==.',
['叹息']='叹息风中:BAAALgAECgcJDAAAAA==.',
['吞吞']='吞吞吐吐:BAAALgAECgYJBgAAAA==.',
['哈斯']='哈斯沃德:BAABLgAECn8YAAIGAAcJsx27PwAnAgAGAAcJsx27PwAnAgAAAA==.',
['回忆']='回忆丶终难忘:BAAALgAECggJEgAAAA==.',
['圣光']='圣光忽悠这你:BAAALgAECgcJCwAAAA==.',
['在哪']='在哪躺在哪睡:BAAALgADCgUJBQAAAA==.',
['墨染']='墨染青衫:BAABLgAFFH8FAAIDAAQJaAm+GwA1AQADAAQJaAm+GwA1AQAAAA==.',
['夜影']='夜影柳柳:BAACLgAFFH8HAAMHAAMJ/QZRBQBlAAAHAAIJgglRBQBlAAAIAAEJkQDJKgAzAAAuAAQKfxUAAgcACAnwEDYQAHQBAAcACAnwEDYQAHQBAAAA.',
['大绿']='大绿豆胆:BAACLgAFFH8HAAIDAAMJCRXkJwD4AAADAAMJCRXkJwD4AAAuAAQKfx8AAgMACQmxG/QSAAoDAAMACQmxG/QSAAoDAAAA.',
['大跳']='大跳崴到脚:BAAALgAECgIJAgAAAA==.',
['天下']='天下第一巭:BAAALgADCgIJAgAAAA==.天下第一战:BAAALgADCgMJAwABLgAFFAQJCAAJAJoJAA==.天下第一骑:BAABLgAFFH8FAAIDAAIJHAJOSwCAAAADAAIJHAJOSwCAAAABLgAFFAQJCAAJAJoJAA==.',
['天堂']='天堂中的群风:BAAALgAECgQJBAAAAA==.',
['寥若']='寥若晨汐:BAACLgAFFH8FAAICAAIJbQdhRwChAAACAAIJbQdhRwChAAAuAAQKfxoAAgIACAmjE/5kAA4CAAIACAmjE/5kAA4CAAAA.',
['寸板']='寸板:BAAALgAECgEJAQAAAA==.',
['小乐']='小乐意丶:BAAALgAFFAUJBAAAAA==.',
['小小']='小小丶小猎:BAAALgAECgQJBAAAAA==.',
['小肥']='小肥星灬:BAAALgAECgYJCAAAAA==.',
['小锶']='小锶:BAAALgAECgEJAQAAAA==.',
['小黄']='小黄伞:BAAALgADCgMJAgAAAA==.',
['尘煙']='尘煙水星:BAAALgAFFAEJAQAAAA==.',
['幸运']='幸运的萨鲁曼:BAACLgAFFH8GAAICAAIJ6xq3NgC9AAACAAIJ6xq3NgC9AAAuAAQKfyQAAgIACAnZJOoSADYDAAIACAnZJOoSADYDAAAA.',
['幽霜']='幽霜:BAAALgAECgEJAQAAAA==.',
['开门']='开门小能手:BAAALgADCgIJAQAAAA==.',
['张利']='张利霞:BAAALgAECgQJBwAAAA==.',
['忧伤']='忧伤不会的:BAAALgAECgcJBwABLgAFFAIJAgAKAAAAAA==.',
['怵术']='怵术:BAAALgADCgYJBgAAAA==.',
['恐龙']='恐龙:BAAALgAECgUJCgAAAA==.',
['悠幽']='悠幽:BAAALgAECgYJCwAAAA==.',
['我有']='我有两只猫:BAACLgAFFH8GAAILAAIJTQrpGwCIAAALAAIJTQrpGwCIAAAuAAQKfxQAAgsACAnZHxMNALUCAAsACAnZHxMNALUCAAAA.',
['打死']='打死不练牛:BAAALgADCgYJBgAAAA==.',
['断灬']='断灬牙:BAAALgAECgcJDgAAAA==.',
['星辰']='星辰聚:BAAALgAECgcJEwAAAA==.',
['春日']='春日小乖狗叫:BAAALgAFFAQJBAABLgAFFAUJCgADAGkdAA==.',
['暗影']='暗影下的猫:BAAALgADCgEJAQAAAA==.',
['暴风']='暴风老人物:BAAALgAFFAEJAgAAAA==.',
['最后']='最后的工具人:BAAALgAECgEJAQAAAA==.',
['月夜']='月夜荼蘼:BAAALgADCgUJBQAAAA==.',
['有绒']='有绒乃大:BAAALgAECgMJBAAAAA==.',
['李太']='李太医:BAAALgAECgQJCwAAAA==.',
['李沐']='李沐恩:BAAALgAECgMJAgAAAA==.',
['树加']='树加光影:BAAALgAECgEJAQAAAA==.',
['桑妮']='桑妮:BAAALgAECgcJCQAAAA==.',
['梦寐']='梦寐之眼:BAAALgAECgIJAwAAAA==.',
['橙子']='橙子妈妈:BAAALgAECgcJCQAAAA==.',
['歆丶']='歆丶回忆:BAAALgAECgEJAQAAAA==.',
['比阿']='比阿特丽思:BAAALgADCgMJAwAAAA==.',
['毛毛']='毛毛球:BAABLgAFFH8FAAIMAAQJyCSyAwC7AQAMAAQJyCSyAwC7AQABLgAFFAUJKgAMAP8kAA==.',
['永冬']='永冬之月:BAAALgAECgYJCwAAAA==.',
['没图']='没图你说个碉:BAAALgAECggJDwAAAA==.',
['沧海']='沧海遗粟邓:BAACLgAFFH8IAAINAAMJIBlpBwDrAAANAAMJIBlpBwDrAAAuAAQKfxkAAw0ACAmrG3cMAEQCAA0ACAldGncMAEQCAA4AAwmDF0d8AMsAAAAA.',
['洛洛']='洛洛娜:BAAALgAECgQJBAAAAA==.',
['流刃']='流刃若火:BAAALgAECgEJAQAAAA==.',
['海峡']='海峡:BAAALgAECgUJBgAAAA==.',
['清风']='清风流年:BAAALgAFFAIJAgAAAA==.',
['滚来']='滚来滚去龙神:BAAALgAECgYJBgAAAA==.',
['漫天']='漫天枫痕:BAAALgAECgcJBwAAAA==.',
['烈吙']='烈吙奶奶:BAAALgAECgYJCQAAAA==.',
['熊猫']='熊猫与傻瓜:BAAALgADCgEJAQAAAA==.',
['牛小']='牛小花灬:BAABLgAFFH8QAAIBAAUJsCCzAADpAQABAAUJsCCzAADpAQAAAA==.',
['牛肉']='牛肉干的妈妈:BAACLgAFFH8HAAIPAAIJpQpUDgCLAAAPAAIJpQpUDgCLAAAuAAQKfxYAAg8ACAlgFOoZAAwCAA8ACAlgFOoZAAwCAAEuAAUUAgkEAAoAAAAA.牛肉干的爸爸:BAAALgAFFAIJBAAAAA==.',
['犯克']='犯克你夫:BAAALgAECgIJAgAAAA==.',
['狂暴']='狂暴怒怒:BAACLgAFFH8FAAIOAAIJ6B/mFADDAAAOAAIJ6B/mFADDAAAuAAQKfxsAAg4ACAnXH4wMAPMCAA4ACAnXH4wMAPMCAAAA.',
['独步']='独步暗影:BAAALgAECgEJAQAAAA==.',
['猜猜']='猜猜:BAAALgADCgcJBwAAAA==.',
['玛莲']='玛莲妮亚:BAAALgADCgEJAQAAAA==.',
['琉璃']='琉璃嫣:BAAALgAECgYJBgAAAA==.',
['电力']='电力少年王:BAAALgAECgkJCQAAAA==.',
['白晓']='白晓谕:BAAALgAECgMJAwAAAA==.',
['神不']='神不在的月曜:BAAALgAECgEJAQAAAA==.',
['禹菜']='禹菜头:BAAALgAECgEJAQAAAA==.',
['笃志']='笃志竹:BAAALgAECgYJBgAAAA==.',
['笔染']='笔染秋渡:BAAALgAECgUJCAAAAA==.',
['精灵']='精灵公主:BAAALgADCgMJAwAAAA==.',
['红日']='红日一号:BAAALgADCgUJBQAAAA==.',
['羽生']='羽生萌萌香:BAAALgAFFAIJAgAAAA==.',
['老灬']='老灬丶灬丢:BAAALgAECgYJCQAAAA==.',
['老灵']='老灵额:BAAALgADCgIJAgAAAA==.',
['胡捌']='胡捌壹丶:BAAALgAECggJDAAAAA==.',
['腰圆']='腰圆棍粗:BAAALgAECgEJAQAAAA==.',
['致富']='致富之手:BAAALgAFFAQJBAAAAA==.',
['艾瑞']='艾瑞:BAAALgADCgEJAQAAAA==.',
['艾米']='艾米哈伯:BAAALgAECgEJAQAAAA==.',
['芭芭']='芭芭拉冲鸭:BAAALgADCgIJAgABLgAFFAEJAQAKAAAAAA==.',
['花鳥']='花鳥風月:BAAALgAECgQJBwAAAA==.',
['茂爷']='茂爷的图腾:BAAALgAECgEJAQAAAA==.茂爷的审判:BAAALgAECgMJAwAAAA==.茂爷的湮灭:BAAALgAECgQJBAAAAA==.',
['草飞']='草飞机:BAAALgAECgUJCwAAAA==.',
['莽一']='莽一:BAABLgAECn8YAAMOAAcJqx2EAwAQAgAOAAcJqx2EAwAQAgAQAAcJaA+KEACUAQAAAA==.',
['莽七']='莽七:BAAALgAECgMJBQAAAA==.',
['莽三']='莽三:BAAALgAECgcJDQAAAA==.莽三十九:BAAALgAECgYJDAAAAA==.',
['莽九']='莽九:BAAALgAECgYJAwAAAA==.',
['莽二']='莽二:BAABLgAECn8XAAMQAAkJLBgQBwBRAgAQAAgJjhUQBwBRAgAOAAcJJBpNKwAJAgAAAA==.莽二十七:BAAALgAECgkJCgAAAA==.莽二十六:BAAALgAECggJDwAAAA==.',
['莽五']='莽五:BAAALgAECgcJDQAAAA==.莽五十:BAAALgAECgcJDQAAAA==.',
['莽六']='莽六:BAAALgAECgkJEwAAAA==.',
['莽四']='莽四:BAAALgAECgYJBgAAAA==.莽四十九:BAAALgAECgMJAwAAAA==.莽四十五:BAAALgAECgcJBwAAAA==.莽四十八:BAAALgAECgcJCgAAAA==.莽四十六:BAAALgAECgYJBgAAAA==.莽四十四:BAAALgAECgcJCAAAAA==.',
['莽夫']='莽夫:BAACLgAFFH8GAAIOAAQJDg6vCwBGAQAOAAQJDg6vCwBGAQAuAAQKfxcAAg4ACQmYHo4AAM8CAA4ACQmYHo4AAM8CAAAA.',
['菩提']='菩提:BAAALgADCgYJBgAAAA==.',
['薄荷']='薄荷冰美式:BAAALgAECgIJAgAAAA==.',
['藤椒']='藤椒鸡排堡:BAAALgAFFAIJAgAAAA==.',
['虚空']='虚空丶鲨鱼:BAAALgADCgUJBQAAAA==.',
['術士']='術士大叔邓:BAAALgAECgEJAQAAAA==.',
['赖小']='赖小七:BAAALgAECgUJBQAAAA==.',
['远航']='远航星:BAAALgAECgYJBgAAAA==.',
['重庆']='重庆破产重组:BAAALgAECgYJDAAAAA==.重庆铭光资产:BAABLgAECn8ZAAMIAAgJuh74FwB3AgAIAAcJQyH4FwB3AgARAAcJVx3rHgAIAgAAAA==.',
['重生']='重生成骑士:BAABLgAFFH8IAAIGAAQJPxEoFwD0AAAGAAQJPxEoFwD0AAAAAA==.',
['銭多']='銭多多:BAAALgAECgUJDQAAAA==.',
['钟吾']='钟吾奇奇:BAAALgAECgYJBwAAAA==.',
['钢化']='钢化你心:BAAALgAECgQJBAAAAA==.',
['钢琴']='钢琴里的猫:BAAALgAFFAYJBAAAAA==.',
['阿肚']='阿肚灬:BAACLgAFFH8LAAISAAQJ/CXBBgBXAQASAAQJ/CXBBgBXAQAuAAQKfx4AAhIACAmBInUFAAwDABIACAmBInUFAAwDAAAA.',
['阿诺']='阿诺库塔:BAAALgADCgEJAQAAAA==.',
['雏灵']='雏灵:BAAALgADCgUJBQAAAA==.',
['露营']='露营必须酒:BAAALgADCgMJAwAAAA==.',
['青青']='青青国王:BAAALgADCgEJAQAAAA==.',
['飘落']='飘落枫叶:BAAALgAECgUJBwAAAA==.',
['飛行']='飛行弗絨:BAAALgAECgQJAwAAAA==.',
['马国']='马国成:BAAALgAECgcJDAAAAA==.',
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
