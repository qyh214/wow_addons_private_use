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
 local lookup = {'Hunter-BeastMastery','Paladin-Retribution','Unknown-Unknown','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Warlock-Destruction','Warrior-Protection','Warrior-Fury','Paladin-Holy','Paladin-Protection','DeathKnight-Frost','Rogue-Subtlety','Rogue-Assassination','Druid-Restoration','Druid-Guardian','Mage-Arcane','Shaman-Restoration','Hunter-Survival','Monk-Windwalker','Monk-Brewmaster','Druid-Balance','Druid-Feral','DeathKnight-Blood','DeathKnight-Unholy','Hunter-Marksmanship','Shaman-Elemental','Warlock-Demonology','Mage-Frost','Warlock-Affliction','DemonHunter-Havoc','Shaman-Enhancement','Priest-Discipline','Priest-Holy',}; local provider = {region='CN',realm='沙怒',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Angeles:BAAALAAECgYIBgAAAA==.',Aw='Awesomeness:BAABLAAFFH8GAAIBAAIIIBosigBIAAABAAIIIBosigBIAAAAAA==.',En='Endwordgry:BAAALAAECgUICAAAAA==.',Fi='Fif:BAAALAAECgYIDwAAAA==.Filingzf:BAAALAAECgYIBwAAAA==.',Ha='Hathaway:BAAALAAECgMIAwAAAA==.',Il='Ilh:BAAALAADCgIIAgAAAA==.',Ju='Judgelight:BAAALAAFFAIIDAAAAQ==.',Ka='Karas:BAABLAAFFH8FAAICAAIIbwXmeQA3AAACAAIIbwXmeQA3AAAAAA==.Karthas:BAAALAAFFAIIBAAAAA==.',Ke='Kevis:BAAALAAECgEIAQAAAA==.',Le='Lesyndicat:BAAALAAECgYIDgAAAA==.',Lo='Lolululu:BAAALAAECgIIAgABLAAFFAgIAgADAAAAAA==.Loolo:BAAALAAFFAIIAgAAAA==.',Ne='Nescafem:BAAALAAECgUIBQAAAA==.',Nu='Null:BAAALAAFFAIIAgAAAA==.',Pi='Pinrupinrup:BAAALAAECgYIBgAAAA==.',Su='Superx:BAAALAAECgYICwAAAA==.',Vv='Vvca:BAACLAAFFH8eAAQEAAcIcB8RAwCSAgAEAAcIcB8RAwCSAgAFAAEIBRdgDgBSAAAGAAIIjBjlHABFAAAsAAQKfx0AAwQACAixJKABAAQDAAQACAixJKABAAQDAAYABgh4JEsWAHUCAAAA.',Wi='Windgone:BAACLAAFFH8kAAIHAAgIkiYcAQAGAwAHAAgIkiYcAQAGAwAsAAQKfxcAAgcABwjQI/wkALMCAAcABwjQI/wkALMCAAAA.',Wo='Woden:BAAALAAECgYICQAAAA==.',Yf='Yfsaiko:BAAALAAECgYICQAAAA==.',Yy='Yydd:BAAALAAECgUIBQAAAA==.',Zz='Zzq:BAAALAADCggIEAAAAA==.',['Äå']='Äå:BAAALAADCgEIAQAAAA==.',['一小']='一小双儿一:BAAALAAECgYIBgAAAA==.',['一碗']='一碗豆腐:BAAALAAECgMIBQAAAA==.',['七夜']='七夜果果:BAAALAADCgUIBQAAAA==.',['七月']='七月在野:BAAALAAECgEIAgAAAA==.七月流火:BAAALAAECgYIBgAAAA==.七月食瓜:BAAALAAECgYICQAAAA==.',['上电']='上电:BAAALAAECgYICwAAAA==.',['下雨']='下雨的伊伊:BAAALAAFFAIIAgAAAA==.',['不死']='不死强哥:BAAALAAECgMIAwAAAA==.',['不负']='不负丶年华:BAAALAAECgYICwAAAA==.',['东北']='东北雨姐:BAAALAAECgYICQAAAA==.',['丨天']='丨天灬枢:BAAALAAECggICgAAAA==.',['丨糖']='丨糖糖丨:BAAALAAECgMIAwAAAA==.',['丩零']='丩零灬大男人:BAACLAAFFH8mAAMIAAYI+iG+BwDHAQAIAAYIGSC+BwDHAQAJAAUIDxsWFgAVAQAsAAQKfxYAAwkABgi0I7IwAHQCAAkABgi0I7IwAHQCAAgAAQhcGluSAEQAAAAA.',['丶墨']='丶墨渊:BAACLAAFFH8rAAMCAAYICx2HIgBZAQACAAUIgh+HIgBZAQAKAAUIKQ1dFwAYAQAsAAQKfxUABAoABwhrFds0AJUBAAoABwhrFds0AJUBAAIABQgJHqEBASgBAAsAAQjPE1NDADUAAAAA.',['丶木']='丶木丁西:BAABLAAFFH8KAAIMAAIIjw9+gwBEAAAMAAIIjw9+gwBEAAAAAA==.',['丶激']='丶激弦发矢:BAAALAAECgUICgAAAA==.',['丶燕']='丶燕狂徒:BAABLAAFFH8GAAICAAYI/hmTBAAiAgACAAYI/hmTBAAiAgAAAA==.',['丶芝']='丶芝士烩面:BAAALAADCgEIAQAAAA==.',['丿战']='丿战魂灬宜春:BAAALAAFFAIIAgAAAA==.',['乄姝']='乄姝侍:BAAALAADCggICAAAAA==.',['乄小']='乄小丽:BAAALAADCgQIBAAAAA==.',['乌镇']='乌镇醇酒:BAACLAAFFH8eAAMNAAYIDB9IBwBkAQANAAUIOB5IBwBkAQAOAAMIxxTBEAD4AAAsAAQKfxkAAw0ACAhTINkCAGoCAA0ACAjGH9kCAGoCAA4AAQgdJdxjAGsAAAAA.',['九尾']='九尾:BAAALAAECgMIAwAAAA==.九尾小仙官:BAAALAAECgMIBQAAAA==.',['二蛋']='二蛋他二婶:BAABLAAFFH8KAAMPAAMIGA17NACYAAAPAAMIGA17NACYAAAQAAMILQlECQBUAAAAAA==.',['五月']='五月螽斯动股:BAAALAAECgEIAQAAAA==.',['人心']='人心薄凉丶伤:BAAALAAFFAgIAQAAAA==.',['仕無']='仕無雙:BAAALAAECgIIAwAAAA==.',['伏黑']='伏黑甚尔:BAAALAAECgYICwABLAAFFAgIIAAJAN8dAA==.',['优库']='优库里伍德:BAAALAADCgIIAwAAAA==.',['余生']='余生爱我:BAAALAAECgYIEwAAAA==.',['依然']='依然灬小熙:BAABLAAFFH8KAAIBAAYIUBgNMAB4AQABAAYIUBgNMAB4AQAAAA==.',['倒车']='倒车请注意:BAAALAAECgYIBgAAAA==.',['傲霊']='傲霊隨風:BAAALAAECgMIAwAAAA==.',['全区']='全区美男:BAAALAAECgUIBQAAAA==.',['六六']='六六:BAABLAAFFH8GAAIOAAII4Qx5GgBKAAAOAAII4Qx5GgBKAAABLAAFFAgIFAAOANIFAA==.',['兰斯']='兰斯维亚:BAAALAAECgYIBgAAAA==.',['关不']='关不严:BAAALAAECgMIAwAAAA==.',['冰封']='冰封的泪:BAAALAAECgYIBwAAAA==.',['冻顶']='冻顶乌龙:BAAALAAECggICQAAAA==.',['净罪']='净罪:BAAALAAECgYIBgAAAA==.',['凛冬']='凛冬来了:BAAALAAECgYIBgAAAA==.',['别慌']='别慌我有棍:BAAALAADCgIIAgAAAA==.',['刺客']='刺客尼基塔:BAAALAAECgIIAgAAAA==.',['刻俄']='刻俄柏:BAABLAAFFH8GAAIPAAII1ROmRQBjAAAPAAII1ROmRQBjAAABLAAFFAYIIgABAD4jAA==.',['剑刃']='剑刃风暴:BAACLAAFFH8FAAIIAAMIVgzsIwBcAAAIAAMIVgzsIwBcAAAsAAQKfxQAAggACAiSF6wQAMwBAAgACAiSF6wQAMwBAAAA.',['副船']='副船长丶:BAAALAADCgcICwAAAA==.',['加洛']='加洛什地狱吼:BAAALAAFFAIIAgAAAA==.',['加迩']='加迩什丶咆哮:BAAALAAECgYIDgAAAA==.',['劫运']='劫运归尘:BAABLAAECn8cAAIRAAgInw0YKAB+AQARAAgInw0YKAB+AQAAAA==.',['勇敢']='勇敢狗咪:BAAALAAECgYIBgAAAA==.',['北原']='北原春希:BAAALAAECgYICwAAAA==.',['北秋']='北秋悲丶:BAAALAAFFAIIBAAAAA==.',['半支']='半支烟:BAAALAAECggIDQAAAA==.',['半面']='半面妆:BAAALAADCgcIBwAAAA==.',['南冥']='南冥有猫:BAAALAAECggIEwAAAA==.',['卡布']='卡布达:BAACLAAFFH8UAAISAAII8g6mUgBpAAASAAII8g6mUgBpAAAsAAQKfyEAAhIACAgSF/5DABICABIACAgSF/5DABICAAAA.',['卡涅']='卡涅利安:BAABLAAFFH8cAAIHAAYIURvaIQCUAQAHAAYIURvaIQCUAQABLAAFFAYIIgABAD4jAA==.',['原地']='原地螺旋起飞:BAABLAAFFH8GAAMNAAYIRh2EDAC1AAAOAAQISh1oEAD9AAANAAIIPB2EDAC1AAAAAA==.',['又射']='又射偏了丶:BAAALAAECgYIDAAAAA==.',['古儿']='古儿丹:BAAALAAFFAIIAgAAAA==.',['古夫']='古夫:BAAALAAECgUIBwABLAAFFAIIBAADAAAAAA==.',['名人']='名人不说暗话:BAAALAAECgUIBQAAAA==.',['周潤']='周潤发:BAAALAAECgYIBgAAAA==.',['咕咕']='咕咕爱吃香蕉:BAABLAAFFH8FAAIPAAII8gREUwBOAAAPAAII8gREUwBOAAAAAA==.',['咖啡']='咖啡鱼:BAAALAAECgYICAAAAA==.',['咸鱼']='咸鱼牧:BAAALAAECgYIBgAAAA==.咸鱼萨:BAAALAAECggICAAAAA==.',['哥我']='哥我猎害吗:BAABLAAFFH8KAAMBAAUISAyOWADpAAABAAUISAyOWADpAAATAAEICgEKCQA0AAAAAA==.',['哦呼']='哦呼:BAAALAAECgYIBgAAAA==.',['嗜血']='嗜血总裁:BAAALAAFFAIIAgAAAA==.',['嗳呀']='嗳呀呀:BAAALAADCgYIBgAAAA==.',['嗷嗷']='嗷嗷呜呜:BAAALAADCggICAAAAA==.',['圆园']='圆园圜囦:BAACLAAFFH8JAAMUAAYIGQYWBwAzAQAUAAYI/QEWBwAzAQAVAAMIQAu3DwCuAAAsAAQKfxgAAxUABggaFlYmAF4BABUABggaFlYmAF4BABQABggiDs1BACkBAAEsAAUUCAgkAAcAkiYA.',['圣一']='圣一一撸你死:BAAALAADCgUIBQAAAA==.',['在等']='在等月亮和你:BAABLAAFFH8OAAIRAAYI3yH/EgDiAQARAAYI3yH/EgDiAQAAAA==.',['地精']='地精真坑爹:BAACLAAFFH8OAAISAAMIYhU7OACQAAASAAMIYhU7OACQAAAsAAQKfxYAAhIACAjBGuozAEUCABIACAjBGuozAEUCAAAA.',['外号']='外号石皮:BAAALAADCgcIBwAAAA==.',['多乐']='多乐港:BAABLAAFFH8HAAIMAAYIBSKaGADWAQAMAAYIBSKaGADWAQAAAA==.',['夜之']='夜之封月:BAAALAAFFAIIBAABLAAFFAYIEAACAIwgAA==.',['夜舞']='夜舞神棍骑:BAAALAAECgYIAwAAAA==.',['夢奇']='夢奇跡:BAAALAAECgYICgAAAA==.',['大种']='大种牛:BAABLAAECn8VAAQPAAYIHxH2bABPAQAPAAYIHxH2bABPAQAWAAYIQwdCegDdAAAXAAQIbAQmQwBmAAAAAA==.',['大肉']='大肉肉包:BAAALAAFFAcIAwAAAA==.',['天启']='天启四骑士:BAABLAAFFH8FAAIMAAIINwywcwCOAAAMAAIINwywcwCOAAAAAA==.',['天啊']='天啊你真高:BAAALAADCgIIAgAAAA==.',['天外']='天外飞小牛:BAAALAAECgQIBAAAAA==.',['天官']='天官赐福:BAAALAAECgYIBgABLAAFFAgIGgAYAH4UAA==.',['天谴']='天谴五骑士:BAABLAAFFH8SAAMMAAMICxDyZQB+AAAMAAMICxDyZQB+AAAZAAEIFQ3MIAA8AAAAAA==.',['失约']='失约海:BAAALAAECgQIBAAAAA==.',['奈斯']='奈斯特咪凸:BAAALAAECgYIBgAAAA==.',['奶上']='奶上天:BAAALAAFFAIIAgAAAA==.',['如夢']='如夢:BAAALAAECggICAAAAA==.',['妩媚']='妩媚丶小女人:BAAALAAECgEIAQAAAA==.',['妮莎']='妮莎瑞文:BAAALAAECgMIAwAAAA==.',['姑苏']='姑苏:BAABLAAFFH8GAAICAAYIiggJRQCFAAACAAYIiggJRQCFAAAAAA==.',['宇宙']='宇宙运气王:BAAALAAECgUIBQAAAA==.',['完全']='完全不懂浪漫:BAAALAAFFAIIAgAAAA==.',['定帧']='定帧珍珠:BAAALAADCgUIBQABLAAFFAIIBAADAAAAAA==.',['宜春']='宜春三阳:BAAALAAECgcIBwAAAA==.',['寂灭']='寂灭的骨头:BAAALAAECgYIBwAAAA==.',['寫下']='寫下你的温柔:BAAALAADCggICAAAAA==.',['导演']='导演丶我死哪:BAAALAAFFAIIAgAAAA==.',['小夕']='小夕夕:BAAALAADCgMIAwAAAA==.',['小废']='小废:BAABLAAFFH8KAAICAAUI+QohMwDpAAACAAUI+QohMwDpAAAAAA==.',['小时']='小时光:BAAALAAECgMIAwAAAA==.',['小期']='小期盼:BAAALAAECgYIBgAAAA==.',['小浪']='小浪蹄儿:BAABLAAFFH8GAAIEAAIImw4fGgBtAAAEAAIImw4fGgBtAAAAAA==.',['小狐']='小狐空幻:BAAALAAFFAIIAgAAAA==.',['小猪']='小猪苒:BAAALAAECgcICwAAAA==.',['小猫']='小猫菲儿:BAAALAAECgYIBgAAAA==.',['小的']='小的德德:BAABLAAFFH8PAAMWAAMInAw1FADEAAAWAAMIlAg1FADEAAAQAAIIBA95DgAqAAABLAAFFAYIEAACAIwgAA==.',['小祈']='小祈盼:BAAALAAECgMIAwAAAA==.',['小风']='小风刃:BAAALAAECgYIBgAAAA==.',['尘世']='尘世遗骸:BAACLAAFFH8PAAIZAAUI5xNRBgAwAQAZAAUI5xNRBgAwAQAsAAQKfx0AAhkABgi6JboLAJYCABkABgi6JboLAJYCAAEsAAUUBggiAAEAPiMA.',['尘灬']='尘灬觞:BAAALAAECgYICQABLAAFFAYIEAACAIwgAA==.',['尨樧']='尨樧銀狼:BAAALAAECgUIBQAAAA==.',['山君']='山君与见山:BAAALAAFFAMIAgAAAA==.',['巅峰']='巅峰之力:BAAALAAECgIIAgAAAA==.',['川口']='川口那小子:BAAALAADCgEIAQAAAA==.',['巫喵']='巫喵王之谜:BAAALAAECgYIBwAAAA==.',['布灵']='布灵布灵:BAAALAAECgUIBQAAAA==.',['希尔']='希尔瓦娜绿皮:BAAALAAECggICAAAAA==.',['带妳']='带妳私奔:BAAALAAFFAIIBAAAAA==.',['幸福']='幸福的小强:BAAALAAFFAIIAgAAAA==.',['幻月']='幻月丶:BAAALAAFFAIIAgAAAA==.幻月星河:BAAALAAFFAIIAgAAAA==.',['幽灵']='幽灵咖啡:BAAALAAECgYIBgAAAA==.',['幽靈']='幽靈獵灬手:BAABLAAECn8gAAMBAAgIRhMMUgCgAQABAAgIRhMMUgCgAQAaAAIIngZutABHAAAAAA==.',['彬彬']='彬彬的:BAAALAAECgcICgAAAA==.',['往事']='往事隨風:BAAALAAECgYICgAAAA==.',['微笑']='微笑向暖丶:BAABLAAFFH8GAAIaAAII+BiLIACIAAAaAAII+BiLIACIAAAAAA==.',['怀恋']='怀恋九妹:BAAALAADCgYIBgAAAA==.',['恋恋']='恋恋:BAAALAAECgEIAQAAAA==.',['悄悄']='悄悄摸鱼:BAAALAAECgIIAgAAAA==.',['悲歌']='悲歌之殇:BAAALAAECgQIBAAAAA==.',['慑砂']='慑砂:BAABLAAFFH8LAAIBAAYIAxmpKgCJAQABAAYIAxmpKgCJAQABLAAFFAYIIgABAD4jAA==.',['我先']='我先走你断后:BAAALAAFFAIIBAAAAA==.',['我兜']='我兜里的糖甜:BAAALAAFFAIIBAAAAA==.',['我去']='我去初音:BAAALAADCgUIBQAAAA==.',['我看']='我看不见啦:BAAALAAECgIIAgAAAA==.',['战傲']='战傲天:BAAALAAECgEIAQAAAA==.',['战卝']='战卝初生牛犊:BAAALAADCgEIAQAAAA==.',['打脑']='打脑壳:BAAALAADCgEIAQAAAA==.',['扬扬']='扬扬凑宝:BAAALAAECgYIDAAAAA==.',['抹灭']='抹灭:BAAALAAECgQIBAAAAA==.',['拖鞋']='拖鞋和林志玲:BAAALAAECgMIAwAAAA==.拖鞋和狗:BAAALAAECgUICAAAAA==.',['拥涌']='拥涌俑佣:BAABLAAFFH8LAAMbAAYIEQp2IQA1AQAbAAYIEQp2IQA1AQASAAUIyQJSGQDnAAABLAAFFAgIJAAHAJImAA==.',['拾忆']='拾忆少女的梦:BAACLAAFFH8PAAIPAAII/yEKKwDDAAAPAAII/yEKKwDDAAAsAAQKfyMAAg8ABwhiHU43AAICAA8ABwhiHU43AAICAAAA.',['指环']='指环丶:BAAALAADCggICAAAAA==.',['挽手']='挽手说梦话:BAAALAAECgYICgAAAA==.',['斩断']='斩断奈何桥:BAAALAAECgcIEAAAAA==.',['施道']='施道芬贝格:BAAALAAECgEIAQAAAA==.',['无聊']='无聊的熊三:BAAALAAECgQIBAAAAA==.',['明丶']='明丶:BAAALAAECgYIBgAAAA==.',['星海']='星海楛:BAAALAAECgEIAQAAAA==.星海琥:BAAALAADCgYIBgAAAA==.星海糊:BAAALAADCgEIAQAAAA==.',['時光']='時光丶:BAABLAAFFH8KAAMMAAIImxnecwBNAAAMAAIImxnecwBNAAAZAAEIJA2VIAA/AAAAAA==.',['晚洛']='晚洛初羽时丶:BAAALAAECggICAAAAA==.',['暗淡']='暗淡的矿脉:BAAALAADCgcIBwAAAA==.',['暴力']='暴力小伙伴:BAAALAAFFAIIBAABLAAFFAgIMQARAGYeAA==.',['暴怒']='暴怒的黑牛:BAAALAAECgEIAQAAAA==.',['暴行']='暴行:BAAALAAECgUIBQAAAA==.',['暴躁']='暴躁小伙伴:BAAALAAFFAIIBAABLAAFFAgIMQARAGYeAA==.',['最初']='最初鍀梦想:BAAALAAECgYIBgAAAA==.',['最后']='最后的风行者:BAAALAAECgYIDAAAAA==.',['月影']='月影之怒:BAAALAAECgIIAgAAAA==.',['月晴']='月晴歌:BAAALAAECgYIBgAAAA==.',['月珑']='月珑:BAAALAAECgYICAAAAA==.',['木小']='木小涕:BAAALAAFFAMIAwAAAA==.',['朴人']='朴人猛:BAAALAAFFAIIAgAAAA==.',['杰洛']='杰洛士灬:BAAALAAECgQIBAAAAA==.',['板甲']='板甲辣妹潼:BAABLAAFFH8ZAAICAAYIriQgCwDsAQACAAYIriQgCwDsAQAAAA==.',['极致']='极致扒妹:BAAALAAECgUIBQAAAA==.',['林卡']='林卡:BAACLAAFFH8sAAMHAAcIMCH4DAA0AgAHAAcIMCH4DAA0AgAcAAEIiiDaIwBWAAAsAAQKfxgAAwcACAimIQ4gAM0CAAcACAimIQ4gAM0CABwAAgjLHGt/AH0AAAAA.',['果儿']='果儿佟佟:BAAALAAECgYIDQAAAA==.',['柔情']='柔情的小妈:BAAALAAFFAEIAQAAAA==.',['格丽']='格丽乔:BAAALAAECgQIBAAAAA==.',['桜丶']='桜丶:BAAALAAECgYIDAAAAA==.',['桥本']='桥本环奈:BAAALAAFFAYIBAAAAA==.',['梦已']='梦已丶久远:BAABLAAECn8VAAICAAgItx1wNACiAgACAAgItx1wNACiAgAAAA==.',['梦幻']='梦幻紫月:BAACLAAFFH8TAAIVAAUIzgfrFQDWAAAVAAUIzgfrFQDWAAAsAAQKfxQAAhUACAifDcEPAEYBABUACAifDcEPAEYBAAAA.',['梵门']='梵门嗔徒:BAAALAAECgEIAQAAAA==.',['棒棒']='棒棒的好二萌:BAAALAAECggICgAAAA==.',['森西']='森西:BAABLAAFFH8GAAIbAAYIoggiIAA/AQAbAAYIoggiIAA/AQABLAAFFAYIIgABAD4jAA==.',['楓葉']='楓葉纏綿:BAAALAADCgQIBAAAAA==.',['楚璇']='楚璇:BAABLAAFFH8kAAICAAYIECXzBQAlAgACAAYIECXzBQAlAgAAAA==.',['横釖']='横釖戰兲:BAAALAADCgIIAgAAAA==.',['橙浮']='橙浮:BAAALAAECgIIAgAAAA==.',['欧皇']='欧皇豹纹:BAAALAADCgIIAgAAAA==.',['武能']='武能定人凄:BAAALAAECgYIBgAAAA==.',['比企']='比企谷八幡:BAAALAAECgYIBgAAAA==.',['比鲁']='比鲁斯:BAAALAAFFAEIAQAAAA==.',['江湖']='江湖路远:BAAALAAECgYIBwAAAA==.',['汼牛']='汼牛牜牪犇:BAABLAAFFH8IAAIaAAgI4gadCQAVAQAaAAgI4gadCQAVAQABLAAFFAgIJAAHAJImAA==.',['法丶']='法丶十三:BAAALAAFFAIIBAAAAA==.',['法天']='法天象地:BAAALAAECgYIBgAAAA==.',['波雅']='波雅汉库克丶:BAAALAAFFAIIBAAAAA==.',['泪水']='泪水满溢:BAAALAADCgcIBAAAAA==.',['泰勒']='泰勒摩森:BAAALAAECgUIBQAAAA==.',['流氓']='流氓筋骨强:BAAALAAFFAIIBAAAAA==.',['浪里']='浪里黑白条:BAAALAAFFAIIAgAAAA==.',['涂山']='涂山雪:BAAALAAECgYIBgAAAA==.',['清晰']='清晰大自然:BAAALAAECggICAAAAA==.',['清穗']='清穗:BAABLAAFFH8HAAMLAAMIQgbiFABPAAALAAMIlwXiFABPAAACAAIItgWTgQAqAAAAAA==.',['湮灭']='湮灭壹壹:BAAALAAECgYIBwAAAA==.',['溡绱']='溡绱乄貪鈊:BAAALAAFFAIIAgAAAA==.',['满山']='满山找牛牛:BAAALAAECgEIAgAAAA==.',['火柴']='火柴棍:BAAALAAECgIIAgAAAA==.',['灬明']='灬明灬:BAAALAAFFAIIAgAAAA==.',['灬暗']='灬暗之誓约灬:BAAALAAECgIIAgAAAA==.',['灬殇']='灬殇丨残魂:BAABLAAECn8VAAINAAYILBzWGwC2AQANAAYILBzWGwC2AQAAAA==.',['灼目']='灼目黑电:BAAALAADCgYIBgAAAA==.',['灾厄']='灾厄永恒:BAAALAAECgQIBAAAAA==.',['炎帝']='炎帝:BAAALAAECgYICgAAAA==.',['点头']='点头魔丶:BAAALAAECgcIBwAAAA==.',['烁烁']='烁烁发光丶:BAAALAAECgUIBQAAAA==.',['烈焰']='烈焰:BAABLAAECn8UAAICAAYIJx3zeAD4AQACAAYIJx3zeAD4AQAAAA==.',['煎饼']='煎饼狗子:BAABLAAECn8gAAIdAAcIVw2GPwBzAQAdAAcIVw2GPwBzAQAAAA==.',['煙花']='煙花过後:BAAALAADCgUIBQAAAA==.',['煙雨']='煙雨江南:BAAALAAECggICAAAAA==.',['熊猫']='熊猫先灬森:BAAALAAECgQIBAAAAA==.',['燃燒']='燃燒軍團:BAAALAAECgMIAwAAAA==.',['爆炎']='爆炎使徒:BAAALAAFFAIIAwAAAA==.',['爆笑']='爆笑丿红红:BAAALAAECgIIAgAAAA==.',['爱德']='爱德王子:BAAALAAECgYIBgAAAA==.',['爱莎']='爱莎丶云歌:BAAALAAECggIEwAAAA==.',['牛叉']='牛叉:BAAALAAECgUIDQAAAA==.',['牛西']='牛西牛:BAAALAAECgMIAwAAAA==.',['犬来']='犬来八荒:BAAALAADCgcIBwAAAA==.',['狂卷']='狂卷尼姑庵:BAAALAAECgcIEQAAAA==.',['狂战']='狂战比鲁斯:BAAALAAECgEIAQAAAA==.',['狐一']='狐一菲:BAABLAAFFH8JAAIdAAMIoRfpCwCbAAAdAAMIoRfpCwCbAAABLAAFFAYIEAACAIwgAA==.',['狐猎']='狐猎猎:BAAALAAECgYIDgAAAA==.',['狗二']='狗二蛋的崛起:BAACLAAFFH8wAAQHAAgILyaLBAC5AgAHAAgI6SWLBAC5AgAeAAEIASYdBQBxAAAcAAEIvCGBIwBXAAAsAAQKfz8AAwcACAilJUkLAEEDAAcACAghJUkLAEEDABwABAiDJXdBAGgBAAAA.',['猎个']='猎个蛋:BAAALAAECgYIDwAAAA==.',['猎图']='猎图:BAAALAAECgYICQAAAA==.',['猫之']='猫之治疗术:BAAALAAECgMIBAAAAA==.',['猫公']='猫公:BAAALAAECggICAAAAA==.',['獣王']='獣王归来夕:BAAALAADCgMIAwAAAA==.',['玄武']='玄武门李老二:BAAALAAECgQIBAAAAA==.',['玄程']='玄程:BAACLAAFFH8OAAQLAAMI2QZhFABTAAACAAIIuQULWgCHAAALAAMI2QZhFABTAAAKAAEIJAGkMQAaAAAsAAQKfyEAAwIACAi6EbRiAD8BAAIABwhND7RiAD8BAAsABwgZEMZAADcBAAAA.',['理塘']='理塘王:BAAALAADCgcIBwAAAA==.',['瘦锰']='瘦锰锰:BAAALAAECgQIBAAAAA==.',['白月']='白月魁:BAAALAAFFAIIBAAAAA==.',['皆盡']='皆盡丶:BAAALAAFFAIIAgAAAA==.',['神圣']='神圣仲裁者:BAAALAAECgQIBAAAAA==.',['神引']='神引:BAABLAAFFH8KAAIRAAIIIhezUQCPAAARAAIIIhezUQCPAAAAAA==.',['空弦']='空弦:BAACLAAFFH8iAAIBAAYIPiNrFADsAQABAAYIPiNrFADsAQAsAAQKfxgAAgEABghnJVc2AIMCAAEABghnJVc2AIMCAAAA.',['穿云']='穿云一箭:BAABLAAFFH8GAAIBAAIIWwjRrgA4AAABAAIIWwjRrgA4AAABLAAFFAYIEAACAIwgAA==.',['筱筠']='筱筠:BAAALAAECgYIEgAAAA==.',['粉粉']='粉粉牛:BAABLAAFFH8HAAISAAIIXRgmSQCLAAASAAIIXRgmSQCLAAAAAA==.',['红油']='红油果冻:BAAALAAECgMIAwAAAA==.',['纯爷']='纯爷们:BAAALAAECgIIAwAAAA==.',['美不']='美不美看姿态:BAAALAAECgYIBgAAAA==.',['美美']='美美莹:BAABLAAFFH8KAAIfAAIIxx/OOQCeAAAfAAIIxx/OOQCeAAABLAAFFAYIEAACAIwgAA==.',['耶路']='耶路撒冷之泪:BAAALAADCggICAAAAA==.',['联盟']='联盟士兵:BAAALAAECgMIAwAAAA==.',['背刺']='背刺高手:BAABLAAFFH8KAAIOAAIIhR7nFgCjAAAOAAIIhR7nFgCjAAABLAAFFAgIMQARAGYeAA==.',['胖兜']='胖兜兜麦麦:BAAALAAECgQIBAAAAA==.',['胡椒']='胡椒:BAAALAAFFAQIBAAAAA==.',['脑袋']='脑袋还在:BAAALAAFFAIIAgABLAAFFAUIGQABADMcAA==.',['自然']='自然风暴:BAACLAAFFH8MAAMSAAIIkCZrMwDaAAASAAIIkCZrMwDaAAAgAAIICQOTCAB5AAAsAAQKfxsAAyAACAghGLELADACACAACAj3FrELADACABsABQhUF+p1AF0BAAEsAAUUBggQAAIAjCAA.',['舞丶']='舞丶若汐:BAAALAADCgIIAgAAAA==.',['舞蹈']='舞蹈牛牛:BAAALAAECgIIAgAAAA==.',['艾维']='艾维拉:BAAALAAECgYIBgAAAA==.',['艾薇']='艾薇拉:BAAALAAECgUIBwAAAA==.',['芝仕']='芝仕雪豹:BAAALAAFFAIIBAAAAA==.',['花丶']='花丶雪:BAAALAAECgQIBAAAAA==.',['花卷']='花卷儿:BAAALAADCgIIAgAAAA==.',['花淡']='花淡媣:BAAALAAECgYICAAAAA==.花淡染:BAAALAAFFAEIAQAAAA==.',['荼吉']='荼吉尼天:BAAALAADCgUIBQAAAA==.',['莱财']='莱财:BAABLAAECn8UAAIMAAgIdAUffwDtAAAMAAgIdAUffwDtAAAAAA==.',['萌萌']='萌萌德:BAABLAAFFH8NAAIPAAYIZyPiBgBAAgAPAAYIZyPiBgBAAgAAAA==.萌萌萨:BAAALAAFFAgIAgAAAA==.',['萨佢']='萨佢老味:BAABLAAFFH8HAAMSAAMIvgPUWgBlAAASAAMIvgPUWgBlAAAbAAIIOQfiRwBAAAAAAA==.',['葡萄']='葡萄结:BAAALAAECgYIBwAAAA==.',['蓝娃']='蓝娃娃:BAAALAAECggICAAAAA==.',['蓬莱']='蓬莱山輝夜:BAAALAAFFAIIBAAAAA==.',['行路']='行路难:BAAALAAFFAYIBAAAAA==.',['西多']='西多夫高:BAAALAADCgMIAwAAAA==.',['西迪']='西迪厄斯丶:BAAALAAECgQIBAAAAA==.',['让我']='让我灬划一会:BAABLAAFFH8HAAIMAAIIIgyJcgCPAAAMAAIIIgyJcgCPAAAAAA==.',['诗丨']='诗丨妤:BAABLAAFFH8IAAMhAAIIIAzCBQBcAAAiAAII+ga8PQB6AAAhAAIIIAzCBQBcAAAAAA==.',['贝恩']='贝恩丶血蹄:BAAALAAECgYICAAAAA==.',['赫拉']='赫拉格:BAAALAAECggICAAAAA==.',['赫默']='赫默:BAABLAAFFH8IAAIPAAYIVhIWFwB7AQAPAAYIVhIWFwB7AQABLAAFFAYIIgABAD4jAA==.',['超气']='超气:BAABLAAFFH89AAMBAAgI7iR9AQD0AgABAAgI7iR9AQD0AgAaAAEIEwpRNwA5AAAAAA==.',['轩萧']='轩萧:BAAALAAECgYIBgAAAA==.',['辛达']='辛达拉的噩梦:BAAALAAECgYIEQAAAA==.',['这锅']='这锅不背:BAAALAAECggICAAAAA==.',['进退']='进退丨由风:BAAALAAFFAIIAgAAAA==.',['追星']='追星踏风:BAAALAAECgYIDAAAAA==.',['透的']='透的赖:BAAALAAECgYIDQAAAA==.',['逐星']='逐星者丿锟仔:BAAALAAECgQIBAAAAA==.逐星者丿锟叔:BAAALAAECgYIBgAAAA==.',['進魤']='進魤戰熋:BAABLAAFFH8PAAMKAAIIHgllKQBnAAAKAAIIHgllKQBnAAACAAIIEBBQbQA/AAAAAA==.',['那年']='那年我五岁:BAAALAAECggIDgAAAA==.',['郭郭']='郭郭:BAAALAAECgYIDgAAAA==.',['醇比']='醇比牙丶:BAAALAAECgUIBQAAAA==.',['醉天']='醉天灬下:BAAALAAECgIIAgAAAA==.',['醉执']='醉执灬着:BAAALAAFFAIIAwAAAA==.',['醉拳']='醉拳甘艿迪:BAABLAAFFH8JAAIOAAUISAzGEgDHAAAOAAUISAzGEgDHAAAAAA==.',['铃兰']='铃兰:BAAALAAFFAIIAgAAAA==.',['锦添']='锦添:BAABLAAFFH8QAAICAAIIjCDjKAC3AAACAAIIjCDjKAC3AAAAAA==.',['门外']='门外青山:BAAALAADCgcIBwAAAA==.',['问题']='问题不噠:BAAALAADCgYICwAAAA==.',['阳光']='阳光灬:BAAALAAECgQIBAAAAA==.',['阿斯']='阿斯卡纶:BAABLAAFFH8LAAIJAAUIXQreKwAEAQAJAAUIXQreKwAEAQABLAAFFAYIIgABAD4jAA==.',['阿曼']='阿曼尼神牛:BAAALAAECgIIAgAAAA==.',['雨伞']='雨伞:BAAALAAECgQIBAAAAA==.',['雪之']='雪之紫龍:BAAALAADCgQIBQAAAA==.',['零度']='零度丶雪飛揚:BAAALAAECggIDgAAAA==.',['雷克']='雷克萨斯:BAAALAAECgEIAQAAAA==.',['雾月']='雾月:BAABLAAECn8YAAIdAAgIDgZbOQB8AAAdAAgIDgZbOQB8AAAAAA==.雾月幻雨:BAABLAAFFH8MAAIMAAMI+RXSXwCOAAAMAAMI+RXSXwCOAAAAAA==.',['霓虹']='霓虹:BAABLAAFFH8PAAIRAAgItB65BgB7AgARAAgItB65BgB7AgAAAA==.',['霸王']='霸王别姬:BAAALAAECgUIBQAAAA==.',['靉丽']='靉丽銯丶賯児:BAAALAAECgYICAAAAA==.',['青影']='青影:BAABLAAFFH8fAAMNAAYIDiAnCABDAQAOAAQIQRu6CgBjAQANAAUICBwnCABDAQAAAA==.',['青芒']='青芒:BAAALAADCggICwAAAA==.',['青蛇']='青蛇她姐:BAAALAADCgIIAgAAAA==.',['非含']='非含:BAAALAAECgYIBgAAAA==.',['韩小']='韩小田:BAAALAADCgIIAgAAAA==.',['顶针']='顶针珍珠:BAAALAAECgYIDAABLAAFFAIIBAADAAAAAA==.',['顺风']='顺风尿湿鞋:BAAALAAECgMIBAABLAAFFAgIBgABADQGAA==.',['顾陌']='顾陌一米六丶:BAABLAAFFH8IAAIbAAYIHyJdIQA2AQAbAAYIHyJdIQA2AQAAAA==.',['風中']='風中的男子:BAAALAAFFAIIAgAAAA==.',['风往']='风往北吹:BAAALAAFFAIIAgAAAA==.',['风靡']='风靡:BAAALAAECgYICQAAAA==.',['飞翔']='飞翔的神:BAAALAAECgYIBgAAAA==.',['骑的']='骑的是非:BAAALAAECgIIAQAAAA==.',['鲁西']='鲁西西:BAAALAAFFAIIAgAAAA==.',['黑夜']='黑夜铭刻:BAAALAAECgQIBAAAAA==.',['黑弥']='黑弥撒丶:BAAALAAECgEIAQAAAA==.',['黑暗']='黑暗追随者:BAAALAAECgUIBQAAAA==.',['黝黑']='黝黑蜗壳:BAABLAAFFH8IAAIMAAIIqBxQcABTAAAMAAIIqBxQcABTAAAAAA==.',['龙笼']='龙笼珑隆:BAABLAAFFH8NAAMFAAYIPAsrBwA2AQAFAAYIOwgrBwA2AQAGAAMI3g8FEQDVAAABLAAFFAgIJAAHAJImAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end