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
 local lookup = {'Paladin-Protection','DeathKnight-Unholy','Hunter-Marksmanship','Mage-Frost','Mage-Fire','Mage-Arcane','Priest-Discipline','Hunter-BeastMastery','Warlock-Destruction','Warlock-Demonology','Paladin-Retribution','DeathKnight-Blood','DemonHunter-Vengeance','DemonHunter-Havoc','Unknown-Unknown','Warlock-Affliction','Warrior-Fury','Druid-Balance','Paladin-Holy','Druid-Restoration','Priest-Holy','Priest-Shadow','Monk-Mistweaver','Monk-Windwalker','Rogue-Assassination','Evoker-Devastation','Monk-Brewmaster','Shaman-Restoration','Shaman-Elemental','Shaman-Enhancement',}; local provider = {region='CN',realm='拉文霍德',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ar='Areslol:BAABKgAFFH8IAAIBAAgI9Q54CQBoAQABAAgI9Q54CQBoAQAAAA==.Arthasdk:BAAAKgAFFAIIAwAAAA==.',Ba='Ballgods:BAABKgAFFH8HAAICAAcIjR+NBQBHAgACAAcIjR+NBQBHAgAAAA==.',Ca='Cady:BAAAKgADCggIGgAAAA==.',Cu='Cuc:BAAAKgAECgcIBwAAAA==.',Cy='Cyv:BAAAKgAECggICAAAAA==.',Cz='Czq:BAAAKgAECgQIBgAAAA==.',Dr='Dragonwing:BAAAKgAECgUIBQAAAA==.',Dy='Dyvoker:BAAAKgAECgcICAAAAA==.',Ga='Gaily:BAAAKgAECgYIBgAAAA==.',Ja='Jasonwswswws:BAAAKgAFFAgIAwAAAA==.',Ju='Juinho:BAAAKgAFFAIIAgAAAA==.',Kl='Kl:BAABKgAECn8gAAIDAAgImhA3QABSAQADAAgImhA3QABSAQAAAA==.',Le='Leogend:BAACKgAFFH8GAAMEAAYIvxIFCADtAAAEAAQIDhwFCADtAAAFAAIIyQSeKAB8AAAqAAQKfxkAAwQACAj8JKUFAOECAAQACAj8JKUFAOECAAUAAgj2A/qmACIAAAAA.',Lo='Losemind:BAAAKgAECgIIAgAAAA==.',Lz='Lzeroii:BAAAKgAECgMIAwAAAA==.',Pr='Prmsivonn:BAACKgAFFH8GAAMEAAII9yMLDADOAAAEAAII9yMLDADOAAAGAAEI6AFiCgArAAAqAAQKfyQAAwQACAj8JDEFAOUCAAQACAj3JDEFAOUCAAYABQikHj8OAGwBAAAA.',Ru='Rua:BAAAKgAECgIIAgAAAA==.',Sc='Scoflied:BAAAKgAECgcIBwAAAA==.',St='Starlight:BAABKgAFFH8KAAIHAAgIZAgnBwC4AQAHAAgIZAgnBwC4AQAAAA==.',Ti='Tindomiel:BAABKgAECn8wAAMDAAgIpiCXGgD8AQADAAgIoh2XGgD8AQAIAAYIICIXMgDgAQAAAA==.',['不动']='不动卿:BAABKgAFFH8GAAIIAAYIdxuCEgBjAQAIAAYIdxuCEgBjAQAAAA==.',['不能']='不能怂赶紧送:BAACKgAFFH8HAAIJAAcINRlwCwDWAQAJAAcINRlwCwDWAQAqAAQKfygAAwkACAibHnYOADsCAAkACAibHnYOADsCAAoABwiCFV4zACkBAAAA.',['丨拓']='丨拓跋菩萨丨:BAABKgAFFH8GAAILAAYIZhU7JgBQAQALAAYIZhU7JgBQAQAAAA==.',['丨桂']='丨桂言葉丨:BAAAKgAECgcICwAAAA==.',['丹泽']='丹泽尔:BAAAKgADCggICAAAAA==.',['主宰']='主宰灬刺心:BAAAKgAFFAQIBAAAAA==.',['九五']='九五二七:BAAAKgAECgYIBgAAAA==.',['云宝']='云宝黛西:BAAAKgAECgQIBAAAAA==.',['五档']='五档太阳神:BAAAKgAECgYICwAAAA==.',['亡红']='亡红月影:BAABKgAFFH8JAAMMAAgIWRetBgDBAQAMAAcIMButBgDBAQACAAIIUAD5NQAvAAAAAA==.',['人形']='人形奶妈:BAABKgAFFH8GAAIBAAYIVhBWDwAMAQABAAYIVhBWDwAMAQAAAA==.',['伊莉']='伊莉丹:BAABKgAFFH8UAAMNAAYIvxmuBQBHAQANAAYI3ReuBQBHAQAOAAQIVx0zIgD1AAABKgAFFAgIBAAPAAAAAA==.',['伴风']='伴风听雨:BAABKgAECn8YAAQJAAcI5BiNNgCUAQAJAAcI5BiNNgCUAQAQAAMI5wlzLwB2AAAKAAII1BFvfwA1AAAAAA==.',['何欣']='何欣橙:BAAAKgAFFAQIBAAAAA==.',['余震']='余震:BAAAKgAECgYIBgAAAA==.',['你最']='你最珍贵:BAABKgAFFH8OAAIRAAQIHBm+EQDzAAARAAQIHBm+EQDzAAABKgAFFAgICwASAIUIAA==.',['依然']='依然寻觅:BAABKgAECn8VAAMTAAgIlSALBwB6AgATAAgIlSALBwB6AgALAAgInCDWSwAOAgAAAA==.',['元婴']='元婴老怪:BAAAKgAECgQIBAAAAA==.',['全部']='全部停手:BAABKgAFFH8KAAINAAMIQwRYFABgAAANAAMIQwRYFABgAAAAAA==.',['兰斯']='兰斯彼恩:BAAAKgAECgEIAQAAAA==.',['兽之']='兽之梦凌:BAABKgAFFH8IAAIDAAgIDBU1BgAJAgADAAgIDBU1BgAJAgAAAA==.',['凨凪']='凨凪凮夙:BAAAKgAECggICwAAAA==.',['匚匸']='匚匸凵冂:BAAAKgAECgcIDwAAAA==.',['华咕']='华咕咕:BAABKgAFFH8MAAMUAAgIsxlUBQDOAQAUAAgIsxlUBQDOAQASAAIIUyQGMADUAAAAAA==.',['华扁']='华扁鹊:BAABKgAFFH8KAAMVAAYIzhk8CQCQAQAVAAYIzhk8CQCQAQAWAAQIzRz1DADzAAABKgAFFAgIEwAJAPIiAA==.',['华更']='华更纱:BAABKgAFFH8IAAIMAAgI1xOOBQDmAQAMAAgI1xOOBQDmAQAAAA==.',['华毛']='华毛头:BAAAKgAFFAYIBAAAAA==.',['卡萨']='卡萨丶布兰卡:BAAAKgAECgIIAwAAAA==.',['可口']='可口可乐:BAAAKgAECgYIDQAAAA==.',['名门']='名门一窝头:BAAAKgADCgIIAgAAAA==.',['咪乐']='咪乐牛:BAAAKgAFFAgIBAAAAA==.',['咪樂']='咪樂貓:BAAAKgAECggIBgAAAA==.',['哐哐']='哐哐你的圈圈:BAAAKgAECgUIAQAAAA==.',['哨兵']='哨兵:BAABKgAFFH8IAAMIAAQIJxgtMgDFAAAIAAQI/BctMgDFAAADAAQILA4DOQCTAAABKgAFFAgIBgAVAKsLAA==.',['噢丶']='噢丶在这狂混:BAAAKgAECgIIAgAAAA==.',['四妹']='四妹:BAAAKgAECgYIBgAAAA==.',['囧灬']='囧灬三少:BAAAKgADCgEIAQAAAA==.',['囷麓']='囷麓眾囦:BAABKgAECn8aAAMKAAgI0hiiCQCoAQAKAAgI0hiiCQCoAQAJAAQInxLOYQDoAAAAAA==.',['墨离']='墨离殇:BAABKgAECn8oAAILAAgImSCJNgAlAgALAAgImSCJNgAlAgAAAA==.',['夏至']='夏至:BAAAKgAECgMIAwAAAA==.',['大乃']='大乃起来:BAAAKgAECgYIBgAAAA==.',['大神']='大神带带我:BAAAKgAECggIDgAAAA==.大神带带杂家:BAABKgAECn8iAAIXAAgInAgwOQDpAAAXAAgInAgwOQDpAAAAAA==.',['天蓝']='天蓝的雪球:BAAAKgAECgcIBwAAAA==.',['奥莉']='奥莉薇:BAAAKgAECgYIBgAAAA==.',['女神']='女神:BAAAKgAECgEIAQAAAA==.',['奶量']='奶量充足:BAAAKgAECgMIAwAAAA==.',['完全']='完全兽捕鸟:BAAAKgAFFAQIBAAAAA==.',['寒夜']='寒夜影:BAAAKgAECgQIBgAAAA==.',['小丶']='小丶扬:BAABKgAFFH8IAAIBAAQIPgvODwCHAAABAAQIPgvODwCHAAAAAA==.',['小九']='小九吖:BAABKgAFFH8FAAMUAAUIJBdqGADdAAAUAAMIJBJqGADdAAASAAIIXAr+WwBDAAAAAA==.',['小学']='小学妹:BAAAKgAECgEIAQAAAA==.',['小拳']='小拳拳捶胸口:BAAAKgADCggICAAAAA==.',['小救']='小救星小杜:BAABKgAFFH8LAAIYAAcIjBpuBAAJAgAYAAcIjBpuBAAJAgABKgAFFAgICQAXAHQWAA==.',['小旋']='小旋风:BAAAKgAECgMIBAAAAA==.',['就爱']='就爱吃肉肉:BAABKgAFFH8IAAIRAAgIjwtJBwDvAQARAAgIjwtJBwDvAQAAAA==.',['巴比']='巴比伦魂:BAAAKgAECgQIBAAAAA==.',['幺妹']='幺妹:BAAAKgAECgIIAgAAAA==.',['开着']='开着三崩子:BAAAKgAFFAgIBAAAAA==.',['弦上']='弦上啭春莺:BAAAKgAFFAUIBAAAAA==.',['彩彻']='彩彻区明:BAAAKgAFFAMIAgAAAA==.',['影夜']='影夜舞:BAAAKgAECgQIBAABKgAFFAgICwASAIUIAA==.',['德勒']='德勒巴妮娅:BAABKgAFFH8NAAMUAAYIvA2FAgBwAQAUAAYIvA2FAgBwAQASAAQIoBmWEwDsAAAAAA==.',['心安']='心安归处:BAABKgAFFH8IAAILAAgIxgOWEgB0AQALAAgIxgOWEgB0AQAAAA==.',['心灵']='心灵种子:BAAAKgAECgYIAwAAAA==.',['忘情']='忘情草:BAAAKgAECgQIBAAAAA==.',['悄咪']='悄咪咪:BAAAKgAECgUIBgAAAA==.',['悠悠']='悠悠泪魂:BAAAKgAFFAQIBAAAAA==.',['意达']='意达的花:BAAAKgAECgYIBgAAAA==.',['摄政']='摄政王伯瓦尔:BAABKgAFFH8HAAILAAcI0wFUaQCZAAALAAcI0wFUaQCZAAAAAA==.',['摩诃']='摩诃迦叶:BAABKgAFFH8FAAIVAAII7gWfHgBmAAAVAAII7gWfHgBmAAAAAA==.',['收购']='收购幸福:BAACKgAFFH8PAAIIAAYITiAmCwC8AQAIAAYITiAmCwC8AQAqAAQKfxYAAggACAhAHIFCAO8BAAgACAhAHIFCAO8BAAEqAAUUCAgLABIAhQgA.',['断幺']='断幺九:BAAAKgAFFAIIBAABKgAFFAMIDwASADIfAA==.',['断罪']='断罪之光:BAAAKgAECggIEwABKgAFFAgICwASAIUIAA==.',['旋律']='旋律迸溅:BAABKgAECn8kAAQFAAgIxRfYFQCTAQAEAAgIvRQVJACTAQAFAAgIzhPYFQCTAQAGAAUIxREBXgDLAAAAAA==.',['无尽']='无尽黑暗:BAAAKgADCgQIBAAAAA==.',['无情']='无情丶玄冰:BAAAKgAECgYIEQAAAA==.',['旺仔']='旺仔牛奶:BAABKgAFFH8LAAISAAgIhQhmDQCiAQASAAgIhQhmDQCiAQAAAA==.',['暴走']='暴走倾城灬兽:BAAAKgAECgEIAQAAAA==.',['月夜']='月夜恋辰:BAABKgAFFH8SAAMVAAYIRxMxCgAvAQAVAAYIRxMxCgAvAQAWAAYIHBQ6DQAsAQABKgAFFAgIDgAJAPkhAA==.月夜晨曦:BAABKgAFFH8GAAIZAAYI1wsPCAB1AQAZAAYI1wsPCAB1AQAAAA==.',['末日']='末日傲气:BAABKgAECn8UAAMHAAgI8xlRFAD9AQAHAAgI8xlRFAD9AQAVAAcIwwdyVQC9AAAAAA==.',['来自']='来自虚空:BAAAKgADCgQIBAAAAA==.',['椒麻']='椒麻鸡:BAAAKgADCgEIAQAAAA==.',['樱花']='樱花丶洛:BAAAKgAECgQIBAAAAA==.',['殇灬']='殇灬冰鸢:BAAAKgAFFAgIBAAAAA==.殇灬无痕:BAABKgAECn8rAAMLAAgIxSZaAgAcAwALAAgIxSZaAgAcAwATAAgIsSMLCwA9AgAAAA==.殇灬黯舞:BAAAKgAFFAMIAwAAAA==.',['水水']='水水之风:BAAAKgAECgYIBgAAAA==.',['江南']='江南皮革厂:BAAAKgAECgMIAwAAAA==.',['江山']='江山岳:BAAAKgADCgQIBAAAAA==.',['江来']='江来:BAABKgAFFH8GAAMWAAYIshIpFwDCAAAWAAMIZBQpFwDCAAAVAAMIUSG2JQCsAAAAAA==.',['油菜']='油菜妞:BAAAKgADCgYIBgAAAA==.',['治愈']='治愈系少女:BAAAKgAECgIIAgAAAA==.',['津雪']='津雪儿:BAABKgAFFH8IAAIGAAgI2RfqBQAxAgAGAAgI2RfqBQAxAgAAAA==.',['温暖']='温暖的黑暗:BAAAKgADCggICAAAAA==.',['火星']='火星宝贝:BAAAKgAFFAMIAwAAAA==.',['灭灭']='灭灭重新来:BAAAKgADCgIIAgAAAA==.',['燕赤']='燕赤侠:BAAAKgAECgcICgAAAA==.',['爸吧']='爸吧:BAAAKgAECgYIDgAAAA==.',['片儿']='片儿懒:BAAAKgAECgYIBgABKgAFFAgIDgAJAJAeAA==.',['牛肉']='牛肉帝王:BAABKgAFFH8IAAIFAAQIxRuqGADsAAAFAAQIxRuqGADsAAAAAA==.',['猎杀']='猎杀原型:BAAAKgAFFAIIAgAAAA==.',['猥猎']='猥猎残榀:BAAAKgADCggIDwAAAA==.',['猫姐']='猫姐在家吗:BAABKgAFFH8HAAIaAAcIaB9MBgAxAgAaAAcIaB9MBgAxAgAAAA==.',['玉米']='玉米:BAABKgAECn80AAMCAAgIciVzBwDYAgACAAgIciVzBwDYAgAMAAEIIx+sGgBYAAABKgAECggIMQALAJcmAA==.',['王富']='王富贵:BAABKgAFFH8FAAMFAAQI5BVyJwCyAAAFAAQIpQlyJwCyAAAGAAEIviVAQABXAAAAAA==.',['玩世']='玩世乂不恭:BAAAKgAECgMIAwAAAA==.',['琴伤']='琴伤:BAAAKgAECgUIBQAAAA==.',['疯魔']='疯魔辣:BAAAKgAECgEIAQAAAA==.',['砍砍']='砍砍:BAAAKgADCgQIBAAAAA==.',['碧愈']='碧愈疾风:BAACKgAFFH8WAAMXAAYIsByXAQDWAQAXAAYIsByXAQDWAQAbAAYIxgQOBgC8AAAqAAQKfxcAAhcACAgJHTwbAK4BABcACAgJHTwbAK4BAAAA.',['筱筱']='筱筱萨:BAAAKgAECgEIAQAAAA==.',['筱麦']='筱麦:BAAAKgADCgEIAQAAAA==.',['糖哥']='糖哥砍爆你:BAAAKgAFFAgIBAAAAA==.',['紫雾']='紫雾之花:BAAAKgADCgYIBgAAAA==.',['红烧']='红烧大排骨:BAABKgAFFH8QAAIOAAgIPSDOAwCdAgAOAAgIPSDOAwCdAgAAAA==.红烧大肉肉:BAABKgAFFH8IAAIBAAgIDgokAQCuAQABAAgIDgokAQCuAQAAAA==.',['罐罐']='罐罐瓶瓶:BAAAKgAECgEIAQAAAA==.',['罗拉']='罗拉娜:BAABKgAFFH8IAAMIAAgIFQgMHQAcAQAIAAYIpwoMHQAcAQADAAIIqQGxRgBlAAAAAA==.',['罗罗']='罗罗诺诺索洛:BAABKgAFFH8HAAMVAAcIPw46DQBRAQAVAAYIvgo6DQBRAQAWAAEIah3PJwBTAAAAAA==.',['老一']='老一套:BAAAKgAECgYICgAAAA==.',['老爷']='老爷子:BAABKgAFFH8GAAIDAAYISQH2HQB/AAADAAYISQH2HQB/AAAAAA==.',['聪聪']='聪聪那年:BAAAKgAFFAYIAgAAAA==.',['膳魔']='膳魔師:BAAAKgAECgMIBAAAAA==.',['自作']='自作多情:BAABKgAECn8rAAIRAAgIhxhyKgDgAQARAAgIhxhyKgDgAQAAAA==.',['艾克']='艾克塞琳:BAABKgAFFH8GAAIEAAYI8hlhBACjAQAEAAYI8hlhBACjAQAAAA==.',['花心']='花心:BAABKgAFFH8JAAILAAQI1BpaRADmAAALAAQI1BpaRADmAAAAAA==.',['莉雅']='莉雅德琳:BAEAKgADCggIEAAAAA==.',['莱尔']='莱尔:BAAAKgADCggICAAAAA==.',['萨满']='萨满的飒:BAABKgAECn8VAAITAAgIEwhVLQACAQATAAgIEwhVLQACAQAAAA==.',['落樱']='落樱纷飞:BAABKgAECn8fAAMHAAgIqyABGgDzAQAVAAgI/B1nGgADAgAHAAgItBgBGgDzAQAAAA==.',['註縡']='註縡灬刖:BAAAKgAECgIIAgAAAA==.',['轻轻']='轻轻流云:BAAAKgADCggICAAAAA==.',['达拉']='达拉斯小牛:BAAAKgADCgYIBgAAAA==.达拉西:BAABKgAFFH8GAAINAAYIrwxMCgAFAQANAAYIrwxMCgAFAQAAAA==.',['这是']='这是一个萨满:BAAAKgAECggICAAAAA==.',['迦旃']='迦旃言雾:BAAAKgADCgQIBAAAAA==.',['迷离']='迷离:BAAAKgAECgEIAQAAAA==.',['逃无']='逃无可桃:BAACKgAFFH8JAAIcAAQIvwzFNQCmAAAcAAQIvwzFNQCmAAAqAAQKfzgAAhwACAghHr8NAPABABwACAghHr8NAPABAAAA.',['钻石']='钻石老舅:BAAAKgAECgMIAwAAAA==.',['银铸']='银铸八极:BAAAKgAFFAQIBAAAAA==.',['镸眉']='镸眉:BAAAKgAECgIIAgAAAA==.',['阿兹']='阿兹瑞思:BAAAKgAECgUICQAAAA==.',['阿萨']='阿萨斯:BAAAKgAFFAMIAwAAAA==.',['陆离']='陆离:BAAAKgAECgYIDQAAAA==.',['隐藏']='隐藏的无畏:BAAAKgADCgMIBQAAAA==.',['雪化']='雪化凝冰:BAAAKgAECgQIBgAAAA==.',['雷諾']='雷諾:BAABKgAFFH8MAAIZAAgIYRJBBwAEAgAZAAgIYRJBBwAEAgAAAA==.',['静默']='静默时光:BAAAKgAECgYIEwAAAA==.',['颗粒']='颗粒黑牛:BAABKgAECn8UAAQcAAgI4gxkTwBRAQAcAAgI4gxkTwBRAQAdAAYILBINPAAfAQAeAAEIFQ+MRgA4AAAAAA==.',['香香']='香香公主:BAACKgAFFH8KAAIGAAMI4Bd5IwDVAAAGAAMI4Bd5IwDVAAAqAAQKfyMAAgYACAjzHIgIAFsCAAYACAjzHIgIAFsCAAAA.',['魅雪']='魅雪紫夢:BAAAKgAFFAgIBAAAAA==.',['魑魅']='魑魅魍魉:BAAAKgADCggICAAAAA==.',['魔法']='魔法之龟:BAAAKgAECgQIBAAAAA==.魔法少年小元:BAAAKgAECgIIAgAAAA==.',['鸟飞']='鸟飞走了:BAABKgAFFH8KAAILAAQIJCEKCgAwAQALAAQIJCEKCgAwAQAAAA==.',['黑色']='黑色幻象:BAABKgAFFH8IAAIcAAgIIQYGCgBoAQAcAAgIIQYGCgBoAQAAAA==.',['龙興']='龙興龘龘:BAAAKgAECgQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end