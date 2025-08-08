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
 local lookup = {'Mage-Arcane','Mage-Frost','Mage-Fire','Druid-Restoration','Druid-Balance','Hunter-Marksmanship','Paladin-Retribution','Priest-Discipline','Priest-Holy','Priest-Shadow','Monk-Mistweaver','Paladin-Holy','Hunter-BeastMastery','Shaman-Restoration','DemonHunter-Havoc','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Warrior-Fury','Warrior-Arms','Monk-Brewmaster','DemonHunter-Vengeance','Paladin-Protection','Shaman-Elemental','DeathKnight-Blood','DeathKnight-Unholy',}; local provider = {region='CN',realm='迦顿',name='CN',type='weekly',zone=42,date='2025-08-02',data={Ai='Ainio:BAAAKgADCgcIBwAAAA==.',An='Anageter:BAABKgAECn8UAAQBAAgIohKpNQB1AQABAAgIqBGpNQB1AQACAAUIdAz2cwCvAAADAAMIlg5TdwCdAAAAAA==.',Ar='Arnold:BAABKgAECn8dAAIEAAgIPgTvUADJAAAEAAgIPgTvUADJAAAAAA==.',Bl='Bluenile:BAAAKgAECgQIBAAAAA==.',Gy='Gym:BAABKgAECn8UAAIFAAgIEAmJLQDmAAAFAAgIEAmJLQDmAAAAAA==.',Ir='Irelia:BAAAKgAFFAgIBAAAAA==.',Mi='Migolielie:BAABKgAFFH8GAAIGAAQIGhUcKwC+AAAGAAQIGhUcKwC+AAABKgAFFAgIDAAFAHMZAA==.Migoqiqi:BAABKgAFFH8KAAIHAAQIKx9rSADdAAAHAAQIKx9rSADdAAAAAA==.Mito:BAAAKgAECgIIAgAAAA==.',Qi='Qimoo:BAACKgAFFH8WAAQIAAQIviRoDQBAAQAIAAMIviRoDQBAAQAJAAQI0B4TGwDjAAAKAAIIiQ+OHACEAAAqAAQKfxcAAwgACAguIkAWABICAAgABwihHkAWABICAAkABAhJIIQyAHcBAAAA.',Si='Siegmund:BAAAKgAECggICAAAAA==.',Yo='Yoroi:BAAAKgADCggICAAAAA==.',['七彩']='七彩水母家的:BAAAKgAECgQIBwAAAA==.',['丶南']='丶南帝:BAAAKgADCgEIAQAAAA==.',['丶莫']='丶莫小熙:BAABKgAFFH8IAAIGAAgIRg3BBwC9AQAGAAgIRg3BBwC9AQAAAA==.',['丿晴']='丿晴天丶:BAAAKgAECgUIBwAAAA==.',['乄乌']='乄乌尔沁乄:BAAAKgAECgYIBgAAAA==.',['乱世']='乱世维纳斯:BAAAKgAECgEIAQAAAA==.',['人字']='人字拖:BAAAKgADCgIIAgAAAA==.',['佛糖']='佛糖:BAABKgAFFH8GAAILAAYIAA5DEQAgAQALAAYIAA5DEQAgAQAAAA==.',['你就']='你就别幻想了:BAAAKgAECgQIBAAAAA==.',['你要']='你要来骑我吗:BAAAKgADCgEIAQAAAA==.',['信仰']='信仰灬圣光:BAAAKgAECggIEAAAAA==.',['兜兜']='兜兜里囿糖:BAAAKgADCgEIAQAAAA==.',['剑玖']='剑玖陆千里:BAAAKgAECgMIBgAAAA==.',['北落']='北落师門:BAAAKgAECgIIAwAAAA==.',['十七']='十七神:BAAAKgADCggICQAAAA==.',['十三']='十三来了:BAAAKgADCgcICQAAAA==.十三骑士:BAAAKgADCgIIAgAAAA==.',['卡布']='卡布达:BAAAKgAFFAIIAgAAAA==.',['吉猫']='吉猫:BAAAKgAECggICAAAAA==.',['吟一']='吟一首好诗牛:BAAAKgADCgIIAgAAAA==.',['吼尐']='吼尐侠:BAAAKgAECgIIAgAAAA==.',['咖啡']='咖啡永不为奴:BAAAKgADCgEIAQAAAA==.',['哎呀']='哎呀你别跑:BAAAKgAECgQIBAAAAA==.',['啊梵']='啊梵达:BAAAKgAECgUICQAAAA==.',['四季']='四季寶:BAAAKgAECgYIBwAAAA==.',['回忆']='回忆十年:BAAAKgAECgQIBAAAAA==.',['团灭']='团灭剩骑士:BAABKgAFFH8PAAMHAAYIDx+CFwCgAQAHAAYIDx+CFwCgAQAMAAUIEgZyDADlAAAAAA==.',['国破']='国破山河在:BAAAKgAECggICAAAAA==.',['坚决']='坚决拥护:BAAAKgAECgMIBQAAAA==.',['坚如']='坚如磐石:BAAAKgADCgIIAgAAAA==.',['墓陵']='墓陵:BAAAKgADCggIDQAAAA==.',['壹坨']='壹坨酸奶牛:BAAAKgAECgUIBQAAAA==.',['壹贰']='壹贰叁肆的叁:BAAAKgADCgUICAAAAA==.壹贰叁肆的壹:BAAAKgADCgQIBAAAAA==.壹贰叁肆的捌:BAAAKgADCgEIAQAAAA==.壹贰叁肆的肆:BAAAKgADCgEIAQAAAA==.',['大哥']='大哥大殁得很:BAAAKgAECgIIAgAAAA==.大哥大邪得很:BAAAKgAECgEIAQAAAA==.',['大将']='大将军林三:BAAAKgAECgEIAgAAAA==.',['大爱']='大爱穿越:BAAAKgAFFAIIAgAAAA==.',['大苹']='大苹果:BAABKgAECn8wAAMNAAgIdRaRIABuAQANAAgIdRaRIABuAQAGAAEIdg8wqgAtAAAAAA==.',['天灾']='天灾男爵:BAAAKgADCgEIAQAAAA==.',['夫老']='夫老坎:BAAAKgAECggICAAAAA==.',['奚緔']='奚緔琺芍:BAABKgAECn8bAAILAAgIMRAWJgBeAQALAAgIMRAWJgBeAQAAAA==.',['奥维']='奥维利:BAAAKgADCgMIAwAAAA==.',['婉婉']='婉婉:BAAAKgAECgIIAgAAAA==.',['媽媽']='媽媽説:BAABKgAFFH8KAAIHAAMImRhdTwDRAAAHAAMImRhdTwDRAAAAAA==.',['嫩嫩']='嫩嫩的老鲜肉:BAAAKgAECgYIDQAAAA==.',['季落']='季落遗沫:BAAAKgADCggICAAAAA==.',['安度']='安度因乌瑞恩:BAAAKgAECgMIAwAAAA==.',['宝青']='宝青坊主:BAAAKgAFFAMIAwAAAA==.',['寂静']='寂静寒夜:BAAAKgAECgQIBAAAAA==.',['寡人']='寡人:BAAAKgAECgYIEwAAAA==.',['小吼']='小吼:BAAAKgADCgQIBAAAAA==.',['小奶']='小奶豆:BAAAKgADCgEIAQAAAA==.',['小小']='小小狐狐:BAAAKgAFFAQIBAAAAA==.小小顽顽皮皮:BAAAKgAECggICAAAAA==.',['小时']='小时候很洋气:BAABKgAFFH8GAAMCAAII4QeFJQBnAAACAAII4QeFJQBnAAABAAEIbgSZSAAvAAAAAA==.',['小银']='小银仙归来:BAAAKgAECgcIDAAAAA==.',['幻境']='幻境里的幻景:BAAAKgAECggICAAAAA==.',['开宝']='开宝马来接你:BAAAKgAECgEIAQAAAA==.',['很傻']='很傻很水的牛:BAACKgAFFH8JAAIOAAMI2RSMLQDBAAAOAAMI2RSMLQDBAAAqAAQKfx0AAg4ABgjNHlgNAPABAA4ABgjNHlgNAPABAAAA.',['忆笙']='忆笙:BAAAKgAECgUIDQAAAA==.',['怒風']='怒風:BAABKgAFFH8GAAIPAAMI9gefNQCqAAAPAAMI9gefNQCqAAAAAA==.',['愤怒']='愤怒啲妇焱洁:BAAAKgAECggIEgAAAA==.',['懒痒']='懒痒痒:BAAAKgAFFAMIAwAAAA==.',['我是']='我是凤凰:BAAAKgADCgMIAwAAAA==.我是老虎:BAAAKgADCgUIBQAAAA==.',['我来']='我来找菊花:BAAAKgADCggICQAAAA==.',['抹茶']='抹茶果汁:BAABKgAFFH8QAAQQAAYIlB2xDQCxAQAQAAYIYR2xDQCxAQARAAMIyyFhDgDFAAASAAIIFQUQFwCFAAABKgAFFAgIAgABAAIWAA==.',['拾六']='拾六厘米:BAAAKgAECgUIBwAAAA==.',['拿撒']='拿撒勒斯:BAAAKgADCgIIAgAAAA==.',['指尖']='指尖上的圣光:BAAAKgAECgEIAQAAAA==.',['提里']='提里奥丶弗丁:BAAAKgAECgYIBgAAAA==.',['教黄']='教黄爷爷:BAABKgAECn8lAAMCAAgIvRc5CwDHAQACAAgIvRc5CwDHAQABAAEIAAAAAAAAAAAAAA==.',['无聊']='无聊玩玩:BAAAKgAECgQIBAAAAA==.',['明月']='明月凄风:BAACKgAFFH8KAAIHAAYIziDIDAABAgAHAAYIziDIDAABAgAqAAQKfzwAAwcACAiBGN0XAAECAAcACAiBGN0XAAECAAwACAiED1glADQBAAAA.',['晓风']='晓风残月:BAAAKgAFFAQIBAAAAA==.',['晦涩']='晦涩黎明:BAAAKgAECgUIBQAAAA==.',['智商']='智商已暴露:BAABKgAFFH8ZAAMTAAMIBQ9fIQDOAAATAAMI6Q5fIQDOAAAUAAII2wehIwB2AAAAAA==.',['替沧']='替沧海寄巫山:BAACKgAFFH8GAAIQAAMIjQl+GwCiAAAQAAMIjQl+GwCiAAAqAAQKfxwAAhAABwg/F505ACUBABAABwg/F505ACUBAAAA.',['月影']='月影独眠:BAAAKgADCgYIBgAAAA==.',['未长']='未长大的面包:BAAAKgAECgUIBQAAAA==.',['末子']='末子:BAAAKgADCggIDwAAAA==.',['杨子']='杨子二:BAABKgAFFH8SAAMLAAQIyhi8GQDQAAALAAQIyhi8GQDQAAAVAAMI4QoFCACPAAAAAA==.',['柑蕉']='柑蕉桔梨禄柚:BAAAKgAECgYICwAAAA==.',['柚柚']='柚柚子:BAAAKgAFFAQIBAAAAA==.',['棘心']='棘心夭夭:BAAAKgAECggIBQAAAA==.',['水果']='水果桶:BAABKgAFFH8GAAIOAAYIMAsqFQAwAQAOAAYIMAsqFQAwAQAAAA==.水果茶:BAABKgAFFH8GAAILAAYIbBNhDQBOAQALAAYIbBNhDQBOAQAAAA==.',['沙漠']='沙漠幽魂:BAAAKgADCgUIBQAAAA==.',['泰瑞']='泰瑞尓:BAAAKgADCgIIAgAAAA==.',['涅法']='涅法蕾姆:BAAAKgADCggICAAAAA==.',['涅磐']='涅磐一怒风:BAAAKgAECgEIAQAAAA==.',['清一']='清一色四暗刻:BAAAKgAFFAgIAgAAAA==.',['温温']='温温馨馨:BAAAKgAECggICAAAAA==.',['游亚']='游亚旧梦:BAAAKgAECgYIDQAAAA==.',['漂泊']='漂泊如风:BAAAKgADCgYIBgAAAA==.',['灰白']='灰白眼瞳:BAAAKgAECgQIBgAAAA==.',['燃烧']='燃烧的战刃:BAAAKgAECgIIAgAAAA==.',['牛一']='牛一箭:BAAAKgAECggICAAAAA==.',['牛德']='牛德糊涂:BAAAKgAFFAQIBAAAAA==.',['牛魔']='牛魔魔:BAAAKgAECgQIBAAAAA==.',['牵着']='牵着小手:BAAAKgADCgIIAgAAAA==.',['特别']='特别来宾:BAAAKgAECgIIAgAAAA==.',['猛虎']='猛虎总独行:BAAAKgADCgIIAgAAAA==.',['珂蕊']='珂蕊:BAAAKgAECggIDwAAAA==.',['生前']='生前非常帅:BAAAKgAFFAYIAwAAAA==.',['疯疯']='疯疯:BAABKgAECn8cAAMPAAgIPxSFRQCSAQAPAAcINRaFRQCSAQAWAAMIBgaVXABbAAAAAA==.',['皓皓']='皓皓:BAAAKgADCgEIAQAAAA==.',['瞎打']='瞎打发卡:BAAAKgADCgQIBAAAAA==.',['硪叫']='硪叫哀木涕:BAABKgAFFH8GAAIFAAYI7hoiEwCDAQAFAAYI7hoiEwCDAQAAAA==.',['碳酸']='碳酸果汁:BAAAKgAFFAQIBAAAAA==.',['神兹']='神兹巫兹:BAAAKgAECggIBwAAAA==.',['秋风']='秋风:BAAAKgAECggIEgAAAA==.',['穆风']='穆风:BAABKgAFFH8IAAMGAAMIFxFBLgCzAAAGAAMIFxFBLgCzAAANAAIIcQliUQBnAAAAAA==.',['粉色']='粉色体育生:BAAAKgAECggIEAAAAA==.',['紫薇']='紫薇:BAAAKgAECggIDAAAAA==.',['紫薯']='紫薯精:BAAAKgAECggICgAAAA==.',['织语']='织语长心:BAABKgAECn8VAAMXAAgInQUHPQCRAAAXAAgIRgQHPQCRAAAHAAIIPQemXgFKAAAAAA==.',['络殇']='络殇:BAABKgAECn8YAAIEAAgIXx7TDQBgAgAEAAgIXx7TDQBgAgAAAA==.',['维克']='维克多雨果:BAAAKgADCggICAAAAA==.',['美不']='美不美看大褪:BAAAKgADCggICAAAAA==.',['老头']='老头:BAAAKgAECgYIBgAAAA==.',['聖洸']='聖洸唿悠了我:BAAAKgAECgYIBgAAAA==.',['胖头']='胖头鱼家的:BAAAKgAFFAIIAgAAAA==.',['胸越']='胸越小心越近:BAAAKgAECgUIBQAAAA==.',['脑袋']='脑袋瓜子:BAABKgAFFH8HAAIHAAQI/BqTFgAAAQAHAAQI/BqTFgAAAQAAAA==.',['艾亚']='艾亚哥斯:BAABKgAFFH8XAAMRAAMIPxFwDwC/AAARAAMIPxFwDwC/AAAQAAMIjAirNACdAAAAAA==.',['花间']='花间:BAABKgAFFH8JAAIOAAMIkgwaNgCmAAAOAAMIkgwaNgCmAAAAAA==.',['茜苽']='茜苽可苛荳:BAABKgAFFH8cAAMEAAYIEw10AgB0AQAEAAYIEw10AgB0AQAFAAYIPhqWBwAzAQAAAA==.',['茯叶']='茯叶:BAABKgAFFH8GAAMJAAMIdRO0EwCgAAAJAAMIdRO0EwCgAAAKAAMIJge4HgCTAAAAAA==.',['荣耀']='荣耀利刃:BAAAKgADCggICAAAAA==.',['莫无']='莫无言:BAAAKgAECgQIBAAAAA==.',['菲迪']='菲迪斯:BAAAKgAECgIIAgAAAA==.',['萌灬']='萌灬小夕:BAAAKgAFFAIIAgAAAA==.萌灬小夜:BAAAKgAFFAgIAwAAAA==.',['萌萌']='萌萌哒花栗鼠:BAABKgAFFH8eAAMPAAgIPhzZBABuAgAPAAgIPhzZBABuAgAWAAcIygzLAwBnAQAAAA==.萌萌的大鸟:BAAAKgADCggICAAAAA==.',['落雪']='落雪:BAAAKgAECggICAAAAA==.',['蒨嬌']='蒨嬌絔媚:BAAAKgADCggIDwAAAA==.',['蔚奥']='蔚奥莱:BAAAKgAECgEIAQAAAA==.',['蜜玛']='蜜玛:BAABKgAFFH8GAAIEAAYIERKSCgBeAQAEAAYIERKSCgBeAQAAAA==.',['蝶野']='蝶野真舞:BAABKgAFFH8FAAMIAAQI4QWsIwCUAAAIAAIIbwmsIwCUAAAJAAIIUwKxPQBFAAAAAA==.',['螺旋']='螺旋丸:BAABKgAFFH8OAAMOAAMIXRfdKADTAAAOAAMIXRfdKADTAAAYAAIInAzPIAB3AAAAAA==.',['血嗜']='血嗜之花:BAAAKgAECgEIAQAAAA==.血嗜之魂:BAAAKgADCggICAAAAA==.',['西湖']='西湖龙井茶:BAABKgAFFH8OAAMZAAgIhhpKAQC7AQAZAAYIWx1KAQC7AQAaAAQIpBenGgBIAQAAAA==.',['西门']='西门大官人:BAABKgAECn8qAAMGAAgI1hUSNQCHAQAGAAgIjhMSNQCHAQANAAcIKhW8TwBtAQAAAA==.',['谜途']='谜途小羔羊:BAAAKgADCgQIBAAAAA==.',['跟我']='跟我走丶:BAAAKgAECgQIBAAAAA==.',['轩大']='轩大胖子:BAAAKgADCggICAAAAA==.',['迎风']='迎风飘去:BAAAKgAECgcIEgAAAA==.',['这是']='这是什么心态:BAAAKgAECggICQAAAA==.',['钱赞']='钱赞企:BAAAKgAECgUIBQABKgAECggIGAAEAF8eAA==.',['铁针']='铁针:BAABKgAFFH8GAAICAAYIaBBkBwBPAQACAAYIaBBkBwBPAQAAAA==.',['闷开']='闷开:BAAAKgADCggIDQAAAA==.',['阿一']='阿一达:BAAAKgAECgIIAgAAAA==.',['随便']='随便射射:BAAAKgAECgQIBAAAAA==.',['难德']='难德游戏:BAAAKgAECgEIAQAAAA==.',['雨昔']='雨昔:BAAAKgAECggIEgAAAA==.',['雨页']='雨页:BAAAKgAECgYIBgAAAA==.',['零丨']='零丨概念:BAAAKgADCgEIAQAAAA==.',['霜火']='霜火烤面包:BAAAKgAECgQIBAAAAA==.',['青春']='青春已过夕阳:BAAAKgAECggICwAAAA==.',['青雨']='青雨落白衣丶:BAAAKgAECgYICgAAAA==.',['面包']='面包:BAAAKgADCgMIAwAAAA==.',['香葱']='香葱梳打饼:BAAAKgAECgQIBAAAAA==.',['马马']='马马鱼:BAAAKgAECggICAAAAA==.',['骑蜗']='骑蜗牛追美女:BAAAKgADCggICAAAAA==.',['鬼舞']='鬼舞凤凰:BAAAKgADCgIIAgAAAA==.',['魚丸']='魚丸拌饭:BAAAKgADCgYIBgAAAA==.',['鯊魚']='鯊魚辣椒:BAABKgAFFH8FAAMWAAQIERE/CwCpAAAWAAQIDww/CwCpAAAPAAEIAxzeMQBSAAAAAA==.',['鱼丸']='鱼丸奶爸:BAAAKgAFFAMIAwAAAA==.鱼丸粗面:BAAAKgAECgMIAwAAAA==.',['鹿希']='鹿希法:BAAAKgAFFAQIBAAAAA==.',['黑木']='黑木崖:BAAAKgAECgUIBgAAAA==.',['黑色']='黑色恶魔:BAAAKgADCgMIBQAAAA==.黑色耀眼:BAAAKgADCgIIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end