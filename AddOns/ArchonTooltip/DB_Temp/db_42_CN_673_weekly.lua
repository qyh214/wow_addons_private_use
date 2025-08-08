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
 local lookup = {'DeathKnight-Unholy','Monk-Mistweaver','Warrior-Arms','Warrior-Protection','Paladin-Retribution','DeathKnight-Blood','DeathKnight-Frost','Warlock-Affliction','Hunter-Marksmanship','Rogue-Assassination','DemonHunter-Havoc','DemonHunter-Vengeance','Mage-Frost','Mage-Fire','Warlock-Destruction','Warlock-Demonology','Warrior-Fury','Priest-Holy','Hunter-BeastMastery','Shaman-Restoration','Shaman-Enhancement','Mage-Arcane','Priest-Discipline','Paladin-Holy','Rogue-Subtlety',}; local provider = {region='CN',realm='库尔提拉斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ao='Aotoman:BAAAKgAECgYIBgAAAA==.',Av='Avbox:BAAAKgAECgQIBAAAAA==.',Co='Coolbaby:BAAAKgAECgQICwAAAA==.',Da='Darie:BAAAKgAECgcIDgAAAA==.',El='Elainè:BAAAKgADCggICAAAAA==.',Lo='Lovemytaotao:BAAAKgAECgYICQAAAA==.Lovettshelly:BAAAKgAECgMIAwAAAA==.',Mo='Molly:BAABKgAECn8UAAIBAAgIWAtPWABeAQABAAgIWAtPWABeAQAAAA==.',Pu='Puerh:BAAAKgAECgYICQAAAA==.',Se='Seize:BAABKgAFFH8GAAICAAYIxx86BwDEAQACAAYIxx86BwDEAQAAAA==.',Sm='Smilee:BAAAKgAFFAYIAgAAAA==.',St='Standbyfly:BAABKgAECn8UAAMDAAgIuRWLCwCUAQADAAgIuRWLCwCUAQAEAAEIFgeQTwAZAAAAAA==.',Sz='Sznbrr:BAAAKgAFFAIIAgAAAA==.',Vo='Voxifera:BAAAKgADCggIDgAAAA==.',Vu='Vurtne:BAAAKgAECgYICgAAAA==.',['一梳']='一梳光:BAAAKgAFFAIIAgAAAA==.',['一粒']='一粒丹灬怒风:BAAAKgAFFAYIBAAAAA==.',['一首']='一首凉凉:BAAAKgAECggICAAAAA==.',['与风']='与风为友:BAAAKgADCggICAAAAA==.',['丑弋']='丑弋:BAAAKgADCgMIAwAAAA==.',['丨十']='丨十丨二丨丨:BAABKgAFFH8IAAIFAAgIJhnBCAA3AgAFAAgIJhnBCAA3AgAAAA==.',['丨狼']='丨狼狗丨:BAAAKgADCgMIAwAAAA==.',['丶心']='丶心寂丶:BAAAKgADCggIDgAAAA==.',['丶柒']='丶柒染:BAAAKgAFFAgIAgAAAA==.',['丶浮']='丶浮华已过:BAAAKgAECgQIBAAAAA==.',['举个']='举个手:BAAAKgAFFAIIAgAAAA==.',['二利']='二利丹:BAAAKgADCgUIBQAAAA==.',['云玫']='云玫:BAAAKgAECgIIAgAAAA==.',['亚巴']='亚巴顿:BAAAKgADCgEIAQAAAA==.',['仙劍']='仙劍堂凝:BAACKgAFFH8QAAMGAAQIKRrjEgCuAAABAAQIBBf+JwDuAAAGAAQIpw7jEgCuAAAqAAQKfxsABAEACAhkE8lKAIwBAAEACAiGEslKAIwBAAcAAQgWHXUlAFYAAAYABQhiBEJaAFQAAAAA.',['伊兰']='伊兰贡多:BAAAKgADCgQIBAAAAA==.',['伊利']='伊利达雷领主:BAAAKgAECgEIAQAAAA==.',['优雅']='优雅的小主:BAAAKgAECgUIBQAAAA==.',['佐磁']='佐磁:BAAAKgADCggICAAAAA==.',['何欣']='何欣橙丨怒风:BAAAKgADCgEIAQAAAA==.',['俺来']='俺来打酱油:BAAAKgAECgcICgAAAA==.',['光博']='光博士:BAABKgAFFH8KAAIIAAMIgArsEgCmAAAIAAMIgArsEgCmAAAAAA==.',['克螺']='克螺米:BAAAKgAFFAIIAgAAAA==.',['八极']='八极小狂风:BAAAKgAECgYICgAAAA==.',['冷冰']='冷冰剑雨:BAABKgAFFH8GAAIJAAYIARJ/FQA4AQAJAAYIARJ/FQA4AQAAAA==.',['凶悍']='凶悍菲菲:BAABKgAFFH8UAAIKAAYIpCIsCADmAQAKAAYIpCIsCADmAQAAAA==.',['凸小']='凸小笨熊凸:BAAAKgAECgYICwAAAA==.',['十二']='十二個耳釘:BAAAKgAECgcICAAAAA==.',['十步']='十步杀一人:BAAAKgAFFAQIBAAAAA==.',['千面']='千面盗:BAAAKgADCggICAAAAA==.',['南方']='南方的雪花:BAAAKgAECgEIAQAAAA==.',['卡拉']='卡拉赞的祝福:BAAAKgADCggIFAAAAA==.',['发呆']='发呆的小牧:BAAAKgAECgMIBAAAAA==.发呆的尛德:BAAAKgAECgMIBAAAAA==.',['吱之']='吱之吱:BAABKgAFFH8HAAIFAAMI1Ri3HwDqAAAFAAMI1Ri3HwDqAAAAAA==.',['吻之']='吻之恶魔:BAAAKgAECgEIAQAAAA==.',['咸鱼']='咸鱼咸不咸:BAAAKgAFFAQIBAAAAA==.',['哈佛']='哈佛威威:BAAAKgAECgQIBAAAAA==.',['哎呦']='哎呦哎呦:BAABKgAECn8ZAAICAAgIzg9+OABlAQACAAgIzg9+OABlAQAAAA==.',['啊脚']='啊脚:BAAAKgADCgIIAgAAAA==.',['啤酒']='啤酒沫:BAABKgAFFH8FAAMLAAMIewdsIQCKAAALAAMIcAZsIQCKAAAMAAEI8QTrJgAoAAAAAA==.',['嘻哈']='嘻哈哈:BAAAKgAECgUIBwAAAA==.',['图雅']='图雅一法尔沙:BAAAKgADCggICwAAAA==.',['圣子']='圣子道无尽:BAAAKgAECgYIBgAAAA==.',['坏坏']='坏坏:BAAAKgAFFAQIBAAAAA==.',['墨云']='墨云吹城:BAABKgAECn8UAAIFAAgI7xe7awDCAQAFAAgI7xe7awDCAQAAAA==.',['夏多']='夏多雷之刃:BAAAKgADCgUIBgAAAA==.',['多尸']='多尸米尸水:BAABKgAFFH8MAAMNAAYIchz7BQB0AQAOAAYIahi8CgCLAQANAAYIWBn7BQB0AQAAAA==.',['夜戈']='夜戈乱舞:BAAAKgADCggICAAAAA==.',['夜枭']='夜枭丶:BAAAKgADCggIEAAAAA==.',['大师']='大师兄:BAAAKgAECggICAAAAA==.',['大烟']='大烟卷:BAAAKgAECggICAAAAA==.',['大神']='大神降师:BAAAKgAECgIIAgAAAA==.',['大领']='大领主丨:BAAAKgADCgEIAQAAAA==.',['天启']='天启丶:BAACKgAFFH8RAAIFAAQINyLpGAAhAQAFAAQINyLpGAAhAQAqAAQKfzMAAgUACAgVJN4UAMQCAAUACAgVJN4UAMQCAAAA.',['天堂']='天堂梦影:BAABKgAFFH8KAAQPAAYIghuDEQB+AQAPAAYIlhqDEQB+AQAIAAMIABNhEQCZAAAQAAEIUBREGgBGAAAAAA==.',['奈斯']='奈斯型队友:BAAAKgADCggIFAAAAA==.',['好孕']='好孕:BAAAKgAECgQICgAAAA==.',['如芸']='如芸:BAAAKgAECgYICQAAAA==.',['威海']='威海雷哥:BAAAKgAECggIDQAAAA==.',['媳妇']='媳妇专用小号:BAAAKgAFFAYIBAAAAA==.',['媽媽']='媽媽:BAABKgAFFH8KAAMDAAYIOB4BBQCwAQADAAYIQRkBBQCwAQARAAQIQyHmEwAiAQAAAA==.',['嫂子']='嫂子我是我哥:BAAAKgAFFAQIBAAAAA==.',['小地']='小地主:BAAAKgAECggICwAAAA==.',['小布']='小布叮叮:BAABKgAFFH8GAAISAAYIghNNDABeAQASAAYIghNNDABeAQAAAA==.',['小强']='小强威武:BAAAKgADCgUIBQAAAA==.',['小盒']='小盒里的精灵:BAABKgAECn8VAAMJAAcITRirMwCOAQAJAAcITRirMwCOAQATAAUIDwwqqwDOAAAAAA==.',['小蹄']='小蹄子一腾:BAAAKgAECgYIBgAAAA==.',['尤克']='尤克奇:BAAAKgAFFAYIBAAAAA==.',['崖叶']='崖叶的今天:BAABKgAFFH8MAAIUAAgI0gQvCwCUAQAUAAgI0gQvCwCUAQAAAA==.',['嶵兒']='嶵兒:BAAAKgAECgQIBAAAAA==.',['希尔']='希尔:BAAAKgADCggICAAAAA==.',['影之']='影之缦:BAAAKgADCggICAAAAA==.',['德得']='德得德得:BAAAKgAECgYICAAAAA==.',['恶魔']='恶魔制造:BAAAKgAECggIDAAAAA==.恶魔起飞:BAAAKgAECgYIBgAAAA==.',['意别']='意别一:BAABKgAFFH8IAAIFAAQIvxvuGQD3AAAFAAQIvxvuGQD3AAAAAA==.',['我爱']='我爱心语:BAAAKgAECggICgAAAA==.我爱饼饼:BAAAKgAECggICQAAAA==.',['提拉']='提拉米苏的苏:BAAAKgAFFAQIBAAAAA==.',['摇摆']='摇摆摇摆:BAABKgAECn8VAAIRAAgIgBZHIwC8AQARAAgIgBZHIwC8AQAAAA==.',['撒哈']='撒哈拉靓:BAAAKgAECggICAAAAA==.',['文殊']='文殊兰:BAABKgAFFH8GAAIFAAYI4gbOGAAhAQAFAAYI4gbOGAAhAQAAAA==.',['斩红']='斩红郎无双剑:BAAAKgADCggICAAAAA==.',['无穷']='无穷小亮:BAABKgAFFH8GAAICAAYIjgGBGQDSAAACAAYIjgGBGQDSAAAAAA==.',['无觅']='无觅处:BAAAKgAECgQIBAAAAA==.',['星海']='星海传奇:BAABKgAFFH8GAAIFAAYIzw/iKABEAQAFAAYIzw/iKABEAQAAAA==.',['是小']='是小染尘吧:BAAAKgAFFAQIBAAAAA==.是小染尘哈:BAAAKgADCggICAAAAA==.是小染尘哦:BAABKgAFFH8FAAIBAAUIiAtgJQD8AAABAAUIiAtgJQD8AAAAAA==.',['晴天']='晴天小奕:BAABKgAFFH8GAAIRAAYIeg7jDgBmAQARAAYIeg7jDgBmAQAAAA==.晴天小燚:BAABKgAFFH8HAAIUAAYIQAbWJADjAAAUAAYIQAbWJADjAAAAAA==.',['暗夜']='暗夜游侠:BAABKgAFFH8GAAITAAYILxFSEgBkAQATAAYILxFSEgBkAQAAAA==.',['榛名']='榛名:BAAAKgADCgQIBAAAAA==.',['欧尼']='欧尼西斯:BAAAKgAECgIIAgAAAA==.',['欧福']='欧福明:BAAAKgADCgIIAgAAAA==.',['武越']='武越:BAABKgAECn8WAAITAAgIiBzcIAA6AgATAAgIiBzcIAA6AgAAAA==.',['毛毛']='毛毛子:BAAAKgADCgIIAgAAAA==.',['水稻']='水稻去了皮:BAAAKgADCggICAAAAA==.',['汤姆']='汤姆逊迫击炮:BAAAKgADCgQIBAAAAA==.',['沐丶']='沐丶清:BAACKgAFFH8IAAIFAAYIvxQPIwDhAAAFAAYIvxQPIwDhAAAqAAQKfzsAAgUACAgaHAkXAA8CAAUACAgaHAkXAA8CAAAA.',['沫年']='沫年:BAAAKgAECggICAAAAA==.',['泰兰']='泰兰丶弗丁:BAAAKgAECgEIAQABKgAFFAgIEQAVANgWAA==.',['洛特']='洛特兰斯:BAAAKgAECgcIBwAAAA==.',['洳淉']='洳淉呮湜冋忆:BAAAKgADCgEIAQAAAA==.',['海浪']='海浪:BAAAKgAECgMIAwAAAA==.',['清新']='清新的汪汪儿:BAABKgAFFH8UAAMBAAgIJSDXAgB+AgABAAgIrx/XAgB+AgAGAAgIGRFdCACVAQAAAA==.',['清风']='清风之牧:BAAAKgAFFAgIBAAAAA==.',['温柔']='温柔小箭:BAAAKgAECgEIAQAAAA==.',['游侠']='游侠:BAAAKgAFFAEIAQAAAA==.',['灬巫']='灬巫夭王灬:BAAAKgADCggICAAAAA==.',['灬德']='灬德灬:BAAAKgADCggICAAAAA==.',['灬狂']='灬狂暴战灬:BAAAKgADCgQIBAAAAA==.',['灰烬']='灰烬游侠:BAABKgAFFH8OAAMJAAYIchcoDgB7AQAJAAYIohUoDgB7AQATAAQIeyNSFwDyAAABKgAFFAgICAATABcdAA==.',['灵威']='灵威仰:BAAAKgADCgYIBgAAAA==.',['炽爱']='炽爱飞雪:BAAAKgAECgUIBQAAAA==.',['烈阳']='烈阳:BAAAKgAECgMIAwAAAA==.',['無畏']='無畏:BAABKgAFFH8FAAIRAAUI9RJBDABGAQARAAUI9RJBDABGAQAAAA==.',['燃烟']='燃烟:BAABKgAFFH8OAAITAAMIihdtLwDMAAATAAMIihdtLwDMAAAAAA==.',['牛人']='牛人:BAAAKgAFFAMIAwAAAA==.',['狐狸']='狐狸:BAAAKgAFFAMIAwAAAA==.',['猫鲨']='猫鲨:BAABKgAFFH8IAAIFAAgItQpmDQDMAQAFAAgItQpmDQDMAQAAAA==.',['理塘']='理塘丁真:BAAAKgAFFAIIAgAAAA==.',['电萨']='电萨郭大律:BAAAKgAECgEIAQAAAA==.',['白银']='白银纯:BAAAKgAECgUIBQAAAA==.',['眬夜']='眬夜:BAAAKgAECgQIBAAAAA==.',['睡到']='睡到自然醒:BAAAKgADCggICAAAAA==.',['石块']='石块:BAAAKgADCgEIAgAAAA==.',['破锅']='破锅:BAAAKgADCggIDwAAAA==.',['神圣']='神圣小混混:BAABKgAECn8WAAIFAAgIehqqQQD9AQAFAAgIehqqQQD9AQAAAA==.神圣紫晶:BAAAKgAECgQIBAAAAA==.',['简墨']='简墨:BAABKgAFFH8FAAILAAMIngY1HgChAAALAAMIngY1HgChAAAAAA==.',['糖沫']='糖沫沫:BAAAKgAECggICwAAAA==.',['緦淰']='緦淰丶回忆:BAAAKgADCgEIAgAAAA==.',['繁华']='繁华欲喧:BAAAKgAECgMIBQAAAA==.',['红蔓']='红蔓漫:BAAAKgADCggICAAAAA==.',['纯黑']='纯黑的天空:BAAAKgAECggIEgAAAA==.',['给你']='给你个奈奈:BAAAKgAFFAIIAwAAAA==.',['绿毛']='绿毛野猪精:BAAAKgAFFAEIAQAAAA==.',['羽天']='羽天翼:BAAAKgADCgIIAgAAAA==.',['联盟']='联盟歼击机:BAABKgAFFH8IAAIWAAgIeCGPAQDNAgAWAAgIeCGPAQDNAgAAAA==.',['肚子']='肚子挡住坤儿:BAAAKgAECgYICgABKgAECggIJwAXAI4fAA==.',['苗子']='苗子姐:BAAAKgAFFAIIAgAAAA==.',['草履']='草履虫超人:BAAAKgAFFAQIBAAAAA==.',['菊花']='菊花神:BAABKgAECn8VAAMFAAgIshjkQgD5AQAFAAgIshjkQgD5AQAYAAYI4w+lLgD6AAAAAA==.',['虚空']='虚空之翼:BAAAKgADCgEIAQAAAA==.',['血昆']='血昆仑:BAAAKgADCggICQAAAA==.',['袅熊']='袅熊:BAAAKgADCgQIBAAAAA==.',['被老']='被老婆吊打:BAAAKgAECggIEQAAAA==.',['要你']='要你命:BAAAKgAECggIDwAAAA==.',['覆體']='覆體之影:BAAAKgADCggICgAAAA==.',['计都']='计都:BAAAKgAECgQIBAAAAA==.',['许坚']='许坚许坚:BAACKgAFFH8JAAILAAMIUw9zLwC/AAALAAMIUw9zLwC/AAAqAAQKfxsAAgsACAj6GSYuAPkBAAsACAj6GSYuAPkBAAAA.',['贼总']='贼总:BAABKgAFFH8GAAIKAAYIzhGhDQB1AQAKAAYIzhGhDQB1AQAAAA==.',['贾小']='贾小鬼:BAAAKgADCggIEAAAAA==.',['輪廻']='輪廻:BAAAKgAECgcIBAAAAA==.',['迈克']='迈克尔一奶霸:BAAAKgAECgcICwAAAA==.',['迷城']='迷城再见你:BAACKgAFFH8MAAILAAMIsh30IAD+AAALAAMIsh30IAD+AAAqAAQKfykAAwsACAi8It4IAMYCAAsACAi8It4IAMYCAAwABQjEDfhDALAAAAAA.',['逐风']='逐风墨月:BAAAKgADCgcIBwAAAA==.',['邪门']='邪门歪盗:BAAAKgAECgYIAwAAAA==.',['酷宝']='酷宝贝:BAAAKgAECgQICwAAAA==.',['重铸']='重铸:BAAAKgAECgMIAwAAAA==.',['钉宫']='钉宫萌萌哒:BAABKgAECn8eAAMMAAgIngpWQwCyAAAMAAcIdAVWQwCyAAALAAIIsRZilACMAAAAAA==.',['铁柱']='铁柱发发法:BAAAKgAECgMIBgABKgAFFAIIBQAUAMEXAA==.铁柱飞飞骑:BAAAKgAECggIBwABKgAFFAIIBQAUAMEXAA==.',['铃屋']='铃屋什造:BAABKgAECn8XAAMZAAYIuAeoJADdAAAZAAYIpAWoJADdAAAKAAUIWAhOOACQAAAAAA==.',['锤妞']='锤妞屁:BAAAKgADCgMIAwAAAA==.',['镭霆']='镭霆:BAAAKgADCgEIAQAAAA==.',['长生']='长生:BAAAKgAECgQIBAAAAA==.',['闪电']='闪电一号:BAAAKgAECggIEgAAAA==.闪电五连锤:BAAAKgAECgUIBgAAAA==.',['闭家']='闭家锁:BAABKgAECn8XAAILAAgIlh8BGgBoAgALAAgIlh8BGgBoAgAAAA==.',['阿兰']='阿兰德隆:BAAAKgAECggICAAAAA==.',['雪碧']='雪碧:BAAAKgAFFAIIAgAAAA==.',['雲中']='雲中猎:BAAAKgAECggIEgAAAA==.',['震惊']='震惊丶百里:BAAAKgADCgQIBwAAAA==.',['霜袶']='霜袶丶:BAACKgAFFH8LAAMBAAcIVhtPAwCnAQABAAUIjCBPAwCnAQAGAAYIww9WEgAPAQAqAAQKfxwAAwEACAhwJYcLAMICAAEACAhwJYcLAMICAAYABQi+E7Q3AOgAAAEqAAUUCAgSAAoAYSAA.',['霸丨']='霸丨霸:BAAAKgADCgIIAgAAAA==.',['面包']='面包狗:BAAAKgAFFAQIBAAAAA==.',['颓废']='颓废小狼:BAABKgAECn8bAAITAAgIQhaqQgCdAQATAAgIQhaqQgCdAQAAAA==.',['风暴']='风暴使者:BAACKgAFFH8KAAIFAAMIBxPHTQDUAAAFAAMIBxPHTQDUAAAqAAQKfxkAAgUACAgTGl9bAKwBAAUACAgTGl9bAKwBAAAA.',['飘逸']='飘逸犄角:BAAAKgAECgUIDwAAAA==.',['飛雪']='飛雪蕭熙:BAAAKgAECggICQAAAA==.',['驭兽']='驭兽比蒙:BAAAKgAECgYICQAAAA==.',['骑十']='骑十一:BAAAKgADCgYIBgAAAA==.',['魏日']='魏日悬:BAAAKgAECgYIBAAAAA==.',['鹅哥']='鹅哥:BAAAKgAFFAgIAQAAAA==.',['黑夜']='黑夜蓝电:BAAAKgAFFAQIBAABKgAFFAgIDQAOAH0bAA==.',['黑暗']='黑暗猎魔:BAABKgAFFH8GAAITAAYIPBQkFABUAQATAAYIPBQkFABUAQAAAA==.',['黑焰']='黑焰:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end