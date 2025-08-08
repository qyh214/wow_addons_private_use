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
 local lookup = {'Unknown-Unknown','Mage-Arcane','Paladin-Holy','Paladin-Retribution','Priest-Shadow','Druid-Balance','Druid-Restoration','DemonHunter-Havoc','Monk-Mistweaver','Mage-Frost','Mage-Fire','DemonHunter-Vengeance','Shaman-Restoration','Shaman-Elemental','DeathKnight-Blood','Priest-Holy','Paladin-Protection','Warlock-Demonology','Warlock-Destruction','Hunter-BeastMastery','Hunter-Marksmanship','Evoker-Devastation','Evoker-Preservation','DeathKnight-Unholy','Monk-Windwalker','Rogue-Outlaw','Rogue-Subtlety','Druid-Guardian','Rogue-Assassination','Warrior-Arms','Warrior-Fury','Monk-Brewmaster','Druid-Feral','Warrior-Protection','Priest-Discipline','Warlock-Affliction',}; local provider = {region='CN',realm='希雷诺斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Af='Afterglow:BAAAKgAECgMIAwAAAA==.',Ag='Agonist:BAAAKgAECgYIBgAAAA==.',Al='Aluratek:BAAAKgADCgcIBwAAAA==.',As='Askua:BAAAKgAECgEIAQABKgAFFAIIAgABAAAAAA==.',Ba='Bartholemew:BAAAKgAFFAEIAgAAAA==.',Bu='Buonarroti:BAABKgAFFH8IAAICAAgIJAryCQDIAQACAAgIJAryCQDIAQAAAA==.',Ca='Casterkok:BAAAKgAECgYIDAAAAA==.',Cq='Cq:BAACKgAFFH8JAAIDAAIIZySgCQDDAAADAAIIZySgCQDDAAAqAAQKfxkAAwMACAi0JIoFAJUCAAMACAi0JIoFAJUCAAQABQgDGR2kAAYBAAAA.',Da='Darksage:BAAAKgADCggICAAAAA==.',De='Deathknigh:BAAAKgAECgcICwAAAA==.',Dh='Dhrzrf:BAAAKgAECgYIBgAAAA==.',Di='Dim:BAABKgAFFH8GAAIFAAYIZQSTEgDsAAAFAAYIZQSTEgDsAAAAAA==.',Er='Erukidu:BAAAKgAECgcIDAAAAA==.',Ge='Gelina:BAAAKgAFFAEIAQAAAA==.',He='Hellcat:BAABKgAFFH8UAAMGAAgIZxkiCgDyAQAGAAcIxBgiCgDyAQAHAAcI6wkACwBWAQAAAA==.',Ke='Kellylin:BAAAKgADCgMIAwAAAA==.',Kl='Klc:BAAAKgAECgYIEQAAAA==.',La='Lauryn:BAAAKgADCgcICAABKgAFFAIIAgABAAAAAA==.',Lo='Longlaugh:BAAAKgADCggIDwAAAA==.',Lt='Lt:BAABKgAECn8rAAIIAAgIgRlfKwC5AQAIAAgIgRlfKwC5AQAAAA==.',Mc='Mclennon:BAAAKgAECgIIAgAAAA==.',Md='Mdse:BAAAKgADCgIIAgAAAA==.Mdsg:BAAAKgAECgcIDwAAAA==.',Mi='Minwusen:BAABKgAFFH8IAAIJAAgIAhcCBAADAgAJAAgIAhcCBAADAgAAAA==.',Mo='Moon:BAAAKgAFFAUIAwAAAA==.Morewant:BAABKgAFFH8IAAMKAAgIDg99CgDbAAALAAQI8gotFAAZAQAKAAQIiRR9CgDbAAAAAA==.',Mu='Mushroom:BAAAKgAFFAgIBAAAAA==.',Pa='Pano:BAAAKgAFFAgIBAAAAA==.',Po='Poisonous:BAAAKgAECgYIBgAAAA==.',Re='Reliques:BAAAKgAECgIIAgAAAA==.Rexsar:BAAAKgAECgIIAgAAAA==.',Ri='Ricio:BAAAKgAECgcIBwAAAA==.',Ru='Rules:BAABKgAFFH8SAAMMAAMIRxbnCgCgAAAIAAMIUBMAKwDMAAAMAAMIVQ/nCgCgAAAAAA==.',Sa='Saurfang:BAAAKgAECgYIBgAAAA==.',So='Sobrave:BAAAKgADCgQIBAAAAA==.Socrizy:BAACKgAFFH8FAAMNAAII9gluSABoAAANAAII9gluSABoAAAOAAEIBArdJwA8AAAqAAQKfxkAAw4ACAi0GLwgAMUBAA4ABghiILwgAMUBAA0ACAjpFclnAAkBAAAA.',Sr='Srt:BAAAKgADCgEIAQAAAA==.',Su='Susie:BAAAKgADCgQIBAABKgAFFAIIAgABAAAAAA==.',Sy='Sylvonas:BAAAKgADCgcICAAAAA==.',Tc='Tc:BAAAKgAECgQIBAAAAA==.',Th='Thistle:BAAAKgAECgYIBgABKgAFFAgIAgABAAAAAA==.',Ts='Tsuru:BAABKgAFFH8GAAIPAAYI0g47EgAQAQAPAAYI0g47EgAQAQAAAA==.',Ve='Vermithor:BAAAKgAFFAgIAQAAAA==.',Vi='Viperboa:BAABKgAFFH8IAAIQAAgIpQGfDAABAQAQAAgIpQGfDAABAQAAAA==.',We='Wealth:BAACKgAFFH8PAAMEAAMIECKgEAASAQAEAAMIECKgEAASAQARAAMINg+gHACVAAAqAAQKfyQAAwQACAj+IS0jAI0CAAQACAj+IS0jAI0CABEACAguFxsTANQBAAAA.',Wg='Wgyll:BAAAKgADCgMIAwAAAA==.',Wy='Wyxjbd:BAAAKgAECgIIAgAAAA==.',Xw='Xwine:BAAAKgADCgIIAgAAAA==.',Yo='Yorick:BAAAKgAECgMIAwAAAA==.',Zh='Zhy:BAABKgAECn8WAAIEAAgIGxOEcgBwAQAEAAgIGxOEcgBwAQAAAA==.',Zl='Zlatan:BAAAKgAECggIDAAAAA==.',['一小']='一小唯一:BAACKgAFFH8LAAMSAAQI3hmDDQDKAAASAAQI9xeDDQDKAAATAAIIMhqjOwCBAAAqAAQKfyIAAxMACAjRInImAOEBABMABwi4G3ImAOEBABIABQi6HyMqAEUBAAAA.',['一幕']='一幕梦晚秋丶:BAAAKgAECgEIAQAAAA==.',['一念']='一念英一:BAAAKgAECgcICAAAAA==.',['一条']='一条虫:BAAAKgAFFAQIBAAAAA==.',['一根']='一根儿葱:BAABKgAFFH8IAAIJAAgI7wOoCgB9AQAJAAgI7wOoCgB9AQAAAA==.',['一步']='一步一安然:BAABKgAFFH8RAAMUAAQI9BrUJAD0AAAUAAQI9BrUJAD0AAAVAAMIMg/2GQCZAAAAAA==.',['一灭']='一灭神一:BAAAKgAECgcIBwAAAA==.',['一种']='一种数值的美:BAABKgAFFH8FAAIEAAMI1xgpIADoAAAEAAMI1xgpIADoAAAAAA==.',['一起']='一起吃香蕉:BAAAKgADCggIEAAAAA==.',['一路']='一路向北飘:BAABKgAFFH8IAAMGAAgI+Ap9DgCLAQAGAAcIUwt9DgCLAQAHAAEIvwFGGQAzAAAAAA==.',['七四']='七四贰:BAABKgAFFH8GAAIPAAYIXxALBQBAAQAPAAYIXxALBQBAAQAAAA==.',['七夜']='七夜狂风:BAAAKgAFFAEIAQAAAA==.',['七肆']='七肆二:BAAAKgAFFAMIAwAAAA==.七肆贰:BAABKgAFFH8MAAMWAAYIUiAjEAANAQAWAAYIUiAjEAANAQAXAAEI/AHcDAAqAAAAAA==.',['三十']='三十八号球衣:BAAAKgAFFAQIBAAAAA==.',['三月']='三月雪飘:BAABKgAECn8WAAIVAAgIFxv4GwAbAgAVAAgIFxv4GwAbAgAAAA==.',['不变']='不变的爱:BAABKgAFFH8GAAIEAAQIQCHjCwAlAQAEAAQIQCHjCwAlAQAAAA==.',['不德']='不德不帅:BAAAKgAECgMIAwAAAA==.',['不服']='不服来搞我:BAAAKgADCggICAAAAA==.',['不狠']='不狠不行:BAAAKgADCggICAABKgAFFAgIAgACAAIWAA==.',['与我']='与我常在:BAAAKgAECgEIAQAAAA==.',['专业']='专业吻戏导演:BAAAKgADCgYIBgAAAA==.专业吻戏演员:BAAAKgAECgQIBgAAAA==.专业床戏演员:BAAAKgADCgEIAQAAAA==.专业躺尸演员:BAAAKgAECgcICwAAAA==.',['世界']='世界萨丶老三:BAABKgAFFH8KAAINAAQIcQzUHQCPAAANAAQIcQzUHQCPAAAAAA==.',['丝丝']='丝丝入肉:BAAAKgAECgMIAwAAAA==.',['两个']='两个死骑:BAAAKgAECgQIAQAAAA==.两个神牧:BAAAKgADCgEIAQAAAA==.',['丨燃']='丨燃烧星辉丨:BAACKgAFFH8TAAMCAAcIGBYWFgAzAQACAAYIAxgWFgAzAQAKAAMI0AuzIwBxAAAqAAQKfxUAAwIACAhpIO8cAAoCAAIACAhVHe8cAAoCAAoABQgIJHkhAKYBAAEqAAUUBwgUAAQA9R4A.丨燃烧语灵丨:BAABKgAFFH8RAAIYAAQIyiBMJQD8AAAYAAQIyiBMJQD8AAABKgAFFAcIFAAEAPUeAA==.丨燃烧语风丨:BAACKgAFFH8HAAIZAAMIACDqDgDyAAAZAAMIACDqDgDyAAAqAAQKfyEAAhkACAjrIMALAJACABkACAjrIMALAJACAAEqAAUUBwgUAAQA9R4A.丨燃烧辉韵丨:BAACKgAFFH8UAAIEAAcI9R6iCAAjAgAEAAcI9R6iCAAjAgAqAAQKfxcAAgQACAh7JUQEAOwCAAQACAh7JUQEAOwCAAAA.',['丨罹']='丨罹梦丨:BAAAKgAFFAMIAgABKgAFFAYIAgABAAAAAA==.',['丨陸']='丨陸丨:BAACKgAFFH8GAAIaAAIIdhG8CAB+AAAaAAIIdhG8CAB+AAAqAAQKfx0AAxsACAjgGUwOAAMCABsACAj7F0wOAAMCABoACAh3EkcMAD0BAAEqAAUUBggCAAEAAAAA.',['丨鸢']='丨鸢尾丨:BAABKgAFFH8JAAIWAAYI3B23EgC9AAAWAAYI3B23EgC9AAAAAA==.',['丶一']='丶一叶婆娑:BAAAKgAFFAQIBAAAAA==.',['丶崩']='丶崩锅机器丶:BAAAKgAECgMIAwAAAA==.',['丶散']='丶散了流年:BAABKgAFFH8NAAIVAAMIWSFMGwAUAQAVAAMIWSFMGwAUAQAAAA==.',['丶王']='丶王怼怼:BAAAKgAFFAEIAQAAAA==.',['丶苍']='丶苍穹:BAAAKgADCgQIAwAAAA==.',['丷筱']='丷筱布:BAAAKgADCggICAAAAA==.',['丿众']='丿众神领域:BAAAKgADCgEIAQAAAA==.',['丿林']='丿林:BAAAKgAFFAQIBAAAAA==.',['丿火']='丿火舞灬魍魉:BAAAKgADCgIIAgAAAA==.',['九师']='九师兄:BAAAKgAFFAYIBAAAAA==.',['云秋']='云秋:BAAAKgADCgEIAQAAAA==.',['云长']='云长:BAAAKgADCggICAAAAA==.',['五个']='五个核桃:BAAAKgADCgYIBgAAAA==.五个猫:BAAAKgAECgIIAgAAAA==.',['亲亲']='亲亲猪宝贝:BAAAKgADCggIEAAAAA==.亲亲逍遥:BAAAKgADCgIIAgAAAA==.',['休伦']='休伦之凛:BAAAKgAECgIIAgAAAA==.',['伤心']='伤心小蜘蛛:BAABKgAFFH8IAAIIAAQIghpOEQD6AAAIAAQIghpOEQD6AAAAAA==.',['低俗']='低俗小说:BAAAKgAECgUIBQAAAA==.',['低头']='低头猛走:BAABKgAFFH8LAAMcAAMI2gxFCgBtAAAGAAMItANJJwCDAAAcAAII5RBFCgBtAAAAAA==.',['低調']='低調芃:BAAAKgAECggICAAAAA==.',['作业']='作业扛把子:BAABKgAECn8cAAINAAgIZxCaHQBDAQANAAgIZxCaHQBDAQAAAA==.',['你们']='你们这群基:BAABKgAFFH8IAAMMAAMIjxFrEwCoAAAMAAMIjxFrEwCoAAAIAAMI/gPUOQCYAAAAAA==.',['你猜']='你猜啊:BAAAKgADCggICAAAAA==.你猜猜我是谁:BAAAKgADCggICAAAAA==.',['依宝']='依宝宝:BAAAKgAECgQIBQAAAA==.',['依然']='依然詆调:BAAAKgADCggIDQAAAA==.',['信圣']='信圣光得脚气:BAAAKgADCggICAAAAA==.',['健康']='健康吃出来:BAAAKgADCggICAAAAA==.',['傻朝']='傻朝朝:BAAAKgAECgYIBgAAAA==.',['先卤']='先卤为敬:BAAAKgAECgEIAQAAAA==.',['全球']='全球变暖:BAACKgAFFH83AAMbAAcIWCNRAQCLAQAdAAcI8SIfBABiAgAbAAUIUyBRAQCLAQAqAAQKfygAAhsACAgdJDsDAMkCABsACAgdJDsDAMkCAAAA.',['八级']='八级小狂风:BAABKgAFFH8KAAITAAYIeBjhEQB6AQATAAYIeBjhEQB6AQAAAA==.',['公子']='公子小宝:BAABKgAECn8jAAMeAAgI8hvHDwAlAgAeAAgI8hvHDwAlAgAfAAIIShaUdwCCAAAAAA==.',['其实']='其实很犀利:BAAAKgAECgUIBwAAAA==.',['冰棠']='冰棠血狸:BAAAKgAECgcIBwABKgAFFAYIHAACALocAA==.',['冷水']='冷水泡面:BAAAKgADCggICAAAAA==.',['冷酸']='冷酸灵:BAABKgAECn8iAAMZAAgIeRuyBgAxAgAZAAgIeRuyBgAxAgAgAAIIxwnXFwAdAAAAAA==.',['凶狠']='凶狠小瞎子:BAAAKgAFFAMIAwAAAA==.',['努力']='努力的小阿依:BAAAKgAECgcIBwAAAA==.',['勃艮']='勃艮第:BAABKgAFFH8GAAIYAAYITBkEFQBzAQAYAAYITBkEFQBzAQAAAA==.',['匍匐']='匍匐的青春:BAABKgAFFH8GAAIQAAYICB1YBwCBAQAQAAYICB1YBwCBAQAAAA==.',['北極']='北極星的眼淚:BAAAKgAECgYIBgABKgAFFAgIBAABAAAAAA==.',['十亿']='十亿少女的梦:BAABKgAFFH8KAAMfAAgIpxcJBABkAQAfAAgIWxUJBABkAQAeAAEIaRImFgBeAAAAAA==.',['十月']='十月丶晴:BAAAKgAECgIIAgAAAA==.',['千岚']='千岚逐枫者:BAAAKgAECgIIAgAAAA==.',['单脚']='单脚跳吃葡萄:BAAAKgAFFAQIBAAAAA==.',['卡布']='卡布灬奇诺:BAAAKgADCgEIAQAAAA==.',['双枪']='双枪入罡:BAAAKgADCgEIAQAAAA==.',['只有']='只有中杯大杯:BAABKgAFFH8LAAINAAMIqRcjFwC7AAANAAMIqRcjFwC7AAAAAA==.',['叫我']='叫我丹姐:BAAAKgADCggICAAAAA==.',['可乐']='可乐永远醒目:BAAAKgAFFAYIAQAAAA==.',['可怜']='可怜的人:BAAAKgADCgYIBgAAAA==.',['叶落']='叶落抚尘:BAACKgAFFH8JAAIQAAQIRhmbGwDgAAAQAAQIRhmbGwDgAAAqAAQKfyQAAhAACAhIFi0jAMoBABAACAhIFi0jAMoBAAAA.',['吃蘑']='吃蘑菇:BAAAKgAECggICAAAAA==.',['吇叽']='吇叽侳鉒:BAAAKgAECgYICQAAAA==.',['吉瀛']='吉瀛尛龙:BAAAKgAECgYIBgAAAA==.',['吉非']='吉非替尼:BAAAKgAFFAQIBAAAAA==.',['后一']='后一射日:BAAAKgADCggICAAAAA==.',['君临']='君临异世:BAAAKgAECggICAAAAA==.',['含笑']='含笑半步癫:BAAAKgAECgIIAgAAAA==.',['听风']='听风说往事:BAAAKgAECggIDgAAAA==.',['吹个']='吹个大气球:BAAAKgADCgEIAQABKgAFFAgICgAhACESAA==.',['呼吸']='呼吸衰竭:BAABKgAFFH8FAAMPAAQItxN4EgCwAAAPAAQI+RB4EgCwAAAYAAEIYR7LUQBLAAAAAA==.',['咕咕']='咕咕一:BAAAKgAECgcIDwAAAA==.',['咸魚']='咸魚先生:BAAAKgAECgYIBgAAAA==.',['哈莉']='哈莉露雅:BAABKgAFFH8IAAIEAAgILwEUKgC/AAAEAAgILwEUKgC/AAAAAA==.',['哎呦']='哎呦我肾掉了:BAAAKgAECggICAAAAA==.',['哥哥']='哥哥疼你:BAAAKgAECgYIBgAAAA==.',['喜相']='喜相逢:BAAAKgADCggICAAAAA==.',['喵星']='喵星人灬辰:BAAAKgAECgUIBQAAAA==.',['嘻嘻']='嘻嘻晓空:BAABKgAFFH8GAAIfAAYIoBK6DQB3AQAfAAYIoBK6DQB3AQAAAA==.',['嘿嘿']='嘿嘿丶五月风:BAAAKgADCggICAAAAA==.嘿嘿哈哈大王:BAAAKgAECggIDwAAAA==.',['四六']='四六炮灬:BAABKgAECn8hAAITAAgIvxsSGwAgAgATAAgIvxsSGwAgAgAAAA==.',['四十']='四十米大砍刀:BAAAKgAECgQICAAAAA==.',['四喜']='四喜汤圆:BAAAKgAECgYIDwAAAA==.',['回忆']='回忆之刃:BAABKgAFFH8aAAIiAAMILg0YCQCVAAAiAAMILg0YCQCVAAAAAA==.',['回来']='回来树棍的:BAAAKgADCgQIBAAAAA==.',['土著']='土著人:BAAAKgADCggIDgAAAA==.',['圣光']='圣光之刃:BAAAKgAFFAEIAQAAAA==.圣光强国:BAAAKgAECgQIBAAAAA==.圣光溪林:BAAAKgAECgYIBgAAAA==.',['圣精']='圣精灵寳:BAAAKgAECggIBgAAAA==.',['埃斯']='埃斯埃姆:BAAAKgAECgMIAwAAAA==.',['堕落']='堕落街使者:BAAAKgAFFAMIAwAAAA==.',['墨碳']='墨碳:BAAAKgADCggICAAAAA==.',['壞脾']='壞脾氣:BAAAKgAECgMIAwAAAA==.',['夕阳']='夕阳下的奔跑:BAAAKgAECggICAAAAA==.',['夜半']='夜半问歌:BAAAKgAFFAIIAgAAAA==.',['大师']='大师兄丶:BAAAKgAFFAQIBAAAAA==.',['大暗']='大暗黑天丶:BAAAKgADCgMIAwAAAA==.',['大波']='大波浪:BAAAKgADCgIIAgAAAA==.',['大菊']='大菊观丶:BAAAKgAFFAQIBAAAAA==.',['天使']='天使与魔法:BAAAKgAECgcICgAAAA==.',['天涯']='天涯咫尺:BAAAKgAECggICAAAAA==.',['天界']='天界大魔法:BAAAKgAECgcIDQAAAA==.',['天蓝']='天蓝腿毛:BAAAKgAECggIDAAAAA==.',['套你']='套你哇一:BAAAKgAECggIDgAAAA==.',['奥蕾']='奥蕾克西娅:BAAAKgAFFAIIAgAAAA==.',['如汤']='如汤沃雪:BAABKgAFFH8SAAIIAAYIORoDAgDZAQAIAAYIORoDAgDZAQAAAA==.',['妖妖']='妖妖菱:BAABKgAFFH8TAAIFAAYIqSBVCACKAQAFAAYIqSBVCACKAQABKgAFFAgIBAABAAAAAA==.',['妖术']='妖术:BAAAKgAECggICQAAAA==.',['妖精']='妖精的尾吧:BAAAKgAECgMIAwAAAA==.',['宋小']='宋小夏:BAAAKgADCgYIBwAAAA==.',['宝矿']='宝矿力:BAAAKgAFFAUIBAABKgAFFAgICAAIALwWAA==.',['实习']='实习骑士:BAABKgAFFH8FAAIYAAUIKiK6EACWAQAYAAUIKiK6EACWAQAAAA==.',['寂寞']='寂寞的绿豆:BAAAKgAFFAYIBAAAAA==.',['小乖']='小乖:BAAAKgAECgEIAQAAAA==.',['小伙']='小伙有样:BAAAKgAECgUIBQAAAA==.',['小太']='小太子乃:BAAAKgAECgUIBQAAAA==.',['小孩']='小孩子少吃糖:BAAAKgAECgYIBgAAAA==.',['小小']='小小胡丶:BAAAKgAFFAIIAQAAAA==.小小萨来也:BAACKgAFFH8nAAMNAAYIix3qBwCaAQANAAYIix3qBwCaAQAOAAEIawFaGQAgAAAqAAQKfz4AAg0ACAjzJFkGAMQCAA0ACAjzJFkGAMQCAAAA.',['小术']='小术点:BAABKgAFFH8HAAITAAcI/Au4EQB8AQATAAcI/Au4EQB8AQAAAA==.',['小毛']='小毛豆:BAAAKgAECgMIAwAAAA==.',['小泽']='小泽馬利亚:BAAAKgADCgMIAwAAAA==.',['小猫']='小猫兜:BAAAKgAECgMIAwAAAA==.',['小福']='小福尼:BAAAKgAFFAMIAwAAAA==.',['小胡']='小胡莉:BAAAKgAECgcICQAAAA==.',['小萨']='小萨鲁法尔:BAAAKgAFFAMIAwABKgAFFAYIEgAjAGEdAA==.',['小野']='小野丶:BAAAKgADCgMIAwAAAA==.',['小雪']='小雪碧丶:BAABKgAECn8WAAIVAAgI/iK5FQAjAgAVAAgI/iK5FQAjAgABKgAFFAgICAAUAHMNAA==.',['就抓']='就抓德:BAABKgAFFH8ZAAIVAAUISBWXCgBvAQAVAAUISBWXCgBvAQAAAA==.',['尼古']='尼古丁珍:BAAAKgADCgQIBAAAAA==.尼古丁男爵:BAAAKgAECgUIBwAAAA==.尼古丁真:BAAAKgAFFAIIAgAAAA==.尼古丁针:BAAAKgAECgMIAwAAAA==.',['尼山']='尼山萨满:BAAAKgADCgIIAgAAAA==.',['屁屁']='屁屁看这裏:BAACKgAFFH8bAAMdAAUIbCR8AgCgAQAdAAUIeSJ8AgCgAQAbAAMInSSjAgA1AQAqAAQKfy0AAxsACAhIJdoCANACABsACAiPJNoCANACAB0ABQjpIjoUAPYBAAAA.',['岑风']='岑风暴烈久:BAAAKgAECgIIAgAAAA==.',['川流']='川流不灭:BAAAKgAECgEIAQAAAA==.',['巧巧']='巧巧妈妈:BAAAKgAECggIDwABKgAFFAYIBgATAC8hAA==.',['带小']='带小号用的:BAAAKgAECggIEQAAAA==.',['幽暗']='幽暗之神:BAABKgAFFH8KAAQDAAIIcAIVEgBsAAADAAIIcAIVEgBsAAAEAAIIQQN1hQBQAAARAAIIYQEPFQA6AAAAAA==.',['幽灵']='幽灵菇传说:BAAAKgAECgQIBAAAAA==.',['开奶']='开奶:BAAAKgADCgYIBgAAAA==.',['弗拉']='弗拉基米尔:BAABKgAECn8VAAIYAAgI7CFHGQBoAgAYAAgI7CFHGQBoAgAAAA==.',['很嚣']='很嚣张:BAAAKgAECgMIAwAAAA==.',['德儿']='德儿塔:BAAAKgAECggIEgAAAA==.',['心头']='心头肉:BAABKgAFFH8IAAIJAAgIWAi3BwB+AQAJAAgIWAi3BwB+AQAAAA==.',['心思']='心思云梦:BAAAKgAFFAYIAgAAAA==.',['忆丶']='忆丶花花:BAAAKgAECggICAAAAA==.',['快乐']='快乐的小母牛:BAABKgAFFH8IAAIEAAQIUyBdDAAjAQAEAAQIUyBdDAAjAQAAAA==.',['忽觉']='忽觉满城空:BAAAKgAECgQIBAAAAA==.',['悠悠']='悠悠吾心:BAAAKgADCgIIAwAAAA==.',['想抓']='想抓个小德:BAACKgAFFH8IAAMVAAMIeB8VKADKAAAVAAMIeB8VKADKAAAUAAEIgyAJQQBgAAAqAAQKfyAAAxUACAh3IgIGAIgCABUACAg+IgIGAIgCABQABAhMHtCfAOcAAAAA.',['憨憨']='憨憨德:BAABKgAFFH8SAAMhAAMITxo7BQDtAAAhAAMIvBk7BQDtAAAGAAMIFBGxNwDBAAAAAA==.',['我不']='我不是彭于晏:BAAAKgAECgcIBwAAAA==.',['我是']='我是传奇:BAAAKgAECgYIBgAAAA==.我是熊猫:BAAAKgADCggICAAAAA==.',['我没']='我没有糖:BAAAKgAECgMIAwAAAA==.我没有糖了:BAAAKgAECggIDAAAAA==.',['手提']='手提酱油:BAABKgAFFH8PAAMKAAMIox/OCwANAQAKAAMIox/OCwANAQACAAEI4QUpKQA1AAAAAA==.',['抓只']='抓只小德:BAABKgAFFH8IAAIVAAMImxLEFAC+AAAVAAMImxLEFAC+AAAAAA==.',['抽烟']='抽烟的小裁缝:BAAAKgADCggICAAAAA==.',['拉雨']='拉雨:BAAAKgAECggICAAAAA==.',['掌控']='掌控丶规则:BAAAKgAECgIIAgAAAA==.',['摩挲']='摩挲楚殇:BAACKgAFFH8XAAQQAAcIoiC6AwAXAgAQAAcIFSC6AwAXAgAFAAYIMBG1BAB7AQAjAAQISxzkBwAbAQAqAAQKfxwAAwUACAjUGnEXANQBAAUABwguG3EXANQBACMAAgjuFSBlAJMAAAEqAAUUCAgNACMA2hwA.',['支吾']='支吾猪:BAAAKgADCgUIBQAAAA==.',['敏捷']='敏捷:BAABKgAECn8fAAIUAAgIkR3CRADnAQAUAAgIkR3CRADnAQAAAA==.',['文人']='文人丶:BAAAKgAECgUIBQAAAA==.',['斗私']='斗私批修:BAAAKgAFFAIIAgAAAA==.',['斩丶']='斩丶死亡猎手:BAAAKgAECgIIAwAAAA==.',['星光']='星光熠熠:BAAAKgADCggICAAAAA==.',['昨日']='昨日风尘:BAABKgAECn8YAAMHAAgI3iH3BwCMAgAHAAgI3iH3BwCMAgAGAAgIIROSRQCVAQAAAA==.',['暖暖']='暖暖幸福:BAABKgAECn8ZAAIEAAgIMSQLHgCgAgAEAAgIMSQLHgCgAgABKgAFFAIIAgABAAAAAA==.',['暗夜']='暗夜小牧:BAABKgAFFH8YAAQFAAgIahd7BwCeAQAFAAcI6hd7BwCeAQAQAAYIaxS2BwD5AAAjAAMIPRBwHACLAAAAAA==.',['更欢']='更欢笑:BAAAKgADCgMIAwAAAA==.',['曾经']='曾经丨怀念:BAAAKgAECgEIAQAAAA==.',['木婉']='木婉清:BAAAKgAFFAcIBAAAAA==.',['机智']='机智的亮闪闪:BAAAKgAECgMIBAAAAA==.机智的老黄牛:BAAAKgAECgEIAQAAAA==.',['来几']='来几个:BAABKgAFFH8FAAICAAMIfRCcLgCpAAACAAMIfRCcLgCpAAAAAA==.',['杭州']='杭州小笼包:BAAAKgAECgcIEQAAAA==.',['杰哥']='杰哥:BAAAKgADCggICgAAAA==.杰哥丶:BAAAKgADCgQIBAAAAA==.',['柒肆']='柒肆贰:BAAAKgAFFAIIAgAAAA==.',['柯镇']='柯镇恶:BAABKgAFFH8LAAIYAAYIzxpoFAB3AQAYAAYIzxpoFAB3AQAAAA==.',['核桃']='核桃:BAAAKgADCggICAAAAA==.',['棕色']='棕色垃圾职业:BAAAKgAECgIIAgAAAA==.',['橘绿']='橘绿橙黄时:BAABKgAECn8UAAMEAAgI6h/KIAB/AgAEAAgIrh/KIAB/AgARAAIInBw3OQClAAAAAA==.',['橙子']='橙子:BAABKgAFFH8IAAIVAAMIHBY5JwDOAAAVAAMIHBY5JwDOAAAAAA==.',['橙黄']='橙黄橘绿时:BAABKgAFFH8IAAQTAAQI4hXeJgDWAAATAAQI4hXeJgDWAAAkAAEIMARHFAAyAAASAAEIAAC7GwAAAAAAAA==.',['欧煌']='欧煌:BAAAKgAFFAMIAwAAAA==.',['歌之']='歌之守护者:BAACKgAFFH8GAAITAAYIOh1lEwBrAQATAAYIOh1lEwBrAQAqAAQKfxUAAhMACAhJHvUcABUCABMACAhJHvUcABUCAAAA.',['殷桃']='殷桃:BAAAKgAECgIIAgAAAA==.',['氰化']='氰化氢:BAAAKgADCggIEAAAAA==.',['水果']='水果仙人:BAABKgAFFH8UAAIGAAQITQtSHwC3AAAGAAQITQtSHwC3AAAAAA==.',['汐釉']='汐釉乄:BAABKgAFFH8GAAIEAAQIlRroHADwAAAEAAQIlRroHADwAAAAAA==.',['江夏']='江夏的提款机:BAAAKgADCggICAAAAA==.',['沐沐']='沐沐灬:BAAAKgAECgYIBwAAAA==.',['沙格']='沙格列汀:BAAAKgADCggIDgAAAA==.',['没必']='没必要哇:BAAAKgAFFAQIAwABKgAFFAgIBAABAAAAAA==.',['泡泡']='泡泡味进口糖:BAAAKgAFFAQIBAABKgAFFAgIEwAUAOUdAA==.',['泪色']='泪色:BAAAKgADCgYIBgAAAA==.',['流云']='流云乱:BAAAKgAFFAIIAgAAAA==.',['流风']='流风回雪:BAAAKgAECgcIBwAAAA==.',['浅然']='浅然:BAAAKgAECgIIBAAAAA==.',['浩哥']='浩哥丶:BAAAKgAECgQIBAAAAA==.',['浪不']='浪不过一杯酒:BAAAKgAECgMIAwAAAA==.',['浪哩']='浪哩个狼:BAAAKgAECgEIAQAAAA==.',['混世']='混世魔王:BAAAKgAECggIDQAAAA==.',['湖风']='湖风:BAAAKgADCgcIBwAAAA==.',['漠漠']='漠漠暗香如云:BAAAKgAFFAUIAgABKgAFFAgICgAEACQhAA==.',['潘帕']='潘帕斯:BAAAKgAECgYICAAAAA==.',['潘达']='潘达的希望:BAAAKgADCgQIBAAAAA==.',['灬刺']='灬刺丶芒灬:BAABKgAFFH8IAAIRAAgIXg4lBgCMAQARAAgIXg4lBgCMAQAAAA==.',['灬吼']='灬吼丶:BAAAKgAECgUIBQAAAA==.',['灬娜']='灬娜娜灬:BAAAKgAECgUIDQAAAA==.',['灰常']='灰常红:BAAAKgAECggICwAAAA==.',['灵芝']='灵芝孢子粉:BAAAKgAECgQIBAAAAA==.',['炙殇']='炙殇:BAAAKgAECgEIAQAAAA==.',['烈女']='烈女仓库:BAAAKgADCgUIBQAAAA==.',['焚寂']='焚寂诀:BAABKgAFFH8LAAIKAAMITQ6dGQCuAAAKAAMITQ6dGQCuAAAAAA==.',['然懿']='然懿:BAACKgAFFH8HAAIfAAII/g7mHgCZAAAfAAII/g7mHgCZAAAqAAQKfzQCAx8ACAhGJVQCAAUDAB8ACAhGJVQCAAUDACIAAwhqESQvAJUAAAAA.',['熠熠']='熠熠:BAAAKgAECggICAAAAA==.',['爱奔']='爱奔哥爱生活:BAAAKgAECgEIAQAAAA==.',['爱死']='爱死机:BAAAKgAECgQIBAAAAA==.',['牛总']='牛总裁:BAAAKgADCggIEAAAAA==.',['牛牛']='牛牛也圣光:BAACKgAFFH8XAAIEAAMIwR7WOAAIAQAEAAMIwR7WOAAIAQAqAAQKfxUAAgQACAhAGfKSAHEBAAQACAhAGfKSAHEBAAAA.',['犸猴']='犸猴烧酒:BAAAKgAECgEIAQAAAA==.',['狂野']='狂野猎手阿宏:BAAAKgAECgUIBgAAAA==.',['狐猎']='狐猎猎:BAAAKgAECgIIAgAAAA==.',['玉生']='玉生烟:BAABKgAFFH8IAAIGAAYI1RosEgCLAQAGAAYI1RosEgCLAQAAAA==.',['王安']='王安全:BAABKgAFFH8FAAMIAAUIXw6qHADSAAAIAAQIRguqHADSAAAMAAEIqhc4FgBMAAAAAA==.',['王扬']='王扬:BAAAKgAECgYIBwAAAA==.',['甜橙']='甜橙丿:BAABKgAFFH8FAAIFAAMIKBGYGAC3AAAFAAMIKBGYGAC3AAAAAA==.',['电磁']='电磁撸火花扣:BAAAKgAFFAQIBAAAAA==.',['痞子']='痞子丶三分冷:BAAAKgAFFAIIAgAAAA==.',['矮子']='矮子句魔:BAAAKgAFFAMIAwABKgAFFAUIGQAVAEgVAA==.',['神不']='神不哀伤:BAAAKgAECgYICwAAAA==.',['神圣']='神圣之心:BAAAKgAECgQIBAAAAA==.',['离别']='离别:BAAAKgAECggIAgAAAA==.',['秂巠']='秂巠賁善:BAAAKgAFFAEIAQAAAA==.',['秋咪']='秋咪不吃鱼:BAABKgAFFH8FAAIjAAMI8yCiBwAWAQAjAAMI8yCiBwAWAQABKgAFFAgICgAhACESAA==.',['秋大']='秋大眠:BAABKgAFFH8IAAIVAAgI5xUVCADdAQAVAAgI5xUVCADdAQAAAA==.',['笨笨']='笨笨胖胖:BAAAKgAFFAQIBAAAAA==.',['第七']='第七王爵:BAAAKgAECggIEwAAAA==.',['米米']='米米大魔王:BAABKgAECn8XAAMEAAgIRyB+LwBiAgAEAAgIRyB+LwBiAgARAAEI6QNVawAOAAAAAA==.',['米蕾']='米蕾西亚:BAABKgAFFH8GAAIVAAYIWxwXDgB7AQAVAAYIWxwXDgB7AQAAAA==.',['紫米']='紫米雪狸:BAAAKgAECgYIEQABKgAFFAYIHAACALocAA==.',['綄羙']='綄羙狼狼:BAAAKgADCgQIBAAAAA==.',['繁华']='繁华丶若梦:BAAAKgAFFAYIBAAAAA==.',['繁花']='繁花:BAABKgAFFH8IAAIdAAMIjBJQGgDYAAAdAAMIjBJQGgDYAAABKgAFFAUIDgAfAJQZAA==.',['红烧']='红烧排骨饭:BAAAKgAECgIIAgAAAA==.',['纳兰']='纳兰姬灬:BAAAKgAECgEIAQAAAA==.纳兰颖灬:BAAAKgAFFAQIBAAAAA==.',['美少']='美少年萨满:BAABKgAFFH8GAAINAAYIrA/dEwDVAAANAAYIrA/dEwDVAAABKgAFFAgICAANALsbAA==.',['老好']='老好人:BAAAKgADCgMIAwAAAA==.',['老杨']='老杨头:BAAAKgADCgEIAQAAAA==.',['耳朵']='耳朵丶:BAABKgAFFH8HAAITAAcIZQzwDwCRAQATAAcIZQzwDwCRAQAAAA==.',['至高']='至高邪牛:BAAAKgADCgMIAwAAAA==.',['舒肝']='舒肝解郁:BAABKgAFFH8NAAINAAcIThgpCADEAQANAAcIThgpCADEAQAAAA==.',['舞夜']='舞夜灬妙音:BAAAKgAECgIIAgAAAA==.',['艾泽']='艾泽泰森:BAAAKgAECgYICAAAAA==.',['芙莉']='芙莉莲:BAACKgAFFH8IAAITAAMI2gsXMQCqAAATAAMI2gsXMQCqAAAqAAQKfx4AAxMACAjbDpw1ADgBABMACAjODpw1ADgBABIAAwh0Cg5lAHMAAAAA.',['茅台']='茅台丶:BAAAKgAECgQICAAAAA==.',['莉迪']='莉迪亚:BAAAKgADCggICAAAAA==.',['莎依']='莎依拉晨风:BAAAKgAECggICAAAAA==.',['菲儿']='菲儿丶:BAAAKgAECgcIBwAAAA==.',['萌有']='萌有萌的萌法:BAAAKgADCggICAAAAA==.',['蒙奇']='蒙奇奇:BAABKgAFFH8GAAIfAAYIrAdXEABQAQAfAAYIrAdXEABQAQAAAA==.',['虹霁']='虹霁:BAAAKgAFFAQIBAAAAA==.',['蛮牛']='蛮牛妞:BAABKgAFFH8MAAMYAAYIwQbdJAD/AAAYAAYI4QLdJAD/AAAPAAYImQb7CgDQAAAAAA==.',['血兽']='血兽来了:BAABKgAFFH8IAAMYAAQIqgkjHwCoAAAYAAQIRwQjHwCoAAAPAAQIqgnDJgB8AAAAAA==.',['血域']='血域狂狼:BAAAKgAECggIEAAAAA==.',['表弟']='表弟文武双全:BAAAKgAECgIIAwAAAA==.表弟能文能武:BAAAKgAECgYICAAAAA==.',['西门']='西门堕落:BAAAKgAECgEIAQAAAA==.',['试甜']='试甜师:BAAAKgAECggIDgABKgAFFAIIAgABAAAAAA==.',['诛心']='诛心:BAABKgAFFH8KAAMPAAYILRdsCwBbAQAPAAYILRdsCwBbAQAYAAQI7AnMGgDAAAAAAA==.',['请来']='请来打扰:BAAAKgAECgMIAwAAAA==.',['诺安']='诺安蔡经理:BAABKgAECn8fAAIZAAgIkhjRGQARAgAZAAgIkhjRGQARAgAAAA==.',['诺西']='诺西纳生钠:BAAAKgAECgUIBQAAAA==.',['谁家']='谁家的小乖:BAABKgAFFH8GAAIEAAYIaSCqFgCmAQAEAAYIaSCqFgCmAQAAAA==.',['超人']='超人怎么会飞:BAAAKgADCgQIBAAAAA==.',['超大']='超大只哈吉米:BAAAKgAFFAMIAwAAAA==.',['足疗']='足疗纳入医保:BAAAKgAFFAIIAgAAAA==.',['软萌']='软萌旺旺糖:BAAAKgAECgIIAgAAAA==.',['轻云']='轻云蔽月:BAAAKgAFFAQIAQABKgAFFAgIHAAGADYlAA==.',['达叔']='达叔还没上车:BAAAKgAECggIDgAAAA==.',['迁逐']='迁逐:BAAAKgAECgIIAgAAAA==.',['近战']='近战停手:BAAAKgAECggICQAAAA==.近战核弹:BAAAKgAECgcIEAAAAA==.',['进击']='进击的圣骑:BAABKgAFFH8RAAMEAAYI7RzvIABrAQAEAAYI2xzvIABrAQARAAUI9BQ5BwDuAAAAAA==.',['远程']='远程停手:BAAAKgAECgIIAgAAAA==.',['迷人']='迷人的二胖:BAAAKgAECgMIAwAAAA==.',['邓太']='邓太阿:BAAAKgAECggIBAAAAA==.',['邪能']='邪能小子:BAAAKgAECggIEAAAAA==.',['郝小']='郝小浪:BAAAKgADCgUIBQAAAA==.',['部落']='部落的希望:BAABKgAFFH8FAAITAAUIwyF9FwBIAQATAAUIwyF9FwBIAQAAAA==.',['鄳玺']='鄳玺:BAABKgAFFH8GAAIJAAYI/ARyFQD5AAAJAAYI/ARyFQD5AAAAAA==.',['酷酷']='酷酷的艾米:BAAAKgAECgYIBgAAAA==.',['醉酒']='醉酒红尘:BAACKgAFFH8LAAIfAAQIuBHIEQDzAAAfAAQIuBHIEQDzAAAqAAQKfx4AAx8ACAiZFCswAMMBAB8ACAiOEyswAMMBACIABQhrEcMoAOcAAAAA.',['釨鏶']='釨鏶鈼鉒:BAAAKgAECgcICAAAAA==.',['铁树']='铁树该鷥:BAABKgAFFH8KAAMCAAMI5w4LBwBXAAACAAMI5w4LBwBXAAALAAEIMAHvQgAlAAABKgAFFAUIGQAVAEgVAA==.',['银月']='银月圣光:BAAAKgAECgIIAgAAAA==.',['锋锋']='锋锋:BAABKgAFFH8HAAIEAAQI7iMfMQAkAQAEAAQI7iMfMQAkAQAAAA==.',['锦上']='锦上添花:BAABKgAFFH8SAAMjAAQIYR2xCAD5AAAjAAQIYR2xCAD5AAAQAAMIpQvCLACRAAAAAA==.',['開宀']='開宀小能兽:BAAAKgADCgEIBQAAAA==.',['阿兰']='阿兰:BAAAKgAFFAEIAQAAAA==.',['阿斯']='阿斯塔特:BAAAKgADCggICAAAAA==.',['阿隆']='阿隆索斯法奥:BAAAKgADCgEIAQAAAA==.',['随风']='随风摇曳:BAAAKgAFFAIIAgAAAA==.',['雪色']='雪色的红:BAAAKgADCggIGAAAAA==.',['霜狱']='霜狱裁决者:BAAAKgAECgQIBAAAAA==.',['青青']='青青西红柿:BAACKgAFFH8IAAIUAAYIghkCEAB6AQAUAAYIghkCEAB6AQAqAAQKfyEAAhQACAh6HzQcAFYCABQACAh6HzQcAFYCAAAA.',['顶死']='顶死你:BAAAKgADCggICAAAAA==.',['风儿']='风儿甚是喧嚣:BAAAKgAECgIIAgAAAA==.',['风岚']='风岚飞雪:BAABKgAFFH8FAAIFAAQIGRiwDgDnAAAFAAQIGRiwDgDnAAAAAA==.',['风影']='风影踏云行:BAAAKgAECgIIAgABKgAFFAgICgAhACESAA==.',['风愈']='风愈者雷伊:BAAAKgADCggICAAAAA==.',['风魔']='风魔:BAAAKgAFFAEIAQAAAA==.',['飯灬']='飯灬大將军:BAAAKgAFFAQIBAAAAA==.',['饮小']='饮小烧:BAAAKgADCgEIAQAAAA==.',['香草']='香草七:BAABKgAFFH8MAAIEAAMIsBy6PQD4AAAEAAMIsBy6PQD4AAAAAA==.',['香蕉']='香蕉:BAAAKgAECgYIBgAAAA==.',['骑过']='骑过小龙女:BAAAKgAECgEIAwABKgAFFAUIGQAVAEgVAA==.',['骨凌']='骨凌冷火:BAAAKgAECgMIBgAAAA==.',['高端']='高端熊猫:BAAAKgAECgYICQAAAA==.高端领主:BAAAKgAECgcIEAAAAA==.',['高贵']='高贵女大:BAAAKgAECgYIBgAAAA==.',['鲨鱼']='鲨鱼蜡椒:BAAAKgAECgUIBQAAAA==.',['鸭力']='鸭力山大:BAABKgAFFH8FAAIfAAUIRgozHADkAAAfAAUIRgozHADkAAAAAA==.',['鼻涕']='鼻涕鬼:BAAAKgAFFAgIBAAAAA==.',['齐德']='齐德龙:BAACKgAFFH8KAAIhAAMIIRKTBADjAAAhAAMIIRKTBADjAAAqAAQKfxgAAwcACAhUGkkJAOgBAAcACAhUGkkJAOgBACEABggNGAYYAAEBAAAA.齐德龙东强:BAACKgAFFH8GAAMDAAUI/RO7DADiAAADAAQIDxS7DADiAAAEAAIIlhNpMwCVAAAqAAQKfxQAAwMACAhaIRUFAJ0CAAMACAhaIRUFAJ0CAAQAAgg4GptzAFgAAAEqAAUUCAgKACEAIRIA.',['龙喵']='龙喵傲天:BAAAKgAFFAMIAwAAAA==.',['龙小']='龙小竹:BAAAKgAECgEIAQAAAA==.',['龙腾']='龙腾尛法:BAAAKgAECgIIAgAAAA==.龙腾猎手:BAAAKgAECgYIBgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end