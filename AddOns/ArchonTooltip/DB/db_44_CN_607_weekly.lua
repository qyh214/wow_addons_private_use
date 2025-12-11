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
 local lookup = {'Monk-Windwalker','Shaman-Restoration','Priest-Holy','Priest-Shadow','Paladin-Retribution','Paladin-Protection','Paladin-Holy','DeathKnight-Frost','DemonHunter-Havoc','Warlock-Destruction','Druid-Restoration','Druid-Balance','Warrior-Fury','Warrior-Protection','Monk-Mistweaver','Hunter-BeastMastery','Warlock-Demonology','Rogue-Subtlety','Rogue-Assassination','Druid-Guardian','Druid-Feral','Hunter-Marksmanship',}; local provider = {region='CN',realm='哈兰',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bl='Blala:BAAALAAECgcIBwAAAA==.',Ch='Charlotte:BAAALAAECgIIAQAAAA==.',Dh='Dhs:BAAALAAECgYICwAAAA==.',Dk='Dks:BAAALAAECgcIEwAAAA==.',Dr='Dra:BAAALAAECgYIDwAAAA==.',Du='Duga:BAABLAAECn8ZAAIBAAYI6wy6IAD0AAABAAYI6wy6IAD0AAAAAA==.',Fo='Foxe:BAABLAAECn8WAAICAAYIWA2nWwDzAAACAAYIWA2nWwDzAAAAAA==.',Fw='Fwy:BAAALAAECgcIEQAAAA==.',Go='Goodjobs:BAABLAAFFH8IAAICAAIIRxC0UwBzAAACAAIIRxC0UwBzAAAAAA==.',Ju='Justgame:BAACLAAFFH8TAAIDAAQIvQt1KADrAAADAAQIvQt1KADrAAAsAAQKfxoAAwMABgixFd0oAG8BAAMABgixFd0oAG8BAAQABAgTEiM4AKEAAAEsAAUUBwgqAAMAcw0A.',Ku='Kuon:BAABLAAFFH8SAAQFAAYI2B3ZFQCgAQAFAAYIxhzZFQCgAQAGAAYIsxecBgBnAQAHAAEI0AS2LwA3AAABLAAFFAcIDwAIAKcjAA==.',Ni='Nionjiujiudi:BAAALAAFFAIIAgAAAA==.',Ox='Oxlady:BAAALAAECgYIBgAAAA==.',Su='Sunshine:BAACLAAFFH8gAAIJAAYIzh9OEgDOAQAJAAYIzh9OEgDOAQAsAAQKfxUAAgkABwg4IbYZAA4CAAkABwg4IbYZAA4CAAAA.',Un='Unkown:BAAALAAECgYICgAAAA==.',We='Weiyan:BAAALAAECgEIAgAAAA==.',Wi='Wialler:BAAALAAECgYIBgAAAA==.Winterr:BAAALAADCgUIBQAAAA==.',['一修']='一修法神:BAAALAAECgcICgAAAA==.',['一剑']='一剑中情:BAAALAAECgYIBQAAAA==.',['一曲']='一曲安神:BAAALAAECgEIAQAAAA==.一曲漓殇:BAAALAAECgYIBwAAAA==.',['三千']='三千雷动:BAAALAADCgEIAQAAAA==.',['三雄']='三雄:BAABLAAFFH8GAAIKAAII7xdwRQCRAAAKAAII7xdwRQCRAAAAAA==.',['不會']='不會飛的兔子:BAAALAADCgQIBAAAAA==.',['不能']='不能喝酒:BAAALAAFFAEIAQAAAA==.',['世界']='世界一刘:BAAALAAECgYICwAAAA==.',['东方']='东方树叶子:BAAALAAECgYIBgAAAA==.',['丶冲']='丶冲锋就崴脚:BAAALAAECgYIBgAAAA==.',['丶茶']='丶茶叶灬:BAABLAAFFH8OAAILAAIIRhBgOQBmAAALAAIIRhBgOQBmAAAAAA==.',['乌鲁']='乌鲁咪:BAAALAADCgcIBwAAAA==.',['也许']='也许是爱:BAABLAAFFH8MAAMMAAYIUBK5BQDzAQAMAAYIUBK5BQDzAQALAAYI/hQKFwB7AQAAAA==.',['今晚']='今晚没月亮:BAAALAADCgIIAgAAAA==.',['停车']='停车枫林晚丨:BAAALAAECgYIDAAAAA==.停车枫林晚丿:BAAALAADCgQIBAAAAA==.',['偶尔']='偶尔丶小性感:BAAALAAECgUIBwAAAA==.',['傲世']='傲世小不点:BAAALAADCgEIAQAAAA==.',['八叶']='八叶一刀刀:BAABLAAFFH8LAAINAAYI3hZWDADSAQANAAYI3hZWDADSAQAAAA==.',['其实']='其实丶你很乖:BAAALAAFFAIIAgAAAA==.其实很可爱:BAABLAAFFH8IAAIOAAIIkALBOAAmAAAOAAIIkALBOAAmAAAAAA==.',['农业']='农业射:BAAALAADCgUIBQAAAA==.',['冰疫']='冰疫刃舞:BAAALAAECgEIAQAAAA==.',['冲锋']='冲锋撞闪现:BAAALAAECgEIAQAAAA==.',['剑三']='剑三:BAAALAAECgcIBwAAAA==.',['加藤']='加藤的鹰:BAAALAAFFAMIBAAAAA==.',['北辰']='北辰沙狐:BAAALAADCggICwAAAA==.',['十字']='十字军流浪:BAABLAAFFH8HAAIPAAIILRAkEgCHAAAPAAIILRAkEgCHAAAAAA==.',['千颂']='千颂伊:BAAALAADCgIIAgAAAA==.',['南瓜']='南瓜皮:BAAALAAECgMIAwAAAA==.',['卡射']='卡射起:BAABLAAFFH8FAAIQAAUISRp6EQCfAQAQAAUISRp6EQCfAQAAAA==.',['叛逆']='叛逆小智:BAAALAAECgIIAgAAAA==.',['口合']='口合克克:BAABLAAFFH8MAAIIAAYI8B5PHADFAQAIAAYI8B5PHADFAQAAAA==.口合兢:BAABLAAFFH8GAAIIAAYIkyBGGgDOAQAIAAYIkyBGGgDOAQAAAA==.',['吸血']='吸血鬼丨可可:BAABLAAFFH8FAAICAAIIkAmpZgBUAAACAAIIkAmpZgBUAAAAAA==.吸血鬼丨大可:BAAALAAFFAIIAgAAAA==.吸血鬼丨小可:BAACLAAFFH8JAAIKAAIInwolaQA3AAAKAAIInwolaQA3AAAsAAQKfyQAAgoACAh0HsQxAHUCAAoACAh0HsQxAHUCAAAA.',['周旋']='周旋:BAAALAAECgYIBwAAAA==.',['咔咔']='咔咔起:BAAALAAECggICAAAAA==.',['哈兄']='哈兄兄:BAABLAAFFH8MAAIIAAYIUBjhLACFAQAIAAYIUBjhLACFAQAAAA==.哈兄克:BAABLAAFFH8MAAIIAAYI5RdNJwCYAQAIAAYI5RdNJwCYAQAAAA==.',['哈克']='哈克兄:BAABLAAFFH8MAAIIAAYIdxixLACGAQAIAAYIdxixLACGAQAAAA==.哈克克:BAABLAAFFH8PAAIIAAcIpyPlCgBMAgAIAAcIpyPlCgBMAgAAAA==.哈克兑:BAABLAAFFH8SAAIIAAYI3B/XIACxAQAIAAYI3B/XIACxAQAAAA==.',['哈兑']='哈兑克:BAABLAAFFH8YAAIIAAYIzyIwGwDKAQAIAAYIzyIwGwDKAQAAAA==.',['哈兢']='哈兢:BAABLAAFFH8MAAIIAAYIYR2sIACxAQAIAAYIYR2sIACxAQAAAA==.',['哈蓝']='哈蓝:BAAALAAFFAIIBAAAAA==.',['四条']='四条一百:BAAALAAECgQICAAAAA==.',['圆圈']='圆圈夕阳的你:BAAALAAECgYIBgAAAA==.',['地狱']='地狱来的主任:BAAALAAECgcIBwAAAA==.',['壹粒']='壹粒蛋怒瘋:BAABLAAFFH8GAAIJAAYIZAEBYQA+AAAJAAYIZAEBYQA+AAAAAA==.',['复方']='复方联苯:BAAALAADCgMIAwAAAA==.',['大尾']='大尾巴狸狸:BAAALAAECgYIEgAAAA==.',['大米']='大米弓米弓:BAAALAAECgQIBAAAAA==.',['奥妙']='奥妙的奥:BAAALAADCgIIAgAAAA==.',['奶妈']='奶妈也有梦想:BAAALAAFFAIIAgAAAA==.',['始终']='始终溺于黄昏:BAAALAAECgYIBgAAAA==.',['客官']='客官来呀:BAABLAAFFH8IAAIQAAUIKxBWUwABAQAQAAUIKxBWUwABAQAAAA==.',['小澤']='小澤瑪麗婭:BAABLAAFFH8JAAIQAAYIVAIWagCPAAAQAAYIVAIWagCPAAAAAA==.',['小火']='小火车呜唔污:BAAALAAECgMIAwAAAA==.',['御天']='御天荒神:BAAALAAECgIIAgAAAA==.',['扯淡']='扯淡君:BAAALAADCgEIAQAAAA==.',['抽烟']='抽烟不用烟嘴:BAAALAAECgEIAQAAAA==.',['放开']='放开那只熊猫:BAAALAAECgYIBgAAAA==.',['映秋']='映秋:BAABLAAFFH8IAAIFAAIIICCRUgBQAAAFAAIIICCRUgBQAAAAAA==.',['晌午']='晌午:BAAALAAECgYIBwAAAA==.',['暴风']='暴风:BAABLAAFFH8GAAIIAAYIxQnROwBLAQAIAAYIxQnROwBLAQAAAA==.',['木诗']='木诗:BAAALAAECgYIBgAAAA==.',['松岛']='松岛的枫:BAAALAAECggICAAAAA==.',['欧努']='欧努:BAAALAADCggICAAAAA==.',['每天']='每天都好困:BAAALAAECgYIBgAAAA==.',['沉默']='沉默的熊:BAAALAAECgYIDAAAAA==.',['没事']='没事哒:BAAALAAECgYIBgAAAA==.',['没奶']='没奶别找我:BAAALAAECgEIAQAAAA==.',['泰洛']='泰洛斯丶:BAAALAAECggICAAAAA==.',['灬龍']='灬龍丶之翔灬:BAAALAAECgIIAgAAAA==.',['灭团']='灭团奶德:BAABLAAFFH8GAAIMAAYINwc8CgCHAQAMAAYINwc8CgCHAQABLAAFFAgIDAAMAPYgAA==.',['牛奶']='牛奶不加糖:BAAALAAECgYIBgAAAA==.',['狐三']='狐三:BAAALAAECgIIAgAAAA==.',['王者']='王者的使命:BAAALAAFFAIIBAAAAA==.',['玛德']='玛德增强萨:BAABLAAFFH8IAAILAAIISR7SMwCaAAALAAIISR7SMwCaAAAAAA==.',['玲娜']='玲娜貝兒:BAABLAAFFH8GAAIRAAUINwGoGgAWAAARAAUINwGoGgAWAAAAAA==.',['电波']='电波元气少女:BAACLAAFFH8UAAMFAAUIogqaLwAJAQAFAAUIogqaLwAJAQAHAAUI7QnTGwDNAAAsAAQKfxYABAUACAjOGvIwAM8BAAUABwjmGPIwAM8BAAcABAi8EPEtANUAAAYAAgh7HMo+AEsAAAAA.',['真新']='真新超人:BAAALAAECgYIDAAAAA==.',['矝枔']='矝枔:BAAALAAECgUIBQAAAA==.',['知影']='知影:BAAALAAECgQIBQAAAA==.',['给我']='给我吃口饭:BAAALAAFFAEIAQAAAA==.',['老衲']='老衲有礼了:BAABLAAFFH8IAAIIAAQITxC/UQDSAAAIAAQITxC/UQDSAAAAAA==.',['肖律']='肖律凡:BAAALAAECgYIBgAAAA==.',['育碧']='育碧:BAAALAAECgYIEwAAAA==.',['胖胖']='胖胖的微笑:BAABLAAECn8YAAIQAAYIaw/g+AA4AQAQAAYIaw/g+AA4AQAAAA==.',['自然']='自然蚀刻:BAAALAAECgYICQAAAA==.',['至圣']='至圣仙师:BAABLAAFFH8IAAINAAgIxgBvZgARAAANAAgIxgBvZgARAAAAAA==.',['色如']='色如刮骨钢刀:BAABLAAFFH8KAAIIAAYIQxkpKQCSAQAIAAYIQxkpKQCSAQAAAA==.',['艾莲']='艾莲娜:BAAALAADCgMIAwAAAA==.',['苍井']='苍井的天空:BAAALAAFFAQIBAAAAA==.',['苏菲']='苏菲莉娅:BAAALAADCgEIAQAAAA==.',['英仙']='英仙座:BAAALAAECgUIBQAAAA==.',['莎夏']='莎夏:BAAALAADCgIIAgAAAA==.',['萨玛']='萨玛兰琦:BAAALAAECgQIBAAAAA==.',['虞灬']='虞灬姬:BAAALAADCgYIBgAAAA==.',['超越']='超越神的杀戮:BAAALAADCgYIBgAAAA==.',['辛灬']='辛灬巴:BAABLAAFFH8GAAILAAYIKgcEIAAgAQALAAYIKgcEIAAgAQAAAA==.',['达司']='达司雷玛:BAAALAAECgYIBgAAAA==.',['还取']='还取不上名字:BAABLAAFFH8JAAINAAYI4BE/HACGAQANAAYI4BE/HACGAQAAAA==.',['迪斯']='迪斯路亚:BAAALAAECgQIBAAAAA==.',['遗忘']='遗忘的妳:BAABLAAECn8ZAAIJAAYIHRwLLQClAQAJAAYIHRwLLQClAQAAAA==.',['鑨灬']='鑨灬飝:BAAALAAECgMIAwAAAA==.',['锤石']='锤石的光:BAABLAAFFH8IAAIQAAYInRKgOQBaAQAQAAYInRKgOQBaAQAAAA==.',['长的']='长的帅:BAAALAADCgEIAQAAAA==.',['阿尔']='阿尔冯斯:BAAALAADCgEIAQAAAA==.',['雪山']='雪山飛兔:BAAALAADCggICAAAAA==.',['零零']='零零發:BAAALAAECgYICwAAAA==.',['静默']='静默灬淡颜:BAABLAAFFH8WAAMSAAgIKR11AQCOAgASAAgIKR11AQCOAgATAAMIogmuEQC4AAAAAA==.静默采花:BAACLAAFFH8OAAIUAAMIFxdnBwB8AAAUAAMIFxdnBwB8AAAsAAQKfyAAAxQABggMHAELAIoBABQABggMHAELAIoBABUABgi6C9EWANMAAAAA.',['风中']='风中的木鱼:BAAALAAECgIIAwAAAA==.',['风铃']='风铃:BAAALAADCgEIAQAAAA==.',['飯島']='飯島的愛:BAAALAAFFAIIAgAAAA==.',['黑科']='黑科技:BAACLAAFFH8LAAIQAAIITxnYWgCPAAAQAAIITxnYWgCPAAAsAAQKfyEAAxAABggkIa1yAPcBABAABgj0H61yAPcBABYABAjeF/9mACgBAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end