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
 local lookup = {'Warlock-Demonology','Warlock-Affliction','Mage-Fire','Mage-Arcane','Mage-Frost','Warlock-Destruction','Warrior-Arms','Druid-Balance','Druid-Restoration','Druid-Guardian','DeathKnight-Unholy','Paladin-Retribution','Shaman-Enhancement','Shaman-Restoration','Shaman-Elemental','Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','Druid-Feral','DeathKnight-Frost','Priest-Holy','Priest-Shadow','Rogue-Assassination','Rogue-Subtlety','Paladin-Protection','DeathKnight-Blood','Warrior-Fury','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Paladin-Holy','Warrior-Protection','Unknown-Unknown','Priest-Discipline','Rogue-Outlaw','Evoker-Devastation',}; local provider = {region='CN',realm='地狱之石',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Allendk:BAAAKgAFFAQIBAAAAA==.',Ar='Arleighburke:BAAAKgAECgEIAQAAAA==.',Bo='Bottleln:BAABKgAFFH8IAAMBAAQIOBLKBQDaAAACAAQIMRH2CADiAAABAAQIxg7KBQDaAAAAAA==.Bottlelnn:BAACKgAFFH8kAAQDAAgIJh3uCACyAQADAAYIwx3uCACyAQAEAAYIMhQBEABsAQAFAAMITRUqDQC2AAAqAAQKfzoABAMACAipIKIWAGwCAAMACAiRIKIWAGwCAAQABAh8HSQZAGUBAAUABgj/IF5HAEgBAAAA.',Ca='Caoguiruisb:BAABKgAFFH8HAAMGAAYIHxMkFwBKAQAGAAYIHxMkFwBKAQABAAEIAAAJJQAAAAAAAA==.',Co='Colorful:BAAAKgAFFAEIAQAAAA==.',Cr='Crushon:BAACKgAFFH8sAAIHAAQIzhRhCgDJAAAHAAQIzhRhCgDJAAAqAAQKf1AAAgcACAgWH4gJAHgCAAcACAgWH4gJAHgCAAAA.',Da='Dawn:BAAAKgAFFAIIAgAAAA==.',De='Decondestiny:BAAAKgAECgcIBwAAAA==.',Di='Disciple:BAAAKgAECgYIBgAAAA==.',Do='Dogthing:BAAAKgAECggICAAAAA==.',Dr='Dragon:BAAAKgAECgcIBwAAAA==.',Eu='Euphoria:BAACKgAFFH8uAAMIAAgI7hfRCQD4AQAIAAgI7hfRCQD4AQAJAAIIGQ6WGAB4AAAqAAQKfycABAgACAi3Ij8PAK0CAAgACAi3Ij8PAK0CAAkAAwhUFA9TAMEAAAoAAgi8CxsqAFQAAAAA.',Gr='Grit:BAABKgAFFH8JAAILAAMIwQ15FgCzAAALAAMIwQ15FgCzAAAAAA==.',La='Lala:BAABKgAFFH8TAAIMAAYITR/PEAARAQAMAAYITR/PEAARAQABKgAFFAgICgAMAK0lAA==.',Le='Lemondonk:BAACKgAFFH8fAAQNAAUIBCBsAwBvAQANAAUIBCBsAwBvAQAOAAQIYwuZFwDHAAAPAAQIqxMzHQCPAAAqAAQKfz8AAw0ACAibJCgEANsCAA0ACAibJCgEANsCAA8AAQgAAD+GAAAAAAAA.',Li='Littletiger:BAAAKgADCggICAAAAA==.',Ma='Magicmax:BAAAKgAECgEIAQAAAA==.Mansonlol:BAAAKgAECgcIBwAAAA==.Maxgic:BAAAKgAECggICAAAAA==.',Mi='Missa:BAAAKgADCggICAAAAA==.',Mo='Moneybags:BAAAKgAECgUIBQAAAA==.',Ol='Olina:BAAAKgAFFAQIBAAAAA==.',Pa='Parisboy:BAAAKgAECggICQAAAA==.',Pl='Playerhzjrbr:BAAAKgADCgEIAQAAAA==.',Pu='Pudding:BAAAKgAECgYIEwAAAA==.',Re='Reda:BAACKgAFFH8oAAMQAAQInyHKDgANAQAQAAQInyHKDgANAQARAAEIwA+fWwBAAAAqAAQKfy8AAxAACAgPJMgRAEYCABAACAgPJMgRAEYCABEABwjQFO6uAMYAAAAA.',['Ré']='Régionalsace:BAAAKgAECgYIBgAAAA==.',Sa='Saipan:BAAAKgADCgYIBgAAAA==.',Se='Seiyamonk:BAAAKgAECgYIBgAAAA==.',Sh='Shersonw:BAAAKgAECgcIBwAAAA==.',Su='Sunshinewind:BAAAKgADCgEIAQAAAA==.',To='Tobacc:BAABKgAFFH8IAAISAAgI0gpyCgDLAQASAAgI0gpyCgDLAQAAAA==.',Va='Varied:BAACKgAFFH8gAAQIAAQIGSCoEwDsAAATAAMIGSBFBQDsAAAIAAQIeR2oEwDsAAAKAAEIah3RBQBQAAAqAAQKfyoABRMACAg+I/wJAPIBABMACAgFHPwJAPIBAAgABAikID8aAIMBAAoAAwihIXMbABcBAAkAAQg7CyOIADAAAAAA.',['一见']='一见到你:BAAAKgADCgcIBwAAAA==.',['一誓']='一誓灬者一:BAAAKgAECgYIBgAAAA==.',['万物']='万物初始之风:BAAAKgAECgYICgAAAA==.',['三千']='三千哆哆:BAAAKgAECgEIAQAAAA==.',['三开']='三开战猎萨:BAAAKgAECgIIAgAAAA==.',['丨使']='丨使徒行者:BAAAKgADCgEIAgAAAA==.',['丨旒']='丨旒歆丨:BAABKgAFFH8KAAIGAAcIrgNsEQAbAQAGAAcIrgNsEQAbAQAAAA==.',['丨阿']='丨阿尒萨斯丨:BAAAKgAECgUIBwAAAA==.',['九万']='九万多:BAAAKgAECgYIBgAAAA==.',['九寒']='九寒丶:BAABKgAECn8nAAIUAAgIsh/CBgBcAgAUAAgIsh/CBgBcAgAAAA==.',['五十']='五十强:BAAAKgADCgcIBwAAAA==.',['五月']='五月:BAAAKgAECggICAAAAA==.',['京常']='京常飞盾:BAAAKgAFFAQIAgAAAA==.',['什么']='什么都没川:BAAAKgADCgUIBQAAAA==.',['任五']='任五郎:BAAAKgAECgMIAwAAAA==.',['任幼']='任幼稚:BAAAKgAECgMIAwAAAA==.',['伊克']='伊克蕾尔:BAAAKgAECgMIAwAAAA==.',['余客']='余客:BAAAKgAFFAQIBAAAAA==.',['你是']='你是我的眼儿:BAAAKgAECgEIAQAAAA==.',['倒满']='倒满:BAAAKgAECggICAAAAA==.',['元気']='元気漫漫丶:BAAAKgAECgUICgAAAA==.',['元素']='元素丶夢魇:BAAAKgADCgEIAQAAAA==.元素天罡:BAAAKgAECgYIBgAAAA==.元素寂灭:BAABKgAFFH8aAAQPAAYILx+DBwBkAQANAAYIQx4DBgCeAQAOAAYIsBqACwCQAQAPAAUIKxmDBwBkAQAAAA==.',['元龙']='元龙战魂:BAABKgAFFH8LAAIIAAMIfAj4IgCgAAAIAAMIfAj4IgCgAAAAAA==.',['克兰']='克兰蒂尔:BAABKgAFFH8PAAIMAAYIRCEJAQD3AQAMAAYIRCEJAQD3AQAAAA==.',['克雷']='克雷诺:BAAAKgAFFAMIAwAAAA==.',['八万']='八万多:BAABKgAFFH8MAAMRAAgI2RTsBgAWAgARAAgI2RTsBgAWAgAQAAEIAAB0WQAAAAAAAA==.',['八音']='八音浩日:BAAAKgAFFAQIBAAAAA==.',['六親']='六親不認:BAAAKgAECgMIAwAAAA==.',['凯瑟']='凯瑟琳娜:BAAAKgAFFAIIAgAAAA==.',['凶梦']='凶梦的残影:BAABKgAFFH8JAAMNAAMIWRBcEwC8AAANAAMIWRBcEwC8AAAOAAEIkwJEOAA0AAAAAA==.',['刁蛮']='刁蛮公主:BAAAKgAECgEIAQAAAA==.',['刘富']='刘富贵:BAABKgAFFH8IAAIQAAYIqCLrCQC4AQAQAAYIqCLrCQC4AQAAAA==.',['别笑']='别笑打劫呐:BAAAKgADCgQIBwAAAA==.',['劣人']='劣人一个:BAAAKgADCgIIAgAAAA==.',['北京']='北京胖爷:BAAAKgAECgUIBQAAAA==.',['千年']='千年丨饕餮:BAAAKgAECgUIBQAAAA==.',['南风']='南风知我意:BAABKgAECn8VAAMVAAgIthsoDQC4AQAVAAgIthsoDQC4AQAWAAEIAABZhAAAAAAAAA==.',['发哥']='发哥嘎嘎棒:BAAAKgAECgcIBwAAAA==.',['口吐']='口吐莲花:BAAAKgAECgEIAQABKgAFFAgISgANAEMWAA==.',['司马']='司马天命:BAACKgAFFH83AAMXAAgIjg+wDACCAQAXAAcIFxGwDACCAQAYAAYI1Q5/AgAgAQAqAAQKfzYAAxcACAiIIOsCAJUCABcACAiQH+sCAJUCABgACAiRHQgBAGoCAAAA.',['吃我']='吃我劈头灵:BAABKgAECn8VAAIUAAgIrxf5CgD2AQAUAAgIrxf5CgD2AQAAAA==.',['吧嗒']='吧嗒嘣:BAAAKgAFFAQIBAAAAA==.',['呆物']='呆物丶:BAABKgAECn8cAAMMAAgIOB8IFwAPAgAMAAgIOB8IFwAPAgAZAAEIXA36IwArAAAAAA==.',['呼哈']='呼哈一声吼:BAABKgAFFH8IAAISAAQIcBITFwDmAAASAAQIcBITFwDmAAABKgAFFAgIDQAMAJEVAA==.',['哎呀']='哎呀丶吱吱:BAAAKgAECgQIBwAAAA==.哎呀丶揶揄:BAAAKgADCgIIAgAAAA==.',['嗜血']='嗜血大胖:BAAAKgADCgQIBgAAAA==.',['嘿嘿']='嘿嘿哎嘿嘿:BAABKgAFFH8GAAIaAAYIjAP1CwDjAAAaAAYIjAP1CwDjAAAAAA==.',['四岁']='四岁就很拽:BAAAKgAECgIIAgAAAA==.',['四葉']='四葉:BAAAKgADCgQIBAAAAA==.',['回复']='回复术:BAAAKgAECggIDAAAAA==.',['国安']='国安牛逼:BAAAKgAECgYIDwAAAA==.',['圣枪']='圣枪洗礼:BAAAKgAECggICAAAAA==.',['地狱']='地狱炙炎:BAABKgAFFH8cAAMEAAgIMhN3BgAgAgAEAAgI1BJ3BgAgAgAFAAcIqBAHBACnAQAAAA==.地狱邪影:BAAAKgAECgUIBQAAAA==.',['墨星']='墨星辰:BAABKgAECn8lAAMOAAgI+BlAIAAIAgAOAAgI+BlAIAAIAgAPAAgIoA7aEgBdAQAAAA==.',['夏季']='夏季的惆怅:BAAAKgAECgcICAAAAA==.',['夏日']='夏日阳光:BAAAKgADCggICAAAAA==.',['大地']='大地之父:BAAAKgAFFAIIAgAAAA==.',['大岳']='大岳瑶常丶:BAAAKgAECggICAAAAA==.',['大猫']='大猫咪:BAAAKgAECgQIBAAAAA==.',['大虎']='大虎牙灬:BAAAKgAFFAQIBAAAAA==.',['天线']='天线宝宝牛:BAAAKgAFFAgIAgAAAA==.',['天霸']='天霸横空烈轰:BAACKgAFFH8IAAIHAAYI4BOxCgBiAQAHAAYI4BOxCgBiAQAqAAQKfx0AAwcACAiZFkYaAOEBAAcACAguFEYaAOEBABsACAjvETo0ALABAAAA.',['失落']='失落的月亮:BAAAKgAECgcIBwAAAA==.',['奥蕾']='奥蕾丶莉亚:BAABKgAFFH8GAAIcAAQI3RH+CwDPAAAcAAQI3RH+CwDPAAAAAA==.',['姓葚']='姓葚茗誰:BAAAKgAECgYICgAAAA==.',['姚青']='姚青:BAAAKgAFFAQIBAAAAA==.',['宁小']='宁小闲:BAACKgAFFH8zAAMdAAgI0RuTBAAVAgAdAAgI0RuTBAAVAgAcAAQI6BPJCAD4AAAqAAQKfyYAAx0ACAhVI3wUAEQCAB0ACAhVI3wUAEQCABwACAjZH1EXACUCAAEqAAUUCAglAAwAGh4A.',['守擭']='守擭:BAAAKgAFFAIIAwAAAA==.',['安娜']='安娜吉祥:BAAAKgADCgMIAwAAAA==.',['寂寥']='寂寥:BAAAKgAECggIEAAAAA==.',['寒雨']='寒雨紫烟:BAAAKgAECggICwAAAA==.',['小乖']='小乖乖德:BAAAKgADCggIEAAAAA==.小乖萨满:BAAAKgADCggICAAAAA==.',['小天']='小天真儿:BAABKgAFFH8FAAIQAAMICwMvQgBzAAAQAAMICwMvQgBzAAAAAA==.',['小时']='小时候:BAABKgAFFH8UAAMGAAgI7B9DAwCBAgAGAAgI7B9DAwCBAgACAAQIxBg/BgD4AAAAAA==.',['小星']='小星辰:BAAAKgAECgYIBwAAAA==.',['小浪']='小浪妞呀:BAAAKgAFFAQIBAAAAA==.',['小牛']='小牛先生:BAAAKgAECggIDgAAAA==.小牛阿秋:BAAAKgAECgEIAQAAAA==.',['小猫']='小猫儿:BAABKgAFFH8GAAIIAAYIABliEQCTAQAIAAYIABliEQCTAQAAAA==.',['小鹿']='小鹿妈妈:BAABKgAFFH8GAAIMAAYIPR4YGwCJAQAMAAYIPR4YGwCJAQAAAA==.',['就一']='就一直这样:BAAAKgAECggICAAAAA==.',['山村']='山村羊羊:BAAAKgAFFAMIAwAAAA==.',['帕拉']='帕拉牛肉丁:BAAAKgADCggICwAAAA==.',['帝狱']='帝狱:BAACKgAFFH8TAAMeAAYIAhHwAABBAQAeAAYIAhHwAABBAQAdAAQICx0YFwDpAAAqAAQKfyMAAh4ACAhqHPYGABMCAB4ACAhqHPYGABMCAAEqAAUUCAgSABkA/BoA.',['帝道']='帝道赤霄:BAACKgAFFH8qAAMMAAQIShWQUgDLAAAMAAQIShWQUgDLAAAfAAMIlgs/EgCvAAAqAAQKf0wABAwACAjJFDx4AKYBAAwACAjJFDx4AKYBAB8ACAiXEQIqABYBABkAAQiJAshiAAUAAAAA.',['幸福']='幸福的小霸王:BAACKgAFFH8yAAMHAAQI6RcGCADpAAAHAAMI6RcGCADpAAAbAAMIbRD6LACNAAAqAAQKf0IAAwcACAhoH7QMAEwCAAcACAjuHrQMAEwCABsAAwhmGcwrAIUAAAAA.',['幽瞳']='幽瞳:BAAAKgADCggICAAAAA==.',['庄河']='庄河羊汤:BAAAKgAECgUIBQAAAA==.',['廿壹']='廿壹:BAAAKgAFFAQIBAAAAA==.',['张之']='张之维:BAABKgAFFH8IAAIcAAgIDwb/BQCsAQAcAAgIDwb/BQCsAQAAAA==.',['得卤']='得卤一:BAAAKgAECgQIBAABKgAFFAcIBwAZAIMQAA==.',['得意']='得意地飘:BAAAKgAECgYIBgAAAA==.',['德灬']='德灬傻傻:BAABKgAFFH8FAAIIAAMIewQcVgBdAAAIAAMIewQcVgBdAAAAAA==.',['怒蹄']='怒蹄南帝:BAAAKgAECgMIAwAAAA==.',['怡凡']='怡凡:BAAAKgADCgQIBAAAAA==.',['恸覔']='恸覔怣卋罖:BAAAKgAECgMIAwAAAA==.',['惊鸿']='惊鸿仙子灬:BAABKgAFFH8FAAIMAAUI8xhIMwAcAQAMAAUI8xhIMwAcAQABKgAFFAgIBQAXALUFAA==.',['我可']='我可不是狐狸:BAAAKgAECggICAAAAA==.',['我是']='我是你三哥:BAAAKgAECggICAAAAA==.我是喵大人:BAABKgAECn8dAAMGAAgI0hvuJADpAQAGAAgIDBfuJADpAQABAAcIhhinHACZAQAAAA==.',['我这']='我这小红手:BAAAKgADCggICAAAAA==.',['战飞']='战飞天:BAAAKgAECgMIAwAAAA==.',['戰國']='戰國:BAAAKgADCgMIAwAAAA==.',['托莉']='托莉娜的锋刃:BAACKgAFFH8mAAMbAAgI4B0pCQDAAQAbAAcI4R0pCQDAAQAHAAIISx+QGQC+AAAqAAQKfzYABBsACAjiJHoMAKMCABsACAjFJHoMAKMCACAABggnGe0VAGsBAAcAAwiTIvk0ABsBAAAA.',['扭曲']='扭曲的机器:BAABKgAFFH8HAAIEAAYI3xJKEABpAQAEAAYI3xJKEABpAQAAAA==.',['把酒']='把酒成疯:BAABKgAFFH8GAAILAAYIuBczCQChAQALAAYIuBczCQChAQAAAA==.',['拉妮']='拉妮:BAAAKgAECgYIBwAAAA==.',['拔丝']='拔丝地瓜:BAAAKgAECggIDQAAAA==.',['提盾']='提盾直接莽:BAAAKgADCggICAAAAA==.',['提里']='提里奥丨弗丁:BAAAKgAECgUIBQAAAA==.',['撒旦']='撒旦小蜜:BAAAKgAECgEIAQAAAA==.',['教灬']='教灬练:BAAAKgAECggICAAAAA==.',['斗战']='斗战心魔:BAAAKgAECgUIBQAAAA==.',['斯蒂']='斯蒂芬刘:BAAAKgAFFAQIAgAAAA==.',['无限']='无限循环:BAABKgAFFH8IAAMBAAMI4g56KABIAAAGAAIIZgmsQABqAAABAAEI2xl6KABIAAABKgAFFAgISgANAEMWAA==.',['春风']='春风花月夜:BAAAKgADCggICAAAAA==.',['晓涵']='晓涵:BAAAKgADCgYIBgAAAA==.',['暖风']='暖风烟火:BAABKgAFFH8OAAIXAAgIwQfRBQD2AQAXAAgIwQfRBQD2AQAAAA==.',['暗黑']='暗黑欣术:BAABKgAFFH8MAAIGAAYIfgxNDwBFAQAGAAYIfgxNDwBFAQAAAA==.暗黑猎手:BAABKgAFFH8GAAISAAYILQ+ADgBeAQASAAYILQ+ADgBeAQAAAA==.',['暴躁']='暴躁小黑胖子:BAABKgAFFH8IAAISAAQIsAWeJQCbAAASAAQIsAWeJQCbAAAAAA==.',['暴风']='暴风的愿望:BAAAKgADCgcIBwAAAA==.',['暹罗']='暹罗猫:BAAAKgAFFAQIBAAAAA==.',['曰灬']='曰灬天:BAABKgAFFH8IAAILAAgIMB2tBABfAgALAAgIMB2tBABfAgAAAA==.',['最后']='最后:BAAAKgAFFAQIBAAAAA==.',['月无']='月无名:BAABKgAFFH8IAAIdAAMINw2hEQCUAAAdAAMINw2hEQCUAAAAAA==.',['有关']='有关部门領捣:BAAAKgADCgEIAQAAAA==.',['本宫']='本宫自悠然:BAAAKgAECgcIBwAAAA==.',['朱敛']='朱敛:BAAAKgAFFAYIAwAAAA==.',['杀噫']='杀噫来袭:BAAAKgAFFAIIAgAAAA==.',['极端']='极端努诺:BAAAKgAECgEIAQAAAA==.',['梦不']='梦不再奢华:BAAAKgAECgcIBwAAAA==.',['楠丶']='楠丶阿萨斯:BAABKgAFFH8GAAIMAAYIUB6pFAC2AQAMAAYIUB6pFAC2AQAAAA==.',['樱桃']='樱桃小公主:BAACKgAFFH8JAAIbAAQIuApJFQDeAAAbAAQIuApJFQDeAAAqAAQKfyoAAhsACAjoG9UXAEsCABsACAjoG9UXAEsCAAAA.樱桃小完犊子:BAAAKgAECgcIBwAAAA==.樱桃泡泡:BAAAKgAECgIIAwAAAA==.',['橘枝']='橘枝:BAAAKgADCggICAAAAA==.',['橘织']='橘织:BAAAKgAECgIIAgAAAA==.',['橘芝']='橘芝:BAAAKgAECgUIBQAAAA==.',['橙子']='橙子小红手丶:BAABKgAFFH8GAAIGAAYIliVTCwDYAQAGAAYIliVTCwDYAQABKgAFFAgIAgAhAAAAAA==.',['欣有']='欣有萌虎:BAAAKgAFFAYIAQAAAA==.',['残破']='残破的灵魂:BAABKgAFFH8MAAIGAAQImhLBLQC3AAAGAAQImhLBLQC3AAAAAA==.',['毁琳']='毁琳:BAACKgAFFH8FAAMCAAMI2xlOFwCDAAACAAII4hlOFwCDAAAGAAIIYQ7lQQBkAAAqAAQKfxQABAYABwi5IRcUAAcCAAYABgi5IRcUAAcCAAEABggjEsM2AAkBAAIAAgi4GYczAGIAAAAA.',['江河']='江河湖海:BAAAKgADCggIDgAAAA==.',['沐清']='沐清风:BAAAKgAECgYICAAAAA==.',['法无']='法无禁止:BAAAKgAECgIIAgAAAA==.',['洛克']='洛克加:BAACKgAFFH8MAAIIAAUImSCOEgCIAQAIAAUImSCOEgCIAQAqAAQKfxkAAggACAj2GXETAMgBAAgACAj2GXETAMgBAAAA.',['洮儿']='洮儿河:BAAAKgAECgYIBgAAAA==.',['派大']='派大星丶:BAAAKgAECgMIAwAAAA==.',['海拉']='海拉鲁老林克:BAAAKgAFFAQIBAAAAA==.',['淡淡']='淡淡的蓝色:BAAAKgAFFAEIAgAAAA==.',['淡色']='淡色艾尔:BAAAKgAECgQIBQAAAA==.',['深汝']='深汝浅出:BAAAKgADCggICAAAAA==.',['深黑']='深黑色:BAABKgAFFH8PAAIMAAcIIyA/FQCxAQAMAAcIIyA/FQCxAQAAAA==.',['源秀']='源秀一:BAABKgAFFH8GAAMLAAYIGiAXBQBYAQALAAQIHCYXBQBYAQAaAAIIFheLJACGAAAAAA==.',['火法']='火法大老鼠:BAAAKgAFFAEIAQAAAA==.',['灬莫']='灬莫娜灬:BAABKgAECn8XAAMLAAgIshOeEwBMAQALAAUIkBueEwBMAQAaAAgICAq7MQDHAAAAAA==.',['灵界']='灵界打鸡丷:BAABKgAFFH8IAAMLAAgIlADzHwBQAAALAAQI3ADzHwBQAAAaAAQIMwDFFAAoAAAAAA==.',['炸糕']='炸糕:BAAAKgAECgIIAgAAAA==.',['煉獄']='煉獄之奴:BAABKgAFFH8GAAIaAAYITg//EAAcAQAaAAYITg//EAAcAQABKgAFFAgIDAAaANESAA==.',['煎饼']='煎饼乄初心:BAACKgAFFH8NAAMJAAQIAxpxIgCeAAAJAAMIAxpxIgCeAAAIAAEIAACYNQAAAAAqAAQKfzsABAkACAh0H6IPAC8CAAkACAh0H6IPAC8CAAgABwi1FvpCAJ4BAAoAAwi/EZYpAJ4AAAAA.',['燃烧']='燃烧肥猫:BAAAKgADCggICAAAAA==.',['爱拉']='爱拉姆斯之剑:BAAAKgAECgYICwABKgAFFAgIEgAZAPwaAA==.',['牛妞']='牛妞:BAAAKgADCgIIAgAAAA==.',['牛灬']='牛灬欢灬喜:BAAAKgAFFAMIAwAAAA==.',['牧一']='牧一:BAAAKgAFFAIIAgAAAA==.',['牧奶']='牧奶怡:BAAAKgADCgcIBwAAAA==.',['牵线']='牵线木偶灬:BAAAKgAFFAMIAwABKgAFFAgICQALAPIZAA==.',['犯二']='犯二小王子:BAAAKgAECgYIBgAAAA==.',['猫咪']='猫咪酱:BAAAKgADCgEIAgAAAA==.',['猫小']='猫小汪:BAACKgAFFH8OAAQVAAYIJBqiEgAdAQAVAAUIfBeiEgAdAQAiAAQIXAh3JACPAAAWAAEIuQ9SKwBFAAAqAAQKfx8AAyIACAimG+kWAAwCACIACAjXGukWAAwCABUACAhNE18tAJABAAEqAAUUBgghABYAihAA.',['猫熊']='猫熊丶:BAABKgAFFH8FAAIdAAUIyQM7GgDMAAAdAAUIyQM7GgDMAAAAAA==.',['玉鳯']='玉鳯:BAAAKgADCgQIBAAAAA==.',['王老']='王老师:BAAAKgAECgUIBQAAAA==.',['玖儿']='玖儿:BAAAKgAFFAgIBAAAAA==.',['珍妮']='珍妮玛士多:BAAAKgAFFAQIBAAAAA==.',['理性']='理性:BAABKgAECn8dAAMLAAcIUxxkKwDPAQALAAcIUxxkKwDPAQAaAAYI+QxCOQDgAAAAAA==.',['生番']='生番丶:BAAAKgAECggIDAAAAA==.',['电梯']='电梯战神:BAABKgAECn8fAAIZAAgIPgidMQDTAAAZAAgIPgidMQDTAAAAAA==.',['番茄']='番茄炒蛋:BAAAKgAECgcIEwAAAA==.',['痛苦']='痛苦骑士:BAAAKgADCgEIAgAAAA==.',['白月']='白月教主丶:BAACKgAFFH8yAAIZAAgIiQwXDAA2AQAZAAgIiQwXDAA2AQAqAAQKfzUAAhkACAjkGxscAH8BABkACAjkGxscAH8BAAAA.',['百月']='百月教主:BAAAKgAECgYIBgAAAA==.',['的说']='的说法是:BAAAKgADCgYIBgAAAA==.',['盐酸']='盐酸小檗碱:BAAAKgAECgYIBgAAAA==.',['真冬']='真冬之雪:BAABKgAFFH8aAAIaAAYIkR/ABgC+AQAaAAYIkR/ABgC+AQAAAA==.',['睡前']='睡前抽根烟:BAAAKgAECgYIDAAAAA==.',['破坏']='破坏天神:BAAAKgAFFAYIBAAAAA==.破坏月神:BAABKgAFFH8IAAMJAAYIChhiCQBxAQAJAAYIChhiCQBxAQAIAAIIHAZhMABnAAAAAA==.',['破邪']='破邪剑征:BAAAKgADCggICAAAAA==.',['神仙']='神仙石头:BAABKgAECn8fAAMRAAgI/iNZDADAAgARAAgI/iNZDADAAgAQAAEItxFwqAAvAAAAAA==.',['神棍']='神棍猫猫:BAAAKgAECgIIAgAAAA==.',['秃头']='秃头披风侠:BAAAKgADCgUIBQAAAA==.',['秦坦']='秦坦造物:BAACKgAFFH8ZAAMRAAQIeRoXFAD9AAARAAQIeRoXFAD9AAAQAAEITwyGUgA2AAAqAAQKfzwAAxEACAhPIyIWAKQCABEACAhPIyIWAKQCABAABggEFqYcADcBAAAA.',['稻戝']='稻戝:BAAAKgAFFAEIAgAAAA==.',['空訫']='空訫糖果丶:BAACKgAFFH8SAAMMAAQIPSKiMAAmAQAMAAQIPSKiMAAmAQAfAAEI0gEpFwAwAAAqAAQKfz8AAwwACAj2JMMlAIQCAAwACAj2JMMlAIQCAB8AAQi1CTZQADYAAAAA.',['章鱼']='章鱼哥丶:BAABKgAFFH8KAAIcAAYIsRz4AAD7AQAcAAYIsRz4AAD7AQAAAA==.',['粉色']='粉色职业:BAAAKgADCgIIAwAAAA==.',['純愛']='純愛戰士:BAAAKgAECgcICQAAAA==.純愛戰士灬:BAAAKgAECgcIEQAAAA==.',['紫晶']='紫晶灬:BAAAKgAECggICAAAAA==.',['紫色']='紫色职业:BAABKgAECn8mAAISAAgImB/pKQAPAgASAAgImB/pKQAPAgAAAA==.',['纳格']='纳格伊芙:BAAAKgAECggICAAAAA==.',['绿色']='绿色职业:BAABKgAECn8YAAIRAAgInhsAKwADAgARAAgInhsAKwADAgAAAA==.',['罗莉']='罗莉妹控:BAABKgAFFH8IAAIJAAgIbBJeBAC/AQAJAAgIbBJeBAC/AQAAAA==.',['老君']='老君的青牛:BAAAKgAFFAQIBAAAAA==.',['而立']='而立尔欣:BAAAKgAFFAIIAgAAAA==.',['聆夜']='聆夜:BAAAKgAECggIEgAAAA==.',['胡八']='胡八一:BAAAKgADCgMIAwAAAA==.',['脆脆']='脆脆丶小红手:BAACKgAFFH8fAAMcAAgIABuRBgATAQAcAAYIzhuRBgATAQAdAAUIdw6xFgDtAAAqAAQKfzMABBwACAhJHrsUADsCABwABwgCI7sUADsCAB0ABwipGKQoALgBAB4ABQhKAzsjAE0AAAAA.',['脱缰']='脱缰狗砸:BAAAKgADCgEIAQAAAA==.脱缰野狗子:BAAAKgADCgcIBwAAAA==.',['腊捌']='腊捌蒜:BAAAKgADCgUIBQAAAA==.',['至高']='至高岭的勇士:BAAAKgADCgIIAgAAAA==.',['舞琳']='舞琳:BAAAKgAFFAIIAgAAAA==.',['艾因']='艾因:BAAAKgAECggICAAAAA==.',['花气']='花气袭人丶:BAACKgAFFH8WAAMGAAQInSPpBgA1AQAGAAMInSPpBgA1AQABAAEIAACgGgAAAAAqAAQKfykABAYACAiHI20OADwCAAYABwhLI20OADwCAAEABAg4ItQ6APYAAAIAAwgJGCoqAK8AAAEqAAUUBggVAAQAqx8A.',['莓莓']='莓莓泡芙卷:BAAAKgADCgQIBAAAAA==.',['萨总']='萨总:BAAAKgAECggIEQAAAA==.',['萨满']='萨满嗜血起:BAACKgAFFH8jAAIOAAQIZhQMFwDJAAAOAAQIZhQMFwDJAAAqAAQKfzoAAg4ACAgfG6AtANMBAA4ACAgfG6AtANMBAAAA.',['落丶']='落丶魔:BAAAKgADCgcIBwAAAA==.',['落雪']='落雪:BAAAKgAECggIDAAAAA==.落雪无痕:BAABKgAFFH8GAAIHAAYITwl4DABGAQAHAAYITwl4DABGAQAAAA==.',['蒂伊']='蒂伊:BAABKgAFFH8FAAMXAAUIbxvKFQD7AAAXAAMIphnKFQD7AAAjAAIIzSAfCgBjAAAAAA==.',['蓝冰']='蓝冰秋释:BAAAKgADCgUICgAAAA==.',['蕾姆']='蕾姆蕾姆:BAABKgAECn8oAAQBAAgIRCGdBQCYAgABAAgIJiGdBQCYAgAGAAYICB00KgBzAQACAAQIphJLJQC2AAAAAA==.',['薩疊']='薩疊頼僷:BAAAKgADCggIEAAAAA==.',['蛋总']='蛋总贴身护卫:BAAAKgADCgMIAwAAAA==.',['蛟龍']='蛟龍:BAAAKgADCgQIBAAAAA==.',['血凝']='血凝梦魇:BAAAKgADCggICQAAAA==.',['血契']='血契旋风:BAABKgAFFH8IAAIMAAgITCOTAgDKAgAMAAgITCOTAgDKAgAAAA==.',['衣以']='衣以候丶:BAACKgAFFH8IAAQiAAYITRMUCwBkAQAiAAYITRMUCwBkAQAVAAEI+g5wPwA5AAAWAAEIuAObMgArAAAqAAQKfycAAhUACAjRHSMeAOoBABUACAjRHSMeAOoBAAAA.',['诅咒']='诅咒伱:BAAAKgADCgQIBAAAAA==.',['谛听']='谛听丶:BAABKgAFFH8IAAMJAAgIRxTJCwBJAQAJAAQIqBbJCwBJAQAIAAQI6g5oPwCtAAAAAA==.',['谜之']='谜之熊猫人:BAAAKgAECggICAAAAA==.',['贝尔']='贝尔蒙多:BAAAKgAFFAYIBAAAAA==.',['贰非']='贰非:BAACKgAFFH8dAAIkAAQInwdkGAChAAAkAAQInwdkGAChAAAqAAQKfz8AAiQACAhpGY4YAPwBACQACAhpGY4YAPwBAAAA.',['起门']='起门拉人快:BAAAKgADCgMIAwAAAA==.',['超级']='超级大力鼠:BAABKgAFFH8IAAIQAAYIWA2OFgAxAQAQAAYIWA2OFgAxAQAAAA==.',['踏疯']='踏疯:BAABKgAFFH8PAAMdAAgIkQ4iBgC0AQAdAAgIkQ4iBgC0AQAcAAMIeQgBEwBsAAAAAA==.',['迎接']='迎接回归的快:BAAAKgAECgUIAwAAAA==.',['逐风']='逐风之语:BAABKgAECn8fAAIRAAgIJyIKDwCsAgARAAgIJyIKDwCsAgAAAA==.',['速度']='速度速度速度:BAAAKgAFFAQIBAAAAA==.',['道格']='道格拉斯:BAAAKgADCggICAAAAA==.',['邪惡']='邪惡丶夢魇:BAAAKgADCgEIAQAAAA==.',['都挺']='都挺无力的:BAAAKgAECgMIAwAAAA==.',['野生']='野生老盖伦:BAAAKgADCgQIBAAAAA==.',['铁锅']='铁锅炖溜达鸡:BAAAKgAECgEIAQAAAA==.',['铃鹿']='铃鹿御前:BAAAKgAFFAIIAgAAAA==.',['铜锅']='铜锅涮肉:BAAAKgAFFAIIAgAAAA==.',['阿克']='阿克曼:BAAAKgADCgIIAgAAAA==.',['阿坤']='阿坤复仇:BAAAKgAFFAQIBAAAAA==.',['阿萨']='阿萨忽悠着你:BAAAKgADCgIIAgAAAA==.',['随风']='随风的风:BAABKgAFFH8GAAIGAAYIMBzIEACHAQAGAAYIMBzIEACHAQAAAA==.随风落雪:BAABKgAFFH8GAAIMAAYImRbiGQD3AAAMAAYImRbiGQD3AAAAAA==.',['雅音']='雅音初雪:BAAAKgAECgIIAgAAAA==.',['雙刃']='雙刃:BAAAKgADCgYIBgAAAA==.',['雷加']='雷加尔:BAAAKgADCgEIAQAAAA==.',['雷索']='雷索:BAACKgAFFH8qAAMBAAgIKBk/AgByAQABAAQIWCM/AgByAQAGAAcI3g3SHwAJAQAqAAQKfzoABAEACAiaJCcBAO0CAAEACAg6JCcBAO0CAAYABwhnG+IXAEUBAAIAAgi5EtkzAHkAAAAA.',['静月']='静月真君:BAAAKgAECgMIAwAAAA==.',['頽癈']='頽癈:BAAAKgAECggICAAAAA==.',['风声']='风声潇潇:BAAAKgAECggICAABKgAECggIFQAVALYbAA==.',['风带']='风带走了什么:BAACKgAFFH80AAMDAAQIGQq1KACqAAADAAQIlQa1KACqAAAEAAMIeAlxMACiAAAqAAQKf1kAAwMACAgZHOwLABoCAAMACAjHGuwLABoCAAQACAhBGwglANEBAAAA.',['风暴']='风暴之拥:BAAAKgAECgUICgAAAA==.风暴使者:BAABKgAFFH8SAAIOAAYIih/zBgCyAQAOAAYIih/zBgCyAQAAAA==.风暴男骑:BAAAKgAECggICAAAAA==.',['风歌']='风歌:BAACKgAFFH8vAAIMAAQIyyPpKgA7AQAMAAQIyyPpKgA7AQAqAAQKf0UABAwACAiLJSsLAOYCAAwACAiLJSsLAOYCAB8ABggGDPUvAOIAABkABAiuDug2ALIAAAAA.',['风清']='风清雲淡:BAAAKgADCgEIAQAAAA==.',['风笛']='风笛:BAABKgAFFH8dAAIPAAcIrw+JCADqAAAPAAcIrw+JCADqAAAAAA==.',['饮血']='饮血机:BAABKgAFFH8GAAIVAAYIqReZBwB6AQAVAAYIqReZBwB6AQAAAA==.',['麦小']='麦小兜:BAAAKgAECggICAAAAA==.',['黑猫']='黑猫:BAAAKgAECgQIBAABKgAFFAgIJgAbAOAdAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end