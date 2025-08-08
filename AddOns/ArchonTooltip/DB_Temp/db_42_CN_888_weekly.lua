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
 local lookup = {'Warlock-Destruction','Warlock-Affliction','Rogue-Assassination','DeathKnight-Unholy','DeathKnight-Frost','Druid-Balance','DemonHunter-Vengeance','Evoker-Devastation','Paladin-Retribution','DemonHunter-Havoc','Priest-Discipline','Priest-Shadow','Mage-Fire','Hunter-Marksmanship','Unknown-Unknown','Warrior-Arms','Warrior-Fury','Priest-Holy','Mage-Frost','Warlock-Demonology','Druid-Restoration','Mage-Arcane','Monk-Brewmaster','Monk-Mistweaver','Druid-Guardian','Monk-Windwalker','Hunter-BeastMastery','Paladin-Protection','Evoker-Preservation','Shaman-Restoration','DeathKnight-Blood','Shaman-Elemental',}; local provider = {region='CN',realm='鲜血熔炉',name='CN',type='weekly',zone=42,date='2025-08-04',data={Aa='Aarn:BAABKgAFFH8PAAMBAAgIexz/BQA3AgABAAgIexz/BQA3AgACAAEIaxqJGwBNAAAAAA==.',Ah='Ahmighty:BAAAKgAFFAQIBAAAAA==.Ahsir:BAAAKgAECgQIBAABKgAFFAUIBgADAHoRAA==.',Ar='Ardth:BAABKgAECn80AAIEAAgInCCXFACFAgAEAAgInCCXFACFAgAAAA==.',As='Asdzxc:BAAAKgADCgEIAQAAAA==.',Ay='Ayamero:BAAAKgAECggIDAAAAA==.',Bl='Blingknight:BAAAKgAFFAIIAgAAAA==.',By='Byakuya:BAACKgAFFH8jAAMEAAgIVhH8EgCCAQAEAAgIVhH8EgCCAQAFAAEI3QWGCgAvAAAqAAQKfywAAwQACAhAHYMqAAwCAAQACAhAHYMqAAwCAAUABQgtFssfAMYAAAAA.',Ca='Carcharodon:BAAAKgAECgcIDAAAAA==.',Da='Darktang:BAAAKgAECgMIAwAAAA==.',De='Desoxynn:BAAAKgAFFAYIAQAAAA==.',Ea='Earthshaker:BAABKgAFFH8FAAIGAAMIpRrSKwDjAAAGAAMIpRrSKwDjAAAAAA==.',Ev='Evidrannor:BAAAKgAECgIIAgAAAA==.Evilxd:BAAAKgAECgQIBAAAAA==.',Fl='Flymdh:BAABKgAECn8gAAIHAAgIWA89OADYAAAHAAgIWA89OADYAAAAAA==.Flymm:BAAAKgADCgUIBQAAAA==.',Fr='Frozen:BAAAKgAECgEIAQAAAA==.',Ga='Galulu:BAAAKgAECgcICAABKgAFFAgIHQAIAB8iAA==.',He='Helsing:BAABKgAFFH8IAAIJAAQISxvFLQC4AAAJAAQISxvFLQC4AAAAAA==.',Ho='Honjo:BAAAKgADCggICAAAAA==.Howtoeasy:BAAAKgADCgYIBgAAAA==.',Hy='Hyvent:BAAAKgADCgUIBQAAAA==.',Ka='Kakarotto:BAACKgAFFH8TAAIKAAMInSKJGwAjAQAKAAMInSKJGwAjAQAqAAQKfxcAAgoACAiCGs40ANkBAAoACAiCGs40ANkBAAAA.',Ko='Konpakuyoumu:BAAAKgAECgUIBQAAAA==.Kopite:BAABKgAFFH8IAAIEAAQItBRYEwDsAAAEAAQItBRYEwDsAAAAAA==.',Li='Light:BAABKgAFFH8GAAMLAAYIcRvTCgBoAQALAAUI1B/TCgBoAQAMAAEINwgLLQBAAAAAAA==.Linchua:BAACKgAFFH8SAAIJAAcIORU+DADdAQAJAAcIORU+DADdAQAqAAQKfxUAAgkACAh7IMwNAHMCAAkACAh7IMwNAHMCAAAA.',Lo='Loiuytrew:BAAAKgAECgUICQABKgAFFAgICAALAPoIAA==.',Ma='Magician:BAABKgAFFH8KAAINAAYILSTmBQASAgANAAYILSTmBQASAgAAAA==.',On='Oncemore:BAABKgAFFH8HAAIJAAYIXxiNGQCSAQAJAAYIXxiNGQCSAQAAAA==.',Po='Posion:BAAAKgAECgQIBAAAAA==.',Pr='Priestl:BAAAKgADCggICAAAAA==.',Si='Silvanuswild:BAAAKgAECgEIAQAAAA==.',So='Sohee:BAAAKgAECgIIAgAAAA==.Somnus:BAABKgAFFH8FAAIOAAUIYxo7CAAFAQAOAAUIYxo7CAAFAQAAAA==.',We='Weejasdeath:BAAAKgADCggICAAAAA==.',Xb='Xbaa:BAAAKgAECgYIBgAAAA==.Xbzz:BAAAKgAECggICQAAAA==.',Ye='Yeeroy:BAACKgAFFH8YAAIHAAMIBRBFFACiAAAHAAMIBRBFFACiAAAqAAQKfzMAAgcACAizD4skAFwBAAcACAizD4skAFwBAAAA.',Yu='Yuka:BAAAKgAFFAEIAgAAAA==.',['一支']='一支大恶魔:BAAAKgADCgYIBgAAAA==.',['一日']='一日法:BAAAKgADCggICgAAAA==.',['一筒']='一筒:BAABKgAFFH8LAAIJAAYIoh4iFAC7AQAJAAYIoh4iFAC7AQAAAA==.',['一起']='一起哈啤啊:BAAAKgAECgIIAgAAAA==.',['一队']='一队的骑士:BAAAKgAFFAYIAgAAAA==.',['三分']='三分熟:BAAAKgAECggIDQAAAA==.',['三队']='三队骑士:BAAAKgAECgYICQAAAA==.',['下巴']='下巴颏儿:BAAAKgAECgcIBwAAAA==.',['丘比']='丘比特老婆:BAAAKgADCgUIBwAAAA==.',['东地']='东地那非:BAABKgAFFH8HAAIEAAQITBG6NgC/AAAEAAQITBG6NgC/AAAAAA==.',['丨叶']='丨叶落丨:BAAAKgAECgIIAwAAAA==.',['丨晴']='丨晴鸣丨:BAAAKgAFFAQIAgAAAA==.',['丨神']='丨神丶话丨:BAAAKgAECgQIBQAAAA==.',['丫头']='丫头飘飘:BAAAKgAFFAIIAgAAAA==.',['临沂']='临沂黑哥:BAAAKgAECgIIAgAAAA==.',['丶血']='丶血之汉尼拔:BAAAKgAFFAQIBAABKgAFFAgIBAAPAAAAAA==.',['乂木']='乂木头懒人乂:BAAAKgAFFAQIBAAAAA==.',['乌漆']='乌漆嘛黑怕:BAAAKgAECgMIAwAAAA==.',['乌龙']='乌龙茶灬琉璃:BAAAKgAECgMIBAAAAA==.',['九筒']='九筒:BAABKgAFFH8XAAMQAAYIpBm2BAC/AQAQAAYIMhm2BAC/AQARAAYIxxSNCgATAQABKgAFFAgIEAAQAIYNAA==.',['二龙']='二龙湖灬政哥:BAABKgAFFH8GAAISAAYIHhq4CgB3AQASAAYIHhq4CgB3AQAAAA==.',['五个']='五个糖豆:BAAAKgAECgEIAQAAAA==.',['伊咔']='伊咔洛斯:BAAAKgADCgIIAgAAAA==.',['众人']='众人皆草木:BAAAKgAFFAMIAwAAAA==.',['你么']='你么慌:BAAAKgAFFAIIAgAAAA==.',['你瞅']='你瞅啥:BAAAKgAECgUICQAAAA==.',['修哈']='修哈:BAAAKgAECgEIAQAAAA==.',['倔强']='倔强小宝:BAAAKgADCggICAAAAA==.',['傲灬']='傲灬龙飞:BAAAKgAFFAMIAwAAAA==.',['元素']='元素的绽放:BAABKgAECn8UAAMNAAgIsBm9MQDUAQANAAgIZRe9MQDUAQATAAUI6Rv+SwA1AQAAAA==.',['养一']='养一羊:BAAAKgAECgQIBwAAAA==.',['兽与']='兽与佛:BAAAKgAECgYICAAAAA==.',['兽兽']='兽兽猎:BAAAKgAFFAEIAQAAAA==.',['冰不']='冰不雪刃:BAAAKgAECgQIBAAAAA==.',['冲向']='冲向天空:BAAAKgADCgEIAQAAAA==.',['冲锋']='冲锋牛牛:BAAAKgAECgMIAwAAAA==.',['凤卷']='凤卷残云:BAABKgAECn8qAAIUAAgIsRu8AwBCAgAUAAgIsRu8AwBCAgAAAA==.',['刀鋒']='刀鋒聖猎:BAAAKgADCggICAAAAA==.',['刘大']='刘大刀:BAAAKgADCgUIBQAAAA==.',['刺客']='刺客信条:BAAAKgAFFAQIBAAAAA==.',['削肾']='削肾客的九叔:BAABKgAFFH8MAAIOAAQIJB+RCAADAQAOAAQIJB+RCAADAQAAAA==.',['前景']='前景无限:BAAAKgADCgEIAQAAAA==.',['加德']='加德斯:BAACKgAFFH8XAAIVAAQI8B+8EQAQAQAVAAQI8B+8EQAQAQAqAAQKfykAAhUACAjbHrwSADACABUACAjbHrwSADACAAAA.',['千岁']='千岁丶:BAAAKgAECggICAAAAA==.',['卖报']='卖报小郎君:BAAAKgAECgYIBgAAAA==.',['卡瓦']='卡瓦格博:BAAAKgADCgIIAgAAAA==.',['卿武']='卿武非佯:BAAAKgAECggIDAAAAA==.',['原神']='原神:BAABKgAFFH8YAAISAAMIDB/gFgD+AAASAAMIDB/gFgD+AAABKgAECggIIAAWAPQiAA==.',['又吃']='又吃橘子:BAAAKgADCgMIBAAAAA==.',['古拉']='古拉哈提亚:BAAAKgAECgMIAwAAAA==.',['吃饭']='吃饭香香:BAAAKgADCgEIAQAAAA==.',['吉尔']='吉尔尼斯屠夫:BAAAKgADCgUIBQAAAA==.',['吊打']='吊打核桃露:BAAAKgADCgIIAgAAAA==.',['后脑']='后脑勺儿:BAABKgAECn8lAAMBAAgI7Rt6BgBDAgABAAgI7Rt6BgBDAgAUAAEIHQ/EfQA4AAAAAA==.',['后脚']='后脚跟儿:BAAAKgAECggICQAAAA==.',['吥噌']='吥噌再噫:BAAAKgADCggIDAAAAA==.',['吽吽']='吽吽丶:BAAAKgAECgcICgAAAA==.',['咕噜']='咕噜露露:BAAAKgAECgcIBwAAAA==.',['哈根']='哈根达斯:BAAAKgAFFAQIBAAAAA==.',['哩野']='哩野:BAAAKgADCggICAAAAA==.',['哪吒']='哪吒:BAAAKgAECgEIAQAAAA==.',['哲别']='哲别风尘:BAACKgAFFH8WAAIOAAMIqx3AHAALAQAOAAMIqx3AHAALAQAqAAQKfysAAg4ACAhjH0ISAEECAA4ACAhjH0ISAEECAAAA.',['唯一']='唯一一:BAAAKgAECgcIEAAAAA==.',['囗他']='囗他:BAACKgAFFH8ZAAMXAAQIqh2HAwAXAQAXAAMIhSCHAwAXAQAYAAEIJRocJgBmAAAqAAQKfyIAAhcACAh5HDYGACwCABcACAh5HDYGACwCAAAA.',['国宝']='国宝:BAAAKgAFFAQIBAAAAA==.',['圣骑']='圣骑牛:BAAAKgAFFAEIAQAAAA==.',['塔里']='塔里克丶:BAAAKgAECggICwAAAA==.',['夕相']='夕相待:BAAAKgAFFAQIBAABKgAFFAgIDAAGAHMZAA==.',['大寒']='大寒:BAAAKgADCggICAAAAA==.',['大橘']='大橘为重丶:BAAAKgAECgEIAQAAAA==.',['大领']='大领主提里奥:BAAAKgADCgUIBQAAAA==.',['天行']='天行客:BAABKgAECn8ZAAQGAAcIvQ+nYwAvAQAGAAcIvQ+nYwAvAQAVAAcIxQ5DNQAYAQAZAAEIAACeHgAAAAAAAA==.',['太阳']='太阳狩猎者:BAAAKgAECgcIEgAAAA==.',['头发']='头发丝儿:BAAAKgAECggICAAAAA==.',['奈文']='奈文魔尔:BAAAKgADCggIEQAAAA==.',['奔放']='奔放的猫头鹰:BAAAKgADCgUIBQAAAA==.奔放的蜗牛:BAAAKgADCgEIAQAAAA==.',['奥术']='奥术编织:BAAAKgAFFAUIBAAAAA==.',['奶茶']='奶茶豬:BAAAKgADCgYIBgAAAA==.',['妈咪']='妈咪妈咪哄:BAAAKgADCgIIAgAAAA==.',['娜美']='娜美彡:BAAAKgAECgcICwAAAA==.',['孤单']='孤单依然:BAAAKgADCggICAAAAA==.',['宇智']='宇智波丿乱射:BAAAKgADCgIIAgAAAA==.',['宝可']='宝可梦上啊:BAAAKgAECggICQAAAA==.',['宫洺']='宫洺昊:BAABKgAFFH8MAAIYAAYIXhx/CgCAAQAYAAYIXhx/CgCAAQAAAA==.',['寒冰']='寒冰王座:BAAAKgAECgUICQAAAA==.',['寒花']='寒花:BAAAKgAFFAEIAQAAAA==.',['寒霜']='寒霜夜雨:BAAAKgADCgYIBgAAAA==.',['小嘴']='小嘴亲亲:BAAAKgAECgEIAQAAAA==.',['小坨']='小坨坨儿:BAACKgAFFH8JAAIOAAIIuRGXHgB+AAAOAAIIuRGXHgB+AAAqAAQKfxoAAg4ACAgwFlsjAL4BAA4ACAgwFlsjAL4BAAAA.',['小孙']='小孙的脚毛:BAAAKgAFFAQIBAAAAA==.',['小梨']='小梨:BAAAKgAECgIIAgAAAA==.',['小程']='小程:BAACKgAFFH8kAAIJAAYIix2HAgC6AQAJAAYIix2HAgC6AQAqAAQKfxgAAgkACAhBI2wtAGoCAAkACAhBI2wtAGoCAAAA.',['小腿']='小腿肚儿:BAABKgAECn8TAAMTAAgIRQnKGQDzAAATAAcI7wjKGQDzAAAWAAgI7AiFKADZAAAAAA==.',['少生']='少生气多喝水:BAAAKgAECgQIBAAAAA==.',['尛辉']='尛辉:BAABKgAFFH8IAAIFAAYIlQ/rAwBgAQAFAAYIlQ/rAwBgAQAAAA==.',['山岚']='山岚:BAACKgAFFH8wAAQCAAgIDiNFAQBEAQABAAcILCBGCQD4AQACAAUI4yVFAQBEAQAUAAII1yXoHQBsAAAqAAQKf00ABAIACAglJi4HAAACAAIABgjFIS4HAAACAAEABwgTJakYAOEBABQABQjgIAQnAGQBAAAA.',['巜丷']='巜丷尐黑灬:BAABKgAFFH8GAAIBAAMIKw5SLwCwAAABAAMIKw5SLwCwAAAAAA==.',['希徳']='希徳嘞丶:BAAAKgAFFAIIAgAAAA==.',['帖拉']='帖拉所翼朵:BAACKgAFFH8kAAMGAAUIsSDvCAAnAQAGAAUIsSDvCAAnAQAVAAIIURQQFwB/AAAqAAQKfzsAAwYACAiPJsoBABEDAAYACAiPJsoBABEDABUABwiFGnsuAGsBAAEqAAUUCAgdAAgAHyIA.',['幽靈']='幽靈猎:BAAAKgADCggICAAAAA==.',['庐山']='庐山升龍霸:BAABKgAFFH8GAAIaAAYIzw/lCQDuAAAaAAYIzw/lCQDuAAAAAA==.',['弋利']='弋利丹:BAABKgAFFH8GAAIKAAYIzQhjEAAtAQAKAAYIzQhjEAAtAQAAAA==.',['德国']='德国小蠊:BAAAKgADCgEIAQAAAA==.',['快乐']='快乐牌刀片:BAAAKgAFFAYIAgAAAA==.',['念丶']='念丶:BAAAKgADCggICAAAAA==.',['怒风']='怒风丶加里奥:BAAAKgADCgUIBQAAAA==.',['恶魔']='恶魔城冥王:BAABKgAFFH8FAAIGAAMI2gj2LQB6AAAGAAMI2gj2LQB6AAAAAA==.恶魔城阎王:BAAAKgAECgcIDQAAAA==.',['愤怒']='愤怒的绿皮儿:BAACKgAFFH8FAAIQAAIIJRZIDgCpAAAQAAIIJRZIDgCpAAAqAAQKfxsAAhAACAhhHeMPAD0CABAACAhhHeMPAD0CAAAA.愤怒的辣条:BAAAKgAECgcIBwAAAA==.愤怒的霜刃:BAAAKgAECggICAAAAA==.',['我秦']='我秦始皇打钱:BAAAKgADCggICAAAAA==.',['我菜']='我菜少拉点:BAAAKgAFFAgIAQAAAA==.',['我要']='我要猎艳:BAABKgAFFH8MAAIbAAYIGhHsGAA1AQAbAAYIGhHsGAA1AQAAAA==.',['拓真']='拓真三:BAAAKgAFFAQIAgAAAA==.拓真二:BAABKgAFFH8GAAIOAAYIDBvoDACKAQAOAAYIDBvoDACKAQAAAA==.',['指甲']='指甲盖儿:BAACKgAFFH8JAAIJAAQIqBg9TQDVAAAJAAQIqBg9TQDVAAAqAAQKfywAAgkACAj0ILoMAIACAAkACAj0ILoMAIACAAAA.',['挽亽']='挽亽歌:BAAAKgADCggICAAAAA==.',['故人']='故人:BAAAKgAECgIIAgAAAA==.',['斯大']='斯大箖丶:BAAAKgAECgUIBgAAAA==.',['於菟']='於菟:BAABKgAFFH8GAAIJAAYIURkXEQCMAQAJAAYIURkXEQCMAQAAAA==.',['无形']='无形无忌:BAAAKgAECgYICQAAAA==.',['无忧']='无忧醑:BAAAKgAECgIIAgAAAA==.',['无数']='无数梦境:BAABKgAECn8gAAIWAAgI9CICDgCLAgAWAAgI9CICDgCLAgAAAA==.',['时风']='时风曰:BAACKgAFFH8YAAIJAAMIQRz6PQD3AAAJAAMIQRz6PQD3AAAqAAQKfyAAAwkACAiPFsNpAMYBAAkABwiUGcNpAMYBABwAAQhwBBJqABEAAAAA.',['星陨']='星陨丶逐日者:BAABKgAECn8UAAINAAcIehBJSwBUAQANAAcIehBJSwBUAQAAAA==.',['星雨']='星雨:BAAAKgAFFAEIAQAAAA==.',['晓一']='晓一:BAAAKgAECgUIBQAAAA==.',['晓芮']='晓芮丶:BAABKgAFFH8HAAMcAAcIDQCrLwAVAAAcAAYIEACrLwAVAAAJAAEIAAAAAAAAAAAAAA==.',['普莉']='普莉希拉:BAACKgAFFH8YAAIdAAMIaBUuBQDMAAAdAAMIaBUuBQDMAAAqAAQKfxQAAh0ACAgICHgTACABAB0ACAgICHgTACABAAAA.',['晴天']='晴天有雲:BAAAKgAECgEIAQAAAA==.',['暗夜']='暗夜小猎手:BAAAKgAECgcIEwAAAA==.',['暴力']='暴力黑风:BAABKgAFFH8FAAIRAAQI0hvwDQADAQARAAQI0hvwDQADAQAAAA==.',['暴走']='暴走小妞:BAABKgAFFH8MAAIJAAQIaCXLCwAmAQAJAAQIaCXLCwAmAQAAAA==.',['月光']='月光白灬琉璃:BAAAKgAECgMIAwAAAA==.',['月沧']='月沧溟:BAAAKgAECgMIAwAAAA==.',['木头']='木头懒人:BAAAKgADCggIBwAAAA==.木头懒人丶:BAAAKgAECgQIBQAAAA==.',['来份']='来份豆腐脑:BAAAKgAECgIIAgAAAA==.',['来广']='来广营包打听:BAABKgAFFH8MAAIbAAgIzhI9BgAtAgAbAAgIzhI9BgAtAgAAAA==.',['林梦']='林梦宛兮:BAAAKgADCgYICQAAAA==.',['果冻']='果冻布丁:BAABKgAFFH8XAAMVAAgIFB3FAQBwAgAVAAgIFB3FAQBwAgAGAAYIaCUkCAAbAgAAAA==.',['柒先']='柒先森:BAAAKgAECgQIBAAAAA==.',['柴门']='柴门暖暖:BAAAKgAECgEIAQAAAA==.',['核桃']='核桃露:BAABKgAFFH8IAAIJAAgInBQHCQAZAgAJAAgInBQHCQAZAgAAAA==.核桃露露:BAAAKgAECgQIBgAAAA==.',['梅小']='梅小赖児:BAABKgAFFH8KAAIeAAQIagrsGADBAAAeAAQIagrsGADBAAABKgAFFAgICAAeALsbAA==.',['椛逝']='椛逝灬花花:BAABKgAFFH8GAAIBAAYIxBVWFgBRAQABAAYIxBVWFgBRAQAAAA==.',['楠木']='楠木之灵:BAABKgAFFH8GAAIEAAYIFAdwHAA7AQAEAAYIFAdwHAA7AQAAAA==.',['極智']='極智的雅痞:BAAAKgADCgcIBwAAAA==.',['武先']='武先生:BAAAKgADCgEIAQAAAA==.',['氤氲']='氤氲之雾:BAAAKgAFFAEIAQAAAA==.',['氨基']='氨基酸:BAAAKgAECgYIBwAAAA==.',['沙漠']='沙漠之虎:BAAAKgAECggICQAAAA==.',['没事']='没事的:BAABKgAFFH8GAAIfAAQITAj5FwCSAAAfAAQITAj5FwCSAAAAAA==.',['法丨']='法丨官:BAABKgAFFH8HAAMVAAQIrhY0GwDIAAAVAAQIrhY0GwDIAAAGAAMIfRpYSgCIAAAAAA==.',['泽菲']='泽菲兰:BAAAKgAECgcIBwAAAA==.',['浮生']='浮生辛诺:BAABKgAFFH8IAAIFAAMI/RO8AwDWAAAFAAMI/RO8AwDWAAAAAA==.',['海洋']='海洋:BAAAKgADCgMIAwAAAA==.',['消逝']='消逝的温柔:BAAAKgAECgUIBgAAAA==.',['淡忘']='淡忘星宇:BAABKgAFFH8FAAIFAAII+AmTBgCGAAAFAAII+AmTBgCGAAAAAA==.淡忘星雨:BAABKgAFFH8KAAIFAAMIpiQpBQAsAQAFAAMIpiQpBQAsAQAAAA==.',['混乱']='混乱风暴:BAAAKgAECgMIAQAAAA==.',['渣男']='渣男:BAAAKgADCggICAAAAA==.',['溜溜']='溜溜球:BAAAKgAFFAcIAgAAAA==.',['灬魑']='灬魑魅魍魉:BAAAKgAECgUIBQAAAA==.',['灰烬']='灰烬使者丶:BAAAKgAECgYICgAAAA==.',['炽热']='炽热之辉:BAABKgAFFH8GAAIJAAYIDBo2HQB+AQAJAAYIDBo2HQB+AQAAAA==.',['热情']='热情的风斗:BAACKgAFFH8LAAIKAAMIlgzyGgDZAAAKAAMIlgzyGgDZAAAqAAQKfxgAAgoACAiHF/47ALkBAAoACAiHF/47ALkBAAAA.',['熊宝']='熊宝宝菁菁:BAAAKgADCgMIAwAAAA==.',['熙汶']='熙汶:BAAAKgAFFAMIAwAAAA==.',['爱射']='爱射不射:BAAAKgADCggICAAAAA==.',['特朗']='特朗德尔丶:BAAAKgAFFAMIAwAAAA==.',['狐狸']='狐狸不是妖:BAAAKgADCggICAAAAA==.',['猴哥']='猴哥:BAAAKgAFFAMIAwAAAA==.',['猴子']='猴子:BAACKgAFFH8LAAIbAAYI/hQoFwDWAAAbAAYI/hQoFwDWAAAqAAQKfxUAAxsACAgtF4lsAG0BABsACAhHE4lsAG0BAA4AAggTGPBmAI0AAAAA.',['玉轩']='玉轩:BAABKgAFFH8QAAIbAAMIjg8pNQC/AAAbAAMIjg8pNQC/AAAAAA==.',['琉璃']='琉璃丶人来疯:BAAAKgAFFAMIBAAAAA==.琉璃丶瀑岚:BAAAKgAECgMIAwAAAA==.琉璃丶筱杺:BAAAKgAECgYIDAAAAA==.',['瑞穆']='瑞穆:BAAAKgAECgQIBAAAAA==.',['璀璨']='璀璨丶光明:BAAAKgAECgMIAwAAAA==.璀璨之猎:BAABKgAECn8XAAIbAAgIyx0sIAA+AgAbAAgIyx0sIAA+AgAAAA==.',['甜馨']='甜馨小屋:BAAAKgADCgEIAQAAAA==.',['白发']='白发蕾丝:BAAAKgAECgQIBgAAAA==.',['盘头']='盘头大姨:BAAAKgAECgUICAAAAA==.',['目湿']='目湿:BAAAKgADCgIIAgAAAA==.',['碳烤']='碳烤鹌鹑:BAACKgAFFH8cAAMVAAQI/CDnBAArAQAVAAQI/CDnBAArAQAGAAIIggfmUQBvAAAqAAQKfyMAAxUACAhJHnMNAGQCABUACAhJHnMNAGQCABkABQgwEGsnAK4AAAAA.',['祢豆']='祢豆子:BAAAKgAECggIEQAAAA==.',['禁忌']='禁忌热血:BAAAKgAECggIEgAAAA==.',['离洛']='离洛流尘:BAAAKgAECgIIAgAAAA==.',['第二']='第二套广播:BAAAKgAECgMIAwAAAA==.',['終極']='終極灬大錶姐:BAAAKgAFFAQIBAAAAA==.',['红丶']='红丶豆丶泥:BAABKgAFFH8GAAIOAAYIuguHGwASAQAOAAYIuguHGwASAQAAAA==.',['红的']='红的发紫:BAAAKgADCgMIBAAAAA==.',['纪律']='纪律:BAAAKgADCggIDAAAAA==.',['纪念']='纪念冷血毕爷:BAAAKgAECggIAwABKgAFFAgIBgASAKsLAA==.',['给我']='给我一个胶带:BAABKgAFFH8FAAIYAAQIKxazBQBSAQAYAAQIKxazBQBSAQAAAA==.给我十块:BAAAKgAFFAYIBAAAAA==.',['维多']='维多莉加:BAAAKgADCgEIAQAAAA==.',['羊肉']='羊肉涮火锅:BAAAKgADCggICAAAAA==.',['義丶']='義丶庇佑羽翼:BAAAKgAECgUIBAAAAA==.',['老弓']='老弓:BAABKgAFFH8UAAMOAAgIzhwgBgALAgAOAAgIzhwgBgALAgAbAAQIOAKjTQBzAAAAAA==.',['肥猫']='肥猫先生:BAAAKgAECgcIDAAAAA==.',['胡力']='胡力撒:BAABKgAFFH8GAAIeAAMIcxG2GgChAAAeAAMIcxG2GgChAAAAAA==.',['自由']='自由行走的葩:BAAAKgAECgQICQAAAA==.',['艾利']='艾利桑徳:BAAAKgADCggICAAAAA==.',['艾达']='艾达微光:BAAAKgAECgcICAAAAA==.',['芒果']='芒果爆爆豆:BAAAKgAFFAYIAgAAAA==.',['花葬']='花葬风小泪:BAAAKgAECgIIAgAAAA==.',['苏格']='苏格兰乄逐风:BAAAKgAECgEIAQAAAA==.',['英普']='英普瑞斯:BAABKgAFFH8OAAMJAAYIkx34EgAKAQAcAAYInBvvCgBKAQAJAAQIjRv4EgAKAQABKgAFFAgIBAAPAAAAAA==.',['莪迷']='莪迷糊:BAAAKgAFFAIIBAAAAA==.',['莹玉']='莹玉:BAAAKgADCggICAAAAA==.',['蒓磍']='蒓磍閙:BAAAKgADCggICAAAAA==.',['蒙牛']='蒙牛很萌:BAAAKgADCgEIAQAAAA==.',['蔓蔓']='蔓蔓:BAAAKgADCggICgAAAA==.',['薹籣']='薹籣悳:BAABKgAFFH8GAAIGAAYInQ1CGQBPAQAGAAYInQ1CGQBPAQAAAA==.',['蠢蠢']='蠢蠢欲动:BAACKgAFFH8LAAIEAAQIlhVRIACjAAAEAAQIlhVRIACjAAAqAAQKfxkAAwQACAiNG8I4AM4BAAQABgi3IMI4AM4BAB8ACAh9ElglAGABAAAA.',['血月']='血月:BAABKgAECn8yAAMJAAgIMCBdJwBiAgAJAAgIMCBdJwBiAgAcAAEI+ANLYAAMAAAAAA==.',['血色']='血色未来:BAAAKgAECgYIDQAAAA==.',['衣裳']='衣裳湿半:BAAAKgAFFAMIAwAAAA==.',['西域']='西域曼陀罗:BAAAKgAECgQIBwAAAA==.',['西格']='西格玛:BAACKgAFFH8YAAMRAAMIUx5lFgAHAQARAAMIqx1lFgAHAQAQAAMIeh0hEwDrAAAqAAQKfxkAAxAACAieHsMSACICABAACAjIHcMSACICABEABQiKGXxRAMcAAAAA.',['要啥']='要啥嗜血:BAAAKgAECgQIBAAAAA==.',['诗人']='诗人哈迪斯:BAAAKgAECgQIBAAAAA==.',['请叫']='请叫我高大尚:BAAAKgAECgMIAwAAAA==.',['赝品']='赝品丶伪娘:BAAAKgADCgYIBgAAAA==.',['赤斧']='赤斧布洛克斯:BAABKgAFFH8KAAMgAAYIxCC+BADAAQAgAAYIxCC+BADAAQAeAAQIlw3pNQCmAAAAAA==.',['超燃']='超燃冲压:BAABKgAECn8VAAIeAAgI9BdGKQDnAQAeAAgI9BdGKQDnAQAAAA==.',['超级']='超级嘵呱子:BAAAKgAFFAIIAgAAAA==.',['超越']='超越宋丹丹丶:BAAAKgADCgEIAgABKgAFFAgIEAAMAFsKAA==.',['踏着']='踏着时间长河:BAAAKgADCgEIAQAAAA==.',['逆潮']='逆潮丨小崔:BAAAKgAECgUICgAAAA==.',['逆转']='逆转的小夜曲:BAAAKgADCgcICgAAAA==.',['逍遥']='逍遥哥:BAAAKgAFFAgIBAAAAA==.',['遇见']='遇见我是福气:BAABKgAECn8gAAMGAAgIzRVeEwDHAQAGAAgIzRVeEwDHAQAVAAgIGBD/KwBNAQAAAA==.',['邪恶']='邪恶灬召唤:BAAAKgADCggICAAAAA==.',['野山']='野山槮:BAAAKgADCggICAAAAA==.',['钢炮']='钢炮儿:BAAAKgAFFAYIBAAAAA==.',['铁板']='铁板烧橘子:BAABKgAFFH8TAAMbAAMINBvoJgDqAAAbAAMINBvoJgDqAAAOAAIIIhL3PwB6AAAAAA==.铁板烧葡萄:BAAAKgAFFAMIAwABKgAFFAMIEwAbADQbAA==.',['铃鹿']='铃鹿:BAACKgAFFH8qAAISAAUIDSFCAgBAAQASAAUIDSFCAgBAAQAqAAQKfyUAAhIACAgRIqQIAJoCABIACAgRIqQIAJoCAAAA.',['银翼']='银翼之龙:BAAAKgADCgYIBgAAAA==.',['锁甲']='锁甲收集者:BAABKgAFFH8FAAIeAAQIKxDlNACpAAAeAAQIKxDlNACpAAAAAA==.',['阳光']='阳光下丶影子:BAABKgAFFH8IAAIOAAYIDhziDwBoAQAOAAYIDhziDwBoAQAAAA==.',['阿祖']='阿祖快收手:BAABKgAFFH8IAAIBAAgIDBWdBQAcAgABAAgIDBWdBQAcAgAAAA==.',['随机']='随机摩卡卡:BAABKgAFFH8GAAIDAAUIehEQDwBgAQADAAUIehEQDwBgAQAAAA==.',['雪匕']='雪匕爱灰鳞:BAAAKgAFFAQIBAAAAA==.',['雷炎']='雷炎蛮牛:BAAAKgADCgQIBQAAAA==.',['霸天']='霸天雷:BAAAKgAECgIIBAAAAA==.',['青丝']='青丝蘸白雪:BAAAKgAFFAYIBAAAAA==.',['青笋']='青笋:BAACKgAFFH8WAAIEAAQIvxo3DgABAQAEAAQIvxo3DgABAQAqAAQKfykAAgQACAjxIDkfAEcCAAQACAjxIDkfAEcCAAAA.',['风丶']='风丶魂:BAAAKgAFFAQIBAAAAA==.',['馄饨']='馄饨骑士:BAAAKgADCgIIAgAAAA==.',['马吉']='马吉纳丨狩魂:BAAAKgAECggICAAAAA==.',['高手']='高手:BAAAKgAFFAQIBAAAAA==.',['魔瞳']='魔瞳之影:BAAAKgADCggICAAAAA==.',['魔血']='魔血耶律琦:BAAAKgADCgQIBAAAAA==.',['麦克']='麦克斯丶:BAAAKgADCggIEQAAAA==.',['麻辣']='麻辣奶黄包:BAAAKgADCggICAAAAA==.',['黑色']='黑色梦中:BAAAKgADCgIIAgAAAA==.',['黑闇']='黑闇戰魂:BAAAKgAECggICAAAAA==.黑闇魔爵:BAAAKgADCggICAAAAA==.',['黔龙']='黔龙君:BAAAKgAECgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end