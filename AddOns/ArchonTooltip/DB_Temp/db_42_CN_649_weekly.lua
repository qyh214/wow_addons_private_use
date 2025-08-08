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
 local lookup = {'Shaman-Elemental','DeathKnight-Frost','DeathKnight-Unholy','Evoker-Preservation','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Fury','Paladin-Retribution','Paladin-Protection','DeathKnight-Blood','Shaman-Restoration','Warrior-Protection','Warlock-Destruction','Hunter-BeastMastery','Evoker-Devastation','Druid-Balance','Druid-Restoration','Druid-Guardian','Warlock-Demonology','Warlock-Affliction','Hunter-Marksmanship','Hunter-Survival','Monk-Mistweaver','Monk-Brewmaster','Mage-Arcane','Mage-Frost','Mage-Fire','Rogue-Subtlety','Rogue-Assassination','Druid-Feral','Unknown-Unknown',}; local provider = {region='CN',realm='安加萨',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ar='Arigatou:BAAAKgADCggICAAAAA==.',Ba='Baccano:BAAAKgAFFAIIAgAAAA==.',Ch='Choose:BAABKgAECn/kAwIBAAgItiatAAAXAwABAAgItiatAAAXAwAAAA==.',Cr='Creepyc:BAABKgAECn8hAAMCAAgIKSOIAQDaAgACAAgIKSOIAQDaAgADAAEIaADoyAACAAAAAA==.',Li='Littleodemon:BAAAKgAECggICAAAAA==.',Mo='Mortis:BAAAKgAECgYIBgABKgAFFAgIGAAEAI0SAA==.',Ne='Nexd:BAAAKgAECggICAAAAA==.',Pl='Playerxydwcz:BAAAKgAECgYIDAAAAA==.',Qs='Qser:BAAAKgAECgQIBAAAAA==.',Sh='Shashasama:BAABKgAFFH8IAAIFAAgIihfTBgA2AgAFAAgIihfTBgA2AgAAAA==.',Sk='Skyez:BAAAKgAECggICAAAAA==.',So='Soleye:BAAAKgADCgYIBgAAAA==.',Ta='Tanuki:BAAAKgADCggICwAAAA==.',Yu='Yumao:BAABKgAFFH8GAAIGAAMIjgY4EwBqAAAGAAMIjgY4EwBqAAAAAA==.',Zi='Zimengdh:BAAAKgAFFAYIAgAAAA==.',['一无']='一无所有:BAAAKgAECgYICgAAAA==.',['不嘻']='不嘻嘻:BAAAKgAECgcIBwAAAA==.',['不落']='不落皇旗前:BAABKgAFFH8RAAIHAAQIZR8eGAD5AAAHAAQIZR8eGAD5AAAAAA==.',['不蓝']='不蓝角:BAAAKgAECgcIBwAAAA==.',['中锋']='中锋躺地板:BAAAKgAECgUIBQAAAA==.',['丶劉']='丶劉德華:BAABKgAFFH8KAAIHAAMIfh2aFAAZAQAHAAMIfh2aFAAZAQAAAA==.',['丶青']='丶青山劉德華:BAABKgAFFH8FAAIIAAMIgBPmSgDZAAAIAAMIgBPmSgDZAAAAAA==.',['乄故']='乄故人旧眸:BAAAKgAECgIIAgAAAA==.',['乐精']='乐精灵:BAAAKgADCggIEAAAAA==.',['乙戈']='乙戈:BAAAKgAECgIIAwAAAA==.',['二手']='二手电工:BAAAKgAECgYICAAAAA==.',['人丑']='人丑爱作怪:BAAAKgAECggIDAAAAA==.',['伟哥']='伟哥丶:BAAAKgAECggICAAAAA==.',['你黑']='你黑你有道理:BAAAKgADCggICQAAAA==.',['倾城']='倾城丶圣契:BAABKgAFFH8aAAMJAAgILCPoAQCeAgAJAAgIhCLoAQCeAgAIAAQIBSaQHwDqAAAAAA==.',['假装']='假装很轻松:BAAAKgAECggICAAAAA==.假装有名字:BAAAKgAECggICAAAAA==.',['傻馒']='傻馒祭司:BAAAKgAFFAQIBAAAAA==.',['光年']='光年以北:BAABKgAFFH8GAAIKAAYI8gMZDAC6AAAKAAYI8gMZDAC6AAAAAA==.',['光明']='光明中的黑暗:BAAAKgAECgQIBQAAAA==.',['冥火']='冥火帽子时光:BAAAKgAECgQIBAAAAA==.',['刘亦']='刘亦绯:BAAAKgADCgYIBgAAAA==.',['化猫']='化猫猫:BAAAKgAECgIIAgAAAA==.',['北卡']='北卡丶蓝:BAAAKgAECgIIAgAAAA==.',['北欧']='北欧女人:BAABKgAECn8YAAILAAgIXReuKgDSAQALAAgIXReuKgDSAQAAAA==.',['午夜']='午夜屠猪男:BAAAKgAFFAQIBAAAAA==.',['南京']='南京翘嘴王:BAAAKgAECgMIBQAAAA==.',['发光']='发光胡子美女:BAABKgAECn8eAAMMAAgIuQTWMwCeAAAMAAgIuQTWMwCeAAAHAAEIkgJomQAiAAAAAA==.',['古驰']='古驰:BAAAKgADCggICAAAAA==.',['可楽']='可楽加牛奶:BAAAKgAFFAMIAQAAAA==.',['君悦']='君悦:BAAAKgAECgYICAAAAA==.',['听过']='听过的歌:BAAAKgAFFAQIBAAAAA==.',['周扒']='周扒皮偷枇杷:BAAAKgADCgIIAgAAAA==.',['哈次']='哈次捏米库:BAABKgAFFH8MAAINAAMI8gilNACdAAANAAMI8gilNACdAAAAAA==.',['哥们']='哥们好胸呀:BAABKgAFFH8GAAIOAAYIfxYOFABVAQAOAAYIfxYOFABVAQAAAA==.',['哩哩']='哩哩是笨蛋:BAAAKgADCgMIAwAAAA==.',['唑牙']='唑牙:BAABKgAFFH8JAAIFAAMIOAahNwCiAAAFAAMIOAahNwCiAAAAAA==.',['囯寳']='囯寳:BAAAKgAECggIEQAAAA==.',['圣人']='圣人孙夫子:BAAAKgAECgEIAQAAAA==.',['壹姐']='壹姐:BAAAKgAECgEIAQAAAA==.',['夜夜']='夜夜生戈:BAAAKgAFFAQIBAAAAA==.',['大别']='大别熊别又别:BAAAKgAFFAIIAgAAAA==.',['大头']='大头大:BAAAKgADCggICAAAAA==.',['天命']='天命难违:BAAAKgAECgEIAQAAAA==.',['天相']='天相:BAABKgAFFH8GAAIIAAYI9g1jKwA5AQAIAAYI9g1jKwA5AQAAAA==.',['太刀']='太刀侠:BAAAKgAECggIEAAAAA==.',['妞妞']='妞妞:BAAAKgADCggICAAAAA==.',['妹妹']='妹妹别跑呀:BAABKgAFFH8MAAMIAAYI6CAxEADeAQAIAAYI6CAxEADeAQAJAAIIWAM0FgBNAAAAAA==.',['始乱']='始乱终弃丶:BAAAKgADCgEIAQAAAA==.',['姐爱']='姐爱加血:BAAAKgAECggIDwAAAA==.',['婼妩']='婼妩灬倾城:BAAAKgAECgIIAgAAAA==.',['子弹']='子弹飞一会:BAAAKgADCgEIAQAAAA==.',['孙子']='孙子丶丶:BAAAKgAFFAQIBAAAAA==.',['安娜']='安娜:BAAAKgAECgIIAgAAAA==.',['宮脇']='宮脇咲良:BAACKgAFFH8tAAIPAAcIBRCZEgA+AQAPAAcIBRCZEgA+AQAqAAQKfysAAg8ACAidGukZAO8BAA8ACAidGukZAO8BAAAA.',['寒蝉']='寒蝉冥泣:BAAAKgAECgUICAAAAA==.',['对自']='对自己真狠:BAAAKgAECgcICwAAAA==.',['小龙']='小龙龙人:BAAAKgAECggIEwAAAA==.',['尘埃']='尘埃:BAABKgAECn8YAAIQAAgIFBYJSwCBAQAQAAgIFBYJSwCBAQAAAA==.尘埃晓萨:BAAAKgAECgYICAAAAA==.尘埃晓骑:BAACKgAFFH8KAAIIAAYI5iIuEgDLAQAIAAYI5iIuEgDLAQAqAAQKfxwAAwgACAh3IVkvAGMCAAgACAh3IVkvAGMCAAkAAQgAABFyAAAAAAAA.',['就奶']='就奶我:BAAAKgAFFAQIAwAAAA==.',['尼诺']='尼诺滴咕咕:BAACKgAFFH8TAAMRAAYIxA4VDQA6AQARAAYIxA4VDQA6AQAQAAEIAAASaAAAAAAqAAQKfyUABBEACAiFGZwhALwBABEACAiFGZwhALwBABAAAgj2GXC6AE0AABIAAQhsBN48AAsAAAAA.',['岁月']='岁月墨染:BAABKgAECn8VAAIDAAgI5RTILQDCAQADAAgI5RTILQDCAQAAAA==.',['岚李']='岚李斯特:BAAAKgAECgQIBgAAAA==.',['崔斯']='崔斯塔娜:BAAAKgAECgEIAQAAAA==.',['帅气']='帅气小小生:BAAAKgAECgUICQAAAA==.',['带刺']='带刺小九:BAABKgAFFH8IAAQNAAgIhQmQHQAbAQANAAYIAAeQHQAbAQATAAEIIRoTIwBUAAAUAAEIhgUqIgBEAAAAAA==.',['年年']='年年有魚:BAAAKgAFFAYIBAAAAA==.',['康斯']='康斯坦丁丶:BAACKgAFFH8GAAIQAAQIWBwVJwD5AAAQAAQIWBwVJwD5AAAqAAQKfy8AAxAACAgWJKAWAH0CABAACAgWJKAWAH0CABEACAiuFU2FADUAAAEqAAUUCAgIABMASiMA.',['弹药']='弹药充足:BAAAKgAFFAgIBAAAAA==.',['德才']='德才兼备:BAABKgAECn8bAAQRAAgI0QtQNwANAQARAAgI0QtQNwANAQASAAII/AVaPAA0AAAQAAEIaAa+5gAWAAAAAA==.',['心术']='心术不歪:BAAAKgAECgUIBgAAAA==.',['忠贞']='忠贞至臻丶:BAAAKgADCgEIAQAAAA==.',['恶魔']='恶魔的咒语:BAAAKgAECgQIBAAAAA==.',['我宝']='我宝宝呢:BAACKgAFFH8GAAMVAAYIhhqgDQDkAAAVAAQIkxSgDQDkAAAOAAIIcyMTIADXAAAqAAQKfxUAAxUACAg3H6oqAJIBAA4ABwgUHuFSALgBABUACAhCG6oqAJIBAAAA.',['我是']='我是奶龙:BAACKgAFFH8YAAIEAAgIjRI+AQDwAQAEAAgIjRI+AQDwAQAqAAQKf1wAAwQACAgJJnUAAPQCAAQACAgJJnUAAPQCAA8ABwh3H8oHACYCAAAA.我是斯蒂芬:BAAAKgAECggIEwAAAA==.',['扒拉']='扒拉咚:BAAAKgAFFAMIAwAAAA==.',['打死']='打死小毛奇:BAAAKgAECgYIBgAAAA==.',['抹茶']='抹茶小蛋糕喵:BAAAKgAECggICAAAAA==.',['昆仑']='昆仑山昆汀:BAAAKgADCgEIAQAAAA==.',['是风']='是风子千呀:BAAAKgAECgYIBgAAAA==.',['晓芙']='晓芙灬丽:BAAAKgAECggIEQAAAA==.',['暁坏']='暁坏坏:BAAAKgAFFAYIAQAAAA==.',['月下']='月下灬小乖猫:BAAAKgAECgEIAQAAAA==.',['月老']='月老:BAAAKgAFFAYIAgAAAA==.',['月舞']='月舞风影:BAAAKgADCgUIBQAAAA==.',['本多']='本多二代:BAAAKgAECgEIAQAAAA==.',['杂念']='杂念:BAAAKgAFFAIIBAAAAA==.',['李慧']='李慧珍:BAAAKgAECgMIAwAAAA==.',['材料']='材料仓库一:BAAAKgAECgMIBAAAAA==.',['森林']='森林狼:BAACKgAFFH8OAAIWAAMIehX6AAD/AAAWAAMIehX6AAD/AAAqAAQKfy4AAxYACAi7JNwAAOoCABYACAiFJNwAAOoCABUABwg9HyMqAJUBAAAA.',['欢乐']='欢乐的小淇:BAACKgAFFH8KAAILAAYIhBosCgAGAQALAAYIhBosCgAGAQAqAAQKfxQAAgsACAipItcMAJECAAsACAipItcMAJECAAAA.',['武当']='武当:BAABKgAECn8dAAMXAAcI1g3rOQDlAAAXAAYIBxDrOQDlAAAYAAEI9AEAAAAAAAAAAA==.',['残妆']='残妆丶:BAAAKgAECggICAAAAA==.',['水煮']='水煮牛鞭丶:BAAAKgAECgYICgAAAA==.',['永恒']='永恒旋律:BAAAKgAFFAQIBAAAAA==.',['沉沦']='沉沦万千:BAABKgAFFH8KAAIIAAQIqww5WgC9AAAIAAQIqww5WgC9AAAAAA==.沉沦法爷:BAAAKgADCgEIAQAAAA==.',['沉默']='沉默地羔羊:BAAAKgAECgQIBAAAAA==.沉默狮子:BAAAKgAECgUIBQAAAA==.',['法力']='法力残渣:BAAAKgAECggICAAAAA==.',['泰沙']='泰沙达:BAAAKgAECggICAAAAA==.',['洒家']='洒家已醉:BAAAKgAECgMIBAAAAA==.',['浊酒']='浊酒恋红尘:BAAAKgAECgYIDAAAAA==.',['灬寒']='灬寒瞳乄:BAAAKgAECggICQAAAA==.',['灬缺']='灬缺德乄:BAAAKgAECgYICAAAAA==.',['灵魂']='灵魂愈合:BAAAKgAECggIEAAAAA==.灵魂绽放:BAAAKgAFFAMIAQAAAA==.',['点解']='点解冇有水:BAAAKgAECgYIBgAAAA==.',['牙牙']='牙牙乐丶:BAAAKgAECgUIBQAAAA==.',['白胡']='白胡子老头:BAAAKgAECgYIBwAAAA==.',['皮多']='皮多肉少:BAACKgAFFH8GAAIZAAYI4xojDgCEAQAZAAYI4xojDgCEAQAqAAQKfxwAAhoACAgvH0sTAGQCABoACAgvH0sTAGQCAAAA.',['相见']='相见欢:BAAAKgAECgYIBgAAAA==.',['看我']='看我小红人:BAAAKgADCgIIAgAAAA==.',['穿越']='穿越者:BAAAKgAECgYIBgAAAA==.',['笑笑']='笑笑:BAABKgAFFH8fAAIXAAUIIBzVCwBpAQAXAAUIIBzVCwBpAQAAAA==.',['糖皇']='糖皇救我:BAAAKgAECggICgABKgAFFAgIDgAZACQgAA==.',['終丶']='終丶雨:BAAAKgAECgYIBgAAAA==.',['繁花']='繁花似蓉:BAAAKgAECgIIAgAAAA==.',['给爷']='给爷跪下:BAAAKgAECgYIBwAAAA==.',['绝世']='绝世男佣:BAABKgAFFH8GAAIZAAYIHwnSLwClAAAZAAYIHwnSLwClAAABKgAFFAgIRwAbADUlAA==.',['绝望']='绝望大咕咕:BAAAKgAECggIEgAAAA==.绝望的圣光:BAAAKgAECgIIAgAAAA==.绝望的天灾:BAAAKgADCgEIAQAAAA==.绝望的幻月:BAAAKgAFFAEIAQAAAA==.绝望的虚空:BAAAKgADCgEIAQAAAA==.',['绿色']='绿色飞翔:BAAAKgAECgQIBgAAAA==.',['老姨']='老姨吃嫩草:BAABKgAFFH8GAAIZAAYI1ApJGAAhAQAZAAYI1ApJGAAhAQAAAA==.',['肾补']='肾补光:BAAAKgADCgEIAQAAAA==.',['胖鹌']='胖鹌鹑:BAAAKgAECgIIAgAAAA==.',['脚指']='脚指头:BAABKgAECn8VAAIRAAcIzR5iGQDUAQARAAcIzR5iGQDUAQAAAA==.',['脚趾']='脚趾头:BAAAKgAECgEIAQAAAA==.',['舞动']='舞动的萧瑟:BAAAKgAECgMIAwAAAA==.',['芒果']='芒果丁:BAAAKgAECgMIAwAAAA==.',['苏醒']='苏醒的羊咩咩:BAAAKgAECgQICgAAAA==.',['范廸']='范廸塞尔:BAABKgAECn9kAAIVAAgIvyVtAwDyAgAVAAgIvyVtAwDyAgAAAA==.',['蒙牛']='蒙牛蛋:BAAAKgAECgMIAwAAAA==.',['蓝玉']='蓝玉飞鱼:BAAAKgAECggICAAAAA==.',['蓝色']='蓝色妖姬:BAAAKgAECgQIBAAAAA==.',['虎头']='虎头鱼伍号盾:BAAAKgAECgIIAgAAAA==.',['血晗']='血晗愁:BAABKgAFFH8GAAMcAAQICxUeBgCUAAAdAAQI3BHPGQDbAAAcAAIInRYeBgCUAAAAAA==.',['血诅']='血诅咒:BAACKgAFFH8jAAIbAAYIpBNrEwAhAQAbAAYIpBNrEwAhAQAqAAQKfyUAAxsACAjNFaUgAC4BABsACAjNFaUgAC4BABoABggXCg5mANgAAAAA.',['西宮']='西宮硝子:BAABKgAECn8XAAURAAgIfBVTCwC8AQARAAgIfBVTCwC8AQAeAAQIxyF8CQApAQASAAUIARFnKwCSAAAQAAEIZxZlywBAAAABKgAFFAgIAgAfAAAAAA==.',['赤古']='赤古:BAABKgAECn8UAAIVAAcImwtAXADkAAAVAAcImwtAXADkAAAAAA==.',['超爷']='超爷:BAAAKgADCgQIBAAAAA==.',['迷人']='迷人小陷阱:BAABKgAFFH8gAAIVAAYIwRmnDgB1AQAVAAYIwRmnDgB1AQAAAA==.',['释迦']='释迦殿下:BAABKgAFFH8GAAIIAAYIExmYKgA9AQAIAAYIExmYKgA9AQAAAA==.',['铛铛']='铛铛小术:BAAAKgADCggICAAAAA==.',['长的']='长的和谐点嘛:BAABKgAFFH8FAAIaAAIINAvKJQBlAAAaAAIINAvKJQBlAAAAAA==.',['闪闪']='闪闪:BAAAKgADCgMIAwAAAA==.',['阿尔']='阿尔玟晨星:BAAAKgAECggICAAAAA==.',['阿皮']='阿皮屁:BAAAKgADCgEIAQAAAA==.',['零六']='零六叁:BAAAKgADCgIIAgAAAA==.',['霹雳']='霹雳浪味仙:BAAAKgAFFAgIAwABKgAFFAgIBAAfAAAAAA==.霹雳火刃:BAAAKgAECggICAAAAA==.',['风影']='风影蒙太奇:BAAAKgADCggICAAAAA==.',['风流']='风流小德糖:BAAAKgADCggICAAAAA==.风流木棉糖:BAAAKgAECggIDwAAAA==.风流棉花糖:BAAAKgAECgQIBgAAAA==.风流牛奶糖:BAAAKgAECggIEAAAAA==.风流猎糖:BAAAKgADCggICAAAAA==.风流跳跳糖:BAAAKgAECgYIBgAAAA==.',['飞羽']='飞羽:BAAAKgAECgQIBAAAAA==.',['马超']='马超:BAAAKgADCggICAAAAA==.',['鬼舞']='鬼舞辻橆惨:BAAAKgAECgUICQAAAA==.鬼舞辻無惨:BAAAKgAECgcICwAAAA==.',['鬼贞']='鬼贞子:BAAAKgAFFAYIBAAAAA==.',['鬽靈']='鬽靈:BAAAKgAECgIIAgAAAA==.',['魂之']='魂之挽歌:BAAAKgAECgQIBgAAAA==.',['魔法']='魔法美少女:BAABKgAFFH8IAAIMAAgINgxEAwCJAQAMAAgINgxEAwCJAQAAAA==.',['魔神']='魔神释天:BAAAKgAFFAEIAQAAAA==.',['黑心']='黑心肺:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end