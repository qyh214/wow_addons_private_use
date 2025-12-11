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
 local lookup = {'DeathKnight-Frost','Warrior-Protection','Priest-Holy','Priest-Shadow','Mage-Arcane','Warrior-Fury','Paladin-Holy','Hunter-BeastMastery','DemonHunter-Havoc','Druid-Restoration','Shaman-Restoration','Warlock-Destruction','DeathKnight-Blood','Unknown-Unknown','Druid-Balance','Druid-Guardian','Evoker-Preservation','Evoker-Devastation','Shaman-Elemental','Hunter-Marksmanship','Monk-Brewmaster','DeathKnight-Unholy','Warlock-Demonology','Warlock-Affliction','Paladin-Retribution','Rogue-Subtlety','Druid-Feral','Hunter-Survival','Mage-Frost','Rogue-Assassination','Monk-Mistweaver','Paladin-Protection','DemonHunter-Vengeance','Priest-Discipline',}; local provider = {region='CN',realm='地狱咆哮',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Arashiwarp:BAAALAAECgYIDgAAAA==.',At='Athenia:BAAALAADCggIFgAAAA==.',Az='Azurerain:BAAALAAECgYICQAAAA==.',Bi='Bitcoin:BAAALAADCgUIBQAAAA==.',Co='Cometopapa:BAAALAAECgcIEgAAAA==.',Cr='Crazylove:BAAALAAFFAYIBAAAAA==.Cruelsummer:BAAALAAFFAIIBAAAAA==.',Da='Darkarrow:BAAALAAFFAIIAgAAAA==.',De='Delilah:BAAALAAECgIIAgAAAA==.',Dr='Dri:BAAALAAECgMIAwAAAA==.',En='End:BAABLAAFFH8GAAIBAAYIRRqqJQCeAQABAAYIRRqqJQCeAQAAAA==.',Ev='Evagelion:BAAALAAECgYIDAAAAA==.',Ho='Honey:BAAALAAECgYIBgAAAA==.',In='In:BAABLAAFFH8GAAICAAYI5hvdCgCSAQACAAYI5hvdCgCSAQAAAA==.',Kj='Kjj:BAAALAADCgIIAgAAAA==.',Ko='Kookazuma:BAACLAAFFH8bAAMDAAYI5A+5GwBxAQADAAYI5A+5GwBxAQAEAAIIUQIMMgApAAAsAAQKfxgAAgMABwjbHJ4SADwCAAMABwjbHJ4SADwCAAAA.',Ky='Kylem:BAAALAAECgYIBgAAAA==.',Lu='Luckyhengyu:BAAALAADCgQIBAAAAA==.',Ly='Lydia:BAAALAAECgEIAQAAAA==.',Mo='Moonlight:BAAALAAECgQIBAAAAA==.Moonlitdream:BAABLAAFFH8HAAIFAAMIOxkiNwCuAAAFAAMIOxkiNwCuAAAAAA==.Mougga:BAAALAADCgEIAQAAAA==.',Mu='Murata:BAAALAADCggIGAAAAA==.',No='Noirr:BAABLAAECn8VAAIGAAgIpxN0VwDrAQAGAAgIpxN0VwDrAQAAAA==.',Or='Orion:BAAALAAECgEIAQAAAA==.',Pe='Penis:BAAALAAECgUIBwAAAA==.',Pr='Prinze:BAAALAADCgQIBAAAAA==.',Ra='Ravi:BAABLAAFFH8OAAIHAAYIiwlrFABGAQAHAAYIiwlrFABGAQAAAA==.',Re='Resdayn:BAAALAAECgMIAwAAAA==.',Ro='Rolandy:BAAALAAECggICAAAAA==.',Su='Subject:BAAALAADCgYIBgAAAA==.Summerberry:BAAALAADCgYIBgAAAA==.Sunstalker:BAAALAAECgQIBgAAAA==.',Ta='Tatyun:BAAALAAECgYIBgAAAA==.',Vi='Vivian:BAAALAADCgcIBwAAAA==.',Wi='Windranner:BAAALAAECgUIBQAAAA==.',Xu='Xun:BAAALAAECggIEAAAAA==.',['一世']='一世清幽:BAAALAAFFAIIAgAAAA==.',['一优']='一优秀一:BAAALAAECgYIBgAAAA==.',['一变']='一变压器一:BAAALAADCgcIBwAAAA==.',['一朵']='一朵小花花:BAAALAAECgcICwAAAA==.',['一梭']='一梭子灌满:BAAALAAFFAIIAgAAAA==.',['一血']='一血色浪漫一:BAAALAADCgYIDgAAAA==.',['一锤']='一锤敲死:BAAALAAECgYIBgAAAA==.',['七玥']='七玥微暖:BAAALAAECgQIBAAAAA==.',['三月']='三月万物苏:BAABLAAFFH8MAAIIAAIIOAw2awCDAAAIAAIIOAw2awCDAAAAAA==.',['上山']='上山打老虎:BAABLAAECn8VAAIJAAYIZB/cLQCiAQAJAAYIZB/cLQCiAQAAAA==.',['下暴']='下暴雨:BAABLAAFFH8HAAIKAAUIBQUUKADXAAAKAAUIBQUUKADXAAAAAA==.',['下水']='下水道母蟑螂:BAAALAAECgMIAwAAAA==.',['不是']='不是小号:BAAALAADCgMIAwAAAA==.',['不能']='不能拳脚相向:BAAALAAECgYIBgAAAA==.',['丨雨']='丨雨革月丨:BAAALAADCgEIAQAAAA==.',['临门']='临门一脚:BAAALAADCgUIBQAAAA==.',['丶三']='丶三鹿奶粉:BAABLAAFFH8KAAILAAIIZwg9XwBhAAALAAIIZwg9XwBhAAAAAA==.',['丶凹']='丶凹凸:BAAALAAECggICAAAAA==.',['丶原']='丶原味鸡汉堡:BAABLAAFFH8vAAIBAAgIcyPfAgDaAgABAAgIcyPfAgDaAgAAAA==.',['丶双']='丶双层嫩牛堡:BAABLAAFFH8zAAIBAAgILSKlAwDKAgABAAgILSKlAwDKAgAAAA==.',['丶含']='丶含笑半步癫:BAAALAAECgEIAQAAAA==.',['丶战']='丶战火:BAAALAAECgEIAQAAAA==.',['丶有']='丶有河不渴:BAAALAAECgYICgAAAA==.',['丶灾']='丶灾星:BAAALAAECgEIAQAAAA==.',['丶皮']='丶皮卡丘:BAAALAAFFAIIAgAAAA==.',['丶笨']='丶笨笨丶:BAAALAAECgIIAwAAAA==.',['丶过']='丶过往如烟:BAABLAAFFH8GAAIMAAII3QVjUQB9AAAMAAII3QVjUQB9AAAAAA==.',['丶香']='丶香辣鸡腿堡:BAABLAAFFH8uAAIBAAgIciNaBQCpAgABAAgIciNaBQCpAgAAAA==.',['丶黎']='丶黎明裁决:BAAALAAECgEIAQAAAA==.',['丸不']='丸不辣:BAAALAAECgUIBQAAAA==.',['丿咸']='丿咸蛋丶超人:BAAALAADCgYIBgAAAA==.',['义海']='义海豪情:BAAALAAECgYIBgAAAA==.',['乖小']='乖小乖:BAABLAAFFH8GAAIKAAYIix6aAgAmAgAKAAYIix6aAgAmAgAAAA==.',['二一']='二一添作五:BAAALAADCgEIAQAAAA==.',['二零']='二零一四:BAAALAAFFAIIAgAAAA==.',['今晚']='今晚打大老虎:BAAALAAECgEIAQAAAA==.今晚打大脑斧:BAAALAAECgYICwAAAA==.',['伊兰']='伊兰迪斯:BAAALAADCgIIAgAAAA==.',['伊利']='伊利萨邪:BAAALAADCgEIAQAAAA==.',['伊谢']='伊谢尔伦的枫:BAAALAADCggICAAAAA==.',['伯菈']='伯菈福鈤涅:BAAALAAECgUIDAAAAA==.',['似水']='似水年华:BAABLAAFFH8HAAIBAAIIVBc2TACkAAABAAIIVBc2TACkAAAAAA==.',['低调']='低调的泡沫啊:BAAALAAFFAIIAgAAAA==.',['你吃']='你吃芹菜:BAAALAAECgIIAgAAAA==.',['你想']='你想不到吧:BAABLAAFFH8MAAIKAAIIoh/VLQC0AAAKAAIIoh/VLQC0AAAAAA==.',['保护']='保护视力:BAAALAADCgcIBwAAAA==.',['做贼']='做贼心不虚:BAAALAADCgEIAQAAAA==.',['偷吻']='偷吻你的绣发:BAABLAAFFH8NAAIGAAIIow9FUgBCAAAGAAIIow9FUgBCAAAAAA==.',['傲之']='傲之囚牛:BAAALAAECgUIBQAAAA==.',['元印']='元印:BAAALAAECgYIEAAAAA==.',['元气']='元气满满:BAABLAAFFH8jAAIFAAYIHxmsHgCcAQAFAAYIHxmsHgCcAQAAAA==.',['兹拜']='兹拜因巴哈丷:BAAALAAFFAQIAwAAAA==.',['兽丨']='兽丨战:BAAALAAFFAIIAgAAAA==.',['冰霜']='冰霜女王影:BAABLAAFFH8GAAIFAAYIsQ1EEADkAQAFAAYIsQ1EEADkAQAAAA==.',['凛冬']='凛冬渐至丶:BAAALAADCgYIBgAAAA==.',['凯蒂']='凯蒂:BAAALAADCgEIAQAAAA==.',['凶珍']='凶珍大:BAAALAAECgYIBgAAAA==.',['刀馬']='刀馬旦:BAAALAADCggICAAAAA==.',['刃下']='刃下心:BAAALAAECgYIBgAAAA==.',['前面']='前面欧巴猛猪:BAABLAAFFH8FAAIDAAMICRzAEgAbAQADAAMICRzAEgAbAQAAAA==.前面欧巴猛龙:BAAALAAECgEIAQAAAA==.',['剑亡']='剑亡人亡丶:BAAALAAECgEIAQAAAA==.',['剑在']='剑在人在丶:BAAALAADCgQIBAAAAA==.',['劍心']='劍心無痕:BAABLAAFFH8GAAIGAAIIExUZLQCiAAAGAAIIExUZLQCiAAAAAA==.',['加尓']='加尓鲁什丶:BAAALAAECgQIBwAAAA==.',['加尔']='加尔丶鲁十:BAABLAAFFH8KAAIGAAIIuhUpLgChAAAGAAIIuhUpLgChAAAAAA==.',['劲脆']='劲脆鸡腿堡丶:BAABLAAFFH8OAAMBAAgIkyAmAwDUAgABAAgIkyAmAwDUAgANAAYIAAAAAAAAAAAAAA==.',['勇地']='勇地飞侠:BAAALAAECgIIAgAAAA==.',['十万']='十万伏特雷丘:BAAALAAFFAIIAgAAAA==.',['千乐']='千乐:BAACLAAFFH8PAAIIAAUI4BZ8UAAMAQAIAAUI4BZ8UAAMAQAsAAQKfxoAAggABghvIBdzAPYBAAgABghvIBdzAPYBAAAA.',['半截']='半截河战神:BAAALAAFFAIIBAAAAA==.',['半疯']='半疯半癫:BAACLAAFFH8QAAIBAAYI7BCbPgBAAQABAAYI7BCbPgBAAQAsAAQKfxYAAgEABggQHUmnALwBAAEABggQHUmnALwBAAAA.',['单行']='单行的轨道:BAABLAAFFH8eAAIIAAUI5yMlJQCdAQAIAAUI5yMlJQCdAQAAAA==.',['南国']='南国先生:BAABLAAFFH8GAAIIAAQI9Aj1ngA/AAAIAAQI9Aj1ngA/AAAAAA==.',['卩灬']='卩灬血煞天使:BAAALAAFFAIIAgAAAA==.',['原味']='原味鸡汉堡丶:BAABLAAFFH8sAAIBAAgIDiQFAgDqAgABAAgIDiQFAgDqAgAAAA==.',['双层']='双层嫩牛堡丶:BAABLAAFFH8vAAIBAAgIpCNwAgDiAgABAAgIpCNwAgDiAgAAAA==.',['双开']='双开门冰箱:BAAALAAECgIIAgAAAA==.',['叔叔']='叔叔依然伟大:BAAALAADCgIIAgAAAA==.',['受命']='受命于天丶:BAAALAAECgYICAABLAAFFAIIBAAOAAAAAA==.',['叨叨']='叨叨晨:BAAALAADCgYIBgAAAA==.',['只会']='只会治肾虚:BAAALAADCgIIAgAAAA==.',['司马']='司马懿:BAABLAAFFH8JAAIFAAMIuggZSgB1AAAFAAMIuggZSgB1AAAAAA==.',['名字']='名字很霸气:BAAALAAECgYIBgAAAA==.名字被狗取了:BAAALAAFFAEIAQAAAA==.',['吐车']='吐车上两百:BAABLAAFFH8JAAIBAAMIkgnnXQCZAAABAAMIkgnnXQCZAAAAAA==.',['吴与']='吴与伦比丶猎:BAAALAAECgYIDAAAAA==.',['吼克']='吼克:BAABLAAECn8UAAIGAAYITxBGlgBYAQAGAAYITxBGlgBYAQAAAA==.',['呆毛']='呆毛:BAAALAAECggICAAAAA==.',['呉朙']='呉朙丨七:BAABLAAFFH8JAAIDAAYIWxrIFgCbAQADAAYIWxrIFgCbAQAAAA==.呉朙丨五:BAABLAAFFH8OAAIDAAgIVRPLCQAsAgADAAgIVRPLCQAsAgAAAA==.呉朙丨六:BAABLAAFFH8HAAIDAAYIihtbEQDRAQADAAYIihtbEQDRAQAAAA==.',['咆哮']='咆哮兽骑:BAAALAAECgYIDwAAAA==.咆哮圣牧:BAAALAAECgYICgAAAA==.咆哮牛猎:BAAALAAECgYIDAAAAA==.咆哮狂萨:BAAALAAECgYIBwAAAA==.咆哮盟猎:BAAALAAECgEIAQAAAA==.咆哮神战:BAAALAAECgYICQAAAA==.咆哮龙术:BAAALAAECgYIBgAAAA==.',['咖啡']='咖啡咖喱:BAAALAAECgYICQAAAA==.',['哈尼']='哈尼小宝:BAABLAAFFH8GAAMKAAYIuwVuXQAyAAAKAAEI/ARuXQAyAAAPAAUIagG8OwAwAAAAAA==.',['哒哒']='哒哒嘀嗒哒:BAAALAAECgMIAwAAAA==.',['唐尼']='唐尼瑞恩:BAACLAAFFH8IAAIKAAMIlBB/LwCsAAAKAAMIlBB/LwCsAAAsAAQKfxsAAwoACAioFgQcAO8BAAoACAioFgQcAO8BABAAAQi9GMYlAEkAAAAA.',['唯有']='唯有记忆:BAAALAADCggICAAAAA==.',['喀拉']='喀拉米尔:BAAALAAECgYIBwAAAA==.',['喷奶']='喷奶龙:BAACLAAFFH9KAAMRAAgIVx9MAQD/AgARAAgIVx9MAQD/AgASAAEIBRJSHABIAAAsAAQKf1MAAxEACAiHJe0AAGUDABEACAiHJe0AAGUDABIACAjFE9ooANUBAAAA.',['喷子']='喷子警长:BAAALAADCgYIBgAAAA==.',['嗨欧']='嗨欧巴等等我:BAAALAAFFAIIBAAAAA==.',['嗯馬']='嗯馬釹士:BAAALAAECgYICQAAAA==.',['嘛咪']='嘛咪嘛咪吽:BAAALAADCgMIBAAAAA==.',['地狱']='地狱火咔:BAAALAADCgUIBQAAAA==.',['墨墨']='墨墨哒:BAAALAAECgcIEwAAAA==.',['壶中']='壶中日月长:BAAALAAECgYIBgAAAA==.',['壹嚸']='壹嚸:BAABLAAFFH8MAAIRAAIInA5JFACLAAARAAIInA5JFACLAAABLAAFFAYIGAAKABgIAA==.',['夏夜']='夏夜灬微凉:BAAALAAECgQIBAAAAA==.',['夏思']='夏思妮:BAAALAAFFAIIAgAAAA==.',['夏汐']='夏汐灬:BAABLAAFFH8IAAIMAAII6w4nTgCEAAAMAAII6w4nTgCEAAAAAA==.',['夜了']='夜了又破晓:BAAALAAECgMIAwAAAA==.',['夜落']='夜落无霜:BAAALAAECggICAAAAA==.',['大可']='大可不必:BAAALAAFFAIIAgABLAAFFAIIBAAOAAAAAA==.',['大笨']='大笨牛啊:BAACLAAFFH8LAAITAAMIQw+1MwCPAAATAAMIQw+1MwCPAAAsAAQKfyEAAhMACAjsGj4UAAoCABMACAjsGj4UAAoCAAAA.',['大耳']='大耳朵牙牙:BAABLAAFFH8IAAILAAIIvgxoXgBhAAALAAIIvgxoXgBhAAAAAA==.',['大肉']='大肉妞儿:BAABLAAFFH8MAAMIAAIIbCXMLADOAAAIAAIIbCXMLADOAAAUAAEIUxvSMwBFAAAAAA==.',['大鼻']='大鼻涕火牛:BAAALAAECgIIAgAAAA==.',['天地']='天地无双:BAAALAADCgQIBAAAAA==.',['天灬']='天灬籁:BAAALAADCggIGAABLAAFFAgIBwAVAPwWAA==.',['头上']='头上有支角:BAAALAAECgcICwAAAA==.',['奇妙']='奇妙毛球:BAABLAAFFH8GAAIHAAYI7xU+DwCSAQAHAAYI7xU+DwCSAQAAAA==.',['奶油']='奶油曲奇:BAAALAAFFAIIBAAAAA==.',['她喜']='她喜欢他的它:BAAALAAECggICAAAAA==.',['她心']='她心游:BAAALAAECgYIEgAAAA==.',['妖痿']='妖痿骑:BAAALAAECgYICQAAAA==.',['威少']='威少:BAABLAAFFH8kAAMBAAYI1xx+JACjAQABAAYI+xl+JACjAQAWAAMI7RhWCAD4AAAAAA==.',['威猛']='威猛的术尸:BAAALAAECggICAAAAA==.',['孙小']='孙小胖的发丝:BAAALAADCgMIAwAAAA==.',['守护']='守护荣耀之战:BAAALAAECgUIBQAAAA==.',['守村']='守村人:BAAALAAECgYIBgAAAA==.',['安吉']='安吉丽娜牡丹:BAAALAAFFAMIAwAAAA==.',['完美']='完美骷髅:BAABLAAECn8ZAAMKAAYIuSI+JQBTAgAKAAYIuSI+JQBTAgAPAAYIaBsVTACEAQAAAA==.',['定格']='定格那帧:BAAALAAECgUIBQAAAA==.',['定風']='定風波:BAAALAAECgUIBQAAAA==.',['宝塔']='宝塔镇河妖:BAAALAAECgIIAgAAAA==.宝塔镇河薬:BAAALAAECgQIBAAAAA==.宝塔镇河藥:BAAALAAECggICAAAAA==.',['实力']='实力超强壮壮:BAAALAADCggICAAAAA==.',['寒冰']='寒冰死骑:BAAALAADCgYIBgAAAA==.',['小咕']='小咕噜:BAAALAAECgYIDAAAAA==.',['小咖']='小咖喱:BAAALAAECgYIBwAAAA==.',['小图']='小图图:BAAALAAECgUIBQAAAA==.',['小城']='小城事故多:BAAALAADCgYIEQAAAA==.',['小多']='小多多:BAAALAAECgYIDAAAAA==.',['小宝']='小宝贝的宝大:BAAALAADCgIIAgAAAA==.',['小方']='小方舟:BAAALAAFFAEIAQAAAA==.',['小楼']='小楼:BAAALAAECgUIBQAAAA==.',['小毛']='小毛跄跄:BAAALAAFFAEIAQAAAA==.',['小汤']='小汤团儿:BAAALAAFFAIIAgAAAA==.',['小满']='小满:BAAALAAECgYIBwAAAA==.',['小点']='小点儿:BAAALAAECgMIAwAAAA==.',['小猪']='小猪蹄儿:BAAALAAECgYIBgAAAA==.',['小紫']='小紫裤衩儿:BAACLAAFFH8VAAMMAAYI9RVGLQBlAQAMAAYI9RVGLQBlAQAXAAEI2AEjMgAwAAAsAAQKfxgAAwwACAj2IpMSAFACAAwACAj2IpMSAFACABcAAQgpIogvAF0AAAEsAAUUCAgRAAwAlhoA.',['小艾']='小艾不能熬夜:BAAALAADCggICAAAAA==.',['小采']='小采集:BAAALAAECgIIAgAAAA==.',['小魚']='小魚:BAAALAAECgYICAAAAA==.',['就我']='就我快乐:BAACLAAFFH8KAAIIAAMI0h0EQACmAAAIAAMI0h0EQACmAAAsAAQKfzcAAggACAhjI9sVAAgDAAgACAhjI9sVAAgDAAAA.',['就是']='就是德呀:BAACLAAFFH8nAAIPAAcIyBgECADkAQAPAAcIyBgECADkAQAsAAQKfz8AAg8ACAipHnEXAKgCAA8ACAipHnEXAKgCAAAA.',['尼古']='尼古拉斯开橙:BAAALAAECgYIBgAAAA==.',['尾巴']='尾巴藏不住:BAABLAAFFH8JAAILAAIIShUHRAB6AAALAAIIShUHRAB6AAAAAA==.',['山寨']='山寨龙傲天:BAAALAAECgUIBQAAAA==.',['山有']='山有扶苏:BAABLAAFFH8OAAIGAAYIoAMVLwDcAAAGAAYIoAMVLwDcAAAAAA==.',['巧乐']='巧乐兹:BAAALAADCggICAAAAA==.',['巧克']='巧克力奶:BAAALAADCgUICgAAAA==.',['已然']='已然消逝:BAAALAAECgYIBgAAAA==.',['布莱']='布莱克刘能:BAAALAAECgcICQAAAA==.',['帅的']='帅的被人砍:BAAALAAFFAIIAgAAAA==.',['希尔']='希尔瓦納斯:BAAALAAECgEIAQAAAA==.',['希瓦']='希瓦丶呆毛:BAAALAAECggICAAAAA==.',['帝诶']='帝诶趣:BAAALAADCgYIBgAAAA==.',['平静']='平静思绪:BAACLAAFFH8WAAMMAAYIeBPLLgBeAQAMAAYIHxPLLgBeAQAXAAEIth58IgBdAAAsAAQKfx4ABAwABwhgIewrAJACAAwABwj5H+wrAJACABcABgh6E/A2AJEBABgAAQgZIAY2AFkAAAAA.',['幺二']='幺二灵:BAAALAAECgYIDAAAAA==.',['库布']='库布齐剑客:BAAALAAECgYIBgAAAA==.',['归尘']='归尘:BAAALAAFFAIIBAAAAA==.',['彦小']='彦小昕:BAAALAADCgMIAwAAAA==.',['彩色']='彩色熊猫:BAAALAADCgcIBwAAAA==.',['得鹿']='得鹿梦渔:BAABLAAFFH8GAAIIAAIIsBCsXwCMAAAIAAIIsBCsXwCMAAAAAA==.得鹿梦鱼丶:BAAALAAFFAIIBAAAAA==.',['德天']='德天独后:BAAALAAFFAEIAQAAAA==.',['心心']='心心的:BAAALAADCggICQAAAA==.',['快乐']='快乐的骑士:BAAALAAFFAIIBAAAAA==.',['快到']='快到包里来:BAAALAADCgIIAgAAAA==.',['怪咖']='怪咖:BAAALAAECgIIAgAAAA==.',['恶魔']='恶魔印记:BAAALAAECgMIAwAAAA==.',['悔恨']='悔恨岭:BAAALAADCgcIBwAAAA==.',['悠带']='悠带刀:BAACLAAFFH8JAAIXAAIIVx/eCwCxAAAXAAIIVx/eCwCxAAAsAAQKfxUAAhcACAjTIiAEAC8DABcACAjTIiAEAC8DAAAA.',['悠扬']='悠扬的脚尖:BAAALAADCgcIBwAAAA==.',['悠闲']='悠闲自在:BAAALAADCgEIAQAAAA==.',['慑天']='慑天:BAABLAAECn8wAAIZAAgISBysHQAoAgAZAAgISBysHQAoAgAAAA==.',['我叫']='我叫小妹:BAAALAAECgYIDQAAAA==.',['我是']='我是大柠檬:BAAALAAECgQIBAAAAA==.我是歌手:BAAALAAECgUIBQAAAA==.',['我爱']='我爱玩原神:BAABLAAFFH8IAAIBAAIIIB10QQCxAAABAAIIIB10QQCxAAAAAA==.',['拉粑']='拉粑粑小魔仙:BAAALAAECgYIBgAAAA==.',['拜月']='拜月:BAAALAAECgQIBAAAAA==.',['搞事']='搞事情:BAAALAAECgYICAAAAA==.',['故事']='故事还长:BAABLAAFFH8KAAILAAIIzCBUPQCuAAALAAIIzCBUPQCuAAAAAA==.',['散落']='散落的烟灰:BAABLAAECn8eAAIaAAYIbReXHQCnAQAaAAYIbReXHQCnAQAAAA==.',['敬蚩']='敬蚩尤一杯酒:BAAALAAECggICAABLAAFFAYIDgAGAKADAA==.',['文森']='文森特先生:BAAALAAECgQIBAAAAA==.',['无双']='无双赵子龙:BAABLAAFFH8KAAIGAAIILg7cNwCWAAAGAAIILg7cNwCWAAAAAA==.',['无心']='无心念经:BAABLAAFFH8GAAITAAIIIgqBOABwAAATAAIIIgqBOABwAAAAAA==.',['无敌']='无敌无敌:BAAALAADCgIIAgAAAA==.',['无视']='无视痛苦:BAABLAAECn8gAAMIAAYIIyQgSQBPAgAIAAYICiQgSQBPAgAUAAYIECHRNgDiAQAAAA==.',['早已']='早已紧闭双眼:BAAALAADCgMIAwAAAA==.',['星灬']='星灬月夜:BAAALAAECgYIDwAAAA==.',['春秋']='春秋鼻法:BAABLAAFFH8MAAIFAAgIMxv+BQCKAgAFAAgIMxv+BQCKAgAAAA==.',['昨日']='昨日勾栏听曲:BAAALAAECgQIBAAAAA==.',['暗夜']='暗夜火球:BAAALAAFFAIIBAAAAA==.',['暴跳']='暴跳小四:BAAALAAECgYIDAAAAA==.暴跳老牛:BAAALAAECgYIBwAAAA==.暴跳貔貅:BAAALAAECgYIDAAAAA==.',['暴雨']='暴雨来了:BAAALAAECggIDAAAAA==.',['曹贼']='曹贼误我:BAAALAAECgYIEgAAAA==.',['最后']='最后一夜:BAACLAAFFH8YAAQKAAYIGAhcDwAGAQAKAAYIGAhcDwAGAQAbAAIIWAIjEQB8AAAPAAEIcQGnLgA+AAAsAAQKfzQABAoACAjWF8smAKQBAAoACAjWF8smAKQBAA8ACAgaDMRLAIUBABsABQjiDtIsACkBAAAA.最后壹夜:BAAALAAECgYIBgAAAA==.',['月亮']='月亮神:BAABLAAFFH8GAAIKAAII9h7qGwCzAAAKAAII9h7qGwCzAAAAAA==.',['木今']='木今:BAAALAAFFAIIAgAAAA==.',['木木']='木木墓:BAAALAAECgcICAAAAA==.',['杀戮']='杀戮之中绽放:BAAALAAECgQIBAAAAA==.',['李世']='李世民:BAAALAAFFAIIAgAAAA==.',['杨多']='杨多多:BAABLAAECn8dAAIDAAYIlRJnLwBCAQADAAYIlRJnLwBCAQAAAA==.',['格兰']='格兰姆:BAAALAADCgQIBAAAAA==.',['格欏']='格欏姆:BAAALAAECgIIAQAAAA==.',['桃术']='桃术子:BAAALAAECgQIBAAAAA==.',['桃桃']='桃桃子:BAABLAAFFH8JAAIJAAIISgnvVwCDAAAJAAIISgnvVwCDAAAAAA==.',['梧桐']='梧桐:BAAALAADCggIHgAAAA==.',['欧皇']='欧皇墨老六:BAAALAADCgYIBgAAAA==.',['欲望']='欲望天堂:BAAALAAECgYIBgAAAA==.',['残枫']='残枫秋落:BAABLAAECn9AAAIBAAgIIB2dEwBMAgABAAgIIB2dEwBMAgAAAA==.',['水影']='水影忍者:BAAALAAECgQIBAAAAA==.',['水蓝']='水蓝蓝:BAAALAAECgQIBAAAAA==.',['永生']='永生:BAAALAAECgQIBAAAAA==.',['沐浴']='沐浴春风:BAACLAAFFH8LAAIDAAIIMxwYKACaAAADAAIIMxwYKACaAAAsAAQKfxkAAwMACAg6HEoaAOwBAAMACAg6HEoaAOwBAAQABwg4HA0SAMsBAAAA.',['泡沫']='泡沫啊:BAAALAAECgYIAwAAAA==.',['洃羽']='洃羽傀儡:BAABLAAFFH8IAAQUAAIILxT2JwB4AAAUAAIIlgv2JwB4AAAcAAEI7w0ICABOAAAIAAII8RGErAA5AAAAAA==.',['浆糊']='浆糊信仰圣光:BAAALAAFFAIIAgAAAA==.浆糊风行者:BAAALAAECgYIBgAAAA==.',['海狗']='海狗猎:BAAALAAECgMIAwAAAA==.',['海鸥']='海鸥不乖:BAAALAADCgQIBAAAAA==.',['淹死']='淹死的锤头鲨:BAABLAAFFH8GAAIZAAYIvBFVIwBUAQAZAAYIvBFVIwBUAQAAAA==.',['滴溜']='滴溜媛:BAABLAAFFH8GAAIKAAII/hbnJwCKAAAKAAII/hbnJwCKAAAAAA==.',['漩涡']='漩涡大雄:BAABLAAECn8UAAMFAAYIgxYvfgCWAQAFAAYIgxYvfgCWAQAdAAQICgYweACJAAAAAA==.',['火柴']='火柴:BAACLAAFFH8eAAIBAAYIBBdHKAD4AAABAAYIBBdHKAD4AAAsAAQKfy8AAgEACAjqJJoJAK0CAAEACAjqJJoJAK0CAAAA.',['灬冰']='灬冰镇绿豆汤:BAABLAAFFH8JAAIIAAYInQ4NRAA5AQAIAAYInQ4NRAA5AQAAAA==.',['灬虎']='灬虎皮辣椒:BAABLAAFFH8HAAIBAAMIVg0AcQBRAAABAAMIVg0AcQBRAAAAAA==.',['灬邪']='灬邪惡丨蔓延:BAAALAAFFAIIBAAAAA==.',['灰的']='灰的:BAAALAADCgEIAQAAAA==.',['炼狱']='炼狱神魔:BAACLAAFFH8GAAIBAAIIsAxAkQA+AAABAAIIsAxAkQA+AAAsAAQKfxwAAgEABwgNFAlJAGcBAAEABwgNFAlJAGcBAAAA.',['烛龍']='烛龍:BAAALAAFFAIIBAAAAA==.',['烟灰']='烟灰伍虒:BAACLAAFFH8OAAMDAAIIJgyjQABpAAADAAIIJgyjQABpAAAEAAIIWRiNJgBLAAAsAAQKfxcAAwQACAjiGzQZAKMCAAQACAjiGzQZAKMCAAMABgh7DoVxACcBAAAA.',['無牙']='無牙:BAAALAAFFAIIAgAAAA==.',['熊猫']='熊猫两千:BAACLAAFFH8NAAILAAMIChHDMQCeAAALAAMIChHDMQCeAAAsAAQKfxYAAgsABggmIH1ZANkBAAsABggmIH1ZANkBAAAA.',['燃烧']='燃烧的凶毛:BAAALAAECgUIBgAAAA==.',['爆浆']='爆浆小丸子:BAABLAAFFH8JAAIZAAII9Q1YWwCFAAAZAAII9Q1YWwCFAAAAAA==.',['爱我']='爱我永远:BAAALAADCgQIBQAAAA==.',['牛一']='牛一樣的漢子:BAABLAAFFH8IAAILAAMIcR23LwDwAAALAAMIcR23LwDwAAAAAA==.',['牛牛']='牛牛会战复:BAABLAAFFH8IAAMKAAIIOg5dRwBgAAAKAAIIOg5dRwBgAAAQAAII+gguEAAlAAAAAA==.',['牛里']='牛里牛气:BAAALAAFFAIIAgAAAA==.',['牧沐']='牧沐时光暖:BAAALAAECgIIAgAAAA==.',['特调']='特调馥芮白:BAABLAAFFH8MAAIDAAMI8xMWLADEAAADAAMI8xMWLADEAAAAAA==.',['狂战']='狂战圣堂:BAAALAAECgUIBQAAAA==.狂战恶魔:BAAALAADCgIIAgAAAA==.',['狐大']='狐大仙儿:BAAALAADCgMIAwAAAA==.',['独饮']='独饮月色:BAAALAAECgYIBwAAAA==.',['狼之']='狼之笑:BAABLAAFFH8XAAMLAAUIUA+WOgCLAAALAAQIjxGWOgCLAAATAAEIuwRXSgA9AAAAAA==.',['猎烈']='猎烈红尘疯:BAAALAAECgUIBQAAAA==.',['猖圣']='猖圣:BAABLAAFFH8GAAIeAAYISwLsEAD1AAAeAAYISwLsEAD1AAAAAA==.',['猪头']='猪头怪猎手:BAAALAADCgUIBQAAAA==.',['猫猫']='猫猫兔小舞:BAAALAAECgUIBQAAAA==.猫猫小天使:BAAALAAECggICwAAAA==.',['猫的']='猫的哲学:BAAALAAFFAIIAwAAAA==.',['王丶']='王丶风暴烈酒:BAAALAADCgUIBQAAAA==.',['玛丽']='玛丽莲梦怡:BAAALAAECgMIBAAAAA==.',['玩原']='玩原神玩的:BAAALAADCggICgAAAA==.',['珈蓝']='珈蓝:BAAALAAECgQIBAAAAA==.',['珍妮']='珍妮马仕多:BAAALAAFFAIIBAAAAA==.',['班门']='班门弄斧:BAAALAAFFAIIBAAAAA==.',['甜桃']='甜桃子:BAABLAAFFH8GAAIBAAYIbh/cGgDLAQABAAYIbh/cGgDLAQAAAA==.',['电亮']='电亮:BAAALAAECgMIAgAAAA==.',['略懂']='略懂拳脚:BAAALAAECgQIBAAAAA==.',['疯一']='疯一样的女子:BAABLAAFFH8PAAIBAAIIExu2cgBOAAABAAIIExu2cgBOAAAAAA==.',['疯狂']='疯狂天涯舞:BAABLAAECn8VAAIIAAYIXgneGwEJAQAIAAYIXgneGwEJAQAAAA==.疯狂汉娜:BAAALAAECgMIAwAAAA==.疯狂的岩哥:BAAALAADCgQIBAAAAA==.',['盗圣']='盗圣:BAAALAADCgMIAwAAAA==.',['相逢']='相逢醉酒间:BAAALAAECgEIAQAAAA==.',['盾击']='盾击炖鸡盾击:BAAALAADCggICAAAAA==.',['看谁']='看谁都打冷颤:BAAALAAECgcICgAAAA==.',['硬灬']='硬灬漢:BAAALAAFFAIIAwAAAA==.',['碧水']='碧水涟漪:BAAALAAECgYICwAAAA==.',['神之']='神之以法:BAAALAAFFAEIAQAAAA==.',['神貂']='神貂大姑父:BAAALAAECgQIBAAAAA==.',['神锣']='神锣天征:BAAALAAFFAIIAgAAAA==.',['禁书']='禁书:BAAALAAECggIDgABLAAFFAgIBwABAFQYAA==.',['禽獸']='禽獸:BAAALAADCgQIBAAAAA==.',['稀哩']='稀哩哗啦拉:BAAALAADCgIIAgAAAA==.',['空悟']='空悟圣大天齐:BAAALAAECgYIBwAAAA==.',['站吊']='站吊:BAAALAAFFAIIAgAAAA==.',['竹取']='竹取飞翔:BAAALAAFFAIIAgABLAAFFAMIEAAVADYQAA==.',['筱牙']='筱牙:BAAALAAFFAMIAwAAAA==.',['糖宗']='糖宗送祖:BAACLAAFFH8jAAMLAAUIoiBVEgDQAQALAAUIoiBVEgDQAQATAAIIuwM8TgA3AAAsAAQKfx8AAwsACAidGb0gAPYBAAsACAidGb0gAPYBABMABQiQDLdaAKcAAAAA.',['糖里']='糖里没兜兜:BAAALAAFFAEIAQAAAA==.',['紫清']='紫清:BAACLAAFFH8cAAIIAAYIhxZ8JQDnAAAIAAYIhxZ8JQDnAAAsAAQKfxgAAwgABgi1I7pAAGUCAAgABgi1I7pAAGUCABQAAggvCbyzAEgAAAEsAAUUCAhKABEAVx8A.',['縌灬']='縌灬吥勭:BAAALAADCggICAAAAA==.',['红尘']='红尘丶二两:BAABLAAFFH8IAAIfAAIILAoPFwBkAAAfAAIILAoPFwBkAAAAAA==.',['纯白']='纯白皮卡丘:BAAALAAECgIIAwAAAA==.',['终极']='终极侮辱:BAAALAAECgEIAQAAAA==.',['绿影']='绿影拂泽:BAAALAAECgYIBgAAAA==.',['羽灬']='羽灬十:BAAALAADCgUIBQAAAA==.',['翩翩']='翩翩舞广袖:BAABLAAFFH8GAAIHAAIIjhVeHACRAAAHAAIIjhVeHACRAAAAAA==.',['翳小']='翳小云:BAAALAAECgMIAgAAAA==.',['老玻']='老玻璃:BAAALAAFFAIIBAAAAA==.',['背刺']='背刺的小小牧:BAAALAAECgYIBgAAAA==.',['背叛']='背叛中刺杀:BAAALAADCggIDQAAAA==.背叛者之歌:BAAALAAFFAIIAgAAAA==.',['胖胖']='胖胖龙:BAAALAAFFAIIAgAAAA==.',['胡子']='胡子妈妈:BAAALAAFFAIIBAAAAA==.',['能扛']='能扛:BAAALAAECgcIEwAAAA==.',['能插']='能插:BAAALAAECgYIBgAAAA==.',['能摇']='能摇人儿:BAAALAAECgMIAwAAAA==.',['能萌']='能萌不萌:BAAALAAECgYIDAAAAA==.',['花顔']='花顔:BAAALAAECgUIBQAAAA==.',['莉亞']='莉亞徳琳丶:BAABLAAFFH8GAAIZAAIILBclOgCiAAAZAAIILBclOgCiAAAAAA==.',['菊花']='菊花盛宴:BAAALAADCgQIBgAAAA==.',['萌萌']='萌萌的奎姆:BAAALAAFFAIIAgAAAA==.',['落寞']='落寞丶煙愺菋:BAABLAAFFH8KAAMHAAMIeA3SEQDSAAAHAAMIeA3SEQDSAAAgAAEIXAN+JAAlAAABLAAFFAYIGAAKABgIAA==.',['虎先']='虎先锋:BAAALAAECgYIBgAAAA==.',['蛋蛋']='蛋蛋的裂变:BAAALAAFFAIIBAAAAA==.',['蜜桃']='蜜桃儿:BAAALAAECgMIAwAAAA==.',['蝶舞']='蝶舞飞:BAAALAADCgIIAgAAAA==.',['血月']='血月红莲:BAAALAADCgYIBgAAAA==.',['血魄']='血魄苍岚:BAAALAAECgMIAwAAAA==.',['血魔']='血魔老祖:BAABLAAFFH8JAAIWAAMI6RT3BwDuAAAWAAMI6RT3BwDuAAAAAA==.',['西瓜']='西瓜萃香:BAAALAAECgEIAQAAAA==.',['誓约']='誓约之锤:BAAALAADCgUIBQAAAA==.',['諾森']='諾森德的雪:BAABLAAFFH8GAAIBAAII5gZIlAA8AAABAAII5gZIlAA8AAAAAA==.',['诺斯']='诺斯提克:BAAALAAECggIEwAAAA==.',['谷雨']='谷雨:BAAALAAFFAMIAgAAAA==.',['贝狄']='贝狄威尔:BAAALAAECggICAAAAA==.',['赴潮']='赴潮生咕咕:BAAALAAECgYIBgAAAA==.',['赵老']='赵老湿:BAAALAAECgQIBAAAAA==.赵老狮:BAAALAAECgYIDAAAAA==.',['超大']='超大榛果拿铁:BAACLAAFFH8FAAIhAAIIWwqtFQBeAAAhAAIIWwqtFQBeAAAsAAQKfyQAAiEACAjBDhgrAF8BACEACAjBDhgrAF8BAAAA.',['超级']='超级莼菜:BAAALAAECgYIBgAAAA==.超级马里奥:BAAALAADCgQIBAAAAA==.',['跢他']='跢他伽多耶:BAAALAAECgIIAgAAAA==.',['踏星']='踏星飞雪:BAAALAADCgYIBgAAAA==.',['轰炸']='轰炸鸡:BAAALAAECgYICwAAAA==.',['辣鸡']='辣鸡有喜:BAAALAAFFAIIBAAAAA==.',['达尔']='达尔文丶丶:BAAALAAECgYIBgAAAA==.达尔文丶徳:BAAALAAECgYIBgAAAA==.',['这货']='这货能打:BAAALAAECgcIBwAAAA==.',['逗七']='逗七七:BAAALAADCgYIBgAAAA==.',['逗小']='逗小七:BAAALAADCgUIBQAAAA==.',['通灵']='通灵巫师:BAAALAAFFAIIAgAAAA==.',['遗忘']='遗忘的未来:BAABLAAECn8VAAIgAAcI0hImNQB1AQAgAAcI0hImNQB1AQAAAA==.',['那一']='那一抹微凉:BAAALAAECgIIAwAAAA==.',['那云']='那云:BAAALAAECggICAABLAAFFAYIDQAGAOMRAA==.',['邪恶']='邪恶银渐层:BAABLAAFFH8GAAIBAAIIqRumTgCiAAABAAIIqRumTgCiAAAAAA==.',['部落']='部落大医师:BAABLAAFFH8FAAIDAAIIyxkQNACXAAADAAIIyxkQNACXAAAAAA==.',['酋长']='酋长加尓鲁什:BAAALAAECggICAAAAA==.',['酒仙']='酒仙儿:BAAALAADCgYIBgAAAA==.',['醉后']='醉后一夜:BAABLAAFFH8IAAIGAAII3xlEJwCqAAAGAAII3xlEJwCqAAABLAAFFAYIGAAKABgIAA==.',['醉後']='醉後壹夜:BAAALAADCgUIBQABLAAFFAYIGAAKABgIAA==.',['醉灬']='醉灬寻仙:BAAALAAECgYIBgAAAA==.',['银月']='银月圣光:BAAALAADCgIIBgAAAA==.',['锤你']='锤你个棒槌:BAAALAAECgMIBQAAAA==.',['门钉']='门钉肉饼:BAAALAAECggICAAAAA==.',['间歇']='间歇发疯体:BAAALAAFFAIIBAAAAA==.',['阿吧']='阿吧阿吧:BAAALAAFFAIIAgAAAA==.',['阿曼']='阿曼德:BAAALAADCgYIBgAAAA==.',['陈不']='陈不留情:BAAALAAFFAIIAgABLAAFFAIIBAAOAAAAAA==.',['雕虫']='雕虫小技:BAAALAAFFAIIAgAAAA==.',['雨中']='雨中漫步:BAACLAAFFH8XAAIDAAYI/Q+8GgB5AQADAAYI/Q+8GgB5AQAsAAQKfy0AAyIACAgQGnsJABgCACIACAgCFnsJABgCAAMACAgoF7s5APMBAAAA.雨中行走:BAAALAAFFAIIAgAAAA==.',['雷科']='雷科萨小迷妹:BAAALAAECgEIAQAAAA==.',['霜岚']='霜岚:BAABLAAFFH8GAAIBAAYIsQGGTwDiAAABAAYIsQGGTwDiAAABLAAFFAYIDgAGAKADAA==.',['霸山']='霸山欺妖:BAAALAAECgYICwAAAA==.',['静心']='静心:BAACLAAFFH8dAAIFAAYIfR12HgA/AQAFAAYIfR12HgA/AQAsAAQKfyAAAgUABwgpJVIgAM4CAAUABwgpJVIgAM4CAAAA.',['風卷']='風卷残云:BAAALAAFFAIIAQAAAA==.',['风涧']='风涧司丶:BAAALAAECggICAAAAA==.',['风逍']='风逍遥:BAAALAAECgQIBAAAAA==.',['飕灬']='飕灬灬啪:BAAALAADCgcIBwAAAA==.',['飞翔']='飞翔的甲壳虫:BAAALAAECgQIBAAAAA==.',['饼弓']='饼弓纸法:BAABLAAFFH8QAAIFAAgIEhnqBwBmAgAFAAgIEhnqBwBmAgAAAA==.',['香辣']='香辣鸡腿堡丶:BAABLAAFFH8jAAIBAAgI7yJhAgDjAgABAAgI7yJhAgDjAgAAAA==.',['鬥魂']='鬥魂:BAAALAAECgUIBQAAAA==.',['鬼俯']='鬼俯魔皇:BAABLAAFFH8GAAICAAIIIwL+MQBBAAACAAIIIwL+MQBBAAAAAA==.',['魔人']='魔人紫:BAABLAAECn8WAAIJAAYIihW+mgCVAQAJAAYIihW+mgCVAQAAAA==.',['魔兽']='魔兽纯萌新:BAAALAAFFAIIBAAAAA==.',['魔教']='魔教老九:BAABLAAFFH8GAAIZAAYISwCigQApAAAZAAYISwCigQApAAAAAA==.',['鸠地']='鸠地震法:BAABLAAFFH8MAAIFAAYIghRHJQB/AQAFAAYIghRHJQB/AQAAAA==.',['鸿蒙']='鸿蒙:BAAALAADCggIDAAAAA==.',['鹰角']='鹰角弓:BAAALAAFFAQIBAAAAA==.',['黎明']='黎明光刃:BAAALAADCgUIBQAAAA==.',['黎曼']='黎曼:BAAALAAECgEIAQAAAA==.',['龍首']='龍首山扛把子:BAABLAAFFH8LAAILAAMIvBrwMwDXAAALAAMIvBrwMwDXAAAAAA==.',['龙人']='龙人二零二四:BAAALAAFFAIIAwAAAA==.',['龙源']='龙源:BAABLAAECn8aAAIBAAcIABa0OQCVAQABAAcIABa0OQCVAQAAAA==.龙源梵:BAABLAAECn8UAAIZAAcIpBQcSwB8AQAZAAcIpBQcSwB8AQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end