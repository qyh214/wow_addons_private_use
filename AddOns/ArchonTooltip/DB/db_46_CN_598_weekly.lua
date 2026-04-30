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

local lookup = {'Paladin-Retribution','DemonHunter-Havoc','DeathKnight-Unholy','Mage-Frost','Hunter-BeastMastery','Unknown-Unknown','Monk-Brewmaster','Priest-Shadow','Evoker-Augmentation','Monk-Mistweaver','Druid-Guardian','Priest-Holy','Priest-Discipline','Paladin-Holy','Warrior-Fury','Evoker-Preservation','Shaman-Restoration','Shaman-Elemental','Druid-Balance','Druid-Restoration','Evoker-Devastation','Rogue-Subtlety','Warrior-Protection','DemonHunter-Devourer',}
local provider = {region='CN',realm='卡德罗斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={An='Anyedeluyi:BAAALgAECgQJBgAAAA==.',
Au='Automata:BAAALgAFFAEJAQAAAA==.',
Bo='Boxter:BAACLgAFFH8LAAIBAAQJGCQMAQCbAQABAAQJGCQMAQCbAQAuAAQKfxQAAgEABwmXJc4RAAMDAAEABwmXJc4RAAMDAAAA.',
Ch='Chara:BAAALgAECgEJAQAAAA==.',
Cr='Cruelknight:BAAALgAECgEJAQAAAA==.',
Ga='Gardevoir:BAAALgAECgcJEgAAAA==.',
Gy='Gyshen:BAAALgAECgcJBgAAAA==.Gyshentt:BAAALgADCgcJBwAAAA==.',
In='Inseceqs:BAAALgAECgQJBAAAAA==.',
Le='Leftism:BAAALgAECgQJBAAAAA==.',
Mi='Miyo:BAABLgAECn8UAAICAAkJHSMjAQCuAwACAAkJHSMjAQCuAwAAAA==.',
Ne='Neuropathys:BAABLgAFFH8FAAIDAAQJGQ/9KwDrAAADAAQJGQ/9KwDrAAAAAA==.',
Pr='Prisdh:BAAALgAECgYJBgAAAA==.Priss:BAACLgAFFH8FAAIEAAMJHRpyPACzAAAEAAMJHRpyPACzAAAuAAQKfx8AAgQACAnnIycPAE4DAAQACAnnIycPAE4DAAAA.',
Sr='Srybwn:BAAALgAECgIJAgAAAA==.',
St='Stella:BAAALgAECgcJEwAAAA==.',
To='Touchmebaby:BAAALgAECgMJAwAAAA==.',
Vi='Vigo:BAAALgAFFAEJAQAAAA==.',
Vo='Volcano:BAAALgAECgEJAQAAAA==.',
Ya='Yangccwlk:BAAALgAECgQJBAAAAA==.',
Yu='Yukihunter:BAAALgAECgkJEAAAAA==.',
Yw='Ywenh:BAAALgAECgUJBQAAAA==.',
Zz='Zzil:BAAALgADCgEJAQAAAA==.',
['一缕']='一缕晚风:BAAALgAECgIJAgAAAA==.',
['万兽']='万兽之缰:BAAALgAECgUJBQAAAA==.',
['万念']='万念俱灰:BAAALgAECgMJAwAAAA==.',
['不一']='不一样的叶子:BAAALgAECgEJAQAAAA==.',
['不吃']='不吃肘击:BAAALgADCgYJBgAAAA==.',
['不玩']='不玩歪歪:BAAALgADCgcJBwAAAA==.不玩贴吧:BAACLgAFFH8FAAIFAAMJ/RbpCQASAQAFAAMJ/RbpCQASAQAuAAQKfyMAAgUACAmsI/4EAD0DAAUACAmsI/4EAD0DAAAA.',
['东尼']='东尼大牧:BAAALgAECgQJBAAAAA==.',
['丶不']='丶不会:BAABLgAFFH8FAAIDAAMJYhZYJAAEAQADAAMJYhZYJAAEAQABLgAFFAUJCgABAMAjAA==.丶不炫耀:BAABLgAFFH8KAAIBAAUJwCP7AQDzAQABAAUJwCP7AQDzAQAAAA==.',
['丶肉']='丶肉蛋:BAAALgAECggJDgAAAA==.',
['丶蛋']='丶蛋挞:BAAALgAECgYJDgAAAA==.',
['丿神']='丿神之灬守护:BAAALgAECgUJBgAAAA==.',
['么么']='么么丶小纯洁:BAAALgAECgcJBwAAAA==.么么小纯牛:BAAALgAFFAIJAgABLgAFFAIJAwAGAAAAAA==.',
['云游']='云游只去青楼:BAAALgAECgMJAwAAAA==.',
['五块']='五块钱的悲催:BAAALgAFFAEJAQAAAA==.',
['亵渎']='亵渎者乌龟壳:BAAALgAECgYJCwAAAA==.',
['仁剑']='仁剑仁爱:BAAALgAECgUJCwAAAA==.',
['仁箭']='仁箭仁爱:BAAALgAECgUJBwAAAA==.',
['偏心']='偏心:BAAALgAECgkJEAAAAA==.',
['偏执']='偏执:BAAALgAFFAEJAQAAAA==.',
['偏爱']='偏爱:BAABLgAFFH8GAAIHAAQJFwyLFADSAAAHAAQJFwyLFADSAAAAAA==.',
['光暗']='光暗娜娜米:BAABLgAFFH8LAAIIAAMJtiDTAwAaAQAIAAMJtiDTAwAaAQAAAA==.',
['光殇']='光殇:BAAALgAFFAIJBAAAAA==.',
['光羽']='光羽亚丝娜:BAAALgAFFAQJBAABLgAFFAYJDgAJAEIXAA==.',
['冰封']='冰封杜蕾丝:BAAALgADCgYJBgAAAA==.',
['冲锋']='冲锋小红手:BAAALgAECgYJBgAAAA==.',
['冷月']='冷月舞:BAAALgAECgIJAgAAAA==.',
['凤独']='凤独影:BAAALgADCgEJAQAAAA==.',
['别让']='别让我流泪:BAAALgADCgEJAQAAAA==.',
['十两']='十两欢:BAABLgAFFH8JAAIKAAMJGRcQDQDUAAAKAAMJGRcQDQDUAAAAAA==.',
['千鸿']='千鸿:BAACLgAFFH8JAAILAAQJXAeMAQDmAAALAAQJXAeMAQDmAAAuAAQKfxQAAgsABwnGFN8MALoBAAsABwnGFN8MALoBAAAA.',
['单调']='单调木头人:BAABLgAECn8VAAQMAAkJrhcGFwAjAgAMAAkJThEGFwAjAgANAAYJfBumJABvAQAIAAMJ7xM4TACmAAAAAA==.',
['南巴']='南巴妹:BAAALgAECgYJBgAAAA==.',
['卢娜']='卢娜:BAAALgAECgcJEwAAAA==.',
['口孔']='口孔:BAAALgAECgEJAQAAAA==.',
['可乐']='可乐加冰红茶:BAAALgAECgYJCAAAAA==.',
['叶子']='叶子的神话:BAAALgAECgEJAQAAAA==.',
['叶流']='叶流芸:BAAALgADCgUJBQAAAA==.',
['吃酸']='吃酸奶喝西瓜:BAAALgAECgYJDgAAAA==.',
['吉爾']='吉爾伽美什:BAAALgAECgIJBAAAAA==.',
['后来']='后来的我们:BAACLgAFFH8FAAIHAAMJcAq8HACKAAAHAAMJcAq8HACKAAAuAAQKfyAAAgcACAmtGBwYAEMCAAcACAmtGBwYAEMCAAAA.',
['咪哥']='咪哥骨排酱:BAAALgAECgEJAQAAAA==.',
['啤啤']='啤啤猎:BAAALgADCgEJAQAAAA==.',
['喔一']='喔一哟:BAAALgAECgIJAgAAAA==.',
['圣光']='圣光穿透一切:BAABLgAFFH8IAAIOAAQJDxRbDQAFAQAOAAQJDxRbDQAFAQAAAA==.',
['圣赛']='圣赛纳留斯:BAAALgAECgMJAwAAAA==.',
['境界']='境界之空:BAACLgAFFH8MAAICAAQJeyUcAQCqAQACAAQJeyUcAQCqAQAuAAQKfyIAAgIACQk5JcMAAMoDAAIACQk5JcMAAMoDAAAA.',
['夜夜']='夜夜殇:BAABLgAECn8VAAIPAAgJyhrDGQB+AgAPAAgJyhrDGQB+AgAAAA==.',
['夜露']='夜露:BAAALgADCgIJAgAAAA==.',
['大漠']='大漠殘陽:BAAALgAECgQJBAAAAA==.',
['天哥']='天哥:BAAALgAECgIJBAAAAA==.',
['天意']='天意十六:BAABLgAFFH8FAAIJAAUJ5hMoBQCxAQAJAAUJ5hMoBQCxAQABLgAFFAkJAQAGAAAAAA==.',
['奇迹']='奇迹的堕天使:BAAALgAECgIJAgAAAA==.',
['奈德']='奈德丽:BAAALgADCgEJAQAAAA==.',
['套里']='套里都是水:BAAALgADCgEJAQAAAA==.',
['女人']='女人狼精:BAAALgAECgYJDQAAAA==.',
['好可']='好可爱的德:BAAALgADCgEJAQAAAA==.',
['如梦']='如梦似水流年:BAAALgAECgcJCQAAAA==.',
['学法']='学法大师:BAAALgADCgEJAQAAAA==.',
['宋柔']='宋柔掌:BAAALgAFFAEJAQAAAA==.',
['寒冬']='寒冬女王:BAAALgAECgYJBgAAAA==.',
['寒塘']='寒塘冷月:BAAALgAECgYJBgAAAA==.',
['射天']='射天狼:BAAALgADCgMJAwAAAA==.',
['小乐']='小乐意:BAAALgAFFAQJBAAAAA==.',
['小其']='小其士:BAAALgAECgUJCAAAAA==.',
['小叶']='小叶儿丶:BAAALgAECgUJBQAAAA==.',
['小小']='小小大懒猫:BAACLgAFFH8FAAIQAAIJ9QlPEwCRAAAQAAIJ9QlPEwCRAAAuAAQKfxoAAhAACAmuEBMYANQBABAACAmuEBMYANQBAAAA.',
['小牛']='小牛大师:BAAALgAECgEJAQAAAA==.',
['小球']='小球球:BAAALgADCgMJAwAAAA==.',
['小甜']='小甜筒:BAAALgAECgUJCAAAAA==.',
['小米']='小米萨萨:BAAALgAECgMJAwAAAA==.小米魔月:BAAALgAECgYJBgAAAA==.',
['小红']='小红手冲锋:BAAALgAECgcJDQAAAA==.小红手战吊:BAAALgAECgYJBgAAAA==.小红手执念:BAABLgAECn8aAAIPAAkJ3hkXEADRAgAPAAkJ3hkXEADRAgAAAA==.',
['小趴']='小趴菜:BAAALgADCggJCAAAAA==.',
['小野']='小野百合:BAAALgAECgcJBwAAAA==.',
['小饼']='小饼干:BAAALgAECgUJCQAAAA==.',
['尐法']='尐法:BAAALgAECgUJBQAAAA==.',
['尐贼']='尐贼:BAAALgAECgkJCQAAAA==.',
['尐龙']='尐龙:BAAALgAECgIJAgABLgAFFAcJEgANAEEVAA==.',
['尖尖']='尖尖哇嘎乃:BAABLgAFFH8HAAMRAAQJZw8BEADoAAARAAQJZw8BEADoAAASAAEJZQkjDwBIAAAAAA==.',
['巨炮']='巨炮蜀黍:BAAALgAECgcJDAAAAA==.',
['巨蟹']='巨蟹座:BAACLgAFFH8JAAIEAAQJQiL4IABAAQAEAAQJQiL4IABAAQAuAAQKfxQAAgQACQknJfEBAOADAAQACQknJfEBAOADAAAA.',
['巫法']='巫法无天:BAAALgAECgEJAgAAAA==.',
['干要']='干要强制改名:BAAALgAECgMJAwAAAA==.',
['影哲']='影哲:BAAALgAECgYJBwAAAA==.',
['御轻']='御轻弦:BAAALgAECgYJDAABLgAFFAIJBgAEADokAA==.',
['快跑']='快跑吧小猪:BAAALgAECgIJAgAAAA==.',
['悟空']='悟空宝妈:BAAALgAECgQJCAAAAA==.',
['慕婉']='慕婉清:BAAALgAECgMJAwAAAA==.',
['我是']='我是酱板鸭:BAAALgAECgQJBwAAAA==.我是阿枪哥:BAAALgAECgYJCAAAAA==.',
['我蔡']='我蔡我有李:BAAALgAECgEJAQAAAA==.',
['战吊']='战吊小红手:BAAALgAECgYJDAAAAA==.',
['战德']='战德宝宝:BAAALgAECgEJAQAAAA==.',
['战念']='战念小红手:BAABLgAECn8YAAIPAAkJIBvACQASAwAPAAkJIBvACQASAwAAAA==.',
['执念']='执念小红手:BAABLgAECn8ZAAIPAAkJERlzEQDFAgAPAAkJERlzEQDFAgAAAA==.',
['拔卵']='拔卵有情:BAAALgAECgYJBwAAAA==.',
['搁丶']='搁丶浅:BAAALgAFFAMJBAAAAA==.',
['搁浅']='搁浅:BAAALgAECgQJBAAAAA==.',
['放弃']='放弃思考:BAAALgADCgEJAQAAAA==.',
['救赎']='救赎与信仰:BAAALgADCgYJBgAAAA==.',
['斯旺']='斯旺起司:BAAALgAECgIJAgAAAA==.',
['无敌']='无敌小萨满:BAAALgAECgQJBAAAAA==.无敌熊猫:BAAALgAECgUJBQAAAA==.',
['无极']='无极丶圣光:BAAALgAECgUJDgAAAA==.',
['时光']='时光:BAAALgAECgEJAQAAAA==.',
['明眸']='明眸靓眼:BAAALgAECgcJEgAAAA==.',
['星渊']='星渊源泉:BAAALgADCgUJBQABLgAECgYJFwAQAF4bAA==.',
['是圣']='是圣光啊:BAAALgAECgQJBQAAAA==.',
['是芥']='是芥末啊:BAAALgAECgUJBQAAAA==.',
['暗夜']='暗夜翠花:BAAALgAECgUJCAAAAA==.',
['暧昧']='暧昧的理由:BAAALgAECgIJAgAAAA==.',
['月翼']='月翼猫头鹰:BAABLgAFFH8FAAITAAUJBBr1AwCvAQATAAUJBBr1AwCvAQAAAA==.',
['有猫']='有猫饼:BAAALgAECgUJCgAAAA==.',
['木叶']='木叶甜馨:BAAALgAECgYJBwAAAA==.',
['末日']='末日太阳:BAAALgAECgYJCwAAAA==.末日曙光:BAAALgAECgUJCQAAAA==.',
['术天']='术天尊:BAAALgADCgYJBAAAAA==.',
['村里']='村里的希望:BAAALgAECgUJDwAAAA==.',
['林桉']='林桉:BAAALgAECgYJBgAAAA==.',
['槑大']='槑大:BAAALgAECgQJBAAAAA==.',
['槑小']='槑小:BAAALgADCgMJAwAAAA==.',
['水无']='水无月空:BAAALgAECgEJAwAAAA==.',
['永远']='永远不太远:BAAALgAECgIJAgAAAA==.',
['流星']='流星星冰乐:BAAALgADCgEJAQAAAA==.',
['海潮']='海潮溟:BAACLgAFFH8OAAIHAAQJmQs3BgASAQAHAAQJmQs3BgASAQAuAAQKfxcAAgcACAl8E/MqALQBAAcACAl8E/MqALQBAAAA.',
['火锅']='火锅味乌巴:BAAALgAECgMJAwAAAA==.',
['火鸡']='火鸡味锅巴:BAAALgADCgEJAQAAAA==.',
['烈焰']='烈焰风行者:BAAALgAECggJEwAAAA==.',
['焕鳞']='焕鳞:BAAALgADCgYJCQABLgAECgYJFwAQAF4bAA==.',
['爆弹']='爆弹小子:BAAALgAFFAEJAQAAAA==.',
['爱唱']='爱唱歌的贝贝:BAACLgAFFH8PAAMRAAUJ0hXvAwCUAQARAAUJ0hXvAwCUAQASAAEJSgc7IABBAAAuAAQKfx4AAxIACAnMHz0XAF4CABIABwn+Hj0XAF4CABEACAmyEvUuAM0BAAAA.',
['爱跳']='爱跳舞的晶晶:BAABLgAFFH8HAAIUAAYJOxtJAQDIAQAUAAYJOxtJAQDIAQAAAA==.',
['狂晓']='狂晓牙:BAAALgAECgYJBgAAAA==.',
['狐酒']='狐酒趁梨花:BAAALgAFFAEJAQAAAA==.',
['猎天']='猎天尊:BAAALgADCgUJBwAAAA==.',
['猫的']='猫的小馒头:BAAALgAECgEJAQAAAA==.',
['玩偷']='玩偷袭的:BAAALgAFFAIJAgAAAA==.',
['琉璃']='琉璃星辰:BAAALgADCgIJAgAAAA==.',
['瑾瑜']='瑾瑜:BAABLgAFFH8HAAICAAMJ7BZYBQAGAQACAAMJ7BZYBQAGAQAAAA==.',
['疯狂']='疯狂的瓶子:BAAALgAECgIJAgAAAA==.',
['痛风']='痛风:BAAALgAECgEJAQAAAA==.',
['看不']='看不清:BAAALgADCgIJAgAAAA==.',
['破碎']='破碎之灵:BAAALgADCgIJAgAAAA==.',
['祖龙']='祖龙神帝:BAAALgADCgMJAwAAAA==.',
['神的']='神的化身:BAAALgADCgEJAQAAAA==.',
['秦梦']='秦梦瑶:BAAALgADCgIJAgAAAA==.',
['精灵']='精灵小谢:BAAALgAECgUJBgAAAA==.精灵莱尼:BAAALgAECgUJBgAAAA==.',
['索纳']='索纳苟斯:BAAALgADCgcJBwAAAA==.',
['紫凝']='紫凝:BAAALgAECgkJCQAAAA==.',
['紫薯']='紫薯小酪丶:BAAALgADCgYJBgAAAA==.',
['红牙']='红牙牙:BAAALgADCgIJAgAAAA==.',
['红红']='红红德:BAAALgADCgUJBQAAAA==.',
['维岳']='维岳:BAABLgAECn8XAAQQAAYJXhs+AwC8AQAQAAYJXhs+AwC8AQAVAAYJHBFpIQAgAQAJAAEJxAPtaAAkAAAAAA==.',
['维鲁']='维鲁德拉:BAAALgAECgQJBQAAAA==.',
['老吃']='老吃老做:BAAALgAECgEJAgAAAA==.',
['胆小']='胆小咕:BAABLgAFFH8JAAMTAAQJxhaODgD3AAATAAQJxhaODgD3AAAUAAIJMwwkHQCIAAABLgAFFAcJBAAGAAAAAA==.',
['胖就']='胖就胖了:BAAALgAECgUJCgAAAA==.',
['胖点']='胖点错了吗:BAAALgAECgUJBQAAAA==.',
['胸胸']='胸胸凶:BAAALgAECgEJAQAAAA==.',
['艾文']='艾文:BAAALgADCgMJAwAAAA==.',
['艾沙']='艾沙维尔:BAABLgAFFH8HAAIWAAQJWxWSDAAbAQAWAAQJWxWSDAAbAQAAAA==.',
['艾路']='艾路恩:BAAALgAECgEJAQABLgAFFAIJBgAEADokAA==.',
['艾露']='艾露恩:BAAALgAFFAIJAwAAAA==.',
['花间']='花间舞:BAAALgAECgkJBwAAAA==.',
['苏南']='苏南:BAABLgAFFH8GAAIEAAIJOiTFMgDTAAAEAAIJOiTFMgDTAAAAAA==.',
['莫笑']='莫笑我痴狂:BAAALgAECgQJEAAAAA==.',
['莲生']='莲生:BAABLgAFFH8FAAIHAAIJiAIpIgBhAAAHAAIJiAIpIgBhAAAAAA==.',
['菅直']='菅直布是人:BAAALgAECgYJEgAAAA==.',
['菜王']='菜王小鬼:BAABLgAECn8ZAAIFAAcJlxnuIQA6AgAFAAcJlxnuIQA6AgAAAA==.',
['萌丶']='萌丶巨龙:BAAALgADCgEJAQAAAA==.萌丶滚滚:BAAALgAECgQJBAABLgAFFAYJBgAVAAkSAA==.',
['蒗猫']='蒗猫:BAAALgAECgEJAQAAAA==.',
['蘑咕']='蘑咕不咕:BAABLgAECn8VAAIRAAgJjh7JFgBgAgARAAgJjh7JFgBgAgAAAA==.',
['蝴蝶']='蝴蝶丶流萤:BAAALgAECgQJBgAAAA==.',
['血龙']='血龙至尊宝:BAAALgAECgEJAQAAAA==.',
['請勿']='請勿拍打餵食:BAAALgAECgkJCQAAAA==.',
['诶哟']='诶哟哟丶:BAACLgAFFH8JAAIMAAMJGxfWBwDtAAAMAAMJGxfWBwDtAAAuAAQKfyEABAwACAkwHBYNAIUCAAwACAkwHBYNAIUCAA0AAwmqDbBCAJ4AAAgAAQmiEyJdAD8AAAAA.',
['贵仔']='贵仔:BAAALgAECgUJCAAAAA==.',
['路特']='路特:BAAALgADCgEJAQAAAA==.',
['软床']='软床等硬枪:BAACLgAFFH8FAAIBAAMJ0hGJHgCzAAABAAMJ0hGJHgCzAAAuAAQKfx4AAgEACAlWHTojAJwCAAEACAlWHTojAJwCAAAA.',
['迈尔']='迈尔斯:BAAALgADCgUJBQAAAA==.',
['这城']='这城市那么空:BAAALgAECgYJBgAAAA==.',
['这就']='这就尴尬了呀:BAAALgAFFAIJAwAAAA==.',
['迪迦']='迪迦奥特曼:BAAALgAECgYJAQAAAA==.',
['這個']='這個小美女:BAAALgAECgYJBgAAAA==.',
['速度']='速度之靴:BAAALgADCgUJBQAAAA==.',
['逸之']='逸之助:BAAALgAECgQJCgAAAA==.',
['邂逅']='邂逅丶:BAAALgAECgYJCQAAAA==.邂逅丶猎:BAAALgAECgQJBgAAAA==.',
['邪天']='邪天帝:BAAALgADCgUJBQAAAA==.',
['钱多']='钱多多一号:BAAALgAECgcJDQAAAA==.',
['银河']='银河星爆:BAAALgAECgQJBAAAAA==.',
['队长']='队长丶是我:BAACLgAFFH8JAAMPAAMJeARxBwDZAAAPAAMJeARxBwDZAAAXAAIJEQIjDgBlAAAuAAQKfxoAAxcACAmeDZofAEUBABcABwk8DZofAEUBAA8ABAmWCtp2AOAAAAAA.',
['阿司']='阿司匹林:BAAALgADCgEJAQAAAA==.',
['阿莉']='阿莉塔:BAAALgADCgIJAgAAAA==.',
['阿鲁']='阿鲁尼拉:BAAALgADCgIJAgAAAA==.',
['陈一']='陈一发兒:BAACLgAFFH8JAAIFAAMJIxbvCAAaAQAFAAMJIxbvCAAaAQAuAAQKfx0AAgUACAmRIjEGACoDAAUACAmRIjEGACoDAAAA.',
['雅克']='雅克德莫莱:BAAALgADCgcJBwAAAA==.',
['雨季']='雨季的救赎:BAAALgADCgYJBwAAAA==.',
['雪叶']='雪叶殘蓮:BAAALgAFFAQJBAAAAA==.',
['顶级']='顶级绿叶:BAAALgAECgYJBgAAAA==.',
['风吹']='风吹乱头发:BAAALgAECgQJBwAAAA==.',
['驫龘']='驫龘殇:BAAALgAFFAIJAwABLgAFFAgJIAAJAAAlAA==.',
['魔天']='魔天帝:BAAALgADCgEJAQAAAA==.',
['黎铭']='黎铭:BAAALgAECgUJBQAAAA==.',
['默默']='默默的邪芋头:BAACLgAFFH8WAAIYAAYJshrqAgAXAgAYAAYJshrqAgAXAgAuAAQKfxwAAhgACAkdIqEQAPkCABgACAkdIqEQAPkCAAAA.',
['龘龐']='龘龐瀣:BAAALgADCgcJDAAAAA==.',
['龙皓']='龙皓晨:BAAALgAECgMJBQAAAA==.',
['龙眠']='龙眠月:BAABLgAECn8aAAIQAAgJkxDdGwCpAQAQAAgJkxDdGwCpAQAAAA==.',
['龙舌']='龙舌兰姑娘:BAAALgAECgEJAgAAAA==.',
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
