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
 local lookup = {'Paladin-Protection','Druid-Restoration','Unknown-Unknown','Warrior-Protection','Hunter-Marksmanship','DemonHunter-Vengeance','DemonHunter-Havoc','Rogue-Assassination','DeathKnight-Blood','Shaman-Restoration','Warlock-Destruction','Warlock-Affliction','Paladin-Retribution','Paladin-Holy','Priest-Holy','Hunter-BeastMastery','Mage-Frost','DeathKnight-Unholy','Shaman-Elemental','Priest-Discipline','Monk-Mistweaver','Mage-Arcane','Mage-Fire','Druid-Balance','Druid-Guardian','Rogue-Subtlety','Druid-Feral','Warrior-Fury','Warrior-Arms','Warlock-Demonology','DeathKnight-Frost','Rogue-Outlaw','Priest-Shadow','Monk-Brewmaster','Monk-Windwalker','Hunter-Survival',}; local provider = {region='CN',realm='玛瑟里顿',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ad='Adamant:BAABKgAFFH8GAAIBAAYIwRx8BwCcAQABAAYIwRx8BwCcAQAAAA==.',Am='Amoureternel:BAAAKgAFFAgIBAAAAA==.',An='Anderson:BAABKgAFFH8GAAICAAYIOBOsBgBWAQACAAYIOBOsBgBWAQABKgAFFAgIBAADAAAAAA==.',Ap='Aphródite:BAAAKgAECgQIBAAAAA==.',At='Athenamagic:BAAAKgAECgcIEAAAAA==.',Bf='Bfate:BAAAKgAECgEIAQAAAA==.',Bi='Bigsun:BAAAKgAECgUIBQAAAA==.Biubiubibiu:BAAAKgADCggICAAAAA==.',Cm='Cmbb:BAAAKgAECgYIBgAAAA==.',Cs='Css:BAAAKgAFFAQIBAAAAA==.',Da='Dari:BAAAKgAECgMIAwAAAA==.',De='Deepsea:BAABKgAFFH8RAAIEAAMIeQSnEQBvAAAEAAMIeQSnEQBvAAAAAA==.',Ed='Edinburgh:BAABKgAFFH8IAAIFAAQIMyFIBwAMAQAFAAQIMyFIBwAMAQAAAA==.',Ev='Evangel:BAAAKgAFFAEIAQAAAA==.Evolution:BAAAKgADCgEIAQAAAA==.',Fg='Fgsgegw:BAACKgAFFH8UAAIGAAMI1gJZIABfAAAGAAMI1gJZIABfAAAqAAQKfxUAAwYACAjUC8A7ANMAAAYACAgdC8A7ANMAAAcAAghqC7uPAEgAAAAA.',Fl='Florence:BAAAKgAFFAIIAgAAAA==.',Ge='Gee:BAABKgAFFH8LAAIIAAYIMRuOCgCkAQAIAAYIMRuOCgCkAQABKgAFFAgICAAJAM0cAA==.',Gi='Ginshadow:BAAAKgAECggICAAAAA==.',Gr='Gracey:BAAAKgAECggIEAAAAA==.',He='Heiy:BAAAKgAECgQIBAAAAA==.',Ho='Holylight:BAAAKgAFFAQIAgAAAA==.',In='Infiltration:BAACKgAFFH8ZAAIKAAQIzRrwFwDFAAAKAAQIzRrwFwDFAAAqAAQKfzsAAgoACAglIIcSAGYCAAoACAglIIcSAGYCAAAA.',Is='Ishtar:BAAAKgAECgEIAQAAAA==.',Jo='Jokey:BAAAKgAECgMIAwAAAA==.',La='Laughinggor:BAAAKgAECgYIDAAAAA==.',Le='Levi:BAAAKgAECgYIDQAAAA==.',Me='Metiss:BAACKgAFFH8QAAMLAAYIKhmzFwBGAQALAAYILBazFwBGAQAMAAQIZhS9EACeAAAqAAQKfxkAAgsACAidGRoVAP8BAAsACAidGRoVAP8BAAAA.',Mo='Momosr:BAABKgAECn8gAAIKAAgIZR9NJwDwAQAKAAgIZR9NJwDwAQAAAA==.Momoya:BAAAKgAECgcIDQAAAA==.',Na='Naiolo:BAABKgAFFH8VAAQNAAYIeB4SEAAUAQANAAYIeB4SEAAUAQAOAAII/w/FEwBJAAABAAEInw9pFQA1AAABKgAFFAgIGgABADESAA==.',Or='Orcwarrior:BAAAKgAFFAIIBAAAAA==.',Pa='Paim:BAAAKgAECggIDgAAAA==.',Pe='Penetrateme:BAAAKgADCgYIBgAAAA==.',Pu='Purelove:BAABKgAFFH8IAAIKAAQILxcNDgDuAAAKAAQILxcNDgDuAAAAAA==.',Ro='Ronaldio:BAAAKgAFFAIIAgAAAA==.',Ru='Rushsun:BAAAKgAECggIDQAAAA==.',Sc='Scotti:BAABKgAECn8VAAIPAAgIFQoPSgDpAAAPAAgIFQoPSgDpAAAAAA==.',Sh='Shadowalker:BAACKgAFFH8FAAIFAAMI/RfVJwDLAAAFAAMI/RfVJwDLAAAqAAQKfykAAwUACAjHIB4OAGkCAAUACAgrIB4OAGkCABAAAwg8EuzcAHQAAAAA.',Si='Sick:BAAAKgAFFAgIBAAAAA==.',Sl='Slyb:BAABKgAECn8sAAIEAAgI1gtBKQDkAAAEAAgI1gtBKQDkAAAAAA==.',So='Souler:BAAAKgAECgMIBQAAAA==.',Su='Sun:BAAAKgAECgcICgAAAA==.',Th='Theas:BAABKgAFFH8FAAIEAAMIlANEDABlAAAEAAMIlANEDABlAAAAAA==.',Tk='Tklord:BAAAKgAECgYICQAAAA==.',To='Tobefree:BAABKgAFFH8GAAINAAYIDw0mZACnAAANAAYIDw0mZACnAAAAAA==.Tori:BAAAKgADCgIIAgAAAA==.',Ty='Tyland:BAAAKgAECgcICAAAAA==.',Va='Vampiream:BAACKgAFFH8MAAIRAAQICx7jBAAKAQARAAQICx7jBAAKAQAqAAQKfyUAAhEACAjMIXoLAIICABEACAjMIXoLAIICAAAA.',Wq='Wqzyyds:BAAAKgAECgIIAgAAAA==.',['Wé']='Wéissmel:BAABKgAECn8WAAMSAAgIFA26eQD3AAASAAgIFA26eQD3AAAJAAUIAQbJVABoAAAAAA==.',Xj='Xj:BAAAKgAFFAEIAQAAAA==.',Ye='Yey:BAAAKgAECgcIBwAAAA==.',Zi='Zipary:BAAAKgAECgQIBAAAAA==.',Zs='Zs:BAAAKgADCgMIAwAAAA==.',['一千']='一千零一个瓜:BAAAKgAECgYICwAAAA==.',['丁浩']='丁浩:BAAAKgAECgIIAgAAAA==.',['上帝']='上帝之手:BAAAKgAECgYIDwAAAA==.',['丑萌']='丑萌:BAAAKgAECggIEwAAAA==.',['专踹']='专踹瘸子好腿:BAACKgAFFH8JAAINAAMI3hXGTADVAAANAAMI3hXGTADVAAAqAAQKfzkAAg0ACAiCIRMwAGACAA0ACAiCIRMwAGACAAAA.',['丨莉']='丨莉莉娅丨:BAABKgAECn8XAAMNAAgIwxdHSgDhAQANAAgIwxdHSgDhAQABAAEIVQB9ZAABAAAAAA==.',['丶呼']='丶呼噜:BAAAKgADCgMIAwAAAA==.',['丶终']='丶终景:BAAAKgAFFAQIAgAAAA==.',['丶路']='丶路子野:BAACKgAFFH8ZAAIJAAQILA40IgCWAAAJAAQILA40IgCWAAAqAAQKfzgAAgkACAhODw4uACEBAAkACAhODw4uACEBAAAA.',['丷小']='丷小幸运丷:BAAAKgAECgcIDAAAAA==.',['亲爱']='亲爱滴鬼鬼:BAAAKgAFFAcIAgABKgAFFAgIEAAQAKobAA==.亲爱的鬼鬼:BAAAKgAFFAgIAQAAAA==.',['休想']='休想丶奶我:BAAAKgAECgUIBQAAAA==.',['伤心']='伤心小箭:BAAAKgAECggIEAAAAA==.',['低端']='低端熊猫:BAABKgAECn8gAAIOAAgI6xncEwDPAQAOAAgI6xncEwDPAQAAAA==.',['何家']='何家欣:BAAAKgADCgEIAQAAAA==.',['俏狸']='俏狸花:BAAAKgAECgIIAgAAAA==.',['修罗']='修罗地狱:BAABKgAFFH8KAAINAAgI2hk2CQAvAgANAAgI2hk2CQAvAgAAAA==.',['俺寻']='俺寻思之力:BAAAKgAECgMIAwAAAA==.',['假笑']='假笑扮从容:BAAAKgAFFAUIBAAAAA==.',['元素']='元素恢复增强:BAABKgAECn8cAAITAAgIAxURJQCnAQATAAgIAxURJQCnAQAAAA==.',['先祖']='先祖忽悠了你:BAAAKgAECgYICAAAAA==.',['八星']='八星剔骨:BAAAKgAECggICAAAAA==.',['公主']='公主一号:BAAAKgAECgEIAQAAAA==.',['农夫']='农夫三拳:BAAAKgAECgUIBQAAAA==.',['冯二']='冯二狗:BAABKgAECn8XAAIHAAgI7xRoMwCOAQAHAAgI7xRoMwCOAQAAAA==.',['冯欣']='冯欣然:BAAAKgAECgcICAAAAA==.',['冰焱']='冰焱妩魅:BAABKgAFFH8GAAIUAAMIKwodDwCOAAAUAAMIKwodDwCOAAAAAA==.',['冰霜']='冰霜小鲤鱼:BAACKgAFFH8WAAIQAAgI3AxlCADrAQAQAAgI3AxlCADrAQAqAAQKfzIAAhAACAgMGY8vAOwBABAACAgMGY8vAOwBAAAA.',['冰魂']='冰魂割裂者:BAAAKgAECgUIBQAAAA==.',['冷艳']='冷艳冰焰:BAAAKgAFFAYIBAAAAA==.冷艳流星锤:BAABKgAFFH8IAAMKAAQI6iVrEgBBAQAKAAQI6iVrEgBBAQATAAEIOQKsHQA4AAAAAA==.',['冷静']='冷静莫冲动丶:BAAAKgAFFAYIBAAAAA==.',['凋魂']='凋魂语:BAAAKgAECgEIAQAAAA==.',['凌小']='凌小皮:BAAAKgAFFAQIBAAAAA==.',['别惹']='别惹我汉中滴:BAAAKgADCgEIAQAAAA==.',['剑舞']='剑舞:BAAAKgAECgIIAgAAAA==.',['功夫']='功夫:BAABKgAFFH8FAAIVAAMI3gH0KgBuAAAVAAMI3gH0KgBuAAAAAA==.功夫海牛哞哞:BAAAKgADCgEIAQAAAA==.',['努力']='努力的饺子:BAABKgAFFH8XAAQRAAYIVyTvAgDdAQARAAYImyLvAgDdAQAWAAYIlyFSCwC1AQAXAAQI9hhrFgD0AAABKgAFFAgIGAAUAOgeAA==.',['北极']='北极热死的熊:BAAAKgAECggICAAAAA==.',['十佬']='十佬会王焊:BAAAKgAFFAQIBAAAAA==.',['半根']='半根烟闯江湖:BAAAKgAECgQIBwAAAA==.',['半面']='半面蔷薇:BAAAKgAECgMIAwAAAA==.',['南玻']='南玻万:BAAAKgADCgMIAwAAAA==.',['又要']='又要改名字:BAAAKgAECggIDAAAAA==.',['古或']='古或今:BAAAKgAECgMIBAAAAA==.',['可爱']='可爱的会会:BAABKgAFFH8QAAMQAAgI5gf4CgCcAQAQAAgICQb4CgCcAQAFAAgIoAZ7CgByAQAAAA==.可爱的苗苗:BAABKgAFFH8FAAINAAUIVwGNOgBwAAANAAUIVwGNOgBwAAAAAA==.',['史昂']='史昂:BAAAKgAECgQIBgAAAA==.',['吃琪']='吃琪琪吧:BAAAKgAFFAgIAwAAAA==.',['吉祥']='吉祥:BAABKgAECn8WAAMRAAgI3xfZIwCVAQARAAcIxBfZIwCVAQAWAAgICxHwNwBqAQAAAA==.',['吾妻']='吾妻善逸:BAAAKgAECgcICwAAAA==.',['呀吼']='呀吼:BAAAKgAFFAIIAgAAAA==.',['咸味']='咸味生活:BAAAKgAECgEIAQAAAA==.',['啪啪']='啪啪丁:BAAAKgAFFAQIBAAAAA==.',['喏喏']='喏喏:BAABKgAFFH8KAAMKAAYIfgkwMgCxAAAKAAQI5QowMgCxAAATAAIIbA8WHwCCAAAAAA==.',['喳哥']='喳哥来也:BAABKgAECn80AAQCAAgIng4TMAA1AQACAAgIng4TMAA1AQAYAAUI5w0UkgCyAAAZAAEIFwm+RAASAAAAAA==.喳哥祭师:BAAAKgADCgEIAQAAAA==.',['喳喳']='喳喳猎手:BAAAKgAECgIIAgAAAA==.',['土之']='土之元素:BAABKgAFFH8SAAIKAAYIOxKSDwBcAQAKAAYIOxKSDwBcAQAAAA==.',['圣休']='圣休亚瑞:BAABKgAECn8uAAILAAgIlBynBgBBAgALAAgIlBynBgBBAgAAAA==.',['圣光']='圣光银神:BAAAKgADCggICAAAAA==.',['圣言']='圣言祭歌:BAAAKgAFFAQIBAAAAA==.',['堕落']='堕落老黄牛:BAAAKgAFFAQIAgAAAA==.',['塞纳']='塞纳河畔:BAAAKgADCgQIBAAAAA==.',['夕凌']='夕凌雪翊:BAAAKgAFFAUIAQAAAA==.',['夕岚']='夕岚:BAAAKgAFFAQIBAAAAA==.',['夜幕']='夜幕降临迅影:BAAAKgAECggICAAAAA==.',['夜影']='夜影之刃:BAABKgAFFH8JAAIGAAMIdwEcEQBSAAAGAAMIdwEcEQBSAAAAAA==.夜影之刺:BAABKgAFFH8PAAMIAAYI8Q1jDwBbAQAIAAYI/AxjDwBbAQAaAAMIPxIzBADNAAAAAA==.夜影之歌:BAACKgAFFH8OAAQYAAUI2Q0DIAC6AAAYAAUIWwwDIAC6AAAZAAMIcQgZBgBwAAACAAEIrgB0KAAlAAAqAAQKfxcABBsACAgdFAQSAHgBABsABwicEwQSAHgBAAIAAwhNCjRpAHoAABgAAwgPB8exAF8AAAAA.夜影之谕:BAABKgAFFH8LAAIPAAgI8wNeCQBDAQAPAAgI8wNeCQBDAQAAAA==.',['夜猎']='夜猎:BAABKgAECn8WAAMQAAgIXgR1TQBpAAAQAAUITwR1TQBpAAAFAAgINwMEngBAAAAAAA==.',['夜色']='夜色中变态:BAACKgAFFH8ZAAIYAAQIIRBFHADKAAAYAAQIIRBFHADKAAAqAAQKfyoAAhgACAgiF+w2AM0BABgACAgiF+w2AM0BAAAA.',['夜骑']='夜骑:BAAAKgADCggICQAAAA==.',['大一']='大一大万大吉:BAABKgAECn8rAAIVAAgIvhjTHAAEAgAVAAgIvhjTHAAEAgAAAA==.',['大主']='大主教格蕾雅:BAABKgAFFH8IAAINAAQINhr+UwDIAAANAAQINhr+UwDIAAAAAA==.',['大劈']='大劈叉:BAAAKgAECgUIBQAAAA==.',['大圣']='大圣光给你嗦:BAAAKgADCgIIAgAAAA==.',['大家']='大家都跑开:BAABKgAFFH8cAAICAAgIsxVJBADvAQACAAgIsxVJBADvAQAAAA==.',['大恩']='大恩大德:BAAAKgADCgQIBAAAAA==.',['大懒']='大懒子:BAAAKgAECgEIAQAAAA==.',['大明']='大明湖畔可乐:BAAAKgADCggICAAAAA==.',['大长']='大长腿:BAAAKgAECgMIAwAAAA==.',['天使']='天使美雨儿:BAABKgAFFH8IAAINAAgI5BItCQAYAgANAAgI5BItCQAYAgAAAA==.',['天崩']='天崩地裂:BAAAKgAECggIEAAAAA==.',['天涯']='天涯冷血:BAABKgAFFH8NAAMcAAQIphdwHgDaAAAcAAQIphdwHgDaAAAdAAIIWw1gEQCUAAAAAA==.天涯大弘豆:BAAAKgAECgYICQAAAA==.天涯若风:BAACKgAFFH8VAAIFAAQIaRcgKADJAAAFAAQIaRcgKADJAAAqAAQKfyIAAgUACAj5Hns7AGcBAAUACAj5Hns7AGcBAAAA.',['奇中']='奇中骑丶:BAAAKgAECgEIAQAAAA==.',['奎师']='奎师那:BAACKgAFFH8LAAINAAIIzCJMLwCxAAANAAIIzCJMLwCxAAAqAAQKfzIAAg0ACAgVJMoPANgCAA0ACAgVJMoPANgCAAAA.',['奥古']='奥古西斯:BAAAKgADCggICAAAAA==.',['奥能']='奥能烧卖:BAACKgAFFH8GAAIRAAYIQhhVBQCHAQARAAYIQhhVBQCHAQAqAAQKfzoAAhEACAihF5odAMQBABEACAihF5odAMQBAAAA.',['奶的']='奶的很疼:BAAAKgAECgMIAwAAAA==.',['如果']='如果炣以:BAABKgAFFH8IAAIGAAIIRhVZGgB+AAAGAAIIRhVZGgB+AAAAAA==.',['妮可']='妮可妮可:BAAAKgAECgYIDAABKgAECggIEQADAAAAAA==.',['姜汁']='姜汁美式:BAABKgAECn8VAAIVAAcI3RN+OQBgAQAVAAcI3RN+OQBgAQAAAA==.',['威廉']='威廉伯爵保姆:BAAAKgADCgQIBAAAAA==.威廉伯爵管家:BAAAKgAECggIEAAAAA==.',['婲飛']='婲飛婲满兲:BAAAKgAECgEIAQAAAA==.',['孤月']='孤月残心:BAAAKgAECgYIDwAAAA==.',['宋轶']='宋轶:BAAAKgAECggICAAAAA==.',['宝宝']='宝宝说心里苦:BAAAKgADCggIEgAAAA==.',['宠爱']='宠爱有佳:BAAAKgADCgQIBAAAAA==.',['寒春']='寒春风曲:BAAAKgAFFAYIAQAAAA==.',['寳唄']='寳唄滴寳:BAAAKgADCgYIBgAAAA==.',['小九']='小九:BAAAKgAFFAIIAgAAAA==.',['小头']='小头:BAABKgAECn8WAAMGAAgIhBFUIgBlAQAGAAgIhBFUIgBlAQAHAAcIuQPhfAB1AAAAAA==.',['小小']='小小帅种子:BAAAKgAECgUICgAAAA==.',['小屁']='小屁呆:BAAAKgAFFAIIAgAAAA==.',['小幸']='小幸运丷:BAAAKgAECggIDQAAAA==.',['小德']='小德快跑:BAAAKgAECgIIAgAAAA==.',['小猪']='小猪的怜悯:BAAAKgADCgEIAQAAAA==.',['小胖']='小胖孩儿丶:BAAAKgADCggICgAAAA==.小胖达:BAABKgAECn8aAAISAAcIdhsrRABhAQASAAcIdhsrRABhAQAAAA==.',['少个']='少个远程:BAAAKgAECggICQAAAA==.',['尛天']='尛天真:BAAAKgAECgUIBQAAAA==.',['尛龙']='尛龙香:BAAAKgAECgYICQAAAA==.',['巴基']='巴基大狂疯:BAAAKgAFFAYIBAAAAA==.',['帕朵']='帕朵菲莉丝:BAABKgAFFH8GAAIIAAYIIg2HDgBoAQAIAAYIIg2HDgBoAQAAAA==.',['幸福']='幸福的大白菜:BAAAKgAFFAIIBAAAAA==.幸福的小白菜:BAAAKgAECgIIAgAAAA==.幸福的豆包:BAAAKgAECgcIBwAAAA==.',['库洛']='库洛姆丶骷髅:BAAAKgAFFAQIBAAAAA==.',['康师']='康师傅丶黑茶:BAAAKgAECgYIEgAAAA==.',['弹道']='弹道亦是道:BAABKgAECn9AAAMeAAgIThggEgD1AQAeAAgIThggEgD1AQALAAYITAqAZQDcAAAAAA==.',['影子']='影子厶念:BAAAKgAECgEIAQAAAA==.',['德克']='德克撒斯:BAAAKgAECggIDQAAAA==.',['德艺']='德艺双馨:BAABKgAFFH8JAAICAAMIDAskEQCNAAACAAMIDAskEQCNAAAAAA==.',['心忆']='心忆黯然:BAAAKgADCggIEQAAAA==.',['心灵']='心灵痛啊痛:BAAAKgAECgMIAwAAAA==.',['恶梦']='恶梦猎手:BAAAKgAFFAQIBAAAAA==.',['惊悚']='惊悚王:BAAAKgADCgIIAgAAAA==.',['想要']='想要魔法披风:BAAAKgADCggICAAAAA==.',['成功']='成功入水:BAAAKgAFFAQIBAAAAA==.',['我是']='我是小段:BAABKgAFFH8GAAIQAAYIrBj3EgBeAQAQAAYIrBj3EgBeAQAAAA==.',['我的']='我的刀呢:BAABKgAFFH8GAAIGAAYIZAbnDQDYAAAGAAYIZAbnDQDYAAAAAA==.',['我考']='我考不会吧:BAAAKgAECggIEAAAAA==.',['把你']='把你鼠標拿開:BAAAKgAFFAQIBAAAAA==.',['摩根']='摩根士丹利:BAAAKgAECgEIAQAAAA==.',['改名']='改名字的熊猫:BAAAKgAECgQIBgAAAA==.',['放開']='放開那釹孩:BAABKgAFFH8QAAIQAAYIRhYvEgBlAQAQAAYIRhYvEgBlAQAAAA==.',['无数']='无数个小提莫:BAAAKgADCgEIAQAAAA==.',['无铭']='无铭:BAABKgAECn8ZAAILAAUISgmCeQCfAAALAAUISgmCeQCfAAAAAA==.',['明茉']='明茉:BAAAKgAECgcIBwAAAA==.',['是牛']='是牛不是熊:BAABKgAECn8VAAIZAAUIhgtpLQCDAAAZAAUIhgtpLQCDAAAAAA==.',['是非']='是非良人:BAAAKgAECggIDgAAAA==.',['暴雨']='暴雨:BAABKgAECn8hAAIKAAgIiQyUWgAvAQAKAAgIiQyUWgAvAQAAAA==.',['最醒']='最醒醒人:BAAAKgAFFAYIAwABKgAFFAgIBAADAAAAAA==.',['杂猎']='杂猎:BAAAKgAFFAYIBAABKgAFFAgIBgAPAKsLAA==.',['李溪']='李溪儿:BAAAKgAECgUIBQAAAA==.',['来头']='来头熊猫压惊:BAAAKgAECgEIAQAAAA==.',['林依']='林依一:BAABKgAECn8XAAMJAAgIcxJRGwB1AQAJAAgIcxJRGwB1AQAfAAEI2wbCOAAqAAAAAA==.林依依:BAABKgAECn8cAAMGAAgIIiNOBgCmAgAGAAgIIiNOBgCmAgAHAAgICh+sGQBqAgAAAA==.',['果子']='果子狸的复仇:BAAAKgAECgYICwAAAA==.',['枫炎']='枫炎风羽:BAAAKgAECgIIAgAAAA==.',['柏芝']='柏芝:BAAAKgADCgQIBAAAAA==.',['样彩']='样彩:BAAAKgAECgEIAQAAAA==.',['榴莲']='榴莲千层:BAABKgAECn8XAAISAAgIXhkDNADhAQASAAgIXhkDNADhAQAAAA==.',['橙色']='橙色风暴:BAAAKgAECgIIAgAAAA==.',['武器']='武器战仕:BAAAKgAECggIEQAAAA==.',['死丸']='死丸之翼:BAAAKgAECgcIEgAAAA==.',['死者']='死者意志:BAABKgAECn8WAAMSAAgI3SDbEQCXAgASAAgI3SDbEQCXAgAJAAcIRQn+MQDFAAAAAA==.',['死鱼']='死鱼越梦海:BAAAKgAFFAgIAgAAAA==.',['残乂']='残乂翼:BAAAKgAECggICAAAAA==.',['毁灭']='毁灭术:BAAAKgAECggICAAAAA==.',['比奇']='比奇堡派大星:BAAAKgAECgYIBgAAAA==.',['毛茸']='毛茸毛茸:BAABKgAFFH8OAAIVAAYIGx79CACeAQAVAAYIGx79CACeAQAAAA==.',['水悟']='水悟空城:BAAAKgAECgUIBQAAAA==.',['求你']='求你别塞冰块:BAAAKgAECgUIBQAAAA==.',['沃克']='沃克玛大主教:BAABKgAFFH8OAAINAAgIgxEXDQD+AQANAAgIgxEXDQD+AQAAAA==.',['沙星']='沙星飞:BAAAKgAECgEIAQAAAA==.',['泄露']='泄露天鸡:BAAAKgAFFAIIAgAAAA==.',['法神']='法神之尊:BAABKgAFFH8GAAIRAAYIxxugAwC+AQARAAYIxxugAwC+AQAAAA==.',['泪模']='泪模糊了眼:BAAAKgAECggICAAAAA==.',['洛丹']='洛丹伦:BAAAKgAECggICQAAAA==.',['洛洛']='洛洛宝贝:BAAAKgAECgEIAQAAAA==.',['浴血']='浴血奋戦:BAABKgAFFH8GAAIcAAMIYgr9EwDJAAAcAAMIYgr9EwDJAAAAAA==.',['淡紫']='淡紫宝贝:BAAAKgAECgEIAQAAAA==.',['游天']='游天刃:BAAAKgAFFAgIBAAAAA==.',['滴溜']='滴溜溜:BAAAKgAECgMIAwAAAA==.',['滿月']='滿月小麥子:BAACKgAFFH8HAAIKAAYINwe4EQDtAAAKAAYINwe4EQDtAAAqAAQKfxkAAgoACAj7ESA9AIEBAAoACAj7ESA9AIEBAAAA.',['漫步']='漫步者天下:BAAAKgAECgYIDAAAAA==.',['漫随']='漫随天外云:BAAAKgADCggIEAAAAA==.',['潘朵']='潘朵瘌:BAAAKgAFFAMIAwAAAA==.',['潘爷']='潘爷:BAABKgAFFH8KAAILAAYI8xUtFQBaAQALAAYI8xUtFQBaAQAAAA==.',['灀之']='灀之哀伤:BAAAKgAECgIIAgAAAA==.',['灭龙']='灭龙:BAAAKgAECgcIDwAAAA==.',['热情']='热情随雨:BAABKgAECn8+AAMIAAgITiC5BwCLAgAIAAgITiC5BwCLAgAgAAYIXA8jEQDrAAABKgAFFAgIBQAIAEkOAA==.',['無賴']='無賴熱血:BAABKgAFFH8IAAIHAAgIxheoCgDeAQAHAAgIxheoCgDeAQAAAA==.',['熊猫']='熊猫创可贴:BAAAKgAECgYIEQAAAA==.',['爆少']='爆少爷:BAAAKgAECgYIBgAAAA==.',['牛哄']='牛哄:BAAAKgAECggICAAAAA==.',['牛壮']='牛壮壮丶:BAAAKgAFFAQIBAAAAA==.',['特香']='特香包:BAAAKgAFFAQIBAAAAA==.',['狐狸']='狐狸精:BAAAKgADCgUIBQAAAA==.',['狸花']='狸花猫:BAAAKgAFFAIIAgAAAA==.',['狼里']='狼里个浪:BAAAKgAECgcICgAAAA==.',['猫不']='猫不会微笑:BAABKgAFFH8MAAIRAAMIcxZbCQDjAAARAAMIcxZbCQDjAAAAAA==.',['猫朵']='猫朵朵:BAAAKgAECgUIBQAAAA==.',['猫猫']='猫猫祟祟:BAAAKgAECgEIAQAAAA==.',['玄灵']='玄灵萨:BAAAKgADCgMIAwAAAA==.',['王中']='王中王:BAACKgAFFH8QAAIQAAMIXRNfMADKAAAQAAMIXRNfMADKAAAqAAQKfxkAAhAACAgPE+dJAIIBABAACAgPE+dJAIIBAAAA.',['珊莳']='珊莳鎏蒂:BAAAKgADCggIDAAAAA==.',['琉璃']='琉璃粉兔:BAAAKgADCgQIBAAAAA==.',['瑞淇']='瑞淇曼:BAABKgAECn9AAAQUAAgIfiVoBADAAgAUAAgI5SRoBADAAgAPAAgI9SFIEABHAgAhAAIIKRB9TwBvAAAAAA==.',['甜心']='甜心小羊:BAAAKgADCggICAAAAA==.',['申花']='申花老乱:BAAAKgAECgYIBgAAAA==.',['电之']='电之殇:BAAAKgAECgQIBgAAAA==.',['男人']='男人多威武:BAAAKgAECggICAAAAA==.',['疯花']='疯花血月:BAAAKgADCgIIAgAAAA==.',['痕迹']='痕迹蜀黍:BAAAKgADCgYIBgAAAA==.',['白魔']='白魔女:BAACKgAFFH8OAAMhAAMIcgYYIACKAAAhAAMIcgYYIACKAAAPAAII4gKYOwBQAAAqAAQKfxUAAyEACAjGC+c6ANMAACEABwgTCec6ANMAAA8ABwieCdtrAJoAAAAA.',['盛夏']='盛夏之茉:BAAAKgAECggIDwAAAA==.盛夏有晴空:BAAAKgAECgYIBgAAAA==.',['破补']='破补丁:BAAAKgAECggIBAAAAA==.',['祈祷']='祈祷的圣翼:BAAAKgADCggICAAAAA==.',['祸害']='祸害联盟二号:BAABKgAFFH8MAAIKAAQIgR87CgAGAQAKAAQIgR87CgAGAQAAAA==.',['秋月']='秋月寒刀:BAABKgAFFH8HAAIWAAMI5RTbJQDKAAAWAAMI5RTbJQDKAAAAAA==.',['秋窗']='秋窗风雨夕:BAACKgAFFH8FAAIhAAIIuRDJHQB8AAAhAAIIuRDJHQB8AAAqAAQKfxsAAyEACAhvGOwdAOcBACEACAhvGOwdAOcBABQAAgjNH9pVAMIAAAAA.',['秦叔']='秦叔宝:BAAAKgAECggICAAAAA==.',['笨拙']='笨拙的罗雷雷:BAABKgAECn8aAAIPAAgIsR7bDQCrAQAPAAgIsR7bDQCrAQAAAA==.',['箭无']='箭无虚发:BAAAKgAECggICAAAAA==.',['米米']='米米耳聋:BAAAKgAECgMIAwAAAA==.',['粉中']='粉中粉:BAAAKgAFFAQIAwAAAA==.',['红色']='红色彼岸花:BAAAKgAECgIIAgAAAA==.',['纯情']='纯情蟑螂:BAAAKgAECgYICQAAAA==.',['细雨']='细雨无声:BAAAKgAECgYIBwAAAA==.',['织梦']='织梦人:BAABKgAFFH8kAAIKAAYIFhLPCwA+AQAKAAYIFhLPCwA+AQAAAA==.',['绯红']='绯红之歌:BAABKgAFFH8GAAIPAAYIRg2DEAAuAQAPAAYIRg2DEAAuAQAAAA==.',['维鲁']='维鲁:BAACKgAFFH8GAAINAAMICBXXIgDcAAANAAMICBXXIgDcAAAqAAQKfxgAAw0ACAikFFNxAHMBAA0ABwieF1NxAHMBAAEAAQjIAlBiAAYAAAEqAAUUCAgIAAQAWAoA.',['绿竹']='绿竹猗猗:BAAAKgAFFAIIBAAAAA==.',['老婆']='老婆返咗郷下:BAABKgAFFH8iAAIQAAQIFyIpIQAHAQAQAAQIFyIpIQAHAQABKgAFFAgIDAAYAHMZAA==.',['老李']='老李的骑士:BAABKgAFFH8HAAMOAAYIsg5BCgAEAQAOAAUIjAtBCgAEAQANAAII+xRISQBiAAAAAA==.',['腊肠']='腊肠牛:BAAAKgADCgEIAQAAAA==.',['臨水']='臨水照花人:BAAAKgADCgUIBQAAAA==.',['舞月']='舞月小牛:BAAAKgAECggIDwAAAA==.',['艾瑞']='艾瑞斯血手:BAAAKgAECgQIBAAAAA==.',['艾莉']='艾莉丝:BAABKgAFFH8GAAIUAAMICAg+IgCbAAAUAAMICAg+IgCbAAAAAA==.艾莉丝光翼:BAAAKgAECgQIBAAAAA==.',['苏萌']='苏萌:BAAAKgAECgYIBgAAAA==.',['荔枝']='荔枝小源子:BAAAKgADCggICAAAAA==.',['荣耀']='荣耀兜兜:BAAAKgAECgcIEwAAAA==.',['莎莉']='莎莉娅:BAABKgAFFH8GAAIJAAMIKwNQEQBlAAAJAAMIKwNQEQBlAAAAAA==.',['菜花']='菜花横溢灬:BAAAKgAECggIEAAAAA==.',['菲拉']='菲拉:BAAAKgAECgUIBQAAAA==.',['萌你']='萌你一脸熊掌:BAACKgAFFH8MAAQCAAMIThPPHQC4AAACAAMIThPPHQC4AAAYAAEIEwFQZQAfAAAZAAEIIgD/EQAEAAAqAAQKfxsAAgIACAiwFdYbAOYBAAIACAiwFdYbAOYBAAAA.',['萌光']='萌光小蹄子:BAABKgAFFH8OAAMhAAYI1iDsAAD+AQAhAAYI1iDsAAD+AQAUAAII9A+EHgCDAAAAAA==.',['萨满']='萨满:BAABKgAFFH8GAAIKAAYIVAkHFwAmAQAKAAYIVAkHFwAmAQAAAA==.',['蓝宝']='蓝宝:BAAAKgAFFAYIBAAAAA==.',['蓝沢']='蓝沢润:BAAAKgAFFAgIBAAAAA==.',['蕾姆']='蕾姆:BAAAKgAECggIDwAAAA==.',['薇尔']='薇尔莉特:BAABKgAFFH8GAAMYAAQIhB5wLwDWAAAYAAQIhB5wLwDWAAACAAII+hU5FgCEAAAAAA==.',['蛋疼']='蛋疼的很:BAAAKgAECgEIAQAAAA==.',['蜜茶']='蜜茶:BAAAKgAECgIIAgAAAA==.',['血色']='血色蔷薇:BAAAKgADCggIEAAAAA==.',['衾影']='衾影无惭:BAAAKgADCggICAAAAA==.',['西装']='西装暴徒:BAAAKgAECgUICQAAAA==.',['诸神']='诸神的毁灭:BAAAKgADCggIDAAAAA==.',['谭雅']='谭雅羊羊:BAAAKgAECggIEQAAAA==.',['豆沙']='豆沙包:BAABKgAFFH8JAAMiAAUIPwihBQC7AAAiAAUIBwehBQC7AAAjAAQI0QerDwCiAAAAAA==.',['赖小']='赖小七:BAAAKgAECggIEAAAAA==.',['赛普']='赛普林:BAAAKgAECggICwAAAA==.',['赵云']='赵云:BAAAKgADCgYIBwAAAA==.',['超级']='超级大兲:BAAAKgAECgUICQAAAA==.超级奶牛:BAAAKgAECgIIAgAAAA==.',['越狱']='越狱丶:BAACKgAFFH8XAAMFAAQIJSLiBQAaAQAFAAQIJSLiBQAaAQAQAAIIgQyGPwBrAAAqAAQKfzgABAUACAjeIekKAIkCAAUACAjeIekKAIkCACQABAjbFAUTALgAABAAAgjmE6oAATgAAAAA.',['跳河']='跳河淹死的鱼:BAAAKgAFFAIIAgAAAA==.',['远处']='远处思念之意:BAAAKgAFFAMIBAAAAA==.',['迷之']='迷之射手:BAAAKgAFFAQIBAAAAA==.',['迷雾']='迷雾之道:BAABKgAFFH8HAAMVAAQI2yDSGwC/AAAVAAQI2yDSGwC/AAAjAAEIvQsAHQBHAAAAAA==.',['逍遥']='逍遥猪头:BAAAKgAECggIDAAAAA==.',['逗豆']='逗豆:BAABKgAFFH8MAAIVAAYIGxTMAgCiAQAVAAYIGxTMAgCiAQAAAA==.',['醉丶']='醉丶千觞:BAAAKgAECgcIBwAAAA==.醉丶可爱:BAABKgAFFH8KAAMFAAQIdBpOIwDiAAAFAAMIdBpOIwDiAAAQAAEIAADHZwAAAAAAAA==.醉丶妮妮:BAAAKgAFFAQIBAAAAA==.醉丶柴:BAAAKgAECgMIAwAAAA==.醉丶盛夏:BAAAKgAECgcICAAAAA==.醉丶萨萨:BAAAKgAECgQIBwAAAA==.醉丶骑:BAACKgAFFH8aAAINAAQINya3EAARAQANAAQINya3EAARAQAqAAQKfxUAAg0ACAjdGYxuALwBAA0ACAjdGYxuALwBAAAA.',['醉拳']='醉拳高手:BAACKgAFFH8JAAMjAAQIlw24GACkAAAjAAQIlw24GACkAAAiAAEI+wO1CgAqAAAqAAQKfxUABBUACAhXFt4rAKYBABUACAhXFt4rAKYBACIABQiWDbAbAJoAACMAAwigCS1oAGUAAAAA.',['野居']='野居大王:BAABKgAFFH8ZAAQMAAYIASLFBgAYAQAMAAUIOBfFBgAYAQALAAYIJh2dKgDDAAAeAAMIfQm4EwClAAAAAA==.',['野性']='野性呼唤:BAAAKgADCgMIAwAAAA==.',['野猪']='野猪大神:BAABKgAFFH8ZAAMUAAgIMhV4AwApAgAUAAgIMhV4AwApAgAhAAIIMBe/FQC2AAAAAA==.',['银杏']='银杏出墙:BAAAKgAECgcICgAAAA==.',['闲得']='闲得慌:BAAAKgAECgYIBgAAAA==.',['阿修']='阿修罗:BAABKgAFFH8FAAISAAMIGBHnEwDHAAASAAMIGBHnEwDHAAAAAA==.',['阿斯']='阿斯顿大蜜蜂:BAAAKgAFFAgIBAAAAA==.',['陈三']='陈三竖:BAAAKgAFFAIIAgAAAA==.',['陨落']='陨落圣光:BAAAKgAECgQIBwAAAA==.',['陪我']='陪我看日出:BAABKgAFFH8GAAINAAYI4xmrHwBxAQANAAYI4xmrHwBxAQAAAA==.',['隐姓']='隐姓埋名:BAAAKgAFFAQIBAAAAA==.',['隔壁']='隔壁小沈:BAABKgAECn8bAAQPAAgIBh/nDQBlAgAPAAgISx3nDQBlAgAUAAcIaCBGFAAjAgAhAAYIORnQLgBmAQABKgAFFAgIBwAPAM4fAA==.',['雪花']='雪花大地:BAABKgAECn8mAAIdAAgIbxisFADrAQAdAAgIbxisFADrAQAAAA==.',['雲天']='雲天:BAAAKgAECgUIBAAAAA==.',['零帧']='零帧起手氵:BAAAKgADCggICAAAAA==.',['雷霆']='雷霆斩:BAAAKgAECgEIAQAAAA==.',['青龙']='青龙卧雪:BAAAKgADCgIIAgAAAA==.',['静瑠']='静瑠:BAAAKgADCgMIAwAAAA==.',['静风']='静风止水:BAAAKgADCggICAAAAA==.',['非常']='非常爱唱歌:BAAAKgADCggICAAAAA==.',['顽强']='顽强的罗雷雷:BAAAKgAECgcIDgAAAA==.',['顾叶']='顾叶寒丶:BAAAKgAECgEIAQAAAA==.',['顾点']='顾点点:BAAAKgAECgQIBAAAAA==.',['風之']='風之天際:BAABKgAECn8fAAMQAAgIoxS7HgCDAQAQAAgIoxS7HgCDAQAFAAIImQ4mkgBWAAAAAA==.',['风地']='风地果趣:BAAAKgAECgcIDwAAAA==.',['风舞']='风舞:BAAAKgADCgUIBQABKgAFFAQIFQAFAGkXAA==.',['风间']='风间翼:BAAAKgAECggIEwAAAA==.',['风雪']='风雪莉莉丝:BAABKgAFFH8MAAINAAMITQb6MQCcAAANAAMITQb6MQCcAAAAAA==.',['风魔']='风魔狂人:BAAAKgAECggICAAAAA==.风魔翼:BAAAKgAECggICQAAAA==.',['飞花']='飞花入梦:BAAAKgAFFAIIAgAAAA==.',['飞高']='飞高点:BAAAKgAECgYIBgAAAA==.',['香米']='香米粑粑:BAAAKgADCgYIBgAAAA==.',['驼背']='驼背矮一半丶:BAAAKgAECgIIBAAAAA==.',['骆雨']='骆雨浅歆:BAAAKgAECgYIDwAAAA==.',['魂丶']='魂丶伤痕:BAAAKgADCggICAAAAA==.',['魑魅']='魑魅魍魉众生:BAAAKgADCggICAAAAA==.',['魔者']='魔者墨也:BAAAKgADCggICAAAAA==.',['鸡腿']='鸡腿消灭者:BAABKgAFFH8RAAMjAAYIRB8bAQDrAQAjAAYIRB8bAQDrAQAiAAYI2AZ3BQDOAAAAAA==.',['黑起']='黑起魔尊:BAAAKgADCggIDwAAAA==.',['龙卷']='龙卷:BAABKgAFFH8OAAMKAAYIRw3PEwA4AQAKAAYIRw3PEwA4AQATAAIIZRU0FACEAAABKgAFFAgICwAKAP4jAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end