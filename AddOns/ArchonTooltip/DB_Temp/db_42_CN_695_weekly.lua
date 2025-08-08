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
 local lookup = {'DeathKnight-Blood','Rogue-Assassination','Rogue-Outlaw','Evoker-Devastation','Mage-Fire','Mage-Frost','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','Mage-Arcane','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Shaman-Restoration','Shaman-Elemental','DeathKnight-Unholy','Hunter-Marksmanship','Druid-Balance','Shaman-Enhancement','Warrior-Fury','Unknown-Unknown','Priest-Discipline','Priest-Shadow','Priest-Holy','DemonHunter-Havoc','Warrior-Arms','DeathKnight-Frost','Druid-Restoration','Warrior-Protection','Hunter-BeastMastery','Warlock-Affliction','Monk-Windwalker','Evoker-Preservation','DemonHunter-Vengeance','Rogue-Subtlety','Monk-Brewmaster','Druid-Guardian',}; local provider = {region='CN',realm='斩魔者',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aazaw:BAAAKgAECgIIAgAAAA==.',An='Annyy:BAABKgAFFH8GAAIBAAYIzwx8FQD2AAABAAYIzwx8FQD2AAAAAA==.',Bi='Bigboss:BAABKgAFFH8UAAMCAAgIqRqjBQAzAgACAAgIqRqjBQAzAgADAAIIrxGnBACQAAAAAA==.',Bl='Blastories:BAAAKgAECggIDAAAAA==.',Co='Converter:BAAAKgAECggIBwABKgAFFAgIDAAEALsiAA==.',Da='Dangerous:BAAAKgADCgIIAgAAAA==.',Do='Dominions:BAAAKgAECggIEAAAAA==.',Em='Emoster:BAABKgAFFH8KAAMFAAYI9xlrCgCRAQAFAAYI5hlrCgCRAQAGAAQIjBccFwC5AAABKgAFFAgIRwAFADUlAA==.',Eu='Eureka:BAABKgAFFH8IAAIHAAgIghhhBQD6AQAHAAgIghhhBQD6AQAAAA==.',Ev='Evelyn:BAAAKgAECggIEwAAAA==.',Gg='Ggboom:BAABKgAFFH8GAAMIAAYIrAymIQD6AAAIAAUIPw2mIQD6AAAJAAEIXgqeKQBHAAABKgAFFAgIAgAKAAIWAA==.',Hi='Highlord:BAABKgAFFH8QAAQLAAgICxNSMAAnAQALAAQI7SRSMAAnAQAMAAQI/BWCDgDOAAANAAQIogUZFwC/AAAAAA==.',Jt='Jtr:BAAAKgAECggICQAAAA==.',Ku='Kuro:BAAAKgAFFAEIAgAAAA==.',La='Lalatina:BAAAKgADCgMIAwAAAA==.',Lc='Lctargaryen:BAABKgAECn8cAAMOAAgIRBYYLADLAQAOAAgIRBYYLADLAQAPAAMIRBbTVQDCAAAAAA==.',Li='Lihua:BAAAKgADCgcICAAAAA==.',Ma='Masamune:BAAAKgAFFAQIBAAAAA==.Matanza:BAABKgAFFH8OAAMLAAgIshbaFAC1AQALAAYIKx3aFAC1AQANAAgIuQk+CwBEAQAAAA==.',Mi='Mill:BAAAKgAECgcIEQAAAA==.Mimiron:BAABKgAFFH8JAAMBAAYIkhTzEAAcAQABAAYIuRLzEAAcAQAQAAMINBb9MgDJAAABKgAFFAgIDAAQAPURAA==.',Ms='Mstaer:BAAAKgAECgcIBwAAAA==.',Na='Nazgrim:BAACKgAFFH9QAAIBAAgITiHfAQCNAgABAAgITiHfAQCNAgAqAAQKfzMAAgEACAh/IZsIAHACAAEACAh/IZsIAHACAAAA.',On='Onlyloveless:BAAAKgAECggICAAAAA==.',Oz='Ozz:BAAAKgAECgUIEQAAAA==.',Pl='Playersimdsy:BAAAKgAECgEIAQAAAA==.',Ra='Ravenaltwod:BAAAKgAECgEIAQABKgAFFAMICwARAC0cAA==.',Ri='Rivendell:BAAAKgADCggICAAAAA==.',Se='Seeyou:BAAAKgAECgUIBgAAAA==.',Te='Tearsineye:BAAAKgAECgIIAgAAAA==.',To='Tohka:BAAAKgAECgEIAQABKgAFFAYICQALABYWAA==.',Um='Umi:BAAAKgAECgMIAwAAAA==.',Vo='Voodoodruid:BAABKgAFFH8GAAISAAYIEwrpHAA1AQASAAYIEwrpHAA1AQABKgAFFAgICwACAGUZAA==.Voodooshades:BAABKgAFFH8HAAMIAAcI8hvwHgAQAQAIAAYI0x3wHgAQAQAJAAEIiRIFKQBIAAABKgAFFAgICwACAGUZAA==.',Wl='Wlsnomercy:BAABKgAECn8WAAIIAAgIOSKFDQB9AgAIAAgIOSKFDQB9AgAAAA==.',Yi='Yicdyoubiye:BAABKgAFFH8QAAISAAQIUxNUFgDjAAASAAQIUxNUFgDjAAAAAA==.',Zw='Zwz:BAAAKgAECgYICQAAAA==.',['一叶']='一叶识秋:BAAAKgAFFAYIBAAAAA==.',['一心']='一心向善:BAAAKgAFFAEIAQAAAA==.',['一本']='一本万丽:BAABKgAFFH8GAAIGAAYIxREeBQBqAQAGAAYIxREeBQBqAQAAAA==.',['一路']='一路走来:BAAAKgADCgIIAgAAAA==.',['一身']='一身艾噢威:BAAAKgAECgYIBgAAAA==.',['一骑']='一骑丿当千:BAAAKgAECgYIBgAAAA==.',['万碎']='万碎:BAABKgAFFH8GAAIRAAYIFwSMEgDXAAARAAYIFwSMEgDXAAAAAA==.',['不再']='不再流浪:BAAAKgAFFAUIBAAAAA==.',['不是']='不是随意:BAAAKgAECgUIBQAAAA==.',['不要']='不要太铞:BAABKgAFFH8IAAIKAAgIywriCQDRAQAKAAgIywriCQDRAQAAAA==.',['专打']='专打瘸子坏腿:BAAAKgAFFAQIBAAAAA==.',['丘比']='丘比特之哀伤:BAABKgAFFH8RAAIHAAgIlRT8AwAsAgAHAAgIlRT8AwAsAgAAAA==.丘比特之杖:BAACKgAFFH8dAAQTAAgISRbWAwARAgATAAgISRbWAwARAgAOAAYIehaEDQB2AQAPAAIIYBK5HgCEAAAqAAQKfyIAAhMACAisId0KAIsCABMACAisId0KAIsCAAAA.',['丨古']='丨古月三少丨:BAACKgAFFH8GAAIUAAYIuB7jCgCdAQAUAAYIuB7jCgCdAQAqAAQKfx4AAhQACAicHDYkALUBABQACAicHDYkALUBAAEqAAUUCAgCABUAAAAA.',['丨西']='丨西野司丨:BAAAKgADCgEIAQAAAA==.',['中广']='中广深龙:BAAAKgADCggICAAAAA==.',['丶兽']='丶兽兽:BAAAKgAECgQIBAAAAA==.',['丶冰']='丶冰玲丶:BAAAKgAECggIEgAAAA==.',['丶嘟']='丶嘟嘟丿灬:BAABKgAFFH8GAAILAAYIwBF8JABYAQALAAYIwBF8JABYAQAAAA==.',['丶福']='丶福如东海:BAAAKgAECggICAAAAA==.',['为了']='为了女孩子:BAAAKgAFFAIIAgAAAA==.',['主宰']='主宰之剑:BAAAKgAECgMIAwAAAA==.',['举杯']='举杯饮尽风雪:BAAAKgAECggICQAAAA==.',['丿悠']='丿悠丶亚:BAAAKgAECgYIBgAAAA==.',['丿纪']='丿纪念丶余生:BAAAKgAECggICAAAAA==.',['乃量']='乃量惊人:BAAAKgAFFAIIBAAAAA==.',['乐正']='乐正绫:BAABKgAFFH8GAAIHAAYINRfUCgB6AQAHAAYINRfUCgB6AQAAAA==.',['九命']='九命狐灬:BAAAKgAECggICAAAAA==.',['亂儛']='亂儛天地:BAAAKgADCggICAAAAA==.',['云和']='云和山的彼端:BAACKgAFFH8hAAIWAAQIfBJTCQDmAAAWAAQIfBJTCQDmAAAqAAQKf0sAAhYACAhmHZkRADoCABYACAhmHZkRADoCAAAA.',['五姑']='五姑娘:BAAAKgAECgYIBgAAAA==.',['亜篾']='亜篾蝶:BAABKgAFFH8HAAIJAAQIeQjUCwCcAAAJAAQIeQjUCwCcAAAAAA==.',['亞蔑']='亞蔑蝶:BAACKgAFFH8fAAMXAAYIlBEaDAA9AQAXAAYIlBEaDAA9AQAYAAQIVhNjFQCVAAAqAAQKfxwAAhgACAgMHi4mALkBABgACAgMHi4mALkBAAAA.',['亦丶']='亦丶天启:BAAAKgAFFAQIBAABKgAFFAgIBgAQAB0dAA==.',['京津']='京津冀:BAAAKgAECgMIAwAAAA==.',['今夜']='今夜好风光:BAAAKgAECgcIBwAAAA==.',['伊俐']='伊俐达雷之刃:BAAAKgADCgEIAQAAAA==.',['伊克']='伊克贝尔多:BAABKgAFFH8IAAIIAAgIHw7DCgDgAQAIAAgIHw7DCgDgAQAAAA==.',['伊小']='伊小丹:BAAAKgAFFAcIBAAAAA==.',['伊芙']='伊芙莉特:BAABKgAFFH8KAAMGAAYIeCPJBAALAQAFAAYIKyMGCADLAQAGAAQIvyLJBAALAQAAAA==.',['伊莉']='伊莉莎白素贞:BAAAKgAECggIDwAAAA==.',['伯乐']='伯乐:BAAAKgAECgYIDAAAAA==.',['低调']='低调小强:BAAAKgAECggIDQAAAA==.',['佩之']='佩之歌:BAAAKgADCggICAAAAA==.',['佳莉']='佳莉亚灬凋零:BAAAKgAECgQIBQAAAA==.',['傅菁']='傅菁:BAAAKgADCgUIBQAAAA==.',['傺魂']='傺魂:BAAAKgAECgEIAQAAAA==.',['傻蔓']='傻蔓电死你:BAABKgAFFH8JAAIOAAIIKxVrRQBwAAAOAAIIKxVrRQBwAAAAAA==.',['克里']='克里斯丁:BAABKgAFFH8FAAIMAAMIwgk9DQCEAAAMAAMIwgk9DQCEAAAAAA==.克里斯狄娜:BAAAKgAECgcICAAAAA==.',['兔之']='兔之夭夭:BAAAKgAECggIEAAAAA==.',['全球']='全球可飞:BAAAKgAECggICAAAAA==.',['八百']='八百里开外:BAABKgAFFH8IAAIRAAMIeQ1jNQCeAAARAAMIeQ1jNQCeAAAAAA==.',['农夫']='农夫三拳丨痛:BAABKgAFFH8FAAIZAAMIbgmDHQDNAAAZAAMIbgmDHQDNAAAAAA==.',['农妇']='农妇山拳:BAAAKgAECgcIBwAAAA==.',['冬刺']='冬刺骨春繁华:BAACKgAFFH8rAAQLAAgISh8mBQBfAQANAAgI8hUmBQDuAQALAAUIqB8mBQBfAQAMAAUIehUyCADUAAAqAAQKfxUAAwwACAjJE/kVAMABAAwACAjJE/kVAMABAAsABghvEse4ACcBAAAA.',['冰火']='冰火绝恋:BAACKgAFFH8LAAMKAAcI4CFeBwAKAgAKAAYIeCVeBwAKAgAFAAUI9Qp+FgD+AAAqAAQKfxwAAgUACAhUHJELAB8CAAUACAhUHJELAB8CAAAA.',['冰霜']='冰霜舞步:BAAAKgADCgUIBQAAAA==.',['冲了']='冲了前头:BAACKgAFFH8XAAIQAAYIwRlpDwCkAQAQAAYIwRlpDwCkAQAqAAQKfyAAAhAACAhfHh8WAFsCABAACAhfHh8WAFsCAAAA.',['凌千']='凌千魂:BAAAKgAECgYIBgAAAA==.',['几十']='几十个老板娘:BAAAKgAECgEIAQAAAA==.',['凶猫']='凶猫:BAABKgAFFH8GAAIaAAYIkQpsBwA5AQAaAAYIkQpsBwA5AQAAAA==.',['刘大']='刘大少:BAABKgAECn80AAMQAAgIhBckOwDEAQAQAAgI9BUkOwDEAQAbAAgIIA/UEwBbAQAAAA==.',['别乄']='别乄惹我:BAAAKgADCgEIAQAAAA==.',['剑倾']='剑倾雪:BAABKgAFFH8GAAIGAAIIvRIOIQCAAAAGAAIIvRIOIQCAAAAAAA==.',['勥巭']='勥巭盼盼:BAAAKgAFFAYIBAAAAA==.',['北岸']='北岸情森:BAAAKgAFFAIIAgAAAA==.',['千小']='千小本:BAAAKgAFFAcIAwABKgAFFAgIBAAVAAAAAA==.',['南国']='南国风情:BAAAKgAECggIDwAAAA==.',['印第']='印第安纳白菜:BAACKgAFFH8hAAIcAAQIzhVgCgDrAAAcAAQIzhVgCgDrAAAqAAQKf1YAAhwACAgiHTgSABQCABwACAgiHTgSABQCAAAA.',['压力']='压力大我先拿:BAAAKgAECggIBwABKgAFFAgIDAARAF8VAA==.',['去跟']='去跟鸡拼啤酒:BAAAKgADCgYIBgAAAA==.',['又见']='又见小刀:BAAAKgAECgUIBQAAAA==.',['古二']='古二:BAABKgAECn8tAAIKAAgIvROaFQCMAQAKAAgIvROaFQCMAQAAAA==.',['古树']='古树梨花:BAAAKgAECgYIBgAAAA==.',['司幽']='司幽:BAAAKgAECgcICQAAAA==.',['吉祥']='吉祥三宝:BAAAKgAFFAYIBAABKgAFFAgIEQARAPEhAA==.',['吒查']='吒查查:BAABKgAFFH8KAAIGAAMICBSWFgC8AAAGAAMICBSWFgC8AAAAAA==.',['呆呆']='呆呆滴西瓜:BAABKgAFFH8MAAIdAAYIzRGFBQAiAQAdAAYIzRGFBQAiAQAAAA==.',['呆萌']='呆萌猪:BAABKgAFFH8OAAIZAAYIYhTaEQBvAQAZAAYIYhTaEQBvAQAAAA==.',['呼呼']='呼呼妹:BAABKgAECn8aAAMRAAgIAR03JwDQAQARAAcIOBg3JwDQAQAeAAYITBhITwBvAQAAAA==.',['呼死']='呼死你:BAABKgAFFH8MAAILAAgIaQt2EADcAQALAAgIaQt2EADcAQAAAA==.',['咆哮']='咆哮的水滴:BAAAKgAECggICAAAAA==.',['咖啡']='咖啡:BAAAKgAFFAIIAgAAAA==.咖啡熙:BAAAKgAFFAQIBAAAAA==.',['咸肉']='咸肉:BAAAKgADCgYIBgAAAA==.',['哀冬']='哀冬乂男爵:BAAAKgADCgQIBgAAAA==.',['哇库']='哇库丨哇酷:BAAAKgAECggICAAAAA==.',['哈侠']='哈侠:BAAAKgAECggICAAAAA==.',['哈搞']='哈搞咕:BAAAKgAECggICAAAAA==.',['哒哒']='哒哒嗒:BAABKgAECn8YAAQWAAgIJhU5EAA9AQAWAAcIDBc5EAA9AQAXAAMIFgq1SwB/AAAYAAMIGgsmNQBDAAAAAA==.',['哦麦']='哦麦泪滴嘎嘎:BAAAKgADCgEIAgAAAA==.',['哲与']='哲与诗:BAAAKgAECgQIBAAAAA==.',['啊卡']='啊卡丽:BAAAKgAECggICAABKgAFFAgICAAIAPUYAA==.',['啊航']='啊航:BAAAKgAECgIIAgAAAA==.',['啮人']='啮人:BAABKgAECn8VAAMRAAgIPBJzFwBwAQARAAgIlRBzFwBwAQAeAAQIVBSvRwCEAAAAAA==.',['善良']='善良无名:BAAAKgAECgcIAQAAAA==.善良的倪哥:BAAAKgAECgQICAAAAA==.',['善酿']='善酿的内个:BAABKgAFFH8IAAMcAAQI6B3HFAD6AAAcAAQI6B3HFAD6AAASAAQI6xgSNADJAAAAAA==.',['喊家']='喊家属来收尸:BAAAKgAECggICAAAAA==.',['喝人']='喝人一大跳:BAAAKgAECgYIBAAAAA==.',['喵猫']='喵猫躲:BAAAKgAECggICAAAAA==.',['喵花']='喵花花:BAAAKgAECggICAAAAA==.',['嗨嗨']='嗨嗨贵:BAAAKgAECgMIAwAAAA==.',['噗噗']='噗噗哦:BAABKgAFFH8MAAIZAAYIOSV0CgDjAQAZAAYIOSV0CgDjAQAAAA==.',['嚒方']='嚒方向:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光味牛肉干:BAAAKgAFFAQIBAAAAA==.圣光有毒:BAABKgAFFH8GAAILAAYI5RQxJABaAQALAAYI5RQxJABaAQAAAA==.',['圣哈']='圣哈哈:BAACKgAFFH8OAAIMAAQIfxpNDQDcAAAMAAQIfxpNDQDcAAAqAAQKfxsAAwsACAjMGztIAOcBAAsABwhTHjtIAOcBAAwACAh/GqkZAJoBAAAA.',['圣婇']='圣婇:BAAAKgAECgEIAQAAAA==.',['圣言']='圣言之女安娜:BAAAKgADCgEIAwAAAA==.',['地王']='地王之怒:BAAAKgADCgYICQAAAA==.',['埃拉']='埃拉西亚:BAABKgAFFH8NAAIOAAII3RPzJwB/AAAOAAII3RPzJwB/AAAAAA==.',['埃辛']='埃辛诺斯:BAAAKgAECgMIAwAAAA==.',['增强']='增强归来:BAABKgAFFH8GAAIPAAYIDA2BCABHAQAPAAYIDA2BCABHAQAAAA==.',['夏了']='夏了个天呀:BAAAKgAFFAUIAQABKgAFFAgIDgAIAOofAA==.',['夏日']='夏日第一缕风:BAAAKgAECggIEQAAAA==.',['大一']='大一学妹:BAABKgAFFH8GAAIHAAYIhxzWCQCOAQAHAAYIhxzWCQCOAQAAAA==.',['大地']='大地震鸡:BAABKgAFFH8NAAMOAAUIKBy8BwAbAQAOAAUIKBy8BwAbAQAPAAEI5ACOKwAkAAAAAA==.',['大漠']='大漠孤焰:BAAAKgADCgcIBwAAAA==.',['大耳']='大耳萌:BAAAKgADCggICAAAAA==.',['大饼']='大饼:BAABKgAFFH8JAAMcAAYIvxF8DgAtAQAcAAYIvxF8DgAtAQASAAIIUhg2RwCTAAAAAA==.大饼熊:BAAAKgAFFAQIBAAAAA==.大饼熊的墓石:BAABKgAFFH8IAAMYAAQIsRiBHgDQAAAYAAQIsRiBHgDQAAAXAAQIPBDTEgDNAAABKgAFFAgICgAYANkWAA==.大饼熊的骑士:BAAAKgAFFAQIBAAAAA==.',['天上']='天上叁只鸟:BAABKgAFFH8NAAMRAAYIRR/vCADLAQARAAYIRR/vCADLAQAeAAQI4A7ZPACpAAAAAA==.',['天使']='天使恶魔:BAAAKgADCgYIBgAAAA==.',['天堂']='天堂之令:BAAAKgAECgMIAwAAAA==.',['天然']='天然气女友:BAABKgAECn8VAAIOAAgILhpJJwDjAQAOAAgILhpJJwDjAQAAAA==.',['天罡']='天罡巅狐:BAAAKgAECgUIBQAAAA==.天罡灵狐:BAAAKgAECgYIBgAAAA==.',['天霸']='天霸地霸咚霸:BAAAKgAECgYIBgAAAA==.',['头号']='头号渣男:BAAAKgAECgMIAwAAAA==.',['女孩']='女孩子:BAAAKgADCgUIBQAAAA==.女孩子喜欢我:BAAAKgAECgcIBwAAAA==.',['奶下']='奶下的圣光:BAAAKgAECgQIBAAAAA==.',['奶不']='奶不动了:BAAAKgADCgIIAgAAAA==.',['好心']='好心女孩子:BAAAKgAFFAMIAwAAAA==.',['如果']='如果你不在:BAABKgAFFH8IAAMMAAIIPiB4CgC3AAAMAAIIPiB4CgC3AAALAAIIbg2AOgBwAAAAAA==.',['娘个']='娘个色赖赖:BAAAKgADCggICAAAAA==.',['孙豆']='孙豆豆:BAAAKgAFFAIIAgAAAA==.',['孤烟']='孤烟:BAACKgAFFH8GAAIeAAYIyCTPCQDVAQAeAAYIyCTPCQDVAQAqAAQKfxsAAx4ACAg2IOopAEwCAB4ACAg2IOopAEwCABEAAQgvG/xAAFIAAAAA.',['孤独']='孤独的兽兽:BAABKgAFFH8KAAMRAAYIQh8oBwANAQAeAAYIkBwCEQBwAQARAAQI+BooBwANAQAAAA==.孤独的夜:BAABKgAECn8aAAMeAAgIiSGvHABUAgAeAAgIiSGvHABUAgARAAUIzQuXYAChAAAAAA==.',['宝屁']='宝屁龙:BAAAKgAECgQIBAAAAA==.',['宝批']='宝批龙:BAAAKgAECgMIAwAAAA==.',['寂寞']='寂寞如烟花:BAABKgAFFH8KAAILAAYIOBH1JQBRAQALAAYIOBH1JQBRAQAAAA==.',['封枝']='封枝暮雪:BAABKgAFFH8dAAQJAAQIFiKgDgDDAAAIAAMIwCBaIwDtAAAJAAMIZCOgDgDDAAAfAAEIYBq6EABPAAAAAA==.',['射什']='射什么射:BAAAKgAECgYIBgAAAA==.',['将来']='将来:BAAAKgAECgcIBwAAAA==.',['小咧']='小咧咧:BAAAKgAECgMIAwAAAA==.',['小喵']='小喵咪:BAAAKgAECgUIBgAAAA==.',['小小']='小小吼:BAABKgAFFH8GAAIUAAYIGxtVDQB6AQAUAAYIGxtVDQB6AQABKgAFFAgIHgAUAPAgAA==.小小孩:BAAAKgAFFAMIAwAAAA==.小小律:BAABKgAFFH8IAAMYAAQI3hjRJQCrAAAYAAQI3hjRJQCrAAAWAAEIAACRNwAAAAAAAA==.小小法强:BAACKgAFFH8nAAMGAAgIchdTAgD6AQAGAAcIchdTAgD6AQAFAAEIAAANNAAAAAAqAAQKf0wAAgYACAjHJFsHANECAAYACAjHJFsHANECAAAA.',['小尾']='小尾儿摆摆:BAAAKgAECgQIBAAAAA==.',['小当']='小当僧:BAAAKgAECgIIAgAAAA==.小当骑骑:BAAAKgAECgIIAgAAAA==.',['小手']='小手拔凉:BAAAKgADCgEIAQAAAA==.',['小枫']='小枫哥:BAAAKgADCgYIBgAAAA==.',['小樱']='小樱:BAAAKgAFFAYIBAAAAA==.小樱桃:BAAAKgADCggICAAAAA==.',['小清']='小清流:BAACKgAFFH8eAAQUAAgI8CDPAwBmAgAUAAgI8CDPAwBmAgAdAAgIXhPzAgCiAQAaAAEIgRs5KABPAAAqAAQKfxQAAhQACAgZI48QAIECABQACAgZI48QAIECAAAA.',['小瑜']='小瑜熊:BAAAKgAFFAIIAgAAAA==.',['小翘']='小翘流水:BAAAKgAECgYIEQAAAA==.',['小草']='小草莓:BAAAKgAECgcIDAAAAA==.',['小软']='小软灬:BAAAKgAECggIEwAAAA==.',['小錵']='小錵椛:BAAAKgAFFAIIAgAAAA==.',['小钢']='小钢炮架起来:BAABKgAFFH8IAAILAAgI1ge1EACVAQALAAgI1ge1EACVAQAAAA==.',['小靓']='小靓仔:BAABKgAFFH8GAAIQAAYIRRB+GQBRAQAQAAYIRRB+GQBRAQAAAA==.',['少玩']='少玩童:BAAAKgAECgQIBgAAAA==.',['就是']='就是不玩奶:BAAAKgAECgYICgAAAA==.',['山与']='山与海:BAAAKgADCgEIAQAAAA==.',['岚之']='岚之卡米:BAAAKgAFFAIIAwAAAA==.',['岳下']='岳下噬魔:BAABKgAECn8fAAIgAAgI2iGyCwBxAgAgAAgI2iGyCwBxAgAAAA==.',['岸灬']='岸灬:BAAAKgAECgcIDAAAAA==.',['崔希']='崔希斯:BAABKgAFFH8FAAIRAAMINg5kMwCkAAARAAMINg5kMwCkAAAAAA==.',['左青']='左青龙:BAAAKgADCggICAAAAA==.',['帅是']='帅是一辈子:BAABKgAFFH8LAAMUAAYIHRUVGQDzAAAUAAYI1BMVGQDzAAAaAAQIfhOiEwDmAAAAAA==.',['希尔']='希尔丹:BAAAKgAECgUIBQAAAA==.',['希格']='希格德莉法:BAACKgAFFH8MAAIeAAMIUBe2KQDeAAAeAAMIUBe2KQDeAAAqAAQKfyEAAxEACAiSHbAsALEBAB4ACAgSHG1EAOgBABEABwhTGrAsALEBAAAA.',['帝凯']='帝凯:BAABKgAFFH8dAAMQAAYIeiNqCAAIAgAQAAYIeiNqCAAIAgAbAAEI2wGYEgAmAAAAAA==.',['幻梦']='幻梦丶唯殇:BAABKgAFFH8QAAMIAAcIpRU6CgAPAQAIAAYIDBg6CgAPAQAJAAMILQaqDACEAAAAAA==.',['幽冥']='幽冥暗殇:BAABKgAFFH8GAAIGAAMIeQWgEQB5AAAGAAMIeQWgEQB5AAAAAA==.',['幽暗']='幽暗圣灵:BAACKgAFFH8ZAAMYAAUIDBWoCwARAQAYAAUIDBWoCwARAQAXAAEIoQaKMQAxAAAqAAQKfzkAAhgACAiZIqgIAJoCABgACAiZIqgIAJoCAAAA.',['庄生']='庄生迷蝶:BAAAKgADCggICAAAAA==.',['应采']='应采儿:BAAAKgAECgYICwAAAA==.',['弄杂']='弄杂刚度:BAABKgAFFH8IAAINAAgIKQeVDAAvAQANAAgIKQeVDAAvAQAAAA==.',['张泰']='张泰玩:BAABKgAFFH8KAAIFAAYIGwduCQBjAQAFAAYIGwduCQBjAQAAAA==.',['很风']='很风骚的小牛:BAAAKgADCgEIAQAAAA==.',['徐子']='徐子凡:BAAAKgAECgYICQAAAA==.',['德哩']='德哩得啷:BAAAKgAECgUIBQAAAA==.',['徽商']='徽商银行:BAAAKgADCgYIBgAAAA==.',['心善']='心善女孩子:BAAAKgAECgUICQAAAA==.',['心如']='心如止:BAAAKgAECgMIAwAAAA==.',['心朵']='心朵蕾:BAAAKgADCgMIAwAAAA==.',['心碎']='心碎小刘:BAAAKgAFFAYIBAAAAA==.',['心累']='心累了一页:BAAAKgADCggIDQAAAA==.',['忆中']='忆中人:BAAAKgAECgUIBQAAAA==.',['忧伤']='忧伤的木头:BAABKgAFFH8HAAMSAAMIJQWXJACVAAASAAMIJQWXJACVAAAcAAIIwg17KwByAAAAAA==.',['恋逸']='恋逸魂伤:BAABKgAFFH8JAAMFAAYIIhV3DgBXAQAFAAYIHBN3DgBXAQAGAAMI6Aw6IACFAAAAAA==.',['惊恐']='惊恐的鸦龙:BAACKgAFFH8JAAMEAAMIVRb0DQDhAAAEAAMIVRb0DQDhAAAhAAEIFQjwCwA1AAAqAAQKfxQAAgQACAjOIY8LAH4CAAQACAjOIY8LAH4CAAEqAAUUBggJAAIAkBIA.',['成吨']='成吨的伤害:BAAAKgADCgEIAQAAAA==.',['我叫']='我叫霎聪君:BAAAKgADCggICAAAAA==.',['我喜']='我喜欢女孩子:BAAAKgAFFAEIAQAAAA==.',['我很']='我很橙熟:BAAAKgAFFAUIBAAAAA==.',['戦十']='戦十骑:BAAAKgADCggICAAAAA==.',['手舞']='手舞圣光:BAAAKgADCggIDQAAAA==.',['打到']='打到你服:BAAAKgADCggICAAAAA==.',['抖腿']='抖腿的贵公子:BAAAKgADCggICgAAAA==.抖腿的贵妇:BAAAKgAECgYIBgAAAA==.',['抹香']='抹香鲸:BAAAKgAFFAMIAQAAAA==.',['拼多']='拼多多搜美团:BAAAKgADCggICAAAAA==.',['挽歌']='挽歌之殇:BAACKgAFFH8cAAMiAAQIgwumCADDAAAiAAQIpAqmCADDAAAZAAMISQ1dMgC2AAAqAAQKf0EAAxkACAiKHyUcACECABkACAiKHyUcACECACIAAghLCtFcAEEAAAAA.',['换胃']='换胃思考:BAABKgAFFH8KAAIFAAYIBBxABADFAQAFAAYIBBxABADFAQAAAA==.',['摇曳']='摇曳系清风:BAAAKgAFFAQIBAAAAA==.',['摩诃']='摩诃迦叶:BAAAKgAECgEIAgAAAA==.',['撒旦']='撒旦的微笑:BAABKgAECn8XAAIeAAgI7B6pCgBpAgAeAAgI7B6pCgBpAgAAAA==.',['斩尽']='斩尽红尘梦:BAAAKgAFFAgIBAAAAA==.',['斩青']='斩青龙之戟:BAAAKgAECgUIBQAAAA==.',['斯文']='斯文败类丨:BAAAKgADCgcIBwAAAA==.',['旅人']='旅人癫疯痴狂:BAACKgAFFH8JAAIeAAMI1ArWSQB+AAAeAAMI1ArWSQB+AAAqAAQKfzgAAx4ACAgsG/o7AAcCAB4ACAimGvo7AAcCABEABAimF3xQAA8BAAAA.',['无天']='无天射手:BAABKgAFFH8OAAIeAAgIzBxVBABtAgAeAAgIzBxVBABtAgAAAA==.',['无奈']='无奈小牛牛:BAAAKgADCgYIBgAAAA==.',['无敌']='无敌老钟:BAAAKgAFFAIIBAAAAA==.',['无聊']='无聊帝帝鬼:BAAAKgAECgIIAgAAAA==.无聊的平头哥:BAAAKgAECgIIAgAAAA==.无聊的羽风:BAAAKgAECgUIBQAAAA==.',['时尚']='时尚小子:BAABKgAECn8bAAMjAAgIwxvhDAAZAgAjAAgIGxrhDAAZAgACAAEIGRv0SgAxAAAAAA==.',['旷野']='旷野的呼喊:BAAAKgAFFAQIBAAAAA==.',['明里']='明里:BAAAKgAFFAIIAgAAAA==.',['星死']='星死骑:BAABKgAECn8eAAQQAAgIeRP6NwCUAQAQAAgI5xH6NwCUAQAbAAYI2REKFgA5AQABAAUI9AidPgCAAAABKgAFFAMIDAAeAFAXAA==.',['春秋']='春秋蝉:BAAAKgAECgcICQAAAA==.',['晴天']='晴天凝月:BAABKgAECn8XAAILAAgILR+9JQBpAgALAAgILR+9JQBpAgAAAA==.',['晴风']='晴风拂面:BAAAKgADCgEIAQAAAA==.',['暖泉']='暖泉:BAABKgAFFH8IAAILAAUIhBRnMAAnAQALAAUIhBRnMAAnAQAAAA==.',['曹老']='曹老板:BAAAKgAFFAQIBAAAAA==.',['月凝']='月凝霜:BAAAKgAECgEIAQAAAA==.',['月夜']='月夜光:BAAAKgADCggICAAAAA==.月夜舞:BAAAKgAFFAUIAQAAAA==.月夜雨轩:BAAAKgADCgQIBAAAAA==.',['有点']='有点冲动:BAAAKgADCggICAAAAA==.',['朕慑']='朕慑汝無罪:BAACKgAFFH8NAAIRAAgIcB4eAwByAgARAAgIcB4eAwByAgAqAAQKfxUAAh4ABwjxGtw6AAsCAB4ABwjxGtw6AAsCAAAA.',['朕略']='朕略萌:BAAAKgAECgQIBAAAAA==.',['朕赦']='朕赦你无罪:BAAAKgADCgEIAQAAAA==.',['机智']='机智的阿昆达:BAAAKgAECgcIBwAAAA==.',['李淳']='李淳罡:BAAAKgAECgIIAwAAAA==.',['李盼']='李盼盼:BAAAKgAECgcICwAAAA==.',['李霄']='李霄凡:BAAAKgAECggICAAAAA==.',['杨超']='杨超越:BAAAKgADCgUIBQAAAA==.',['枚川']='枚川内酷:BAABKgAFFH8GAAIIAAYI6BP3EgBvAQAIAAYI6BP3EgBvAQAAAA==.',['枫影']='枫影:BAAAKgADCgUIBQAAAA==.',['柠檬']='柠檬小草:BAABKgAECn8UAAMJAAgIiRARKwBAAQAJAAgIiRARKwBAAQAIAAIIEwcnlQBgAAAAAA==.柠檬柚子茶:BAAAKgAFFAQIBAAAAA==.',['桂花']='桂花酒:BAABKgAFFH8IAAMIAAYITRpUGwArAQAIAAUIIx5UGwArAQAfAAMI6woLCAC7AAAAAA==.桂花酿:BAAAKgAECgEIAQAAAA==.',['桐桐']='桐桐爸:BAAAKgAECgUIAwAAAA==.',['欺山']='欺山:BAAAKgAECggIAgAAAA==.',['正义']='正义之丘比特:BAABKgAFFH8bAAILAAQIhSVjKABGAQALAAQIhSVjKABGAQAAAA==.',['武器']='武器斩:BAAAKgADCggICAAAAA==.',['死了']='死了还会活:BAABKgAFFH8TAAMbAAQIBg4WBwAGAQAbAAQIBg4WBwAGAQAQAAIIFgEsVAA+AAAAAA==.',['殇魂']='殇魂猎杀:BAAAKgADCgUIBQAAAA==.',['殇麴']='殇麴:BAAAKgAECgMIAwAAAA==.',['殷尸']='殷尸作乐:BAAAKgADCgEIAQAAAA==.',['毁滅']='毁滅:BAABKgAFFH8IAAIRAAQIPB3oIQDqAAARAAQIPB3oIQDqAAABKgAFFAgIBAAVAAAAAA==.',['毛伊']='毛伊:BAAAKgAECgEIAQAAAA==.',['水墨']='水墨青花:BAAAKgAECggIDAAAAA==.',['水汐']='水汐:BAABKgAFFH8QAAIRAAgITRNOCADYAQARAAgITRNOCADYAQAAAA==.',['永恆']='永恆的信仰:BAABKgAFFH8UAAMBAAYI5CEbBgDUAQABAAYIdCAbBgDUAQAQAAYIKRp4EgCGAQABKgAFFAgIDgAiALELAA==.永恆的榮光:BAABKgAFFH8GAAIUAAYItRxjCwCVAQAUAAYItRxjCwCVAQAAAA==.永恆的漩渦:BAABKgAFFH8IAAIOAAgIzhWfBAD0AQAOAAgIzhWfBAD0AQAAAA==.永恆的聖光:BAABKgAFFH8MAAILAAgIVxOMDADaAQALAAgIVxOMDADaAQAAAA==.',['汐之']='汐之卡米:BAABKgAFFH8QAAIbAAMIFRm1AgD4AAAbAAMIFRm1AgD4AAAAAA==.',['汐汐']='汐汐:BAABKgAFFH8OAAIIAAgI6h86AQDuAQAIAAgI6h86AQDuAQAAAA==.',['汪烊']='汪烊俊侽:BAAAKgADCgQIBAAAAA==.',['沈三']='沈三浪:BAAAKgADCgEIAQAAAA==.',['泰山']='泰山:BAAAKgAECggIEgAAAA==.',['泽拉']='泽拉耿:BAABKgAECn8YAAIEAAYI5RkXLwBJAQAEAAYI5RkXLwBJAQAAAA==.',['泽村']='泽村英梨梨:BAAAKgAECgUIBgAAAA==.',['流氓']='流氓圣斗士:BAAAKgAECggIEwAAAA==.流氓情聖:BAAAKgAECgcICwAAAA==.',['浊酒']='浊酒一壶半生:BAAAKgAECgMIAwAAAA==.',['浪飞']='浪飞冲天:BAAAKgADCggIDgAAAA==.',['海月']='海月果子狸:BAAAKgADCgEIAQAAAA==.',['海盗']='海盗战:BAAAKgAECgIIAgAAAA==.',['淡淡']='淡淡的夏:BAAAKgAECggICAAAAA==.',['淡若']='淡若悠然:BAAAKgAFFAEIAQAAAA==.',['深刻']='深刻的机会:BAAAKgAECgQIBAAAAA==.',['清霜']='清霜渐雪:BAAAKgADCgIIAgAAAA==.',['清风']='清风:BAAAKgADCgIIAgAAAA==.',['游戏']='游戏人生丶:BAAAKgAFFAQIBAAAAA==.',['游龍']='游龍戏鳯:BAAAKgAFFAIIAgAAAA==.游龍戲鳯:BAAAKgAECgcIEwAAAA==.',['游龙']='游龙戏凤:BAAAKgAECgYIBgAAAA==.',['湘云']='湘云:BAAAKgAECgMIAwAAAA==.',['潇洒']='潇洒牛牛:BAAAKgAECgEIAQAAAA==.',['澤老']='澤老板:BAAAKgAECgIIAgAAAA==.',['灬妃']='灬妃咲灬:BAAAKgAECggIEAAAAA==.',['灬妖']='灬妖孽丶:BAABKgAFFH8GAAMWAAYI1xgqDgA3AQAWAAUIHxcqDgA3AQAYAAEItR9fOABfAAAAAA==.',['灬雨']='灬雨心灬:BAAAKgAFFAQIBAABKgAFFAgIBgAYAKsLAA==.',['灵魂']='灵魂潴:BAABKgAFFH8OAAMKAAgI2hTtBgAfAgAKAAgIHxHtBgAfAgAGAAUIIRbzCwALAQAAAA==.',['災禍']='災禍:BAABKgAFFH8MAAIQAAgIBRszBwAfAgAQAAgIBRszBwAfAgAAAA==.',['烈焰']='烈焰镇魂曲:BAAAKgAECgIIAgAAAA==.',['烣燼']='烣燼使者:BAABKgAFFH8IAAILAAQIVRqEJQDbAAALAAQIVRqEJQDbAAAAAA==.',['熊熊']='熊熊大首领:BAABKgAFFH8GAAIkAAYI0BRRAwAgAQAkAAYI0BRRAwAgAQAAAA==.',['燎原']='燎原:BAABKgAFFH8FAAIUAAQI4hZvIQDNAAAUAAQI4hZvIQDNAAAAAA==.',['燎野']='燎野:BAAAKgADCgMIAwAAAA==.',['爆炸']='爆炸天团:BAAAKgAECggICAAAAA==.',['爱你']='爱你某理由:BAAAKgADCggICAAAAA==.爱你的宝:BAAAKgADCgYIBwAAAA==.',['爱吃']='爱吃小雪的魂:BAACKgAFFH8HAAIXAAIISAi/JgBbAAAXAAIISAi/JgBbAAAqAAQKfxoAAhcACAiUGCEZAA8CABcACAiUGCEZAA8CAAAA.爱吃水果:BAACKgAFFH8MAAMeAAMILA7HOwCtAAAeAAMILA7HOwCtAAARAAMIhApHNwCYAAAqAAQKf0sAAxEACAguIC8SAEICABEACAiMHy8SAEICAB4ACAg/HdcoAA4CAAEqAAUUCAgKAB4AFwwA.爱吃蔬菜:BAAAKgAFFAIIBAAAAA==.',['牛德']='牛德婳:BAAAKgADCggIDAAAAA==.',['牦牛']='牦牛奔驰:BAAAKgAECggICwAAAA==.',['犬饲']='犬饲贵丈:BAAAKgADCgEIAQAAAA==.',['犭畏']='犭畏锁小萨:BAABKgAECn8YAAQPAAgIIBeSPQAXAQAPAAYI0BmSPQAXAQAOAAUIGwx4kACcAAATAAIIaRC4PAByAAAAAA==.',['狂怒']='狂怒审判:BAAAKgAECgUIBQAAAA==.',['狂霸']='狂霸拽酷帅叼:BAAAKgAECgIIAgAAAA==.',['狐狸']='狐狸精:BAAAKgADCgEIAQAAAA==.',['狗承']='狗承欢:BAAAKgAFFAQIBAAAAA==.',['独孤']='独孤傲弑:BAAAKgADCggICAAAAA==.',['琴森']='琴森依旧:BAABKgAFFH8UAAIQAAMIfxQ8MADQAAAQAAMIfxQ8MADQAAAAAA==.',['璞鈺']='璞鈺:BAABKgAFFH8XAAMRAAQILR8GLwCxAAARAAMIgR8GLwCxAAAeAAMInBT+QACbAAAAAA==.',['瓦系']='瓦系林北:BAAAKgAECgYIBwAAAA==.',['甄妮']='甄妮玛黛劲:BAAAKgAFFAEIAQAAAA==.',['甜筒']='甜筒掉了:BAABKgAFFH8IAAIOAAgIfQ1bBwDTAQAOAAgIfQ1bBwDTAQAAAA==.',['电炎']='电炎绝手:BAAAKgAECgcICQAAAA==.',['留下']='留下伱过夜:BAAAKgAECggIDwAAAA==.',['疯狂']='疯狂的奶茶:BAAAKgAECggICQAAAA==.',['疯羊']='疯羊:BAAAKgAFFAEIAQAAAA==.',['痛毁']='痛毁恶魔:BAACKgAFFH8PAAMIAAMI8gndPgBxAAAIAAIIAQrdPgBxAAAfAAEI0wlCJQA6AAAqAAQKf1AAAwgACAjEHRoUAAcCAAgACAi+HRoUAAcCAB8AAgh8FG0vAHYAAAAA.',['白桃']='白桃丶乌龙:BAAAKgADCgIIAgAAAA==.白桃肉桂:BAAAKgAFFAIIAgAAAA==.',['百步']='百步飞箭:BAACKgAFFH8HAAIRAAQIOBxoBwALAQARAAQIOBxoBwALAQAqAAQKfxwAAhEACAioISALAIcCABEACAioISALAIcCAAAA.',['皮丶']='皮丶卡丶丘丶:BAAAKgADCgEIAQAAAA==.',['皮皮']='皮皮努:BAABKgAFFH8GAAIZAAYIjwqLGAA4AQAZAAYIjwqLGAA4AQAAAA==.皮皮鲁:BAAAKgADCgYIBgAAAA==.',['看星']='看星星的牛牛:BAAAKgAECgYIBgAAAA==.',['真冬']='真冬酱:BAABKgAFFH8IAAINAAgI4hxFAwBHAgANAAgI4hxFAwBHAgAAAA==.',['真霓']='真霓马带劲:BAAAKgAFFAIIAgAAAA==.',['眠小']='眠小栩:BAABKgAFFH8MAAIGAAgISxdBAQBIAgAGAAgISxdBAQBIAgAAAA==.',['眠浅']='眠浅浅:BAAAKgAFFAgIBAAAAA==.',['眨眼']='眨眼爱上你:BAAAKgADCgQIBAAAAA==.',['砸妮']='砸妮家玻璃:BAAAKgAFFAQIBAAAAA==.',['神奇']='神奇姝姝:BAAAKgAECggICAABKgAFFAgICwAYAKsaAA==.',['神棍']='神棍一德:BAAAKgAECgQIBAAAAA==.',['箭隐']='箭隐无名:BAAAKgAFFAEIAQAAAA==.',['米根']='米根:BAAAKgAECgQIBgAAAA==.',['紫衣']='紫衣:BAAAKgADCgMIAwAAAA==.',['红是']='红是否一:BAAAKgAECgYIBgAAAA==.',['红里']='红里透黑:BAAAKgAECgYIBwAAAA==.',['终极']='终极吸橙器:BAAAKgAECgEIAQAAAA==.',['续完']='续完这支烟:BAAAKgAECggICAAAAA==.',['绿皮']='绿皮小怪兽:BAAAKgAECgYIBwAAAA==.',['羞耻']='羞耻普类:BAAAKgAECgQIBAAAAA==.',['老婆']='老婆早安:BAAAKgAECgIIAgAAAA==.',['老子']='老子绝版:BAAAKgADCggICAAAAA==.',['老钟']='老钟采花:BAABKgAFFH8UAAMDAAMI1hbaBADQAAADAAMI1hbaBADQAAACAAIItAdaJQB6AAAAAA==.',['耐克']='耐克:BAABKgAFFH8GAAIGAAYIUwsQCwAWAQAGAAYIUwsQCwAWAQAAAA==.',['耐牛']='耐牛:BAAAKgAECgYIBQAAAA==.',['肉蛋']='肉蛋葱鸡:BAAAKgADCgYIBgAAAA==.',['胖胖']='胖胖不怕胖:BAACKgAFFH8tAAIeAAcIJxpCEQBuAQAeAAcIJxpCEQBuAQAqAAQKfycAAh4ACAgrH8AjACoCAB4ACAgrH8AjACoCAAAA.胖胖不是胖:BAABKgAFFH8oAAILAAUIKBQiGAAoAQALAAUIKBQiGAAoAQAAAA==.胖胖不能胖:BAABKgAFFH8tAAISAAcILhUUGwBBAQASAAcILhUUGwBBAQAAAA==.',['脆皮']='脆皮:BAAAKgADCgEIAQAAAA==.',['臉紅']='臉紅咯:BAABKgAFFH8GAAILAAYISRhvAgC9AQALAAYISRhvAgC9AQAAAA==.',['自笑']='自笑走荭尘:BAAAKgAECggICAAAAA==.自笑走荭薼:BAABKgAFFH8MAAMeAAQIcSJfFwDyAAAeAAQITx5fFwDyAAARAAQIEx9MEQDSAAAAAA==.',['舒克']='舒克:BAAAKgAECgUIBQAAAA==.',['艾莉']='艾莉茜娅:BAABKgAFFH8KAAISAAYI+hYAFgBpAQASAAYI+hYAFgBpAQAAAA==.',['艾萨']='艾萨克尼特罗:BAACKgAFFH8WAAMUAAQIxiB+CQAaAQAUAAQIxiB+CQAaAQAaAAEIWhrxFwBTAAAqAAQKfxwAAxQACAgXJFsLAKwCABQACAgXJFsLAKwCABoAAQidDKNjAEEAAAAA.',['芙兰']='芙兰莎:BAABKgAFFH8GAAIMAAYIGxrFBACfAQAMAAYIGxrFBACfAQAAAA==.',['花吹']='花吹雪:BAAAKgADCggICQAAAA==.',['花开']='花开淡墨:BAAAKgAECgUIBQAAAA==.',['花花']='花花的啊呜:BAAAKgAECggICAAAAA==.',['花间']='花间一坛酒:BAAAKgAECgIIAgAAAA==.花间浊酒:BAAAKgAECgYIBgAAAA==.',['苞谷']='苞谷地守卫者:BAAAKgAECgMIAwAAAA==.',['苦行']='苦行者:BAAAKgAECgQIBAAAAA==.',['苹果']='苹果太子:BAAAKgAFFAEIAQAAAA==.',['茅山']='茅山金甲尸:BAAAKgADCgMIAwAAAA==.',['茜特']='茜特菈莉:BAAAKgAECgQIBAAAAA==.',['茯苓']='茯苓半夏:BAABKgAFFH8IAAIXAAYI9RciCgBfAQAXAAYI9RciCgBfAQAAAA==.',['茶太']='茶太:BAAAKgADCggICQAAAA==.',['荒漠']='荒漠星云:BAABKgAECn8fAAMXAAgIyxBLKACVAQAXAAgIyxBLKACVAQAYAAQItQz3dQB8AAAAAA==.荒漠虚空:BAAAKgADCgEIAQAAAA==.荒漠龙息:BAABKgAECn8XAAMEAAcIMxd4KQBvAQAEAAcIMxd4KQBvAQAhAAII4AIMKAA2AAAAAA==.',['莘朵']='莘朵拉:BAABKgAFFH8GAAIIAAYIpA5BDgBaAQAIAAYIpA5BDgBaAQAAAA==.',['莫安']='莫安娜:BAAAKgAECgUIBQAAAA==.',['莫琴']='莫琴音:BAAAKgADCgcIBwAAAA==.',['菜小']='菜小蜓:BAABKgAFFH8IAAIeAAQIshOMNQC+AAAeAAQIshOMNQC+AAABKgAFFAgIBAAVAAAAAA==.',['菜鸟']='菜鸟劣人:BAABKgAFFH8FAAIRAAMIGBHiKwC7AAARAAMIGBHiKwC7AAAAAA==.',['菠萝']='菠萝鳖:BAAAKgAECgcICQAAAA==.',['菲拉']='菲拉斯羽月:BAAAKgAECgMIBAAAAA==.',['菲羽']='菲羽凌曦:BAABKgAFFH8TAAMeAAgIHR0cBABzAgAeAAgIAR0cBABzAgARAAQIdhLjEQDPAAAAAA==.',['萌萌']='萌萌的身材:BAAAKgAFFAQIBAAAAA==.',['萢咴']='萢咴儿:BAAAKgAECgEIAQAAAA==.',['萨克']='萨克拉:BAAAKgAECgYIBgAAAA==.',['萨蛮']='萨蛮丶:BAAAKgAFFAQIBAAAAA==.',['萨鄙']='萨鄙:BAAAKgAECgYICAAAAA==.',['萬歲']='萬歲高:BAAAKgADCgYIBgAAAA==.',['萬箭']='萬箭丨穿心:BAABKgAFFH8GAAIRAAYItwyAGgAZAQARAAYItwyAGgAZAQAAAA==.',['落灬']='落灬日:BAABKgAFFH8GAAIeAAYICB+NDgCLAQAeAAYICB+NDgCLAQAAAA==.',['落花']='落花飘雪:BAAAKgAECgEIAQAAAA==.',['落雪']='落雪梨花:BAACKgAFFH8iAAQYAAQIjxmvHQDUAAAYAAMIjxmvHQDUAAAXAAQIyQydEwDHAAAWAAEI5QabKwA2AAAqAAQKfxsAAxgABwiwH3QmALcBABgABwifHHQmALcBABYABAi6HFhOANsAAAEqAAUUCAgQABYA3BoA.落雪樱花:BAAAKgAFFAMIAwAAAA==.',['蒲公']='蒲公英的约定:BAAAKgADCgEIAQAAAA==.',['蔣小']='蔣小柚:BAAAKgAFFAQIBAAAAA==.',['虎贲']='虎贲中郎将:BAAAKgAFFAQIBAAAAA==.',['虎长']='虎长老:BAAAKgAFFAIIBAAAAA==.',['蛛蛛']='蛛蛛丶丶:BAAAKgAFFAQIBAAAAA==.',['螳螂']='螳螂虾:BAAAKgAECgIIAgAAAA==.',['蠻给']='蠻给力:BAABKgAFFH8MAAIBAAYIKAmoCQDwAAABAAYIKAmoCQDwAAAAAA==.',['血洗']='血洗麒少:BAAAKgAECgcICAAAAA==.',['行止']='行止:BAAAKgAECgYIBwAAAA==.',['衢州']='衢州兔头:BAABKgAFFH8IAAMLAAgIRgfUOAAIAQALAAQIzgjUOAAIAQANAAQIOwVwEgBxAAAAAA==.',['衰气']='衰气逼人:BAAAKgAECgQIBAAAAA==.',['西梅']='西梅干:BAAAKgAECgIIAgAAAA==.',['诺乐']='诺乐:BAAAKgADCgIIAgAAAA==.',['诺文']='诺文:BAAAKgAFFAgIBAAAAA==.',['诺言']='诺言:BAAAKgAFFAgIBAAAAA==.',['豆干']='豆干:BAAAKgAFFAIIAgAAAA==.',['豆豆']='豆豆的棒棒糖:BAAAKgAFFAgIBAAAAA==.豆豆的骑士:BAACKgAFFH8QAAILAAMIUSAyMwAcAQALAAMIUSAyMwAcAQAqAAQKfxoAAgsACAgAInsnAH4CAAsACAgAInsnAH4CAAAA.',['贰細']='贰細:BAABKgAFFH8GAAIcAAYIAR0iBwCgAQAcAAYIAR0iBwCgAQAAAA==.',['超牛']='超牛死骑:BAAAKgAECgMICAAAAA==.',['超级']='超级巫婆:BAAAKgAFFAQIBAAAAA==.',['越过']='越过山丘:BAAAKgADCggICAAAAA==.',['跪求']='跪求壹敗:BAABKgAFFH8GAAILAAYI2QadMgAfAQALAAYI2QadMgAfAQAAAA==.',['跳跳']='跳跳和小乌龟:BAABKgAFFH8GAAIeAAYIfRxRDgCOAQAeAAYIfRxRDgCOAQAAAA==.',['轻抚']='轻抚后庭花:BAACKgAFFH8MAAMSAAMI5wzJPgCvAAASAAMI5wzJPgCvAAAcAAMIxwOSKwBxAAAqAAQKfxYAAxwACAgrFaQuAGkBABwABwgPFqQuAGkBABIABQiRE0J9AOAAAAAA.',['达不']='达不溜萨:BAAAKgAFFAgIAwAAAA==.',['达文']='达文希:BAAAKgAECgcICwAAAA==.',['还能']='还能提动刀:BAAAKgAFFAIIBAAAAA==.',['迦南']='迦南:BAAAKgAFFAgIBAAAAA==.',['迷森']='迷森鹿:BAAAKgADCgMIAwAAAA==.',['遗忘']='遗忘的星语:BAAAKgAECggIEwAAAA==.',['那夜']='那夜太墨迹:BAAAKgAECgYIBQAAAA==.那夜真给力:BAAAKgAECgUIBgAAAA==.',['邪将']='邪将:BAABKgAFFH8GAAMIAAYIqxvBAwCDAQAIAAUIuR/BAwCDAQAJAAEIcQtWFQBSAAAAAA==.',['邪恶']='邪恶少女魔酱:BAABKgAFFH8GAAIBAAYIGBwlCACZAQABAAYIGBwlCACZAQAAAA==.',['酷呆']='酷呆狂热:BAABKgAFFH8IAAIUAAQITxPeIADQAAAUAAQITxPeIADQAAAAAA==.',['野猪']='野猪乔治:BAAAKgAECgUIBQAAAA==.',['铁块']='铁块:BAAAKgADCgEIAQAAAA==.',['铁胩']='铁胩:BAAAKgAECgQIBQAAAA==.',['铁锅']='铁锅炖大德:BAABKgAFFH8GAAMSAAYIVBacEgDwAAASAAUIAhacEgDwAAAcAAEIyggAAAAAAAAAAA==.',['铁骑']='铁骑:BAAAKgAECgYIBgAAAA==.',['闪开']='闪开我来吧:BAAAKgAFFAMIAwAAAA==.',['间影']='间影呛咚呛:BAACKgAFFH9YAAMYAAgILyVkAADgAgAYAAgILyVkAADgAgAWAAEIex9ULgBcAAAqAAQKf1EABBgACAhwJugAAAYDABgACAhwJugAAAYDABYAAQgOG7h+AFcAABcAAQhUEY81ADkAAAAA.',['闻人']='闻人语:BAAAKgAECgQIBgAAAA==.',['闻薄']='闻薄阳又现雪:BAAAKgAFFAQIAgAAAA==.',['队长']='队长五百斤:BAAAKgAECggIEAAAAA==.',['阳光']='阳光得战:BAAAKgADCggICAAAAA==.阳光果粒橙:BAAAKgAFFAYIBAAAAA==.',['阿乏']='阿乏:BAAAKgAECgYIBgAAAA==.',['阿努']='阿努比斯杰:BAABKgAECn8fAAQLAAgInBRIZADSAQALAAgInBRIZADSAQAMAAQIUgb7QQB5AAANAAEI8AOBbAAMAAAAAA==.',['阿涵']='阿涵:BAABKgAFFH8NAAILAAQI+CCuMgAeAQALAAQI+CCuMgAeAQAAAA==.',['阿耀']='阿耀:BAACKgAFFH8rAAIBAAgIKCCzAgBWAgABAAgIKCCzAgBWAgAqAAQKfzkAAgEACAjaIqcNAFMCAAEACAjaIqcNAFMCAAAA.',['随意']='随意大小变:BAAAKgAECggIAQAAAA==.',['雀斑']='雀斑:BAAAKgAFFAQIBAAAAA==.',['雨落']='雨落单车:BAAAKgAFFAQIBAAAAA==.',['雪语']='雪语微微:BAAAKgAECggICwAAAA==.',['零千']='零千魂:BAABKgAFFH8HAAMRAAQIYhmcEgDKAAARAAQILxScEgDKAAAeAAMI8QwbHAC5AAABKgAFFAgIHAAKAPgfAA==.',['雷二']='雷二:BAABKgAECn8XAAIeAAgIfxhiGQCyAQAeAAgIfxhiGQCyAQAAAA==.',['雷大']='雷大:BAAAKgAECgYIDAAAAA==.',['霜晓']='霜晓寒姿:BAACKgAFFH8VAAMUAAQIRhTGDAA1AQAUAAQIRhTGDAA1AQAaAAII9g2yEwB8AAAqAAQKfzkAAxoACAghHqgSAAECABoACAiNG6gSAAECABQABwigF2Q3AEgBAAAA.',['霸王']='霸王崩山劲:BAAAKgAECgMIAwAAAA==.',['青蝶']='青蝶:BAABKgAFFH8MAAIXAAYIlxuDAwCaAQAXAAYIlxuDAwCaAQAAAA==.',['韩丶']='韩丶北地绿蚁:BAAAKgAECggICAAAAA==.',['风尘']='风尘细雨:BAABKgAECn8iAAMMAAgIhR2fFADNAQAMAAgIhR2fFADNAQALAAIIPg1yFwFTAAAAAA==.',['风清']='风清极道:BAABKgAFFH8FAAIZAAMIYw0CGwC4AAAZAAMIYw0CGwC4AAAAAA==.',['风飒']='风飒飒:BAAAKgAECgMIAwAAAA==.',['飓飓']='飓飓侠:BAABKgAFFH8GAAISAAYITBLOFwBaAQASAAYITBLOFwBaAQAAAA==.',['飘渺']='飘渺流氓:BAAAKgAECggIDwAAAA==.',['飞天']='飞天小龙人:BAABKgAFFH8GAAIEAAYIARIuEgBDAQAEAAYIARIuEgBDAQAAAA==.飞天激拔王:BAAAKgAECgQIBAAAAA==.飞天魔猎:BAABKgAECn8lAAIeAAgIaxnMNgAaAgAeAAgIaxnMNgAaAgAAAA==.',['饮水']='饮水机帅帅:BAABKgAECn8XAAIlAAgIWxoXDADmAQAlAAgIWxoXDADmAQAAAA==.',['马褂']='马褂不要了:BAAAKgAECggICwAAAA==.',['骨头']='骨头拨清波:BAAAKgAECgIIAgAAAA==.',['高级']='高级牛肉干:BAABKgAFFH8IAAMaAAgI6xLDDABCAQAaAAQIvRLDDABCAQAUAAQIKROBIgDJAAAAAA==.高级精兽肉干:BAAAKgAFFAIIAgAAAA==.',['高高']='高高名被占了:BAAAKgAECgMIAwAAAA==.',['鬼箭']='鬼箭羽:BAAAKgAFFAgIAwAAAA==.',['黑化']='黑化的骑士王:BAAAKgADCggICAAAAA==.',['黑大']='黑大叔:BAAAKgAFFAIIAgAAAA==.',['黑虎']='黑虎虾:BAAAKgAFFAIIBAAAAA==.',['龙猫']='龙猫殿下:BAABKgAFFH8MAAMUAAYIhR6XAQC9AQAUAAYI9hGXAQC9AQAaAAYIEB55CACDAQABKgAFFAgIFgAUANkUAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end