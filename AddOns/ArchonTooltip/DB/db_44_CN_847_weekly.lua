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
 local lookup = {'DeathKnight-Frost','Warlock-Destruction','Evoker-Preservation','Evoker-Devastation','Mage-Arcane','Priest-Holy','Priest-Shadow','Priest-Discipline','Shaman-Restoration','Warrior-Fury','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Retribution','Paladin-Protection','Mage-Frost','Druid-Guardian','DeathKnight-Blood','DemonHunter-Havoc','DemonHunter-Vengeance','Monk-Mistweaver','Druid-Restoration','Warlock-Demonology','Paladin-Holy','Monk-Brewmaster','Warrior-Protection','Monk-Windwalker','Hunter-Survival','Shaman-Elemental','Unknown-Unknown','Druid-Balance','Rogue-Outlaw',}; local provider = {region='CN',realm='迦顿',name='CN',type='weekly',zone=44,date='2025-12-08',data={Ac='Aceace:BAAALAAFFAIIBAAAAA==.',Ai='Ainio:BAAALAAECgIIAgAAAA==.',An='Anageter:BAAALAAECgcIBwAAAA==.',Ar='Arnold:BAAALAAFFAIIAgAAAA==.',At='Atfirst:BAAALAAFFAEIAQAAAA==.',Bl='Bluenile:BAAALAAECgYIDAAAAA==.',Ch='Chenjf:BAAALAAECgUIBQAAAA==.',Co='Coolcold:BAAALAAFFAQIBAABLAAFFAgIBwABAFQYAA==.',Go='Goaway:BAABLAAFFH8IAAICAAQI6RC7KADpAAACAAQI6RC7KADpAAAAAA==.Gorilly:BAAALAAECgYICwAAAA==.',Ha='Havana:BAAALAAECgMIAwAAAA==.',He='Heaven:BAAALAAECgIIAgAAAA==.',Ir='Irelia:BAAALAAFFAIIAgAAAA==.',Lh='Lhz:BAAALAAECgYIDAAAAA==.',Li='Lilyisbitch:BAAALAADCgEIAQAAAA==.',Lu='Luoyilan:BAACLAAFFH8KAAMDAAYIDQEmGgBuAAADAAYIDQEmGgBuAAAEAAMIDgExJQAnAAAsAAQKfxUAAgMABgj2F0UMAKMBAAMABgj2F0UMAKMBAAAA.',Mi='Missdk:BAAALAAECgYIDwAAAA==.',Mo='Mon:BAAALAAFFAMIAwAAAA==.',Ng='Ngapp:BAAALAAFFAIIAwAAAA==.',Nv='Nvlieren:BAAALAAFFAIIBAAAAA==.',Pa='Pantys:BAABLAAFFH8GAAIFAAYICxVtKAB0AQAFAAYICxVtKAB0AQAAAA==.',Qi='Qimoo:BAABLAAFFH8UAAQGAAYI7RphHABtAQAGAAQISCBhHABtAQAHAAQIKiAUFwAOAQAIAAEIMA9lBwBEAAAAAA==.',Ro='Rosen:BAACLAAFFH8IAAIBAAIIrxxJbQBfAAABAAIIrxxJbQBfAAAsAAQKfxkAAgEACAhrHXcTAE4CAAEACAhrHXcTAE4CAAAA.',So='Soeaky:BAAALAAECgYIDAAAAA==.',Tr='Traitorstorm:BAAALAAECgYIBgAAAA==.',Wa='Washer:BAAALAAECgYICwAAAA==.',['一二']='一二三的二:BAACLAAFFH8PAAIJAAYIdRigBgDXAQAJAAYIdRigBgDXAQAsAAQKfx0AAgkACAimHugcAKMCAAkACAimHugcAKMCAAAA.',['一箭']='一箭一辣:BAAALAADCgEIAQAAAA==.',['一辉']='一辉:BAABLAAFFH8HAAIKAAII3w+SVgBAAAAKAAII3w+SVgBAAAAAAA==.',['丄弦']='丄弦月丷别闹:BAABLAAFFH8JAAILAAMI9xXubwCEAAALAAMI9xXubwCEAAAAAA==.',['万物']='万物归壹:BAAALAAECgMIAwAAAA==.',['上古']='上古凶兽玄牛:BAAALAAFFAIIBAAAAA==.',['不朽']='不朽的牙:BAAALAAECgYICAAAAA==.',['丶南']='丶南帝:BAAALAAECgYICQAAAA==.',['丶莫']='丶莫子:BAAALAAECgYICwAAAA==.',['为依']='为依消兽:BAACLAAFFH8GAAMLAAIIRwwbmgBBAAALAAIIRwwbmgBBAAAMAAEIgg57GAA4AAAsAAQKfxQAAwsABgiWIfY3AOUBAAsABgiWIfY3AOUBAAwABQguEQZ+AOIAAAEsAAUUBggoAA0Aoh8A.',['丿头']='丿头上有犄角:BAAALAADCgYIBgAAAA==.',['丿靖']='丿靖共尔位:BAABLAAECn8aAAIGAAcIpBV3LQBRAQAGAAcIpBV3LQBRAQAAAA==.',['乄乌']='乄乌尔萨娜乄:BAAALAAFFAIIAgAAAA==.',['义父']='义父:BAAALAAECgUIBgAAAA==.',['乔尼']='乔尼娜丶尼奥:BAAALAADCgYIBgAAAA==.',['二月']='二月满天:BAAALAAECgYIDwAAAA==.',['云清']='云清:BAABLAAFFH8GAAIOAAIISQWmHwBcAAAOAAIISQWmHwBcAAAAAA==.',['云诗']='云诗顿:BAAALAAECgIIAgAAAA==.',['人字']='人字拖:BAABLAAFFH8GAAIPAAIIUg7TEwCGAAAPAAIIUg7TEwCGAAAAAA==.',['伊里']='伊里野灬加奈:BAAALAAECgYICQAAAA==.',['伽蓝']='伽蓝:BAABLAAFFH8GAAIGAAYIrxm6EwC7AQAGAAYIrxm6EwC7AQAAAA==.',['余香']='余香肉丝:BAAALAADCgQIBAAAAA==.',['佛丶']='佛丶爷:BAAALAADCgIIAgAAAA==.',['你好']='你好啊旅行者:BAAALAAECgEIAQAAAA==.',['佬牛']='佬牛徳:BAABLAAFFH8NAAIQAAUIDAduBgClAAAQAAUIDAduBgClAAAAAA==.',['依然']='依然想贰奶:BAAALAAECgUICgAAAA==.',['信仰']='信仰灬圣光:BAAALAAECgYIDQAAAA==.',['兀归']='兀归:BAABLAAECn8eAAMMAAYIEw+UdAD+AAALAAYIuA388wA9AQAMAAYIEAuUdAD+AAAAAA==.',['克哩']='克哩克哩:BAAALAADCgYIBgAAAA==.',['兜兜']='兜兜里囿糖:BAAALAAECgYIBgAAAA==.',['其实']='其实牙不长:BAAALAAECgYIBgAAAA==.',['冰法']='冰法死契:BAABLAAFFH8OAAIRAAUI+gNSEgC5AAARAAUI+gNSEgC5AAAAAA==.',['冷风']='冷风吹:BAAALAAFFAIIAgAAAA==.',['刀糖']='刀糖:BAAALAAECgYIBgAAAA==.',['刑丶']='刑丶天:BAAALAAECgYIBgAAAA==.',['北落']='北落师門:BAAALAAECgYIDAAAAA==.',['十七']='十七神:BAAALAAECgYIBgAAAA==.',['十三']='十三骑士:BAACLAAFFH8GAAINAAIIYhSWOwChAAANAAIIYhSWOwChAAAsAAQKfx0AAg0ABgiRH2VjACQCAA0ABgiRH2VjACQCAAAA.',['千早']='千早爱音:BAAALAAECgYIBgAAAA==.',['千秋']='千秋岁引:BAAALAAECgEIAQAAAA==.',['卡布']='卡布达:BAAALAAFFAIIAwAAAA==.',['原木']='原木纯品:BAABLAAFFH8GAAILAAIIcggiugAwAAALAAIIcggiugAwAAAAAA==.',['双持']='双持宝马:BAAALAAECgIIAgAAAA==.双持的小羊:BAACLAAFFH8HAAIKAAIIZh3dNgCXAAAKAAIIZh3dNgCXAAAsAAQKfyYAAgoABwj+IXI5AE8CAAoABwj+IXI5AE8CAAAA.',['发霉']='发霉的金针菇:BAAALAAECgYIDAAAAA==.',['古大']='古大丹:BAAALAADCgcIBwAAAA==.',['吉猫']='吉猫:BAAALAAFFAIIAgAAAA==.',['告别']='告别泪痕:BAAALAAECgYIBgAAAA==.',['咸湿']='咸湿的饼干:BAAALAAECgUIBgAAAA==.',['哎呀']='哎呀你别跑:BAAALAAFFAMIAwAAAA==.',['唛唯']='唛唯唲:BAAALAAECgIIAgAAAA==.',['嗜血']='嗜血欲望:BAAALAADCgIIAgAAAA==.嗜血老牛:BAABLAAFFH8MAAIJAAII8STlIgDDAAAJAAII8STlIgDDAAABLAAFFAUIHwANACgkAA==.',['四个']='四个幺鸡:BAAALAAECgYIDAAAAA==.',['四季']='四季寶:BAAALAAECgYICwAAAA==.',['回忆']='回忆十年:BAAALAAECgYIBgAAAA==.',['回眸']='回眸一角:BAAALAAFFAIIAwAAAA==.',['团灭']='团灭剩骑士:BAAALAAECgYIBgAAAA==.',['圣临']='圣临天下:BAAALAADCgQIBAAAAA==.',['地狱']='地狱修罗王:BAABLAAFFH8hAAISAAUIGRSpLAA1AQASAAUIGRSpLAA1AQAAAA==.',['墨子']='墨子丶:BAABLAAFFH8GAAINAAIIEhNcPQCgAAANAAIIEhNcPQCgAAAAAA==.',['墨竹']='墨竹凉夜影:BAAALAAECgQIBAAAAA==.',['大滋']='大滋花:BAABLAAFFH8FAAISAAIIZRG3PwCZAAASAAIIZRG3PwCZAAAAAA==.',['大爱']='大爱穿越:BAACLAAFFH8PAAMSAAUIdQsMMAAbAQASAAUIxggMMAAbAQATAAIIRA8VFQAsAAAsAAQKfxwAAxIABghNFLasAHcBABIABghNFLasAHcBABMABQjqBlJNAKMAAAAA.',['大跳']='大跳冲锋躺:BAAALAAECggIEgAAAA==.',['大鱼']='大鱼吃小鱼:BAAALAAFFAIIAwAAAA==.',['天梁']='天梁斗天相:BAAALAAECgUIBQAAAA==.',['天灾']='天灾男爵:BAAALAAECgUICAAAAA==.',['奚緔']='奚緔琺芍:BAABLAAFFH8SAAIUAAIIVANwGgBKAAAUAAIIVANwGgBKAAAAAA==.',['奥维']='奥维利:BAAALAAECgQIBQAAAA==.',['女王']='女王菲菲:BAAALAADCgIIAgAAAA==.',['好多']='好多的小银仙:BAABLAAFFH8MAAMVAAIIzR/zGwCyAAAVAAIIzR/zGwCyAAAQAAIIsQgFEAAmAAABLAAFFAUIHwANACgkAA==.',['如锋']='如锋:BAAALAAFFAIIAgAAAA==.',['妖妖']='妖妖奺:BAAALAAFFAIIBAAAAA==.',['妖精']='妖精坏坏:BAABLAAECn8VAAICAAYIkgQ9xQDiAAACAAYIkgQ9xQDiAAAAAA==.妖精怀怀:BAACLAAFFH8UAAIJAAUIaAg2NADYAAAJAAUIaAg2NADYAAAsAAQKfxUAAgkABgj7F054AJEBAAkABgj7F054AJEBAAAA.',['婉婉']='婉婉:BAACLAAFFH8GAAICAAII9AKFcgAnAAACAAII9AKFcgAnAAAsAAQKfxoAAxYABgi0CFFcAAYBAAIABghHCIGtAB4BABYABggaBVFcAAYBAAAA.',['媽媽']='媽媽説:BAACLAAFFH8oAAINAAYIoh9YDgDTAQANAAYIoh9YDgDTAQAsAAQKfxQAAg0ABwj4I6oVAGICAA0ABwj4I6oVAGICAAAA.',['宝青']='宝青坊主:BAAALAAFFAIIBAAAAA==.',['宝马']='宝马的珐师:BAAALAAFFAIIBAAAAA==.',['小奶']='小奶豆:BAAALAADCgYIBgAAAA==.',['小宇']='小宇宙:BAAALAAECgYIBwAAAA==.',['小小']='小小淘淘气气:BAAALAAECgYIEAAAAA==.小小轩:BAAALAAECgMIAwAAAA==.',['小时']='小时候很洋气:BAAALAAECgYIBgAAAA==.',['小胖']='小胖甜甜:BAAALAADCgcIBwAAAA==.',['小虾']='小虾米:BAAALAAECgYICAAAAA==.',['小银']='小银仙归来:BAACLAAFFH8fAAINAAUIKCSWFACpAQANAAUIKCSWFACpAQAsAAQKfyIAAw0ABgjHJWo3AJYCAA0ABgjHJWo3AJYCABcAAQj2B1J9AC0AAAAA.小银仙痛死你:BAABLAAFFH8GAAMWAAII5hXQFwA6AAACAAII5hX8WABIAAAWAAEIogjQFwA6AAABLAAFFAUIHwANACgkAA==.小银猎:BAAALAAFFAIIBAAAAA==.',['山烟']='山烟镜流:BAABLAAFFH8FAAILAAII8AY/tgA0AAALAAII8AY/tgA0AAAAAA==.',['左眼']='左眼跳瞎:BAAALAADCgIIAgAAAA==.',['巫旒']='巫旒歆:BAABLAAFFH8RAAIPAAUIrg+ECQDnAAAPAAUIrg+ECQDnAAAAAA==.',['开宝']='开宝马来接你:BAACLAAFFH8JAAILAAIIhgF5wwAZAAALAAIIhgF5wwAZAAAsAAQKfxoAAwsABggWCisKASEBAAsABggWCisKASEBAAwABgj5As6ZAIgAAAAA.',['张柏']='张柏芝:BAAALAAFFAIIBAAAAA==.',['影渐']='影渐层:BAAALAAECgQIBAAAAA==.',['影行']='影行:BAAALAAECgUIBQAAAA==.',['很傻']='很傻很水的牛:BAABLAAFFH8nAAIJAAYIPhrfFAC7AQAJAAYIPhrfFAC7AQAAAA==.',['心随']='心随风起:BAAALAADCggICAAAAA==.',['忆笙']='忆笙:BAAALAAECgIIAgAAAA==.',['恋絮']='恋絮无悔:BAAALAAECgYIBgAAAA==.',['愤怒']='愤怒的黑牛:BAAALAAFFAIIAwAAAA==.',['慈母']='慈母的怀抱:BAAALAAECgMIAwAAAA==.',['慕紫']='慕紫微风:BAABLAAFFH8SAAIYAAUIagPFFwCnAAAYAAUIagPFFwCnAAAAAA==.',['懒痒']='懒痒痒:BAAALAAFFAIIBAAAAA==.',['我不']='我不是图腾:BAAALAAECgUIBQAAAA==.',['我将']='我将带头冲钅:BAAALAADCgYIBgAAAA==.',['我很']='我很深你行吗:BAAALAAECgMIAwAAAA==.',['戳戳']='戳戳侬:BAAALAAECgYIDAAAAA==.',['折叶']='折叶笼花:BAAALAAECgEIAQAAAA==.',['拆尼']='拆尼斯孔府:BAAALAAECgUIBQAAAA==.',['提里']='提里奥丶弗丁:BAAALAAFFAIIAwAAAA==.',['教黄']='教黄爷爷:BAABLAAECn8YAAIPAAYIMxhOGQBbAQAPAAYIMxhOGQBbAQAAAA==.',['敬畏']='敬畏丨幽魂:BAAALAAFFAIIAgAAAA==.',['无名']='无名码头:BAAALAAECggICgAAAA==.',['无糖']='无糖:BAAALAAECgYIBgAAAA==.',['旺仔']='旺仔牛奶丶:BAAALAAECgYIBgAAAA==.',['明月']='明月凄风:BAACLAAFFH8jAAINAAUI7hB8LQAeAQANAAUI7hB8LQAeAQAsAAQKfxkAAw0ABwhKFk9YAFoBAA0ABwhKFk9YAFoBABcAAQjBB1NHACUAAAAA.',['明老']='明老湿:BAAALAAECgMIAwAAAA==.明老湿会吟湿:BAAALAAECgYIBgAAAA==.',['春日']='春日崎雪乃:BAAALAAFFAYIAgAAAA==.',['晓风']='晓风残月:BAACLAAFFH8jAAMCAAYIoRCuLgBhAQACAAYIoRCuLgBhAQAWAAMIHgscEwBGAAAsAAQKfyYAAxYABgjNIDAwAK4BABYABginGTAwAK4BAAIABggEHWEyAIQBAAAA.',['晦涩']='晦涩黎明:BAAALAAECgMIAwAAAA==.',['智商']='智商已暴露:BAABLAAFFH8cAAMKAAUIkBPiJABJAQAKAAUIkBPiJABJAQAZAAII/QnlLQA2AAAAAA==.',['曰香']='曰香奴生紫嫣:BAAALAAFFAMIBAAAAA==.',['替沧']='替沧海寄巫山:BAABLAAFFH8NAAICAAMIuhIWTgCEAAACAAMIuhIWTgCEAAAAAA==.',['月影']='月影独眠:BAAALAAECgYIDgAAAA==.',['末子']='末子:BAABLAAFFH8GAAISAAIIuRL3PgCaAAASAAIIuRL3PgCaAAAAAA==.',['杨子']='杨子二:BAABLAAFFH8vAAQYAAYIQSXzBAAZAgAYAAYIQSXzBAAZAgAaAAUIEBO4CgAyAQAUAAIIEBCIEwCGAAAAAA==.',['林花']='林花谢了:BAAALAAECgIIAgAAAA==.',['柚柚']='柚柚橙:BAABLAAFFH8QAAIDAAMIfwyJFgCfAAADAAMIfwyJFgCfAAABLAAFFAYIKAANAKIfAA==.',['水果']='水果桶:BAABLAAFFH8GAAIJAAYI6yMSBgBiAgAJAAYI6yMSBgBiAgAAAA==.水果茶:BAAALAAFFAEIAQAAAA==.',['水水']='水水的白牛:BAAALAAFFAIIAgAAAA==.',['沐鱼']='沐鱼儿:BAAALAADCgEIAQAAAA==.',['法力']='法力残渣:BAACLAAFFH8GAAIPAAIIYAzUFQCBAAAPAAIIYAzUFQCBAAAsAAQKfxsAAg8ABwg1GBcXAHABAA8ABwg1GBcXAHABAAAA.',['法夜']='法夜:BAABLAAECn8WAAMSAAYIDxdUtQBqAQASAAYIEBZUtQBqAQATAAYI5AoJPgDvAAAAAA==.',['波妞']='波妞:BAAALAAFFAIIBAAAAA==.',['浒子']='浒子:BAABLAAFFH8KAAIOAAIIFAl3IQApAAAOAAIIFAl3IQApAAAAAA==.',['海盐']='海盐苏打饼:BAAALAAECgIIAgAAAA==.',['涅法']='涅法蕾姆:BAAALAAECgUIDAAAAA==.',['温西']='温西尔:BAABLAAFFH8JAAIBAAMIMgnYYgCJAAABAAMIMgnYYgCJAAAAAA==.',['游亚']='游亚旧梦:BAABLAAFFH8SAAINAAUILxRGKgAwAQANAAUILxRGKgAwAQAAAA==.',['溺水']='溺水的鱼:BAAALAAECgQIBAAAAA==.',['漂泊']='漂泊如风:BAACLAAFFH8eAAILAAUIZBixSQAoAQALAAUIZBixSQAoAQAsAAQKfxsABAsABgicIoiEANcBAAsABQheIoiEANcBAAwABgh3GdlGAJkBABsABAgfFr8YABYBAAAA.',['濑濑']='濑濑:BAAALAAFFAIIAgAAAA==.',['火球']='火球飞来:BAAALAAECgYICwAAAA==.',['灰白']='灰白眼瞳:BAAALAAFFAIIAgAAAA==.',['炸梦']='炸梦这是我去:BAABLAAFFH8JAAMKAAUIyA0DMADVAAAKAAQI8AsDMADVAAAZAAEIKRV9KQBAAAAAAA==.',['熊猫']='熊猫萌萌:BAAALAAECgYIDAAAAA==.',['爱与']='爱与希望:BAAALAADCgcICwAAAA==.',['牛太']='牛太:BAAALAAECgYIDgAAAA==.',['牛德']='牛德糊涂:BAABLAAFFH8iAAIVAAYIRRo7EADGAQAVAAYIRRo7EADGAQABLAAFFAYIKAANAKIfAA==.',['牛牛']='牛牛老登:BAAALAAECgQIBAAAAA==.',['牛角']='牛角上跳芭蕾:BAAALAAECgYIBgAAAA==.',['特别']='特别来宾:BAABLAAFFH8RAAIGAAUISRSxHQBiAQAGAAUISRSxHQBiAQAAAA==.',['狂侠']='狂侠:BAABLAAFFH8YAAIOAAUIBAfbDADAAAAOAAUIBAfbDADAAAAAAA==.',['狐借']='狐借狐威:BAABLAAFFH8FAAILAAMInwFRvgArAAALAAMInwFRvgArAAAAAA==.',['狐哥']='狐哥:BAAALAADCgYIBgAAAA==.',['猎刃']='猎刃潇稗:BAABLAAFFH8LAAILAAIIswfZqQA7AAALAAIIswfZqQA7AAAAAA==.',['玩不']='玩不明白:BAAALAAFFAIIAgAAAA==.',['珂蕊']='珂蕊:BAAALAAECggIDgAAAA==.',['瑟蒂']='瑟蒂:BAABLAAFFH8FAAISAAMI6BkYPQCaAAASAAMI6BkYPQCaAAAAAA==.',['瓦西']='瓦西西:BAAALAAFFAYIAgAAAA==.',['生前']='生前比较帅:BAAALAAECgYIBgAAAA==.生前比较酷:BAABLAAFFH8NAAMRAAIIhxdrGQA8AAARAAIIhxdrGQA8AAABAAEIAAF9owAyAAAAAA==.生前非常帅:BAABLAAFFH8XAAMWAAUIRBonAwBXAQAWAAUIEhonAwBXAQACAAEI5QroWQBGAAAAAA==.',['电糖']='电糖:BAABLAAFFH8GAAIcAAYIkwHdRABEAAAcAAYIkwHdRABEAAAAAA==.',['疯疯']='疯疯:BAAALAAECgQIBAAAAA==.',['疯起']='疯起云涌:BAAALAAFFAIIAwAAAA==.',['皮皮']='皮皮酱丶:BAAALAAFFAEIAQAAAA==.',['破山']='破山:BAABLAAFFH8OAAMKAAQI2xm9IwC0AAAKAAQI2xm9IwC0AAAZAAMIFg3sIgBmAAAAAA==.',['硪叫']='硪叫哀木涕:BAAALAAFFAIIBAAAAA==.',['神丶']='神丶聖:BAAALAAECggICAAAAA==.',['神殇']='神殇丿鼠:BAAALAAECgYIDQABLAAFFAIIBAAdAAAAAA==.',['福杰']='福杰尼:BAAALAAECgQIBgAAAA==.',['粉红']='粉红色的魅力:BAAALAAECgYIBgAAAA==.',['粉色']='粉色体育生:BAAALAAFFAIIAgAAAA==.',['粗面']='粗面鱼丸:BAAALAADCgEIAQAAAA==.',['紫川']='紫川短裤:BAAALAAFFAIIBAAAAA==.',['紫薇']='紫薇:BAAALAAECgYIEwAAAA==.',['绿绿']='绿绿的小索索:BAAALAAECgUIBQAAAA==.',['老头']='老头:BAABLAAFFH8FAAINAAMIugutSQB2AAANAAMIugutSQB2AAAAAA==.',['老婆']='老婆是女神:BAAALAAECgEIAQAAAA==.',['肉团']='肉团团:BAAALAAECgYIDgAAAA==.',['胖头']='胖头鱼家的:BAAALAADCggICAAAAA==.',['腰围']='腰围八尺:BAAALAAECgYIBgAAAA==.',['艾亚']='艾亚哥斯:BAABLAAFFH8fAAMWAAYIkBA5BAApAQAWAAUIcRM5BAApAQACAAYIwQWnOQAnAQAAAA==.',['花花']='花花十三:BAAALAAFFAIIAgAAAA==.',['花间']='花间:BAAALAAFFAIIAgAAAA==.',['花鸟']='花鸟雪月:BAAALAAFFAIIBAAAAA==.花鸟风月:BAAALAAFFAIIAgAAAA==.',['苏娜']='苏娜艾玛尔:BAAALAAECgEIAQAAAA==.',['茜苽']='茜苽可苛荳:BAACLAAFFH8NAAIQAAIIhxklBwB9AAAQAAIIhxklBwB9AAAsAAQKfxgAAxAABwhJFdwQACwBABAABghUF9wQACwBAB4ABAg+BoSRAH8AAAAA.',['茯叶']='茯叶:BAABLAAFFH8TAAIGAAUImhhoGQCIAQAGAAUImhhoGQCIAQAAAA==.',['莜茜']='莜茜壬茧:BAABLAAFFH8LAAIeAAUIJQPeJACLAAAeAAUIJQPeJACLAAAAAA==.',['莫无']='莫无言:BAAALAAFFAIIAwAAAA==.',['莫道']='莫道君行早:BAAALAAFFAEIAQAAAA==.',['菜鸟']='菜鸟会努力哒:BAAALAAECgMIBQAAAA==.',['菲宝']='菲宝:BAAALAAECggIDwAAAA==.',['菲菲']='菲菲女王:BAAALAAFFAIIAgAAAA==.菲菲女神:BAAALAAECgUIBQAAAA==.',['萨满']='萨满灬泡泡:BAAALAADCggICAAAAA==.',['萨牛']='萨牛傻牛:BAAALAAECgMIAwAAAA==.',['落雪']='落雪:BAAALAAECggICAAAAA==.',['蒨嬌']='蒨嬌絔媚:BAACLAAFFH8GAAINAAMIZAaMTABnAAANAAMIZAaMTABnAAAsAAQKfxwAAg0ABghXGKajALEBAA0ABghXGKajALEBAAAA.',['蓝丶']='蓝丶语嫣:BAAALAADCgIIAgAAAA==.',['蕾姆']='蕾姆灬拉姆:BAAALAAECgYIBgAAAA==.',['蜜玛']='蜜玛:BAAALAAECgYIBgAAAA==.',['蝶野']='蝶野真舞:BAAALAAFFAQIBAAAAA==.',['西湖']='西湖龙井茶:BAABLAAFFH8NAAIBAAYIDhB5NgBkAQABAAYIDhB5NgBkAQAAAA==.',['西门']='西门大官人:BAABLAAECn8WAAILAAgIHhjeNgDoAQALAAgIHhjeNgDoAQAAAA==.',['西风']='西风烈霜晨月:BAABLAAFFH8LAAINAAIIjBKCaABCAAANAAIIjBKCaABCAAAAAA==.',['謨子']='謨子丶:BAAALAAECgYIBgAAAA==.',['跳糖']='跳糖:BAAALAAFFAIIAgAAAA==.',['轩大']='轩大胖子:BAAALAADCgEIAQAAAA==.',['这是']='这是什么心态:BAABLAAFFH8VAAMJAAUITA1jQQCjAAAJAAMIOhFjQQCjAAAcAAMIaQSbMQCiAAAAAA==.',['这芝']='这芝士牛:BAAALAAECgYIBgAAAA==.',['邪恶']='邪恶的小轩:BAAALAAECgQIBwAAAA==.',['醉晴']='醉晴儿丶:BAAALAAECgMIAwAAAA==.',['重返']='重返艾泽拉丝:BAAALAADCgEIAQAAAA==.',['银灰']='银灰色的死:BAABLAAFFH8MAAIGAAIIXwhQPQB7AAAGAAIIXwhQPQB7AAAAAA==.',['闷热']='闷热:BAAALAADCggIDQAAAA==.',['队长']='队长:BAAALAAECgUIBwAAAA==.',['阿伟']='阿伟:BAAALAADCgQIBAAAAA==.',['阿特']='阿特加诶赴死:BAAALAAFFAEIAQAAAA==.',['难德']='难德游戏:BAABLAAECn8WAAIVAAYI7ArVUwDJAAAVAAYI7ArVUwDJAAAAAA==.',['雨别']='雨别停:BAAALAADCgcIBwABLAAFFAYICgADAA0BAA==.',['雨楪']='雨楪:BAAALAADCggICAAAAA==.',['雨页']='雨页:BAAALAADCgYIBgAAAA==.',['雪逝']='雪逝泪痕:BAAALAAECgQIBwAAAA==.',['雾里']='雾里看花:BAAALAAECgMIAwAAAA==.',['霜月']='霜月吟:BAAALAAECgYIBgAAAA==.',['霜火']='霜火烤面包:BAAALAAECgQIBAAAAA==.',['霸总']='霸总:BAAALAAFFAIIBAAAAA==.',['非正']='非正人君子:BAABLAAECn8WAAMPAAYIbQ48VQAgAQAPAAYIeAo8VQAgAQAFAAYIrQ1KtwAQAQAAAA==.',['風薰']='風薰夏的記憶:BAAALAAECgYIBgAAAA==.',['风泣']='风泣灬泡泡:BAAALAADCgYIBgAAAA==.',['食神']='食神:BAABLAAFFH8GAAIPAAIIowmwGwA6AAAPAAIIowmwGwA6AAAAAA==.',['香葱']='香葱梳打饼:BAAALAAECgYICQAAAA==.',['骑士']='骑士无圣光:BAAALAAECgEIAQAAAA==.',['鬼舞']='鬼舞凤凰:BAAALAAFFAIIAgAAAA==.',['魂舞']='魂舞綻:BAABLAAFFH8HAAIZAAIIugW5LgBcAAAZAAIIugW5LgBcAAAAAA==.',['鱼丸']='鱼丸粗面:BAAALAAECgIIAgAAAA==.鱼丸粗麺:BAAALAADCgQIBwAAAA==.',['鸟叔']='鸟叔叔:BAABLAAFFH8JAAIDAAIIbA2aFgB+AAADAAIIbA2aFgB+AAAAAA==.',['黄菜']='黄菜菜:BAAALAAECgEIAQAAAA==.',['黑暗']='黑暗中守护你:BAABLAAFFH8GAAIfAAII3gaABgAxAAAfAAII3gaABgAxAAAAAA==.',['黑皮']='黑皮体育生:BAABLAAFFH8GAAMZAAYINQAoPAALAAAZAAMIZgAoPAALAAAKAAMIBADXaQADAAAAAA==.',['黑色']='黑色风想:BAAALAAECgYIBgAAAA==.',['黯骑']='黯骑士:BAAALAADCgIIAgAAAA==.',['龙行']='龙行:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end