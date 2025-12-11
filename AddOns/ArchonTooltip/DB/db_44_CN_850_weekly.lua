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
 local lookup = {'Evoker-Augmentation','Evoker-Devastation','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Preservation','Mage-Arcane','Druid-Restoration','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Blood','Paladin-Holy','Shaman-Restoration','Shaman-Elemental','Rogue-Assassination','Rogue-Subtlety','DemonHunter-Havoc','Warlock-Destruction','Warlock-Demonology','Monk-Mistweaver','Warrior-Protection','Priest-Holy','Mage-Frost','Mage-Fire','DeathKnight-Unholy','Druid-Guardian','Druid-Balance','Unknown-Unknown','DemonHunter-Vengeance','Hunter-Survival','Warrior-Fury','Priest-Shadow',}; local provider = {region='CN',realm='逐日者',name='CN',type='weekly',zone=44,date='2025-12-09',data={Be='Bearchief:BAAALAAECgYIDAAAAA==.',Br='Brick:BAABLAAECn8gAAMBAAgIKSEFAwDJAgABAAgIFSEFAwDJAgACAAgIHBybFACIAgABLAAFFAgIQwACAEUeAA==.',Df='Df:BAAALAAECgYIBgAAAA==.',Ea='Earthspirit:BAAALAAECgEIAQAAAA==.',Em='Emmy:BAAALAAECggIAQAAAA==.',Et='Eternalia:BAAALAAECggICAAAAA==.',Ev='Evilddkdming:BAAALAAFFAIIAwAAAA==.',Gi='Girulian:BAAALAAFFAMIBAAAAA==.',Hi='Hi:BAAALAAECgMIAwAAAA==.',Ht='Htlr:BAAALAADCgYIBgAAAA==.',Je='Jeanreno:BAAALAAFFAYIAwAAAA==.',Ki='Kirby:BAABLAAFFH8gAAMDAAYIQBkrLACIAQADAAYIQBkrLACIAQAEAAIIFw7yKAB2AAAAAA==.',Ku='Kuro:BAAALAAECgUIBQAAAA==.',La='Lampe:BAAALAAECgYIBgAAAA==.',Lo='Loved:BAABLAAFFH8GAAQCAAIIsBkIGgCLAAACAAIIOxMIGgCLAAABAAEIGxhQCwBQAAAFAAEIzQ5IGwBGAAABLAAFFAgIQwACAEUeAA==.',Lu='Lulu:BAAALAAECgIIAgAAAA==.Luna:BAAALAAECggICAAAAA==.',Ma='Manastorm:BAAALAAECgYICAAAAA==.Maxmage:BAABLAAFFH8FAAIGAAIIPhu5OgCmAAAGAAIIPhu5OgCmAAAAAA==.',Me='Mercuriai:BAAALAAECgYICgAAAA==.',Mi='Mikoto:BAAALAAFFAIIBAAAAA==.',Ne='Nemesis:BAAALAADCgEIAQAAAA==.',Oa='Oathes:BAAALAAECgYICgAAAA==.',Ok='Ok:BAAALAAECgYIBgAAAA==.',On='Onion:BAABLAAECn8dAAMFAAgI4iGjBAD8AgAFAAgI4iGjBAD8AgACAAgI+Rt1GwBDAgABLAAFFAgIQwACAEUeAA==.',So='Sophia:BAAALAAECgYIBgAAAA==.',Ul='Ulbertallen:BAAALAAECgMIBAAAAA==.',Ve='Vegetable:BAAALAAECgUIAQAAAA==.',Wa='Wander:BAAALAAECgYIBgAAAA==.',We='Weather:BAABLAAFFH8fAAIDAAYIEiO0EQACAgADAAYIEiO0EQACAgAAAA==.',Yc='Yccwarlock:BAAALAADCgUIBQAAAA==.',Yo='Yougodie:BAAALAAECgUIBQAAAA==.',['一字']='一字齐肩王:BAAALAAECgYICAAAAA==.',['一归']='一归来一:BAAALAAECgYIBgAAAA==.',['一战']='一战傲天一:BAAALAAECgYIBgAAAA==.',['一日']='一日月一:BAAALAAECgEIAQAAAA==.',['一粒']='一粒麦芽糖:BAAALAAECgIIAgAAAA==.',['一精']='一精灵一:BAAALAAECgUIBQAAAA==.',['一花']='一花一叶:BAAALAAFFAIIAgAAAA==.一花一草:BAAALAAFFAIIBAAAAA==.',['一龍']='一龍傲天一:BAAALAAECgEIAQAAAA==.',['七星']='七星瓢虫:BAAALAAECgYIBgAAAA==.',['上古']='上古伽椰子:BAAALAAECgIIAgAAAA==.',['上头']='上头猫:BAAALAAECgQIBQAAAA==.',['不会']='不会战复:BAABLAAFFH8IAAIDAAIIHRjlTACYAAADAAIIHRjlTACYAAAAAA==.',['不朽']='不朽的温柔:BAAALAADCgIIAgAAAA==.',['不要']='不要批呱卵呱:BAAALAAECgYICwAAAA==.',['乂落']='乂落落乂:BAAALAAECgQIBAAAAA==.',['乄晨']='乄晨乄曦乄:BAAALAAFFAMIBAAAAA==.',['乄魑']='乄魑魅乄:BAAALAAFFAIIBAAAAA==.',['么么']='么么灵:BAAALAAECgYIBgAAAA==.',['乔碧']='乔碧萝:BAABLAAFFH8QAAIHAAIIqSRDKQDSAAAHAAIIqSRDKQDSAAAAAA==.',['二三']='二三一:BAAALAADCgYIBgAAAA==.',['二手']='二手烟:BAAALAAECgQIBQAAAA==.',['云倾']='云倾城:BAABLAAFFH8GAAIIAAIIWg3ETwCSAAAIAAIIWg3ETwCSAAAAAA==.',['亚洲']='亚洲砍王灬:BAABLAAFFH8FAAMJAAIIZCE4OQC/AAAJAAIIZCE4OQC/AAAKAAEIpwMfGQAwAAAAAA==.',['今夜']='今夜吥想睡:BAAALAADCgMIAwAAAA==.',['他朝']='他朝同淋雪:BAAALAAFFAEIAgAAAA==.',['伊露']='伊露伊:BAAALAAECgcIBwAAAA==.',['会打']='会打会加:BAAALAAECgIIAgAAAA==.',['你点']='你点到我了:BAAALAAFFAMIAwAAAA==.',['佳熙']='佳熙:BAABLAAECn8kAAMIAAYIZSGALADjAQAIAAYIZSGALADjAQALAAYIeRuAEgDVAQABLAAFFAgINwAJAFgkAA==.',['依然']='依然饭太稀:BAAALAAECgEIAQAAAA==.',['依语']='依语:BAAALAADCgYIBgAAAA==.',['信仰']='信仰的传说:BAAALAADCggICAAAAA==.',['六月']='六月的德耳朵:BAAALAAECgYIBgAAAA==.',['兰花']='兰花一:BAABLAAFFH8YAAMMAAYIcROMKwAOAQAMAAUINhCMKwAOAQANAAIIMQdtNwCBAAAAAA==.兰花三:BAABLAAFFH8UAAMMAAYIxAwVMgDlAAAMAAUIJgoVMgDlAAANAAIIYwcUNwCCAAAAAA==.兰花二:BAABLAAFFH8jAAMMAAYIBRFALwD3AAAMAAUIiA5ALwD3AAANAAIIKgaVOAB7AAAAAA==.兰花五:BAABLAAFFH8IAAMMAAYIpw/DMADuAAAMAAUIIgzDMADuAAANAAEI3QS1TAA5AAAAAA==.兰花六:BAAALAAFFAIIAgAAAA==.兰花四:BAABLAAFFH8PAAMMAAYIHw7LLwD0AAAMAAUI3QzLLwD0AAANAAEIDAWSSwA7AAAAAA==.',['刀如']='刀如雪:BAAALAADCgcIBwAAAA==.',['利雅']='利雅德林:BAAALAAECgQIBAAAAA==.',['剣瀮']='剣瀮:BAABLAAFFH8KAAMOAAIIeRP6GgCTAAAOAAIIsBH6GgCTAAAPAAEICQ9DHQBBAAAAAA==.',['勾陈']='勾陈大帝:BAABLAAECn8UAAIIAAcICyC/KQDuAQAIAAcICyC/KQDuAQAAAA==.',['北京']='北京二零零八:BAAALAAFFAIIAgAAAA==.',['匡匡']='匡匡:BAABLAAFFH8QAAIJAAQIhwatYQCNAAAJAAQIhwatYQCNAAAAAA==.匡匡然:BAAALAAECgYICgAAAA==.',['匹诺']='匹诺曹丨:BAAALAAECgMIAwAAAA==.',['十万']='十万伏忒:BAAALAAECgQIBAAAAA==.',['十公']='十公主的侍卫:BAAALAAECgEIAQAAAA==.',['千早']='千早愛音:BAABLAAFFH8GAAIJAAII6RkzUwCfAAAJAAII6RkzUwCfAAAAAA==.',['卡莎']='卡莎:BAAALAAFFAIIBAAAAA==.',['卢凌']='卢凌风:BAAALAADCggICAAAAA==.',['压力']='压力:BAAALAAFFAYIBAAAAA==.',['原力']='原力释放:BAAALAADCgYIBgAAAA==.',['原吉']='原吉的塬:BAAALAAECgQIBAAAAA==.',['又见']='又见零下八度:BAAALAAECgYIBgAAAA==.',['双喜']='双喜街:BAAALAADCgYIBgAAAA==.',['双子']='双子座撒伽:BAAALAADCgQIBAAAAA==.双子座撒迦:BAAALAADCgEIAQAAAA==.',['双栖']='双栖动物:BAAALAADCgYIBgAAAA==.',['双面']='双面亚娃:BAAALAADCgEIAQAAAA==.',['发姐']='发姐球迷会:BAAALAAFFAIIBAAAAA==.',['吃苹']='吃苹果的蛇:BAAALAADCgcIBwAAAA==.',['哀伤']='哀伤灬冷眸:BAAALAAFFAIIAgAAAA==.',['哎哟']='哎哟哟:BAAALAADCgQIBAAAAA==.',['四阿']='四阿哥:BAAALAAECgYIBgAAAA==.',['圆咕']='圆咕隆咚圆:BAAALAAECgYIBgAAAA==.',['圆月']='圆月花开:BAAALAAECgEIAQAAAA==.',['圣光']='圣光助我:BAAALAAECgMIAwAAAA==.',['塞外']='塞外小德:BAAALAAECgUIBgAAAA==.',['大梦']='大梦一场丶:BAABLAAFFH8IAAIMAAMI/gdYUwB2AAAMAAMI/gdYUwB2AAAAAA==.',['天下']='天下无双骑:BAAALAAECgYIDwAAAA==.',['天嗱']='天嗱你真矮丶:BAACLAAFFH8GAAIQAAMI9hasOgClAAAQAAMI9hasOgClAAAsAAQKfxcAAhAABwgZI2snAMECABAABwgZI2snAMECAAAA.',['天堂']='天堂灬心:BAAALAADCggIFwAAAA==.',['天天']='天天快乐:BAAALAAECgYIDAAAAA==.',['天涯']='天涯迟暮:BAABLAAFFH8GAAIKAAYIJxDiCwBSAQAKAAYIJxDiCwBSAQAAAA==.',['天谴']='天谴之月光:BAAALAAECgQIBAAAAA==.天谴之死士:BAAALAAECgIIAgAAAA==.天谴之鬼术:BAAALAAECggIBgAAAA==.',['太寿']='太寿鸠毛皇:BAAALAAFFAIIBAAAAA==.',['奎托']='奎托斯归来:BAAALAAECgEIAQAAAA==.',['奥村']='奥村英二:BAACLAAFFH8eAAMRAAYIbA/dMABYAQARAAYIPg/dMABYAQASAAIIJgqiGgCNAAAsAAQKfx4AAxIACAipGiUpANABABEACAhrFZlJABcCABIABwj5FiUpANABAAAA.',['女灬']='女灬王:BAAALAADCgIIAgAAAA==.',['如风']='如风:BAACLAAFFH8XAAIIAAYIlB1JDwDOAQAIAAYIlB1JDwDOAQAsAAQKfzMAAggACAgrJQkFAPcCAAgACAgrJQkFAPcCAAAA.',['妹妹']='妹妹我来咯:BAAALAADCgEIAQAAAA==.',['婉转']='婉转灵龙:BAAALAAECgEIAQAAAA==.',['孑孓']='孑孓不独活:BAABLAAFFH8FAAIQAAMIGQ35QwB/AAAQAAMIGQ35QwB/AAAAAA==.',['字一']='字一色:BAAALAAECgYICgAAAA==.',['孤城']='孤城乱舞:BAACLAAFFH8KAAITAAIIHBrhDgCfAAATAAIIHBrhDgCfAAAsAAQKfyIAAhMACAgJITUEAMcCABMACAgJITUEAMcCAAAA.',['害怕']='害怕怕:BAAALAAECgYICwAAAA==.',['寒夜']='寒夜丶:BAAALAAECgYICQAAAA==.',['封魔']='封魔剑魂:BAABLAAFFH8GAAIJAAII3BbjawCSAAAJAAII3BbjawCSAAAAAA==.',['射歪']='射歪一点啊:BAAALAAECgYICAAAAA==.',['小小']='小小书童:BAAALAAECgYICQAAAA==.',['小时']='小时候可壊了:BAAALAADCgIIAgAAAA==.小时候可漂亮:BAAALAAECgYIBwAAAA==.',['小李']='小李飞刀:BAABLAAECn8WAAIDAAgIuyH/FQAHAwADAAgIuyH/FQAHAwAAAA==.',['小猪']='小猪哼哼:BAAALAAECgUIBQAAAA==.',['小领']='小领主:BAAALAADCggICAAAAA==.',['尤尔']='尤尔莉丝:BAAALAADCgYIBgAAAA==.',['峨眉']='峨眉峰:BAAALAAECgYIBgAAAA==.',['崩山']='崩山裂地:BAAALAADCgEIAQAAAA==.',['希娜']='希娜:BAAALAAECggIEAAAAA==.',['希尔']='希尔薇德:BAAALAAECggICAAAAA==.',['幻梦']='幻梦猛禽:BAAALAADCgUIBgAAAA==.',['廉颇']='廉颇老矣:BAABLAAFFH8KAAIUAAUIWwZGGwC5AAAUAAUIWwZGGwC5AAAAAA==.',['张万']='张万森:BAAALAAFFAQIBAAAAA==.',['彼岸']='彼岸双生:BAAALAAECgYICAAAAA==.',['心属']='心属懿芳:BAAALAAECgYIBgAAAA==.',['快乐']='快乐的小羊:BAAALAAECgIIAgAAAA==.',['快溜']='快溜郭黑黑:BAAALAAECgYICAAAAA==.',['性感']='性感小然然:BAABLAAFFH8RAAIVAAQI/BAOKAD1AAAVAAQI/BAOKAD1AAAAAA==.',['怪盗']='怪盗基德:BAAALAADCggICAAAAA==.',['恶魔']='恶魔之握:BAAALAADCgIIAwAAAA==.',['悒雨']='悒雨倾城:BAAALAAFFAIIBAAAAA==.',['惡靈']='惡靈退散:BAAALAADCgEIAQAAAA==.',['想吃']='想吃芒果干:BAAALAAFFAIIAgAAAA==.',['我大']='我大爷的帽子:BAAALAAECgQIBwAAAA==.',['我要']='我要振刀了:BAACLAAFFH8TAAIIAAUIKReXKAA8AQAIAAUIKReXKAA8AQAsAAQKfxYAAggACAiYG9khABQCAAgACAiYG9khABQCAAAA.',['战神']='战神马尔斯:BAAALAAECgcIDQAAAA==.',['手法']='手法也是法:BAAALAAFFAEIAQAAAA==.',['抓住']='抓住郭黑黑:BAAALAAECgQIAwAAAA==.',['抓狂']='抓狂的大香蕉:BAAALAAECggICAAAAA==.',['拉娜']='拉娜还在躲藏:BAABLAAFFH8GAAMOAAIIzA2EGgBLAAAOAAEIRg+EGgBLAAAPAAEIUQzPGgAAAAAAAA==.',['拉格']='拉格娜罗斯:BAAALAAECggIEQAAAA==.',['提拉']='提拉弭苏:BAAALAAFFAIIBAAAAA==.',['摇曳']='摇曳的小术:BAAALAAECgYIBwAAAA==.',['摩天']='摩天锤:BAAALAAECgMIAwAAAA==.',['撒娇']='撒娇五花肉:BAAALAAFFAIIAgAAAA==.',['断光']='断光达努比:BAAALAADCgIIAgAAAA==.',['星星']='星星去哪了:BAABLAAECn8ZAAIWAAgISRCgHQA2AQAWAAgISRCgHQA2AQAAAA==.',['星烁']='星烁:BAAALAAECgIIAgAAAA==.',['昨夜']='昨夜:BAAALAAECgMIAwAAAA==.',['晓山']='晓山瑞希:BAABLAAFFH8GAAIIAAMI/AQSTwBeAAAIAAMI/AQSTwBeAAABLAAFFAYIIQADAB4bAA==.',['暗之']='暗之赤焰:BAAALAAECgYIDAAAAA==.',['曦之']='曦之魅惑:BAABLAAFFH8FAAIJAAIIYBIWqwAbAAAJAAIIYBIWqwAbAAAAAA==.',['曦馨']='曦馨:BAABLAAECn8VAAIIAAYIaiB9JgD9AQAIAAYIaiB9JgD9AQAAAA==.',['曰川']='曰川冈版:BAAALAAFFAIIBAAAAA==.',['更木']='更木剑霸:BAAALAAECgYIBgAAAA==.',['最爱']='最爱电风扇:BAAALAAECgIIAgAAAA==.',['月神']='月神灬唯爱:BAAALAAECgQIBAAAAA==.',['月隐']='月隐灬咏叹:BAABLAAFFH8lAAIHAAYIeh9CCQAdAgAHAAYIeh9CCQAdAgAAAA==.',['有事']='有事宝宝先上:BAABLAAFFH8IAAIDAAQIIQaUZQCoAAADAAQIIQaUZQCoAAAAAA==.',['朝天']='朝天棍:BAAALAAFFAIIBAAAAA==.',['木已']='木已成舟灬:BAAALAADCgIIAgAAAA==.',['术术']='术术口:BAAALAAFFAEIAQAAAA==.',['杀你']='杀你就别玩:BAABLAAFFH8IAAIIAAMIeRARRgCEAAAIAAMIeRARRgCEAAAAAA==.',['杨超']='杨超越:BAABLAAFFH8MAAIDAAYIrhyWBAA4AgADAAYIrhyWBAA4AgAAAA==.',['杰出']='杰出贡献:BAAALAAECggICAAAAA==.',['杵诀']='杵诀哼丧:BAAALAAFFAIIAgAAAA==.',['枫翎']='枫翎月:BAAALAAFFAIIAgAAAA==.',['柏喙']='柏喙:BAAALAAECgMIAwAAAA==.',['柬埔']='柬埔寨钢枪王:BAACLAAFFH8WAAIUAAUIIw4OGQDfAAAUAAUIIw4OGQDfAAAsAAQKfyUAAhQACAjXEUYfAEoBABQACAjXEUYfAEoBAAAA.',['桃喰']='桃喰绮罗莉:BAAALAAECgEIAQAAAA==.',['棕勾']='棕勾勾:BAAALAADCgMIBAAAAA==.',['森林']='森林狼:BAACLAAFFH8GAAIMAAIIuA68XgBfAAAMAAIIuA68XgBfAAAsAAQKfxcAAgwABwhXE41BAFYBAAwABwhXE41BAFYBAAAA.',['椿鬼']='椿鬼:BAAALAAFFAIIBAAAAA==.',['榴莲']='榴莲派:BAAALAAECgYIBgAAAA==.',['橘居']='橘居居:BAAALAAECgIIAgAAAA==.',['比加']='比加锁:BAAALAAFFAIIAgAAAA==.',['水瓶']='水瓶座卡妙:BAAALAADCgUIBQAAAA==.',['永恒']='永恒柏拉图:BAAALAAECgYIBgAAAA==.',['没事']='没事吃西瓜:BAACLAAFFH8VAAMGAAYI9xVzJACGAQAGAAYI4RRzJACGAQAWAAIISRzFDQCaAAAsAAQKfyAAAxYACAjtIFYUAHwCABYABwj0IlYUAHwCAAYACAgRGQ4/AE8CAAAA.',['泉丶']='泉丶此方:BAACLAAFFH8lAAIGAAUIhh2bKADxAAAGAAUIhh2bKADxAAAsAAQKfzgAAwYACAgDIc0gAMwCAAYACAgDIc0gAMwCABcAAggfGxMWAJwAAAAA.',['法号']='法号释怀:BAAALAAFFAEIAQAAAA==.',['波尔']='波尔塞福涅:BAABLAAFFH8IAAMJAAIIsgxAdACOAAAJAAIIsgxAdACOAAAYAAEIbQBHIQAnAAAAAA==.',['浦浦']='浦浦小飞侠:BAAALAAECgUIBQAAAA==.',['海底']='海底捞:BAAALAAECgIIAgAAAA==.',['清新']='清新的黄瓜:BAAALAAECgIIAgAAAA==.',['清风']='清风朗月:BAACLAAFFH8PAAIMAAMIEh4wLwD3AAAMAAMIEh4wLwD3AAAsAAQKfxUAAgwACAjeIpAWAMUCAAwACAjeIpAWAMUCAAAA.',['漆黑']='漆黑圣典:BAAALAAECgEIAQAAAA==.',['火锅']='火锅烩付超:BAAALAADCgUIBQAAAA==.',['灬圈']='灬圈灬:BAABLAAFFH8GAAIJAAYIYQO2YQCNAAAJAAYIYQO2YQCNAAAAAA==.',['灵魂']='灵魂紫泫:BAAALAAECgYIBgAAAA==.',['灼眼']='灼眼的夏丶娜:BAABLAAFFH8KAAIVAAMIkxaOFgDyAAAVAAMIkxaOFgDyAAAAAA==.',['点亮']='点亮半边天:BAAALAAECgIIAgAAAA==.',['点点']='点点都似哎:BAABLAAFFH8GAAIHAAYIZhe5GQBkAQAHAAYIZhe5GQBkAQAAAA==.点点都似猎:BAABLAAFFH8GAAIDAAYIkBR4OQBeAQADAAYIkBR4OQBeAQAAAA==.',['烽火']='烽火照夜:BAAALAADCgIIAgAAAA==.',['焦香']='焦香牛牛:BAAALAAECggIDQAAAA==.',['爆炸']='爆炸陷阱:BAAALAAFFAIIAgABLAAFFAIIEAAHAKkkAA==.',['爱上']='爱上苍井老师:BAAALAAECggICAAAAA==.',['爱冒']='爱冒险的朵拉:BAAALAADCgYIBgAAAA==.',['爱的']='爱的皮皮虾:BAAALAAECgYIBgAAAA==.',['爷们']='爷们土肥圆:BAAALAADCggICAAAAA==.',['牛志']='牛志达:BAABLAAFFH8OAAMLAAYITwZXGQD8AAALAAUIWARXGQD8AAAIAAMI4xi4IQDKAAAAAA==.',['牛波']='牛波一:BAAALAAFFAIIAgAAAA==.',['牛牛']='牛牛人:BAAALAAECgQIBAAAAA==.',['牛顿']='牛顿:BAAALAAECgYIEQAAAA==.',['狐三']='狐三太奶:BAAALAADCgYIBgAAAA==.',['狐飒']='狐飒:BAABLAAFFH8IAAIMAAII3hJkXABkAAAMAAII3hJkXABkAAAAAA==.',['狩王']='狩王:BAAALAAECgcIAgAAAA==.',['猎心']='猎心:BAAALAAECgEIAQAAAA==.',['猎虎']='猎虎八八:BAAALAADCgMIAwAAAA==.',['猎袭']='猎袭:BAAALAAFFAIIBAAAAA==.',['獨釣']='獨釣寒江雪:BAAALAAFFAIIAgAAAA==.',['琅博']='琅博旺:BAAALAAECgEIAQAAAA==.',['琉璃']='琉璃时光:BAAALAAECgYIBgAAAA==.',['璐娜']='璐娜:BAABLAAFFH8LAAIRAAII0w0gSgCKAAARAAII0w0gSgCKAAAAAA==.',['生如']='生如洋葱:BAAALAAECggICgABLAAFFAgIQwACAEUeAA==.',['电疗']='电疗大师:BAAALAADCgMIAwAAAA==.',['百龄']='百龄坛:BAAALAAECgYIBgAAAA==.',['益馨']='益馨:BAAALAAFFAIIBAAAAA==.',['眼红']='眼红的烈人:BAAALAAFFAIIBAAAAA==.',['知更']='知更鸟:BAAALAADCggICAAAAA==.',['矮小']='矮小的农民工:BAAALAADCgMIAwAAAA==.',['破梦']='破梦:BAABLAAECn8WAAIJAAcIhhxmVwBIAgAJAAcIhhxmVwBIAgAAAA==.',['祈愿']='祈愿圣光:BAAALAAECgYIDAAAAA==.',['神之']='神之长子:BAAALAAECgUIBQAAAA==.',['神牧']='神牧奶奶:BAAALAAECgYIBgAAAA==.',['神谕']='神谕使者:BAAALAAECgYIBgAAAA==.',['秘法']='秘法之星:BAACLAAFFH8oAAMGAAcI3hZtFwCnAQAGAAYIGRltFwCnAQAXAAEIfAn6DABEAAAsAAQKf0YAAwYACAiAIeUYAPECAAYACAiAIeUYAPECABcAAQgFG+IRAE8AAAAA.',['竹猗']='竹猗猗:BAAALAADCgQIBAAAAA==.',['筱小']='筱小辉:BAABLAAECn8SAAIIAAYI4SCScgAEAgAIAAYI4SCScgAEAgAAAA==.',['米线']='米线饵丝:BAABLAAECn8WAAIJAAgIgQ/qPwCEAQAJAAgIgQ/qPwCEAQAAAA==.',['米迦']='米迦埃莉丝:BAAALAAECgYIDgAAAA==.',['紅颜']='紅颜:BAAALAADCgUICAAAAA==.',['绿色']='绿色小图腾:BAAALAAECgMIAwAAAA==.',['群星']='群星间的低语:BAACLAAFFH8oAAIIAAcIYCMoBABRAgAIAAcIYCMoBABRAgAsAAQKfysAAggACAijI8ocAP8CAAgACAijI8ocAP8CAAAA.',['翠湖']='翠湖精神病人:BAAALAAFFAIIAgAAAA==.',['翠花']='翠花哥哥:BAAALAAFFAIIAgAAAA==.',['老烧']='老烧:BAAALAAFFAIIAgAAAA==.',['肉嘟']='肉嘟嘟德:BAAALAADCgcIBwAAAA==.',['胖胖']='胖胖的达摩:BAAALAAECgYIBgAAAA==.',['自然']='自然之尘:BAABLAAFFH8IAAIHAAIIjBD6NABrAAAHAAIIjBD6NABrAAAAAA==.',['良知']='良知:BAAALAAECgIIAgAAAA==.',['艾米']='艾米:BAAALAAFFAMIAwAAAA==.',['艾莉']='艾莉西娅:BAAALAAECgUIBQAAAA==.',['芙卡']='芙卡洛斯:BAAALAADCgIIAgAAAA==.',['若尘']='若尘:BAAALAADCgEIAQAAAA==.',['若枼']='若枼睦:BAAALAAFFAIIAgAAAA==.',['茶盏']='茶盏凉:BAAALAADCgIIAgAAAA==.',['荆棘']='荆棘十字:BAABLAAFFH8RAAMZAAUIoQZhBgCpAAAZAAUIoQZhBgCpAAAHAAEIrQ5ATwA3AAAAAA==.',['莉亚']='莉亚德林:BAAALAAFFAIIAgAAAA==.',['菜菜']='菜菜:BAAALAADCgYICgAAAA==.',['菠菜']='菠菜:BAAALAAECgYIBgAAAA==.',['萝卜']='萝卜卜:BAAALAAECgYIBgAAAA==.',['萨豆']='萨豆豆:BAAALAAFFAIIAgAAAA==.',['落日']='落日之魅影:BAAALAAECgUICgAAAA==.',['葡萄']='葡萄派:BAABLAAECn8VAAIaAAgIkB6RHAB8AgAaAAgIkB6RHAB8AgABLAAFFAYIFwAQAH0YAA==.',['薄荷']='薄荷:BAABLAAFFH8GAAIEAAYIuxNZDwCDAAAEAAYIuxNZDwCDAAAAAA==.',['蚊子']='蚊子:BAAALAAECgYIBgAAAA==.',['血月']='血月丨:BAAALAADCggICQAAAA==.',['请叫']='请叫我蛋总:BAAALAAECgYIBgAAAA==.',['谁要']='谁要男妈妈:BAAALAADCggIEAAAAA==.',['贝露']='贝露:BAAALAAECgYIBgABLAAFFAgIBQARAIQIAA==.',['路过']='路过的老百姓:BAAALAAECgYIBgAAAA==.',['进击']='进击的雄鹰:BAAALAADCgcIBwAAAA==.',['远去']='远去的云:BAAALAADCggICAABLAAECgEIAQAbAAAAAA==.',['迷离']='迷离小骑:BAAALAAFFAIIAgAAAA==.',['逆光']='逆光织影:BAABLAAFFH8IAAIcAAII5BlGCwCbAAAcAAII5BlGCwCbAAAAAA==.',['逆风']='逆风:BAAALAAECgYIBgAAAA==.',['逐日']='逐日大孝子:BAAALAAECgEIAQAAAA==.',['那司']='那司福:BAAALAADCgMIBQAAAA==.',['邪能']='邪能波比:BAAALAAFFAIIAgAAAA==.',['里尔']='里尔恩:BAABLAAFFH8GAAIDAAYIgh13IgCsAQADAAYIgh13IgCsAQAAAA==.',['镇魂']='镇魂:BAAALAAECgUIBQAAAA==.',['长安']='长安小德:BAAALAAECgEIAQAAAA==.',['阿兹']='阿兹特克酋长:BAAALAAFFAIIAgAAAA==.',['阿尔']='阿尔莉娅:BAAALAADCgcIBwAAAA==.',['阿萨']='阿萨神奥丁:BAAALAAECgYIBgAAAA==.',['阿薰']='阿薰:BAAALAAECggICAAAAA==.',['陈老']='陈老师:BAAALAAECgYICwAAAA==.',['雪术']='雪术:BAAALAAECgEIAQAAAA==.',['雪菲']='雪菲児:BAAALAAECgIIAgAAAA==.',['零七']='零七:BAAALAAFFAYIBAAAAA==.',['雷塞']='雷塞克啦:BAAALAAECgYIBgAAAA==.',['青柠']='青柠派:BAACLAAFFH8XAAIQAAYIfRh/BwAlAgAQAAYIfRh/BwAlAgAsAAQKfygAAhAACAi7JPcNADsDABAACAi7JPcNADsDAAAA.',['顶级']='顶级糖人:BAABLAAFFH8KAAIDAAYI7hnONQBqAQADAAYI7hnONQBqAQAAAA==.',['须臾']='须臾涧:BAABLAAECn8lAAQDAAgI1COnCgDMAgADAAgIRCOnCgDMAgAdAAYIGiECBADTAQAEAAEI3Q0PMAAsAAAAAA==.',['顽疾']='顽疾:BAAALAADCgEIAQAAAA==.',['风之']='风之彩:BAABLAAECn8XAAITAAYIrxHIKgBNAQATAAYIrxHIKgBNAQAAAA==.风之龙骑:BAACLAAFFH8HAAMDAAMI5gLMmgBBAAADAAMI5gLMmgBBAAAEAAIIAgFdHQAXAAAsAAQKfxcAAwQABgg2B7qHAMIAAAQABgg2B7qHAMIAAAMAAghrBagkAVAAAAAA.',['风尘']='风尘烟雨云深:BAAALAAECgMIAwAAAA==.',['风雪']='风雪之序曲:BAAALAAECgYIDgAAAA==.风雪飘飘:BAAALAAECgUIBQAAAA==.',['馨雨']='馨雨:BAABLAAFFH8GAAIeAAIIYRhRRABQAAAeAAIIYRhRRABQAAAAAA==.',['骨尔']='骨尔丹:BAAALAAECgUIBgAAAA==.',['高人']='高人是我:BAAALAAECgIIAgAAAA==.',['魔山']='魔山克里冈:BAAALAAECgYICwAAAA==.',['魔法']='魔法少女喵:BAACLAAFFH8JAAIMAAMIbCB5FAARAQAMAAMIbCB5FAARAQAsAAQKfxwAAwwABwj5IA0oAHECAAwABwj5IA0oAHECAA0ABgiiFIJhAJQBAAAA.魔法批风:BAACLAAFFH8cAAIGAAYIwQ+qKQBvAQAGAAYIwQ+qKQBvAQAsAAQKfxkAAgYABwgFG7EZANsBAAYABwgFG7EZANsBAAAA.',['鱼吐']='鱼吐泡:BAAALAADCgEIAQAAAA==.',['黄色']='黄色:BAAALAAECgUIBQAAAA==.',['黑之']='黑之契约者:BAAALAADCggIDwAAAA==.',['黑叶']='黑叶:BAAALAAECgQIAgAAAA==.',['黑土']='黑土:BAAALAADCggICQAAAA==.',['黑暗']='黑暗萌主:BAAALAAECgYIBgAAAA==.',['黑桔']='黑桔:BAAALAAECggICAAAAA==.',['黑琴']='黑琴:BAAALAAECggICAAAAA==.',['黑瑛']='黑瑛:BAAALAAECgYIBAAAAA==.',['黯淡']='黯淡星光:BAABLAAFFH8HAAMVAAIIyw18PgBuAAAVAAIIyw18PgBuAAAfAAII1hQYKQBFAAAAAA==.黯淡的烛光:BAAALAAECgMIAwAAAA==.',['龍舌']='龍舌蘭寶寶:BAAALAAECgIIAgAAAA==.',['龙之']='龙之幻想:BAAALAAECgcIDwAAAA==.',['龙牧']='龙牧壮骨:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end