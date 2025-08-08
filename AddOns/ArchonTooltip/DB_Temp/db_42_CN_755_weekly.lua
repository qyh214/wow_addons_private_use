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
 local lookup = {'Druid-Balance','Druid-Feral','Unknown-Unknown','Priest-Shadow','Priest-Discipline','Paladin-Retribution','Shaman-Restoration','Paladin-Protection','DeathKnight-Blood','DeathKnight-Unholy','Rogue-Assassination','Rogue-Subtlety','Mage-Fire','Priest-Holy','Shaman-Enhancement','Shaman-Elemental','Mage-Arcane','DemonHunter-Havoc','Druid-Restoration','Paladin-Holy','Hunter-BeastMastery','DemonHunter-Vengeance','Druid-Guardian','Hunter-Marksmanship','Rogue-Outlaw','DeathKnight-Frost','Mage-Frost','Evoker-Devastation','Warlock-Destruction','Warlock-Affliction',}; local provider = {region='CN',realm='狂风峭壁',name='CN',type='weekly',zone=42,date='2025-08-08',data={Bl='Blacklilas:BAAAKgAECgIIAwAAAA==.',Ce='Celestia:BAAAKgAECgYICQAAAA==.',Da='Danai:BAAAKgAFFAQIBAAAAA==.',De='Devilman:BAAAKgAECggICAAAAA==.',Ei='Eilenngu:BAAAKgAECgMIAwAAAA==.',Ho='Holydruid:BAACKgAFFH8KAAIBAAQIhRRNNADJAAABAAQIhRRNNADJAAAqAAQKfxsAAwEACAjSHKMpAAwCAAEACAiXGqMpAAwCAAIABAikFoMWABYBAAEqAAUUCAgEAAMAAAAA.Holyevoker:BAAAKgAFFAEIAQABKgAFFAgIBAADAAAAAA==.Holyress:BAABKgAECn8YAAMEAAgIeBkXCQAdAgAEAAgIeBkXCQAdAgAFAAgIeRfGBwDlAQABKgAFFAgIBAADAAAAAA==.Holyshm:BAAAKgAFFAgIBAAAAA==.Homelander:BAAAKgADCgEIAQAAAA==.',Me='Messi:BAABKgAFFH8KAAIGAAYIZh1cAQDkAQAGAAYIZh1cAQDkAQAAAA==.',Mv='Mvp:BAABKgAFFH8PAAIHAAMI0wa0PQCRAAAHAAMI0wa0PQCRAAAAAA==.',Sv='Svip:BAABKgAFFH8dAAMIAAUIOBmaEQD0AAAIAAUInhiaEQD0AAAGAAQICRJEJgDOAAAAAA==.',Sw='Swankeys:BAAAKgADCgIIAgAAAA==.',Vi='Vip:BAACKgAFFH8yAAMJAAYIChdBDQBCAQAJAAYIWhVBDQBCAQAKAAQIbRH5MQDMAAAqAAQKfyYAAwkACAhTFdQIAJwBAAkACAhTFdQIAJwBAAoABQjvB3CaAJsAAAAA.',['Äö']='Äöäöä:BAABKgAFFH8UAAMLAAgIkRtjAAAeAgALAAgIkRtjAAAeAgAMAAIISBGeDwBTAAAAAA==.',['一为']='一为了孩子:BAAAKgAECgYIDAAAAA==.',['一亿']='一亿年太久:BAAAKgAECgcIBwAAAA==.',['一修']='一修罗一:BAABKgAFFH8MAAIKAAgIiAjPBwDLAQAKAAgIiAjPBwDLAQAAAA==.',['三十']='三十六的汉子:BAAAKgAECgcIEwAAAA==.',['不可']='不可驯服:BAAAKgAFFAQIBAAAAA==.',['丑爆']='丑爆了:BAAAKgADCggIEgAAAA==.',['丨聖']='丨聖光將熄丨:BAAAKgAECgYIBgAAAA==.',['丨血']='丨血染征袍丨:BAAAKgAECgYIBgAAAA==.',['丿亚']='丿亚丝娜丶:BAAAKgADCggIEAAAAA==.',['乖猪']='乖猪:BAAAKgAFFAQIBAABKgAFFAgIDgANAMMiAA==.',['二十']='二十七的妹子:BAAAKgAECgcIEAAAAA==.',['佳缘']='佳缘菠菜:BAAAKgAECggICwAAAA==.',['俺莲']='俺莲莲:BAABKgAECn8XAAIOAAgIjgE9hQBWAAAOAAgIjgE9hQBWAAAAAA==.',['倩女']='倩女幽玺:BAAAKgADCggICAAAAA==.',['偶尔']='偶尔忘喘气:BAAAKgAECgEIAQAAAA==.',['克里']='克里斯丁雷:BAABKgAFFH8GAAIGAAYIYRUoIwBfAQAGAAYIYRUoIwBfAQAAAA==.',['八奈']='八奈见杏菜丶:BAABKgAFFH8OAAMPAAcI6hS6AQC8AQAPAAcI6hS6AQC8AQAHAAQI3AgxGgC6AAABKgAFFAgIBAADAAAAAA==.',['冰蓝']='冰蓝冰:BAAAKgADCgUIBQAAAA==.',['冰霜']='冰霜之怒:BAAAKgAECgYIBgAAAA==.',['别顶']='别顶嘴会挨揍:BAABKgAFFH8KAAMHAAQI3Qe6GADBAAAHAAQI3Qe6GADBAAAQAAMIUQmsGgClAAABKgAFFAgIBAADAAAAAA==.',['功夫']='功夫高手:BAAAKgADCggICAAAAA==.',['北斗']='北斗灬炫宇:BAAAKgAECgIIAgAAAA==.',['千风']='千风六月:BAABKgAFFH8KAAMNAAYI1xSgGwDOAAANAAYI1xSgGwDOAAARAAQIrAroMQCcAAAAAA==.',['半巨']='半巨人不怒:BAABKgAFFH8IAAISAAgIdBMBCAAQAgASAAgIdBMBCAAQAgAAAA==.',['南域']='南域神骑:BAABKgAFFH8GAAIGAAMIfgcQYACwAAAGAAMIfgcQYACwAAAAAA==.',['卧龙']='卧龙:BAAAKgADCggICAAAAA==.',['发姐']='发姐:BAAAKgADCgMIAwAAAA==.',['含笑']='含笑半步癫:BAAAKgADCggICAAAAA==.',['啊哩']='啊哩哩啊哩哩:BAABKgAECn8qAAITAAgIvAG1aQBQAAATAAgIvAG1aQBQAAAAAA==.',['啊牛']='啊牛哥:BAABKgAECn8xAAMUAAgINwL1RAB1AAAUAAgINwL1RAB1AAAIAAgISAJ+UAA/AAAAAA==.',['国产']='国产奶骑:BAAAKgADCggIEAAAAA==.',['堕天']='堕天:BAAAKgAFFAQIBAAAAA==.堕天丿:BAAAKgAECgYIBgAAAA==.堕天丿丿伊人:BAAAKgAECgcICgAAAA==.',['塔姆']='塔姆:BAAAKgAECgEIAQAAAA==.',['夏木']='夏木木丶:BAABKgAFFH8IAAIVAAQIGA1lOgCxAAAVAAQIGA1lOgCxAAAAAA==.',['大叔']='大叔就是好:BAAAKgAECgYICgAAAA==.大叔铛铛:BAAAKgAECgYIBgAAAA==.',['大块']='大块魔光碎片:BAAAKgAECgEIAQAAAA==.',['大德']='大德魔光碎片:BAABKgAECn8VAAMBAAgILhPPRwCNAQABAAgILhPPRwCNAQATAAcI3Ap6QgAFAQAAAA==.',['大灰']='大灰狼敲你门:BAAAKgAECggICAAAAA==.',['大炮']='大炮可可:BAAAKgAFFAQIBAAAAA==.',['大熊']='大熊比较懒:BAAAKgAFFAgIBAAAAA==.',['大牧']='大牧魔光碎片:BAAAKgAECggICQAAAA==.',['大白']='大白居:BAAAKgADCgYIBgAAAA==.',['大舅']='大舅哥:BAAAKgAECgMIAwAAAA==.',['天上']='天上九头鸟:BAAAKgADCgIIAgAAAA==.',['天涯']='天涯小牧:BAAAKgADCggICAAAAA==.天涯小龙:BAAAKgADCggICAAAAA==.',['太阳']='太阳神之女:BAAAKgAECgYICQAAAA==.',['失误']='失误术:BAAAKgAFFAQIBAAAAA==.',['奈特']='奈特麦尔:BAABKgAFFH8OAAQOAAgIuBdoBgDLAQAOAAgILxJoBgDLAQAFAAQIbB8dBwAlAQAEAAEI0xLjKgBHAAAAAA==.',['奥德']='奥德彪洗地毯:BAABKgAFFH8VAAIBAAYIMCOmDADMAQABAAYIMCOmDADMAQAAAA==.',['她恨']='她恨我:BAAAKgAECgQIBAAAAA==.',['妹子']='妹子请你睡觉:BAABKgAECn8jAAMWAAgIaQSITAB5AAAWAAgI4QOITAB5AAASAAUIyATATABIAAAAAA==.',['安东']='安东尼狂风:BAABKgAFFH8FAAIHAAUIaA/ZDwBYAQAHAAUIaA/ZDwBYAQAAAA==.',['小只']='小只芽:BAAAKgAECgUIBQAAAA==.',['小咣']='小咣咣:BAAAKgAFFAQIBAAAAA==.',['小德']='小德德:BAABKgAFFH8GAAITAAYI6wjUDgAqAQATAAYI6wjUDgAqAQAAAA==.',['小母']='小母牛坐火箭:BAABKgAFFH8lAAQBAAQIBhQTGgDYAAABAAQIBhQTGgDYAAAXAAMI1grvCQBxAAATAAIIkAGHGgAgAAAAAA==.',['小箜']='小箜箜:BAAAKgAFFAgIBAAAAA==.',['形影']='形影相随:BAAAKgAECgMIAwAAAA==.',['彩羽']='彩羽恶魔:BAABKgAFFH8IAAIBAAgIQgy2CgDjAQABAAgIQgy2CgDjAQAAAA==.',['得加']='得加钱:BAAAKgADCggICAAAAA==.',['忆云']='忆云:BAAAKgADCgQIBAAAAA==.',['恐怖']='恐怖小说:BAAAKgAFFAMIAwAAAA==.',['感灬']='感灬恩:BAAAKgAECgIIAgAAAA==.',['我儿']='我儿王腾:BAAAKgADCggICAAAAA==.',['我来']='我来抗揍:BAABKgAFFH8LAAIKAAIIeB06HQCxAAAKAAIIeB06HQCxAAAAAA==.',['战场']='战场原黑仪:BAAAKgADCggICAAAAA==.',['扶器']='扶器:BAAAKgAECgMIAwAAAA==.',['拉米']='拉米亚斯:BAABKgAFFH8IAAMYAAQIsx8EBQAkAQAYAAQIsx8EBQAkAQAVAAQI9wnqIgDLAAAAAA==.',['暖阳']='暖阳妮娜:BAAAKgAECggICAAAAA==.',['暮岚']='暮岚寒枫:BAAAKgAECgcICAAAAA==.',['暮雨']='暮雨朝露:BAAAKgADCggICAAAAA==.',['木子']='木子:BAAAKgAECgcIEgAAAA==.',['未语']='未语人先羞:BAABKgAECn8UAAIHAAcIHgEdtAA7AAAHAAcIHgEdtAA7AAAAAA==.',['李与']='李与刘:BAAAKgADCgEIAQAAAA==.',['柳如']='柳如烟:BAAAKgAECgYIBgAAAA==.',['栽培']='栽培:BAAAKgAECggICgAAAA==.',['桉树']='桉树叶:BAAAKgAECggIBAAAAA==.',['棉花']='棉花棒棒:BAAAKgAECgYIBgAAAA==.',['水深']='水深:BAABKgAFFH8FAAIZAAMIKAq9BgCmAAAZAAMIKAq9BgCmAAAAAA==.',['治安']='治安战:BAAAKgAFFAQIBAAAAA==.',['洛扬']='洛扬:BAAAKgAECgYIBgAAAA==.',['海兰']='海兰儿:BAAAKgAECgQIBgAAAA==.',['清水']='清水加冰:BAAAKgAECgEIAQAAAA==.',['满月']='满月寂照:BAAAKgAFFAQIBAAAAA==.',['潴潴']='潴潴嫒你:BAAAKgADCggICAAAAA==.',['灬彼']='灬彼得堡:BAAAKgAECgYIBgAAAA==.',['灬转']='灬转弯的箭:BAAAKgADCggICAAAAA==.',['灵光']='灵光幻影:BAAAKgAECgYIBgAAAA==.',['烦奇']='烦奇:BAAAKgAECggIDQAAAA==.',['爱上']='爱上夏天的蕓:BAABKgAFFH8PAAIGAAcIPxrWCAA4AQAGAAcIPxrWCAA4AQAAAA==.',['爱原']='爱原始森林:BAABKgAECn8bAAIOAAgIRgfzUwDqAAAOAAgIRgfzUwDqAAAAAA==.',['爱雪']='爱雪花飘:BAABKgAECn8sAAMaAAgIkALKLwBdAAAaAAcImwLKLwBdAAAJAAUICAIjVgAgAAAAAA==.',['爱高']='爱高山:BAAAKgAECggIEQAAAA==.',['爺们']='爺们:BAAAKgAECgQIBAAAAA==.',['狂暴']='狂暴的鹌鹑:BAAAKgADCggICAAAAA==.',['猎鬼']='猎鬼:BAAAKgAFFAQIBAAAAA==.',['玄幻']='玄幻小说:BAABKgAFFH8NAAMRAAMIIhl1IgDbAAARAAMIiBd1IgDbAAAbAAMIHxSgFwC3AAAAAA==.',['玄烨']='玄烨:BAAAKgADCgQIBAAAAA==.',['王珊']='王珊琪女王:BAABKgAFFH8HAAIBAAYI8QuzEQBIAQABAAYI8QuzEQBIAQAAAA==.',['玥鵺']='玥鵺:BAAAKgADCggICAAAAA==.',['璋琅']='璋琅:BAAAKgAECgEIAQAAAA==.',['疯狂']='疯狂的韭菜:BAABKgAECn8aAAMTAAgI8BSCHwChAQATAAgI8BSCHwChAQAXAAUI/xL6FAAHAQAAAA==.',['白发']='白发灬魔女:BAAAKgADCgYIBgAAAA==.',['相逢']='相逢:BAAAKgADCggICAAAAA==.',['看灬']='看灬:BAAAKgAECgEIAQAAAA==.',['神经']='神经蛋白质:BAAAKgADCggICAAAAA==.',['福森']='福森:BAAAKgADCggICAAAAA==.',['秦少']='秦少游:BAABKgAFFH8GAAINAAYIcSGKCAC8AQANAAYIcSGKCAC8AQABKgAFFAgICgAbALglAA==.',['笑笑']='笑笑熊:BAAAKgAECgQIBQAAAA==.',['筒二']='筒二爷:BAABKgAECn8UAAMHAAgIxBWRQQBwAQAHAAgIxBWRQQBwAQAQAAYIzxPjTADMAAAAAA==.',['筒子']='筒子哥:BAAAKgAECgUIBQAAAA==.',['索瑞']='索瑞森大帝:BAABKgAFFH8IAAMJAAYIgRyqCACPAQAJAAYIgRyqCACPAQAKAAIInAU9KwBuAAAAAA==.',['纳兹']='纳兹乌罗:BAABKgAFFH8FAAIcAAUImhffFQAcAQAcAAUImhffFQAcAQAAAA==.',['终极']='终极紫微星:BAAAKgADCggICAAAAA==.',['给点']='给点吧:BAAAKgAECgIIAQAAAA==.',['美羊']='美羊羊:BAAAKgAECgcIDQAAAA==.',['胎哥']='胎哥:BAAAKgAFFAIIAgAAAA==.',['臊德']='臊德一:BAAAKgADCgIIAgAAAA==.',['舞清']='舞清影:BAAAKgAECgcICAAAAA==.',['艾儿']='艾儿西丝:BAABKgAFFH8GAAIHAAYImAXBGwAPAQAHAAYImAXBGwAPAQAAAA==.',['苏咔']='苏咔咘咧丶:BAAAKgAFFAQIAgAAAA==.',['苏摩']='苏摩丶:BAABKgAFFH8FAAMdAAIIIBnrIACNAAAdAAIIIBnrIACNAAAeAAEI8A0nJQA6AAAAAA==.',['荒野']='荒野大镖客:BAAAKgAECgYIBgAAAA==.',['萨摩']='萨摩耶:BAAAKgAECgUIBQAAAA==.',['蒼萤']='蒼萤:BAAAKgAECgYIBgAAAA==.',['蓝色']='蓝色灬晨曦:BAAAKgAECggICAAAAA==.',['藏藏']='藏藏:BAACKgAFFH8rAAIGAAUI3BfhGQAXAQAGAAUI3BfhGQAXAQAqAAQKfxcAAgYACAjJHaloAIkBAAYACAjJHaloAIkBAAAA.',['蜜蜂']='蜜蜂逛花海:BAAAKgAECgIIAgAAAA==.',['象征']='象征高贵:BAAAKgAFFAgIBAAAAA==.',['赵兄']='赵兄:BAAAKgADCgQIBAAAAA==.',['迈克']='迈克沃尔夫:BAAAKgAECgUIBQAAAA==.',['速猛']='速猛萨:BAABKgAFFH8PAAIHAAQIsRdHFgDMAAAHAAQIsRdHFgDMAAAAAA==.',['道友']='道友剑影:BAAAKgAECgMIBAAAAA==.道友闻香:BAAAKgAECggICAAAAA==.道友魔刃:BAAAKgADCgIIAgAAAA==.',['销魂']='销魂小蜜:BAAAKgADCggICAAAAA==.',['随便']='随便玩玩儿:BAACKgAFFH8MAAIGAAMIWhzoMgClAAAGAAMIWhzoMgClAAAqAAQKfycAAgYACAiwH6ktAGkCAAYACAiwH6ktAGkCAAAA.',['雪露']='雪露诺姆:BAAAKgAECggICAAAAA==.',['韭菜']='韭菜炒鸡蛋:BAACKgAFFH8uAAMJAAcIZSTHAwAgAgAJAAYI5yTHAwAgAgAKAAEI2yHnTQBnAAAqAAQKfzYAAwoACAiRJb8IAMwCAAoACAiRJb8IAMwCAAkACAjWG78PAPsBAAAA.',['風雲']='風雲随风飘逝:BAAAKgADCgcIBwAAAA==.',['风弈']='风弈:BAAAKgADCgQIBAAAAA==.',['风神']='风神戏妖怪:BAAAKgAECgUIBQAAAA==.',['风笛']='风笛:BAAAKgAECgQIBAAAAA==.',['魔道']='魔道深渊:BAAAKgADCgIIAgAAAA==.',['魔鬼']='魔鬼大娃娃:BAAAKgAECgYIBgAAAA==.',['黑棺']='黑棺丶:BAAAKgAFFAIIAgAAAA==.',['黛丽']='黛丽靃本:BAAAKgADCgEIAQAAAA==.',['龙人']='龙人:BAAAKgAECggIDwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end