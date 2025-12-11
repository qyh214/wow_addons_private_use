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
 local lookup = {'DeathKnight-Frost','Druid-Restoration','Druid-Balance','Priest-Discipline','Priest-Holy','Priest-Shadow','Shaman-Restoration','Hunter-BeastMastery','Evoker-Devastation','Mage-Arcane','Rogue-Subtlety','Shaman-Elemental','Warrior-Fury','DemonHunter-Havoc','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Rogue-Assassination','Mage-Frost','Unknown-Unknown','Warrior-Protection','Warrior-Arms','Paladin-Retribution','Warlock-Destruction','DeathKnight-Unholy','Druid-Guardian','DeathKnight-Blood','DemonHunter-Vengeance','Mage-Fire','Paladin-Protection','Hunter-Survival','Hunter-Marksmanship','Warlock-Demonology','Paladin-Holy',}; local provider = {region='CN',realm='熵魔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ab='Abaddon:BAABLAAFFH8IAAIBAAMILxhNYQCLAAABAAMILxhNYQCLAAAAAA==.',Bi='Biubiubiu:BAAALAADCgcIBwAAAA==.',Bo='Bonny:BAAALAAECgYIDQAAAA==.',Cc='Ccvip:BAAALAAECgYIBgAAAA==.',Ch='Chovy:BAABLAAFFH8GAAIBAAYIEQBgrQACAAABAAYIEQBgrQACAAAAAA==.',Da='Darkknight:BAAALAAECgUIBQAAAA==.Darwind:BAABLAAFFH8XAAMCAAYIFBqpEgCoAQACAAYIFBqpEgCoAQADAAUI3ggFHgDYAAAAAA==.Darwinm:BAABLAAFFH8SAAQEAAYIOQ6lAgDDAAAFAAMImRMcGADnAAAEAAQIcAmlAgDDAAAGAAMIdwWJIQB6AAABLAAFFAYIFwACABQaAA==.Darwinr:BAACLAAFFH8XAAIHAAUIOR7VFAAOAQAHAAUIOR7VFAAOAQAsAAQKfxwAAgcABgiYJeclAHoCAAcABgiYJeclAHoCAAEsAAUUBggXAAIAFBoA.',Dd='Ddkk:BAAALAADCgIIAgAAAA==.',Do='Doken:BAAALAAECgIIAgAAAA==.',Dr='Dreamend:BAAALAAECgQIBgAAAA==.',Ei='Eilen:BAAALAADCggICQAAAA==.',Fr='Frosty:BAAALAAECgYICQAAAA==.',Fw='Fwmanman:BAACLAAFFH8OAAIIAAMI+B3UOwCtAAAIAAMI+B3UOwCtAAAsAAQKfxQAAggABwjjIEs3AOUBAAgABwjjIEs3AOUBAAAA.',Ga='Gaura:BAACLAAFFH8FAAIJAAIIWAbLHgB4AAAJAAIIWAbLHgB4AAAsAAQKfx8AAgkACAhbE1AmAOcBAAkACAhbE1AmAOcBAAAA.',Gg='Ggkiller:BAABLAAFFH8LAAIKAAUICxD7NwAPAQAKAAUICxD7NwAPAQABLAAFFAcIOAALADQgAA==.',Gn='Gnomestorm:BAACLAAFFH8dAAIHAAUI8xRKJgAvAQAHAAUI8xRKJgAvAQAsAAQKfxsAAwcACAhjHMcNAI0CAAcACAhjHMcNAI0CAAwAAQggA9OHAAAAAAAA.',Go='Goblinkiller:BAABLAAFFH8GAAINAAIIsxsXLACjAAANAAIIsxsXLACjAAAAAA==.',Gr='Grapefiuit:BAABLAAECn8bAAIIAAYIFBkbgwBDAQAIAAYIFBkbgwBDAQAAAA==.',Ha='Hao:BAAALAAECgYICgAAAA==.Hatter:BAAALAAFFAIIAgAAAA==.',Hu='Huskarl:BAAALAAECgYIDQAAAA==.',Ic='Icecoffee:BAAALAAECgYICgAAAA==.',Je='Jesse:BAAALAAECgIIBAAAAA==.',Jr='Jrs:BAAALAAECgYIDwAAAA==.',Ko='Kous:BAAALAAECgEIAQAAAA==.',Kr='Kris:BAABLAAECn8YAAIOAAgIMhKlSABAAQAOAAgIMhKlSABAAQAAAA==.',Le='Leeha:BAAALAADCgUIBQAAAA==.',Lm='Lmn:BAAALAAFFAIIAgABLAAFFAgIJAAJAAYcAA==.',Lo='Losointa:BAABLAAFFH8MAAQPAAYI/gN9EACxAAAPAAUIlQR9EACxAAAQAAEI4wDOGwAjAAARAAMI/gAfJAAhAAAAAA==.',Mi='Mizuki:BAAALAADCgIIAgAAAA==.',Ni='Nimble:BAACLAAFFH84AAMLAAcINCCpBADAAQALAAYIRB6pBADAAQASAAQIBBpuBgBsAQAsAAQKfzoAAwsACAgtIkYEABkDAAsACAjaIUYEABkDABIACAiKHbsXAFgCAAAA.Nishizhu:BAAALAAECgUIBQAAAA==.Niubility:BAACLAAFFH8ZAAIBAAYIBhqtIgCpAQABAAYIBhqtIgCpAQAsAAQKfxUAAgEABwiXFp05AJUBAAEABwiXFp05AJUBAAEsAAUUBggcAAgAMBkA.',No='Nobubu:BAAALAAECgEIAQAAAA==.',Pa='Packaged:BAAALAADCgQIBAAAAA==.',Ra='Ray:BAAALAAECgIIAgAAAA==.',Re='Red:BAAALAAECgIIAgAAAA==.',Rh='Rhapsody:BAACLAAFFH8IAAINAAMIbRO2PQBzAAANAAMIbRO2PQBzAAAsAAQKfxUAAg0ABgjgHpMpALgBAA0ABgjgHpMpALgBAAAA.',Si='Siejja:BAAALAAECgQIBAAAAA==.',Sp='Spirithunter:BAAALAAECgYIBgAAAA==.',Uz='Uzi:BAAALAADCgYIBgAAAA==.',Vo='Voviod:BAAALAAECgEIAQAAAA==.Voviodd:BAAALAAECgYICgAAAA==.',We='Westwoodkill:BAACLAAFFH8RAAMKAAYI5hvmFQDOAQAKAAYI5hvmFQDOAQATAAMINRd9FwBAAAAsAAQKfx4AAhMABwgzIEIJACwCABMABwgzIEIJACwCAAAA.',Zy='Zyh:BAAALAAFFAIIAgAAAA==.',['一个']='一个奶爸:BAABLAAFFH8NAAIHAAIIoREWVwBmAAAHAAIIoREWVwBmAAAAAA==.一个技能够了:BAAALAAECgIIAgAAAA==.',['一刀']='一刀掌死你:BAAALAAFFAIIAgAAAA==.',['一哓']='一哓孤孀一:BAAALAADCgIIAgAAAA==.',['一头']='一头大牛:BAAALAAECgYICAABLAAECgYIEgAUAAAAAA==.',['一寸']='一寸黑丶:BAAALAAECgMIAwAAAA==.',['一朵']='一朵小娇花:BAAALAAECgYIDAAAAA==.',['一杯']='一杯鸡蛋:BAAALAAECgEIAQAAAA==.',['一梦']='一梦入星河:BAAALAAFFAIIAgAAAA==.',['一棍']='一棍电晕你:BAAALAAECgYIBAAAAA==.',['一炮']='一炮轰死你:BAAALAAECgcIEQAAAA==.',['一百']='一百多个萨满:BAACLAAFFH8hAAIMAAcI7w7tHABZAQAMAAcI7w7tHABZAQAsAAQKfysAAgwACAjjHCInAHsCAAwACAjjHCInAHsCAAAA.',['一脚']='一脚不小心:BAABLAAFFH8OAAQRAAYIURWUDQBtAQARAAYIURWUDQBtAQAPAAII+wtAFgBpAAAQAAII9wotGAA/AAAAAA==.',['一航']='一航:BAAALAAECgUIBQAAAA==.',['一身']='一身腱子肉:BAABLAAECn8UAAQVAAgIZAyPJAAjAQAVAAgItQqPJAAjAQANAAcIkAfZVQAUAQAWAAEIPhAbFgA2AAAAAA==.一身都是肉:BAAALAAECgYIBgAAAA==.',['七月']='七月未央:BAAALAAECgYICwAAAA==.',['七海']='七海娜娜米丷:BAABLAAFFH8IAAIXAAIIHx60JwC6AAAXAAIIHx60JwC6AAAAAA==.',['三指']='三指元素:BAAALAAECgYIBgAAAA==.',['三花']='三花红棍:BAAALAAFFAYIAgABLAAFFAgIFAAVAD0eAA==.',['三角']='三角初华:BAABLAAFFH8GAAIYAAYIIRCnMQBQAQAYAAYIIRCnMQBQAQAAAA==.',['不无']='不无理取闹:BAABLAAFFH8UAAIPAAYIGRytBgDUAQAPAAYIGRytBgDUAQAAAA==.',['不残']='不残酷:BAABLAAFFH8MAAIPAAYIzxfzBwCvAQAPAAYIzxfzBwCvAQAAAA==.',['不爱']='不爱喝咖啡:BAABLAAFFH8IAAIYAAII7wjhZgA5AAAYAAII7wjhZgA5AAAAAA==.',['不眠']='不眠:BAAALAAECgYIBgAAAA==.',['专家']='专家级叫兽:BAAALAADCgEIAQAAAA==.',['丨血']='丨血祭寳丨:BAAALAAECgYICgAAAA==.',['丶一']='丶一寸黑:BAAALAAECgUIBQAAAA==.',['丶沐']='丶沐雨橙风:BAAALAAFFAcIAgAAAA==.',['丶血']='丶血祭宝丶:BAAALAAECgYIBgAAAA==.丶血祭寳丶:BAAALAAECgMIBAAAAA==.',['丷初']='丷初霜:BAAALAAECgQIBAAAAA==.',['丿复']='丿复生者:BAACLAAFFH8UAAIBAAYIvBLONQBkAQABAAYIvBLONQBkAQAsAAQKfxgAAwEACAjWFJ2BAPcBAAEACAgXFJ2BAPcBABkAAghLEMRPAHIAAAAA.',['乄胖']='乄胖爹乄:BAAALAADCgMIAwAAAA==.',['九月']='九月小牧:BAAALAAECggIEQAAAA==.',['九袋']='九袋长老:BAAALAADCggICAAAAA==.',['二零']='二零二五:BAAALAADCggICwAAAA==.',['云中']='云中飞雪:BAAALAAFFAIIAgAAAA==.',['云之']='云之君兮:BAAALAADCgMIAwAAAA==.',['五千']='五千战火不加:BAAALAAFFAIIBAAAAA==.',['交稿']='交稿日:BAABLAAFFH8IAAIHAAQI2RMVLQABAQAHAAQI2RMVLQABAQAAAA==.',['人心']='人心薄凉丶伤:BAAALAAFFAgIBAAAAA==.',['什果']='什果鲨律:BAAALAAECgYIBgAAAA==.',['今年']='今年二四岁:BAAALAADCgcICwAAAA==.',['仓老']='仓老师:BAAALAAECgYIBgAAAA==.',['以德']='以德扶人:BAAALAAFFAIIBAAAAA==.',['以电']='以电服人:BAAALAADCggIDAAAAA==.',['伊利']='伊利达雷牛奶:BAAALAADCgEIAQAAAA==.',['你也']='你也配说剑来:BAAALAAECgYICAAAAA==.',['你愁']='你愁啥:BAAALAAFFAIIAgAAAA==.',['你无']='你无法看见:BAAALAAECgYIBgAAAA==.',['你说']='你说我无情:BAABLAAFFH8UAAIPAAYI4xlkBwC+AQAPAAYI4xlkBwC+AQAAAA==.',['侠以']='侠以武犯禁:BAAALAADCgIIAgAAAA==.',['光头']='光头卖香油:BAAALAAECgIIAgAAAA==.',['光明']='光明乳业:BAAALAAECgYICQAAAA==.',['公子']='公子丶上边请:BAAALAADCgYIBgAAAA==.公子丶请留步:BAAALAADCggIDgAAAA==.',['公牛']='公牛的血:BAABLAAFFH8NAAIMAAMIyx2AFQALAQAMAAMIyx2AFQALAQAAAA==.',['兰斯']='兰斯络特:BAAALAAECggIDQAAAA==.',['再不']='再不玩就老了:BAAALAAFFAIIAgAAAA==.',['冖九']='冖九七:BAABLAAFFH8GAAIBAAYIRhTHMwBsAQABAAYIRhTHMwBsAQAAAA==.',['冬天']='冬天雪人:BAAALAADCgEIAQAAAA==.',['冰墓']='冰墓裁决:BAABLAAFFH8HAAIBAAIIchYjWACcAAABAAIIchYjWACcAAAAAA==.',['冰忆']='冰忆:BAABLAAFFH8GAAIXAAYIWBPuBQAIAgAXAAYIWBPuBQAIAgAAAA==.',['冰糖']='冰糖桂元:BAABLAAFFH8JAAIHAAQIRg3MNgDIAAAHAAQIRg3MNgDIAAAAAA==.冰糖桂員:BAABLAAFFH8GAAITAAMIbBcTDQCHAAATAAMIbBcTDQCHAAAAAA==.冰糖桂圆:BAAALAAECgQIBAAAAA==.',['冲锋']='冲锋猝死:BAAALAAECgYIBgAAAA==.',['净月']='净月:BAAALAAECgEIAQAAAA==.',['凝残']='凝残丶辰:BAAALAADCgIIAgAAAA==.凝残丶魍:BAAALAAECgYIBwAAAA==.',['凡人']='凡人皆有一死:BAACLAAFFH8MAAIXAAQI0Q3NPQCgAAAXAAQI0Q3NPQCgAAAsAAQKfykAAhcABgieIKowANABABcABgieIKowANABAAAA.',['凯旋']='凯旋灵魂:BAACLAAFFH8MAAITAAQI4h0RCQD1AAATAAQI4h0RCQD1AAAsAAQKfx8AAhMACAgbHBwVAHQCABMACAgbHBwVAHQCAAAA.',['凶残']='凶残的怪兽:BAABLAAFFH8GAAINAAIIxgepXAA5AAANAAIIxgepXAA5AAAAAA==.',['凶狠']='凶狠最无敌:BAAALAAFFAgIAgAAAA==.',['刘湿']='刘湿湿:BAAALAADCgMIAwAAAA==.',['剑无']='剑无炎:BAAALAAECgYIBwAAAA==.',['割草']='割草机:BAAALAAECgEIAQAAAA==.',['十五']='十五德太阳:BAAALAADCgQIBAAAAA==.',['千甄']='千甄:BAAALAAECgYIDwAAAA==.',['午夜']='午夜神:BAAALAADCgQIBAAAAA==.午夜胸岭:BAABLAAECn8VAAIIAAYItSS9JwAZAgAIAAYItSS9JwAZAgAAAA==.',['南瓜']='南瓜皮:BAAALAADCgMIAwAAAA==.',['卡列']='卡列乌斯:BAAALAAECggIDgABLAAFFAgIHQAQAJoLAA==.',['卡拉']='卡拉赞地主:BAAALAAFFAIIAgAAAA==.',['卿明']='卿明语时:BAACLAAFFH8JAAILAAMIMgcEEAB6AAALAAMIMgcEEAB6AAAsAAQKfx4AAgsABwgxF9kHAKYBAAsABwgxF9kHAKYBAAAA.',['压妹']='压妹叠丶:BAAALAAECgMIAwAAAA==.',['原则']='原则:BAAALAAECggICAAAAA==.',['叁拾']='叁拾陆:BAAALAADCggIDQAAAA==.',['叔叔']='叔叔别捏了:BAAALAAFFAIIBAAAAA==.叔叔的果粒橙:BAAALAAFFAIIAgAAAA==.',['变不']='变不了树:BAAALAAECgQICgAAAA==.',['古德']='古德莫林:BAAALAADCgcIBwAAAA==.',['只会']='只会睡觉的鱼:BAAALAAECgcIDQAAAA==.',['只是']='只是条闲鱼:BAAALAAECgYIDgAAAA==.',['叫我']='叫我大尸兄:BAAALAAECgYIBgAAAA==.',['叮一']='叮一下玖拾:BAAALAAECgEIAQAAAA==.',['叶孤']='叶孤城:BAAALAAECggICAAAAA==.',['吉吉']='吉吉大魔王:BAAALAAECgEIAQAAAA==.',['吉尔']='吉尔尼斯德:BAAALAAFFAIIAgAAAA==.',['吊不']='吊不吊:BAAALAADCgIIAgAAAA==.',['吵架']='吵架王宫下:BAAALAAECgYIDgAAAA==.',['吾命']='吾命欲真:BAAALAAECgcIDgAAAA==.',['吾宁']='吾宁爱与憎:BAABLAAFFH8RAAIKAAYIPxe6EgDQAQAKAAYIPxe6EgDQAQAAAA==.',['呂布']='呂布:BAABLAAFFH8HAAIXAAIIaRl9MQCqAAAXAAIIaRl9MQCqAAAAAA==.',['周瑜']='周瑜:BAAALAAFFAIIBAAAAA==.',['咕咕']='咕咕丶:BAAALAAFFAIIAgAAAA==.咕咕咪:BAAALAAECgYICAAAAA==.',['哈基']='哈基米:BAAALAAECgYIBgAAAA==.',['哈库']='哈库菈玛塔塔:BAACLAAFFH8NAAMNAAcIkAytGwCJAQANAAcIkAytGwCJAQAWAAEIEQHMCQAuAAAsAAQKfxkAAxYACAgeHUANAAECAA0ACAhYHNtHABoCABYABgjbHUANAAECAAAA.',['哈鸡']='哈鸡米:BAABLAAFFH8JAAIXAAMIuhpGFgAJAQAXAAMIuhpGFgAJAQAAAA==.',['哑巴']='哑巴湖小米粒:BAAALAADCggICAAAAA==.',['哪里']='哪里不无取闹:BAABLAAFFH8SAAIPAAYIFhlmBwC+AQAPAAYIFhlmBwC+AQAAAA==.',['啊要']='啊要辣油阿:BAAALAAFFAIIAwAAAA==.',['喝酸']='喝酸奶忝瓶蓋:BAAALAAFFAIIAgAAAA==.',['嗦溜']='嗦溜一口儿:BAABLAAFFH8MAAIYAAMI6RGpPACbAAAYAAMI6RGpPACbAAAAAA==.',['嗯哼']='嗯哼嗯哼勥烎:BAAALAAECgUIBwAAAA==.',['嘿嘿']='嘿嘿哇哇:BAAALAADCgIIAgAAAA==.',['四十']='四十几只萨满:BAABLAAFFH8HAAMHAAMIqBZ9OwC1AAAHAAMIqBZ9OwC1AAAMAAIIOwsOTQA5AAAAAA==.',['回头']='回头一曰:BAAALAAECgYICQAAAA==.',['圣光']='圣光无用:BAAALAAECgYIBgAAAA==.',['坏蛋']='坏蛋惊羽:BAABLAAFFH8GAAIIAAIIFh7OfgBZAAAIAAIIFh7OfgBZAAABLAAFFAgIAwAUAAAAAA==.',['坝坝']='坝坝好:BAAALAADCgcIBwAAAA==.',['坦帕']='坦帕斯:BAABLAAECn8bAAMVAAcIfxNVIQA6AQAVAAcIORFVIQA6AQANAAYImw0kpwA1AQAAAA==.',['堕落']='堕落乱舞:BAAALAAFFAIIAgAAAA==.',['塔布']='塔布羊:BAAALAADCgYIBgAAAA==.',['墙上']='墙上的向日葵:BAAALAAECgYIBwAAAA==.',['多恩']='多恩保安阿瓦:BAAALAAFFAIIAgAAAA==.',['夜听']='夜听云海:BAABLAAFFH8IAAMDAAgI0QB6PgApAAADAAcI2gB6PgApAAAaAAEIjwDZEgAEAAAAAA==.',['夜浮']='夜浮华:BAABLAAFFH8IAAIXAAIIPQw5TQCUAAAXAAIIPQw5TQCUAAAAAA==.',['大军']='大军:BAAALAAFFAIIBAAAAA==.',['大声']='大声咆哮:BAAALAAECgYIBgAAAA==.',['大湿']='大湿兄丶:BAAALAADCgYIBgAAAA==.',['天朝']='天朝铁甲如云:BAAALAAFFAIIAgAAAA==.',['天空']='天空中的雷鸣:BAAALAAFFAgIAQAAAA==.',['太乙']='太乙假人:BAAALAAECgMIAwAAAA==.',['太难']='太难得的回忆:BAACLAAFFH8pAAMBAAYIXBJWLwB9AQABAAYIXBJWLwB9AQAbAAEIyQMIGQAyAAAsAAQKfzEAAgEACAhnGStVAE0CAAEACAhnGStVAE0CAAAA.',['奇犽']='奇犽奏敌客:BAAALAADCgcICAAAAA==.',['奔跑']='奔跑的拉条子:BAAALAAFFAMIAwAAAA==.',['奕剑']='奕剑十五:BAAALAAECgYIDwAAAA==.',['奥卡']='奥卡诺斯:BAAALAADCggICAAAAA==.',['奥泽']='奥泽美咲:BAABLAAFFH8GAAIYAAYI2hL3JgB+AQAYAAYI2hL3JgB+AQAAAA==.',['女子']='女子大学校长:BAAALAAECgIIAgAAAA==.',['奶盖']='奶盖红茶:BAAALAAECgQIBgAAAA==.',['奶神']='奶神小布:BAAALAAECgYIBgAAAA==.',['好牛']='好牛的滑子:BAAALAADCgEIAQAAAA==.',['好男']='好男人老婆造:BAAALAAECgYIBgAAAA==.',['妖靈']='妖靈:BAAALAAECgYICQAAAA==.',['妮雅']='妮雅:BAAALAADCgIIAgAAAA==.',['姬伯']='姬伯沓:BAAALAAECggICAAAAA==.',['姿伊']='姿伊:BAABLAAFFH8GAAIKAAYIHBNvKwBiAQAKAAYIHBNvKwBiAQAAAA==.',['婲開']='婲開糀謝:BAAALAAECgYIBgAAAA==.',['媄玔']='媄玔裤紁:BAAALAADCgIIAgAAAA==.',['嫂嫂']='嫂嫂请住手:BAABLAAECn8ZAAIYAAcIaRXCawCxAQAYAAcIaRXCawCxAQAAAA==.',['子初']='子初:BAAALAADCgIIAgAAAA==.',['子妗']='子妗:BAABLAAFFH8GAAIcAAYInguOAgB3AQAcAAYInguOAgB3AQAAAA==.',['孙小']='孙小美:BAAALAAECgIIBAAAAA==.',['孤独']='孤独之雨:BAABLAAFFH8GAAMHAAYIjBFwJgAuAQAHAAUIBxRwJgAuAQAMAAEIHgwsQwBFAAAAAA==.',['安之']='安之若:BAAALAADCgYIBgAAAA==.',['安娜']='安娜:BAAALAAECgYIBgAAAA==.',['安格']='安格斯谷饲:BAAALAADCgIIAgAAAA==.',['安玲']='安玲:BAAALAAECgUIBQAAAA==.',['安静']='安静:BAAALAAECgQIBAAAAA==.',['宝宝']='宝宝蛇:BAAALAAFFAYIAgAAAA==.',['对不']='对不起我要赢:BAABLAAFFH8IAAIOAAIIfxcLTQBMAAAOAAIIfxcLTQBMAAAAAA==.',['对唔']='对唔嗨住啊:BAAALAAECgYICAAAAA==.',['小丢']='小丢丢:BAAALAAECgIIAgAAAA==.',['小妹']='小妹贵姓:BAAALAAECgYIDAAAAA==.',['小娜']='小娜美:BAABLAAFFH8GAAIEAAYI0wO/BQBdAAAEAAYI0wO/BQBdAAAAAA==.',['小小']='小小聋人:BAABLAAFFH8GAAIJAAIIgwgaIwAyAAAJAAIIgwgaIwAyAAAAAA==.',['小帝']='小帝大人:BAAALAAECgIIAwAAAA==.',['小张']='小张:BAACLAAFFH8dAAMBAAUIAh+hNQBlAQABAAUIAh+hNQBlAQAbAAEIMBNmGABCAAAsAAQKfz0AAgEACAggJWUFAN0CAAEACAggJWUFAN0CAAAA.',['小正']='小正经:BAAALAADCgIIAgAAAA==.',['小沫']='小沫沫不吓人:BAAALAADCgcIBwAAAA==.',['小浪']='小浪蹄子:BAAALAADCgMIAwAAAA==.',['小熊']='小熊几点啦丶:BAAALAAECgcIBQAAAA==.',['小狐']='小狐:BAAALAAECgMIAwAAAA==.小狐仙:BAAALAAECgMIAwAAAA==.',['小猪']='小猪乔治:BAACLAAFFH8JAAIYAAMIRxdSSQCWAAAYAAMIRxdSSQCWAAAsAAQKfxkAAhgACAgREflxAKIBABgACAgREflxAKIBAAAA.小猪伊薇:BAABLAAFFH8GAAICAAMIGQ32MwCaAAACAAMIGQ32MwCaAAABLAAFFAMICQAYAEcXAA==.小猪佩奇:BAABLAAFFH8LAAIXAAII8hG2ZQBDAAAXAAII8hG2ZQBDAAABLAAFFAMICQAYAEcXAA==.',['小瓶']='小瓶娃哈哈:BAAALAAECgUIBQAAAA==.',['小睡']='小睡塔:BAAALAADCgUICAAAAA==.',['小羊']='小羊肖恩:BAAALAADCgQIBAAAAA==.',['小脸']='小脸狐狐:BAABLAAFFH8GAAIFAAIIaQ0dMwCKAAAFAAIIaQ0dMwCKAAAAAA==.',['小菜']='小菜羊师妹:BAAALAAFFAQIBAAAAA==.',['小豆']='小豆丁:BAAALAAECgYIBgAAAA==.',['小鼠']='小鼠大浪:BAAALAAECgEIAQAAAA==.',['尼古']='尼古拉斯灬导:BAAALAAECgYICQAAAA==.',['山下']='山下忠秀:BAABLAAFFH8LAAIXAAII+x+6UQBSAAAXAAII+x+6UQBSAAABLAAFFAMIDgAIAPgdAA==.',['崔希']='崔希丝丶:BAAALAAECgYIBgAAAA==.',['布林']='布林顿九千:BAABLAAFFH8FAAIdAAUI4wPOBQDaAAAdAAUI4wPOBQDaAAAAAA==.',['布絡']='布絡克斯:BAABLAAECn8WAAIbAAYIuQ1lHADdAAAbAAYIuQ1lHADdAAAAAA==.',['布能']='布能用:BAAALAAECgEIAQAAAA==.',['布鲁']='布鲁特斯:BAAALAAFFAIIBAAAAA==.',['帝国']='帝国的荣耀:BAAALAAECgYIDAAAAA==.',['帝大']='帝大人:BAAALAADCgYICwAAAA==.',['帝轩']='帝轩:BAABLAAFFH8HAAIcAAIINRKQEgBpAAAcAAIINRKQEgBpAAAAAA==.',['帝靈']='帝靈:BAAALAAECgYICAAAAA==.',['帽帽']='帽帽里装暗法:BAAALAADCgEIAQAAAA==.',['平安']='平安喜樂:BAAALAAECgUIBwAAAA==.',['年轻']='年轻真的很好:BAAALAAECggICAAAAA==.',['幺三']='幺三:BAAALAADCgEIAQAAAA==.',['幻影']='幻影刺客:BAAALAADCggICAAAAA==.',['幽灵']='幽灵之翼:BAAALAAECggICAAAAA==.',['幽狼']='幽狼:BAAALAAFFAMIAwAAAA==.',['幽魅']='幽魅冰影:BAAALAAECggICAABLAAFFAgIHgABAKscAA==.',['庐州']='庐州月光:BAABLAAFFH8IAAIKAAYI0BXtJACBAQAKAAYI0BXtJACBAQAAAA==.',['弑神']='弑神者丶:BAACLAAFFH8GAAMTAAYIRwljCQDoAAATAAUICwtjCQDoAAAKAAEIdAAWbQANAAAsAAQKfxcAAxMACAgaJHcMANcCABMACAhZIncMANcCAAoABQjNFXtAAAoBAAAA.',['弦卷']='弦卷心:BAABLAAFFH8MAAIYAAYIfA6oLQBkAQAYAAYIfA6oLQBkAQAAAA==.',['弹凸']='弹凸凸:BAAALAAECgcIDQAAAA==.',['归来']='归来的半仙:BAAALAAECgYICAAAAA==.',['影灬']='影灬:BAAALAAECgYIEgAAAA==.',['影魅']='影魅:BAAALAAECgYIEwAAAA==.',['心生']='心生万法:BAABLAAFFH8FAAIeAAIIGgfgHgBhAAAeAAIIGgfgHgBhAAAAAA==.',['心碎']='心碎往事:BAAALAAECggICAAAAA==.',['心陌']='心陌南尘:BAABLAAECn8XAAINAAYIKBv2OgBtAQANAAYIKBv2OgBtAQAAAA==.',['忍耐']='忍耐姜歌:BAAALAADCgYIBwAAAA==.',['怕老']='怕老公:BAAALAAECgQIBAAAAA==.',['性感']='性感牛牛:BAABLAAFFH8IAAIeAAIINQeNHQBmAAAeAAIINQeNHQBmAAAAAA==.',['怪味']='怪味虾仁:BAAALAAECgUIBwAAAA==.',['恶魔']='恶魔小锦鲤:BAABLAAFFH8FAAIcAAIISwKzGgBJAAAcAAIISwKzGgBJAAAAAA==.',['惊飞']='惊飞羽:BAABLAAFFH8GAAISAAIIZwzuHACGAAASAAIIZwzuHACGAAAAAA==.',['我不']='我不殺鼪:BAACLAAFFH8HAAIIAAMIegmRdAB2AAAIAAMIegmRdAB2AAAsAAQKfycAAggACAgmGustAAMCAAgACAgmGustAAMCAAAA.',['我只']='我只抽云烟:BAAALAAECgcIEwAAAA==.我只抽双喜:BAAALAADCgcICQAAAA==.我只抽宽窄:BAAALAAECgYIBgAAAA==.我只抽苏烟:BAAALAADCgQIBAAAAA==.我只抽荷花:BAAALAAECgYIBgAAAA==.我只抽黄山:BAAALAAECgYIEgAAAA==.',['我心']='我心里:BAABLAAFFH8HAAIfAAIISBT2BQBAAAAfAAIISBT2BQBAAAAAAA==.',['我无']='我无法看见:BAAALAAECgYIBgAAAA==.我无理取闹:BAABLAAFFH8IAAIPAAYIaxDtCQB0AQAPAAYIaxDtCQB0AQAAAA==.',['我残']='我残酷:BAABLAAFFH8YAAIPAAYIqR3wBQDqAQAPAAYIqR3wBQDqAQAAAA==.',['战歌']='战歌丶:BAAALAAECgYICwAAAA==.',['战神']='战神小锦鲤:BAACLAAFFH8MAAMNAAII2RbWNQCYAAANAAII2RbWNQCYAAAVAAIIdwyHJwBvAAAsAAQKfxYAAxUACAhOFoBJAFsBABUACAikDIBJAFsBAA0ABgjYGLZaAAUBAAAA.',['才哥']='才哥的愤怒:BAAALAAECgYIDAAAAA==.',['扑倒']='扑倒就整:BAAALAADCggIEAAAAA==.',['执念']='执念叶子丶凡:BAAALAAFFAIIAgAAAA==.',['技能']='技能五:BAABLAAFFH8HAAIVAAcIWwqJDgBfAQAVAAcIWwqJDgBfAQAAAA==.',['拽牛']='拽牛:BAAALAAECgUIBQAAAA==.',['捞鱼']='捞鱼小巴妞:BAAALAAFFAIIBAAAAA==.',['救世']='救世萨杨永信:BAAALAAFFAIIAgAAAA==.',['救救']='救救冬鳞蝌蚪:BAAALAAECgIIAgAAAA==.',['散发']='散发弄扁舟:BAABLAAFFH8LAAMKAAYI1xBjKwBjAQAKAAYISg5jKwBjAQATAAIIqRFSFABGAAAAAA==.',['新康']='新康泰克:BAAALAAECgYIBgAAAA==.',['旅途']='旅途中的牛:BAABLAAFFH8IAAINAAIIYhMwSwBIAAANAAIIYhMwSwBIAAAAAA==.',['旋转']='旋转乄玛瑬:BAAALAAECgEIAQAAAA==.',['无双']='无双的王者:BAAALAAECgYIEwAAAA==.',['无情']='无情大将军:BAAALAADCggICAAAAA==.',['无敌']='无敌小跟班:BAAALAAECgIIAgAAAA==.无敌莫西干:BAABLAAFFH8UAAIBAAYIrxdzKACUAQABAAYIrxdzKACUAQAAAA==.',['无言']='无言之境:BAAALAAECgYIBgAAAA==.',['日月']='日月吉吉:BAABLAAFFH8HAAMNAAMIGAh4HgDUAAANAAMIGAh4HgDUAAAVAAIIAAPwNwAoAAAAAA==.',['星尘']='星尘猎丶:BAAALAADCgYIBgAAAA==.',['星晨']='星晨猎丶:BAABLAAFFH8GAAIgAAYIRAGEDwCCAAAgAAYIRAGEDwCCAAAAAA==.',['星期']='星期三:BAAALAAECgQIBAAAAA==.星期五要放假:BAAALAAECgcIDAAAAA==.',['星辰']='星辰蓝天:BAACLAAFFH8tAAMFAAYILyP9BgBaAgAFAAYILyP9BgBaAgAGAAIImQpkIACFAAAsAAQKf4AAAwUACAjVIxMEABgDAAUACAjVIxMEABgDAAYABQggHpZNAIABAAAA.',['春生']='春生夏长:BAABLAAFFH8FAAMaAAMInxKYCABcAAAaAAMInxKYCABcAAACAAIItwdQTwBVAAAAAA==.',['是个']='是个小白:BAAALAAECggICAAAAA==.',['晨拥']='晨拥:BAACLAAFFH8IAAIXAAIIZx/nPQCgAAAXAAIIZx/nPQCgAAAsAAQKfx8AAhcABwiFI3kZAEQCABcABwiFI3kZAEQCAAAA.',['晶莹']='晶莹剔透:BAAALAADCgcIBwAAAA==.',['暗夜']='暗夜譕情:BAABLAAFFH8OAAIBAAUIaBT4RQAiAQABAAUIaBT4RQAiAQAAAA==.',['暗战']='暗战殇:BAABLAAFFH8GAAIVAAIIzg2ZLAA3AAAVAAIIzg2ZLAA3AAAAAA==.',['曹逹']='曹逹华:BAAALAAECggIEAAAAA==.',['曾照']='曾照彩云归:BAAALAAECgUICQAAAA==.',['曾经']='曾经丶爱过:BAABLAAFFH8IAAIYAAIIZAsVYAA/AAAYAAIIZAsVYAA/AAAAAA==.',['最终']='最终幻想:BAAALAAECgcIEwAAAA==.',['月儛']='月儛云漪:BAAALAAECgIIAQAAAA==.',['月辉']='月辉随云:BAAALAADCgcIBwAAAA==.',['有时']='有时右逝:BAAALAAECggICwAAAA==.',['朕赦']='朕赦你捂嘴:BAAALAADCgIIAgAAAA==.',['木木']='木木杨:BAABLAAFFH8IAAIKAAgIphUfCgBBAgAKAAgIphUfCgBBAgAAAA==.',['木瓜']='木瓜最伟大:BAAALAADCgEIAQAAAA==.',['本街']='本街最靓的仔:BAAALAAECgYICQAAAA==.',['杀戮']='杀戮盛宴:BAAALAAECgYIDQAAAA==.',['杀财']='杀财神:BAAALAAECgYICQABLAAFFAgIBwANAEIWAA==.',['李奥']='李奥瑞克王:BAABLAAFFH8GAAIBAAYIiSBlGQDTAQABAAYIiSBlGQDTAQAAAA==.',['李宝']='李宝库:BAAALAAECgYIDAAAAA==.',['李相']='李相赫:BAAALAAECgMIAwAAAA==.',['東尼']='東尼大木:BAACLAAFFH8HAAIHAAMInw+4PgCEAAAHAAMInw+4PgCEAAAsAAQKfyIAAgcABgggHXVoALQBAAcABgggHXVoALQBAAAA.',['枫语']='枫语:BAAALAADCgUIBwAAAA==.',['柚子']='柚子啊:BAAALAAECgYIBgAAAA==.',['栗子']='栗子醋:BAACLAAFFH8oAAMFAAYIcRv8DQDzAQAFAAYIcRv8DQDzAQAGAAMIqQxGHwCOAAAsAAQKfxUAAwUACAgLFylBANIBAAUACAgLFylBANIBAAYABQiIHGAeAFMBAAEsAAUUCAgDABQAAAAA.',['格洛']='格洛玛什:BAAALAADCgQIBAAAAA==.',['格鲁']='格鲁尔大王:BAAALAAECgYIDgABLAAECgYIEgAUAAAAAA==.',['梁有']='梁有鱼:BAAALAADCgYIBgAAAA==.',['梅花']='梅花:BAAALAAECgYIEgAAAA==.',['棉花']='棉花糖果儿:BAAALAAECgYIBgAAAA==.棉花糖豆豆:BAAALAAECgYICgAAAA==.',['棒子']='棒子插入:BAAALAAECgUIAgAAAA==.',['植物']='植物人:BAAALAAFFAIIAwAAAA==.',['椰椰']='椰椰:BAAALAAFFAIIBAAAAA==.',['楠神']='楠神:BAAALAADCgYIBgAAAA==.',['樱桃']='樱桃小丸犊子:BAAALAAECgYIDAAAAA==.',['武氏']='武氏奶娘:BAAALAAFFAIIAgAAAA==.武氏媚娘:BAAALAAECgIIBAAAAA==.',['死亡']='死亡旋涡:BAABLAAFFH8TAAINAAMIlxrINQCbAAANAAMIlxrINQCbAAAAAA==.',['段剑']='段剑袭明:BAAALAAFFAIIAgAAAA==.',['段杖']='段杖袭明:BAABLAAFFH8MAAIFAAMIWBRdLQC6AAAFAAMIWBRdLQC6AAAAAA==.',['毒液']='毒液丶:BAAALAAFFAIIBAAAAA==.',['比尔']='比尔:BAAALAAECgYIBgAAAA==.',['水晶']='水晶叶子:BAABLAAFFH8UAAIHAAUIChPPJwAlAQAHAAUIChPPJwAlAQAAAA==.',['水港']='水港灬长钓:BAAALAADCgEIAQAAAA==.',['氵九']='氵九七:BAABLAAFFH8IAAIBAAYISx88HADFAQABAAYISx88HADFAQAAAA==.',['求豆']='求豆麻袋:BAAALAADCggICAAAAA==.',['汉克']='汉克威尔森:BAACLAAFFH8JAAMNAAYImwhpKgAXAQANAAUIqwlpKgAXAQAVAAEISAOWOgAgAAAsAAQKfycAAw0ACAhbErQpALgBAA0ACAhbErQpALgBABUABwjoCkssAPQAAAAA.',['江无']='江无浪:BAAALAADCgQIBAAAAA==.',['江流']='江流:BAAALAAECgYIDwAAAA==.',['沐小']='沐小雪灬:BAAALAADCgYIBgAAAA==.',['沙雕']='沙雕么不沙雕:BAAALAAECgYIBgAAAA==.',['没可']='没可乐的日子:BAAALAAFFAIIBAAAAA==.',['波雅']='波雅一汉库克:BAAALAADCgIIAgAAAA==.',['泽卷']='泽卷小雨:BAAALAAECggICAAAAA==.',['洁灬']='洁灬雨灵:BAAALAADCggICAAAAA==.',['浅野']='浅野心:BAAALAAFFAIIAgAAAA==.',['浪总']='浪总:BAAALAAECgYIBgAAAA==.',['浴紫']='浴紫而存:BAAALAAFFAIIBAAAAA==.',['海问']='海问香丶:BAAALAAECgYICgAAAA==.',['消失']='消失的永恒:BAAALAAECgYICwAAAA==.',['淡淡']='淡淡流苏:BAACLAAFFH8IAAIHAAYIlAHgTgB+AAAHAAYIlAHgTgB+AAAsAAQKfxQAAgcABgjQEhFUAAwBAAcABgjQEhFUAAwBAAAA.',['深度']='深度失忆:BAAALAAFFAIIAgAAAA==.',['清水']='清水键:BAAALAAECgQICgAAAA==.',['清纯']='清纯女班长:BAABLAAFFH8GAAMhAAIIgBSmEQBJAAAhAAIIgBSmEQBJAAAYAAIILggbaQA3AAAAAA==.',['潶黯']='潶黯亡战:BAABLAAFFH8fAAIVAAYIgQ4WEwArAQAVAAYIgQ4WEwArAQAAAA==.',['火花']='火花闪电:BAAALAAECgUIBQAAAA==.',['灬殇']='灬殇城灬:BAAALAAECgYIBgAAAA==.',['灬火']='灬火锅汤泡饭:BAAALAAECgUIBQAAAA==.',['灬魔']='灬魔道:BAAALAAECgUIBQAAAA==.',['灵魂']='灵魂羁绊:BAAALAAECgYIBgAAAA==.',['炸掉']='炸掉男厕所:BAAALAADCggIHgAAAA==.',['無惧']='無惧者丶无影:BAAALAAECgYIBwAAAA==.',['煽动']='煽动:BAABLAAFFH8GAAIIAAYI4RZbOgBYAQAIAAYI4RZbOgBYAQAAAA==.',['熊抱']='熊抱抚细腰:BAABLAAFFH8HAAIDAAUIMwQtIgCiAAADAAUIMwQtIgCiAAAAAA==.',['燕三']='燕三十娘:BAAALAAECgMIAwAAAA==.',['爱吃']='爱吃马卡龙:BAACLAAFFH82AAICAAcIbxstBwA6AgACAAcIbxstBwA6AgAsAAQKfx0AAgIACAjSH3YSAMcCAAIACAjSH3YSAMcCAAAA.',['牛啤']='牛啤:BAAALAADCgUIBQAAAA==.',['牛牛']='牛牛我很壮:BAAALAAFFAIIAgAAAA==.',['牛逼']='牛逼:BAACLAAFFH8cAAIIAAYIMBnpKQCMAQAIAAYIMBnpKQCMAQAsAAQKfyAAAggABwizDcPeAMAAAAgABwizDcPeAMAAAAAA.',['牛骑']='牛骑人圣头士:BAAALAADCgMIAwAAAA==.',['牛魔']='牛魔皇:BAAALAAECgcICQAAAA==.',['牧浮']='牧浮生:BAAALAADCgcIBwAAAA==.',['狂暴']='狂暴之刃刃:BAAALAADCgYICAAAAA==.狂暴之龙:BAAALAADCgQIAgAAAA==.狂暴血儿:BAAALAADCgcIBgAAAA==.',['狂雪']='狂雪:BAAALAADCgMIAwAAAA==.',['狐狸']='狐狸萨斯:BAAALAAECgYIBgAAAA==.',['狗贩']='狗贩子:BAAALAAECgcIBwAAAA==.',['猎物']='猎物是神子:BAAALAAECgYIBgAAAA==.',['猎风']='猎风小寒:BAABLAAFFH8GAAIIAAYIyhbZCQDvAQAIAAYIyhbZCQDvAQAAAA==.',['猛扯']='猛扯好翅膀:BAAALAAECgMIAwAAAA==.',['王都']='王都的巨神:BAAALAAECgYIBgAAAA==.',['玩的']='玩的无聊:BAAALAAECgYIBgAAAA==.',['玫瑰']='玫瑰是玫瑰:BAABLAAFFH8GAAIKAAQItxdWOgD1AAAKAAQItxdWOgD1AAAAAA==.',['瑟希']='瑟希恩丶霜脉:BAAALAAECgYICAAAAA==.',['生命']='生命缚誓者:BAAALAADCggIDQAAAA==.',['由乃']='由乃:BAAALAADCggICAAAAA==.',['留在']='留在你生命里:BAAALAAFFAIIAwAAAA==.',['疯不']='疯不觉:BAAALAAFFAYIBAAAAA==.',['疯子']='疯子冥泪:BAAALAAECgYIBgAAAA==.疯子晚餐:BAABLAAFFH8MAAITAAIIuxzPDgCUAAATAAIIuxzPDgCUAAAAAA==.',['疯狂']='疯狂猫咪:BAAALAAECgMIAwAAAA==.',['痛到']='痛到窒息:BAAALAAECgIIAgAAAA==.',['盲僧']='盲僧:BAABLAAFFH8FAAINAAIIkhzQRQBNAAANAAIIkhzQRQBNAAAAAA==.',['看我']='看我眼色行事:BAAALAAECgUIBQAAAA==.',['神罗']='神罗天征:BAAALAAECgYIEgAAAA==.',['离熵']='离熵十字:BAAALAAECgYIEQAAAA==.',['立花']='立花正仁:BAACLAAFFH8LAAMBAAIIBiL6SgClAAABAAIIBiL6SgClAAAZAAEIBAJ2IABAAAAsAAQKfxcAAwEABwi7JAQSAFkCAAEABwi7JAQSAFkCABkAAggzHqtOAHkAAAEsAAUUAwgOAAgA+B0A.',['童帝']='童帝结城结弦:BAABLAAECn8WAAMXAAgIkQ95QQCXAQAXAAgIkQ95QQCXAQAeAAYI2wWxMgCRAAAAAA==.',['笨拙']='笨拙:BAAALAADCggICAAAAA==.',['第六']='第六元素:BAABLAAFFH8KAAIHAAII2QkkZwBUAAAHAAII2QkkZwBUAAAAAA==.',['米兰']='米兰达小新星:BAAALAADCgYIBwAAAA==.',['米无']='米无敌:BAAALAAECgYICAAAAA==.',['米米']='米米尔龙:BAAALAAFFAIIAgAAAA==.',['糊糊']='糊糊精:BAABLAAFFH8NAAICAAgInhUyBwA6AgACAAgInhUyBwA6AgAAAA==.',['糯叽']='糯叽叽:BAAALAAECgYIAQAAAA==.',['索尔']='索尔格林:BAAALAAECgYIDAAAAA==.',['红丨']='红丨日:BAAALAAECgYIEQAAAA==.',['红墙']='红墙白雪:BAAALAAECgYIEQAAAA==.',['红头']='红头发魔鬼:BAACLAAFFH8KAAIIAAMIFBMccQB/AAAIAAMIFBMccQB/AAAsAAQKfzwAAwgABwiLH4s/AM0BAAgABwiLH4s/AM0BACAABgj2Dt1qABsBAAAA.',['红桃']='红桃:BAAALAAECgYIDwABLAAECgYIEgAUAAAAAA==.',['约克']='约克公爵:BAAALAAECgYIDQAAAA==.',['细雨']='细雨菲菲:BAAALAADCgIIAgAAAA==.',['绫小']='绫小路未来:BAAALAAECgYICwAAAA==.',['维兰']='维兰娜丶灵愈:BAAALAADCgUIBQAAAA==.',['绽放']='绽放时光深处:BAAALAAECgYICAAAAA==.',['缥缈']='缥缈星星:BAABLAAECn8ZAAIIAAYIugoZwQDsAAAIAAYIugoZwQDsAAAAAA==.',['罗宾']='罗宾丶妮可:BAABLAAFFH8QAAMhAAIIpyDFEACjAAAhAAIIfxjFEACjAAAYAAIIpyBnVABZAAAAAA==.',['羽裳']='羽裳:BAAALAADCgMIAwAAAA==.',['老实']='老实巴交:BAAALAAECgYIDAAAAA==.',['老猫']='老猫:BAABLAAFFH8PAAINAAMIkQ8hHgDXAAANAAMIkQ8hHgDXAAAAAA==.',['老男']='老男孩依旧酷:BAAALAADCgMIAwABLAAFFAgIBQATAEMdAA==.',['老魔']='老魔杖:BAAALAAECgIIAgAAAA==.',['聋人']='聋人:BAAALAAECgYIDQAAAA==.',['肌肉']='肌肉:BAAALAAFFAgIBAAAAA==.',['胖桃']='胖桃嗷嗷:BAAALAADCggICQAAAA==.',['脱离']='脱离猪圈的猪:BAAALAADCgcICgAAAA==.',['腐烂']='腐烂干预:BAAALAAECgYIBgAAAA==.',['至高']='至高岭大祭司:BAAALAADCgEIAQAAAA==.',['舞动']='舞动的旋律:BAAALAAECgYIDAAAAA==.',['艾姆']='艾姆谢特:BAAALAAECgYICQAAAA==.',['芭比']='芭比歪卜:BAAALAAECggIDQAAAA==.',['花凌']='花凌丶若别离:BAAALAAECgEIAQAAAA==.',['花花']='花花叉叉:BAAALAAFFAIIBAAAAA==.',['苏内']='苏内河:BAABLAAFFH8ZAAMKAAYIniIREgDpAQAKAAYIniIREgDpAQATAAIIign0GAB1AAAAAA==.',['苏小']='苏小寒:BAAALAAECgYIBgAAAA==.',['苏沫']='苏沫寒:BAAALAAECggIDgAAAA==.',['苏灼']='苏灼:BAACLAAFFH8IAAIHAAIIHxe4OQCNAAAHAAIIHxe4OQCNAAAsAAQKfx4AAgcACAg7HfojAIMCAAcACAg7HfojAIMCAAAA.',['若叶']='若叶睦:BAABLAAFFH8GAAIYAAYIOw0qMABYAQAYAAYIOw0qMABYAQAAAA==.',['苳洷']='苳洷:BAAALAAECgYICwAAAA==.',['荒天']='荒天骑:BAAALAAECgIIAgABLAAFFAcIOQAXAEsmAA==.',['荣耀']='荣耀的信仰:BAABLAAFFH8IAAINAAIIkg0QVABBAAANAAIIkg0QVABBAAAAAA==.',['荧光']='荧光棒:BAAALAAECgYIBwAAAA==.',['莉娜']='莉娜丶依巴斯:BAAALAADCgMIAwAAAA==.',['莉泽']='莉泽罗忒:BAAALAADCgYIBgAAAA==.',['莫高']='莫高雷牛哥:BAAALAADCggICAAAAA==.',['萨叔']='萨叔:BAABLAAFFH8TAAIHAAMIbRDRRACXAAAHAAMIbRDRRACXAAAAAA==.',['萨否']='萨否赖你:BAAALAAFFAUIBAAAAA==.',['萨满']='萨满炒菜:BAAALAAECgMIAwAAAA==.',['萨特']='萨特:BAAALAAECgMIAwAAAA==.',['萨鲁']='萨鲁法氪丶:BAABLAAFFH8IAAIBAAIIChuKPAC5AAABAAIIChuKPAC5AAAAAA==.',['葬靈']='葬靈魂:BAAALAAECgIIAgAAAA==.',['蒲公']='蒲公英奶茶:BAAALAAECgYIBgAAAA==.',['蒹葭']='蒹葭:BAAALAADCgYIBgAAAA==.',['虎妞']='虎妞儿:BAAALAADCgQIBAAAAA==.',['虾仁']='虾仁:BAAALAAFFAIIAgAAAA==.',['蛮大']='蛮大人:BAAALAAECgUIDAAAAA==.',['蜡烛']='蜡烛骑士:BAAALAADCgEIAQAAAA==.',['血染']='血染过的凶器:BAAALAAFFAIIBAABLAAFFAcINQAIACkZAA==.',['衣袂']='衣袂:BAAALAAECgYICQAAAA==.',['裂地']='裂地狅熊:BAAALAADCgMIAwAAAA==.',['西木']='西木:BAABLAAFFH8MAAIOAAMIOQrSQQCGAAAOAAMIOQrSQQCGAAAAAA==.',['要死']='要死的可爱:BAAALAAECgYICAAAAA==.',['誓约']='誓约胜利之剑:BAAALAAFFAEIAQAAAA==.',['讔靈']='讔靈:BAAALAAECgYIBgAAAA==.',['诡异']='诡异乂寒洋:BAAALAADCgIIAgAAAA==.',['诸神']='诸神的遗产:BAAALAADCgMIAwAAAA==.',['读来']='读来过倒才牛:BAACLAAFFH8UAAQNAAIIhSEqIwC2AAANAAIIhSEqIwC2AAAWAAEIIgsGCQBFAAAVAAIIYRk8KwA5AAAsAAQKfx0AAw0ABgjmIjI4AFQCAA0ABgikIjI4AFQCABYABAj5HE0aAFEBAAAA.读来过倒才犇:BAACLAAFFH8IAAIPAAIIgxKhEgCEAAAPAAIIgxKhEgCEAAAsAAQKfxQAAg8ABgh9HIYQAJ0BAA8ABgh9HIYQAJ0BAAAA.',['谢无']='谢无敌冉宝宝:BAAALAADCgIIAgAAAA==.',['谨年']='谨年丶:BAAALAAECgMIAwAAAA==.',['贝萨']='贝萨:BAAALAAFFAMIAwAAAA==.',['贝西']='贝西西:BAAALAAFFAIIAwAAAA==.',['贫僧']='贫僧法号能抗:BAAALAAECgYICQAAAA==.',['赤岩']='赤岩丶戈隆:BAAALAAECgYIBgAAAA==.',['赤明']='赤明:BAABLAAFFH8LAAIRAAYIdQVRFAD+AAARAAYIdQVRFAD+AAAAAA==.',['超级']='超级凶:BAAALAAECgYIBwAAAA==.超级耐射王:BAAALAAECgYIBgAAAA==.',['蹲厕']='蹲厕观蛆戏水:BAABLAAECn8VAAMYAAgI6AyOOgBeAQAYAAgI6AyOOgBeAQAhAAYILQJYewCNAAAAAA==.',['轻熟']='轻熟德:BAAALAAFFAIIAgAAAA==.',['辛德']='辛德穆拉丶:BAACLAAFFH8UAAIHAAIIEwz4YgBYAAAHAAIIEwz4YgBYAAAsAAQKfxcAAgcABggWFHiYAE0BAAcABggWFHiYAE0BAAEsAAUUCAgKAAcA7hoA.',['迷人']='迷人的小迷迷:BAACLAAFFH8OAAQFAAYI9hSOGwByAQAFAAUI8ReOGwByAQAEAAIISATuBABlAAAGAAEIXxesJABTAAAsAAQKfyAAAwQABwiHGngNANIBAAQABgjSGngNANIBAAUABwhbFNcrAFoBAAAA.',['追萧']='追萧:BAAALAAECgYIBgAAAA==.',['退堂']='退堂的鼓:BAAALAAECgYIBgAAAA==.',['逆鳞']='逆鳞无常:BAAALAAFFAIIBAAAAA==.',['那年']='那年的梦想:BAAALAADCgYIBgAAAA==.',['酱油']='酱油快跑:BAAALAAECgYIDAAAAA==.',['野蛮']='野蛮的圣光:BAAALAAECgYIDAAAAA==.',['釒九']='釒九七:BAABLAAFFH8KAAIBAAYILSDuGwDGAQABAAYILSDuGwDGAQAAAA==.',['钟宝']='钟宝儿:BAAALAADCgYIBgAAAA==.',['铁头']='铁头功:BAAALAAFFAIIAgAAAA==.',['锅碗']='锅碗瓢盆缸:BAAALAAFFAIIBAAAAA==.',['锦鲤']='锦鲤:BAAALAAECgYIDAAAAA==.',['长崎']='长崎素世:BAABLAAFFH8YAAIYAAYIKROdKAB3AQAYAAYIKROdKAB3AQAAAA==.',['闇之']='闇之子:BAABLAAFFH8KAAIOAAIIICFTJgDFAAAOAAIIICFTJgDFAAABLAAFFAgIBgAiAPEJAA==.',['闪电']='闪电五连缏:BAAALAAECgYIDQAAAA==.',['闪闪']='闪闪的阿喵:BAAALAAECgYIBgAAAA==.',['阁楼']='阁楼小飞人:BAAALAADCgIIAgAAAA==.',['阳光']='阳光下的小猪:BAAALAAECgQIBAAAAA==.',['阿不']='阿不一:BAAALAAECgYICQAAAA==.',['阿卡']='阿卡:BAAALAADCgIIAgAAAA==.',['阿殇']='阿殇小刀:BAABLAAFFH8GAAIYAAYIPhzeCAAwAgAYAAYIPhzeCAAwAgAAAA==.',['阿浩']='阿浩有德:BAAALAAECgYIBgAAAA==.',['阿米']='阿米伽月光:BAAALAADCgYIBgAAAA==.',['阿要']='阿要辣油啊冫:BAABLAAFFH8RAAIYAAYIqwfHQQDhAAAYAAYIqwfHQQDhAAAAAA==.',['阿达']='阿达兽:BAAALAAECgYIDQAAAA==.',['阿雅']='阿雅达:BAAALAADCgMIAwAAAA==.',['陈无']='陈无敌:BAAALAAECgYICQAAAA==.',['雪儿']='雪儿萌宝:BAAALAAECgYIDAAAAA==.',['雪祤']='雪祤:BAABLAAECn8dAAIVAAYIBhPuSQBZAQAVAAYIBhPuSQBZAQAAAA==.',['雷勃']='雷勃:BAACLAAFFH9LAAIVAAcIhB2fAgAtAgAVAAcIhB2fAgAtAgAsAAQKfykABBUACAgfHwYUAJMCABUACAgfHwYUAJMCAA0ABgj4EDGTAF8BABYABgi2Dv8aAEoBAAAA.',['雷答']='雷答耶:BAAALAADCgEIAgAAAA==.',['靇竉']='靇竉龍:BAAALAADCgQIBAAAAA==.',['青歌']='青歌:BAAALAAFFAIIAgAAAA==.',['面向']='面向大海:BAAALAAFFAIIAgAAAA==.',['颲靈']='颲靈:BAAALAAECgUIBQAAAA==.',['风之']='风之舞:BAAALAADCgIIAgAAAA==.',['飘落']='飘落的孤心:BAAALAADCgYIBgAAAA==.',['飞鱼']='飞鱼:BAACLAAFFH8dAAIeAAUIPQY/DQC0AAAeAAUIPQY/DQC0AAAsAAQKfywAAx4ACAhBEeUfABEBAB4ABwjpD+UfABEBABcACAgDCfGYAM4AAAAA.',['饱饱']='饱饱你看它吖:BAAALAAECgQIBAAAAA==.',['香蕉']='香蕉不呐呐:BAAALAAECgEIAQAAAA==.',['魔法']='魔法小龟:BAABLAAFFH8MAAIKAAYINiOiAgCHAgAKAAYINiOiAgCHAgAAAA==.',['魔王']='魔王壹号:BAAALAAFFAEIAQAAAA==.',['魔鬼']='魔鬼斩杀者:BAAALAADCggIDgAAAA==.',['鷄亀']='鷄亀骨滾羹丨:BAAALAAECggIDgAAAA==.',['麻美']='麻美老师:BAAALAAFFAIIAgAAAA==.麻美老湿:BAAALAAECgYICAAAAA==.',['黑暗']='黑暗之翼:BAAALAAECggICAAAAA==.',['黑牛']='黑牛陆七八:BAAALAAECgcIDwAAAA==.',['龙皇']='龙皇异次元:BAAALAAECggIEgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end