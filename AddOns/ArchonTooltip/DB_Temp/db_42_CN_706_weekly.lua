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
 local lookup = {'DeathKnight-Unholy','Paladin-Retribution','DemonHunter-Havoc','DemonHunter-Vengeance','Rogue-Outlaw','Rogue-Assassination','Rogue-Subtlety','Priest-Holy','Priest-Discipline','Mage-Frost','Druid-Balance','Druid-Restoration','Monk-Mistweaver','Evoker-Devastation','Mage-Arcane','Druid-Feral','Druid-Guardian','Unknown-Unknown','Mage-Fire','Paladin-Protection','Shaman-Restoration','Priest-Shadow','Warlock-Destruction','DeathKnight-Frost','Warlock-Demonology','Warlock-Affliction','Monk-Windwalker','Warrior-Arms','Warrior-Fury','Monk-Brewmaster','Hunter-Marksmanship','Hunter-BeastMastery','DeathKnight-Blood','Shaman-Enhancement','Shaman-Elemental','Evoker-Augmentation','Paladin-Holy','Warrior-Protection',}; local provider = {region='CN',realm='暴风祭坛',name='CN',type='weekly',zone=42,date='2025-08-08',data={Av='Avernus:BAAAKgAFFAIIAgAAAA==.',Br='Bringdead:BAAAKgAECgUICgAAAA==.Bringfox:BAAAKgAECgYICgAAAA==.Bringmagic:BAAAKgAECgQICwAAAA==.',Bt='Btelgeusex:BAABKgAFFH8KAAIBAAYIFQ+ZGQBQAQABAAYIFQ+ZGQBQAQAAAA==.',Ca='Cantice:BAAAKgAFFAEIAQAAAA==.',Ch='Chara:BAAAKgAECgEIAQAAAA==.',Cr='Crusade:BAABKgAFFH8YAAICAAgIgx4ZDQD+AQACAAgIgx4ZDQD+AQAAAA==.',Di='Dida:BAAAKgADCggICAAAAA==.',['Dé']='Démon:BAABKgAFFH8FAAIBAAUIIAwXIgARAQABAAUIIAwXIgARAQAAAA==.',Ea='Earg:BAABKgAFFH8IAAMDAAQICxmSIgDzAAADAAQICxmSIgDzAAAEAAQIRwKGIABeAAAAAA==.',Ed='Edwardteach:BAACKgAFFH8SAAMFAAYIURdnAQCSAQAFAAYIURdnAQCSAQAGAAQIcQT6IwCIAAAqAAQKfxYABAUACAjyJP0AAOoCAAUACAjRJP0AAOoCAAcABAixFt8kANsAAAYAAQjEJH4/AGAAAAAA.',Ee='Eeko:BAAAKgAECgQIBQAAAA==.',Ez='Ezri:BAABKgAFFH8JAAIBAAUIbx2eCwBXAQABAAUIbx2eCwBXAQAAAA==.Ezrn:BAAAKgADCgMIAwAAAA==.',Fi='Finewu:BAAAKgAECgEIAQAAAA==.',Fl='Flora:BAAAKgAECgUIBQAAAA==.',Fo='Foncés:BAAAKgAECgEIAQAAAA==.',Gl='Gloria:BAACKgAFFH8OAAMIAAMIdgptLgCLAAAIAAMIPAptLgCLAAAJAAMIxAUbEgBoAAAqAAQKfxsAAwgACAiWFMUQAH0BAAgACAgTFMUQAH0BAAkAAwguD/UfAI0AAAAA.',Ha='Happy:BAAAKgAECgYICQAAAA==.',Ho='Holybaby:BAAAKgADCgcIBwAAAA==.',Ir='Ireul:BAAAKgAECgEIAQAAAA==.',Ja='Jacque:BAAAKgAECggIDgAAAA==.',Ji='Jina:BAAAKgAECgUIDAAAAA==.',Ka='Kannime:BAABKgAECn8XAAIKAAgIDCGBDQCWAgAKAAgIDCGBDQCWAgAAAA==.Kay:BAAAKgAFFAMIAwAAAA==.',Ku='Kuroneko:BAAAKgAFFAMIAwAAAA==.',La='Latsiimh:BAAAKgAFFAYIBAAAAA==.',Lu='Luckin:BAAAKgAECggICAAAAA==.',Ma='Marriott:BAAAKgAECgEIAQAAAA==.',Me='Meio:BAAAKgADCggIEAAAAA==.',Mi='Mioone:BAAAKgAECgEIAQAAAA==.',Na='Naldo:BAABKgAFFH8MAAMLAAgIuhIfCAAbAgALAAgIuhIfCAAbAgAMAAQI5RCsDgArAQAAAA==.',Op='Opsdd:BAAAKgAECgQIBAAAAA==.Opsdh:BAABKgAFFH8IAAIDAAgIxhj7BgAzAgADAAgIxhj7BgAzAgAAAA==.Opspala:BAAAKgAECgYIBgAAAA==.',Ph='Philomena:BAABKgAFFH8LAAIBAAYIfxtiDgATAQABAAYIfxtiDgATAQABKgAFFAgIGgANAG0WAA==.',Pk='Pk:BAAAKgADCgYIBgAAAA==.',Te='Tenderness:BAAAKgADCggIDAAAAA==.',Th='Thrush:BAABKgAFFH8FAAIGAAUIcw+uCQAuAQAGAAUIcw+uCQAuAQAAAA==.',Tr='Traitor:BAAAKgAECgEIAQAAAA==.',Vo='Voiïstopal:BAABKgAFFH8GAAIKAAYIBhWTBwBLAQAKAAYIBhWTBwBLAQAAAA==.',Yu='Yukisama:BAABKgAFFH8JAAIOAAQIwRblDwARAQAOAAQIwRblDwARAQAAAA==.Yunshixd:BAABKgAFFH8RAAMLAAYIriT1CAAnAQALAAYIriT1CAAnAQAMAAQIXwdQEQCrAAAAAA==.',Zz='Zzwolf:BAAAKgADCgMIAwAAAA==.',['一头']='一头大叔:BAAAKgAECggICAAAAA==.',['一念']='一念乂逍遥:BAAAKgADCggICAAAAA==.',['一把']='一把小骨头:BAAAKgAFFAYIBAAAAA==.',['一杯']='一杯柚柚酱:BAAAKgAFFAYIAwAAAA==.',['七零']='七零四张医师:BAAAKgAFFAQIAQAAAA==.',['万象']='万象皆杀:BAABKgAFFH8IAAIGAAgIGRmSAgCQAgAGAAgIGRmSAgCQAgAAAA==.',['三代']='三代血色老法:BAAAKgAECgIIAgAAAA==.',['上海']='上海萌牛:BAACKgAFFH8PAAMKAAMIjBkSCQDlAAAKAAMIjBkSCQDlAAAPAAMIVQpZLQCvAAAqAAQKf0YAAwoACAhbJF8FAOQCAAoACAg0JF8FAOQCAA8ACAiKIVILAKMCAAAA.',['丌涅']='丌涅:BAAAKgAECggIDgAAAA==.',['与子']='与子巨馍:BAAAKgAFFAEIAQAAAA==.',['专业']='专业的小德:BAAAKgAECgEIAQAAAA==.',['丨丶']='丨丶丨丶:BAAAKgAECgUIBQAAAA==.',['丨野']='丨野蛮教主:BAACKgAFFH8KAAICAAIIMBBKRwBvAAACAAIIMBBKRwBvAAAqAAQKfx8AAgIACAj0Fi9RAMoBAAIACAj0Fi9RAMoBAAAA.',['丶是']='丶是雨诺啊:BAAAKgAECggICAAAAA==.',['丶血']='丶血小贱:BAAAKgAECgEIAQAAAA==.',['丶雨']='丶雨诺丶:BAABKgAFFH8GAAIBAAQIUhmjEQDzAAABAAQIUhmjEQDzAAAAAA==.丶雨诺啊:BAAAKgAECggICAAAAA==.丶雨诺阿:BAAAKgAECgIIAgAAAA==.',['乄卝']='乄卝:BAAAKgAECgMIAwAAAA==.',['乄蓝']='乄蓝色妖姬:BAAAKgAECgMIAwAAAA==.',['乌拉']='乌拉乌拉:BAAAKgAFFAYIAgAAAA==.乌拉乌拉乌拉:BAACKgAFFH8SAAQQAAQIIAtuBgCPAAAQAAIIDQtuBgCPAAAMAAIIBBtRKACEAAALAAIIRgvPXgA8AAAqAAQKfxkABAwACAggGK0gAMMBAAwABwjvGa0gAMMBABAABgh+FlAOAL8BABEAAQgkAU4+AAQAAAEqAAUUBggCABIAAAAA.',['乌龙']='乌龙花茶:BAAAKgADCgQIBgAAAA==.',['乌龟']='乌龟的黑头:BAAAKgAECgYICgAAAA==.',['乔伊']='乔伊波伊:BAAAKgADCgYIBgAAAA==.',['九八']='九八七:BAABKgAFFH8FAAIBAAUIERj+DAAvAQABAAUIERj+DAAvAQAAAA==.',['二宫']='二宫沙树:BAAAKgADCgIIAgAAAA==.',['五星']='五星农场主:BAAAKgAECgQIAgAAAA==.',['亮瞎']='亮瞎你狗眼:BAAAKgAECgcIDgAAAA==.',['亲爱']='亲爱的热爱的:BAAAKgADCggICAAAAA==.',['仄仄']='仄仄:BAACKgAFFH8KAAICAAYIfhv2AAD8AQACAAYIfhv2AAD8AQAqAAQKfx8AAgIACAgqFjd/AJkBAAIACAgqFjd/AJkBAAAA.',['今晚']='今晚吊七你:BAABKgAFFH8OAAMPAAgIaRpwBABnAgAPAAgI1BlwBABnAgATAAQITxOlCgBNAQAAAA==.',['他们']='他们都会:BAAAKgADCggICAAAAA==.',['以梦']='以梦:BAAAKgAECgcIDAAAAA==.',['伊十']='伊十六夜:BAAAKgAFFAEIAQAAAA==.',['优势']='优势在我:BAABKgAFFH8IAAIUAAgIMxIsBQCyAQAUAAgIMxIsBQCyAQAAAA==.',['何阿']='何阿姨:BAAAKgADCgEIAQAAAA==.',['你又']='你又:BAACKgAFFH8TAAIVAAMIUyT1EwA3AQAVAAMIUyT1EwA3AQAqAAQKfyAAAhUACAidH3QOAOYBABUACAidH3QOAOYBAAAA.',['你妻']='你妻负我阿:BAAAKgADCgIIAgAAAA==.',['你家']='你家鸽鸽:BAABKgAFFH8MAAMLAAQIhBrCEAD3AAALAAQIhBrCEAD3AAAMAAMIdgZcMQBTAAABKgAFFAgIBAASAAAAAA==.',['佢老']='佢老豆:BAABKgAFFH8MAAIBAAgIFhkuBABMAgABAAgIFhkuBABMAgAAAA==.',['倔強']='倔強的葡萄哥:BAABKgAFFH8JAAICAAgIzxkxBgBpAgACAAgIzxkxBgBpAgAAAA==.',['倾城']='倾城绝色:BAABKgAFFH8MAAICAAYIASR4EQDSAQACAAYIASR4EQDSAQABKgAFFAgIFgACAOQZAA==.',['元素']='元素忽悠者:BAAAKgAECgIIAgAAAA==.',['克里']='克里斯蒂:BAAAKgAECggICAAAAA==.',['八方']='八方来财:BAAAKgADCggIDAAAAA==.',['公主']='公主八个胃:BAABKgAFFH8IAAMJAAQIlh8+FwCmAAAJAAMIshw+FwCmAAAWAAIIhxT0GACbAAABKgAFFAgIEwAXADQUAA==.',['其实']='其实我不黑:BAAAKgADCggICAAAAA==.',['兽比']='兽比兽兽瘦:BAAAKgADCggICAAAAA==.',['内呗']='内呗:BAAAKgAECgIIAgAAAA==.',['再世']='再世神经刀:BAABKgAECn8cAAMJAAcINA63OAANAQAJAAcINA63OAANAQAWAAYINwNLTgB0AAAAAA==.',['冖亼']='冖亼冖:BAAAKgAECgEIAQAAAA==.',['冥帝']='冥帝:BAAAKgAFFAEIAQAAAA==.',['冰封']='冰封柬柬:BAAAKgAECgMIBgAAAA==.',['冰符']='冰符:BAAAKgAECgQICQAAAA==.',['冰雪']='冰雪风影:BAAAKgAECgcIBwAAAA==.',['冰魄']='冰魄剑:BAAAKgAECgIIAgAAAA==.',['冲锋']='冲锋就开怪:BAAAKgAECgQIBAAAAA==.冲锋拦截援护:BAAAKgADCgEIAQAAAA==.',['凉拌']='凉拌花椰菜:BAABKgAFFH8GAAIXAAYIIAjZEAAnAQAXAAYIIAjZEAAnAQAAAA==.',['凝望']='凝望深渊:BAABKgAECn8UAAMYAAcIrSGoDQDLAQAYAAYITiGoDQDLAQABAAUIURqBEQBnAQAAAA==.',['凤凰']='凤凰院喵真:BAABKgAFFH8HAAQXAAYI2RMuBgBBAQAXAAUITRcuBgBBAQAZAAEICQb/FgBNAAAaAAEIEA60JQA4AAAAAA==.',['出云']='出云彼方:BAAAKgAECgMIAwAAAA==.',['剑君']='剑君十二恨:BAAAKgAFFAQIAgAAAA==.',['单吊']='单吊绝九万:BAABKgAFFH8FAAIOAAUI/hxoFgAWAQAOAAUI/hxoFgAWAQABKgAFFAgIGwAOACwhAA==.',['卖血']='卖血在上网:BAABKgAECn8gAAIbAAgI7gu/LgA2AQAbAAgI7gu/LgA2AQAAAA==.',['南影']='南影倾寒:BAAAKgAFFAQIBAAAAA==.',['南瓜']='南瓜闷土豆:BAABKgAFFH8GAAMDAAQIPxoALgDEAAADAAQIPxoALgDEAAAEAAII6QnUIABcAAAAAA==.',['卜折']='卜折手断:BAAAKgAECgEIAQAAAA==.',['占戈']='占戈女臣:BAAAKgAECggIDwAAAA==.',['卤蛋']='卤蛋和尚:BAAAKgADCgQIBAAAAA==.',['卩丶']='卩丶橘子灬:BAABKgAECn8UAAMcAAYIOSJdGADwAQAcAAYIOSJdGADwAQAdAAMIBB2SHgD7AAAAAA==.卩丶芒果灬:BAAAKgAECgcICwAAAA==.卩丶苹果灬:BAAAKgAECgcICgAAAA==.卩丶草莓灬:BAAAKgAECgcICwAAAA==.卩丶西瓜灬:BAAAKgAECggIDgAAAA==.',['及夏']='及夏:BAAAKgAECgYIBgAAAA==.',['变老']='变老的大二:BAAAKgAECgYICgAAAA==.',['叨叨']='叨叨神:BAAAKgADCgEIAQAAAA==.',['叮咚']='叮咚:BAABKgAFFH8PAAMeAAYIXA1bAQApAQAeAAYIXA1bAQApAQANAAQI0BTaHgCsAAAAAA==.',['可乐']='可乐八号:BAABKgAFFH8IAAIUAAgI+wuyBgByAQAUAAgI+wuyBgByAQAAAA==.',['听海']='听海指路:BAAAKgAFFAMIAwAAAA==.',['吾行']='吾行之骑:BAAAKgAECgQIBQAAAA==.吾行天下:BAAAKgAECgYIEwAAAA==.',['咪德']='咪德:BAAAKgAECggICAAAAA==.',['哈基']='哈基恶:BAAAKgAECgcIBwAAAA==.',['哎呦']='哎呦不错呦:BAAAKgAECggICgAAAA==.',['哎哟']='哎哟不错哟:BAABKgAFFH8GAAIfAAYI+BioDgB1AQAfAAYI+BioDgB1AQAAAA==.',['哟来']='哟来颗糖:BAAAKgADCgYIBgAAAA==.',['哦哩']='哦哩哦哩哦:BAAAKgAECgYIBgAAAA==.',['唯他']='唯他命吸:BAAAKgAECgEIAQAAAA==.',['喆同']='喆同学:BAAAKgAFFAIIAgAAAA==.',['喝假']='喝假酒开牢车:BAAAKgAFFAgIAgAAAA==.',['嗒啦']='嗒啦嗨:BAAAKgADCgUIBQAAAA==.',['嘉明']='嘉明:BAACKgAFFH8bAAIVAAMI/B5QIgDvAAAVAAMI/B5QIgDvAAAqAAQKfxkAAhUACAi8CkBgAB8BABUACAi8CkBgAB8BAAAA.',['嘴上']='嘴上说不要:BAABKgAFFH8GAAILAAYImRMtEABnAQALAAYImRMtEABnAQAAAA==.',['噬血']='噬血的沪舒宝:BAAAKgADCgIIAgAAAA==.',['回魂']='回魂:BAAAKgAECgUIBQAAAA==.',['圆形']='圆形霸天虎:BAAAKgAECggICAAAAA==.',['土逼']='土逼南波湾:BAAAKgAECgQIBAAAAA==.',['圣丶']='圣丶惩戒:BAABKgAECn8UAAICAAcI1RpPeACmAQACAAcI1RpPeACmAQAAAA==.',['圣光']='圣光之泪:BAAAKgAFFAgIBAAAAA==.圣光棍之力:BAAAKgADCgIIAgAAAA==.',['圣教']='圣教军:BAAAKgADCgEIAgAAAA==.',['圣玛']='圣玛丽:BAAAKgADCgQICgAAAA==.',['埃辛']='埃辛诺斯之力:BAAAKgADCggICAAAAA==.',['培提']='培提尔:BAAAKgAECgUIBQAAAA==.',['基普']='基普索恩:BAAAKgAECgYIEAAAAA==.',['堕落']='堕落丘比特:BAABKgAECn8aAAMgAAgISiSzHQBOAgAgAAcI6iSzHQBOAgAfAAUINBz4TQDlAAAAAA==.',['塞伦']='塞伦娜郡主:BAAAKgAFFAgIAQAAAA==.',['夏一']='夏一个:BAAAKgAECggICAAAAA==.',['夏至']='夏至名绍芹芹:BAAAKgADCggICAAAAA==.',['夏雪']='夏雪丶:BAAAKgAECggICAAAAA==.',['夕月']='夕月丶:BAAAKgAFFAEIAQAAAA==.',['夜之']='夜之魔刃:BAABKgAFFH8MAAMXAAYIfB4zBAB0AQAXAAYIfB4zBAB0AQAZAAEIwRJUEwBYAAABKgAFFAgIFgAXAIseAA==.',['夜心']='夜心:BAACKgAFFH8FAAINAAMIsghPJQCOAAANAAMIsghPJQCOAAAqAAQKfycAAg0ACAiQFn8fAI0BAA0ACAiQFn8fAI0BAAAA.',['夜玹']='夜玹:BAAAKgAECgIIAgAAAA==.夜玹玹:BAABKgAFFH8OAAIhAAgIJAh9DABLAQAhAAgIJAh9DABLAQAAAA==.',['夢梅']='夢梅悅怡:BAABKgAFFH8KAAIKAAYIaxN0EACiAAAKAAYIaxN0EACiAAAAAA==.',['大只']='大只西瓜:BAABKgAFFH8NAAICAAgIIRPqEQDOAQACAAgIIRPqEQDOAQAAAA==.',['大沢']='大沢佑香:BAAAKgAECgIIAgAAAA==.',['大浣']='大浣熊干脆面:BAAAKgAECgUIBQAAAA==.',['大爷']='大爷有空:BAAAKgADCgIIAgAAAA==.',['大队']='大队人马:BAAAKgADCggIEAAAAA==.',['天命']='天命人:BAABKgAECn8XAAMMAAgIIBxlEAAmAgAMAAgIIBxlEAAmAgALAAEIEwaB2wAqAAAAAA==.',['天天']='天天小肥牛:BAAAKgADCgEIAQAAAA==.天天牛肉面:BAABKgAECn8WAAMaAAgISSAEAwBxAgAaAAgI6x0EAwBxAgAZAAMIMRYMYACDAAAAAA==.',['天籁']='天籁术:BAAAKgAECggICAAAAA==.天籁萨:BAABKgAFFH8FAAIiAAUIrBv4CgAfAQAiAAUIrBv4CgAfAQAAAA==.',['天菩']='天菩萨:BAABKgAFFH8GAAIjAAYImgynCQAvAQAjAAYImgynCQAvAQAAAA==.',['奔跑']='奔跑的泡面:BAABKgAFFH8GAAICAAYInxnuHwBwAQACAAYInxnuHwBwAQAAAA==.',['奘卌']='奘卌:BAAAKgADCggICwAAAA==.',['奥本']='奥本海默:BAABKgAECn8bAAIKAAgIOhj5NwCNAQAKAAgIOhj5NwCNAQAAAA==.',['奥蕾']='奥蕾莉娅:BAAAKgADCggICAAAAA==.',['奧茲']='奧茲諾姆:BAABKgAFFH8GAAIBAAYIJwzOGgBHAQABAAYIJwzOGgBHAQAAAA==.',['奶不']='奶不起:BAAAKgADCggICAAAAA==.',['奶爸']='奶爸:BAAAKgAECgYICAAAAA==.',['奶瓶']='奶瓶超人:BAAAKgAECggIDwAAAA==.',['如意']='如意小瓜瓜:BAAAKgAECgUIBQAAAA==.如意紫茄子:BAAAKgAFFAQIAgAAAA==.',['媞妮']='媞妮:BAAAKgADCgEIAQAAAA==.',['嫩白']='嫩白色:BAAAKgADCgUIBQAAAA==.',['孺子']='孺子牛:BAAAKgAFFAIIAwAAAA==.',['守岸']='守岸人:BAAAKgAECgQIBAAAAA==.',['安慕']='安慕丶希:BAABKgAECn8WAAIbAAgIDx2zFAA7AgAbAAgIDx2zFAA7AgAAAA==.',['家乐']='家乐福海盗:BAAAKgAECgQIBAAAAA==.',['寡头']='寡头:BAAAKgADCgIIAgAAAA==.',['射射']='射射:BAABKgAFFH8JAAIgAAMIlhhSLADVAAAgAAMIlhhSLADVAAAAAA==.',['小众']='小众宝藏蜥蜴:BAAAKgAECgIIAgAAAA==.',['小十']='小十一:BAAAKgAECgYICwAAAA==.',['小周']='小周:BAAAKgADCggICAAAAA==.',['小尾']='小尾巴甩甩:BAABKgAFFH8IAAILAAgIFhsKBQB2AgALAAgIFhsKBQB2AgAAAA==.',['小德']='小德来保护你:BAAAKgAECgUIBQAAAA==.',['小母']='小母牛回来啦:BAAAKgAECgIIAwAAAA==.',['小神']='小神棍德:BAAAKgAECgEIAQAAAA==.',['小花']='小花生:BAAAKgADCgEIAQAAAA==.',['小行']='小行星爆炸:BAABKgAFFH8OAAMBAAYIGBl7FQBwAQABAAYIwBZ7FQBwAQAhAAIIvBBwGACPAAAAAA==.',['小西']='小西瓜:BAABKgAFFH8IAAIPAAgIUBQhBgA2AgAPAAgIUBQhBgA2AgAAAA==.',['小调']='小调皮:BAAAKgADCgIIAgAAAA==.',['小跳']='小跳跳:BAAAKgADCggICAAAAA==.',['小饭']='小饭团:BAAAKgAECgQIBAAAAA==.',['小龙']='小龙人:BAABKgAFFH8GAAIDAAYICRvHFABTAQADAAYICRvHFABTAQAAAA==.小龙包:BAABKgAFFH8IAAIfAAgIrA98BgDsAQAfAAgIrA98BgDsAQAAAA==.',['尘灬']='尘灬无痴:BAAAKgAECgIIAgAAAA==.',['尚古']='尚古:BAAAKgADCgEIAQAAAA==.',['山崎']='山崎信长:BAAAKgADCgQIBAAAAA==.',['岂涅']='岂涅:BAAAKgAECgMIAwAAAA==.',['巅峰']='巅峰緑冐鵔:BAAAKgADCgcIBwAAAA==.',['左橙']='左橙丨丨右蓝:BAAAKgADCggICAAAAA==.',['巨婴']='巨婴爱哭鬼:BAAAKgADCggICAAAAA==.',['布丁']='布丁:BAAAKgAFFAYIBAAAAA==.',['希你']='希你瓦娜斯:BAAAKgADCgEIAQAAAA==.',['希尔']='希尔瓦一娜斯:BAAAKgADCgIIAgAAAA==.',['希爾']='希爾瓦納:BAAAKgADCgQIBAAAAA==.',['帕克']='帕克:BAAAKgAFFAIIAgAAAA==.',['带点']='带点绿生活好:BAAAKgAECgIIAgAAAA==.',['干个']='干个亼兒:BAAAKgAECgYIBgAAAA==.',['幻影']='幻影之米里雅:BAABKgAFFH8IAAINAAYI1hUqDABkAQANAAYI1hUqDABkAQABKgAFFAgIBgAhAOACAA==.',['幼儿']='幼儿园打手:BAABKgAFFH8IAAICAAgIrB3lBAB8AgACAAgIrB3lBAB8AgAAAA==.',['幽冥']='幽冥哈迪斯:BAABKgAECn8ZAAMPAAgI8BalEgCuAQAPAAgI8BalEgCuAQAKAAMIrQvikwBmAAAAAA==.',['库蕾']='库蕾雅:BAAAKgAFFAYIBAAAAA==.',['开始']='开始即结束:BAAAKgAECgQIBAAAAA==.',['很爱']='很爱羽:BAAAKgADCggICAAAAA==.',['御神']='御神丶格格:BAAAKgAECgcIBwAAAA==.',['必须']='必须德:BAABKgAECn8aAAIMAAgIYBOxIQCQAQAMAAgIYBOxIQCQAQAAAA==.',['忘忧']='忘忧草檞寄生:BAAAKgADCgQIBAAAAA==.',['怒乂']='怒乂逍遥:BAAAKgAECggIEQAAAA==.',['恐怖']='恐怖灌注人:BAAAKgADCgMIAwABKgAFFAQIGAAOAEAhAA==.恐怖电击葫芦:BAACKgAFFH8RAAIiAAMIYiCsCgAkAQAiAAMIYiCsCgAkAQAqAAQKfx0AAyIACAhYIlcHAIICACIACAgdIlcHAIICACMAAggoIqNNAMgAAAEqAAUUBAgYAA4AQCEA.',['恶魔']='恶魔之王:BAAAKgAECgEIAQAAAA==.恶魔之锁:BAAAKgAECgEIAgAAAA==.恶魔眼棱献祭:BAAAKgADCgQIBAAAAA==.',['恺恩']='恺恩血蹄:BAAAKgAECgYIBgAAAA==.',['悍匪']='悍匪蚊子:BAEBKgAFFH8MAAMXAAQIyyWRFQDOAAAXAAQIyyWRFQDOAAAaAAIIww7fFQB6AAAAAA==.',['愈树']='愈树人轻木:BAAAKgAECggICAAAAA==.',['感冒']='感冒药片:BAAAKgAECgUICgAAAA==.',['慕斯']='慕斯灬蛋糕:BAAAKgAECgEIAQAAAA==.',['我叫']='我叫不紧张啊:BAAAKgAECgQIBAAAAA==.我叫曾轶可:BAABKgAECn8eAAMgAAgIpxqmOQAPAgAgAAgIpxqmOQAPAgAfAAgIdAznOABHAQAAAA==.',['我性']='我性疯狂:BAAAKgAFFAEIAQAAAA==.',['我没']='我没尅:BAAAKgAECgYICQAAAA==.',['我真']='我真的巨厉害:BAAAKgAECgYIBgAAAA==.',['戦斧']='戦斧牛排:BAACKgAFFH8dAAIhAAQITwUzHQBxAAAhAAQITwUzHQBxAAAqAAQKfzwAAiEACAjuCnQzAAABACEACAjuCnQzAAABAAAA.',['手心']='手心的蔷薇:BAAAKgAECgYIBgAAAA==.',['手拿']='手拿根火柴:BAAAKgAECgQIBAAAAA==.',['折枝']='折枝:BAAAKgADCgMIAwAAAA==.',['拉的']='拉的翼神:BAAAKgAFFAQIAQAAAA==.',['拉链']='拉链卡到毛:BAAAKgAFFAQIAwAAAA==.',['拜金']='拜金者:BAABKgAFFH8PAAIVAAMIahILMwCuAAAVAAMIahILMwCuAAAAAA==.',['拯救']='拯救者:BAAAKgADCggICAAAAA==.',['挥剑']='挥剑转身:BAAAKgADCggICAAAAA==.',['摄魂']='摄魂之刃:BAAAKgAECgQIBAAAAA==.摄魂之箭:BAABKgAFFH8GAAIfAAYI9BU0EgBSAQAfAAYI9BU0EgBSAQAAAA==.摄魂夺魄:BAAAKgAECggIEgAAAA==.',['放学']='放学等我打你:BAAAKgADCggIFAAAAA==.',['放弃']='放弃圣光:BAABKgAECn8UAAICAAgIhCVZCQDwAgACAAgIhCVZCQDwAgAAAA==.',['敖兴']='敖兴:BAABKgAFFH8FAAIOAAUInxyTFAArAQAOAAUInxyTFAArAQAAAA==.',['无心']='无心落叶风:BAABKgAFFH8FAAIPAAUI2Bg+GwALAQAPAAUI2Bg+GwALAQAAAA==.',['无涩']='无涩丶清茶:BAABKgAECn8eAAICAAgISyHoKwBvAgACAAgISyHoKwBvAgAAAA==.',['无聊']='无聊岁月:BAAAKgAECgEIAQAAAA==.',['无语']='无语泪奔:BAAAKgAFFAQIBAAAAA==.',['无间']='无间之隙:BAAAKgAECgMIAwAAAA==.',['时扳']='时扳晴人:BAAAKgAECggICwAAAA==.',['时间']='时间机器:BAAAKgAFFAQIBAAAAA==.',['明裡']='明裡紬:BAAAKgADCgQIBAAAAA==.',['星星']='星星的小坎肩:BAAAKgADCggICAABKgAFFAgIDgAXAEEbAA==.',['春寒']='春寒倒返:BAACKgAFFH8gAAIOAAcIfhRtCwCJAQAOAAcIfhRtCwCJAQAqAAQKfygAAw4ACAhuHCQXAAkCAA4ACAhuHCQXAAkCACQAAgjbDc4HAE0AAAAA.',['是棱']='是棱但啦:BAAAKgAECgIIAgAAAA==.',['是雨']='是雨诺呀丶:BAAAKgAFFAYIBAAAAA==.',['晨风']='晨风韵雨:BAAAKgADCgIIAgAAAA==.',['暗月']='暗月旋舞:BAAAKgAECgYIBAAAAA==.',['暴风']='暴风熔岩:BAAAKgADCggICQAAAA==.',['曲老']='曲老师:BAAAKgAECgUICQABKgAFFAgIEwAIAP0gAA==.',['曵忈']='曵忈:BAAAKgADCgYIBgAAAA==.',['月丶']='月丶半小夜曲:BAAAKgAECggIAQAAAA==.',['月亮']='月亮小船:BAABKgAFFH8PAAIgAAgINxZ8AABiAgAgAAgINxZ8AABiAgAAAA==.',['有成']='有成最爱罗兰:BAAAKgAFFAYIBAABKgAFFAgIDwAiAC4bAA==.',['木大']='木大力:BAAAKgAFFAIIAgABKgAFFAgIFgAVAMYWAA==.',['木槿']='木槿半枫荷:BAABKgAFFH8FAAMgAAUICx7mHwAOAQAgAAQIBx7mHwAOAQAfAAEIFx6USgBWAAAAAA==.',['木瑾']='木瑾年:BAAAKgAECgUIBQAAAA==.',['术术']='术术口:BAAAKgAECggICAAAAA==.',['杀戮']='杀戮时刻:BAABKgAFFH8GAAIDAAYIhAi4EAApAQADAAYIhAi4EAApAQAAAA==.',['李梦']='李梦月:BAAAKgAECgUIBQAAAA==.',['枫児']='枫児:BAAAKgAECgEIAQAAAA==.',['柚柚']='柚柚酱:BAAAKgAFFAYIAgAAAA==.',['柯博']='柯博文:BAAAKgADCgcIBwAAAA==.',['柳随']='柳随风:BAAAKgADCgEIAQAAAA==.',['树叶']='树叶德:BAAAKgADCggIEAAAAA==.',['根哥']='根哥很忙:BAAAKgAECgUICAAAAA==.',['梅塔']='梅塔特林:BAABKgAFFH8PAAMZAAMIyQ5fDwDAAAAZAAMIyQ5fDwDAAAAXAAIICQW9LABUAAAAAA==.',['橙子']='橙子丶布丁:BAAAKgADCggICAAAAA==.',['橙色']='橙色的橙:BAAAKgAECgMIAwAAAA==.',['欧菲']='欧菲丽兹:BAAAKgADCggICAAAAA==.',['正版']='正版无敌小强:BAAAKgAECgMIAwAAAA==.',['武术']='武术运动员:BAABKgAFFH8FAAINAAMI/AS3JwCDAAANAAMI/AS3JwCDAAAAAA==.',['武林']='武林高手常威:BAAAKgAECgEIAQAAAA==.',['歪比']='歪比巴卜:BAACKgAFFH8jAAMgAAUIqR+2DQBXAQAgAAUIqR+2DQBXAQAfAAEI1wdPKQAzAAAqAAQKfygAAyAACAiOI5QFAL4CACAACAjOIpQFAL4CAB8ABAh7HqMhAAsBAAAA.',['死亡']='死亡横扫:BAABKgAECn8dAAIDAAgIjiLbBQCsAgADAAgIjiLbBQCsAgAAAA==.',['毁灭']='毁灭恶魔痛苦:BAAAKgADCgMIAwAAAA==.',['水煮']='水煮鸡胸肉:BAABKgAFFH8GAAITAAYIMguzEQA0AQATAAYIMguzEQA0AQAAAA==.',['江边']='江边玲玲子:BAABKgAFFH8MAAIDAAQIcRo0EwD7AAADAAQIcRo0EwD7AAAAAA==.',['河马']='河马:BAAAKgADCgIIAgAAAA==.',['泰兰']='泰兰得的星怒:BAAAKgAFFAMIAwABKgAFFAQIGAAOAEAhAA==.',['泰莉']='泰莉亚:BAAAKgAFFAIIAgABKgAECggIJwAJAI4fAA==.',['派拉']='派拉斯:BAAAKgADCggICAAAAA==.',['流浪']='流浪的小木鱼:BAAAKgADCggIDwAAAA==.',['浪漫']='浪漫丶饭团:BAABKgAECn8TAAMKAAcI0h/hHAAfAgAKAAYI0h/hHAAfAgATAAIIfAczpAAnAAAAAA==.',['海奎']='海奎特:BAAAKgADCgEIAQAAAA==.',['深邃']='深邃流年:BAAAKgAFFAQIBAAAAA==.',['渊武']='渊武:BAAAKgAECgUIBQAAAA==.',['渔鱼']='渔鱼:BAAAKgAECgYIBwAAAA==.',['温莉']='温莉洛克贝尔:BAAAKgADCgIIAgAAAA==.',['游侠']='游侠兒:BAAAKgADCgIIAgAAAA==.',['游龙']='游龙剑:BAAAKgAECggIDAAAAA==.',['渺小']='渺小的尘埃:BAAAKgAFFAYIBAAAAA==.',['溜溜']='溜溜狐:BAABKgAFFH8HAAIPAAQIugdBHgCRAAAPAAQIugdBHgCRAAABKgAFFAQIGAAOAEAhAA==.',['漫长']='漫长归途:BAAAKgAFFAMIAwABKgAFFAgIBAASAAAAAA==.',['潇潇']='潇潇羽墨:BAAAKgADCggICAAAAA==.',['激活']='激活打脉动:BAAAKgAFFAYIBAAAAA==.',['火野']='火野眏失:BAAAKgAECgIIAgAAAA==.',['火鸡']='火鸡味鍋巴:BAAAKgAECggIDQAAAA==.',['灬血']='灬血公子灬:BAAAKgAECgYICwAAAA==.',['灬阝']='灬阝荳荳:BAAAKgADCgEIAQAAAA==.',['灰骑']='灰骑士薛帕德:BAAAKgAECggICAAAAA==.',['灵魂']='灵魂圣光:BAABKgAECn8gAAMCAAgIxxeHTgAHAgACAAgIxxeHTgAHAgAlAAIIPQYRTQBDAAAAAA==.灵魂怒哮:BAAAKgADCgUIBQAAAA==.灵魂泳流:BAAAKgAECgYIBwAAAA==.',['炎帝']='炎帝:BAAAKgADCgUIBQAAAA==.',['烈焰']='烈焰法神:BAAAKgAFFAIIAgAAAA==.',['烟燃']='烟燃力烟灭:BAAAKgAECgYIBgAAAA==.烟燃灬烟灭:BAAAKgAECggICAAAAA==.',['烟菋']='烟菋弥漫:BAABKgAFFH8GAAMIAAQIKAZ7LwCIAAAIAAMIKAZ7LwCIAAAJAAMIPgXjLABjAAAAAA==.',['烟雨']='烟雨轻风:BAABKgAECn8UAAICAAgIxhOEbQB8AQACAAgIxhOEbQB8AQAAAA==.',['無尽']='無尽之旅:BAABKgAFFH8IAAIXAAgIQwaODAB/AQAXAAgIQwaODAB/AQAAAA==.',['無所']='無所畏懼:BAAAKgAECggICAAAAA==.',['熊气']='熊气昂昂:BAABKgAFFH8IAAITAAUIbBtREgAuAQATAAUIbBtREgAuAQAAAA==.',['熊猫']='熊猫充电宝:BAAAKgADCgYIBgAAAA==.',['熊霸']='熊霸天下:BAAAKgAECgYIBwAAAA==.',['爱吃']='爱吃土豆丝:BAAAKgAECgcIDgAAAA==.',['爱浪']='爱浪漫咕咕:BAAAKgAECggICAAAAA==.',['牛市']='牛市变熊市:BAAAKgAECgUIBQAAAA==.',['牛牛']='牛牛肥:BAAAKgAECgIIAgAAAA==.',['牛痘']='牛痘痘:BAABKgAFFH8GAAILAAYIJxLsDwBsAQALAAYIJxLsDwBsAQABKgAFFAgIQwAMAFYlAA==.',['牛虱']='牛虱:BAAAKgADCgMIAwAAAA==.',['狂风']='狂风追影:BAAAKgAECgYICwAAAA==.',['狐歌']='狐歌:BAAAKgAECgIIAgAAAA==.',['狗仔']='狗仔萨摩耶:BAABKgAFFH8jAAMgAAYIFiIWCgDPAQAgAAYIFSIWCgDPAQAfAAYI3R4AEgBTAQAAAA==.',['狠爱']='狠爱楠:BAABKgAFFH8GAAIlAAYI+A3vBQA0AQAlAAYI+A3vBQA0AQAAAA==.',['独夏']='独夏孤影:BAAAKgAECgYIEAAAAA==.',['猛哥']='猛哥:BAAAKgADCgIIAwAAAA==.',['珂莱']='珂莱塔:BAAAKgADCgMIAwAAAA==.',['珏珏']='珏珏乀子:BAABKgAFFH8IAAIJAAgIwwq8BACcAQAJAAgIwwq8BACcAQAAAA==.',['琦涅']='琦涅:BAABKgAECn8bAAIfAAgIAh5XHAAZAgAfAAgIAh5XHAAZAgAAAA==.',['琪叶']='琪叶青青:BAAAKgAECgMIAwAAAA==.',['痞子']='痞子丶魔:BAAAKgAECgYIBgAAAA==.',['癫火']='癫火幻耀石:BAAAKgAECggICAAAAA==.癫火炒年糕:BAAAKgAECgUIBQAAAA==.',['白云']='白云苍狗:BAAAKgAECgQICAAAAA==.',['白术']='白术芍药:BAABKgAFFH8GAAICAAYITAyDFgA6AQACAAYITAyDFgA6AQAAAA==.',['白榆']='白榆:BAAAKgAECgEIAQAAAA==.',['白驹']='白驹过隙:BAAAKgAECggICgAAAA==.',['盒马']='盒马:BAAAKgAFFAYIBAAAAA==.',['直插']='直插云霄:BAAAKgAECgYICQAAAA==.',['真嘟']='真嘟假嘟:BAAAKgAECgYIBwAAAA==.',['着光']='着光:BAAAKgAECgUICQAAAA==.',['瞞兲']='瞞兲過海:BAAAKgAECgQIBAAAAA==.',['短小']='短小快枪男:BAAAKgAFFAIIBAABKgAFFAQIGAAOAEAhAA==.',['破晓']='破晓晨星:BAABKgAFFH8FAAIDAAUIfQ/CEwBbAQADAAUIfQ/CEwBbAQAAAA==.',['破碎']='破碎冬镜:BAAAKgADCgMIAwAAAA==.',['神奇']='神奇猫猫头:BAAAKgAFFAIIAgAAAA==.',['神秘']='神秘人:BAAAKgAECgQIBAAAAA==.',['禅翼']='禅翼:BAAAKgAFFAEIAQAAAA==.',['离人']='离人公子:BAAAKgAFFAQIBAAAAA==.',['秦始']='秦始皇:BAABKgAECn8ZAAQdAAgIJROBFgBPAQAdAAcI6g+BFgBPAQAcAAYIbxNQKgA6AQAmAAEIjhVGIQBCAAAAAA==.',['穆秀']='穆秀于麟:BAAAKgADCgMIAwAAAA==.',['窈窕']='窈窕术女:BAAAKgAFFAYIAgAAAA==.',['笨蛋']='笨蛋狐狸:BAAAKgADCggICAAAAA==.',['箭鬼']='箭鬼:BAAAKgAECgYICgAAAA==.',['精靈']='精靈雪兒:BAAAKgADCgIIAgAAAA==.',['紧急']='紧急联络人:BAAAKgAECgUIBQAAAA==.',['紫日']='紫日:BAABKgAECn8WAAQIAAgInxOoLwBmAQAIAAgInxOoLwBmAQAJAAEI7Q1QgQArAAAWAAEIAADVcAAAAAAAAA==.',['繁华']='繁华梦露:BAABKgAFFH8KAAMTAAYIvyAGBwCUAQATAAYIzRQGBwCUAQAKAAQI5SPQCAA1AQABKgAFFAgICAAKALIdAA==.',['红黄']='红黄绿黑四龙:BAAAKgADCggICAAAAA==.',['纹舞']='纹舞兰:BAAAKgAECggICQAAAA==.',['织雾']='织雾踏风酒仙:BAAAKgADCgQIBgAAAA==.',['维里']='维里奈:BAAAKgADCggICAAAAA==.',['罄囊']='罄囊尸医:BAAAKgAFFAYIBAABKgAFFAgIBAASAAAAAA==.',['罗慕']='罗慕洛斯:BAAAKgAECgMIDAAAAA==.',['美女']='美女骑士:BAABKgAFFH8PAAMBAAgIQhO6BwDNAQABAAcI7xG6BwDNAQAhAAcIUQ6DBQB8AQAAAA==.',['羲和']='羲和:BAABKgAFFH8IAAIgAAMIdBWgGADuAAAgAAMIdBWgGADuAAAAAA==.',['翼柳']='翼柳浮洋:BAABKgAFFH8IAAIXAAgIhQmnCQC+AQAXAAgIhQmnCQC+AQAAAA==.',['老衲']='老衲法号三葬:BAAAKgADCgYIBgAAAA==.老衲法号胸毛:BAAAKgAECgIIAgAAAA==.',['职业']='职业坑队友:BAABKgAECn8VAAIXAAgIMBs3EgAXAgAXAAgIMBs3EgAXAgAAAA==.',['肉团']='肉团团的妈妈:BAAAKgADCgYIBgAAAA==.',['肉宝']='肉宝宝丶:BAAAKgAECgEIAQAAAA==.',['肉葫']='肉葫芦:BAABKgAFFH8JAAImAAMIDBVPBwC2AAAmAAMIDBVPBwC2AAABKgAFFAQIGAAOAEAhAA==.',['肌肉']='肌肉男:BAAAKgADCgEIAQAAAA==.',['肖申']='肖申克的九叔:BAAAKgADCggICAAAAA==.',['肨肨']='肨肨彪彪熊:BAAAKgAECgUIBQAAAA==.',['自东']='自东向西:BAAAKgAFFAYIAwAAAA==.',['舞糖']='舞糖糖:BAABKgAFFH8IAAMZAAQIGgnkDQCDAAAXAAQIGgnTGwCiAAAZAAQI5wPkDQCDAAAAAA==.',['船长']='船长:BAAAKgADCgYIBgAAAA==.',['艾利']='艾利安萨满:BAAAKgAECggICAAAAA==.',['艾雅']='艾雅黑掌:BAACKgAFFH8IAAIJAAgIaBF6AwDfAQAJAAgIaBF6AwDfAQAqAAQKfxcAAxYACAiNDEQ6ABwBABYABgjqEEQ6ABwBAAgACAgsDgJIABkBAAAA.',['花生']='花生:BAAAKgADCggICwAAAA==.花生糕:BAAAKgAECgQIBAAAAA==.',['苏妲']='苏妲己:BAAAKgAFFAEIAQAAAA==.',['苦难']='苦难之心:BAAAKgAFFAMIAwAAAA==.',['菊魔']='菊魔沾酱:BAAAKgAECggICAAAAA==.',['菟碧']='菟碧楠薄婉:BAAAKgADCgEIAQAAAA==.',['菠萝']='菠萝啤:BAAAKgAECgUIBQAAAA==.',['萌烧']='萌烧锅:BAAAKgAECggICAAAAA==.',['萨伊']='萨伊尔:BAAAKgADCgEIAQAAAA==.',['萨拉']='萨拉塔司:BAAAKgAFFAIIAgAAAA==.',['葡叮']='葡叮噹:BAAAKgADCgMIAwAAAA==.',['蒙牛']='蒙牛优酪乳:BAAAKgAECggIEgAAAA==.',['蒟蒻']='蒟蒻:BAAAKgAECgMIAwAAAA==.',['薩菲']='薩菲隆:BAAAKgAECgEIAQAAAA==.',['藤条']='藤条打嘉美:BAAAKgAECgYIBwAAAA==.',['虎皮']='虎皮豆:BAAAKgADCggICAAAAA==.',['虔诚']='虔诚拜三拜:BAAAKgAECgYIBgAAAA==.',['蛮劲']='蛮劲发作:BAAAKgAECggIDQAAAA==.',['血凝']='血凝牙:BAAAKgAFFAMIAwAAAA==.',['血色']='血色玛丽:BAAAKgAECgcICQAAAA==.',['角牛']='角牛:BAAAKgAECgIIAgAAAA==.',['諸神']='諸神無名:BAAAKgAFFAgIAgAAAA==.',['语风']='语风的星怒:BAABKgAFFH8JAAIQAAMIChnYBAD2AAAQAAMIChnYBAD2AAABKgAFFAQIGAAOAEAhAA==.',['贰灬']='贰灬减:BAAAKgAFFAgIBAAAAA==.',['赞美']='赞美太阳:BAABKgAFFH8OAAMDAAQInxgaEgD3AAADAAQIfxgaEgD3AAAEAAIIHAxwEgBwAAAAAA==.',['跑马']='跑马运动员:BAABKgAFFH8WAAMUAAMIyBe8GQCqAAACAAMIJRCfJwDJAAAUAAMIqxK8GQCqAAABKgAFFAcIBQANAPwEAA==.',['跳伞']='跳伞运动员:BAAAKgAECgYIBgABKgAFFAcIBQANAPwEAA==.',['跳远']='跳远运动员:BAACKgAFFH8OAAMEAAMIMRCICwCaAAADAAMIcA5JLgDDAAAEAAMIig2ICwCaAAAqAAQKfxoAAwMACAjaGUEfAAsCAAMACAh3GUEfAAsCAAQACAjNEw0eAJMBAAEqAAUUBwgFAA0A/AQA.',['迎接']='迎接圣光:BAAAKgAECgQIBAAAAA==.',['迷梦']='迷梦时光:BAABKgAECn8WAAICAAgIzR6UNAAtAgACAAgIzR6UNAAtAgAAAA==.',['逍遥']='逍遥无忧:BAABKgAECn8ZAAIBAAgIfBhSLADKAQABAAgIfBhSLADKAQAAAA==.逍遥的奇:BAAAKgAECgIIBAAAAA==.',['逐风']='逐风者石肤:BAAAKgAECgUICgAAAA==.',['逐鹿']='逐鹿中原:BAAAKgAECggICAAAAA==.',['通通']='通通:BAAAKgAECggICAAAAA==.',['邦比']='邦比爱塔:BAABKgAECn8YAAICAAgIeR1kLABtAgACAAgIeR1kLABtAgAAAA==.',['邪恶']='邪恶摇粒绒:BAAAKgADCgYIBgAAAA==.',['酸甜']='酸甜柠檬:BAAAKgAECgIIAgAAAA==.',['采蘑']='采蘑菇的姑娘:BAAAKgAFFAQIBAAAAA==.',['释云']='释云:BAAAKgADCgMIAwAAAA==.',['释放']='释放的释:BAAAKgAECgEIAQAAAA==.',['野生']='野生动物贩子:BAAAKgAECgEIAQAAAA==.',['钙奶']='钙奶:BAAAKgAECgQIBAAAAA==.',['钢铁']='钢铁风筝:BAAAKgAECgUIBwAAAA==.',['钱和']='钱和命都要:BAAAKgAECgUIBQAAAA==.',['银座']='银座暗翼:BAABKgAFFH8IAAIXAAgIKBcLBwAiAgAXAAgIKBcLBwAiAgAAAA==.',['银角']='银角大王:BAAAKgADCggICAAAAA==.',['闪电']='闪电侠:BAAAKgADCgEIAQAAAA==.',['阿丽']='阿丽蛋姐:BAAAKgADCggICAAAAA==.',['阿卡']='阿卡丽:BAAAKgAECgQIBAAAAA==.',['阿爾']='阿爾托麗雅:BAAAKgAECggICAAAAA==.',['陈十']='陈十四:BAAAKgAECgIIAgAAAA==.',['随风']='随风猎影:BAAAKgADCggICAAAAA==.',['雀雀']='雀雀的雀:BAAAKgADCggICAAAAA==.',['雨落']='雨落樱:BAAAKgADCggIEAAAAA==.',['雨诺']='雨诺吖:BAAAKgAFFAYIBAABKgAFFAgIBAASAAAAAA==.雨诺吖丶:BAAAKgAECggICAAAAA==.雨诺啊丶:BAAAKgAFFAYIBAAAAA==.',['雪落']='雪落幻夜:BAAAKgAECgYIBgAAAA==.',['零丨']='零丨刺青:BAAAKgADCgIIAgAAAA==.',['雷兙']='雷兙萨:BAAAKgAECgYIDgAAAA==.',['雷震']='雷震子杨永信:BAAAKgAECggIAwAAAA==.',['露茜']='露茜范佩尔特:BAAAKgAECgQIBAAAAA==.',['霸刀']='霸刀宋壹:BAAAKgADCgEIAQAAAA==.',['颠嗨']='颠嗨鸠:BAAAKgAFFAUIBAABKgAFFAgILwAfAKQlAA==.',['风御']='风御殇:BAABKgAFFH8EAAIfAAQICR/VBQAbAQAfAAQICR/VBQAbAQAAAA==.',['风暴']='风暴代替思考:BAABKgAFFH8IAAICAAgINx6HGgCNAQACAAgINx6HGgCNAQAAAA==.',['飞龙']='飞龙仔:BAAAKgAECgIIAgAAAA==.',['马什']='马什么梅:BAACKgAFFH8PAAIBAAYIUwxfNwC9AAABAAYIUwxfNwC9AAAqAAQKfyIAAwEACAhUHs8WAFUCAAEACAhUHs8WAFUCABgAAwjKClQpAIsAAAAA.',['驴驴']='驴驴:BAAAKgADCgcICgAAAA==.',['骑上']='骑上扒下:BAACKgAFFH8GAAICAAMIHhiKQgDqAAACAAMIHhiKQgDqAAAqAAQKfxcAAwIACAhPIkISAMICAAIACAhPIkISAMICABQAAQijA0RiAAYAAAAA.',['高一']='高一高:BAAAKgAECgcICgAAAA==.',['鬼魅']='鬼魅火术:BAAAKgADCggICAAAAA==.',['魏爱']='魏爱裙:BAAAKgAECgMIAwAAAA==.',['魔曦']='魔曦:BAAAKgAFFAgIBAAAAA==.',['魔鬼']='魔鬼鱼:BAAAKgADCggICAAAAA==.',['鱼干']='鱼干爱次糖:BAAAKgAECgIIAgAAAA==.',['鹿邑']='鹿邑:BAAAKgAFFAgIBAAAAA==.',['麦麦']='麦麦头:BAAAKgAECgMIAwAAAA==.麦麦宝:BAAAKgADCggICAAAAA==.',['黎明']='黎明之锤:BAAAKgADCgEIAQAAAA==.黎明女神:BAAAKgADCgEIAQAAAA==.',['黑俊']='黑俊的爸爸:BAABKgAFFH8SAAICAAYI9hYnDgAbAQACAAYI9hYnDgAbAQAAAA==.',['黑子']='黑子:BAAAKgADCgUIBQAAAA==.',['黑桃']='黑桃尖丶:BAAAKgAFFAQIBAAAAA==.',['黑白']='黑白配配:BAAAKgAFFAMIAwAAAA==.',['黑脚']='黑脚杆:BAAAKgAECgUIBwAAAA==.',['黑葡']='黑葡萄:BAAAKgADCgMIAwAAAA==.',['龍小']='龍小羽:BAAAKgAECgYIEAAAAA==.',['龏缺']='龏缺德:BAAAKgAECgEIAQAAAA==.',['龙唐']='龙唐尔:BAACKgAFFH8YAAIOAAQIQCHDDQDiAAAOAAQIQCHDDQDiAAAqAAQKfxkAAg4ACAg9HloQAEsCAA4ACAg9HloQAEsCAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end