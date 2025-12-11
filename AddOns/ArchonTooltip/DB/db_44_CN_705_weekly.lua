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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Hunter-Survival','Hunter-BeastMastery','DeathKnight-Frost','Paladin-Retribution','Shaman-Restoration','DemonHunter-Havoc','Mage-Frost','DeathKnight-Unholy','Mage-Arcane','Warrior-Protection','Warrior-Fury','Druid-Restoration','Druid-Balance','Paladin-Protection','Shaman-Elemental','Priest-Holy','Priest-Discipline','Hunter-Marksmanship','Monk-Windwalker','DeathKnight-Blood','Priest-Shadow','Druid-Guardian','Rogue-Assassination','DemonHunter-Vengeance','Monk-Brewmaster','Druid-Feral','Rogue-Outlaw','Rogue-Subtlety','Paladin-Holy',}; local provider = {region='CN',realm='暮色森林',name='CN',type='weekly',zone=44,date='2025-12-06',data={As='Asuka:BAAALAAFFAIIAgAAAA==.',At='Atina:BAAALAAECgEIAQAAAA==.',Au='Augustus:BAAALAAECgYIEAAAAA==.',Br='Brollan:BAAALAAECgYICwAAAA==.',Co='Contorl:BAAALAADCgUIBQAAAA==.Cowboy:BAAALAAFFAEIAQAAAA==.',De='Deathme:BAAALAAFFAIIAgAAAA==.Demantoid:BAACLAAFFH8PAAMBAAMIiBT2JgDxAAABAAMIiBT2JgDxAAACAAIIGwz+GQCPAAAsAAQKfxoABAEABwiWG407AEsCAAEABwiWG407AEsCAAIABQieEdBTACYBAAMAAggnDo4uAH4AAAAA.Destiny:BAABLAAFFH8GAAMEAAIIbBsnAwCrAAAEAAIIbBsnAwCrAAAFAAII5hWplABDAAAAAA==.',Dh='Dhh:BAAALAAECgEIAQAAAA==.',Ex='Existed:BAABLAAFFH8gAAIGAAYIYyL3FwDaAQAGAAYIYyL3FwDaAQAAAA==.',Fl='Flammable:BAAALAADCgEIAQAAAA==.',Fr='Fraction:BAAALAAECgMIAwAAAA==.',Ge='Gevjon:BAAALAAFFAQIBAAAAA==.',Gl='Glbertv:BAAALAAECgMIAwAAAA==.',He='Hessonite:BAAALAAECgEIAQAAAA==.',Ho='Horderogue:BAAALAAECgQIBAAAAA==.Howdareu:BAAALAAECgMIAQAAAA==.',Is='Isnow:BAABLAAFFH8bAAIGAAYIhhqhIACyAQAGAAYIhhqhIACyAQAAAA==.',Ka='Kaelh:BAAALAAECgMIBwAAAA==.',Lr='Lradd:BAAALAADCgIIAgAAAA==.',Ma='Malestorm:BAAALAAECgMICQAAAA==.Mamon:BAAALAAECgQIBAAAAA==.Maxime:BAAALAAECgUICAAAAA==.',Mi='Mi:BAAALAAECgYIBwAAAA==.',Mo='Mond:BAABLAAFFH8OAAMCAAYIzA+CBQDqAAACAAQIvhaCBQDqAAABAAII5wEtVABbAAAAAA==.',No='Notexist:BAACLAAFFH8iAAIHAAYIoiG8BQALAgAHAAYIoiG8BQALAgAsAAQKfyMAAgcACAjoI54fAPMCAAcACAjoI54fAPMCAAAA.Notoobad:BAAALAAFFAEIAQAAAA==.',Qr='Qredm:BAAALAAECgUIBQAAAA==.',Ra='Radiogaga:BAAALAAECgQIBAAAAA==.Radiosasa:BAAALAAECgQIBgAAAA==.',Sh='Shamanship:BAACLAAFFH8FAAIIAAMIIQPxXABhAAAIAAMIIQPxXABhAAAsAAQKfxUAAggABgijFidCAFIBAAgABgijFidCAFIBAAAA.',Su='Sulla:BAAALAAECgYIEgAAAA==.',Th='Thekingdh:BAAALAAECgUIBQAAAA==.',Va='Vampire:BAABLAAFFH8GAAIJAAYIdwFvOACyAAAJAAYIdwFvOACyAAABLAAFFAgIDAAJAGUZAA==.Vanessa:BAAALAAFFAIIBAAAAA==.',['一个']='一个骑:BAAALAADCgYIBgAAAA==.',['一只']='一只小水法:BAAALAAECggICAAAAA==.',['一叶']='一叶知秋:BAAALAAFFAMIAwABLAAFFAQIBgABAJgKAA==.',['一德']='一德一:BAAALAADCgQIBAAAAA==.',['一桃']='一桃丘一:BAAALAAECgYIBgAAAA==.',['一般']='一般般吧:BAABLAAECn8YAAIKAAYIGiNZGQBPAgAKAAYIGiNZGQBPAgAAAA==.',['一醉']='一醉猫一:BAAALAADCgQIBAAAAA==.',['丁丁']='丁丁打车:BAAALAAECgQIDgAAAA==.',['七彩']='七彩缝纫机:BAAALAADCgcIDQAAAA==.',['万華']='万華千鳥:BAAALAAECgYIBgAAAA==.',['三叶']='三叶草:BAAALAAECgIIAwAAAA==.',['不服']='不服就是干:BAABLAAFFH8FAAIIAAUIDAMePACyAAAIAAUIDAMePACyAAAAAA==.',['不知']='不知名的萨满:BAACLAAFFH8KAAIIAAIIDA9pXQBgAAAIAAIIDA9pXQBgAAAsAAQKfxcAAggACAhkEqoxAJkBAAgACAhkEqoxAJkBAAAA.',['丛林']='丛林有情狼:BAAALAAECgUIBgAAAA==.',['丫丫']='丫丫一丫丫:BAAALAAECgQIBAAAAA==.丫丫宝贝兔:BAAALAAECgYICgAAAA==.丫丫宝贝妈:BAAALAAFFAIIBAAAAA==.丫丫小宝宝:BAAALAAECgQIBAAAAA==.丫丫小宝贝:BAAALAAECgUIBQAAAA==.丫丫爱睡觉觉:BAAALAAECgUIBgAAAA==.',['丶冷']='丶冷月:BAAALAAECgIIAgAAAA==.',['云衶']='云衶心:BAABLAAFFH8MAAIKAAMI+xSkCwChAAAKAAMI+xSkCwChAAAAAA==.',['五十']='五十五个圣光:BAAALAAECgMIAwAAAA==.',['井芹']='井芹仁菜樣:BAABLAAFFH8GAAMGAAIIZB+zPwCzAAAGAAIIZB+zPwCzAAALAAEI+gF9IABAAAAAAA==.',['亚煞']='亚煞极:BAAALAAECgIIAgAAAA==.',['人偶']='人偶忧瞳:BAABLAAFFH8MAAIMAAYIbB4GBwA8AgAMAAYIbB4GBwA8AgAAAA==.',['仁慈']='仁慈的妖:BAAALAAFFAEIAQAAAA==.',['伸縮']='伸縮自如的愛:BAAALAADCgcIBwAAAA==.',['你们']='你们卡吗:BAAALAAECgUIBQAAAA==.',['你猫']='你猫爷来了:BAAALAAECgMIAwAAAA==.',['侽茼']='侽茼茄耗油:BAABLAAFFH8FAAMNAAMIVhdPHwB/AAANAAMIVhdPHwB/AAAOAAIIagR2SwB2AAABLAAFFAYIDwAOAPkOAA==.',['修谱']='修谱丿诺斯丨:BAABLAAFFH8JAAMBAAYI3Aa+PAAQAQABAAYIVQW+PAAQAQACAAEIiBNEKABQAAAAAA==.',['偃旗']='偃旗息鼓:BAAALAAECgYIBwAAAA==.',['傲慢']='傲慢的蛋蛋:BAAALAAECgUIBQAAAA==.',['像个']='像个老头:BAABLAAFFH8FAAIJAAMIjwM5RgBhAAAJAAMIjwM5RgBhAAAAAA==.',['儰装']='儰装灬嗳謺妳:BAAALAAECgYICAAAAA==.',['八块']='八块凹凸肌:BAAALAAECgIIAgAAAA==.',['再看']='再看我就揍你:BAAALAAFFAIIBAAAAA==.',['冬日']='冬日:BAAALAAECgYIDAAAAA==.',['冰眼']='冰眼斯佳蒂:BAAALAAECgYIBgAAAA==.',['凯瑟']='凯瑟琳黎恩:BAAALAAECgUIBgAAAA==.',['千早']='千早爱音樣:BAAALAADCgEIAQABLAAFFAIIBgAGAGQfAA==.',['南肯']='南肯摆子:BAAALAAFFAIIAgAAAA==.',['卡塞']='卡塞米罗:BAAALAAECgYICgAAAA==.',['卡門']='卡門碎星者:BAABLAAFFH8IAAIIAAYImyHMCgAgAgAIAAYImyHMCgAgAgAAAA==.卡門罗拉娜:BAAALAAFFAIIAgAAAA==.',['卡门']='卡门影风:BAABLAAFFH8QAAMPAAYIRxeaBADoAQAPAAYIRxeaBADoAQAQAAIIlQIxKgBjAAAAAA==.',['又得']='又得取名字:BAAALAAECgUIBQAAAA==.',['只要']='只要你命硬:BAAALAAECgYICwAAAA==.',['叫兽']='叫兽:BAABLAAFFH8rAAIRAAYIyRG0BwBJAQARAAYIyRG0BwBJAQAAAA==.',['可爱']='可爱吕:BAABLAAFFH8JAAIIAAQIOAh5PwCoAAAIAAQIOAh5PwCoAAAAAA==.',['右手']='右手的風:BAAALAAFFAMIAwAAAA==.',['叶婧']='叶婧衣:BAABLAAECn8gAAMSAAgIMRFDMgBIAQASAAYInxVDMgBIAQAIAAgIJRDTvgAHAQAAAA==.',['吃大']='吃大米长大个:BAAALAAECgQIBAAAAA==.',['吕菲']='吕菲菲:BAAALAAFFAIIAgAAAA==.',['吕飞']='吕飞飞:BAAALAAFFAEIAQAAAA==.',['吴勉']='吴勉:BAAALAAECgYICAAAAA==.',['呆萌']='呆萌萌:BAAALAAFFAMIAwAAAA==.',['唔呼']='唔呼呼:BAAALAAECgYICAAAAA==.',['嘉泽']='嘉泽:BAAALAAECgUICwAAAA==.',['回忆']='回忆满满:BAAALAADCgEIAQAAAA==.',['团灭']='团灭发动机:BAAALAAECgIIAgAAAA==.',['团长']='团长我又蛇了:BAAALAAECgQIBAAAAA==.',['圣光']='圣光的赐福:BAAALAAECgUIBQAAAA==.',['坎坎']='坎坎胡:BAACLAAFFH8GAAITAAIIoAqXQgBlAAATAAIIoAqXQgBlAAAsAAQKfxQAAxMABgj7GdYjAJYBABMABggyGdYjAJYBABQABghtDt0aACABAAAA.',['塞瑞']='塞瑞斯星風:BAAALAAECgYIBgAAAA==.',['塞璐']='塞璐贝利亚:BAABLAAECn8UAAIHAAgIEww4XgBKAQAHAAgIEww4XgBKAQAAAA==.',['墨楓']='墨楓:BAAALAAECgYIBgAAAA==.',['墨黎']='墨黎:BAAALAAECgYIBgAAAA==.',['壅鑍']='壅鑍:BAAALAAECgUIBQAAAA==.',['夜乄']='夜乄白熙:BAAALAAECgMIAwAAAA==.夜乄辰星:BAAALAAECgMIAwAAAA==.',['夜之']='夜之媚影:BAAALAAECgYIBgAAAA==.夜之灵影:BAAALAAECgUIDAAAAA==.',['大丶']='大丶神:BAAALAAECgIIAgAAAA==.',['大蒜']='大蒜和咖啡:BAAALAAECgUIBQAAAA==.',['大表']='大表姐:BAAALAAECgQIBwAAAA==.',['大锤']='大锤锤:BAAALAAECgYIBgAAAA==.',['天意']='天意:BAAALAAECgYIBgAAAA==.',['夺命']='夺命大乌苏:BAAALAADCgIIAgAAAA==.',['奥丶']='奥丶姑:BAACLAAFFH8MAAIVAAMIpwtPIwCBAAAVAAMIpwtPIwCBAAAsAAQKfy8AAhUACAiOHvIaAIwCABUACAiOHvIaAIwCAAAA.',['奶油']='奶油大亏头:BAAALAADCgcIBwAAAA==.',['妮妮']='妮妮:BAAALAADCgMIAwAAAA==.',['子非']='子非鱼:BAAALAAFFAIIAwAAAA==.',['宁静']='宁静的夏日:BAABLAAFFH8FAAIQAAUI0QQEIAC/AAAQAAUI0QQEIAC/AAABLAAFFAgICAAWAOwAAA==.',['安度']='安度因乌瑞恩:BAABLAAFFH8IAAIHAAYIxAPWEgAjAQAHAAYIxAPWEgAjAQAAAA==.安度因落萨:BAAALAAFFAMIAwAAAA==.',['安然']='安然:BAABLAAFFH8SAAIIAAYI/A+dHwBfAQAIAAYI/A+dHwBfAQAAAA==.',['完败']='完败:BAAALAADCgIIAgAAAA==.',['实力']='实力派人士:BAAALAAECgYIDAAAAA==.',['寒依']='寒依依:BAABLAAFFH8FAAITAAMItQRINQCQAAATAAMItQRINQCQAAAAAA==.',['小亓']='小亓不要跑:BAAALAAECgYICwAAAA==.',['小哈']='小哈想养狗:BAAALAAECgEIAQAAAA==.',['小小']='小小钟:BAACLAAFFH8vAAIGAAcIyCKHCwBDAgAGAAcIyCKHCwBDAgAsAAQKfyYAAgYABgg7JlM2AJ0CAAYABgg7JlM2AJ0CAAAA.小小鲨鱼:BAAALAADCgYICgAAAA==.小小龙人:BAAALAAFFAIIAgABLAAFFAMICQAHAJMUAA==.',['小尼']='小尼斯:BAAALAAECgIIAgAAAA==.',['小星']='小星形:BAAALAAECgMIAwAAAA==.',['小晓']='小晓蛸:BAACLAAFFH8JAAIBAAIIPwf1ZQA6AAABAAIIPwf1ZQA6AAAsAAQKfzQAAgEACAi7EO81AHIBAAEACAi7EO81AHIBAAEsAAUUAwgJAAcAkxQA.',['小树']='小树丶小树:BAAALAAFFAIIBAAAAA==.',['小母']='小母牛翻单杠:BAAALAAFFAIIBAABLAAFFAYIIAAIAAgTAA==.',['小洛']='小洛:BAAALAAECgUIBQAAAA==.',['小熊']='小熊软糖:BAACLAAFFH8MAAIXAAQIlBaVEQDMAAAXAAQIlBaVEQDMAAAsAAQKfzcAAxcACAgvITwFAGgCABcACAgvITwFAGgCAAYABgh8GdCYANIBAAAA.',['小甜']='小甜甜:BAABLAAFFH8PAAIJAAYIfRgeHACUAQAJAAYIfRgeHACUAQAAAA==.',['小竹']='小竹竹:BAAALAADCgMIAwAAAA==.',['小紫']='小紫曼:BAAALAAECgYICwAAAA==.',['小鱼']='小鱼丸:BAABLAAFFH8GAAMYAAQIVBeiGwC/AAAYAAMIGh6iGwC/AAATAAEIGxBhTQBDAAABLAAFFAgIEQATAEQaAA==.',['少凡']='少凡:BAAALAAECgQIBAAAAA==.',['少糖']='少糖多冰:BAAALAADCgIIAgAAAA==.',['岁月']='岁月安然:BAABLAAFFH8MAAMZAAIIzhAuCABxAAAZAAIIzhAuCABxAAAQAAIIXwQnKQBpAAAAAA==.',['岭西']='岭西吴彦祖:BAABLAAFFH8bAAIFAAgIgRdXDgC/AQAFAAgIgRdXDgC/AQAAAA==.',['左手']='左手地狱:BAABLAAFFH8GAAIGAAII7xUBeABKAAAGAAII7xUBeABKAAAAAA==.',['巭犇']='巭犇:BAAALAAECgUIBQAAAA==.',['帕力']='帕力:BAAALAAFFAIIBAAAAA==.',['开心']='开心大笑:BAAALAADCgQIBAAAAA==.',['彼岸']='彼岸花:BAAALAAECgIIAwAAAA==.彼岸花未央:BAAALAAECgYIBwAAAA==.',['心跳']='心跳叁陸零:BAAALAAFFAIIAgAAAA==.',['心願']='心願:BAAALAAECgEIAQAAAA==.',['忧郁']='忧郁小蘑菇:BAABLAAECn8UAAIPAAYIPxNRcABFAQAPAAYIPxNRcABFAQAAAA==.',['恨意']='恨意的单行道:BAACLAAFFH8JAAIGAAMIswpSZgB9AAAGAAMIswpSZgB9AAAsAAQKfyYAAwYACAjwHIoTAEwCAAYACAjwHIoTAEwCAAsABghdDfovAEgBAAAA.',['情满']='情满四合院:BAAALAADCgQIBAAAAA==.',['感觉']='感觉崩崩哒:BAAALAAECgMIAwAAAA==.感觉很不错:BAAALAAECgYIBgAAAA==.',['愤怒']='愤怒的小蛋壳:BAAALAAECgYIEAAAAA==.',['战术']='战术:BAAALAADCggICAAAAA==.',['披着']='披着凉皮的糖:BAAALAADCgEIAQAAAA==.',['拉莫']='拉莫斯:BAAALAAECgYIBgAAAA==.',['指尖']='指尖的忧伤:BAAALAAECgQIBwAAAA==.指尖的疯狂:BAAALAAECgUICgAAAA==.',['掼蛋']='掼蛋皇城:BAAALAAFFAIIBAAAAA==.',['插头']='插头:BAABLAAFFH8TAAIIAAUI8hAzKQAbAQAIAAUI8hAzKQAbAQAAAA==.',['敏捷']='敏捷之蛇:BAAALAAECgYIAwAAAA==.',['教煌']='教煌陛下:BAAALAAECgMIBAAAAA==.',['教练']='教练我想打球:BAAALAAECgIIAgAAAA==.',['断月']='断月:BAAALAAECgEIAQAAAA==.',['无尘']='无尘:BAAALAAECgQIBAAAAA==.',['旭格']='旭格道伐考夫:BAAALAAECgYIBgAAAA==.',['易水']='易水寒庭:BAAALAAFFAIIAgAAAA==.',['春去']='春去秋来:BAABLAAFFH8GAAICAAIINRnNEABLAAACAAIINRnNEABLAAAAAA==.',['晒嘟']='晒嘟嘟:BAAALAAECgYIBgAAAA==.',['晒毛']='晒毛毛:BAAALAAECgIIAgAAAA==.',['暗夜']='暗夜德:BAAALAAECgYIDQAAAA==.暗夜牧:BAAALAAECgQIBAAAAA==.',['暗淡']='暗淡的月光:BAAALAAECgIIAgAAAA==.',['暗色']='暗色调:BAAALAAECgYIBgAAAA==.',['曰落']='曰落:BAABLAAECn8WAAIFAAYInR4TUgCgAQAFAAYInR4TUgCgAQAAAA==.',['最假']='最假演员:BAAALAAECgYIDAAAAA==.',['末日']='末日之仭:BAABLAAFFH8GAAIaAAIIoxtNGABUAAAaAAIIoxtNGABUAAAAAA==.',['柑蕉']='柑蕉桔李萝柚:BAAALAAFFAYIBAAAAA==.',['格鲁']='格鲁尔之子:BAAALAADCggIDAAAAA==.',['梅丶']='梅丶比斯:BAAALAAECgYIBgAAAA==.',['梅凉']='梅凉馨:BAAALAAFFAIIAgAAAA==.',['梅瑟']='梅瑟莫:BAAALAADCggICAAAAA==.',['椎名']='椎名市役所:BAAALAAECgcIBwAAAA==.',['楚王']='楚王爷:BAABLAAFFH8HAAIOAAMI4AuvPQBzAAAOAAMI4AuvPQBzAAAAAA==.',['樱桃']='樱桃丶:BAAALAAFFAIIAgAAAA==.',['橙意']='橙意满满:BAAALAAECgYIBgAAAA==.',['殇之']='殇之魇:BAABLAAECn8dAAIJAAYIEhYYnQCRAQAJAAYIEhYYnQCRAQAAAA==.',['殊途']='殊途:BAAALAAECgIIAgABLAAFFAcIOQAFADQmAA==.',['水灵']='水灵光:BAAALAAECgQIBAAAAA==.',['永和']='永和大王:BAAALAAFFAIIBAAAAA==.',['永夜']='永夜:BAAALAADCgcIBwAAAA==.',['沐浴']='沐浴圣光:BAAALAAECgYICAAAAA==.',['河下']='河下文楼:BAABLAAFFH8JAAIFAAUIugxCWADqAAAFAAUIugxCWADqAAAAAA==.',['法布']='法布雷嘉斯:BAAALAAECgYIBwAAAA==.',['泰山']='泰山:BAABLAAFFH8HAAIOAAMI+AaiPQB0AAAOAAMI+AaiPQB0AAAAAA==.',['洋芋']='洋芋:BAAALAAFFAEIAQAAAA==.',['浮沉']='浮沉:BAAALAAECgcIBwAAAA==.',['深山']='深山幽谷:BAAALAADCgEIAQAAAA==.',['清雾']='清雾星沂:BAAALAAECgYIEwAAAA==.',['清风']='清风丶雷鸣:BAABLAAECn8YAAIIAAYIuxOZiQBsAQAIAAYIuxOZiQBsAQAAAA==.',['漆月']='漆月:BAABLAAFFH8QAAIOAAUIsBZ7GAABAQAOAAUIsBZ7GAABAQAAAA==.',['演员']='演员:BAAALAAECgYIBwAAAA==.',['灀之']='灀之燃冰:BAAALAAECggICAAAAA==.',['灬小']='灬小脚冰凉丶:BAAALAAECgYIBwAAAA==.',['灬菜']='灬菜虚鲲灬:BAAALAAFFAIIAgAAAA==.',['灰常']='灰常会采集:BAAALAAECgEIAQAAAA==.灰常博爱:BAAALAAECgQIBgAAAA==.灰常小屁孩:BAAALAAECgYIDwAAAA==.灰常爱干净:BAABLAAECn8UAAMHAAgI/h4lJQDcAgAHAAgI/h4lJQDcAgARAAMI+RBQPgBNAAAAAA==.',['灵魂']='灵魂火焰:BAAALAAFFAIIAgAAAA==.',['炮灰']='炮灰式伦伦:BAAALAADCgYICgAAAA==.炮灰式稻草:BAABLAAECn8cAAIFAAgIKiQHTgCpAQAFAAgIKiQHTgCpAQAAAA==.',['熊德']='熊德一匹:BAABLAAECn8WAAMZAAYIXQyqGQC5AAAZAAYIXQyqGQC5AAAQAAYIcgI9VgBaAAAAAA==.',['熊猫']='熊猫的大乃至:BAAALAAECgMIAwAAAA==.',['猎迹']='猎迹累累:BAAALAAECggIEAAAAA==.',['猎魔']='猎魔丶迷踪:BAAALAADCgYIBgAAAA==.',['猛龙']='猛龙过江:BAAALAADCgEIAQAAAA==.',['率土']='率土之滨:BAAALAADCgUIBQAAAA==.',['玛里']='玛里奥:BAAALAADCgIIAgAAAA==.',['生生']='生生不息:BAABLAAECn8oAAIGAAgI7hwbSgBmAgAGAAgI7hwbSgBmAgAAAA==.',['申有']='申有娜:BAAALAAECgYIBgAAAA==.',['白云']='白云黄鹤间:BAAALAAECgYIDAAAAA==.',['白牛']='白牛青汁:BAACLAAFFH8JAAISAAMIcxBEGwDcAAASAAMIcxBEGwDcAAAsAAQKfx4AAxIACAgfIQElAIgCABIABwiKIQElAIgCAAgAAQiSBZ5RASEAAAAA.',['白胡']='白胡子老爹:BAAALAAECgYIEgAAAA==.',['皚雪']='皚雪凌霜:BAAALAAECgEIAQAAAA==.',['看我']='看我七十二变:BAABLAAFFH8LAAIPAAYIdwZdLgCyAAAPAAYIdwZdLgCyAAAAAA==.',['真希']='真希酱灬:BAABLAAFFH8GAAIRAAIIURrXFwA/AAARAAIIURrXFwA/AAAAAA==.',['瞬恒']='瞬恒一:BAAALAAFFAYIBAAAAA==.',['石之']='石之自由:BAAALAAECgYIBgAAAA==.',['破疯']='破疯:BAAALAAECgIIAgAAAA==.',['神威']='神威无敌:BAAALAAFFAMIAgAAAA==.',['神护']='神护牛肉:BAAALAAECgcIEAAAAA==.',['禁止']='禁止穿越:BAAALAADCgYICAAAAA==.',['秋心']='秋心拆两半:BAAALAAECgMIAwAAAA==.',['秋穑']='秋穑的回忆:BAAALAAECgYICQAAAA==.',['空壳']='空壳画眉丸樣:BAAALAADCgQIBAAAAA==.',['空灵']='空灵的殇:BAAALAAECgYIBgAAAA==.',['笨笨']='笨笨爱吃肉:BAAALAAFFAIIAgAAAA==.',['笼兄']='笼兄:BAAALAAECgMIAwAAAA==.',['等待']='等待紫伊:BAABLAAFFH8RAAIBAAMISA6cTwB7AAABAAMISA6cTwB7AAAAAA==.',['简单']='简单二号:BAABLAAFFH8GAAIbAAIIuwh6FgApAAAbAAIIuwh6FgApAAABLAAFFAMICQAHAJMUAA==.简单亿点:BAACLAAFFH8JAAIHAAMIkxRXQwCKAAAHAAMIkxRXQwCKAAAsAAQKfxoAAwcACAibGnAvANUBAAcABwgdHXAvANUBABEAAQgRCVtHACQAAAAA.',['糖果']='糖果:BAAALAADCggIDQAAAA==.',['糯米']='糯米成精:BAAALAADCgYIBgAAAA==.',['素锦']='素锦:BAAALAAFFAIIBAAAAA==.',['紫红']='紫红汽水:BAAALAAECgUIBQAAAA==.',['紫罗']='紫罗兰图腾:BAAALAAECgYIBgAAAA==.',['絕懟']='絕懟:BAAALAADCgMIAwAAAA==.',['絶懟']='絶懟丶零下:BAAALAADCgYIBgAAAA==.',['红双']='红双喜喜:BAAALAADCgYIBgAAAA==.',['红尘']='红尘恋人:BAAALAAECgYIBwAAAA==.',['纽扣']='纽扣劣人:BAAALAAECgYIDAAAAA==.',['绿谷']='绿谷:BAAALAAFFAIIBAAAAA==.绿谷无情:BAAALAAECgYIEQAAAA==.绿谷荣耀:BAAALAAFFAIIAgAAAA==.绿谷风情:BAAALAAFFAIIBAAAAA==.',['美如']='美如花赛天仙:BAABLAAFFH8IAAIBAAIIBxHOXgBAAAABAAIIBxHOXgBAAAAAAA==.',['美娅']='美娅:BAABLAAFFH8KAAIFAAUI8gUpYAC+AAAFAAUI8gUpYAC+AAAAAA==.',['聂小']='聂小倩丶:BAAALAAECgYICwAAAA==.',['胆顾']='胆顾凝:BAAALAAECgUICQAAAA==.胆顾宁:BAAALAAECgYIBgAAAA==.',['胡子']='胡子阿八:BAABLAAFFH8GAAIGAAMItAYIdwBKAAAGAAMItAYIdwBKAAAAAA==.',['艾利']='艾利西亚:BAABLAAFFH8OAAIFAAYIJQ98RgAwAQAFAAYIJQ98RgAwAQAAAA==.',['艾薇']='艾薇丶辛西娅:BAAALAAFFAIIAgAAAA==.',['艾诺']='艾诺辛:BAABLAAFFH8IAAIJAAgIXQApcQANAAAJAAgIXQApcQANAAAAAA==.',['芙莉']='芙莉莲:BAAALAAECgcICwAAAA==.',['芝士']='芝士菌:BAAALAAFFAIIAgAAAA==.',['花之']='花之翼:BAAALAAFFAIIAgAAAA==.',['若言']='若言誓言:BAAALAAECgEIAQAAAA==.',['范克']='范克里夫佩琪:BAAALAAECgYIBgAAAA==.',['草原']='草原小彩牛:BAABLAAFFH8IAAIZAAUIQQNbBwB9AAAZAAUIQQNbBwB9AAAAAA==.',['菊花']='菊花残了:BAAALAAECggICgAAAA==.',['菲伦']='菲伦:BAABLAAFFH8IAAIMAAIIHRdDSgCWAAAMAAIIHRdDSgCWAAAAAA==.',['萨娜']='萨娜:BAAALAAFFAIIBAAAAA==.',['萨琪']='萨琪玛:BAAALAAECggIAgAAAA==.',['落叶']='落叶晨曦:BAAALAAECgYIBgAAAA==.',['落花']='落花飘别处:BAAALAAFFAIIAgAAAA==.',['藜荋']='藜荋狗:BAABLAAFFH8NAAIPAAYIlxI5GABwAQAPAAYIlxI5GABwAQAAAA==.',['血腥']='血腥之王:BAABLAAFFH8UAAMHAAYI6B/sCwDlAQAHAAYI6B/sCwDlAQARAAIIVgIdIQBRAAAAAA==.',['血誓']='血誓:BAAALAAECgYICwAAAA==.',['街溜']='街溜子讲武德:BAAALAAFFAIIAgAAAA==.',['街角']='街角的晚风:BAAALAAECgYIBgAAAA==.',['袍子']='袍子哥:BAACLAAFFH8OAAIJAAMIGRETQQCJAAAJAAMIGRETQQCJAAAsAAQKfxUAAgkABwgzGCg3AH0BAAkABwgzGCg3AH0BAAAA.',['调皮']='调皮的笑笑:BAABLAAFFH8HAAIBAAYIUBHwOQAjAQABAAYIUBHwOQAjAQAAAA==.',['贱神']='贱神:BAAALAAECgYICAAAAA==.',['这里']='这里有个精灵:BAABLAAFFH8GAAIVAAIIHwVOGwAwAAAVAAIIHwVOGwAwAAABLAAFFAMICQAHAJMUAA==.',['遗月']='遗月:BAABLAAFFH8JAAIDAAQIPhY5AgDQAAADAAQIPhY5AgDQAAABLAAFFAUIEAAOALAWAA==.',['酷兰']='酷兰德:BAAALAADCgYIBgAAAA==.',['酷到']='酷到没朋友:BAAALAAECgUIBQAAAA==.',['醉舞']='醉舞仙疯:BAABLAAECn8bAAMWAAYIbxcbHQAVAQAWAAYIbxcbHQAVAQAcAAYIKAR9HgCJAAAAAA==.',['野德']='野德辛之柱:BAABLAAFFH8FAAIdAAIIZA1wDgCUAAAdAAIIZA1wDgCUAAAAAA==.',['金陵']='金陵肥爷:BAAALAAECgYIBgAAAA==.',['钱多']='钱多拿来烧:BAAALAAECgYIBgAAAA==.',['铠塚']='铠塚霙樣:BAABLAAECn8UAAMeAAgIGBy6BwAaAgAeAAYIAiK6BwAaAgAfAAMI3Qp1PwCfAAABLAAFFAIIBgAGAGQfAA==.',['长期']='长期素食:BAAALAAECggICAAAAA==.',['阴影']='阴影降临:BAAALAAECggICAAAAA==.',['阿库']='阿库亚:BAAALAAFFAQIBAAAAA==.',['随遇']='随遇丶而安:BAAALAADCggICAAAAA==.',['隔壁']='隔壁老王头:BAAALAAFFAIIAgAAAA==.',['隠隠']='隠隠莋痛:BAABLAAECn8SAAQHAAgI5hbglwDEAQAHAAgIUhbglwDEAQAgAAYI4gZ1WADwAAARAAIIfxwgPQBSAAAAAA==.',['雪满']='雪满天飞:BAAALAAECgMIAwAAAA==.',['雷神']='雷神:BAAALAADCggICAAAAA==.',['霜歌']='霜歌:BAABLAAFFH8FAAIPAAIIVBeHKACJAAAPAAIIVBeHKACJAAAAAA==.',['霸气']='霸气雄途:BAAALAAFFAMIAwAAAA==.',['青丘']='青丘白淺:BAAALAAECgYIBQAAAA==.',['青莲']='青莲剑似歌:BAAALAAECggICAAAAA==.',['靓乄']='靓乄仔:BAAALAAECgQIBAAAAA==.',['风世']='风世字:BAAALAAECgYIBgAAAA==.',['风云']='风云出我辈:BAAALAAECgIIAgAAAA==.',['风流']='风流猎手:BAAALAAECgMIAQAAAA==.',['食月']='食月:BAABLAAFFH8VAAITAAYI2xO5FgCcAQATAAYI2xO5FgCcAQAAAA==.',['饱饱']='饱饱:BAAALAADCgUIBQAAAA==.',['高松']='高松灯樣:BAAALAAECgMIAwABLAAFFAIIBgAGAGQfAA==.',['鬼殇']='鬼殇裁决:BAAALAAECgQIBQAAAA==.',['魂火']='魂火:BAAALAAECgIIAgAAAA==.',['魔术']='魔术师:BAAALAADCgQIBAAAAA==.',['魚頭']='魚頭小臉臉:BAAALAAECgYICAAAAA==.',['鲜花']='鲜花缤纷:BAABLAAECn8aAAMFAAYI1Q64/wAvAQAFAAYI1Q64/wAvAQAVAAEIiAA72gAEAAAAAA==.',['鳳凰']='鳳凰涅槃:BAAALAAECgYICQAAAA==.',['鸣笛']='鸣笛:BAAALAAECgUIBQAAAA==.',['黎明']='黎明之剑:BAABLAAFFH8IAAIIAAMIxwj+UAB5AAAIAAMIxwj+UAB5AAAAAA==.',['黑铁']='黑铁咖啡:BAAALAAECgYIBwAAAA==.',['龟仙']='龟仙人杯莫停:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end