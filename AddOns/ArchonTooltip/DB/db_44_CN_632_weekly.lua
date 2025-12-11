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
 local lookup = {'Paladin-Retribution','Shaman-Restoration','Shaman-Elemental','Warrior-Protection','DeathKnight-Frost','Hunter-BeastMastery','Warlock-Destruction','Paladin-Protection','DeathKnight-Blood','Hunter-Marksmanship','Hunter-Survival','Paladin-Holy','Unknown-Unknown','DemonHunter-Havoc','Warrior-Fury','Mage-Arcane','Warlock-Demonology','Monk-Brewmaster','DeathKnight-Unholy','Priest-Holy','Mage-Frost','Druid-Balance','Druid-Restoration','DemonHunter-Vengeance',}; local provider = {region='CN',realm='大漩涡',name='CN',type='weekly',zone=44,date='2025-12-06',data={An='Ansl:BAAALAADCgEIAQAAAA==.',Ba='Baby:BAACLAAFFH8FAAIBAAII9Q3ibgA/AAABAAII9Q3ibgA/AAAsAAQKfxsAAgEABghfHGZHAIYBAAEABghfHGZHAIYBAAAA.',Bm='Bmhunter:BAAALAAECgYICgAAAA==.',Ca='Cat:BAAALAAECgQIBAAAAA==.',Ch='Chelizi:BAACLAAFFH8IAAICAAIIwxjKWgBlAAACAAIIwxjKWgBlAAAsAAQKfx8AAwIACAjtGu8RAGQCAAIACAjtGu8RAGQCAAMABQgWArhvAFcAAAAA.',Cr='Crius:BAABLAAFFH8JAAIBAAIIeA1WaABCAAABAAIIeA1WaABCAAAAAA==.',Da='Daybreakwind:BAABLAAFFH8GAAIEAAYI4QfyFgD4AAAEAAYI4QfyFgD4AAAAAA==.',Fz='Fzlan:BAAALAAECgMIAwAAAA==.',Gr='Gross:BAAALAAECgYIBgAAAA==.',He='Heycicle:BAACLAAFFH8MAAIFAAIIeBIcfQBHAAAFAAIIeBIcfQBHAAAsAAQKfxUAAgUABwjMF600AKUBAAUABwjMF600AKUBAAAA.Heyclceie:BAAALAAECgYICwABLAAFFAIIDAAFAHgSAA==.',Li='Lighthouse:BAABLAAFFH8RAAIGAAUIOSJ3LQCAAQAGAAUIOSJ3LQCAAQAAAA==.',Lu='Lunarf:BAAALAAECgYIDAAAAA==.',Oo='Oov:BAABLAAFFH8GAAIHAAYIIBVLEQDaAQAHAAYIIBVLEQDaAQAAAA==.',Pl='Playerqxvexv:BAAALAAECgYIBgAAAA==.',Sg='Sgalvatron:BAAALAAFFAIIAgAAAA==.',Su='Supersaman:BAAALAAFFAIIAgAAAA==.',Wa='Wallsay:BAACLAAFFH8cAAIBAAYIYx5kEADCAQABAAYIYx5kEADCAQAsAAQKfx4AAgEABgh0H55IAIMBAAEABgh0H55IAIMBAAAA.',['一五']='一五零四一:BAAALAAFFAIIAgAAAA==.',['一次']='一次插四根:BAAALAAECgYIDAAAAA==.',['一醉']='一醉似南柯:BAAALAAECgEIAQAAAA==.',['一顿']='一顿三碗:BAABLAAFFH8IAAIFAAYIpgI8TQD1AAAFAAYIpgI8TQD1AAAAAA==.',['七秀']='七秀叶芷青:BAAALAAECgcIDQAAAA==.',['三包']='三包薯条:BAAALAAECggIDQAAAA==.',['三重']='三重刘得华:BAAALAAECgQIBAAAAA==.',['不吃']='不吃牛肉:BAABLAAFFH8MAAIFAAII0BFgYQCXAAAFAAII0BFgYQCXAAAAAA==.',['两包']='两包薯条:BAAALAAFFAQIBAAAAA==.',['丨织']='丨织部里沙丨:BAAALAAFFAIIBAAAAA==.',['乌琵']='乌琵尔:BAAALAAECgYIBgABLAAFFAMIDgAIAK0XAA==.',['人间']='人间喜乐:BAAALAAECgIIAgAAAA==.人间寥情难诉:BAAALAADCggICAAAAA==.',['从心']='从心就怂:BAAALAADCgQIBAAAAA==.',['伊然']='伊然丶玩美:BAAALAAECgMIAwAAAA==.',['休闲']='休闲老饕:BAABLAAFFH8bAAMFAAUIRxeRPgBBAQAFAAUIRxeRPgBBAQAJAAEIOQCdIAAMAAAAAA==.',['伺机']='伺机待发硬币:BAAALAAFFAIIAgAAAA==.',['似水']='似水泠洛:BAAALAAFFAIIAgAAAA==.',['你写']='你写吸佳佳吗:BAABLAAFFH8HAAMKAAIIxRKsIgCDAAAKAAIIxRKsIgCDAAALAAEI5wSlCABFAAAAAA==.',['你大']='你大嘴:BAAALAAECggICQAAAA==.',['侠岚']='侠岚夆夆:BAAALAAECgYICwAAAA==.',['六六']='六六:BAAALAAECgQIBAAAAA==.',['冯小']='冯小怜:BAABLAAFFH8PAAIMAAgIHxVGBQBIAgAMAAgIHxVGBQBIAgAAAA==.',['冰冻']='冰冻星火:BAAALAADCgUIBQAAAA==.',['冲锋']='冲锋之魂:BAAALAADCgEIAQAAAA==.',['凌云']='凌云飞燕:BAAALAAECgIIAgAAAA==.',['别骂']='别骂我了哥:BAAALAAECggIBgAAAA==.',['勇敢']='勇敢德憨憨:BAAALAAECgYICgAAAA==.勇敢铁憨憨:BAAALAAECgQIBAAAAA==.',['勞娘']='勞娘崾黜嫁:BAAALAAECgUICQAAAA==.',['十五']='十五楼既牛牛:BAAALAAFFAIIBAAAAA==.',['千早']='千早爱音:BAAALAAECgEIAQABLAAECgYIDAANAAAAAA==.',['卖血']='卖血上网:BAABLAAFFH8GAAIGAAYIuQNrcgB8AAAGAAYIuQNrcgB8AAAAAA==.',['博闻']='博闻爸爸:BAABLAAFFH8PAAIOAAYIrQm5LAAxAQAOAAYIrQm5LAAxAQAAAA==.',['卫龙']='卫龙:BAAALAAECgYIDgAAAA==.',['可可']='可可慕斯:BAAALAADCgUIBQAAAA==.',['可爱']='可爱大叮叮:BAAALAAECgYICgAAAA==.',['史迪']='史迪牛:BAAALAAECgEIAQAAAA==.',['吃过']='吃过靓仔的亏:BAABLAAECn8dAAIPAAcIFxPqTgApAQAPAAcIFxPqTgApAQAAAA==.',['吃饱']='吃饱了睡:BAAALAAFFAQIBAAAAA==.',['咕噜']='咕噜咕噜:BAABLAAFFH8JAAIBAAUIShXuJABLAQABAAUIShXuJABLAQAAAA==.',['哈密']='哈密小烧猫:BAAALAAECgYIBgAAAA==.',['哎嗨']='哎嗨唷:BAAALAAECggICgAAAA==.',['唯心']='唯心是造:BAABLAAECn8VAAIQAAYIFRCiOQAnAQAQAAYIFRCiOQAnAQAAAA==.',['喜牛']='喜牛牛:BAAALAAECgQIBwAAAA==.',['四费']='四费硬币山岭:BAABLAAFFH8GAAIBAAII6hQ+PgCfAAABAAII6hQ+PgCfAAAAAA==.',['增强']='增强的泽拉图:BAABLAAECn8fAAIDAAgImxsuJQCHAgADAAgImxsuJQCHAgAAAA==.',['夏氏']='夏氏:BAAALAADCggIAwABLAAFFAIIBgARAMQYAA==.',['夕红']='夕红人瘦:BAAALAAECgMIAwAAAA==.',['大唐']='大唐千牛卫:BAAALAAECgIIAgAAAA==.',['大宗']='大宗师灬悟:BAAALAADCgQIBAAAAA==.',['大水']='大水棒:BAAALAAECgUIBgAAAA==.',['大耳']='大耳朵小老頭:BAAALAAECgYIBgAAAA==.',['大腳']='大腳板小老頭:BAAALAAECgYIDAAAAA==.',['天堂']='天堂星辰:BAAALAAFFAIIBAAAAA==.',['妖应']='妖应封光:BAAALAAECgYICgAAAA==.',['姑射']='姑射流光:BAAALAAECgMIAwAAAA==.',['子爵']='子爵:BAAALAADCgQIBQAAAA==.',['孤捣']='孤捣摸伱:BAAALAAECgMIAwAAAA==.',['孤独']='孤独的美食家:BAAALAAECggICAAAAA==.',['寒冰']='寒冰术师:BAAALAAECgYIEQAAAA==.寒冰熊德:BAAALAAECgQIBAAAAA==.',['小小']='小小折腾丶:BAAALAAFFAIIAgAAAA==.',['小未']='小未央丶:BAAALAAECgUIBQAAAA==.',['小浣']='小浣雄:BAAALAAECgYIBgAAAA==.',['小狗']='小狗兮兮:BAAALAAFFAIIAgAAAA==.',['小藕']='小藕藕丶:BAAALAAFFAIIBAAAAA==.',['尼鲁']='尼鲁:BAAALAADCggICAAAAA==.',['差点']='差点是美男:BAABLAAFFH8YAAISAAYI5gRhFQDmAAASAAYI5gRhFQDmAAAAAA==.',['布莱']='布莱恩铜须:BAACLAAFFH8OAAIIAAMIrRcGDwCfAAAIAAMIrRcGDwCfAAAsAAQKfxcAAwgABwhlG+cVAGoBAAgABggcHucVAGoBAAEABgjLE53rAEkBAAAA.',['干申']='干申大那多:BAAALAADCgIIAgAAAA==.',['平衡']='平衡的泽拉图:BAAALAADCggICQAAAA==.',['幻雪']='幻雪冰风:BAABLAAFFH8GAAIGAAYIGwbNVQD2AAAGAAYIGwbNVQD2AAAAAA==.',['弄烦']='弄烦:BAAALAAECgMIAwAAAA==.',['張教']='張教授:BAAALAADCgIIAgAAAA==.',['忧郁']='忧郁的大角牛:BAAALAAECgQIBAAAAA==.忧郁的小小妞:BAAALAAECgEIAQAAAA==.忧郁的小术术:BAAALAAECgQIBAAAAA==.忧郁的小阿飞:BAAALAAECgYIBgAAAA==.忧郁的小鲨鱼:BAAALAAECgYICwAAAA==.',['我才']='我才是春哥:BAABLAAFFH8HAAIOAAMI/xr1PQCVAAAOAAMI/xr1PQCVAAAAAA==.',['我的']='我的大肚腩:BAABLAAFFH8QAAIFAAYI8w8+RQAlAQAFAAYI8w8+RQAlAQAAAA==.',['我知']='我知道错了哥:BAABLAAFFH8JAAQFAAQIChP+RgCpAAAFAAIIwBr+RgCpAAAJAAII9QRDDwCNAAATAAIIsBJMFACHAAAAAA==.',['战于']='战于野:BAAALAADCggICAAAAA==.',['拂晓']='拂晓晨曦:BAAALAAFFAIIBAAAAA==.',['拜蒙']='拜蒙:BAAALAADCggICAAAAA==.',['捣蛋']='捣蛋炽天使:BAAALAAECgYIBgAAAA==.捣蛋猎魔人:BAAALAAECgYIBwAAAA==.捣蛋路西法:BAAALAAECgQIBAAAAA==.',['敌丨']='敌丨法:BAAALAAECgYIBwAAAA==.',['明日']='明日叶三叶:BAAALAADCgYIBgAAAA==.',['星星']='星星点点:BAAALAAECgYIEQAAAA==.',['星空']='星空:BAAALAAECgUIBQAAAA==.',['星魂']='星魂猎:BAACLAAFFH8MAAIGAAII2RmeVACTAAAGAAII2RmeVACTAAAsAAQKfxkAAgYABwh2IHozAPEBAAYABwh2IHozAPEBAAAA.',['春之']='春之恋:BAAALAAECgIIAgAAAA==.',['春哥']='春哥一米八:BAAALAAECgYIDgAAAA==.春哥赐你永生:BAAALAAECgMIAwAAAA==.',['晓梦']='晓梦:BAABLAAFFH8GAAIBAAYIfB1TAgBdAgABAAYIfB1TAgBdAgAAAA==.',['普鲁']='普鲁托:BAAALAAECgEIAQAAAA==.',['月魔']='月魔光:BAAALAADCgQIBAAAAA==.',['月黑']='月黑风高:BAAALAAFFAIIBAAAAA==.',['未来']='未来混沌:BAAALAADCgIIAgAAAA==.',['林飞']='林飞儿:BAAALAAECgYIBgAAAA==.',['枫叶']='枫叶爱熙:BAAALAAFFAIIAgAAAA==.枫叶爱睿:BAAALAAFFAIIAgAAAA==.',['染墨']='染墨:BAAALAAECggICAAAAA==.',['水大']='水大棒:BAAALAAECgYIEAAAAA==.',['沙瑞']='沙瑞琻:BAAALAAECggICAAAAA==.',['没有']='没有灵魂兽:BAAALAAECgYICAAAAA==.没有重来:BAAALAAECgIIAgAAAA==.',['河馬']='河馬:BAABLAAFFH8xAAMTAAcIkyOFAQDCAQAFAAcIkyMwCQBmAgATAAYIFiOFAQDCAQAAAA==.',['泽畔']='泽畔東篱:BAAALAAFFAIIAgAAAA==.',['洋仔']='洋仔:BAAALAAECgYICQAAAA==.',['洒家']='洒家来也:BAAALAAECgIIAgAAAA==.',['浪浪']='浪浪山喜牛牛:BAAALAAECgYIBwAAAA==.',['浪漫']='浪漫无限:BAAALAAECgUIAgAAAA==.',['混吃']='混吃混喝:BAAALAAFFAIIAgAAAA==.',['混沌']='混沌启源:BAAALAADCggICAAAAA==.',['淸浅']='淸浅:BAABLAAECn8WAAIUAAYITxbhUACTAQAUAAYITxbhUACTAQAAAA==.',['清故']='清故宸凉:BAAALAAFFAIIAgABLAAFFAgITgAHACMjAA==.',['清水']='清水戦九:BAABLAAFFH8KAAIEAAYIrA3lBgCZAQAEAAYIrA3lBgCZAQAAAA==.',['清清']='清清白白:BAAALAAECgIIAgAAAA==.',['游云']='游云:BAAALAAECgQIBAAAAA==.',['灯塔']='灯塔:BAACLAAFFH8XAAIQAAUIMiKHJQB/AQAQAAUIMiKHJQB/AQAsAAQKfxUAAxAABgjkINNXAP0BABAABgjkINNXAP0BABUAAwh4D1p5AIQAAAAA.',['炸梦']='炸梦这是我去:BAABLAAFFH8FAAIUAAMIng/zLgCxAAAUAAMIng/zLgCxAAAAAA==.',['煮牛']='煮牛肉的猴子:BAAALAAECgMIAwAAAA==.',['牛奶']='牛奶啤酒:BAAALAAECgUIBQAAAA==.',['狐狐']='狐狐哈哈:BAAALAADCggICAAAAA==.',['猛仔']='猛仔:BAABLAAFFH8GAAIGAAIIyxZnRwCcAAAGAAIIyxZnRwCcAAAAAA==.',['王二']='王二狗丶:BAAALAAECgUIBQAAAA==.',['王大']='王大拿木大:BAAALAADCgUIBQAAAA==.',['玲珑']='玲珑剔透:BAAALAADCgYIBgAAAA==.',['瓮途']='瓮途鳖:BAAALAAECgMIAwAAAA==.',['生不']='生不息:BAAALAADCggIBwAAAA==.',['白斩']='白斩乁:BAAALAAECgIIAgAAAA==.',['白纸']='白纸扇书生:BAAALAAECgEIAQAAAA==.',['盲眼']='盲眼觅心猎手:BAAALAAECgQIBAAAAA==.',['盾墙']='盾墙:BAAALAAECgcIBwAAAA==.',['看看']='看看人家:BAAALAAECgQIBAAAAA==.',['神奇']='神奇的滄寒:BAABLAAFFH8GAAIRAAIINgQGHgB7AAARAAIINgQGHgB7AAAAAA==.',['神欲']='神欲之殇:BAACLAAFFH8iAAIVAAYIQxyoAwCjAQAVAAYIQxyoAwCjAQAsAAQKfxsAAhUABwgrIR0bAEICABUABwgrIR0bAEICAAAA.',['秋桃']='秋桃:BAABLAAFFH8GAAMWAAIIfgX6KABqAAAWAAIIfgX6KABqAAAXAAIIIgZsQwBcAAAAAA==.',['米娜']='米娜希儿:BAAALAAECgYIDAAAAA==.',['累不']='累不死的牛:BAABLAAFFH8FAAIPAAIIig0vPQCQAAAPAAIIig0vPQCQAAAAAA==.',['绿石']='绿石桃桃:BAAALAAFFAIIAgAAAA==.',['老子']='老子又打挑夸:BAABLAAFFH8GAAIPAAYIQwZbKgAXAQAPAAYIQwZbKgAXAQAAAA==.老子打挑夸:BAACLAAFFH8WAAIPAAYIBhBrIABpAQAPAAYIBhBrIABpAQAsAAQKfx8AAg8ABwjXH4EYAB8CAA8ABwjXH4EYAB8CAAAA.',['老璐']='老璐:BAAALAAECgYIDAAAAA==.',['色还']='色还是那个色:BAAALAAECgIIAgAAAA==.',['花有']='花有重开日:BAAALAAECggIDQABLAAFFAgIBQAXAJgMAA==.',['菲力']='菲力一世:BAAALAADCgEIAQAAAA==.',['萌萌']='萌萌忻:BAACLAAFFH8OAAIRAAIIRSPXDACtAAARAAIIRSPXDACtAAAsAAQKfxYAAhEACAgzH+MIANoCABEACAgzH+MIANoCAAAA.萌萌猎:BAAALAADCgIIAgAAAA==.萌萌的筱紫瞳:BAABLAAFFH8GAAIHAAIIOx2HNACoAAAHAAIIOx2HNACoAAAAAA==.',['葱油']='葱油虾干生菜:BAAALAADCgUIBQAAAA==.',['蓝皮']='蓝皮白雪公主:BAAALAADCgEIAQAAAA==.',['費蒙']='費蒙特:BAAALAAFFAIIBAAAAA==.',['超大']='超大杯:BAAALAAECgYIBgAAAA==.',['踏风']='踏风的泽拉图:BAAALAAECgcIDQABLAAECggIHwADAJsbAA==.',['迦勒']='迦勒底的猫鱼:BAAALAAECgEIAQAAAA==.',['追战']='追战者:BAAALAADCgEIAQAAAA==.',['追法']='追法者:BAAALAADCgEIAQAAAA==.',['追踨']='追踨者:BAAALAAFFAMIBAAAAA==.',['追魔']='追魔者:BAAALAADCgEIAQAAAA==.',['逆水']='逆水寒冰:BAABLAAECn8aAAIBAAYIZglulADXAAABAAYIZglulADXAAAAAA==.',['邪瓶']='邪瓶花:BAAALAADCgEIAQAAAA==.',['长期']='长期素食:BAAALAAFFAIIBAABLAAFFAIIBwAKAMUSAA==.',['阿卟']='阿卟:BAAALAAECgYIEgAAAA==.',['阿古']='阿古斯:BAABLAAFFH8MAAIYAAII4xeIDQCIAAAYAAII4xeIDQCIAAABLAAFFAMIDgAIAK0XAA==.',['阿达']='阿达尔之手:BAAALAADCgUIBQAAAA==.',['雏龙']='雏龙饲养员:BAAALAAECgEIAQAAAA==.',['雨丶']='雨丶:BAABLAAFFH8QAAIFAAUIJB7iOABYAQAFAAUIJB7iOABYAQABLAAFFAUIEQAGADkiAA==.',['雨点']='雨点点丶:BAAALAAFFAMIAwAAAA==.',['鸩酒']='鸩酒白绫:BAAALAAECgYIDAAAAA==.',['黑日']='黑日白:BAAALAAECgQIBAAAAA==.',['黑花']='黑花:BAAALAADCgMIAwAAAA==.',['默存']='默存:BAAALAADCgIIAgAAAA==.',['默莫']='默莫:BAAALAAECgYICwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end