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
 local lookup = {'Paladin-Retribution','Druid-Restoration','Druid-Balance','Hunter-BeastMastery','Hunter-Survival','Evoker-Preservation','Evoker-Devastation','Evoker-Augmentation','DeathKnight-Frost','DemonHunter-Vengeance','DemonHunter-Havoc','Shaman-Elemental','Shaman-Restoration','Warrior-Fury','Mage-Arcane','Monk-Mistweaver','Monk-Windwalker','Hunter-Marksmanship','Rogue-Subtlety','Rogue-Assassination','Rogue-Outlaw','Priest-Holy','DeathKnight-Blood','Warlock-Destruction','Warlock-Affliction','Warlock-Demonology','Priest-Shadow','Mage-Frost','Paladin-Holy','Warrior-Protection','Priest-Discipline','Paladin-Protection','Druid-Feral','Unknown-Unknown','DeathKnight-Unholy',}; local provider = {region='CN',realm='蓝龙军团',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ad='Addiction:BAABLAAFFH89AAIBAAYI/yWjBgAdAgABAAYI/yWjBgAdAgAAAA==.',Al='Aldrich:BAAALAAECgYICgAAAA==.',As='Ascot:BAABLAAFFH8eAAMCAAYIDRzpDADrAQACAAYIDRzpDADrAQADAAEIMAgeNwA4AAAAAA==.',Be='Berogue:BAAALAAFFAIIBAAAAA==.',Br='Brat:BAABLAAFFH8JAAMEAAIItBrkRACfAAAEAAIItBrkRACfAAAFAAII9g8sBQCXAAAAAA==.Brunhilde:BAAALAAECggICAAAAA==.',Ce='Cenariusy:BAABLAAFFH8GAAMCAAIIHw7WRQBjAAACAAIIHw7WRQBjAAADAAIIrAgMNwA4AAAAAA==.',Ch='Cherrysteel:BAABLAAFFH8IAAIEAAII4BqSVwCRAAAEAAII4BqSVwCRAAAAAA==.',Co='Corrine:BAAALAAFFAIIBAAAAA==.',Cr='Cream:BAAALAAECgIIAgAAAA==.',Da='Dad:BAABLAAFFH8PAAQGAAMIIhyuCgAAAQAGAAMIIhyuCgAAAQAHAAIInALvIABnAAAIAAEIzAGyDAA1AAAAAA==.',Do='Doxa:BAAALAADCgUIBgAAAA==.',Dr='Dragonleague:BAABLAAFFH82AAIJAAYI5CRGEAANAgAJAAYI5CRGEAANAgAAAA==.',Fi='Fionasit:BAABLAAFFH8GAAMKAAIITgkTFwBZAAALAAIIRgRYYQBkAAAKAAIITgkTFwBZAAAAAA==.',Is='Isherlock:BAAALAADCgYIBgAAAA==.',Js='Jssy:BAABLAAECn8UAAILAAYIHg8TwQBXAQALAAYIHg8TwQBXAQAAAA==.',Li='Lika:BAAALAAECgUIBQAAAA==.',Lo='Longlongago:BAAALAAECgYICAAAAA==.',['Lä']='Läderach:BAAALAAECggIDwAAAA==.',Ma='Mamakoto:BAAALAAECggICAAAAA==.Marswill:BAAALAAECgYIDAAAAA==.Marswy:BAAALAAFFAIIAgAAAA==.',Mi='Milos:BAAALAAECgEIAQAAAA==.',Mo='Mom:BAAALAAFFAIIBAABLAAFFAMIDwAGACIcAA==.',No='Nobrains:BAABLAAFFH8fAAMMAAUIVB9rCwDJAQAMAAUIVB9rCwDJAQANAAQI2yNTDAB6AQABLAAFFAYIHgACAA0cAA==.',Od='Odd:BAAALAAECgEIAQAAAA==.',Pa='Panny:BAAALAAECgEIAQAAAA==.Pararon:BAABLAAFFH8FAAIEAAUIqQXyhABNAAAEAAUIqQXyhABNAAAAAA==.',Pl='Pleasure:BAAALAAECgEIAQAAAA==.',Se='Seraph:BAAALAAECgUIBQAAAA==.',Si='Sideanilafoi:BAAALAAECgYIDgAAAA==.',Sl='Slut:BAAALAAFFAIIAwAAAA==.',Sm='Smartmoon:BAAALAAECgYIDAAAAA==.',Su='Supersonic:BAAALAAECgcIBwAAAA==.',Zf='Zfocean:BAABLAAFFH8IAAIOAAIIEBX0OACVAAAOAAIIEBX0OACVAAAAAA==.',['一二']='一二零:BAABLAAECn8gAAINAAYIMRThTAAoAQANAAYIMRThTAAoAQAAAA==.',['一碰']='一碰就倒:BAAALAAFFAIIBAAAAA==.',['一肆']='一肆:BAAALAAECgYIBgAAAA==.',['七罪']='七罪魅灵:BAAALAAFFAIIAgAAAA==.',['七魄']='七魄归窍:BAAALAAFFAIIBAAAAA==.',['三碗']='三碗不过岗:BAACLAAFFH8JAAIJAAIIIxA5agCTAAAJAAIIIxA5agCTAAAsAAQKfyYAAgkABwikHRBwABYCAAkABwikHRBwABYCAAAA.',['下不']='下不来了:BAAALAAECgEIAQAAAA==.',['不能']='不能急了:BAABLAAFFH8GAAIKAAIIEg7EEwBkAAAKAAIIEg7EEwBkAAAAAA==.',['专业']='专业打团专员:BAAALAADCgEIAQAAAA==.',['临渊']='临渊怨:BAABLAAFFH8FAAIJAAIIzxsdQQCxAAAJAAIIzxsdQQCxAAAAAA==.',['丶小']='丶小馒头:BAAALAAECgYICgAAAA==.丶小馒頭:BAAALAAFFAIIAgAAAA==.',['丶隔']='丶隔壁老王:BAAALAAECgQIBwAAAA==.',['为什']='为什么要修改:BAAALAADCgEIAQAAAA==.',['乌帕']='乌帕:BAAALAADCgcIBwAAAA==.',['乌漆']='乌漆嘛黑:BAAALAAECgYIBgAAAA==.',['乔木']='乔木:BAAALAADCgUIBQAAAA==.',['乜精']='乜精钢:BAAALAAECgYICwAAAA==.',['九州']='九州之归尘:BAAALAAFFAIIAgAAAA==.',['二师']='二师兄:BAAALAAECgQIBgAAAA==.',['云绝']='云绝妙思:BAABLAAFFH8IAAIBAAIIIBYeXQBIAAABAAIIIBYeXQBIAAAAAA==.',['亚亚']='亚亚西:BAAALAADCgMIAwAAAA==.',['亲爱']='亲爱的宝贝:BAACLAAFFH8HAAIOAAUI2gs1KgAcAQAOAAUI2gs1KgAcAQAsAAQKfxUAAg4ABgj8F0g3AHwBAA4ABgj8F0g3AHwBAAAA.',['什么']='什么叫无敌:BAAALAAFFAIIBAAAAA==.',['今夜']='今夜月色很美:BAAALAAECgYIBgAAAA==.',['今生']='今生:BAABLAAFFH8FAAIPAAII8hCKWQCGAAAPAAII8hCKWQCGAAAAAA==.',['从未']='从未被超越:BAAALAADCggICAAAAA==.',['他朝']='他朝:BAAALAAECgYICAAAAA==.',['伊力']='伊力丹:BAAALAADCgYIBgAAAA==.',['会遗']='会遗憾吗:BAACLAAFFH8LAAIPAAMIIRLeRgCHAAAPAAMIIRLeRgCHAAAsAAQKfyIAAg8ACAi+Gk4aANYBAA8ACAi+Gk4aANYBAAAA.',['但丁']='但丁说灬:BAAALAAFFAIIBAAAAA==.',['佛跳']='佛跳墙:BAABLAAFFH8GAAMQAAYIWQzFDwDDAAAQAAQIwgXFDwDDAAARAAII2we7EgBtAAAAAA==.',['你姑']='你姑奶奶:BAAALAADCgIIAgAAAA==.',['你小']='你小姑:BAAALAADCgEIAQAAAA==.',['你配']='你配吗:BAAALAAECgIIAgAAAA==.',['依然']='依然六叁零:BAACLAAFFH8iAAMSAAYIBBIiDQAaAQAEAAYIWxHJOgBYAQASAAYI1wciDQAaAQAsAAQKfysAAwQACAgkIBEUAIYCAAQACAjfHxEUAIYCABIABwhdFZ0SACUBAAAA.',['倾星']='倾星河:BAABLAAFFH8FAAIPAAIIMBMjSgCWAAAPAAIIMBMjSgCWAAAAAA==.',['偌只']='偌只如初見:BAACLAAFFH8sAAQTAAYIxSHSAQBVAgATAAYIyB7SAQBVAgAUAAUI+CD7CACJAQAVAAEIJRSWBABOAAAsAAQKfx0ABBQACAiOI4MGABYDABQACAhkIoMGABYDABUAAggTIB0XALoAABMAAQjNDcNRAC0AAAAA.',['元始']='元始天尊:BAAALAADCggICQAAAA==.',['兆本']='兆本山:BAAALAAECgYIBwAAAA==.',['光头']='光头强爷爷:BAAALAAECgYIDAAAAA==.',['全体']='全体起立:BAAALAAFFAIIBAAAAA==.',['八四']='八四术:BAAALAAECgUIBQAAAA==.',['八月']='八月秋风:BAAALAAECgIIAgAAAA==.',['关芝']='关芝琳:BAACLAAFFH8rAAIBAAYIiyErCwDtAQABAAYIiyErCwDtAQAsAAQKfzAAAgEABgifJM4jAAkCAAEABgifJM4jAAkCAAEsAAUUBgguABYAghQA.',['冬幕']='冬幕节咭安娜:BAAALAAECgEIAQAAAA==.',['冰冻']='冰冻大西瓜:BAACLAAFFH8JAAMEAAIIARY6ZgCHAAAEAAIIARY6ZgCHAAASAAIIQQRNMABfAAAsAAQKfzMAAwQACAiaGsUkACYCAAQACAiaGsUkACYCABIABgj6Ced8AOUAAAAA.',['冲锋']='冲锋撞你腰子:BAAALAADCgIIAgAAAA==.',['凉风']='凉风有信:BAAALAAFFAEIAQAAAA==.',['凤凰']='凤凰棠:BAABLAAFFH8IAAIPAAMICgcXTQBYAAAPAAMICgcXTQBYAAAAAA==.',['利姆']='利姆露:BAAALAAECgMIAwAAAA==.',['刺痛']='刺痛的心:BAABLAAECn8eAAMJAAgIax1wVgBKAgAJAAgIax1wVgBKAgAXAAYIWRJDKQAzAQAAAA==.',['剑神']='剑神暴龙:BAAALAADCgYIBgAAAA==.',['功夫']='功夫樂樂:BAACLAAFFH8qAAMMAAYImB7vGwBhAQAMAAUI1x3vGwBhAQANAAEIeBYWdQBDAAAsAAQKfykAAw0ACAheHmUcAKYCAA0ACAheHmUcAKYCAAwABgi3H7IgAKsBAAEsAAUUBgguABYAghQA.',['努阿']='努阿达:BAAALAAECggIEAAAAA==.',['十三']='十三:BAAALAAECgYIBgAAAA==.',['千歌']='千歌:BAACLAAFFH8RAAIJAAUIWBhVIgAVAQAJAAUIWBhVIgAVAQAsAAQKfxYAAgkACAjUIb8uALcCAAkACAjUIb8uALcCAAAA.',['半刀']='半刀胖:BAAALAAECgYICAAAAA==.',['半生']='半生丶浮云:BAAALAAECgIIBAAAAA==.半生丶烟雨:BAAALAAECgYIBgAAAA==.',['卡希']='卡希乌斯:BAABLAAFFH8cAAMCAAYIbRflGgBWAQACAAUI9hTlGgBWAQADAAUIsQ51GQANAQAAAA==.',['却冬']='却冬:BAABLAAFFH8NAAIPAAUIshuGLwBLAQAPAAUIshuGLwBLAQABLAAFFAYIHQAEAIUhAA==.',['原味']='原味少女胖次:BAAALAAFFAEIAQAAAA==.',['双刀']='双刀恶魔:BAAALAADCgYIBgAAAA==.',['古丽']='古丽塞露塔:BAABLAAFFH8lAAIBAAYICxjoGQCKAQABAAYICxjoGQCKAQAAAA==.',['古力']='古力娜扎:BAACLAAFFH8VAAIJAAYISReQIwCnAQAJAAYISReQIwCnAQAsAAQKfy4AAgkABgiNI1ohAPQBAAkABgiNI1ohAPQBAAEsAAUUBgguABYAghQA.',['古叶']='古叶书:BAAALAADCgQIBAAAAA==.',['叮咚']='叮咚的猫:BAAALAAECgIIAgAAAA==.',['司空']='司空震:BAAALAAFFAIIAwAAAA==.',['吃有']='吃有文化的亏:BAAALAAECgYICgAAAA==.',['吃没']='吃没文化亏:BAAALAAECgEIAgAAAA==.吃没文化的亏:BAAALAAECgUICAAAAA==.',['名侦']='名侦探兔美:BAACLAAFFH89AAQYAAcI0hoxFADqAQAYAAcI0hoxFADqAQAZAAEI8hWVBgBZAAAaAAEIxAtTKwBMAAAsAAQKfzQABBgACAiTIJIfAM8CABgACAiTIJIfAM8CABoABQj2D4NYABUBABkAAgjYFhksAI0AAAAA.',['吧啦']='吧啦吧啦丶:BAAALAAECgEIAQAAAA==.',['听雨']='听雨看风:BAAALAAECgEIAQAAAA==.',['呜喵']='呜喵王啊:BAAALAADCgIIAgAAAA==.',['周末']='周末丶:BAAALAADCgEIAQAAAA==.',['呼啸']='呼啸而过:BAAALAAECgYIBwAAAA==.',['哥布']='哥布塔:BAAALAAECgQIBAAAAA==.',['喵手']='喵手回春:BAAALAAFFAEIAQAAAA==.',['嗷唔']='嗷唔派大星:BAAALAAECgYIBgAAAA==.',['団子']='団子:BAACLAAFFH89AAMQAAYIKBn3BgDMAQAQAAYIKBn3BgDMAQARAAYI6xsHBQC7AQAsAAQKf1YAAxAACAifIyACABUDABAACAifIyACABUDABEACAidHy8QAKYCAAAA.',['圆圆']='圆圆的大肚纸:BAAALAADCggICAAAAA==.',['土豆']='土豆毅:BAAALAAECgcIEAAAAA==.',['圣光']='圣光小女:BAAALAAECgYIBgAAAA==.圣光照我行:BAAALAAECgYICAAAAA==.圣光霹雳:BAAALAAECgUIBQAAAA==.',['地图']='地图鱼:BAAALAAFFAIIAwAAAA==.',['夜夜']='夜夜相思:BAAALAAECgYICgAAAA==.',['夜长']='夜长空:BAAALAAECgYIBwAAAA==.',['大头']='大头儿之怒:BAAALAAECgYIBgAAAA==.',['大姐']='大姐大:BAAALAAECgUIBQAAAA==.',['大将']='大将军胖虎:BAAALAAECgYIBgAAAA==.',['大明']='大明星王祖贤:BAACLAAFFH8oAAIOAAYIpxnwFwCiAQAOAAYIpxnwFwCiAQAsAAQKfx0AAg4ABgjBI9gzAGYCAA4ABgjBI9gzAGYCAAEsAAUUBgguABYAghQA.',['大眼']='大眼蛙:BAAALAAECgcIBwAAAA==.',['大罗']='大罗顾小桑:BAAALAAECgQIBAAAAA==.',['大领']='大领主殇冬:BAAALAADCggICAAAAA==.',['大高']='大高个:BAABLAAFFH8QAAIXAAMIkQVMFgBeAAAXAAMIkQVMFgBeAAAAAA==.大高個:BAAALAAFFAIIBAAAAA==.',['天下']='天下赎魂:BAAALAAFFAIIBAAAAA==.',['天使']='天使下了凡:BAABLAAECn8cAAIYAAYIXhZChAB3AQAYAAYIXhZChAB3AQAAAA==.',['天灵']='天灵灵土灵灵:BAABLAAFFH8IAAINAAIIbAe2YABfAAANAAIIbAe2YABfAAAAAA==.',['天狼']='天狼心:BAAALAADCgcIBwAAAA==.',['天祺']='天祺领主:BAAALAAFFAIIAgAAAA==.',['天空']='天空裂痕:BAAALAADCgEIAQAAAA==.',['奈克']='奈克赛斯:BAACLAAFFH88AAILAAYIYyCnEADcAQALAAYIYyCnEADcAQAsAAQKf1cAAwsACAiQI9gRACcDAAsACAiQI9gRACcDAAoAAQj1CccxACAAAAAA.',['奥术']='奥术奏鸣曲:BAAALAAECgQIBAAAAA==.',['女神']='女神邱淑贞:BAACLAAFFH8uAAMWAAYIghR4FQCpAQAWAAYIghR4FQCpAQAbAAUIJBK7EwA5AQAsAAQKfysAAxsABgg3H98WAJkBABsABgg3H98WAJkBABYABAgeCkKdAKcAAAAA.',['奶娘']='奶娘:BAABLAAECn8YAAICAAYIQh2rPgDlAQACAAYIQh2rPgDlAQAAAA==.',['妖娆']='妖娆帅老哥:BAABLAAFFH8GAAIcAAIIeQx5GgA7AAAcAAIIeQx5GgA7AAAAAA==.',['娃娃']='娃娃:BAAALAAFFAIIAgAAAA==.',['娜尔']='娜尔雅:BAAALAAECgEIAQAAAA==.',['守护']='守护者阿洛迪:BAABLAAFFH8WAAIWAAUIPxg9GwB2AQAWAAUIPxg9GwB2AQABLAAFFAgIRQAbAKEmAA==.',['安娜']='安娜贝丽:BAACLAAFFH8qAAIDAAUIaR7dEgBRAQADAAUIaR7dEgBRAQAsAAQKfysAAgMACAh0I3gIADYDAAMACAh0I3gIADYDAAAA.',['宗馥']='宗馥莉:BAAALAAFFAIIAwAAAA==.',['宝儿']='宝儿姐:BAABLAAFFH8JAAIUAAUIGBCLDABHAQAUAAUIGBCLDABHAQAAAA==.',['寒烟']='寒烟柔:BAAALAAECgIIAgAAAA==.',['射人']='射人先射鸡:BAAALAAECgYIEQAAAA==.',['射射']='射射更健康:BAAALAADCgIIAgAAAA==.',['小光']='小光:BAACLAAFFH8oAAMWAAYIYyb3AwCcAgAWAAYIYyb3AwCcAgAbAAEIvQF3MQAuAAAsAAQKfyMAAxYABwiSI/ETAMoCABYABwiSI/ETAMoCABsABgjTI3kNAAkCAAAA.小光光:BAACLAAFFH8gAAIGAAYIth6rBgAQAgAGAAYIth6rBgAQAgAsAAQKfxgAAgYABgiVJLMLAHQCAAYABgiVJLMLAHQCAAEsAAUUBggoABYAYyYA.',['小天']='小天后孙燕姿:BAACLAAFFH8tAAMDAAYInR/3CQDDAQADAAYInR/3CQDDAQACAAEIkhEHWQA/AAAsAAQKfy4AAgMABggCI4IfAGUCAAMABggCI4IfAGUCAAEsAAUUBgguABYAghQA.',['小小']='小小光:BAACLAAFFH8rAAMNAAYI7CB9BwBLAgANAAYI7CB9BwBLAgAMAAMIuwinOAB5AAAsAAQKfx0AAw0ABggYH9dMAPoBAA0ABggYH9dMAPoBAAwABgiRIWcaANgBAAEsAAUUBggoABYAYyYA.',['小布']='小布丁超可爱:BAAALAAFFAIIBAAAAA==.',['小悲']='小悲催:BAAALAAECgUIBQAAAA==.',['小李']='小李飞刀:BAABLAAECn8fAAIdAAYIQBN5QgBTAQAdAAYIQBN5QgBTAQAAAA==.',['小狗']='小狗快跑:BAABLAAFFH8GAAIBAAII/SLiTQBgAAABAAII/SLiTQBgAAAAAA==.',['小艾']='小艾芙:BAABLAAFFH8LAAIRAAIIIwuyGQA4AAARAAIIIwuyGQA4AAAAAA==.',['小蹄']='小蹄:BAAALAAECgYIBgAAAA==.',['小韶']='小韶涵:BAACLAAFFH8mAAMPAAYIvB4IHwCbAQAPAAYIRh4IHwCbAQAcAAIIzyBpDwBpAAAsAAQKfyoAAw8ABggIJbA7AFsCAA8ABgjGIrA7AFsCABwABgjhI+kxALEBAAEsAAUUBgguABYAghQA.',['少侠']='少侠莫慌:BAAALAAECgcIBwAAAA==.',['少帅']='少帅寇仲:BAABLAAFFH8GAAIcAAII/gkDHQA3AAAcAAII/gkDHQA3AAAAAA==.',['尼尼']='尼尼哥尼尼:BAAALAAECgMIAwAAAA==.',['屁屁']='屁屁猪:BAAALAADCgIIBAAAAA==.',['差不']='差不多裂人:BAAALAAFFAQIBAAAAA==.',['市川']='市川海老藏:BAABLAAECn8VAAIeAAYISxSOSABfAQAeAAYISxSOSABfAQAAAA==.',['帅的']='帅的不敢出门:BAAALAAECgYICwAAAA==.',['师斤']='师斤手:BAAALAAFFAIIBAAAAA==.',['希尔']='希尔娜娜斯:BAAALAAECgUIBQAAAA==.',['希格']='希格文:BAABLAAFFH8GAAIbAAQIFxDCDwAeAQAbAAQIFxDCDwAeAQAAAA==.',['开天']='开天精灵:BAABLAAFFH8GAAIEAAIINQwawgAdAAAEAAIINQwawgAdAAAAAA==.',['开心']='开心果果:BAAALAAFFAIIAgAAAA==.',['德国']='德国妮子:BAAALAAFFAIIAgAAAA==.',['德鲁']='德鲁零:BAABLAAFFH8IAAICAAIIDRZEKwCBAAACAAIIDRZEKwCBAAABLAAFFAYIHQAEAIUhAA==.',['心碎']='心碎了才懂:BAAALAAECgYIBgAAAA==.',['念念']='念念不忘:BAAALAAECgQIBwAAAA==.',['急行']='急行的猎豹:BAACLAAFFH8LAAMEAAIIPRRolwBCAAAEAAIIPRRolwBCAAASAAEITwUsOQAyAAAsAAQKfxwAAxIACAiDGwo/ALsBABIABwh1GQo/ALsBAAQABwifF/qdAK8BAAAA.',['悠悠']='悠悠残月:BAABLAAFFH8mAAIJAAYIAhxPHgC9AQAJAAYIAhxPHgC9AQAAAA==.',['感触']='感触:BAAALAAFFAIIAgAAAA==.感触生灵:BAAALAAFFAIIAgAAAA==.',['戀愛']='戀愛:BAACLAAFFH8NAAMWAAMIOwauNACVAAAWAAMI2AWuNACVAAAfAAEIIQbGBgA1AAAsAAQKfxkAAxYABwjUDdo1ABoBABYABwgLDdo1ABoBAB8AAwhABycwAG8AAAAA.',['戀蕊']='戀蕊:BAABLAAFFH8JAAINAAIIHwUIcQBJAAANAAIIHwUIcQBJAAAAAA==.',['戀魚']='戀魚:BAABLAAFFH8GAAIgAAII/QeHIwAjAAAgAAII/QeHIwAjAAAAAA==.',['成就']='成就一牧:BAAALAAECgYIDAAAAA==.成就一萨:BAAALAAECgYIDAAAAA==.成就一骑:BAABLAAECn8UAAIBAAYIxRixTwBvAQABAAYIxRixTwBvAQAAAA==.',['我为']='我为你着迷陈:BAAALAAECgUIBQAAAA==.',['我真']='我真的跑不动:BAACLAAFFH8NAAMaAAIILR91IwBYAAAaAAEIsB11IwBYAAAYAAEIqiCkXABCAAAsAAQKfxcAAxgACAi+Hh4/AD0CABgABwicHB4/AD0CABoABgghHPAoANEBAAEsAAUUBggdAAQAhSEA.',['戳泡']='戳泡泡龙:BAACLAAFFH8FAAIHAAIIGhQDGgCLAAAHAAIIGhQDGgCLAAAsAAQKfxUAAwcACAjhH60eACUCAAcABwj8IK0eACUCAAYAAgh8IL00ALYAAAAA.',['戴锁']='戴锁:BAAALAAFFAIIAwAAAA==.',['折翼']='折翼的圣光:BAAALAAFFAIIBAAAAA==.折翼的狐狸:BAAALAAFFAIIAgAAAA==.折翼的骑士:BAABLAAFFH8GAAIBAAIIZQc8ewA2AAABAAIIZQc8ewA2AAAAAA==.',['抹茶']='抹茶流心:BAAALAAECgcIBwAAAA==.',['拓跋']='拓跋砡儿:BAABLAAFFH8NAAIEAAUI1RK/TwAQAQAEAAUI1RK/TwAQAQABLAAFFAYIJgAJAAIcAA==.',['提莫']='提莫小队长:BAABLAAFFH8MAAIJAAUIrQvgRwAcAQAJAAUIrQvgRwAcAQAAAA==.',['无光']='无光之刃:BAAALAAFFAIIAwAAAA==.',['无尺']='无尺灬:BAAALAAECgYIBgAAAA==.',['无限']='无限的牛:BAAALAAECgYICAAAAA==.',['明俊']='明俊:BAAALAAECgYIBgAAAA==.',['星云']='星云:BAAALAAECggICAAAAA==.',['星冕']='星冕:BAAALAADCgMIAwAAAA==.',['星屑']='星屑旋转功:BAAALAAFFAIIAgAAAA==.',['星野']='星野梦夏树:BAACLAAFFH8iAAICAAUICSSbCgAIAgACAAUICSSbCgAIAgAsAAQKf0EAAwIABwgVIjMQAFkCAAIABgg1JTMQAFkCACEABwgIBqguABkBAAAA.',['暗戳']='暗戳戳:BAACLAAFFH8gAAILAAUIRxJOKQBKAQALAAUIRxJOKQBKAQAsAAQKfyQAAgsABgjyHRYpALcBAAsABgjyHRYpALcBAAAA.',['暮光']='暮光之咒:BAABLAAFFH8HAAIYAAIIHA9vWwBEAAAYAAIIHA9vWwBEAAAAAA==.',['月亮']='月亮花:BAABLAAFFH8GAAINAAII3QoEZABXAAANAAII3QoEZABXAAAAAA==.',['月夜']='月夜雪纷飞:BAABLAAFFH8LAAIYAAMIRg2fSwCMAAAYAAMIRg2fSwCMAAABLAAFFAYIJgAJAAIcAA==.',['月色']='月色真美:BAAALAAFFAIIAwAAAA==.',['木桥']='木桥:BAAALAADCgYIBgAAAA==.',['木瓜']='木瓜:BAAALAADCggICAAAAA==.',['李恭']='李恭梓:BAAALAAECgYIBgAAAA==.',['李旺']='李旺财:BAAALAAECggICAABLAAFFAgIAgAiAAAAAA==.',['杰斯']='杰斯塞索:BAAALAAFFAIIBAAAAA==.',['杰杰']='杰杰:BAAALAAECgEIAQAAAA==.',['极光']='极光:BAAALAADCgUIBQAAAA==.极光掠夺天边:BAAALAAFFAIIAwAAAA==.',['林青']='林青霞:BAACLAAFFH8aAAIYAAYIgxU1IwCPAQAYAAYIgxU1IwCPAQAsAAQKfxUAAhgABghoH/0kAMoBABgABghoH/0kAMoBAAEsAAUUBgguABYAghQA.',['枣枣']='枣枣:BAAALAAECgYIBgAAAA==.',['枫小']='枫小雨:BAABLAAFFH8SAAMMAAYIhBi9DgCVAQAMAAUI5Ra9DgCVAQANAAEI8xMieAA8AAAAAA==.',['柏恩']='柏恩泽:BAABLAAFFH8FAAIYAAUI+wiiQADwAAAYAAUI+wiiQADwAAAAAA==.',['柳清']='柳清婉:BAABLAAFFH8UAAIUAAIInBwYGABWAAAUAAIInBwYGABWAAABLAAFFAYILgAWAIIUAA==.',['桂言']='桂言葉:BAAALAAFFAIIBAAAAA==.',['梦之']='梦之炫恋:BAAALAAECgYIBgAAAA==.',['梦幻']='梦幻泡影:BAAALAAECgIIAgAAAA==.',['梦月']='梦月影:BAAALAAFFAUIBAAAAA==.',['橙花']='橙花生:BAABLAAFFH8IAAIDAAYI7AMwLgBGAAADAAYI7AMwLgBGAAAAAA==.',['止夏']='止夏忧伤:BAAALAADCgEIAQAAAA==.',['死骑']='死骑:BAAALAAECgYIBgAAAA==.',['残血']='残血:BAAALAAECgMIAwAAAA==.',['水调']='水调歌头:BAABLAAFFH8GAAIQAAYICQsLCwBZAQAQAAYICQsLCwBZAQAAAA==.',['氷鎖']='氷鎖:BAAALAAFFAIIBAAAAA==.',['永不']='永不缺席:BAAALAAECgcICQAAAA==.',['永胤']='永胤:BAACLAAFFH8NAAIEAAMIHBqmJwDeAAAEAAMIHBqmJwDeAAAsAAQKfzYAAgQACAhbJJ4UAA0DAAQACAhbJJ4UAA0DAAAA.',['沈大']='沈大勇:BAAALAAECgMIBAAAAA==.',['沐月']='沐月:BAAALAAECgQIBAAAAA==.',['沖修']='沖修斗:BAAALAAFFAIIAgAAAA==.',['沫上']='沫上流光丶:BAAALAAECggICwAAAA==.',['泡泡']='泡泡二号:BAAALAAFFAIIAgAAAA==.',['波雅']='波雅丶汉库克:BAABLAAFFH8GAAIEAAMIhBQ+bgCGAAAEAAMIhBQ+bgCGAAAAAA==.',['洛苏']='洛苏颖:BAACLAAFFH8GAAIaAAYIzw+LAgBzAQAaAAYIzw+LAgBzAQAsAAQKfyAAAhoACAgIH4IOAI8CABoACAgIH4IOAI8CAAAA.',['流浪']='流浪青春:BAABLAAFFH8LAAIWAAUIXQNZKADuAAAWAAUIXQNZKADuAAAAAA==.',['浪荡']='浪荡天涯:BAAALAAECgYIEQAAAA==.',['浴血']='浴血丶舞:BAAALAADCgEIAQAAAA==.',['消失']='消失的上勾拳:BAAALAAECgQIBAAAAA==.',['渴望']='渴望偷条野猪:BAAALAAFFAEIAQAAAA==.',['游荡']='游荡的艾琳:BAAALAADCgEIAQAAAA==.',['湛蓝']='湛蓝玫瑰:BAAALAAFFAIIBAAAAA==.',['漂漂']='漂漂:BAAALAAECgcIEwAAAA==.',['火柴']='火柴头:BAAALAAECgQIBQAAAA==.',['火焰']='火焰小蛋糕:BAAALAAECgYIDgAAAA==.',['灵宝']='灵宝天尊:BAAALAAECgYIEgAAAA==.',['炎爆']='炎爆羊肉拌面:BAAALAAECgMIAwAAAA==.',['炫蓝']='炫蓝之仙:BAAALAADCgIIAgAAAA==.炫蓝之森:BAAALAAFFAIIAgAAAA==.炫蓝之猎:BAAALAADCgYIBgAAAA==.',['烟火']='烟火丶迅箭:BAAALAAECgIIAgAAAA==.',['熊了']='熊了个猫:BAAALAAECgYIBgAAAA==.',['熊大']='熊大:BAAALAAECgYIDAAAAA==.',['爱马']='爱马仕半巨人:BAAALAAFFAIIBAAAAA==.',['牛潘']='牛潘德拉贡:BAAALAAFFAIIBAAAAA==.',['牧晚']='牧晚离:BAAALAAECgMIAwAAAA==.',['狂暴']='狂暴大西瓜:BAABLAAECn8XAAMeAAgILRYASQBdAQAeAAgILRYASQBdAQAOAAYINAuWXAABAQAAAA==.狂暴战:BAAALAAFFAIIBAAAAA==.',['狂野']='狂野自然:BAAALAAECggICAAAAA==.',['狐假']='狐假虎威:BAABLAAFFH8GAAIJAAMIogyOZgB+AAAJAAMIogyOZgB+AAAAAA==.',['猎一']='猎一:BAABLAAFFH8IAAIEAAgIYh32BQCMAgAEAAgIYh32BQCMAgAAAA==.',['猎三']='猎三:BAAALAAFFAgIAgAAAA==.',['猎四']='猎四:BAAALAAFFAQIBAAAAA==.',['献祭']='献祭:BAAALAAFFAIIBAAAAA==.',['王思']='王思聪:BAABLAAFFH8FAAIBAAMIyBNAQACVAAABAAMIyBNAQACVAAAAAA==.',['玛琪']='玛琪果果:BAAALAAECgYIBgAAAA==.玛琪豆豆:BAAALAAECgYIBgAAAA==.',['珍珠']='珍珠:BAAALAAECgYICwAAAA==.',['甜咪']='甜咪:BAABLAAFFH8GAAIOAAII+RGJNgCYAAAOAAII+RGJNgCYAAAAAA==.',['甜水']='甜水面:BAABLAAECn8YAAINAAYIhA8CUgAVAQANAAYIhA8CUgAVAQAAAA==.',['甜甜']='甜甜:BAAALAAECgEIAQAAAA==.',['生掘']='生掘坊主:BAABLAAECn8eAAIQAAYIeh0+IgCXAQAQAAYIeh0+IgCXAQAAAA==.',['生生']='生生不息:BAABLAAFFH8OAAICAAIIZCKIHgCpAAACAAIIZCKIHgCpAAAAAA==.',['用力']='用力用力用力:BAAALAAECgUIBQAAAA==.',['男技']='男技师:BAAALAADCggICAAAAA==.',['番茄']='番茄炒鸡蛋:BAABLAAFFH8FAAIEAAUITg6pUwACAQAEAAUITg6pUwACAQAAAA==.',['疯狂']='疯狂的乞丐:BAAALAAFFAIIAgAAAA==.',['直人']='直人:BAABLAAFFH8VAAICAAYIpxYeFACZAQACAAYIpxYeFACZAQAAAA==.',['碎日']='碎日布坊:BAAALAADCgUIBQAAAA==.碎日敬腾:BAAALAADCgYIBgAAAA==.',['祖传']='祖传姥军医:BAAALAAECgUICAAAAA==.',['祝大']='祝大保:BAAALAAECgYIBgAAAA==.',['神圣']='神圣风暴:BAAALAAFFAIIBAAAAA==.',['第伍']='第伍元素:BAAALAAFFAIIBAAAAA==.',['筱樱']='筱樱:BAACLAAFFH8QAAICAAIIOxoEOgCGAAACAAIIOxoEOgCGAAAsAAQKfxoAAgIABwhLF+cjALcBAAIABwhLF+cjALcBAAAA.',['筱飞']='筱飞:BAAALAAECgEIAQAAAA==.',['米拉']='米拉卡:BAAALAAECgIIAwAAAA==.',['米芯']='米芯尔:BAAALAAECgYIBgAAAA==.',['糖水']='糖水绿洲:BAACLAAFFH8zAAINAAYI1RhmFgCtAQANAAYI1RhmFgCtAQAsAAQKfzwAAw0ACAh9HLEpAGsCAA0ACAh9HLEpAGsCAAwABwj2FfcrAGgBAAAA.',['紧那']='紧那罗王:BAAALAADCgIIAgAAAA==.',['绯夜']='绯夜苍穹:BAAALAAECggIDgABLAAFFAgICgAYAKYjAA==.',['绯红']='绯红玫瑰:BAABLAAFFH8YAAIJAAYIMCClHwC3AQAJAAYIMCClHwC3AQAAAA==.',['维生']='维生素片:BAAALAAECgYIBwAAAA==.',['聂影']='聂影逞烽:BAAALAAECgYIDAAAAA==.',['胖就']='胖就一個字:BAAALAAFFAIIAgAAAA==.',['胖胖']='胖胖无敌:BAAALAAECgYIDgAAAA==.',['舍得']='舍得分手:BAACLAAFFH8GAAIBAAIIIgkidAA8AAABAAIIIgkidAA8AAAsAAQKfxcAAgEABgjPFLRlADgBAAEABgjPFLRlADgBAAAA.',['色系']='色系:BAACLAAFFH8SAAMbAAYIqxnVDACNAQAbAAYIqxnVDACNAQAWAAIITgeBRABiAAAsAAQKfycAAhYABwjhFqohAKgBABYABwjhFqohAKgBAAAA.',['花虎']='花虎花虎:BAACLAAFFH8iAAINAAYI7RLWEgAiAQANAAYI7RLWEgAiAQAsAAQKfxUAAg0ACAhqHmEfAJcCAA0ACAhqHmEfAJcCAAAA.',['苍穹']='苍穹之光:BAAALAAECgYIDAAAAA==.',['苹果']='苹果小笨:BAABLAAECn8hAAIBAAgInBvwHQAnAgABAAgInBvwHQAnAgAAAA==.苹果牛:BAAALAAECgYIBgAAAA==.',['萨满']='萨满大西瓜:BAABLAAFFH8FAAMMAAMIGwRKOwBiAAAMAAMIGwRKOwBiAAANAAIImwembABOAAAAAA==.萨满巫师:BAAALAAECgUIBQAAAA==.',['落叶']='落叶之光:BAABLAAECn8ZAAIMAAcIhg+6YACWAQAMAAcIhg+6YACWAQAAAA==.落叶晨魂:BAAALAAECgYIBgAAAA==.落叶秋雨:BAAALAADCgYIBgAAAA==.落叶醉雨巷:BAABLAAFFH8FAAMaAAIIJgZpGAA3AAAZAAIIGgG6BwBOAAAaAAIIJgZpGAA3AAAAAA==.',['落魄']='落魄山的鱼:BAAALAAECgYIBgAAAA==.',['蓝萨']='蓝萨儿:BAAALAAECgEIAQAAAA==.',['袅德']='袅德:BAAALAAECgUIBQAAAA==.',['装甲']='装甲壁垒:BAAALAADCgMIAwAAAA==.',['西北']='西北望:BAAALAAECgYIBwAAAA==.',['西门']='西门冰修:BAAALAAECgIIAgAAAA==.西门庆:BAAALAAECgMIAwAAAA==.',['解压']='解压小游戏:BAAALAAECgYIDgAAAA==.',['读条']='读条三十秒:BAAALAAECgYIEwAAAA==.',['谢娜']='谢娜:BAAALAAECgYIBgABLAAFFAgIAgAiAAAAAA==.',['贰万']='贰万:BAAALAAECgYIBgAAAA==.',['赤小']='赤小豆:BAAALAAECgYICAAAAA==.',['超跑']='超跑牛:BAABLAAFFH8GAAIJAAIILAysggCFAAAJAAIILAysggCFAAAAAA==.',['越獄']='越獄:BAAALAAECgYIDQAAAA==.',['还是']='还是个泡泡:BAACLAAFFH8HAAIKAAIIfwX7GABSAAAKAAIIfwX7GABSAAAsAAQKfx4AAgoABwg7DVExADcBAAoABwg7DVExADcBAAAA.还是个白狼:BAAALAAFFAIIBAAAAA==.',['逞风']='逞风隐:BAAALAAECgYIDAAAAA==.',['道友']='道友留步啊:BAAALAADCgcIBwAAAA==.',['那咋']='那咋了捏:BAAALAAFFAIIAgAAAA==.',['酣战']='酣战热血:BAAALAAECgMIAwAAAA==.',['铁民']='铁民:BAAALAAECgMIBQAAAA==.',['长夜']='长夜余火:BAABLAAFFH8NAAMMAAUI1goAKAAHAQAMAAUI1goAKAAHAQANAAMITRBCQwB8AAABLAAFFAYIHQAEAIUhAA==.',['长江']='长江:BAAALAAECgYIBgAAAA==.',['门杠']='门杠清一色:BAAALAAECgYIBgABLAAFFAgIHgAEADkbAA==.',['门清']='门清清一色:BAAALAAECggICAAAAA==.',['阿尔']='阿尔塞死:BAAALAAECgYIBgAAAA==.阿尔赛利娅:BAAALAAECgYICgAAAA==.',['阿那']='阿那:BAAALAAECgYIBgAAAA==.',['陌上']='陌上丶猫児:BAAALAAFFAIIBAAAAA==.',['陌陌']='陌陌芊芊:BAAALAAECggICAAAAA==.',['雪之']='雪之灵:BAAALAAFFAIIBAAAAA==.',['露希']='露希莉斯:BAAALAADCgcIBwABLAAFFAYIPAALAGMgAA==.',['霸王']='霸王别急:BAAALAADCgYIAgAAAA==.',['霹雳']='霹雳:BAAALAAECgIIAgAAAA==.',['顺直']='顺直男:BAAALAAECgYIBgAAAA==.',['风月']='风月咕:BAAALAAECgEIAQAAAA==.',['风继']='风继续吹:BAAALAAECgYIBgAAAA==.',['飒飒']='飒飒逞风:BAACLAAFFH8JAAIKAAIIkA2zEgBoAAAKAAIIkA2zEgBoAAAsAAQKfxQAAgoABwimEksrAF4BAAoABwimEksrAF4BAAAA.',['飞弹']='飞弹:BAAALAAECgYICwAAAA==.',['首席']='首席魔法丨师:BAAALAAECgYICAAAAA==.',['香蕉']='香蕉不呐呐:BAAALAAECgYIBwAAAA==.',['马修']='马修:BAABLAAFFH8GAAIjAAIISQUGFwA4AAAjAAIISQUGFwA4AAAAAA==.',['骨道']='骨道瘦马:BAAALAAECgYICwAAAA==.',['魚娃']='魚娃宁宝:BAAALAADCgcIBwAAAA==.',['鱼儿']='鱼儿瓦娜斯:BAAALAAFFAIIAwAAAA==.',['鱼利']='鱼利丹:BAAALAAFFAIIAgAAAA==.',['鱼蕾']='鱼蕾莉亚:BAABLAAFFH8MAAMEAAYInBfNDgC6AQAEAAUIzRrNDgC6AQASAAMIUBSyEgDQAAAAAA==.',['鲑鱼']='鲑鱼卵派:BAAALAAECgYIDAAAAA==.',['麻辣']='麻辣砂锅米线:BAAALAAECgIIAgAAAA==.',['黃飛']='黃飛鴻:BAAALAADCggICwAAAA==.',['黄飞']='黄飞鴻:BAAALAADCggICAAAAA==.',['黎明']='黎明之剑:BAAALAAECgYIBwAAAA==.',['黑化']='黑化的桂言葉:BAABLAAFFH8KAAIJAAIIfxFlfQBHAAAJAAIIfxFlfQBHAAAAAA==.',['黑神']='黑神话悟净:BAAALAADCgYICgAAAA==.',['黑龙']='黑龙的影子:BAAALAADCgYIBgAAAA==.',['鼠鼠']='鼠鼠:BAAALAAECgYIBgAAAA==.',['龍語']='龍語婓:BAAALAAECgYIBgAAAA==.',['龙之']='龙之月:BAAALAADCggIDAAAAA==.龙之炎:BAAALAAFFAIIAgAAAA==.龙之猎神:BAAALAAECgQIBgAAAA==.',['龙在']='龙在天涯:BAAALAADCgEIAQAAAA==.',['龙菲']='龙菲菲:BAAALAAFFAIIAgABLAAFFAYIPAALAGMgAA==.',['龙语']='龙语斐:BAAALAAFFAIIAgAAAA==.龙语翡:BAAALAAFFAIIAgAAAA==.',['龙骑']='龙骑:BAAALAAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end