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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','Rogue-Subtlety','DeathKnight-Unholy','Rogue-Assassination','Shaman-Restoration','DeathKnight-Blood','Paladin-Retribution','Evoker-Devastation','Mage-Fire','DemonHunter-Vengeance','Monk-Windwalker','Unknown-Unknown','Paladin-Protection','Warlock-Destruction','Warrior-Fury','Warrior-Arms','Shaman-Elemental','Druid-Restoration','Druid-Balance','Druid-Feral','Mage-Frost','Mage-Arcane','Monk-Mistweaver','Warlock-Demonology','Warrior-Protection','Priest-Holy','Priest-Discipline','Priest-Shadow','Warlock-Affliction',}; local provider = {region='CN',realm='奥斯里安',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aa:BAABKgAFFH8IAAMBAAIIXwrZRwBhAAABAAIIpwfZRwBhAAACAAIIQgeDVABbAAAAAA==.',Ad='Adh:BAABKgAFFH8GAAIDAAIIMxJiIQCKAAADAAIIMxJiIQCKAAAAAA==.',Am='Ams:BAAAKgAECgEIAQAAAA==.',An='Anubisreaper:BAABKgAECn8YAAIEAAgIARzqDAAYAgAEAAgIARzqDAAYAgAAAA==.',Au='Austonmartin:BAAAKgAFFAQIBAAAAA==.',Da='Darksouls:BAABKgAFFH8FAAIFAAMI5w/iEwDpAAAFAAMI5w/iEwDpAAAAAA==.',Ha='Happyend:BAABKgAFFH8IAAIGAAgIHw7gBAAnAgAGAAgIHw7gBAAnAgAAAA==.',Iv='Iv:BAABKgAFFH8GAAIHAAYIJAmqFwAjAQAHAAYIJAmqFwAjAQAAAA==.',Ki='Kirameki:BAAAKgAECgMIAwAAAA==.',Ma='Maomaodk:BAAAKgAFFAEIAQABKgAFFAgICAAIAFgSAA==.Maomaoshaman:BAAAKgAECgMIAwAAAA==.',Ro='Romyuwe:BAAAKgADCgIIAgAAAA==.',So='Someone:BAAAKgAFFAIIAgAAAA==.Soulhacker:BAAAKgAFFAcIBAAAAA==.',Sw='Swiper:BAABKgAECn8YAAIJAAgIjh0QRAD1AQAJAAgIjh0QRAD1AQAAAA==.',Ze='Zeroblood:BAAAKgAFFAIIAgAAAA==.',['一击']='一击必杀:BAAAKgADCgIIAgAAAA==.',['一百']='一百级鲤鱼王:BAAAKgAFFAUIBAAAAA==.',['三月']='三月三十日:BAAAKgADCggICAAAAA==.',['三熊']='三熊奶业:BAAAKgADCggICAAAAA==.',['不啰']='不啰嗦:BAAAKgAECgQIBAAAAA==.',['不高']='不高兴丶:BAABKgAFFH8gAAIKAAgIlRz+BABYAgAKAAgIlRz+BABYAgAAAA==.',['东郊']='东郊到家姬师:BAAAKgAECgUIBQAAAA==.',['丶夜']='丶夜色:BAAAKgADCgYIBgAAAA==.',['丶晓']='丶晓风残月:BAAAKgADCgcIBwAAAA==.',['丶珊']='丶珊珊来迟:BAAAKgAECgEIAQAAAA==.',['丶离']='丶离家不远丶:BAAAKgADCgMIAwAAAA==.',['为何']='为何如此不安:BAAAKgADCgYIBgAAAA==.',['丿听']='丿听灬海:BAAAKgADCggICAAAAA==.',['丿吻']='丿吻灬别:BAAAKgAFFAYIBAAAAA==.',['乔艾']='乔艾莉波妮:BAAAKgAECggIDgAAAA==.',['二楼']='二楼经理:BAAAKgAFFAYIAgAAAA==.',['人間']='人間失格丶:BAAAKgAECggICAAAAA==.',['伏魔']='伏魔御厨子:BAAAKgAECgUICAAAAA==.',['似惊']='似惊雷丶:BAABKgAECn8cAAILAAgIxRKRNADGAQALAAgIxRKRNADGAQAAAA==.',['倩魂']='倩魂:BAAAKgADCgEIBQAAAA==.',['元素']='元素行者:BAAAKgAFFAIIAgAAAA==.',['克洛']='克洛克达尔:BAAAKgAECggICAAAAA==.',['再回']='再回首非少年:BAAAKgAECgUIBgAAAA==.',['冰蓝']='冰蓝的绚烂:BAAAKgADCgcIBwAAAA==.',['冷月']='冷月光:BAAAKgADCggICQAAAA==.',['凝简']='凝简禅梦姗熙:BAAAKgAFFAMIAwAAAA==.',['刀剑']='刀剑无言:BAAAKgADCgEIAgAAAA==.',['半个']='半个月亮:BAAAKgAECgYIBgAAAA==.',['卡齐']='卡齐:BAAAKgAECggICAAAAA==.',['双刀']='双刀就看走:BAABKgAFFH8MAAMMAAYINh3OAwCQAQAMAAYI0xnOAwCQAQADAAUIZw5sHQDNAAAAAA==.',['叶問']='叶問:BAABKgAFFH8OAAINAAYIVQ+ZCQBOAQANAAYIVQ+ZCQBOAQAAAA==.',['名字']='名字:BAAAKgADCgEIBAAAAA==.',['含泪']='含泪加入:BAACKgAFFH9FAAMEAAgIkiUhAAD9AgAEAAgIiiUhAAD9AgAGAAcIhiTbAgCSAQAqAAQKfy8AAwQACAiBJlABAPUCAAQACAh8JlABAPUCAAYABAjXJHQdAHcBAAAA.',['听雨']='听雨眠:BAAAKgADCggIAQAAAA==.',['吴壹']='吴壹贰:BAAAKgADCgEIAQAAAA==.',['吾王']='吾王丨:BAAAKgAFFAQIBAAAAA==.',['周二']='周二毛:BAAAKgAECgEIAQABKgAFFAgIAgAOAAAAAA==.',['唵嘛']='唵嘛呢叭哞吽:BAAAKgAECggIEwAAAA==.',['噩梦']='噩梦丨指针:BAAAKgAFFAgIAwAAAA==.',['回首']='回首亦少年:BAAAKgAECgMIAwAAAA==.回首再非少年:BAAAKgAECggIDQAAAA==.回首妄少年:BAAAKgAECgEIAQAAAA==.回首少年:BAAAKgAECgQIBAAAAA==.回首赌少年:BAAAKgAECgIIAgAAAA==.回首非少年:BAAAKgAECgQIBAAAAA==.',['圣光']='圣光代言者:BAABKgAECn8VAAMJAAgItxi0ewBZAQAJAAgItxi0ewBZAQAPAAEI6gOCYQAIAAAAAA==.圣光轨道炮:BAAAKgAECggICAAAAA==.',['堕落']='堕落的白羽:BAAAKgAECgMIAwAAAA==.',['复仇']='复仇啼血:BAAAKgADCggICAAAAA==.',['多弗']='多弗朗明哥:BAAAKgAFFAgIAgAAAA==.',['夜星']='夜星丶:BAABKgAFFH8WAAIPAAgIIxRDBgDCAQAPAAgIIxRDBgDCAQABKgAFFAgIFwACAJAcAA==.',['大龙']='大龙凤:BAAAKgAECgIIAgAAAA==.',['天之']='天之水:BAABKgAFFH8FAAIQAAUIpwcKFADtAAAQAAUIpwcKFADtAAAAAA==.',['妙涟']='妙涟寺鸦郎:BAAAKgAECgYICQAAAA==.',['姜维']='姜维:BAAAKgAECgMIAwAAAA==.',['威猛']='威猛大西瓜:BAAAKgADCggIEAAAAA==.',['娴熟']='娴熟的荒凉丶:BAAAKgAFFAYIAgAAAA==.',['安东']='安东憨憨泥:BAAAKgADCgIIAgAAAA==.',['寂寞']='寂寞血雨:BAAAKgAFFAIIAgAAAA==.',['射点']='射点什么:BAAAKgAECgMIAwAAAA==.',['小萨']='小萨毛:BAABKgAFFH8NAAIHAAcI2Q8nAgB+AQAHAAcI2Q8nAgB+AQAAAA==.',['小鸥']='小鸥:BAAAKgAFFAYIBAAAAA==.',['少学']='少学六十五变:BAAAKgADCgQIBAAAAA==.',['尨樧']='尨樧銀狼:BAAAKgAFFAQIBAAAAA==.',['岁月']='岁月屠夫:BAABKgAFFH8QAAMRAAgIUROmBQAeAgARAAgIFROmBQAeAgASAAgIagZTBwCcAQAAAA==.',['巧克']='巧克力的春天:BAAAKgADCgEIAQAAAA==.',['巳巳']='巳巳如意:BAAAKgAFFAgIBAAAAA==.',['强子']='强子哥:BAAAKgAECgUIBQAAAA==.',['怂得']='怂得一批:BAAAKgAECggIBwAAAA==.',['想屁']='想屁吃的贼总:BAABKgAFFH8SAAMTAAYIOxtSBQCrAQATAAYIOxtSBQCrAQAHAAQI3Bb8CwD6AAAAAA==.',['愤怒']='愤怒伏特加:BAAAKgAFFAIIAgAAAA==.',['我不']='我不够持久:BAAAKgAECgIIAgAAAA==.',['我嘞']='我嘞个烧钢:BAABKgAFFH8WAAQUAAgIgRc4CACIAQAUAAUIExo4CACIAQAVAAUIrBTeKwDjAAAWAAEIbBBHBwBjAAAAAA==.',['我头']='我头上有犄角:BAAAKgAECggICAAAAA==.',['我真']='我真的很怪:BAABKgAFFH8IAAIVAAgInwrRDADJAQAVAAgInwrRDADJAQAAAA==.',['执着']='执着的铁锤:BAAAKgAECgIIAgAAAA==.',['掌上']='掌上老虎:BAABKgAFFH8WAAMBAAgI3B4FBwAPAQACAAgI4BzuFQBHAQABAAQI3h4FBwAPAQAAAA==.',['摩罗']='摩罗衍娜:BAABKgAFFH8GAAIDAAYI4RAjDgBnAQADAAYI4RAjDgBnAQAAAA==.',['斯文']='斯文的:BAABKgAFFH8KAAMJAAYIqw3MJADdAAAJAAQIaxbMJADdAAAPAAYITQQvGQCuAAAAAA==.',['斷奏']='斷奏:BAAAKgADCggICAAAAA==.',['旅店']='旅店老板娘:BAACKgAFFH8OAAIMAAYIyxfoAgAfAQAMAAYIyxfoAgAfAQAqAAQKfxgAAwMACAj2GDg5AMUBAAMABwjeGzg5AMUBAAwACAgxCfs4ANUAAAAA.',['无欲']='无欲务求:BAAAKgADCgEIAgAAAA==.',['昕诚']='昕诚:BAABKgAECn8VAAMXAAgIuRyWEQA4AgAXAAgIuRyWEQA4AgAYAAEIAABurQAAAAAAAA==.',['春哥']='春哥夸我帅:BAAAKgAECgEIAQAAAA==.',['晚鸢']='晚鸢枫华:BAAAKgAECgUIBgAAAA==.',['暗格']='暗格:BAAAKgADCggICAAAAA==.',['暗魂']='暗魂哀歌:BAAAKgAFFAIIAgAAAA==.',['机子']='机子酱:BAABKgAFFH8QAAIQAAMIOgnMGwCiAAAQAAMIOgnMGwCiAAAAAA==.',['格兰']='格兰帝亚:BAAAKgADCgEIAgAAAA==.',['桃子']='桃子酱:BAAAKgAFFAIIAgAAAA==.',['橙色']='橙色:BAAAKgAECgQIBAAAAA==.',['死神']='死神眷恋:BAAAKgAFFAMIAwAAAA==.',['毳的']='毳的毳的:BAAAKgADCggICAAAAA==.',['沐丝']='沐丝丶墓碑:BAAAKgAFFAIIAQAAAA==.',['没脑']='没脑袋:BAABKgAFFH8HAAIKAAcIwhi9AAARAgAKAAcIwhi9AAARAgAAAA==.',['流氓']='流氓兔斯基:BAACKgAFFH8pAAQYAAQIfh2lHAAAAQAYAAQIfh2lHAAAAQALAAII3grbMgB/AAAXAAIIURafIgB4AAAqAAQKfxkABBgABwhyHfAyAIQBABgABgjTHPAyAIQBABcABghuFCtcAPkAAAsAAwisEppsAMEAAAAA.流氓兔斯基喔:BAAAKgAECgYICQAAAA==.',['清晨']='清晨点根烟:BAACKgAFFH8IAAIJAAgIiBciBwBGAgAJAAgIiBciBwBGAgAqAAQKfxsAAgkACAiHII0mAJABAAkACAiHII0mAJABAAAA.',['漫步']='漫步灬云端:BAABKgAECn8YAAIDAAgI2h4IGgBoAgADAAgI2h4IGgBoAgAAAA==.',['火炏']='火炏焱:BAAAKgAECgYIDwAAAA==.',['火锅']='火锅:BAAAKgAECgIIAgAAAA==.',['炙渊']='炙渊:BAAAKgADCgcIBwAAAA==.',['烈咬']='烈咬路鲨:BAAAKgAFFAYIAwAAAA==.',['照烧']='照烧小丸子:BAABKgAECn8WAAIVAAgILxEYVwBXAQAVAAgILxEYVwBXAQAAAA==.',['燃烧']='燃烧的可乐:BAABKgAECn8YAAIJAAgIRhz2NABRAgAJAAgIRhz2NABRAgAAAA==.',['爆击']='爆击灭烟:BAABKgAECn8XAAMUAAgI1w8LMABiAQAUAAgI1w8LMABiAQAVAAEIAAAi4QAAAAAAAA==.',['牛儿']='牛儿响叮当:BAAAKgAECggIEgAAAA==.',['狂野']='狂野伏特加:BAAAKgAFFAMIAwAAAA==.',['狐狸']='狐狸捉小鸡:BAABKgAFFH8GAAILAAYIBCS0CAC4AQALAAYIBCS0CAC4AQAAAA==.',['獠丶']='獠丶牙:BAAAKgAECgUIBQAAAA==.',['王嘉']='王嘉熙:BAABKgAFFH8OAAMZAAUIah4KCQBVAQAZAAUIah4KCQBVAQANAAEIlg6WFQBFAAAAAA==.',['玛什']='玛什么梅:BAAAKgAECgYICAAAAA==.',['玫瑰']='玫瑰酱:BAAAKgAFFAIIAgAAAA==.',['瑝镞']='瑝镞宇宙:BAAAKgAFFAQIBAAAAA==.瑝镞牛:BAAAKgAFFAQIBAAAAA==.',['白塔']='白塔:BAABKgAFFH8GAAISAAYICx8HBwClAQASAAYICx8HBwClAQAAAA==.',['白昼']='白昼:BAAAKgAFFAMIAwAAAA==.',['百合']='百合花的夏天:BAAAKgADCgEIBAAAAA==.',['盐味']='盐味拉面:BAAAKgAECggICQAAAA==.',['真星']='真星羽:BAAAKgADCgIIAgAAAA==.',['破晓']='破晓:BAAAKgAFFAIIAgAAAA==.',['硕大']='硕大无朋:BAABKgAFFH8KAAMQAAgIbxj+DgCfAQAQAAYIDBn+DgCfAQAaAAIIwxT6JwBJAAAAAA==.',['碾碎']='碾碎者托拉格:BAABKgAFFH8KAAIRAAgI+Bg6AwCRAgARAAgI+Bg6AwCRAgAAAA==.',['神圣']='神圣的爱:BAAAKgAFFAMIAwAAAA==.',['秦百']='秦百胜:BAAAKgAECgIIAwAAAA==.',['箭破']='箭破万法:BAAAKgAECgcIBwAAAA==.',['織田']='織田信奈:BAAAKgAECgMIAwAAAA==.',['细嗅']='细嗅蔷薇:BAAAKgAFFAgIBAAAAA==.',['绫零']='绫零:BAAAKgAFFAQIBAAAAA==.',['翻滚']='翻滚吧三月半:BAAAKgAFFAQIBAAAAA==.',['翻车']='翻车老司机:BAAAKgADCgQIBAAAAA==.',['脚后']='脚后跟:BAAAKgAECgEIAQAAAA==.',['自恋']='自恋长发飘:BAACKgAFFH8TAAMRAAQIqhpHHQDfAAARAAMIqhpHHQDfAAAbAAQIRAeXEAB5AAAqAAQKfx4AAxsACAhdIWMKADkCABsACAiNHGMKADkCABEACAgiGggpAOgBAAAA.',['至臻']='至臻小德:BAABKgAFFH8QAAQcAAYIfh6sHQDUAAAcAAQIABusHQDUAAAdAAMIDB07GQCYAAAeAAIIKxlGHwCPAAAAAA==.至臻牧司:BAABKgAFFH8KAAMUAAYIXx6TBQDIAQAUAAYIXx6TBQDIAQAVAAQIigkaIAC5AAAAAA==.',['艾沙']='艾沙克:BAAAKgAECgYIBgAAAA==.',['芋泥']='芋泥厚厚牛奶:BAAAKgAFFAYIBAABKgAFFAgIEAAJAIwiAA==.',['芝士']='芝士莓莓茶:BAABKgAFFH8FAAIBAAUIrB83TABOAAABAAUIrB83TABOAAAAAA==.',['英年']='英年早逝:BAABKgAFFH8GAAIFAAYIzQz8FwBdAQAFAAYIzQz8FwBdAQAAAA==.',['菜小']='菜小三:BAAAKgAECgcIBQAAAA==.',['落寞']='落寞年华霜钰:BAAAKgAECgQIBAAAAA==.',['虚月']='虚月丶:BAAAKgAFFAQIAQABKgAFFAgIFwACAJAcAA==.',['血色']='血色迷恋:BAAAKgADCgEIBAAAAA==.',['血领']='血领主马拉克:BAABKgAFFH8GAAIJAAYIKBNeEgB3AQAJAAYIKBNeEgB3AQAAAA==.',['言出']='言出法随:BAAAKgADCgQIBAAAAA==.',['誓约']='誓约胜利之剑:BAAAKgAFFAYIBAAAAA==.',['诸神']='诸神丶黄昏:BAAAKgAECgcIBwAAAA==.',['超越']='超越纣王:BAABKgAFFH8IAAIJAAgI3RiRBwBNAgAJAAgI3RiRBwBNAgAAAA==.',['跳进']='跳进去就噶了:BAAAKgADCgIIAgAAAA==.',['踏雪']='踏雪丨凝梦:BAABKgAFFH8HAAMXAAMINw4+JQBoAAAXAAMIHgw+JQBoAAAYAAEIsBGJJwBCAAAAAA==.',['辛乛']='辛乛多雷:BAAAKgAECgUIBQAAAA==.',['边享']='边享受边泪流:BAAAKgADCggICAAAAA==.',['遇术']='遇术临瘋:BAACKgAFFH8LAAMfAAMIXgVQCgCcAAAfAAMIXgVQCgCcAAAQAAIIHgPNTQA5AAAqAAQKfygABB8ACAgCF9cDANsBAB8ACAhFFtcDANsBABAABghxES8/AA8BABoABQj1EWQ9AOsAAAAA.',['邪恶']='邪恶小王子:BAAAKgAFFAQIBAAAAA==.',['邪能']='邪能伏特加:BAABKgAFFH8IAAIDAAMIhRLCFgDVAAADAAMIhRLCFgDVAAAAAA==.',['部落']='部落丶酋长:BAAAKgADCgcICQAAAA==.',['酱爆']='酱爆肉:BAAAKgAFFAcIBAAAAA==.',['酸辣']='酸辣土豆丝:BAAAKgADCggICAABKgAECgYIDgAOAAAAAA==.',['醉爱']='醉爱:BAAAKgADCgIIBQAAAA==.',['钴毛']='钴毛头:BAAAKgAFFAQIAgABKgAFFAYIBgADAIgZAA==.',['镍毛']='镍毛头:BAABKgAFFH8GAAIDAAYIiBnhFABTAQADAAYIiBnhFABTAQAAAA==.',['阿塔']='阿塔澜忒:BAAAKgAECgUIBQAAAA==.',['阿纳']='阿纳斯塔西亚:BAAAKgAECggIDAAAAA==.',['雪华']='雪华风暴烈酒:BAAAKgAECgQIBAAAAA==.',['雪月']='雪月明:BAAAKgAECgEIAQAAAA==.',['零多']='零多:BAAAKgAECggICAAAAA==.',['雷霆']='雷霆衙扫蝗组:BAAAKgAECgQIBAAAAA==.',['霜天']='霜天月:BAABKgAECn8WAAMFAAgIMCOVCADXAgAFAAgIMCOVCADXAgAIAAgIUwybMAARAQABKgAFFAgIDAAFAPURAA==.',['颜舜']='颜舜瑛:BAABKgAFFH8GAAIJAAYIchQbEgB8AQAJAAYIchQbEgB8AQAAAA==.',['风暴']='风暴之:BAAAKgADCggICwAAAA==.',['飘渺']='飘渺逸:BAAAKgADCgUIBwAAAA==.',['驯兽']='驯兽家:BAABKgAFFH8IAAIBAAgIMB54AgB+AgABAAgIMB54AgB+AgAAAA==.',['高大']='高大力:BAAAKgADCggIFwAAAA==.',['鬼知']='鬼知道你叫啥:BAABKgAFFH8GAAIBAAYIHRdeDgB4AQABAAYIHRdeDgB4AQAAAA==.',['鬼鬼']='鬼鬼:BAABKgAFFH8OAAICAAgILhORCADtAQACAAgILhORCADtAQAAAA==.',['麦咪']='麦咪和熊熊:BAABKgAFFH8XAAMCAAgIkBzYAAATAgABAAgIfhsWBABLAgACAAcI7BXYAAATAgAAAA==.',['麦旋']='麦旋风:BAABKgAECn8VAAIHAAgI9hdfMgCuAQAHAAgI9hdfMgCuAQAAAA==.',['龙洺']='龙洺:BAABKgAFFH8fAAIDAAgIaCUNAQD+AgADAAgIaCUNAQD+AgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end