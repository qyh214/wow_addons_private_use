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
 local lookup = {'Shaman-Elemental','Hunter-BeastMastery','DeathKnight-Unholy','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Frost','Druid-Restoration','Hunter-Marksmanship','Paladin-Holy','Paladin-Retribution','Priest-Shadow','Priest-Holy','Warlock-Destruction','Mage-Frost','Mage-Arcane','Warrior-Fury','Warrior-Protection','Rogue-Assassination','Shaman-Restoration','Monk-Mistweaver','Druid-Balance','Unknown-Unknown','Monk-Windwalker','Druid-Guardian','DeathKnight-Blood','Warlock-Demonology','Evoker-Preservation','Evoker-Devastation',}; local provider = {region='CN',realm='阿扎达斯',name='CN',type='weekly',zone=44,date='2025-12-09',data={Ar='Arlsa:BAABLAAFFH8tAAIBAAYI6iHHDADnAQABAAYI6iHHDADnAQAAAA==.',Ay='Ayia:BAAALAAECgYIBgAAAA==.',Bl='Blackwidow:BAAALAADCggICAAAAA==.',Ci='Cici:BAAALAAECgUIBwAAAA==.',Dr='Drankrobber:BAAALAADCgYIBgAAAA==.',El='Elegant:BAAALAAFFAIIAgAAAA==.',Hi='Hiphop:BAAALAAECgEIAQAAAA==.Hipmart:BAAALAAECgQIBAAAAA==.Hipoop:BAAALAAECgYIBgAAAA==.',Ki='Kimmich:BAAALAAECgYIBgAAAA==.Kin:BAAALAAECgIIAgAAAA==.',Lo='Lovetangel:BAAALAAECgIIAgAAAA==.',Mm='Mm:BAAALAADCgYIDAAAAA==.',Mo='Monthevil:BAAALAAECgIIAwAAAA==.',My='Mysql:BAAALAAFFAIIBAAAAA==.',Sa='San:BAAALAAFFAIIAgAAAA==.',Sk='Skypillar:BAAALAADCgEIAQAAAA==.',Ti='Tima:BAABLAAFFH8GAAICAAYIRQhZVQABAQACAAYIRQhZVQABAQAAAA==.',Wr='Wreckurballz:BAAALAAFFAIIAgAAAA==.',Ya='Yanggne:BAAALAADCgEIAQAAAA==.',Yo='Young:BAAALAAECgEIAQAAAA==.Younggz:BAAALAADCgUIBgAAAA==.Youngll:BAAALAADCgQIBAAAAA==.Youngx:BAAALAADCgYIBgAAAA==.Youngz:BAAALAADCgIIBAAAAA==.',Ze='Zealous:BAAALAADCgYIBgABLAAFFAIIBgADAIUcAA==.',['一骑']='一骑绝尘:BAAALAAECgQIBAAAAA==.',['三余']='三余无梦生:BAAALAAECgUIBQAAAA==.',['不急']='不急:BAAALAAECgYIBgAAAA==.',['不散']='不散恐惧:BAAALAAECgIIAgAAAA==.',['不给']='不给糖就捣乱:BAAALAAECgYIBgAAAA==.',['丘比']='丘比特之箭:BAAALAAECgIIBAAAAA==.',['丷筱']='丷筱乄默:BAAALAADCgIIAgAAAA==.',['亢龍']='亢龍有悔:BAAALAAECggICAAAAA==.',['交出']='交出小爪子:BAAALAAECgEIAQAAAA==.',['以血']='以血洗礼:BAAALAAECgMIAwAAAA==.',['伊邪']='伊邪那岐丶:BAACLAAFFH8dAAIEAAYIxhjEFgAmAQAEAAYIxhjEFgAmAQAsAAQKfzIAAwQACAgBItkXAAkDAAQACAgBItkXAAkDAAUABgh2G3YTAB8BAAEsAAUUBggfAAYAGBoA.',['伯虎']='伯虎哥:BAAALAAECgYIBgAAAA==.',['住嘴']='住嘴:BAABLAAFFH8IAAIHAAgIoRc4BQDZAQAHAAgIoRc4BQDZAQAAAA==.',['依然']='依然情殇:BAAALAAFFAIIBAAAAA==.',['俊殳']='俊殳湖主:BAAALAADCggIAwAAAA==.',['假装']='假装你不在:BAABLAAFFH8GAAIGAAYIdRcsCAAlAgAGAAYIdRcsCAAlAgAAAA==.',['元素']='元素之手:BAAALAAFFAEIAQAAAA==.',['冰封']='冰封雪痕:BAABLAAECn8YAAMIAAcI6xC2FgDxAAACAAcISAzSnwAcAQAIAAYIlhG2FgDxAAAAAA==.',['冷秋']='冷秋月:BAAALAADCgEIAQAAAA==.',['凉了']='凉了:BAAALAAECgQIBAAAAA==.',['凉拌']='凉拌黄瓜丶:BAAALAADCgYIBgAAAA==.',['凭扶']='凭扶摇寄远:BAABLAAFFH8JAAMJAAIIMxmjIgCRAAAJAAIIMxmjIgCRAAAKAAIIlQrlVwCKAAAAAA==.',['凯蒂']='凯蒂亚彡家居:BAAALAAECgMIAwAAAA==.',['凿墙']='凿墙:BAAALAAECgYIBgAAAA==.',['刘德']='刘德华:BAAALAAECgYICAAAAA==.',['到会']='到会你的将来:BAABLAAFFH8IAAICAAYImB1IIgCuAQACAAYImB1IIgCuAQAAAA==.',['劳斯']='劳斯丹顿:BAACLAAFFH8GAAIGAAIILSKzPQC2AAAGAAIILSKzPQC2AAAsAAQKfxsAAgYABwgSI04WADcCAAYABwgSI04WADcCAAAA.',['午夜']='午夜听雨:BAAALAAECgYIBgAAAA==.午夜猫猫:BAABLAAFFH8HAAIKAAMIbQzYHgDXAAAKAAMIbQzYHgDXAAAAAA==.',['南迦']='南迦之巅:BAAALAAECgMIAwAAAA==.',['卡斯']='卡斯丁:BAAALAAECgYIBgAAAA==.',['友利']='友利奈绪:BAAALAADCgMIAwAAAA==.',['反恐']='反恐狐:BAAALAAECgEIAQAAAA==.',['可可']='可可灬:BAAALAAECgYIBwAAAA==.',['呆呆']='呆呆河马:BAABLAAFFH8KAAICAAIICxuvRACfAAACAAIICxuvRACfAAAAAA==.呆呆熊猫:BAABLAAFFH8MAAILAAIIvBDdHwCPAAALAAIIvBDdHwCPAAAAAA==.',['呆小']='呆小法:BAAALAAFFAIIBAAAAA==.',['和谐']='和谐排骨:BAABLAAECn8cAAIMAAYIkQx/QQDeAAAMAAYIkQx/QQDeAAAAAA==.',['咕我']='咕我在:BAAALAAFFAIIAgAAAA==.',['哈哈']='哈哈哥:BAAALAAFFAIIAgAAAA==.哈哈小猎:BAAALAAECgcIBwAAAA==.哈哈萨:BAAALAAFFAMIAwAAAA==.',['哈本']='哈本:BAAALAAECgQIBAAAAA==.',['啊排']='啊排归来:BAABLAAECn8cAAINAAcIohgIKAC6AQANAAcIohgIKAC6AQAAAA==.',['啦布']='啦布布:BAAALAAECgYIDgAAAA==.',['喵新']='喵新星:BAAALAADCgMIAwAAAA==.',['嚣袅']='嚣袅医朲:BAAALAAFFAIIBAAAAA==.',['嚣鳥']='嚣鳥医仁:BAAALAAECgYIEgAAAA==.',['圈圈']='圈圈诅咒:BAAALAAECgIIAgAAAA==.',['土豆']='土豆王子:BAAALAAECgYIBgAAAA==.',['圣光']='圣光王者:BAAALAAFFAEIAQAAAA==.',['垂念']='垂念愈恭:BAABLAAFFH8GAAIKAAYIXBUdIABtAQAKAAYIXBUdIABtAQAAAA==.',['堕月']='堕月:BAAALAAECgcIDAAAAA==.',['夏川']='夏川丨真凉:BAABLAAFFH8GAAIDAAIIhRyLDACyAAADAAIIhRyLDACyAAAAAA==.',['大善']='大善勿血:BAABLAAECn8uAAMOAAgIPA/0FQB+AQAOAAgIEQ/0FQB+AQAPAAYIywOdWwCUAAAAAA==.',['天气']='天气晚来秋:BAAALAAECgYIBgAAAA==.',['天灾']='天灾小牛奶:BAAALAADCgMIAwAAAA==.',['天神']='天神下凡:BAAALAADCgQIBAAAAA==.',['夯大']='夯大力:BAAALAAECgYICwAAAA==.',['失恋']='失恋的猫:BAAALAADCgYIBgAAAA==.',['奈奈']='奈奈個熊:BAAALAADCgYIBgAAAA==.',['妮雅']='妮雅:BAAALAAECgEIAQAAAA==.',['姜明']='姜明子:BAAALAADCgQIBAAAAA==.',['姝释']='姝释:BAAALAADCgQIBAAAAA==.',['娇姐']='娇姐请抽烟:BAACLAAFFH8XAAMQAAUIbws4FAApAQAQAAQIcA04FAApAQARAAQIPQexFACsAAAsAAQKfxgAAxAABghlGudcANwBABAABghlGudcANwBABEABQjwE0NXACYBAAAA.',['子之']='子之夜法:BAAALAAECgQIBAAAAA==.',['家有']='家有孩继续玩:BAAALAAECgYIBgAAAA==.',['小姨']='小姨妈:BAAALAAECgYIBgAAAA==.',['小害']='小害虫:BAAALAAECgYIBgAAAA==.',['小小']='小小枭枭:BAAALAAECggICAAAAA==.小小陈二号:BAABLAAFFH8GAAICAAII1RR8WACQAAACAAII1RR8WACQAAAAAA==.',['小手']='小手冰凉凉:BAACLAAFFH8FAAIQAAIISgT7XQA5AAAQAAIISgT7XQA5AAAsAAQKfxYAAhAACAiSBhZeAP0AABAACAiSBhZeAP0AAAAA.',['小肚']='小肚脐:BAABLAAFFH8LAAICAAMI/gSBgQBYAAACAAMI/gSBgQBYAAAAAA==.',['小腰']='小腰扭扭:BAAALAAECgYIBgAAAA==.',['少女']='少女的梦:BAAALAAECgYIBgAAAA==.',['尔希']='尔希龙术:BAAALAAECgYICAAAAA==.',['尽忘']='尽忘前尘:BAAALAAECgYIBgAAAA==.',['布拉']='布拉德皮孩:BAAALAAECgYIEQAAAA==.',['帅乄']='帅乄锅:BAAALAAFFAIIAgAAAA==.',['常世']='常世万法仙君:BAAALAADCgQIBAAAAA==.',['幽幽']='幽幽狐:BAAALAAECgYIEgAAAA==.',['幽影']='幽影幻灭:BAAALAAECgYICwAAAA==.',['张斗']='张斗斗:BAAALAAECgYIBgAAAA==.',['影子']='影子:BAABLAAFFH8GAAISAAYIDRx8BgDAAQASAAYIDRx8BgDAAQAAAA==.',['影羽']='影羽:BAABLAAFFH8GAAIFAAII7QZ2FwBYAAAFAAII7QZ2FwBYAAAAAA==.',['微笑']='微笑:BAAALAAECgEIAQAAAA==.',['德乄']='德乄爷:BAAALAAECgUIBQAAAA==.',['怀念']='怀念愈冲:BAAALAAECgYIBgAAAA==.',['悲催']='悲催气势:BAAALAAECgYICAAAAA==.',['悲歌']='悲歌难吟:BAAALAAECgIIAgAAAA==.',['想念']='想念愈切:BAAALAAECgYIBgAAAA==.',['感念']='感念愈浓:BAAALAAECgYIBgAAAA==.',['感觉']='感觉被掏空:BAAALAAECgYICwAAAA==.',['戒律']='戒律木:BAABLAAFFH8JAAMQAAMIkgjtUgBDAAARAAIIyggOLwBaAAAQAAEIIwjtUgBDAAAAAA==.',['战牛']='战牛在野:BAAALAAECggICAAAAA==.',['戦一']='戦一士:BAAALAADCgMIAwAAAA==.',['扶摇']='扶摇至上:BAAALAAECggICAAAAA==.',['抠脚']='抠脚大汉:BAAALAAECggICAAAAA==.',['指挥']='指挥:BAAALAAFFAYIBAAAAA==.',['摇摇']='摇摇领先:BAAALAAECgYIDgAAAA==.',['撒拉']='撒拉嘿哟:BAABLAAFFH8IAAITAAQInxVbMQDrAAATAAQInxVbMQDrAAABLAAFFAYIIgAQACodAA==.',['收菜']='收菜六小队:BAAALAADCgYIBgAAAA==.',['故我']='故我思:BAAALAAFFAIIBAABLAAFFAUICgAUANIJAA==.',['斩绝']='斩绝:BAAALAAECgYICAAAAA==.',['断绝']='断绝末路:BAACLAAFFH8KAAIUAAUI0gnTBgBhAQAUAAUI0gnTBgBhAQAsAAQKfxYAAhQACAg3HPYIADsCABQACAg3HPYIADsCAAAA.',['春哥']='春哥快救我:BAAALAAFFAEIAQAAAA==.',['晓他']='晓他:BAAALAAECgYIBwAAAA==.',['晨曦']='晨曦秋景:BAAALAAFFAEIAQABLAAFFAUICgAUANIJAA==.',['暮色']='暮色玫瑰:BAAALAAECgMIAwAAAA==.',['暴走']='暴走的火龙果:BAAALAAFFAIIAgAAAA==.',['最亮']='最亮一颗星:BAAALAAECgYICQAAAA==.',['月翼']='月翼猫头鹰:BAABLAAFFH8QAAMHAAgIOh3aBQBWAgAHAAcIOh3aBQBWAgAVAAEIVx84KwBgAAAAAA==.',['木木']='木木飞:BAAALAADCgIIAgAAAA==.',['来一']='来一个:BAAALAADCgEIAQAAAA==.',['杰尼']='杰尼斯:BAAALAAFFAIIBAAAAA==.杰尼斯伍:BAAALAAFFAIIAgAAAA==.杰尼斯六:BAABLAAFFH8IAAICAAIIpRuiigBJAAACAAIIpRuiigBJAAAAAA==.杰尼斯壹:BAAALAAFFAIIAgAAAA==.杰尼斯拾:BAAALAAECgIIAgAAAA==.杰尼斯拾壹:BAAALAAFFAIIAgAAAA==.杰尼斯斯:BAAALAAFFAIIAgAAAA==.杰尼斯柒:BAAALAAFFAEIAQAAAA==.杰尼斯贰:BAAALAAFFAIIAgAAAA==.',['枫子']='枫子:BAACLAAFFH8kAAICAAYImSLQEwD2AQACAAYImSLQEwD2AQAsAAQKf0cAAgIACAgGJMIJANICAAIACAgGJMIJANICAAEsAAUUCAgvAAIAIiIA.',['枼耐']='枼耐法:BAAALAAECgYICgAAAA==.',['梁朝']='梁朝伟:BAAALAAECgYICAAAAA==.',['死神']='死神玩酷:BAAALAAECgYICwAAAA==.',['残月']='残月天明:BAAALAAFFAIIAgAAAA==.',['氏族']='氏族丨咔咔:BAAALAAECgYICQAAAA==.',['水墨']='水墨:BAACLAAFFH8RAAIKAAMI/xVhQgCRAAAKAAMI/xVhQgCRAAAsAAQKfy4AAwoABwghHXJRAG0BAAoABwghHXJRAG0BAAkABghSEQsgAEgBAAAA.',['沐小']='沐小绫:BAAALAAFFAYIAgAAAA==.',['流水']='流水飞烟:BAAALAAFFAMIAwAAAA==.',['流离']='流离:BAAALAAECgYIBgAAAA==.',['浴血']='浴血重生:BAAALAAECgYIBgAAAA==.',['海王']='海王星:BAAALAAECgcIBwAAAA==.',['清水']='清水先生:BAAALAAECgMIAwAAAA==.清水来了:BAAALAAECgIIAgAAAA==.清水萨:BAAALAAECgIIAgAAAA==.清水龙:BAAALAAECgYIBgAAAA==.',['温柔']='温柔的兰博:BAAALAAECgMIBAAAAA==.',['湮糖']='湮糖:BAAALAAECggICAAAAA==.',['灵精']='灵精夜暗魔:BAAALAAECgYIBwAAAA==.灵精空虚猎:BAAALAAECgEIAQAAAA==.灵精血骑:BAAALAAECgYICgAAAA==.',['灵魂']='灵魂毁灭者:BAACLAAFFH8GAAIIAAYIpQ5DCAA9AQAIAAYIpQ5DCAA9AQAsAAQKfxgAAggABghqEjIVAAQBAAgABghqEjIVAAQBAAAA.灵魂鸡米花:BAAALAAECgIIAgABLAAFFAgIAgAWAAAAAA==.',['炒饼']='炒饼:BAABLAAFFH8OAAIXAAUIgxTvCgAvAQAXAAUIgxTvCgAvAQAAAA==.',['烟熏']='烟熏火燎:BAABLAAECn8aAAIGAAcIFw5GywCJAQAGAAcIFw5GywCJAQAAAA==.',['热烈']='热烈丶的马:BAAALAAFFAIIBAAAAA==.',['焰影']='焰影苇草:BAAALAAECgMIAwAAAA==.',['爬墙']='爬墙:BAAALAAECgEIAQAAAA==.',['爱牧']='爱牧牧:BAAALAAECgUIBQAAAA==.',['爸爸']='爸爸:BAABLAAFFH8MAAINAAYIKwncNwAzAQANAAYIKwncNwAzAQAAAA==.',['特斯']='特斯拉:BAABLAAFFH8WAAIPAAUIPxoiKwDmAAAPAAUIPxoiKwDmAAAAAA==.',['猪肉']='猪肉王子:BAAALAAECgYIDAAAAA==.',['玄德']='玄德爱香香:BAABLAAFFH8GAAIYAAIISAeKDwAnAAAYAAIISAeKDwAnAAAAAA==.',['王睿']='王睿哥哥咚:BAABLAAFFH8YAAMBAAYIfQVmEwAsAQABAAYIfQVmEwAsAQATAAYIAQB3egACAAAAAA==.',['甲鱼']='甲鱼别:BAAALAAECgUIBQAAAA==.',['瘦人']='瘦人术仕:BAAALAAECgUIBQAAAA==.',['白月']='白月光:BAABLAAFFH8IAAIHAAYILw/wGgBYAQAHAAYILw/wGgBYAQAAAA==.',['百里']='百里东君:BAAALAAECgMIBgAAAA==.',['眷念']='眷念愈恭:BAAALAAECgYIBgAAAA==.',['石不']='石不转:BAAALAADCgQIBAAAAA==.',['破极']='破极:BAAALAAECgIIAgAAAA==.',['碳棒']='碳棒:BAAALAAECgUIBQAAAA==.',['祎祎']='祎祎不舍:BAAALAAECgYIDwAAAA==.',['秋意']='秋意那时浓:BAABLAAFFH8IAAIPAAIIQwoPXQCBAAAPAAIIQwoPXQCBAAAAAA==.秋意那时浓丶:BAAALAAECgYIBgAAAA==.',['科羅']='科羅蒂娜:BAABLAAFFH8GAAIMAAYIYQ9WHAByAQAMAAYIYQ9WHAByAQAAAA==.',['空山']='空山新雨后:BAAALAAECgYICQAAAA==.',['米凯']='米凯拉的锋刃:BAABLAAFFH8GAAIQAAYITx7GAwBkAgAQAAYITx7GAwBkAgAAAA==.',['紫苏']='紫苏煎蛋:BAAALAAECgYIDAAAAA==.',['繁呅']='繁呅缛兯:BAABLAAFFH8MAAIZAAIIHw8OEQCBAAAZAAIIHw8OEQCBAAAAAA==.',['纯蓝']='纯蓝色:BAABLAAFFH8FAAIaAAIIHhUKEgBJAAAaAAIIHhUKEgBJAAAAAA==.',['织法']='织法者:BAABLAAECn8nAAMOAAgITiThBwAXAwAOAAgIfCPhBwAXAwAPAAgIMCIaGAD0AgABLAAFFAUICgAUANIJAA==.',['绝境']='绝境无序:BAAALAAECggIEgAAAA==.',['绿茵']='绿茵小旋风:BAAALAAECgQIBAAAAA==.',['老玩']='老玩童:BAAALAAECgUIBQAAAA==.',['肉酱']='肉酱君:BAABLAAFFH8JAAIKAAMILxebQgCQAAAKAAMILxebQgCQAAAAAA==.',['肾虚']='肾虚:BAAALAAECgMIAwAAAA==.',['苍穹']='苍穹龙炎:BAABLAAECn8hAAIbAAgIdRzuCgCBAgAbAAgIdRzuCgCBAgABLAAFFAUICgAUANIJAA==.',['荆邑']='荆邑居士:BAAALAAECgYIBgAAAA==.',['莫问']='莫问大叔:BAAALAADCgEIAQAAAA==.',['菲尔']='菲尔:BAAALAAECgMIAwAAAA==.',['萌之']='萌之煞丶:BAABLAAFFH8MAAIMAAYIdRe3FQCqAQAMAAYIdRe3FQCqAQAAAA==.',['萌萌']='萌萌的小牧師:BAABLAAFFH8GAAIMAAQIjRdUKQCYAAAMAAQIjRdUKQCYAAAAAA==.',['萨满']='萨满牛圣:BAABLAAFFH8GAAITAAII8BioUAB8AAATAAII8BioUAB8AAAAAA==.',['落梦']='落梦无痕:BAAALAADCgQIBAAAAA==.',['蓑笠']='蓑笠翁:BAABLAAECn8UAAMCAAYIaiGfPQDVAQACAAYIaiGfPQDVAQAIAAIIDQtlsQBNAAAAAA==.',['蓝子']='蓝子老赖:BAABLAAFFH8FAAICAAUI7gT9ZACuAAACAAUI7gT9ZACuAAAAAA==.',['蓝筹']='蓝筹股:BAAALAADCgYIBgAAAA==.',['虱子']='虱子座丶:BAAALAAECgYIBgAAAA==.',['蜻蜓']='蜻蜓队长丨:BAAALAAECgYIBgAAAA==.',['血祭']='血祭图纹:BAAALAAECgIIAgAAAA==.血祭幽冥:BAAALAADCgQIBAAAAA==.',['裤子']='裤子哥是帅哥:BAAALAAECgYIDAAAAA==.',['裤派']='裤派猎鑫者:BAAALAAECgYIBgAAAA==.',['西北']='西北望:BAABLAAFFH8HAAICAAUIDAlTXQDYAAACAAUIDAlTXQDYAAABLAAFFAYIHwAGABgaAA==.',['訓練']='訓練師小雪:BAABLAAECn8lAAIMAAcIQxM0UACVAQAMAAcIQxM0UACVAQAAAA==.',['请叫']='请叫我傻曼:BAAALAAECgIIAgAAAA==.',['賞金']='賞金猎秂:BAAALAAECgYIBgAAAA==.',['走位']='走位很风骚:BAABLAAFFH8HAAMbAAIIVgbjHABeAAAbAAIIVgbjHABeAAAcAAIIxhRTHwA+AAAAAA==.',['超级']='超级十字路口:BAAALAAECgYICAAAAA==.',['路過']='路過人间:BAAALAAFFAQIBAAAAA==.',['迪亚']='迪亚波罗丶:BAACLAAFFH8fAAIGAAYIGBroLACKAQAGAAYIGBroLACKAQAsAAQKfxUAAgYACAg3GkVKAGYCAAYACAg3GkVKAGYCAAAA.',['迷失']='迷失的爱丽丝:BAAALAAECgcICQAAAA==.',['部族']='部族龙魂:BAAALAAECgYICwAAAA==.',['酷酷']='酷酷小萌德:BAAALAAECgIIAgAAAA==.',['野牛']='野牛两个半:BAAALAAECgYIEgAAAA==.',['鑐魑']='鑐魑鑐纗:BAABLAAFFH8KAAIKAAQIgxIkOADKAAAKAAQIgxIkOADKAAAAAA==.',['银光']='银光骤雨:BAAALAADCgEIAQAAAA==.',['阿园']='阿园:BAAALAAECgEIAQAAAA==.',['阿慢']='阿慢:BAAALAAECgYICQAAAA==.',['隐秘']='隐秘追猎:BAAALAAECgEIAQAAAA==.',['雷克']='雷克斯:BAAALAAECgYIBgAAAA==.',['震鬼']='震鬼門:BAABLAAFFH8JAAIQAAUIeQv5LQD0AAAQAAUIeQv5LQD0AAABLAAFFAYIHwAGABgaAA==.',['霜寒']='霜寒裁决使:BAACLAAFFH8PAAIOAAMIDxAZDgB+AAAOAAMIDxAZDgB+AAAsAAQKfx0AAg4ACAjNGCoWAHsBAA4ACAjNGCoWAHsBAAAA.',['霸气']='霸气龙族:BAAALAADCgYIBgAAAA==.',['静源']='静源星:BAAALAAFFAIIAgAAAA==.',['风里']='风里有詩句:BAABLAAFFH8HAAIPAAUIViI5DAAHAgAPAAUIViI5DAAHAgAAAA==.',['风雪']='风雪依旧:BAAALAAECgYIBgAAAA==.',['饺子']='饺子:BAABLAAFFH8IAAIGAAYIeSHzFADwAQAGAAYIeSHzFADwAQAAAA==.',['香海']='香海不窄:BAAALAAECgYIDQAAAA==.',['骑了']='骑了个怪:BAAALAAECgIIAgAAAA==.',['骑猪']='骑猪看日出:BAAALAAECgQIBQAAAA==.',['鬼骁']='鬼骁:BAAALAAECggIDAAAAA==.',['鬼鬼']='鬼鬼惑:BAAALAAECgMIAwAAAA==.',['魔法']='魔法权威:BAAALAAECgQIBAAAAA==.',['鸠摩']='鸠摩:BAAALAADCgEIAQAAAA==.',['鸢尾']='鸢尾星辰:BAAALAAECgIIAgAAAA==.',['黢黑']='黢黑:BAAALAAECgEIAQAAAA==.',['黯星']='黯星:BAACLAAFFH8oAAIGAAYIFCAJGwDQAQAGAAYIFCAJGwDQAQAsAAQKfzgAAgYACAjaHKAoANUBAAYACAjaHKAoANUBAAAA.',['龙星']='龙星:BAAALAAECgcIDwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end