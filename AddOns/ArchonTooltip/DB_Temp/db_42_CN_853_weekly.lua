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
 local lookup = {'Paladin-Retribution','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Shaman-Elemental','Shaman-Enhancement','Shaman-Restoration','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Discipline','Priest-Holy','DemonHunter-Havoc','Rogue-Outlaw','DeathKnight-Blood','Paladin-Holy','Hunter-Survival','Druid-Restoration','DemonHunter-Vengeance','Mage-Arcane','Mage-Fire','Mage-Frost','DeathKnight-Unholy','Paladin-Protection','Druid-Feral','Druid-Guardian','Druid-Balance','Warrior-Arms','Warrior-Fury','Rogue-Assassination','Rogue-Subtlety','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Evoker-Devastation','Warrior-Protection','DeathKnight-Frost','Priest-Shadow','Evoker-Preservation',}; local provider = {region='CN',realm='金度',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ad='Adela:BAACKgAFFH8GAAIBAAYIKh61GgCLAQABAAYIKh61GgCLAQAqAAQKfxgAAgEACAhnGVpgANsBAAEACAhnGVpgANsBAAEqAAUUCAgKAAEArSUA.',Al='Alisaa:BAAAKgAFFAIIAgAAAA==.',Ba='Bamboo:BAAAKgAFFAgIBAAAAA==.',Co='Costea:BAAAKgADCgEIAQAAAA==.',Da='Darkwish:BAABKgAFFH8KAAQCAAYIWRlGBABxAQACAAUIZBlGBABxAQADAAMIBBLJCgDWAAAEAAEIKxn5EQBcAAAAAA==.',Fa='Faye:BAAAKgAECgcIEQAAAA==.',Fe='Feketerigó:BAAAKgAECggIDgAAAA==.Fenria:BAAAKgAECggICwAAAA==.',Ga='Gamble:BAABKgAECn8gAAQFAAgIPRhEIQDBAQAFAAgIcxNEIQDBAQAGAAUIURObKQABAQAHAAgI7APpeQDWAAAAAA==.',Ha='Hades:BAAAKgAFFAIIAgAAAA==.',Hs='Hsu:BAAAKgAECgcIBwAAAA==.',Ir='Irisviel:BAAAKgADCgQIBAAAAA==.',Iz='Izvestia:BAAAKgADCgIIAgAAAA==.',Ka='Kaloge:BAAAKgADCggICAAAAA==.',Kr='Krious:BAAAKgAECggIDgABKgAECggILAABANMiAA==.',Ku='Kunaro:BAAAKgAECgEIAQAAAA==.',La='Latomate:BAAAKgADCggIEAAAAA==.',Lr='Lrovo:BAABKgAFFH8PAAMIAAYIBx44BACUAQAIAAYIVhs4BACUAQAJAAUICSLpEABeAQAAAA==.',Lv='Lvv:BAAAKgAECgQIBAAAAA==.',Mi='Miko:BAABKgAFFH8GAAIBAAYIHxx5FwCgAQABAAYIHxx5FwCgAQAAAA==.',Mu='Murad:BAABKgAFFH8GAAMHAAYIkA4hKgDOAAAHAAUIQAohKgDOAAAFAAEIGgVXJwA/AAAAAA==.',Mz='Mzero:BAAAKgAECgIIBAAAAA==.',Na='Narcissa:BAABKgAFFH8NAAMCAAgI4haSBgArAgACAAgI4haSBgArAgAEAAMIgggmEwCpAAAAAA==.',Ni='Nichole:BAAAKgAECgEIAQAAAA==.',Ro='Rosekelly:BAAAKgAFFAEIAQAAAA==.',So='Sophia:BAAAKgADCggIEAAAAA==.',Ti='Tingjinl:BAABKgAFFH8IAAMCAAYICxmsFABeAQACAAYICxmsFABeAQADAAIICwVrFwBqAAAAAA==.',Vi='Vigilante:BAAAKgAECgYIBwAAAA==.',['一发']='一发毁灭:BAABKgAECn8UAAMCAAgIxRc4HgC3AQACAAcI5Rg4HgC3AQAEAAcIyhQHJAB1AQABKgAECggILAABANMiAA==.',['一粒']='一粒子弹:BAAAKgADCgEIAQAAAA==.',['一零']='一零一:BAABKgAECn8UAAMKAAcI+RWLOwArAQAKAAYIShSLOwArAQALAAcI+xG+OwAoAQAAAA==.',['丁尼']='丁尼格菲儿:BAAAKgAECggIDQAAAA==.',['七卦']='七卦合体黑龙:BAAAKgAECgEIAwAAAA==.',['万能']='万能青年旅店:BAAAKgAFFAYIBAAAAA==.',['三江']='三江口:BAAAKgAECgIIAgAAAA==.',['上京']='上京临潢府:BAABKgAECn8VAAIMAAgIih4lFABgAgAMAAgIih4lFABgAgAAAA==.上京会宁府:BAABKgAECn8oAAIMAAgIcCD7EQBzAgAMAAgIcCD7EQBzAgAAAA==.',['不捅']='不捅不爽斯基:BAABKgAECn8WAAINAAgI5h/tAgCMAgANAAgI5h/tAgCMAgABKgAECggILAABANMiAA==.',['不死']='不死降神:BAAAKgADCgIIAgAAAA==.',['不爱']='不爱了:BAAAKgAFFAQIBAAAAA==.',['不知']='不知道:BAABKgAECn8bAAIOAAgI+w93DQAgAQAOAAgI+w93DQAgAQAAAA==.',['专业']='专业团队:BAAAKgAFFAYIBAAAAA==.',['专治']='专治各种不服:BAAAKgAECggIDQAAAA==.',['东门']='东门听雨:BAAAKgAECgUIBwAAAA==.',['丨以']='丨以撒灬:BAAAKgADCgMIBAAAAA==.',['丨鬼']='丨鬼隐丨:BAAAKgADCggICAAAAA==.',['丫头']='丫头子:BAABKgAFFH8GAAIPAAYIyAqdBwA3AQAPAAYIyAqdBwA3AQAAAA==.',['为你']='为你喝彩:BAAAKgAECgMIAwAAAA==.为你我喜欢:BAACKgAFFH8JAAMQAAMIcBe1AgDUAAAQAAMIcBe1AgDUAAAJAAEI9QKBVwAjAAAqAAQKfxcAAxAACAjhH6oEADYCABAACAiOH6oEADYCAAkAAQgqI+OLAGIAAAAA.为你我斩杀:BAAAKgAECgcICwAAAA==.',['乔冶']='乔冶:BAABKgAFFH8GAAIRAAYIIg46AgB+AQARAAYIIg46AgB+AQAAAA==.',['乔安']='乔安:BAAAKgAFFAYIBAAAAA==.',['九五']='九五二柒:BAAAKgAECgIIAgAAAA==.',['二零']='二零七:BAAAKgAECggICAAAAA==.',['五十']='五十二日:BAABKgAECn8WAAMSAAgIYA5/KAA4AQASAAgIYA5/KAA4AQAMAAEI9QZIogAkAAAAAA==.',['亚尔']='亚尔佛莉德:BAAAKgAECgQIBAAAAA==.',['亚美']='亚美酱:BAAAKgADCggICQAAAA==.',['亚莉']='亚莉安洛德:BAAAKgAECgMIAwAAAA==.',['人像']='人像三要素:BAAAKgAFFAQIBAAAAA==.',['什么']='什么熊:BAAAKgAECggICAAAAA==.',['今天']='今天几号:BAAAKgADCggICAAAAA==.',['以德']='以德服人:BAAAKgAFFAQIAgAAAA==.',['伊莱']='伊莱尔斯:BAABKgAFFH8VAAQTAAgIMxjrEQBYAQATAAYI3RTrEQBYAQAUAAYI7wvkEgAnAQAVAAQIshbPFQC/AAAAAA==.',['伊雷']='伊雷希亚:BAAAKgAFFAYIBAAAAA==.',['伽楠']='伽楠:BAABKgAECn8nAAIWAAgI/h7aBAB+AgAWAAgI/h7aBAB+AgAAAA==.',['余小']='余小米:BAACKgAFFH8cAAIBAAQIcCDONgAPAQABAAQIcCDONgAPAQAqAAQKfy8AAgEACAhQIrIwAF8CAAEACAhQIrIwAF8CAAAA.',['你想']='你想变成光吗:BAABKgAFFH8QAAMBAAYIhhknEACdAQABAAYIhhknEACdAQAXAAYIOQImDgCaAAAAAA==.',['你给']='你给路达呦:BAAAKgAECgIIAgAAAA==.',['依依']='依依熠熠:BAAAKgAECgMIAwAAAA==.',['依旧']='依旧那个角度:BAACKgAFFH8NAAMVAAQI0xSdDADIAAAVAAMI0xSdDADIAAATAAMIuRCWIgBqAAAqAAQKfyIABBUACAitHn4iAP0BABUACAjmHH4iAP0BABMABAiRHBNCADgBABQAAQgAAEKxAAAAAAAA.',['倪好']='倪好:BAABKgAECn87AAMYAAgIOSL4AwCbAgAYAAgIOSL4AwCbAgAZAAEIsQiDMgAmAAAAAA==.',['偑衆']='偑衆仐発:BAAAKgAECgEIAQAAAA==.',['光丶']='光丶:BAAAKgAFFAIIAgAAAA==.',['光天']='光天化曰:BAAAKgAECgMIBQAAAA==.',['光祈']='光祈愿:BAAAKgADCggICAAAAA==.',['光铸']='光铸臊蹄子:BAAAKgAECgYIBgAAAA==.',['内个']='内个水木师:BAAAKgAECgYIDAAAAA==.',['军团']='军团代理人:BAAAKgADCgQIBAAAAA==.',['冰涔']='冰涔涔:BAAAKgAECggIDwAAAA==.',['冲锋']='冲锋三十八:BAAAKgADCgEIAQAAAA==.',['冲鸭']='冲鸭卡比丘:BAAAKgAECggIEAAAAA==.',['冷月']='冷月寒风:BAAAKgADCggICwAAAA==.',['冷洫']='冷洫丶:BAAAKgAFFAQIBAAAAA==.',['冷酷']='冷酷汽水:BAAAKgAFFAQIAQAAAA==.',['冻结']='冻结的时间:BAAAKgAECgcIDQAAAA==.',['凝冰']='凝冰:BAAAKgAECgEIAQAAAA==.',['凝雨']='凝雨:BAAAKgAECgMIAwAAAA==.',['凝雪']='凝雪:BAAAKgADCgUIBQAAAA==.',['凤彩']='凤彩翼:BAAAKgADCgQIBAAAAA==.',['出塞']='出塞:BAAAKgAECgMIAwAAAA==.',['刘岩']='刘岩:BAABKgAECn8oAAQRAAgIThDCEABbAQARAAgIThDCEABbAQAaAAgImA1jLADwAAAZAAEIlwNYSAAJAAAAAA==.',['别烦']='别烦夏天:BAAAKgAFFAQIAQAAAA==.',['劍來']='劍來:BAACKgAFFH8JAAMbAAgIRxEnAwAZAgAbAAgIKxEnAwAZAgAcAAEIhBiYKABOAAAqAAQKfyMAAxsACAgeJtgCAOcCABsACAgeJtgCAOcCABwABwhOHhI3AKEBAAAA.',['加罗']='加罗什:BAAAKgAECgYIBgAAAA==.',['劳伦']='劳伦斯:BAABKgAFFH8IAAMcAAgIKyGoAwBsAgAcAAcIXyKoAwBsAgAbAAEI9xkpJwBVAAAAAA==.',['十一']='十一月的肖邦:BAAAKgAECggIDQAAAA==.',['十七']='十七丶风行者:BAABKgAECn8rAAMIAAgI5iJjBADSAgAIAAgIviJjBADSAgAJAAcINRxaEwCdAQABKgAECggILAABANMiAA==.',['十九']='十九厘米:BAAAKgAECggICAAAAA==.',['单纯']='单纯小男孩:BAAAKgAFFAIIAgAAAA==.',['厄提']='厄提诺斯:BAABKgAECn8bAAMaAAgILRuSCwA6AgAaAAgILRuSCwA6AgARAAYIqRvLDQCKAQABKgAECggILAABANMiAA==.',['双刀']='双刀小游子:BAAAKgADCgMIAwAAAA==.',['取名']='取名要随机:BAABKgAFFH8IAAMcAAgIARwiBQAvAgAcAAcIghwiBQAvAgAbAAEI9hhXKABOAAAAAA==.',['只是']='只是近黄昏:BAAAKgADCgcIBwAAAA==.',['叫丶']='叫丶兽:BAABKgAECn8uAAQNAAgInh01BQArAgANAAgIhxw1BQArAgAdAAgIJRYPIAB6AQAeAAQIAAXJMABvAAAAAA==.',['叫米']='叫米幺幺零:BAAAKgAFFAMIAwAAAA==.',['可乐']='可乐不加冰丶:BAAAKgAFFAYIAQABKgAFFAgIGQABAP8eAA==.',['可莉']='可莉頑家:BAABKgAFFH8kAAMIAAcIPiMJBgAwAgAIAAcIaCEJBgAwAgAJAAYIVyM1BwDvAQAAAA==.',['台海']='台海无中线:BAAAKgAECgIIAgAAAA==.',['右手']='右手葬黎明:BAAAKgADCgQIBAAAAA==.',['司马']='司马峨嵋:BAACKgAFFH8HAAIfAAYIDRSPDAAAAQAfAAYIDRSPDAAAAQAqAAQKfxoAAx8ACAjFDkhDADMBAB8ACAjFDkhDADMBACAAAQgAAFRyAAAAAAAA.',['名字']='名字么所谓:BAAAKgAECgMIAwAAAA==.名字没所谓:BAAAKgAECgQICAAAAA==.',['君不']='君不见:BAAAKgAECgIIAgAAAA==.',['呆毛']='呆毛大魔王:BAAAKgAECgYIBgAAAA==.',['呆萌']='呆萌的小萝莉:BAABKgAFFH8GAAILAAYIOxg2DABgAQALAAYIOxg2DABgAQAAAA==.',['咘悠']='咘悠咘悠:BAABKgAECn8cAAMfAAgIExuQIQDjAQAfAAgIExuQIQDjAQAhAAEI9AEAAAAAAAAAAA==.',['哥哥']='哥哥想我吗:BAAAKgAECggICgAAAA==.',['哦是']='哦是吗:BAAAKgAFFAgIBAAAAA==.',['唔知']='唔知小旭:BAAAKgAFFAYIBAAAAA==.',['唯微']='唯微:BAAAKgAECggIEwAAAA==.',['嗜血']='嗜血丹:BAAAKgADCgcICgAAAA==.',['嘟嘟']='嘟嘟傻满丶:BAABKgAFFH8YAAQHAAYIPCN6BgDlAQAHAAYIPCN6BgDlAQAFAAQIniMTCQDmAAAGAAIIMBnoDQDIAAABKgAFFAgIFwAMAC8iAA==.',['嘻匹']='嘻匹耐:BAAAKgAFFAQIBAAAAA==.',['嚯嚯']='嚯嚯:BAAAKgADCgEIAQAAAA==.',['固定']='固定剂:BAAAKgAFFAIIAgAAAA==.',['国奶']='国奶:BAAAKgADCgEIAQAAAA==.',['圣光']='圣光大忽悠:BAAAKgAECgIIAgAAAA==.圣光胜于打码:BAABKgAECn8sAAMBAAgI0yKoBwDAAgABAAgIHCKoBwDAAgAXAAYIgSH7GwB7AQAAAA==.圣光辐射着你:BAAAKgADCggICAAAAA==.',['圣戮']='圣戮:BAAAKgADCgEIAgAAAA==.',['圣珈']='圣珈堂:BAABKgAECn9PAAMBAAgISCbkAQAOAwABAAgISCbkAQAOAwAXAAgIMx1uDgATAgAAAA==.',['坏壊']='坏壊灬孩孓气:BAABKgAFFH8aAAMFAAgIhBT7AwDjAQAFAAcICRf7AwDjAQAHAAcINRbQCAC6AQAAAA==.',['墨尔']='墨尔本菠萝:BAAAKgADCgQIBAAAAA==.',['夏日']='夏日冰爽:BAABKgAECn8UAAIaAAgIfBZkUwBkAQAaAAgIfBZkUwBkAQAAAA==.夏日海滨:BAAAKgAECgYICgAAAA==.',['夕阳']='夕阳下看海:BAAAKgAECgEIAQAAAA==.',['夜之']='夜之暗战:BAAAKgADCggICAAAAA==.夜之月:BAAAKgAECgYICAAAAA==.',['大佬']='大佬儿:BAAAKgAECggICAAAAA==.',['大坑']='大坑:BAAAKgAECgYIBgAAAA==.',['大志']='大志雷马:BAAAKgAECgYIBgAAAA==.',['大碗']='大碗卤面:BAAAKgAECggICAAAAA==.',['大蜥']='大蜥蜴:BAABKgAFFH8IAAIiAAQIdRDJEwC0AAAiAAQIdRDJEwC0AAAAAA==.',['大鼻']='大鼻子大吧:BAAAKgADCgQIBAAAAA==.',['天使']='天使魔心:BAACKgAFFH8JAAMJAAMIRxXJDwDaAAAJAAMIfhPJDwDaAAAIAAEIBRNxSABGAAAqAAQKfyUAAwkACAjAIgMKAJMCAAkACAjAIgMKAJMCAAgAAwjAConfAHAAAAAA.',['天宇']='天宇法:BAAAKgAECgYIBgAAAA==.天宇的奈飞龙:BAAAKgADCgMIAwAAAA==.天宇的瓦莉拉:BAAAKgAECgIIAgAAAA==.',['天幕']='天幕红尘:BAAAKgAECgYIEwAAAA==.',['天音']='天音化物:BAABKgAFFH8aAAMXAAgIXhcvAQCsAQAXAAgIXhcvAQCsAQAPAAMIyhcHCADWAAAAAA==.',['夶丶']='夶丶洣:BAAAKgAFFAQIBAAAAA==.',['奥丁']='奥丁的狗腿子:BAAAKgADCgIIAgAAAA==.',['奥蕾']='奥蕾赛丝:BAAAKgAECgYIBgAAAA==.',['奶似']='奶似奶非奶:BAAAKgAFFAgIAgAAAA==.',['奶奶']='奶奶呀奶奶:BAABKgAFFH8IAAIKAAgIpAb9BwCjAQAKAAgIpAb9BwCjAQAAAA==.',['威廉']='威廉凯萨琳:BAAAKgAFFAQIAwAAAA==.',['嫂子']='嫂子只疼你:BAAAKgAECgQIBAAAAA==.',['孤狼']='孤狼小猎:BAAAKgADCggICAAAAA==.',['安沫']='安沫颜:BAAAKgADCgEIAQAAAA==.',['寂末']='寂末无瞳:BAAAKgADCggICAAAAA==.',['小兵']='小兵一零四:BAAAKgAECggIDgAAAA==.',['小婧']='小婧婧:BAABKgAFFH8kAAMaAAgIACE/BQBvAgAaAAgIACE/BQBvAgARAAgI7RmhAgA5AgAAAA==.',['小小']='小小死骑士:BAAAKgADCggICAAAAA==.',['小德']='小德真好玩:BAAAKgAECgQIBAAAAA==.',['小悦']='小悦毁灭世界:BAAAKgAECgIIAgAAAA==.',['小栗']='小栗帽:BAAAKgAECgEIAQAAAA==.',['小风']='小风雪:BAAAKgADCggIHgABKgAECggILAABANMiAA==.',['尐尐']='尐尐龍兒他姐:BAAAKgADCgEIAQAAAA==.',['尐龟']='尐龟龟:BAAAKgAECgYIBgAAAA==.',['尛柚']='尛柚归来:BAAAKgADCgUIBgAAAA==.',['尛笙']='尛笙归来:BAAAKgADCgQIBAAAAA==.',['尛鑫']='尛鑫归来:BAAAKgAFFAEIAQAAAA==.',['尛饭']='尛饭归来:BAAAKgADCgQIBAAAAA==.',['就是']='就是不帅:BAAAKgADCgEIAgAAAA==.就是个干:BAAAKgAECggIDAAAAA==.就是气死你:BAABKgAECn8cAAIGAAgItRZYBgDnAQAGAAgItRZYBgDnAQAAAA==.',['屁珐']='屁珐师龚智伟:BAAAKgAECgUIBQABKgAECggILAABANMiAA==.',['岛田']='岛田邦桑迪:BAABKgAECn8UAAIEAAYI/ghDTgCuAAAEAAYI/ghDTgCuAAAAAA==.',['左手']='左手执魂:BAAAKgADCgIIBAAAAA==.',['巫毒']='巫毒箭舞:BAAAKgAECgUICAAAAA==.',['希尔']='希尔之手:BAAAKgAECggIDgABKgAECggILAABANMiAA==.希尔瓦德:BAAAKgAECgEIAQAAAA==.',['帕拉']='帕拉丁:BAABKgAFFH8IAAIBAAgIFB4yBACYAgABAAgIFB4yBACYAgAAAA==.',['帝剑']='帝剑之誓:BAAAKgADCgYIBgAAAA==.',['幽幽']='幽幽小帕布:BAAAKgADCgcICwAAAA==.',['开炮']='开炮了:BAAAKgAECggIDAAAAA==.',['张总']='张总:BAAAKgADCgMIAwAAAA==.',['張童']='張童鞋:BAAAKgAECgEIAQAAAA==.',['弹跳']='弹跳甲鱼汤:BAABKgAFFH8nAAMCAAgIyh94AgCCAgACAAgIyh94AgCCAgAEAAII3ho2CACzAAAAAA==.',['心灵']='心灵控制:BAABKgAFFH8GAAITAAMIkwuQLACxAAATAAMIkwuQLACxAAAAAA==.',['忻灬']='忻灬羽燃:BAAAKgADCgcIBwAAAA==.',['悍刀']='悍刀行:BAAAKgAECgUICAAAAA==.',['悟卩']='悟卩彡光之手:BAAAKgAECgUIBQAAAA==.',['悠悠']='悠悠我心哇:BAAAKgADCgYIBgAAAA==.',['情迷']='情迷艾玛:BAAAKgAECgUIBwAAAA==.',['慈航']='慈航道人:BAABKgAFFH8HAAIfAAcIcAmaCQA/AQAfAAcIcAmaCQA/AQAAAA==.',['慕容']='慕容玉晅:BAAAKgAECgYIBgAAAA==.慕容玉桓:BAAAKgAECggIEgAAAA==.慕容玉洹:BAAAKgAECgcIDwAAAA==.慕容玉烜:BAAAKgAECgcICAAAAA==.',['我真']='我真不会治疗:BAAAKgAFFAEIAQAAAA==.',['我瞎']='我瞎我怕谁:BAAAKgAECgUICQAAAA==.',['战隼']='战隼飯団:BAACKgAFFH8ZAAMSAAYIrRZJBgD6AAASAAQIeBxJBgD6AAAMAAII/A0+OgCVAAAqAAQKfxcAAhIACAhUFtEhAHEBABIACAhUFtEhAHEBAAAA.战隼饭団:BAABKgAFFH8LAAIOAAQIfBh8GwDHAAAOAAQIfBh8GwDHAAAAAA==.',['打不']='打不过就无敌:BAABKgAFFH8SAAMXAAYIOxjEDQAgAQAXAAYIuRPEDQAgAQABAAQIExg4HQDvAAAAAA==.',['抠脚']='抠脚大汉:BAABKgAECn8WAAIjAAgI8REsDgA6AQAjAAgI8REsDgA6AQAAAA==.',['文总']='文总:BAABKgAFFH8RAAMRAAYI+yE/BADxAQARAAYI+yE/BADxAQAaAAUIeyJ3FgBkAQABKgAFFAgIUAAaABcmAA==.',['断水']='断水流:BAAAKgAECgEIAQAAAA==.',['斯卡']='斯卡蒂:BAACKgAFFH8HAAIWAAQILiWVIQAVAQAWAAQILiWVIQAVAQAqAAQKfxQAAxYACAgLH3YpABICABYACAhxHHYpABICACQAAgjsI9khAM8AAAEqAAUUCAgLABYAOxQA.',['无奈']='无奈的山芋:BAAAKgAECggIDQAAAA==.',['无情']='无情樱花:BAAAKgAECggICAAAAA==.',['无敌']='无敌雷:BAAAKgADCggICAAAAA==.',['时空']='时空妖灵:BAAAKgAFFAIIBAAAAA==.',['旺德']='旺德发:BAAAKgADCggICAAAAA==.',['昂首']='昂首过桌底:BAAAKgADCggICAAAAA==.',['昆字']='昆字小伙:BAAAKgADCgYIBgAAAA==.',['星界']='星界游龙:BAAAKgAECggICAAAAA==.',['星缘']='星缘影子:BAAAKgAECgcICgAAAA==.星缘梦魇:BAAAKgAECgIIBAAAAA==.',['星辰']='星辰挽歌:BAAAKgADCgUIBQAAAA==.',['晓德']='晓德德:BAAAKgAECgYICQAAAA==.',['晓风']='晓风:BAABKgAECn8cAAIBAAgIPxd6GgDqAQABAAgIPxd6GgDqAQAAAA==.',['暗夜']='暗夜德弟:BAABKgAECn8XAAIRAAgI2CDBCgCAAgARAAgI2CDBCgCAAgAAAA==.',['暗影']='暗影控魔:BAAAKgADCgQICAAAAA==.',['暮雨']='暮雨亦成诗:BAAAKgAECgUIBgAAAA==.',['曓轌']='曓轌風櫊铜须:BAAAKgADCgIIAgAAAA==.',['月明']='月明花满楼:BAAAKgADCgEIAQAAAA==.',['有容']='有容有毒:BAACKgAFFH8LAAMHAAMIVQ9xMQCzAAAHAAMIVQ9xMQCzAAAFAAEItwE7KwAoAAAqAAQKfywAAgcACAhAGGc1ALEBAAcACAhAGGc1ALEBAAAA.',['未来']='未来:BAAAKgAECggIDQAAAA==.',['术梦']='术梦醒今生:BAAAKgAFFAEIAQAAAA==.',['李斯']='李斯顿飞刀:BAABKgAECn8YAAMKAAgIYiIiBgCjAgAKAAgIYiIiBgCjAgALAAUIKiBPOQBXAQABKgAECggILAABANMiAA==.',['极饿']='极饿小栗帽:BAAAKgAECggICgAAAA==.',['果果']='果果很爱你:BAAAKgADCggICAAAAA==.',['柒号']='柒号肉老板:BAAAKgAFFAQIAgAAAA==.',['柒爪']='柒爪魚:BAAAKgAFFAYIBAAAAA==.',['柳眠']='柳眠棠丶:BAAAKgAECgYIBgAAAA==.',['柳若']='柳若烟:BAAAKgAECgcIBwAAAA==.',['格拉']='格拉菲特:BAABKgAFFH8MAAIHAAYIixTwFQAsAQAHAAYIixTwFQAsAQAAAA==.',['梦魇']='梦魇死骑:BAAAKgAECggIDAAAAA==.',['森之']='森之灵羿:BAAAKgAECggICgAAAA==.森之灵翼:BAAAKgAECgYIBgAAAA==.',['森森']='森森呀:BAAAKgADCggICAAAAA==.',['楠丁']='楠丁格尔:BAACKgAFFH8eAAMBAAQIFhS1JADdAAABAAMIFhS1JADdAAAPAAMI+wm0DwCCAAAqAAQKfxwABAEACAjdE2qSAHIBAAEABwjxFmqSAHIBAA8AAghXBMlIAFgAABcAAQhqAS5kAAMAAAAA.',['樱木']='樱木花:BAAAKgAFFAMIAwAAAA==.',['樱桃']='樱桃小丸子:BAACKgAFFH8GAAIaAAMIbgxhRACcAAAaAAMIbgxhRACcAAAqAAQKfxgAAxEACAj5GUgdANwBABEACAj5GUgdANwBABoAAQgpFIXAAEEAAAAA.',['此生']='此生幸识卿:BAAAKgAFFAQIBAABKgAFFAgIIQAOAP4VAA==.',['武汉']='武汉彭于晏丶:BAAAKgAECgUIBQAAAA==.',['死亡']='死亡熊猫:BAAAKgADCggICAAAAA==.',['毒奶']='毒奶一口:BAAAKgAECgYIBgAAAA==.',['比很']='比很高还拉疯:BAAAKgADCgIIAgAAAA==.',['毛发']='毛发旺盛:BAAAKgAFFAQIBAABKgAFFAgIDgAaALMVAA==.',['水中']='水中飞舞:BAACKgAFFH8LAAIBAAQIPSFyDgAaAQABAAQIPSFyDgAaAQAqAAQKfx8AAgEACAg9IPErAFACAAEACAg9IPErAFACAAAA.',['氵阿']='氵阿嚏:BAAAKgAECgEIAgAAAA==.',['求带']='求带团长别踢:BAAAKgAECgQIBQAAAA==.',['汹涌']='汹涌如江流:BAAAKgADCggICAAAAA==.',['沃尔']='沃尔皮:BAAAKgAECgIIAgAAAA==.',['沉默']='沉默:BAAAKgAECggIEAAAAA==.',['没遮']='没遮拦丶袭人:BAABKgAECn8iAAIHAAgIShkYKwDeAQAHAAgIShkYKwDeAQAAAA==.',['治疗']='治疗漏电:BAAAKgADCgYIBgAAAA==.',['法號']='法號飄柔:BAABKgAFFH8IAAIfAAgICw/zBQC4AQAfAAgICw/zBQC4AQAAAA==.',['泥食']='泥食油大饼:BAAAKgADCggICAAAAA==.',['流浪']='流浪妖:BAABKgAECn8XAAIIAAgIihXwOgC5AQAIAAgIihXwOgC5AQAAAA==.流浪风之间:BAABKgAFFH8MAAMCAAQIRiESEADnAAACAAQIphoSEADnAAADAAQIRiGLCwDXAAAAAA==.',['海战']='海战之星:BAABKgAFFH8VAAIBAAMImyGkPQD4AAABAAMImyGkPQD4AAAAAA==.海战之盾:BAACKgAFFH8OAAIcAAMI3CBEFAAdAQAcAAMI3CBEFAAdAQAqAAQKfxQAAhwACAihIHUDALMCABwACAihIHUDALMCAAAA.',['渡鸦']='渡鸦:BAABKgAFFH8QAAMHAAgI1gtACACRAQAHAAgI1gtACACRAQAFAAQIHBB0FgDAAAAAAA==.',['湮滅']='湮滅淵:BAABKgAECn8bAAIcAAcILyFxFwAYAgAcAAcILyFxFwAYAgAAAA==.',['滚滚']='滚滚丶:BAAAKgAECgYIBgAAAA==.',['潜麝']='潜麝若尘:BAAAKgAECgEIAQAAAA==.',['火工']='火工头陀:BAAAKgADCggICAABKgAECggILAABANMiAA==.',['灬以']='灬以箭之名灬:BAAAKgADCggIEAAAAA==.',['灬刀']='灬刀尖舔血灬:BAAAKgAECgIIAgAAAA==.',['灬浅']='灬浅写丶爱:BAAAKgAECgQIBwAAAA==.',['灬須']='灬須彌的等待:BAABKgAFFH8WAAMUAAYIVhoDBADMAQAUAAYIexkDBADMAQATAAYIEhMKFABEAQAAAA==.',['灿歌']='灿歌:BAAAKgAECgQIBwAAAA==.',['烈刃']='烈刃熊熊:BAAAKgADCgYIBgAAAA==.',['無命']='無命:BAAAKgAECgYIBwAAAA==.',['焰凤']='焰凤凰:BAABKgAECn8YAAIiAAgIfhI5JACSAQAiAAgIfhI5JACSAQAAAA==.',['熟悉']='熟悉的味道丶:BAAAKgADCgIIAwAAAA==.',['爆棚']='爆棚福运侠:BAACKgAFFH8TAAIfAAMIeh+tFQD3AAAfAAMIeh+tFQD3AAAqAAQKfxgABB8ACAhcHpIMAGEBAB8ACAhcHpIMAGEBACAABggzF14xACYBACEAAQgAAG0sAAAAAAAA.',['爆炸']='爆炸头:BAABKgAFFH8GAAIWAAYIsRMAFgBsAQAWAAYIsRMAFgBsAQAAAA==.',['爱你']='爱你哟摸摸哒:BAAAKgAECgQIBQAAAA==.',['爱吃']='爱吃草莓:BAAAKgAECgcICQAAAA==.',['牛三']='牛三胖:BAAAKgAECggIDwAAAA==.',['牛爷']='牛爷:BAAAKgAECgcIBwAAAA==.',['牛犇']='牛犇犇:BAABKgAECn8iAAMBAAgIWhdWLgBcAQABAAgIWhdWLgBcAQAXAAgI9wmuLQDsAAAAAA==.',['牧之']='牧之何:BAAAKgAECgQIBAAAAA==.',['牧十']='牧十:BAAAKgAECgcIDQAAAA==.',['牧萨']='牧萨:BAAAKgAECgIIAgAAAA==.',['犀利']='犀利的反杀:BAAAKgADCgEIAQAAAA==.',['狂狼']='狂狼战:BAAAKgAECgEIAQAAAA==.',['狂野']='狂野之弦:BAAAKgAFFAIIBAAAAA==.',['狂风']='狂风骤雪:BAAAKgADCgIIAgAAAA==.',['独倚']='独倚望江楼:BAAAKgADCggICAAAAA==.',['猛练']='猛练丶自然强:BAAAKgAFFAIIAgAAAA==.',['猫不']='猫不闻水饺:BAAAKgAECgYICgAAAA==.',['猫猫']='猫猫头大侠:BAAAKgADCgYIBgAAAA==.',['王嘉']='王嘉懿丶:BAAAKgAFFAEIAQAAAA==.',['王小']='王小明丶:BAABKgAECn8tAAIMAAgIHCAuGAB0AgAMAAgIHCAuGAB0AgAAAA==.',['玖玥']='玖玥是流氓:BAAAKgAFFAYIBAAAAA==.',['玛卡']='玛卡巴卡丶:BAAAKgAECgIIAgAAAA==.',['玛塔']='玛塔多珥:BAAAKgAECgQIBAAAAA==.',['玛瑙']='玛瑙:BAACKgAFFH8kAAMRAAQIShIvEACzAAARAAQIShIvEACzAAAaAAEIFQOvMgArAAAqAAQKfx4AAxEACAilFVYzAE8BABEABwhiF1YzAE8BABkAAQg/CiI2AB0AAAAA.',['瑶瑶']='瑶瑶:BAAAKgAECgYICQAAAA==.',['瓶子']='瓶子妖:BAAAKgAECggIEwAAAA==.',['甜妹']='甜妹:BAAAKgADCggIDAAAAA==.',['甜橙']='甜橙有点甜:BAAAKgADCgEIAQAAAA==.',['番茄']='番茄:BAABKgAFFH8IAAIJAAgIXRE3BgDzAQAJAAgIXRE3BgDzAQAAAA==.',['白河']='白河奈奈佳:BAABKgAECn8WAAQBAAgIuBjuZgCOAQABAAcIxhzuZgCOAQAPAAYIkwx5KwACAQAXAAEIZAD5YgAFAAAAAA==.',['百分']='百分之十:BAAAKgAFFAMIAwAAAA==.',['皂皂']='皂皂丶:BAAAKgAFFAIIAgAAAA==.皂皂酱丶:BAAAKgAECgYIBgAAAA==.',['盗玥']='盗玥:BAAAKgAECgEIAQAAAA==.',['真志']='真志雷马:BAABKgAECn8aAAMFAAcIGxhiIwCyAQAFAAcIGxhiIwCyAQAHAAEI3w0SvwApAAAAAA==.',['睨风']='睨风:BAABKgAFFH8GAAIBAAYI4xsmaQCaAAABAAYI4xsmaQCaAAAAAA==.',['瞬刻']='瞬刻瑟瑞斯:BAAAKgAFFAQIBAAAAA==.',['知夏']='知夏:BAAAKgAECggIEAAAAA==.',['石榴']='石榴汁:BAABKgAECn8XAAMEAAgIyBiJBQAFAgAEAAgIyBiJBQAFAgACAAIIcA0mlQBgAAAAAA==.',['砍爆']='砍爆哩的头:BAAAKgAECgEIAQAAAA==.',['碳花']='碳花咪:BAAAKgAECggICwAAAA==.',['祐手']='祐手吥离:BAAAKgAECggICgAAAA==.',['空弦']='空弦:BAABKgAFFH8JAAIIAAYIKBQ4EQBuAQAIAAYIKBQ4EQBuAQABKgAFFAgIJAAIAD4jAA==.',['简单']='简单:BAACKgAFFH8GAAIEAAQIlhM7BwDOAAAEAAQIlhM7BwDOAAAqAAQKfysAAwQACAheIQ4EAKICAAQACAheIQ4EAKICAAIACAj3FoMsAMMBAAAA.',['米尔']='米尔菲斯:BAAAKgAECgYIBgAAAA==.',['糖丸']='糖丸猫豆:BAAAKgAECgMIAwAAAA==.',['糟辣']='糟辣回锅肉:BAAAKgAFFAQIBAAAAA==.',['紅法']='紅法:BAABKgAFFH8OAAMTAAgI8Bu9BABSAgATAAgIFxq9BABSAgAUAAQIehIqHwDZAAAAAA==.',['紗雾']='紗雾丶:BAAAKgADCgYIBgAAAA==.',['紫心']='紫心兰:BAABKgAFFH8MAAMJAAYIwxwHCwCmAQAJAAYIGRsHCwCmAQAIAAIIihPARACNAAAAAA==.',['絕對']='絕對牧靈:BAABKgAECn9IAAMKAAgIiCJ3AgCRAgAKAAgIiCJ3AgCRAgAlAAgIPBFNIACCAQAAAA==.',['红尘']='红尘绝世楼:BAAAKgADCgEIAQAAAA==.',['红袖']='红袖满楼招:BAAAKgAECggICQAAAA==.',['给静']='给静心买瓜子:BAAAKgADCggIEAAAAA==.',['维罗']='维罗娜拉:BAABKgAFFH8IAAIJAAgIeBO3BgD8AQAJAAgIeBO3BgD8AQAAAA==.',['维贝']='维贝:BAAAKgAECggIEwAAAA==.',['缓缓']='缓缓飘落枫叶:BAAAKgADCgQIBAAAAA==.',['网恋']='网恋骑:BAAAKgADCggIEAAAAA==.',['美女']='美女丶悠着点:BAAAKgADCgMIAwAAAA==.',['翅膀']='翅膀:BAAAKgAECgYIDQAAAA==.',['老龙']='老龙重装:BAABKgAECn8fAAMmAAgILRFTCQB8AQAmAAgILRFTCQB8AQAiAAEIvwGqZAAUAAAAAA==.',['考瓦']='考瓦斯血棘:BAAAKgAECgUIBQAAAA==.',['耶巴']='耶巴蒂:BAAAKgADCgIIAgAAAA==.',['聆听']='聆听你的声音:BAAAKgADCggICAAAAA==.',['聪明']='聪明灯:BAAAKgAFFAYIBAABKgAFFAgIJAAIAD4jAA==.',['胡子']='胡子叔叔:BAAAKgAECgEIAQAAAA==.',['能有']='能有什么办法:BAABKgAFFH8KAAMaAAYIbyVEAAAzAgAaAAYIbyVEAAAzAgARAAQIeBI1DADOAAAAAA==.',['致良']='致良知:BAABKgAECn8UAAIaAAgIFw89HABsAQAaAAgIFw89HABsAQAAAA==.',['花与']='花与虫:BAAAKgAECgMIAgAAAA==.',['苍郁']='苍郁丶:BAABKgAFFH8IAAIUAAQIWB9gGQDeAAAUAAQIWB9gGQDeAAAAAA==.',['茉莉']='茉莉美美:BAAAKgADCgMIAwAAAA==.',['莉娜']='莉娜因巴斯:BAAAKgAECggICAAAAA==.',['莫高']='莫高雷的图腾:BAABKgAFFH8FAAIHAAMIkxFKOQCdAAAHAAMIkxFKOQCdAAAAAA==.',['莱恩']='莱恩哈特:BAAAKgAFFAEIAQAAAA==.',['萌喵']='萌喵的肉球:BAAAKgAECgIIAgAAAA==.',['萌龟']='萌龟龟:BAABKgAECn8ZAAMWAAgIqx5KFgBaAgAWAAcIqx5KFgBaAgAOAAgI7hJUIABIAQAAAA==.',['蓝芷']='蓝芷鸢:BAABKgAECn8kAAMSAAgIzw5LNgDiAAASAAgIqwxLNgDiAAAMAAUIuxTlXgDSAAAAAA==.',['薇琪']='薇琪:BAABKgAECn8eAAIBAAgILh3DTwDPAQABAAgILh3DTwDPAQAAAA==.',['虹霓']='虹霓儿:BAAAKgAECgMIAwAAAA==.',['虾仁']='虾仁水饺:BAABKgAECn8XAAMJAAgIxyRTBgC+AgAJAAgINCJTBgC+AgAIAAgIGCBUHgB+AgAAAA==.',['蜜鳕']='蜜鳕:BAABKgAECn8aAAIWAAgIrBiPKQDZAQAWAAgIrBiPKQDZAQAAAA==.',['血性']='血性:BAAAKgAFFAQIBAAAAA==.',['袏手']='袏手吥弃:BAAAKgAECgQIBwAAAA==.',['西巴']='西巴里个:BAAAKgAECgUIBQAAAA==.',['要饭']='要饭没有碗:BAAAKgADCggICAAAAA==.',['角角']='角角子:BAAAKgAFFAIIAgAAAA==.',['誒扒']='誒扒武零壹:BAABKgAFFH8OAAMaAAgIsxX1DADHAQAaAAYIPx31DADHAQARAAgIoAfwCAB5AQAAAA==.',['調泄']='調泄了:BAAAKgADCgcIBwAAAA==.',['諸神']='諸神黃昏:BAAAKgAECggIEgAAAA==.',['记得']='记得奶我:BAAAKgAECgIIAgAAAA==.',['诗书']='诗书执礼:BAACKgAFFH8GAAMCAAYIEB/yFgBMAQACAAQIpR/yFgBMAQAEAAIIvxwrJABSAAAqAAQKfyUABAQACAhJGvohAHYBAAQACAhJGvohAHYBAAMABQjPE9MhAOQAAAIABAhcCwl4AKMAAAAA.',['豁酨']='豁酨偒霞:BAAAKgAECggIDgAAAA==.',['贰泉']='贰泉印月:BAAAKgAECgEIAQAAAA==.',['贼拉']='贼拉臭:BAAAKgAECggIDAAAAA==.',['超凡']='超凡骑士:BAABKgAECn8aAAMBAAgI6A77lAAjAQABAAYI/RL7lAAjAQAXAAgITwdCOgCgAAAAAA==.',['足迹']='足迹:BAAAKgADCgEIAQAAAA==.',['路人']='路人德:BAAAKgAECgUIBQAAAA==.',['蹦跶']='蹦跶嘚橙仔:BAAAKgAFFAIIBAABKgAFFAgILQAIAMMeAA==.',['轩辕']='轩辕的小圣歌:BAAAKgAFFAIIAgAAAA==.',['辣手']='辣手摧残:BAAAKgAECggIDgAAAA==.',['辣西']='辣西美黛子:BAAAKgAECgUIDAAAAA==.',['迦呐']='迦呐:BAAAKgAECggIEAAAAA==.',['逆流']='逆流一圣骑:BAABKgAECn8YAAMXAAgIxRK8EgDkAAABAAcIyxBOwAAaAQAXAAYIzxC8EgDkAAAAAA==.逆流一德:BAAAKgAECggIEAAAAA==.逆流一术:BAAAKgADCggICAAAAA==.逆流一死骑:BAAAKgAECggICwAAAA==.逆流一牧:BAABKgAECn8ZAAMlAAgIXg+ZKwB9AQAlAAgIXg+ZKwB9AQAKAAUI6R5JKQBgAQAAAA==.逆流一萨:BAABKgAECn8jAAMFAAgIUxLOEAB3AQAFAAgIUxLOEAB3AQAHAAMIHQ/HiQCaAAAAAA==.',['逸枫']='逸枫:BAAAKgAECgUIBQAAAA==.',['道友']='道友請留步:BAAAKgAECgQIDQAAAA==.',['遙遠']='遙遠的回憶:BAABKgAECn8oAAIIAAgIkRkkKwADAgAIAAgIkRkkKwADAgAAAA==.',['遠坂']='遠坂凛:BAAAKgAECgQIBAAAAA==.',['那夜']='那夜很销魂:BAAAKgAECgUIBQAAAA==.',['那尔']='那尔撒斯:BAAAKgAECgUICgAAAA==.',['鈤落']='鈤落之后:BAABKgAECn9cAAQNAAgI0SArAQCqAgANAAgI0SArAQCqAgAeAAgIyBtEAwAdAgAdAAQI/RHSKwD2AAAAAA==.',['键盘']='键盘侠:BAAAKgADCgMIAwAAAA==.',['镜花']='镜花水月楼:BAAAKgADCgcIBwAAAA==.',['长高']='长高不是事儿:BAAAKgAFFAgIBAAAAA==.',['阿克']='阿克西瓦:BAABKgAECn8ZAAQbAAgIPB5ZCwBfAgAbAAgIPB5ZCwBfAgAjAAYIZxI3JQACAQAcAAEIGQ48eQA3AAABKgAECggILAABANMiAA==.',['阿祖']='阿祖:BAAAKgAECgMIAQAAAA==.',['阿莫']='阿莫西茨林:BAAAKgAFFAgIBAAAAA==.',['陌上']='陌上人如玉:BAAAKgADCgUIBQAAAA==.',['隮涧']='隮涧槃薖:BAAAKgADCggICAAAAA==.',['雨落']='雨落傾城:BAABKgAECn8jAAMZAAgIkg6yEwAVAQAZAAgIDgyyEwAVAQAaAAUIdA1dOgCgAAAAAA==.',['雨露']='雨露甜甜:BAABKgAFFH8IAAIBAAgIARWgCQAoAgABAAgIARWgCQAoAgAAAA==.',['雨鱼']='雨鱼之战:BAAAKgAECggICAAAAA==.雨鱼之术:BAABKgAECn86AAQDAAgI8hYBCADmAQADAAgI8hYBCADmAQAEAAEIXQT2hQAZAAACAAEIAAA8TQAAAAAAAA==.雨鱼之猎:BAABKgAECn8UAAIIAAgIbB7iCQBzAgAIAAgIbB7iCQBzAgAAAA==.',['雪域']='雪域冰封:BAACKgAFFH8VAAMUAAgIABE5BgAFAgAUAAgI1BA5BgAFAgAVAAQIGSHIBgD4AAAqAAQKfxcAAxQACAgEFKk0AMUBABQACAgEFKk0AMUBABUAAQglBxSyACoAAAAA.',['雷电']='雷电斧王:BAABKgAECn8gAAIFAAgIeh8ZDACDAgAFAAgIeh8ZDACDAgABKgAECggILAABANMiAA==.',['雾里']='雾里飞花:BAAAKgAFFAMIAwAAAA==.',['霸霸']='霸霸:BAABKgAECn8WAAIdAAgIeBdJBgD/AQAdAAgIeBdJBgD/AQAAAA==.',['青霭']='青霭:BAAAKgAECgUIBQAAAA==.',['韩梅']='韩梅梅丶:BAABKgAFFH8GAAIJAAYIohH4FQA0AQAJAAYIohH4FQA0AQAAAA==.',['颜值']='颜值很重要:BAAAKgAFFAgIBAAAAA==.',['風之']='風之沙:BAABKgAFFH8JAAMIAAgIlxU2EQBuAQAIAAQIKxk2EQBuAQAJAAUIsw4KEAD4AAAAAA==.',['风凌']='风凌雪孀:BAAAKgAFFAIIAgAAAA==.',['风速']='风速疾驰:BAAAKgADCgIIAgAAAA==.',['飒飒']='飒飒萨饅:BAAAKgAECgMIAwAAAA==.',['飘浪']='飘浪小妹:BAAAKgAECggICAAAAA==.',['饿龙']='饿龙咆哮:BAAAKgADCggICAAAAA==.',['马里']='马里奥佛丁:BAAAKgADCgQIBAAAAA==.',['鬼泣']='鬼泣大叔:BAAAKgADCggICAAAAA==.',['魔幻']='魔幻之旅:BAABKgAECn9VAAMIAAgIziUTAgAAAwAIAAgIziUTAgAAAwAJAAIIbxcoZwCMAAAAAA==.',['魚乱']='魚乱丢:BAAAKgADCggICAAAAA==.',['黑千']='黑千鸟:BAAAKgAECggICAAAAA==.',['黑塔']='黑塔:BAAAKgAECggICAAAAA==.',['黑巧']='黑巧闪闪:BAACKgAFFH8JAAQLAAYInRB6DgDJAAALAAUI6wV6DgDJAAAKAAIIIxatGwCOAAAlAAII3AV0IwBPAAAqAAQKfxwABCUACAh+GbsZAAkCACUACAh+GbsZAAkCAAoABAh3GhtSAM8AAAsAAQjlFOuOAD0AAAAA.',['黑暗']='黑暗丶欣:BAAAKgAECgUICgAAAA==.',['黑珍']='黑珍珠:BAAAKgAECgEIAQAAAA==.',['黑脸']='黑脸窦豆:BAAAKgAFFAEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end