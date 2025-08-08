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
 local lookup = {'Warrior-Arms','Warlock-Destruction','Paladin-Retribution','Paladin-Holy','Warrior-Fury','Hunter-BeastMastery','DeathKnight-Unholy','DemonHunter-Vengeance','Priest-Shadow','Mage-Arcane','Hunter-Marksmanship','DeathKnight-Blood','Shaman-Enhancement','Mage-Frost','Druid-Restoration','Mage-Fire','Unknown-Unknown','Shaman-Restoration','Priest-Holy','Paladin-Protection','Shaman-Elemental','Priest-Discipline','DemonHunter-Havoc','Druid-Balance','Druid-Guardian','Druid-Feral','Warrior-Protection','Warlock-Demonology','Rogue-Outlaw','Evoker-Devastation','Monk-Windwalker','Rogue-Assassination','Rogue-Subtlety','Warlock-Affliction','Monk-Brewmaster','Monk-Mistweaver',}; local provider = {region='CN',realm='埃加洛尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Am='Ambrosio:BAAAKgAECggIEAABKgAFFAgIJgABAHgcAA==.',Ba='Baboy:BAAAKgAECgUIBQAAAA==.Badjuju:BAAAKgAFFAQIBAAAAA==.Balagan:BAAAKgADCggICAAAAA==.Baojojo:BAAAKgAECggIEAAAAA==.',Bi='Bigbra:BAABKgAFFH8IAAICAAgISAwtCADhAQACAAgISAwtCADhAQAAAA==.',Bl='Blast:BAABKgAFFH8IAAIDAAgIswpADQDOAQADAAgIswpADQDOAQAAAA==.Bleachz:BAAAKgAECgIIAgAAAA==.',Co='Connie:BAAAKgAECgYIDAAAAA==.',El='Elaras:BAABKgAFFH8MAAIEAAYIuiKWAwDUAQAEAAYIuiKWAwDUAQAAAA==.',Fa='Fables:BAAAKgAFFAYIAgAAAA==.',Go='Goodnight:BAAAKgAECgQIBAAAAA==.',Gu='Guldaneye:BAAAKgAECgUIDQAAAA==.',He='Heybear:BAAAKgADCgEIAQAAAA==.',Hi='Hiz:BAAAKgAECgYICwAAAA==.',Hu='Huarya:BAABKgAFFH8KAAIFAAYINSJxAAAJAgAFAAYINSJxAAAJAgAAAA==.Hunterbleach:BAAAKgAECggIAQABKgAFFAgICAAGABcdAA==.',Ja='Jamila:BAAAKgAFFAQIBAABKgAFFAgIKgAGACMgAA==.',Je='Jezd:BAABKgAFFH8GAAIHAAYI/A2QGABZAQAHAAYI/A2QGABZAQAAAA==.',Ju='June:BAAAKgAFFAQIBAAAAA==.Juno:BAAAKgADCggICAAAAA==.',Li='Littlefat:BAAAKgAFFAgIBAAAAA==.',Lo='Loki:BAABKgAFFH8GAAIIAAYIdx31AwCIAQAIAAYIdx31AwCIAQAAAA==.',Mo='Moouse:BAAAKgAECgUIBQAAAA==.',Oh='Oh:BAAAKgAFFAYIBAAAAA==.',Pl='Playerwynfsy:BAAAKgAECgYIBgAAAA==.',Ra='Radwimps:BAAAKgAECgMIAwABKgAFFAUIBwAJAI8XAA==.Razor:BAAAKgADCgcIBwAAAA==.',Ro='Roadhog:BAABKgAFFH8IAAIBAAgIYw4MAwAkAgABAAgIYw4MAwAkAgAAAA==.',Sa='Sahur:BAABKgAFFH8FAAIKAAMImgWuIAB/AAAKAAMImgWuIAB/AAAAAA==.Savitar:BAABKgAFFH8MAAMLAAYIoBvMAADQAQALAAYIBxrMAADQAQAGAAMInCG5NQC9AAAAAA==.',Si='Silas:BAABKgAFFH8UAAMHAAYIoB/EDQC3AQAHAAYIoB/EDQC3AQAMAAQIHxIIEgCyAAAAAA==.',St='Stig:BAABKgAFFH8IAAINAAgIfA2+AwAJAgANAAgIfA2+AwAJAgAAAA==.',Sz='Szh:BAABKgAFFH8LAAIOAAMILhZ+CQDhAAAOAAMILhZ+CQDhAAAAAA==.',Th='Thundersm:BAAAKgAECgcICAAAAA==.',Tu='Tuolagan:BAAAKgAECgIIAgAAAA==.',Vi='Vincent:BAABKgAFFH8GAAIDAAYIQxPTGwCFAQADAAYIQxPTGwCFAQAAAA==.',Vu='Vurtne:BAAAKgADCgIIAgAAAA==.',Ze='Zerodal:BAAAKgAFFAIIAgAAAA==.Zeronine:BAAAKgAECgMIAwAAAA==.',['一包']='一包干脆面:BAAAKgADCggICAAAAA==.',['一弎']='一弎一肆:BAAAKgAECgYIBgAAAA==.',['一派']='一派狐言:BAAAKgAECgIIAwAAAA==.',['一雨']='一雨天一:BAABKgAECn8WAAIDAAgI4wi/owBQAQADAAgI4wi/owBQAQAAAA==.',['不吉']='不吉的黑白:BAAAKgAECgEIAQAAAA==.',['不學']='不學灬無術:BAAAKgAFFAQIBAAAAA==.',['不怕']='不怕潜规则:BAAAKgADCgUIBQAAAA==.',['不要']='不要加香菜:BAABKgAFFH8IAAIPAAgIdgOrBwAwAQAPAAgIdgOrBwAwAQAAAA==.',['不见']='不见君:BAABKgAFFH8FAAMQAAQIFhu6FgDzAAAQAAQISRi6FgDzAAAOAAEI5x+EKQBGAAABKgAFFAgIBAARAAAAAA==.',['与你']='与你守日出:BAABKgAFFH8IAAISAAgIaBD5BgCyAQASAAgIaBD5BgCyAQAAAA==.',['且行']='且行且惜:BAAAKgADCggICAAAAA==.',['丶妖']='丶妖小妖:BAABKgAFFH8YAAITAAQIUxyCGwDgAAATAAQIUxyCGwDgAAAAAA==.',['乘子']='乘子小象腿:BAAAKgADCgEIAQAAAA==.',['二手']='二手玫瑰丶:BAAAKgAFFAQIBAAAAA==.',['二蛋']='二蛋重生:BAAAKgAECgQICAAAAA==.',['亚历']='亚历山大:BAACKgAFFH8YAAIMAAMIFwmDHgBqAAAMAAMIFwmDHgBqAAAqAAQKf18AAgwACAg/E2gjAG8BAAwACAg/E2gjAG8BAAAA.',['亚妮']='亚妮拉丝:BAAAKgADCggICAAAAA==.',['人间']='人间小可爱:BAABKgAFFH8IAAIKAAgInBRaBgAxAgAKAAgInBRaBgAxAgAAAA==.',['今夕']='今夕丶何夕:BAAAKgAFFAEIAQAAAA==.',['代王']='代王里天神:BAAAKgAECgQIBQAAAA==.',['伊利']='伊利蛋怒風:BAAAKgAFFAIIAgAAAA==.',['伊森']='伊森丨哈德:BAAAKgAECgYIBgAAAA==.',['伊莉']='伊莉诞:BAAAKgAFFAQIBAAAAA==.',['你就']='你就给我爆:BAABKgAFFH8KAAIOAAQI2AVFCgDVAAAOAAQI2AVFCgDVAAAAAA==.',['偶系']='偶系毁灭灾难:BAAAKgADCgEIAQAAAA==.',['傲世']='傲世:BAAAKgADCgEIAQABKgAFFAIIAgARAAAAAA==.',['儿童']='儿童期一:BAAAKgAECgYIBgAAAA==.',['允川']='允川:BAABKgAFFH8IAAIUAAIIFwJFKgA9AAAUAAIIFwJFKgA9AAABKgAFFAMIGAAMABcJAA==.',['元祖']='元祖咖喱:BAAAKgAECgcIEQAAAA==.',['兄弟']='兄弟葫芦:BAAAKgADCgQIBAAAAA==.',['克里']='克里兰德:BAAAKgAECgIIAgAAAA==.',['兜里']='兜里没钱:BAAAKgAECgYIDAAAAA==.',['公交']='公交霉:BAABKgAFFH8FAAIVAAQIUg3UGACzAAAVAAQIUg3UGACzAAAAAA==.',['再別']='再別無敌:BAAAKgAECgcIBwABKgAFFAQICwAWAHkgAA==.',['再别']='再别無敌:BAAAKgAECggICAABKgAFFAQICwAWAHkgAA==.',['再次']='再次抄底:BAABKgAFFH8IAAIXAAQIQBEGFgDqAAAXAAQIQBEGFgDqAAAAAA==.',['冬天']='冬天的酒:BAACKgAFFH8KAAISAAII+RXLIwCLAAASAAII+RXLIwCLAAAqAAQKfyoAAhIACAjsFOxCAHwBABIACAjsFOxCAHwBAAAA.',['冰柠']='冰柠乐:BAAAKgADCggICAAAAA==.',['冰镇']='冰镇卤煮:BAAAKgAFFAQIBAAAAA==.',['凑热']='凑热闹僧魁:BAAAKgAFFAQIBAAAAA==.',['几度']='几度秦云楚雨:BAAAKgAECgYIBgAAAA==.',['凱凡']='凱凡:BAAAKgAECgYIBgAAAA==.',['切尔']='切尔斯:BAAAKgAFFAQIAgAAAA==.',['加塞']='加塞拉:BAABKgAFFH8FAAMYAAIIJQmDUAB0AAAYAAIIJQmDUAB0AAAPAAEI9g2TIQA/AAAAAA==.',['十方']='十方俱灭:BAAAKgADCgEIAQAAAA==.',['千华']='千华留:BAACKgAFFH8iAAIGAAQI8RsCDwA4AQAGAAQI8RsCDwA4AQAqAAQKf1kAAgYACAjiJP8GAPMCAAYACAjiJP8GAPMCAAAA.',['半岛']='半岛欧尼酱:BAAAKgAECgMIAwAAAA==.',['南小']='南小鸟:BAAAKgAECggICwAAAA==.',['卡尔']='卡尔梅斯:BAAAKgAECggICAAAAA==.',['压路']='压路机:BAAAKgAFFAIIAgAAAA==.',['参天']='参天大刘欢:BAACKgAFFH8JAAMZAAQIfgvXCQByAAAaAAMItQgYCQCaAAAZAAQIywjXCQByAAAqAAQKfxsAAxkACAhNFl0KADgBABoABwhJErERAGEBABkACAixE10KADgBAAAA.',['可喜']='可喜可乐:BAAAKgAECgUIBQAAAA==.可喜可贺:BAACKgAFFH8IAAIFAAIISRLnHQCeAAAFAAIISRLnHQCeAAAqAAQKfy8ABAUACAgjHlclAPsBAAUABwiaHVclAPsBAAEABAgFHSQqAGkBABsABwjBBDkqALQAAAAA.',['可爱']='可爱的川川:BAAAKgAFFAgIBAAAAA==.',['哈哈']='哈哈牛盾:BAABKgAFFH8GAAIbAAYIxgquBwDuAAAbAAYIxgquBwDuAAAAAA==.',['唯快']='唯快不破丶:BAACKgAFFH8KAAICAAYIHBV6DAD9AAACAAYIHBV6DAD9AAAqAAQKfygAAxwACAh2HiQKAEECABwABwhuIiQKAEECAAIACAjVEf85AIQBAAAA.',['啃德']='啃德基:BAAAKgAECgYIBgAAAA==.',['啊布']='啊布:BAABKgAFFH8GAAIDAAYI6h67HwBxAQADAAYI6h67HwBxAQAAAA==.',['喝一']='喝一杯摩卡:BAABKgAFFH8GAAICAAYIHAYpEgANAQACAAYIHAYpEgANAQAAAA==.',['嗔怨']='嗔怨:BAAAKgADCgYIBgAAAA==.',['嘎嘎']='嘎嘎学徒:BAACKgAFFH8bAAMOAAUIZx0UDQD+AAAKAAQI2CH8GgANAQAOAAQIpBoUDQD+AAAqAAQKfxoAAw4ACAgaIn8VAFMCAA4ACAigIX8VAFMCAAoABAj4If9IABsBAAAA.',['回头']='回头不是你:BAAAKgADCgUIBQAAAA==.',['因风']='因风飞过蔷薇:BAABKgAECn8bAAIXAAgIwxMeFQC2AQAXAAgIwxMeFQC2AQAAAA==.',['圣世']='圣世:BAAAKgAFFAIIAgAAAA==.',['圣光']='圣光丿罗兰:BAAAKgAECggICAAAAA==.圣光审判者:BAACKgAFFH8WAAMDAAYI7yIbFQCzAQADAAYI7yIbFQCzAQAUAAQIjRHSCwCtAAAqAAQKfxsAAgMACAjpJcAMAOYCAAMACAjpJcAMAOYCAAAA.',['圣心']='圣心骑士:BAAAKgADCgIIAgAAAA==.',['圣殿']='圣殿之主:BAAAKgADCgYIBgAAAA==.',['在家']='在家不出门:BAAAKgADCgIIAgAAAA==.',['坏刃']='坏刃:BAAAKgAFFAgIBAAAAA==.',['塞勒']='塞勒尼:BAABKgAFFH8QAAMLAAgIThbZBQATAgALAAgIThbZBQATAgAGAAQIpxDwGwDlAAAAAA==.',['墨墨']='墨墨:BAAAKgAECggIDwABKgAFFAgIDgAHAA8XAA==.',['复活']='复活魔王:BAABKgAFFH8KAAMYAAgIKhX6EgCEAQAYAAYIihP6EgCEAQAPAAMIASOzGgDMAAAAAA==.',['夕立']='夕立加油:BAAAKgADCgYIBgAAAA==.',['夜無']='夜無殇:BAAAKgAECgMIAwAAAA==.',['大圣']='大圣没娶我:BAAAKgAECgYIAQAAAA==.',['大梵']='大梵:BAABKgAFFH8IAAISAAYIlhhRAQCnAQASAAYIlhhRAQCnAQAAAA==.',['大欠']='大欠儿:BAAAKgAECgYICwAAAA==.',['大石']='大石碎胸口:BAAAKgAECggIDgAAAA==.',['大脚']='大脚怪:BAABKgAFFH8JAAMBAAMIDw2zDADEAAABAAMIhwqzDADEAAAFAAMIVwh5JwCuAAABKgAFFAcIBwAVAAUPAA==.',['天野']='天野月:BAABKgAFFH8GAAIdAAMIUwuXBgCpAAAdAAMIUwuXBgCpAAAAAA==.',['天魂']='天魂无双:BAAAKgAECgYIBgAAAA==.',['太大']='太大希尔:BAACKgAFFH8SAAIeAAgITR9qBABsAgAeAAgITR9qBABsAgAqAAQKfyoAAh4ACAjtHJ4QAEYCAB4ACAjtHJ4QAEYCAAAA.',['太妍']='太妍:BAAAKgAECgYICQAAAA==.',['奥黛']='奥黛丽厚本:BAAAKgAFFAYIBAAAAA==.',['奶灬']='奶灬罐子:BAAAKgAECgMIAwAAAA==.',['妹妹']='妹妹门别锁:BAAAKgAECgQIBwAAAA==.',['姬姬']='姬姬蹦:BAABKgAFFH8GAAIHAAYI/xHEFAB1AQAHAAYI/xHEFAB1AQAAAA==.',['嫩非']='嫩非牛:BAAAKgAECgUICgAAAA==.',['孤独']='孤独的错:BAAAKgAECgMIAwAAAA==.',['守饭']='守饭狗:BAAAKgAECgYICQAAAA==.',['安静']='安静的奶德:BAAAKgAECgcIEwAAAA==.',['寒宵']='寒宵:BAABKgAFFH8GAAIDAAYIDhcNHgB6AQADAAYIDhcNHgB6AQAAAA==.',['寒谷']='寒谷山人:BAAAKgAFFAQIBAABKgAFFAgICAAGABcdAA==.',['射到']='射到假死:BAAAKgAECgYIBgAAAA==.',['小牛']='小牛向前冲:BAAAKgAECgYIBgAAAA==.',['小狗']='小狗子:BAAAKgAECggIEAAAAA==.',['小豆']='小豆苗咩唔:BAAAKgAECgUIBQAAAA==.',['小黄']='小黄蜂:BAAAKgAECgQICAAAAA==.',['少年']='少年挺文艺:BAAAKgAFFAUIAwAAAA==.',['尛奶']='尛奶瓶兒:BAABKgAFFH8SAAIUAAgIuQ5sCACCAQAUAAgIuQ5sCACCAQAAAA==.',['尛尛']='尛尛熊丶:BAAAKgAECgQIBAAAAA==.',['尤迪']='尤迪安丶:BAAAKgAFFAYIAQAAAA==.',['屠戮']='屠戮狂杀:BAAAKgAFFAIIAgAAAA==.',['左未']='左未门:BAAAKgAFFAIIAgAAAA==.',['市芄']='市芄银:BAABKgAFFH8PAAMGAAMIRRLRLwCZAAAGAAMIRRLRLwCZAAALAAIIgQhCSABfAAAAAA==.',['带核']='带核吃芒果:BAABKgAFFH8KAAIWAAYI3RjxCACOAQAWAAYI3RjxCACOAQAAAA==.',['带眼']='带眼镜小流氓:BAAAKgAECggIDgAAAA==.带眼镜流氓:BAAAKgAECggIDwAAAA==.带眼镜的流氓:BAABKgAECn8kAAMBAAgI3hZ+FQDiAQABAAgI3hZ+FQDiAQAFAAgIQw0JNgCmAQAAAA==.带眼镜的程龙:BAABKgAECn8aAAIfAAgIchB0JQB1AQAfAAgIchB0JQB1AQAAAA==.',['年少']='年少有爲:BAAAKgAECgIIAgAAAA==.',['幽冥']='幽冥寐影:BAABKgAFFH8OAAMgAAYICBjrDQBxAQAgAAYICBjrDQBxAQAhAAQIXglPCgC9AAABKgAFFAgIBQAgAEkOAA==.',['废铁']='废铁加鲁鲁:BAABKgAFFH8MAAIBAAYIfBreBgCpAQABAAYIfBreBgCpAQAAAA==.',['心累']='心累:BAAAKgAFFAQIBAAAAA==.',['忆恋']='忆恋薇安:BAAAKgADCggICAAAAA==.',['忠诚']='忠诚的信士:BAAAKgAECggIEgAAAA==.',['忧傷']='忧傷调:BAACKgAFFH8xAAQiAAgIxx2kCgDfAAACAAYIuBkQDQBzAQAiAAMIcyakCgDfAAAcAAEI2QZgLABCAAAqAAQKf08AAgIACAiAJfMCAOMCAAIACAiAJfMCAOMCAAAA.',['快組']='快組我劉天馳:BAABKgAFFH8JAAIUAAgIthtBBAATAgAUAAgIthtBBAATAgAAAA==.',['快组']='快组我王瞾飞:BAAAKgAECgQIBAAAAA==.',['性感']='性感小么么:BAABKgAFFH8GAAIDAAQI2RqzXAC3AAADAAQI2RqzXAC3AAAAAA==.性感小摸摸:BAAAKgAFFAIIAgAAAA==.',['恶魔']='恶魔之击:BAABKgAFFH8NAAIgAAMIiBXuFQD5AAAgAAMIiBXuFQD5AAAAAA==.',['悄悄']='悄悄慕斯猫:BAAAKgADCggICAAAAA==.',['惊羽']='惊羽:BAABKgAFFH8FAAIGAAIIVxPXUABpAAAGAAIIVxPXUABpAAAAAA==.',['憨牛']='憨牛骑士:BAABKgAFFH8RAAIDAAQIOhxVPQD5AAADAAQIOhxVPQD5AAABKgAFFAUIGwAOAGcdAA==.',['成富']='成富裕:BAACKgAFFH8JAAIDAAMIeRDWVwDBAAADAAMIeRDWVwDBAAAqAAQKfzMAAgMACAhaH+ckAG0CAAMACAhaH+ckAG0CAAAA.',['我先']='我先上了:BAAAKgAECgYIBgAAAA==.',['战争']='战争机器:BAABKgAFFH8JAAIFAAMIDA2VEgDZAAAFAAMIDA2VEgDZAAAAAA==.',['战场']='战场原小葵:BAABKgAFFH8HAAMOAAUIsA7qDAC5AAAOAAMIUgvqDAC5AAAKAAIIvBNVMwCWAAABKgAFFAgIBAARAAAAAA==.',['戴眼']='戴眼镜小流氓:BAAAKgAECgcICwAAAA==.戴眼镜流氓:BAAAKgAECggIEQAAAA==.',['手打']='手打柠檬冰:BAAAKgAECgYIBgAAAA==.',['找大']='找大桃:BAAAKgAFFAgIBAAAAA==.找大瓜:BAABKgAFFH8sAAMcAAcIihKmBAAQAQAcAAYI2Q6mBAAQAQAiAAQIGhOUCwDXAAAAAA==.找大蛙:BAAAKgAECgYIBgAAAA==.',['招财']='招财小笨猫:BAABKgAFFH8eAAIOAAMIKxksEgDRAAAOAAMIKxksEgDRAAAAAA==.',['挽歌']='挽歌荣耀:BAAAKgADCggICAAAAA==.',['数师']='数师:BAABKgAFFH8RAAQCAAgIzR4ABABqAgACAAgIzR4ABABqAgAcAAEIIxx2IwBTAAAiAAEIAABcJAAAAAAAAA==.',['无敌']='无敌飞战将:BAABKgAFFH8KAAIGAAYITCA2CQDgAQAGAAYITCA2CQDgAQAAAA==.',['无累']='无累:BAAAKgAECgUIBQAAAA==.',['旭写']='旭写爱的诗文:BAAAKgAECgQIBAAAAA==.',['春也']='春也迟迟:BAAAKgADCggICAAAAA==.',['是二']='是二哈啊:BAAAKgADCggICAAAAA==.',['晓舞']='晓舞:BAAAKgADCgEIAQAAAA==.',['晚睡']='晚睡的兔兔:BAABKgAFFH8NAAIjAAMI1Ab1CAB7AAAjAAMI1Ab1CAB7AAABKgAFFAMIGAAMABcJAA==.',['普罗']='普罗米休斯:BAAAKgAECgIIAgAAAA==.',['普羅']='普羅米修斯:BAAAKgAECgMIBQAAAA==.',['普莉']='普莉希娅:BAAAKgAECgYIBgAAAA==.',['晴天']='晴天舞舞:BAAAKgADCggICAAAAA==.',['暗影']='暗影恶魔:BAAAKgAFFAYIBAAAAA==.暗影术神:BAAAKgAFFAQIAwAAAA==.',['暗黑']='暗黑凋零:BAAAKgAFFAMIAwAAAA==.暗黑破壞神:BAACKgAFFH8RAAIOAAMIPQ/HGACyAAAOAAMIPQ/HGACyAAAqAAQKfyIAAg4ACAiMG4MdABsCAA4ACAiMG4MdABsCAAAA.',['曾经']='曾经的狠狠摸:BAAAKgAECgYIBgAAAA==.',['月亮']='月亮祭司:BAABKgAFFH8UAAQJAAYIaR40CACMAQAJAAYIaR40CACMAQAWAAQIjRL6GQDCAAATAAEIjSS2HwBdAAAAAA==.',['月光']='月光阴影:BAAAKgAFFAQIBAAAAA==.',['月逐']='月逐舟行:BAAAKgADCggICAAAAA==.',['服部']='服部信玄:BAAAKgAECgMIAwAAAA==.',['朝夕']='朝夕夕:BAAAKgADCggICAAAAA==.',['朝希']='朝希希:BAAAKgADCgcIBwAAAA==.',['杠开']='杠开甩素本:BAAAKgAECgMIBgAAAA==.',['杰洛']='杰洛尼莫:BAAAKgAECgMIAwAAAA==.',['柠檬']='柠檬百香果:BAABKgAFFH8OAAIFAAgIoAx7CADRAQAFAAgIoAx7CADRAQAAAA==.',['桃花']='桃花夭夭:BAAAKgAECgQIBQAAAA==.',['椿湫']='椿湫:BAAAKgAECggICAAAAA==.',['楚鳳']='楚鳳琉璃:BAAAKgADCgUIBQAAAA==.',['欧罗']='欧罗罗伽亚:BAAAKgAECgEIAQAAAA==.',['武侯']='武侯莫尔:BAAAKgAFFAQIBAAAAA==.',['歧视']='歧视:BAABKgAFFH8HAAIDAAQIwBc4QQDuAAADAAQIwBc4QQDuAAAAAA==.',['沉默']='沉默的天蓝色:BAAAKgAECggICAAAAA==.',['沐浴']='沐浴圣光:BAAAKgAECgQIBAAAAA==.',['注意']='注意宝珠:BAAAKgADCggICgAAAA==.',['泰好']='泰好看了:BAAAKgADCggIDAAAAA==.',['洗奶']='洗奶娃:BAAAKgAECgEIAQAAAA==.',['浮笙']='浮笙:BAAAKgAECgQICAAAAA==.',['海倫']='海倫仙度丝:BAAAKgADCgEIAQAAAA==.',['淡灰']='淡灰色的记忆:BAAAKgADCgEIAQAAAA==.',['深白']='深白浅绿:BAAAKgAECggICAABKgAFFAcIBwAVAAUPAA==.',['混沌']='混沌灾星:BAACKgAFFH8JAAIFAAMIpRZsDQAFAQAFAAMIpRZsDQAFAQAqAAQKfxkABAUACAjFIPEVACYCAAUACAirH/EVACYCABsABwj8HMcPAOQBAAEABAgsFCU6APkAAAAA.',['清辰']='清辰板小凳:BAAAKgAECgUIBQAAAA==.',['澪冬']='澪冬:BAAAKgAFFAIIAgAAAA==.',['灬丨']='灬丨季末丨灬:BAAAKgAFFAUIBAAAAA==.',['灬绝']='灬绝色妖姬灬:BAAAKgAECgIIAgAAAA==.',['灭天']='灭天一箭:BAAAKgADCgQIBAAAAA==.',['灵魂']='灵魂碎片贩子:BAAAKgAECgUIBQAAAA==.',['炎菲']='炎菲:BAAAKgAECggIEQAAAA==.',['热心']='热心市民黑熊:BAAAKgAECggICAAAAA==.',['热血']='热血:BAAAKgAFFAIIAgAAAA==.',['焱焰']='焱焰小毛豆:BAABKgAFFH8MAAMSAAQIqCQUBABAAQASAAQIqCQUBABAAQAVAAQIDRLpGACyAAAAAA==.',['爱你']='爱你一小下:BAABKgAFFH8FAAIYAAUI7woNIQAaAQAYAAUI7woNIQAaAQAAAA==.',['爺恐']='爺恐怖人物:BAAAKgAFFAIIAgAAAA==.',['牛呣']='牛呣呣:BAAAKgAFFAQIAgAAAA==.',['牛萨']='牛萨:BAABKgAFFH8QAAISAAgIghk+BAAgAgASAAgIghk+BAAgAgAAAA==.',['狐作']='狐作非为:BAAAKgAECgMIAwAAAA==.',['猎狞']='猎狞人:BAABKgAFFH8GAAIGAAYIgQ0CGQA0AQAGAAYIgQ0CGQA0AQAAAA==.',['猎神']='猎神七月:BAAAKgAECggICAAAAA==.',['献世']='献世:BAAAKgAECgQIBAABKgAFFAIIAgARAAAAAA==.',['玉玉']='玉玉德:BAAAKgAFFAQIBAAAAA==.',['王曌']='王曌飞丶:BAAAKgAECggIEgAAAA==.',['玖儿']='玖儿呀:BAAAKgADCgQIBAAAAA==.',['甄尐']='甄尐妃:BAABKgAECn8aAAIDAAYItBgWdQBpAQADAAYItBgWdQBpAQAAAA==.',['甜小']='甜小甜:BAABKgAFFH8KAAQCAAYI4xV1BQBPAQACAAUIORR1BQBPAQAcAAEIhhnnEQBcAAAiAAEItAexGgBQAAAAAA==.',['番茄']='番茄小美妞:BAAAKgADCgIIAgAAAA==.番茄蛋:BAACKgAFFH8eAAMVAAQIIR02CAAnAQAVAAQIIR02CAAnAQANAAEIiQ0NEAA5AAAqAAQKf1cAAxUACAhcJN4HALYCABUACAhcJN4HALYCAA0AAghnF+w+AGUAAAAA.番茄里炒蛋:BAAAKgAECgQIBAAAAA==.',['疯狂']='疯狂小萨:BAAAKgAECgUIBgAAAA==.',['看秘']='看秘密教学:BAAAKgAFFAMIAwAAAA==.',['真部']='真部落无敌:BAABKgAECn8pAAQYAAgIqB/XHgBJAgAYAAgIqB/XHgBJAgAPAAMIQBSEHwC7AAAZAAEIEwnMRAASAAAAAA==.',['矮丑']='矮丑法王:BAAAKgAECgUIBQAAAA==.',['石头']='石头人没奶:BAABKgAFFH8QAAIkAAgIMBN8BQDKAQAkAAgIMBN8BQDKAQAAAA==.',['砍刀']='砍刀小子:BAAAKgAECggICAAAAA==.',['破天']='破天刈剑:BAAAKgAECgQIBAAAAA==.',['破碎']='破碎精灵:BAABKgAFFH8FAAIgAAII3AncFACJAAAgAAII3AncFACJAAAAAA==.',['碎月']='碎月沉星:BAAAKgAECgQIBQAAAA==.',['祖龙']='祖龙游道:BAAAKgAECgEIAQAAAA==.',['神圣']='神圣干涉:BAAAKgAFFAQIBAABKgAFFAgIBgAYAAoKAA==.',['福安']='福安:BAAAKgAECgIIAgAAAA==.',['米奈']='米奈希尔:BAAAKgADCggIDwAAAA==.',['糖果']='糖果哈尼:BAAAKgAECggICAAAAA==.',['紫色']='紫色皮皮虾:BAABKgAFFH8FAAIFAAUI1xumDwBbAQAFAAUI1xumDwBbAQAAAA==.',['细語']='细語者:BAAAKgAECgMIAwAAAA==.',['缺德']='缺德丶鲁伊:BAAAKgADCgIIAgAAAA==.',['翻倒']='翻倒龟:BAAAKgAECggIEAAAAA==.',['老妹']='老妹你咋了:BAACKgAFFH8IAAIDAAYIAw/YIwBcAQADAAYIAw/YIwBcAQAqAAQKfxgAAwMACAh4FDeZAGUBAAMACAh4FDeZAGUBABQAAQgbA35tAAkAAAAA.',['老白']='老白:BAAAKgAECgUIBQAAAA==.',['老衲']='老衲被逼出家:BAABKgAECn8WAAISAAgI9hAEQwB7AQASAAgI9hAEQwB7AQAAAA==.',['聼琳']='聼琳語:BAABKgAFFH8LAAMWAAQIeSAlBwAkAQAWAAQIeSAlBwAkAQAJAAQIuQ6jEgDPAAAAAA==.',['肥大']='肥大饰拳:BAABKgAFFH8HAAIVAAMIBQ8qDgC1AAAVAAMIBQ8qDgC1AAAAAA==.',['胖宝']='胖宝宝:BAAAKgAECggIEAAAAA==.',['自奏']='自奏圣乐:BAAAKgAECgQIBAAAAA==.',['般若']='般若绝:BAAAKgAECgUIBQAAAA==.',['艾格']='艾格特:BAAAKgADCggICAAAAA==.',['芒果']='芒果木槿花:BAAAKgAECggIEAAAAA==.',['苏英']='苏英俊:BAAAKgAFFAIIAgAAAA==.',['苏醒']='苏醒的哈利:BAAAKgAECgcICAAAAA==.苏醒的背叛:BAAAKgADCggICAAAAA==.苏醒的黑暗:BAAAKgADCggICAAAAA==.',['茗綺']='茗綺小劍敏:BAAAKgAFFAIIAgAAAA==.',['草莓']='草莓味飛崽:BAABKgAFFH8ZAAQWAAgIzBrLAQC5AQATAAgIOxieAwAbAgAWAAYIQxbLAQC5AQAJAAMI3xn9CQAPAQAAAA==.',['莉娅']='莉娅:BAAAKgAECggICgAAAA==.',['莱恩']='莱恩曼妮:BAACKgAFFH8dAAICAAQIlBLAEgADAQACAAQIlBLAEgADAQAqAAQKf04AAgIACAh0Hd8QACICAAIACAh0Hd8QACICAAAA.',['菲尔']='菲尔:BAABKgAFFH8IAAIDAAgIEhmtCAA4AgADAAgIEhmtCAA4AgAAAA==.',['萌新']='萌新鬣妈人:BAAAKgAECgMIAwAAAA==.',['萨安']='萨安德萨:BAABKgAFFH8UAAINAAYIrh5lBQC8AQANAAYIrh5lBQC8AQAAAA==.',['萨摩']='萨摩牛:BAACKgAFFH8LAAISAAQIXSHpGQAYAQASAAQIXSHpGQAYAQAqAAQKfxYAAhIABghSIzopANkBABIABghSIzopANkBAAEqAAUUBQgbAA4AZx0A.',['蓝色']='蓝色吻:BAAAKgAECgQIBgAAAA==.蓝色皮卡丘:BAAAKgAECgIIAgAAAA==.',['蓝风']='蓝风的向日葵:BAABKgAFFH8IAAIDAAgImhKWDAAEAgADAAgImhKWDAAEAgAAAA==.',['虔诚']='虔诚:BAAAKgADCgEIAQAAAA==.',['蛮牛']='蛮牛士:BAABKgAFFH8MAAIDAAYIBRF2KQBBAQADAAYIBRF2KQBBAQAAAA==.',['褐色']='褐色炭烧:BAAAKgAECgIIAgAAAA==.',['语雨']='语雨者:BAABKgAFFH8KAAMYAAYICRDqGQBKAQAYAAYICRDqGQBKAQAPAAQIXAd/KACDAAAAAA==.',['请叫']='请叫我奶神:BAAAKgADCggICAAAAA==.',['请赐']='请赐予我灌注:BAAAKgAECgEIAQAAAA==.',['谁是']='谁是谁菲:BAABKgAECn8YAAIOAAYIjggRZgDYAAAOAAYIjggRZgDYAAAAAA==.',['谢特']='谢特丿:BAAAKgAECgEIAQAAAA==.',['贼有']='贼有劲丶:BAAAKgADCggIDgAAAA==.',['赫斯']='赫斯缇雅:BAAAKgADCggICAAAAA==.',['赵曰']='赵曰天大魔王:BAABKgAFFH8GAAQCAAQICBo5DQD3AAACAAMICBo5DQD3AAAiAAIIqQQlIQA8AAAcAAEIAADjIwAAAAAAAA==.',['达分']='达分奇:BAABKgAFFH8IAAIGAAMItQxKGwC9AAAGAAMItQxKGwC9AAAAAA==.',['达文']='达文西:BAAAKgAECgYIBgAAAA==.',['过来']='过来摸摸:BAABKgAFFH8GAAIDAAYIoBLWIwBcAQADAAYIoBLWIwBcAQAAAA==.',['连城']='连城绝影:BAAAKgAECgEIAQAAAA==.',['速度']='速度灭啊:BAAAKgAECgIIAgAAAA==.',['邦迪']='邦迪:BAAAKgADCggIDwAAAA==.',['邪枭']='邪枭印:BAAAKgADCgMIAwAAAA==.',['邪王']='邪王真眼:BAABKgAECn8ZAAICAAgISBiSLQC9AQACAAgISBiSLQC9AQAAAA==.',['鍃丶']='鍃丶熱:BAAAKgAECgEIAQAAAA==.',['银河']='银河落九天:BAAAKgAECggIDQAAAA==.',['阿尔']='阿尔塞斯之怒:BAAAKgAFFAEIAQAAAA==.阿尔泰米斯:BAAAKgAFFAQIBAAAAA==.',['阿萨']='阿萨谢尔:BAABKgAFFH8EAAIeAAQIYSKnEwA0AQAeAAQIYSKnEwA0AQAAAA==.',['雨天']='雨天的爱哭鬼:BAABKgAECn8dAAITAAgIVBAWMQB+AQATAAgIVBAWMQB+AQAAAA==.',['雷霆']='雷霆灬嘎巴:BAAAKgAECgMIAwAAAA==.',['青梅']='青梅嗅:BAACKgAFFH8MAAIOAAQIghslCQDlAAAOAAQIghslCQDlAAAqAAQKfzMABA4ACAgdIb8RAHECAA4ACAgdIb8RAHECAAoAAwgPFPxoAKcAABAAAgiZCGWRAFMAAAAA.',['非常']='非常牛:BAAAKgAFFAIIAgAAAA==.',['非牛']='非牛类:BAACKgAFFH8IAAMGAAMIWCEWHgAXAQAGAAMIWCEWHgAXAQALAAEIQgRXLAAzAAAqAAQKfy8AAwYACAgMJEsOALECAAYACAgMJEsOALECAAsABAhtEPpgAJ8AAAAA.',['音调']='音调:BAAAKgAFFAgIBAAAAA==.',['颜柏']='颜柏:BAAAKgAECgMIAwAAAA==.',['风之']='风之厄运:BAAAKgADCgQIBAAAAA==.',['风行']='风行者:BAAAKgADCgUIBQAAAA==.',['鬼敬']='鬼敬:BAAAKgADCgEIAQAAAA==.',['鬼麟']='鬼麟丨小乐:BAAAKgAECgEIAQAAAA==.',['魔神']='魔神:BAAAKgAFFAMIAwAAAA==.',['鱼片']='鱼片儿:BAACKgAFFH8GAAIXAAIIdRAZKQCQAAAXAAIIdRAZKQCQAAAqAAQKfy8AAhcACAhbIIkZADUCABcACAhbIIkZADUCAAAA.',['鲜红']='鲜红的幼月:BAABKgAFFH8HAAIJAAUIjxfXBQBWAQAJAAUIjxfXBQBWAQAAAA==.',['鸭梨']='鸭梨黎:BAABKgAECn8UAAIXAAgITBc9KwC6AQAXAAgITBc9KwC6AQAAAA==.',['麻辣']='麻辣香鱼片:BAAAKgAECgYIBgAAAA==.',['黑暗']='黑暗审判者:BAAAKgAECggICAAAAA==.黑暗镇魂挽歌:BAABKgAFFH8OAAICAAgIChHPCAABAgACAAgIChHPCAABAgAAAA==.',['黑硬']='黑硬肉钢猛:BAAAKgADCggICAAAAA==.',['黑胡']='黑胡椒喷嚏:BAABKgAFFH8MAAMYAAQIuAsORACeAAAYAAQIuAsORACeAAAPAAQIhwrYJgCKAAAAAA==.',['龙城']='龙城狂霸拽:BAAAKgAECgEIAQAAAA==.',['龙格']='龙格尔:BAABKgAFFH8MAAIeAAgI0BXbCADsAQAeAAgI0BXbCADsAQAAAA==.',['龙逸']='龙逸轩:BAACKgAFFH8lAAIDAAYIpSKAAAAZAgADAAYIpSKAAAAZAgAqAAQKf0gAAgMACAg/I4MaAJsCAAMACAg/I4MaAJsCAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end