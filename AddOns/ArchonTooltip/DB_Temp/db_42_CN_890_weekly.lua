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
 local lookup = {'Paladin-Retribution','Unknown-Unknown','Mage-Fire','Hunter-BeastMastery','Hunter-Marksmanship','Paladin-Protection','DeathKnight-Blood','DeathKnight-Unholy','Monk-Windwalker','Evoker-Devastation','DemonHunter-Havoc','Druid-Balance','Druid-Restoration','Warrior-Fury','Shaman-Enhancement','Shaman-Restoration','Shaman-Elemental','Warrior-Arms','DemonHunter-Vengeance','Priest-Holy','Priest-Shadow','Priest-Discipline','Mage-Frost','Mage-Arcane','Monk-Mistweaver','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Druid-Guardian','Paladin-Holy','DeathKnight-Frost','Rogue-Assassination',}; local provider = {region='CN',realm='麦姆',name='CN',type='weekly',zone=42,date='2025-08-04',data={Ac='Acool:BAAAKgAFFAYIBAABKgAFFAgICAABAP8gAA==.',Am='Amvs:BAAAKgAFFAEIAgAAAA==.',An='Annaami:BAAAKgADCgYIBgAAAA==.Annami:BAAAKgAECgQIBAAAAA==.Annmi:BAAAKgADCggICAAAAA==.',As='Astorelle:BAAAKgAECgIIAgABKgAFFAIIBAACAAAAAA==.',Cl='Clearlove:BAAAKgADCggICQAAAA==.',Cu='Cure:BAAAKgAECgEIAQAAAA==.',Cx='Cxk:BAAAKgAFFAEIAQAAAA==.',Dh='Dhvs:BAAAKgAFFAIIAwAAAA==.',Dk='Dkl:BAAAKgAECggIDgAAAA==.',Dr='Drlu:BAABKgAFFH8GAAIDAAYI1xgVDQBmAQADAAYI1xgVDQBmAQAAAA==.',Ed='Edvard:BAAAKgAFFAEIAQAAAA==.',Fr='Fruit:BAAAKgADCggICAAAAA==.',Ge='Gede:BAAAKgADCgQIBAAAAA==.',Gg='Ggcj:BAAAKgAFFAEIAQAAAA==.',Go='Gosh:BAAAKgADCggICgAAAA==.Goshsweat:BAAAKgAFFAMIAwAAAA==.',Ki='Kiron:BAAAKgAECgIIAgAAAA==.',Kk='Kkqq:BAAAKgAECgEIAQAAAA==.',Li='Lielielie:BAACKgAFFH8QAAMEAAYIiR7HHAAeAQAEAAQIuCPHHAAeAQAFAAIIxBaTNQCdAAAqAAQKfxQAAgQACAjGIysMANYCAAQACAjGIysMANYCAAEqAAUUBggXAAYAGxEA.Little:BAABKgAFFH8KAAMHAAYI7g6ABwAcAQAHAAYI6AqABwAcAQAIAAQIaA0DGQDOAAAAAA==.',Me='Meowdracthyr:BAAAKgAECgYIBgABKgAECggINQAJAP0jAA==.Meowmage:BAAAKgAECgUIBQABKgAECggINQAJAP0jAA==.',Mi='Misty:BAAAKgADCgIIAgAAAA==.',Ne='Neltharis:BAABKgAFFH8FAAIKAAUI6CEyEgBDAQAKAAUI6CEyEgBDAQAAAA==.Nexxarion:BAAAKgAFFAcIAwAAAA==.',Ol='Oliveira:BAABKgAFFH8GAAILAAQImxxfEwDyAAALAAQImxxfEwDyAAABKgAFFAgIDAALADUhAA==.',Ov='Ovleqiq:BAABKgAFFH8WAAILAAgIuiATBACUAgALAAgIuiATBACUAgAAAA==.',Re='Regil:BAAAKgAECggIDgAAAA==.',Sh='Shigure:BAAAKgAECggIEQABKgAFFAIIBAACAAAAAA==.Shugure:BAAAKgAFFAIIBAAAAA==.',Si='Silverdew:BAABKgAECn8WAAMMAAgIlRlkIwAxAQAMAAYInxlkIwAxAQANAAQI9hNDRgD1AAAAAA==.',St='Starling:BAAAKgAECgYICQAAAA==.',Sw='Sweetdeath:BAAAKgADCgMIAwAAAA==.',To='Tooltauren:BAABKgAFFH8YAAIOAAYIFB6xAADyAQAOAAYIFB6xAADyAQABKgAFFAgIBgAOABcZAA==.Toothless:BAABKgAFFH8MAAINAAMIHg4ZDwCgAAANAAMIHg4ZDwCgAAAAAA==.',Tu='Tuhaha:BAAAKgADCgQIBQAAAA==.',Xi='Xiaomao:BAACKgAFFH8XAAIBAAYIpB1ZIQBpAQABAAYIpB1ZIQBpAQAqAAQKfywAAgEACAgSIVEnAH8CAAEACAgSIVEnAH8CAAEqAAUUCAgKAAEArSUA.',['一奈']='一奈奈哦:BAAAKgADCgcIBwAAAA==.',['一念']='一念百年中:BAAAKgAFFAIIAgAAAA==.',['一木']='一木易一:BAAAKgAFFAQIBAAAAA==.',['一箭']='一箭就行:BAAAKgAFFAIIBAAAAA==.',['不会']='不会玩近战:BAAAKgADCgMIAwAAAA==.',['不做']='不做牛马:BAABKgAFFH8UAAIKAAQILg/MFQC5AAAKAAQILg/MFQC5AAAAAA==.',['不想']='不想成为宝宝:BAAAKgAECgEIAQAAAA==.',['专业']='专业电疗:BAABKgAECn8UAAIPAAgInRP+FwCbAQAPAAgInRP+FwCbAQAAAA==.',['专养']='专养牛马:BAAAKgADCgEIAQAAAA==.',['丨大']='丨大仙丨:BAAAKgAECgUIBQAAAA==.',['丨狐']='丨狐仙儿丨:BAABKgAFFH8PAAMQAAMIpR29EQDsAAAQAAMIpR29EQDsAAARAAMIFwTvHACSAAAAAA==.',['丨龙']='丨龙仙丨:BAAAKgAECgcIBwAAAA==.',['中年']='中年又发春:BAABKgAFFH8GAAIBAAYI3yG5EwC+AQABAAYI3yG5EwC+AQAAAA==.',['丿丶']='丿丶德耀神州:BAAAKgADCgEIAQAAAA==.丿丶武耀神州:BAAAKgADCgEIAQAAAA==.丿丶盗耀神州:BAAAKgADCgEIAQAAAA==.丿丶蓝颜祸水:BAAAKgAFFAIIAgAAAA==.丿丶血耀神州:BAAAKgADCgEIAQAAAA==.',['丿你']='丿你好嗨:BAAAKgAFFAIIAgAAAA==.丿你好逗:BAAAKgAFFAQIBAAAAA==.丿你真拽:BAAAKgAECggICAAAAA==.丿你真逗:BAABKgAFFH8GAAIBAAYIthZEIwBfAQABAAYIthZEIwBfAQAAAA==.',['乌妖']='乌妖亡:BAAAKgAECgEIAQAAAA==.',['于少']='于少保:BAAAKgAECgQICQAAAA==.',['五堰']='五堰:BAAAKgAFFAMIAwAAAA==.',['亦橙']='亦橙:BAAAKgADCgEIAQAAAA==.',['人不']='人不能不恰饭:BAAAKgAECggIEAAAAA==.',['他们']='他们叫我大壮:BAABKgAFFH8KAAMOAAYIlBozDACIAQAOAAYIlBozDACIAQASAAEIRwvCFgBZAAAAAA==.',['伊利']='伊利卡拉:BAAAKgAFFAQIBAAAAA==.',['传承']='传承套我来了:BAABKgAECn8ZAAIHAAgIpiOxBQDBAgAHAAgIpiOxBQDBAgABKgAFFAEIAQACAAAAAA==.',['伸缩']='伸缩牛:BAAAKgAECggICAAAAA==.',['你好']='你好我要灌注:BAAAKgAECgMIAwAAAA==.',['傻馒']='傻馒奶不动:BAAAKgADCgIIAgAAAA==.',['光与']='光与影的传说:BAABKgAECn8mAAIBAAgIqSQUFADHAgABAAgIqSQUFADHAgABKgAFFAgIUgAFAOglAA==.',['兮尘']='兮尘墨羽:BAAAKgADCggIEwAAAA==.',['兰丶']='兰丶博:BAAAKgADCgUIBQAAAA==.',['农夫']='农夫三拳啊:BAAAKgAECgQIBAAAAA==.',['冥阿']='冥阿茶丶:BAABKgAFFH8KAAITAAYIlwQWEADDAAATAAYIlwQWEADDAAAAAA==.',['初见']='初见小德:BAACKgAFFH8IAAIMAAMIXxAXNQDHAAAMAAMIXxAXNQDHAAAqAAQKfxwAAgwACAhkFas5AMEBAAwACAhkFas5AMEBAAAA.初见老贼:BAAAKgAECgQIBAAAAA==.',['别惹']='别惹我胖虎:BAAAKgAFFAEIAQAAAA==.',['别慌']='别慌:BAACKgAFFH8OAAMUAAQIHAodFwCGAAAUAAQIHAodFwCGAAAVAAMIYwEqGgBBAAAqAAQKfxcAAxQACAjNC6tDAAQBABQACAjUCqtDAAQBABYAAwjACMZ3AGUAAAAA.',['北京']='北京薛之谦:BAAAKgAECgQIBAAAAA==.',['厕所']='厕所之术界:BAAAKgAECgMIAwABKgAFFAYIBgAPAAUTAA==.',['受死']='受死吧牛马:BAAAKgADCgQIBQAAAA==.',['古堰']='古堰捞面王:BAAAKgAECggICAAAAA==.古堰老麻雀:BAAAKgADCgMIAwAAAA==.',['古尔']='古尔舟:BAAAKgAECgEIAQAAAA==.',['古道']='古道瘦马:BAAAKgAECgUIBQAAAA==.',['只会']='只会心疼哥鸽:BAAAKgAECgEIAQAAAA==.',['只是']='只是休闲玩:BAAAKgAECgEIAQAAAA==.',['可以']='可以了够混了:BAAAKgAECggIDQAAAA==.',['可爱']='可爱的鲨鱼:BAABKgAECn8dAAMXAAgI8xvxEgApAgAXAAgI8xvxEgApAgAYAAIIWxHFfABuAAAAAA==.',['名捕']='名捕丶追风:BAAAKgADCgcIBwAAAA==.',['听欣']='听欣:BAAAKgADCggICAAAAA==.',['吾名']='吾名喵喵之翼:BAABKgAECn81AAMJAAgI/SMzBgDPAgAJAAgI/SMzBgDPAgAZAAYIUQu2XADJAAAAAA==.',['周起']='周起:BAAAKgAECgQIBAAAAA==.',['咻咻']='咻咻就很快:BAAAKgAECgUIBgAAAA==.',['哈利']='哈利波特别大:BAAAKgADCgEIAQAAAA==.',['哦德']='哦德发:BAAAKgADCggICAAAAA==.',['喂你']='喂你吃:BAAAKgAECgEIAQAAAA==.',['喜乐']='喜乐的小兔:BAAAKgAECgQIBAAAAA==.',['嘿铁']='嘿铁:BAAAKgAECgEIAQAAAA==.',['土豆']='土豆牛马:BAABKgAFFH8jAAIJAAYI7xIQBwBsAQAJAAYI7xIQBwBsAQAAAA==.',['圣光']='圣光保护你:BAAAKgADCgEIAQAAAA==.圣光照耀着我:BAAAKgAFFAEIAQAAAA==.',['墨轩']='墨轩:BAABKgAFFH8IAAIBAAYIdBBRJgBPAQABAAYIdBBRJgBPAQAAAA==.',['墨阳']='墨阳:BAAAKgADCgEIAQAAAA==.',['夜羽']='夜羽:BAAAKgAECgcICgAAAA==.',['夜行']='夜行动物:BAABKgAFFH8hAAIKAAYIHBjvCwB1AQAKAAYIHBjvCwB1AQAAAA==.',['大又']='大又土火铳:BAABKgAFFH8GAAIEAAYIsw64DQBVAQAEAAYIsw64DQBVAQAAAA==.大又土聖骐:BAABKgAFFH8GAAIBAAYIKRPAEgBwAQABAAYIKRPAEgBwAQAAAA==.',['大调']='大调查进职场:BAAAKgADCgMIAwAAAA==.',['天亮']='天亮说晚安:BAAAKgAECgIIAgAAAA==.',['天生']='天生牛马:BAACKgAFFH8iAAIOAAYIiRxcCADLAQAOAAYIiRxcCADLAQAqAAQKfxgAAg4ACAg/HS4aADwCAA4ACAg/HS4aADwCAAAA.',['天黑']='天黑遛个弯:BAAAKgAECgMIAwAAAA==.',['天龍']='天龍瑬星:BAAAKgAECggIDwAAAA==.',['太阳']='太阳之泪:BAAAKgADCgUIBQAAAA==.',['夺目']='夺目龙:BAAAKgADCgQIBAAAAA==.',['奇米']='奇米蛋:BAAAKgADCgYIBgAAAA==.',['奔跑']='奔跑着来:BAAAKgAECggICAAAAA==.',['奥德']='奥德彪:BAABKgAFFH8GAAIGAAYIOgdzFgDEAAAGAAYIOgdzFgDEAAAAAA==.',['奶很']='奶很小的牛牛:BAAAKgAECggIDQAAAA==.',['奶熊']='奶熊:BAAAKgAECgQIBAAAAA==.',['妖刀']='妖刀姬:BAAAKgAECgMIAwAAAA==.',['宫昶']='宫昶泊疆谙旗:BAABKgAFFH8GAAIIAAYItBNZCgB5AQAIAAYItBNZCgB5AQAAAA==.宫昶泊疆飒蛮:BAABKgAFFH8GAAIPAAYIOxPVBgB/AQAPAAYIOxPVBgB/AQAAAA==.',['寒江']='寒江夜雨:BAAAKgADCgcICgAAAA==.',['小孩']='小孩孩:BAABKgAECn8nAAQaAAgIcR1sDgCRAQAaAAYIMxtsDgCRAQAbAAgItxQ1OgCEAQAcAAIITxkfUwCfAAAAAA==.',['小小']='小小牛马:BAABKgAFFH8iAAMFAAgIbw9xBwDJAQAFAAgI9A1xBwDJAQAEAAQInxryKQDdAAAAAA==.小小马蝼:BAABKgAFFH8kAAIPAAYIHBRwBQCJAQAPAAYIHBRwBQCJAQAAAA==.',['小汐']='小汐妍:BAAAKgAECggICwAAAA==.',['小然']='小然弟:BAABKgAECn8VAAIFAAgIXh3VEgA9AgAFAAgIXh3VEgA9AgAAAA==.',['小熊']='小熊猫丽丽:BAAAKgAECggICAAAAA==.',['小瞎']='小瞎眼波比:BAAAKgADCgQIBAAAAA==.',['小福']='小福:BAAAKgAECgMIBAAAAA==.',['小范']='小范大人:BAAAKgAFFAgIBAAAAA==.',['小阿']='小阿狸:BAAAKgAFFAgIAgAAAA==.',['小陆']='小陆柒:BAAAKgAECgUIBQAAAA==.',['少时']='少时月黑:BAAAKgAFFAgIBAAAAA==.',['屁带']='屁带汁:BAAAKgADCgUIBQAAAA==.',['山椒']='山椒猪皮茎:BAAAKgADCgUIBQAAAA==.',['崴脚']='崴脚的猫:BAAAKgAECgQIBAAAAA==.',['川宝']='川宝:BAABKgAFFH8GAAMFAAYI8grZJgDQAAAFAAUIXQjZJgDQAAAEAAEIRhVCWwBBAAAAAA==.',['年华']='年华逝去:BAAAKgADCgYIBgAAAA==.',['庄毕']='庄毕凡:BAAAKgADCgEIAQAAAA==.',['开心']='开心马蝼:BAACKgAFFH8zAAIBAAcI1iIPBgBdAgABAAcI1iIPBgBdAgAqAAQKfy8AAwEACAgcJvYLAOkCAAEACAgcJvYLAOkCAAYAAQjjHpYdAFgAAAAA.',['弑神']='弑神大米:BAABKgAECn8WAAMGAAYIAAkaPQCaAAAGAAYIXQYaPQCaAAABAAMIsQqwKgGDAAAAAA==.',['德莱']='德莱武:BAABKgAFFH8RAAMIAAYIniD/AQDPAQAIAAYIniD/AQDPAQAHAAQIFxKjEAC7AAAAAA==.',['德鲁']='德鲁大仙:BAACKgAFFH8OAAMNAAMIextKFgDvAAANAAMIextKFgDvAAAMAAII+AKQMQBbAAAqAAQKfzEABA0ACAgBIBMKAG8CAA0ACAgBIBMKAG8CAB0ABAgAEUggAJkAAAwAAggeFIykAHsAAAEqAAUUBggXAAYAGxEA.',['忘掉']='忘掉种过的花:BAAAKgAECgEIAQAAAA==.',['想养']='想养只渡鸦:BAAAKgAECgcIDQAAAA==.',['愛寞']='愛寞齊:BAAAKgADCgIIBgAAAA==.',['我不']='我不是机器人:BAABKgAFFH8MAAMLAAQIvRApGADjAAALAAQIvRApGADjAAATAAIIywYSFgBOAAAAAA==.我不是电脑:BAAAKgADCgEIAQAAAA==.',['我是']='我是职业的:BAAAKgAECgYIBwAAAA==.',['我眼']='我眼睛有根毛:BAAAKgADCgEIAQAAAA==.',['我要']='我要粉碎你:BAAAKgAECgUIBQABKgAFFAEIAQACAAAAAA==.',['打出']='打出了翔:BAAAKgAECgUIBwAAAA==.',['打工']='打工靓仔:BAAAKgADCgQIBAAAAA==.',['拉普']='拉普兰德:BAABKgAFFH8VAAILAAYIYiIUCwDWAQALAAYIYiIUCwDWAQAAAA==.',['拽拽']='拽拽:BAAAKgADCgYIBgAAAA==.',['敖五']='敖五:BAAAKgADCggICAAAAA==.',['敖武']='敖武:BAAAKgAECgMIAwAAAA==.',['斌斌']='斌斌:BAABKgAFFH8aAAIBAAMIChekJADdAAABAAMIChekJADdAAAAAA==.',['断狡']='断狡:BAAAKgAECgMIAwAAAA==.',['斯卡']='斯卡雷特:BAABKgAFFH8HAAMIAAQIPQeJGgDCAAAIAAQIPQeJGgDCAAAHAAMIKwK5IgBJAAAAAA==.',['新任']='新任大酋长:BAAAKgADCgEIAQAAAA==.',['斷劍']='斷劍重鑄:BAAAKgAECgQIAwAAAA==.',['无上']='无上天火:BAAAKgADCggICAAAAA==.',['无敌']='无敌少女:BAAAKgAECgIIAgAAAA==.',['旺旺']='旺旺雪饼:BAAAKgAECgYIDQAAAA==.',['星火']='星火燃残念:BAABKgAFFH8KAAMEAAcIFBaXGAA3AQAEAAQIwR2XGAA3AQAFAAMI2AshNACiAAAAAA==.',['暴走']='暴走精灵:BAACKgAFFH8IAAMYAAYITBdHEgBUAQAYAAUI5hxHEgBUAQAXAAIIGQIGFgA7AAAqAAQKfxUAAhcABQhpB9SFAIQAABcABQhpB9SFAIQAAAAA.',['最后']='最后的死骑:BAAAKgAECgQIBAAAAA==.',['桂琴']='桂琴吖:BAACKgAFFH8IAAIUAAMIWhO4FACaAAAUAAMIWhO4FACaAAAqAAQKfzgAAxQACAgvHuoWABwCABQACAgvHuoWABwCABUABgg9BqdaAIMAAAAA.',['梦满']='梦满枝:BAACKgAFFH8VAAMWAAQIjhshFQDsAAAWAAQIjhshFQDsAAAUAAEI8QR6KAA1AAAqAAQKf0IAAxYACAitGrcYANUBABYACAhBGrcYANUBABQACAh0CW1KAOgAAAAA.',['樱羽']='樱羽兮墨:BAACKgAFFH8GAAIeAAIIhBK9DgCJAAAeAAIIhBK9DgCJAAAqAAQKfysABB4ACAh1HmYJAFUCAB4ACAh1HmYJAFUCAAEAAQj/BMGKASEAAAYAAQjBAcpjAAMAAAAA.',['橙毛']='橙毛黑熊:BAABKgAFFH8GAAIFAAYIORomEgBSAQAFAAYIORomEgBSAQABKgAFFAgIBAACAAAAAA==.',['步步']='步步生花:BAAAKgADCgcIBwAAAA==.',['武僧']='武僧大仙:BAAAKgAFFAIIAgAAAA==.',['段眉']='段眉:BAAAKgADCgMIAwAAAA==.',['永恒']='永恒之光:BAAAKgAFFAIIBAAAAA==.永恒的终结:BAAAKgAECgMIAwAAAA==.',['法仙']='法仙:BAAAKgAECgYICgAAAA==.',['清微']='清微天:BAAAKgAECgEIAQAAAA==.',['清风']='清风幽谷:BAAAKgAECgUIBwAAAA==.清风醉:BAAAKgAECggICAAAAA==.',['游城']='游城十代:BAAAKgAFFAYIBAAAAA==.',['源计']='源计划兽灵:BAAAKgAECgEIAQAAAA==.',['澜澜']='澜澜:BAAAKgAECgcIBwAAAA==.',['灬万']='灬万剑一:BAAAKgADCgQIBAAAAA==.',['烟斗']='烟斗客官:BAAAKgAECgUIBQAAAA==.',['熊熊']='熊熊:BAAAKgAECgYIBgAAAA==.',['熹楽']='熹楽:BAABKgAECn8oAAILAAgIgBgUJQDhAQALAAgIgBgUJQDhAQAAAA==.',['爆爆']='爆爆成年版:BAABKgAFFH8GAAIBAAQIGx+/GQAXAQABAAQIGx+/GQAXAQAAAA==.爆爆爱射击:BAAAKgAFFAgIBAAAAA==.',['爱上']='爱上客人的咕:BAAAKgAECgQICAAAAA==.',['牛犇']='牛犇牛犇:BAAAKgAECgQIBwAAAA==.',['狗一']='狗一样的:BAAAKgAECgIIAwAAAA==.',['王的']='王的唱响:BAAAKgADCggIDAAAAA==.',['用飘']='用飘柔洗脚:BAAAKgADCggICAABKgAFFAgICAAEAHMNAA==.',['疯癫']='疯癫大仙:BAAAKgAECggICgABKgAFFAYIFwAGABsRAA==.',['白上']='白上咲花:BAAAKgADCgIIAgAAAA==.',['看我']='看我干嘛看剑:BAAAKgAECgUIBQAAAA==.',['砖业']='砖业人士:BAAAKgADCggICAAAAA==.',['硝烟']='硝烟铁血呐喊:BAAAKgAECgQIBAAAAA==.',['碎魂']='碎魂米米:BAAAKgAFFAYIBAAAAA==.碎魂醚醚:BAAAKgAECggICAAAAA==.碎魂麋麋:BAABKgAFFH8GAAIQAAYIQAMgIQD1AAAQAAYIQAMgIQD1AAABKgAFFAgIDgAQABUPAA==.',['祖达']='祖达萨吴彦祖:BAAAKgAECgIIAgAAAA==.',['神父']='神父忽悠着你:BAAAKgAFFAgIBAAAAA==.',['神通']='神通大了去了:BAABKgAECn8XAAIQAAgIuBQhNgCdAQAQAAgIuBQhNgCdAQAAAA==.',['空刃']='空刃:BAACKgAFFH8iAAIIAAUIUh1UFQBxAQAIAAUIUh1UFQBxAQAqAAQKfxQAAggACAiJGqE5AMkBAAgACAiJGqE5AMkBAAAA.',['笑天']='笑天下:BAACKgAFFH8RAAMbAAgIFBuJAwBbAgAbAAgIcBqJAwBbAgAcAAMIcBR3CAC/AAAqAAQKfyoAAxwACAi3HmgIAG0CABwACAi3HmgIAG0CABsAAwggDT2eAEwAAAAA.',['第二']='第二个混子:BAAAKgAFFAEIAQAAAA==.',['简单']='简单玩得:BAAAKgAECgUIBQAAAA==.简单玩猎:BAACKgAFFH8IAAMFAAYITRcqAQC5AQAFAAYIyBYqAQC5AQAEAAIIcRm7NwCIAAAqAAQKfxgAAgQACAi/IXYiAGsCAAQACAi/IXYiAGsCAAEqAAUUCAgTAAQA5R0A.简单玩玩:BAABKgAFFH8LAAMeAAQI1xfGBgDjAAAeAAQI1xfGBgDjAAABAAQIlBDkJgDWAAAAAA==.',['米歇']='米歇尔的祝福:BAAAKgAECggIDQAAAA==.',['米洛']='米洛迦:BAABKgAECn8XAAIbAAgINRoaIQD+AQAbAAgINRoaIQD+AQAAAA==.',['纸伞']='纸伞:BAAAKgAECgUIBQAAAA==.',['给一']='给一个:BAAAKgAECgUIBQAAAA==.',['老大']='老大哈:BAAAKgADCggICAAAAA==.',['耳紅']='耳紅:BAAAKgAECgEIAQAAAA==.',['肉碎']='肉碎茄子:BAABKgAFFH8HAAIDAAYIRBpgAwDaAQADAAYIRBpgAwDaAQAAAA==.',['肥橘']='肥橘肥都嘟:BAAAKgAECgMIBQAAAA==.',['胖熊']='胖熊猫:BAABKgAFFH8IAAIXAAgIZQ72AgDmAQAXAAgIZQ72AgDmAQAAAA==.',['脱贫']='脱贫攻坚战:BAAAKgAFFAQIBAAAAA==.',['自带']='自带打蠢光环:BAAAKgADCgEIAQAAAA==.',['艾希']='艾希:BAAAKgADCggICAAAAA==.',['苏素']='苏素:BAABKgAFFH8GAAIBAAMIQCFzJgDYAAABAAMIQCFzJgDYAAAAAA==.',['苏肃']='苏肃:BAAAKgAFFAEIAQAAAA==.',['苦痛']='苦痛折磨:BAAAKgAECgYIEgAAAA==.',['萌兰']='萌兰:BAAAKgAECgMIAwAAAA==.',['萌家']='萌家轩宝:BAAAKgAFFAIIAgAAAA==.',['萌萌']='萌萌的小萝莉:BAAAKgADCgEIAQAAAA==.',['萤烛']='萤烛之火:BAAAKgADCgEIAQAAAA==.',['萨乐']='萨乐芬猫:BAAAKgADCgEIAQAAAA==.萨乐芬西:BAABKgAFFH8GAAIPAAYIBROzBwBmAQAPAAYIBROzBwBmAQAAAA==.',['蓝色']='蓝色海郁云烟:BAAAKgAFFAQIBAAAAA==.',['蓝调']='蓝调将夜:BAAAKgADCggICAAAAA==.',['虎杖']='虎杖丶悠仁:BAABKgAFFH8IAAIYAAgIigpECQDYAQAYAAgIigpECQDYAQAAAA==.',['虎生']='虎生:BAAAKgAECgMIAwAAAA==.',['蛋蛋']='蛋蛋:BAABKgAFFH8GAAISAAYItQkUDQA+AQASAAYItQkUDQA+AQAAAA==.',['衡山']='衡山客:BAAAKgAECgUIBQAAAA==.',['请叫']='请叫我骑士:BAACKgAFFH8XAAMGAAYIGxHjEwDaAAABAAMIqBl0HwDrAAAGAAYIzArjEwDaAAAqAAQKfxoAAwYACAg6HkAPAAgCAAYABwiAIEAPAAgCAAEABggUEUnCABcBAAAA.',['请正']='请正对目标:BAAAKgAECggIEAAAAA==.',['赤孔']='赤孔雀:BAAAKgAECgYIBgAAAA==.',['赫赫']='赫赫协调:BAABKgAFFH8IAAIBAAgIPRS1CwANAgABAAgIPRS1CwANAgAAAA==.',['走走']='走走道生啦:BAAAKgADCggIDQAAAA==.',['超凡']='超凡大仙:BAAAKgADCggIEAABKgAFFAYIFwAGABsRAA==.',['越共']='越共诱捕器:BAAAKgAECggIEwAAAA==.',['躺下']='躺下别动:BAAAKgAECgMIAwAAAA==.',['迷人']='迷人的洋葱头:BAAAKgADCgUIBQAAAA==.',['速度']='速度灭了:BAACKgAFFH8sAAMSAAgIVCGMAgBWAgASAAYI7CGMAgBWAgAOAAYIlyDkCgCdAQAqAAQKfzoAAxIACAiyJT4DAOACABIABwiyJT4DAOACAA4ABwjoITEuAM4BAAAA.',['邪能']='邪能信仰圣光:BAABKgAFFH8GAAIbAAYIvwoDHQAfAQAbAAYIvwoDHQAfAQAAAA==.',['都发']='都发地方:BAABKgAFFH8IAAINAAgIWBqtAgAbAgANAAgIWBqtAgAbAgAAAA==.',['酒魔']='酒魔德:BAABKgAECn8UAAMNAAgIHQkQRADTAAANAAcI+QkQRADTAAAMAAYIaAUUpACLAAAAAA==.',['阿修']='阿修罗攀打:BAAAKgAECggICgAAAA==.',['阿尼']='阿尼亚西亚:BAAAKgAECgYIBgAAAA==.',['随风']='随风飘无影:BAABKgAECn8UAAMLAAgIDQ5aIABCAQALAAgIDQ5aIABCAQATAAEIkAEnKwARAAAAAA==.',['雄库']='雄库鲁:BAAAKgAECgEIAgAAAA==.',['雨碎']='雨碎江南:BAAAKgAECgYIBgAAAA==.',['霜华']='霜华聚灵:BAAAKgADCggICAAAAA==.',['青彦']='青彦:BAABKgAFFH8OAAMIAAYImSN5CwDWAQAIAAYImSN5CwDWAQAfAAIIoROyBwBTAAAAAA==.',['頭上']='頭上长犄角:BAAAKgAECgYIBgABKgAFFAEIAQACAAAAAA==.',['风暴']='风暴要火:BAAAKgAFFAEIAwAAAA==.',['马刹']='马刹拉地:BAAAKgADCggIEAAAAA==.',['高耸']='高耸的菠萝:BAABKgAFFH8PAAIDAAQInh8LEQAPAQADAAQInh8LEQAPAQAAAA==.',['鲀鲀']='鲀鲀:BAABKgAFFH8GAAIgAAYI4AR7EQA5AQAgAAYI4AR7EQA5AQAAAA==.',['鲨鱼']='鲨鱼宝宝:BAAAKgADCgcIBwAAAA==.鲨鱼潮汐:BAAAKgAECggICgAAAA==.',['鸭一']='鸭一样的:BAAAKgAECgMIBwAAAA==.',['麦兜']='麦兜神话:BAAAKgAECgMIAwAAAA==.',['麻哥']='麻哥自有妙计:BAAAKgAECggIEAAAAA==.',['黑缎']='黑缎:BAAAKgAECggICAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end