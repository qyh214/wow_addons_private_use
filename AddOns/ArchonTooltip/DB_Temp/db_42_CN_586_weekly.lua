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
 local lookup = {'Monk-Mistweaver','Monk-Brewmaster','Hunter-Marksmanship','Paladin-Retribution','Paladin-Protection','Paladin-Holy','Evoker-Devastation','Druid-Balance','DeathKnight-Blood','DemonHunter-Havoc','Mage-Arcane','Rogue-Assassination','Rogue-Outlaw','Shaman-Enhancement','Shaman-Elemental','Shaman-Restoration','Hunter-BeastMastery','Priest-Holy','Priest-Shadow','Priest-Discipline','Warlock-Demonology','DemonHunter-Vengeance','Druid-Restoration','Warlock-Destruction','DeathKnight-Unholy','Unknown-Unknown','Warrior-Fury','Mage-Frost','Mage-Fire','Warlock-Affliction','Rogue-Subtlety','Monk-Windwalker','DeathKnight-Frost','Druid-Guardian','Evoker-Preservation','Evoker-Augmentation','Warrior-Protection','Warrior-Arms','Druid-Feral',}; local provider = {region='CN',realm='凯恩血蹄',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aayden:BAABKgAFFH8IAAMBAAQI5BHeEgDYAAABAAQI5BHeEgDYAAACAAQIyQS8CQBsAAAAAA==.',Al='Alxamuren:BAABKgAFFH8EAAIDAAQI1g/XDwDaAAADAAQI1g/XDwDaAAAAAA==.',An='Andonemore:BAAAKgAECgIIAgAAAA==.',Bb='Bbt:BAAAKgAECgYIBgAAAA==.',Bl='Blacksun:BAAAKgAECgQIBAAAAA==.',Br='Breakbeat:BAAAKgAFFAMIAwAAAA==.',Ch='Christao:BAAAKgAECgYIBgAAAA==.',Da='Darkjoy:BAAAKgAECggICAAAAA==.',Do='Doublebei:BAAAKgAECgEIAQAAAA==.',Es='Essie:BAAAKgADCggICAAAAA==.',Fi='Fireblade:BAACKgAFFH8MAAIEAAQIMyIcFQADAQAEAAQIMyIcFQADAQAqAAQKfxgAAgQACAgaJqQLAOsCAAQACAgaJqQLAOsCAAAA.',Fl='Flanbranford:BAABKgAFFH8PAAQFAAYItBiBCgBSAQAFAAYIYxaBCgBSAQAEAAMIrCL1OgABAQAGAAEIVBSlFABDAAAAAA==.Fliedmiles:BAABKgAECn9AAAIHAAgICBvZGADyAQAHAAgICBvZGADyAQAAAA==.',Ga='Galesaur:BAAAKgAFFAQIBAAAAA==.',Gr='Grand:BAAAKgAFFAEIAQAAAA==.',He='Hela:BAABKgAFFH8IAAIFAAgIHwIaCgDzAAAFAAgIHwIaCgDzAAAAAA==.Hephaestus:BAAAKgAECgYIEAAAAA==.',Im='Imakkx:BAAAKgADCgEIAQAAAA==.',Je='Jepenseatoi:BAABKgAFFH8JAAIIAAQIEQYHJQCSAAAIAAQIEQYHJQCSAAAAAA==.',Ka='Kangjinstar:BAAAKgADCggICAAAAA==.',Le='Levelone:BAAAKgADCggICAAAAA==.',Li='Lichjin:BAAAKgAFFAgIBAAAAA==.',Ma='Mayden:BAAAKgAFFAYIBAAAAA==.',Mi='Minke:BAAAKgAFFAEIAQAAAA==.',Mo='Mograine:BAABKgAFFH8IAAIJAAgIeghFDABPAQAJAAgIeghFDABPAQAAAA==.Monologuew:BAAAKgADCgIIAgAAAA==.',Mv='Mv:BAABKgAECn8cAAIKAAgIJyBgEACBAgAKAAgIJyBgEACBAgAAAA==.',Na='Narassin:BAAAKgADCgMIAQAAAA==.',No='Nomainstream:BAAAKgAFFAIIAgAAAA==.',Pa='Parado:BAABKgAFFH8KAAILAAgICBKrCADrAQALAAgICBKrCADrAQAAAA==.',Ra='Rach:BAABKgAFFH8GAAIEAAYIGRPcHACAAQAEAAYIGRPcHACAAQAAAA==.',Ro='Rogueedison:BAACKgAFFH8MAAIMAAMIpRMDDADjAAAMAAMIpRMDDADjAAAqAAQKfxUAAwwACAhSE/sXAM4BAAwACAhSE/sXAM4BAA0AAgjtCMkdAEEAAAAA.',Sa='Saoxingxing:BAACKgAFFH8ZAAMOAAQIxyLTBQAmAQAOAAMIIxzTBQAmAQAPAAMISiG8DgCwAAAqAAQKfyEABA4ACAjSIvcOAF8CAA4ACAipIfcOAF8CAA8ABQjPIIFDABcBABAAAQjqD8u5ADAAAAAA.',Th='Thermos:BAABKgAECn8VAAIRAAgIJR3NKwBEAgARAAgIJR3NKwBEAgAAAA==.',Wa='Warjin:BAABKgAFFH8IAAIRAAQI2ALJSwB4AAARAAQI2ALJSwB4AAAAAA==.',Wo='Wooblackhoof:BAAAKgADCggICAAAAA==.',Wt='Wtfly:BAAAKgAECgEIAQAAAA==.',Xa='Xayden:BAAAKgADCggICAAAAA==.',Ys='Yshadows:BAAAKgAECgEIAQAAAA==.',['一牛']='一牛骑士:BAAAKgAFFAQIBAAAAA==.',['一脚']='一脚爆蛋:BAACKgAFFH8dAAMSAAQIExX3DADRAAASAAQIExX3DADRAAATAAEIQAgjMQAzAAAqAAQKfyoABBIACAiVH08gAN0BABIABwhnIE8gAN0BABMABQjfCKpPAK4AABQAAghgHNthAJwAAAAA.',['一饼']='一饼:BAAAKgAECgMIAwAAAA==.',['丁丁']='丁丁猎:BAABKgAFFH8HAAMRAAYIehc9GAA5AQARAAYIaxE9GAA5AQADAAEIPyNpSQBaAAAAAA==.',['三千']='三千弥陀:BAAAKgAFFAQIAwAAAA==.',['三筒']='三筒:BAAAKgAECgMIAwAAAA==.',['不要']='不要惹:BAAAKgAECgUIBQAAAA==.',['与众']='与众不瞳:BAABKgAFFH8MAAIEAAYI0CObDQD4AQAEAAYI0CObDQD4AQAAAA==.',['丨影']='丨影子丨:BAAAKgAFFAMIAwABKgAFFAgINgAMAM0hAA==.',['丨梦']='丨梦灬初醒丨:BAACKgAFFH8QAAMTAAQIexCyEgDOAAATAAQIexCyEgDOAAASAAII9As5OQBbAAAqAAQKfx0AAxMACAj2Gq8WACYCABMACAj2Gq8WACYCABIABQg2FsZGAPcAAAEqAAUUCAgSABUAxBoA.',['丨灬']='丨灬天下:BAAAKgAFFAQIBAAAAA==.',['丨芃']='丨芃然欣动丨:BAAAKgAECgUICAAAAA==.',['中年']='中年老詹:BAABKgAFFH8GAAIDAAYIEhOKAQCgAQADAAYIEhOKAQCgAQAAAA==.',['中指']='中指朝天立:BAAAKgAECgEIAQAAAA==.',['丶杰']='丶杰杀:BAAAKgAECgIIAgAAAA==.',['丶柠']='丶柠檬茶:BAAAKgADCgcIBwAAAA==.',['丶纳']='丶纳兹:BAAAKgAECgcIBwAAAA==.',['丶黑']='丶黑角:BAAAKgADCgQIBAAAAA==.',['为你']='为你而来:BAABKgAECn8cAAMWAAgIdBATNAD4AAAKAAYIsQ9LXwApAQAWAAcInwwTNAD4AAAAAA==.',['九筒']='九筒:BAAAKgAECgMIAwAAAA==.',['九重']='九重:BAAAKgADCgQIBAAAAA==.',['乱时']='乱时光:BAABKgAFFH8IAAIMAAgIDg4CBwALAgAMAAgIDg4CBwALAgAAAA==.',['了布']='了布德:BAACKgAFFH8xAAMXAAcIHBmuDQA0AQAXAAcIHBmuDQA0AQAIAAQIvw3aPwCrAAAqAAQKfzkAAwgACAi1GkolACMCAAgACAi1GkolACMCABcACAgqHgoXAAwCAAAA.',['事了']='事了拂身去:BAAAKgAFFAQIBAAAAA==.',['二分']='二分之一柠檬:BAAAKgADCgEIAQAAAA==.',['二四']='二四零下铺:BAAAKgAECgIIAgAAAA==.',['云隐']='云隐雷霆:BAAAKgAECggIDAAAAA==.',['五皮']='五皮皮:BAABKgAFFH8HAAIWAAQIqAY4HAB0AAAWAAQIqAY4HAB0AAABKgAFFAgIEgAVAMQaAA==.',['五筒']='五筒:BAAAKgAECgcIBwAAAA==.',['亦云']='亦云:BAAAKgAECgMIAwAAAA==.',['伤别']='伤别离:BAAAKgAECgQIBAAAAA==.',['你还']='你还在等什么:BAAAKgAECgMIAwAAAA==.',['俊克']='俊克总总:BAABKgAFFH8NAAMXAAQIFwb9GwBoAAAXAAQIFwb9GwBoAAAIAAMIegTgVQBdAAAAAA==.',['信春']='信春哥得永生:BAAAKgADCgIIAgAAAA==.',['偶心']='偶心飞翔:BAAAKgAECgYIBgAAAA==.',['傲尘']='傲尘:BAAAKgAECggICwAAAA==.',['光影']='光影丶:BAAAKgAECgcIBwAAAA==.',['光明']='光明大师:BAAAKgAECggIEQAAAA==.',['光荣']='光荣崛起:BAAAKgADCggIDAAAAA==.光荣领唱者:BAAAKgADCgMIAwAAAA==.',['冰冰']='冰冰有火:BAACKgAFFH8bAAQGAAQIHhZqDQDaAAAGAAQIHhZqDQDaAAAEAAIIzAdofgBqAAAFAAIILgSnFQBTAAAqAAQKf4AABAYACAiNI+oDALQCAAYACAiNI+oDALQCAAQABwh8GVmeAFsBAAUAAghKFE9CAHUAAAAA.',['冲冲']='冲冲猫猫头:BAAAKgADCgEIAQAAAA==.',['冷色']='冷色的夏季:BAAAKgAECgEIAQAAAA==.',['减里']='减里维克斯:BAAAKgAECgQIBwAAAA==.',['凡尔']='凡尔赛玫瑰:BAAAKgAFFAEIAQAAAA==.',['凶悍']='凶悍的亮亮:BAAAKgAECgQIBAAAAA==.',['初南']='初南:BAAAKgAFFAYIAQABKgAFFAgIDQAEAOEYAA==.',['別打']='別打左臉:BAAAKgAECggICAAAAA==.',['剧终']='剧终丶点点:BAAAKgADCggICAAAAA==.',['功夫']='功夫熊猫:BAABKgAFFH8GAAIOAAMIVgjQCgC3AAAOAAMIVgjQCgC3AAAAAA==.',['动感']='动感迷踪拳:BAAAKgAECgUICAAAAA==.',['北方']='北方阿一:BAAAKgADCgUIAwAAAA==.',['卅卅']='卅卅:BAAAKgAFFAQIBAAAAA==.',['卓尔']='卓尔不群:BAAAKgAECgIIAgAAAA==.',['南风']='南风知我意:BAAAKgADCgIIAgAAAA==.',['原野']='原野的呼唤:BAACKgAFFH8WAAIIAAQIQBTYNQDFAAAIAAQIQBTYNQDFAAAqAAQKfzAAAggACAhRHngbAGQCAAgACAhRHngbAGQCAAAA.',['发芽']='发芽的坏笑:BAAAKgAECggICAAAAA==.',['变丨']='变丨熊:BAAAKgADCgEIAwAAAA==.',['口亨']='口亨:BAAAKgADCgQIBAAAAA==.',['古饵']='古饵丹丨远征:BAAAKgAFFAYIBAABKgAFFAgIBgAYAC4RAA==.',['可达']='可达鸭鸭:BAAAKgAECgYICwAAAA==.',['史蒂']='史蒂夫考:BAABKgAFFH8JAAIRAAMIEhClHQCwAAARAAMIEhClHQCwAAAAAA==.',['吙竺']='吙竺尾:BAAAKgADCgMIAwAAAA==.',['含泪']='含泪吹喇叭:BAAAKgAFFAQIBAAAAA==.',['吼米']='吼米:BAAAKgAECgYIAQABKgAECggIMAAEAJgiAA==.',['哀仇']='哀仇:BAAAKgAECgEIAgAAAA==.',['哦豁']='哦豁:BAAAKgAECgYIBgAAAA==.',['哪个']='哪个德:BAAAKgADCggICAAAAA==.',['嘉禾']='嘉禾:BAAAKgAECgcIBwAAAA==.',['圣殿']='圣殿丶流星:BAAAKgAECgMIAwAAAA==.',['塔格']='塔格奥:BAAAKgAECgUIBQAAAA==.',['壹怒']='壹怒为红颜:BAABKgAFFH8QAAMZAAYI/SEvCgDqAQAZAAYI/SEvCgDqAQAJAAII1xEFHQByAAAAAA==.',['壹箭']='壹箭傾心:BAAAKgADCgMIAwAAAA==.',['夏天']='夏天飞雪:BAAAKgAFFAQIBAAAAA==.',['大伯']='大伯:BAAAKgAECgIIAgAAAA==.',['大地']='大地忽悠你:BAAAKgAECggIEwAAAA==.',['大意']='大意了没闪:BAAAKgAECgEIAQAAAA==.',['大鸿']='大鸿牛:BAAAKgAECgUIBQAAAA==.',['天堂']='天堂的蓝调:BAABKgAECn8qAAIYAAgIVB3hDgA3AgAYAAgIVB3hDgA3AgAAAA==.',['天王']='天王盖地虎丨:BAAAKgAFFAcIAQABKgAFFAgIDwABAO4LAA==.',['天禄']='天禄貔貅:BAAAKgAECggIDgAAAA==.',['天青']='天青:BAAAKgAECgYIBgAAAA==.天青涩等艳遇:BAAAKgAECgMIAwAAAA==.',['天黑']='天黑心乱:BAABKgAECn8UAAMKAAcISiJ4IABCAgAKAAcISiJ4IABCAgAWAAEIAACdewAAAAAAAA==.天黑心慌慌:BAAAKgAECgcICwAAAA==.',['奎尔']='奎尔萨莱斯:BAAAKgAECgEIAQAAAA==.',['奔放']='奔放的小番茄:BAAAKgAFFAQIBAAAAA==.',['奥淡']='奥淡淡变身:BAAAKgAECgEIAQAAAA==.',['女王']='女王范:BAAAKgAECgIIAgAAAA==.',['如法']='如法炮制:BAAAKgAECggICQAAAA==.',['妖魅']='妖魅众生:BAAAKgADCgQIBAAAAA==.',['妙想']='妙想技师多多:BAAAKgAECgYIBQAAAA==.',['妙蛙']='妙蛙种子:BAABKgAFFH8aAAIEAAgIFSI2AwC1AgAEAAgIFSI2AwC1AgAAAA==.',['妞妞']='妞妞:BAAAKgAECgIIAgAAAA==.',['姚璐']='姚璐璐:BAAAKgAECgUIBQAAAA==.',['姨妈']='姨妈喷发:BAAAKgADCggICAAAAA==.',['宇智']='宇智波卡卡西:BAABKgAFFH8IAAIRAAQIeBR9GgDpAAARAAQIeBR9GgDpAAAAAA==.',['安洁']='安洁妮:BAAAKgAECgIIAgAAAA==.',['宝宝']='宝宝很凶:BAAAKgADCggICAAAAA==.',['射出']='射出精彩:BAABKgAFFH8MAAMRAAQIiBvgJAD0AAARAAQIiBvgJAD0AAADAAQI/wYHPgCAAAABKgAFFAgIBAAaAAAAAA==.',['小哥']='小哥来也:BAABKgAFFH8LAAIbAAMI5AgbJgC2AAAbAAMI5AgbJgC2AAAAAA==.',['小泽']='小泽玛丽娅丶:BAAAKgAECgIIAgAAAA==.',['小王']='小王同志:BAAAKgAECgMIAwAAAA==.',['小紅']='小紅手:BAAAKgAECgYIBgAAAA==.',['小耳']='小耳闻浸画论:BAAAKgADCgUIBQAAAA==.',['小超']='小超锅一号:BAAAKgAFFAYIBAAAAA==.',['小阳']='小阳人:BAAAKgAECgIIAgAAAA==.',['尖牙']='尖牙銳爪丶:BAABKgAECn8VAAMIAAgI1RqGNwDbAQAIAAgI1RqGNwDbAQAXAAgIDBaSIgC1AQABKgAFFAgIDQAXABcGAA==.',['就是']='就是小哥:BAAAKgAECgMIBgAAAA==.',['就问']='就问能不能躺:BAABKgAECn8eAAMRAAgIPyCVGABuAgARAAgIPyCVGABuAgADAAYI/hV0OgBAAQAAAA==.',['尸情']='尸情化疫:BAAAKgADCgcIBwAAAA==.',['尼酱']='尼酱的乖宝宝:BAABKgAFFH8jAAIXAAYIIQ9qDQA3AQAXAAYIIQ9qDQA3AQAAAA==.',['希尔']='希尔瓦娜思:BAAAKgAFFAQIBAAAAA==.',['帝保']='帝保罗:BAAAKgAECggIEgAAAA==.',['带鸟']='带鸟追人:BAAAKgAFFAYIBAAAAA==.',['幻舞']='幻舞妖姬:BAAAKgADCggICAAAAA==.',['幽灵']='幽灵隐者:BAACKgAFFH8IAAIcAAQIkg6wEQCaAAAcAAQIkg6wEQCaAAAqAAQKfx4AAxwACAiaF/0lAOkBABwACAiaF/0lAOkBAB0AAQjVBN+mACIAAAAA.',['弑神']='弑神灬冷:BAAAKgAFFAQIBAAAAA==.',['弥离']='弥离:BAACKgAFFH8QAAQeAAYIARveAgByAQAeAAYI8xfeAgByAQAYAAYIgg7mGAA9AQAVAAQIphTfBQDZAAAqAAQKfxUAAhgACAhnGcotALwBABgACAhnGcotALwBAAAA.',['彪悍']='彪悍的亮亮:BAAAKgAECggIEgAAAA==.',['彭哥']='彭哥哥好帅:BAABKgAFFH8tAAMSAAYIbBggCQCSAQASAAYIbBggCQCSAQAUAAIImAZUIQB1AAAAAA==.',['影曦']='影曦:BAAAKgAECgQIBAAAAA==.',['影熙']='影熙:BAAAKgAFFAEIAQAAAA==.',['德莱']='德莱不是德鲁:BAABKgAFFH8NAAIQAAMIlBn3JQDfAAAQAAMIlBn3JQDfAAAAAA==.',['心灵']='心灵潜行:BAACKgAFFH8PAAMfAAMIQR3vAwDTAAAfAAMIxxTvAwDTAAAMAAIIGR39HQC7AAAqAAQKfyQAAwwACAjdFKwVAOcBAAwACAjdFKwVAOcBAB8ABAhgEHIqAKAAAAAA.',['念念']='念念不忘:BAAAKgADCggICQAAAA==.',['怒怒']='怒怒的蛋蛋:BAABKgAECn8aAAIWAAgIiw86KQA5AQAWAAgIiw86KQA5AQAAAA==.',['怪盗']='怪盗安度因丶:BAABKgAFFH8OAAMUAAYIdRikBwAeAQASAAYIdA/xDQBJAQAUAAQISSGkBwAeAQAAAA==.',['恶妇']='恶妇:BAAAKgAECgEIAQAAAA==.',['恶魔']='恶魔之撃:BAAAKgAECgUIEAAAAA==.',['悍客']='悍客:BAAAKgAECgIIAgAAAA==.',['悲泣']='悲泣挽歌:BAAAKgAFFAIIAgAAAA==.',['惆怅']='惆怅的小妹:BAABKgAFFH8GAAIFAAYIGgreEwDbAAAFAAYIGgreEwDbAAAAAA==.惆怅的疯狂:BAABKgAFFH8GAAMdAAYIUA8hFgACAQAdAAUIoAwhFgACAQALAAEIDhpKQgBKAAAAAA==.',['愤怒']='愤怒的牛牛:BAAAKgADCgEIAQAAAA==.',['懦夫']='懦夫救星丶:BAAAKgAECgYIBgAAAA==.',['我们']='我们宽恕众生:BAAAKgADCgMIAwAAAA==.',['我只']='我只做小三:BAAAKgAECgUIBwAAAA==.',['我是']='我是奶龙:BAABKgAFFH8OAAIZAAYIiCLaDADDAQAZAAYIiCLaDADDAQAAAA==.我是牛吗:BAABKgAECn8uAAMIAAgIMxWZQACmAQAIAAgIMxWZQACmAQAXAAgIDQxZOgD+AAAAAA==.我是盼盼:BAAAKgAFFAQIBAABKgAFFAgICAAQAO0XAA==.',['我觉']='我觉得可行:BAAAKgAFFAYIAgAAAA==.我觉得很行:BAAAKgAECggIBgAAAA==.我觉得还行:BAABKgAFFH8GAAMBAAQIuxu7GQCvAAABAAMIZCC7GQCvAAAgAAEIZACRIwAqAAAAAA==.',['战斗']='战斗王开转:BAAAKgADCggICAAAAA==.',['戢翊']='戢翊峥:BAABKgAFFH8IAAIbAAgItwLXCgBzAQAbAAgItwLXCgBzAQAAAA==.',['戦灬']='戦灬小万:BAAAKgAECggICAAAAA==.戦灬月眸:BAAAKgAECgMIAwAAAA==.',['戴尔']='戴尔李斯阿卡:BAAAKgAECgIIAgAAAA==.戴尔菲娜:BAAAKgADCgQIBAAAAA==.',['打老']='打老虎的淇淇:BAABKgAFFH8MAAIRAAYIgRhyEQBsAQARAAYIgRhyEQBsAQAAAA==.',['托尼']='托尼老师:BAAAKgADCggICAAAAA==.',['扶正']='扶正鞭上坐:BAABKgAFFH8IAAMYAAYIUhS2FgBNAQAYAAYINBO2FgBNAQAeAAIISQ1xFQCRAAABKgAFFAgIBAAaAAAAAA==.',['拉克']='拉克西丝:BAAAKgADCgUIBQAAAA==.',['捌佰']='捌佰鲍夜:BAABKgAFFH8IAAIYAAgI+BedAwBaAgAYAAgI+BedAwBaAgAAAA==.',['捌级']='捌级大狂风:BAABKgAFFH8YAAIEAAQIFSCANgARAQAEAAQIFSCANgARAQAAAA==.',['搅厶']='搅厶棍:BAABKgAFFH8OAAMDAAgIpRloBQAPAgADAAgI/hRoBQAPAgARAAYIXxeKDwCAAQAAAA==.',['敖闰']='敖闰:BAAAKgAFFAQIBAABKgAFFAgIHAALAPgfAA==.',['文艺']='文艺青年:BAAAKgADCggICAAAAA==.',['新手']='新手新:BAAAKgADCggIEAAAAA==.',['方向']='方向:BAAAKgADCgEIAQAAAA==.',['无多']='无多洗哈:BAAAKgADCgIIAgAAAA==.',['无尽']='无尽的苍穹:BAABKgAECn8aAAMcAAgIIiRtFQBUAgAcAAgIIiRtFQBUAgALAAMIYRaVXQDMAAAAAA==.',['无情']='无情哈拉少:BAAAKgADCgEIAQAAAA==.',['昊风']='昊风:BAAAKgAECgYIBgAAAA==.',['星辰']='星辰之戀:BAAAKgADCgYIBgAAAA==.',['是美']='是美雅哦:BAABKgAFFH8UAAIYAAYIqiLaBQBIAQAYAAYIqiLaBQBIAQAAAA==.是美雅啊:BAABKgAFFH8WAAIEAAYILCauAQDVAQAEAAYILCauAQDVAQABKgAFFAgICgAEAK0lAA==.',['是薯']='是薯片呀丶:BAABKgAFFH8GAAIEAAYI6wmAKQBBAQAEAAYI6wmAKQBBAQAAAA==.',['晴天']='晴天漠漠:BAAAKgAECgQIBgAAAA==.',['暮雨']='暮雨丶轻风:BAAAKgAECgEIAQAAAA==.',['月光']='月光下的清雨:BAAAKgAECgYIBgAAAA==.',['月石']='月石在生气:BAAAKgAECgUIBQAAAA==.',['月落']='月落衫间:BAABKgAFFH8GAAIXAAYIGBaZCgBdAQAXAAYIGBaZCgBdAQAAAA==.',['李珞']='李珞宁:BAAAKgAFFAYIBAAAAA==.',['林雷']='林雷之梦:BAACKgAFFH8QAAMEAAMI2wyHLQCwAAAEAAMI2wyHLQCwAAAGAAIInQgrEgBqAAAqAAQKfxgABAQACAiPFIOMADQBAAQACAgxE4OMADQBAAYABAiKEtUyAM8AAAUABAhuCV1IAG0AAAAA.',['枫叶']='枫叶烙痕:BAABKgAECn8WAAIhAAcIShpJDwCgAQAhAAcIShpJDwCgAQAAAA==.枫叶红了:BAABKgAECn8gAAIRAAgIYBtSKwACAgARAAgIYBtSKwACAgAAAA==.',['梦回']='梦回珞珈:BAAAKgAFFAQIBAAAAA==.',['梧攸']='梧攸:BAAAKgAFFAQIBAAAAA==.',['橘子']='橘子丶:BAACKgAFFH8SAAMBAAgIGxbzAgCeAQABAAgIGxbzAgCeAQACAAQIugJBBwBvAAAqAAQKfxcAAwEABwgIF4RHACABAAEABgiMFYRHACABACAABwgrD2c6AO8AAAAA.',['欧阳']='欧阳岚:BAAAKgAECgYIBgAAAA==.',['正国']='正国佬:BAAAKgAECgYIBwAAAA==.',['死在']='死在天真里:BAACKgAFFH8GAAMDAAQICByNBwAKAQADAAQICByNBwAKAQARAAIIDQ/pTwBsAAAqAAQKfxYAAxEABggkFnSLABgBABEABghVFHSLABgBAAMAAwhDGPGAAHsAAAAA.',['气质']='气质丶:BAAAKgAECggIEgABKgAECggIGgAWAIsPAA==.',['氣質']='氣質丶:BAAAKgAFFAUIAQAAAA==.',['水樱']='水樱宮葵:BAABKgAFFH8GAAMTAAYIaQ70HgCRAAATAAMI8hD0HgCRAAASAAMIGRfgFgCMAAAAAA==.',['沫沫']='沫沫忧咔:BAABKgAFFH8IAAIKAAgIrgWnDACMAQAKAAgIrgWnDACMAQAAAA==.',['法克']='法克:BAAAKgAECgYICAAAAA==.',['波风']='波风皆人:BAABKgAFFH8MAAIMAAgIyxMkAACtAgAMAAgIyxMkAACtAgAAAA==.',['泥艾']='泥艾希我奶妈:BAAAKgAECgIIAgAAAA==.',['泰一']='泰一迪:BAACKgAFFH8RAAIRAAMIJx6JDwAPAQARAAMIJx6JDwAPAQAqAAQKfx0AAhEACAh/IZUnAFUCABEACAh/IZUnAFUCAAAA.',['泰二']='泰二迪:BAABKgAFFH8FAAIKAAQIFA9tMwCyAAAKAAQIFA9tMwCyAAAAAA==.',['泰蕾']='泰蕾莎:BAAAKgAECggICgAAAA==.',['流风']='流风若雪:BAABKgAFFH8SAAQSAAYIBh9bDwA5AQASAAUIiR5bDwA5AQAUAAQICxfxCgD+AAATAAEINQ7CKwBEAAAAAA==.',['海卖']='海卖斯的腿毛:BAABKgAFFH8IAAMiAAIIsAglDQBIAAAIAAIIhQhhUQBxAAAiAAII1gUlDQBIAAAAAA==.',['淞餮']='淞餮:BAAAKgAECgcICQAAAA==.',['深藏']='深藏功与名:BAABKgAFFH8MAAMXAAgIMRLsBgClAQAXAAcIRxTsBgClAQAIAAUI0Q0vHQDKAAAAAA==.',['深邃']='深邃海蓝:BAAAKgAECgYIBgAAAA==.',['淼淼']='淼淼脆皮肠:BAACKgAFFH8MAAIYAAYI4xR4FgBQAQAYAAYI4xR4FgBQAQAqAAQKfxsAAhgACAjtJE8DAOcCABgACAjtJE8DAOcCAAEqAAUUCAgZABgACyMA.',['灡泠']='灡泠:BAAAKgAECggICwAAAA==.',['火影']='火影摇摆龙王:BAABKgAFFH8xAAIbAAQIbRopGQDzAAAbAAQIbRopGQDzAAAAAA==.',['火焰']='火焰:BAAAKgAECgYIBgAAAA==.',['灬醉']='灬醉明月灬:BAAAKgAECgMIAwAAAA==.',['灵魂']='灵魂祷言:BAAAKgAECgEIAQAAAA==.灵魂附体:BAAAKgAECgYIBgAAAA==.',['炫爱']='炫爱教练:BAAAKgAFFAIIAgAAAA==.',['炮灰']='炮灰向前冲:BAACKgAFFH8HAAIZAAMI1A2COgCzAAAZAAMI1A2COgCzAAAqAAQKfy0AAhkACAhyGwAsAAYCABkACAhyGwAsAAYCAAAA.',['烂木']='烂木头:BAABKgAFFH8NAAQeAAMIywY0GwBoAAAYAAMIogUtKABtAAAeAAIIHgg0GwBoAAAVAAEI7QvKLgA9AAAAAA==.',['烤串']='烤串达人:BAABKgAFFH8GAAIdAAYI6gzREAA+AQAdAAYI6gzREAA+AQAAAA==.',['焰之']='焰之曙光:BAABKgAFFH8KAAIEAAQIChe0KQDLAAAEAAQIChe0KQDLAAAAAA==.',['牛奶']='牛奶:BAABKgAFFH8FAAIQAAII5Aj2KwBtAAAQAAII5Aj2KwBtAAAAAA==.牛奶丶:BAAAKgAFFAQIBAAAAA==.',['牛战']='牛战:BAAAKgAFFAIIAgAAAA==.',['牛术']='牛术:BAAAKgADCgMIAwAAAA==.',['牛牛']='牛牛增幅器:BAACKgAFFH8XAAMHAAYIDxqiFQAeAQAHAAYIDxqiFQAeAQAjAAEIMQOpCwAsAAAqAAQKfyoABAcACAgUIhYKAI4CAAcACAgUIhYKAI4CACQAAQigHIYPAEsAACMAAQirCAAhACoAAAAA.',['牛猎']='牛猎:BAAAKgADCgcIBwAAAA==.',['牢記']='牢記血海仇:BAABKgAFFH8JAAMJAAgIewzUFwDiAAAJAAYIWgnUFwDiAAAhAAIITxRuDQCiAAAAAA==.',['狂想']='狂想镇魂曲:BAAAKgAFFAQIBAAAAA==.',['狂暴']='狂暴宥宥:BAACKgAFFH8LAAMZAAMI2huIJwDwAAAZAAMI2huIJwDwAAAhAAEIWwRlEgAvAAAqAAQKfx0AAhkACAgpHwYiAAcCABkACAgpHwYiAAcCAAAA.',['狐丑']='狐丑抱橘花:BAAAKgAFFAgIAQAAAA==.',['狐小']='狐小妖:BAAAKgADCgEIAQAAAA==.',['独狼']='独狼:BAAAKgAFFAQIBAAAAA==.独狼狼:BAAAKgADCgQIBwAAAA==.',['猛牛']='猛牛冲钅:BAAAKgADCgcIDAAAAA==.',['猫脸']='猫脸雷公嘴丶:BAABKgAFFH8FAAIBAAUIhhW0CQCQAQABAAUIhhW0CQCQAQAAAA==.',['玛莎']='玛莎喇蒂:BAABKgAECn8ZAAMGAAgIwA/cHgBpAQAGAAgIwA/cHgBpAQAEAAQI+QgdOQF0AAAAAA==.',['生前']='生前是天使:BAABKgAECn8VAAIYAAgICRKxKQB2AQAYAAgICRKxKQB2AQABKgAFFAgICAAYAPUYAA==.',['疾跑']='疾跑哥布林:BAACKgAFFH8PAAIhAAMIuBaoCADgAAAhAAMIuBaoCADgAAAqAAQKfy0AAiEACAhoIUMEAJ8CACEACAhoIUMEAJ8CAAAA.',['癌丘']='癌丘:BAAAKgAECgUICQAAAA==.',['白雪']='白雪老师:BAAAKgAECgEIAQAAAA==.',['看我']='看我变變变:BAAAKgAECgYICgAAAA==.',['真电']='真电游王:BAAAKgAECgMIBgAAAA==.',['矩阵']='矩阵:BAAAKgAECggIDAAAAA==.',['破碎']='破碎小柠:BAAAKgAECgEIAQAAAA==.破碎残阳的影:BAAAKgADCgMIBAAAAA==.破碎空灵:BAAAKgAECgYIDQAAAA==.',['神农']='神农鼎:BAAAKgAFFAYIAwABKgAFFAgIBgALAKwVAA==.',['神秘']='神秘人:BAAAKgAECgIIAgAAAA==.',['秋天']='秋天卫士:BAABKgAFFH8VAAQYAAMIfCOVDQD1AAAYAAMILRmVDQD1AAAVAAEIoCahEABhAAAeAAEIPSQ/HABhAAAAAA==.',['秋翎']='秋翎煜:BAAAKgAFFAIIAgAAAA==.',['秦始']='秦始皇:BAABKgAECn8UAAIbAAcIFg+gOABAAQAbAAcIFg+gOABAAQAAAA==.',['空白']='空白格丶:BAAAKgADCgEIAQAAAA==.',['红山']='红山哥布林:BAAAKgAFFAMICgAAAA==.',['红烧']='红烧蹄子:BAAAKgAFFAEIAQAAAA==.',['纯爱']='纯爱扭头人:BAAAKgAFFAYIBAABKgAFFAgIDwAXAJ4TAA==.',['纯綷']='纯綷:BAAAKgAECgYICAAAAA==.',['纯纯']='纯纯小虎牙:BAAAKgADCgEIAQAAAA==.',['美得']='美得太明显:BAAAKgAECgQIBAAAAA==.',['翔傲']='翔傲天:BAAAKgAECgEIAQAAAA==.',['翘边']='翘边模子:BAAAKgADCggIFAAAAA==.',['老一']='老一点的卜:BAAAKgAFFAYIBAAAAA==.',['老卜']='老卜:BAAAKgAFFAYIAgAAAA==.',['老子']='老子就是胖娃:BAABKgAFFH8GAAIDAAYIZwqaGgAYAQADAAYIZwqaGgAYAQAAAA==.',['老板']='老板凳丶:BAAAKgAECgQIBAAAAA==.',['老虎']='老虎不是虎:BAABKgAFFH8GAAMSAAYIRheZFQAIAQASAAUITRWZFQAIAQATAAEIxA1TKwBFAAAAAA==.',['耂胡']='耂胡豆豆:BAAAKgAFFAIIAwAAAA==.',['聖光']='聖光將熄:BAABKgAFFH8FAAIEAAUIwxp3hABUAAAEAAUIwxp3hABUAAAAAA==.',['聖柒']='聖柒柒:BAAAKgADCgMIAwAAAA==.',['肥宅']='肥宅丶:BAAAKgADCggICAAAAA==.',['自来']='自来火:BAABKgAFFH8mAAIYAAYIyxLCEwBoAQAYAAYIyxLCEwBoAQAAAA==.',['自然']='自然丨随风:BAAAKgAECgQIBAAAAA==.',['自由']='自由镇的狂魔:BAAAKgAECgEIAQAAAA==.',['至尊']='至尊邪魔王:BAABKgAFFH8FAAIKAAMIYwSYIwB5AAAKAAMIYwSYIwB5AAAAAA==.至尊魔王:BAACKgAFFH8MAAIiAAMIWwe1CgBoAAAiAAMIWwe1CgBoAAAqAAQKfx4AAiIACAh/FL0UAGUBACIACAh/FL0UAGUBAAAA.',['至高']='至高图腾:BAAAKgAECgYICQAAAA==.',['色子']='色子:BAAAKgAECgEIAQAAAA==.',['艾拉']='艾拉蓓徳:BAAAKgAECggICAAAAA==.',['花好']='花好月圆:BAAAKgADCgQIBAAAAA==.',['花辞']='花辞树:BAAAKgADCgIIAgAAAA==.',['草莓']='草莓丶圣代:BAABKgAFFH8HAAINAAQI4SD/AQD4AAANAAQI4SD/AQD4AAABKgAFFAgINgANAHolAA==.',['菊花']='菊花真汉子:BAACKgAFFH8bAAIIAAYIGx8VDgC4AQAIAAYIGx8VDgC4AQAqAAQKfyMAAggACAhZJVkTAJQCAAgACAhZJVkTAJQCAAAA.',['萌小']='萌小白:BAAAKgADCggICAAAAA==.',['萨厼']='萨厼:BAAAKgAECggIEgABKgAFFAgIGgASAEgZAA==.',['萨飞']='萨飞罗斯:BAAAKgADCgQIBAAAAA==.',['萨髵']='萨髵:BAAAKgAECgYIBwAAAA==.',['萬年']='萬年:BAAAKgAECgEIAQAAAA==.',['落雪']='落雪无尘:BAAAKgAECgQIBAAAAA==.',['葬剑']='葬剑为红颜:BAAAKgAECgYICQAAAA==.',['藻井']='藻井:BAABKgAFFH8GAAIQAAYI3BJ4DwBdAQAQAAYI3BJ4DwBdAQAAAA==.',['虎虎']='虎虎牌小饼干:BAABKgAFFH8GAAIlAAMIwQjdBgChAAAlAAMIwQjdBgChAAAAAA==.',['蛋蛋']='蛋蛋菊花香:BAAAKgADCgEIAQAAAA==.',['蜡筆']='蜡筆小旧:BAABKgAFFH8nAAMIAAQIISaCGQBNAQAIAAQIISaCGQBNAQAXAAQImhmCGwDGAAAAAA==.',['血之']='血之追猎者:BAABKgAFFH8JAAIRAAQIkRX0IQDQAAARAAQIkRX0IQDQAAAAAA==.',['西来']='西来:BAAAKgAECgUICgAAAA==.',['要猛']='要猛灬:BAAAKgAECgQIBgAAAA==.',['解树']='解树:BAAAKgAECgEIAQAAAA==.',['让我']='让我来摸:BAABKgAFFH8uAAIQAAYIZRqMDACCAQAQAAYIZRqMDACCAQAAAA==.',['贝克']='贝克汉牛:BAAAKgAECgMIAwAAAA==.',['贤德']='贤德淡藤:BAABKgAFFH8LAAMdAAYIoRivCQBdAQAdAAYI1ROvCQBdAQALAAQIFB/SJADPAAAAAA==.',['超级']='超级大洋芋:BAACKgAFFH8IAAIbAAQIHApwHgCbAAAbAAQIHApwHgCbAAAqAAQKfzQAAhsACAgdHUEHAFACABsACAgdHUEHAFACAAAA.超级奶爸:BAAAKgAECgUIBQAAAA==.超级至尊魔王:BAABKgAFFH8GAAILAAMIBwOYIQB2AAALAAMIBwOYIQB2AAAAAA==.',['路卡']='路卡利欧:BAACKgAFFH9VAAMhAAgIkyU/AADlAgAhAAgIeCU/AADlAgAZAAYIsiUyAgDJAQAqAAQKfyIAAxkACAixJv8GAOMCABkACAiXJv8GAOMCACEAAQioJpYtAGsAAAAA.',['辰妹']='辰妹:BAABKgAFFH8JAAIIAAgIdxyNBACGAgAIAAgIdxyNBACGAgAAAA==.',['逍遥']='逍遥扇:BAABKgAFFH8GAAIHAAQIrxmrEADPAAAHAAQIrxmrEADPAAAAAA==.逍遥老狼:BAAAKgAECgMIAwAAAA==.逍遥鱼:BAAAKgAECgYIBgAAAA==.',['那时']='那时的疯狂:BAAAKgAFFAIIAgAAAA==.',['那時']='那時的瘋狂:BAAAKgAECgUICwAAAA==.',['那边']='那边是地:BAAAKgAECgYIBgAAAA==.',['邪恶']='邪恶男爵:BAABKgAECn8iAAIcAAgIBBUaDAC8AQAcAAgIBBUaDAC8AQAAAA==.',['邱淑']='邱淑贞:BAAAKgAECgEIAQAAAA==.',['野蛮']='野蛮拖拽:BAAAKgAECgUIBQAAAA==.',['钵阑']='钵阑街砍霸子:BAABKgAFFH8IAAImAAgIJQ46BAAGAgAmAAgIJQ46BAAGAgAAAA==.',['错季']='错季花開:BAAAKgAECggICAAAAA==.',['镜阳']='镜阳:BAAAKgADCggICAAAAA==.',['长肉']='长肉就变帅:BAAAKgAFFAYIBAAAAA==.',['闪伯']='闪伯利恒之星:BAABKgAECn8VAAINAAgIowGEIAAoAAANAAgIowGEIAAoAAAAAA==.',['防不']='防不胜防:BAABKgAECn8tAAMnAAgIJyB7AgBsAgAnAAgIJyB7AgBsAgAIAAQIcA/igADVAAAAAA==.',['阿兰']='阿兰蒂恩:BAAAKgAFFAIIAwAAAA==.',['阿勀']='阿勀里斯:BAABKgAECn8UAAMhAAgIWQ3KFQA8AQAhAAcIEA7KFQA8AQAJAAQI/wnBSwCNAAAAAA==.',['阿狄']='阿狄娜:BAAAKgAFFAIIAgAAAA==.',['阿米']='阿米陀赋:BAABKgAFFH8PAAMDAAgIxCH3AwBRAgADAAgIqyD3AwBRAgARAAYI2BtDEQBuAQAAAA==.',['陆路']='陆路通:BAAAKgAFFAEIAQAAAA==.',['降龙']='降龙伏虎:BAAAKgADCgIIAgAAAA==.',['限量']='限量版私房钱:BAAAKgAECgMIAwAAAA==.',['雅少']='雅少:BAABKgAECn8UAAIEAAgIdA37jQAxAQAEAAgIdA37jQAxAQAAAA==.',['雨慢']='雨慢落:BAAAKgAFFAEIAQAAAA==.',['雪之']='雪之下雪乃:BAAAKgAECgcIDQAAAA==.',['雪月']='雪月色:BAAAKgADCgEIAQAAAA==.',['雲翔']='雲翔龙法丶壹:BAABKgAFFH8GAAILAAYIPB0qCwC4AQALAAYIPB0qCwC4AQAAAA==.',['霁月']='霁月清风:BAAAKgAECggIEQAAAA==.',['靈魟']='靈魟:BAAAKgADCgEIAQAAAA==.',['青铜']='青铜脆皮姬:BAAAKgAECggIEAAAAA==.',['靓盗']='靓盗云云:BAAAKgAECgMICAAAAA==.',['静看']='静看花开花落:BAAAKgAFFAgIAQAAAA==.',['非洲']='非洲熊一:BAAAKgADCgEIAQAAAA==.',['风暴']='风暴丨烈酒:BAAAKgAECgYICQAAAA==.',['风铃']='风铃的叹息:BAAAKgADCggICAAAAA==.',['飞尨']='飞尨在天:BAAAKgAECgYICQAAAA==.',['飞羽']='飞羽无痕:BAAAKgAECggIDAAAAA==.',['飞舞']='飞舞的刀刃:BAAAKgAECgMIAwAAAA==.',['骑同']='骑同伟:BAAAKgAECgYIAQAAAA==.',['魔力']='魔力熊猫:BAAAKgAFFAYIBAAAAA==.',['魔法']='魔法批风:BAAAKgAECgUIBQAAAA==.',['魔狼']='魔狼兽战:BAAAKgAECgYICQAAAA==.',['鲜血']='鲜血玛丽:BAACKgAFFH8YAAMJAAYIoSXmAwAcAgAJAAYIoSXmAwAcAgAhAAQIWBKUAwDeAAAqAAQKfxwAAyEACAgtGsgLAOQBACEABwiFHcgLAOQBAAkAAQgbBnRrAB8AAAEqAAUUCAgaABkATCEA.',['鸟人']='鸟人的未来:BAAAKgAECgYIBwAAAA==.',['鸡公']='鸡公加蛋:BAAAKgAFFAQIBAABKgAFFAcICwAeADYVAA==.鸡公狂躁:BAAAKgAFFAIIAgAAAA==.',['鸡肉']='鸡肉味嘎嘣脆:BAAAKgAECgQIBAAAAA==.',['麦希']='麦希子龙:BAAAKgAECgYIDgAAAA==.',['黄桃']='黄桃蛋挞:BAAAKgAFFAIIAgAAAA==.',['黄棒']='黄棒丶:BAABKgAECn8XAAIKAAgIBhIINwB6AQAKAAgIBhIINwB6AQAAAA==.',['默旭']='默旭魂丶雨:BAAAKgAECgMIAwAAAA==.',['黯月']='黯月帕拉图:BAACKgAFFH8SAAIEAAMIoRlfQQDtAAAEAAMIoRlfQQDtAAAqAAQKfxYAAgQACAhdHcI6ABUCAAQACAhdHcI6ABUCAAAA.',['龍媽']='龍媽:BAAAKgADCggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end