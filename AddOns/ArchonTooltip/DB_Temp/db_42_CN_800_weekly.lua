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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Paladin-Retribution','Paladin-Holy','Mage-Arcane','Mage-Frost','Rogue-Assassination','Monk-Mistweaver','Druid-Restoration','Warrior-Arms','Evoker-Devastation','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Druid-Guardian','Shaman-Restoration','DemonHunter-Havoc','Warrior-Fury','Shaman-Enhancement','Mage-Fire','Shaman-Elemental','DeathKnight-Blood','Paladin-Protection','DeathKnight-Unholy','Hunter-Survival','Evoker-Preservation','Evoker-Augmentation','DemonHunter-Vengeance',}; local provider = {region='CN',realm='艾维娜',name='CN',type='weekly',zone=42,date='2025-08-08',data={Be='Beser:BAACKgAFFH8KAAMBAAMIXhxKIgD2AAABAAMIXhxKIgD2AAACAAEIOgnSHgA5AAAqAAQKfxQAAwEACAhSJKcjAJcBAAEABggnI6cjAJcBAAIAAwigJKgvADkBAAAA.',Ca='Cappuc:BAAAKgAECgUIBQAAAA==.Cappul:BAABKgAECn8fAAMDAAgIPRyWLgBFAgADAAgIPRyWLgBFAgAEAAgIzRiyHgBsAQAAAA==.',Cl='Clever:BAAAKgADCgcICAAAAA==.Closer:BAAAKgAECgcICwAAAA==.',Dd='Ddhmy:BAABKgAECn8YAAMFAAgIRRmqLgCaAQAFAAYISh6qLgCaAQAGAAcIrg7eRQBPAQAAAA==.',Li='Lisea:BAABKgAFFH8FAAIHAAUIThE5EwAfAQAHAAUIThE5EwAfAQAAAA==.',Lo='Lonlytraamps:BAAAKgAECggICAAAAA==.',Ne='Nevermore:BAAAKgAECggICAAAAA==.',Ph='Phr:BAAAKgAECgYIEgAAAA==.',Ro='Rockingdz:BAABKgAFFH8LAAIHAAQIBCK0EgAoAQAHAAQIBCK0EgAoAQAAAA==.Rose:BAABKgAFFH8IAAIGAAQIfB+dAwAcAQAGAAQIfB+dAwAcAQAAAA==.',Se='Sevenxstone:BAAAKgAECggIEgAAAA==.',Su='Suzu:BAAAKgAFFAQIBAAAAA==.',Un='Unossy:BAABKgAFFH8HAAIIAAUIxwk6FADSAAAIAAUIxwk6FADSAAAAAA==.',Ws='Wsldqq:BAACKgAFFH8OAAIGAAMISCV2CAA7AQAGAAMISCV2CAA7AQAqAAQKfyAAAwYACAivJXEDAPMCAAYACAimJXEDAPMCAAUABwhPI0sHAHQCAAAA.',['一粒']='一粒丹炸雷:BAAAKgADCgYIBgAAAA==.',['七仔']='七仔猫:BAAAKgAECgQIBAAAAA==.',['七十']='七十的立方:BAAAKgADCgMIAwAAAA==.',['三条']='三条鱼:BAAAKgAECgcIDQAAAA==.',['三角']='三角初华:BAABKgAFFH8GAAIJAAYIvhnsBwCOAQAJAAYIvhnsBwCOAQAAAA==.',['丶浮']='丶浮生若梦:BAAAKgAECggIDQAAAA==.',['二条']='二条鱼鱼:BAAAKgAECgQIBQAAAA==.',['今汐']='今汐:BAAAKgAFFAQIBAAAAA==.',['伊默']='伊默:BAAAKgADCgcIBwAAAA==.',['伤痛']='伤痛独自尝:BAABKgAFFH8GAAIKAAYIxgwMDABNAQAKAAYIxgwMDABNAQAAAA==.',['你的']='你的样子:BAAAKgAFFAYIBAAAAA==.',['佬弓']='佬弓:BAAAKgAECgUIBQAAAA==.',['依梦']='依梦玲:BAAAKgAFFAMIAwAAAA==.',['八万']='八万:BAAAKgAECgYIBgAAAA==.',['冰火']='冰火脸脸:BAAAKgAECgMIAwAAAA==.',['凛冬']='凛冬:BAAAKgAECggICAAAAA==.',['凤凰']='凤凰山下:BAAAKgAFFAQIBAAAAA==.',['千里']='千里云帆:BAAAKgAECgUIBwAAAA==.千里明月:BAAAKgAECgIIAgAAAA==.',['卖姑']='卖姑娘的火柴:BAAAKgAFFAgIBAAAAA==.',['卡利']='卡利奶多:BAAAKgAECgMIAwAAAA==.',['卡卡']='卡卡诺斯:BAABKgAFFH8RAAILAAMIECCZGAAAAQALAAMIECCZGAAAAQAAAA==.',['可爱']='可爱的傻馒:BAAAKgAECgYIBgAAAA==.',['叶律']='叶律云:BAABKgAECn8hAAMMAAgI2RarFwDCAQAMAAgI2RarFwDCAQANAAMILRFxbAB+AAAAAA==.',['吃点']='吃点南瓜叭:BAABKgAFFH8MAAIOAAgIwBz5AwCVAgAOAAgIwBz5AwCVAgAAAA==.',['吮指']='吮指原味咕:BAACKgAFFH8FAAIPAAMIABCIBABmAAAPAAMIABCIBABmAAAqAAQKfxYAAg8ACAj+GNMIAOgBAA8ACAj+GNMIAOgBAAAA.',['咕了']='咕了个咕:BAABKgAFFH8GAAIOAAYIkBJmGABVAQAOAAYIkBJmGABVAQAAAA==.',['唐朝']='唐朝祭司:BAABKgAFFH8ZAAIQAAYIBhfoCgBQAQAQAAYIBhfoCgBQAQAAAA==.',['圣若']='圣若瑟:BAABKgAFFH8IAAIDAAgIjQnUDQDFAQADAAgIjQnUDQDFAQAAAA==.',['堕落']='堕落的叶子:BAAAKgAECggIDQAAAA==.',['塔塔']='塔塔林:BAAAKgADCggICAAAAA==.',['夏日']='夏日凡星:BAAAKgADCggICAAAAA==.',['多说']='多说一句就退:BAAAKgADCgYIBgAAAA==.',['夜神']='夜神烈火:BAAAKgAECgMIBgAAAA==.',['夢醒']='夢醒時芬:BAAAKgADCggICAAAAA==.',['大凶']='大凶脸脸猫:BAAAKgAECgcIBwAAAA==.',['大天']='大天使夜叉:BAAAKgAFFAMIAwAAAA==.',['天才']='天才靓仔萧萧:BAABKgAFFH8FAAIRAAMIYAhtNgCnAAARAAMIYAhtNgCnAAAAAA==.',['奥斯']='奥斯卡丶尊龙:BAABKgAFFH8cAAMSAAUIyw+fHQDeAAASAAUIcg+fHQDeAAAKAAMI0A93EQCUAAAAAA==.',['奥蕾']='奥蕾丽亚:BAAAKgAFFAQIBAAAAA==.',['好戏']='好戏开场:BAAAKgAECgIIAgAAAA==.',['好脾']='好脾气的我:BAAAKgAFFAIIAgAAAA==.',['妙妙']='妙妙的傻馒:BAABKgAFFH8GAAITAAYICRWPAQDEAQATAAYICRWPAQDEAQAAAA==.',['妳的']='妳的样子:BAAAKgAFFAQIBAAAAA==.',['守信']='守信雀风物:BAABKgAFFH8GAAINAAQIxgSCHgB7AAANAAQIxgSCHgB7AAAAAA==.',['守护']='守护天地:BAAAKgAECgMIAwAAAA==.守护阿梅:BAAAKgAECgIIAgAAAA==.',['寂寞']='寂寞妖娆:BAAAKgADCggICAAAAA==.寂寞桃子:BAAAKgAECgMIAwAAAA==.寂寞阿狸:BAAAKgADCgIIAgAAAA==.',['小丑']='小丑希斯莱杰:BAAAKgAECgYIBgAAAA==.',['小兔']='小兔吃狼:BAAAKgAECggIEQAAAA==.',['小糸']='小糸侑:BAAAKgADCggICAAAAA==.',['小脸']='小脸骑士:BAAAKgADCgQIBAAAAA==.',['小萨']='小萨鲁法尔:BAAAKgAECggICAAAAA==.',['尾随']='尾随伏击骑:BAAAKgAECggIEAAAAA==.',['崽崽']='崽崽猫:BAAAKgADCgEIAQAAAA==.',['心里']='心里有术:BAABKgAFFH8IAAMBAAQIYx0QEwD+AAABAAMIYx0QEwD+AAACAAIIJxmMFQBKAAAAAA==.',['怒比']='怒比澄:BAAAKgAFFAQIBAAAAA==.',['惊鴻']='惊鴻:BAABKgAFFH8GAAINAAYIIhZlEQBZAQANAAYIIhZlEQBZAQAAAA==.',['想站']='想站在彩虹上:BAABKgAFFH8FAAIUAAQIWw7fOQBLAAAUAAQIWw7fOQBLAAAAAA==.',['我不']='我不信圣光:BAAAKgAECggIBAAAAA==.',['我爱']='我爱小罗卜:BAABKgAECn8iAAMQAAgIZyJ1NAC1AQAQAAgIZyJ1NAC1AQAVAAIIHgfgewBDAAABKgAFFAgICgAQACITAA==.',['戰国']='戰国:BAAAKgAECgYIBQAAAA==.',['托夫']='托夫:BAAAKgAECgMIBAAAAA==.',['拉斐']='拉斐尔馨:BAABKgAFFH8FAAIQAAIIOwWaSwBeAAAQAAIIOwWaSwBeAAAAAA==.',['断腿']='断腿:BAAAKgADCggICAAAAA==.',['星光']='星光夜语:BAAAKgADCgQIBAAAAA==.星光夜雨:BAAAKgAECgcIBwAAAA==.',['暴丶']='暴丶龙:BAACKgAFFH8GAAIWAAIItQBYJQA3AAAWAAIItQBYJQA3AAAqAAQKfxsAAhYACAijBC1EAK0AABYACAijBC1EAK0AAAAA.',['最凶']='最凶脸脸猫:BAAAKgAECgYIBwAAAA==.',['梦境']='梦境逐星:BAABKgAFFH8KAAMOAAYI6B7GDgCwAQAOAAYI6B7GDgCwAQAJAAIIswf0EQClAAAAAA==.',['梵天']='梵天渡世:BAAAKgADCgMIBQAAAA==.',['棉花']='棉花糖的爱:BAAAKgAECgcICgAAAA==.',['樱满']='樱满集:BAABKgAFFH8GAAIDAAYI9hxrFAC5AQADAAYI9hxrFAC5AQAAAA==.',['池生']='池生:BAAAKgADCgQIBAAAAA==.',['法之']='法之界:BAAAKgAECgEIAQAAAA==.',['洛阿']='洛阿洛:BAAAKgADCgEIAQAAAA==.',['清澈']='清澈微眸:BAAAKgAECgYIBgAAAA==.',['游学']='游学者周卓:BAAAKgAFFAIIAgAAAA==.',['满天']='满天星斗:BAAAKgAECgEIAQAAAA==.',['火焰']='火焰魔法德:BAAAKgADCgcIBwAAAA==.',['烟柳']='烟柳寻花:BAAAKgADCgQIBAAAAA==.',['燃雷']='燃雷之殛:BAAAKgADCgQIBAAAAA==.',['燃风']='燃风之烬:BAAAKgAFFAgIAgAAAA==.',['爆炸']='爆炸的圣光:BAAAKgAECggIEQAAAA==.',['牛之']='牛之守望:BAABKgAFFH8YAAMOAAYIKQsVHQA0AQAOAAYIKQsVHQA0AQAJAAYIlxOFDgAtAQAAAA==.',['牛牛']='牛牛南瓜粥:BAAAKgAFFAUIAwAAAA==.',['狮王']='狮王之傲:BAAAKgAFFAIIAgAAAA==.',['狼丶']='狼丶牙:BAAAKgAECgUIBQAAAA==.',['瓜宝']='瓜宝:BAAAKgAFFAMIAwAAAA==.',['生命']='生命喂了联盟:BAAAKgAFFAgIAgAAAA==.',['疯狂']='疯狂的二雷:BAABKgAFFH8IAAMDAAQIFyTNSADdAAADAAQIFyTNSADdAAAEAAQIbxWBDQDZAAAAAA==.',['破晓']='破晓之光:BAAAKgADCgYIBgAAAA==.破晓之刃:BAAAKgAFFAEIAQAAAA==.',['离离']='离离原上咪:BAAAKgAECgMIAwAAAA==.',['禾木']='禾木:BAABKgAECn8cAAQDAAgIPxgjTgDUAQADAAgIPxgjTgDUAQAXAAQIFQQgVABJAAAEAAEIZAJUVwAbAAAAAA==.',['穆赫']='穆赫兰道丶:BAAAKgADCgEIAQAAAA==.',['空灵']='空灵格子:BAAAKgADCggICAAAAA==.',['空腹']='空腹吃早餐:BAAAKgAECggICAAAAA==.',['窗外']='窗外的梦:BAACKgAFFH8hAAIIAAgIeCTsBAAJAgAIAAgIeCTsBAAJAgAqAAQKfyQAAggACAjQHokRAF0CAAgACAjQHokRAF0CAAAA.',['筱曦']='筱曦:BAABKgAFFH8GAAIYAAYIehrTAQDUAQAYAAYIehrTAQDUAQAAAA==.',['管仲']='管仲:BAACKgAFFH8SAAIZAAQIMBYRAgCqAAAZAAQIMBYRAgCqAAAqAAQKfycAAhkACAiaILwDAFsCABkACAiaILwDAFsCAAAA.',['缥缈']='缥缈随风:BAAAKgADCggICAAAAA==.',['美式']='美式拉个花:BAABKgAFFH8GAAIKAAYIngdkBwA6AQAKAAYIngdkBwA6AQAAAA==.',['美竹']='美竹兰:BAAAKgAECggICAAAAA==.',['耀光']='耀光改二:BAAAKgAFFAMIAwAAAA==.耀光改二甲:BAABKgAFFH8WAAQaAAgIHB5HAgBYAQAaAAgIHB5HAgBYAQALAAQIrgfNKgCLAAAbAAEIfg+7BAA1AAAAAA==.',['耀眼']='耀眼艾拉:BAAAKgAECggIDAAAAA==.',['背叛']='背叛哀伤:BAAAKgAECgEIAQAAAA==.',['脸脸']='脸脸大猫:BAAAKgAECgYIDAAAAA==.',['色衰']='色衰爱弛:BAAAKgADCggICAAAAA==.',['芙宁']='芙宁娜:BAABKgAFFH8GAAMGAAQIexdkFwC4AAAGAAQIexdkFwC4AAAUAAIItgFnPwA6AAABKgAFFAgIEAAUALAfAA==.',['花园']='花园多惠:BAAAKgADCgYIDAAAAA==.',['萌新']='萌新牛:BAAAKgADCggICAAAAA==.',['蕯鲁']='蕯鲁法尔大王:BAAAKgAFFAgIAQAAAA==.',['西雪']='西雪文子:BAAAKgAFFAYIAgABKgAFFAgIDgADACocAA==.',['调皮']='调皮卷卷羊:BAAAKgAFFAIIAgAAAA==.',['赤橙']='赤橙:BAAAKgAFFAgIBAAAAA==.',['还是']='还是坏蛋:BAAAKgAECgQICQABKgAECggIIQAMANkWAA==.',['通讯']='通讯录:BAAAKgADCggICAAAAA==.',['那戈']='那戈劣人:BAAAKgAECgIIBAAAAA==.那戈迪凯:BAAAKgAECgEIAQAAAA==.',['醉里']='醉里挑燈看箭:BAAAKgAFFAQIBAAAAA==.',['锅子']='锅子:BAAAKgAECgcIBwAAAA==.',['閻之']='閻之绫波零:BAAAKgADCgQIBAAAAA==.',['阳光']='阳光甜橙:BAAAKgAECggICAAAAA==.',['阿德']='阿德拉:BAAAKgAECggICAAAAA==.',['阿道']='阿道夫洗发水:BAAAKgAECgQIBAAAAA==.',['附魔']='附魔专家:BAAAKgAECgYICQAAAA==.',['陆文']='陆文希灬堆堆:BAAAKgAECgYIDgAAAA==.',['陈陈']='陈陈风暴烈酒:BAAAKgAECgIIAgAAAA==.',['雨晴']='雨晴木子:BAAAKgAECgMIAwAAAA==.',['雷氪']='雷氪萨:BAAAKgAFFAgIBAAAAA==.',['靓得']='靓得拖网速:BAAAKgAECgMIBAAAAA==.',['面包']='面包恶魔:BAABKgAFFH8GAAMcAAMIdg8tFQCcAAAcAAMIdg8tFQCcAAARAAIIAwfaQwBvAAAAAA==.',['顺手']='顺手牵阳:BAAAKgADCgYIBgAAAA==.',['风吟']='风吟月荷:BAAAKgADCgcIBwAAAA==.',['飘渺']='飘渺沉沦:BAAAKgAECgIIAgAAAA==.',['饼干']='饼干爱好者:BAABKgAFFH8GAAMaAAYIlBjiAgD1AAAaAAQI2BXiAgD1AAALAAII4xfyEwCyAAAAAA==.',['鱼儿']='鱼儿飞飞:BAAAKgAECggIDQAAAA==.',['鲁克']='鲁克:BAABKgAFFH8IAAIDAAgIrQZ5EACZAQADAAgIrQZ5EACZAQAAAA==.',['鲮鲤']='鲮鲤:BAAAKgADCgcIBwAAAA==.',['麻辣']='麻辣回锅肉:BAAAKgADCggIEAAAAA==.',['黄牛']='黄牛:BAAAKgAFFAQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end