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
 local lookup = {'Paladin-Retribution','Paladin-Holy','Druid-Balance','Druid-Restoration','Warrior-Protection','DeathKnight-Frost','Shaman-Restoration','Shaman-Elemental','Priest-Holy','Hunter-BeastMastery','Warlock-Destruction','Mage-Frost','Rogue-Assassination','Warrior-Fury','Druid-Feral','DemonHunter-Havoc','Rogue-Subtlety','DeathKnight-Blood','Priest-Shadow','Druid-Guardian','Mage-Arcane','DemonHunter-Vengeance','Paladin-Protection','Warlock-Demonology','Priest-Discipline','Warrior-Arms','Hunter-Marksmanship','DeathKnight-Unholy','Monk-Mistweaver','Monk-Windwalker','Warlock-Affliction',}; local provider = {region='CN',realm='玛维·影歌',name='CN',type='weekly',zone=44,date='2025-12-07',data={An='Angiecc:BAABLAAFFH8GAAIBAAYIvBtdFwCZAQABAAYIvBtdFwCZAQAAAA==.',Be='Bellona:BAAALAAECgYIBgAAAA==.',Ca='Canaan:BAAALAAFFAIIBAAAAA==.',Cu='Cuberly:BAABLAAFFH8GAAICAAIIwRFjJgBzAAACAAIIwRFjJgBzAAAAAA==.Cuihua:BAAALAAFFAIIAgAAAA==.',Do='Doodmoon:BAAALAAFFAIIBAAAAA==.',Fa='Father:BAAALAAFFAIIAgAAAA==.',Fu='Funnymudpee:BAABLAAFFH8HAAMDAAUI/xDHGQALAQADAAUI/xDHGQALAQAEAAEIcQQRXgAyAAAAAA==.',Gs='Gsdfga:BAAALAAFFAQIBAAAAA==.',Gu='Gunrose:BAAALAAECgYIBwAAAA==.',Ha='Hahayan:BAAALAADCggICgAAAA==.',Ja='Jamespaul:BAAALAAFFAIIAgAAAA==.',Je='Jett:BAAALAAECgYIBgAAAA==.',Ka='Kami:BAAALAAFFAIIAgAAAA==.',Li='Lierdan:BAAALAADCgQIBwAAAA==.Lifengzs:BAABLAAFFH8IAAIFAAgIuxvoAgBFAgAFAAgIuxvoAgBFAgAAAA==.Lisanren:BAAALAADCgEIAQAAAA==.Lisdan:BAAALAADCgYIBgAAAA==.Lisidan:BAAALAADCgYICQAAAA==.',Lo='Lonewolf:BAAALAAECgEIAQAAAA==.Lovey:BAACLAAFFH80AAIGAAcINCVtBgCYAgAGAAcINCVtBgCYAgAsAAQKfyAAAgYACAgEI6MQAGgCAAYACAgEI6MQAGgCAAAA.',Ly='Lyz:BAAALAAECgYICAAAAA==.',Mo='Moogy:BAAALAAECggIAQAAAA==.Moyo:BAAALAAFFAYIAQAAAA==.',Re='Regression:BAAALAAECgYIBgAAAA==.Regressiono:BAAALAAECgYIBgAAAA==.Regressionoo:BAAALAAECgYICQAAAA==.Regressionss:BAAALAAECgUIBQAAAA==.',Ro='Roddy:BAAALAADCgYIBgAAAA==.',Sa='Salt:BAAALAAECgYICwAAAA==.',Sc='Schaman:BAABLAAFFH8XAAMHAAMIiBWXOgC6AAAHAAMIiBWXOgC6AAAIAAMIvQs9NwCCAAAAAA==.',Si='Sita:BAAALAAFFAIIAgAAAA==.',Su='Sulayman:BAAALAAECgEIAQAAAA==.',Sv='Svy:BAAALAAECgYIEwAAAA==.',Sy='Sybz:BAABLAAFFH8GAAIGAAMIGAY8aAB5AAAGAAMIGAY8aAB5AAAAAA==.',To='Tohkaam:BAAALAAECgQIBAAAAA==.',Ve='Velen:BAABLAAFFH8QAAIJAAUIax2WBgDvAQAJAAUIax2WBgDvAQAAAA==.Velonica:BAAALAADCggICAAAAA==.',Vi='Viviana:BAAALAAFFAEIAQAAAA==.',Yu='Yuliko:BAAALAADCgUIBQABLAAFFAIIBgACAMERAA==.',Zy='Zy:BAAALAAFFAIIBAAAAA==.',['一剑']='一剑成王:BAAALAAFFAIIAgAAAA==.',['一叶']='一叶千花:BAAALAAFFAIIAgAAAA==.',['一定']='一定不咕:BAAALAAECgEIAQAAAA==.',['一射']='一射成王:BAAALAAFFAIIAgAAAA==.',['一棍']='一棍成王:BAAALAAECgIIAgAAAA==.',['一生']='一生情缘:BAAALAAECgMIBwAAAA==.一生爱:BAAALAAECgUIBQAAAA==.一生缘分:BAAALAADCggICAAAAA==.',['一重']='一重:BAAALAADCgIIAgAAAA==.',['一锤']='一锤成王:BAAALAAFFAIIAgAAAA==.',['一鸣']='一鸣同学:BAAALAAFFAIIBAAAAA==.',['七小']='七小度:BAAALAAECgMIAwAAAA==.',['三只']='三只奶牛:BAAALAAECgUICQAAAA==.',['不会']='不会圣疗:BAAALAAFFAIIAgAAAA==.',['不似']='不似风月:BAAALAAECgUIBQAAAA==.',['不太']='不太可爱了呢:BAAALAADCgEIAQAAAA==.',['不然']='不然:BAAALAADCgMIAwAAAA==.',['不知']='不知:BAAALAADCgQIBAAAAA==.',['业务']='业务员丶:BAAALAADCgYIBgAAAA==.',['两三']='两三百斤:BAAALAAECgYIBgAAAA==.',['丨灬']='丨灬至尊宝丶:BAABLAAFFH8GAAIKAAYIMxDpQABGAQAKAAYIMxDpQABGAQAAAA==.',['中郁']='中郁闷:BAAALAAECgQIAwAAAA==.',['丶悍']='丶悍夫:BAAALAAECgcIDAAAAA==.',['丹宗']='丹宗小弟:BAAALAAECgMIBQAAAA==.',['为了']='为了上班:BAAALAADCgUIBQAAAA==.',['乌龙']='乌龙山伯爵:BAABLAAFFH8LAAIJAAIIpwV2PwB3AAAJAAIIpwV2PwB3AAAAAA==.',['乐不']='乐不乐:BAAALAADCggIDgAAAA==.',['也太']='也太可爱了吧:BAAALAAECgYIBgAAAA==.',['五火']='五火球教主:BAAALAADCgIIAgAAAA==.',['人心']='人心薄凉丶伤:BAABLAAFFH8GAAIEAAYIPhNtBgC9AQAEAAYIPhNtBgC9AQAAAA==.',['人艰']='人艰不拆:BAAALAADCgIIAgAAAA==.',['今宵']='今宵酒醒何岸:BAAALAAECgYIBwAAAA==.',['代号']='代号陨石:BAAALAADCgUIBQAAAA==.',['仲晓']='仲晓灬遁地:BAAALAAECgQIBAAAAA==.',['仿若']='仿若暮夏:BAAALAAFFAIIAwAAAA==.',['伊利']='伊利亚丹:BAAALAAECgEIAQAAAA==.',['伊纳']='伊纳瑞斯:BAAALAAFFAIIBAAAAA==.',['伍拾']='伍拾:BAABLAAFFH8FAAILAAIIyA1ZXQBCAAALAAIIyA1ZXQBCAAABLAAFFAUIJwALALEXAA==.',['众生']='众生祈念丶:BAABLAAFFH8MAAIHAAYIOyLABwBJAgAHAAYIOyLABwBJAgAAAA==.',['伴阳']='伴阳光飞行:BAAALAAECggICAAAAA==.',['作业']='作业太多辣:BAABLAAFFH8KAAIBAAMI4hdjPgCcAAABAAMI4hdjPgCcAAAAAA==.',['你不']='你不知道:BAAALAAECgcIBwAAAA==.',['你也']='你也太可爱了:BAAALAAECgYICAAAAA==.',['俺似']='俺似劣人:BAAALAAECgUIBwAAAA==.',['倚天']='倚天屠龙几:BAAALAAECgYIBgAAAA==.',['倾城']='倾城丶:BAAALAAECgYICwAAAA==.',['元气']='元气橘子猫:BAAALAAFFAIIBAAAAA==.',['公主']='公主去哪了:BAAALAAFFAIIAgAAAA==.',['六天']='六天七夜:BAAALAAECgYICAAAAA==.',['冰鲜']='冰鲜柠檬:BAAALAAECgYIBgAAAA==.',['凄凄']='凄凄惨惨:BAAALAAECgQICQAAAA==.',['凤凰']='凤凰单枞:BAABLAAFFH8GAAIMAAYIZh/XAgDEAQAMAAYIZh/XAgDEAQAAAA==.',['別說']='別說:BAAALAAECgUIBQAAAA==.',['别惹']='别惹我恐惧伱:BAAALAADCgIIAgAAAA==.',['刷卡']='刷卡买就完了:BAAALAAECgIIAgAAAA==.',['刺杀']='刺杀之吻:BAABLAAFFH8OAAINAAYIbhUSCACbAQANAAYIbhUSCACbAQAAAA==.',['剑啸']='剑啸九天:BAACLAAFFH8OAAIOAAMITRNsOwCGAAAOAAMITRNsOwCGAAAsAAQKfyIAAg4ACAh6G0svAHsCAA4ACAh6G0svAHsCAAAA.',['剑心']='剑心之遗:BAAALAAECgYIBgAAAA==.',['勇敢']='勇敢牛大:BAAALAAFFAIIAgAAAA==.',['北北']='北北:BAABLAAFFH8PAAIMAAQIQhRPCgDLAAAMAAQIQhRPCgDLAAAAAA==.',['北城']='北城柳絮飞:BAAALAAFFAIIAgAAAA==.',['北戴']='北戴河:BAAALAAECgYIDAAAAA==.',['千年']='千年猎:BAAALAAECgQIBAAAAA==.',['千早']='千早爱音:BAAALAAECgMIAwAAAA==.',['半别']='半别恨半心凉:BAACLAAFFH8PAAMPAAQIRBhHBgD6AAAPAAMIvBNHBgD6AAAEAAIIiwz8OABnAAAsAAQKfyUABA8ACAibH2UKAKwCAA8ACAibH2UKAKwCAAQACAihEJJJALwBAAMABgigEo9kAC0BAAAA.',['半点']='半点星图:BAAALAADCgEIAQAAAA==.',['华胥']='华胥绫丶:BAABLAAECn8cAAIQAAgIKRfmZAD+AQAQAAgIKRfmZAD+AQAAAA==.',['南城']='南城琉璃月:BAAALAAECgYIEwAAAA==.',['厚礼']='厚礼蟹丶:BAABLAAFFH8IAAIGAAQIKQ+gWQCbAAAGAAQIKQ+gWQCbAAAAAA==.',['原味']='原味绵绵冰:BAAALAAECgcIDgAAAA==.',['厮杀']='厮杀汉:BAAALAADCggICAAAAA==.',['双刀']='双刀捕蝇草:BAACLAAFFH84AAMNAAYIUx7iCgBjAQANAAQIZxziCgBjAQARAAIIKyKxEABmAAAsAAQKfywAAw0ACAgXH3QnAOIBAA0ACAjsGHQnAOIBABEABgh3GU4jAHoBAAAA.',['双娇']='双娇赵合德:BAACLAAFFH8uAAMGAAYIsyEUEwD5AQAGAAYIsyEUEwD5AQASAAEIHgKxHgAnAAAsAAQKfyUAAgYACAgYJDAQADIDAAYACAgYJDAQADIDAAAA.',['双持']='双持狂暴战:BAABLAAFFH8XAAMHAAUIABgLIABeAQAHAAUIABgLIABeAQAIAAEInwpCWAAAAAAAAA==.',['叫不']='叫不醒的猪:BAABLAAECn8UAAIKAAcIvRmASAC3AQAKAAcIvRmASAC3AQAAAA==.',['可达']='可达鸭跟班:BAABLAAFFH8IAAIOAAII+RH9NgCXAAAOAAII+RH9NgCXAAAAAA==.',['司雨']='司雨迷:BAAALAAFFAIIBAAAAA==.',['司马']='司马上官:BAABLAAFFH8GAAMIAAYIiQLYOwBfAAAIAAUI9gDYOwBfAAAHAAEI+gAlggAXAAAAAA==.司马令狐:BAACLAAFFH8JAAMHAAYIxxJAJwArAQAHAAUIEA9AJwArAQAIAAEI8gEBUQAzAAAsAAQKfxYAAgcABAhrI8U1AIgBAAcABAhrI8U1AIgBAAAA.司马西门:BAABLAAFFH8MAAMJAAYIjAXwIgAtAQAJAAYIjAXwIgAtAQATAAIInwDGNAAIAAAAAA==.',['向日']='向日葵的花语:BAAALAAFFAIIAgAAAA==.',['向阳']='向阳花开:BAAALAAECgYIDAAAAA==.',['听风']='听风吟:BAAALAAECgYICwAAAA==.',['咕天']='咕天乐丶:BAAALAADCggICAAAAA==.',['哈仕']='哈仕奇:BAAALAAECgQIBAAAAA==.',['哟佬']='哟佬黑:BAAALAAECgYIDQAAAA==.',['唐门']='唐门大长老:BAAALAAECgQIBAAAAA==.',['啊呜']='啊呜呜:BAABLAAFFH8IAAIOAAgIpACTZgAWAAAOAAgIpACTZgAWAAAAAA==.',['喵丶']='喵丶兽兽:BAAALAAECgMIAwAAAA==.',['嗜血']='嗜血闪闪:BAAALAAECgIIAgAAAA==.',['嘉嘉']='嘉嘉:BAABLAAFFH8IAAIEAAIIyA9xRwBhAAAEAAIIyA9xRwBhAAAAAA==.',['嘴角']='嘴角的樱桃汁:BAABLAAFFH8JAAIEAAMI+gVqKQCGAAAEAAMI+gVqKQCGAAAAAA==.',['噬魂']='噬魂丨鬼魅:BAAALAAECgYIBgAAAA==.',['回忆']='回忆也许美:BAAALAAECgcIEAAAAA==.',['图拉']='图拉样:BAAALAAECgcIEAAAAA==.',['土得']='土得冒烟:BAAALAAECgEIAQAAAA==.',['圣光']='圣光丶照耀:BAAALAAFFAIIBAAAAA==.圣光之锋:BAABLAAFFH8MAAIGAAQIsQU1iABCAAAGAAQIsQU1iABCAAAAAA==.圣光低估了我:BAABLAAFFH8GAAIGAAII5QPRowAyAAAGAAII5QPRowAyAAAAAA==.圣光有点脏:BAABLAAFFH8XAAIQAAYIKRitGQCkAQAQAAYIKRitGQCkAQAAAA==.圣光背叛了我:BAAALAAFFAIIBAAAAA==.',['地明']='地明星铁笛仙:BAAALAAFFAIIBAAAAA==.',['堀江']='堀江由衣酱:BAABLAAECn8WAAIEAAYIkQo2kAD4AAAEAAYIkQo2kAD4AAAAAA==.',['塞北']='塞北:BAAALAAECgYICAAAAA==.',['塞巴']='塞巴斯塔:BAAALAAECgYIBgAAAA==.',['墨丶']='墨丶白:BAAALAAECgUIBQAAAA==.',['墨颜']='墨颜丶:BAABLAAFFH8GAAIQAAIIYg7iRACWAAAQAAIIYg7iRACWAAAAAA==.墨颜吖:BAAALAAECgIIAgAAAA==.墨颜呐:BAAALAAFFAIIAgAAAA==.',['夏露']='夏露露:BAABLAAFFH8IAAIUAAIIYQX6CwBRAAAUAAIIYQX6CwBRAAAAAA==.',['外翻']='外翻丶玫瑰:BAABLAAFFH8MAAMTAAMITgs2FQDUAAATAAMITgs2FQDUAAAJAAIIBxgtKQCYAAAAAA==.',['多多']='多多辛迪:BAABLAAECn8aAAIKAAgIxiChQABlAgAKAAgIxiChQABlAgAAAA==.',['夜之']='夜之惧:BAAALAAECgIIAgAAAA==.',['夜影']='夜影画情殇:BAAALAADCgEIAQAAAA==.',['夜行']='夜行恶魔:BAAALAAFFAIIBAAAAA==.夜行我狂:BAABLAAFFH8IAAMMAAMILA0DEQCNAAAMAAII1hIDEQCNAAAVAAMI2wMRTABmAAAAAA==.夜行汐禾:BAABLAAFFH8OAAIGAAMIIxn0VgCvAAAGAAMIIxn0VgCvAAAAAA==.夜行的魅惑:BAAALAAECgYIBgAAAA==.',['大北']='大北北:BAAALAAFFAIIBAAAAA==.',['大曾']='大曾加:BAAALAAECgYIDgAAAA==.',['大波']='大波浪:BAABLAAECn8WAAIOAAYIQB11LACsAQAOAAYIQB11LACsAQAAAA==.',['大熊']='大熊之熊:BAAALAAECgYICQAAAA==.',['大雷']='大雷凤:BAAALAAECgYIDAAAAA==.',['天天']='天天皆是你:BAAALAAFFAIIBAAAAA==.',['天尊']='天尊:BAAALAAECgYIBgAAAA==.',['天微']='天微星九纹龙:BAAALAAECgUIBQAAAA==.',['天怒']='天怒:BAAALAAECgQIBAAAAA==.',['天无']='天无风:BAAALAAECgYIBgAAAA==.',['天枢']='天枢残光:BAAALAAECgYIDwAAAA==.',['天罡']='天罡七十二变:BAAALAAECgIIAgAAAA==.',['天败']='天败星活阎罗:BAABLAAFFH8HAAILAAMI5AqVUwBlAAALAAMI5AqVUwBlAAAAAA==.',['天际']='天际蓝明雨:BAAALAAECgcIBwAAAA==.',['天霸']='天霸汉:BAABLAAECn8WAAIGAAcIjBgeMQCzAQAGAAcIjBgeMQCzAQAAAA==.',['失眠']='失眠睡美人:BAABLAAFFH8GAAIEAAYItRQTFgCHAQAEAAYItRQTFgCHAQAAAA==.',['奈插']='奈插的穴:BAAALAADCgMIAwAAAA==.',['奕奕']='奕奕:BAAALAADCgMIAwAAAA==.',['奶量']='奶量十足:BAAALAADCggICAAAAA==.',['姐姐']='姐姐去哪了:BAAALAADCgYIBgAAAA==.',['娜乌']='娜乌西卡:BAAALAAFFAIIBAAAAA==.',['婷婷']='婷婷玉莉:BAAALAAECgYIBwAAAA==.',['孤月']='孤月行者:BAAALAAECgUICgAAAA==.',['守护']='守护:BAAALAAFFAIIAgAAAA==.',['密林']='密林幽影:BAABLAAECn8eAAIKAAgI/BRfWQCRAQAKAAgI/BRfWQCRAQAAAA==.',['寒威']='寒威霖:BAAALAAECgMIBAAAAA==.',['寒梦']='寒梦:BAABLAAFFH8HAAIVAAIInx+NNQCzAAAVAAIInx+NNQCzAAAAAA==.',['寒风']='寒风冷猎:BAAALAAECgcIDAAAAA==.',['小七']='小七度:BAAALAAECgUIBQAAAA==.',['小二']='小二丫的春天:BAABLAAFFH8KAAIEAAIIpQ41SQBeAAAEAAIIpQ41SQBeAAAAAA==.',['小北']='小北北:BAABLAAFFH8ZAAIJAAYI3BcbFAC3AQAJAAYI3BcbFAC3AQAAAA==.',['小小']='小小萨麦尔:BAAALAAECgYIBgAAAA==.',['小手']='小手丶冰凉:BAABLAAFFH8FAAIEAAIIlgwXSQBeAAAEAAIIlgwXSQBeAAAAAA==.',['小楼']='小楼一夜:BAAALAAECgYIDwAAAA==.',['小波']='小波:BAAALAAECgQIBwAAAA==.',['小满']='小满哥:BAAALAADCgYIBgAAAA==.',['小狗']='小狗乐:BAABLAAFFH8GAAIHAAIIkxGcSgBwAAAHAAIIkxGcSgBwAAAAAA==.',['小胖']='小胖胖:BAABLAAFFH8FAAIEAAII6gc1TwBWAAAEAAII6gc1TwBWAAAAAA==.',['小芙']='小芙尔忒:BAACLAAFFH88AAIGAAgI8yD9BABUAgAGAAgI8yD9BABUAgAsAAQKfzsAAgYACAgnJsoDAHgDAAYACAgnJsoDAHgDAAAA.',['小鳴']='小鳴同学丶:BAAALAAFFAIIAgAAAA==.',['小鸣']='小鸣叔叔:BAACLAAFFH8GAAIBAAIISxcoOACkAAABAAIISxcoOACkAAAsAAQKfx4AAgEACAgQIOkwAK4CAAEACAgQIOkwAK4CAAAA.',['尛灬']='尛灬晓沫:BAAALAAECgYIBgAAAA==.',['尛老']='尛老板儿:BAAALAAECgQIBAAAAA==.',['就叫']='就叫老白吧:BAABLAAFFH8FAAIGAAUILSSjLQCFAQAGAAUILSSjLQCFAQAAAA==.',['崩坏']='崩坏星穹铁道:BAAALAAECgQIBAAAAA==.',['师傅']='师傅去哪了:BAAALAADCggICAAAAA==.',['希哥']='希哥:BAAALAAFFAIIAgAAAA==.',['帝国']='帝国兽猎者:BAAALAADCgMIAwAAAA==.',['带宝']='带宝宝打天下:BAAALAAECgYIDgAAAA==.',['度小']='度小七:BAAALAAFFAIIAgAAAA==.',['开心']='开心丶:BAAALAADCgMIAwAAAA==.开心亅:BAAALAAECgEIAQAAAA==.',['强制']='强制交社保:BAAALAAECgMIBgAAAA==.',['影歌']='影歌丷:BAABLAAFFH8UAAIVAAYIJx0DCgAcAgAVAAYIJx0DCgAcAgAAAA==.',['彼岸']='彼岸之梦:BAABLAAFFH8FAAIKAAUIhRhiUQAMAQAKAAUIhRhiUQAMAQAAAA==.',['微笑']='微笑情人:BAABLAAFFH8TAAMEAAUIjx2fHABFAQAEAAQIrhufHABFAQADAAUIExErGgAHAQAAAA==.',['微胖']='微胖才香:BAABLAAFFH8GAAIKAAIIiBNligBJAAAKAAIIiBNligBJAAAAAA==.',['德布']='德布利斤:BAABLAAFFH8cAAIEAAUI3hwEEwCmAQAEAAUI3hwEEwCmAQAAAA==.',['心底']='心底难藏泪:BAAALAAFFAIIAgAAAA==.',['忽毙']='忽毙猎:BAAALAAECgYICQAAAA==.',['思绪']='思绪万千:BAAALAADCgQIBAAAAA==.思绪飞扬:BAAALAAECgUIBQAAAA==.',['性感']='性感胡须:BAAALAADCgYIBAAAAA==.',['怺恆']='怺恆哋爾騎:BAAALAADCgIIAgAAAA==.',['想飞']='想飞上天:BAABLAAFFH8NAAIWAAUIlQpJCgCnAAAWAAUIlQpJCgCnAAABLAAFFAYIHwAXAD4PAA==.',['意见']='意见不合就干:BAABLAAFFH8GAAIFAAIISQQsOAAoAAAFAAIISQQsOAAoAAAAAA==.',['愤怒']='愤怒丶牪:BAAALAAFFAIIBAAAAA==.愤怒的锅包肉:BAAALAAFFAIIBAABLAAFFAMIDgAOAE0TAA==.',['我不']='我不吃刘肉:BAABLAAFFH8GAAMEAAYIyAlCJgDqAAAEAAUICwlCJgDqAAADAAEIgwUxOQA1AAAAAA==.',['我也']='我也是醉了:BAABLAAFFH8IAAIYAAIIuAzkFgA9AAAYAAIIuAzkFgA9AAAAAA==.',['我剑']='我剑自来:BAAALAADCgIIAgAAAA==.',['我叫']='我叫什么:BAAALAAFFAIIAgAAAA==.',['我就']='我就是可爱呀:BAAALAAECgcIDgAAAA==.',['我是']='我是科学家:BAAALAAECgIIAgAAAA==.',['我的']='我的小二丫:BAACLAAFFH8JAAIJAAIIEQZePQB7AAAJAAIIEQZePQB7AAAsAAQKfxYAAwkACAgRG+4tACoCAAkACAgRG+4tACoCABkAAQheCdI+AC8AAAAA.',['我老']='我老公最帅啦:BAAALAAFFAMIAwAAAA==.',['战帝']='战帝:BAAALAAECgYIBgAAAA==.',['戦神']='戦神狂拽:BAAALAAECggIAQAAAA==.',['戰天']='戰天:BAAALAAECgMIAwAAAA==.',['所有']='所有的人:BAAALAAECggICgAAAA==.',['打豆']='打豆丁:BAAALAAECgYIBgAAAA==.打豆豆:BAAALAAECgQIBAAAAA==.',['拂晓']='拂晓:BAAALAAECggICAAAAA==.',['接近']='接近神的人:BAAALAADCgIIAgAAAA==.',['摩根']='摩根:BAABLAAFFH8GAAIMAAIIzgYoIAAtAAAMAAIIzgYoIAAtAAAAAA==.',['故轩']='故轩:BAAALAAFFAMIAwAAAA==.',['散落']='散落于云海:BAABLAAFFH8MAAMHAAYIkxCLJQA2AQAHAAUIXhGLJQA2AQAIAAEI0QHBUwAsAAAAAA==.',['斯塔']='斯塔莱德丶白:BAAALAAECggIDgABLAAFFAYIEAAGABsaAA==.',['斯莫']='斯莫德:BAAALAAECgcIDgAAAA==.',['新鲜']='新鲜奶贝:BAACLAAFFH8GAAIOAAII6QrbQwCHAAAOAAII6QrbQwCHAAAsAAQKfyYAAw4ABwhfGig2AIIBAA4ABwhfGig2AIIBABoAAQikF/46ADkAAAAA.新鲜橙多:BAAALAAECgUIBQAAAA==.',['无爪']='无爪有爪:BAAALAAECgYIDAABLAAFFAYIOAANAFMeAA==.',['明月']='明月照我心:BAAALAAFFAIIAgAAAA==.',['昏木']='昏木:BAAALAADCgEIAQAAAA==.',['易水']='易水寒:BAABLAAFFH8GAAIbAAYIrBEZBgDGAQAbAAYIrBEZBgDGAQAAAA==.',['星光']='星光:BAABLAAFFH8MAAIBAAII3RF4RACbAAABAAII3RF4RACbAAAAAA==.',['星夜']='星夜愿:BAAALAAECgYIDAAAAA==.',['星彩']='星彩丶:BAAALAAECgYIBwAAAA==.',['星海']='星海丶:BAAALAAECgYIBgAAAA==.',['晓之']='晓之女神:BAAALAAECgYIBgAAAA==.',['暴躁']='暴躁的兔子:BAABLAAFFH8KAAIQAAUIRBRzLQAvAQAQAAUIRBRzLQAvAQAAAA==.',['最后']='最后一笑:BAAALAAECgYIEwAAAA==.',['最好']='最好一笑:BAABLAAECn8dAAMMAAYIShDRIgAMAQAMAAYIShDRIgAMAQAVAAYI8wP+zADPAAAAAA==.',['月中']='月中的玉兔猪:BAAALAAFFAIIAwAAAA==.',['朋友']='朋友推车吗:BAAALAAFFAIIBAAAAA==.',['木兰']='木兰花:BAABLAAFFH8LAAIKAAMILRwqZQCnAAAKAAMILRwqZQCnAAAAAA==.',['杀戮']='杀戮者丶影歌:BAAALAADCggIEAAAAA==.',['林火']='林火辣:BAAALAADCgcIBwAAAA==.',['枪炮']='枪炮与玫瑰:BAAALAAECggICAAAAA==.',['树精']='树精灵:BAAALAAECgUIBQAAAA==.',['格鲁']='格鲁特:BAABLAAFFH8IAAIEAAIIChjvNwCMAAAEAAIIChjvNwCMAAAAAA==.',['梦境']='梦境之影:BAAALAAECgYICgAAAA==.',['梨花']='梨花飘落:BAAALAAFFAIIBAAAAA==.',['棒槌']='棒槌德:BAAALAAECgYICgAAAA==.棒槌猎:BAAALAAECgYIDAAAAA==.',['死亡']='死亡公爵:BAAALAAECgYIEgAAAA==.',['死灵']='死灵起舞:BAAALAAECgYICwAAAA==.',['死神']='死神的輓歌:BAABLAAFFH8GAAIGAAYILxALOQBaAQAGAAYILxALOQBaAQAAAA==.',['气质']='气质女王:BAAALAAFFAIIBAAAAA==.',['沁心']='沁心:BAACLAAFFH8LAAIBAAQIcgk5PgCdAAABAAQIcgk5PgCdAAAsAAQKfxQAAwEABwizDcLQAHABAAEABwizDcLQAHABAAIABAjIAdZ0AFMAAAAA.',['没事']='没事做瓶子:BAAALAAECgcIBgAAAA==.没事玩一下:BAAALAADCggICAAAAA==.没事赦一下:BAACLAAFFH8JAAIKAAMI5AzkdQB2AAAKAAMI5AzkdQB2AAAsAAQKfxsAAgoACAg3Fg5gAIMBAAoACAg3Fg5gAIMBAAAA.',['沼泽']='沼泽:BAAALAAECgYIBgAAAA==.',['浅夏']='浅夏丶微微凉:BAAALAAECgYIBgAAAA==.',['浅竹']='浅竹:BAAALAAFFAIIBAAAAA==.',['浅羽']='浅羽:BAABLAAFFH8GAAMKAAII6h4+NgC3AAAKAAIIIB0+NgC3AAAbAAII2hR4IACIAAAAAA==.',['浩复']='浩复侵:BAAALAAECgEIAQAAAA==.',['海波']='海波東:BAAALAADCgEIAQAAAA==.',['涂山']='涂山蓉蓉:BAAALAAECgMIAwAAAA==.',['淡忘']='淡忘蛋蛋伤:BAAALAAECggICAAAAA==.',['清明']='清明雨上:BAABLAAFFH8GAAIGAAIIawfwmgA5AAAGAAIIawfwmgA5AAAAAA==.',['清艳']='清艳宝宝:BAAALAADCgUIBgAAAA==.',['清蒸']='清蒸羊蹄:BAAALAAECgYIBgAAAA==.',['游学']='游学者周桌:BAAALAAFFAIIAgABLAAFFAgICgAQAJ0EAA==.',['湖堤']='湖堤春晓:BAAALAAECgYICAAAAA==.',['漫步']='漫步六星:BAABLAAFFH8GAAILAAII+QddUACAAAALAAII+QddUACAAAAAAA==.',['潇洒']='潇洒:BAAALAAECgIIAwAAAA==.',['潜龙']='潜龙:BAAALAAECgYIBgAAAA==.',['灬爱']='灬爱因斯坦灬:BAAALAAECgYIEAAAAA==.',['灬鳯']='灬鳯舞灬:BAAALAAECgEIAQAAAA==.',['灬龍']='灬龍吟灬:BAAALAAECgQIBgAAAA==.',['炫天']='炫天残影:BAAALAAFFAIIAgAAAA==.',['炮仗']='炮仗:BAAALAAECgUIBQAAAA==.',['為所']='為所丶欲為:BAABLAAFFH8FAAIMAAII1BLvGwBeAAAMAAII1BLvGwBeAAAAAA==.',['燃烧']='燃烧恶魔丹:BAAALAADCggIDgAAAA==.燃烧暗影:BAAALAADCgYIBgAAAA==.燃烧的神官:BAABLAAFFH8GAAITAAIIYBCiIgCHAAATAAIIYBCiIgCHAAAAAA==.燃烧顽石:BAAALAADCgEIAQAAAA==.',['爬墙']='爬墙和尚:BAAALAAECgYIBgAAAA==.',['爱我']='爱我还是他:BAAALAAFFAIIAgABLAAFFAgIBwANAMoWAA==.',['牛肉']='牛肉面不要面:BAAALAAECgQIBAAAAA==.',['牛蹄']='牛蹄战歌:BAAALAAFFAEIAQAAAA==.',['狂暴']='狂暴:BAAALAADCgMIAwAAAA==.',['狂野']='狂野之心:BAAALAAECgQIBAAAAA==.',['猫小']='猫小:BAAALAAFFAYIAgAAAA==.',['王权']='王权没有永恒:BAAALAADCgYIBgAAAA==.',['玛惟']='玛惟影之歌:BAAALAAECgYIBgAAAA==.',['玛格']='玛格罗斯:BAABLAAECn8lAAIOAAcIFRzyKwCuAQAOAAcIFRzyKwCuAQAAAA==.',['玫瑰']='玫瑰与情人:BAAALAADCggICAAAAA==.',['玲珑']='玲珑皓月:BAAALAAECgIIAwAAAA==.玲珑红月:BAAALAAECgUIBQAAAA==.',['班普']='班普雷奥斯:BAAALAAECgYIEAAAAA==.',['理性']='理性论马:BAABLAAFFH8GAAICAAYIBBBqEgBmAQACAAYIBBBqEgBmAQAAAA==.',['璀璨']='璀璨人生:BAAALAAECgIIAgAAAA==.',['甜灵']='甜灵:BAAALAAECgYIBgAAAA==.',['田中']='田中理惠:BAAALAAECgYIDAAAAA==.',['电叉']='电叉:BAABLAAFFH8GAAICAAIIMAX2KwBeAAACAAIIMAX2KwBeAAAAAA==.',['番小']='番小茄:BAAALAAECgMIAwAAAA==.',['疏影']='疏影:BAAALAAFFAIIAgAAAA==.',['疯狂']='疯狂的瓶子:BAAALAAECgYIBgAAAA==.',['痴情']='痴情丶少年:BAAALAAFFAIIAgAAAA==.',['瘾大']='瘾大技术差:BAAALAAECgYIBgAAAA==.',['白浅']='白浅浅:BAABLAAFFH8LAAIJAAIIPgqDQwBlAAAJAAIIPgqDQwBlAAAAAA==.',['白虹']='白虹贯日:BAAALAAECgIIAgAAAA==.',['白闪']='白闪闪:BAABLAAFFH8LAAIHAAII6hHIVQBnAAAHAAII6hHIVQBnAAAAAA==.',['百盛']='百盛堂十九号:BAAALAAECgYIBgAAAA==.',['皮皮']='皮皮:BAABLAAFFH8KAAIBAAMI4xrRPQCeAAABAAMI4xrRPQCeAAAAAA==.',['盐烧']='盐烧柠檬:BAAALAAFFAIIBAAAAA==.',['看我']='看我变个狼:BAAALAAFFAIIAgAAAA==.',['看相']='看相摸骨:BAAALAAECgYIBgAAAA==.',['真炎']='真炎幸魂:BAAALAAFFAIIAgAAAA==.',['眼罩']='眼罩:BAAALAAFFAIIBAAAAA==.',['矮挫']='矮挫丑:BAABLAAFFH8mAAILAAYIDhcvIgCVAQALAAYIDhcvIgCVAQAAAA==.',['硕大']='硕大的胸肌:BAACLAAFFH8HAAMcAAIIuSIKEwCNAAAcAAII/xEKEwCNAAAGAAIIuSI4bABkAAAsAAQKfx4AAwYACAjQIBM8AIwCAAYACAgtHBM8AIwCABwACAjSHV4QAFMCAAAA.',['碎冰']='碎冰:BAAALAADCgIIAgAAAA==.',['神勇']='神勇小桂子:BAAALAADCgYIBgAAAA==.',['神撩']='神撩木木:BAAALAAECgYICgAAAA==.',['神秘']='神秘王子:BAAALAAECggICAAAAA==.',['秦王']='秦王绕柱:BAAALAADCgEIAQAAAA==.',['秦龙']='秦龙爱:BAAALAAFFAIIAgAAAA==.',['窈窕']='窈窕舞媚:BAAALAAECgYIDAAAAA==.',['窝馕']='窝馕废:BAAALAAECgYICQAAAA==.',['第二']='第二刀半价:BAAALAAECgcIEQAAAA==.',['筽篁']='筽篁:BAABLAAFFH8IAAIKAAIIWw3WoAA+AAAKAAIIWw3WoAA+AAAAAA==.',['糖丸']='糖丸:BAAALAAFFAIIBAAAAA==.',['糖糖']='糖糖小恶魔:BAABLAAFFH8MAAIMAAIItx1wCgCvAAAMAAIItx1wCgCvAAAAAA==.',['索拉']='索拉莉娜:BAABLAAFFH8FAAIOAAMIwQlIPACCAAAOAAMIwQlIPACCAAAAAA==.',['紫川']='紫川:BAAALAAECgcIBwAAAA==.',['紫毛']='紫毛蛋儿:BAAALAADCgQIBAAAAA==.',['繁星']='繁星不如你:BAAALAAFFAIIBAAAAA==.',['红毛']='红毛蛋儿:BAABLAAFFH8RAAIGAAMIFx/7PAC4AAAGAAMIFx/7PAC4AAAAAA==.',['纯爱']='纯爱在西元前:BAAALAAFFAIIAgAAAA==.',['纽维']='纽维:BAAALAAFFAIIAgAAAA==.',['缇娜']='缇娜丶黛安娜:BAACLAAFFH8hAAIBAAYI/BeUGACSAQABAAYI/BeUGACSAQAsAAQKfx8AAgEABwgGIJo1AJ0CAAEABwgGIJo1AJ0CAAAA.',['缺不']='缺不了一点:BAABLAAFFH8GAAMEAAMIPR3WJAD2AAAEAAMIPR3WJAD2AAADAAEIHhF6MgA/AAAAAA==.',['罗伊']='罗伊拜恩:BAAALAAFFAIIAgAAAA==.',['罪恶']='罪恶德德:BAAALAAFFAMIAwAAAA==.罪恶死骑:BAACLAAFFH8MAAMGAAMIOQpeZwB8AAAGAAMI4QheZwB8AAAcAAIIvAvFEwBIAAAsAAQKfxYAAgYABgjvFqJUAEsBAAYABgjvFqJUAEsBAAAA.',['羊肉']='羊肉犄角:BAAALAAECgIIAgAAAA==.',['翎羽']='翎羽:BAAALAAECgUIBQAAAA==.',['老哥']='老哥我贼稳:BAAALAAECgYIDwAAAA==.',['老虎']='老虎菜:BAAALAAECgYICgAAAA==.',['联盟']='联盟指挥官:BAAALAAECgYIBgAAAA==.',['肥仔']='肥仔乐:BAAALAAECgcICAAAAA==.',['胖叔']='胖叔叔:BAAALAAFFAIIAgAAAA==.',['花果']='花果山小丑:BAAALAAECgYIBgAAAA==.花果山顶流:BAABLAAFFH8IAAIHAAIIVBuhQwB7AAAHAAIIVBuhQwB7AAAAAA==.',['若水']='若水依依:BAAALAADCgIIAgAAAA==.若水依冰:BAAALAADCgMIAwAAAA==.若水依梦:BAAALAADCgMIAwAAAA==.若水依溪:BAAALAAFFAIIBAAAAA==.',['若语']='若语思念:BAAALAAECgUICQAAAA==.',['英杰']='英杰丶战灵:BAAALAAECgYIBgAAAA==.',['莉亚']='莉亚德琳:BAABLAAFFH8KAAMCAAIIIwPiLABXAAACAAIIIwPiLABXAAABAAIIugKngQAsAAABLAAFFAUIGgAQAHISAA==.',['莉娜']='莉娜因巴斯:BAAALAAECgMIAwAAAA==.',['莉莉']='莉莉薇:BAAALAAECgEIAQAAAA==.',['莎尤']='莎尤娜菈:BAAALAAFFAIIAgAAAA==.',['菜刀']='菜刀砍电线丶:BAAALAADCggICAAAAA==.',['萨克']='萨克朵:BAAALAAECgYIBgAAAA==.',['萨曼']='萨曼岚琪:BAAALAAECgIIAgAAAA==.',['萨诺']='萨诺斯:BAABLAAFFH8GAAIHAAIIewiuXQBiAAAHAAIIewiuXQBiAAAAAA==.',['萨麦']='萨麦尔:BAAALAAECgEIAQAAAA==.',['葡式']='葡式蛋挞:BAAALAAECgQIBQAAAA==.',['蒙奇']='蒙奇德路飞:BAAALAAECggICAAAAA==.',['蒼绿']='蒼绿:BAACLAAFFH8WAAMdAAQIpQlWDwDSAAAdAAQIpQlWDwDSAAAeAAMIlAp3EACRAAAsAAQKfzIAAh0ACAiTGlIHAGECAB0ACAiTGlIHAGECAAAA.',['蓝调']='蓝调悠扬:BAAALAAECgYIBgAAAA==.',['薄荷']='薄荷红茶灬:BAAALAADCgYIBgAAAA==.',['薛迪']='薛迪凯:BAAALAAECggICAAAAA==.',['虎哥']='虎哥:BAAALAADCgYIBgAAAA==.',['虚无']='虚无玅:BAAALAAECgYIBgAAAA==.',['蛋黄']='蛋黄:BAAALAAECggICAAAAA==.',['蛤蟆']='蛤蟆:BAAALAADCgIIAgAAAA==.',['血武']='血武魂:BAAALAAECgYIDAAAAA==.',['血色']='血色羽毛:BAAALAAECgYIEwAAAA==.',['行癫']='行癫:BAAALAADCgEIAQAAAA==.',['行香']='行香子:BAAALAADCgEIAQAAAA==.',['袖白']='袖白雪:BAAALAAECgYIDAAAAA==.',['被圣']='被圣光抛弃:BAAALAAECgEIAQAAAA==.',['裘德']='裘德洛:BAAALAADCgYIBgAAAA==.',['西北']='西北望:BAABLAAFFH8UAAMbAAUImSTMDQAQAQAbAAQIPB7MDQAQAQAKAAMIDCPJKADaAAAAAA==.',['话饭']='话饭军:BAAALAADCgQIBAAAAA==.',['谜团']='谜团:BAAALAAFFAIIAgAAAA==.',['谜圗']='谜圗灬曉術:BAACLAAFFH8uAAMLAAcIXyEhDgAoAgALAAcIXyEhDgAoAgAYAAIIEh3/DwCkAAAsAAQKfysABAsABwiJJPQdANgCAAsABwjsI/QdANgCABgABQjEJDEoANUBAB8AAQgmIqY1AFsAAAAA.',['豚豚']='豚豚:BAAALAAECgIIAgAAAA==.',['贱无']='贱无虚发:BAAALAAECgcICQAAAA==.',['赵大']='赵大胖:BAAALAADCgIIAgAAAA==.',['跃夜']='跃夜晓德:BAAALAAECgYICgAAAA==.',['软糯']='软糯灬吱吱兔:BAABLAAFFH8GAAILAAIIeQXCUAB/AAALAAIIeQXCUAB/AAAAAA==.',['迎接']='迎接你们的王:BAAALAAFFAIIAwAAAA==.',['还我']='还我点卡:BAAALAADCgYIBgAAAA==.',['迟眠']='迟眠:BAABLAAFFH8GAAIXAAIIXxwZFABWAAAXAAIIXxwZFABWAAAAAA==.',['追随']='追随太阳:BAAALAAECgQIBAAAAA==.',['选修']='选修:BAAALAAECgYICQAAAA==.',['透明']='透明蓝:BAAALAAECgUIBQAAAA==.',['逐日']='逐日圣光:BAAALAAECgYIBwAAAA==.逐日木子:BAACLAAFFH8PAAIJAAIIGRvdMwCaAAAJAAIIGRvdMwCaAAAsAAQKfx0AAgkACAhaFKZAANUBAAkACAhaFKZAANUBAAAA.',['遗憾']='遗憾无法说:BAAALAAECgEIAQAAAA==.',['遙不']='遙不可及丶夢:BAABLAAFFH8KAAMEAAIIfRaXLgB4AAAEAAIIfRaXLgB4AAADAAIIogk9NwA4AAAAAA==.',['那个']='那个奶萨:BAAALAAECgMIAwAAAA==.',['邪恶']='邪恶大波浪:BAABLAAFFH8GAAMLAAIIxgmyagA2AAAYAAEI9QrCLQBIAAALAAII6AeyagA2AAAAAA==.',['醉红']='醉红妆:BAABLAAFFH8JAAMYAAIIXRGGEwBFAAAYAAIIXRGGEwBFAAALAAEI3QpeYgA9AAAAAA==.',['重新']='重新开始:BAABLAAFFH8IAAIBAAYILhCmIQBhAQABAAYILhCmIQBhAQAAAA==.',['钊帝']='钊帝大领主:BAAALAAECgEIAQAAAA==.钊帝小德:BAAALAAECgcIDQAAAA==.钊帝萨满:BAAALAAFFAIIAgAAAA==.',['银影']='银影:BAAALAADCgYIBgAAAA==.银影天仇:BAAALAAECgYIBgAAAA==.',['长的']='长的吓人:BAAALAAECgMIAwAAAA==.',['问北']='问北:BAAALAAFFAQIBAAAAA==.',['阿塔']='阿塔咪:BAAALAADCgYIDAAAAA==.',['阿波']='阿波斯雅:BAAALAAECgQIBAAAAA==.',['陌上']='陌上人如玉:BAAALAAECgYICQAAAA==.',['隔壁']='隔壁老樊:BAABLAAFFH8IAAIHAAIISBQjUgBqAAAHAAIISBQjUgBqAAAAAA==.',['雨霖']='雨霖铃:BAAALAAFFAIIAgAAAA==.',['雪代']='雪代巴:BAAALAAFFAIIAwAAAA==.',['霜织']='霜织哀伤:BAAALAAECgQIBgAAAA==.',['露露']='露露的驴驴:BAAALAADCgYIBgAAAA==.',['青云']='青云子:BAABLAAFFH8FAAIeAAIIewj2GQA3AAAeAAIIewj2GQA3AAAAAA==.',['非常']='非常无聊:BAAALAADCgcIBwAAAA==.',['面壁']='面壁者章北海:BAAALAADCgEIAQAAAA==.',['風雲']='風雲破晓:BAAALAAECggICAAAAA==.',['风之']='风之大海:BAACLAAFFH8IAAIEAAIIigviSgBcAAAEAAIIigviSgBcAAAsAAQKfyoAAgQABwgfGN0qAI0BAAQABwgfGN0qAI0BAAAA.风之火焰:BAABLAAFFH8IAAIKAAIIYxgoZgCHAAAKAAIIYxgoZgCHAAAAAA==.',['风兮']='风兮破军:BAAALAAECgYIBgAAAA==.',['风烟']='风烟俱净:BAAALAAECgYIBgAAAA==.',['风聆']='风聆夜:BAABLAAFFH8KAAIVAAIIEg9tVwBEAAAVAAIIEg9tVwBEAAAAAA==.',['马兰']='马兰开花卅七:BAAALAAECgUIBQAAAA==.',['马化']='马化腾还活着:BAAALAADCgEIAQAAAA==.',['高数']='高数满分:BAAALAAECggIEAAAAA==.',['魂淡']='魂淡风轻:BAAALAAECgYIBgAAAA==.',['魔布']='魔布利斤:BAAALAAECgYIBgAAAA==.',['魔网']='魔网:BAAALAAECgcIDQAAAA==.',['魔羯']='魔羯座:BAAALAADCgYIAwAAAA==.',['鲲乐']='鲲乐信仰圣光:BAAALAAECgYICQAAAA==.鲲乐战很红:BAABLAAFFH8OAAIOAAYITSH8CwD9AQAOAAYITSH8CwD9AQAAAA==.鲲乐的红手猎:BAABLAAFFH8mAAIKAAYI3B6UHgC6AQAKAAYI3B6UHgC6AQAAAA==.鲲乐红手武僧:BAAALAAFFAIIBAAAAA==.',['鹰眼']='鹰眼儿毛蛋儿:BAABLAAFFH8PAAIKAAMIfSa4OwCtAAAKAAMIfSa4OwCtAAAAAA==.',['黑天']='黑天际线:BAAALAAECgYIBgAAAA==.',['黑手']='黑手老牛牛:BAAALAAECgYIDAAAAA==.',['黑玫']='黑玫瑰:BAAALAAECgYIDAAAAA==.',['黑石']='黑石:BAAALAAFFAIIAgAAAA==.',['黑虎']='黑虎:BAAALAAECgEIAQAAAA==.',['黑锋']='黑锋重剑:BAABLAAFFH8VAAIGAAUIYxsuNwBhAQAGAAUIYxsuNwBhAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end