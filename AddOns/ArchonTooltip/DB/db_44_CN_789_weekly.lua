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
 local lookup = {'DeathKnight-Frost','DeathKnight-Unholy','DeathKnight-Blood','Mage-Arcane','Mage-Frost','Shaman-Restoration','Hunter-BeastMastery','Druid-Balance','Druid-Restoration','Druid-Feral','Evoker-Preservation','Evoker-Augmentation','Warrior-Protection','Priest-Holy','Monk-Windwalker','DemonHunter-Havoc','Monk-Brewmaster','Paladin-Retribution','Paladin-Protection','Hunter-Marksmanship','Rogue-Subtlety','Priest-Shadow','DemonHunter-Vengeance','Paladin-Holy','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Warrior-Fury','Hunter-Survival','Monk-Mistweaver','Rogue-Assassination','Mage-Fire','Evoker-Devastation','Unknown-Unknown',}; local provider = {region='CN',realm='织亡者',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Aris:BAAALAAFFAEIAQAAAA==.',Di='Dier:BAAALAADCggIDQAAAA==.',Dk='Dkill:BAACLAAFFH8zAAQBAAcI0iKGCgBSAgABAAcIzCKGCgBSAgACAAMIjiU4BQAiAQADAAEI6QH9HAAtAAAsAAQKfyMAAwEACAhhJm8IAFkDAAEACAhhJm8IAFkDAAIAAwjTG1w4ABQBAAAA.',Ic='Icywind:BAAALAAECggICAAAAA==.',Li='Liar:BAAALAADCggIDQAAAA==.',Lu='Luckyxing:BAACLAAFFH8IAAMEAAMI6wmrRwCDAAAEAAMI6wmrRwCDAAAFAAEIWg1uIABCAAAsAAQKfxQAAwUABggpGTg7AIYBAAUABghKGDg7AIYBAAQABghgEgE4AC8BAAAA.',Ma='Marsper:BAAALAADCgEIAQAAAA==.',Mi='Midoman:BAAALAAFFAIIAgAAAA==.Mimoo:BAAALAAECgQIBAAAAA==.',Nu='Nut:BAAALAAFFAYIAgAAAA==.',So='Sob:BAAALAAECgYIEAAAAA==.',St='Strelitzia:BAAALAAECggICAAAAA==.',Th='Theworld:BAAALAAECgYIBgAAAA==.',To='Tot:BAABLAAFFH8HAAIGAAIIRQ4yYABbAAAGAAIIRQ4yYABbAAAAAA==.',Ve='Venom:BAAALAAFFAUIBAAAAA==.',Vi='Vitaminb:BAAALAAFFAIIAgAAAA==.',Wi='Windflower:BAAALAAECggICAAAAA==.',['一剑']='一剑倾情:BAAALAAECgYIDAAAAA==.',['一疯']='一疯:BAAALAADCgMIAwAAAA==.',['一箭']='一箭倾情:BAABLAAFFH8NAAIHAAUISgtOWQDkAAAHAAUISgtOWQDkAAAAAA==.',['三角']='三角丶初音:BAABLAAFFH8KAAQIAAYIlgHuKQBlAAAIAAQIRgHuKQBlAAAJAAII0gI8SQBRAAAKAAIINwIFEgAlAAAAAA==.',['上校']='上校:BAAALAAFFAIIAgAAAA==.',['不上']='不上班行不行:BAAALAAECgQIBAAAAA==.',['不服']='不服周:BAAALAAECggIEAAAAA==.',['不要']='不要骂了:BAAALAAFFAUIAgAAAA==.',['丫米']='丫米丫米:BAABLAAFFH8MAAILAAYI7SCaBQAxAgALAAYI7SCaBQAxAgAAAA==.',['丶武']='丶武则天:BAABLAAFFH8IAAIJAAII6xzEJwCLAAAJAAII6xzEJwCLAAAAAA==.',['丶转']='丶转角:BAAALAAECgYIBgAAAA==.',['丶颜']='丶颜颜丶:BAAALAAFFAMIBAAAAA==.',['丿丶']='丿丶刂:BAABLAAFFH8kAAMFAAYIBxMcDACXAAAEAAQIGhLGPADZAAAFAAII4hQcDACXAAAAAA==.',['云琪']='云琪瑶:BAAALAAECgEIAQAAAA==.',['亚米']='亚米亚米:BAABLAAFFH8GAAMMAAYIAxCIAwCTAQAMAAUIvA2IAwCTAQALAAEIJxcoGwBHAAABLAAFFAgIBgAMAMYbAA==.',['亮一']='亮一亮静一静:BAAALAAECgYIEwAAAA==.',['亲丫']='亲丫:BAABLAAFFH8JAAINAAIIrAj+MAAyAAANAAIIrAj+MAAyAAAAAA==.',['亲吖']='亲吖:BAAALAAFFAIIBAAAAA==.',['伊利']='伊利蛋蛋:BAAALAADCggICAAAAA==.',['传奇']='传奇射手:BAABLAAFFH8IAAIHAAIIJQfPrQA4AAAHAAIIJQfPrQA4AAAAAA==.',['佚丶']='佚丶名:BAAALAAECgYICgAAAA==.',['佚名']='佚名伊:BAAALAAECgYIBgAAAA==.佚名翼:BAAALAAECgYIBgAAAA==.',['你说']='你说的都对:BAAALAAECgMIAwAAAA==.',['做戏']='做戏:BAAALAAECgYIBgAAAA==.',['光之']='光之翼翅:BAAALAAFFAMIBAAAAA==.',['兜法']='兜法:BAAALAAECgEIAQAAAA==.',['六卖']='六卖神贱:BAAALAAECgYIBgAAAA==.',['兲堂']='兲堂向左丶:BAAALAAFFAMIAwAAAA==.',['兽性']='兽性难改:BAAALAAECgMIAwAAAA==.',['刃物']='刃物息无声:BAAALAAECgMIBgAAAA==.',['别打']='别打我:BAAALAAECgQIBAAAAA==.',['力冠']='力冠三军:BAAALAAECgMIAwAAAA==.',['加尔']='加尔鲁什酋长:BAAALAAECgYIEwAAAA==.',['勇冠']='勇冠三军:BAAALAAECgQIBAAAAA==.',['勇猛']='勇猛的射击猎:BAAALAAECgcIDQAAAA==.',['医美']='医美小王:BAABLAAECn8YAAIOAAYImh5PGQD1AQAOAAYImh5PGQD1AQAAAA==.',['匿丶']='匿丶:BAAALAAECgEIAQAAAA==.',['匿了']='匿了:BAAALAAECgQIBAAAAA==.',['十二']='十二月的猫猫:BAABLAAFFH8IAAIPAAIIsxDuEwCHAAAPAAIIsxDuEwCHAAAAAA==.',['十六']='十六年老奶萨:BAAALAAFFAIIAgAAAA==.',['千浔']='千浔:BAAALAAECgYICgAAAA==.',['千薪']='千薪万苦:BAAALAAECgYIEAAAAA==.',['升空']='升空:BAAALAAECgQIBAAAAA==.',['升龙']='升龙旺旺:BAAALAAECgEIAQAAAA==.',['南门']='南门:BAAALAAECgMIAwAAAA==.',['叄川']='叄川樱雯:BAABLAAECn8UAAIQAAgIOxscOQB6AgAQAAgIOxscOQB6AgAAAA==.',['司殓']='司殓小王:BAABLAAFFH8NAAIBAAUITxuZQAA4AQABAAUITxuZQAA4AQAAAA==.',['吾乃']='吾乃上将潘凤:BAAALAAECgMIAwAAAA==.',['呜嗷']='呜嗷呜嗷呜嗷:BAABLAAFFH8FAAILAAUIiBZYDQBsAQALAAUIiBZYDQBsAQAAAA==.',['周叔']='周叔叔:BAAALAAECgEIAQAAAA==.',['周壹']='周壹:BAAALAADCgMIAwAAAA==.周壹不想放假:BAAALAAECgYICQAAAA==.周壹不想睡觉:BAAALAAECgYIBgAAAA==.周壹先僧:BAAALAADCgcIBwAAAA==.周壹师兄:BAABLAAECn8VAAMRAAgImhPwIACNAQARAAgImhPwIACNAQAPAAYI/AkkIwDdAAAAAA==.周壹的德:BAAALAAECgYIDgAAAA==.',['咕嘟']='咕嘟咕嘟咕嘟:BAAALAADCgMIAwAAAA==.',['咕德']='咕德喵咛:BAAALAAECgYIBgAAAA==.',['咿呀']='咿呀小母牛:BAAALAAECgYIBgAAAA==.',['啊哈']='啊哈哈:BAAALAAFFAEIAQAAAA==.',['喊我']='喊我去睡觉:BAABLAAFFH8GAAIOAAYIGB1RDAAHAgAOAAYIGB1RDAAHAgAAAA==.',['嗷呜']='嗷呜嗷呜嗷呜:BAABLAAFFH8GAAILAAYIORO0BADJAQALAAYIORO0BADJAQAAAA==.',['囧囧']='囧囧滴潴潴:BAAALAAECgYICAABLAAFFAUIJQAGAF0TAA==.',['图腾']='图腾君:BAAALAAECgYIEwAAAA==.',['圣光']='圣光狂暴战:BAABLAAECn8YAAMSAAYIbx0QTQB2AQASAAYIpBoQTQB2AQATAAYISxXaGgA6AQAAAA==.',['圣灮']='圣灮永恒:BAAALAAECgYIDwAAAA==.',['坐杀']='坐杀博徒:BAABLAAFFH8GAAISAAYI+Q2eLAAfAQASAAYI+Q2eLAAfAQAAAA==.',['坤哥']='坤哥:BAAALAAECgMIAwAAAA==.',['基督']='基督山伯爵:BAAALAAFFAIIBAAAAA==.',['塞牙']='塞牙缝的韭菜:BAAALAAECggICAAAAA==.',['墓地']='墓地萨:BAAALAADCggIFwAAAA==.',['壹箭']='壹箭倾情:BAAALAAECgYIDAAAAA==.',['夜阑']='夜阑卧听雨:BAAALAAECgMIAwAAAA==.',['大爆']='大爆牙:BAAALAAFFAIIAgAAAA==.',['天天']='天天开心:BAAALAAECggICAAAAA==.',['奎尔']='奎尔萨斯王子:BAACLAAFFH8IAAIBAAIIEh4cbABhAAABAAIIEh4cbABhAAAsAAQKfzAAAgEABwgZIO1MAF8CAAEABwgZIO1MAF8CAAAA.',['娜娜']='娜娜米:BAAALAADCgMIAwAAAA==.',['寂灭']='寂灭:BAAALAAFFAIIAwAAAA==.',['小病']='小病人丶:BAABLAAFFH8JAAMHAAYIbBTASAAoAQAHAAYIbBTASAAoAQAUAAIIgQTRLwBhAAAAAA==.',['小胖']='小胖娃:BAAALAAECgEIAQAAAA==.',['小龙']='小龙女:BAAALAAECgEIAQAAAA==.',['岳绮']='岳绮罗丶:BAAALAAECgYIBgAAAA==.',['巴拉']='巴拉拉:BAABLAAECn8WAAIVAAYIwBNZDABFAQAVAAYIwBNZDABFAQAAAA==.',['巴洛']='巴洛斯:BAACLAAFFH8gAAIHAAUIMA3aVgDxAAAHAAUIMA3aVgDxAAAsAAQKf0kAAgcACAjtH6IdAEoCAAcACAjtH6IdAEoCAAAA.',['布雷']='布雷斯塔:BAAALAAECgMIAwAAAA==.',['希斯']='希斯:BAAALAAECggIDgAAAA==.',['希里']='希里雅:BAAALAAECgYIDQABLAAFFAYIIwAWACQfAA==.',['弑血']='弑血杀戮:BAAALAAECgUIBQAAAA==.',['当归']='当归不归:BAAALAAECggIDwAAAA==.',['影踪']='影踪禅院:BAAALAAECggIAwAAAA==.',['往佑']='往佑走打怪兽:BAACLAAFFH8lAAIBAAUI3BGMQgAwAQABAAUI3BGMQgAwAQAsAAQKfzEAAgEACAgqE7lJAGYBAAEACAgqE7lJAGYBAAAA.',['待续']='待续:BAAALAAECgEIAQAAAA==.待续丶:BAABLAAFFH8GAAIXAAIIIgZMGABVAAAXAAIIIgZMGABVAAAAAA==.待续丶战:BAABLAAFFH8LAAINAAMIpgNDJgBNAAANAAMIpgNDJgBNAAAAAA==.',['微胖']='微胖神龙大侠:BAAALAAECgEIAQAAAA==.',['德輶']='德輶如宇:BAAALAAECgYICQAAAA==.',['忐忑']='忐忑:BAAALAADCgMIAwAAAA==.',['忽闻']='忽闻声仙乐:BAAALAAECgYICgAAAA==.',['怵歪']='怵歪:BAACLAAFFH8GAAISAAMIEgnARwB8AAASAAMIEgnARwB8AAAsAAQKfxUAAxgACAjwBbxeANAAABgABgiDBLxeANAAABIAAggPBuDSAFYAAAAA.',['憨厚']='憨厚小脸猫:BAACLAAFFH8OAAMFAAIIiBtHDQCcAAAFAAIIiBtHDQCcAAAEAAIIBA6vXAA/AAAsAAQKfyIAAwUABwh+Hv8PAMIBAAUABgjqIf8PAMIBAAQABwhFFkFyALQBAAAA.',['我来']='我来组成头部:BAAALAADCgEIAQAAAA==.',['所愿']='所愿:BAAALAAFFAIIBAAAAA==.',['托兰']='托兰斯提安:BAACLAAFFH8aAAIQAAQIyBEdNQDbAAAQAAQIyBEdNQDbAAAsAAQKfy0AAxAABwhIG6ZaABYCABAABwhIG6ZaABYCABcABgiSB/EfAJwAAAAA.',['护林']='护林小王:BAAALAAECgYIBgAAAA==.',['拉普']='拉普兰德:BAAALAADCggICAAAAA==.',['挚爱']='挚爱黎馨:BAAALAAECgYICwAAAA==.',['挽心']='挽心:BAAALAADCgcIBwAAAA==.',['搞不']='搞不懂吧:BAACLAAFFH8cAAITAAQIaApQDwCKAAATAAQIaApQDwCKAAAsAAQKfy0AAhMACAgfF2UTAIIBABMACAgfF2UTAIIBAAAA.',['撑死']='撑死的人:BAAALAAECgMIAwAAAA==.',['撒肆']='撒肆给:BAAALAAECgMIAwAAAA==.',['斩风']='斩风:BAAALAAECgYICQAAAA==.',['无敌']='无敌嘉宝:BAAALAAECgUIBQAAAA==.',['星辰']='星辰丶光:BAAALAAECggICAAAAA==.',['晓柒']='晓柒丶:BAAALAADCgMIAwAAAA==.',['晨舸']='晨舸:BAAALAAECgYICwAAAA==.',['暂时']='暂时我还好丶:BAAALAAECgQIBAAAAA==.',['暗影']='暗影无行:BAAALAAECgEIAQAAAA==.',['暴力']='暴力的美学:BAAALAAECgYICgAAAA==.',['最后']='最后的剧情:BAAALAADCgcIBwAAAA==.',['木子']='木子:BAAALAAECgUICgAAAA==.',['枫叶']='枫叶:BAAALAAFFAIIBAAAAA==.',['桃酥']='桃酥瑶:BAAALAAECgYIBgAAAA==.',['橘色']='橘色的猫:BAABLAAFFH8HAAMIAAUIWQeQIgCdAAAIAAQI7gWQIgCdAAAJAAIInweUXAA0AAAAAA==.',['欲盖']='欲盖弥彰:BAAALAAECgQIBgAAAA==.',['死灵']='死灵战骑:BAAALAAECgYICwAAAA==.',['死鬼']='死鬼丶:BAABLAAECn8XAAIHAAYI5QiZ3QDCAAAHAAYI5QiZ3QDCAAAAAA==.',['殺丶']='殺丶必死:BAAALAADCgIIAgAAAA==.',['水木']='水木微:BAAALAAECgYIBgAAAA==.',['水淼']='水淼火焱:BAAALAADCgMIAwAAAA==.',['法誓']='法誓:BAABLAAFFH8LAAIFAAMIchxxCwCmAAAFAAMIchxxCwCmAAAAAA==.',['泪泪']='泪泪酱:BAACLAAFFH8bAAIFAAQIJRhWCQDsAAAFAAQIJRhWCQDsAAAsAAQKfzEAAgUABwgcIa8QAKICAAUABwgcIa8QAKICAAAA.',['泰瑞']='泰瑞利亚:BAAALAAECgQIBAAAAA==.',['海洋']='海洋王子:BAAALAAECgYIEgAAAA==.',['涯洛']='涯洛的哀伤:BAAALAAECgYIBgAAAA==.',['深丶']='深丶蓝:BAAALAAECggICAAAAA==.',['深山']='深山里的娃:BAAALAAECgUIBQAAAA==.',['混沌']='混沌圣光:BAAALAADCgMIAwAAAA==.混沌朱厌:BAAALAADCgYIBgAAAA==.',['游戏']='游戏人间:BAAALAAECgMIAwAAAA==.',['湮灬']='湮灬咩:BAABLAAFFH8LAAIBAAUI/xLPQwArAQABAAUI/xLPQwArAQAAAA==.',['湮灭']='湮灭:BAAALAAFFAIIBAAAAA==.',['火灬']='火灬雨:BAACLAAFFH8uAAQZAAYIuRxICADDAAAaAAYIDBubHwCeAQAZAAMIQhdICADDAAAbAAEIxAtKCABQAAAsAAQKfyYAAxkABwhdIZ8hAPgBABkABQgnJJ8hAPgBABoABghQGlk5AGMBAAAA.',['灬暁']='灬暁灬妮:BAAALAADCgMIAwAAAA==.',['灬血']='灬血魔织影灬:BAAALAADCggICAAAAA==.',['炎小']='炎小汐:BAAALAAECgIIAgAAAA==.',['熊心']='熊心壮志:BAAALAAFFAIIBAAAAA==.',['熊猫']='熊猫毛:BAAALAADCgcIAQAAAA==.',['电工']='电工小王:BAABLAAFFH8FAAIGAAMIdBvjMwDXAAAGAAMIdBvjMwDXAAAAAA==.',['疙瘩']='疙瘩:BAAALAAFFAIIAgAAAA==.',['痞子']='痞子锋:BAACLAAFFH8VAAIJAAQIUxBjJwDcAAAJAAQIUxBjJwDcAAAsAAQKfx0AAwkABwhxFIlgAHIBAAkABgjJFIlgAHIBAAgABwh5EKg9AMQAAAAA.',['白日']='白日丶依山盡:BAACLAAFFH8WAAMOAAYIzwvBHgBVAQAOAAYIzwvBHgBVAQAWAAYITwiuFQAfAQAsAAQKfxcAAw4ABgjpG+o+AN0BAA4ABgjpG+o+AN0BABYAAggdFwo7AI4AAAAA.',['白菜']='白菜的驯兽思:BAACLAAFFH8iAAMHAAUIhQ17UQAJAQAHAAUIhQ17UQAJAQAUAAIIyAbrLQBpAAAsAAQKfzYAAxQACAhqFqY8AMUBAAcACAiPE2eKAM0BABQABwhGFqY8AMUBAAAA.',['盾白']='盾白菜:BAACLAAFFH8lAAINAAUIgBjLEwAjAQANAAUIgBjLEwAjAQAsAAQKfzAAAw0ACAiXIEwLAPMCAA0ACAiXIEwLAPMCABwABAgVCeB/AJUAAAAA.',['矮大']='矮大紧:BAAALAAECgYICwAAAA==.',['神特']='神特么烦:BAABLAAFFH8GAAIQAAIICg49SwCRAAAQAAIICg49SwCRAAAAAA==.',['神鳭']='神鳭虾侣:BAAALAAECgYIEwAAAA==.',['秋荷']='秋荷:BAAALAADCgQIBAAAAA==.',['稀稀']='稀稀饭:BAAALAADCgYIBgAAAA==.',['第九']='第九:BAAALAAECgYIEgAAAA==.',['筱天']='筱天丶:BAABLAAFFH8GAAIJAAIIjBvaKwB/AAAJAAIIjBvaKwB/AAAAAA==.',['箭灬']='箭灬雨:BAAALAAFFAEIAQAAAA==.',['粉色']='粉色的猫:BAAALAAFFAIIBAAAAA==.',['精壮']='精壮二狗:BAAALAADCggICAAAAA==.',['糖果']='糖果屋的幽灵:BAABLAAFFH8KAAMOAAgI4xqPCABBAgAOAAcIGhyPCABBAgAWAAIIwRE/HQCiAAAAAA==.',['索灬']='索灬隆:BAABLAAFFH8aAAISAAUIJBxLIQBgAQASAAUIJBxLIQBgAQAAAA==.',['紫旺']='紫旺旺:BAABLAAECn8UAAMaAAYIMRoUQwA9AQAaAAYIdhcUQwA9AQAZAAUIdBhSVQAhAQAAAA==.',['紫氣']='紫氣:BAAALAADCgYIBgAAAA==.',['紫色']='紫色体育生:BAAALAAECgEIAQAAAA==.',['红掌']='红掌柜:BAAALAAECgYIBgAAAA==.',['红牛']='红牛:BAAALAAFFAEIAQAAAA==.',['给你']='给你一瓶七喜:BAAALAADCgMIAwAAAA==.给你一瓶可乐:BAABLAAFFH8PAAMdAAIIaCIhAgDJAAAdAAIIUiIhAgDJAAAHAAIIXiFcMADFAAAAAA==.给你一瓶芬达:BAABLAAFFH8FAAMKAAIIfRQIDwCQAAAKAAIIowkIDwCQAAAIAAEIfhv+KwBOAAAAAA==.',['美女']='美女疯子澄澄:BAABLAAFFH8KAAIBAAIIuiQtPQC3AAABAAIIuiQtPQC3AAAAAA==.',['翼川']='翼川樱雯:BAACLAAFFH8WAAIHAAUI3hBgPgCpAAAHAAUI3hBgPgCpAAAsAAQKfyUAAwcACAh1IioeAOICAAcACAg/IioeAOICABQACAijHZkZAJcCAAAA.',['老吴']='老吴之家:BAAALAAECgYICAAAAA==.老吴之恶:BAAALAADCgEIAQAAAA==.老吴在家:BAAALAAECgYICgAAAA==.老吴归来:BAAALAAECgMIAwAAAA==.老吴爱人:BAAALAADCgIIAgAAAA==.老吴看海:BAAALAAECgYIEwAAAA==.',['联盟']='联盟的勇士:BAAALAAECgEIAQAAAA==.',['胖胖']='胖胖小盼:BAABLAAFFH8KAAIeAAIIUxDcEgCDAAAeAAIIUxDcEgCDAAAAAA==.',['胡萝']='胡萝卜:BAAALAAFFAIIAgAAAA==.',['脑袋']='脑袋开花:BAAALAAECgEIAQAAAA==.',['腻了']='腻了:BAACLAAFFH8SAAMVAAUIJBevDwCfAAAfAAQI0hfqEAD1AAAVAAMIQBivDwCfAAAsAAQKfyUAAxUABwg9Io0QADUCAB8ABgiPIXAbADkCABUABwiMHo0QADUCAAAA.',['花样']='花样华年:BAAALAAECgEIAQAAAA==.',['花间']='花间酒:BAABLAAFFH8XAAIBAAYIYxbHKACTAQABAAYIYxbHKACTAQAAAA==.',['芽米']='芽米芽米:BAABLAAFFH8GAAILAAYIfwyEDgBTAQALAAYIfwyEDgBTAQAAAA==.',['药丸']='药丸儿:BAAALAAECgQIBwAAAA==.',['莫名']='莫名的无语:BAAALAAECggIBwAAAA==.',['莫思']='莫思思:BAABLAAFFH8LAAIaAAYIeADGcwAaAAAaAAYIeADGcwAaAAAAAA==.',['莱杰']='莱杰:BAABLAAECn8bAAMBAAYIYh9ELADEAQABAAYIYh9ELADEAQADAAEIGhNQMAA5AAAAAA==.',['萝卡']='萝卡:BAABLAAFFH8OAAIYAAIIxRWDIwCGAAAYAAIIxRWDIwCGAAABLAAFFAYIGgAJAJQSAA==.',['萨满']='萨满牛小嚒:BAAALAADCggICAAAAA==.',['葬送']='葬送的芙莉莲:BAABLAAFFH8KAAIgAAIImhl2BACoAAAgAAIImhl2BACoAAAAAA==.',['蒜泥']='蒜泥狠:BAAALAAECgcIBwAAAA==.',['蕉太']='蕉太狼:BAAALAAFFAIIBAAAAA==.',['街六']='街六子:BAAALAAFFAIIAgAAAA==.',['西瓜']='西瓜子:BAABLAAFFH8lAAIOAAYIBhkrEQDSAQAOAAYIBhkrEQDSAQAAAA==.西瓜狐狐:BAACLAAFFH8IAAIGAAIIGBOPVwBsAAAGAAIIGBOPVwBsAAAsAAQKfxYAAgYACAjzHOwPAHcCAAYACAjzHOwPAHcCAAAA.',['诗乐']='诗乐稚丶:BAAALAAECgYIBgAAAA==.',['谁记']='谁记得危安:BAAALAAECggICAAAAA==.',['豪杰']='豪杰春香:BAAALAAFFAIIAwAAAA==.',['贰川']='贰川樱雯:BAABLAAFFH8PAAIBAAMIlwosZwB6AAABAAMIlwosZwB6AAAAAA==.',['赶紧']='赶紧洗洗睡:BAAALAADCggIHQAAAA==.赶紧洗漱睡:BAAALAADCggIEAAAAA==.',['路过']='路过蜻蜓丶:BAAALAAECgYIDAAAAA==.',['践踏']='践踏酱:BAAALAAECgYICAAAAA==.',['軒轅']='軒轅丨逐楓弒:BAAALAADCgcIBwAAAA==.',['达闻']='达闻稀:BAAALAAECgMIAwAAAA==.',['那一']='那一夜梦如锻:BAAALAADCggIDQAAAA==.',['那个']='那个牛奶:BAAALAADCgUIBQAAAA==.',['那抹']='那抹笑面如花:BAAALAADCggIDAAAAA==.那抹笑面如霜:BAAALAADCgYIBgAAAA==.',['那瓜']='那瓜那潴那鳖:BAACLAAFFH8lAAIGAAUIXROaJwAmAQAGAAUIXROaJwAmAQAsAAQKfzEAAgYACAjKEmU+AGEBAAYACAjKEmU+AGEBAAAA.',['邦古']='邦古:BAABLAAECn8fAAMhAAgIQRM9DgCxAQAhAAgIQRM9DgCxAQALAAMI/QQcPgBhAAAAAA==.',['邪能']='邪能少女丶僕:BAAALAAFFAQIAgAAAA==.',['酒鬼']='酒鬼大人:BAACLAAFFH8LAAISAAQI9Q9ZNADfAAASAAQI9Q9ZNADfAAAsAAQKfxwAAhIACAieHm8RAIICABIACAieHm8RAIICAAAA.',['里洱']='里洱:BAAALAAECgYIBwAAAA==.',['铁棒']='铁棒:BAAALAAECgYIBwAAAA==.',['银河']='银河邀望:BAAALAAECgYICwAAAA==.',['长崎']='长崎丶爽世:BAAALAAECgYIBgAAAA==.',['防骑']='防骑兴星:BAABLAAFFH8HAAISAAMIjA+xRQCDAAASAAMIjA+xRQCDAAAAAA==.',['阿姨']='阿姨不可以:BAAALAADCggIDwAAAA==.',['阿尔']='阿尔托利娅:BAAALAAECgMIAwAAAA==.',['阿矛']='阿矛:BAAALAAECgYIBgAAAA==.',['阿达']='阿达尔之手:BAAALAAECgUICgAAAA==.',['陈丶']='陈丶辛多雷:BAAALAAECgQIBAABLAAFFAIIAgAiAAAAAA==.',['陌语']='陌语:BAAALAADCgEIAQAAAA==.',['陸噵']='陸噵論囬:BAAALAADCgIIAgAAAA==.',['随风']='随风的细尘:BAAALAAECgUIBgAAAA==.',['雨歇']='雨歇微凉:BAABLAAECn8pAAISAAgIrh7PKwDCAgASAAgIrh7PKwDCAgAAAA==.',['雪晶']='雪晶灵圣骑:BAAALAAECgYICQAAAA==.',['雾切']='雾切响子:BAABLAAFFH8NAAIaAAcIOxkEEwDyAQAaAAcIOxkEEwDyAQAAAA==.',['霜华']='霜华猎梦人:BAACLAAFFH8OAAIHAAQIMhpDWgDfAAAHAAQIMhpDWgDfAAAsAAQKfysAAgcACAhVIEUfAEACAAcACAhVIEUfAEACAAAA.',['靓兮']='靓兮兮:BAABLAAFFH8GAAIXAAIIqgznFABhAAAXAAIIqgznFABhAAAAAA==.',['风丶']='风丶止步的夜:BAAALAAECgQIBAAAAA==.',['风之']='风之歩影:BAACLAAFFH8UAAMSAAQIHg5gNgDOAAASAAQIqwxgNgDOAAATAAMIiwqGEgBgAAAsAAQKfxYAAxMABwgnGsQVAGsBABIABwgEF85+AO4BABMABghHGsQVAGsBAAAA.',['风继']='风继续吹:BAAALAAECgIIAgAAAA==.',['饭饭']='饭饭猫:BAAALAAFFAIIBAAAAA==.',['饿魔']='饿魔猎手:BAAALAAECgQIBQAAAA==.',['魑魅']='魑魅波:BAAALAAFFAYIAgAAAA==.',['鸡丶']='鸡丶你太美:BAAALAADCggIFgAAAA==.',['黎明']='黎明之剑:BAAALAAECgYIBwAAAA==.',['黑么']='黑么么:BAAALAAECggIBgAAAA==.',['黑暗']='黑暗后的黎明:BAAALAADCgEIAQAAAA==.',['黑色']='黑色的猫:BAAALAAFFAIIAgABLAAFFAgICgAOAIQQAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end