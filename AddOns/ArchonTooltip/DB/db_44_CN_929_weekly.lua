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
 local lookup = {'DeathKnight-Unholy','DeathKnight-Frost','Druid-Feral','Druid-Balance','Priest-Shadow','Paladin-Retribution','Paladin-Protection','Priest-Holy','DeathKnight-Blood','Mage-Arcane','Hunter-BeastMastery','Shaman-Elemental','Warlock-Destruction','Warlock-Demonology','Monk-Mistweaver','Monk-Windwalker','Druid-Restoration','Monk-Brewmaster','Mage-Fire','Hunter-Marksmanship','Mage-Frost','Shaman-Restoration','Paladin-Holy','DemonHunter-Havoc',}; local provider = {region='CN',realm='冬寒',name='CN',type='weekly',zone=44,date='2025-12-07',data={Cv='Cvbcvbcb:BAAALAAECgMIAwAAAA==.',Da='Dalao:BAACLAAFFH8GAAMBAAIILA5kFACHAAABAAIIhwxkFACHAAACAAEI8QTFoQA9AAAsAAQKfxUAAwIACAj+FZe2AKUBAAIACAjNE5e2AKUBAAEABQhGERg3ABwBAAAA.',Ge='Genji:BAAALAAFFAIIAgAAAA==.',Hf='Hfghfghfg:BAAALAAECgYIBgAAAA==.',Hl='Hlhlyj:BAAALAADCgUIBQAAAA==.Hlhlyl:BAAALAAFFAQIBAAAAA==.Hlhsndejun:BAAALAADCgIIAgAAAA==.Hlhsnyc:BAAALAADCgIIAgAAAA==.Hlhyly:BAAALAADCgYIDAAAAA==.',Ho='Hodur:BAAALAAECgQIBQAAAA==.',Li='Libraf:BAABLAAFFH8GAAMDAAYIcAIEDABYAAADAAQITAIEDABYAAAEAAIIuAILQAAkAAAAAA==.',Lu='Luna:BAACLAAFFH8QAAIFAAUIfRB4FgAXAQAFAAUIfRB4FgAXAQAsAAQKfxkAAgUABgghGBBGAKABAAUABgghGBBGAKABAAAA.',Mi='Missfox:BAAALAADCgYIBgAAAA==.',Ph='Phamonster:BAACLAAFFH8vAAIGAAYITyYIBgAlAgAGAAYITyYIBgAlAgAsAAQKfzQAAgYACAiuJoMBAJIDAAYACAiuJoMBAJIDAAAA.',Se='Seecoo:BAABLAAFFH8IAAICAAIIygwAlQA8AAACAAIIygwAlQA8AAAAAA==.',Sn='Snaco:BAAALAADCgYIBgAAAA==.',Wy='Wyzlin:BAAALAAECgYIBgAAAA==.',Yg='Ygsm:BAAALAAECgYICgAAAA==.Ygss:BAAALAAECgYIBgAAAA==.',Yi='Yigeleiren:BAAALAAECgYIBgAAAA==.',['一个']='一个大火球:BAAALAAFFAUIAgAAAA==.一个梦:BAAALAAFFAIIAgAAAA==.',['一抹']='一抹:BAABLAAFFH8MAAICAAYILBEYMgB1AQACAAYILBEYMgB1AQAAAA==.',['一般']='一般六僧:BAAALAAFFAIIAgAAAA==.',['不要']='不要脱我裤子:BAAALAAECgYIDAAAAA==.',['丨慈']='丨慈丨:BAAALAAECgQICgAAAA==.',['丨红']='丨红枫翩跹丨:BAABLAAFFH8HAAIHAAMIHRNeEAB6AAAHAAMIHRNeEAB6AAAAAA==.',['丨若']='丨若叶睦丨:BAAALAAECgMIAwAAAA==.',['为欢']='为欢几何:BAABLAAECn8YAAMIAAcI+BbVVgB8AQAIAAYIcxXVVgB8AQAFAAEISBn+RgBMAAAAAA==.',['丽莎']='丽莎:BAABLAAFFH8GAAIJAAYIIw+CCwBYAQAJAAYIIw+CCwBYAQAAAA==.',['二娃']='二娃:BAABLAAFFH8IAAIKAAIIuxVXRQCaAAAKAAIIuxVXRQCaAAAAAA==.',['五毒']='五毒毒:BAABLAAFFH8KAAIEAAYICxPeCQCRAQAEAAYICxPeCQCRAQABLAAFFAgINgALAFkkAA==.',['伊索']='伊索:BAAALAADCggICAAAAA==.',['何意']='何意啊:BAABLAAFFH8XAAIMAAgIxRNkCQAaAgAMAAgIxRNkCQAaAgAAAA==.',['你机']='你机关儿爆炸:BAABLAAFFH8LAAIKAAYI/h1pHwCbAQAKAAYI/h1pHwCbAQABLAAFFAgIBgAKAGsiAA==.',['你艾']='你艾希我奶妈:BAAALAAECgYIBgAAAA==.',['佳佳']='佳佳:BAAALAADCggICAAAAA==.',['倾竹']='倾竹:BAAALAAECgUIBQAAAA==.',['元素']='元素主机:BAAALAADCggICAABLAAFFAgICAAGAH8TAA==.',['准备']='准备动身:BAABLAAFFH8IAAMNAAIIThjANgCjAAANAAIIThjANgCjAAAOAAEIIwKKIgAAAAAAAA==.',['凌霜']='凌霜降:BAABLAAECn8aAAIGAAcIpRoDXwAtAgAGAAcIpRoDXwAtAgAAAA==.',['单纯']='单纯的黑牛:BAACLAAFFH8GAAIPAAIIpAc7GABdAAAPAAIIpAc7GABdAAAsAAQKfxQAAw8ACAhUChsaAA0BAA8ACAhUChsaAA0BABAABAjICY8vAHgAAAAA.',['南城']='南城四旬:BAACLAAFFH8WAAMCAAgIuxZiEwCxAQACAAgIuxZiEwCxAQABAAEI/wZjIABAAAAsAAQKfycAAwIACAicIANLAGQCAAIACAhCIANLAGQCAAEACAgBEXojAKEBAAAA.',['卡搜']='卡搜搜:BAABLAAFFH8gAAILAAgIsyXTAAAJAwALAAgIsyXTAAAJAwABLAAFFAgINgALAFkkAA==.',['只孔']='只孔雀东南:BAABLAAFFH8GAAIJAAYIABVrCwBaAQAJAAYIABVrCwBaAQAAAA==.',['司马']='司马铁蛋:BAAALAAECgQIBAAAAA==.',['君不']='君不兮兮:BAACLAAFFH8OAAIIAAMIBSC2EwAQAQAIAAMIBSC2EwAQAQAsAAQKfxYAAggABwiBIEEqAD4CAAgABwiBIEEqAD4CAAAA.',['和煦']='和煦晚风:BAABLAAECn8XAAIRAAgI+R5ZGACeAgARAAgI+R5ZGACeAgAAAA==.',['哈基']='哈基米德:BAAALAAECgYICAAAAA==.',['园经']='园经几夜伊甸:BAABLAAFFH8OAAIJAAgIMhIlBQAAAgAJAAgIMhIlBQAAAgAAAA==.',['国宝']='国宝胸毛:BAAALAAECgYIDAAAAA==.',['土豆']='土豆泥丶:BAAALAAECgYIBQAAAA==.',['埃斯']='埃斯梅拉达:BAAALAAECgIIAgAAAA==.',['复活']='复活戒指:BAAALAAECgcIEQAAAA==.',['夏天']='夏天天:BAABLAAFFH8vAAILAAgIWSXmAQDrAgALAAgIWSXmAQDrAgABLAAFFAgINgALAFkkAA==.',['大刀']='大刀四十米:BAAALAAFFAMIBAAAAA==.',['天亮']='天亮就起床:BAAALAAECgMIAwAAAA==.',['天棘']='天棘梦青丝:BAABLAAFFH8GAAIJAAYIdxAfDQA5AQAJAAYIdxAfDQA5AQAAAA==.',['天遼']='天遼秋泊:BAAALAADCggICAAAAA==.',['好龙']='好龙:BAAALAAECgYIBgAAAA==.',['姜珮']='姜珮瑶:BAAALAAFFAIIAgAAAA==.',['安洁']='安洁莉娅:BAABLAAFFH8KAAIIAAIISwj/OQCAAAAIAAIISwj/OQCAAAABLAAFFAMIFAACABIgAA==.',['小小']='小小汪:BAAALAAECgMIAwAAAA==.',['小月']='小月半弯:BAAALAAECgMIBQAAAA==.',['工程']='工程作业员:BAACLAAFFH8aAAQQAAMIsRrlDwCbAAAQAAMIsRrlDwCbAAAPAAMI0wlrEgCVAAASAAEI2AjXHwA2AAAsAAQKfxQAAxAABgikGjYxAIgBABAABgikGjYxAIgBAA8ABAjjEJ1HAIgAAAAA.',['巴哈']='巴哈:BAAALAAFFAIIAgAAAA==.',['庸手']='庸手丶:BAAALAAECgEIAQAAAA==.',['快叫']='快叫萨爹:BAAALAAECgYIBgAAAA==.',['思念']='思念说给枫听:BAAALAAECgIIAgAAAA==.',['战火']='战火青春:BAABLAAFFH8GAAILAAIIEBUYmgBBAAALAAIIEBUYmgBBAAAAAA==.',['提尔']='提尔尔:BAAALAADCgYIBgAAAA==.',['斯托']='斯托尔特:BAAALAAECgUIBQAAAA==.',['新的']='新的冲锋:BAAALAAECggICAAAAA==.',['无敌']='无敌惩戒大王:BAAALAAECgIIAgAAAA==.',['昀丶']='昀丶:BAABLAAFFH8GAAIKAAIIjwQdZwA0AAAKAAIIjwQdZwA0AAAAAA==.',['春光']='春光难遇秋草:BAABLAAFFH8GAAIJAAYIIxk2DgAkAQAJAAYIIxk2DgAkAQAAAA==.',['春天']='春天的筱野兽:BAAALAAECggICAAAAA==.',['春芒']='春芒野火:BAAALAAECgYIDAAAAA==.',['晚风']='晚风:BAACLAAFFH8TAAIKAAYIAhVfDwDsAQAKAAYIAhVfDwDsAQAsAAQKfxgAAwoACAgIIXs5AGQCAAoACAgIIXs5AGQCABMABgjYBhIQABkBAAAA.',['晨曦']='晨曦雨露:BAAALAAECgUIBQAAAA==.',['月城']='月城柳:BAAALAAFFAIIAgAAAA==.',['未闻']='未闻:BAAALAADCgIIAgAAAA==.',['松子']='松子糖:BAAALAAECgYIDAAAAA==.',['柳絮']='柳絮:BAABLAAFFH8UAAICAAMIEiBkVQC6AAACAAMIEiBkVQC6AAAAAA==.',['栗子']='栗子球丶:BAAALAAFFAIIAgAAAA==.',['棒子']='棒子油条:BAABLAAFFH8GAAILAAIIVQX9dwB1AAALAAIIVQX9dwB1AAAAAA==.',['沙拉']='沙拉曼:BAAALAAECgYICgAAAA==.',['泽坦']='泽坦:BAABLAAFFH8IAAIJAAgIAQ+EBgDTAQAJAAgIAQ+EBgDTAQAAAA==.',['浅吻']='浅吻:BAABLAAFFH8IAAIGAAgIfxPPCwDnAQAGAAgIfxPPCwDnAQAAAA==.',['海绵']='海绵妹儿:BAAALAAECggICAAAAA==.',['烈牙']='烈牙仇瀑:BAABLAAFFH8KAAIBAAUI4hEMBgA6AQABAAUI4hEMBgA6AQAAAA==.',['爱上']='爱上擎天:BAAALAAFFAIIAgAAAA==.',['牛八']='牛八:BAABLAAFFH8QAAIGAAYI+hThEAA6AQAGAAYI+hThEAA6AQAAAA==.',['狂雪']='狂雪:BAAALAAECgUICAAAAA==.',['王淑']='王淑芬:BAACLAAFFH8KAAIGAAQIbAqIOQC6AAAGAAQIbAqIOQC6AAAsAAQKfyIAAgYABwifGHs6AK8BAAYABwifGHs6AK8BAAAA.',['瓜皮']='瓜皮:BAABLAAFFH82AAILAAgIWSQ5AwDKAgALAAgIWSQ5AwDKAgAAAA==.',['生当']='生当做人杰:BAAALAADCgYIDAAAAA==.',['瘟疫']='瘟疫:BAABLAAFFH8OAAIJAAgIkxrDAgBfAgAJAAgIkxrDAgBfAgAAAA==.',['白嫩']='白嫩嫩:BAABLAAFFH8eAAIUAAgI3B2KAACGAgAUAAgI3B2KAACGAgABLAAFFAgINgALAFkkAA==.',['白狼']='白狼狼:BAABLAAFFH8iAAILAAgIDyROAgDgAgALAAgIDyROAgDgAgABLAAFFAgINgALAFkkAA==.',['盛怒']='盛怒:BAABLAAFFH8QAAMCAAYIah8fDgDmAQACAAYIPQ8fDgDmAQAJAAYIah8WBgDgAQAAAA==.',['眠眠']='眠眠大魔王:BAAALAAECgYICAAAAA==.',['碧落']='碧落:BAAALAADCgIIAgAAAA==.',['稻稻']='稻稻:BAAALAADCgYIAwAAAA==.',['空丶']='空丶城:BAAALAAECgYICAAAAA==.',['空幕']='空幕华年:BAAALAAECgMIBAAAAA==.',['端木']='端木凌锋:BAAALAAECgYICgAAAA==.',['筑梦']='筑梦丿:BAAALAAECgEIAQAAAA==.',['紫菜']='紫菜菜:BAABLAAFFH8oAAILAAgIACZXAgDgAgALAAgIACZXAgDgAgABLAAFFAgINgALAFkkAA==.',['纷争']='纷争:BAABLAAFFH8LAAIJAAYI4RgpCgB1AQAJAAYI4RgpCgB1AQAAAA==.',['维也']='维也纳的救赎:BAAALAAECgYICwAAAA==.',['胡桃']='胡桃:BAAALAAECgYIEQAAAA==.',['若叶']='若叶睦:BAAALAAECgMIAwAAAA==.若叶睦丶:BAABLAAFFH8GAAIVAAYIKAGeEwBJAAAVAAYIKAGeEwBJAAAAAA==.若叶问:BAACLAAFFH8LAAMSAAMIGBy9FwCoAAASAAMIGBy9FwCoAAAQAAEIGQGrHQAMAAAsAAQKfxwABBIACAhSIMoDAHgCABIACAg9HcoDAHgCABAABwh4HqEIACMCAA8AAQhdE8cvADoAAAAA.',['萌新']='萌新闯世界:BAACLAAFFH8IAAMOAAII/xDnEABLAAANAAIIJgnzSwCIAAAOAAIIWQ7nEABLAAAsAAQKfyQAAw0ABwiEG3IwAI0BAA0ABwgtG3IwAI0BAA4ABwjdDyc4AIwBAAAA.',['萨满']='萨满真神:BAABLAAFFH8PAAIWAAgIMBd3CAA/AgAWAAgIMBd3CAA/AgAAAA==.',['蒙蒙']='蒙蒙大魔王:BAAALAADCgYIBgAAAA==.',['藏苦']='藏苦:BAAALAAECgMIBAAAAA==.',['血色']='血色玫瑰:BAAALAADCgYIBgAAAA==.',['装备']='装备动手:BAABLAAFFH8GAAICAAIIpx+dOwC6AAACAAIIpx+dOwC6AAAAAA==.',['诸葛']='诸葛连撸:BAABLAAECn8bAAMUAAcIcRnXRACiAQAUAAcI6BXXRACiAQALAAYIDhlbbQBqAQAAAA==.',['贝优']='贝优妮塔:BAAALAAECgYIBgAAAA==.',['贺雷']='贺雷修斯:BAAALAAECgIIAgAAAA==.',['贼桑']='贼桑的小树苗:BAABLAAFFH8IAAMRAAIIiQ0NNgBqAAARAAIIiQ0NNgBqAAAEAAEIrgHMMAAmAAAAAA==.',['赢一']='赢一把休息:BAAALAAFFAIIBAAAAA==.',['走丟']='走丟了:BAAALAAECgYIBgAAAA==.',['辣鸡']='辣鸡职业:BAAALAAECgQIBAAAAA==.',['邪恶']='邪恶梅格:BAAALAAECgYICgAAAA==.',['醉意']='醉意丶:BAABLAAFFH8SAAIXAAYIURvPCwDLAQAXAAYIURvPCwDLAQAAAA==.',['铃鹿']='铃鹿御前:BAABLAAFFH8PAAIYAAMIGyKnMQCnAAAYAAMIGyKnMQCnAAABLAAFFAgIFQAGAJ4iAA==.',['锦绣']='锦绣未央:BAAALAAECgEIAQAAAA==.',['长尡']='长尡:BAACLAAFFH8QAAIIAAIIZgkNQgBnAAAIAAIIZgkNQgBnAAAsAAQKfxgAAwgACAgYEeQyAC4BAAgABwioEOQyAC4BAAUAAghEDdJCAGEAAAAA.',['雀鹰']='雀鹰:BAAALAAECgUIBQAAAA==.',['雾彦']='雾彦祖:BAAALAAECgEIAQAAAA==.',['风怒']='风怒来我身边:BAAALAAECgUICgAAAA==.',['风暴']='风暴:BAAALAAECgQIBAAAAA==.',['飙马']='飙马野狼:BAAALAAFFAMIAwAAAA==.',['飚血']='飚血:BAABLAAFFH8WAAICAAMIawdyaAB5AAACAAMIawdyaAB5AAAAAA==.飚血王:BAABLAAFFH8IAAIVAAIIeAjCHAA4AAAVAAIIeAjCHAA4AAAAAA==.',['飞天']='飞天大河马:BAABLAAFFH8dAAILAAgIkiRYAQD6AgALAAgIkiRYAQD6AgABLAAFFAgINgALAFkkAA==.',['饥荒']='饥荒:BAABLAAFFH8GAAIJAAYICRdICwBcAQAJAAYICRdICwBcAQAAAA==.',['马依']='马依然:BAABLAAFFH8jAAILAAgI4yW3AAAMAwALAAgI4yW3AAAMAwABLAAFFAgINgALAFkkAA==.',['鬼地']='鬼地方:BAAALAAECgQIBAAAAA==.',['魔兽']='魔兽入野:BAABLAAFFH8VAAMGAAgIniJPAQDcAgAGAAgIniJPAQDcAgAHAAMIXhrGDwCEAAAAAA==.',['麻婆']='麻婆豆腐:BAAALAADCgUICAAAAA==.',['麻痹']='麻痹戒指:BAAALAAECgIIAgAAAA==.',['龍丫']='龍丫:BAAALAAECgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end