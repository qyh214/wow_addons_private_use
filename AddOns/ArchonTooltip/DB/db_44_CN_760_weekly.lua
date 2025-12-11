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
 local lookup = {'Shaman-Restoration','Warrior-Protection','DemonHunter-Vengeance','Priest-Holy','DeathKnight-Frost','Warrior-Fury','DeathKnight-Unholy','Paladin-Retribution','Hunter-Marksmanship','DeathKnight-Blood','Druid-Restoration','Druid-Balance','Paladin-Holy','Unknown-Unknown','Hunter-BeastMastery','Warlock-Demonology','Warlock-Destruction','Shaman-Elemental','Mage-Arcane','Druid-Feral','Monk-Mistweaver','Rogue-Assassination','Rogue-Subtlety','Druid-Guardian','Priest-Shadow','DemonHunter-Havoc','Monk-Windwalker','Evoker-Devastation','Monk-Brewmaster','Mage-Frost','Priest-Discipline','Paladin-Protection','Warrior-Arms',}; local provider = {region='CN',realm='玛瑟里顿',name='CN',type='weekly',zone=44,date='2025-12-06',data={Al='Alzard:BAABLAAFFH8KAAIBAAII6RayPQCFAAABAAII6RayPQCFAAAAAA==.',Ap='Aphródite:BAAALAAECgYIBgAAAA==.',At='Athenamagic:BAAALAAFFAIIAgAAAA==.',Ba='Batonuth:BAAALAAECgQIBAAAAA==.',Bf='Bfate:BAAALAAFFAIIAgAAAA==.',Bi='Bigsun:BAABLAAFFH8IAAICAAIIJgkQLABkAAACAAIIJgkQLABkAAAAAA==.',Da='Dante:BAAALAAECgQIBQAAAA==.Dari:BAABLAAFFH8GAAIDAAIIPwxAFQBfAAADAAIIPwxAFQBfAAAAAA==.',De='Deepsea:BAABLAAFFH8GAAICAAIIdwE6MQBJAAACAAIIdwE6MQBJAAAAAA==.',Ea='Earlylilac:BAAALAADCggICgAAAA==.',Ev='Evolution:BAAALAAECgYIBgAAAA==.',Ff='Ffray:BAABLAAFFH8GAAIEAAYIfwbKCgCkAQAEAAYIfwbKCgCkAQAAAA==.',Fg='Fgsgegw:BAACLAAFFH8GAAIDAAIIKQJFGwBEAAADAAIIKQJFGwBEAAAsAAQKfxgAAgMABwiKCig7AP0AAAMABwiKCig7AP0AAAAA.',Go='Goél:BAAALAAECgYIBgAAAA==.',Ij='Ijokeri:BAAALAAECgYIBgAAAA==.',In='Infiltration:BAACLAAFFH8KAAIBAAIIwhJbTwBsAAABAAIIwhJbTwBsAAAsAAQKfy4AAgEACAj1EZhqAK8BAAEACAj1EZhqAK8BAAAA.',Ip='Iphone:BAAALAAECgIIAgAAAA==.',Is='Ishtar:BAAALAAFFAIIBAAAAA==.',Jo='Jokers:BAABLAAECn8UAAIFAAYI7Rp9oADGAQAFAAYI7Rp9oADGAQAAAA==.Jokey:BAAALAADCgYIBgAAAA==.',Ma='Martin:BAAALAAECgYIDgAAAA==.',Me='Metiss:BAAALAAFFAIIAgAAAA==.',Mo='Momosr:BAAALAAFFAIIBAAAAA==.Momoya:BAAALAAECgYICwAAAA==.',My='Myriad:BAAALAAECgIIAgAAAA==.Mythlatiis:BAAALAAECgUIBgAAAA==.',No='Nobodys:BAAALAAECgYIBgAAAA==.',Or='Orcwarrior:BAAALAAFFAIIAgAAAA==.',Pa='Paim:BAAALAAFFAIIAgAAAA==.',Re='Realme:BAAALAAECgMIAwAAAA==.',Ro='Rosemouth:BAAALAADCgQIBwAAAA==.',Ru='Rushsun:BAAALAADCggICAAAAA==.',Sc='Scotti:BAAALAAFFAIIBAAAAA==.',Sh='Shadowalker:BAAALAAFFAIIAgAAAA==.Shadowslash:BAAALAADCgMIAwAAAA==.',Sl='Slyb:BAABLAAFFH8NAAICAAMIwQXiJQBQAAACAAMIwQXiJQBQAAAAAA==.',So='Souler:BAAALAAFFAIIBAAAAA==.',Su='Sunday:BAAALAAFFAIIAgAAAA==.Sunny:BAAALAAFFAIIAgAAAA==.',Th='Theas:BAACLAAFFH8GAAICAAIIfwsUMgAwAAACAAIIfwsUMgAwAAAsAAQKfxkAAwIABgg5E/YoAAgBAAIABgg5E/YoAAgBAAYABgizCYxhAPEAAAAA.',Tk='Tklord:BAABLAAFFH8GAAIHAAIIphPQFQB9AAAHAAIIphPQFQB9AAAAAA==.',To='Tonylemon:BAABLAAFFH8GAAIFAAYIDRqRKgCNAQAFAAYIDRqRKgCNAQABLAAFFAcIIwAIALIgAA==.',Ty='Tyland:BAAALAAFFAIIBAAAAA==.',Ul='Ultramany:BAABLAAFFH8GAAIFAAIIzh7SSQCmAAAFAAIIzh7SSQCmAAAAAA==.',Va='Vampiream:BAAALAAECggIAgABLAAFFAQICAAJAJ4WAA==.',Vi='Vitamine:BAAALAAFFAIIAgAAAA==.',Vu='Vuoto:BAAALAAECgMIAwAAAA==.',Wq='Wqzyyds:BAABLAAFFH8zAAIGAAYIJyOEDQDtAQAGAAYIJyOEDQDtAQAAAA==.',['Wé']='Wéissmel:BAABLAAFFH8PAAMFAAMIBwsMaAB3AAAFAAMIBwsMaAB3AAAKAAIIcAM+FgBZAAAAAA==.',Ye='Yey:BAAALAAECgQIBAAAAA==.',['一个']='一个梦想:BAAALAAECgIIAgAAAA==.',['一千']='一千零一个瓜:BAACLAAFFH8JAAMLAAYIGxVvEwCgAQALAAYIGxVvEwCgAQAMAAMI4hsIIgCkAAAsAAQKfxUAAgsABgiMGoQqAIwBAAsABgiMGoQqAIwBAAAA.',['丁浩']='丁浩:BAAALAAECgYIBgAAAA==.',['七月']='七月小恶魔:BAAALAAFFAIIBAAAAA==.',['不倒']='不倒大怪兽:BAAALAADCgEIAQAAAA==.',['不是']='不是我不小心:BAAALAAECgYIBgAAAA==.',['专踹']='专踹瘸子好腿:BAACLAAFFH8NAAIIAAMIuxcqQQCRAAAIAAMIuxcqQQCRAAAsAAQKfzEAAwgABghsGUxcAE4BAAgABghsGUxcAE4BAA0ABQibC+BUAAABAAAA.',['东南']='东南么么:BAAALAADCgcIBwAAAA==.东南狂飙:BAAALAADCgQIBAAAAA==.',['两学']='两学一坐:BAABLAAFFH8eAAIFAAYIdh1TJACjAQAFAAYIdh1TJACjAQAAAA==.',['丨莉']='丨莉莉娅丨:BAACLAAFFH8QAAIIAAQIOBLjNQDSAAAIAAQIOBLjNQDSAAAsAAQKfxgAAggABgg4ELzfAFoBAAgABgg4ELzfAFoBAAAA.',['丷小']='丷小幸运丷:BAAALAAFFAYIBAAAAA==.',['丹青']='丹青化五灵:BAAALAAECggICwAAAA==.',['乖猫']='乖猫:BAAALAADCgUIBQAAAA==.',['亲爱']='亲爱滴鬼鬼:BAAALAAECgYIBgABLAAFFAgIAQAOAAAAAA==.',['人鱼']='人鱼骷髅:BAABLAAFFH8FAAIPAAIIrRZIjABHAAAPAAIIrRZIjABHAAAAAA==.',['今夕']='今夕明月:BAACLAAFFH8KAAIIAAIIDhZbPwCfAAAIAAIIDhZbPwCfAAAsAAQKfxQAAggABggwG2yfALgBAAgABggwG2yfALgBAAAA.',['付丧']='付丧神:BAACLAAFFH8LAAIFAAMIQRmrPwCzAAAFAAMIQRmrPwCzAAAsAAQKfxUAAgUABgjgIhJRAFYCAAUABgjgIhJRAFYCAAAA.',['仙女']='仙女不讲李:BAAALAAECgcIDQAAAA==.',['伊方']='伊方:BAAALAAECgIIAgAAAA==.',['但丁']='但丁魔剑:BAAALAAECgQIBQAAAA==.但丁魔箭:BAAALAADCgIIAwAAAA==.',['你不']='你不配被治疗:BAABLAAECn8eAAMQAAYIbSFaHQATAgARAAYIGh+eRAAoAgAQAAYIax9aHQATAgAAAA==.',['假笑']='假笑扮从容:BAAALAADCgMIAwAAAA==.',['元素']='元素恢复增强:BAABLAAFFH8HAAISAAIIZgZ6SQA+AAASAAIIZgZ6SQA+AAAAAA==.',['先祖']='先祖忽悠了你:BAAALAAFFAIIAgAAAA==.',['公主']='公主一号:BAABLAAECn8XAAIPAAYIyiCpRAC/AQAPAAYIyiCpRAC/AQAAAA==.',['冯欣']='冯欣然:BAAALAAFFAIIAgAAAA==.',['冰焱']='冰焱妩魅:BAACLAAFFH8MAAIEAAMIhwocNQCRAAAEAAMIhwocNQCRAAAsAAQKfxQAAgQACAjDEjFBANIBAAQACAjDEjFBANIBAAAA.',['冰祭']='冰祭:BAABLAAFFH8WAAIEAAYIoRStFgCdAQAEAAYIoRStFgCdAQAAAA==.',['冰霜']='冰霜小鲤鱼:BAABLAAECn8ZAAMPAAgIuQ0JqAAOAQAPAAcIng4JqAAOAQAJAAYIygWSgwDQAAAAAA==.',['冰魂']='冰魂割裂者:BAAALAAFFAIIAgAAAA==.',['冰魄']='冰魄炎舞:BAAALAAECgYIDAAAAA==.',['冲他']='冲他:BAAALAAECgQIBAAAAA==.',['冷艳']='冷艳流星锤:BAAALAAECgYIBgAAAA==.',['凌寒']='凌寒祭歌:BAAALAAFFAMIBAAAAA==.',['凌小']='凌小皮:BAAALAAECgYIDQAAAA==.',['前世']='前世是三大爷:BAABLAAFFH8GAAIFAAIIVhOEggBEAAAFAAIIVhOEggBEAAAAAA==.前世是帅哥:BAAALAAFFAIIBAAAAA==.前世是眉女:BAAALAAECgQIBAAAAA==.',['前方']='前方高能:BAAALAAECgMIAwAAAA==.',['剑舞']='剑舞:BAAALAAECgMIAwAAAA==.',['剑风']='剑风传奇:BAAALAAECgYIDAAAAA==.',['动感']='动感大帅锅:BAAALAADCgQIBAAAAA==.',['努力']='努力的小白:BAAALAAECggICAAAAA==.',['匕空']='匕空之歌:BAAALAADCgYIBgAAAA==.',['北极']='北极熊:BAAALAAFFAEIAQAAAA==.',['十二']='十二月的小米:BAAALAADCgYIBgAAAA==.',['卖茉']='卖茉莉的熊貮:BAAALAAECgYIBgAAAA==.',['南玻']='南玻万:BAAALAAECgMIAwAAAA==.',['原初']='原初祈求着:BAABLAAFFH8GAAILAAIIehGsMwBtAAALAAIIehGsMwBtAAAAAA==.',['又要']='又要改名字:BAAALAAFFAIIAwAAAA==.',['发光']='发光的眼:BAAALAAECgYIBgAAAA==.',['吉祥']='吉祥:BAABLAAECn8UAAITAAYIayA1GgDXAQATAAYIayA1GgDXAQAAAA==.',['呕像']='呕像大尸:BAAALAAECgEIAQAAAA==.',['周防']='周防有希:BAAALAAECgcIDQAAAA==.',['咸味']='咸味生活:BAAALAAFFAIIAgAAAA==.',['哈基']='哈基猎手:BAAALAADCgIIAgAAAA==.',['哦索']='哦索快点:BAAALAADCgIIAgAAAA==.',['啊差']='啊差:BAAALAAECgYIBgAAAA==.',['喏喏']='喏喏:BAAALAAFFAIIAwAAAA==.',['喳哥']='喳哥来也:BAACLAAFFH8RAAILAAMIXBSYKgDGAAALAAMIXBSYKgDGAAAsAAQKfyoABAsABwijECVEAAcBAAsABwijECVEAAcBAAwABAh7D0FLAIkAABQAAgikC0oiAFUAAAAA.',['喵灬']='喵灬喵灬喵:BAABLAAFFH8FAAISAAIIXQ3WSgA8AAASAAIIXQ3WSgA8AAAAAA==.',['土之']='土之元素:BAACLAAFFH8HAAISAAQIVQ0ILgDGAAASAAQIVQ0ILgDGAAAsAAQKfxUAAwEACAgpGJo+ACICAAEACAgpGJo+ACICABIABgjvGMtRAMQBAAAA.',['圣休']='圣休亚瑞:BAAALAAFFAIIBAAAAA==.',['圣光']='圣光发菜:BAAALAAECgYIBgAAAA==.圣光银神:BAAALAAECgYIBgAAAA==.',['堕落']='堕落老黄牛:BAABLAAFFH8IAAIGAAgIFAbSKgASAQAGAAgIFAbSKgASAQAAAA==.',['壹叁']='壹叁伍:BAABLAAFFH8GAAIFAAIIWxW5YACYAAAFAAIIWxW5YACYAAAAAA==.',['夏打']='夏打盹儿:BAABLAAECn8ZAAIMAAgIIxo2DgAbAgAMAAgIIxo2DgAbAgAAAA==.',['夕岚']='夕岚:BAABLAAFFH8IAAIVAAQIcQsWDwDWAAAVAAQIcQsWDwDWAAAAAA==.',['夜夜']='夜夜笙歌:BAABLAAFFH8WAAIWAAUImBZOCwBaAQAWAAUImBZOCwBaAQAAAA==.',['夜影']='夜影之刃:BAABLAAFFH8KAAIDAAII8AoQFwAoAAADAAII8AoQFwAoAAAAAA==.夜影之刺:BAACLAAFFH8JAAIWAAIIYxBNGACeAAAWAAIIYxBNGACeAAAsAAQKfyEAAxYABgjPGsAkAPMBABYABgjPGsAkAPMBABcABgieEZ8NAC8BAAAA.夜影之歌:BAACLAAFFH8MAAMUAAYI3Q0VBQBfAQAUAAYI3Q0VBQBfAQAYAAIIjg3FDgApAAAsAAQKfx4AAxQABgi6IcYGAPIBABQABgi6IcYGAPIBAAsABAhCIXSFABEBAAAA.夜影之谕:BAACLAAFFH8IAAIEAAIIgBpANACWAAAEAAIIgBpANACWAAAsAAQKfyAAAwQABgg9Hz4WABQCAAQABgg9Hz4WABQCABkABggqDgYpAAIBAAEsAAUUCAgRAAQARBoA.夜影之锋:BAABLAAFFH8GAAIPAAIIZhfMkABEAAAPAAIIZhfMkABEAAAAAA==.',['夜猎']='夜猎:BAAALAAFFAYIBAAAAA==.',['夜色']='夜色中变态:BAABLAAFFH8YAAIMAAYIWhNYFABAAQAMAAYIWhNYFABAAQAAAA==.',['夜魔']='夜魔:BAAALAAECgUICQAAAA==.',['大一']='大一大万大吉:BAACLAAFFH8VAAIVAAQI2RB9DgDnAAAVAAQI2RB9DgDnAAAsAAQKfyEAAhUABgiPIcIUAC0CABUABgiPIcIUAC0CAAAA.',['大主']='大主教格蕾雅:BAAALAAECgYIBgAAAA==.',['大劈']='大劈叉:BAAALAAFFAIIBAAAAA==.',['大圣']='大圣光给你嗦:BAAALAAECgIIAgAAAA==.',['大懒']='大懒子:BAAALAAFFAIIAgAAAA==.',['大窃']='大窃能者阿方:BAAALAAECgUIBQAAAA==.',['大胡']='大胡:BAAALAADCgQIBAAAAA==.',['大风']='大风车崴脚:BAACLAAFFH8MAAIFAAIIzxZxYgCXAAAFAAIIzxZxYgCXAAAsAAQKfyEAAgUACAj6Gz5BAH0CAAUACAj6Gz5BAH0CAAAA.',['天地']='天地会总舵主:BAAALAAECgQIBQAAAA==.',['天域']='天域彗星:BAABLAAFFH8GAAIRAAYI7gxaEQDZAQARAAYI7gxaEQDZAQAAAA==.',['天崩']='天崩地裂:BAABLAAFFH8MAAISAAYIyg7YIAA6AQASAAYIyg7YIAA6AQAAAA==.',['天涯']='天涯冷血:BAACLAAFFH8wAAMGAAYI9CB/DwDcAQAGAAYI9CB/DwDcAQACAAEIPgvEMgAwAAAsAAQKfx8AAwYACAh3Ht41AF4CAAYACAh3Ht41AF4CAAIAAQgnEnOYADEAAAAA.天涯若风:BAACLAAFFH8KAAIJAAIIXgzVJwB4AAAJAAIIXgzVJwB4AAAsAAQKfy0AAgkACAixHLkaAI4CAAkACAixHLkaAI4CAAAA.天涯银霸:BAAALAAECgUIBQAAAA==.',['奎师']='奎师那:BAACLAAFFH8QAAIIAAIIryNNJwC7AAAIAAIIryNNJwC7AAAsAAQKfxYAAggABwjuIuckAAMCAAgABwjuIuckAAMCAAAA.',['奥古']='奥古西斯:BAAALAAFFAIIAgAAAA==.',['奥术']='奥术光辉:BAAALAAECggICAAAAA==.',['奥能']='奥能烧卖:BAAALAAFFAIIAgAAAA==.',['奶的']='奶的很疼:BAABLAAFFH8IAAIEAAIIxQGrSwBNAAAEAAIIxQGrSwBNAAAAAA==.',['如果']='如果炣以:BAABLAAFFH8KAAIaAAYIuAz/JABlAQAaAAYIuAz/JABlAQAAAA==.',['妖狐']='妖狐:BAAALAAECgYIEQAAAA==.',['孤月']='孤月残心:BAAALAADCgMIAwAAAA==.',['孤独']='孤独荒野猎:BAAALAADCgIIAgAAAA==.',['宋轶']='宋轶:BAAALAADCgYIBgAAAA==.',['宝宝']='宝宝要你命:BAABLAAECn8UAAIaAAYIcxcmPABqAQAaAAYIcxcmPABqAQAAAA==.',['审判']='审判之光:BAAALAAECgMIAwAAAA==.',['小丑']='小丑:BAAALAAECgEIAQAAAA==.',['小呆']='小呆哈哈:BAABLAAFFH8FAAIRAAMI5QsPTQCGAAARAAMI5QsPTQCGAAAAAA==.',['小头']='小头:BAABLAAFFH8KAAIaAAII/ha2NwCgAAAaAAII/ha2NwCgAAAAAA==.',['小小']='小小帅种子:BAAALAAFFAIIBAAAAA==.',['小幸']='小幸运灬筱悠:BAAALAAECgYIDAAAAA==.小幸运灬筱筱:BAABLAAFFH8GAAIRAAIIzwe5UgB6AAARAAIIzwe5UgB6AAAAAA==.',['小方']='小方子:BAABLAAFFH8IAAIFAAgIgh/JBQChAgAFAAgIgh/JBQChAgAAAA==.',['小猪']='小猪的叹息:BAAALAAECgMIAwAAAA==.小猪的悲伤:BAAALAAECgYICQAAAA==.',['小白']='小白兔丁丁:BAAALAAECgEIAQAAAA==.',['小米']='小米虫:BAAALAAECgYIBwAAAA==.',['小锐']='小锐:BAAALAAECgMIAwAAAA==.小锐锐:BAAALAAECgQIBAAAAA==.',['小阿']='小阿紫:BAABLAAFFH8GAAMQAAIIigccGwCLAAAQAAIIigccGwCLAAARAAEIZQRtYABBAAAAAA==.',['小雨']='小雨儿:BAABLAAFFH8GAAIBAAIIcwihawBPAAABAAIIcwihawBPAAAAAA==.',['少个']='少个远程:BAABLAAFFH8GAAIJAAIItQ6AJgB7AAAJAAIItQ6AJgB7AAAAAA==.',['尖沙']='尖沙咀靓坤:BAAALAAECgYIBgAAAA==.',['希尔']='希尔塔萨:BAAALAAFFAIIAgAAAA==.',['带头']='带头大姐大:BAAALAADCgEIAQAAAA==.',['平安']='平安:BAAALAAFFAMIAwAAAA==.',['应龙']='应龙:BAAALAAECgYIAwAAAA==.',['康小']='康小术:BAAALAADCgIIAgAAAA==.',['康師']='康師傅丶紅茶:BAAALAAECgUIBQAAAA==.',['弹道']='弹道亦是道:BAABLAAFFH8OAAIRAAIIXQnKTACGAAARAAIIXQnKTACGAAAAAA==.',['当场']='当场逮捕:BAAALAAECgcICgAAAA==.',['影之']='影之练金术师:BAAALAAECgYICAAAAA==.',['影帝']='影帝一号:BAABLAAFFH8KAAIJAAgIoBakAgDYAQAJAAgIoBakAgDYAQAAAA==.',['影舞']='影舞:BAABLAAFFH8GAAMEAAIImiGMLQC5AAAEAAIImiGMLQC5AAAZAAIItAIuMQAvAAAAAA==.',['微我']='微我五十:BAAALAAECgEIAQAAAA==.',['德克']='德克撒斯:BAAALAAFFAIIBAAAAA==.',['德意']='德意儿地笑:BAAALAAECgYIBgAAAA==.',['德的']='德的得:BAABLAAFFH8FAAIUAAIIchbMCwBbAAAUAAIIchbMCwBbAAAAAA==.',['德艺']='德艺双馨:BAABLAAFFH8PAAILAAUIXw3qIQAOAQALAAUIXw3qIQAOAQAAAA==.',['心忆']='心忆黯然:BAABLAAFFH8IAAIaAAII1A1pVwBEAAAaAAII1A1pVwBEAAAAAA==.',['念慈']='念慈悲度众生:BAAALAADCgIIAgAAAA==.',['怎么']='怎么办啊:BAAALAAECgMIAwAAAA==.',['怒之']='怒之猎魔:BAAALAAECgYICAABLAAFFAMIAwAOAAAAAA==.',['怒斩']='怒斩苍穹:BAABLAAFFH8ZAAIGAAYIbRSBHACEAQAGAAYIbRSBHACEAQAAAA==.',['恒老']='恒老板:BAABLAAFFH8MAAIFAAYIqgeeRwAbAQAFAAYIqgeeRwAbAQAAAA==.',['恶梦']='恶梦猎手:BAAALAAECgcIAQAAAA==.',['惊悚']='惊悚王:BAAALAAECgQIBAAAAA==.',['我找']='我找宠咬你:BAAALAAECgIIAgAAAA==.',['扫地']='扫地沙弥:BAABLAAFFH8PAAIbAAUIkhMMCgBCAQAbAAUIkhMMCgBCAQAAAA==.',['把你']='把你鼠標拿開:BAABLAAFFH8MAAIBAAII3hu3NACXAAABAAII3hu3NACXAAAAAA==.',['抓小']='抓小德:BAAALAAECgQIBAAAAA==.',['抓猫']='抓猫德:BAAALAAFFAIIAgAAAA==.',['拳风']='拳风拂柳:BAABLAAFFH8TAAIbAAUIVhW1CQBJAQAbAAUIVhW1CQBJAQAAAA==.',['摩根']='摩根士丹利:BAABLAAFFH8KAAIaAAII1Q/pTACPAAAaAAII1Q/pTACPAAAAAA==.',['改名']='改名字的熊猫:BAABLAAFFH8IAAIbAAIIrhJwFQBIAAAbAAIIrhJwFQBIAAAAAA==.',['敏哥']='敏哥哥:BAAALAAECgcICAAAAA==.',['斑斑']='斑斑鸠鸠:BAAALAAECgYIEgAAAA==.',['断思']='断思忘念:BAAALAAECgYIBgAAAA==.',['旋律']='旋律:BAABLAAFFH8GAAIPAAIIowtYnABAAAAPAAIIowtYnABAAAAAAA==.',['无神']='无神绝心:BAAALAAECgYIBgAAAA==.',['无聊']='无聊的转身:BAAALAAECgYIBgAAAA==.',['星辰']='星辰不变:BAAALAAECgQIBAAAAA==.',['星魂']='星魂傲雪:BAAALAAECgUIBQAAAA==.',['是牛']='是牛不是熊:BAAALAAFFAIIAwAAAA==.',['是非']='是非良人:BAAALAAFFAIIAgAAAA==.',['晓梦']='晓梦永远开心:BAAALAAFFAMIAwAAAA==.',['暗之']='暗之恶魔:BAABLAAFFH8FAAIcAAMIKgtdGAB6AAAcAAMIKgtdGAB6AAAAAA==.',['暗声']='暗声:BAABLAAFFH8FAAIaAAUIOQRfNgDKAAAaAAUIOQRfNgDKAAAAAA==.',['暴雨']='暴雨:BAACLAAFFH8iAAIBAAUIHB4RFgCvAQABAAUIHB4RFgCvAQAsAAQKfysAAgEACAidIVcMAAIDAAEACAidIVcMAAIDAAAA.',['暴风']='暴风渣男:BAAALAAECgIIAgAAAA==.',['曖曖']='曖曖大咘叮:BAAALAAECgcIAgAAAA==.',['曦玥']='曦玥:BAAALAAFFAIIAgAAAA==.',['最醒']='最醒醒人:BAAALAAFFAgIBAAAAA==.',['月缘']='月缘月:BAAALAADCgEIAQAAAA==.',['木头']='木头人:BAAALAAECgYIBgAAAA==.',['杀戮']='杀戮执行官:BAAALAAECgYICAAAAA==.杀戮魔神:BAAALAADCgcIBwAAAA==.',['李溪']='李溪儿:BAAALAAECgYIBgAAAA==.',['林依']='林依依:BAABLAAECn8XAAIDAAYI6R2AGgDsAQADAAYI6R2AGgDsAQAAAA==.',['林家']='林家乐:BAAALAADCgEIAQAAAA==.',['果子']='果子狸的悲伤:BAAALAAECgYIBgAAAA==.',['果是']='果是甲命:BAABLAAFFH8KAAIPAAUIMRTvJwDdAAAPAAUIMRTvJwDdAAAAAA==.',['柏芝']='柏芝:BAAALAADCgcIDQAAAA==.',['桔梗']='桔梗:BAAALAAECgYIBgAAAA==.',['梦中']='梦中人:BAAALAAECgYIBwAAAA==.',['橙色']='橙色圣光:BAAALAADCgEIAQAAAA==.橙色风暴:BAAALAADCgYIBgAAAA==.',['橙露']='橙露:BAAALAADCgIIAgAAAA==.',['欧夏']='欧夏天:BAAALAAECgYIBgAAAA==.',['武器']='武器战仕:BAABLAAECn8WAAMGAAcIFBEcRgBFAQAGAAUIIhMcRgBFAQACAAcIJQ55XwAJAQABLAAFFAIIBgABAAISAA==.',['死丸']='死丸之翼:BAAALAAFFAIIAgAAAA==.',['死亡']='死亡高达:BAAALAAECgYIBwAAAA==.',['残夜']='残夜:BAAALAAECgYICAAAAA==.',['残暴']='残暴戰士:BAAALAADCgMIAwAAAA==.',['残月']='残月:BAAALAAECgMIBQAAAA==.',['毛茸']='毛茸毛茸:BAABLAAFFH8GAAIVAAYIsQAdEQCmAAAVAAYIsQAdEQCmAAAAAA==.',['氏子']='氏子:BAAALAADCgEIAQAAAA==.',['水悟']='水悟空城:BAAALAAECgYIBgAAAA==.',['永恒']='永恒的柏拉图:BAAALAAECgYIBgAAAA==.',['求你']='求你别塞冰块:BAABLAAECn8XAAIFAAcI3hOyrgCwAQAFAAcI3hOyrgCwAQAAAA==.',['江西']='江西芙蓉王:BAAALAAECgYIBgAAAA==.',['沃克']='沃克玛大主教:BAAALAAFFAQIBAAAAA==.',['沙加']='沙加:BAAALAAECggICAAAAA==.',['沙星']='沙星飞:BAAALAAECgUIBQAAAA==.',['没弓']='没弓的饲养员:BAAALAAFFAIIAgAAAA==.',['没有']='没有银子:BAAALAAECgYIBgAAAA==.',['洛洛']='洛洛宝贝:BAAALAAFFAIIAwAAAA==.',['洪柒']='洪柒:BAAALAAECgMIAwAAAA==.',['浴血']='浴血奋戦:BAAALAAFFAIIBAAAAA==.',['混混']='混混日子:BAABLAAFFH8MAAIWAAQI9A9PEQDtAAAWAAQI9A9PEQDtAAAAAA==.',['游天']='游天刃:BAACLAAFFH8IAAIdAAIIBgSfIgAqAAAdAAIIBgSfIgAqAAAsAAQKfxsABBUABgjeDPQcAOkAABUABgjeDPQcAOkAABsABAgbGJQkANAAAB0ABgihBDc7AL8AAAAA.',['滿月']='滿月小麥子:BAAALAAFFAIIAwAAAA==.',['潘朵']='潘朵瘌:BAAALAAFFAIIAgAAAA==.',['灬寳']='灬寳貝灬:BAAALAAECgMIBQAAAA==.',['灬星']='灬星爷灬:BAAALAAECgYIEAAAAA==.',['灬正']='灬正邪委圆灬:BAAALAADCgYIBgAAAA==.',['灬秋']='灬秋宇灬:BAAALAAECgYIDgAAAA==.',['灬筱']='灬筱蜜桃:BAABLAAFFH8IAAIPAAII+iO1PgCoAAAPAAII+iO1PgCoAAAAAA==.',['灵活']='灵活的小胖子:BAABLAAFFH8SAAIdAAYIcxBTEABFAQAdAAYIcxBTEABFAQAAAA==.',['热情']='热情随雨:BAABLAAFFH8PAAIWAAMI9RCmFQCnAAAWAAMI9RCmFQCnAAAAAA==.',['熊猫']='熊猫创可贴:BAAALAAFFAIIBAAAAA==.',['牌牌']='牌牌琦:BAAALAAECgIIAgAAAA==.',['牧尘']='牧尘:BAAALAAECgYIDwAAAA==.',['狂烈']='狂烈:BAAALAAECgYIBgAAAA==.',['狂野']='狂野泯灭之魂:BAAALAAFFAIIAgAAAA==.',['狐狸']='狐狸精:BAAALAADCgYIDAAAAA==.',['狼里']='狼里个浪:BAABLAAECn8YAAIBAAYIoQ4kvwAGAQABAAYIoQ4kvwAGAQAAAA==.',['猫不']='猫不会微笑:BAABLAAFFH8IAAIeAAIIpRruEgBMAAAeAAIIpRruEgBMAAAAAA==.',['猴赛']='猴赛雷:BAAALAAECgUICwAAAA==.',['王中']='王中王:BAACLAAFFH8GAAIPAAIIqAw7ngA/AAAPAAIIqAw7ngA/AAAsAAQKfx8AAg8ACAhrGK5uAP4BAA8ACAhrGK5uAP4BAAAA.',['琪琪']='琪琪酱:BAAALAADCggICAAAAA==.',['瑞克']='瑞克十代:BAABLAAFFH8MAAITAAIIeBEATgCTAAATAAIIeBEATgCTAAAAAA==.',['瑞淇']='瑞淇曼:BAABLAAFFH8PAAIEAAMIDhyTHgDHAAAEAAMIDhyTHgDHAAAAAA==.',['申花']='申花老乱:BAACLAAFFH8LAAILAAUIAAynIwD+AAALAAUIAAynIwD+AAAsAAQKfyUAAgsABgjzGbZPAKgBAAsABgjzGbZPAKgBAAAA.',['电之']='电之殇:BAABLAAFFH8KAAIBAAIIig8HXgBfAAABAAIIig8HXgBfAAAAAA==.',['疯牛']='疯牛涕淌:BAAALAAECgQIBAAAAA==.',['白魔']='白魔女:BAABLAAECn8eAAMEAAgIkQtVaABCAQAEAAcIqAxVaABCAQAZAAMIvgm8jwBiAAAAAA==.',['百丈']='百丈:BAAALAAFFAIIAgAAAA==.',['盛夏']='盛夏之茉:BAAALAAECggIEQAAAA==.盛夏有晴空:BAAALAAFFAIIAgAAAA==.',['直到']='直到世界尽头:BAAALAAECgYIEAAAAA==.',['真实']='真实的战复:BAAALAAFFAIIAgAAAA==.',['眼不']='眼不见为净:BAAALAADCgEIAQAAAA==.',['瞎子']='瞎子猎手:BAAALAAECgYIBgAAAA==.',['知寒']='知寒问暖:BAAALAAECgEIAQAAAA==.',['破碎']='破碎祭歌:BAABLAAFFH8eAAMLAAYIKCI0BgBLAgALAAYIKCI0BgBLAgAMAAYIKQaJGwD3AAAAAA==.',['破补']='破补丁:BAAALAAFFAIIBAAAAA==.',['祈祷']='祈祷的圣翼:BAAALAAFFAIIBAAAAA==.',['祎蝶']='祎蝶血棘:BAABLAAFFH8GAAIaAAYIIwCpcgAFAAAaAAYIIwCpcgAFAAAAAA==.',['秋月']='秋月寒刀:BAAALAAFFAIIBAAAAA==.',['秋窗']='秋窗风雨夕:BAACLAAFFH8pAAIZAAcIQyICBABDAgAZAAcIQyICBABDAgAsAAQKfzoAAxkACAgGI+UKAB4DABkACAgGI+UKAB4DAB8ABAhUHPYKAEwBAAEsAAUUCAgIABoAmgcA.',['童眸']='童眸:BAAALAAECgYIBgAAAA==.',['箭无']='箭无虚发:BAABLAAFFH8LAAIPAAYImx4aGADXAQAPAAYImx4aGADXAQAAAA==.',['糯米']='糯米啵啵酱:BAAALAAECgEIAQAAAA==.',['纪王']='纪王村支书:BAAALAADCgEIAQAAAA==.',['纯情']='纯情蟑螂:BAAALAAFFAIIBAAAAA==.',['细雨']='细雨无声:BAAALAAECgYIEgAAAA==.',['织梦']='织梦人:BAACLAAFFH8iAAIBAAYItRL9JAA4AQABAAYItRL9JAA4AQAsAAQKfyUAAgEABwidFulyAJ0BAAEABwidFulyAJ0BAAAA.',['续航']='续航力:BAAALAAECgMIAwAAAA==.',['维鲁']='维鲁:BAACLAAFFH8KAAIIAAII0xK+SQCXAAAIAAII0xK+SQCXAAAsAAQKfxQAAggABghqH7MwANABAAgABghqH7MwANABAAAA.',['绿叶']='绿叶素:BAAALAAECgMIAQAAAA==.',['绿竹']='绿竹猗猗:BAAALAADCgYIBgAAAA==.',['老婆']='老婆返咗乡下:BAABLAAFFH8KAAIBAAIIBA5zYQBZAAABAAIIBA5zYQBZAAAAAA==.老婆返咗郷下:BAACLAAFFH8fAAIPAAgIag2cMQBzAQAPAAgIag2cMQBzAQAsAAQKfyMAAg8ACAjiHvQpALACAA8ACAjiHvQpALACAAAA.',['老李']='老李的骑士:BAABLAAFFH8TAAMIAAYIDA+SLQAZAQAIAAUILQ2SLQAZAQAgAAQIqgtXDQCrAAAAAA==.',['肖雅']='肖雅文:BAAALAAECgEIAgAAAA==.',['腰子']='腰子:BAAALAAECgIIAgAAAA==.',['舒克']='舒克飞机坠了:BAAALAAFFAIIAgAAAA==.',['艾瑞']='艾瑞拉:BAAALAAFFAIIAgAAAA==.',['花间']='花间醉酒:BAAALAAFFAIIAgAAAA==.',['苏萌']='苏萌:BAAALAAECgcICwAAAA==.',['莎莉']='莎莉娅:BAAALAAFFAIIBAAAAA==.',['莫杰']='莫杰作:BAAALAAECggICgAAAA==.',['菲拉']='菲拉:BAAALAAFFAIIAgAAAA==.',['萌你']='萌你一脸熊掌:BAACLAAFFH8SAAILAAUIBBizGwBMAQALAAUIBBizGwBMAQAsAAQKfxkAAgsABgh6HGtCANYBAAsABgh6HGtCANYBAAAA.',['萧翎']='萧翎:BAAALAAECgYICgAAAA==.',['萨满']='萨满:BAAALAAFFAYIAwAAAA==.',['落叶']='落叶的安宁:BAAALAAECggIDgAAAA==.',['蒙朱']='蒙朱清云:BAAALAAECgUIBQAAAA==.',['蒙面']='蒙面超人:BAAALAAECgYIDQAAAA==.',['蕾姆']='蕾姆:BAABLAAFFH8GAAMBAAIIAhKtVwBrAAABAAIIAhKtVwBrAAASAAIIRQO1TgA3AAAAAA==.',['蛋疼']='蛋疼的很:BAABLAAFFH8GAAIKAAIIeAEaFwBNAAAKAAIIeAEaFwBNAAAAAA==.',['蜜茶']='蜜茶:BAAALAADCgIIAgAAAA==.',['蝙蝠']='蝙蝠虾:BAAALAAECgYICAAAAA==.',['西棠']='西棠月:BAAALAADCgIIAgAAAA==.',['言叶']='言叶之庭:BAAALAAECgYIDAAAAA==.',['诸神']='诸神的毁灭:BAAALAADCgcIBwAAAA==.',['谭雅']='谭雅羊羊:BAAALAAECgEIAQAAAA==.',['貂儿']='貂儿:BAAALAAECgQIBAAAAA==.',['赛克']='赛克西:BAABLAAFFH8gAAMSAAYIsiBzDwDGAQASAAYIsiBzDwDGAQABAAIIKQGYcQBFAAAAAA==.',['赛普']='赛普林:BAAALAAFFAIIBAAAAA==.',['赤怜']='赤怜:BAABLAAFFH8IAAIRAAIIhAwcSQCMAAARAAIIhAwcSQCMAAAAAA==.',['赵云']='赵云:BAAALAADCgYICQAAAA==.',['超级']='超级大兲:BAAALAAECgYIDAAAAA==.超级奶牛:BAACLAAFFH8eAAMMAAUIvBtoEwBKAQAMAAUIvBtoEwBKAQALAAIIBhUmPwB1AAAsAAQKfxgAAwwACAgNHp4LAD8CAAwACAgNHp4LAD8CAAsABwgdBHarALwAAAAA.',['越狱']='越狱丶:BAACLAAFFH8IAAMJAAQInhbBCwA0AQAJAAQINRbBCwA0AQAPAAMIexMhbwCDAAAsAAQKfxoAAw8ACAi8IroTABIDAA8ACAhIIroTABIDAAkABwiIHLlJAI4BAAAA.越狱丷:BAABLAAECn8YAAMJAAgIIB/nBABDAgAJAAgIph3nBABDAgAPAAcIoRwSIwAtAgAAAA==.',['跳河']='跳河淹死的鱼:BAAALAAECggICAABLAAFFAgIBgANAOIhAA==.',['轩辕']='轩辕吉祥:BAAALAAECgYIBgAAAA==.',['轰不']='轰不冻:BAAALAAFFAIIAgAAAA==.',['迅小']='迅小小:BAAALAADCgcIBwAAAA==.',['这就']='这就是僵尸么:BAAALAAFFAIIAgAAAA==.',['逍遥']='逍遥猪头:BAABLAAFFH8IAAIRAAIIPAUXVQByAAARAAIIPAUXVQByAAAAAA==.',['邪神']='邪神猎手:BAAALAADCgYIBgAAAA==.',['醉丶']='醉丶可爱:BAAALAAECgEIAQAAAA==.',['重污']='重污染源:BAAALAAFFAIIBAAAAA==.',['野居']='野居大王:BAABLAAFFH8MAAMRAAIIpxq2RgCPAAARAAIIHg+2RgCPAAAQAAEICh5/JABVAAAAAA==.',['野性']='野性呼唤:BAAALAAECgYICwAAAA==.野性酥笙:BAAALAADCgMIBQAAAA==.',['野猪']='野猪大神:BAABLAAFFH8GAAIEAAIIHh+VMACoAAAEAAIIHh+VMACoAAAAAA==.',['金大']='金大干:BAAALAAECgYICQAAAA==.',['银杏']='银杏出墙:BAAALAADCggICAAAAA==.',['银神']='银神至尊:BAAALAAECgMIBAAAAA==.',['闲得']='闲得慌:BAAALAAFFAIIAgAAAA==.',['闹闹']='闹闹腾:BAAALAAECgEIAQAAAA==.',['阿尔']='阿尔囧牛斯:BAABLAAECn8lAAIFAAcIVA2GyQCMAQAFAAcIVA2GyQCMAQAAAA==.',['阿易']='阿易雷:BAAALAAECgIIAgAAAA==.',['阿玉']='阿玉王:BAAALAAECgYIDAAAAA==.',['陈三']='陈三竖:BAAALAAECgEIAQAAAA==.',['陪我']='陪我看日出:BAAALAAECgYIDgAAAA==.',['随风']='随风落叶:BAAALAADCgYICQAAAA==.',['隐姓']='隐姓埋名:BAACLAAFFH8KAAIGAAQIrxlSLAD+AAAGAAQIrxlSLAD+AAAsAAQKfxcAAgYABgjtGBF3AJsBAAYABgjtGBF3AJsBAAAA.',['隔壁']='隔壁小沈:BAACLAAFFH8LAAIZAAYI2BP8DQB/AQAZAAYI2BP8DQB/AQAsAAQKfxYAAhkACAjIHZs5ANoBABkACAjIHZs5ANoBAAEsAAUUBwgZAAQAGwkA.',['雨夜']='雨夜獨行:BAAALAAECgYIEQAAAA==.',['雪花']='雪花回来了:BAAALAADCgIIAgAAAA==.雪花大地:BAABLAAECn8aAAIhAAYIvh/gAwDWAQAhAAYIvh/gAwDWAQAAAA==.',['雲天']='雲天:BAABLAAECn8aAAITAAYINhJkOAAtAQATAAYINhJkOAAtAQAAAA==.',['雷霆']='雷霆斩:BAAALAAECgQIBAAAAA==.',['雾零']='雾零:BAABLAAFFH8GAAIaAAMIbQTKRQBkAAAaAAMIbQTKRQBkAAAAAA==.',['青柠']='青柠桃桃喵:BAAALAAFFAIIAgAAAA==.',['青龙']='青龙卧雪:BAAALAAECgYIDAAAAA==.',['静风']='静风止水:BAAALAAECgYIEgAAAA==.',['風之']='風之天際:BAACLAAFFH8IAAIPAAIIfRfvmQBBAAAPAAIIfRfvmQBBAAAsAAQKfxUAAg8ACAjgEFR8AE4BAA8ACAjgEFR8AE4BAAAA.',['风地']='风地果趣:BAABLAAFFH8QAAIFAAMIbRGsYwCFAAAFAAMIbRGsYwCFAAAAAA==.',['风景']='风景旧曾谙丶:BAAALAADCggIDgAAAA==.',['风暴']='风暴祭歌:BAABLAAFFH8RAAIBAAYIGRAuJQA3AQABAAYIGRAuJQA3AQAAAA==.',['风间']='风间翼:BAAALAAFFAIIBAAAAA==.',['风雪']='风雪莉莉丝:BAAALAAECgYIBgAAAA==.',['风魔']='风魔狂人:BAAALAAFFAIIAgAAAA==.风魔翼:BAABLAAFFH8GAAIeAAIIFxxvDQCbAAAeAAIIFxxvDQCbAAAAAA==.',['飞花']='飞花入梦:BAABLAAFFH8SAAIFAAYIQBfbJAChAQAFAAYIQBfbJAChAQAAAA==.',['飞高']='飞高点:BAAALAAFFAIIBAAAAA==.',['饭醉']='饭醉份子:BAACLAAFFH8IAAIIAAIIOQkRdgA6AAAIAAIIOQkRdgA6AAAsAAQKfxoAAggACAiUF/kkAAMCAAgACAiUF/kkAAMCAAAA.',['香米']='香米粑粑:BAAALAAECgYICQAAAA==.',['魄罗']='魄罗王:BAAALAAFFAIIAwAAAA==.',['黑疯']='黑疯骑士:BAAALAAECgYIDAAAAA==.',['黑起']='黑起魔尊:BAAALAAFFAEIAQAAAA==.',['龙虎']='龙虎山野人:BAAALAADCgIIAgAAAA==.',['龙魂']='龙魂祭歌:BAABLAAFFH8GAAIcAAYI/g4ODQBPAQAcAAYI/g4ODQBPAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end