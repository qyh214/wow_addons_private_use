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
 local lookup = {'DeathKnight-Frost','Hunter-Marksmanship','Paladin-Protection','Mage-Frost','Mage-Arcane','Warrior-Fury','Shaman-Elemental','Rogue-Assassination','Shaman-Restoration','Paladin-Retribution','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Priest-Shadow','Priest-Discipline','Priest-Holy','Warrior-Arms','DeathKnight-Blood','DemonHunter-Havoc','Rogue-Outlaw','Hunter-BeastMastery','DeathKnight-Unholy','Druid-Restoration','Druid-Guardian','Druid-Balance','Unknown-Unknown','Paladin-Holy','Monk-Mistweaver','Monk-Brewmaster','Druid-Feral','Evoker-Devastation','Evoker-Preservation','Shaman-Enhancement','Monk-Windwalker',}; local provider = {region='CN',realm='迦玛兰',name='CN',type='weekly',zone=42,date='2025-08-02',data={Ak='Akiyama:BAAAKgAECgcIBwAAAA==.Akiyaqs:BAAAKgADCgQIBAAAAA==.Akiyaws:BAAAKgADCgYIBgAAAA==.',Ap='Ap:BAAAKgADCgYIBgAAAA==.',Da='Darkhaezs:BAABKgAFFH8FAAIBAAMIrw5RCwDCAAABAAMIrw5RCwDCAAAAAA==.',El='Elis:BAAAKgAFFAgIAgAAAA==.',Gr='Gracy:BAAAKgADCggICAAAAA==.',Gu='Gup:BAAAKgAFFAIIAgAAAA==.',Ha='Halo:BAAAKgADCggICwAAAA==.',Li='Lilbaby:BAAAKgADCgIIAgAAAA==.',Lr='Lr:BAABKgAFFH8IAAICAAgI8wiECQCKAQACAAgI8wiECQCKAQAAAA==.',Me='Merely:BAABKgAFFH8OAAIDAAQIcAx9DgCVAAADAAQIcAx9DgCVAAAAAA==.',Mi='Miao:BAAAKgAFFAQIBAAAAA==.',Mo='Moon:BAAAKgADCgIIAgAAAA==.Moonlight:BAAAKgAFFAMIAwAAAA==.',No='Nogamenolife:BAAAKgAECggIDAAAAA==.Norris:BAAAKgAECgYIBgAAAA==.',Pe='Penknife:BAAAKgAECgMIAwAAAA==.',Su='Sunnimabio:BAABKgAFFH8GAAMEAAQIExzYBgD4AAAEAAQIhBvYBgD4AAAFAAIIiR3wBgBaAAAAAA==.',Sw='Swordsaint:BAABKgAFFH8IAAIGAAgIMxI0BQAtAgAGAAgIMxI0BQAtAgAAAA==.',Wo='Wongfaye:BAAAKgAFFAYIBAAAAA==.',['一卡']='一卡卡:BAABKgAFFH8IAAIFAAgIKRJhCADyAQAFAAgIKRJhCADyAQAAAA==.',['三六']='三六九澫:BAAAKgAECgIIBAAAAA==.',['两岸']='两岸统一:BAACKgAFFH8GAAIFAAYIgB91CwCxAQAFAAYIgB91CwCxAQAqAAQKfzAAAwQACAgnJVIJAL0CAAQACAjjJFIJAL0CAAUACAhfIZkNAI4CAAAA.',['丨电']='丨电闪丶雷鸣:BAABKgAFFH8UAAIHAAQIwhdwEQDbAAAHAAQIwhdwEQDbAAAAAA==.',['乐猫']='乐猫儿:BAABKgAFFH8GAAIIAAYIVBNZBwCYAQAIAAYIVBNZBwCYAQAAAA==.',['乾坤']='乾坤无极:BAAAKgAECgcIBwAAAA==.',['二郎']='二郎险胜真君:BAAAKgAECgEIAQAAAA==.',['二阶']='二阶堂白丸:BAAAKgAECgYICwAAAA==.',['五更']='五更琉璃:BAAAKgAECggICAAAAA==.',['今夜']='今夜不会醉:BAABKgAFFH8HAAIJAAQIlSb3AgBUAQAJAAQIlSb3AgBUAQAAAA==.',['他喵']='他喵熊的力量:BAAAKgAFFAEIAQAAAA==.',['佛洛']='佛洛狄忒:BAAAKgAECgYIBgAAAA==.',['你能']='你能拿我咋办:BAABKgAFFH8IAAIFAAgITQ/JCQDSAQAFAAgITQ/JCQDSAQAAAA==.',['光辉']='光辉岁月:BAABKgAFFH8PAAIKAAYIrxDJJgBNAQAKAAYIrxDJJgBNAQAAAA==.',['其实']='其实我很帅:BAAAKgAECggICAAAAA==.',['冰糖']='冰糖番茄酱:BAAAKgAFFAQIBAAAAA==.',['冷钢']='冷钢:BAAAKgAECgUIBgAAAA==.',['卡卡']='卡卡:BAABKgAFFH8GAAQLAAYIoxNQCQDfAAALAAQIkRFQCQDfAAAMAAEISyHORwBLAAANAAEIMAwpKwBEAAAAAA==.',['口与']='口与瓜:BAABKgAFFH8MAAQOAAYICgs5CgAvAQAOAAYICgs5CgAvAQAPAAQIqQbZDwCFAAAQAAIInQYwGgBsAAABKgAFFAgIDgAMAPkhAA==.',['叨刀']='叨刀:BAACKgAFFH8WAAIKAAQIySLkFQABAQAKAAQIySLkFQABAQAqAAQKfzkAAwoACAhEJB0aAK8CAAoACAhEJB0aAK8CAAMAAwgOGTBUAEkAAAAA.',['吃嫩']='吃嫩草的老牛:BAAAKgADCgMIBQAAAA==.',['呆萌']='呆萌小伯牛:BAAAKgAFFAYIBAAAAA==.',['商陆']='商陆:BAAAKgAECggICAAAAA==.',['啧啧']='啧啧丶:BAABKgAECn8nAAIRAAgIjRaXGADBAQARAAgIjRaXGADBAQAAAA==.',['嘟嘟']='嘟嘟秒黑市:BAABKgAFFH8GAAISAAYI4A12EwAGAQASAAYI4A12EwAGAQAAAA==.',['圣光']='圣光钢管舞:BAAAKgAECgMIAwAAAA==.',['塔格']='塔格奥的咒语:BAAAKgAECgMIAwAAAA==.',['大榴']='大榴莲想滋人:BAABKgAFFH8FAAITAAMIkhe5JgDcAAATAAMIkhe5JgDcAAABKgAFFAMICQAUAMYUAA==.大榴莲想背刺:BAABKgAFFH8JAAIUAAMIxhRSBQDFAAAUAAMIxhRSBQDFAAAAAA==.',['天乐']='天乐:BAAAKgAFFAMIAwAAAA==.',['奈何']='奈何与天齐:BAABKgAECn8bAAITAAgIpRrDDQAXAgATAAgIpRrDDQAXAgAAAA==.',['女射']='女射手李琪薇:BAACKgAFFH8IAAICAAgI0w/ZCgD0AAACAAgI0w/ZCgD0AAAqAAQKfxQAAwIACAhrHzITADkCAAIACAhrHzITADkCABUAAQjwA1cTARsAAAAA.',['孤汪']='孤汪投:BAAAKgAECgMIAwAAAA==.',['学石']='学石油毁一生:BAAAKgAECgIIAgAAAA==.',['容嬷']='容嬷嬷:BAAAKgADCggIGAAAAA==.',['寂寞']='寂寞有毒:BAAAKgADCggIIAAAAA==.',['小毛']='小毛豆:BAAAKgAECggICAAAAA==.',['小诺']='小诺:BAABKgAFFH8MAAMCAAYI4w+qDgAMAQACAAYI+wqqDgAMAQAVAAYIegrjEQAGAQAAAA==.',['尼查']='尼查德泰绅:BAAAKgAECggIEAAAAA==.',['屠师']='屠师傅:BAAAKgADCggICAAAAA==.',['帅气']='帅气的熊熊:BAABKgAFFH8KAAIWAAYIjBXUFAB0AQAWAAYIjBXUFAB0AQAAAA==.',['幕落']='幕落:BAAAKgAECgMIAwAAAA==.',['库附']='库附魔:BAACKgAFFH8lAAIQAAYIjiFQCgB9AQAQAAYIjiFQCgB9AQAqAAQKfzMABBAACAj8IasLAHoCABAACAimIasLAHoCAA4AAwg5FTNAALYAAA8AAgi4Gp9kAJUAAAAA.',['影墨']='影墨:BAAAKgAECgUIBwAAAA==.',['從此']='從此不缺德:BAABKgAFFH8IAAIXAAgI0AsKBQCaAQAXAAgI0AsKBQCaAQAAAA==.',['微风']='微风不燥:BAABKgAFFH8GAAMQAAYIAAuyBwD6AAAQAAUINwmyBwD6AAAOAAEIRwgXIwBQAAAAAA==.',['德了']='德了个德:BAABKgAFFH8PAAMYAAQIxAq4CQBzAAAZAAQIxAp9HwC0AAAYAAMIRAq4CQBzAAAAAA==.',['忄丨']='忄丨忄:BAAAKgAFFAMIAwAAAA==.',['必须']='必须得释放:BAAAKgAECgIIAgAAAA==.',['怡格']='怡格:BAAAKgAFFAMIAwAAAA==.',['恶灵']='恶灵之缚:BAACKgAFFH8KAAIVAAQIdxm4JQDwAAAVAAQIdxm4JQDwAAAqAAQKfyIAAxUABwjEIkkeAEoCABUABwhaIkkeAEoCAAIABQj1Gsw4AHQBAAAA.',['愛喝']='愛喝啤酒的猫:BAAAKgAECggICAAAAA==.',['我不']='我不想释放:BAAAKgAECgQIBAAAAA==.',['我会']='我会乖乖的:BAAAKgAFFAQIBAAAAA==.',['我想']='我想唱首歌:BAAAKgAECgMIAwAAAA==.',['我抬']='我抬手就冲锋:BAAAKgAECgYIBgAAAA==.',['折耳']='折耳根丶:BAACKgAFFH8KAAIKAAQIeiB7HACCAQAKAAQIeiB7HACCAQAqAAQKfxUAAgoACAjFIjshAH0CAAoACAjFIjshAH0CAAAA.',['拉克']='拉克絲丶:BAACKgAFFH8LAAIKAAMIfxhjRwDfAAAKAAMIfxhjRwDfAAAqAAQKfzAAAgoACAi4ICsSADsCAAoACAi4ICsSADsCAAAA.',['无趣']='无趣:BAAAKgAECgUIBQAAAA==.',['无限']='无限坠落:BAAAKgAECgUIBQAAAA==.',['晃晃']='晃晃也能赢:BAAAKgADCggICAAAAA==.',['晓人']='晓人物:BAAAKgAFFAIIAgAAAA==.',['晴舞']='晴舞青猫:BAAAKgAECgIIAgAAAA==.',['月上']='月上风铃:BAAAKgAFFAMIAwAAAA==.',['月华']='月华落幕:BAAAKgAFFAYIAQABKgAFFAgIBAAaAAAAAA==.',['有奶']='有奶便是娘:BAAAKgAECgQIBAAAAA==.',['有绒']='有绒女乃大:BAAAKgAECgYIBgAAAA==.',['木木']='木木夕雨叚:BAABKgAFFH8MAAMKAAYIix0gDgC+AQAKAAYIix0gDgC+AQAbAAYI6QJkCwDzAAAAAA==.木木夕雨霞:BAAAKgAFFAQIBAAAAA==.',['来个']='来个熊猫:BAAAKgAECgQIBAAAAA==.',['标哥']='标哥:BAABKgAECn8hAAIVAAgIJyLjDgCtAgAVAAgIJyLjDgCtAgAAAA==.标哥的表哥:BAABKgAECn8kAAIEAAgI4hzIBwAhAgAEAAgI4hzIBwAhAgAAAA==.',['树忄']='树忄爿:BAABKgAFFH8IAAMcAAQIzgMjKQB6AAAcAAQIzgMjKQB6AAAdAAQIxgUaCQB4AAAAAA==.',['梦破']='梦破:BAAAKgAECggICQAAAA==.',['椒盐']='椒盐锅巴:BAAAKgAECgEIAQAAAA==.',['死了']='死了没埋:BAAAKgAECgMIAwAAAA==.',['毅格']='毅格:BAABKgAFFH8kAAMCAAcIgBwwBgDzAQACAAcIgBwwBgDzAQAVAAEIbBftWABIAAAAAA==.毅格仓库:BAAAKgADCggIBwAAAA==.',['水门']='水门大侠:BAAAKgADCggICgAAAA==.',['法克']='法克劳斯特:BAACKgAFFH8QAAMeAAMINRNlAwDRAAAeAAMINRNlAwDRAAAYAAIIJgw7BQBZAAAqAAQKfx4AAxgACAj3Gv4IAOQBABgACAjdGP4IAOQBAB4ABwgLFRAPALIBAAAA.',['泰兰']='泰兰徳丶喵:BAAAKgAECggICAAAAA==.',['深海']='深海:BAAAKgAECggICAAAAA==.',['深蓝']='深蓝彼岸:BAACKgAFFH8mAAIVAAQIayFQFgD2AAAVAAQIayFQFgD2AAAqAAQKfycAAhUACAivIDklAF8CABUACAivIDklAF8CAAAA.',['湘西']='湘西猫王:BAAAKgAECgYICwAAAA==.',['湮灭']='湮灭法至尊:BAAAKgAFFAIIAgAAAA==.湮灭魔至尊:BAAAKgAFFAEIAQAAAA==.',['灬光']='灬光之子灬:BAAAKgAECggIDQAAAA==.',['灰色']='灰色的光:BAAAKgADCgQIBAAAAA==.',['無月']='無月:BAABKgAFFH8GAAIQAAYIGR/ZBQCwAQAQAAYIGR/ZBQCwAQAAAA==.',['爔澐']='爔澐:BAABKgAFFH8GAAIPAAYImhH0CwBVAQAPAAYImhH0CwBVAQAAAA==.',['爱意']='爱意随钟起:BAABKgAFFH8IAAMHAAMIWgdxGwCgAAAHAAMIWgdxGwCgAAAJAAIIzQiVSgBiAAAAAA==.',['爱的']='爱的罗曼式:BAAAKgAECgMIAwAAAA==.爱的罗猫史:BAAAKgAECgUIBQAAAA==.',['牛内']='牛内面丶:BAACKgAFFH8HAAIGAAQI7RZDEQBCAQAGAAQI7RZDEQBCAQAqAAQKfxgAAgYACAiJHxUPAGkCAAYACAiJHxUPAGkCAAAA.',['玖個']='玖個灵:BAAAKgAECgYICAAAAA==.',['玛里']='玛里苟斯:BAACKgAFFH8SAAIfAAYIzxAQBABnAQAfAAYIzxAQBABnAQAqAAQKfxcAAyAACAjVEY8TAB8BACAABgg2Eo8TAB8BAB8ABAjSHJY5AAgBAAAA.',['琼恩']='琼恩的长爪:BAAAKgAFFAIIAgAAAA==.',['疾风']='疾风者狂爆:BAABKgAFFH8NAAMVAAYIjBGpFgBDAQAVAAYIjBGpFgBDAQACAAQIqwgiFwCoAAAAAA==.',['白白']='白白的女流氓:BAABKgAFFH8GAAICAAYIcxmaDgB1AQACAAYIcxmaDgB1AQAAAA==.',['看不']='看不到释放:BAAAKgAECgMIAwAAAA==.',['短短']='短短:BAAAKgAECgYIBwAAAA==.',['破日']='破日狂魔:BAABKgAFFH8TAAIFAAYIjiNiCADxAQAFAAYIjiNiCADxAQAAAA==.',['碎星']='碎星将军:BAAAKgAECggICAAAAA==.',['神棍']='神棍丨德:BAAAKgAECgQIBQAAAA==.',['秋晓']='秋晓:BAAAKgAECgcICgAAAA==.',['秋晚']='秋晚枫:BAAAKgAFFAEIAQAAAA==.',['第九']='第九特区:BAABKgAFFH8GAAMOAAYIERESEwDMAAAOAAMI/QcSEwDMAAAPAAMIvh2CFQCzAAAAAA==.',['聖丶']='聖丶法天神霊:BAABKgAFFH8KAAQJAAYIjBYaBQA0AQAJAAUIKBMaBQA0AQAHAAEI1A9VFwBXAAAhAAEIewBcHgA2AAAAAA==.',['聪明']='聪明的肉肉:BAAAKgAECgYIBgAAAA==.',['肆雨']='肆雨:BAAAKgADCgIIAgAAAA==.',['花花']='花花灼灼:BAAAKgADCgcICwAAAA==.',['若叶']='若叶睦:BAAAKgAFFAIIAgAAAA==.',['若无']='若无其事:BAAAKgAECgEIAQAAAA==.',['菠萝']='菠萝大神:BAABKgAFFH8dAAMNAAQI9RTpFgCRAAAMAAQIhQ8QLQC5AAANAAIIEBjpFgCRAAAAAA==.',['蓝夏']='蓝夏仟寻:BAAAKgADCgIIAgAAAA==.蓝夏千寻:BAAAKgADCggICAAAAA==.蓝夏阡寻:BAAAKgAECgYIBgAAAA==.',['蓝色']='蓝色卡卡:BAAAKgAECgYIBgAAAA==.',['薅毋']='薅毋尥:BAAAKgADCggICAAAAA==.',['蚩尤']='蚩尤:BAAAKgAECggICAAAAA==.',['诚小']='诚小子:BAAAKgAFFAQIBAAAAA==.',['诺宝']='诺宝:BAABKgAFFH8OAAQPAAYIPSAhBgDPAQAPAAYIjB4hBgDPAQAQAAUIpRfUEgAbAQAOAAIIEiM+GAC6AAAAAA==.',['诺诺']='诺诺:BAABKgAFFH8RAAIJAAYI7BrTCwCKAQAJAAYI7BrTCwCKAQAAAA==.',['谢逊']='谢逊:BAAAKgADCggICAAAAA==.',['遗忘']='遗忘的圣骑:BAABKgAECn8lAAIKAAgI4R6uOAAdAgAKAAgI4R6uOAAdAgAAAA==.',['那年']='那年物是人非:BAAAKgAECgEIAQAAAA==.',['酒桶']='酒桶王:BAAAKgADCgMIAwAAAA==.',['释星']='释星魂:BAABKgAECn8UAAIKAAgIChfBkQB0AQAKAAgIChfBkQB0AQAAAA==.',['钩吻']='钩吻:BAABKgAFFH8FAAMdAAUItA9jBACwAAAdAAQIuRNjBACwAAAiAAEIowNcGgBWAAAAAA==.',['阿宝']='阿宝同学:BAABKgAFFH8TAAIEAAMIMxarFADEAAAEAAMIMxarFADEAAAAAA==.',['阿毛']='阿毛:BAAAKgAECgYIBgAAAA==.',['阿萨']='阿萨斯砍:BAACKgAFFH8RAAMWAAMIBB76DgAGAQAWAAMIBB76DgAGAQASAAMIEQYEKgBtAAAqAAQKfycAAxYACAiIIfoTAGwCABYACAiIIfoTAGwCABIACAh3EEEiADcBAAEqAAUUCAgGABYAQxUA.',['陈韬']='陈韬毅格:BAAAKgAECgIIAgAAAA==.',['随風']='随風之葉:BAAAKgADCgQIBAAAAA==.',['風寒']='風寒:BAAAKgAECggIDgAAAA==.',['风吹']='风吹老牛:BAAAKgADCggIEwAAAA==.',['风火']='风火雷电雨:BAAAKgAFFAYIAwAAAA==.',['飛火']='飛火灬流星:BAAAKgADCggIEAAAAA==.',['騎只']='騎只貓:BAABKgAECn8cAAIYAAYIfBCtFgD0AAAYAAYIfBCtFgD0AAAAAA==.',['黑手']='黑手牛:BAAAKgAFFAQIBAAAAA==.',['龙之']='龙之骑:BAABKgAFFH8OAAMDAAYI4RbACgBNAQADAAYI4RbACgBNAQAbAAYI/Q3iBgBLAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end