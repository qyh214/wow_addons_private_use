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
 local lookup = {'Paladin-Retribution','DeathKnight-Unholy','DeathKnight-Blood','Shaman-Enhancement','DeathKnight-Frost','Warlock-Affliction','Warlock-Destruction','Priest-Holy','Priest-Discipline','Warrior-Fury','Mage-Frost','Druid-Balance','Druid-Restoration','Priest-Shadow','Rogue-Assassination','Shaman-Restoration','Mage-Arcane','Mage-Fire','Paladin-Protection','DemonHunter-Havoc','Hunter-Marksmanship','Evoker-Devastation','Evoker-Preservation','Monk-Mistweaver','Monk-Windwalker','Monk-Brewmaster','Hunter-BeastMastery','Unknown-Unknown','Druid-Feral','Warrior-Arms',}; local provider = {region='CN',realm='塔纳利斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ca='Cassiebaby:BAAAKgADCggICAAAAA==.',Ce='Ceeya:BAABKgAFFH8GAAIBAAYI1iHBFQCtAQABAAYI1iHBFQCtAQAAAA==.',Ck='Ckc:BAABKgAFFH8OAAMCAAYIYB8MCAAqAQADAAYINRzjCgBjAQACAAQIGiAMCAAqAQAAAA==.',Cl='Clrak:BAABKgAFFH8KAAIBAAYIpBiaIgBiAQABAAYIpBiaIgBiAQABKgAFFAgICgAEAIUNAA==.',Dk='Dknight:BAACKgAFFH8SAAICAAYIdxW0BgA5AQACAAYIdxW0BgA5AQAqAAQKfzUAAwIACAhaH1wgAEACAAIACAjJHlwgAEACAAUABwhUEB4XACkBAAAA.',Dw='Dwada:BAAAKgADCgQIBQAAAA==.',Ie='Ieros:BAAAKgAFFAYIBAAAAA==.',Jo='Joana:BAAAKgAECgQIBQAAAA==.',Ma='Maxii:BAAAKgAECggIAwAAAA==.',Mo='Moonkin:BAAAKgAFFAQIBAAAAA==.',Mu='Muda:BAAAKgAFFAQIBAAAAA==.',Pl='Playerfmkirp:BAAAKgADCgYIBgAAAA==.',Po='Poena:BAABKgAFFH8IAAMGAAQIZx+TCgDgAAAGAAQIZx+TCgDgAAAHAAEIAACLPAAAAAAAAA==.',Va='Vassago:BAAAKgADCgIIAgAAAA==.',Yi='Yiesus:BAABKgAFFH8GAAMIAAQIGxM5DgDLAAAIAAQIaw85DgDLAAAJAAIIIha4GACbAAAAAA==.',['一地']='一地鸡毛:BAABKgAECn8ZAAIKAAgIixteFAA2AgAKAAgIixteFAA2AgAAAA==.',['一天']='一天都顶起:BAACKgAFFH8MAAILAAMIwRbdDwCnAAALAAMIwRbdDwCnAAAqAAQKfyAAAgsACAhEHqASAC0CAAsACAhEHqASAC0CAAAA.',['不好']='不好不坏:BAAAKgADCgEIAQAAAA==.',['不死']='不死牛:BAAAKgAFFAQIBAAAAA==.',['中老']='中老年再就业:BAAAKgADCgMIAwAAAA==.',['临风']='临风听蝉:BAABKgAECn8fAAMMAAgIWBxSOwDKAQAMAAgIWBxSOwDKAQANAAQIKRnZNAAaAQAAAA==.',['丶烁']='丶烁烁:BAABKgAFFH8GAAIBAAYISxLuFQBBAQABAAYISxLuFQBBAQAAAA==.',['丶闪']='丶闪闪:BAABKgAFFH8GAAIDAAYIYQWVGwDGAAADAAYIYQWVGwDGAAAAAA==.',['伊暮']='伊暮:BAABKgAFFH8KAAIOAAYIShumCACAAQAOAAYIShumCACAAQAAAA==.',['伟大']='伟大伟大伟大:BAAAKgADCgEIAQAAAA==.',['你先']='你先斩:BAABKgAFFH8IAAIKAAQIsAQVKQCjAAAKAAQIsAQVKQCjAAAAAA==.',['依然']='依然随风:BAABKgAFFH8TAAIBAAgILyE3BACYAgABAAgILyE3BACYAgAAAA==.',['偷你']='偷你光光:BAABKgAFFH8IAAIPAAQI0RYXCQD8AAAPAAQI0RYXCQD8AAAAAA==.',['傲魂']='傲魂魅影:BAAAKgAFFAYIAgAAAA==.',['兜兜']='兜兜里有红:BAAAKgADCgEIAQAAAA==.',['全球']='全球皆可飞:BAAAKgAECggIEQAAAA==.',['八八']='八八呀八八:BAAAKgADCgEIAwAAAA==.',['八级']='八级小狂风:BAAAKgAFFAYIAgAAAA==.',['兰兰']='兰兰吖兰兰:BAAAKgADCgIIAgAAAA==.',['兰卡']='兰卡威豪仔:BAAAKgAECgYIDgAAAA==.',['冷艳']='冷艳冻人:BAAAKgAECgIIAgAAAA==.',['十二']='十二路弹腿:BAABKgAFFH8LAAIQAAgIUgpcCACPAQAQAAgIUgpcCACPAQAAAA==.',['卡尔']='卡尔瓦罗森:BAAAKgAECgcIDQAAAA==.卡尔萨雷徳:BAAAKgAECgUIBQAAAA==.',['又好']='又好又坏:BAAAKgADCggIDQAAAA==.',['双锤']='双锤天下:BAAAKgAECgMIAwAAAA==.',['叫妈']='叫妈妈:BAAAKgAECgMIAwAAAA==.',['命运']='命运之裁决:BAAAKgADCgIIAgAAAA==.',['哟法']='哟法热儿:BAAAKgADCgIIAwAAAA==.',['嗜血']='嗜血小乖:BAAAKgAECggIBgAAAA==.',['嘻嘻']='嘻嘻嘿嘿吼吼:BAAAKgADCgEIAgAAAA==.',['太慌']='太慌张的拥抱:BAAAKgAECgYIBgAAAA==.',['夹心']='夹心灬盖伦:BAAAKgADCgEIAQAAAA==.夹心甜点:BAACKgAFFH8SAAQLAAcIEh1PCQAuAQARAAYIsxjpEgBOAQALAAQIpSNPCQAuAQASAAEI4g2DNwBbAAAqAAQKfyAAAwsACAiCJpcBABADAAsACAiCJpcBABADABEAAghIGzWOAEgAAAEqAAUUCAgKAAcAFh8A.',['小三']='小三:BAACKgAFFH8dAAIBAAYIWiDuEQDNAQABAAYIWiDuEQDNAQAqAAQKfycAAwEACAg9GwdDAPgBAAEACAgVGwdDAPgBABMACAgKDOInABQBAAAA.',['小和']='小和:BAAAKgADCgcIBwAAAA==.',['小美']='小美:BAAAKgAECggICAAAAA==.',['少女']='少女皇:BAAAKgAECggICwAAAA==.',['山丘']='山丘蕨根:BAAAKgAECgEIAQABKgAFFAgICAAUABwYAA==.',['巅峰']='巅峰小学生:BAAAKgAECgIIAwAAAA==.',['微风']='微风没她会吹:BAAAKgAECggIDwAAAA==.',['忽冷']='忽冷:BAAAKgAECgYICwAAAA==.',['恶魔']='恶魔猎雄:BAABKgAFFH8FAAIVAAII5AJUIwBVAAAVAAII5AJUIwBVAAAAAA==.恶魔雄德:BAAAKgADCgEIAQAAAA==.恶魔雄贼:BAAAKgADCgUIBQAAAA==.',['戒灬']='戒灬:BAAAKgAECgIIAgAAAA==.',['找啊']='找啊找啊找:BAABKgAFFH8IAAITAAgIIAzYCQBgAQATAAgIIAzYCQBgAQAAAA==.',['敞衫']='敞衫罩子隆:BAAAKgAFFAIIAgAAAA==.',['斯特']='斯特莱夫:BAACKgAFFH8UAAIKAAYIfiRdBQAnAgAKAAYIfiRdBQAnAgAqAAQKfxUAAgoACAhlD/43AJwBAAoACAhlD/43AJwBAAAA.',['旋转']='旋转风暴:BAAAKgAECgYIBgAAAA==.',['月影']='月影流砂:BAABKgAFFH8IAAIBAAgIihcZBwBGAgABAAgIihcZBwBGAgAAAA==.',['木易']='木易丹心:BAAAKgAECgMIAwAAAA==.',['朱诺']='朱诺:BAABKgAFFH8IAAIBAAgITAyyDADXAQABAAgITAyyDADXAQAAAA==.',['果汁']='果汁小欣:BAAAKgAECgIIAgAAAA==.',['桀骜']='桀骜萨特浓:BAABKgAFFH8KAAIEAAgIhQ2ZBADmAQAEAAgIhQ2ZBADmAQAAAA==.',['桐谷']='桐谷和人:BAAAKgAECggICAAAAA==.',['梦寐']='梦寐龙:BAACKgAFFH8WAAIWAAQI+xNGIADCAAAWAAQI+xNGIADCAAAqAAQKfygAAxYACAjZHzQQAEsCABYACAjZHzQQAEsCABcAAQjPBCItAB0AAAAA.',['棍子']='棍子只给火牛:BAAAKgADCgYIBgAAAA==.',['榴莲']='榴莲碎冰冰:BAAAKgAECggICAAAAA==.',['正义']='正义之怒丶:BAAAKgAECgIIAgAAAA==.',['此牛']='此牛可能无敌:BAACKgAFFH8QAAQYAAgIyxZfEAAqAQAYAAQI+RRfEAAqAQAZAAQIMRwACAACAQAaAAII1QgsCABdAAAqAAQKfyYAAhkACAhvJA8HAMUCABkACAhvJA8HAMUCAAAA.',['水是']='水是这样喝的:BAAAKgAECgYIBgAAAA==.',['河边']='河边野钓:BAAAKgAECgEIAQAAAA==.',['河马']='河马一小只:BAAAKgAECgEIAQAAAA==.',['油条']='油条:BAAAKgAECggICAAAAA==.',['波丶']='波丶:BAACKgAFFH8GAAICAAIItBpTPQCoAAACAAIItBpTPQCoAAAqAAQKfxYAAwIACAjUGN08AL0BAAIACAi0GN08AL0BAAUAAgjaFl8sAGMAAAAA.',['流逝']='流逝的星辰:BAACKgAFFH8IAAIbAAYIDRIILgDQAAAbAAYIDRIILgDQAAAqAAQKfxcAAhsACAjkEE8nAD8BABsACAjkEE8nAD8BAAAA.',['火灬']='火灬火:BAABKgAFFH8FAAMVAAUIBgfqGwCNAAAVAAIIiwfqGwCNAAAbAAMIgQZBUQBnAAAAAA==.',['爷爷']='爷爷:BAAAKgAECggICgAAAA==.',['牛德']='牛德一币:BAAAKgAFFAMIAwAAAA==.',['牛肉']='牛肉丸子:BAAAKgAECgcIBwAAAA==.',['猫猫']='猫猫吖猫猫:BAAAKgADCgEIAgAAAA==.',['獵人']='獵人:BAAAKgAFFAgIAgAAAA==.',['琻刚']='琻刚娃转转猴:BAABKgAFFH8GAAIaAAMI1QkxCQB3AAAaAAMI1QkxCQB3AAAAAA==.',['生命']='生命之輕:BAAAKgADCgIIAgAAAA==.',['电竞']='电竞小能手:BAAAKgAECggICQAAAA==.',['百死']='百死而生:BAAAKgADCggICAAAAA==.',['筱泽']='筱泽广:BAAAKgADCgUIBQAAAA==.',['箭过']='箭过无痕:BAABKgAECn8jAAIbAAgIHhs/MADpAQAbAAgIHhs/MADpAQAAAA==.',['米妮']='米妮酷帕儿:BAABKgAFFH8FAAIQAAUI+yO4BwCeAQAQAAUI+yO4BwCeAQAAAA==.',['紫色']='紫色职业:BAAAKgAECgUICAAAAA==.',['红的']='红的没法看:BAAAKgADCgEIAgAAAA==.',['红红']='红红吖红红:BAAAKgADCgEIAQAAAA==.',['绿魔']='绿魔鬼:BAAAKgAFFAgIBAABKgAFFAgIEgALAIshAA==.',['羊过']='羊过小龙女:BAABKgAECn8hAAILAAgIOBqKCQD5AQALAAgIOBqKCQD5AQAAAA==.',['考的']='考的全会:BAAAKgADCgcIBwAAAA==.',['肆无']='肆无忌惮的爱:BAAAKgADCgYIBgAAAA==.',['致奇']='致奇:BAAAKgAECgQIBAAAAA==.',['芷言']='芷言:BAAAKgAECgYIDQAAAA==.',['苏察']='苏察哈尔灿:BAAAKgAFFAgIBAAAAA==.',['菠萝']='菠萝菠萝啤:BAAAKgAECgMIBAAAAA==.',['萌蹄']='萌蹄牛角包:BAABKgAECn8fAAIQAAgI5CHzCwCXAgAQAAgI5CHzCwCXAgABKgAFFAgIBAAcAAAAAA==.',['萨魔']='萨魔:BAABKgAFFH8FAAIQAAIIIgjqJQBUAAAQAAIIIgjqJQBUAAAAAA==.',['薄酒']='薄酒灬丨丨:BAABKgAFFH8GAAITAAYIIgcFFgDIAAATAAYIIgcFFgDIAAABKgAFFAgIDQABAOEYAA==.薄酒灬漫星夜:BAAAKgAECggICQAAAA==.',['薛定']='薛定谔的耳朵:BAAAKgADCggICAAAAA==.',['蛋弟']='蛋弟快来:BAAAKgADCgYIBgAAAA==.',['血域']='血域幽魂:BAAAKgAFFAEIAQAAAA==.',['血色']='血色莲华:BAAAKgAECgUIBQAAAA==.',['诸葛']='诸葛村夫:BAAAKgAECgEIAQAAAA==.',['越喝']='越喝越有:BAACKgAFFH8HAAMNAAYIXQ7lEACtAAANAAIILAzlEACtAAAMAAQIHAgeRQCaAAAqAAQKfxgAAwwACAgTDp9dAEgBAAwACAgTDp9dAEgBAB0AAQgrCpsvACkAAAAA.',['軍士']='軍士:BAABKgAFFH8GAAIeAAYITxDTAQCpAQAeAAYITxDTAQCpAQAAAA==.',['辕门']='辕门射姬:BAAAKgAFFAIIAgAAAA==.',['迷途']='迷途书童儿:BAABKgAFFH8JAAIBAAMIyhCWTwDQAAABAAMIyhCWTwDQAAAAAA==.',['追风']='追风风:BAAAKgAECgYIBgAAAA==.',['逍遥']='逍遥无边:BAAAKgAECgIIAgAAAA==.',['長松']='長松落落:BAAAKgAECgYIBgAAAA==.',['阿历']='阿历克斯:BAABKgAECn8UAAIBAAgIGx51DgBtAgABAAgIGx51DgBtAgAAAA==.',['阿格']='阿格拉玛:BAAAKgAECggICAAAAA==.',['陨落']='陨落星辰:BAAAKgAFFAgIBAAAAA==.',['霸霸']='霸霸猪:BAABKgAFFH8IAAIBAAgIdw3cCwDlAQABAAgIdw3cCwDlAQAAAA==.',['青玄']='青玄:BAAAKgAECgYIBwAAAA==.',['颓废']='颓废的喵:BAABKgAFFH8IAAMJAAQItxmfCwD4AAAJAAQItxmfCwD4AAAOAAII0AaIHQB+AAAAAA==.',['风间']='风间飞熊:BAAAKgAFFAQIBAABKgAFFAgIBAAcAAAAAA==.',['鬼头']='鬼头桃菜:BAABKgAFFH8IAAIVAAgIwgyWCgCsAQAVAAgIwgyWCgCsAQAAAA==.',['魍罔']='魍罔剡薾:BAAAKgAECggICAAAAA==.',['魔仙']='魔仙堡练习生:BAAAKgAECgcIDQAAAA==.',['魔鬼']='魔鬼小强:BAABKgAFFH8SAAMLAAYIiyE3AwDQAQALAAYIiyE3AwDQAQARAAIIRwXhPQBmAAAAAA==.',['鹌鹑']='鹌鹑烤蛋:BAAAKgAECgIIAgAAAA==.',['龙套']='龙套:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end