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
 local lookup = {'Mage-Arcane','Mage-Frost','Warlock-Destruction','DeathKnight-Unholy','Mage-Fire','DeathKnight-Blood','Warrior-Arms','Warrior-Protection','Rogue-Assassination','DemonHunter-Havoc','Shaman-Restoration','Shaman-Elemental','DemonHunter-Vengeance','Monk-Windwalker','Monk-Brewmaster','Rogue-Subtlety','Paladin-Retribution','Priest-Holy','Priest-Shadow','Priest-Discipline','Hunter-BeastMastery','Hunter-Marksmanship','Warlock-Demonology','Warlock-Affliction','Druid-Balance','Monk-Mistweaver','Unknown-Unknown','Evoker-Devastation','Warrior-Fury','DeathKnight-Frost','Druid-Restoration','Paladin-Protection','Shaman-Enhancement',}; local provider = {region='CN',realm='雏龙之翼',name='CN',type='weekly',zone=42,date='2025-08-03',data={Al='Aluka:BAAAKgAFFAQIBAAAAA==.',Ap='Apurple:BAAAKgAFFAQIBAAAAA==.',Bl='Blackmage:BAACKgAFFH8GAAIBAAYIgBY2DQCSAQABAAYIgBY2DQCSAQAqAAQKfzIAAwIACAiLF0QgAK8BAAIACAiLF0QgAK8BAAEABghzEDtQAP4AAAAA.',Bu='Buther:BAABKgAFFH8MAAIDAAgI5BFbBQAhAgADAAgI5BFbBQAhAgAAAA==.',De='Deadlines:BAAAKgAECggICQAAAA==.Deathknights:BAABKgAFFH8GAAIEAAYIbANrIwAIAQAEAAYIbANrIwAIAQAAAA==.Decepticons:BAACKgAFFH8cAAMBAAQIyR8+IQDiAAABAAQIHh4+IQDiAAAFAAMInBZWGgDWAAAqAAQKf0AABAUACAhMJEIIANACAAUACAi4I0IIANACAAIABgjkGD5PACgBAAEAAwjtIOpKABMBAAAA.Deepsea:BAAAKgAECggICAAAAA==.Demonrider:BAAAKgADCgcIBwAAAA==.',Dr='Drpriest:BAAAKgADCgQIBQAAAA==.',Ed='Edp:BAAAKgADCggICAAAAA==.',Eg='Eggtart:BAAAKgADCggICAAAAA==.',Es='Escapist:BAAAKgAECgYIEgAAAA==.',Fi='Firefly:BAAAKgAFFAQIBAAAAA==.',Go='Goaway:BAAAKgAECgMIBQAAAA==.',Gt='Gtese:BAAAKgADCggICAAAAA==.',Ic='Icecoke:BAAAKgADCgcIBwAAAA==.',In='Inn:BAABKgAFFH8GAAMEAAQI+xWaDwD7AAAEAAQI+xWaDwD7AAAGAAIInQTfIQBQAAAAAA==.',Ir='Ira:BAABKgAFFH8GAAIHAAYI/RJoAQC4AQAHAAYI/RJoAQC4AQAAAA==.',Is='Isler:BAAAKgAFFAMIAwAAAA==.',Ja='Javelin:BAABKgAECn8lAAMHAAgIxRMYHwCMAQAHAAcI4xUYHwCMAQAIAAYIxAnBKAC+AAAAAA==.',Je='Jetai:BAAAKgAFFAYIAgABKgAFFAgIGwAJABoUAA==.',Ji='Jinnx:BAAAKgAFFAYIBAAAAA==.Jinzx:BAAAKgAECgQIBAAAAA==.',Jo='Johnreese:BAABKgAFFH8FAAIKAAUI9ATCFQDcAAAKAAUI9ATCFQDcAAAAAA==.',Kr='Kristian:BAABKgAFFH8FAAMLAAUIsQalPwCKAAALAAQIvwalPwCKAAAMAAEIIQYZJwBAAAAAAA==.',Ks='Ksphantom:BAAAKgAFFAQIBAAAAA==.',Li='Lii:BAAAKgADCgEIAQAAAA==.',Ll='Llylith:BAAAKgADCgIIAgAAAA==.',Me='Melody:BAABKgAFFH8FAAINAAUIXxPtAgAeAQANAAUIXxPtAgAeAQAAAA==.',Mo='Mordekaiser:BAABKgAFFH8KAAIGAAYIGxWCCwBZAQAGAAYIGxWCCwBZAQAAAA==.',Mu='Mucher:BAAAKgAFFAIIAwAAAA==.',Na='Nako:BAAAKgAECggICAAAAA==.',Pu='Pursuing:BAAAKgADCggIFAAAAA==.',Ra='Rafale:BAAAKgAECgIIAgAAAA==.',Ro='Roodi:BAAAKgAECgUIBQAAAA==.',Sm='Smileedol:BAAAKgAECgYICgAAAA==.',So='Sosy:BAAAKgADCgEIAgAAAA==.',St='Stylite:BAABKgAECn8YAAMOAAgIOxcxGADkAQAOAAgIOxcxGADkAQAPAAgIARAGEABAAQAAAA==.',Su='Sukhoi:BAAAKgAECgMIAwAAAA==.Sunpsyche:BAABKgAFFH8MAAIJAAYIIiKHCQC9AQAJAAYIIiKHCQC9AQAAAA==.',Sw='Swordthrust:BAACKgAFFH8cAAMQAAcIlBjbAQBhAQAQAAUIwBfbAQBhAQAJAAYIIhMfFAAQAQAqAAQKfxQAAxAACAgbH8IFAJwBABAABgjhHcIFAJwBAAkABAidH10eAG4BAAAA.',Ti='Tino:BAAAKgAFFAQIBAAAAA==.',Tr='Trissmerigo:BAAAKgADCgEIAQAAAA==.',Un='Unidaddy:BAAAKgAECgIIAgAAAA==.',Va='Valthonis:BAACKgAFFH8dAAIRAAQIXR+cPQD4AAARAAQIXR+cPQD4AAAqAAQKfzcAAhEACAiNIpgfAJsCABEACAiNIpgfAJsCAAAA.',Vi='Vi:BAAAKgAFFAgIBAAAAA==.',Vo='Voidim:BAABKgAFFH8IAAICAAgIxxaGAQAqAgACAAgIxxaGAQAqAgAAAA==.',Xx='Xxqishen:BAAAKgAECgEIAQAAAA==.',Ya='Yangbaby:BAAAKgAFFAQIAgAAAA==.',Ye='Yenneferr:BAABKgAFFH8IAAIDAAgIqBnSAwBQAgADAAgIqBnSAwBQAgAAAA==.',Zq='Zqz:BAAAKgAFFAEIAQAAAA==.',Zz='Zz:BAAAKgADCggICAAAAA==.',['一个']='一个小萨满:BAAAKgAECgQIBAAAAA==.一个耳环:BAABKgAECn8YAAQSAAYIBxoCNABOAQASAAYIBxoCNABOAQATAAYI5w00OgDWAAAUAAEIAADSpgAAAAAAAA==.',['一叶']='一叶风华:BAABKgAFFH8HAAIJAAYIhB7QCgCfAQAJAAYIhB7QCgCfAQAAAA==.',['一直']='一直在飞:BAAAKgAECgYIBgAAAA==.',['七个']='七个核桃:BAAAKgAECggICAAAAA==.',['七百']='七百龙:BAABKgAECn8VAAMVAAgINhwuLQD4AQAVAAgIRxkuLQD4AQAWAAIIxhrtewCGAAAAAA==.',['三岁']='三岁才会爬:BAABKgAECn8ZAAIXAAgIaB5DCABvAgAXAAgIaB5DCABvAgAAAA==.',['三鹿']='三鹿奶:BAAAKgAECgcIBwAAAA==.',['上汤']='上汤排骨:BAAAKgAFFAIIAgAAAA==.',['不是']='不是兔子的锅:BAAAKgAECgMIAwABKgAFFAgICgALAGQMAA==.',['不朽']='不朽傲天:BAAAKgADCgIIAgAAAA==.',['不负']='不负韶华丶:BAAAKgADCgMIAwAAAA==.',['两面']='两面三刃:BAAAKgAFFAQIBAAAAA==.',['丨可']='丨可乐瓶丨:BAAAKgADCgQIBAAAAA==.',['丨夏']='丨夏浅川丶:BAAAKgAECgMIAwAAAA==.',['丨悠']='丨悠哉悠哉丶:BAAAKgAECgEIAQAAAA==.',['丶七']='丶七月的风:BAAAKgAECggICAAAAA==.',['丶炸']='丶炸鸡加啤酒:BAAAKgAECgMIAwAAAA==.',['丶静']='丶静心:BAABKgAFFH8VAAQDAAYIwR0JAgDFAQADAAYIyxsJAgDFAQAXAAEIfxxjFABVAAAYAAIIIgSfGwBNAAAAAA==.',['丶飘']='丶飘渺孤鸿影:BAAAKgAECgUIBwAAAA==.',['乌拉']='乌拉巴哈:BAAAKgAECgcIBwAAAA==.',['乘風']='乘風破狼:BAABKgAFFH8IAAIZAAQIag07QgCkAAAZAAQIag07QgCkAAAAAA==.',['仓影']='仓影:BAABKgAFFH8HAAMCAAYIBRzDAwC5AQACAAYIBRzDAwC5AQABAAEIbgZhJgBHAAAAAA==.',['仙狐']='仙狐术:BAAAKgAECgIIAgAAAA==.',['仲夏']='仲夏叁拾:BAAAKgAECgIIAgAAAA==.',['伊利']='伊利蛋丶怒猴:BAAAKgAECgMIAwAAAA==.',['伊卡']='伊卡洛兹:BAAAKgAECggICAAAAA==.',['众神']='众神黄昏:BAAAKgAECgEIAQAAAA==.',['优迪']='优迪安路疯:BAABKgAECn8aAAIKAAgIWhJkPwBQAQAKAAgIWhJkPwBQAQAAAA==.',['会发']='会发光的左手:BAAAKgAECgQIBQAAAA==.会发光的手:BAAAKgAECgYIBgAAAA==.',['传统']='传统丽人:BAAAKgADCgMIAwAAAA==.',['伪坚']='伪坚强伪清新:BAABKgAFFH8OAAMVAAYIOSBMCwC6AQAVAAYIqR5MCwC6AQAWAAQIOh8QHQAIAQAAAA==.',['伴晏']='伴晏锺神:BAABKgAFFH8KAAICAAYImhi7CQApAQACAAYImhi7CQApAQAAAA==.',['余生']='余生还长:BAAAKgAECgEIAQAAAA==.',['佛叮']='佛叮:BAABKgAFFH8GAAIRAAYIvxeFHwByAQARAAYIvxeFHwByAQAAAA==.',['你戒']='你戒律阿:BAAAKgAECgQIBAAAAA==.',['你是']='你是牛也好:BAAAKgAECgUIBgAAAA==.',['你的']='你的姐姐:BAABKgAFFH8YAAIZAAYIMST3CAAJAgAZAAYIMST3CAAJAgAAAA==.',['佩佩']='佩佩有熊猫:BAABKgAFFH8GAAIaAAUIQg+uDADqAAAaAAUIQg+uDADqAAAAAA==.佩佩有猫:BAACKgAFFH8fAAILAAgIrhxmAgBNAgALAAgIrhxmAgBNAgAqAAQKfx4AAwsACAhQD8xIAGYBAAsACAhQD8xIAGYBAAwAAwitCKdlAIgAAAAA.佩佩有龙猫:BAAAKgAECgIIAgAAAA==.',['侬是']='侬是则模子:BAABKgAECn8ZAAIRAAgIFCH0OgA+AgARAAgIFCH0OgA+AgAAAA==.',['信仰']='信仰之光:BAAAKgADCgcIBwAAAA==.',['信宇']='信宇:BAAAKgAECgEIAQAAAA==.',['信用']='信用社郑经理:BAABKgAFFH8OAAIRAAYIrhfFFgD/AAARAAYIrhfFFgD/AAAAAA==.',['倔强']='倔强的小赖妮:BAAAKgAECgIIAgAAAA==.倔强的蜗牛:BAAAKgADCgEIAQAAAA==.',['元气']='元气少女:BAAAKgAFFAQIBAABKgAFFAgIAgAbAAAAAA==.',['元瑶']='元瑶:BAAAKgAECgIIAgAAAA==.',['元素']='元素副会长:BAAAKgAECgcIEwAAAA==.元素小会长:BAAAKgAECgYIDQAAAA==.',['光与']='光与暗:BAAAKgAECgYIDAAAAA==.',['克洛']='克洛卡卡:BAAAKgAECgEIAQAAAA==.',['兔子']='兔子的小德:BAAAKgAFFAQIBAABKgAFFAYIHQATAMgdAA==.兔子的小萨:BAABKgAFFH8HAAILAAQIBx2WCQALAQALAAQIBx2WCQALAQABKgAFFAYIHQATAMgdAA==.',['兜十']='兜十六:BAABKgAFFH8IAAIcAAQIUSTgGQD0AAAcAAQIUSTgGQD0AAAAAA==.兜十四:BAAAKgAECggICAAAAA==.',['兜里']='兜里有唐:BAAAKgADCggICAAAAA==.',['六合']='六合布武:BAAAKgAECgYIBwAAAA==.',['再见']='再见二丁目啊:BAAAKgAECggIAwAAAA==.',['农家']='农家肥:BAAAKgAECggIEAAAAA==.',['冰封']='冰封白菜:BAABKgAFFH8KAAMXAAYINRjuAABUAQAXAAUInxvuAABUAQADAAUIIRmCBQBOAQAAAA==.',['冰雪']='冰雪紫炎:BAAAKgAECgMIBAABKgAFFAcIMQALAKoZAA==.',['决弃']='决弃:BAAAKgADCgcIBwAAAA==.',['净莲']='净莲丶兰:BAAAKgAECgUIBgAAAA==.',['凉拌']='凉拌玛卡巴卡:BAAAKgAECgEIAQAAAA==.',['凌媚']='凌媚夜舞:BAAAKgAFFAgIBAAAAA==.凌媚靚菁:BAAAKgAECgEIAQAAAA==.',['刀口']='刀口舔血:BAAAKgAECgQIBAAAAA==.',['列兵']='列兵多斯:BAAAKgAFFAYIBAAAAA==.',['初十']='初十一:BAABKgAECn8XAAIdAAgIaBHaLACCAQAdAAgIaBHaLACCAQAAAA==.初十二:BAABKgAECn8eAAICAAYIFxPJNwAaAQACAAYIFxPJNwAaAQAAAA==.初十六:BAAAKgAECgQIBAAAAA==.初十四:BAAAKgAECgIIAgAAAA==.',['别了']='别了丶红顔:BAAAKgADCgMIAwAAAA==.',['剑剑']='剑剑:BAAAKgAECgUIBQAAAA==.',['剩骑']='剩骑士:BAAAKgAECgIIAgAAAA==.',['劣人']='劣人丨:BAAAKgAECgEIAQAAAA==.',['北风']='北风南方吹:BAAAKgAECgUIBQAAAA==.',['十月']='十月丶夜:BAAAKgAFFAQIBAAAAA==.',['华尔']='华尔街之娘:BAAAKgADCgEIAQAAAA==.',['南瓜']='南瓜:BAAAKgAFFAYIBAAAAA==.',['卟侍']='卟侍小紫啧:BAAAKgAECgIIAgAAAA==.',['卡奈']='卡奈丽:BAABKgAFFH8IAAIRAAgImwvpDQDDAQARAAgImwvpDQDDAQAAAA==.',['卡忙']='卡忙北北:BAAAKgAECggICgAAAA==.',['叁井']='叁井寿:BAABKgAFFH8HAAMEAAQIvBu+DQADAQAEAAMIvBu+DQADAQAGAAQI3AHCHgBoAAAAAA==.',['口袋']='口袋里有图腾:BAAAKgAECgIIAQAAAA==.',['史瑞']='史瑞克:BAABKgAFFH8QAAIDAAgIMRA5BgAMAgADAAgIMRA5BgAMAgAAAA==.',['司马']='司马莽夫:BAABKgAFFH8MAAMeAAYIVA74AgDxAAAeAAQI+BP4AgDxAAAGAAYIhAk9HADAAAAAAA==.',['吃草']='吃草的老虎:BAAAKgAECgYIBgAAAA==.',['吾爱']='吾爱丽曼:BAABKgAECn8cAAMMAAgI4RqOFwAOAgAMAAgI4RqOFwAOAgALAAYIaSOZJAD+AQAAAA==.',['呐丶']='呐丶别摸:BAAAKgAECgYICgAAAA==.',['呤狐']='呤狐冲:BAAAKgADCgQIBgAAAA==.',['周末']='周末去看海吧:BAAAKgADCgEIAQAAAA==.',['咩咩']='咩咩丶:BAAAKgADCgEIAQAAAA==.',['哈库']='哈库呐玛塔塔:BAACKgAFFH8FAAIfAAUIOx1BBgBjAQAfAAUIOx1BBgBjAQAqAAQKfxkAAh8ACAgDJPwEALUCAB8ACAgDJPwEALUCAAAA.',['哔哔']='哔哔吡吡:BAABKgAFFH8IAAISAAgIaB5kAgBFAgASAAgIaB5kAgBFAgAAAA==.',['唯有']='唯有少年心:BAAAKgAFFAQIBAAAAA==.',['啊吊']='啊吊:BAAAKgAECgcIBwABKgAFFAYIBgAKADQKAA==.',['喜多']='喜多川海梦:BAAAKgAFFAQIBAAAAA==.',['嘿丶']='嘿丶那个蛋:BAAAKgAFFAIIAgAAAA==.',['四季']='四季都冬至:BAAAKgADCgEIAQAAAA==.',['四川']='四川唯一狂少:BAAAKgAECgIIAgAAAA==.',['回家']='回家找妈:BAAAKgAECggICAAAAA==.',['图小']='图小奇:BAAAKgAECggICAAAAA==.',['圆滚']='圆滚滚:BAAAKgADCggICAAAAA==.',['國士']='國士無双:BAAAKgAFFAgIBAAAAA==.',['圣光']='圣光下沐浴:BAAAKgAECgQIBAAAAA==.圣光忽悠:BAAAKgADCggICAAAAA==.圣光忽悠了我:BAABKgAFFH8HAAIRAAQISw+6UQDMAAARAAQISw+6UQDMAAAAAA==.圣光救救我:BAACKgAFFH8LAAMRAAQIkBcFSgDaAAARAAMImRYFSgDaAAAgAAQIyhMYDAC9AAAqAAQKfxsAAyAABgh5HHQJAJsBACAABgh5HHQJAJsBABEABQjJCmwAAbYAAAAA.圣光有你:BAAAKgAECgQIBAAAAA==.圣光的抉择:BAABKgAFFH8lAAIgAAgIyQ3fBQCTAQAgAAgIyQ3fBQCTAQAAAA==.圣光空空:BAAAKgAECgIIAgAAAA==.',['圣灵']='圣灵空空:BAAAKgAECgEIAQAAAA==.',['地狱']='地狱丶咆哮:BAAAKgADCggIEAAAAA==.',['地球']='地球保护者:BAAAKgAECgcIDQAAAA==.',['埃辛']='埃辛诺斯丶刃:BAAAKgADCgcIBwAAAA==.',['堂小']='堂小小:BAABKgAFFH8GAAIWAAMILQpyHQCBAAAWAAMILQpyHQCBAAAAAA==.',['墓尸']='墓尸妹子:BAABKgAFFH8IAAIUAAgIqhxSAQBkAgAUAAgIqhxSAQBkAgAAAA==.',['多多']='多多綠少糖:BAAAKgAFFAgIAQABKgAFFAgICAARAJsLAA==.',['大学']='大学生:BAAAKgADCgcIBwAAAA==.',['大宝']='大宝是小猪:BAABKgAFFH8LAAMgAAgIchb2CQBdAQAgAAcIqw/2CQBdAQARAAQI/hb3MQAhAQAAAA==.',['大少']='大少爷会长:BAAAKgADCgQIBAAAAA==.',['大枭']='大枭:BAAAKgADCgMIAwAAAA==.',['大橙']='大橙小柚:BAAAKgAFFAMIAwAAAA==.',['大牛']='大牛牛:BAAAKgAECgEIAQAAAA==.',['大王']='大王饶命:BAAAKgADCgYIBwAAAA==.',['大白']='大白牛:BAAAKgADCgEIAQAAAA==.大白牛笨笨:BAABKgAFFH8JAAIZAAUImBGIFAAVAQAZAAUImBGIFAAVAQAAAA==.',['大耳']='大耳猫:BAAAKgADCgEIAQAAAA==.',['大酋']='大酋长雷德:BAAAKgAECgUIBgAAAA==.',['大鲸']='大鲸鱼:BAAAKgAECgQIBAAAAA==.',['天之']='天之壁垒:BAAAKgAFFAQIBAABKgAFFAgIEAATAFsKAA==.',['天亮']='天亮了:BAABKgAECn8YAAILAAgIKyPGDQCJAgALAAgIKyPGDQCJAgAAAA==.',['天使']='天使之翼:BAAAKgAECgcIEAAAAA==.',['天刑']='天刑客:BAABKgAFFH8IAAIVAAgINRytAwCDAgAVAAgINRytAwCDAgAAAA==.',['天字']='天字一号奶爸:BAAAKgAECgUIAQAAAA==.天字一号奶萨:BAAAKgADCgcIBwAAAA==.',['天界']='天界玛雅:BAAAKgAECgcIDgAAAA==.',['奈因']='奈因哈特:BAAAKgAECgcIEQAAAA==.',['奥罗']='奥罗拉丶血翼:BAAAKgAECggIDQAAAA==.',['奥蕾']='奥蕾风行者:BAAAKgADCgUIBQAAAA==.',['妖怪']='妖怪看招:BAAAKgAECgQIBAAAAA==.',['娘娘']='娘娘驾到:BAAAKgAECgYIBgAAAA==.',['宁萌']='宁萌:BAAAKgAECggICwAAAA==.',['宠臣']='宠臣:BAABKgAFFH8UAAICAAQI0hzhDQD2AAACAAQI0hzhDQD2AAAAAA==.',['宫下']='宫下玲奈:BAABKgAFFH8MAAMUAAYIVxhBAwB1AQAUAAUIgB1BAwB1AQATAAYI/wfJDwAKAQAAAA==.',['寂寞']='寂寞的丶想你:BAAAKgADCgMIBwAAAA==.寂寞的馒头:BAAAKgAECgYICAAAAA==.',['寒武']='寒武纪小法:BAAAKgAECgUIBQAAAA==.',['寒气']='寒气震四方:BAAAKgAECgQIBAAAAA==.',['射到']='射到你叫不敢:BAACKgAFFH8zAAMVAAYIbRczEQBuAQAVAAYIyxQzEQBuAQAWAAQIOhkyDgDhAAAqAAQKfykAAxYACAiQIvcOAGACABYACAiQIvcOAGACABUAAwhwFGGoANUAAAAA.',['小丿']='小丿橙子:BAABKgAFFH8IAAIVAAYI8wm7JADBAAAVAAYI8wm7JADBAAAAAA==.',['小乔']='小乔不会戦士:BAAAKgADCggICAAAAA==.小乔不会死骑:BAAAKgAECgYICwAAAA==.',['小医']='小医仙:BAAAKgAFFAIIAgAAAA==.',['小十']='小十九:BAABKgAFFH8GAAIIAAYIQggCCADoAAAIAAYIQggCCADoAAAAAA==.',['小堂']='小堂:BAAAKgAECgYIBgAAAA==.',['小婧']='小婧嫣:BAABKgAFFH8GAAMCAAYIXxqsBgBhAQACAAUIjiCsBgBhAQABAAEIpQETSgAjAAAAAA==.',['小小']='小小晨丨:BAAAKgAFFAUIBAAAAA==.',['小晴']='小晴晴:BAAAKgAECgcIBwAAAA==.',['小猫']='小猫钓鱼:BAAAKgADCgEIAQAAAA==.',['小红']='小红手猴吉:BAAAKgADCggICAAAAA==.',['小龙']='小龙翅膀:BAABKgAECn8bAAMdAAgIIBvvIADLAQAdAAcIoBzvIADLAQAHAAYIjRDgLwAUAQAAAA==.',['尐尐']='尐尐丨沭士:BAAAKgAECgQIBgAAAA==.',['尕疼']='尕疼疼:BAABKgAFFH8MAAIKAAQI4xpbDAAUAQAKAAQI4xpbDAAUAQAAAA==.',['尘埃']='尘埃丶落:BAAAKgAECggIAgAAAA==.',['尤涅']='尤涅若:BAABKgAFFH8IAAIdAAgI3weqBwDnAQAdAAgI3weqBwDnAQAAAA==.',['尼古']='尼古拉斯悟净:BAAAKgADCgQIBAAAAA==.',['山总']='山总:BAABKgAECn8VAAMTAAgIjQoeMQANAQATAAgIjQoeMQANAQAUAAgIeAjfPwDsAAAAAA==.',['巅峰']='巅峰灬猴子:BAAAKgADCgEIAQAAAA==.',['巷牙']='巷牙山李桂兰:BAABKgAECn8bAAQXAAgInRZEFwC+AQAXAAgInRZEFwC+AQADAAcICAiEZADfAAAYAAEIRQFGSAAJAAAAAA==.',['帅胡']='帅胡:BAAAKgAECgEIAQAAAA==.',['帕瑟']='帕瑟妮丶影歌:BAAAKgAFFAMIAwAAAA==.',['帝国']='帝国圣光:BAAAKgADCgEIAQAAAA==.',['幸运']='幸运猪:BAAAKgADCggIGAAAAA==.',['库卡']='库卡隆精英:BAAAKgAECgcICAAAAA==.',['张三']='张三疯:BAAAKgAECgYIDgAAAA==.',['彩十']='彩十球:BAAAKgADCgQIBAAAAA==.',['微尘']='微尘:BAAAKgAECggICgAAAA==.',['微微']='微微一笑:BAAAKgAECgQIBQAAAA==.',['德尔']='德尔蹄:BAABKgAFFH8ZAAMfAAQItB0VBwAKAQAfAAMItB0VBwAKAQAZAAQILRfqMADSAAAAAA==.',['心有']='心有光明:BAABKgAFFH8aAAMUAAMIuw+0HwCkAAAUAAMISw60HwCkAAASAAIIdQ23GwB4AAAAAA==.',['忐忐']='忐忐一忑忑:BAAAKgAFFAQIAwAAAA==.',['快乐']='快乐的小幸福:BAAAKgAECggIDQAAAA==.',['怎能']='怎能没有我:BAAAKgAECggICQAAAA==.',['感动']='感动狗狗:BAABKgAECn8bAAQdAAgIwBjZLADUAQAdAAgIIxjZLADUAQAHAAcIMwvHQQDOAAAIAAMIhAStSQAxAAAAAA==.',['愤怒']='愤怒的奇异果:BAACKgAFFH8qAAMPAAgIyQsCAgB5AQAPAAgIyQsCAgB5AQAaAAEIlwQXMwA8AAAqAAQKfyIAAw8ACAjHGk0JANMBAA8ACAjHGk0JANMBAA4ABgifE9Y+ABUBAAAA.愤怒的机器猫:BAAAKgADCgIIAgAAAA==.',['愿圣']='愿圣光忽悠你:BAAAKgAECgIIAgAAAA==.',['慕氏']='慕氏统领:BAAAKgADCggICAAAAA==.',['我不']='我不会用刀桶:BAABKgAFFH8IAAQYAAYIKBoWBAAPAQAYAAMIsyIWBAAPAQADAAMIoxdlDgDwAAAXAAIIWhTsEgBZAAAAAA==.我不想玩奶:BAABKgAFFH8GAAIfAAYIRBEQDQA6AQAfAAYIRBEQDQA6AQAAAA==.我不瞎好吗:BAAAKgADCgUIBQAAAA==.',['我们']='我们很年轻:BAAAKgADCgYIBgAAAA==.',['我即']='我即是暗裔:BAAAKgAECgYICQAAAA==.',['我叫']='我叫小茶树菇:BAABKgAFFH8IAAIBAAgIDRTdBgAWAgABAAgIDRTdBgAWAgAAAA==.',['我天']='我天下无敌啦:BAAAKgAFFAQIBAAAAA==.',['我活']='我活在梦里:BAAAKgAFFAQIAgAAAA==.',['戦無']='戦無义:BAABKgAFFH8IAAIIAAQIZQ+yCACaAAAIAAQIZQ+yCACaAAAAAA==.',['扶风']='扶风:BAABKgAFFH8NAAIEAAYIsxV1FgBpAQAEAAYIsxV1FgBpAQAAAA==.',['拉钢']='拉钢同丶学:BAAAKgAECggIDwAAAA==.拉钢同丶志:BAABKgAECn8vAAIVAAgIpSILCACRAgAVAAgIpSILCACRAgAAAA==.',['排了']='排了个骨:BAAAKgAECgUIBQAAAA==.',['放心']='放心有我:BAABKgAECn8wAAMSAAcItxivMACAAQASAAcItxivMACAAQAUAAMIKwpVhQBIAAAAAA==.',['文泰']='文泰来:BAAAKgAFFAIIBAAAAA==.',['施暴']='施暴者:BAAAKgAECgYIBgAAAA==.',['无忧']='无忧:BAAAKgAFFAYIBAABKgAFFAgICAALALsbAA==.',['明儿']='明儿个十五:BAAAKgAECgYIBgAAAA==.',['明月']='明月春光:BAAAKgAFFAQIBAAAAA==.',['昏整']='昏整灬:BAABKgAFFH8QAAIEAAgIShdqBwAbAgAEAAgIShdqBwAbAgAAAA==.',['星光']='星光龙:BAAAKgAECgYICgAAAA==.',['星见']='星见雅:BAAAKgAECggICAAAAA==.',['晴天']='晴天放风筝:BAAAKgAECgEIAQAAAA==.',['智慧']='智慧:BAABKgAECn8UAAICAAcI5AwOPAAEAQACAAcI5AwOPAAEAQAAAA==.',['曦曦']='曦曦大魔王:BAAAKgADCgMIAwAAAA==.',['曦月']='曦月:BAAAKgAFFAQIBAAAAA==.',['曹兔']='曹兔子:BAAAKgAECggICAABKgAFFAYIHQATAMgdAA==.',['曼珠']='曼珠灬沙华:BAAAKgAECggIEAAAAA==.',['曾照']='曾照彩云归:BAAAKgADCgYIBgAAAA==.',['替身']='替身使者:BAAAKgAECggICAAAAA==.',['最爱']='最爱水瓶座:BAABKgAECn8cAAIWAAgI3B4AFABZAgAWAAgI3B4AFABZAgAAAA==.',['月城']='月城柳:BAABKgAFFH8KAAILAAgI8gk4CQCzAQALAAgI8gk4CQCzAQAAAA==.',['有丸']='有丸没完:BAABKgAFFH8ZAAIRAAQIKRbcIQDfAAARAAQIKRbcIQDfAAAAAA==.',['有德']='有德便有奶:BAABKgAFFH8FAAIZAAUIhxaaIAAcAQAZAAUIhxaaIAAcAQAAAA==.',['服部']='服部半藏森林:BAABKgAFFH8GAAIRAAYIaRBEIwBfAQARAAYIaRBEIwBfAQAAAA==.',['木鱼']='木鱼:BAAAKgAECgUIDAAAAA==.木鱼哥哥:BAAAKgAECgcIDwAAAA==.',['末南']='末南未北:BAAAKgADCgMIAwAAAA==.',['杜鹃']='杜鹃恨啼作血:BAAAKgADCggIGQAAAA==.',['来了']='来了来了:BAAAKgADCgIIAgAAAA==.',['杨总']='杨总:BAAAKgAECgYICAAAAA==.',['杨永']='杨永信:BAAAKgAFFAMIAwAAAA==.',['柒零']='柒零柒:BAABKgAFFH8IAAMLAAQIgw49GwCdAAALAAQIgw49GwCdAAAMAAQInQeLHAA9AAAAAA==.',['树语']='树语兀:BAAAKgAFFAQIBAAAAA==.',['格林']='格林丶怒风:BAAAKgAECggICQAAAA==.',['格萨']='格萨拉克:BAAAKgAECgMIAwAAAA==.',['梅子']='梅子绿茶:BAACKgAFFH8FAAISAAMI3wZjGAB8AAASAAMI3wZjGAB8AAAqAAQKfx0AAxQACAhaEtoOAE4BABQABwgjFdoOAE4BABIABgjbBL98AGsAAAAA.',['梦为']='梦为鱼:BAAAKgADCgIIAgAAAA==.',['梦里']='梦里灬圣光:BAACKgAFFH8GAAIgAAIIAQS+FQBSAAAgAAIIAQS+FQBSAAAqAAQKfyMAAiAACAj2E4UbAIUBACAACAj2E4UbAIUBAAAA.梦里灬战嗜:BAAAKgAECgUIBQAAAA==.',['森森']='森森:BAAAKgADCggICAAAAA==.',['楪祈']='楪祈吖丶:BAAAKgAECgMIAwAAAA==.',['欧根']='欧根亲王:BAAAKgAECgQIBAAAAA==.',['殷血']='殷血修罗:BAAAKgADCggICAAAAA==.',['永不']='永不独行:BAAAKgAECgQIBAAAAA==.',['没吃']='没吃饭么:BAAAKgAECgQIAwAAAA==.',['法兰']='法兰克福:BAABKgAECn8WAAMNAAgI9RzAEAAfAgANAAgIBhzAEAAfAgAKAAcIJBXITgBsAQAAAA==.',['法爷']='法爷魔士:BAAAKgAECgMIAwAAAA==.',['洛丶']='洛丶克:BAAAKgAECggIAwAAAA==.',['流星']='流星的星空:BAAAKgADCggICAAAAA==.',['流浪']='流浪猫:BAAAKgAECgUIBQAAAA==.',['海的']='海的天空:BAAAKgAECgYIBgAAAA==.',['清风']='清风小雨:BAAAKgADCggIDwAAAA==.',['温酒']='温酒待故人:BAAAKgAECggIDAAAAA==.',['游戏']='游戏可乐瓶:BAAAKgAECgIIAgAAAA==.',['滴水']='滴水光头:BAAAKgAECgIIAwAAAA==.',['潇湘']='潇湘夜雨:BAAAKgAECggICgAAAA==.',['潜龙']='潜龙勿用:BAAAKgAECgQIBAAAAA==.',['火炎']='火炎之歌:BAAAKgADCgIIAgAAAA==.',['灬姑']='灬姑姑灬:BAAAKgAFFAIIAgAAAA==.',['灬缺']='灬缺德灬:BAAAKgADCggICAAAAA==.',['灭龙']='灭龙丶魔导士:BAAAKgAECgIIAgAAAA==.',['灰机']='灰机带翅膀:BAAAKgADCgYIBgAAAA==.',['点点']='点点滴滴:BAAAKgADCgEIAQAAAA==.',['烂肉']='烂肉格及不:BAABKgAFFH8FAAIKAAUIhQnTJQDgAAAKAAUIhQnTJQDgAAAAAA==.',['熊五']='熊五爷:BAAAKgAECggICAAAAA==.',['熊熊']='熊熊族:BAAAKgAECggICAAAAA==.',['熊貓']='熊貓阿宝:BAAAKgAECggICAAAAA==.',['牙生']='牙生江铁拳:BAAAKgAECgMIAwAAAA==.',['牛二']='牛二:BAABKgAECn8WAAIVAAYIURIYbgAMAQAVAAYIURIYbgAMAQAAAA==.',['牛尾']='牛尾巴毛:BAAAKgADCggICAAAAA==.',['牛肉']='牛肉意面:BAABKgAFFH8PAAMGAAcItRXyBACVAQAGAAcIgBXyBACVAQAEAAQIiRCMFgDdAAABKgAFFAgIAgAbAAAAAA==.',['牢大']='牢大:BAAAKgAECggIEAAAAA==.',['牧奶']='牧奶医丶:BAABKgAECn8VAAISAAgI1xnfGgD/AQASAAgI1xnfGgD/AQAAAA==.',['牧紳']='牧紳壹:BAABKgAFFH8IAAMSAAgIJhZaCACiAQASAAcIrhRaCACiAQATAAEITxCiKgBIAAAAAA==.',['狂躁']='狂躁的开膛手:BAAAKgADCgYIBgAAAA==.',['狄娜']='狄娜:BAABKgAFFH8JAAIKAAMIkQ+8GADHAAAKAAMIkQ+8GADHAAAAAA==.',['狗儿']='狗儿蛋:BAAAKgAECgIIAwAAAA==.',['狗狗']='狗狗感动了:BAAAKgAECggIDAAAAA==.',['狗蛋']='狗蛋:BAABKgAFFH8MAAQYAAYI6BcABQAFAQADAAYIoBSoFwBGAQAYAAUI3BgABQAFAQAXAAEIFwgELABDAAAAAA==.',['猜不']='猜不透表情:BAAAKgAFFAYIBAAAAA==.',['玉米']='玉米的仓库:BAAAKgAECggIDwAAAA==.',['王者']='王者圣光:BAAAKgADCggICAAAAA==.王者绝非偶然:BAAAKgAECgIIAgAAAA==.',['玩笑']='玩笑:BAAAKgADCgYICQAAAA==.',['珍泥']='珍泥马代劲:BAAAKgADCggICAAAAA==.',['用九']='用九:BAAAKgAECggICAAAAA==.',['白夜']='白夜守心:BAAAKgAECgEIAQAAAA==.',['白飞']='白飞飞:BAAAKgAFFAQIBAAAAA==.',['百年']='百年孤寂:BAAAKgAECgIIAgAAAA==.',['盖世']='盖世丶萝莉:BAAAKgAECgEIAQAAAA==.盖世灬蘿莉:BAAAKgAFFAQIBAAAAA==.',['省外']='省外来颗呆萌:BAABKgAECn8dAAMWAAgIQRpSFACSAQAVAAgIahYZSADcAQAWAAgI2RVSFACSAQAAAA==.',['眨眼']='眨眼:BAAAKgADCgQIBAAAAA==.',['睿睿']='睿睿爱吃肉:BAABKgAECn8UAAIEAAgINhbsPAC9AQAEAAgINhbsPAC9AQAAAA==.',['碧落']='碧落红尘丶:BAAAKgAFFAcIAgAAAA==.',['祖宗']='祖宗保佑我:BAABKgAECn8XAAMhAAYI7wwENQAcAQAhAAYIugsENQAcAQAMAAUIAA0NUgC0AAAAAA==.',['神射']='神射丨山胖:BAAAKgAECggICAAAAA==.',['神话']='神话步兵:BAACKgAFFH8gAAIVAAQITRGAGQDHAAAVAAQITRGAGQDHAAAqAAQKfx4AAhUACAitGS84AMQBABUACAitGS84AMQBAAEqAAUUBQgdAAQAPhMA.神话游侠:BAACKgAFFH8jAAILAAQI8B3OIgDtAAALAAQI8B3OIgDtAAAqAAQKfykAAgsACAjqHzkPAHQCAAsACAjqHzkPAHQCAAEqAAUUBQgdAAQAPhMA.神话熊猫:BAACKgAFFH8dAAIEAAUIPhOKDwD8AAAEAAUIPhOKDwD8AAAqAAQKfzoAAwQACAhcH/wTAGwCAAQACAhcH/wTAGwCAAYABggRDT0wANEAAAAA.',['神静']='神静:BAAAKgAECgMIAwAAAA==.',['祭司']='祭司:BAABKgAECn8YAAILAAgI3xvpLgDNAQALAAgI3xvpLgDNAQAAAA==.',['禁忌']='禁忌之兰:BAAAKgAFFAgIBAAAAA==.',['秉冰']='秉冰病兵:BAAAKgAECgQIBAAAAA==.',['秋落']='秋落灬花无依:BAAAKgADCggICAAAAA==.',['秋风']='秋风落枼:BAAAKgADCggICAAAAA==.',['秒天']='秒天地秒空气:BAAAKgAECgUIAQAAAA==.',['空空']='空空丶:BAAAKgAECgIIBAAAAA==.',['空竹']='空竹幽兰:BAAAKgAECgQIBAAAAA==.',['笑三']='笑三邪:BAAAKgADCgIIAgAAAA==.',['笑看']='笑看往事:BAAAKgAECggIEAAAAA==.',['等我']='等我插个棍:BAAAKgAECgYIBwAAAA==.',['等月']='等月光落雪地:BAABKgAFFH8WAAMNAAYIAhpFBAB2AQANAAYIAhpFBAB2AQAKAAYIyA3SFQBMAQAAAA==.',['简单']='简单一嚸:BAAAKgADCgQIBAAAAA==.简单的一天:BAABKgAFFH8RAAMSAAgIFSFwAQCUAgASAAgIFSFwAQCUAgATAAEIPBz2JwBSAAAAAA==.',['米斯']='米斯特汀:BAACKgAFFH8KAAIWAAYICxHoDgAKAQAWAAYICxHoDgAKAQAqAAQKfyMAAxYACAiWHzYXAD4CABYACAiWHzYXAD4CABUAAQiBGEX+ADsAAAAA.',['米粒']='米粒之光:BAAAKgADCgMIAwAAAA==.',['索兰']='索兰尼亚:BAAAKgADCggICAAAAA==.',['紫弦']='紫弦月:BAABKgAFFH8GAAIVAAYI9xqrEQBqAQAVAAYI9xqrEQBqAQAAAA==.',['紫瞳']='紫瞳小囧:BAABKgAFFH8IAAMCAAgIJAf0EgDNAAACAAUIRwr0EgDNAAABAAMI9gJwNACQAAAAAA==.',['红发']='红发有娜:BAAAKgADCgMIAwAAAA==.',['红孩']='红孩儿的小妈:BAAAKgAECgYIBgAAAA==.',['红蔷']='红蔷:BAAAKgAFFAUIAgAAAA==.',['纥那']='纥那:BAAAKgAECggICAAAAA==.',['纱布']='纱布尼古拉斯:BAAAKgAECgEIAQAAAA==.',['群星']='群星陨落:BAAAKgAECggICAAAAA==.',['羽落']='羽落丶壹壹:BAAAKgAECgUIBQAAAA==.',['翡翠']='翡翠:BAAAKgAECgEIAQAAAA==.',['肖恩']='肖恩康纳朗:BAAAKgAFFAEIAQAAAA==.',['胡来']='胡来的瞎王:BAAAKgAECgIIBQAAAA==.',['能奶']='能奶能打:BAABKgAECn8YAAMSAAgIlhtCJwCzAQASAAYIxSBCJwCzAQAUAAgIpg1tMQAxAQAAAA==.',['脸红']='脸红的发紫:BAABKgAFFH8IAAIGAAgI7w0rCQCDAQAGAAgI7w0rCQCDAQAAAA==.',['腹黑']='腹黑的猫:BAABKgAFFH8IAAIRAAQISRRXGgD2AAARAAQISRRXGgD2AAAAAA==.',['艾星']='艾星守护者:BAABKgAFFH8HAAMCAAQIUyJ1FADFAAAFAAQIKhvkGQDaAAACAAMIpCR1FADFAAAAAA==.',['芒果']='芒果喵喵:BAABKgAFFH8MAAIUAAYIfhCKBABNAQAUAAYIfhCKBABNAQAAAA==.',['若有']='若有若無:BAAAKgADCgUIBQAAAA==.',['若静']='若静沫筱雪:BAAAKgADCgUIBQAAAA==.',['荒天']='荒天帝:BAAAKgADCggICAAAAA==.',['荠菜']='荠菜水饺:BAAAKgAECgYIDAAAAA==.',['荣誉']='荣誉大酋长:BAAAKgAECgUIBQAAAA==.',['菠萝']='菠萝爷蛋总:BAABKgAFFH8IAAISAAgIzBN1BADlAQASAAgIzBN1BADlAQAAAA==.',['萨满']='萨满拉面熊:BAAAKgAECgQICAAAAA==.',['落雨']='落雨无声:BAAAKgAECgcIBwAAAA==.',['落霞']='落霞孤鹜:BAAAKgAECgIIBAAAAA==.',['葬送']='葬送的福利莲:BAAAKgAECgEIAQAAAA==.',['葵花']='葵花:BAAAKgAFFAgIBAAAAA==.',['蒙牛']='蒙牛三三雨:BAAAKgAECggICAAAAA==.',['蓝澄']='蓝澄:BAAAKgADCggIEwAAAA==.',['蓝皮']='蓝皮鼠:BAAAKgAFFAgIAQAAAA==.',['蓝色']='蓝色记忆:BAAAKgAECgcIEAAAAA==.',['薯条']='薯条是只猫:BAAAKgAFFAgIAQAAAA==.',['血丶']='血丶姬:BAAAKgAECgIIAwAAAA==.',['血之']='血之神翼:BAAAKgAECgUIBQAAAA==.',['血煞']='血煞魔君:BAACKgAFFH8IAAIdAAQIISJRGAD4AAAdAAQIISJRGAD4AAAqAAQKfyAAAh0ACAh4H3cRAHoCAB0ACAh4H3cRAHoCAAAA.',['血色']='血色郁金香:BAAAKgAECggICAAAAA==.',['西爷']='西爷:BAABKgAECn8hAAMIAAgIsAo/EwDdAAAIAAgI6Qk/EwDdAAAdAAYInAmHTgDVAAAAAA==.',['西西']='西西弗斯:BAAAKgAECgEIAQAAAA==.',['订书']='订书机:BAAAKgAECgUIBQAAAA==.订书针:BAAAKgADCggIDQAAAA==.',['让我']='让我进隐:BAAAKgADCgIIAgAAAA==.',['诗卧']='诗卧妲雕:BAABKgAECn8UAAIDAAgIBiWTAgDzAgADAAgIBiWTAgDzAgABKgAFFAgIBgABAHkmAA==.',['请伊']='请伊切桑活:BAACKgAFFH8JAAIVAAMIYxJzGQDIAAAVAAMIYxJzGQDIAAAqAAQKfyAAAxUACAgsHloeAEkCABUACAhEHVoeAEkCABYABQjbFJNZAO0AAAAA.',['请侬']='请侬切生活:BAABKgAECn8XAAIZAAgIdxXhEgDLAQAZAAgIdxXhEgDLAQAAAA==.',['诺铭']='诺铭丨咻:BAAAKgAECgIIAgAAAA==.',['谷尓']='谷尓单:BAAAKgADCgEIAQAAAA==.',['贝壳']='贝壳丶:BAAAKgAECgUIAQAAAA==.',['贝德']='贝德维尔:BAAAKgADCggICAAAAA==.',['超级']='超级皮卡丘:BAAAKgAECgIIAgAAAA==.',['路边']='路边一条:BAAAKgAECgQIBAAAAA==.',['跳外']='跳外八:BAAAKgADCgYIBgAAAA==.',['踏宴']='踏宴:BAAAKgAFFAIIAgAAAA==.',['车底']='车底战神:BAAAKgAECgcIDAAAAA==.',['轻水']='轻水远林:BAAAKgAECggICwAAAA==.',['辛德']='辛德拉:BAABKgAFFH8GAAIDAAYIEBJ0MgCmAAADAAYIEBJ0MgCmAAAAAA==.',['辣条']='辣条是只喵:BAAAKgAFFAQIBAAAAA==.',['辣脆']='辣脆:BAAAKgAECgYIBgAAAA==.',['近视']='近视三千度:BAABKgAFFH8IAAIKAAQIkA9QIAC6AAAKAAQIkA9QIAC6AAAAAA==.',['迪娜']='迪娜:BAABKgAFFH8RAAIRAAMIzBrZPwDyAAARAAMIzBrZPwDyAAAAAA==.',['迪菲']='迪菲亚:BAAAKgADCggICAAAAA==.',['迷失']='迷失的季节:BAAAKgAECgQIBAAAAA==.',['迷雾']='迷雾老登:BAAAKgAECgMIAwAAAA==.',['追丶']='追丶风:BAACKgAFFH8WAAIVAAQIOSCrIwD5AAAVAAQIOSCrIwD5AAAqAAQKfzwAAxUACAgkIggVAIUCABUACAgkIggVAIUCABYABgjIEmRTAM8AAAAA.',['追光']='追光:BAACKgAFFH8MAAMVAAQIVx2qEQAKAQAVAAQIVx2qEQAKAQAWAAEIFgnhUgA0AAAqAAQKfyIAAhUACAihITYlACICABUACAihITYlACICAAAA.',['追随']='追随寂寞:BAAAKgAFFAYIBAAAAA==.',['逃跑']='逃跑的太阳:BAABKgAFFH8IAAMWAAQIsCJdFwCnAAAVAAMIuyIsNgC8AAAWAAQIQBxdFwCnAAAAAA==.',['邪恶']='邪恶老师:BAAAKgAFFAMIAwAAAA==.',['邪能']='邪能小红蹄:BAAAKgAECgUIBQAAAA==.',['邪钉']='邪钉横辉:BAABKgAECn8bAAIZAAgIWBg5LgD1AQAZAAgIWBg5LgD1AQAAAA==.',['郑菲']='郑菲翠:BAAAKgAECgYIEQAAAA==.',['部落']='部落勇士:BAAAKgAFFAQIBAAAAA==.',['酒鬼']='酒鬼丶:BAAAKgAECggIEAAAAA==.',['醉夜']='醉夜迷香:BAAAKgAECgEIAQAAAA==.',['重拳']='重拳的回忆:BAAAKgADCggICAAAAA==.',['重案']='重案组之虎:BAABKgAFFH8LAAMBAAMICxKtAgDMAAABAAMI9A+tAgDMAAACAAEI9AyRLQAzAAAAAA==.',['重阳']='重阳:BAAAKgADCgIIAgAAAA==.',['银月']='银月昊天:BAAAKgAECggIBQAAAA==.银月梓沬:BAAAKgADCggICAAAAA==.',['铸星']='铸星砧台:BAAAKgADCgYIBgAAAA==.',['闪避']='闪避王川噗:BAABKgAFFH8QAAMDAAYILCDNBABgAQADAAUIxCLNBABgAQAXAAIIzBVVFgBPAAAAAA==.',['阳光']='阳光彩虹神龙:BAAAKgADCgEIAQAAAA==.',['阿兜']='阿兜兜:BAAAKgAFFAQIBAAAAA==.',['阿匹']='阿匹斯:BAAAKgAECgEIAQAAAA==.',['阿布']='阿布都飞腿:BAAAKgADCgYIBgAAAA==.',['阿鑫']='阿鑫要冷静:BAAAKgADCgcIBwAAAA==.',['阿雕']='阿雕:BAAAKgADCgQIBAAAAA==.',['陌上']='陌上君如雪:BAAAKgAFFAIIAgAAAA==.',['集火']='集火我:BAABKgAFFH8IAAIUAAgImhMfBAAPAgAUAAgImhMfBAAPAgAAAA==.',['雷电']='雷电将军:BAAAKgAFFAQIBAAAAA==.',['雷霆']='雷霆之戮:BAAAKgAECgIIAgAAAA==.雷霆风暴:BAAAKgADCgQIBAAAAA==.',['霧灬']='霧灬無邪:BAAAKgAFFAgIBAAAAA==.',['青春']='青春如此短暂:BAAAKgADCgEIAQAAAA==.青春留不住:BAABKgAFFH8GAAIHAAYIdhrgBgCpAQAHAAYIdhrgBgCpAQAAAA==.',['韩婉']='韩婉君:BAAAKgAFFAEIAQAAAA==.',['順唭']='順唭自然:BAAAKgADCggICAAAAA==.',['顺淇']='顺淇頿然:BAAAKgAECgEIAQAAAA==.',['風流']='風流風騷德:BAAAKgAECgEIAQAAAA==.',['風熄']='風熄箭吟:BAAAKgAECgQIBAAAAA==.',['风之']='风之卓绝:BAAAKgAECgYIDAAAAA==.',['风暴']='风暴烈酒:BAAAKgADCgMIAwAAAA==.',['风流']='风流夜夜浪:BAABKgAFFH8FAAMXAAQIswPIGgB8AAAXAAQIswPIGgB8AAADAAEIAABdPAAAAAAAAA==.',['飞机']='飞机皮沙发:BAAAKgAECggIDQAAAA==.',['魔云']='魔云金翅:BAAAKgAECgYIBAAAAA==.',['鸟人']='鸟人:BAAAKgAECgIIAgAAAA==.',['鸾凤']='鸾凤和鸣:BAABKgAFFH8MAAIFAAYIUBQaDgBbAQAFAAYIUBQaDgBbAQAAAA==.',['麻辣']='麻辣鸡:BAAAKgAECgQIBgAAAA==.',['黄灰']='黄灰灰:BAABKgAFFH8OAAILAAYImw6DFQAuAQALAAYImw6DFQAuAQAAAA==.',['黑九']='黑九:BAAAKgAECggICAAAAA==.',['齐大']='齐大王丶:BAAAKgAECgYIDAAAAA==.',['龙人']='龙人老登:BAAAKgAECgUIBQAAAA==.',['龙傲']='龙傲师:BAAAKgADCgMIAwAAAA==.',['龙象']='龙象般若猫:BAABKgAFFH8MAAIOAAgIzQ/8BADtAQAOAAgIzQ/8BADtAQAAAA==.',['龙龙']='龙龙得意:BAABKgAFFH8IAAMTAAYI8xrVCgBSAQATAAYI8xrVCgBSAQAUAAIIxxB8FQCzAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end