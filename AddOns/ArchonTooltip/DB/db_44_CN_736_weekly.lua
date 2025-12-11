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
 local lookup = {'Shaman-Elemental','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Priest-Holy','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Frost','Paladin-Retribution','Warrior-Protection','Warrior-Arms','Rogue-Assassination','Evoker-Preservation','Hunter-BeastMastery','Paladin-Holy','Hunter-Marksmanship','Shaman-Restoration','Druid-Balance','Druid-Restoration','Priest-Shadow','Monk-Windwalker','Druid-Guardian','Mage-Frost','Mage-Arcane','Monk-Mistweaver','Evoker-Devastation','Evoker-Augmentation',}; local provider = {region='CN',realm='深渊之喉',name='CN',type='weekly',zone=44,date='2025-12-06',data={Be='Believe:BAAALAAFFAIIAgAAAA==.',Ca='Capricornus:BAAALAAECggIEAAAAA==.',Co='Coversky:BAAALAAECgYIDgAAAA==.Coverssky:BAABLAAECn8WAAIBAAYI6yC3GgDVAQABAAYI6yC3GgDVAQAAAA==.',De='Deathknight:BAAALAAFFAIIAwAAAA==.Demonhunter:BAAALAAFFAIIAwAAAA==.',Il='Illidanstor:BAAALAADCgMIAwAAAA==.',Lh='Lhwxswsj:BAAALAADCggICgAAAA==.',Mo='Montiorshi:BAAALAAECgMIAQAAAA==.',Pa='Parsley:BAAALAADCgYIBgAAAA==.',Ri='Riokin:BAAALAAECgEIAQAAAA==.',Wa='Wawlplh:BAAALAADCgQIBAAAAA==.',Ws='Wsjlhwxs:BAAALAADCgQIBAAAAA==.',Wx='Wxslhwsj:BAAALAADCgcICAAAAA==.',Zh='Zhangda:BAAALAADCgEIAQAAAA==.',['一生']='一生最爱的点:BAAALAADCggICQAAAA==.',['一見']='一見生財:BAAALAADCgYICAAAAA==.',['一颗']='一颗蛋:BAAALAAECgEIAQAAAA==.',['丨相']='丨相伴丶隨:BAAALAAECgYIEAAAAA==.',['丽莎']='丽莎娜:BAABLAAECn8bAAQCAAYIuBVQegCNAQACAAYIrRRQegCNAQADAAIIdBX/EgBJAAAEAAII9wpFNABDAAAAAA==.',['乀弑']='乀弑魂乚风铃:BAABLAAECn8VAAIFAAgIewlkXgBjAQAFAAgIewlkXgBjAQAAAA==.',['九魅']='九魅妖姬:BAAALAADCgMIAwAAAA==.',['乱舞']='乱舞一盛哥:BAAALAAECgMIAwAAAA==.',['仁道']='仁道湛卢:BAAALAAECgQIBAAAAA==.',['今晚']='今晚听你的:BAABLAAFFH8KAAMGAAYI2w4BKgBDAQAGAAYIkgwBKgBDAQAHAAIIpRi8EQA/AAAAAA==.',['仰头']='仰头微笑:BAAALAAECgIIAgAAAA==.',['伍班']='伍班副:BAAALAAECgYICwAAAA==.',['僞僐']='僞僐:BAAALAAECgYIDAAAAA==.',['冰之']='冰之煞:BAAALAAECgYIBgAAAA==.',['冰利']='冰利丹:BAAALAADCgMIAwAAAA==.',['冰夜']='冰夜元素行者:BAAALAAECgIIAgAAAA==.冰夜圣光行者:BAAALAAECgYIDAAAAA==.冰夜猎行者:BAAALAAECgYIBgAAAA==.冰夜风行者:BAAALAADCgEIAQAAAA==.',['冲锋']='冲锋小怪兽:BAAALAAECggICAAAAA==.',['刘小']='刘小七:BAABLAAECn8bAAIIAAgISxiqTQBeAgAIAAgISxiqTQBeAgAAAA==.',['制裁']='制裁者的小手:BAAALAADCgYIBgAAAA==.',['刺血']='刺血光铸骑:BAAALAAFFAEIAgAAAA==.刺血土灵猎:BAAALAADCgIIAgAAAA==.刺血机侏术:BAAALAAFFAIIAgAAAA==.',['剑域']='剑域嗜魂者:BAAALAAECgYIEQAAAA==.',['十元']='十元:BAAALAAFFAEIAQAAAA==.',['另一']='另一天堂:BAACLAAFFH8JAAIJAAIIKxc4PwCfAAAJAAIIKxc4PwCfAAAsAAQKfxsAAgkABgggHS5qABUCAAkABgggHS5qABUCAAEsAAUUAggQAAgA+R4A.',['台北']='台北娜娜:BAAALAAECgQIBwAAAA==.',['叶枫']='叶枫挡不住:BAABLAAECn8VAAMKAAcIzhF7IABAAQAKAAYIQRN7IABAAQALAAcICgfCDADGAAAAAA==.',['嗜血']='嗜血烟头:BAACLAAFFH8FAAIMAAMIwQunDgDqAAAMAAMIwQunDgDqAAAsAAQKfx0AAgwABghmH44gABICAAwABghmH44gABICAAAA.',['困难']='困难自闭丸:BAAALAAFFAIIAgAAAA==.',['土豪']='土豪肥肥:BAAALAAECggICAABLAAFFAgIMQAFAAAdAA==.',['土鳖']='土鳖射击:BAAALAAECggIDgAAAA==.',['圣艾']='圣艾泽利亚:BAAALAAECgUIBQAAAA==.',['堇色']='堇色安年:BAAALAAECgMIAwAAAA==.',['墙头']='墙头的草丶:BAABLAAFFH8IAAINAAgIAhucAgCqAgANAAgIAhucAgCqAgAAAA==.',['夏沫']='夏沫清浅:BAAALAAECgMIAQAAAA==.',['夕阳']='夕阳:BAAALAADCggICAAAAA==.',['夜丶']='夜丶未眠:BAAALAAFFAIIBAAAAA==.',['夜之']='夜之子:BAAALAADCgIIAgAAAA==.',['夜铯']='夜铯:BAABLAAECn8YAAIIAAYI9hb8SgBiAQAIAAYI9hb8SgBiAQAAAA==.',['大家']='大家不要慌:BAAALAAECgUIBgAAAA==.',['天情']='天情:BAABLAAFFH8JAAIFAAMIgwtPMwCbAAAFAAMIgwtPMwCbAAAAAA==.',['天然']='天然呆萌:BAAALAAECgYIBgAAAA==.',['太寿']='太寿鸠毛:BAABLAAFFH8GAAIJAAIIww4SWgCHAAAJAAIIww4SWgCHAAAAAA==.',['奔跑']='奔跑的春風:BAAALAAECgYICwAAAA==.',['妈妈']='妈妈:BAABLAAECn8VAAIOAAgIAxvzUQA6AgAOAAgIAxvzUQA6AgAAAA==.',['姚舜']='姚舜禹:BAABLAAFFH8HAAIIAAMIsxvlJQACAQAIAAMIsxvlJQACAQAAAA==.',['娱乐']='娱乐大众:BAAALAAECggIBQAAAA==.',['小仓']='小仓木麻衣:BAACLAAFFH8HAAIOAAMI8gmUeQBoAAAOAAMI8gmUeQBoAAAsAAQKfxUAAg4ABwjHGZCCANoBAA4ABwjHGZCCANoBAAAA.',['小阿']='小阿门:BAAALAAECgEIAQAAAA==.',['小龙']='小龙虾蛋挞:BAAALAAFFAIIAgAAAA==.',['尛傲']='尛傲天:BAABLAAFFH8QAAIIAAII+R7iUwCfAAAIAAII+R7iUwCfAAAAAA==.',['弑神']='弑神冰凌:BAABLAAECn8ZAAIPAAYI/h36DgACAgAPAAYI/h36DgACAgAAAA==.弑神凌天:BAAALAADCggICAAAAA==.',['急冻']='急冻盖拉:BAABLAAFFH8UAAIJAAYIyyIrCADjAQAJAAYIyyIrCADjAQAAAA==.',['急诊']='急诊室医生:BAAALAAECgYIBgAAAA==.',['恋家']='恋家的野牛:BAAALAAECgMIAwAAAA==.',['恩乛']='恩乛熙:BAAALAADCgMIAwAAAA==.',['恩熙']='恩熙:BAAALAADCgEIAQAAAA==.',['恶灵']='恶灵之眼:BAACLAAFFH8MAAIGAAIItBaTPQCbAAAGAAIItBaTPQCbAAAsAAQKfxUAAgYACAhlIM8jANECAAYACAhlIM8jANECAAAA.',['惩戒']='惩戒骑:BAAALAADCgEIAQAAAA==.',['我腿']='我腿短先溜了:BAACLAAFFH8IAAIMAAIIpw4sGgCXAAAMAAIIpw4sGgCXAAAsAAQKfxkAAgwACAiOF8wNAIgBAAwACAiOF8wNAIgBAAAA.',['或许']='或许:BAABLAAFFH8FAAIOAAMI3gSdigBIAAAOAAMI3gSdigBIAAAAAA==.',['战无']='战无双:BAAALAAECgYICAAAAA==.',['执念']='执念成殇:BAAALAAECggIEQAAAA==.',['拉克']='拉克西丝:BAAALAAECgEIAQAAAA==.',['整理']='整理那悲伤:BAACLAAFFH8PAAMOAAIIFiVbfQBdAAAQAAIIqAfzLABsAAAOAAIIFiVbfQBdAAAsAAQKfyoAAw4ABwiHIqcdAEoCAA4ABwiHIqcdAEoCABAABgidFAtTAGoBAAAA.',['新坝']='新坝吹长头子:BAAALAAECgYICwAAAA==.新坝萨拉赫:BAAALAAECgYICQAAAA==.',['无敌']='无敌死骑派派:BAAALAAECgQIBAAAAA==.',['无烬']='无烬的雷鸣:BAAALAAECgYIDAAAAA==.',['无蛋']='无蛋白鸡胸肉:BAAALAAECgEIAQAAAA==.',['星星']='星星有光哦:BAAALAAECgYIDgAAAA==.',['星辰']='星辰壹:BAAALAADCgYIBgAAAA==.',['暗矛']='暗矛使者:BAAALAAECgIIAwAAAA==.',['朱颜']='朱颜剑歌:BAABLAAFFH8PAAIJAAQIDSGtLwAIAQAJAAQIDSGtLwAIAQAAAA==.',['李秋']='李秋秋:BAAALAADCgIIAgAAAA==.',['杜鹃']='杜鹃花开:BAAALAAECgQIBAAAAA==.',['杨无']='杨无敌:BAAALAAECgMIAwAAAA==.',['水煮']='水煮四喜丸子:BAABLAAFFH8WAAIFAAUIURr5FgCaAQAFAAUIURr5FgCaAQAAAA==.',['江晚']='江晚枫眠:BAAALAAECgYICgAAAA==.',['沐丶']='沐丶尐晨:BAAALAAECgUICAAAAA==.',['泪闪']='泪闪星河:BAAALAAECgMIAwAAAA==.',['浅笑']='浅笑离愁:BAAALAAECgYIBgAAAA==.',['浦东']='浦东刘亦菲:BAAALAAFFAIIAgAAAA==.',['淡淡']='淡淡地忧伤:BAAALAAECgMIAwAAAA==.',['清蒸']='清蒸四喜丸子:BAACLAAFFH8UAAMRAAUITBTrJwAkAQARAAUITBTrJwAkAQABAAMIcgaqOAB3AAAsAAQKfxUAAwEACAhZDQ46ACUBAAEABggmEQ46ACUBABEACAgzFEivACIBAAAA.',['湛然']='湛然秋水:BAABLAAECn8VAAIPAAcIwxJBHABmAQAPAAcIwxJBHABmAQAAAA==.',['灬丶']='灬丶吐司:BAAALAAECgYIBgAAAA==.',['灬清']='灬清儿灬:BAABLAAFFH8HAAMSAAcI4BWnDgB9AQASAAYIpBanDgB9AQATAAEIShUwWABAAAAAAA==.',['焰灵']='焰灵姬:BAAALAAECgcIBwAAAA==.',['爱心']='爱心喵喵拳:BAAALAAFFAEIAQAAAA==.',['牙牙']='牙牙乐:BAAALAADCggICAAAAA==.牙牙大熊猫:BAAALAAECgYICwAAAA==.牙牙小狐:BAAALAADCgcIBwAAAA==.',['牛板']='牛板筋:BAAALAADCgMIAwAAAA==.',['牛虻']='牛虻:BAAALAADCgYIBgAAAA==.',['牧丶']='牧丶殇情:BAABLAAFFH8NAAIFAAYIwh+fDAADAgAFAAYIwh+fDAADAgAAAA==.',['狂刀']='狂刀战神:BAAALAADCgMIBAAAAA==.',['狂野']='狂野杀戮:BAACLAAFFH8HAAIKAAIIcAixKQBqAAAKAAIIcAixKQBqAAAsAAQKfxoAAgoABgjXFxc8AJUBAAoABgjXFxc8AJUBAAAA.',['瑞波']='瑞波:BAAALAADCgMIAwAAAA==.',['番茄']='番茄鸡蛋:BAAALAADCgMIAwAAAA==.',['疯丨']='疯丨狂可爱澄:BAAALAAECggIEAAAAA==.',['瘟艺']='瘟艺:BAAALAAFFAMIBAAAAA==.',['白鸟']='白鸟悠:BAAALAAECgcIBwAAAA==.',['真强']='真强啊:BAAALAAFFAMIAwAAAA==.',['碧晨']='碧晨红妆:BAAALAAECgQIBQAAAA==.',['碧落']='碧落黄泉:BAAALAAECggICAAAAA==.',['神圣']='神圣随风起舞:BAAALAAECgYIEgAAAA==.',['神怜']='神怜世人:BAAALAAECgIIAgAAAA==.',['神杀']='神杀一箭:BAAALAAECgUIBQAAAA==.',['神灬']='神灬清儿:BAAALAAECgEIAQAAAA==.',['秋叶']='秋叶残酒丶:BAACLAAFFH8gAAIUAAYI/BLUEQBOAQAUAAYI/BLUEQBOAQAsAAQKfyQAAhQACAggHvEXAK0CABQACAggHvEXAK0CAAAA.',['简单']='简单丶:BAAALAAECgYIDgAAAA==.',['米古']='米古:BAAALAADCgMIAwAAAA==.',['粗又']='粗又壮:BAAALAAECggIDgAAAA==.',['糖醋']='糖醋四喜丸子:BAAALAAFFAIIBAAAAA==.',['紫皮']='紫皮惩戒骑:BAAALAAECgYIBgAAAA==.',['綒紜']='綒紜:BAAALAAECgIIBAAAAA==.',['红孩']='红孩儿:BAABLAAFFH8GAAIVAAIIUQ/mEgCLAAAVAAIIUQ/mEgCLAAAAAA==.',['红水']='红水晶的爱恋:BAAALAADCgYIBgAAAA==.',['红烧']='红烧四喜丸子:BAAALAAFFAIIBAAAAA==.',['红红']='红红:BAAALAADCgYIBgAAAA==.',['聖道']='聖道轩辕:BAAALAADCgMIAwAAAA==.',['自然']='自然丶:BAAALAADCggICAAAAA==.',['艾利']='艾利斯风影:BAAALAAECgYIBgAAAA==.',['花枝']='花枝乱颤:BAAALAAECgMIAwAAAA==.',['花舞']='花舞流年:BAAALAADCggICAAAAA==.',['落雪']='落雪纷飞:BAAALAADCggICAAAAA==.',['蓝火']='蓝火翼:BAAALAADCgMIAwAAAA==.',['蓝精']='蓝精灵:BAAALAAECgEIAQAAAA==.',['蔷薇']='蔷薇少女:BAAALAAECggIEwAAAA==.',['蛮不']='蛮不讲理:BAAALAAFFAIIAgAAAA==.',['蜜汁']='蜜汁四喜丸子:BAACLAAFFH8UAAMTAAUIsxesGABqAQATAAUIsxesGABqAQASAAMIrgV2KgBgAAAsAAQKfxcABBMABwhtEiZeAHkBABMABwhtEiZeAHkBABIAAwhSEG6bAGAAABYAAwjlDwQkAFcAAAAA.',['血丶']='血丶魔:BAAALAADCgMIAwAAAA==.',['血色']='血色领域:BAAALAAECggIBwAAAA==.',['血魔']='血魔归来:BAAALAADCgUIBQAAAA==.血魔殘月:BAAALAAFFAIIAgAAAA==.',['被蛋']='被蛋卷:BAAALAAECgMIAwAAAA==.',['西地']='西地那非:BAAALAAFFAIIBAAAAA==.',['走地']='走地鸡:BAAALAADCgYIBgAAAA==.',['逆时']='逆时针:BAABLAAECn8ZAAMXAAYILCA9HQAxAgAXAAYILCA9HQAxAgAYAAYI5RWJLgBdAQAAAA==.',['酒酿']='酒酿四喜丸子:BAABLAAFFH8MAAIZAAUIogqBDgDnAAAZAAUIogqBDgDnAAAAAA==.',['酱爆']='酱爆四喜丸子:BAABLAAFFH8YAAIPAAYIQQ9nEACAAQAPAAYIQQ9nEACAAQAAAA==.',['醋溜']='醋溜四喜丸子:BAACLAAFFH8XAAMNAAUIXA/8DwAxAQANAAUIXA/8DwAxAQAaAAEIigOoIAA5AAAsAAQKfyAABA0ABwiuFngbAJwBAA0ABwiuFngbAJwBABoABAiXDUkmAKsAABsAAQgZAwURABwAAAAA.',['重锤']='重锤:BAAALAAECgYICAAAAA==.',['鉄头']='鉄头:BAABLAAFFH8LAAIGAAMIeQ2HQACMAAAGAAMIeQ2HQACMAAAAAA==.',['錢包']='錢包包:BAAALAAECgEIAQAAAA==.',['长丶']='长丶耳朵:BAAALAAECgYIBgAAAA==.',['闪电']='闪电之资:BAAALAAECgIIAgAAAA==.',['阿努']='阿努比斯丶:BAAALAAECgYIDAAAAA==.',['雨后']='雨后踩虹:BAAALAAECgEIAQAAAA==.',['雨落']='雨落红颜:BAAALAAECggIBwAAAA==.',['霹雳']='霹雳小肥仔:BAAALAAFFAIIAgAAAA==.',['风之']='风之雪舞:BAAALAAECggICAAAAA==.',['香煎']='香煎四喜丸子:BAABLAAFFH8OAAIOAAUIdQz+VgDxAAAOAAUIdQz+VgDxAAAAAA==.',['高桥']='高桥刘一桐:BAABLAAFFH8HAAIJAAIIkRXBQwCbAAAJAAIIkRXBQwCbAAAAAA==.',['高血']='高血吖:BAABLAAFFH8HAAIIAAIIYx6nVACeAAAIAAIIYx6nVACeAAAAAA==.',['魔大']='魔大力:BAAALAAECggIBgAAAA==.',['麦港']='麦港恋楠:BAAALAADCgIIAgAAAA==.',['麦香']='麦香牛:BAAALAAECgYIBgAAAA==.',['黑尛']='黑尛天:BAAALAAECgUIBQAAAA==.',['黑暗']='黑暗永生:BAAALAAECgYIBgAAAA==.',['黒尛']='黒尛天:BAAALAAECgUIBAAAAA==.',['黯殇']='黯殇:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end