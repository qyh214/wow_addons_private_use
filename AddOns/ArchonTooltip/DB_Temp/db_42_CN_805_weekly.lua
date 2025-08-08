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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Monk-Mistweaver','Monk-Windwalker','Evoker-Devastation','Druid-Restoration','Druid-Balance','Shaman-Restoration','Hunter-BeastMastery','Warlock-Destruction','DeathKnight-Blood','DeathKnight-Unholy','Priest-Discipline','Priest-Shadow','Warrior-Fury','Shaman-Elemental','Warlock-Demonology','Warrior-Arms','Rogue-Assassination','Hunter-Marksmanship','DemonHunter-Vengeance','Warrior-Protection','Paladin-Holy','Monk-Brewmaster','DemonHunter-Havoc','Mage-Arcane','Druid-Guardian','DeathKnight-Frost','Mage-Fire','Shaman-Enhancement','Priest-Holy','Warlock-Affliction','Mage-Frost','Rogue-Subtlety','Evoker-Preservation','Hunter-Survival',}; local provider = {region='CN',realm='芬里斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aaffkk:BAABKgAFFH8cAAMBAAcIJxb+EwBeAQABAAYIohf+EwBeAQACAAEIwA4cFABFAAAAAA==.',Al='Alear:BAAAKgAECgIIAgAAAA==.Alien:BAAAKgAFFAYIBAAAAA==.',An='Anberlin:BAACKgAFFH8IAAIDAAIIVwzeIwB3AAADAAIIVwzeIwB3AAAqAAQKfxsAAwMACAjEFMUlAMkBAAMACAjEFMUlAMkBAAQABwg/GYEcALoBAAAA.',Ap='Apptt:BAABKgAFFH8GAAIFAAYIiiDUCQDXAQAFAAYIiiDUCQDXAQAAAA==.',Ay='Ayu:BAAAKgAECgQIBAAAAA==.',Be='Bestdd:BAAAKgAFFAQIBAAAAA==.',Bl='Blackforest:BAABKgAFFH8PAAIBAAgIJyX5BQBsAgABAAgIJyX5BQBsAgAAAA==.Bldh:BAAAKgADCggICAAAAA==.Blqs:BAAAKgAECgYIBgAAAA==.Blws:BAAAKgAECgUIBwAAAA==.Blxd:BAABKgAECn8UAAMGAAYI7BMkPQAeAQAGAAYI7BMkPQAeAQAHAAUIkg35iQC8AAAAAA==.',Bs='Bsp:BAABKgAECn8dAAIIAAgIPhM+NAC2AQAIAAgIPhM+NAC2AQAAAA==.',Ca='Calliope:BAABKgAECn8VAAIJAAgIGSUmCQDZAgAJAAgIGSUmCQDZAgAAAA==.',Cc='Ccy:BAAAKgADCggICAAAAA==.',Da='Darknight:BAABKgAFFH8SAAIBAAMIAhtGSQDcAAABAAMIAhtGSQDcAAAAAA==.Darkranger:BAABKgAFFH8GAAIKAAYIAgz9GQA1AQAKAAYIAgz9GQA1AQAAAA==.Dawnarrived:BAAAKgAECgEIAQAAAA==.',Dd='Ddaacc:BAAAKgAECggIDwAAAA==.Ddffkk:BAAAKgAFFAIIAgABKgAFFAcIHAABACcWAA==.',De='Deathspectre:BAAAKgADCgIIAgAAAA==.',Dm='Dmt:BAAAKgAECgcIEAAAAA==.Dmtd:BAAAKgADCgEIAgAAAA==.Dmtdd:BAAAKgAECgcICgAAAA==.Dmtqs:BAAAKgADCggICAAAAA==.Dmtsm:BAABKgAECn8eAAIIAAYIyQ+qdADQAAAIAAYIyQ+qdADQAAAAAA==.Dmtxd:BAAAKgADCgMIAwAAAA==.',Dr='Dremlock:BAAAKgADCgYIBgAAAA==.',Ea='Eaffkk:BAAAKgAFFAIIAgABKgAFFAcIHAABACcWAA==.',En='Enigma:BAAAKgAFFAgIAgAAAA==.',Ev='Eva:BAABKgAFFH8GAAIGAAYIFR0QBQCfAQAGAAYIFR0QBQCfAQAAAA==.',Fe='Felstriker:BAAAKgAECgQIBAAAAA==.',Fl='Flenjoy:BAAAKgAFFAQIBAAAAA==.Flora:BAAAKgAECggIDgAAAA==.',Fs='Fs:BAAAKgADCggICAAAAA==.',He='Herrsaal:BAAAKgADCgYIBgAAAA==.',Ho='Hotpp:BAACKgAFFH8PAAILAAQIRQTSEABtAAALAAQIRQTSEABtAAAqAAQKfx8AAgsACAg/CCo2APAAAAsACAg/CCo2APAAAAAA.Houtui:BAAAKgADCgEIAQAAAA==.',Ik='Ikunc:BAABKgAFFH8MAAIBAAgIpBQPCgAjAgABAAgIpBQPCgAjAgAAAA==.',Je='Jet:BAAAKgAFFAQIBAAAAA==.Jetaime:BAACKgAFFH8GAAIBAAQIBiMVCAA9AQABAAQIBiMVCAA9AQAqAAQKfx0AAgEACAgPJIgVAMECAAEACAgPJIgVAMECAAAA.',Ka='Kami:BAAAKgADCgMIAwAAAA==.',La='Ladderfour:BAAAKgAECgUIBgAAAA==.',Le='Leandizon:BAAAKgADCgEIAQAAAA==.Leslie:BAABKgAFFH8OAAIIAAgIURYdBQAGAgAIAAgIURYdBQAGAgAAAA==.',Lo='Lokilo:BAAAKgADCgEIAQAAAA==.',Mi='Michelle:BAABKgAFFH8IAAIMAAgI7w+EBgD3AQAMAAgI7w+EBgD3AQAAAA==.',Re='Redback:BAAAKgAFFAYIBAAAAA==.',Sl='Slken:BAAAKgADCgIIAgAAAA==.',So='Soholy:BAAAKgADCggICAAAAA==.Sokko:BAAAKgAFFAQIBAAAAA==.Somoo:BAAAKgADCggICAAAAA==.',St='Stirke:BAACKgAFFH8HAAIBAAYI7SNcDgDxAQABAAYI7SNcDgDxAQAqAAQKfxgAAgEACAgIFSuKADkBAAEACAgIFSuKADkBAAAA.',Su='Suge:BAAAKgADCgEIAQAAAA==.Suiyi:BAAAKgAECgEIAQAAAA==.Superdruid:BAABKgAFFH8OAAMGAAYIyBPXAgBdAQAGAAQIsw3XAgBdAQAHAAIIPCWALgDZAAAAAA==.Sutee:BAAAKgAECgEIAQAAAA==.',Tj='Tjydbp:BAABKgAFFH8GAAIBAAYILhYCHACEAQABAAYILhYCHACEAQAAAA==.',Un='Unicorns:BAAAKgAECgYICwAAAA==.',Vi='Villana:BAAAKgAFFAIIAgAAAA==.',Xi='Xiaozhengtai:BAAAKgAECgIIAgAAAA==.',Ze='Zemifull:BAAAKgADCggICAAAAA==.',['一之']='一之小狐狸:BAAAKgADCgYIBgAAAA==.',['一代']='一代英雄:BAAAKgAECgUIBgAAAA==.',['一傻']='一傻的可爱一:BAAAKgADCgIIAgAAAA==.',['一只']='一只熊怪:BAAAKgADCggICAAAAA==.',['一段']='一段青春:BAAAKgAECgcICwAAAA==.',['一百']='一百只能一次:BAAAKgADCgUIBQAAAA==.',['一般']='一般我不狗叫:BAAAKgADCgEIAQAAAA==.',['一袋']='一袋米抗几楼:BAAAKgADCggICAAAAA==.',['一队']='一队小猎:BAAAKgADCgMIAwAAAA==.',['三分']='三分鐘熱度:BAABKgAFFH8IAAIBAAgICBX3CgAXAgABAAgICBX3CgAXAgAAAA==.',['三羧']='三羧酸循环:BAAAKgAECggICQAAAA==.',['上去']='上去就一镐把:BAABKgAFFH8JAAIBAAYIYBIGAwCqAQABAAYIYBIGAwCqAQAAAA==.',['上善']='上善丶若水:BAABKgAFFH8PAAMNAAgI9xiYBAAAAgANAAgI9xiYBAAAAgAOAAEIdAOgKQA9AAAAAA==.',['不乛']='不乛晓得:BAABKgAECn8gAAIGAAgIvCGjAwCBAgAGAAgIvCGjAwCBAgAAAA==.',['不学']='不学无术丶:BAAAKgADCgMIAwAAAA==.',['不懂']='不懂殇:BAABKgAFFH8GAAIKAAYIqhnOSABHAAAKAAYIqhnOSABHAAAAAA==.',['不服']='不服来扔点:BAABKgAFFH8WAAIEAAYIoxvxAQC7AQAEAAYIoxvxAQC7AQAAAA==.',['不装']='不装逼的人:BAAAKgAECgUIBgAAAA==.',['丢失']='丢失的回忆:BAABKgAECn8gAAIPAAgI2A+vMwCyAQAPAAgI2A+vMwCyAQAAAA==.',['丨丶']='丨丶迷你牛牛:BAAAKgADCgUIBQAAAA==.丨丶迷失:BAAAKgADCgMIBAAAAA==.丨丶迷奇:BAAAKgADCggIDAAAAA==.丨丶迷妮:BAAAKgADCgQIBAAAAA==.丨丶迷心:BAAAKgADCgcIBwAAAA==.丨丶迷惘:BAAAKgADCgIIAgAAAA==.丨丶迷途:BAAAKgADCggIEAAAAA==.丨丶迷雾:BAAAKgADCgcIBwAAAA==.',['丨徳']='丨徳玛西亚:BAABKgAFFH8HAAIQAAMIdB6QDAAIAQAQAAMIdB6QDAAIAQAAAA==.丨徳玛酉亚:BAABKgAFFH8NAAMKAAMIcx+qIQD6AAAKAAMIcx+qIQD6AAARAAEImA74FgBDAAABKgAFFAgIDwAKAJIcAA==.',['丨德']='丨德玛酉亚:BAAAKgAFFAQIBAAAAA==.',['丨柳']='丨柳如烟:BAABKgAFFH8IAAIMAAgIZhQ/CAALAgAMAAgIZhQ/CAALAgAAAA==.',['中二']='中二粥:BAAAKgAECgEIAQABKgAFFAgIBgAGAOUQAA==.',['丶冫']='丶冫氵灬伸:BAAAKgADCggICQAAAA==.',['丶天']='丶天朝战神:BAAAKgAECggICAAAAA==.',['丶战']='丶战:BAABKgAFFH8NAAMPAAYIPRX0DQBzAQAPAAYIfxL0DQBzAQASAAQIohCBBwDxAAAAAA==.',['丶报']='丶报国名媛:BAAAKgAECgUIBQAAAA==.',['丶萌']='丶萌萌的:BAABKgAFFH8IAAIIAAgI5AF9DgBpAQAIAAgI5AF9DgBpAQAAAA==.',['为了']='为了馒头:BAAAKgAECgQIBAAAAA==.',['丿牛']='丿牛犇:BAAAKgAECgUICAAAAA==.',['丿老']='丿老北鼻:BAAAKgADCggICAAAAA==.',['二四']='二四年的尾巴:BAAAKgAECgEIAQAAAA==.',['二条']='二条园子:BAAAKgAECgQIBAAAAA==.',['云雾']='云雾:BAAAKgAECgIIAgAAAA==.',['五琼']='五琼浆:BAAAKgAECggIEgAAAA==.',['京小']='京小贱:BAAAKgAECgUIBQAAAA==.',['人來']='人來人往:BAAAKgADCgcIBwAAAA==.',['人可']='人可擎天:BAAAKgAECggICAAAAA==.',['人字']='人字拖贼:BAABKgAFFH8FAAITAAUI8xASCgD1AAATAAUI8xASCgD1AAAAAA==.',['仁智']='仁智勇:BAAAKgAFFAEIAQAAAA==.',['今戈']='今戈:BAAAKgADCgIIAgAAAA==.',['仨瓜']='仨瓜俩枣:BAAAKgADCgIIAgAAAA==.',['价值']='价值时光:BAAAKgADCgIIAgAAAA==.',['伊利']='伊利达雷之刃:BAAAKgADCgQIBAAAAA==.',['众淼']='众淼竞技灬圣:BAAAKgAECggIEgAAAA==.',['会游']='会游泳的猪:BAAAKgADCgIIAgAAAA==.',['何发']='何发财:BAAAKgAECggICAAAAA==.',['佛丁']='佛丁的西瓜刀:BAAAKgADCggICAAAAA==.',['你上']='你上我殿后:BAABKgAFFH8IAAMJAAQIORIcPACrAAAJAAQI9wocPACrAAAUAAQIXw+TNQCdAAAAAA==.',['你丑']='你丑你先睡:BAAAKgADCgIIAgAAAA==.你丑没事:BAABKgAFFH8GAAIVAAMI4gHbIQBVAAAVAAMI4gHbIQBVAAAAAA==.',['你跟']='你跟我闹呢:BAABKgAFFH8OAAIBAAYIoCE3EgDLAQABAAYIoCE3EgDLAQABKgAFFAgIDAAMAPURAA==.你跟谁撒娇呢:BAAAKgAECggICAAAAA==.',['你需']='你需要进食:BAABKgAFFH8JAAIPAAMI2guJIwDEAAAPAAMI2guJIwDEAAAAAA==.',['佳期']='佳期若梦丶:BAABKgAFFH8RAAIIAAUI4CMRDACHAQAIAAUI4CMRDACHAQABKgAFFAcIGwAIAIkbAA==.',['信仰']='信仰喵喵:BAABKgAFFH8PAAIBAAgIZh7yFQCsAQABAAgIZh7yFQCsAQAAAA==.',['修罗']='修罗魔帝:BAAAKgAECgUIEAAAAA==.',['做一']='做一休三:BAAAKgADCggICAAAAA==.',['偶尔']='偶尔玩:BAABKgAECn8YAAIBAAgIoRhTUgD9AQABAAgIoRhTUgD9AQAAAA==.',['偶看']='偶看好你哟:BAABKgAECn8YAAIHAAgI0SAvEQChAgAHAAgI0SAvEQChAgAAAA==.',['僷铯']='僷铯男爵:BAAAKgADCgYIBgAAAA==.',['全场']='全场最色:BAAAKgAECgYIBgAAAA==.',['八级']='八级小狂风:BAAAKgADCgEIAQAAAA==.',['六酱']='六酱真香:BAABKgAECn8YAAMCAAgISwrvMgDLAAACAAgIlwjvMgDLAAABAAYI9gZL8QCFAAAAAA==.',['兵临']='兵临城下:BAAAKgAECggIDAAAAA==.',['内德']='内德维德:BAAAKgAECgEIAQAAAA==.',['冥之']='冥之埃雷特:BAAAKgAFFAIIAgAAAA==.',['冥炎']='冥炎:BAABKgAFFH8QAAIKAAgIJBujBgApAgAKAAgIJBujBgApAgAAAA==.',['冬天']='冬天不再冷:BAAAKgADCggICAAAAA==.',['冷混']='冷混:BAAAKgAECgQIBAAAAA==.',['冷风']='冷风狂舞:BAACKgAFFH8UAAMSAAQIHRGBCwDYAAASAAQIHRGBCwDYAAAWAAEI3wIUEAAoAAAqAAQKfzUAAxIACAjKFNYsACkBABIACAjKFNYsACkBABYACAgECTAmANAAAAAA.',['凡灵']='凡灵天:BAAAKgAECgQIBAAAAA==.',['凡雪']='凡雪永恒:BAAAKgAECggICAAAAA==.',['刘强']='刘强东:BAABKgAFFH8GAAITAAMIfhBKDADeAAATAAMIfhBKDADeAAAAAA==.',['则瑞']='则瑞的帽子:BAABKgAFFH8IAAIBAAYISxVvHQB9AQABAAYISxVvHQB9AQAAAA==.',['利群']='利群:BAABKgAFFH8VAAIWAAQI7wL7CgBhAAAWAAQI7wL7CgBhAAAAAA==.',['别动']='别动我的母牛:BAABKgAFFH8GAAIGAAYIBBCbDgAsAQAGAAYIBBCbDgAsAQAAAA==.',['刹那']='刹那间的闪:BAAAKgAECggIDQAAAA==.',['剑神']='剑神逍遥游:BAAAKgAECgMIAwAAAA==.',['剣三']='剣三:BAAAKgAECgUIBQAAAA==.',['功夫']='功夫雄猫:BAAAKgADCgIIAgAAAA==.',['劣小']='劣小猎:BAAAKgAECggICAAAAA==.',['勒布']='勒布郎詹姆斯:BAAAKgADCgYIBgAAAA==.',['千碎']='千碎焱:BAAAKgAECgYIBgAAAA==.',['南长']='南长恶霸:BAAAKgAFFAIIAgAAAA==.',['印象']='印象咕咕:BAAAKgAECgEIAQAAAA==.印象若泽:BAACKgAFFH8QAAIIAAUIAhjnEwDVAAAIAAUIAhjnEwDVAAAqAAQKfycAAggACAjEHTEfABoCAAgACAjEHTEfABoCAAAA.',['叁灬']='叁灬爷:BAACKgAFFH8MAAIMAAQIjBO3EwDIAAAMAAQIjBO3EwDIAAAqAAQKfxYAAwwABwgTFElXABwBAAwABwiUEklXABwBAAsABgh5Cig2AK4AAAAA.',['叁爺']='叁爺灬:BAACKgAFFH8GAAIBAAMIyxTySADcAAABAAMIyxTySADcAAAqAAQKfxYAAwEACAgsHUdBAP4BAAEABwidIUdBAP4BAAIABAikDC8+AIsAAAAA.',['只是']='只是有点像:BAAAKgADCgIIAgAAAA==.',['叫我']='叫我不高兴:BAAAKgAFFAcIAgAAAA==.',['可怕']='可怕的蜗牛:BAAAKgADCggICAAAAA==.',['可是']='可是:BAAAKgAECgEIAQAAAA==.',['可爱']='可爱的角角:BAAAKgAECggICAAAAA==.',['可萌']='可萌:BAAAKgAECgEIAQAAAA==.',['合宇']='合宇陈爷:BAAAKgAECggICAAAAA==.',['后跳']='后跳回手掏:BAAAKgAECgUICgAAAA==.',['君莫']='君莫笑:BAAAKgAECgYIBgAAAA==.',['呆呆']='呆呆贼丶:BAABKgAFFH8IAAITAAgIHwmNCADaAQATAAgIHwmNCADaAQAAAA==.',['命运']='命运之手:BAAAKgAFFAYIBAAAAA==.',['咕咕']='咕咕鼓鼓:BAABKgAECn8ZAAIOAAgIER82DgBEAgAOAAgIER82DgBEAgAAAA==.',['哈奈']='哈奈尔:BAAAKgADCgIIAgAAAA==.',['哈尼']='哈尼一吥叽:BAAAKgADCgMIAwAAAA==.',['哈迪']='哈迪贝阿罗:BAAAKgAECgIIAgAAAA==.',['哎木']='哎木九和牛:BAABKgAFFH8HAAMXAAMI3wzKCADOAAAXAAMI3wzKCADOAAABAAIIVQoCfgBrAAAAAA==.哎木五和德:BAACKgAFFH8LAAMGAAMIRho6BwAHAQAGAAMIRho6BwAHAQAHAAIIbw3mUgBsAAAqAAQKfx8AAwYACAhaHTYWABMCAAYACAhaHTYWABMCAAcABgh4EzJrABkBAAAA.哎木五和龙:BAAAKgADCggIEAAAAA==.',['唏哩']='唏哩呼噜:BAACKgAFFH8IAAIYAAMIpQJOCgBgAAAYAAMIpQJOCgBgAAAqAAQKfxQAAhgACAgBCTkUAOIAABgACAgBCTkUAOIAAAAA.',['啵哆']='啵哆嘢结衣:BAAAKgADCgEIAQAAAA==.',['喋血']='喋血之刃:BAABKgAFFH8GAAIZAAYIjRBjDgBhAQAZAAYIjRBjDgBhAQABKgAFFAgIBgALAF4LAA==.',['噬血']='噬血悪灵:BAAAKgAFFAQIBAAAAA==.',['四月']='四月丶:BAAAKgAECgEIAQAAAA==.',['圆融']='圆融的大水牛:BAAAKgAECggICQAAAA==.',['圈圈']='圈圈面包:BAAAKgAECgIIAgAAAA==.',['土曾']='土曾强萨木耳:BAAAKgAFFAIIBAABKgAFFAgIBwAIAN8SAA==.',['圣光']='圣光之祖:BAAAKgAFFAYIBAAAAA==.',['圣加']='圣加西亚:BAAAKgADCggIDwAAAA==.',['圣帝']='圣帝撒奥瑟:BAABKgAFFH8UAAIBAAgIcR8DAQD6AQABAAgIcR8DAQD6AQAAAA==.',['地狱']='地狱西施:BAAAKgADCgUIBQAAAA==.',['城市']='城市经典:BAABKgAFFH8IAAICAAgIjyMmAQDSAgACAAgIjyMmAQDSAgAAAA==.',['堕落']='堕落的大牛:BAAAKgADCgQIBAAAAA==.堕落的暗风:BAABKgAFFH8GAAIKAAYIZhkkEACOAQAKAAYIZhkkEACOAQAAAA==.',['塚灬']='塚灬铭记:BAAAKgAECgEIAQAAAA==.',['墨丶']='墨丶雾影:BAAAKgAECgYIBgAAAA==.',['壬水']='壬水行:BAABKgAFFH8GAAIZAAYI1g1SFgBIAQAZAAYI1g1SFgBIAQAAAA==.',['夏晓']='夏晓荣:BAAAKgAECgEIAQAAAA==.',['夜的']='夜的旋律:BAAAKgADCggICAAAAA==.',['夜色']='夜色丶玫瑰:BAAAKgAECgIIAgAAAA==.',['大事']='大事不妙:BAAAKgAECgcIBwAAAA==.',['大内']='大内密探阿宗:BAAAKgAECgMIAwAAAA==.',['大力']='大力士:BAABKgAFFH8PAAIMAAgI/xkgCwDcAQAMAAgI/xkgCwDcAQAAAA==.',['大熊']='大熊猫熬:BAAAKgADCggICAAAAA==.',['大田']='大田:BAAAKgADCggICAAAAA==.',['大红']='大红手阿宗:BAAAKgAECgEIAQAAAA==.',['大菠']='大菠萝:BAAAKgAFFAYIAQABKgAFFAgICAACAOIcAA==.',['大黑']='大黑汉撩素年:BAABKgAFFH8JAAIZAAMIjBqIJADoAAAZAAMIjBqIJADoAAAAAA==.',['天启']='天启之箭:BAAAKgAECgUIBQAAAA==.',['天命']='天命之灭世者:BAAAKgAFFAQIBAAAAA==.',['天堂']='天堂里的橙砖:BAAAKgAFFAIIAgAAAA==.',['天天']='天天有爱心:BAAAKgADCgMIAwAAAA==.',['天时']='天时:BAAAKgAECgQIBAAAAA==.',['太阳']='太阳花的叶子:BAAAKgADCggIEQAAAA==.',['失语']='失语:BAAAKgADCggICAAAAA==.',['奈斯']='奈斯任:BAAAKgAECggICAAAAA==.',['奈落']='奈落之光:BAAAKgAFFAQIBAAAAA==.',['奔放']='奔放亲老汉:BAABKgAFFH8JAAINAAMIVhQKDACxAAANAAMIVhQKDACxAAAAAA==.',['奔跑']='奔跑的小猪:BAAAKgAECggICAAAAA==.',['奶圈']='奶圈:BAAAKgAECggIEAAAAA==.',['奶德']='奶德啊绣:BAAAKgAFFAIIBAAAAA==.',['奶油']='奶油味牛肉饼:BAAAKgAFFAgIBAAAAA==.',['她要']='她要结婚了:BAAAKgAECgcIBwAAAA==.',['她说']='她说他很棒:BAAAKgAFFAYIAQAAAA==.她说她想要:BAAAKgADCgIIAgAAAA==.',['好人']='好人丶:BAAAKgAECgYICQAAAA==.',['好湿']='好湿:BAAAKgAECggICAAAAA==.',['好立']='好立可:BAAAKgADCggICAAAAA==.',['妮可']='妮可拉刀疤:BAABKgAFFH8IAAMHAAgIXx2VCgDqAQAHAAcIERyVCgDqAQAGAAEIKQpqNQBFAAAAAA==.',['妹妹']='妹妹灬笑呵呵:BAAAKgAECgEIAQAAAA==.',['姗姗']='姗姗小糖果:BAAAKgADCgIIAgAAAA==.',['婴宁']='婴宁:BAAAKgAECgUIBQAAAA==.',['媛嘟']='媛嘟嘟:BAABKgAFFH8IAAIaAAgI5grjCwCqAQAaAAgI5grjCwCqAQAAAA==.',['嫖指']='嫖指导:BAAAKgAECggIAgAAAA==.',['季泊']='季泊常:BAAAKgAFFAgIAwAAAA==.',['宇多']='宇多熊光:BAAAKgAFFAQIAQAAAA==.',['家有']='家有小樣:BAAAKgAECgUIBQAAAA==.',['寂寞']='寂寞海上玥:BAAAKgADCggICAAAAA==.',['寒慕']='寒慕晨:BAAAKgAECgIIAgAAAA==.',['寒樱']='寒樱似雪:BAABKgAECn8bAAIIAAgIIRY/SgBhAQAIAAgIIRY/SgBhAQAAAA==.',['射穿']='射穿你小子:BAAAKgAECgcIEAAAAA==.',['小丑']='小丑:BAAAKgADCggICAAAAA==.',['小丘']='小丘傻馒:BAAAKgAFFAQIBAAAAA==.',['小九']='小九向阳丶:BAABKgAFFH8IAAIZAAQInxc6JwDaAAAZAAQInxc6JwDaAAAAAA==.',['小初']='小初夏:BAAAKgAECgIIAgAAAA==.',['小名']='小名叫小三三:BAAAKgADCggIDQAAAA==.',['小小']='小小奶萨:BAAAKgADCgQIBAAAAA==.小小黑夜眼睛:BAAAKgAECgEIAQAAAA==.',['小弟']='小弟绕腰三圈:BAABKgAFFH8JAAIBAAMIMhQoIwDbAAABAAMIMhQoIwDbAAAAAA==.',['小德']='小德练习生:BAACKgAFFH8KAAIGAAcIQRq5BgCqAQAGAAcIQRq5BgCqAQAqAAQKfxMAAwcABwikIZgyAPEBAAcABwikIZgyAPEBABsABQhsEsckAMIAAAAA.',['小池']='小池塘:BAABKgAFFH8FAAIcAAMI7gsbDAC5AAAcAAMI7gsbDAC5AAAAAA==.',['小煎']='小煎花鲢:BAABKgAFFH8GAAIBAAYIISADGACdAQABAAYIISADGACdAQAAAA==.',['小耳']='小耳朵好漂亮:BAAAKgAECgIIAgAAAA==.',['小雪']='小雪可以怡情:BAAAKgAFFAQIAQAAAA==.',['屋顶']='屋顶上的戈多:BAAAKgAFFAQIBAAAAA==.',['岁月']='岁月记忆怀念:BAAAKgAECggIEQAAAA==.',['岌岌']='岌岌:BAAAKgAFFAEIAQAAAA==.',['布鲁']='布鲁兹大叔:BAAAKgADCgYIBgAAAA==.布鲁兹老爷:BAABKgAFFH8HAAISAAcIYRQ9BgC4AQASAAcIYRQ9BgC4AQAAAA==.',['师太']='师太请放开手:BAAAKgAECgIIAgAAAA==.',['带带']='带带猎猎吧:BAABKgAFFH8IAAMJAAgIixbiFABOAQAJAAQIcBziFABOAQAUAAQIrQ5oMwCkAAAAAA==.',['幽默']='幽默小龙人:BAAAKgAFFAIIAgAAAA==.',['床世']='床世纪:BAAAKgADCggICwAAAA==.',['弥塞']='弥塞亚:BAAAKgAECgcICQAAAA==.',['弹指']='弹指舞飞雪:BAAAKgAECgEIAQAAAA==.',['当了']='当了哩个当:BAAAKgAECgUIBwAAAA==.',['御箭']='御箭飞龍:BAABKgAFFH8KAAMUAAgIMhcNFwAuAQAUAAQIiRcNFwAuAQAJAAQIvxYlMgDGAAAAAA==.',['德狼']='德狼:BAAAKgADCgIIAgAAAA==.',['德艺']='德艺雙馨:BAAAKgAFFAQIBAAAAA==.',['心机']='心机之蛙:BAAAKgAECgcICAAAAA==.',['心照']='心照不宣:BAAAKgAECgQIBAAAAA==.',['心软']='心软吊硬:BAAAKgADCgcIBwAAAA==.',['必胜']='必胜客:BAAAKgAECgQIBAAAAA==.',['性感']='性感大蜥蜴:BAAAKgAECggICAAAAA==.',['恬悠']='恬悠优:BAAAKgAECgQIBAAAAA==.',['恶名']='恶名昭著:BAAAKgAECgEIAQAAAA==.',['悍匪']='悍匪:BAAAKgAECgIIAgAAAA==.',['惊天']='惊天巨鳝:BAAAKgAECggICgAAAA==.',['想念']='想念莫离丶:BAABKgAFFH8KAAMdAAYIlRytGQDpAAAdAAYI9RqtGQDpAAAaAAQIiBcUKQC+AAABKgAFFAgIDgABAKsWAA==.',['感受']='感受我的圣光:BAAAKgAECgQIBAAAAA==.',['愤怒']='愤怒的香烟:BAAAKgADCgcIBwAAAA==.',['我来']='我来偷茄子的:BAABKgAFFH8OAAITAAMIKgpPHQDCAAATAAMIKgpPHQDCAAAAAA==.',['我要']='我要反三俗:BAAAKgAECgYIBgAAAA==.',['我震']='我震死你:BAABKgAFFH8IAAIIAAQI5hPSEgDZAAAIAAQI5hPSEgDZAAABKgAFFAgICAAIALsbAA==.',['战歌']='战歌部落:BAAAKgAECgMIBgAAAA==.',['技艺']='技艺精甚:BAABKgAFFH8IAAITAAMIkgo6DgC7AAATAAMIkgo6DgC7AAAAAA==.',['抓住']='抓住黑护:BAAAKgAECgYIBgAAAA==.',['抗怪']='抗怪基本用脸:BAAAKgAFFAQIBAAAAA==.',['折灵']='折灵丶:BAAAKgAECggICAAAAA==.',['指尖']='指尖弹出盛夏:BAAAKgAFFAIIAgAAAA==.',['探花']='探花界天花板:BAABKgAFFH8IAAIIAAgIwglrCADAAQAIAAgIwglrCADAAQAAAA==.',['插棍']='插棍捅破天:BAABKgAFFH8PAAMeAAMIcRldDQD1AAAeAAMIcRldDQD1AAAIAAMIDgnCHgCKAAAAAA==.',['撸出']='撸出血:BAAAKgAECgEIAQABKgAFFAgICgABAK0lAA==.',['放爱']='放爱一条生路:BAABKgAFFH8MAAIEAAMIoxgZCwDfAAAEAAMIoxgZCwDfAAAAAA==.',['敲你']='敲你波棱盖:BAAAKgAECggICQAAAA==.',['文乐']='文乐:BAAAKgAECggICAAAAA==.',['斗战']='斗战哈士猎:BAAAKgAECggICAAAAA==.斗战哈士猪:BAAAKgAECgQIBAAAAA==.',['新兵']='新兵:BAABKgAFFH8JAAICAAMI7wOnFgBHAAACAAMI7wOnFgBHAAAAAA==.',['新月']='新月丶玫瑰:BAAAKgAECgYIBgAAAA==.',['方合']='方合:BAAAKgAFFAYIAgAAAA==.方合助理:BAABKgAFFH8KAAMNAAYIwx/TEQDOAAANAAMIRSLTEQDOAAAOAAYIqB1aJQBJAAAAAA==.',['无奈']='无奈的撒旦:BAAAKgADCggIDAAAAA==.',['无敌']='无敌小胖墩:BAAAKgAECgcIBwAAAA==.',['无欲']='无欲:BAAAKgADCgIIAgAAAA==.',['时津']='时津风:BAABKgAECn8XAAMfAAcIdBM7OgAvAQAfAAcI+RI7OgAvAQANAAUIbRAGUgDPAAABKgAFFAgIJQAgACEcAA==.',['旺仔']='旺仔小葡萄:BAABKgAFFH8OAAMdAAYIJh0bCwCGAQAdAAYIlRkbCwCGAQAhAAII4hY+HgCTAAAAAA==.',['明悦']='明悦:BAAAKgAECggICAAAAA==.',['明若']='明若静嫙:BAAAKgADCgIIAgAAAA==.',['明静']='明静:BAAAKgAECgIIAwAAAA==.',['星火']='星火燎原:BAAAKgAECgYIBgAAAA==.',['晨曦']='晨曦之主:BAACKgAFFH8FAAIBAAMIjhUCRwDgAAABAAMIjhUCRwDgAAAqAAQKfxkAAgEACAhrFpmXAGgBAAEACAhrFpmXAGgBAAAA.晨曦闪闪:BAAAKgAECggICgAAAA==.',['暖暖']='暖暖就在胸膛:BAAAKgADCgMIAwAAAA==.',['暮色']='暮色寂然:BAABKgAFFH8SAAQgAAYI7xs8BgD4AAAKAAYI7xtADACFAQAgAAQI1Rg8BgD4AAARAAEIAAD4NAAAAAAAAA==.暮色红手:BAAAKgAECgMIAwAAAA==.',['暴躁']='暴躁:BAAAKgAECgQIBAAAAA==.',['暴风']='暴风下的撕逼:BAABKgAFFH8RAAIUAAMIPxsKEgDdAAAUAAMIPxsKEgDdAAAAAA==.',['曾经']='曾经的大恩:BAAAKgAFFAQIBAAAAA==.',['月下']='月下蝶影丶:BAAAKgADCggICAAAAA==.',['月兮']='月兮:BAAAKgAFFAgIBAAAAA==.',['月夕']='月夕:BAAAKgAFFAYIBAAAAA==.',['月照']='月照如锦:BAABKgAFFH8HAAICAAcIhgorDQAnAQACAAcIhgorDQAnAQAAAA==.',['有凤']='有凤来仪:BAAAKgADCggICAAAAA==.',['朝兮']='朝兮盼兮:BAAAKgADCggICAAAAA==.',['朝霖']='朝霖昂邦邦:BAAAKgADCggICAAAAA==.',['木瓜']='木瓜妞:BAAAKgAECgYIBgAAAA==.',['术小']='术小福:BAAAKgAFFAUIAwAAAA==.',['朴得']='朴得欢:BAAAKgAECgYICwAAAA==.',['朴正']='朴正幻:BAAAKgAECgEIAQAAAA==.朴正欢:BAAAKgAECgUICQAAAA==.',['朴的']='朴的桓:BAAAKgAECgMIAwAAAA==.朴的焕:BAAAKgAECgMIAwAAAA==.',['机器']='机器喵:BAAAKgAECgQIBAAAAA==.',['李槐']='李槐大爷:BAAAKgAECggICAAAAA==.',['枫之']='枫之忆:BAAAKgAFFAMIAwAAAA==.',['柚子']='柚子茶丶:BAAAKgAECggIDwAAAA==.',['柚安']='柚安:BAAAKgADCgYIBgAAAA==.',['柳晓']='柳晓霈:BAABKgAFFH8IAAICAAQIbQ/iDQCgAAACAAQIbQ/iDQCgAAAAAA==.',['柴牧']='柴牧之丶:BAAAKgAFFAMIAwAAAA==.',['桃符']='桃符:BAAAKgADCgQIBAAAAA==.',['梦若']='梦若:BAABKgAECn8UAAIXAAgIuhKiHgBsAQAXAAgIuhKiHgBsAQABKgAFFAgIEAAOAFsKAA==.',['梵蒂']='梵蒂冈之曲:BAAAKgAFFAcIAQAAAA==.',['椛宮']='椛宮娜:BAABKgAFFH8GAAIBAAYIBBdcGQCTAQABAAYIBBdcGQCTAQAAAA==.',['椰椰']='椰椰的星星:BAABKgAFFH8IAAIKAAQItQ9fFQDPAAAKAAQItQ9fFQDPAAAAAA==.',['樱花']='樱花树下:BAAAKgAECgMIAwAAAA==.',['橙人']='橙人游戲:BAAAKgAECggICAAAAA==.',['武大']='武大郎:BAABKgAFFH8JAAMGAAMIqxMxDADLAAAGAAMIqxMxDADLAAAHAAMI9xB1OQC9AAAAAA==.',['死亡']='死亡丶浮铭:BAACKgAFFH8iAAMLAAYIQw6qFwDkAAALAAYIQw6qFwDkAAAMAAQIrgilOwCuAAAqAAQKfzMAAwsACAjeGF8HAMoBAAsACAjeGF8HAMoBAAwAAQg9BUHPAC8AAAAA.死亡斗士:BAAAKgAECgEIAQAAAA==.',['殇灬']='殇灬混乱:BAAAKgAECgMIAwAAAA==.殇灬魅影:BAABKgAFFH8GAAMfAAYInhiGFAAPAQAfAAUI1BaGFAAPAQAOAAEIDwn9LABBAAAAAA==.',['残酷']='残酷灏神纲领:BAAAKgAECggICQAAAA==.',['永生']='永生的发丝:BAABKgAFFH8UAAQhAAgIJB14BACgAQAdAAgIEg8IBwDqAQAhAAgIRhx4BACgAQAaAAMIayO/LwClAAAAAA==.永生的大肥鸡:BAABKgAFFH8IAAIHAAQIVA7YGgDUAAAHAAQIVA7YGgDUAAAAAA==.',['汉库']='汉库克:BAAAKgAECgEIAQAAAA==.',['江南']='江南一棵树:BAAAKgADCgIIAgAAAA==.',['江湖']='江湖百晓生:BAABKgAFFH8VAAIUAAUIZBarDwDbAAAUAAUIZBarDwDbAAAAAA==.',['汽车']='汽车人霸天虎:BAAAKgAECgUIBQAAAA==.',['沉默']='沉默的风语者:BAAAKgAECggIDgAAAA==.',['沐小']='沐小雅丶:BAAAKgAFFAIIAgAAAA==.',['治疗']='治疗萨木耳:BAABKgAFFH8HAAIIAAQI3xKsLQDAAAAIAAQI3xKsLQDAAAAAAA==.',['活着']='活着多好:BAAAKgADCggICAAAAA==.',['流滢']='流滢偌枫:BAABKgAFFH8LAAIUAAYI6BsMCQCcAQAUAAYI6BsMCQCcAQAAAA==.',['流火']='流火若歌:BAAAKgAECgIIAgAAAA==.',['浮生']='浮生丿若梦:BAAAKgAECgcICAAAAA==.',['涅加']='涅加米罗休丝:BAABKgAFFH8IAAICAAgIZx4FAwAgAgACAAgIZx4FAwAgAgAAAA==.',['清风']='清风拂落雨:BAAAKgAFFAgIBAAAAA==.',['温暖']='温暖的茜:BAAAKgAFFAEIAQABKgAFFAgIBgAgAJkUAA==.',['渲染']='渲染街角:BAACKgAFFH8YAAMUAAcIuheZJgDRAAAUAAUInxeZJgDRAAAJAAII8BcAAAAAAAAqAAQKfxsAAhQACAjyG403AE8BABQACAjyG403AE8BAAEqAAUUCAgTAAIADRMA.',['潇潇']='潇潇:BAAAKgAECggIEAAAAA==.',['澜色']='澜色妖姬:BAAAKgAECgcIBwAAAA==.',['灬死']='灬死亡凋零:BAABKgAFFH8JAAMMAAYIhBh9DwCjAQAMAAYIhBh9DwCjAQALAAIIsgR7LQBcAAABKgAFFAgIDQAMAPMWAA==.',['灬纞']='灬纞戦灬:BAAAKgADCgUIBQAAAA==.',['灬风']='灬风行者:BAAAKgAECgIIAgAAAA==.',['灰烬']='灰烬丶黄泉:BAAAKgAECgMIAwAAAA==.灰烬戼天堂:BAABKgAFFH8IAAIGAAgIOgwyBQCYAQAGAAgIOgwyBQCYAQAAAA==.灰烬癶天堂:BAAAKgAFFAUIAQAAAA==.灰烬老九:BAAAKgAECggICAAAAA==.灰烬老铁柱:BAAAKgAECgMIAwAAAA==.',['灵之']='灵之灵:BAAAKgADCggIDAAAAA==.',['烈焰']='烈焰灼心:BAAAKgAECgYICAAAAA==.',['烈风']='烈风之殇:BAABKgAFFH8GAAIUAAYIewwBGAAoAQAUAAYIewwBGAAoAQABKgAFFAgICAAJAKoYAA==.',['烛龙']='烛龙九阴:BAABKgAECn8gAAMKAAgIZh3NEgASAgAKAAgIyxvNEgASAgARAAgIQhRwIAB/AQAAAA==.',['烟缸']='烟缸爱香烟:BAAAKgADCgQIBAAAAA==.',['無情']='無情的寶貝:BAABKgAFFH8SAAMBAAYI4CRJCwATAgABAAYIQCNJCwATAgACAAYI5R9hBgC+AQAAAA==.',['焦糖']='焦糖舒芙蕾:BAABKgAECn8lAAIVAAgIiQ30LgAUAQAVAAgIiQ30LgAUAQAAAA==.',['爆瀑']='爆瀑鑤曝米花:BAAAKgAECgEIAQAAAA==.',['爱囡']='爱囡囡:BAAAKgAECggIEAAAAA==.',['爱是']='爱是不保留丶:BAAAKgADCgMIAwAAAA==.',['爱美']='爱美丽斯:BAAAKgAECgMIAwAAAA==.爱美丽斯丶:BAAAKgAECggICQAAAA==.',['牛三']='牛三叉飞毛腿:BAAAKgAECgcICgAAAA==.',['牛太']='牛太白:BAAAKgAFFAQIBAAAAA==.',['牛腩']='牛腩煲菠萝油:BAAAKgAECggIEAAAAA==.',['牛里']='牛里牛气:BAABKgAFFH8IAAIBAAQIXBpEGgD2AAABAAQIXBpEGgD2AAAAAA==.',['牧呦']='牧呦小丘:BAAAKgAECgMIAwAAAA==.',['特仑']='特仑苏:BAAAKgAECgYIBgAAAA==.',['狂怒']='狂怒萧墙:BAAAKgADCggICAAAAA==.',['狂神']='狂神:BAAAKgAECgEIAQAAAA==.',['狂风']='狂风浪迹:BAABKgAFFH8MAAMVAAQIkANLDwBqAAAVAAMIkANLDwBqAAAZAAEIAACnLAAAAAAAAA==.',['狩猎']='狩猎与生存:BAAAKgADCggICAAAAA==.',['独酌']='独酌陈酿:BAAAKgAFFAQIBAAAAA==.',['狼王']='狼王:BAAAKgAFFAQIBAAAAA==.',['猫不']='猫不哀伤:BAAAKgAECgQIBAAAAA==.',['猴子']='猴子就是我:BAABKgAFFH8IAAIDAAgIDw2yBgChAQADAAgIDw2yBgChAQAAAA==.',['獄火']='獄火重生:BAAAKgAFFAMIBAAAAA==.',['玄皮']='玄皮寡脸:BAAAKgAECgYIBgAAAA==.',['王健']='王健林:BAABKgAFFH8UAAIMAAMIHA8TNQDDAAAMAAMIHA8TNQDDAAAAAA==.',['班策']='班策达根:BAAAKgAECgcIDgAAAA==.',['琥珀']='琥珀:BAAAKgAECgIIAgAAAA==.',['生椰']='生椰丝绒拿铁:BAAAKgADCgQIBAAAAA==.',['用角']='用角怼死你:BAAAKgAFFAQIBAAAAA==.',['电到']='电到啦啦酥:BAAAKgADCggICAAAAA==.',['疾风']='疾风邀月:BAABKgAFFH8JAAIdAAMIvxEOCADkAAAdAAMIvxEOCADkAAAAAA==.',['白嫩']='白嫩滑弹:BAABKgAFFH8GAAIMAAQIIRVrFADnAAAMAAQIIRVrFADnAAAAAA==.白嫩滑弹挺:BAAAKgAECggIEAAAAA==.白嫩滑弹翘挺:BAABKgAFFH8KAAIJAAYI5h3hCgDAAQAJAAYI5h3hCgDAAQAAAA==.',['白衣']='白衣宁凡:BAAAKgAECgEIAQAAAA==.',['百步']='百步穿揚:BAAAKgAECgYIBwAAAA==.',['盒子']='盒子哥的骑士:BAAAKgAFFAEIAQABKgAFFAgIMAAFACEaAA==.',['盗跖']='盗跖:BAACKgAFFH8KAAMTAAMIZhkHFgD4AAATAAMIZhkHFgD4AAAiAAEIPRkjCABOAAAqAAQKfyIAAyIACAjbHRMLADcCACIABwiRHxMLADcCABMACAiyFs8fAGEBAAAA.',['瞄准']='瞄准:BAAAKgAECggICgABKgAFFAgICAAJAHkgAA==.',['瞬间']='瞬间的永恒:BAACKgAFFH8HAAIMAAMIQxmxLADbAAAMAAMIQxmxLADbAAAqAAQKfyEAAgwACAjoHlcnABwCAAwACAjoHlcnABwCAAAA.',['矮大']='矮大妈也风流:BAAAKgAECggIEQAAAA==.',['砭苄']='砭苄胬檠鼾:BAAAKgADCgMIAwAAAA==.',['碎梦']='碎梦:BAAAKgAECgEIAQAAAA==.',['磐岩']='磐岩岛:BAAAKgADCggICQAAAA==.',['磷纹']='磷纹:BAAAKgAFFAQIAgAAAA==.',['秋荼']='秋荼丶:BAAAKgAECgYIBgAAAA==.',['秦之']='秦之明月:BAAAKgAFFAQIBAAAAA==.',['穷死']='穷死的:BAAAKgAECgUIBQAAAA==.',['空空']='空空兒:BAABKgAFFH8GAAIIAAYILBiqDACBAQAIAAYILBiqDACBAQAAAA==.',['章北']='章北海:BAAAKgAECgEIAQAAAA==.',['米兰']='米兰地小瓦匠:BAAAKgADCggIDQAAAA==.',['系咪']='系咪肥咕咕:BAAAKgAFFAIIAgAAAA==.',['純情']='純情的小豬:BAABKgAFFH8GAAIaAAMIOw7BKQC7AAAaAAMIOw7BKQC7AAAAAA==.',['索尔']='索尔迦雷欧:BAAAKgAECgYIDgAAAA==.',['紫色']='紫色的偶然:BAAAKgAECgUIBQAAAA==.',['紫英']='紫英丶:BAAAKgAFFAYIAQAAAA==.',['红到']='红到无能无力:BAABKgAFFH8IAAMUAAQIbR2/BgARAQAUAAQIVx2/BgARAQAJAAQIjhhhLwDMAAAAAA==.',['红烧']='红烧牛腩:BAACKgAFFH8VAAMPAAQI8xU7EQD1AAAPAAQInRI7EQD1AAASAAIIShVaFgBdAAAqAAQKfyUAAw8ACAjGImIOAJMCAA8ACAh7IWIOAJMCABIAAgj0GHNPAI0AAAAA.',['纣王']='纣王:BAABKgAFFH8MAAMUAAgIyhtAEABkAQAUAAgIDRtAEABkAQAJAAQIDwkAAAAAAAAAAA==.',['细雨']='细雨挽轻裳:BAAAKgAECggIEQAAAA==.',['终将']='终将涅槃:BAAAKgAFFAQIBAAAAA==.',['结冰']='结冰水:BAAAKgAECgMIAwAAAA==.',['维尔']='维尔卡:BAABKgAFFH8IAAMPAAgIYiByBgAHAgAPAAYI4CJyBgAHAgASAAIIJxoVGwCyAAAAAA==.',['缓缓']='缓缓归矣:BAAAKgAFFAYIBAAAAA==.',['缺耐']='缺耐者:BAABKgAFFH8MAAMhAAgIpBFCBAASAQAdAAgI6wZrCADBAQAhAAQI9h9CBAASAQAAAA==.',['翅膀']='翅膀:BAABKgAFFH8bAAITAAgIHBvnAgCDAgATAAgIHBvnAgCDAgAAAA==.',['老柴']='老柴:BAAAKgAFFAIIAgAAAA==.',['肉豆']='肉豆豆:BAABKgAFFH8SAAMIAAgI1hq9AwAxAgAIAAgI1hq9AwAxAgAQAAQI/hgoCADtAAAAAA==.',['肥婆']='肥婆烧烤:BAABKgAFFH8IAAIBAAgIJRjiBgBaAgABAAgIJRjiBgBaAgAAAA==.',['胖子']='胖子他叔:BAAAKgAECgYIBgAAAA==.',['花生']='花生中丶毒:BAAAKgAECgUIBQAAAA==.花生丶中毒:BAAAKgAECggICAAAAA==.',['花若']='花若云裳:BAAAKgAECggICAAAAA==.',['苍鹰']='苍鹰魔弹:BAAAKgAECgcIBwAAAA==.',['苏离']='苏离丶半折:BAAAKgAFFAQIBAABKgAFFAgIDwAeAC4bAA==.',['苏轼']='苏轼:BAAAKgAECgcIBwAAAA==.',['若小']='若小吉:BAAAKgADCgEIAQAAAA==.',['若离']='若离若即:BAABKgAFFH8LAAIUAAMI6QcPOACWAAAUAAMI6QcPOACWAAAAAA==.',['苦功']='苦功:BAAAKgAECgcIDQAAAA==.',['茉莉']='茉莉味小飞象:BAAAKgAECgcICQAAAA==.',['草莓']='草莓糖果:BAAAKgAFFAEIAQAAAA==.',['菊花']='菊花灵:BAABKgAFFH8IAAITAAYI0xD4CQCzAQATAAYI0xD4CQCzAQAAAA==.菊花箭:BAAAKgAECgQIBAAAAA==.',['萧瑟']='萧瑟秋凉:BAAAKgAFFAIIAgAAAA==.',['萨拉']='萨拉塔斯:BAABKgAECn8ZAAIOAAcIaRdaJACzAQAOAAcIaRdaJACzAQAAAA==.',['萨满']='萨满之王:BAAAKgAFFAQIBAAAAA==.',['萨科']='萨科西格尔:BAAAKgADCgUIBQAAAA==.',['葛斑']='葛斑玛:BAACKgAFFH8OAAIFAAMIlhrpCQAAAQAFAAMIlhrpCQAAAQAqAAQKfyIAAwUACAijIosIAKECAAUACAijIosIAKECACMABAhSGmMTACEBAAAA.',['蒋劲']='蒋劲夫:BAAAKgAECgIIAgAAAA==.',['蔷薇']='蔷薇乱舞:BAAAKgAECggIEQAAAA==.',['蘇菲']='蘇菲桑:BAAAKgAFFAEIAQAAAA==.',['虚空']='虚空传说:BAABKgAECn8UAAMKAAgIpw5iRQBTAQAKAAgIHgxiRQBTAQARAAUIcxF3QQDbAAAAAA==.',['虬髯']='虬髯天佑:BAACKgAFFH8KAAMgAAYIUCJfAQC4AQAgAAYIUCJfAQC4AQAKAAII2RyrHwCUAAAqAAQKfx0ABCAACAi1HFIdAAUBABEABggSGHU3ABcBACAABAhEGlIdAAUBAAoAAwgIFUWEAIMAAAAA.',['蚕豆']='蚕豆:BAAAKgADCgMIAwAAAA==.',['蛋蛋']='蛋蛋暴了:BAAAKgAECgEIAQAAAA==.',['蜗牛']='蜗牛冒泡泡:BAAAKgAECgcIBwAAAA==.',['蜜汁']='蜜汁山芋:BAABKgAECn8UAAIBAAgITCBrRQDxAQABAAgITCBrRQDxAQABKgAFFAgIDQABAOEYAA==.',['蜜雪']='蜜雪冰橙:BAAAKgAFFAgIAgAAAA==.',['血魄']='血魄之力:BAAAKgAECgYIDgAAAA==.',['衤果']='衤果奔是种美:BAABKgAECn8ZAAIhAAgIcxCTUAAjAQAhAAgIcxCTUAAjAQAAAA==.',['裴斐']='裴斐:BAAAKgADCggICAAAAA==.',['西柚']='西柚棒棒糖:BAAAKgAFFAEIAQAAAA==.',['西红']='西红柿炖豆腐:BAAAKgAECgIIAgAAAA==.',['西门']='西门庆:BAABKgAFFH8MAAISAAMI4RLXFgDPAAASAAMI4RLXFgDPAAAAAA==.',['該瘾']='該瘾:BAABKgAFFH8IAAIfAAgIcQYrCQCSAQAfAAgIcQYrCQCSAQAAAA==.',['諾一']='諾一:BAAAKgAECgUICQAAAA==.',['讹兲']='讹兲使:BAAAKgAFFAIIAgAAAA==.',['语光']='语光无敌啦:BAABKgAECn8UAAIhAAgI7x1nHAAiAgAhAAgI7x1nHAAiAgAAAA==.',['请叫']='请叫我唐浮云:BAABKgAFFH8GAAIHAAYIEQouHgAsAQAHAAYIEQouHgAsAQAAAA==.',['诺拉']='诺拉丶萌僧:BAAAKgAFFAgIBAAAAA==.',['谢瑞']='谢瑞麟:BAAAKgAECgcIBwAAAA==.',['豆哥']='豆哥:BAABKgAFFH8JAAMOAAYILR2DCACEAQAOAAYILR2DCACEAQAfAAIIlxKcIgBFAAAAAA==.',['貓绒']='貓绒绒:BAAAKgAECgMIAwAAAA==.',['貝殼']='貝殼里的海:BAABKgAFFH8QAAQgAAYIaCN7BAALAQAKAAYIViI7DgCpAQAgAAMIjSJ7BAALAQARAAIILR02EQBeAAAAAA==.',['费尔']='费尔南达:BAAAKgAECgEIAQAAAA==.',['贼猫']='贼猫之手:BAAAKgAECgMIAwAAAA==.',['贾樟']='贾樟柯:BAAAKgAECggICQAAAA==.',['赛尔']='赛尔宇:BAAAKgADCgIIAgAAAA==.赛尔欣:BAAAKgADCgMIAwAAAA==.',['足道']='足道也是道:BAAAKgAECgEIAQAAAA==.',['踩花']='踩花儿:BAAAKgADCggICAAAAA==.',['软趴']='软趴趴:BAABKgAFFH8GAAIbAAMI2QvPCACAAAAbAAMI2QvPCACAAAAAAA==.',['轰开']='轰开乾坤门:BAAAKgADCgEIAQAAAA==.',['轻嗅']='轻嗅石楠:BAAAKgADCggICQAAAA==.',['输出']='输出及格线:BAABKgAECn8iAAMIAAgIRB01GQAwAgAIAAgIRB01GQAwAgAQAAEIKBAbeAAxAAAAAA==.',['辣是']='辣是我亮哥:BAABKgAFFH8OAAMLAAYIGRS/DQA8AQALAAYIGRS/DQA8AQAMAAQIjglmHgCrAAAAAA==.辣是我亮哥哎:BAABKgAFFH8KAAIBAAYIMBokIQBqAQABAAYIMBokIQBqAQAAAA==.辣是我亮哥帝:BAAAKgAFFAQIBAAAAA==.辣是我亮哥术:BAABKgAFFH8GAAIKAAYIZg3hFwBFAQAKAAYIZg3hFwBFAQAAAA==.辣是我亮哥萨:BAAAKgAFFAQIBAAAAA==.',['辰梦']='辰梦夜:BAAAKgAFFAYIBAAAAA==.',['这个']='这个冬天好冷:BAAAKgAECgQIBAAAAA==.',['这货']='这货有点萌:BAAAKgADCggICAAAAA==.',['追月']='追月无痕:BAAAKgAFFAQIBAAAAA==.',['逆蝶']='逆蝶重生:BAABKgAFFH8QAAMFAAgI+B13BgArAgAFAAgI+B13BgArAgAjAAIIAQw1CAB0AAAAAA==.',['逗号']='逗号与逗号:BAAAKgAECgYIBgAAAA==.',['道无']='道无:BAAAKgAFFAgIBAAAAA==.',['遗忘']='遗忘:BAABKgAFFH8IAAILAAgIywlZCwBcAQALAAgIywlZCwBcAQAAAA==.',['那一']='那一眼回眸:BAAAKgAFFAYIBAAAAA==.',['都变']='都变成羊吧:BAABKgAFFH8GAAIaAAYIZQMiFQDWAAAaAAYIZQMiFQDWAAAAAA==.',['重返']='重返一百六:BAAAKgAECgIIAgAAAA==.',['鉴茶']='鉴茶师:BAABKgAFFH8TAAMdAAUIqyLKBgCYAQAdAAUIbCDKBgCYAQAaAAQIDyP4GwAFAQABKgAFFAgIDgAaAMAhAA==.',['铁掌']='铁掌乃上漂:BAABKgAFFH8IAAIDAAgIYgdFCABtAQADAAgIYgdFCABtAQAAAA==.',['锅里']='锅里有饭:BAAAKgAECgQIBQAAAA==.',['锦丨']='锦丨马超:BAAAKgAECgUIBQAAAA==.',['锦年']='锦年:BAABKgAFFH8GAAIPAAYIGQ36DgBlAQAPAAYIGQ36DgBlAQAAAA==.',['长安']='长安幻夜:BAAAKgADCggICAAAAA==.',['阿伟']='阿伟罗:BAAAKgAECggICAAAAA==.',['阿爾']='阿爾托莉雅:BAAAKgAFFAgIBAAAAA==.',['阿蠢']='阿蠢:BAAAKgADCggICQAAAA==.',['阿赤']='阿赤:BAAAKgADCggICAAAAA==.',['随性']='随性:BAAAKgAECgYIBwAAAA==.',['随笨']='随笨笨:BAAAKgAECgUIBQAAAA==.',['隐形']='隐形熊掏击:BAAAKgADCgcIBwAAAA==.',['雨神']='雨神丶肖敬腾:BAAAKgADCggICAAAAA==.',['雨落']='雨落心尘:BAACKgAFFH8HAAIBAAQI8SS/LgAtAQABAAQI8SS/LgAtAQAqAAQKfyMAAgEACAg6I+QGAMwCAAEACAg6I+QGAMwCAAAA.',['零九']='零九年的伍萨:BAAAKgAECgcICAAAAA==.零九年的肆德:BAAAKgAECgQIBQAAAA==.零九年的贰猎:BAABKgAECn8UAAMJAAgIJh8vKgBLAgAJAAgIJh8vKgBLAgAkAAEIrA2JIAAkAAAAAA==.',['零元']='零元:BAAAKgAECgEIAgAAAA==.',['零分']='零分:BAAAKgADCggICAAAAA==.',['雷电']='雷电熊熊:BAAAKgAFFAIIAgAAAA==.',['雾雨']='雾雨之刃:BAAAKgAFFAQIBAAAAA==.',['霓彩']='霓彩儿:BAAAKgAFFAYIBAAAAA==.',['霸气']='霸气全漏:BAAAKgAFFAQIBAAAAA==.霸气内敛:BAAAKgAECggICAAAAA==.',['青鸟']='青鸟丶飞鱼:BAAAKgAFFAIIAwAAAA==.',['颠覆']='颠覆天下:BAAAKgADCggICAAAAA==.',['风之']='风之岚歌:BAAAKgAECgQIBAAAAA==.',['风城']='风城烟雨:BAAAKgAFFAQIAwAAAA==.',['风干']='风干的微笑:BAABKgAFFH8QAAIBAAgIjCK4AgDEAgABAAgIjCK4AgDEAgAAAA==.',['风杀']='风杀:BAAAKgAECgEIAQAAAA==.',['风沧']='风沧溟:BAAAKgAECgIIAgAAAA==.',['飚丶']='飚丶血:BAAAKgADCgcIBwAAAA==.',['香蜜']='香蜜的小泥泥:BAAAKgAECgUICQAAAA==.',['马化']='马化腾:BAABKgAFFH8OAAINAAgIkQr2CQDYAAANAAgIkQr2CQDYAAAAAA==.',['马匹']='马匹德:BAABKgAFFH8GAAIBAAYIfRdPHgB4AQABAAYIfRdPHgB4AQAAAA==.',['马小']='马小姨子:BAAAKgAECgEIAgAAAA==.',['骆驼']='骆驼骑士:BAAAKgAFFAIIAwAAAA==.',['骑小']='骑小猪去看山:BAAAKgAFFAgIBAAAAA==.',['魔苟']='魔苟斯:BAAAKgAECgMIAwAAAA==.',['鱼香']='鱼香肉丝:BAAAKgAFFAQIBAAAAA==.',['鱼鹰']='鱼鹰:BAABKgAFFH8JAAIbAAMINxA6BwCbAAAbAAMINxA6BwCbAAAAAA==.',['鲫鱼']='鲫鱼:BAACKgAFFH8pAAQdAAYI2SJFDAA6AQAdAAUImSFFDAA6AQAaAAQISiVbFwApAQAhAAII+SA/GgBgAAAqAAQKfy8AAx0ACAiUJqIAAB8DAB0ACAiPJqIAAB8DABoACAgpJQIIAMUCAAAA.',['麻辣']='麻辣肌胸肉:BAAAKgADCggICAAAAA==.',['黄圣']='黄圣依:BAABKgAFFH8IAAIFAAgIUw1wCADiAQAFAAgIUw1wCADiAQAAAA==.',['黄瓜']='黄瓜精:BAAAKgAECgMIAwAAAA==.',['黑了']='黑了黑牛:BAAAKgADCgQIBAAAAA==.',['黑暗']='黑暗新娘:BAAAKgADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end