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
 local lookup = {'Mage-Frost','Mage-Arcane','Paladin-Retribution','Hunter-Marksmanship','Hunter-BeastMastery','Hunter-Survival','Druid-Restoration','Shaman-Elemental','Shaman-Restoration','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Warrior-Fury','DeathKnight-Unholy','DeathKnight-Blood','Druid-Balance','Paladin-Holy','Paladin-Protection','Mage-Fire','Priest-Holy','Monk-Mistweaver','DeathKnight-Frost','Monk-Windwalker','Warrior-Arms','Shaman-Enhancement','Rogue-Assassination','DemonHunter-Havoc','Priest-Shadow','Priest-Discipline','Evoker-Devastation','Unknown-Unknown','Druid-Guardian','Druid-Feral','Warrior-Protection',}; local provider = {region='CN',realm='甜水绿洲',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aigodali:BAAAKgAFFAQIBAAAAA==.Aisace:BAAAKgAECggICAAAAA==.',Ba='Ball:BAAAKgAECgUIBQAAAA==.',Bi='Bigzai:BAAAKgAECgEIAQAAAA==.',Ca='Calafiori:BAACKgAFFH8hAAMBAAgIixuYAwDAAQABAAgIixuYAwDAAQACAAQI7Qm9NACPAAAqAAQKfyEAAgEACAg0I4kMAJ4CAAEACAg0I4kMAJ4CAAAA.',Ce='Celine:BAAAKgAECgMIAwAAAA==.',Ch='Chicagogirl:BAAAKgAECgcIBwAAAA==.',Cr='Crsan:BAABKgAFFH8GAAIDAAYI2xj/FQCrAQADAAYI2xj/FQCrAQAAAA==.',Dk='Dk:BAABKgAFFH8GAAQEAAIIexaSIwBTAAAEAAEIWRuSIwBTAAAFAAEInRE5RQBNAAAGAAEIUAYdBwA3AAAAAA==.',Fa='Fantine:BAAAKgAECgQIBAABKgAECggIQAAHAD0gAA==.',Fl='Flyawyya:BAECKgAFFH8GAAMIAAQIXB5nBgD/AAAIAAQIXB5nBgD/AAAJAAII5A17KAB+AAAqAAQKfxgAAggACAjcIzwUAEoCAAgACAjcIzwUAEoCAAAA.',Fq='Fq:BAAAKgADCggICAAAAA==.',Fr='Freude:BAAAKgAECgYIBwAAAA==.',Gi='Ginman:BAAAKgAFFAQIBAAAAA==.',Ha='Halleluyah:BAAAKgADCgEIAQAAAA==.',He='Heartinsword:BAABKgAFFH8MAAQKAAMIdxwWEwCpAAALAAMIgw1LGADAAAAMAAIIGiRcDgCzAAAKAAMIkwoWEwCpAAAAAA==.',Ic='Icehotflam:BAAAKgAFFAgIBAAAAA==.',Ja='Jackydk:BAAAKgAFFAYIBAAAAA==.',Kb='Kbz:BAAAKgADCggICAAAAA==.',La='Lalalal:BAABKgAFFH8SAAMFAAYISiS9CgAsAQAEAAYIISPaCwCZAQAFAAYIjiK9CgAsAQAAAA==.',Li='Linkikpark:BAAAKgADCgUIBQAAAA==.',Ll='Llyygg:BAABKgAFFH8FAAINAAUISQlOFgAIAQANAAUISQlOFgAIAQAAAA==.',Lu='Lunar:BAABKgAECn8UAAIDAAYIXg65tADnAAADAAYIXg65tADnAAAAAA==.',Ma='Mastateligo:BAAAKgAFFAMIAwAAAA==.',Na='Naowhlul:BAABKgAFFH8fAAMOAAgIpSC0BABeAgAOAAgIux+0BABeAgAPAAUISBLPFQCfAAAAAA==.',Pl='Playeraplyrq:BAAAKgADCgMIAwAAAA==.Playerepnbqe:BAAAKgAECgIIAgAAAA==.Playerhqpxul:BAAAKgAECgEIAQAAAA==.',Po='Pochama:BAAAKgAECgUIBQAAAA==.',Pu='Pulsar:BAAAKgAECgcIBwAAAA==.',Ra='Rabigator:BAAAKgAECggIEQAAAA==.',Re='Readyone:BAAAKgAECgcICwAAAA==.',Se='Seirias:BAAAKgAECgcIDwAAAA==.',Sh='Sherryly:BAAAKgADCgcIBwAAAA==.',Sw='Swaylv:BAABKgAFFH8OAAIQAAgIDwbxDQCXAQAQAAgIDwbxDQCXAQAAAA==.',To='Tom:BAABKgAECn8XAAMEAAgIuQ6tRQAJAQAEAAgIogutRQAJAQAFAAQIMwmx4gBrAAAAAA==.',Ul='Ultrakill:BAAAKgAFFAQIBAAAAA==.',Ve='Venti:BAAAKgADCggICAAAAA==.',Wa='Wangich:BAAAKgAECgEIAQAAAA==.',Ye='Yee:BAAAKgAECgYIBgAAAA==.',['一个']='一个人的旅行:BAAAKgAFFAQIBAAAAA==.',['一二']='一二三亖:BAAAKgADCgMIAwAAAA==.',['一只']='一只丶:BAAAKgAECggIDgAAAA==.',['一品']='一品温如言:BAABKgAFFH8GAAMEAAIIng/GQgBxAAAEAAIIng/GQgBxAAAFAAIIUQRCQQBfAAAAAA==.',['一晶']='一晶晶公主一:BAAAKgAFFAIIAgAAAA==.',['一箭']='一箭你就笑:BAAAKgAECgEIAQAAAA==.',['七度']='七度王爵:BAAAKgADCggICAAAAA==.',['万剑']='万剑归宗:BAAAKgAECgYICgAAAA==.',['万灵']='万灵守护:BAAAKgAECggICQAAAA==.',['三七']='三七:BAAAKgAECgUIBgAAAA==.',['三队']='三队那个骑士:BAAAKgAECggICwAAAA==.',['不倾']='不倾城但成熟:BAAAKgAECggIEAAAAA==.',['不嘚']='不嘚不牛:BAACKgAFFH8MAAIQAAMI2BjWKwDjAAAQAAMI2BjWKwDjAAAqAAQKfxcAAhAACAhgHNUmABoCABAACAhgHNUmABoCAAEqAAUUAwgOAAgAUxYA.',['不爱']='不爱吃鱼橘猫:BAAAKgAECgQICAAAAA==.',['不要']='不要比我拽:BAAAKgADCggICAAAAA==.',['不酷']='不酷不爱笑:BAAAKgAECggIDwAAAA==.',['与风']='与风同程:BAABKgAFFH8LAAQDAAQIVR8JFwD+AAADAAQIVR8JFwD+AAARAAMIEhbcDgCIAAASAAMI2wdmEACDAAAAAA==.与风如月:BAAAKgAFFAYIAwAAAA==.与风来电:BAAAKgAFFAQIAwAAAA==.',['专业']='专业收银员:BAAAKgAECggICAAAAA==.',['东尼']='东尼三木:BAACKgAFFH8fAAIIAAgIpyF9AgBLAgAIAAgIpyF9AgBLAgAqAAQKfz4AAwgACAiwJNMGAMYCAAgACAiwJNMGAMYCAAkABQiQEHCNAKMAAAAA.',['丢丢']='丢丢仔:BAABKgAFFH8GAAIOAAYIJhJFFgBqAQAOAAYIJhJFFgBqAQAAAA==.',['两小']='两小胡猜:BAAAKgAECgMIAwAAAA==.',['丨恺']='丨恺丶屹丨:BAAAKgAFFAQIBAAAAA==.',['丶轻']='丶轻而易举:BAAAKgAECgYIAwAAAA==.',['丹妮']='丹妮利斯:BAAAKgAECgIIAgAAAA==.',['丿单']='丿单车丿:BAAAKgAECgEIAQAAAA==.',['丿吟']='丿吟风灬:BAAAKgAFFAMIAwAAAA==.',['乌龙']='乌龙:BAAAKgADCgEIAQAAAA==.',['乐事']='乐事奶瓜:BAAAKgAFFAgIBAAAAA==.',['九摩']='九摩诃:BAABKgAFFH8OAAITAAgIXw60CABzAQATAAgIXw60CABzAQAAAA==.',['乳糖']='乳糖炒粽子:BAAAKgAFFAIIAgAAAA==.',['了尘']='了尘居士:BAABKgAFFH8GAAIUAAMI8RaFHQDVAAAUAAMI8RaFHQDVAAAAAA==.',['二十']='二十四桥月夜:BAAAKgAFFAQIBAAAAA==.',['二环']='二环十四郎:BAAAKgAECgEIAQAAAA==.',['云灬']='云灬儿:BAAAKgAECggIBAAAAA==.',['五斗']='五斗米三季稻:BAAAKgAECgcIDgAAAA==.',['五火']='五火球毅哥:BAAAKgAFFAUIBAAAAA==.',['五行']='五行缺目:BAAAKgAFFAEIAQAAAA==.',['亚瑞']='亚瑞:BAAAKgAECgcICgAAAA==.',['人人']='人人有功练:BAAAKgAECgYICwAAAA==.',['今日']='今日刑满:BAABKgAFFH8KAAMPAAQIkiZrAwBbAQAPAAQIkiZrAwBbAQAOAAQI4xW/FgDcAAAAAA==.',['仙云']='仙云拂马来:BAAAKgADCgEIAQAAAA==.',['仚仚']='仚仚屲冚:BAAAKgADCggICQAAAA==.',['代号']='代号穿山甲:BAAAKgAFFAQIBAAAAA==.',['伊利']='伊利达雷宝宝:BAAAKgADCgQIBAAAAA==.',['何伟']='何伟姐:BAAAKgAECgEIAQAAAA==.',['你扯']='你扯我腿毛了:BAAAKgAFFAQIBAAAAA==.',['佬倌']='佬倌矶:BAACKgAFFH8GAAIVAAMIfgVcJwCFAAAVAAMIfgVcJwCFAAAqAAQKfx4AAhUACAi6FvwgAIMBABUACAi6FvwgAIMBAAEqAAUUAwgOAAgAUxYA.',['依然']='依然:BAAAKgADCgMIAwAAAA==.',['信风']='信风扶:BAAAKgAECgcIBwAAAA==.',['修女']='修女面霜:BAAAKgAECgYIEQAAAA==.',['儿化']='儿化音:BAAAKgAECgEIAQAAAA==.',['元素']='元素丶萨:BAAAKgAECgYIBgAAAA==.',['光之']='光之圣堂:BAABKgAFFH8JAAMDAAcIXxLyHQDtAAADAAQIaRTyHQDtAAASAAMIVhCvGQCqAAAAAA==.',['兔八']='兔八哥:BAABKgAFFH8GAAINAAYIIxm4CwCQAQANAAYIIxm4CwCQAQAAAA==.',['兔酱']='兔酱说开始:BAAAKgADCgYIBgAAAA==.',['全职']='全职劣人:BAAAKgAFFAIIBAAAAA==.',['全需']='全需:BAAAKgAFFAYIBAAAAA==.',['六六']='六六橙:BAAAKgAECgIIAgAAAA==.',['冰霜']='冰霜贼:BAACKgAFFH8QAAIOAAMIrQ9qNQDCAAAOAAMIrQ9qNQDCAAAqAAQKfxsAAw4ACAhiGoYyAOgBAA4ACAhiGoYyAOgBABYAAQi4BNM6ABUAAAAA.',['冷笑']='冷笑:BAAAKgAECgMIBAAAAA==.',['冷馨']='冷馨丨灬:BAAAKgAECgIIAgAAAA==.冷馨儿:BAAAKgAFFAEIAQAAAA==.',['凛霜']='凛霜守护:BAAAKgAECgQIBAAAAA==.',['凤箫']='凤箫声动:BAAAKgAFFAIIAwAAAA==.',['凨凪']='凨凪凮夙:BAAAKgAECgUICQAAAA==.',['凶猛']='凶猛小猫咪:BAAAKgAFFAYIBAAAAA==.',['刀锋']='刀锋追猎者:BAAAKgADCgEIAQAAAA==.',['别开']='别开腔:BAAAKgAECgEIAQAAAA==.',['劳勃']='劳勃拜拉席恩:BAAAKgAECgUIBQAAAA==.',['包神']='包神:BAABKgAFFH8IAAIJAAgIixG2BgC3AQAJAAgIixG2BgC3AQAAAA==.',['北陵']='北陵帝空:BAAAKgAECggIEgAAAA==.',['十步']='十步流肾骑士:BAABKgAECn8aAAIDAAgIZBjrTgDRAQADAAgIZBjrTgDRAQAAAA==.',['千骨']='千骨枯:BAAAKgAFFAQIAgAAAA==.',['华尔']='华尔街:BAAAKgAECgQIBAAAAA==.',['单身']='单身穷光蛋:BAABKgAFFH8IAAINAAQIHQ9yHwDWAAANAAQIHQ9yHwDWAAAAAA==.',['南拳']='南拳嘛嘛:BAABKgAFFH8GAAIXAAYIMhhtCABoAQAXAAYIMhhtCABoAQAAAA==.',['印第']='印第安老板鸠:BAAAKgAECggIDgABKgAECggIGAAKAJEYAA==.',['叁途']='叁途川:BAAAKgAFFAYIAgAAAA==.',['叽里']='叽里呱啦:BAAAKgAECgUIBQAAAA==.',['吊成']='吊成一匹马:BAAAKgAECgQICgAAAA==.',['呼而']='呼而嗨哟:BAABKgAFFH8OAAMNAAYIIRuCDAAJAQANAAYI1BaCDAAJAQAYAAIIGBm/CgDGAAAAAA==.',['命运']='命运脚印:BAAAKgAECggICAAAAA==.',['咩咩']='咩咩暴打巨蟹:BAAAKgAECgYIBgABKgAECggIGAAKAJEYAA==.',['咪喵']='咪喵喵:BAAAKgAECggIEwAAAA==.',['咸香']='咸香脆薯条:BAAAKgAECgYIBgAAAA==.',['哑巴']='哑巴湖小水怪:BAAAKgAECgQIBAAAAA==.',['啸月']='啸月孤狼:BAAAKgADCgQIBAAAAA==.',['啾瑟']='啾瑟夫:BAAAKgAFFAQIBAAAAA==.',['喜微']='喜微晨巷:BAAAKgAECggIDwAAAA==.',['喜薇']='喜薇曟港:BAAAKgAECgcICAABKgAECggIGAAKAJEYAA==.',['嘂猫']='嘂猫爷嘂:BAAAKgAFFAYIAgAAAA==.',['嘿西']='嘿西欧:BAAAKgAFFAEIAQAAAA==.',['噩梦']='噩梦之子:BAAAKgAECggICQAAAA==.',['囤囤']='囤囤转:BAABKgAFFH8GAAISAAYIYwsQEwDjAAASAAYIYwsQEwDjAAAAAA==.',['圐一']='圐一宸浠:BAAAKgADCgUIBQAAAA==.',['圣典']='圣典鳞卫奥尔:BAAAKgAFFAIIAgAAAA==.',['圣堂']='圣堂之战:BAAAKgAFFAYIBAABKgAFFAgIEwAQAHMfAA==.圣堂之武:BAAAKgAFFAQIBAAAAA==.圣堂之法:BAABKgAECn8WAAMBAAgIWR2bEwAjAgABAAgIchybEwAjAgATAAIIjRv0MgChAAAAAA==.圣堂之猎:BAAAKgAFFAYIBAAAAA==.圣堂之贼:BAAAKgAECggIEAAAAA==.圣堂之骑:BAABKgAFFH8IAAIOAAYI9w9PDQApAQAOAAYI9w9PDQApAQAAAA==.圣堂之魔:BAAAKgAECggIEAAAAA==.',['地九']='地九神:BAACKgAFFH8NAAMZAAYINRigAQDAAQAZAAYINRigAQDAAQAJAAEIAABSOgAAAAAqAAQKfxUAAwkACAiAGGIsANgBAAkACAiAGGIsANgBAAgACAiLDaQ7AEIBAAAA.',['地狱']='地狱飞魔:BAABKgAECn8dAAIUAAgIrB/CDgBVAgAUAAgIrB/CDgBVAgAAAA==.',['型到']='型到跌渣:BAAAKgAFFAMIAwAAAA==.',['塔下']='塔下意识粉:BAACKgAFFH8WAAIJAAYIQRLCDwBZAQAJAAYIQRLCDwBZAQAqAAQKfyUAAgkACAhDI6wKAJgCAAkACAhDI6wKAJgCAAAA.',['壊男']='壊男孩:BAABKgAFFH8HAAIDAAcITQmHEQCGAQADAAcITQmHEQCGAQAAAA==.',['复仇']='复仇的圣骑:BAABKgAECn8eAAIDAAgICSI0FAC5AgADAAgICSI0FAC5AgAAAA==.',['外星']='外星人拉面:BAAAKgAECgYICAAAAA==.',['夢追']='夢追的流星群:BAAAKgAECggICAAAAA==.',['大漠']='大漠:BAAAKgAECggICAAAAA==.',['大炮']='大炮筒:BAABKgAECn8ZAAIJAAgIxBxoHQAYAgAJAAgIxBxoHQAYAgAAAA==.',['天下']='天下無敵:BAAAKgAECgQIBQAAAA==.',['天九']='天九王:BAABKgAFFH8GAAITAAYIwhlDDAByAQATAAYIwhlDDAByAQAAAA==.',['天十']='天十二:BAABKgAFFH8KAAINAAYIKyDFCgCfAQANAAYIKyDFCgCfAQAAAA==.',['天地']='天地公子:BAAAKgAFFAQIBAAAAA==.',['天天']='天天捏票纸:BAAAKgADCggIDwAAAA==.',['天性']='天性神奇:BAAAKgADCggICAAAAA==.',['天极']='天极:BAAAKgAECgQIBAAAAA==.',['天气']='天气凉:BAABKgAFFH8GAAIPAAYI0gcyGQDYAAAPAAYI0gcyGQDYAAAAAA==.',['天灾']='天灾士兵:BAABKgAFFH8GAAIOAAYIbw/5FwBdAQAOAAYIbw/5FwBdAQAAAA==.',['天然']='天然呆的萌妹:BAAAKgADCggICAAAAA==.天然呆自然萌:BAAAKgAECgUIBQAAAA==.',['天爱']='天爱星:BAAAKgAECggICAAAAA==.',['天生']='天生缺德:BAAAKgAECgIIAgAAAA==.',['奥丽']='奥丽薇娅:BAAAKgAECgYIBgAAAA==.',['奥利']='奥利干:BAAAKgADCggICAAAAA==.',['女乃']='女乃女馬:BAAAKgAECggIDgAAAA==.',['奶油']='奶油柠檬:BAAAKgAECgMIAwAAAA==.',['奶酪']='奶酪骑士:BAAAKgAFFAIIAgAAAA==.',['好日']='好日子在后面:BAABKgAFFH8WAAIDAAgI5CH6AgC8AgADAAgI5CH6AgC8AgAAAA==.',['好白']='好白的牛:BAAAKgAECgIIAgAAAA==.',['姒如']='姒如歌:BAAAKgAFFAYIBAAAAA==.',['孤星']='孤星小流氓:BAABKgAFFH8QAAIQAAgIRBz4BQBXAgAQAAgIRBz4BQBXAgAAAA==.',['学校']='学校的沃柑:BAABKgAFFH8GAAIaAAYIzQR+AwB1AQAaAAYIzQR+AwB1AQAAAA==.',['宇宙']='宇宙首富:BAAAKgAECggICAAAAA==.',['安牧']='安牧希:BAAAKgAECgEIAQAAAA==.',['宗布']='宗布神羿:BAAAKgADCgEIAQAAAA==.',['宝宝']='宝宝别闹:BAABKgAFFH8GAAIbAAQIwRXeFwDkAAAbAAQIwRXeFwDkAAAAAA==.宝宝甜:BAAAKgAFFAYIBAAAAA==.',['审判']='审判之刃:BAAAKgADCgIIAgAAAA==.',['富强']='富强民主:BAABKgAFFH8IAAIbAAQIIA98GQDfAAAbAAQIIA98GQDfAAAAAA==.',['寒枫']='寒枫:BAACKgAFFH8JAAIUAAMIRwt/KgCZAAAUAAMIRwt/KgCZAAAqAAQKfx8AAhQACAgbEPc0AEkBABQACAgbEPc0AEkBAAAA.',['寒茫']='寒茫:BAABKgAFFH8IAAIPAAgIBw/qCACJAQAPAAgIBw/qCACJAQAAAA==.',['寒阶']='寒阶望月华:BAAAKgAECgIIAgAAAA==.',['寒風']='寒風殤魂:BAAAKgAFFAQIBAAAAA==.',['小不']='小不封控:BAAAKgAECgcIBwAAAA==.',['小屹']='小屹屹:BAABKgAECn8wAAQcAAgIVxCvIwBoAQAcAAgIVxCvIwBoAQAUAAQIbAQHaQB4AAAdAAEIAADmkAAAAAAAAA==.',['小手']='小手儿冰凉凉:BAABKgAFFH8KAAMFAAYIwQrjHQAYAQAFAAYIwQrjHQAYAQAEAAQILwkYFgCxAAAAAA==.',['小柒']='小柒柒:BAAAKgAECggICAAAAA==.',['小狐']='小狐狸萌萌:BAAAKgAECgUIBgAAAA==.',['小祭']='小祭司三三:BAABKgAFFH8GAAIJAAUIyhiVEADhAAAJAAUIyhiVEADhAAABKgAFFAgICAAJALsbAA==.',['小糯']='小糯米丨拾柒:BAAAKgAECggICAAAAA==.',['小绵']='小绵羊:BAAAKgAECgcIBwAAAA==.',['小胖']='小胖鸟:BAAAKgAECgUICgAAAA==.',['小色']='小色牛:BAAAKgAECgEIAQAAAA==.',['小阿']='小阿四:BAAAKgAECgUIBQAAAA==.',['小鸡']='小鸡比波:BAAAKgADCgIIAgAAAA==.',['尐尐']='尐尐戀歌:BAABKgAFFH8GAAIUAAYIJBfsEQAiAQAUAAYIJBfsEQAiAQAAAA==.',['尼查']='尼查德深:BAAAKgAECgIIAgAAAA==.',['岂曰']='岂曰无衣:BAABKgAFFH8SAAIeAAYIjRPkEgA8AQAeAAYIjRPkEgA8AQAAAA==.',['左泪']='左泪必须死:BAAAKgAECgcIDgAAAA==.',['布响']='布响丸喇:BAAAKgAECgEIAQAAAA==.',['布布']='布布果:BAAAKgAECgYICwAAAA==.',['布鲁']='布鲁諾:BAAAKgAECgMIBwAAAA==.',['帅得']='帅得被人砍啊:BAAAKgADCgIIAgAAAA==.',['希爾']='希爾瓦納斯丶:BAAAKgAECggICAAAAA==.',['帕莉']='帕莉:BAAAKgAECgIIAgAAAA==.',['弓如']='弓如霹雳弦惊:BAEAKgAFFAMIBAAAAA==.',['弗泽']='弗泽亚莱因丝:BAAAKgAECgUIBgAAAA==.',['强颜']='强颜欢笑:BAAAKgAFFAgIAwAAAA==.',['彩虹']='彩虹会飞:BAAAKgAECgYIBgAAAA==.',['彷徨']='彷徨的老人:BAAAKgADCggICAAAAA==.',['彼得']='彼得:BAAAKgAFFAQIBAAAAA==.',['御戥']='御戥:BAABKgAFFH8IAAIeAAQI9x+9DQCGAQAeAAQI9x+9DQCGAQABKgAFFAgIBAAfAAAAAA==.',['微笑']='微笑着说放弃:BAAAKgAFFAYIBAAAAA==.',['微胖']='微胖:BAAAKgADCgYIBwAAAA==.',['德灬']='德灬辉:BAAAKgAECgIIAgAAAA==.',['德玛']='德玛西亚云图:BAAAKgADCgUIBQAAAA==.',['心若']='心若止水:BAAAKgADCggICAAAAA==.',['怀瑜']='怀瑜握瑾:BAABKgAFFH8HAAIJAAYI8BvuBAA1AQAJAAYI8BvuBAA1AQAAAA==.',['性光']='性光照耀大地:BAAAKgAFFAQIBAAAAA==.',['恺丶']='恺丶屹:BAAAKgAFFAQIBAAAAA==.',['恺屹']='恺屹:BAAAKgAECgYICwAAAA==.',['愤怒']='愤怒主播万峰:BAAAKgAECgEIAQAAAA==.',['慕雪']='慕雪浅浸初冬:BAAAKgADCggICAAAAA==.',['成都']='成都男孩:BAAAKgAECgYIBgAAAA==.',['我十']='我十步杀一人:BAABKgAECn8mAAMLAAgICyBQEAApAgALAAgICyBQEAApAgAKAAEIjgbJgQApAAAAAA==.',['战场']='战场小蝙蝠:BAAAKgADCgMIAwAAAA==.',['打小']='打小屁孩:BAAAKgAFFAEIAQAAAA==.',['执笔']='执笔灬江山:BAAAKgAECgUIBwAAAA==.',['扶她']='扶她:BAAAKgAFFAIIAwAAAA==.',['抱着']='抱着弩:BAABKgAECn8cAAIEAAcIGST7DAB0AgAEAAcIGST7DAB0AgAAAA==.',['拉普']='拉普雷斯:BAAAKgADCgEIAQAAAA==.',['拐子']='拐子嗦边边:BAAAKgAECggICAAAAA==.拐子姐:BAAAKgAECgUICAAAAA==.',['指着']='指着太阳说日:BAAAKgAFFAgIAgAAAA==.',['振魂']='振魂醒身:BAABKgAFFH8QAAIVAAYIIiQqAQDxAQAVAAYIIiQqAQDxAQAAAA==.',['摇摆']='摇摆的拜拜肉:BAAAKgAECgQIBAAAAA==.',['旋风']='旋风腿:BAAAKgAECgEIAwAAAA==.',['无敌']='无敌最俊朗:BAAAKgADCggICAAAAA==.无敌死骑:BAAAKgADCggICAAAAA==.',['时天']='时天使阿蒙:BAAAKgAFFAYIBAAAAA==.',['星夜']='星夜与风:BAABKgAFFH8FAAIOAAUISg8lDgAYAQAOAAUISg8lDgAYAQAAAA==.',['星星']='星星陨落之夜:BAAAKgAECgIIBAAAAA==.',['星烨']='星烨:BAAAKgAECgIIAgAAAA==.',['星际']='星际旅行:BAAAKgADCggICAAAAA==.',['春眠']='春眠白雪:BAABKgAECn8dAAIBAAcI2gaLTAC5AAABAAcI2gaLTAC5AAAAAA==.',['昵芭']='昵芭冻冻:BAABKgAFFH8GAAITAAYIDR5pAwDZAQATAAYIDR5pAwDZAQAAAA==.昵芭夕夕:BAABKgAFFH8LAAMcAAYIcw/fDAAxAQAcAAYIcw/fDAAxAQAUAAQIBxqICADyAAAAAA==.',['晓星']='晓星沉:BAAAKgAFFAIIAwAAAA==.',['晨星']='晨星之光:BAAAKgADCgUIBQAAAA==.',['晶晶']='晶晶公主:BAABKgAFFH8IAAIPAAgI6RazAgAVAgAPAAgI6RazAgAVAgAAAA==.',['暖巷']='暖巷:BAAAKgAECgYICQAAAA==.',['暴走']='暴走小猫咪:BAAAKgAECgUIBQABKgAFFAYIBAAfAAAAAA==.',['暴风']='暴风之箭艾希:BAAAKgADCgUIBQAAAA==.',['曼八']='曼八奥特:BAAAKgADCgIIAQAAAA==.',['曼曼']='曼曼:BAAAKgAECgIIAgAAAA==.',['曾经']='曾经和尚:BAAAKgAFFAQIBAAAAA==.',['最郁']='最郁闷的情绪:BAAAKgAECgMIAwAAAA==.',['月下']='月下寒阶:BAAAKgADCggICAAAAA==.',['月影']='月影诡魅:BAAAKgAECgYIDAAAAA==.',['末末']='末末殇:BAABKgAFFH8GAAMEAAYIbgl9FAC9AAAEAAQI5wt9FAC9AAAFAAIItwUFRgCJAAAAAA==.',['杀手']='杀手不太冷:BAAAKgAFFAIIAgAAAA==.',['来啊']='来啊小妞:BAAAKgAECgQICAAAAA==.来啊美眉丶:BAABKgAECn8ZAAIBAAgI+xYrMQCvAQABAAgI+xYrMQCvAQAAAA==.来啊萝莉:BAAAKgAECgIIAgAAAA==.',['杨浦']='杨浦小阿三:BAAAKgAECgYIBwAAAA==.',['柔软']='柔软的土肥圆:BAABKgAFFH8OAAMQAAYIAhSmEwB+AQAQAAYIAhSmEwB+AQAHAAQIDxYjGQDXAAAAAA==.',['柚小']='柚小牧:BAABKgAFFH8OAAQcAAgIfRkkAQDtAQAcAAYItx8kAQDtAQAUAAQIiRX0EQAiAQAdAAQIPhvlFQDkAAAAAA==.',['桃也']='桃也丶雾漫漫:BAAAKgAECgUIBQAAAA==.桃也雾漫漫:BAABKgAFFH8LAAIDAAQI6w5VJgDYAAADAAQI6w5VJgDYAAAAAA==.',['桃色']='桃色小象:BAAAKgAECgIIAgAAAA==.',['梁小']='梁小无拆:BAABKgAECn8YAAIJAAgIjxReNQChAQAJAAgIjxReNQChAQAAAA==.',['梦中']='梦中逢衍:BAACKgAFFH8IAAMDAAIIbA1gPQCNAAADAAIIbA1gPQCNAAARAAIIZwVPGwBPAAAqAAQKfxUAAgMACAgGGclPAAMCAAMACAgGGclPAAMCAAAA.',['梦里']='梦里看花:BAAAKgAECgQIBAAAAA==.',['梦鱼']='梦鱼得鹿:BAABKgAECn8WAAIVAAgIAhzVDABDAgAVAAgIAhzVDABDAgAAAA==.',['梨果']='梨果:BAAAKgADCgcIBwAAAA==.',['梵音']='梵音:BAAAKgADCggICAAAAA==.',['樱桃']='樱桃花时雨:BAAAKgAECgQIBAAAAA==.',['橋本']='橋本丶有菜:BAAAKgAFFAQIBAAAAA==.',['橙吉']='橙吉大师:BAAAKgADCgYIBgAAAA==.',['欧小']='欧小尕:BAAAKgADCggICAAAAA==.',['欧皇']='欧皇之力:BAABKgAFFH8NAAIbAAgILRkpCwAcAQAbAAgILRkpCwAcAQAAAA==.',['武圣']='武圣关羽:BAAAKgADCgEIAQAAAA==.',['残丶']='残丶雅风:BAABKgAFFH8FAAIaAAUIhgzbFAAGAQAaAAUIhgzbFAAGAQAAAA==.',['毁在']='毁在伱手里:BAAAKgADCgYIBgAAAA==.',['比上']='比上的风大:BAAAKgAFFAIIAgAAAA==.',['比黑']='比黑暗更寂静:BAAAKgAFFAMIBAAAAA==.',['氪萝']='氪萝蒂鸭:BAAAKgAECgMIAwAAAA==.',['沉思']='沉思录:BAABKgAECn8YAAIDAAgIagJ7SgFhAAADAAgIagJ7SgFhAAAAAA==.',['法术']='法术风暴:BAAAKgADCggICgAAAA==.',['法神']='法神挖的:BAAAKgADCgEIAQAAAA==.',['注意']='注意你的态度:BAAAKgAECgMIAwAAAA==.',['洒满']='洒满:BAACKgAFFH8OAAIIAAMIUxYdEgDWAAAIAAMIUxYdEgDWAAAqAAQKfx8AAwgACAiTHJ4SAD0CAAgACAiTHJ4SAD0CAAkAAQjoC4C7AC4AAAAA.',['流光']='流光嗌彩:BAACKgAFFH8UAAMJAAYIARw5CQB6AQAJAAYIARw5CQB6AQAIAAQIqh8ZEgDWAAAqAAQKfykAAwgACAgoILcEAIkCAAgACAgoILcEAIkCAAkABwhCGVExALMBAAAA.流光追月神:BAAAKgAECgMIAwAAAA==.',['浅殇']='浅殇灬:BAAAKgADCgQIBAAAAA==.',['浅酌']='浅酌低唱:BAAAKgAECgQIBAAAAA==.',['浪浪']='浪浪山白夜:BAAAKgADCgEIAQAAAA==.',['海拉']='海拉:BAAAKgAECggICAAAAA==.',['深蓝']='深蓝中浅蓝:BAAAKgADCgEIAQAAAA==.',['湖人']='湖人总冠军:BAABKgAECn8VAAQLAAgI8xxnQAAKAQALAAUIbh1nQAAKAQAMAAII+BcbLwCSAAAKAAMIlRkCXgB+AAAAAA==.',['湮花']='湮花不侍:BAAAKgAECgIIAgABKgAECggIGAAKAJEYAA==.湮花不待:BAABKgAECn8UAAMOAAgI1B0dKQDcAQAOAAUIISEdKQDcAQAPAAgI9BPOGgB6AQAAAA==.',['滴答']='滴答滴答:BAAAKgAECgEIAQAAAA==.',['灌注']='灌注给我土爹:BAAAKgAFFAQIBAABKgAFFAgICAAIAEwYAA==.',['灬壹']='灬壹拾叁:BAAAKgADCggICAAAAA==.',['灬梦']='灬梦魇编织者:BAABKgAFFH8IAAILAAgI1hQ8CQD5AQALAAgI1hQ8CQD5AQAAAA==.',['灬楓']='灬楓之貓貓灬:BAAAKgAECgIIAgAAAA==.',['灰烬']='灰烬之刃:BAAAKgAFFAgIBAABKgAFFAgICAAPAAcPAA==.',['灵兰']='灵兰:BAAAKgAECgEIAQAAAA==.',['炎血']='炎血:BAAAKgADCgMIAwAAAA==.',['炮神']='炮神大魔王:BAAAKgAECgMIAwAAAA==.',['炽热']='炽热之火:BAAAKgAECggIDwAAAA==.',['烈酒']='烈酒烫喉:BAAAKgADCgQIBAAAAA==.',['無尽']='無尽怒火:BAAAKgAECgYIBgAAAA==.',['無訫']='無訫:BAABKgAFFH8FAAIJAAMI3A5jHACXAAAJAAMI3A5jHACXAAAAAA==.',['煌黑']='煌黑龙:BAACKgAFFH8TAAQDAAMItBfaPwDyAAADAAMItBfaPwDyAAARAAMIKQv9CwCYAAASAAMIGwxvIAB7AAAqAAQKfxQABAMACAjvEwaZABsBAAMABAhqGwaZABsBABEABQhuEX0yANIAABIABgj/Crc2ALkAAAAA.',['熊猫']='熊猫烧香:BAABKgAFFH8KAAIDAAQIFSPODQAdAQADAAQIFSPODQAdAQAAAA==.',['熹微']='熹微晨巷:BAABKgAECn8WAAMGAAUImhFeDwD/AAAGAAUI4g1eDwD/AAAEAAIIchIPhABzAAAAAA==.',['爆炸']='爆炸输出:BAAAKgAFFAYIBAABKgAECggIJwAdAI4fAA==.',['爆锤']='爆锤大老表:BAABKgAFFH8FAAMJAAQIMA+9EwDWAAAJAAQIMA+9EwDWAAAZAAEIdQ/RFgBUAAAAAA==.',['爵丨']='爵丨天下:BAAAKgADCggICAAAAA==.',['父亲']='父亲:BAAAKgAECggICAAAAA==.',['牛乂']='牛乂甩甩:BAABKgAFFH8GAAIEAAYILw2pFwAqAQAEAAYILw2pFwAqAQAAAA==.',['牛乖']='牛乖乖:BAAAKgADCgUIBQAAAA==.',['特怀']='特怀德:BAABKgAFFH8JAAIQAAMI6gw/PAC2AAAQAAMI6gw/PAC2AAAAAA==.',['狐狸']='狐狸爪子:BAAAKgAECggIDgAAAA==.',['狗蛋']='狗蛋助我:BAAAKgAECgQIBAAAAA==.',['狡诈']='狡诈的圣光:BAABKgAECn8WAAMUAAgIORkIHwDMAQAUAAgIJRkIHwDMAQAdAAcIxRH+NgBAAQAAAA==.',['狩猎']='狩猎的蛋蛋:BAAAKgAFFAQIBAAAAA==.',['猎心']='猎心姬:BAABKgAECn8VAAMEAAgI8gyPYgDPAAAEAAgI8gyPYgDPAAAFAAgIAAAAAAAAAAAAAA==.',['猫猫']='猫猫头:BAAAKgAFFAYIBAAAAA==.',['王梓']='王梓墨:BAAAKgAFFAQIBAAAAA==.',['王者']='王者来也:BAABKgAFFH8IAAIbAAgI6BJwBwAhAgAbAAgI6BJwBwAhAgAAAA==.',['珐师']='珐师的荣耀丿:BAAAKgAECggICgAAAA==.',['珼萱']='珼萱婧:BAAAKgAFFAQIBAAAAA==.',['瓜迪']='瓜迪奥拉:BAABKgAFFH8HAAMSAAcI3QkdEwDiAAASAAQIHA0dEwDiAAADAAMIiAXCcQCHAAAAAA==.',['瓦史']='瓦史托德:BAABKgAFFH8LAAMOAAQIxiGgDQAEAQAOAAQIxiGgDQAEAQAPAAMIRgJ+HgBqAAABKgAFFAgIDwAdAM4XAA==.',['甜恩']='甜恩静:BAAAKgAECgQIBAAAAA==.',['田螺']='田螺鸭脚煲:BAAAKgADCggICAAAAA==.',['电能']='电能使者永信:BAAAKgAFFAQIBAAAAA==.',['疯牛']='疯牛一代:BAACKgAFFH8HAAMHAAMIMgj0KACBAAAHAAMIMgj0KACBAAAQAAIIeQHzWgBHAAAqAAQKfxUAAwcACAjDDiMzACMBAAcABwjMDyMzACMBACAABQhZCCwjAIIAAAAA.',['白巧']='白巧克力牛:BAAAKgADCggICAAAAA==.',['白煞']='白煞灬牛蜀黍:BAABKgAFFH8GAAISAAYI/AvqEQDvAAASAAYI/AvqEQDvAAAAAA==.',['白雪']='白雪女王:BAAAKgAECgYIBgAAAA==.',['百变']='百变星君:BAAAKgAFFAYIAgAAAA==.',['皮卡']='皮卡伊布:BAAAKgAECggIEQAAAA==.',['盲人']='盲人揼邪骨:BAAAKgAECgEIAQAAAA==.',['看淡']='看淡这个世界:BAACKgAFFH8IAAISAAgIlCI2AQDOAgASAAgIlCI2AQDOAgAqAAQKfxUAAhEACAhTFcsUAMYBABEACAhTFcsUAMYBAAAA.',['眞实']='眞实:BAABKgAFFH8JAAIBAAMItxYKCgDeAAABAAMItxYKCgDeAAAAAA==.',['真龙']='真龙:BAABKgAECn8hAAIeAAgIrxB7KwBhAQAeAAgIrxB7KwBhAQAAAA==.',['眼前']='眼前一灰:BAAAKgAECgIIAgAAAA==.眼前一绿:BAAAKgADCggICAAAAA==.',['磊哥']='磊哥哥:BAAAKgAECgEIAQAAAA==.',['祝您']='祝您永不便秘:BAABKgAFFH8IAAIdAAgIjwtvBACrAQAdAAgIjwtvBACrAQAAAA==.',['神经']='神经沐沐:BAAAKgAECggIDQAAAA==.',['福宝']='福宝:BAABKgAFFH8FAAIXAAUImAgDEAC0AAAXAAUImAgDEAC0AAAAAA==.',['稚拙']='稚拙:BAAAKgADCgUIBQAAAA==.',['立正']='立正丶:BAABKgAECn8pAAMhAAgIPR8OCwAJAgAhAAgIPR8OCwAJAgAQAAYIaxQ8ZQAqAQABKgAFFAgIIAANAJYbAA==.',['竹影']='竹影丶清风:BAABKgAFFH8RAAMSAAYIohMLDAA3AQASAAYIlRMLDAA3AQADAAQIKg0vZACmAAAAAA==.',['等风']='等风来丶:BAAAKgAECgEIAQAAAA==.',['簿暮']='簿暮晨光:BAABKgAECn8fAAIQAAgIgA95UQBrAQAQAAgIgA95UQBrAQAAAA==.',['糯米']='糯米丨小鮮花:BAAAKgAECggICAAAAA==.',['糯糯']='糯糯小比噶:BAAAKgAECgIIAgAAAA==.',['紅茶']='紅茶兔子:BAAAKgAECgcIBwAAAA==.',['紫梦']='紫梦星辰:BAABKgAFFH8OAAMdAAYIShEeDQBEAQAdAAYISwseDQBEAQAUAAQILhNOKAChAAABKgAFFAgIFAAUACwaAA==.',['經典']='經典萬達:BAABKgAFFH8KAAINAAYISx83CADXAQANAAYISx83CADXAQAAAA==.',['繁華']='繁華丶落尽:BAAAKgAECgYIBgAAAA==.',['红圣']='红圣:BAAAKgADCgcIBwAAAA==.',['红领']='红领章:BAABKgAFFH8OAAMDAAYI7SBuCQA0AQASAAYIwx2RBwCZAQADAAQISyRuCQA0AQAAAA==.',['红鲤']='红鲤鱼绿鲤鱼:BAABKgAFFH8IAAIdAAgIrQ++BQDdAQAdAAgIrQ++BQDdAQAAAA==.',['约定']='约定云龙出海:BAAAKgADCgMIAwAAAA==.',['纯粹']='纯粹灬忽悠你:BAAAKgAECgUIBQAAAA==.',['细雨']='细雨江南:BAABKgAECn8ZAAMDAAgIHxRkcAB1AQADAAgIHxRkcAB1AQASAAEIswIdXgAUAAAAAA==.',['经典']='经典七七:BAABKgAFFH8SAAMBAAgILRybAwDAAQATAAgILhV4BgD7AQABAAYI6B2bAwDAAQAAAA==.经典万达:BAAAKgADCggICAAAAA==.经典阿帕次:BAABKgAFFH8GAAIaAAYItBXeCgCeAQAaAAYItBXeCgCeAQAAAA==.经典食客:BAAAKgADCggICAAAAA==.经典黑白:BAAAKgAFFAQIBAAAAA==.',['给朕']='给朕跪下丶:BAAAKgAECggIBQABKgAFFAgIEgAdAB4aAA==.',['维罗']='维罗尼卡军曹:BAAAKgAECgIIAgAAAA==.',['绿洲']='绿洲小奶牛:BAACKgAFFH8MAAMIAAMIBQ61FwC5AAAIAAMIBQ61FwC5AAAJAAIIChmSHwCbAAAqAAQKfxUAAwkACAgHF8BEAHUBAAkABwgUGsBEAHUBAAgABAjcDvtOAN8AAAAA.',['绿绿']='绿绿:BAABKgAECn8ZAAMJAAgIxRu8JgDmAQAJAAgIxRu8JgDmAQAIAAIIpARFgAAdAAAAAA==.',['缺徳']='缺徳组我:BAABKgAFFH8GAAIQAAYIQhPOFQBqAQAQAAYIQhPOFQBqAQAAAA==.',['罗丶']='罗丶斯:BAAAKgAFFAQIBAAAAA==.',['美少']='美少女壮士:BAABKgAFFH8GAAIJAAYIaBI8EQBLAQAJAAYIaBI8EQBLAQAAAA==.',['羴骉']='羴骉犇猋:BAAAKgAECgcIBwAAAA==.',['老挝']='老挝盾牌兵:BAAAKgAECgUIDAAAAA==.',['聖光']='聖光大領主:BAAAKgAFFAIIAgAAAA==.',['肆吉']='肆吉财:BAAAKgADCgcIBwAAAA==.',['肉蛋']='肉蛋葱击:BAAAKgAECgEIAQAAAA==.',['肥头']='肥头大耳:BAAAKgAECgMIAwAAAA==.',['肥皂']='肥皂你好肥:BAAAKgAECgEIAQAAAA==.',['胜德']='胜德太子:BAAAKgADCgIIAgAAAA==.',['脚板']='脚板:BAAAKgAFFAYIBAAAAA==.',['膏锋']='膏锋锷:BAAAKgAECgcICwAAAA==.',['艾似']='艾似星辰:BAAAKgADCgYIBgAAAA==.艾似疾风:BAAAKgAECgMIAwAAAA==.',['芋头']='芋头:BAAAKgAFFAYIBAAAAA==.',['芝麻']='芝麻糊:BAAAKgADCggICAAAAA==.芝麻蛋:BAAAKgAECgQIBAAAAA==.',['花大']='花大妞:BAAAKgAFFAQIAgAAAA==.',['花猪']='花猪咪:BAAAKgAECgEIAQAAAA==.',['花田']='花田:BAAAKgAECggICAABKgAFFAgIAgAfAAAAAA==.',['芳心']='芳心纵火犯:BAAAKgAECggIDQAAAA==.',['苇浅']='苇浅:BAAAKgADCggICAAAAA==.',['茉莉']='茉莉乌龙:BAABKgAFFH8IAAIDAAgITxJlCQATAgADAAgITxJlCQATAgAAAA==.',['茜瑞']='茜瑞:BAAAKgADCgIIAgAAAA==.',['莉莉']='莉莉亚斯:BAAAKgAFFAUIBAAAAA==.',['莓烦']='莓烦恼:BAAAKgAFFAEIAQAAAA==.',['萧葑']='萧葑魄谇:BAAAKgAECgMIAwAAAA==.',['萨拉']='萨拉利丝:BAACKgAFFH8WAAMBAAcILBe8CgAbAQACAAQI9g+4FwAmAQABAAMIySC8CgAbAQAqAAQKfxcAAwEACAi6JC0HANMCAAEACAi6JC0HANMCABMABAj8EKN8AI4AAAAA.',['萨狗']='萨狗的召唤:BAAAKgAECgEIAQAAAA==.',['落忆']='落忆:BAAAKgAECgcIBwAAAA==.',['葆蝶']='葆蝶家:BAAAKgAECgcIBwAAAA==.',['葡萄']='葡萄搏击者:BAAAKgADCgQIBAAAAA==.葡萄无面者:BAAAKgAECgQIBQAAAA==.葡萄治愈者:BAAAKgAFFAEIAQAAAA==.葡萄黑牛牛:BAAAKgAECgYICwAAAA==.',['蓝色']='蓝色马里奥:BAAAKgAECgYICgAAAA==.',['薄暮']='薄暮晨光:BAABKgAECn9AAAQHAAgIPSBUDgA9AgAHAAgIPSBUDgA9AgAQAAUIwBEWgQDUAAAgAAYIJAuMIgCHAAAAAA==.',['虫下']='虫下月易:BAACKgAFFH8aAAMQAAgI1RK0CAAWAgAQAAgI1RK0CAAWAgAgAAMIlQyjCQB0AAAqAAQKfyIAAiAACAiqFaIRAI8BACAACAiqFaIRAI8BAAAA.',['血溺']='血溺:BAABKgAFFH8OAAMOAAYI3h+uCgDjAQAOAAYI3h+uCgDjAQAPAAYIbRCCEgAOAQAAAA==.',['血血']='血血加加:BAABKgAFFH8GAAIcAAYIgRd6CwBHAQAcAAYIgRd6CwBHAQAAAA==.',['西柚']='西柚奶糖:BAAAKgAFFAEIAQABKgAFFAUIFQALAEQkAA==.',['西红']='西红柿:BAAAKgAECgIIAgAAAA==.',['西街']='西街的尼采:BAABKgAFFH8HAAMCAAQIXBj2IADkAAACAAMIXBj2IADkAAATAAQItQ8DIQDSAAAAAA==.',['西装']='西装逗:BAAAKgAECgQIBAAAAA==.',['让左']='让左泪死:BAABKgAECn8YAAQKAAgIkRhiKgBRAQAKAAcILxBiKgBRAQALAAMI+RfjUADMAAAMAAMIdBZXIwDDAAAAAA==.',['豆腐']='豆腐大魔王:BAAAKgAFFAIIAgAAAA==.',['豌豆']='豌豆射手:BAABKgAECn8aAAQEAAgIzhnXHQAOAgAEAAgIpxnXHQAOAgAFAAUIYhNVlgCdAAAGAAEIAACCGwAAAAAAAA==.',['贫道']='贫道粗通剑法:BAAAKgAECgMIAwAAAA==.',['贼酷']='贼酷不爱笑:BAAAKgAECggICgAAAA==.',['起名']='起名都烦了:BAAAKgAECggICAAAAA==.',['轻裹']='轻裹你的风:BAABKgAFFH8IAAINAAQISBtVDQAGAQANAAQISBtVDQAGAQAAAA==.',['达菲']='达菲鸭:BAABKgAFFH8GAAIVAAYIwQgjFAAHAQAVAAYIwQgjFAAHAQAAAA==.',['过期']='过期:BAAAKgAECgEIAQAAAA==.',['迷逗']='迷逗白:BAAAKgAFFAQIBAAAAA==.',['逆天']='逆天丶凋零者:BAABKgAFFH8OAAIaAAgICRVuBgAcAgAaAAgICRVuBgAcAgAAAA==.逆天发威沙暴:BAAAKgAECgIIAgAAAA==.逆天大地:BAAAKgAFFAYIBAAAAA==.',['逝水']='逝水柔情:BAAAKgAFFAYIAQAAAA==.',['遇術']='遇術临瘋:BAAAKgAECgMIAwAAAA==.',['道士']='道士不好惹:BAAAKgAECgYIBQABKgAFFAMIDgAIAFMWAA==.',['邋遢']='邋遢大叔:BAAAKgADCgEIAQAAAA==.邋遢大哥:BAABKgAFFH8GAAISAAYIuxHoDQAeAQASAAYIuxHoDQAeAQAAAA==.',['钢铁']='钢铁之手:BAABKgAFFH8GAAMZAAYIaxKvDADlAAAZAAQIGw+vDADlAAAJAAIIuQF3QACGAAAAAA==.',['铁甲']='铁甲依然在:BAAAKgAFFAQIBAABKgAFFAgIDwADADMfAA==.',['银河']='银河之心:BAAAKgAECgIIAgAAAA==.',['锅炉']='锅炉爷爷:BAABKgAFFH8GAAIBAAYIYxm1BgBfAQABAAYIYxm1BgBfAQAAAA==.',['闪现']='闪现否:BAAAKgAECgMIAwAAAA==.',['闪电']='闪电风暴:BAACKgAFFH8TAAIIAAMIbhKaCgDbAAAIAAMIbhKaCgDbAAAqAAQKfykAAggACAjcH6UVAD4CAAgACAjcH6UVAD4CAAAA.',['阐述']='阐述你的梦:BAAAKgADCggIDwAAAA==.',['阿博']='阿博洛迪忒:BAAAKgAECggICAAAAA==.',['阿润']='阿润润:BAAAKgAFFAQIBAABKgAFFAgICQADAKIYAA==.',['阿贝']='阿贝贝:BAAAKgAECgYIBgAAAA==.',['陨星']='陨星:BAAAKgADCggICAAAAA==.',['雅菲']='雅菲缇莉丝:BAAAKgADCgcIBwAAAA==.',['雇佣']='雇佣军亚瑟:BAAAKgAECggIEQAAAA==.',['雪舞']='雪舞:BAAAKgAECgcIBwAAAA==.',['雲焑']='雲焑:BAABKgAFFH8GAAIDAAYI0RlAGACbAQADAAYI0RlAGACbAQAAAA==.',['雷丨']='雷丨疯:BAAAKgAFFAYIBAABKgAFFAgIEgAdAB4aAA==.',['雷罚']='雷罚天尊:BAAAKgAECgIIAgAAAA==.',['雾丨']='雾丨:BAAAKgAECgMIAwAAAA==.',['雾中']='雾中寻鹿:BAACKgAFFH8QAAIDAAQIxSTICgArAQADAAQIxSTICgArAQAqAAQKfzYAAgMACAjsJqkAACwDAAMACAjsJqkAACwDAAEqAAUUCAggAA0AlhsA.',['霍伦']='霍伦赫布斯:BAABKgAECn8WAAIJAAgI5hhELgDQAQAJAAgI5hhELgDQAQAAAA==.',['霸气']='霸气无双:BAABKgAECn8UAAMYAAcIKRU8CwCbAQAYAAcIxRQ8CwCbAQANAAYI7RFHTAAyAQAAAA==.',['霹雳']='霹雳闪电鞭:BAAAKgAFFAQIBAAAAA==.',['青椰']='青椰芝士:BAAAKgAECgMIAQAAAA==.',['静听']='静听花儿开:BAABKgAFFH8IAAIUAAgIUAiwBwB4AQAUAAgIUAiwBwB4AQAAAA==.',['非欢']='非欢:BAAAKgADCggICAAAAA==.',['風之']='風之瀦潴:BAABKgAFFH8UAAQLAAgI7iMkBQBKAgALAAgI7iMkBQBKAgAKAAQIXBZwDQDKAAAMAAEIAADwIwAAAAAAAA==.',['风中']='风中风:BAAAKgAECgYIDAAAAA==.',['风之']='风之猎手:BAAAKgAECgEIAQAAAA==.',['风吹']='风吹沙:BAAAKgAECgcIBwAAAA==.',['风琳']='风琳:BAAAKgAECggICAAAAA==.',['风酔']='风酔里一剣:BAABKgAFFH8FAAIYAAUIZhoWDwAgAQAYAAUIZhoWDwAgAQAAAA==.',['风骚']='风骚乐乐哥:BAAAKgADCggICwAAAA==.',['飞影']='飞影绝尘:BAABKgAFFH8IAAIaAAgIwQl/BQAFAgAaAAgIwQl/BQAFAgAAAA==.',['食铁']='食铁兽:BAAAKgADCggIEAAAAA==.',['香芋']='香芋甜筒:BAAAKgAECgIIAgAAAA==.',['香草']='香草生椰拿铁:BAAAKgAECgMIAwAAAA==.',['騎丶']='騎丶仕:BAAAKgAFFAIIAgAAAA==.',['鬼五']='鬼五延:BAAAKgAECgMIAwAAAA==.',['魔神']='魔神笔笔:BAAAKgAFFAQIBAAAAA==.',['鲁智']='鲁智森:BAACKgAFFH8TAAMVAAQI1h00HAC8AAAVAAQI1h00HAC8AAAXAAIIMg45EgB7AAAqAAQKfxgAAhUACAjQHO8KAIkBABUACAjQHO8KAIkBAAAA.',['鲍抱']='鲍抱:BAABKgAECn8kAAMNAAgIURQNLgB7AQANAAcIEhYNLgB7AQAiAAgIDw3XGgAzAQAAAA==.',['鸡肥']='鸡肥蛋大:BAAAKgAFFAQIBAAAAA==.',['麥洛']='麥洛汀朵:BAAAKgAECgQIBgAAAA==.',['麻辣']='麻辣王子:BAAAKgAECggICAAAAA==.',['黄泉']='黄泉:BAAAKgAECgUIBgAAAA==.',['黑夜']='黑夜丶雨蘅:BAAAKgAECgUIBQAAAA==.',['黑暗']='黑暗丶游侠:BAAAKgADCgEIAQAAAA==.',['黑牛']='黑牛战:BAAAKgAECgcICwAAAA==.',['黑猫']='黑猫:BAAAKgAECgQIBAAAAA==.',['龙傲']='龙傲天:BAAAKgAFFAgIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end