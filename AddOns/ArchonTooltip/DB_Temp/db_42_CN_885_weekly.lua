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
 local lookup = {'Priest-Discipline','Priest-Shadow','Mage-Arcane','Mage-Fire','Shaman-Restoration','Shaman-Elemental','Warrior-Arms','Hunter-BeastMastery','Druid-Balance','Druid-Feral','Unknown-Unknown','Paladin-Protection','Paladin-Retribution','Hunter-Marksmanship','DemonHunter-Havoc','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','DeathKnight-Frost','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Holy','Priest-Holy','Mage-Frost','Monk-Mistweaver','Monk-Brewmaster','Warrior-Fury','DemonHunter-Vengeance','Druid-Restoration','Rogue-Assassination','Rogue-Subtlety','Monk-Windwalker','Warrior-Protection','Shaman-Enhancement','Druid-Guardian',}; local provider = {region='CN',realm='风暴峭壁',name='CN',type='weekly',zone=42,date='2025-08-04',data={Ac='Acfun:BAAAKgAECgUIBQAAAA==.',Ad='Adamt:BAAAKgAECggICAAAAA==.',Ai='Aito:BAABKgAFFH8GAAMBAAYIHhJ0FADzAAABAAUIaA10FADzAAACAAEIEg7QKwBEAAAAAA==.',Am='Amazon:BAAAKgADCgcICAAAAA==.',Aq='Aqualwitch:BAABKgAFFH8KAAMDAAYIbRxCEABpAQADAAYIbRxCEABpAQAEAAQI8wmMIwDIAAAAAA==.',At='Atroposs:BAAAKgAFFAMIBAAAAA==.',Aw='Awgqwg:BAAAKgAECgQIBAAAAA==.',Br='Braveheat:BAAAKgAECgIIAgAAAA==.',Cl='Clemmy:BAAAKgAFFAQIBAAAAA==.',Cp='Cppxy:BAAAKgAECgYIDQAAAA==.',Cu='Curaplke:BAACKgAFFH86AAMFAAUIfB97DAD3AAAFAAQIhiJ7DAD3AAAGAAUIlgiyCgDiAAAqAAQKf2IAAwUACAgRJmEDAOICAAUACAgRJmEDAOICAAYAAgiqDyguAFAAAAAA.Custa:BAAAKgAECgIIAgAAAA==.',De='Devileye:BAAAKgAECgQIBgAAAA==.',Di='Diesel:BAABKgAFFH8FAAIHAAQIvQ1JCwDbAAAHAAQIvQ1JCwDbAAAAAA==.',Dk='Dk:BAAAKgAECgIIAgAAAA==.',Dp='Dps:BAABKgAECn8ZAAIIAAYIMSHJRQDjAQAIAAYIMSHJRQDjAQAAAA==.',Fi='Firmament:BAABKgAFFH8LAAIJAAIIVSD+IgCpAAAJAAIIVSD+IgCpAAAAAA==.',Gr='Greenlight:BAAAKgAECgIIAgAAAA==.',Gv='Gvares:BAAAKgAFFAgIAQAAAA==.',Ho='Hoothoot:BAABKgAFFH8GAAIKAAQIrBPrBgDNAAAKAAQIrBPrBgDNAAAAAA==.',Is='Ishmael:BAAAKgAECgQICQABKgAFFAIIAgALAAAAAA==.',Ko='Koi:BAAAKgAECggICAAAAA==.',Lo='Longgray:BAAAKgAECgQIBAAAAA==.',Ma='Malakh:BAABKgAFFH8PAAIMAAQIiQIlEgBhAAAMAAQIiQIlEgBhAAAAAA==.Manchester:BAAAKgAFFAIIAgAAAA==.Marlee:BAAAKgAECgYICQAAAA==.',Mi='Michael:BAAAKgAECgQIBAAAAA==.Mintrandir:BAAAKgAECgQIBgAAAA==.',No='Nolan:BAABKgAFFH8KAAINAAgIFx/5DADRAQANAAgIFx/5DADRAQAAAA==.',Pl='Playertewmnu:BAAAKgAECgMIAwAAAA==.Playervdpywx:BAACKgAFFH8FAAIIAAMIeRiXJgDrAAAIAAMIeRiXJgDrAAAqAAQKfyIAAwgACAh6I5kFALwCAAgACAh6I5kFALwCAA4AAgjzFtiBAHgAAAAA.',Po='Pokemongo:BAAAKgAECgcIBwAAAA==.',Pp='Ppaalldd:BAAAKgAECggICAAAAA==.',Pr='Protectxj:BAABKgAFFH8OAAIPAAgIyRm2BgA5AgAPAAgIyRm2BgA5AgAAAA==.Proxius:BAAAKgAFFAQIBAAAAA==.',Re='Renée:BAABKgAFFH8GAAQQAAYIkxj9KQDGAAAQAAQItxv9KQDGAAARAAEIaRzcIQBFAAASAAEIUguMKwBDAAAAAA==.',Sa='Santacruz:BAAAKgAECggIDQAAAA==.',St='Stamcm:BAABKgAFFH8RAAINAAQIbxtIPQD5AAANAAQIbxtIPQD5AAAAAA==.Stamyy:BAABKgAFFH8VAAIPAAQIGwroGwCxAAAPAAQIGwroGwCxAAAAAA==.Stamzj:BAABKgAFFH8LAAITAAQIohK1CQDOAAATAAQIohK1CQDOAAAAAA==.Starless:BAAAKgAECggICAAAAA==.',Su='Summerbloom:BAACKgAFFH8PAAMUAAgIWRQvDADMAQAUAAgI7REvDADMAQATAAIIIBkCDwCJAAAqAAQKfxkABBMACAjmIlEEAJ0CABMACAjmIlEEAJ0CABUABwgtEEssACwBABQAAwjDHaiKAMUAAAAA.',To='Tocca:BAAAKgAFFAMIAQAAAA==.',Tr='Tristafei:BAAAKgADCgIIAgAAAA==.',Ve='Vera:BAAAKgAFFAYIBAAAAA==.',Yr='Yrel:BAABKgAECn8ZAAINAAgIgB0+PAA6AgANAAgIgB0+PAA6AgAAAA==.',Zn='Znye:BAABKgAECn8cAAIGAAgI+hynFgAVAgAGAAgI+hynFgAVAgAAAA==.',['一位']='一位慈善家:BAAAKgAFFAgIAgAAAA==.',['一只']='一只海龟成功:BAAAKgAECgQIBAAAAA==.',['一叶']='一叶秋风落:BAAAKgAFFAMIAwAAAA==.',['一天']='一天多一点:BAABKgAECn8ZAAMNAAgIaRncJwCGAQANAAgIaRncJwCGAQAWAAgIGBPwGwCBAQAAAA==.',['一念']='一念沧海桑田:BAAAKgAECgEIAQAAAA==.',['一缕']='一缕烟尘:BAAAKgAFFAQIBAABKgAFFAgIBgAVAOACAA==.',['一花']='一花一世界丶:BAABKgAFFH8nAAMXAAQIBCJqEQAnAQAXAAQIBCJqEQAnAQACAAQI3wiPFAC/AAAAAA==.',['一贱']='一贱为生:BAAAKgAECgQIBAAAAA==.',['一飞']='一飞冲天:BAAAKgAECggICAAAAA==.',['万州']='万州糍粑:BAAAKgAECgUIBQAAAA==.',['万物']='万物皆可盘:BAAAKgAECggIAwAAAA==.',['三生']='三生三世:BAAAKgADCgIIAgAAAA==.',['世界']='世界最强:BAABKgAECn8mAAMGAAgIgx58EwBQAgAGAAgIgx58EwBQAgAFAAEIEQPvyQAkAAABKgAFFAgICwAFADAbAA==.世界第一萨满:BAABKgAFFH8LAAMFAAYIMBsjDACGAQAFAAYIMBsjDACGAQAGAAEI1xc5JQBQAAAAAA==.',['东江']='东江湖之歌:BAAAKgAECgUIBQAAAA==.',['丨傷']='丨傷丨印:BAAAKgADCggICAAAAA==.',['丨安']='丨安吉斯丶:BAAAKgAECgEIAQABKgAFFAgIBAALAAAAAA==.',['丨梦']='丨梦灬魇丶:BAAAKgAECgIIAgAAAA==.',['丨灵']='丨灵魂医者丨:BAAAKgADCgQIBAAAAA==.',['丰申']='丰申惠娴:BAABKgAFFH8NAAIFAAQIixGuKQDPAAAFAAQIixGuKQDPAAAAAA==.',['临安']='临安初雨:BAACKgAFFH8FAAIIAAQIYRgBDwA3AQAIAAQIYRgBDwA3AQAqAAQKfxYAAggACAhxIP0YAGsCAAgACAhxIP0YAGsCAAAA.',['临时']='临时加:BAAAKgAFFAIIAgAAAA==.',['丶丨']='丶丨惘:BAAAKgADCgIIAgAAAA==.',['丶冷']='丶冷剑:BAAAKgAECgUIBQAAAA==.',['丶凝']='丶凝墨:BAAAKgADCggICAAAAA==.',['丶圣']='丶圣骑:BAAAKgADCgcIBwAAAA==.',['丶小']='丶小星星:BAABKgAFFH8JAAMVAAQIWRqzCgDxAAAVAAQIWRqzCgDxAAAUAAQIAwshGQDNAAABKgAFFAgIBAALAAAAAA==.',['丶摩']='丶摩尔迦娜:BAACKgAFFH8gAAMEAAgIiBxTAwDcAQADAAgIJBkRBQBJAgAEAAYICyBTAwDcAQAqAAQKfxUABAMACAieIDcZACYCAAQACAjlHEobAFACAAMABwibIjcZACYCABgAAgijHkpmAGIAAAAA.',['丶杰']='丶杰森斯坦森:BAAAKgAECgEIAQAAAA==.',['丶楛']='丶楛髏:BAABKgAECn8UAAMZAAgIsQ/+JgBYAQAZAAgIsQ/+JgBYAQAaAAQIvwPHHwBPAAAAAA==.',['丶药']='丶药药:BAABKgAFFH8FAAIFAAQIvgc5PwCLAAAFAAQIvgc5PwCLAAAAAA==.',['丶莫']='丶莫言:BAAAKgAECgcIBwAAAA==.',['丶葯']='丶葯葯:BAAAKgAECgMIAwAAAA==.',['丿射']='丿射你一箭:BAAAKgADCggICAAAAA==.',['丿霂']='丿霂:BAAAKgADCggICAAAAA==.',['丿风']='丿风骑:BAAAKgADCgQIBAAAAA==.',['久伴']='久伴丷:BAAAKgAECggIEQAAAA==.',['么么']='么么战熊:BAAAKgAECgQIBAAAAA==.',['义博']='义博橒兲:BAAAKgADCggICAAAAA==.',['乔沃']='乔沃德汏奈嗞:BAAAKgADCggICAAAAA==.',['乖乖']='乖乖猪:BAABKgAFFH8GAAIXAAYITBzbCACYAQAXAAYITBzbCACYAQAAAA==.',['二十']='二十一桥:BAAAKgADCggICAAAAA==.',['二青']='二青灬疾风:BAAAKgADCggICwAAAA==.',['云轻']='云轻烟弱:BAABKgAECn8cAAINAAgI3yAfIgB5AgANAAgI3yAfIgB5AgAAAA==.',['云飘']='云飘飘:BAAAKgAECgcICAAAAA==.',['亡零']='亡零杰克:BAAAKgAECgMIAwAAAA==.',['享受']='享受每一天:BAAAKgAFFAQIBAAAAA==.',['仁致']='仁致箭则无敌:BAAAKgAECgIIAgAAAA==.',['今夜']='今夜明珠色:BAAAKgAECgMIAwAAAA==.',['今晚']='今晚有貓貓:BAABKgAFFH8OAAIXAAgImBt6BQDeAQAXAAgImBt6BQDeAQAAAA==.',['代三']='代三男猛:BAAAKgAECgYIBwAAAA==.',['以何']='以何为:BAABKgAECn8YAAIbAAgIviEeCQCrAgAbAAgIviEeCQCrAgAAAA==.',['伊丽']='伊丽莎白铁柱:BAAAKgADCggICAAAAA==.',['伊克']='伊克莱敷:BAAAKgAECgIIAgAAAA==.',['伍里']='伍里雾里:BAAAKgAECgIIAgAAAA==.',['会飞']='会飞的蜗牛:BAAAKgAFFAQIBAAAAA==.',['低调']='低调的哀伤:BAAAKgAECgYIDAAAAA==.',['你好']='你好棒棒:BAAAKgAECgUICAAAAA==.',['依然']='依然不听你的:BAAAKgAECggICAAAAA==.',['假装']='假装很牛叉:BAABKgAFFH8FAAINAAMIwRVqUADPAAANAAMIwRVqUADPAAAAAA==.',['傅崇']='傅崇碧:BAAAKgAFFAQIBAAAAA==.',['傷不']='傷不道:BAAAKgAECgIIAgAAAA==.',['傻傻']='傻傻的羊:BAAAKgAECgQIBAAAAA==.',['傻熊']='傻熊咖啡豆:BAAAKgAECgMIBgAAAA==.',['元素']='元素:BAAAKgADCggICAAAAA==.',['兜风']='兜风耳:BAAAKgAECgQIBAAAAA==.',['全村']='全村你最棒:BAABKgAECn8eAAMYAAgItBxCFwD9AQAYAAgItBxCFwD9AQADAAYIcgyOWgDXAAAAAA==.',['八兄']='八兄弟同赏月:BAABKgAFFH8IAAIcAAgIhQf7AwBdAQAcAAgIhQf7AwBdAQAAAA==.',['公子']='公子世無双:BAAAKgADCgUIBQAAAA==.',['其实']='其实我也难过:BAABKgAFFH8GAAIPAAYIwxU/FgBJAQAPAAYIwxU/FgBJAQAAAA==.',['再打']='再打我报警:BAACKgAFFH8qAAQVAAgIQCGLAQCrAgAVAAgILSGLAQCrAgAUAAYI4hRqHwAkAQATAAYI/RLTAgD1AAAqAAQKfxYAAhQACAg7IHMZAGcCABQACAg7IHMZAGcCAAAA.',['冰封']='冰封忆记:BAAAKgAECgQIBAAAAA==.',['冰小']='冰小哥:BAAAKgAECgQIBAAAAA==.',['冰火']='冰火龘龘:BAAAKgAECgYIBgAAAA==.',['凯瑟']='凯瑟斯玲娜:BAABKgAFFH8GAAINAAYIeyEUGACcAQANAAYIeyEUGACcAQAAAA==.',['凶猛']='凶猛大白鲨:BAAAKgAFFAYIBAABKgAFFAgICAAIAHkgAA==.',['切位']='切位离丶:BAABKgAFFH8IAAIBAAMI/BXxGADKAAABAAMI/BXxGADKAAAAAA==.',['初心']='初心逐风:BAAAKgADCgcIBwAAAA==.',['刻骨']='刻骨茗心:BAAAKgAFFAEIAQAAAA==.',['勇敢']='勇敢的战神:BAAAKgAECgYIBgAAAA==.勇敢的朋友:BAAAKgADCggICAAAAA==.',['包弖']='包弖头:BAABKgAFFH8IAAIIAAgIIAdjCgCtAQAIAAgIIAdjCgCtAQAAAA==.',['北方']='北方海默:BAAAKgAFFAYIBAAAAA==.',['卡布']='卡布佳:BAABKgAFFH8KAAIFAAMICCF/GAAfAQAFAAMICCF/GAAfAQAAAA==.',['叁点']='叁点壹肆贰:BAAAKgADCgYIBgAAAA==.',['双手']='双手玩闪电:BAAAKgAECgYICgAAAA==.',['双马']='双马尾滴西:BAAAKgADCggICAAAAA==.',['发福']='发福的中年人:BAAAKgAFFAEIAQAAAA==.',['变態']='变態:BAAAKgAECgUICQAAAA==.',['口火']='口火口火灬:BAACKgAFFH8dAAMZAAQInxY0HAC8AAAZAAQInxY0HAC8AAAaAAEIAACNDQAAAAAqAAQKfx8AAxkACAj2Fr4lAMkBABkACAj2Fr4lAMkBABoAAQhkAH8rAAgAAAAA.',['只会']='只会一点点:BAAAKgAFFAEIAQAAAA==.',['只猎']='只猎你的心:BAAAKgAECggIDAAAAA==.',['叫发']='叫发丝的萨满:BAAAKgAECgEIAQAAAA==.',['叮叮']='叮叮喵喵:BAAAKgAFFAMIAwAAAA==.',['叶纚']='叶纚:BAAAKgADCggICgAAAA==.',['叶落']='叶落独舞:BAAAKgADCgMIAwAAAA==.',['吃鱼']='吃鱼割女腰子:BAABKgAECn8jAAQYAAgINRswKgDRAQAYAAgINRswKgDRAQADAAQIBhOsbACcAAAEAAQI7QyafACOAAAAAA==.',['吕師']='吕師傅:BAAAKgAECgMIAwAAAA==.',['启哥']='启哥好叻:BAAAKgAECggIEQAAAA==.启哥好狂:BAAAKgAECgYIDAAAAA==.',['周周']='周周真可爱:BAAAKgAFFAQIBAAAAA==.',['周贱']='周贱贱同学:BAACKgAFFH8LAAIUAAQIbBS1LQDYAAAUAAQIbBS1LQDYAAAqAAQKfxcAAhQACAgsHycVAGICABQACAgsHycVAGICAAAA.',['咕噜']='咕噜噜王子:BAACKgAFFH8LAAIJAAgIORIaGgBJAQAJAAgIORIaGgBJAQAqAAQKfx8AAgkACAipINUWAH4CAAkACAipINUWAH4CAAAA.咕噜灬丨:BAACKgAFFH8XAAIFAAQIQxvZEQDrAAAFAAQIQxvZEQDrAAAqAAQKfxwAAgUACAh6GDknAPEBAAUACAh6GDknAPEBAAEqAAUUCAgnABcABCIA.',['咖米']='咖米源:BAACKgAFFH8HAAMIAAMIXA6fOAC2AAAIAAMIXA6fOAC2AAAOAAII9QTkTABLAAAqAAQKfxkAAwgACAhtHPMlAB4CAAgABwhtHPMlAB4CAA4ACAiFEBFAAFIBAAAA.',['咬人']='咬人晓虫:BAAAKgAECgIIAgAAAA==.',['哇哇']='哇哇哒:BAAAKgAECgUIEQAAAA==.',['哒滴']='哒滴哒滴:BAAAKgADCgIIAgAAAA==.',['哪吒']='哪吒永闯天涯:BAAAKgAECgYIDQAAAA==.',['唯一']='唯一的女神:BAABKgAECn8lAAIbAAgICiKmCACxAgAbAAgICiKmCACxAgAAAA==.',['喂勒']='喂勒丶部落:BAAAKgAECgIIAgAAAA==.',['喔汣']='喔汣醬:BAABKgAFFH8HAAINAAYI5SJDDgDyAQANAAYI5SJDDgDyAQAAAA==.',['嗜血']='嗜血死神:BAAAKgAECgcICgAAAA==.',['嗨你']='嗨你的魔力酒:BAAAKgADCgQIBQAAAA==.',['回忆']='回忆的爱好:BAAAKgAECgUIBwAAAA==.',['回眸']='回眸一笑:BAAAKgAECgMIAwAAAA==.',['囧灬']='囧灬猎:BAAAKgAFFAgIAgAAAA==.',['圣光']='圣光之锤:BAAAKgADCgYIBgAAAA==.圣光龘龘:BAAAKgAFFAMIAwAAAA==.',['圣珺']='圣珺美璟:BAAAKgAECgMIAwAAAA==.',['圣罗']='圣罗莎:BAABKgAFFH8FAAIMAAUI7Q9ECgDrAAAMAAUI7Q9ECgDrAAAAAA==.',['在眼']='在眼泪上雕刻:BAABKgAFFH8UAAIFAAMIoBzOEgDhAAAFAAMIoBzOEgDhAAAAAA==.',['地狱']='地狱的使者:BAABKgAECn8hAAQTAAgIORqGCgAKAgATAAgIORqGCgAKAgAUAAYIohLwWQATAQAVAAYIKwo1OACjAAAAAA==.',['坠落']='坠落之心:BAAAKgAECgIIAgAAAA==.',['堕落']='堕落意旨:BAAAKgAFFAQIBAAAAA==.',['墓中']='墓中无人:BAAAKgAFFAEIAQAAAA==.',['墮落']='墮落伊利谭:BAAAKgAECgIIAgAAAA==.墮落殪丗:BAAAKgAECgIIAgAAAA==.',['士非']='士非闇:BAAAKgAECgYIBgAAAA==.',['壮丶']='壮丶风暴烈酒:BAAAKgAECggICAAAAA==.',['夜幕']='夜幕丶冷血:BAAAKgAECgYIBgAAAA==.',['夜雨']='夜雨十三浪:BAAAKgADCggICAAAAA==.',['夢眼']='夢眼迷离:BAAAKgAECgcICwAAAA==.',['大叔']='大叔爱抗怪:BAAAKgADCgcIBwAAAA==.',['大淇']='大淇淇:BAAAKgAFFAEIAgAAAA==.',['大雨']='大雨疯骑:BAAAKgAECgEIAQAAAA==.',['大雷']='大雷:BAABKgAFFH8HAAMCAAYI9BFMDAA6AQACAAYI9BFMDAA6AQAXAAEIbQJqKQAxAAAAAA==.',['大领']='大领主图拉炀:BAABKgAECn8XAAINAAcIhRV5oABXAQANAAcIhRV5oABXAQAAAA==.',['大黄']='大黄:BAABKgAFFH8GAAIZAAYINwqjCwACAQAZAAYINwqjCwACAQAAAA==.',['天使']='天使的呢喃:BAAAKgADCgIIAgAAAA==.',['天子']='天子驾九:BAABKgAFFH8GAAINAAYIdxdMHACDAQANAAYIdxdMHACDAQAAAA==.',['天蝎']='天蝎座丶无声:BAAAKgAECgMIAwAAAA==.',['天行']='天行:BAAAKgAECggIEQAAAA==.',['奇尔']='奇尔希丶银:BAAAKgAFFAIIAgAAAA==.',['奇想']='奇想天恸:BAABKgAFFH8JAAINAAMIJRi7PgD1AAANAAMIJRi7PgD1AAAAAA==.',['奕然']='奕然寳唄:BAAAKgADCggICAAAAA==.',['女王']='女王大人倩児:BAAAKgAECgEIAQAAAA==.',['奶坚']='奶坚强:BAAAKgADCgIIAgAAAA==.',['如丶']='如丶如:BAAAKgAECgUIBwAAAA==.',['如冰']='如冰虽不冻:BAAAKgAECgIIAgAAAA==.',['妖婧']='妖婧姐姐:BAAAKgAECgYIBwAAAA==.',['妮屁']='妮屁屁:BAAAKgAECggICAAAAA==.',['姬彡']='姬彡小双:BAAAKgAECgIIAgAAAA==.',['婉拒']='婉拒少妋百次:BAABKgAECn8UAAISAAgIfxZ8FQDWAQASAAgIfxZ8FQDWAQAAAA==.',['婲星']='婲星雨:BAACKgAFFH8GAAIUAAYI8R3hEQCLAQAUAAYI8R3hEQCLAQAqAAQKfxYAAxUACAgIGc0iAHQBABUACAiYFM0iAHQBABQABQjBHkFlADYBAAAA.',['婲淚']='婲淚婲落:BAAAKgADCgIIAgAAAA==.',['孤帆']='孤帆:BAAAKgAECggICAAAAA==.',['守护']='守护女神之战:BAAAKgAECggIDwAAAA==.',['安蘇']='安蘇芮克之刃:BAAAKgADCgIIAgAAAA==.',['宝贝']='宝贝别哭:BAAAKgAECgEIAQAAAA==.',['宠物']='宠物比我高:BAACKgAFFH8RAAMOAAQIYR1tIgDnAAAOAAQIYR1tIgDnAAAIAAEIDBCaXwA3AAAqAAQKfzsAAw4ACAh2I2cNAJACAA4ACAh2I2cNAJACAAgACAiZHeQfAHcCAAAA.',['容易']='容易折的肋骨:BAAAKgAECgEIAQAAAA==.',['寂寞']='寂寞小妖:BAAAKgADCgYIBgAAAA==.',['射你']='射你玩:BAABKgAFFH8GAAIIAAMIqhAfGQDKAAAIAAMIqhAfGQDKAAAAAA==.',['射妮']='射妮还不了手:BAAAKgAECgEIAQAAAA==.',['射得']='射得比你狠:BAABKgAFFH8GAAIOAAYI8AVxIADzAAAOAAYI8AVxIADzAAAAAA==.',['小不']='小不点露西:BAAAKgADCgUIBQAAAA==.',['小古']='小古凉:BAAAKgAECggIEAAAAA==.',['小吥']='小吥懂:BAAAKgAECgUIBQAAAA==.',['小哔']='小哔凯:BAAAKgAECgUIBQAAAA==.',['小学']='小学生物老师:BAAAKgADCggIEAAAAA==.',['小小']='小小黑妞:BAABKgAFFH8FAAMJAAUIjg+vPAC0AAAJAAQIiAyvPAC0AAAdAAEIhRovMQBTAAAAAA==.',['小意']='小意丶:BAAAKgAFFAQIBAAAAA==.',['小时']='小时候救过人:BAABKgAECn8pAAMIAAgIIRqoSADaAQAIAAgI8RioSADaAQAOAAYIXRppMgBpAQAAAA==.小时候救过火:BAAAKgAECgIIAwAAAA==.小时候的圣光:BAAAKgAECgEIAQAAAA==.',['小明']='小明丶:BAABKgAFFH8KAAMeAAYICh2vCgCiAQAeAAYICh2vCgCiAQAfAAQIWwzxCADjAAAAAA==.',['小母']='小母牛倒立:BAAAKgAECgYIBgAAAA==.',['小矮']='小矮子:BAABKgAFFH8KAAMTAAMIPRdHCADkAAATAAMIYRRHCADkAAAUAAMINRR2NwC9AAAAAA==.',['小而']='小而葝:BAAAKgAECgUIBQAAAA==.',['小腿']='小腿抽筋:BAAAKgAECgEIAQAAAA==.',['小蛇']='小蛇头:BAAAKgAECgEIAQAAAA==.',['小鸽']='小鸽鸽来玩呀:BAAAKgADCgcIBwAAAA==.',['小鹿']='小鹿儿乱撞:BAAAKgAECgIIAgAAAA==.',['少时']='少时诵诗书啊:BAABKgAECn8WAAIDAAgIgBsVCQBOAgADAAgIgBsVCQBOAgAAAA==.',['尛孟']='尛孟起:BAACKgAFFH88AAMIAAgIiR9wCQDcAQAIAAgIaB5wCQDcAQAOAAUIQRzVFAA8AQAqAAQKfy8AAwgACAhFJbMIAOkCAAgACAhFJbMIAOkCAA4AAQinGzaQACoAAAAA.',['就瞅']='就瞅你了:BAAAKgAECgYIAwAAAA==.',['巧克']='巧克力:BAAAKgAECgIIAgAAAA==.',['差了']='差了丶:BAABKgAFFH8IAAIgAAMIvRzdDQD/AAAgAAMIvRzdDQD/AAABKgAFFAYIFQACAPMhAA==.',['巴御']='巴御前:BAABKgAFFH8JAAIZAAgIhAm2BwB8AQAZAAgIhAm2BwB8AQAAAA==.',['库里']='库里南:BAAAKgADCgMIAwAAAA==.',['庞然']='庞然小捅:BAABKgAECn8WAAMeAAgI1BkoDgAkAgAeAAgI1BkoDgAkAgAfAAIIgQQKNwA9AAAAAA==.',['开令']='开令可:BAAAKgADCgYIBgAAAA==.',['弹指']='弹指灬红颜老:BAAAKgAFFAgIBAAAAA==.',['彩虹']='彩虹之桥:BAAAKgAECgEIAQAAAA==.',['很傻']='很傻很天真:BAAAKgAECgYICwAAAA==.',['微熊']='微熊熊呀:BAAAKgAECgYIBwAAAA==.',['德历']='德历诺之王:BAAAKgAECgUIBQAAAA==.',['心理']='心理畸型:BAAAKgADCgEIAQAAAA==.',['忄束']='忄束负:BAABKgAFFH8IAAINAAQIBhQZHgDtAAANAAQIBhQZHgDtAAAAAA==.',['忧郁']='忧郁菠萝油:BAABKgAFFH8IAAQRAAYIXiQCAAAyAgARAAYIXiQCAAAyAgAQAAEIMwtKLABWAAASAAEIoQ90FABVAAAAAA==.',['性丨']='性丨感小牧:BAAAKgAECgYIBwAAAA==.',['恐怖']='恐怖丨如斯:BAABKgAFFH8JAAIIAAYIQiI8CQDfAQAIAAYIQiI8CQDfAQAAAA==.',['悦多']='悦多多:BAAAKgAFFAQIBAAAAA==.',['惑琺']='惑琺春奈:BAAAKgADCgUIBgAAAA==.',['愈夜']='愈夜愈有基:BAABKgAFFH8HAAIUAAQIoR4wKADtAAAUAAQIoR4wKADtAAABKgAFFAgIEwAIAOUdAA==.',['懒得']='懒得打名字:BAAAKgADCggICAAAAA==.',['我叫']='我叫张小欢:BAAAKgAECgQIBAAAAA==.我叫随便:BAAAKgAFFAIIAgAAAA==.',['我是']='我是小熊:BAACKgAFFH8HAAIYAAQIvhW9FADEAAAYAAQIvhW9FADEAAAqAAQKfx4AAhgACAj9GnkkAPEBABgACAj9GnkkAPEBAAAA.',['戒徒']='戒徒:BAABKgAFFH8KAAIPAAYISBYNFQBSAQAPAAYISBYNFQBSAQAAAA==.',['战意']='战意无双:BAACKgAFFH8OAAMbAAMIPgUtFwClAAAbAAMINwUtFwClAAAhAAMIsQEdFABaAAAqAAQKfxkABAcACAiBEaIyACoBAAcABghrDKIyACoBABsAAgjyG4xZAKQAACEACAgoCjQ1AJUAAAAA.',['战斗']='战斗美女:BAAAKgAECggICgAAAA==.',['戰魂']='戰魂之歌:BAAAKgADCggICAAAAA==.',['扎德']='扎德雷:BAAAKgAECgUIBQAAAA==.',['打不']='打不过我就躺:BAAAKgAFFAEIAgAAAA==.',['扭到']='扭到费:BAABKgAFFH8PAAIVAAYIVRZ6DABLAQAVAAYIVRZ6DABLAQAAAA==.',['披甲']='披甲者:BAAAKgAECgQIBAABKgAECggIKAAPANodAA==.',['持剑']='持剑者:BAABKgAECn8oAAIPAAgI2h06HQBUAgAPAAgI2h06HQBUAgAAAA==.',['指缝']='指缝见流逝:BAAAKgADCgIIAgAAAA==.',['推倒']='推倒小心肝:BAAAKgAECgQIBAAAAA==.',['掷点']='掷点王:BAAAKgAECggICAAAAA==.',['撸自']='撸自呻:BAAAKgADCgQIBAAAAA==.',['放肆']='放肆寂寞:BAABKgAFFH8mAAIEAAUIABLTBgAYAQAEAAUIABLTBgAYAQAAAA==.',['斐瑞']='斐瑞:BAABKgAFFH8KAAIBAAYIgSRhAAA0AgABAAYIgSRhAAA0AgAAAA==.',['旋转']='旋转的雪:BAABKgAFFH8JAAMQAAUIZhZvBgA9AQAQAAUIHxNvBgA9AQARAAQIMRhTDgDDAAAAAA==.',['无情']='无情的粉碎:BAAAKgAECgEIAQAAAA==.无情起门机器:BAAAKgAFFAQIBAAAAA==.',['无敌']='无敌大猩猩:BAAAKgAFFAQIBAAAAA==.',['无瑕']='无瑕:BAABKgAFFH8IAAIOAAgIGxHeCQC4AQAOAAgIGxHeCQC4AQAAAA==.',['无糖']='无糖小雪碧:BAACKgAFFH8JAAQTAAUIthEJBADJAAATAAQIDgcJBADJAAAVAAQIZRUsHwCrAAAUAAEIqAZvUgBIAAAqAAQKfyAAAhMACAjTGP4LAOwBABMACAjTGP4LAOwBAAAA.',['既来']='既来之则安之:BAAAKgAECgUICQAAAA==.',['日落']='日落飞锦:BAAAKgAECgIIAgABKgAFFAgIBAALAAAAAA==.日落黄昏:BAABKgAFFH8GAAIeAAYIxhVADACIAQAeAAYIxhVADACIAQAAAA==.',['旭阿']='旭阿:BAAAKgAECggIEAAAAA==.',['旺仔']='旺仔小馒头:BAAAKgAECggICAAAAA==.旺仔牛逼糖:BAAAKgADCgEIAQAAAA==.',['明镜']='明镜之光:BAAAKgAECgIIAwAAAA==.',['星丿']='星丿亦术:BAAAKgADCggIFgAAAA==.星丿亦辰:BAAAKgAECgYIBgAAAA==.',['星之']='星之所往:BAAAKgAFFAMIBAAAAA==.',['星辰']='星辰夜影风:BAAAKgAECgEIAQAAAA==.',['春梦']='春梦了无狠:BAAAKgAECgYIBwAAAA==.',['晓手']='晓手哇凉:BAAAKgAECgEIAQAAAA==.',['晓晓']='晓晓鏃:BAAAKgADCggICAAAAA==.',['晚上']='晚上不睡觉:BAAAKgAECgMIAwAAAA==.',['暗之']='暗之银翼:BAAAKgAECgcIDQAAAA==.',['暗影']='暗影界魔导师:BAAAKgADCgQIBAAAAA==.',['暗黑']='暗黑狼:BAAAKgAECgEIAQAAAA==.暗黑虎:BAACKgAFFH8WAAMNAAMIUx4WPwD0AAANAAMIUx4WPwD0AAAMAAMItA7gEgBuAAAqAAQKfxUABA0ACAjPIYFfAKEBAA0ACAgoIYFfAKEBAAwABQgvHe8qAAABABYAAggBFUobAHcAAAAA.',['曲喵']='曲喵喵:BAABKgAFFH8GAAIBAAYIPhJOMwA4AAABAAYIPhJOMwA4AAAAAA==.',['曲终']='曲终人必散:BAAAKgAFFAIIAgAAAA==.',['曼丽']='曼丽丶:BAAAKgAECgEIAQAAAA==.',['最肉']='最肉二狗锅:BAAAKgAECgMIAwAAAA==.',['月中']='月中眠:BAABKgAFFH8IAAIFAAgIshcWBQDlAQAFAAgIshcWBQDlAQAAAA==.',['有医']='有医保随便搞:BAAAKgAECggIDAAAAA==.',['未晞']='未晞丶:BAACKgAFFH8UAAICAAQIbSFcCQAVAQACAAQIbSFcCQAVAQAqAAQKfyQAAgIACAhGIFgSAE4CAAIACAhGIFgSAE4CAAAA.',['杀乄']='杀乄生:BAAAKgADCggICwAAAA==.',['村边']='村边一只熊:BAAAKgAECggIDQAAAA==.',['杳杳']='杳杳钟声晚:BAAAKgADCgIIAgAAAA==.',['柏木']='柏木:BAAAKgADCggICAAAAA==.',['柒心']='柒心嫖虫:BAAAKgAFFAQIAgABKgAFFAgIDwABAM4XAA==.',['梅友']='梅友镜:BAAAKgAECgQIBAAAAA==.',['榴莲']='榴莲臭臭:BAAAKgAECgUIBQAAAA==.',['橙肩']='橙肩橙戒:BAAAKgADCggICAAAAA==.',['正灬']='正灬义:BAAAKgADCgQIBgAAAA==.',['死神']='死神妹妹:BAAAKgAECgMIAwAAAA==.',['残暴']='残暴的太阳哥:BAAAKgAECggICwAAAA==.',['毕竟']='毕竟大帅比啊:BAAAKgAECgUIBQAAAA==.',['毛毛']='毛毛球:BAAAKgAECgUIBgAAAA==.',['气场']='气场两米八:BAAAKgAECggICwAAAA==.',['永远']='永远追随蛋哥:BAAAKgAECgYIEgAAAA==.',['求你']='求你马老公抱:BAAAKgAECggICAABKgAFFAgIFgAVACgiAA==.',['沉冤']='沉冤待雪:BAAAKgAECgQIBAAAAA==.',['沐浴']='沐浴法姐:BAAAKgADCgcIBwAAAA==.',['没睡']='没睡醒的猫:BAAAKgAECgcICAAAAA==.',['沧澜']='沧澜丶会长:BAAAKgAECgYIBwAAAA==.',['沧素']='沧素:BAABKgAFFH8HAAMHAAMIGwhfHQCgAAAHAAMIGwhfHQCgAAAhAAEI3wBuEAAgAAAAAA==.',['法爷']='法爷:BAACKgAFFH8UAAIEAAQIUyZTEABDAQAEAAQIUyZTEABDAQAqAAQKfxoAAgQACAiRJCoKADgCAAQACAiRJCoKADgCAAAA.',['波菲']='波菲亚:BAAAKgAECgYIBgAAAA==.',['泯灭']='泯灭使者:BAABKgAFFH8GAAINAAYIMh50DgC4AQANAAYIMh50DgC4AQAAAA==.',['洛丹']='洛丹伦的悲叹:BAAAKgADCgQIBAAAAA==.',['流丶']='流丶云:BAAAKgADCgUIBQAAAA==.',['浊谷']='浊谷山人主:BAACKgAFFH8JAAIFAAMIQyOPDQAfAQAFAAMIQyOPDQAfAQAqAAQKfxcAAgUACAidJOUJAKYCAAUACAidJOUJAKYCAAAA.',['浩若']='浩若海洋:BAAAKgAFFAgIBAAAAA==.',['浮生']='浮生茹梦:BAAAKgADCggICAAAAA==.',['海澈']='海澈:BAAAKgAECgEIAQAAAA==.',['淡淡']='淡淡幽香:BAAAKgAFFAQIAwAAAA==.',['清月']='清月晚星:BAABKgAFFH8KAAIVAAYIyBVXCQABAQAVAAYIyBVXCQABAQAAAA==.',['清风']='清风慢慢:BAAAKgAECgEIAQAAAA==.',['温不']='温不胜王有胜:BAAAKgAECgMIAwAAAA==.',['满月']='满月孤星:BAAAKgAECgEIAQAAAA==.',['潇法']='潇法:BAAAKgAFFAMIAwAAAA==.',['潇牧']='潇牧:BAABKgAFFH8GAAIBAAYIOBQ5CgBzAQABAAYIOBQ5CgBzAQAAAA==.',['澳斯']='澳斯尔:BAAAKgAECgUICQAAAA==.',['火花']='火花闪电:BAABKgAFFH8JAAIiAAIIZBdWEACqAAAiAAIIZBdWEACqAAAAAA==.',['灬一']='灬一贱你就笑:BAAAKgAECgEIAQAAAA==.',['灬布']='灬布丁:BAAAKgAECgMIBgAAAA==.',['灬往']='灬往死里射灬:BAAAKgAECgMIAwAAAA==.',['灬无']='灬无幽:BAAAKgAECggIDgAAAA==.',['灬末']='灬末路:BAAAKgAFFAEIAQAAAA==.',['灬火']='灬火疙瘩:BAAAKgADCggICAAAAA==.',['灭灬']='灭灬亡:BAAAKgADCggIDwAAAA==.',['灰烬']='灰烬未明:BAABKgAFFH8LAAIUAAQIQBqJCgAWAQAUAAQIQBqJCgAWAQAAAA==.',['灵感']='灵感:BAABKgAECn8XAAMfAAYIyBZNGwBNAQAfAAYICxNNGwBNAQAeAAUIkhECKwAKAQAAAA==.',['灵敏']='灵敏的鲨鱼:BAAAKgAFFAQIBAAAAA==.',['灵梦']='灵梦八云蓝:BAAAKgAFFAYIAgAAAA==.',['灵魂']='灵魂摆渡者:BAAAKgAECgMIBQAAAA==.灵魂摆逗:BAAAKgADCgMIAwAAAA==.',['災灬']='災灬禍:BAAAKgADCggICAAAAA==.',['炎之']='炎之龙斩者:BAAAKgAFFAQIBAAAAA==.',['炸你']='炸你丫的:BAACKgAFFH8GAAINAAMIuAZlMACiAAANAAMIuAZlMACiAAAqAAQKfyQAAw0ACAgXFrUkAJkBAA0ACAgXFrUkAJkBAAwAAQjaAZljAAQAAAAA.',['烎战']='烎战隼兲:BAAAKgADCgUIBQAAAA==.',['烧干']='烧干红酒:BAAAKgAECgEIAQAAAA==.',['照世']='照世明灯:BAAAKgADCgMIAwAAAA==.',['熊猫']='熊猫贵族:BAAAKgADCgIIAgAAAA==.',['爱吃']='爱吃鱼的猴子:BAAAKgAECggICAAAAA==.',['爱甜']='爱甜甜的小哈:BAAAKgAFFAQIBAAAAA==.',['牛极']='牛极巴:BAAAKgADCgEIAQAAAA==.',['狂暴']='狂暴的小泥鳅:BAABKgAFFH8GAAIUAAYIMA1KGABbAQAUAAYIMA1KGABbAQAAAA==.',['狒狒']='狒狒的逆袭:BAAAKgAECgcIDgAAAA==.',['王小']='王小洲:BAAAKgAECggICAAAAA==.',['玖玖']='玖玖捌拾壹:BAABKgAECn8XAAIdAAcIhh1UFwDmAQAdAAcIhh1UFwDmAQAAAA==.',['环杉']='环杉:BAAAKgAECggICAAAAA==.',['电了']='电了个电:BAABKgAFFH8IAAMFAAQI+w1yFQDPAAAFAAQI+w1yFQDPAAAGAAMIwxJqFwC6AAABKgAFFAgIEAAFACIVAA==.',['男演']='男演员:BAAAKgAECgUIBQAAAA==.',['番茄']='番茄蛋龙须面:BAAAKgADCgcIDQAAAA==.',['疯牛']='疯牛症:BAAAKgAECgQIBAAAAA==.',['疯狂']='疯狂小防骑:BAAAKgAECgYIBgAAAA==.疯狂的石头:BAABKgAFFH8GAAIEAAYIww2TBwCLAQAEAAYIww2TBwCLAQAAAA==.',['白發']='白發魔莮:BAABKgAFFH8IAAINAAQI8AfzZQCiAAANAAQI8AfzZQCiAAAAAA==.',['白雪']='白雪大人:BAABKgAFFH8SAAINAAMIpx5WQADwAAANAAMIpx5WQADwAAAAAA==.',['百万']='百万伏特:BAAAKgADCgMIAwAAAA==.',['皇后']='皇后殺手:BAABKgAECn9FAAIPAAgIRB+yFQBTAgAPAAgIRB+yFQBTAgAAAA==.',['看书']='看书去呗:BAAAKgAECgcIBwAAAA==.',['看来']='看来经济:BAACKgAFFH8IAAMIAAQIuRyrLgDOAAAIAAQIuRyrLgDOAAAOAAQIDhMyWQAAAAAqAAQKfxwAAwgACAj7G4NDAJkBAAgACAj7G4NDAJkBAA4AAQiiHGeVAFAAAAAA.',['真心']='真心不懂老湿:BAAAKgAFFAMIAwAAAA==.',['真白']='真白:BAAAKgADCgQIBAAAAA==.',['瞎子']='瞎子很风骚:BAACKgAFFH8iAAIcAAQItg5kBwDcAAAcAAQItg5kBwDcAAAqAAQKf1AAAhwACAgKH3UMAEgCABwACAgKH3UMAEgCAAAA.',['短腿']='短腿基:BAAAKgAFFAIIBAAAAA==.',['矮大']='矮大壮:BAACKgAFFH8WAAIOAAMIQBnPJQDUAAAOAAMIQBnPJQDUAAAqAAQKfzEAAw4ACAjlHykVAFACAA4ACAjlHykVAFACAAgAAQj4BsgOASQAAAAA.',['碧落']='碧落紅尘:BAACKgAFFH8PAAINAAMI5ArMYQCsAAANAAMI5ArMYQCsAAAqAAQKfx8AAg0ACAjOGYVNANYBAA0ACAjOGYVNANYBAAAA.',['社区']='社区业灬主:BAAAKgAECgEIAQAAAA==.社区光头:BAAAKgADCgIIAgAAAA==.社区暴富王胖:BAAAKgAECgEIAQAAAA==.',['神不']='神不过如此嘛:BAAAKgAECgcIDwAAAA==.',['神僧']='神僧:BAAAKgADCgIIAgAAAA==.',['神棍']='神棍擎天:BAAAKgADCgYICQAAAA==.',['禁铺']='禁铺又禁盖:BAABKgAFFH8JAAIJAAMIoAOgTACBAAAJAAMIoAOgTACBAAAAAA==.',['秋意']='秋意阑珊:BAAAKgAECgYIEAAAAA==.',['空肚']='空肚吃早餐:BAAAKgAECgIIAgAAAA==.',['章大']='章大宝:BAACKgAFFH8UAAMbAAgImxy6BQAaAgAbAAgIaxa6BQAaAgAHAAYI7B5jCACFAQAqAAQKfyEAAhsACAhRFdktAM8BABsACAhRFdktAM8BAAAA.',['第八']='第八種颜色:BAAAKgADCgYIBgAAAA==.',['紙爿']='紙爿人:BAAAKgAECgEIAQAAAA==.',['紫楓']='紫楓:BAAAKgAECgEIAQAAAA==.',['紫色']='紫色夜晚:BAACKgAFFH8HAAIIAAMI2gwsOwCvAAAIAAMI2gwsOwCvAAAqAAQKfxcAAggACAjVFt01AM4BAAgACAjVFt01AM4BAAAA.',['紫花']='紫花地丁:BAAAKgAFFAQIBAAAAA==.',['红心']='红心番石榴:BAACKgAFFH8GAAIVAAYI9A4NFAABAQAVAAYI9A4NFAABAQAqAAQKfxYAAxQACAhWJXkHAOACABQACAhWJXkHAOACABUABghBDoFAAL0AAAEqAAUUCAgMABQA9REA.',['红星']='红星照耀:BAAAKgAECgEIAQAAAA==.',['红杏']='红杏丶:BAAAKgADCgMIAwAAAA==.',['红运']='红运郎:BAABKgAFFH8MAAINAAYIrCGQCgAtAQANAAYIrCGQCgAtAQAAAA==.',['红门']='红门乖乖:BAAAKgAECgYIEwAAAA==.红门城城:BAAAKgAECgMIBgAAAA==.',['纵火']='纵火狂丶焰:BAAAKgAECggIDgAAAA==.',['细细']='细细粒粒:BAABKgAFFH8IAAIQAAgI7huBAwB6AgAQAAgI7huBAwB6AgAAAA==.',['绚辉']='绚辉炎:BAAAKgAECgMIAwAAAA==.',['维拉']='维拉特:BAAAKgAECgIIAgAAAA==.',['缘缘']='缘缘不断:BAAAKgADCgMIAwAAAA==.',['缥缈']='缥缈丶孤鸿影:BAAAKgADCggICAAAAA==.',['罒冰']='罒冰雨罒:BAAAKgAECgYIBgAAAA==.',['罒娇']='罒娇花罒:BAABKgAFFH8IAAIQAAgI5hyWAgB+AgAQAAgI5hyWAgB+AgAAAA==.',['罒悟']='罒悟空罒:BAAAKgAECgIIAgAAAA==.',['罒舞']='罒舞者罒:BAABKgAFFH8IAAIaAAgIsgXoAgBpAQAaAAgIsgXoAgBpAQAAAA==.',['罢癃']='罢癃入顶:BAABKgAFFH8GAAIaAAYIYQhmBQDQAAAaAAYIYQhmBQDQAAABKgAFFAgIBgAaAPgLAA==.',['羊角']='羊角挺秀气:BAAAKgAECggICwAAAA==.',['美丽']='美丽的大牙:BAACKgAFFH8GAAICAAYIiyL8BgCtAQACAAYIiyL8BgCtAQAqAAQKfx4AAxcACAh9JNMHAKICABcACAh9JNMHAKICAAIABwg9G88gAM8BAAAA.',['美洋']='美洋洋丶情殇:BAAAKgAFFAIIAgAAAA==.',['羽隹']='羽隹:BAAAKgAECgcICAAAAA==.',['翻垮']='翻垮四中围墙:BAAAKgAFFAQIBAAAAA==.',['翻墙']='翻墙走路上网:BAAAKgAFFAQIBAAAAA==.',['老紫']='老紫属道山:BAABKgAFFH8SAAIIAAUI9R4HDwA2AQAIAAUI9R4HDwA2AQAAAA==.老紫日历仙人:BAABKgAFFH8QAAIgAAQIew1LDQC+AAAgAAQIew1LDQC+AAAAAA==.',['耐力']='耐力卷轴:BAAAKgAFFAUIAQAAAA==.',['聆听']='聆听我的声音:BAABKgAECn9CAAIGAAgIjR5hDwBfAgAGAAgIjR5hDwBfAgAAAA==.',['职业']='职业打铁:BAABKgAECn9BAAINAAgICCMSFwCqAgANAAgICCMSFwCqAgAAAA==.职业脱靶:BAAAKgAFFAQIBAAAAA==.',['聖丶']='聖丶瓦里安:BAAAKgAECggIDwAAAA==.聖丶莫格莱尼:BAABKgAECn8cAAINAAgIHyEBKABgAgANAAgIHyEBKABgAgAAAA==.',['聖光']='聖光忽悠着你:BAAAKgAECgYIBgAAAA==.',['聖骐']='聖骐:BAAAKgAECgUICgAAAA==.',['肆天']='肆天赋有鸟用:BAABKgAECn8eAAQJAAgI0g6LagAbAQAJAAcIcQ6LagAbAQAdAAUIZxEROwD7AAAjAAQI4woeLACNAAAAAA==.',['肝出']='肝出二十橙:BAAAKgAECgYIBgAAAA==.',['背后']='背后有尾巴:BAAAKgADCggICAAAAA==.',['臭烂']='臭烂碎鸡者:BAAAKgAFFAgIBAAAAA==.',['舞月']='舞月光:BAAAKgAECgMIAwAAAA==.',['舞行']='舞行八卦:BAABKgAECn8ZAAIgAAgIXR+rDQBaAgAgAAgIXR+rDQBaAgAAAA==.',['艾丽']='艾丽斯:BAACKgAFFH8SAAQjAAMI0QZGCwBfAAAJAAMIxwPtTwB2AAAjAAMIZgZGCwBfAAAKAAEIKAVKDgA0AAAqAAQKfxkABAkACAjMChJlACsBAAkACAiOCRJlACsBAB0ACAjqCWtBAAoBACMABAjNCdsiAIUAAAAA.',['艾奥']='艾奥斯:BAAAKgAFFAYIBAAAAA==.',['艾欧']='艾欧静儿:BAAAKgAECggICAAAAA==.艾欧静兒:BAAAKgADCggICQAAAA==.',['艾瑞']='艾瑞维拉:BAAAKgAFFAQIBAAAAA==.',['艾瑟']='艾瑟丽:BAAAKgAECgEIAQAAAA==.',['艾辛']='艾辛格:BAAAKgAECgQIBgAAAA==.',['花下']='花下晒裤子:BAAAKgAFFAMIAwAAAA==.',['花若']='花若兮梦若卿:BAABKgAFFH8MAAIZAAMIawD3MQBHAAAZAAMIawD3MQBHAAAAAA==.',['芸飞']='芸飞扬:BAAAKgAFFAMIAwAAAA==.',['苗苗']='苗苗祭司:BAAAKgAECgMIBQAAAA==.',['苦丁']='苦丁花茶:BAAAKgAFFAQIAwAAAA==.',['药丶']='药丶不能停:BAAAKgADCggICAAAAA==.',['莉娜']='莉娜因巴斯:BAAAKgADCggIDgAAAA==.',['莉维']='莉维耶塔:BAAAKgAFFAIIAgAAAA==.',['莎莫']='莎莫:BAAAKgADCggICAAAAA==.',['莓茱']='莓茱:BAAAKgADCgIIAgAAAA==.',['莫青']='莫青青:BAAAKgAECggICgAAAA==.',['菠萝']='菠萝小小熊:BAABKgAFFH8MAAMFAAYIow5ZEwA7AQAFAAYIow5ZEwA7AQAGAAMI1hD7EQCTAAAAAA==.',['薛村']='薛村长:BAAAKgAECgIIAwAAAA==.',['虎鶴']='虎鶴丶妖師:BAABKgAFFH8IAAMUAAQIFw0oPgClAAAUAAQIWgcoPgClAAAVAAQI0QioKwBmAAAAAA==.',['虚空']='虚空大师:BAAAKgAFFAQIBAAAAA==.',['蜜糖']='蜜糖喵喵:BAAAKgAECgYIBgAAAA==.',['血丶']='血丶长空:BAAAKgADCgEIAQAAAA==.',['表幻']='表幻想:BAACKgAFFH8NAAMSAAQI6yWJBQAfAQAQAAQI6yXNBgA3AQASAAMI2iCJBQAfAQAqAAQKfxoAAhIACAjxIpcIAGoCABIACAjxIpcIAGoCAAAA.',['装备']='装备绑定:BAAAKgADCgQIBAAAAA==.',['西方']='西方慢车:BAAAKgAECgYIBgAAAA==.',['西装']='西装狂徒:BAAAKgAECgYIBgAAAA==.',['要樂']='要樂奈:BAABKgAFFH8IAAMIAAQIBhfZFwDxAAAIAAQIBhfZFwDxAAAOAAQIXRI1DgDhAAAAAA==.',['解谜']='解谜人:BAAAKgADCggICgAAAA==.',['触手']='触手丶怪:BAAAKgAECgEIAQAAAA==.',['說晚']='說晚安:BAABKgAFFH8RAAMYAAYI+Be2BAB7AQAYAAYIiha2BAB7AQADAAYIohWSDwBxAQAAAA==.',['誰湜']='誰湜誰哋誰:BAABKgAFFH8FAAIXAAMIxwz6KQCaAAAXAAMIxwz6KQCaAAAAAA==.',['诡夜']='诡夜无形:BAAAKgADCggICAAAAA==.',['请叫']='请叫我土豪:BAAAKgAECgMIAgAAAA==.',['诸因']='诸因解体:BAACKgAFFH8rAAMdAAgIaiELAADfAgAdAAgIaiELAADfAgAJAAIIsB03QwChAAAqAAQKfx8AAh0ACAg4JsMBAPECAB0ACAg4JsMBAPECAAAA.',['诺米']='诺米团:BAAAKgAECgUIBQAAAA==.',['谈爱']='谈爱已老:BAAAKgADCgEIAQAAAA==.',['谣妹']='谣妹:BAAAKgADCggICAAAAA==.',['贼兮']='贼兮兮的猫着:BAAAKgAECgEIAQAAAA==.',['贼王']='贼王:BAAAKgAECgMIAwAAAA==.',['赤座']='赤座灯外:BAAAKgAFFAIIAgAAAA==.',['超級']='超級賽亚人:BAAAKgAECggICAAAAA==.',['路过']='路过甩一泡:BAAAKgAECgIIAwAAAA==.',['跳起']='跳起来打:BAAAKgAECggIEAAAAA==.',['辣鸡']='辣鸡王中王:BAAAKgADCggICAAAAA==.',['达布']='达布:BAAAKgAFFAgIBAAAAA==.',['还搁']='还搁这玩呢:BAEBKgAECn8UAAMRAAcIDRiVCADbAQARAAcIDRiVCADbAQAQAAIIrhdXbAB8AAABKgAFFAgIBgAiAK4TAA==.',['迷途']='迷途不归路:BAABKgAECn8UAAIGAAgIHhp6JgDAAQAGAAgIHhp6JgDAAQAAAA==.',['追风']='追风:BAABKgAECn8lAAIQAAgIKhq9BwAnAgAQAAgIKhq9BwAnAgAAAA==.',['通航']='通航有益:BAAAKgADCggICAAAAA==.',['遇见']='遇见丶花开:BAAAKgADCgMIAwAAAA==.',['那一']='那一年的風:BAAAKgADCgUIBQAAAA==.',['那天']='那天喝七瀑:BAAAKgAFFAQIBAAAAA==.',['郝吉']='郝吉吉:BAAAKgADCgUIBQAAAA==.',['酱椒']='酱椒鱼头:BAABKgAFFH8LAAIFAAQIxB1AHgADAQAFAAQIxB1AHgADAQAAAA==.',['酱紫']='酱紫剑:BAAAKgAECgMIAwAAAA==.',['醺醺']='醺醺:BAAAKgAECgIIAgAAAA==.',['钟山']='钟山丽影:BAAAKgAECgIIAwAAAA==.',['长坂']='长坂坡张翼德:BAABKgAFFH8GAAIbAAYIcwenCwBWAQAbAAYIcwenCwBWAQABKgAFFAgIBgAbACMOAA==.',['闪星']='闪星:BAAAKgAFFAQIBAAAAA==.',['阿古']='阿古西阁下:BAAAKgAECgUICQAAAA==.',['陨落']='陨落之星:BAABKgAECn8YAAMXAAgI6RQ7MgB4AQAXAAgI6RQ7MgB4AQABAAMIXQu6ggBNAAAAAA==.',['随心']='随心:BAAAKgADCgEIAQAAAA==.',['震离']='震离星姬:BAABKgAFFH8IAAIFAAYIGhf6DAB8AQAFAAYIGhf6DAB8AQAAAA==.',['青花']='青花郎:BAABKgAFFH8QAAMYAAYIBxd7BQAFAQAYAAYI7A17BQAFAQAEAAQIAA5jHQDEAAABKgAFFAgIBgAEAF8hAA==.',['静静']='静静蔓延:BAAAKgAECgUIBwAAAA==.',['风姿']='风姿依然:BAAAKgAECgIIAgAAAA==.',['风流']='风流一棍:BAAAKgAECggICAAAAA==.',['风碑']='风碑:BAAAKgAECgMIAwAAAA==.',['飘玲']='飘玲丶:BAAAKgAECgYIBgAAAA==.',['飞跃']='飞跃苏联:BAACKgAFFH8ZAAIZAAYIoBuBEAApAQAZAAYIoBuBEAApAQAqAAQKf1QAAhkACAhlJukAAAIDABkACAhlJukAAAIDAAAA.',['食野']='食野之萍:BAAAKgAECgYIBwAAAA==.',['饮血']='饮血玛鲁斯:BAAAKgADCggICAAAAA==.',['骑士']='骑士道:BAAAKgAECggIEwAAAA==.',['魅影']='魅影璃姬:BAAAKgADCgcIBwAAAA==.',['魔女']='魔女:BAAAKgADCgcIBwAAAA==.',['麦克']='麦克邱:BAAAKgAFFAMIAwAAAA==.',['黄的']='黄的琞艳:BAABKgAFFH8LAAIhAAMIOwPXEgBlAAAhAAMIOwPXEgBlAAAAAA==.',['黑暗']='黑暗小德:BAAAKgADCgUIBgAAAA==.',['黑灬']='黑灬暗:BAAAKgADCgQIBAAAAA==.',['黑煞']='黑煞:BAABKgAECn8VAAIFAAgIpRFWQQBxAQAFAAgIpRFWQQBxAQAAAA==.',['黑蛐']='黑蛐蛐:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end