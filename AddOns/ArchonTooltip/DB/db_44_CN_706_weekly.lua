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
 local lookup = {'DemonHunter-Vengeance','Unknown-Unknown','DeathKnight-Frost','Warlock-Destruction','Hunter-BeastMastery','Paladin-Protection','DeathKnight-Blood','Paladin-Holy','Warrior-Protection','Monk-Brewmaster','Shaman-Restoration','Paladin-Retribution','Mage-Arcane','Mage-Frost','Druid-Balance','Druid-Restoration','Hunter-Survival','Hunter-Marksmanship','Warrior-Fury','DemonHunter-Havoc','Priest-Holy','Priest-Shadow','Rogue-Assassination','Monk-Windwalker','Mage-Fire','Warlock-Demonology','Shaman-Elemental','Druid-Guardian','Rogue-Outlaw','Druid-Feral','Rogue-Subtlety',}; local provider = {region='CN',realm='暴风祭坛',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ad='Adibil:BAAALAAFFAIIAwAAAA==.',Al='Alam:BAAALAAFFAIIBAAAAA==.Allenlr:BAAALAAECgUIBQAAAA==.',As='Asxcv:BAAALAAECgYICQAAAA==.',Ba='Baal:BAACLAAFFH8OAAIBAAMIWgnwDwBMAAABAAMIWgnwDwBMAAAsAAQKfyoAAgEACAjlCVo3ABMBAAEACAjlCVo3ABMBAAAA.',Br='Bringdead:BAAALAAECgcICAAAAA==.Bringmagic:BAAALAAECgYICAAAAA==.',Bt='Btelgeusex:BAAALAAECgYIBgAAAA==.',Ca='Cantice:BAAALAAFFAIIAgAAAA==.',Ce='Cecilee:BAAALAADCgUIBQAAAA==.',Ch='Chara:BAAALAAFFAIIAgAAAA==.Christopher:BAAALAAFFAIIAgAAAA==.',Co='Coldcosmic:BAAALAAECgIIAgAAAA==.',Cr='Crusade:BAAALAAFFAQIBAABLAAFFAgIBAACAAAAAA==.',Cu='Curtain:BAAALAAECgYIDAAAAA==.',Di='Dida:BAAALAAECgEIAQAAAA==.',Ea='Eagie:BAABLAAFFH8MAAIDAAYIFhs9BwAxAgADAAYIFhs9BwAxAgAAAA==.',Eu='Euhdhqgdg:BAAALAAECgMIAwAAAA==.',Ez='Ezra:BAAALAAECggICAAAAA==.',Fl='Flynn:BAABLAAFFH8JAAIBAAMIJA5oDQBjAAABAAMIJA5oDQBjAAAAAA==.',Ha='Hahamage:BAAALAADCgcIBwAAAA==.',Ji='Jina:BAAALAADCgYIBwAAAA==.',Ju='Justices:BAAALAAECgEIAQAAAA==.',Ki='Kissok:BAAALAAECgIIAgAAAA==.',Kn='Knock:BAABLAAFFH8eAAIEAAYIkxzKHgCiAQAEAAYIkxzKHgCiAQAAAA==.',Ku='Kuroneko:BAABLAAFFH8GAAIFAAII/iCsMgC/AAAFAAII/iCsMgC/AAAAAA==.',La='Lalune:BAAALAAECgYIEgAAAA==.',Ma='Mac:BAAALAAECgYICwAAAA==.',Me='Mercy:BAAALAAFFAIIAgAAAA==.',Ni='Nightsoul:BAAALAAECgEIAQAAAA==.',Om='Omelette:BAAALAAECgIIAgAAAA==.',Op='Opsdh:BAAALAAECgYIBgAAAA==.Opspala:BAABLAAECn8ZAAIGAAYIYyGsGAAyAgAGAAYIYyGsGAAyAgAAAA==.Opszs:BAAALAAECgYIDgAAAA==.',Os='Oscenery:BAAALAAECgUIBwAAAA==.',Ou='Outsider:BAAALAAECgYIDAAAAA==.',Ph='Philomena:BAABLAAFFH8KAAMHAAYIzgtRBQCiAQAHAAYIJQtRBQCiAQADAAQI+QrUUwDBAAAAAA==.',Pi='Pinarello:BAAALAAECgUIBQAAAA==.',Pk='Pk:BAAALAADCgYICQAAAA==.',Qa='Qaq:BAAALAAFFAIIAgAAAA==.',Ro='Rotazel:BAAALAADCgMIAwAAAA==.',Sa='Santofire:BAAALAADCgQIBAAAAA==.',St='Stewie:BAAALAAFFAIIAgAAAA==.',Su='Summerme:BAAALAADCgQIBAAAAA==.',Te='Tenderness:BAAALAAECgYIEAAAAA==.',Tr='Traitor:BAAALAADCgYIBgAAAA==.',Uu='Uu:BAAALAAECgMIAwAAAA==.',Wd='Wdq:BAAALAAECgQIBgAAAA==.',Xc='Xcott:BAAALAAECgEIAQAAAA==.',Yu='Yukikaze:BAABLAAFFH8LAAMIAAMIohGDHgCuAAAIAAMIohGDHgCuAAAGAAIIvyLNDgChAAABLAAFFAgICgAJACciAA==.',Zu='Zustav:BAAALAAECgYIBgAAAA==.',Zz='Zzwolf:BAAALAADCgYIBgAAAA==.',['一三']='一三得三:BAAALAADCgEIAQAAAA==.',['一头']='一头大叔:BAAALAAECgEIAQAAAA==.',['一寺']='一寺一壶酒:BAABLAAFFH8kAAIKAAYIbAkPDQDTAAAKAAYIbAkPDQDTAAAAAA==.',['一把']='一把小骨头:BAABLAAFFH8JAAILAAMIahUNGwDeAAALAAMIahUNGwDeAAAAAA==.',['一拳']='一拳丶:BAAALAAECgEIAQAAAA==.',['七零']='七零四张医师:BAABLAAFFH8IAAIMAAYIRgkZKAA5AQAMAAYIRgkZKAA5AQAAAA==.',['上海']='上海萌牛:BAACLAAFFH8kAAMNAAYIxRaNIACUAQANAAYIixaNIACUAQAOAAMIoRSsDQCAAAAsAAQKfyYAAw4ACAjUIRIRAJ4CAA4ABwh3IBIRAJ4CAA0ACAhbHulBAEUCAAAA.',['不吃']='不吃花菜:BAAALAAECgQIBAAAAA==.',['不死']='不死川實彌:BAAALAAECgYICAAAAA==.',['不留']='不留牛油:BAACLAAFFH8LAAIPAAMI/gsQGwCYAAAPAAMI/gsQGwCYAAAsAAQKfyEAAg8ABwiDGpgpACQCAA8ABwiDGpgpACQCAAAA.',['与子']='与子偕老:BAAALAAECgYIBgAAAA==.与子偕行:BAAALAAECgYICQAAAA==.与子巨馍:BAAALAAECgUIBQAAAA==.',['专业']='专业的小德:BAAALAAFFAIIAwAAAA==.专业的狂怒萨:BAAALAAFFAIIAgAAAA==.',['专啃']='专啃面包:BAAALAAECgMIAwAAAA==.',['丝瓜']='丝瓜琪:BAAALAADCgYIBgAAAA==.',['丨野']='丨野蛮教主:BAABLAAECn8gAAIMAAcIBB4fRACPAQAMAAcIBB4fRACPAQAAAA==.',['丶是']='丶是雨诺啊:BAAALAAECgMIAwAAAA==.',['丶柒']='丶柒囍:BAAALAAECgYICQAAAA==.',['丶沐']='丶沐小彬:BAAALAAECgYIDAAAAA==.',['丶雨']='丶雨诺:BAABLAAFFH8KAAILAAMIhhhRMgDgAAALAAMIhhhRMgDgAAAAAA==.丶雨诺吖:BAAALAAFFAIIAgAAAA==.丶雨诺啊:BAAALAAECgIIAgAAAA==.丶雨诺阿:BAABLAAFFH8MAAIDAAMINhrzWQCdAAADAAMINhrzWQCdAAAAAA==.',['乀丨']='乀丨丨乀肥:BAAALAAECggICAAAAA==.',['乄卝']='乄卝:BAAALAADCgcIBwAAAA==.',['乄蓝']='乄蓝色妖姬:BAABLAAECn8UAAIFAAYIMBr5pACkAQAFAAYIMBr5pACkAQAAAA==.',['乌拉']='乌拉乌拉乌拉:BAABLAAFFH8MAAMQAAQI9hz5GQBdAQAQAAQI9hz5GQBdAQAPAAIISx4ILABSAAABLAAFFAgICgAJACciAA==.乌拉乌拉战:BAACLAAFFH8KAAIJAAIIJyLaEwCxAAAJAAIIJyLaEwCxAAAsAAQKfygAAgkACAicI98FADgDAAkACAicI98FADgDAAAA.',['乌龟']='乌龟的黑头:BAACLAAFFH8XAAIFAAYIESESFgDiAQAFAAYIESESFgDiAQAsAAQKfxwAAwUACAiVI80eAN8CAAUACAiKI80eAN8CABEAAQgYJhsPAHEAAAAA.',['九州']='九州冰霜:BAABLAAFFH8GAAMOAAYIahldCgDHAAANAAMI+Q4zPQDUAAAOAAMI2iNdCgDHAAAAAA==.',['乱鸠']='乱鸠来:BAAALAADCgMIAwAAAA==.',['二宫']='二宫沙树:BAAALAADCgMIAwAAAA==.',['二舅']='二舅:BAAALAAFFAIIBAAAAA==.',['云熙']='云熙:BAAALAADCgYIBgAAAA==.',['五十']='五十以到:BAAALAADCgMIAwAAAA==.',['亮晶']='亮晶晶:BAAALAADCgUIBQAAAA==.',['亮瞎']='亮瞎你狗眼:BAABLAAFFH8VAAIMAAYIJhb9GgCDAQAMAAYIJhb9GgCDAQAAAA==.',['人心']='人心薄凉丶伤:BAABLAAFFH8FAAIQAAIIlByQIQCfAAAQAAIIlByQIQCfAAAAAA==.',['人熊']='人熊猫鸟鹿树:BAAALAADCgcIBwAAAA==.',['今晩']='今晩打老虎:BAABLAAFFH8OAAMFAAMIaBiVbgCEAAAFAAMIaBiVbgCEAAASAAII3Ab2LQBpAAAAAA==.',['仓井']='仓井玛利兰:BAAALAAECgUIBQAAAA==.',['仓颉']='仓颉:BAAALAAECgUICAAAAA==.',['以战']='以战止殇:BAABLAAFFH8SAAIDAAUIxgukSQAPAQADAAUIxgukSQAPAQAAAA==.',['任云']='任云亦云:BAAALAADCgEIAQAAAA==.',['伄戼']='伄戼:BAAALAAECgYICgAAAA==.',['伊利']='伊利纯牛奶:BAAALAAECgYIBgAAAA==.',['会长']='会长来了:BAACLAAFFH8GAAMJAAIInQmBKwBmAAAJAAIIygWBKwBmAAATAAEIUw0YUgBMAAAsAAQKfxkAAwkACAhLFv5AAH8BAAkABwifFf5AAH8BABMAAgjVEUDtAH0AAAAA.',['何阿']='何阿姨:BAAALAAECgUIBQAAAA==.',['你也']='你也曾心动吧:BAAALAAFFAIIAwAAAA==.',['你又']='你又:BAAALAAFFAIIAgAAAA==.',['你家']='你家鸽鸽:BAAALAAECgYICgABLAAFFAgICAAQADMeAA==.',['你过']='你过来呀:BAAALAAECgYIBgAAAA==.',['佢老']='佢老豆:BAAALAAECgQICgAAAA==.',['依念']='依念逍遥:BAAALAAECgYIBgAAAA==.',['依波']='依波拉:BAABLAAFFH8OAAIOAAIIqSPxCwCkAAAOAAIIqSPxCwCkAAAAAA==.',['倾城']='倾城绝色:BAAALAAECggICAAAAA==.',['傲娇']='傲娇小公主:BAAALAAECgYIBgAAAA==.',['傲月']='傲月凌霜:BAAALAADCgQIBAAAAA==.',['像疯']='像疯一样自由:BAAALAAECgYIBgAAAA==.',['元素']='元素忽悠者:BAAALAADCgcIBwAAAA==.',['克咳']='克咳胶囊:BAAALAADCgEIAQAAAA==.',['克里']='克里斯蒂:BAAALAAECggIDwAAAA==.',['全村']='全村的希望:BAAALAAECgIIAgAAAA==.',['兽皇']='兽皇之皇:BAAALAAFFAIIAgAAAA==.',['内呗']='内呗:BAAALAAECgYIBwAAAA==.',['冖亼']='冖亼冖:BAABLAAFFH8WAAMQAAUIxhraFgB9AQAQAAUIxhraFgB9AQAPAAMI/xF+JgB+AAAAAA==.',['军团']='军团一再临:BAAALAAECgIIAgAAAA==.',['冰嗱']='冰嗱铁:BAAALAAECggIBgAAAA==.',['冰封']='冰封柬柬:BAAALAAECgYIEQAAAA==.',['冰符']='冰符:BAABLAAECn8ZAAIOAAYIiQ/DSABNAQAOAAYIiQ/DSABNAQAAAA==.',['冰风']='冰风血雨:BAAALAAECgYIBgAAAA==.',['冲锋']='冲锋就开怪:BAAALAAECgYIEAAAAA==.',['凉拌']='凉拌花椰菜:BAABLAAECn8ZAAIEAAgIUA+TcQCjAQAEAAgIUA+TcQCjAQABLAAFFAMIDgAFAGgYAA==.',['凉枫']='凉枫荷叶塘:BAABLAAFFH8KAAMQAAIIogmhPQBiAAAQAAIIogmhPQBiAAAPAAIIRgxLNQA6AAABLAAFFAMIDgAFAGgYAA==.',['凝望']='凝望深渊:BAABLAAFFH8KAAIDAAUI+x3pNABoAQADAAUI+x3pNABoAQABLAAFFAYIFwAFABEhAA==.',['凤凰']='凤凰院喵真:BAAALAAECgcIBwAAAA==.',['凶残']='凶残的喵了喵:BAAALAAECgYIBgAAAA==.',['刘海']='刘海柱丶:BAAALAAECgYICgAAAA==.',['刮刮']='刮刮:BAAALAAECggIDAAAAA==.',['前世']='前世今生:BAAALAADCgQIBAAAAA==.',['功夫']='功夫小豹:BAAALAADCgEIAQAAAA==.功夫织女:BAAALAAECgMIAwAAAA==.',['加里']='加里维克斯:BAAALAAECgYIBgAAAA==.',['加钟']='加钟五百起:BAAALAAECgYIEgAAAA==.',['匹格']='匹格叄号:BAAALAAFFAIIAwAAAA==.',['十五']='十五年后:BAAALAAFFAIIAgAAAA==.',['半月']='半月九天:BAAALAADCgYIBgAAAA==.',['半条']='半条小黄鱼:BAAALAAECgYICAAAAA==.',['南国']='南国小虎:BAAALAADCgQIBAAAAA==.南国小豹:BAAALAADCgMIAwAAAA==.',['卡布']='卡布遛:BAAALAAFFAYIBAAAAA==.',['卩丶']='卩丶橘子灬:BAAALAAFFAIIAgAAAA==.卩丶芒果灬:BAAALAAFFAIIAgAAAA==.卩丶苹果灬:BAACLAAFFH8KAAIFAAYIphfPLwB4AQAFAAYIphfPLwB4AQAsAAQKfxwAAgUABgglJK8vAP0BAAUABgglJK8vAP0BAAAA.卩丶草莓灬:BAAALAAFFAIIBAAAAA==.卩丶菠萝灬:BAAALAAFFAIIBAAAAA==.卩丶西瓜灬:BAACLAAFFH8JAAIMAAUIqx8CHQB4AQAMAAUIqx8CHQB4AQAsAAQKfyIAAgwABwhwIEc7AIkCAAwABwhwIEc7AIkCAAAA.',['原神']='原神丶启动:BAAALAADCgMIAwAAAA==.',['叁妖']='叁妖武:BAAALAAECgQIBAAAAA==.',['又要']='又要上班了:BAAALAAECgYICwAAAA==.',['吃泡']='吃泡面没叉子:BAAALAADCgYIBgAAAA==.',['吃麻']='吃麻瓜:BAAALAAECggICAAAAA==.',['吉川']='吉川库郎:BAAALAAFFAQIBAAAAA==.',['吊打']='吊打吊丝战:BAAALAAECgIIAgAAAA==.',['名字']='名字不违规:BAAALAAFFAIIAgABLAAFFAYIFwAFABEhAA==.',['名流']='名流灬天目:BAAALAAECgMIBQAAAA==.',['吾行']='吾行之骑:BAAALAAECgUIBQAAAA==.吾行天下:BAAALAAECgUIBAAAAA==.',['咕咕']='咕咕永不为奴:BAAALAAECgQIBAAAAA==.',['咻丨']='咻丨给你一箭:BAABLAAFFH8JAAIFAAYISROsLQB/AQAFAAYISROsLQB/AQAAAA==.',['哈咪']='哈咪:BAAALAAFFAQIBAAAAA==.',['哈哈']='哈哈明:BAAALAADCgIIAgAAAA==.',['哈基']='哈基恶:BAAALAAECgIIAgAAAA==.哈基米:BAAALAAECgYIBwAAAA==.',['哎嘿']='哎嘿嘿:BAAALAADCgYIBgAAAA==.',['唯他']='唯他命吸:BAAALAAECgYIBgAAAA==.',['善恶']='善恶的彼岸:BAAALAAECgMIAwAAAA==.',['嘉明']='嘉明:BAABLAAFFH8GAAILAAII8hSkVgBuAAALAAII8hSkVgBuAAAAAA==.',['嘟哩']='嘟哩嘟:BAAALAAFFAIIBAAAAA==.',['嘴上']='嘴上说不要:BAABLAAFFH8GAAIPAAYIdRTFEgBRAQAPAAYIdRTFEgBRAQAAAA==.',['国产']='国产三鹿:BAAALAAECgEIAQAAAA==.',['圆圆']='圆圆只会嗜血:BAAALAAECgYIDQAAAA==.',['土地']='土地:BAAALAADCgYIBgAAAA==.',['圣光']='圣光之泪:BAAALAAECggIDgAAAA==.圣光照耀着我:BAAALAAECgIIAgAAAA==.圣光猫猫头:BAAALAAECgYIBgAAAA==.',['地才']='地才:BAAALAAECgMIBAAAAA==.',['埃辛']='埃辛诺斯之力:BAACLAAFFH8KAAIBAAIIVwdrGAAlAAABAAIIVwdrGAAlAAAsAAQKfxcAAwEABgjlCXobAMAAAAEABgjlCXobAMAAABQAAQgNBfplAR4AAAAA.',['基尔']='基尔加两蛋:BAABLAAFFH8IAAIMAAUIXRU9JgBEAQAMAAUIXRU9JgBEAQAAAA==.',['基普']='基普索恩:BAABLAAFFH8PAAIQAAMIvRygGgC3AAAQAAMIvRygGgC3AAAAAA==.',['堕落']='堕落丘比特:BAAALAAECgYIDAAAAA==.',['報仇']='報仇的牛油果:BAAALAAECgEIAQAAAA==.',['壹只']='壹只耳:BAABLAAFFH8FAAIFAAII5ArvnwA+AAAFAAII5ArvnwA+AAAAAA==.',['夕月']='夕月丶:BAABLAAFFH8iAAIDAAYIvSHMDgDgAQADAAYIvSHMDgDgAQAAAA==.',['夜之']='夜之魔:BAAALAAECgYIDAAAAA==.',['夜来']='夜来美:BAABLAAFFH8JAAITAAQIXQN8NgCYAAATAAQIXQN8NgCYAAAAAA==.',['夢梅']='夢梅悅怡:BAABLAAFFH8JAAIOAAII/w+QHAA4AAAOAAII/w+QHAA4AAAAAA==.',['大圣']='大圣归来丶:BAAALAAECgQIBAAAAA==.',['大孝']='大孝子:BAAALAAECgQIBAAAAA==.',['大沢']='大沢佑香:BAAALAAECgYIBgAAAA==.',['大王']='大王巡山去:BAABLAAFFH8IAAIFAAYIfAAgxAAPAAAFAAYIfAAgxAAPAAAAAA==.',['大鱼']='大鱼海棠丶:BAAALAADCgIIAgAAAA==.',['天之']='天之猎艳:BAAALAAECgEIAQAAAA==.',['天籁']='天籁术:BAAALAAFFAIIAgAAAA==.天籁萨:BAAALAAFFAIIAgAAAA==.',['天黑']='天黑黑:BAABLAAFFH8WAAIDAAUIHxm7OABYAQADAAUIHxm7OABYAQAAAA==.',['失落']='失落的蛋炒饭:BAAALAAECgQIBAAAAA==.',['奈米']='奈米西斯:BAAALAAECgYICwAAAA==.',['奈萨']='奈萨里奥:BAAALAAECgUIBQAAAA==.',['契血']='契血:BAAALAAECgIIAgAAAA==.',['奥本']='奥本海默:BAABLAAFFH8IAAMNAAIIrxZjPgChAAANAAIIrxZjPgChAAAOAAEICQO6IgA2AAABLAAFFAMIDwAQAL0cAA==.',['奶油']='奶油小鬼鬼:BAABLAAFFH8QAAILAAIITxcKPACIAAALAAIITxcKPACIAAAAAA==.',['奶爸']='奶爸:BAABLAAFFH8FAAMVAAMIGg67GgDbAAAVAAMIGg67GgDbAAAWAAEIxgGPMAAnAAAAAA==.',['如意']='如意小瓜瓜:BAAALAAECggICAAAAA==.',['娜塔']='娜塔娅丶:BAAALAAECggICAAAAA==.',['孺子']='孺子牛:BAAALAAECggIDwAAAA==.',['安东']='安东尼达厮:BAAALAADCgUIBQAAAA==.',['安丨']='安丨慕希:BAAALAADCggIDwAAAA==.',['安丰']='安丰灬小沟:BAAALAAECgUIAwAAAA==.',['安丶']='安丶慕希:BAAALAAECggIDAAAAA==.',['安吉']='安吉洛:BAABLAAFFH8IAAIDAAgImBGxDQAkAgADAAgImBGxDQAkAgAAAA==.',['寻宝']='寻宝的神仙:BAAALAAECgcIBwAAAA==.',['射射']='射射:BAABLAAFFH8NAAIFAAYIKBJ+NwBgAQAFAAYIKBJ+NwBgAQAAAA==.',['小众']='小众宝藏蜥蜴:BAAALAAECgUIBQAAAA==.',['小十']='小十一:BAAALAAECgEIAQAAAA==.',['小妞']='小妞妞放火球:BAAALAAECgYIBgAAAA==.',['小弟']='小弟伊利蛋:BAABLAAFFH8JAAIBAAMIpAUbEABKAAABAAMIpAUbEABKAAAAAA==.',['小母']='小母牛回来啦:BAAALAAECgYICQAAAA==.',['小调']='小调皮:BAABLAAFFH8JAAIMAAUIvQkQMgDyAAAMAAUIvQkQMgDyAAAAAA==.',['小飞']='小飞侠鬼鬼:BAAALAAFFAIIBAAAAA==.',['小龙']='小龙人:BAABLAAFFH8GAAIUAAYI1x73GwCVAQAUAAYI1x73GwCVAQAAAA==.小龙包:BAAALAAECggICAAAAA==.',['尖椒']='尖椒酿肉:BAAALAAECgYIBwAAAA==.',['尘灬']='尘灬无欲:BAAALAAECgIIAgAAAA==.尘灬清柠:BAAALAAECgMIAwAAAA==.',['山二']='山二王:BAAALAAECgMIAwAAAA==.',['山楂']='山楂大王:BAAALAAECgQIBAAAAA==.',['岂止']='岂止于快:BAAALAAECgcICAAAAA==.',['左杨']='左杨:BAAALAAECgYICAAAAA==.',['布丁']='布丁:BAABLAAFFH8RAAINAAYIBQYINwAYAQANAAYIBQYINwAYAQAAAA==.',['布吉']='布吉岛小鬼鬼:BAABLAAFFH8OAAIFAAIIcxG5kwBDAAAFAAIIcxG5kwBDAAAAAA==.',['布洛']='布洛芬胶囊:BAAALAADCgEIAQAAAA==.',['希尔']='希尔瓦一娜斯:BAAALAADCgcIBwAAAA==.',['希爾']='希爾瓦納:BAAALAAECgEIAQAAAA==.',['希罗']='希罗:BAAALAAECgYIBgAAAA==.',['希贰']='希贰瓦娜斯:BAAALAADCgMIAgAAAA==.',['帕尔']='帕尔米拉:BAAALAADCgUIBQAAAA==.',['常自']='常自在:BAAALAAECgIIAgAAAA==.',['干个']='干个亼兒:BAAALAAECgUIBQAAAA==.',['年迈']='年迈的饲养员:BAAALAADCgEIAQAAAA==.',['幽冥']='幽冥哈迪斯:BAABLAAFFH8RAAINAAUIVg3xOQD6AAANAAUIVg3xOQD6AAAAAA==.',['库蕾']='库蕾雅:BAABLAAFFH8GAAINAAYIgxwSIQCRAQANAAYIgxwSIQCRAQAAAA==.',['库迪']='库迪蒂娜言:BAAALAADCgYIBgAAAA==.',['开始']='开始即结束:BAAALAAECgYIDAAAAA==.',['开无']='开无敌逃跑:BAAALAAECgQICAAAAA==.',['影忍']='影忍行者:BAAALAAECgYIEgAAAA==.',['很爱']='很爱羽:BAAALAAECggIDQAAAA==.',['很矮']='很矮很胖:BAAALAAFFAIIAgAAAA==.',['德丽']='德丽莎:BAAALAAECggICAAAAA==.',['德之']='德之我幸:BAACLAAFFH8FAAIQAAIIThMWOQBnAAAQAAIIThMWOQBnAAAsAAQKfxcAAhAACAg+FV09AOoBABAACAg+FV09AOoBAAAA.',['德偿']='德偿所望:BAAALAAECgYIBwAAAA==.',['德道']='德道高僧:BAAALAAECgMIAwAAAA==.',['心意']='心意会:BAAALAAFFAIIBAAAAA==.',['必杀']='必杀剑回天:BAAALAAECgYIBgAAAA==.',['必须']='必须德:BAAALAAECgYIBgAAAA==.',['忆瑞']='忆瑞恋:BAAALAAECggICAAAAA==.',['性感']='性感功夫:BAAALAAECgEIAQAAAA==.性感升龙:BAAALAAECgYIDgAAAA==.性感图腾:BAAALAAECgQIBwAAAA==.性感雷霆:BAAALAAECgIIAgAAAA==.',['恶魔']='恶魔记忆:BAAALAAECgEIAQAAAA==.',['惩击']='惩击队友:BAABLAAFFH8FAAIMAAII6A3bZQBDAAAMAAII6A3bZQBDAAAAAA==.',['想你']='想你的夜:BAAALAAECgUIBQAAAA==.',['愛麗']='愛麗絲的旋律:BAAALAAECgIIAgAAAA==.',['感冒']='感冒药片:BAAALAAFFAIIAgAAAA==.',['慕叶']='慕叶乄血小小:BAABLAAFFH8FAAIFAAIIBhXoYwCJAAAFAAIIBhXoYwCJAAAAAA==.',['憨七']='憨七鸠:BAAALAAECgIIAgAAAA==.',['憬柃']='憬柃:BAAALAAECgYIBgAAAA==.',['戌极']='戌极:BAAALAAECgYICAAAAA==.',['我从']='我从城里来:BAAALAAECgYIBgAAAA==.',['我叫']='我叫曾轶可:BAABLAAFFH8KAAMSAAYIQxTEDAAgAQAFAAYILhHBPABRAQASAAQIjxHEDAAgAQAAAA==.',['我是']='我是光:BAAALAAECgMIAwAAAA==.我是小瓶蓋:BAAALAAFFAIIAgAAAA==.',['我来']='我来抓宝宝:BAAALAAECgEIAQAAAA==.',['我欲']='我欲独行:BAAALAADCgMIAwAAAA==.',['我毒']='我毒吧:BAAALAAECgYIBgAAAA==.',['我滴']='我滴乖:BAAALAAECgQIBAAAAA==.',['我爱']='我爱天亦:BAACLAAFFH8KAAIGAAII8QlhIQBOAAAGAAII8QlhIQBOAAAsAAQKfxUAAgYABgjADOElAOQAAAYABgjADOElAOQAAAAA.',['戦斧']='戦斧牛排:BAAALAAECgQIBAAAAA==.',['手拿']='手拿根火柴:BAAALAAECgIIAgAAAA==.',['打不']='打不过就趴下:BAAALAAECgYIBgAAAA==.',['抱歉']='抱歉小伙:BAAALAAECgEIAQAAAA==.',['拉轰']='拉轰的牛虱子:BAABLAAFFH8HAAIJAAMIyg2UIgBnAAAJAAMIyg2UIgBnAAAAAA==.',['拜勒']='拜勒蒙:BAAALAAECgYIBgAAAA==.',['拜金']='拜金者:BAABLAAFFH8SAAILAAII5RfwQwB6AAALAAII5RfwQwB6AAAAAA==.',['挥剑']='挥剑转身:BAAALAADCgEIAQAAAA==.',['挨揍']='挨揍的肥宅熋:BAABLAAECn8dAAIQAAYIhRu9IgC+AQAQAAYIhRu9IgC+AQAAAA==.',['捷克']='捷克弗里特:BAAALAAECgEIAQABLAAFFAIIBAACAAAAAA==.',['掠影']='掠影示现:BAAALAAECgYIBwAAAA==.',['搞五']='搞五搞六:BAAALAAECgYIBgAAAA==.',['摄魂']='摄魂之箭:BAAALAAFFAIIBAAAAA==.',['放学']='放学等我打你:BAAALAAFFAQIBAAAAA==.',['放弃']='放弃圣光:BAABLAAFFH8SAAIMAAUIZiIQGACSAQAMAAUIZiIQGACSAQABLAAFFAYIFwAFABEhAA==.',['敌敌']='敌敌畏:BAAALAADCgQIBAAAAA==.',['敖玉']='敖玉:BAAALAAECgYIDAAAAA==.',['施奶']='施奶德:BAAALAAECgYICQAAAA==.',['无与']='无与伦比的美:BAAALAAECgYICQAAAA==.',['无为']='无为转变:BAAALAAFFAIIBAAAAA==.',['无尽']='无尽之旅:BAAALAAECgYICQAAAA==.无尽之猎:BAAALAAECgIIAgAAAA==.',['无敌']='无敌闪电链:BAAALAADCgYIBgAAAA==.',['无法']='无法登入游戏:BAAALAADCgcIBwAAAA==.',['无涩']='无涩丶清茶:BAAALAAECgYIBwAAAA==.',['无聊']='无聊的走街仔:BAAALAAECgUIBwAAAA==.',['无语']='无语泪奔:BAAALAAECgYIBgAAAA==.',['早安']='早安:BAAALAAECgQIBAAAAA==.',['早酒']='早酒晚舞:BAAALAAECgQIBAAAAA==.',['时扳']='时扳晴人:BAAALAAECgQIBQAAAA==.',['明年']='明年今日:BAAALAAFFAEIAQAAAA==.',['星星']='星星的小坎肩:BAAALAADCgYICQABLAAFFAgITgAEACMjAA==.',['星辰']='星辰永恒:BAAALAADCgIIAgAAAA==.',['春子']='春子无敌:BAAALAADCgUIBQAAAA==.',['春寒']='春寒倒返:BAAALAAFFAIIAgAAAA==.',['是妲']='是妲己呀:BAAALAADCgQIAQAAAA==.',['是棱']='是棱但啦:BAAALAAECggICAAAAA==.',['是雨']='是雨诺吖丶:BAAALAAFFAIIBAAAAA==.是雨诺呀丶:BAAALAAECgUIBQAAAA==.',['晓德']='晓德德:BAAALAAFFAIIAgAAAA==.',['晨风']='晨风韵雨:BAAALAAECgcICwAAAA==.',['暗影']='暗影箭:BAABLAAFFH8JAAIEAAIIVBhQPgCaAAAEAAIIVBhQPgCaAAAAAA==.',['暗月']='暗月旋舞:BAAALAAECgYIDAAAAA==.',['暗法']='暗法熔渣:BAAALAADCgEIAQAAAA==.',['暴走']='暴走的无迪:BAAALAAECgYICwAAAA==.',['暴躁']='暴躁的鬼鬼:BAABLAAFFH8JAAIMAAII+hJzYQBFAAAMAAII+hJzYQBFAAAAAA==.',['暴风']='暴风熔岩:BAAALAADCgQIBAAAAA==.',['月之']='月之守卫:BAAALAADCgUIBQAAAA==.',['朝生']='朝生暮死:BAAALAAECgYIDQAAAA==.',['木心']='木心贼:BAABLAAECn8UAAIXAAcIrQ7+NACPAQAXAAcIrQ7+NACPAQAAAA==.',['木易']='木易巾凡:BAAALAAECgIIAgAAAA==.',['木槿']='木槿半枫荷:BAABLAAFFH8KAAIFAAQIoBRxhQBLAAAFAAQIoBRxhQBLAAAAAA==.',['木瑾']='木瑾年:BAAALAADCgEIAQAAAA==.',['李梦']='李梦月:BAABLAAECn8WAAILAAcI/RG1hgByAQALAAcI/RG1hgByAQAAAA==.',['東靈']='東靈:BAAALAAECggICAAAAA==.',['柯博']='柯博文:BAAALAAFFAMIBAAAAA==.',['桔梗']='桔梗:BAAALAAECggICAAAAA==.',['梦游']='梦游皮皮:BAAALAAECgYIDAAAAA==.',['樱桃']='樱桃牛奶兔:BAAALAAFFAIIAgAAAA==.',['橙子']='橙子汽水:BAAALAAECgYIBgAAAA==.',['橙色']='橙色的橙:BAAALAAFFAIIAgAAAA==.',['橙雲']='橙雲:BAAALAADCgYICAAAAA==.',['橙风']='橙风飞:BAAALAAECgMIBAAAAA==.',['欧菲']='欧菲丽兹:BAABLAAFFH8GAAIMAAIIaQhNewA2AAAMAAIIaQhNewA2AAAAAA==.',['正版']='正版无敌小强:BAABLAAFFH8SAAMQAAYIExEMGQBnAQAQAAYIExEMGQBnAQAPAAUI9BqbEwBIAQAAAA==.',['武僧']='武僧福禄:BAAALAADCggIDgAAAA==.',['武术']='武术运动员:BAACLAAFFH8HAAIKAAMIEgg4GwBeAAAKAAMIEgg4GwBeAAAsAAQKfy4AAwoACAhdEwQTABUBAAoABgj3EAQTABUBABgAAwiTF4EjANsAAAEsAAUUBQgIAAwA0xUA.',['武林']='武林高手常威:BAABLAAFFH8GAAIYAAIIkxttEwBaAAAYAAIIkxttEwBaAAABLAAFFAYIFwAFABEhAA==.',['歪比']='歪比巴卜:BAACLAAFFH8TAAIFAAUIKxyCIAAFAQAFAAUIKxyCIAAFAQAsAAQKf1AAAgUACAheJSgPACoDAAUACAheJSgPACoDAAAA.',['死亡']='死亡横扫:BAABLAAFFH8HAAIUAAMIQBWIPwCQAAAUAAMIQBWIPwCQAAAAAA==.',['死神']='死神硫克:BAAALAADCgIIAgAAAA==.',['死骑']='死骑记忆:BAAALAADCgQIBAAAAA==.',['水煮']='水煮鸡胸肉:BAABLAAFFH8LAAIOAAIIWSILCADHAAAOAAIIWSILCADHAAAAAA==.',['没眉']='没眉毛的小强:BAAALAAECgYIBwAAAA==.',['法灵']='法灵月:BAAALAAECgYICwAAAA==.',['活孬']='活孬只能勥撸:BAAALAAECgQIBAAAAA==.',['浪漫']='浪漫丶饭团:BAACLAAFFH8LAAMOAAIIuSM3EABfAAANAAIIZAjBWACHAAAOAAIIuSM3EABfAAAsAAQKfx4ABA4ABgjxIrkaAEUCAA4ABgjxIrkaAEUCAA0AAQg2EB8AATsAABkAAQggBikmACwAAAAA.',['海棠']='海棠秋已挽:BAABLAAFFH8IAAIDAAYIfhHPNQBkAQADAAYIfhHPNQBkAQAAAA==.',['深夏']='深夏:BAAALAAECggICAAAAA==.',['混乱']='混乱之治暗矛:BAABLAAFFH8KAAIOAAIIOCLOCgCsAAAOAAIIOCLOCgCsAAAAAA==.',['混元']='混元霹雳牛:BAAALAADCgEIAQAAAA==.',['混沌']='混沌鱼子酱:BAAALAADCgMIAwAAAA==.',['清风']='清风送雨恶猎:BAAALAAECgQIBAABLAAFFAIIDAAIABwkAA==.',['游侠']='游侠兒:BAAALAAECgUIBQAAAA==.',['溜溜']='溜溜狐:BAABLAAFFH8VAAINAAYIsiUjIQCRAQANAAYIsiUjIQCRAQAAAA==.',['漆黑']='漆黑之呀:BAAALAAECggICAAAAA==.',['火鸡']='火鸡味鍋巴:BAABLAAFFH8HAAIaAAMIIxN1CQCLAAAaAAMIIxN1CQCLAAAAAA==.',['灵魂']='灵魂圣光:BAAALAAECgEIAQAAAA==.',['烈焰']='烈焰法神:BAABLAAFFH8FAAIOAAMI5gaQEwBJAAAOAAMI5gaQEwBJAAAAAA==.',['烛光']='烛光灵月:BAAALAAECgQIBAAAAA==.',['烟火']='烟火寻常:BAABLAAFFH8MAAIbAAUI4hc7HgBPAQAbAAUI4hc7HgBPAQAAAA==.',['烟燃']='烟燃灬烟灭:BAAALAAECgMIBAAAAA==.',['無尽']='無尽之旅:BAABLAAFFH8GAAIEAAII1AW+TwCBAAAEAAII1AW+TwCBAAAAAA==.',['無敌']='無敌尐辣椒:BAAALAADCggICwAAAA==.',['熊小']='熊小斐:BAAALAADCgMIAwAAAA==.',['熊筱']='熊筱晨丶:BAAALAADCgQIBAAAAA==.',['熊霸']='熊霸天下:BAAALAAFFAIIBAAAAA==.',['爆裂']='爆裂火焰:BAAALAAECgYIDwAAAA==.爆裂黎明:BAAALAAECggIDQAAAA==.',['爱喝']='爱喝樱桃牛奶:BAAALAAECgMIAwAAAA==.',['爱想']='爱想你在哪:BAAALAADCgYIDgAAAA==.',['爱意']='爱意随钟起:BAAALAAECgcIEgAAAA==.',['牛不']='牛不牛:BAAALAAECgYIBgAAAA==.',['牛德']='牛德满满:BAAALAADCgYIBgAAAA==.',['牛牛']='牛牛肥:BAAALAAFFAIIAQAAAA==.',['牛虱']='牛虱:BAAALAAECgMIAwAAAA==.',['牜人']='牜人猎:BAAALAAECgQIBwAAAA==.牜人骑:BAAALAAECgUIBQAAAA==.',['牜头']='牜头人萨满:BAAALAAECgYIBgAAAA==.',['牧之']='牧之所及:BAAALAAECggICAAAAA==.',['狂魂']='狂魂:BAAALAAFFAYIAwAAAA==.',['狐歌']='狐歌:BAAALAAECgIIAgAAAA==.',['狐狸']='狐狸猎手:BAAALAADCgQIBAAAAA==.狐狸霸:BAABLAAFFH8MAAILAAII+QuaWwBjAAALAAII+QuaWwBjAAAAAA==.',['狗仔']='狗仔萨摩耶:BAAALAAECggICAABLAAFFAgICAAFAOEZAA==.',['独夏']='独夏孤影:BAAALAAECgQICQAAAA==.',['猎手']='猎手的春天:BAAALAAECgMIAwAAAA==.',['猎艳']='猎艳部落:BAAALAAECgUIBQAAAA==.',['猛哥']='猛哥:BAAALAAECgQIBAAAAA==.',['猩红']='猩红之泪:BAAALAAECgYICwABLAAFFAYIMAANAFAiAA==.猩红王子:BAAALAAECgYICAAAAA==.',['猫斯']='猫斯拉:BAAALAAECgUIDQAAAA==.',['猫猫']='猫猫头:BAABLAAECn8XAAMIAAgIuCF+CADpAgAIAAgIuCF+CADpAgAMAAgIIxURPgCiAQAAAA==.',['王思']='王思聪:BAAALAAECgEIAQAAAA==.',['王玄']='王玄策:BAAALAAECgQIBAAAAA==.',['琪叶']='琪叶青青:BAAALAADCgcIBwAAAA==.',['璇璇']='璇璇:BAAALAAECgEIAQAAAA==.',['瓦伦']='瓦伦丁:BAAALAAECgQIBAAAAA==.',['瓦王']='瓦王:BAAALAAECgYIBgAAAA==.',['电疗']='电疗师:BAAALAAECgMIAwAAAA==.',['疯狂']='疯狂星期四:BAAALAAECgUIBQAAAA==.',['白云']='白云苍狗:BAAALAAECgIIAgAAAA==.',['白术']='白术芍药:BAABLAAFFH8OAAIMAAYIwBlqHAB7AQAMAAYIwBlqHAB7AQAAAA==.',['白白']='白白净静:BAAALAAECgYIDwAAAA==.',['白驹']='白驹过隙:BAABLAAFFH8NAAITAAUIwRrXIQBeAQATAAUIwRrXIQBeAQABLAAFFAYIFwAFABEhAA==.',['百眼']='百眼丰德:BAAALAAECgYIBgAAAA==.',['盐焗']='盐焗芽儿:BAAALAAECgMIBQAAAA==.',['直插']='直插云霄:BAAALAAECgYIBwAAAA==.',['相扑']='相扑运动员:BAACLAAFFH8GAAIcAAIINgsMDwAoAAAcAAIINgsMDwAoAAAsAAQKfyUAAw8ACAh5GPoSAOMBAA8ACAhZF/oSAOMBABwACAjQDDMRACQBAAEsAAUUBQgIAAwA0xUA.',['真嘟']='真嘟假嘟:BAAALAAECgYIBgAAAA==.',['睿角']='睿角死蹄:BAAALAADCgIIAgAAAA==.',['瞞兲']='瞞兲過海:BAABLAAFFH8IAAIdAAIIaxPiBABKAAAdAAIIaxPiBABKAAAAAA==.',['石桥']='石桥:BAAALAAECgYIBgAAAA==.',['祖国']='祖国人:BAAALAADCgYIBgAAAA==.',['神斗']='神斗士:BAAALAAFFAQIBAAAAA==.',['神牧']='神牧碗面:BAAALAAECgYIDAAAAA==.',['禁止']='禁止喂食摸爪:BAAALAAFFAIIBAAAAA==.',['种西']='种西瓜:BAACLAAFFH8jAAIDAAYIPBqcKwDqAAADAAYIPBqcKwDqAAAsAAQKfyAAAgMABwhQIaJMAGACAAMABwhQIaJMAGACAAAA.',['秦始']='秦始皇:BAAALAAECggICQAAAA==.',['笑天']='笑天哥:BAAALAAECgYIBwAAAA==.',['笔墨']='笔墨绘三生:BAAALAAECgUIBQAAAA==.',['箭鬼']='箭鬼:BAABLAAECn8XAAIFAAYI8BuykgDAAQAFAAYI8BuykgDAAQAAAA==.',['篮色']='篮色的篮:BAACLAAFFH8cAAMLAAYI2RIqGgCLAQALAAYI2RIqGgCLAQAbAAIIKQY+UQAxAAAsAAQKfykAAgsABwjiIvg4ADQCAAsABwjiIvg4ADQCAAAA.',['篵丶']='篵丶蓉:BAABLAAFFH8OAAITAAQI9RVwLQDwAAATAAQI9RVwLQDwAAAAAA==.',['粉色']='粉色的粉:BAAALAAFFAIIAgAAAA==.',['素年']='素年瑾时:BAAALAADCgQIBAAAAA==.',['紫日']='紫日:BAABLAAFFH8OAAIVAAIIKxL4NACIAAAVAAIIKxL4NACIAAAAAA==.',['红尘']='红尘绝链:BAAALAADCgEIAQAAAA==.',['纯净']='纯净:BAAALAAECgUIBQAAAA==.',['纯牛']='纯牛马丶:BAAALAAECgYICAAAAA==.',['纹舞']='纹舞兰:BAAALAAECgMIAwAAAA==.',['织雾']='织雾踏风酒仙:BAAALAAECgQIBAAAAA==.',['绒毛']='绒毛裂掌:BAAALAADCgEIAQAAAA==.',['绞袭']='绞袭队友:BAAALAAFFAIIAgAAAA==.',['罗慕']='罗慕洛斯:BAAALAAECgQIDwAAAA==.',['美息']='美息伪麻片:BAAALAADCgIIAgAAAA==.',['群星']='群星闪耀:BAAALAAECgMIAwAAAA==.',['翼柳']='翼柳浮洋:BAABLAAFFH8IAAIEAAgIkACgZQA6AAAEAAgIkACgZQA6AAAAAA==.',['老杨']='老杨:BAAALAAECgUICAAAAA==.',['老鎮']='老鎮玫瑰:BAAALAAECgIIAgAAAA==.',['职业']='职业坑队友:BAAALAAECgUICQAAAA==.',['肉团']='肉团团的妈妈:BAAALAAECgIIAgAAAA==.',['肖申']='肖申克的九叔:BAAALAAECgYICAAAAA==.',['肾毒']='肾毒素:BAAALAAECgUICQAAAA==.',['胖胖']='胖胖咕:BAAALAAECgYIDAAAAA==.',['胡媚']='胡媚娘:BAAALAAECgYIBgAAAA==.',['胭脂']='胭脂喵喵:BAAALAAECggICAAAAA==.',['般般']='般般小牛:BAABLAAFFH8VAAIEAAQIAxCVQwDOAAAEAAQIAxCVQwDOAAAAAA==.',['船长']='船长:BAAALAAECgYIBwAAAA==.',['艾利']='艾利安:BAAALAAECgcIBwAAAA==.',['芝士']='芝士柠檬:BAAALAAECgYICgAAAA==.',['芝芝']='芝芝舒芙蕾:BAAALAADCggICAAAAA==.',['芯骋']='芯骋:BAAALAAECgIIAgAAAA==.',['花满']='花满楼:BAAALAAECgUICQAAAA==.',['花漾']='花漾甜心:BAAALAADCgMIAwAAAA==.',['苍井']='苍井玛利亚:BAAALAAECgYICQAAAA==.',['若有']='若有所撕:BAAALAADCgUIBQAAAA==.',['英熊']='英熊饶命啊:BAACLAAFFH8GAAIMAAIIlxr2YwBEAAAMAAIIlxr2YwBEAAAsAAQKfyMAAwwACAiJI98dAPsCAAwACAiJI98dAPsCAAgACAgpDm8zAJwBAAAA.',['英雄']='英雄饶命呀:BAAALAAECggIEAABLAAFFAIIBgAMAJcaAA==.',['茶狐']='茶狐:BAAALAAECgIIAgAAAA==.',['荼蔓']='荼蔓:BAAALAAECgYICgAAAA==.',['菠萝']='菠萝啤:BAAALAAECgQICAAAAA==.',['萌新']='萌新牛牛:BAAALAAECgYIDwAAAA==.',['萌萌']='萌萌嘚:BAAALAADCgEIAQAAAA==.',['萨拉']='萨拉塔司:BAAALAAFFAIIAgAAAA==.萨拉曼卡:BAABLAAFFH8OAAIUAAIIsB43NwCgAAAUAAIIsB43NwCgAAABLAAFFAMIDwAQAL0cAA==.萨拉曼嗒:BAAALAAECgUIBQAAAA==.',['萨灼']='萨灼嗜引:BAABLAAECn8XAAIbAAcIOw4sPAAcAQAbAAcIOw4sPAAcAQAAAA==.',['萨特']='萨特辉煌:BAAALAADCgYIBgAAAA==.',['蒙牛']='蒙牛优酪乳:BAAALAAFFAYIBAAAAA==.',['蒟蒻']='蒟蒻:BAAALAAECgYIDAAAAA==.',['蓝桉']='蓝桉丷:BAAALAAFFAIIAgABLAAFFAgITgAEACMjAA==.',['蓝色']='蓝色姜子牙:BAABLAAECn8UAAMOAAYIYw0fJwDsAAAOAAYIYw0fJwDsAAANAAMI0wQJZQBrAAAAAA==.',['藏啾']='藏啾啾:BAAALAAECgEIAQAAAA==.',['虎皮']='虎皮豆:BAAALAADCggICAAAAA==.',['虔诚']='虔诚拜三拜:BAACLAAFFH8JAAMeAAIIKxUrDQBHAAAPAAII5w50JAB/AAAeAAIIKxUrDQBHAAAsAAQKfxwAAw8ACAjxG5EZAJUCAA8ACAjxG5EZAJUCAB4AAQg4FdAkAEEAAAAA.',['虚空']='虚空大灰狼:BAAALAAECgUIBQAAAA==.',['蛮劲']='蛮劲发作:BAAALAAECgYIDQAAAA==.',['蛮荒']='蛮荒崩裂:BAAALAAECgQIBwAAAA==.',['蝙蝠']='蝙蝠侠客:BAAALAAECgYIBgAAAA==.蝙蝠死侍:BAAALAADCggICAAAAA==.',['血凝']='血凝牙:BAAALAAFFAIIAgAAAA==.',['血色']='血色玛丽:BAAALAADCgEIAQAAAA==.',['行走']='行走的鱼:BAABLAAECn8UAAIMAAYInSQkIgARAgAMAAYInSQkIgARAgAAAA==.',['術月']='術月靈:BAAALAAECgYIBwAAAA==.',['补天']='补天士:BAAALAAECgYIBgAAAA==.',['被逼']='被逼的:BAAALAADCgcIBwAAAA==.',['西瓜']='西瓜雪梨:BAAALAAECgYIBgAAAA==.',['諸神']='諸神無名:BAAALAAFFAMIAwAAAA==.',['诗笔']='诗笔尽还:BAAALAAECgIIAgAAAA==.',['诚实']='诚实的豆沙包:BAAALAAECgQIBAAAAA==.',['诸葛']='诸葛刚子:BAAALAAECgYIDAAAAA==.诸葛钢铁:BAAALAAECgcICgAAAA==.',['贫僧']='贫僧法号戒色:BAAALAADCgQIBAAAAA==.',['贰灬']='贰灬减:BAAALAAFFAIIAgAAAA==.',['起舞']='起舞弄清影:BAAALAADCgEIAQAAAA==.',['跑马']='跑马运动员:BAACLAAFFH8IAAMMAAUI0xXoLwAGAQAMAAQI9hjoLwAGAQAGAAIIPAmsHwAsAAAsAAQKfykAAwYABwgYGWYbADUBAAYABwhDFGYbADUBAAwABAhEHqB9AAUBAAAA.',['路边']='路边一条我:BAAALAAECggIDgAAAA==.',['路过']='路过一只蹄蹄:BAAALAAECggIEwAAAA==.',['跳远']='跳远运动员:BAACLAAFFH8GAAIBAAIICBWWEwAzAAABAAIICBWWEwAzAAAsAAQKfygAAxQACAhVHY0hAN0BABQABwi+G40hAN0BAAEACAgzFugMAIEBAAEsAAUUBQgIAAwA0xUA.',['轉身']='轉身時的溫柔:BAAALAAFFAIIAgAAAA==.',['达库']='达库拉:BAAALAAECgUIBwAAAA==.',['迎接']='迎接圣光:BAAALAAECgQIBwAAAA==.',['远兮']='远兮哲别:BAAALAAECgYIEQAAAA==.',['迷梦']='迷梦时光:BAAALAAFFAIIAgAAAA==.',['追星']='追星逐月:BAAALAAECgUIBQAAAA==.',['逆天']='逆天小子:BAABLAAFFH8JAAIGAAII0w/BHAAxAAAGAAII0w/BHAAxAAAAAA==.',['通通']='通通:BAABLAAFFH8IAAIDAAgIHxy0BwB+AgADAAgIHxy0BwB+AgAAAA==.',['遗落']='遗落的小狐狸:BAAALAAECgYIBgAAAA==.遗落的小龙虾:BAAALAAECgYIDAAAAA==.',['邦比']='邦比爱塔:BAABLAAFFH8LAAMIAAMIYxXNHQC1AAAIAAMIYxXNHQC1AAAMAAII9xVsQACeAAABLAAFFAMIDwAQAL0cAA==.',['邪能']='邪能熔渣:BAAALAADCgQIBAAAAA==.',['鄙人']='鄙人丶李莲英:BAAALAAECgcIBwAAAA==.',['释放']='释放的释:BAAALAAFFAIIAgAAAA==.',['钟是']='钟是学不费:BAAALAAECgYIDAAAAA==.',['钢铁']='钢铁风筝:BAABLAAFFH8MAAMRAAIIsA06BgCJAAARAAIIxQg6BgCJAAAFAAIIsA3IdAB6AAAAAA==.',['铁甲']='铁甲战车:BAAALAADCgYIBgAAAA==.',['長岛']='長岛冰茶:BAAALAAECggICAAAAA==.',['長島']='長島冰茶:BAAALAAECggICAAAAA==.',['長泽']='長泽雅美:BAACLAAFFH8MAAMUAAIIcxjZTABMAAAUAAIIyxbZTABMAAABAAIIRBYsEwA2AAAsAAQKfxkAAxQABgiuIREeAPIBABQABgiuIREeAPIBAAEABggTFhgRADsBAAAA.',['长歪']='长歪的养乐多:BAAALAADCgQIBAAAAA==.',['闪开']='闪开我来丶:BAAALAAECgIIAgAAAA==.',['闪电']='闪电侠:BAAALAAECgYIBgAAAA==.',['闹闹']='闹闹:BAAALAAECgIIAgAAAA==.',['阿伊']='阿伊努卡:BAAALAADCgYIBgAAAA==.',['阿夜']='阿夜耶不耶:BAAALAAECgYIBgAAAA==.',['阿尓']='阿尓萨斯:BAAALAAECgUIBQAAAA==.',['阿尔']='阿尔蒂拉:BAAALAAECgQIBAAAAA==.',['阿态']='阿态:BAAALAAECgYIBgAAAA==.',['阿拉']='阿拉伯土著萨:BAAALAAECgQIBAAAAA==.',['阿纳']='阿纳斯塔西娅:BAAALAAECgMIAwAAAA==.',['阿肯']='阿肯:BAAALAADCgIIAgAAAA==.阿肯不睡觉:BAACLAAFFH8xAAIXAAcIih1XAwAmAgAXAAcIih1XAwAmAgAsAAQKf1wAAxcACAgoJhcBAHkDABcACAgoJhcBAHkDAB8AAgjYFm9CAIgAAAAA.',['阿谢']='阿谢姆:BAAALAAECgYIBgAAAA==.',['阿鲁']='阿鲁巴托:BAABLAAFFH8GAAIFAAYIVwtzRAA3AQAFAAYIVwtzRAA3AQAAAA==.',['陈十']='陈十四:BAACLAAFFH8OAAIJAAII/gunKQBqAAAJAAII/gunKQBqAAAsAAQKfxcAAgkACAg4EC5BAH4BAAkACAg4EC5BAH4BAAAA.',['陵山']='陵山素问:BAAALAADCgYIBgAAAA==.',['隔壁']='隔壁山大王:BAAALAAECgUIBQAAAA==.',['雨诺']='雨诺丶:BAABLAAFFH8QAAIFAAYI6CWTEQD+AQAFAAYI6CWTEQD+AQAAAA==.雨诺吖:BAAALAAFFAIIBAAAAA==.雨诺吖丶:BAAALAAFFAIIAgAAAA==.雨诺啊丶:BAABLAAFFH8IAAIVAAIIfiNSKwDLAAAVAAIIfiNSKwDLAAAAAA==.',['雪子']='雪子的奶白:BAABLAAFFH8GAAIDAAYI1gR8UwDEAAADAAYI1gR8UwDEAAAAAA==.',['雪見']='雪見紗弥:BAAALAAECgYIBgAAAA==.',['霓叭']='霓叭叭:BAAALAAECgYIBgAAAA==.',['露茜']='露茜范佩尔特:BAABLAAFFH8IAAILAAII3hpIQwCcAAALAAII3hpIQwCcAAAAAA==.',['霸道']='霸道龙行天下:BAAALAADCgQIBAAAAA==.',['霸霸']='霸霸宋:BAAALAAECgIIAgAAAA==.',['青井']='青井草莓:BAAALAAECgMIAwAAAA==.',['非酋']='非酋小白脸:BAAALAAECgMIAwAAAA==.',['风中']='风中飘絮:BAAALAAECgYIBwAAAA==.',['风御']='风御殇:BAAALAAECggIAgAAAA==.',['飞的']='飞的龙:BAAALAAECgUIBQAAAA==.',['飞越']='飞越疯牛院:BAAALAAECgYIDAAAAA==.',['首长']='首长:BAAALAAECgMIAwAAAA==.',['香香']='香香配臭臭:BAAALAAECgMIAwAAAA==.',['驴驴']='驴驴:BAAALAADCggICAAAAA==.',['骑幻']='骑幻:BAAALAAECgcIBwAAAA==.',['骑进']='骑进村:BAAALAAFFAEIAgAAAA==.',['鬼泣']='鬼泣萧萧:BAABLAAFFH8VAAIUAAUIFAgqMwDwAAAUAAUIFAgqMwDwAAAAAA==.',['鬼舞']='鬼舞教父:BAAALAADCgUIBQAAAA==.鬼舞辻無慘:BAABLAAECn8YAAIDAAYIWBbMuACiAQADAAYIWBbMuACiAQAAAA==.',['鬼魅']='鬼魅火术:BAAALAADCgYIBgAAAA==.',['魏爱']='魏爱裙:BAAALAAECgEIAQAAAA==.',['魔兽']='魔兽钢炮:BAAALAAFFAIIBAAAAA==.',['鱼尤']='鱼尤鱼鱼:BAAALAAECgYICQAAAA==.',['鱼干']='鱼干爱次糖:BAABLAAECn8bAAIFAAgIrhvqUgA4AgAFAAgIrhvqUgA4AgAAAA==.',['鲁迪']='鲁迪萨:BAAALAAECgYIEwAAAA==.',['鹿邑']='鹿邑:BAAALAAECggICAAAAA==.',['麦克']='麦克斯韦:BAABLAAFFH8IAAILAAIIDx5LKwCtAAALAAIIDx5LKwCtAAABLAAFFAMIDwAQAL0cAA==.',['麦麦']='麦麦汐:BAAALAAECgEIAQAAAA==.',['麻痹']='麻痹啊是人:BAAALAAECgYIBgAAAA==.',['黎明']='黎明之锤:BAAALAAFFAQIBAAAAA==.',['黑心']='黑心拉皮者:BAAALAADCgQIBAAAAA==.',['黑暗']='黑暗中人:BAAALAAECgQIBAAAAA==.黑暗罗格:BAAALAAFFAIIBAAAAA==.',['黑爻']='黑爻鲥:BAAALAAECgQIBQAAAA==.',['黑白']='黑白配配:BAAALAADCgcIBwAAAA==.',['黑脚']='黑脚杆:BAAALAAECgIIAgAAAA==.',['黑葡']='黑葡萄:BAAALAAECgUIBwAAAA==.',['龙姨']='龙姨:BAAALAAECgUIBQAAAA==.',['龙行']='龙行龘龘:BAAALAADCgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end