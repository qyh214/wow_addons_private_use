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
 local lookup = {'Warlock-Demonology','Warrior-Fury','Warrior-Arms','Druid-Balance','Shaman-Restoration','Shaman-Elemental','Druid-Restoration','Druid-Guardian','Mage-Arcane','Evoker-Devastation','DeathKnight-Frost','Warrior-Protection','DeathKnight-Blood','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','DemonHunter-Vengeance','Unknown-Unknown','Rogue-Assassination','Rogue-Subtlety','Monk-Brewmaster','Paladin-Retribution','Paladin-Holy','Druid-Feral','Monk-Windwalker','Priest-Holy','Warlock-Destruction','Paladin-Protection','Mage-Frost','Monk-Mistweaver','DeathKnight-Unholy','Mage-Fire','Hunter-Survival','Evoker-Augmentation','Evoker-Preservation','Priest-Shadow','Warlock-Affliction',}; local provider = {region='CN',realm='霍格',name='CN',type='weekly',zone=44,date='2025-12-10',data={Ai='Aifa:BAABLAAFFH8IAAIBAAIIvBweDwCmAAABAAIIvBweDwCmAAAAAA==.',Ar='Armani:BAAALAADCgMIAwAAAA==.',As='Ash:BAABLAAFFH8OAAMCAAYIeRC3IQBmAQACAAYIeRC3IQBmAQADAAIIUBxNAwCqAAAAAA==.Asûnâ:BAAALAAECggIBgAAAA==.',Ba='Bananan:BAAALAAFFAMIAQAAAA==.',Bi='Bigrain:BAAALAAFFAIIBAABLAAFFAgIEAAEAO8eAA==.',Bo='Boares:BAAALAAECgQIBAAAAA==.',Ca='Caffein:BAABLAAFFH8IAAICAAIIYBVCNQCZAAACAAIIYBVCNQCZAAAAAA==.',Cc='Cctvc:BAABLAAECn8VAAMFAAYIKg+JaQDKAAAFAAYIKg+JaQDKAAAGAAMIhAn0cgBSAAAAAA==.',Ch='Christer:BAAALAAECggICwAAAA==.',El='Elymas:BAAALAAECgQIBgAAAA==.',Em='Emilye:BAABLAAFFH8NAAMHAAIIaAbFRABaAAAHAAIIaAbFRABaAAAIAAIIqBsRCwBGAAAAAA==.Emnm:BAABLAAFFH8NAAMFAAYIIwu+OADEAAAFAAUIAQe+OADEAAAGAAEILARNTgA4AAAAAA==.',He='Helle:BAAALAADCgEIAQAAAA==.',Ho='Hordak:BAAALAADCgYIDAAAAA==.',Ia='Iamguldan:BAAALAAECgYIBgAAAA==.',Ja='Jackseven:BAABLAAFFH8SAAIJAAYIBiRgEAD9AQAJAAYIBiRgEAD9AQAAAA==.Jagermister:BAAALAADCggICAAAAA==.',Ki='Kiba:BAACLAAFFH8TAAIKAAUISR7iDABYAQAKAAUISR7iDABYAQAsAAQKfx4AAgoACAhHHuEGAEUCAAoACAhHHuEGAEUCAAAA.',Ku='Kumo:BAABLAAFFH8RAAILAAgIfiL9BAC5AgALAAgIfiL9BAC5AgAAAA==.',Li='Lifengzs:BAABLAAFFH8GAAIMAAYIJR3OCwCLAQAMAAYIJR3OCwCLAQAAAA==.',Ma='Maisakatoku:BAAALAAFFAIIBAAAAA==.',Me='Medusa:BAAALAAFFAMIAwAAAA==.',Mi='Miss:BAAALAAFFAEIAQAAAA==.',Mo='Mochizuki:BAAALAAECgYIBgAAAA==.',Oc='Oct:BAAALAADCgYIBgAAAA==.',Oi='Oiqs:BAAALAADCgYIBgAAAA==.',Pa='Padre:BAAALAAECggICAAAAA==.Papay:BAAALAAECggIBgAAAA==.',Po='Poisonllvy:BAABLAAFFH8gAAINAAYIOSOJBQD0AQANAAYIOSOJBQD0AQAAAA==.Pookieq:BAABLAAFFH8KAAILAAUIlha0RQArAQALAAUIlha0RQArAQAAAA==.Porschez:BAAALAADCgMIAwAAAA==.',Qu='Quinn:BAAALAAECggIDQAAAA==.',Ro='Rolling:BAACLAAFFH8qAAIOAAYIDBcECwDyAQAOAAYIDBcECwDyAQAsAAQKfzIAAg4ACAhuIZ4fAOQCAA4ACAhuIZ4fAOQCAAAA.',Se='Sebs:BAAALAAECgEIAQAAAA==.Seraphine:BAABLAAFFH8JAAIFAAIIKxM1WABtAAAFAAIIKxM1WABtAAAAAA==.',Sh='Short:BAAALAAFFAIIAgAAAA==.Shownor:BAABLAAFFH8GAAILAAYIDgGNcwBPAAALAAYIDgGNcwBPAAAAAA==.',Sp='Spoolerr:BAAALAAECgYICQAAAA==.',Su='Subs:BAAALAADCgEIAQAAAA==.',Te='Teele:BAAALAADCgcICQAAAA==.Ten:BAAALAADCgMIAwAAAA==.',Ti='Tipo:BAAALAAECgYIBgAAAA==.',Va='Vampirecain:BAAALAAECggICAAAAA==.',Wo='Wonderheaven:BAAALAAFFAIIAgAAAA==.',Xc='Xczxn:BAAALAAECgEIAQAAAA==.',Xm='Xmzk:BAAALAADCgYIBgAAAA==.',Xr='Xrp:BAAALAAFFAIIBAAAAA==.',Yv='Yveital:BAAALAAECgYIBgAAAA==.',Zo='Zoua:BAAALAAFFAIIAgAAAA==.',['一個']='一個卷卷:BAABLAAFFH8FAAILAAMIEAVoPwC0AAALAAMIEAVoPwC0AAAAAA==.',['一只']='一只小死骑啊:BAAALAAECgEIAQAAAA==.',['一抹']='一抹丶回忆:BAAALAADCgIIAgAAAA==.一抹浅笑:BAAALAADCgYIBgAAAA==.',['一眼']='一眼顶真:BAAALAAFFAIIBAAAAA==.',['一雨']='一雨纵横:BAABLAAECn8eAAIOAAgI1R3/DwBmAgAOAAgI1R3/DwBmAgAAAA==.',['七十']='七十七:BAAALAAECgYIDAAAAA==.',['七里']='七里香丷:BAAALAAFFAIIAgAAAA==.',['三岁']='三岁:BAABLAAFFH8GAAILAAIIsQT1mQA7AAALAAIIsQT1mQA7AAAAAA==.三岁学射射:BAAALAAECgYICwAAAA==.三岁学杀鸡:BAABLAAFFH8GAAICAAIIuQSdYgAyAAACAAIIuQSdYgAyAAAAAA==.',['三色']='三色喵:BAAALAAECgMIAwAAAA==.',['三鹿']='三鹿奶粉:BAAALAADCgQIBAAAAA==.',['不忘']='不忘初心:BAAALAAECgEIAgAAAA==.',['丝方']='丝方烬:BAAALAAFFAIIAgAAAA==.',['两年']='两年兽医毕业:BAAALAAECgYIBgAAAA==.',['丨小']='丨小心售人控:BAAALAAFFAIIAgAAAA==.',['丰川']='丰川祥子:BAAALAAECgYIBgAAAA==.',['丰胸']='丰胸圣手:BAABLAAECn8cAAMPAAgIWR4mNgCDAgAPAAgI5hwmNgCDAgAQAAYIJRtwRQCgAQAAAA==.',['丶流']='丶流云破晓:BAABLAAFFH8IAAIRAAIIOAubFgApAAARAAIIOAubFgApAAAAAA==.',['丶皮']='丶皮卡丘:BAAALAAECgIIAgAAAA==.',['丶莣']='丶莣記乁:BAAALAAECgQIBAAAAA==.',['举个']='举个梨子:BAAALAAECgYICwABLAAFFAgIAgASAAAAAA==.',['之子']='之子流年:BAACLAAFFH8IAAITAAUIQBcXDQBEAQATAAUIQBcXDQBEAQAsAAQKfxQAAxMACAhpH0MHAAoCABMACAjmHEMHAAoCABQAAghgG+BIAFsAAAAA.',['乌力']='乌力乌力:BAAALAAECgcIBwAAAA==.',['乔治']='乔治烤佩奇灬:BAAALAAECgYIBwAAAA==.',['乖乖']='乖乖兔:BAAALAADCgEIAQAAAA==.',['亇亽']='亇亽旳獨角戲:BAAALAADCgYIBgAAAA==.',['二十']='二十的回忆:BAAALAAECgYIDQAAAA==.',['二宝']='二宝哈嘻:BAABLAAFFH8GAAIVAAYIYgwbEwAeAQAVAAYIYgwbEwAeAQAAAA==.',['二贰']='二贰:BAAALAAECgEIAQAAAA==.',['云里']='云里灬雾里:BAAALAAECgEIAQAAAA==.',['五号']='五号牛牛:BAAALAAECgQIBAAAAA==.',['亦檬']='亦檬:BAAALAAECgYIEQAAAA==.',['人偶']='人偶迷城:BAABLAAECn8dAAIHAAgIZBEnLACHAQAHAAgIZBEnLACHAQAAAA==.',['亻俞']='亻俞心盗贝戎:BAAALAAECgMIAwAAAA==.',['今天']='今天晚上吃啥:BAAALAAECgcIBwAAAA==.',['从小']='从小就很黑丶:BAAALAAECgIIAgAAAA==.',['从来']='从来不消费:BAABLAAFFH8FAAIPAAMIdSTGGABEAQAPAAMIdSTGGABEAQAAAA==.',['伊莎']='伊莎玛拉:BAAALAAECgQIBAAAAA==.',['伊莲']='伊莲娜丶岚星:BAAALAAFFAIIAgAAAA==.',['伟大']='伟大的大伟:BAAALAADCgUIBQAAAA==.',['传统']='传统狐人萨满:BAAALAADCgIIAgAAAA==.',['伤心']='伤心猪大肠:BAABLAAFFH8NAAIHAAMIPBpaKADbAAAHAAMIPBpaKADbAAAAAA==.伤心羊腰子:BAABLAAFFH8JAAILAAIIMSCjcQBUAAALAAIIMSCjcQBUAAAAAA==.',['何以']='何以解优:BAAALAAECgYIDAAAAA==.',['你被']='你被牛打过:BAABLAAFFH8GAAMEAAYIXQ1+GwD/AAAEAAUICQ1+GwD/AAAHAAEIcAgCXQA3AAAAAA==.',['你麦']='你麦克疯掉了:BAAALAAFFAIIBAAAAA==.',['佩拉']='佩拉:BAABLAAFFH8GAAIEAAYIvxBxEwBPAQAEAAYIvxBxEwBPAQAAAA==.',['俩毛']='俩毛也是钱:BAAALAADCgMIAwAAAA==.',['俺翼']='俺翼:BAABLAAFFH8IAAIMAAIIjR+REgC6AAAMAAIIjR+REgC6AAAAAA==.',['假装']='假装很猛:BAAALAADCgIIAgAAAA==.',['元神']='元神丶:BAABLAAFFH8IAAIFAAIIzhvNSQCMAAAFAAIIzhvNSQCMAAABLAAFFAIICAACAGAVAA==.',['克洛']='克洛诺思:BAAALAAECgIIAgAAAA==.',['兰迪']='兰迪:BAABLAAFFH8QAAMWAAIIvyPAJQC/AAAWAAIIvyPAJQC/AAAXAAIIihEtHACRAAABLAAFFAYIGgAPAPoUAA==.',['兵主']='兵主:BAAALAAECgYICwAAAA==.',['兽授']='兽授:BAAALAAFFAYIBAAAAA==.',['内向']='内向法丝:BAAALAAECgIIAgAAAA==.',['冬瓜']='冬瓜你个西瓜:BAAALAAECgIIAgAAAA==.',['冰棍']='冰棍塞裤衩:BAAALAAFFAEIAQAAAA==.',['冲锋']='冲锋无悔:BAAALAADCggICAAAAA==.',['凉风']='凉风起:BAAALAAECgEIAQAAAA==.',['凶邪']='凶邪新月:BAAALAADCgIIAgAAAA==.',['凶鸟']='凶鸟:BAAALAAECgQIBAAAAA==.',['刘哒']='刘哒哒:BAAALAAFFAIIBAAAAA==.',['别动']='别动断了叫人:BAAALAAECgQIBAAAAA==.',['别问']='别问:BAAALAAECggIBgAAAA==.',['刺拳']='刺拳:BAAALAADCgQIBAAAAA==.',['力量']='力量的花生:BAAALAAECgYIBgAAAA==.',['加利']='加利福尼亚州:BAAALAADCgcIBwAAAA==.',['加尼']='加尼尔:BAAALAADCgYIBgAAAA==.',['动物']='动物保护协会:BAAALAAECgMIBAAAAA==.',['劳资']='劳资锤:BAAALAAECgYIBgAAAA==.',['北梦']='北梦:BAAALAADCgYIBgAAAA==.',['十六']='十六夜灬咲夜:BAAALAADCgIIAgAAAA==.',['十步']='十步杀一人:BAAALAADCgMIAwAAAA==.',['午後']='午後:BAABLAAFFH8NAAIYAAMILxpvBQAPAQAYAAMILxpvBQAPAQAAAA==.',['卖萌']='卖萌的喵声人:BAAALAAECgQIBAAAAA==.',['南来']='南来北往:BAAALAADCgcIBwAAAA==.',['压力']='压力暴大:BAAALAAECgEIAQAAAA==.',['厌水']='厌水鱼:BAAALAAFFAIIAgAAAA==.',['友哈']='友哈巴赫:BAAALAAFFAIIBAAAAA==.',['变相']='变相怪杰:BAAALAAECgYIBwAAAA==.',['叛逆']='叛逆的鲁智深:BAABLAAFFH8IAAIZAAIIahhQDgCgAAAZAAIIahhQDgCgAAABLAAFFAYIFAAFABsaAA==.',['口嗨']='口嗨可不行:BAAALAADCggICAAAAA==.',['可可']='可可笆娜娜:BAABLAAFFH8QAAIMAAYIqQU8GQDhAAAMAAYIqQU8GQDhAAAAAA==.',['向左']='向左:BAAALAAECgYIBgAAAA==.',['君倩']='君倩:BAAALAAECgQIBAAAAA==.',['咕咕']='咕咕:BAAALAAFFAIIAgAAAA==.',['咕噜']='咕噜丨敏:BAAALAAFFAIIAgAAAA==.',['哇喔']='哇喔谢谢你:BAAALAAFFAIIAgAAAA==.',['哞哞']='哞哞懒惰虫:BAAALAAECgcIAwAAAA==.',['喝醉']='喝醉的老虎:BAAALAADCgUIBQAAAA==.',['喵一']='喵一:BAABLAAFFH8KAAIMAAUI7BzVEQA/AQAMAAUI7BzVEQA/AQAAAA==.',['喵七']='喵七:BAABLAAFFH8MAAIMAAgIxRcwBAAdAgAMAAgIxRcwBAAdAgAAAA==.',['喵三']='喵三:BAABLAAFFH8MAAIMAAgI5xs0AwA/AgAMAAgI5xs0AwA/AgAAAA==.',['喵九']='喵九:BAABLAAFFH8VAAIVAAgIxRqIBAAsAgAVAAgIxRqIBAAsAgAAAA==.',['喵二']='喵二:BAABLAAFFH8JAAIMAAgIGBvFAgBWAgAMAAgIGBvFAgBWAgAAAA==.',['喵五']='喵五:BAABLAAFFH8IAAIMAAgIMxoUAwBEAgAMAAgIMxoUAwBEAgAAAA==.',['喵八']='喵八:BAABLAAFFH8XAAIVAAgIlxkVBAA8AgAVAAgIlxkVBAA8AgAAAA==.',['喵六']='喵六:BAABLAAFFH8PAAIMAAgI8hy1AgBZAgAMAAgI8hy1AgBZAgAAAA==.',['喵十']='喵十:BAABLAAFFH8SAAIVAAgI5huOAwBRAgAVAAgI5huOAwBRAgAAAA==.喵十一:BAABLAAFFH8aAAIVAAgIoR5qAgCDAgAVAAgIoR5qAgCDAgAAAA==.喵十七:BAABLAAFFH8cAAIVAAgI3hsmAwBjAgAVAAgI3hsmAwBjAgAAAA==.喵十三:BAABLAAFFH8XAAIVAAgI/hmHBAAsAgAVAAgI/hmHBAAsAgAAAA==.喵十二:BAABLAAFFH8WAAIVAAgIeRdNBQAUAgAVAAgIeRdNBQAUAgAAAA==.喵十五:BAABLAAFFH8NAAIVAAcISRMSCwCaAQAVAAcISRMSCwCaAQAAAA==.喵十八:BAABLAAFFH8RAAIVAAcIKxqOBgD0AQAVAAcIKxqOBgD0AQAAAA==.喵十六:BAABLAAFFH8XAAIVAAgIlxxDAwBdAgAVAAgIlxxDAwBdAgAAAA==.喵十四:BAABLAAFFH8WAAIVAAgIMxeCBQAOAgAVAAgIMxeCBQAOAgAAAA==.',['喵四']='喵四:BAABLAAFFH8HAAIMAAcIcA6JBgCkAQAMAAcIcA6JBgCkAQAAAA==.',['嘴强']='嘴强八零后:BAAALAAECgYIBwAAAA==.',['四十']='四十米砍刀:BAAALAAECgMIAwAAAA==.',['回忆']='回忆如困兽:BAAALAAECgIIAgAAAA==.',['困了']='困了就睡丶:BAAALAADCgcIBwAAAA==.',['圣光']='圣光合同工:BAAALAAECgMIAwAAAA==.圣光小王子:BAAALAAECgEIAQAAAA==.',['圣灵']='圣灵吹拂:BAABLAAECn8dAAIaAAcI0hmyMAAdAgAaAAcI0hmyMAAdAgAAAA==.',['地上']='地上的月影:BAACLAAFFH8PAAIWAAUIGBkrJgBLAQAWAAUIGBkrJgBLAQAsAAQKfxwAAhYABgj4Ht56APUBABYABgj4Ht56APUBAAAA.',['坐牢']='坐牢:BAAALAAFFAIIAgAAAA==.',['坤坤']='坤坤哥:BAAALAADCgEIAQAAAA==.',['墨児']='墨児:BAAALAAECgMIAwAAAA==.',['墩墩']='墩墩杯:BAAALAAECgMIAwAAAA==.',['夏婉']='夏婉沁:BAAALAADCgcIBwAAAA==.',['夏洛']='夏洛特凯尔:BAABLAAFFH8IAAMXAAYICgxsFABQAQAXAAYICgxsFABQAQAWAAIITxFCQQCdAAABLAAFFAgIBgAXAJghAA==.',['多尔']='多尔切比塔:BAABLAAFFH8kAAIaAAYIqxVlFgClAQAaAAYIqxVlFgClAQAAAA==.',['大六']='大六小鸡哦:BAAALAADCgEIAQAAAA==.大六小鸡啊:BAAALAADCgQIBAAAAA==.',['大典']='大典太:BAAALAAFFAgIAgAAAA==.大典太光世:BAABLAAFFH8GAAICAAQIBAgIGQD+AAACAAQIBAgIGQD+AAAAAA==.',['大叔']='大叔就是玩:BAAALAADCgYIBgAAAA==.',['大花']='大花花:BAAALAAECgYIDAAAAA==.',['大鹌']='大鹌鹑:BAABLAAFFH8GAAIEAAYIiBViBQD7AQAEAAYIiBViBQD7AQAAAA==.',['天启']='天启十人众:BAAALAAECgUIBQAAAA==.',['天选']='天选恶:BAABLAAFFH8GAAIOAAIIrBPLQACZAAAOAAIIrBPLQACZAAAAAA==.天选战:BAABLAAFFH8JAAICAAII8RixKwCkAAACAAII8RixKwCkAAAAAA==.天选盗:BAAALAADCggICAAAAA==.天选骑:BAABLAAFFH8OAAILAAQIPR3OTwDuAAALAAQIPR3OTwDuAAAAAA==.',['奥八']='奥八瑪:BAAALAADCggICAAAAA==.',['女少']='女少先队长:BAAALAADCgIIAgAAAA==.',['女尤']='女尤:BAABLAAFFH8IAAIbAAgI2BOFDgAqAgAbAAgI2BOFDgAqAgAAAA==.',['女明']='女明星花花:BAAALAADCgQIBAAAAA==.',['奶不']='奶不动就跑:BAAALAAFFAQIBAAAAA==.',['好吃']='好吃的番茄:BAAALAADCgIIAgAAAA==.',['好运']='好运:BAAALAAECgYICgAAAA==.',['嫣然']='嫣然:BAAALAAECgIIAgAAAA==.',['宁心']='宁心:BAABLAAFFH8SAAIaAAYIah21DAAIAgAaAAYIah21DAAIAgAAAA==.',['守法']='守法邪能大王:BAAALAADCgQIBAAAAA==.',['安妮']='安妮公主:BAAALAAECgYIBgAAAA==.',['宠物']='宠物商贩:BAAALAAECgYIDAAAAA==.',['审判']='审判:BAAALAAECgYIBgAAAA==.',['寂寞']='寂寞越人歌:BAABLAAFFH8IAAIHAAgIiAw/EQC7AQAHAAgIiAw/EQC7AQAAAA==.',['寒暄']='寒暄:BAAALAAECgcIEgAAAA==.寒暄兮语:BAAALAAFFAIIAgAAAA==.寒暄兮默:BAAALAAECgYIDwAAAA==.寒暄汹焽僧:BAAALAAECgYIDAAAAA==.寒暄焽訩貓:BAAALAAECgYIDgAAAA==.寒暄莫殇喻:BAAALAAECgYIBgAAAA==.寒暄莫萨曼:BAABLAAECn8eAAIFAAYITwyKYQDkAAAFAAYITwyKYQDkAAAAAA==.寒暄莫言:BAABLAAECn8VAAIOAAYIXhUPowCHAQAOAAYIXhUPowCHAQAAAA==.寒暄莫雨:BAAALAAFFAIIAgAAAA==.',['寰宇']='寰宇于天:BAAALAADCgcIBwAAAA==.',['寻梦']='寻梦仙人:BAAALAADCggICAAAAA==.',['射击']='射击:BAABLAAFFH8IAAIPAAUIYBdFTAAjAQAPAAUIYBdFTAAjAQAAAA==.',['小忮']='小忮:BAAALAAECgYICAAAAA==.',['小桥']='小桥流水:BAAALAADCgEIAQAAAA==.',['小泽']='小泽早安:BAAALAAECgIIAgAAAA==.',['小狼']='小狼叁号:BAAALAAECgUIBQAAAA==.',['小猪']='小猪呼噜噜:BAAALAAECgEIAQAAAA==.小猪宝宝:BAACLAAFFH8VAAMFAAUIoBm6HgBtAQAFAAUIoBm6HgBtAQAGAAUI9gQvLQDZAAAsAAQKfyMAAwUABghnI0QxAE4CAAUABghnI0QxAE4CAAYABgioDb56AFABAAEsAAUUBwgGAAUAvAcA.',['小管']='小管同学术:BAAALAADCggICQAAAA==.小管同学萨:BAAALAAECgYICwAAAA==.小管同学魔:BAAALAADCgMIAwAAAA==.',['小红']='小红足疗:BAAALAADCgEIAQAAAA==.',['小落']='小落落走丢了:BAABLAAFFH8MAAIFAAIIiA/iUQBqAAAFAAIIiA/iUQBqAAAAAA==.',['小虎']='小虎哥:BAABLAAFFH8mAAMCAAYIew55IwBYAQACAAYINg15IwBYAQAMAAUIUA+hGADqAAAAAA==.小虎歌:BAAALAAECgQICgAAAA==.小虎謌:BAABLAAFFH8ZAAILAAYI7BdxKQCXAQALAAYI7BdxKQCXAQAAAA==.小虎骑士:BAABLAAFFH8JAAMWAAYIpg0WKgA1AQAWAAYIKAkWKgA1AQAcAAMIFRKgEQBqAAAAAA==.',['少司']='少司命:BAAALAAFFAQIBAAAAA==.',['尖耳']='尖耳长眉光头:BAAALAAECgMIAwAAAA==.',['巴掌']='巴掌有点大:BAAALAAFFAIIBAAAAA==.',['希瓦']='希瓦女王乂:BAAALAAFFAIIBAAAAA==.',['帝狱']='帝狱咆哮:BAAALAAECgUIBgAAAA==.',['常青']='常青藤:BAAALAAECggICAAAAA==.',['幺丶']='幺丶鸡:BAAALAAECgQIBAAAAA==.',['幻视']='幻视:BAAALAAECgYICgAAAA==.',['幽灵']='幽灵灬壁垒:BAABLAAFFH8ZAAIPAAYIvyDYGwDLAQAPAAYIvyDYGwDLAQAAAA==.',['张思']='张思齐:BAABLAAFFH8GAAIbAAIIPxC4RwCOAAAbAAIIPxC4RwCOAAAAAA==.',['强电']='强电起搏器:BAAALAADCgEIAQAAAA==.',['徒手']='徒手杀敌:BAAALAAECgYIBgAAAA==.',['微震']='微震天:BAAALAAECgYIBgAAAA==.',['德艺']='德艺三馨:BAAALAAECgYIBgAAAA==.',['心斩']='心斩灵魂:BAAALAADCgYIBgAAAA==.',['忍冬']='忍冬和月见草:BAACLAAFFH8dAAMQAAYIuBzdBACRAQAQAAYIuBzdBACRAQAPAAEIcx8UhABQAAAsAAQKfysAAxAABwhiI2gFADQCABAABwgDI2gFADQCAA8ABghJHU98AFEBAAAA.',['忧郁']='忧郁波比:BAAALAAFFAEIAQAAAA==.',['忽必']='忽必劣:BAABLAAFFH8IAAIPAAIIgRGtXgCMAAAPAAIIgRGtXgCMAAAAAA==.',['恐龙']='恐龙扛狼扛:BAAALAAECgYIBgAAAA==.',['慒丶']='慒丶懆:BAACLAAFFH8FAAILAAMInRilJgD/AAALAAMInRilJgD/AAAsAAQKfx0AAgsACAirHw4qAMkCAAsACAirHw4qAMkCAAAA.',['我不']='我不是冰法:BAAALAAECgMIBAAAAA==.',['我只']='我只是个奶:BAAALAAFFAQIBAAAAA==.',['我笑']='我笑清风:BAABLAAFFH8sAAILAAUInBcRLwDfAAALAAUInBcRLwDfAAAAAA==.',['我要']='我要践踏你:BAAALAADCggICAAAAA==.',['战虍']='战虍:BAAALAAFFAMIAwAAAA==.',['戦轼']='戦轼:BAAALAAECgYIBgAAAA==.',['打窝']='打窝:BAABLAAFFH8IAAICAAgIDySuAgDVAgACAAgIDySuAgDVAgAAAA==.',['扛几']='扛几楼:BAAALAAECgEIAQAAAA==.',['执政']='执政官:BAAALAAFFAIIAgAAAA==.',['执酒']='执酒挽清歌:BAAALAADCgYIBgAAAA==.',['扬帆']='扬帆远航:BAAALAAECgYIBgAAAA==.',['找妹']='找妹子看夕阳:BAAALAAECgMIAwAAAA==.',['找姐']='找姐骑:BAACLAAFFH8JAAIWAAIIwhGuTgCTAAAWAAIIwhGuTgCTAAAsAAQKfxYAAhYACAghHFseACcCABYACAghHFseACcCAAAA.',['拒绝']='拒绝的刺:BAAALAAECgYIDQAAAA==.',['拿我']='拿我耙子来:BAABLAAECn8eAAIdAAYI2xtqFACQAQAdAAYI2xtqFACQAQAAAA==.',['持美']='持美行凶:BAAALAAECgYICQAAAA==.',['指尖']='指尖丶旋律:BAAALAAFFAIIBAAAAA==.',['握日']='握日摘星:BAAALAADCggICAAAAA==.',['放开']='放开那头牛:BAAALAAECgEIAQAAAA==.',['断片']='断片:BAABLAAFFH8SAAMeAAIIcBmmEgCWAAAeAAIIcBmmEgCWAAAVAAII7gXFIQAvAAABLAAFFAUIFwAWABUUAA==.',['方可']='方可无:BAAALAAECgYIBgAAAA==.',['施瓦']='施瓦辛格蕊:BAAALAAECgYIDQAAAA==.',['无心']='无心:BAAALAAECgQIBAAAAA==.',['无敌']='无敌坤坤:BAAALAAECgYICgABLAAECggIGAALAF0RAA==.',['早餐']='早餐上的诗集:BAAALAAECgcIBwAAAA==.',['早饭']='早饭想吃啥:BAAALAAFFAIIBAAAAA==.',['旬旬']='旬旬洵:BAAALAAECgYIBgAAAA==.',['明明']='明明是个弟弟:BAABLAAFFH8NAAIXAAYIMBuLCQD0AQAXAAYIMBuLCQD0AQAAAA==.',['星穹']='星穹:BAAALAAECgYICQAAAA==.',['春哥']='春哥儿:BAAALAADCgYIBgAAAA==.',['晚晚']='晚晚:BAABLAAFFH8IAAIaAAIIKBdkOQB+AAAaAAIIKBdkOQB+AAAAAA==.',['晚里']='晚里:BAABLAAFFH8GAAIaAAII1BalMQCMAAAaAAII1BalMQCMAAABLAAFFAgIDQAaAHkaAA==.晚里二:BAABLAAECn8aAAIaAAYIgxt8QgDNAQAaAAYIgxt8QgDNAQAAAA==.晚里五:BAABLAAECn8ZAAIaAAcIXRiCIAC3AQAaAAcIXRiCIAC3AQAAAA==.晚里六:BAAALAAFFAYIBAAAAA==.',['晦明']='晦明:BAAALAAECgIIAgAAAA==.',['暗夜']='暗夜影刃:BAAALAAECgIIAgAAAA==.',['暗战']='暗战牛宝宝:BAABLAAFFH8GAAIWAAYIlw1eIABtAQAWAAYIlw1eIABtAQAAAA==.',['暴力']='暴力熊:BAAALAAFFAIIAgAAAA==.',['暴风']='暴风雨城:BAABLAAECn8mAAMdAAYIug79JQD5AAAdAAYIug79JQD5AAAJAAUIvwTCXQCMAAAAAA==.',['月光']='月光鱼:BAAALAAECgEIAQAAAA==.',['月夜']='月夜越:BAAALAAECgYIBwAAAA==.',['月渎']='月渎:BAAALAAECgYICAAAAA==.',['月牙']='月牙猫:BAAALAAECgQIBAAAAA==.',['朝霞']='朝霞:BAACLAAFFH8ZAAIJAAYInB+vGgCzAQAJAAYInB+vGgCzAQAsAAQKfyoAAgkACAhJIW4lALgCAAkACAhJIW4lALgCAAAA.',['朴国']='朴国倡:BAAALAAECgYIBgAAAA==.',['机枪']='机枪熊:BAAALAAECgYIDgAAAA==.',['来自']='来自深渊一:BAAALAADCgYIBgAAAA==.',['杭州']='杭州赘婿:BAAALAAECgEIAQAAAA==.',['极光']='极光瑰夏:BAAALAADCggICAAAAA==.',['极限']='极限:BAAALAAECggICAAAAA==.',['林明']='林明美:BAAALAAECgQICQAAAA==.',['枫之']='枫之翼:BAAALAADCgcIBwAAAA==.',['枫岁']='枫岁月:BAAALAADCgEIAQAAAA==.',['柒天']='柒天漆夜:BAACLAAFFH8IAAIMAAMIQAXJJgBPAAAMAAMIQAXJJgBPAAAsAAQKfxgAAgwABwh5D45FAGsBAAwABwh5D45FAGsBAAAA.',['栖药']='栖药:BAABLAAFFH8OAAIRAAUIFxD6AgBNAQARAAUIFxD6AgBNAQAAAA==.',['桃花']='桃花再不斩:BAAALAADCgIIAgAAAA==.',['桑博']='桑博:BAAALAAFFAIIAgAAAA==.',['梓落']='梓落秋山:BAAALAAECgYIDAAAAA==.',['梦叨']='梦叨叨:BAAALAAECgIIAgAAAA==.',['梦哥']='梦哥哥:BAAALAAECgcICgAAAA==.',['梦游']='梦游猫:BAAALAAECgYIBgAAAA==.',['楚霸']='楚霸王:BAAALAADCgEIAQAAAA==.',['楼下']='楼下是佩奇:BAABLAAFFH8FAAIPAAIIGRPysgA3AAAPAAIIGRPysgA3AAAAAA==.',['槐桑']='槐桑:BAAALAAFFAIIBAAAAA==.',['樱桃']='樱桃肉丸子丷:BAAALAAECgQIBAAAAA==.',['橙柚']='橙柚柚:BAABLAAFFH8LAAIXAAQIPCB4EgBqAQAXAAQIPCB4EgBqAQAAAA==.',['欢迎']='欢迎业主回家:BAACLAAFFH8aAAMLAAYIeiS/CwD9AQALAAUIrSS/CwD9AQAfAAII2R8kCgDEAAAsAAQKfxsABAsABwg5JNVcADwCAAsABwjZI9VcADwCAA0ABAjcJKAdAKMBAB8AAwg9IPxFAK8AAAAA.',['欧阳']='欧阳嗯:BAAALAAECgIIAgAAAA==.',['死亡']='死亡领主:BAABLAAFFH8KAAILAAYI6Bz+BQBFAgALAAYI6Bz+BQBFAgAAAA==.',['水煮']='水煮牛鞭丶:BAACLAAFFH8MAAMJAAII3iHRNwCsAAAJAAIIYh7RNwCsAAAdAAEI9iT9GgBoAAAsAAQKfxsABAkACAgkHXhAAEoCAAkACAgwGnhAAEoCACAABAjNFK4QAAsBAB0AAggoIqtsALwAAAAA.',['氵蘭']='氵蘭彡:BAAALAAECgIIAgAAAA==.',['汪尔']='汪尔萨斯:BAABLAAFFH8RAAILAAYISRQ/KgCUAQALAAYISRQ/KgCUAQAAAA==.',['沙一']='沙一町丶:BAAALAAECgIIAgAAAA==.',['没味']='没味:BAAALAAECgUIBgAAAA==.',['没有']='没有馅的面包:BAAALAAFFAYIAwAAAA==.',['没蓝']='没蓝妮娅:BAAALAAFFAIIBAAAAA==.',['沧海']='沧海灬人无情:BAACLAAFFH8RAAMOAAQIXxXyEwBTAQAOAAQIXxXyEwBTAQARAAIIDAa0GABUAAAsAAQKfyAAAw4ACAgxHEZCAFsCAA4ACAgxHEZCAFsCABEACAgpDIUvAEIBAAAA.',['法尸']='法尸:BAAALAAECgYIBgAAAA==.',['流氓']='流氓头子:BAAALAAFFAIIBAAAAA==.',['流莺']='流莺毒:BAACLAAFFH8hAAIWAAYI/iXIBQAtAgAWAAYI/iXIBQAtAgAsAAQKf2cAAhYACAjJJJwQADgDABYACAjJJJwQADgDAAAA.',['流萤']='流萤:BAAALAAECgEIAQAAAA==.',['浅海']='浅海鱼:BAAALAAECgYIBwAAAA==.',['浮生']='浮生灬半世:BAAALAADCgIIAgAAAA==.',['海军']='海军上将泰勒:BAAALAAECgQIBAAAAA==.海军统帅:BAAALAAECgIIAgAAAA==.',['海绵']='海绵丶宝宝:BAAALAADCgEIAQAAAA==.',['消散']='消散:BAAALAAFFAIIAwAAAA==.',['混世']='混世小德:BAAALAAFFAIIAgAAAA==.',['清扬']='清扬婉兮:BAACLAAFFH8dAAIJAAYIrxdGHgCgAQAJAAYIrxdGHgCgAQAsAAQKfyYAAwkABgixH08mAIkBAB0ABgg5G/M5AIwBAAkABgjKHk8mAIkBAAAA.',['清源']='清源妙道真君:BAAALAAECggIDAAAAA==.',['清蒸']='清蒸鱼:BAAALAADCgIIAgAAAA==.',['清规']='清规:BAABLAAFFH8NAAIaAAMIzBASMQCpAAAaAAMIzBASMQCpAAABLAAFFAUIFwAWABUUAA==.',['清风']='清风圣:BAACLAAFFH8MAAIWAAMIWhvyKgCzAAAWAAMIWhvyKgCzAAAsAAQKfxYAAhYACAg6I5YyAKgCABYACAg6I5YyAKgCAAEsAAUUBQgsAAsAnBcA.',['源稚']='源稚生:BAABLAAECn8ZAAILAAcIMhgdSwBlAQALAAcIMhgdSwBlAQAAAA==.',['滚滚']='滚滚转圈圈:BAABLAAFFH8jAAIVAAYITCavBAAnAgAVAAYITCavBAAnAgAAAA==.',['漠影']='漠影丶:BAACLAAFFH80AAMLAAYIHSbnCAAdAgALAAYIECbnCAAdAgAfAAMIUCSGAwBKAQAsAAQKfx4AAwsABgjgJo86AJACAAsABgjcJo86AJACAB8AAwjKJiwtAFoBAAAA.',['火爆']='火爆法爷:BAAALAAECgYIBgAAAA==.',['炎爆']='炎爆:BAAALAADCgEIAQAAAA==.',['烦烦']='烦烦的手:BAABLAAFFH8aAAMLAAYIzhifJwCdAQALAAYIcBafJwCdAQANAAIIsBuzEgC2AAAAAA==.',['煎饼']='煎饼果籽:BAAALAAECgMIAwAAAA==.',['牙子']='牙子:BAABLAAECn8VAAIhAAYIPh9wBAC/AQAhAAYIPh9wBAC/AQAAAA==.',['牛一']='牛一宿:BAABLAAECn8WAAIHAAYIPxBiQgAUAQAHAAYIPxBiQgAUAQAAAA==.',['牛哞']='牛哞哞:BAAALAADCgIIAgAAAA==.',['牛爷']='牛爷爷来咯:BAAALAAECgYIBAAAAA==.',['特格']='特格维克:BAAALAAECgEIAQAAAA==.',['狂炫']='狂炫富婆画饼:BAABLAAFFH8IAAMiAAgI8wpTBgBaAQAiAAYIVQxTBgBaAQAjAAIIpQ/KFgCeAAAAAA==.',['狐狸']='狐狸精有點騷:BAAALAADCgUIBQAAAA==.',['独行']='独行:BAAALAAECgYIBwAAAA==.',['玉帝']='玉帝:BAAALAAECgUIBQAAAA==.玉帝重返天庭:BAAALAAECgYIBwAAAA==.玉帝重返寰宇:BAAALAAECgMIBgAAAA==.',['王多']='王多浴:BAABLAAFFH8GAAMLAAIInAw4lQA9AAALAAIIMwk4lQA9AAAfAAIIxArhFgA8AAABLAAFFAYIBgAHAAoXAA==.',['玙洁']='玙洁:BAAALAAECgcIDAAAAA==.',['玛嘉']='玛嘉烈:BAAALAADCgYIBgAAAA==.',['玛胖']='玛胖的大手:BAAALAAECgYIEgABLAAECgcIHQAaANIZAA==.',['玩具']='玩具刀:BAACLAAFFH8TAAMMAAIILxqPJgBRAAAMAAIILxqPJgBRAAACAAIICxYnRwBNAAAsAAQKfxkAAgIABgjAEldZAAwBAAIABgjAEldZAAwBAAEsAAUUBQgXABYAFRQA.',['珊珊']='珊珊來迟:BAABLAAECn8WAAIFAAYI+RkdZwC3AQAFAAYI+RkdZwC3AQAAAA==.',['珊瑚']='珊瑚海:BAAALAAFFAIIAgAAAA==.',['球球']='球球大帝:BAAALAAECgYIBgAAAA==.',['男尤']='男尤:BAAALAAECgYICgAAAA==.',['留恋']='留恋星空:BAAALAAFFAIIBAAAAA==.',['略恰']='略恰了比利:BAACLAAFFH8KAAIWAAIIQh6CWQBKAAAWAAIIQh6CWQBKAAAsAAQKfxQAAhYABwj1HU2cAL0BABYABwj1HU2cAL0BAAAA.',['疯一']='疯一样地男人:BAABLAAFFH8QAAIdAAIIHheMFQBFAAAdAAIIHheMFQBFAAAAAA==.',['白河']='白河静流:BAAALAAECgIIAgAAAA==.',['白玲']='白玲轩:BAAALAAECgIIAgAAAA==.',['白芷']='白芷动芳馨丶:BAACLAAFFH88AAMHAAYIVSHlEgCpAQAHAAUINCDlEgCpAQAEAAUIlR3KEABsAQAsAAQKfzAAAwcACAgRJBYIACEDAAcACAgRJBYIACEDAAQABAgiIBVEAK8AAAAA.',['白须']='白须哥:BAAALAAFFAIIAgAAAA==.白须哥哥:BAAALAADCgQIBAAAAA==.',['百里']='百里安歌:BAAALAAECgQIBAAAAA==.',['盐酸']='盐酸哌替啶:BAABLAAFFH8IAAIXAAgINhNsBgA0AgAXAAgINhNsBgA0AgAAAA==.',['盘丝']='盘丝大仙:BAABLAAFFH8KAAIkAAYI7gktFAA3AQAkAAYI7gktFAA3AQAAAA==.',['看撒']='看撒捏:BAAALAAECgMIAwAAAA==.',['真假']='真假人生:BAAALAAECgYICQAAAA==.',['真的']='真的是白给:BAACLAAFFH8aAAICAAYI+Ru9FAC5AQACAAYI+Ru9FAC5AQAsAAQKfxUABAwACAj1Gyc9AJABAAwABgjwFyc9AJABAAIABgg8FKaUAFwBAAMABAjdHSkaAFMBAAAA.',['眼睛']='眼睛有点迷:BAABLAAFFH8GAAIGAAYIQACDVwATAAAGAAYIQACDVwATAAAAAA==.',['瞄准']='瞄准:BAAALAAECgYIBgAAAA==.',['瞎搞']='瞎搞:BAABLAAFFH8LAAILAAIImhLxeABLAAALAAIImhLxeABLAAAAAA==.',['硝酸']='硝酸咪康唑:BAABLAAFFH8QAAMHAAgIrQ4AEADJAQAHAAgIrQ4AEADJAQAEAAEIvx0MLQBRAAAAAA==.',['硬汉']='硬汉阿宝:BAAALAAFFAIIAgAAAA==.',['示申']='示申茉莉:BAAALAAECgYIBwAAAA==.',['神仙']='神仙鱼:BAAALAAECgIIAgAAAA==.',['神医']='神医小华佗:BAABLAAFFH8tAAMWAAYILSQYCAAPAgAWAAYILSQYCAAPAgAXAAEI4RUMLwBGAAAAAA==.',['神月']='神月卡琳:BAABLAAFFH8UAAIIAAYIwCIgAQDwAQAIAAYIwCIgAQDwAQAAAA==.',['神经']='神经小哥:BAAALAAECgYICAAAAA==.',['神谕']='神谕:BAABLAAFFH8GAAIaAAIIOROnLACTAAAaAAIIOROnLACTAAAAAA==.',['离心']='离心丶鬼颜:BAABLAAFFH8GAAMlAAYI2BMOBQCOAAAbAAMIgBR4QgDlAAAlAAMIMBMOBQCOAAAAAA==.',['离法']='离法:BAABLAAFFH8GAAIbAAUIOhHdPQAQAQAbAAUIOhHdPQAQAQAAAA==.',['秦人']='秦人奶你:BAAALAAFFAIIBAAAAA==.',['稳重']='稳重猫咪:BAAALAAECgMIAwAAAA==.',['空条']='空条承太狼:BAACLAAFFH8HAAIJAAMIbglDMQDGAAAJAAMIbglDMQDGAAAsAAQKfxwAAgkACAjoFrBQABMCAAkACAjoFrBQABMCAAAA.',['突斩']='突斩:BAABLAAECn8UAAIOAAgIkA4FpQCEAQAOAAgIkA4FpQCEAQAAAA==.',['童年']='童年的哆啦:BAAALAADCgYIBgAAAA==.',['笑语']='笑语风橙:BAACLAAFFH89AAMQAAYIMx4oBAClAQAQAAYIyR0oBAClAQAPAAUIXBfPJQDlAAAsAAQKf0AAAw8ACAi5I0EVAAoDAA8ACAhnI0EVAAoDABAACAiZIHQbAIgCAAAA.',['等丶']='等丶待:BAAALAADCgQIBAAAAA==.',['繁华']='繁华似锦:BAAALAAECgUIBwAAAA==.',['红色']='红色皇后:BAAALAAECggIDAAAAA==.',['红鲤']='红鲤鱼:BAABLAAFFH8WAAIWAAgI7RpABABTAgAWAAgI7RpABABTAgAAAA==.',['纯棉']='纯棉的兔子猫:BAAALAAFFAYIAwAAAA==.',['维什']='维什戴尔:BAAALAAECgEIAQAAAA==.',['维尔']='维尔丶哔特弗:BAAALAAECgMIAwAAAA==.',['绷绷']='绷绷怪:BAAALAADCgcIBwAAAA==.',['绿壳']='绿壳:BAAALAADCgcIBwAAAA==.',['缘分']='缘分:BAAALAAFFAMIAwAAAA==.',['网瘾']='网瘾少女:BAACLAAFFH8IAAIFAAIIGxrKSACPAAAFAAIIGxrKSACPAAAsAAQKfyIAAwUACAjKG2o4ADYCAAUACAjKG2o4ADYCAAYAAwh6BeJ1AEgAAAAA.网瘾少年:BAACLAAFFH8JAAIPAAcI3h/GCwA1AgAPAAcI3h/GCwA1AgAsAAQKfxYAAg8ACAgZHakgAD0CAA8ACAgZHakgAD0CAAAA.',['罗雷']='罗雷斯曼:BAAALAADCggICAAAAA==.',['羽兒']='羽兒:BAAALAAECgQIBAAAAA==.',['翩若']='翩若丨惊鸿:BAAALAAFFAIIAgAAAA==.',['老天']='老天真:BAAALAAECggIDgAAAA==.',['老登']='老登丶:BAAALAADCgIIAgABLAAECggIGAALAF0RAA==.',['老蔡']='老蔡:BAABLAAECn8XAAILAAYIORfotACoAQALAAYIORfotACoAQAAAA==.',['老霸']='老霸霸:BAAALAAECgMIBgAAAA==.',['聿日']='聿日箋秋:BAAALAAECgYIBgAAAA==.',['肉蟹']='肉蟹堡儿丶:BAAALAADCgUIBQAAAA==.肉蟹煲丶:BAAALAADCggICQAAAA==.',['胖嘟']='胖嘟嘟得:BAABLAAFFH8GAAIHAAYIgRGdGABvAQAHAAYIgRGdGABvAQAAAA==.胖嘟嘟德二:BAABLAAFFH8QAAIHAAYIxgxoHQA/AQAHAAYIxgxoHQA/AQAAAA==.',['脆皮']='脆皮没仇恨:BAACLAAFFH8MAAMOAAQIzQ9XNgDcAAAOAAQIzQ9XNgDcAAARAAEIwgZCHQApAAAsAAQKfxYAAg4ABgicH/0jANIBAA4ABgicH/0jANIBAAAA.',['脑袋']='脑袋有点晕:BAAALAAFFAIIBAAAAA==.',['自攻']='自攻牛:BAABLAAFFH8OAAIWAAUImQowNADtAAAWAAUImQowNADtAAAAAA==.',['艾玛']='艾玛格兰杰:BAABLAAFFH8NAAIJAAUIwRHoOAANAQAJAAUIwRHoOAANAQABLAAFFAcIHgAMAAYfAA==.',['花开']='花开若相依:BAAALAAFFAYIBAAAAA==.',['花式']='花式彡:BAAALAAECgYIBgAAAA==.',['花心']='花心野男人:BAABLAAFFH8LAAIMAAgIzR73AQCDAgAMAAgIzR73AQCDAgAAAA==.',['花落']='花落知多少乀:BAAALAAECgQIBAAAAA==.',['苏菲']='苏菲:BAAALAAFFAQIBAAAAA==.',['若叶']='若叶睦:BAABLAAFFH8GAAIEAAYIVgKUKQBwAAAEAAYIVgKUKQBwAAAAAA==.',['若无']='若无花又怎样:BAABLAAFFH8UAAMFAAYIABOOCwCGAQAFAAYIABOOCwCGAQAGAAMIoAyuIQCpAAABLAAFFAgIBgAPAN0aAA==.',['苦修']='苦修:BAAALAAECggIAQAAAA==.',['苦水']='苦水鱼:BAAALAAECgYIDwAAAA==.',['范廸']='范廸塞尔:BAABLAAFFH8UAAIQAAYIhR/AAwCzAQAQAAYIhR/AAwCzAQAAAA==.',['茉莉']='茉莉奶绿:BAAALAADCgYIBgAAAA==.',['荀令']='荀令君丶:BAAALAAECgUIAwAAAA==.',['荒野']='荒野的呼唤:BAAALAADCgMIAwAAAA==.',['荣归']='荣归:BAAALAADCgMIAwAAAA==.',['菟阿']='菟阿姨:BAAALAAECgYIBgAAAA==.',['菠萝']='菠萝快车:BAAALAAECgYIBgAAAA==.菠萝排骨:BAAALAAECgYICwAAAA==.',['萌萌']='萌萌哒丨萨满:BAABLAAFFH8GAAMFAAYIkg8mFwD5AAAFAAQIXQwmFwD5AAAGAAIItAQNKACXAAAAAA==.',['萨特']='萨特先祖:BAAALAAECgUIBQAAAA==.',['葛城']='葛城王牌:BAAALAAECgMIAwAAAA==.',['蓝岚']='蓝岚丶坠:BAACLAAFFH8qAAIGAAYIICMkCwABAgAGAAYIICMkCwABAgAsAAQKfx8AAgYACAh5IucPABIDAAYACAh5IucPABIDAAAA.',['蓝霹']='蓝霹雳:BAAALAAECgcICgAAAA==.',['薛定']='薛定谔的猫:BAACLAAFFH8GAAIRAAII/QuUFABiAAARAAII/QuUFABiAAAsAAQKfyIAAhEABwjYDwYuAEsBABEABwjYDwYuAEsBAAAA.',['藏海']='藏海:BAABLAAFFH8TAAIPAAcItCFBCwA7AgAPAAcItCFBCwA7AgAAAA==.',['虎牙']='虎牙丶:BAABLAAECn8YAAILAAgIXRFTjADlAQALAAgIXRFTjADlAQAAAA==.',['蜻蜓']='蜻蜓隊長:BAAALAAECgEIAQAAAA==.',['蠻蠻']='蠻蠻漂亮:BAAALAADCgEIAQAAAA==.',['街尾']='街尾杂货铺:BAAALAAECgYIBgAAAA==.',['要发']='要发泽:BAAALAADCgMIAwAAAA==.',['见面']='见面不如怀念:BAAALAADCgMIAwAAAA==.',['让光']='让光照耀你:BAAALAAECgQIBQAAAA==.',['诧紫']='诧紫:BAAALAADCgEIAQAAAA==.',['请先']='请先杀我队友:BAABLAAFFH8HAAILAAcISBByGQDZAQALAAcISBByGQDZAQAAAA==.',['诺雅']='诺雅情心:BAAALAAECgIIAgAAAA==.',['谁是']='谁是木头人:BAAALAAECgYIBgAAAA==.',['谢哥']='谢哥哥:BAACLAAFFH9MAAIWAAgIuh9BAwB6AgAWAAgIuh9BAwB6AgAsAAQKf0MAAxYACAj2JNoQADcDABYACAj2JNoQADcDABwAAQgtAkN/AB4AAAAA.',['豆豆']='豆豆堂:BAAALAAECgMIBwAAAA==.',['贝先']='贝先生:BAABLAAFFH8HAAIWAAQIxhqdNQDgAAAWAAQIxhqdNQDgAAAAAA==.',['贝克']='贝克汉姆:BAAALAAECgQIBQAAAA==.',['贰贰']='贰贰叁肆:BAAALAAECgIIAgAAAA==.',['赵露']='赵露思:BAAALAAECgMIAwAAAA==.',['超人']='超人力霸王:BAAALAAECgQIBQAAAA==.超人强:BAAALAAECgYIBwAAAA==.',['超级']='超级玛丽:BAABLAAFFH8NAAMdAAYIHxsfCgCxAAAJAAYIHxumJACDAQAdAAIIAB4fCgCxAAAAAA==.',['路胜']='路胜:BAAALAAECgUIBgAAAA==.',['路过']='路过的查拉图:BAABLAAFFH8GAAMgAAII4BQfBgCRAAAJAAII9RLfSACXAAAgAAIIURMfBgCRAAAAAA==.',['过路']='过路的人:BAAALAAECgYIDAAAAA==.',['进击']='进击的塔塔开:BAAALAAECgUIBQAAAA==.',['迪亚']='迪亚大菠萝:BAABLAAFFH8fAAMMAAYIYhNQEQBFAQAMAAYINhNQEQBFAQACAAUIWgccLAAPAQAAAA==.',['迪光']='迪光:BAAALAAFFAIIAgAAAA==.',['追風']='追風老灯:BAAALAADCgQIBAAAAA==.',['追风']='追风老灯:BAAALAADCgIIAgAAAA==.',['退伍']='退伍老兵:BAACLAAFFH8VAAMHAAUIhBfkGgBYAQAHAAUIhBfkGgBYAQAEAAUIOQaiHwDNAAAsAAQKfyMAAwcACAhyI2ISAMgCAAcACAhyI2ISAMgCAAQABwhLEaJEAKIBAAAA.',['逍遥']='逍遥墨士:BAABLAAFFH8FAAIFAAII0wpMZgBWAAAFAAII0wpMZgBWAAAAAA==.逍遥酒家:BAACLAAFFH8KAAIFAAII+AabYQBfAAAFAAII+AabYQBfAAAsAAQKfycAAgUACAjLDHxTABIBAAUACAjLDHxTABIBAAAA.逍遥陌士:BAAALAAFFAIIBAAAAA==.',['那个']='那个法式:BAAALAADCgYIBgAAAA==.',['邪丨']='邪丨能:BAABLAAFFH8NAAIOAAgICxorBgCEAgAOAAgICxorBgCEAgAAAA==.',['邪恶']='邪恶猕猴桃:BAAALAAFFAIIAgAAAA==.邪恶糯米饭:BAAALAAFFAIIAgAAAA==.',['酸菜']='酸菜鱼:BAAALAAECgQIBQAAAA==.',['释永']='释永行:BAAALAAECgYICwAAAA==.',['里奥']='里奥尼斯:BAAALAAFFAMIAwAAAA==.',['銘劍']='銘劍風流:BAABLAAFFH8OAAIWAAgI8A71FwCZAQAWAAgI8A71FwCZAQAAAA==.',['钝钝']='钝钝子:BAAALAAECgEIAQAAAA==.',['钢背']='钢背灬传说刂:BAABLAAFFH8LAAIGAAIIySDgJACeAAAGAAIIySDgJACeAAAAAA==.',['钱哆']='钱哆哆灬:BAAALAAFFAIIBAABLAAFFAYILQAWAC0kAA==.',['铁锤']='铁锤妹妹丶:BAAALAAECgMIBgAAAA==.',['银狼']='银狼:BAAALAAECgYIBgAAAA==.',['长大']='长大不得了丶:BAAALAAECgUIBQAAAA==.',['长崎']='长崎素世:BAAALAAECgYICwAAAA==.',['闪解']='闪解人衣:BAABLAAFFH8LAAIPAAMIoxT3awCRAAAPAAMIoxT3awCRAAAAAA==.',['阐释']='阐释者:BAABLAAFFH8XAAMGAAYIlR+yEAC/AQAGAAYIlR+yEAC/AQAFAAEI6wGwfwAqAAAAAA==.',['阿卡']='阿卡多:BAAALAAECgIIAgAAAA==.',['阿哲']='阿哲学长:BAAALAAFFAIIBAAAAA==.',['阿尼']='阿尼斯:BAAALAAECgQICAAAAA==.',['阿弥']='阿弥陀佛:BAABLAAFFH8HAAILAAMIAR0NKwDsAAALAAMIAR0NKwDsAAAAAA==.',['阿拉']='阿拉尼:BAAALAAECgQIBgAAAA==.',['阿撒']='阿撒托斯:BAAALAAECgYIBgAAAA==.',['阿狄']='阿狄忒修斯:BAAALAAECgEIAQAAAA==.',['阿西']='阿西灬法克刂:BAABLAAECn8UAAICAAYIzSRcNgBcAgACAAYIzSRcNgBcAgAAAA==.',['陈晖']='陈晖洁:BAAALAAECgYIBgAAAA==.',['陌上']='陌上浅歌幕:BAABLAAFFH8OAAIVAAYIsh0BDQB7AQAVAAYIsh0BDQB7AQAAAA==.',['雪落']='雪落无痕:BAABLAAFFH8RAAILAAUIdw/yLQDiAAALAAUIdw/yLQDiAAAAAA==.',['雷电']='雷电芽衣:BAABLAAFFH8LAAIMAAMIuxAMIwBoAAAMAAMIuxAMIwBoAAAAAA==.',['雷霆']='雷霆雨露:BAABLAAECn8UAAMFAAYIlxNdlQBUAQAFAAYIlxNdlQBUAQAGAAEIkwMw2AAqAAABLAAECgcIHQAaANIZAA==.',['雾绡']='雾绡:BAAALAADCgMIAwAAAA==.',['雾里']='雾里灬云里:BAAALAAECgcIBwAAAA==.',['霍格']='霍格大爷:BAAALAAECggICAAAAA==.',['霜降']='霜降:BAABLAAFFH8OAAILAAMIDxf2XQCXAAALAAMIDxf2XQCXAAABLAAFFAUIFwAWABUUAA==.',['霸主']='霸主:BAAALAAECgYICgAAAA==.',['霸道']='霸道的大叔:BAAALAAECgYIBgAAAA==.',['青山']='青山如是:BAABLAAECn8ZAAICAAgIpBuUHAAGAgACAAgIpBuUHAAGAgAAAA==.',['青柑']='青柑丨普洱:BAAALAAFFAIIBAABLAAFFAgIBgALALoRAA==.',['青楚']='青楚:BAAALAAECgQIBAAAAA==.',['青浦']='青浦小糍佬:BAAALAAECgYIBgAAAA==.',['青澀']='青澀:BAAALAADCgEIAQAAAA==.',['非油']='非油炸:BAAALAAECgEIAQAAAA==.',['风兽']='风兽:BAAALAAECgYIDAAAAA==.',['风卷']='风卷残云:BAABLAAFFH8RAAIaAAYI3CD5CABAAgAaAAYI3CD5CABAAgAAAA==.',['风四']='风四哥:BAAALAAECggIBgAAAA==.',['风圣']='风圣:BAAALAAECgYIDAAAAA==.',['风德']='风德:BAAALAAECgYIDAAAAA==.',['风法']='风法:BAAALAAECgYICwAAAA==.',['风潜']='风潜:BAAALAAECgYIBgAAAA==.',['风绾']='风绾暮晴雪:BAAALAAFFAgIBAAAAA==.',['风语']='风语萨:BAABLAAFFH8nAAMOAAYIdRLRJwBbAQAOAAYI3A/RJwBbAQARAAQI5RKBCgCmAAAAAA==.',['风起']='风起一盏盏:BAAALAAECgQIBAAAAA==.',['风黑']='风黑:BAAALAAECgYIDwAAAA==.',['饭哆']='饭哆哆:BAAALAAFFAIIAgAAAA==.',['马桶']='马桶超人:BAAALAAFFAIIBAAAAA==.',['骑上']='骑上烂摩托:BAABLAAFFH8IAAIWAAMIkxLzGgDuAAAWAAMIkxLzGgDuAAAAAA==.',['麻匪']='麻匪马邦德:BAAALAAECgYIBgAAAA==.',['黄河']='黄河丨入海流:BAAALAAFFAIIAgAAAA==.',['黄花']='黄花鱼:BAABLAAFFH8FAAIPAAIIaR4mNwC1AAAPAAIIaR4mNwC1AAAAAA==.',['黑化']='黑化肥发灰:BAAALAADCgEIAQAAAA==.',['黑心']='黑心棉:BAABLAAFFH8KAAIFAAII7QxLVABoAAAFAAII7QxLVABoAAAAAA==.',['黑色']='黑色新娘:BAABLAAFFH8KAAIJAAIIpg6LVABIAAAJAAIIpg6LVABIAAABLAAFFAUIFwAWABUUAA==.',['黑锋']='黑锋骑士:BAAALAAECgQIBAAAAA==.',['龍繫']='龍繫爾:BAAALAAECgYIDAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end