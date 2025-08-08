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
 local lookup = {'Shaman-Restoration','Priest-Shadow','Druid-Balance','Mage-Fire','DeathKnight-Blood','DeathKnight-Unholy','Mage-Arcane','Mage-Frost','Druid-Restoration','Druid-Guardian','Rogue-Assassination','Priest-Holy','DemonHunter-Havoc','Monk-Mistweaver','Monk-Windwalker','Hunter-BeastMastery','Paladin-Retribution','Paladin-Protection','DemonHunter-Vengeance','Shaman-Enhancement','Priest-Discipline','Hunter-Marksmanship','Warlock-Destruction','Hunter-Survival','Warrior-Fury','Warlock-Demonology','Warlock-Affliction','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Warrior-Arms','Unknown-Unknown','Shaman-Elemental','Warrior-Protection','DeathKnight-Frost',}; local provider = {region='CN',realm='羽月',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ad='Addoil:BAAAKgAFFAEIAQAAAA==.',Ai='Aisha:BAAAKgAFFAgIBAAAAA==.',Ak='Akari:BAAAKgAFFAYIAgAAAA==.',Ap='Apoll:BAABKgAECn83AAIBAAgIEiI5CgCcAgABAAgIEiI5CgCcAgAAAA==.',Aq='Aqua:BAABKgAFFH8GAAICAAQIqAzRFAC9AAACAAQIqAzRFAC9AAABKgAFFAgIFAADAFUiAA==.',Ar='Artekro:BAAAKgAECgYIBgAAAA==.',Ba='Basara:BAAAKgADCgMIAwAAAA==.',Bl='Blindlegend:BAAAKgAECgUIBQAAAA==.',Cr='Crazyseven:BAABKgAFFH8GAAIEAAYINx0RCQCuAQAEAAYINx0RCQCuAQAAAA==.',Da='Darkempress:BAABKgAFFH8HAAIFAAYInAgDGgDSAAAFAAYInAgDGgDSAAAAAA==.Darkpowet:BAAAKgAECgYICQAAAA==.',Di='Die:BAABKgAFFH8FAAMFAAUIkwUcIABfAAAFAAQI1gEcIABfAAAGAAEIyBBXLQBWAAAAAA==.',Do='Donk:BAAAKgAECgQIBAAAAA==.',El='Ella:BAAAKgAECgMIAwAAAA==.',Fo='Forces:BAAAKgAFFAMIBAAAAA==.',Ga='Ganymede:BAAAKgAECgUIBQAAAA==.',Gl='Glamdring:BAABKgAFFH8SAAQHAAYIkRdkEQBdAQAHAAYIthVkEQBdAQAEAAQIWRoeGQDrAAAIAAQI9xcECQDmAAAAAA==.',Ha='Hakeya:BAAAKgADCggICAAAAA==.',Ka='Kaerlushi:BAAAKgAECggICgAAAA==.',La='Laodashiwo:BAABKgAECn8nAAMJAAgIlBNFIgCMAQAJAAgIlBNFIgCMAQAKAAEICAaHRgAOAAAAAA==.',Lu='Lunalight:BAABKgAECn8ZAAIHAAcIaRP0EQAxAQAHAAcIaRP0EQAxAQAAAA==.',Ma='Mareeta:BAABKgAFFH8GAAILAAQISRDfCwDkAAALAAQISRDfCwDkAAAAAA==.',Mi='Miia:BAAAKgAECgUIBQAAAA==.Miinjure:BAAAKgAECggICAAAAA==.Mirriw:BAAAKgADCggICAAAAA==.',Mo='Morningglory:BAAAKgAECggIBwAAAA==.',Na='Naisha:BAAAKgAECggICAAAAA==.',Pl='Pluto:BAAAKgAECggIDwAAAA==.',Pr='Prometheus:BAACKgAFFH8vAAQHAAUItxxoDwA6AQAHAAUIBBxoDwA6AQAEAAQIqRMQCADkAAAIAAEISByGEwBWAAAqAAQKfy4ABAQACAixHskdAEECAAQACAijHskdAEECAAcABAhQGh1LABIBAAgAAghOEDimADwAAAAA.',Ra='Rakusu:BAAAKgADCggICAAAAA==.',Re='Remeber:BAAAKgAECgYIEAAAAA==.',Ro='Rosicky:BAAAKgAFFAYIBAAAAA==.',Ru='Ruccd:BAAAKgAECgIIAgAAAA==.',Se='Serein:BAABKgAFFH8KAAQHAAQIlx/TMgCYAAAHAAMInxzTMgCYAAAEAAIIDhLFLQCSAAAIAAEIiCWHGwBRAAAAAA==.',Sn='Snowangel:BAAAKgAECgcICwAAAA==.Snowteas:BAAAKgAECgYIBAAAAA==.Snowwater:BAAAKgAECgYICQAAAA==.Snowy:BAAAKgAFFAQIBAAAAA==.',St='Steven:BAAAKgAECggICAAAAA==.',Su='Sudera:BAAAKgAECgYIBgAAAA==.',Th='Thierry:BAABKgAFFH8OAAIBAAYI/yKeAADtAQABAAYI/yKeAADtAQABKgAFFAgIDgAMACAkAA==.',Tu='Turpio:BAAAKgAECggICAAAAA==.',Xc='Xcjxcj:BAAAKgAECgIIAgAAAA==.',Yi='Yi:BAAAKgAECgIIAgAAAA==.',Za='Zahzy:BAABKgAECn8VAAINAAgIJxvcLgCmAQANAAgIJxvcLgCmAQAAAA==.Zakty:BAACKgAFFH8HAAIOAAMInxoqDgDMAAAOAAMInxoqDgDMAAAqAAQKfy4AAw8ACAiIHYUVADQCAA8ACAiIHYUVADQCAA4ABgiNH2AZAL8BAAAA.',Zo='Zonl:BAABKgAFFH8ZAAIQAAcIOiAeBgAyAgAQAAcIOiAeBgAyAgAAAA==.',Zx='Zxlcmj:BAAAKgADCgMIAwAAAA==.',['一喝']='一喝就喝高:BAAAKgAFFAQIBAAAAA==.',['一箭']='一箭追月:BAAAKgADCgUIBgAAAA==.',['一袋']='一袋米扛几楼:BAAAKgAECgMIAwAAAA==.',['三娘']='三娘:BAAAKgADCgIIAgAAAA==.',['三指']='三指弹天:BAABKgAFFH8UAAMHAAgIbSWpAAD9AgAHAAgIbSWpAAD9AgAEAAQIVwXBFQAHAQAAAA==.',['三老']='三老板:BAAAKgAECggIAwAAAA==.',['上弦']='上弦月:BAAAKgAECggICgAAAA==.',['下狼']='下狼:BAAAKgAECgIIAgAAAA==.',['不可']='不可撼动:BAAAKgAECgUICgAAAA==.',['不好']='不好点长肥了:BAABKgAFFH8NAAMFAAgIjxc5CgBxAQAFAAYIyho5CgBxAQAGAAMIFAsuQQCaAAAAAA==.',['不要']='不要议论:BAAAKgAECgEIAQAAAA==.',['专属']='专属妳的温柔:BAAAKgAECgcICwAAAA==.',['且看']='且看云舒:BAABKgAFFH8GAAIBAAYISw/GEwA4AQABAAYISw/GEwA4AQAAAA==.',['东东']='东东二号:BAAAKgAECgMIAwAAAA==.',['丨克']='丨克莱茵:BAABKgAFFH8MAAIRAAYIByDoHACAAQARAAYIByDoHACAAQAAAA==.',['丨紫']='丨紫丶小囡:BAACKgAFFH8FAAIQAAMIZBD+OwCsAAAQAAMIZBD+OwCsAAAqAAQKfxkAAhAACAjzGRkuAPMBABAACAjzGRkuAPMBAAAA.丨紫丶小薇:BAACKgAFFH8LAAMEAAgI6xDtBgDtAQAEAAgIOxDtBgDtAQAIAAMIiA/SGACyAAAqAAQKfxUAAggACAgQHH8GAE4CAAgACAgQHH8GAE4CAAAA.',['丰川']='丰川素世:BAAAKgAECgEIAQAAAA==.',['丶乐']='丶乐无忧丶:BAAAKgAFFAQIBAAAAA==.',['为了']='为了成就三:BAAAKgAFFAQIBAAAAA==.',['乔乔']='乔乔:BAAAKgAECggICAAAAA==.',['九曦']='九曦:BAABKgAFFH8IAAIMAAgIvRR+BAD9AQAMAAgIvRR+BAD9AQAAAA==.',['也许']='也许没有也许:BAAAKgAECggIDgAAAA==.',['五條']='五條悟:BAAAKgAECgYIBgAAAA==.',['从小']='从小就很帅啊:BAAAKgAECgUIBQAAAA==.',['伊瑞']='伊瑞尔丶:BAACKgAFFH8FAAIRAAMIBBZFRgDiAAARAAMIBBZFRgDiAAAqAAQKfxkAAxEACAipHt46AD4CABEABwgMI946AD4CABIAAghaBMNqAA8AAAAA.',['伊蕾']='伊蕾影歌:BAAAKgAECgMIAwAAAA==.',['伤懐']='伤懐:BAABKgAECn8XAAMNAAgI5x4/GQBtAgANAAgI5x4/GQBtAgATAAEIXQxCcAAkAAAAAA==.',['低调']='低调的暴菊:BAAAKgAECgIIAgAAAA==.',['佐倉']='佐倉双葉:BAAAKgAECgQIBAAAAA==.',['你你']='你你我我他他:BAAAKgAECgYICQAAAA==.',['依能']='依能:BAABKgAECn8pAAIRAAgIjCQ4DwDbAgARAAgIjCQ4DwDbAgAAAA==.',['假行']='假行僧:BAAAKgADCgIIAgAAAA==.',['元素']='元素之歌:BAAAKgAECgMIAwAAAA==.元素烈焰:BAACKgAFFH8HAAIBAAMIoApDHgCNAAABAAMIoApDHgCNAAAqAAQKfxcAAwEACAhREzA9AIABAAEACAhREzA9AIABABQAAgggC4AcAE8AAAAA.',['光辉']='光辉圣骑:BAAAKgAECgQIBQAAAA==.',['六味']='六味丨地黄丸:BAABKgAFFH8IAAIMAAgIMhaCBAD8AQAMAAgIMhaCBAD8AQAAAA==.',['六月']='六月的橘子酱:BAAAKgAECggIEwAAAA==.',['冰摇']='冰摇马提尼:BAAAKgAECgMIAwAAAA==.',['冰火']='冰火冲天:BAAAKgADCggICAAAAA==.',['冰蓝']='冰蓝悲忆:BAAAKgAECggIDAAAAA==.',['冰锋']='冰锋:BAAAKgAECgQIBAAAAA==.',['冰鲜']='冰鲜柠檬水:BAAAKgAECgIIAgAAAA==.',['冷咲']='冷咲月:BAAAKgAECgMIBQAAAA==.',['冷樹']='冷樹葉:BAAAKgAFFAQIBAAAAA==.',['凉拌']='凉拌见手青:BAAAKgAECgMIAwAAAA==.',['凡尔']='凡尔塞玫瑰:BAAAKgADCggIEAAAAA==.',['凤凰']='凤凰灵儿:BAAAKgAECgcIDgAAAA==.',['凨凪']='凨凪風夙:BAAAKgAECgYICwAAAA==.',['凶狠']='凶狠的二咕父:BAAAKgAECgYICwAAAA==.',['刘青']='刘青云:BAAAKgAECggICgAAAA==.',['剑履']='剑履上殿:BAAAKgADCgcICQAAAA==.',['剣聖']='剣聖:BAAAKgAECggIBgAAAA==.',['劝业']='劝业场大力王:BAAAKgADCgQIBAAAAA==.',['加诺']='加诺德斯:BAAAKgAECgEIAQAAAA==.加诺德萨:BAABKgAFFH8HAAIBAAcI7ha+FgAoAQABAAcI7ha+FgAoAQAAAA==.',['勒个']='勒个娃儿可爱:BAAAKgADCggIDAAAAA==.',['北美']='北美小小灰狼:BAAAKgAECgMIAwAAAA==.',['千帆']='千帆舞影:BAABKgAECn8YAAIMAAcIFCNaEABGAgAMAAcIFCNaEABGAgAAAA==.',['千早']='千早爱音:BAAAKgAECgMIBAAAAA==.',['千颂']='千颂依:BAAAKgAECgQIBAAAAA==.',['南河']='南河:BAAAKgAECgYIBwAAAA==.',['卡洛']='卡洛琳特:BAAAKgADCgUIBQAAAA==.',['卡米']='卡米奇亚:BAAAKgAFFAYIBAAAAA==.',['历史']='历史的尘埃:BAAAKgADCgEIAQAAAA==.',['双手']='双手插兜儿:BAABKgAFFH8aAAMEAAgIYR/XBAC5AQAEAAgITh7XBAC5AQAIAAIIVCOwEACgAAAAAA==.',['叠最']='叠最厚的甲:BAAAKgADCggICAAAAA==.',['只会']='只会拉链子:BAABKgAECn8fAAIBAAgI5R5rEwBVAgABAAgI5R5rEwBVAgAAAA==.',['叫我']='叫我大肚汉:BAAAKgADCgEIAQAAAA==.',['可以']='可以吗:BAACKgAFFH8JAAQCAAcIqh38CQAPAQACAAUIUxr8CQAPAQAVAAIIgCMlGADRAAAMAAII5Q2rNwBhAAAqAAQKfycAAwwACAiJIEIUACICAAwACAgxIEIUACICABUABAiQG5pXALwAAAAA.',['吃饱']='吃饱饱睡好好:BAAAKgAECgcICAAAAA==.',['吉村']='吉村车钛:BAAAKgAFFAIIAgAAAA==.',['君向']='君向潇湘:BAAAKgAECgEIAQAAAA==.',['含羞']='含羞带点骚:BAAAKgAFFAYIBAAAAA==.',['咒鵺']='咒鵺:BAAAKgADCgMIAwAAAA==.',['咔咔']='咔咔罗特:BAAAKgAECgIIAgAAAA==.',['哎呀']='哎呀:BAAAKgAECgMIAwAAAA==.',['哔哩']='哔哩哔哩丶战:BAAAKgAECggICgAAAA==.',['嗜血']='嗜血伯爵:BAAAKgAFFAQIBAAAAA==.',['嘟小']='嘟小满:BAAAKgAFFAEIAQAAAA==.嘟小牧:BAABKgAFFH8SAAMMAAYIgx7lCADuAAAMAAQIAyHlCADuAAAVAAIIwxo6EgDMAAABKgAFFAgIHwACAAoWAA==.',['四季']='四季发财:BAACKgAFFH8RAAIQAAMI0RHMNQC9AAAQAAMI0RHMNQC9AAAqAAQKfxoAAxAACAiPGeJSALgBABAACAiPGeJSALgBABYAAghlBc61ABoAAAAA.',['囤囤']='囤囤:BAAAKgAECgIIAgAAAA==.',['圣光']='圣光丶使者:BAAAKgAECgEIAQAAAA==.圣光余辉:BAAAKgADCggICAAAAA==.圣光大角牛:BAAAKgADCggICgAAAA==.圣光永不灭:BAABKgAECn8XAAMRAAgI2RX+awDBAQARAAcI1xj+awDBAQASAAEI6APhYQAHAAAAAA==.',['在魅']='在魅边:BAAAKgAECgUIBQAAAA==.',['埃及']='埃及吧想不想:BAABKgAFFH8GAAIRAAYIOBnkIABrAQARAAYIOBnkIABrAQAAAA==.',['塞尔']='塞尔达是天:BAAAKgADCgQIBAAAAA==.',['墨心']='墨心掌柜:BAAAKgADCgQIBAAAAA==.墨心灬咕喵德:BAAAKgAECgIIAgAAAA==.',['墨色']='墨色轻舞流年:BAAAKgAECgYICAAAAA==.',['壹頁']='壹頁书:BAABKgAFFH8MAAIIAAQIex13BQAFAQAIAAQIex13BQAFAQAAAA==.',['夏夜']='夏夜清风:BAABKgAFFH8GAAIMAAYI+h9HBgDOAQAMAAYI+h9HBgDOAQAAAA==.',['夕阳']='夕阳昔阳:BAAAKgADCggICAAAAA==.',['夜与']='夜与梦:BAAAKgAECgEIAgAAAA==.',['夜之']='夜之於:BAAAKgAECgcIEQABKgAFFAgIBwASAI4RAA==.夜之语:BAACKgAFFH8HAAISAAcIjhFAEgDrAAASAAcIjhFAEgDrAAAqAAQKfyoAAhEACAheJioPANsCABEACAheJioPANsCAAAA.夜之雨:BAABKgAFFH8GAAIHAAYIpBSFEQBcAQAHAAYIpBSFEQBcAQAAAA==.夜之飘舞:BAAAKgAECgQIBAAAAA==.',['夜曦']='夜曦如梦:BAABKgAFFH8GAAIVAAMIwAYkEACDAAAVAAMIwAYkEACDAAAAAA==.',['夜畔']='夜畔猫:BAAAKgAECgEIAQAAAA==.',['夜的']='夜的同类:BAAAKgADCgEIAQAAAA==.',['夜阑']='夜阑谣:BAAAKgAECgUIBwAAAA==.',['大主']='大主教伊瑞尔:BAAAKgAFFAQIBAAAAA==.',['大宅']='大宅一子:BAAAKgAECgYIBgAAAA==.',['大掌']='大掌柜:BAAAKgAFFAMIAwAAAA==.',['大满']='大满贯:BAAAKgADCgEIAQAAAA==.',['大灰']='大灰狼来啦:BAABKgAFFH8FAAIQAAQIdRVPHQAbAQAQAAQIdRVPHQAbAQAAAA==.',['大米']='大米豆豆:BAAAKgADCgQIBAAAAA==.',['大队']='大队长助理:BAAAKgADCgQIBAAAAA==.',['大雁']='大雁南飞:BAABKgAECn8ZAAIXAAgIZBkBGQDeAQAXAAgIZBkBGQDeAQABKgAFFAgIBQASAKwgAA==.',['大鷲']='大鷲伊迪丝:BAABKgAFFH8jAAIJAAcIcRz/CAB4AQAJAAcIcRz/CAB4AQAAAA==.',['天使']='天使的哀伤:BAAAKgADCgUIBQAAAA==.',['天堂']='天堂之声:BAAAKgAECgYIDgAAAA==.天堂神光:BAAAKgAECgEIAQAAAA==.',['天梵']='天梵:BAAAKgAECggICAAAAA==.',['天真']='天真:BAAAKgAFFAMIAwAAAA==.',['天边']='天边的你:BAAAKgAECgIIAgAAAA==.',['太阳']='太阳神:BAABKgAECn8kAAMWAAgIZSBkEgBmAgAWAAgIZSBkEgBmAgAYAAII8xwzGwBSAAAAAA==.',['夹克']='夹克:BAABKgAECn8eAAIZAAgIuw1WOgA4AQAZAAgIuw1WOgA4AQAAAA==.',['奈奈']='奈奈雪:BAAAKgAECgEIAQAAAA==.',['奥村']='奥村春:BAAAKgAECgYIBgAAAA==.',['奶白']='奶白色雪子:BAAAKgAECgMIBQAAAA==.',['好汉']='好汉一个半:BAAAKgAECgcICwAAAA==.',['妇科']='妇科手术大夫:BAACKgAFFH8LAAQXAAYIMBnnAwB+AQAXAAUIcxvnAwB+AQAaAAEIJBDWEwBXAAAbAAEIagHnIgAtAAAqAAQKfysAAxcACAjnITUQAGgCABcACAj0IDUQAGgCABoABAgrHkU7APQAAAAA.',['妞牛']='妞牛纽拗:BAAAKgAECgIIBQAAAA==.',['妮诺']='妮诺:BAAAKgAFFAIIAgAAAA==.',['子轼']='子轼:BAAAKgAECgYIBgAAAA==.',['季末']='季末春闱:BAAAKgAFFAEIAQAAAA==.',['孤独']='孤独狂舞:BAAAKgADCggICAAAAA==.孤独箭舞:BAAAKgADCggICAAAAA==.',['宋夭']='宋夭夭:BAAAKgADCggICAAAAA==.',['完颜']='完颜兀术:BAABKgAECn8yAAINAAgIhiC5DgCPAgANAAgIhiC5DgCPAgAAAA==.',['寂寞']='寂寞灬宿命:BAABKgAECn8iAAIRAAgIeBvDSwAOAgARAAgIeBvDSwAOAgAAAA==.',['寒牙']='寒牙:BAAAKgADCggIGwAAAA==.',['寺本']='寺本理絵:BAAAKgAECgQIBAAAAA==.',['小加']='小加诺:BAAAKgAECgYIDAAAAA==.',['小寶']='小寶貝:BAAAKgAECggIDgAAAA==.',['小小']='小小的蚂蚁子:BAAAKgAECggICQAAAA==.',['小巧']='小巧一粒:BAAAKgAECgYIBgAAAA==.',['小恬']='小恬恬:BAAAKgADCgMIBQAAAA==.',['小明']='小明打野:BAABKgAFFH8GAAIQAAYIwg8dFgBGAQAQAAYIwg8dFgBGAQAAAA==.',['小林']='小林哥哥:BAAAKgADCggICwAAAA==.',['小爱']='小爱心:BAAAKgAECgYIDwAAAA==.',['小牧']='小牧點儿:BAAAKgAFFAgIAgAAAA==.',['小米']='小米嘟嘟:BAAAKgADCgEIAQAAAA==.小米豆豆:BAAAKgADCgIIAgAAAA==.',['小舒']='小舒不想输:BAAAKgAECggIDwAAAA==.',['小钢']='小钢炮:BAAAKgAFFAIIAgAAAA==.',['小龙']='小龙人爱吐息:BAAAKgAFFAQIBAAAAA==.小龙人高达:BAACKgAFFH8oAAMcAAUIIyA+DABvAQAcAAUIIyA+DABvAQAdAAEI7BXGAwBGAAAqAAQKfxQAAxwABQgWH0UeAMcBABwABQgWH0UeAMcBAB4ABAjPAygcAKIAAAAA.',['尖椒']='尖椒肉丝:BAAAKgAECgEIAQAAAA==.',['尤丽']='尤丽迪丝:BAABKgAECn8uAAIMAAgIuh+NEQBFAgAMAAgIuh+NEQBFAgAAAA==.',['屮疍']='屮疍:BAABKgAFFH8KAAINAAYItBslEwBhAQANAAYItBslEwBhAQAAAA==.',['川上']='川上貞代:BAAAKgAECgEIAQAAAA==.',['工藤']='工藤由愛:BAAAKgAECgEIAQAAAA==.',['已经']='已经摆烂了:BAAAKgAFFAQIBAAAAA==.',['巴索']='巴索罗缪大熊:BAAAKgAECgcIBwAAAA==.',['布衣']='布衣骑士:BAACKgAFFH8GAAIMAAMIUhEUJwCmAAAMAAMIUhEUJwCmAAAqAAQKfx4AAgwACAg1Gh8YAAACAAwACAg1Gh8YAAACAAAA.',['希尔']='希尔瓦努斯:BAAAKgADCgYIBgAAAA==.',['带狗']='带狗季森:BAAAKgADCgQIBAAAAA==.',['帮你']='帮你打官司:BAAAKgAFFAYIBAAAAA==.',['常夜']='常夜樱:BAAAKgAFFAIIBAAAAA==.',['幕后']='幕后凋零:BAABKgAFFH8FAAIZAAQIvwooFADmAAAZAAQIvwooFADmAAAAAA==.幕后幕后凋零:BAABKgAFFH8HAAIRAAYI0RqRGwCHAQARAAYI0RqRGwCHAQAAAA==.幕后黑手骑士:BAAAKgAFFAgIBAAAAA==.',['平凡']='平凡清风:BAAAKgADCggIDAAAAA==.',['幸福']='幸福小米:BAAAKgADCggIEAAAAA==.',['幺儿']='幺儿幺幺:BAAAKgAFFAIIBAAAAA==.',['幻想']='幻想的可乐:BAABKgAFFH8IAAMfAAQIOB/IBQAHAQAfAAQI/xzIBQAHAQAZAAQIwxREEQD1AAAAAA==.',['弄霄']='弄霄:BAAAKgAECgcIDwAAAA==.',['张四']='张四十一岁:BAABKgAFFH8OAAMZAAYI+BXkAQCyAQAZAAYI/BLkAQCyAQAfAAQIDRz6EgDtAAABKgAFFAgIEAALAIYiAA==.',['弹指']='弹指声中:BAABKgAFFH8FAAMSAAMIZgglJwBVAAARAAII3ApfeQB3AAASAAMIQgIlJwBVAAAAAA==.',['影袭']='影袭:BAAAKgADCgUIBQAAAA==.',['御船']='御船千早:BAAAKgAECggICAAAAA==.',['微笑']='微笑在左:BAABKgAFFH8GAAIXAAYI2Rg1FwBKAQAXAAYI2Rg1FwBKAQAAAA==.',['心碎']='心碎的微笑:BAABKgAFFH8CAAIOAAIIOgX3NAArAAAOAAIIOgX3NAArAAAAAA==.',['忍野']='忍野咩咩:BAAAKgAECgcIDwAAAA==.',['忧棂']='忧棂:BAAAKgAECgUICgAAAA==.',['悲鸣']='悲鸣月:BAAAKgAECgEIAQAAAA==.',['慕珑']='慕珑:BAAAKgADCggICAAAAA==.',['我就']='我就是小丑:BAACKgAFFH8GAAIFAAYIFBKVFAClAAAFAAYIFBKVFAClAAAqAAQKfxUAAwYACAgVIe0ZAGUCAAYACAigH+0ZAGUCAAUABQgMFIxCALQAAAAA.',['我怕']='我怕额钱啊躺:BAAAKgADCgQIBAAAAA==.',['我感']='我感觉很难受:BAAAKgAECgIIAgAAAA==.',['手捧']='手捧雷:BAAAKgAECgEIAQAAAA==.',['折戟']='折戟沉沙:BAABKgAFFH8LAAISAAMI1gisEAB3AAASAAMI1gisEAB3AAAAAA==.',['捞的']='捞的淌口水:BAAAKgADCgIIAgAAAA==.',['提瓦']='提瓦特掉色人:BAABKgAFFH8IAAIFAAgIewURBwA9AQAFAAgIewURBwA9AQAAAA==.',['搞裙']='搞裙子:BAABKgAFFH8MAAISAAYI/B3sAADHAQASAAYI/B3sAADHAQAAAA==.',['敏锐']='敏锐贼:BAAAKgAFFAEIAQAAAA==.',['无情']='无情之寒冰:BAAAKgAECgQIBAAAAA==.',['无惧']='无惧签约:BAAAKgADCgIIAgAAAA==.',['无敌']='无敌夹克:BAACKgAFFH8EAAIUAAMIVQoOCwCyAAAUAAMIVQoOCwCyAAAqAAQKfy4AAwEACAjpFzUpANoBAAEACAjpFzUpANoBABQACAhBD5sQAPoAAAAA.无敌妞妞魔:BAAAKgAECggIEgAAAA==.',['无禁']='无禁的风:BAAAKgAFFAQIBAAAAA==.',['时光']='时光流丶:BAAAKgAECgUIBgABKgAFFAMIEAAIAEohAA==.',['时间']='时间:BAABKgAECn8ZAAMSAAcISAljNADFAAASAAcIrAdjNADFAAARAAEInA++NAExAAAAAA==.时间就系我:BAAAKgAECgcIDAABKgAECggIEAAgAAAAAA==.',['昆仑']='昆仑悠闲:BAAAKgAECggICAAAAA==.',['星辰']='星辰九天:BAACKgAFFH8rAAMCAAgIeBNlCwASAQACAAUIGQ5lCwASAQAMAAYIghdFFgADAQAqAAQKf00ABAIACAjbHksMAF8CAAIACAjbHksMAF8CAAwACAhDGHwhANUBABUABQiVCs1nAIwAAAAA.星辰耀长空:BAAAKgAECgMIAwAAAA==.',['是老']='是老相好吧:BAAAKgAFFAQIBAAAAA==.',['晓丶']='晓丶点点:BAABKgAECn8dAAIQAAgI2yMoFQCoAgAQAAgI2yMoFQCoAgAAAA==.',['晓情']='晓情卓意:BAAAKgADCgUIBQAAAA==.',['晓月']='晓月圜舞曲:BAAAKgAFFAcIAgAAAA==.',['晨光']='晨光:BAABKgAFFH8MAAIRAAYIkxemGACYAQARAAYIkxemGACYAQAAAA==.',['暗夜']='暗夜风行者:BAAAKgAECgUICwAAAA==.',['暗影']='暗影之邪:BAAAKgADCggICAAAAA==.',['暗里']='暗里着迷:BAABKgAECn8XAAITAAgIOBwiDgAxAgATAAgIOBwiDgAxAgABKgAFFAgIBQASAKwgAA==.',['最爱']='最爱榴莲味:BAAAKgAECgMIAwAAAA==.',['月之']='月之翎:BAAAKgAECggICAAAAA==.',['月似']='月似故人:BAAAKgADCggICAAAAA==.',['月儿']='月儿湾湾:BAAAKgAFFAQIBAAAAA==.',['朝朝']='朝朝暮暮:BAAAKgAECgcIBwAAAA==.',['未来']='未来福音:BAAAKgAECggICAAAAA==.',['术术']='术术来喽:BAAAKgAECgQIBAAAAA==.',['杀气']='杀气十足:BAABKgAFFH8FAAIfAAUIGBTUAgBcAQAfAAUIGBTUAgBcAQAAAA==.杀气的骑士:BAAAKgAECggICQAAAA==.',['来日']='来日方长:BAABKgAFFH8IAAIRAAQItxVSSADdAAARAAQItxVSSADdAAAAAA==.',['松永']='松永里愛:BAAAKgAFFAEIAQAAAA==.',['枼月']='枼月紗蘭:BAAAKgAECgEIAQAAAA==.',['柔月']='柔月怜怜:BAAAKgAECgEIAQAAAA==.',['柴咲']='柴咲明里:BAAAKgADCggICAAAAA==.',['核电']='核电皮卡丘:BAAAKgAFFAMIAwAAAA==.',['梅勒']='梅勒芙:BAABKgAFFH8IAAMOAAYIlRVwCwBwAQAOAAYIlRVwCwBwAQAPAAII/AjkIABkAAAAAA==.',['检修']='检修师:BAAAKgAECgMIAwAAAA==.',['樱牧']='樱牧华稻:BAAAKgAFFAYIAgAAAA==.',['欧洲']='欧洲小熊猫:BAABKgAFFH8QAAMBAAgIgBOqBQD5AQABAAgIgBOqBQD5AQAhAAQICRfcCADnAAAAAA==.',['欧阳']='欧阳菲兒:BAAAKgAFFAQIAgAAAA==.欧阳震华:BAAAKgAECgcIEgAAAA==.欧阳霏兒:BAAAKgAECgMIAgAAAA==.',['欧陽']='欧陽陽:BAAAKgAFFAEIAQAAAA==.',['歐阳']='歐阳菲儿:BAAAKgAECggICAAAAA==.',['歐陽']='歐陽菲儿:BAABKgAFFH8GAAIXAAYIWxMUFABkAQAXAAYIWxMUFABkAQAAAA==.歐陽震华:BAAAKgAECgIIAwAAAA==.歐陽震華:BAAAKgAECgIIBAAAAA==.',['武小']='武小优:BAAAKgAECgQIBAAAAA==.',['武見']='武見妙:BAAAKgAECggICAAAAA==.',['歧途']='歧途悲歌:BAACKgAFFH8MAAMaAAMI3iJSBQAiAQAaAAMI3iJSBQAiAQAbAAEIewI7IgA1AAAqAAQKfywAAhoACAj6I+ECAL0CABoACAj6I+ECAL0CAAAA.',['水晶']='水晶鼕瓜茶:BAAAKgAECgMIBAAAAA==.',['永夜']='永夜丶無解:BAABKgAFFH8GAAINAAYIpRkiAgDUAQANAAYIpRkiAgDUAQAAAA==.永夜之歌:BAAAKgADCgUIBQAAAA==.',['沙莎']='沙莎莎沙:BAAAKgAECggICAAAAA==.',['没眼']='没眼看:BAAAKgADCggICAAAAA==.',['泰莉']='泰莉萨:BAAAKgAECgMIAwAAAA==.',['泰难']='泰难德:BAAAKgADCgMIAwAAAA==.',['浅墨']='浅墨冰蓝:BAAAKgAECgcIBQAAAA==.浅墨幽兰:BAAAKgAECgcIDAAAAA==.',['清水']='清水依依:BAAAKgAECggIDQAAAA==.',['渣渣']='渣渣牧:BAAAKgADCgcIBwAAAA==.',['温柔']='温柔风暴:BAAAKgAECgcIEAAAAA==.',['渴望']='渴望长高:BAABKgAECn8WAAIhAAgI7xhMHQDeAQAhAAgI7xhMHQDeAQAAAA==.',['溪北']='溪北:BAAAKgADCgEIAQAAAA==.',['溶月']='溶月淡风:BAAAKgADCgYIBgAAAA==.',['满满']='满满:BAAAKgAECgYIBgABKgAFFAIIAgAgAAAAAA==.',['潘朵']='潘朵拉之心:BAAAKgAECgYIBgAAAA==.',['火鸡']='火鸡味锅八:BAAAKgAECggICAAAAA==.',['灭世']='灭世者钢蛋:BAAAKgADCgUIBQAAAA==.',['炽末']='炽末荼迷:BAABKgAFFH8KAAIBAAMIMB1aIAD4AAABAAMIMB1aIAD4AAAAAA==.',['炽舞']='炽舞之翼:BAAAKgAFFAIIAwAAAA==.',['热烈']='热烈的温:BAAAKgAECggICAAAAA==.',['無法']='無法無天:BAAAKgAECggICAAAAA==.',['熊猫']='熊猫子:BAAAKgAFFAIIAwAAAA==.',['熔火']='熔火大帝:BAAAKgAECggICAAAAA==.',['爱在']='爱在芯馒头:BAAAKgAECgMIAwAAAA==.',['爱情']='爱情小坦克:BAABKgAFFH8IAAINAAQIRiEgCwAdAQANAAQIRiEgCwAdAQAAAA==.',['版本']='版本之子:BAABKgAFFH8HAAIRAAMI4Ag6XwCyAAARAAMI4Ag6XwCyAAAAAA==.',['牛郎']='牛郎:BAAAKgADCgUIBQAAAA==.',['牛里']='牛里牛气:BAABKgAECn8XAAISAAYIfhCdLgDmAAASAAYIfhCdLgDmAAAAAA==.',['特洛']='特洛伊悍马:BAAAKgAECgIIAgABKgAECggIEAAgAAAAAA==.',['狂乱']='狂乱中年母鸡:BAAAKgAECggIDwAAAA==.',['狂暴']='狂暴的鱼哥:BAAAKgADCgYIBgAAAA==.',['狂舞']='狂舞夜色:BAABKgAFFH8IAAIXAAgIbROBBwAZAgAXAAgIbROBBwAZAgAAAA==.狂舞天涯:BAAAKgAECgMIAwAAAA==.',['狗狗']='狗狗:BAAAKgADCgEIAQAAAA==.',['猎萌']='猎萌新:BAAAKgAECgMIBgAAAA==.',['猪母']='猪母狼马蜂:BAAAKgADCgEIAgAAAA==.',['猫不']='猫不易:BAABKgAFFH8IAAIMAAgIRA4UBgDRAQAMAAgIRA4UBgDRAQAAAA==.',['猫猫']='猫猫九:BAAAKgAECggICAAAAA==.',['玉珑']='玉珑大师:BAAAKgADCgUIBQAAAA==.',['现甪']='现甪:BAAAKgAECgMIAwAAAA==.',['珊蒂']='珊蒂丝:BAAAKgAECggICQAAAA==.',['琪児']='琪児丶酱:BAAAKgADCgIIAgAAAA==.',['生生']='生生:BAAAKgAECgYIBgABKgAFFAIIAgAgAAAAAA==.',['用亮']='用亮光闪瞎你:BAAAKgAECgQIBAAAAA==.',['甩狙']='甩狙枪枪爆头:BAABKgAECn8WAAIWAAgIFxshHAAaAgAWAAgIFxshHAAaAgAAAA==.',['矮子']='矮子不打铁:BAAAKgAFFAEIAQAAAA==.',['石小']='石小川:BAAAKgAECgEIAQAAAA==.',['破晓']='破晓苍炎:BAAAKgADCgEIAQAAAA==.',['神圣']='神圣月光:BAAAKgADCgMIBAAAAA==.神圣的伪君子:BAAAKgAECggIDQAAAA==.',['神是']='神是谁说:BAABKgAECn8mAAIMAAgIXxW+KgCAAQAMAAgIXxW+KgCAAQAAAA==.',['神里']='神里绫华:BAACKgAFFH8GAAIHAAMI1AavMgCYAAAHAAMI1AavMgCYAAAqAAQKfxQAAgcACAhcFZArAKoBAAcACAhcFZArAKoBAAAA.神里绫华的狗:BAABKgAECn8WAAINAAgI8gzCRQA0AQANAAgI8gzCRQA0AQAAAA==.',['空气']='空气中密蔓:BAAAKgAECgQIBAAAAA==.空气中弥漫:BAACKgAFFH8xAAIOAAUIohzgCQA5AQAOAAUIohzgCQA5AQAqAAQKfyQAAg4ACAhtGJIfAPABAA4ACAhtGJIfAPABAAAA.空气中米慢:BAAAKgAECgIIAgAAAA==.空气中迷漫:BAAAKgADCgEIAQAAAA==.',['窝力']='窝力睾:BAAAKgAECggICAAAAA==.',['站桩']='站桩输出:BAAAKgADCggICAAAAA==.',['竹影']='竹影清瞳:BAAAKgAFFAIIAgAAAA==.',['笑嘻']='笑嘻嘻:BAAAKgAECggIDQAAAA==.',['等不']='等不到天亮:BAACKgAFFH8QAAIIAAMISiHFCwAOAQAIAAMISiHFCwAOAQAqAAQKf1MABAgACAheJogBABADAAgACAheJogBABADAAcAAggdHEZAAFUAAAQAAgieD7GeADIAAAAA.',['紫丶']='紫丶薇:BAAAKgAECggIEQAAAA==.',['紫雨']='紫雨泠烟:BAAAKgAECgYIBgAAAA==.',['繁华']='繁华落尽時丨:BAABKgAFFH8GAAIRAAYIVQ7WFgA2AQARAAYIVQ7WFgA2AQAAAA==.',['繁花']='繁花落尽時丨:BAABKgAFFH8FAAILAAUIlghtCgANAQALAAUIlghtCgANAQAAAA==.',['红鸳']='红鸳:BAAAKgAECgYIBgAAAA==.',['纳兰']='纳兰若曦:BAABKgAECn8UAAIiAAYIZwoqMQCvAAAiAAYIZwoqMQCvAAAAAA==.',['终白']='终白:BAAAKgADCgEIAQAAAA==.',['绚烂']='绚烂的烟花:BAAAKgAFFAMIAwAAAA==.',['绛红']='绛红:BAABKgAFFH8GAAILAAYICwYZCQBHAQALAAYICwYZCQBHAQAAAA==.',['绝地']='绝地天通:BAAAKgADCggIAwAAAA==.',['绝对']='绝对领袖:BAAAKgAECgUICwAAAA==.',['维爾']='维爾彼厄斯:BAAAKgADCgEIAQAAAA==.',['绿豆']='绿豆芽:BAABKgAECn9JAAIDAAgItSUIBgDyAgADAAgItSUIBgDyAgABKgAFFAYIBgADAOkUAA==.',['缪雪']='缪雪:BAACKgAFFH8fAAMGAAQIgiIoHwAmAQAGAAQIgiIoHwAmAQAFAAQIew/qIQCYAAAqAAQKfysAAwYACAgTJKAOAKwCAAYACAgTJKAOAKwCACMAAwiQER0oAH8AAAEqAAUUCAgFAAUA+BMA.',['缺个']='缺个小德:BAAAKgAECgQICAAAAA==.',['罗汉']='罗汉:BAAAKgAECgEIAQAAAA==.',['羽月']='羽月第一法吊:BAAAKgADCggICAAAAA==.',['羽林']='羽林龙卫:BAAAKgADCgUIBQAAAA==.',['翡翠']='翡翠夜:BAABKgAFFH8GAAIOAAYI3xMRDQBTAQAOAAYI3xMRDQBTAQAAAA==.',['老油']='老油条子:BAABKgAECn8kAAIKAAgIjRzlBwA7AgAKAAgIjRzlBwA7AgAAAA==.',['胸毛']='胸毛妹妹:BAAAKgAECgMIAwAAAA==.',['脆脆']='脆脆鲨:BAAAKgADCggICAAAAA==.',['舞蹈']='舞蹈老师:BAAAKgADCggICAAAAA==.',['艾尔']='艾尔:BAABKgAFFH8GAAISAAYIKwLQHACTAAASAAYIKwLQHACTAAAAAA==.',['艾德']='艾德鲁夜十九:BAAAKgAECgYIBgAAAA==.',['艾戈']='艾戈文:BAABKgAFFH8GAAIIAAYIsQoKBgA+AQAIAAYIsQoKBgA+AQAAAA==.',['艾瑞']='艾瑞莉亚:BAAAKgAECgMIBAAAAA==.',['花与']='花与艾丽丝:BAABKgAECn8WAAMVAAgINiGcCwB1AgAVAAgIGyCcCwB1AgAMAAgIxxeqKACqAQAAAA==.',['芳澤']='芳澤霞:BAAAKgAECggICAAAAA==.',['苏苏']='苏苏:BAAAKgAECgMIAwAAAA==.',['英雄']='英雄器杜安:BAABKgAECn8nAAIiAAgIoh6UCABWAgAiAAgIoh6UCABWAgABKgAFFAgIBQASAKwgAA==.',['荀彧']='荀彧:BAAAKgAECgMIAwAAAA==.',['莉琳']='莉琳德拉:BAAAKgAECgMIAwAAAA==.',['莎莎']='莎莎沙沙:BAAAKgAECggIBgAAAA==.',['莫里']='莫里亚蒂:BAAAKgADCgEIAQAAAA==.',['落樱']='落樱神锤:BAAAKgAECgMIAwAAAA==.',['落霞']='落霞孤鹜齐飞:BAAAKgAFFAIIBAAAAA==.',['葬月']='葬月幽然:BAAAKgAECgYIBgAAAA==.',['蓝胖']='蓝胖子牛蹄子:BAABKgAECn8cAAIBAAgIGxl5JQDsAQABAAgIGxl5JQDsAQAAAA==.',['蛋疼']='蛋疼的信仰:BAAAKgAECgIIAgAAAA==.',['蜜儿']='蜜儿:BAAAKgAECgIIAgAAAA==.',['蜜拉']='蜜拉底儿:BAAAKgAFFAcIAQAAAA==.蜜拉馨儿:BAAAKgAECgMIBAAAAA==.',['行千']='行千里致广大:BAAAKgAFFAIIAwAAAA==.',['衣之']='衣之哀伤:BAAAKgAECgQIBgAAAA==.衣之暗舞:BAAAKgAECgUIBwAAAA==.',['言不']='言不语:BAAAKgAECgYIDQAAAA==.',['誓羽']='誓羽:BAAAKgAECggIDQAAAA==.',['诗允']='诗允:BAAAKgADCgMIAwAAAA==.',['诗景']='诗景:BAAAKgAECgYIBgAAAA==.',['诸神']='诸神之城:BAABKgAECn81AAMTAAgIfhpzEwDxAQATAAgIORlzEwDxAQANAAgIyBUOPwCtAQAAAA==.诸神之猪:BAABKgAECn8ZAAIHAAgIfBxVFgA/AgAHAAgIfBxVFgA/AgAAAA==.诸神之边:BAAAKgADCgQIBAAAAA==.',['豆豆']='豆豆逗你玩:BAAAKgAFFAQIBAAAAA==.',['豌豆']='豌豆芽:BAABKgAECn9DAAIDAAgIIyXsBwDkAgADAAgIIyXsBwDkAgABKgAFFAYIBgADAOkUAA==.',['财神']='财神到:BAAAKgAECgcIBwAAAA==.',['赫波']='赫波:BAABKgAFFH8KAAMXAAYI0xVMFABiAQAXAAYIzRVMFABiAQAbAAQIphSKDQDJAAAAAA==.',['走来']='走来走去:BAABKgAFFH8QAAMGAAYIyhxjEwB/AQAGAAYIqRhjEwB/AQAFAAYIhBZaDQBBAQABKgAECggIJwAVAI4fAA==.',['越变']='越变越好看:BAAAKgADCgIIAgAAAA==.',['踏风']='踏风武僧:BAAAKgAECgUIBgAAAA==.',['达利']='达利园:BAAAKgAFFAgIBAAAAA==.',['逍遥']='逍遥无涯:BAABKgAECn8fAAMZAAgIWBhxLwDHAQAZAAgIWBhxLwDHAQAfAAgI8QxeKgA5AQAAAA==.',['速趴']='速趴塞牙疙瘩:BAABKgAFFH8MAAIOAAgIyRUZBAD/AQAOAAgIyRUZBAD/AQAAAA==.',['遇见']='遇见八月:BAABKgAECn8nAAIFAAgIExQpIACMAQAFAAgIExQpIACMAQABKgAFFAgIBQASAKwgAA==.',['遛鸟']='遛鸟高手:BAAAKgAECgYIBgAAAA==.',['那些']='那些年已老:BAAAKgADCggICAAAAA==.',['重修']='重修:BAAAKgADCgcICQAAAA==.',['钱前']='钱前乾:BAAAKgAECggIEQAAAA==.',['铗勊']='铗勊:BAAAKgAECgQIBAAAAA==.',['长沙']='长沙杠精:BAAAKgAECgcIDgAAAA==.',['閃電']='閃電:BAABKgAECn8UAAIjAAgIIBweCwD9AQAjAAgIIBweCwD9AQAAAA==.',['阿尔']='阿尔克丽娅:BAAAKgAFFAQIAQAAAA==.阿尔克莉娅:BAAAKgAFFAEIAQAAAA==.',['阿拉']='阿拉什斯特拉:BAAAKgADCgIIAgAAAA==.',['阿瓦']='阿瓦达啃大瓜:BAABKgAFFH9HAAQIAAgI1B9OAgD6AQAEAAgIgxe3AwBqAgAHAAgI8hm9BABgAgAIAAcI8xpOAgD6AQAAAA==.',['隔壁']='隔壁佬王:BAABKgAECn8UAAMWAAgIwRohHQATAgAWAAgIwRohHQATAgAQAAQI/RmohQDJAAABKgAFFAgIBQASAKwgAA==.',['雪源']='雪源血乂:BAAAKgADCggICAAAAA==.',['霜冷']='霜冷:BAAAKgAECgcIDAAAAA==.',['霸月']='霸月魅魂:BAAAKgAECggIDgAAAA==.',['霸柳']='霸柳染颜秀青:BAAAKgAECgcIDAAAAA==.',['霸道']='霸道小学生:BAAAKgAECggICAAAAA==.',['青鸳']='青鸳:BAAAKgAFFAIIAgAAAA==.',['非诚']='非诚勿绕:BAAAKgADCggICAAAAA==.',['鞭长']='鞭长莫急:BAAAKgADCggICQAAAA==.',['顾北']='顾北辰:BAABKgAECn8VAAQfAAgI6ReGHgC/AQAfAAcI/hmGHgC/AQAZAAQI8wmXewB2AAAiAAIIyQqDPwBDAAAAAA==.',['风吹']='风吹佩兰:BAAAKgADCggICAAAAA==.',['风火']='风火雷萨:BAAAKgADCgUICAAAAA==.',['风雪']='风雪从风:BAABKgAECn8XAAMZAAgIzyInHgAkAgAZAAcIYx4nHgAkAgAfAAgIcB02GADxAQABKgAFFAgICwAZAI4YAA==.风雪满天:BAAAKgADCgMIAwAAAA==.',['飞翔']='飞翔的酸菜鱼:BAAAKgAECgIIBAAAAA==.',['飞行']='飞行阿瓜:BAAAKgAECgcIEgAAAA==.',['香菇']='香菇炖鸡煲:BAABKgAFFH8KAAIRAAYIMRf/HQB6AQARAAYIMRf/HQB6AQAAAA==.',['香葱']='香葱蛋炒饭:BAAAKgAFFAQIBAAAAA==.',['马达']='马达马达:BAABKgAFFH8GAAIXAAIIshGLPQB4AAAXAAIIshGLPQB4AAABKgAFFAMIEAAIAEohAA==.',['马里']='马里奥格策:BAAAKgADCgUIBQAAAA==.',['骑蜗']='骑蜗牛上天:BAABKgAECn8nAAIRAAgIiiOMHACmAgARAAgIiiOMHACmAgAAAA==.',['鬼见']='鬼见愁:BAAAKgAECgMIAwAAAA==.',['魂刃']='魂刃之殇:BAABKgAFFH8RAAIGAAYIVB5SCwDYAQAGAAYIVB5SCwDYAQAAAA==.',['魅影']='魅影修罗:BAABKgAFFH8GAAIFAAYITQfcGQDTAAAFAAYITQfcGQDTAAAAAA==.',['魔源']='魔源之心:BAAAKgADCgIIAgAAAA==.',['鲍罗']='鲍罗粉:BAAAKgAECgIIAgAAAA==.',['鲜血']='鲜血大祭司:BAABKgAFFH8OAAQMAAYIQSJEDQBRAQAMAAUIZSBEDQBRAQAVAAQIOyX4DABGAQACAAMIXCDnDgAVAQAAAA==.',['麦芽']='麦芽:BAAAKgAFFAgIBAAAAA==.',['黄风']='黄风大圣:BAAAKgAECgIIAgAAAA==.',['黑豹']='黑豹:BAABKgAFFH8IAAIDAAgIygmzCwDJAQADAAgIygmzCwDJAQAAAA==.',['黯淡']='黯淡辉光:BAABKgAFFH8IAAILAAgIVQtbBwAAAgALAAgIVQtbBwAAAgAAAA==.',['齐道']='齐道临:BAABKgAECn88AAIIAAgIoh5WCAAYAgAIAAgIoh5WCAAYAgAAAA==.',['龙晨']='龙晨燚:BAABKgAFFH8LAAMRAAMIZBH4UADOAAARAAMIZBH4UADOAAASAAMI5ALvEgBXAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end