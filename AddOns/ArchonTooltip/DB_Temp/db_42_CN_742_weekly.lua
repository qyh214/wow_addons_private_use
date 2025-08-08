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
 local lookup = {'Warlock-Destruction','Paladin-Retribution','Druid-Restoration','Druid-Balance','Druid-Guardian','Priest-Discipline','Priest-Holy','Priest-Shadow','Warrior-Fury','Warlock-Demonology','Mage-Frost','Mage-Fire','Hunter-BeastMastery','Mage-Arcane','Shaman-Restoration','Shaman-Elemental','Monk-Mistweaver','Hunter-Marksmanship','DeathKnight-Unholy','DeathKnight-Blood','Warrior-Protection','DemonHunter-Vengeance','Paladin-Protection','Warrior-Arms','Unknown-Unknown','DeathKnight-Frost','Evoker-Preservation','Evoker-Devastation','Rogue-Assassination','Monk-Windwalker','Monk-Brewmaster','DemonHunter-Havoc','Warlock-Affliction','Paladin-Holy',}; local provider = {region='CN',realm='火焰之树',name='CN',type='weekly',zone=42,date='2025-08-08',data={Af='Afark:BAAAKgAECgQIBAAAAA==.',Al='Alian:BAAAKgAECggIDQAAAA==.Alpha:BAAAKgAFFAEIAQAAAA==.',Am='Ammook:BAAAKgADCggICAAAAA==.',An='Anpanman:BAABKgAFFH8IAAIBAAQInRGAFQDOAAABAAQInRGAFQDOAAAAAA==.',Ar='Archimedes:BAAAKgAECggICAAAAA==.',Bo='Boom:BAAAKgAECgQIBAAAAA==.',Ca='Carpediem:BAAAKgAFFAgIBAAAAA==.',Da='Dante:BAAAKgAFFAIIAgAAAA==.',Ev='Evens:BAAAKgAFFAIIAgAAAA==.',Fo='Foceanusx:BAABKgAECn8eAAICAAgINSVoCQDwAgACAAgINSVoCQDwAgAAAA==.Forerunner:BAAAKgAECgQIBQAAAA==.',Gr='Gravitystar:BAACKgAFFH8GAAIDAAYISgkiEQAWAQADAAYISgkiEQAWAQAqAAQKfxYABAQACAhwFmA3AMsBAAQACAhwFmA3AMsBAAMAAQgzBXGCABwAAAUAAQgAAAZKAAAAAAAA.',Ha='Hadouken:BAAAKgAECggIDwAAAA==.',Ic='Icaria:BAAAKgAECgQIBgAAAA==.',Ki='Kinicolu:BAAAKgADCgQIBAAAAA==.',['Mà']='Màyùyú:BAAAKgADCggICgAAAA==.',Ob='Obilivate:BAAAKgAECgEIAQAAAA==.',Pd='Pd:BAAAKgAFFAMIAwAAAA==.',Pi='Pikmin:BAAAKgAFFAYIBAAAAA==.',Pl='Playergcyqre:BAAAKgADCggICAAAAA==.Pluviophile:BAABKgAFFH8TAAQGAAYIOR7YBgAoAQAGAAYIMxvYBgAoAQAHAAMI0RtfDgDlAAAIAAQIoxPbEgDNAAABKgAFFAgICgAHANkWAA==.',Sa='Sadaharur:BAAAKgAECgQIBAAAAA==.',So='Soapshamans:BAAAKgAFFAMIAwAAAA==.',Ss='Ssrank:BAAAKgAECgUICgAAAA==.',St='Stashbringer:BAAAKgADCggICwAAAA==.',Su='Sumail:BAAAKgAFFAEIAQAAAA==.',Sy='Sylvanase:BAAAKgADCggICgAAAA==.Sylwanas:BAAAKgADCgIIAgAAAA==.',Th='Thalorian:BAAAKgAFFAIIAgAAAA==.',Ti='Tiger:BAABKgAFFH8IAAIJAAgIAxkMBABcAgAJAAgIAxkMBABcAgAAAA==.',Xl='Xll:BAABKgAECn8bAAMKAAgI0xhTEQD+AQAKAAgI0xhTEQD+AQABAAcIKRT8VQARAQAAAA==.',Xn='Xniuxniu:BAAAKgAECgQIBAAAAA==.',['一刀']='一刀灬见血:BAAAKgADCgMIAwAAAA==.',['一只']='一只小小德:BAAAKgADCgYIBgAAAA==.',['一德']='一德服人:BAAAKgAFFAMIAwAAAA==.',['一朵']='一朵儿:BAAAKgADCgYIBgAAAA==.一朵祥云:BAAAKgAECgIIAgAAAA==.',['一眾']='一眾丨掛念:BAAAKgAFFAQIBAAAAA==.',['一色']='一色日和:BAABKgAECn8ZAAMLAAgI/By3CAAPAgALAAgI/By3CAAPAgAMAAgI6hP5LwDdAQAAAA==.',['一颗']='一颗石头:BAAAKgAFFAgIBAAAAA==.',['七焰']='七焰之夏尔米:BAAAKgAECgYIBgAAAA==.',['丅絃']='丅絃冄:BAABKgAFFH8GAAINAAQIawj5JQC6AAANAAQIawj5JQC6AAAAAA==.',['万人']='万人猛张飞:BAAAKgAECggICwAAAA==.',['三国']='三国赵云:BAAAKgAFFAgIBAAAAA==.',['上帝']='上帝审判:BAAAKgAECgMIAwAAAA==.',['上杉']='上杉绘梨衣:BAAAKgAECggICAABKgAFFAYIEgAKAMQfAA==.',['不是']='不是哥们:BAAAKgAECgUIBQAAAA==.不是哥们儿:BAAAKgADCgQIBAAAAA==.',['东北']='东北小玉:BAAAKgAFFAIIAgAAAA==.',['丨图']='丨图腾丨:BAAAKgADCgMIAwAAAA==.',['丨圣']='丨圣骑丨:BAAAKgAFFAMIAwAAAA==.',['丨小']='丨小术丨:BAAAKgAECgYIBgAAAA==.丨小粥粥:BAAAKgAECgEIAQAAAA==.',['丨泡']='丨泡沫丨:BAAAKgAECgEIAQAAAA==.',['中分']='中分头背带裤:BAAAKgAFFAYIAgAAAA==.',['丶今']='丶今日说法:BAACKgAFFH8VAAMLAAYIgxhzAwAeAQAOAAYIOhRBDwB2AQALAAQIrx9zAwAeAQAqAAQKfxcAAwsACAjyG88iAJwBAAsACAjdGc8iAJwBAA4ABAggGZlHACEBAAAA.',['丶光']='丶光之刹那:BAAAKgAECgQIBAAAAA==.',['丶年']='丶年华易逝丶:BAABKgAFFH8XAAMPAAYIsh1AEwA8AQAPAAUItBtAEwA8AQAQAAEI2gIcKAA6AAABKgAFFAYIFwARAL0fAA==.',['丶我']='丶我是刹那:BAABKgAFFH8MAAMSAAQIuSCQCQD8AAASAAQIVRyQCQD8AAANAAQIdB3LFQD3AAAAAA==.',['丶李']='丶李铁柱:BAAAKgAECgEIAQAAAA==.',['丶疏']='丶疏野:BAAAKgADCggIFAAAAA==.',['丶阿']='丶阿丁灬:BAABKgAFFH8OAAIRAAgILRTMAwA0AgARAAgILRTMAwA0AgAAAA==.',['为了']='为了部落牛:BAAAKgAECggIDwAAAA==.',['丿年']='丿年华已逝丿:BAAAKgAECgEIAQAAAA==.',['丿漫']='丿漫漫长路:BAAAKgAECgIIAgAAAA==.',['乌拉']='乌拉:BAABKgAFFH8KAAMEAAQI9RfrEQDyAAAEAAQI9RfrEQDyAAADAAIIZxKfOAA4AAAAAA==.乌拉卡尔:BAAAKgAECgUIBgAAAA==.',['九尾']='九尾狐仙:BAAAKgAECgQIBAAAAA==.',['九霄']='九霄烟雨:BAAAKgAFFAIIAwAAAA==.',['二三']='二三七:BAAAKgAECgYICQAAAA==.',['二手']='二手医生:BAABKgAFFH8FAAITAAUIyRbRGwA/AQATAAUIyRbRGwA/AQABKgAFFAgICAAJALMSAA==.二手木匠:BAAAKgAFFAQIBAAAAA==.二手灰机:BAABKgAFFH8GAAINAAYIYR0jDACtAQANAAYIYR0jDACtAQAAAA==.',['五月']='五月的雪:BAAAKgADCgUIBQAAAA==.',['亚洲']='亚洲梅西:BAAAKgAECgcICAAAAA==.亚洲舞王赵四:BAAAKgAECgcIDQAAAA==.',['亡魂']='亡魂雇佣军:BAABKgAFFH8KAAMTAAYIuhC0GwBAAQATAAYIaA20GwBAAQAUAAQIxw05JACIAAAAAA==.',['亩矛']='亩矛牛:BAAAKgAECgEIAQAAAA==.',['人狠']='人狠話不多:BAAAKgAFFAIIAgABKgAFFAYIDAAVAKwSAA==.',['亿万']='亿万少女的梦:BAABKgAFFH8HAAIUAAQIVRUNDgDPAAAUAAQIVRUNDgDPAAAAAA==.',['亿槍']='亿槍穿雲:BAABKgAFFH8NAAINAAgIaR2EBgAiAgANAAgIaR2EBgAiAgAAAA==.',['伊利']='伊利亚伍德:BAAAKgAECgQIBAAAAA==.',['伊泽']='伊泽奈亚子:BAABKgAECn8UAAIWAAgIrAJdUACBAAAWAAgIrAJdUACBAAAAAA==.',['佛爺']='佛爺:BAAAKgADCgIIAgAAAA==.',['依然']='依然迷着你:BAAAKgADCgEIAQAAAA==.',['俊少']='俊少爷:BAABKgAECn8XAAMSAAgI+hP1IgDAAQASAAgI+hP1IgDAAQANAAQIVgel4QBtAAAAAA==.',['儍慢']='儍慢丶羽煌:BAAAKgAECgEIAQAAAA==.',['全场']='全场最佳:BAAAKgAECgQIBQAAAA==.',['八两']='八两月半斤:BAAAKgAECgEIAQAAAA==.',['八仙']='八仙桌骑士:BAAAKgAECgQIBAAAAA==.',['六月']='六月湘雨:BAAAKgAFFAgIBAAAAA==.',['兰斯']='兰斯洛特丶龍:BAAAKgADCgIIAgAAAA==.',['共祝']='共祝华夏永盛:BAAAKgADCgYIBgAAAA==.',['其实']='其实我最肉:BAAAKgAECgIIAgAAAA==.',['内个']='内个先别说话:BAABKgAECn8ZAAMGAAgIqhaiNQAcAQAGAAYIRxWiNQAcAQAHAAUIMRHORgD3AAAAAA==.内个来贴贴:BAACKgAFFH8dAAMPAAMIDhe5FgC+AAAPAAMIDhe5FgC+AAAQAAMIWwsPGwCjAAAqAAQKfycAAw8ACAgsHcsnAOABAA8ACAgsHcsnAOABABAAAQg3ByaHACgAAAAA.',['冰封']='冰封丶七鹰:BAAAKgAECgIIAgAAAA==.',['冰彡']='冰彡空:BAABKgAECn8kAAIPAAgIqBq/LgDOAQAPAAgIqBq/LgDOAQAAAA==.',['冰霜']='冰霜舞步:BAAAKgAECgYICQAAAA==.',['冷月']='冷月随风:BAAAKgADCgQIBAAAAA==.',['凵凵']='凵凵:BAAAKgADCgUIBQAAAA==.',['凶刃']='凶刃崩天:BAAAKgADCgMIAwAAAA==.',['出来']='出来就很高:BAACKgAFFH8TAAICAAMI7A1TVQDGAAACAAMI7A1TVQDGAAAqAAQKfyEAAwIACAhJGTcaAPEBAAIACAhJGTcaAPEBABcAAQhkAAAAAAAAAAAA.出来想带电:BAAAKgADCgEIAgAAAA==.',['刀刀']='刀刀德:BAAAKgAECggICAAAAA==.',['刀蛮']='刀蛮屠:BAABKgAFFH8LAAMJAAMICA2vFADCAAAJAAMIggivFADCAAAYAAIIUBGiIACLAAAAAA==.',['刘大']='刘大顺:BAAAKgAFFAQIBAAAAA==.',['别打']='别打这个萨满:BAAAKgAFFAIIAgAAAA==.',['剩个']='剩个骑士:BAAAKgADCgMIAwAAAA==.',['动圈']='动圈:BAAAKgAFFAQIBAABKgAFFAgICAACAC8jAA==.',['动物']='动物园管理者:BAAAKgADCggICAAAAA==.',['勇哥']='勇哥哥:BAABKgAECn8VAAIJAAcI7hGxFABmAQAJAAcI7hGxFABmAQAAAA==.',['北京']='北京哈登:BAAAKgAFFAQIBAAAAA==.',['区区']='区区一小妖:BAAAKgAECgYIBgAAAA==.',['医禽']='医禽治兽:BAAAKgAFFAIIAwAAAA==.',['半醉']='半醉浮世:BAABKgAFFH8OAAMCAAYImBn6AQDLAQACAAYImBn6AQDLAQAXAAQIRwzJHwB/AAABKgAFFAgIAwAZAAAAAA==.半醉餘生:BAABKgAFFH8QAAIUAAYI9RsxBABNAQAUAAYI9RsxBABNAQABKgAFFAgIGgATAEwhAA==.',['华年']='华年似水:BAAAKgAECgEIAQAAAA==.',['卑鄙']='卑鄙的外乡人:BAAAKgAFFAMIAwABKgAFFAgIKQAIAMoZAA==.',['单身']='单身狗召唤术:BAAAKgAECggIEAAAAA==.',['卡哇']='卡哇伊呐:BAAAKgAECgUIBQAAAA==.',['古徳']='古徳拜上帝:BAAAKgAECgEIAQAAAA==.',['古思']='古思特:BAAAKgADCgYICgAAAA==.',['只儿']='只儿豁阿歹:BAAAKgAECgQIBAAAAA==.',['叮先']='叮先生:BAACKgAFFH8zAAMTAAQI1SWDBgA8AQATAAQI1SWDBgA8AQAaAAMIixj9BwDqAAAqAAQKf08AAxMACAgSJuACAAQDABMACAgSJuACAAQDABoABAjzH50MAIcBAAAA.',['右手']='右手丶会炎爆:BAAAKgAECgEIAQAAAA==.',['司马']='司马花院长:BAAAKgAFFAIIAgAAAA==.',['叽里']='叽里叽里啦:BAAAKgAECggIEwAAAA==.叽里咕噜啪:BAAAKgAFFAQIBAAAAA==.',['吓猴']='吓猴蹲:BAAAKgAECgYICAAAAA==.',['听风']='听风者:BAAAKgAECggICAAAAA==.',['吸血']='吸血鬼:BAAAKgADCgcICAAAAA==.',['吻中']='吻中求进:BAAAKgAECgUIDQAAAA==.',['吾仍']='吾仍热血:BAAAKgADCggICAAAAA==.',['吾嶽']='吾嶽陳雪:BAAAKgAECgEIAQAAAA==.',['吾辈']='吾辈何以為战:BAABKgAFFH8jAAIXAAQIHQMBEgBkAAAXAAQIHQMBEgBkAAAAAA==.吾辈何以為戦:BAAAKgAECgYIBgAAAA==.',['呆妹']='呆妹儿:BAAAKgADCggIEAAAAA==.',['周老']='周老三:BAAAKgADCgUIAQAAAA==.',['和中']='和中:BAABKgAFFH8FAAIXAAMIdBAaGgCnAAAXAAMIdBAaGgCnAAAAAA==.',['咣噹']='咣噹:BAAAKgADCgYIBgAAAA==.',['哄嚨']='哄嚨:BAAAKgAECggICAAAAA==.',['哈怒']='哈怒噬血:BAABKgAFFH8GAAIBAAYI1g1/AwCNAQABAAYI1g1/AwCNAQAAAA==.',['啊阿']='啊阿奇:BAABKgAFFH8FAAIPAAMI4hBAHACYAAAPAAMI4hBAHACYAAAAAA==.',['啸月']='啸月孤狼:BAAAKgAFFAIIAgAAAA==.',['喜欢']='喜欢摄影姓陈:BAABKgAFFH8GAAICAAQI6Q+XCQAzAQACAAQI6Q+XCQAzAQAAAA==.',['团团']='团团:BAAAKgADCgMIAwAAAA==.',['囧架']='囧架架:BAAAKgAFFAQIBAAAAA==.',['图腾']='图腾嘟嘟鬼:BAAAKgAECgcICwAAAA==.图腾大祭司:BAAAKgAECgIIAgAAAA==.',['圆头']='圆头耄耋:BAABKgAFFH8GAAMbAAQI4RcIBADVAAAbAAMI4RcIBADVAAAcAAMISRdhGgB+AAAAAA==.',['圣光']='圣光韭菜:BAABKgAFFH8IAAMGAAYIUxUHEAAjAQAGAAYIUxUHEAAjAQAIAAEIMBcLKgBJAAAAAA==.',['城崎']='城崎麻理子:BAAAKgADCggICAAAAA==.',['夏打']='夏打盹:BAABKgAFFH8GAAIJAAYIzRYGCQC0AQAJAAYIzRYGCQC0AQAAAA==.夏打盹六世:BAABKgAFFH8IAAICAAgIWBYsCwAUAgACAAgIWBYsCwAUAgAAAA==.',['夜幕']='夜幕涎鬼:BAAAKgAECgMIAwAAAA==.',['大酋']='大酋长:BAAAKgAFFAQIBAAAAA==.',['天天']='天天好心情:BAACKgAFFH8xAAIBAAQI2RWbFgDJAAABAAQI2RWbFgDJAAAqAAQKf1YAAgEACAiLH9kJAHECAAEACAiLH9kJAHECAAAA.天天妹妹:BAAAKgAECgcICQAAAA==.',['天才']='天才小笨笨:BAAAKgAECggIDQAAAA==.',['天狼']='天狼破军:BAAAKgAECgcIBwAAAA==.',['天越']='天越高心越小:BAABKgAFFH8GAAINAAYIERP7FgBBAQANAAYIERP7FgBBAQAAAA==.',['太不']='太不好玩了:BAAAKgAECgMIAwAAAA==.',['奇怪']='奇怪的彼岸花:BAABKgAFFH8MAAIRAAYI/RG+DgA8AQARAAYI/RG+DgA8AQAAAA==.',['奈何']='奈何桥孟婆:BAAAKgAECggICQAAAA==.',['奥绝']='奥绝之飝:BAABKgAFFH8IAAIdAAIIpxRFIgCWAAAdAAIIpxRFIgCWAAAAAA==.',['好好']='好好哥哥:BAACKgAFFH8UAAIHAAMIYBrGHgDOAAAHAAMIYBrGHgDOAAAqAAQKfyMAAwcACAgiGFscAN8BAAcACAgiGFscAN8BAAgAAQhQCtFnACIAAAAA.',['妖媚']='妖媚丶:BAAAKgAFFAEIAQAAAA==.',['姐夫']='姐夫再用力:BAAAKgAFFAIIAgAAAA==.',['娜美']='娜美:BAABKgAFFH8KAAIBAAYIExD/FwBEAQABAAYIExD/FwBEAQAAAA==.',['婲芯']='婲芯小四:BAAAKgAECgMIAwAAAA==.',['婼只']='婼只人生初见:BAAAKgAECgUIBQAAAA==.',['宇傾']='宇傾:BAAAKgAECgUIBQAAAA==.',['安東']='安東:BAACKgAFFH8NAAMXAAgIBhZfBgC+AQAXAAgIYxVfBgC+AQACAAQIfxT3JwDSAAAqAAQKfyAAAgIACAjdJdkYALQCAAIACAjdJdkYALQCAAAA.',['宝儿']='宝儿:BAAAKgADCgYIBwAAAA==.',['宫羽']='宫羽:BAABKgAFFH8GAAIMAAYI7Q3qFAARAQAMAAYI7Q3qFAARAQAAAA==.',['对君']='对君酌:BAAAKgAFFAEIAQAAAA==.',['小伙']='小伙贼壮:BAAAKgADCgMIAwAAAA==.小伙贼大:BAABKgAECn8gAAINAAgIRxuXIgAxAgANAAgIRxuXIgAxAgAAAA==.小伙贼猛:BAAAKgAECgYICAAAAA==.小伙贼粗:BAABKgAECn8aAAIPAAgIHBHHQgBsAQAPAAgIHBHHQgBsAQAAAA==.',['小六']='小六丶:BAAAKgADCggIEAAAAA==.',['小手']='小手儿必凉:BAAAKgAECgUIBQAAAA==.',['小时']='小时候很帅:BAAAKgADCggICAAAAA==.',['小红']='小红莓:BAAAKgADCgMIAwAAAA==.',['小黑']='小黑莓:BAAAKgAECggICAAAAA==.',['小龙']='小龙人:BAAAKgADCgYIBgAAAA==.小龙霞:BAACKgAFFH8MAAIeAAQIqA4jDwC/AAAeAAQIqA4jDwC/AAAqAAQKfxcABBEACAi8EC49AE8BABEACAi8EC49AE8BAB8ABggqHWURACgBAB4AAQjOD/pzAD8AAAAA.',['尐妖']='尐妖妖丷:BAABKgAFFH8OAAMGAAgITxBIBABSAQAGAAgITxBIBABSAQAIAAEIKA0uJQBKAAAAAA==.',['就不']='就不加你:BAABKgAFFH8LAAMgAAYIuB90CwDQAQAgAAYIuB90CwDQAQAWAAUIXAoACQC9AAAAAA==.',['尹艾']='尹艾茜:BAAAKgAECgYIDgAAAA==.',['山有']='山有扶蘇:BAACKgAFFH8LAAMEAAQILxyfLADgAAAEAAQILxyfLADgAAADAAMISxaQGgDNAAAqAAQKfyUABAQACAgkITEcAGACAAQACAjCIDEcAGACAAUABgjDGHkRAJIBAAMABgjnDwhNANgAAAEqAAUUBggSAAoAxB8A.',['崛北']='崛北真灬希:BAAAKgAECggICAAAAA==.',['巧克']='巧克力糖:BAAAKgADCgcIEgAAAA==.',['巧立']='巧立名牧:BAABKgAFFH8HAAIgAAYIBhT5FABSAQAgAAYIBhT5FABSAQAAAA==.',['巨龍']='巨龍木艮:BAACKgAFFH8FAAIbAAMIIwzcBgCaAAAbAAMIIwzcBgCaAAAqAAQKfxUAAxsACAgrE2UIAJMBABsACAgrE2UIAJMBABwAAgjEB1RjADkAAAAA.',['巳升']='巳升升:BAAAKgAFFAQIAgAAAA==.',['布谷']='布谷鸟儿:BAAAKgAECgYIBgAAAA==.',['帅的']='帅的莫名其妙:BAAAKgAECgMIBQAAAA==.',['希望']='希望之歌声:BAABKgAFFH8GAAICAAMIpgZQYwCpAAACAAMIpgZQYwCpAAAAAA==.',['带宗']='带宗师:BAAAKgAFFAIIBAAAAA==.',['平常']='平常心:BAABKgAFFH8GAAIPAAYIVRB7EQBJAQAPAAYIVRB7EQBJAQAAAA==.',['年华']='年华已逝:BAABKgAFFH8XAAIRAAYIvR8FCwB3AQARAAYIvR8FCwB3AQAAAA==.年华已逝丶:BAAAKgADCggICAAAAA==.年华已阑珊:BAAAKgAECgEIAQAAAA==.年华易逝:BAABKgAFFH8VAAMGAAYIoxuwCgBrAQAGAAYIvBWwCgBrAQAHAAMIlB9LEAC+AAABKgAFFAYIFwARAL0fAA==.年华易逝丶:BAABKgAFFH8PAAIDAAQIPxSKHgC0AAADAAQIPxSKHgC0AAABKgAFFAYIFwARAL0fAA==.年华易逝丿:BAAAKgAECgQIBAABKgAFFAYIFwARAL0fAA==.',['幽兰']='幽兰芳蔼:BAAAKgAECggICAAAAA==.',['广寒']='广寒宫:BAABKgAFFH8IAAIMAAQIRApPJADEAAAMAAQIRApPJADEAAAAAA==.',['影之']='影之哀伤:BAAAKgADCggICAAAAA==.',['徘徊']='徘徊左右:BAAAKgAECgYIBgAAAA==.',['御水']='御水者:BAACKgAFFH8XAAIHAAQIDxifHADaAAAHAAQIDxifHADaAAAqAAQKf1EAAgcACAhdH6gPAE0CAAcACAhdH6gPAE0CAAAA.',['心中']='心中的火焰:BAABKgAFFH8FAAICAAQIThblGwDyAAACAAQIThblGwDyAAAAAA==.',['心若']='心若芷兰:BAABKgAFFH8FAAMeAAQI5wBuFgA7AAAeAAMI5wBuFgA7AAARAAEIAACRGgAAAAAAAA==.',['怀念']='怀念年华:BAAAKgADCgQIBAAAAA==.',['思思']='思思:BAAAKgAECgEIAQAAAA==.',['总冠']='总冠军:BAAAKgAFFAQIBAABKgAFFAgIBAAZAAAAAA==.',['悠闲']='悠闲自得:BAAAKgAECgYICgAAAA==.',['愚蠢']='愚蠢的地球人:BAABKgAFFH8GAAIdAAYI8gtfAwB8AQAdAAYI8gtfAwB8AQAAAA==.',['成为']='成为海理解海:BAAAKgAECgMIAwAAAA==.',['我丨']='我丨回来了:BAAAKgAECgQIBAAAAA==.',['我为']='我为熊猫带盐:BAAAKgAECgIIAgAAAA==.',['我是']='我是奶骑:BAAAKgAECgYIBQAAAA==.我是射姬猎:BAAAKgAECgQIBAAAAA==.',['我爱']='我爱大保健:BAAAKgAFFAQIBAAAAA==.',['我的']='我的脸特白:BAAAKgAECggICAAAAA==.',['战少']='战少:BAAAKgAFFAQIBAAAAA==.',['打灰']='打灰机:BAAAKgAFFAQIBAABKgAFFAgICAANABcdAA==.',['托尼']='托尼托尼乔芭:BAAAKgAECgcIBwAAAA==.',['找刺']='找刺猬的狐狸:BAAAKgADCgEIAQAAAA==.',['抹了']='抹了油的驹丶:BAAAKgAFFAIIAgAAAA==.',['抹茶']='抹茶麻糬:BAACKgAFFH8uAAIPAAQIrSU5AwBOAQAPAAQIrSU5AwBOAQAqAAQKfyoAAg8ACAg6HvIfABYCAA8ACAg6HvIfABYCAAAA.',['拉面']='拉面加肉:BAABKgAFFH8LAAIRAAYI/xC4AwCJAQARAAYI/xC4AwCJAQAAAA==.',['拌熟']='拌熟:BAABKgAFFH8IAAIXAAgIHBOUBADOAQAXAAgIHBOUBADOAQAAAA==.',['排骨']='排骨小贼:BAAAKgAECgUIDgAAAA==.',['搓面']='搓面包的法丝:BAAAKgAECgUIBQAAAA==.',['摇滚']='摇滚雪姨:BAABKgAFFH8KAAMEAAYIDCGNCgDrAQAEAAYIDCGNCgDrAQADAAQIkgtrDgC+AAAAAA==.',['撒旦']='撒旦皮皮:BAAAKgAECggIDwAAAA==.',['敏捷']='敏捷:BAABKgAFFH8GAAISAAYISgxRGwATAQASAAYISgxRGwATAQAAAA==.',['新来']='新来的萨满:BAAAKgAECgYICQAAAA==.',['旋律']='旋律影子:BAABKgAFFH8EAAIBAAQIORkwLAC9AAABAAQIORkwLAC9AAAAAA==.',['无为']='无为:BAABKgAFFH8GAAICAAYITAd/GgASAQACAAYITAd/GgASAQAAAA==.',['无亟']='无亟之旅:BAABKgAFFH8UAAIVAAMIFAlKDwCFAAAVAAMIFAlKDwCFAAAAAA==.',['无头']='无头:BAAAKgADCgYIBgAAAA==.',['无忌']='无忌:BAACKgAFFH8LAAMcAAMIVAYVKQCVAAAcAAMIVAYVKQCVAAAbAAEIxguuCwAsAAAqAAQKfy4AAxsACAgVFt0GAMMBABsACAgVFt0GAMMBABwABwjyEigUADgBAAAA.',['无敌']='无敌穿山甲:BAAAKgAFFAYIBAAAAA==.',['旧世']='旧世回忆:BAAAKgADCgQIBAAAAA==.',['昔日']='昔日的贵族:BAABKgAFFH8KAAMKAAQIQQQCGwB7AAAKAAQI2wMCGwB7AAABAAMIbwKrKgA5AAAAAA==.',['時銧']='時銧筎氵:BAAAKgAFFAQIBAAAAA==.',['晚上']='晚上睡不着丶:BAAAKgAECgYIBgAAAA==.',['晨曦']='晨曦丿星辰:BAAAKgAECgMIAwAAAA==.',['普拉']='普拉蒂尼:BAAAKgADCggIDAAAAA==.',['普特']='普特雷斯:BAABKgAECn8lAAMKAAgIpBxXEAAIAgAKAAgIHhxXEAAIAgABAAYIAxTaTADZAAAAAA==.',['景久']='景久:BAAAKgAECgUIBwAAAA==.',['晴山']='晴山栖谷:BAACKgAFFH8ZAAIRAAQIUB5NFwDnAAARAAQIUB5NFwDnAAAqAAQKf0AAAhEACAgbItsJAGkCABEACAgbItsJAGkCAAAA.',['暗影']='暗影鱼:BAAAKgAECgYIBwAAAA==.',['暗悔']='暗悔:BAACKgAFFH80AAMHAAQIdSVuAwAsAQAHAAQIdSVuAwAsAQAIAAMIGxrvEgDoAAAqAAQKf1YAAwcACAjGJNIIAJgCAAcACAjGJNIIAJgCAAgACAg6HfINAEgCAAAA.',['暗术']='暗术肘击牢大:BAAAKgADCggIFwAAAA==.',['暮光']='暮光茉莉:BAAAKgADCgIIAgAAAA==.',['暮雨']='暮雨夜:BAAAKgAECgYIBgAAAA==.',['暴击']='暴击急速:BAABKgAFFH8IAAINAAgICRZ4BQBDAgANAAgICRZ4BQBDAgAAAA==.',['曾经']='曾经的潇洒哥:BAAAKgAFFAEIAQAAAA==.',['最灿']='最灿烂的烟火:BAAAKgADCggICAAAAA==.',['月洋']='月洋:BAAAKgADCgQIBgAAAA==.',['月野']='月野兔:BAAAKgAECgUIBQAAAA==.',['杀戮']='杀戮圣光:BAAAKgADCgEIAQAAAA==.杀戮天堂:BAAAKgADCggICAAAAA==.杀戮影舞:BAABKgAFFH8KAAMLAAYIjRrEBQACAQAOAAYIjRouEgBWAQALAAQIMRzEBQACAQAAAA==.杀戮暗夜:BAABKgAFFH8FAAINAAUIChYAGwApAQANAAUIChYAGwApAQABKgAFFAgIBAAZAAAAAA==.杀戮梦魇:BAAAKgADCgUIBQAAAA==.杀戮随风:BAABKgAFFH8OAAMgAAYIWCCKAgDFAQAgAAYIWCCKAgDFAQAWAAIIGBGqHAByAAAAAA==.',['李永']='李永浩:BAAAKgAECgIIAgAAAA==.',['李霸']='李霸天:BAAAKgADCgUIBQAAAA==.',['来自']='来自猩猩的你:BAAAKgADCggICAAAAA==.',['杰夫']='杰夫老祭司:BAAAKgAECgYIBgAAAA==.',['東雪']='東雪莲:BAAAKgAECgUICgAAAA==.',['林诗']='林诗音:BAABKgAFFH8OAAMYAAYILx54AAD3AQAYAAYILx54AAD3AQAJAAQIURymCAAgAQAAAA==.',['枫道']='枫道:BAABKgAFFH8PAAMOAAYIAyMxBwAPAgAOAAYIAyMxBwAPAgAMAAYIuQ+aEQA0AQABKgAFFAgIPAAMAN8mAA==.',['柒爺']='柒爺:BAABKgAFFH8IAAINAAgI+w0bCADxAQANAAgI+w0bCADxAQAAAA==.',['查狄']='查狄伦:BAAAKgADCgIIAgAAAA==.',['桃之']='桃之夭夭:BAABKgAECn8fAAQhAAgIQRt5BQCWAQAhAAgIpxF5BQCWAQABAAYIeRkxKgBzAQAKAAUIyhh9QQDtAAAAAA==.',['梦的']='梦的磐涅:BAABKgAFFH8GAAICAAYIdBOqLQC4AAACAAYIdBOqLQC4AAABKgAFFAgIAgAZAAAAAA==.',['楚天']='楚天秋:BAACKgAFFH8PAAIEAAYIYSO2DQC9AQAEAAYIYSO2DQC9AQAqAAQKfyYAAgQACAjnH5kXAHkCAAQACAjnH5kXAHkCAAEqAAUUCAgPAAMAnhMA.',['榛果']='榛果威化:BAAAKgAECgcIBwAAAA==.',['正义']='正义之手:BAAAKgADCgYIBgAAAA==.',['死亡']='死亡序号:BAAAKgAFFAcIAwAAAA==.',['殇炎']='殇炎:BAAAKgAECgMIAwAAAA==.',['毀天']='毀天滅帝:BAAAKgADCggICAAAAA==.',['气球']='气球的怨念:BAABKgAFFH8QAAQhAAYINRtlBQAuAQABAAYIBhgzFwBKAQAhAAUI5hZlBQAuAQAKAAUIDxFMBwAHAQAAAA==.',['水无']='水无月灬流歌:BAABKgAFFH8JAAICAAYIGxuoEAASAQACAAYIGxuoEAASAQAAAA==.',['水曜']='水曜曰的猫:BAAAKgAFFAIIAgAAAA==.',['水水']='水水渔渔:BAAAKgAFFAUIBAAAAA==.',['水流']='水流云散:BAAAKgAECgcIBwAAAA==.',['永远']='永远的神:BAABKgAFFH8PAAIPAAQIfiSlAwBHAQAPAAQIfiSlAwBHAQAAAA==.',['汐唐']='汐唐杉禾:BAABKgAFFH8FAAIGAAMIqBXRGQDDAAAGAAMIqBXRGQDDAAAAAA==.',['汪峰']='汪峰:BAACKgAFFH8vAAIgAAgIbxPMCwDKAQAgAAgIbxPMCwDKAQAqAAQKfz8AAiAACAg4IjQXAHoCACAACAg4IjQXAHoCAAAA.',['沉着']='沉着冷静道观:BAAAKgAECgIIAgAAAA==.',['法瑟']='法瑟布拉德:BAAAKgAECgcIDAAAAA==.',['泰灡']='泰灡德:BAAAKgAECgQIBAAAAA==.',['洋马']='洋马丶萨满:BAAAKgAECgMIAwAAAA==.',['洛丹']='洛丹伦的伊琳:BAAAKgAFFAMIAwAAAA==.洛丹伦的兲空:BAACKgAFFH8MAAMTAAMIsRPZFQDgAAATAAMIsRPZFQDgAAAUAAEI1RG4JAA6AAAqAAQKfycABBMACAijJPAFAOUCABMACAijJPAFAOUCABQABAgzFqU0APkAABoAAggXE4cqAG8AAAAA.',['洛千']='洛千寻:BAAAKgADCgYIBgAAAA==.',['活着']='活着真累:BAAAKgAECggICAAAAA==.',['浑身']='浑身都是劲:BAABKgAFFH8GAAIJAAYI4BkIDACKAQAJAAYI4BkIDACKAQAAAA==.',['淡淡']='淡淡幸福:BAAAKgAFFAMIAwAAAA==.',['深入']='深入荒野:BAAAKgAECgcICQAAAA==.',['清静']='清静:BAABKgAECn8bAAILAAgI1BitFwD5AQALAAgI1BitFwD5AQAAAA==.',['温柔']='温柔的大坑:BAABKgAFFH8JAAIUAAUIRhvHCgDwAAAUAAUIRhvHCgDwAAAAAA==.温柔的狞笑:BAAAKgAFFAIIAgAAAA==.',['滑漂']='滑漂:BAAAKgAFFAQIAwAAAA==.',['演员']='演员丶:BAABKgAFFH8GAAIdAAYIFhsaDACLAQAdAAYIFhsaDACLAQAAAA==.',['潇湘']='潇湘亱雨:BAAAKgAECgYICgAAAA==.',['火焰']='火焰刀锋出鞘:BAABKgAECn8WAAMCAAgI8xQiYQDZAQACAAgI8xQiYQDZAQAXAAEICgTFawANAAAAAA==.火焰菇菇:BAAAKgADCgEIAQAAAA==.',['灬倾']='灬倾世灬:BAAAKgAFFAQIBAAAAA==.',['灬奔']='灬奔雷剑灬:BAACKgAFFH8FAAINAAQITgtREgADAQANAAQITgtREgADAQAqAAQKfxsAAg0ACAhMHO4iAC8CAA0ACAhMHO4iAC8CAAAA.',['灬残']='灬残火太刀灬:BAABKgAFFH8GAAICAAYIcAxwKgA9AQACAAYIcAxwKgA9AQAAAA==.',['灬粗']='灬粗野派灬:BAABKgAFFH8GAAISAAYIxBWAEQBYAQASAAYIxBWAEQBYAQAAAA==.',['灬羡']='灬羡世丨非灬:BAAAKgAFFAIIAgAAAA==.',['灬脉']='灬脉动灬:BAAAKgADCgEIAQAAAA==.',['灬风']='灬风暴之眼灬:BAAAKgAECgIIAgAAAA==.',['灭霸']='灭霸老登:BAABKgAFFH8GAAICAAYIahYOGQCVAQACAAYIahYOGQCVAQAAAA==.',['灵感']='灵感老祭司:BAAAKgAECgUICQAAAA==.',['炎之']='炎之克里斯:BAAAKgAECggICQAAAA==.',['烂木']='烂木头:BAAAKgAECgIIAgAAAA==.',['热心']='热心的群众:BAAAKgAFFAQIAgAAAA==.',['熊丶']='熊丶先生:BAAAKgAECgEIAQAAAA==.',['熊小']='熊小库丶:BAABKgAECn8WAAIVAAYIJgXTNwCFAAAVAAYIJgXTNwCFAAAAAA==.熊小德丶:BAABKgAECn8VAAIFAAYIaBgQHQAGAQAFAAYIaBgQHQAGAQAAAA==.',['熊柒']='熊柒丶:BAABKgAECn8iAAIPAAYIWh7iNgCaAQAPAAYIWh7iNgCaAQAAAA==.',['爱意']='爱意随钟起:BAAAKgAECgUIBQAAAA==.',['牛气']='牛气十足:BAAAKgAECggIEwAAAA==.',['牛马']='牛马:BAAAKgAFFAYIAgAAAA==.',['牧之']='牧之泠:BAAAKgADCgEIAQAAAA==.',['狂笑']='狂笑的菠萝糖:BAAAKgAECgEIAQAAAA==.',['狐可']='狐可爱:BAAAKgADCggICAAAAA==.',['独孤']='独孤尚恋:BAAAKgAECggIDwAAAA==.',['狼心']='狼心娃娃:BAABKgAECn8gAAMSAAgIdRvXJADfAQASAAgIVRvXJADfAQANAAcIkxWYmAD4AAAAAA==.',['獠牙']='獠牙刘华强:BAAAKgAECgYIDQAAAA==.',['獨孤']='獨孤尙戀:BAAAKgAECggIDQAAAA==.',['玄寒']='玄寒冰:BAABKgAECn8bAAMLAAgICx1rEABGAgALAAgICx1rEABGAgAOAAIIKwk1ngAqAAAAAA==.',['瑟尔']='瑟尔薇娜:BAAAKgAECgQIBAAAAA==.',['瑾年']='瑾年丨随风:BAAAKgAFFAQIBAAAAA==.',['瓦利']='瓦利丨白龙皇:BAABKgAECn8XAAMRAAgIygDXagAiAAARAAgIygDXagAiAAAfAAgIAAAAAAAAAAAAAA==.',['生蚝']='生蚝:BAABKgAFFH8IAAIOAAgIwBqbBABYAgAOAAgIwBqbBABYAgAAAA==.',['电光']='电光石火秋凉:BAAAKgAECgQIBAAAAA==.',['男兽']='男兽:BAAAKgAECgUIEAAAAA==.',['疯狂']='疯狂的石头:BAABKgAFFH8FAAITAAUICQhYDgAUAQATAAUICQhYDgAUAQAAAA==.',['痛苦']='痛苦面具:BAABKgAFFH8MAAIdAAQIMR2fGwDOAAAdAAQIMR2fGwDOAAAAAA==.',['痞子']='痞子丨柒:BAACKgAFFH8TAAIPAAMInR5ZEgDaAAAPAAMInR5ZEgDaAAAqAAQKfxkAAw8ACAjpFRk8AIUBAA8ACAjpFRk8AIUBABAAAgiDD4OBADUAAAAA.痞子狼哥:BAABKgAFFH8HAAIUAAMIAwHlMABHAAAUAAMIAwHlMABHAAAAAA==.',['白将']='白将军:BAABKgAECn8eAAMCAAgIrRXnHgDFAQACAAgIrRXnHgDFAQAXAAgInQo8LAD3AAAAAA==.',['百变']='百变随心:BAAAKgADCgUIBQAAAA==.',['看我']='看我眼神开怪:BAAAKgAECgEIAQAAAA==.',['看这']='看这里嘛:BAAAKgAECgEIAQAAAA==.',['石头']='石头梦想圣:BAABKgAFFH8LAAICAAMIVQ18VwDCAAACAAMIVQ18VwDCAAAAAA==.石头梦想娃:BAABKgAFFH8XAAMNAAMIoxzoJwDmAAANAAMIoxzoJwDmAAASAAIIGQdOUwAzAAAAAA==.石头梦想德:BAAAKgAECgYIBgAAAA==.石头梦想法:BAABKgAFFH8NAAILAAMI2BJ8FQDAAAALAAMI2BJ8FQDAAAAAAA==.石头梦想萨:BAABKgAFFH8RAAIPAAMIkxkqJQDiAAAPAAMIkxkqJQDiAAABKgAFFAMIFwANAKMcAA==.',['祖阿']='祖阿曼的熊:BAAAKgAFFAgIBAAAAA==.',['神圣']='神圣裁决:BAAAKgADCgcICgAAAA==.',['神明']='神明之手:BAAAKgAECgEIAQAAAA==.',['神的']='神的传说:BAAAKgAECgcIDgAAAA==.',['禧玛']='禧玛诺:BAABKgAFFH8GAAIPAAYI3RapDQB0AQAPAAYI3RapDQB0AQAAAA==.',['秤子']='秤子逐风者:BAAAKgAECggIEwAAAA==.',['秦宝']='秦宝宝:BAABKgAFFH8GAAIBAAYIbQUpEwD7AAABAAYIbQUpEwD7AAABKgAFFAgIBgAhAGobAA==.',['秦秦']='秦秦:BAABKgAFFH8IAAICAAgIswulDADYAQACAAgIswulDADYAQAAAA==.',['稗兰']='稗兰:BAACKgAFFH8mAAIHAAQIISb4AQBIAQAHAAQIISb4AQBIAQAqAAQKf0MAAgcACAixJhMBAP8CAAcACAixJhMBAP8CAAAA.',['穿布']='穿布甲的圣骑:BAAAKgADCggICAAAAA==.',['立花']='立花灬千岁:BAABKgAFFH8NAAIdAAYIxx2vDACCAQAdAAYIxx2vDACCAQAAAA==.',['符娃']='符娃大哥:BAAAKgAECgQIBAAAAA==.',['第二']='第二秃:BAAAKgAECgYICwAAAA==.',['糖果']='糖果守护神:BAABKgAECn8XAAICAAgIXxzxNAAsAgACAAgIXxzxNAAsAgAAAA==.',['糖豆']='糖豆先生:BAAAKgAFFAMIAwAAAA==.',['紫薯']='紫薯阿美莉卡:BAAAKgAECggICAAAAA==.',['繧姰']='繧姰:BAAAKgAECgYIBgAAAA==.',['纞戦']='纞戦之狼哥:BAABKgAFFH8GAAIXAAMI5gSgJABkAAAXAAMI5gSgJABkAAAAAA==.纞戦狼哥:BAABKgAFFH8KAAIfAAMI+QRhCQBzAAAfAAMI+QRhCQBzAAAAAA==.',['红烧']='红烧牛蹄:BAAAKgADCggICAAAAA==.红烧蹄筋:BAAAKgADCggICAAAAA==.',['红玫']='红玫瑰白玫瑰:BAAAKgADCgEIAQAAAA==.',['终是']='终是浮夸丶:BAAAKgADCgMIAwAAAA==.',['绝地']='绝地死战:BAACKgAFFH8GAAIYAAYIIBs9CQB2AQAYAAYIIBs9CQB2AQAqAAQKfxYABBUACAjcGrAbACoBAAkABQgxGstJAD8BABgABAglGOIvAD4BABUACAhQDrAbACoBAAAA.',['罗罗']='罗罗诺亚索罗:BAAAKgAECgQIBAAAAA==.',['羽倾']='羽倾:BAACKgAFFH8SAAMKAAUIxB8nBwAIAQAKAAQIuyEnBwAIAQABAAEI5BcmKwBdAAAqAAQKfyIAAwoACAiyIcEDAKgCAAoACAiyIcEDAKgCAAEAAwiDE8tzAGcAAAAA.',['羽翼']='羽翼之城:BAAAKgAECggIDQAAAA==.',['羽落']='羽落神喵:BAABKgAFFH8GAAIHAAYILQ6aEAAtAQAHAAYILQ6aEAAtAQAAAA==.',['老鲶']='老鲶鱼:BAAAKgAECgcIBwAAAA==.',['耿小']='耿小苒:BAAAKgAECgYIBgAAAA==.',['职业']='职业卖萌德:BAAAKgADCgcIBwAAAA==.',['聖人']='聖人亞納:BAAAKgAECgYIEQAAAA==.',['聖方']='聖方濟各:BAAAKgAECgEIAQAAAA==.',['聼述']='聼述說:BAABKgAFFH8IAAIYAAQIdRQxDwCkAAAYAAQIdRQxDwCkAAAAAA==.',['肉棘']='肉棘尔:BAAAKgAECgYIBgAAAA==.',['肚皮']='肚皮人儿:BAAAKgAECggIEQABKgAFFAgIBAAZAAAAAA==.',['背对']='背对背拥抱:BAAAKgAECggICAAAAA==.',['脆皮']='脆皮小笼包:BAAAKgAFFAgIAQAAAA==.',['脆锤']='脆锤锤:BAAAKgAECgMIAwAAAA==.',['自由']='自由:BAABKgAFFH8FAAIfAAUI6wklBQDKAAAfAAUI6wklBQDKAAAAAA==.',['艾微']='艾微尔:BAAAKgAECggICAAAAA==.',['花丫']='花丫头:BAABKgAECn8XAAINAAgIfRlRKQAMAgANAAgIfRlRKQAMAgAAAA==.',['花气']='花气袭人丶:BAABKgAFFH8VAAQOAAYIqx+7DACaAQAOAAYIqx+7DACaAQALAAQIHBHECgDYAAAMAAIIdRd2JgCIAAAAAA==.',['花生']='花生了什么树:BAACKgAFFH8aAAINAAQIHRujJwDnAAANAAQIHRujJwDnAAAqAAQKf0UAAg0ACAgcIHwZAGgCAA0ACAgcIHwZAGgCAAAA.',['花脸']='花脸博迪:BAABKgAFFH8GAAIVAAMI3gEeDQBYAAAVAAMI3gEeDQBYAAAAAA==.',['苒姝']='苒姝儿:BAAAKgAECgQIBAAAAA==.',['若蒺']='若蒺若藜:BAAAKgADCgIIAgAAAA==.',['荡漾']='荡漾:BAABKgAFFH8KAAMWAAYIggahCADEAAAWAAYIbAWhCADEAAAgAAQI6wdAHQCoAAAAAA==.',['莫高']='莫高雷:BAAAKgAFFAEIAQAAAA==.',['菊丶']='菊丶希尔芬:BAABKgAFFH8PAAMiAAUIWBf3BQDtAAAiAAQInxz3BQDtAAAXAAUIyhLiFADRAAAAAA==.',['萌卷']='萌卷卷丶:BAABKgAFFH8MAAMHAAYI8SDxBADvAQAHAAYI8SDxBADvAQAIAAEIIQeRLQA/AAABKgAFFAgICgAHANkWAA==.',['萌宠']='萌宠小拉:BAABKgAFFH8JAAIUAAYIwRcbCwBgAQAUAAYIwRcbCwBgAQAAAA==.',['萌新']='萌新小德:BAABKgAECn8YAAIEAAgIJB02JAApAgAEAAgIJB02JAApAgAAAA==.萌新就是我:BAAAKgADCggICAAAAA==.',['萧瑟']='萧瑟:BAAAKgAECgEIAQAAAA==.',['萨满']='萨满之心:BAACKgAFFH8dAAMPAAQImCRYEwA7AQAPAAQImCRYEwA7AQAQAAEIcANEHgA2AAAqAAQKfz8AAw8ACAitIWwYAEICAA8ACAitIWwYAEICABAABwjQGIsqAIMBAAAA.',['萱草']='萱草花:BAAAKgAFFAMIAwAAAA==.',['落寞']='落寞且行:BAAAKgADCgIIAgAAAA==.',['落花']='落花黯然:BAABKgAFFH8IAAIIAAQIwxbEDgDnAAAIAAQIwxbEDgDnAAAAAA==.',['蒙狼']='蒙狼哥:BAABKgAFFH8HAAIWAAMIngEZEQBTAAAWAAMIngEZEQBTAAAAAA==.',['蓝染']='蓝染惣右介丶:BAABKgAFFH8KAAMPAAYIcQIMIgDwAAAPAAYIcQIMIgDwAAAQAAQIWww5DADNAAAAAA==.',['蓝翔']='蓝翔博士后:BAAAKgAECgUIBQAAAA==.',['薩菲']='薩菲羅斯:BAABKgAFFH8KAAIgAAYIJBd6FABWAQAgAAYIJBd6FABWAQAAAA==.',['薩魯']='薩魯法爾:BAABKgAFFH8MAAMTAAYIxQ8yCwBhAQATAAYIhQ8yCwBhAQAUAAYIGQygFQD1AAABKgAFFAgIDgAWALELAA==.',['虞兮']='虞兮丶虞兮:BAAAKgAFFAYIAgAAAA==.',['蜜蜂']='蜜蜂公爵:BAAAKgAFFAEIAQAAAA==.',['血小']='血小溅:BAABKgAFFH8IAAIOAAgIPQwmCQDfAQAOAAgIPQwmCQDfAQAAAA==.',['血色']='血色风影:BAAAKgADCgQIBAAAAA==.',['西门']='西门长海:BAABKgAFFH8JAAMgAAQIBhz2JQDgAAAgAAQIdRr2JQDgAAAWAAII8hgQDwCIAAAAAA==.',['覇気']='覇気十卒:BAAAKgAFFAEIAQAAAA==.',['见血']='见血封喉:BAAAKgAECgUIBQAAAA==.',['观星']='观星者:BAACKgAFFH8YAAMTAAQIUhqlJQD6AAATAAQIUhqlJQD6AAAaAAEIzwpvEwA8AAAqAAQKf0kAAxMACAgAIaoPAI0CABMACAh6IKoPAI0CABoABAjSFWEdAP4AAAAA.',['贝亲']='贝亲:BAAAKgADCgYICgAAAA==.',['赞达']='赞达拉之魂:BAAAKgAFFAQIBAAAAA==.',['超级']='超级赛亚小豆:BAABKgAFFH8MAAIXAAgIAw2lCQBlAQAXAAgIAw2lCQBlAQAAAA==.',['跋扈']='跋扈:BAAAKgADCgEIAQAAAA==.',['踴鎶']='踴鎶:BAAAKgAECgMIBAAAAA==.',['蹦嘚']='蹦嘚我的蹦嘚:BAAAKgAECggICAAAAA==.',['蹦跳']='蹦跳:BAABKgAFFH8KAAIWAAYIHwYLCADPAAAWAAYIHwYLCADPAAAAAA==.',['输入']='输入错误:BAAAKgAFFAIIAwAAAA==.',['辛妮']='辛妮亚丨凝焰:BAAAKgADCgIIBAAAAA==.',['达摩']='达摩院扫地僧:BAABKgAFFH8GAAIRAAYIjgcfDAD5AAARAAYIjgcfDAD5AAAAAA==.',['迪昂']='迪昂德萨巴赫:BAABKgAFFH8HAAIPAAQI1hVQDAD4AAAPAAQI1hVQDAD4AAAAAA==.',['迷迭']='迷迭的心:BAAAKgADCgEIAQAAAA==.',['追忆']='追忆杨毅:BAABKgAFFH8IAAIiAAMItA0IEwCnAAAiAAMItA0IEwCnAAAAAA==.',['逐风']='逐风者:BAAAKgAECgUIBgAAAA==.',['道不']='道不清的温柔:BAAAKgADCgQIBAAAAA==.',['遗忘']='遗忘的情义:BAAAKgAECgIIAgAAAA==.遗忘的红楼:BAAAKgAECgMIAwAAAA==.遗忘的魂:BAACKgAFFH8OAAQLAAYI5iDjAwCzAQALAAYI5iDjAwCzAQAMAAQIfB4wDwAcAQAOAAQIURxfJwDFAAAqAAQKfx0AAgsACAgnGFsoAHYBAAsACAgnGFsoAHYBAAAA.',['部落']='部落一枝花:BAAAKgADCggICAAAAA==.',['采花']='采花的小牛牛:BAABKgAFFH8HAAMEAAUIIRaXIQAXAQAEAAUIIRaXIQAXAQADAAEIAACUPQAAAAAAAA==.',['重釿']='重釿求子丶:BAAAKgAFFAIIAgAAAA==.',['钟声']='钟声:BAACKgAFFH8OAAIdAAUIpBXSEQA1AQAdAAUIpBXSEQA1AQAqAAQKf0cAAh0ACAhgIkcGAKMCAB0ACAhgIkcGAKMCAAAA.',['铁甲']='铁甲你懂的:BAACKgAFFH80AAMJAAYIshDsDQB0AQAJAAYIshDsDQB0AQAVAAQIDgS0CwBWAAAqAAQKfxUAAwkABwguEldJAEEBAAkABghkFFdJAEEBABUABQgbCCw4AIMAAAAA.',['铁蹄']='铁蹄拉风牛:BAABKgAFFH8IAAIUAAgItgOSBwAsAQAUAAgItgOSBwAsAQAAAA==.',['问题']='问题玛格丽特:BAAAKgAECggICAAAAA==.',['阎王']='阎王爷:BAAAKgADCggICAAAAA==.',['阿基']='阿基米德:BAABKgAECn8UAAIPAAgIchhjRABmAQAPAAgIchhjRABmAQAAAA==.',['阿拉']='阿拉贡丶斩神:BAAAKgADCgcIBwAAAA==.',['阿梓']='阿梓:BAAAKgAECgIIAgAAAA==.',['阿灬']='阿灬棍:BAAAKgAFFAYIAgAAAA==.',['阿辽']='阿辽沙:BAAAKgAFFAQIBAAAAA==.',['陆筱']='陆筱凤:BAACKgAFFH8aAAICAAQIXxu3PwDyAAACAAQIXxu3PwDyAAAqAAQKf1AAAgIACAgOI0MuAEcCAAIACAgOI0MuAEcCAAAA.',['陆贰']='陆贰肆:BAAAKgAECgQIBAAAAA==.',['陌生']='陌生人的故事:BAABKgAFFH8GAAIPAAMIkAoCOAChAAAPAAMIkAoCOAChAAAAAA==.',['随风']='随风的小恶魔:BAAAKgAFFAQIBAAAAA==.',['隐士']='隐士丶怒风:BAAAKgADCggICQAAAA==.',['雨国']='雨国璇书:BAABKgAFFH8FAAIKAAMIrA6GDwC/AAAKAAMIrA6GDwC/AAAAAA==.',['雷帝']='雷帝:BAAAKgAECgUIBgAAAA==.',['雷德']='雷德王:BAAAKgAECgYIDgAAAA==.',['雷托']='雷托:BAABKgAFFH8GAAITAAYIfhVsFgBpAQATAAYIfhVsFgBpAQAAAA==.',['雷炙']='雷炙:BAAAKgADCggIFgAAAA==.',['霁无']='霁无瑕:BAABKgAFFH8GAAIMAAYInRiXCgCNAQAMAAYInRiXCgCNAQAAAA==.',['霰雪']='霰雪凝香:BAAAKgAFFAQIBAAAAA==.',['青司']='青司:BAAAKgADCgUIBgAAAA==.',['须弥']='须弥芥子:BAABKgAFFH8GAAIRAAYIJBYkDQBSAQARAAYIJBYkDQBSAQAAAA==.',['颤抖']='颤抖吧骚年:BAACKgAFFH8ZAAIgAAQIPyP1GgAnAQAgAAQIPyP1GgAnAQAqAAQKfyQAAyAACAgbJcEKALQCACAACAgbJcEKALQCABYAAwgkCVZYAGcAAAAA.',['风一']='风一样的勇士:BAAAKgAECgcIDAAAAA==.',['风中']='风中德:BAAAKgAECgIIAgAAAA==.风中魅火:BAAAKgAFFAEIAQAAAA==.风中魒:BAAAKgAECgEIAQAAAA==.',['风之']='风之君主:BAAAKgAECgcIBwAAAA==.风之季语:BAABKgAFFH8HAAILAAMIRBbaFADDAAALAAMIRBbaFADDAAAAAA==.风之彼岸婲:BAABKgAFFH8FAAQhAAQIwR2CBwDtAAAhAAMIwR2CBwDtAAAKAAEIQgPaIAArAAABAAEIAACePAAAAAAAAA==.',['风带']='风带来了什么:BAAAKgAECggICAAAAA==.',['风烟']='风烟作良辰:BAAAKgAECgYIDAAAAA==.',['飘雪']='飘雪之哀殇:BAAAKgAFFAcIBAAAAA==.',['飞火']='飞火涟漪:BAAAKgADCgQIBQAAAA==.飞火连天:BAAAKgADCggIEQAAAA==.',['马太']='马太福音:BAAAKgAECgYIBgAAAA==.',['马德']='马德里竞技:BAAAKgADCgcIBwAAAA==.',['驱魔']='驱魔人:BAAAKgAECgIIAwAAAA==.',['骤夜']='骤夜:BAAAKgAECgQIBAAAAA==.',['魂之']='魂之行者:BAAAKgAECggICAAAAA==.',['魔法']='魔法之翼:BAAAKgADCgIIAgAAAA==.',['魔灵']='魔灵娃娃:BAAAKgAFFAYIBAAAAA==.',['鱻鱻']='鱻鱻:BAAAKgADCggICAAAAA==.',['麦粥']='麦粥粥:BAAAKgAECgUIBgAAAA==.',['黄昏']='黄昏乐章:BAABKgAFFH8KAAIUAAYInQ9gEgAPAQAUAAYInQ9gEgAPAQABKgAFFAgIFgAJANkUAA==.',['黄桃']='黄桃罐头:BAAAKgAECgQICAAAAA==.',['黎眀']='黎眀:BAAAKgAFFAYIBAAAAA==.',['黑岩']='黑岩妞子:BAACKgAFFH8RAAMFAAQIOQwZCQB8AAAFAAQIOQwZCQB8AAADAAMIAQOiHwBMAAAqAAQKfx4AAwUACAh2EBwPAF0BAAUACAh2EBwPAF0BAAMAAgjFBSd/AEQAAAAA.',['黑暗']='黑暗中灬莲花:BAAAKgADCgcIBwAAAA==.',['黑泽']='黑泽灬纱重:BAABKgAFFH8KAAMMAAYI2h/ICQCcAQAMAAYIjR/ICQCcAQALAAIIGh9tFQCHAAAAAA==.',['黑熊']='黑熊:BAAAKgAECgUIBgAAAA==.',['黑蓮']='黑蓮花:BAABKgAFFH8GAAIPAAYIHQulFQAtAQAPAAYIHQulFQAtAQAAAA==.',['黑龙']='黑龙王子:BAAAKgADCgUIBQAAAA==.',['黒锋']='黒锋:BAABKgAFFH8GAAITAAYI9ByeDgCuAQATAAYI9ByeDgCuAQAAAA==.',['龙儿']='龙儿:BAAAKgADCgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end