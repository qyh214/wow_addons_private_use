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
 local lookup = {'DemonHunter-Havoc','Mage-Arcane','DeathKnight-Frost','Warlock-Destruction','Unknown-Unknown','Paladin-Retribution','Priest-Holy','Druid-Restoration','Rogue-Subtlety','Warrior-Fury','Rogue-Assassination','DeathKnight-Blood','Shaman-Restoration','Warlock-Demonology','Druid-Balance','Druid-Feral','Priest-Discipline','Priest-Shadow','Mage-Frost','DeathKnight-Unholy','Hunter-BeastMastery','DemonHunter-Vengeance','Paladin-Holy','Paladin-Protection','Monk-Brewmaster','Evoker-Preservation','Shaman-Elemental','Shaman-Enhancement','Evoker-Devastation',}; local provider = {region='CN',realm='暗影裂口',name='CN',type='weekly',zone=44,date='2025-12-07',data={Ad='Ade:BAAALAADCggICAAAAA==.',An='Anon:BAAALAAECgYIBgAAAA==.',Ar='Arcanewielde:BAAALAADCggICAAAAA==.',Bi='Bitacat:BAAALAADCgEIAQAAAA==.',Da='Dahlia:BAABLAAFFH8JAAIBAAMIbhVVMQCnAAABAAMIbhVVMQCnAAAAAA==.',Ee='Eemotionn:BAAALAAECgYIBgAAAA==.',Fa='Fallenarcher:BAAALAAECgYIBwAAAA==.',Fr='Frighten:BAAALAADCgEIAQAAAA==.',Gu='Guodono:BAABLAAFFH8ZAAICAAgIGxm/CABbAgACAAgIGxm/CABbAgAAAA==.Guodonoo:BAABLAAFFH8VAAICAAgIghyeBwBuAgACAAgIghyeBwBuAgAAAA==.',Ku='Kubu:BAAALAAECgYICQAAAA==.',Lu='Lucky:BAAALAAFFAEIAQAAAA==.',Md='Mdk:BAABLAAFFH8RAAIDAAYIAhySGwDKAQADAAYIAhySGwDKAQAAAA==.',Mo='Mortis:BAABLAAFFH8pAAIEAAYIyRYVIwCQAQAEAAYIyRYVIwCQAQAAAA==.',Mw='Mwuwe:BAAALAAECgcIBwAAAA==.',Ro='Rokely:BAAALAAECgYIBgABLAAFFAgIAwAFAAAAAA==.',Sh='Shdjsa:BAABLAAFFH8GAAIGAAYISgWULAAjAQAGAAYISgWULAAjAQAAAA==.Sherry:BAAALAAECgEIAQAAAA==.',Tr='Tracyy:BAAALAAFFAIIAgAAAA==.',Wu='Wuas:BAAALAADCggICAAAAA==.',['一中']='一中:BAAALAAECgYIBgABLAAFFAYIBgAGAEoFAA==.',['一刀']='一刀秒:BAAALAAECgYIBgAAAA==.',['一米']='一米九:BAAALAAECgYICQAAAA==.',['不亦']='不亦乐乎:BAAALAADCgEIAQAAAA==.',['丨灬']='丨灬丶帝凯彡:BAAALAADCgYIBgAAAA==.丨灬丶月貌彡:BAAALAAECgUIBQAAAA==.丨灬丶错過彡:BAAALAAFFAIIAgAAAA==.',['丶海']='丶海拉丶:BAAALAAECgQIBAAAAA==.',['乱儛']='乱儛:BAABLAAFFH8FAAIGAAIILAjjeAA5AAAGAAIILAjjeAA5AAAAAA==.',['仁术']='仁术仁心:BAABLAAECn8WAAIHAAgIeBbuGgDoAQAHAAgIeBbuGgDoAQAAAA==.',['伊利']='伊利蛋:BAAALAAFFAEIAQAAAA==.',['侍女']='侍女:BAAALAAECgEIAQAAAA==.',['修罗']='修罗战神:BAAALAAFFAIIAwAAAA==.',['傻不']='傻不啦叽:BAAALAAECgUIBQAAAA==.',['关东']='关东煮丶:BAAALAAECgIIAgAAAA==.',['勇士']='勇士:BAAALAADCgUIBQAAAA==.',['勇敢']='勇敢憨牛牛:BAAALAAFFAIIBAAAAA==.',['勤劳']='勤劳的牛牛:BAACLAAFFH8JAAIIAAMIlwmYIACiAAAIAAMIlwmYIACiAAAsAAQKfxcAAggACAgXFYxGAMgBAAgACAgXFYxGAMgBAAAA.',['千里']='千里不留行:BAABLAAFFH8IAAIJAAgImRmuAQB8AgAJAAgImRmuAQB8AgAAAA==.',['南巷']='南巷清风:BAAALAAECgUIBQAAAA==.',['又开']='又开始了:BAAALAADCgMIAwAAAA==.',['又高']='又高又帅:BAAALAAECgUIBQAAAA==.',['含沙']='含沙射影:BAAALAAECgMIBQAAAA==.',['呜喵']='呜喵王:BAAALAADCgMIAwAAAA==.',['命宫']='命宫武曲:BAAALAADCggIAgAAAA==.',['哈库']='哈库勒玛塔塔:BAAALAAECgIIAgAAAA==.',['哪儿']='哪儿去呢:BAAALAADCgIIAgAAAA==.',['喵喵']='喵喵人:BAAALAAFFAIIAwAAAA==.',['困困']='困困丶:BAAALAAFFAIIAgAAAA==.',['土突']='土突凸:BAAALAAFFAIIAgAAAA==.',['圣灵']='圣灵:BAAALAAECgYIBgAAAA==.',['坠入']='坠入星云:BAAALAAECggIDQAAAA==.',['声乐']='声乐方老师:BAAALAAECgQIBAAAAA==.',['夏季']='夏季之风:BAAALAADCgYICAAAAA==.',['夏目']='夏目:BAABLAAECn8WAAIKAAgI+BsELwB9AgAKAAgI+BsELwB9AgAAAA==.',['夏至']='夏至薄雾:BAAALAAFFAIIAgAAAA==.',['夜猫']='夜猫:BAABLAAFFH8aAAILAAYIqx1vAQAlAgALAAYIqx1vAQAlAgABLAAFFAgIEgABAPUgAA==.',['大灰']='大灰螚:BAAALAAECggIDwAAAA==.',['大饼']='大饼干:BAAALAADCggICAAAAA==.',['奶到']='奶到你吐:BAAALAAECgUIBQAAAA==.',['奶量']='奶量巨大:BAAALAAECgIIAgAAAA==.',['如水']='如水丶:BAAALAAECgYIDgAAAA==.',['学生']='学生肖恩:BAAALAAECgMIAwAAAA==.',['宝贝']='宝贝妮丫:BAAALAAECgYIDgAAAA==.宝贝妮丫儿:BAAALAAECgQIBAAAAA==.',['对对']='对对眼的蜥蜴:BAAALAAFFAIIAwAAAA==.',['小个']='小个子大智慧:BAAALAAECgYICAAAAA==.',['小小']='小小梦点:BAAALAAECgIIAgAAAA==.小小钱:BAAALAAFFAIIAgAAAA==.',['小术']='小术梓:BAAALAAFFAIIAgAAAA==.',['小樱']='小樱桃:BAAALAADCgcIBwAAAA==.',['小绵']='小绵羊:BAABLAAFFH8UAAIDAAUIhRNrQgA0AQADAAUIhRNrQgA0AQAAAA==.',['尛点']='尛点点:BAAALAAFFAIIBAAAAA==.',['尼姑']='尼姑无双:BAAALAAECgYIEgAAAA==.',['岚宝']='岚宝:BAAALAAFFAIIBAAAAA==.',['巴基']='巴基大狂风:BAAALAAECgYICgAAAA==.',['帅吡']='帅吡超人:BAABLAAECn8UAAMMAAYIiCMLDgBxAgAMAAYIiCMLDgBxAgADAAYIhxpjqgC3AQAAAA==.',['希曼']='希曼:BAAALAAFFAIIAgAAAA==.',['帝森']='帝森:BAABLAAFFH8GAAIKAAIIcwo7QACMAAAKAAIIcwo7QACMAAAAAA==.',['张和']='张和离:BAAALAAECgIIAgAAAA==.',['張學']='張學友:BAABLAAFFH8GAAIGAAYIigpuLwAPAQAGAAYIigpuLwAPAQAAAA==.',['恋如']='恋如雨止丶:BAAALAAECgQIBAAAAA==.',['我才']='我才是一奶龙:BAAALAADCgIIAgAAAA==.',['戴因']='戴因斯雷布:BAAALAAFFAIIAgAAAA==.',['把酒']='把酒黄昏后丶:BAABLAAFFH8MAAINAAYIFxs1EwDLAQANAAYIFxs1EwDLAQAAAA==.',['揽月']='揽月敬年华:BAAALAAFFAUIAgABLAAFFAYICAABAAwMAA==.',['放开']='放开那个小德:BAAALAAECgIIAgAAAA==.',['星星']='星星小圣骑:BAAALAAECgMIAwAAAA==.',['普洱']='普洱人家:BAABLAAECn8aAAIBAAYIUxRJTAA3AQABAAYIUxRJTAA3AQAAAA==.普洱派对:BAAALAAECgIIBAAAAA==.',['暗之']='暗之猎:BAAALAADCgIIAgAAAA==.',['暗影']='暗影行者:BAAALAADCgIIAgAAAA==.',['暮色']='暮色求:BAAALAAECgYICQAAAA==.',['曼珠']='曼珠沙华:BAABLAAECn8YAAIOAAgIcR3SCgC+AgAOAAgIcR3SCgC+AgAAAA==.',['有志']='有志不在年糕:BAACLAAFFH8gAAQIAAYI3w21GwBPAQAIAAYI3w21GwBPAQAPAAUImwuAHADwAAAQAAEIsQ5hDgBCAAAsAAQKfy8ABA8ACAg4GKUdAIMBAA8ACAg4GKUdAIMBAAgABwhWCjJXAL0AABAAAwgREYweAHwAAAAA.',['木盒']='木盒:BAABLAAFFH8GAAMRAAIIPgniBgBKAAARAAIIPgniBgBKAAASAAIIYRSrJwBJAAAAAA==.',['李修']='李修缘:BAAALAAECgYICAAAAA==.',['李阿']='李阿不:BAAALAAECgYIEQAAAA==.',['杨珋']='杨珋:BAAALAAECgQIBAAAAA==.',['树妖']='树妖:BAAALAAECgYICQAAAA==.',['格罗']='格罗地獄咆哮:BAAALAAECgUIBQAAAA==.',['梦点']='梦点:BAAALAAFFAIIBAAAAA==.',['欧气']='欧气满满:BAABLAAFFH8MAAMCAAUIvRItPQDZAAACAAQIKREtPQDZAAATAAIINRkyFgBDAAAAAA==.',['没口']='没口可:BAAALAAECgYIDwAAAA==.',['河北']='河北的彩花:BAAALAAECgYIBgAAAA==.',['波妞']='波妞:BAAALAAECgYICgAAAA==.',['浅安']='浅安:BAABLAAFFH8GAAIBAAYI2R+qBABTAgABAAYI2R+qBABTAgAAAA==.',['游荡']='游荡者灬:BAABLAAFFH8aAAQDAAgI8R4GBwCOAgADAAgI8R4GBwCOAgAMAAYIVRQRDABNAQAUAAEIwxerEABSAAAAAA==.',['溜肉']='溜肉段:BAAALAAECgYIBwAAAA==.',['火车']='火车头朋克王:BAAALAADCgEIAQAAAA==.',['灬凹']='灬凹凸曼灬:BAAALAAECggICAAAAA==.',['灵魂']='灵魂使者:BAAALAADCgQIBAAAAA==.',['焚诗']='焚诗煮酒:BAABLAAFFH8GAAIVAAYISgH0eABuAAAVAAYISgH0eABuAAAAAA==.',['煊肥']='煊肥肥:BAAALAAECgYIBgAAAA==.',['爱吃']='爱吃狮子头:BAAALAAECggIBgABLAAFFAgIBgAKAAkYAA==.爱吃糖醋里脊:BAABLAAFFH8IAAMEAAYI9QnRNABCAQAEAAYI9QnRNABCAQAOAAEIdQbjLgBFAAAAAA==.',['爱犬']='爱犬球球:BAAALAAECgYICwAAAA==.',['牛奶']='牛奶周师傅:BAAALAAECgIIAgAAAA==.',['狐迪']='狐迪凯:BAAALAAECgYIBgAAAA==.',['王灵']='王灵贼:BAAALAAECgYIBgAAAA==.',['百货']='百货杨师傅:BAAALAAECgYIBgAAAA==.',['真的']='真的瞎了:BAAALAADCgYIBgAAAA==.',['矢吹']='矢吹守:BAACLAAFFH8MAAIBAAYIrQyXLgAnAQABAAYIrQyXLgAnAQAsAAQKfyMAAwEACAhiHKMcAP0BAAEACAhiHKMcAP0BABYABwhvDg4wAD4BAAAA.',['破剑']='破剑式:BAAALAAECgYIBwAAAA==.',['硬饼']='硬饼干:BAABLAAFFH8GAAMXAAII6wjeKQBnAAAXAAII6wjeKQBnAAAYAAIIywhkJAAfAAAAAA==.',['秋风']='秋风铃:BAACLAAFFH8GAAITAAIIoxqvCgCtAAATAAIIoxqvCgCtAAAsAAQKfxwAAhMABwh/HQEpAOIBABMABwh/HQEpAOIBAAAA.',['空帽']='空帽子:BAABLAAFFH8YAAIHAAYIIRp3EgDIAQAHAAYIIRp3EgDIAQAAAA==.',['紫色']='紫色苍蝇:BAABLAAFFH8HAAIBAAMIcwiaRAB3AAABAAMIcwiaRAB3AAAAAA==.',['红色']='红色极光:BAABLAAFFH8LAAIDAAYIqhXILgCBAQADAAYIqhXILgCBAQAAAA==.',['纳哥']='纳哥乏思:BAAALAADCgYIBgAAAA==.',['绯红']='绯红劫:BAAALAAFFAIIAgAAAA==.',['绵绵']='绵绵小软糖:BAABLAAFFH8NAAMPAAYIvgOKIwCWAAAPAAUIQwKKIwCWAAAIAAQIswqWMgBvAAAAAA==.',['老兵']='老兵:BAAALAAFFAIIAgAAAA==.',['老年']='老年人玩游戏:BAAALAAECgYICgAAAA==.',['肉蛋']='肉蛋葱鸡:BAABLAAFFH8GAAIZAAYIqhhQCwD9AAAZAAYIqhhQCwD9AAAAAA==.',['艾瑞']='艾瑞利亚:BAAALAAECgYIBgAAAA==.',['菈妮']='菈妮:BAABLAAFFH8rAAMHAAYIpx2hDQD6AQAHAAYIpx2hDQD6AQASAAIIPgjTKQBDAAABLAAFFAYILQAaACgbAA==.',['菜鸟']='菜鸟大师:BAAALAAECgIIAgAAAA==.',['萌面']='萌面大虾:BAACLAAFFH8aAAMIAAYIKCFQBwA7AgAIAAYIKCFQBwA7AgAPAAIIxQ/4NAA7AAAsAAQKfy0AAw8ACAh3FzQXALoBAA8ACAh3FzQXALoBAAgACAhjCBhUAMgAAAAA.',['蛋花']='蛋花汤:BAAALAAECgQIBAAAAA==.',['赤色']='赤色轨迹:BAACLAAFFH8/AAMLAAgIICYwAACmAgALAAgIICYwAACmAgAJAAEIJR7+GQBUAAAsAAQKfzgAAgsACAjUJowAAIwDAAsACAjUJowAAIwDAAAA.',['走了']='走了出来:BAAALAAFFAIIAgAAAA==.',['超大']='超大袋奶粉:BAAALAAECgMIAwAAAA==.',['超级']='超级皮卡丘:BAABLAAFFH8GAAIbAAYITgNXEAB1AQAbAAYITgNXEAB1AQAAAA==.',['轻轻']='轻轻十七:BAAALAAECgMIAwAAAA==.',['迪萌']='迪萌修斯:BAABLAAFFH8JAAISAAIIuBxxGQClAAASAAIIuBxxGQClAAAAAA==.',['逐日']='逐日者日瓦拉:BAAALAADCgUIBQAAAA==.',['遗忘']='遗忘血海:BAAALAAECgYIEgAAAA==.',['那晚']='那晚她说很疼:BAAALAAECgYIBgAAAA==.',['邪恶']='邪恶小契约:BAAALAAECgcIDwAAAA==.',['酉阳']='酉阳:BAAALAAFFAIIAgAAAA==.',['钢丝']='钢丝球搓澡:BAAALAAECgQIBAAAAA==.',['锅里']='锅里炖条鱼:BAAALAAFFAIIAgAAAA==.',['阿司']='阿司匹林:BAABLAAFFH8KAAIOAAII6CCoCgC2AAAOAAII6CCoCgC2AAAAAA==.',['阿希']='阿希吃面包:BAAALAAECgMIAwAAAA==.阿希强力去犹:BAAALAAECgMIAwAAAA==.',['阿德']='阿德:BAAALAAECgEIAQAAAA==.',['阿罗']='阿罗卡卡:BAAALAAECgYIBgAAAA==.',['陈近']='陈近南丶:BAABLAAFFH8FAAIZAAMIig0rDwC0AAAZAAMIig0rDwC0AAAAAA==.',['随性']='随性:BAAALAAECgEIAQAAAA==.',['隔壁']='隔壁女神:BAAALAADCgIIAgAAAA==.',['雏菊']='雏菊:BAAALAADCgcIBwAAAA==.',['霓蔻']='霓蔻:BAACLAAFFH8hAAINAAYINRzAEAA5AQANAAYINRzAEAA5AQAsAAQKfxsAAw0ABgiYJEYzAEcCAA0ABgiYJEYzAEcCABwABghpGMoGAJYBAAAA.',['霜杀']='霜杀百草:BAAALAAECgcIBwAAAA==.',['非洲']='非洲之星:BAAALAAECggICAAAAA==.',['风吟']='风吟:BAAALAAECgYIBgAAAA==.',['飞鸟']='飞鸟:BAABLAAFFH8tAAMaAAYIKBuxBwD2AQAaAAYIKBuxBwD2AQAdAAIIKQQkIABuAAAAAA==.',['饭主']='饭主:BAAALAAFFAIIAgAAAA==.',['鱼丸']='鱼丸丶:BAABLAAFFH8LAAIMAAgI1gpWBwC7AQAMAAgI1gpWBwC7AQAAAA==.',['鲍德']='鲍德里奇:BAAALAAECgYICAAAAA==.',['鲜奶']='鲜奶不限量:BAABLAAECn8nAAIHAAgIeBTpHgDDAQAHAAgIeBTpHgDDAQAAAA==.',['黎明']='黎明阿猎:BAAALAAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end