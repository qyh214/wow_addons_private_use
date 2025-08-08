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
 local lookup = {'Mage-Arcane','Mage-Fire','Shaman-Elemental','Shaman-Restoration','Priest-Discipline','Mage-Frost','DeathKnight-Blood','DeathKnight-Unholy','Warrior-Fury','Hunter-Survival','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Druid-Restoration','DemonHunter-Havoc','Druid-Balance','Paladin-Retribution','Paladin-Protection','Monk-Mistweaver','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Warrior-Arms','Priest-Shadow','Unknown-Unknown','Paladin-Holy',}; local provider = {region='CN',realm='泰拉尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aiolia:BAAAKgAECgUIBQAAAA==.',Bl='Bloodivan:BAAAKgADCggICQAAAA==.',Fr='Frostmoon:BAAAKgAECggICAAAAA==.',Ha='Harris:BAABKgAFFH8FAAMBAAMI9AMANgCKAAABAAMI9AMANgCKAAACAAII7QAuPABEAAAAAA==.',Mo='Moondeity:BAAAKgAECgYIDgAAAA==.',Oo='Oom:BAAAKgAECgUIBwAAAA==.',St='Stormmars:BAAAKgAECgYIBgAAAA==.',Vd='Vdh:BAAAKgADCggICAAAAA==.',Vz='Vzs:BAAAKgAECgUIBQAAAA==.',Ya='Yanhoneylove:BAAAKgAECgMIAwAAAA==.',['一身']='一身正气:BAAAKgAECgYIBgAAAA==.',['三井']='三井血受:BAAAKgAECgcIBwAAAA==.',['不睡']='不睡懒觉豆豆:BAABKgAFFH8GAAIDAAYIqx4ABgCQAQADAAYIqx4ABgCQAQAAAA==.',['丝丝']='丝丝暧昧丶:BAAAKgAFFAYIBAABKgAFFAgICAAEALsbAA==.',['丢丢']='丢丢兔兔:BAABKgAFFH8GAAIFAAYIQRaYCQCBAQAFAAYIQRaYCQCBAQAAAA==.',['丧尸']='丧尸:BAABKgAFFH8MAAMGAAMIXQs1FQCIAAABAAMIAAi2MQCdAAAGAAIIXw81FQCIAAAAAA==.',['丨无']='丨无灬双丨:BAABKgAFFH8GAAMHAAQIaAGFMABKAAAHAAQIVwGFMABKAAAIAAIIhAHNUgBGAAABKgAFFAgIDgAIAEoXAA==.',['丨鬼']='丨鬼丿魅丨:BAAAKgADCggICAAAAA==.',['丹丹']='丹丹熊:BAAAKgAFFAMIAwAAAA==.',['为了']='为了糖果:BAAAKgAECgIIAgAAAA==.',['九月']='九月十八:BAAAKgADCgIIAgAAAA==.',['井荷']='井荷花:BAAAKgAECgcIBwAAAA==.',['交个']='交个什么:BAAAKgADCgQIBAAAAA==.',['仴橆']='仴橆凊寒:BAACKgAFFH8KAAIJAAII7AjQIQCHAAAJAAII7AjQIQCHAAAqAAQKfyAAAgkACAhbG0EaAP8BAAkACAhbG0EaAP8BAAAA.仴橆靈殇:BAACKgAFFH8JAAQKAAYIOw+NAgDZAAAKAAQIYxWNAgDZAAALAAIIgBBjJACGAAAMAAII/gXlPQCBAAAqAAQKfzoAAwsACAglHQ0PACgCAAsACAjEHA0PACgCAAwABQgTGlhLACMBAAAA.',['传说']='传说的恶魔:BAAAKgADCgMIAwAAAA==.传说的法爷:BAAAKgADCggICAAAAA==.',['伤恨']='伤恨寒冰枪:BAABKgAECn8dAAIGAAgICg7TQwBYAQAGAAgICg7TQwBYAQAAAA==.',['佐佐']='佐佐木绯世:BAAAKgAFFAYIBAAAAA==.',['你可']='你可真高:BAAAKgADCgcIBwAAAA==.',['你就']='你就是块木头:BAACKgAFFH8fAAMFAAYIPg7WDwDbAAAFAAYIPg7WDwDbAAANAAMIUgVCMACFAAAqAAQKfyYAAgUACAjiHnYMAG0CAAUACAjiHnYMAG0CAAAA.',['倚楼']='倚楼聼风雨:BAAAKgAECgUIBQAAAA==.',['傲娇']='傲娇娇:BAAAKgAECgEIAQAAAA==.',['傲雪']='傲雪灬寒霜:BAAAKgAECgYIBgAAAA==.',['八级']='八级小狂风:BAAAKgAECgQIBAAAAA==.',['兵临']='兵临城下:BAAAKgAECgYIBgAAAA==.',['冬天']='冬天没有风:BAAAKgAECgUIBwAAAA==.',['冰楓']='冰楓回忆:BAAAKgAECgYIBgAAAA==.',['冰火']='冰火震天:BAAAKgAFFAIIAgAAAA==.',['冷月']='冷月寒心:BAAAKgAFFAIIBAAAAA==.',['凉月']='凉月清风:BAAAKgAFFAYIAgABKgAFFAgICgAOAO0VAA==.',['凤影']='凤影之恋:BAAAKgAECggIDAAAAA==.',['刀舞']='刀舞:BAAAKgAECgYIDAAAAA==.',['刺客']='刺客大师:BAAAKgADCgIIAgAAAA==.',['化水']='化水的老油皮:BAAAKgAECgEIAQAAAA==.',['十二']='十二:BAAAKgADCggICAAAAA==.',['十字']='十字勋章:BAAAKgAECgYIEQAAAA==.',['可爱']='可爱的熊熊:BAABKgAFFH8XAAIMAAQI/A3uMwCiAAAMAAQI/A3uMwCiAAAAAA==.',['吃我']='吃我一火球:BAAAKgAECgIIAgAAAA==.',['君临']='君临天下:BAABKgAFFH8GAAIPAAYIXRzREAB8AQAPAAYIXRzREAB8AQAAAA==.',['吟灬']='吟灬灰狼:BAAAKgAECgUIBQAAAA==.',['咖啡']='咖啡丨因:BAAAKgAECggIEgAAAA==.',['哆唻']='哆唻咪法:BAAAKgAFFAQIBAAAAA==.',['哎呦']='哎呦你干嘛:BAAAKgADCgYIBgAAAA==.',['哔哩']='哔哩吧啦嘭:BAAAKgAFFAQIBAAAAA==.哔哩吧啦崩:BAAAKgAECgYIBgAAAA==.哔哩哔哩嘣:BAABKgAFFH8GAAIBAAYI6wpDGAAiAQABAAYI6wpDGAAiAQABKgAFFAgIHAAQADYlAA==.',['哥微']='哥微微一笑:BAAAKgAECgIIAgAAAA==.',['哦哦']='哦哦救护队:BAAAKgADCgQIBAAAAA==.',['啊哈']='啊哈你干嘛:BAAAKgADCgQIBAAAAA==.',['嗳卟']='嗳卟後悔:BAAAKgAFFAIIAgAAAA==.',['回首']='回首暮云远:BAABKgAFFH8KAAMRAAQIZySpEQAOAQASAAQIMSJ6DQAjAQARAAQI2xipEQAOAQAAAA==.',['围攻']='围攻伯拉勒斯:BAAAKgAFFAgIAQAAAA==.',['圣光']='圣光救赎:BAAAKgAECgQIBAAAAA==.',['埃斯']='埃斯蒂尼安:BAAAKgAECgYIBgAAAA==.',['墩儿']='墩儿:BAAAKgADCggICQAAAA==.',['多鸠']='多鸠鱼:BAAAKgAFFAQIBAAAAA==.',['夜丶']='夜丶风:BAABKgAECn8vAAIRAAgIvSKnHQCiAgARAAgIvSKnHQCiAgAAAA==.',['夜舞']='夜舞飞扬:BAAAKgAECgQIBAAAAA==.',['夜色']='夜色樱桃:BAAAKgAECgEIAQAAAA==.',['大力']='大力龙:BAAAKgAECggICAAAAA==.',['大酋']='大酋长:BAAAKgADCggIDwAAAA==.',['奈何']='奈何不是仙:BAAAKgAFFAEIAgAAAA==.',['奈莉']='奈莉莎:BAABKgAECn8YAAITAAYIuSC2KAC3AQATAAYIuSC2KAC3AQAAAA==.',['契约']='契约之瞳:BAAAKgAECgQIBAAAAA==.',['奥林']='奥林花园:BAAAKgAECggICAAAAA==.',['奶油']='奶油派浪浪:BAAAKgADCgEIAQAAAA==.',['孤胆']='孤胆胖胖:BAAAKgAECgIIAwAAAA==.',['安娜']='安娜贝尔:BAAAKgAECgIIAgAAAA==.',['小蝌']='小蝌蚪找媽媽:BAAAKgAECgQIBAAAAA==.',['就一']='就一箭丶:BAAAKgAFFAQIBAAAAA==.',['布袋']='布袋:BAAAKgAECgMIBAAAAA==.',['常暄']='常暄凌:BAAAKgAECgYICwAAAA==.',['年年']='年年:BAAAKgADCggICQAAAA==.',['幸福']='幸福一家:BAAAKgAECgUIBQAAAA==.',['幻蝶']='幻蝶:BAAAKgAECgYIBwAAAA==.',['弋弌']='弋弌弍弎丶:BAABKgAECn8WAAIRAAgIyhNmeQBfAQARAAgIyhNmeQBfAQAAAA==.',['弓喜']='弓喜发财:BAAAKgAECgQIBQAAAA==.',['影之']='影之潮汐:BAACKgAFFH8FAAMUAAMIQRPHCgCWAAAUAAIISBXHCgCWAAAVAAEIMg8nKgA8AAAqAAQKfxYABBQACAgGIWAaAAcBABQAAwhSH2AaAAcBABYABAixHLY/APQAABUAAwjrIqdUAMEAAAAA.',['影歌']='影歌之月:BAACKgAFFH8GAAIPAAMIvA5FGgDcAAAPAAMIvA5FGgDcAAAqAAQKfyEAAg8ACAjfIJwXAHgCAA8ACAjfIJwXAHgCAAAA.',['彼岸']='彼岸的圣光:BAAAKgAECgIIAgAAAA==.',['征讨']='征讨者夏娜:BAAAKgADCggICAAAAA==.',['救赎']='救赎之路:BAAAKgADCgYIBwAAAA==.',['旋风']='旋风之刃:BAABKgAFFH8KAAMXAAYI4B1WCQB1AQAXAAYILxdWCQB1AQAJAAQIbhctEQD1AAAAAA==.',['晴空']='晴空飞鸟:BAAAKgAFFAQIBAABKgAFFAgICAALAHMNAA==.',['林深']='林深见鹿:BAABKgAFFH8GAAMCAAUI7RliCQBkAQACAAUI7RliCQBkAQAGAAEIAACqMAAAAAAAAA==.',['核弹']='核弹:BAAAKgAFFAIIBAAAAA==.',['楚恋']='楚恋流云:BAABKgAFFH8MAAMSAAYIHRQTAwBNAQASAAYIARETAwBNAQARAAQIVhecEwAIAQABKgAFFAgIEgAEAE4iAA==.',['欢喜']='欢喜兔:BAAAKgAFFAQIBAAAAA==.',['正义']='正义市民小马:BAAAKgAECgQIBAAAAA==.',['水落']='水落伯羿:BAAAKgADCggICAAAAA==.',['流年']='流年:BAAAKgADCggICAAAAA==.',['浪了']='浪了哩个啷:BAAAKgAFFAIIAgAAAA==.',['海棠']='海棠朵朵:BAAAKgADCgIIAgAAAA==.',['海盗']='海盗猎手:BAABKgAFFH8FAAIMAAUI6A8aHgACAQAMAAUI6A8aHgACAQAAAA==.',['消失']='消失的叶子:BAACKgAFFH8hAAITAAYIxx0uAwCXAQATAAYIxx0uAwCXAQAqAAQKfyoAAhMACAhCGcoUAOoBABMACAhCGcoUAOoBAAAA.消失的喵呜:BAAAKgAECggICAAAAA==.',['涔涔']='涔涔铃音:BAAAKgAECgYIBgAAAA==.',['涔风']='涔风暴烈酒:BAAAKgADCggICAAAAA==.',['涼月']='涼月清風:BAABKgAFFH8MAAIPAAQIVBJ9FQDrAAAPAAQIVBJ9FQDrAAAAAA==.',['深度']='深度莫愁:BAAAKgADCgIIAgAAAA==.',['湮灭']='湮灭之舞:BAAAKgADCgQIBAAAAA==.',['火鸡']='火鸡味锅巴:BAABKgAFFH8GAAMEAAYIcRrtIQDxAAAEAAQI5RftIQDxAAADAAII5Q7AHwB+AAABKgAFFAgIBQAVADUbAA==.',['灬丶']='灬丶荭颜:BAABKgAFFH8GAAIIAAYIshcXEwCCAQAIAAYIshcXEwCCAQAAAA==.',['灬遇']='灬遇术临疯灬:BAABKgAECn8WAAIWAAcI6hy8FADdAQAWAAcI6hy8FADdAQAAAA==.',['爱或']='爱或伤痕:BAAAKgAECgMIBQAAAA==.',['男丶']='男丶德:BAAAKgAECgIIAgAAAA==.',['疯批']='疯批牛牪犇:BAAAKgAECgYIBgAAAA==.',['癫一']='癫一阿癫儿:BAAAKgAECgMIAwAAAA==.',['皮固']='皮固非常养:BAABKgAFFH8NAAMBAAcInyCnBABWAgABAAcIViCnBABWAgAGAAYIvh18AwDEAQAAAA==.',['盾入']='盾入空门:BAABKgAFFH8IAAMNAAQIiCBlAwAtAQANAAQIiCBlAwAtAQAYAAQINBMSGgCvAAAAAA==.',['睡不']='睡不醒的豆豆:BAAAKgAECgcIDAAAAA==.',['瞬间']='瞬间即逝:BAAAKgAFFAIIAgAAAA==.',['穿高']='穿高跟跑百米:BAAAKgAECgcIBwAAAA==.',['紫媚']='紫媚儿:BAAAKgAECgYIBgAAAA==.',['红鲤']='红鲤鱼:BAAAKgAECgEIAQAAAA==.红鲤鱼绿鲤鱼:BAAAKgAECgUIBQAAAA==.',['维罗']='维罗娜拉:BAABKgAECn8VAAQMAAgIrx4YIQDMAQAMAAgIZB4YIQDMAQAKAAYIsBqmDwD6AAALAAII/wg34gBsAAAAAA==.',['美式']='美式加冰:BAAAKgAECgUIBQAAAA==.',['羴骉']='羴骉犇猋丶:BAAAKgAECgYIBwAAAA==.',['翠花']='翠花:BAABKgAECn8VAAIIAAgIFRGTPQB9AQAIAAgIFRGTPQB9AQAAAA==.',['老胡']='老胡丨:BAAAKgAECgYIBgAAAA==.',['耶斯']='耶斯密罗:BAAAKgAECgMIAwAAAA==.',['胡作']='胡作非为:BAAAKgADCggIEAAAAA==.',['艾莎']='艾莎:BAABKgAFFH8LAAIBAAMIjg4vKQC+AAABAAMIjg4vKQC+AAAAAA==.',['艾露']='艾露辛维:BAAAKgAECgcIBwAAAA==.',['花泽']='花泽:BAAAKgADCgQIBAAAAA==.',['苍狼']='苍狼大地:BAABKgAFFH8QAAIRAAgIdhRkCwASAgARAAgIdhRkCwASAgAAAA==.',['苹果']='苹果里有虫:BAAAKgADCgEIAQAAAA==.',['萝莉']='萝莉么么哒:BAAAKgAECgIIAgAAAA==.',['萤火']='萤火虫之光:BAABKgAFFH8QAAMRAAYInRiuEACWAQARAAYIoReuEACWAQASAAQIHxgrFADXAAAAAA==.',['萨瓦']='萨瓦迪卡:BAABKgAFFH8GAAIIAAYIyxXIEACVAQAIAAYIyxXIEACVAQAAAA==.',['蔠嗳']='蔠嗳亦鉎:BAAAKgAECgcICAAAAA==.',['薄情']='薄情不是资本:BAABKgAFFH8IAAIDAAgIOQ9IBAD7AQADAAgIOQ9IBAD7AQAAAA==.',['装备']='装备评分:BAACKgAFFH8pAAIOAAgIERSmBQCBAQAOAAgIERSmBQCBAQAqAAQKfyYAAg4ACAjoGJYaAPABAA4ACAjoGJYaAPABAAAA.',['谁拿']='谁拿我圆规了:BAABKgAFFH8MAAILAAYISRPgGAA1AQALAAYISRPgGAA1AQABKgAFFAgIAgAZAAAAAA==.',['贫僧']='贫僧法号秃顶:BAAAKgADCggICAAAAA==.',['趴趴']='趴趴:BAAAKgAECgQIBAAAAA==.',['邢亥']='邢亥:BAAAKgAECgEIAQAAAA==.',['那就']='那就这样吧:BAAAKgAECgYIEQAAAA==.',['醉生']='醉生梦色:BAAAKgAECgQIBAAAAA==.',['重回']='重回十八:BAAAKgAECgcIEwAAAA==.',['钅竟']='钅竟:BAAAKgADCgYIBgAAAA==.',['铁胆']='铁胆火车侠:BAAAKgAECgMIAwAAAA==.',['阿尔']='阿尔撒斯之心:BAABKgAFFH8cAAIRAAgI3iFXAgDKAgARAAgI3iFXAgDKAgAAAA==.',['阿扎']='阿扎尔:BAAAKgAECggICAAAAA==.',['雅秘']='雅秘海:BAAAKgAECgYICQAAAA==.',['雨夜']='雨夜孤魂:BAAAKgAECggICgAAAA==.',['雪梅']='雪梅初绽:BAABKgAFFH8PAAMRAAMIUxUhTQDVAAARAAMIUxUhTQDVAAAaAAEIOQPLFgA1AAAAAA==.',['雪菲']='雪菲特:BAAAKgADCggICAAAAA==.',['雾轨']='雾轨银芒:BAABKgAFFH8IAAIMAAgIERYkBgAKAgAMAAgIERYkBgAKAgAAAA==.',['霜之']='霜之小唯:BAAAKgAECggICAAAAA==.霜之惋歌:BAAAKgADCggICAAAAA==.',['青春']='青春已逝:BAAAKgAECgQIBAAAAA==.',['風起']='風起雲飛揚:BAAAKgAFFAQIBAAAAA==.',['风流']='风流一小德:BAAAKgADCgYIBgAAAA==.',['风风']='风风火火:BAAAKgAECgEIAQAAAA==.',['香菜']='香菜:BAABKgAECn8mAAMFAAgIkx9WEgAQAgAFAAgIwR5WEgAQAgANAAcIxhmjOQBWAQAAAA==.',['马儿']='马儿叔叔:BAAAKgAECgQIBAAAAA==.',['鬼冢']='鬼冢英吉:BAAAKgAECgcIEwAAAA==.',['魅舞']='魅舞:BAAAKgAECggIEAAAAA==.',['麻匪']='麻匪豆豆:BAAAKgAECgYIBwAAAA==.',['黎明']='黎明前的圣光:BAAAKgADCggICAAAAA==.',['龙吟']='龙吟铃鹿御前:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end