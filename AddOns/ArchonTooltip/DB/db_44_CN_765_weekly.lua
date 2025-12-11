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
 local lookup = {'DemonHunter-Havoc','Shaman-Restoration','Hunter-BeastMastery','Warrior-Fury','Mage-Frost','Mage-Arcane','Paladin-Holy','Paladin-Retribution','Warrior-Protection','Priest-Holy','Monk-Brewmaster','Shaman-Elemental','Druid-Restoration','DeathKnight-Frost','Hunter-Marksmanship','Druid-Guardian','DeathKnight-Blood','Warrior-Melee',}; local provider = {region='CN',realm='瓦丝琪',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ap='Appo:BAABLAAFFH8XAAIBAAYIqx1xDADeAQABAAYIqx1xDADeAQAAAA==.',Ca='Cattyovo:BAAALAAECgQIBgAAAA==.Cayden:BAAALAAECgEIAQAAAA==.',Fo='Foever:BAAALAAECgIIAgAAAA==.Foeverlight:BAAALAAECgIIAgAAAA==.',La='Lash:BAAALAAECgYIBgAAAA==.',Lj='Ljhh:BAAALAAECgMIAwAAAA==.',Mu='Muxi:BAAALAAECgcICAAAAA==.',Ou='Outgo:BAAALAADCggIEAAAAA==.',Tb='Tbmm:BAAALAAECgQIBAAAAA==.',Yi='Yiggee:BAAALAAECgYIAQAAAA==.',['一瓶']='一瓶红牛:BAACLAAFFH8FAAICAAMIHQ7zQwCaAAACAAMIHQ7zQwCaAAAsAAQKfxYAAgIACAgDIPQHANgCAAIACAgDIPQHANgCAAAA.',['不朽']='不朽之王:BAAALAAFFAIIAgAAAA==.',['丨罪']='丨罪翁丨:BAAALAAECgUIBgAAAA==.',['丿唯']='丿唯美灬熙丶:BAAALAAECgYICAAAAA==.',['丿阿']='丿阿狸丶:BAAALAAECgYIBgAAAA==.',['俺头']='俺头上有犄角:BAAALAADCgEIAQAAAA==.',['养什']='养什么死什么:BAABLAAFFH8KAAIDAAIIMAQvtAA0AAADAAIIMAQvtAA0AAAAAA==.',['冰霜']='冰霜女巫:BAAALAAECgEIAQAAAA==.',['冷傲']='冷傲孤狂:BAABLAAFFH8GAAIEAAYI6A18IABoAQAEAAYI6A18IABoAQAAAA==.',['劈头']='劈头士帅牛:BAAALAAECgYIEwAAAA==.',['北城']='北城春秋:BAAALAADCgYIBgAAAA==.',['半醉']='半醉人间:BAACLAAFFH8HAAMFAAIIpRK8FACEAAAFAAIIpRK8FACEAAAGAAIIXwfqZQA1AAAsAAQKfyQAAwUACAjbHP0JAB0CAAUACAjEG/0JAB0CAAYABQiMFsE/AA0BAAAA.',['卡斯']='卡斯特:BAAALAADCgUIBQAAAA==.',['命运']='命运的制裁:BAAALAAFFAIIAgAAAA==.',['哥白']='哥白尼:BAAALAADCgEIAQAAAA==.',['圣光']='圣光之锤:BAAALAAECgYIBgAAAA==.圣光忽悠悠:BAABLAAFFH8GAAMHAAYIqwKOGgDfAAAHAAUI5gKOGgDfAAAIAAEIpADHhAAYAAAAAA==.',['堕落']='堕落嘚骷髅:BAAALAAECgQIBAAAAA==.',['塔乃']='塔乃乃德:BAAALAAECgYICAAAAA==.',['大帅']='大帅背后女人:BAAALAAECgUIBQAAAA==.',['太刀']='太刀川美美:BAAALAADCgMIAwAAAA==.',['奔跑']='奔跑的芭乐葡:BAAALAAECgUIBwAAAA==.',['奥拉']='奥拉:BAAALAAECgYIEAAAAA==.',['奥莱']='奥莱丽娅:BAAALAAFFAIIAgAAAA==.',['女妖']='女妖之王:BAAALAAECgMIAwAAAA==.',['妖妖']='妖妖:BAAALAAECgYICwAAAA==.',['妞妞']='妞妞的一天:BAAALAAFFAIIAgAAAA==.',['嫩豆']='嫩豆腐迷糊了:BAAALAAECgIIAgAAAA==.',['孤丶']='孤丶城:BAABLAAFFH8JAAIJAAMIdQzUIQBrAAAJAAMIdQzUIQBrAAAAAA==.',['学穿']='学穿搭:BAAALAAFFAIIAgAAAA==.',['小猪']='小猪跑得快:BAAALAAECgUIBgAAAA==.小猪配恩:BAAALAAECgMIAwAAAA==.',['小珍']='小珍珠:BAAALAAFFAIIBAAAAA==.',['小痴']='小痴躲猫猫:BAAALAADCgIIAgAAAA==.',['开祷']='开祷:BAAALAAECgEIAQAAAA==.',['张三']='张三秒:BAABLAAECn8UAAIBAAYIUSLpRQBQAgABAAYIUSLpRQBQAgAAAA==.',['张妙']='张妙妙:BAABLAAECn8UAAIDAAYIqx8GXQAiAgADAAYIqx8GXQAiAgAAAA==.',['弦歌']='弦歌枕月:BAAALAAECgUICwAAAA==.',['性高']='性高采猎:BAAALAAECgYICwAAAA==.',['怪叁']='怪叁叔:BAAALAAECgIIAgAAAA==.',['怪骑']='怪骑骑:BAAALAAECgIIAgAAAA==.',['恶龙']='恶龙吐奶:BAABLAAFFH8JAAIKAAIISwloQwBkAAAKAAIISwloQwBkAAAAAA==.',['我先']='我先你后退:BAABLAAFFH8IAAIJAAIIugP1NgAqAAAJAAIIugP1NgAqAAAAAA==.',['打啦']='打啦不鞥:BAAALAADCgYIBgAAAA==.',['放开']='放开那根竹子:BAABLAAFFH8GAAILAAIIvgR8HQBPAAALAAIIvgR8HQBPAAAAAA==.',['放弃']='放弃治疗速死:BAABLAAFFH8KAAMCAAIIVg+MWgBmAAACAAIIVg+MWgBmAAAMAAIIQwJAVQAdAAAAAA==.',['放纵']='放纵丶爱情:BAAALAAECgcIBwAAAA==.',['斧刃']='斧刃:BAABLAAFFH8mAAINAAYIlw8WGQBmAQANAAYIlw8WGQBmAQAAAA==.',['旋转']='旋转跳跃:BAAALAAECggIDQAAAA==.',['无心']='无心的大航海:BAABLAAFFH8JAAIEAAUI7QDgTQBrAAAEAAUI7QDgTQBrAAAAAA==.无心的航海:BAAALAAFFAYIBAABLAAFFAgICgAOAIMBAA==.',['无粒']='无粒丹:BAACLAAFFH8OAAIBAAUIbB/MHgCHAQABAAUIbB/MHgCHAQAsAAQKfyEAAgEACAjVJUwDAP0CAAEACAjVJUwDAP0CAAAA.',['晚安']='晚安:BAAALAAECgQIBQAAAA==.',['晴天']='晴天霹雳:BAAALAAFFAIIAgAAAA==.',['月桂']='月桂树:BAAALAAECgUIBQAAAA==.',['杨过']='杨过:BAABLAAFFH8KAAIOAAYI1ApgPgBBAQAOAAYI1ApgPgBBAQAAAA==.',['林软']='林软软:BAAALAAECgYIBwAAAA==.',['欧皇']='欧皇:BAAALAAECgUIBQAAAA==.',['氵昆']='氵昆血儿灬:BAAALAAFFAIIAwAAAA==.',['沧渊']='沧渊:BAAALAAECgQIBwAAAA==.',['泷泽']='泷泽灬烈酒:BAAALAAECgYIBgAAAA==.',['海拉']='海拉:BAAALAAECgYIDgAAAA==.',['淡君']='淡君忘:BAAALAADCgYIBgAAAA==.',['潇潇']='潇潇:BAAALAAECgYIBgAAAA==.',['灬阿']='灬阿狸丶:BAAALAAECgYIBgAAAA==.',['灵芝']='灵芝茶:BAAALAAFFAIIAgAAAA==.',['熊猫']='熊猫丶男爵:BAABLAAFFH8FAAIJAAUIIQ1OGADkAAAJAAUIIQ1OGADkAAAAAA==.',['爱情']='爱情限时批:BAAALAAECgYICwAAAA==.',['王者']='王者的叹息:BAABLAAFFH8lAAIJAAYIthNFDAADAQAJAAYIthNFDAADAQAAAA==.',['玛卡']='玛卡巴卡卜:BAAALAAFFAIIBAAAAA==.',['珍丶']='珍丶珠:BAABLAAFFH8ZAAMDAAYIBBaQMgBwAQADAAYIBBaQMgBwAQAPAAEIVxBlNQA/AAAAAA==.',['疯狂']='疯狂牛牛:BAAALAAECgUIBwAAAA==.',['白银']='白银之爹:BAAALAAFFAIIBAAAAA==.',['碱水']='碱水丨魔芋爽:BAAALAAECgUICgAAAA==.',['祐天']='祐天寺若麦:BAAALAAECgYICQAAAA==.',['空城']='空城灬旧梦:BAAALAAECgYIBgAAAA==.',['紫凝']='紫凝仙子:BAAALAAECgYIBgAAAA==.',['罗三']='罗三岁:BAAALAADCggICAAAAA==.',['罪翁']='罪翁:BAAALAAECgYIBgAAAA==.',['美少']='美少女丶壮士:BAABLAAFFH8MAAIHAAII8QvsJwBsAAAHAAII8QvsJwBsAAAAAA==.',['老李']='老李七号:BAABLAAFFH8XAAIKAAYIng3nGgB3AQAKAAYIng3nGgB3AQAAAA==.老李五号:BAABLAAFFH8TAAMHAAYItQrnEgBcAQAHAAYItQrnEgBcAQAIAAUIHAVDNwDGAAAAAA==.老李六号:BAACLAAFFH8rAAMCAAYIDw9QIgBLAQACAAYIDw9QIgBLAQAMAAUIUQS8LQDKAAAsAAQKfxYAAgIABwh3GNZZANgBAAIABwh3GNZZANgBAAAA.',['肉山']='肉山大馍馍:BAAALAAFFAIIAwAAAA==.肉山小馍馍:BAABLAAFFH8KAAIQAAIIiBI/DQAwAAAQAAIIiBI/DQAwAAAAAA==.',['胡子']='胡子有点长:BAAALAAECgYIDwAAAA==.',['自由']='自由:BAABLAAFFH8GAAIRAAYIxQ7bDAA8AQARAAYIxQ7bDAA8AQAAAA==.',['致命']='致命伤痕之晓:BAAALAAECgYIBgAAAA==.',['艾微']='艾微恩丶上士:BAABLAAFFH8FAAIJAAUI0g8LHwCCAAAJAAUI0g8LHwCCAAAAAA==.艾微恩丶上校:BAABLAAFFH8FAAIJAAUIuRwoEABMAQAJAAUIuRwoEABMAQAAAA==.艾微恩丶中士:BAABLAAFFH8SAAIJAAYIWxiWDQBrAQAJAAYIWxiWDQBrAQAAAA==.艾微恩丶中校:BAABLAAFFH8NAAIJAAYIXxXrDwBOAQAJAAYIXxXrDwBOAQAAAA==.艾微恩丶准尉:BAABLAAFFH8FAAISAAUIEhQAAAAAAAAJAAUIEhQAAAAAAAAAAA==.艾微恩丶大校:BAABLAAFFH8MAAIJAAYIeRi/DQBpAQAJAAYIeRi/DQBpAQAAAA==.艾微恩丶少校:BAABLAAFFH8FAAIJAAUI0hLlFgD5AAAJAAUI0hLlFgD5AAAAAA==.',['若即']='若即灬那回忆:BAAALAAECgUIBQAAAA==.',['落丶']='落丶星:BAAALAAFFAIIBAAAAA==.',['蓋爾']='蓋爾加朵花花:BAAALAAECgYICgAAAA==.',['蔚蓝']='蔚蓝决斗:BAABLAAFFH8aAAMDAAYIniJALwB6AQADAAUI9SBALwB6AQAPAAMIgSJ7FADDAAAAAA==.蔚蓝葬月:BAABLAAFFH8HAAIOAAMI0w4TYwCGAAAOAAMI0w4TYwCGAAAAAA==.',['蛋刀']='蛋刀在哪里:BAAALAAFFAIIAgAAAA==.',['血泪']='血泪悲伤:BAAALAAFFAIIAgAAAA==.',['西滩']='西滩坪关羽:BAABLAAECn8aAAIOAAcIIxQxowDCAQAOAAcIIxQxowDCAQAAAA==.',['越夜']='越夜时光:BAAALAAFFAQIBAAAAA==.',['轻夜']='轻夜:BAAALAAECgIIAgAAAA==.',['钢铁']='钢铁馒头:BAAALAAECgEIAQAAAA==.',['防战']='防战十一号:BAAALAAFFAMIAwAAAA==.防战十二号:BAABLAAFFH8GAAIJAAYIsg+KEwAmAQAJAAYIsg+KEwAmAQAAAA==.防战十四号:BAABLAAFFH8GAAIJAAYITxDJFAAWAQAJAAYITxDJFAAWAQAAAA==.',['阿吉']='阿吉娜:BAAALAADCgcIBwAAAA==.',['阿狸']='阿狸灬信燕:BAAALAAECgYICAAAAA==.',['阿里']='阿里阿李:BAACLAAFFH8IAAMFAAIItRLiEwCGAAAFAAIItRLiEwCGAAAGAAEIUAMWbwA1AAAsAAQKfyQAAwUACAg6HSsIAEQCAAUACAg6HSsIAEQCAAYABgi9E2xBAAYBAAAA.',['雪纳']='雪纳瑞:BAAALAADCgYICQAAAA==.',['飙车']='飙车男:BAAALAAFFAIIBAAAAA==.',['黑之']='黑之契约者:BAAALAAECgUICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end