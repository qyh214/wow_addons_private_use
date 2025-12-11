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
 local lookup = {'Shaman-Enhancement','Mage-Arcane','Monk-Brewmaster','Warrior-Fury','Shaman-Restoration','Mage-Frost','Rogue-Assassination','Paladin-Retribution','DeathKnight-Frost','DemonHunter-Havoc','Unknown-Unknown','Warlock-Affliction','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Holy','Paladin-Protection','Evoker-Preservation','Priest-Holy','Priest-Shadow','Warlock-Demonology','Druid-Restoration','DemonHunter-Vengeance','Warlock-Destruction','Druid-Balance','Shaman-Elemental','Monk-Mistweaver','Monk-Windwalker','DeathKnight-Unholy','Warrior-Protection',}; local provider = {region='CN',realm='达斯雷玛',name='CN',type='weekly',zone=44,date='2025-12-08',data={Am='Aminat:BAAALAAECgEIAQAAAA==.',An='Anotherone:BAAALAAECgIIAgAAAA==.',Ao='Ao:BAAALAAECggIAgAAAA==.',Da='Dabolo:BAABLAAECn8bAAIBAAYIQx2pBgCbAQABAAYIQx2pBgCbAQAAAA==.',Do='Doramon:BAABLAAFFH8IAAICAAIIgxQwWABDAAACAAIIgxQwWABDAAAAAA==.',El='Ellywick:BAAALAAFFAIIBAAAAA==.',Fo='Foreverjh:BAAALAAECggICgAAAA==.',Is='Ispower:BAAALAAECgUICAAAAA==.',Ma='Macrosszts:BAAALAAECgYIBgAAAA==.Markorze:BAAALAAECgMIAwAAAA==.Mate:BAAALAADCgcICgAAAA==.',No='Novi:BAAALAAECgIIAgAAAA==.Novii:BAAALAAECgQICAAAAA==.',Or='Or:BAAALAADCggICAAAAA==.',Pi='Piaoliang:BAAALAADCggICAAAAA==.',Ro='Roy:BAAALAADCgYIBgAAAA==.',Si='Silverwolf:BAABLAAFFH8GAAIDAAYI0geYEwAPAQADAAYI0geYEwAPAQAAAA==.',So='Sol:BAAALAAFFAIIAgAAAA==.Somels:BAABLAAFFH8LAAIEAAMIGQ6gOgCKAAAEAAMIGQ6gOgCKAAAAAA==.Sometree:BAACLAAFFH8GAAIFAAIIHweabABPAAAFAAIIHweabABPAAAsAAQKfxUAAgUACAhAD9JVAAgBAAUACAhAD9JVAAgBAAAA.',Su='Supernb:BAAALAAECgYIDAAAAA==.',Th='Thor:BAAALAAECgYIDAAAAA==.',Ve='Verta:BAAALAAECgcIEAAAAA==.',Wa='Watertears:BAAALAAFFAIIBAAAAA==.',Wh='Whitepanda:BAAALAAECgQIBAAAAA==.',Xx='Xxiaoo:BAAALAAECgYIDAAAAA==.',Zx='Zxl:BAAALAAECggICAAAAA==.',['一之']='一之濑琴美:BAABLAAECn8aAAIGAAgIFh8EDgDEAgAGAAgIFh8EDgDEAgAAAA==.',['一二']='一二:BAAALAAECggICAAAAA==.',['一分']='一分钟也行啦:BAABLAAFFH8GAAIHAAYIVACNHwA4AAAHAAYIVACNHwA4AAAAAA==.',['一只']='一只小鸟:BAAALAAECgYIBgAAAA==.',['一碗']='一碗面条:BAAALAAECgYIBgAAAA==.',['一禹']='一禹二一:BAAALAAECgYIEAAAAA==.',['三点']='三点起床:BAABLAAFFH8GAAIDAAYIzQWyCABYAQADAAYIzQWyCABYAQAAAA==.',['上帝']='上帝禁区:BAABLAAFFH8LAAIIAAIIVhYXUACSAAAIAAIIVhYXUACSAAAAAA==.上帝禁区丨:BAAALAAFFAEIAQAAAA==.',['与妮']='与妮共舞:BAAALAAECgYICwAAAA==.',['丶战']='丶战神:BAABLAAFFH8HAAIEAAMIGQsBPQB+AAAEAAMIGQsBPQB+AAAAAA==.',['丿墨']='丿墨点:BAABLAAFFH8GAAIJAAIIHA0zhQBEAAAJAAIIHA0zhQBEAAAAAA==.',['丿欢']='丿欢欢丿:BAAALAAECgYIDAAAAA==.',['乄黑']='乄黑眼圈乄:BAAALAAECgcIBwAAAA==.',['乔二']='乔二姐:BAAALAADCgQIBAAAAA==.',['九千']='九千胜:BAAALAADCgEIAQAAAA==.',['九台']='九台农商银行:BAAALAAECgYIBgAAAA==.',['九月']='九月莺飞:BAAALAAECggICAAAAA==.',['乳胶']='乳胶小雨伞:BAABLAAECn8WAAIKAAgIfxZ5XQAPAgAKAAgIfxZ5XQAPAgAAAA==.',['事思']='事思敬忿思难:BAAALAAECgMIAwAAAA==.',['人言']='人言:BAAALAAECgIIAgABLAAFFAgIAgALAAAAAA==.',['仁狐']='仁狐:BAABLAAECn9EAAIMAAgI9wfxCAAGAQAMAAgI9wfxCAAGAQAAAA==.',['代号']='代号大本钟:BAAALAADCgQIBAAAAA==.',['以仁']='以仁悟道:BAAALAADCgEIAQAAAA==.',['以太']='以太掌控者:BAAALAAECggICAAAAA==.',['传说']='传说的高育良:BAAALAADCggIDwAAAA==.',['何处']='何处不抗压:BAAALAAECgQIBgAAAA==.',['你有']='你有小秘密啊:BAAALAAFFAIIAgAAAA==.',['倚天']='倚天箭:BAACLAAFFH8YAAMCAAYImwehOwDsAAACAAYImwehOwDsAAAGAAIILAOAGwBiAAAsAAQKfxUAAwIACAjzE7UbAMsBAAIACAjzE7UbAMsBAAYAAQhQAO2iAAIAAAAA.',['傻馒']='傻馒头子:BAAALAAECgYICQAAAA==.傻馒鸡丝:BAAALAAFFAIIAgAAAA==.',['光头']='光头睿睿:BAAALAAFFAIIAgAAAA==.',['八云']='八云烈火:BAAALAAECgIIAgAAAA==.',['关雲']='关雲短灬:BAAALAAECggIDgAAAA==.',['再长']='再长一百斤:BAABLAAFFH8IAAIJAAYITCFQIgCtAQAJAAYITCFQIgCtAQAAAA==.',['冰糖']='冰糖葫璐儿:BAAALAAECgQIBAAAAA==.',['凝乐']='凝乐:BAAALAAECgQICgAAAA==.',['凯瑞']='凯瑞甘:BAABLAAFFH8GAAIKAAIIEwxVWACDAAAKAAIIEwxVWACDAAAAAA==.',['劳资']='劳资蜀道山:BAABLAAECn8eAAMNAAcIOBb7kQAuAQANAAcIOBb7kQAuAQAOAAIIrAfDLgAzAAAAAA==.',['勤瘦']='勤瘦:BAAALAAECgIIAgAAAA==.',['医者']='医者仁心:BAAALAAFFAQIBAAAAA==.',['卡娅']='卡娅:BAAALAAECgcICQAAAA==.',['卡布']='卡布仕:BAAALAAECgIIBAAAAA==.',['卡明']='卡明爵士:BAAALAADCgQIBAAAAA==.',['卡梅']='卡梅冯:BAAALAAECgUICQAAAA==.',['压力']='压力好大:BAAALAAECgEIAQAAAA==.',['可爱']='可爱的小德:BAAALAAECgYIBgAAAA==.',['台式']='台式电脑:BAABLAAFFH8IAAMPAAIIfCBtHwCoAAAPAAIIfCBtHwCoAAAQAAEIyyBLJgAAAAABLAAFFAUIAwALAAAAAA==.',['右手']='右手温暖左手:BAAALAAECggIDgAAAA==.',['叶华']='叶华:BAAALAADCgYIBgAAAA==.',['叶子']='叶子要飞了:BAAALAAECgYIDAAAAA==.',['司马']='司马亡姨:BAAALAAFFAIIAgAAAA==.司马汪姨:BAAALAAECgIIAgAAAA==.',['后半']='后半夜的鱼:BAAALAAECggICgAAAA==.后半夜的黑:BAAALAAECggICAAAAA==.',['吕布']='吕布:BAAALAAECgYIDAAAAA==.',['吴村']='吴村第一战:BAAALAAFFAgIBAAAAA==.',['吼少']='吼少侠:BAAALAADCgQIBAAAAA==.',['呆呆']='呆呆的小骑士:BAAALAAECggICAAAAA==.',['咕咕']='咕咕噜:BAAALAAECgYIDAAAAA==.',['咱家']='咱家小姨子:BAAALAAFFAYIAwAAAA==.',['咿利']='咿利丹丶怒風:BAAALAAECgUIAgAAAA==.',['响当']='响当当:BAAALAAECgYIDAAAAA==.',['哎呀']='哎呀丶蓝龙:BAABLAAFFH8cAAIRAAgI5SH+AAAWAwARAAgI5SH+AAAWAwAAAA==.哎呀丶难顶:BAABLAAFFH8QAAMSAAYIuR8ADwDrAQASAAUISCUADwDrAQATAAEIAAPCLgA5AAAAAA==.',['喝水']='喝水时憋气:BAAALAAECggIAQAAAA==.',['嗳姆']='嗳姆豆:BAAALAAECgMIAwAAAA==.',['四想']='四想拼德:BAAALAAFFAIIBAAAAA==.',['四点']='四点起床:BAABLAAFFH8IAAIDAAgIKQnmCgCYAQADAAgIKQnmCgCYAQAAAA==.',['囧丨']='囧丨臭那啥灬:BAAALAADCgYIBgAAAA==.',['圣光']='圣光护佑着你:BAAALAAECgMIAwAAAA==.',['在掩']='在掩饰什么:BAAALAADCgYIBgAAAA==.',['坡上']='坡上村副村长:BAAALAADCgUIBQABLAAFFAYICgAEACgXAA==.坡上村高富帅:BAAALAADCgEIAQABLAAFFAYICgAEACgXAA==.',['声波']='声波:BAAALAAFFAIIAgAAAA==.',['复仇']='复仇之魂:BAAALAAECgYICwAAAA==.复仇回归:BAAALAAECgEIAQAAAA==.复仇女神:BAAALAAECgIIAgAAAA==.',['夏末']='夏末蓝海:BAAALAAECgEIAQAAAA==.',['夏臸']='夏臸未臸:BAAALAAECgQIBQAAAA==.',['夜丶']='夜丶澜:BAAALAADCggICAAAAA==.',['夜行']='夜行神龙:BAAALAAECgYICgAAAA==.',['夜雨']='夜雨风轻:BAABLAAECn8bAAIUAAYI6hfoDwBuAQAUAAYI6hfoDwBuAQAAAA==.',['大叔']='大叔就是好:BAAALAAECgQIBQAAAA==.',['大头']='大头爆栗子:BAAALAAECgYIBgAAAA==.',['大胡']='大胡子:BAAALAAFFAIIAgAAAA==.',['大黑']='大黑大猎:BAAALAAECgEIAQAAAA==.',['天之']='天之天蝎:BAAALAADCgYIDAAAAA==.',['天蝎']='天蝎座我:BAAALAADCgMIAwAAAA==.天蝎怒风:BAAALAAECgYIBgAAAA==.',['天赐']='天赐祈福:BAAALAADCgIIAgAAAA==.',['奇七']='奇七卡斯:BAAALAADCgEIAQAAAA==.',['奔跑']='奔跑的大叔:BAAALAAECgIIAgAAAA==.',['妖奴']='妖奴:BAAALAAECgEIAQAAAA==.',['妖妖']='妖妖零:BAABLAAFFH8KAAIEAAUIgxBnKAAvAQAEAAUIgxBnKAAvAQABLAAFFAUIDgAKAEAUAA==.妖妖领:BAABLAAFFH8OAAIKAAUIQBS0LAA0AQAKAAUIQBS0LAA0AQAAAA==.',['威震']='威震天丶:BAABLAAFFH8GAAIFAAIIpRDaWABqAAAFAAIIpRDaWABqAAAAAA==.',['娇滴']='娇滴滴的肉丸:BAACLAAFFH8dAAMNAAYIygvLQwA9AQANAAYIygvLQwA9AQAOAAEIsgZBOAA2AAAsAAQKfxoAAw0ABwi6EsTJAHIBAA0ABwi6EsTJAHIBAA4AAwh3BsSjAGwAAAAA.',['媇吻']='媇吻伱嘚咗脸:BAAALAADCgMIAgAAAA==.',['安久']='安久彡:BAAALAAECgQIBgAAAA==.',['寂寞']='寂寞长天:BAABLAAFFH8GAAIFAAYIESGzDAALAgAFAAYIESGzDAALAgAAAA==.',['小嘎']='小嘎哩皇不辣:BAABLAAECn8UAAMGAAYI5hWcNwCXAQAGAAYI5hWcNwCXAQACAAEItwNPDAEmAAAAAA==.',['小女']='小女子也能射:BAAALAAECgcIDQAAAA==.',['小小']='小小飞牛:BAAALAAECgMIAwAAAA==.',['小新']='小新打不死:BAAALAADCgIIAgAAAA==.',['小树']='小树娘娘丶:BAABLAAFFH8QAAIVAAUIyg19IQAVAQAVAAUIyg19IQAVAQAAAA==.',['小猫']='小猫腻儿丶:BAAALAAECgYIBgAAAA==.',['尘暮']='尘暮夕:BAAALAAECggICgAAAA==.',['尤敌']='尤敌安:BAABLAAFFH8HAAIWAAIIhQzuEwBkAAAWAAIIhQzuEwBkAAAAAA==.',['尾芒']='尾芒:BAABLAAFFH8GAAINAAYIoxorMgBzAQANAAYIoxorMgBzAQAAAA==.',['布莱']='布莱梅乐团:BAAALAAECgYIDgAAAA==.',['帛曳']='帛曳:BAAALAAFFAIIAgAAAA==.',['干将']='干将丶:BAAALAAFFAMIBAAAAA==.',['幻西']='幻西:BAABLAAFFH8OAAIXAAgIrx/cBAC1AgAXAAgIrx/cBAC1AgAAAA==.',['底比']='底比斯:BAAALAAECgIIBAAAAA==.',['德古']='德古拉灬杀戮:BAABLAAECn8eAAIEAAgIKhmaHgD4AQAEAAgIKhmaHgD4AQAAAA==.',['心情']='心情哥哥:BAAALAAECggICAAAAA==.',['心脏']='心脏外科:BAABLAAFFH8FAAINAAUIygSkYQC8AAANAAUIygSkYQC8AAAAAA==.',['心賍']='心賍外科:BAAALAAFFAMIAwAAAA==.',['恩赐']='恩赐解脱:BAAALAAECgEIAQAAAA==.',['恶魔']='恶魔丨灬炫舞:BAAALAAECggICAAAAA==.',['悠悠']='悠悠情意:BAABLAAFFH8FAAMPAAUIlwaSHADGAAAPAAQIbQOSHADGAAAIAAEIpgHxgQArAAAAAA==.',['我在']='我在故我变:BAABLAAECn8YAAIYAAYINRJlLAAeAQAYAAYINRJlLAAeAQAAAA==.',['我是']='我是土豪:BAAALAAECgIIAgAAAA==.',['手段']='手段极其残忍:BAACLAAFFH8MAAIKAAII8ARtWwB9AAAKAAII8ARtWwB9AAAsAAQKfyUAAgoABgjYEw1bAA4BAAoABgjYEw1bAA4BAAAA.',['捉怪']='捉怪兽的野人:BAAALAADCgEIAQAAAA==.',['撒了']='撒了个鸡:BAABLAAFFH8GAAIZAAYIyQSxKgDuAAAZAAYIyQSxKgDuAAAAAA==.',['撒斯']='撒斯阿尔:BAAALAAECgMIAwAAAA==.',['攬雀']='攬雀尾:BAACLAAFFH8KAAITAAIIShSRHgCTAAATAAIIShSRHgCTAAAsAAQKf0wAAhMACAgMIBMGAJECABMACAgMIBMGAJECAAAA.',['放学']='放学大龙单挑:BAAALAAECgUIDgAAAA==.',['敏菲']='敏菲莉亚:BAAALAAECggICAAAAA==.',['散落']='散落的烟灰:BAAALAADCgEIAQAAAA==.',['无限']='无限修仙:BAABLAAECn8ZAAIVAAYIGwk4nQDbAAAVAAYIGwk4nQDbAAAAAA==.无限修魔:BAAALAAECgYICwAAAA==.',['日野']='日野晴矢:BAAALAAECggICAAAAA==.',['星德']='星德守月:BAABLAAFFH8QAAIHAAUI+wwLDgAvAQAHAAUI+wwLDgAvAQAAAA==.',['晓楠']='晓楠:BAAALAAECgYIBgAAAA==.',['晨星']='晨星絮玉:BAAALAAECgEIAQAAAA==.',['晨曦']='晨曦呓语:BAAALAAECgIIBwAAAA==.晨曦暮语:BAAALAAECgcIDgAAAA==.晨曦煦雨:BAAALAAECgMIAwAAAA==.晨曦絮羽:BAAALAAECgQIBAAAAA==.晨曦耳语:BAAALAAECgIIAgAAAA==.晨曦霏羽:BAAALAAECgUIBQAAAA==.晨曦飞羽:BAAALAAECgYIDwAAAA==.晨曦飞語:BAAALAAECgUIBQAAAA==.晨曦飞语:BAAALAAECgUIBQAAAA==.',['曲奇']='曲奇小甜筒:BAAALAAECgUIBQAAAA==.',['朋友']='朋友与狗:BAAALAAECgIIAgAAAA==.',['朴实']='朴实无华:BAAALAAECgYIBgAAAA==.',['来自']='来自海底:BAAALAAECgYIBgAAAA==.',['杨幂']='杨幂:BAAALAAECgYIBgAAAA==.',['林思']='林思慧:BAAALAAECgIIAgAAAA==.',['柳如']='柳如烟:BAAALAAECgQIBAAAAA==.',['桔纳']='桔纳修斯大帝:BAABLAAFFH8GAAIIAAII0xvpPgCfAAAIAAII0xvpPgCfAAAAAA==.',['梦术']='梦术:BAAALAAFFAIIBAAAAA==.',['梦里']='梦里回梦如她:BAAALAAECggIDgAAAA==.',['樱桃']='樱桃小完犢子:BAABLAAFFH8FAAIXAAUIAReMOgAiAQAXAAUIAReMOgAiAQAAAA==.',['歌德']='歌德密斯:BAAALAAECgIIAgAAAA==.',['死亡']='死亡钟声:BAAALAAECgYIBwAAAA==.',['毒傷']='毒傷:BAAALAAECgYIDAAAAA==.',['毛丶']='毛丶丶:BAACLAAFFH8WAAIEAAUIdiVeFAC4AQAEAAUIdiVeFAC4AQAsAAQKfxUAAgQABgiYIIwnAMQBAAQABgiYIIwnAMQBAAAA.',['毛文']='毛文婕:BAAALAAECgUIBQAAAA==.',['水菜']='水菜:BAAALAAFFAYIAgAAAA==.',['永兰']='永兰:BAABLAAFFH8GAAMVAAIItwx9SgBcAAAVAAIItwx9SgBcAAAYAAIIEAvlOgAzAAAAAA==.',['沙漠']='沙漠:BAAALAADCggICAAAAA==.',['没事']='没事溜溜:BAAALAAECgcICQAAAA==.',['沸石']='沸石:BAABLAAECn8cAAMUAAcIyxOZEABmAQAUAAcIyxOZEABmAQAXAAMIJwTbmQA2AAAAAA==.',['泊舟']='泊舟:BAAALAADCgYIBgAAAA==.',['法勒']='法勒个爷:BAAALAAFFAIIAgAAAA==.',['波雅']='波雅汉库克:BAAALAADCgIIAgAAAA==.',['活噗']='活噗萨:BAABLAAFFH8OAAIFAAII+xXvUQB4AAAFAAII+xXvUQB4AAAAAA==.',['流氓']='流氓难啊:BAAALAADCgEIAQAAAA==.',['浪姐']='浪姐:BAAALAAECgEIAQAAAA==.',['清笙']='清笙挽喻:BAAALAAECgUIBwAAAA==.清笙挽歌:BAAALAAFFAIIAgAAAA==.清笙雨潇:BAAALAADCgIIAgAAAA==.',['清蒸']='清蒸狮子头:BAAALAAECgUIBQAAAA==.',['清风']='清风丶小骚蹄:BAAALAAECgYIBgAAAA==.清风丶张小凡:BAABLAAFFH8GAAIKAAII2gswUwCJAAAKAAII2gswUwCJAAAAAA==.',['温柔']='温柔的狼:BAAALAAECgQIBAAAAA==.',['漫步']='漫步人生路:BAAALAADCgQIBAAAAA==.',['灬神']='灬神棍德:BAABLAAFFH8GAAIVAAIIQxaqKgCCAAAVAAIIQxaqKgCCAAAAAA==.',['灬阿']='灬阿桀灬:BAABLAAFFH8HAAIIAAIImxhPOgCiAAAIAAIImxhPOgCiAAAAAA==.',['為妳']='為妳變乖:BAAALAAECgYIBgAAAA==.',['無上']='無上大梵天:BAABLAAFFH8MAAINAAMIfB6xIAAEAQANAAMIfB6xIAAEAQAAAA==.',['熊猫']='熊猫吓蛋蛋了:BAAALAAECgQIBAAAAA==.',['燃尽']='燃尽风华:BAAALAAECgYIBgAAAA==.',['爆射']='爆射你的狗头:BAAALAAECgYICgAAAA==.',['爱励']='爱励励:BAAALAADCgQIBAAAAA==.',['爱情']='爱情来的太快:BAAALAADCgYIBgAAAA==.',['爱笑']='爱笑的男娃:BAAALAAFFAIIBAAAAA==.',['版本']='版本福利:BAAALAAFFAUIAwAAAA==.',['狗头']='狗头人头狗:BAAALAAECgUICQAAAA==.',['独爱']='独爱月:BAAALAAECgcIBwAAAA==.',['狼王']='狼王:BAAALAADCgYIBgAAAA==.',['猎头']='猎头之王:BAAALAAECgUIBQAAAA==.',['猎皇']='猎皇:BAAALAAECgQIBAAAAA==.',['猛子']='猛子就是猛:BAAALAADCgIIAgAAAA==.',['猪肉']='猪肉脯:BAAALAAECgMIBAAAAA==.',['疯德']='疯德:BAAALAAECgIIAgAAAA==.',['疯狂']='疯狂的大叔:BAAALAAECgQIBwAAAA==.',['皇爷']='皇爷爷:BAACLAAFFH8ZAAMaAAUIrAj9DQD+AAAaAAUIrAj9DQD+AAAbAAUIlgyZDQDjAAAsAAQKfxsAAxsACAiNGXUJABQCABsABwjaHHUJABQCABoACAgZDd0ZABABAAAA.',['皮了']='皮了玩:BAAALAAECggICAAAAA==.',['盘古']='盘古之力:BAABLAAFFH8GAAIJAAYIxAQwSAAcAQAJAAYIxAQwSAAcAQAAAA==.',['真棉']='真棉的房客:BAAALAAECgYIBgAAAA==.',['睡到']='睡到丶自然醒:BAAALAADCggICQAAAA==.',['矮子']='矮子里面拔大:BAAALAAECgcIDwAAAA==.',['破军']='破军杀星:BAAALAAECgMIAwAAAA==.',['祛灬']='祛灬梦嘉:BAABLAAECn8UAAMQAAgIxQ1nOgBXAQAQAAgIvw1nOgBXAQAIAAIIeAhQZwFlAAAAAA==.',['神奇']='神奇种子店:BAAALAAECgYIBgAAAA==.',['秀荣']='秀荣:BAAALAAECggIDgABLAAFFAIIBAALAAAAAA==.',['等等']='等等硪灬:BAACLAAFFH8IAAIJAAIIsQ/ReACMAAAJAAIIsQ/ReACMAAAsAAQKfxUAAwkABwjQGjyXANQBAAkABwg/GDyXANQBABwABgi+FU8yADoBAAAA.',['筱潇']='筱潇:BAAALAAECgYIDAAAAA==.',['简森']='简森:BAAALAAECggICAAAAA==.',['米奈']='米奈希尔灬灵:BAAALAAFFAMIAQAAAA==.',['米小']='米小米:BAABLAAFFH8FAAITAAIIDQdJJQB+AAATAAIIDQdJJQB+AAAAAA==.',['索大']='索大爷:BAAALAAFFAIIAgAAAA==.',['紫丶']='紫丶苑:BAAALAAFFAIIAgAAAA==.',['纯变']='纯变态:BAAALAAECgcIBwAAAA==.',['纯爱']='纯爱女主:BAAALAAECgYIBgAAAA==.',['终于']='终于实现是爽:BAAALAAECgQIBAAAAA==.',['绿光']='绿光之意:BAABLAAFFH8FAAISAAMIRBD1GQDeAAASAAMIRBD1GQDeAAAAAA==.',['缥缈']='缥缈不羁:BAAALAAFFAIIAgAAAA==.',['美丽']='美丽一族:BAAALAAECgYICQAAAA==.',['翠星']='翠星诗:BAABLAAFFH8FAAITAAIIKQ9/IQCLAAATAAIIKQ9/IQCLAAAAAA==.',['翻滾']='翻滾吧牛寶寶:BAAALAADCgEIAQAAAA==.',['联盟']='联盟恶魔:BAABLAAFFH8FAAIKAAII2ATSagA0AAAKAAII2ATSagA0AAAAAA==.',['胜骑']='胜骑:BAAALAAECgQIBAAAAA==.',['芝士']='芝士受气包:BAABLAAECn8qAAMSAAgIPyIXDwDvAgASAAgIPyIXDwDvAgATAAgIRBQcLwAQAgAAAA==.芝士小猫:BAABLAAFFH8HAAIRAAMI2CEECQAxAQARAAMI2CEECQAxAQAAAA==.芝士皮皮:BAAALAAECggICAAAAA==.',['芭比']='芭比丨牧:BAAALAAFFAIIAwAAAA==.',['花散']='花散里:BAAALAAECgYIBgAAAA==.',['苍心']='苍心诗:BAABLAAFFH8GAAIJAAIIzBzCVACeAAAJAAIIzBzCVACeAAAAAA==.',['苏麻']='苏麻拉姑:BAAALAAECgUIBQAAAA==.',['茜维']='茜维尔:BAAALAAECgEIAQAAAA==.',['荒古']='荒古圣体:BAABLAAFFH8FAAIEAAIIsQWVTgBmAAAEAAIIsQWVTgBmAAAAAA==.',['菜瓜']='菜瓜:BAABLAAFFH8wAAMDAAYIXSYTBAA1AgADAAYIXSYTBAA1AgAaAAYI6hWoFAB2AAAAAA==.',['菲梵']='菲梵:BAABLAAFFH8IAAIIAAIIqxHyaQBCAAAIAAIIqxHyaQBCAAAAAA==.',['萘紫']='萘紫:BAAALAADCgcIBwAAAA==.',['蓝色']='蓝色月神:BAAALAADCgIIAgAAAA==.蓝色烟花:BAAALAADCgIIAgAAAA==.',['蓬莱']='蓬莱藤原妹红:BAAALAAECgIIAgAAAA==.',['蕭瑟']='蕭瑟的風:BAAALAADCgQICAAAAA==.',['蜥蜴']='蜥蜴人小队长:BAAALAADCgMIAwAAAA==.',['血查']='血查理诺兰:BAABLAAECn8UAAIGAAcIDBZCFACQAQAGAAcIDBZCFACQAQAAAA==.',['血管']='血管外科:BAAALAAFFAIIAgAAAA==.',['西门']='西门塔尔:BAAALAADCgMIAwAAAA==.',['調戲']='調戲伱:BAAALAAECgIIAgAAAA==.',['许小']='许小得:BAAALAAFFAIIBAAAAA==.',['诗诗']='诗诗:BAABLAAFFH8KAAMOAAII7Q0hKQB1AAAOAAII5gshKQB1AAANAAIIlgnMsgA2AAAAAA==.',['诸神']='诸神战黄昏:BAAALAAECgUIBgAAAA==.',['诺基']='诺基亚:BAAALAAFFAIIBAAAAA==.',['诺米']='诺米叔叔:BAACLAAFFH8TAAMGAAYI+RMKBgDlAAACAAUIzRACOQAJAQAGAAQIoRQKBgDlAAAsAAQKfxcAAwIACAhyFCFWAAECAAIACAg8EyFWAAECAAYABgipEmREAF8BAAAA.',['豆鲨']='豆鲨包:BAAALAAFFAEIAwAAAA==.',['赛貂']='赛貂蝉:BAAALAAECgYIBgAAAA==.',['超级']='超级大苦力:BAAALAAECgYIDgAAAA==.',['躺尸']='躺尸三百宿:BAAALAAFFAEIAQAAAA==.',['辣味']='辣味小松鼠:BAAALAAECgYIBgAAAA==.',['达斯']='达斯维达:BAAALAAECgMIAwAAAA==.',['达普']='达普雷:BAAALAAECgMIAwAAAA==.',['迪尔']='迪尔布拉索:BAABLAAFFH8VAAIRAAUIARSQCwDqAAARAAUIARSQCwDqAAAAAA==.',['迪蒙']='迪蒙亨特:BAAALAAECgYICgAAAA==.',['选哥']='选哥战神:BAAALAAFFAIIAgAAAA==.',['逸天']='逸天:BAAALAADCgEIAQAAAA==.',['醉卧']='醉卧沙场:BAAALAAECggIEQAAAA==.',['醉失']='醉失风情:BAAALAAECggICAAAAA==.醉失风情丶醉:BAABLAAFFH8GAAIEAAYInRlPGQCYAQAEAAYInRlPGQCYAQAAAA==.',['野妹']='野妹子:BAAALAADCgYIBgAAAA==.',['野性']='野性本色:BAAALAAECgYIBgAAAA==.',['钢铁']='钢铁霞:BAAALAAECgYIBgAAAA==.',['铁牢']='铁牢里的囚徒:BAABLAAECn8WAAIGAAYIfgskKgDbAAAGAAYIfgskKgDbAAAAAA==.',['铁甲']='铁甲威牛:BAAALAADCgQIBAAAAA==.',['链接']='链接专家:BAAALAAECgUIBQAAAA==.',['销魂']='销魂碧兽:BAAALAAECggIAgAAAA==.',['闹一']='闹一气:BAACLAAFFH8oAAICAAYIJBuOGAC/AQACAAYIJBuOGAC/AQAsAAQKfxsAAwIACAgfHLg0AHcCAAIACAgfHLg0AHcCAAYAAQhnH/KMAEMAAAAA.',['闹来']='闹来闹去:BAACLAAFFH8wAAIJAAYIYRwXHQDDAQAJAAYIYRwXHQDDAQAsAAQKfxwAAgkACAjiH/8uALYCAAkACAjiH/8uALYCAAAA.',['阿华']='阿华:BAAALAAECgYIBgAAAA==.',['阿妮']='阿妮娅:BAAALAAECgIIAgAAAA==.',['阿尔']='阿尔弗雷德:BAAALAAECgEIAQAAAA==.',['阿花']='阿花:BAAALAAECgUIBQAAAA==.',['陈伟']='陈伟达:BAAALAAECgYIBgAAAA==.',['雨点']='雨点:BAAALAAECgYIDAAAAA==.',['雨落']='雨落枫林:BAAALAAECggICAAAAA==.',['霁谙']='霁谙瑚茵:BAAALAAECgIIAQAAAA==.',['霜乄']='霜乄刀:BAAALAAECgYIEgAAAA==.',['霸气']='霸气刀疤男:BAAALAADCggIEgAAAA==.',['青柑']='青柑普洱:BAABLAAFFH8GAAIFAAIIJwwCZgBVAAAFAAIIJwwCZgBVAAAAAA==.',['青行']='青行诗:BAABLAAFFH8IAAIbAAIISxcZFQBIAAAbAAIISxcZFQBIAAAAAA==.',['静晓']='静晓薰:BAAALAADCggICAAAAA==.',['静电']='静电美男子:BAAALAAECgYIDgAAAA==.',['风吹']='风吹丨煜散:BAAALAAECgcIBwAAAA==.风吹丨雨散:BAAALAAFFAIIBAAAAA==.',['香花']='香花:BAAALAAECgYICgAAAA==.',['香草']='香草储备:BAABLAAECn8VAAIdAAYIOwT3dwCpAAAdAAYIOwT3dwCpAAAAAA==.',['香莲']='香莲:BAAALAAFFAIIAgAAAA==.',['鬼厉']='鬼厉:BAAALAAECgQIBgAAAA==.',['魂之']='魂之守卫敌法:BAAALAAECgYIBgAAAA==.魂之挽歌:BAAALAAECgYIBgAAAA==.',['鲁德']='鲁德牛:BAABLAAFFH8GAAMVAAQIHQzrHQCrAAAVAAMIPQ7rHQCrAAAYAAEIYQD3LwA1AAAAAA==.',['鸡血']='鸡血注入:BAABLAAFFH8MAAMXAAUI5BSfOAAsAQAXAAUIBg6fOAAsAQAUAAIIUBd4EABMAAAAAA==.',['黑嘎']='黑嘎嘎的黑:BAAALAADCggICAAAAA==.',['黑巧']='黑巧薄脆饼干:BAAALAAFFAIIBAAAAA==.',['黧绕']='黧绕:BAABLAAECn8VAAMaAAgImA9EFABhAQAaAAgImA9EFABhAQADAAUI/AeQHQCWAAAAAA==.',['龙之']='龙之血刃:BAAALAADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end