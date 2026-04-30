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

local lookup = {'Mage-Frost','Hunter-Marksmanship','Hunter-Survival','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','DeathKnight-Unholy','Shaman-Elemental','Druid-Restoration','Unknown-Unknown','Priest-Holy','Shaman-Restoration','Druid-Balance','Paladin-Holy','Paladin-Retribution','Priest-Discipline','Warrior-Fury','Monk-Brewmaster','Rogue-Subtlety','DemonHunter-Devourer','Monk-Mistweaver','Hunter-BeastMastery','Warrior-Arms','DemonHunter-Havoc','Paladin-Protection','Warlock-Destruction','Warlock-Demonology',}
local provider = {region='CN',realm='夏维安',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ai='Ailice:BAAALgAFFAIJAgAAAA==.',
Ba='Baelish:BAAALgAECgEJAwAAAA==.Balerion:BAAALgADCgEJAQAAAA==.Baobao:BAAALgAECgEJAQAAAA==.',
Da='Darkrepulse:BAABLgAFFH8GAAIBAAIJvRc1OAC6AAABAAIJvRc1OAC6AAAAAA==.',
De='Deathdirge:BAAALgAECgMJAwAAAA==.Device:BAAALgAECggJCwAAAA==.Deviln:BAAALgADCgkJCgAAAA==.',
Di='Dijin:BAABLgAECn8UAAMCAAcJnxmEJgDyAQACAAcJnxmEJgDyAQADAAMJeQnuCwDKAAAAAA==.Disturbzsz:BAAALgADCgUJBQAAAA==.',
Eu='Eugeo:BAAALgAECgYJEAAAAA==.',
Ex='Excelsior:BAACLgAFFH8PAAICAAQJGhabDABTAQACAAQJGhabDABTAQAuAAQKfxYAAgIACAkaIbQMAOACAAIACAkaIbQMAOACAAAA.',
Fa='Faeries:BAAALgAFFAIJAgABLgAFFAUJBQAEAMoNAA==.',
Fe='Fearmonger:BAAALgADCgMJAwAAAA==.',
Fr='Freedoom:BAAALgADCgQJBAAAAA==.',
Fu='Funkylion:BAAALgAECgIJAgAAAA==.',
Ho='Howonewobee:BAABLgAECn8YAAIBAAcJLRVFcgDvAQABAAcJLRVFcgDvAQAAAA==.',
Hu='Huikodh:BAAALgAECgcJDQAAAA==.',
Ka='Kaelen:BAAALgAECggJDgAAAA==.',
Ki='Kilakri:BAAALgAECgQJDAAAAA==.Kiritor:BAAALgAECgYJBwAAAA==.',
Lo='Loong:BAACLgAFFH8OAAMFAAQJwiN2AgB2AQAFAAQJwiN2AgB2AQAGAAEJ1ANSCwBLAAAuAAQKfyAAAwUACAlHHaYRAF8CAAUABwl2HKYRAF8CAAYAAwluFZspANEAAAAA.',
Ma='Maiimohunter:BAAALgAECgcJCAAAAA==.Maiimoo:BAAALgAECgcJBwAAAA==.Matumbaman:BAAALgADCgYJAgAAAA==.',
Mi='Mik:BAAALgAFFAIJAgAAAA==.',
Mo='Mocuishle:BAAALgAECgEJAQAAAA==.Mostaza:BAAALgAECgYJBgAAAA==.',
Ne='Neverflee:BAAALgAECgcJEgAAAA==.',
Od='Odream:BAAALgAFFAEJAgAAAA==.',
Ol='Oldwong:BAAALgAECgcJEwAAAA==.',
On='Oniros:BAAALgAFFAEJAQAAAA==.',
Qi='Qingdao:BAAALgAECgYJBgAAAA==.',
Ro='Rougeil:BAAALgADCgMJAwAAAA==.Rougeml:BAAALgADCgYJAwAAAA==.Rougesl:BAAALgAECgQJDAAAAA==.',
Sh='Shadowdream:BAAALgAECgEJAQAAAA==.',
Sk='Skyburial:BAAALgAECgEJAQAAAA==.',
Sp='Spotlights:BAAALgAECgQJBgAAAA==.',
Up='Uplift:BAAALgAECgcJBwAAAA==.',
Ur='Urmyirezings:BAAALgAECggJEgAAAA==.',
Wi='Willy:BAAALgAECgEJAgAAAA==.Winteye:BAAALgADCgMJBQAAAA==.',
Wo='Woylle:BAAALgAFFAEJAQAAAA==.',
Xc='Xc:BAAALgADCgEJAQAAAA==.',
Yu='Yukiasuna:BAAALgAECgYJBgAAAA==.',
['一匹']='一匹狼:BAAALgAFFAQJBAAAAA==.',
['一只']='一只羊:BAAALgAFFAIJAgAAAA==.',
['一叶']='一叶秋风:BAABLgAECn8WAAIHAAcJCh5VDQCzAQAHAAcJCh5VDQCzAQAAAA==.',
['一寸']='一寸灰:BAAALgAFFAQJAwAAAA==.',
['万物']='万物将朽:BAAALgAECgIJAgAAAA==.',
['三年']='三年五班丶萨:BAAALgADCgEJAQAAAA==.',
['三度']='三度衝擊:BAAALgADCgEJAQAAAA==.',
['三莜']='三莜:BAAALgAFFAQJBAABLgAFFAYJFgAIAMUZAA==.',
['不可']='不可言语:BAAALgADCgQJBAAAAA==.',
['不愿']='不愿上班:BAAALgAECgQJBAAAAA==.',
['丨光']='丨光环丨:BAAALgAECgEJAQAAAA==.',
['丨没']='丨没有丶回忆:BAAALgADCgIJAgAAAA==.',
['丨灵']='丨灵魂之翼丨:BAAALgAECgYJDQAAAA==.',
['丨空']='丨空丨:BAAALgADCgYJBgAAAA==.',
['丶丨']='丶丨希诺:BAAALgAECgUJBwAAAA==.',
['丶嘘']='丶嘘别说话丶:BAAALgAECgEJAQAAAA==.',
['丶奔']='丶奔驰上树:BAAALgADCgUJBQAAAA==.',
['丶弱']='丶弱鸡:BAAALgAECgEJAQAAAA==.',
['丶晓']='丶晓萌:BAAALgAFFAUJAQAAAA==.',
['丶柟']='丶柟:BAAALgADCgcJBwAAAA==.',
['丶苍']='丶苍蕊墨影:BAACLgAFFH8FAAIJAAMJTwlAEwDOAAAJAAMJTwlAEwDOAAAuAAQKfxsAAgkACAkCF3clACMCAAkACAkCF3clACMCAAAA.',
['丶薯']='丶薯片丶:BAAALgAECgEJAgABLgAECgIJAgAKAAAAAA==.',
['丶誓']='丶誓约丶:BAAALgAECgIJAgAAAA==.',
['丸犊']='丸犊子:BAABLgAFFH8FAAIEAAUJyg0ZBgCSAQAEAAUJyg0ZBgCSAQAAAA==.',
['为梦']='为梦而战:BAAALgADCgEJAQAAAA==.',
['丿逆']='丿逆袭灬小术:BAAALgADCgMJAwAAAA==.',
['乔拉']='乔拉莫尔蒙:BAAALgAECgEJAQAAAA==.',
['乱世']='乱世佳人:BAAALgAFFAIJAwAAAA==.',
['乱糟']='乱糟糟的红尘:BAAALgAECgYJBgAAAA==.',
['云水']='云水蟾心:BAAALgAECgEJAQAAAA==.',
['人間']='人間不值得:BAAALgAECgYJDQAAAA==.',
['伊呀']='伊呀嘿:BAACLgAFFH8MAAILAAUJhh/bAADgAQALAAUJhh/bAADgAQAuAAQKfyYAAgsACQmtIQECAFMDAAsACQmtIQECAFMDAAAA.',
['众生']='众生为果:BAAALgAECgIJAgAAAA==.',
['优秀']='优秀潜力股:BAABLgAECn8XAAIMAAgJQRYKIQAZAgAMAAgJQRYKIQAZAgAAAA==.',
['伶俐']='伶俐丶大帅:BAAALgADCgEJAQAAAA==.',
['佛耶']='佛耶戈:BAAALgAFFAQJBAAAAA==.',
['你二']='你二大爷:BAAALgADCgIJAgAAAA==.',
['你别']='你别追我跑了:BAAALgAECgUJBQAAAA==.',
['你被']='你被牛打过:BAABLgAFFH8IAAINAAUJ8x0kAgDrAQANAAUJ8x0kAgDrAQAAAA==.',
['依酷']='依酷:BAAALgADCgEJAQAAAA==.',
['信小']='信小絮叨:BAAALgADCgEJAQAAAA==.',
['先杀']='先杀那个骑士:BAAALgAFFAEJAQAAAA==.',
['入魇']='入魇:BAAALgADCgIJAgAAAA==.',
['六味']='六味地黄丸:BAAALgAECgkJCwAAAA==.',
['再见']='再见小臭屁:BAAALgAECgcJBgAAAA==.',
['军团']='军团再临:BAAALgAECgYJCwAAAA==.',
['冬天']='冬天的冬:BAAALgADCgcJBwAAAA==.',
['冰冷']='冰冷的热血:BAAALgAFFAEJAQABLgAFFAIJBAAKAAAAAA==.',
['冰封']='冰封厄运:BAAALgADCgUJBQAAAA==.',
['冰蓝']='冰蓝聖雪:BAAALgAFFAEJAQAAAA==.',
['冰镇']='冰镇麦酒桶:BAAALgAECgMJBAAAAA==.',
['冲锋']='冲锋啊嗖:BAAALgAECgEJAgAAAA==.',
['决明']='决明:BAAALgAECgYJBgAAAA==.',
['凯恩']='凯恩肉蹄:BAAALgADCgEJAQAAAA==.',
['初三']='初三帅:BAAALgAECgcJCAAAAA==.',
['初小']='初小帅:BAAALgAECgIJAwAAAA==.',
['动次']='动次打次:BAAALgADCgEJAQAAAA==.',
['北小']='北小野:BAAALgADCgEJAQAAAA==.',
['北极']='北极之风:BAAALgAFFAEJAQAAAA==.',
['医不']='医不了:BAAALgAECgMJAwAAAA==.',
['十年']='十年乄如一:BAABLgAECn8ZAAIOAAgJVBroFABqAgAOAAgJVBroFABqAgAAAA==.',
['千叶']='千叶美智子:BAAALgADCgEJAQAAAA==.',
['千百']='千百夜:BAAALgADCgQJBAAAAA==.',
['半世']='半世浮生:BAAALgAECgEJAgAAAA==.',
['厉害']='厉害的哈你妹:BAAALgADCgQJBAAAAA==.',
['叙利']='叙利亚悍妇:BAAALgADCgUJBQAAAA==.',
['口曷']='口曷水酉:BAAALgAECgEJAQAAAA==.',
['只有']='只有香如故:BAAALgADCgMJAwAAAA==.',
['叮当']='叮当飞吻:BAABLgAFFH8HAAIBAAIJNRYbQgCrAAABAAIJNRYbQgCrAAAAAA==.',
['叽里']='叽里呱啦:BAAALgADCgcJBwAAAA==.',
['合法']='合法马路杀手:BAAALgAECgEJAQAAAA==.',
['吉尔']='吉尔瓦伦蒂安:BAAALgADCgMJAwAAAA==.',
['呜呜']='呜呜嗷嗷呜:BAAALgAECgQJBAAAAA==.',
['咕咕']='咕咕的阿江:BAAALgAECgYJCwAAAA==.',
['咿呀']='咿呀咿呀呦:BAAALgAECgQJBAAAAA==.',
['哑巴']='哑巴湖大水怪:BAAALgADCgEJAQAAAA==.',
['啫啫']='啫啫喱喱:BAAALgAECgMJAwAAAA==.',
['喔煌']='喔煌曌沃:BAAALgAECgEJAQAAAA==.',
['喵哟']='喵哟:BAAALgAECgYJCQAAAA==.',
['圣光']='圣光中的酒桶:BAAALgAECgUJCQAAAA==.圣光中的青龙:BAAALgAECgUJCAAAAA==.圣光教主:BAAALgAECgYJDQAAAA==.圣光的孽畜:BAAALgAECgYJBwAAAA==.圣光闪现:BAAALgAECgIJAwAAAA==.',
['坎特']='坎特蕾拉:BAAALgAECgEJAQAAAA==.',
['堂吉']='堂吉诃德:BAAALgAECgMJAwAAAA==.',
['墨彩']='墨彩环:BAAALgAFFAQJAQAAAA==.',
['夏奇']='夏奇羊:BAAALgAECgUJBQAAAA==.',
['夏绯']='夏绯雪:BAAALgAECgcJCAAAAA==.',
['夜墲']='夜墲灬倾城:BAAALgADCgkJDgAAAA==.',
['夜破']='夜破:BAAALgADCgIJAgAAAA==.',
['大萌']='大萌物:BAAALgAECgEJAgABLgAECgcJDAAKAAAAAA==.',
['天丶']='天丶辣鸡暴血:BAAALgAECgYJCwAAAA==.',
['天使']='天使:BAAALgAECgYJBgABLgAFFAQJBAAKAAAAAA==.',
['天水']='天水无梦:BAACLgAFFH8FAAIPAAIJqQVFKQCTAAAPAAIJqQVFKQCTAAAuAAQKfxUAAg8ABwliGqxNAPkBAA8ABwliGqxNAPkBAAAA.',
['天辰']='天辰风:BAAALgAECgEJAQAAAA==.',
['奥达']='奥达奇:BAAALgADCgEJAQAAAA==.',
['奶你']='奶你丶小叮叮:BAAALgAECgYJBgAAAA==.',
['妙丨']='妙丨酱:BAAALgAFFAIJAgAAAA==.',
['姜丹']='姜丹:BAAALgAECgcJEAAAAA==.',
['孔雀']='孔雀河西岸:BAABLgAFFH8FAAIQAAUJhiHiAQAQAgAQAAUJhiHiAQAQAgAAAA==.',
['学医']='学医不能救国:BAAALgAECgkJDgAAAA==.',
['宁姚']='宁姚:BAAALgAFFAIJAgAAAA==.',
['宋玉']='宋玉:BAAALgAFFAQJBAAAAA==.',
['寂静']='寂静之声:BAAALgADCgEJAQAAAA==.',
['寒灬']='寒灬梦:BAAALgAECgEJAQAAAA==.',
['小妞']='小妞贼啦俊:BAAALgAECgEJAQAAAA==.',
['小害']='小害怕:BAABLgAFFH8FAAIRAAMJWQ77FwCpAAARAAMJWQ77FwCpAAAAAA==.',
['小狼']='小狼崽:BAAALgAFFAQJAQAAAA==.',
['小羊']='小羊克丝:BAAALgAECgYJBgAAAA==.小羊崽:BAAALgAFFAMJAwAAAA==.',
['小鱼']='小鱼的霸霸:BAAALgAECgcJCAAAAA==.',
['小龙']='小龙人光环:BAAALgAECgMJAwAAAA==.',
['就爱']='就爱出橙装:BAAALgAFFAQJBAAAAA==.',
['尺玉']='尺玉霄飛練:BAAALgAFFAQJBAAAAA==.',
['山壑']='山壑赴荆门:BAABLgAFFH8HAAISAAMJxCGiCgAzAQASAAMJxCGiCgAzAQAAAA==.',
['岑太']='岑太白西凤:BAAALgADCgIJAgAAAA==.',
['布尔']='布尔多多:BAAALgADCgEJAQAAAA==.',
['希望']='希望长出尾巴:BAAALgAECgQJDgAAAA==.',
['幸以']='幸以:BAABLgAFFH8FAAITAAIJ+xpjEwCyAAATAAIJ+xpjEwCyAAAAAA==.',
['张老']='张老仙人:BAAALgAECgMJBgAAAA==.',
['往复']='往复:BAAALgADCgYJBgAAAA==.',
['從現']='從現在開始:BAAALgADCgEJAQAAAA==.',
['德蛮']='德蛮子:BAAALgAECgcJDQAAAA==.',
['心如']='心如死水:BAAALgAECgcJCgAAAA==.',
['恢复']='恢复牛牛:BAABLgAECn8eAAIMAAgJNiGDEACTAgAMAAgJNiGDEACTAgAAAA==.',
['感恩']='感恩带德:BAAALgADCgEJAQAAAA==.',
['愤怒']='愤怒的哈密瓜:BAAALgADCgQJBAAAAA==.愤怒的麻将:BAAALgADCgYJBgAAAA==.',
['我何']='我何必说谎:BAAALgAECgYJDAAAAA==.',
['我家']='我家闺女不卖:BAAALgAECgIJAgAAAA==.',
['我无']='我无敌你随意:BAAALgAECgEJAQAAAA==.',
['执迷']='执迷的鲸鱼:BAAALgAECgEJAQAAAA==.',
['执酒']='执酒醉迷离丶:BAAALgAECgEJAgAAAA==.',
['拂晓']='拂晓莫机车:BAAALgAECgYJEAAAAA==.',
['拉斯']='拉斯塔哈大王:BAAALgAFFAMJAwABLgAFFAQJBgAUABkaAA==.',
['排骨']='排骨大侠:BAAALgADCgEJAQAAAA==.',
['撕咬']='撕咬者:BAAALgAECgMJBAAAAA==.',
['放开']='放开我来:BAAALgAECgIJAwAAAA==.',
['散板']='散板:BAAALgAECgYJDAAAAA==.',
['斗萝']='斗萝:BAABLgAFFH8IAAIJAAMJaA+YEQDdAAAJAAMJaA+YEQDdAAAAAA==.',
['斩红']='斩红德:BAAALgADCgQJBQAAAA==.斩红法:BAAALgADCgEJAQAAAA==.斩红猎:BAAALgAECgEJAgAAAA==.',
['断誸']='断誸:BAAALgADCgQJBAAAAA==.',
['无意']='无意苦争春:BAAALgADCgQJBAAAAA==.',
['无谓']='无谓信仰丶:BAAALgADCgcJBwAAAA==.',
['日暮']='日暮残垣:BAAALgAECgEJAQAAAA==.',
['昆山']='昆山片玉:BAAALgAECgkJBwAAAA==.',
['普通']='普通的死骑:BAAALgAECgEJAgAAAA==.',
['暖阳']='暖阳下的小妞:BAAALgAECgYJBgAAAA==.',
['曾小']='曾小贤:BAAALgADCgEJAQAAAA==.',
['曾经']='曾经为她痴心:BAAALgAECgUJCQAAAA==.',
['月涩']='月涩:BAAALgAECgEJAwAAAA==.',
['月雨']='月雨殇:BAAALgAECgUJDAAAAA==.',
['未七']='未七:BAAALgAECgEJAgAAAA==.',
['李慕']='李慕婉:BAAALgAFFAQJBAAAAA==.',
['来真']='来真德:BAAALgAECgYJEgAAAA==.',
['杭州']='杭州萧炎:BAAALgAECgIJAgABLgAFFAEJAQAKAAAAAA==.',
['杰哥']='杰哥就是爱情:BAAALgAECgkJCQAAAA==.',
['林间']='林间小道:BAAALgAECgIJAgAAAA==.',
['枫叶']='枫叶微黄:BAACLgAFFH8FAAIVAAIJexluDwCkAAAVAAIJexluDwCkAAAuAAQKfyEAAhUACAnlH6EJALkCABUACAnlH6EJALkCAAAA.',
['柏冰']='柏冰:BAAALgAECgIJAwAAAA==.',
['栀意']='栀意乌龙茶:BAABLgAECn8ZAAIWAAkJUiADAwBkAwAWAAkJUiADAwBkAwABLgAFFAMJBQAXAMsPAA==.',
['梦飛']='梦飛雪:BAABLgAFFH8HAAILAAMJzApOCQDSAAALAAMJzApOCQDSAAAAAA==.',
['椰树']='椰树牌椰汁:BAAALgAECgcJDgAAAA==.',
['樱落']='樱落灬天堂:BAAALgAECgcJEQABLgAFFAQJCAAPABYjAA==.',
['橘小']='橘小美:BAAALgAECgIJAwAAAA==.橘小美分美:BAAALgAECgYJBwAAAA==.',
['橙色']='橙色鸢尾:BAAALgAECgQJBQAAAA==.',
['武庸']='武庸:BAAALgAECgYJBgAAAA==.',
['死亡']='死亡笨牛:BAAALgADCgEJAQAAAA==.',
['死有']='死有何惧灬:BAAALgAECgkJBwAAAA==.',
['死透']='死透透:BAACLgAFFH8IAAIHAAMJzxjcCwAUAQAHAAMJzxjcCwAUAQAuAAQKfycAAgcABwk1I1wFADICAAcABwk1I1wFADICAAAA.',
['残丨']='残丨梦:BAABLgAFFH8IAAISAAMJ0xBpGgCXAAASAAMJ0xBpGgCXAAAAAA==.',
['殺袈']='殺袈:BAAALgADCgYJBgAAAA==.',
['毁梦']='毁梦:BAABLgAFFH8HAAIBAAMJCh+RIwAqAQABAAMJCh+RIwAqAQAAAA==.',
['比洋']='比洋芋还子弟:BAAALgADCgYJBQAAAA==.',
['毛乐']='毛乐:BAACLgAFFH8HAAIJAAIJTx8mFQC7AAAJAAIJTx8mFQC7AAAuAAQKfxcAAgkABwnrIkkSAKMCAAkABwnrIkkSAKMCAAAA.',
['水墨']='水墨青花:BAAALgADCgYJBgAAAA==.',
['水濑']='水濑名雪:BAABLgAFFH8GAAIGAAMJ9g/4BQCxAAAGAAMJ9g/4BQCxAAAAAA==.',
['永夜']='永夜的极光:BAAALgAECgkJCQAAAA==.',
['永恒']='永恒审判:BAAALgAECgYJBgAAAA==.',
['汤姆']='汤姆哈迪:BAAALgADCgIJAgAAAA==.',
['沉沦']='沉沦与遐想:BAAALgAECgcJBgAAAA==.',
['沐沐']='沐沐岚:BAAALgADCgEJAQAAAA==.',
['没虱']='没虱子的牛:BAAALgADCgQJBAAAAA==.',
['油炸']='油炸土克勒:BAAALgADCgUJCwAAAA==.',
['法海']='法海:BAAALgAECgcJBAAAAA==.',
['泰瑞']='泰瑞迩:BAAALgAECgEJAQAAAA==.',
['流浪']='流浪的烟壳儿:BAAALgAECgEJAQAAAA==.流浪的烟灰:BAAALgAECgEJAgAAAA==.流浪的烟盒儿:BAAALgAECgEJAQAAAA==.流浪的香烟盒:BAAALgAECgEJAQAAAA==.',
['浅唱']='浅唱灬天空:BAAALgAECgEJAQAAAA==.',
['海德']='海德拉:BAAALgAECgcJDQAAAA==.',
['清揽']='清揽明辉:BAAALgAECgEJAQAAAA==.',
['清风']='清风:BAAALgAECgYJBgAAAA==.',
['源丶']='源丶纆:BAAALgADCgYJBgAAAA==.',
['滚滚']='滚滚长江:BAAALgAECgYJDgAAAA==.',
['漂流']='漂流瓶:BAAALgAECgMJAgAAAA==.',
['漫漫']='漫漫:BAAALgADCgcJBwAAAA==.',
['澜沧']='澜沧:BAAALgAFFAMJAwAAAA==.',
['濠柒']='濠柒灬柒彩:BAAALgAECgQJBAAAAA==.',
['灬玄']='灬玄玉:BAAALgAFFAIJAwAAAA==.',
['灬辣']='灬辣个和尚灬:BAAALgAFFAEJAQAAAA==.灬辣个锁甲灬:BAAALgADCgUJBQAAAA==.',
['点子']='点子大王:BAAALgAECgUJBgAAAA==.',
['煤气']='煤气罐贝贝:BAAALgAECgYJBwAAAA==.',
['熔火']='熔火幸运星:BAABLgAECn8ZAAIBAAgJ9hI4aAAGAgABAAgJ9hI4aAAGAgAAAA==.',
['燃烧']='燃烧瓶:BAAALgAECgQJAgAAAA==.',
['爱吃']='爱吃阿尔卑斯:BAAALgAECgYJDAAAAA==.',
['牛大']='牛大帅:BAABLgAFFH8MAAMWAAQJ1STwAACMAQAWAAQJeCPwAACMAQACAAMJjRL1EwD/AAAAAA==.',
['牧小']='牧小雅:BAACLgAFFH8JAAMLAAQJ3Az3CADYAAAQAAQJfgXvCwAaAQALAAMJ4w/3CADYAAAuAAQKfzIAAxAABwnkHyQOAFgCABAABwlKHCQOAFgCAAsABglMHAIoAK8BAAAA.',
['狂暴']='狂暴彩虹:BAAALgADCgQJBAAAAA==.',
['狩猎']='狩猎者:BAAALgAECgIJAgAAAA==.',
['猗窝']='猗窝座:BAABLgAFFH8FAAIMAAUJdRraAADEAQAMAAUJdRraAADEAQAAAA==.',
['猪蹄']='猪蹄配米饭:BAAALgAECgEJAQAAAA==.',
['猫南']='猫南北:BAAALgAECgIJAgAAAA==.',
['玛维']='玛维影歌:BAAALgAECgUJBQAAAA==.',
['理塘']='理塘丁真:BAAALgAECgcJDwAAAA==.',
['琉璃']='琉璃龙龙:BAAALgAECgQJBQABLgAECgcJDwAKAAAAAA==.',
['琪琪']='琪琪与牛牛:BAAALgAECgEJAQAAAA==.',
['瓦合']='瓦合:BAAALgAFFAEJAQAAAA==.',
['百理']='百理屠苏:BAAALgADCgEJAQAAAA==.',
['目中']='目中无人:BAAALgAECgQJBAAAAA==.',
['真水']='真水幽香:BAABLgAECn8ZAAIBAAgJOBZjTQBPAgABAAgJOBZjTQBPAgAAAA==.',
['瞌睡']='瞌睡虫贝贝:BAABLgAECn8eAAIYAAgJZw3ZHwC/AQAYAAgJZw3ZHwC/AQAAAA==.',
['瞧瞧']='瞧瞧看:BAAALgADCgUJBQAAAA==.',
['破晓']='破晓晨光:BAAALgAECgYJBgAAAA==.',
['祝踏']='祝踏峰:BAAALgADCgEJAQAAAA==.',
['祸祸']='祸祸牛:BAAALgADCgcJBwAAAA==.',
['秋名']='秋名山司机:BAAALgADCgMJAwAAAA==.',
['秋水']='秋水流离雪:BAAALgAECgcJAQAAAA==.',
['科雷']='科雷达卡莱:BAAALgAFFAEJAQAAAA==.',
['程雨']='程雨欣:BAABLgAFFH8FAAIRAAQJqhT1CABgAQARAAQJqhT1CABgAQAAAA==.',
['第二']='第二只鼬鼬:BAAALgADCgEJAQAAAA==.',
['筱筱']='筱筱牧:BAAALgAECgMJBAAAAA==.',
['粉色']='粉色的阿江:BAAALgAECgYJDQAAAA==.',
['红烧']='红烧牛肉:BAAALgAECgEJAQAAAA==.',
['红色']='红色的阿江:BAAALgADCgEJAQAAAA==.',
['罐儿']='罐儿:BAAALgAECgkJCQAAAA==.',
['罒鳕']='罒鳕熊罒:BAABLgAECn8VAAIMAAcJyR67FwBYAgAMAAcJyR67FwBYAgAAAA==.',
['老惡']='老惡魔:BAAALgAECgEJAgAAAA==.',
['老舅']='老舅老舅:BAAALgAECgYJBgAAAA==.',
['老衲']='老衲略懂拳脚:BAAALgAECgkJBwAAAA==.',
['考斯']='考斯乄韦恩:BAAALgAFFAQJBAABLgAFFAUJEAATAC8lAA==.',
['胖胖']='胖胖的喜羊羊:BAACLgAFFH8HAAIHAAMJjiDgHAAvAQAHAAMJjiDgHAAvAQAuAAQKfxkAAgcACAlZIFgdANACAAcACAlZIFgdANACAAAA.',
['脆皮']='脆皮松子:BAAALgADCgIJAgAAAA==.',
['艾莉']='艾莉克希尔:BAAALgAECgYJBgAAAA==.',
['芒灬']='芒灬果:BAABLgAFFH8HAAIPAAMJjRT7FgD1AAAPAAMJjRT7FgD1AAAAAA==.',
['芣洁']='芣洁灬靈魂:BAAALgAECgQJBQAAAA==.',
['花式']='花式抗亮:BAAALgAECgUJBgAAAA==.',
['花衬']='花衬衫:BAAALgAECgUJBQABLgAECgcJEgAKAAAAAA==.',
['英皇']='英皇丶美屡:BAAALgAFFAEJAQAAAA==.',
['范老']='范老师:BAAALgAECgQJCQAAAA==.范老師:BAAALgAECgYJCAAAAA==.',
['范迪']='范迪塞迩:BAAALgAFFAEJAQAAAA==.',
['草莓']='草莓酱:BAAALgAECggJCwAAAA==.',
['药王']='药王孙思邈:BAAALgAECgcJBwAAAA==.',
['萌国']='萌国大将军:BAAALgAECgcJBwAAAA==.',
['萌萌']='萌萌的柳絮:BAABLgAECn8fAAIPAAkJ2R4RCABUAwAPAAkJ2R4RCABUAwAAAA==.',
['萨拉']='萨拉米肠:BAAALgAECgUJBQAAAA==.萨拉达尔:BAAALgAFFAEJAgAAAA==.',
['萨穆']='萨穆罗丨甜瓜:BAAALgAECgUJDAAAAA==.',
['萨罗']='萨罗尼奥:BAAALgADCgYJBgAAAA==.',
['落尽']='落尽桃花:BAAALgAECgEJAQAAAA==.',
['蓉城']='蓉城大熊猫:BAAALgADCgcJCAABLgAFFAQJBAAKAAAAAA==.',
['蛮一']='蛮一爷:BAAALgADCgUJBQAAAA==.',
['蜉蝣']='蜉蝣:BAAALgAECgYJCgAAAA==.',
['言是']='言是非:BAAALgAECgIJAgAAAA==.',
['譞雨']='譞雨:BAAALgAECgYJEgAAAA==.',
['谢道']='谢道韫:BAAALgAECgYJCwAAAA==.',
['贪财']='贪财的阿江:BAAALgAECgcJEQAAAA==.',
['赤爪']='赤爪:BAAALgAFFAEJAQAAAA==.',
['赫墨']='赫墨拉:BAAALgADCgYJCwAAAA==.',
['超级']='超级陨石坑:BAAALgAECgYJBgAAAA==.',
['距离']='距离感:BAABLgAFFH8HAAIUAAUJ4yBjBADsAQAUAAUJ4yBjBADsAQAAAA==.',
['连名']='连名带姓:BAAALgAECgQJBAAAAA==.',
['迪奥']='迪奥普罗墨斯:BAAALgAECgEJAQAAAA==.',
['迪许']='迪许蒙格:BAAALgADCgEJAQAAAA==.',
['迷途']='迷途的未来:BAAALgAECgcJBwAAAA==.',
['那時']='那時老爺爺:BAAALgAFFAEJAQAAAA==.',
['那片']='那片花海:BAAALgAECgMJAwAAAA==.',
['邪修']='邪修丶哈基德:BAAALgADCgcJCwAAAA==.',
['郝若']='郝若溪:BAAALgAECgYJCgAAAA==.',
['都是']='都是我的锅丶:BAAALgAECgYJCQAAAA==.',
['野玫']='野玫瑰:BAAALgAECgEJAQAAAA==.',
['锥生']='锥生一缕:BAAALgAECgUJDAAAAA==.',
['镜中']='镜中仙:BAAALgADCgUJIQAAAA==.',
['长留']='长留:BAAALgADCgQJBAAAAA==.',
['闪电']='闪电丶五连鞭:BAAALgAECgQJBgAAAA==.',
['阿加']='阿加西巛:BAAALgAECgEJAQAAAA==.',
['阿多']='阿多:BAAALgAECgIJAwAAAA==.',
['阿尔']='阿尔托莉娅:BAAALgADCgYJBgABLgADCgcJBwAKAAAAAA==.',
['阿莉']='阿莉雅之笛:BAAALgAECgUJBwAAAA==.',
['隋右']='隋右边:BAAALgAECgkJCQAAAA==.',
['雅克']='雅克洪尼斯特:BAACLgAFFH8FAAIPAAIJ3gqYJwCaAAAPAAIJ3gqYJwCaAAAuAAQKfyEAAw8ABwmEIEQ3AEYCAA8ABwmEIEQ3AEYCABkABgm7CLYrAK8AAAAA.',
['雅静']='雅静:BAAALgAECgEJAQAAAA==.',
['雨帆']='雨帆儿:BAAALgAECgEJAQAAAA==.',
['雪糕']='雪糕可凉了:BAAALgAECgEJAQAAAA==.',
['静雅']='静雅:BAAALgAECgEJAQAAAA==.',
['非洲']='非洲大洋芋:BAAALgAECgUJBQAAAA==.',
['韭菜']='韭菜花:BAAALgAECgYJCAAAAA==.韭菜芽:BAAALgAECgEJAQAAAA==.韭菜苗:BAAALgAECgEJAQAAAA==.',
['顶得']='顶得住哦:BAAALgAECgQJBAAAAA==.',
['顶瓜']='顶瓜瓜:BAAALgAECgMJAwAAAA==.',
['预修']='预修亡:BAAALgADCgMJAwAAAA==.',
['风吹']='风吹雪:BAACLgAFFH8QAAIYAAUJBxUlAQCoAQAYAAUJBxUlAQCoAQAuAAQKfywAAhgACQlyJLwAAMsDABgACQlyJLwAAMsDAAAA.',
['风神']='风神的神德:BAABLgAECn8dAAMIAAcJTxH4MgCOAQAIAAcJTxH4MgCOAQAMAAYJ6QWBZQD4AAAAAA==.',
['风蛇']='风蛇:BAAALgAECgEJAQAAAA==.',
['飘箭']='飘箭十三郎:BAAALgAECgMJAwAAAA==.',
['饿了']='饿了抠一块儿:BAAALgAECgEJAgAAAA==.',
['马驴']='马驴脸猛鹿:BAAALgADCgUJBQAAAA==.',
['驯麓']='驯麓:BAAALgAECgEJAQAAAA==.',
['高大']='高大帅男雕弩:BAAALgAECgUJBAAAAA==.',
['高德']='高德发:BAAALgAECgEJAQABLgAFFAEJAQAKAAAAAA==.',
['魂魄']='魂魄妖夢:BAAALgAFFAIJAgAAAA==.',
['魅影']='魅影丶塞隆:BAAALgAECgIJAgAAAA==.魅影姬:BAAALgADCgUJBQAAAA==.',
['鸦鸦']='鸦鸦的小影子:BAAALgAECgIJAgABLgAFFAYJBgAGAAkSAA==.',
['鹹菜']='鹹菜:BAAALgAFFAIJAgAAAA==.',
['鹿鸣']='鹿鸣之什:BAABLgAECn8cAAMaAAYJmh/SIwA6AQAbAAQJ/Ry/fABiAQAaAAQJYRzSIwA6AQAAAA==.',
['黄泉']='黄泉枫:BAAALgAECgYJBQAAAA==.',
['黑嘟']='黑嘟嘟:BAAALgAFFAQJAgAAAA==.',
['黑崎']='黑崎八千:BAAALgAECgQJBQAAAA==.',
['黑龙']='黑龙的阿江:BAAALgAECgEJAQAAAA==.',
['默涩']='默涩:BAAALgAECgQJBAAAAA==.',
['龙女']='龙女神月:BAAALgADCgEJAQAAAA==.',
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
