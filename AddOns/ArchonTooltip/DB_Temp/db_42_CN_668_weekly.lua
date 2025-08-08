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
 local lookup = {'DemonHunter-Havoc','Priest-Holy','Mage-Arcane','DeathKnight-Frost','DeathKnight-Blood','DeathKnight-Unholy','Evoker-Devastation','Evoker-Augmentation','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Hunter-BeastMastery','Paladin-Retribution','Rogue-Assassination','Hunter-Marksmanship','Mage-Frost','Mage-Fire','Priest-Discipline','Druid-Restoration','Druid-Guardian','Warrior-Protection','Priest-Shadow','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Warrior-Fury','Shaman-Elemental','Shaman-Restoration','Shaman-Enhancement','DemonHunter-Vengeance','Warrior-Arms','Druid-Balance','Unknown-Unknown','Evoker-Preservation','Paladin-Holy','Rogue-Subtlety','Paladin-Protection',}; local provider = {region='CN',realm='布莱恩',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ap='Apt:BAAAKgAECgYICwAAAA==.',Ar='Arii:BAAAKgAECgIIAgAAAA==.',Aw='Awasubaru:BAAAKgAECgMIAwAAAA==.',Az='Azyfe:BAAAKgAECgcIBwAAAA==.',Ca='Caesar:BAAAKgAECggICAAAAA==.',De='Demonhunter:BAABKgAFFH8HAAIBAAQI4BmhDwACAQABAAQI4BmhDwACAQAAAA==.',Du='Ducati:BAAAKgAECggIDQAAAA==.',Ev='Evazore:BAAAKgAFFAEIAQAAAA==.',Fi='Fingerto:BAAAKgAECggIEwAAAA==.',Gi='Gifty:BAACKgAFFH8GAAICAAMI4goGLACUAAACAAMI4goGLACUAAAqAAQKfyQAAgIACAgoFY0lAKABAAIACAgoFY0lAKABAAAA.Givenchy:BAABKgAFFH8IAAIDAAgIFA44CAD7AQADAAgIFA44CAD7AQAAAA==.',Ha='Hardy:BAAAKgADCggIEAAAAA==.',Jc='Jchc:BAABKgAECn8kAAQEAAgInx4dCgASAgAEAAcIlB8dCgASAgAFAAcIrhXZGwBxAQAGAAQIOBfHhwDNAAAAAA==.',Ka='Kakamie:BAACKgAFFH9MAAMHAAgI2CCrAwCHAgAHAAgIxyCrAwCHAgAIAAIIbxYoAgCgAAAqAAQKfycAAgcACAhTIwANAG4CAAcACAhTIwANAG4CAAAA.Kakamis:BAACKgAFFH8GAAMJAAQIcgtlEgAWAQAJAAQIcgtlEgAWAQAKAAIIpwsBDwDAAAAqAAQKfxQABAsACAiLGJQPAEYBAAsACAg9E5QPAEYBAAoABAhMFlE+ABgBAAkAAgjGBs+AAFkAAAAA.',Li='Linabell:BAAAKgAECgUIBQAAAA==.',Lu='Luteinizing:BAAAKgAFFAQIBAAAAA==.',Mo='Monesy:BAAAKgAECgcIBwAAAA==.',Ms='Mstrzuo:BAAAKgAECgUIBQAAAA==.',Ni='Nitro:BAABKgAECn8UAAIMAAgIJyIKEAClAgAMAAgIJyIKEAClAgAAAA==.',Pg='Pg:BAAAKgAECggIDAABKgAFFAgIDgANAKsWAA==.',Po='Pororo:BAAAKgAFFAQIBAAAAA==.',Qa='Qaq:BAAAKgAECgMIAwAAAA==.',Sa='Samaelquiet:BAAAKgAECgYIBgAAAA==.',Su='Suemac:BAAAKgAECggIEwAAAA==.Suemia:BAAAKgADCgEIAQAAAA==.Suequte:BAAAKgADCgEIAQAAAA==.',Ta='Takumiouo:BAABKgAFFH8GAAIOAAYI0AumAgCbAQAOAAYI0AumAgCbAQAAAA==.',['Yò']='Yòvó:BAAAKgAECgEIAQAAAA==.',Zh='Zhan:BAAAKgAECgIIAgAAAA==.',['一只']='一只猎手猫:BAAAKgAECgMIAwAAAA==.一只老鸽子:BAAAKgAFFAIIAwAAAA==.',['一叶']='一叶随风:BAAAKgADCgcICgAAAA==.一叶飘零:BAAAKgAECgUIBQAAAA==.',['一梦']='一梦一瑾年:BAAAKgAECggICAABKgAFFAgIBgAGAB0dAA==.',['一路']='一路哀愁:BAAAKgAFFAIIAgAAAA==.',['一颗']='一颗油麦菜:BAAAKgAECgQIBAAAAA==.',['一骑']='一骑绝尘风:BAACKgAFFH8bAAMPAAgIshkGEgBTAQAPAAYIjBgGEgBTAQAMAAMIkhxlPgCkAAAqAAQKfz4AAw8ACAg5JmABAAYDAA8ACAg5JmABAAYDAAwAAQjUE3nCAD4AAAAA.',['三澄']='三澄美琴:BAABKgAECn8XAAIJAAgIqh7nDwBqAgAJAAgIqh7nDwBqAgAAAA==.',['下水']='下水道的光辉:BAACKgAFFH8IAAMQAAQI6AWcGQBoAAARAAQI6AXWIwCaAAAQAAMIKgOcGQBoAAAqAAQKfx0AAxEACAhVGfA0AMQBABEACAjKFfA0AMQBABAAAghTHo90AK0AAAAA.',['不会']='不会潜水的鱼:BAAAKgAFFAYIBAAAAA==.',['不喜']='不喜豚:BAAAKgAECgEIAQAAAA==.',['不死']='不死战神:BAAAKgAECgYIBgAAAA==.',['不能']='不能算了:BAAAKgAECgYIBgAAAA==.',['不许']='不许喂猫呀丶:BAABKgAECn8nAAMCAAgIGRieJwCwAQACAAcI3RaeJwCwAQASAAcIYxXNLAB3AQAAAA==.',['专吃']='专吃男大学生:BAAAKgAECgIIAgAAAA==.',['东风']='东风烈手:BAAAKgADCgUIBQAAAA==.',['丰茹']='丰茹丶肥臀:BAAAKgAECgIIAgAAAA==.',['丶黑']='丶黑玫瑰丶:BAABKgAECn8YAAMTAAgIIxpWJwCVAQATAAgIIxpWJwCVAQAUAAEIuAuwNQAfAAAAAA==.',['丷爱']='丷爱似水仙丷:BAABKgAECn8ZAAIBAAgIDSBOFQBWAgABAAgIDSBOFQBWAgAAAA==.',['为什']='为什么是蹄子:BAAAKgAECggIEwABKgAECggIGwAGAJ0gAA==.',['九天']='九天战神:BAABKgAECn8uAAIVAAgILhwCCgAjAgAVAAgILhwCCgAjAgAAAA==.',['了然']='了然:BAAAKgAECgQIBAAAAA==.',['云德']='云德:BAAAKgAECgQIBAAAAA==.',['云达']='云达:BAAAKgAECgIIAgAAAA==.',['井井']='井井丨:BAACKgAFFH8IAAMGAAMIRBPfEQDyAAAGAAMIRBPfEQDyAAAFAAIIfAq8HwBiAAAqAAQKfyIAAwYACAhdHm0zAOQBAAYABggFIm0zAOQBAAUACAg2DyIrADUBAAAA.',['他们']='他们叫小小呀:BAAAKgAECgUIBQAAAA==.',['以德']='以德服人啊:BAABKgAFFH8HAAIUAAQI1w4ZBQCJAAAUAAQI1w4ZBQCJAAAAAA==.',['以菜']='以菜为名:BAAAKgADCggIDgAAAA==.',['伊利']='伊利达尼:BAAAKgADCgQIBAAAAA==.',['借风']='借风吻你:BAAAKgADCgQIBAAAAA==.',['倾穹']='倾穹:BAACKgAFFH8TAAMSAAcINhnzCgBmAQASAAUICBzzCgBmAQAWAAQI8QVSFQB5AAAqAAQKfxcABBIACAjrIKAIAJUCABIACAjrIKAIAJUCABYAAgiVEHdcAH0AAAIAAgiMFRiDAFwAAAAA.',['傲世']='傲世灬神射手:BAAAKgAECgcICAAAAA==.',['傲特']='傲特慢:BAAAKgAECgcIBwAAAA==.',['光铸']='光铸小蹄子:BAAAKgAECgcIBwAAAA==.',['全能']='全能之手:BAAAKgAECgQIBAAAAA==.',['冰河']='冰河葬寒心:BAABKgAFFH8KAAMGAAMIkwjpJgCKAAAGAAMIkwjpJgCKAAAEAAEIsAmxEwA4AAAAAA==.',['冷色']='冷色:BAAAKgAECgEIAQAAAA==.',['凤舞']='凤舞九天:BAAAKgAFFAYIBAAAAA==.',['凯鲨']='凯鲨:BAABKgAECn8yAAQRAAgIWRmSKAAFAgARAAgIChmSKAAFAgADAAYI3xPRWwDSAAAQAAMI1A3xiQB6AAAAAA==.',['刘彪']='刘彪:BAAAKgADCgYIBgAAAA==.',['别打']='别打我别打我:BAAAKgAFFAgIAQABKgAFFAgIFgAHAIchAA==.',['别毛']='别毛我伤害:BAAAKgAFFAIIAgAAAA==.',['别逼']='别逼逼:BAAAKgAECgEIAQAAAA==.',['刺探']='刺探你的温柔:BAAAKgAECgIIAgAAAA==.',['剑箭']='剑箭丶:BAAAKgAECgQIBAAAAA==.',['剡溟']='剡溟:BAABKgAFFH8ZAAMJAAgI8x1IBQD9AQAJAAgI8x1IBQD9AQAKAAQIWgX7CwDPAAAAAA==.',['加尔']='加尔鲁什咆哮:BAAAKgADCgEIAQAAAA==.',['勇敢']='勇敢的火柴:BAABKgAFFH8NAAQXAAUIRRPPEACzAAAXAAQISBjPEACzAAAYAAQIBwnVOQCJAAAZAAEIOgTvFwBLAAAAAA==.',['十一']='十一丶:BAAAKgAECgIIAgAAAA==.十一棵刺槐树:BAAAKgAECgIIAgAAAA==.',['十年']='十年术木:BAACKgAFFH8EAAIXAAQI6iL7CQDmAAAXAAQI6iL7CQDmAAAqAAQKfy4ABBgACAjuIskTAE4CABgABwjvIskTAE4CABcABQihG1sdAAQBABkAAwjiIKxUAKgAAAAA.',['十的']='十的八次方:BAABKgAFFH8MAAMQAAYI7x52AgAtAQARAAYI0BW6BgCYAQAQAAQI/CN2AgAtAQAAAA==.',['卖的']='卖的一手好萌:BAAAKgADCggIFwAAAA==.',['卡农']='卡农伴奏:BAAAKgAFFAYIAgAAAA==.',['卫宫']='卫宫切嗣:BAAAKgAECggICAAAAA==.',['受死']='受死:BAAAKgAFFAEIAQAAAA==.',['古神']='古神蕾妮娅:BAAAKgAFFAgIBAAAAA==.',['只因']='只因你太美:BAAAKgAECgEIAQAAAA==.',['叶随']='叶随风:BAABKgAECn8eAAIMAAgIghyEIQA2AgAMAAgIghyEIQA2AgAAAA==.',['吉尔']='吉尔弗德:BAAAKgAECgcIBwAAAA==.',['听风']='听风不是雨啊:BAABKgAECn8UAAINAAgI4R1WZwDLAQANAAgI4R1WZwDLAQAAAA==.',['告白']='告白气球:BAAAKgADCgIIAQAAAA==.',['咖啡']='咖啡盐:BAACKgAFFH8jAAMVAAcIWho3AgDdAQAVAAcIWho3AgDdAQAaAAII7RUJHgBQAAAqAAQKfxkAAhUACAj6G5AMAPQBABUACAj6G5AMAPQBAAAA.',['咙逗']='咙逗逗:BAAAKgADCggICAAAAA==.',['哥屋']='哥屋恩滚:BAAAKgAFFAIIAwAAAA==.',['啊灭']='啊灭火啦:BAACKgAFFH8lAAQbAAgIYhbCBQCYAQAbAAYIURjCBQCYAQAcAAYI/iG6DgBmAQAdAAQI2BB/EADUAAAqAAQKfycABB0ACAjYHrchALgBAB0ABwg/GbchALgBABwABwjUGdU/AIcBABsABwgiHdw6ACQBAAAA.',['嗜睡']='嗜睡的小狐狸:BAAAKgAECgYIBgAAAA==.',['嘚嘚']='嘚嘚德:BAAAKgAFFAIIAwAAAA==.',['国宝']='国宝:BAAAKgADCgYIBgAAAA==.',['在吾']='在吾之下:BAAAKgAFFAEIAQAAAA==.',['墨兰']='墨兰亭:BAAAKgADCgQIBAAAAA==.',['复仇']='复仇:BAACKgAFFH8xAAQRAAgIqh73BQAOAgARAAcIzx33BQAOAgADAAcIIhjcDgB7AQAQAAEIhA11HwBAAAAqAAQKfz4AAxEACAh3JdcFAOQCABEACAh3JdcFAOQCAAMABAjBIz0aAMsAAAAA.',['夏洛']='夏洛忑煩惱:BAAAKgADCgQIBAAAAA==.',['多莉']='多莉的擁抱:BAACKgAFFH9XAAIeAAgISRZCAgD0AQAeAAgISRZCAgD0AQAqAAQKfyQAAh4ACAjcHpoNAEkCAB4ACAjcHpoNAEkCAAAA.',['夜莺']='夜莺:BAAAKgAECgQIBQAAAA==.',['大憨']='大憨牛:BAAAKgAECggICAAAAA==.',['大藏']='大藏里想奈:BAAAKgAECgYICQAAAA==.',['大迪']='大迪克:BAACKgAFFH8FAAIfAAQIOw8kEwDrAAAfAAQIOw8kEwDrAAAqAAQKfxgAAh8ACAhhFF0cANABAB8ACAhhFF0cANABAAAA.',['大雨']='大雨雨:BAABKgAFFH8OAAMgAAgI+w2hCgDqAQAgAAgI+w2hCgDqAQATAAYIHg6vDgArAQAAAA==.',['天海']='天海:BAAAKgAECgcIBwABKgAFFAYICgAGAJMIAA==.',['头上']='头上有犄角:BAAAKgADCgcIBwABKgAECggIGwAGAJ0gAA==.',['奶白']='奶白色雪子:BAAAKgAFFAYIBAAAAA==.',['她真']='她真的不一样:BAAAKgAECgYIBwAAAA==.',['如烟']='如烟丶:BAAAKgAECggIDgABKgAFFAYIBAAhAAAAAA==.',['姑娘']='姑娘你的绿箭:BAAAKgAECggICAAAAA==.',['嬛嬛']='嬛嬛:BAAAKgAFFAQIAgAAAA==.',['孤单']='孤单想起谁:BAAAKgADCgEIAQAAAA==.',['宇宙']='宇宙骑丶磊神:BAAAKgAFFAQIBAAAAA==.',['安之']='安之若素丶:BAAAKgAECggIDwAAAA==.',['安静']='安静:BAAAKgAECgQICQAAAA==.',['实名']='实名上网:BAAAKgAECgEIAQAAAA==.',['寒山']='寒山石径斜:BAAAKgADCgEIAQAAAA==.',['对影']='对影:BAAAKgAECggIEAAAAA==.',['将军']='将军夜引弓:BAAAKgAFFAYIAQAAAA==.',['小丑']='小丑龙:BAACKgAFFH8WAAMHAAgIhyHuAwB+AgAHAAgIhyHuAwB+AgAIAAEIAABuBQAAAAAqAAQKfzoAAwcACAidJcQDAOICAAcACAidJcQDAOICACIAAQhkA7IrACQAAAAA.',['小东']='小东西丶:BAABKgAFFH8IAAINAAMIKxxBQgDrAAANAAMIKxxBQgDrAAAAAA==.',['小小']='小小卉卉:BAABKgAFFH8MAAISAAYIBxq3AQC+AQASAAYIBxq3AQC+AQAAAA==.',['小德']='小德:BAAAKgAECgIIAgAAAA==.',['小狐']='小狐狸丶丶:BAAAKgAECggICQAAAA==.',['小笑']='小笑豆豆:BAAAKgAECgYIBgAAAA==.',['小能']='小能猫:BAAAKgAFFAEIAQAAAA==.',['小龙']='小龙人没翅膀:BAABKgAFFH8JAAIHAAYIfCBYCQDhAQAHAAYIfCBYCQDhAQAAAA==.',['峰哥']='峰哥亡命天涯:BAAAKgADCggIEAAAAA==.',['崭新']='崭新电脑桌:BAAAKgAECgUIAQAAAA==.',['左眼']='左眼跳桃花开:BAAAKgAECgQIBAAAAA==.',['带着']='带着圣光滚:BAAAKgADCgYIBgAAAA==.',['幽璃']='幽璃:BAABKgAFFH8PAAMBAAYITyPgAAAaAgABAAYITyPgAAAaAgAeAAIIpAZpJwAjAAAAAA==.',['异界']='异界萨满:BAAAKgAFFAYIAwAAAA==.',['张三']='张三疯:BAAAKgAECgQIBAAAAA==.',['彩虹']='彩虹之梦:BAABKgAFFH8KAAIFAAYI7BqFCQB9AQAFAAYI7BqFCQB9AQABKgAFFAgIBAAhAAAAAA==.',['影月']='影月丶弥生:BAAAKgAECggICgAAAA==.',['德伊']='德伊贝瑞:BAAAKgAECggIEQAAAA==.',['德妞']='德妞:BAAAKgAECgcIEQAAAA==.',['忽悠']='忽悠忽悠你:BAAAKgAECgYIBgAAAA==.忽悠忽悠谁:BAAAKgAECgIIAgAAAA==.',['怀大']='怀大:BAAAKgADCggIDQAAAA==.',['怒灿']='怒灿:BAACKgAFFH9SAAMVAAgIRyM5AQBWAgAVAAcIBSM5AQBWAgAfAAMICRg2EgCOAAAqAAQKfywAAx8ACAgRJZMPAEACAB8ACAhjIZMPAEACABUABAjUJSgSAJwBAAAA.',['我不']='我不会羊:BAAAKgAECgcIBwAAAA==.',['我们']='我们还行吧:BAAAKgADCgYIBgAAAA==.',['我在']='我在冰箱里面:BAAAKgADCgEIAQAAAA==.',['我是']='我是一个演员:BAABKgAECn8bAAMJAAYIuQpdQQDAAAAJAAYIuQpdQQDAAAAKAAUI3ga3VgBlAAAAAA==.',['我爱']='我爱奶茶:BAABKgAFFH8GAAIPAAYI3wxRDgB5AQAPAAYI3wxRDgB5AQAAAA==.',['我要']='我要回农村:BAABKgAFFH8IAAIBAAgI0AkNCwC4AQABAAgI0AkNCwC4AQAAAA==.',['我说']='我说的你不懂:BAAAKgAECgQIBAAAAA==.',['我都']='我都影遁了:BAABKgAECn8bAAMGAAgInSDKFgB4AgAGAAgInSDKFgB4AgAFAAIIuAv8WgBSAAAAAA==.',['战场']='战场原黒仪:BAACKgAFFH8ZAAMgAAUI5AuUKwDkAAAgAAUI5AuUKwDkAAATAAMIBBPzCwDQAAAqAAQKfx8ABCAACAhcFapbAE8BACAABAj7G6pbAE8BABMACAgiELE0AEgBABQABQjlD90bAMAAAAAA.',['戰魂']='戰魂丶小雄:BAAAKgAECgYIBgAAAA==.',['拐拐']='拐拐哩滴龙:BAAAKgADCggICAAAAA==.',['揷哥']='揷哥来了:BAABKgAECn8lAAMNAAgIohrfWADtAQANAAgIohrfWADtAQAjAAgITgnoMADbAAAAAA==.',['擎潮']='擎潮主:BAACKgAFFH8tAAMcAAgIZR7QAQCDAgAcAAgIZR7QAQCDAgAbAAMIIQeNEACbAAAqAAQKfyQAAhwACAitJLcJAKgCABwACAitJLcJAKgCAAAA.',['敌进']='敌进我退:BAAAKgADCgQIBAAAAA==.',['教练']='教练:BAAAKgAECgcIDAAAAA==.',['散夜']='散夜花影:BAAAKgAFFAIIAgABKgAFFAgIJQAbAGIWAA==.',['斩雷']='斩雷:BAABKgAFFH8NAAIcAAYIoSL0BQDyAQAcAAYIoSL0BQDyAQAAAA==.',['斯可']='斯可拉:BAAAKgAECgEIAQAAAA==.',['方彤']='方彤彤:BAABKgAFFH8GAAICAAQIVggyEQC4AAACAAQIVggyEQC4AAAAAA==.',['无玄']='无玄:BAACKgAFFH8xAAIGAAgIWR5RBQBNAgAGAAgIWR5RBQBNAgAqAAQKfzYAAgYACAg/JYcEAPcCAAYACAg/JYcEAPcCAAAA.',['时间']='时间紧任务重:BAABKgAFFH8IAAIBAAUIDRUlDQB/AQABAAUIDRUlDQB/AQAAAA==.',['时雨']='时雨:BAAAKgADCggIDAAAAA==.',['旺旺']='旺旺大雪饼:BAAAKgAECgEIAQAAAA==.',['星空']='星空凛:BAAAKgAECgIIAgAAAA==.',['是眼']='是眼子啊:BAABKgAFFH8IAAITAAgIdQmdBQCEAQATAAgIdQmdBQCEAQAAAA==.',['暗月']='暗月苍狼:BAABKgAECn80AAIGAAgIJyCFEQB+AgAGAAgIJyCFEQB+AgAAAA==.',['暴风']='暴风哈尔:BAABKgAFFH8GAAMMAAYIRwrXHAC0AAAMAAQIRwvXHAC0AAAPAAIIyAhJPACHAAAAAA==.暴风星辰:BAAAKgAFFAQIBAAAAA==.',['曦风']='曦风月:BAAAKgAFFAMIAwAAAA==.',['月罄']='月罄霊语:BAABKgAFFH8LAAMbAAYIGCB4BQClAQAbAAYIGCB4BQClAQAcAAUIHhBvEgDaAAABKgAFFAgIEAAcACIVAA==.',['有事']='有事稳李锐:BAAAKgAFFAUIBAAAAA==.',['有什']='有什么好想的:BAAAKgAFFAEIAgAAAA==.',['木依']='木依:BAACKgAFFH8cAAQYAAgI7hjFCQDvAQAYAAcIoxjFCQDvAQAZAAIIYBlXGACKAAAXAAEI6hIiGwBOAAAqAAQKfyoABBgACAgQIMEfAAYCABgACAjVGcEfAAYCABkABQjeGgArAEABABcAAgh2Ha8sAKAAAAAA.',['木公']='木公子:BAAAKgADCgMIAwAAAA==.',['木宁']='木宁馨:BAACKgAFFH8xAAIFAAgIth2xAgBWAgAFAAgIth2xAgBWAgAqAAQKfykAAwUACAgcH8ANAFICAAUACAgcH8ANAFICAAQAAQg4GjszAEcAAAAA.',['杨桃']='杨桃子:BAACKgAFFH8KAAIcAAQIVhe/FQDGAAAcAAQIVhe/FQDGAAAqAAQKfyEAAhwACAg1H5oSAFsCABwACAg1H5oSAFsCAAAA.',['果冻']='果冻先生:BAAAKgAFFAgIAgAAAA==.',['枫之']='枫之林晚:BAAAKgADCgUIBQAAAA==.',['根本']='根本扛不住:BAAAKgAECgQIBAAAAA==.',['梁龙']='梁龙:BAAAKgAECggICAAAAA==.',['椒盐']='椒盐小龙虾:BAABKgAFFH8GAAISAAYISRqsAQC/AQASAAYISRqsAQC/AQAAAA==.',['橙橙']='橙橙爱果子:BAAAKgADCgEIAQAAAA==.',['欧皇']='欧皇敏敏:BAAAKgAECggIEgAAAA==.欧皇敏爷:BAABKgAFFH8IAAIaAAgI6BmCBQAjAgAaAAgI6BmCBQAjAgAAAA==.',['武汉']='武汉特色小吃:BAACKgAFFH8/AAIgAAgIQiGABACHAgAgAAgIQiGABACHAgAqAAQKfxUAAiAACAiOIf0oAB0CACAACAiOIf0oAB0CAAAA.',['殇黑']='殇黑尘:BAAAKgAECgQIBAAAAA==.',['沙特']='沙特尔:BAAAKgAECgIIAgAAAA==.',['法爷']='法爷冲击:BAABKgAFFH8JAAMQAAgIsxfoAQAOAgAQAAgIPhboAQAOAgADAAEI0Qs/QgBKAAAAAA==.',['泰达']='泰达希尔:BAAAKgAECggICAAAAA==.',['津渡']='津渡月:BAAAKgADCgYIBgAAAA==.',['活杀']='活杀乱雪月花:BAAAKgADCgUIBQABKgAECggIGwAGAJ0gAA==.',['海棠']='海棠血泪:BAAAKgADCggICAAAAA==.',['涼舟']='涼舟:BAAAKgADCggICAAAAA==.',['淺墨']='淺墨未央:BAACKgAFFH9VAAMOAAgIlQkvCADmAQAOAAgIlQkvCADmAQAkAAEITgDdEwAnAAAqAAQKfycAAw4ACAgIE+YZALgBAA4ACAgIE+YZALgBACQABggjAT4xAGsAAAAA.',['清补']='清补凉:BAAAKgAECgYICQAAAA==.',['温蕾']='温蕾萨:BAABKgAFFH8LAAQKAAUI/hBHEQDZAAAKAAQIkRZHEQDZAAAJAAEIFQEBGgAjAAALAAEIHwB0DQAHAAAAAA==.',['滚界']='滚界高僧:BAAAKgAECggICAAAAA==.',['漫漫']='漫漫罗:BAAAKgAECgQIBQAAAA==.',['炼狱']='炼狱修罗斩:BAABKgAFFH8IAAIBAAgIZQ2QCwDOAQABAAgIZQ2QCwDOAQAAAA==.',['炽热']='炽热暴徒:BAAAKgADCggIDQAAAA==.',['烂榜']='烂榜样:BAAAKgAECggIDgABKgAFFAgIGgAGAEwhAA==.',['烈海']='烈海王:BAACKgAFFH9hAAIKAAgIqCMfAQDIAgAKAAgIqCMfAQDIAgAqAAQKf0AAAgoACAi8JPkGAMYCAAoACAi8JPkGAMYCAAAA.',['热不']='热不同:BAABKgAECn8YAAIcAAgIoRtiKQDZAQAcAAgIoRtiKQDZAQAAAA==.',['熊熊']='熊熊不怕疼:BAACKgAFFH9IAAIlAAgInAVnEgDqAAAlAAgInAVnEgDqAAAqAAQKfx4AAyUACAhGCxMpAAsBACUACAhGCxMpAAsBAA0AAwjpAZ6OARwAAAAA.熊熊戈壁:BAAAKgAFFAEIAQAAAA==.',['燃烧']='燃烧的柚子皮:BAAAKgAECgQIBAAAAA==.',['牛一']='牛一扭:BAAAKgADCggICAAAAA==.',['狂热']='狂热心潮:BAAAKgAECggIDgAAAA==.',['狩魔']='狩魔人杰洛特:BAABKgAFFH8OAAINAAgIJx2eBgBfAgANAAgIJx2eBgBfAgAAAA==.',['独鹿']='独鹿:BAACKgAFFH8dAAIfAAYI/ROKDQA4AQAfAAYI/ROKDQA4AQAqAAQKfysABB8ACAgQHm0LAGwCAB8ACAgQHm0LAGwCABUABAi9Db4vAJEAABoAAghLDjqRADYAAAAA.',['猎炎']='猎炎:BAAAKgAECgQIBgAAAA==.',['猫跳']='猫跳:BAAAKgADCgQIBAAAAA==.',['獠獠']='獠獠粗:BAAAKgAECgUIBwAAAA==.',['玛咔']='玛咔咔酱:BAAAKgAECggIDAAAAA==.',['玩具']='玩具枪丶:BAEBKgAECn8nAAIbAAgIYRjJIADpAQAbAAgIYRjJIADpAQABKgAFFAgIBgAdAK4TAA==.',['玩原']='玩原神玩的:BAAAKgAECgcICAAAAA==.',['琥珀']='琥珀封印:BAAAKgAECgMIAwAAAA==.',['瑟提']='瑟提:BAAAKgADCgEIAQAAAA==.',['男神']='男神你雨果:BAAAKgADCggICAAAAA==.',['疯狂']='疯狂喀秋莎:BAAAKgAFFAYIAgAAAA==.',['白馒']='白馒头:BAAAKgAFFAIIBAAAAA==.',['盖伦']='盖伦出轻语:BAAAKgAECgMIAwAAAA==.',['省油']='省油的灯:BAABKgAFFH8GAAISAAYIiQ0rAwB6AQASAAYIiQ0rAwB6AQABKgAFFAgIEwACAP0gAA==.',['真红']='真红:BAAAKgADCgIIAgAAAA==.',['真页']='真页孑亥:BAABKgAFFH8GAAMjAAYInQrlDQDUAAAjAAUIGwTlDQDUAAANAAEIfRjUhABTAAAAAA==.',['神罚']='神罚:BAAAKgAECgYIDgAAAA==.',['禍祸']='禍祸灬老爺们:BAAAKgAECgYIBwAAAA==.',['空帽']='空帽子:BAAAKgAECggICAAAAA==.',['笑里']='笑里有雨滴:BAABKgAECn8bAAIHAAgIXiLWCgCHAgAHAAgIXiLWCgCHAgAAAA==.',['索林']='索林丶橡木盾:BAAAKgAECgUIBAAAAA==.',['绘梨']='绘梨依:BAABKgAECn8UAAQRAAgIkhj6NwC1AQARAAgIlhD6NwC1AQAQAAYIvBjKLwBHAQADAAMIAhcceAB7AAAAAA==.',['给小']='给小熊梳毛:BAAAKgAECgMIAwAAAA==.',['绯樱']='绯樱闲:BAABKgAECn8pAAMZAAgINB0NHgCQAQAZAAgILB0NHgCQAQAYAAcIHxjYRQBSAQAAAA==.',['维尔']='维尔薇:BAAAKgAECgIIAgAAAA==.',['美神']='美神令子:BAABKgAECn8kAAMNAAgIxhsWFAAtAgANAAcIxhsWFAAtAgAjAAcI2RcUGQCcAQAAAA==.',['翻滚']='翻滚灬遇上猪:BAAAKgAECgUIBQAAAA==.',['老灯']='老灯:BAAAKgAFFAYIAgAAAA==.',['脆脆']='脆脆角:BAABKgAECn8UAAIKAAgITCGVDgB0AgAKAAgITCGVDgB0AgABKgAFFAgIFgAHAIchAA==.',['脎鸸']='脎鸸:BAAAKgADCggICAAAAA==.',['自然']='自然之灵:BAABKgAFFH8GAAIMAAYIUxCLFQBKAQAMAAYIUxCLFQBKAQAAAA==.',['臭皮']='臭皮德:BAAAKgAECgQIBAAAAA==.',['舍身']='舍身入魔:BAAAKgADCggIDQAAAA==.',['艾尔']='艾尔利亚:BAAAKgAFFAQIAgABKgAFFAgIMwAOAOQgAA==.艾尔莉蕥:BAAAKgAFFAYIAgAAAA==.艾尔隆德月影:BAAAKgAECgcIEAAAAA==.',['苍天']='苍天:BAAAKgAECggICAAAAA==.',['若雪']='若雪丶:BAAAKgAECgYIBgAAAA==.',['草莓']='草莓布丁糖:BAAAKgADCgIIAgAAAA==.',['莫莉']='莫莉:BAAAKgAECgYIBgAAAA==.',['萤火']='萤火虫之森:BAABKgAECn8XAAMSAAgISw3EQAATAQASAAcIhA7EQAATAQACAAQISAildQBSAAAAAA==.',['萧瑟']='萧瑟:BAAAKgADCggICAAAAA==.',['落英']='落英:BAABKgAECn8WAAIQAAcIaw6QNwAbAQAQAAcIaw6QNwAbAQAAAA==.',['蓅輦']='蓅輦丶:BAABKgAFFH8TAAIBAAMIpRNfGgDcAAABAAMIpRNfGgDcAAABKgAFFAYILAAGAN8cAA==.',['虎面']='虎面笑:BAAAKgAECgUIBwAAAA==.',['虚雤']='虚雤薺:BAAAKgAFFAgIAgAAAA==.',['蛋蛋']='蛋蛋的大哥:BAAAKgAECggICAAAAA==.',['西宫']='西宫结弦:BAAAKgAFFAgIBAAAAA==.',['许仲']='许仲康:BAAAKgAECgEIAQAAAA==.',['贝尓']='贝尓基德:BAAAKgAECgEIAQAAAA==.',['贼娃']='贼娃子:BAAAKgAECgYIBgAAAA==.',['赛纳']='赛纳留斯:BAAAKgADCgIIAgAAAA==.',['轻舞']='轻舞:BAAAKgADCgIIAgAAAA==.',['辛月']='辛月舞:BAAAKgAFFAIIAgAAAA==.',['辣个']='辣个帅锅:BAABKgAFFH8PAAIgAAYIlCD0CgDbAQAgAAYIlCD0CgDbAQAAAA==.',['达到']='达到燃放:BAAAKgAECgUIBQAAAA==.',['这个']='这个恐惧奈斯:BAABKgAFFH8OAAQYAAYIoyFTDwCaAQAYAAYI+iBTDwCaAQAZAAEI9yUvHgBqAAAXAAEInBLNIgBCAAAAAA==.',['远浪']='远浪:BAAAKgAECgEIAgAAAA==.',['迷糊']='迷糊熊猫:BAABKgAECn8cAAMJAAgIHgZaQQDAAAAJAAgIHgZaQQDAAAAKAAQISwYdUwB0AAAAAA==.',['迷麟']='迷麟:BAABKgAECn8WAAINAAgIjRtyRwAaAgANAAgIjRtyRwAaAgAAAA==.',['追猎']='追猎者蕾娜:BAAAKgAECgcIBwAAAA==.',['邪恶']='邪恶征伐者:BAAAKgAFFAgIBAAAAA==.',['醉枪']='醉枪:BAACKgAFFH8wAAMPAAYI8R08CgCyAQAPAAYI8R08CgCyAQAMAAEIzwjKSwBAAAAqAAQKfyQAAg8ACAg3JZgHAK8CAA8ACAg3JZgHAK8CAAAA.',['锅盔']='锅盔夹凉粉:BAABKgAECn9EAAMjAAgInRqQEwDYAQAjAAgInRqQEwDYAQANAAYIlhk4nABfAQAAAA==.',['闹闹']='闹闹桑:BAABKgAECn9FAAIcAAgI5hkFJgDpAQAcAAgI5hkFJgDpAQAAAA==.',['阎魔']='阎魔:BAAAKgADCggICAAAAA==.',['阿伟']='阿伟:BAACKgAFFH8qAAMDAAgIYRqtDACbAQADAAcIexOtDACbAQARAAUINx1tEABBAQAqAAQKfzMABBEACAiEIRkMALMCABEACAiEIRkMALMCAAMAAghtH0tmAK8AABAAAQhwB8G0ACUAAAAA.',['阿兰']='阿兰娜逐星:BAAAKgAECgYIDgABKgAFFAgIMQAFALYdAA==.',['阿拉']='阿拉坦胡雅克:BAAAKgAECgYIBgAAAA==.',['阿次']='阿次:BAAAKgAFFAQIBAAAAA==.',['阿熊']='阿熊:BAABKgAFFH8IAAIOAAQIDhXdCgDvAAAOAAQIDhXdCgDvAAAAAA==.',['阿緋']='阿緋:BAAAKgAECgYICAAAAA==.',['阿菲']='阿菲:BAABKgAECn8UAAINAAgIexs3WwCsAQANAAgIexs3WwCsAQAAAA==.',['随身']='随身带棍:BAAAKgADCgUIBQAAAA==.',['隔叶']='隔叶听风:BAAAKgADCgYIBgAAAA==.',['雅典']='雅典娜娜:BAAAKgADCgEIAQAAAA==.',['雨夜']='雨夜听荷:BAAAKgAECgYICQAAAA==.',['雷家']='雷家大公主:BAABKgAFFH8KAAIcAAYI/RI8EABUAQAcAAYI/RI8EABUAQAAAA==.雷家小公主:BAAAKgAFFAYIBAAAAA==.',['青春']='青春丶喂了狗:BAAAKgAECgIIAgAAAA==.',['风中']='风中的传说:BAABKgAECn81AAMMAAcIYhAlgAA1AQAMAAcIYhAlgAA1AQAPAAIIbAc7ngBAAAAAAA==.',['风剪']='风剪云:BAAAKgAFFAgIAgAAAA==.',['风影']='风影轻舞:BAAAKgAECgEIAQAAAA==.',['风灵']='风灵:BAAAKgADCggICAAAAA==.',['风起']='风起云涌:BAAAKgAECgUIBQAAAA==.',['飞马']='飞马梦想:BAAAKgAECgEIAQAAAA==.飞马的种子袋:BAAAKgADCgQIBAAAAA==.',['馨魔']='馨魔:BAAAKgAFFAIIAgAAAA==.',['鬼见']='鬼见愁:BAAAKgAECggICQAAAA==.',['魑魅']='魑魅丶魍魉:BAACKgAFFH8sAAMGAAYI3xwRDgC0AQAGAAYI3xwRDgC0AQAFAAEIkALJJwAmAAAqAAQKf0AAAgYACAhgI6UKALoCAAYACAhgI6UKALoCAAAA.',['黑白']='黑白丶:BAABKgAFFH8MAAINAAcIfRlbDAAGAgANAAcIfRlbDAAGAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end