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

local lookup = {'DeathKnight-Unholy','DeathKnight-Blood','Mage-Frost','Monk-Brewmaster','Evoker-Augmentation','Evoker-Devastation','Rogue-Subtlety','Paladin-Holy','Paladin-Retribution','Warrior-Protection','DemonHunter-Havoc','DemonHunter-Devourer','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Restoration','Monk-Mistweaver','Priest-Shadow','Priest-Holy','Priest-Discipline','Warlock-Demonology','Warlock-Destruction','Evoker-Preservation','Unknown-Unknown','Rogue-Assassination',}
local provider = {region='CN',realm='普罗德摩',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ad='Adama:BAAALgAECgEJAgAAAA==.',
An='Angaby:BAAALgAFFAIJAgAAAA==.',
As='Ashenone:BAAALgAECgcJDQAAAA==.Ashesthree:BAAALgAFFAUJAQAAAA==.',
Be='Becky:BAAALgADCgEJAQAAAA==.',
Bi='Biubiubiu:BAAALgAECgQJBAABLgAFFAIJBgABAOcfAA==.',
Bl='Bloodseeker:BAAALgADCgQJBAABLgAFFAIJBgABAOcfAA==.',
Br='Brabbit:BAAALgAECgMJAwAAAA==.Brandon:BAAALgADCgMJAwAAAA==.',
Bu='Bubbakush:BAAALgAFFAEJAQAAAA==.',
Da='Daniel:BAAALgADCgMJAwAAAA==.',
Dd='Ddxx:BAAALgAECgYJDAAAAA==.',
Dk='Dk:BAACLgAFFH8KAAICAAQJFAn3CQDkAAACAAQJFAn3CQDkAAAuAAQKfyIAAgIACAnzFDMSAOgBAAIACAnzFDMSAOgBAAAA.',
Do='Dolarex:BAAALgAECgIJAQAAAA==.',
Dy='Dylandk:BAACLgAFFH8WAAMBAAYJCSJDAgDyAQABAAUJCSJDAgDyAQACAAEJAACUDAAAAAAuAAQKfyMAAgEACAn8JAoOACsDAAEACAn8JAoOACsDAAAA.',
Em='Emma:BAAALgADCgEJAQAAAA==.',
Gu='Guccb:BAAALgADCgYJBgAAAA==.',
Im='Imxlol:BAAALgADCgYJBwAAAA==.',
Jo='Johnnybgoode:BAABLgAFFH8GAAIBAAQJGx6NDABxAQABAAQJGx6NDABxAQAAAA==.',
Le='Letmess:BAAALgAFFAEJAQAAAA==.',
Lo='Lowo:BAAALgAFFAIJAgAAAA==.',
Ma='Maniac:BAABLgAFFH8GAAIDAAIJzhvgQwCoAAADAAIJzhvgQwCoAAAAAA==.Manndala:BAAALgAECgcJDAAAAA==.Marika:BAAALgAECgUJCQAAAA==.',
Ol='Olivan:BAAALgAECgUJBgAAAA==.',
Os='Oscar:BAAALgADCgEJAQAAAA==.',
Pi='Piekarz:BAAALgADCgEJAQAAAA==.',
Ry='Ryms:BAAALgAECgQJBAAAAA==.',
Ul='Uliana:BAAALgAECgYJBgAAAA==.',
Wd='Wdxpg:BAABLgAFFH8FAAIDAAMJ5RDiOgC1AAADAAMJ5RDiOgC1AAAAAA==.',
Wh='Which:BAAALgAECgEJAQAAAA==.',
Xi='Ximiko:BAAALgAECgIJAgAAAA==.',
Xx='Xxcc:BAAALgAECgUJDQAAAA==.',
['一一']='一一壹佰:BAAALgAECgEJAQAAAA==.一一得伊:BAAALgAECgUJBQAAAA==.一一点点:BAAALgAECgQJBAAAAA==.',
['一米']='一米五八:BAAALgAFFAUJAgAAAA==.',
['一起']='一起笑看風雲:BAAALgAECgcJEwAAAA==.',
['一路']='一路顺发旺:BAAALgAECgkJBgAAAA==.',
['一键']='一键:BAAALgAECgEJAgAAAA==.',
['一非']='一非礼勿听一:BAAALgADCgUJBQAAAA==.',
['一颠']='一颠颠:BAAALgAECgkJCQAAAA==.',
['三分']='三分归元气:BAAALgAECgIJAwAAAA==.',
['三笠']='三笠一阿克曼:BAAALgAECgIJAgAAAA==.',
['不会']='不会汪汪:BAAALgAECgIJAgAAAA==.',
['不再']='不再游泳:BAAALgAECgQJBgAAAA==.',
['不动']='不动咕咕:BAAALgAECgIJAgAAAA==.不动熊猫:BAACLgAFFH8KAAIEAAQJqw78DAAdAQAEAAQJqw78DAAdAQAuAAQKfyIAAgQACAleFc8eAAsCAAQACAleFc8eAAsCAAAA.',
['丛林']='丛林啊猫:BAAALgADCgIJAgAAAA==.',
['丝黛']='丝黛拉苟萨:BAACLgAFFH8WAAMFAAYJpyHFAQBHAgAFAAYJpyHFAQBHAgAGAAEJoAvuAgBMAAAuAAQKfyEAAwUACQmPIWoCAIoDAAUACQmPIWoCAIoDAAYABwmxG54RAMUBAAAA.',
['丨假']='丨假面丨:BAAALgAECgYJCgAAAA==.',
['丶丶']='丶丶通丶:BAAALgAECgEJAgAAAA==.',
['丶流']='丶流星蝴蝶剑:BAAALgAECgYJBwAAAA==.',
['仆街']='仆街丶:BAAALgADCgEJAQAAAA==.',
['他毁']='他毁谤我啊:BAAALgAECgYJBgAAAA==.',
['代课']='代课老师师:BAAALgAECgUJCAAAAA==.',
['以得']='以得俘人:BAAALgADCgUJBwAAAA==.',
['伊普']='伊普利斯:BAAALgAECgEJAgAAAA==.',
['伊谢']='伊谢尔丶风歌:BAAALgAECgMJAwAAAA==.',
['你是']='你是柚子:BAAALgAECgQJBAABLgAFFAIJBgABAOcfAA==.',
['俺也']='俺也德:BAAALgAECgYJBgAAAA==.',
['偷心']='偷心贼零命中:BAACLgAFFH8FAAIHAAIJ3QqvCQCjAAAHAAIJ3QqvCQCjAAAuAAQKfxoAAgcABwkDGaAcABoCAAcABwkDGaAcABoCAAAA.',
['光兄']='光兄:BAAALgAFFAIJAgABLgAFFAYJBgAGAAkSAA==.',
['兔必']='兔必琅勃湾:BAAALgAECgEJAQAAAA==.',
['再现']='再现天骄:BAAALgAECgIJAwAAAA==.',
['冰泪']='冰泪:BAAALgAECgIJAgAAAA==.',
['刁炸']='刁炸天:BAAALgADCgYJBgAAAA==.',
['划船']='划船不用桨:BAAALgAFFAIJAgAAAA==.',
['划过']='划过天空的砖:BAAALgAECgEJAQAAAA==.',
['初翎']='初翎丶山风:BAAALgAECgYJCwAAAA==.',
['别处']='别处一:BAAALgAFFAIJAgABLgAFFAYJCQAFAFcfAA==.别处七:BAAALgAFFAIJAgABLgAFFAYJCQAFAFcfAA==.别处三:BAAALgAFFAQJBAAAAA==.别处九:BAAALgAFFAIJAgABLgAFFAYJCQAFAFcfAA==.别处五:BAABLgAFFH8JAAMFAAYJVx9lAAADAgAFAAUJVx9lAAADAgAGAAEJAABYAwAAAAAAAA==.别处八:BAAALgAFFAQJBAABLgAFFAYJCQAFAFcfAA==.别处六:BAAALgAFFAIJAgAAAA==.',
['劈色']='劈色特弄:BAAALgAECgYJEAAAAA==.',
['加到']='加到你吐奶:BAAALgAFFAIJAgABLgAFFAQJBwAIAEgVAA==.',
['医疗']='医疗训练假人:BAAALgAFFAEJAQAAAA==.',
['匿迹']='匿迹:BAABLgAFFH8KAAIJAAQJmhv1CABnAQAJAAQJmhv1CABnAQAAAA==.',
['单玉']='单玉:BAAALgAECgcJEAAAAA==.',
['南山']='南山千江流:BAAALgAECgkJBgAAAA==.',
['卡其']='卡其的小布藕:BAABLgAECn8dAAIKAAgJpxErFwCfAQAKAAgJpxErFwCfAQAAAA==.',
['卡沙']='卡沙:BAAALgAECggJDQAAAA==.',
['名字']='名字不太长:BAAALgAECgYJBgABLgAFFAYJCwADAL0cAA==.',
['含剎']='含剎射影:BAAALgAECgUJBQAAAA==.',
['吴名']='吴名英雄:BAAALgAECgkJEwAAAA==.',
['咒夜']='咒夜:BAAALgADCgUJBQAAAA==.',
['啊对']='啊对对對:BAAALgAFFAQJBAAAAA==.',
['喵喵']='喵喵蕾:BAAALgAECgMJAwAAAA==.',
['嘟嘟']='嘟嘟侠:BAAALgAECgEJAQAAAA==.',
['图力']='图力深:BAAALgAECgYJEQAAAA==.',
['圆心']='圆心:BAAALgAECgcJCAAAAA==.',
['圣光']='圣光照亮涛:BAAALgAECgMJAwAAAA==.圣光红叶:BAAALgAECgEJAgAAAA==.圣光蔷薇:BAAALgAECgUJBQAAAA==.',
['堕落']='堕落灬兽狩:BAAALgAECgEJAQAAAA==.堕落灬聖光:BAAALgAECgEJAwAAAA==.堕落灬魂焱:BAAALgAECgEJAQAAAA==.',
['壹伍']='壹伍零壹:BAABLgAECn8cAAMLAAgJ/hnqFgASAgALAAgJ/hnqFgASAgAMAAYJFRCdcwBKAQAAAA==.',
['壹支']='壹支穿云箭:BAAALgAECgYJBgAAAA==.',
['夜芷']='夜芷枫:BAAALgAECgUJBQAAAA==.夜芷长弓:BAABLgAECn8YAAMNAAgJwB28HQBUAgANAAgJKhy8HQBUAgAOAAUJiRZRSwAkAQAAAA==.',
['大晶']='大晶晶:BAAALgAECgEJAQAAAA==.',
['大笑']='大笑红尘:BAAALgAECgYJCAAAAA==.',
['大郎']='大郎该喝药啦:BAAALgAFFAIJAQAAAA==.',
['天生']='天生血无情:BAAALgAECgEJAgAAAA==.',
['头上']='头上带点绿:BAACLgAFFH8NAAILAAQJXyQOAQCtAQALAAQJXyQOAQCtAQAuAAQKfx4AAwsACAl1Jn4BAJQDAAsACAl1Jn4BAJQDAAwAAQnKGB3UAEoAAAAA.',
['女神']='女神的宝宝:BAABLgAECn8dAAIPAAgJ0SANFQCOAgAPAAgJ0SANFQCOAgAAAA==.',
['奶一']='奶一口:BAAALgAFFAQJBAABLgAFFAcJBwAQACIHAA==.',
['奶酪']='奶酪猪猪:BAAALgAECgEJAQAAAA==.',
['安妮']='安妮女王:BAAALgAECgEJAQAAAA==.',
['安西']='安西香二十七:BAAALgAFFAQJBAABLgAFFAYJEgARADAaAA==.',
['小指']='小指头艾瑞克:BAAALgAECgEJAQAAAA==.',
['小猪']='小猪哥:BAAALgAECgUJCwAAAA==.',
['尛沫']='尛沫沫:BAAALgAECgYJBgAAAA==.',
['尼古']='尼古丁真:BAAALgADCgUJBQAAAA==.',
['尼妹']='尼妹丶贵姓:BAAALgAECgYJCwAAAA==.',
['岚川']='岚川:BAAALgAECgcJBwAAAA==.',
['帝隐']='帝隐:BAAALgAFFAIJBAAAAA==.',
['席尔']='席尔瓦纳斯:BAAALgADCgUJBQAAAA==.',
['干锅']='干锅李冬柏:BAABLgAFFH8RAAMBAAcJ1R0PAABuAgABAAYJ1R0PAABuAgACAAEJAAA1FgBBAAAAAA==.',
['平凡']='平凡萨:BAAALgAECgUJDAAAAA==.',
['广汉']='广汉沙舵爷:BAAALgAECgYJBgAAAA==.',
['弓箭']='弓箭手腿子:BAAALgAECgIJAwAAAA==.',
['强强']='强强:BAABLgAFFH8JAAIBAAUJmQ8+CQCHAQABAAUJmQ8+CQCHAQAAAA==.',
['怀武']='怀武侠梦:BAAALgAECgIJAgAAAA==.',
['怜夜']='怜夜:BAABLgAFFH8GAAIBAAIJ5x+bNAC2AAABAAIJ5x+bNAC2AAAAAA==.',
['惩魔']='惩魔导:BAAALgAECgEJAgAAAA==.',
['懵懵']='懵懵小术:BAAALgADCgEJAQAAAA==.',
['我蚌']='我蚌埠住了:BAAALgAECgcJBwAAAA==.',
['战地']='战地之鹰:BAAALgADCgYJBgAAAA==.',
['战霸']='战霸天:BAAALgAECgEJAgAAAA==.',
['找人']='找人弄你:BAABLgAFFH8QAAMBAAcJ9h8QAABtAgABAAYJ9h8QAABtAgACAAEJAACvDAAAAAAAAA==.',
['拉门']='拉门收费五毛:BAAALgAECgIJAgAAAA==.',
['搞樂']='搞樂:BAAALgAFFAEJAQAAAA==.',
['摘星']='摘星咕咕:BAAALgAECgEJAwAAAA==.摘星辰大师:BAAALgAECgEJAQAAAA==.',
['新被']='新被宾风:BAAALgAECgMJBAAAAA==.',
['无聊']='无聊骑:BAABLgAECn8rAAIIAAgJNB+uAwBCAgAIAAgJNB+uAwBCAgAAAA==.',
['无良']='无良毒奶:BAAALgADCgQJBAAAAA==.',
['旧神']='旧神复苏:BAAALgAECgYJDgAAAA==.',
['明夕']='明夕灬:BAAALgADCgYJBgAAAA==.',
['星月']='星月海:BAAALgAECgYJCgAAAA==.',
['星海']='星海魁使:BAAALgADCgIJAgAAAA==.',
['星眸']='星眸:BAABLgAFFH8FAAIDAAMJAwOIMQDnAAADAAMJAwOIMQDnAAAAAA==.',
['是秀']='是秀虎呀:BAAALgADCgUJBQAAAA==.',
['晓晓']='晓晓虎:BAAALgAECgQJBAAAAA==.',
['普罗']='普罗提诺:BAAALgAECgIJBAAAAA==.',
['暗影']='暗影幽寒:BAAALgADCgEJAQAAAA==.',
['暗电']='暗电火闪:BAAALgAECgEJAQAAAA==.',
['暗黑']='暗黑姬:BAAALgAECgYJDAAAAA==.',
['暮冬']='暮冬:BAAALgAECgYJEAABLgAFFAIJBgABAOcfAA==.',
['暮色']='暮色灬晨曦:BAAALgAECgEJAQAAAA==.',
['暮雨']='暮雨菲菲:BAAALgAECgEJAQAAAA==.',
['曌熙']='曌熙帝:BAAALgAFFAMJAwAAAA==.',
['最爱']='最爱吐司边儿:BAAALgAECgkJCwAAAA==.',
['月光']='月光魅影:BAAALgADCgYJBgAAAA==.',
['月袭']='月袭人:BAAALgAECggJDwAAAA==.',
['李小']='李小黑:BAAALgADCgEJAQAAAA==.',
['村长']='村长:BAAALgAECgYJBgAAAA==.',
['杨幂']='杨幂的奶:BAAALgADCgMJBAAAAA==.',
['柳馨']='柳馨:BAAALgAECgcJBwAAAA==.',
['格子']='格子:BAAALgAECgUJBQAAAA==.',
['桑葚']='桑葚:BAACLgAFFH8PAAMSAAQJgBV4BABAAQASAAQJgBV4BABAAQATAAEJzwGEGwBAAAAuAAQKfycAAxIACAlqH7EHANACABIACAlqH7EHANACABMABAlqEpc1APcAAAAA.',
['梦一']='梦一样自由:BAAALgAECgYJCQAAAA==.',
['楼烦']='楼烦将:BAAALgAECgQJCAAAAA==.',
['武汉']='武汉欢欢:BAABLgAECn8cAAMBAAgJwBRQHgAqAQABAAgJJxNQHgAqAQACAAEJYBmvQQBEAAAAAA==.武汉歡歡:BAAALgAECgYJBgAAAA==.',
['死亡']='死亡一:BAABLgAFFH8JAAMBAAUJpRQeFgBLAQABAAQJpRQeFgBLAQACAAEJAACxGwArAAAAAA==.死亡三:BAABLgAFFH8GAAIBAAQJrxbtGQA+AQABAAQJrxbtGQA+AQAAAA==.死亡二:BAABLgAFFH8IAAMBAAUJNBC9FwBGAQABAAQJNBC9FwBGAQACAAEJAAD/EgBbAAAAAA==.死亡伴你行:BAAALgAECgMJAQAAAA==.死亡四:BAABLgAFFH8IAAMBAAYJ1BM/BQCtAQABAAUJ1BM/BQCtAQACAAEJAABcGQA3AAAAAA==.',
['殁境']='殁境神蚀者:BAAALgAECggJDgAAAA==.',
['比利']='比利大魔王:BAAALgAECgUJBgAAAA==.',
['毛兄']='毛兄:BAAALgAECgIJAgAAAA==.',
['气刃']='气刃兜割:BAACLgAFFH8GAAIEAAMJlRT5EQDsAAAEAAMJlRT5EQDsAAAuAAQKfxkAAgQACAm5HgESAIQCAAQACAm5HgESAIQCAAAA.',
['水晶']='水晶葡萄紫:BAAALgAECgYJBgAAAA==.',
['永夜']='永夜丶无眠:BAAALgAECgUJAgAAAA==.',
['没用']='没用的阿吉:BAAALgAECgcJBwAAAA==.',
['法拉']='法拉利猴:BAABLgAFFH8JAAMBAAYJZCHrAQABAgABAAUJZCHrAQABAgACAAEJAAAxFQBGAAAAAA==.',
['泠逸']='泠逸尘:BAAALgAECgkJBwAAAA==.',
['波波']='波波奶射:BAAALgAECgQJBAAAAA==.',
['泥奏']='泥奏凯:BAAALgAECgIJAgAAAA==.',
['洛丹']='洛丹伦的夕阳:BAAALgAECgMJAwAAAA==.',
['洛洛']='洛洛白:BAACLgAFFH8RAAIUAAUJrxsiBADeAQAUAAUJrxsiBADeAQAuAAQKfycAAxQACQkfI1UDAIsDABQACQkfI1UDAIsDABUAAgmbGc9OAIEAAAAA.',
['海豚']='海豚啊:BAAALgAECgMJAwAAAA==.',
['淦绿']='淦绿哥:BAACLgAFFH8LAAMFAAQJJgUmDwAPAQAFAAQJJgUmDwAPAQAWAAIJDQL/EwCJAAAuAAQKfx8ABAUABwkwFPclAI0BAAUABwkwFPclAI0BABYABgk6B9MwAOoAAAYAAQmQBFlDACgAAAAA.',
['清风']='清风之弦:BAAALgADCgUJBQAAAA==.',
['湿兄']='湿兄:BAAALgAECgIJAgAAAA==.',
['火云']='火云无刀:BAAALgADCgEJAQAAAA==.',
['灬欧']='灬欧尼酱灬:BAAALgAFFAcJBAAAAA==.',
['灰常']='灰常荡:BAAALgAECgcJEgAAAA==.',
['灵魂']='灵魂修行者:BAAALgADCgMJAwAAAA==.',
['爱上']='爱上王老吉:BAAALgAFFAEJAQAAAA==.',
['爱吃']='爱吃烤榴莲:BAAALgAECgEJAgAAAA==.',
['牛牛']='牛牛不怕黑:BAAALgADCgUJBQAAAA==.',
['牛糊']='牛糊螂:BAAALgAECgYJBwAAAA==.',
['犯错']='犯错的夏天:BAAALgAECgkJAgAAAA==.',
['狐兄']='狐兄:BAAALgAECgQJBAAAAA==.',
['狐小']='狐小魔:BAAALgADCgUJBQAAAA==.',
['独孤']='独孤宁珂:BAAALgADCgIJAQAAAA==.',
['猪猪']='猪猪:BAAALgAECgEJAwAAAA==.',
['猫猫']='猫猫丶:BAAALgAECgIJAgAAAA==.',
['王局']='王局:BAAALgADCgUJBQAAAA==.',
['玛卡']='玛卡巴卡姆:BAAALgAECgEJAQAAAA==.',
['珊蒂']='珊蒂斯丶风歌:BAAALgADCgYJBgAAAA==.',
['电拿']='电拿杨师傅:BAAALgAECgYJDAAAAA==.',
['百乱']='百乱喵多喵多:BAAALgAECgcJBwAAAA==.',
['百事']='百事可爱:BAAALgADCgUJBQAAAA==.',
['皮皮']='皮皮酱:BAAALgAECgEJAQAAAA==.',
['盐水']='盐水凤梨:BAABLgAFFH8JAAMOAAUJEx/PBADlAQAOAAUJEx/PBADlAQANAAMJdBeQEADDAAAAAA==.',
['破沧']='破沧海:BAAALgAECgEJAQAAAA==.',
['碌七']='碌七输大晒:BAAALgADCgMJAwAAAA==.',
['神射']='神射:BAAALgAECgcJBwAAAA==.',
['秀虎']='秀虎小分队:BAAALgAECgEJAQAAAA==.',
['秋过']='秋过落叶飞:BAAALgAECgIJAgAAAA==.',
['秋风']='秋风之刃:BAACLgAFFH8KAAISAAQJAhDiBAA4AQASAAQJAhDiBAA4AQAuAAQKfyEAAhIACAmGFHIcAPkBABIACAmGFHIcAPkBAAAA.',
['科鲁']='科鲁坦图:BAAALgAECgYJBgAAAA==.',
['空调']='空调不够冷:BAAALgADCgEJAQAAAA==.',
['紫嫣']='紫嫣水仙:BAAALgAFFAEJAQAAAA==.',
['紫星']='紫星东陨:BAAALgAECgYJBgAAAA==.',
['绚夜']='绚夜灬幻咒:BAAALgADCgYJBgAAAA==.',
['绽影']='绽影清枫:BAAALgAECgIJAgAAAA==.',
['老虎']='老虎怒吃肉:BAAALgAECgYJCQAAAA==.',
['背叛']='背叛者的怒火:BAAALgAECgYJCgAAAA==.',
['胖头']='胖头陀:BAAALgAECgUJCAAAAA==.',
['色孽']='色孽:BAAALgAECgcJBwAAAA==.',
['艾晓']='艾晓莎:BAAALgADCgIJAgABLgAFFAEJAQAXAAAAAA==.',
['花小']='花小花:BAABLgAFFH8FAAIOAAUJGxR2CACTAQAOAAUJGxR2CACTAQAAAA==.',
['苦行']='苦行僧猪猪:BAAALgADCgEJAQAAAA==.',
['草间']='草间乌鸦:BAAALgAECgIJAgAAAA==.',
['荣耀']='荣耀老地主:BAAALgAFFAEJAQAAAA==.',
['莱拉']='莱拉帕尼亚:BAAALgADCgUJBQAAAA==.',
['莹月']='莹月:BAAALgADCgkJCQAAAA==.',
['菇姑']='菇姑咕钴沽估:BAAALgAECgQJBAAAAA==.',
['葫芦']='葫芦妹:BAAALgAECgMJAgAAAA==.',
['蒲一']='蒲一蒲丶黎别:BAAALgAECgUJBgAAAA==.',
['蕾丷']='蕾丷蕾:BAAALgAECgEJAQAAAA==.',
['血祭']='血祭清道夫:BAAALgADCgYJBgAAAA==.',
['袁祺']='袁祺:BAAALgAECgEJAQAAAA==.',
['西尔']='西尔雅娜澌:BAAALgAECgcJBwAAAA==.',
['西逝']='西逝之秋:BAAALgAECgYJCwAAAA==.',
['西野']='西野七濑:BAAALgAECgEJAQAAAA==.',
['謸呜']='謸呜:BAACLgAFFH8KAAIVAAQJZhDQAAD+AAAVAAQJZhDQAAD+AAAuAAQKfyIAAhUACAn/HlgCAOgCABUACAn/HlgCAOgCAAAA.',
['该丶']='该丶隐:BAAALgAECgcJDAAAAA==.',
['谍影']='谍影重重:BAAALgAECgEJAgAAAA==.',
['豌豆']='豌豆苗苗:BAAALgAECgYJBgAAAA==.',
['豿嘿']='豿嘿丶:BAAALgAECgUJCQAAAA==.',
['贝塔']='贝塔的尾巴尖:BAAALgAECgEJAQAAAA==.',
['贝斯']='贝斯特拉:BAAALgAECgkJDQAAAA==.',
['贾斯']='贾斯丁盾墙:BAAALgAECgYJBgAAAA==.',
['赛丽']='赛丽亚:BAAALgAECgUJBQAAAA==.',
['赛亚']='赛亚小能人:BAAALgAECgYJCQAAAA==.',
['轱辘']='轱辘咕噜:BAAALgADCgUJBQAAAA==.',
['轻松']='轻松熊:BAAALgAECgEJAQAAAA==.',
['辰星']='辰星:BAAALgAFFAIJAgAAAA==.',
['迎接']='迎接你们的光:BAAALgAECgMJAwAAAA==.',
['还原']='还原靓靓拳:BAAALgAECgEJAQAAAA==.',
['进口']='进口香蕉丶:BAAALgAECgUJBgAAAA==.',
['迪丽']='迪丽热巴:BAAALgAECgIJAQAAAA==.',
['迪古']='迪古拉斯:BAAALgAFFAMJBAAAAA==.',
['迪斯']='迪斯路亞:BAAALgAECgYJBwAAAA==.',
['迪纳']='迪纳尔:BAAALgAECgIJAgAAAA==.',
['郁闷']='郁闷小恶:BAABLgAECn8dAAILAAgJfh1xDwBuAgALAAgJfh1xDwBuAgAAAA==.',
['钢铁']='钢铁守卫:BAAALgADCgEJAQAAAA==.',
['钱来']='钱来钱来:BAAALgAECgIJAgAAAA==.',
['铁头']='铁头娃:BAAALgAECgUJAgAAAA==.',
['镇山']='镇山掌:BAAALgAFFAEJAgAAAA==.',
['镜界']='镜界:BAAALgAECgEJAQAAAA==.',
['闪电']='闪电喵会圣疗:BAAALgAFFAEJAQAAAA==.',
['阿丶']='阿丶小狸:BAAALgAECgEJAQAAAA==.',
['阿尔']='阿尔特亚斯:BAAALgAECgUJBgAAAA==.',
['阿拉']='阿拉蕾:BAAALgAECgYJBgAAAA==.',
['阿斯']='阿斯芭甜丶:BAAALgAFFAEJAgAAAA==.',
['阿穆']='阿穆拉钉:BAAALgAECgcJCQAAAA==.',
['随型']='随型所欲:BAAALgAECgkJCQAAAA==.',
['随风']='随风领主:BAAALgAECgkJBQAAAA==.',
['隔壁']='隔壁大叔:BAAALgAECgEJAQAAAA==.',
['雅丽']='雅丽史卓莎:BAAALgAECgIJAgAAAA==.',
['露西']='露西拉:BAAALgADCgEJAQAAAA==.',
['霸气']='霸气小萝莉:BAAALgAECgYJBgAAAA==.',
['风丶']='风丶泣:BAAALgAECgQJBQAAAA==.',
['风神']='风神半月:BAABLgAFFH8FAAIJAAMJ1QkMJwCcAAAJAAMJ1QkMJwCcAAAAAA==.',
['飘飘']='飘飘:BAAALgAECgYJDQAAAA==.',
['飞天']='飞天鬼:BAAALgAECgUJBgAAAA==.',
['飞测']='飞测起了:BAAALgAECgMJAwAAAA==.',
['飞翔']='飞翔的雨滴:BAAALgADCgIJAgAAAA==.飞翔的飘乐:BAAALgADCgIJAgAAAA==.',
['香炸']='香炸牧羊犬:BAABLgAFFH8FAAIYAAUJ8hm3AADLAQAYAAUJ8hm3AADLAQAAAA==.',
['鱼柳']='鱼柳柳:BAAALgAECgYJCQAAAA==.',
['鹤瑶']='鹤瑶:BAAALgAFFAEJAQAAAA==.',
['黑加']='黑加吉小猫猫:BAAALgADCgEJAQAAAA==.',
['黑夜']='黑夜问白天:BAAALgAECgIJAgAAAA==.',
['黯淡']='黯淡雪姬:BAABLgAECn8SAAIUAAcJohpuDgCfAQAUAAcJohpuDgCfAQAAAA==.',
['龙二']='龙二医老斑鸠:BAAALgAECgMJAwAAAA==.',
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
