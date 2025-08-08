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
 local lookup = {'Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Monk-Windwalker','Warrior-Arms','Warrior-Fury','DeathKnight-Unholy','Shaman-Enhancement','Shaman-Restoration','Priest-Holy','Priest-Shadow','Priest-Discipline','Unknown-Unknown','Paladin-Retribution','Paladin-Protection','DemonHunter-Havoc','Druid-Balance','Warlock-Destruction','Druid-Restoration','DemonHunter-Vengeance','Mage-Arcane','DeathKnight-Blood','Paladin-Holy','Mage-Frost','Rogue-Assassination','Warlock-Affliction','Monk-Brewmaster','Shaman-Elemental','Mage-Fire','Evoker-Devastation','Rogue-Outlaw',}; local provider = {region='CN',realm='森金',name='CN',type='weekly',zone=42,date='2025-08-08',data={Be='Belief:BAABKgAFFH8LAAMBAAYIrR7cAADLAQABAAYIGx7cAADLAQACAAIIjCA1QACeAAAAAA==.',Bl='Blanny:BAAAKgAECgIIAgAAAA==.',Cl='Clarence:BAABKgAFFH8GAAMDAAUIyhibCgAQAQADAAQI9xSbCgAQAQAEAAEIfA3AGQBeAAAAAA==.',Co='Coco:BAAAKgAECggICAAAAA==.Comeover:BAAAKgAECggICAAAAA==.',De='Deluyi:BAAAKgAECgEIAQAAAA==.',Dm='Dmile:BAAAKgAECgIIAgAAAA==.',Em='Embert:BAAAKgAFFAEIAQAAAA==.',Ev='Evga:BAAAKgAECgYICgAAAA==.',Ex='Excuses:BAAAKgAECgUIBQAAAA==.',Fo='Foreverl:BAAAKgAFFAIIAgAAAA==.Former:BAAAKgAECgIIAgAAAA==.',Fr='Freeandnil:BAACKgAFFH8tAAMBAAcIXhWsDQAjAQABAAUIUxSsDQAjAQACAAMI5RbpFADmAAAqAAQKfywAAwEACAgEJTIFAM0CAAEACAjYJDIFAM0CAAIABAguId0pAC4BAAAA.',Gr='Grieved:BAAAKgAECgUIBQAAAA==.',Ku='Kun:BAAAKgAECgcIAgAAAA==.',Ls='Lsir:BAAAKgAFFAIIAgAAAA==.',Ni='Nichol:BAAAKgAECgUIBQAAAA==.',Or='Orchard:BAAAKgAECgEIAgAAAA==.',Pl='Playervhstoa:BAAAKgAECgcICgAAAA==.',Rk='Rko:BAABKgAFFH8jAAMFAAgIbiK/AADXAQAGAAgIbiIbAwCJAgAFAAYIKRu/AADXAQAAAA==.',Sm='Smileknight:BAAAKgAECgIIAgAAAA==.',St='Starmen:BAAAKgAFFAQIAwAAAA==.Starskydk:BAABKgAFFH8IAAIHAAgIWRKCCAAHAgAHAAgIWRKCCAAHAgAAAA==.Starskysm:BAABKgAFFH8IAAMIAAgIPQwXBgCaAQAIAAcIwAwXBgCaAQAJAAEIZAChUQA4AAAAAA==.',Sw='Swissian:BAABKgAFFH8IAAICAAQIoyV7BwBNAQACAAQIoyV7BwBNAQAAAA==.',Vi='Violenceper:BAABKgAFFH8GAAIEAAYIlg9mAgChAQAEAAYIlg9mAgChAQAAAA==.',Wi='Will:BAAAKgAECgMIAwAAAA==.',Zo='Zombieh:BAAAKgADCgEIAQAAAA==.',['一只']='一只树奈奈:BAAAKgAFFAIIAgAAAA==.',['一号']='一号海底:BAAAKgADCgEIAwAAAA==.',['一蒹']='一蒹葭一:BAAAKgAECgQIBAAAAA==.',['七喜']='七喜:BAAAKgAFFAQIBAAAAA==.',['三义']='三义共生:BAAAKgADCgEIAQAAAA==.',['不会']='不会游泳的宇:BAAAKgAECgUICgAAAA==.',['不吃']='不吃牛肉:BAAAKgAFFAIIAgAAAA==.',['不黑']='不黑:BAAAKgADCggICAAAAA==.',['世仁']='世仁林飞:BAACKgAFFH8IAAQKAAMIlg71KgCXAAAKAAMIlg71KgCXAAALAAEIjAiCMQAxAAAMAAEI0wK8NQAsAAAqAAQKfxsAAwoABwjJEB88AEoBAAoABwjJEB88AEoBAAsABgh5EbQ7ABMBAAEqAAUUBAgEAA0AAAAA.',['东兽']='东兽祭:BAABKgAFFH8GAAIBAAYISBVGUgA2AAABAAYISBVGUgA2AAAAAA==.',['丢总']='丢总诺伊:BAAAKgAECgYICAAAAA==.',['丨李']='丨李小花丨:BAAAKgADCggICAAAAA==.',['丨鲜']='丨鲜血圣歌丨:BAABKgAFFH8MAAMOAAgI3A94DQAeAQAOAAQIJSJ4DQAeAQAPAAgI5QJcEAABAQAAAA==.',['中二']='中二病没得治:BAAAKgAFFAQIBAAAAA==.',['丶加']='丶加尔鲁什:BAAAKgAECgcIDQAAAA==.',['丶猎']='丶猎户座:BAAAKgAECggIEAAAAA==.',['丶麦']='丶麦辣鸡翅:BAAAKgAECgEIAQAAAA==.',['丿璐']='丿璐璐丿:BAABKgAFFH8KAAIGAAYI2xu2DACCAQAGAAYI2xu2DACCAQAAAA==.',['丿香']='丿香蕉丿:BAABKgAFFH8GAAIBAAYIOhsVEQBcAQABAAYIOhsVEQBcAQAAAA==.',['丿黯']='丿黯灬痕:BAABKgAFFH8FAAIOAAQI6xnAHgDsAAAOAAQI6xnAHgDsAAAAAA==.',['乌克']='乌克丽丽:BAAAKgAFFAQIBAAAAA==.',['乖张']='乖张鹏爷:BAAAKgAECgIIAgAAAA==.',['二阶']='二阶堂灬大盒:BAAAKgAECgMIAwAAAA==.',['云落']='云落光阴:BAAAKgAECgMIBQAAAA==.云落挽歌:BAAAKgAECgYIBgAAAA==.云落风尘:BAAAKgAECgUICAAAAA==.',['亲爱']='亲爱的罗曼德:BAAAKgAECgIIAgAAAA==.',['仙逝']='仙逝:BAAAKgADCgMIAwAAAA==.',['以魂']='以魂续命:BAABKgAFFH8GAAIQAAYIJxLEFwA9AQAQAAYIJxLEFwA9AQAAAA==.',['伊利']='伊利丶牛:BAAAKgAECgYIBgAAAA==.',['伤心']='伤心洞庭湖:BAAAKgADCggIEAAAAA==.',['你丫']='你丫缺德:BAAAKgADCgEIAQAAAA==.',['光锭']='光锭喝七喜:BAAAKgAECggICgAAAA==.',['兙勥']='兙勥:BAABKgAFFH8FAAIHAAMIYAx5OgCzAAAHAAMIYAx5OgCzAAAAAA==.',['全天']='全天猎杀:BAAAKgAECgEIAQAAAA==.',['兰幽']='兰幽丶郁语:BAAAKgAFFAQIBAAAAA==.',['兽血']='兽血沸腾:BAAAKgAFFAQIBAAAAA==.',['冥羽']='冥羽林飞:BAAAKgAFFAQIBAAAAA==.',['冰之']='冰之魔心:BAAAKgAECgUIBQAAAA==.',['冰嗏']='冰嗏丫丶:BAAAKgAFFAYIAgABKgAFFAgIDAARAHMZAA==.',['冰封']='冰封之殇:BAAAKgADCgUIBQAAAA==.',['冰火']='冰火之舞:BAAAKgADCgQIBAAAAA==.',['凉拌']='凉拌腰肝:BAABKgAFFH8FAAISAAUINhn7GAA8AQASAAUINhn7GAA8AQAAAA==.',['凤玉']='凤玉罗:BAABKgAFFH8cAAIHAAgI2x1CAwCQAgAHAAgI2x1CAwCQAgAAAA==.',['刘斩']='刘斩仙:BAAAKgAECgcIBwAAAA==.',['初吻']='初吻給勒煙:BAAAKgAFFAQIBAAAAA==.',['加拉']='加拉哈德:BAAAKgAECgMIAwAAAA==.',['勺十']='勺十六:BAAAKgAECgMIAwAAAA==.',['十亿']='十亿少女的梦:BAAAKgAECggIDAAAAA==.',['千紫']='千紫夏:BAAAKgAECgYIBgAAAA==.',['南天']='南天门:BAABKgAFFH8GAAMTAAYIzAdBHADBAAATAAUIEgdBHADBAAARAAEI3QF2YAA3AAABKgAFFAgICQARAGcJAA==.',['只玩']='只玩火法:BAAAKgAECgcIBwAAAA==.',['可可']='可可熊:BAAAKgAFFAUIBAAAAA==.',['吉德']='吉德:BAAAKgADCgEIAQAAAA==.',['吱吱']='吱吱:BAABKgAFFH8KAAMQAAQIlBpNJADpAAAQAAQIlBpNJADpAAAUAAIIuREkEQB5AAAAAA==.',['咖喱']='咖喱牛肉:BAAAKgAECgUIBQAAAA==.',['品德']='品德:BAAAKgADCgcIBwAAAA==.',['哇哈']='哇哈哈:BAAAKgAFFAgIBAAAAA==.',['嗜血']='嗜血奥术:BAABKgAFFH8KAAIVAAgIAxqGBABbAgAVAAgIAxqGBABbAgAAAA==.',['嘉伈']='嘉伈饼干:BAAAKgAFFAMIAwABKgAFFAgIDgAKABEgAA==.',['嘘别']='嘘别说话:BAABKgAFFH8GAAIWAAYIxQM7DAC3AAAWAAYIxQM7DAC3AAAAAA==.',['圣光']='圣光小花牛:BAABKgAFFH8MAAIOAAQICxFzKgDIAAAOAAQICxFzKgDIAAAAAA==.圣光旋律:BAAAKgAFFAQIBAAAAA==.圣光爆裂:BAABKgAECn8gAAMXAAgIhRgYEAAAAgAXAAgIhRgYEAAAAgAOAAMIEQb/SQFiAAABKgAFFAEIAQANAAAAAA==.圣光老崔:BAABKgAFFH8OAAIOAAQIZCWVMAAmAQAOAAQIZCWVMAAmAQAAAA==.',['圣皇']='圣皇凯撒:BAAAKgAECgcIEAAAAA==.',['圣魔']='圣魔之烟儿:BAABKgAFFH8GAAIYAAMIowaaDgCiAAAYAAMIowaaDgCiAAAAAA==.',['堕落']='堕落的圣人:BAAAKgAECgYIBwAAAA==.',['墨丶']='墨丶语:BAAAKgAFFAQIBAAAAA==.',['壊人']='壊人:BAABKgAFFH8IAAIOAAgI+gqCEQDSAQAOAAgI+gqCEQDSAQAAAA==.',['复仇']='复仇者:BAAAKgAECgMIAwAAAA==.',['夜封']='夜封钰:BAAAKgAFFAEIAQAAAA==.',['夜幕']='夜幕丶未央:BAAAKgADCggICAAAAA==.夜幕丶花未央:BAAAKgAECggICAAAAA==.',['夜空']='夜空星:BAABKgAFFH8VAAMRAAgI4Rr4CwDDAQARAAgI4Rr4CwDDAQATAAUIYxZ4GgDNAAAAAA==.',['夜舞']='夜舞:BAABKgAFFH8PAAMUAAgIKwp/BQBJAQAQAAgIRgaLCwCqAQAUAAcIPwt/BQBJAQAAAA==.',['大耐']='大耐:BAABKgAFFH8RAAMOAAQIwxupHQDuAAAOAAMIwxupHQDuAAAPAAQIQRUKGwCgAAAAAA==.',['大苏']='大苏打撒:BAAAKgAECgIIAgAAAA==.',['天丶']='天丶谴:BAAAKgAFFAQIBAABKgAFFAgIBgASAC4RAA==.',['天亮']='天亮中的黑芒:BAAAKgAECgMIAwAAAA==.',['天魔']='天魔王:BAAAKgADCgEIAQAAAA==.',['太阳']='太阳神彡:BAAAKgAECgUIBQAAAA==.',['好看']='好看:BAAAKgAECgQIBAAAAA==.',['妖妖']='妖妖铃:BAAAKgAECgcIBwAAAA==.',['娃哈']='娃哈哈:BAAAKgAFFAQIBAAAAA==.',['孤高']='孤高的梦:BAABKgAFFH8IAAIOAAgIOg95DQD6AQAOAAgIOg95DQD6AQAAAA==.',['宜春']='宜春:BAAAKgAECgEIAgAAAA==.',['宝总']='宝总小媳妇:BAAAKgAECgEIAQAAAA==.',['宥宥']='宥宥:BAAAKgAECggICAAAAA==.',['寒冰']='寒冰:BAAAKgADCgQIBAAAAA==.',['寸芒']='寸芒天虹:BAAAKgAECgcIEwAAAA==.',['射箭']='射箭老崔:BAABKgAFFH8JAAMBAAYIix5EEgBRAQABAAUImR1EEgBRAQACAAQIFRmRLwDMAAABKgAFFAgIDQABALkfAA==.',['小丑']='小丑灬哈利:BAAAKgAECgYIBQAAAA==.',['小江']='小江江:BAAAKgAFFAQIAwAAAA==.',['小猪']='小猪在树上:BAAAKgAFFAQIBAAAAA==.小猪奔月:BAAAKgAECgMIAwAAAA==.',['小雯']='小雯驿:BAAAKgAFFAMIAwAAAA==.',['尔尔']='尔尔丶:BAAAKgAECggICAABKgAFFAgIEQAKAJgWAA==.',['巫喵']='巫喵王再怒:BAAAKgAECgYIBwAAAA==.',['布洛']='布洛克斯希加:BAABKgAFFH8FAAIFAAUIYBlcDQA6AQAFAAUIYBlcDQA6AQAAAA==.',['帝王']='帝王引擎:BAAAKgAFFAEIAQABKgAFFAUIBQAFACQOAA==.',['幺鸡']='幺鸡:BAABKgAFFH8GAAIRAAYIzRzEEACZAQARAAYIzRzEEACZAQAAAA==.',['开始']='开始了电话:BAAAKgADCggICAAAAA==.',['弑灬']='弑灬殇:BAABKgAECn8fAAIHAAgI2hc0KwDQAQAHAAgI2hc0KwDQAQAAAA==.',['张无']='张无奇:BAAAKgAECgIIAgAAAA==.',['弥赛']='弥赛斯杜:BAAAKgAFFAgIBAAAAA==.',['强强']='强强:BAABKgAFFH8QAAIBAAgIghzDAgByAgABAAgIghzDAgByAgAAAA==.',['很厉']='很厉害得呦:BAABKgAFFH8NAAIQAAQIiiPqHgAMAQAQAAQIiiPqHgAMAQAAAA==.',['忆灬']='忆灬殇:BAAAKgADCgMIAwAAAA==.',['怜悯']='怜悯丶:BAABKgAFFH8RAAQKAAgImBb8BADVAQAKAAgIbRT8BADVAQAMAAQIbhEVDwDfAAALAAMIchJaFgCxAAAAAA==.',['恋芝']='恋芝:BAABKgAFFH8GAAIJAAYI9gkfFwAmAQAJAAYI9gkfFwAmAQAAAA==.',['悠緈']='悠緈天空:BAAAKgAECgMIAwAAAA==.',['惩罚']='惩罚队友:BAABKgAFFH8GAAIZAAYIZhaNDACEAQAZAAYIZhaNDACEAQAAAA==.',['感到']='感到害怕了吧:BAAAKgADCgEIAgAAAA==.',['慑魂']='慑魂的随便果:BAAAKgAECgUIBwAAAA==.',['憾天']='憾天:BAAAKgAECgYIBwAAAA==.',['戰丨']='戰丨将:BAAAKgAECgIIAgAAAA==.',['打火']='打火机:BAABKgAFFH8XAAIOAAYIciP4DAD/AQAOAAYIciP4DAD/AQAAAA==.',['扯淡']='扯淡的人生:BAAAKgAECgYIBgAAAA==.',['抬头']='抬头看看天:BAAAKgAECgQIBAAAAA==.',['抹茶']='抹茶灬小布町:BAAAKgAECgcIBwAAAA==.',['拳脚']='拳脚无眼:BAAAKgADCgIIAgAAAA==.',['拿盾']='拿盾就是坦:BAAAKgAECgQIBAAAAA==.',['搅得']='搅得周天寒彻:BAACKgAFFH8LAAIOAAMIORjqNgCbAAAOAAMIORjqNgCbAAAqAAQKfx0AAg4ACAj9G1NOAAcCAA4ACAj9G1NOAAcCAAAA.',['故城']='故城:BAAAKgAFFAIIBAAAAA==.',['敌奥']='敌奥炸天:BAAAKgAECgcICQAAAA==.',['救赎']='救赎肀审判:BAAAKgAECgUICAAAAA==.',['无双']='无双血狮:BAAAKgADCgMIAwAAAA==.无双血魔:BAAAKgADCgEIAQAAAA==.',['日居']='日居月诸:BAAAKgAECgYIBgAAAA==.',['晓嘟']='晓嘟嘟:BAAAKgADCgMIAwAAAA==.',['智者']='智者晓彻:BAAAKgAFFAgIBAAAAA==.',['暗影']='暗影吐息:BAAAKgAECgYIBgAAAA==.暗影小牧丶:BAABKgAFFH8QAAMMAAgIXBWfCQCAAQAMAAcI0RSfCQCAAQALAAMITh33EwDdAAAAAA==.',['暴力']='暴力熊猫:BAAAKgAFFAMIAwAAAA==.',['暴金']='暴金之妖孽:BAACKgAFFH8cAAQKAAUIiB5MBgAIAQAKAAQIZCBMBgAIAQAMAAMINhsBIACjAAALAAIInh/DHgCTAAAqAAQKfyUAAwoACAjhHrYZAAgCAAoACAjhHrYZAAgCAAsAAQjpAuF9AB4AAAAA.',['曾牛']='曾牛:BAAAKgAECgYIBgAAAA==.',['曾经']='曾经的床忆:BAAAKgAECgQIBAAAAA==.',['月下']='月下曙光:BAAAKgAFFAMIAwAAAA==.',['月光']='月光星晨:BAAAKgAECgUIBQAAAA==.',['月翎']='月翎:BAABKgAFFH8PAAMFAAYIqhYUAQDGAQAFAAYIXBQUAQDGAQAGAAUIaBmnEQA8AQAAAA==.',['望断']='望断南飞雁:BAAAKgAFFAYIAwAAAA==.',['木木']='木木秋:BAABKgAFFH8LAAMHAAgImA5lCgDnAQAHAAgImA5lCgDnAQAWAAIIVAm/HwBiAAAAAA==.',['木若']='木若深秋:BAAAKgAECgEIAQAAAA==.',['末丶']='末丶予:BAABKgAFFH8QAAIQAAQI5x4+DAAUAQAQAAQI5x4+DAAUAQAAAA==.',['术三']='术三绝:BAAAKgAECgEIAgAAAA==.',['杏灬']='杏灬林小小:BAABKgAFFH8QAAMMAAYIDhEDAgCrAQAMAAYIDhEDAgCrAQALAAYIpBEyBACJAQAAAA==.',['枯樹']='枯樹年华:BAAAKgAFFAIIAgAAAA==.',['柠檬']='柠檬心:BAABKgAECn8cAAMSAAgIkRllFgD0AQASAAgIkRllFgD0AQAaAAYIWg9xHwDdAAAAAA==.',['栋哥']='栋哥霸天下:BAABKgAFFH8FAAIVAAMIYAyMGQCyAAAVAAMIYAyMGQCyAAAAAA==.',['树奈']='树奈奈:BAAAKgADCggICAAAAA==.',['梦华']='梦华:BAAAKgADCgcIBwAAAA==.',['森森']='森森妹妹:BAAAKgADCgEIAQAAAA==.',['楚门']='楚门的世界:BAAAKgAECgYIEAAAAA==.',['榴莲']='榴莲棠:BAAAKgADCgUIBQAAAA==.',['樂佰']='樂佰氏:BAABKgAFFH8IAAIRAAQI5yNVLwBxAAARAAQI5yNVLwBxAAABKgAFFAgIDAARAHMZAA==.',['欣辛']='欣辛:BAAAKgAECgYIBgAAAA==.',['武丨']='武丨僧:BAABKgAFFH8PAAMDAAgIBwtFCACtAQADAAgIBwtFCACtAQAEAAQIRA2ADQDPAAAAAA==.',['死丨']='死丨騎:BAABKgAFFH8QAAIWAAgI8xdEBAASAgAWAAgI8xdEBAASAgAAAA==.',['沐雨']='沐雨言诗:BAABKgAECn8eAAMMAAgIaxwfFwAKAgAMAAgIRhofFwAKAgAKAAYI6RmaNQBGAQAAAA==.',['法丨']='法丨师:BAAAKgAFFAgIAgAAAA==.',['法号']='法号给力:BAAAKgAECggIEQAAAA==.',['泰丽']='泰丽莎洛雨:BAAAKgAFFAQIBAAAAA==.',['泷囍']='泷囍:BAACKgAFFH8IAAIHAAgIeBZtBgAuAgAHAAgIeBZtBgAuAgAqAAQKfxUAAgcABghTGpBVAGgBAAcABghTGpBVAGgBAAAA.',['泽西']='泽西:BAAAKgAECgUICAAAAA==.',['洋洋']='洋洋得宜:BAAAKgAECgQIBAAAAA==.',['浪味']='浪味大仙:BAAAKgAECggICAAAAA==.',['浪德']='浪德虚:BAABKgAFFH8LAAMRAAUIhQ5aIAAeAQARAAQIthFaIAAeAQATAAEIYADVPAAdAAAAAA==.',['海螺']='海螺:BAAAKgAFFAQIBAAAAA==.',['清允']='清允丶:BAAAKgADCggICAAAAA==.',['滚滚']='滚滚老崔:BAABKgAFFH8GAAIDAAYILA4hBAB/AQADAAYILA4hBAB/AQAAAA==.',['漫天']='漫天飘德花:BAAAKgAFFAgIAgAAAA==.',['火丶']='火丶影:BAAAKgAECggICwAAAA==.',['火正']='火正重黎:BAAAKgAECgYIDQAAAA==.火正鸣霜:BAAAKgAECgQIBAAAAA==.',['火炎']='火炎焱燚:BAAAKgAECgEIAQAAAA==.',['火神']='火神刘康:BAAAKgAFFAMIAQAAAA==.',['火舞']='火舞:BAAAKgADCgIIAgAAAA==.',['灬妮']='灬妮莉艾露灬:BAAAKgADCgMIAwAAAA==.',['灵魂']='灵魂之弦:BAAAKgADCgQIBAAAAA==.',['灿灬']='灿灬灿:BAABKgAFFH8OAAQEAAYILR6JBwCEAQAEAAYILR6JBwCEAQADAAQIXRTQHAC5AAAbAAIIdADJCQA6AAAAAA==.',['熊猫']='熊猫罐头:BAAAKgAECggICAAAAA==.',['爱沫']='爱沫德:BAAAKgAECgYIDAAAAA==.',['爱莱']='爱莱克奥润芷:BAAAKgADCggICAAAAA==.',['牛叁']='牛叁哥:BAAAKgAFFAEIAQAAAA==.',['牛纸']='牛纸:BAAAKgAFFAQIBAAAAA==.',['牧丶']='牧丶:BAABKgAFFH8GAAMKAAYIghMkGAD1AAAKAAUIfRYkGAD1AAAMAAEImQcAAAAAAAAAAA==.',['物十']='物十三:BAAAKgAECgUIBQAAAA==.物十二:BAAAKgADCggICAAAAA==.',['狗二']='狗二蛋:BAAAKgAECgYICgAAAA==.',['猩红']='猩红丶:BAABKgAFFH8GAAIWAAQIyBDcJQCAAAAWAAQIyBDcJQCAAAAAAA==.',['獵丨']='獵丨人:BAABKgAFFH8IAAIBAAgITAkqDQCHAQABAAgITAkqDQCHAQAAAA==.',['留连']='留连往返:BAAAKgAFFAEIAQAAAA==.',['皇啊']='皇啊玛:BAABKgAFFH8MAAIHAAYIqhnMEwB8AQAHAAYIqhnMEwB8AQAAAA==.',['直接']='直接美滋滋:BAAAKgADCgYIBgAAAA==.',['真的']='真的美滋滋:BAACKgAFFH8LAAIMAAMI6BE3DwDeAAAMAAMI6BE3DwDeAAAqAAQKfysAAwwACAiHIHwVABkCAAwACAgSHXwVABkCAAoAAQiPIW+CAF0AAAAA.',['神之']='神之影:BAAAKgAECgQICAAAAA==.',['神说']='神说喓有光:BAAAKgAECgQIBQAAAA==.',['私欲']='私欲:BAABKgAECn8gAAMFAAgIAR9mCwBsAgAFAAgIIR5mCwBsAgAGAAQIDB/AQgAOAQAAAA==.',['秋水']='秋水丶怡人:BAAAKgADCggICAAAAA==.',['空橙']='空橙记:BAAAKgAFFAgIAgAAAA==.',['筱筱']='筱筱酥:BAAAKgADCgUIBQAAAA==.',['简约']='简约而不简单:BAACKgAFFH8hAAMJAAUIeRNOEwDXAAAJAAUIeRNOEwDXAAAcAAMICAjdGwCcAAAqAAQKfxYAAwkABwhUFWRCAG0BAAkABgjnF2RCAG0BABwAAwiSDb9YAJgAAAAA.',['米拉']='米拉尔:BAAAKgAECgYIBgAAAA==.',['紅樓']='紅樓残夢:BAAAKgAFFAgIBAAAAA==.',['红的']='红的发黑:BAAAKgAECgYIBgAAAA==.',['绿色']='绿色小王子:BAABKgAECn8UAAIDAAgI/heUGQC9AQADAAgI/heUGQC9AQAAAA==.',['缀音']='缀音:BAABKgAFFH8GAAILAAYIchRsCgBZAQALAAYIchRsCgBZAQAAAA==.',['聖丨']='聖丨騎:BAABKgAFFH8kAAMPAAgIvBrdAQCGAQAOAAgIKRMpCwDwAQAPAAgIJxrdAQCGAQAAAA==.',['能坦']='能坦又能奶:BAAAKgAECgMIAwAAAA==.',['能奶']='能奶又能抗:BAAAKgAECggICAAAAA==.',['自走']='自走式电棍:BAAAKgAFFAQIBAAAAA==.',['舅妈']='舅妈:BAAAKgAECgUIBQAAAA==.',['良缘']='良缘:BAAAKgAECggICAAAAA==.',['艾丽']='艾丽丶:BAABKgAFFH8IAAIdAAQI4CR/CwBCAQAdAAQI4CR/CwBCAQABKgAFFAgIGAAVAOchAA==.',['芒刺']='芒刺木樨:BAAAKgAECgEIAQAAAA==.',['苏黎']='苏黎世的从前:BAAAKgAECggICAAAAA==.',['苯苯']='苯苯的领袖:BAACKgAFFH8IAAICAAYIKBtdAQDsAQACAAYIKBtdAQDsAQAqAAQKfxYAAwIACAgqHL4sAPoBAAIACAgqHL4sAPoBAAEABAhpHUYiAAUBAAEqAAUUCAgYAAwA6B4A.',['莫德']='莫德里奇:BAABKgAFFH8GAAIZAAMIJRB7DQDJAAAZAAMIJRB7DQDJAAAAAA==.',['莱杰']='莱杰罗:BAAAKgAFFAIIAgAAAA==.',['菊花']='菊花淡淡香:BAAAKgADCgQIBAAAAA==.',['菠菜']='菠菜焖红蹄:BAABKgAFFH8GAAITAAYIaiDgBADcAQATAAYIaiDgBADcAQAAAA==.',['萨丶']='萨丶:BAABKgAFFH8IAAIJAAQI2BsDEQDgAAAJAAQI2BsDEQDgAAAAAA==.',['萨满']='萨满小号:BAAAKgADCgEIAQAAAA==.',['蓉城']='蓉城晓喵:BAABKgAFFH8HAAIZAAUIHgehFQD9AAAZAAUIHgehFQD9AAAAAA==.',['蕾妮']='蕾妮拉:BAAAKgAFFAgIBAAAAA==.',['蕾姆']='蕾姆:BAAAKgADCgEIAQAAAA==.',['蛋疼']='蛋疼的旋律:BAAAKgAFFAIIAgAAAA==.',['蛋皇']='蛋皇派:BAACKgAFFH8IAAMXAAQIKRDABwDYAAAXAAQIKRDABwDYAAAPAAQINhKjHQCNAAAqAAQKfygAAxcACAgCIAwKAEoCABcACAgCIAwKAEoCAA4AAQjDGekcAUwAAAEqAAUUCAgJAA4AohgA.',['血色']='血色即永恒:BAAAKgAFFAIIAwAAAA==.',['讓兲']='讓兲使潑槑:BAABKgAFFH8KAAIOAAgIZgyhAwCXAQAOAAgIZgyhAwCXAQAAAA==.',['译雷']='译雷:BAAAKgAFFAMIAwAAAA==.',['赤色']='赤色圣射手:BAAAKgADCgMIAwAAAA==.',['跛豪']='跛豪:BAAAKgADCgEIAQAAAA==.',['蹦迪']='蹦迪治大病:BAAAKgAECgUIBQAAAA==.',['辰辰']='辰辰奶爸:BAAAKgADCgMIAwAAAA==.辰辰的牧妈:BAAAKgAFFAEIAQAAAA==.',['远山']='远山和叶:BAAAKgAFFAgIBAAAAA==.',['逍遥']='逍遥魔侠:BAAAKgAECggIEwAAAA==.',['逐静']='逐静丶:BAABKgAECn8YAAIQAAgI+iFDFwB6AgAQAAgI+iFDFwB6AgAAAA==.',['逐风']='逐风之翼:BAAAKgADCggICAAAAA==.',['遗忘']='遗忘冰河:BAAAKgAECgMIAwAAAA==.遗忘海角:BAAAKgAFFAYIAgAAAA==.',['部落']='部落猎殺者:BAABKgAFFH8HAAMBAAYINBmJCgBwAQABAAYIXxeJCgBwAQACAAEIkRY/LABNAAABKgAFFAgIAgANAAAAAA==.',['酒醉']='酒醉逍遥:BAAAKgAECgEIAQAAAA==.',['钟止']='钟止意难平:BAAAKgAFFAQIBAAAAA==.',['钟馗']='钟馗:BAAAKgADCggICAAAAA==.',['铁意']='铁意:BAAAKgADCgYIBgAAAA==.',['银师']='银师:BAAAKgAECgQIBAAAAA==.',['长耳']='长耳朵:BAAAKgADCgIIAgAAAA==.',['闪电']='闪电七连鞭:BAAAKgAECgIIAgAAAA==.',['阿斯']='阿斯特拉:BAAAKgAECgIIAgAAAA==.',['陈伯']='陈伯与梦姨:BAABKgAFFH8GAAIFAAYIyQlaDABIAQAFAAYIyQlaDABIAQAAAA==.',['陌丶']='陌丶域:BAAAKgAECgYIBgAAAA==.',['陌羽']='陌羽:BAAAKgAECggIEAAAAA==.',['雪炎']='雪炎瞑:BAABKgAFFH8GAAIeAAYIGglsDwAcAQAeAAYIGglsDwAcAQAAAA==.',['雯小']='雯小驿:BAAAKgAECgEIAQAAAA==.',['雾中']='雾中遗忘:BAACKgAFFH8RAAMZAAgIgBJSBgAgAgAZAAgIgBJSBgAgAgAfAAEIpQ9xBgBJAAAqAAQKfyUAAx8ACAgSIXYHANABAB8ACAimHnYHANABABkABQhRGwEcAIYBAAAA.',['霜火']='霜火法魔:BAAAKgADCgUIBQAAAA==.',['青岛']='青岛吴彦祖:BAAAKgAECgEIAQAAAA==.',['风中']='风中纸灰机:BAAAKgAECgUICgAAAA==.',['风之']='风之逆襲:BAABKgAFFH8IAAIWAAQIYwhrGQCJAAAWAAQIYwhrGQCJAAAAAA==.',['风清']='风清扬:BAABKgAFFH8GAAIDAAYIkQstEgAYAQADAAYIkQstEgAYAQAAAA==.',['风爆']='风爆小子:BAAAKgADCggICAAAAA==.',['风裂']='风裂:BAABKgAFFH8JAAMRAAgIZwmGKQDtAAARAAUI7QuGKQDtAAATAAQIzgtTGgDPAAAAAA==.',['飞的']='飞的黑快:BAAAKgAFFAYIBAAAAA==.',['骑丶']='骑丶:BAABKgAFFH8IAAQXAAYIPRI8CgAEAQAXAAUITA08CgAEAQAPAAIIlhC6DwCIAAAOAAEI2gNujwAyAAAAAA==.',['骑士']='骑士难搏万:BAAAKgAECgMIAwAAAA==.',['骑着']='骑着牛私奔:BAABKgAFFH8KAAMCAAYIxRfAEwBXAQACAAYIeBXAEwBXAQABAAIIXQ3MGACdAAAAAA==.',['鬼彻']='鬼彻:BAAAKgAFFAEIAQAAAA==.',['鬼瞳']='鬼瞳丨枫:BAAAKgAECggICQAAAA==.',['魂掉']='魂掉地上了:BAAAKgAECggIEAAAAA==.',['麒麟']='麒麟:BAABKgAFFH8NAAIJAAYI5R2jAADrAQAJAAYI5R2jAADrAQABKgAFFAgIBAANAAAAAA==.',['黑暗']='黑暗骑士:BAABKgAECn8WAAIHAAgIUxMUDQCrAQAHAAgIUxMUDQCrAQAAAA==.',['黑白']='黑白照片:BAAAKgADCgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end