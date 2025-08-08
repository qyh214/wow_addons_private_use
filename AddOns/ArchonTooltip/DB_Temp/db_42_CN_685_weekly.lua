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
 local lookup = {'Paladin-Any','Paladin-Retribution','DeathKnight-Unholy','Priest-Holy','Priest-Shadow','Mage-Fire','Mage-Frost','Mage-Arcane','Monk-Mistweaver','Hunter-Marksmanship','Shaman-Elemental','Warrior-Fury','Rogue-Assassination','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Druid-Restoration','Druid-Balance','Rogue-Subtlety','Hunter-BeastMastery','DemonHunter-Havoc','Paladin-Holy','Warrior-Arms','DeathKnight-Blood','Shaman-Enhancement','DemonHunter-Vengeance','Monk-Windwalker','Shaman-Restoration','Paladin-Protection','Priest-Discipline','DeathKnight-Frost','Unknown-Unknown','Monk-Brewmaster','Evoker-Augmentation','Evoker-Devastation','Druid-Guardian',}; local provider = {region='CN',realm='扎拉赞恩',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ae='Aerarion:BAACKgAFFH8GAAIBAAYIiBEAAAAAAAACAAYIiBEAAAAAAAAqAAQKfyEAAgIACAiKIvkVAMACAAIACAiKIvkVAMACAAAA.',Am='Amyla:BAAAKgAECgIIBAAAAA==.',Bl='Bluebones:BAABKgAFFH8GAAIDAAIIGwX7KQB5AAADAAIIGwX7KQB5AAAAAA==.',Bw='Bwmcars:BAAAKgAECgYICAAAAA==.',De='Deepseek:BAAAKgADCgUIBQAAAA==.',Do='Dogcpj:BAACKgAFFH8dAAMEAAMIZRYrIgC9AAAEAAMIZRYrIgC9AAAFAAIIQQx8IwBwAAAqAAQKfyYAAwQACAhpHMIdAOwBAAQACAhpHMIdAOwBAAUABQjSDEE7ABUBAAAA.Dogjpc:BAACKgAFFH8OAAQGAAUIAB9qDQBiAQAGAAUIehVqDQBiAQAHAAMI8BoeEQDZAAAIAAEIUwNlKgAlAAAqAAQKfyEAAgYACAhsE5sTAKwBAAYACAhsE5sTAKwBAAEqAAUUCAgGAAkAFQQA.Dogl:BAAAKgAFFAMIAwAAAA==.Dogt:BAAAKgAECgQIBAAAAA==.',Dr='Dreamagain:BAABKgAFFH8GAAICAAYI4xWvIgBiAQACAAYI4xWvIgBiAQAAAA==.',Ec='Echo:BAAAKgAECgYIBgAAAA==.',En='Enchantedy:BAABKgAECn8oAAICAAgIchy2PQALAgACAAgIchy2PQALAgAAAA==.',Fi='Fice:BAAAKgADCgEIAQAAAA==.',Ga='Galya:BAABKgAFFH8GAAIIAAYIihGsFQA3AQAIAAYIihGsFQA3AQAAAA==.',Gr='Grommash:BAAAKgAECgMIAwAAAA==.',Ha='Hayex:BAABKgAECn8UAAIKAAgISB6XEwA1AgAKAAgISB6XEwA1AgAAAA==.',He='Hellstorm:BAAAKgAECgUIBQAAAA==.',Im='Imm:BAABKgAFFH8MAAMIAAgI5xYaCAD5AQAIAAgIlxQaCAD5AQAHAAQIER5hBQAGAQAAAA==.',Jm='Jmm:BAACKgAFFH8WAAILAAYIHxmTBgD9AAALAAYIHxmTBgD9AAAqAAQKfxgAAgsABwgpJW0FAHUCAAsABwgpJW0FAHUCAAAA.',Ko='Kosse:BAABKgAFFH8GAAIMAAYIxwWGEgAyAQAMAAYIxwWGEgAyAQAAAA==.',Md='Mdem:BAAAKgAFFAgIAgAAAA==.Mdzhu:BAAAKgAECgEIAQAAAA==.',Me='Meisarah:BAABKgAFFH8KAAINAAMIlgyHHQDAAAANAAMIlgyHHQDAAAAAAA==.',Os='Oseven:BAAAKgAFFAQIBAAAAA==.',Pa='Pandaheroes:BAAAKgAECgcICQAAAA==.',Si='Silhouette:BAAAKgAFFAYIBAAAAA==.',Sn='Snownight:BAAAKgAFFAYIBAAAAA==.',Sq='Squidy:BAAAKgADCgIIAgAAAA==.',St='Stonegarlic:BAABKgAFFH8NAAQOAAMIYQ4ACwCWAAAOAAMIYQ4ACwCWAAAPAAMImgiDIgBuAAAQAAEIbQfIEwA5AAAAAA==.Styleblack:BAABKgAFFH8HAAIRAAcICApaBwA8AQARAAcICApaBwA8AQAAAA==.',Th='Thornweave:BAABKgAFFH8IAAISAAgIERZgBwA2AgASAAgIERZgBwA2AgAAAA==.',To='To:BAAAKgAFFAIIAgAAAA==.Tornadory:BAAAKgAFFAIIAgAAAA==.',Va='Vanyas:BAAAKgADCggICAAAAA==.',Ve='Veux:BAAAKgAECggIBQAAAA==.',Vi='Vikenn:BAABKgAFFH8GAAMNAAQIqg27DADaAAANAAQIIAm7DADaAAATAAIIPBGPDQCOAAAAAA==.',Wi='Wisdom:BAAAKgAECgIIAgABKgAECggIFQASAHIlAA==.',Wo='Wolfeye:BAAAKgAECgUIBwAAAA==.',Xi='Xiong:BAABKgAFFH8OAAMRAAYIVg+FFwDkAAARAAUIoA+FFwDkAAASAAUIbhdcGADdAAABKgAFFAgIQwARAFYlAA==.',Ye='Yeviper:BAABKgAFFH8OAAICAAgIehfdCAA1AgACAAgIehfdCAA1AgAAAA==.',['一大']='一大姨妈一:BAAAKgAECgIIAgAAAA==.',['一封']='一封离别信:BAAAKgAECgEIAQAAAA==.',['一级']='一级建造师:BAAAKgAECgQIBAAAAA==.',['万木']='万木纷秀挺:BAABKgAFFH8eAAMUAAYIKR5tBACQAQAKAAYIkR2RCACqAQAUAAYIQRttBACQAQABKgAFFAgIEgAVAJgVAA==.',['不会']='不会变身:BAAAKgAFFAQIAgAAAA==.',['不吃']='不吃爆壳蟹:BAABKgAFFH8FAAIWAAQI7xq4AwAQAQAWAAQI7xq4AwAQAQAAAA==.',['不爱']='不爱吃竹叶:BAAAKgAECgUIBwAAAA==.',['不高']='不高兴:BAABKgAFFH8GAAICAAYIPBvQFQCtAQACAAYIPBvQFQCtAQAAAA==.',['且听']='且听风雨吟丷:BAABKgAFFH8IAAIPAAgI8wpfCADdAQAPAAgI8wpfCADdAQAAAA==.',['丘丘']='丘丘巫师:BAAAKgAECgUIBQAAAA==.',['丨亡']='丨亡者归来丨:BAAAKgAECggIEAAAAA==.',['丨射']='丨射丨咪丨咪:BAABKgAFFH8PAAIKAAQI6CTgGgAWAQAKAAQI6CTgGgAWAQAAAA==.',['丨琳']='丨琳丨:BAAAKgAECggICAAAAA==.',['丶不']='丶不明觉厉:BAAAKgAECgYIBgAAAA==.',['丶康']='丶康斯坦丁:BAABKgAFFH8GAAIVAAYIgBAQFQBSAQAVAAYIgBAQFQBSAQABKgAFFAgIGAAVAFwdAA==.',['丶浅']='丶浅唱低吟:BAAAKgAECgMIBQAAAA==.',['丶起']='丶起啥名:BAAAKgADCgQIBgAAAA==.',['丶阿']='丶阿泰戈:BAAAKgAECgQIBAAAAA==.',['主公']='主公息怒:BAAAKgAECgUIBQAAAA==.',['丽莎']='丽莎:BAABKgAFFH8IAAIMAAgISgWgCADCAQAMAAgISgWgCADCAQAAAA==.',['丽诺']='丽诺:BAAAKgAECgUIBQAAAA==.',['乃乃']='乃乃各熊:BAAAKgADCgMIAwAAAA==.',['二个']='二个萨满:BAAAKgAFFAgIBAAAAA==.',['二哥']='二哥的幻影:BAAAKgAFFAYIBAAAAA==.二哥的法影:BAABKgAFFH8GAAIIAAYIARRUEABoAQAIAAYIARRUEABoAQAAAA==.二哥的血影:BAABKgAFFH8GAAIDAAYIugIIEQDmAAADAAYIugIIEQDmAAAAAA==.',['云巅']='云巅:BAABKgAFFH8HAAICAAMIGxbBVgDDAAACAAMIGxbBVgDDAAAAAA==.',['云无']='云无月:BAAAKgADCggICAAAAA==.',['人生']='人生猎手:BAACKgAFFH8SAAMUAAMIPhsoJgDtAAAUAAMIPhsoJgDtAAAKAAMI2AttHgB/AAAqAAQKfxUAAxQACAgNHj0oABECABQACAgNHj0oABECAAoAAghNEGONAF8AAAAA.',['今晚']='今晚不做饭:BAAAKgAECgIIAgAAAA==.',['今朝']='今朝陌路单:BAABKgAECn8gAAMCAAgIgyGKIACXAgACAAgIgyGKIACXAgAWAAEImwRWWAAhAAAAAA==.',['任我']='任我狂:BAAAKgADCgMIAgAAAA==.任我狂傲:BAAAKgADCgEIAQAAAA==.任我飞:BAAAKgADCgEIAQAAAA==.',['伊人']='伊人丶红妆:BAAAKgAFFAUIAQABKgAFFAgICAAHALIdAA==.',['伊利']='伊利打檑:BAAAKgADCggICAAAAA==.伊利蛋丶怒疯:BAAAKgAECgcIDQAAAA==.伊利蛋的咆哮:BAAAKgAECgYIBAAAAA==.',['伊力']='伊力丹丶怒風:BAABKgAFFH8GAAIVAAYIsBfgEQBvAQAVAAYIsBfgEQBvAQAAAA==.',['伊斯']='伊斯塔凛:BAAAKgAECgcIBwAAAA==.',['伊达']='伊达司:BAAAKgAECggIEQAAAA==.',['伏鸾']='伏鸾:BAAAKgADCgUIBQAAAA==.',['众志']='众志橙橙:BAAAKgAECgMIAwAAAA==.',['传说']='传说的大肥羊:BAAAKgAECgQIBAAAAA==.',['伽蓝']='伽蓝之堂:BAAAKgAECggICAAAAA==.',['低风']='低风速:BAAAKgAECgEIAQAAAA==.',['你不']='你不要过来吖:BAAAKgAECgYIBgAAAA==.',['你刚']='你刚才:BAAAKgAECggICAAAAA==.',['佰仕']='佰仕达:BAAAKgAFFAgIBAAAAA==.',['使命']='使命者:BAABKgAFFH8JAAIXAAcIdhI7BAAGAgAXAAcIdhI7BAAGAgAAAA==.',['依然']='依然深深:BAAAKgADCgcIBwAAAA==.',['信仰']='信仰圣光吧:BAAAKgAECgQIBQAAAA==.',['俺扎']='俺扎小辫子:BAAAKgAFFAIIAgAAAA==.',['俺是']='俺是雅典娜:BAABKgAFFH8JAAIDAAgIQA50CAAHAgADAAgIQA50CAAHAgAAAA==.',['倉木']='倉木麻衣:BAAAKgAECggIEAAAAA==.',['兀自']='兀自笑春風:BAAAKgAFFAQIBAAAAA==.',['元芳']='元芳大人:BAABKgAFFH8FAAIEAAMIyQS2MACDAAAEAAMIyQS2MACDAAABKgAFFAUIIwARAJAMAA==.',['先杀']='先杀那个贼:BAABKgAFFH8OAAQPAAgIbRgqBgAzAgAPAAgIVxgqBgAzAgAQAAMIEQ9FFgCLAAAOAAIIfxp0KgBFAAAAAA==.',['光明']='光明与黄昏:BAABKgAECn8dAAIEAAgIUBIRMABjAQAEAAgIUBIRMABjAQAAAA==.',['光沛']='光沛之萱:BAAAKgAFFAIIBAAAAA==.',['光神']='光神:BAABKgAECn8YAAICAAgIVx1kDwBjAgACAAgIVx1kDwBjAgAAAA==.',['克力']='克力克力:BAAAKgAECgYIBgAAAA==.',['克里']='克里斯一梅深:BAAAKgADCggICwAAAA==.',['克雷']='克雷格大卫:BAAAKgAECgQIAQAAAA==.',['兔斯']='兔斯基熊:BAAAKgAFFAYIBAAAAA==.',['兜兜']='兜兜里有颗糖:BAAAKgADCgEIAQAAAA==.',['全村']='全村的希望丶:BAAAKgAECgQICAAAAA==.',['兮沐']='兮沐:BAAAKgAECgEIAQAAAA==.',['兽猎']='兽猎钱:BAAAKgADCgQIBAAAAA==.',['再筑']='再筑辉煌:BAABKgAFFH8IAAIVAAgIIBWRCAAOAgAVAAgIIBWRCAAOAgAAAA==.',['冰封']='冰封世界:BAAAKgAECggICQAAAA==.',['冰火']='冰火两重天:BAABKgAFFH8SAAMIAAQI+hjSHgDwAAAIAAQI+hjSHgDwAAAGAAMIjQ0NHgDBAAAAAA==.',['冰风']='冰风绿茶:BAAAKgADCgcICAAAAA==.',['冷月']='冷月无双:BAAAKgADCggICAAAAA==.',['冷燕']='冷燕:BAAAKgAECggICAAAAA==.',['凛冬']='凛冬冰封:BAABKgAFFH8MAAMDAAYIuRYHFQBzAQADAAYIKBAHFQBzAQAYAAYIphXSBQBwAQAAAA==.',['凡尔']='凡尔赛提斯:BAAAKgAFFAQIBAAAAA==.',['刀锋']='刀锋:BAAAKgAECgIIAgAAAA==.',['别怕']='别怕我走火:BAABKgAECn8aAAMUAAgIWiSnEgCUAgAUAAgIEySnEgCUAgAKAAcI3RixOQBEAQABKgAFFAgIBQAKAIQQAA==.',['功夫']='功夫大熊猫:BAAAKgADCggICAAAAA==.功夫熊猫启动:BAAAKgAECgMIAwAAAA==.',['势不']='势不可挡:BAACKgAFFH8YAAIXAAQIahRBFADhAAAXAAQIahRBFADhAAAqAAQKfxoAAhcACAjrEs8dAMUBABcACAjrEs8dAMUBAAAA.',['勿丶']='勿丶扰:BAAAKgADCgcICgAAAA==.',['千挺']='千挺峙寒清:BAABKgAFFH8GAAIZAAYI+xUHBQCkAQAZAAYI+xUHBQCkAQAAAA==.',['千早']='千早爱音丨:BAAAKgAFFAIIAgAAAA==.',['升龍']='升龍霸:BAABKgAFFH8GAAIJAAUI2RQxFADSAAAJAAUI2RQxFADSAAAAAA==.',['半夏']='半夏的温柔:BAAAKgAECgMIBAAAAA==.',['半熟']='半熟榴莲:BAAAKgAECgMIAwAAAA==.',['华尔']='华尔街巨饿:BAAAKgAECggIEgAAAA==.',['单眼']='单眼佬:BAAAKgADCgUIBQAAAA==.',['南宫']='南宫糯:BAABKgAFFH8HAAISAAQI/BP0MgDMAAASAAQI/BP0MgDMAAAAAA==.南宫苼:BAAAKgAFFAEIAQAAAA==.',['卡尼']='卡尼琳娜:BAAAKgAECgUIDAAAAA==.',['卡布']='卡布达:BAAAKgAECgQIBAAAAA==.',['卡德']='卡德橙:BAAAKgADCggICAAAAA==.',['原地']='原地唱歌:BAAAKgAECgMIAwAAAA==.',['发改']='发改咨询师:BAABKgAFFH8JAAIaAAMIrAYTGwB6AAAaAAMIrAYTGwB6AAAAAA==.',['变大']='变大变粗:BAABKgAFFH8cAAMRAAgIHwerCQBsAQARAAgIHwerCQBsAQASAAQIGRK6GwDNAAAAAA==.',['可乐']='可乐乌龙茶:BAAAKgAECggICAAAAA==.',['可爱']='可爱大咕咕丶:BAABKgAFFH8LAAMRAAYIZh7sBQC+AQARAAYIZh7sBQC+AQASAAQIogzfRgCUAAAAAA==.',['史蒂']='史蒂芬妃:BAAAKgADCgIIAwAAAA==.史蒂芬菲:BAAAKgADCgQIBQAAAA==.',['君醉']='君醉为红颜:BAABKgAFFH8GAAIUAAYIjxuQDgCLAQAUAAYIjxuQDgCLAQAAAA==.',['咖啡']='咖啡猎手:BAAAKgAECgIIAgAAAA==.',['咚咚']='咚咚香:BAAAKgADCggIDwAAAA==.',['哇卡']='哇卡卡:BAABKgAFFH8JAAICAAMIYggrYACwAAACAAMIYggrYACwAAAAAA==.哇卡战舰:BAAAKgAECgQIBAAAAA==.',['哇啦']='哇啦嘻啦咙:BAABKgAFFH8IAAICAAQI7xwhGAD7AAACAAQI7xwhGAD7AAAAAA==.',['哥不']='哥不解释:BAAAKgAECgMIAwABKgAFFAMICQAbAIwVAA==.',['哥斯']='哥斯丶拉:BAAAKgADCgIIAgAAAA==.',['哦也']='哦也光明之神:BAAAKgADCggICAAAAA==.',['唇边']='唇边的印痕:BAAAKgADCgMIAwAAAA==.',['喵星']='喵星人饭团:BAAAKgAECgQIBAAAAA==.',['嘸極']='嘸極:BAABKgAECn8gAAICAAgI+x2/LgBFAgACAAgI+x2/LgBFAgAAAA==.',['噯已']='噯已逺呿:BAAAKgAECgYIEwAAAA==.',['噯難']='噯難:BAAAKgAECgcICgAAAA==.',['囧涩']='囧涩芙:BAABKgAFFH8GAAICAAYIrRn3IQBlAQACAAYIrRn3IQBlAQAAAA==.',['国民']='国民小可爱:BAAAKgADCggICAAAAA==.国民小甜豆:BAAAKgAECgMIAwAAAA==.',['国王']='国王瓦里安:BAABKgAFFH8GAAIMAAYIsQw7DwBhAQAMAAYIsQw7DwBhAQAAAA==.',['圈圈']='圈圈小可爱:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光咏叹:BAABKgAFFH8NAAICAAYIghEpKgA/AQACAAYIghEpKgA/AQAAAA==.圣光手电筒:BAAAKgAECgUIBQAAAA==.圣光炫耀:BAABKgAECn8bAAICAAgIBB0OMgA3AgACAAgIBB0OMgA3AgAAAA==.圣光猫:BAAAKgADCggICwAAAA==.圣光艾尼路:BAABKgAFFH8IAAICAAgIoRGPCQAPAgACAAgIoRGPCQAPAgAAAA==.圣光铸士尼:BAAAKgADCgEIAQAAAA==.',['在干']='在干嘛:BAAAKgAFFAMIBAAAAA==.',['塔榙']='塔榙:BAAAKgAECgUIBQAAAA==.',['墨小']='墨小鱼:BAACKgAFFH8LAAINAAYIZQ/CEwAWAQANAAYIZQ/CEwAWAQAqAAQKfxcAAw0ACAhGGhMSABACAA0ACAhGGhMSABACABMACAjlFYsQAOMBAAAA.',['壹粒']='壹粒蛋丨怒逼:BAABKgAFFH8NAAIaAAMI8goSGACLAAAaAAMI8goSGACLAAAAAA==.',['夏天']='夏天省电王:BAAAKgAFFAEIAQAAAA==.',['夏璐']='夏璐璐:BAABKgAFFH8KAAISAAYIjxqXEQCRAQASAAYIjxqXEQCRAQAAAA==.',['外特']='外特水:BAABKgAFFH8IAAMRAAgIRhkBDABGAQARAAQIUBYBDABGAQASAAQIZxe1FgDiAAAAAA==.',['夜夜']='夜夜皆然丶:BAAAKgAECgEIAQAAAA==.',['夜怀']='夜怀雅:BAAAKgADCggIEAAAAA==.夜怀雪:BAABKgAFFH8IAAIcAAgIVwy2BwDNAQAcAAgIVwy2BwDNAQAAAA==.',['夜樂']='夜樂:BAAAKgAFFAgIBAAAAA==.',['夜羽']='夜羽大表哥:BAAAKgAECgMIAwAAAA==.夜羽龙帝:BAACKgAFFH8LAAIMAAQIawUAKACqAAAMAAQIawUAKACqAAAqAAQKfx0AAgwACAhXFLgtANABAAwACAhXFLgtANABAAAA.',['大十']='大十字军之剑:BAAAKgAECgEIAQAAAA==.',['大守']='大守八云:BAAAKgAECgIIAgAAAA==.',['大将']='大将軍:BAAAKgADCgEIAQAAAA==.',['大帅']='大帅哥郦老师:BAAAKgAECgEIAQAAAA==.',['大熊']='大熊猫仙人:BAABKgAFFH8PAAIJAAgI7gvjBgCZAQAJAAgI7gvjBgCZAQAAAA==.',['大锤']='大锤八十:BAABKgAFFH8KAAIdAAYI5xejCQBlAQAdAAYI5xejCQBlAQAAAA==.',['大領']='大領主:BAAAKgADCggICAAAAA==.',['天一']='天一命:BAABKgAFFH8OAAMcAAQIxhRLMwCtAAAcAAQIxhRLMwCtAAALAAMI9gjvDwCiAAAAAA==.',['天生']='天生丽质雷姆:BAAAKgAECgQIBAAAAA==.',['太阳']='太阳神:BAAAKgAFFAYIBAAAAA==.',['奡舁']='奡舁:BAAAKgAECgcIBwAAAA==.',['奥克']='奥克塔维亚:BAAAKgAFFAQIBAAAAA==.',['奥蕾']='奥蕾丽婭:BAAAKgAECgYIBgAAAA==.',['奶么']='奶么西哈:BAABKgAFFH8IAAICAAYILyMGGACdAQACAAYILyMGGACdAQAAAA==.',['奶翻']='奶翻全场:BAAAKgADCgQIBAAAAA==.',['如初']='如初見:BAAAKgAECgMIAwAAAA==.',['妖之']='妖之骄法:BAAAKgAECggIDQAAAA==.',['姐姐']='姐姐我还要:BAAAKgADCgQIBwAAAA==.',['威武']='威武的油大爷:BAAAKgADCggICAAAAA==.',['娘口']='娘口三十三:BAAAKgAECgcIDgAAAA==.',['媽丶']='媽丶媽:BAAAKgADCggIDQAAAA==.',['嫂子']='嫂子请放手:BAAAKgAECggIDAAAAA==.',['孟男']='孟男奶爸:BAAAKgAECgMIAwAAAA==.',['孤儿']='孤儿单小牛:BAABKgAFFH8IAAIcAAQI7Q4RHQCTAAAcAAQI7Q4RHQCTAAAAAA==.孤儿单扮演者:BAACKgAFFH8RAAMGAAgIkBwdBQAuAgAGAAgIaxwdBQAuAgAHAAQI4RbABgD4AAAqAAQKfxUAAgcACAiVH9IZADMCAAcACAiVH9IZADMCAAAA.孤儿蛋三世:BAABKgAFFH8GAAICAAQIeRToMAAlAQACAAQIeRToMAAlAQAAAA==.',['安胖']='安胖:BAAAKgADCgIIAgAAAA==.',['安蕾']='安蕾莉雅:BAAAKgAECggIBgAAAA==.',['宝批']='宝批龙:BAAAKgAFFAgIBAAAAA==.',['宿醉']='宿醉:BAAAKgAECgcIBwAAAA==.',['对不']='对不起:BAAAKgADCggICAAAAA==.',['寻月']='寻月追夢:BAAAKgADCgcIAgAAAA==.',['射丨']='射丨咪丨咪丨:BAAAKgAFFAQIBAAAAA==.',['小小']='小小好可爱:BAAAKgAFFAEIAQAAAA==.小小宇:BAACKgAFFH8JAAMaAAQIaAa8GwB3AAAVAAQIZAPVQQB4AAAaAAMIaAa8GwB3AAAqAAQKfx0AAhoACAiNGKQTAO8BABoACAiNGKQTAO8BAAAA.小小的熊猫:BAAAKgAFFAQIAgABKgAFFAgIDgAbANAQAA==.小小真可爱:BAABKgAFFH8FAAISAAQIYhQCEwDuAAASAAQIYhQCEwDuAAABKgAFFAgIEAASANUeAA==.',['小心']='小心恶龙:BAAAKgAECgIIAgAAAA==.',['小新']='小新:BAAAKgAECgYIBgAAAA==.',['小楼']='小楼夜雨听风:BAAAKgAFFAMIAwAAAA==.',['小白']='小白:BAAAKgADCggICAAAAA==.',['小皮']='小皮匠丶:BAAAKgAECgYIDAAAAA==.',['小破']='小破之刃:BAAAKgADCggICAAAAA==.',['小老']='小老头:BAAAKgAECgYIEQAAAA==.',['小迪']='小迪客:BAAAKgAECgIIAgAAAA==.',['小鞋']='小鞋匠:BAAAKgAECgQIBAAAAA==.',['小魅']='小魅影:BAABKgAFFH8IAAIEAAgINBLJBAD0AQAEAAgINBLJBAD0AQAAAA==.',['尕狂']='尕狂:BAAAKgAECgYIBgAAAA==.',['就不']='就不加血:BAAAKgAECggIDQAAAA==.',['就想']='就想看你一眼:BAAAKgAECggICAAAAA==.',['尿末']='尿末滴白:BAABKgAFFH8GAAIYAAYISwOUHgCuAAAYAAYISwOUHgCuAAAAAA==.',['巨灵']='巨灵神拉姆克:BAAAKgADCgEIAQAAAA==.',['巨牧']='巨牧蘸酱:BAABKgAFFH8KAAIeAAMIYR86EgAKAQAeAAMIYR86EgAKAQAAAA==.',['差很']='差很多同学:BAABKgAECn8aAAIEAAgIvCA/CQCTAgAEAAgIvCA/CQCTAgAAAA==.',['帕皮']='帕皮不啃竹:BAAAKgAECgMIAwAAAA==.',['帝小']='帝小羽:BAABKgAECn8UAAIcAAgIMw68SwBMAQAcAAgIMw68SwBMAQABKgAFFAUIIwARAJAMAA==.帝小羽灬:BAAAKgAECgMIBAABKgAFFAUIIwARAJAMAA==.',['带宠']='带宠物逛街:BAAAKgAECgYIAgAAAA==.',['常驻']='常驻嘉宾:BAABKgAFFH8KAAMNAAYIOhrzCwCNAQANAAYIHxjzCwCNAQATAAQILhvQBQADAQAAAA==.',['幸运']='幸运召唤师:BAAAKgAECgMIAwAAAA==.',['庭前']='庭前雨后:BAAAKgAFFAMIBAAAAA==.',['弌対']='弌対尐榊瀦:BAAAKgAECggICAAAAA==.',['弑神']='弑神杀:BAAAKgADCgUIBQAAAA==.',['弱水']='弱水三千丶:BAAAKgADCggIDQAAAA==.',['弹指']='弹指红颜老:BAABKgAFFH8GAAICAAYIZhe2HACBAQACAAYIZhe2HACBAQAAAA==.',['御天']='御天老武:BAAAKgADCgEIAQAAAA==.',['德中']='德中我最牛:BAAAKgAECgYIBwAAAA==.',['德古']='德古喵大王:BAACKgAFFH8QAAMDAAYIxAxhGgBKAQADAAYIUAxhGgBKAQAYAAYIyQtAEgCxAAAqAAQKfxoAAhgACAivFasbALUBABgACAivFasbALUBAAAA.',['德哥']='德哥带你飞:BAAAKgADCggICAAAAA==.',['心梦']='心梦梦幻:BAAAKgAECggIDAAAAA==.心梦缥缈:BAAAKgAECgcIBwAAAA==.心梦逐流:BAAAKgAECggICgAAAA==.心梦陨星:BAAAKgAECgMIAwAAAA==.心梦飓风:BAAAKgAECgEIAQAAAA==.',['忆缱']='忆缱绻:BAAAKgADCgYIBgAAAA==.',['怪咖']='怪咖战舰:BAAAKgADCggIDgAAAA==.',['恋世']='恋世浮曲:BAAAKgAFFAMIAwAAAA==.',['恶魔']='恶魔来信了:BAAAKgAECgUIBQAAAA==.恶魔角:BAAAKgADCgYICwAAAA==.',['悠哉']='悠哉小桃子:BAAAKgAECgUIBwAAAA==.',['悠悠']='悠悠爱:BAABKgAECn8oAAIcAAgIMxVjLwC8AQAcAAgIMxVjLwC8AQAAAA==.',['悠月']='悠月沉吟:BAAAKgAECgEIAQAAAA==.',['惑丶']='惑丶琰:BAABKgAECn8WAAMcAAgIQAx8WQAyAQAcAAgIQAx8WQAyAQALAAMIxBVSVADHAAAAAA==.',['惑之']='惑之不惑:BAAAKgAFFAQIBAAAAA==.',['慕容']='慕容姗姗:BAACKgAFFH9XAAQeAAgIOxQiBgDPAQAeAAgImA8iBgDPAQAEAAUI3xTyCADuAAAFAAQIagu6EACvAAAqAAQKfzMABAQACAgJHqQZAAgCAAQACAhDHaQZAAgCAB4ABQgGHP4wAF8BAAUAAggeE4NNAHgAAAAA.',['我不']='我不会开门:BAAAKgADCgEIAQAAAA==.',['我乃']='我乃光明:BAAAKgAECgUIBwAAAA==.',['我叫']='我叫糖门不滚:BAAAKgADCggICAAAAA==.我叫芙蓉:BAAAKgAECggIDQAAAA==.',['我很']='我很阿娇:BAAAKgADCggICAAAAA==.',['我怕']='我怕开水烫:BAABKgAECn8XAAIMAAgIdhYEIwAIAgAMAAgIdhYEIwAIAgAAAA==.',['我求']='我求你别死:BAAAKgAFFAgIAgAAAA==.',['戒不']='戒不得丶:BAAAKgADCggICAAAAA==.',['手电']='手电侠:BAAAKgAECgEIAQAAAA==.',['执手']='执手:BAAAKgAECgcIBgAAAA==.',['执法']='执法:BAABKgAFFH8GAAIGAAYIExuBAwDXAQAGAAYIExuBAwDXAQAAAA==.',['把总']='把总:BAAAKgADCgMIAwAAAA==.',['抓住']='抓住一只悦悦:BAABKgAFFH8GAAIPAAQIGx7JCwACAQAPAAQIGx7JCwACAQAAAA==.',['抗疫']='抗疫英雄:BAAAKgADCggICgAAAA==.',['报告']='报告老板:BAAAKgAECgYICQAAAA==.',['提里']='提里奥丶茀丁:BAAAKgAFFAIIAgAAAA==.提里奥抚丁:BAABKgAFFH8gAAICAAYIgSQkEADfAQACAAYIgSQkEADfAQABKgAFFAgIFAACABkkAA==.',['收割']='收割的节奏:BAACKgAFFH8jAAMRAAUIkAw3GQDXAAARAAUIkAw3GQDXAAASAAIIVwLHPQAzAAAqAAQKfzMAAxEACAgcGBEaAM4BABEACAgcGBEaAM4BABIAAwhZBe++AEQAAAAA.',['放着']='放着你来:BAABKgAFFH8OAAIVAAgItxzOAgC8AQAVAAgItxzOAgC8AQAAAA==.',['无尽']='无尽梦魇:BAACKgAFFH8OAAMKAAYIIQyBGwASAQAKAAYIIQyBGwASAQAUAAII6wZsOACGAAAqAAQKfxwAAwoACAg+FzslALEBAAoACAg+FzslALEBABQABggqDAmXAPsAAAAA.',['无问']='无问西东:BAAAKgAECgcIDgAAAA==.',['无难']='无难:BAAAKgAFFAIIAgAAAA==.',['旧梦']='旧梦时光不语:BAABKgAECn8UAAMWAAgIlhYYFwC1AQAWAAgIlhYYFwC1AQACAAQIwRA/IAGOAAAAAA==.',['昏鸦']='昏鸦:BAABKgAFFH8IAAIYAAgIyRWcBQDlAQAYAAgIyRWcBQDlAQAAAA==.',['春逝']='春逝:BAAAKgAECggICAAAAA==.',['昧纸']='昧纸:BAAAKgADCggICAAAAA==.',['暗夜']='暗夜狂魔:BAAAKgAECgcICgAAAA==.暗夜里吃眯咪:BAAAKgAECgIIAgAAAA==.',['暗影']='暗影彼得:BAAAKgAECggICQAAAA==.',['暗黑']='暗黑之影:BAACKgAFFH8IAAIfAAMIUxygBgAEAQAfAAMIUxygBgAEAQAqAAQKfycAAh8ACAiqIIEDAI4CAB8ACAiqIIEDAI4CAAAA.',['月夜']='月夜暗猎:BAABKgAFFH8GAAIUAAQIYxBwMQDHAAAUAAQIYxBwMQDHAAAAAA==.',['有丶']='有丶小强:BAABKgAFFH8GAAIEAAYIVgsIEgAhAQAEAAYIVgsIEgAhAQAAAA==.',['朝朝']='朝朝牧牧:BAABKgAECn8UAAIeAAgI5w1POgAFAQAeAAgI5w1POgAFAQAAAA==.',['木登']='木登出不穷:BAAAKgAECgEIAQAAAA==.',['术业']='术业无专攻:BAAAKgAECgEIAgAAAA==.',['术丶']='术丶爷:BAAAKgADCggICQAAAA==.',['术尸']='术尸妹子:BAAAKgAECggICAAAAA==.',['机战']='机战御天:BAAAKgADCgEIAQAAAA==.',['来人']='来人有刺客:BAAAKgAFFAIIBAAAAA==.',['板骑']='板骑倪昂佐:BAAAKgADCggICAAAAA==.',['柠檬']='柠檬柚子:BAAAKgAECgUIBQAAAA==.柠檬汽水:BAAAKgAECgcICQAAAA==.',['柳如']='柳如烟:BAAAKgADCggICAAAAA==.',['柳妹']='柳妹:BAAAKgADCgEIAQAAAA==.',['柳茹']='柳茹艳:BAAAKgAECgEIAQAAAA==.',['根号']='根号二亲儿子:BAAAKgAECgIIAwAAAA==.',['梦幻']='梦幻小熊猫:BAABKgAFFH8HAAIUAAYItRiPAgC7AQAUAAYItRiPAgC7AQAAAA==.',['梦游']='梦游他父亲:BAAAKgADCggICAAAAA==.',['梦若']='梦若晨曦:BAAAKgAECgQIBAAAAA==.',['椿庭']='椿庭梦澜:BAABKgAECn8lAAICAAgIrRqnQQD9AQACAAgIrRqnQQD9AQAAAA==.',['楼蓝']='楼蓝壹飘壳:BAABKgAECn8WAAIMAAgIAw9IMQBpAQAMAAgIAw9IMQBpAQAAAA==.',['榕耀']='榕耀星光:BAAAKgAFFAQIBAAAAA==.',['橙丶']='橙丶猎:BAAAKgAECgcICAAAAA==.',['殇之']='殇之剑:BAAAKgAECgYICQAAAA==.',['残酷']='残酷天使:BAAAKgADCgQIBAAAAA==.',['每天']='每天一只兔:BAABKgAFFH8QAAIPAAYIDxAvGQA6AQAPAAYIDxAvGQA6AQAAAA==.',['毒丝']='毒丝栈鉴:BAAAKgAECgIIAgAAAA==.',['毛熊']='毛熊团:BAABKgAFFH8GAAIZAAYIUgwOCQBJAQAZAAYIUgwOCQBJAQAAAA==.',['水之']='水之静:BAABKgAECn8oAAIEAAcIABp6MwBRAQAEAAcIABp6MwBRAQAAAA==.',['水茉']='水茉青花:BAABKgAFFH8IAAICAAgInCICBgBsAgACAAgInCICBgBsAgAAAA==.',['汐丿']='汐丿舊時光:BAAAKgADCgMIAwAAAA==.',['江洋']='江洋大盗:BAAAKgADCgQIBAAAAA==.',['沁一']='沁一丶:BAAAKgAECgMIBAAAAA==.',['沐雨']='沐雨兮兮:BAAAKgAECggIEAAAAA==.沐雨兮然:BAAAKgAECgcIBwAAAA==.',['没事']='没事就打你:BAABKgAFFH8HAAMCAAUIMwoKSABqAAACAAIIzgYKSABqAAAdAAUIMwpZLAAsAAAAAA==.',['法治']='法治社会:BAABKgAFFH8FAAIGAAUIbAhbGADpAAAGAAUIbAhbGADpAAAAAA==.',['波哥']='波哥彡:BAAAKgAECgQIBAAAAA==.',['泰澜']='泰澜德丶語风:BAABKgAFFH8GAAIUAAYIHgx/GAA3AQAUAAYIHgx/GAA3AQAAAA==.',['泰袒']='泰袒丶欧萨:BAABKgAFFH8IAAMcAAgIfg3jEwDYAAAcAAUIQgTjEwDYAAALAAMIEwSOEQCPAAAAAA==.',['流云']='流云战歌:BAABKgAFFH8eAAICAAMIahbZSgDZAAACAAMIahbZSgDZAAAAAA==.',['流离']='流离指沙间:BAABKgAECn8WAAMMAAgIBCGLEgBHAgAMAAgIBCGLEgBHAgAXAAYIVBUyLgBLAQAAAA==.',['浪四']='浪四花:BAAAKgAECgcIBwAAAA==.',['海印']='海印:BAAAKgAECggICgAAAA==.',['海瑟']='海瑟薇安妮:BAAAKgAFFAMIAwAAAA==.',['润媞']='润媞:BAAAKgAECgEIAQAAAA==.',['混就']='混就完事了:BAABKgAFFH8IAAIKAAQIYgvzGACgAAAKAAQIYgvzGACgAAAAAA==.',['淼厸']='淼厸:BAAAKgAECgYIBgAAAA==.',['清蒸']='清蒸贝鱼:BAAAKgAECgYIBwAAAA==.',['渡渡']='渡渡鸟爱洗澡:BAAAKgAECggIEwAAAA==.',['漠北']='漠北:BAABKgAFFH8SAAMKAAYInBrDDQB/AQAKAAYI7RjDDQB/AQAUAAQIvRzWLQDRAAAAAA==.漠北丶傲天:BAABKgAFFH8UAAICAAYIGSQ3EwDCAQACAAYIGSQ3EwDCAQAAAA==.漠北丶大宗师:BAAAKgAFFAYIAQABKgAFFAgIDgADAA8XAA==.漠北丶大魔王:BAABKgAFFH8JAAMDAAUItxeOGABZAQADAAUItxeOGABZAQAYAAQIdQi/KABzAAAAAA==.漠北丶天下:BAABKgAFFH8GAAIZAAYIhwZ6CABUAQAZAAYIhwZ6CABUAQAAAA==.漠北丶猎手:BAABKgAFFH8GAAIVAAYIASI4CQDuAQAVAAYIASI4CQDuAQAAAA==.',['潇洒']='潇洒的你:BAAAKgAECgEIAQAAAA==.潇洒的碧月:BAAAKgAECgcICAAAAA==.',['潶丶']='潶丶殺戮藝術:BAAAKgAECgEIBAAAAA==.',['濛濛']='濛濛:BAABKgAFFH8MAAMFAAYIlhkBCgBhAQAFAAYIlhkBCgBhAQAeAAQIYxLVHQCsAAAAAA==.',['火丽']='火丽全开:BAAAKgAECgMIAwAAAA==.',['火跳']='火跳跳:BAAAKgAECgIIAgAAAA==.',['灬小']='灬小懒猪灬:BAAAKgAECgYIBgAAAA==.',['灬火']='灬火翼灬:BAABKgAECn8VAAMDAAgIXR2rJwAaAgADAAgIXR2rJwAaAgAYAAIIHA5KWQBYAAAAAA==.',['灬皮']='灬皮包切割者:BAAAKgAFFAIIAgAAAA==.',['灭神']='灭神弑天:BAAAKgAECgYIDQAAAA==.',['灭霸']='灭霸弹指:BAAAKgAECgYICgAAAA==.',['灰太']='灰太郞:BAAAKgAECgUIBQAAAA==.',['灰烬']='灰烬梦寐:BAAAKgADCggICAAAAA==.',['灵动']='灵动迅捷:BAAAKgADCggICAAAAA==.',['灵境']='灵境行者:BAAAKgADCggICAAAAA==.',['点到']='点到爷爷:BAAAKgADCgQIBAAAAA==.',['点点']='点点依恋:BAAAKgAECgcIBwAAAA==.',['炼狱']='炼狱燃景:BAAAKgAECggICAAAAA==.',['烟雨']='烟雨碧落:BAABKgAFFH8WAAIEAAQI1RppDgDlAAAEAAQI1RppDgDlAAAAAA==.烟雨黄泉:BAAAKgAECgYIBgAAAA==.',['热门']='热门战舰:BAABKgAECn8YAAMLAAcIxRoYLQCXAQALAAcIahcYLQCXAQAZAAUIpx3AMQAzAQAAAA==.',['烽火']='烽火戏诸侯丨:BAAAKgAECgcICQAAAA==.',['熊叔']='熊叔叔的救赎:BAAAKgAECgIIAgAAAA==.',['熬夜']='熬夜对眼不好:BAAAKgADCgMIAwAAAA==.',['爱丶']='爱丶请深爱:BAAAKgAECgMIBQAAAA==.',['爱喵']='爱喵喵的可乐:BAAAKgAFFAIIAgAAAA==.',['爱情']='爱情修理工:BAAAKgAECgEIAQAAAA==.',['爱的']='爱的迷茫:BAAAKgAECgIIAgAAAA==.',['爺不']='爺不悲傷:BAABKgAECn8ZAAMUAAgIXBsqJwAXAgAUAAgIXBsqJwAXAgAKAAYIsBhpPABjAQAAAA==.',['牧欲']='牧欲橙风丶:BAAAKgADCggICAAAAA==.',['狂野']='狂野之血:BAABKgAFFH8KAAMKAAYItSFPAADwAQAKAAYItSFPAADwAQAUAAIIdh4GWgBEAAABKgAFFAgIBAAgAAAAAA==.',['狡诈']='狡诈的跳跳蛙:BAABKgAFFH8LAAMFAAYI7RgIDAD6AAAFAAYI7RgIDAD6AAAeAAUIxA8bFAD2AAABKgAFFAgIBgAEAKsLAA==.',['猎杀']='猎杀蜗牛:BAABKgAECn8fAAIUAAgI6SOwCADcAgAUAAgI6SOwCADcAgAAAA==.',['猎猎']='猎猎风遒:BAAAKgAECgEIAQAAAA==.',['猎神']='猎神小小:BAAAKgADCgQIBAAAAA==.',['猪猪']='猪猪宝:BAAAKgAECggICwAAAA==.',['猴哥']='猴哥猴哥:BAAAKgAFFAEIAgAAAA==.',['琍亚']='琍亚德琳:BAAAKgAFFAgIAQAAAA==.',['疯狂']='疯狂麦辣鸡:BAAAKgAFFAQIBAAAAA==.',['白发']='白发小鬼:BAABKgAECn8WAAMWAAgIKR6IAwBOAgAWAAgIKR6IAwBOAgACAAYI6BzuIQCuAQAAAA==.',['百岁']='百岁山:BAAAKgAECgEIAQAAAA==.',['盜愺']='盜愺亾:BAACKgAFFH8WAAIMAAQIMB7vGgDpAAAMAAQIMB7vGgDpAAAqAAQKfxQAAgwACAjwFZMhAMcBAAwACAjwFZMhAMcBAAAA.',['矮要']='矮要坦荡荡丶:BAAAKgAECgUIBgAAAA==.',['破一']='破一启新:BAAAKgADCgYIBgAAAA==.',['破法']='破法:BAAAKgADCgcIBwAAAA==.',['神勇']='神勇之力:BAAAKgADCgIIAgAAAA==.',['神的']='神的王庭:BAACKgAFFH8cAAIMAAgI4iDnAgCSAgAMAAgI4iDnAgCSAgAqAAQKfx8AAwwACAiMEsQ0AK0BAAwACAiMEsQ0AK0BABcABgiHAMxuACAAAAAA.',['神秘']='神秘女:BAAAKgAECgQIBAAAAA==.',['神里']='神里绫华:BAABKgAFFH8GAAIPAAYI+CBcDADHAQAPAAYI+CBcDADHAQAAAA==.',['福噗']='福噗噗:BAAAKgAECggIEgAAAA==.',['福猪']='福猪猪:BAAAKgAECgcIDAAAAA==.',['秋水']='秋水熙熙:BAAAKgAECgIIAgAAAA==.',['秦半']='秦半仙:BAAAKgAECgYIBgAAAA==.',['窃格']='窃格瓦拉丶:BAABKgAFFH8JAAINAAUI1CBUEABLAQANAAUI1CBUEABLAQAAAA==.',['笑霓']='笑霓裳:BAAAKgADCgEIAQAAAA==.',['箭射']='箭射银行:BAAAKgAECgIIAgAAAA==.',['米莉']='米莉丫:BAAAKgADCgMIAwAAAA==.米莉娅:BAABKgAFFH8KAAMPAAUIFh/1EgBvAQAPAAQIFh/1EgBvAQAOAAEIAACbNwAAAAAAAA==.',['粉红']='粉红小饿魔:BAAAKgAECgIIAgAAAA==.',['粉色']='粉色跑道:BAABKgAFFH8GAAICAAYIUhj2IABrAQACAAYIUhj2IABrAQAAAA==.',['精神']='精神科主任:BAACKgAFFH8WAAICAAQIjBwlHgD0AAACAAQIjBwlHgD0AAAqAAQKfxgAAgIACAjZINFXAO8BAAIACAjZINFXAO8BAAAA.',['糯米']='糯米:BAAAKgADCggICAAAAA==.',['紫瑄']='紫瑄:BAAAKgAECggICAAAAA==.',['繁华']='繁华易逝:BAAAKgAECgEIAQABKgAECggIwwAJAPwlAA==.',['红手']='红手丶夏娜:BAAAKgAECgYICAAAAA==.',['红萼']='红萼:BAAAKgAECgUIBQAAAA==.',['红葡']='红葡萄干:BAAAKgAECgcIBwAAAA==.',['纯脆']='纯脆:BAAAKgAFFAQIBAAAAA==.',['给看']='给看翘嘴不:BAAAKgADCgEIAQAAAA==.',['绝版']='绝版狐狸:BAAAKgADCgQIBAAAAA==.',['绮丽']='绮丽:BAAAKgAECggIEQAAAA==.',['绯色']='绯色夏天:BAAAKgADCgEIAQAAAA==.',['绵珞']='绵珞珞:BAABKgAFFH8KAAMZAAYIgwjgCQA1AQAZAAYIgwjgCQA1AQAcAAQIVA4yFADUAAAAAA==.',['绾绵']='绾绵绵:BAABKgAFFH8GAAIFAAYIIyTwBQDRAQAFAAYIIyTwBQDRAQAAAA==.',['缺蛋']='缺蛋蛋的鹌鹑:BAAAKgADCgEIAQAAAA==.',['网瘾']='网瘾治疗专家:BAACKgAFFH9gAAMLAAgIRiXQAADTAgALAAgIRiXQAADTAgAcAAEIFAW1OAAyAAAqAAQKf0MAAwsACAjWJjMAACkDAAsACAjWJjMAACkDABwAAQgAADHSAAAAAAAA.',['羌塘']='羌塘一野牦牛:BAAAKgAECgUIBQAAAA==.',['美食']='美食博主:BAAAKgAECgYIBgAAAA==.',['羽落']='羽落心非:BAABKgAECn8eAAIcAAgI3BhKFACcAQAcAAgI3BhKFACcAQABKgAECggIwwAJAPwlAA==.',['而今']='而今听雨:BAAAKgADCgYIBgAAAA==.',['肉曦']='肉曦小歧势:BAABKgAFFH8GAAICAAYIIhsuHACDAQACAAYIIhsuHACDAQAAAA==.',['肉蛋']='肉蛋蛋:BAABKgAECn8XAAMbAAgIhw87JwBpAQAbAAgIhw87JwBpAQAhAAMICAXVIQA9AAAAAA==.',['肖邦']='肖邦:BAAAKgADCggICAAAAA==.',['肝不']='肝不动:BAABKgAFFH8JAAMHAAMIWQwNJQBqAAAIAAIIAQ1eOwB0AAAHAAMIWQwNJQBqAAAAAA==.肝不动呐:BAAAKgAECgYIBgAAAA==.',['肝爹']='肝爹:BAAAKgAECgUIBwAAAA==.',['能哥']='能哥的深邃:BAABKgAECn8XAAMDAAgIvBq7NgDWAQADAAgIVBq7NgDWAQAYAAgINxDkKgA2AQAAAA==.',['臭宝']='臭宝贝:BAAAKgAECgYIAwAAAA==.',['臭粑']='臭粑粑丶:BAAAKgAECgUICAAAAA==.',['至尊']='至尊无上:BAAAKgADCggICAAAAA==.',['至高']='至高无尚:BAABKgAFFH8GAAIdAAYI7x9yBwCdAQAdAAYI7x9yBwCdAQAAAA==.',['艾弗']='艾弗森:BAACKgAFFH8LAAIUAAQIWxwJEQAIAQAUAAQIWxwJEQAIAQAqAAQKfyEAAhQACAjuIF8bAIsCABQACAjuIF8bAIsCAAAA.',['芍滴']='芍滴可爱:BAAAKgAECggICAAAAA==.',['芒果']='芒果莉:BAAAKgADCggICAAAAA==.',['芝士']='芝士圈圈:BAAAKgADCgUIBQAAAA==.',['芮德']='芮德麦蒂卡:BAAAKgAECgQIBAAAAA==.',['花想']='花想容:BAAAKgADCggICAAAAA==.',['苏格']='苏格拉底:BAAAKgAECgMIAwAAAA==.',['若黛']='若黛:BAAAKgADCgEIAQAAAA==.',['茂挺']='茂挺独先觉:BAABKgAFFH8WAAMDAAYIlyBgDADJAQADAAYIuR5gDADJAQAYAAQI6x6DCAANAQAAAA==.',['莫焰']='莫焰:BAAAKgADCgIIAgAAAA==.',['莺灵']='莺灵:BAAAKgADCggIFQAAAA==.',['萌萌']='萌萌的豚鼠:BAAAKgADCggICAAAAA==.',['萧疏']='萧疏气挺拔:BAAAKgAFFAQIBAAAAA==.',['萨拉']='萨拉多尔:BAAAKgAECgYIBwAAAA==.',['萨满']='萨满巫师:BAAAKgAECgEIAQAAAA==.',['蓝蓝']='蓝蓝路:BAABKgAFFH8LAAMiAAMIhwnXAgB5AAAjAAMIIwkXKQCVAAAiAAMIngXXAgB5AAAAAA==.',['蓝雪']='蓝雪紫幽:BAAAKgAFFAQIBAAAAA==.',['虾米']='虾米那德:BAAAKgAECgMIBwAAAA==.',['蜗蜗']='蜗蜗喵喵:BAAAKgADCgcIBwABKgAFFAgIEAAGADsgAA==.',['血色']='血色小溜溜:BAAAKgAECgYIBgAAAA==.血色黄橙橙:BAAAKgADCggICAAAAA==.',['西门']='西门催血:BAABKgAECn8XAAMOAAYIUxvUCgCRAQAOAAYIUxvUCgCRAQAPAAEIAADAvwAAAAAAAA==.',['角大']='角大的一逼:BAAAKgAECggIDgAAAA==.',['诺达']='诺达希尔之歌:BAAAKgADCggICAABKgAFFAgIBgABAIgRAA==.',['谁忆']='谁忆往日欢:BAAAKgAECgYIBgAAAA==.',['豆哥']='豆哥丶:BAAAKgAECgYIBgAAAA==.',['貓先']='貓先生:BAABKgAFFH8IAAIMAAIIuhF8KwCUAAAMAAIIuhF8KwCUAAAAAA==.',['貝爾']='貝爾蒙特:BAAAKgAECgEIAQAAAA==.',['贼漂']='贼漂亮贼好看:BAAAKgAECggIBgAAAA==.',['起名']='起名真累:BAAAKgAECgQIBAAAAA==.',['輪回']='輪回死骑:BAAAKgADCgYIDAAAAA==.',['轻荡']='轻荡涟漪丶:BAACKgAFFH8FAAICAAIIUxIqegB1AAACAAIIUxIqegB1AAAqAAQKfxcAAgIABwguJOEmAGQCAAIABwguJOEmAGQCAAAA.',['这一']='这一世:BAAAKgAFFAEIAgAAAA==.',['迷离']='迷离夜影:BAAAKgADCgUIBQAAAA==.',['追风']='追风筝的胖子:BAAAKgADCggICAAAAA==.',['這籹']='這籹籽好羙:BAAAKgAECgcICQAAAA==.',['那一']='那一抹忧思丶:BAAAKgADCgQIBQAAAA==.',['那个']='那个萨瞒:BAAAKgADCggIAQAAAA==.',['邪恶']='邪恶召唤:BAAAKgAECgQIBQAAAA==.',['郭芙']='郭芙榕啊:BAAAKgAFFAgIBAAAAA==.',['重练']='重练号很辛苦:BAAAKgAECgIIAgAAAA==.',['銘書']='銘書:BAAAKgAECgQIBAAAAA==.',['鑫迪']='鑫迪焱花:BAAAKgAFFAQIBAAAAA==.',['锄禾']='锄禾曰荡午:BAAAKgAECgYICAAAAA==.',['键来']='键来:BAAAKgAFFAYIBAAAAA==.',['长空']='长空陌路:BAAAKgADCgQIBAAAAA==.',['闪耀']='闪耀五连鞭:BAAAKgADCgEIAQAAAA==.',['阿勒']='阿勒泰大鸡排:BAAAKgAECgQIBQAAAA==.',['阿芙']='阿芙罗蒂特:BAABKgAFFH8WAAMCAAQIkQtEXAC4AAACAAQIkQtEXAC4AAAWAAMI+QJADwBZAAAAAA==.',['阿莱']='阿莱斯特:BAAAKgAECgIIAgAAAA==.',['阿追']='阿追:BAAAKgAECgEIAQAAAA==.',['陆奥']='陆奥天斗:BAAAKgADCgEIAQAAAA==.',['陈阿']='陈阿俊:BAABKgAECn8nAAMRAAgIWxuLBgAqAgARAAgIWxuLBgAqAgAkAAYISAhCEgCaAAABKgAECggIwwAJAPwlAA==.',['随意']='随意丶:BAAAKgADCggIBwAAAA==.',['隔壁']='隔壁老翁:BAAAKgAECgEIAQAAAA==.',['難釋']='難釋懐:BAABKgAECn8jAAMFAAgIJBdKHwCLAQAFAAgIJBdKHwCLAQAEAAcI7Q60IADKAAAAAA==.',['雨皇']='雨皇:BAAAKgAECggICgAAAA==.',['雪松']='雪松绿豆:BAAAKgADCgUIBQAAAA==.',['零时']='零时夜色:BAAAKgADCgcIBwAAAA==.',['露卡']='露卡之刺:BAAAKgADCggICAAAAA==.',['霸气']='霸气女萝莉:BAAAKgAECgEIAQAAAA==.',['顾允']='顾允:BAABKgAFFH8IAAIXAAgIThN6AgBIAgAXAAgIThN6AgBIAgAAAA==.',['顾小']='顾小桑:BAABKgAECn8bAAIXAAgIthhOEgAmAgAXAAgIthhOEgAmAgAAAA==.',['额米']='额米陀佛:BAAAKgAECgcICAAAAA==.',['颠覆']='颠覆战伯冰:BAAAKgADCgcIBwAAAA==.',['風揚']='風揚:BAAAKgAECggIDgAAAA==.',['风一']='风一般怪蜀黍:BAABKgAFFH8PAAMMAAYIRCCSCQAZAQAMAAQIiSGSCQAZAQAXAAMIXh42CgDLAAAAAA==.',['风吹']='风吹来吹吹风:BAAAKgAECggICQAAAA==.风吹毛儿飞:BAAAKgAECgUIBgAAAA==.',['风景']='风景:BAABKgAFFH8GAAIVAAYI9hN9FABWAQAVAAYI9hN9FABWAQAAAA==.',['风轻']='风轻云淡丶:BAAAKgADCgQIBQAAAA==.',['风雨']='风雨中的萨灵:BAAAKgAECgIIAgAAAA==.',['飘飞']='飘飞的落叶:BAABKgAECn8pAAIPAAgIqhRbDQDDAQAPAAgIqhRbDQDDAQAAAA==.',['马歇']='马歇尔蒂奇:BAAAKgAECgMIAgAAAA==.',['骑士']='骑士之魂:BAABKgAFFH8GAAIDAAQIKwbiGgCNAAADAAQIKwbiGgCNAAAAAA==.',['骑遍']='骑遍世界:BAABKgAECn8gAAICAAgINSS3EgDMAgACAAgINSS3EgDMAgAAAA==.',['鬥叮']='鬥叮:BAAAKgAECggICAAAAA==.',['魅影']='魅影诱魂:BAAAKgAECgMIAwAAAA==.',['魇的']='魇的第七章:BAABKgAECn8lAAMWAAgIvhXxFADEAQAWAAgIvhXxFADEAQACAAUIRxKCzAC/AAAAAA==.',['鲁莽']='鲁莽兔零:BAAAKgADCggICAAAAA==.',['麗麗']='麗麗在目:BAAAKgAECgIIAgAAAA==.',['麥麥']='麥麥猪:BAAAKgAECgQIBAAAAA==.',['麦格']='麦格文尼:BAAAKgADCgEIAQAAAA==.',['黄昏']='黄昏之印:BAAAKgAECgUIBQAAAA==.',['黎明']='黎明之盾:BAAAKgAFFAQIBAAAAA==.',['黑夜']='黑夜行者:BAAAKgAECgIIAgAAAA==.',['黑心']='黑心狸猫:BAAAKgAECggICQAAAA==.黑心骑士:BAAAKgAECgMIAwAAAA==.',['黑暗']='黑暗毒蜥:BAAAKgAECgIIAgAAAA==.',['黑曜']='黑曜石拿铁:BAAAKgAECggICAAAAA==.',['黑矮']='黑矮子:BAAAKgAECgMIAwAAAA==.',['黑色']='黑色大猫:BAAAKgAECggICgAAAA==.',['黑锋']='黑锋大领主:BAAAKgAECgcIDQAAAA==.',['齐月']='齐月半:BAAAKgAECgIIAQAAAA==.',['齐达']='齐达内:BAAAKgADCggICAAAAA==.',['龍丶']='龍丶傲天:BAAAKgADCgUIBwAAAA==.',['龙行']='龙行有雨:BAACKgAFFH8OAAIjAAQIpCNfCAATAQAjAAQIpCNfCAATAQAqAAQKfzMAAiMACAgcHyYIABsCACMACAgcHyYIABsCAAAA.',['龙裔']='龙裔:BAAAKgAECgMIAwAAAA==.',['龙雨']='龙雨:BAAAKgAECgYICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end