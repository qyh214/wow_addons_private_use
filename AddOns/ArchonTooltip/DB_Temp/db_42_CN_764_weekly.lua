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
 local lookup = {'Priest-Holy','Priest-Discipline','Warlock-Affliction','Warlock-Demonology','Warlock-Destruction','Shaman-Enhancement','Evoker-Devastation','Hunter-BeastMastery','Paladin-Retribution','DeathKnight-Blood','Evoker-Preservation','Paladin-Holy','Mage-Frost','Mage-Fire','Unknown-Unknown','DemonHunter-Havoc','DemonHunter-Vengeance','Shaman-Restoration','Hunter-Marksmanship','DeathKnight-Unholy','Paladin-Protection',}; local provider = {region='CN',realm='瑟莱德丝',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ac='Acow:BAABKgAFFH8gAAMBAAgIMh63BgDDAQABAAgI9R23BgDDAQACAAgIqRC9BwCqAQAAAA==.',Ay='Ayayaga:BAAAKgAECgIIAgAAAA==.',Ca='Catherine:BAABKgAECn8eAAQDAAgIoxjPDgB7AQAEAAgIGhfOHACYAQADAAgIIxLPDgB7AQAFAAIIAQSXtQAjAAAAAA==.',Fl='Flora:BAAAKgAFFAIIAgAAAA==.',Ke='Keath:BAABKgAFFH8GAAIBAAYIvgfVDQDtAAABAAYIvgfVDQDtAAAAAA==.',Mx='Mxzzc:BAABKgAFFH8OAAIGAAQIUh6ADQDyAAAGAAQIUh6ADQDyAAAAAA==.',Ni='Niklaus:BAAAKgAFFAEIAQAAAA==.',Ra='Ranni:BAAAKgAECggIBgAAAA==.',Si='Sixdots:BAAAKgAECggIBQAAAA==.',['一坨']='一坨:BAAAKgAECgIIAgAAAA==.',['三鹿']='三鹿粉不加奶:BAAAKgADCgEIAgAAAA==.',['不死']='不死牛马:BAAAKgAECgQIBAAAAA==.',['且听']='且听龙吟:BAAAKgAECgQIBQAAAA==.',['丹妹']='丹妹:BAAAKgAECgEIAQAAAA==.',['乐瑶']='乐瑶:BAABKgAFFH85AAMBAAgIQCK1AQCDAgABAAgIISK1AQCDAgACAAYIQR5uBwCyAQAAAA==.',['乖乖']='乖乖小德:BAAAKgADCgcIBwAAAA==.',['二様']='二様骑骑:BAAAKgADCggICAAAAA==.',['代号']='代号猎手:BAAAKgAECgEIAQAAAA==.',['俺是']='俺是帝皮埃斯:BAABKgAFFH8IAAIFAAgIRxvsAwBtAgAFAAgIRxvsAwBtAgAAAA==.',['偶尔']='偶尔躲躲乌云:BAAAKgAECggICQAAAA==.',['克拉']='克拉苏斯:BAABKgAFFH8SAAIHAAgI7x5EBAByAgAHAAgI7x5EBAByAgAAAA==.',['克里']='克里斯塔皮爷:BAABKgAFFH8KAAIIAAYI/h5fDwCCAQAIAAYI/h5fDwCCAQAAAA==.',['公瑾']='公瑾凉又凉:BAAAKgAECgEIAQAAAA==.',['冰摇']='冰摇桃桃乌龙:BAAAKgAECggIDwAAAA==.',['冷凝']='冷凝:BAAAKgAECggICAAAAA==.',['冷大']='冷大壮:BAABKgAECn8UAAIJAAgIZhosWADvAQAJAAgIZhosWADvAQAAAA==.',['北冥']='北冥有鱼:BAABKgAFFH8GAAIKAAYIJwY+GwDIAAAKAAYIJwY+GwDIAAAAAA==.',['司波']='司波空悠:BAAAKgADCggICAAAAA==.',['咕咕']='咕咕丶哒:BAAAKgADCgQIBAAAAA==.',['咕尔']='咕尔丹丶:BAAAKgADCgMIAwAAAA==.',['哇大']='哇大恶魔:BAAAKgAECgEIAQAAAA==.',['喜宝']='喜宝:BAAAKgADCgMIAwAAAA==.',['嘻嘻']='嘻嘻哈哈:BAABKgAFFH8IAAMHAAgICR/pDwBiAQAHAAQI4yPpDwBiAQALAAQIjSGGAQApAQAAAA==.',['噔哆']='噔哆啦:BAAAKgADCggICAAAAA==.',['回忆']='回忆的箭:BAABKgAFFH8SAAMCAAgItCSbAADQAgACAAgItCSbAADQAgABAAQIsAWmEgCsAAAAAA==.',['圣光']='圣光团子:BAACKgAFFH8FAAIJAAIIig00QgCCAAAJAAIIig00QgCCAAAqAAQKfxQAAgkACAhvDyyFAI0BAAkACAhvDyyFAI0BAAAA.圣光忽悠者您:BAAAKgAECgYIBgAAAA==.圣光闪现:BAABKgAFFH8cAAIMAAQItwPaDQB3AAAMAAQItwPaDQB3AAAAAA==.',['墨染']='墨染尘归:BAABKgAFFH8cAAMNAAQIfCFvBQAFAQANAAQIfCFvBQAFAQAOAAQI4wibJADDAAABKgAFFAgIBAAPAAAAAA==.',['壹技']='壹技壁殺:BAAAKgAECggICAAAAA==.',['天下']='天下行走:BAAAKgAECgMIAwAAAA==.',['天之']='天之丛雲:BAAAKgAECgQIBAAAAA==.',['天沁']='天沁:BAAAKgADCgIIAgAAAA==.',['天降']='天降正義:BAACKgAFFH8KAAIOAAYIHBfpBAC4AQAOAAYIHBfpBAC4AQAqAAQKfxUAAw0ACAinInMkAPEBAA0ACAhvIXMkAPEBAA4ABwj8F1U4ALMBAAAA.',['奥莱']='奥莱恩丶冰蹄:BAACKgAFFH8RAAIJAAQICiN1DgAaAQAJAAQICiN1DgAaAQAqAAQKfyIAAgkACAhVF3uBAJQBAAkACAhVF3uBAJQBAAEqAAUUCAgEAA8AAAAA.',['安静']='安静的佐佐:BAABKgAFFH8GAAICAAYINRC7CwBZAQACAAYINRC7CwBZAQAAAA==.',['富察']='富察傅恒:BAABKgAECn8YAAMQAAgIhxBhSAAoAQAQAAYInRRhSAAoAQARAAgIXwd+OgDNAAAAAA==.',['小伙']='小伙伴:BAAAKgAECggICgAAAA==.',['小小']='小小德丶:BAAAKgAECggICwAAAA==.',['小磊']='小磊暴揍贺宝:BAAAKgAECgMIAwAAAA==.',['己不']='己不由心:BAAAKgAECgMIAwAAAA==.',['希尔']='希尔瓦娜矢丶:BAAAKgAECgIIAgAAAA==.',['心不']='心不由己:BAAAKgAECgcICwAAAA==.',['愿圣']='愿圣光忽悠你:BAAAKgADCgUICAAAAA==.',['拉不']='拉不住一点丶:BAAAKgAECgcIDAAAAA==.',['招财']='招财进宝:BAAAKgAFFAQIBAAAAA==.',['暴龙']='暴龙兽:BAAAKgADCgMIAwAAAA==.',['月雾']='月雾米拉:BAAAKgAECgQIBQAAAA==.',['木法']='木法沙:BAAAKgADCgYIBgAAAA==.',['术团']='术团子:BAAAKgAECggIEwAAAA==.',['李忆']='李忆寒:BAAAKgADCggICAAAAA==.',['桂花']='桂花弄:BAAAKgADCgEIAQAAAA==.',['梅仁']='梅仁耀:BAAAKgAECgMIAwAAAA==.',['殃云']='殃云天降:BAAAKgAECgEIAQAAAA==.',['残血']='残血媚影:BAABKgAFFH8GAAINAAYI/RA9BQBjAQANAAYI/RA9BQBjAQAAAA==.',['泉塘']='泉塘吴彦祖:BAACKgAFFH8UAAISAAMIliXVEQBGAQASAAMIliXVEQBGAQAqAAQKfzUAAhIACAgaIWIWAE4CABIACAgaIWIWAE4CAAEqAAUUBAghABIAkSAA.泉塘谢霆锋:BAAAKgAECgUICQABKgAFFAQIIQASAJEgAA==.',['法王']='法王:BAAAKgADCgQIBAAAAA==.',['洒琪']='洒琪玛:BAAAKgAFFAMIAwAAAA==.',['浮生']='浮生如梦灬:BAAAKgADCgIIAgAAAA==.',['渣渣']='渣渣:BAAAKgAECgEIAQAAAA==.',['灬凌']='灬凌小小:BAACKgAFFH8vAAIJAAgIXSIRBQCCAgAJAAgIXSIRBQCCAgAqAAQKfzcAAgkACAiUJkkKAPECAAkACAiUJkkKAPECAAAA.',['牧笙']='牧笙:BAAAKgAECgYIBgAAAA==.',['狐狸']='狐狸先森丶:BAAAKgADCggIEAAAAA==.',['狼小']='狼小灬灵:BAAAKgAFFAQIBAABKgAFFAYIAQAPAAAAAA==.',['猎团']='猎团子:BAABKgAECn8YAAMIAAgIzhW8PwD5AQAIAAgIzhW8PwD5AQATAAEIzQvIjAAwAAAAAA==.',['痛苦']='痛苦无常:BAACKgAFFH8WAAMFAAgIEhcLCAAPAgAFAAcIaBYLCAAPAgADAAQIsBkWDgDFAAAqAAQKfxQAAgUACAiYHZtAAAkBAAUACAiYHZtAAAkBAAAA.',['白胡']='白胡子老爹:BAAAKgADCgQIBAAAAA==.',['科学']='科学鉴定专家:BAAAKgAECgEIAQAAAA==.',['笃笃']='笃笃滴:BAAAKgADCgMIAwAAAA==.',['筱武']='筱武:BAAAKgAECgIIAgAAAA==.',['米丶']='米丶粒:BAABKgAFFH8KAAIUAAYItxJ4DAAKAQAUAAYItxJ4DAAKAQAAAA==.',['米粒']='米粒丶:BAAAKgAECgcIBwAAAA==.',['索克']='索克丶黑石:BAAAKgADCgcIBwAAAA==.',['綺漪']='綺漪:BAAAKgADCgEIAQAAAA==.',['群主']='群主演一下:BAABKgAFFH8LAAMJAAYIkgtCIwDhAAAJAAQIlhJCIwDhAAAVAAYICwZcGAC1AAAAAA==.群主跳一下:BAABKgAFFH8KAAIQAAYI3A50GgAqAQAQAAYI3A50GgAqAQAAAA==.',['腹背']='腹背受迪:BAABKgAFFH8JAAIQAAgIQQnqCgC9AQAQAAgIQQnqCgC9AQAAAA==.',['良晴']='良晴:BAACKgAFFH8OAAIMAAQI+wFNEAB/AAAMAAQI+wFNEAB/AAAqAAQKf1cAAwwACAjiElIKAHwBAAwACAjiElIKAHwBABUABQjiDIoXAKAAAAAA.',['花妖']='花妖丶:BAAAKgAECgQIBQAAAA==.',['英皇']='英皇法神:BAABKgAFFH8FAAINAAMIxwlIFgCDAAANAAMIxwlIFgCDAAAAAA==.',['莫方']='莫方有我:BAAAKgAFFAIIBAAAAA==.',['萨克']='萨克丶黑石:BAABKgAFFH8MAAMFAAYIWgmLEAAtAQAFAAYIOwmLEAAtAQAEAAEIqAZCFwBBAAAAAA==.',['董毛']='董毛毛:BAABKgAFFH8IAAISAAgIpgelHgABAQASAAgIpgelHgABAQAAAA==.',['蓝夜']='蓝夜凊音:BAAAKgADCgQIBAAAAA==.',['达文']='达文奇:BAAAKgAFFAIIAgAAAA==.',['迪迪']='迪迪胃胃:BAAAKgAECgQIBAAAAA==.',['邪血']='邪血:BAAAKgADCggIDQAAAA==.',['部落']='部落老中医:BAAAKgADCgEIAQAAAA==.',['郭德']='郭德刚满月:BAAAKgADCggIDgAAAA==.',['里通']='里通外迪:BAAAKgAECggICQAAAA==.',['鐡血']='鐡血:BAAAKgAFFAIIBAAAAA==.',['钢针']='钢针:BAABKgAFFH8MAAIUAAYICQ7YGABXAQAUAAYICQ7YGABXAQAAAA==.',['阿瑞']='阿瑞斯丶:BAAAKgADCggICAAAAA==.',['青城']='青城山上:BAAAKgADCggIGwAAAA==.青城山下:BAAAKgADCgMIBAAAAA==.',['韩小']='韩小柒:BAAAKgAFFAIIAgAAAA==.',['飞机']='飞机师:BAACKgAFFH8IAAIJAAYIBQ9/LgAuAQAJAAYIBQ9/LgAuAQAqAAQKfxgAAgkACAiNIXxQAAECAAkACAiNIXxQAAECAAAA.',['香烟']='香烟的凝望:BAAAKgADCgIIAgAAAA==.',['鬼帅']='鬼帅丶:BAAAKgAECgYIBwAAAA==.',['黑色']='黑色暗衍丶:BAAAKgAFFAEIAQAAAA==.',['龙族']='龙族丿烂少:BAAAKgAFFAYIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end