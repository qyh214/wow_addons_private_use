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
 local lookup = {'Druid-Balance','Hunter-Marksmanship','Paladin-Retribution','Priest-Holy','Warrior-Protection','Warrior-Fury','Druid-Restoration','Shaman-Restoration','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Mage-Arcane','DeathKnight-Frost','Druid-Guardian','Mage-Frost','Monk-Brewmaster','Paladin-Protection','Druid-Feral','Paladin-Holy',}; local provider = {region='CN',realm='安格博达',name='CN',type='weekly',zone=44,date='2025-12-06',data={Am='Ammn:BAACLAAFFH8OAAIBAAUIuxCKGQALAQABAAUIuxCKGQALAQAsAAQKfxkAAgEABwggHjkYAK8BAAEABwggHjkYAK8BAAAA.Amplified:BAAALAADCggICAAAAA==.',Bi='Biubiubiuu:BAABLAAFFH8SAAICAAUIsg2UCgD2AAACAAUIsg2UCgD2AAAAAA==.',Dy='Dyrachyo:BAABLAAFFH8IAAIDAAII7BWIOgCiAAADAAII7BWIOgCiAAAAAA==.',Eg='Egg:BAAALAAFFAIIAgAAAA==.',In='Invoke:BAABLAAFFH8FAAIEAAII9QXxPgB4AAAEAAII9QXxPgB4AAAAAA==.',Lc='Lceland:BAAALAAECgIIAgAAAA==.',Mi='Miate:BAAALAADCgMIAwAAAA==.',Pl='Playeresexja:BAAALAADCgMIAgAAAA==.',Yu='Yuchen:BAAALAAFFAIIBAAAAA==.',['一勺']='一勺料汁:BAAALAAECgYICAAAAA==.',['一对']='一对三:BAAALAAECgYICwAAAA==.一对四:BAABLAAECn8YAAMFAAYIZxrrFgCOAQAFAAYIZxrrFgCOAQAGAAIINgJvpwAuAAAAAA==.',['三月']='三月七:BAAALAAECgYIBgAAAA==.',['下一']='下一个烟火:BAAALAAECgYIDAAAAA==.',['东皇']='东皇丶太一:BAAALAAECgYIDAABLAAFFAIICgAHACEUAA==.东皇丶新一:BAACLAAFFH8KAAIHAAIIIRRJPQB7AAAHAAIIIRRJPQB7AAAsAAQKfyIAAgcACAjSGEIXABUCAAcACAjSGEIXABUCAAAA.',['丨小']='丨小林子丨:BAAALAAECgYIDgAAAA==.',['丶仨']='丶仨岁:BAAALAAFFAIIAgAAAA==.丶仨嵗:BAAALAAFFAIIBAAAAA==.',['丶叁']='丶叁岁:BAAALAAECgQIBAAAAA==.',['丶独']='丶独自等待:BAAALAADCgIIAgAAAA==.',['丷綿']='丷綿茸菟丷:BAAALAAECgYIBwAAAA==.',['丷菟']='丷菟籽丷:BAAALAAECgYIBwAAAA==.',['乌鸦']='乌鸦:BAAALAAECgQIBAAAAA==.',['乔伊']='乔伊波伊:BAAALAAECgYICgAAAA==.',['二弟']='二弟永不倒:BAAALAAECgcICwAAAA==.',['亿粒']='亿粒蛋:BAAALAAECgMIBAAAAA==.',['伊邪']='伊邪那美:BAABLAAFFH8GAAIIAAYIqBk8FgCtAQAIAAYIqBk8FgCtAQAAAA==.',['使命']='使命召唤:BAABLAAFFH8NAAIJAAMIKA3AcgB7AAAJAAMIKA3AcgB7AAAAAA==.',['傻满']='傻满:BAABLAAFFH8FAAIIAAUIEAHwZgBUAAAIAAUIEAHwZgBUAAAAAA==.',['光之']='光之印记:BAACLAAFFH8FAAMKAAIIWgfUawA0AAALAAEIDAewLwBDAAAKAAEIpwfUawA0AAAsAAQKfxgAAwsABghgGyQoANUBAAsABghbGyQoANUBAAoABAgPE+NaAO4AAAAA.',['克里']='克里斯提娜:BAAALAAECgcICQAAAA==.',['北极']='北极星灬:BAAALAADCgEIAQAAAA==.',['千年']='千年乌木:BAAALAAFFAIIAgAAAA==.',['可乐']='可乐不加冰块:BAAALAAECgYIBgAAAA==.',['可爱']='可爱多真可爱:BAAALAADCgIIAgAAAA==.',['哲月']='哲月:BAAALAAFFAIIAgAAAA==.',['嘻嘻']='嘻嘻哈:BAAALAAECgYIBgAAAA==.',['嘿唧']='嘿唧唧:BAAALAAECgYICwAAAA==.',['埃尔']='埃尔拉希奥:BAACLAAFFH8bAAIMAAYIVxu6FQC4AQAMAAYIVxu6FQC4AQAsAAQKfyYAAgwACAgyIvMMAIQCAAwACAgyIvMMAIQCAAAA.',['堕落']='堕落大天使:BAABLAAFFH8JAAQNAAUIUxcuBQBqAAANAAMIgBQuBQBqAAAOAAMI1QYONAANAAAEAAII5BQAAAAAAAAAAA==.',['大剑']='大剑:BAABLAAECn8XAAIDAAYIWhevXwBGAQADAAYIWhevXwBGAQAAAA==.',['大炮']='大炮:BAAALAAECgcIBwAAAA==.',['大青']='大青衣:BAAALAAECgcIBwAAAA==.',['天尊']='天尊神德:BAAALAADCgUIBQAAAA==.',['天月']='天月时:BAAALAAECgcIDgAAAA==.',['天生']='天生帅气:BAAALAADCgYIDAAAAA==.',['奔驰']='奔驰牌的夏立:BAAALAAECgYIEgAAAA==.',['她耳']='她耳朵不好:BAAALAAECgIIAgAAAA==.',['妮姑']='妮姑:BAAALAAECggIDQAAAA==.',['妲奈']='妲奈奈:BAAALAAECgUICgAAAA==.',['守望']='守望寂寞:BAABLAAECn8dAAIDAAcITxQHogC0AQADAAcITxQHogC0AQAAAA==.',['安舞']='安舞格枫:BAAALAAECgcIBwAAAA==.',['小萨']='小萨走一回:BAAALAAECgEIAQAAAA==.',['小野']='小野花喵丶:BAAALAADCgYIBgAAAA==.',['尼姑']='尼姑:BAAALAAECgUIBQAAAA==.',['山鸡']='山鸡:BAAALAAECgYIDgAAAA==.',['巅峰']='巅峰步兵:BAAALAAECgUIBQAAAA==.',['巧克']='巧克力:BAABLAAFFH8LAAIPAAQIvRbkHABYAQAPAAQIvRbkHABYAQAAAA==.巧克力熊猫:BAABLAAFFH8FAAIQAAIIARWlXwCYAAAQAAIIARWlXwCYAAAAAA==.',['巨炮']='巨炮猎:BAAALAADCgYIBgAAAA==.',['巴尔']='巴尔泽布:BAAALAAECgIIAgAAAA==.',['帅猫']='帅猫猫:BAAALAAECgQIBAAAAA==.',['希林']='希林娜依:BAAALAAECgcICAAAAA==.',['张来']='张来福:BAAALAAECgYIBgAAAA==.',['影宝']='影宝:BAAALAAECgYIBgAAAA==.',['德布']='德布劳内:BAAALAAECgMIAwAAAA==.',['心之']='心之韧:BAAALAAECggICAAAAA==.',['思馨']='思馨:BAAALAAECgMIAwAAAA==.',['恋上']='恋上你的唇:BAAALAAECgcIEQAAAA==.',['悟茶']='悟茶:BAAALAAECggICAAAAA==.',['慢慢']='慢慢:BAAALAAECgEIAQAAAA==.',['拉鲁']='拉鲁拉丝:BAAALAAECgcIBwAAAA==.',['故梦']='故梦换新装:BAAALAAECgYIDAAAAA==.',['无名']='无名可可:BAAALAAECgYIBgAAAA==.',['星见']='星见雅:BAAALAAECgYICAAAAA==.',['星雅']='星雅若风:BAAALAADCgYIBgAAAA==.',['村花']='村花:BAAALAAECgEIAQAAAA==.',['果恴']='果恴崽:BAAALAAECgYICAAAAA==.',['柔情']='柔情猫娘:BAABLAAECn8dAAIRAAgILxLoEwChAQARAAgILxLoEwChAQAAAA==.',['桃子']='桃子同学丶:BAAALAAFFAIIAgAAAA==.',['框框']='框框:BAABLAAFFH8GAAIKAAYIqhXFLQBjAQAKAAYIqhXFLQBjAQAAAA==.',['梅川']='梅川库籽:BAACLAAFFH8IAAIDAAMIvw7xQwCIAAADAAMIvw7xQwCIAAAsAAQKf0UAAgMACAgbHzgWAFsCAAMACAgbHzgWAFsCAAAA.',['植物']='植物大战僵尸:BAAALAAECggICAAAAA==.',['武动']='武动乾坤:BAAALAAFFAIIBAAAAA==.',['残留']='残留的回想:BAAALAAECgYIDgAAAA==.',['汽车']='汽车人撤退:BAABLAAFFH8FAAISAAUI3QJQCwCqAAASAAUI3QJQCwCqAAAAAA==.',['法王']='法王:BAAALAAECgEIAQAAAA==.',['泗吥']='泗吥橡:BAAALAAECgIIAgAAAA==.',['泡灬']='泡灬僧贰拾叁:BAABLAAFFH8FAAITAAUIxhY6GACWAAATAAUIxhY6GACWAAAAAA==.泡灬僧贰拾壹:BAABLAAFFH8QAAITAAYIcRhaDgBiAQATAAYIcRhaDgBiAQAAAA==.泡灬僧贰拾柒:BAABLAAFFH8JAAITAAYIqQnHEgAbAQATAAYIqQnHEgAbAQAAAA==.泡灬僧贰拾肆:BAABLAAFFH8PAAITAAYIfBAJFQB8AAATAAYIfBAJFQB8AAAAAA==.泡灬僧贰拾贰:BAABLAAFFH8GAAITAAYIMw9GEQA2AQATAAYIMw9GEQA2AQAAAA==.',['洛克']='洛克塔丶欧噶:BAAALAADCgYIBgAAAA==.',['活的']='活的很好:BAAALAADCgQIBAAAAA==.',['派蒙']='派蒙:BAAALAAECgYIBgAAAA==.',['浴火']='浴火重生:BAAALAAECgcIEQAAAA==.',['淡淡']='淡淡天赐香:BAAALAAECgYIBgAAAA==.',['潘达']='潘达爱美丽:BAAALAADCgIIAgAAAA==.',['炉石']='炉石撤退:BAAALAAECgYICQAAAA==.',['牛七']='牛七重天:BAAALAAFFAIIAgAAAA==.',['牛叉']='牛叉牛叉:BAAALAAFFAIIAgAAAA==.',['牛鼻']='牛鼻子老道:BAAALAAFFAQIBAAAAA==.',['犄角']='犄角:BAAALAAECgEIAQAAAA==.',['狂暴']='狂暴战神:BAAALAAECgYIBgAAAA==.',['王都']='王都督:BAAALAAECgYIDAAAAA==.',['琬辣']='琬辣:BAAALAAECgQIBQAAAA==.',['琴声']='琴声细雨:BAAALAAECgYIDAAAAA==.',['疯爷']='疯爷:BAAALAAECgYIDQAAAA==.',['看我']='看我角:BAAALAAFFAIIAgAAAA==.',['碧落']='碧落黄泉:BAAALAAECggIBgAAAA==.',['神光']='神光闪耀:BAABLAAFFH8GAAIDAAIIVxusUQBSAAADAAIIVxusUQBSAAAAAA==.',['神灵']='神灵圣帝:BAAALAADCgMIAwAAAA==.',['纳特']='纳特:BAAALAAECggICAAAAA==.',['脑细']='脑细胞阵亡:BAAALAAECgMIAwAAAA==.',['腹肌']='腹肌磨马甲线:BAAALAADCgMIBAAAAA==.',['节奏']='节奏:BAABLAAECn8eAAMDAAgImh8rawATAgADAAgImh8rawATAgAUAAgITRBDPwA/AQAAAA==.',['花与']='花与爱丽丝:BAAALAADCgIIAgAAAA==.',['茗火']='茗火:BAABLAAFFH8HAAIPAAIIpg5STwCRAAAPAAIIpg5STwCRAAAAAA==.',['莓有']='莓有烦恼:BAABLAAFFH8FAAICAAUIIxHDCQBsAQACAAUIIxHDCQBsAQAAAA==.',['莱妮']='莱妮:BAAALAAECgEIAQAAAA==.',['菊花']='菊花等住我:BAAALAAECgYICgAAAA==.',['落雨']='落雨小潇潇:BAAALAADCgIIAgAAAA==.',['蕾娜']='蕾娜菈:BAAALAAECgIIAQAAAA==.',['虎虎']='虎虎尔:BAAALAAECgIIAgAAAA==.',['被遗']='被遗忘者:BAAALAAECgYICQAAAA==.',['诺贝']='诺贝尔:BAAALAAFFAIIBAAAAA==.',['谜谜']='谜谜米:BAABLAAFFH8TAAILAAQIWReRCACaAAALAAQIWReRCACaAAAAAA==.',['路西']='路西德:BAAALAAECgYIBgAAAA==.',['输煮']='输煮嘛给:BAAALAAECgcIBwAAAA==.',['酱爆']='酱爆牛肉:BAAALAAECgYIBgAAAA==.',['重生']='重生智力火花:BAABLAAECn8XAAMJAAYI+RyEmwCyAQAJAAYINBuEmwCyAQACAAYIbRWrTwB3AQAAAA==.',['野德']='野德芯之助:BAAALAAECgYIBgABLAAFFAcIOQADAEsmAA==.',['鈊茽']='鈊茽絠術:BAAALAADCgcIBwAAAA==.',['银月']='银月无裳:BAACLAAFFH8ZAAIVAAQIYQ6DCADDAAAVAAQIYQ6DCADDAAAsAAQKfyAAAhUACAjZFYcIAMUBABUACAjZFYcIAMUBAAAA.',['陆月']='陆月丿龙:BAAALAAECgYICwAAAA==.',['陈浩']='陈浩南:BAAALAAECgYICQAAAA==.',['陌丨']='陌丨佰:BAAALAAECgYIBgAAAA==.',['雪柔']='雪柔:BAABLAAFFH8HAAIWAAMIoRurDQADAQAWAAMIoRurDQADAQAAAA==.',['霞月']='霞月紫灵:BAAALAADCgEIAQAAAA==.',['青山']='青山寒枫:BAACLAAFFH8IAAIQAAIIrg0ZeACMAAAQAAIIrg0ZeACMAAAsAAQKfxUAAhAABgi1GP9NAFoBABAABgi1GP9NAFoBAAAA.',['风行']='风行月灵:BAAALAAFFAIIAgAAAA==.',['馨欣']='馨欣乡溪:BAABLAAECn8ZAAIJAAYI/BYlfABOAQAJAAYI/BYlfABOAQAAAA==.',['魅慕']='魅慕:BAAALAAECgYIDAAAAA==.',['魔弓']='魔弓手:BAABLAAFFH8NAAIJAAYIbBw6HgC5AQAJAAYIbBw6HgC5AQAAAA==.',['魔法']='魔法披风:BAABLAAFFH8GAAIMAAIIDSMjMgCmAAAMAAIIDSMjMgCmAAAAAA==.',['鲜切']='鲜切马尾:BAAALAAECgEIAQAAAA==.',['麦克']='麦克斯韦:BAAALAAECgYIDgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end