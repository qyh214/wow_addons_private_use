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
 local lookup = {'DemonHunter-Havoc','Mage-Arcane','Monk-Windwalker','DeathKnight-Unholy','DeathKnight-Blood','Shaman-Enhancement','Paladin-Retribution','Paladin-Protection','DeathKnight-Frost','Druid-Restoration','Warlock-Affliction','Warlock-Destruction','Shaman-Elemental','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Balance','Priest-Holy','Priest-Shadow','Paladin-Holy','Warrior-Fury','Warrior-Protection','Warlock-Demonology','Mage-Frost','Monk-Brewmaster','Monk-Mistweaver','Shaman-Restoration','Hunter-Survival','Rogue-Subtlety','Mage-Fire','Druid-Feral','DemonHunter-Vengeance',}; local provider = {region='CN',realm='安戈洛',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Armagnac:BAAALAADCgMIAwAAAA==.',As='Asukae:BAACLAAFFH8OAAIBAAQIoRoeEwBnAQABAAQIoRoeEwBnAQAsAAQKfyEAAgEACAjYIGQcAPQCAAEACAjYIGQcAPQCAAEsAAUUBggeAAIAhxUA.',Bl='Blader:BAAALAAECgUIBQAAAA==.',Ch='Cherez:BAAALAAECgUIBQABLAAFFAYIFQADALAbAA==.',Cr='Crownl:BAAALAAFFAIIBAAAAA==.',De='Deepdarkboys:BAABLAAFFH8ZAAMEAAYI+BSxAgCuAQAEAAYIPxSxAgCuAQAFAAIIxQxiEgB4AAAAAA==.',Di='Dissolute:BAABLAAFFH8gAAIGAAcI0RYVAgCRAQAGAAcI0RYVAgCRAQAAAA==.',El='Eleuseus:BAACLAAFFH8bAAIHAAYIfxgVFgCeAQAHAAYIfxgVFgCeAQAsAAQKfx4AAwcABwiLIpAcAC8CAAcABwjLIZAcAC8CAAgAAwibIyFDACsBAAAA.',Hi='Hiiamjay:BAAALAAFFAIIBAAAAA==.',Hl='Hlose:BAAALAAECgYICAAAAA==.',Hu='Huazi:BAAALAAFFAQIAgAAAA==.',Lo='Lo:BAAALAADCgEIAQAAAA==.',Lu='Luvshuai:BAAALAAFFAYIAgAAAA==.',Nu='Nukoo:BAAALAAECgYIEgAAAA==.',Sa='Salmon:BAACLAAFFH8SAAIJAAUI1AnnQgCvAAAJAAUI1AnnQgCvAAAsAAQKfyMAAgkACAhIEgKIAOwBAAkACAhIEgKIAOwBAAAA.',Si='Sinnerdk:BAACLAAFFH8OAAMEAAYIrRmBBABjAQAEAAUIaR2BBABjAQAJAAMIxgl/dgCNAAAsAAQKfxQAAwkABggTHwtCAHsBAAkABghrHQtCAHsBAAQABggGF18rAGcBAAAA.',Sk='Skyinthesea:BAAALAAECgIIAgAAAA==.',Wx='Wxdhs:BAAALAAFFAMIAwAAAA==.',Ya='Yamazaki:BAAALAADCgQIBAAAAA==.',['Àl']='Àlty:BAAALAAECgYICQAAAA==.',['万种']='万种风情:BAABLAAECn8iAAIHAAcIwx1NIwALAgAHAAcIwx1NIwALAgAAAA==.',['三聚']='三聚毒奶:BAABLAAFFH8GAAIKAAII5RzrHgCnAAAKAAII5RzrHgCnAAAAAA==.',['不明']='不明死因:BAAALAAECgYIDAAAAA==.',['丨阿']='丨阿布灬:BAAALAAECggIBAAAAA==.',['丶碎']='丶碎雪镜:BAAALAAFFAIIAgAAAA==.',['丿丶']='丿丶呜啦丨豆:BAAALAADCgQIBAAAAA==.',['乌夜']='乌夜啼:BAACLAAFFH8kAAMLAAYIphupAQCRAQALAAYIyhWpAQCRAQAMAAUIrhsUNQA+AQAsAAQKfyUAAwsABgimJTkFAJMCAAsABgh8JTkFAJMCAAwABghiI7JLABACAAEsAAUUBggeAAcA5CMA.',['二级']='二级眼残:BAAALAAFFAIIAgAAAA==.',['五境']='五境之上:BAAALAAFFAIIAQAAAA==.',['五条']='五条刻:BAABLAAFFH8dAAIJAAYIuRQXKwCLAQAJAAYIuRQXKwCLAQABLAAFFAYIKwANAO4aAA==.',['亡命']='亡命战神:BAAALAADCgYIBgAAAA==.',['亡魂']='亡魂骑士:BAAALAAFFAIIAgAAAA==.',['亿粒']='亿粒蛋怒疯:BAAALAADCgIIAgAAAA==.',['何似']='何似在人间:BAABLAAFFH8GAAIJAAII9hcUTwCiAAAJAAII9hcUTwCiAAAAAA==.',['余年']='余年:BAAALAAFFAIIAgAAAA==.',['依旧']='依旧魅力:BAAALAAECgYIEAAAAA==.',['六丶']='六丶:BAAALAAFFAIIAgAAAA==.',['冥土']='冥土追魂:BAAALAAECgYIDQAAAA==.',['冬哥']='冬哥灬猎:BAABLAAFFH8bAAMOAAYI0hMoTgAVAQAOAAYI0hMoTgAVAQAPAAIIQwFDNABDAAAAAA==.',['冰火']='冰火两重天:BAAALAADCgcIBwAAAA==.',['动物']='动物园牛总:BAABLAAFFH8IAAMKAAIIBwSpVQBIAAAKAAIIBwSpVQBIAAAQAAIINAO9PAAuAAAAAA==.',['叁拳']='叁拳丶:BAAALAAECgYIDwAAAA==.',['司渊']='司渊:BAAALAAECggICAAAAA==.',['吉尔']='吉尔伽美什神:BAAALAAECgYIDAAAAA==.',['吾系']='吾系菜菜子:BAAALAAFFAQIBAAAAA==.',['呛水']='呛水男:BAAALAADCgEIAQAAAA==.',['呜哇']='呜哇噢:BAAALAAECgYICQAAAA==.',['哈狸']='哈狸:BAACLAAFFH8gAAMRAAYI/RbWEgDDAQARAAYI/RbWEgDDAQASAAQIigqhFQDQAAAsAAQKfx0AAxIABwiJGdI3AOMBABIABwiJGdI3AOMBABEABAgJHKQyAC0BAAAA.',['哭泣']='哭泣的维纳斯:BAABLAAECn86AAMTAAgIZhhgJgDpAQATAAcIrhtgJgDpAQAHAAIILAG0owEBAAAAAA==.',['四月']='四月还在下雪:BAAALAAECgUIBQAAAA==.',['地板']='地板王:BAAALAAECgYIBgAAAA==.',['基拉']='基拉的怒火:BAABLAAECn8ZAAIEAAYIURcaIgCqAQAEAAYIURcaIgCqAQAAAA==.',['基里']='基里连科:BAAALAAECgYICgAAAA==.',['墨翼']='墨翼丶幽澜:BAABLAAFFH8KAAMUAAIIHRqwRgBMAAAUAAIIHRqwRgBMAAAVAAIIJQwgMwAvAAAAAA==.',['夏季']='夏季芭乐:BAABLAAFFH8NAAMPAAYIsRepBwCiAQAPAAYI/Q+pBwCiAQAOAAYICxY4TQAYAQAAAA==.',['大叔']='大叔也疯狂:BAAALAAECgUIDwAAAA==.',['大姐']='大姐大真猛:BAAALAAECgYICwAAAA==.',['大师']='大师兄真坑:BAAALAAECgUIBQAAAA==.',['大花']='大花脸:BAABLAAFFH8GAAIWAAII6Rb+EQBIAAAWAAII6Rb+EQBIAAAAAA==.',['天德']='天德:BAAALAAECgcIBwAAAA==.',['奶蓟']='奶蓟草:BAAALAAFFAMIAwAAAA==.',['如梦']='如梦令:BAACLAAFFH8GAAIPAAIIWxvHGgCfAAAPAAIIWxvHGgCfAAAsAAQKfyQAAg8ABggeIp0jAE8CAA8ABggeIp0jAE8CAAEsAAUUBggeAAcA5CMA.',['孙小']='孙小仙:BAAALAAFFAIIAgAAAA==.',['孤星']='孤星残月:BAAALAADCgYIBgAAAA==.',['宴清']='宴清都:BAACLAAFFH8eAAIHAAYI5CNQCQD9AQAHAAYI5CNQCQD9AQAsAAQKfysAAgcABggRJhU0AKMCAAcABggRJhU0AKMCAAAA.',['小倩']='小倩倩:BAAALAAECgYICwAAAA==.',['小宝']='小宝佩奇:BAAALAAECgYICgAAAA==.',['小小']='小小鱼碗里来:BAABLAAFFH8GAAMWAAIIzQZwHgB3AAAWAAIIzQZwHgB3AAAMAAEIPgCoZAAXAAABLAAFFAgICAAKAL8fAA==.',['小烨']='小烨烨:BAAALAAECgMIAgAAAA==.',['小红']='小红红:BAAALAAECgYICwAAAA==.',['小面']='小面皮儿:BAAALAAECgIIAgAAAA==.',['尾巴']='尾巴控:BAAALAAFFAMIAwAAAA==.',['山木']='山木有枝:BAAALAAFFAIIBAAAAA==.',['很没']='很没头脑:BAAALAAECgMIAwAAAA==.',['快乐']='快乐的大角:BAAALAADCgUIBQAAAA==.',['忽悠']='忽悠小骑:BAAALAAECgYICgAAAA==.',['我有']='我有神经冰:BAACLAAFFH8rAAIXAAYIYhOrBQBjAQAXAAYIYhOrBQBjAQAsAAQKf0gAAhcACAj1H+0MANICABcACAj1H+0MANICAAAA.',['战龙']='战龙于野:BAAALAADCgcIBwAAAA==.',['抚丝']='抚丝足掌峰峦:BAABLAAFFH8OAAISAAIIBxF2JgBLAAASAAIIBxF2JgBLAAAAAA==.',['拂晓']='拂晓晨星:BAAALAAECgYIBgAAAA==.',['拉风']='拉风风:BAAALAAECgcIBwAAAA==.',['拿得']='拿得起放得下:BAABLAAECn8nAAIMAAYIEhPVTgAUAQAMAAYIEhPVTgAUAQAAAA==.',['星恒']='星恒残月:BAAALAAECgYIBgAAAA==.',['智能']='智能流:BAAALAAECgUIBQAAAA==.',['暴走']='暴走小学生:BAABLAAFFH8VAAIDAAYIsBvoBQCjAQADAAYIsBvoBQCjAQAAAA==.暴走练习生:BAABLAAFFH8GAAIBAAYIaQ/0HwCCAQABAAYIaQ/0HwCCAQAAAA==.',['术业']='术业有专攻:BAAALAAECgYICgAAAA==.',['来啦']='来啦老弟:BAAALAAECgYIBgAAAA==.',['枕香']='枕香肩尝朱唇:BAABLAAFFH8KAAMYAAYIsw+7DwBOAQAYAAYIsw+7DwBOAQAZAAIIJQcpGABdAAAAAA==.',['柳哥']='柳哥:BAAALAADCgcIBwAAAA==.',['桖銫']='桖銫坆瓌韓:BAAALAADCggICAAAAA==.',['梦泽']='梦泽:BAABLAAFFH8JAAIJAAYIWhQ3NABrAQAJAAYIWhQ3NABrAQAAAA==.',['水域']='水域乄卖萌:BAAALAAFFAIIAgAAAA==.',['泰岚']='泰岚徳:BAAALAAECggICQAAAA==.',['流星']='流星残月:BAAALAAFFAIIAgAAAA==.',['浣溪']='浣溪沙:BAACLAAFFH8OAAICAAYImAyvNAApAQACAAYImAyvNAApAQAsAAQKfxQAAxcABgj2H0omAPMBAAIABgizHstVAAICABcABgirHEomAPMBAAEsAAUUBggeAAcA5CMA.',['源野']='源野:BAAALAAECgYICwAAAA==.',['滚滚']='滚滚:BAABLAAFFH8aAAIaAAYIFgy3JgAsAQAaAAYIFgy3JgAsAQAAAA==.',['炫舞']='炫舞龙:BAAALAADCgIIAgAAAA==.',['牛皮']='牛皮的野猫:BAAALAAECgcICgAAAA==.',['牧神']='牧神魔蝎:BAAALAAECgQIBAAAAA==.',['狼之']='狼之图腾:BAABLAAFFH8IAAIaAAIINhZUPQCGAAAaAAIINhZUPQCGAAAAAA==.',['王小']='王小猫:BAAALAADCgUIBQAAAA==.',['甜甜']='甜甜的糖:BAABLAAECn8eAAMbAAYIpRZrBwBbAQAbAAYIpRZrBwBbAQAOAAEIPQmePAEoAAAAAA==.',['生为']='生为卖萌:BAAALAAFFAIIAgAAAA==.',['痛彻']='痛彻心绯:BAAALAAECgIIAgAAAA==.',['百步']='百步穿牛:BAABLAAFFH8HAAIOAAMI2wqzfABfAAAOAAMI2wqzfABfAAAAAA==.',['瞧尔']='瞧尔萨斯:BAABLAAFFH8GAAIHAAYIGBoMDwDMAQAHAAYIGBoMDwDMAQAAAA==.',['碎雪']='碎雪镜:BAAALAAECgYIBgAAAA==.',['神棍']='神棍:BAACLAAFFH8IAAIaAAIItSLdNwDEAAAaAAIItSLdNwDEAAAsAAQKfzUAAhoACAjRIjUFAAYDABoACAjRIjUFAAYDAAAA.',['神马']='神马都是浮云:BAAALAAFFAIIAgAAAA==.',['秦天']='秦天:BAAALAAFFAIIAgAAAA==.',['秦玉']='秦玉:BAABLAAFFH8GAAIRAAIItQg9RABiAAARAAIItQg9RABiAAAAAA==.',['罗铁']='罗铁柱:BAAALAAFFAEIAQAAAA==.',['羊美']='羊美娜斯:BAACLAAFFH8hAAMMAAYIGxl9IQCWAQAMAAYIGxl9IQCWAQALAAEI0hGHCABHAAAsAAQKfxgAAwwABwg3G2tPAAQCAAwABwg3G2tPAAQCAAsABQjoD3MaAC4BAAAA.',['胸毛']='胸毛君:BAABLAAFFH8JAAIYAAII0QuqIAAyAAAYAAII0QuqIAAyAAAAAA==.',['艾秋']='艾秋:BAABLAAFFH8GAAIcAAQIEg9pCAAjAQAcAAQIEg9pCAAjAQAAAA==.',['菜鸟']='菜鸟驿站:BAAALAAFFAIIAwAAAA==.',['落日']='落日残月:BAAALAAECgIIAgAAAA==.',['虎眼']='虎眼流一清玄:BAAALAAFFAIIAgAAAA==.',['血珊']='血珊瑚:BAABLAAFFH8eAAMCAAYIhxVJMwAyAQACAAUIQxhJMwAyAQAdAAIIWAsoCAB/AAAAAA==.',['血腥']='血腥罪人:BAABLAAFFH8IAAIeAAYIHhH4BABjAQAeAAYIHhH4BABjAQAAAA==.',['诚心']='诚心诚意:BAABLAAFFH8MAAICAAgIbh53BACnAgACAAgIbh53BACnAgAAAA==.',['贼神']='贼神之贼帅:BAAALAAECgYICQAAAA==.',['轩辕']='轩辕嗜血:BAAALAAECgcIDwAAAA==.',['辛辣']='辛辣天生:BAAALAAECgYIBwAAAA==.',['还是']='还是不够黑:BAAALAADCggICAAAAA==.',['迪门']='迪门修斯:BAAALAAECgYICQAAAA==.',['逍遥']='逍遥蘑菇仙人:BAAALAAFFAIIAgAAAA==.',['逐日']='逐日者谢尔比:BAAALAAECgYIDAAAAA==.',['遮雨']='遮雨也遮月光:BAAALAAFFAQIBAAAAA==.',['那個']='那個战四:BAAALAADCgEIAQAAAA==.',['那又']='那又咋了:BAAALAAECgYIBgAAAA==.',['醉仙']='醉仙望月步:BAABLAAFFH8KAAIYAAYI3xEECwAHAQAYAAYI3xEECwAHAQABLAAFFAgIDwATAD4XAA==.',['采花']='采花小小盗:BAABLAAFFH8GAAIaAAYI4BpIEADkAQAaAAYI4BpIEADkAQAAAA==.',['重启']='重启之一粒丹:BAABLAAFFH8MAAMfAAIIIQ+sFAAtAAABAAIIJAZkWACCAAAfAAIIIQ+sFAAtAAABLAAFFAYIKwANAO4aAA==.重启之牛飒萨:BAACLAAFFH8rAAINAAYI7hqWFACXAQANAAYI7hqWFACXAQAsAAQKfx4AAg0ACAgVF0Q8ABQCAA0ACAgVF0Q8ABQCAAAA.',['铭文']='铭文师的猫:BAAALAADCgYIBgAAAA==.',['陈大']='陈大锤:BAABLAAECn8fAAITAAgIDBACLgC6AQATAAgIDBACLgC6AQAAAA==.',['陈铁']='陈铁柱:BAAALAAECgYIBgAAAA==.',['随风']='随风飘流:BAAALAAFFAIIBAAAAA==.',['霍卡']='霍卡恩怒雷:BAAALAAECgIIAgAAAA==.',['頭给']='頭给你拧下来:BAABLAAFFH8hAAMIAAUIhgnIDADAAAAIAAUIMgnIDADAAAAHAAQI9QLnPACfAAAAAA==.',['风声']='风声依旧:BAABLAAFFH8WAAIHAAUIJAq7MAD/AAAHAAUIJAq7MAD/AAAAAA==.',['风舞']='风舞黄沙:BAAALAAECgUIBQAAAA==.',['飞的']='飞的更高:BAAALAAFFAEIAQAAAA==.',['龙骑']='龙骑:BAAALAAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end