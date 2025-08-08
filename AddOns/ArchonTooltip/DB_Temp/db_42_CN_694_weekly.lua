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
 local lookup = {'Priest-Discipline','Priest-Shadow','Mage-Fire','Mage-Frost','DemonHunter-Havoc','Warrior-Fury','Warrior-Arms','Rogue-Assassination','Mage-Ranged','Druid-Balance','Paladin-Protection','DeathKnight-Blood','DeathKnight-Unholy','Priest-Holy','Hunter-Marksmanship','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','Druid-Restoration','Paladin-Retribution','Monk-Mistweaver','DeathKnight-Frost','Warrior-Protection','Unknown-Unknown','Evoker-Devastation','Paladin-Holy','Shaman-Enhancement','Monk-Windwalker','Hunter-Survival','Evoker-Augmentation','Evoker-Preservation','Shaman-Restoration','Mage-Arcane','Druid-Guardian','Shaman-Elemental','Druid-Feral','DemonHunter-Vengeance',}; local provider = {region='CN',realm='摩摩尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Bi='Biubiubu:BAAAKgADCgcIBwAAAA==.',Ca='Carlota:BAABKgAFFH8IAAMBAAgI/BzKAwAdAgABAAcIDx7KAwAdAgACAAEIaQ3dKwBEAAAAAA==.Cattleya:BAABKgAFFH8JAAMDAAYI3hJoDQBiAQADAAUI3hJoDQBiAQAEAAQIfgiWHACfAAAAAA==.',Da='Daimonp:BAAAKgAFFAYIBAAAAA==.',De='Demondemon:BAABKgAFFH8GAAIFAAYIuQzoFgBDAQAFAAYIuQzoFgBDAQAAAA==.',Ev='Evilmaster:BAACKgAFFH8KAAIGAAMIjxUvHwDYAAAGAAMIjxUvHwDYAAAqAAQKfxoAAwYACAjSHMEaADkCAAYACAjSHMEaADkCAAcAAghgFXNpADIAAAAA.Evilputrefy:BAABKgAECn8eAAIIAAgI8xo3DQAyAgAIAAgI8xo3DQAyAgAAAA==.',Fe='Feifei:BAABKgAFFH8GAAIJAAYIRhwAAAAAAAAEAAYIRhwAAAAAAAAAAA==.',Fo='Forrest:BAABKgAFFH8RAAIKAAYIwxw1EACfAQAKAAYIwxw1EACfAQABKgAFFAgIFQALANAYAA==.',Iq='Iqoql:BAAAKgADCgUIBQAAAA==.',Ke='Keaz:BAAAKgAFFAIIAgAAAA==.',La='Labubu:BAAAKgAFFAIIAgAAAA==.',Lu='Lulullulu:BAAAKgAECgIIAgAAAA==.',Ma='Malevirgin:BAAAKgAECggICAAAAA==.Mamen:BAAAKgAFFAQIBAAAAA==.',Mi='Miumiu:BAAAKgADCgEIAQAAAA==.',Mo='Morii:BAAAKgAECggICAAAAA==.',No='Nothingness:BAAAKgAECgQIBAAAAA==.',Re='Reo:BAAAKgAECgYIBgAAAA==.',Rl='Rlo:BAAAKgAECggICAAAAA==.',So='Somnusy:BAAAKgAECgcIDgAAAA==.Soul:BAAAKgAFFAIIAgAAAA==.',St='Starssea:BAAAKgAECgUIBgAAAA==.',Su='Summering:BAAAKgAECgMIAwAAAA==.Sunwarrior:BAAAKgAFFAEIAQAAAA==.',Va='Vaisramana:BAAAKgAECgUIBwAAAA==.',Za='Zalazana:BAABKgAFFH8GAAIMAAYIqhj+CQB0AQAMAAYIqhj+CQB0AQAAAA==.',['一刀']='一刀必死:BAAAKgADCgIIAgAAAA==.',['一戰']='一戰成名:BAABKgAFFH8IAAINAAgIrhxrBgAvAgANAAgIrhxrBgAvAgAAAA==.',['一般']='一般货色:BAAAKgAECggIEQAAAA==.',['一路']='一路烧一路杀:BAAAKgAECgMIBAAAAA==.',['一魅']='一魅婀一:BAAAKgADCgcIBwAAAA==.',['上海']='上海淸纯小妈:BAAAKgAECgYIBwAAAA==.',['下水']='下水道龙妈妈:BAACKgAFFH8IAAIOAAgINwchCQCSAQAOAAgINwchCQCSAQAqAAQKfxkAAg4ACAgSD1M3AD0BAA4ACAgSD1M3AD0BAAAA.',['不万']='不万能:BAAAKgAECgIIAgAAAA==.',['不要']='不要冷冰冰:BAAAKgADCggICAAAAA==.',['丨卸']='丨卸弦丨:BAABKgAFFH8NAAMPAAMI8A33MwCiAAAPAAMI+Av3MwCiAAAQAAIIkQlTUgBkAAAAAA==.',['丨叮']='丨叮铛丨:BAAAKgAECgYIBgAAAA==.',['丨心']='丨心碎灬丨:BAABKgAFFH8GAAIQAAYI7hrSCgCgAQAQAAYI7hrSCgCgAQAAAA==.',['丨方']='丨方丈:BAAAKgADCgQIBAAAAA==.',['丨米']='丨米奈希尓丨:BAAAKgAECgYIDAAAAA==.',['个性']='个性宝贝:BAABKgAFFH8IAAMRAAYIDhF9FgBPAQARAAYIDhF9FgBPAQASAAII2AMmJQBPAAAAAA==.',['丶天']='丶天明丶:BAAAKgADCgUIBQAAAA==.',['丶摩']='丶摩可可丶:BAABKgAFFH8IAAMKAAgIRRWODADOAQAKAAcIzROODADOAQATAAEIJhAsNABIAAAAAA==.',['丶没']='丶没教养的牛:BAAAKgAECgEIAQAAAA==.',['丶西']='丶西卡:BAAAKgADCgQIBAAAAA==.',['丷沧']='丷沧海:BAAAKgAECgIIAgAAAA==.',['丹娜']='丹娜:BAABKgAFFH8HAAIHAAcImwQtCgBpAQAHAAcImwQtCgBpAQAAAA==.',['么么']='么么天玲:BAAAKgAECggIEAAAAA==.',['乌云']='乌云:BAAAKgAECgYIBgAAAA==.',['二十']='二十四夜:BAAAKgADCgYIBgAAAA==.',['二零']='二零:BAAAKgAECgEIAQAAAA==.',['于小']='于小怂:BAAAKgAFFAYIBAAAAA==.',['今夜']='今夜孤星伴月:BAAAKgAECgQIBAAAAA==.今夜繁星映月:BAAAKgAFFAMIAwAAAA==.',['代表']='代表月亮削你:BAABKgAFFH8IAAIUAAQI1g0cVADIAAAUAAQI1g0cVADIAAAAAA==.',['伊莉']='伊莉丝:BAAAKgAECgUIDAABKgAECgcIGAAVALkgAA==.',['伪戒']='伪戒:BAAAKgAFFAMIAwAAAA==.',['你们']='你们全体大耶:BAAAKgAECgYICgAAAA==.',['你吃']='你吃饭了吗:BAAAKgADCggIFAAAAA==.',['你在']='你在我身边丶:BAAAKgAECggICwAAAA==.',['你猜']='你猜呢:BAAAKgAECggICAABKgAFFAgIEwAKAHMfAA==.',['侃爷']='侃爷:BAAAKgAECggIAQAAAA==.',['依然']='依然丨嫒祢:BAAAKgAECgQIBQAAAA==.',['俞瑜']='俞瑜:BAACKgAFFH8GAAIOAAMITxEtJgCqAAAOAAMITxEtJgCqAAAqAAQKfxUABAIACAhrD/YsAHMBAAIACAhrD/YsAHMBAA4ABggGEeZPAPkAAAEAAgjqCwKBAFEAAAAA.',['傲神']='傲神:BAAAKgADCgEIAQAAAA==.',['八月']='八月飞雪:BAAAKgAFFAIIAgAAAA==.',['冠位']='冠位:BAAAKgAFFAgIBAAAAA==.',['冰山']='冰山彩虹:BAAAKgAECggICQAAAA==.',['冰镇']='冰镇草莓酸奶:BAAAKgAFFAIIAgAAAA==.',['凌乱']='凌乱一杀戮:BAABKgAECn8cAAMQAAgI8Q4tdwDyAAAQAAcIMBAtdwDyAAAPAAQIvAl1hgBtAAAAAA==.',['凤凰']='凤凰翎:BAAAKgAFFAYIAgAAAA==.',['初心']='初心:BAAAKgAECgQIBAAAAA==.初心丶:BAAAKgADCgEIAQAAAA==.',['初衷']='初衷:BAAAKgADCgEIAQAAAA==.',['北戰']='北戰丨丶:BAAAKgADCggIEAAAAA==.',['卖萌']='卖萌的老幺:BAABKgAFFH8GAAIGAAYILAXaDAAyAQAGAAYILAXaDAAyAQAAAA==.',['南征']='南征北战:BAACKgAFFH8GAAIFAAMIOAlzOACeAAAFAAMIOAlzOACeAAAqAAQKfyAAAgUACAjKFfMzAN0BAAUACAjKFfMzAN0BAAAA.',['博海']='博海丨之歌:BAAAKgAECgUIBgAAAA==.',['卡雷']='卡雷苟萨丶玲:BAAAKgAFFAIIAgAAAA==.',['叉歪']='叉歪歪:BAABKgAFFH8GAAMNAAYIOxpuJwDxAAANAAQIaiFuJwDxAAAWAAIIcw/vDQCYAAAAAA==.',['双鱼']='双鱼座灬可乐:BAAAKgAECgEIAQAAAA==.',['古灬']='古灬尔灬丹:BAAAKgADCggICAAAAA==.',['叫我']='叫我女王大银:BAAAKgAECgIIAgAAAA==.',['可怜']='可怜的沫沫:BAABKgAFFH8IAAIIAAgI6QSgBgDFAQAIAAgI6QSgBgDFAQAAAA==.',['可爱']='可爱布布:BAAAKgADCgIIAgAAAA==.',['可雕']='可雕之木:BAAAKgAECgQIBAAAAA==.',['右岸']='右岸:BAABKgAECn8UAAIFAAgIxglYVQBQAQAFAAgIxglYVQBQAQAAAA==.',['右手']='右手搓冰棍:BAAAKgADCggICAAAAA==.右手搓圣光:BAAAKgADCggICwAAAA==.',['叶落']='叶落無痕:BAAAKgAFFAQIBAAAAA==.',['吃完']='吃完饭就饿:BAABKgAFFH8JAAMXAAcIYwUsBgDcAAAXAAUIUgUsBgDcAAAGAAQI7wX5JgCxAAAAAA==.',['吉相']='吉相:BAAAKgAECgIIAgAAAA==.',['吹吹']='吹吹乐:BAABKgAFFH8IAAITAAgI5g8rBADJAQATAAgI5g8rBADJAQAAAA==.',['吹老']='吹老湿:BAAAKgAFFAcIBAAAAA==.',['吼娃']='吼娃儿:BAAAKgADCggICAAAAA==.',['咕咕']='咕咕骑士:BAAAKgADCggICAAAAA==.',['咕德']='咕德猫柠:BAABKgAFFH8KAAIKAAYIgx5yEACcAQAKAAYIgx5yEACcAQABKgAFFAgIAgAYAAAAAA==.',['哎比']='哎比利唔:BAAAKgADCggICAAAAA==.',['哘屍']='哘屍灬赱肉:BAAAKgAECggIEQAAAA==.',['哞哞']='哞哞牛:BAABKgAFFH8GAAIKAAYIJQpDHQAyAQAKAAYIJQpDHQAyAQAAAA==.',['哟湿']='哟湿幽盅:BAAAKgAECgIIAwAAAA==.',['哥丶']='哥丶风流倜傥:BAAAKgAECgYICQAAAA==.',['唐伯']='唐伯虎猎风:BAACKgAFFH8FAAMQAAMIvAxiPgBxAAAQAAIIbw1iPgBxAAAPAAIIEw0pKABCAAAqAAQKfyEAAw8ACAj1HDAtAIQBABAABghnIMZXAKkBAA8ABwj7GDAtAIQBAAAA.',['唛兜']='唛兜七枚:BAABKgAFFH8KAAMPAAYIAx13DACRAQAPAAYIdht3DACRAQAQAAQIgxcjLQCgAAAAAA==.',['啤酒']='啤酒仙:BAAAKgAFFAQIBAABKgAFFAgIFgAKALQWAA==.啤酒肚:BAAAKgAECggICwAAAA==.',['喬妮']='喬妮娜灬草性:BAAAKgAECggICgAAAA==.',['嗨弗']='嗨弗雷:BAAAKgAECgYIBgAAAA==.',['嘉德']='嘉德丽雅:BAABKgAFFH8MAAIZAAQIESKzCAAOAQAZAAQIESKzCAAOAQAAAA==.',['国宝']='国宝熊猫:BAAAKgAECggICAAAAA==.',['圣光']='圣光丶裁决灬:BAAAKgADCgcIDgAAAA==.圣光归来:BAAAKgAECgEIAQAAAA==.圣光永渡:BAABKgAECn8pAAMUAAgISReJZgDNAQAUAAgISReJZgDNAQAaAAgIRhGeHQB1AQAAAA==.',['在我']='在我身后冲锋:BAAAKgAECggICAAAAA==.',['坐地']='坐地炮:BAABKgAFFH8IAAIPAAgIxB4QAwB0AgAPAAgIxB4QAwB0AgAAAA==.',['基尔']='基尔:BAABKgAFFH8GAAIMAAYIywzTEwADAQAMAAYIywzTEwADAQABKgAFFAgIIAAMAFUQAA==.',['墓秋']='墓秋:BAABKgAFFH8IAAIEAAQIgBhvFgC8AAAEAAQIgBhvFgC8AAABKgAFFAgIDwAbAC4bAA==.',['增强']='增强萨:BAAAKgAECgEIAQAAAA==.',['墨嶨']='墨嶨:BAABKgAFFH8IAAIPAAgIkA0WCgC1AQAPAAgIkA0WCgC1AQAAAA==.',['壮实']='壮实:BAAAKgAECgUIBgAAAA==.',['复仇']='复仇:BAABKgAFFH8GAAIFAAYIABSEEACBAQAFAAYIABSEEACBAQAAAA==.',['夏天']='夏天的热浪:BAAAKgAFFAQIBAAAAA==.',['夏娃']='夏娃冰梦缘:BAABKgAECn8YAAMQAAgIqSKbEgC0AgAQAAgIqSKbEgC0AgAPAAEISxo6gQBIAAAAAA==.',['夏小']='夏小白:BAABKgAFFH8FAAICAAUIwQUeEAAFAQACAAUIwQUeEAAFAQABKgAFFAgIDgARAPkhAA==.',['外瑞']='外瑞咕德:BAABKgAFFH8GAAIKAAYI5gqeHQAwAQAKAAYI5gqeHQAwAQAAAA==.',['夜深']='夜深人静想你:BAABKgAFFH8GAAIFAAQIuwqZNgCmAAAFAAQIuwqZNgCmAAAAAA==.',['大摩']='大摩:BAAAKgAECggICAAAAA==.',['大智']='大智若魚:BAAAKgAFFAQIBAAAAA==.',['大米']='大米:BAAAKgAECggICAAAAA==.',['大脑']='大脑按摩:BAABKgAFFH8JAAIcAAcIZhWWBgCoAQAcAAcIZhWWBgCoAQAAAA==.',['大麦']='大麦青汁:BAAAKgAFFAMIAwAAAA==.',['天上']='天上往来:BAAAKgADCgMIAwAAAA==.',['天堂']='天堂荣耀:BAAAKgAECgcIEAAAAA==.',['天天']='天天见到你:BAAAKgADCgEIAQAAAA==.',['天明']='天明:BAAAKgAECgIIAgAAAA==.天明丶:BAAAKgADCgYIBgAAAA==.',['天秤']='天秤座童虎:BAABKgAECn8XAAMcAAgIlB3vBABrAgAcAAgIlB3vBABrAgAVAAIIgBSLiABFAAABKgAFFAQIHgAdAMUiAA==.',['天蝎']='天蝎座灬擒獣:BAAAKgAECgUIBQAAAA==.',['太阳']='太阳萌德:BAAAKgADCgQICAABKgAFFAMICwAUAEIjAA==.',['失控']='失控的灵魂:BAABKgAFFH8IAAIVAAgIXBbBBADmAQAVAAgIXBbBBADmAQAAAA==.',['头上']='头上长犄角:BAAAKgAECgUIBgAAAA==.',['奈亞']='奈亞:BAACKgAFFH8HAAINAAMI0gliPACsAAANAAMI0gliPACsAAAqAAQKfxgAAg0ACAg+HlRJAJEBAA0ACAg+HlRJAJEBAAAA.',['奥尔']='奥尔多安:BAAAKgAECgYIBwAAAA==.',['奥格']='奥格罗丶火刃:BAAAKgAECgMIAwAAAA==.',['奶灬']='奶灬小德:BAAAKgADCggICAAAAA==.',['好想']='好想捏捏你:BAAAKgADCgYIBgAAAA==.',['好玩']='好玩爱玩:BAAAKgAFFAEIAQAAAA==.',['妖灬']='妖灬月:BAAAKgAFFAQIBAAAAA==.',['妮尔']='妮尔塔莉:BAAAKgAECgUIBQAAAA==.',['婕婕']='婕婕:BAAAKgAECgUIBQAAAA==.',['安丶']='安丶度丶因:BAAAKgADCgYIBgAAAA==.',['宛若']='宛若星辰:BAABKgAFFH8GAAIOAAYI6Q97CwAUAQAOAAYI6Q97CwAUAQAAAA==.',['宝宝']='宝宝抱抱:BAAAKgADCggIEAAAAA==.',['宝石']='宝石罐头:BAAAKgAECgYIBwAAAA==.',['室女']='室女座释静摩:BAACKgAFFH8cAAMZAAQInyDlFgARAQAZAAQInyDlFgARAQAeAAEIeB0hBABOAAAqAAQKfzEAAxkACAgWIcINAGYCABkACAgWIcINAGYCAB4AAQiNGcMPAEYAAAEqAAUUBAgeAB0AxSIA.',['寒暄']='寒暄:BAAAKgADCggICAAAAA==.',['射手']='射手座格式塔:BAACKgAFFH8eAAMdAAQIxSJoAQAaAQAdAAMI9SBoAQAaAQAPAAQIFhx/FgCuAAAqAAQKf0EABB0ACAjRJLQAAL0CAB0ACAhUJLQAAL0CAA8ACAhGInAQAFMCABAABQjaImQoADcBAAAA.',['小丶']='小丶浣熊:BAAAKgAECgEIAQAAAA==.',['小奶']='小奶狼死哪了:BAAAKgAECgQIBwAAAA==.',['小小']='小小怂:BAAAKgADCggICAAAAA==.小小猎刃:BAAAKgAECggICAAAAA==.',['小损']='小损样儿:BAAAKgAECgYIBgAAAA==.',['小母']='小母龙:BAAAKgAECgQIBAAAAA==.',['小灬']='小灬龙:BAAAKgAECggICAAAAA==.',['小羊']='小羊羔手:BAAAKgAFFAIIAgAAAA==.',['小铭']='小铭铭:BAAAKgAECgYIBgAAAA==.',['少琛']='少琛:BAAAKgAFFAMIAwAAAA==.',['尔非']='尔非鱼:BAABKgAFFH8HAAIUAAcI/R1gDQD6AQAUAAcI/R1gDQD6AQAAAA==.',['尼古']='尼古拉斯凯骑:BAABKgAFFH8LAAIUAAYIEiFwBAB9AQAUAAYIEiFwBAB9AQAAAA==.',['山里']='山里红没有虫:BAAAKgADCgYIBgAAAA==.',['布地']='布地奈德:BAAAKgAECgEIAQAAAA==.',['帅磊']='帅磊磊:BAAAKgAECgMIAwAAAA==.',['希尔']='希尔瓦娜澌:BAAAKgAECgYIDAAAAA==.',['帝国']='帝国桃花剑:BAAAKgAFFAMIAwAAAA==.',['幸福']='幸福乂虎牙:BAAAKgADCggICAAAAA==.',['幽默']='幽默小黄人:BAAAKgAECgIIAgAAAA==.',['开门']='开门大吉:BAAAKgADCggICAAAAA==.',['弈秋']='弈秋丶:BAAAKgAECgEIAQAAAA==.',['弗丶']='弗丶丁:BAABKgAFFH8OAAMLAAUIMxuDCwA/AQALAAUIMxuDCwA/AQAUAAQI3QVgagCXAAABKgAFFAgICAAFAOcMAA==.',['张继']='张继科:BAABKgAECn8WAAMKAAgIHhkvNwDcAQAKAAgIHhkvNwDcAQATAAcIbwc/UADMAAAAAA==.',['影中']='影中幽:BAAAKgADCgUIBQAAAA==.',['影忄']='影忄殇:BAACKgAFFH8KAAIMAAMIswAzJQA3AAAMAAMIswAzJQA3AAAqAAQKfxkAAgwACAiYB2w4AOUAAAwACAiYB2w4AOUAAAAA.',['影月']='影月:BAACKgAFFH8GAAIOAAYIawtLEgAgAQAOAAYIawtLEgAgAQAqAAQKfxgAAg4ACAh7GD8hANcBAA4ACAh7GD8hANcBAAAA.',['影柯']='影柯:BAAAKgAECgcIBwAAAA==.',['德咕']='德咕啦:BAAAKgAECgUIDQAAAA==.',['忧伤']='忧伤的骨头:BAAAKgADCgQIBAAAAA==.',['怡红']='怡红公子:BAAAKgAECgcICwAAAA==.',['怪叔']='怪叔叔坏:BAAAKgADCggICAAAAA==.',['恭喜']='恭喜这个比:BAAAKgAECgUIBwAAAA==.',['恶魔']='恶魔凯德:BAAAKgADCggICAAAAA==.',['悠哉']='悠哉徳:BAAAKgAECgIIAgAAAA==.悠哉德:BAAAKgAECggICwAAAA==.',['悠悠']='悠悠的回忆:BAAAKgAECggICAAAAA==.',['惊鹊']='惊鹊:BAABKgAFFH8GAAMfAAYIyRmCBQDAAAAfAAQINxOCBQDAAAAZAAIItBPDLQB4AAAAAA==.',['憨憨']='憨憨哆哆丶:BAAAKgADCggICAAAAA==.憨憨的小跟班:BAAAKgAECgMIAwAAAA==.',['懒惰']='懒惰:BAAAKgAFFAMIAwAAAA==.',['戀戰']='戀戰:BAACKgAFFH8IAAIRAAgIzBxjAwB9AgARAAgIzBxjAwB9AgAqAAQKfxUAAhEACAggHpANAEUCABEACAggHpANAEUCAAAA.',['我一']='我一个后跳:BAAAKgAECgcICAAAAA==.我一个大跳:BAAAKgAECgcIBwAAAA==.',['我不']='我不吃牛肉:BAAAKgAFFAIIBAAAAA==.',['我爱']='我爱丶娜娜:BAABKgAECn+kAAIQAAYI2SIUQwDtAQAQAAYI2SIUQwDtAQAAAA==.我爱梦之仙子:BAABKgAECn8eAAMRAAgI4weeZQDbAAARAAgIhQaeZQDbAAASAAYIvAcNSwC5AAAAAA==.',['戒怒']='戒怒:BAABKgAFFH8RAAINAAcIvRUECADFAQANAAcIvRUECADFAQAAAA==.',['戒狂']='戒狂:BAAAKgADCggICAAAAA==.',['战争']='战争靈主:BAAAKgADCggIEAAAAA==.',['战歌']='战歌之魂:BAAAKgADCggICAAAAA==.',['战神']='战神飞雪:BAAAKgADCgcIBwAAAA==.',['扎实']='扎实:BAAAKgAECggIDwAAAA==.',['拔毛']='拔毛上膛:BAABKgAFFH8JAAIPAAMINwbnHACGAAAPAAMINwbnHACGAAAAAA==.',['拨皮']='拨皮双子:BAAAKgAECggIEAAAAA==.',['拳脚']='拳脚定十方:BAAAKgAFFAQIBAAAAA==.',['提里']='提里奥丶福叮:BAABKgAFFH8GAAIUAAYI9gwqJgBQAQAUAAYI9gwqJgBQAQAAAA==.',['携秋']='携秋水揽星河:BAABKgAFFH8MAAIgAAYIshXWDQByAQAgAAYIshXWDQByAQABKgAFFAgIDgAgABkfAA==.',['摄政']='摄政王丨羿:BAAAKgAECgcIBwAAAA==.',['摩可']='摩可可:BAABKgAFFH8GAAIQAAQIORUoKgDcAAAQAAQIORUoKgDcAAAAAA==.',['摩柯']='摩柯柯:BAAAKgAFFAIIAgAAAA==.',['擒灬']='擒灬獣:BAAAKgAECgMIAwAAAA==.',['收手']='收手吧阿汤:BAAAKgAECgUIDAAAAA==.',['断角']='断角先生丶:BAAAKgADCgMIAwAAAA==.',['斯嘉']='斯嘉莉:BAAAKgAFFAMIAwAAAA==.',['无效']='无效快速防秃:BAAAKgAFFAgIAgAAAA==.',['无极']='无极:BAABKgAFFH8RAAMHAAQIfwz+DwARAQAHAAQIfwz+DwARAQAGAAII7QXIMQBqAAAAAA==.',['无糖']='无糖美式:BAAAKgAECggICAAAAA==.',['旱稻']='旱稻韭菈:BAAAKgAFFAgIAQAAAA==.',['明前']='明前奶紫:BAAAKgAECgUIBQAAAA==.',['星空']='星空泪痕:BAAAKgAFFAQIBAAAAA==.',['春光']='春光无限好:BAABKgAFFH8IAAMMAAYIDQZiGwDHAAAMAAYIgAViGwDHAAANAAIIeQZZTQBqAAAAAA==.',['昨日']='昨日西风依旧:BAAAKgADCggIDwAAAA==.',['晓法']='晓法:BAABKgAFFH8OAAMEAAUIcxvCBgAkAQAEAAUIcxvCBgAkAQAhAAMI7Qt7OQB8AAAAAA==.',['普罗']='普罗旺斯薰薰:BAAAKgAECgQIBAAAAA==.',['暗血']='暗血虚空:BAAAKgADCggICAAAAA==.',['暗语']='暗语黯刃:BAAAKgAECgQIBAAAAA==.',['暴怒']='暴怒丶:BAABKgAECn8kAAIXAAgIDBPyFQBrAQAXAAgIDBPyFQBrAQAAAA==.',['曉宇']='曉宇:BAACKgAFFH8NAAMiAAMImRMuBwCcAAAiAAMImRMuBwCcAAAKAAEIKAKcPgAvAAAqAAQKfyYABCIACAhREz4VAAQBACIABwjkET4VAAQBABMABghUCpRUALsAAAoABAiJEwKVAJ8AAAAA.',['曹轩']='曹轩宁宁:BAAAKgAFFAMIAwAAAA==.曹轩寜寜:BAAAKgAFFAIIAgAAAA==.',['月夜']='月夜月圆:BAABKgAFFH8GAAIgAAYIcwEOHQAJAQAgAAYIcwEOHQAJAQAAAA==.',['朗姆']='朗姆:BAABKgAFFH8GAAIKAAYI/gb3IAAaAQAKAAYI/gb3IAAaAQAAAA==.',['木木']='木木大魔王:BAABKgAFFH8XAAQbAAgIHiNNAACKAgAbAAgIHiNNAACKAgAgAAQIeRCPNACpAAAjAAIIPBY0GwCiAAAAAA==.',['术出']='术出:BAAAKgAFFAQIBAAAAA==.',['杀戮']='杀戮小萨:BAABKgAECn8WAAIgAAcIdAX6mQCGAAAgAAcIdAX6mQCGAAAAAA==.杀戮德:BAAAKgAECgcICgAAAA==.杀戮死骑:BAABKgAECn8VAAMNAAcI8gNNkQBzAAANAAcI2ANNkQBzAAAMAAQI0QJ6UQAyAAAAAA==.杀戮法爷:BAABKgAECn8cAAIEAAcIFQWedwClAAAEAAcIFQWedwClAAAAAA==.杀戮獣兽:BAAAKgADCgcIBwAAAA==.杀戮骑士:BAABKgAECn8eAAMUAAcIpQTrDQGkAAAUAAcIigTrDQGkAAALAAYI1AI0TgBHAAAAAA==.',['李火']='李火旺:BAAAKgAECgIIAgAAAA==.',['杜尔']='杜尔赞:BAABKgAFFH8MAAIEAAYImRzDAwC6AQAEAAYImRzDAwC6AQAAAA==.',['果汁']='果汁分你一半:BAABKgAFFH8SAAIiAAMI6giCCgBqAAAiAAMI6giCCgBqAAAAAA==.',['柒尐']='柒尐对児:BAAAKgADCgQIBAAAAA==.',['格瑞']='格瑞斯华尔德:BAAAKgADCggICAAAAA==.',['梦之']='梦之魂:BAAAKgADCgYIBgAAAA==.',['梦往']='梦往神游:BAAAKgAECgIIAgAAAA==.',['梦追']='梦追梦:BAACKgAFFH8iAAMhAAUIlQsZKgC6AAAhAAQICA8ZKgC6AAADAAQI/QQ1KwCcAAAqAAQKfzsAAwMACAh6GZktAOsBAAMACAiBF5ktAOsBACEABQjFFJ9CADYBAAAA.',['梦鸡']='梦鸡:BAAAKgADCgQIBAAAAA==.',['森僧']='森僧:BAABKgAFFH8IAAIVAAgIWA1GBgCwAQAVAAgIWA1GBgCwAQAAAA==.',['榴链']='榴链味:BAAAKgAECgEIAQAAAA==.',['欣欣']='欣欣宝宝:BAAAKgAECgUIBQAAAA==.',['欧西']='欧西给欧西给:BAAAKgAFFAIIAgAAAA==.',['死亡']='死亡的终结:BAABKgAFFH8FAAIMAAMIxAjRJwB3AAAMAAMIxAjRJwB3AAABKgAFFAgIBAAYAAAAAA==.',['沉睡']='沉睡:BAAAKgAECgEIAQAAAA==.',['法司']='法司:BAAAKgAECgUIBQAAAA==.',['法天']='法天相地丶:BAAAKgAECgQIBAAAAA==.',['泣洫']='泣洫丶灬:BAAAKgAFFAMIAwAAAA==.',['泰守']='泰守旧茂:BAABKgAFFH8NAAMbAAcI5R19AwAmAgAbAAcI5R19AwAmAgAgAAYIdAFkJwDZAAAAAA==.',['洁盈']='洁盈:BAAAKgAECgYIBgAAAA==.',['活宝']='活宝他姐:BAABKgAECn8bAAIUAAcIIBnWbwC5AQAUAAcIIBnWbwC5AQAAAA==.',['浣纱']='浣纱溪:BAAAKgAECggIDQAAAA==.',['浮云']='浮云沉香丶:BAABKgAECn8TAAMZAAgIEhgiHQDJAQAZAAgIEhgiHQDJAQAfAAMI3wMzIwBcAAAAAA==.',['浮光']='浮光魅影:BAAAKgAECgUIBQAAAA==.',['涅磐']='涅磐涵星:BAAAKgADCggICAAAAA==.',['游魂']='游魂爱哭鬼:BAAAKgADCgEIAQAAAA==.',['滨城']='滨城一一陌璃:BAAAKgAFFAIIAgAAAA==.',['灬奥']='灬奥特曼灬:BAABKgAFFH8MAAIRAAgILxZMBgAMAgARAAgILxZMBgAMAgAAAA==.',['灬妖']='灬妖僧灬:BAAAKgADCggICAAAAA==.灬妖牧灬:BAAAKgAECgcIDQAAAA==.灬妖猎灬:BAAAKgADCgcIBwAAAA==.灬妖萨灬:BAAAKgAECgIIAgAAAA==.灬妖骑灬:BAAAKgAECgQIBAAAAA==.',['灬腾']='灬腾云蛟日灬:BAABKgAFFH8GAAMaAAQIvw1lEQC3AAAaAAQIvw1lEQC3AAAUAAIILAZSRwBvAAAAAA==.',['灵魂']='灵魂丶冰糖:BAAAKgAFFAYIBgABKgAFFAgIBAAYAAAAAA==.灵魂丶尼克:BAAAKgAECgcIBwAAAA==.灵魂丶彼岸:BAABKgAFFH8MAAIQAAQIEx0AHADlAAAQAAQIEx0AHADlAAAAAA==.灵魂丶碎裂:BAABKgAFFH8GAAIMAAYI/AzuFAD6AAAMAAYI/AzuFAD6AAABKgAFFAgIIAAMAFUQAA==.',['烟鬼']='烟鬼:BAAAKgAECgIIAgAAAA==.',['熊朵']='熊朵朵:BAABKgAFFH8SAAMPAAYIGhDADQAhAQAPAAYIfAzADQAhAQAQAAQIcRBoIADWAAABKgAFFAgILQAQAMMeAA==.',['熊猫']='熊猫灬小妞:BAACKgAFFH8IAAMgAAYISRLqFwAiAQAgAAQIlA7qFwAiAQAjAAIITAT/FgBeAAAqAAQKfyYAAyMACAhXEdYvAIgBACMACAhXEdYvAIgBACAAAQjZAs3FAB0AAAAA.',['熙仔']='熙仔:BAAAKgAFFAYIBAAAAA==.',['爆走']='爆走的丸子:BAABKgAFFH8LAAMBAAQI3SViDQBAAQABAAQI3SViDQBAAQAOAAMIQxYCIADIAAAAAA==.',['爱你']='爱你老婆大人:BAAAKgADCgcIBwAAAA==.',['爱吃']='爱吃肉的胖达:BAAAKgAECgEIAQAAAA==.爱吃西红柿:BAAAKgADCgUIBQAAAA==.',['爱清']='爱清:BAAAKgADCgIIAgAAAA==.',['牛奶']='牛奶煮萝莉:BAAAKgAECgEIAQAAAA==.',['牛德']='牛德收割机:BAACKgAFFH8HAAIkAAMIKw4ZBwDKAAAkAAMIKw4ZBwDKAAAqAAQKfyMAAiQACAg6F7gMAOQBACQACAg6F7gMAOQBAAAA.',['牛油']='牛油果壳:BAAAKgAECgQIBAAAAA==.',['牛牛']='牛牛嗜血:BAABKgAFFH8cAAMgAAMIVyJpHgACAQAgAAMIVyJpHgACAQAjAAMIRAPMHQCKAAAAAA==.',['狐娘']='狐娘收割机:BAAAKgADCgMIAwAAAA==.',['狸狸']='狸狸原上跑:BAACKgAFFH8IAAIgAAYICBBUEgBCAQAgAAYICBBUEgBCAQAqAAQKfxYAAiAABwj2CgBzAOkAACAABwj2CgBzAOkAAAAA.',['猫已']='猫已经肥了:BAACKgAFFH8QAAIcAAMIgBzICgDnAAAcAAMIgBzICgDnAAAqAAQKfx4AAhwACAhCIEANAIECABwACAhCIEANAIECAAAA.',['王不']='王不丨留行:BAAAKgAECgYIBgAAAA==.',['玛法']='玛法丨里奥:BAAAKgAFFAIIAgAAAA==.',['玩闹']='玩闹小裤衩:BAAAKgAECgMIAwAAAA==.',['玲嘟']='玲嘟豆:BAAAKgADCgcIBwAAAA==.',['瑾年']='瑾年丨七章:BAABKgAECn8bAAIUAAgIeCZHBgABAwAUAAgIeCZHBgABAwABKgAFFAgIEAALAMANAA==.',['瓦莉']='瓦莉拉妲己:BAAAKgAECgQIBAAAAA==.',['田德']='田德莉娜:BAAAKgADCgEIAQAAAA==.',['疯狂']='疯狂丹丹:BAAAKgADCgYIBgAAAA==.',['疯魔']='疯魔:BAAAKgADCgYIBgAAAA==.',['瘸子']='瘸子别跑:BAABKgAFFH8GAAIKAAYIUBkSFwBgAQAKAAYIUBkSFwBgAQABKgAFFAgIEAAQACYbAA==.',['白白']='白白更健康:BAAAKgAECgEIAQAAAA==.',['白羊']='白羊丶:BAABKgAFFH8GAAIFAAMIFwvPMwCxAAAFAAMIFwvPMwCxAAAAAA==.',['白胖']='白胖儿丸子头:BAAAKgADCggICwAAAA==.',['白色']='白色:BAAAKgADCggICAAAAA==.',['白驹']='白驹过隙:BAAAKgAECgEIAQAAAA==.',['百香']='百香果啤酒:BAAAKgADCggICAAAAA==.',['相沢']='相沢南:BAAAKgADCgEIAQAAAA==.',['瞅你']='瞅你妹阿:BAAAKgAECgcICQAAAA==.',['瞬发']='瞬发炉石:BAAAKgAECgYIBgAAAA==.',['祠梦']='祠梦余生:BAABKgAFFH8FAAIOAAMIeCBnFgACAQAOAAMIeCBnFgACAQAAAA==.',['福禄']='福禄娃:BAAAKgADCggICQAAAA==.',['空空']='空空:BAABKgAFFH8GAAINAAYIgBO3GABYAQANAAYIgBO3GABYAQAAAA==.',['竖丶']='竖丶:BAAAKgAFFAQIBAAAAA==.',['竖二']='竖二:BAAAKgAECggICAAAAA==.',['童话']='童话你不懂:BAAAKgADCgYIBgAAAA==.',['笑的']='笑的比花甜:BAAAKgAECgUIBQAAAA==.',['箭破']='箭破苍穹:BAAAKgAFFAQIBAABKgAFFAgIEwAQAOUdAA==.',['精灵']='精灵:BAAAKgAECgEIAQAAAA==.',['精神']='精神丶小妹:BAAAKgADCgQIBAAAAA==.',['紫影']='紫影:BAAAKgAECggIDAAAAA==.',['红粉']='红粉头子:BAAAKgAECgYIBgAAAA==.',['红衣']='红衣女孩吖:BAAAKgAECgUIBQAAAA==.',['绵鱼']='绵鱼:BAAAKgAECgcICAAAAA==.',['老婆']='老婆最好:BAAAKgAECggIDQAAAA==.',['老炮']='老炮:BAABKgAECn8XAAIgAAcIYh2+OwCXAQAgAAcIYh2+OwCXAQAAAA==.',['聖光']='聖光小怪獸:BAABKgAFFH8LAAIUAAYIJR0cIQBqAQAUAAYIJR0cIQBqAQAAAA==.',['胡萝']='胡萝卜的秋天:BAAAKgAFFAIIAgAAAA==.',['脉八']='脉八鹤:BAAAKgAECggICAAAAA==.',['自然']='自然之力:BAAAKgAFFAIIAgAAAA==.自然风光:BAAAKgAECggIEQAAAA==.',['自闭']='自闭的裂魂:BAAAKgADCgQIBAAAAA==.',['至尊']='至尊宝:BAAAKgAFFAQIBAAAAA==.',['舞心']='舞心恋战:BAAAKgAECggICAAAAA==.',['芭比']='芭比:BAAAKgAECggIEAAAAA==.',['芭芭']='芭芭拉:BAAAKgAFFAIIAgAAAA==.',['花裤']='花裤衩之传说:BAAAKgAECgIIAgAAAA==.',['花间']='花间意:BAAAKgADCgIIAgAAAA==.',['若耶']='若耶溪:BAAAKgAFFAQIBAAAAA==.',['苦瓜']='苦瓜大王:BAAAKgAECgYICAAAAA==.',['英特']='英特纳雄奈尔:BAAAKgAECgUIBgAAAA==.',['茉莉']='茉莉糖糖:BAAAKgADCgUIBQAAAA==.',['荒天']='荒天帝:BAAAKgAFFAgIBAAAAA==.',['荣耀']='荣耀之箭:BAABKgAFFH8FAAIPAAUI0BQNCgB+AQAPAAUI0BQNCgB+AQAAAA==.',['荷尖']='荷尖翘呀翘:BAACKgAFFH8OAAMhAAUIow5PLACyAAAhAAQISQ9PLACyAAAEAAEIsgwJFQBGAAAqAAQKfxoAAwQACAjLGH0+AHABAAQACAhbFX0+AHABACEABwh8EzQ+AEoBAAAA.',['莫莫']='莫莫灬:BAAAKgAECgcIBwAAAA==.',['莱昂']='莱昂纳多:BAAAKgAECggIEQAAAA==.',['菩提']='菩提小精灵:BAACKgAFFH8FAAIUAAQIzhkFVgDEAAAUAAQIzhkFVgDEAAAqAAQKfzEAAxQACAglJM8UAMQCABQACAglJM8UAMQCAAsAAQhlBDtqABAAAAAA.菩提精灵:BAABKgAECn8WAAMKAAgIpRxrHQBZAgAKAAgIpRxrHQBZAgATAAcIKxjuJQCfAQAAAA==.',['菳牛']='菳牛座奥克斯:BAAAKgADCgIIAgAAAA==.',['萨小']='萨小满:BAAAKgAECggICAAAAA==.',['萨满']='萨满丶贺:BAAAKgAECgMIAwAAAA==.',['萨爹']='萨爹:BAAAKgADCggIDAAAAA==.',['萨瓦']='萨瓦多獠牙:BAAAKgADCggICAAAAA==.',['萨路']='萨路法尔:BAAAKgADCgEIAQABKgAFFAMIEwAgADQNAA==.',['落单']='落单被抡:BAAAKgAFFAIIAgAAAA==.',['落誮']='落誮冇意:BAABKgAFFH8GAAIUAAYI9R3kEQDOAQAUAAYI9R3kEQDOAQAAAA==.',['虚空']='虚空大曦:BAAAKgADCgIIAgAAAA==.',['蛮牛']='蛮牛:BAABKgAFFH8ZAAIXAAQIggKrEwBfAAAXAAQIggKrEwBfAAAAAA==.',['裴珠']='裴珠泫:BAABKgAFFH8MAAMTAAYITxZqCgBgAQATAAYITxZqCgBgAQAKAAQICx7jCwAQAQAAAA==.',['西蒙']='西蒙德:BAAAKgADCgEIAQAAAA==.',['说爱']='说爱你:BAAAKgAECgcIBwAAAA==.',['诺坎']='诺坎普之王:BAAAKgAECgEIAQAAAA==.',['谷唯']='谷唯一:BAABKgAFFH8OAAINAAgILw14CQD0AQANAAgILw14CQD0AQAAAA==.',['貓貓']='貓貓雨:BAAAKgAFFAEIAQAAAA==.',['贰爷']='贰爷:BAAAKgAECgYIBwAAAA==.',['贼么']='贼么西:BAAAKgADCgMIAwAAAA==.',['贼低']='贼低調:BAAAKgAECgYICwAAAA==.',['赟大']='赟大爷:BAABKgAFFH8JAAIPAAMIZwh7OQCRAAAPAAMIZwh7OQCRAAAAAA==.',['赟小']='赟小爷:BAAAKgAFFAEIAQAAAA==.赟小狐:BAAAKgAFFAEIAQAAAA==.',['赤色']='赤色要塞:BAAAKgAECgQIBAAAAA==.',['超级']='超级熊猫爸爸:BAAAKgAFFAEIAQAAAA==.',['超绝']='超绝阴暗比:BAABKgAECn8UAAIUAAgI+BrlQgAnAgAUAAgI+BrlQgAnAgAAAA==.',['路短']='路短:BAAAKgAECgYIDAAAAA==.',['路过']='路过的路:BAAAKgAECgQIBgAAAA==.',['辉煌']='辉煌嗳呦喂:BAAAKgAECgMIBQAAAA==.辉煌籹籹庅:BAAAKgAECgEIAQAAAA==.',['迪丽']='迪丽热巴乄:BAAAKgAECgcIBwAAAA==.',['迪菲']='迪菲亚渗透者:BAABKgAFFH8GAAMMAAUIBA5kDwDEAAAMAAUIsAVkDwDEAAANAAEI3iZxKgB1AAAAAA==.',['逍遥']='逍遥臭臭:BAAAKgAECggICAAAAA==.',['遙遠']='遙遠有多遠:BAAAKgADCgMIAgAAAA==.',['邪能']='邪能之骑士:BAABKgAECn8WAAIUAAgIgx4xaADJAQAUAAgIgx4xaADJAQAAAA==.',['重楼']='重楼赏月:BAAAKgADCgMIAwAAAA==.',['重门']='重门花影:BAABKgAFFH8GAAIBAAYIKBPaCQB6AQABAAYIKBPaCQB6AQAAAA==.',['野格']='野格冰红茶:BAAAKgADCgIIAgAAAA==.',['金龙']='金龙鱼爱抽烟:BAAAKgAECggICAAAAA==.',['钢丝']='钢丝床:BAABKgAFFH8nAAMlAAgISB45AgD2AQAlAAgIABg5AgD2AQAFAAYIyh+YEQByAQAAAA==.',['钮祜']='钮祜禄橙梦:BAABKgAFFH8KAAMRAAYI4RRTHgAVAQARAAUIWhZTHgAVAQASAAII+w5lKABIAAAAAA==.',['铁锅']='铁锅炖大鹅:BAAAKgAECgYIBgAAAA==.',['长天']='长天一色:BAAAKgADCgIIAgAAAA==.',['闪电']='闪电风暴:BAAAKgAECgYICgAAAA==.',['阿劣']='阿劣劣:BAABKgAFFH8IAAIQAAgIwxf7BQA3AgAQAAgIwxf7BQA3AgAAAA==.',['阿拉']='阿拉蕾囧:BAAAKgAECgMIAwAAAA==.',['阿苏']='阿苏焉:BAAAKgAFFAQIBAAAAA==.',['陈惯']='陈惯西路子野:BAAAKgAECgIIAgAAAA==.',['隔壁']='隔壁老張:BAABKgAFFH8GAAIKAAYInRM5FAB5AQAKAAYInRM5FAB5AQAAAA==.',['雨天']='雨天一夜:BAAAKgAECgcICwAAAA==.',['雪诺']='雪诺:BAAAKgAECggIEAAAAA==.',['零星']='零星灬小雨:BAAAKgAECggICAAAAA==.',['雷小']='雷小德:BAABKgAFFH8KAAMKAAYIYA6UGwA9AQAKAAYIYA6UGwA9AQATAAQIAxJFDADNAAABKgAFFAgICAAgALsbAA==.',['露可']='露可帕妮:BAABKgAFFH8FAAIgAAQISR8GCAAYAQAgAAQISR8GCAAYAQAAAA==.',['静悄']='静悄悄:BAAAKgAECgEIAQAAAA==.',['韩德']='韩德萨姆:BAAAKgADCgIIAgAAAA==.',['風殤']='風殤之塵:BAABKgAFFH8FAAIEAAUIWwMRDgCpAAAEAAUIWwMRDgCpAAAAAA==.',['风吹']='风吹鸡飞:BAAAKgAECgYIDAAAAA==.',['风的']='风的感伤:BAAAKgAECgIIAgAAAA==.',['风语']='风语丶德兰泰:BAAAKgADCggIEAAAAA==.',['飞天']='飞天小女警:BAAAKgAECggIDwAAAA==.',['飞雪']='飞雪星尘:BAABKgAFFH8GAAIPAAYINg5DGACgAAAPAAYINg5DGACgAAAAAA==.',['马戏']='马戏团的小丑:BAAAKgAECgMIBAAAAA==.',['骑猪']='骑猪喝茅台:BAACKgAFFH8PAAINAAYIjhhzEACZAQANAAYIjhhzEACZAQAqAAQKfyIAAw0ACAjOISwRAIECAA0ACAjOISwRAIECABYABgikCkMeANUAAAEqAAUUCAgUACEAuiIA.骑猪泡温泉:BAAAKgADCgYIBgABKgAFFAgIFAAhALoiAA==.骑猪泡软妹:BAACKgAFFH8MAAMgAAYIbxPlDgBkAQAgAAYIbxPlDgBkAQAjAAMIVB4ZDwDtAAAqAAQKfxYAAyMACAjdIegNAG8CACMACAjdIegNAG8CACAAAwhiCvutAEgAAAEqAAUUCAgUACEAuiIA.骑猪看世界:BAACKgAFFH8UAAQhAAUIuiIiFQA7AQAhAAMIvyMiFQA7AQADAAUIDxUzFgABAQAEAAEItCN4JwBZAAAqAAQKfx8ABCEACAjWHVEoALwBACEABQj5IFEoALwBAAMABwhQGJ1LAFIBAAQABgiFIapWAAsBAAAA.骑猪遛大象:BAACKgAFFH8KAAIZAAMI3Rs7HwDIAAAZAAMI3Rs7HwDIAAAqAAQKfx8AAhkACAhPIqQNAGUCABkACAhPIqQNAGUCAAEqAAUUCAgUACEAuiIA.骑猪霍稀泥:BAAAKgADCgMIAwAAAA==.',['骨残']='骨残心:BAAAKgAECgUIBQAAAA==.',['鬼雨']='鬼雨墨山:BAACKgAFFH8LAAIUAAMIQiOcLwAqAQAUAAMIQiOcLwAqAQAqAAQKfyAAAwsACAixIxIVAMwBABQABghlJL9WAPIBAAsABwibHRIVAMwBAAAA.',['魔法']='魔法航航:BAAAKgAECgYIBgAAAA==.',['鮮血']='鮮血哀川凜:BAABKgAECn8dAAMHAAcIFRa8IgBwAQAHAAYIFRa8IgBwAQAGAAQIqgnqdQCHAAAAAA==.',['鲨鱼']='鲨鱼饵丶:BAACKgAFFH8tAAINAAgI+RsDEACeAQANAAgI+RsDEACeAQAqAAQKfysAAg0ACAjCJCIUAIgCAA0ACAjCJCIUAIgCAAAA.',['鸡脚']='鸡脚男:BAAAKgAECggICgAAAA==.',['鸡蛋']='鸡蛋炒米饭:BAAAKgADCgMIAgAAAA==.',['黑暗']='黑暗形态:BAAAKgADCgIIAgAAAA==.',['齐得']='齐得龙东强:BAAAKgADCgUIBQAAAA==.',['龍希']='龍希尔:BAACKgAFFH8uAAMZAAgIiBeTCQDcAQAZAAgIiBeTCQDcAQAfAAYIUSQtAQA9AQAqAAQKfxwAAx8ACAgpJDABANcCAB8ACAgpJDABANcCABkABQjQG+wnAHsBAAAA.',['龙之']='龙之随风:BAAAKgAFFAEIAQAAAA==.',['龙焰']='龙焰:BAABKgAFFH8KAAMfAAYI1Qx1BADnAAAfAAUItAl1BADnAAAZAAEIxwEWNQA8AAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end