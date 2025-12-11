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
 local lookup = {'Paladin-Retribution','Druid-Balance','DeathKnight-Frost','DeathKnight-Blood','DemonHunter-Havoc','Paladin-Protection','Mage-Arcane','Warrior-Fury','Warrior-Arms','Hunter-Marksmanship','Priest-Holy','Druid-Guardian','Paladin-Holy','Druid-Restoration','Hunter-BeastMastery','Mage-Frost','Rogue-Subtlety','Rogue-Assassination','Warlock-Destruction','Warlock-Demonology','Warrior-Protection','Evoker-Devastation','Druid-Feral','Warlock-Affliction','Rogue-Outlaw','Shaman-Restoration','Shaman-Elemental','Monk-Brewmaster',}; local provider = {region='CN',realm='火喉',name='CN',type='weekly',zone=44,date='2025-12-06',data={As='Asassaina:BAAALAAECgIIAgAAAA==.Asassainq:BAAALAAECgYICwAAAA==.Asassaint:BAAALAAECgEIAQAAAA==.Asassainy:BAAALAAECgMIBAAAAA==.',Dr='Dragonraja:BAAALAAECgUIBQAAAA==.',Fi='Finni:BAAALAAECgYIBgAAAA==.',Ga='Gawaine:BAAALAAECgYIBgAAAA==.',Ho='Holyhigh:BAEALAAECgYICwABLAAECgcIFgABAKUhAA==.',Ja='Jael:BAAALAAECgMIAwAAAA==.',Ka='Katze:BAAALAAECgYIDQAAAA==.',Kl='Kluivert:BAAALAADCgEIAQAAAA==.',Lo='Lolv:BAAALAADCgIIAgAAAA==.',Qa='Qaq:BAAALAAECgMIAwAAAA==.',Sn='Snakeman:BAAALAAECgEIAQAAAA==.',So='Soner:BAABLAAFFH8FAAICAAIIGR0QFgCwAAACAAIIGR0QFgCwAAAAAA==.',St='Starbboy:BAAALAAECgYICAAAAA==.Starboy:BAAALAAECgYICwAAAA==.Starboyy:BAAALAADCgEIAQAAAA==.',To='Tony:BAAALAAECgMIAwAAAA==.',Va='Vanilla:BAAALAADCgEIAQAAAA==.',['一辛']='一辛一意:BAAALAAECggICwAAAA==.',['不灭']='不灭:BAAALAAECgEIAQAAAA==.',['不知']='不知道彧:BAAALAAECgUIBQAAAA==.',['不稳']='不稳定的心能:BAABLAAFFH8GAAMDAAMIXAj/ZgB7AAADAAIIwAf/ZgB7AAAEAAIIIgimFQBfAAAAAA==.',['丶阿']='丶阿全丶:BAAALAAECgcIBwAAAA==.',['二楼']='二楼战神:BAAALAAFFAIIAgAAAA==.',['伊利']='伊利达雷:BAACLAAFFH8GAAIFAAIIxxqtMwCkAAAFAAIIxxqtMwCkAAAsAAQKfxYAAgUABgheIGdlAP0BAAUABgheIGdlAP0BAAAA.',['信手']='信手斩龍:BAAALAAECgUIBQAAAA==.',['入梦']='入梦:BAAALAAECgMIAwAAAA==.',['关门']='关门放小德:BAAALAAFFAIIBAAAAA==.',['再吃']='再吃一口:BAAALAAECgMIAwAAAA==.',['冰冻']='冰冻九天:BAAALAAFFAIIBAAAAA==.',['冲鸭']='冲鸭:BAAALAADCgYIBgAAAA==.',['凱丶']='凱丶風暴烈酒:BAAALAAECgYIBgAAAA==.',['初春']='初春饰利:BAACLAAFFH8YAAIGAAYIlh/pAwC6AQAGAAYIlh/pAwC6AQAsAAQKfyAAAgEACAgFDKqvAJ8BAAEACAgFDKqvAJ8BAAAA.',['卡卡']='卡卡旋秋周:BAAALAADCggICAAAAA==.卡卡那个什么:BAAALAAECgYIBgAAAA==.卡卡霸道婷哥:BAAALAADCgUIBQAAAA==.',['卡西']='卡西奥佩娅:BAAALAAECgYIDAAAAA==.',['卡里']='卡里古拉:BAAALAAECgMIAwAAAA==.',['叁仟']='叁仟贰:BAAALAAECgYIDgAAAA==.',['双魚']='双魚理:BAABLAAFFH8ZAAIHAAgIFCLdAgDLAgAHAAgIFCLdAgDLAgAAAA==.',['叫我']='叫我亚瑟:BAAALAAECgYIDgAAAA==.叫我帅气男孩:BAAALAAECgMIAwAAAA==.',['吹牛']='吹牛女公子:BAABLAAECn8XAAMIAAYI0B3XTwABAgAIAAYI0B3XTwABAgAJAAIIMAuWNQBTAAAAAA==.',['呆帝']='呆帝:BAABLAAFFH8GAAIKAAIIhhAJKwBxAAAKAAIIhhAJKwBxAAAAAA==.',['咗嗳']='咗嗳:BAAALAAECgUIBQAAAA==.',['咣咣']='咣咣招财:BAABLAAFFH8FAAILAAIIJRUrLgCRAAALAAIIJRUrLgCRAAAAAA==.',['嗷呜']='嗷呜:BAABLAAFFH8IAAIMAAIIRwVoCwBYAAAMAAIIRwVoCwBYAAAAAA==.',['嘎嘎']='嘎嘎有米:BAABLAAFFH8LAAIBAAIIdh0MUgBSAAABAAIIdh0MUgBSAAAAAA==.',['嘟嘟']='嘟嘟吖:BAAALAAECgYIBgAAAA==.',['国服']='国服男枪:BAAALAAECgYICAAAAA==.',['圣光']='圣光将熄:BAAALAAFFAYIAwAAAA==.',['壹尒']='壹尒仐糸:BAABLAAFFH8eAAINAAUI3B3HCgBJAQANAAUI3B3HCgBJAQAAAA==.',['夏克']='夏克上:BAAALAAECgcIBwAAAA==.',['多情']='多情离别伤:BAAALAADCgMIAwAAAA==.',['夜杀']='夜杀狂:BAAALAAECggIDQAAAA==.',['大不']='大不点:BAAALAAECgYIBgAAAA==.',['大头']='大头与小头:BAABLAAFFH8LAAIOAAUIKA4zIQAVAQAOAAUIKA4zIQAVAQAAAA==.',['大腿']='大腿冰凉:BAABLAAFFH8iAAIDAAYIRRudJwCXAQADAAYIRRudJwCXAQAAAA==.大腿吱吱:BAABLAAFFH8GAAMPAAQIRgorZACnAAAPAAQIRgorZACnAAAKAAIIDQmdGgA0AAAAAA==.',['奇妙']='奇妙小法:BAABLAAFFH8JAAIQAAIIHhkoFABGAAAQAAIIHhkoFABGAAAAAA==.奇妙旅行:BAAALAAFFAIIAwAAAA==.',['奈非']='奈非天:BAAALAAECgcIDQAAAA==.',['姐姐']='姐姐为您服雾:BAAALAAECgMIAwAAAA==.',['威哥']='威哥:BAAALAAFFAIIAgAAAA==.',['嫩牧']='嫩牧牧:BAAALAAECgYIBgAAAA==.',['完美']='完美召唤:BAAALAAECgMIAwAAAA==.完美舞步:BAABLAAECn8YAAIBAAYIGRUHwACIAQABAAYIGRUHwACIAQAAAA==.',['小小']='小小土灵:BAAALAAECgYICgAAAA==.小小德鲁壹:BAAALAAECggICAAAAA==.',['小狐']='小狐狸可爱捏:BAAALAADCgIIAgAAAA==.',['尛儿']='尛儿:BAAALAAECgYICQAAAA==.',['就教']='就教:BAAALAAECgYIBgAAAA==.',['岩香']='岩香奥莉:BAAALAAECgUIDQAAAA==.',['巨石']='巨石强森:BAABLAAFFH8NAAMPAAYI8hlZGQA+AQAPAAYI8hlZGQA+AQAKAAEIlxUBMgBTAAAAAA==.',['帅比']='帅比无敌发丝:BAACLAAFFH8uAAIHAAcIlhs9DwACAgAHAAcIlhs9DwACAgAsAAQKfy0AAgcACAgsHtk3AGsCAAcACAgsHtk3AGsCAAAA.',['弄弄']='弄弄:BAAALAAECgMIAwAAAA==.',['忄乙']='忄乙:BAAALAAECgYIBgAAAA==.',['忆梦']='忆梦:BAAALAAECggIDgAAAA==.',['忍冬']='忍冬花灬羔:BAAALAAECgYIBgAAAA==.',['恶魔']='恶魔翼峰:BAAALAAFFAIIAgAAAA==.恶魔翼贰一:BAAALAAECgUIBQAAAA==.恶魔阿卡沙:BAAALAAECgYIBgAAAA==.',['悯天']='悯天乄承影:BAABLAAFFH8IAAMRAAIIhhbAGQBXAAARAAEIEx7AGQBXAAASAAEI+A7AHQBAAAAAAA==.',['我是']='我是呆帝:BAABLAAFFH8FAAIDAAIIQhBEdgBLAAADAAIIQhBEdgBLAAAAAA==.',['我藏']='我藏好了:BAACLAAFFH8hAAMTAAYIqBofJACKAQATAAYIuRkfJACKAQAUAAEIvyVGIABqAAAsAAQKfzIAAxMABwhfJNsfAM4CABMABwjMI9sfAM4CABQABAgeHw9SAC0BAAAA.',['手指']='手指安魂曲:BAAALAAFFAIIAgAAAA==.',['执剑']='执剑冲锋:BAABLAAECn8ZAAMVAAcIDQ8lJgAZAQAVAAcIDQ8lJgAZAQAIAAYI4wSB1wC5AAAAAA==.',['敏儿']='敏儿米熊:BAAALAADCgIIAgAAAA==.',['方舟']='方舟骑士:BAAALAAFFAMIAQAAAA==.',['无敌']='无敌三十六地:BAAALAAECgQICAAAAA==.',['无赖']='无赖僷:BAAALAAECgYICQAAAA==.',['时光']='时光缱绻:BAAALAAFFAEIAQAAAA==.',['昙芯']='昙芯:BAAALAADCgMIAwAAAA==.',['星星']='星星骑士:BAABLAAFFH8KAAINAAIIBxgxHQCPAAANAAIIBxgxHQCPAAAAAA==.',['暮幽']='暮幽:BAABLAAFFH8KAAIPAAQILRCDXgDIAAAPAAQILRCDXgDIAAAAAA==.',['暴虐']='暴虐的灬华光:BAAALAAECgYIEQABLAAFFAYIBgATAM4MAA==.',['月影']='月影魂殇:BAACLAAFFH8IAAIPAAII2A90dAB6AAAPAAII2A90dAB6AAAsAAQKfxgAAg8ABghzGg93AFcBAA8ABghzGg93AFcBAAEsAAUUCAgMAA0ApRQA.',['木子']='木子彡彡:BAAALAAECgUIBwAAAA==.',['杨楚']='杨楚楚:BAAALAADCggIBQAAAA==.',['杰森']='杰森斯坦森:BAACLAAFFH8FAAIGAAIIPQlOHgAvAAAGAAIIPQlOHgAvAAAsAAQKfygAAwYACAhMHfoOAJMCAAYACAhMHfoOAJMCAAEACAhPDaezAJkBAAAA.',['梅川']='梅川三酷子:BAABLAAFFH8QAAIPAAYIriKWFQDlAQAPAAYIriKWFQDlAQAAAA==.',['梦中']='梦中有你:BAAALAAECgIIAgAAAA==.',['梦舞']='梦舞曲丶入渊:BAAALAAFFAIIAgAAAA==.梦舞曲丶入魂:BAAALAAECgYIBgAAAA==.',['楽楽']='楽楽:BAABLAAFFH8GAAIWAAYISwGXFgCPAAAWAAYISwGXFgCPAAAAAA==.',['欧非']='欧非混合牛:BAAALAAECgMIAwAAAA==.',['沐雨']='沐雨燃歌丶:BAAALAAECgMIAwAAAA==.',['波奇']='波奇:BAAALAADCgIIAgAAAA==.',['潘小']='潘小闲:BAAALAAECgQIBAAAAA==.',['烟花']='烟花战神:BAAALAAECgYIEQAAAA==.',['烹饪']='烹饪技术哪家:BAAALAAECgIIAgAAAA==.',['猪肉']='猪肉荣:BAAALAAECgEIAQAAAA==.',['玛格']='玛格战神:BAAALAADCgcIDAAAAA==.',['生死']='生死有命:BAABLAAFFH8GAAIFAAIIewi1ZwA4AAAFAAIIewi1ZwA4AAAAAA==.',['电得']='电得泥马直噻:BAAALAADCgMIAwAAAA==.',['硿陇']='硿陇伉啷:BAAALAADCgEIAQAAAA==.',['碧风']='碧风之影:BAABLAAFFH8GAAIVAAIIixr3FwCZAAAVAAIIixr3FwCZAAAAAA==.',['糖醋']='糖醋小小德:BAAALAADCggICAAAAA==.',['紫月']='紫月:BAAALAAECgQIBAAAAA==.',['约翰']='约翰塞纳:BAACLAAFFH8UAAIDAAYICxoJKACWAQADAAYICxoJKACWAQAsAAQKfxgAAwQACAhGIE0IANwCAAQACAgiIE0IANwCAAMABwhmEqnmAGUBAAAA.',['纯情']='纯情丶大表哥:BAACLAAFFH8LAAIMAAQIqxbVBQC5AAAMAAQIqxbVBQC5AAAsAAQKfxUABAwACAgqFxsOAPoBAAwACAgqFxsOAPoBABcAAgjzCJ9FAFUAAAIAAQggESOvAC8AAAAA.',['翘班']='翘班小王子:BAAALAAFFAIIAgAAAA==.',['老约']='老约翰:BAAALAAECgEIAQAAAA==.',['肾光']='肾光女郎:BAABLAAFFH8KAAINAAII/hUSJgBzAAANAAII/hUSJgBzAAAAAA==.',['胖吖']='胖吖:BAABLAAFFH8GAAIIAAYIXQknJABNAQAIAAYIXQknJABNAQAAAA==.',['自燃']='自燃之力:BAAALAAECgYIDwAAAA==.',['自由']='自由者:BAAALAADCgcIBwAAAA==.',['范海']='范海辛:BAABLAAFFH8KAAIVAAII1w4lIgB5AAAVAAII1w4lIgB5AAAAAA==.',['范迪']='范迪塞尔:BAABLAAFFH8VAAIVAAYIjBhsDgBhAQAVAAYIjBhsDgBhAQAAAA==.',['荒野']='荒野大彪哥:BAAALAAECgYIBwAAAA==.',['莫德']='莫德雷德:BAAALAAECgYIBwAAAA==.',['落雪']='落雪白:BAAALAAECgMIAwAAAA==.',['蓝色']='蓝色太阳:BAAALAADCgIIAgAAAA==.',['蘸豆']='蘸豆爽:BAAALAADCgMIAwAAAA==.',['蛙仔']='蛙仔:BAAALAAECggICwAAAA==.',['蜚语']='蜚语兰歌:BAAALAAECgYICgAAAA==.',['血破']='血破军:BAAALAAECgMIAwAAAA==.',['襩罪']='襩罪:BAAALAAECgYICwAAAA==.',['詺門']='詺門鑫尐:BAAALAAECggICAABLAAFFAgIHgADAKscAA==.',['诗嫣']='诗嫣:BAABLAAFFH8UAAMTAAgIIR7BCQBkAgATAAgIIR7BCQBkAgAYAAEIlQwiCABRAAAAAA==.',['诛邪']='诛邪:BAAALAAECgcIDAAAAA==.',['谈影']='谈影空人心:BAAALAAECggICAAAAA==.',['贪丨']='贪丨嗔丨痴:BAAALAAECgYIBgABLAAFFAYIBgATAM4MAA==.',['赛丽']='赛丽梦妮:BAAALAAFFAIIBAAAAA==.',['身高']='身高定战斗力:BAAALAAFFAIIBAAAAA==.',['辛辛']='辛辛虫:BAAALAADCgEIAQAAAA==.',['达达']='达达馥贵:BAABLAAFFH8GAAIZAAIIhQm3BQCKAAAZAAIIhQm3BQCKAAAAAA==.',['迷离']='迷离慕斯:BAAALAAECgYIDAAAAA==.',['追寻']='追寻你的轨迹:BAAALAADCgYIBgAAAA==.',['那谁']='那谁我不爱:BAAALAAECgQIBAAAAA==.',['郭达']='郭达一世:BAACLAAFFH8GAAMaAAUIcxUpJAA+AQAaAAUIcxUpJAA+AQAbAAEI/QCuPwA8AAAsAAQKfxkAAxsACAgPF7o1ADACABsACAgPF7o1ADACABoABQhNCxHrAL8AAAEsAAUUCAgGAAsArA8A.郭达斯坦森:BAACLAAFFH8kAAIcAAYI6iGnAwAFAgAcAAYI6iGnAwAFAgAsAAQKfyMAAhwACAjZJCgBAOgCABwACAjZJCgBAOgCAAAA.',['醉爱']='醉爱红尘:BAAALAAECgQIBAAAAA==.',['门口']='门口干涉:BAAALAAECggICAAAAA==.',['阳光']='阳光下的温柔:BAAALAADCgYIBgAAAA==.',['阿尔']='阿尔缇妮:BAAALAADCgEIAgAAAA==.',['阿朗']='阿朗的抉择:BAAALAAECgIIAgAAAA==.',['阿萨']='阿萨奇:BAAALAADCgYIBgAAAA==.',['陌路']='陌路终身:BAAALAAFFAYIBAAAAA==.',['陶大']='陶大奋:BAAALAADCgcIBwABLAAFFAgISwAaACQXAA==.',['随便']='随便玩玩:BAABLAAFFH8MAAIBAAII3xUuPAChAAABAAII3xUuPAChAAAAAA==.',['随叫']='随叫随到哦:BAAALAAFFAIIAgAAAA==.',['隨風']='隨風潛入夜:BAAALAAECgYICgAAAA==.',['雷电']='雷电奥义法:BAAALAAECgQIBAAAAA==.',['靓仔']='靓仔:BAAALAAECgYIBgAAAA==.',['颜颜']='颜颜:BAABLAAFFH8IAAILAAIIsQoNQQBoAAALAAIIsQoNQQBoAAAAAA==.',['飞天']='飞天熊猫:BAAALAAECgYIEAAAAA==.',['高歌']='高歌:BAAALAAFFAIIAgAAAA==.',['鬼影']='鬼影金刚:BAABLAAFFH8MAAIVAAIIWw/BJAB0AAAVAAIIWw/BJAB0AAAAAA==.',['魅影']='魅影箭:BAAALAAECgUIBQAAAA==.',['鹧鸪']='鹧鸪菜:BAAALAADCgQIBAAAAA==.',['麥樂']='麥樂:BAACLAAFFH8TAAIDAAUIlR8vMgByAQADAAUIlR8vMgByAQAsAAQKfxYAAgMACAgpJDUVABwDAAMACAgpJDUVABwDAAAA.',['麦乐']='麦乐:BAAALAAECgUIBQAAAA==.',['麻饼']='麻饼:BAAALAAECgQIBAAAAA==.',['黑铁']='黑铁战神:BAAALAAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end