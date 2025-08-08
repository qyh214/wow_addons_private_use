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
 local lookup = {'DeathKnight-Unholy','Warrior-Fury','Warrior-Arms','Paladin-Retribution','Warlock-Destruction','Warlock-Demonology','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Blood','Shaman-Elemental','Shaman-Enhancement','Shaman-Restoration','Paladin-Protection','Paladin-Holy','Druid-Balance','Priest-Holy','Rogue-Outlaw','Mage-Frost','Druid-Restoration','Druid-Guardian','DeathKnight-Frost','Rogue-Assassination','DemonHunter-Havoc','Mage-Fire','Priest-Discipline','Monk-Mistweaver','Monk-Windwalker','Mage-Arcane','Evoker-Devastation','Evoker-Preservation','Unknown-Unknown','Warrior-Protection','Priest-Shadow','DemonHunter-Vengeance','Warlock-Affliction','Monk-Brewmaster',}; local provider = {region='CN',realm='提尔之手',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alexanderamy:BAABKgAECn8UAAIBAAgIFRfNLwC5AQABAAgIFRfNLwC5AQAAAA==.',An='Angelawho:BAAAKgADCgIIAgAAAA==.',Ba='Baga:BAACKgAFFH83AAMCAAgIUxk5BgANAgACAAgIUxk5BgANAgADAAIIthA/IgCBAAAqAAQKfz0AAgIACAi+IbYIAC4CAAIACAi+IbYIAC4CAAAA.',Bu='Burning:BAAAKgADCgEIAQAAAA==.',Ca='Candycoco:BAAAKgAECgEIAQAAAA==.',Cl='Cloverdou:BAABKgAFFH8GAAIEAAYIUhbOIQBmAQAEAAYIUhbOIQBmAQAAAA==.',Cy='Cynthia:BAAAKgAFFAQIBAAAAA==.',Dh='Dhwaltz:BAAAKgAFFAIIBAAAAA==.',Di='Disappeared:BAABKgAECn8YAAIBAAcIfxp5QQCsAQABAAcIfxp5QQCsAQAAAA==.',Do='Doubble:BAABKgAECn8qAAMFAAgIhx3CEgASAgAFAAgIhx3CEgASAgAGAAgIywUsQwDVAAAAAA==.',El='Elemt:BAAAKgAECgMIAwAAAA==.Ellen:BAAAKgAECgYIBwAAAA==.',Ex='Excalibur:BAAAKgADCgEIAQAAAA==.Exii:BAABKgAFFH8KAAMHAAgIExb7HgASAQAHAAQIYw77HgASAQAIAAYI8RhIJQDXAAAAAA==.Exiz:BAABKgAFFH8GAAIJAAYISgUwHwBmAAAJAAYISgUwHwBmAAAAAA==.',Fi='Firewaltz:BAAAKgAFFAIIBAAAAA==.',Kd='Kderboys:BAAAKgAFFAIIAgAAAA==.',Ki='Kinfe:BAABKgAECn8WAAIKAAgIlQ8ILAB6AQAKAAgIlQ8ILAB6AQAAAA==.Kinfezs:BAABKgAECn8cAAMDAAgI5RhNFwDPAQADAAgIUBZNFwDPAQACAAQIQQ7gYwB5AAAAAA==.',Ko='Kopiluwha:BAAAKgAECggICAAAAA==.',Li='Liadrinian:BAAAKgAECgYIBQAAAA==.',Lu='Luxaky:BAAAKgAECgEIAQAAAA==.',Oo='Ooningoo:BAEBKgAFFH8RAAIEAAMIHSAXNgASAQAEAAMIHSAXNgASAQABKgAFFAgIBgALAK4TAA==.',Op='Opai:BAABKgAFFH8IAAMKAAQIuCLdBAASAQAKAAQIuCLdBAASAQAMAAMIAxg9HgCiAAABKgAFFAgIEwANAA0TAA==.',Pa='Pattinson:BAAAKgADCgIIAgAAAA==.',Pl='Playerpussbp:BAAAKgAECgUIBQAAAA==.',Sc='Scarletwitch:BAAAKgAECgYIBQAAAA==.',Su='Sunriver:BAAAKgAECgMIAwAAAA==.Supremedream:BAAAKgAECggIDAAAAA==.',Th='Thebrutalt:BAAAKgAECgYICQAAAA==.',Tr='Trbhedrt:BAAAKgADCggICAAAAA==.',['一抹']='一抹天蓝色:BAAAKgAFFAcIAQAAAA==.',['一点']='一点殷红:BAAAKgAECgYICwAAAA==.',['一箭']='一箭穿杨:BAABKgAFFH8MAAIIAAYI3hDREgBMAQAIAAYI3hDREgBMAQABKgAFFAgIHAAHAIUbAA==.',['七夜']='七夜狼君:BAACKgAFFH8JAAMDAAQI4AQLEgBuAAADAAII6QULEgBuAAACAAIIzgLTIAAvAAAqAAQKfyMAAwMACAjGFVQeAJMBAAMACAjGFVQeAJMBAAIABQjxDK5bAOoAAAAA.',['三十']='三十六帝飞机:BAABKgAFFH8GAAIMAAMIGx8CEAAAAQAMAAMIGx8CEAAAAQAAAA==.',['三鹿']='三鹿请安:BAAAKgAECggICAAAAA==.',['丨异']='丨异域歌狂丨:BAAAKgADCgIIAgAAAA==.',['丨某']='丨某个莳间丨:BAAAKgAECgYICQAAAA==.',['丶拉']='丶拉斐尔丶:BAAAKgAECggICAAAAA==.',['丶桃']='丶桃花坞:BAAAKgAECggICAAAAA==.',['丶滔']='丶滔咪:BAAAKgAFFAEIAQAAAA==.',['丶茉']='丶茉莉蜜茶:BAAAKgAECgQIAwAAAA==.',['丿小']='丿小灬橘子:BAAAKgAFFAIIBAAAAA==.',['乔艾']='乔艾莉:BAAAKgAECgMIAwAAAA==.',['乱舞']='乱舞大秦:BAABKgAFFH8QAAIEAAgI4xGwCQANAgAEAAgI4xGwCQANAgAAAA==.乱舞春秋:BAAAKgAFFAYIBAAAAA==.',['二丫']='二丫:BAAAKgAECggICAAAAA==.',['云泽']='云泽:BAAAKgAECgYIBgAAAA==.',['五德']='五德充沛:BAACKgAFFH8GAAIOAAMI7QowEgCvAAAOAAMI7QowEgCvAAAqAAQKfxoAAw4ACAhgE5EmAC4BAA4ACAhgE5EmAC4BAAQAAggBC7U4AS4AAAAA.',['五晨']='五晨寺炎掌门:BAAAKgAECgYIBgAAAA==.',['伊什']='伊什塔尔:BAAAKgAECgIIAgAAAA==.',['传说']='传说品质咕咕:BAABKgAFFH8QAAIPAAQIgxAwHADKAAAPAAQIgxAwHADKAAABKgAFFAcIJwAKAKodAA==.',['似雾']='似雾像风:BAAAKgAFFAQIBAAAAA==.',['余生']='余生:BAAAKgAECgEIAQAAAA==.',['佛罗']='佛罗伦娜:BAABKgAECn8VAAIQAAgIvBwMHQDxAQAQAAgIvBwMHQDxAQAAAA==.',['八旬']='八旬麻匪:BAABKgAFFH8GAAIRAAMIswthBgCtAAARAAMIswthBgCtAAAAAA==.',['关你']='关你皮斯呦:BAABKgAFFH8GAAISAAYIKxWEBgBlAQASAAYIKxWEBgBlAQAAAA==.',['冰冷']='冰冷之海:BAABKgAFFH8KAAMEAAgIUQ8IIgBlAQAEAAYIixMIIgBlAQANAAQIPQYeFwC/AAAAAA==.',['冰美']='冰美式:BAAAKgAECgQIBgAAAA==.',['冷淡']='冷淡的英雄:BAABKgAFFH8FAAIHAAIIfQQbVQBZAAAHAAIIfQQbVQBZAAABKgAFFAgIEwANAA0TAA==.',['凛风']='凛风追猎:BAAAKgAECggICAAAAA==.',['凯罗']='凯罗尒:BAAAKgAFFAQIBAAAAA==.',['刹戮']='刹戮:BAAAKgAFFAQIBAAAAA==.',['刺蛇']='刺蛇狗毒爆:BAAAKgADCggIBgAAAA==.',['功夫']='功夫犇:BAAAKgAECgEIAQAAAA==.',['勤受']='勤受:BAAAKgADCgEIAQAAAA==.',['十八']='十八坡小学妹:BAAAKgAECgUIBQAAAA==.',['午后']='午后法神:BAAAKgAECgYIBgAAAA==.',['午夜']='午夜屠夫:BAAAKgAECgcIBwAAAA==.',['半盏']='半盏观山海:BAABKgAECn8XAAMTAAgI/Q2HPAD1AAATAAgI/Q2HPAD1AAAUAAgIYwi5DgDXAAAAAA==.',['南乡']='南乡子:BAAAKgAECgYIBgAAAA==.',['南昌']='南昌出口空运:BAAAKgAFFAQIBAAAAA==.',['南歌']='南歌子:BAAAKgAECggIDgAAAA==.',['古琪']='古琪:BAABKgAECn8bAAMBAAgIyQg1GQAFAQABAAgIyQg1GQAFAQAVAAYIYgVEKQCLAAAAAA==.',['只剑']='只剑截江流:BAAAKgAECgMIAwAAAA==.',['叫我']='叫我莫莫:BAABKgAFFH8IAAIFAAgIfwt5CQDCAQAFAAgIfwt5CQDCAQAAAA==.',['后门']='后门口扛把子:BAABKgAECn8eAAIMAAgIwAc2LADYAAAMAAgIwAc2LADYAAAAAA==.',['呵呵']='呵呵牛逼:BAAAKgAFFAIIAgAAAA==.',['咖喱']='咖喱给给:BAABKgAFFH8MAAIWAAYIIxytCAD/AAAWAAYIIxytCAD/AAAAAA==.',['咣咣']='咣咣就是两拳:BAAAKgAFFAQIBAABKgAFFAgICgAEAK0lAA==.',['哈力']='哈力克:BAABKgAFFH8GAAISAAYIghP1BgBZAQASAAYIghP1BgBZAQAAAA==.',['哈士']='哈士奇大帝:BAAAKgAECggIDAAAAA==.',['嚣张']='嚣张不解释:BAABKgAFFH8OAAIMAAYI8BGIAgBpAQAMAAYI8BGIAgBpAQAAAA==.',['四层']='四层吉士汉堡:BAAAKgAECgYIDgAAAA==.',['回忆']='回忆如此温暖:BAABKgAFFH8GAAIHAAYIghmhDwB+AQAHAAYIghmhDwB+AQAAAA==.',['因为']='因为他善:BAAAKgADCgIIAgAAAA==.',['土土']='土土:BAAAKgAECgYIBAAAAA==.',['圣人']='圣人冏冏:BAABKgAFFH8GAAIEAAYIXwrcFQBBAQAEAAYIXwrcFQBBAQAAAA==.',['圣光']='圣光德芙:BAAAKgADCggICAAAAA==.',['圣舞']='圣舞:BAABKgAFFH8IAAINAAYIRRr8HQCLAAANAAYIRRr8HQCLAAABKgAFFAgICgAXAAIRAA==.',['圣骑']='圣骑:BAAAKgAECgIIAgAAAA==.',['坎谱']='坎谱拉:BAAAKgAECggICwAAAA==.',['基尔']='基尔加丹:BAAAKgAFFAIIBAAAAA==.',['壹壹']='壹壹陆:BAAAKgADCggICAAAAA==.',['夏天']='夏天的茶叶:BAABKgAFFH8IAAINAAgICRFJBQCuAQANAAgICRFJBQCuAQAAAA==.',['夜小']='夜小夕:BAAAKgAFFAYIBAAAAA==.',['夜雨']='夜雨残风:BAAAKgADCggICAAAAA==.',['大你']='大你十来岁:BAAAKgAECgUIBwAAAA==.',['大尾']='大尾巴鱼:BAABKgAFFH8OAAMGAAQI+BmCDwC/AAAFAAQIkxSrFgDJAAAGAAQI0BKCDwC/AAAAAA==.',['大滋']='大滋水枪:BAABKgAFFH8SAAIEAAgIvySmAwCnAgAEAAgIvySmAwCnAgAAAA==.',['天堂']='天堂在左:BAACKgAFFH8IAAMDAAcIXQ0iGQDBAAADAAUIog4iGQDBAAACAAMIeASeLQCJAAAqAAQKfxkAAgMACAiFH4UDAIgCAAMACAiFH4UDAIgCAAAA.',['奶茶']='奶茶微糖少冰:BAAAKgAECgQIBAAAAA==.',['如是']='如是自来也:BAABKgAFFH8LAAITAAMIKR4/FgDvAAATAAMIKR4/FgDvAAAAAA==.',['孜然']='孜然:BAABKgAFFH8GAAIMAAYIFgm7FwAjAQAMAAYIFgm7FwAjAQAAAA==.',['季末']='季末乄玄天:BAAAKgAFFAYIBAAAAA==.',['宝宝']='宝宝呢:BAAAKgAFFAQIBAAAAA==.',['实在']='实在是小:BAAAKgAECggIEwAAAA==.',['审判']='审判官之手:BAAAKgADCgYIBgAAAA==.',['寻常']='寻常巷陌:BAAAKgAFFAEIAQAAAA==.',['小倩']='小倩乖:BAABKgAFFH8QAAIHAAMIOSAQIAANAQAHAAMIOSAQIAANAQAAAA==.',['小呆']='小呆守护者:BAABKgAFFH8IAAMSAAgIVBcgBwD1AAAYAAQInRK7EgApAQASAAQInB0gBwD1AAAAAA==.',['小小']='小小抱米花:BAABKgAFFH8GAAIZAAYI4RSlCgBrAQAZAAYI4RSlCgBrAQAAAA==.小小芳芳:BAACKgAFFH8YAAIaAAQIHSS4BgA+AQAaAAQIHSS4BgA+AQAqAAQKfzsAAxoACAiuI2gHALgCABoACAiuI2gHALgCABsABAhSElZJAKEAAAAA.',['小汤']='小汤圆丶:BAAAKgAECgYIBgAAAA==.',['小滋']='小滋水枪:BAABKgAFFH8GAAIcAAYI4hqmDACcAQAcAAYI4hqmDACcAQAAAA==.',['小聋']='小聋仁:BAABKgAFFH8IAAMdAAgIlwjJFgASAQAdAAQI7Q3JFgASAQAeAAQIeApoBwCOAAAAAA==.',['小花']='小花非花:BAABKgAFFH8KAAMPAAYIsRK5GABSAQAPAAYIsRK5GABSAQATAAQIiSEfEgAOAQAAAA==.',['小角']='小角色的我:BAAAKgAECggICAABKgAFFAgICgAEAK0lAA==.',['小龙']='小龙亡命天涯:BAAAKgAECgIIAgAAAA==.',['尛阿']='尛阿喵:BAAAKgADCggIEAAAAA==.',['山下']='山下彻也:BAAAKgADCggICAAAAA==.',['巧克']='巧克力脆皮:BAAAKgADCggICAAAAA==.',['巨鲨']='巨鲨:BAAAKgAECggIEgAAAA==.',['巴掌']='巴掌:BAAAKgAECgYICwAAAA==.',['布鲁']='布鲁欧曼德:BAAAKgAECgMIAwAAAA==.',['希尔']='希尔哇娜丝:BAAAKgAECggIBgAAAA==.',['希罗']='希罗苏:BAAAKgAFFAQIBAAAAA==.',['幸福']='幸福的小兔子:BAAAKgAECggIEgAAAA==.',['幽睚']='幽睚:BAAAKgAECgEIAQAAAA==.',['幽雅']='幽雅:BAAAKgAFFAEIAQAAAA==.',['弑丿']='弑丿雨落星辰:BAAAKgAECggICAAAAA==.',['归灬']='归灬墟:BAABKgAFFH8IAAMVAAQIzCXIBQAZAQAVAAQIzCXIBQAZAQABAAQI0gdaGwC9AAABKgAFFAgIBgAJAF4LAA==.',['德雷']='德雷斯顿:BAAAKgAECgQIBAABKgAECggICAAfAAAAAA==.',['怀瑾']='怀瑾握瑜:BAAAKgAECgcIDQAAAA==.',['恨你']='恨你的犬夜叉:BAABKgAECn8UAAIgAAgI4REhKQDlAAAgAAgI4REhKQDlAAAAAA==.',['悲伤']='悲伤死士:BAAAKgADCgMIAwAAAA==.',['慧儿']='慧儿:BAAAKgADCggIBAAAAA==.',['我不']='我不是治疗啊:BAABKgAFFH8IAAIFAAgIxBgaBgA0AgAFAAgIxBgaBgA0AgAAAA==.',['我来']='我来组成头部:BAABKgAFFH8IAAIEAAQIQxPwJADdAAAEAAQIQxPwJADdAAAAAA==.',['我爱']='我爱赤石:BAABKgAFFH8MAAQZAAgIqxggDABUAQAZAAcI6RYgDABUAQAQAAMIHQ4mLQCQAAAhAAEIhwYSJwBFAAAAAA==.',['挚爱']='挚爱无悔:BAABKgAECn8bAAIHAAgI1hPzPwCnAQAHAAgI1hPzPwCnAQAAAA==.',['捣蛋']='捣蛋鬼别捣蛋:BAAAKgAECgQIBAAAAA==.',['斟满']='斟满一杯酒:BAAAKgAECggIDwAAAA==.',['无悔']='无悔挚爱:BAAAKgAECgcIEQAAAA==.',['星辰']='星辰大海:BAABKgAFFH8HAAICAAcI6RRsFQAQAQACAAcI6RRsFQAQAQAAAA==.',['暗语']='暗语宥辰:BAAAKgADCggICAAAAA==.',['最美']='最美不是夏天:BAAAKgADCggICQAAAA==.最美不是秋天:BAAAKgADCggICAAAAA==.',['月亮']='月亮与六便士:BAAAKgAFFAYIBAAAAA==.',['李大']='李大夫:BAAAKgAECgYIBgAAAA==.',['李队']='李队长:BAAAKgAFFAQIBAAAAA==.',['枸杞']='枸杞:BAAAKgAFFAIIBAAAAA==.',['柒千']='柒千:BAABKgAFFH8GAAIDAAYI0Ra+CQBvAQADAAYI0Ra+CQBvAQAAAA==.',['柳半']='柳半仙儿:BAAAKgADCggICAAAAA==.',['桔梨']='桔梨萝柚:BAAAKgAECgEIAQAAAA==.',['梅琳']='梅琳娜:BAAAKgAECggICwAAAA==.',['棒棒']='棒棒:BAAAKgADCgUIBQAAAA==.',['橙色']='橙色棉花:BAAAKgAFFAgIBAAAAA==.',['欧皇']='欧皇之皇:BAAAKgAECgQIBwAAAA==.',['正义']='正义的伙伴:BAAAKgAECgMIAwAAAA==.',['死定']='死定啦:BAAAKgADCgIIAgAAAA==.',['死神']='死神向左:BAAAKgADCggICAAAAA==.',['死骑']='死骑不帅:BAAAKgAECgIIAgAAAA==.',['池鱼']='池鱼:BAABKgAFFH8KAAMFAAYInhpxCAAhAQAFAAUIZhtxCAAhAQAGAAMIiRIwGQCFAAAAAA==.',['沏上']='沏上一壶茶:BAAAKgAECggIEwAAAA==.',['沟壑']='沟壑之王:BAABKgAFFH8NAAIEAAgIWgkJFAC8AQAEAAgIWgkJFAC8AQAAAA==.',['法涅']='法涅斯:BAABKgAFFH8KAAIaAAYIfh1/CQCUAQAaAAYIfh1/CQCUAQAAAA==.',['泡泡']='泡泡大帝:BAAAKgAECggICAAAAA==.',['洁云']='洁云:BAAAKgADCgEIAQAAAA==.',['流年']='流年丶:BAAAKgAECggICAAAAA==.',['浮士']='浮士德二夫人:BAABKgAFFH8XAAIOAAMISB6aBwD1AAAOAAMISB6aBwD1AAAAAA==.浮士德国战车:BAAAKgAFFAIIAwAAAA==.浮士德夫人:BAACKgAFFH8aAAMGAAMIvxLuDQDHAAAGAAMIvxLuDQDHAAAFAAEI7gZ9NgA3AAAqAAQKfxQAAwYACAhOFfcMAGwBAAYABwg3FvcMAGwBAAUABQh4EF1tAMMAAAAA.',['消单']='消单乐:BAABKgAFFH8KAAMMAAYIPAX7GgATAQAMAAYIPAX7GgATAQAKAAQIoAoDGwCjAAABKgAFFAgIBAAfAAAAAA==.',['深蓝']='深蓝苦茶子:BAAAKgAECggICgAAAA==.',['清风']='清风:BAABKgAFFH8GAAIEAAYITiLMDQD3AQAEAAYITiLMDQD3AQAAAA==.',['温上']='温上一壶酒:BAAAKgAECggIEgAAAA==.',['温格']='温格萝琳:BAABKgAFFH8KAAIEAAYIlBXPJQBSAQAEAAYIlBXPJQBSAQAAAA==.',['温蕾']='温蕾萨灬:BAABKgAFFH8XAAQZAAgICBRJAgCZAQAQAAgIIA9ZBgDMAQAZAAYIgBNJAgCZAQAhAAQIwBfoDgDmAAAAAA==.',['溜溜']='溜溜梅:BAABKgAFFH8SAAMIAAgIhh2hCADSAQAIAAYIBiKhCADSAQAHAAYIyQqBFwA9AQAAAA==.',['满天']='满天星亮晶晶:BAABKgAFFH8RAAICAAgIDhpnDQB6AQACAAgIDhpnDQB6AQAAAA==.',['漫步']='漫步远征路:BAAAKgAECgMIAwAAAA==.',['灬归']='灬归墟:BAAAKgAECggICAAAAA==.',['灵荫']='灵荫:BAABKgAECn8sAAMTAAgIkiLuBwCdAgATAAgIkiLuBwCdAgAPAAgIABckOQDEAQABKgAFFAgIDAAPAHMZAA==.',['点燃']='点燃一支烟:BAABKgAECn8ZAAIMAAgIDRqMDAACAgAMAAgIDRqMDAACAgAAAA==.',['爱小']='爱小潘:BAAAKgAFFAYIBAAAAA==.',['爱意']='爱意随钟起:BAABKgAFFH8IAAIVAAYI9w3iAwBiAQAVAAYI9w3iAwBiAQAAAA==.',['片羽']='片羽渡寒渊:BAAAKgADCgEIAQAAAA==.',['牛头']='牛头人:BAABKgAFFH8IAAIQAAIISSIKEgCxAAAQAAIISSIKEgCxAAAAAA==.',['牛牛']='牛牛犇犇:BAACKgAFFH8uAAICAAgIYiQpAQDQAQACAAgIYiQpAQDQAQAqAAQKf1EABAIACAgFJW4KALUCAAIACAgFJW4KALUCACAAAQiVGSEgAEoAAAMAAQgAANpoAAAAAAAA.',['牛蛙']='牛蛙猪排饭:BAAAKgAECgYICwAAAA==.',['牧牧']='牧牧:BAAAKgADCggICAAAAA==.',['牧舞']='牧舞:BAAAKgAECgQIAQAAAA==.',['特兰']='特兰奇亚:BAABKgAECn8xAAINAAgIUB3EDgAfAgANAAgIUB3EDgAfAgAAAA==.',['猫帝']='猫帝嘎嘎:BAABKgAECn8aAAIMAAgIMh3IFwA5AgAMAAgIMh3IFwA5AgAAAA==.',['琉璃']='琉璃槿:BAAAKgADCgQIBAAAAA==.',['瑶瑶']='瑶瑶的兔子:BAABKgAFFH8FAAIIAAMIlhiYJADbAAAIAAMIlhiYJADbAAAAAA==.',['瓦塔']='瓦塔西:BAAAKgAECggICAAAAA==.',['甘雨']='甘雨:BAABKgAFFH8FAAIIAAMIxRwEEwDHAAAIAAMIxRwEEwDHAAABKgAFFAYICgAUAEwXAA==.',['田鼠']='田鼠笑嘻嘻:BAABKgAFFH8GAAIUAAYIVwRWBACkAAAUAAYIVwRWBACkAAAAAA==.',['番茄']='番茄蛋饭:BAAAKgADCgMIAwAAAA==.',['白星']='白星:BAAAKgAECggICAAAAA==.',['瞬间']='瞬间爆表:BAABKgAFFH8GAAICAAYIdRw0DQB8AQACAAYIdRw0DQB8AQAAAA==.',['知心']='知心波波丶:BAABKgAFFH8HAAIIAAQITSRYBQAgAQAIAAQITSRYBQAgAQAAAA==.',['神猎']='神猎手:BAACKgAFFH8IAAIXAAQIGRbwNACtAAAXAAQIGRbwNACtAAAqAAQKfxYAAhcABwjTEXdSAFwBABcABwjTEXdSAFwBAAAA.',['秋心']='秋心:BAAAKgADCgYIBgAAAA==.',['笑掉']='笑掉半颗大牙:BAAAKgAFFAYIBAAAAA==.',['粉色']='粉色苦茶子:BAACKgAFFH8kAAIEAAgIihxBBgBZAgAEAAgIihxBBgBZAgAqAAQKfzYAAgQACAhNJFkbAKoCAAQACAhNJFkbAKoCAAAA.',['粒粒']='粒粒大魔王:BAAAKgAECgMIAwAAAA==.粒粒橙:BAABKgAFFH8KAAIiAAMI7wnRDACLAAAiAAMI7wnRDACLAAAAAA==.',['糖果']='糖果贩子:BAAAKgAECgEIAQAAAA==.',['糖玉']='糖玉叉烧丶:BAAAKgAFFAYIAwABKgAFFAgIBgAcABsRAA==.',['素灵']='素灵:BAAAKgAECgEIAQAAAA==.',['紫蝴']='紫蝴蝶:BAABKgAECn8XAAMJAAgIYRo1FAC/AQAJAAgIYRo1FAC/AQABAAcIvwv0ZwAtAQAAAA==.',['红尘']='红尘客栈:BAAAKgAFFAQIAQAAAA==.',['纯情']='纯情公烧甲:BAABKgAFFH8JAAMXAAUIYguqGADhAAAXAAQILg6qGADhAAAiAAUIOAVAFACiAAABKgAFFAgIDAAJANESAA==.',['绝不']='绝不意气用事:BAABKgAFFH8IAAIYAAgIUwTTBAClAQAYAAgIUwTTBAClAQAAAA==.',['绝对']='绝对不玩:BAAAKgAECgUIBQAAAA==.绝对核心:BAACKgAFFH8OAAMYAAMImBzkEwAAAQAYAAMImBzkEwAAAQASAAIIEw2dGQBoAAAqAAQKf0YAAxgACAhtISwPAJ4CABgACAhtISwPAJ4CABwAAQgDG3uKAE8AAAEqAAUUCAgYABwAhB4A.',['老父']='老父亲:BAAAKgAECgYIBgABKgAECggICAAfAAAAAA==.',['肯定']='肯定不玩:BAAAKgAFFAMIAwAAAA==.',['胡椒']='胡椒:BAABKgAFFH8GAAIXAAYIfxlYDwCQAQAXAAYIfxlYDwCQAQAAAA==.',['脚丫']='脚丫曾被亵渎:BAAAKgAECgUICQAAAA==.',['自爆']='自爆卵:BAAAKgAECgYIBgABKgAFFAIIAgAfAAAAAA==.',['艾丝']='艾丝蒂尔:BAAAKgAECgEIAQAAAA==.',['艾瑞']='艾瑞达:BAABKgAFFH8MAAIEAAMI6B3ZOwD+AAAEAAMI6B3ZOwD+AAAAAA==.',['芙莉']='芙莉莲丶:BAABKgAFFH8GAAIdAAYIpQwZDgA7AQAdAAYIpQwZDgA7AQAAAA==.',['花心']='花心烧烧:BAABKgAFFH8IAAIFAAgIIgb5CgChAQAFAAgIIgb5CgChAQAAAA==.',['花蝴']='花蝴蝶:BAABKgAFFH8IAAIXAAgIFA4GCQD0AQAXAAgIFA4GCQD0AQAAAA==.',['花香']='花香小叶:BAAAKgAECgQIBAABKgAFFAQIKAAjAOIjAA==.',['苍天']='苍天已死:BAAAKgAECgcIBwAAAA==.',['苏打']='苏打饼干:BAABKgAFFH8GAAMQAAYIhQrJEQC4AAAQAAQIiBHJEQC4AAAZAAIIAgAtGAABAAAAAA==.',['莫莫']='莫莫嘟嘟:BAAAKgADCgQIBQAAAA==.',['萌萌']='萌萌的小行星:BAAAKgAECgQICwAAAA==.',['萧晓']='萧晓筱:BAAAKgAECgEIAQAAAA==.',['萨格']='萨格拉满:BAAAKgAECgUIBQAAAA==.',['萨舞']='萨舞:BAAAKgAFFAQIAgAAAA==.',['萨鲁']='萨鲁法尔大王:BAAAKgADCgQIBAAAAA==.',['落花']='落花无意:BAAAKgAECgMIAwAAAA==.',['蕾玖']='蕾玖:BAAAKgAECgIIAgAAAA==.',['薛定']='薛定谔的厨子:BAACKgAFFH8NAAIaAAQIlySqBgBAAQAaAAQIlySqBgBAAQAqAAQKfyEAAxoACAjPJeYBAPYCABoACAjPJeYBAPYCACQABQiOBvsfAGkAAAEqAAUUCAgEAB8AAAAA.',['蛋黄']='蛋黄派:BAAAKgAFFAgIAQAAAA==.',['蜜桃']='蜜桃雪糕:BAABKgAFFH8QAAIBAAgIKyBdAgCUAgABAAgIKyBdAgCUAgAAAA==.',['西瓜']='西瓜多:BAAAKgAFFAgIBAAAAA==.',['观南']='观南丶:BAAAKgAFFAQIBAAAAA==.',['誓丿']='誓丿雨落星辰:BAAAKgAECgEIAQAAAA==.',['谢谢']='谢谢你的爱:BAAAKgADCgcIBwAAAA==.',['贝雷']='贝雷达尔:BAAAKgADCgEIAQAAAA==.',['贪财']='贪财好色:BAAAKgAFFAIIAgAAAA==.',['赦天']='赦天琴姬:BAAAKgAECgcICwAAAA==.',['车七']='车七七:BAAAKgAECgYIDwAAAA==.',['过一']='过一下剧情:BAAAKgAFFAQIBAAAAA==.',['远野']='远野:BAAAKgAECggICAAAAA==.',['那个']='那个辣条:BAAAKgAECgYIEgAAAA==.',['部落']='部落大表哥:BAABKgAFFH8GAAMGAAYINhjHBAAqAQAGAAUIKhzHBAAqAQAFAAEIZwjbSwA+AAAAAA==.',['酒鬼']='酒鬼的假发:BAAAKgAECgQIBgAAAA==.',['醉里']='醉里挑灯看奶:BAABKgAFFH8GAAITAAYIbQgwEgANAQATAAYIbQgwEgANAQAAAA==.',['重庆']='重庆森林:BAAAKgAECgIIAwAAAA==.',['铁锤']='铁锤骑士:BAAAKgAECgIIAgAAAA==.',['锅巴']='锅巴的义祖父:BAAAKgAECggICAAAAA==.',['阿尔']='阿尔卑斯丶:BAAAKgAECgEIAQAAAA==.阿尔萨廝:BAAAKgAECgEIAQAAAA==.',['阿巴']='阿巴瑟三:BAAAKgADCggICAABKgAECggIHAAMAMUkAA==.阿巴瑟瑟:BAABKgAECn8cAAIMAAgIxSS9EQBhAgAMAAgIxSS9EQBhAgAAAA==.',['阿晖']='阿晖丶:BAAAKgADCggICAAAAA==.',['陆佩']='陆佩璃:BAAAKgAECgQIBwAAAA==.',['隐术']='隐术:BAAAKgAECgEIAQAAAA==.',['雏田']='雏田:BAAAKgAECgMIAwAAAA==.',['零度']='零度幻想:BAAAKgAECgUICAAAAA==.',['靓靓']='靓靓:BAAAKgAECgQIBgAAAA==.',['顽强']='顽强的玉米:BAABKgAFFH8IAAINAAgIjwSyDgAUAQANAAgIjwSyDgAUAQAAAA==.',['風不']='風不停息:BAAAKgAFFAQIAgABKgAFFAgICAAHAHMNAA==.',['风之']='风之疾风:BAAAKgADCggICQAAAA==.风之痕迹:BAAAKgADCggICAAAAA==.',['风殇']='风殇之梦:BAABKgAECn8fAAMTAAgIoRTDDgCBAQATAAgIoRTDDgCBAQAPAAEIKw1lWAAsAAAAAA==.',['风的']='风的痕迹:BAAAKgADCgcIBwAAAA==.',['香叶']='香叶栀子:BAAAKgAFFAEIAQABKgAFFAgIFAAQAHkhAA==.',['香蕉']='香蕉元素:BAAAKgAECgUIBQAAAA==.',['骑摩']='骑摩托拾荒:BAAAKgAECggIEwAAAA==.',['鬼神']='鬼神上凡二代:BAAAKgAECgUIBQAAAA==.鬼神下凡:BAAAKgAECgYICwAAAA==.鬼神下凡二代:BAAAKgAECgMIAwAAAA==.鬼神宝宝:BAAAKgAECgEIAQAAAA==.鬼神轨道炮:BAAAKgAECgcICQAAAA==.',['鲁尼']='鲁尼:BAABKgAFFH8GAAIFAAYIPw7EFQBVAQAFAAYIPw7EFQBVAQAAAA==.',['鸭头']='鸭头肉:BAAAKgAECgMIAwAAAA==.',['麦姬']='麦姬珂:BAAAKgAECgUIBQAAAA==.',['麦田']='麦田射手:BAABKgAFFH8GAAIHAAYIIRTlEwBWAQAHAAYIIRTlEwBWAQAAAA==.',['黑姬']='黑姬结灯丶:BAABKgAFFH8LAAMKAAQIFhK5CgDaAAAKAAQIFhK5CgDaAAAMAAQI9RizJwDXAAAAAA==.',['黑牛']='黑牛之怒:BAAAKgAECgMIAwAAAA==.',['默默']='默默不玩:BAABKgAFFH8MAAMaAAMIrwxqIgCZAAAaAAMIrwxqIgCZAAAbAAEISwAfGAANAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end