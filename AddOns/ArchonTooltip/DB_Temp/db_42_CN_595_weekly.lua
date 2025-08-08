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
 local lookup = {'Monk-Mistweaver','Shaman-Elemental','Paladin-Protection','Warlock-Destruction','Mage-Fire','Mage-Frost','Mage-Arcane','Paladin-Retribution','Druid-Restoration','DeathKnight-Unholy','Priest-Holy','Warlock-Demonology','Warrior-Fury','Warrior-Protection','DemonHunter-Vengeance','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','DemonHunter-Havoc','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Monk-Windwalker','Druid-Balance','Paladin-Holy','Priest-Discipline','DeathKnight-Blood','Warlock-Affliction','Warrior-Arms','Unknown-Unknown','Priest-Shadow','Druid-Guardian','Evoker-Devastation','Hunter-Survival','Monk-Brewmaster',}; local provider = {region='CN',realm='勇士岛',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aape:BAAAKgAECggICAAAAA==.',Ac='Acuoz:BAAAKgADCgEIAgAAAA==.',Ad='Adios:BAAAKgADCggICAAAAA==.',Al='Alexluo:BAAAKgAFFAIIAgAAAA==.',Ar='Arden:BAAAKgAECggICAAAAA==.',As='Ashbringer:BAAAKgAECgEIAQAAAA==.',At='Atmanuntmd:BAAAKgAFFAgIAQAAAA==.',Ay='Ayse:BAAAKgAECgIIBQAAAA==.',Ch='Chichoo:BAAAKgADCggIDQAAAA==.',Cr='Crit:BAACKgAFFH8EAAIBAAQIFB/+CwD8AAABAAQIFB/+CwD8AAAqAAQKfxgAAgEACAj/IMoMAIUCAAEACAj/IMoMAIUCAAAA.',Da='Dart:BAAAKgAECgYIBgAAAA==.',De='Derpession:BAAAKgADCgEIAQAAAA==.',Dm='Dmal:BAAAKgAECgQIBAAAAA==.',Gr='Grill:BAAAKgAFFAQIBAAAAA==.',Ha='Hasana:BAAAKgAECgIIAgAAAA==.',Ja='Jaina:BAAAKgAFFAEIAQAAAA==.',Ka='Kamehameha:BAAAKgAECggICAAAAA==.',Kh='Khuntoria:BAACKgAFFH8lAAICAAgIACEJBADhAQACAAgIACEJBADhAQAqAAQKfzIAAgIACAiVJcoDAOcCAAIACAiVJcoDAOcCAAAA.',Ki='Killuakeeper:BAABKgAFFH8GAAIDAAYINg5jEQD2AAADAAYINg5jEQD2AAAAAA==.',Ky='Kyo:BAABKgAFFH8IAAIEAAgIohmgBABXAgAEAAgIohmgBABXAgAAAA==.',Ml='Mlss:BAABKgAFFH8qAAQFAAgIgB+dAgDyAQAFAAgIbh6dAgDyAQAGAAYIkh5NAwDNAQAHAAYItiQjCgDMAQAAAA==.Mlsslovee:BAABKgAFFH8NAAIFAAYIXRdTEABDAQAFAAYIXRdTEABDAQAAAA==.',Na='Nakyiou:BAAAKgAECgYICwAAAA==.',Pl='Playerkxsfto:BAAAKgAECgcICAAAAA==.',Rl='Rlyeh:BAAAKgAFFAUIAgAAAA==.',Si='Siky:BAABKgAECn8bAAIIAAgIBxtxFQAfAgAIAAgIBxtxFQAfAgAAAA==.',So='Sonder:BAAAKgAECggIAwAAAA==.Sosai:BAABKgAECn8YAAIJAAgIFRogFgATAgAJAAgIFRogFgATAgAAAA==.',St='Starlight:BAAAKgAECgEIAQAAAA==.',Su='Superorange:BAAAKgAECgYIBgAAAA==.',['一拳']='一拳一个小菜:BAABKgAFFH8QAAIKAAQIeQ6ZMwDHAAAKAAQIeQ6ZMwDHAAAAAA==.',['一直']='一直:BAAAKgAECgYIBwAAAA==.一直都还在:BAAAKgAFFAQIBAAAAA==.',['一翩']='一翩若惊鸿一:BAAAKgAECgcICwAAAA==.',['丄弑']='丄弑神者丄:BAABKgAFFH8GAAIKAAQI3RBqFADnAAAKAAQI3RBqFADnAAAAAA==.',['三十']='三十二号娶你:BAAAKgAECgMIAwAAAA==.',['三号']='三号小菜鸡:BAABKgAECn9VAAILAAgItSaWAAALAwALAAgItSaWAAALAwAAAA==.',['三条']='三条腿:BAAAKgAFFAIIBAAAAA==.',['上帝']='上帝的人:BAAAKgAECgYICAAAAA==.',['不擅']='不擅杀伐:BAAAKgAECgMIAwAAAA==.',['不朽']='不朽者:BAAAKgAECgEIAQAAAA==.',['不死']='不死神术:BAABKgAECn8VAAMMAAgIfRRYJwBiAQAMAAgIfRRYJwBiAQAEAAUI1gwAcQC4AAAAAA==.',['不知']='不知冬:BAACKgAFFH8JAAIIAAMIiQR1NQCMAAAIAAMIiQR1NQCMAAAqAAQKfxoAAggABwgHEywzAEQBAAgABwgHEywzAEQBAAAA.',['不約']='不約兒童丶:BAAAKgAECgcIBQAAAA==.',['专业']='专业开颅:BAAAKgADCggICAAAAA==.',['东星']='东星骆驼:BAABKgAECn8TAAMNAAgI5B5cHwAdAgANAAcIJCBcHwAdAgAOAAgIUQo2IgDxAAAAAA==.',['丨一']='丨一哥丨:BAABKgAFFH8LAAIPAAMIVARkHgBqAAAPAAMIVARkHgBqAAAAAA==.',['丨时']='丨时雨落枫丨:BAABKgAECn8WAAQQAAgIQw9/CQAbAQAQAAcIFg5/CQAbAQARAAUIKg1xGQB2AAASAAEIAAAyFAAAAAAAAA==.',['丶时']='丶时雨落枫丶:BAABKgAECn8UAAITAAgIXRfpJADiAQATAAgIXRfpJADiAQAAAA==.',['丶獵']='丶獵:BAAAKgAECgIIAgAAAA==.',['丷刺']='丷刺客的忧伤:BAAAKgAFFAQIBAAAAA==.',['丷大']='丷大柚呢:BAAAKgAFFAQIBAAAAA==.',['丷无']='丷无尽寒冬:BAAAKgADCgQIBQAAAA==.',['丷时']='丷时光如瑾:BAAAKgAFFAYIBAAAAA==.',['丷柚']='丷柚呢:BAABKgAFFH8GAAIUAAYIRR+6CQDBAQAUAAYIRR+6CQDBAQABKgAFFAgIBgAJAHcTAA==.',['丷洛']='丷洛丹伦之泪:BAABKgAFFH8GAAIIAAYIbRFCIABvAQAIAAYIbRFCIABvAQAAAA==.',['为了']='为了联盟灬:BAACKgAFFH8dAAMVAAYI2BogAwBHAQAVAAYI2BogAwBHAQAUAAMIGwxyOgCxAAAqAAQKfyMAAxQACAifIOgsAPkBABQACAjNH+gsAPkBABUABgjdFxFAAFIBAAAA.',['乌瑟']='乌瑟尔丶焰须:BAAAKgADCggICAAAAA==.',['乔大']='乔大爷:BAAAKgAECgQICQAAAA==.',['九児']='九児:BAAAKgADCgMIAwAAAA==.',['九士']='九士衞:BAAAKgADCgMIAwAAAA==.',['九天']='九天丶:BAABKgAFFH8IAAMUAAQIZxTnFgD0AAAUAAQIZxTnFgD0AAAVAAQIKgyiEwDDAAAAAA==.',['九幽']='九幽之主:BAAAKgAECgQIBQAAAA==.',['九徳']='九徳嶽:BAAAKgADCgYIBgAAAA==.',['九牛']='九牛:BAAAKgADCgIIAgAAAA==.',['也非']='也非也:BAABKgAECn8YAAMVAAgIYQv5RgACAQAUAAcIsAziggAuAQAVAAgIhAb5RgACAQAAAA==.',['二三']='二三四五六:BAAAKgAECgEIAwAAAA==.',['亲爱']='亲爱的时光:BAAAKgAECggICQAAAA==.',['亿之']='亿之水月:BAABKgAECn9FAAIWAAgIjBY0GAB1AQAWAAgIjBY0GAB1AQAAAA==.',['仙贝']='仙贝丶:BAAAKgADCgYIBgAAAA==.',['伊姆']='伊姆什霍格:BAAAKgAECgUIBQAAAA==.',['伊库']='伊库伊库:BAAAKgAFFAMIAwAAAA==.',['似云']='似云似雾:BAAAKgADCgIIAgAAAA==.',['佐佐']='佐佐慕曦:BAAAKgAECgEIAQAAAA==.',['信用']='信用卡:BAAAKgADCggICAAAAA==.',['倚长']='倚长剑凌清秋:BAAAKgADCgEIAQAAAA==.',['借网']='借网贷去推由:BAAAKgAFFAIIAgAAAA==.',['傲天']='傲天大兵:BAABKgAFFH8HAAMUAAMI2ww3HAC4AAAUAAMI2ww3HAC4AAAVAAEIvwUhVAAwAAAAAA==.',['兰蒂']='兰蒂斯之长云:BAAAKgAECggIDwAAAA==.',['关云']='关云长:BAAAKgAFFAQIAgAAAA==.',['再入']='再入深渊:BAABKgAECn8VAAMBAAgIUBpNEgAFAgABAAgIUBpNEgAFAgAXAAMILRSLRQC0AAAAAA==.',['冷心']='冷心丶疯子:BAAAKgADCggICAAAAA==.',['凉米']='凉米线:BAAAKgADCgcIBwAAAA==.',['凌乱']='凌乱的人生:BAAAKgAECgQIBAAAAA==.',['凌音']='凌音丶:BAAAKgAECgQIBAAAAA==.',['别哔']='别哔哔:BAABKgAFFH8FAAIIAAQIzRBNIQDmAAAIAAQIzRBNIQDmAAAAAA==.',['别看']='别看我在飘:BAABKgAFFH8HAAIYAAQIpRvILwDVAAAYAAQIpRvILwDVAAAAAA==.',['别进']='别进去:BAAAKgAECgMIAwAAAA==.',['刹那']='刹那芳华逝:BAAAKgAFFAIIAgAAAA==.',['割肉']='割肉大师:BAABKgAFFH8IAAIPAAMIwAOPHgBpAAAPAAMIwAOPHgBpAAAAAA==.',['力个']='力个表:BAAAKgAECgMIAwAAAA==.',['加尔']='加尔泰里奥:BAAAKgAECgQIBAAAAA==.',['十八']='十八岁半:BAAAKgADCggICAAAAA==.',['十火']='十火十:BAAAKgAECgQIBAAAAA==.',['升龙']='升龙拳:BAAAKgADCgQIBAAAAA==.',['南寒']='南寒:BAAAKgAFFAYIAwAAAA==.',['南帝']='南帝丶:BAAAKgADCgYICQAAAA==.',['卡卡']='卡卡盲豆:BAAAKgADCgYIBgAAAA==.',['卢饮']='卢饮溪:BAABKgAFFH8MAAMVAAYIGiM4AAD+AQAVAAYIGiM4AAD+AQAUAAII1hGGRgCIAAAAAA==.',['受人']='受人尊敬的哥:BAAAKgAECgUIBQAAAA==.受人爱戴小弟:BAAAKgAECgUIBQAAAA==.',['变形']='变形乆乆:BAAAKgAFFAYIAgAAAA==.',['只抽']='只抽华子:BAAAKgAECgQIBAAAAA==.',['只需']='只需等待:BAAAKgADCggICAAAAA==.',['可大']='可大可小:BAABKgAFFH8IAAIJAAgIdRZPAwAWAgAJAAgIdRZPAwAWAgAAAA==.',['可完']='可完事了:BAABKgAFFH8IAAIHAAgIOQ2ICADyAQAHAAgIOQ2ICADyAQAAAA==.',['台台']='台台子怒海:BAAAKgAECgYIBgAAAA==.',['史蒂']='史蒂芬霍津:BAAAKgAFFAMIAwAAAA==.',['叶子']='叶子丶:BAAAKgAECgQIBQAAAA==.',['吴老']='吴老爷:BAAAKgAECgIIAgAAAA==.',['吴颜']='吴颜祖丶:BAAAKgAECgEIAQAAAA==.',['吹毛']='吹毛求毛:BAABKgAFFH8QAAMFAAgI7Ai9CAByAQAFAAgIjgi9CAByAQAGAAIIwwsAAAAAAAAAAA==.',['吾乃']='吾乃戰神:BAAAKgAECgUIBwAAAA==.',['周肥']='周肥錀:BAAAKgAECgYIBgAAAA==.',['周防']='周防天音:BAAAKgADCgYIBgAAAA==.',['咕咕']='咕咕魍魉:BAAAKgAFFAQIBAAAAA==.',['咪类']='咪类个喵:BAAAKgAFFAQIBAAAAA==.',['咸鱼']='咸鱼罐头:BAAAKgAECgEIAQAAAA==.',['哀求']='哀求:BAACKgAFFH8MAAIIAAQIChQTTADXAAAIAAQIChQTTADXAAAqAAQKfygAAwgACAgeHzoNAHwCAAgACAgeHzoNAHwCABkAAwhhCBFFAHQAAAAA.',['哈哩']='哈哩咕噜几:BAAAKgAFFAQIBAAAAA==.',['哈士']='哈士旗:BAAAKgAFFAEIAQAAAA==.',['哈根']='哈根达斯:BAAAKgADCggICAAAAA==.',['唐初']='唐初排骨:BAAAKgADCgEIAQAAAA==.',['唱游']='唱游:BAAAKgAECggICAAAAA==.',['啊哦']='啊哦:BAAAKgAECggIDQAAAA==.',['喜之']='喜之郎:BAABKgAFFH8IAAIOAAgIiAx5AwB/AQAOAAgIiAx5AwB/AQAAAA==.',['喵若']='喵若曦:BAAAKgAFFAIIAgAAAA==.',['嘟嘟']='嘟嘟小强:BAAAKgAECgIIAgAAAA==.',['嘿那']='嘿那个骑士:BAAAKgADCggICAAAAA==.',['噬之']='噬之魂:BAAAKgAECgcIDAAAAA==.',['团长']='团长一翻跟头:BAAAKgAECgEIAQAAAA==.',['国宝']='国宝级别:BAAAKgAECgYIDAAAAA==.',['圣无']='圣无界:BAABKgAFFH8GAAIIAAYIvhLWAwCRAQAIAAYIvhLWAwCRAQAAAA==.',['坏坏']='坏坏小宝:BAAAKgAECgQIBAAAAA==.',['埃尔']='埃尔文薛定谔:BAACKgAFFH8sAAIDAAgIbyQMBQDzAQADAAgIbyQMBQDzAQAqAAQKfxoAAgMACAgNIpcHAI8CAAMACAgNIpcHAI8CAAAA.',['埃里']='埃里雅罗:BAAAKgAECgMIBQAAAA==.',['墓有']='墓有亡法:BAAAKgADCgIIAgAAAA==.',['墨洒']='墨洒丹心:BAAAKgADCgcIBwAAAA==.',['壮鱼']='壮鱼儿:BAAAKgAECgUIBQAAAA==.',['壹生']='壹生所愛:BAAAKgAECggICAAAAA==.',['壹贰']='壹贰叁肆伍:BAAAKgADCgQIBAAAAA==.',['夏目']='夏目丶友人帐:BAAAKgAECgMIAwAAAA==.',['夜月']='夜月追风:BAACKgAFFH8qAAMHAAcIdhRWEABoAQAHAAYIdhRWEABoAQAFAAQIEg3dIwDHAAAqAAQKfzIABAUACAjEFRktAO0BAAUACAjEFRktAO0BAAYABQgeEXhsAMQAAAcAAwgiEnppAKUAAAAA.',['夜羽']='夜羽:BAAAKgADCgEIAQAAAA==.',['大丶']='大丶爷:BAAAKgAECgMIAwAAAA==.',['大兵']='大兵:BAACKgAFFH8IAAIIAAMItQ61UwDJAAAIAAMItQ61UwDJAAAqAAQKfyEAAggACAgYG4BEAPMBAAgACAgYG4BEAPMBAAAA.',['大沐']='大沐沐:BAAAKgAECgUICQAAAA==.',['大牛']='大牛追小牛:BAABKgAFFH8FAAINAAIIaQR0MgBjAAANAAIIaQR0MgBjAAAAAA==.',['大眼']='大眼小馒头:BAABKgAFFH8OAAMRAAYIuRy/AADxAQARAAYIuRy/AADxAQAQAAQIDxOoBwDyAAAAAA==.',['大赖']='大赖皮:BAAAKgAFFAQIBAAAAA==.',['大风']='大风吹:BAACKgAFFH8KAAMYAAMI4gsRHwC4AAAYAAMI4gsRHwC4AAAJAAMIQwf7KQB7AAAqAAQKf0AAAxgACAjGGg0jADACABgACAjGGg0jADACAAkACAjkGeEHAAYCAAAA.',['天天']='天天又天天:BAAAKgAECgcIBwAAAA==.天天向上:BAAAKgADCggICAAAAA==.天天熊:BAAAKgAFFAQIBAAAAA==.',['天笑']='天笑大骑士:BAAAKgADCggICQAAAA==.',['女神']='女神的救赎:BAABKgAFFH8OAAMLAAcIqRnXEAArAQALAAUIBBbXEAArAQAaAAUI9RZICwC+AAAAAA==.',['好像']='好像一只牛:BAAAKgADCggICAAAAA==.',['好名']='好名字:BAAAKgAECgcICAAAAA==.',['好好']='好好恋爱:BAAAKgADCgQIBAAAAA==.',['妮娜']='妮娜杜波夫:BAAAKgAECgQIBAAAAA==.',['威哥']='威哥:BAAAKgAECgUICgAAAA==.',['孤城']='孤城不危:BAACKgAFFH8JAAIWAAMIYBujEgDjAAAWAAMIYBujEgDjAAAqAAQKfxUAAhYACAgWEL9HAGoBABYACAgWEL9HAGoBAAAA.',['孤寂']='孤寂精灵:BAAAKgADCgEIAQAAAA==.',['安度']='安度余生:BAABKgAFFH8KAAMUAAYIWRq+DQAYAQAUAAQI7yG+DQAYAQAVAAII9w6dGACeAAAAAA==.',['宝山']='宝山吴彦祖丶:BAABKgAFFH8IAAIKAAgIfwuCDADHAQAKAAgIfwuCDADHAQAAAA==.',['寂静']='寂静冷冬:BAAAKgAECgYIBwAAAA==.',['富婆']='富婆来拉怪:BAABKgAFFH8GAAIbAAYIjRLYDQA7AQAbAAYIjRLYDQA7AQABKgAFFAgIDgAKAEoXAA==.',['寒月']='寒月无声:BAABKgAFFH8IAAIKAAgIgQITDQAtAQAKAAgIgQITDQAtAQAAAA==.',['寻风']='寻风脚步:BAAAKgAFFAIIAgAAAA==.',['小信']='小信用卡:BAAAKgAECggIEAAAAA==.',['小宝']='小宝贝儿:BAACKgAFFH8HAAIUAAMIOgnDQwCRAAAUAAMIOgnDQwCRAAAqAAQKfyUAAxQACAhQFw0dAJEBABQACAhQFw0dAJEBABUAAgjGDTdMACwAAAAA.',['小小']='小小仔仔:BAACKgAFFH8HAAIIAAQIhBX0IQDgAAAIAAQIhBX0IQDgAAAqAAQKfyUAAggACAhxI7wIALMCAAgACAhxI7wIALMCAAAA.小小福:BAAAKgADCggICAAAAA==.小小闹钟:BAAAKgAECgUIBQAAAA==.',['小猎']='小猎哥哥:BAAAKgADCgEIAQAAAA==.',['小盒']='小盒子灬:BAAAKgAFFAEIAQAAAA==.',['小米']='小米苏柒:BAAAKgAECggICAAAAA==.',['小青']='小青儿:BAABKgAFFH8NAAIaAAMIDhjdFgDbAAAaAAMIDhjdFgDbAAAAAA==.小青青:BAAAKgAECgEIAQAAAA==.',['小龙']='小龙人烧烤:BAAAKgAECggIEgAAAA==.',['少女']='少女丶撒手:BAABKgAFFH8HAAITAAYI0QsABQCMAQATAAYI0QsABQCMAQAAAA==.',['尼古']='尼古拉斯二狗:BAABKgAFFH8IAAIRAAgIqgSPCQAyAQARAAgIqgSPCQAyAQAAAA==.',['巫喵']='巫喵王:BAAAKgAECgMIBAAAAA==.',['巳白']='巳白:BAABKgAFFH8GAAIHAAYI/hdPDwB1AQAHAAYI/hdPDwB1AQAAAA==.',['帅哥']='帅哥在此:BAABKgAFFH8FAAIKAAIIlwgiSwB1AAAKAAIIlwgiSwB1AAAAAA==.',['帅帅']='帅帅喵咪:BAABKgAFFH8GAAIYAAYIYRdrGQBOAQAYAAYIYRdrGQBOAQAAAA==.',['帅的']='帅的掉渣:BAABKgAFFH8HAAIVAAYI6RdVEgBQAQAVAAYI6RdVEgBQAQAAAA==.',['帝煌']='帝煌:BAAAKgAECgQIBQAAAA==.',['幸运']='幸运之星:BAAAKgAECgMIAwAAAA==.',['幻灵']='幻灵幽幽:BAABKgAECn8gAAQMAAgIUhXDFwDCAQAMAAgIUhXDFwDCAQAEAAIIww6rRgAwAAAcAAEIAADFHgAAAAAAAA==.',['幽冥']='幽冥暮色:BAAAKgADCggICAAAAA==.',['幽灵']='幽灵魍魉:BAAAKgAECgEIAQAAAA==.',['幽荧']='幽荧:BAABKgAFFH8GAAIWAAQIyQigHwCGAAAWAAQIyQigHwCGAAAAAA==.',['康忙']='康忙泽喂:BAAAKgADCggICAAAAA==.',['弄弄']='弄弄:BAAAKgAECgYIBwAAAA==.',['强盗']='强盗:BAAAKgAECgMIAwAAAA==.强盗肥波:BAAAKgAECggICQAAAA==.',['影之']='影之灵龛:BAAAKgADCggICAAAAA==.',['影心']='影心:BAAAKgAECggIAQAAAA==.',['得非']='得非所求:BAAAKgAECgcIBwAAAA==.',['徘徊']='徘徊月:BAABKgAFFH8eAAIIAAgIQx/HAQDSAQAIAAgIQx/HAQDSAQAAAA==.',['微风']='微风沐情书:BAAAKgAECgIIAgAAAA==.微风沐清書:BAABKgAFFH8IAAIIAAMIUAWwaACbAAAIAAMIUAWwaACbAAAAAA==.',['德禄']='德禄一:BAAAKgAECgcIDQAAAA==.',['心的']='心的发现:BAAAKgAFFAgIAgAAAA==.',['忘离']='忘离霹雳重触:BAAAKgAECgQIBAAAAA==.',['思弦']='思弦:BAAAKgADCggICAAAAA==.',['恋上']='恋上酒的猫:BAAAKgAECgIIAgAAAA==.',['恋馨']='恋馨:BAABKgAFFH8IAAIIAAgI+g1SCwDuAQAIAAgI+g1SCwDuAQAAAA==.',['恶魔']='恶魔乄市銀丸:BAABKgAFFH8FAAIEAAIIMhS6JQB5AAAEAAIIMhS6JQB5AAAAAA==.',['悟空']='悟空嘿嘿:BAABKgAFFH8FAAIGAAMIKgiHHgCRAAAGAAMIKgiHHgCRAAAAAA==.',['悠哉']='悠哉丶:BAABKgAFFH8IAAIbAAgI2w9MCACWAQAbAAgI2w9MCACWAQAAAA==.',['情迷']='情迷大自然:BAABKgAECn8nAAIUAAgI4QfudwDwAAAUAAgI4QfudwDwAAAAAA==.',['慧慧']='慧慧可人:BAAAKgAECgQIBAAAAA==.',['我不']='我不是坏蛋:BAAAKgAECggICQAAAA==.',['我叫']='我叫佩佩:BAAAKgAECgIIAgAAAA==.',['我很']='我很幸福哈:BAAAKgADCgUIBQAAAA==.',['我撒']='我撒腿就跑:BAAAKgAFFAQIBAAAAA==.',['我来']='我来组成头部:BAAAKgADCggICAAAAA==.',['我欲']='我欲我狂:BAABKgAECn8xAAQGAAgIYhblDQCcAQAGAAgI5BXlDQCcAQAHAAgIWxEYPgBLAQAFAAIIhQYhEAA4AAAAAA==.',['我火']='我火很大:BAABKgAFFH8FAAIEAAUIfAoNIgD4AAAEAAUIfAoNIgD4AAAAAA==.',['我热']='我热:BAAAKgAFFAEIAQAAAA==.',['戒音']='戒音:BAAAKgAECgMIAwAAAA==.',['战神']='战神丶贝塔:BAABKgAFFH8UAAMdAAgI5xTlAADPAQAdAAgI5xTlAADPAQANAAMILwQOGACcAAAAAA==.',['戰岚']='戰岚破海:BAACKgAFFH8NAAMdAAYIxB00CACJAQAdAAYIxB00CACJAQANAAEIjhTlKQBKAAAqAAQKfzwAAw0ACAjRIZ0LAI4CAA0ACAjRIZ0LAI4CAA4AAgj6AzxNACEAAAEqAAUUCAgCAB4AAAAA.',['技师']='技师也是师:BAAAKgADCgEIAQAAAA==.',['抚蔚']='抚蔚光明:BAAAKgAECggICAAAAA==.',['捣蛋']='捣蛋猫:BAAAKgAECgMIBAAAAA==.',['掌心']='掌心丶:BAAAKgAFFAcIAgAAAA==.',['提裙']='提裙:BAAAKgAECgYIBgAAAA==.',['提里']='提里奥矮丁:BAAAKgAECgQIBAAAAA==.提里奥胖丁:BAAAKgAECgEIAQAAAA==.',['揸刀']='揸刀的强盗:BAABKgAECn8WAAIWAAgIXg28WAAhAQAWAAgIXg28WAAhAQAAAA==.',['摁着']='摁着来:BAAAKgAECgEIAQAAAA==.',['撒拿']='撒拿棍戳咧:BAAAKgAECgYICwAAAA==.',['故人']='故人:BAAAKgAECgEIAQAAAA==.',['故仁']='故仁:BAAAKgAECgQIBAAAAA==.',['救赎']='救赎乆乆:BAAAKgAFFAYIBAAAAA==.',['教父']='教父:BAAAKgADCgYICQAAAA==.',['文文']='文文哥哥:BAAAKgAECgUIBQAAAA==.',['断线']='断线远飞:BAABKgAECn8bAAMCAAgIPhJ4JwCYAQACAAgIPhJ4JwCYAQAWAAQIfQ0MlQB+AAAAAA==.',['新岛']='新岛真:BAAAKgAECgYIBgAAAA==.',['斷臂']='斷臂維納斯:BAAAKgAECgcIBwAAAA==.',['方丈']='方丈出山:BAAAKgAFFAIIBAAAAA==.',['无敌']='无敌大虾:BAABKgAECn8eAAIEAAgIsBLpJQCLAQAEAAgIsBLpJQCLAQAAAA==.',['旦旦']='旦旦哥哥:BAAAKgADCgQIBAAAAA==.',['时间']='时间背叛者:BAAAKgADCggICAAAAA==.',['明明']='明明郁闷:BAAAKgADCgYIBgAAAA==.',['星见']='星见雅:BAABKgAFFH8GAAIRAAYIlhyrCwCRAQARAAYIlhyrCwCRAQAAAA==.',['昨晚']='昨晚星辰:BAAAKgAECgEIAQAAAA==.',['普莉']='普莉梅拉:BAABKgAFFH8IAAMDAAgI6A0CHACZAAADAAQItxECHACZAAAIAAQIDAsAAAAAAAAAAA==.',['普通']='普通人黑兹:BAAAKgAECgMIAwAAAA==.',['暗夜']='暗夜小萱萱:BAAAKgAECgIIAgAAAA==.',['暗影']='暗影之觞:BAAAKgAECgQIBAAAAA==.',['暗色']='暗色爱丽丝:BAAAKgAFFAEIAQAAAA==.',['暮溪']='暮溪:BAABKgAFFH8IAAIEAAgIQggWCgC1AQAEAAgIQggWCgC1AQAAAA==.',['暴力']='暴力鸟:BAABKgAFFH8GAAIJAAYIPQTsCwDOAAAJAAYIPQTsCwDOAAAAAA==.',['曹阿']='曹阿满呀:BAAAKgAECgYIDAAAAA==.',['月蚀']='月蚀之舞:BAACKgAFFH8XAAMOAAgIVRMgBABSAQAOAAYIiBQgBABSAQAdAAIIVhALHgCcAAAqAAQKfx0AAg4ACAhSDvkZADwBAA4ACAhSDvkZADwBAAAA.',['木瓜']='木瓜惹的祸:BAAAKgAECgYIBgAAAA==.',['木石']='木石枚子:BAAAKgAFFAQIBAAAAA==.',['朵小']='朵小朵:BAAAKgAFFAgIAgAAAA==.',['李逍']='李逍遙:BAAAKgAFFAEIAQAAAA==.',['杜甫']='杜甫丶:BAABKgAFFH8GAAIbAAQIZg82FQCiAAAbAAQIZg82FQCiAAAAAA==.',['来抓']='来抓老子啊:BAAAKgAECgYIDAAAAA==.',['来碗']='来碗排骨面:BAAAKgADCggIDwAAAA==.来碗排骨靣:BAAAKgADCggICAAAAA==.',['极博']='极博大的胸怀:BAAAKgAECgQIBAAAAA==.',['极品']='极品狂人:BAAAKgADCgUIBQAAAA==.',['果果']='果果龙:BAAAKgAECgYIBgAAAA==.',['枫珏']='枫珏丶:BAABKgAECn8lAAIUAAgIkyDAEQCaAgAUAAgIkyDAEQCaAgAAAA==.',['柠檬']='柠檬养乐多:BAAAKgADCgEIAQAAAA==.',['梦醒']='梦醒的嘟少:BAAAKgADCgQIBAAAAA==.',['森林']='森林丶:BAABKgAFFH8IAAMQAAMI5A+BBADFAAAQAAMI5A+BBADFAAARAAIIPQO2JgBnAAAAAA==.',['森语']='森语鹿鸣:BAAAKgAECgIIAgAAAA==.',['此间']='此间丶年少:BAAAKgAECgUIBgAAAA==.',['死亡']='死亡骑:BAAAKgAECgUIBQAAAA==.',['段小']='段小贱:BAAAKgAECgEIAQAAAA==.',['比歌']='比歌迪克:BAACKgAFFH8NAAMVAAMIZhpeCwDxAAAVAAMIZhpeCwDxAAAUAAEIlxe/RwBIAAAqAAQKfygAAxUACAjKIcQJAJUCABUACAjKIcQJAJUCABQAAgimFePRAIcAAAAA.',['氯化']='氯化鈉:BAAAKgAECgMIAwAAAA==.',['水波']='水波啵:BAAAKgADCgEIAQAAAA==.',['汤圆']='汤圆麻麻:BAAAKgAECgQIBAAAAA==.',['沐小']='沐小雅:BAAAKgAECgMIAwAAAA==.',['没啥']='没啥感觉:BAABKgAFFH8JAAIIAAcIzBiWEwBlAQAIAAcIzBiWEwBlAQAAAA==.',['没有']='没有点卡:BAAAKgAECgEIAQAAAA==.',['没点']='没点逼术:BAAAKgAFFAQIBAAAAA==.',['沪爷']='沪爷冲击:BAABKgAFFH8GAAIVAAYIIgtKGgAaAQAVAAYIIgtKGgAaAQAAAA==.',['泡沫']='泡沫冰茶:BAAAKgADCgIIAgAAAA==.',['泪血']='泪血狂徒:BAABKgAECn8gAAIbAAgIEgXSNQCwAAAbAAgIEgXSNQCwAAAAAA==.',['洛青']='洛青:BAABKgAFFH8IAAIIAAcISw/7GQAWAQAIAAcISw/7GQAWAQAAAA==.',['活力']='活力小萱:BAAAKgAECgcIBgAAAA==.',['流焱']='流焱:BAAAKgADCggIGAAAAA==.',['流羽']='流羽牛掰奶爸:BAAAKgAFFAMIAwAAAA==.',['海上']='海上生明月:BAAAKgAECgIIAgAAAA==.',['清水']='清水佐纪:BAAAKgAFFAgIBAAAAA==.',['清风']='清风醉笑:BAABKgAECn8ZAAIWAAgI1AmcZAD9AAAWAAgI1AmcZAD9AAAAAA==.',['温小']='温小暖:BAABKgAFFH8GAAIIAAYIVw10MAAnAQAIAAYIVw10MAAnAQABKgAFFAgICAAIAC8jAA==.',['澤塔']='澤塔瓊斯:BAAAKgADCggICAAAAA==.',['灬偲']='灬偲淰灬:BAAAKgADCggICAAAAA==.',['灬思']='灬思念灬:BAAAKgADCggICAAAAA==.',['灬时']='灬时雨落枫灬:BAABKgAECn8sAAIXAAgIChXfCgC8AQAXAAgIChXfCgC8AQAAAA==.',['炫酷']='炫酷擎天柱:BAAAKgAFFAIIAgAAAA==.',['烈焰']='烈焰狂吻:BAAAKgAECgQIBQAAAA==.烈焰猎手:BAABKgAECn8ZAAMTAAgIiBQ2GwB4AQATAAYIuBk2GwB4AQAPAAgIfAn/FADkAAAAAA==.',['熊医']='熊医生:BAAAKgADCggIEQAAAA==.',['熊猫']='熊猫茄子:BAABKgAFFH8SAAIWAAMIExsAFADWAAAWAAMIExsAFADWAAAAAA==.',['爆弹']='爆弹狂鼠:BAAAKgAECggICgAAAA==.',['爱意']='爱意随钟起:BAAAKgAECgMIAwAAAA==.',['爵士']='爵士飛鬍:BAAAKgAECggIDQAAAA==.',['牧唧']='牧唧唧:BAAAKgADCgMIAwAAAA==.',['狂暴']='狂暴狂暴战神:BAAAKgAECggIEQAAAA==.',['狂烈']='狂烈焰吻:BAAAKgAECgcIBwAAAA==.',['狙打']='狙打天下:BAAAKgADCggICAAAAA==.',['狼之']='狼之嚎叫:BAAAKgAECgMIAwAAAA==.',['猎取']='猎取天下:BAAAKgADCgMIAwAAAA==.',['猪猪']='猪猪牧:BAAAKgADCggICAAAAA==.',['玩玩']='玩玩耍耍:BAAAKgADCgEIAQAAAA==.',['琳琳']='琳琳寶貝:BAAAKgADCgEIAQAAAA==.',['电竞']='电竞判客:BAAAKgAECgIIAgAAAA==.',['疾风']='疾风破袭:BAAAKgADCgIIAgAAAA==.',['白菜']='白菜不再:BAABKgAFFH8KAAMfAAMIqRG8EwDGAAAfAAMIqRG8EwDGAAALAAEIUwAlRAAbAAAAAA==.',['白银']='白银风暴:BAAAKgADCggICAAAAA==.',['皮皮']='皮皮秋:BAAAKgAECggICAAAAA==.',['目童']='目童:BAAAKgAFFAgIAgAAAA==.',['盾在']='盾在手人在抖:BAAAKgAECgIIAgAAAA==.',['真理']='真理香:BAABKgAFFH8GAAINAAYIORvoCwCMAQANAAYIORvoCwCMAQAAAA==.',['破墟']='破墟玄玄:BAABKgAECn8UAAIEAAgIvxAVOwCAAQAEAAgIvxAVOwCAAQAAAA==.',['破晓']='破晓前忘掉:BAAAKgAECggICAAAAA==.',['社会']='社会平爷:BAACKgAFFH8GAAIJAAQIdxOYCwDTAAAJAAQIdxOYCwDTAAAqAAQKfx0ABBgACAjpI6wWAH8CABgABwjPJawWAH8CAAkACAgEICgMAHICACAAAQiGGJ8sAEUAAAAA.',['神之']='神之翼:BAAAKgAECgYIBgAAAA==.',['神圣']='神圣天启:BAAAKgAECgIIAgAAAA==.',['神箭']='神箭丘比特:BAAAKgADCgYIBgAAAA==.',['福乐']='福乐爸爸:BAAAKgAECgUIBQAAAA==.',['福星']='福星:BAAAKgADCgYIBgAAAA==.',['秃头']='秃头强:BAAAKgAFFAYIBAABKgAFFAgIBgAJAHcTAA==.',['秋葉']='秋葉蒝:BAABKgAECn8tAAIUAAgI0xbWMwDYAQAUAAgI0xbWMwDYAQAAAA==.',['站长']='站长:BAAAKgADCgIIAgAAAA==.',['米卡']='米卡莎丷:BAACKgAFFH8LAAQfAAgIGQ87FADbAAAfAAQIHhE7FADbAAAaAAMISheJGgC/AAALAAEI9A2TPgA/AAAqAAQKfxoAAxoACAhrEgk/ABsBABoACAhrEgk/ABsBAB8ABAh5BRNmAF0AAAAA.',['米色']='米色极光:BAAAKgAECggICgAAAA==.',['精灵']='精灵之使:BAAAKgAECgUIBQAAAA==.',['紫柏']='紫柏:BAABKgAFFH8IAAIIAAgI/g9eDQD7AQAIAAgI/g9eDQD7AQAAAA==.',['红茶']='红茶拿铁:BAAAKgAECggIDwAAAA==.',['纳尔']='纳尔森:BAABKgAFFH8IAAITAAgImgVmDACTAQATAAgImgVmDACTAQAAAA==.',['练拳']='练拳先练嘴:BAAAKgAFFAQIBAAAAA==.',['练级']='练级太难了:BAAAKgADCggICAAAAA==.',['给你']='给你两下:BAAAKgAECgUIBQAAAA==.',['绿筱']='绿筱配青竹:BAAAKgAECgYIBgAAAA==.',['绿萼']='绿萼添妆:BAAAKgADCggICAAAAA==.',['置信']='置信区间:BAAAKgAFFAQIBAAAAA==.',['翁雪']='翁雪:BAABKgAFFH8NAAMHAAgIYCSsAAD8AgAHAAgIYCSsAAD8AgAGAAMI2h1sHQCZAAAAAA==.',['老年']='老年阿宾:BAABKgAFFH8FAAIOAAUIZh4NBQAvAQAOAAUIZh4NBQAvAQAAAA==.',['胖哒']='胖哒:BAAAKgAECgMIBQAAAA==.',['胖奶']='胖奶:BAABKgAFFH8GAAIWAAIIwA1GRwBrAAAWAAIIwA1GRwBrAAAAAA==.',['腼腆']='腼腆小野孩:BAAAKgAFFAMIAwAAAA==.',['艾黎']='艾黎娅罗:BAAAKgAECgEIAQAAAA==.',['芮斯']='芮斯拜:BAABKgAFFH8IAAIhAAQI8RdBDgDfAAAhAAQI8RdBDgDfAAAAAA==.',['花落']='花落:BAAAKgAECgMIAwAAAA==.',['苍星']='苍星石:BAAAKgADCgYIBgAAAA==.',['苏打']='苏打饼干:BAAAKgAFFAIIAgAAAA==.',['苏酥']='苏酥头号粉丝:BAAAKgAFFAIIAgAAAA==.',['若叶']='若叶牧:BAAAKgAECgUIDQAAAA==.',['莉雅']='莉雅的小蛋蛋:BAAAKgAECgUIBQAAAA==.',['莫隐']='莫隐:BAAAKgAECgYIBgAAAA==.',['莱恩']='莱恩家的天神:BAAAKgAECgcICwAAAA==.莱恩家的死神:BAAAKgADCggICAAAAA==.',['菜刀']='菜刀抠脚:BAACKgAFFH8LAAIIAAYIEyCdDwDlAQAIAAYIEyCdDwDlAQAqAAQKfxQAAggABgiwFXGbABcBAAgABgiwFXGbABcBAAAA.',['菠萝']='菠萝条条:BAABKgAFFH8IAAIEAAgISRTtBwARAgAEAAgISRTtBwARAgAAAA==.',['萨森']='萨森斯坦森:BAAAKgAECgcIBwAAAA==.',['落花']='落花菲:BAAAKgAECgcICgAAAA==.',['落雨']='落雨听禅:BAAAKgAECgQIBAAAAA==.',['蒂法']='蒂法祈祷:BAAAKgAECggICAAAAA==.',['薄雾']='薄雾幽幽:BAAAKgAFFAQIBAAAAA==.',['薇欧']='薇欧娜尔:BAAAKgAECggICgAAAA==.',['蛋疼']='蛋疼的生活:BAAAKgADCggICAAAAA==.',['蜡笔']='蜡笔小新的笔:BAABKgAFFH8IAAMFAAYIEhG7DwBJAQAFAAYI6A67DwBJAQAGAAIIyBZ/FACMAAAAAA==.',['蝦米']='蝦米:BAAAKgAECgYICQAAAA==.',['裤子']='裤子都脱了:BAAAKgAECgcIBwAAAA==.',['覆盆']='覆盆子:BAABKgAECn8wAAIWAAgIuxOoQwBpAQAWAAgIuxOoQwBpAQAAAA==.',['试剂']='试剂:BAAAKgADCggICAAAAA==.',['诸子']='诸子百家:BAABKgAFFH8IAAINAAQIURa6GwDmAAANAAQIURa6GwDmAAAAAA==.',['谁为']='谁为天使忧愁:BAAAKgAECgcIDgABKgAFFAIIAgAeAAAAAA==.',['谁懂']='谁懂明月心:BAAAKgAFFAgIBAAAAA==.',['调皮']='调皮软脚虾:BAAAKgAECgEIAQAAAA==.',['豆花']='豆花米线:BAAAKgAECgQIBAAAAA==.',['赫克']='赫克托尔:BAAAKgAECgEIAQAAAA==.',['赫琳']='赫琳托尔贝恩:BAAAKgAFFAQIAgAAAA==.',['赵本']='赵本山:BAAAKgAECgYIBgAAAA==.',['超甜']='超甜软男:BAAAKgAECggICAAAAA==.',['超级']='超级钢板:BAAAKgAECgUIBQAAAA==.',['跑的']='跑的飞快:BAAAKgADCggICAAAAA==.',['路希']='路希菲尔:BAAAKgADCggICAAAAA==.',['轨桧']='轨桧鬼:BAAAKgAECgcICAAAAA==.',['辣个']='辣个老板:BAABKgAFFH8GAAILAAYIYR0yCQCSAQALAAYIYR0yCQCSAQAAAA==.',['辣白']='辣白菜:BAABKgAFFH8GAAIWAAYIGRh0DQB2AQAWAAYIGRh0DQB2AQAAAA==.',['还是']='还是那个老板:BAABKgAFFH8GAAIBAAYIqAkIBQBkAQABAAYIqAkIBQBkAQAAAA==.',['迷幻']='迷幻唱腔:BAAAKgADCgYIBgAAAA==.',['逐风']='逐风烨月:BAAAKgAECgEIAQAAAA==.',['遥远']='遥远的救世主:BAAAKgAECgMIAwAAAA==.',['那年']='那年十八岁:BAAAKgAECgIIAgAAAA==.那年的春夏:BAABKgAFFH8KAAMIAAMILRKLUgDLAAAIAAMILRKLUgDLAAADAAMIYQYHIwBsAAAAAA==.',['邪能']='邪能乆乆:BAACKgAFFH8KAAIEAAYILx0DDAAAAQAEAAYILx0DDAAAAQAqAAQKfxgAAgQABwgAF007AH8BAAQABwgAF007AH8BAAAA.',['部落']='部落的敌人:BAABKgAECn83AAQVAAgIfxX/FgB1AQAVAAgIShH/FgB1AQAUAAgIYREEUwBiAQAiAAYIkRW5BABNAQAAAA==.',['醉梦']='醉梦浮生:BAAAKgAECgUIBAAAAA==.',['醉酒']='醉酒阿飞:BAAAKgAECgQIBAAAAA==.',['野猪']='野猪佩琪:BAABKgAFFH8HAAIIAAYIKgZGXwCyAAAIAAYIKgZGXwCyAAABKgAFFAgIDwAdAJAUAA==.',['野蛮']='野蛮宝贝:BAAAKgAECgUIBQAAAA==.',['銘訫']='銘訫頦餶:BAAAKgAECgcIBwAAAA==.',['长期']='长期术世:BAAAKgAECgIIAgAAAA==.',['閃耀']='閃耀:BAAAKgAECgYIEQAAAA==.',['闇之']='闇之魔魂:BAABKgAFFH8KAAINAAYIIxM3DACIAQANAAYIIxM3DACIAQAAAA==.',['闪电']='闪电连五鞭:BAAAKgAECgMIAwAAAA==.',['闪闪']='闪闪不泡茶:BAAAKgAECgcICgAAAA==.',['阝灬']='阝灬傻傻彡:BAAAKgAECggIDAAAAA==.阝灬熊熊彡:BAAAKgAECggIEAAAAA==.',['防战']='防战天笑:BAAAKgAECgYIBgAAAA==.',['阳羡']='阳羡清露:BAAAKgAECgQIBAAAAA==.',['阿尔']='阿尔塞斯他弟:BAAAKgADCgUIBQAAAA==.阿尔塞斯姐夫:BAAAKgAECgcIBwAAAA==.阿尔塞斯是你:BAAAKgAECgYICgAAAA==.阿尔塞斯是我:BAAAKgAECgQIBgAAAA==.阿尔赛斯:BAAAKgAECgcICAAAAA==.阿尔达:BAAAKgAECgYICgAAAA==.',['阿洛']='阿洛:BAAAKgAECgQIBAAAAA==.',['阿瓦']='阿瓦可:BAAAKgAECgEIAQAAAA==.',['阿鸡']='阿鸡:BAAAKgAFFAIIAgAAAA==.',['陆啦']='陆啦啦辣:BAABKgAFFH8FAAIDAAUIlxrcAgBTAQADAAUIlxrcAgBTAQAAAA==.',['陈佳']='陈佳佳:BAACKgAFFH8FAAIXAAII3warIgBPAAAXAAII3warIgBPAAAqAAQKfx4AAxcACAifEXErAIwBABcACAifEXErAIwBACMAAQiFCXIXACMAAAAA.',['陈壮']='陈壮壮:BAAAKgAECgQIBAAAAA==.',['雨落']='雨落冰寒:BAAAKgAECgYICAAAAA==.雨落栀晓:BAAAKgAECgEIAgAAAA==.',['雪圣']='雪圣丶:BAAAKgAECggICwAAAA==.',['雪灵']='雪灵丶:BAABKgAECn8eAAIUAAYImxyTWwCeAQAUAAYImxyTWwCeAQAAAA==.',['雪碧']='雪碧无糖:BAAAKgAECgQIBQAAAA==.',['雪舞']='雪舞舞:BAAAKgAECgEIAQAAAA==.',['雷影']='雷影魔魂:BAABKgAFFH8GAAIWAAYI9x1dBwCnAQAWAAYI9x1dBwCnAQAAAA==.',['雾都']='雾都老登:BAAAKgAECgIIAgAAAA==.',['霄雲']='霄雲:BAAAKgADCgIIAgAAAA==.',['青灯']='青灯夜游:BAAAKgADCggICAAAAA==.',['青芝']='青芝:BAAAKgAECggICAAAAA==.',['靠近']='靠近靠近:BAAAKgADCggICAAAAA==.',['顿了']='顿了顿:BAAAKgAECgYICAAAAA==.',['风影']='风影魔魂:BAABKgAFFH8GAAIBAAYI5hiMBwCDAQABAAYI5hiMBwCDAQAAAA==.',['飘然']='飘然洒脱的你:BAAAKgAECgEIAQAAAA==.',['飞雷']='飞雷羽羽矢:BAABKgAFFH8IAAIUAAgIVwLhEwDwAAAUAAgIVwLhEwDwAAAAAA==.',['骑士']='骑士魅影:BAAAKgAFFAEIAQAAAA==.',['骨质']='骨质增僧:BAAAKgAECgEIAgAAAA==.',['魅小']='魅小影:BAACKgAFFH8SAAITAAQIZiSTBwBCAQATAAQIZiSTBwBCAQAqAAQKfxoAAhMACAhLIHUgAEICABMACAhLIHUgAEICAAAA.',['魔幻']='魔幻冥帝:BAAAKgAECggICAAAAA==.魔幻天鋆:BAAAKgADCgIIAgAAAA==.魔幻棒棒:BAABKgAFFH8UAAIXAAYINx5DAQDeAQAXAAYINx5DAQDeAQABKgAFFAgIEgAbALUfAA==.',['魔灵']='魔灵:BAAAKgAECgIIAgAAAA==.',['鹰鹜']='鹰鹜:BAAAKgAFFAQIBAAAAA==.',['麒哥']='麒哥:BAAAKgADCggIAwAAAA==.',['麯蔠']='麯蔠亽繖:BAABKgAFFH8JAAIUAAgI3xitBABeAgAUAAgI3xitBABeAgAAAA==.',['黄仁']='黄仁勋:BAABKgAFFH8GAAIIAAYIyB5DFQCxAQAIAAYIyB5DFQCxAQAAAA==.',['黄昏']='黄昏:BAAAKgADCggICQAAAA==.',['黑玉']='黑玉玲珑:BAAAKgADCggICAAAAA==.',['黑神']='黑神话耗子:BAAAKgAECgYICAAAAA==.',['黑色']='黑色死亡之翼:BAAAKgAECgYIBgAAAA==.',['龙彦']='龙彦:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end