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
 local lookup = {'Shaman-Restoration','Druid-Balance','Paladin-Retribution','Mage-Fire','Druid-Restoration','Evoker-Devastation','Mage-Frost','Mage-Arcane','Warrior-Protection','Warrior-Arms','Priest-Shadow','Priest-Holy','Priest-Discipline','Warrior-Fury','Shaman-Elemental','DeathKnight-Unholy','DeathKnight-Blood','Paladin-Protection','Paladin-Holy','DeathKnight-Frost','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Mistweaver','Warlock-Destruction','Warlock-Demonology','DemonHunter-Havoc','DemonHunter-Vengeance','Warlock-Affliction','Rogue-Assassination',}; local provider = {region='CN',realm='阿迦玛甘',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ad='Adventure:BAAAKgAECgYICwAAAA==.',Cm='Cms:BAACKgAFFH8JAAIBAAIIRAs2KgB3AAABAAIIRAs2KgB3AAAqAAQKfxoAAgEACAj8FOE6AIoBAAEACAj8FOE6AIoBAAAA.',Co='Constantinn:BAABKgAFFH8IAAICAAgIQiJSAgDKAgACAAgIQiJSAgDKAgAAAA==.Constantinne:BAABKgAFFH8IAAIDAAQIByXrFQBAAQADAAQIByXrFQBAAQAAAA==.',Da='Daeneryst:BAABKgAFFH8SAAIEAAYI6B7PCgCKAQAEAAYI6B7PCgCKAQAAAA==.',Dr='Dreamcher:BAAAKgAECggIBAAAAA==.Drguo:BAAAKgAECgIIAgAAAA==.',En='Envydurid:BAABKgAFFH8JAAICAAYIGRIPJAAIAQACAAYIGRIPJAAIAQABKgAFFAgIKQACAGQbAA==.',Es='Espeon:BAAAKgADCggICAAAAA==.',Fr='Freedruid:BAACKgAFFH8qAAMFAAMIMBbYDADJAAAFAAMIMBbYDADJAAACAAEIyAOiYgAwAAAqAAQKfywAAwUACAjjICUVABsCAAUACAjjICUVABsCAAIABAj0Ej58AOkAAAAA.',Gi='Gimbe:BAABKgAFFH8FAAIGAAUIOBUKFQAlAQAGAAUIOBUKFQAlAQAAAA==.',Go='Goodfriend:BAAAKgADCgEIAQAAAA==.Goodpartner:BAAAKgAFFAQIBAAAAA==.',Ko='Kormac:BAABKgAFFH8HAAIDAAQIlxiOTwDQAAADAAQIlxiOTwDQAAAAAA==.',Le='Leander:BAABKgAECn8eAAMHAAgIaB4sEABJAgAHAAgIaB4sEABJAgAIAAEIAQmpowAgAAAAAA==.',Li='Liuzh:BAAAKgADCgMIAwAAAA==.',Lu='Lumeng:BAABKgAFFH8MAAIDAAgI3STsAAAJAwADAAgI3STsAAAJAwAAAA==.',Ma='Maifa:BAABKgAECn9DAAMJAAgIyxbFEwCvAQAJAAgIyxbFEwCvAQAKAAQI1gJlVABVAAAAAA==.Makaria:BAAAKgAFFAMIAwAAAA==.Mandy:BAAAKgAECgEIAQAAAA==.',Pr='Priteardrop:BAABKgAFFH8QAAQLAAYITiDXAAADAgALAAYITiDXAAADAgAMAAEIeCCjIgBFAAANAAEIQh5aKABBAAABKgAFFAgICAABAO0XAA==.',Ri='Rimbe:BAABKgAFFH8NAAMOAAYIySMVCgCsAQAOAAUIpCQVCgCsAQAKAAYIrR+fCACAAQAAAA==.',Sa='Sarys:BAAAKgAECgYICgAAAA==.',Se='Seraphim:BAAAKgADCggICAAAAA==.',Su='Sun:BAABKgAFFH8HAAMIAAQIVhRtLACyAAAIAAQIVhRtLACyAAAHAAIImA5AFwB9AAAAAA==.',Ti='Timeless:BAAAKgAECgYIBgAAAA==.Tiphareth:BAABKgAFFH8GAAIPAAYIsRSvBwBeAQAPAAYIsRSvBwBeAQAAAA==.',Vv='Vvindrunner:BAAAKgADCgYIBgAAAA==.',Zs='Zsmj:BAAAKgAECgIIBAAAAA==.',['一乐']='一乐逍遥一:BAAAKgADCgUIBQAAAA==.',['一抹']='一抹红颜泪:BAAAKgADCggICAAAAA==.',['一朵']='一朵粑粑花:BAABKgAFFH8GAAINAAYIexLLCQB8AQANAAYIexLLCQB8AQAAAA==.',['一样']='一样:BAABKgAFFH8IAAIDAAgIGxE+DgDyAQADAAgIGxE+DgDyAQAAAA==.',['一羽']='一羽雪一:BAAAKgAECggICwAAAA==.',['一赤']='一赤魅一:BAAAKgAECggICAAAAA==.',['三月']='三月十日:BAAAKgADCgIIBAAAAA==.',['三清']='三清四帝:BAABKgAFFH8GAAIBAAYIKAzcDgANAQABAAYIKAzcDgANAQAAAA==.',['上帝']='上帝之手:BAACKgAFFH8OAAIMAAQIAA9CJgCpAAAMAAQIAA9CJgCpAAAqAAQKfxQABAwACAgKDJpWAN8AAAwABgjgCZpWAN8AAAsABAgMCMZHAJEAAA0ABAhLCgVkAGsAAAAA.',['不懂']='不懂:BAAAKgAECgIIAgAAAA==.',['两眼']='两眼一抹黑:BAAAKgAECgYICQAAAA==.',['丶幽']='丶幽若:BAABKgAFFH8LAAIDAAYIaBqHEwBlAQADAAYIaBqHEwBlAQAAAA==.',['丶椰']='丶椰子汁:BAAAKgADCgYIBgAAAA==.',['丶鱼']='丶鱼仔酱:BAAAKgADCgQIBAAAAA==.',['亡者']='亡者之墙:BAACKgAFFH8GAAIDAAQI0gykVgDDAAADAAQI0gykVgDDAAAqAAQKfx8AAgMACAggGQdMANsBAAMACAggGQdMANsBAAAA.',['伊力']='伊力丹怒風:BAAAKgAECgEIAQAAAA==.',['伪德']='伪德:BAAAKgAECggICQAAAA==.',['伪装']='伪装遗忘:BAAAKgAECgcICwAAAA==.',['低头']='低头皇冠掉:BAAAKgAECgEIAQAAAA==.',['何飞']='何飞爱洗澡:BAAAKgAFFAEIAQAAAA==.',['佰戰']='佰戰:BAAAKgAECgYICAAAAA==.',['光铸']='光铸番茄:BAABKgAFFH8GAAIDAAYIYxf3HwBwAQADAAYIYxf3HwBwAQAAAA==.',['农夫']='农夫:BAAAKgADCgQIBAAAAA==.',['冬泉']='冬泉谷的晨辉:BAABKgAFFH8GAAMNAAQIdBqRFAC6AAANAAMIFh2RFAC6AAALAAEIegMvKQA/AAAAAA==.',['冰丨']='冰丨锋:BAAAKgAFFAgIBAAAAA==.',['冰释']='冰释之尘:BAAAKgADCggIHwAAAA==.',['冰魔']='冰魔邪皇:BAAAKgAECgcIBwAAAA==.',['凉上']='凉上:BAAAKgADCggICAAAAA==.',['凝聚']='凝聚嘚荣耀:BAAAKgAECgYICwAAAA==.',['凡心']='凡心:BAAAKgADCgEIAQAAAA==.',['别扒']='别扒拉我:BAABKgAECn8UAAIBAAcIphiLRQBiAQABAAcIphiLRQBiAQAAAA==.',['前进']='前进的蜗牛:BAABKgAFFH8GAAMNAAYIwxBkEQATAQANAAUIhxJkEQATAQALAAEI8QhlLwA5AAAAAA==.',['剑舞']='剑舞者:BAAAKgAFFAgIBAAAAA==.',['包龙']='包龙星:BAAAKgAECggICAAAAA==.',['华魔']='华魔英雄:BAAAKgADCggIAgAAAA==.',['南蛇']='南蛇藤:BAAAKgADCgUIBQAAAA==.',['印第']='印第安纳:BAAAKgADCgIIAgAAAA==.',['只为']='只为泡妞:BAAAKgADCgcIAgAAAA==.',['可爱']='可爱的煎饼:BAAAKgAECggICQAAAA==.',['吨吨']='吨吨:BAAAKgADCgQIBAAAAA==.',['听天']='听天:BAAAKgADCggICAAAAA==.',['和风']='和风细雨:BAAAKgAFFAIIAgAAAA==.',['唯壹']='唯壹一天天:BAAAKgAECgYIEgAAAA==.',['喀秋']='喀秋莎之怒:BAAAKgAECgEIAQAAAA==.',['嘒彼']='嘒彼參與昴:BAAAKgADCgMIAwAAAA==.',['土豆']='土豆炸薯条:BAABKgAFFH8wAAMQAAgIzCMPAgCgAgAQAAgIzCMPAgCgAgARAAYIkg7jEwACAQAAAA==.',['圣光']='圣光之主:BAABKgAECn8cAAQDAAgIWiBwJwBiAgADAAgIWiBwJwBiAgASAAMISxTGOACoAAATAAEItgl7UwApAAAAAA==.',['地獄']='地獄霸王丸:BAAAKgAECgQIBwAAAA==.',['坤坤']='坤坤回来了:BAAAKgAECggIEQAAAA==.',['埃塞']='埃塞尔弗莱德:BAAAKgAECggICQAAAA==.',['塞西']='塞西娅:BAABKgAFFH8GAAIIAAYIJRpvDwBzAQAIAAYIJRpvDwBzAQAAAA==.',['墨痕']='墨痕乄思恋:BAAAKgADCggICAAAAA==.墨痕乄晴空:BAAAKgAFFAYIBAABKgAFFAgICgADAK0lAA==.',['壹贰']='壹贰叁木头人:BAAAKgADCgUIBQAAAA==.',['夜猫']='夜猫:BAAAKgAECgQIBQAAAA==.',['夜色']='夜色迷人:BAAAKgADCggICAAAAA==.',['大招']='大招开英勇起:BAAAKgAECgcIBwAAAA==.',['天亮']='天亮说晚安:BAABKgAFFH8LAAIDAAQI6B6GFgAAAQADAAQI6B6GFgAAAQAAAA==.',['天蓝']='天蓝蓝:BAAAKgAECgUIBQAAAA==.',['天马']='天马流星拳丨:BAAAKgAECgIIAgAAAA==.',['夶劦']='夶劦淼掱:BAAAKgADCggICAAAAA==.',['夹饼']='夹饼不要辣椒:BAAAKgAECgQIBgAAAA==.',['奔波']='奔波尔灞:BAAAKgADCggICAAAAA==.',['奔騰']='奔騰小野豬:BAABKgAFFH8FAAIOAAUIQBGeFwD9AAAOAAUIQBGeFwD9AAAAAA==.',['奶不']='奶不死你:BAAAKgAECgUIBQAAAA==.',['孙小']='孙小美女:BAAAKgADCggICQAAAA==.',['宝蓝']='宝蓝的信仰:BAABKgAFFH8KAAMRAAYIIxHbFgDrAAAQAAQI8hr7JgDzAAARAAYIPwnbFgDrAAABKgAFFAgIDgAQAEoXAA==.',['寒糖']='寒糖:BAABKgAECn8bAAMHAAgIWhaiHADMAQAHAAgIWhaiHADMAQAIAAEI2gUKqAAWAAAAAA==.',['封狼']='封狼丶居胥:BAABKgAFFH8GAAIQAAYIWQ6MFgBoAQAQAAYIWQ6MFgBoAQAAAA==.',['小坤']='小坤坤:BAABKgAECn8YAAICAAgI/QHEtABZAAACAAgI/QHEtABZAAAAAA==.',['小学']='小学语文老师:BAAAKgAECgIIAgAAAA==.',['小新']='小新:BAAAKgAFFAMIAwAAAA==.',['小红']='小红薯:BAABKgAFFH8IAAMQAAYIKQu0IwAGAQAQAAQIaQW0IwAGAQAUAAIIqRYcDgCWAAAAAA==.',['小羊']='小羊的尾巴尖:BAAAKgADCggICAAAAA==.',['小袁']='小袁同学:BAABKgAECn8wAAIDAAgICR7EMQBbAgADAAgICR7EMQBbAgAAAA==.',['小面']='小面加蛋:BAAAKgAECgEIAQAAAA==.',['小鹿']='小鹿鹿:BAAAKgAFFAQIBAAAAA==.',['尔等']='尔等皆是弟弟:BAAAKgAECgcIBwAAAA==.',['尤菲']='尤菲一塔尼娅:BAAAKgADCgEIAQAAAA==.',['就是']='就是有野性:BAAAKgAECgQICAAAAA==.',['岚妍']='岚妍:BAAAKgAECggICQAAAA==.',['左手']='左手下的星空:BAAAKgAFFAQIBAAAAA==.',['布欧']='布欧:BAAAKgAECgUIBQAAAA==.',['干将']='干将墨邪:BAAAKgADCggICAABKgAECggIHAAVAEwcAA==.干将尐墨:BAABKgAECn8cAAIVAAgITByTHgAJAgAVAAgITByTHgAJAgAAAA==.',['幻想']='幻想破碎者:BAAAKgADCggICAAAAA==.',['弑神']='弑神乄归来:BAAAKgADCgYIBgAAAA==.',['弓月']='弓月:BAACKgAFFH8bAAIWAAQIeBwBJAD4AAAWAAQIeBwBJAD4AAAqAAQKf0EAAhYACAjKJOcJANMCABYACAjKJOcJANMCAAAA.',['往后']='往后余生:BAABKgAFFH8GAAIFAAYIbAawEwACAQAFAAYIbAawEwACAQAAAA==.',['德鲁']='德鲁依死骑:BAACKgAFFH8LAAMRAAMIkQyYGwB7AAARAAMIFQqYGwB7AAAQAAMIEAvnHAB1AAAqAAQKfyIAAhEACAjgD3UoAEcBABEACAjgD3UoAEcBAAAA.',['快睡']='快睡觉觉:BAAAKgAECggIEwAAAA==.',['怎么']='怎么老是你:BAAAKgADCgMIAwAAAA==.',['思睿']='思睿:BAABKgAECn8bAAIDAAgIIxSIZgCPAQADAAgIIxSIZgCPAQAAAA==.',['恶魔']='恶魔月刃:BAAAKgAECgQIBAAAAA==.',['慕容']='慕容灬黛雨:BAAAKgADCggICAAAAA==.',['懒斯']='懒斯洛特:BAABKgAFFH8GAAIDAAYI6hy2GQCRAQADAAYI6hy2GQCRAQAAAA==.',['戈登']='戈登有名的:BAAAKgAECgIIAgAAAA==.戈登费小曼:BAABKgAFFH8GAAIXAAQIWApNFgDHAAAXAAQIWApNFgDHAAABKgAFFAgICQADAKIYAA==.戈登阿喀琉斯:BAAAKgAECggIEQAAAA==.戈登雅典娜:BAAAKgAECgMIAwAAAA==.',['我叫']='我叫不高兴:BAAAKgADCgIIAgAAAA==.',['我就']='我就是小德:BAAAKgAFFAgIAgAAAA==.',['我的']='我的牛牛:BAAAKgADCgMIAwAAAA==.',['我算']='我算开了眼了:BAABKgAFFH8ZAAISAAMIthkEFQDQAAASAAMIthkEFQDQAAAAAA==.',['战场']='战场大元帅:BAAAKgAECggIDQAAAA==.',['拉涅']='拉涅斯:BAAAKgAFFAQIBAAAAA==.',['掉血']='掉血找我干嘛:BAAAKgADCgEIAQAAAA==.',['探险']='探险家黝黑:BAAAKgADCgYIBgAAAA==.',['斡耳']='斡耳朵斯:BAAAKgAECgMIAwAAAA==.',['斯道']='斯道普:BAAAKgADCgUIBQAAAA==.',['明写']='明写春诗丶:BAAAKgAFFAIIAgAAAA==.',['明月']='明月昭昭:BAABKgAFFH8FAAIDAAQILBQNIADpAAADAAQILBQNIADpAAAAAA==.',['易安']='易安居士:BAAAKgADCggICQAAAA==.',['星夢']='星夢:BAAAKgAECgMIBAAAAA==.',['星屑']='星屑:BAAAKgADCgQIBAAAAA==.',['星辰']='星辰紫玥:BAACKgAFFH8aAAMWAAQI8hX5LgDOAAAWAAMIaRT5LgDOAAAVAAQI3w1fLwCwAAAqAAQKfyQAAxYACAhXHyQhADgCABYACAhXHyQhADgCABUACAh4DkRQANsAAAAA.',['春日']='春日祈小鱼:BAABKgAECn8YAAIBAAgIih/6FgA+AgABAAgIih/6FgA+AgAAAA==.',['晓萨']='晓萨:BAAAKgAFFAQIBAAAAA==.',['普罗']='普罗徳摩尔:BAAAKgAECggIEgAAAA==.',['暗色']='暗色雪夜:BAAAKgADCgIIAgAAAA==.',['會長']='會長:BAAAKgADCgYIBgAAAA==.',['有药']='有药儿:BAABKgAECn8dAAQNAAgIcBiDPQAiAQANAAYIXxeDPQAiAQAMAAcIgg87UwDFAAALAAEI8walfAAhAAAAAA==.',['李三']='李三青:BAAAKgAECgcICAAAAA==.',['杰兰']='杰兰特:BAAAKgAECggICAAAAA==.',['松树']='松树恶霸:BAAAKgAECgMIAwAAAA==.',['欧格']='欧格玛:BAAAKgAECgUICQAAAA==.',['死亡']='死亡旋律:BAAAKgAECgEIAQAAAA==.',['残月']='残月随风:BAAAKgADCggICAAAAA==.',['水墨']='水墨点点:BAABKgAFFH8FAAIVAAUIqBylFgAwAQAVAAUIqBylFgAwAQAAAA==.',['水晶']='水晶:BAAAKgAFFAEIAQAAAA==.',['水漾']='水漾涟漪:BAABKgAFFH8GAAIQAAYI0RtnKADsAAAQAAYI0RtnKADsAAAAAA==.',['永恒']='永恒不常在:BAABKgAFFH8GAAMYAAYIMwoSGgA0AQAYAAUIMwoSGgA0AQAZAAEIAACSNwAAAAAAAA==.',['没那']='没那麽简单:BAAAKgADCgEIAQAAAA==.',['沧澜']='沧澜星月:BAAAKgAECgcIBwAAAA==.',['波雅']='波雅丶汉庫克:BAAAKgADCgQIBAAAAA==.',['浪里']='浪里小白龙:BAAAKgADCgYIBgAAAA==.',['涅槃']='涅槃丶尤文:BAABKgAFFH8KAAIUAAgImRQwAgA9AgAUAAgImRQwAgA9AgAAAA==.',['淡淡']='淡淡的味道:BAAAKgADCggICAAAAA==.',['溯洄']='溯洄水之湄:BAABKgAECn8kAAMaAAgICxV6MwCNAQAaAAgICxV6MwCNAQAbAAQIYwiVSwB9AAAAAA==.',['满满']='满满都是奶:BAACKgAFFH8GAAIBAAMIBhWALgC9AAABAAMIBhWALgC9AAAqAAQKfycAAwEACAiKFWdAAHUBAAEACAiKFWdAAHUBAA8ABgioB1oiAKkAAAAA.',['激昂']='激昂来啦:BAAAKgAECgcIBwAAAA==.',['火焰']='火焰紋章:BAACKgAFFH8KAAMYAAYIZBG6DwCUAQAYAAYIZBG6DwCUAQAcAAEIzgPlJwArAAAqAAQKfxoAAxgACAitEucqAG8BABgACAitEucqAG8BABkAAghrDsRmAGUAAAAA.',['灬剘']='灬剘待丨嬡:BAAAKgADCggIAQAAAA==.',['灬霸']='灬霸唱丶:BAACKgAFFH8IAAMcAAQIcSWdAQA7AQAcAAQIcSWdAQA7AQAYAAIISw7yIwCAAAAqAAQKfxkAAxgACAjlHvEZACYCABgACAjlHvEZACYCABkAAQgID5F3AD4AAAAA.',['炎魔']='炎魔堂葫芦:BAAAKgAECgYIDAAAAA==.',['炸鸡']='炸鸡队长:BAAAKgAECggICAAAAA==.',['烈焰']='烈焰红唇丶:BAAAKgADCggICAAAAA==.',['烏尔']='烏尔奇奥拉:BAAAKgADCgQIBAAAAA==.',['熊熊']='熊熊香奈儿:BAAAKgADCgMIAwAAAA==.',['熊猫']='熊猫宝宝:BAAAKgADCggICAAAAA==.',['爆炒']='爆炒傻兔子:BAAAKgADCgQIBAAAAA==.',['爱到']='爱到你想逃:BAAAKgAECgcICQAAAA==.',['爻叶']='爻叶:BAAAKgADCgIIAwAAAA==.',['狂暴']='狂暴武器战:BAACKgAFFH8NAAIOAAMIgBQ4HQDfAAAOAAMIgBQ4HQDfAAAqAAQKfxoAAg4ACAiMGJweACICAA4ACAiMGJweACICAAAA.',['狐思']='狐思丨乱想:BAAAKgADCgIIAgAAAA==.',['狼族']='狼族絕影:BAAAKgAECgEIAQAAAA==.',['狼魂']='狼魂:BAABKgAECn8ZAAIBAAgIDhgaNQCyAQABAAgIDhgaNQCyAQAAAA==.',['猎一']='猎一:BAAAKgAECgcICAAAAA==.',['猜丁']='猜丁壳:BAABKgAFFH8QAAMNAAQI4x8NEQAXAQANAAQI4x8NEQAXAQAMAAEIkx9jIABWAAAAAA==.',['王坡']='王坡大虾:BAAAKgAECgEIAQAAAA==.',['琉璃']='琉璃星:BAAAKgAECgcIBwAAAA==.',['瑪薇']='瑪薇影歌:BAAAKgADCggICAAAAA==.',['瓤是']='瓤是臭的:BAAAKgAECgYICQAAAA==.',['番茄']='番茄小强:BAABKgAFFH8FAAIKAAUITRMqDQA8AQAKAAUITRMqDQA8AQAAAA==.',['疯狂']='疯狂的巨人:BAAAKgADCgMIAwAAAA==.',['神圣']='神圣的光:BAAAKgAECgMIAwAAAA==.',['神羅']='神羅天征:BAAAKgAECgcIDgAAAA==.',['秋风']='秋风骚落叶:BAAAKgAECgUICQAAAA==.',['秋香']='秋香丶:BAABKgAFFH8MAAMFAAgI9Q6OEQASAQAFAAUIhQmOEQASAQACAAQIFRyVEgDwAAAAAA==.',['第五']='第五轻柔:BAAAKgADCgQIBAAAAA==.',['箭箭']='箭箭橙心:BAAAKgAECgUICAAAAA==.',['箭雨']='箭雨繁花:BAAAKgAFFAYIBAAAAA==.',['粑粑']='粑粑棍:BAAAKgADCgIIAgAAAA==.',['系俾']='系俾你:BAAAKgAECgUICAAAAA==.',['繁星']='繁星夜:BAAAKgADCgcICAAAAA==.',['繁花']='繁花树海:BAAAKgADCgMIAwAAAA==.',['红油']='红油钵钵鸡:BAAAKgAECgMIAwAAAA==.',['红红']='红红的奶茶:BAAAKgAFFAgIAwAAAA==.',['纸包']='纸包鱼:BAABKgAFFH8IAAMYAAgIHAtSCwCVAQAYAAYIRgtSCwCVAQAZAAIIJQqYFQBJAAAAAA==.',['绯雨']='绯雨潇潇:BAAAKgAECgYICwAAAA==.',['缇绫']='缇绫:BAABKgAFFH8QAAIYAAgIgQ2+BwDpAQAYAAgIgQ2+BwDpAQAAAA==.',['罗刹']='罗刹千阳:BAAAKgAECgEIAQAAAA==.',['老牛']='老牛萨满:BAAAKgAECgIIAQAAAA==.',['肯德']='肯德基:BAAAKgADCgEIAQAAAA==.',['胧幻']='胧幻月:BAAAKgAECggIDAABKgAECggIGwAWAMUVAA==.',['腊味']='腊味丶煲仔饭:BAAAKgAFFAIIAgAAAA==.',['臻小']='臻小臻:BAAAKgAECgYICQAAAA==.',['花下']='花下晒爪子:BAAAKgAFFAgIAgAAAA==.',['花椒']='花椒:BAAAKgADCgYIBgAAAA==.',['花若']='花若怜:BAAAKgAFFAQIBAAAAA==.',['若薙']='若薙迷兮:BAABKgAFFH8HAAIdAAQIOww4HADKAAAdAAQIOww4HADKAAAAAA==.',['萨无']='萨无风:BAAAKgAFFAQIBAAAAA==.',['蓝色']='蓝色警告:BAAAKgAECgQIBAAAAA==.',['蕾斯']='蕾斯蒂亚:BAAAKgAECgEIAQAAAA==.',['虚空']='虚空夜月:BAAAKgAECgQIBAAAAA==.',['蜜糖']='蜜糖裹枇霜:BAABKgAFFH8HAAIVAAMIWwOiIQBkAAAVAAMIWwOiIQBkAAAAAA==.',['让圣']='让圣光勾引你:BAAAKgAFFAEIAQAAAA==.',['记忆']='记忆随身:BAAAKgAECgEIAQAAAA==.',['贪财']='贪财的唫牛座:BAAAKgAECgYICQAAAA==.',['赖倾']='赖倾德:BAAAKgADCgEIAQAAAA==.',['赤影']='赤影:BAAAKgAECgYIBgAAAA==.',['辛菲']='辛菲尔一暗歌:BAAAKgADCgMIAwAAAA==.',['进击']='进击的莫莫:BAABKgAFFH8OAAMQAAgIIh4NBAB0AgAQAAgIIh4NBAB0AgARAAQIgAKYHQBvAAAAAA==.',['逍遥']='逍遥纵横:BAABKgAFFH8TAAIWAAYIBiA0CgDMAQAWAAYIBiA0CgDMAQAAAA==.',['逐心']='逐心:BAAAKgADCgUIBQAAAA==.',['速渡']='速渡灭:BAAAKgADCgIIAgAAAA==.',['造影']='造影师:BAABKgAFFH8QAAILAAYI/h/zCAAbAQALAAYI/h/zCAAbAQAAAA==.',['邪之']='邪之六六:BAAAKgADCggICAAAAA==.',['郝卷']='郝卷:BAAAKgADCggICgAAAA==.',['醉后']='醉后的三哥:BAAAKgAECgIIAgAAAA==.',['錦瑟']='錦瑟無聲:BAAAKgAECggICAAAAA==.',['铸剑']='铸剑为梨:BAAAKgAECgUIBQAAAA==.',['闪电']='闪电啵霸:BAABKgAFFH8MAAIBAAUIMxZsEQBJAQABAAUIMxZsEQBJAQAAAA==.闪电红薯:BAAAKgAFFAMIAwAAAA==.',['阳光']='阳光的果粒橙:BAAAKgADCggICwAAAA==.',['阿凡']='阿凡达再临:BAAAKgADCggICAAAAA==.',['阿卡']='阿卡斯:BAAAKgAECgQIBAAAAA==.',['阿杰']='阿杰曼德:BAAAKgAFFAQIAgAAAA==.',['隔壁']='隔壁你范叔:BAAAKgAECgcIEQAAAA==.隔壁王大哥:BAABKgAFFH8QAAIDAAgIHiDsBQBTAQADAAgIHiDsBQBTAQAAAA==.',['雨丨']='雨丨夜:BAAAKgADCgMIAwAAAA==.',['雨夜']='雨夜:BAAAKgADCggICAAAAA==.',['雾里']='雾里看飞:BAACKgAFFH8FAAIEAAUI0BbEFAASAQAEAAUI0BbEFAASAQAqAAQKfx4AAwcACAgfJmUDAPoCAAcACAgfJmUDAPoCAAQABgg4GpxNAEgBAAAA.',['霍丽']='霍丽贝尔:BAAAKgAFFAIIAgAAAA==.',['霜凛']='霜凛月:BAABKgAECn8bAAMWAAgIxRXFQgDuAQAWAAgIxRXFQgDuAQAVAAMIzgT+gABJAAAAAA==.',['霞儿']='霞儿:BAAAKgAECggIEQAAAA==.',['露恩']='露恩之橙:BAAAKgAECgYICgAAAA==.',['青红']='青红皂了个白:BAABKgAFFH8MAAIGAAMITAvkJQCnAAAGAAMITAvkJQCnAAAAAA==.',['青龙']='青龙卧墨池:BAAAKgAECggIEQAAAA==.',['風雨']='風雨:BAAAKgAECgEIAQAAAA==.',['风云']='风云向北风:BAACKgAFFH8kAAIDAAYIzyNhDAAjAQADAAYIzyNhDAAjAQAqAAQKfz8AAgMACAiEJgADABcDAAMACAiEJgADABcDAAEqAAUUCAgGABcAiQgA.',['风絶']='风絶:BAABKgAECn8fAAIWAAYI7xITawAVAQAWAAYI7xITawAVAQAAAA==.',['风行']='风行者飘渺:BAAAKgAECggIEgAAAA==.',['风雨']='风雨潇湘:BAAAKgAECgYICgAAAA==.',['飒萨']='飒萨:BAAAKgAECgYIBgAAAA==.',['飘雪']='飘雪的海面:BAAAKgAECgcICQAAAA==.',['食蛇']='食蛇者:BAAAKgADCgMIAwAAAA==.',['香菜']='香菜丫:BAAAKgAECgEIAQAAAA==.',['馫穆']='馫穆桂英馫:BAABKgAECn8cAAMSAAgI5A+MIgBCAQASAAgIbQ+MIgBCAQADAAcI8AndvADZAAAAAA==.',['马祖']='马祖小夜曲:BAAAKgAECgUIBQAAAA==.',['骨碎']='骨碎补:BAAAKgAECgIIAgAAAA==.',['高等']='高等术学:BAAAKgADCgQIBAAAAA==.',['魂念']='魂念:BAAAKgADCggIEgAAAA==.',['黄昏']='黄昏的宁静:BAAAKgADCggICAAAAA==.',['黄色']='黄色预警:BAAAKgAECggIDQAAAA==.',['黑暗']='黑暗幻象:BAABKgAECn8XAAIQAAgInhrnMgDmAQAQAAgInhrnMgDmAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end