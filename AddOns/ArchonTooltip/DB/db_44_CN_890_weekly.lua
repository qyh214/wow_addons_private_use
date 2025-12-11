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
 local lookup = {'Warlock-Destruction','Mage-Arcane','DemonHunter-Vengeance','Shaman-Elemental','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Preservation','DemonHunter-Havoc','Hunter-Survival','Paladin-Retribution','Druid-Restoration','Druid-Balance','Warrior-Fury','Monk-Brewmaster','Priest-Shadow','Priest-Holy','Monk-Windwalker','DeathKnight-Frost','Evoker-Devastation','Priest-Discipline','Warrior-Protection','Mage-Frost','DeathKnight-Unholy','Paladin-Protection','Warlock-Demonology','Warrior-Arms','Shaman-Restoration','Paladin-Holy','Rogue-Subtlety','Druid-Guardian',}; local provider = {region='CN',realm='麦姆',name='CN',type='weekly',zone=44,date='2025-12-10',data={Am='Amvs:BAAALAAECgYIDwAAAA==.',Ap='Apollow:BAAALAAECgQIBAAAAA==.',Aw='Awstargazer:BAABLAAFFH8QAAIBAAgIfxjAAwB/AgABAAgIfxjAAwB/AgAAAA==.',Ce='Celosia:BAABLAAFFH8GAAICAAMIdw+VLADfAAACAAMIdw+VLADfAAAAAA==.',Cl='Clearlove:BAAALAAECggICwAAAA==.',Cn='Cnmhshii:BAAALAAECgYICwAAAA==.',Co='Confesseur:BAABLAAECn8bAAIDAAYIVxrCKwBaAQADAAYIVxrCKwBaAQAAAA==.',Cu='Cure:BAAALAADCgYICgAAAA==.',Cx='Cxk:BAAALAAECgUIBQAAAA==.',Dh='Dhvs:BAAALAAECgYIBgAAAA==.',Dr='Drlu:BAABLAAFFH8GAAICAAIIPQl9WACIAAACAAIIPQl9WACIAAAAAA==.',Dw='Dwahui:BAAALAADCgEIAQAAAA==.',Ea='Earthshaker:BAABLAAFFH8GAAIEAAYITREgHABkAQAEAAYITREgHABkAQAAAA==.',Ec='Eclipseborne:BAAALAADCgEIAQAAAA==.',El='Elison:BAAALAAECgMIAwAAAA==.',Fe='Felguldan:BAABLAAFFH8MAAIBAAMI0h1VMwCrAAABAAMI0h1VMwCrAAAAAA==.',Gg='Ggcj:BAABLAAFFH8OAAICAAYIOwSXOQAHAQACAAYIOwSXOQAHAQAAAA==.',Go='Gosh:BAAALAAECgUIBQAAAA==.Goshsweat:BAAALAADCgIIAgAAAA==.',He='Heisenberg:BAAALAAECgYIBgAAAA==.',Ki='Kinderd:BAAALAAFFAIIAgAAAA==.',Kk='Kkymacc:BAAALAADCgYIBgAAAA==.',Ko='Kogvs:BAAALAAECgQIBgAAAA==.',Li='Lielielie:BAAALAAECgMIAwABLAAFFAYIGgABAOwTAA==.Little:BAAALAADCggICAAAAA==.',Lo='Loerm:BAAALAAECgYIDAAAAA==.Loppe:BAAALAAFFAIIAgAAAA==.',Ma='Matchless:BAABLAAFFH8SAAMFAAYIrSU/CwDgAQAFAAYIrSU/CwDgAQAGAAIIhxRwIwCBAAAAAA==.Mayta:BAAALAAFFAYIBAAAAA==.',Me='Meowdracthyr:BAAALAAECgcICQABLAAFFAMIEAAHAOghAA==.',Mo='Moment:BAAALAAECgYIBgAAAA==.Mophisto:BAAALAAFFAIIBAAAAA==.',Na='Nameless:BAABLAAFFH8VAAICAAYIrQ2ALABfAQACAAYIrQ2ALABfAQAAAA==.',Ne='Nexxarion:BAAALAAECgEIAQAAAA==.',Ni='Nishikata:BAAALAAECgYIBwAAAA==.Nitrogen:BAAALAAFFAIIAgAAAA==.',Ov='Ovleqiq:BAABLAAFFH8JAAIIAAYI7xb2DgC7AQAIAAYI7xb2DgC7AQAAAA==.Ovliveq:BAABLAAFFH8KAAMFAAYIvBGLLADPAAAFAAYIvBGLLADPAAAJAAEITgm6BwBSAAAAAA==.',Qy='Qywarlockg:BAABLAAFFH8uAAIBAAgIXBu5CAB6AgABAAgIXBu5CAB6AgAAAA==.',Re='Regil:BAAALAAECgYIBgAAAA==.',Sa='Sayen:BAABLAAFFH8IAAIKAAII7BmVNACnAAAKAAII7BmVNACnAAAAAA==.',Se='Seraphiel:BAAALAAECgMIAwAAAA==.',Sh='Shmilypp:BAAALAADCgUIBQAAAA==.Showmelovege:BAAALAAFFAIIAgAAAA==.',Si='Silverdew:BAABLAAFFH8KAAMLAAIIsQr1SwBbAAALAAIIsQr1SwBbAAAMAAIICwrKQQAdAAAAAA==.',So='Sophiegood:BAAALAADCgYIBgAAAA==.',Ss='Sswyy:BAAALAAECgMIBAAAAA==.',To='Toothless:BAAALAAFFAIIBAAAAA==.',['一力']='一力弹的春天:BAAALAAECgYICQAAAA==.',['一生']='一生三生万物:BAAALAAFFAIIAgAAAA==.',['一箭']='一箭就行:BAAALAAFFAIIAgAAAA==.',['万事']='万事天尊:BAAALAAECgYIDAAAAA==.',['三月']='三月兔:BAAALAAECgcIEwAAAA==.',['不做']='不做牛马:BAAALAAFFAIIAgAAAA==.',['不加']='不加迪威龙:BAAALAAECgYIBgAAAA==.',['专卖']='专卖螺蛳粉:BAAALAAFFAIIAgAAAA==.',['丨大']='丨大仙丨:BAABLAAFFH8GAAINAAII6Ae/SAB+AAANAAII6Ae/SAB+AAAAAA==.',['丨龙']='丨龙仙丨:BAAALAAECgUIBQAAAA==.',['临渴']='临渴掘井:BAAALAADCgIIAgAAAA==.',['丿丶']='丿丶蓝颜祸水:BAAALAAFFAIIAgAAAA==.丿丶血耀神州:BAAALAAFFAEIAQAAAA==.',['乌妖']='乌妖亡:BAAALAAECgYICwAAAA==.',['二憨']='二憨:BAAALAAECgYIBgAAAA==.',['云影']='云影清风:BAAALAAECgYIDAAAAA==.',['亚麻']='亚麻灬跌:BAAALAADCgcIBwAAAA==.亚麻碟:BAAALAAECgMIAwAAAA==.',['亦橙']='亦橙:BAAALAAECgYICAAAAA==.',['亮晶']='亮晶晶:BAAALAAFFAIIAgAAAA==.',['他们']='他们叫我大壮:BAAALAAECgQIBAAAAA==.',['仙之']='仙之人兮:BAAALAADCgQIBAAAAA==.',['伊利']='伊利旦怒风:BAAALAAECgMIAwAAAA==.伊利雷:BAAALAADCggICAAAAA==.',['伊纳']='伊纳瑞斯:BAABLAAFFH8IAAIFAAMIaBRVLQDNAAAFAAMIaBRVLQDNAAAAAA==.',['伊藤']='伊藤誠:BAAALAADCgYIBgAAAA==.',['伤心']='伤心小小箭:BAAALAAECgMIAwAAAA==.',['何彤']='何彤彤:BAAALAAECgYIBwAAAA==.',['傻馒']='傻馒奶死你:BAAALAADCggIAgAAAA==.',['六神']='六神狂战:BAAALAAECgQIBAAAAA==.',['再看']='再看抠你眼睛:BAAALAAECgIIAgAAAA==.',['冥阿']='冥阿茶丶:BAAALAAECgQIBAAAAA==.',['冬天']='冬天的暴风雪:BAAALAAECgYIBgAAAA==.',['冷色']='冷色丶妖姬:BAAALAAECgQIBAAAAA==.',['初丨']='初丨安平:BAAALAADCgYIBgAAAA==.',['初见']='初见小德:BAAALAAFFAIIBAAAAA==.初见老贼:BAAALAAECgIIAgAAAA==.',['别惹']='别惹我胖虎:BAABLAAFFH8MAAIOAAII1yDxDwCsAAAOAAII1yDxDwCsAAAAAA==.',['别慌']='别慌:BAACLAAFFH8KAAIPAAII7RFUIACOAAAPAAII7RFUIACOAAAsAAQKfzEAAw8ABwivH+AOAPgBAA8ABwivH+AOAPgBABAABQjKBXKXALwAAAAA.',['剑心']='剑心犹在丶:BAAALAAECgYIBgAAAA==.',['加贺']='加贺美:BAAALAAECgYIBgAAAA==.',['努力']='努力的阿术:BAAALAADCggICAAAAA==.',['北京']='北京布鞋:BAAALAAECgYICAAAAA==.',['北方']='北方锁钥:BAAALAAECgcIBwAAAA==.',['卑丷']='卑丷鄙:BAAALAAECgUIBgAAAA==.',['可爱']='可爱的鲨鱼:BAAALAAECggIEgAAAA==.',['可达']='可达鸭啊:BAAALAADCgEIAQAAAA==.',['叶落']='叶落悟菩提:BAAALAAECggICwAAAA==.',['名人']='名人丶小四:BAAALAAFFAMIBAAAAA==.',['吾名']='吾名喵喵之翼:BAACLAAFFH8IAAIRAAIIGCGYDQCmAAARAAIIGCGYDQCmAAAsAAQKfyQAAxEABwgVJN0QAJ0CABEABwgVJN0QAJ0CAA4ABgitDbI1AOgAAAEsAAUUAwgQAAcA6CEA.',['咔咔']='咔咔卡酷酷:BAAALAAECgYIBgAAAA==.',['咻咻']='咻咻就很快:BAAALAADCgUIBQAAAA==.',['哔哩']='哔哩哔哩:BAAALAAECgMIAwAAAA==.',['哦对']='哦对的对的:BAAALAADCggICAAAAA==.',['喵萨']='喵萨里奥:BAACLAAFFH8QAAIHAAMI6CFMCQApAQAHAAMI6CFMCQApAQAsAAQKfzgAAgcACAhvI4kCADEDAAcACAhvI4kCADEDAAAA.',['回眸']='回眸一箭:BAAALAAECgEIAQAAAA==.',['因为']='因为水里没鱼:BAAALAADCgYIBgAAAA==.',['土豆']='土豆牛马:BAABLAAFFH8HAAIRAAII2w/nEQCPAAARAAII2w/nEQCPAAAAAA==.',['地狱']='地狱级咆哮:BAAALAADCgYICgAAAA==.',['复活']='复活我的爱人:BAAALAAECgYICwAAAA==.',['夏天']='夏天的海鸟:BAAALAAECgUIBQAAAA==.',['夏季']='夏季八砍:BAACLAAFFH8PAAISAAMI4RTbYgCMAAASAAMI4RTbYgCMAAAsAAQKfxkAAhIABggyItkpANEBABIABggyItkpANEBAAAA.',['多一']='多一分辛苦:BAAALAAECgMIAwAAAA==.',['多多']='多多:BAAALAAECgYIBgAAAA==.',['夜盈']='夜盈川:BAAALAAECggIDwAAAA==.',['夜行']='夜行动物:BAACLAAFFH8IAAITAAII4gyXGwCGAAATAAII4gyXGwCGAAAsAAQKfxkAAhMABwgIFwoTAHcBABMABwgIFwoTAHcBAAAA.',['天天']='天天睡脚:BAAALAAECgYIBgAAAA==.天天睡觉:BAAALAAECgYIEgAAAA==.',['天琊']='天琊灬:BAAALAAECgIIAgAAAA==.',['天生']='天生牛马:BAABLAAFFH8SAAINAAYIlBx+EQDRAQANAAYIlBx+EQDRAQAAAA==.',['天黑']='天黑遛个弯:BAAALAADCgYIBgAAAA==.',['天龍']='天龍瑬星:BAAALAAFFAIIBAAAAA==.',['夺目']='夺目龙:BAAALAAECgYIDgAAAA==.',['奥法']='奥法王:BAAALAAECgYIEAAAAA==.',['妖刀']='妖刀姬:BAAALAAECgYICgAAAA==.',['安安']='安安:BAAALAAECgQIBAAAAA==.',['宝宝']='宝宝保护协会:BAAALAADCgEIAQAAAA==.',['宫野']='宫野志保:BAAALAAECgUIBwAAAA==.',['寒江']='寒江夜雨:BAAALAAECgYIBgAAAA==.',['小四']='小四:BAAALAAECgYIDwAAAA==.',['小圆']='小圆子:BAABLAAECn8VAAMUAAYIxxQ0FwBJAQAQAAYIaBPkXgBhAQAUAAYIzxA0FwBJAQAAAA==.',['小孩']='小孩孩:BAAALAAFFAIIAwAAAA==.',['小小']='小小牛马:BAABLAAFFH8gAAMFAAYI5CWODAAtAgAFAAYI5CWODAAtAgAGAAEIXQNlHwAAAAABLAAFFAcIOQAKAAsmAA==.小小马蝼:BAABLAAFFH8bAAIEAAYIHhm0FACbAQAEAAYIHhm0FACbAQAAAA==.',['小河']='小河:BAAALAADCgMIAwAAAA==.',['小法']='小法依依:BAAALAAECgUIBQAAAA==.',['小熊']='小熊猫丽丽:BAAALAAECgYICgAAAA==.',['小猪']='小猪鱼:BAABLAAFFH8aAAIIAAYITCA+EwBkAQAIAAYITCA+EwBkAQAAAA==.',['小福']='小福:BAAALAAFFAIIBAAAAA==.',['小米']='小米瓶子:BAAALAAFFAIIBAAAAA==.',['小身']='小身材大味道:BAAALAAECggICQABLAAFFAIIBgALAE8mAA==.',['尛吥']='尛吥点:BAAALAAECgUIBQAAAA==.',['屁带']='屁带汁:BAAALAAECgYIDAAAAA==.',['崴脚']='崴脚的猫:BAAALAAFFAIIBAAAAA==.',['幕君']='幕君年丶:BAAALAAECgUIBQAAAA==.',['年华']='年华逝去:BAAALAAECgYIBgAAAA==.',['幻想']='幻想:BAAALAAECgUIBgAAAA==.',['庄子']='庄子看报纸:BAAALAAECgMIAwAAAA==.',['庄毕']='庄毕凡:BAAALAADCgUIBQAAAA==.',['开开']='开开来了:BAAALAAECgIIAgAAAA==.',['开心']='开心马蝼:BAACLAAFFH85AAIKAAcICyZMAQCDAgAKAAcICyZMAQCDAgAsAAQKfzQAAgoACAh1JnYFAHMDAAoACAh1JnYFAHMDAAAA.',['张墩']='张墩墩儿:BAAALAAECgYIBgAAAA==.',['归心']='归心似剑:BAAALAADCgYIBwAAAA==.',['徐卫']='徐卫彪:BAAALAAECgYICQAAAA==.',['德纳']='德纳修斯六鸽:BAAALAAECgEIAQAAAA==.',['德鲁']='德鲁大仙:BAABLAAFFH8GAAILAAII8w48NQBrAAALAAII8w48NQBrAAABLAAFFAYIGgABAOwTAA==.',['性感']='性感地崩子:BAAALAAECgQICAAAAA==.',['恩佐']='恩佐斯的使者:BAAALAAECgYICQAAAA==.',['恶魔']='恶魔烈手:BAAALAAECgYIBgAAAA==.',['惩戒']='惩戒:BAABLAAECn8aAAIKAAYIYx3tdQD+AQAKAAYIYx3tdQD+AQAAAA==.',['想养']='想养只鹦鹉:BAAALAADCggICAAAAA==.',['憨熊']='憨熊:BAAALAADCgEIAQAAAA==.',['懒猫']='懒猫不吃鱼:BAABLAAFFH8IAAIKAAQI1QZmPwCcAAAKAAQI1QZmPwCcAAAAAA==.',['我不']='我不是幽魂:BAAALAAECgUICwAAAA==.我不是机器人:BAAALAAECgMIBQAAAA==.',['我是']='我是戦士大王:BAABLAAECn8ZAAMNAAcIVxyvZgDDAQANAAcI0RmvZgDDAQAVAAYITBQwQwB2AQAAAA==.我是职业的:BAAALAAECgMIBAAAAA==.我是骑士大王:BAAALAAECgUIBQAAAA==.',['我要']='我要粉碎你:BAAALAAFFAIIBAABLAAFFAIIDAAOANcgAA==.',['我跑']='我跑图最快:BAAALAAFFAIIAgAAAA==.',['战痕']='战痕:BAAALAAECgYICwAAAA==.',['扛住']='扛住:BAAALAAECgUICgAAAA==.',['把酒']='把酒祝东风:BAABLAAFFH8GAAICAAQI1xTNPADjAAACAAQI1xTNPADjAAAAAA==.',['拉普']='拉普兰德:BAABLAAFFH8KAAIIAAIIySMEJgDHAAAIAAIIySMEJgDHAAAAAA==.',['拽拽']='拽拽:BAAALAAECgQIBAAAAA==.',['揽云']='揽云沾星月:BAAALAAECgYIBgAAAA==.',['敖武']='敖武:BAABLAAFFH8NAAINAAUIzx+dCwDcAQANAAUIzx+dCwDcAQAAAA==.',['斌斌']='斌斌:BAACLAAFFH8PAAIKAAUIsw+2MwDwAAAKAAUIsw+2MwDwAAAsAAQKfxgAAgoABwg4GjZQAHABAAoABwg4GjZQAHABAAAA.',['斯莱']='斯莱瑞克:BAABLAAFFH8GAAITAAIIWhdUHACDAAATAAIIWhdUHACDAAAAAA==.',['无敌']='无敌少女:BAAALAAECgQIBAAAAA==.无敌暴龙戦士:BAAALAAECgMIAwAAAA==.',['昂几']='昂几克拉:BAAALAAECgYIDQAAAA==.',['昂基']='昂基克拉:BAAALAAECgYIBgAAAA==.',['明云']='明云兮:BAAALAAECgMIBQAAAA==.',['明凯']='明凯:BAACLAAFFH8GAAIDAAMIZwR2DQCIAAADAAMIZwR2DQCIAAAsAAQKfx8AAwMACAjvDtcpAGgBAAMACAjvDtcpAGgBAAgABgggCqLsAA8BAAAA.',['明君']='明君:BAAALAAECgcIDgAAAA==.',['明喆']='明喆:BAAALAAFFAMIAwAAAA==.',['星期']='星期一:BAABLAAFFH8QAAISAAYIExH+MwByAQASAAYIExH+MwByAQABLAAFFAgIBwANAEIWAA==.',['星火']='星火燃残念:BAAALAAECgYICwAAAA==.',['春去']='春去秋来:BAAALAADCggICAAAAA==.',['暴力']='暴力三刀:BAAALAAECgYIBwAAAA==.暴力小母狼:BAAALAAECgcIDwAAAA==.',['暴走']='暴走精灵:BAABLAAECn8aAAMWAAYIww4QJgD4AAAWAAYIww4QJgD4AAACAAEI6gYPeAAtAAAAAA==.',['最初']='最初的声音:BAABLAAFFH8GAAIFAAIIQRsRVACTAAAFAAIIQRsRVACTAAABLAAFFAYIDAASACUiAA==.',['最后']='最后的死骑:BAAALAADCgYIBgAAAA==.',['朝露']='朝露丶:BAABLAAFFH8MAAICAAYI8h6uLABeAQACAAYI8h6uLABeAQAAAA==.',['朴孝']='朴孝敏:BAAALAADCgYIBgAAAA==.',['朴昭']='朴昭妍:BAAALAADCgYIBgAAAA==.',['桂琴']='桂琴吖:BAACLAAFFH8KAAIQAAII4gxdNACIAAAQAAII4gxdNACIAAAsAAQKfx8AAxAACAiAEv9EAMIBABAACAiAEv9EAMIBAA8AAQhBA2KmACIAAAAA.',['梦想']='梦想丶星空:BAAALAAECgYIBwAAAA==.',['梦赴']='梦赴光寥之乡:BAABLAAFFH8LAAISAAYI3RJ6MgB4AQASAAYI3RJ6MgB4AQAAAA==.',['橙毛']='橙毛黑熊:BAAALAAECggICAAAAA==.',['毛人']='毛人与风小号:BAAALAAECgEIAQAAAA==.',['民兵']='民兵队长:BAAALAADCgMIAwAAAA==.',['永恒']='永恒之光:BAACLAAFFH8PAAIXAAII4BHWEACWAAAXAAII4BHWEACWAAAsAAQKfyEAAhcACAj3IJUFAAIDABcACAj3IJUFAAIDAAAA.',['江心']='江心比心:BAAALAADCgQIBAAAAA==.',['汤母']='汤母丶里德尔:BAAALAAECgYIBgAAAA==.',['法仙']='法仙:BAAALAAECgYIBgAAAA==.',['洛小']='洛小冰:BAAALAAFFAIIAgAAAA==.洛小萌:BAABLAAFFH8KAAMYAAUIcRK0DQCvAAAYAAQI/wq0DQCvAAAKAAMITBeZPQClAAAAAA==.洛小颜:BAAALAAFFAIIAgAAAA==.',['洛弗']='洛弗斯基:BAAALAADCgYIBgAAAA==.',['流波']='流波将月去:BAABLAAFFH8MAAICAAYI+ReQIACVAQACAAYI+ReQIACVAQAAAA==.',['流浪']='流浪天使:BAAALAAFFAEIAQAAAA==.',['混沌']='混沌之爪:BAAALAAECgcIBwAAAA==.',['清微']='清微天:BAAALAAECgQIBAAAAA==.',['清风']='清风幽谷:BAAALAAECgYIEAAAAA==.',['游城']='游城十代:BAAALAAECgYICgAAAA==.',['满城']='满城风雨:BAAALAAECgYIDQAAAA==.',['灬万']='灬万剑一:BAAALAADCgYIBgAAAA==.',['炮团']='炮团制造:BAAALAAECgYIDAAAAA==.',['烟花']='烟花不太冷丿:BAAALAADCgUIBQAAAA==.',['焚混']='焚混灬铅华:BAAALAAFFAIIBAAAAA==.',['熊熊']='熊熊:BAABLAAFFH8GAAILAAIIiBYuLwB2AAALAAIIiBYuLwB2AAAAAA==.',['熊猫']='熊猫大王:BAAALAADCggIDQAAAA==.',['熹楽']='熹楽:BAACLAAFFH80AAIIAAYIDxeNGgCjAQAIAAYIDxeNGgCjAQAsAAQKfywAAggABwhdG4RQADECAAgABwhdG4RQADECAAAA.',['爆爆']='爆爆成年版:BAAALAAFFAYIAgAAAA==.爆爆爱射击:BAAALAAECgEIAQAAAA==.',['爱上']='爱上客人的咕:BAAALAAFFAIIAgAAAA==.',['爱骑']='爱骑行的小包:BAAALAAECgYIDAAAAA==.',['牛宝']='牛宝爱吃猪:BAABLAAFFH8GAAMSAAYI3RDFTgD3AAASAAUIow/FTgD3AAAXAAEI/hY5DwBYAAAAAA==.',['牛崽']='牛崽子:BAAALAADCgYIBgAAAA==.',['牛犇']='牛犇牛犇:BAAALAADCgcIBwAAAA==.',['猜猜']='猜猜我是谁:BAAALAAECgYIBgAAAA==.',['球球']='球球:BAAALAAECggIDwAAAA==.',['琦哥']='琦哥:BAABLAAECn8XAAISAAYILwzvdgADAQASAAYILwzvdgADAQAAAA==.',['瑄瑄']='瑄瑄:BAACLAAFFH8OAAIFAAUIew/nUwAIAQAFAAUIew/nUwAIAQAsAAQKfxsAAgUACAiaEAxhAIMBAAUACAiaEAxhAIMBAAAA.瑄瑄呀:BAACLAAFFH8FAAIBAAMIIQRuXABEAAABAAMIIQRuXABEAAAsAAQKfyYAAgEABgh+BGTLANAAAAEABgh+BGTLANAAAAAA.',['瓦莱']='瓦莱里安:BAAALAAECgYIEwAAAA==.',['瓶子']='瓶子风行者:BAAALAADCgMIAwAAAA==.',['用飘']='用飘柔洗脚:BAAALAADCgYIBgAAAA==.',['疯癫']='疯癫大仙:BAACLAAFFH8aAAIBAAYI7BOQKgB0AQABAAYI7BOQKgB0AQAsAAQKfy4AAwEACAjeHdEnAKUCAAEACAjeHdEnAKUCABkAAQgkG06WADwAAAAA.',['看我']='看我干嘛看剑:BAAALAAECgcICAAAAA==.',['短鼻']='短鼻子章鱼哥:BAAALAADCggICAAAAA==.',['矮冬']='矮冬瓜:BAAALAADCgEIAQAAAA==.',['硝烟']='硝烟铁血呐喊:BAABLAAECn8XAAMNAAYI5Q3ctQAUAQANAAYIiw3ctQAUAQAaAAQIIQ2xLQCHAAAAAA==.',['碎魂']='碎魂小宝宝:BAAALAAECgYIDAAAAA==.碎魂糜糜:BAABLAAECn8VAAIFAAYIFhXmoAAbAQAFAAYIFhXmoAAbAQAAAA==.碎魂谧谧:BAAALAAECgYIDwAAAA==.碎魂靡靡:BAABLAAECn8XAAIKAAgINhgMTwBSAgAKAAgINhgMTwBSAgAAAA==.',['神父']='神父忽悠着你:BAAALAAECgcIBwAAAA==.',['神通']='神通大了去了:BAACLAAFFH8IAAMbAAYImQ5+ZQBXAAAbAAIIgwp+ZQBXAAAEAAYIfQCCTwA2AAAsAAQKfxkAAxsABgiqF7A2AIUBABsABgiqF7A2AIUBAAQABQj5BRBiAJEAAAAA.',['秋风']='秋风知我心:BAAALAADCgUIBQAAAA==.',['空刃']='空刃:BAABLAAFFH8hAAISAAgIlCOJAwDTAgASAAgIlCOJAwDTAgAAAA==.',['笑天']='笑天下:BAACLAAFFH8QAAIBAAYIrgujMABbAQABAAYIrgujMABbAQAsAAQKfxQAAwEABwjYHSwoALoBAAEABwgFHSwoALoBABkAAghUGHZ5AJQAAAAA.',['第二']='第二个混子:BAAALAAECgYICQAAAA==.',['简单']='简单玩得:BAAALAADCgIIAgAAAA==.简单玩猎:BAAALAAECgYIBgABLAAFFAgIHAAMAOIkAA==.简单玩玩:BAAALAAECgIIAgAAAA==.简单玩骑:BAAALAADCgQIBAAAAA==.',['米洛']='米洛迦:BAABLAAFFH8FAAIBAAUIcxHNPQARAQABAAUIcxHNPQARAQAAAA==.',['粉嫩']='粉嫩的坤坤:BAABLAAFFH8MAAMCAAII1ROGVQCLAAACAAIIXQyGVQCLAAAWAAIIVBAOHwAzAAAAAA==.粉嫩的鲲鹏:BAAALAAFFAIIBAAAAA==.',['粉紅']='粉紅色鑽石:BAABLAAFFH8GAAICAAYI6xNzDQD8AQACAAYI6xNzDQD8AQAAAA==.',['红悟']='红悟能:BAAALAADCgQIBAAAAA==.',['红色']='红色拖拉机:BAAALAADCgQIBAAAAA==.',['结局']='结局灬待续:BAABLAAFFH8KAAMSAAgI0xxGDwAdAgASAAcILR5GDwAdAgAXAAEIVxNcEABTAAAAAA==.',['美味']='美味牛肉饼:BAAALAAFFAMIAwAAAA==.',['美团']='美团狗狗骑手:BAABLAAECn8aAAMcAAgIyQpcOgB5AQAcAAgIyQpcOgB5AQAKAAYIHBM21ABrAQAAAA==.',['老六']='老六大窝瓜:BAABLAAFFH8GAAISAAYIsxVTCgAMAgASAAYIsxVTCgAMAgAAAA==.',['老李']='老李头啊:BAAALAADCgcIBwAAAA==.',['耐奥']='耐奥雷祖:BAAALAADCggICAAAAA==.',['耳紅']='耳紅:BAAALAAECgIIAgAAAA==.',['聪姐']='聪姐:BAAALAAFFAIIAwAAAA==.',['肉碎']='肉碎茄子:BAABLAAFFH8PAAMCAAMIUR/5MADHAAACAAMIUR/5MADHAAAWAAIISQzjFgB+AAABLAAFFAYIEQAIALsYAA==.',['胖大']='胖大的钮子:BAAALAAECgYIBgAAAA==.',['胖小']='胖小达:BAABLAAFFH8KAAIFAAYI8hUqOgBeAQAFAAYI8hUqOgBeAQAAAA==.',['胡丽']='胡丽精:BAAALAAECgEIAQAAAA==.',['自然']='自然天使圣灵:BAABLAAFFH8TAAIKAAYIRg9sGQD3AAAKAAYIRg9sGQD3AAAAAA==.',['艾丽']='艾丽芬:BAAALAAECgIIAgAAAA==.',['艾希']='艾希:BAAALAADCgMIAwAAAA==.',['芙莉']='芙莉莲:BAACLAAFFH8FAAICAAUIEAR1QgChAAACAAUIEAR1QgChAAAsAAQKfyUAAwIACAjbEDppAMwBAAIACAjbEDppAMwBABYAAwj1AYiTADQAAAEsAAUUCAgMAB0AchYA.',['芝士']='芝士雪报:BAAALAADCggICgAAAA==.',['芸兮']='芸兮:BAAALAAECgQIBAAAAA==.',['苏素']='苏素:BAACLAAFFH8ZAAIKAAUIhiWvBQAMAgAKAAUIhiWvBQAMAgAsAAQKfxUABBgABghjGjJEACYBABgABghyEDJEACYBABwABgiZCv5OABoBAAoABAjbGU2XANUAAAAA.',['苏肃']='苏肃:BAACLAAFFH8bAAMSAAUIoyOdCgAJAgASAAUIoyOdCgAJAgAXAAEIdhl7GwBVAAAsAAQKfxQAAxIABgj0JQE8AIwCABIABgj0JQE8AIwCABcAAwjQIXI4ABMBAAAA.',['苦痛']='苦痛折磨:BAAALAAECgYIBgAAAA==.',['茶百']='茶百道福利官:BAAALAAFFAIIAgAAAA==.',['莽就']='莽就完了:BAAALAAECgIIAgAAAA==.',['萌兰']='萌兰:BAAALAAFFAIIAgAAAA==.',['萌家']='萌家轩宝:BAABLAAECn8VAAIIAAgIKxftHAD8AQAIAAgIKxftHAD8AQAAAA==.',['萨满']='萨满:BAAALAAECgYIBgAAAA==.',['落霞']='落霞烟雪灬娜:BAAALAADCgYIBgAAAA==.',['蓝沧']='蓝沧月:BAAALAAECgUICAAAAA==.',['蓝色']='蓝色海郁云烟:BAAALAAECgUIBgAAAA==.',['蔓蔓']='蔓蔓云烟:BAAALAAECgIIAgAAAA==.',['虎生']='虎生:BAAALAAECgYIBgAAAA==.',['蛮叁']='蛮叁刀:BAABLAAFFH8PAAISAAYICRNdMQB8AQASAAYICRNdMQB8AQAAAA==.',['蜀道']='蜀道英雄:BAAALAADCgYIBgAAAA==.',['衡山']='衡山客:BAAALAAECgYICAAAAA==.',['角俏']='角俏俏:BAAALAAECggICAAAAA==.',['解释']='解释真容易:BAAALAAECgMIAwAAAA==.',['请你']='请你吃闪电链:BAAALAAECgYIBgAAAA==.',['请叫']='请叫我骑士:BAABLAAFFH8GAAIYAAIICRQAFQCAAAAYAAIICRQAFQCAAAABLAAFFAYIGgABAOwTAA==.',['谁拿']='谁拿了我的头:BAAALAAECgIIAgAAAA==.',['贤贤']='贤贤易色:BAAALAAECgYIBgAAAA==.',['走走']='走走道生啦:BAAALAADCgIIAgAAAA==.',['越共']='越共诱捕器:BAAALAAECgYIBgAAAA==.',['轻若']='轻若如初:BAAALAAECgYIBgAAAA==.',['达不']='达不溜丶圣盾:BAABLAAFFH8VAAMYAAUI9xUDCwD7AAAYAAUIfRIDCwD7AAAKAAMIMxvdPgCeAAAAAA==.达不溜丶坠星:BAABLAAFFH8FAAMJAAMIlhdcBACeAAAJAAIIIhJcBACeAAAFAAMIlhfObACPAAAAAA==.达不溜丶戾魔:BAACLAAFFH8GAAMDAAIICw5DFQAsAAAIAAII+AweXQBCAAADAAIIIAtDFQAsAAAsAAQKfxUAAwgACAiHGVFVACQCAAgABwhmG1FVACQCAAMAAghlCrkpAFIAAAAA.',['迷人']='迷人的洋葱头:BAAALAAECgIIAgAAAA==.',['那个']='那个战市:BAAALAAECgUIBQAAAA==.',['邪术']='邪术大忽悠:BAAALAAECgYIBgAAAA==.',['邪瞳']='邪瞳:BAAALAAECgYIBgAAAA==.',['邻家']='邻家小猎猎:BAAALAADCggICAAAAA==.',['都发']='都发地方:BAACLAAFFH8IAAILAAIIlhNWQQByAAALAAIIlhNWQQByAAAsAAQKfycABAsACAiOE5khAMsBAAsACAiOE5khAMsBAB4ABgjbFroNAF8BAAwABgiWEgctAB0BAAAA.',['酒魔']='酒魔德:BAAALAAECgMIAwAAAA==.',['酱油']='酱油术:BAAALAAECgYIBgAAAA==.',['酸辣']='酸辣小菜鸡:BAAALAAFFAIIAgAAAA==.',['长歌']='长歌幻故川:BAAALAAECgQIBAAAAA==.',['阿修']='阿修罗攀打:BAAALAADCgYIBgAAAA==.',['阿呆']='阿呆:BAAALAAECgUIBQAAAA==.',['阿琳']='阿琳:BAAALAADCgYIBgAAAA==.',['阿鸡']='阿鸡波:BAAALAAECgIIAgAAAA==.',['随地']='随地大小揷:BAAALAAECgMIBgAAAA==.',['随风']='随风飘无影:BAAALAAECgYIEwAAAA==.',['雄库']='雄库鲁:BAAALAAECgMIAwAAAA==.',['雨浸']='雨浸落花秋:BAAALAAECgUIBwAAAA==.',['雨碎']='雨碎江南:BAAALAAECgYIBgAAAA==.',['霸气']='霸气男人味:BAAALAADCggICAAAAA==.',['青彦']='青彦:BAACLAAFFH8MAAISAAMIgRs1RwCpAAASAAMIgRs1RwCpAAAsAAQKfxcAAhIABgh/JJslAOMBABIABgh/JJslAOMBAAAA.',['颓废']='颓废小步调:BAAALAAECgUIAQAAAA==.',['風雪']='風雪夜帰人:BAAALAADCggIDgAAAA==.',['飞刀']='飞刀:BAAALAAECgYIBgAAAA==.',['飞飞']='飞飞刀:BAAALAADCgQIBgAAAA==.',['騎牛']='騎牛大叔:BAABLAAFFH8GAAIFAAIIehjznwA/AAAFAAIIehjznwA/AAAAAA==.',['驯猪']='驯猪高手:BAAALAAECgEIAQAAAA==.',['高人']='高人一筹:BAAALAAECgUIBQABLAAFFAgIEgAFAM0MAA==.',['高等']='高等:BAABLAAECn8ZAAISAAYIHh85NQCmAQASAAYIHh85NQCmAQAAAA==.',['魂梦']='魂梦与君同:BAABLAAFFH8IAAICAAYIGxNQKgBqAQACAAYIGxNQKgBqAQAAAA==.',['魏静']='魏静祥:BAAALAADCgIIAgAAAA==.',['魔猎']='魔猎:BAAALAAECgYIBgAAAA==.',['鲨鱼']='鲨鱼宝宝:BAAALAAECgEIAQAAAA==.鲨鱼潮汐:BAABLAAFFH8GAAIFAAMIJiKIGwAoAQAFAAMIJiKIGwAoAQAAAA==.',['鸡子']='鸡子国:BAAALAADCggICAAAAA==.鸡子权:BAAALAADCggICAAAAA==.',['麦兜']='麦兜神话:BAAALAAECggICAAAAA==.',['麻匪']='麻匪:BAABLAAFFH8IAAIEAAIIGBZFJwCZAAAEAAIIGBZFJwCZAAABLAAFFAgICwAbAEofAA==.',['麻哥']='麻哥爱你们:BAAALAADCgIIAgAAAA==.麻哥自有妙计:BAAALAAECgYIBwAAAA==.',['黄瓜']='黄瓜可以吗:BAAALAADCgYIBgAAAA==.',['黑猫']='黑猫:BAAALAAECgYIBgAAAA==.',['黑铁']='黑铁:BAAALAAECgUIBwAAAA==.',['龙灬']='龙灬夏月:BAAALAAECgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end