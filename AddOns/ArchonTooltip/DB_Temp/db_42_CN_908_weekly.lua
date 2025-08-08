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
 local lookup = {'Mage-Fire','DemonHunter-Havoc','DemonHunter-Vengeance','Druid-Balance','Evoker-Devastation','Evoker-Preservation','DeathKnight-Unholy','Unknown-Unknown','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Paladin-Retribution','Paladin-Protection','Hunter-Marksmanship','Rogue-Assassination','Rogue-Subtlety','Mage-Arcane','Mage-Frost','Monk-Mistweaver','Shaman-Elemental','DeathKnight-Blood','Warrior-Protection','Warrior-Arms','DeathKnight-Frost','Priest-Discipline','Priest-Holy','Druid-Guardian','Evoker-Augmentation',}; local provider = {region='CN',realm='瓦拉纳',name='CN',type='weekly',zone=42,date='2025-08-06',data={Ar='Artemis:BAAAKgADCggICAAAAA==.',As='Aspirantx:BAABKgAFFH8IAAIBAAQIuR3rFAD7AAABAAQIuR3rFAD7AAAAAA==.',Cn='Cnofne:BAAAKgAECgUIBQAAAA==.',De='Demonanimal:BAAAKgAECgQIBAAAAA==.',Fa='Faker:BAAAKgAFFAIIAwAAAA==.',Ki='Killer:BAABKgAFFH8IAAICAAgI1gZhDACTAQACAAgI1gZhDACTAQAAAA==.',Lr='Lr:BAAAKgAECggICAAAAA==.',Ma='Makima:BAABKgAFFH8FAAMDAAUIsQyzDgCLAAADAAQIdAWzDgCLAAACAAEIaiIqSABTAAABKgAFFAgIDAAEAEklAA==.',No='Nosh:BAAAKgAECggICAAAAA==.',['上天']='上天擒大胆:BAAAKgAECggICAAAAA==.',['上帝']='上帝之手:BAAAKgADCgEIAgAAAA==.',['世良']='世良真纯:BAAAKgADCgEIAQAAAA==.',['丶名']='丶名侦探嬲塞:BAAAKgAECggICAAAAA==.',['丷小']='丷小果果丷:BAAAKgADCgEIAQAAAA==.',['丹妮']='丹妮丨莉丝:BAABKgAFFH8NAAMFAAcI3AyAFwALAQAFAAYILAmAFwALAQAGAAIIfw0fBwCVAAAAAA==.',['二费']='二费零杠七:BAACKgAFFH8KAAIFAAUIHCEWDgB/AQAFAAUIHCEWDgB/AQAqAAQKfxoAAwUACAjvIQwOAGICAAUACAjvIQwOAGICAAYABQjTEpUXAN4AAAAA.',['云外']='云外遥山:BAAAKgADCggICAAAAA==.',['今夜']='今夜有风:BAAAKgADCgUIBQAAAA==.',['伊瑞']='伊瑞儿:BAAAKgADCgMIAwAAAA==.伊瑞尔丶影歌:BAAAKgADCgMIAwAAAA==.',['你后']='你后面有东西:BAAAKgAFFAMIAwAAAA==.',['像个']='像个高手:BAAAKgADCgcIBwAAAA==.',['八零']='八零後老大哥:BAAAKgADCgEIAQAAAA==.',['冥界']='冥界骑士:BAABKgAECn8XAAIHAAgIowvYWgBWAQAHAAgIowvYWgBWAQAAAA==.',['冰墩']='冰墩墩:BAAAKgAFFAIIAgAAAA==.',['冰镇']='冰镇柠檬水:BAAAKgADCggICAAAAA==.',['冰龙']='冰龙:BAAAKgADCgEIAQAAAA==.',['初升']='初升的东曦:BAAAKgADCgMIAwAAAA==.',['北极']='北极熊猎手:BAAAKgAECgUICQABKgAFFAIIAgAIAAAAAA==.',['单刷']='单刷尼姑庵:BAAAKgADCggICAAAAA==.',['受天']='受天明命:BAABKgAFFH8JAAIJAAUIjx41BQB8AQAJAAUIjx41BQB8AQAAAA==.',['呆小']='呆小夫:BAAAKgAECgMIAwAAAA==.',['哥要']='哥要变身啦:BAAAKgAFFAQIBAAAAA==.',['喝杯']='喝杯娃哈哈:BAACKgAFFH8UAAMKAAQIVh/1IgDwAAAKAAMIVh/1IgDwAAALAAIIUhmIFgBOAAAqAAQKfzQABAoACAjmIrgWADsCAAoACAhsILgWADsCAAsABgi/IDAWAMcBAAwAAQgVDPMbAC0AAAAA.',['噢咔']='噢咔:BAABKgAFFH8MAAMNAAQIzyVnBgBNAQANAAQIzyVnBgBNAQAOAAQI3BfuCADSAAABKgAFFAgICgACAAIRAA==.',['图拉']='图拉玛:BAAAKgAECggICAAAAA==.',['土灵']='土灵僧:BAAAKgAECgMIAwAAAA==.',['墨鱼']='墨鱼假心:BAAAKgAFFAgIBAAAAA==.',['夜之']='夜之牧:BAAAKgADCgEIAQAAAA==.',['夜曲']='夜曲搁浅:BAABKgAECn8eAAINAAgIbRlpUQDJAQANAAgIbRlpUQDJAQAAAA==.',['大唫']='大唫柱子:BAAAKgAFFAQIBAAAAA==.',['大帝']='大帝的猎变:BAABKgAFFH8IAAIPAAgIORt1AwBjAgAPAAgIORt1AwBjAgAAAA==.',['大星']='大星术师谷歌:BAABKgAFFH8kAAQKAAgIsyFJAwCBAgAKAAgIXiFJAwCBAgAMAAUIiiGdAgB8AQALAAMImx2UCQCzAAAAAA==.',['大爷']='大爷丶太爷:BAAAKgAECggICQAAAA==.',['太美']='太美的圣骑:BAAAKgADCgUIBQAAAA==.',['奶盖']='奶盖火龙果:BAABKgAFFH8IAAMNAAYIJg3TJgDXAAANAAYIJg3TJgDXAAAOAAIIUwU9JABmAAAAAA==.',['妖之']='妖之林:BAAAKgAECgEIAQAAAA==.',['孤独']='孤独小鸟:BAAAKgAECgEIAQAAAA==.',['完美']='完美风尘:BAAAKgADCgEIAQAAAA==.',['小困']='小困包:BAAAKgAECgIIAgAAAA==.',['小黄']='小黄莺:BAAAKgADCggICAAAAA==.',['尘归']='尘归尘土归土:BAAAKgADCggICAAAAA==.',['山里']='山里灵活的苟:BAAAKgAECgcIBwAAAA==.',['幸运']='幸运小孩儿:BAABKgAECn8eAAMQAAgImBa8GADFAQAQAAgImBa8GADFAQARAAgI0gf4GgBSAQAAAA==.',['幺幺']='幺幺泠:BAABKgAFFH8GAAINAAYItRogFAC7AQANAAYItRogFAC7AQAAAA==.',['张小']='张小旺:BAAAKgAFFAQIBAAAAA==.',['弦千']='弦千钧:BAAAKgAFFAQIBAAAAA==.',['强尼']='强尼德普:BAAAKgADCggICAAAAA==.',['彩云']='彩云荣老师:BAABKgAECn8WAAISAAgIcw2+SAAcAQASAAgIcw2+SAAcAQAAAA==.',['总之']='总之很可爱:BAACKgAFFH8FAAMBAAIIdhSBLQCTAAABAAIIdhSBLQCTAAATAAEI5hqeGwBQAAAqAAQKfy4ABAEACAibIzMMALMCAAEACAiAIjMMALMCABMABwhDIsQkAO8BABIAAwgJI7IRADQBAAAA.',['悄悄']='悄悄德:BAAAKgADCgEIAQAAAA==.',['悠柔']='悠柔:BAAAKgAFFAQIBAAAAA==.',['情绪']='情绪乀中毒:BAAAKgADCgIIAgAAAA==.',['我只']='我只负责萌丶:BAABKgAFFH8GAAIUAAYIIxaKDgA/AQAUAAYIIxaKDgA/AQAAAA==.',['我是']='我是小刺客:BAAAKgAECgIIAgAAAA==.我是酒吧胸器:BAAAKgAECggICAAAAA==.',['我要']='我要影遁了:BAABKgAFFH8LAAICAAYILh4JCAA6AQACAAYILh4JCAA6AQAAAA==.',['扛起']='扛起灬加特林:BAABKgAFFH8QAAMJAAYIUh19CwAnAQAPAAYIeRW+EQBWAQAJAAYIUh19CwAnAQAAAA==.',['抖胸']='抖胸奶四方:BAAAKgADCgcIBwAAAA==.',['抠了']='抠了多放点:BAAAKgAECggIDwAAAA==.',['拔个']='拔个牙楼:BAAAKgADCgIIAgAAAA==.',['捌秒']='捌秒:BAAAKgADCggICAAAAA==.',['文突']='文突苏立:BAACKgAFFH8NAAIVAAQIFhypCADpAAAVAAQIFhypCADpAAAqAAQKfyAAAhUACAi3JCkHAMICABUACAi3JCkHAMICAAAA.',['无心']='无心试试:BAAAKgADCgEIAgAAAA==.',['日暮']='日暮死骑:BAABKgAECn8UAAMHAAgIBx1jLgD6AQAHAAgIBx1jLgD6AQAWAAYIUROCMAASAQAAAA==.',['星辰']='星辰大海:BAABKgAFFH8PAAIEAAQISB1WKwDlAAAEAAQISB1WKwDlAAABKgAFFAgIEAALAOAZAA==.',['晚睡']='晚睡不早起:BAAAKgADCgYIBgAAAA==.',['晝擾']='晝擾怡紅阮:BAAAKgAECgcIEgAAAA==.',['暗影']='暗影丶舞动:BAAAKgAFFAIIAgAAAA==.',['暗魂']='暗魂小以八:BAAAKgADCggICAAAAA==.',['月羽']='月羽姬:BAAAKgADCgEIAgAAAA==.',['月野']='月野小兔:BAAAKgAECgMIAwAAAA==.',['木木']='木木雨革月:BAAAKgADCggICAAAAA==.',['杨大']='杨大力:BAAAKgAECgYIBgAAAA==.',['枪抖']='枪抖:BAAAKgAECgMIAwAAAA==.',['楚将']='楚将养由基:BAACKgAFFH8FAAIJAAMIpAqxHQCvAAAJAAMIpAqxHQCvAAAqAAQKfxsAAgkACAhgGJE5AL4BAAkACAhgGJE5AL4BAAAA.',['楚霸']='楚霸王:BAABKgAFFH8RAAMXAAMIVgTqEQBtAAAYAAMIfwKiEQB5AAAXAAMIVgTqEQBtAAABKgAFFAgIDwAUAMcVAA==.',['欧贝']='欧贝利斯克:BAAAKgAFFAQIBAAAAA==.',['水饺']='水饺大米小米:BAAAKgADCgIIAwAAAA==.',['池鱼']='池鱼思故沅丶:BAAAKgAECggICAAAAA==.',['沉默']='沉默的小兔子:BAAAKgADCgMIBgAAAA==.',['漢子']='漢子情森:BAAAKgADCgQIBAAAAA==.',['漫步']='漫步丨雲端:BAAAKgADCggICAAAAA==.',['澄澄']='澄澄:BAABKgAFFH8WAAMNAAgIYh8eKQBDAQANAAQIxSQeKQBDAQAOAAQIWBtIIAB8AAAAAA==.',['灬哈']='灬哈雷彗星灬:BAAAKgADCggICAAAAA==.',['灬澄']='灬澄澄灬:BAAAKgAECgMIBAAAAA==.',['炁丶']='炁丶鎏:BAABKgAFFH8GAAIUAAYIJgueDQD4AAAUAAYIJgueDQD4AAAAAA==.',['炉石']='炉石搓冒烟:BAAAKgAFFAIIAgAAAA==.',['炫彩']='炫彩卡比猫:BAABKgAFFH8OAAIUAAMImgeJJgCJAAAUAAMImgeJJgCJAAAAAA==.',['炮灰']='炮灰向前冲:BAAAKgADCgMIAwAAAA==.',['烟蝶']='烟蝶:BAAAKgAECgUIEQAAAA==.',['烟雨']='烟雨旧:BAABKgAFFH8QAAIQAAgIHxgBBQBFAgAQAAgIHxgBBQBFAgAAAA==.',['爱吹']='爱吹牛的牛:BAAAKgADCggICgAAAA==.',['爱昆']='爱昆:BAABKgAECn8fAAIHAAcI9xhwRwCXAQAHAAcI9xhwRwCXAQAAAA==.',['爱魔']='爱魔力轉圈圈:BAACKgAFFH8KAAINAAQIqiEwGQD5AAANAAQIqiEwGQD5AAAqAAQKfxQAAg0ACAjRHOU8ADgCAA0ACAjRHOU8ADgCAAAA.',['狂撸']='狂撸圣手:BAAAKgAECgcIBwAAAA==.',['狮叫']='狮叫兽:BAAAKgADCgIIAgAAAA==.',['玉藻']='玉藻前:BAAAKgADCgIIAgAAAA==.',['王球']='王球小球球:BAAAKgADCggICAAAAA==.',['王雷']='王雷的懒趴:BAABKgAECn8vAAMHAAgINhoKKgAPAgAHAAgINhoKKgAPAgAZAAgIrw3/FABKAQAAAA==.',['琪亚']='琪亚娜:BAAAKgADCgEIAQAAAA==.',['甜甜']='甜甜豆腐脑:BAAAKgAECgYICwAAAA==.',['白熊']='白熊山:BAABKgAFFH8GAAIHAAYIYw1UGgBLAQAHAAYIYw1UGgBLAQAAAA==.',['皮皮']='皮皮萨:BAAAKgAECgMIAwAAAA==.',['秋风']='秋风舞落叶:BAAAKgADCgMIAwAAAA==.',['程希']='程希载耀:BAAAKgAECgQIBAAAAA==.',['第三']='第三天使月城:BAACKgAFFH8FAAIBAAUI0iQ4BgAFAgABAAUI0iQ4BgAFAgAqAAQKfx4AAhMACAhFHN4VAAsCABMACAhFHN4VAAsCAAAA.',['筱王']='筱王子:BAAAKgADCgEIAQAAAA==.',['红桃']='红桃誒:BAABKgAFFH8NAAIPAAYILCMQBwDzAQAPAAYILCMQBwDzAQAAAA==.',['红色']='红色莫里哀:BAABKgAECn8UAAIJAAgIlAAICAEuAAAJAAgIlAAICAEuAAAAAA==.',['维娜']='维娜:BAAAKgADCggICAAAAA==.',['翊富']='翊富:BAAAKgAECgYIDwAAAA==.',['翠花']='翠花不太脆:BAAAKgAFFAgIAQAAAA==.',['耀夜']='耀夜姬:BAAAKgADCgEIAQAAAA==.',['脆脆']='脆脆鲨:BAABKgAFFH8RAAMNAAUIjRJsOACYAAANAAIIdiBsOACYAAAOAAUI/QLzIQBzAAABKgAFFAgIEwAOAA0TAA==.',['腐朽']='腐朽:BAAAKgADCgMIAwAAAA==.',['艺术']='艺术私房写真:BAAAKgAFFAEIAQAAAA==.',['艾莉']='艾莉塔:BAABKgAFFH8SAAMaAAgIqRgvAwA3AgAaAAgImBQvAwA3AgAbAAYIFhhnCQCNAQAAAA==.',['花丶']='花丶花:BAAAKgAFFAEIAQAAAA==.',['花开']='花开须忘忧丶:BAAAKgAFFAgIAgAAAA==.',['苏察']='苏察哈尔灿:BAAAKgADCgMIAwAAAA==.',['苗德']='苗德恒:BAAAKgAECggIDAAAAA==.',['華麗']='華麗乂謝幕:BAAAKgAECgIIAgAAAA==.',['菲利']='菲利克斯红铁:BAAAKgAECgIIAgAAAA==.',['蛮牛']='蛮牛:BAABKgAFFH8LAAMcAAMItAPXCwBYAAAcAAMItAPXCwBYAAAEAAIIHAG8MgAsAAABKgAFFAgIDwAUAMcVAA==.',['豆小']='豆小骑:BAAAKgAECggIEgAAAA==.',['贝恩']='贝恩:BAAAKgADCgEIAQAAAA==.',['迷失']='迷失的烈:BAAAKgAFFAgIBAAAAA==.',['道晚']='道晚:BAABKgAFFH8OAAIJAAgIzRtmBgAlAgAJAAgIzRtmBgAlAgAAAA==.',['那些']='那些年丶执着:BAAAKgAECgEIAQAAAA==.',['酱焖']='酱焖牛至:BAABKgAFFH8FAAIPAAII1heBGwCPAAAPAAII1heBGwCPAAAAAA==.',['铁骨']='铁骨:BAAAKgAFFAgIAgAAAA==.',['银影']='银影天仇:BAAAKgAECgYICgABKgAECggIHAANACEmAA==.',['长门']='长门丨有希:BAABKgAFFH8GAAIQAAYIYwiFEABIAQAQAAYIYwiFEABIAQAAAA==.',['阿克']='阿克懵德:BAAAKgAFFAQIBAAAAA==.',['阿娇']='阿娇酱:BAAAKgAFFAgIBAAAAA==.',['阿尔']='阿尔寿司:BAAAKgADCggIDwAAAA==.',['雅丽']='雅丽马斯内:BAABKgAFFH8IAAIPAAgIBw0yCAC1AQAPAAgIBw0yCAC1AQAAAA==.',['雅弥']='雅弥:BAAAKgADCggICAAAAA==.',['雅歌']='雅歌:BAAAKgAECgQIBAAAAA==.',['零小']='零小圣:BAAAKgAFFAEIAQAAAA==.',['雷鸣']='雷鸣电闪:BAAAKgAECgMIAwAAAA==.',['雾气']='雾气哥:BAAAKgADCgcIBwAAAA==.',['鞍山']='鞍山老铁:BAAAKgAECgUIBwAAAA==.',['鞘伏']='鞘伏:BAABKgAFFH8UAAICAAgI8yASCAAYAgACAAgI8yASCAAYAgAAAA==.',['风暴']='风暴降生龙妈:BAAAKgAECgMIAwAAAA==.',['风清']='风清云淡:BAAAKgADCggICQAAAA==.',['骑德']='骑德龙咚强:BAABKgAFFH8IAAIOAAgIsBcaBQDwAQAOAAgIsBcaBQDwAQAAAA==.',['魅魔']='魅魔克丽丝:BAACKgAFFH8JAAMGAAMIgAlGBwCRAAAGAAMIgAlGBwCRAAAdAAEIyQFDBQAcAAAqAAQKfxQAAgYABwh8FbIFAEwBAAYABwh8FbIFAEwBAAAA.',['鲜血']='鲜血小王子:BAABKgAFFH8QAAMWAAgIliGEAQB5AgAWAAgIrB2EAQB5AgAHAAYIYyY+BwAfAgAAAA==.',['鸭嘴']='鸭嘴头双采:BAABKgAFFH8GAAIEAAMIogSMRwCRAAAEAAMIogSMRwCRAAAAAA==.',['麻烦']='麻烦:BAAAKgAECgEIAQAAAA==.',['麻辣']='麻辣兔头哦:BAAAKgADCgEIAQAAAA==.',['黑杯']='黑杯:BAAAKgAECgEIAgAAAA==.',['黛歆']='黛歆落:BAAAKgAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end