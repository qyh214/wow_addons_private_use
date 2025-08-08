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
 local lookup = {'Hunter-BeastMastery','Druid-Balance','Paladin-Protection','Priest-Holy','Druid-Restoration','DemonHunter-Vengeance','DemonHunter-Havoc','DeathKnight-Unholy','DeathKnight-Blood','DeathKnight-Frost','Mage-Frost','Warrior-Fury','Warrior-Arms','Shaman-Enhancement','Shaman-Restoration','Priest-Shadow','Druid-Feral','Unknown-Unknown','Hunter-Marksmanship','Monk-Mistweaver','Paladin-Retribution','Druid-Guardian','Priest-Discipline','Mage-Fire','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','Mage-Arcane',}; local provider = {region='CN',realm='迪瑟洛克',name='CN',type='weekly',zone=42,date='2025-08-02',data={Ly='Lyn:BAAAKgAECgYIDQAAAA==.',Ni='Niko:BAAAKgAFFAQIBAAAAA==.',Ro='Roberto:BAAAKgAECgcIBwAAAA==.',['一叶']='一叶乄知秋:BAAAKgAECgIIAgAAAA==.',['丑得']='丑得祸国殃民:BAAAKgADCgEIAQAAAA==.',['丨丨']='丨丨丶素質灬:BAAAKgADCggICAAAAA==.',['丨屁']='丨屁屁苹果丨:BAAAKgAECgQIBAAAAA==.',['丨栗']='丨栗子丨:BAABKgAFFH8GAAIBAAYIMgn6GQAvAQABAAYIMgn6GQAvAQAAAA==.',['为时']='为时已晚:BAAAKgAFFAMIAwAAAA==.',['乔巴']='乔巴船长:BAABKgAFFH8KAAICAAYILwu+GwA8AQACAAYILwu+GwA8AQAAAA==.',['云朵']='云朵朵:BAAAKgAECgMIBAAAAA==.',['以灬']='以灬沫:BAAAKgAECgEIAQAAAA==.',['伊泽']='伊泽:BAABKgAFFH8IAAIDAAgIRg8HCQBzAQADAAgIRg8HCQBzAQAAAA==.',['你过']='你过来啊:BAAAKgAECggIDAAAAA==.',['储备']='储备粮:BAAAKgAECgYIBgAAAA==.',['元宝']='元宝金小:BAAAKgADCgYIBgAAAA==.',['六欲']='六欲魔君:BAAAKgADCgUIBQAAAA==.',['冬末']='冬末雪霁:BAABKgAECn8WAAIEAAgIvRdrIgC0AQAEAAgIvRdrIgC0AQABKgAFFAgIUAAFACwgAA==.',['凭本']='凭本事挨骂:BAAAKgAFFAIIAgAAAA==.凭本事跳怪:BAACKgAFFH8vAAMGAAgIvBfWAgDFAQAGAAgI8xTWAgDFAQAHAAUI+xPVEwBaAQAqAAQKfxYAAwYABAgIIgAfAIEBAAYABAgIIgAfAIEBAAcAAQjHGbixAEsAAAAA.',['出月']='出月清风:BAACKgAFFH8vAAIHAAcI7RE4DgCfAQAHAAcI7RE4DgCfAQAqAAQKfyUAAwcACAhnHr4dAFICAAcACAhnHr4dAFICAAYAAQghBMZyACAAAAAA.',['午夜']='午夜屠姬:BAABKgAFFH8IAAMIAAYIMgkVDwADAQAIAAUIVgkVDwADAQAJAAEIpQimFAAnAAAAAA==.',['卡尔']='卡尔丶:BAAAKgAFFAQIBAAAAA==.',['变啊']='变啊变:BAAAKgAECgYIBgAAAA==.',['叫我']='叫我叠底:BAABKgAFFH8FAAIKAAMIAwKeDwBaAAAKAAMIAwKeDwBaAAAAAA==.叫我嘛嘛:BAAAKgAECggIEAAAAA==.',['吉祥']='吉祥如意丶:BAABKgAFFH8IAAILAAgIXhJuAgAUAgALAAgIXhJuAgAUAgAAAA==.',['向剑']='向剑底斩桃花:BAAAKgAFFAIIAgAAAA==.',['吮指']='吮指原味鸡:BAABKgAFFH8IAAMJAAgIkhJuEQAXAQAJAAYIxw5uEQAXAQAIAAIIDhy2PgCjAAAAAA==.',['吮汁']='吮汁原味鸡:BAABKgAFFH8GAAIJAAYI3A15FAD+AAAJAAYI3A15FAD+AAAAAA==.',['周扒']='周扒皮:BAAAKgADCggICAAAAA==.',['哈哩']='哈哩路呀:BAAAKgAFFAQIBAAAAA==.',['唐伯']='唐伯虎点蜡烛:BAAAKgAECgYIEAAAAA==.',['嘞嘞']='嘞嘞呀:BAABKgAFFH8iAAILAAQI0B2wDQD4AAALAAQI0B2wDQD4AAAAAA==.',['圈圈']='圈圈蛋蛋:BAABKgAECn8XAAIMAAgIwgvUGAAwAQAMAAgIwgvUGAAwAQAAAA==.',['塔哚']='塔哚哩亚:BAAAKgADCgEIAQAAAA==.',['墨小']='墨小墨:BAABKgAFFH8FAAMMAAUIMg7NJgCyAAAMAAQIegnNJgCyAAANAAEIWhwzKABPAAAAAA==.',['大和']='大和田南那:BAAAKgADCgIIAgAAAA==.',['大板']='大板牙:BAAAKgAECgIIAgAAAA==.',['天堂']='天堂在我身后:BAAAKgAECgEIAQAAAA==.',['天樄']='天樄:BAABKgAFFH8NAAMOAAUI2BdOAwB0AQAOAAUI2BdOAwB0AQAPAAQIvgNsPwCLAAAAAA==.',['天驱']='天驱若若:BAACKgAFFH8fAAMEAAQIySJxBwD9AAAEAAQIySJxBwD9AAAQAAEIigitJgBGAAAqAAQKfxgAAxAACAiYFlQgANIBABAACAiYFlQgANIBAAQABwjXHmwmALcBAAAA.',['头皮']='头皮发麻:BAAAKgAECgEIAQAAAA==.',['奇葩']='奇葩猫:BAABKgAFFH8iAAIRAAcIzxkHAQAdAgARAAcIzxkHAQAdAgAAAA==.',['奥蕾']='奥蕾莉亞丶:BAAAKgAFFAgIBAAAAA==.',['她说']='她说是晒黑的:BAAAKgAECggIEAABKgAFFAgIBAASAAAAAA==.',['姬亭']='姬亭:BAACKgAFFH8oAAMBAAgIoyCuDQCWAQABAAYIOx+uDQCWAQATAAYIYiGjEQBXAQAqAAQKfzcAAxMACAiuJLAKAIwCABMACAiuJLAKAIwCAAEACAiyGv1JANYBAAAA.',['安东']='安东尼的兔子:BAABKgAFFH8FAAIHAAUICxREIAACAQAHAAUICxREIAACAQAAAA==.',['安尐']='安尐兮:BAABKgAFFH8JAAMQAAUIxwgyCQAYAQAQAAUIxwgyCQAYAQAEAAQIsRAYLQCQAAAAAA==.',['完美']='完美熊猫:BAACKgAFFH8+AAIEAAgItxQVBwC6AQAEAAgItxQVBwC6AQAqAAQKf0QAAgQACAjBIpcTADUCAAQACAjBIpcTADUCAAAA.',['宫崎']='宫崎美橞:BAABKgAECn8UAAIUAAgI3g6eQgA2AQAUAAgI3g6eQgA2AQAAAA==.',['家家']='家家羊:BAAAKgAFFAQIBAAAAA==.',['寒衣']='寒衣伴楚歌:BAACKgAFFH8qAAIVAAYIwyBTDQD7AQAVAAYIwyBTDQD7AQAqAAQKfyIAAxUACAg6JBkWALACABUACAg6JBkWALACAAMAAQhkAAAAAAAAAAAA.',['小样']='小样最德意:BAABKgAECn8WAAIWAAgIIhbGDQB4AQAWAAgIIhbGDQB4AQAAAA==.',['小烧']='小烧麦:BAAAKgAECggICAABKgAFFAYIBgAXALkZAA==.',['小红']='小红手霸气丶:BAACKgAFFH8JAAIYAAYI6BFTKQCnAAAYAAYI6BFTKQCnAAAqAAQKfyUAAxgACAh2INsmAA4CABgACAh6GtsmAA4CAAsABAinIq42AJMBAAAA.',['少年']='少年游:BAABKgAFFH8HAAQZAAYIehecEADkAAAZAAQI4R2cEADkAAAaAAII8xlCDADJAAAbAAEIpAO5GABKAAAAAA==.',['屠夫']='屠夫之瞳:BAABKgAFFH8MAAMIAAQIDB5YFgDeAAAIAAQIDB5YFgDeAAAJAAQIXA66EwCpAAAAAA==.',['心里']='心里有术:BAABKgAFFH8IAAIZAAgI7gwQCADiAQAZAAgI7gwQCADiAQAAAA==.',['怒风']='怒风魔骑士:BAAAKgAECgcIBQAAAA==.',['我按']='我按了呀:BAAAKgADCggICAAAAA==.',['拿铁']='拿铁之花:BAAAKgADCggICAAAAA==.',['收到']='收到屁哦:BAAAKgAECgcICQAAAA==.',['无为']='无为:BAAAKgAECgcIBgAAAA==.',['旦哥']='旦哥:BAAAKgAECggICgAAAA==.',['时遇']='时遇:BAABKgAECn8YAAQcAAgIWx9rCwAyAgAcAAgI3x5rCwAyAgAdAAYICRmaHwBjAQAeAAEIGBjtHABJAAAAAA==.',['暴风']='暴风虎牙脆:BAAAKgADCgEIAQAAAA==.',['月夜']='月夜星晨:BAABKgAFFH8JAAICAAUIVAhHHQDKAAACAAUIVAhHHQDKAAAAAA==.',['月清']='月清疏:BAAAKgADCggICAAAAA==.',['木剑']='木剑小游侠:BAAAKgAFFAQIBAAAAA==.',['杨超']='杨超越:BAAAKgADCgEIAQAAAA==.',['枫卟']='枫卟:BAAAKgAECgUIBQAAAA==.枫卟雨:BAAAKgAECgQIBAAAAA==.',['柚子']='柚子桑:BAAAKgADCggICAAAAA==.',['桃乐']='桃乐茜:BAAAKgAFFAQIBAAAAA==.',['梅川']='梅川凶兆:BAAAKgADCgcIBwAAAA==.',['死神']='死神不乖:BAAAKgAECgQIBAAAAA==.',['母爱']='母爱一击:BAAAKgAECgUIDgAAAA==.',['汼牛']='汼牛很牛:BAAAKgAFFAEIAgAAAA==.',['没头']='没头脑的家羊:BAAAKgAECgUIDQAAAA==.',['没钱']='没钱花:BAABKgAFFH8GAAIVAAYIHwpLJwBLAQAVAAYIHwpLJwBLAQAAAA==.',['沫年']='沫年:BAAAKgAECgEIAQAAAA==.',['油腻']='油腻的师姐丶:BAACKgAFFH8tAAMKAAcIviG5AQD/AQAKAAcIShu5AQD/AQAIAAYIbx2SBwAvAQAqAAQKfzgAAwgACAivJVoFAO8CAAgACAiMJVoFAO8CAAoABAgoJAAUAG4BAAAA.',['法力']='法力玲珑:BAABKgAECn8VAAILAAgIUhOXLgBOAQALAAgIUhOXLgBOAQAAAA==.',['法小']='法小师:BAAAKgAECgEIAQAAAA==.',['波特']='波特卡斯艾斯:BAABKgAFFH8HAAMLAAQIZRebEQDVAAALAAQIZRebEQDVAAAfAAMIjgZkPQBpAAAAAA==.',['波黑']='波黑软脚虾:BAAAKgAECgQIBQAAAA==.',['浊白']='浊白:BAACKgAFFH8wAAMZAAcIcRrVIAABAQAZAAQIKxnVIAABAQAaAAMI/hxoDgCyAAAqAAQKfzUABBkACAj9IoESAFYCABkACAjZIIESAFYCABoABwgWHAkMAK4BABsABAjBHxAiAHYBAAAA.',['灵学']='灵学院:BAACKgAFFH8QAAIBAAMIyRFxMADKAAABAAMIyRFxMADKAAAqAAQKfyAAAgEACAhNHOEhADQCAAEACAhNHOEhADQCAAAA.',['烈暮']='烈暮壮:BAAAKgAECgQIBwAAAA==.',['熊大']='熊大王:BAAAKgAFFAQIBAAAAA==.',['熊猫']='熊猫烧香丶:BAAAKgAFFAQIBAAAAA==.',['熬夜']='熬夜白了头:BAAAKgADCgIIAgAAAA==.',['爆血']='爆血丶:BAAAKgADCgQIBAAAAA==.',['爱不']='爱不够的妖精:BAABKgAFFH8GAAIVAAQIVxojEgANAQAVAAQIVxojEgANAQAAAA==.',['牛一']='牛一闪:BAAAKgADCgIIAgAAAA==.',['牛大']='牛大王:BAACKgAFFH8IAAMFAAYIvBSHAQCoAQAFAAYIvBSHAQCoAQACAAII8A+RKgCKAAAqAAQKfx0AAgIACAipFoQ2AM4BAAIACAipFoQ2AM4BAAAA.',['牧赖']='牧赖丶红莉栖:BAABKgAFFH8GAAIJAAYIrw+iEgANAQAJAAYIrw+iEgANAQABKgAFFAgIFgAMANkUAA==.',['狐大']='狐大王:BAABKgAFFH8IAAINAAgIWwt8AwADAgANAAgIWwt8AwADAgAAAA==.',['璀璨']='璀璨火花:BAAAKgAECgYIBwAAAA==.',['白起']='白起弑神:BAAAKgAECgQIBAAAAA==.',['直男']='直男呢阿泽:BAABKgAFFH8aAAIPAAQIKCMTHAAOAQAPAAQIKCMTHAAOAQAAAA==.直男阿泽:BAACKgAFFH8QAAILAAQIRBuvEQDVAAALAAQIRBuvEQDVAAAqAAQKfxcAAgsABwgQHrImAIEBAAsABwgQHrImAIEBAAAA.',['神邸']='神邸丶:BAACKgAFFH8qAAIVAAgItBl1EQDSAQAVAAgItBl1EQDSAQAqAAQKfykAAhUACAhtI2AfAJsCABUACAhtI2AfAJsCAAAA.神邸灬:BAACKgAFFH8RAAIIAAYIuxAjFgBrAQAIAAYIuxAjFgBrAQAqAAQKfxsAAggACAi6HIocACsCAAgACAi6HIocACsCAAAA.',['秀妍']='秀妍呢:BAABKgAFFH8QAAIVAAQIiBHnUADOAAAVAAQIiBHnUADOAAAAAA==.',['科洛']='科洛蒂娅:BAAAKgADCgUIBQAAAA==.',['红杏']='红杏又出墙:BAAAKgADCgEIAQAAAA==.',['绝版']='绝版菜鸟:BAACKgAFFH88AAIMAAgI9iEDBABeAgAMAAgI9iEDBABeAgAqAAQKf0EAAgwACAi8JU8EAO8CAAwACAi8JU8EAO8CAAAA.',['缄绪']='缄绪:BAAAKgAECgQIBAAAAA==.',['羅曼']='羅曼羅籣:BAAAKgAFFAQIAgAAAA==.',['羊宝']='羊宝奶你了哦:BAAAKgAECgcIDgAAAA==.',['羽燃']='羽燃:BAAAKgAECgcICwAAAA==.',['老子']='老子姓马蚤:BAAAKgAECgcICAAAAA==.',['肉丸']='肉丸胡辣汤:BAAAKgADCgEIAQAAAA==.',['肉夹']='肉夹馍之神:BAAAKgAFFAIIAgAAAA==.',['艾格']='艾格温:BAAAKgAECgMIAwAAAA==.',['花臂']='花臂小叔叔:BAAAKgAECgMIAwAAAA==.',['菱梦']='菱梦纱璃:BAABKgAECn8bAAQZAAgIGh8SDgB4AgAZAAgIGh8SDgB4AgAaAAII2xajMgB/AAAbAAEIgBlacgBHAAAAAA==.',['菲尼']='菲尼克斯:BAAAKgAECgEIAQAAAA==.',['萨勒']='萨勒芬妮:BAAAKgAECgUIBQAAAA==.',['萨爽']='萨爽阴滋:BAABKgAECn8bAAIPAAgIEBUKOACVAQAPAAgIEBUKOACVAQAAAA==.',['葳蕤']='葳蕤菡萏:BAAAKgAFFAQIBAAAAA==.',['蓝宝']='蓝宝石西梅派:BAAAKgADCgcIBwAAAA==.',['虐纳']='虐纳千百遍:BAAAKgADCgEIAQAAAA==.',['虾仁']='虾仁不眨眼:BAABKgAFFH8IAAMBAAYI2A9jFwA+AQABAAYIZQ1jFwA+AQATAAIIsBgaGwCQAAAAAA==.',['蛇朋']='蛇朋:BAABKgAFFH8SAAMCAAYIFhTcEwB8AQACAAYIFhTcEwB8AQAFAAYIphPTBgBKAQAAAA==.',['路过']='路过一只牛:BAAAKgAECgcIBwAAAA==.',['过客']='过客的记忆:BAAAKgAFFAIIAgAAAA==.',['迪凯']='迪凯灬地狱吼:BAACKgAFFH8GAAIIAAMIRgP+QQCWAAAIAAMIRgP+QQCWAAAqAAQKfxkAAggACAiDEbhDAKQBAAgACAiDEbhDAKQBAAAA.迪凯风暴烈酒:BAAAKgAECgUICAAAAA==.',['野森']='野森海:BAAAKgAECggICAAAAA==.',['金小']='金小元宝:BAAAKgAECgEIAQAAAA==.',['银馍']='银馍:BAAAKgADCgcIBwAAAA==.',['阿撒']='阿撒托斯:BAAAKgAECgYIDAAAAA==.',['阿泽']='阿泽是直男:BAABKgAFFH8MAAIJAAQIugEdEgBWAAAJAAQIugEdEgBWAAAAAA==.',['面对']='面对疾风吧:BAABKgAECn8YAAMIAAgIaB0PHQAoAgAIAAgIaB0PHQAoAgAKAAQIJgfgKwBmAAABKgAFFAgIDAAIAPURAA==.',['颓废']='颓废的干饭:BAAAKgAECgQIBQAAAA==.',['风中']='风中轻舞:BAAAKgAECggIDwAAAA==.',['风雪']='风雪渡归人:BAACKgAFFH8UAAIBAAQIrxVAMADKAAABAAQIrxVAMADKAAAqAAQKfycAAwEACAjMHv0aAF8CAAEACAjMHv0aAF8CABMAAgi5F/R5AIwAAAAA.',['飞扬']='飞扬的可乐:BAAAKgADCgIIAgAAAA==.',['香菜']='香菜呢:BAAAKgAECgYIBgAAAA==.',['骑季']='骑季小子:BAAAKgAECgcIDAAAAA==.',['鬼服']='鬼服活人:BAAAKgADCggICAAAAA==.',['龟仙']='龟仙人:BAAAKgAECggIEgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end