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
 local lookup = {'Warlock-Destruction','DeathKnight-Frost','Monk-Mistweaver','Mage-Arcane','DemonHunter-Havoc','Shaman-Restoration','Shaman-Elemental','Paladin-Retribution','Druid-Restoration','Druid-Balance','Warlock-Demonology','Paladin-Holy','Hunter-BeastMastery','Warrior-Protection','Warrior-Fury','Mage-Frost','Warrior-Arms','Druid-Guardian','Paladin-Protection','Unknown-Unknown','Hunter-Marksmanship','Priest-Holy','Evoker-Devastation','Evoker-Preservation',}; local provider = {region='CN',realm='瓦拉纳',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ai='Aixx:BAAALAAFFAMIAwAAAA==.',Am='Amoris:BAABLAAFFH8SAAIBAAYImxBSLQBmAQABAAYImxBSLQBmAQAAAA==.',Ar='Artemis:BAAALAAFFAIIBAAAAA==.',As='Aspirantx:BAAALAAECgYICAAAAA==.Aspirantxx:BAAALAAECgIIAgAAAA==.',Be='Belfmwarlock:BAAALAADCgYIBgAAAA==.',De='Demonanimal:BAAALAAECgYIBwAAAA==.',Di='Dio:BAABLAAFFH8SAAICAAYI6wTERAApAQACAAYI6wTERAApAQAAAA==.',Fa='Faker:BAABLAAFFH8IAAIDAAIIQBfaDwCUAAADAAIIQBfaDwCUAAAAAA==.',Is='Isbella:BAACLAAFFH8bAAIEAAYIfxbBIgCLAQAEAAYIfxbBIgCLAQAsAAQKfywAAgQACAjLIJYHAKACAAQACAjLIJYHAKACAAAA.',Mo='Monondy:BAAALAAFFAQIBAAAAA==.',Ob='Oblivionis:BAABLAAFFH8nAAIBAAYIuxmiIgCSAQABAAYIuxmiIgCSAQAAAA==.',Oi='Oi:BAAALAAFFAIIAgAAAA==.',Ok='Ok:BAAALAAFFAIIBAAAAA==.',Ra='Ravendk:BAAALAAECgYIBgAAAA==.',Ti='Timgmcgraw:BAAALAAFFAIIAgAAAA==.',Vi='Vii:BAAALAADCgEIAQAAAA==.',Wo='Woohoho:BAAALAAECgYIDAAAAA==.',Ym='Ymwdh:BAABLAAFFH8IAAIFAAIIJQ5UTwCNAAAFAAIIJQ5UTwCNAAAAAA==.',['一号']='一号萨满:BAABLAAFFH8IAAIGAAgIoRfxBgBTAgAGAAgIoRfxBgBTAgAAAA==.',['三森']='三森铃子:BAAALAAECgIIAgAAAA==.',['上帝']='上帝说要有光:BAAALAAECgYIBgAAAA==.',['丝袜']='丝袜奶茶丶:BAABLAAFFH8QAAIHAAII9hxSIQCrAAAHAAII9hxSIQCrAAAAAA==.',['丨混']='丨混乱之箭丨:BAAALAADCgQIBAAAAA==.',['丨跳']='丨跳跳糖丨:BAAALAAFFAIIAgAAAA==.',['丶澄']='丶澄:BAAALAAFFAIIAgAAAA==.',['丶茶']='丶茶剎灬:BAABLAAFFH8GAAIGAAYInBA1IgBNAQAGAAYInBA1IgBNAQAAAA==.',['主城']='主城特级保安:BAAALAAECgYICAAAAA==.',['事后']='事后清晨:BAAALAAFFAIIAgAAAA==.',['二号']='二号萨满:BAABLAAFFH8QAAIGAAgIrSB5AQACAwAGAAgIrSB5AQACAwAAAA==.',['二费']='二费零杠七:BAAALAAFFAgIAgAAAA==.',['云知']='云知兰:BAABLAAFFH8VAAICAAUI0QpmSQATAQACAAUI0QpmSQATAQAAAA==.',['伊利']='伊利蛋怒日:BAAALAAECgYIBgAAAA==.',['伊地']='伊地知虹夏:BAAALAAFFAIIAgAAAA==.',['伊瑞']='伊瑞尔丶影歌:BAABLAAFFH8GAAIIAAIIhBR4ZQBEAAAIAAIIhBR4ZQBEAAAAAA==.',['传功']='传功第九年:BAAALAAECgEIAQAAAA==.传功第八年:BAAALAAECgIIAgAAAA==.',['伢伢']='伢伢:BAABLAAFFH8OAAIBAAgIPxpMCAB6AgABAAgIPxpMCAB6AgAAAA==.',['六位']='六位帝王玩:BAAALAAECgYIBgAAAA==.',['兰慕']='兰慕:BAAALAAECgIIAgAAAA==.',['冰墩']='冰墩墩:BAABLAAFFH8MAAIGAAIIKA1EYQBaAAAGAAIIKA1EYQBaAAABLAAFFAIIEwABAJkQAA==.',['出门']='出门要戴口罩:BAAALAAECgEIAQAAAA==.',['别跟']='别跟我喵喵叫:BAABLAAFFH8IAAMJAAIIwQcNTwBVAAAJAAIIwQcNTwBVAAAKAAEIsAXXQwAAAAAAAA==.',['加丶']='加丶尔丶鲁什:BAAALAAFFAIIAgAAAA==.',['匆匆']='匆匆:BAAALAADCggICAAAAA==.',['北之']='北之:BAABLAAFFH8KAAICAAIIYBwfSQCnAAACAAIIYBwfSQCnAAAAAA==.',['单刷']='单刷尼姑庵:BAAALAAECgMIAwAAAA==.',['南多']='南多一幸子:BAAALAADCgIIAgAAAA==.',['吉薇']='吉薇艾儿:BAAALAAECgMIAwAAAA==.',['哦呦']='哦呦呦:BAAALAAFFAQIBAAAAA==.',['啸天']='啸天龙:BAACLAAFFH8TAAIBAAIImRA7WgBFAAABAAIImRA7WgBFAAAsAAQKfxwAAgEABggIFX99AIYBAAEABggIFX99AIYBAAAA.',['喝杯']='喝杯娃哈哈:BAACLAAFFH8IAAMBAAQIyxmfJgDyAAABAAMIfxyfJgDyAAALAAEIrxG0IgBcAAAsAAQKfx0AAwEACAiEIJ4oAKECAAEACAg5H54oAKECAAsAAghgHLlzAKoAAAAA.',['噗嘻']='噗嘻:BAAALAAECgYICgAAAA==.',['噢咔']='噢咔:BAABLAAFFH8IAAMIAAYI/hL0IABkAQAIAAYI/hL0IABkAQAMAAIIfgleJAB7AAAAAA==.',['图拉']='图拉玛:BAAALAAECgcIBwAAAA==.',['土里']='土里土气:BAAALAAFFAIIBAAAAA==.',['土鸡']='土鸡:BAAALAADCgYIBgAAAA==.',['墨鱼']='墨鱼假心:BAAALAAFFAYIAgAAAA==.',['夜雨']='夜雨漲秋池:BAAALAAECggICAAAAA==.夜雨迷途:BAAALAAECggIDgAAAA==.',['大星']='大星术师谷歌:BAABLAAFFH8QAAIBAAgIvRvhCABxAgABAAgIvRvhCABxAgAAAA==.',['大爷']='大爷丶太爷:BAAALAAECgYIDAAAAA==.',['奶萨']='奶萨不划水:BAAALAADCggICAAAAA==.',['好运']='好运风筝:BAAALAAECgUIBQAAAA==.',['如烟']='如烟丨大帝:BAAALAAECgYIDgAAAA==.',['妖一']='妖一一:BAAALAAECggIBgAAAA==.',['妖之']='妖之林:BAAALAAECgYIBgAAAA==.',['孤狼']='孤狼丶独舞:BAAALAADCgIIAgAAAA==.',['寐丶']='寐丶:BAAALAAECgYIDAAAAA==.',['小困']='小困包:BAABLAAFFH8IAAINAAIIdhikmABBAAANAAIIdhikmABBAAAAAA==.',['小小']='小小骑士牧:BAAALAAFFAEIAQAAAA==.',['小煤']='小煤气罐子:BAAALAAECgIIAgAAAA==.',['小牛']='小牛宝莉:BAACLAAFFH8qAAMOAAYIyCLlBgDZAQAOAAYIyCLlBgDZAQAPAAUIjRUbJQBIAQAsAAQKfxcAAg4ACAg9HCYdAEkCAA4ACAg9HCYdAEkCAAAA.',['小铁']='小铁:BAABLAAFFH8KAAICAAIImiUnOwC7AAACAAIImiUnOwC7AAAAAA==.',['小铭']='小铭丶:BAAALAAECgEIAQAAAA==.',['小露']='小露娜打怪兽:BAAALAAECgIIAgAAAA==.',['小鸡']='小鸡哔哔呦:BAAALAAECggICAAAAA==.',['小黄']='小黄莺:BAAALAAECgIIAgAAAA==.',['尘归']='尘归尘土归土:BAAALAAECgYIBgAAAA==.',['山里']='山里灵活的苟:BAAALAAECgcIBwAAAA==.',['帅过']='帅过后的翻唱:BAABLAAECn8XAAIQAAYImgZKXwD3AAAQAAYImgZKXwD3AAAAAA==.',['希尔']='希尔瓦娜丝:BAAALAAECgEIAQAAAA==.',['希瓦']='希瓦斯:BAAALAAECgYIDAAAAA==.',['幺幺']='幺幺泠:BAABLAAFFH8FAAIIAAIIQx18KgC0AAAIAAIIQx18KgC0AAAAAA==.',['幽灵']='幽灵虎:BAABLAAFFH8KAAIFAAYIbxrmEwBTAQAFAAYIbxrmEwBTAQAAAA==.',['弦千']='弦千钧:BAAALAAFFAIIAgAAAA==.',['强尼']='强尼德普:BAAALAAECgQIBgAAAA==.',['德之']='德之助:BAAALAADCgcIBwAAAA==.',['总之']='总之很可爱:BAAALAAFFAIIAgABLAAFFAYIEAAIAOALAA==.',['情字']='情字何解:BAAALAADCgYIBgAAAA==.',['情绪']='情绪中毒:BAAALAADCgIIAgAAAA==.情绪乀中毒:BAAALAAFFAIIAgAAAA==.',['我只']='我只负责萌丶:BAAALAAFFAIIAgAAAA==.',['扛起']='扛起灬加特林:BAAALAAFFAQIAQAAAA==.',['抓个']='抓个咕咕:BAAALAAECgUIBQAAAA==.',['抓抓']='抓抓小益益:BAAALAAECggICAAAAA==.',['抖胸']='抖胸奶四方:BAAALAAECgEIAQAAAA==.',['抠了']='抠了多放点:BAAALAAFFAIIBAAAAA==.',['放下']='放下那根竹子:BAAALAAECgcICgAAAA==.',['放心']='放心:BAAALAAECgIIAgAAAA==.',['救了']='救了一车人:BAAALAAECgYIBgAAAA==.',['文突']='文突苏立:BAAALAAFFAIIBAAAAA==.',['无则']='无则无忧:BAAALAAECgIIAgAAAA==.',['无畏']='无畏红牛:BAAALAADCgEIAQAAAA==.',['日暮']='日暮瞎:BAABLAAFFH8GAAIFAAIIMh4JLwCrAAAFAAIIMh4JLwCrAAAAAA==.',['星辰']='星辰大海:BAACLAAFFH8MAAIKAAUIkRhvCAC0AQAKAAUIkRhvCAC0AQAsAAQKfxgAAgoABwhdHrUnAC8CAAoABwhdHrUnAC8CAAEsAAUUBggtABAAfxgA.',['暗影']='暗影丶舞动:BAAALAADCgEIAQAAAA==.',['最後']='最後的戰役丶:BAAALAADCgYIBgAAAA==.',['杰瑞']='杰瑞雪暴:BAAALAAECgYIBgAAAA==.',['椭奇']='椭奇:BAABLAAFFH8GAAIBAAYIHRy7IACaAQABAAYIHRy7IACaAQAAAA==.',['楚们']='楚们的世界:BAAALAAECgYIDwAAAA==.',['楚将']='楚将养由基:BAABLAAFFH8SAAINAAIIzRZ0jwBFAAANAAIIzRZ0jwBFAAABLAAFFAIIEwABAJkQAA==.',['楚霸']='楚霸王:BAABLAAFFH8KAAIRAAIIMxXvBABKAAARAAIIMxXvBABKAAABLAAFFAIIEwABAJkQAA==.',['武音']='武音李斯特:BAAALAAECgYIBgABLAAFFAYIEgACAOsEAA==.',['水滴']='水滴水:BAABLAAFFH8GAAISAAIIThRMBwB6AAASAAIIThRMBwB6AAAAAA==.',['水饺']='水饺大米小米:BAAALAAECgYIEwAAAA==.',['汤加']='汤加:BAABLAAFFH8FAAMIAAMIQxoIOwCtAAAIAAMIfxgIOwCtAAATAAII/BFOHQAwAAAAAA==.',['沉香']='沉香逐梦:BAAALAAECggIBgAAAA==.',['沸腾']='沸腾的七喜:BAAALAAECgIIAgABLAAECgYIBgAUAAAAAA==.',['法象']='法象天地:BAAALAAECgMIBwAAAA==.',['涵德']='涵德桑博一:BAAALAAECgIIAgAAAA==.',['溧阳']='溧阳人民广场:BAABLAAFFH8WAAIOAAYIxQ4bFQAUAQAOAAYIxQ4bFQAUAQAAAA==.',['澄澄']='澄澄:BAABLAAFFH8IAAIIAAIIQCbhSQByAAAIAAIIQCbhSQByAAAAAA==.',['灬澄']='灬澄澄灬:BAAALAAECgYIBgAAAA==.',['炉石']='炉石搓冒烟:BAAALAAFFAMIAwAAAA==.',['烈风']='烈风语者:BAAALAAECgUIBQAAAA==.',['烟蝶']='烟蝶:BAABLAAFFH8HAAIBAAII6QdUawA1AAABAAII6QdUawA1AAAAAA==.',['烟雨']='烟雨婉琉璃:BAAALAAECgMIAwAAAA==.烟雨旧:BAAALAAECgYIBgAAAA==.',['烧烧']='烧烧:BAABLAAFFH8KAAILAAIIwgWqFwA6AAALAAIIwgWqFwA6AAAAAA==.',['爱丽']='爱丽丝:BAABLAAFFH8GAAIIAAYIFRPjHAB6AQAIAAYIFRPjHAB6AQAAAA==.',['爱宕']='爱宕:BAAALAAECgYIDAAAAA==.',['爱情']='爱情来了:BAAALAAFFAEIAQAAAA==.',['爱谁']='爱谁谁丶:BAAALAAECgQIBAAAAA==.',['爱魔']='爱魔力轉圈圈:BAAALAADCgYIBgAAAA==.',['牛计']='牛计吧:BAAALAAFFAIIAgAAAA==.',['狂撸']='狂撸圣手:BAAALAAECgQIBAAAAA==.',['猎祖']='猎祖烈宗:BAACLAAFFH8eAAMNAAYImxvsLACDAQANAAYImxvsLACDAQAVAAMIlA77DgCIAAAsAAQKfxgAAw0ABggqIGRwAPsBAA0ABgieHWRwAPsBABUABgjqF/YUAAUBAAAA.',['猫咪']='猫咪公主:BAAALAADCgUIBQAAAA==.',['王建']='王建掴:BAAALAAFFAMIAwAAAA==.',['王球']='王球小球球:BAABLAAFFH8KAAIQAAIIQQ3HGgA7AAAQAAIIQQ3HGgA7AAABLAAFFAIIEwABAJkQAA==.',['王雷']='王雷的懒趴:BAABLAAFFH8KAAICAAYIyw0yDwDcAQACAAYIyw0yDwDcAQAAAA==.',['玛格']='玛格汉堡:BAAALAADCgEIAQAAAA==.',['甜甜']='甜甜豆腐脑:BAACLAAFFH8FAAIWAAIIMBbuOAB+AAAWAAIIMBbuOAB+AAAsAAQKfxcAAhYABgh1IHIZAPQBABYABgh1IHIZAPQBAAAA.',['疤脸']='疤脸:BAAALAAECgYIBgAAAA==.',['白天']='白天睡得香:BAAALAAECggIDgAAAA==.',['白葡']='白葡萄青提:BAABLAAFFH8GAAICAAYIsRUwLwB/AQACAAYIsRUwLwB/AQAAAA==.',['白蹄']='白蹄子萌萌:BAAALAAECggICAAAAA==.',['直直']='直直丶:BAAALAADCgEIAQAAAA==.',['神兆']='神兆:BAAALAADCggICAAAAA==.',['第三']='第三天使月城:BAACLAAFFH8QAAIQAAgIKgyeBwAoAQAQAAgIKgyeBwAoAQAsAAQKfyMAAhAACAinF3YQAL0BABAACAinF3YQAL0BAAAA.',['糖小']='糖小棋:BAAALAAECgYICgAAAA==.',['糖糖']='糖糖小脑瓜:BAAALAAFFAIIAgAAAA==.',['紫罗']='紫罗兰学徒:BAAALAAECgUIBQAAAA==.',['红丶']='红丶爵:BAAALAAFFAIIAwAAAA==.',['红桃']='红桃誒:BAAALAAFFAIIAgAAAA==.',['红炉']='红炉点雪:BAAALAAECgYIBgAAAA==.',['红色']='红色莫里哀:BAAALAAECggICAAAAA==.',['终極']='终極刺客:BAABLAAFFH8KAAIFAAIIqAfLVACHAAAFAAIIqAfLVACHAAAAAA==.',['给我']='给我吃一口:BAABLAAFFH8GAAIBAAIIfxYPXABDAAABAAIIfxYPXABDAAAAAA==.',['肥嘟']='肥嘟嘟右卫门:BAAALAAECgIIAgAAAA==.',['肯德']='肯德基:BAAALAAECgYIBgAAAA==.',['胡莉']='胡莉晶:BAAALAAECgYICAAAAA==.',['脆脆']='脆脆鲨:BAACLAAFFH83AAIIAAYIAyO6CAADAgAIAAYIAyO6CAADAgAsAAQKfxcAAwgACAjDIohTAEcCAAgACAgMIIhTAEcCABMAAghFJiEnANwAAAAA.',['致命']='致命红玫瑰:BAABLAAFFH8IAAINAAgIjw0jFwDeAQANAAgIjw0jFwDeAQAAAA==.',['花斑']='花斑蚊:BAABLAAFFH8JAAIPAAII1hhGMACeAAAPAAII1hhGMACeAAAAAA==.',['花有']='花有重开日:BAAALAAECgUIBQAAAA==.',['花灬']='花灬花花:BAAALAAECgYIBgAAAA==.',['若叶']='若叶睦:BAABLAAFFH8SAAIXAAYI4BQYDABgAQAXAAYI4BQYDABgAQAAAA==.',['范海']='范海辛灬神羿:BAABLAAFFH8MAAINAAIIVhO7gwBPAAANAAIIVhO7gwBPAAAAAA==.',['草摩']='草摩信伊:BAAALAAECgIIAgAAAA==.',['莉莉']='莉莉维斯:BAAALAAECgQIBAAAAA==.',['菲力']='菲力:BAAALAAECgYICgAAAA==.',['萌新']='萌新角斗士:BAAALAAECgEIAQAAAA==.',['萨拉']='萨拉塔斯娜:BAAALAAECgUIBQAAAA==.',['萨鲁']='萨鲁法灬尔:BAABLAAFFH8FAAICAAMIEgfwaAB0AAACAAMIEgfwaAB0AAAAAA==.',['蛇形']='蛇形貂手:BAAALAADCgIIAgAAAA==.',['蛮牛']='蛮牛:BAACLAAFFH8MAAIJAAIIaQbnUABTAAAJAAIIaQbnUABTAAAsAAQKfxkAAwoABgghEUIwAAYBAAoABgghEUIwAAYBAAkAAwiwCm3HAHYAAAEsAAUUAggTAAEAmRAA.',['蟑螂']='蟑螂恶霸:BAAALAAECgYIBgAAAA==.',['贵阳']='贵阳小丁哥乄:BAAALAAECgYICgAAAA==.',['赚钱']='赚钱摸扎丶:BAAALAADCgMIAwAAAA==.',['踏雪']='踏雪寻猫:BAAALAAECgYIBgAAAA==.',['辶周']='辶周賈凊樣:BAAALAAECgYIBgAAAA==.',['退钱']='退钱:BAAALAAECgYIBgAAAA==.',['那些']='那些年丶执着:BAAALAAECgYIEAAAAA==.',['酱焖']='酱焖牛至:BAACLAAFFH8uAAMNAAYIIR46DwC2AQANAAYIIR46DwC2AQAVAAMIfherEwDJAAAsAAQKfzMAAw0ACAiUIr87AHMCABUACAjdIDIeAHUCAA0ACAidHb87AHMCAAAA.',['银月']='银月小狼:BAAALAAECgQIBAAAAA==.',['闪电']='闪电掉链子:BAAALAAECgMIAwAAAA==.',['阿尔']='阿尔寿司:BAAALAADCgUIBQAAAA==.',['陈小']='陈小狗:BAAALAAECgYIDAAAAA==.',['陈都']='陈都灵:BAAALAAECgMIAwAAAA==.',['雅丽']='雅丽马斯内:BAAALAADCgEIAQAAAA==.',['集合']='集合石的朋友:BAABLAAFFH8GAAINAAYIih2wBAA2AgANAAYIih2wBAA2AgAAAA==.',['難葙']='難葙莣慾楿守:BAAALAAECgYICAAAAA==.',['露娜']='露娜老牛猎:BAAALAADCgQIBAAAAA==.',['霹雳']='霹雳波波:BAAALAAECgMIBAAAAA==.',['风暴']='风暴降生龙妈:BAABLAAFFH8FAAIWAAIItgB7TgA/AAAWAAIItgB7TgA/AAAAAA==.',['风起']='风起:BAAALAAECgQIBAAAAA==.',['马兰']='马兰小妖怪:BAAALAADCgIIAgAAAA==.',['魅魔']='魅魔克丽丝:BAABLAAECn8UAAIYAAYIwQ9+JABDAQAYAAYIwQ9+JABDAQAAAA==.',['魔法']='魔法披风:BAAALAAFFAgIBAAAAA==.',['鱼鱼']='鱼鱼老公:BAAALAAFFAMIAwAAAA==.',['鹤嵬']='鹤嵬冬:BAAALAAECgIIAgAAAA==.',['麻烦']='麻烦:BAABLAAECn8YAAIIAAYIDxKsygB4AQAIAAYIDxKsygB4AQAAAA==.',['龙鳞']='龙鳞马:BAABLAAFFH8GAAIEAAYIVxkiJwB4AQAEAAYIVxkiJwB4AQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end