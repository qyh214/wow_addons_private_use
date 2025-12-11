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
 local lookup = {'DemonHunter-Havoc','Warrior-Fury','Warlock-Destruction','Paladin-Protection','Mage-Arcane','Paladin-Retribution','Paladin-Holy','DeathKnight-Frost','DeathKnight-Blood','Monk-Windwalker','Monk-Brewmaster','Evoker-Preservation','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Shaman-Elemental','Rogue-Assassination','Warlock-Affliction','Warlock-Demonology','Druid-Balance','Unknown-Unknown','Druid-Restoration','DeathKnight-Unholy','Warrior-Protection',}; local provider = {region='CN',realm='伊森德雷',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bl='Blu:BAAALAAECgYICwAAAA==.',Fr='Freeman:BAAALAAECgYIBgAAAA==.',Ja='Jacding:BAAALAAECgIIAgAAAA==.',Le='Leesin:BAAALAAFFAIIAgAAAA==.Lemon:BAAALAAECgYIBgAAAA==.',Mi='Miya:BAAALAAFFAIIAgAAAA==.',Mo='Moiros:BAABLAAECn8UAAIBAAgIdRSnWwAUAgABAAgIdRSnWwAUAgAAAA==.',Pu='Purist:BAAALAAECgYICwAAAA==.',Ti='Titsflow:BAABLAAFFH8IAAICAAIIzCM2PwBlAAACAAIIzCM2PwBlAAABLAAFFAMIBwADADYgAA==.',Wa='Wadewang:BAAALAAECgYIBgAAAA==.Warme:BAABLAAFFH8GAAIEAAIIFSMDCgDHAAAEAAIIFSMDCgDHAAAAAA==.Warmee:BAAALAAECgYIBgAAAA==.',['一圣']='一圣斗士一:BAAALAADCgEIAQAAAA==.',['一块']='一块二:BAAALAAECgEIAQAAAA==.',['一起']='一起看风景:BAAALAADCgQIBAAAAA==.',['七夜']='七夜篁:BAABLAAFFH8IAAIFAAIIPRjMUwCNAAAFAAIIPRjMUwCNAAAAAA==.',['丧彪']='丧彪兄:BAAALAAECgQIBAAAAA==.',['丶丶']='丶丶教父:BAAALAAECgcIDQAAAA==.',['丶五']='丶五两:BAAALAAFFAMIAwAAAA==.',['丶盛']='丶盛夏:BAAALAAECgQIBAAAAA==.',['乐咚']='乐咚弯德汹:BAAALAAECgMIAwAAAA==.',['九宫']='九宫格肥:BAABLAAFFH8GAAMGAAIIgwnsVQCMAAAGAAIIgwnsVQCMAAAHAAIIjgnJIQCDAAAAAA==.',['五蕴']='五蕴皆空:BAAALAAECgUIBQAAAA==.',['今天']='今天就放假:BAAALAAFFAIIBAAAAA==.',['体柔']='体柔:BAAALAAECgYICQAAAA==.',['你压']='你压我头发了:BAAALAAFFAMIAwAAAA==.',['你好']='你好卡基尔哦:BAAALAAFFAIIAgAAAA==.',['保洁']='保洁小妹:BAAALAAECgEIAQAAAA==.',['偷偷']='偷偷发育:BAAALAAECgQIBAAAAA==.',['傲娇']='傲娇丶玉人:BAAALAAECgYIBgAAAA==.',['克里']='克里斯蒂亚诺:BAAALAAECgQIBAAAAA==.',['关海']='关海法:BAAALAAECgMIAwAAAA==.',['冰双']='冰双皮奶:BAABLAAFFH8HAAIIAAMIUBaiQwCuAAAIAAMIUBaiQwCuAAAAAA==.',['剑心']='剑心犹在:BAAALAAECgYIBgAAAA==.',['劣质']='劣质的人:BAAALAAECgMIAwAAAA==.',['勥龍']='勥龍:BAAALAAFFAYIAwAAAA==.',['卡雷']='卡雷莉斯冰歌:BAABLAAFFH8NAAMJAAgIhB6JAQClAgAJAAgITx6JAQClAgAIAAUIlxo+PwA+AQAAAA==.',['口口']='口口:BAAALAAECgMIAwAAAA==.',['叮咯']='叮咯咙咚呛:BAAALAAECgcIEQAAAA==.',['君麻']='君麻吕:BAAALAAECgYIBgAAAA==.',['哭泣']='哭泣的萱萱:BAAALAADCggICAAAAA==.',['喜欢']='喜欢半路逃跑:BAAALAAECgYICwAAAA==.',['嘴角']='嘴角丶微弯:BAAALAADCgYIBgAAAA==.',['圣殿']='圣殿穷骑士:BAACLAAFFH8FAAIHAAMI+w+WEADcAAAHAAMI+w+WEADcAAAsAAQKfyUAAwcACAgcFkUPAP0BAAcACAgcFkUPAP0BAAYACAhLE+w6AKwBAAAA.',['地狱']='地狱小猎:BAAALAAECgEIAQAAAA==.',['地獄']='地獄小牛:BAAALAADCgQIBAAAAA==.',['外马']='外马尔:BAAALAAECgYIBAAAAA==.',['夜神']='夜神舞:BAAALAAECgMIAwAAAA==.',['大象']='大象一二三一:BAABLAAFFH8NAAMKAAUIQAUpEwBgAAAKAAII+wEpEwBgAAALAAMIbgd1GwBaAAAAAA==.大象三零六三:BAABLAAFFH8JAAIMAAQILhSGEwDVAAAMAAQILhSGEwDVAAAAAA==.大象九五二七:BAABLAAFFH8NAAMNAAUImxHBUwAAAQANAAUI8w/BUwAAAQAOAAII+Bf+HwCJAAAAAA==.大象五二六九:BAABLAAFFH8VAAMPAAUIIxIyJwApAQAPAAUIIxIyJwApAQAQAAIIwADTPABKAAAAAA==.大象八八四八:BAAALAAECgMIAwAAAA==.',['大青']='大青丘:BAABLAAFFH8FAAIBAAMIwgMgZQA7AAABAAMIwgMgZQA7AAAAAA==.',['天下']='天下无贼:BAABLAAFFH8GAAIRAAYIGxDMCQB4AQARAAYIGxDMCQB4AQAAAA==.',['天地']='天地浪子:BAAALAAECgEIAQAAAA==.',['天灰']='天灰的像哭过:BAAALAAFFAIIAgAAAA==.',['奥瑟']='奥瑟兰:BAACLAAFFH8VAAIIAAMIngsqZACEAAAIAAMIngsqZACEAAAsAAQKfzcAAggACAiRGasoANMBAAgACAiRGasoANMBAAAA.',['奶到']='奶到栈溢出:BAAALAAFFAMIAwAAAA==.',['妖刀']='妖刀姬:BAAALAADCggICAAAAA==.',['妲己']='妲己:BAAALAADCggICAAAAA==.',['威尔']='威尔士:BAAALAAECgYIBwAAAA==.',['娜璐']='娜璐璐:BAAALAAECgYIBgABLAAFFAcIHQANAJsiAA==.',['小天']='小天丶战:BAAALAAECgMIBAAAAA==.',['小红']='小红人练习生:BAABLAAFFH8KAAIIAAII/B5VcwBNAAAIAAII/B5VcwBNAAAAAA==.',['小菜']='小菜鸡:BAAALAAECggICAAAAA==.',['小西']='小西皮:BAABLAAFFH8FAAICAAUILwElZwAMAAACAAUILwElZwAMAAAAAA==.',['尤型']='尤型玩物:BAACLAAFFH8+AAQDAAcI0BR3FwDOAQADAAcI0BR3FwDOAQASAAIIRgfpBACQAAATAAEIyBKAKABPAAAsAAQKfyYABAMACAiEHswjALoCAAMACAiEHswjALoCABMABggxEnxDAGABABIAAQjzBsQ/ADsAAAAA.',['岂因']='岂因:BAAALAAECgIIAgAAAA==.',['希伊']='希伊葉:BAAALAAECgYIBgAAAA==.',['年少']='年少欢愉:BAAALAAECgYIBgAAAA==.',['張敏']='張敏:BAABLAAFFH8FAAINAAMIxgvxfwBWAAANAAMIxgvxfwBWAAAAAA==.',['弹弹']='弹弹球:BAABLAAFFH8GAAIPAAIIWhRMRgB3AAAPAAIIWhRMRgB3AAAAAA==.',['当归']='当归:BAAALAADCgQIBAAAAA==.',['心猿']='心猿意马:BAAALAAFFAIIBAAAAA==.',['忘忘']='忘忘小牧:BAAALAAECgMIBAAAAA==.忘忘小萨:BAAALAAECgYIEQAAAA==.',['怒风']='怒风:BAAALAAFFAIIBAAAAA==.怒风灬记忆:BAAALAAFFAIIAgAAAA==.',['恶魔']='恶魔丨猎手:BAAALAAFFAIIAgAAAA==.',['惜夏']='惜夏:BAABLAAFFH8GAAIUAAYIPwSXDAA2AQAUAAYIPwSXDAA2AQABLAAECgcIEwAVAAAAAA==.',['愿圣']='愿圣光照死你:BAAALAAFFAIIAgAAAA==.',['我的']='我的减伤队友:BAABLAAFFH8GAAICAAIIqhXTLgCgAAACAAIIqhXTLgCgAAAAAA==.',['无敌']='无敌金钟罩:BAAALAAECgEIAQAAAA==.',['暴牙']='暴牙妹:BAAALAAECgcIEgAAAA==.',['月亮']='月亮战神:BAAALAAECgYIBgAAAA==.',['月希']='月希:BAABLAAFFH8PAAITAAUIQRTJAwA5AQATAAUIQRTJAwA5AQAAAA==.',['木帆']='木帆桨:BAAALAAFFAIIAgAAAA==.木帆船:BAAALAAECggIEQAAAA==.',['术爷']='术爷有专攻:BAABLAAFFH8GAAIDAAYILSNuBABxAgADAAYILSNuBABxAgAAAA==.',['李晓']='李晓璐:BAAALAADCgMIAwAAAA==.',['某只']='某只暴力熊:BAACLAAFFH8PAAIIAAIIUyJFSQCnAAAIAAIIUyJFSQCnAAAsAAQKfxYAAggABggFIc8yAKwBAAgABggFIc8yAKwBAAEsAAUUAwgHAAMANiAA.',['榴莲']='榴莲糖:BAAALAADCgMIAwAAAA==.',['此牛']='此牛不卖:BAAALAADCgMIAwAAAA==.',['死亡']='死亡骑手:BAAALAAFFAIIBAAAAA==.',['毛人']='毛人猎:BAAALAAECgMIAwAAAA==.毛人骑:BAAALAAECgQIBAAAAA==.',['水枪']='水枪装尿:BAAALAAECgYIBgAAAA==.',['水蓝']='水蓝天空:BAAALAAECgMIAwAAAA==.',['洗洗']='洗洗睡了:BAABLAAECn8YAAINAAYIaCGDNwDkAQANAAYIaCGDNwDkAQAAAA==.',['淡定']='淡定丨影之伤:BAAALAAECgMIAwAAAA==.',['清静']='清静丨親静:BAAALAAECgYIEwAAAA==.',['滞腐']='滞腐:BAAALAAECgYIBgAAAA==.',['火雪']='火雪翼:BAAALAAECgIIAgAAAA==.',['灬土']='灬土豆灬:BAAALAAECgUIBgAAAA==.',['灬癫']='灬癫佬:BAAALAADCgMIAwAAAA==.',['灬皮']='灬皮皮虾灬:BAAALAAECggIEwAAAA==.',['烈焰']='烈焰之击:BAAALAAECgYICwAAAA==.',['烮天']='烮天:BAAALAAECgIIAgAAAA==.',['爱莉']='爱莉希雅:BAAALAAFFAIIAwAAAA==.',['爲誰']='爲誰瘋誑:BAAALAAECgMIAwAAAA==.',['牛牛']='牛牛:BAAALAAFFAIIAgAAAA==.',['牛面']='牛面兽心:BAAALAADCgIIAgAAAA==.',['牜氵']='牜氵扌忄:BAAALAAECgMIAgAAAA==.',['牧云']='牧云清歌:BAACLAAFFH8LAAIWAAMI1hQkFADWAAAWAAMI1hQkFADWAAAsAAQKfxgAAhYABgjkJCQWAB8CABYABgjkJCQWAB8CAAAA.',['牧有']='牧有鱼丸:BAAALAAFFAIIAgAAAA==.',['狂暴']='狂暴的蚂蚁:BAAALAADCgEIAQAAAA==.',['狂飙']='狂飙:BAABLAAECn8VAAMOAAgI8iN+EADgAgAOAAgI8iN+EADgAgANAAYINCMPQABmAgAAAA==.',['猎码']='猎码糕手:BAABLAAECn8VAAMIAAcIoyQKIwDjAgAIAAcIoyQKIwDjAgAXAAYIlRwNKwBpAQAAAA==.',['猎贼']='猎贼六:BAABLAAFFH8HAAINAAII6yFeLwDIAAANAAII6yFeLwDIAAAAAA==.',['獣堺']='獣堺仏潪:BAAALAAECgYIBgAAAA==.',['王与']='王与马共天下:BAAALAAECgcIBwAAAA==.',['玩什']='玩什么呢啊:BAAALAAECgIIAgAAAA==.',['瑞特']='瑞特让他:BAAALAADCgcIBwAAAA==.',['瑟琳']='瑟琳纳斯:BAAALAADCgEIAQAAAA==.',['白露']='白露向喜:BAABLAAFFH8FAAIYAAUI9wf5GADaAAAYAAUI9wf5GADaAAAAAA==.',['皮皮']='皮皮好好看:BAAALAAFFAIIAgAAAA==.',['瞪你']='瞪你咋滴:BAACLAAFFH8IAAIDAAII3g9hQACXAAADAAII3g9hQACXAAAsAAQKfxsAAwMABwjNHVwwAHsCAAMABwhCHVwwAHsCABIAAggBH5wrAJAAAAAA.',['磁暴']='磁暴步兵:BAAALAAECgYIBgABLAAFFAIIAgAVAAAAAA==.',['福贵']='福贵儿:BAAALAADCgYIBgAAAA==.',['离析']='离析:BAAALAAECgcIEwAAAA==.',['窋差']='窋差一下:BAAALAAECgIIAgAAAA==.',['米小']='米小新丶:BAAALAAECgMIAwAAAA==.',['紫梦']='紫梦雨露:BAAALAADCgEIAQAAAA==.',['红豆']='红豆汤包:BAABLAAFFH8OAAIFAAIIdRbkTQCTAAAFAAIIdRbkTQCTAAAAAA==.',['纯白']='纯白丶:BAAALAAFFAIIBAAAAA==.',['给牛']='给牛牛乐一个:BAAALAADCgEIAQAAAA==.',['绝地']='绝地之亡:BAABLAAFFH8IAAIIAAMIcApzYwCFAAAIAAMIcApzYwCFAAAAAA==.',['绿番']='绿番茄灬:BAAALAADCgcIBwAAAA==.',['罗纳']='罗纳尔少:BAACLAAFFH8HAAIDAAMINiAfSACdAAADAAMINiAfSACdAAAsAAQKfyAAAwMACAjSHZ4cAP4BAAMACAjSHZ4cAP4BABMABQgyFYRJAEsBAAAA.',['聖珖']='聖珖:BAAALAAECgQIBAABLAAFFAMICQACABcQAA==.',['胖大']='胖大牛:BAABLAAFFH8GAAIYAAYI6B7qCQCjAQAYAAYI6B7qCQCjAQAAAA==.',['花散']='花散里:BAAALAAECgYIDAAAAA==.',['苦橙']='苦橙丶:BAAALAAFFAIIAwAAAA==.',['苦的']='苦的盐焗银杏:BAAALAADCgYIBgAAAA==.',['莫负']='莫负韶华:BAAALAAECgUICgAAAA==.',['萨哈']='萨哈达尔:BAAALAAECgcIBwAAAA==.',['落花']='落花淡煙雨:BAAALAAECgYIDAAAAA==.',['藏剑']='藏剑天涯:BAAALAAECgUIBQAAAA==.',['蛋奶']='蛋奶:BAABLAAFFH8MAAIWAAIIcg6kRQBjAAAWAAIIcg6kRQBjAAAAAA==.',['血翼']='血翼:BAAALAAECggIEQAAAA==.',['要乃']='要乃没有德:BAAALAAECgIIAgAAAA==.',['诋調']='诋調佐墓:BAAALAAECgYIBwAAAA==.',['请勿']='请勿抚摸投食:BAAALAAECgYIBgAAAA==.',['豪情']='豪情万丈:BAACLAAFFH8JAAIWAAIIwRJUNQBrAAAWAAIIwRJUNQBrAAAsAAQKfyUAAhYACAhfHn0gAG0CABYACAhfHn0gAG0CAAAA.',['贝欣']='贝欣:BAAALAAECgYIBgAAAA==.',['越女']='越女侠:BAAALAAECgYIDwAAAA==.',['迎风']='迎风鸟千里:BAAALAAECgMIAwAAAA==.',['迪凯']='迪凯拉克:BAAALAAECgIIAgAAAA==.',['迷迷']='迷迷糊糊:BAAALAADCgIIAgAAAA==.',['酒井']='酒井麻衣:BAAALAAECggICAAAAA==.',['钵钵']='钵钵鸡:BAAALAAECgIIAgAAAA==.',['铁柱']='铁柱:BAAALAAECgYIBgAAAA==.',['铭刻']='铭刻诺言:BAAALAAECgYIDwAAAA==.',['阿萌']='阿萌:BAAALAADCggICAAAAA==.',['雪糕']='雪糕糊你脸:BAACLAAFFH8tAAIDAAcIpyPIBQBcAgADAAcIpyPIBQBcAgAsAAQKfy8AAgMACAgKJgIFAG4DAAMACAgKJgIFAG4DAAAA.',['雾夜']='雾夜圣光:BAABLAAFFH8IAAIGAAQI1RLcNADaAAAGAAQI1RLcNADaAAAAAA==.雾夜殇:BAAALAAECggIDgAAAA==.',['霖海']='霖海丶牧野:BAAALAAFFAEIAQAAAA==.',['非凡']='非凡牧羊人:BAAALAAECgYIBgAAAA==.',['飙龙']='飙龙妙影:BAAALAAFFAIIBAAAAA==.',['飞卫']='飞卫:BAABLAAFFH8GAAINAAYIDw3GQQBBAQANAAYIDw3GQQBBAQAAAA==.',['鬼泣']='鬼泣丶:BAABLAAFFH8GAAIYAAII3BKXHACGAAAYAAII3BKXHACGAAAAAA==.',['鸡翅']='鸡翅包饭:BAAALAADCgIIAgAAAA==.',['黑怒']='黑怒劳乖:BAAALAAFFAIIAgAAAA==.',['黙認']='黙認幸福:BAAALAAECgYIDAAAAA==.',['龙之']='龙之殇荷鲁斯:BAAALAAFFAIIBAAAAA==.',['龙舌']='龙舌兰:BAAALAAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end