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
 local lookup = {'Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Hunter-Marksmanship','Druid-Balance','Druid-Restoration','Priest-Discipline','Warrior-Fury','DeathKnight-Unholy','DeathKnight-Blood','Mage-Frost','Mage-Arcane','DeathKnight-Frost','Hunter-BeastMastery','Evoker-Devastation','Priest-Shadow','Shaman-Restoration','Paladin-Holy','Paladin-Retribution','Paladin-Protection','Priest-Holy','Warrior-Arms','Shaman-Enhancement','Shaman-Elemental','Warrior-Protection','Rogue-Assassination','Mage-Fire','Monk-Mistweaver','Rogue-Outlaw','DemonHunter-Vengeance',}; local provider = {region='CN',realm='火烟之谷',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ah='Ahnqiraj:BAACKgAFFH8NAAMBAAUIxg7kEAC3AAACAAQIYAiZJgDYAAABAAQIFg/kEAC3AAAqAAQKfxoABAIACAirEmtJAEMBAAIACAirEmtJAEMBAAEABQjkDBFDANUAAAMAAgjaB9A9AE8AAAEqAAUUCAgSAAQA7RgA.',Al='Alabibi:BAAAKgADCgQIBAAAAA==.',As='Asrealbud:BAABKgAECn8ZAAMFAAgITRc4MwDeAQAFAAgITRc4MwDeAQAGAAYIRgUbYQCSAAAAAA==.',Ca='Catiam:BAABKgAFFH8IAAIHAAQIaCPwCAAQAQAHAAQIaCPwCAAQAQAAAA==.',Cs='Csniper:BAABKgAECn8XAAIIAAgIKyHFNACtAQAIAAgIKyHFNACtAQAAAA==.',Em='Empty:BAAAKgAECggICQAAAA==.',Je='Jerox:BAABKgAFFH8MAAMJAAgI9RGoDADFAQAJAAgI7w2oDADFAQAKAAQI+xCsEQC1AAAAAA==.',Lo='Lorabbit:BAABKgAECn8WAAMLAAgI+hp9IwD3AQALAAgIKhh9IwD3AQAMAAMI6xUHGwDDAAAAAA==.',Mo='Mograine:BAABKgAFFH8XAAQNAAYILB2EAwB3AQAJAAYIkRc9EgCIAQANAAYIfBOEAwB3AQAKAAYIfRSeDABKAQAAAA==.',No='Nopmop:BAAAKgAFFAMIAwAAAA==.',Nt='Ntr:BAAAKgAECgIIAgAAAA==.',Ol='Oldwang:BAAAKgADCgYIBgAAAA==.',Ra='Ralegh:BAABKgAFFH8MAAIOAAgI0xq2BABfAgAOAAgI0xq2BABfAgAAAA==.',Ru='Rubyflame:BAABKgAFFH8NAAIPAAYIYBW8DADoAAAPAAYIYBW8DADoAAAAAA==.',Sa='Salute:BAABKgAFFH8IAAMQAAgI3hp4DQApAQAQAAUIPBd4DQApAQAHAAMIeSFuDwApAQAAAA==.',Th='Thundervice:BAAAKgAECgEIAgAAAA==.',Ti='Timess:BAABKgAFFH8GAAIRAAYI2RNHEABUAQARAAYI2RNHEABUAQAAAA==.',Un='Uncletang:BAABKgAFFH8IAAIEAAgIjwgDDQCJAQAEAAgIjwgDDQCJAQAAAA==.',Wr='Wr:BAAAKgAFFAgIAgAAAA==.',['不吃']='不吃人头:BAABKgAFFH8IAAIKAAgI2BhbAgAzAgAKAAgI2BhbAgAzAgAAAA==.',['不大']='不大但有:BAAAKgAFFAgIAwAAAA==.',['丢失']='丢失:BAABKgAFFH8GAAIEAAYIihDMFQA1AQAEAAYIihDMFQA1AQAAAA==.',['丨悠']='丨悠悠丨:BAAAKgADCggICQAAAA==.',['中大']='中大渣网速:BAAAKgAECgYICwAAAA==.中大烧火棍:BAAAKgAFFAQIAgABKgAFFAgIFAALAPAZAA==.',['丶双']='丶双鱼座:BAAAKgADCgEIAQAAAA==.',['丶楼']='丶楼影:BAAAKgAFFAIIAgAAAA==.',['丶浅']='丶浅唱:BAAAKgADCgYIBgAAAA==.',['丶萨']='丶萨科:BAAAKgADCgEIAQAAAA==.',['为爱']='为爱战死床头:BAACKgAFFH8OAAMSAAYI1hClCQAOAQASAAUI4w6lCQAOAQATAAQIuwYBLgC3AAAqAAQKfxcABBIACAiEFZcaAJEBABIACAiEFZcaAJEBABQABgifBrhEAHsAABMAAQj4AgBMARkAAAAA.',['丿丶']='丿丶指间灬砂:BAABKgAECn8WAAMHAAgIFhvyFAAdAgAHAAgIFhvyFAAdAgAVAAgIWRD1OQBVAQAAAA==.',['乌啦']='乌啦啦:BAABKgAFFH8NAAITAAYINB7WAAACAgATAAYINB7WAAACAgAAAA==.',['乌鸦']='乌鸦大人:BAAAKgAFFAIIAgAAAA==.',['乧嵿']='乧嵿:BAAAKgADCggICAAAAA==.',['人马']='人马跳大:BAABKgAFFH8GAAIJAAYIaQvJGQBPAQAJAAYIaQvJGQBPAQABKgAFFAgIDgATACocAA==.',['今晚']='今晚吃鸡:BAABKgAFFH8mAAMWAAgIKyGoAADfAQAWAAgIKyGoAADfAQAIAAUIFwouBgA4AQAAAA==.',['仙熊']='仙熊掌和鱼:BAABKgAFFH8GAAITAAYIGxbfHwBwAQATAAYIGxbfHwBwAQAAAA==.',['以德']='以德福人:BAAAKgAECggIBQAAAA==.',['伊瑞']='伊瑞尔丶德尼:BAAAKgADCggICAAAAA==.',['你媳']='你媳妇突然:BAAAKgAECgQIBAAAAA==.',['侠女']='侠女妙影:BAAAKgAECgYIEgAAAA==.',['入夜']='入夜:BAAAKgAFFAIIAwAAAA==.',['再世']='再世:BAAAKgADCgUIBQAAAA==.',['冰淇']='冰淇淋哭了:BAAAKgAECgUICAAAAA==.',['冰西']='冰西瓜:BAAAKgAECggICAAAAA==.',['删除']='删除记忆:BAABKgAFFH8LAAIEAAgIBRmnBwDmAQAEAAgIBRmnBwDmAQAAAA==.',['割头']='割头者:BAAAKgAECgMIBAAAAA==.',['劫持']='劫持上帝:BAACKgAFFH8XAAQXAAYIhBDSCwDxAAAXAAYIJw/SCwDxAAAYAAQI+Aw1FwC7AAARAAQIyAhiOwCYAAAqAAQKfzUABBgACAh0JIAHALoCABgACAgAI4AHALoCABcACAh2IQoJAKACABEAAgg2DXCjAF0AAAAA.',['勇敢']='勇敢牛牛不怕:BAAAKgAECgUIBQAAAA==.',['千面']='千面红:BAAAKgAFFAEIAQAAAA==.',['双椒']='双椒肉拌面:BAABKgAFFH8FAAMBAAMITgzmGQCBAAACAAMIbglCNQCbAAABAAIIew/mGQCBAAAAAA==.',['可乐']='可乐加水:BAAAKgAECgIIAgAAAA==.',['吃薯']='吃薯片都塞牙:BAAAKgAECgIIAgAAAA==.',['呆贼']='呆贼:BAAAKgAFFAEIAQAAAA==.',['哈密']='哈密:BAAAKgAECgIIAgAAAA==.',['唐允']='唐允:BAAAKgAECgMIBgAAAA==.',['圣世']='圣世:BAAAKgADCgQIBAAAAA==.',['圣光']='圣光毛豆:BAAAKgADCgIIAgAAAA==.',['圣弓']='圣弓游侠:BAAAKgAFFAIIAgAAAA==.',['在黑']='在黑夜下犯罪:BAAAKgAFFAEIAQAAAA==.',['复姓']='复姓上官:BAABKgAECn8YAAMWAAgIoBDEDQBlAQAWAAcIqBHEDQBlAQAZAAgIHQyYDgA1AQAAAA==.',['夏末']='夏末红茶:BAAAKgAECgEIAQAAAA==.',['夜之']='夜之燧:BAAAKgAFFAEIAQAAAA==.夜之穗:BAABKgAFFH8IAAMQAAQI3AiHFQC4AAAQAAQI3AiHFQC4AAAHAAQImAYIJACRAAAAAA==.夜之邃:BAAAKgAECgUIBQAAAA==.夜之韢:BAAAKgAECgYICgAAAA==.夜之颂:BAAAKgAFFAQIBAAAAA==.',['夜的']='夜的渡船:BAABKgAFFH8IAAIFAAQIMhKSNwDBAAAFAAQIMhKSNwDBAAAAAA==.',['夜羽']='夜羽:BAABKgAECn8WAAMWAAgIMRVLHQDJAQAWAAgIMRVLHQDJAQAIAAgIEgzUOACYAQAAAA==.',['大尾']='大尾鲈鳗:BAAAKgADCgIIAgAAAA==.',['大概']='大概是个憨憨:BAABKgAFFH8IAAITAAgIlQo8DQDOAQATAAgIlQo8DQDOAQAAAA==.',['大魔']='大魔王:BAAAKgAECgYIBwAAAA==.',['天天']='天天摸鱼:BAAAKgAFFAQIBAAAAA==.',['天气']='天气晴朗:BAAAKgAECgMIAwAAAA==.',['太寿']='太寿鸠毛:BAAAKgAFFAIIAgAAAA==.',['太年']='太年轻:BAAAKgAECgIIAgAAAA==.',['女监']='女监男狱警:BAAAKgAECgcIBwAAAA==.',['奶德']='奶德拉个宁静:BAAAKgAECggIEAAAAA==.',['好气']='好气宝宝:BAAAKgADCgQIBAAAAA==.',['妮莉']='妮莉艾路:BAABKgAFFH8LAAMVAAcIqxrbBwCrAQAVAAcIqxrbBwCrAQAHAAQISgtjIACiAAAAAA==.',['娜萨']='娜萨:BAAAKgAECgEIAQAAAA==.',['子丿']='子丿鼠:BAAAKgAECgQIBAAAAA==.',['孤单']='孤单的苹果:BAABKgAFFH8OAAMBAAYI9BufAABnAQABAAUIeRyfAABnAQACAAUIIBFwBgA9AQAAAA==.',['孤独']='孤独根号三:BAAAKgAFFAIIAgAAAA==.',['孫灬']='孫灬燕姿:BAAAKgAECgEIAQAAAA==.',['宁辞']='宁辞秋:BAABKgAFFH8IAAITAAYInBcUHgB6AQATAAYInBcUHgB6AQAAAA==.',['宇智']='宇智波丶全需:BAAAKgAFFAMIAwAAAA==.',['守备']='守备官米卡:BAAAKgAECgYIBgAAAA==.',['完美']='完美无瑕:BAAAKgAECgUIBQAAAA==.',['对唔']='对唔嗨住啊:BAABKgAFFH8HAAMEAAcI6gR5HwD5AAAEAAUITQZ5HwD5AAAOAAIIIwLPWQBFAAAAAA==.',['小侎']='小侎:BAAAKgADCgIIAgAAAA==.',['小屠']='小屠屠逐日者:BAAAKgAFFAIIAgAAAA==.',['小猫']='小猫吃鱼:BAAAKgAECgEIAQAAAA==.',['小绿']='小绿龙:BAAAKgAECgIIAgAAAA==.',['小蘿']='小蘿麗:BAABKgAFFH8FAAIIAAUI2hUcFgDWAAAIAAUI2hUcFgDWAAAAAA==.',['小贱']='小贱:BAAAKgAECgIIAgAAAA==.',['小野']='小野妞:BAAAKgAFFAIIAgAAAA==.',['小阳']='小阳阳:BAACKgAFFH8GAAILAAQIWgmjDQCwAAALAAQIWgmjDQCwAAAqAAQKfxkAAgsACAhUGOQXAPcBAAsACAhUGOQXAPcBAAAA.',['小馬']='小馬寶莉:BAABKgAFFH8TAAMHAAYIDBkwAQDZAQAHAAYIDBkwAQDZAQAQAAQIAw9eEgDQAAAAAA==.',['小鱼']='小鱼儿:BAAAKgAECgIIAgAAAA==.',['尐丶']='尐丶柚萌:BAAAKgAECgEIAQAAAA==.',['少林']='少林寺王神父:BAAAKgADCgYIBgAAAA==.',['尛丫']='尛丫头:BAAAKgADCgMIAwAAAA==.',['居然']='居然来了:BAAAKgAFFAgIBAAAAA==.',['帅就']='帅就可以了:BAAAKgAECgcIBwAAAA==.',['帅气']='帅气小贼:BAAAKgAFFAIIAgAAAA==.',['幽暗']='幽暗的天空:BAAAKgAECgQICQAAAA==.',['德玛']='德玛西亚之翼:BAACKgAFFH8GAAIEAAYIbh7lGAAiAQAEAAYIbh7lGAAiAQAqAAQKfyYAAg4ACAi6JA4JANoCAA4ACAi6JA4JANoCAAAA.',['德鲁']='德鲁医:BAAAKgADCggICAAAAA==.',['心跳']='心跳零距离:BAAAKgADCgUIBQAAAA==.',['我来']='我来助你:BAABKgAFFH8HAAMZAAQI/QbWEAB2AAAWAAMI9gR9IACMAAAZAAQIXgbWEAB2AAAAAA==.',['我的']='我的筷子呢:BAAAKgAECgMIAwAAAA==.',['战傲']='战傲天:BAAAKgAECggIDwAAAA==.',['挡你']='挡你的虔诚:BAACKgAFFH8JAAISAAQI2x96CQARAQASAAQI2x96CQARAQAqAAQKfxYABBIACAg1H/UiAEcBABIABwhsHvUiAEcBABMABAgfHIGDAEcBABQAAwhSDcxAAH0AAAAA.',['振翅']='振翅:BAAAKgAECgQIBAAAAA==.',['搞部']='搞部落:BAABKgAECn8XAAITAAcIsR1gTwAEAgATAAcIsR1gTwAEAgAAAA==.',['文衍']='文衍:BAABKgAFFH8FAAIHAAUIDRUjEQAWAQAHAAUIDRUjEQAWAQAAAA==.',['星烬']='星烬之璨:BAAAKgAECgMIAwAAAA==.',['星见']='星见雅:BAAAKgAFFAMIAwAAAA==.',['暗之']='暗之刚:BAAAKgADCggICAAAAA==.',['暮光']='暮光幼龙:BAAAKgAECgcIBwAAAA==.',['暮色']='暮色百合:BAABKgAFFH8GAAIFAAYIbRRKGQBOAQAFAAYIbRRKGQBOAQAAAA==.',['暮雨']='暮雨:BAAAKgAECgMIAwAAAA==.',['暴力']='暴力柚柚:BAABKgAECn8WAAMWAAgIwBXYGgDcAQAWAAgIwBXYGgDcAQAIAAQI1hJrVwCtAAAAAA==.',['曾经']='曾经很小德:BAAAKgAECgYIBgAAAA==.',['最后']='最后的征伐:BAABKgAFFH8NAAMWAAYIAxYTDABNAQAWAAYI0A4TDABNAQAIAAMI/h8RHADkAAAAAA==.',['月意']='月意紫影:BAAAKgADCggICAAAAA==.',['月色']='月色如浅梦:BAAAKgAECgIIAgAAAA==.',['有根']='有根大竹子:BAAAKgAECgMIAwAAAA==.',['木木']='木木灬:BAAAKgAECgYIBgAAAA==.',['板都']='板都板不脱:BAAAKgADCggIDQAAAA==.',['桑德']='桑德兰:BAAAKgAFFAQIBAAAAA==.',['梧夜']='梧夜飘逝:BAAAKgADCgEIAQAAAA==.',['梧桐']='梧桐栖凤:BAABKgAFFH8LAAIUAAQIhhV3CQDLAAAUAAQIhhV3CQDLAAAAAA==.',['泡椒']='泡椒牛肉丝:BAABKgAECn8UAAMHAAgIUiTVCwByAgAHAAcIlyTVCwByAgAVAAIIsSL/fgBmAAAAAA==.',['洒家']='洒家要喝酒:BAAAKgAECgYICQABKgAECggIHAAMAM0eAA==.',['济公']='济公活佛:BAAAKgAECgYICgAAAA==.',['淘气']='淘气女孩:BAAAKgAECggICgAAAA==.',['深刈']='深刈:BAAAKgAFFAMIAwAAAA==.',['深情']='深情的流氓:BAAAKgADCgQIBAAAAA==.',['清欢']='清欢渡:BAAAKgAECgYIBgAAAA==.',['清源']='清源:BAAAKgAECggICAAAAA==.',['湛蓝']='湛蓝玫瑰:BAAAKgAFFAEIAQAAAA==.',['滚豆']='滚豆豆:BAAAKgADCgMIAwAAAA==.',['火火']='火火因:BAAAKgADCggIEQAAAA==.',['灬傻']='灬傻瓜丶:BAAAKgAECggICQAAAA==.',['灬浮']='灬浮丨云灬:BAAAKgAECgQIBAAAAA==.',['热烈']='热烈的马:BAABKgAECn8ZAAIJAAgIMiGPFgBXAgAJAAgIMiGPFgBXAgAAAA==.',['焱调']='焱调调:BAAAKgAFFAgIBAAAAA==.',['爱梅']='爱梅子明哥:BAAAKgADCgEIAQAAAA==.',['牛儿']='牛儿大:BAAAKgADCggICAAAAA==.',['犯困']='犯困的水煮蛋:BAABKgAFFH8bAAMMAAgI4R75CQDPAQAMAAgIoB35CQDPAQALAAYIzx6eAwC9AQAAAA==.犯困的溏心蛋:BAABKgAFFH8LAAIIAAYIgxdSDQB6AQAIAAYIgxdSDQB6AQAAAA==.犯困的荷包蛋:BAABKgAFFH8OAAMDAAgILhmbAABnAQADAAUIVBmbAABnAQACAAgIHhb2BgA1AQAAAA==.',['狼银']='狼银:BAAAKgADCgIIAgAAAA==.',['猫头']='猫头鹰:BAAAKgADCgMIAwAAAA==.',['生命']='生命奇迹:BAAAKgAECgUIBQAAAA==.',['皮卡']='皮卡丘一号:BAAAKgAECgYICwAAAA==.',['盖侬']='盖侬:BAAAKgAFFAQIBAAAAA==.',['碧涟']='碧涟含烟:BAAAKgAECgIIAgAAAA==.',['程洁']='程洁琪:BAAAKgAECgEIAQAAAA==.',['红疙']='红疙瘩:BAAAKgADCgMIAwAAAA==.',['维吉']='维吉尔:BAABKgAFFH8GAAIaAAYIXxJQDACHAQAaAAYIXxJQDACHAQAAAA==.',['罗宾']='罗宾:BAAAKgAECgUICQAAAA==.',['老呼']='老呼突然:BAAAKgADCggICAAAAA==.',['老奶']='老奶奶过马路:BAAAKgAECgEIAQAAAA==.',['老船']='老船长丢火车:BAAAKgAECgIIAgAAAA==.',['老阴']='老阴批:BAAAKgAFFAMIAwAAAA==.',['芙莉']='芙莉莲:BAABKgAFFH8KAAIUAAYI+xTRDAArAQAUAAYI+xTRDAArAQAAAA==.',['芥末']='芥末肉骨头:BAAAKgADCgYIBgAAAA==.',['若水']='若水盈盈:BAAAKgAFFAQIBAAAAA==.',['莎丨']='莎丨蔓:BAAAKgAECggIDQAAAA==.',['莱汀']='莱汀:BAAAKgAECgEIAQAAAA==.',['菠萝']='菠萝到处浪啊:BAACKgAFFH8LAAILAAMIJh8SDwDqAAALAAMIJh8SDwDqAAAqAAQKfxgABAsACAjdHb4gAKwBAAsACAjdHb4gAKwBABsABQi8ClNzAKoAAAwAAQisJHR/AGgAAAAA.',['萌新']='萌新小牧:BAABKgAFFH8OAAMVAAYIihtRBwC2AQAVAAYIihtRBwC2AQAHAAEIAAB6NwAAAAAAAA==.萌新小萨:BAACKgAFFH8iAAMRAAUIEyRNAwBNAQARAAUIEyRNAwBNAQAYAAII2g/uIQBxAAAqAAQKfygAAxEACAjAI0YFAM4CABEACAjAI0YFAM4CABgACAgqFjslAMgBAAEqAAUUBggOABUAihsA.',['萌狐']='萌狐小施:BAAAKgAECgUIBQAAAA==.',['萨特']='萨特曼:BAABKgAECn8cAAIRAAgIWyF0JQDsAQARAAgIWyF0JQDsAQAAAA==.',['萨萌']='萨萌檬:BAAAKgAECgYICwAAAA==.',['蓁蓁']='蓁蓁的保镖:BAABKgAFFH8MAAIWAAgI4Bk+AwAuAgAWAAgI4Bk+AwAuAgAAAA==.',['蔚虾']='蔚虾仁:BAAAKgAECggICAAAAA==.',['蘇姗']='蘇姗:BAAAKgADCggICAAAAA==.',['虚空']='虚空夜月:BAACKgAFFH8GAAIEAAII9xPjHgB9AAAEAAII9xPjHgB9AAAqAAQKfyUAAwQACAhxH6QbAPQBAAQACAhxH6QbAPQBAA4AAQjgCirMAC4AAAAA.',['蠱惑']='蠱惑崽:BAAAKgAECgYIDgAAAA==.',['血色']='血色刀锋:BAAAKgAECgYIBgAAAA==.',['西东']='西东东:BAAAKgAECgcICgAAAA==.',['见龙']='见龙在田:BAAAKgADCggICAAAAA==.',['贼娃']='贼娃子:BAAAKgAECggICAAAAA==.',['赏你']='赏你个痛快:BAAAKgADCggICwAAAA==.',['赤宵']='赤宵战魂:BAAAKgAECggICAAAAA==.',['赴我']='赴我再少年丶:BAAAKgADCgIIAgAAAA==.',['超级']='超级变变遍:BAAAKgAECgUIBQAAAA==.',['路索']='路索普:BAAAKgAECggICwAAAA==.',['躲在']='躲在你的衣柜:BAABKgAECn8WAAIcAAgI+RgCMAAeAQAcAAgI+RgCMAAeAQAAAA==.',['辣多']='辣多一点:BAAAKgADCgYIBgAAAA==.',['过期']='过期小鲜肉:BAAAKgAECgIIAQAAAA==.',['邪邪']='邪邪笙歌:BAAAKgAECgYIBgAAAA==.',['酋长']='酋长毛结棍:BAAAKgAECggIDQAAAA==.',['酒亦']='酒亦醉情易碎:BAABKgAFFH8XAAIKAAYIrRqxCgBoAQAKAAYIrRqxCgBoAQAAAA==.',['钢板']='钢板曰川:BAAAKgAECgQIBAAAAA==.',['闲钺']='闲钺:BAAAKgAECgUIDQAAAA==.',['阳阳']='阳阳:BAABKgAECn80AAITAAgIhSFACgCfAgATAAgIhSFACgCfAgAAAA==.',['阿尔']='阿尔泰娅:BAAAKgAECgQIBAAAAA==.',['阿紫']='阿紫喵:BAAAKgAECgMIAwAAAA==.',['隐藏']='隐藏角色:BAACKgAFFH8FAAITAAIIDCPYLAC8AAATAAIIDCPYLAC8AAAqAAQKfzcAAhMACAjWJSgHAAADABMACAjWJSgHAAADAAAA.',['雲淡']='雲淡凬轻:BAAAKgADCgEIAQAAAA==.',['電動']='電動亜當:BAABKgAFFH8LAAMGAAQISxXVGwDEAAAGAAQISxXVGwDEAAAFAAMIwQceQgCkAAAAAA==.',['霜夜']='霜夜小白:BAABKgAFFH8KAAMCAAYIkRKUFABfAQACAAYIkRKUFABfAQABAAQIsxDkDgDCAAAAAA==.',['青柑']='青柑灬普洱:BAAAKgADCggICAAAAA==.',['非洲']='非洲叫兽:BAAAKgADCgUIBQAAAA==.',['顿顿']='顿顿有拉菲:BAAAKgADCgcIBwAAAA==.',['风三']='风三帅:BAABKgAECn8UAAIJAAgIkBD+RwBSAQAJAAgIkBD+RwBSAQAAAA==.',['风从']='风从发梢吹过:BAABKgAFFH8GAAIRAAYIthD2EQBFAQARAAYIthD2EQBFAQABKgAFFAgICAARALsbAA==.',['飛天']='飛天豬寶寶:BAAAKgAECgYIBgAAAA==.',['马一']='马一一:BAABKgAFFH8TAAIHAAQIeyUDDQBGAQAHAAQIeyUDDQBGAQAAAA==.',['马叮']='马叮当:BAABKgAFFH8PAAIOAAQINBulEwDzAAAOAAQINBulEwDzAAAAAA==.',['马啦']='马啦啦:BAABKgAFFH8VAAMdAAQI6x5gAwABAQAaAAQItBuaBwAJAQAdAAQI3BtgAwABAQAAAA==.',['马维']='马维:BAABKgAFFH8LAAIIAAQIxxeIEADvAAAIAAQIxxeIEADvAAAAAA==.',['骑着']='骑着老奶奶:BAABKgAFFH8KAAIeAAMI3iMiBwAtAQAeAAMI3iMiBwAtAQAAAA==.',['鬼人']='鬼人正邪:BAABKgAECn8WAAIKAAgI3A+sLQDiAAAKAAgI3A+sLQDiAAAAAA==.',['鬼砺']='鬼砺:BAABKgAFFH8IAAMDAAYI1AwDBABMAQADAAYI/QsDBABMAQACAAIIxwiiQgBhAAAAAA==.',['黑色']='黑色丶眼眸:BAAAKgAECggIAwAAAA==.',['龙霸']='龙霸天:BAAAKgAFFAIIAgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end