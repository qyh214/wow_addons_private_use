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
 local lookup = {'DeathKnight-Frost','Mage-Frost','Mage-Arcane','DemonHunter-Havoc','Warlock-Destruction','Monk-Windwalker','Druid-Balance','Hunter-Marksmanship','Priest-Holy','Paladin-Retribution','Paladin-Holy','Evoker-Devastation','Evoker-Preservation','Hunter-BeastMastery','Rogue-Assassination','Warrior-Protection','Druid-Feral','Druid-Restoration','Monk-Mistweaver','Warlock-Affliction','Warlock-Demonology','Priest-Discipline','Paladin-Protection','Shaman-Elemental','DeathKnight-Unholy','DeathKnight-Blood','Shaman-Restoration','Warrior-Arms','Warrior-Fury','Mage-Fire','DemonHunter-Vengeance','Priest-Shadow',}; local provider = {region='CN',realm='托尔巴拉德',name='CN',type='weekly',zone=42,date='2025-08-08',data={De='Deviltrigger:BAAAKgADCggICAAAAA==.',Dh='Dh:BAAAKgAFFAMIAwAAAA==.',Gk='Gk:BAAAKgADCgMIAwAAAA==.',Hg='Hgkghk:BAAAKgAFFAQIBAAAAA==.',Ke='Kelvins:BAAAKgAFFAMIAwAAAA==.',Lo='Louiselys:BAABKgAFFH8GAAIBAAYIkg3KAwBoAQABAAYIkg3KAwBoAQAAAA==.',Mo='Move:BAACKgAFFH8eAAMCAAQIIh1RDwDoAAACAAQIIh1RDwDoAAADAAEIAADLKwAAAAAqAAQKfy0AAgIACAgQImYQAH0CAAIACAgQImYQAH0CAAAA.',Ni='Nibusiwude:BAAAKgADCgcICwAAAA==.',Pe='Pein:BAAAKgADCgQIBAAAAA==.',Pl='Plhyn:BAAAKgAFFAgIAgAAAA==.',Ro='Roldmandh:BAABKgAFFH8IAAIEAAgIUg+iCgDfAQAEAAgIUg+iCgDfAQAAAA==.',Sp='Spectral:BAABKgAFFH8MAAIEAAYIFhmHDgCbAQAEAAYIFhmHDgCbAQABKgAFFAYICAAFAKUbAA==.',Tk='Tkin:BAAAKgADCgEIAQAAAA==.',Wy='Wysl:BAAAKgAECgQIBAAAAA==.',['一举']='一举拿下:BAAAKgADCggICAAAAA==.',['一代']='一代宗师叶问:BAAAKgAECgIIAgAAAA==.',['一小']='一小只狐:BAAAKgADCgcIBwAAAA==.',['一杯']='一杯二鍋頭:BAAAKgADCgEIAQAAAA==.',['一根']='一根破树枝:BAAAKgAECgEIAQAAAA==.',['七六']='七六出溜:BAABKgAECn8VAAIGAAgI0BjfFAAGAgAGAAgI0BjfFAAGAgAAAA==.',['不礼']='不礼貌:BAAAKgADCgUIBQAAAA==.',['不说']='不说话:BAABKgAFFH8HAAIHAAcIGxlfCQAFAgAHAAcIGxlfCQAFAgAAAA==.',['不顺']='不顺眼:BAAAKgAECgEIAQAAAA==.',['不领']='不领情:BAAAKgADCgIIAgAAAA==.',['不高']='不高兴:BAAAKgADCgQIBAAAAA==.',['专打']='专打没成年:BAABKgAECn8XAAIIAAgIXgt4ZQDFAAAIAAgIXgt4ZQDFAAAAAA==.',['丨猫']='丨猫内灬:BAAAKgADCggICAAAAA==.',['丶不']='丶不学无术丶:BAAAKgAFFAMIAwAAAA==.',['丶养']='丶养成生活:BAAAKgAECgcIBwAAAA==.',['丷兰']='丷兰诺丷:BAAAKgAFFAMIBAAAAA==.',['丿夜']='丿夜丶允儿灬:BAABKgAECn8WAAIJAAgICRSDLgBsAQAJAAgICRSDLgBsAQAAAA==.丿夜丶大海彡:BAAAKgADCggICQAAAA==.丿夜丶舞曲:BAAAKgAECgYIBgAAAA==.丿夜丶萨仨灬:BAAAKgAECgcIBwAAAA==.',['人红']='人红橙多:BAABKgAFFH8GAAMKAAYIqhyoBABzAQAKAAUIox6oBABzAQALAAEIPxC1EgBeAAAAAA==.',['低薪']='低薪蛮兵:BAAAKgAFFAEIAQAAAA==.',['佐妈']='佐妈妈:BAAAKgAECgYIBgAAAA==.',['你的']='你的相好:BAAAKgAFFAgIBAAAAA==.',['依然']='依然心痛:BAAAKgAECgEIAQAAAA==.',['假装']='假装高手:BAAAKgAECgIIAgAAAA==.',['光的']='光的狗腿子:BAAAKgAECgcICwAAAA==.',['克拉']='克拉克休:BAACKgAFFH8MAAIMAAMIkg53FQC+AAAMAAMIkg53FQC+AAAqAAQKfyYAAwwACAiRHBkHADgCAAwACAiRHBkHADgCAA0ABAjjD3QVAJEAAAEqAAUUBwgeAAQAlRQA.',['克莱']='克莱曼汀:BAAAKgAECgMIAwAAAA==.',['八尺']='八尺江的奶水:BAAAKgADCgEIAQAAAA==.',['军团']='军团海:BAAAKgAECgYIBwAAAA==.',['冰霜']='冰霜勇者:BAAAKgAECgQICAAAAA==.冰霜烈焰:BAAAKgAECggIEgAAAA==.',['冻梨']='冻梨:BAAAKgADCggICAAAAA==.',['凝夏']='凝夏丶:BAAAKgAECggIDgAAAA==.',['几斤']='几斤几两:BAABKgAFFH8RAAMCAAMIgBJrFACMAAADAAMIFwcfHgCTAAACAAMI1RBrFACMAAAAAA==.',['凶矛']='凶矛无鬙:BAAAKgAECgcIEAAAAA==.',['凸尼']='凸尼老师凹:BAAAKgAFFAEIAQAAAA==.',['凹暖']='凹暖降:BAAAKgADCgEIAgAAAA==.',['刘茹']='刘茹雅:BAABKgAFFH8GAAIDAAYIjQxqFABBAQADAAYIjQxqFABBAQAAAA==.',['剑廿']='剑廿叁:BAAAKgAECggIDwAAAA==.',['副科']='副科长:BAAAKgAFFAMIAwAAAA==.',['北之']='北之极致:BAAAKgADCggIFQAAAA==.',['北大']='北大方小猎牛:BAABKgAFFH8GAAIOAAYIyBLlEQBoAQAOAAYIyBLlEQBoAQAAAA==.北大方小雌牛:BAAAKgAECggICAAAAA==.',['北极']='北极的雨:BAABKgAECn8ZAAIPAAgIEQvpHwB8AQAPAAgIEQvpHwB8AQAAAA==.北极的雪:BAAAKgADCggICAAAAA==.',['北郡']='北郡气质哥:BAACKgAFFH8MAAIQAAQI0gdsEAB7AAAQAAQI0gdsEAB7AAAqAAQKfxUAAhAACAhVBSIvALwAABAACAhVBSIvALwAAAAA.',['午夜']='午夜寂落幽魂:BAAAKgAECgIIAgAAAA==.',['卡在']='卡在名字:BAAAKgAFFAQIBAAAAA==.',['卡德']='卡德喵:BAABKgAECn8hAAMRAAgIIwtREQCFAQARAAgIIwtREQCFAQASAAEIKQKzmQAJAAAAAA==.',['厚朴']='厚朴生地:BAAAKgAFFAQIBAAAAA==.',['原味']='原味乐事:BAAAKgAECgYIBgAAAA==.',['反手']='反手上膛:BAAAKgAECgMIAwAAAA==.',['可乐']='可乐薯条:BAAAKgADCgYIBgAAAA==.',['可怜']='可怜的小无奈:BAABKgAFFH8SAAIFAAMIuxT5KADKAAAFAAMIuxT5KADKAAAAAA==.',['吥懂']='吥懂夜的黑:BAACKgAFFH8LAAITAAgI0hXpBAAJAgATAAgI0hXpBAAJAgAqAAQKfxsAAhMACAj0IJwNADkCABMACAj0IJwNADkCAAAA.',['吼哟']='吼哟:BAACKgAFFH8jAAQUAAYIUhUrCgDkAAAUAAMICRkrCgDkAAAVAAMITBa8DwC+AAAFAAQIihT0NQCYAAAqAAQKfzkABAUACAi5JPgRAFoCAAUACAiPJPgRAFoCABQAAwiqIeYaABgBABUABAgLJWxEAOAAAAAA.',['哆啦']='哆啦一梦:BAAAKgAECgYICgAAAA==.',['哇型']='哇型男:BAAAKgADCgIIAgAAAA==.',['哐哐']='哐哐丶蛋逼:BAABKgAFFH8GAAIKAAYIFA/gJgBNAQAKAAYIFA/gJgBNAQAAAA==.',['嘞噜']='嘞噜的小冲儿:BAAAKgAECgQIBAAAAA==.',['嘿瞧']='嘿瞧那个逗比:BAAAKgADCgEIAQAAAA==.',['噬魂']='噬魂丶猎:BAACKgAFFH8cAAMIAAgIrCGtAADYAQAIAAgIrCGtAADYAQAOAAYIPBf8DABnAQAqAAQKfxIAAw4ABwgdJGZbAJ4BAA4ABwgdJGZbAJ4BAAgAAwi+G1FgANYAAAAA.',['四修']='四修骑士:BAAAKgAFFAMIAwAAAA==.',['四夕']='四夕丶:BAAAKgAECggICgAAAA==.',['圣光']='圣光圆舞曲:BAAAKgAFFAYIAgAAAA==.圣光忽悠着:BAAAKgADCggICAAAAA==.',['圣息']='圣息者爱萝米:BAACKgAFFH8dAAIJAAQIDyM+EwAYAQAJAAQIDyM+EwAYAQAqAAQKfycAAwkACAj8I/gMAG4CAAkACAh5I/gMAG4CABYABQhaI0YoAJMBAAAA.',['圣老']='圣老黑:BAAAKgADCgQIBAAAAA==.',['圣锤']='圣锤的指引:BAAAKgAFFAYIAQAAAA==.',['圣骑']='圣骑不好骑:BAAAKgAECggICwAAAA==.',['埃辛']='埃辛诺斯乄殇:BAABKgAFFH8KAAIEAAgIrBAHEwBiAQAEAAgIrBAHEwBiAQAAAA==.',['墨琉']='墨琉璃:BAAAKgAECgEIAQAAAA==.',['夏沫']='夏沫秋秋:BAAAKgAECggIBgAAAA==.',['夜尽']='夜尽丶天明:BAAAKgAECgIIAgAAAA==.',['夜涩']='夜涩幽兰:BAACKgAFFH8QAAIXAAgIMBwhAwAaAgAXAAgIMBwhAwAaAgAqAAQKfxQAAgoACAgwH/c8ADgCAAoACAgwH/c8ADgCAAAA.',['大宝']='大宝锅:BAAAKgAECgMIAwAAAA==.',['大白']='大白小细腰儿:BAAAKgAECgEIAQAAAA==.大白小蛮腰儿:BAAAKgAECgIIAgAAAA==.',['天哪']='天哪我真高啊:BAACKgAFFH8eAAIEAAcIlRQ2AQACAgAEAAcIlRQ2AQACAgAqAAQKf3MAAgQACAgmJL4DANcCAAQACAgmJL4DANcCAAAA.',['奈奈']='奈奈丶:BAAAKgAECggIEAAAAA==.',['妙手']='妙手丶肥肥:BAAAKgAECgQIBQAAAA==.',['安妮']='安妮宝贝灬:BAABKgAECn8bAAIYAAgIbhlbKAC0AQAYAAgIbhlbKAC0AQAAAA==.',['对月']='对月而笑:BAAAKgAFFAIIAgAAAA==.',['射到']='射到你满意:BAAAKgAECgIIAgAAAA==.',['小七']='小七灬:BAAAKgAECgEIAQAAAA==.',['小狮']='小狮子儿:BAABKgAFFH8GAAIEAAMINAaJOACeAAAEAAMINAaJOACeAAAAAA==.',['小狼']='小狼雪糕:BAABKgAFFH8IAAITAAgIGh06AgB5AgATAAgIGh06AgB5AgAAAA==.',['小鑫']='小鑫要砍人:BAAAKgADCgMIAwAAAA==.',['布兰']='布兰迪:BAABKgAFFH8VAAMTAAUI6ReVDQDWAAATAAUI6ReVDQDWAAAGAAQIbQcREgCeAAABKgAFFAgICAAKACcVAA==.',['德德']='德德打滴:BAAAKgAECggICQABKgAFFAgIEQASAD4jAA==.',['忘忧']='忘忧君:BAAAKgAFFAgIAwAAAA==.',['恶鱼']='恶鱼丨:BAAAKgAECgEIAQABKgAFFAgIFAAKAM4gAA==.',['悟不']='悟不空:BAAAKgAFFAYIAgABKgAFFAgICAAKAPgOAA==.',['惊鲵']='惊鲵:BAAAKgAECgIIAgAAAA==.',['慕容']='慕容铁柱:BAAAKgADCggICAAAAA==.',['我从']='我从不特别:BAAAKgADCgYIBgAAAA==.',['我痒']='我痒了:BAAAKgAECgEIAQAAAA==.',['打团']='打团先奶我:BAABKgAFFH8GAAIFAAYIKAdJIQD9AAAFAAYIKAdJIQD9AAAAAA==.',['打枪']='打枪的狼:BAAAKgADCgEIAQAAAA==.',['托尼']='托尼老死:BAAAKgAFFAIIBAAAAA==.',['抓走']='抓走小公主:BAAAKgAECgMIAwAAAA==.',['挽风']='挽风歌谣:BAAAKgADCggICAAAAA==.',['插几']='插几下:BAAAKgADCgEIAwAAAA==.',['放肆']='放肆的小飞:BAACKgAFFH8nAAQZAAYITSHxCAD/AQAZAAYITSHxCAD/AQAaAAYImhSQDgAzAQABAAMIgxICCQDYAAAqAAQKfzQAAhkACAjfJFsGAOECABkACAjfJFsGAOECAAEqAAUUCAhCAAgAxCUA.',['无奈']='无奈的小刀:BAABKgAFFH8GAAIJAAMIEQz/KgCXAAAJAAMIEQz/KgCXAAAAAA==.无奈的小可爱:BAAAKgAFFAIIBAAAAA==.',['无情']='无情丶奈奈:BAAAKgAECgYICgAAAA==.',['星向']='星向:BAAAKgAECgIIAgAAAA==.',['星辰']='星辰大海:BAAAKgADCggICAAAAA==.',['晚柠']='晚柠:BAAAKgAECgUICAAAAA==.',['暴走']='暴走丨汉堡:BAAAKgAECgMIAwABKgAECggIGQAKAKkSAA==.',['有趣']='有趣的灵魂:BAAAKgAECgYICQAAAA==.',['木敏']='木敏:BAABKgAFFH8NAAIbAAMI0xv2IQDxAAAbAAMI0xv2IQDxAAAAAA==.',['李阿']='李阿不:BAAAKgAECgcIDgAAAA==.',['柏拉']='柏拉图式魔醻:BAAAKgAECgYIBwAAAA==.',['格兰']='格兰蒂亚:BAABKgAFFH8GAAIKAAMI3Q6XWADAAAAKAAMI3Q6XWADAAAAAAA==.',['桂花']='桂花酱:BAAAKgADCgQIBAAAAA==.',['桑海']='桑海小笼包:BAAAKgAECggICAAAAA==.',['梦寻']='梦寻乄千古殇:BAABKgAFFH8QAAQcAAgIdx3lBwCOAQAcAAYIox7lBwCOAQAdAAQIQRgBDQAHAQAQAAYI5w5/BwDxAAAAAA==.',['棒棒']='棒棒糖:BAAAKgAECggICQAAAA==.',['武魔']='武魔:BAABKgAFFH8IAAIZAAgIPg5vBgD7AQAZAAgIPg5vBgD7AQAAAA==.',['求一']='求一个未来:BAABKgAFFH8IAAIJAAMIUhjUIQC+AAAJAAMIUhjUIQC+AAAAAA==.',['法克']='法克酉烙茻:BAAAKgADCgMIAwAAAA==.',['法聖']='法聖:BAAAKgAFFAEIAQAAAA==.',['注定']='注定路过天堂:BAAAKgAECgIIAgAAAA==.',['海嗨']='海嗨烸塰:BAAAKgAECgEIAQAAAA==.',['海蒂']='海蒂:BAAAKgADCgEIAQAAAA==.',['深渊']='深渊之蛙:BAABKgAFFH8IAAIPAAgIABpyBABYAgAPAAgIABpyBABYAgAAAA==.',['温柔']='温柔丶小飞雪:BAAAKgAECgMIAwAAAA==.',['灬凯']='灬凯尔:BAABKgAFFH8KAAQCAAMITQkVGwCnAAACAAMITQkVGwCnAAADAAII+AX5PQBlAAAeAAEIUABLQwAcAAAAAA==.',['灬劦']='灬劦灬:BAABKgAECn8UAAMOAAcIoRIhXABFAQAOAAcIoRIhXABFAQAIAAMIeAQaqwArAAAAAA==.',['灬小']='灬小渔灬:BAABKgAFFH8GAAIJAAMI/QYGGQB5AAAJAAMI/QYGGQB5AAAAAA==.',['炎钰']='炎钰:BAAAKgAECgEIAQAAAA==.',['烟尘']='烟尘拾捌:BAAAKgADCgIIBQAAAA==.',['烟火']='烟火拾壹:BAAAKgADCggICAAAAA==.',['無糖']='無糖:BAAAKgADCgEIBQAAAA==.',['無鎖']='無鎖囚:BAAAKgAECgQIBAAAAA==.',['焱燠']='焱燠:BAAAKgAECgcICAAAAA==.',['熊的']='熊的猫丶:BAAAKgAECgYIBgAAAA==.',['爱莉']='爱莉希雅:BAAAKgADCggICAAAAA==.',['片刀']='片刀砍电线:BAAAKgAECgEIAQAAAA==.',['牢萨']='牢萨陛:BAAAKgAECgIIAgAAAA==.',['狂奔']='狂奔的小狐狸:BAAAKgADCgEIAQAAAA==.',['独上']='独上西楼:BAAAKgAECgYIBwAAAA==.',['狼灬']='狼灬要有气质:BAACKgAFFH8JAAIOAAQIphVWDwAyAQAOAAQIphVWDwAyAQAqAAQKfxgAAg4ACAjNGLQwAOgBAA4ACAjNGLQwAOgBAAAA.',['猫骨']='猫骨头:BAABKgAECn8eAAIFAAgIGQ7lOgCBAQAFAAgIGQ7lOgCBAQAAAA==.',['玛蒂']='玛蒂娜:BAABKgAFFH8IAAMFAAgIOwhSDACDAQAFAAYIGwlSDACDAQAUAAII/QJfEgBGAAAAAA==.',['瓦达']='瓦达西瓦:BAAAKgADCgcIBwAAAA==.',['生姜']='生姜红糖:BAAAKgADCggICAAAAA==.',['留白']='留白:BAABKgAFFH8IAAIOAAMINg7/OgCvAAAOAAMINg7/OgCvAAAAAA==.',['疑似']='疑似高手:BAABKgAFFH8PAAMFAAgI+hWZBwAXAgAFAAgI+hWZBwAXAgAVAAEIgwLTMAA4AAAAAA==.',['百变']='百变星軍:BAAAKgAECgUIBQAAAA==.',['看那']='看那个部落:BAAAKgAECgcICgAAAA==.',['碎花']='碎花:BAAAKgADCgEIAQAAAA==.',['碧玉']='碧玉石:BAAAKgAFFAIIBAAAAA==.',['神农']='神农:BAAAKgAFFAMIAwAAAA==.',['红山']='红山果:BAAAKgADCgQIBAAAAA==.',['纳芙']='纳芙蒂蒂:BAACKgAFFH8KAAMXAAYIWRTkAgBSAQAXAAYIWRTkAgBSAQAKAAIIlQpJSABpAAAqAAQKfy4AAwoACAhRG+ZNAAgCAAoACAhRG+ZNAAgCABcABwjeESonABwBAAAA.',['群星']='群星之弓矢:BAAAKgAECgUIBQAAAA==.',['羽落']='羽落青衣:BAABKgAFFH8FAAICAAMIqAsPHACiAAACAAMIqAsPHACiAAAAAA==.',['聖光']='聖光背叛了我:BAAAKgADCggICAABKgAFFAgICAAPAAAaAA==.',['艾塔']='艾塔利亚:BAAAKgAFFAgIBAAAAA==.',['艾米']='艾米丽语风:BAAAKgAECgYIBgAAAA==.',['芃芃']='芃芃:BAAAKgAECgcICQAAAA==.',['芙莉']='芙莉莲:BAAAKgAECgEIAQABKgAFFAYIFQAaALIVAA==.',['苍狼']='苍狼白鹿:BAABKgAFFH8GAAIOAAYIIgAgMwAUAAAOAAYIIgAgMwAUAAAAAA==.',['苛鲁']='苛鲁斯:BAAAKgADCgMIAwAAAA==.',['菲尔']='菲尔琼斯:BAAAKgAECgYIBgAAAA==.',['萨蕾']='萨蕾娜邪刃:BAABKgAFFH8OAAMfAAMIKgjYGgB7AAAfAAMIlAfYGgB7AAAEAAIIVwTqLwBrAAAAAA==.',['萱儿']='萱儿:BAAAKgAECgUIBQAAAA==.',['蒙特']='蒙特:BAAAKgADCgIIAgAAAA==.',['蓝绸']='蓝绸带:BAAAKgAECgMIAwAAAA==.',['蕯鲁']='蕯鲁法尓:BAABKgAFFH8GAAIaAAYIjwrGFgDrAAAaAAYIjwrGFgDrAAABKgAFFAgIIAAaAFUQAA==.',['蕾娜']='蕾娜兰尼斯特:BAAAKgAECgEIAQAAAA==.',['藿藿']='藿藿:BAAAKgADCggICAAAAA==.',['譬如']='譬如朝露:BAABKgAFFH8KAAMJAAYIkhkqDgDLAAAJAAQIqxYqDgDLAAAgAAIIZRkzFADDAAAAAA==.',['豌豆']='豌豆包:BAAAKgAFFAIIBAAAAA==.',['达摩']='达摩耶:BAABKgAECn8mAAITAAgISBfXMQCGAQATAAgISBfXMQCGAQAAAA==.',['迷一']='迷一般的男人:BAAAKgADCgEIAQAAAA==.',['迷魂']='迷魂片儿:BAAAKgAECgQIBAAAAA==.',['追风']='追风化影:BAAAKgAECggICwAAAA==.',['逆风']='逆风落:BAAAKgAECgIIBAAAAA==.',['道明']='道明寺灬三少:BAAAKgAECgYIBgAAAA==.',['那你']='那你说:BAAAKgAECgQIBAAAAA==.',['醉卧']='醉卧山岗:BAAAKgAECgMIAwAAAA==.',['醉翁']='醉翁:BAAAKgADCgEIAQAAAA==.',['铁手']='铁手既天命:BAAAKgAECggICQAAAA==.',['闪电']='闪电贱不贱:BAAAKgAECgEIAQAAAA==.',['陈六']='陈六胖:BAAAKgAECgIIAgAAAA==.',['陌不']='陌不守:BAABKgAECn8tAAMbAAgIlB4SFwA+AgAbAAgIlB4SFwA+AgAYAAMISwNidgBWAAAAAA==.',['雪梨']='雪梨不加糖:BAABKgAFFH8IAAIeAAgIpQPkBACgAQAeAAgIpQPkBACgAQAAAA==.',['雪色']='雪色蒙昧:BAAAKgAECgcIBwAAAA==.',['雷吉']='雷吉毛:BAAAKgAECgYIBwAAAA==.',['雷豆']='雷豆毛:BAAAKgAECgQIBAAAAA==.',['霜之']='霜之闪电:BAAAKgAECgEIAQAAAA==.',['风来']='风来王:BAABKgAECn8oAAMdAAgIRBywIgAKAgAdAAgIRBywIgAKAgAQAAUIyggeNQByAAAAAA==.',['飞跃']='飞跃疯人院:BAAAKgADCgEIAgAAAA==.',['魔兽']='魔兽与大海:BAAAKgAECgQIBAAAAA==.',['魔婴']='魔婴:BAAAKgAECggICAAAAA==.',['黄天']='黄天在上:BAAAKgAECgUIBQAAAA==.',['龍战']='龍战丶狐狸:BAACKgAFFH8NAAIKAAMIFxj2JADUAAAKAAMIFxj2JADUAAAqAAQKfyYAAgoACAjbIkgUALgCAAoACAjbIkgUALgCAAAA.',['龙哥']='龙哥的猎手:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end