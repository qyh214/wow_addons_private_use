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
 local lookup = {'Mage-Arcane','Evoker-Devastation','Warrior-Protection','Warrior-Fury','Evoker-Preservation','DemonHunter-Havoc','DeathKnight-Frost','DeathKnight-Unholy','Warlock-Destruction','Hunter-BeastMastery','Hunter-Survival','Druid-Restoration','Monk-Windwalker','Monk-Brewmaster','Paladin-Retribution','Warrior-Arms','Paladin-Holy','Mage-Frost','Evoker-Augmentation','Hunter-Marksmanship','Shaman-Restoration','Shaman-Elemental','Priest-Holy','Druid-Balance','DeathKnight-Blood','Warlock-Demonology','Druid-Guardian','Druid-Feral','Priest-Shadow','Priest-Discipline','Warlock-Affliction','Paladin-Protection','Mage-Fire','Unknown-Unknown','DemonHunter-Vengeance',}; local provider = {region='CN',realm='冬泉谷',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ae='Aeeac:BAAALAAECgYIBwAAAA==.',Ai='Ailier:BAAALAAECgQIBAAAAA==.',Ak='Akili:BAAALAAECgYIDwAAAA==.',An='Angiefaith:BAAALAAECggIEwAAAA==.Aniu:BAAALAADCgIIAgAAAA==.Aniun:BAAALAADCgMIAwAAAA==.Aniuniu:BAAALAADCgYIBgAAAA==.',Ap='Apell:BAAALAADCggICAAAAA==.',Bl='Blessingyou:BAAALAADCgEIAQAAAA==.',Br='Britneyspear:BAAALAADCgYIBgAAAA==.',Ca='Cat:BAAALAAECggICQAAAA==.',Ch='Chanceses:BAAALAADCgMIAwAAAA==.Cherrin:BAAALAAECgYIBgAAAA==.',Da='Datou:BAAALAAECgYIBgAAAA==.',De='Demandcat:BAAALAAECgcICQAAAA==.',Di='Di:BAAALAAFFAEIAQAAAA==.',Eb='Ebod:BAAALAAECgUIBQAAAA==.Ebody:BAAALAAECggIDQAAAA==.Ebone:BAAALAAECggICQAAAA==.Ebtwo:BAAALAAECggICAAAAA==.',El='Eleven:BAAALAAECgYICQAAAA==.',Ft='Ftwoa:BAAALAAFFAIIAgAAAA==.',Ha='Ha:BAAALAAECgYIBwAAAA==.',Jo='Johnnydeppxd:BAAALAADCgYIBgAAAA==.',Ka='Kaixin:BAAALAAECgEIAQAAAA==.',Ki='Kiwi:BAAALAAECgEIAQAAAA==.',Ko='Koala:BAAALAAECgMIAwAAAA==.',Kp='Kpoprumi:BAAALAADCgMIAwAAAA==.',Le='Levin:BAABLAAFFH8IAAIBAAgI2yMFAwDHAgABAAgI2yMFAwDHAgAAAA==.',Lo='Longlongago:BAABLAAFFH8NAAICAAII/BnpFwCTAAACAAII/BnpFwCTAAAAAA==.',Lu='Luckycows:BAACLAAFFH8KAAIDAAIIWgznLAA3AAADAAIIWgznLAA3AAAsAAQKfxoAAwQACAj0E8JXAA4BAAMABggrEIhYACEBAAQACAjZEsJXAA4BAAAA.',Ma='Magician:BAAALAAECgUIBQAAAA==.',Me='Meta:BAAALAAECgYIDwAAAA==.Metass:BAAALAADCgIIAgAAAA==.',Mo='Mortis:BAABLAAFFH8rAAIFAAcIrBHeCADTAQAFAAcIrBHeCADTAQAAAA==.',Ny='Nyc:BAAALAAECgYIBgAAAA==.',Os='Osaragi:BAAALAADCgYIBgAAAA==.',Pe='Perfect:BAABLAAFFH8GAAIGAAUINQmIMAARAQAGAAUINQmIMAARAQAAAA==.',Pl='Playerceksgk:BAAALAAECgMIBAAAAA==.Playerhotydn:BAACLAAFFH8VAAMHAAUIAgtmSwADAQAHAAUIAgtmSwADAQAIAAIIhAdKFQCCAAAsAAQKfxwAAwcACAg5E7UzAKkBAAcACAhiErUzAKkBAAgABgjiDmAtAFkBAAAA.Playerpteftp:BAABLAAFFH8PAAIJAAMIAgtmUgBsAAAJAAMIAgtmUgBsAAAAAA==.Playerwqhvlt:BAACLAAFFH8lAAIKAAUIARspQgBAAQAKAAUIARspQgBAAQAsAAQKfyoAAwoACAiYHvw8AG8CAAoACAgAHfw8AG8CAAsABwgpGEIKAAkCAAAA.Playerzqczuo:BAAALAADCgYIBgAAAA==.',Qd='Qdfair:BAAALAAFFAQIAwAAAA==.',Va='Varusy:BAAALAAECgIIAgAAAA==.',Vm='Vmware:BAABLAAFFH8KAAIMAAIIiBSHPwB0AAAMAAIIiBSHPwB0AAAAAA==.',Yr='Yreteu:BAAALAAECgIIAgAAAA==.',Zy='Zynn:BAAALAAECgYIBgAAAA==.',['一个']='一个人失忆:BAAALAAFFAEIAQAAAA==.',['一及']='一及格线一:BAABLAAFFH8GAAMNAAUIgQfADQDcAAANAAQIqQXADQDcAAAOAAIIZw0gFwByAAAAAA==.',['一念']='一念晴朗:BAAALAAECgYIDQAAAA==.',['一朵']='一朵懒女子:BAAALAADCgEIAQAAAA==.',['一盏']='一盏青灯:BAAALAAECgUIBwAAAA==.',['一马']='一马当先:BAAALAAECgEIAQAAAA==.',['七喜']='七喜小宝:BAABLAAFFH8GAAIPAAYIKgCAhwAHAAAPAAYIKgCAhwAHAAAAAA==.七喜小宝宝:BAAALAAECgYICgAAAA==.',['七宗']='七宗罪丶傲慢:BAAALAAECgEIAQAAAA==.',['七彩']='七彩街老司机:BAAALAAECgYIBwAAAA==.',['三笠']='三笠阿克曼:BAAALAAECgUIBQAAAA==.',['不了']='不了不了:BAABLAAFFH8PAAIQAAIIlxXABABMAAAQAAIIlxXABABMAAAAAA==.',['不会']='不会施法:BAABLAAFFH8JAAIBAAYIkgTHVwBDAAABAAYIkgTHVwBDAAAAAA==.',['不是']='不是算了我的:BAAALAAECggIEAAAAA==.',['不灭']='不灭苍穹:BAABLAAECn8cAAMPAAcIcAZ6/gAtAQAPAAcIcAZ6/gAtAQARAAYIbwulJwAFAQAAAA==.',['不用']='不用驱我能解:BAABLAAFFH8KAAMBAAII8hlpQQCeAAABAAII8hlpQQCeAAASAAEIxQMNIwAzAAAAAA==.',['不道']='不道归期:BAABLAAFFH8GAAIDAAYImwFrIAB2AAADAAYImwFrIAB2AAAAAA==.',['丶猫']='丶猫笑笑:BAABLAAFFH8IAAIHAAgIKSJGAwDSAgAHAAgIKSJGAwDSAgAAAA==.',['也来']='也来一次:BAAALAAECgYIBgAAAA==.',['二哥']='二哥:BAABLAAFFH8IAAIPAAIIEwbrYQBxAAAPAAIIEwbrYQBxAAAAAA==.',['二爷']='二爷:BAABLAAFFH8GAAIHAAIIhAOnlABrAAAHAAIIhAOnlABrAAAAAA==.',['二见']='二见原锂离子:BAAALAAFFAQIBAABLAAFFAYIHAATAI0dAA==.',['云一']='云一号:BAABLAAFFH8GAAIBAAYIfBe7CwAMAgABAAYIfBe7CwAMAgAAAA==.',['云三']='云三号:BAABLAAFFH8GAAIBAAYITQqsLwBJAQABAAYITQqsLwBJAQAAAA==.',['云然']='云然:BAAALAAFFAIIAgAAAA==.',['云芗']='云芗:BAAALAAECggICAAAAA==.',['亓小']='亓小夜:BAAALAAECgcICwAAAA==.亓小烨:BAAALAAECgYIBgAAAA==.',['五筒']='五筒:BAAALAAFFAIIAgAAAA==.',['亖及']='亖及格线亖:BAAALAADCgEIAQABLAAFFAUIBgANAIEHAA==.',['京城']='京城奶爸:BAAALAAECgMIBgAAAA==.',['人称']='人称花哥:BAAALAAECgEIAQAAAA==.',['今夜']='今夜賊寂寞:BAAALAAECgYIEgAAAA==.',['今田']='今田美樱:BAAALAADCgEIAQAAAA==.',['从我']='从我家里出去:BAAALAAFFAIIBAAAAA==.',['仙子']='仙子狗尾巴花:BAAALAADCgEIAQAAAA==.',['会仰']='会仰泳的蝌蚪:BAABLAAFFH8FAAIDAAIIQRNsJQBSAAADAAIIQRNsJQBSAAAAAA==.',['传说']='传说中的小猎:BAACLAAFFH8VAAMKAAUIoyCMNQBmAQAKAAUIoyCMNQBmAQAUAAIIiRnxHgCNAAAsAAQKfywAAxQACAgAIcMRANUCABQACAiBH8MRANUCAAoABgjAIQUyAPYBAAAA.',['但丁']='但丁:BAAALAAECgIIAgAAAA==.',['你以']='你以为我是谁:BAABLAAECn8YAAMQAAgISR8wBQDAAgAQAAgI0h0wBQDAAgAEAAgIfhzNLgB+AgAAAA==.',['你的']='你的十七娘:BAABLAAECn8aAAIHAAYI+A0GhADiAAAHAAYI+A0GhADiAAAAAA==.',['你鱼']='你鱼总:BAABLAAFFH8GAAIVAAMIfwMaXgBfAAAVAAMIfwMaXgBfAAAAAA==.',['便便']='便便上有牙印:BAAALAADCgIIAgAAAA==.',['信感']='信感小翘囤:BAAALAAECgQIBAAAAA==.',['傲娇']='傲娇双马尾:BAABLAAFFH8HAAIBAAMImBZKJgD7AAABAAMImBZKJgD7AAAAAA==.',['傲慢']='傲慢与偏见丶:BAACLAAFFH8IAAIRAAIIVAzwJwBsAAARAAIIVAzwJwBsAAAsAAQKfxUAAw8ABgiJGpWJANsBAA8ABgiJGpWJANsBABEABggHFiE6AHsBAAAA.',['傻馒']='傻馒的河狸:BAACLAAFFH8KAAMVAAII4CX7GwDaAAAVAAII4CX7GwDaAAAWAAEI2gbLPgBBAAAsAAQKfyMAAxUABgjMIcA2ADsCABUABgjMIcA2ADsCABYABggqHFpOANABAAEsAAUUAggMABcAChsA.',['元旦']='元旦:BAABLAAFFH8IAAIOAAgIYxuuAgBuAgAOAAgIYxuuAgBuAgAAAA==.',['光头']='光头小萨:BAAALAAECgQIBAAAAA==.',['八亿']='八亿少奶的梦:BAAALAADCgMIAwAAAA==.',['冯丶']='冯丶殷麦曼:BAAALAAECgYICAAAAA==.',['冰风']='冰风骑士:BAAALAAECgcIEwAAAA==.',['凄绝']='凄绝的戏:BAAALAAECggICAAAAA==.',['凯尔']='凯尔莫汉的雪:BAAALAAECgMIAwAAAA==.',['划水']='划水嗑瓜子:BAAALAADCgIIAgAAAA==.',['勇敢']='勇敢的卡布:BAAALAAECgQIBAAAAA==.',['午餐']='午餐肉罐头:BAABLAAFFH8GAAIXAAIIHgbGPQB6AAAXAAIIHgbGPQB6AAAAAA==.',['半月']='半月小月半:BAAALAAFFAIIAgAAAA==.',['南山']='南山竹海:BAAALAAECgMIAwAAAA==.',['卡妙']='卡妙:BAABLAAFFH8GAAIPAAIINhHTQQCdAAAPAAIINhHTQQCdAAAAAA==.',['厚甲']='厚甲载物:BAABLAAFFH8HAAIIAAIIdB2sDgBbAAAIAAIIdB2sDgBbAAAAAA==.',['双子']='双子星嚤羯:BAABLAAECn8VAAIPAAgIGBEljQDVAQAPAAgIGBEljQDVAQABLAAFFAYIGQAEAIEcAA==.',['反派']='反派迷人小狗:BAAALAAECgYIBgAAAA==.',['叫吾']='叫吾猎爹:BAAALAADCgEIAQAAAA==.',['叫皖']='叫皖大姨妈:BAAALAAECgYIDwAAAA==.',['右手']='右手哥哥:BAAALAAECgMIAwAAAA==.',['叹气']='叹气子:BAAALAADCggIDwAAAA==.',['吃我']='吃我一矛:BAACLAAFFH8WAAIRAAUIISFkBQDhAQARAAUIISFkBQDhAQAsAAQKfyIAAhEACAhhI9MEABgDABEACAhhI9MEABgDAAAA.',['吃货']='吃货小豆泥:BAAALAAECgcICgABLAAFFAYIGQAEAIEcAA==.',['向日']='向日葵:BAAALAAECgMIBAAAAA==.',['君莫']='君莫邪:BAABLAAFFH8MAAIRAAYI2xCTEAB9AQARAAYI2xCTEAB9AQAAAA==.',['咸蛋']='咸蛋黄超人:BAAALAAECgYIBgAAAA==.',['咸鸭']='咸鸭蛋超人:BAABLAAFFH8GAAIGAAYIsQx4KABPAQAGAAYIsQx4KABPAQAAAA==.',['哦喵']='哦喵了个咪:BAAALAAECgcIBwAAAA==.',['喜欢']='喜欢喝牛奶:BAAALAADCggICAAAAA==.',['喜爱']='喜爱芋头:BAAALAAECgYIBgAAAA==.',['喵星']='喵星人之咏叹:BAAALAAECgMIAwAAAA==.',['嗜血']='嗜血熔岩暴徒:BAABLAAFFH8GAAIVAAIIHA/3XwBcAAAVAAIIHA/3XwBcAAAAAA==.',['嘿嘿']='嘿嘿:BAABLAAFFH8HAAISAAIIfRivEwBIAAASAAIIfRivEwBIAAAAAA==.',['图腾']='图腾代言人:BAAALAADCgEIAQAAAA==.',['圣光']='圣光之下:BAAALAAECgYIBwAAAA==.',['在逃']='在逃薯薯饼:BAAALAAECgYICAAAAA==.',['地精']='地精刺客:BAAALAAECggICAAAAA==.',['坏脾']='坏脾气俏:BAAALAAECgEIAQAAAA==.',['坠落']='坠落凤舞:BAAALAAECgYIDQAAAA==.',['坤少']='坤少:BAABLAAFFH8IAAIPAAIIgQpocQA9AAAPAAIIgQpocQA9AAAAAA==.',['堕落']='堕落妖姬:BAAALAADCgYIBgAAAA==.',['墓无']='墓无亡法:BAAALAAECgYIBgAAAA==.',['增强']='增强增强萨:BAAALAAECgQIBAAAAA==.',['夏树']='夏树之恋:BAAALAADCgEIAQAAAA==.',['夜鹿']='夜鹿:BAAALAAECgYICwAAAA==.',['够了']='够了哦:BAAALAAECgYIDgAAAA==.',['大年']='大年丶:BAAALAAECgEIAQAAAA==.',['大触']='大触:BAAALAAECgIIAgAAAA==.',['大鸡']='大鸡牛:BAABLAAFFH8FAAMYAAUINwQ4JwB6AAAYAAQIcgQ4JwB6AAAMAAEItBR2WABAAAAAAA==.',['天下']='天下黄汤:BAACLAAFFH8UAAIZAAYIWxiqCQB9AQAZAAYIWxiqCQB9AQAsAAQKfxoAAhkABgggIfUKANcBABkABgggIfUKANcBAAAA.',['天涯']='天涯小术:BAAALAADCgEIAQAAAA==.',['天灾']='天灾忠犬:BAAALAAECgYIBgAAAA==.',['天煞']='天煞灬孤星:BAAALAAECgYIEQAAAA==.',['天黑']='天黑好干那事:BAAALAAFFAIIBAAAAA==.',['奈亚']='奈亚拉托提普:BAAALAAECgYIBgAAAA==.',['奶油']='奶油小饼干:BAABLAAFFH8IAAMQAAIIjxCVBQCJAAAEAAIIjxBsNQCZAAAQAAIIkAuVBQCJAAAAAA==.',['好哥']='好哥们韦伯:BAAALAAECgQIBAAAAA==.',['好好']='好好弟弟:BAAALAAECgYIBwAAAA==.好好打一次过:BAAALAAECgYICQAAAA==.',['好色']='好色北北:BAAALAAECgQIBAAAAA==.好色嘻嘻:BAAALAAECgIIAgAAAA==.',['好萌']='好萌的狐萨满:BAABLAAFFH8GAAIVAAII1QZkbABOAAAVAAII1QZkbABOAAAAAA==.',['如花']='如花壹:BAAALAAECgIIAgAAAA==.如花拾:BAAALAAECgMIBAAAAA==.如花玖:BAAALAAECgIIAgAAAA==.如花贰:BAAALAAECgEIAgAAAA==.',['妺喜']='妺喜:BAAALAAECgYIDwAAAA==.',['季伯']='季伯初:BAABLAAECn8bAAIBAAgIASbTDgAmAwABAAgIASbTDgAmAwAAAA==.',['安哥']='安哥拉曼纽:BAAALAADCgQIBAAAAA==.',['射爆']='射爆你的鸡:BAAALAAFFAIIAgAAAA==.',['小七']='小七喜:BAAALAAECgYIBgAAAA==.',['小司']='小司机:BAABLAAFFH8OAAIaAAMIGwg1CgB6AAAaAAMIGwg1CgB6AAAAAA==.',['小小']='小小灬圣骑:BAAALAADCgUIBQAAAA==.',['小棉']='小棉裤:BAABLAAFFH8fAAIKAAYIbh0GJQCeAQAKAAYIbh0GJQCeAQAAAA==.',['小泽']='小泽:BAAALAAECgEIAQAAAA==.',['小熊']='小熊餠干:BAAALAAECgUIBQAAAA==.',['小牛']='小牛贝希:BAABLAAFFH8GAAIVAAYInx/4AgAuAgAVAAYInx/4AgAuAgAAAA==.',['小白']='小白他叔:BAAALAAECgUIBQAAAA==.',['小罗']='小罗就吃肉:BAAALAAECgIIAgAAAA==.',['小耳']='小耳朵咕噜:BAABLAAFFH8KAAIVAAUIlxHDKQAXAQAVAAUIlxHDKQAXAQAAAA==.',['小胖']='小胖胖龙:BAAALAADCgEIAQAAAA==.',['小黄']='小黄天天开心:BAAALAAECgMIAwAAAA==.',['尐色']='尐色:BAABLAAFFH8IAAIPAAIIwxHFWQCHAAAPAAIIwxHFWQCHAAAAAA==.',['尕尕']='尕尕:BAAALAAECgIIAwAAAA==.',['尼采']='尼采:BAACLAAFFH8XAAMPAAYImgTCLgAQAQAPAAYImgTCLgAQAQARAAUIkgrlFwAPAQAsAAQKfx4AAhEACAhQFDQQAPEBABEACAhQFDQQAPEBAAAA.',['屠魔']='屠魔之力:BAAALAAFFAIIBAAAAA==.',['山鸡']='山鸡哥:BAACLAAFFH8JAAIHAAII9xs9gABFAAAHAAII9xs9gABFAAAsAAQKfxYAAgcABghkHWo1AKMBAAcABghkHWo1AKMBAAAA.山鸡老表:BAAALAAFFAIIBAABLAAFFAIICQAHAPcbAA==.',['屹川']='屹川丶元素萨:BAAALAAFFAIIBAABLAAFFAYIEgARABscAA==.屹川丶奶僧:BAAALAAECgIIAgAAAA==.屹川丶奶德:BAAALAAFFAIIBAAAAA==.屹川丶奶萨:BAABLAAFFH8FAAIVAAIIZxaxQgB9AAAVAAIIZxaxQgB9AAABLAAFFAYIEgARABscAA==.屹川丶奶骑:BAABLAAFFH8SAAIRAAYIGxwpCAAHAgARAAYIGxwpCAAHAgAAAA==.屹川丶小德:BAAALAAFFAIIBAAAAA==.屹川丶戒律:BAAALAAFFAIIAgAAAA==.屹川丶撒亚人:BAAALAAECgYICwAAAA==.屹川丶湮灭:BAAALAAECgYIBgAAAA==.屹川丶熊德:BAABLAAECn8YAAMbAAcICRHyEAAoAQAbAAcICRHyEAAoAQAcAAYIAgTCNwDHAAAAAA==.屹川丶狂怒:BAAALAAECgEIAQAAAA==.屹川丶踏风:BAAALAAECgYIBwAAAA==.屹川丶酒仙:BAAALAAECgYIBwAAAA==.屹川丶野德:BAABLAAFFH8HAAIcAAMICw4JCwB1AAAcAAMICw4JCwB1AAAAAA==.屹川丶黒箭:BAAALAAFFAMIAwAAAA==.',['岁月']='岁月并非如歌:BAAALAADCgEIAQAAAA==.',['峒河']='峒河老大哥:BAABLAAFFH8GAAISAAIItgp3GQA9AAASAAIItgp3GQA9AAAAAA==.',['巅峰']='巅峰丿修罗灬:BAAALAADCgcIBwAAAA==.',['巨神']='巨神兵:BAAALAAECgYICwAAAA==.',['布响']='布响丸辣:BAAALAAFFAIIAgABLAAFFAYICQAaACUIAA==.',['希尔']='希尔瓦辣条:BAAALAAFFAIIBAAAAA==.',['平凡']='平凡的河狸:BAACLAAFFH8MAAIXAAIIChuWJgCeAAAXAAIIChuWJgCeAAAsAAQKfx4ABBcABghKI4InAE0CABcABghKI4InAE0CAB0ABQgHGiJMAIYBAB4AAQiNFaI7ADwAAAAA.',['平稳']='平稳的河狸:BAAALAAECgYICgABLAAFFAIIDAAXAAobAA==.',['幻兽']='幻兽之王:BAAALAAECgYIBgAAAA==.',['幽灵']='幽灵芝阍:BAAALAAECgUIBwAAAA==.',['康德']='康德:BAABLAAFFH8GAAIYAAYI2APkHwDAAAAYAAYI2APkHwDAAAAAAA==.',['张学']='张学友:BAAALAAECgUIBwAAAA==.',['影心']='影心:BAACLAAFFH8sAAIXAAcIjxoxCABFAgAXAAcIjxoxCABFAgAsAAQKfxkAAhcACAiGHBslAFoCABcACAiGHBslAFoCAAAA.',['很牛']='很牛的牛肉粉:BAABLAAECn8XAAMbAAcIJxToFgB4AQAbAAYIyBXoFgB4AQAcAAcIpQt0JABrAQAAAA==.',['御小']='御小魂:BAABLAAFFH8QAAIOAAYIsRooDgBlAQAOAAYIsRooDgBlAQAAAA==.',['微光']='微光如炬:BAAALAADCgIIAgAAAA==.',['德资']='德资:BAAALAAFFAYIAQAAAA==.',['快点']='快点睡觉:BAAALAAECgYIBQAAAA==.',['性感']='性感冷艳:BAAALAAECgYIDQAAAA==.',['恐龙']='恐龙不扛娘:BAAALAAECgYIBgAAAA==.',['情忆']='情忆丶圣骑:BAAALAAFFAYIBAAAAA==.情忆丶恶魔:BAABLAAFFH8GAAIGAAYIpALENwC5AAAGAAYIpALENwC5AAAAAA==.情忆丶江南:BAABLAAFFH8KAAIEAAYIJAQ2LQDyAAAEAAYIJAQ2LQDyAAAAAA==.情忆丶烟云:BAAALAADCgcIBwAAAA==.情忆丶烟雨:BAAALAAFFAYIBAAAAA==.情忆丶熊熊:BAABLAAFFH8GAAIcAAYIpwEnDABTAAAcAAYIpwEnDABTAAAAAA==.',['想飞']='想飞的牛:BAAALAAECgYICQAAAA==.',['憤怒']='憤怒的蜗牛:BAAALAAECgYICAAAAA==.',['我乃']='我乃上将潘凤:BAAALAADCgQIBAAAAA==.',['我是']='我是吓大的:BAABLAAFFH8SAAMYAAYIzCIDBwD5AQAYAAYIzCIDBwD5AQAMAAEIfAF9YQAcAAAAAA==.',['我没']='我没有狐臭阿:BAAALAAECgIIAgAAAA==.',['战无']='战无虚发:BAAALAAECggICAAAAA==.',['戴蒙']='戴蒙亨特:BAAALAAECgUIBgAAAA==.',['打不']='打不死扛不住:BAAALAADCggICAAAAA==.',['打小']='打小就牛:BAABLAAFFH8KAAIYAAIIaArzJQB7AAAYAAIIaArzJQB7AAAAAA==.',['打爆']='打爆你们:BAAALAAFFAIIBAAAAA==.',['执剑']='执剑饮烈酒:BAABLAAECn8eAAINAAYIKwe6JgC/AAANAAYIKwe6JgC/AAAAAA==.',['批萨']='批萨猪:BAAALAAECgQIBAAAAA==.',['挑逗']='挑逗的嘴角:BAABLAAECn8XAAIPAAYIfRpnTAB4AQAPAAYIfRpnTAB4AQAAAA==.',['撒旦']='撒旦之吻:BAAALAAECgEIAQAAAA==.',['敌铠']='敌铠:BAAALAADCgEIAQAAAA==.',['早晚']='早晚要防骑:BAAALAAECgYIDAAAAA==.',['昔昔']='昔昔盐:BAAALAAECgMIAwAAAA==.',['晚安']='晚安吾爱:BAAALAAECgMIAwAAAA==.',['晴玲']='晴玲飞雪:BAAALAADCggICAAAAA==.',['暴力']='暴力狂:BAAALAAECgUIBQAAAA==.',['暴戈']='暴戈戈:BAAALAAECgQIAgAAAA==.',['暴躁']='暴躁五花肉:BAAALAAECgQIBgAAAA==.',['月之']='月之暗面:BAAALAAFFAMIAwAAAA==.',['月痕']='月痕:BAABLAAFFH8GAAMUAAII+xh3IwCBAAAKAAII0RBuZACIAAAUAAIIzxZ3IwCBAAAAAA==.',['有个']='有个道贼:BAAALAADCgYIBgAAAA==.',['有点']='有点小忐忑:BAABLAAFFH8LAAIMAAUIGxN6HQA6AQAMAAUIGxN6HQA6AQAAAA==.',['朕羊']='朕羊你勿罪:BAABLAAECn8gAAISAAYIDQ6lJQD1AAASAAYIDQ6lJQD1AAAAAA==.',['朗普']='朗普特:BAAALAAECgUIBQAAAA==.',['朝左']='朝左丶:BAABLAAFFH8RAAIHAAUIDRP8RQAiAQAHAAUIDRP8RQAiAQAAAA==.',['木若']='木若雅:BAAALAAECgMIAwAAAA==.',['未成']='未成年少钕:BAAALAAECgQIAgAAAA==.',['朵朵']='朵朵:BAAALAAECgYICAAAAA==.',['李二']='李二狗:BAABLAAFFH8OAAMcAAYIiQ3CBgAkAQAcAAYIiQ3CBgAkAQAMAAMIXBkAAAAAAAAAAA==.',['杰哥']='杰哥叁:BAAALAADCgYIBgAAAA==.',['杰尼']='杰尼龟:BAAALAAECgcIBwAAAA==.',['林月']='林月如丶:BAAALAAECggICAAAAA==.',['枫林']='枫林落叶:BAAALAAECgMIAwAAAA==.',['桃子']='桃子乌龙谢谢:BAAALAAECgYIBgAAAA==.',['桃花']='桃花岛丶郭靖:BAAALAAECgUIBQAAAA==.',['梦境']='梦境行者:BAAALAAFFAIIAgAAAA==.',['梦想']='梦想尽头:BAAALAADCgEIAQAAAA==.',['梦魇']='梦魇小骑士:BAAALAAECgIIAgAAAA==.',['橋本']='橋本環奈:BAABLAAFFH8GAAIKAAYIgBiTCQDxAQAKAAYIgBiTCQDxAQAAAA==.',['橘信']='橘信:BAAALAAECggICAAAAA==.',['橘子']='橘子丶:BAAALAAECggICAAAAA==.',['橙色']='橙色的牛氓:BAABLAAFFH8PAAMDAAUIpiOnDQBqAQAEAAUIViK2GwCJAQADAAUI5h2nDQBqAQAAAA==.',['欧皇']='欧皇小妮:BAABLAAFFH8IAAIPAAII5R5QKwCzAAAPAAII5R5QKwCzAAAAAA==.',['武圣']='武圣关羽:BAAALAAFFAEIAQAAAA==.',['武神']='武神千千:BAAALAAECggICAAAAA==.',['死后']='死后依然美:BAAALAADCgQIBAAAAA==.',['毁灭']='毁灭吧:BAABLAAFFH8JAAMaAAYIJQhzDgBQAAAaAAIIbxhzDgBQAAAJAAYIAACNdgABAAAAAA==.',['毒奶']='毒奶小德:BAAALAADCgcIBwAAAA==.',['毛头']='毛头小术:BAACLAAFFH8kAAMJAAYI2yGxEwDsAQAJAAYI2yGxEwDsAQAaAAIIjB0uCgC4AAAsAAQKfxYABAkABwh4IzIcAAACAAkABwh4IzIcAAACAB8AAgiiHF4qAJgAABoAAQgJJUSJAF4AAAAA.',['毛胖']='毛胖球:BAABLAAFFH8gAAMXAAgIFCLJAgDKAgAXAAcIYyPJAgDKAgAdAAQIaRB2FAAvAQABLAAFFAgIpAAXAAUkAA==.',['水无']='水无濑:BAAALAAFFAIIAgAAAA==.',['污喵']='污喵王:BAAALAAECgUIBgAAAA==.',['沉沦']='沉沦醉生梦死:BAABLAAECn8UAAIJAAcICA5DRQA0AQAJAAcICA5DRQA0AQAAAA==.',['泰勒']='泰勒斯:BAACLAAFFH8UAAIIAAYI9gtNBABsAQAIAAYI9gtNBABsAQAsAAQKfxcAAwgABgi4GpYhAK4BAAgABgi4GpYhAK4BAAcABQhqBBNcAakAAAAA.',['流逝']='流逝无痕:BAABLAAECn8VAAIBAAYIJw60QgABAQABAAYIJw60QgABAQAAAA==.',['浪浪']='浪浪山小妖精:BAAALAAECgIIAwAAAA==.',['海参']='海参炒面:BAAALAAECgQIBAAAAA==.',['渊博']='渊博的蜗牛:BAAALAAECgMIAwAAAA==.',['渝州']='渝州打手:BAABLAAECn8UAAIKAAcInxKJgwBCAQAKAAcInxKJgwBCAQAAAA==.',['温婉']='温婉的河狸:BAABLAAFFH8GAAIBAAIISBZXRACbAAABAAIISBZXRACbAAABLAAFFAIIDAAXAAobAA==.',['温熊']='温熊:BAAALAAECgMIAwAAAA==.',['溏沫']='溏沫沫:BAAALAAECgYICgAAAA==.',['满地']='满地伤:BAAALAAECgMIAwAAAA==.',['满船']='满船清梦:BAAALAADCgYIBgAAAA==.',['漠丿']='漠丿小丹:BAAALAAECgUICgAAAA==.',['潇洒']='潇洒走一回:BAACLAAFFH8JAAMRAAIIFQOLLABXAAARAAIIFQOLLABXAAAPAAEIqAFYigAAAAAsAAQKfxoAAhEABggcEJsiAC4BABEABggcEJsiAC4BAAAA.',['澜神']='澜神:BAAALAAECgcICQAAAA==.',['炖鸡']='炖鸡狂魔:BAAALAAECgEIAQAAAA==.',['炫酷']='炫酷:BAAALAAFFAIIBAAAAA==.炫酷之裤:BAACLAAFFH8GAAMHAAII5R6OVwCcAAAHAAII5R6OVwCcAAAZAAIIUxU6DwCNAAAsAAQKfyAAAwcABwi3I/YsAL4CAAcABwhWI/YsAL4CABkABgg8HysWAPkBAAAA.',['烙雪']='烙雪残阳:BAAALAADCgYIBgAAAA==.',['燃烧']='燃烧军团猎:BAAALAADCgEIAQAAAA==.',['爱别']='爱别离:BAAALAAECggIEAAAAA==.',['爱莉']='爱莉希雅:BAAALAAFFAIIAgAAAA==.',['牛八']='牛八亨:BAABLAAFFH8NAAIPAAUIiQ9PLgAUAQAPAAUIiQ9PLgAUAQAAAA==.',['牛妞']='牛妞佛:BAAALAAECggICAAAAA==.',['狂想']='狂想者:BAAALAAECgIIAgAAAA==.',['狐筱']='狐筱妖:BAAALAAECgYIEAAAAA==.',['狼出']='狼出鬼没:BAABLAAFFH8WAAIKAAUIthThSwAdAQAKAAUIthThSwAdAQAAAA==.',['狼叔']='狼叔丿:BAACLAAFFH8nAAIKAAYIcR+9HADAAQAKAAYIcR+9HADAAQAsAAQKfzcAAgoACAiRI2YYAPwCAAoACAiRI2YYAPwCAAAA.',['猎犬']='猎犬丶:BAAALAAFFAIIAwABLAAFFAUIEQAHAA0TAA==.',['猛的']='猛的一匹:BAAALAAFFAIIAgAAAA==.',['猫儿']='猫儿啃泥巴:BAAALAADCggICAAAAA==.',['珊瑚']='珊瑚哥:BAAALAAECgYICgAAAA==.',['瑶光']='瑶光丶:BAAALAAECgcIDgAAAA==.',['用眼']='用眼睛去瞪:BAAALAAECggIEgAAAA==.',['男人']='男人无敌:BAAALAAECgEIAQAAAA==.',['留恋']='留恋过往:BAAALAAECgYIBgABLAAFFAcICgAHAA8eAA==.',['痛苦']='痛苦折磨:BAAALAAECgYIBgAAAA==.',['癞飛']='癞飛天:BAAALAADCgMIAwAAAA==.',['白梦']='白梦妍:BAABLAAECn8nAAMDAAgIdw3iIgAuAQADAAgIYw3iIgAuAQAEAAYI2wiOtAAXAQAAAA==.',['白银']='白银之膝盖:BAABLAAFFH8GAAIRAAYIaQ9mBgDLAQARAAYIaQ9mBgDLAQABLAAFFAgIBgAPAMsRAA==.',['盗德']='盗德的德丶:BAAALAAECgIIAgAAAA==.',['目标']='目标的目标:BAAALAADCgEIAQAAAA==.',['直击']='直击我的灵魂:BAABLAAFFH8OAAIJAAYIzhFrKwBtAQAJAAYIzhFrKwBtAQABLAAFFAYIKAAHAHshAA==.',['瞳话']='瞳话:BAAALAAECgYIBgAAAA==.',['石中']='石中剑:BAAALAAECgcIDgAAAA==.',['确实']='确实:BAABLAAFFH8GAAMDAAMIDxPqGACVAAADAAMIDxPqGACVAAAEAAII/AQbTQBwAAAAAA==.',['磨剪']='磨剪子戗菜刀:BAAALAAECggICAAAAA==.',['离群']='离群的大猫咪:BAABLAAFFH8eAAIGAAYI9yH5DgDqAQAGAAYI9yH5DgDqAQAAAA==.',['秋天']='秋天深蓝:BAAALAADCgQIBgAAAA==.',['秋知']='秋知叶落:BAAALAAECgYICQAAAA==.',['科比']='科比布莱恩特:BAAALAAECgUIBQABLAAFFAYIGQAEAIEcAA==.',['稳重']='稳重的河狸:BAABLAAFFH8MAAIMAAII9CCAGQC8AAAMAAII9CCAGQC8AAABLAAFFAIIDAAXAAobAA==.',['稻香']='稻香:BAAALAAECgQIBAAAAA==.',['立刻']='立刻狂暴:BAAALAAECgYIDwAAAA==.',['童童']='童童:BAAALAAFFAMIBAAAAA==.',['米凯']='米凯拉的锋刃:BAAALAADCgQIBAAAAA==.',['籹吇']='籹吇借个吻:BAABLAAFFH8OAAIHAAMIXgbBNQDIAAAHAAMIXgbBNQDIAAAAAA==.',['精灵']='精灵宝钻:BAAALAAECgYIBgAAAA==.',['糕神']='糕神:BAAALAAECgMIBgAAAA==.',['糯灬']='糯灬团团:BAAALAAECgIIAgAAAA==.糯灬米团:BAAALAAECgYIBgAAAA==.',['紫皮']='紫皮苍蝇:BAAALAADCgUIBQAAAA==.',['維多']='維多利亞一世:BAAALAADCgIIAgAAAA==.',['红烧']='红烧小蓝猫:BAAALAAECggIAwAAAA==.红烧小黑兔:BAAALAAECgIIAgAAAA==.',['红酒']='红酒妹:BAAALAAECgMIAwAAAA==.',['细路']='细路囡:BAAALAAECgYIBwAAAA==.',['结界']='结界灬:BAACLAAFFH8PAAIHAAMIlSNwLwDdAAAHAAMIlSNwLwDdAAAsAAQKfycAAgcACAj+JUoHAGADAAcACAj+JUoHAGADAAAA.',['绿巨']='绿巨人:BAAALAAECgYIBgAAAA==.',['美式']='美式坦克:BAABLAAECn8nAAIMAAYIeRjuJgCjAQAMAAYIeRjuJgCjAQAAAA==.',['美版']='美版迅捷咕:BAAALAAFFAMIAwAAAA==.',['美眉']='美眉麻将:BAAALAAECgEIAQAAAA==.',['群星']='群星萝莉丷:BAABLAAFFH8UAAIGAAUI3xnPDADZAQAGAAUI3xnPDADZAQAAAA==.',['老坛']='老坛:BAAALAAECgEIAQAAAA==.',['老板']='老板来瓶水:BAABLAAFFH8ZAAIKAAYISxxHIgCpAQAKAAYISxxHIgCpAQAAAA==.',['老鼠']='老鼠人:BAAALAAECgMIAwAAAA==.',['耗丶']='耗丶子:BAAALAAECgMIAwAAAA==.',['联盟']='联盟组人:BAAALAAECgMIAwAAAA==.',['脾气']='脾气坏:BAAALAAECggICAAAAA==.',['腻腻']='腻腻:BAAALAADCgIIAgAAAA==.',['臣妾']='臣妾做不到哇:BAAALAAECgEIAQAAAA==.',['自撸']='自撸吉祥物:BAAALAAFFAMIAwAAAA==.',['自灬']='自灬由:BAAALAAFFAIIBAAAAA==.',['自由']='自由飞翔:BAAALAADCgIIAgAAAA==.',['至善']='至善随心:BAAALAAECgMIAwAAAA==.',['致命']='致命节奏:BAAALAAFFAIIAwABLAAFFAYIEgARABscAA==.',['舞零']='舞零舞:BAAALAAECgEIAQAAAA==.',['艾克']='艾克瑟琳:BAABLAAFFH8GAAIPAAIIawodWgCHAAAPAAIIawodWgCHAAAAAA==.',['艾陆']='艾陆之力:BAACLAAFFH8tAAIDAAcIoRrTBQDtAQADAAcIoRrTBQDtAQAsAAQKfzEAAgMACAjiIXkLAPECAAMACAjiIXkLAPECAAAA.',['芋头']='芋头大仙:BAAALAAECgYIEgAAAA==.',['芤曖']='芤曖:BAACLAAFFH8KAAIVAAIIUxk2PACIAAAVAAIIUxk2PACIAAAsAAQKfxoAAhUACAgXHZwgAJECABUACAgXHZwgAJECAAAA.',['芯碎']='芯碎:BAABLAAFFH8JAAIVAAYI5QYBLQABAQAVAAYI5QYBLQABAQAAAA==.',['花儿']='花儿瑜:BAAALAAECgYIBwAAAA==.',['花再']='花再:BAABLAAFFH8KAAIGAAYIBg5SIACAAQAGAAYIBg5SIACAAQAAAA==.',['花凌']='花凌:BAAALAAECgYIBgAAAA==.',['花初']='花初:BAABLAAFFH8RAAINAAYIXQ62CABiAQANAAYIXQ62CABiAQAAAA==.',['花开']='花开:BAABLAAFFH8bAAMMAAYI1hiMDgDWAQAMAAYI1hiMDgDWAQAYAAUI8gwCGwD9AAAAAA==.',['花弗']='花弗:BAABLAAFFH8hAAIPAAYI/SGFDADfAQAPAAYI/SGFDADfAQAAAA==.',['花椒']='花椒:BAABLAAFFH8jAAIEAAYIcR3mEQDKAQAEAAYIcR3mEQDKAQAAAA==.',['花椰']='花椰菜之心:BAAALAAECgMIAwAAAA==.',['花泽']='花泽:BAABLAAFFH81AAIHAAYI7iJCEADSAQAHAAYI7iJCEADSAQAAAA==.',['花絮']='花絮:BAAALAAECgQIBQAAAA==.花絮樱:BAAALAAECgYIBgAAAA==.',['花菜']='花菜:BAABLAAFFH8rAAQXAAYIFyJvBwBTAgAXAAYIFyJvBwBTAgAeAAIIGgdVCAA0AAAdAAIIrgE0MQAvAAAAAA==.',['花落']='花落:BAABLAAFFH8tAAIKAAYIsSImEwD0AQAKAAYIsSImEwD0AQAAAA==.',['花蔓']='花蔓:BAABLAAFFH8nAAMBAAgI4R+FBgCAAgABAAgInR6FBgCAAgASAAYI4xgzBQBzAQAAAA==.',['花酒']='花酒:BAABLAAFFH8qAAMVAAYILRNqHgBoAQAVAAYILRNqHgBoAQAWAAUIFRieHwBEAQAAAA==.',['花醒']='花醒:BAABLAAFFH8OAAMJAAYIyActOAAsAQAJAAYIyActOAAsAQAaAAIIgQn8FABCAAAAAA==.',['苍蓝']='苍蓝残响:BAACLAAFFH8cAAMTAAYIjR1vBACgAQATAAYIjR1vBACgAQACAAUILxYcCwBWAQAsAAQKfyIAAwIACAilIOsSAJkCAAIABwh+IOsSAJkCABMAAghuGwsMAJsAAAAA.',['苏格']='苏格拉底:BAACLAAFFH8cAAMPAAgI5wlAIwBUAQAPAAgI5wlAIwBUAQARAAMIzQjXIQCUAAAsAAQKfzUABBEACAiNEacqAM4BABEACAiNEacqAM4BAA8ACAj1FzQ7AKsBACAAAggaFk5AAEQAAAAA.',['英俊']='英俊:BAABLAAFFH8KAAIKAAIItAsrcgB9AAAKAAIItAsrcgB9AAABLAAFFAgIHAAYAOIkAA==.',['荏苒']='荏苒灬:BAAALAAECgYIBwAAAA==.',['荒天']='荒天帝:BAAALAAFFAIIAgAAAA==.',['莉亚']='莉亚迪桑:BAABLAAECn8XAAMKAAgI0B67EgCPAgAKAAgIZR67EgCPAgAUAAcIJxewPgC8AQAAAA==.',['莱尔']='莱尔逐日者:BAABLAAFFH8IAAIUAAQIhxK/CwDQAAAUAAQIhxK/CwDQAAAAAA==.',['萌象']='萌象象:BAABLAAFFH8IAAIKAAIIRRtoSgCaAAAKAAIIRRtoSgCaAAAAAA==.',['葫芦']='葫芦蛙:BAABLAAFFH8MAAIPAAYIlBK8JABMAQAPAAYIlBK8JABMAQAAAA==.',['蒲公']='蒲公英:BAACLAAFFH8QAAMPAAUI4QrTLgAPAQAPAAUI4QrTLgAPAQAgAAEIkQq0IwAxAAAsAAQKfxQAAiAACAh2FyUnAMkBACAACAh2FyUnAMkBAAAA.',['蓝眼']='蓝眼豆豆:BAAALAAFFAEIAQAAAA==.',['虚空']='虚空猎杀者:BAAALAAECgQIBAAAAA==.',['蚩尤']='蚩尤大帝:BAABLAAFFH8FAAIJAAIITwVRcAAtAAAJAAIITwVRcAAtAAAAAA==.',['蛊尔']='蛊尔丹儿:BAABLAAFFH8hAAIJAAUIqg3iLADSAAAJAAUIqg3iLADSAAAAAA==.',['蛮牛']='蛮牛:BAAALAAECgYICAAAAA==.',['蜗牛']='蜗牛超人:BAAALAAECgYIBgAAAA==.',['补血']='补血使者:BAAALAADCgEIAQAAAA==.',['见好']='见好就收:BAAALAAECgYIDgAAAA==.',['认真']='认真专注冷静:BAAALAAFFAQIBAAAAA==.',['谁又']='谁又明浪子心:BAAALAAECgIIAgAAAA==.',['调皮']='调皮:BAAALAADCggICAAAAA==.',['豹跳']='豹跳熊突:BAACLAAFFH8FAAMYAAII9gPvLwA1AAAYAAEI0ATvLwA1AAAbAAEIHANPDQAuAAAsAAQKfxsABBsACAhKEacaAEoBABsABggGFKcaAEoBABgABwjqBmBwAAQBABwABwh9Aps5ALUAAAAA.',['赏金']='赏金家族:BAAALAAECgYICAAAAA==.',['赞达']='赞达拉剑士:BAABLAAFFH8GAAIDAAYIrQ8qFAAfAQADAAYIrQ8qFAAfAQAAAA==.',['赫萝']='赫萝:BAAALAAFFAIIBAAAAA==.',['超威']='超威老炮:BAACLAAFFH8ZAAMEAAYIgRyKFAC3AQAEAAYIJhmKFAC3AQADAAMIXSSEEQDBAAAsAAQKfy8AAwMACAjdJXEDAF0DAAMACAjdJXEDAF0DAAQACAgXIwgJALkCAAAA.',['超导']='超导:BAABLAAFFH8HAAIEAAUIFQsEKgAbAQAEAAUIFQsEKgAbAQAAAA==.',['超级']='超级芫茜:BAAALAAECgIIAgAAAA==.超级袄景王:BAAALAAFFAIIAgAAAA==.',['超速']='超速蜗牛:BAABLAAFFH8IAAIEAAIIdRTfUQBDAAAEAAIIdRTfUQBDAAAAAA==.',['跑跑']='跑跑就是牛:BAAALAAECgcIDwAAAA==.',['跳高']='跳高斯温:BAABLAAFFH8IAAIJAAMIOgnOUgBoAAAJAAMIOgnOUgBoAAAAAA==.',['轻舞']='轻舞淇淇:BAAALAAFFAIIAgAAAA==.',['辣辣']='辣辣油米:BAAALAAECgEIAQAAAA==.',['达克']='达克多戈:BAAALAAECgYIBgAAAA==.',['还缺']='还缺德吗:BAAALAADCgEIAQAAAA==.',['逍遥']='逍遥十落叶:BAAALAAFFAIIAgAAAA==.',['道长']='道长:BAAALAAFFAIIBAAAAA==.',['遗弃']='遗弃新之助:BAAALAAECgQIBAAAAA==.遗弃珐绅:BAAALAAECgQIBgAAAA==.遗弃神起:BAAALAAECgYICgAAAA==.',['那个']='那个奶萨:BAAALAADCgQIBAAAAA==.那个萨满丶:BAABLAAFFH8WAAIRAAgI4hxQAgC6AgARAAgI4hxQAgC6AgAAAA==.那个龙人:BAACLAAFFH80AAMSAAcIxyEmAQAcAgASAAYIxCQmAQAcAgABAAIIpRHoQACkAAAsAAQKf0IAAxIACAjaJYIBAPkCABIACAjaJYIBAPkCACEAAwi/FK4VAKIAAAAA.',['邪恶']='邪恶之霸:BAACLAAFFH80AAQaAAcIjiDFBgC/AAAJAAUI9RpWKwBtAQAfAAII2iF0AwDQAAAaAAMIPCTFBgC/AAAsAAQKfyMABAkABwh1IoIuAIQCAAkABwhKIYIuAIQCAB8AAgiWH1cmALYAABoAAQjmI2+HAGQAAAAA.邪恶代言人:BAABLAAFFH8PAAIHAAUInw8HKQD1AAAHAAUInw8HKQD1AAABLAAFFAYIEgARABscAA==.',['郭小']='郭小囡:BAAALAAECgMIAwAAAA==.',['酸菜']='酸菜雨:BAABLAAFFH8LAAIPAAIIihi1UABVAAAPAAIIihi1UABVAAAAAA==.',['醉翩']='醉翩翩:BAAALAAECgYIDQAAAA==.',['醉醉']='醉醉:BAABLAAFFH8KAAIHAAYItg2xMgBwAQAHAAYItg2xMgBwAQAAAA==.',['采菊']='采菊东篱:BAAALAAECgYIBgAAAA==.',['重新']='重新起航:BAAALAAECgYIBgAAAA==.',['野兽']='野兽啊:BAAALAAECgMIAwAAAA==.',['鋼鉄']='鋼鉄韵律:BAACLAAFFH8IAAIDAAIImwniJwBuAAADAAIImwniJwBuAAAsAAQKfx8AAwMACAjaEb85AKEBAAMACAjaEb85AKEBAAQAAwiyCwriAJwAAAAA.',['鑫爷']='鑫爷:BAAALAADCggICAAAAA==.',['钰钰']='钰钰:BAAALAAECgQIBAAAAA==.',['铁山']='铁山鹰:BAAALAAECgcIEwAAAA==.',['阳光']='阳光丶:BAABLAAFFH8PAAIPAAMIQQ8+RQCEAAAPAAMIQQ8+RQCEAAAAAA==.阳光宝宝:BAABLAAFFH8iAAIRAAYIphwqCAAHAgARAAYIphwqCAAHAgAAAA==.阳光小宝贝:BAABLAAFFH8sAAIVAAYIrxuNFAC8AQAVAAYIrxuNFAC8AQAAAA==.阳光小小:BAABLAAFFH8jAAIXAAYIvB30CwALAgAXAAYIvB30CwALAgAAAA==.',['阿冬']='阿冬灬:BAAALAAFFAEIAQABLAAFFAIIAgAiAAAAAA==.',['阿姐']='阿姐:BAAALAAECgYIBgAAAA==.',['阿宝']='阿宝怒风:BAAALAADCgUIBQAAAA==.',['陌上']='陌上寸草:BAAALAAFFAIIAgAAAA==.',['雨中']='雨中花:BAAALAAECgYIBgAAAA==.',['雪封']='雪封尘:BAABLAAFFH8XAAIHAAUIpxmNMQDVAAAHAAUIpxmNMQDVAAAAAA==.',['雪幽']='雪幽晴:BAAALAAECgYICgAAAA==.',['雪花']='雪花女神龙:BAAALAAFFAIIBAAAAA==.',['零神']='零神瑟丝卡:BAABLAAFFH8RAAIRAAYI1w7VDwCJAQARAAYI1w7VDwCJAQAAAA==.',['雷电']='雷电狂徒:BAAALAAFFAEIAQAAAA==.',['霍霍']='霍霍:BAABLAAFFH8KAAIXAAUIOiLxDQD0AQAXAAUIOiLxDQD0AQAAAA==.',['霜冻']='霜冻之羽:BAAALAAECgQIAwAAAA==.',['霸气']='霸气上冒:BAABLAAFFH8FAAIZAAUIpQk9EADzAAAZAAUIpQk9EADzAAAAAA==.',['青菜']='青菜要放葱:BAAALAAFFAIIAgAAAA==.',['靓盈']='靓盈:BAAALAADCgQIBAAAAA==.',['顶级']='顶级手法:BAACLAAFFH8mAAIBAAYIsB1nGQC3AQABAAYIsB1nGQC3AQAsAAQKfx0AAgEACAiGIQsWAP4CAAEACAiGIQsWAP4CAAEsAAUUBggoAAcAeyEA.',['顶风']='顶风作案:BAABLAAFFH8GAAIHAAYIagblSAAUAQAHAAYIagblSAAUAQAAAA==.',['须佐']='须佐之男命:BAABLAAFFH8ZAAMKAAYI0RfjEAClAQAKAAYI0RfjEAClAQAUAAII6g+lJgB6AAAAAA==.',['颓废']='颓废王子:BAAALAADCgIIAgAAAA==.',['风存']='风存:BAAALAAFFAIIBAAAAA==.',['风暴']='风暴韵律:BAAALAAFFAIIAgAAAA==.',['风雪']='风雪怜幽谷:BAABLAAFFH8fAAIBAAYI1hvEHgCcAQABAAYI1hvEHgCcAQAAAA==.',['风风']='风风:BAABLAAFFH8NAAIPAAYIohFSHgByAQAPAAYIohFSHgByAQAAAA==.',['飝滒']='飝滒:BAAALAAFFAIIAwAAAA==.',['飝裓']='飝裓:BAABLAAFFH8FAAIHAAIIqRYUgABFAAAHAAIIqRYUgABFAAAAAA==.',['飝贼']='飝贼:BAAALAADCgUIBQAAAA==.',['飞翔']='飞翔的河狸:BAAALAAFFAIIAgABLAAFFAIIDAAXAAobAA==.',['饭饭']='饭饭之呗:BAAALAADCgEIAQAAAA==.饭饭之备:BAAALAAECgUIAgAAAA==.',['香香']='香香熊:BAABLAAFFH8QAAIMAAYI8hhpEADAAQAMAAYI8hhpEADAAQAAAA==.',['馨児']='馨児:BAAALAAECgYIBgAAAA==.',['馬克']='馬克斯彡德:BAABLAAFFH8GAAIbAAIIWgVgCwBYAAAbAAIIWgVgCwBYAAAAAA==.馬克斯彡肖:BAABLAAFFH8LAAIjAAIIQgSkGQBQAAAjAAIIQgSkGQBQAAAAAA==.馬克斯彡萧:BAAALAAECgYIBgAAAA==.',['骄阳']='骄阳严寒:BAAALAAECgYIBgAAAA==.',['高冷']='高冷女明星:BAAALAAECgMIAwAAAA==.',['魔神']='魔神角斗士:BAAALAAFFAEIAQAAAA==.',['鱻鱻']='鱻鱻:BAAALAAECgYIBgAAAA==.',['黎滴']='黎滴滴:BAAALAAECgcICAAAAA==.',['黑暗']='黑暗之心:BAAALAADCgMIAwAAAA==.',['黑椒']='黑椒牛排:BAAALAAECgMIAwAAAA==.',['黑皮']='黑皮松花蛋:BAABLAAFFH8TAAMXAAYIYh/cCQArAgAXAAYIYh/cCQArAgAdAAQIeBS6GADyAAAAAA==.',['黒羽']='黒羽仟影:BAAALAAFFAIIBAAAAA==.',['黯黑']='黯黑小念头:BAABLAAECn8VAAIVAAYIixYNgQB+AQAVAAYIixYNgQB+AQAAAA==.',['龍龍']='龍龍柒喊海底:BAAALAAECgUIBQAAAA==.',['龘飝']='龘飝飍舞:BAABLAAFFH8dAAIEAAYIgBPFHACCAQAEAAYIgBPFHACCAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end