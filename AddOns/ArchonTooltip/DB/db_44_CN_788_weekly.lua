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
 local lookup = {'Warlock-Destruction','Hunter-BeastMastery','Hunter-Marksmanship','DeathKnight-Frost','DeathKnight-Blood','Warrior-Fury','Shaman-Elemental','Shaman-Restoration','DeathKnight-Unholy','Paladin-Protection','Mage-Fire','Mage-Arcane','Evoker-Devastation','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Vengeance','Monk-Brewmaster','Evoker-Preservation','Druid-Restoration','Evoker-Augmentation','Warrior-Protection','Druid-Guardian','Druid-Feral','Priest-Holy','Paladin-Retribution','Druid-Balance','Rogue-Assassination','Rogue-Subtlety','Paladin-Holy','Hunter-Survival','Warrior-Arms','Warlock-Demonology',}; local provider = {region='CN',realm='纳沙塔尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bu='Buffwarlock:BAABLAAFFH8iAAIBAAYIZyLtBQBaAgABAAYIZyLtBQBaAgAAAA==.',Ca='Caitlyn:BAABLAAFFH8NAAICAAgIMAWSVwDuAAACAAgIMAWSVwDuAAAAAA==.',Ch='Chiron:BAABLAAFFH8UAAMCAAYIphqEJwCUAQACAAYIphqEJwCUAQADAAIIxQaiLABtAAAAAA==.',Da='Darkbaron:BAAALAAECgQIBAAAAA==.',Ir='Ireliia:BAABLAAFFH8cAAMEAAcIuRY2HADFAQAEAAcIVRY2HADFAQAFAAMIKxlgCgDTAAABLAAFFAgICgAEAOQiAA==.',Ly='Lywarlock:BAABLAAFFH8LAAIBAAYI0RiIIwCNAQABAAYI0RiIIwCNAQAAAA==.',Ma='Maryia:BAABLAAFFH8IAAIGAAgIbgAFZwAMAAAGAAgIbgAFZwAMAAAAAA==.',Mi='Missfortune:BAAALAADCgYIBgAAAA==.',Mo='Moonbeam:BAABLAAFFH8KAAMHAAYI9xJwIgAvAQAHAAUIaxRwIgAvAQAIAAEINQP9fAAtAAAAAA==.',Na='Nausicaa:BAAALAAECggIDQAAAA==.',Ni='Nissen:BAAALAADCgMIAwAAAA==.',Po='Poka:BAAALAAECgQIBwAAAA==.',Re='Recovery:BAACLAAFFH8XAAIFAAMIwAjGFQBlAAAFAAMIwAjGFQBlAAAsAAQKfysAAwUACAiqDnsUADwBAAUACAgbDXsUADwBAAkABAjLFMIWAMEAAAAA.',Ry='Ryokouu:BAABLAAFFH8KAAIKAAIIDxAlHgAvAAAKAAIIDxAlHgAvAAAAAA==.',Sa='Saiyantpro:BAABLAAFFH8TAAMLAAQIFxbkBQDWAAAMAAMIPhlWKADyAAALAAQIPw/kBQDWAAABLAAFFAcIMQANAEkfAA==.',To='Tosca:BAAALAAFFAIIAwAAAA==.',Ve='Venetosiu:BAAALAAECggICAABLAAECggICAAOAAAAAA==.',Yi='Yigedh:BAACLAAFFH8yAAIPAAYIVSRjCwASAgAPAAYIVSRjCwASAgAsAAQKfxQAAw8ABghLJC4/AGUCAA8ABghLJC4/AGUCABAABQjFHJ4iAKEBAAEsAAUUCAgIABAAmQUA.',['一回']='一回头吓死牛:BAAALAAECgYICQAAAA==.',['一队']='一队的萨满:BAAALAAECgYIEgAAAA==.',['三魂']='三魂之玉:BAABLAAFFH8cAAIRAAUICAe+FQDcAAARAAUICAe+FQDcAAAAAA==.',['丨末']='丨末世翱翔丨:BAABLAAFFH8IAAISAAYIABTvDAB2AQASAAYIABTvDAB2AQAAAA==.',['丶路']='丶路遥:BAABLAAFFH8YAAIBAAgISxrLCwBEAgABAAgISxrLCwBEAgAAAA==.',['仙丶']='仙丶魔:BAAALAAECgEIAQAAAA==.',['仙灬']='仙灬魔:BAAALAADCgMIAwAAAA==.',['你的']='你的老爸:BAAALAADCggICAAAAA==.',['依文']='依文:BAABLAAFFH8cAAIFAAYIRRn/CACLAQAFAAYIRRn/CACLAQAAAA==.',['信仰']='信仰狂暴战:BAAALAAFFAIIBAAAAA==.',['俺也']='俺也一样:BAAALAAECgYIBgAAAA==.',['倦鸟']='倦鸟余花:BAABLAAFFH8GAAITAAYIugHUMACnAAATAAYIugHUMACnAAAAAA==.',['偷塑']='偷塑料贼:BAACLAAFFH9IAAMNAAgIhSVjAAABAwANAAgIhSVjAAABAwAUAAUI1BZkAwCfAQAsAAQKfzsAAw0ACAh/JM4JAP4CAA0ACAgKJM4JAP4CABQABwhKI/QCAMsCAAAA.',['傻了']='傻了吧叽:BAAALAAFFAIIAgAAAA==.',['八面']='八面佛:BAAALAADCgYIBgAAAA==.',['冰封']='冰封牛:BAAALAAECgYIBgAAAA==.',['冰火']='冰火齐发:BAAALAAECgYIDQAAAA==.',['凤舞']='凤舞龙飞:BAABLAAFFH8GAAIQAAIIAQgGFwBZAAAQAAIIAQgGFwBZAAAAAA==.',['切我']='切我:BAAALAADCgcIBwAAAA==.',['劍多']='劍多食广:BAAALAAECgYIEQAAAA==.',['加班']='加班李嘴黑:BAABLAAFFH8OAAIPAAYI2xqKGQCjAQAPAAYI2xqKGQCjAQAAAA==.',['勇者']='勇者无畏:BAABLAAECn8XAAMGAAgIdQojagDXAAAGAAgIdQojagDXAAAVAAUIvwR8PgCTAAAAAA==.',['北斗']='北斗圣启:BAAALAAECgUIBgAAAA==.北斗翳恴:BAACLAAFFH8MAAIWAAIIVg9ADQAwAAAWAAIIVg9ADQAwAAAsAAQKfxcAAhYABwipFLsQACsBABYABwipFLsQACsBAAAA.',['十月']='十月星尘:BAAALAAECgMIBAAAAA==.',['午夜']='午夜獠牙哥:BAAALAADCgUIBQAAAA==.午夜芭比:BAAALAADCgQIBAAAAA==.',['半拉']='半拉柯基:BAACLAAFFH8tAAMPAAgI1xgSBwAsAgAPAAgI1xgSBwAsAgAQAAMIfQvlDQBdAAAsAAQKf0UAAg8ACAg/JZoKAEwDAA8ACAg/JZoKAEwDAAAA.',['南方']='南方小细妹:BAAALAADCgMIBAAAAA==.',['卡琳']='卡琳:BAABLAAFFH8eAAICAAYIIR5SMgBxAQACAAYIIR5SMgBxAQAAAA==.',['卡破']='卡破天:BAAALAAECgQIBQAAAA==.卡破玩:BAAALAAECgQIBAAAAA==.',['卡雯']='卡雯笛珝:BAAALAAFFAEIAQAAAA==.',['又芭']='又芭比抠了:BAAALAAECgQIAgAAAA==.',['双鱼']='双鱼的露娜:BAAALAAECgYICwAAAA==.',['可儿']='可儿:BAABLAAFFH8OAAIBAAYIdg21MQBQAQABAAYIdg21MQBQAQAAAA==.',['叶一']='叶一萨:BAAALAAECgYICAAAAA==.',['叽哩']='叽哩咕噜:BAAALAAECgQICAAAAA==.',['周米']='周米粒:BAAALAAECggICAAAAA==.',['咆哮']='咆哮之威:BAAALAAECgYIDwAAAA==.',['咖啡']='咖啡冰沙:BAAALAAECgYICAAAAA==.',['哥只']='哥只是传说:BAAALAAECgYICAAAAA==.',['哪吒']='哪吒仔:BAAALAADCgcIBwAAAA==.',['唔芭']='唔芭比抠了:BAAALAAECgYIBwAAAA==.',['嘉尛']='嘉尛囡:BAAALAADCgEIAQAAAA==.',['四枫']='四枫院夜一:BAABLAAFFH8eAAIBAAYIShwxHgClAQABAAYIShwxHgClAQAAAA==.',['圣光']='圣光忽悠着我:BAAALAAECgEIAQAAAA==.',['士兵']='士兵男孩:BAACLAAFFH8qAAIGAAcIERibCgAMAgAGAAcIERibCgAMAgAsAAQKfysAAgYACAgAINcRAFgCAAYACAgAINcRAFgCAAAA.',['夜魔']='夜魔雕翎:BAAALAAECgYIBwAAAA==.',['大熊']='大熊猫:BAABLAAECn8bAAIRAAgITgP0GwCnAAARAAgITgP0GwCnAAAAAA==.',['奶不']='奶不起来:BAABLAAECn8YAAMWAAYIGg/0FADvAAAWAAYIGg/0FADvAAAXAAEIuANOUQAeAAAAAA==.',['如玉']='如玉:BAAALAAECgMIAwAAAA==.',['妃蓝']='妃蓝妮:BAAALAADCgcIBwAAAA==.',['妈妈']='妈妈:BAABLAAFFH8RAAIYAAgIphqBAwCrAgAYAAgIphqBAwCrAgAAAA==.',['妳的']='妳的佬玛:BAAALAADCgEIAQAAAA==.',['宿命']='宿命枷锁德:BAAALAAECgYICwAAAA==.',['寂寞']='寂寞小贝贝:BAAALAAECgMIAwAAAA==.寂寞的小贝贝:BAAALAAECgIIAgAAAA==.',['小乐']='小乐丶:BAAALAAECgEIAQAAAA==.',['小加']='小加阿姨:BAAALAAFFAIIAgAAAA==.',['小影']='小影子:BAAALAAECgYICwAAAA==.',['小楼']='小楼听雨夜思:BAAALAAECgIIAgAAAA==.小楼听风:BAAALAAECgcIDwAAAA==.',['小涛']='小涛爱浪:BAAALAAECgIIAgAAAA==.',['小鼻']='小鼻嘎:BAABLAAFFH8KAAICAAQImRutVgDyAAACAAQImRutVgDyAAAAAA==.',['少女']='少女时蛋:BAAALAAFFAIIAgAAAA==.',['巴迪']='巴迪乖乖:BAABLAAFFH8VAAIBAAgIpBgMDQAzAgABAAgIpBgMDQAzAgAAAA==.',['希里']='希里:BAABLAAFFH8KAAIPAAYIbAsJJQBlAQAPAAYIbAsJJQBlAQAAAA==.',['幽冥']='幽冥丨刃灬:BAAALAADCgQIBAAAAA==.',['强军']='强军先锋:BAAALAAECggIDwAAAA==.',['强力']='强力公牛:BAAALAADCgMIAwAAAA==.',['德帅']='德帅:BAAALAAECgYICQAAAA==.',['德鲁']='德鲁医生:BAAALAAECggICAAAAA==.德鲁猫:BAABLAAFFH8FAAIWAAMIKyAoBgCrAAAWAAMIKyAoBgCrAAAAAA==.',['怨灵']='怨灵射手:BAABLAAECn8UAAICAAgIlhM3XACKAQACAAgIlhM3XACKAQAAAA==.怨灵杀手:BAAALAAFFAIIBAAAAA==.怨灵骑士:BAAALAAECgcIBwAAAA==.怨灵骑矢:BAAALAAECgIIAgAAAA==.怨灵魔术:BAAALAAECgYICwAAAA==.',['恶魔']='恶魔的杀戮:BAAALAAECgYICQAAAA==.',['情授']='情授:BAAALAAFFAMIAQAAAA==.',['慕容']='慕容贝贝:BAAALAAECgYIBgAAAA==.',['戈德']='戈德莉亚:BAABLAAFFH8SAAIZAAYIYBlPGACRAQAZAAYIYBlPGACRAQAAAA==.',['戈鲁']='戈鲁:BAAALAAECgEIAQAAAA==.',['我是']='我是胖子丶:BAABLAAFFH8SAAIPAAUIrRKOLAAyAQAPAAUIrRKOLAAyAQAAAA==.',['我黑']='我黑:BAAALAAFFAIIAgAAAA==.',['扛不']='扛不住怪:BAAALAAECgYICgAAAA==.',['挺无']='挺无敌三:BAABLAAFFH8FAAIIAAMIzwqfVABoAAAIAAMIzwqfVABoAAAAAA==.',['插棍']='插棍子:BAAALAAECgYIBwAAAA==.',['擒授']='擒授:BAABLAAFFH8HAAIIAAQIiBq2EAA5AQAIAAQIiBq2EAA5AQAAAA==.',['攻守']='攻守之道:BAAALAADCggICAAAAA==.',['放开']='放开那妞:BAAALAAECgMIBgAAAA==.',['敖蕾']='敖蕾莉亚:BAAALAAECggIDQAAAA==.',['无敌']='无敌小娟:BAAALAAECgYICgAAAA==.',['春卷']='春卷:BAABLAAFFH8GAAIZAAYIbRTpHAB5AQAZAAYIbRTpHAB5AQAAAA==.',['暗之']='暗之魔鬼修罗:BAABLAAECn8gAAIGAAcICw8MUQAiAQAGAAcICw8MUQAiAQAAAA==.',['暗影']='暗影之龙:BAAALAAECgEIAQAAAA==.暗影天使:BAAALAAECgYIEQAAAA==.',['暗黑']='暗黑的夜:BAAALAAECgIIAgAAAA==.',['月丸']='月丸吨:BAAALAAFFAMIAwAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8IAAMTAAgIIhOfDgDVAQATAAcIBxOfDgDVAQAaAAEIQRn4KgBbAAAAAA==.',['杀破']='杀破羊:BAABLAAFFH8eAAMbAAYIPBLPDABAAQAbAAUI6xDPDABAAQAcAAMIdgxADwCHAAAAAA==.',['死了']='死了不能爱:BAAALAADCgYIBgAAAA==.',['死亡']='死亡初体验:BAAALAADCgEIAQAAAA==.',['比杀']='比杀劫:BAAALAAECgQICAAAAA==.',['毛毛']='毛毛雨睡醒了:BAAALAAECgcIBwAAAA==.',['淡淡']='淡淡的龙井茶:BAACLAAFFH8KAAIZAAMILBsoPgCaAAAZAAMILBsoPgCaAAAsAAQKfxcAAxkACAiAIH8lANsCABkACAiAIH8lANsCAB0ABgihCqkpAPQAAAAA.',['深夜']='深夜狗食馆:BAAALAAECgcIBwAAAA==.',['渐渐']='渐渐遠去的心:BAACLAAFFH8HAAMCAAMIVRHaTACYAAACAAMIVRHaTACYAAAeAAEIRgp7BwAAAAAsAAQKfxUABB4ABgi6HPgSAHwBAB4ABQgQGvgSAHwBAAIABQguFl3qAEkBAAMAAgg7DW2rAFkAAAAA.',['温柔']='温柔的大伟:BAAALAAECgYIBgAAAA==.',['潇雨']='潇雨唲:BAABLAAFFH8GAAIYAAMIRgdbMwCbAAAYAAMIRgdbMwCbAAAAAA==.',['火鸡']='火鸡味锅巴:BAAALAADCgYIBgAAAA==.',['炎耀']='炎耀天:BAACLAAFFH8LAAIVAAMIBwZpJgBNAAAVAAMIBwZpJgBNAAAsAAQKfx0ABBUACAhFCuwwANkAABUACAhSCOwwANkAAAYABgiZB0B/AJYAAB8AAgj3CDw1AFUAAAAA.',['炒股']='炒股打牌喝茶:BAAALAAECgYIBgAAAA==.',['烽火']='烽火术:BAAALAAECgQIBAAAAA==.烽火连成:BAAALAAECgYIDQAAAA==.',['狱邪']='狱邪魂断:BAAALAAECgQIBAAAAA==.',['琪琪']='琪琪小宝贝:BAAALAAECgYIEQAAAA==.',['瑟理']='瑟理亚德唧唧:BAAALAAECggICAAAAA==.',['破卡']='破卡:BAAALAAECgUICwAAAA==.破卡卡:BAAALAAECgYIBgAAAA==.',['祝您']='祝您永不窜稀:BAAALAADCgcIAwAAAA==.',['神不']='神不知鬼不觉:BAAALAAFFAIIAgAAAA==.',['神圣']='神圣符文:BAAALAADCgEIAgAAAA==.神圣闪烁:BAAALAADCgcIBwAAAA==.',['禅意']='禅意人生:BAABLAAFFH8IAAIRAAIInwFtHgBCAAARAAIInwFtHgBCAAAAAA==.',['私人']='私人助理:BAAALAADCgMIAwAAAA==.',['秋沫']='秋沫:BAAALAAECgIIAwAAAA==.',['科斯']='科斯塔:BAAALAAFFAIIAgAAAA==.',['箭多']='箭多食广:BAAALAAECgQICAAAAA==.',['绿夏']='绿夏:BAAALAADCgMIAwAAAA==.',['罗小']='罗小贝:BAAALAAECgYIDAAAAA==.',['罗莎']='罗莎莎:BAABLAAFFH8GAAIZAAYIzhxvEwCuAQAZAAYIzhxvEwCuAQAAAA==.',['老辈']='老辈子:BAAALAAECgMIBgAAAA==.',['自寻']='自寻死路丶:BAAALAAECgMIAwAAAA==.',['至今']='至今思项羽:BAAALAAECgIIAgAAAA==.',['艾莉']='艾莉塔:BAABLAAFFH8IAAIGAAYIuwqFJQBDAQAGAAYIuwqFJQBDAQAAAA==.',['花堪']='花堪折:BAABLAAFFH8KAAIMAAIIJgpAXwA8AAAMAAIIJgpAXwA8AAAAAA==.',['苏大']='苏大强:BAAALAAECgMIAwAAAA==.',['莫宁']='莫宁斯塔:BAAALAAECgYIBgAAAA==.',['莫小']='莫小加:BAABLAAFFH8eAAITAAYIvRFfFwB4AQATAAYIvRFfFwB4AQAAAA==.',['莲升']='莲升:BAABLAAFFH8FAAIIAAMItRAsSACOAAAIAAMItRAsSACOAAABLAAFFAgIAgAOAAAAAA==.',['萌比']='萌比带闪电:BAAALAAECgYIBgAAAA==.',['萨博']='萨博尼斯:BAAALAAFFAIIAgAAAA==.',['萨满']='萨满卡琳:BAAALAAECgIIAgAAAA==.',['虾仁']='虾仁猪心:BAACLAAFFH8IAAIPAAII0QqlTgCOAAAPAAII0QqlTgCOAAAsAAQKfxQAAg8ACAh+GOROADUCAA8ACAh+GOROADUCAAAA.',['蛋哥']='蛋哥:BAAALAAECgMIBAAAAA==.',['见卡']='见卡破玩萨满:BAAALAAECgQIBAAAAA==.',['请注']='请注意丶倒车:BAAALAADCgEIAQAAAA==.',['超雄']='超雄马保国:BAABLAAFFH8IAAIEAAII0Bz6RgCpAAAEAAII0Bz6RgCpAAAAAA==.',['路遥']='路遥丶:BAABLAAFFH8MAAIBAAYIdhxAHQCqAQABAAYIdhxAHQCqAQAAAA==.',['邪灬']='邪灬:BAAALAAECgQIBAAAAA==.',['重生']='重生灰烬:BAAALAAECggIDgAAAA==.',['鑫茂']='鑫茂冰:BAAALAAECgYIBwAAAA==.',['银色']='银色梦幻:BAAALAADCgIIAgAAAA==.',['闷骚']='闷骚的大伟:BAAALAAECgYICwAAAA==.',['阿芒']='阿芒拿满:BAAALAAECgMIAwAAAA==.',['雷电']='雷电神光:BAAALAAECgUIBQAAAA==.',['非常']='非常法:BAAALAAECgYIEAAAAA==.',['额芭']='额芭比抠了:BAAALAAECgYICAAAAA==.',['风暴']='风暴行者:BAAALAAECgUIBQAAAA==.',['飞龙']='飞龙在天:BAABLAAECn8hAAMUAAYI1wWzEwDzAAAUAAYI1wWzEwDzAAASAAUIagjMGwCfAAAAAA==.',['饕餮']='饕餮小毛:BAAALAAECgYIBgAAAA==.',['鬼瑰']='鬼瑰丶:BAAALAAECgEIAQAAAA==.',['魅影']='魅影騎士:BAAALAADCgIIAgAAAA==.',['魔羽']='魔羽飞狼:BAACLAAFFH8PAAMgAAII1ha2GACSAAAgAAIIXRW2GACSAAABAAII1AmxYAA+AAAsAAQKfy0AAyAACAiYGKkgAP4BACAABgjeHakgAP4BAAEACAgcFN80AHYBAAAA.',['鹤鸣']='鹤鸣九皋:BAAALAADCgYIBgAAAA==.',['黄泉']='黄泉送葬:BAAALAAECgYIEgAAAA==.',['黄色']='黄色真好:BAAALAAECgYIEAAAAA==.',['黑夜']='黑夜传说:BAAALAADCggICAAAAA==.',['黯然']='黯然伤神:BAAALAAECgYICwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end