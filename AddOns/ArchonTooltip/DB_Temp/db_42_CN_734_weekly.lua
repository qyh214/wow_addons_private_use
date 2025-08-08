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
 local lookup = {'Druid-Restoration','DemonHunter-Havoc','Mage-Fire','Priest-Discipline','Priest-Holy','Priest-Shadow','Evoker-Preservation','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Protection','Monk-Brewmaster','Rogue-Assassination','Rogue-Subtlety','Shaman-Elemental','Shaman-Restoration','Warrior-Fury','Warrior-Protection','Warrior-Arms','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Destruction','Paladin-Retribution','Druid-Balance','DemonHunter-Vengeance','Shaman-Enhancement','Monk-Mistweaver','Druid-Guardian','Mage-Arcane','Druid-Feral','Mage-Frost','Monk-Windwalker','Warlock-Demonology','Evoker-Devastation','Hunter-Survival','Warlock-Affliction','Paladin-Holy',}; local provider = {region='CN',realm='海达希亚',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ak='Akoe:BAAAKgAECggICAAAAA==.Akoo:BAAAKgADCggIGAAAAA==.Akuu:BAAAKgAECggIEgAAAA==.',Al='Alcoho:BAAAKgAECggICAAAAA==.',Bl='Blyat:BAAAKgAFFAgIBAAAAA==.',Cl='Cloudvzai:BAABKgAFFH9BAAIBAAgIESRVAAAxAgABAAgIESRVAAAxAgAAAA==.',De='Demomine:BAABKgAFFH8HAAICAAMI8hVpJwDZAAACAAMI8hVpJwDZAAAAAA==.',Dk='Dktank:BAAAKgAECgIIAgAAAA==.',Im='Imfiredup:BAABKgAFFH8PAAIDAAQIkyWrEQAMAQADAAQIkyWrEQAMAQAAAA==.Imicedown:BAAAKgADCggICAAAAA==.',Iv='Ivanna:BAACKgAFFH8qAAMEAAgIkxdwAgCTAQAEAAgIBRNwAgCTAQAFAAUISRdoCwBsAQAqAAQKfycABAUACAiRGr0lALsBAAUACAhAF70lALsBAAYABAjmDYtEAOIAAAQAAwhOFCZOANwAAAAA.',Ki='Kirto:BAAAKgAECgEIAQAAAA==.Kittywo:BAAAKgAECgcIAQAAAA==.',Ma='Mainz:BAAAKgAFFAQIBAAAAA==.',Mo='Moonightss:BAAAKgADCgUIBQAAAA==.',Po='Ponderist:BAAAKgAECgQIBAAAAA==.',Ra='Rainn:BAAAKgADCggICAAAAA==.',Sa='Santamina:BAECKgAFFH8YAAIHAAgIVh5jAAB6AgAHAAgIVh5jAAB6AgAqAAQKfxYAAgcACAgwH8cLALABAAcACAgwH8cLALABAAAA.',Sh='Shiry:BAAAKgAFFAYIAgAAAA==.',So='Soulaxe:BAAAKgAECggICAAAAA==.Souldk:BAABKgAFFH8UAAMIAAYIqhQ5FQByAQAIAAYInxQ5FQByAQAJAAYI4gX6CgDQAAAAAA==.',St='Stankss:BAABKgAFFH8MAAIKAAQIrhJ0DAC5AAAKAAQIrhJ0DAC5AAAAAA==.Stonn:BAABKgAFFH8SAAILAAYILRDaAwAQAQALAAYILRDaAwAQAQAAAA==.',To='Tortville:BAACKgAFFH8UAAMEAAQIjQzqDQCYAAAEAAMIUQzqDQCYAAAFAAQI+wbLGAB6AAAqAAQKfxYAAgUACAiUEI8/ABYBAAUACAiUEI8/ABYBAAAA.',Vi='Vitruvius:BAACKgAFFH85AAMMAAgIKCU+AQDYAgAMAAgIKCU+AQDYAgANAAQICCI4AwAmAQAqAAQKfzoAAwwACAiNJmEEAMACAA0ACAidJHoDAMMCAAwACAhEJmEEAMACAAAA.',Xe='Xeno:BAAAKgADCggIEAAAAA==.Xenoblade:BAABKgAFFH8RAAIOAAMIzRtJDgD2AAAOAAMIzRtJDgD2AAAAAA==.',['一句']='一句顶一万句:BAAAKgAFFAYIAQABKgAFFAgICAAMAMYWAA==.',['一招']='一招大海无量:BAAAKgAFFAIIAgAAAA==.',['一粒']='一粒丶仙丹:BAABKgAECn8UAAIEAAgIKRvQFQAWAgAEAAgIKRvQFQAWAgAAAA==.',['一素']='一素年一:BAAAKgAECgQIBAAAAA==.',['一老']='一老萨一:BAABKgAFFH8JAAIPAAIIDhIJKAB/AAAPAAIIDhIJKAB/AAAAAA==.',['七宗']='七宗罪一傲慢:BAAAKgAECgEIAQAAAA==.七宗罪一暴怒:BAABKgAFFH8OAAQQAAUIxRV+GQDxAAAQAAQI9hl+GQDxAAARAAQI0AXYBwCPAAASAAEIMgmAFABOAAAAAA==.',['三磷']='三磷酸腺苷啊:BAABKgAFFH8JAAMGAAcIPQ/qDwAIAQAGAAYI3wzqDwAIAQAFAAEIZhqSPQBFAAAAAA==.',['不羡']='不羡丶仙:BAABKgAECn8WAAIPAAgI1R3SGAA/AgAPAAgI1R3SGAA/AgAAAA==.',['专属']='专属小狗:BAAAKgADCggICAAAAA==.',['丘比']='丘比特之神射:BAACKgAFFH9LAAMTAAcIlh/OBACHAQATAAcIlh/OBACHAQAUAAQIRyAlDgAZAQAqAAQKfyQAAxMACAiiJV4YAJgCABMACAiiJV4YAJgCABQABwjoE3VBAB0BAAAA.',['两发']='两发和平卫士:BAAAKgAFFAMIAwAAAA==.',['丽桑']='丽桑德拉:BAAAKgAECggICAAAAA==.',['乂永']='乂永恒乂:BAAAKgAECgQIBgAAAA==.',['久久']='久久:BAABKgAFFH8FAAITAAUIXwRmEgACAQATAAUIXwRmEgACAQAAAA==.',['九生']='九生:BAAAKgAFFAQIAgAAAA==.',['乱红']='乱红飞过秋去:BAAAKgAECggIDgABKgAFFAgIEAAVANkjAA==.',['云青']='云青青兮丶:BAAAKgAECgIIAgAAAA==.',['人艰']='人艰不拆法:BAAAKgAECggICAAAAA==.人艰不拆萨:BAAAKgAFFAYIBAAAAA==.',['伊利']='伊利蛋的表哥:BAAAKgAECgIIAgAAAA==.',['伊邪']='伊邪娜美:BAAAKgAFFAIIAgAAAA==.',['传承']='传承:BAAAKgAECgYIBgAAAA==.',['信仰']='信仰精灵:BAABKgAFFH8QAAIQAAYIZyCzCADNAQAQAAYIZyCzCADNAQAAAA==.',['偷星']='偷星星的蘑菇:BAABKgAFFH8GAAITAAYIkg8NGgAuAQATAAYIkg8NGgAuAQAAAA==.',['兔子']='兔子猫猫:BAAAKgADCgIIAgAAAA==.',['兜兜']='兜兜风:BAAAKgAECgYICwAAAA==.',['全球']='全球的闪电链:BAAAKgAECgIIBQAAAA==.',['其实']='其实是死骑:BAAAKgAECggICwAAAA==.',['冬青']='冬青:BAAAKgAFFAIIAwAAAA==.',['凌丶']='凌丶霜:BAABKgAFFH8QAAMKAAgIixLVBwCUAQAKAAgI/w/VBwCUAQAWAAQIzxtQFwD9AAAAAA==.',['凤雅']='凤雅玲:BAAAKgAECgMIAwABKgAFFAgIUgAXAAoeAA==.',['切糕']='切糕:BAAAKgAECggICAAAAA==.',['加里']='加里瑟斯:BAACKgAFFH8wAAIWAAUINSXmCQAxAQAWAAUINSXmCQAxAQAqAAQKfx4AAhYACAjlIdMrAG8CABYACAjlIdMrAG8CAAAA.',['卡伦']='卡伦西:BAAAKgAECgcICgAAAA==.',['卡提']='卡提希娅:BAABKgAFFH8IAAIKAAgIhSAMAgCUAgAKAAgIhSAMAgCUAgAAAA==.',['叁斧']='叁斧子半:BAAAKgAFFAQIBAAAAA==.',['古爾']='古爾丹:BAABKgAFFH8GAAIVAAYIwxL9DAB0AQAVAAYIwxL9DAB0AQAAAA==.',['可可']='可可偶吧:BAAAKgADCgEIAQAAAA==.',['台台']='台台:BAAAKgADCggICAAAAA==.',['名字']='名字太难想了:BAABKgAFFH8IAAIRAAQI6ASfCwBvAAARAAQI6ASfCwBvAAAAAA==.',['含笑']='含笑凋零:BAABKgAFFH8OAAMCAAYIFiDjDQClAQACAAYIFiDjDQClAQAYAAYICxSqCAAZAQAAAA==.',['吹角']='吹角连营:BAABKgAFFH8NAAIQAAgIShfeBAA5AgAQAAgIShfeBAA5AgAAAA==.',['咏玖']='咏玖星花火:BAAAKgAECggIDQAAAA==.',['咖啡']='咖啡伴酒:BAAAKgADCgIIAgAAAA==.',['咸鱼']='咸鱼大作战:BAABKgAFFH85AAIDAAgICyMUAgC5AgADAAgICyMUAgC5AgAAAA==.',['啵啵']='啵啵的二头肌:BAABKgAFFH8MAAIZAAgI9Rw+AwA7AgAZAAgI9Rw+AwA7AgAAAA==.',['囚困']='囚困者:BAAAKgAECgMIAwAAAA==.',['囡鼐']='囡鼐瓶子:BAAAKgAECgEIAQAAAA==.',['国宝']='国宝猫猫:BAABKgAECn8gAAIaAAgIug0fMAAdAQAaAAgIug0fMAAdAQAAAA==.',['地火']='地火:BAAAKgADCgEIAQAAAA==.',['地狱']='地狱蛮妞:BAAAKgADCgcIBwAAAA==.',['堂岛']='堂岛之龙:BAAAKgADCggICAAAAA==.',['夏和']='夏和小:BAACKgAFFH9NAAMEAAgIkSEWAADCAgAEAAgIkSEWAADCAgAFAAMIfxPGJwCjAAAqAAQKfyYABAQACAhyIkIJAI4CAAQACAjiIUIJAI4CAAUACAhxEisuAIwBAAYABAiwGDY4ACgBAAAA.',['夏筱']='夏筱雨:BAAAKgAECgcICgAAAA==.',['夜月']='夜月刀歌:BAAAKgAFFAEIAgAAAA==.',['夜醉']='夜醉弦楼:BAAAKgADCggICAAAAA==.',['大地']='大地惊雷:BAAAKgADCgUIBQAAAA==.',['大壮']='大壮丶:BAABKgAFFH8NAAMTAAgIqxiUGAA3AQATAAQIZxiUGAA3AQAUAAUIUhafHwD4AAAAAA==.',['大有']='大有:BAAAKgAECggICAAAAA==.',['天一']='天一剑魔:BAAAKgAECgcIBwAAAA==.',['天哥']='天哥:BAAAKgADCggICAAAAA==.',['天语']='天语清音:BAACKgAFFH8JAAMFAAYIgQpCEwAYAQAFAAUI9wlCEwAYAQAEAAEINQ0pMABRAAAqAAQKfxwAAgUACAgCFDUpAKcBAAUACAgCFDUpAKcBAAAA.',['天选']='天选魔眼:BAABKgAFFH8IAAITAAQI3iPYCgArAQATAAQI3iPYCgArAQAAAA==.',['太平']='太平骑士:BAAAKgADCggIHQAAAA==.',['太极']='太极八荒:BAABKgAFFH8JAAIKAAgILhvEBgCzAQAKAAgILhvEBgCzAQAAAA==.',['太阳']='太阳当空照:BAAAKgAECggICAAAAA==.',['奇洛']='奇洛:BAABKgAFFH8dAAIbAAQIewdNBgBsAAAbAAQIewdNBgBsAAAAAA==.',['奥莉']='奥莉娃:BAABKgAFFH8GAAIXAAYIUgusHgApAQAXAAYIUgusHgApAQAAAA==.',['好一']='好一朵娇花:BAAAKgAECgUIBQAAAA==.',['如是']='如是闻:BAAAKgADCgQIBAAAAA==.',['妖娆']='妖娆的舞姿:BAAAKgAECggIDQAAAA==.',['子夜']='子夜幽兰:BAABKgAFFH8GAAIWAAYIMA6DJQBTAQAWAAYIMA6DJQBTAQAAAA==.',['宁姚']='宁姚:BAAAKgAECgYIBgAAAA==.',['寒江']='寒江收残月:BAAAKgAECggIDgAAAA==.',['寿与']='寿与天琦:BAABKgAECn8fAAIcAAgImw6QHABBAQAcAAgImw6QHABBAQAAAA==.寿与天齐么:BAABKgAECn8YAAQdAAgIPwe2GgDaAAAdAAgIPwe2GgDaAAAXAAQIxgXvSwBVAAABAAQIKAEthAAZAAAAAA==.',['小亚']='小亚雄:BAAAKgAECgYIBgAAAA==.',['小小']='小小赖:BAAAKgAECgUIBQAAAA==.小小钟:BAAAKgAECgEIAQAAAA==.',['小敏']='小敏姐姐:BAAAKgADCggICAAAAA==.',['小猪']='小猪存钱罐:BAABKgAFFH8HAAMeAAQI1SKEBAAPAQAeAAQIHyGEBAAPAQADAAMIQyCFGADtAAAAAA==.',['小田']='小田山:BAAAKgAECggICwAAAA==.',['小笼']='小笼包包:BAAAKgAECgIIAgAAAA==.',['小葱']='小葱拌豆腐:BAAAKgADCgUIBQAAAA==.',['就是']='就是不绷带:BAABKgAECn8YAAIFAAgIbyATCgCKAgAFAAgIbyATCgCKAgAAAA==.',['崂山']='崂山道士:BAAAKgADCgEIAQAAAA==.',['川北']='川北凉粉:BAAAKgAECgEIAQAAAA==.',['巨人']='巨人:BAABKgAFFH8VAAIJAAQIWxRIHgCxAAAJAAQIWxRIHgCxAAAAAA==.',['巴布']='巴布:BAABKgAECn8YAAIRAAgINhieDwDBAQARAAgINhieDwDBAQAAAA==.',['并刀']='并刀如水:BAAAKgAFFAIIAgABKgAFFAgIBgAWAOkKAA==.',['幸十']='幸十二:BAAAKgAECgEIAQAAAA==.',['幸运']='幸运的范范:BAAAKgAFFAMIAwAAAA==.',['弗里']='弗里德曼:BAACKgAFFH8GAAIWAAIIfw7rOgCTAAAWAAIIfw7rOgCTAAAqAAQKfycAAhYACAgdHkcwAGACABYACAgdHkcwAGACAAAA.',['律法']='律法女娲:BAACKgAFFH8iAAIWAAUIChSfHQD4AAAWAAUIChSfHQD4AAAqAAQKfxsAAhYACAjTGpRfAN0BABYACAjTGpRfAN0BAAAA.',['忍者']='忍者神龟:BAAAKgADCgcIBwAAAA==.',['恒月']='恒月丶:BAAAKgADCgEIAQAAAA==.',['恶魔']='恶魔之握:BAAAKgADCggICAAAAA==.恶魔唯伊:BAAAKgAECgEIAQAAAA==.',['我只']='我只会玩鸟:BAAAKgADCggICAAAAA==.',['我叫']='我叫王宝强:BAAAKgAECgIIAgAAAA==.',['战丶']='战丶凡尘:BAAAKgAFFAIIAgAAAA==.战丶晨:BAAAKgAECgUIBQAAAA==.',['托尼']='托尼大人:BAACKgAFFH8KAAITAAMIqBZSKwDYAAATAAMIqBZSKwDYAAAqAAQKfxYAAhMACAjGEMVoAHgBABMACAjGEMVoAHgBAAAA.',['折丶']='折丶戟:BAABKgAECn8WAAMQAAgIXR8aIgAOAgAQAAgINB8aIgAOAgASAAYITxuPMgArAQAAAA==.',['抬头']='抬头浅笑:BAAAKgAECgEIAQAAAA==.',['拉格']='拉格斯炉火:BAABKgAFFH8GAAITAAYI2wtmGAA4AQATAAYI2wtmGAA4AQAAAA==.',['指尖']='指尖起舞:BAAAKgADCggIBwAAAA==.',['挽歌']='挽歌盗圣:BAAAKgAECggICAAAAA==.挽歌神牧:BAAAKgAECggICAABKgAFFAgIBwAFAM4fAA==.',['旌术']='旌术:BAAAKgAECgIIAgAAAA==.',['无冬']='无冬城的月光:BAABKgAFFH8GAAIWAAYIbg/aIgBhAQAWAAYIbg/aIgBhAQAAAA==.',['无相']='无相之月:BAACKgAFFH8ZAAIMAAQIIxXpGADhAAAMAAQIIxXpGADhAAAqAAQKfx0AAgwACAinGecTAPoBAAwACAinGecTAPoBAAAA.',['星辰']='星辰苍穹:BAABKgAFFH8IAAIRAAgIPgtGAwB/AQARAAgIPgtGAwB/AQAAAA==.',['星雨']='星雨流暄:BAAAKgADCgQIBAAAAA==.',['星韵']='星韵邀月:BAAAKgADCggIDAAAAA==.',['是梦']='是梦:BAACKgAFFH8qAAQGAAgIoiC0AAATAgAGAAcIXyK0AAATAgAEAAYIvA+UCgBsAQAFAAEIwQzRHgBDAAAqAAQKfyMAAgYACAjYJKwFANICAAYACAjYJKwFANICAAAA.',['普罗']='普罗蒂萨:BAAAKgADCgMIAwAAAA==.',['暗月']='暗月印记:BAAAKgAECgIIAgAAAA==.',['暴走']='暴走本子:BAABKgAFFH8GAAIPAAYIZBWKGwCyAAAPAAYIZBWKGwCyAAAAAA==.',['末日']='末日者行:BAAAKgAECgUIBQAAAA==.',['杖剑']='杖剑走天涯:BAAAKgAECgIIBAAAAA==.',['杰克']='杰克妹子:BAACKgAFFH8GAAIfAAUIvA85BABBAQAfAAUIvA85BABBAQAqAAQKfxgAAh8ACAj2FkAiAMwBAB8ACAj2FkAiAMwBAAAA.',['梅林']='梅林疏芳:BAAAKgAECgEIAQAAAA==.',['梦游']='梦游者紫琦:BAAAKgAECgQIBAAAAA==.',['槑小']='槑小猎:BAAAKgAECgMIAwAAAA==.',['此髯']='此髯故忧伤:BAAAKgAECggICAAAAA==.',['武魂']='武魂艾丽卡:BAAAKgADCgcIBwAAAA==.',['汤姆']='汤姆猫:BAACKgAFFH8RAAIgAAMIYxImDQDNAAAgAAMIYxImDQDNAAAqAAQKfyAAAiAACAiCG5cFAAcCACAACAiCG5cFAAcCAAAA.',['沧海']='沧海:BAAAKgAFFAQIBAAAAA==.',['法老']='法老王:BAAAKgADCggIDQAAAA==.',['泡泡']='泡泡奶霸:BAAAKgADCgIIAgAAAA==.',['浪里']='浪里个浪:BAAAKgAECgcIBwAAAA==.',['海达']='海达叁世:BAAAKgAFFAQIBAAAAA==.',['清晨']='清晨的风:BAAAKgAECgMIAwAAAA==.',['清风']='清风刀:BAAAKgADCgcIBwAAAA==.',['渣渣']='渣渣:BAAAKgADCgIIAgAAAA==.',['漂浮']='漂浮炸弾:BAACKgAFFH9SAAIXAAgICh5gBACLAgAXAAgICh5gBACLAgAqAAQKfyQAAhcACAhRI1kaAGoCABcACAhRI1kaAGoCAAAA.',['漫天']='漫天飞射:BAAAKgAECggIEQABKgAFFAYICQAVAJYWAA==.',['灬淡']='灬淡陌灬:BAAAKgAECggICgAAAA==.',['灵魂']='灵魂鬼火:BAABKgAECn8WAAIgAAgIIhZJFQDPAQAgAAgIIhZJFQDPAQAAAA==.',['炁体']='炁体源流:BAAAKgAFFAcIBAAAAA==.',['炽光']='炽光:BAAAKgADCggICAAAAA==.',['烈日']='烈日灼阳:BAAAKgADCgEIAQAAAA==.',['烧饼']='烧饼:BAAAKgADCgQIBAAAAA==.',['爱情']='爱情臭豆腐:BAAAKgAECgMIAwAAAA==.',['狮心']='狮心茉莉:BAAAKgADCgIIAgAAAA==.',['猪蛋']='猪蛋蛋:BAABKgAFFH8FAAIDAAUILwjZBgAYAQADAAUILwjZBgAYAQAAAA==.',['瑟莱']='瑟莱德丝:BAAAKgAECgYIBgAAAA==.',['瓦萨']='瓦萨骑:BAAAKgAECgUIAwAAAA==.',['甘道']='甘道夫:BAAAKgAECgYIBwAAAA==.',['生人']='生人不治:BAAAKgAECgMIAwAAAA==.',['电闪']='电闪雷鸣:BAABKgAECn8fAAMPAAgIiRW/OwCGAQAPAAgIiRW/OwCGAQAOAAEIAgI8gwASAAAAAA==.',['疯狂']='疯狂豪哥:BAAAKgAECggICAAAAA==.',['白毫']='白毫银针:BAAAKgAECgIIAgAAAA==.',['白色']='白色的白:BAAAKgAECgQIBAAAAA==.',['神王']='神王宙斯:BAACKgAFFH8RAAIWAAgIByCDAwCrAgAWAAgIByCDAwCrAgAqAAQKfxYAAhYACAjvE3MuAGABABYACAjvE3MuAGABAAAA.',['童童']='童童爱:BAAAKgADCgMIAwAAAA==.',['笙落']='笙落:BAAAKgAECggIBwAAAA==.',['筱芙']='筱芙:BAAAKgADCggICAAAAA==.',['粿条']='粿条超人:BAABKgAECn9DAAIBAAgI6SJhAgCxAgABAAgI6SJhAgCxAgAAAA==.',['紫南']='紫南京:BAAAKgAECggICAAAAA==.',['紫色']='紫色千幻:BAAAKgAECgUIBQABKgAFFAgIUAAXABcmAA==.紫色幻箭:BAAAKgAFFAIIAgAAAA==.紫色狼牙:BAAAKgAFFAQIBAAAAA==.',['红龙']='红龙奇洛:BAABKgAFFH8eAAMHAAYI+h2SAQC6AQAHAAYI+h2SAQC6AQAhAAIIrQiFHABzAAAAAA==.',['纪检']='纪检骑士:BAABKgAFFH8NAAIWAAMIXB2TPQD5AAAWAAMIXB2TPQD5AAABKgAFFAgIBgAfAJUSAA==.',['纯丨']='纯丨真:BAABKgAFFH8IAAMEAAQIsiP7BgAnAQAEAAQIsiP7BgAnAQAFAAQIdxELDgDLAAAAAA==.',['绵绵']='绵绵:BAAAKgADCgEIAQAAAA==.',['缘翼']='缘翼比根:BAACKgAFFH8vAAICAAgIHhiBDgCbAQACAAgIHhiBDgCbAQAqAAQKfykAAgIACAjcHLkmAB8CAAIACAjcHLkmAB8CAAAA.',['缭乱']='缭乱:BAAAKgAFFAMIAwAAAA==.',['罗红']='罗红霉素:BAABKgAECn8UAAIPAAgIEBfzOQCNAQAPAAgIEBfzOQCNAQAAAA==.',['老夫']='老夫在此:BAAAKgAECgUIBwAAAA==.老夫来也:BAAAKgAECgIIAgAAAA==.老夫的龙人:BAAAKgADCgEIAgAAAA==.',['老鬼']='老鬼:BAAAKgADCggICgAAAA==.',['聖骑']='聖骑士:BAABKgAFFH8GAAIKAAYIDQi9FADTAAAKAAYIDQi9FADTAAAAAA==.',['肉蟹']='肉蟹煲:BAAAKgAECgUICAAAAA==.',['胖三']='胖三郎:BAAAKgADCgIIAgAAAA==.',['胖子']='胖子打他:BAAAKgAFFAYIBAAAAA==.',['胖蒜']='胖蒜丶:BAAAKgADCgEIAQAAAA==.',['艾米']='艾米丽:BAAAKgAECgQIBgAAAA==.',['芙兰']='芙兰朵露:BAAAKgAFFAQIBAAAAA==.',['花间']='花间未眠:BAABKgAFFH8JAAMeAAUIjhZ1CgDbAAAeAAQIYBZ1CgDbAAADAAUIbw5/HgDbAAAAAA==.',['芸梦']='芸梦飘雨:BAABKgAECn8cAAQUAAgIVRynGAALAgAUAAgIehunGAALAgATAAMIGx1TkQAJAQAiAAII3hEdHABKAAAAAA==.',['芸海']='芸海深蓝:BAAAKgAECgcIBwAAAA==.',['苏拉']='苏拉呢:BAABKgAFFH8UAAIMAAQI9R0LFAARAQAMAAQI9R0LFAARAQABKgAFFAUIMAAWADUlAA==.',['英雄']='英雄不朽:BAABKgAFFH8HAAIWAAYIHA7LFABQAQAWAAYIHA7LFABQAQAAAA==.',['萌萌']='萌萌哒:BAACKgAFFH8VAAIVAAQIihMHGgC3AAAVAAQIihMHGgC3AAAqAAQKfyQAAxUACAg+IS8DAKECABUACAg+IS8DAKECACMAAQjRDl1CAD0AAAAA.',['萝之']='萝之一目:BAACKgAFFH8FAAIeAAII5Q5xFwB8AAAeAAII5Q5xFwB8AAAqAAQKfxsAAh4ACAi3G0UYAD4CAB4ACAi3G0UYAD4CAAAA.',['萨满']='萨满:BAAAKgADCggICAAAAA==.',['蓝瑟']='蓝瑟犹豫:BAAAKgAFFAEIAQAAAA==.',['蔚然']='蔚然橙风:BAABKgAECn8ZAAMIAAcI2R6+LgD5AQAIAAcIdx2+LgD5AQAJAAUIxxtJNAD7AAABKgAFFAgIBQAQAKkWAA==.',['藏丶']='藏丶锋:BAABKgAFFH8RAAMCAAgITByxBgA7AgACAAgITByxBgA7AgAYAAMIQgG6IQBWAAAAAA==.',['虚灵']='虚灵之刃丷:BAABKgAECn8dAAIMAAgI6B+gEgAKAgAMAAgI6B+gEgAKAgAAAA==.',['虾哥']='虾哥哥嗷:BAAAKgAECgcIBwAAAA==.',['血疫']='血疫圆舞曲:BAAAKgAECgcIDAAAAA==.',['訷巠']='訷巠覀覀:BAACKgAFFH8NAAIDAAYIrB1HDQAuAQADAAYIrB1HDQAuAQAqAAQKfxQAAh4ACAgnJqEEAOwCAB4ACAgnJqEEAOwCAAAA.',['认真']='认真我就输了:BAAAKgAECggICQAAAA==.',['讨厌']='讨厌:BAACKgAFFH9bAAMGAAgImSQrAAC9AgAGAAgImSQrAAC9AgAFAAIIlwJ+PwA5AAAqAAQKfyQAAwYACAhtJsAEAN0CAAYACAhtJsAEAN0CAAUAAQiZDQ2RADgAAAAA.',['豆腐']='豆腐配酒:BAAAKgAECggIDQAAAA==.',['赛塔']='赛塔洛斯:BAABKgAFFH8IAAIWAAIIGSM5XgC0AAAWAAIIGSM5XgC0AAAAAA==.',['走位']='走位不存在的:BAAAKgADCgQIBAAAAA==.',['路西']='路西法寒冬:BAAAKgADCgYIBgAAAA==.',['辛巴']='辛巴:BAAAKgAECggIDwAAAA==.',['迪尔']='迪尔梅林:BAAAKgAECgQIBwABKgAFFAgIUgAXAAoeAA==.',['迷乱']='迷乱耀阳:BAABKgAFFH8TAAQFAAgItR5cAQCaAgAFAAgItR5cAQCaAgAEAAQIzBCPDQA+AQAGAAYIORWbFAC/AAAAAA==.',['逆鳞']='逆鳞:BAABKgAECn8XAAMHAAgIahbBCADyAQAHAAgIahbBCADyAQAhAAEIUALsbgAKAAABKgAFFAgIGgAKADESAA==.',['部落']='部落骑士:BAABKgAECn8gAAMKAAgIdggVOACsAAAKAAgI7AUVOACsAAAWAAQICgsrHgGRAAAAAA==.',['醉梦']='醉梦忆生:BAAAKgAFFAIIAgAAAA==.',['阿瓦']='阿瓦达啃大瓜:BAAAKgAFFAQIBAAAAA==.',['陪你']='陪你去看星星:BAACKgAFFH8RAAIeAAMIAx0eDgDzAAAeAAMIAx0eDgDzAAAqAAQKfygABB4ACAhwHTQTACcCAB4ACAhwHTQTACcCAAMABgjUCgFqAMsAABwAAgidEp15AHcAAAEqAAUUCAgGAB8AlRIA.',['随机']='随机嗨姓刷子:BAAAKgADCgEIAQAAAA==.',['隔壁']='隔壁老王:BAABKgAECn8fAAIWAAgISxYTWwCtAQAWAAgISxYTWwCtAQAAAA==.',['雨終']='雨終晴天:BAACKgAFFH8RAAMkAAcIdxCkAgAqAQAkAAcIdxCkAgAqAQAWAAEISwNWUwBCAAAqAAQKfyIAAxYACAinHflNAAgCABYACAinHflNAAgCACQACAgEEu4dAHIBAAAA.',['雲烟']='雲烟过眼:BAAAKgAECggIDQAAAA==.',['零榆']='零榆:BAAAKgAFFAIIBAAAAA==.',['雷神']='雷神索尔:BAAAKgADCgEIAQAAAA==.',['雷诺']='雷诺杰克逊:BAAAKgAFFAIIAgAAAA==.',['雾去']='雾去哪了:BAABKgAFFH8IAAMEAAQIfRaIGADNAAAEAAQIfRaIGADNAAAGAAIIHge8JQBhAAAAAA==.',['青青']='青青兰若:BAAAKgADCggICAAAAA==.',['静葔']='静葔椛开:BAABKgAFFH8YAAITAAQIMhqtJgDrAAATAAQIMhqtJgDrAAABKgAFFAgIEAAVANkjAA==.',['顾熙']='顾熙:BAAAKgADCggICAAAAA==.',['领先']='领先主演的:BAAAKgADCggICAAAAA==.',['风之']='风之天香:BAAAKgAECgEIAgAAAA==.',['风月']='风月不入眸:BAAAKgAFFAEIAQAAAA==.',['风行']='风行者紫琦:BAABKgAECn8YAAMTAAgIAQrUZAApAQATAAgIAQrUZAApAQAUAAEIxQV5TwAfAAAAAA==.',['飞天']='飞天:BAAAKgADCgMIAwAAAA==.',['飞翔']='飞翔的乌鸦:BAABKgAFFH8GAAIXAAYIJhWAFgBkAQAXAAYIJhWAFgBkAQAAAA==.',['骑馬']='骑馬倚斜桥:BAABKgAFFH8IAAIWAAQIFA+GYQCtAAAWAAQIFA+GYQCtAAAAAA==.',['鬼卿']='鬼卿:BAABKgAFFH8qAAMTAAYI0RurCQDDAQATAAYI0RurCQDDAQAUAAIIaQshHQCGAAAAAA==.',['魔女']='魔女:BAAAKgAFFAQIAwAAAA==.',['魔礼']='魔礼寿:BAAAKgADCgEIAQAAAA==.魔礼海:BAAAKgADCgEIAgAAAA==.魔礼青:BAAAKgADCgEIAgAAAA==.',['鲸落']='鲸落于海:BAAAKgAECggIBgAAAA==.',['麻辣']='麻辣烫:BAAAKgAFFAgIBAAAAA==.',['黎夕']='黎夕:BAAAKgAECgMIBAAAAA==.',['黑皮']='黑皮体育生丶:BAAAKgAECgcIBwAAAA==.',['黑索']='黑索协奏曲:BAAAKgAECgcIEgAAAA==.',['龍龖']='龍龖龘:BAAAKgAECgMIAwAAAA==.',['龙神']='龙神女猎:BAAAKgAFFAIIAgAAAA==.',['龙骨']='龙骨牡丹:BAAAKgAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end