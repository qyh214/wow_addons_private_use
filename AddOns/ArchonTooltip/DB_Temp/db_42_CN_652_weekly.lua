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
 local lookup = {'DeathKnight-Unholy','Shaman-Enhancement','Paladin-Retribution','DemonHunter-Havoc','DeathKnight-Blood','Paladin-Protection','DemonHunter-Vengeance','Warlock-Destruction','Warlock-Affliction','Evoker-Devastation','Druid-Balance','Druid-Restoration','Hunter-Marksmanship','Warrior-Arms','Warrior-Fury','Priest-Discipline','Priest-Shadow','Priest-Holy','Paladin-Holy','Shaman-Restoration','Monk-Mistweaver','Druid-Guardian','Rogue-Assassination','Hunter-BeastMastery','Mage-Frost','Monk-Windwalker','Monk-Brewmaster','Hunter-Survival','Shaman-Elemental','Warlock-Demonology','Mage-Fire',}; local provider = {region='CN',realm='安戈洛',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alphabear:BAAAKgADCggICwAAAA==.',De='Deepdarkboys:BAACKgAFFH8iAAIBAAQIWhzQJQD5AAABAAQIWhzQJQD5AAAqAAQKfx0AAgEACAgnIgIZAGoCAAEACAgnIgIZAGoCAAAA.',Di='Dissolute:BAACKgAFFH8JAAICAAYIoB7+BQCeAQACAAYIoB7+BQCeAQAqAAQKfyMAAgIACAhqH50MACcCAAIACAhqH50MACcCAAAA.',El='Eleuseus:BAAAKgAFFAQIBAAAAA==.',Ha='Happyl:BAAAKgADCggICAAAAA==.',Hi='Hiiamjay:BAABKgAFFH8FAAIDAAUItyVNEwDBAQADAAUItyVNEwDBAQAAAA==.',Ma='Magicdh:BAABKgAFFH8FAAIEAAUIUxKiIQD5AAAEAAUIUxKiIQD5AAABKgAFFAgIFgAFACgiAA==.Magichan:BAABKgAFFH8KAAIGAAYIhhhsCgBUAQAGAAYIhhhsCgBUAQAAAA==.',Nu='Nukoo:BAABKgAECn8UAAMHAAUIJB4gKABBAQAHAAUIJB4gKABBAQAEAAUIVhDwcQDnAAAAAA==.',Re='Reality:BAABKgAFFH8GAAMIAAQI1xUXLgC1AAAIAAQI1xUXLgC1AAAJAAII+wHJIQA4AAAAAA==.',Sa='Salmon:BAAAKgAECgMIBQAAAA==.',Se='Seainthesky:BAAAKgAECgYIBwAAAA==.Seekingheart:BAAAKgAFFAQIBAAAAA==.',Sk='Skyinthesea:BAAAKgAECgYIBgAAAA==.',Su='Summers:BAAAKgAECggICAAAAA==.',Vo='Volatile:BAABKgAFFH8IAAIKAAgIegfhCgCbAQAKAAgIegfhCgCbAQAAAA==.',Ye='Yezi:BAACKgAFFH8KAAMLAAgInBrCDADKAQALAAYIvSHCDADKAQAMAAIIbw5AJQCQAAAqAAQKfxkAAwsACAhTFshEAJcBAAsACAhTFshEAJcBAAwACAivEnIrAHwBAAAA.',Yi='Yikecong:BAAAKgAFFAQIBAAAAA==.',['一条']='一条大香肠猎:BAABKgAFFH8GAAINAAYIKRKwEwBFAQANAAYIKRKwEwBFAQAAAA==.',['一枝']='一枝花丶:BAAAKgAECgQIBAAAAA==.',['七斤']='七斤半:BAAAKgADCggICAAAAA==.',['万毒']='万毒窟蚩梦:BAAAKgAECgQICAAAAA==.',['万种']='万种风情:BAABKgAECn8aAAIDAAgIFBu8EgA7AgADAAgIFBu8EgA7AgAAAA==.',['丨阿']='丨阿布灬:BAAAKgAECgYIBgAAAA==.',['丶简']='丶简兮:BAAAKgAECgYICQAAAA==.',['丶苍']='丶苍山负雪:BAAAKgAFFAQIAgAAAA==.',['丸子']='丸子老公:BAAAKgADCggIDAAAAA==.',['乌夜']='乌夜啼:BAABKgAFFH8IAAMIAAUI8STCDQCwAQAIAAUI8STCDQCwAQAJAAIIdBSUEQCYAAABKgAFFAgIBgADAHceAA==.',['五条']='五条五:BAABKgAFFH8YAAIDAAMIoxkESADeAAADAAMIoxkESADeAAAAAA==.',['传说']='传说中的自由:BAAAKgAECgcICwAAAA==.',['余年']='余年:BAABKgAFFH8KAAMLAAYIhhIsJAAIAQALAAUIkhUsJAAIAQAMAAUIShM8FQD3AAAAAA==.',['六巛']='六巛:BAAAKgAFFAQIBAAAAA==.',['凡人']='凡人:BAAAKgAECgUICAAAAA==.',['刑天']='刑天自由:BAAAKgADCgMIAwAAAA==.',['初初']='初初:BAAAKgAFFAQIBAAAAA==.',['动物']='动物园牛总:BAAAKgAFFAMIBAAAAA==.',['叁拳']='叁拳丶:BAAAKgAECggIEAAAAA==.',['吉尔']='吉尔伽美什神:BAACKgAFFH8WAAMOAAgIFyBXBAABAgAOAAgIrxBXBAABAgAPAAYIhSELCAAlAQAqAAQKfysAAg8ACAiyFYwqAN8BAA8ACAiyFYwqAN8BAAAA.',['呜哇']='呜哇噢:BAAAKgADCgYIBgAAAA==.',['周星']='周星驰爽歪歪:BAAAKgAECgYIDAAAAA==.',['咏恆']='咏恆卪简單:BAAAKgAECgMIAwAAAA==.',['咫尺']='咫尺的他:BAABKgAFFH8MAAMQAAYIYRLaCwBXAQAQAAYIYRLaCwBXAQARAAYIGQM2DgDRAAABKgAFFAgIEAAQAC0SAA==.',['哈狸']='哈狸:BAACKgAFFH8YAAQSAAQI6hlXHQDWAAASAAQI6hlXHQDWAAARAAMIuRKdDgDKAAAQAAEIPghENQAvAAAqAAQKfx4ABBIACAgYIHAPAE8CABIACAi8H3APAE8CABAACAjdFoIeANQBABEAAwguE0dMAL0AAAAA.',['哭泣']='哭泣的维纳斯:BAABKgAECn9DAAMTAAgIHRv9DwD9AQATAAgIHRv9DwD9AQADAAEIEg1cNgEwAAAAAA==.',['圣骑']='圣骑噬:BAAAKgAECgMIAwAAAA==.',['基拉']='基拉的怒火:BAABKgAECn8kAAIBAAgIcRkgKwDQAQABAAgIcRkgKwDQAQAAAA==.',['大姐']='大姐大真猛:BAAAKgAECgQIBAAAAA==.',['大师']='大师兄真坑:BAAAKgAECgIIAgAAAA==.',['天外']='天外飞仙一:BAAAKgAECgEIAQAAAA==.',['奥利']='奥利给给:BAAAKgAFFAQIBAAAAA==.',['奶蓟']='奶蓟草:BAABKgAFFH8IAAIUAAMIwBfkJgDbAAAUAAMIwBfkJgDbAAAAAA==.',['孤星']='孤星残月:BAAAKgAECgcICAAAAA==.',['学而']='学而时习之:BAABKgAFFH8IAAIUAAYIuQlLEAD9AAAUAAYIuQlLEAD9AAAAAA==.',['宓芙']='宓芙:BAABKgAFFH8FAAIUAAUIJAP4KQDPAAAUAAUIJAP4KQDPAAAAAA==.',['宝爷']='宝爷爷:BAABKgAFFH8IAAIVAAgI8gcBCAB2AQAVAAgI8gcBCAB2AQAAAA==.',['宴清']='宴清都:BAACKgAFFH8GAAIDAAYIdx54BAB8AQADAAYIdx54BAB8AQAqAAQKfy4AAgMACAjCJYkGAAMDAAMACAjCJYkGAAMDAAAA.',['寂静']='寂静的心:BAABKgAFFH8QAAMEAAYIyBJ8BACXAQAEAAYIVQ98BACXAQAHAAYIdBBFCQARAQAAAA==.',['小喵']='小喵警长:BAAAKgADCgIIAgAAAA==.',['小滚']='小滚滚:BAAAKgAECgUIBwAAAA==.',['小烨']='小烨烨:BAAAKgAECgYICwAAAA==.',['尾巴']='尾巴控:BAABKgAECn8VAAMLAAgI+xHUSgCCAQALAAgI+xHUSgCCAQAWAAEIbAsONgAeAAAAAA==.',['弯弯']='弯弯省一把手:BAAAKgAECgQIBAAAAA==.',['微笑']='微笑时好美:BAACKgAFFH8GAAIXAAYIQhcJCwCbAQAXAAYIQhcJCwCbAQAqAAQKfxoAAhcACAjXI2sHAJECABcACAjXI2sHAJECAAAA.',['心橙']='心橙自由:BAABKgAECn8YAAMNAAgIfBrsGgD6AQANAAgIfBrsGgD6AQAYAAIIWAmjBgEvAAAAAA==.',['悟空']='悟空:BAAAKgAECgUIBQAAAA==.',['我有']='我有神经冰:BAACKgAFFH8HAAIZAAMIkwnUHACdAAAZAAMIkwnUHACdAAAqAAQKfzwAAhkACAimHb4RADcCABkACAimHb4RADcCAAAA.',['抚丝']='抚丝足掌峰峦:BAABKgAECn8cAAMRAAgIngwVGQAdAQARAAgIngwVGQAdAQAQAAgIGQvtOgACAQAAAA==.',['拿得']='拿得起放得下:BAABKgAECn8iAAIIAAgIkhTUQAAIAQAIAAgIkhTUQAAIAQAAAA==.',['无限']='无限混:BAABKgAECn8ZAAILAAgIuh1GHwBPAgALAAgIuh1GHwBPAgAAAA==.',['星恒']='星恒残月:BAAAKgAECgEIAQAAAA==.',['暴走']='暴走小学生:BAACKgAFFH8KAAMaAAUIvRS3CAAjAQAaAAUIiBS3CAAjAQAbAAQI3wwtCACLAAAqAAQKfxgAAhoABgghJVocAPsBABoABgghJVocAPsBAAAA.',['术业']='术业有专攻:BAAAKgADCggICAAAAA==.',['枕香']='枕香肩尝朱唇:BAAAKgAECggICgAAAA==.',['林一']='林一:BAAAKgAECgMIAwAAAA==.',['林夏']='林夏:BAAAKgAECgEIAQAAAA==.',['桖銫']='桖銫坆瓌韓:BAAAKgAFFAQIBAAAAA==.',['梦泽']='梦泽:BAABKgAFFH8SAAIBAAgIlRt+BwAZAgABAAgIlRt+BwAZAgAAAA==.',['死灵']='死灵重现:BAABKgAFFH8HAAIZAAcI1A0LBACmAQAZAAcI1A0LBACmAQAAAA==.',['死魚']='死魚眼:BAAAKgADCgEIAQAAAA==.',['氼家']='氼家丶:BAAAKgAECgcIEQAAAA==.',['波哥']='波哥大闸蟹:BAAAKgAFFAYIBAAAAA==.',['派派']='派派丶:BAABKgAFFH8FAAIUAAUIPxJGGQAcAQAUAAUIPxJGGQAcAQAAAA==.',['流云']='流云残月:BAAAKgAECgQIBAAAAA==.',['流星']='流星残月:BAAAKgADCgIIAgAAAA==.',['温柔']='温柔枕边雨:BAABKgAFFH8MAAIFAAgIMyBCAQCRAgAFAAgIMyBCAQCRAgAAAA==.',['滚滚']='滚滚:BAACKgAFFH8GAAIUAAQIsxRnMQCzAAAUAAQIsxRnMQCzAAAqAAQKfzEAAhQACAjfI0kPAHQCABQACAjfI0kPAHQCAAAA.',['炸清']='炸清:BAABKgAFFH8IAAIDAAQIfSI6EwAJAQADAAQIfSI6EwAJAQAAAA==.',['爱丽']='爱丽丝灬冰冰:BAAAKgAECgEIAQAAAA==.',['牛十']='牛十一:BAAAKgAECgUIBQAAAA==.',['牧神']='牧神魔蝎:BAAAKgAECgQIBAAAAA==.',['狐狸']='狐狸大圣:BAAAKgADCggICAAAAA==.',['猛禽']='猛禽:BAAAKgADCgMIAwAAAA==.',['甜甜']='甜甜的糖:BAABKgAECn8yAAIcAAcIdxzTAgDHAQAcAAcIdxzTAgDHAQAAAA==.',['田里']='田里的雪:BAAAKgAECgcIDgAAAA==.',['瞧尔']='瞧尔萨斯:BAAAKgAFFAYIAgAAAA==.',['碎樰']='碎樰镜:BAAAKgAECgIIAgAAAA==.',['神棍']='神棍:BAABKgAFFH8IAAMUAAYINxC3EQBHAQAUAAYINxC3EQBHAQAdAAIIhQIwFwBaAAAAAA==.',['神秘']='神秘巨星:BAAAKgAECgEIAQAAAA==.',['神马']='神马都是浮云:BAAAKgAECgYIDAAAAA==.',['秦天']='秦天:BAAAKgAECgYIBgAAAA==.',['等待']='等待幸福:BAAAKgAECgQIBQAAAA==.',['米凯']='米凯尔:BAAAKgAECgIIAwAAAA==.',['纯爱']='纯爱小精灵:BAAAKgAFFAYIAQAAAA==.',['绮葛']='绮葛龙丶苳蔷:BAAAKgAECggIDAAAAA==.',['羊美']='羊美娜斯:BAACKgAFFH8jAAMJAAQIeBmvBQDnAAAJAAQIkBavBQDnAAAIAAMIeBl1KQDIAAAqAAQKfxYAAwkACAgyIA8LAL0BAAkABwimHA8LAL0BAAgABwgQIS05AIgBAAAA.',['美辛']='美辛:BAAAKgADCgIIAgAAAA==.',['艾斯']='艾斯菲亚:BAABKgAFFH8KAAMEAAgIbg5QCQDrAQAEAAgIbg5QCQDrAQAHAAIIJAN4DwBoAAAAAA==.',['艾秋']='艾秋:BAAAKgAECgUIDwAAAA==.',['落日']='落日残月:BAAAKgADCggICAAAAA==.',['蒹葭']='蒹葭苍仓:BAACKgAFFH8QAAMIAAYIKB3RCQATAQAIAAUImhXRCQATAQAeAAMI5BgcCgCtAAAqAAQKfyAABAkACAh8HA0GAA8CAAkACAiqGQ0GAA8CAAgACAisE9g8AHgBAB4ABwjsEBJIAMQAAAAA.',['虎眼']='虎眼流一清玄:BAAAKgAECgYIEAAAAA==.',['血之']='血之神牧:BAAAKgADCgUIBQAAAA==.',['血珊']='血珊瑚:BAABKgAECn8gAAIfAAcIuyJIHABKAgAfAAcIuyJIHABKAgAAAA==.',['血腥']='血腥罪人:BAAAKgAFFAQIAgAAAA==.',['行简']='行简丶:BAAAKgAECgYICQAAAA==.',['观硬']='观硬大师:BAAAKgAECgQIBAAAAA==.',['诚心']='诚心诚意:BAABKgAFFH8QAAIZAAQIIxkJCQDlAAAZAAQIIxkJCQDlAAAAAA==.',['贼神']='贼神之贼帅:BAAAKgAECggICAAAAA==.',['轩辕']='轩辕七哥:BAABKgAFFH8GAAIOAAYIcxFOCwBYAQAOAAYIcxFOCwBYAQAAAA==.轩辕之血:BAAAKgADCgQIBAAAAA==.',['还是']='还是不够黑:BAAAKgAECgIIAgAAAA==.',['逍遥']='逍遥蘑菇仙人:BAABKgAFFH8FAAIDAAMI0QxzMwCVAAADAAMI0QxzMwCVAAAAAA==.',['遮雨']='遮雨也遮月光:BAABKgAFFH8GAAIDAAMIKwyTLAC0AAADAAMIKwyTLAC0AAAAAA==.',['醉仙']='醉仙望月步:BAABKgAFFH8FAAIaAAUIcQ9/GQCeAAAaAAUIcQ9/GQCeAAABKgAFFAgIBQAGAL8NAA==.',['重启']='重启之一粒丹:BAAAKgAFFAIIAgAAAA==.重启之刺客龙:BAAAKgAFFAMIAwABKgAFFAMIGAADAKMZAA==.重启之增辉龙:BAABKgAFFH8PAAIKAAMI3BXBHADZAAAKAAMI3BXBHADZAAABKgAFFAMIGAADAKMZAA==.',['错觉']='错觉之僧:BAAAKgADCgcIBwAAAA==.错觉之牧:BAAAKgADCggICAAAAA==.',['阿尔']='阿尔托莉雅丶:BAAAKgAECgYIEwAAAA==.',['随意']='随意:BAAAKgADCgMIAwAAAA==.',['风声']='风声依旧:BAAAKgAFFAQIBAAAAA==.',['风留']='风留人物:BAACKgAFFH8bAAQDAAgIlROMOQAGAQADAAQI6RyMOQAGAQAGAAQIlwyKEwDeAAATAAEIng0MFQBBAAAqAAQKfy4AAwMACAiMI/sTALoCAAMACAiMI/sTALoCABMABAjTD8otAPIAAAAA.',['骏泽']='骏泽:BAAAKgAFFAMIAwAAAA==.',['鱼鱼']='鱼鱼碗里来:BAAAKgAFFAgIBAAAAA==.',['黑白']='黑白辉:BAAAKgAFFAQIBAAAAA==.',['龙十']='龙十二:BAAAKgADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end