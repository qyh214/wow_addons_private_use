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
 local lookup = {'Priest-Shadow','Priest-Holy','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','Rogue-Assassination','DeathKnight-Unholy','Paladin-Protection','DemonHunter-Vengeance','Warrior-Fury','Mage-Frost','Monk-Mistweaver','Shaman-Elemental','Monk-Windwalker','Paladin-Retribution','Shaman-Enhancement','DeathKnight-Frost','DemonHunter-Havoc','Evoker-Devastation','Warrior-Arms','Druid-Balance','Druid-Feral','Warlock-Demonology','Warlock-Destruction','Priest-Discipline','Rogue-Subtlety','Warlock-Affliction','Mage-Arcane','Mage-Fire','Druid-Restoration','Paladin-Holy','Druid-Guardian','Unknown-Unknown','DeathKnight-Blood','Monk-Brewmaster','Rogue-Outlaw',}; local provider = {region='CN',realm='纳克萨玛斯',name='CN',type='weekly',zone=42,date='2025-08-08',data={Al='Alvina:BAABKgAFFH8IAAMBAAgIwRBqBwCtAQABAAcIlA5qBwCtAQACAAEIDgsDHwBCAAAAAA==.',An='Angèlia:BAAAKgAFFAgIBAAAAA==.',Ar='Archmage:BAAAKgAECggIEwAAAA==.',Ax='Axiaoai:BAAAKgAFFAIIAwAAAA==.',Bi='Biglottery:BAABKgAECn8pAAMDAAgIyB88FwB2AgADAAgIyB88FwB2AgAEAAMIegKrhQA/AAAAAA==.',Ee='Ee:BAABKgAFFH8HAAIFAAQIvQ1mGwCzAAAFAAQIvQ1mGwCzAAABKgAFFAgICgAFAIwWAA==.',En='Enchantment:BAABKgAECn8aAAIGAAgIjRayBgD2AQAGAAgIjRayBgD2AQAAAA==.',Fe='Felicia:BAAAKgAFFAQIBAAAAA==.',Gr='Groupiesl:BAAAKgAFFAYIAgAAAA==.',Ha='Hardcandy:BAABKgAFFH8UAAMEAAgI8RZqAQCpAQADAAgIUBRzCADxAQAEAAYIChpqAQCpAQAAAA==.',Lo='Loveisover:BAABKgAFFH8KAAIHAAgIbSIQAwCWAgAHAAgIbSIQAwCWAgAAAA==.',Lr='Lrszm:BAAAKgAFFAMIAQAAAA==.',Mo='Morphohelena:BAABKgAECn8aAAIIAAgI/hKDGgCPAQAIAAgI/hKDGgCPAQABKgAECggIJQAJAGQbAA==.',No='Nomushroom:BAABKgAFFH8GAAIIAAQIhxOpCADXAAAIAAQIhxOpCADXAAAAAA==.',Oi='Oi:BAAAKgAECggIEAAAAA==.',Pi='Pino:BAAAKgAFFAYIAgAAAA==.',Pp='Ppower:BAAAKgAECgQIBQAAAA==.',Ri='Rita:BAAAKgADCgEIAQAAAA==.',Se='Seath:BAAAKgAECgcIEgAAAA==.',Sh='Shootingstar:BAABKgAFFH8IAAIKAAgIfwWTCQChAQAKAAgIfwWTCQChAQAAAA==.',Sn='Snadow:BAAAKgADCggICAAAAA==.',Sp='Spellbreake:BAABKgAECn8eAAILAAgIah7mDwBMAgALAAgIah7mDwBMAgAAAA==.Spiritwolf:BAAAKgAECgEIAQAAAA==.',St='Staylol:BAAAKgAECgUIBQAAAA==.',Te='Terryvit:BAACKgAFFH8GAAIMAAIILgk8JAB1AAAMAAIILgk8JAB1AAAqAAQKfxkAAgwACAigFhgqALABAAwACAigFhgqALABAAAA.',Tn='Tneisnart:BAACKgAFFH8eAAINAAcI5BcLCABUAQANAAcI5BcLCABUAQAqAAQKfxgAAg0ACAgVIWsLAJYCAA0ACAgVIWsLAJYCAAAA.',Tu='Turbocharger:BAAAKgAECggIEAAAAA==.',Xi='Xiilina:BAAAKgAECgUIBQAAAA==.',['三代']='三代目前男友:BAABKgAFFH8NAAIOAAQIshLWCwDeAAAOAAQIshLWCwDeAAAAAA==.',['专业']='专业卖萌:BAAAKgAECggIBgAAAA==.',['丨寻']='丨寻找妹妹丨:BAAAKgADCgEIAQAAAA==.',['丨粒']='丨粒蛋卤疯:BAAAKgADCggIEAAAAA==.',['丶小']='丶小狐狸丶:BAAAKgADCgEIAQAAAA==.',['丶谁']='丶谁的:BAAAKgAFFAcIAgAAAA==.',['丷王']='丷王子丷:BAABKgAFFH8GAAIPAAYICR78EQDNAQAPAAYICR78EQDNAQAAAA==.',['丿酒']='丿酒仙丨傻馒:BAAAKgAECgIIAgAAAA==.',['乐盈']='乐盈玲:BAAAKgAECgEIAQAAAA==.',['二十']='二十四个圣骑:BAAAKgAECgcIBwAAAA==.二十四个萨满:BAACKgAFFH8KAAIQAAYICwtxCQA/AQAQAAYICwtxCQA/AQAqAAQKfx8ABBAACAgXGLoZAPwBABAACAi2FroZAPwBAAUACAgwE0Q5AKEBAA0ACAhcETgzAHMBAAEqAAUUCAgLAAUA/iMA.',['亲爱']='亲爱哒丶:BAAAKgAECggICgAAAA==.',['仁醫']='仁醫:BAABKgAECn8sAAMHAAgIHhkdLAAFAgAHAAgIHhkdLAAFAgARAAQIawyPJQCSAAAAAA==.',['伊利']='伊利安慕希:BAAAKgAECgYIBgAAAA==.',['伊吏']='伊吏丹怒风:BAAAKgAFFAIIAgAAAA==.',['伊立']='伊立丹怒风:BAABKgAFFH8QAAISAAYI3g9FGgAsAQASAAYI3g9FGgAsAQAAAA==.',['优雅']='优雅的小莉莉:BAAAKgADCgMIAwAAAA==.',['俾面']='俾面派对:BAAAKgAECgIIAgAAAA==.',['偏要']='偏要吃兔兔丶:BAAAKgAECggICAAAAA==.',['傲天']='傲天丶:BAAAKgADCgQIBAAAAA==.',['像疯']='像疯一样丷:BAAAKgAECgYIBgAAAA==.',['元素']='元素之舞:BAAAKgAFFAEIAQAAAA==.',['兄弟']='兄弟盟血羽:BAAAKgAECgQIBQAAAA==.',['光之']='光之挽歌:BAAAKgAECggICAAAAA==.',['光猫']='光猫:BAABKgAFFH8WAAIPAAMIbRljQADwAAAPAAMIbRljQADwAAAAAA==.',['光脚']='光脚丫:BAAAKgAECgQIBAAAAA==.',['冰封']='冰封夜影:BAAAKgAECgEIAQAAAA==.',['冰镇']='冰镇零度:BAAAKgAECgMIAwAAAA==.',['冲锋']='冲锋释放:BAAAKgAFFAgIBAAAAA==.',['刘老']='刘老胖:BAABKgAFFH8IAAIFAAQIZQ8BFQDRAAAFAAQIZQ8BFQDRAAAAAA==.',['办事']='办事:BAAAKgAECgUIBQAAAA==.',['加糖']='加糖加醋:BAABKgAECn8dAAITAAgIPBXiHADUAQATAAgIPBXiHADUAQAAAA==.',['劣人']='劣人:BAAAKgADCgEIAQAAAA==.',['勇敢']='勇敢的牛仔:BAABKgAFFH8OAAMKAAgI8B9uAwB4AgAKAAgIeB9uAwB4AgAUAAIIZh+WGQC+AAAAAA==.',['千于']='千于千寻:BAAAKgAECgIIAgAAAA==.',['半支']='半支烟:BAAAKgADCggICAAAAA==.',['卡布']='卡布奇诺德:BAABKgAECn8gAAMVAAgIoho5JgAeAgAVAAgIoho5JgAeAgAWAAgIYggmGQABAQAAAA==.',['压脉']='压脉带思密达:BAABKgAFFH8IAAILAAgIsQ3pAgDuAQALAAgIsQ3pAgDuAQAAAA==.',['古神']='古神之躯:BAAAKgADCggICAAAAA==.',['吃我']='吃我一逼兜:BAAAKgAECgEIAgAAAA==.',['各种']='各种闪避:BAAAKgADCgYIBwAAAA==.',['吸烟']='吸烟有害健康:BAAAKgAECggIDQAAAA==.',['吸血']='吸血鬼丶莱恩:BAAAKgADCgMIAwAAAA==.',['呼啦']='呼啦:BAABKgAFFH8RAAMBAAYIDg33DADrAAABAAUIfwz3DADrAAACAAQI3hC2EADFAAABKgAFFAcIHgANAOQXAA==.',['哈巴']='哈巴罗夫斯克:BAABKgAFFH8GAAMXAAYIQxS6BwAAAQAXAAUIcRW6BwAAAQAYAAEIiQ+ySgBCAAAAAA==.',['啊哒']='啊哒哒:BAAAKgAECgQIBQAAAA==.',['啸骜']='啸骜:BAAAKgAFFAUIBAAAAA==.',['喂我']='喂我花生:BAAAKgAECgQIBAAAAA==.',['嘎拉']='嘎拉哈儿丶:BAAAKgAFFAQIBAAAAA==.',['四四']='四四飚:BAAAKgAFFAIIAgAAAA==.',['圆圆']='圆圆的阿宝:BAABKgAFFH8GAAIOAAYIow7zCABcAQAOAAYIow7zCABcAQAAAA==.',['圣佛']='圣佛魔心:BAAAKgADCgQIBAAAAA==.',['圣光']='圣光小莉莉:BAAAKgAECgEIAQAAAA==.',['圣女']='圣女萨拉:BAAAKgAECggICAAAAA==.',['塞尔']='塞尔达:BAAAKgAECgYIBgAAAA==.',['墓穴']='墓穴之寒:BAAAKgAECgYIBgAAAA==.',['墨雨']='墨雨:BAAAKgAECgEIAwAAAA==.',['夏丶']='夏丶目:BAAAKgAFFAQIBAAAAA==.',['外法']='外法狂徒:BAAAKgADCgQIBAAAAA==.',['夜尽']='夜尽天明丶丶:BAABKgAFFH8LAAIPAAMIzRewUADOAAAPAAMIzRewUADOAAAAAA==.',['夜菲']='夜菲风婉婉:BAAAKgADCgYIBgAAAA==.',['大口']='大口吃瓜瓜:BAAAKgAECgEIAQAAAA==.',['大海']='大海里摸鱼:BAAAKgADCgIIAgAAAA==.',['大猫']='大猫爱吃鱼:BAAAKgADCgYIBgAAAA==.',['大白']='大白兔刘奶糖:BAABKgAFFH8OAAMCAAgIyhDjCACXAQACAAcIQxDjCACXAQABAAYILRSLBACAAQAAAA==.',['大米']='大米稀饭:BAAAKgAECgMIAwAAAA==.',['大风']='大风吹过:BAAAKgAECggIEQAAAA==.',['天岚']='天岚小师妹:BAAAKgAECgcIDwAAAA==.',['天气']='天气晚来秋丷:BAAAKgAFFAQIBAAAAA==.',['失落']='失落的灵魂:BAABKgAFFH8GAAILAAYI3Q7MBwBHAQALAAYI3Q7MBwBHAQAAAA==.',['夺命']='夺命踢:BAAAKgAFFAIIAgAAAA==.',['奇术']='奇术之仕:BAAAKgADCgMIAwAAAA==.',['奈斯']='奈斯:BAAAKgAECggIDAAAAA==.',['奶到']='奶到爆:BAAAKgADCggIEAAAAA==.',['奶思']='奶思兔咪特悠:BAABKgAECn8bAAIPAAgIIxccHwDEAQAPAAgIIxccHwDEAQAAAA==.',['奶糖']='奶糖丶:BAABKgAFFH8GAAIZAAYIyhgwCACeAQAZAAYIyhgwCACeAQAAAA==.',['好欢']='好欢螺:BAAAKgAECgIIAgAAAA==.',['妳丶']='妳丶我见犹怜:BAABKgAFFH8OAAIDAAcIHxvLBgAaAgADAAcIHxvLBgAaAgAAAA==.',['妹子']='妹子你站住丷:BAAAKgAECgcIBwAAAA==.',['姿态']='姿态决定成败:BAAAKgAFFAEIAgAAAA==.',['娜尔']='娜尔妮莎:BAAAKgADCggICgAAAA==.',['孤独']='孤独的刺客:BAABKgAFFH8GAAIGAAYIUhDHDQBzAQAGAAYIUhDHDQBzAQAAAA==.',['寂于']='寂于冲锋:BAAAKgAECgcIBwAAAA==.',['富婆']='富婆抱抱我:BAAAKgAECggIDwAAAA==.',['寻找']='寻找妹妹:BAAAKgAECgIIAgAAAA==.',['射死']='射死你丫:BAAAKgADCgEIAQAAAA==.',['小师']='小师妹:BAAAKgADCgcIBwAAAA==.',['小斑']='小斑爱睡觉:BAAAKgAECggIEgAAAA==.',['小棉']='小棉花餹:BAAAKgADCggICAAAAA==.',['小泽']='小泽莜沐风:BAAAKgAECgcIDQAAAA==.',['小熊']='小熊雪碧:BAAAKgAFFAEIAQAAAA==.',['小牛']='小牛翘尾巴:BAAAKgAFFAgIBAAAAA==.',['小航']='小航与大鹏:BAAAKgAECggIBgAAAA==.',['小花']='小花生:BAABKgAFFH8PAAIIAAYIuxfrCAB2AQAIAAYIuxfrCAB2AQAAAA==.',['少麻']='少麻少辣:BAAAKgAFFAIIAQAAAA==.',['尛二']='尛二花丨同学:BAAAKgAECgEIAQAAAA==.',['尼古']='尼古拉斯翠花:BAAAKgADCgIIAgAAAA==.',['山岳']='山岳之力:BAAAKgAECggICAAAAA==.',['巜萨']='巜萨尓瓦多:BAAAKgAFFAgIAgAAAA==.',['巨棒']='巨棒刺喉:BAABKgAECn8WAAMPAAgIjhOCigCCAQAPAAcIwBaCigCCAQAIAAEIZAAAAAAAAAAAAA==.',['帅逼']='帅逼丶:BAABKgAFFH8IAAIPAAQI5CC2NwAMAQAPAAQI5CC2NwAMAQAAAA==.',['帖拉']='帖拉所伊朵:BAAAKgAECgYIDwAAAA==.',['幸运']='幸运术:BAAAKgAECggIDgAAAA==.',['幻想']='幻想悲伤:BAAAKgAECgIIAgAAAA==.',['張珍']='張珍宝:BAAAKgADCggIEAAAAA==.',['彡影']='彡影丶末日灬:BAAAKgADCgMIBQAAAA==.彡影丶行者灬:BAAAKgAECggICQAAAA==.彡影丶逐风灬:BAAAKgADCgMIAwAAAA==.',['微醺']='微醺的小莉莉:BAAAKgAECgQIBAAAAA==.',['德弗']='德弗罗雯可:BAAAKgAECgUIBQAAAA==.',['德鲁']='德鲁牛:BAAAKgADCgcIBwAAAA==.',['心怀']='心怀众生丶:BAAAKgAECgQIAwAAAA==.',['忆血']='忆血蹄之白虎:BAAAKgADCgEIAQAAAA==.',['怒冠']='怒冠为红颜:BAAAKgAFFAYIAwAAAA==.',['恨之']='恨之灰烬:BAAAKgAFFAQIBAAAAA==.',['恶魔']='恶魔在背后:BAABKgAECn8ZAAMGAAgIgxVRGACoAQAGAAgIoxFRGACoAQAaAAYIqRKQBAANAQAAAA==.恶魔小东东:BAAAKgAECgEIAQAAAA==.',['悠悠']='悠悠小凡:BAABKgAECn8wAAQYAAgIfhxbBgBIAgAYAAgIxRtbBgBIAgAXAAgI/RbzEgDtAQAbAAEIrBgFGQBHAAAAAA==.悠悠萌宝宝:BAABKgAECn8ZAAIDAAgIoR9pCgBtAgADAAgIoR9pCgBtAgAAAA==.',['愤怒']='愤怒的圣光:BAAAKgAFFAMIAgAAAA==.',['我去']='我去买俩橘子:BAAAKgAFFAIIAgAAAA==.',['我和']='我和你拼了:BAAAKgADCggICQAAAA==.',['我要']='我要去远方:BAABKgAFFH8YAAQcAAMIgho3IQDiAAAcAAMIcxg3IQDiAAALAAII7hp0HQCZAAAdAAEIpw8YPABEAAAAAA==.',['我还']='我还要去远方:BAABKgAFFH8FAAIEAAMIAhHNGgCUAAAEAAMIAhHNGgCUAAABKgAFFAgICAADAHMNAA==.',['战争']='战争牛牛:BAAAKgADCggICAAAAA==.',['戰骑']='戰骑:BAAAKgAECgYIBgAAAA==.',['把嘴']='把嘴给我闭上:BAAAKgAFFAQIBAAAAA==.',['抠死']='抠死你:BAAAKgADCgMIAwAAAA==.',['拉咘']='拉咘拉多警长:BAABKgAFFH8IAAMaAAUIbxdvCgC5AAAaAAMIOhJvCgC5AAAGAAIIpRz5EACpAAAAAA==.',['挣扎']='挣扎的煎饼果:BAAAKgAECgcICAAAAA==.',['改名']='改名会变好运:BAAAKgAFFAgIAgAAAA==.',['文豪']='文豪野犬:BAAAKgAECgMIAwAAAA==.',['斌歌']='斌歌:BAABKgAECn81AAILAAgIrSErCgCSAgALAAgIrSErCgCSAgAAAA==.',['无尽']='无尽的回忆:BAACKgAFFH8MAAMeAAMIkA0IJACWAAAeAAMIkA0IJACWAAAVAAMIXwKLTwB4AAAqAAQKfxsAAh4ACAhqHiAGADYCAB4ACAhqHiAGADYCAAAA.',['无悔']='无悔的天使:BAAAKgAECggIAgAAAA==.',['无辜']='无辜者悼词:BAABKgAECn8kAAQPAAgIfyEXCQCuAgAPAAgIfyEXCQCuAgAIAAcIgAMIPwCGAAAfAAEI7QwbJAAwAAAAAA==.',['昕夜']='昕夜:BAAAKgAECgMIAwAAAA==.',['暗行']='暗行狱史:BAABKgAFFH8KAAIEAAMIXQxyMgCnAAAEAAMIXQxyMgCnAAAAAA==.',['曼尼']='曼尼猎血:BAABKgAFFH8IAAIeAAYIlxy7BwCSAQAeAAYIlxy7BwCSAQAAAA==.',['月婵']='月婵:BAAAKgADCgcICAAAAA==.',['月影']='月影寒:BAAAKgAECggIDgAAAA==.',['有火']='有火没烟:BAAAKgAFFAQIBAABKgAFFAgIFgAHAGsZAA==.',['有烟']='有烟没火:BAABKgAFFH8IAAIDAAQI8Bq0KgDaAAADAAQI8Bq0KgDaAAAAAA==.',['杨开']='杨开程:BAABKgAFFH8IAAIPAAgIaxhQBgBmAgAPAAgIaxhQBgBmAgAAAA==.',['林楚']='林楚瑶:BAAAKgAECgEIAQAAAA==.',['林沐']='林沐儿:BAABKgAFFH8WAAQIAAgIURZWBQDmAQAIAAgIwhVWBQDmAQAPAAMIUxlhQgDrAAAfAAII9xOeDACZAAAAAA==.',['林阿']='林阿瑶:BAABKgAFFH8JAAIgAAMIWgdWCgBsAAAgAAMIWgdWCgBsAAAAAA==.',['枫粼']='枫粼:BAAAKgAECgMIAwAAAA==.',['桃子']='桃子哥:BAABKgAFFH8OAAIEAAYIfSALCgC2AQAEAAYIfSALCgC2AQAAAA==.',['桃气']='桃气泡泡:BAAAKgAECggIDAAAAA==.',['橙天']='橙天捣蛋:BAAAKgAECgQIBQAAAA==.',['欧文']='欧文:BAABKgAFFH8JAAMFAAcIPBdBDQB5AQAFAAQIxBxBDQB5AQANAAMInx4vDQACAQAAAA==.',['死亡']='死亡皛骑士:BAAAKgADCgEIAQAAAA==.',['死神']='死神的拥抱:BAABKgAFFH8FAAICAAUIJAW/IQC/AAACAAUIJAW/IQC/AAAAAA==.死神阿信:BAAAKgADCggICAAAAA==.',['殇之']='殇之寳寳:BAAAKgAECggIEAAAAA==.',['气定']='气定乾坤:BAAAKgAECggIDgAAAA==.',['水无']='水无忧:BAAAKgADCggICAAAAA==.',['水灵']='水灵依素:BAABKgAFFH8OAAQZAAYIIx2+EwD6AAAZAAQI2CK+EwD6AAACAAQIPwjKEAC7AAABAAIIGCE1FQC6AAAAAA==.',['沁天']='沁天一指:BAABKgAFFH8IAAMPAAcIoR0DFAC8AQAPAAYIcR8DFAC8AQAIAAEIkRSOFABAAAAAAA==.',['沂水']='沂水舞雩:BAABKgAFFH8IAAIfAAgIfwkwBACjAQAfAAgIfwkwBACjAQAAAA==.',['沃日']='沃日:BAABKgAFFH8IAAIcAAgICQnMCwCaAQAcAAgICQnMCwCaAQAAAA==.',['沐澄']='沐澄:BAAAKgAFFAQIBAAAAA==.',['沙加']='沙加:BAAAKgADCgQIBAAAAA==.',['没有']='没有狐臭丶:BAAAKgADCggIDAAAAA==.',['没梦']='没梦想的咸鱼:BAACKgAFFH8KAAIdAAMIbyJKEAAUAQAdAAMIbyJKEAAUAQAqAAQKfy8AAh0ACAj8JAIEAPUCAB0ACAj8JAIEAPUCAAAA.',['法琳']='法琳娜:BAACKgAFFH8lAAILAAUIZxNZDQDAAAALAAUIZxNZDQDAAAAqAAQKfyQAAgsACAg7GoUXAPsBAAsACAg7GoUXAPsBAAAA.',['流羽']='流羽:BAABKgAFFH8QAAMVAAMIOBZ+GgDVAAAVAAMIOBZ+GgDVAAAeAAIINgQFHQBhAAAAAA==.',['浊心']='浊心:BAAAKgADCgcIBwAAAA==.',['浓沃']='浓沃:BAABKgAFFH8MAAMLAAYIAyKMAwDCAQALAAYIAyKMAwDCAQAdAAYIUBA8DgBZAQAAAA==.',['浮屠']='浮屠半生缘:BAABKgAECn8XAAIPAAgIoCLNRwAYAgAPAAgIoCLNRwAYAgAAAA==.',['海滨']='海滨小城:BAAAKgAECgIIAgAAAA==.',['涟漪']='涟漪之秀:BAABKgAFFH8LAAIPAAMIFgVBZwCfAAAPAAMIFgVBZwCfAAAAAA==.',['清澈']='清澈的时光:BAAAKgAFFAYIBAABKgAFFAgIBAAhAAAAAA==.',['温水']='温水天爱星:BAAAKgAFFAQIBAAAAA==.温水小鞠:BAAAKgAECgQIBAAAAA==.温水杏菜:BAAAKgAECgYIBgAAAA==.',['温蒂']='温蒂:BAAAKgADCggICAAAAA==.',['潇洒']='潇洒哥:BAAAKgADCgEIAQAAAA==.',['潇然']='潇然丶:BAABKgAFFH8IAAMeAAQISxVJFQCJAAAeAAMIixdJFQCJAAAVAAIIbx9hNwBEAAAAAA==.',['火腿']='火腿炒饭丶:BAAAKgADCggICwAAAA==.',['火虫']='火虫:BAAAKgAFFAgIBAAAAA==.',['灬佬']='灬佬龍乤灬:BAABKgAFFH8FAAIYAAMIJAIIQABsAAAYAAMIJAIIQABsAAAAAA==.',['灬冰']='灬冰丨封灬:BAAAKgAECggICAAAAA==.',['灬稀']='灬稀飯灬:BAAAKgAECgIIAgAAAA==.',['灬聖']='灬聖魅灬:BAAAKgAECgEIAQAAAA==.',['灰色']='灰色心情:BAABKgAFFH8GAAIPAAYIbx1yGQCTAQAPAAYIbx1yGQCTAQAAAA==.',['烈酒']='烈酒暖心:BAABKgAFFH8JAAISAAgISRQCCgDtAQASAAgISRQCCgDtAQAAAA==.',['烈风']='烈风疾炎:BAAAKgAECgYIBgAAAA==.',['烤冷']='烤冷面不加蛋:BAAAKgAFFAYIBAAAAA==.',['熊先']='熊先僧:BAACKgAFFH8HAAMMAAQI8RElEwDXAAAMAAQI8RElEwDXAAAOAAEIpAEWIgA0AAAqAAQKfxgAAgwACAgiIjsKAJ0CAAwACAgiIjsKAJ0CAAAA.',['熊杨']='熊杨:BAAAKgAFFAYIBAAAAA==.',['爱就']='爱就这么简单:BAAAKgAFFAgIAwAAAA==.',['爱跳']='爱跳舞的熊熊:BAAAKgAECgMIBgAAAA==.',['牧牧']='牧牧慕慕:BAAAKgAFFAIIAgABKgAFFAQIAwAhAAAAAA==.牧牧沐沐:BAAAKgAFFAQIAwAAAA==.',['牧野']='牧野:BAABKgAFFH8MAAMZAAYIWiPYBQA2AQAZAAUIXCPYBQA2AQABAAIIihsgHQCdAAAAAA==.',['猎猎']='猎猎黑巧:BAACKgAFFH8RAAMDAAYIthsDEAB6AQADAAUIdiADEAB6AQAEAAEItAjuTwA+AAAqAAQKfxwAAgMACAjqIv4SAJICAAMACAjqIv4SAJICAAAA.',['猫叔']='猫叔唉:BAACKgAFFH8bAAIDAAMIxiPMDQAYAQADAAMIxiPMDQAYAQAqAAQKfyUAAgMACAhRIEckAGMCAAMACAhRIEckAGMCAAAA.',['猫哥']='猫哥:BAAAKgAECggIEgAAAA==.',['玛林']='玛林:BAAAKgADCgUIBQAAAA==.',['玩闹']='玩闹烟斗:BAAAKgAFFAMIAwAAAA==.',['甜甜']='甜甜:BAABKgAFFH8RAAMCAAMIUhtjHQDWAAACAAMIUhtjHQDWAAAZAAEIzgnlKQA8AAABKgAFFAgIEAAVADgWAA==.',['电离']='电离:BAABKgAFFH8IAAIDAAgIdAmuCQDDAQADAAgIdAmuCQDDAQAAAA==.',['疯狂']='疯狂的小柿饼:BAAAKgAECgMIAwAAAA==.',['疾風']='疾風月影:BAABKgAFFH8HAAMVAAUI7RDxEQDyAAAVAAQIexHxEQDyAAAeAAMI3AT8HQBaAAAAAA==.',['疾风']='疾风剑濠:BAAAKgADCggICAAAAA==.',['痴道']='痴道:BAAAKgAECggIEwAAAA==.',['白無']='白無常:BAAAKgAFFAcIBAAAAA==.',['白色']='白色乐章:BAAAKgAECggIEwAAAA==.',['白虎']='白虎颚小莉莉:BAAAKgAECgMIAwAAAA==.',['皮皮']='皮皮大领主:BAAAKgAFFAgIBAAAAA==.皮皮迪凯:BAABKgAFFH8RAAMHAAgIcRVABQBPAgAHAAgIcRVABQBPAgAiAAQIOhjAHQC1AAAAAA==.',['祈求']='祈求者马兰:BAAAKgADCgIIAgAAAA==.',['神圣']='神圣干涉:BAACKgAFFH8GAAMIAAUI/A3aCAAdAQAIAAUI/A3aCAAdAQAPAAEI/wVzjQA3AAAqAAQKfyAAAg8ACAizI38TAMkCAA8ACAizI38TAMkCAAAA.',['神明']='神明灵:BAAAKgAECggIDgAAAA==.',['移动']='移动奶瓶:BAABKgAFFH8PAAMFAAgIHBMFBgApAQAFAAgIHBMFBgApAQANAAMIjgpiIQB0AAAAAA==.',['立秋']='立秋:BAAAKgAECggIDAAAAA==.',['精卫']='精卫丶:BAAAKgAFFAYIBAAAAA==.',['紫月']='紫月凌风:BAAAKgAECgYIDAAAAA==.',['繁星']='繁星:BAAAKgAFFAgIBAAAAA==.',['红手']='红手小蹄子:BAABKgAFFH8IAAMPAAYI3w5PJABaAQAPAAYI3w5PJABaAQAIAAIIVQH7FAA6AAAAAA==.',['绫波']='绫波丽:BAAAKgAECgYICQAAAA==.',['绿和']='绿和尚:BAAAKgADCgQIBAAAAA==.',['绿小']='绿小野:BAABKgAFFH8GAAIMAAYIsxKMDQBLAQAMAAYIsxKMDQBLAQAAAA==.',['老东']='老东西杨永信:BAAAKgAECggIEQAAAA==.',['聆听']='聆听你的声音:BAAAKgAECgMIAwAAAA==.',['聖光']='聖光祈願:BAABKgAFFH8OAAIfAAgIqxNrAgAhAgAfAAgIqxNrAgAhAgAAAA==.',['肥喵']='肥喵不养鱼:BAAAKgAFFAQIBAAAAA==.',['胆怯']='胆怯的乌索普:BAAAKgAECgcIBwAAAA==.',['胡小']='胡小飒:BAAAKgAECgMIAwAAAA==.',['胡萝']='胡萝卜酱:BAAAKgAECgIIAgAAAA==.',['致命']='致命童话:BAAAKgAECggICAAAAA==.',['艾欧']='艾欧尼亚:BAACKgAFFH8JAAIDAAQIAR+gHgAUAQADAAQIAR+gHgAUAQAqAAQKfxUAAwMACAgHIKkSAJQCAAMACAgHIKkSAJQCAAQABggSByNYAL4AAAEqAAUUCAgNAB4A7RwA.',['芒果']='芒果养乐多:BAAAKgAECgYICQAAAA==.芒果欧蕾:BAABKgAECn8XAAIKAAgI1RcULQDTAQAKAAgI1RcULQDTAQAAAA==.',['芝芝']='芝芝芒芒:BAAAKgAECgUIAgAAAA==.',['花妙']='花妙汐:BAAAKgAFFAIIAgAAAA==.',['花开']='花开灬富贵:BAAAKgAECgIIAgAAAA==.',['花泽']='花泽香菜:BAABKgAFFH8HAAIPAAQIxBfCIADlAAAPAAQIxBfCIADlAAAAAA==.',['草原']='草原牛王:BAABKgAFFH8HAAMKAAMIdgVdMgBkAAAKAAIIPwZdMgBkAAAUAAII7ANlLAA1AAAAAA==.',['莎莎']='莎莎酱:BAABKgAFFH8FAAMZAAUIIRfFFQCxAAAZAAQIUBTFFQCxAAABAAEIjBqsIQBWAAAAAA==.',['萌囡']='萌囡囡:BAAAKgAECgMIAwAAAA==.',['萨达']='萨达萨达:BAAAKgAECgMIAwAAAA==.',['落花']='落花劶:BAABKgAFFH8IAAIeAAQI6QiGEQCJAAAeAAQI6QiGEQCJAAAAAA==.',['落辞']='落辞:BAAAKgAFFAQIBAAAAA==.',['蓝色']='蓝色大海传说:BAABKgAFFH8OAAISAAgIzhNZBwAkAgASAAgIzhNZBwAkAgAAAA==.',['蚀魂']='蚀魂狂魔:BAAAKgAFFAEIAQAAAA==.',['蛋上']='蛋上二两灰:BAAAKgADCggIEAAAAA==.',['血夜']='血夜红魔:BAACKgAFFH8FAAIYAAMIqA01MgCmAAAYAAMIqA01MgCmAAAqAAQKfy4AAxgACAg4GIwgAAECABgACAg4GIwgAAECABcAAQgLEZF/AC4AAAAA.',['血战']='血战八方:BAAAKgADCgIIAgAAAA==.',['血斩']='血斩丶沸:BAAAKgAECgYICAAAAA==.',['西农']='西农九七九:BAAAKgAECggIEAAAAA==.',['西虹']='西虹市首富:BAAAKgADCgYIBgAAAA==.',['西门']='西门达莱:BAACKgAFFH8EAAIPAAQIjxfMVwDBAAAPAAQIjxfMVwDBAAAqAAQKfykAAw8ACAg8IisWAK8CAA8ACAg8IisWAK8CAB8AAQg+ALFYAAoAAAAA.',['请叫']='请叫我灰太狼:BAAAKgAFFAMIAwAAAA==.',['诸神']='诸神灬黄昏:BAAAKgAECgQIBAAAAA==.',['谦玉']='谦玉:BAAAKgAECgUIBQAAAA==.',['谨防']='谨防上当:BAABKgAFFH8HAAIYAAQIGQ5EGAC9AAAYAAQIGQ5EGAC9AAABKgAFFAgIBgAbAGobAA==.',['贪婪']='贪婪小宇:BAAAKgAECggICQAAAA==.',['赛琳']='赛琳娜法法:BAAAKgAECgQIBAAAAA==.',['赫塞']='赫塞汀:BAABKgAFFH8IAAIHAAIIlAhESgB4AAAHAAIIlAhESgB4AAAAAA==.',['超级']='超级小黄人:BAAAKgAECgYICQAAAA==.',['辣目']='辣目桃子:BAABKgAFFH8YAAQOAAgI9xEaBQDoAQAOAAgI9xEaBQDoAQAjAAQI2BjyAgDXAAAMAAMIyQTSJwBVAAAAAA==.',['近战']='近战五码分散:BAACKgAFFH8eAAIIAAYIUh8QAwAfAgAIAAYIUh8QAwAfAgAqAAQKfx0AAggACAjPJAcCAO8CAAgACAjPJAcCAO8CAAAA.',['迷迭']='迷迭香:BAABKgAFFH8GAAIYAAYIxhcqAgDBAQAYAAYIxhcqAgDBAQAAAA==.',['遗忘']='遗忘的背叛者:BAAAKgAECgUIBQAAAA==.',['邪魂']='邪魂丶:BAAAKgADCgQIBAAAAA==.',['醉卧']='醉卧看斜阳:BAABKgAFFH8IAAMGAAMIVweFJACDAAAGAAII8gmFJACDAAAkAAIIuQJYCwBDAAAAAA==.',['野猫']='野猫贼:BAABKgAFFH8HAAIVAAMItgULJQCSAAAVAAMItgULJQCSAAAAAA==.',['釒熊']='釒熊猫:BAAAKgAFFAUIAgAAAA==.釒熊貓飼養員:BAAAKgAFFAQIBAAAAA==.',['釗鋒']='釗鋒:BAABKgAECn87AAMFAAgIkBrbKQDWAQAFAAgIkBrbKQDWAQAQAAcIixbwGACQAQAAAA==.',['鎏羽']='鎏羽:BAABKgAFFH8QAAMVAAUIPBrkGQBKAQAVAAUIPBrkGQBKAQAeAAEIoB6KHgBWAAAAAA==.',['钻石']='钻石无畏:BAAAKgAECgEIAQAAAA==.',['铁蹄']='铁蹄黑心:BAAAKgAFFAEIAQAAAA==.',['闪电']='闪电丷:BAABKgAFFH8JAAIFAAcITgYhDwBhAQAFAAcITgYhDwBhAQAAAA==.',['阿力']='阿力:BAAAKgAFFAEIAQAAAA==.',['阿基']='阿基米德:BAAAKgAECgYIBgAAAA==.',['阿尔']='阿尔萨思:BAAAKgAECggIDQAAAA==.阿尔萨撕:BAABKgAECn8UAAIiAAgIphtvDAAtAgAiAAgIphtvDAAtAgAAAA==.',['阿拉']='阿拉穆戈:BAAAKgADCggICAAAAA==.',['阿文']='阿文灬:BAAAKgADCgUIBQAAAA==.',['阿木']='阿木的寂寞:BAAAKgAECgEIAQAAAA==.',['阿蒙']='阿蒙:BAAAKgAECggICgAAAA==.',['阿阮']='阿阮丶:BAABKgAFFH8JAAIDAAQINB5wHwAQAQADAAQINB5wHwAQAQAAAA==.',['阿鲁']='阿鲁迪巴朗:BAAAKgADCggICAAAAA==.',['陈大']='陈大黑:BAABKgAFFH8JAAIUAAMIbQztGADCAAAUAAMIbQztGADCAAAAAA==.',['陈小']='陈小牧:BAAAKgAECgQIBAAAAA==.',['随风']='随风飘远方:BAAAKgAECggICwAAAA==.',['雨中']='雨中的宁静:BAAAKgADCgMIAwAAAA==.',['雪百']='雪百合:BAAAKgADCggICAAAAA==.',['雪飘']='雪飘飘:BAACKgAFFH8iAAMCAAQITxOJFACbAAACAAQITxOJFACbAAABAAMIbwKaJABpAAAqAAQKfxgAAwIACAinFgE6ADABAAIACAiVFgE6ADABABkABgiJDB9RANIAAAAA.',['雷霆']='雷霆妞妞:BAABKgAFFH8PAAMFAAYIQgusFQAtAQAFAAYIQgusFQAtAQANAAMIshreDQD6AAAAAA==.雷霆萬鈞:BAAAKgAFFAEIAQAAAA==.',['青眼']='青眼白龙莉莉:BAAAKgAECgIIAgAAAA==.',['靓醒']='靓醒的纯天然:BAABKgAECn8aAAIPAAgIKxfGGgDrAQAPAAgIKxfGGgDrAQAAAA==.',['静丨']='静丨悄悄:BAABKgAFFH8OAAIGAAgI+BglBQBBAgAGAAgI+BglBQBBAgAAAA==.',['非法']='非法潮流:BAAAKgAECgIIAgAAAA==.',['風未']='風未止战:BAAAKgAECgcIEwABKgAFFAYIBAAhAAAAAA==.',['风剑']='风剑雅:BAABKgAFFH8GAAMUAAIIghlNHwCUAAAUAAIIghlNHwCUAAAKAAIInAgSMQBxAAAAAA==.',['风千']='风千绝:BAAAKgAECgQIBAAAAA==.',['骑士']='骑士贝贝:BAAAKgAECgEIAQAAAA==.',['高剑']='高剑:BAAAKgAECgUIBQAAAA==.',['髯墨']='髯墨麸華:BAAAKgAFFAQIBAAAAA==.',['魍者']='魍者咏生:BAAAKgAECgQIBAAAAA==.',['魔女']='魔女丶:BAAAKgAECggIDQAAAA==.',['鲜血']='鲜血毒牙:BAABKgAFFH8aAAMEAAUI1iC0KgC/AAAEAAIIlSK0KgC/AAADAAQIHR+5PACqAAAAAA==.',['鸩羽']='鸩羽千夜丶:BAABKgAFFH8IAAINAAgI9wLICQAtAQANAAgI9wLICQAtAQAAAA==.',['麦香']='麦香鱼丶:BAABKgAFFH8GAAIZAAYIlBtdCQCFAQAZAAYIlBtdCQCFAQAAAA==.',['麽嘛']='麽嘛哒:BAAAKgAFFAMIAwAAAA==.',['黄昏']='黄昏的乐章:BAAAKgAECgEIAQAAAA==.',['黑黑']='黑黑萌萌哒:BAAAKgAFFAYIBAAAAA==.',['齐天']='齐天圣主:BAAAKgADCgEIAQAAAA==.',['龙梅']='龙梅耳:BAAAKgAECgcIDwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end