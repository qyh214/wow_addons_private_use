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
 local lookup = {'DemonHunter-Havoc','Druid-Restoration','Hunter-BeastMastery','Paladin-Retribution','Druid-Feral','Mage-Arcane','Mage-Frost','Shaman-Restoration','Shaman-Elemental','Paladin-Protection','Druid-Guardian','Hunter-Marksmanship','Warrior-Protection','Warrior-Arms','Warrior-Fury','DeathKnight-Blood','Warlock-Destruction','Warlock-Demonology','Monk-Mistweaver','Druid-Balance','Priest-Holy','Monk-Windwalker','DemonHunter-Vengeance','DeathKnight-Unholy','DeathKnight-Frost','Warlock-Affliction','Priest-Shadow','Paladin-Holy',}; local provider = {region='CN',realm='杜隆坦',name='CN',type='weekly',zone=44,date='2025-12-06',data={Au='Autocad:BAAALAAECgYICgAAAA==.',Cc='Cceyy:BAABLAAFFH8KAAIBAAII9hDNUwBHAAABAAII9hDNUwBHAAAAAA==.',Co='Contagious:BAAALAAECgYIBgAAAA==.',Dk='Dkkw:BAAALAADCgYIBgAAAA==.',Dr='Drkk:BAAALAAFFAIIAgAAAA==.',Fr='Frangrace:BAAALAAECgMIAwAAAA==.',Ha='Halloween:BAAALAADCgQIBAAAAA==.',Hu='Hunterp:BAAALAAECggIDQAAAA==.',Jf='Jfdsajaasdfg:BAAALAADCgEIAQAAAA==.',Ju='Jurisdiction:BAAALAAFFAIIBAAAAA==.',Kd='Kdeathknight:BAAALAAECgEIAQAAAA==.Kdemonhunter:BAAALAAECgYIBgAAAA==.',Ki='Kiko:BAAALAAECgEIAQAAAA==.',La='Lancome:BAAALAADCggIDgAAAA==.',Lu='Luyyi:BAABLAAFFH8FAAICAAMIUg0mNACZAAACAAMIUg0mNACZAAAAAA==.',Ni='Ning:BAAALAAECgYIEAAAAA==.Niyaa:BAAALAAECgIIAgAAAA==.',Oe='Oell:BAABLAAFFH8MAAIDAAMIARu8aACTAAADAAMIARu8aACTAAAAAA==.',Si='Sithlord:BAAALAADCgcIBwAAAA==.',To='Toky:BAACLAAFFH8FAAIEAAIIkQnAXACCAAAEAAIIkQnAXACCAAAsAAQKfxYAAgQABwhUD463AJQBAAQABwhUD463AJQBAAAA.',Ut='Utopia:BAAALAAECgIIAwAAAA==.',Va='Valenti:BAACLAAFFH8HAAICAAII+h1EMACpAAACAAII+h1EMACpAAAsAAQKfyUAAwIABgheH+EzABECAAIABgheH+EzABECAAUAAwhVB4g+AIoAAAAA.',['一击']='一击即中:BAABLAAFFH8FAAIDAAII0RMakwBDAAADAAII0RMakwBDAAAAAA==.',['一叶']='一叶一菩提:BAAALAAECgYICQAAAA==.',['一颦']='一颦一笑:BAAALAAFFAIIAgAAAA==.',['一鸩']='一鸩羽千夜一:BAAALAAECgQIBAAAAA==.',['上档']='上档次:BAAALAAECgUIBQAAAA==.',['上证']='上证要红:BAABLAAECn8VAAMGAAgI1hXeXQDqAQAGAAgI1hXeXQDqAQAHAAYI3hPVPwByAQAAAA==.',['不做']='不做乖小孩:BAAALAAECgYIDgAAAA==.',['不吃']='不吃竹子:BAAALAADCgQIBAAAAA==.',['不明']='不明的人物:BAAALAAECgYIBgAAAA==.',['世界']='世界丨萨:BAACLAAFFH8oAAIIAAYIvBvAEQDWAQAIAAYIvBvAEQDWAQAsAAQKfyUAAwgACAgmGgZFAA8CAAgACAgmGgZFAA8CAAkABgipDTx9AEkBAAAA.世界中的我:BAAALAADCgEIAQAAAA==.',['丨元']='丨元素萨满丨:BAAALAADCgQIBAAAAA==.',['丨豆']='丨豆豆汝丨:BAAALAAECgYIEAAAAA==.',['中式']='中式无糖面包:BAAALAAECgQIBAAAAA==.',['临无']='临无敌丶:BAAALAAECgYIBgAAAA==.',['丶咕']='丶咕噜噜:BAAALAADCgEIAQAAAA==.',['丹玛']='丹玛丽娜:BAAALAAECgEIAQAAAA==.',['丿尐']='丿尐少:BAAALAAECgIIAgAAAA==.',['乄取']='乄取名好烦:BAAALAAECgQIBQAAAA==.',['九尾']='九尾雪狐:BAABLAAFFH8KAAIKAAIIRRDcFQB+AAAKAAIIRRDcFQB+AAAAAA==.',['云墨']='云墨墨:BAAALAAFFAIIBAAAAA==.',['人族']='人族先锋:BAAALAAECggICgAAAA==.',['代春']='代春花:BAABLAAFFH8GAAILAAIIFRjzBQCPAAALAAIIFRjzBQCPAAAAAA==.',['伊利']='伊利蛋语风:BAAALAAECgIIBAAAAA==.',['伍媚']='伍媚:BAAALAAECgYIBgAAAA==.',['作怪']='作怪飞飞:BAABLAAFFH8GAAMDAAII4RILYwCJAAADAAIIwQ0LYwCJAAAMAAIIchIjGAA8AAAAAA==.',['你和']='你和我玩崩铁:BAACLAAFFH81AAQNAAYIJBFrEgAyAQANAAYIJBFrEgAyAQAOAAIIlQqyBQCHAAAPAAIIRws+SwBIAAAsAAQKfyUAAw0ABghuHZQsAOUBAA0ABghwHJQsAOUBAA8ABgijFixLADQBAAAA.',['你女']='你女未白勺:BAAALAAECgYICwAAAA==.',['使徒']='使徒行者:BAAALAAECgcICAAAAA==.',['做廆']='做廆也風流:BAAALAAECgMIAwAAAA==.',['傻袍']='傻袍子:BAAALAADCgcIBwAAAA==.',['元素']='元素的愤怒:BAAALAADCgIIAgAAAA==.',['光明']='光明骑士:BAAALAAECgcIDAAAAA==.',['克罗']='克罗木:BAABLAAFFH8FAAIQAAUILwR5BwA3AQAQAAUILwR5BwA3AQAAAA==.',['再二']='再二大:BAABLAAECn8hAAIBAAgI4SHCFwAJAwABAAgI4SHCFwAJAwAAAA==.',['冰晶']='冰晶:BAABLAAFFH8FAAIHAAII6xG/GAA+AAAHAAII6xG/GAA+AAAAAA==.',['冷江']='冷江:BAABLAAFFH8GAAIBAAIIVgahYQA+AAABAAIIVgahYQA+AAAAAA==.',['凝云']='凝云冰澜:BAAALAADCggICgAAAA==.',['凤凰']='凤凰輓歌:BAABLAAECn8ZAAMHAAYIQRnANQCfAQAHAAYIQRnANQCfAQAGAAEIbgpDDAEmAAAAAA==.',['凯萨']='凯萨之灵:BAAALAADCgMIAwAAAA==.',['列克']='列克星敦:BAABLAAFFH8qAAMRAAYINx2RFwDNAQARAAYINx2RFwDNAQASAAEIJhr3JQBTAAAAAA==.',['利托']='利托里奥:BAABLAAFFH8xAAMNAAYINSTvAwAeAgANAAYINSTvAwAeAgAPAAEI1ReaaQAAAAAAAA==.',['加特']='加特琳:BAAALAAFFAEIAQAAAA==.',['勇敢']='勇敢牛牛冲冲:BAAALAADCgYIBgAAAA==.',['北冥']='北冥雪:BAAALAADCgIIAgAAAA==.',['北宅']='北宅:BAAALAAECgMIBQAAAA==.',['半斤']='半斤肉:BAAALAADCggICQAAAA==.',['卩丶']='卩丶類了灬:BAAALAAECgQIBAAAAA==.',['变猫']='变猫变鸟:BAAALAADCgQIBAAAAA==.',['只抽']='只抽煊赫门:BAAALAAECgMIAwAAAA==.',['可爱']='可爱小骑士:BAAALAAECgYIDQAAAA==.',['可琳']='可琳娜:BAAALAAECgIIAgAAAA==.',['吉普']='吉普莉儿:BAAALAAECgQIBAAAAA==.',['吓咪']='吓咪:BAAALAADCgUIBQAAAA==.',['君莫']='君莫笑余生寞:BAAALAAECgYIAwAAAA==.',['吮趾']='吮趾回味:BAAALAADCgEIAQAAAA==.',['呦呦']='呦呦酱:BAAALAAECgQIBAAAAA==.',['哈士']='哈士奇精莉莉:BAAALAADCgUIBQAAAA==.',['哎呀']='哎呀豚豚:BAAALAADCgMIAwAAAA==.',['唯你']='唯你而来:BAAALAAECgUIBgAAAA==.',['喵喵']='喵喵怪:BAABLAAFFH8GAAITAAII/RYBEACSAAATAAII/RYBEACSAAAAAA==.',['喵萌']='喵萌萌:BAAALAAFFAIIAgAAAA==.',['噼里']='噼里啪啦轰隆:BAAALAAECgEIAQAAAA==.',['嚎叫']='嚎叫的死人:BAAALAAECgYIBgAAAA==.',['囄我']='囄我遠點:BAAALAAECgQIBQAAAA==.',['土佬']='土佬肥:BAAALAAFFAIIAgAAAA==.',['土蚕']='土蚕:BAAALAAECgQIBAAAAA==.',['圣光']='圣光之母:BAAALAADCgQIBAAAAA==.圣光小忽悠:BAAALAADCgEIAQAAAA==.',['圣心']='圣心之手:BAAALAAECgUIBQAAAA==.',['地狱']='地狱之箭:BAAALAAECgMIAwAAAA==.',['堕天']='堕天使路西法:BAAALAADCgQIBAAAAA==.堕天使露西法:BAAALAAECgYIBgAAAA==.',['塞纳']='塞纳里奥咸鱼:BAAALAAECgIIAgAAAA==.',['墨蓝']='墨蓝:BAAALAADCgYIBgAAAA==.',['夏日']='夏日的颂歌:BAAALAAECgMIBgAAAA==.',['夜小']='夜小岚:BAAALAAECgIIAgAAAA==.夜小战:BAAALAAECgYICAAAAA==.夜小黎:BAAALAAECgYIEAAAAA==.夜小黑:BAAALAAECgEIAQAAAA==.',['夜清']='夜清醒:BAABLAAFFH8OAAIIAAIIpg2xVgBnAAAIAAIIpg2xVgBnAAAAAA==.',['夜羽']='夜羽:BAABLAAFFH8GAAIUAAII0REjNgA5AAAUAAII0REjNgA5AAAAAA==.',['大侠']='大侠阿宝:BAAALAAECgYIDAAAAA==.',['大唐']='大唐不良人:BAAALAAECgQIBAAAAA==.',['大毁']='大毁凌:BAAALAAECgYICQAAAA==.',['大笨']='大笨象扎支枪:BAAALAADCgYICgAAAA==.',['天水']='天水一色:BAAALAADCgEIAQAAAA==.',['天炎']='天炎迷雨:BAAALAAECggICAAAAA==.',['头上']='头上萌萌得:BAAALAAECgQIBAAAAA==.',['奈何']='奈何为猎:BAAALAAECgUIBwAAAA==.',['女王']='女王的执着:BAABLAAECn8UAAMCAAYITgwfkAD4AAACAAYITgwfkAD4AAAUAAIIjwS3pQBCAAAAAA==.',['好运']='好运呵毛:BAAALAAECgYIBgAAAA==.好运啊毛:BAAALAAECgYIDQAAAA==.好运毛毛:BAAALAAECgYIBgAAAA==.',['如梦']='如梦初见:BAAALAAECgIIAgAAAA==.',['妞妞']='妞妞向前冲:BAAALAAECggICAAAAA==.',['妹妹']='妹妹我还要:BAAALAAECgYIBgAAAA==.',['嫑烎']='嫑烎:BAAALAAECgYICAAAAA==.',['寒烟']='寒烟兰烬休:BAAALAAECgYIDAAAAA==.',['射勒']='射勒:BAAALAAECgYIDwAAAA==.',['小嘿']='小嘿:BAAALAADCgEIAQAAAA==.',['小寒']='小寒号鸟:BAAALAAECgYIEwAAAA==.',['小布']='小布儿:BAABLAAFFH8bAAIVAAYIbhZXEwC+AQAVAAYIbhZXEwC+AQAAAA==.',['小懿']='小懿:BAAALAAECgIIAQAAAA==.',['小毁']='小毁凌:BAAALAAECgIIBAAAAA==.',['小洛']='小洛:BAABLAAFFH8IAAICAAIISgkCPwBhAAACAAIISgkCPwBhAAAAAA==.',['小浩']='小浩然:BAAALAAFFAIIBAAAAA==.',['小熊']='小熊呼噜噜:BAABLAAFFH8JAAIRAAYImxDTLwBaAQARAAYImxDTLwBaAQAAAA==.',['小猫']='小猫洛尔:BAAALAADCgYIBgAAAA==.',['小雾']='小雾气:BAAALAAECggICAAAAA==.',['尐丸']='尐丸子:BAAALAAECgYIBgAAAA==.',['尐甜']='尐甜惢:BAAALAAECgMIAwAAAA==.',['尘封']='尘封记忆:BAAALAADCgQIBAAAAA==.',['居尔']='居尔特粑粑:BAAALAAECgYIDAAAAA==.',['山城']='山城棒棒军:BAAALAAECgQICAAAAA==.',['巭圣']='巭圣熊:BAAALAAECgQIBAAAAA==.',['带你']='带你一起下去:BAAALAAFFAIIAgAAAA==.',['干了']='干了杯大姨妈:BAAALAAECgIIAgAAAA==.',['幸运']='幸运猎手:BAAALAAECggICAAAAA==.',['幻梦']='幻梦丶射击:BAAALAADCgcIBwAAAA==.',['幽暗']='幽暗诅咒:BAAALAAECgYIBgAAAA==.',['幽色']='幽色玫瑰:BAACLAAFFH8iAAMFAAYIthi1AgDIAQAFAAYIuha1AgDIAQAUAAQITw4FIQCyAAAsAAQKfysAAwUACAifJEwCAFIDAAUACAifJEwCAFIDABQAAggeHrpEAKcAAAAA.',['彩笔']='彩笔持恒爱掉:BAAALAAECgIIAwAAAA==.彩笔痴横爱吊:BAAALAAECgMIBAAAAA==.',['彩色']='彩色天空:BAAALAAECgIIAgAAAA==.',['影轩']='影轩:BAABLAAFFH8FAAILAAIIyw9QCABwAAALAAIIyw9QCABwAAAAAA==.',['微风']='微风灬呆呆兽:BAABLAAFFH8MAAIIAAQIShoXLAAHAQAIAAQIShoXLAAHAQAAAA==.',['恐鳌']='恐鳌之心:BAACLAAFFH8rAAINAAYIaQ7HEgAuAQANAAYIaQ7HEgAuAQAsAAQKfyAAAw0ACAifFsccAFoBAA8ABgjhGAI/AF4BAA0ACAgUFcccAFoBAAAA.',['情深']='情深不渡:BAAALAADCgEIAQAAAA==.',['惊魂']='惊魂甫定:BAAALAAECgYICAAAAA==.',['慕容']='慕容千叶:BAAALAAECgYICAAAAA==.慕容辰:BAAALAAECgYIDgAAAA==.',['慕红']='慕红莲:BAABLAAFFH8FAAIEAAMIfQrgRQCCAAAEAAMIfQrgRQCCAAAAAA==.',['我一']='我一直是五:BAABLAAFFH8WAAIBAAgIHxoeBwBiAgABAAgIHxoeBwBiAgABLAAFFAgIFwABAGIeAA==.我一直是六:BAABLAAFFH8XAAIBAAgIYh4XBACtAgABAAgIYh4XBACtAgAAAA==.我一直是四:BAABLAAFFH8LAAIBAAgIfBjoBgBnAgABAAgIfBjoBgBnAgABLAAFFAgIFwABAGIeAA==.',['我是']='我是小猪猪:BAAALAAECgQIBgAAAA==.',['我裂']='我裂开了:BAAALAAFFAIIBAAAAA==.',['提刀']='提刀遛狗:BAAALAAFFAIIAgAAAA==.',['摩尔']='摩尔珈娜:BAAALAAECgYICQAAAA==.',['擒兽']='擒兽:BAAALAADCggIEAAAAA==.',['放羊']='放羊的宝宝:BAAALAAECggICAAAAA==.',['无尽']='无尽虚空:BAAALAAECgEIAQAAAA==.',['无情']='无情岁月:BAAALAADCggICAAAAA==.',['无敌']='无敌小虾米:BAAALAAECgEIAgAAAA==.',['无言']='无言影:BAAALAAFFAIIBAAAAA==.',['春花']='春花:BAAALAADCgYIBgAAAA==.',['春雨']='春雨惊雷化风:BAAALAAFFAIIAgAAAA==.',['晓灬']='晓灬菜刀队长:BAABLAAECn8bAAIPAAcIOxjvSwANAgAPAAcIOxjvSwANAgAAAA==.',['晓骐']='晓骐:BAABLAAFFH8FAAIBAAMIwxAPQQCJAAABAAMIwxAPQQCJAAAAAA==.',['晓骑']='晓骑:BAABLAAFFH8FAAIWAAMIdx26DwCdAAAWAAMIdx26DwCdAAAAAA==.',['暗夜']='暗夜梦蓝:BAAALAAECggICAAAAA==.',['暗心']='暗心天堂:BAABLAAFFH8MAAIXAAQIQAIyDQBmAAAXAAQIQAIyDQBmAAAAAA==.',['暮歌']='暮歌:BAAALAAFFAIIBAAAAA==.',['曼朱']='曼朱莎华:BAAALAADCgQIBAAAAA==.',['月影']='月影:BAAALAAFFAIIBAAAAA==.',['有去']='有去无回:BAAALAAECgYIBgAAAA==.',['望月']='望月呆呆兽:BAAALAAECggIDAABLAAFFAYIKQACAOcaAA==.',['期盼']='期盼丶丶:BAABLAAFFH8NAAMYAAIIYxzmDgCgAAAYAAIIYxzmDgCgAAAZAAEIcBeInABKAAAAAA==.',['术丶']='术丶丶士:BAAALAADCgYICAAAAA==.',['李下']='李下小术:BAAALAADCgYIBgAAAA==.李下小猎:BAABLAAFFH8GAAIDAAYIKQtzXwDCAAADAAYIKQtzXwDCAAAAAA==.李下小骑:BAAALAAECggICAAAAA==.',['李战']='李战:BAAALAAECgIIAgAAAA==.',['条条']='条条:BAAALAAECggICAABLAAFFAgILAAVAAknAA==.',['果紫']='果紫木:BAAALAADCgEIAQAAAA==.',['枫花']='枫花恋:BAAALAADCggICAAAAA==.',['柒伤']='柒伤轩辕:BAAALAAFFAMIAwAAAA==.',['柒筱']='柒筱柒:BAABLAAECn8gAAQRAAgIJhwDLQCLAgARAAgIHRsDLQCLAgAaAAQI8BmWGABEAQASAAEIRg5MlgA8AAAAAA==.',['柠檬']='柠檬田田:BAAALAAECgMIBAAAAA==.',['梅花']='梅花十三:BAAALAAECgYIBgAAAA==.',['楛藤']='楛藤老树昏鸦:BAAALAAFFAIIBAAAAA==.',['檎炎']='檎炎熙雨:BAABLAAFFH8SAAIBAAYIBCGxEgDMAQABAAYIBCGxEgDMAQAAAA==.',['欧皇']='欧皇猎:BAABLAAFFH8GAAIDAAYIzBc6MAB3AQADAAYIzBc6MAB3AQAAAA==.',['死亡']='死亡法骑:BAAALAADCggICAAAAA==.',['毁凌']='毁凌:BAAALAAECgYIBgAAAA==.',['毁崚']='毁崚:BAAALAAECgYIBgAAAA==.',['毁淩']='毁淩:BAAALAAECgYIBgAAAA==.',['毁爺']='毁爺:BAAALAAECgUICwAAAA==.',['毁绫']='毁绫:BAAALAAECgIIAgAAAA==.',['毁錂']='毁錂:BAAALAAECgYIBgAAAA==.',['水元']='水元素煮火锅:BAAALAAECgEIAQAAAA==.',['水凝']='水凝:BAABLAAFFH8GAAIDAAYIWgCkwwASAAADAAYIWgCkwwASAAAAAA==.',['永恒']='永恒小猎:BAAALAAECggIDgAAAA==.永恒小蹄子:BAAALAAFFAIIAgAAAA==.',['沐璃']='沐璃晴:BAACLAAFFH8FAAIUAAUITALdIwCRAAAUAAUITALdIwCRAAAsAAQKfykAAxQACAgMEZBJAI4BABQABwgjEpBJAI4BAAIACAi2CT10ADsBAAAA.',['没的']='没的名字:BAAALAADCgMIAwAAAA==.',['沫小']='沫小滥:BAAALAAECgQICQAAAA==.',['法神']='法神艾格文:BAAALAAECgMIAwAAAA==.',['泰兰']='泰兰的语风:BAAALAAFFAQIBAAAAA==.',['海水']='海水冰凌:BAAALAADCgQIBAAAAA==.海水飚飒:BAAALAAFFAQIBAAAAA==.',['深蓝']='深蓝色的梦:BAAALAADCgYIBgAAAA==.',['深证']='深证要红:BAAALAADCgUIBQAAAA==.',['混沌']='混沌:BAAALAAFFAIIAgAAAA==.',['湘潭']='湘潭铺子:BAAALAAECgYIDgAAAA==.',['潇洒']='潇洒依然:BAAALAAECgYIEAAAAA==.',['火力']='火力即真理:BAAALAAECgYIDQAAAA==.',['灬糖']='灬糖喵喵:BAACLAAFFH8zAAIVAAYIdxCXFwCVAQAVAAYIdxCXFwCVAQAsAAQKfzMAAxUACAhtG7MZAPEBABUACAhtG7MZAPEBABsAAwjiDoV9ALIAAAAA.',['灬萫']='灬萫奈丿丶:BAAALAAECgYICQAAAA==.',['灵异']='灵异楼兰:BAABLAAFFH8FAAIDAAMIMw+/dwBuAAADAAMIMw+/dwBuAAAAAA==.',['炮椒']='炮椒:BAAALAAECgIIAgAAAA==.',['烣烬']='烣烬使者:BAAALAAECgYICQAAAA==.',['煎饼']='煎饼果子:BAAALAAFFAIIAgAAAA==.',['煙花']='煙花丶易冷:BAAALAAECgYICgAAAA==.',['熊熊']='熊熊猫猫鹌鹑:BAAALAAECgYIEQAAAA==.',['熬夜']='熬夜:BAAALAADCgMIAwAAAA==.',['熬雪']='熬雪魔猎手:BAAALAAECgQIBAAAAA==.',['牡冄']='牡冄埖芐屍:BAAALAAECgYIDAAAAA==.',['牧雨']='牧雨橙枫:BAABLAAFFH8FAAIVAAMIjBYcLACUAAAVAAMIjBYcLACUAAAAAA==.',['狄琳']='狄琳娜:BAABLAAFFH8GAAIGAAYI0SMCAwB/AgAGAAYI0SMCAwB/AgAAAA==.',['狩猎']='狩猎心心:BAAALAADCgYIBgAAAA==.',['狩魂']='狩魂:BAAALAAECgYIBgABLAAFFAIICgAKAEUQAA==.',['狮子']='狮子歌歌:BAAALAAECgQIBAAAAA==.',['猎魂']='猎魂:BAAALAADCgYIBgAAAA==.',['玉琉']='玉琉璃:BAAALAAECgYIBgAAAA==.',['玖零']='玖零丶:BAAALAADCgYIBgAAAA==.',['玩转']='玩转地球:BAAALAAECgUIBwAAAA==.',['玲乄']='玲乄小小星:BAAALAAECgYIDAAAAA==.',['珍珍']='珍珍:BAAALAAECgIIAgAAAA==.',['琤琤']='琤琤:BAAALAAECggICAAAAA==.',['琴骑']='琴骑书画:BAAALAAFFAIIBAAAAA==.',['瑞亚']='瑞亚丶风行者:BAAALAAECgMIAwAAAA==.',['瑟琳']='瑟琳娜奥斯本:BAAALAAECgYIBgAAAA==.',['璟璘']='璟璘:BAAALAAECgMIAwAAAA==.',['甜惢']='甜惢:BAAALAAECgYIDwAAAA==.',['甜甜']='甜甜起司喵:BAABLAAFFH8NAAIVAAIIbAKASgBSAAAVAAIIbAKASgBSAAAAAA==.',['疯狂']='疯狂的三三:BAAALAADCgYIBgAAAA==.',['痕哥']='痕哥:BAAALAAECgUIBQAAAA==.',['瘫瘫']='瘫瘫:BAAALAAFFAIIBAAAAA==.',['白曦']='白曦:BAAALAAECgMIAwAAAA==.',['白胡']='白胡子老爷爷:BAAALAAECgYIBgAAAA==.',['百事']='百事亦可乐:BAABLAAFFH8GAAIIAAII9w/xTABuAAAIAAII9w/xTABuAAAAAA==.',['盲牛']='盲牛青青:BAAALAAECgYIBgAAAA==.',['盾卫']='盾卫:BAAALAAFFAIIBAAAAA==.',['看夕']='看夕阳骑小猪:BAAALAAECgQICAAAAA==.',['真炎']='真炎八重樱:BAAALAAECgcIDgAAAA==.真炎幸魂:BAAALAAECgYIBgAAAA==.',['神圣']='神圣小雨:BAAALAADCgQIBAAAAA==.',['神祭']='神祭司:BAAALAAECgIIAgAAAA==.',['秀炎']='秀炎秀雨:BAAALAAECgQIBAAAAA==.',['秋冬']='秋冬夜未凉:BAAALAAECgYIEwAAAA==.',['秋沐']='秋沐寒:BAAALAAECgIIBAAAAA==.',['秦兰']='秦兰德丶语风:BAAALAAECgYICwAAAA==.',['空中']='空中雪花:BAAALAAECgQIBAAAAA==.',['笨会']='笨会传染的:BAABLAAFFH8HAAIEAAQIWQYORQCFAAAEAAQIWQYORQCFAAAAAA==.',['精湛']='精湛:BAAALAAECgYIBgAAAA==.',['索拉']='索拉亇:BAAALAAECgYIBgAAAA==.',['紫蜓']='紫蜓:BAAALAADCgEIAQAAAA==.',['红泥']='红泥小火炉:BAAALAADCgYIBgAAAA==.',['约克']='约克城:BAABLAAFFH8OAAIDAAYIzxsTIwCmAQADAAYIzxsTIwCmAQAAAA==.',['纯属']='纯属意外:BAABLAAFFH8HAAIDAAIIUxKQXQCNAAADAAIIUxKQXQCNAAAAAA==.',['绝不']='绝不拉怪:BAAALAADCgIIAgAAAA==.',['继续']='继续守护:BAAALAAECgMIAwAAAA==.',['缺德']='缺德的找我:BAAALAAECgYICQAAAA==.',['罒尛']='罒尛喪翼:BAABLAAFFH8kAAIGAAYIChLGNAAoAQAGAAYIChLGNAAoAQABLAAFFAYINQANACQRAA==.罒尛喪黑:BAABLAAFFH8mAAIEAAUIwxqrFQANAQAEAAUIwxqrFQANAQABLAAFFAYINQANACQRAA==.',['翻滚']='翻滚的葡萄:BAAALAAECgYIBgAAAA==.翻滚的豆豆:BAAALAAECgIIAgAAAA==.',['老张']='老张毛飞扬:BAAALAAECgYICQAAAA==.',['老杂']='老杂皮:BAAALAADCgQIBwAAAA==.',['聖光']='聖光天堂:BAABLAAFFH8bAAIKAAUIBQkKDADUAAAKAAUIBQkKDADUAAAAAA==.',['肉丝']='肉丝:BAAALAADCgUIAgAAAA==.',['肥嘟']='肥嘟嘟:BAAALAAECgYIBgAAAA==.',['背叛']='背叛与守护:BAAALAADCgEIAQAAAA==.',['胶布']='胶布:BAAALAAECgMIBQAAAA==.',['自炎']='自炎自雨:BAAALAAECgYIBgAAAA==.',['舞的']='舞的神话:BAAALAAECgYICgAAAA==.',['艾其']='艾其其:BAAALAAECgQIBAAAAA==.',['花言']='花言叶:BAAALAADCgcIBwAAAA==.',['苍邪']='苍邪:BAAALAAECgYICQAAAA==.',['若水']='若水丨时沙:BAAALAAECgEIAQAAAA==.',['苦海']='苦海孤雏:BAABLAAFFH8GAAIFAAIISRNSDgBCAAAFAAIISRNSDgBCAAAAAA==.',['莫问']='莫问剑:BAAALAAECgMIAwAAAA==.',['菲的']='菲的神话:BAAALAAECgYIBgAAAA==.',['萌娜']='萌娜俪莎:BAAALAAECgQIBAAAAA==.',['萌辶']='萌辶果果:BAAALAAECgYIDwAAAA==.',['萧碧']='萧碧宰治丶:BAAALAAECgYIBgAAAA==.',['萧蘅']='萧蘅哟:BAABLAAFFH8FAAIBAAII9AuyZAA7AAABAAII9AuyZAA7AAAAAA==.',['萨不']='萨不满:BAAALAAFFAIIAgAAAA==.',['萨拉']='萨拉托加:BAACLAAFFH8FAAIKAAUIwwN0BwDtAAAKAAUIwwN0BwDtAAAsAAQKfxUAAxwACAjnCAY8AHEBABwACAjnCAY8AHEBAAoABQhIBGdiAIkAAAAA.',['蒜小']='蒜小叶:BAABLAAFFH8NAAICAAIIIBclOgCFAAACAAIIIBclOgCFAAAAAA==.',['虎哥']='虎哥就是传说:BAAALAAECgYICAAAAA==.虎哥是个传说:BAABLAAECn8kAAIZAAYIlRkcPwCEAQAZAAYIlRkcPwCEAQAAAA==.',['血兽']='血兽:BAAALAADCgcICAAAAA==.',['血染']='血染风采:BAAALAAECgQIBAAAAA==.',['裂荏']='裂荏小扉:BAAALAAECgYIBgAAAA==.',['要了']='要了老命:BAABLAAFFH8GAAIZAAMIEg52ZACDAAAZAAMIEg52ZACDAAAAAA==.',['覆秋']='覆秋霜:BAAALAAECgIIAgAAAA==.',['诸葛']='诸葛钢钉:BAAALAAECgQIBAAAAA==.',['豆豆']='豆豆龙:BAAALAADCgMIAwAAAA==.',['超超']='超超大魔王:BAABLAAFFH8HAAIPAAQIVALDPQBzAAAPAAQIVALDPQBzAAAAAA==.超超泪邪痕:BAAALAAECgcIBwAAAA==.',['越想']='越想越气:BAAALAAECgEIAQAAAA==.',['跟老']='跟老黑有肉吃:BAAALAAECgYIDAAAAA==.',['路绮']='路绮欧:BAAALAAECgIIAgAAAA==.',['車干']='車干:BAAALAAFFAIIAgAAAA==.',['轩妮']='轩妮诗:BAAALAAECgQIBAAAAA==.',['辣椒']='辣椒小熊:BAAALAAECgMIAwAAAA==.',['辰晞']='辰晞:BAAALAAECgIIAgAAAA==.',['迷失']='迷失森林:BAAALAAECgYIAwAAAA==.',['追月']='追月之殇:BAAALAAECgYICQAAAA==.',['邪歌']='邪歌:BAABLAAFFH8GAAIBAAII3xE+WQBDAAABAAII3xE+WQBDAAAAAA==.',['郑秀']='郑秀晶:BAAALAAECgYICAAAAA==.',['醉倾']='醉倾秋:BAABLAAFFH8GAAIDAAII1hYNrAA5AAADAAII1hYNrAA5AAAAAA==.',['醉凊']='醉凊秋:BAABLAAFFH8JAAIEAAQIxgwcPQCfAAAEAAQIxgwcPQCfAAAAAA==.',['醉清']='醉清枫:BAAALAAFFAIIBAAAAA==.',['醉箐']='醉箐风:BAAALAAFFAIIAgAAAA==.',['鑫森']='鑫森淼焱垚:BAAALAAECgYIBgAAAA==.',['锍殇']='锍殇:BAAALAADCgIIAgAAAA==.',['镇上']='镇上一朵花:BAAALAAECgYIDAAAAA==.',['闪烁']='闪烁者:BAAALAAECgYIBgAAAA==.',['阿姨']='阿姨洗鐵路:BAAALAAECgEIAQAAAA==.',['阿牛']='阿牛:BAAALAAECgcIAgAAAA==.',['阿猛']='阿猛小朋友:BAAALAAECgUICAAAAA==.',['陈思']='陈思琪:BAAALAAECgEIAQAAAA==.',['隔壁']='隔壁李大爷:BAAALAAFFAIIAgAAAA==.',['隽炎']='隽炎妙雨:BAABLAAFFH8GAAINAAYIsBm7DAB3AQANAAYIsBm7DAB3AQAAAA==.',['雪箭']='雪箭:BAABLAAECn8UAAIDAAgIYw9mtQCNAQADAAgIYw9mtQCNAQAAAA==.',['雪花']='雪花飘舞:BAAALAAECgIIAgAAAA==.',['雷公']='雷公助我:BAAALAAFFAIIAgAAAA==.',['霜狼']='霜狼之子:BAAALAAECgYIBgAAAA==.',['霜飞']='霜飞残荷落:BAAALAADCgIIAgAAAA==.',['青云']='青云之枭雄:BAAALAADCgEIAQAAAA==.',['青酱']='青酱:BAAALAAECgEIAQAAAA==.',['风吹']='风吹拂兰:BAABLAAFFH8GAAIbAAYICwExMAAzAAAbAAYICwExMAAzAAAAAA==.',['风舞']='风舞天籁:BAAALAAECggIEAAAAA==.',['风行']='风行者:BAAALAAECgQIBAAAAA==.',['飘雪']='飘雪的精灵:BAAALAADCgIIAgAAAA==.',['飞的']='飞的羽翼:BAAALAADCgQIBAAAAA==.飞的高摔的惨:BAAALAADCgMIAwAAAA==.',['骑在']='骑在她身上:BAAALAAECgIIAgAAAA==.',['鬣煞']='鬣煞:BAAALAAECggICAAAAA==.',['鬼聻']='鬼聻希夷微:BAAALAAECgYICAAAAA==.',['魅惑']='魅惑之魂:BAAALAAECgYIBgAAAA==.',['魔丷']='魔丷焰:BAAALAADCgEIAQAAAA==.',['鱼见']='鱼见愁:BAAALAADCgMIAwAAAA==.',['鸡根']='鸡根里脊:BAABLAAECn8YAAIPAAYIMxYVcgCnAQAPAAYIMxYVcgCnAQAAAA==.',['鸩羽']='鸩羽千夜丨:BAAALAAECgYIBgAAAA==.',['黄小']='黄小邪:BAABLAAECn8cAAIEAAYIByLKWwA0AgAEAAYIByLKWwA0AgAAAA==.',['黄老']='黄老邪:BAABLAAFFH8GAAIZAAIIWRBNiQBBAAAZAAIIWRBNiQBBAAAAAA==.',['黑妹']='黑妹儿萨:BAAALAAFFAIIAgAAAA==.',['黑狮']='黑狮辉光:BAAALAAECgMIAwAAAA==.',['黑的']='黑的太早:BAAALAAECgEIAQAAAA==.',['黑翼']='黑翼雪狐:BAABLAAFFH8LAAIIAAYI+h4eEADlAQAIAAYI+h4eEADlAQAAAA==.',['黑色']='黑色信仰:BAAALAAECgMIAwAAAA==.',['默然']='默然冷对:BAAALAAECgYIDAAAAA==.',['龍城']='龍城丶飛將:BAAALAAECgIIAQAAAA==.',['龙之']='龙之奥:BAAALAAECgYIDAAAAA==.龙之魄:BAAALAAECgYIBgAAAA==.',['龙语']='龙语归来:BAAALAAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end