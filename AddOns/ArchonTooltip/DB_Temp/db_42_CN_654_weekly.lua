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
 local lookup = {'Druid-Restoration','Druid-Balance','Hunter-Marksmanship','Mage-Frost','Unknown-Unknown','Shaman-Restoration','Warlock-Destruction','Warlock-Demonology','Hunter-BeastMastery','Paladin-Retribution','Warrior-Fury','DeathKnight-Unholy','DeathKnight-Blood','DemonHunter-Havoc','Druid-Guardian','DeathKnight-Frost','Warrior-Arms','Monk-Windwalker','Paladin-Protection','Rogue-Assassination','Mage-Fire','Mage-Arcane','Paladin-Holy','Rogue-Outlaw','Warrior-Protection','DemonHunter-Vengeance','Priest-Holy','Priest-Discipline','Priest-Shadow','Shaman-Enhancement','Shaman-Elemental',}; local provider = {region='CN',realm='安纳塞隆',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ba='Banshee:BAACKgAFFH8/AAMBAAgIwxlBAgBRAgABAAgIwxlBAgBRAgACAAMIhA6bSgCIAAAqAAQKfy8AAwEACAhbInoGAKACAAEACAhbInoGAKACAAIACAj+DQ9RAHMBAAAA.',Da='Darkkiss:BAAAKgAECggIDAABKgAECggIKgADAAciAA==.',Di='Dissipate:BAAAKgAECgYIBgAAAA==.',Du='Dudgeonm:BAABKgAFFH8GAAIEAAQI8h2FBwDyAAAEAAQI8h2FBwDyAAAAAA==.',Gr='Gravityy:BAAAKgAFFAQIBAAAAA==.',Hu='Huidada:BAAAKgADCggICAAAAA==.',Iv='Ivory:BAAAKgAFFAgIAgAAAA==.',Ma='Mapple:BAAAKgADCgIIAgAAAA==.',Mi='Mii:BAAAKgADCgEIAQAAAA==.',Ob='Oblivions:BAAAKgAFFAQIBAABKgAFFAgIBAAFAAAAAA==.',Re='Regina:BAAAKgAFFAMIAwAAAA==.',Sd='Sdfvc:BAAAKgADCggICAAAAA==.',Ti='Titanx:BAAAKgAECgUIBQAAAA==.',Ve='Veronica:BAABKgAFFH8IAAIGAAgICBDTBgDeAQAGAAgICBDTBgDeAQAAAA==.',Xi='Xiaoxyz:BAABKgAFFH8GAAMHAAMIZwiKHACdAAAHAAMIZwiKHACdAAAIAAEI+AaAGQAvAAAAAA==.',['一如']='一如故一:BAAAKgAFFAYIBAAAAA==.',['不呆']='不呆不傻还萌:BAAAKgADCgYIBgAAAA==.',['不川']='不川苦茶子:BAACKgAFFH8bAAMJAAYIhhdxFABSAQAJAAUI4hpxFABSAQADAAQIixbRKADHAAAqAAQKfyIAAwkACAhNIc0wADECAAkACAigHs0wADECAAMABwh2G0EuAKkBAAAA.',['丨冰']='丨冰噸噸丨:BAAAKgAECgQIBAAAAA==.',['丨变']='丨变形灬徳:BAAAKgADCggICAAAAA==.',['丨影']='丨影牛之主丨:BAAAKgADCggICAAAAA==.',['丶加']='丶加尔鲁什:BAAAKgADCggICAAAAA==.',['丷西']='丷西红柿丷:BAAAKgAECggICAAAAA==.',['丿灬']='丿灬默默:BAAAKgADCggICAAAAA==.',['乌龟']='乌龟的黑头:BAAAKgAFFAEIAgAAAA==.',['二手']='二手玫瑰:BAAAKgAFFAYIAQABKgAFFAgICAAKAC8jAA==.',['井阵']='井阵:BAACKgAFFH8XAAILAAQIwRg+EAD5AAALAAQIwRg+EAD5AAAqAAQKfxcAAgsACAhbHcoZAAMCAAsACAhbHcoZAAMCAAAA.',['亲爱']='亲爱的老公:BAAAKgADCgEIAQAAAA==.亲爱的老龚:BAAAKgADCgEIAQAAAA==.',['今年']='今年我十八:BAABKgAFFH8VAAMMAAgISSMXAQDnAgAMAAgISSMXAQDnAgANAAYIDhGVEQAWAQAAAA==.',['从前']='从前从前:BAAAKgADCggICAAAAA==.',['伊丨']='伊丨利灬丹:BAABKgAFFH8MAAIOAAQI0yJlHgAQAQAOAAQI0yJlHgAQAQAAAA==.',['伊諾']='伊諾:BAAAKgAECgcICQAAAA==.',['众乐']='众乐乐:BAAAKgAECgcIBwAAAA==.',['你妹']='你妹:BAABKgAFFH8IAAIDAAgIyRlGBQAlAgADAAgIyRlGBQAlAgAAAA==.',['侧田']='侧田的春袋:BAAAKgAECgUIBQAAAA==.',['六袋']='六袋长老:BAAAKgAECggICwAAAA==.',['内个']='内个谁丶:BAAAKgADCgQIBAAAAA==.',['冬至']='冬至丶戦:BAAAKgAECgIIAgAAAA==.',['冰埄']='冰埄灬牛奶:BAAAKgADCgUIBQAAAA==.',['冰封']='冰封牛奶:BAACKgAFFH8qAAMBAAQI+xmGCwDUAAABAAQI+xmGCwDUAAACAAQIEgxaOwC4AAAqAAQKf2kABAEACAinISkOAFwCAAEACAinISkOAFwCAAIACAhzEztYAFMBAA8ABQj4GTwWAPkAAAAA.',['则卷']='则卷小雨:BAAAKgADCgEIAQAAAA==.',['初心']='初心不改:BAAAKgAECgEIAQAAAA==.',['别问']='别问我为啥:BAAAKgAECgcIBwAAAA==.',['到得']='到得听能妳只:BAAAKgADCggICgAAAA==.',['北灬']='北灬牧:BAAAKgAECgcIBwAAAA==.北灬珩:BAAAKgAECgUIBQAAAA==.北灬野:BAAAKgAECgUIAwAAAA==.',['十一']='十一:BAAAKgAECgMIAwAAAA==.',['半岛']='半岛铁盒:BAAAKgADCggICAAAAA==.',['口圭']='口圭口合口合:BAAAKgAECgEIAQAAAA==.',['叶舞']='叶舞风踪:BAAAKgADCgUIBQAAAA==.',['呆呆']='呆呆的你:BAAAKgAFFAQIBAAAAA==.',['哈利']='哈利撸呀:BAAAKgAECgcIEQAAAA==.',['哈尼']='哈尼之祖:BAAAKgAECgcIBwAAAA==.',['嘻嘻']='嘻嘻路路:BAABKgAFFH8IAAIEAAgIShFjFABMAAAEAAgIShFjFABMAAAAAA==.',['圣灬']='圣灬骑灬士:BAAAKgAECgcICwAAAA==.',['地精']='地精王大胆:BAAAKgADCggICAAAAA==.',['夜天']='夜天子:BAABKgAFFH8JAAMQAAMIPRsgBwD5AAAQAAMIPRsgBwD5AAAMAAMIZAh7PACsAAAAAA==.',['大柒']='大柒罗宾逊:BAAAKgAECgIIAwAAAA==.',['大漠']='大漠:BAAAKgAECggIDQAAAA==.',['大粗']='大粗牛:BAABKgAFFH8IAAIBAAMIdQwCEQCOAAABAAMIdQwCEQCOAAAAAA==.',['天南']='天南丶小生:BAAAKgAFFAYIAQAAAA==.',['天地']='天地之灵:BAAAKgADCggICAAAAA==.',['如意']='如意算盘:BAAAKgADCgEIAQAAAA==.',['婷婷']='婷婷香婷:BAABKgAFFH8GAAIOAAYIWxvIDQCmAQAOAAYIWxvIDQCmAQAAAA==.',['嫂子']='嫂子请抱紧沃:BAACKgAFFH8aAAMLAAUIQRAgEwDsAAALAAUInA8gEwDsAAARAAMIHA4cDADOAAAqAAQKfxcAAwsACAijGKslAPkBAAsACAijGKslAPkBABEAAQgAAOxyAAAAAAAA.',['孔雀']='孔雀翎:BAAAKgAECgEIAQAAAA==.',['孤星']='孤星之泪:BAABKgAFFH8KAAMHAAYIMxOpIAACAQAHAAUIDhSpIAACAQAIAAEIyA8UKgBGAAAAAA==.',['安纳']='安纳酷贼:BAAAKgAECggICAAAAA==.',['小尖']='小尖椒炒土豆:BAAAKgAECggICAAAAA==.',['小猪']='小猪失恋了丶:BAAAKgAECgEIAQAAAA==.',['小猴']='小猴子杂货铺:BAAAKgAECgYIBgAAAA==.',['小美']='小美牛牛:BAAAKgAFFAQIBAAAAA==.',['尐狐']='尐狐狸:BAAAKgAECgEIAQAAAA==.',['尐胖']='尐胖虎:BAABKgAFFH8IAAIMAAgIsAVRDQC8AQAMAAgIsAVRDQC8AQAAAA==.',['尼克']='尼克胡尼克:BAAAKgAECgEIAQAAAA==.',['工友']='工友夸我够烧:BAAAKgADCggICAAAAA==.工友夸我够猛:BAABKgAFFH8GAAIMAAMIHAnAOQC1AAAMAAMIHAnAOQC1AAAAAA==.工友夸我奇大:BAAAKgAFFAMIAwAAAA==.工友夸我奇烧:BAAAKgAECggICAAAAA==.工友夸我奇猛:BAAAKgADCggICAAAAA==.工友夸我好吊:BAAAKgADCgYIBgAAAA==.工友夸我巨大:BAAAKgAFFAMIAwAAAA==.工友夸我巨烧:BAAAKgADCgEIAQAAAA==.工友夸我忒烧:BAAAKgAECgYIBgAAAA==.工友夸我挺烧:BAAAKgAFFAMIAwAAAA==.工友夸我挺猛:BAAAKgAECgQIBAAAAA==.工友夸我极烧:BAAAKgAECgEIAQAAAA==.工友夸我极猛:BAAAKgAECgUIBAAAAA==.工友夸我特烧:BAAAKgAECgMIAwAAAA==.工友夸我特猛:BAAAKgAECgUIBQAAAA==.工友夸我特硬:BAAAKgAFFAMIAwAAAA==.工友夸我真大:BAAAKgAFFAMIAwAAAA==.工友夸我真强:BAAAKgAFFAMIAwAAAA==.工友夸我真棒:BAAAKgAECgYIBwAAAA==.工友夸我真烧:BAAAKgAECgYIBgAAAA==.工友夸我真猛:BAAAKgAECggIDwAAAA==.工友夸我真硬:BAAAKgAECgYIBgAAAA==.工友夸我能喷:BAAAKgADCggICAAAAA==.工友夸我能射:BAAAKgAECgEIAQAAAA==.工友夸我贼烧:BAAAKgADCgEIAQAAAA==.工友夸我超烧:BAAAKgAECgcIEgAAAA==.',['布丁']='布丁拽:BAAAKgADCgEIAQAAAA==.',['帅就']='帅就一个字:BAAAKgAECgYIBwAAAA==.',['帅气']='帅气的石头人:BAAAKgAECgQIBAAAAA==.',['帅电']='帅电工:BAAAKgAFFAYIBAAAAA==.',['希尔']='希尔丨瓦娜斯:BAABKgAFFH8IAAIJAAQIQx9OJgDtAAAJAAQIQx9OJgDtAAAAAA==.',['帽子']='帽子戏法:BAAAKgADCgUIBQAAAA==.',['张三']='张三丶:BAAAKgAECgQIBAAAAA==.',['张翼']='张翼德:BAAAKgADCggICAAAAA==.',['归零']='归零者:BAAAKgADCggICwAAAA==.',['很萌']='很萌的茶壶:BAAAKgADCgQIBAAAAA==.',['恒刀']='恒刀立马:BAAAKgAECgUICQAAAA==.',['惊艳']='惊艳绝刀:BAAAKgADCgIIAgAAAA==.',['懒宝']='懒宝:BAAAKgAFFAIIAgAAAA==.',['我不']='我不会治疗:BAAAKgAECgQIBAAAAA==.我不是惩戒:BAAAKgAFFAQIBAAAAA==.我不是骑士真:BAAAKgAECgYIBgAAAA==.',['我也']='我也没有办法:BAACKgAFFH8MAAIKAAMIQh4oJADXAAAKAAMIQh4oJADXAAAqAAQKfxgAAgoACAjsHk03ACICAAoACAjsHk03ACICAAAA.',['我们']='我们校风很大:BAAAKgAFFAQIAgABKgAFFAgIDgASANAQAA==.',['我依']='我依旧是传奇:BAAAKgADCggIGAAAAA==.',['我犯']='我犯了坚强罪:BAAAKgADCgEIAQAAAA==.',['战灬']='战灬士:BAABKgAFFH8OAAILAAQI8iW5CQAYAQALAAQI8iW5CQAYAQABKgAFFAgICAALAHYKAA==.',['戰丨']='戰丨钰:BAABKgAFFH8GAAITAAYInBBtEAAAAQATAAYInBBtEAAAAQAAAA==.',['托米']='托米尼恩斯:BAAAKgAFFAMIAwAAAA==.',['抗战']='抗战二十年:BAAAKgAECgEIAQAAAA==.',['拒绝']='拒绝内耗:BAAAKgAECgIIAgAAAA==.',['挥手']='挥手阳光:BAAAKgADCggICAAAAA==.',['捕猎']='捕猎夏天:BAAAKgAECgcIBwAAAA==.',['数据']='数据结构基础:BAABKgAFFH8IAAIUAAgIswmiBwD3AQAUAAgIswmiBwD3AQAAAA==.',['昊丶']='昊丶坤尔加丹:BAAAKgAFFAgIBAAAAA==.',['暗影']='暗影追猎:BAAAKgAECggICAAAAA==.',['暗淡']='暗淡星辰:BAABKgAFFH8GAAIVAAYINwpnHwC5AAAVAAYINwpnHwC5AAABKgAFFAgIGAAWAOchAA==.',['最初']='最初的大魔王:BAAAKgAECgMIAwAAAA==.',['最後']='最後的戰役:BAAAKgAECgIIAgAAAA==.',['月光']='月光爷爷:BAAAKgAECgIIAgAAAA==.',['李小']='李小龙:BAAAKgADCgcIBwAAAA==.',['林志']='林志玲丶:BAAAKgAECgMIAgAAAA==.',['枫北']='枫北彳来的晚:BAAAKgAECgYIBgAAAA==.',['梦回']='梦回唐朝:BAAAKgADCgIIAgAAAA==.',['槽方']='槽方芳:BAAAKgAFFAYIBAAAAA==.',['槽芳']='槽芳芳:BAAAKgAFFAQIBAABKgAFFAgIDAAOADUhAA==.',['樱花']='樱花飘零坠:BAABKgAFFH8GAAIKAAYIDw9TFABZAQAKAAYIDw9TFABZAQAAAA==.',['橙色']='橙色丶圣光:BAACKgAFFH8KAAIKAAYIQB2KEgDIAQAKAAYIQB2KEgDIAQAqAAQKfxYAAxcACAitGRIVAMkBABcACAitGRIVAMkBAAoACAjzE6mBAJQBAAEqAAUUCAgSAAYATiIA.橙色丶风暴:BAABKgAFFH8HAAMJAAYIuhlEBgBgAQAJAAUIwxdEBgBgAQADAAIIbB2HHACJAAABKgAFFAgIBAAFAAAAAA==.',['歹匕']='歹匕尸:BAABKgAFFH8FAAIYAAII7CIjBQDJAAAYAAII7CIjBQDJAAAAAA==.',['死亡']='死亡丶华尔玆:BAABKgAFFH8IAAIKAAgIfAkWDgDBAQAKAAgIfAkWDgDBAQAAAA==.',['段延']='段延庆:BAAAKgAECgcIDgAAAA==.',['比克']='比克:BAABKgAECn8zAAMJAAgI8xsnDgA0AgAJAAgI8xsnDgA0AgADAAII0BMbNwB7AAAAAA==.',['沅芳']='沅芳:BAAAKgAFFAIIAgAAAA==.',['治不']='治不疗你:BAAAKgADCgUIBQAAAA==.',['泼墨']='泼墨:BAAAKgAECgMIAwAAAA==.',['海盗']='海盗:BAACKgAFFH8PAAMEAAQI/BRNFgC9AAAEAAQI/BRNFgC9AAAWAAEIxwkhRwA2AAAqAAQKfx4ABAQACAjyGYwjAPcBAAQACAjBGYwjAPcBABUABAjmD5pkAOAAABYAAghNFG14AHoAAAAA.海盗号角:BAACKgAFFH8WAAIKAAMInyFjFgAAAQAKAAMInyFjFgAAAQAqAAQKfyIAAgoABwhyJCs2AE0CAAoABwhyJCs2AE0CAAAA.',['海鲜']='海鲜:BAABKgAECn8qAAMDAAgIByIyHgAMAgADAAcIhx8yHgAMAgAJAAQIvBcufwDbAAAAAA==.',['清平']='清平调:BAAAKgAECggICAAAAA==.',['灬允']='灬允:BAAAKgAECgIIAgAAAA==.',['灬熠']='灬熠卓丶周:BAAAKgADCgcIBwAAAA==.',['灰烬']='灰烬中重生:BAAAKgAFFAgIAgAAAA==.',['灾难']='灾难犭时钟:BAABKgAFFH8MAAMLAAYISBzBCwCPAQALAAYI2xjBCwCPAQAZAAYIzBLxBQAXAQABKgAFFAgIAgAFAAAAAA==.',['烟司']='烟司:BAAAKgADCggICAAAAA==.',['烟灰']='烟灰:BAABKgAFFH8IAAMHAAYIOxMoGABCAQAHAAYIOxMoGABCAQAIAAEIKAUDLwA8AAABKgAFFAgIHAACADYlAA==.',['爱为']='爱为伊生:BAAAKgAECgMIAwAAAA==.',['爱吃']='爱吃豌杂面:BAAAKgAFFAEIAQAAAA==.',['牛伟']='牛伟雄:BAAAKgADCgIIAgAAAA==.',['牛小']='牛小骚:BAAAKgAECgQIBgAAAA==.',['牛牛']='牛牛战斗斗:BAABKgAECn8aAAMLAAgIiBySFQApAgALAAgI3xuSFQApAgARAAgIChWmGwCoAQAAAA==.',['牛马']='牛马无常:BAABKgAFFH8IAAMOAAMIng+lLADIAAAOAAMIng+lLADIAAAaAAIIbwg0IABgAAAAAA==.',['猎鲨']='猎鲨丶:BAAAKgAECgMIAwAAAA==.',['猛将']='猛将兄丶:BAAAKgAECggICQAAAA==.',['玉术']='玉术临风丷:BAABKgAFFH8IAAIHAAQIixjoEADiAAAHAAQIixjoEADiAAAAAA==.',['白魔']='白魔王灬丨:BAAAKgAFFAgIBAAAAA==.',['皮蛋']='皮蛋豆腐:BAABKgAFFH8RAAISAAMIxRZbDwC7AAASAAMIxRZbDwC7AAAAAA==.',['眼细']='眼细春袋大:BAAAKgAECggICwAAAA==.',['瞎狐']='瞎狐撸:BAABKgAFFH8IAAIEAAMIoRb6EADaAAAEAAMIoRb6EADaAAAAAA==.',['磯风']='磯风:BAAAKgAFFAgIBAAAAA==.',['神恩']='神恩结界:BAABKgAFFH8IAAIUAAQIAAA/KwAAAAAUAAQIAAA/KwAAAAAAAA==.',['神翔']='神翔:BAABKgAFFH8IAAIHAAgI6w0NBwD5AQAHAAgI6w0NBwD5AQAAAA==.',['笑天']='笑天随风:BAABKgAFFH8KAAIGAAYI+hGFDgBoAQAGAAYI+hGFDgBoAQAAAA==.',['筱筱']='筱筱弓:BAAAKgAECgIIAgAAAA==.',['米蘭']='米蘭国际:BAAAKgAECggIEgAAAA==.',['精神']='精神晓伙:BAAAKgADCgMIAwAAAA==.',['紫晴']='紫晴彩虹:BAAAKgADCgEIAQAAAA==.',['红黑']='红黑禁穿:BAAAKgAECgYIBwAAAA==.',['纤纤']='纤纤青丝:BAABKgAFFH8MAAQbAAYIbhIoDQD4AAAbAAYIWAsoDQD4AAAcAAQIERcmFwDZAAAdAAIIIxNqIACIAAAAAA==.',['纳兹']='纳兹多拉格尼:BAABKgAFFH8SAAMWAAYIKBZjEwBJAQAWAAYI/RNjEwBJAQAVAAYIGgrsEQAyAQAAAA==.',['绯红']='绯红帝痞:BAABKgAFFH8RAAIHAAgI/wuCDACAAQAHAAgI/wuCDACAAQAAAA==.',['缩骨']='缩骨揼柒:BAAAKgAECgUICgAAAA==.',['缺人']='缺人疼灬:BAAAKgAECgQIBAAAAA==.',['耍双']='耍双刀的熊猫:BAAAKgAECggIDwAAAA==.',['聖丶']='聖丶龍:BAAAKgAFFAYIAwAAAA==.',['胸肌']='胸肌沦落为奶:BAABKgAFFH8IAAMdAAgIGhPmBQDSAQAdAAcIphXmBQDSAQAbAAEIfBUUPQBIAAAAAA==.',['臣卜']='臣卜一木曹:BAAAKgAECggICAAAAA==.',['自由']='自由自在:BAAAKgAECggIDgAAAA==.',['艺高']='艺高人蛋大:BAAAKgAECgEIAQAAAA==.',['艾萝']='艾萝娜:BAAAKgADCgIIAgAAAA==.',['花腿']='花腿鲤鱼:BAABKgAFFH8MAAIQAAgIvRZOAQA5AgAQAAgIvRZOAQA5AgAAAA==.',['茶靡']='茶靡夜岚:BAAAKgADCggICAAAAA==.',['萧婉']='萧婉晴:BAAAKgAECgEIAQAAAA==.',['落坨']='落坨翔子:BAACKgAFFH8MAAMeAAMIPRWCDgDnAAAeAAMIPRWCDgDnAAAfAAMIjgoWGgCqAAAqAAQKfx8AAx4ACAgmG+EPAPgBAB4ACAilF+EPAPgBAB8ABwigFzgqAIYBAAAA.',['落婲']='落婲丶无痕:BAAAKgAECggICAAAAA==.',['落花']='落花聼雨:BAAAKgAECggIDgAAAA==.',['蓝羽']='蓝羽:BAABKgAFFH8KAAINAAQIQCarAwBWAQANAAQIQCarAwBWAQABKgAFFAgIGgAMAEwhAA==.',['蟑螂']='蟑螂小霸:BAABKgAFFH8IAAIGAAgIswjDCQBtAQAGAAgIswjDCQBtAQAAAA==.',['蠺丨']='蠺丨殇徳:BAAAKgAECgIIAgAAAA==.',['让子']='让子弹飞一会:BAAAKgAECgYICAAAAA==.',['话多']='话多五:BAAAKgAFFAQIBAAAAA==.话多六:BAAAKgAECgQIBAAAAA==.',['超爱']='超爱雪碧:BAAAKgADCgYIBgAAAA==.',['跑着']='跑着不累:BAAAKgADCggIDAAAAA==.',['踏碎']='踏碎凌霄:BAAAKgAFFAIIAgAAAA==.',['身高']='身高就任性:BAAAKgADCggICAAAAA==.',['轩霰']='轩霰玄新:BAAAKgAECgcIBwAAAA==.',['逍遥']='逍遥一梦:BAAAKgAFFAQIBAABKgAFFAgIDwAbAOgSAA==.逍遥弑神:BAAAKgADCggIEQAAAA==.',['醉酒']='醉酒当歌丶:BAAAKgADCgMIAwAAAA==.',['野蛮']='野蛮小歪:BAAAKgAECgMIAwAAAA==.',['钻石']='钻石巧克力:BAABKgAFFH8jAAQZAAgIZxiOAwB6AQALAAgIlBTFBQA2AgAZAAgItRSOAwB6AQARAAYI7A74CgBeAQAAAA==.',['锁天']='锁天:BAACKgAFFH8UAAIJAAMIXRx3GgDpAAAJAAMIXRx3GgDpAAAqAAQKfyAAAwMACAiyICoIAFoCAAMACAhaHSoIAFoCAAkACAgOH4kkACYCAAAA.',['長華']='長華:BAAAKgAECggIEAAAAA==.',['领航']='领航:BAAAKgAECgIIAgAAAA==.',['风行']='风行者丶卡纳:BAAAKgAECgUIBQAAAA==.',['骑猪']='骑猪找对象:BAABKgAFFH8RAAIKAAYIJx+jCgAsAQAKAAYIJx+jCgAsAQAAAA==.',['魂丶']='魂丶弹:BAAAKgADCggIDgAAAA==.',['麦斯']='麦斯蒂娜:BAAAKgAFFAMIAwAAAA==.',['黑暗']='黑暗化身丶:BAAAKgAFFAEIAgAAAA==.',['默丶']='默丶默:BAAAKgAECgQIBgAAAA==.',['默默']='默默丿丿:BAAAKgAECgQIBAAAAA==.默默灬灬:BAAAKgAECgcIBwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end