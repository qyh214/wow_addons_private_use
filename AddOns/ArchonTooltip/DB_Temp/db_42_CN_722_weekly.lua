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
 local lookup = {'Mage-Arcane','Warrior-Fury','Warrior-Arms','Shaman-Elemental','Monk-Windwalker','Rogue-Assassination','DeathKnight-Unholy','DeathKnight-Blood','Hunter-BeastMastery','Warrior-Protection','Paladin-Retribution','Druid-Balance','Druid-Restoration','Druid-Guardian','Mage-Frost','Shaman-Restoration','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Hunter-Marksmanship','Priest-Holy','Unknown-Unknown','Mage-Fire','Priest-Discipline','Paladin-Holy','Monk-Mistweaver','Monk-Brewmaster','Paladin-Protection','Hunter-Survival','DeathKnight-Frost','DemonHunter-Havoc','Shaman-Enhancement','Priest-Shadow','Evoker-Devastation','Evoker-Preservation',}; local provider = {region='CN',realm='毁灭之锤',name='CN',type='weekly',zone=42,date='2025-08-08',data={Az='Azurophia:BAAAKgADCggICAAAAA==.',Ca='Casarchmage:BAABKgAFFH8IAAIBAAgIeAmkCwCdAQABAAgIeAmkCwCdAQAAAA==.Caskingg:BAAAKgAFFAEIAQAAAA==.Casnn:BAABKgAECn8rAAMCAAgImyCkDACiAgACAAgImyCkDACiAgADAAUIZxRONQAYAQAAAA==.',Dn='Dnshaman:BAABKgAECn8eAAIEAAcIaBWJKQCKAQAEAAcIaBWJKQCKAQAAAA==.',Ei='Eilmaris:BAAAKgAECgcIBQAAAA==.',Fa='Fancy:BAAAKgAECggICgABKgAFFAgIBwAFABoSAA==.',Fo='Fox:BAAAKgAECgYIBgAAAA==.',Gr='Grubbycn:BAABKgAFFH8IAAIGAAgIHxmPAgCRAgAGAAgIHxmPAgCRAgAAAA==.',Ig='Igotitfrom:BAABKgAFFH8MAAMHAAQIOSF+CAAmAQAHAAQIOSF+CAAmAQAIAAQIOAzUFACkAAABKgAFFAgIBgAHAB0dAA==.',In='Int:BAAAKgAECgYIEQAAAA==.Intpall:BAAAKgAECgEIAQAAAA==.',Ma='Maedaatsuko:BAAAKgADCgEIAQAAAA==.',Ne='Nettie:BAAAKgAECgMIBAAAAA==.',Or='Orlandobulu:BAABKgAFFH8JAAIJAAQIahGbGADOAAAJAAQIahGbGADOAAAAAA==.',Ou='Ourteam:BAAAKgAFFAQIBAAAAA==.',Ri='Richarbeauty:BAAAKgAFFAMIAwAAAA==.Richarcheng:BAACKgAFFH8MAAICAAYIeRKuCQCdAQACAAYIeRKuCQCdAQAqAAQKfxQABAMACAiRGd4ZALYBAAMABwjIGd4ZALYBAAIABQiUER8+ACUBAAoAAQg5B7NOABwAAAAA.Richarcheung:BAABKgAFFH8JAAILAAcIgh7nBgBaAgALAAcIgh7nBgBaAgAAAA==.Richarchueng:BAABKgAECn8YAAQMAAgIdBkANADaAQAMAAgIdBkANADaAQANAAcINRFCMQAuAQAOAAEI7wVWHAAhAAAAAA==.Richarjunior:BAACKgAFFH8GAAMPAAMIYw9ODADAAAAPAAMIYw9ODADAAAABAAEIAgMxSQArAAAqAAQKfxgAAg8ACAhuIZ4JAJkCAA8ACAhuIZ4JAJkCAAAA.Richarrich:BAAAKgAFFAMIAwAAAA==.Richarxt:BAABKgAECn8dAAIQAAgIRhcBPACFAQAQAAgIRhcBPACFAQAAAA==.Rino:BAAAKgADCgMIBQAAAA==.',Ro='Ronz:BAABKgAFFH8NAAQRAAYIHSX5DwCRAQARAAYIaSD5DwCRAQASAAMIaB36BgDxAAATAAEIAAA2IgAAAAAAAA==.Ronzs:BAAAKgAFFAYIBAAAAA==.',Sm='Smite:BAAAKgAECggICAAAAA==.',Ty='Tyrael:BAAAKgADCgEIAQAAAA==.',Uk='Ukys:BAAAKgADCgEIAQAAAA==.',Wh='Why:BAABKgAFFH8GAAIUAAYIJBEoDABGAQAUAAYIJBEoDABGAQAAAA==.',Ys='Yss:BAAAKgAFFAQIBAAAAA==.',['一二']='一二三木头人:BAAAKgAECgIIAgAAAA==.',['一叶']='一叶孤舟:BAAAKgAECggIDQAAAA==.',['一条']='一条咸鱼:BAABKgAFFH8JAAIVAAUIYRkgDwA8AQAVAAUIYRkgDwA8AQAAAA==.',['一秒']='一秒破:BAAAKgADCgEIBAAAAA==.',['七一']='七一夜:BAAAKgAECgQIBAAAAA==.',['七乂']='七乂夜:BAABKgAECn8WAAICAAgIBBsXCQAiAgACAAgIBBsXCQAiAgABKgAFFAgIAgAWAAAAAA==.',['三支']='三支香:BAAAKgAECgIIAgAAAA==.',['不能']='不能回头的风:BAABKgAFFH8KAAMJAAYIdBHmGwAjAQAJAAYIVw3mGwAjAQAUAAQIaxbBIwBSAAAAAA==.',['与歌']='与歌:BAABKgAFFH8IAAMXAAgIuxvxDwBHAQAXAAQIjRzxDwBHAQAPAAQIohqUFQDAAAAAAA==.',['与龙']='与龙共舞:BAAAKgAECgYIBgAAAA==.',['丶奥']='丶奥法烨烨:BAAAKgAFFAIIAgAAAA==.',['乄小']='乄小蔷薇乄:BAACKgAFFH8FAAILAAIIQh/HMQCoAAALAAIIQh/HMQCoAAAqAAQKfzIAAgsACAjXJBcLAO0CAAsACAjXJBcLAO0CAAAA.',['云无']='云无月:BAABKgAFFH8IAAMYAAQIMBOKDgDiAAAYAAQIMBOKDgDiAAAVAAQI0QMYEwCoAAAAAA==.',['京城']='京城蚀血者:BAAAKgAECgMIAwAAAA==.',['伽尔']='伽尔鲁什:BAAAKgAECggICAAAAA==.',['佑酱']='佑酱:BAAAKgAECgQIBAAAAA==.',['你的']='你的牛牛:BAABKgAFFH8NAAMQAAgIdg0UEABWAQAQAAcIjAkUEABWAQAEAAMIJAm1GQCtAAAAAA==.',['六老']='六老七:BAAAKgAECgUIAwAAAA==.',['冰魂']='冰魂殿下:BAAAKgAECggICAAAAA==.',['凶猛']='凶猛大狐狸:BAAAKgADCgIIAgAAAA==.',['凹正']='凹正凹:BAAAKgAECgIIAgAAAA==.',['剑来']='剑来:BAABKgAFFH8MAAMLAAgIYxRdEQDTAQALAAgIYxRdEQDTAQAZAAIIFgrNDwCCAAAAAA==.',['北帝']='北帝冰魂:BAAAKgADCgEIAQAAAA==.北帝暴脾气:BAABKgAFFH8XAAMDAAgIEho1AAAwAgADAAcIoRY1AAAwAgACAAgIRBmuAwBzAQAAAA==.北帝罗兰:BAABKgAFFH8GAAILAAYIfhJuJQBUAQALAAYIfhJuJQBUAQABKgAFFAgIDAAHAPURAA==.',['半岛']='半岛铁牛:BAAAKgAFFAIIAgABKgAFFAgIEQANAD4jAA==.',['卋峯']='卋峯骑士:BAAAKgADCggICAAAAA==.',['南门']='南门老萨满:BAAAKgAECgMIAwAAAA==.',['可乐']='可乐加冰:BAAAKgADCgMIAwAAAA==.',['可我']='可我是个新手:BAAAKgADCggICAAAAA==.',['可爱']='可爱的小怂怂:BAAAKgAFFAYIBAABKgAFFAgICAAUALMfAA==.可爱的小畅畅:BAABKgAFFH8MAAMaAAYIiROtIAChAAAaAAYIiROtIAChAAAbAAIIlQH9CABdAAABKgAFFAgICgAVAKgbAA==.',['后端']='后端爱护:BAAAKgAECgEIAQAAAA==.',['后羿']='后羿射曰:BAAAKgADCggICAAAAA==.',['吻兒']='吻兒:BAAAKgAFFAQIBAABKgAFFAgIBAAWAAAAAA==.',['咒咒']='咒咒:BAABKgAECn8lAAMJAAgI0RpgKQALAgAJAAgIbhpgKQALAgAUAAIInhf1egCJAAAAAA==.',['咸鱼']='咸鱼无妄:BAAAKgAECgIIAgAAAA==.咸鱼魔魔:BAAAKgAECgEIAQAAAA==.',['哈兰']='哈兰:BAAAKgADCgIIAgAAAA==.',['哔哩']='哔哩哔哩干杯:BAAAKgAFFAIIAgAAAA==.',['哦啊']='哦啊咦耶:BAAAKgAECggICAAAAA==.',['唾弃']='唾弃这一切:BAAAKgAECgcIBwAAAA==.唾弃这泯灭:BAAAKgADCggIEQAAAA==.',['啊闹']='啊闹之术:BAABKgAFFH8UAAMRAAQI6w1NMACtAAARAAQIbAxNMACtAAATAAEIFw/lFgBDAAAAAA==.',['啥都']='啥都可以:BAAAKgAECgcIDAAAAA==.',['嗜血']='嗜血小磊:BAAAKgADCgMIAwAAAA==.嗜血德噜依:BAAAKgADCggICgAAAA==.嗜血蓝天:BAACKgAFFH8MAAMCAAMIjgY7FgCwAAACAAMITAY7FgCwAAADAAMIlAT4DwCXAAAqAAQKfyIAAwIACAgLF9ofANMBAAIACAgLF9ofANMBAAMAAwjhBtNWAEwAAAAA.',['圣光']='圣光之耀:BAABKgAFFH8IAAILAAYITR0zHwBzAQALAAYITR0zHwBzAQAAAA==.',['圣灵']='圣灵武士灭魔:BAAAKgAECgMIAwAAAA==.',['夜澜']='夜澜星:BAAAKgAECggICAAAAA==.',['大内']='大内密探:BAAAKgAECggIDgAAAA==.',['大魔']='大魔王:BAAAKgADCggIBAAAAA==.',['天新']='天新老宝宝:BAAAKgAECggIDgAAAA==.',['奥术']='奥术残渣:BAAAKgAFFAgIAQAAAA==.',['奶爸']='奶爸也狂野:BAAAKgAECgMIBAAAAA==.',['妙蛙']='妙蛙种种子:BAAAKgAECgUICQAAAA==.',['妲己']='妲己爱你哟:BAAAKgADCgYIBgAAAA==.',['小咸']='小咸鱼的德:BAAAKgAECggICwAAAA==.',['小熊']='小熊:BAAAKgAECgUICgAAAA==.',['小猪']='小猪饲养员:BAAAKgAECgIIAQAAAA==.',['小萨']='小萨苗苗:BAAAKgAECgUIBgAAAA==.',['小飞']='小飞棍丶来咯:BAAAKgAECgQIBQAAAA==.',['布答']='布答:BAAAKgAFFAQIBAAAAA==.',['带我']='带我呼吸:BAAAKgADCggIDAAAAA==.',['待客']='待客如夫:BAABKgAFFH8KAAMcAAgIWRCBEQD1AAAcAAQIYhCBEQD1AAALAAQITRBPJgDYAAAAAA==.',['微笑']='微笑的迪神:BAAAKgADCgYIBgAAAA==.',['心碎']='心碎黑夜:BAAAKgAECgIIAgAAAA==.',['惩戒']='惩戒天堂:BAAAKgADCggIDgAAAA==.',['慣性']='慣性矩:BAABKgAFFH8GAAIFAAMIxQeiDwCiAAAFAAMIxQeiDwCiAAAAAA==.',['我就']='我就是牛插:BAACKgAFFH8fAAQJAAUIICKpEAAKAQAJAAUIICKpEAAKAQAUAAEIDASaKQA+AAAdAAEILA8aBQA9AAAqAAQKfyAAAwkACAgWHeM2ABoCAAkACAidG+M2ABoCABQAAggqDvR3AF8AAAAA.',['我有']='我有一个角丶:BAABKgAFFH8IAAIMAAgI6QMbEABpAQAMAAgI6QMbEABpAQAAAA==.',['我能']='我能打辅助吗:BAAAKgADCgEIAQAAAA==.',['战灵']='战灵儿:BAAAKgADCgQICwAAAA==.',['拉歌']='拉歌朗曰:BAAAKgAFFAMIAwAAAA==.',['携醉']='携醉枕酒:BAAAKgAFFAIIBAABKgAFFAYIBwAFAIMCAA==.',['摸摸']='摸摸我的大肌:BAAAKgAFFAYIAwABKgAFFAgICgALAK0lAA==.',['收割']='收割:BAABKgAECn8cAAMHAAgIwBxkJAArAgAHAAgIwBxkJAArAgAeAAIIMRzLMQBQAAAAAA==.',['救赎']='救赎之殇:BAAAKgAFFAgIBAAAAA==.',['星河']='星河六号:BAABKgAFFH8KAAMRAAYI1h6NDgClAQARAAYI1h6NDgClAQASAAQINRWcCwDXAAAAAA==.',['星骓']='星骓:BAAAKgAECgIIAgAAAA==.',['是一']='是一个萨满:BAAAKgADCgYIBgAAAA==.是一只母牛啊:BAAAKgAECggIDQAAAA==.',['暴躁']='暴躁的阿呆:BAABKgAFFH8QAAIXAAYIJia4AgDuAQAXAAYIJia4AgDuAQAAAA==.',['月光']='月光之力:BAABKgAFFH8GAAIMAAYIVBahAQDMAQAMAAYIVBahAQDMAQAAAA==.',['有点']='有点数:BAAAKgADCggIDAAAAA==.',['枪花']='枪花:BAAAKgADCgYIBgAAAA==.',['柳贯']='柳贯一:BAAAKgADCgIIAgAAAA==.',['梅叶']='梅叶彼德:BAAAKgAECgIIAgAAAA==.',['梦乂']='梦乂魇:BAAAKgAECgQIBAAAAA==.',['樱桃']='樱桃小完犊子:BAABKgAFFH8GAAILAAYILBq+GQCRAQALAAYILBq+GQCRAQAAAA==.',['橙时']='橙时:BAAAKgAECgMIAwAAAA==.',['正义']='正义的小锤子:BAAAKgAECgEIAQAAAA==.',['武生']='武生军少:BAAAKgADCgIIAgAAAA==.',['水星']='水星記:BAABKgAFFH8RAAMMAAgINxPDDADKAQAMAAYI+RnDDADKAQANAAgIPwyEBQCJAQAAAA==.',['永恆']='永恆德德:BAAAKgADCggICAABKgAFFAMIBgAQAH0UAA==.',['氺丶']='氺丶龙人:BAAAKgADCggICAAAAA==.',['没踪']='没踪玫瑰刀:BAAAKgAECgQIBAAAAA==.',['法利']='法利娜:BAAAKgAECgYIDAAAAA==.',['法生']='法生万物:BAABKgAFFH8GAAMQAAQIExUDIgCQAAAQAAQIExUDIgCQAAAEAAIIIBvhEgCOAAAAAA==.',['浅唱']='浅唱伤心过往:BAAAKgADCgIIAgAAAA==.',['浪漫']='浪漫的小说:BAABKgAFFH8IAAMUAAYIuhxAEwBIAQAUAAUIAhxAEwBIAQAJAAEImR/kVQBVAAAAAA==.',['烈烈']='烈烈:BAAAKgAECgEIAQAAAA==.',['爬墙']='爬墙头等红杏:BAAAKgAECgEIAQAAAA==.',['爱亦']='爱亦随风起:BAAAKgADCgEIAgAAAA==.',['爵爷']='爵爷:BAAAKgAFFAMIBAAAAA==.',['牛牛']='牛牛萌:BAAAKgADCgMIAwAAAA==.',['犬夜']='犬夜叉:BAAAKgAECgEIAQAAAA==.',['王大']='王大锤阿:BAAAKgAECgcIDwAAAA==.',['王糖']='王糖豆:BAAAKgAECgMIAwAAAA==.',['王阿']='王阿痴:BAABKgAFFH8IAAMQAAgI0gkbFgArAQAQAAQIBw8bFgArAQAEAAQI4RecCADqAAAAAA==.',['瑞查']='瑞查儿:BAACKgAFFH8GAAIJAAUIVwlZFwDVAAAJAAUIVwlZFwDVAAAqAAQKfxkAAwkACAgTIYgTAI4CAAkACAj6H4gTAI4CABQACAjgC5xTAAIBAAAA.',['疾风']='疾风掠影:BAABKgAFFH8PAAIaAAQIxxVpHgCvAAAaAAQIxxVpHgCvAAAAAA==.',['癡癡']='癡癡呆坐一檯:BAAAKgAECgYICwAAAA==.',['白毛']='白毛向天歌:BAAAKgAECgIIAgAAAA==.',['白银']='白银之手:BAAAKgAFFAIIAgAAAA==.',['眉宇']='眉宇间的神似:BAAAKgAECgEIAQAAAA==.',['真天']='真天命:BAAAKgAECgQIBAAAAA==.',['知道']='知道啦明天见:BAAAKgAECgEIAQAAAA==.',['石页']='石页:BAAAKgAECgEIAQAAAA==.',['神圣']='神圣大狐狸:BAAAKgADCgEIAQAAAA==.',['穿越']='穿越三界:BAAAKgAECgYIBgAAAA==.',['第五']='第五人格:BAAAKgADCggICAAAAA==.',['米虫']='米虫豆:BAAAKgAECgcIDwAAAA==.',['紫盒']='紫盒子:BAAAKgAECgUIBQAAAA==.',['紫露']='紫露凝香:BAABKgAFFH8IAAIfAAYIfx7EEgBlAQAfAAYIfx7EEgBlAQAAAA==.',['红豆']='红豆大福:BAAAKgAECggICAAAAA==.',['老公']='老公说我胖了:BAAAKgADCggIEwAAAA==.',['老斯']='老斯基:BAABKgAECn8fAAMLAAgI5Q3ZjgAvAQALAAgI5Q3ZjgAvAQAcAAEImwYFXgAVAAAAAA==.',['老母']='老母猪上房顶:BAAAKgAECgUICgAAAA==.',['花倾']='花倾城:BAAAKgADCgUIBgAAAA==.',['花枪']='花枪:BAABKgAECn8pAAMNAAgIHA+ZNAAcAQANAAgIHA+ZNAAcAQAMAAUIKgYMrgBnAAABKgAFFAgIDwAgAC4bAA==.',['荀彧']='荀彧:BAAAKgAECggICAAAAA==.',['莱因']='莱因哈特:BAABKgAFFH8MAAIHAAMIewG4SwByAAAHAAMIewG4SwByAAAAAA==.',['菜娃']='菜娃的玩具:BAAAKgADCggIDAAAAA==.',['萌萌']='萌萌的汤圆:BAAAKgAECgYIBwAAAA==.',['蛮萨']='蛮萨大狐狸:BAAAKgAECgEIAQAAAA==.',['蝶舞']='蝶舞梦回:BAAAKgAECgIIAgAAAA==.',['见血']='见血封喉:BAAAKgADCgMIAwAAAA==.',['见面']='见面曾相识:BAAAKgAFFAQIBAAAAA==.',['诸葛']='诸葛亮:BAABKgAFFH8GAAIPAAYI4RDpCAA0AQAPAAYI4RDpCAA0AQAAAA==.',['豆腐']='豆腐加辣:BAAAKgADCggICAAAAA==.',['賽先']='賽先僧:BAABKgAFFH8JAAMhAAQIwAi9EgCaAAAhAAMIwAi9EgCaAAAVAAEIAADBIgAAAAAAAA==.',['贝呗']='贝呗贝极星:BAAAKgAECgUIBQAAAA==.',['贝贝']='贝贝呗极星:BAACKgAFFH8JAAIFAAMIih6eBgASAQAFAAMIih6eBgASAQAqAAQKfygAAwUACAgPJFMHAMICAAUACAgPJFMHAMICABsAAgimH9IcAIwAAAAA.',['路过']='路过的大师:BAAAKgAFFAgIBAAAAA==.',['身体']='身体棒棒强:BAAAKgAFFAQIBAABKgAFFAgIAgAWAAAAAA==.',['达拉']='达拉崩巴国王:BAAAKgAECgUIBgAAAA==.',['迪蔻']='迪蔻:BAAAKgAECggIEgAAAA==.',['逍遥']='逍遥自得:BAAAKgAFFAIIAgABKgAFFAYIBwAFAIMCAA==.',['那一']='那一根神箭:BAAAKgAFFAIIAgABKgAFFAgIDwAgAC4bAA==.那一贱的疯情:BAABKgAFFH8GAAIIAAQITQzIJQCAAAAIAAQITQzIJQCAAAABKgAFFAgIDgAHAEoXAA==.',['释迦']='释迦:BAAAKgADCgIIAgAAAA==.',['重合']='重合成功:BAAAKgAFFAIIBAABKgAFFAYIBwAFAIMCAA==.',['鏡中']='鏡中故我:BAAAKgAECgYIBgAAAA==.',['闲云']='闲云野鸖:BAABKgAFFH8IAAILAAQIgiBfCwAoAQALAAQIgiBfCwAoAQAAAA==.',['阝湮']='阝湮灭:BAAAKgAECgEIAQAAAA==.',['阿傍']='阿傍罗刹龙:BAAAKgADCgMIBQAAAA==.',['阿巴']='阿巴丷:BAACKgAFFH8TAAQBAAgIkx0kAwCPAgABAAgIkx0kAwCPAgAPAAQI6BmCBwDyAAAXAAQIMQpHIwDJAAAqAAQKfxwAAg8ACAizGw0oANwBAA8ACAizGw0oANwBAAAA.',['随波']='随波逐流:BAAAKgAECgcIBwAAAA==.',['雪倾']='雪倾国:BAAAKgADCggIEAAAAA==.',['非主']='非主流大爷:BAAAKgAECgcICAAAAA==.',['香槟']='香槟拉菲:BAACKgAFFH8HAAMFAAIIgwJHIwBJAAAFAAIIgwJHIwBJAAAaAAEIDgEAAAAAAAAqAAQKfxUAAxoACAhvBHVqAJoAABoACAhvBHVqAJoAAAUABAhVChxUAG8AAAAA.',['骑手']='骑手战鹰:BAABKgAFFH8GAAILAAYIwBN0IABuAQALAAYIwBN0IABuAQAAAA==.',['鱼麦']='鱼麦:BAAAKgAECgQIBgAAAA==.',['鲜鲜']='鲜鲜:BAAAKgAECgYIBgAAAA==.',['龙咚']='龙咚呛:BAABKgAECn8YAAMiAAgIJAxSNAAeAQAiAAgIJAxSNAAeAQAjAAcIlgTHHACbAAABKgAFFAYIBwAFAIMCAA==.',['龙妈']='龙妈:BAAAKgADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end