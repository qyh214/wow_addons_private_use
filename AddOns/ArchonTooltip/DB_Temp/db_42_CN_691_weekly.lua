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
 local lookup = {'Hunter-BeastMastery','Warlock-Destruction','Hunter-Survival','Unknown-Unknown','Hunter-Marksmanship','Shaman-Restoration','Shaman-Elemental','Monk-Mistweaver','Mage-Frost','Paladin-Retribution','DeathKnight-Unholy','Warrior-Fury','Warrior-Arms','Warlock-Demonology','Paladin-Protection','Priest-Shadow','Priest-Holy','Priest-Discipline','Warlock-Affliction','Druid-Restoration','Druid-Balance','Druid-Guardian','Paladin-Holy',}; local provider = {region='CN',realm='拉贾克斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alleriasulu:BAAAKgAFFAgIAQAAAA==.',Ca='Carol:BAAAKgAECgcIDAAAAA==.',Co='Cosima:BAAAKgAFFAEIAgAAAA==.',Ka='Kaniellesulu:BAABKgAFFH8IAAIBAAgIXAdrDQCbAQABAAgIXAdrDQCbAQAAAA==.',Ne='Nesingwary:BAABKgAFFH8ZAAIBAAQIyw6UGgDCAAABAAQIyw6UGgDCAAAAAA==.',Sy='Sylvanassulu:BAABKgAFFH8OAAICAAgIQRvPBABTAgACAAgIQRvPBABTAgAAAA==.',To='Totemsoul:BAAAKgADCgMIAwAAAA==.',['一串']='一串大闸蟹:BAABKgAFFH8IAAIBAAgISg0kCADxAQABAAgISg0kCADxAQAAAA==.',['丶电']='丶电解质:BAAAKgAFFAIIAgAAAA==.',['二傻']='二傻之:BAAAKgAECggICAAAAA==.',['云中']='云中君:BAAAKgAECgYICgAAAA==.',['亚历']='亚历山大:BAAAKgAECgYIBgAAAA==.',['你在']='你在玩火:BAAAKgAECgEIAQAAAA==.',['六月']='六月雪:BAAAKgAECgMIAwAAAA==.',['冰冰']='冰冰的蛋黄:BAAAKgAECgUIBQAAAA==.',['凨行']='凨行獨儛:BAAAKgAECgcIDQAAAA==.',['勇沣']='勇沣哲:BAAAKgAECgIIAgAAAA==.',['北极']='北极很慢:BAAAKgAECgEIAQAAAA==.',['十八']='十八岁萌萌:BAAAKgAECgEIAQAAAA==.',['南明']='南明:BAAAKgAECgUIBgAAAA==.',['印象']='印象雲烟:BAAAKgADCgEIAQAAAA==.',['变变']='变变乐:BAAAKgAECgMIAwAAAA==.',['吴屁']='吴屁屁:BAAAKgADCggICAAAAA==.',['吴臭']='吴臭臭:BAAAKgAECgUICQAAAA==.',['啊人']='啊人才:BAAAKgAECgYICgAAAA==.',['圣光']='圣光白:BAAAKgAECgUIBQAAAA==.',['圣灵']='圣灵舞者:BAAAKgADCggICgAAAA==.',['天堂']='天堂向左:BAAAKgAECgIIAgAAAA==.',['太极']='太极雪月:BAAAKgADCgIIAgAAAA==.',['奉献']='奉献型人格:BAAAKgAFFAcIAQABKgAFFAgIBgADAN8RAA==.',['孙媳']='孙媳妇:BAAAKgAFFAQIBAAAAA==.',['审之']='审之判:BAAAKgAECggICgAAAA==.',['寒冰']='寒冰彡葡萄:BAAAKgADCgQIBgAAAA==.',['小巴']='小巴特儿:BAAAKgAECgYICgAAAA==.',['小熊']='小熊猫:BAAAKgADCgMIAwAAAA==.',['小锡']='小锡林:BAAAKgADCggIEAAAAA==.',['山东']='山东德哥:BAAAKgAECgIIAgAAAA==.',['巫女']='巫女的黑喵:BAAAKgAECggICAAAAA==.',['帅气']='帅气滴夕阳:BAAAKgAECgYICgAAAA==.',['御殿']='御殿月将军:BAAAKgAECgQIBAABKgAFFAEIAQAEAAAAAA==.',['心的']='心的开始:BAABKgAFFH8GAAICAAYIGhXTFgBNAQACAAYIGhXTFgBNAQAAAA==.',['心绪']='心绪:BAABKgAFFH8cAAMBAAQIrB3MEQAKAQABAAQIrB3MEQAKAQAFAAQIExS6KADHAAAAAA==.',['怪哞']='怪哞哞:BAAAKgAECgQIBAAAAA==.',['惹噜']='惹噜啾咪厚:BAACKgAFFH8dAAMGAAUIZSBZCwCRAQAGAAUIZSBZCwCRAQAHAAUIkBcGCQA8AQAqAAQKfyoAAwYACAjEIwkMAJYCAAYACAjEIwkMAJYCAAcACAgEG4keAPgBAAAA.',['我僧']='我僧慈悲:BAABKgAFFH8cAAIIAAYIMhTEDwAwAQAIAAYIMhTEDwAwAQAAAA==.',['我爱']='我爱暖暖:BAABKgAECn8ZAAIJAAgI3x/wCgCIAgAJAAgI3x/wCgCIAgAAAA==.',['拉玛']='拉玛基尼:BAAAKgADCggICAAAAA==.',['插插']='插插乐:BAAAKgAECgUIBQAAAA==.',['放纵']='放纵:BAAAKgAECggIDgAAAA==.',['无敌']='无敌大结实:BAAAKgAECgMIBAAAAA==.无敌小希:BAAAKgADCggICAAAAA==.',['月夜']='月夜丶飘雪:BAAAKgAECgUIBQAAAA==.',['月影']='月影星晨:BAAAKgAECgUIBQAAAA==.',['李阿']='李阿不:BAAAKgAECgcICwAAAA==.',['林怼']='林怼怼:BAABKgAFFH8FAAIKAAUILhoKLQAzAQAKAAUILhoKLQAzAQAAAA==.',['树與']='树與静风不止:BAABKgAFFH8MAAILAAgI+gqiCgDjAQALAAgI+gqiCgDjAQAAAA==.',['欧丨']='欧丨皇小萨:BAAAKgADCgEIAQAAAA==.',['此生']='此生不换:BAACKgAFFH8FAAIMAAQIERDwJAC8AAAMAAQIERDwJAC8AAAqAAQKfyAAAw0ACAiqG/cNAFACAA0ABwiqG/cNAFACAAwAAQgAAC2fAAAAAAAA.',['毁灭']='毁灭术:BAABKgAFFH8HAAMCAAMIQhbgIACNAAACAAMIQhbgIACNAAAOAAEImwSeHwA1AAAAAA==.',['汐溪']='汐溪:BAAAKgAECgYICQAAAA==.',['汤米']='汤米谢尔比:BAAAKgAECgcIBwAAAA==.',['流年']='流年:BAAAKgAFFAQIAgAAAA==.',['浩子']='浩子超无敌:BAAAKgAFFAgIAgAAAA==.',['淑薇']='淑薇:BAAAKgADCggICAAAAA==.',['灬二']='灬二師兄灬:BAAAKgAECgIIAgAAAA==.',['独木']='独木秀于林:BAAAKgAFFAQIBAAAAA==.',['猪得']='猪得:BAACKgAFFH8OAAIKAAMINRMdSwDYAAAKAAMINRMdSwDYAAAqAAQKfxkAAwoACAiHGLFSAMUBAAoACAiHGLFSAMUBAA8AAQglAh9jAAUAAAAA.',['窗前']='窗前明月光:BAAAKgAECggICAAAAA==.',['竹马']='竹马吃青梅:BAAAKgADCgMIAwAAAA==.',['美丽']='美丽心灵:BAABKgAFFH8IAAMQAAgImQKJDAD0AAAQAAcIuAKJDAD0AAARAAEIzQCkIAAxAAAAAA==.',['老灵']='老灵导:BAAAKgADCggICAAAAA==.',['聖骑']='聖骑士:BAABKgAECn8jAAMOAAgImSM/CABdAgAOAAgIkyI/CABdAgACAAQIHCLTOAApAQAAAA==.',['艾丽']='艾丽丝丶杨:BAACKgAFFH8eAAMQAAUITx4KCQB2AQAQAAUITx4KCQB2AQASAAIIcCCGGwC4AAAqAAQKfzAAAxAACAh0JNIFAL8CABAACAh0JNIFAL8CABIAAwiTHgRRANIAAAAA.',['艾西']='艾西莉亚:BAAAKgADCgMIAwAAAA==.',['蓝月']='蓝月儿小姐:BAAAKgADCgIIAgAAAA==.',['蕾米']='蕾米莉亚:BAABKgAFFH8MAAQOAAYIrRTeAwA6AQAOAAUIshbeAwA6AQACAAEImAzPJwBIAAATAAEIfwSLIgBDAAAAAA==.',['蝌蚪']='蝌蚪绣蛤蟆:BAABKgAECn8WAAMFAAcIUxL6GQBTAQAFAAcIUxL6GQBTAQABAAIIBQSPCwEpAAAAAA==.',['西楚']='西楚霸王:BAABKgAECn8XAAQUAAgIsBFXKgBXAQAUAAcIkBNXKgBXAQAVAAUI4g//hQDQAAAWAAEIJgfJRQAPAAAAAA==.',['踢踢']='踢踢乐:BAAAKgADCgIIAgAAAA==.',['轩辕']='轩辕奇奇:BAAAKgAECgIIAgAAAA==.',['透心']='透心凉:BAAAKgAFFAQIBAAAAA==.',['醉别']='醉别江南:BAAAKgAECgQIBAAAAA==.',['银哇']='银哇:BAAAKgAECgIIAgAAAA==.',['银蛙']='银蛙:BAAAKgAECgQIBQAAAA==.',['闪电']='闪电博尔特:BAAAKgAECgYIBgAAAA==.',['阿兰']='阿兰娜之狡黠:BAAAKgAECggIEQAAAA==.',['风流']='风流小青年:BAAAKgAECgQIBAABKgAFFAUIHgAQAE8eAA==.',['魔裔']='魔裔一电锯男:BAACKgAFFH8OAAMXAAQIkRzVCQALAQAXAAQIkRzVCQALAQAKAAMIaRfMIADlAAAqAAQKfxgAAxcACAh6JM0CAM4CABcACAh6JM0CAM4CAAoAAwh0GN9NANAAAAAA.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end