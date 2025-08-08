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
 local lookup = {'Warrior-Arms','Warrior-Fury','DemonHunter-Havoc','DeathKnight-Unholy','Mage-Arcane','Evoker-Devastation','Hunter-BeastMastery','Shaman-Restoration','Monk-Mistweaver','Druid-Guardian','Druid-Balance','DemonHunter-Vengeance','Paladin-Retribution','Paladin-Protection','Unknown-Unknown','Priest-Discipline','Priest-Shadow','Priest-Holy','DeathKnight-Frost','Hunter-Marksmanship','Mage-Frost','Druid-Restoration','Warrior-Protection','Mage-Fire','Warlock-Affliction','Rogue-Assassination','Rogue-Subtlety','DeathKnight-Blood','Warlock-Demonology','Warlock-Destruction','Paladin-Holy',}; local provider = {region='CN',realm='爱斯特纳',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aaoo:BAAAKgAECgMIAwAAAA==.',Ai='Aimee:BAABKgAECn8YAAMBAAgIMBbvBwDsAQABAAgIMBbvBwDsAQACAAYIYQz1TQAqAQAAAA==.',Bb='Bbnoe:BAAAKgAECggIAgAAAA==.',Ch='Charlotte:BAAAKgAFFAgIAQAAAA==.',Do='Dopamine:BAACKgAFFH8IAAICAAgIqx2aAgCgAgACAAgIqx2aAgCgAgAqAAQKfx8AAgIACAh+Df4xAGUBAAIACAh+Df4xAGUBAAAA.',Hi='Hisense:BAAAKgADCggICAAAAA==.',Ho='Hotwoman:BAAAKgAECggICAAAAA==.',Hu='Hunterx:BAABKgAFFH8JAAIDAAYIfxyhDQCpAQADAAYIfxyhDQCpAQAAAA==.',It='Itaeyeon:BAAAKgAECggICAAAAA==.',Kr='Krovath:BAABKgAFFH8MAAIEAAgIqQzqCQDuAQAEAAgIqQzqCQDuAQAAAA==.',Le='Legendary:BAAAKgAECgMIAwAAAA==.',Ma='Marcus:BAAAKgAECgUIBQAAAA==.Matts:BAAAKgAECgMIBAAAAA==.',Mk='Mkml:BAAAKgAECggIEAAAAA==.',Pa='Pandavip:BAAAKgAECggICAAAAA==.',Pi='Pikapika:BAAAKgAECggICQAAAA==.',Sh='Shadowpact:BAAAKgAECgMIAwAAAA==.',Sk='Skullheart:BAACKgAFFH8HAAIEAAMIeSBVJwDxAAAEAAMIeSBVJwDxAAAqAAQKfxkAAgQACAjsJKsEAPUCAAQACAjsJKsEAPUCAAAA.',Ss='Ssg:BAAAKgADCggICAAAAA==.',Te='Tedson:BAAAKgADCgQIBAAAAA==.',Wf='Wf:BAAAKgADCgEIAQAAAA==.',Za='Zafkiel:BAAAKgAECgEIAQAAAA==.',['一只']='一只柯基吖:BAAAKgAECgMIAwAAAA==.',['一姬']='一姬:BAAAKgAECgYICgAAAA==.',['三队']='三队的劣人:BAAAKgAECgMIAwAAAA==.',['上班']='上班咯:BAAAKgAECgIIAgAAAA==.',['不懂']='不懂丶:BAAAKgADCgIIAgAAAA==.',['东海']='东海:BAAAKgAECgMIAwAAAA==.',['丰收']='丰收祭:BAAAKgADCggICAAAAA==.',['丶千']='丶千水丶:BAABKgAFFH8IAAIFAAgILg0RCQDjAQAFAAgILg0RCQDjAQAAAA==.',['丶浮']='丶浮生未歇:BAAAKgAFFAQIBAABKgAFFAgICAAEADwlAA==.',['丶烈']='丶烈焰风暴:BAAAKgAECgMIAwAAAA==.',['丶碎']='丶碎裂星辰:BAABKgAFFH8GAAIGAAYIBhgIDgCAAQAGAAYIBhgIDgCAAQAAAA==.',['丷烽']='丷烽火连城丷:BAABKgAECn8bAAIHAAgIQhTpGgCjAQAHAAgIQhTpGgCjAQAAAA==.',['丿先']='丿先祖灬指引:BAABKgAFFH8GAAIIAAUIJx8VBgApAQAIAAUIJx8VBgApAQAAAA==.',['丿荣']='丿荣耀灬光辉:BAAAKgAFFAQIAwAAAA==.',['丿风']='丿风暴灬酿酒:BAABKgAFFH8GAAIJAAYICQ/+AwCBAQAJAAYICQ/+AwCBAQAAAA==.',['丿黑']='丿黑暗灬语者:BAAAKgAFFAgIBAAAAA==.',['五十']='五十三度酱香:BAAAKgADCgMIAwAAAA==.',['仓储']='仓储负责人:BAACKgAFFH8PAAIKAAQIdAdrCgBrAAAKAAQIdAdrCgBrAAAqAAQKfyAAAwoACAjZEZoVAFoBAAoACAjZEZoVAFoBAAsAAQhVBX7oABIAAAAA.',['仙亦']='仙亦慕红尘:BAAAKgAECgYIBgAAAA==.',['任性']='任性天使:BAAAKgADCgYIBgAAAA==.',['伊丷']='伊丷利丹:BAAAKgADCggICAAAAA==.',['伊什']='伊什塔尔:BAAAKgAECgIIAgAAAA==.',['伊小']='伊小蛋:BAABKgAECn8UAAIMAAgIiQ4nLQAgAQAMAAgIiQ4nLQAgAQAAAA==.',['会潜']='会潜水的小胖:BAAAKgAECggIEAAAAA==.',['会飞']='会飞的小胖:BAAAKgAFFAMIAwAAAA==.会飞的狼:BAAAKgADCgEIAQAAAA==.会飞的许浩:BAAAKgAECggICQAAAA==.',['余争']='余争:BAABKgAFFH8RAAMMAAUI2xRGDwDKAAAMAAMIchZGDwDKAAADAAIIeBLQNwChAAAAAA==.',['依然']='依然丶酋长:BAAAKgADCgIIAgAAAA==.',['依竹']='依竹笑怜丶:BAAAKgAECgcIBwAAAA==.',['侠肠']='侠肠无医:BAABKgAFFH8LAAIJAAMI4BDhFgDEAAAJAAMI4BDhFgDEAAAAAA==.',['俏无']='俏无双:BAAAKgAFFAgIBAAAAA==.',['傻傻']='傻傻的傻馒:BAACKgAFFH8HAAIIAAIIqRowHwCdAAAIAAIIqRowHwCdAAAqAAQKfx0AAggACAjXIJEOAIMCAAgACAjXIJEOAIMCAAAA.',['先驱']='先驱猎手:BAAAKgADCggICAAAAA==.',['克里']='克里斯汀小七:BAACKgAFFH8VAAINAAQItBuvRQDjAAANAAQItBuvRQDjAAAqAAQKfxQAAg0ACAgiGi9vAHgBAA0ACAgiGi9vAHgBAAAA.',['兰斯']='兰斯珞特:BAAAKgAECggICAAAAA==.',['兹德']='兹德拉斯特维:BAABKgAECn8WAAMNAAgIdhxBPAAQAgANAAgIdhxBPAAQAgAOAAEIZAAAAAAAAAAAAA==.',['冥之']='冥之爱过:BAAAKgAECgYIBAABKgAECgcICwAPAAAAAA==.',['冥殇']='冥殇小象:BAAAKgAECgIIAgAAAA==.',['冰凌']='冰凌无双:BAAAKgADCggICAAAAA==.',['冰牛']='冰牛奶丶:BAAAKgAFFAQIBAABKgAFFAgIDwAQAM4XAA==.',['冰蝕']='冰蝕:BAAAKgAECggIEAAAAA==.',['凯伦']='凯伦怀特:BAAAKgAECgEIAQAAAA==.',['刀不']='刀不玩要玩贱:BAAAKgAECgIIAgAAAA==.',['刁德']='刁德一:BAAAKgADCgQIBAAAAA==.',['创世']='创世神话:BAAAKgAECgMIAwAAAA==.',['别枝']='别枝惊鹊:BAAAKgAECgYIDgAAAA==.',['到底']='到底有多难玩:BAABKgAFFH8IAAIDAAQIRRZGFADvAAADAAQIRRZGFADvAAAAAA==.',['动感']='动感槌子:BAAAKgAECgYICQAAAA==.',['千年']='千年那天:BAABKgAFFH8IAAMRAAgIFxLHGQCWAAARAAUI/hDHGQCWAAASAAMI1ArRMACDAAAAAA==.',['卡皮']='卡皮巴拉:BAAAKgADCgYIBgAAAA==.',['双瞳']='双瞳三季稻:BAABKgAECn8UAAMNAAYIbAdYBQGvAAANAAUIzwhYBQGvAAAOAAMIOwKpXgASAAAAAA==.',['变身']='变身前很帅:BAAAKgADCgEIAQAAAA==.',['古一']='古一:BAAAKgAECgQIBAAAAA==.',['古因']='古因达鲁:BAAAKgAECgcIDAAAAA==.',['另一']='另一面牧:BAAAKgAECggICAAAAA==.',['只知']='只知道加血:BAAAKgAFFAgIBAAAAA==.',['听雨']='听雨:BAAAKgADCggICAAAAA==.',['呆呆']='呆呆大魔王:BAAAKgAECgEIAQAAAA==.',['咩哆']='咩哆哆:BAABKgAFFH8NAAMDAAgILRPMCQAoAQADAAgILRPMCQAoAQAMAAMIqQnlDACbAAAAAA==.',['哈牛']='哈牛:BAAAKgAECgUIBQAAAA==.',['唐伯']='唐伯虎点蚊香:BAAAKgAECgYIBgAAAA==.',['唱歌']='唱歌的小胖:BAAAKgADCggICAAAAA==.',['唾液']='唾液王:BAACKgAFFH8JAAMEAAgI7x68AgCkAgAEAAgI7x68AgCkAgATAAEI6gnaCQA6AAAqAAQKfywAAxMACAhBH9kGAFkCABMACAgsH9kGAFkCAAQACAhpG5UcACsCAAAA.',['嘟小']='嘟小宝的牧牧:BAABKgAFFH8SAAMSAAYIORUECQBOAQASAAYIORUECQBOAQARAAYIcwnXDQAjAQAAAA==.嘟小宝的萨满:BAAAKgAFFAYIBAAAAA==.',['圣狄']='圣狄亚之弦:BAABKgAFFH8JAAIUAAYIQR11DgB3AQAUAAYIQR11DgB3AQAAAA==.圣狄亚之牧:BAAAKgAFFAgIAQAAAA==.圣狄亚之翼:BAAAKgAFFAQIBAAAAA==.',['圣童']='圣童战:BAAAKgADCggICAAAAA==.',['塔子']='塔子弟:BAAAKgADCgMIAwAAAA==.',['夜神']='夜神弯月:BAAAKgAECgEIAQAAAA==.',['夜雨']='夜雨声煩:BAAAKgADCgEIAQAAAA==.',['大藶']='大藶出奇迹:BAAAKgAECgMIAwAAAA==.',['大长']='大长腿萝莉:BAAAKgAECgIIAwAAAA==.',['天兵']='天兵神折:BAABKgAECn8UAAIVAAgIBB5PBQB0AgAVAAgIBB5PBQB0AgAAAA==.',['天堂']='天堂树下的影:BAABKgAFFH8FAAMWAAUIlQsHGAB7AAAWAAQIlA0HGAB7AAALAAEIfQkYXABDAAAAAA==.',['太乙']='太乙丶:BAAAKgADCgUICgAAAA==.',['夹缝']='夹缝:BAABKgAFFH8IAAIFAAgIwgMRDwBCAQAFAAgIwgMRDwBCAQAAAA==.',['奶你']='奶你呢别着急:BAAAKgAFFAYIAwAAAA==.',['姬儿']='姬儿加蛋:BAAAKgAFFAIIAwAAAA==.',['娜尼']='娜尼雅:BAABKgAECn85AAIIAAgISB6EGQA7AgAIAAgISB6EGQA7AgAAAA==.',['孤单']='孤单小乖:BAAAKgAECggICAAAAA==.',['守妮']='守妮:BAAAKgAECgIIAgAAAA==.',['守護']='守護之光:BAAAKgAECgUIBQAAAA==.',['安思']='安思塔利亚:BAAAKgADCggIEAAAAA==.',['安格']='安格隆:BAABKgAECn8iAAMBAAgIvAtiNAD4AAABAAgIiwliNAD4AAACAAgIfAg8YgDNAAAAAA==.',['安沐']='安沐拜艾克:BAABKgAFFH8PAAIDAAYIfCBqBQB/AQADAAYIfCBqBQB/AQAAAA==.',['安胡']='安胡拉阿克巴:BAABKgAECn8WAAMCAAgIDw5INwBIAQACAAcIIBBINwBIAQAXAAgICwR6KwCsAAAAAA==.',['完美']='完美驯兽师:BAAAKgADCggICQAAAA==.',['寄半']='寄半分渴望:BAAAKgAECgcICgAAAA==.',['寒冰']='寒冰碎片:BAACKgAFFH8JAAMVAAMIehjpEgDNAAAVAAMIehjpEgDNAAAYAAEImwErQgAtAAAqAAQKfyYAAxUACAjiGwQZADoCABUACAjiGwQZADoCABgABwh1DBZRADcBAAAA.',['寒鋒']='寒鋒冷锷:BAAAKgADCgUIBQAAAA==.',['小事']='小事呵呵哒:BAACKgAFFH8eAAQFAAYIsCVgBgAiAgAFAAYIqSVgBgAiAgAYAAYILxZGDQBkAQAVAAQIfiRlDAAGAQAqAAQKfxkAAxUACAgEGLExAKwBABUACAgEGLExAKwBABgAAwh6Bwc/AFoAAAEqAAUUCAgUAAUANCMA.',['小半']='小半:BAAAKgAFFAQIBAAAAA==.',['小小']='小小豌豆:BAAAKgAECgIIAgAAAA==.',['小德']='小德怎么又:BAAAKgAECggICAAAAA==.',['小牛']='小牛牛丶托斯:BAAAKgAECgYICwABKgAECggINgAIAMsiAA==.',['小老']='小老虎呀呀哒:BAAAKgADCggICAAAAA==.',['小萨']='小萨儿:BAAAKgAFFAIIAgAAAA==.',['小马']='小马萨:BAAAKgADCggICAAAAA==.',['小鸽']='小鸽:BAAAKgADCgEIAQAAAA==.',['就是']='就是炫:BAAAKgAECggICAAAAA==.',['就爱']='就爱葬吻梦蝶:BAAAKgADCgYIBgAAAA==.',['工头']='工头儿:BAAAKgADCgEIAQAAAA==.',['巫女']='巫女玲儿:BAABKgAFFH8IAAIZAAQIbhebCADlAAAZAAQIbhebCADlAAAAAA==.',['巫毒']='巫毒之神:BAAAKgADCgEIAQAAAA==.',['希尔']='希尔瓦纳斯:BAAAKgAFFAYIBAAAAA==.',['希瓦']='希瓦丶:BAAAKgAECgQIBAAAAA==.',['庄生']='庄生大萌:BAAAKgAECggICQAAAA==.',['序列']='序列零:BAAAKgADCgEIAQAAAA==.',['库拉']='库拉:BAABKgAFFH8FAAMaAAQIExkYFwDuAAAaAAQIExkYFwDuAAAbAAEIgRZ6DwBVAAAAAA==.',['开心']='开心灬至尊:BAAAKgADCggICAAAAA==.',['彩云']='彩云的回忆:BAAAKgADCgIIAgAAAA==.',['影之']='影之泪痕:BAAAKgAECgQIBAAAAA==.',['微笑']='微笑的蒂蕾莎:BAAAKgAECgcICAAAAA==.',['心星']='心星:BAAAKgADCgYIBgAAAA==.',['悦妞']='悦妞:BAAAKgAFFAEIAQAAAA==.',['感谢']='感谢物理法则:BAACKgAFFH8FAAIWAAMIXQ0fIwCaAAAWAAMIXQ0fIwCaAAAqAAQKfxoAAhYACAj+EzwzACIBABYACAj+EzwzACIBAAAA.',['愤怒']='愤怒的泡泡:BAAAKgADCgQIBAAAAA==.',['懿妖']='懿妖精:BAAAKgADCgEIAQAAAA==.',['我只']='我只吃素:BAAAKgAECgYIBgAAAA==.',['我是']='我是鱼鹅:BAABKgAFFH8GAAIOAAQIHxh4FwC8AAAOAAQIHxh4FwC8AAAAAA==.',['手握']='手握风云:BAAAKgADCggICAAAAA==.',['提里']='提里兰尼斯特:BAAAKgAECggIEAAAAA==.',['撕袜']='撕袜骑士:BAABKgAECn8ZAAMTAAgIRRRnEQCTAQATAAgIjRJnEQCTAQAcAAgIRw0WJQAgAQAAAA==.',['撩汉']='撩汉大婶:BAAAKgAECgYIBgAAAA==.',['收割']='收割一手:BAAAKgADCgEIAQAAAA==.',['敏行']='敏行慎言:BAAAKgAECgYICgAAAA==.',['救命']='救命恩人:BAABKgAFFH8MAAICAAgIqRc9BABvAgACAAgIqRc9BABvAgAAAA==.',['救赎']='救赎躯体:BAAAKgAECggICgAAAA==.',['敗家']='敗家丶劈叉:BAABKgAECn8WAAMNAAgIGwqjPwALAQANAAgIGwqjPwALAQAOAAEIAQLsXgARAAAAAA==.',['方块']='方块十三:BAAAKgAECgQIBAAAAA==.',['无惧']='无惧无畏:BAAAKgAECgIIAgAAAA==.',['无畏']='无畏无惧:BAAAKgAECggICAAAAA==.',['昏晓']='昏晓:BAAAKgAECgUIBQAAAA==.',['星罗']='星罗:BAABKgAECn8mAAINAAgIWRbPYQDYAQANAAgIWRbPYQDYAQAAAA==.',['暗燃']='暗燃小红:BAAAKgAECgUICQABKgAECgcICwAPAAAAAA==.',['暗血']='暗血风铃:BAAAKgADCgEIAQAAAA==.',['暮雨']='暮雨醉秋梦:BAAAKgAFFAQIBAAAAA==.',['暴风']='暴风游侠:BAAAKgAECgcICAAAAA==.',['朝丨']='朝丨歌:BAAAKgAECgIIAgAAAA==.',['朱鹤']='朱鹤普渡沧溟:BAAAKgAECgMIAwAAAA==.',['杉多']='杉多伊俐丹:BAAAKgADCgIIBAAAAA==.',['東來']='東來:BAAAKgAECgIIAgAAAA==.',['松下']='松下梨合:BAAAKgADCggICAAAAA==.',['枫树']='枫树种子:BAAAKgADCgIIAgAAAA==.',['柠檬']='柠檬酸:BAAAKgADCgUIBQAAAA==.',['桂妮']='桂妮薇尔:BAAAKgAFFAQIBAAAAA==.',['梅花']='梅花十三:BAAAKgAFFAgIBAAAAA==.',['梦昏']='梦昏昏:BAAAKgADCgQIBAAAAA==.',['橙色']='橙色长鼻象:BAAAKgAECgYIDQAAAA==.',['毛利']='毛利丶兰:BAABKgAECn86AAIHAAgIMiH8HwBAAgAHAAgIMiH8HwBAAgAAAA==.',['水蓝']='水蓝冰凌:BAAAKgAFFAgIAwAAAA==.',['江北']='江北小鸡:BAABKgAECn8cAAINAAgIByVWDgDfAgANAAgIByVWDgDfAgAAAA==.',['沈阳']='沈阳制造:BAABKgAECn8hAAICAAgIZBZZHgDgAQACAAgIZBZZHgDgAQAAAA==.',['法神']='法神:BAABKgAFFH8LAAIYAAYIrB9oAgD3AQAYAAYIrB9oAgD3AQAAAA==.',['浪丶']='浪丶飞儿:BAAAKgAECgcICwAAAA==.',['海佩']='海佩佩:BAAAKgAECggICgAAAA==.',['海潮']='海潮贤者托斯:BAABKgAECn82AAIIAAgIyyLHCwCYAgAIAAgIyyLHCwCYAgAAAA==.',['海豚']='海豚有海:BAAAKgAFFAEIAQAAAA==.',['消磨']='消磨时间:BAAAKgAECgcIBwAAAA==.消磨时间二号:BAAAKgAFFAQIBAAAAA==.',['清心']='清心晚风:BAAAKgADCggICAAAAA==.',['清源']='清源:BAAAKgAECgYIBgAAAA==.',['渐入']='渐入佳境:BAAAKgADCggICAAAAA==.',['漆黑']='漆黑的追踪者:BAAAKgAECgYIBgAAAA==.',['潶潶']='潶潶:BAACKgAFFH8VAAQdAAUIzRfLDgDCAAAdAAMIERPLDgDCAAAZAAIIURfaGwBMAAAeAAEIUhYkMABGAAAqAAQKfysABB4ACAiXIOAUAEcCAB4ACAiXIOAUAEcCAB0ABgiUE8ktADMBABkAAgjJGps/AEcAAAAA.',['火山']='火山堆雪:BAAAKgADCgEIAQAAAA==.',['火法']='火法:BAAAKgAFFAQIBAAAAA==.',['灬星']='灬星矢灬:BAAAKgAECgUIBQAAAA==.',['灬菲']='灬菲菲灬:BAAAKgADCgMIAwAAAA==.',['烟雨']='烟雨小熊熊:BAACKgAFFH8KAAINAAMIKAhjRAB8AAANAAMIKAhjRAB8AAAqAAQKfx4AAw0ACAgaEm6TAHABAA0ACAgaEm6TAHABAA4AAQj3A+FqAA8AAAAA.',['熊凶']='熊凶胸:BAAAKgADCggICAAAAA==.',['熊猫']='熊猫傻慢:BAAAKgAECgYIBgAAAA==.',['熊胸']='熊胸凶:BAAAKgAECggICAAAAA==.',['爆雨']='爆雨梨花:BAABKgAFFH8OAAMUAAUIBBieCQD7AAAUAAQIVx6eCQD7AAAHAAUIAwekKQCpAAABKgAFFAgIEwAHAOUdAA==.',['爱丝']='爱丝特娜:BAAAKgAFFAcIBAAAAA==.',['狂奔']='狂奔五百里:BAAAKgADCggIDAAAAA==.',['猎手']='猎手惧魔:BAAAKgAECgYIBgAAAA==.',['猫哆']='猫哆哆:BAABKgAFFH8KAAMQAAgIEx7PCgBpAQAQAAgIEx7PCgBpAQASAAEIoiCWIgBFAAAAAA==.',['王健']='王健将:BAABKgAFFH8GAAIaAAYIARtuCgCnAQAaAAYIARtuCgCnAQAAAA==.',['王小']='王小布丁:BAAAKgAECgMIAwAAAA==.',['琴瑟']='琴瑟和鸣:BAAAKgADCgUIBQAAAA==.',['瓜不']='瓜不保熟:BAAAKgAECgIIAgAAAA==.',['瓦蓝']='瓦蓝三季稻:BAAAKgAECgUIBQAAAA==.',['男神']='男神:BAAAKgAECggICgAAAA==.',['白雪']='白雪公主:BAAAKgAECgEIAgAAAA==.',['盾牧']='盾牧:BAAAKgADCgEIAQAAAA==.',['看那']='看那东风:BAAAKgAECggICAAAAA==.',['矮的']='矮的有形:BAABKgAFFH8MAAMNAAYIzBEOFABdAQANAAYIzBEOFABdAQAfAAYIxQfjBgAKAQAAAA==.',['示斤']='示斤祷:BAABKgAFFH8GAAIaAAYIzBbuAQC2AQAaAAYIzBbuAQC2AQAAAA==.',['神圣']='神圣的小胖:BAABKgAFFH8NAAINAAgIMiBjAwCvAgANAAgIMiBjAwCvAgAAAA==.',['秘书']='秘书子:BAAAKgAFFAUIAQAAAA==.',['空白']='空白的木瓜:BAAAKgADCggICAAAAA==.',['米洛']='米洛:BAAAKgAECggICAAAAA==.',['糖糖']='糖糖兔:BAAAKgAECgYIDAAAAA==.',['素描']='素描老师:BAAAKgAECgUIBQAAAA==.',['紫魔']='紫魔仙小豪:BAAAKgADCgEIAQAAAA==.',['縌不']='縌不倒翁:BAAAKgAECgYIBgAAAA==.',['红烧']='红烧大鳄鱼:BAAAKgAECgYIBgAAAA==.',['红狐']='红狐狸:BAAAKgADCgcIBwAAAA==.',['红魔']='红魔仙小豪:BAAAKgAECggICAAAAA==.',['绝不']='绝不姑息:BAAAKgADCgEIAQAAAA==.',['绝对']='绝对鄙视胖子:BAABKgAFFH8YAAMVAAYISiUOAgAHAgAVAAYISiUOAgAHAgAYAAYImw4BEABGAQABKgAFFAgIEwAJAE0iAA==.',['绮绮']='绮绮猫:BAABKgAFFH8NAAQSAAgIYg7KDABYAQASAAcInw/KDABYAQAQAAIImw2yFgCrAAARAAEIqRw6KQBMAAAAAA==.',['缚冰']='缚冰星术师:BAAAKgAECgUIBQAAAA==.',['缚灵']='缚灵星术师:BAAAKgAECggICQAAAA==.',['美少']='美少女:BAAAKgADCggICAAAAA==.',['翼王']='翼王:BAAAKgADCgEIAgAAAA==.',['老婆']='老婆辛苦了:BAABKgAFFH8IAAICAAgIAQ1zBgAHAgACAAgIAQ1zBgAHAgAAAA==.',['联盟']='联盟第壹美女:BAAAKgAECgUIBQAAAA==.',['胡服']='胡服骑射:BAAAKgAECggIDwAAAA==.',['脸萌']='脸萌圣骑丝:BAAAKgAECgEIAQAAAA==.',['艾利']='艾利婕丶血歌:BAAAKgAECgYIBgAAAA==.',['艾尔']='艾尔特斯:BAABKgAECn8mAAIcAAgI1xjNFgDnAQAcAAgI1xjNFgDnAQAAAA==.',['艾欧']='艾欧尔斯:BAAAKgAFFAMIAwAAAA==.',['艾瑞']='艾瑞利娅:BAAAKgADCgUIBQAAAA==.',['艾芳']='艾芳瑟琳:BAAAKgAECgYICgAAAA==.',['艾莎']='艾莎云歌:BAAAKgAECgMIAwAAAA==.',['艾蕾']='艾蕾什基嘉勒:BAACKgAFFH8IAAMSAAgIsgxBCABlAQASAAcI3Q1BCABlAQAQAAEIswXmMABMAAAqAAQKfx4ABBAACAgcFH4iALgBABAACAgcFH4iALgBABEABghEDFRBAPQAABIAAQhdGyB3AE4AAAAA.',['花花']='花花牛哞哞:BAABKgAECn8VAAIIAAgIlRfSLADIAQAIAAgIlRfSLADIAQAAAA==.',['苦完']='苦完:BAAAKgADCggICAAAAA==.',['英姿']='英姿飒爽:BAAAKgADCggICAAAAA==.',['莯浴']='莯浴阳光:BAAAKgAECgEIAQAAAA==.',['莯红']='莯红尘:BAAAKgAECgQICAAAAA==.',['菲列']='菲列特利加:BAAAKgAECggICwAAAA==.',['萌新']='萌新欢乐多:BAAAKgADCgIIAwAAAA==.',['萨斯']='萨斯利尔:BAABKgAECn8ZAAITAAgI7R3OCgD6AQATAAgI7R3OCgD6AQAAAA==.',['落無']='落無風:BAAAKgAECgUICAABKgAECgcICwAPAAAAAA==.',['葬爱']='葬爱你崔哥:BAAAKgAFFAYIBAAAAA==.',['蕊仔']='蕊仔一号:BAABKgAFFH8MAAIeAAYIkBbeFABdAQAeAAYIkBbeFABdAQAAAA==.蕊仔零号:BAAAKgAECgEIAQAAAA==.',['蛋丹']='蛋丹:BAAAKgAECgEIAQAAAA==.',['蛋蛋']='蛋蛋有伤:BAAAKgADCgEIAQAAAA==.',['蟹堡']='蟹堡王白大厨:BAAAKgAECgQIBAAAAA==.',['血染']='血染之路:BAAAKgADCggICAAAAA==.',['袁罡']='袁罡:BAAAKgAFFAYIBAAAAA==.',['西瓜']='西瓜籽儿:BAAAKgADCgcIBwAAAA==.',['西红']='西红柿炒蛋:BAAAKgAFFAYIAgAAAA==.',['见崎']='见崎鸣一:BAAAKgAECggICAAAAA==.',['诺瓦']='诺瓦星云:BAAAKgADCggICAAAAA==.',['负反']='负反馈螺旋:BAABKgAECn8hAAQTAAgIphGBEwBfAQATAAgIhBCBEwBfAQAEAAYI8grNfgDoAAAcAAcIiAk9OwDWAAAAAA==.',['走到']='走到哪混到哪:BAABKgAFFH8GAAIeAAYIbg8mFABkAQAeAAYIbg8mFABkAQAAAA==.',['跑题']='跑题大王:BAAAKgAECgIIAgAAAA==.',['身材']='身材魔鬼:BAABKgAECn8tAAIeAAgIhBOcLQBfAQAeAAgIhBOcLQBfAQAAAA==.',['轩辕']='轩辕疚疯:BAAAKgADCggIFQAAAA==.',['达娜']='达娜夜风:BAABKgAECn81AAIHAAgIVBGBXgCVAQAHAAgIVBGBXgCVAQAAAA==.',['还珠']='还珠格格:BAAAKgAECgcIBwAAAA==.',['逍遥']='逍遥豌豆:BAAAKgAECggIDgAAAA==.',['透明']='透明窗帘:BAAAKgAECggIDAAAAA==.',['邪恶']='邪恶白毛熊:BAABKgAFFH8IAAIIAAYIshT5AQCHAQAIAAYIshT5AQCHAQAAAA==.',['钓鱼']='钓鱼不打窝:BAAAKgADCgIIAgAAAA==.',['铁马']='铁马红颜:BAAAKgAECgUIBwAAAA==.',['银眼']='银眼泰蓝德:BAABKgAECn8nAAIWAAgIbRU5IwCwAQAWAAgIbRU5IwCwAQAAAA==.',['長崎']='長崎素世:BAAAKgAECgIIAgAAAA==.',['阿梓']='阿梓:BAAAKgADCggICAAAAA==.',['陆军']='陆军元帅:BAAAKgADCggICAAAAA==.',['雨落']='雨落听风:BAAAKgADCgEIAQAAAA==.',['雪山']='雪山上的汪:BAABKgAFFH8JAAINAAYIKBBDJwBLAQANAAYIKBBDJwBLAQAAAA==.',['雪鹿']='雪鹿啤酒托斯:BAAAKgAECgYICQABKgAECggINgAIAMsiAA==.',['霍森']='霍森布鲁次:BAABKgAECn8WAAIaAAgIKA9lHACfAQAaAAgIKA9lHACfAQAAAA==.',['霸魃']='霸魃紅:BAAAKgAECggIEAAAAA==.',['霹雳']='霹雳三哥:BAAAKgAECgEIAQAAAA==.',['非洲']='非洲的白脸:BAAAKgAFFAEIAQAAAA==.',['風暴']='風暴壁垒:BAAAKgADCggICAAAAA==.',['风一']='风一样的自由:BAAAKgADCgEIAQAAAA==.',['风中']='风中的叹息:BAAAKgAECgEIAQAAAA==.',['风之']='风之冰霜:BAABKgAECn8VAAMUAAgIpAgnJgDmAAAUAAgIpAgnJgDmAAAHAAMI2gMR/AA/AAAAAA==.风之飒:BAAAKgAECgIIAgAAAA==.',['风影']='风影狂:BAAAKgAECggICAAAAA==.',['风流']='风流丶:BAAAKgAECgMIAwAAAA==.',['风灵']='风灵月影:BAABKgAFFH8KAAINAAYIrA6wKABFAQANAAYIrA6wKABFAQAAAA==.',['风走']='风走云流:BAAAKgAECgcICAAAAA==.',['飞翔']='飞翔的企鹅:BAAAKgAECgEIAQAAAA==.',['飞虎']='飞虎队:BAAAKgAECgEIAQAAAA==.',['香烟']='香烟吥离手:BAAAKgAECggIEgAAAA==.',['魅瞳']='魅瞳:BAAAKgAECgQIBQAAAA==.',['魔灵']='魔灵法老:BAAAKgADCgIIBAAAAA==.',['魔界']='魔界玄武:BAAAKgAECgUIBgAAAA==.',['鸽子']='鸽子:BAAAKgADCgEIAQAAAA==.',['鹿胡']='鹿胡子:BAAAKgAECgEIAQAAAA==.',['麦克']='麦克阿猎:BAAAKgAECgUIBQAAAA==.',['黑色']='黑色的小象:BAAAKgAECgYIBgAAAA==.黑色的长鼻象:BAABKgAECn8cAAIBAAgIPhRyHwC5AQABAAgIPhRyHwC5AQAAAA==.',['齊天']='齊天乖乖:BAAAKgAECgEIAQAAAA==.齊天肉牛牛:BAAAKgADCggICAAAAA==.',['龙希']='龙希尔丶:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end