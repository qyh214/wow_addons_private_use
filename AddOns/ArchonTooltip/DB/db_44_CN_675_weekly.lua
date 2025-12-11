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
 local lookup = {'Druid-Restoration','DeathKnight-Blood','DeathKnight-Frost','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Monk-Mistweaver','Evoker-Preservation','Evoker-Devastation','DemonHunter-Havoc','Shaman-Elemental','Druid-Balance','Paladin-Holy','Paladin-Retribution','Hunter-BeastMastery','Monk-Brewmaster','Mage-Arcane','Priest-Holy','Warrior-Fury','Unknown-Unknown','Mage-Frost','Shaman-Restoration','Priest-Shadow','Hunter-Marksmanship','Paladin-Protection','DeathKnight-Unholy','Warrior-Protection','Rogue-Assassination','Monk-Windwalker','DemonHunter-Vengeance','Priest-Discipline',}; local provider = {region='CN',realm='弗塞雷迦',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Arthurx:BAAALAAECgIIAgAAAA==.',As='Ashbrlnger:BAAALAAECggIDgAAAA==.',Ca='Carol:BAAALAAECgIIAwAAAA==.',Cr='Crazydk:BAAALAADCggICAAAAA==.',De='Devilreturns:BAAALAAECgIIAgAAAA==.',Di='Diverdv:BAAALAAECgUIBQAAAA==.',Ef='Efey:BAAALAAFFAIIBAAAAA==.',Eu='Eugen:BAAALAAECgYIEAAAAA==.',Ev='Evontion:BAAALAAECggICAAAAA==.',Fa='Fall:BAABLAAFFH8MAAIBAAYIMh7ECQARAgABAAYIMh7ECQARAgAAAA==.Fancyfs:BAAALAADCgMIAwAAAA==.',Fo='Foam:BAAALAAECgQIBAAAAA==.',Fr='Frizy:BAAALAADCgIIAgAAAA==.Frozenangel:BAABLAAECn8UAAMCAAYIpBAIGwDuAAACAAYIeQ4IGwDuAAADAAQIxgu5VAG3AAAAAA==.',Is='Isaias:BAAALAAECggICAAAAA==.',Ix='Ixshishi:BAABLAAECn8bAAIDAAYI7wwmdQAEAQADAAYI7wwmdQAEAQAAAA==.',Ja='Jasckrios:BAABLAAECn8kAAQEAAgISRofNQBmAgAEAAgISRofNQBmAgAFAAYIRRJuPgBzAQAGAAIIsQd2MQBvAAAAAA==.',Lo='Louisluo:BAAALAAECgYIBgAAAA==.',Lu='Lunacame:BAAALAAECgUIBQAAAA==.',Ne='Newzq:BAAALAAECgMIAwAAAA==.',Ra='Rain:BAAALAAECgYIBgAAAA==.',Re='Reexxarr:BAAALAAFFAIIAgAAAA==.',Sa='Samc:BAAALAADCgUIBQAAAA==.',Sl='Slaughterr:BAAALAAFFAIIAgAAAA==.',Su='Supertank:BAAALAAECgUIBQAAAA==.',Ta='Tazdingo:BAAALAAECgUIBQAAAA==.',Un='Undefined:BAAALAAECgEIAQAAAA==.',Us='Ushio:BAACLAAFFH8jAAIDAAcIrh7oDAAuAgADAAcIrh7oDAAuAgAsAAQKfx4AAgMABwh4IDV4AAcCAAMABwh4IDV4AAcCAAAA.',Wz='Wzclhmd:BAAALAAECgYIEgAAAA==.',Zz='Zze:BAAALAADCgMIAwAAAA==.',['一勺']='一勺料汁:BAAALAADCgEIAQAAAA==.',['一根']='一根棍走天下:BAABLAAFFH8MAAIHAAMIjSNkCwDUAAAHAAMIjSNkCwDUAAAAAA==.',['一琪']='一琪丗一:BAAALAAECggIDgAAAA==.',['一阳']='一阳阳一:BAAALAADCgIIAgAAAA==.',['万龙']='万龙:BAACLAAFFH8IAAIIAAII/As5FQCGAAAIAAII/As5FQCGAAAsAAQKfxcAAwgABwjwFBAZALgBAAgABwjwFBAZALgBAAkABgiBFoo3AHUBAAAA.',['不用']='不用刷幻化:BAAALAAECgIIAgAAAA==.',['丨丶']='丨丶小熊:BAAALAAECgYIBgAAAA==.',['丨海']='丨海盗船长丨:BAAALAADCggICAAAAA==.',['丨潜']='丨潜规则丨:BAAALAADCgcIBwAAAA==.',['丰川']='丰川丶祥子:BAABLAAFFH8dAAIKAAYIPxqKDgDBAQAKAAYIPxqKDgDBAQAAAA==.',['临时']='临时演员:BAAALAADCggICQAAAA==.',['丶城']='丶城武:BAAALAAECgYIBgAAAA==.',['丶彦']='丶彦祖:BAABLAAFFH8GAAILAAMImBMBNQCJAAALAAMImBMBNQCJAAAAAA==.',['丶萨']='丶萨瓦迪卡:BAAALAAECgIIAgAAAA==.',['乃穷']='乃穷神冰:BAAALAAFFAIIAgAAAA==.',['乄神']='乄神棍德乄:BAAALAADCgEIAQAAAA==.',['乌萨']='乌萨奇:BAAALAAECgYIEwAAAA==.',['九局']='九局下半:BAABLAAFFH8KAAIMAAII0Be7GQCcAAAMAAII0Be7GQCcAAAAAA==.',['云梦']='云梦瑶:BAABLAAFFH8KAAMNAAYIBRGYBgDGAQANAAYIBRGYBgDGAQAOAAIIax3sPwCeAAAAAA==.',['五年']='五年四班丶:BAABLAAECn8WAAIPAAgIMhlxjADKAQAPAAgIMhlxjADKAQAAAA==.',['京城']='京城灬叁公子:BAAALAAFFAMIAwAAAA==.',['亲你']='亲你肿又肿了:BAAALAADCgEIAQAAAA==.',['仗剑']='仗剑浪天涯:BAAALAADCgQIBAAAAA==.',['任朝']='任朝野:BAAALAAECgcIBwAAAA==.',['伊加']='伊加天:BAAALAAECgcIBwAAAA==.',['伊洛']='伊洛玛丽:BAACLAAFFH9BAAIQAAcIcCSHAQBwAgAQAAcIcCSHAQBwAgAsAAQKfyAAAhAACAhBJLQHAO0CABAACAhBJLQHAO0CAAAA.',['伊莉']='伊莉娅丶晨曦:BAABLAAFFH8OAAIOAAMIKBW1PwCVAAAOAAMIKBW1PwCVAAAAAA==.',['伯瓦']='伯瓦尔弗塔跟:BAAALAADCgUIBQAAAA==.',['佛罗']='佛罗伦萨之音:BAAALAAECgMIAwAAAA==.',['你也']='你也玩暗牧么:BAAALAAECgEIAQAAAA==.',['信仰']='信仰之光:BAAALAAECgEIAQAAAA==.',['倪久']='倪久依鲁瑟尔:BAACLAAFFH8KAAIRAAIIzw2ZTgCSAAARAAIIzw2ZTgCSAAAsAAQKfx8AAhEACAhxG9w4AGcCABEACAhxG9w4AGcCAAAA.',['傻哥']='傻哥:BAAALAAFFAIIBAAAAA==.',['元素']='元素力量:BAAALAAECgEIAQAAAA==.元素灬泯灭:BAAALAAECgYIBgAAAA==.',['克吕']='克吕墨涅:BAAALAAECgYIBwAAAA==.',['公主']='公主了逍遥:BAAALAAECgMIAwAAAA==.',['养只']='养只猫叫狗子:BAABLAAFFH8IAAISAAIIwwAVRgBZAAASAAIIwwAVRgBZAAAAAA==.',['冉易']='冉易:BAAALAAECggICAAAAA==.',['再見']='再見不見:BAABLAAFFH8KAAIKAAIITRgONACjAAAKAAIITRgONACjAAABLAAFFAIICgAMANAXAA==.',['冥王']='冥王再先:BAAALAAFFAEIAQAAAA==.冥王再现:BAAALAAFFAIIBAAAAA==.冥王圣闪:BAABLAAECn8XAAIOAAgIHwileAAPAQAOAAgIHwileAAPAQAAAA==.',['冰战']='冰战:BAAALAADCgcIBwAAAA==.',['冲锋']='冲锋致死:BAAALAADCgEIAQAAAA==.',['凯尔']='凯尔文:BAACLAAFFH8MAAITAAIInxn5KgClAAATAAIInxn5KgClAAAsAAQKfycAAhMACAhbI8oNADMDABMACAhbI8oNADMDAAAA.',['列奥']='列奥德罗:BAAALAADCggICAAAAA==.',['别看']='别看我长得丑:BAAALAAECgYIDQAAAA==.别看我长得呆:BAAALAAECgEIAQABLAAECgYIDQAUAAAAAA==.别看我长得妖:BAAALAAECgYICQABLAAECgYIDQAUAAAAAA==.别看我长得小:BAAALAAECgYIBgABLAAECgYIDQAUAAAAAA==.别看我长得恶:BAAALAAECgYIDAABLAAECgYIDQAUAAAAAA==.别看我长得花:BAAALAAECgMIAwABLAAECgYIDQAUAAAAAA==.别看我长得龘:BAAALAAECgYICgAAAA==.',['剩蛋']='剩蛋结:BAAALAADCggIDQAAAA==.',['医者']='医者不目医:BAAALAAFFAIIAgAAAA==.',['千夜']='千夜亡刃:BAAALAAFFAIIAwAAAA==.',['千早']='千早丶爱音:BAABLAAFFH8GAAIKAAYIIBE4IwBvAQAKAAYIIBE4IwBvAQAAAA==.',['卡奇']='卡奇:BAAALAAECggICAAAAA==.',['卡提']='卡提希娅:BAAALAAECgYIDAAAAA==.',['原始']='原始圣骑:BAABLAAECn8fAAIOAAgIZh7yHAAtAgAOAAgIZh7yHAAtAgAAAA==.',['叛逆']='叛逆人生:BAABLAAFFH8MAAMVAAII7huDEACOAAAVAAII7huDEACOAAARAAIIOQtMYgB1AAAAAA==.',['叨叨']='叨叨个没完:BAAALAAECgYIBgAAAA==.',['只恋']='只恋剑:BAAALAADCgIIAgAAAA==.',['吃战']='吃战复的妖怪:BAABLAAFFH8GAAITAAYImhdfGACeAQATAAYImhdfGACeAQAAAA==.吃战复的怪兽:BAABLAAFFH8MAAITAAYIeRZ9GQCXAQATAAYIeRZ9GQCXAQAAAA==.吃战复的怪物:BAABLAAFFH8ZAAITAAYInhqoFQCvAQATAAYInhqoFQCvAQAAAA==.',['呀丶']='呀丶我的眼:BAAALAAECgYIBgAAAA==.',['呦丶']='呦丶:BAABLAAECn8VAAIKAAgIPxglRABVAgAKAAgIPxglRABVAgAAAA==.呦丶功夫:BAAALAADCgYIBgAAAA==.',['和平']='和平饭店:BAAALAAFFAIIAgAAAA==.',['咕咕']='咕咕牛:BAAALAAECgYIBgAAAA==.',['咖啡']='咖啡猎手:BAAALAAECgUIBQAAAA==.',['咣咣']='咣咣丶德:BAAALAADCgYIBgAAAA==.咣咣丶珈:BAAALAADCgYIDAAAAA==.',['咪朵']='咪朵儿:BAAALAADCgcIBwAAAA==.',['喀尔']='喀尔刻:BAAALAAECgIIAgAAAA==.',['喝后']='喝后摇一摇:BAAALAAECgYIBgAAAA==.',['噩梦']='噩梦的泪:BAAALAAECgYIBgAAAA==.',['四喜']='四喜丸子:BAACLAAFFH8IAAIWAAIIggoKWQBlAAAWAAIIggoKWQBlAAAsAAQKfyUAAwsACAgMDs9uAHABAAsABwhYC89uAHABABYACAgRC7qhADsBAAAA.',['回首']='回首心远:BAAALAAFFAMIAwAAAA==.',['圆圆']='圆圆哒蘑菇酱:BAAALAAECgYIDQAAAA==.',['坨坨']='坨坨是只猫:BAAALAAFFAEIAQAAAA==.',['塔隆']='塔隆丨血魔:BAAALAAECgYIEgAAAA==.',['夙翼']='夙翼:BAACLAAFFH8KAAIPAAMI9BKPbgCEAAAPAAMI9BKPbgCEAAAsAAQKfysAAg8ACAgIH880AIgCAA8ACAgIH880AIgCAAAA.',['夜戮']='夜戮:BAAALAAFFAIIAgAAAA==.',['夜耿']='夜耿耿而不寐:BAABLAAFFH8YAAMSAAYI7BjcBgDrAQASAAYI7BjcBgDrAQAXAAEIqhiAJABUAAAAAA==.',['夜魇']='夜魇:BAABLAAFFH8JAAIDAAMIDxVJVQCeAAADAAMIDxVJVQCeAAAAAA==.',['大师']='大师救我:BAAALAAECggICAAAAA==.',['大福']='大福哥:BAAALAAECgYIBgAAAA==.',['大笨']='大笨牛牛:BAAALAAECgcIBwAAAA==.',['大飞']='大飞庆:BAABLAAFFH8IAAIDAAMI/xYnTwCiAAADAAMI/xYnTwCiAAAAAA==.',['大香']='大香波:BAAALAAECgUIEAAAAA==.',['天王']='天王盖地虎丶:BAAALAADCgEIAQAAAA==.',['天童']='天童爱丽丝:BAAALAAECgYIEAABLAAFFAIIDgAEADUgAA==.',['太极']='太极宗师雷雷:BAAALAAECgYIDAAAAA==.',['失落']='失落:BAABLAAFFH8GAAIWAAIIEhr9RgCRAAAWAAIIEhr9RgCRAAAAAA==.失落的琴弦:BAABLAAFFH8OAAISAAIIMw7eMQCMAAASAAIIMw7eMQCMAAAAAA==.',['奈非']='奈非天:BAABLAAECn8WAAIOAAYI5hQvvACNAQAOAAYI5hQvvACNAQAAAA==.',['奥斯']='奥斯卡:BAAALAAECgEIAQAAAA==.',['如此']='如此随意:BAABLAAFFH8GAAIRAAYIhw+CKABxAQARAAYIhw+CKABxAQAAAA==.',['如花']='如花美眷:BAAALAADCgUIBQAAAA==.',['子瓜']='子瓜单戈:BAAALAAECgIIAgAAAA==.',['守元']='守元:BAAALAAFFAIIBAAAAA==.',['安于']='安于长情:BAAALAAFFAIIAgAAAA==.',['安魂']='安魂夜:BAABLAAFFH8HAAIRAAIItwT7aAAuAAARAAIItwT7aAAuAAAAAA==.',['宝宝']='宝宝是本体:BAAALAAECgYIBwAAAA==.',['寂寞']='寂寞的收获:BAAALAAECgQIAgAAAA==.',['寒风']='寒风袭击了你:BAAALAAECggIDQAAAA==.',['小冰']='小冰酱:BAAALAAFFAMIBAAAAA==.',['小凶']='小凶许:BAAALAAECgMIBgAAAA==.',['小叨']='小叨叨:BAAALAAECgYIBgAAAA==.',['小吼']='小吼咆哮:BAAALAADCgEIAQAAAA==.',['小斩']='小斩弑:BAAALAAECgcIDQAAAA==.',['小晴']='小晴天:BAABLAAFFH8GAAIVAAYIIAkoAgCoAQAVAAYIIAkoAgCoAQAAAA==.',['小灬']='小灬八:BAAALAAECggICAAAAA==.',['小狗']='小狗子瑜:BAAALAAFFAYIBAAAAA==.',['小狙']='小狙魔:BAAALAAECgUICgAAAA==.',['小狩']='小狩人:BAAALAAECgYIDAAAAA==.',['小饿']='小饿魔:BAAALAAECgYIEgAAAA==.',['小香']='小香猪:BAABLAAFFH8YAAIKAAUIrRKzLAAxAQAKAAUIrRKzLAAxAQAAAA==.',['小鸟']='小鸟游星野:BAACLAAFFH8OAAMEAAIINSCeLwC+AAAEAAIINSCeLwC+AAAFAAEInAjELQBIAAAsAAQKfxQAAgQACAhjHEgwAHsCAAQACAhjHEgwAHsCAAAA.',['屠千']='屠千军:BAAALAAECgQIBAAAAA==.',['屠苏']='屠苏:BAAALAAECgMIAwAAAA==.',['岁岁']='岁岁年年:BAAALAADCgQIBAAAAA==.',['希斯']='希斯帕拉丁:BAAALAAFFAIIAwAAAA==.希斯萨鲁曼:BAAALAAFFAIIAwAAAA==.希斯黛梦:BAAALAAECgYICgAAAA==.',['帕特']='帕特拉尔:BAAALAAECgUIBQAAAA==.',['幸运']='幸运小绿人:BAABLAAFFH8XAAMPAAYItB/dIwCiAQAPAAYItB/dIwCiAQAYAAMIVRHEEwDIAAABLAAFFAgIGQABAHgiAA==.幸运小蓝人:BAABLAAFFH8WAAMWAAYI2yV4BACAAgAWAAYI2yV4BACAAgALAAUIdB6jGgBqAQABLAAFFAgIGQABAHgiAA==.',['幽灵']='幽灵比蒙:BAAALAAFFAIIAgAAAA==.',['张叔']='张叔叔:BAAALAAECgYICgAAAA==.',['影魂']='影魂巨龙:BAABLAAFFH8UAAIPAAcI4QjCOQBaAQAPAAcI4QjCOQBaAQAAAA==.',['彼岸']='彼岸来客:BAAALAADCggICAAAAA==.',['御宅']='御宅族:BAAALAAECgIIAgAAAA==.',['德意']='德意忘形:BAAALAADCgEIAQAAAA==.',['德魯']='德魯伊娃:BAAALAAECggIBAAAAA==.',['快乐']='快乐星球:BAAALAADCgMIAwAAAA==.',['恶灬']='恶灬魔大灬师:BAAALAAECgYIBgAAAA==.',['恶灵']='恶灵血翼:BAAALAAECgMIAwAAAA==.',['恶魔']='恶魔少女:BAAALAAECggICQAAAA==.',['惊天']='惊天风骚:BAAALAAECgQIBQAAAA==.',['想的']='想的是你:BAAALAAECggICgAAAA==.',['意大']='意大利炮:BAAALAAFFAIIAgAAAA==.',['慈悲']='慈悲度魂落:BAAALAAECgEIAQAAAA==.',['我不']='我不是花荣:BAAALAAECgYICAAAAA==.',['我先']='我先下了:BAAALAAECgEIAQAAAA==.',['我想']='我想抓只小德:BAAALAAECgYIBgAAAA==.',['战峰']='战峰:BAAALAADCgYIBgAAAA==.',['户外']='户外大型妲己:BAAALAADCgIIAgAAAA==.户外异型妲己:BAAALAADCgQIBAAAAA==.',['手太']='手太红也不好:BAAALAAECgYIBwAAAA==.',['把那']='把那小妹放开:BAAALAADCgYIBgAAAA==.',['拔起']='拔起树根然后:BAACLAAFFH8GAAIBAAIIZCOiFwDEAAABAAIIZCOiFwDEAAAsAAQKfyIAAwEACAj8G/seAHUCAAEACAj8G/seAHUCAAwAAQhfCQStADIAAAAA.',['无影']='无影随行者:BAAALAAECgYICAAAAA==.',['无敌']='无敌小超超:BAAALAADCggIEgAAAA==.无敌张大炮:BAABLAAFFH8JAAMFAAMIcxJKDwCmAAAFAAIIuBhKDwCmAAAEAAII4AWkUgBpAAAAAA==.',['日月']='日月矢口:BAAALAAECggICQAAAA==.',['星丶']='星丶空:BAAALAAECggIBgAAAA==.星丶耀:BAAALAAECgUIBQAAAA==.',['星熊']='星熊勇仪:BAAALAAECgYIDwAAAA==.',['春日']='春日影:BAACLAAFFH8MAAIDAAIILCRZOADBAAADAAIILCRZOADBAAAsAAQKfx0AAgMACAhkJCYZAAwDAAMACAhkJCYZAAwDAAEsAAUUCAgPAAMAOwAA.',['暗影']='暗影灬伊妹:BAAALAAECgEIAQAAAA==.',['月神']='月神血之舞:BAABLAAECn8XAAIOAAcINxszZQAgAgAOAAcINxszZQAgAgAAAA==.',['有媳']='有媳妇儿的猪:BAAALAAECgYIBwAAAA==.',['有痔']='有痔青年:BAAALAAECgYIBgAAAA==.',['木有']='木有鱼丸:BAAALAAFFAIIAgAAAA==.',['李富']='李富贵:BAAALAAECgIIAgAAAA==.',['枫林']='枫林唱晚:BAAALAADCgIIAgABLAAFFAgICgAWAO4aAA==.',['桀桀']='桀桀:BAAALAADCgcIBwABLAAFFAIICAAZAHUkAA==.',['桃塔']='桃塔罗斯:BAAALAAECgIIAgAAAA==.',['梦幻']='梦幻芭比:BAACLAAFFH8KAAMXAAQIXQxbIQB7AAAXAAII8AZbIQB7AAASAAIIxhC4OwBzAAAsAAQKfxYAAxIACAgHEbhIALMBABIACAgHEbhIALMBABcABQgbDec3AKMAAAEsAAUUBwgyABgA3RYA.',['椰风']='椰风挡不住:BAACLAAFFH8GAAIYAAIIaxsCHQCUAAAYAAIIaxsCHQCUAAAsAAQKfxkAAhgACAi+IZMQAN8CABgACAi+IZMQAN8CAAAA.',['死丶']='死丶牛:BAAALAAECgcIBgAAAA==.',['死亡']='死亡不会飞:BAACLAAFFH8NAAMDAAMIMRMdTQCjAAADAAMIMRMdTQCjAAAaAAEIbgZUHwBIAAAsAAQKfxoAAwMACAhMHJExALABAAMABwjNHJExALABABoAAwhtGd4/AN0AAAAA.',['汏苯']='汏苯疍:BAAALAAFFAgIAgAAAA==.',['沾繁']='沾繁霜而至曙:BAABLAAFFH8GAAINAAYIJwkgFABKAQANAAYIJwkgFABKAQAAAA==.',['法師']='法師娃:BAAALAAFFAIIBAAAAA==.',['法琳']='法琳:BAAALAADCggICAAAAA==.',['泡椒']='泡椒水煮肉:BAAALAAECgYIBgAAAA==.',['流氓']='流氓丸少哥:BAAALAAECgYICwAAAA==.流氓壞叔叔:BAAALAAFFAIIAgAAAA==.',['浪漫']='浪漫血色:BAAALAAFFAIIAgAAAA==.',['海蛎']='海蛎子号:BAAALAAFFAMIAwAAAA==.',['深更']='深更半夜:BAAALAADCgEIAQAAAA==.',['深绘']='深绘理:BAAALAADCgIIAgAAAA==.',['温妮']='温妮丶班班:BAAALAADCgUIAwAAAA==.温妮丶莉莉:BAAALAADCgEIAQAAAA==.',['满身']='满身雪花肉:BAAALAADCgcICwAAAA==.',['漂洋']='漂洋过海:BAAALAAFFAEIAQAAAA==.',['漠北']='漠北狐:BAABLAAFFH8aAAIEAAYITgf5NQA5AQAEAAYITgf5NQA5AQAAAA==.',['潘诺']='潘诺佩亚:BAAALAAECgcIBwAAAA==.',['火舞']='火舞丶天涯:BAAALAAECgYIEQAAAA==.火舞劣劣:BAAALAAECgYIEQAAAA==.',['火雲']='火雲:BAAALAAECgYIBgAAAA==.',['火鸡']='火鸡味锅巴:BAABLAAFFH8NAAIWAAMI1h3WLQD8AAAWAAMI1h3WLQD8AAAAAA==.',['灵异']='灵异之光:BAAALAAECgYIEgAAAA==.',['烈焰']='烈焰珏仔:BAABLAAECn8UAAMBAAgIUwsxSQDxAAABAAgIUwsxSQDxAAAMAAMIgg2njQCOAAAAAA==.',['無糖']='無糖冰可乐丶:BAABLAAFFH8IAAIOAAIIex2fKQC2AAAOAAIIex2fKQC2AAAAAA==.',['熊猫']='熊猫滑翔者:BAAALAAECgQIBAAAAA==.',['爆裂']='爆裂绽放:BAAALAAFFAIIAgAAAA==.',['爪子']='爪子要放上边:BAAALAAECgUIBQAAAA==.',['爱吃']='爱吃一鞭:BAAALAAECgQIBAAAAA==.',['爱心']='爱心便当:BAAALAAECgYIDQAAAA==.',['牛牛']='牛牛痒痒德:BAAALAAECgEIAQAAAA==.牛牛飞起:BAABLAAFFH8IAAIPAAYIvg0cPwBJAQAPAAYIvg0cPwBJAQAAAA==.',['牛鞭']='牛鞭奶爆小嘴:BAAALAAECgQIBAAAAA==.',['牢大']='牢大:BAABLAAFFH8NAAIbAAMIBg9SIgBoAAAbAAMIBg9SIgBoAAAAAA==.',['犇犇']='犇犇牛:BAAALAAECgYICwAAAA==.',['狂镦']='狂镦没伤害:BAAALAAECgYICgAAAA==.',['狼大']='狼大灰:BAABLAAECn8XAAIcAAcITw5cFgAQAQAcAAcITw5cFgAQAQAAAA==.',['猫小']='猫小乐:BAACLAAFFH8RAAMTAAQIJwwJMQC/AAATAAQIbQoJMQC/AAAbAAMIDw1bJABZAAAsAAQKfxgAAxsABwi0F5MSALgBABsABwi0F5MSALgBABMABggzDG1hAPEAAAAA.',['玄灵']='玄灵:BAACLAAFFH8JAAIWAAMIHhssMQDnAAAWAAMIHhssMQDnAAAsAAQKfxQAAhYACAjFHfoyAEgCABYACAjFHfoyAEgCAAAA.玄灵之舞:BAABLAAFFH8HAAIOAAQIGAivOQCzAAAOAAQIGAivOQCzAAAAAA==.',['玩爆']='玩爆圣光:BAACLAAFFH8GAAIKAAIIrgj8WwBBAAAKAAIIrgj8WwBBAAAsAAQKfxYAAgoACAi7HA4SAE0CAAoACAi7HA4SAE0CAAAA.',['甜甜']='甜甜丶:BAAALAADCgQIBAAAAA==.',['疯僧']='疯僧醉菩提:BAABLAAECn8fAAMHAAYIXxzbHADNAQAHAAYIXxzbHADNAQAdAAEIGBHlawAzAAAAAA==.',['白上']='白上吹雪:BAACLAAFFH8IAAIRAAIIcg80UQCQAAARAAIIcg80UQCQAAAsAAQKfyAAAxUACAjSILYSAIsCABUACAgyILYSAIsCABEABwhWHmo6AGACAAAA.',['白牛']='白牛:BAAALAAECgYICAAAAA==.',['白衣']='白衣长歌:BAAALAAFFAIIBAAAAA==.',['白银']='白银之手团长:BAABLAAFFH8FAAIOAAIIwRf7WABKAAAOAAIIwRf7WABKAAAAAA==.',['皇灬']='皇灬诺加娜:BAABLAAFFH8QAAMPAAYIUg6bVAD8AAAPAAYIUg6bVAD8AAAYAAIIHBWoIQCFAAAAAA==.',['皮丶']='皮丶皮:BAAALAAECgEIAQAAAA==.',['皮皮']='皮皮鲁小爷:BAAALAAECgEIAQAAAA==.',['盖伦']='盖伦儿:BAACLAAFFH8IAAIZAAIIdST3CADTAAAZAAIIdST3CADTAAAsAAQKfxgAAhkACAiFJLUDAEwDABkACAiFJLUDAEwDAAAA.',['真理']='真理穿孔:BAAALAAECgEIAQAAAA==.',['石矶']='石矶娘娘:BAAALAADCggICAAAAA==.',['神圣']='神圣裁决:BAAALAADCgMIAwAAAA==.',['竞星']='竞星丶:BAAALAADCgUIBQAAAA==.',['竹杖']='竹杖芒鞋:BAAALAAFFAIIBAAAAA==.',['第一']='第一最寂寞:BAAALAAECgYICwAAAA==.',['等等']='等等:BAAALAAECgIIAgAAAA==.',['红面']='红面紫牙:BAAALAAECgYIBgAAAA==.',['纯爱']='纯爱骑士:BAABLAAFFH8GAAIOAAMIUgmvHgDYAAAOAAMIUgmvHgDYAAAAAA==.',['经典']='经典怀旧:BAAALAAECgYICQAAAA==.',['维生']='维生素医:BAAALAAECgQIBAAAAA==.',['维纳']='维纳斯的诅咒:BAABLAAFFH8GAAIRAAII2xW9SwCVAAARAAII2xW9SwCVAAAAAA==.',['罗曼']='罗曼:BAAALAAECgYICAAAAA==.',['美型']='美型师:BAAALAADCgYIBgAAAA==.',['群青']='群青與熟褐:BAABLAAECn8WAAIPAAYIzBTliQA5AQAPAAYIzBTliQA5AQAAAA==.',['耀西']='耀西:BAAALAAFFAIIAgAAAA==.',['肉肉']='肉肉宝:BAABLAAFFH8SAAIPAAYIQh6dIACwAQAPAAYIQh6dIACwAQAAAA==.',['肥宅']='肥宅今夜无眠:BAAALAADCgYIBgAAAA==.',['胖次']='胖次打次:BAAALAADCgYIBgAAAA==.',['胖胖']='胖胖萨满:BAAALAAECgUIBQAAAA==.',['胭脂']='胭脂酒椛间醉:BAAALAAECgYIBgABLAAFFAgIMQASAHUiAA==.',['能闻']='能闻闻你脚吗:BAAALAAECgEIAQAAAA==.',['自由']='自由既强权:BAAALAAECgUIBQAAAA==.',['自胜']='自胜者强:BAAALAADCgIIAgAAAA==.',['艾莉']='艾莉桑德:BAAALAAECgIIAgAAAA==.',['芋泥']='芋泥啵啵:BAAALAAECgYIAwAAAA==.',['芒芒']='芒芒露露:BAAALAAECggIBgAAAA==.',['花繁']='花繁似錦:BAAALAADCgEIAQAAAA==.',['花開']='花開似落:BAAALAAECgQIBAAAAA==.',['苍星']='苍星石:BAAALAADCgIIAwAAAA==.',['英伦']='英伦玫瑰:BAABLAAFFH8GAAIPAAII+hONigBIAAAPAAII+hONigBIAAAAAA==.英伦雪花:BAAALAAECgEIAQAAAA==.',['苹果']='苹果猫:BAAALAAECgEIAQAAAA==.',['莉丶']='莉丶酱:BAAALAAECgYIDgAAAA==.',['莫利']='莫利亚提:BAAALAAECggIAwAAAA==.',['莫提']='莫提斯:BAAALAAFFAIIAgAAAA==.',['菜鸟']='菜鸟:BAAALAAECgYIBwAAAA==.',['菜鸡']='菜鸡互啄:BAACLAAFFH8IAAIeAAIIehcZDQCLAAAeAAIIehcZDQCLAAAsAAQKfx4AAx4ACAjqG/kPAGQCAB4ACAjqG/kPAGQCAAoAAQh6F+hTATkAAAAA.',['萨鲁']='萨鲁法尔大王:BAAALAAECgYIDAAAAA==.',['落叶']='落叶满长安:BAAALAADCgYIBgAAAA==.',['蔚然']='蔚然橙风:BAAALAADCggICAAAAA==.',['薇薇']='薇薇安:BAAALAAFFAIIAgAAAA==.',['虚空']='虚空撕裂者:BAAALAAFFAIIAgAAAA==.',['蟑螂']='蟑螂恶霸丿:BAAALAAECgYIBgAAAA==.',['血色']='血色珊瑚骑:BAABLAAFFH8KAAIOAAIIhCSUHwDUAAAOAAIIhCSUHwDUAAAAAA==.',['術士']='術士娃:BAAALAAECgUIBQAAAA==.',['裴柱']='裴柱现:BAAALAADCgYIBgAAAA==.',['西渡']='西渡残桥:BAAALAAECgYIBgAAAA==.',['要帥']='要帥一辈子:BAAALAAFFAgIAgAAAA==.',['让我']='让我看看:BAAALAADCgEIAQAAAA==.',['记录']='记录回忆:BAAALAAECgYICgAAAA==.',['论持']='论持久战:BAACLAAFFH8MAAMHAAIIdAejFQB2AAAHAAIIdAejFQB2AAAdAAEI5wGIGwAxAAAsAAQKfx4AAx0ACAiKF4wlANUBAB0ABwiYFYwlANUBAAcACAivD3IhAJ4BAAAA.',['诗雨']='诗雨馨竹:BAAALAAECgYIDAAAAA==.',['诡坦']='诡坦不会玩:BAAALAAECgMIAwAAAA==.',['贪丶']='贪丶财:BAAALAAECggIBwAAAA==.',['赛拉']='赛拉斐:BAACLAAFFH8GAAINAAIIbBkQFgCtAAANAAIIbBkQFgCtAAAsAAQKfyEAAg0ACAiaHQEPAJ8CAA0ACAiaHQEPAJ8CAAAA.',['蹦蹦']='蹦蹦兔兔:BAACLAAFFH8MAAIEAAMI7RQcTQCGAAAEAAMI7RQcTQCGAAAsAAQKfxoAAgQACAjrGcsoALMBAAQACAjrGcsoALMBAAAA.',['辣条']='辣条花生:BAAALAAECgYIBgAAAA==.',['达美']='达美乐大师:BAAALAAFFAIIAgAAAA==.',['追着']='追着换游戏玩:BAAALAAECgMIBgAAAA==.',['那个']='那个潜行者:BAAALAAECgMIAwAAAA==.',['那谁']='那谁家老谁:BAAALAAFFAIIAgAAAA==.',['醉暧']='醉暧馬娓:BAABLAAFFH8FAAIRAAUIbR/QDwDoAQARAAUIbR/QDwDoAQABLAAFFAgIAQAUAAAAAA==.',['重生']='重生小罗汉:BAAALAADCggICAAAAA==.',['野狼']='野狼伊恩:BAAALAAECggIDgAAAA==.',['銳雯']='銳雯:BAACLAAFFH8IAAIDAAIILB6YUgCfAAADAAIILB6YUgCfAAAsAAQKfyEAAwMACAixIIEqAMgCAAMACAixIIEqAMgCAAIAAQg5DoBNADMAAAAA.',['鋭雯']='鋭雯:BAACLAAFFH8GAAISAAII1BLqLACTAAASAAII1BLqLACTAAAsAAQKfxsAAhIABwgtERBhAFoBABIABwgtERBhAFoBAAAA.',['鑽石']='鑽石糖:BAABLAAFFH8FAAIPAAUIFwvGWgDcAAAPAAUIFwvGWgDcAAAAAA==.',['钚莨']='钚莨少哖丨:BAAALAAECggICQAAAA==.',['钨钢']='钨钢之狼:BAAALAADCgYIBgAAAA==.',['钮扣']='钮扣熊:BAACLAAFFH8MAAMdAAMIuSAzDAC5AAAdAAIIWB8zDAC5AAAQAAMIuSCkEACkAAAsAAQKfxUAAx0ACAiFI64GAFECAB0ABwjJJK4GAFECABAAAwg/H2k+AKMAAAAA.',['银月']='银月追光者:BAABLAAFFH8GAAMfAAII+BO2BAB4AAAfAAII+BO2BAB4AAASAAEIQwAmUwARAAAAAA==.',['长崎']='长崎素世:BAABLAAFFH8ZAAIKAAYIQRoTGQClAQAKAAYIQRoTGQClAQAAAA==.',['阿伊']='阿伊古丽:BAAALAAECgEIAQAAAA==.',['阿尔']='阿尔忒猊斯:BAAALAADCgEIAQAAAA==.',['阿斯']='阿斯特赖亚:BAAALAAECgUIBQAAAA==.',['阿穆']='阿穆木:BAAALAADCgQIBAAAAA==.',['阿芙']='阿芙洛狄忒:BAAALAAECgYICQAAAA==.',['陽光']='陽光下的豆喵:BAAALAADCgYIBgAAAA==.',['随风']='随风浪天涯:BAAALAAECgYIBgAAAA==.',['雨彤']='雨彤:BAAALAAFFAIIAgAAAA==.',['雨敲']='雨敲梳棂:BAAALAAFFAIIAgAAAA==.',['青山']='青山应如是灬:BAAALAAECgYICwAAAA==.',['青灬']='青灬衣:BAAALAAFFAIIBAAAAA==.',['青玉']='青玉德德:BAAALAADCgIIAgAAAA==.',['青面']='青面槽牙:BAAALAAECgYIBgAAAA==.',['頹廢']='頹廢的溫柔:BAEALAAFFAQIBAAAAA==.',['風之']='風之紫电:BAABLAAFFH8MAAMWAAIIVw56WwBkAAAWAAIIVw56WwBkAAALAAII0wC0VQAWAAAAAA==.',['风起']='风起鹤归时:BAAALAAECgIIAgAAAA==.',['飞庆']='飞庆:BAAALAADCgIIAgAAAA==.',['香浓']='香浓那一刻:BAAALAAECgUICAAAAA==.',['香菜']='香菜不吃:BAAALAAECgYIBgAAAA==.',['骑天']='骑天大圣:BAAALAAECgYIBgAAAA==.',['骨感']='骨感妹妹:BAAALAAECgYIBgAAAA==.',['魔法']='魔法舅妈:BAAALAAFFAIIAgAAAA==.',['鮮血']='鮮血伯爵:BAABLAAFFH8IAAIDAAIIChC3hgBCAAADAAIIChC3hgBCAAAAAA==.',['黑火']='黑火黎明:BAAALAAFFAIIAgAAAA==.',['黑百']='黑百合之吻:BAAALAAECgYIBgAAAA==.',['黑翼']='黑翼降临:BAAALAADCgYIBwAAAA==.',['黑魂']='黑魂收割者:BAAALAAECgYIBgAAAA==.',['龘赑']='龘赑赑:BAAALAAFFAIIAgAAAA==.',['龙艺']='龙艺:BAABLAAECn8WAAMSAAYIVQKvUwCCAAASAAYIVQKvUwCCAAAXAAQIBwgTPgB5AAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end