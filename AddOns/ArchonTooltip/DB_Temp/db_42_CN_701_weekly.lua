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
 local lookup = {'Mage-Arcane','Paladin-Retribution','Druid-Balance','Druid-Restoration','DeathKnight-Blood','DeathKnight-Unholy','Paladin-Protection','Shaman-Restoration','Shaman-Elemental','Priest-Discipline','Unknown-Unknown','Hunter-BeastMastery','Hunter-Marksmanship','Priest-Holy','Warrior-Fury','DeathKnight-Frost','Monk-Brewmaster','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','Warrior-Arms','Druid-Feral','Druid-Guardian','Mage-Frost','Mage-Fire','DemonHunter-Havoc','DemonHunter-Vengeance','Warrior-Protection','Rogue-Assassination','Priest-Shadow','Evoker-Devastation','Paladin-Holy','Monk-Mistweaver','Hunter-Survival','Rogue-Subtlety',}; local provider = {region='CN',realm='普罗德摩',name='CN',type='weekly',zone=42,date='2025-08-08',data={An='Angelwings:BAAAKgAFFAgIBAAAAA==.Anyenan:BAAAKgADCgIIAgAAAA==.',Bi='Biubiubiu:BAABKgAFFH8FAAIBAAUISgbhEgD2AAABAAUISgbhEgD2AAAAAA==.',Bl='Blackthor:BAABKgAFFH8FAAICAAUIFAIMNACSAAACAAUIFAIMNACSAAAAAA==.Bloodseeker:BAACKgAFFH8QAAMDAAgIlB22BgBAAgADAAcIfyG2BgBAAgAEAAEIXAcUNgBDAAAqAAQKfxcAAgMACAhoGqc1ANIBAAMACAhoGqc1ANIBAAAA.',Dd='Ddxx:BAAAKgADCgIIAQAAAA==.',Dk='Dk:BAACKgAFFH8jAAIFAAUIHge3GgCBAAAFAAUIHge3GgCBAAAqAAQKfyoAAgUACAiMD1gtACYBAAUACAiMD1gtACYBAAAA.',Dy='Dylandk:BAABKgAFFH8SAAIGAAYIgRpECAC9AQAGAAYIgRpECAC9AQABKgAFFAgITQACABIjAA==.',Eu='Eusbio:BAAAKgAFFAMIBAAAAA==.',Fo='Forwhen:BAAAKgAECggIAQAAAA==.',Gr='Gry:BAAAKgAECgQIBAAAAA==.Gryphon:BAAAKgAECgUIBgAAAA==.',Gt='Gtol:BAAAKgAECgIIAgAAAA==.',Id='Idiotpaladin:BAABKgAFFH8GAAIHAAYIqAFmDgCZAAAHAAYIqAFmDgCZAAAAAA==.',Jo='Johnnybegood:BAAAKgAECgQIBAAAAA==.',Ka='Kathy:BAAAKgAECgQIBAAAAA==.',Kt='Ktv:BAABKgAFFH8JAAIIAAUIlA9yMgCwAAAIAAUIlA9yMgCwAAAAAA==.',Le='Letmedk:BAABKgAFFH8HAAIGAAQITxMOEwDOAAAGAAQITxMOEwDOAAAAAA==.Letmexd:BAAAKgAFFAYIAwAAAA==.',Li='Licceeccee:BAAAKgAECgIIAgAAAA==.',Lo='Lowo:BAABKgAECn84AAIJAAgIgiIDAwDCAgAJAAgIgiIDAwDCAgAAAA==.',Lu='Luchao:BAAAKgAECgUIBQAAAA==.',Ma='Manndala:BAABKgAFFH8GAAIKAAYIGgpHEAAgAQAKAAYIGgpHEAAgAQAAAA==.',Mm='Mmoonne:BAAAKgAECggIDQAAAA==.',Mo='Molisa:BAAAKgAECgQICQAAAA==.Mone:BAAAKgAECgIIAgABKgAECggIDQALAAAAAA==.',Ne='Neoo:BAAAKgADCgIIAgAAAA==.',Pi='Pippinsnout:BAAAKgAFFAIIAgAAAA==.',Pk='Pkoterevo:BAAAKgADCgEIAQAAAA==.',Pl='Playervnawno:BAAAKgAFFAIIAgAAAA==.Playerwurchl:BAAAKgAECgYICgAAAA==.',Pz='Pzh:BAAAKgADCgQIBAAAAA==.',Re='Reina:BAAAKgAECgIIAwAAAA==.',Sa='Saaber:BAABKgAFFH8HAAIHAAQIOAqyFABdAAAHAAQIOAqyFABdAAAAAA==.',Sh='Shadow:BAAAKgAECgcICQAAAA==.',Sp='Speed:BAAAKgAECgcIBwAAAA==.',Te='Teresa:BAABKgAECn8pAAMMAAgIoyCcNAAjAgAMAAgIGSCcNAAjAgANAAYIdB4WLQCvAQAAAA==.',Wo='Wowhh:BAAAKgAECgUIAQAAAA==.',Xx='Xxcc:BAAAKgAECgMIAwAAAA==.',Yc='Yctxl:BAAAKgAECgQIBAAAAA==.',Yi='Yian:BAAAKgAECgMIBAAAAA==.',['一一']='一一壹佰:BAAAKgAECgIIAgAAAA==.一一得伊:BAACKgAFFH8IAAIIAAYIPhkWDACHAQAIAAYIPhkWDACHAQAqAAQKfxkAAggACAgQIW4RAG4CAAgACAgQIW4RAG4CAAAA.一一泗:BAAAKgAECggIAwAAAA==.一一点点:BAACKgAFFH8HAAIOAAYIACGHBwCyAQAOAAYIACGHBwCyAQAqAAQKfxQAAg4ACAhRHEUSAD8CAA4ACAhRHEUSAD8CAAAA.一一的德:BAAAKgAECgEIAQAAAA==.',['一个']='一个小德:BAABKgAFFH8FAAIDAAMIkx3eJgD6AAADAAMIkx3eJgD6AAAAAA==.',['一品']='一品江南:BAAAKgAECgYIBgAAAA==.',['一嘀']='一嘀嘀:BAABKgAFFH8KAAMEAAgIEA7ACQBrAQAEAAcI3gzACQBrAQADAAEIrAuVWwBFAAAAAA==.',['一季']='一季花开:BAACKgAFFH8VAAICAAQIoAoJWwC7AAACAAQIoAoJWwC7AAAqAAQKfzYAAgIACAgdHt80AFECAAIACAgdHt80AFECAAAA.',['一抹']='一抹血色:BAAAKgAECgEIAQAAAA==.',['一生']='一生为你:BAAAKgAECgcIDAAAAA==.',['一米']='一米五七:BAAAKgADCggICgAAAA==.一米五八:BAABKgAFFH8HAAIKAAQIrh4ZCAAJAQAKAAQIrh4ZCAAJAQAAAA==.',['一粒']='一粒淡:BAAAKgADCgQIBAAAAA==.',['一薪']='一薪一亿:BAAAKgAECgcICAAAAA==.',['一路']='一路顺发旺:BAABKgAECn8UAAIPAAgI9w4MMgC7AQAPAAgI9w4MMgC7AQAAAA==.',['一颠']='一颠颠:BAABKgAFFH8hAAQGAAgIthp/BQBIAgAGAAgIEBp/BQBIAgAQAAQIyBwCAwDvAAAFAAIIDwFdNAArAAAAAA==.',['万古']='万古魔性:BAAAKgADCggIDAAAAA==.',['三分']='三分归元气:BAAAKgAFFAQIBAAAAA==.',['上去']='上去就躺:BAAAKgAECgMIAwAAAA==.',['不会']='不会汪汪:BAABKgAFFH8MAAMDAAQI7hwnGQDaAAADAAQI7hwnGQDaAAAEAAMI9SHiDQDBAAAAAA==.',['不动']='不动熊猫:BAACKgAFFH8lAAIRAAYIWhKVAwDDAAARAAYIWhKVAwDDAAAqAAQKfzEAAhEACAh7G/QHAPgBABEACAh7G/QHAPgBAAAA.不动神无:BAAAKgAECggICgAAAA==.',['不哭']='不哭丶站搓:BAAAKgAECgYIBgAAAA==.',['不多']='不多:BAAAKgAFFAEIAQAAAA==.',['不葙']='不葙:BAACKgAFFH8uAAQSAAgIHhY2CgDoAQASAAcI4RI2CgDoAQATAAQIRx2NCAD4AAAUAAEIpApWIAA/AAAqAAQKf00ABBIACAhMJDMTAFICABIACAjuHjMTAFICABMABgjdI3cjAG0BABQAAwiaHMkqAKsAAAAA.',['丛林']='丛林啊猫:BAAAKgAECgIIAwAAAA==.',['东晋']='东晋桥头堡:BAAAKgAECggICAAAAA==.',['丨丶']='丨丶殇:BAAAKgAFFAQIBAAAAA==.',['中老']='中老妇女偶像:BAAAKgAECgMIAwAAAA==.',['丿橋']='丿橋本侑菜灬:BAAAKgAECggICAAAAA==.',['乄壊']='乄壊壞乄灬繠:BAAAKgAFFAEIAQAAAA==.',['云啓']='云啓丶丨:BAAAKgAECgEIAQAAAA==.',['亡者']='亡者之手:BAAAKgAECgcIBwAAAA==.',['亦菲']='亦菲:BAAAKgAECgUIBQAAAA==.',['代课']='代课老师师:BAAAKgADCgIIAgAAAA==.',['优然']='优然自得:BAAAKgADCggICAAAAA==.',['伟瑞']='伟瑞固德:BAAAKgADCgMIAwAAAA==.',['佐手']='佐手倒影:BAABKgAECn8UAAMTAAgI7A8UIwB6AQATAAgI7A8UIwB6AQASAAUINgmsegCcAAAAAA==.',['作弊']='作弊成绩取消:BAAAKgADCgcIBwAAAA==.',['信仰']='信仰欠费:BAAAKgAECgEIAgAAAA==.',['偶蕾']='偶蕾蕾:BAAAKgAECgUICAAAAA==.',['傲视']='傲视天下:BAACKgAFFH8pAAIVAAYIEiUfBAAJAgAVAAYIEiUfBAAJAgAqAAQKfxsAAhUACAjmIKYJAIACABUACAjmIKYJAIACAAAA.',['元柳']='元柳斋丨重国:BAAAKgAFFAYIBAAAAA==.',['元素']='元素:BAACKgAFFH8oAAUWAAYIlhuBAgBSAQAWAAUIlhuBAgBSAQAXAAQI2BYtBQDJAAAEAAIIIRAnGAB6AAADAAEI2R2sMgBSAAAqAAQKfygABRcACAiVHfALAJwBAAMABwi4GJZDAKgBABcABwiCGfALAJwBABYABggvGhoVAD8BAAQAAwgUEF5bAKQAAAAA.',['光兄']='光兄:BAABKgAECn8XAAICAAcI4h35TwADAgACAAcI4h35TwADAgABKgAFFAgIEwAHAA0TAA==.',['光脚']='光脚:BAACKgAFFH8kAAIYAAgIxR3JAgDkAQAYAAgIxR3JAgDkAQAqAAQKfzoAAhgACAjdJC4IAMgCABgACAjdJC4IAMgCAAAA.',['兜兜']='兜兜里有糖:BAAAKgAECgQIBAAAAA==.',['六月']='六月雨:BAAAKgADCggICAAAAA==.',['兮希']='兮希曦惜夕:BAAAKgAECgEIAQAAAA==.',['兰帝']='兰帝子:BAAAKgAFFAYIBAAAAA==.',['冰与']='冰与火之歌:BAAAKgAECggICAAAAA==.',['冰泪']='冰泪:BAAAKgADCgcIBwAAAA==.',['冰狂']='冰狂猎:BAABKgAECn8UAAMNAAgIexGgHAA3AQAMAAcI2Ar+fgA5AQANAAcIChOgHAA3AQAAAA==.',['冰风']='冰风溪:BAAAKgAFFAYIAgAAAA==.',['刁炸']='刁炸天:BAAAKgAFFAMIAwAAAA==.',['划船']='划船不用桨:BAACKgAFFH8GAAIZAAYI5BiEAwDXAQAZAAYI5BiEAwDXAQAqAAQKfxQAAxgACAj9GloiAP4BABgACAj9GloiAP4BABkABAgCEcU0AJUAAAAA.',['劈色']='劈色特弄:BAABKgAECn8cAAMaAAgI7yNxCQDBAgAaAAgI7yNxCQDBAgAbAAMIABCfVwBpAAAAAA==.',['北北']='北北再临:BAAAKgAECggICQAAAA==.',['匪类']='匪类:BAAAKgAECgEIAQAAAA==.',['匿迹']='匿迹:BAABKgAFFH8RAAICAAMINiE1MgAgAQACAAMINiE1MgAgAQAAAA==.',['十年']='十年樱:BAAAKgADCggICAAAAA==.',['单玉']='单玉:BAABKgAECn8eAAICAAgICiQ0EwC+AgACAAgICiQ0EwC+AgAAAA==.',['卡其']='卡其的小布藕:BAACKgAFFH8tAAIcAAQIwRIBDACmAAAcAAQIwRIBDACmAAAqAAQKf2AAAhwACAjrF4cWAGMBABwACAjrF4cWAGMBAAAA.',['卢克']='卢克莱修:BAAAKgADCggICAAAAA==.',['原野']='原野上的风铃:BAABKgAFFH8GAAICAAYIwSDrEgDFAQACAAYIwSDrEgDFAQAAAA==.',['叮当']='叮当:BAAAKgADCgYIBgAAAA==.',['叶青']='叶青青:BAAAKgAECgYIBgAAAA==.',['司命']='司命:BAAAKgAFFAMIAwAAAA==.',['名字']='名字不太长:BAABKgAFFH8FAAICAAQI8A3RJwDTAAACAAQI8A3RJwDTAAAAAA==.',['向我']='向我看齐:BAABKgAFFH8IAAICAAQIpyF6IgDjAAACAAQIpyF6IgDjAAABKgAFFAgICAAdAP8VAA==.',['君宇']='君宇:BAAAKgAECgMIAwAAAA==.',['含剎']='含剎射影:BAAAKgAECgQIBAAAAA==.',['吴名']='吴名英雄:BAABKgAFFH8JAAICAAQI+heVHQDuAAACAAQI+heVHQDuAAAAAA==.',['吴泽']='吴泽宇:BAAAKgAECgQIBAAAAA==.',['吾有']='吾有素了:BAAAKgAFFAQIAgAAAA==.',['咔忙']='咔忙呗比:BAABKgAFFH8NAAQYAAQIliEkBQAIAQABAAMIhCG6GgAPAQAYAAQI8RskBQAIAQAZAAQIrhVBKACtAAAAAA==.',['哀木']='哀木涕劣人:BAAAKgAFFAIIAwAAAA==.',['啊信']='啊信:BAABKgAFFH8HAAIIAAMI2BH0LgC8AAAIAAMI2BH0LgC8AAAAAA==.',['啊对']='啊对对對:BAAAKgAECgYIBgAAAA==.',['喵喵']='喵喵蕾:BAAAKgAECgUIBwAAAA==.',['喵蕾']='喵蕾蕾喵:BAAAKgAECgEIAQAAAA==.',['嗜血']='嗜血魔皇:BAAAKgADCggIEAAAAA==.',['嘟嘟']='嘟嘟侠:BAAAKgAECgcIEgAAAA==.',['嘤嘤']='嘤嘤:BAAAKgADCggICAAAAA==.',['四顾']='四顾剑:BAAAKgADCggICQAAAA==.',['土豆']='土豆叮叮:BAAAKgAECgYIBgAAAA==.',['圣光']='圣光之触:BAACKgAFFH8mAAMOAAYIPA1yDwDEAAAOAAQI+BFyDwDEAAAKAAIIIgZsMQBHAAAqAAQKfysAAw4ACAglF/osAJIBAA4ACAi2FfosAJIBAAoABggTDh5IAPQAAAAA.圣光照亮涛:BAAAKgAFFAQIBAAAAA==.圣光的正义:BAABKgAECn8YAAICAAYImRuhbgB6AQACAAYImRuhbgB6AQAAAA==.圣光莉莉珂:BAAAKgAFFAQIBAAAAA==.',['圣所']='圣所:BAAAKgAFFAMIAwAAAA==.',['地狱']='地狱埃里克:BAAAKgAFFAQIBAAAAA==.',['堕落']='堕落灬兽狩:BAAAKgADCgIIAgAAAA==.堕落灬星辰:BAAAKgADCgEIAQAAAA==.堕落灬狂怒:BAAAKgADCgUIBQAAAA==.堕落灬聖光:BAAAKgAECgcIBwAAAA==.堕落灬霜焱:BAAAKgADCggIDwAAAA==.堕落灬風怒:BAAAKgAECgIIAgAAAA==.堕落灬魂焱:BAAAKgADCgEIAQAAAA==.',['填神']='填神下饭:BAAAKgAECggICAAAAA==.',['壹伍']='壹伍零壹:BAACKgAFFH8jAAIaAAQI+Bd3JgDdAAAaAAQI+Bd3JgDdAAAqAAQKfzIAAhoACAhtIaYUAIoCABoACAhtIaYUAIoCAAAA.',['壹支']='壹支穿云箭:BAAAKgAFFAMIAwAAAA==.',['夏亚']='夏亚:BAAAKgAECggIDwAAAA==.',['夏目']='夏目:BAAAKgAECgIIAgAAAA==.',['夜下']='夜下:BAAAKgAECgEIAQAAAA==.',['夜之']='夜之祈愿:BAAAKgAECgQIBAAAAA==.',['夜芷']='夜芷长弓:BAAAKgADCgYIBgAAAA==.',['夜衣']='夜衣:BAAAKgAECgYIBgAAAA==.',['大笑']='大笑红尘:BAAAKgAECgcICAAAAA==.',['大脸']='大脸猫爱吃鱼:BAABKgAFFH8LAAMSAAYIFBtREQCAAQASAAYIFBtREQCAAQATAAIIYgAVMwAsAAAAAA==.',['大逗']='大逗比:BAAAKgAECgIIAgAAAA==.',['大郎']='大郎该喝药啦:BAABKgAFFH8KAAIMAAgIFCAhBAByAgAMAAgIFCAhBAByAgAAAA==.',['天呐']='天呐你真高:BAAAKgAECgIIAgAAAA==.',['天涯']='天涯若比邻:BAAAKgADCgIIAgAAAA==.',['头上']='头上带点绿:BAACKgAFFH8wAAIaAAgInyGdBwAiAgAaAAgInyGdBwAiAgAqAAQKfy8AAhoACAiRJtIBABMDABoACAiRJtIBABMDAAAA.',['头发']='头发乱糟糟:BAAAKgAECgYIEAAAAA==.',['奕丶']='奕丶动天:BAAAKgAECgcICAAAAA==.',['奥丁']='奥丁斯:BAAAKgADCggICAAAAA==.',['奥卓']='奥卓卡尔:BAACKgAFFH8NAAIaAAIIgB/FJQCbAAAaAAIIgB/FJQCbAAAqAAQKfz4AAhoACAhJJPQHAM4CABoACAhJJPQHAM4CAAAA.',['奥萨']='奥萨利安:BAABKgAFFH8FAAIGAAMIJg0FFgC3AAAGAAMIJg0FFgC3AAAAAA==.',['女神']='女神的宝宝:BAACKgAFFH8tAAIEAAQItB2IFQD0AAAEAAQItB2IFQD0AAAqAAQKf2AAAgQACAiqHD4cAOMBAAQACAiqHD4cAOMBAAAA.',['奶大']='奶大力皮皮:BAAAKgAECggIDAAAAA==.',['她说']='她说箭不够狠:BAAAKgAFFAIIBAAAAA==.',['姐夫']='姐夫别这样:BAAAKgAECgEIAQAAAA==.',['威朗']='威朗普:BAABKgAECn8YAAIDAAgILBvnJwAjAgADAAgILBvnJwAjAgAAAA==.',['孤儿']='孤儿蛋:BAAAKgAECgYIBwAAAA==.',['寳吖']='寳吖頭:BAABKgAFFH8GAAIEAAYI+BO/CAB8AQAEAAYI+BO/CAB8AQAAAA==.',['寻梦']='寻梦人:BAAAKgAECgMIAwAAAA==.',['射一']='射一发:BAABKgAFFH8GAAINAAYIvAqEGgAZAQANAAYIvAqEGgAZAQAAAA==.',['射的']='射的你喊疼:BAAAKgADCgEIAQAAAA==.',['小天']='小天使:BAACKgAFFH8TAAMOAAQIkw5fKQCdAAAOAAQIkw5fKQCdAAAeAAEIAgFTNAAZAAAqAAQKfyIAAw4ACAjGHG4TACkCAA4ACAjGHG4TACkCAAoAAQiqEVyQADMAAAEqAAUUCAgLAB8ACwMA.',['小心']='小心你的鸟:BAAAKgAECggIDAAAAA==.',['小泽']='小泽又沐风:BAAAKgAECgcIBwAAAA==.',['小灵']='小灵龙:BAAAKgAECgMIAwAAAA==.',['小看']='小看天空:BAAAKgADCgQIBgAAAA==.',['小萝']='小萝莉:BAAAKgADCggICwAAAA==.',['小饭']='小饭团:BAAAKgAECgUICAAAAA==.',['尐吖']='尐吖頭:BAACKgAFFH8TAAMIAAYI/R6zCgCcAQAIAAYI/R6zCgCcAQAJAAIIUBHUHgCDAAAqAAQKfzoAAggACAgxHhgdACYCAAgACAgxHhgdACYCAAAA.',['尐寳']='尐寳灬筫:BAAAKgAECgUIBAAAAA==.',['尐寶']='尐寶寳:BAAAKgAECgYIBgAAAA==.',['尐灬']='尐灬菟筫:BAABKgAFFH8MAAICAAYIXx5qFAC5AQACAAYIXx5qFAC5AQABKgAFFAgICAACAFYNAA==.',['尐熊']='尐熊猫:BAAAKgADCgMIAwAAAA==.',['尛沫']='尛沫沫:BAAAKgAECgYIBAAAAA==.',['尛魅']='尛魅影:BAAAKgAECgQIBwAAAA==.',['尤娜']='尤娜娜:BAAAKgAFFAEIAQAAAA==.',['屠联']='屠联圣者:BAAAKgAECgYIBgAAAA==.',['左勾']='左勾拳右勾拳:BAAAKgAECggICQAAAA==.',['布偶']='布偶与花:BAAAKgADCgMIAwAAAA==.',['帕利']='帕利达:BAABKgAFFH8GAAIdAAYICAzwDgBiAQAdAAYICAzwDgBiAQAAAA==.',['平凡']='平凡萨:BAABKgAECn8XAAIIAAgI3g07XgAQAQAIAAgI3g07XgAQAQAAAA==.',['幽幽']='幽幽:BAAAKgADCgMIAwAAAA==.',['广汉']='广汉沙舵爷:BAABKgAECn8lAAIMAAgItRUZFgDTAQAMAAgItRUZFgDTAQAAAA==.',['应思']='应思雪:BAAAKgAECgMIAwAAAA==.',['康某']='康某北鼻:BAAAKgAECgMIAwAAAA==.',['御神']='御神光同在:BAACKgAFFH8oAAICAAQI2SMjGAAoAQACAAQI2SMjGAAoAQAqAAQKfz0AAgIACAgmJUwiAJECAAIACAgmJUwiAJECAAAA.',['微雨']='微雨笙寒:BAABKgAECn8WAAMOAAgIzhNpKgCBAQAOAAgIvxJpKgCBAQAKAAEIZQkjhwAfAAAAAA==.',['德撸']='德撸一:BAABKgAFFH8GAAIDAAYIlANSGADlAAADAAYIlANSGADlAAAAAA==.',['心如']='心如琉璃:BAABKgAFFH8IAAICAAUIUx8aCgAvAQACAAUIUx8aCgAvAQAAAA==.',['忍野']='忍野忍:BAAAKgADCggICAAAAA==.',['忠于']='忠于纯粹:BAACKgAFFH8KAAIZAAMI0w15HwDYAAAZAAMI0w15HwDYAAAqAAQKfycAAxkACAgFG1UiACYCABkACAgFG1UiACYCABgABAgaDN+MAHQAAAAA.',['念一']='念一丝丝微光:BAAAKgAECggICAAAAA==.',['怀梦']='怀梦星辰:BAAAKgAFFAMIAQAAAA==.',['怒风']='怒风早乙女:BAAAKgAECggIDgAAAA==.',['思诗']='思诗:BAAAKgADCgcICAAAAA==.',['性感']='性感小尾巴:BAAAKgAFFAYIBAAAAA==.',['恋香']='恋香惜遇:BAAAKgADCgcIBwAAAA==.',['恶魔']='恶魔小熊:BAABKgAECn8kAAQDAAgIIB55HABZAgADAAgIIB55HABZAgAEAAYIYyNyGQD5AQAXAAEIWQSfRwALAAAAAA==.恶魔狂牛:BAABKgAECn8sAAIPAAgIhRyNEQBQAgAPAAgIhRyNEQBQAgAAAA==.恶魔猎猎:BAAAKgAECgYIBgAAAA==.恶魔荣荣:BAAAKgAECgEIAQAAAA==.恶魔骑:BAABKgAECn8WAAICAAgINCA+DwBlAgACAAgINCA+DwBlAgAAAA==.',['悠凛']='悠凛:BAABKgAFFH8UAAIcAAQIuxRmCgC9AAAcAAQIuxRmCgC9AAABKgAFFAgICwAfAAsDAA==.',['想念']='想念燃烧:BAABKgAFFH8IAAIYAAMIYBrsEADbAAAYAAMIYBrsEADbAAAAAA==.',['愤怒']='愤怒的圣光:BAAAKgAFFAcIAwAAAA==.愤怒的大菜包:BAAAKgADCgUIBAAAAA==.愤怒的海棠:BAABKgAFFH8GAAINAAUI+giQFQC4AAANAAUI+giQFQC4AAAAAA==.',['我不']='我不是伟人:BAAAKgAFFAEIAQAAAA==.',['我会']='我会用魔法:BAAAKgADCggIEwAAAA==.',['我來']='我來劫財:BAACKgAFFH8KAAQYAAIIWgshJgBiAAAZAAIIYgZKNQBxAAAYAAIIRwshJgBiAAABAAEIyAFpCgAqAAAqAAQKfzYABBgACAiGGNAoANkBABgACAg+FtAoANkBAAEACAhNEuEzAH8BABkABwgjEvtDAHkBAAAA.',['我哪']='我哪晓得下雨:BAAAKgAFFAQIBAABKgAFFAYIBgAOAKIaAA==.',['我有']='我有欧洲梦:BAAAKgAECgYIBgABKgAFFAgIEAATAOAZAA==.',['我的']='我的温柔:BAAAKgAECgQIBAAAAA==.',['我要']='我要奉献:BAAAKgADCggICAAAAA==.',['戳锅']='戳锅漏:BAABKgAFFH8KAAIMAAYIJQ1gDgBGAQAMAAYIJQ1gDgBGAQAAAA==.',['戴林']='戴林:BAAAKgAFFAgIBAAAAA==.',['托纳']='托纳提乌:BAAAKgAECggICAAAAA==.',['抓个']='抓个德做宝宝:BAAAKgAECgEIAQAAAA==.',['抬手']='抬手三炮影压:BAAAKgAECggICAAAAA==.',['抽象']='抽象变态狂:BAAAKgAECgcIDgAAAA==.',['拔刀']='拔刀斋猪猪:BAAAKgAFFAgIBAAAAA==.',['掐死']='掐死你的温柔:BAAAKgAECgMIBQAAAA==.',['搞樂']='搞樂:BAABKgAFFH8IAAINAAgIWhKvBQAFAgANAAgIWhKvBQAFAgAAAA==.',['文阿']='文阿婧丶:BAACKgAFFH8UAAIIAAQIBwcLIACEAAAIAAQIBwcLIACEAAAqAAQKfysAAwgABAi+Dv0vAMIAAAgABAi+Dv0vAMIAAAkAAwgLA+5xAD8AAAAA.',['无情']='无情的大辫子:BAAAKgAECgQIBAAAAA==.',['无聊']='无聊德:BAACKgAFFH8MAAMDAAgIShaABwA0AgADAAgIShaABwA0AgAXAAMI2AMABwBdAAAqAAQKfyoAAxcACAhYGkIEABMCABcACAhYGkIEABMCAAMAAgj6BzJUADoAAAAA.无聊战:BAABKgAECn8XAAIcAAgI5hM2CgCYAQAcAAgI5hM2CgCYAQABKgAFFAgIDAADAEoWAA==.无聊牧:BAAAKgADCgEIAQAAAA==.无聊猎:BAACKgAFFH8PAAMMAAMI3B/EIgD+AAAMAAMI3B/EIgD+AAANAAIIkwrNIgBeAAAqAAQKfyAAAwwACAiBIrkNALYCAAwACAiBIrkNALYCAA0AAgh0F8h7AIcAAAEqAAUUCAgMAAMAShYA.无聊的死骑:BAAAKgADCgEIAQABKgAFFAgIDAADAEoWAA==.无聊萨:BAAAKgADCgEIAQAAAA==.无聊骑:BAACKgAFFH8oAAIHAAMI+x6IEAD/AAAHAAMI+x6IEAD/AAAqAAQKf14AAgcACAjnJO8DAMUCAAcACAjnJO8DAMUCAAEqAAUUCAgMAAMAShYA.',['无良']='无良毒奶:BAAAKgAECggICQAAAA==.',['明月']='明月小楼:BAAAKgAECgcICAAAAA==.明月邀约:BAAAKgAECgcIDQAAAA==.',['星眸']='星眸:BAABKgAFFH8HAAIYAAMIVAtMGgCrAAAYAAMIVAtMGgCrAAAAAA==.',['星诀']='星诀:BAAAKgAECgIIAgAAAA==.',['星辰']='星辰兔巴哥:BAABKgAECn8UAAMcAAgI9ALZOABgAAAcAAgIZgLZOABgAAAPAAMIkwKFewAyAAAAAA==.',['是吐']='是吐司呀:BAAAKgADCggICAAAAA==.',['晚上']='晚上不睡:BAABKgAFFH8KAAMNAAgIORfOEQBVAQANAAYIjBzOEQBVAQAMAAQI8wx3IAALAQAAAA==.',['普罗']='普罗提诺:BAABKgAFFH8PAAIgAAYIfBufAACwAQAgAAYIfBufAACwAQAAAA==.',['景元']='景元:BAAAKgAECgEIAQAAAA==.',['智剑']='智剑平八方:BAAAKgADCgYIBgAAAA==.',['暗电']='暗电花:BAAAKgADCggIDAAAAA==.暗电闪:BAAAKgAECgQIBAAAAA==.',['暮色']='暮色灬晨曦:BAAAKgAECggIDwAAAA==.',['暮雨']='暮雨菲菲:BAAAKgAFFAIIAgAAAA==.',['暴风']='暴风:BAABKgAECn8dAAMNAAgIkxuqHADtAQANAAgImxiqHADtAQAMAAgIlQ4QdQBVAQAAAA==.',['曾经']='曾经的萌德:BAAAKgAECggICAAAAA==.',['最爱']='最爱吐司边儿:BAAAKgAECgUICQAAAA==.',['月光']='月光下的血红:BAAAKgAECgcIBQAAAA==.',['月袭']='月袭人:BAAAKgAFFAgIBAAAAA==.',['有法']='有法可衣:BAAAKgAECgcIBwAAAA==.',['有点']='有点小傲娇:BAABKgAFFH8GAAIaAAYIeRkZDwCTAQAaAAYIeRkZDwCTAQAAAA==.',['有说']='有说法么:BAAAKgAECgEIAQAAAA==.',['杀手']='杀手达文西:BAAAKgAECggICAAAAA==.',['李小']='李小黑:BAAAKgAECgUIBwAAAA==.',['来一']='来一拳:BAABKgAFFH8OAAIhAAgIXBbTBQDuAQAhAAgIXBbTBQDuAQAAAA==.',['杰西']='杰西简:BAABKgAFFH8GAAIPAAYI/hwsCwCXAQAPAAYI/hwsCwCXAQABKgAFFAgIDAACAJIXAA==.',['東海']='東海路人乙:BAAAKgAECgYIBgAAAA==.',['柚子']='柚子柚子:BAAAKgADCgIIAgAAAA==.',['格子']='格子:BAACKgAFFH8QAAMIAAUIGRNOFQDKAAAIAAUIGRNOFQDKAAAJAAEIAAAyLQAAAAAqAAQKfyIAAwgACAiXG2clAPoBAAgACAiXG2clAPoBAAkAAwjsE95QALkAAAAA.',['格格']='格格巫:BAABKgAFFH8LAAICAAcI9ReNDQAeAQACAAcI9ReNDQAeAQAAAA==.',['格调']='格调灬:BAAAKgAECgYIBgAAAA==.',['格鐳']='格鐳瑪燍:BAACKgAFFH8RAAIPAAMIow9DIADTAAAPAAMIow9DIADTAAAqAAQKfzYAAg8ACAj1GBEbAPkBAA8ACAj1GBEbAPkBAAAA.',['桃源']='桃源里:BAAAKgADCggICAAAAA==.',['桑岚']='桑岚徳:BAAAKgAECgQIBAAAAA==.',['桑葚']='桑葚:BAACKgAFFH8oAAMKAAYItREOCwBlAQAKAAYItREOCwBlAQAOAAQI3hJtDQDPAAAqAAQKfykAAg4ACAhYIlcJAJICAA4ACAhYIlcJAJICAAAA.',['梦一']='梦一样自由:BAAAKgAECgMIAwAAAA==.',['梦之']='梦之守护者:BAAAKgADCggICAAAAA==.',['椰奶']='椰奶的眼泪:BAAAKgAFFAQIBAAAAA==.',['榴莲']='榴莲酥:BAAAKgADCgYIBgAAAA==.',['欢乐']='欢乐人身:BAAAKgAECggIDwAAAA==.',['正义']='正义的害虫:BAAAKgADCggICQAAAA==.',['武乄']='武乄僧:BAAAKgAECgMIAwAAAA==.',['武汉']='武汉欢欢:BAACKgAFFH8vAAIFAAgIwwosFAAAAQAFAAgIwwosFAAAAQAqAAQKfzAAAgUACAiCFGMeAJwBAAUACAiCFGMeAJwBAAAA.武汉歡歡:BAAAKgADCgEIAQAAAA==.',['殇烦']='殇烦:BAAAKgAFFAEIAQAAAA==.',['比利']='比利大魔王:BAAAKgAECgEIAQAAAA==.',['毛兄']='毛兄:BAAAKgAECgEIAQAAAA==.',['毛桃']='毛桃大仙:BAAAKgAECgQIBAAAAA==.',['气刃']='气刃兜割:BAAAKgAECgEIAQAAAA==.',['永夜']='永夜丶无眠:BAAAKgAECgUIBQAAAA==.',['求求']='求求你给点力:BAABKgAFFH8FAAIGAAMI+QHQRgCFAAAGAAMI+QHQRgCFAAAAAA==.',['没事']='没事去兜风:BAAAKgADCgMIAwAAAA==.',['沧桑']='沧桑男人:BAAAKgAECgUICwAAAA==.',['洒满']='洒满鸡丝:BAAAKgAECgIIAgAAAA==.',['洛克']='洛克丹莫:BAABKgAECn8mAAIJAAgIdgCNjgAUAAAJAAgIdgCNjgAUAAAAAA==.',['洛洛']='洛洛白:BAACKgAFFH80AAMSAAcIwBnZCADRAQASAAYITRjZCADRAQATAAMIxSPrCwDVAAAqAAQKf0gAAxIACAitJIMTAFACABIACAiCI4MTAFACABMABwg2I4IGAOwBAAAA.',['派大']='派大星真厉害:BAAAKgAFFAgIAgAAAA==.',['海边']='海边的卡卡:BAABKgAFFH8HAAIGAAQIDAmTFwCqAAAGAAQIDAmTFwCqAAAAAA==.',['淘气']='淘气小熊:BAACKgAFFH8pAAQZAAUIBCO/CgCLAQAZAAUIBCO/CgCLAQABAAMI6B29HAD/AAAYAAEIFhEWIwA1AAAqAAQKfzEABBkACAgmI24RAI8CABkACAgtIm4RAI8CAAEABAhoIiAzAIMBABgABAiFICBvALwAAAAA.',['溪清']='溪清:BAAAKgAECgEIAQAAAA==.',['瀧傲']='瀧傲天:BAAAKgAFFAQIAQAAAA==.',['灬呱']='灬呱呱灬:BAAAKgAFFAQIAwAAAA==.',['灭咩']='灭咩子:BAAAKgAECgQIBAAAAA==.',['灭尽']='灭尽一刀:BAAAKgADCgUIBQAAAA==.',['灭度']='灭度:BAAAKgADCggICAAAAA==.',['灰凉']='灰凉凉:BAAAKgAECggIDwAAAA==.',['灰常']='灰常荡:BAAAKgAECgYIDQAAAA==.',['灵梦']='灵梦讴歌:BAABKgAECn8UAAMGAAgI7RqPLgD5AQAGAAgIKxqPLgD5AQAFAAgI0wqIMwD/AAAAAA==.',['灵魂']='灵魂修行者:BAAAKgADCgMIAwAAAA==.',['焕醒']='焕醒神明:BAAAKgAFFAQIBAAAAA==.',['燃烧']='燃烧的鸡脖:BAAAKgAFFAgIAgAAAA==.',['爱之']='爱之仙儿:BAAAKgADCgMIAwAAAA==.爱之灵儿:BAAAKgADCggICAAAAA==.',['爱就']='爱就宅一起:BAAAKgADCggICAAAAA==.',['爱是']='爱是永恒:BAAAKgADCgYIBgAAAA==.',['牛糊']='牛糊螂:BAAAKgAECgcICAAAAA==.',['牛角']='牛角辣:BAAAKgAECggICQAAAA==.',['牛魔']='牛魔牛:BAAAKgAECgEIAQAAAA==.',['狂风']='狂风行者:BAAAKgAECgYIBwAAAA==.',['狂魔']='狂魔自尊:BAAAKgAECgQICAAAAA==.',['独上']='独上高楼:BAAAKgADCgUIBQAAAA==.',['独孤']='独孤肥天:BAABKgAFFH8GAAIIAAYIqxRPDwBfAQAIAAYIqxRPDwBfAQAAAA==.',['猪猪']='猪猪:BAAAKgADCgcIBwAAAA==.猪猪大屁屁:BAABKgAFFH8IAAMDAAgIKxwBCgD0AQADAAcIexoBCgD0AQAEAAEIgwMLNwA/AAAAAA==.',['猫猫']='猫猫嘴里的鱼:BAABKgAFFH8iAAMYAAYI/hrfAwC0AQAYAAYI/hrfAwC0AQABAAQIVA46GAC7AAABKgAFFAgICAAFACwLAA==.猫猫爱吃鱼:BAABKgAFFH8TAAMOAAgIKBxtBAD/AQAOAAcIUBttBAD/AQAeAAMIRxZmFQDQAAAAAA==.',['玄仙']='玄仙:BAAAKgAFFAYIBAABKgAFFAgIDQACAOEYAA==.',['王德']='王德锅:BAAAKgAECgYICgAAAA==.',['璇美']='璇美美:BAAAKgAECggIEQAAAA==.',['生命']='生命壹号:BAAAKgAECgUIBQAAAA==.',['疯狂']='疯狂小奶牛:BAABKgAFFH8IAAIIAAQIqw5kHQCSAAAIAAQIqw5kHQCSAAAAAA==.疯狂星期四:BAABKgAFFH8UAAMDAAQIIyHHKgDoAAADAAQIIyHHKgDoAAAEAAQIJhDeDADJAAABKgAFFAgIAgALAAAAAA==.',['癞葛']='癞葛宝:BAAAKgAECgMIAwAAAA==.',['白主']='白主教:BAAAKgAFFAMIAwAAAA==.',['白教']='白教主:BAAAKgAECgIIAgAAAA==.',['白骨']='白骨夫人:BAAAKgAECgUIBQAAAA==.',['盏茶']='盏茶浅抿:BAACKgAFFH8fAAMCAAgImBx8CAA7AgACAAgIShx8CAA7AgAHAAUIjhDoEgDkAAAqAAQKfysAAwIACAgAIPkyAFcCAAIACAgAIPkyAFcCAAcAAQgfBBdrAA4AAAAA.',['盐水']='盐水凤梨:BAACKgAFFH8YAAMNAAQIHiMtGwAUAQANAAQIHiMtGwAUAQAMAAII8R4jPACrAAAqAAQKf0MABA0ACAgjJWUEANYCAA0ACAgjJWUEANYCAAwAAQiOIzqvAGMAACIAAQgAAHAiAAAAAAAA.',['盖尔']='盖尔丶加朵:BAABKgAFFH8KAAMSAAYIchfbAQDOAQASAAYIchfbAQDOAQATAAEIAADhIgAAAAAAAA==.',['盲人']='盲人模橙:BAAAKgAECgQIBAAAAA==.',['相泽']='相泽南:BAAAKgAECgcIBwAAAA==.',['真无']='真无霜:BAACKgAFFH8MAAIMAAQIHyRUCwAoAQAMAAQIHyRUCwAoAQAqAAQKfxUAAwwACAhwI3IZAGgCAAwACAgFI3IZAGgCAA0ACAi5HhUVACgCAAAA.',['碧瞳']='碧瞳小妖:BAAAKgAECggICAAAAA==.',['祖师']='祖师尊:BAAAKgAECgQIBAAAAA==.',['禅院']='禅院丨织姬:BAABKgAFFH8NAAQKAAUIfR7MCwD2AAAKAAQItRjMCwD2AAAeAAQIHBJdEADdAAAOAAUIJxj3JwCiAAAAAA==.',['秀虎']='秀虎小分队:BAAAKgAECgYICAAAAA==.',['秃头']='秃头老宝贝:BAACKgAFFH8GAAIBAAYITA7SFQA1AQABAAYITA7SFQA1AQAqAAQKfykAAxkACAgJEIo6AKgBABkACAgJEIo6AKgBAAEAAQgYBTumABoAAAAA.',['秋叶']='秋叶:BAAAKgADCgYIBwABKgAFFAgICwAfAAsDAA==.',['秋风']='秋风之刃:BAACKgAFFH8sAAIOAAYIvxCCDgDJAAAOAAYIvxCCDgDJAAAqAAQKf0AAAg4ACAhjGnImAJoBAA4ACAhjGnImAJoBAAAA.',['穿越']='穿越六零年代:BAAAKgAECggICAAAAA==.',['米亚']='米亚:BAACKgAFFH8YAAIMAAUIlx9yEAB2AQAMAAUIlx9yEAB2AQAqAAQKfxUAAwwACAgYIQ81ACECAAwABwiPHg81ACECACIAAwj0GwARANwAAAAA.',['米瑞']='米瑞特之阻碍:BAACKgAFFH8jAAQSAAgImxf4EADiAAASAAYIiBb4EADiAAAUAAMIQhQwDQDLAAATAAMIQRoYEwCpAAAqAAQKfzoABBIACAiWJEkXADgCABIACAgPH0kXADgCABMABAhYJY4wACUBABQAAQhuDY9FADUAAAAA.',['絕鈑']='絕鈑灬壞壞:BAACKgAFFH8HAAIGAAIIeQsiKACEAAAGAAIIeQsiKACEAAAqAAQKfyUAAgYACAh3GSkrANABAAYACAh3GSkrANABAAAA.',['絮絮']='絮絮叨叨的旭:BAABKgAFFH8MAAMCAAQIsiATFAAHAQACAAQIsiATFAAHAQAgAAQIqwl0EgCtAAAAAA==.',['繁星']='繁星:BAAAKgAECgYIDAAAAA==.',['纯情']='纯情的狗公腰:BAABKgAECn8iAAMHAAgImxh7EgDtAQAHAAgIhxd7EgDtAQACAAUI6xA1DAGmAAAAAA==.纯情的鸡屁股:BAABKgAFFH8iAAIDAAcIjhOuFgBjAQADAAcIjhOuFgBjAQAAAA==.',['终末']='终末之箭:BAACKgAFFH8aAAMMAAQIix2bFAD7AAAMAAMItBqbFAD7AAANAAQIuBTRKgC/AAAqAAQKfywAAwwACAg6HaQwADECAAwACAg6HaQwADECAA0AAQjNDDKRACgAAAAA.',['给你']='给你套军体拳:BAAAKgAFFAEIAQAAAA==.',['老汉']='老汉一个:BAAAKgADCggIEAAAAA==.',['老衲']='老衲法号流氓:BAAAKgAECgQIBAAAAA==.老衲法号颓废:BAAAKgAECgIIAgAAAA==.',['肥四']='肥四:BAAAKgAECgQIBAAAAA==.',['肿小']='肿小喵:BAAAKgAECgcIBwAAAA==.',['胖头']='胖头陀:BAABKgAECn8ZAAIEAAYIVBHnOwD4AAAEAAYIVBHnOwD4AAAAAA==.',['胡陶']='胡陶立即死:BAAAKgADCgcIBwAAAA==.',['致命']='致命的大辫子:BAAAKgAECggICQAAAA==.',['色媚']='色媚:BAAAKgAFFAMIAwAAAA==.',['芙莉']='芙莉莲:BAABKgAFFH8KAAMBAAMI6xlZLwCnAAABAAMIHxBZLwCnAAAYAAII2x7YHgCPAAAAAA==.',['花小']='花小花:BAAAKgAECggICAAAAA==.',['花泽']='花泽香菜的碗:BAABKgAECn8aAAMIAAgIdgpeXAAqAQAIAAgIdgpeXAAqAQAJAAMIUguDWwCMAAAAAA==.',['苦行']='苦行僧猪猪:BAAAKgAFFAUIAQAAAA==.',['荣耀']='荣耀审判:BAAAKgAFFAMIAwAAAA==.荣耀属于部落:BAAAKgADCggIEAAAAA==.荣耀糯米饭:BAABKgAFFH8HAAIMAAcI3gYlDQBlAQAMAAcI3gYlDQBlAQAAAA==.',['荷鲁']='荷鲁斯:BAAAKgAECgIIAgAAAA==.',['菰灬']='菰灬黩:BAAAKgAFFAYIBAAAAA==.',['菰黩']='菰黩:BAAAKgAECgQIBAAAAA==.',['菲月']='菲月斯:BAAAKgADCgIIAgAAAA==.',['萌萌']='萌萌的术爸:BAAAKgAECgIIAgAAAA==.',['萧情']='萧情:BAAAKgAECgEIAQAAAA==.',['萨满']='萨满开嗜血:BAABKgAFFH8NAAIZAAgICx8xAwCCAgAZAAgICx8xAwCCAgAAAA==.',['葉青']='葉青青:BAAAKgAECggICAAAAA==.',['葫芦']='葫芦娃老九:BAAAKgAECggICAAAAA==.',['蒼龍']='蒼龍雲傲天:BAAAKgAFFAQIBAAAAA==.',['蓝色']='蓝色油腻奶瓶:BAACKgAFFH8KAAIIAAMImwdOPwCLAAAIAAMImwdOPwCLAAAqAAQKf0wAAwgACAhsDM1VAD4BAAgACAhsDM1VAD4BAAkAAQilBRyBABoAAAAA.',['蓝莓']='蓝莓:BAAAKgADCgEIAQAAAA==.',['蕾丷']='蕾丷蕾:BAAAKgAECggIEgAAAA==.',['薄荷']='薄荷喵:BAAAKgAECgYIBgAAAA==.',['薯片']='薯片:BAAAKgADCgYIBgAAAA==.',['虎牙']='虎牙:BAAAKgADCgEIAQAAAA==.',['虹口']='虹口碧罗:BAAAKgAECgYIBwAAAA==.',['血染']='血染的紅岭巾:BAABKgAFFH8IAAIaAAgIRgYXDACbAQAaAAgIRgYXDACbAQAAAA==.',['西猫']='西猫饱的夸:BAAAKgAFFAQIBAAAAA==.',['西逝']='西逝之秋:BAAAKgAECggICAAAAA==.',['謸呜']='謸呜:BAACKgAFFH8sAAISAAYI2xo5BgBBAQASAAYI2xo5BgBBAQAqAAQKfy4AAhIACAh+JUcEANoCABIACAh+JUcEANoCAAAA.',['讨厌']='讨厌科科:BAAAKgAECgYIBwAAAA==.',['诗思']='诗思:BAAAKgADCggIGAAAAA==.',['诗诗']='诗诗:BAAAKgADCggICAAAAA==.',['该丶']='该丶隐:BAABKgAECn8VAAIaAAgISQ4zSgB+AQAaAAgISQ4zSgB+AQAAAA==.',['请叫']='请叫我小凌乱:BAAAKgAECggICAAAAA==.',['豌豆']='豌豆苗苗:BAAAKgAECgcIEQAAAA==.',['貌似']='貌似纯洁:BAAAKgAECgcIEgAAAA==.',['贝斯']='贝斯特拉:BAABKgAFFH8MAAMgAAQIRhkVDgDSAAAgAAQIRhkVDgDSAAAHAAQIbRXjCQDFAAAAAA==.',['贫道']='贫道法号贼尼:BAACKgAFFH8JAAISAAMIpBOcEwDWAAASAAMIpBOcEwDWAAAqAAQKfyoAAxIACAg+H1kUAEoCABIACAj8HlkUAEoCABMABQgYHhoaAKoBAAAA.',['费纳']='费纳希雅:BAAAKgAFFAgIAgAAAA==.',['贾斯']='贾斯丁盾墙:BAABKgAFFH8QAAMPAAgIXh0aAwCKAgAPAAgIXh0aAwCKAgAVAAEIugMRGABTAAAAAA==.',['走在']='走在冷风中:BAAAKgADCgUIBQAAAA==.',['超硬']='超硬的文少爷:BAAAKgAFFAMIBAAAAA==.',['路边']='路边蹲只羊:BAAAKgAECgMIAwAAAA==.',['轻松']='轻松熊:BAABKgAECn8xAAMDAAgI6CCVEgCWAgADAAgI6CCVEgCWAgAEAAIIYxQaaQB7AAAAAA==.',['迎接']='迎接你们的光:BAABKgAFFH8IAAIEAAgIPQvDBQDCAQAEAAgIPQvDBQDCAQAAAA==.',['这一']='这一拳会上天:BAAAKgAFFAQIBAAAAA==.',['进口']='进口香蕉丶:BAABKgAFFH8GAAIZAAQIHgf+JADAAAAZAAQIHgf+JADAAAAAAA==.',['迪古']='迪古拉斯:BAABKgAECn8WAAICAAgIoiLLQQD8AQACAAgIoiLLQQD8AQAAAA==.',['追猎']='追猎冕下:BAAAKgADCgMIAwABKgAFFAQIAgALAAAAAA==.',['逝去']='逝去的年华:BAAAKgAECgcICwAAAA==.',['邪恶']='邪恶的益虫:BAAAKgAECgMIBQAAAA==.',['郁闷']='郁闷小恶:BAACKgAFFH8mAAIaAAQI5B+tHgAOAQAaAAQI5B+tHgAOAQAqAAQKfzAAAhoACAgfH24gAEICABoACAgfH24gAEICAAAA.郁闷小战:BAAAKgAECgQIDAAAAA==.郁闷小牧:BAAAKgAECgQIDgAAAA==.郁闷小阿:BAABKgAFFH8GAAIGAAMIRgYVHgBnAAAGAAMIRgYVHgBnAAAAAA==.郁闷小騎:BAAAKgAECgQICAAAAA==.',['酒劍']='酒劍:BAACKgAFFH8lAAMNAAQIPBqfLgCyAAANAAQICBafLgCyAAAMAAII/hzCPwCfAAAqAAQKfyYAAw0ACAjVIuwOAGACAA0ACAjVIuwOAGACAAwABAjwCoS/AKUAAAAA.',['醉之']='醉之狂刀:BAAAKgAECgUIBQAAAA==.',['野性']='野性怒火:BAAAKgADCgYIBgAAAA==.野性的暗夜:BAAAKgAECgcIDwAAAA==.',['野生']='野生:BAAAKgADCgYIBgAAAA==.野生女王:BAAAKgADCgQIBAAAAA==.野生花花:BAAAKgADCgYIBgAAAA==.',['钢兄']='钢兄:BAAAKgAFFAgIBAAAAA==.',['阿尔']='阿尔特亚斯:BAAAKgAECgQIBwAAAA==.阿尔迪莉娅:BAABKgAFFH8FAAIPAAUIPBsVEQBEAQAPAAUIPBsVEQBEAQAAAA==.',['阿布']='阿布:BAABKgAFFH8IAAISAAgIMxNpCAAIAgASAAgIMxNpCAAIAgAAAA==.',['阿立']='阿立与你同在:BAACKgAFFH8SAAMCAAgILiKGAAAXAgACAAgILiKGAAAXAgAHAAQI2A2tDQCZAAAqAAQKfxcAAgIACAhUIjUoAHwCAAIACAhUIjUoAHwCAAAA.',['随风']='随风领主:BAABKgAFFH8UAAIDAAYI5B+JDgCzAQADAAYI5B+JDgCzAQAAAA==.',['隔壁']='隔壁大叔:BAAAKgAECgUIBQAAAA==.',['雷神']='雷神乔帮主:BAAAKgAFFAEIAQAAAA==.',['须佐']='须佐丶之男:BAAAKgADCgcIBwAAAA==.',['顽皮']='顽皮的多多:BAABKgAECn8XAAIKAAgIDhoECQDFAQAKAAgIDhoECQDFAQAAAA==.',['风丶']='风丶泣:BAABKgAFFH8IAAIPAAgIRRldBABQAgAPAAgIRRldBABQAgAAAA==.',['风神']='风神半月:BAABKgAFFH8GAAICAAYI3iIDEgDNAQACAAYI3iIDEgDNAQAAAA==.',['飘逸']='飘逸随行者:BAAAKgAECgcICwAAAA==.',['飘飘']='飘飘:BAABKgAFFH8FAAITAAMIewg2CwCiAAATAAMIewg2CwCiAAAAAA==.',['飞侠']='飞侠:BAAAKgADCgUIBQAAAA==.',['飞天']='飞天鬼:BAAAKgADCgUIBQAAAA==.',['香炸']='香炸牧羊犬:BAABKgAFFH8FAAMdAAMItQyJDQDNAAAdAAMIMwuJDQDNAAAjAAII1gUpDgCCAAAAAA==.',['驳驳']='驳驳:BAABKgAFFH8IAAIVAAgIoAV3BQCVAQAVAAgIoAV3BQCVAQAAAA==.',['魂断']='魂断蓝桥:BAAAKgAECggICAAAAA==.',['鱼丸']='鱼丸:BAABKgAFFH8GAAMaAAQIbxgIFADwAAAaAAQIbxgIFADwAAAbAAEIAwbZGwAsAAAAAA==.',['鱼柳']='鱼柳柳:BAAAKgAECgYICAAAAA==.',['黑夜']='黑夜问白天:BAABKgAFFH8SAAMdAAYIyhHiDAB/AQAdAAYIyhHiDAB/AQAjAAEIAACcCgAAAAAAAA==.',['黯刃']='黯刃男爵巴尼:BAAAKgAFFAUIAQAAAA==.',['黯淡']='黯淡雪姬:BAABKgAFFH8GAAMSAAQIYAyyJgDXAAASAAMIAQ6yJgDXAAATAAEIfgdsLABCAAAAAA==.',['龍戰']='龍戰騎士:BAABKgAFFH8TAAICAAQI4RZIIQDjAAACAAQI4RZIIQDjAAAAAA==.',['龙之']='龙之舞嘶:BAAAKgADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end