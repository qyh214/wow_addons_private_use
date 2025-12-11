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
 local lookup = {'Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Holy','Priest-Holy','Druid-Restoration','Paladin-Retribution','Shaman-Restoration','Shaman-Elemental','Paladin-Protection','Warrior-Protection','Mage-Arcane','Hunter-Survival','Warlock-Destruction','DeathKnight-Frost','DeathKnight-Unholy','Evoker-Devastation','Evoker-Preservation','Warlock-Demonology','DeathKnight-Blood','Monk-Windwalker','Monk-Brewmaster','Unknown-Unknown','Warrior-Fury','Druid-Balance','Rogue-Subtlety','Priest-Discipline','Mage-Frost','DemonHunter-Havoc','Warlock-Affliction','Mage-Fire','Rogue-Assassination','Druid-Feral','Priest-Shadow','Monk-Mistweaver','DemonHunter-Vengeance',}; local provider = {region='CN',realm='希雷诺斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Af='Afterglow:BAAALAAFFAIIAgAAAA==.',Ag='Agonist:BAABLAAFFH8MAAMBAAMIFhhpQgCiAAABAAMIFhhpQgCiAAACAAIInBBXJAB/AAAAAA==.',Ai='Aii:BAAALAAECgMIAwAAAA==.Ail:BAABLAAFFH8HAAIDAAII1Q9IHwCKAAADAAII1Q9IHwCKAAAAAA==.Aill:BAABLAAFFH8MAAIEAAIIoRA7NwCFAAAEAAIIoRA7NwCFAAAAAA==.Ailli:BAABLAAFFH8LAAIFAAMIuR3YJwDZAAAFAAMIuR3YJwDZAAAAAA==.Aiurr:BAAALAAFFAIIAgAAAA==.',Al='Aletheia:BAACLAAFFH8MAAIDAAIIIiW9FAC4AAADAAIIIiW9FAC4AAAsAAQKfxoAAwMABwihJZsNAK0CAAMABwihJZsNAK0CAAYAAQjGJNXHAGoAAAEsAAUUAwgVAAcAoCIA.',Ar='Aresx:BAAALAAECgYIBgAAAA==.',At='Atamnica:BAAALAADCgIIAgAAAA==.',Be='Beaman:BAAALAADCgQIBAAAAA==.',Ca='Capibarqs:BAAALAADCgMIAwAAAA==.',Co='Commonheart:BAABLAAECn8VAAIIAAYItxDuagB6AQAIAAYItxDuagB6AQAAAA==.',Cq='Cq:BAACLAAFFH8MAAQDAAMILR3cEQDRAAADAAIIySTcEQDRAAAGAAEIxAVxeAA4AAAJAAEIQwbEIQAoAAAsAAQKfxYAAwMABwi9IyYLAMgCAAMABwi9IyYLAMgCAAYAAggbCGltAVoAAAAA.',Cr='Crazyfury:BAAALAAECgYIBgAAAA==.',Da='Darck:BAAALAADCgEIAQAAAA==.',Dh='Dhrzrf:BAAALAADCggIEAAAAA==.',Du='Duretan:BAAALAAECgYIEQAAAA==.',Er='Erukidu:BAAALAAECgYICQAAAA==.',Fa='Fau:BAABLAAFFH8FAAIKAAIIFBJ7NgArAAAKAAIIFBJ7NgArAAAAAA==.',Fe='Fe:BAAALAAECgUIBgAAAA==.',Fl='Flowercc:BAABLAAFFH8GAAILAAIIrxAuVwBEAAALAAIIrxAuVwBEAAAAAA==.',Ge='Gelina:BAAALAAFFAIIAgAAAA==.',Gr='Greedstar:BAAALAADCgYIBgAAAA==.',He='Hellbark:BAAALAAECgUIBwAAAA==.',Je='Jerk:BAAALAADCgcIBwAAAA==.',Ju='Justiced:BAAALAAFFAIIAgAAAA==.',La='Labubu:BAAALAAECgIIAgAAAA==.',Li='Lightcool:BAAALAADCggICAAAAA==.Lightkid:BAAALAAFFAQIBAAAAA==.',Lo='Loktarz:BAAALAAECgYIBgAAAA==.',Lt='Lt:BAAALAAECgMIAwAAAA==.',Md='Mdsa:BAAALAAFFAIIAgAAAA==.Mdsg:BAACLAAFFH8jAAIBAAYIxBgyLACEAQABAAYIxBgyLACEAQAsAAQKfycABAEACAjJG4xEAMABAAEACAhDG4xEAMABAAIABAhkEoeXAI8AAAwAAQiKCKomADEAAAAA.Mdsm:BAAALAAECgYIEAAAAA==.Mdss:BAAALAADCgYIBgAAAA==.',Me='Megumelol:BAAALAADCgIIAgAAAA==.',Mi='Minmu:BAAALAAECgQIBgAAAA==.Minsa:BAAALAAECgUICAAAAA==.Minwusen:BAAALAAECgYIBgABLAAFFAgIBQANAIQIAA==.Mit:BAAALAAFFAIIBAAAAA==.',Ne='Neonlight:BAAALAAECgYIEgAAAA==.',No='Nomnom:BAAALAAFFAIIBAAAAA==.',Or='Orage:BAABLAAFFH8JAAILAAIIjAiRXgB+AAALAAIIjAiRXgB+AAAAAA==.',Pa='Pano:BAAALAAECgIIAgAAAA==.',Pu='Purplepoison:BAAALAADCgIIAgAAAA==.',Re='Rexsar:BAAALAAECgUIDAAAAA==.',Sa='Sangeyasha:BAAALAAECgYICAAAAA==.',So='Socrizy:BAAALAAECgMIAwAAAA==.Socrzay:BAAALAADCgIIAgAAAA==.',Sw='Swindrunner:BAAALAAECgYICQAAAA==.',Te='Teufel:BAAALAAFFAIIBAAAAA==.',Th='Thistle:BAACLAAFFH80AAIEAAgIDx/5AQBhAgAEAAgIDx/5AQBhAgAsAAQKfx8AAgQACAhBIzMLAA4DAAQACAhBIzMLAA4DAAAA.',Tr='Tribal:BAAALAAECgIIAgAAAA==.',Ve='Vermithor:BAABLAAFFH8GAAIBAAII+Q76bQCBAAABAAII+Q76bQCBAAAAAA==.',Wi='Wilhelmina:BAAALAAECgYIBgAAAA==.',Xi='Xied:BAAALAAECgQIBAAAAA==.',Xw='Xwine:BAAALAADCgQIBAAAAA==.',Yo='Yorick:BAAALAADCgcIBwAAAA==.',['一小']='一小唯一:BAAALAAFFAIIAgAAAA==.',['一指']='一指流沙:BAAALAAECggICAAAAA==.',['一条']='一条虫:BAAALAADCgYICwAAAA==.',['一步']='一步一安然:BAACLAAFFH8RAAIBAAUIBRKoUgAEAQABAAUIBRKoUgAEAQAsAAQKfyoAAgEACAgAIJEUAIICAAEACAgAIJEUAIICAAEsAAUUBQgoAA0AsBYA.',['一灭']='一灭神一:BAAALAAECgQIBQAAAA==.',['一琦']='一琦琦一:BAABLAAFFH8FAAIIAAIIhhe6PQBPAAAIAAIIhhe6PQBPAAAAAA==.',['一种']='一种数值的美:BAABLAAFFH8lAAIGAAYIUx+gDwDIAQAGAAYIUx+gDwDIAQAAAA==.',['一般']='一般小骑士:BAABLAAFFH8JAAIJAAIIaAG8IgA8AAAJAAIIaAG8IgA8AAAAAA==.一般般啦:BAABLAAFFH8IAAIKAAIIvQG1OgAgAAAKAAIIvQG1OgAgAAAAAA==.',['一蓑']='一蓑烟雨丶:BAAALAAECgYICAAAAA==.',['一队']='一队圣骑:BAACLAAFFH8OAAIOAAUIzRWpQwAsAQAOAAUIzRWpQwAsAQAsAAQKfxcAAg4ABwj/FLJTAEwBAA4ABwj/FLJTAEwBAAAA.',['七四']='七四二:BAAALAAECgYIBgAAAA==.七四贰:BAABLAAFFH8JAAMPAAMI0gfyDACMAAAPAAMI0gfyDACMAAAOAAEIpAB2sAAAAAAAAA==.',['七肆']='七肆二:BAABLAAFFH8IAAINAAUI5QglQADyAAANAAUI5QglQADyAAAAAA==.七肆贰:BAABLAAFFH8OAAMQAAYISRFIDABcAQAQAAYISRFIDABcAQARAAIICgeRHABdAAAAAA==.',['三月']='三月雪飘:BAAALAAECgcIBwAAAA==.',['不听']='不听大乘佛法:BAAALAAECgYIDAAAAA==.',['不止']='不止如初见:BAAALAAFFAIIAgAAAA==.',['不知']='不知德:BAABLAAFFH8KAAIFAAII3AcQTwBVAAAFAAII3AcQTwBVAAAAAA==.',['不谓']='不谓侠:BAAALAAECgYICwAAAA==.',['世界']='世界萨丶老三:BAAALAAECgcICQAAAA==.',['东杰']='东杰:BAABLAAECn8aAAISAAYIzx2AJADoAQASAAYIzx2AJADoAQAAAA==.',['丨挚']='丨挚爱丨:BAAALAAFFAIIAgAAAA==.',['丨林']='丨林大头丨:BAAALAAECgUIBQAAAA==.',['丨燃']='丨燃烧星辉丨:BAABLAAFFH8lAAILAAUIVR6gEgDRAQALAAUIVR6gEgDRAQABLAAFFAcIHwABAIsjAA==.丨燃烧曦风丨:BAACLAAFFH8fAAIBAAcIiyOfCABYAgABAAcIiyOfCABYAgAsAAQKfyAAAgEACAjqJJIJANICAAEACAjqJJIJANICAAAA.丨燃烧语灵丨:BAACLAAFFH8cAAMOAAYIUBubKACUAQAOAAYIGhibKACUAQATAAUI2hllDABGAQAsAAQKfxwAAhMACAhaIZAQAEkCABMACAhaIZAQAEkCAAEsAAUUBwgfAAEAiyMA.丨燃烧语风丨:BAACLAAFFH8hAAMUAAYITyJiAwDvAQAVAAYIdB88BgDzAQAUAAYIXh9iAwDvAQAsAAQKfx8AAxQABgghJLgWAFsCABQABgj/IbgWAFsCABUABgi+Ie4RAEACAAEsAAUUBwgfAAEAiyMA.丨燃烧辉韵丨:BAACLAAFFH8RAAIGAAYIUSCwDADeAQAGAAYIUSCwDADeAQAsAAQKfxoAAgYACAjGIcIgAO8CAAYACAjGIcIgAO8CAAEsAAUUBwgfAAEAiyMA.',['丨碧']='丨碧波丨:BAABLAAFFH8LAAIVAAYI4BMFCQBNAQAVAAYI4BMFCQBNAQAAAA==.',['丨罹']='丨罹梦丨:BAAALAAECgYIBgAAAA==.',['丨陸']='丨陸丨:BAAALAADCggIDAABLAAECgYIBgAWAAAAAA==.',['丶一']='丶一叶婆娑:BAABLAAFFH8GAAIVAAUIIgdOFwCwAAAVAAUIIgdOFwCwAAABLAAFFAgICQAVAHMKAA==.丶一寸狂心:BAAALAAFFAIIBAAAAA==.',['丶万']='丶万物:BAAALAAECgUICQAAAA==.',['丶灭']='丶灭:BAAALAAECgYIBwAAAA==.',['丶王']='丶王怼怼:BAACLAAFFH8HAAMBAAIIphhMSgCaAAABAAIIphhMSgCaAAACAAII6AMvMABgAAAsAAQKfxYAAwEABgiKGRiwAJUBAAEABQjuHBiwAJUBAAIABgiIENRkAC4BAAAA.',['丷筱']='丷筱布:BAAALAAECggIEgAAAA==.',['丿林']='丿林:BAAALAAECgQIBgAAAA==.',['乌了']='乌了雷:BAAALAAFFAIIAgAAAA==.',['也曾']='也曾深夜崩溃:BAAALAAECgEIAQAAAA==.',['书思']='书思:BAAALAAECgYIEgAAAA==.',['云梦']='云梦的暗夜贼:BAAALAADCgQIBAAAAA==.',['五弥']='五弥三道:BAAALAAECgEIAQAAAA==.',['五火']='五火球叫煮:BAAALAADCgYIBwAAAA==.',['伊利']='伊利小丹丹:BAAALAAECggICAAAAA==.',['休婆']='休婆曼:BAAALAAECgYIBgAAAA==.',['低头']='低头猛冲:BAABLAAFFH8LAAIXAAMILglbOACRAAAXAAMILglbOACRAAAAAA==.低头猛走:BAABLAAECn8aAAIYAAcIRBfKIABoAQAYAAcIRBfKIABoAQAAAA==.',['佛耶']='佛耶戈:BAACLAAFFH8LAAMOAAMIBx9xJwD7AAAOAAMIBx9xJwD7AAAPAAEIZBlKHQBQAAAsAAQKfxQAAw4ACAjyIHU2AJ0CAA4ACAg1IHU2AJ0CAA8ABggoIJ4kAJgBAAAA.',['作业']='作业扛把子:BAABLAAFFH8KAAIHAAIIuQ+3XQBgAAAHAAIIuQ+3XQBgAAAAAA==.',['你跟']='你跟我说不着:BAAALAAECgYICwAAAA==.',['佩恩']='佩恩:BAAALAAECgUIBQAAAA==.',['依宝']='依宝宝:BAAALAAECggICAAAAA==.',['依旧']='依旧很犀利:BAAALAAECgIIAgAAAA==.',['偷土']='偷土豆得:BAAALAAECgYIEgAAAA==.',['傻朝']='傻朝朝:BAAALAAECgMIAwAAAA==.',['先卤']='先卤为敬:BAAALAADCgQIBAAAAA==.',['免骑']='免骑:BAAALAAECgEIAgAAAA==.',['全球']='全球变暖:BAABLAAFFH8GAAIZAAII/xWpFACIAAAZAAII/xWpFACIAAAAAA==.',['公子']='公子小宝:BAAALAAECgYIDQAAAA==.',['其一']='其一:BAAALAADCgEIAQAAAA==.',['兽兽']='兽兽很和谐:BAAALAAECgcICAAAAA==.兽兽很善良:BAAALAAECgYIDAAAAA==.',['冷酸']='冷酸灵:BAAALAADCggICAAAAA==.',['冷锋']='冷锋:BAABLAAFFH8ZAAMBAAYI2RvBCQDwAQABAAYI2RvBCQDwAQACAAEIIQapGAA7AAAAAA==.',['凡人']='凡人皆有一死:BAAALAAECgYIEAAAAA==.',['凶神']='凶神恶萨:BAAALAAECgYIBgAAAA==.',['刘一']='刘一口:BAAALAAECgYICwAAAA==.',['刘奶']='刘奶奶:BAAALAADCgEIAQAAAA==.',['刘小']='刘小猪:BAAALAAECgIIAgAAAA==.',['刘白']='刘白发:BAAALAAECgYICAAAAA==.',['刘鼻']='刘鼻血:BAAALAAECgIIAgAAAA==.',['初夏']='初夏:BAAALAAECgEIAQAAAA==.',['别了']='别了小吾爱:BAAALAADCgIIAgAAAA==.',['勃艮']='勃艮第:BAABLAAFFH8LAAMOAAIIdR6LQwCuAAAOAAIIdR6LQwCuAAAPAAII9BAsEwCNAAAAAA==.',['勇敢']='勇敢牛贝拉:BAAALAADCgYIBgAAAA==.',['勾陈']='勾陈:BAABLAAFFH8IAAIGAAQIZAYbOwCqAAAGAAQIZAYbOwCqAAAAAA==.',['北京']='北京卡酷:BAAALAADCgcICAAAAA==.',['十五']='十五:BAAALAAFFAQIAwAAAA==.',['十曰']='十曰:BAAALAAECgMIAwAAAA==.',['十月']='十月丶晴:BAABLAAFFH8KAAIOAAQIQRObGwBGAQAOAAQIQRObGwBGAQAAAA==.',['千岚']='千岚丶逐风者:BAAALAAECgYICgAAAA==.',['千手']='千手柱间:BAAALAAFFAIIAgAAAA==.',['卡尼']='卡尼之涌:BAAALAADCgMIAwAAAA==.',['卡布']='卡布灬奇诺:BAAALAAECgEIAQAAAA==.',['卡斯']='卡斯特梅雨季:BAAALAAECgcIDgAAAA==.',['又被']='又被骗回来咯:BAAALAADCgMIAwAAAA==.',['发新']='发新卡卡:BAAALAADCggICAAAAA==.',['古墓']='古墓小师妹:BAAALAADCgMIAwAAAA==.',['只有']='只有中杯大杯:BAABLAAFFH8nAAMIAAYIUx3kEgCkAQAIAAYIUx3kEgCkAQAHAAUIQhMJKwAOAQAAAA==.',['可乐']='可乐永远醒目:BAABLAAFFH8MAAILAAIIDBK9RQCaAAALAAIIDBK9RQCaAAAAAA==.可乐的德:BAAALAAECgUIBQAAAA==.',['叶落']='叶落抚尘:BAABLAAFFH8HAAIEAAIIPQegOwB+AAAEAAIIPQegOwB+AAAAAA==.',['吇叽']='吇叽侳鉒:BAAALAAECgYIEgAAAA==.吇叽唑註:BAAALAAECgQIBAAAAA==.',['吉非']='吉非替尼:BAABLAAECn8aAAIGAAYIIRs6TQB1AQAGAAYIIRs6TQB1AQAAAA==.',['君临']='君临异世:BAAALAAECgMIAwAAAA==.',['听风']='听风戀雪:BAAALAAECgIIAgAAAA==.',['启程']='启程啊丷:BAAALAADCgQIBAAAAA==.',['吹个']='吹个大气球:BAABLAAFFH8GAAIBAAIIwyElNAC8AAABAAIIwyElNAC8AAABLAAFFAQICgAOAEETAA==.',['呲溜']='呲溜溜:BAAALAAECgUIBwAAAA==.',['呲牙']='呲牙咧嘴:BAAALAAFFAIIAgAAAA==.',['咕咕']='咕咕一:BAAALAAECgYIEQAAAA==.',['咕噜']='咕噜头戴假发:BAAALAAFFAEIAQAAAA==.',['哈利']='哈利波特别大:BAAALAADCgMIAwAAAA==.',['哈莉']='哈莉露雅:BAAALAADCgYIBgAAAA==.',['唾液']='唾液淀粉酶:BAAALAAFFAIIAgAAAA==.',['啊牧']='啊牧師:BAAALAAFFAIIBAAAAA==.',['喜糖']='喜糖:BAAALAAECgYIBgAAAA==.',['喵了']='喵了个咪:BAAALAAECgYIDAAAAA==.',['喵手']='喵手囘春:BAAALAAECgYICAAAAA==.',['嗜血']='嗜血斑马:BAAALAAECgEIAQABLAAECgYIDgAWAAAAAA==.',['嘻嘻']='嘻嘻晓空:BAABLAAFFH8GAAIKAAYI/QxAFQAQAQAKAAYI/QxAFQAQAQAAAA==.',['嘿嘿']='嘿嘿哈哈大王:BAABLAAFFH8IAAIFAAIIrRE9NwBoAAAFAAIIrRE9NwBoAAAAAA==.',['四块']='四块钱麻辣烫:BAAALAAECgYIBwAAAA==.',['回忆']='回忆之刃:BAABLAAFFH8rAAIKAAYIgQnNFQAJAQAKAAYIgQnNFQAJAQAAAA==.',['圣光']='圣光决裁者:BAAALAAECgIIAgAAAA==.圣光强国:BAABLAAFFH8IAAIGAAIIuB6fVwBLAAAGAAIIuB6fVwBLAAAAAA==.圣光裁决者:BAAALAAFFAIIAgAAAA==.',['地头']='地头蛇:BAAALAAECgYIBgAAAA==.',['堕落']='堕落的丘比特:BAAALAADCgIIAgAAAA==.堕落迷失:BAAALAAFFAMIAwAAAA==.',['塞拉']='塞拉丶辉刃:BAAALAAECgYIBwAAAA==.',['壞脾']='壞脾氣:BAAALAAECgYIBwAAAA==.',['壹神']='壹神带肆腿:BAAALAAECgYIBgAAAA==.',['备长']='备长炭:BAAALAADCgYIBgAAAA==.',['夜凉']='夜凉如水丶:BAACLAAFFH8KAAMEAAQI2AltGwDXAAAEAAQI2AltGwDXAAAaAAEIjwdXBgA+AAAsAAQKfygAAxoABwjtGtMIACMCABoABwjUGtMIACMCAAQABwj1EpNNAKABAAAA.',['大暗']='大暗黑天丶:BAAALAAFFAIIBAAAAA==.',['大耳']='大耳朵狐狐:BAABLAAFFH8HAAIHAAMI0w1GTgB/AAAHAAMI0w1GTgB/AAAAAA==.',['大脑']='大脑斧:BAABLAAFFH8IAAIFAAIIgRQ7PQB7AAAFAAIIgRQ7PQB7AAAAAA==.',['天使']='天使与魔法:BAAALAAFFAIIAgAAAA==.',['天剑']='天剑:BAAALAAFFAIIAgAAAA==.',['天歌']='天歌:BAABLAAECn8UAAIXAAYIoAtBWQAKAQAXAAYIoAtBWQAKAQAAAA==.',['天然']='天然含气:BAAALAADCgUIBQAAAA==.',['天界']='天界大魔法:BAABLAAFFH8GAAIbAAIIOA7vGAA+AAAbAAIIOA7vGAA+AAAAAA==.',['天睿']='天睿:BAAALAAECgYIBgAAAA==.',['天鬼']='天鬼皇:BAAALAADCggIDAAAAA==.',['奎托']='奎托斯:BAAALAAECgYIBgAAAA==.',['套你']='套你哇一:BAACLAAFFH8GAAIGAAIIqhOWQwCcAAAGAAIIqhOWQwCcAAAsAAQKfxQAAgYACAicJHgNAEcDAAYACAicJHgNAEcDAAAA.',['奥蕾']='奥蕾克西娅:BAAALAADCggICAABLAAECgcICwAWAAAAAA==.',['奥迪']='奥迪双钻:BAAALAAFFAIIAgAAAA==.',['奶丝']='奶丝凸咪挺优:BAAALAADCgMIAwAAAA==.',['如何']='如何不丑:BAAALAAFFAIIAgAAAA==.',['妖妖']='妖妖菱:BAAALAAFFAcIAwAAAA==.',['妖术']='妖术:BAAALAAECgYIDAAAAA==.',['妖精']='妖精的尾吧:BAAALAAECgIIAwAAAA==.',['威廉']='威廉国王:BAAALAAECgYICQAAAA==.',['嫆嬷']='嫆嬷嬷:BAAALAADCgcIBwAAAA==.',['孤影']='孤影昭昭:BAABLAAFFH8JAAIEAAMI9Qa+IQC0AAAEAAMI9Qa+IQC0AAAAAA==.',['宇智']='宇智波:BAABLAAFFH8GAAIcAAII9w5VWwBCAAAcAAII9w5VWwBCAAAAAA==.',['安戁']='安戁:BAAALAADCggIDgAAAA==.',['安静']='安静丶承受:BAACLAAFFH8JAAIGAAMIOyD5EwAZAQAGAAMIOyD5EwAZAQAsAAQKfx4AAgYABwg6IChCAHUCAAYABwg6IChCAHUCAAAA.',['寂寥']='寂寥狂诗曲:BAAALAAECgEIAgAAAA==.',['寒烟']='寒烟柔:BAAALAAFFAIIBAAAAA==.',['小伙']='小伙:BAAALAADCgUIBQAAAA==.',['小十']='小十月:BAAALAAECggICAAAAA==.',['小南']='小南:BAAALAAFFAIIBAAAAA==.',['小太']='小太阳丶:BAAALAADCgEIAQAAAA==.',['小孩']='小孩子少吃糖:BAABLAAFFH8GAAIDAAII3xOBJAB+AAADAAII3xOBJAB+AAAAAA==.',['小小']='小小胡丶:BAAALAAFFAIIAgAAAA==.小小萨来也:BAABLAAFFH8PAAIHAAIIUQ6wUABrAAAHAAIIUQ6wUABrAAAAAA==.',['小强']='小强:BAABLAAFFH8FAAIOAAUIBRnJQgAvAQAOAAUIBRnJQgAvAQAAAA==.',['小心']='小心雪人:BAAALAAECgQIBAAAAA==.',['小手']='小手软绵丶:BAABLAAFFH8GAAIEAAYISBVCGACQAQAEAAYISBVCGACQAQAAAA==.',['小时']='小时候很浪荡:BAAALAADCgEIAQAAAA==.',['小楼']='小楼风雨:BAAALAADCgMIAwAAAA==.',['小浮']='小浮尼:BAAALAAFFAIIBAAAAA==.',['小牧']='小牧:BAAALAADCggICAAAAA==.',['小猫']='小猫兜:BAAALAAECgIIAgAAAA==.',['小福']='小福尼:BAABLAAFFH8fAAMNAAYIMxPyKAB2AQANAAYIMxPyKAB2AQAdAAEItgutBwBPAAAAAA==.',['小胡']='小胡莉:BAAALAAECgYICQAAAA==.',['小萨']='小萨鲁法尔:BAABLAAFFH8UAAMTAAYIPxxHCwBaAQATAAYIRBZHCwBaAQAOAAQICCHyQwArAQAAAA==.',['小骷']='小骷髅:BAAALAAFFAIIAgABLAAFFAYICAAFAIEUAA==.',['少年']='少年来一发:BAAALAAFFAIIAgAAAA==.',['尕不']='尕不尕:BAAALAAFFAIIBAAAAA==.',['尛灬']='尛灬静:BAAALAAECgMIBQAAAA==.',['就抓']='就抓德:BAABLAAFFH8OAAICAAUIJgpoCwDcAAACAAUIJgpoCwDcAAABLAAFFAYIIAANAMMUAA==.',['尼古']='尼古丁真:BAAALAAECgIIAgAAAA==.尼古丁臻:BAAALAAFFAIIAgAAAA==.',['屁屁']='屁屁看这裏:BAAALAAECgYICAAAAA==.屁屁看这里:BAACLAAFFH8qAAILAAcIiCT0CABTAgALAAcIiCT0CABTAgAsAAQKfx8AAwsACAisI1wIAJYCAB4ABwioH34DAJYCAAsACAilI1wIAJYCAAAA.屁屁踢了没:BAABLAAFFH8HAAICAAII3g1+KAB3AAACAAII3g1+KAB3AAAAAA==.',['山下']='山下牛:BAABLAAFFH8GAAIfAAYIqA6BCgBoAQAfAAYIqA6BCgBoAQAAAA==.',['山田']='山田孝之:BAABLAAFFH8FAAIIAAIIMResJwCYAAAIAAIIMResJwCYAAAAAA==.',['岑风']='岑风暴烈久:BAABLAAECn8XAAMVAAcI+BMcJABxAQAVAAcI+BMcJABxAQAUAAMIYgpZXgBwAAAAAA==.',['岛村']='岛村卯月:BAABLAAFFH8GAAITAAIIRgr1GwAxAAATAAIIRgr1GwAxAAAAAA==.',['巧巧']='巧巧妈妈:BAABLAAFFH8hAAMbAAYIxBhrBACMAQAbAAYIxBhrBACMAQALAAEItQiMYQA6AAAAAA==.',['巴菲']='巴菲特吃腰子:BAAALAAFFAIIAgAAAA==.',['希夫']='希夫:BAABLAAFFH8RAAMHAAUIrxylMQDkAAAHAAQI4xqlMQDkAAAIAAUIURVrKwDiAAAAAA==.',['帕里']='帕里斯丶香秀:BAAALAAECgYIBgAAAA==.',['带小']='带小号用的:BAABLAAFFH8GAAIcAAIILQaMZwA4AAAcAAIILQaMZwA4AAAAAA==.',['带投']='带投丨大哥:BAAALAADCgcIBwAAAA==.',['幽暗']='幽暗之神:BAABLAAECn8WAAMGAAcIaA3hxgB+AQAGAAcIaA3hxgB+AQADAAQIrAiuOQB3AAAAAA==.',['幽灵']='幽灵菇传说:BAAALAAFFAIIBAAAAA==.',['弑丶']='弑丶冰:BAAALAADCgYIBgAAAA==.',['张三']='张三丰:BAABLAAFFH8QAAMBAAYIoxunNABpAQABAAYIoxunNABpAQACAAIITAjTKgByAAAAAA==.',['张云']='张云龙大笨蛋:BAAALAAECgYICAAAAA==.张云龙教授:BAAALAAECgYIBgAAAA==.',['张成']='张成还钳:BAAALAAFFAIIAwAAAA==.',['很小']='很小很可怜:BAAALAADCgcIBwAAAA==.',['心尘']='心尘:BAAALAAFFAIIBAAAAA==.',['心思']='心思云梦:BAABLAAFFH8OAAMDAAUIaBNGDAAgAQADAAMIvB1GDAAgAQAGAAII8ALWhwAGAAAAAA==.',['忆丶']='忆丶花花:BAAALAAFFAIIAwAAAA==.忆丶飞飞:BAAALAAFFAIIAgAAAA==.',['快乐']='快乐的小跟班:BAABLAAECn8gAAIOAAYIhx0MPgCHAQAOAAYIhx0MPgCHAQAAAA==.',['忽觉']='忽觉满城空:BAAALAAECgMIAwAAAA==.',['恶魔']='恶魔恩:BAABLAAFFH8IAAIcAAII7xoQMQCoAAAcAAII7xoQMQCoAAABLAAFFAMIBQAGAI0dAA==.',['悠悠']='悠悠吾心:BAAALAAFFAIIBAAAAA==.',['悲伤']='悲伤大鼻嘎:BAABLAAFFH8QAAIKAAQIKwVMFwCdAAAKAAQIKwVMFwCdAAAAAA==.',['想抓']='想抓个小德:BAACLAAFFH8iAAMCAAUI/R0MBwBaAQACAAUI4xsMBwBaAQABAAUIbhSWTQAXAQAsAAQKfx4AAwIABwizIlkcAIICAAIABwh1IVkcAIICAAEABgjzH6NbAIsBAAAA.',['愤怒']='愤怒的霸王花:BAAALAAECgYICwAAAA==.愤怒说唱歌手:BAAALAAECgEIAQAAAA==.',['憨憨']='憨憨德:BAABLAAFFH8sAAMgAAYIhiD3AQDtAQAgAAYIhiD3AQDtAQAFAAEItwaKXAA0AAAAAA==.',['我不']='我不是彭于晏:BAAALAAECgUIBQAAAA==.',['我猎']='我猎开了:BAAALAAECgYICAAAAA==.',['我自']='我自然萌:BAAALAAECgYIBgAAAA==.',['戴斯']='戴斯潘克:BAAALAAECgQIBAAAAA==.',['手提']='手提酱油:BAACLAAFFH8bAAIbAAUI7xVXBwAwAQAbAAUI7xVXBwAwAQAsAAQKfyMAAxsABwi3GwIpAOIBABsABghuHQIpAOIBAAsABQhWFzW/APoAAAAA.',['抓只']='抓只小德:BAACLAAFFH8eAAMBAAYITiFKFwDcAQABAAYITiFKFwDcAQACAAIISgpeKQB1AAAsAAQKfxgAAwEACAitHxgpABMCAAIACAhmGn4iAFcCAAEABwiAIBgpABMCAAAA.',['抗怪']='抗怪专用:BAABLAAECn8dAAIHAAYIOxMFlABWAQAHAAYIOxMFlABWAQAAAA==.',['抹去']='抹去尘埃:BAAALAADCgQIBAAAAA==.',['掌控']='掌控丶规则:BAAALAAECgUIBQAAAA==.',['握不']='握不住的扎儿:BAABLAAFFH8IAAIBAAIIkhgRUwCUAAABAAIIkhgRUwCUAAAAAA==.',['摟著']='摟著死屍狂笑:BAAALAAECgQIBQAAAA==.',['摩挲']='摩挲楚殇:BAACLAAFFH8IAAIhAAgIuhXEBAApAgAhAAgIuhXEBAApAgAsAAQKfxsAAiEABwgEG28TALwBACEABwgEG28TALwBAAAA.',['敏捷']='敏捷:BAAALAAECgcIEwAAAA==.',['斩丶']='斩丶死亡猎手:BAAALAAECgYICAAAAA==.',['斬丶']='斬丶赤紅之瞳:BAAALAAFFAIIBAAAAA==.',['斯嘉']='斯嘉丽儿:BAAALAAECgYIDAAAAA==.',['无敌']='无敌小浪子:BAAALAAECgYIDgAAAA==.',['无聊']='无聊的焰火:BAAALAAECgMIAwAAAA==.',['昨日']='昨日风尘:BAAALAAECgYIBgAAAA==.',['智力']='智力:BAAALAAECgQICQAAAA==.',['暖暖']='暖暖幸福:BAAALAAECgUICQABLAAECgcICwAWAAAAAA==.',['暗夜']='暗夜大祭司丶:BAAALAADCgEIAQAAAA==.',['曾经']='曾经是超人:BAABLAAECn8XAAIOAAYI9xR3VABKAQAOAAYI9xR3VABKAQAAAA==.',['最佳']='最佳灬损友:BAAALAADCgIIAgAAAA==.',['最爱']='最爱依山尽:BAAALAAFFAIIBAABLAAFFAQICgAOAEETAA==.',['木一']='木一:BAAALAAECgYICgAAAA==.',['机智']='机智的灵魂兽:BAAALAADCgQIBAAAAA==.',['杀气']='杀气凌云:BAAALAAECgUIBQAAAA==.',['李亚']='李亚军:BAAALAAECgYIDAAAAA==.',['李元']='李元梅西:BAAALAAECgQIBAAAAA==.',['来几']='来几个:BAABLAAFFH8QAAILAAUIYg38LwDNAAALAAUIYg38LwDNAAAAAA==.',['杨如']='杨如画:BAAALAAECgYICgAAAA==.',['杨思']='杨思思:BAAALAAECgYIDAAAAA==.',['杭州']='杭州小笼包:BAAALAAECgMIAwAAAA==.',['柒四']='柒四二:BAABLAAFFH8HAAIJAAMIdAMcFwBDAAAJAAMIdAMcFwBDAAAAAA==.',['柒泗']='柒泗二:BAAALAAFFAIIAgAAAA==.柒泗贰:BAABLAAFFH8QAAIEAAUIQwqzJAAXAQAEAAUIQwqzJAAXAQAAAA==.',['柒肆']='柒肆二:BAABLAAFFH8TAAMXAAgIohzaBACRAgAXAAgIohzaBACRAgAKAAMIJw6FIgBnAAAAAA==.柒肆贰:BAAALAAFFAMIAwAAAA==.',['柔情']='柔情信仰战:BAAALAAECgIIAgAAAA==.',['柚子']='柚子迪克:BAAALAAECgMIAwAAAA==.',['柠檬']='柠檬灬柚子茶:BAAALAADCggICAAAAA==.',['柯镇']='柯镇恶:BAAALAAFFAMIBAAAAA==.',['核桃']='核桃:BAAALAAECgcIBwAAAA==.',['格瓦']='格瓦拉:BAAALAAECgYIDgAAAA==.',['樱井']='樱井小泽:BAAALAAECgMIAQAAAA==.',['橙黄']='橙黄橘绿时:BAACLAAFFH8oAAMNAAUIsBY9NwAxAQANAAUIsBY9NwAxAQASAAII5Ql4GgCNAAAsAAQKfx4AAw0ABgi9GvM8AFQBAA0ABgh+GPM8AFQBABIABQiLGDVOADoBAAAA.',['欲望']='欲望圣灵:BAAALAAECgIIAQAAAA==.',['死亡']='死亡喵:BAAALAAECgYIBgAAAA==.',['残云']='残云断月:BAAALAADCggIDAAAAA==.',['殺戮']='殺戮戰神:BAAALAAECgIIAgAAAA==.',['气盖']='气盖世:BAAALAADCggICAAAAA==.',['水果']='水果仙人:BAAALAAFFAIIAgABLAAFFAUIKAANALAWAA==.',['永夜']='永夜黑暗:BAAALAAECgQICQAAAA==.',['求糊']='求糊嘛嚓:BAAALAAECgYICAAAAA==.',['江夏']='江夏的提款机:BAAALAAECgYIBgAAAA==.',['沐沐']='沐沐灬:BAAALAAECgYICAAAAA==.',['沙角']='沙角白蹄:BAAALAADCgIIAgAAAA==.',['法布']='法布赞:BAAALAAFFAIIAgAAAA==.',['泰勒']='泰勒斯威夫特:BAAALAAECgYIAwAAAA==.',['派大']='派大星派副总:BAABLAAFFH8GAAIMAAII6h8YBABSAAAMAAII6h8YBABSAAAAAA==.派大星派总:BAABLAAFFH8NAAIBAAUIvg1BUwACAQABAAUIvg1BUwACAQAAAA==.',['流年']='流年丶若:BAABLAAECn8VAAILAAgIxxh6XQDsAQALAAgIxxh6XQDsAQAAAA==.',['浅然']='浅然:BAABLAAECn8gAAIXAAgImRztEwBEAgAXAAgImRztEwBEAgAAAA==.',['浪不']='浪不过一杯酒:BAABLAAFFH8KAAIiAAIIdQqOEwCAAAAiAAIIdQqOEwCAAAAAAA==.',['浮厝']='浮厝:BAAALAAECgEIAgAAAA==.',['浮生']='浮生第七纪:BAABLAAFFH8IAAMcAAIIfw9LWgBDAAAjAAIIFgR1GQBQAAAcAAIIfw9LWgBDAAABLAAFFAUIKAANALAWAA==.',['海绵']='海绵宝宝总:BAABLAAFFH8FAAMIAAII8hB8QQBIAAAIAAII8hB8QQBIAAAHAAIIkwFaeAA6AAAAAA==.',['混世']='混世魔王:BAAALAAECgYIDwAAAA==.',['混江']='混江龙:BAAALAAECgcIEwAAAA==.',['混沌']='混沌双子:BAACLAAFFH8GAAINAAIIhxOaRwCOAAANAAIIhxOaRwCOAAAsAAQKfxkAAg0ACAjLGkwuAIUCAA0ACAjLGkwuAIUCAAAA.混沌哞哞:BAAALAAFFAIIBAAAAA==.',['渺缈']='渺缈:BAAALAAECgYIBgAAAA==.',['漠漠']='漠漠暗香如云:BAABLAAECn8VAAIGAAgIpSBHHAABAwAGAAgIpSBHHAABAwABLAAFFAYIEQAGAH8NAA==.',['潘帕']='潘帕斯:BAAALAAFFAMIBAAAAA==.',['潘达']='潘达的希望:BAABLAAFFH8LAAMiAAIIlgq/FgBmAAAiAAIIlgq/FgBmAAAUAAII0AOsGwAuAAAAAA==.',['灬刺']='灬刺丶芒灬:BAABLAAFFH8HAAIGAAIIICOtIgDHAAAGAAIIICOtIgDHAAAAAA==.',['灬吼']='灬吼丶:BAAALAAECgUIAwAAAA==.',['灬猎']='灬猎兽:BAAALAAFFAYIAgAAAA==.',['灰常']='灰常红:BAAALAADCgIIAgAAAA==.',['灵芝']='灵芝孢子粉:BAAALAAFFAIIAgAAAA==.',['炙殇']='炙殇:BAACLAAFFH8nAAMZAAYInBPuBgBwAQAZAAYIbA/uBgBwAQAfAAQIxhMXEQDyAAAsAAQKfx0AAxkACAi4E/0aAL8BABkACAi4E/0aAL8BAB8AAgjJBK9nAFMAAAAA.',['炫酷']='炫酷牛炸天:BAAALAAECgYIDAAAAA==.',['炸裂']='炸裂欧替丶:BAABLAAFFH8IAAIXAAgIiwKOPQB0AAAXAAgIiwKOPQB0AAAAAA==.',['烬之']='烬之舞焚寂诀:BAABLAAFFH8GAAIcAAYITAd2LAAzAQAcAAYITAd2LAAzAQAAAA==.',['烬妖']='烬妖娆:BAAALAADCgMIAwAAAA==.',['焚寂']='焚寂诀:BAABLAAFFH8fAAIbAAYIwRiYBACHAQAbAAYIwRiYBACHAQAAAA==.',['無敌']='無敌锋:BAABLAAFFH8bAAMOAAYIPiIjFQDpAQAOAAYIPiIjFQDpAQAPAAIIphgoCwCkAAAAAA==.',['無限']='無限:BAAALAAECgIIAgAAAA==.',['然懿']='然懿:BAACLAAFFH8LAAIXAAMItxRnLQCiAAAXAAMItxRnLQCiAAAsAAQKfx4AAhcACAjSIYUMAJECABcACAjSIYUMAJECAAAA.',['熠熠']='熠熠:BAABLAAECn80AAMEAAgIDBZMIgCiAQAEAAgIDBZMIgCiAQAaAAEIUQ9qPgAxAAAAAA==.',['燕青']='燕青:BAAALAAECgIIAgAAAA==.',['爱奔']='爱奔哥爱生活:BAAALAADCgYIBwAAAA==.',['爱死']='爱死机:BAAALAADCgcICQAAAA==.爱死积:BAAALAAECgcIBwAAAA==.',['牛奶']='牛奶加点冰:BAABLAAFFH8KAAIUAAIIYBAjFwBCAAAUAAIIYBAjFwBCAAAAAA==.',['牛德']='牛德鹿:BAAALAAECgYIDgAAAA==.',['牛总']='牛总:BAAALAAFFAIIBAAAAA==.牛总裁:BAAALAAFFAIIAgAAAA==.',['牛牛']='牛牛不吃菜:BAABLAAFFH8PAAIKAAIINRUIHQCFAAAKAAIINRUIHQCFAAABLAAFFAUIKAANALAWAA==.牛牛也圣光:BAACLAAFFH8WAAIGAAUICB2fJQBHAQAGAAUICB2fJQBHAQAsAAQKfxgAAgYABgjaGlppADABAAYABgjaGlppADABAAAA.牛牛看烟花:BAAALAAFFAIIAgAAAA==.',['犹豫']='犹豫血灵:BAACLAAFFH8dAAIHAAYIoxr6EwDCAQAHAAYIoxr6EwDCAQAsAAQKfxwAAgcABghoHdEsALEBAAcABghoHdEsALEBAAAA.',['狂野']='狂野猎手阿宏:BAAALAAECgcIBwAAAA==.',['狼弟']='狼弟肉惑:BAAALAAECgYIEgAAAA==.',['猎七']='猎七:BAAALAAFFAIIBAAAAA==.',['猎杀']='猎杀星辰:BAAALAAFFAIIAwAAAA==.',['猎魔']='猎魔:BAAALAAECgYIBgAAAA==.',['猫爱']='猫爱丶咖啡:BAAALAADCgIIAgAAAA==.',['猫猫']='猫猫頭:BAAALAAFFAIIAgAAAA==.',['獠牙']='獠牙:BAAALAAECgMIAwAAAA==.',['玉书']='玉书生:BAAALAAECgYIBgAAAA==.',['王仔']='王仔顺丰:BAABLAAFFH8gAAINAAYIwxR5JgCAAQANAAYIwxR5JgCAAQAAAA==.',['王等']='王等等丶:BAAALAAECgMIAwAAAA==.',['玫瑰']='玫瑰紫衣:BAAALAADCgMIAwAAAA==.',['珍妮']='珍妮弗康纳利:BAAALAAECgYIBgAAAA==.',['理塘']='理塘的绝凶虎:BAAALAAECgMIBgAAAA==.',['甜橙']='甜橙丿:BAAALAADCgcIBwAAAA==.',['疯蛙']='疯蛙:BAAALAAFFAIIAgAAAA==.',['痞子']='痞子丶五分冷:BAAALAADCgEIAQAAAA==.',['痞老']='痞老板痞总:BAAALAAECgYICQAAAA==.',['百年']='百年周星驰:BAABLAAFFH8nAAIOAAcIVCDUDwAQAgAOAAcIVCDUDwAQAgAAAA==.',['盾牌']='盾牌:BAAALAAECgcIBwAAAA==.',['破咦']='破咦嗷嫖:BAAALAAFFAIIAgAAAA==.',['硬汉']='硬汉猫猫头:BAABLAAFFH8cAAILAAYI5BxxGwBzAQALAAYI5BxxGwBzAQAAAA==.',['神圣']='神圣之心:BAAALAAECgEIAQAAAA==.',['神灵']='神灵之邪恶:BAAALAAFFAIIBAAAAA==.',['秋咪']='秋咪不吃鱼:BAAALAADCgEIAQABLAAFFAQICgAOAEETAA==.',['秋大']='秋大眠:BAACLAAFFH8GAAIBAAIIiw9xaACFAAABAAIIiw9xaACFAAAsAAQKfxYAAwEABggGG0i6AIcBAAEABgjWGUi6AIcBAAIAAwgXEmOXAJAAAAAA.',['秦宓']='秦宓:BAAALAADCgQIBAAAAA==.',['笨笨']='笨笨胖胖:BAAALAAECgUIDQAAAA==.',['第一']='第一:BAABLAAFFH8QAAIFAAQINBekIwD+AAAFAAQINBekIwD+AAAAAA==.',['第七']='第七:BAABLAAFFH8KAAIHAAIIohrVSwCFAAAHAAIIohrVSwCFAAAAAA==.第七王爵:BAAALAAECgYIEAAAAA==.',['第九']='第九:BAAALAAFFAIIBAAAAA==.',['第二']='第二:BAAALAAECgYIBgAAAA==.',['第八']='第八:BAAALAAFFAIIBAAAAA==.',['米蕾']='米蕾西亚:BAABLAAFFH8IAAMCAAII1xVUIwCBAAACAAII2RBUIwCBAAABAAII1xXrjABGAAAAAA==.',['糖葫']='糖葫芦:BAAALAADCgQIBAAAAA==.',['紫月']='紫月无痕:BAAALAAECgMIAwAAAA==.紫月梦魇:BAABLAAECn8YAAIOAAYIJB2SjwDgAQAOAAYIJB2SjwDgAQAAAA==.',['綄羙']='綄羙狼狼:BAACLAAFFH8GAAIYAAIIVw3ENAA7AAAYAAIIVw3ENAA7AAAsAAQKfx8AAhgABggNF/hNAH0BABgABggNF/hNAH0BAAAA.',['繁花']='繁花:BAAALAAECgQIBQABLAAFFAIIBAAWAAAAAA==.',['續寫']='續寫輝煌:BAAALAADCgQIBAAAAA==.',['纳兰']='纳兰姬灬:BAAALAAECgEIAQAAAA==.纳兰颖灬:BAAALAAECgYICQAAAA==.',['绝世']='绝世老毒奶:BAAALAAFFAIIAgAAAA==.',['缺钱']='缺钱的贼:BAAALAAFFAIIBAAAAA==.',['美少']='美少女:BAAALAAECgYIBgAAAA==.美少年卡卡:BAAALAAFFAIIAgAAAA==.美少年卡卡丶:BAAALAAFFAIIAgAAAA==.',['老丶']='老丶胡:BAAALAADCgIIAgAAAA==.',['老司']='老司机:BAABLAAFFH8KAAINAAUI9hPxNwAtAQANAAUI9hPxNwAtAQAAAA==.',['老师']='老师不记仇:BAAALAAECgYIBgAAAA==.',['老杨']='老杨头:BAAALAADCggICAAAAA==.',['老牛']='老牛:BAAALAAECgcICgAAAA==.',['老胡']='老胡:BAAALAAECgEIAQAAAA==.',['聆听']='聆听:BAAALAADCgcIBwAAAA==.',['肥牛']='肥牛:BAAALAADCgIIAgAAAA==.',['肺痒']='肺痒痒:BAABLAAFFH8VAAIHAAMIoCJeEgAnAQAHAAMIoCJeEgAnAQAAAA==.',['胖大']='胖大星:BAAALAAECgYIBgAAAA==.',['胤丶']='胤丶饕:BAAALAAECgMIAwAAAA==.',['胤灬']='胤灬绝夜:BAAALAAECgYIBgAAAA==.',['舒肝']='舒肝解郁:BAAALAADCgcIDgAAAA==.',['舞夜']='舞夜飞花:BAAALAADCgcIBwAAAA==.',['芒多']='芒多:BAAALAAECggIDAAAAA==.',['芙莉']='芙莉莲:BAACLAAFFH8ZAAMSAAUIGg/6CQCAAAANAAUIFg5/PQALAQASAAMIcQ36CQCAAAAsAAQKfxgAAxIABgj3FnY0AJsBABIABgj3FnY0AJsBAA0AAwhSCgrnAH8AAAAA.',['花容']='花容:BAAALAADCgEIAQAAAA==.',['花怎']='花怎么会落呢:BAAALAAECgYIBgAAAA==.',['花无']='花无十日红:BAAALAAFFAIIAgAAAA==.',['英俊']='英俊不刷血:BAAALAAECgcICAAAAA==.',['茅台']='茅台丶:BAAALAAECgYICwAAAA==.',['莫桑']='莫桑比克丶:BAABLAAFFH8PAAIBAAgIRBZ8CgDoAQABAAgIRBZ8CgDoAQAAAA==.',['萌虎']='萌虎超:BAAALAAECgQIBQAAAA==.',['萨大']='萨大满:BAAALAAECgYIBgAAAA==.',['落雪']='落雪蓝山:BAAALAAECggICAAAAA==.',['蓝霹']='蓝霹雳丷:BAAALAADCgEIAQAAAA==.',['虚无']='虚无缥缈:BAABLAAFFH8KAAILAAMIxh8VOACsAAALAAMIxh8VOACsAAAAAA==.',['虫儿']='虫儿的思念:BAAALAAECgYIBwAAAA==.',['虹霁']='虹霁:BAABLAAFFH8JAAIEAAIIlxkBJgChAAAEAAIIlxkBJgChAAAAAA==.',['蛮牛']='蛮牛妞:BAAALAAFFAMIAwAAAA==.',['血兽']='血兽来了:BAABLAAFFH8uAAMOAAYI0xx3GgDOAQAOAAYI0xx3GgDOAQATAAEIUwEyIAAZAAAAAA==.',['血域']='血域狂狼:BAABLAAFFH8QAAIXAAIIqBvXRABPAAAXAAIIqBvXRABPAAAAAA==.',['血牛']='血牛牛:BAAALAAFFAIIAgAAAA==.',['血色']='血色八字军:BAAALAAECggICAAAAA==.',['表弟']='表弟文武双全:BAABLAAECn8YAAMBAAYIYSKlTgCnAQABAAYIYSKlTgCnAQACAAYIcxF9ZAAvAQAAAA==.',['西地']='西地那非:BAAALAAECgIIAgAAAA==.',['西红']='西红柿炒辣椒:BAAALAAECgMIAwAAAA==.西红柿炒韭菜:BAAALAAECgUIBQAAAA==.',['西虹']='西虹市首富:BAAALAAFFAIIBAAAAA==.',['西门']='西门堕落:BAAALAAECgYIDAAAAA==.',['西顿']='西顿丶牛猎:BAABLAAFFH8NAAIBAAMIVgqsgQBSAAABAAMIVgqsgQBSAAAAAA==.',['要什']='要什么名字:BAACLAAFFH8UAAIcAAQInyBSGAAWAQAcAAQInyBSGAAWAQAsAAQKfx8AAhwABwhGI0gtAKgCABwABwhGI0gtAKgCAAAA.',['要关']='要关服了:BAAALAAFFAIIBAAAAA==.',['见怪']='见怪头一个冲:BAAALAADCgIIAgAAAA==.',['试甜']='试甜师:BAAALAAECgcICwAAAA==.',['诳汱']='诳汱病刄:BAAALAAECgYIBgAAAA==.',['豌豆']='豌豆蛐蛐:BAABLAAFFH8IAAIEAAII0Bx8NQCPAAAEAAII0Bx8NQCPAAAAAA==.',['贝莉']='贝莉:BAAALAADCgUIBQAAAA==.',['超大']='超大只哈吉米:BAABLAAFFH8pAAIOAAYIoCTZDgAYAgAOAAYIoCTZDgAYAgAAAA==.',['跑太']='跑太慢追不上:BAAALAAFFAIIAgAAAA==.',['跳豆']='跳豆:BAABLAAFFH8MAAIBAAYIKhHGPQBOAQABAAYIKhHGPQBOAQAAAA==.',['软萌']='软萌旺旺糖:BAACLAAFFH8eAAILAAYIMxdVIQCRAQALAAYIMxdVIQCRAQAsAAQKfx8AAgsACAjaG+kZANkBAAsACAjaG+kZANkBAAAA.',['轻丝']='轻丝:BAAALAADCgQIBAAAAA==.',['进击']='进击的圣骑:BAABLAAFFH8UAAIGAAYIURwsEgC2AQAGAAYIURwsEgC2AQAAAA==.',['迤逦']='迤逦萌牛:BAAALAAFFAIIAgABLAAFFAYIIAANAMMUAA==.',['追风']='追风小恶魔:BAAALAAECgIIBAAAAA==.',['逍遥']='逍遥小爷:BAAALAAFFAIIAgAAAA==.',['逐日']='逐日释然:BAACLAAFFH8IAAIHAAIIMAgxagBRAAAHAAIIMAgxagBRAAAsAAQKfxcAAwcACAiKGkl7AIoBAAcABgi9F0l7AIoBAAgAAgi3BWzHAE0AAAAA.',['邓太']='邓太阿:BAAALAAECgYIBgAAAA==.',['那枚']='那枚老船长:BAABLAAFFH8FAAMbAAMI5xiKDQCbAAAbAAIItRWKDQCbAAALAAEISx/vaABPAAAAAA==.',['郝小']='郝小浪:BAAALAADCgYIBgAAAA==.',['部落']='部落的希望:BAAALAAECggIDwAAAA==.',['鄳玺']='鄳玺:BAAALAAFFAIIAgAAAA==.',['酒馆']='酒馆灬光影:BAAALAAECgEIAQAAAA==.酒馆灬圣光:BAABLAAECn8VAAIGAAgIOxcKKAD0AQAGAAgIOxcKKAD0AQAAAA==.',['酷炫']='酷炫牛炸天:BAAALAAECgMIAwAAAA==.',['酷酷']='酷酷的艾米:BAAALAADCgEIAQAAAA==.',['醉卧']='醉卧丷伊人榻:BAABLAAFFH8MAAMXAAIIoRi5RgBMAAAXAAIIoRi5RgBMAAAKAAEI4hLqPAAAAAAAAA==.',['醉酒']='醉酒红尘:BAAALAAFFAIIAgABLAAFFAQIEAAKACsFAA==.',['醒着']='醒着做梦:BAAALAAECgYIEgAAAA==.',['释放']='释放丶:BAAALAAFFAIIAgAAAA==.',['野兽']='野兽派:BAACLAAFFH8KAAIBAAIIthqFRwCcAAABAAIIthqFRwCcAAAsAAQKfyUAAwEABgh5IUJSADoCAAEABgh5IUJSADoCAAIAAggWD/GlAGYAAAAA.',['釨鏶']='釨鏶鈼鉒:BAAALAAECgYIDwAAAA==.',['銶凛']='銶凛:BAABLAAFFH8GAAIRAAII8QI9GQBsAAARAAII8QI9GQBsAAAAAA==.',['铁憨']='铁憨憨:BAAALAAECgIIAwABLAAECgYIDgAWAAAAAA==.',['铁树']='铁树该鷥:BAACLAAFFH8gAAILAAUIeRU+LwDRAAALAAUIeRU+LwDRAAAsAAQKfyAAAgsACAjVGAE+AFMCAAsACAjVGAE+AFMCAAEsAAUUBgggAA0AwxQA.',['锋刃']='锋刃:BAAALAADCgQIBwAAAA==.',['锋锋']='锋锋:BAACLAAFFH8MAAIGAAUIWhyaJABNAQAGAAUIWhyaJABNAQAsAAQKfxkAAgYACAjdIBEgAPECAAYACAjdIBEgAPECAAAA.',['长得']='长得太丑:BAAALAADCgYIBgAAAA==.',['開宀']='開宀小能兽:BAAALAAFFAIIAgAAAA==.',['阿丽']='阿丽:BAAALAADCgUIBQAAAA==.',['阿兰']='阿兰:BAAALAAECgMIBQAAAA==.',['阿尔']='阿尔福雷德:BAAALAAECgYIDAAAAA==.',['阿康']='阿康公司:BAAALAAECgYIDwAAAA==.',['阿笠']='阿笠:BAAALAAECgYIBwAAAA==.',['阿莲']='阿莲:BAAALAADCgYIBgAAAA==.',['阿香']='阿香:BAAALAAECgQICwAAAA==.',['随风']='随风摇曳:BAAALAAECgQIBQAAAA==.',['雪记']='雪记:BAAALAADCgQIBAAAAA==.',['雷奥']='雷奥尼娅:BAAALAAECgYIDQAAAA==.',['霹雳']='霹雳五连鞭:BAABLAAFFH8KAAIIAAMIsg9ANQCIAAAIAAMIsg9ANQCIAAAAAA==.霹雳同学:BAABLAAFFH8KAAIGAAYIhhGjHgBwAQAGAAYIhhGjHgBwAQAAAA==.',['青青']='青青西红柿:BAACLAAFFH8FAAIBAAIINhpeTQCYAAABAAIINhpeTQCYAAAsAAQKfxoAAgEABwhsGy9TAJ0BAAEABwhsGy9TAJ0BAAAA.',['静夜']='静夜听雨:BAAALAADCgYIBAAAAA==.',['顶死']='顶死你:BAAALAAECgQIBAAAAA==.',['风愈']='风愈者雷伊:BAAALAAECgYIEAAAAA==.',['风暴']='风暴滋生:BAAALAAECgEIAQAAAA==.风暴降生:BAAALAAECgEIAQAAAA==.',['飞天']='飞天魔鬼本鬼:BAABLAAFFH8MAAIGAAUIgxKdLAAfAQAGAAUIgxKdLAAfAQAAAA==.',['飞黄']='飞黄腾达:BAABLAAFFH8PAAMHAAYI1hKYGgCHAQAHAAYI1hKYGgCHAQAIAAEI0Q4NQABKAAABLAAFFAYIFAATAD8cAA==.',['馒头']='馒头丶:BAAALAAECgYIBgAAAA==.',['香脆']='香脆锅巴:BAAALAAECgEIAQAAAA==.',['香草']='香草七:BAABLAAFFH8MAAIGAAIIvhd1OwChAAAGAAIIvhd1OwChAAAAAA==.',['香蕉']='香蕉:BAAALAADCgEIAQAAAA==.',['马什']='马什么梅呀:BAAALAAFFAIIAgAAAA==.',['骑过']='骑过小龙女:BAABLAAFFH8LAAIJAAQIxgVJEAB5AAAJAAQIxgVJEAB5AAABLAAFFAYIIAANAMMUAA==.',['骨凌']='骨凌冷火:BAAALAAECgYIBgAAAA==.',['高位']='高位截瘫:BAAALAAFFAIIAgAAAA==.',['高启']='高启强:BAAALAAECgYICAAAAA==.',['高端']='高端时代:BAAALAAECgEIAQAAAA==.高端熊猫:BAAALAAECgEIAQAAAA==.高端端:BAAALAAECgYIBgAAAA==.高端领主:BAAALAAECgEIAQAAAA==.',['高鹏']='高鹏飞太大惹:BAAALAAFFAIIAgAAAA==.',['鬼怪']='鬼怪:BAAALAAECgUIBQAAAA==.',['鸭力']='鸭力山大:BAAALAAECgYIBgAAAA==.',['麦田']='麦田圈制造者:BAABLAAECn8VAAMFAAgIhQgIfgAjAQAFAAgIhQgIfgAjAQAYAAYICQg/cQABAQAAAA==.',['黑洞']='黑洞奇点:BAAALAAECgYIBgAAAA==.',['黑神']='黑神话丷悟空:BAAALAAECgYIBgAAAA==.',['齐德']='齐德龙:BAACLAAFFH8KAAMFAAIIuRo3IgCcAAAFAAIIuRo3IgCcAAAgAAII/A8IDgCWAAAsAAQKfxgAAyAABgiRGRwcALoBACAABgiRGRwcALoBAAUABQjiHDxSAJ8BAAEsAAUUBAgKAA4AQRMA.齐德龙东强:BAABLAAFFH8MAAMGAAIICxLNPgCfAAAGAAIICxLNPgCfAAADAAIILhDMHACQAAABLAAFFAQICgAOAEETAA==.',['龍腾']='龍腾尛尨:BAAALAAECgYIBgAAAA==.龍腾尛龙:BAAALAAECgUIBQAAAA==.',['龙腾']='龙腾尛翔:BAAALAAECgEIAQAAAA==.',['龟愛']='龟愛:BAAALAAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end