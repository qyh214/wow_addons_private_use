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
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Unknown-Unknown','Priest-Discipline','Priest-Holy','Priest-Shadow','DemonHunter-Devourer','DemonHunter-Vengeance','Rogue-Subtlety','Rogue-Assassination','DeathKnight-Blood','DeathKnight-Unholy','Mage-Frost','Paladin-Retribution','Paladin-Holy','Shaman-Restoration','Monk-Windwalker','Warlock-Demonology','Hunter-BeastMastery','Hunter-Survival','Hunter-Marksmanship','Warrior-Fury','Warrior-Protection','Monk-Brewmaster',}
local provider = {region='CN',realm='达纳斯',name='CN',type='weekly',zone=46,date='2026-04-25',data={Al='Allisom:BAAALgAECgQJBAAAAA==.',
Fo='Foxdie:BAAALgAECgMJBAAAAA==.',
He='Hebby:BAAALgADCgQJBAAAAA==.',
Hy='Hyrd:BAAALgAECgIJBQABLgAECgcJDAABAAAAAA==.Hyrum:BAAALgAECgUJCAAAAA==.Hyson:BAAALgAECgcJDAAAAA==.',
Il='Illida:BAAALgADCgcJCQAAAA==.',
Is='Isolation:BAAALgAECgQJBAAAAA==.',
Ji='Jinsir:BAAALgADCgYJBwAAAA==.',
Ju='Juliy:BAAALgAECgUJBgAAAA==.',
Ma='Maus:BAACLgAFFH8TAAQCAAUJXBAoBgCAAQACAAUJtQooBgCAAQADAAIJEhslDACgAAAEAAIJ0gFTEgB9AAAuAAQKfyAABAIACAnCFVUZAM8BAAIABglvGFUZAM8BAAQABglVGwsmAKcBAAMABwm7CdA7AEsBAAAA.',
My='Mystery:BAAALgAECgUJBgAAAA==.',
Pr='Precepts:BAAALgAECgQJBQAAAA==.',
Ra='Raysofli:BAAALgAECgIJAgAAAA==.',
Sh='Sheldoon:BAAALgAECgEJAQAAAA==.',
St='Stelo:BAAALgADCgUJBgAAAA==.',
Su='Sunswan:BAAALgAECgYJCQAAAA==.',
Sy='Syou:BAACLgAFFH8HAAIFAAMJ8w9VEgDlAAAFAAMJ8w9VEgDlAAAuAAQKfxgAAgUABwmZH0g/APcBAAUABwmZH0g/APcBAAAA.',
Wi='Wireshark:BAAALgAFFAIJAwABLgAFFAMJCAAGAAYUAA==.',
['一吻']='一吻天荒:BAAALgAECgYJCwAAAA==.',
['一雪']='一雪团团一:BAAALgAFFAEJAwABLgAFFAUJEQAEAIwhAA==.',
['丁自']='丁自酷:BAAALgAECgcJDgAAAA==.',
['七夜']='七夜圣光:BAAALgADCgEJAQAAAA==.',
['三秒']='三秒鑫:BAACLgAFFH8KAAMHAAQJgBATCgBQAQAHAAQJgBATCgBQAQAIAAEJIAlSBgBbAAAuAAQKfxgAAwcACAk+HpATAHsCAAcACAk+HpATAHsCAAgABAkdFcgQAAABAAAA.',
['丨十']='丨十:BAAALgAECgEJAQAAAA==.',
['丶痛']='丶痛哭流涕:BAAALgAECgYJCQAAAA==.',
['丷夜']='丷夜火琉萤丷:BAAALgAECgcJEQABLgAFFAIJAwABAAAAAA==.',
['丷葭']='丷葭衤:BAAALgAECgEJAQAAAA==.',
['九遥']='九遥:BAAALgAECgkJCQAAAA==.',
['亚亚']='亚亚守护神:BAAALgAECgUJCQAAAA==.',
['人淡']='人淡如菊:BAAALgAECgEJAQAAAA==.',
['代价']='代价为大铲车:BAAALgADCgEJAQAAAA==.',
['任断']='任断离:BAAALgAECgYJBgAAAA==.',
['伊诺']='伊诺山度:BAAALgADCggJCAAAAA==.',
['传说']='传说中的少女:BAAALgAECgMJBAAAAA==.',
['光的']='光的阴影:BAAALgAECgYJEwAAAA==.',
['兮夜']='兮夜老师:BAAALgAECgcJBwAAAA==.',
['兮郦']='兮郦:BAAALgAECgIJAwAAAA==.',
['兮黎']='兮黎:BAAALgAFFAEJAQAAAA==.',
['兰心']='兰心蕙性:BAAALgAECgMJAwAAAA==.',
['典當']='典當靈魂:BAAALgADCgEJAQAAAA==.',
['冰块']='冰块丶:BAAALgAECgEJAQAAAA==.',
['净化']='净化心灵:BAAALgAECgEJAQAAAA==.',
['凉拌']='凉拌丶米豆腐:BAAALgAFFAEJAgAAAA==.凉拌丶香椿:BAAALgAECgIJAgAAAA==.',
['刑天']='刑天:BAAALgAECgEJAQAAAA==.',
['初夏']='初夏醉蓝:BAAALgAECgcJBwAAAA==.',
['十三']='十三猎幺:BAAALgADCgQJBAAAAA==.',
['卓尔']='卓尔狂箭:BAAALgAECgIJAwAAAA==.',
['卡特']='卡特尼娜:BAAALgAECgMJAwAAAA==.',
['印灰']='印灰:BAAALgADCgEJAQAAAA==.',
['只想']='只想抓宝宝:BAAALgAECgEJAQAAAA==.只想用头撞墙:BAABLgAECn8XAAMJAAcJqRrPFwCdAQAJAAYJURvPFwCdAQAKAAcJNQ2AjQBmAQABLgAECgUJBQABAAAAAA==.',
['可愛']='可愛哆:BAABLgAECn8fAAILAAkJuxzlHAACAwALAAkJuxzlHAACAwAAAA==.',
['吉尓']='吉尓伽美什:BAAALgAECgQJBQAAAA==.',
['吮指']='吮指原味鸡:BAAALgAECgUJCgAAAA==.',
['呆呆']='呆呆的阿昆达:BAAALgADCgEJAQAAAA==.',
['和道']='和道一文字:BAAALgAECgEJAQAAAA==.',
['咕噜']='咕噜咕噜噜:BAAALgAECgQJBAAAAA==.',
['哈基']='哈基龙:BAAALgAECgcJBwAAAA==.',
['哈士']='哈士骑:BAABLgAECn8WAAMMAAcJwR4NOABDAgAMAAcJwR4NOABDAgANAAcJpAxMRgBfAQAAAA==.',
['哈尔']='哈尔滨啤酒:BAAALgADCgEJAQAAAA==.',
['唤潮']='唤潮:BAAALgAECgQJBQAAAA==.',
['喵小']='喵小兔:BAAALgAECgMJAwAAAA==.',
['嘟嘟']='嘟嘟叔叔:BAAALgAECgEJAQAAAA==.',
['團妹']='團妹:BAAALgAFFAIJBAAAAA==.',
['圣光']='圣光大叔:BAAALgAECgIJAgAAAA==.圣光小宝宝:BAAALgAECgEJAQAAAA==.圣光热不死你:BAAALgAECgMJAwAAAA==.圣光蛋:BAAALgAECgQJBQAAAA==.',
['地皮']='地皮爱死信仰:BAAALgADCgEJAQAAAA==.',
['塞巴']='塞巴斯蒂安丶:BAAALgAECggJCAABLgAFFAgJAgABAAAAAA==.',
['壹米']='壹米陽光:BAAALgAECgEJAQAAAA==.',
['夜天']='夜天之书:BAAALgAECgcJDQAAAA==.',
['夢幻']='夢幻丶薄桜:BAAALgAECgYJCgABLgAFFAMJBwAFAPMPAA==.',
['大只']='大只青头籽:BAAALgAECgQJBgAAAA==.',
['天使']='天使陨落:BAAALgAECgYJEwAAAA==.',
['失业']='失业的江南:BAAALgAECgUJBgAAAA==.',
['头号']='头号罪犯丶:BAAALgAECgEJAQAAAA==.',
['奇迹']='奇迹渔:BAAALgAECgEJAQAAAA==.',
['如月']='如月之亘:BAAALgADCgEJAQAAAA==.',
['子衿']='子衿灬:BAAALgAECgUJBQAAAA==.',
['孤独']='孤独之猎:BAAALgAECgEJAQAAAA==.',
['安静']='安静的猫爪子:BAAALgAECgEJAQAAAA==.',
['寒鸦']='寒鸦少年:BAAALgADCgEJAQAAAA==.',
['寶貝']='寶貝尐棍棍:BAAALgAECgQJBQAAAA==.寶貝尐騎士:BAAALgAECgUJCQAAAA==.寶貝熊:BAAALgAECgYJDQAAAA==.',
['小小']='小小薰衣草:BAAALgAECgYJDAAAAA==.',
['小巧']='小巧卝朦胧:BAABLgAFFH8FAAMDAAMJtAveCwClAAADAAMJtAveCwClAAACAAEJXQDGHAAwAAAAAA==.',
['小李']='小李逵:BAAALgAECgkJCQABLgAFFAUJBAABAAAAAA==.',
['小蜜']='小蜜蜂:BAAALgAECgUJBQAAAA==.',
['小衫']='小衫:BAABLgAECn8YAAIMAAYJth6EWQDWAQAMAAYJth6EWQDWAQAAAA==.',
['尤菲']='尤菲米娅:BAAALgAECgYJEgAAAA==.',
['尤迪']='尤迪:BAAALgAECgMJAwAAAA==.',
['左右']='左右开弓:BAABLgAFFH8HAAIOAAMJFBtjCAD3AAAOAAMJFBtjCAD3AAAAAA==.',
['店长']='店长推薦:BAAALgAECgIJAgAAAA==.',
['强妹']='强妹:BAAALgAFFAIJAgAAAA==.',
['彩虹']='彩虹之翼:BAAALgAECgYJCwAAAA==.',
['影风']='影风泪:BAAALgAECgQJBQAAAA==.',
['彼岸']='彼岸的风铃:BAAALgAECgcJCgAAAA==.',
['德尼']='德尼骑:BAAALgAECgEJAQAAAA==.',
['德庄']='德庄大火锅:BAAALgAFFAIJAgAAAA==.',
['心语']='心语:BAAALgAFFAIJAwABLgAECgcJFQAPAB0PAA==.',
['忘了']='忘了什么:BAAALgAECgYJCwAAAA==.',
['快乐']='快乐鹰:BAAALgADCgIJAgAAAA==.',
['恐惧']='恐惧的真谛:BAAALgAECgcJBwAAAA==.',
['恩歌']='恩歌拉夏:BAAALgAECgIJAgAAAA==.',
['愛之']='愛之坠:BAAALgAECgYJDQAAAA==.',
['愛恨']='愛恨情愁:BAAALgAECgYJBgAAAA==.',
['我叫']='我叫生性:BAABLgAFFH8FAAIQAAIJvAnEJQCNAAAQAAIJvAnEJQCNAAAAAA==.',
['我想']='我想抓个小德:BAAALgAECgkJCQAAAA==.',
['我是']='我是天上无敌:BAAALgAECgcJDAAAAA==.',
['打打']='打打咑劫:BAAALgADCgIJAgAAAA==.',
['折镜']='折镜丶:BAAALgAECgQJBQAAAA==.',
['摩拉']='摩拉克斯:BAAALgADCgEJAQAAAA==.',
['无悔']='无悔之意:BAAALgAECgYJBgAAAA==.',
['无量']='无量:BAAALgAFFAIJBAAAAA==.',
['时七']='时七丶:BAAALgADCgEJAQAAAA==.',
['星落']='星落:BAAALgAECgYJBgAAAA==.',
['星骸']='星骸猎手:BAAALgAECgUJBQAAAA==.',
['晨曦']='晨曦月影:BAAALgADCgcJCAAAAA==.',
['暗影']='暗影之熄:BAAALgAECggJCQAAAA==.',
['暮筱']='暮筱:BAABLgAFFH8HAAICAAQJoBDcCQBBAQACAAQJoBDcCQBBAQAAAA==.',
['暮雪']='暮雪微雨:BAAALgAECgEJAQAAAA==.',
['暴走']='暴走一戟灞:BAAALgAECgEJAgAAAA==.',
['月下']='月下:BAABLgAECn8XAAQRAAgJ4xheOQDJAQARAAcJGRheOQDJAQASAAUJShA+HAASAQATAAEJAwhrjgAsAAAAAA==.',
['月影']='月影突袭:BAAALgAECgEJAQAAAA==.',
['月神']='月神:BAAALgAFFAMJAwAAAA==.',
['术手']='术手巫策:BAAALgAFFAIJAgAAAA==.',
['杀务']='杀务尽:BAAALgADCgIJAwAAAA==.',
['李娜']='李娜莉:BAAALgAFFAMJBAAAAA==.',
['柜子']='柜子里的美丽:BAAALgAECgQJBAAAAA==.',
['桃之']='桃之幺幺:BAAALgAECgYJDAAAAA==.',
['椰椰']='椰椰酥:BAAALgAECgQJBAAAAA==.',
['武极']='武极:BAAALgAECgEJAgAAAA==.',
['毛纟']='毛纟线:BAAALgADCgEJAQAAAA==.',
['江浸']='江浸月丶:BAAALgAECgYJDAAAAA==.',
['沙布']='沙布兰尼古:BAAALgAECgUJBQABLgAFFAMJCAAGAAYUAA==.',
['沙漠']='沙漠之狐:BAAALgADCgcJBwAAAA==.',
['没事']='没事:BAAALgADCgYJBgAAAA==.',
['沧海']='沧海:BAAALgADCgMJAwAAAA==.',
['沧渊']='沧渊凌霜:BAAALgAECgUJBQAAAA==.',
['波涛']='波涛呀:BAAALgAECgQJBQAAAA==.',
['洋葱']='洋葱头的夏天:BAAALgAECgYJBQAAAA==.',
['派大']='派大星的智慧:BAAALgAECgYJEQAAAA==.',
['流光']='流光剑:BAAALgAECgEJAQAAAA==.',
['浮生']='浮生半日:BAAALgAECgUJBQAAAA==.',
['清梦']='清梦卧星河:BAAALgAECgIJAgAAAA==.',
['瀍壑']='瀍壑朱樱:BAAALgAECgMJBAAAAA==.',
['灰太']='灰太狼大官人:BAAALgAECgUJBwAAAA==.',
['灵魂']='灵魂料滋:BAAALgAECgQJBAAAAA==.灵魂无畏:BAAALgAFFAIJAwAAAA==.',
['独品']='独品:BAAALgAECgQJCQAAAA==.',
['王魂']='王魂骑士:BAAALgADCgEJAQAAAA==.',
['琉璃']='琉璃梦羡:BAAALgAFFAIJAwAAAA==.',
['瓦里']='瓦里安:BAAALgAFFAMJAwAAAA==.',
['田渊']='田渊正浩:BAAALgAECgMJAwAAAA==.',
['白色']='白色闪电:BAAALgAECgQJBgAAAA==.',
['百撕']='百撕卜得骑姐:BAAALgAECgcJDwAAAA==.',
['皓雪']='皓雪殇:BAAALgAECgkJCQAAAA==.',
['皮皮']='皮皮浪:BAAALgAECgEJAQAAAA==.',
['盗猎']='盗猎者卡卡西:BAAALgAECgcJCwAAAA==.',
['盼盼']='盼盼:BAABLgAECn8ZAAMUAAcJzhdyLgD4AQAUAAcJzhdyLgD4AQAVAAMJSwawOQB9AAAAAA==.',
['短尾']='短尾猫不吃鱼:BAAALgAECgYJBwAAAA==.',
['硝酸']='硝酸甘油:BAAALgAECgYJBQAAAA==.',
['神秘']='神秘壹号演员:BAAALgAECgQJBAAAAA==.',
['空空']='空空没那么难:BAAALgAECgYJCAAAAA==.',
['紛飛']='紛飛索愛:BAAALgADCgcJBwAAAA==.',
['索尼']='索尼:BAAALgAECgYJBgAAAA==.',
['红葉']='红葉舞:BAAALgAECgEJAQAAAA==.',
['给你']='给你一片天:BAAALgAECgYJBwAAAA==.',
['绯月']='绯月无双:BAAALgADCgEJAQAAAA==.',
['绯红']='绯红:BAAALgAECgQJBAAAAA==.',
['维卡']='维卡娅:BAAALgAECgIJAgAAAA==.',
['翻转']='翻转再来壹發:BAAALgADCgEJAgAAAA==.',
['耳朵']='耳朵不能摸:BAAALgADCgIJAgAAAA==.',
['胖哥']='胖哥哥大宗师:BAAALgAECgcJBwABLgAFFAQJCAAFAJMQAA==.',
['脑袋']='脑袋沙拉:BAAALgAECgQJBAAAAA==.',
['腾牛']='腾牛霸剑:BAAALgAECgIJAgAAAA==.',
['自信']='自信二狗哥:BAABLgAECn8WAAIUAAgJ8RoaHQBlAgAUAAgJ8RoaHQBlAgAAAA==.',
['艾欧']='艾欧逻斯:BAAALgAECgQJBAAAAA==.',
['艾琳']='艾琳柯娜:BAAALgADCgEJAQAAAA==.',
['范塔']='范塔斯笛:BAAALgAECgcJDQAAAA==.',
['荧焰']='荧焰丶:BAAALgADCgEJAQAAAA==.',
['莉娜']='莉娜因巴斯:BAAALgAECgUJCgAAAA==.',
['莫贺']='莫贺延碛:BAAALgADCgEJAQAAAA==.',
['菲林']='菲林斯:BAAALgAECgEJAQAAAA==.',
['萌萌']='萌萌的幻月蓝:BAABLgAECn8aAAMNAAkJ5x6KAAAfAwANAAkJ5x6KAAAfAwAMAAUJSCGTVwDcAQABLgAFFAIJAgABAAAAAA==.',
['萨拉']='萨拉塔澌:BAAALgAECgEJAgAAAA==.',
['萨萨']='萨萨情人:BAAALgAECgEJAQAAAA==.',
['落花']='落花爱上流水:BAAALgAECgkJCwAAAA==.',
['葡萄']='葡萄有多甜:BAAALgAFFAEJAQAAAA==.',
['蒂德']='蒂德莉特:BAAALgADCgEJAQAAAA==.',
['蓝莓']='蓝莓有多甜:BAAALgAECgEJAQAAAA==.',
['蕾米']='蕾米欧娜:BAAALgAECgIJAgAAAA==.',
['蛮三']='蛮三刀:BAACLgAFFH8JAAIKAAMJ+BjYFQDqAAAKAAMJ+BjYFQDqAAAuAAQKfyMAAgoACQmYGD8gAMACAAoACQmYGD8gAMACAAAA.',
['蜡筆']='蜡筆小薪:BAAALgAECgcJDQAAAA==.',
['蠢蠢']='蠢蠢欲动:BAAALgAECgEJAgAAAA==.',
['血色']='血色尘风:BAAALgAECgEJAQAAAA==.',
['西巴']='西巴尔:BAAALgAECgYJDQAAAA==.',
['西里']='西里犀利:BAAALgAFFAEJAwAAAA==.',
['言不']='言不清:BAAALgAECgUJBQAAAA==.',
['让我']='让我想想:BAAALgAECgYJEgABLgAFFAUJEwACAFwQAA==.',
['贞德']='贞德:BAAALgAECgIJAgAAAA==.',
['赛莉']='赛莉卡:BAAALgAFFAMJBAAAAA==.',
['起个']='起个好名字:BAAALgAECgEJAQAAAA==.',
['还用']='还用吴京倒模:BAAALgAECgEJAQAAAA==.',
['迦楼']='迦楼罗:BAAALgAECgUJAgAAAA==.',
['迪奥']='迪奥:BAAALgAECgIJAgAAAA==.',
['逆游']='逆游的鱼:BAAALgAECgYJCgAAAA==.',
['逝去']='逝去的灵魂:BAAALgAECgQJBwAAAA==.',
['邦贝']='邦贝儿:BAAALgADCgYJBgAAAA==.',
['量变']='量变临界点:BAAALgAECgMJAwAAAA==.',
['长崎']='长崎素世:BAAALgADCgcJDQAAAA==.',
['阿塔']='阿塔兰忒:BAAALgAECgcJCQAAAA==.',
['阿比']='阿比斯深渊:BAAALgAECgQJBAAAAA==.',
['雄狮']='雄狮水晶:BAAALgAECgEJAQAAAA==.',
['雅兰']='雅兰:BAAALgAECgYJDwAAAA==.',
['雲和']='雲和山的彼端:BAAALgAECgcJDQAAAA==.',
['露露']='露露的女王:BAAALgAECgUJBgAAAA==.',
['霸者']='霸者小宝宝:BAAALgAECgEJAQAAAA==.',
['靑児']='靑児:BAAALgAECgYJBgAAAA==.',
['青枫']='青枫:BAAALgAECgcJEAAAAA==.',
['靓飘']='靓飘飘:BAAALgADCgIJAgAAAA==.',
['非常']='非常无姜君:BAAALgADCgEJAQAAAA==.',
['顺势']='顺势:BAAALgAFFAMJBAAAAA==.',
['顺水']='顺水:BAAALgAFFAIJAwAAAA==.',
['飞天']='飞天小狐狸:BAABLgAECn8VAAMPAAcJHQ8yLQB4AQAPAAcJHQ8yLQB4AQAWAAMJ1AZ7bgCIAAAAAA==.',
['香草']='香草桃桃冰:BAAALgAFFAEJAQAAAA==.',
['马保']='马保国:BAAALgAECgMJAwAAAA==.',
['魂之']='魂之舞:BAAALgAECgYJCAAAAA==.',
['魔里']='魔里狱卒:BAAALgADCgEJAQAAAA==.',
['鸭梨']='鸭梨吗斯:BAAALgAECgYJEAABLgAFFAUJEwACAFwQAA==.',
['麋鹿']='麋鹿也迷路:BAAALgAFFAQJAwAAAA==.',
['黄色']='黄色的西瓜:BAAALgAECgIJAgAAAA==.',
['黑色']='黑色的西瓜:BAAALgAECgYJDgABLgAFFAYJBQAKAEokAA==.',
['龍剣']='龍剣飛:BAAALgAECgQJBAAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
