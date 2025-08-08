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
 local lookup = {'Rogue-Assassination','DeathKnight-Blood','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Druid-Restoration','Druid-Balance','Shaman-Restoration','Mage-Frost','Shaman-Elemental','Paladin-Retribution','Druid-Guardian','Priest-Holy','Paladin-Holy','Warrior-Fury','Paladin-Protection','Hunter-Marksmanship','Hunter-BeastMastery','Monk-Windwalker','DemonHunter-Havoc','Warlock-Affliction','Priest-Discipline','Warrior-Arms','Priest-Shadow','Mage-Arcane','DemonHunter-Vengeance','Unknown-Unknown','Shaman-Enhancement','Warrior-Protection','Hunter-Survival','Monk-Mistweaver','Mage-Fire','Druid-Feral','DeathKnight-Frost','Evoker-Preservation',}; local provider = {region='CN',realm='阿拉希',name='CN',type='weekly',zone=42,date='2025-08-03',data={Ak='Akrios:BAABKgAECn8WAAIBAAYItB1DCwB9AQABAAYItB1DCwB9AQAAAA==.',Bl='Blackcow:BAAAKgAECgMIAwAAAA==.',Bm='Bmwninet:BAABKgAFFH8IAAMCAAQIOwrZJgB7AAADAAQIEARhQgCVAAACAAQIOwrZJgB7AAAAAA==.',De='Desire:BAABKgAFFH8OAAIDAAQIbgy7FQC4AAADAAQIbgy7FQC4AAAAAA==.',Do='Doomart:BAABKgAFFH8PAAMEAAMI9SBQDwDAAAAFAAMIHhhfKQDIAAAEAAII5iNQDwDAAAAAAA==.',Dr='Drkedogs:BAABKgAFFH8GAAIFAAMIwwuTGwCiAAAFAAMIwwuTGwCiAAAAAA==.Druidforcmcc:BAAAKgAFFAgIBAAAAA==.',Du='Duoduoxd:BAABKgAFFH8IAAMGAAgIHAkMDQA6AQAGAAcIeQcMDQA6AQAHAAEIkCKtUwBoAAABKgAFFAgIUAAHABcmAA==.',Fa='Faithfully:BAAAKgADCggICAAAAA==.',Fs='Fsfssfs:BAAAKgAECgQIBQAAAA==.',Fu='Fuwawa:BAABKgAFFH8IAAIIAAMIOSH+GQC7AAAIAAMIOSH+GQC7AAAAAA==.',Ge='Gervin:BAABKgAECn8UAAIJAAgIMxQrIQCpAQAJAAgIMxQrIQCpAQAAAA==.',He='Hellovenus:BAAAKgAECgMIBAAAAA==.',Hi='Hiletaeagune:BAAAKgADCggICAAAAA==.',Ho='Honeyhoney:BAABKgAFFH8GAAMIAAIIZQuvJwCAAAAIAAIIZQuvJwCAAAAKAAIIuQTAIwBhAAAAAA==.Howlingfjord:BAAAKgAECgcIBwAAAA==.',Ju='Justwrong:BAAAKgAECgYIBwAAAA==.',Ka='Kanata:BAAAKgAFFAIIAgAAAA==.',Li='Linghh:BAAAKgADCgQIBAAAAA==.Lingmu:BAAAKgADCggICAAAAA==.',Lo='Longbeforz:BAABKgAFFH8aAAILAAgIASROAQDnAQALAAgIASROAQDnAQAAAA==.',Ls='Lsskykg:BAAAKgAECgUIBQAAAA==.',Ly='Lyqssr:BAACKgAFFH8QAAMHAAQI9iMKJQADAQAHAAMI9iMKJQADAQAGAAQIFBBbDwCdAAAqAAQKfzEAAwcACAg9Iy4NALsCAAcACAg9Iy4NALsCAAwACAgaDtIcAAgBAAAA.',Ma='Mahzero:BAAAKgAECgMIBQAAAA==.',Mo='Moaobo:BAAAKgADCgEIAQAAAA==.',Mu='Muamua:BAAAKgAECgEIAQAAAA==.',Ni='Nicki:BAAAKgADCgEIAQAAAA==.Nikehunike:BAAAKgAECgUIDAAAAA==.',No='Nobich:BAABKgAFFH8GAAINAAYI8RLcDQBKAQANAAYI8RLcDQBKAQAAAA==.',Pa='Pair:BAABKgAFFH8IAAMIAAQIxAUmGwC1AAAIAAQIxAUmGwC1AAAKAAIIkQl4FgBqAAAAAA==.',Ph='Philemon:BAAAKgADCgQIBgAAAA==.',Po='Powerpuff:BAAAKgAECggICAAAAA==.',Pu='Pulengez:BAAAKgAECgMIAwAAAA==.',Re='Remyuew:BAAAKgAECgQIBAAAAA==.',Rw='Rwerwr:BAAAKgAECggICAAAAA==.',Sd='Sdsadad:BAAAKgAECgUIBgAAAA==.',Si='Sike:BAAAKgAECgMIAwAAAA==.',So='Soft:BAAAKgAECggICAAAAA==.',Th='Themage:BAAAKgAECggICAAAAA==.',Ve='Venuswv:BAAAKgAECgUIBgAAAA==.',Vs='Vsolo:BAAAKgAECgYIBwAAAA==.',Vu='Vurnter:BAAAKgADCgYIBgAAAA==.',We='Wefrew:BAAAKgAFFAQIAgAAAA==.',Wi='Wishtoday:BAAAKgAECggIEAAAAA==.',Wo='Wowaxe:BAAAKgAFFAgIBAAAAA==.',['一个']='一个也不能少:BAAAKgAECgEIAQAAAA==.',['一剑']='一剑破虚空:BAABKgAECn8VAAMLAAgIpSTIDQDYAgALAAgIpSTIDQDYAgAOAAEIkBQFUQA9AAAAAA==.',['一壶']='一壶奶茶:BAAAKgAFFAQIBAAAAA==.',['一库']='一库哈撒尅:BAAAKgAECggICQAAAA==.',['一战']='一战神一:BAABKgAFFH8IAAIPAAgIVxSwBABBAgAPAAgIVxSwBABBAgAAAA==.',['一撕']='一撕就得:BAABKgAFFH8WAAQLAAYISBMIIABwAQALAAYISBMIIABwAQAOAAMIiAj8BwDWAAAQAAQIKAZlIwBqAAAAAA==.',['一泥']='一泥菩萨一:BAABKgAFFH8FAAIIAAMIHw2QHACVAAAIAAMIHw2QHACVAAAAAA==.',['一粒']='一粒氮:BAAAKgAECgUIBQAAAA==.',['一骑']='一骑当千:BAABKgAFFH8IAAIQAAgIowg7BwBXAQAQAAgIowg7BwBXAQAAAA==.一骑当千舞丶:BAABKgAECn8WAAILAAcIzB1seQCkAQALAAcIzB1seQCkAQAAAA==.',['一魔']='一魔神一:BAAAKgAECggICAAAAA==.',['七崽']='七崽:BAABKgAFFH8IAAINAAgIVQjJBwBwAQANAAgIVQjJBwBwAQAAAA==.',['七鸢']='七鸢折纸:BAAAKgAFFAIIAgAAAA==.',['万箭']='万箭一:BAAAKgAECgEIAQAAAA==.',['三军']='三军:BAABKgAFFH8KAAMDAAgIMRFiBQAcAgADAAgIMRFiBQAcAgACAAEICQBzNgACAAAAAA==.',['三千']='三千千:BAABKgAECn8gAAMRAAgIMSPSEgA9AgARAAgIMSPSEgA9AgASAAEIAADvHAEAAAAAAA==.',['上官']='上官瑾:BAAAKgADCggIAQAAAA==.',['上帝']='上帝的糖罐:BAAAKgAECggICAAAAA==.',['不胜']='不胜其苦:BAAAKgADCgcIBwAAAA==.',['不要']='不要搓泥宝:BAAAKgADCgEIAQAAAA==.',['东方']='东方壮士:BAAAKgADCggICwAAAA==.',['东风']='东风破四风:BAAAKgADCggICAAAAA==.',['丨一']='丨一个怪咖:BAAAKgAECgQIBAAAAA==.',['丨夜']='丨夜丶落寞:BAAAKgADCggICAAAAA==.',['丨小']='丨小丶智丨:BAAAKgADCggICAAAAA==.',['丨恐']='丨恐惧大魔王:BAAAKgAECgMIAwAAAA==.',['丨无']='丨无敌丶:BAAAKgAECgcICAAAAA==.',['丨灬']='丨灬蕾丝控:BAAAKgADCgYIBgAAAA==.丨灬豹纹控:BAAAKgADCggICAAAAA==.',['丨芷']='丨芷柠丨:BAABKgAFFH8TAAISAAgIMxtTBQBKAgASAAgIMxtTBQBKAgAAAA==.',['丨術']='丨術業有专攻:BAAAKgAFFAYIBAAAAA==.',['丨连']='丨连对丨:BAAAKgADCgUIBQAAAA==.',['丶丽']='丶丽丽酱:BAAAKgAFFAgIBAAAAA==.',['丶他']='丶他二姨:BAAAKgAFFAIIAgAAAA==.',['丶柚']='丶柚子蜜茶:BAAAKgAECgMIAwAAAA==.',['丶欧']='丶欧煌:BAABKgAFFH8MAAITAAYImRmnAQDIAQATAAYImRmnAQDIAQAAAA==.',['丷娘']='丷娘子丷:BAABKgAFFH8GAAIQAAYIiQooEwDiAAAQAAYIiQooEwDiAAABKgAFFAgIGgADAEwhAA==.',['丸言']='丸言丸语丶:BAAAKgAECggICAAAAA==.',['丸里']='丸里丸气丶:BAAAKgAECggIDgAAAA==.',['为了']='为了光明:BAAAKgAECgEIAQAAAA==.',['丿曾']='丿曾经的他:BAAAKgAECgMIBgAAAA==.丿曾经的王:BAAAKgAECgYICgAAAA==.',['丿清']='丿清风:BAAAKgADCggICAAAAA==.',['丿硝']='丿硝酸甘油丶:BAAAKgAECggIAwAAAA==.',['丿胖']='丿胖丶熊熊:BAAAKgAECgYIBgABKgAFFAgIGgANAEgZAA==.',['乌合']='乌合之众:BAABKgAFFH8IAAIUAAQIjAyqGwDWAAAUAAQIjAyqGwDWAAAAAA==.',['乖乖']='乖乖狠:BAAAKgAECgUIBQAAAA==.',['九朝']='九朝感悟:BAAAKgAFFAIIAgAAAA==.',['九朵']='九朵玫瑰恋:BAAAKgAECgEIAQAAAA==.',['二十']='二十二:BAAAKgAECgIIAgAAAA==.',['二楼']='二楼后座:BAAAKgADCgEIAgAAAA==.',['二零']='二零二六无敌:BAABKgAFFH8IAAILAAgIxBw8BwBUAgALAAgIxBw8BwBUAgAAAA==.',['云无']='云无月:BAAAKgAECggICAAAAA==.',['人造']='人造人十八号:BAAAKgADCggICAAAAA==.',['仙帝']='仙帝:BAABKgAFFH8FAAIPAAMIzAaJKACmAAAPAAMIzAaJKACmAAAAAA==.',['以战']='以战养战:BAABKgAFFH8IAAIPAAgIsxSnBABDAgAPAAgIsxSnBABDAgAAAA==.',['仲商']='仲商为期:BAAAKgAFFAgIAgAAAA==.',['伊芙']='伊芙蕾迩:BAAAKgADCgIIAgAAAA==.',['会上']='会上树的海参:BAAAKgAECgEIAQAAAA==.',['会放']='会放闪电的牛:BAAAKgAECgEIAQAAAA==.',['传奇']='传奇感冒王:BAAAKgAFFAYIBAAAAA==.',['佑恋']='佑恋的管家:BAAAKgADCggICAAAAA==.',['你人']='你人还怪好嘞:BAABKgAFFH8GAAIFAAYIBA1VGQA5AQAFAAYIBA1VGQA5AQAAAA==.',['你在']='你在想屁吃:BAAAKgADCgEIAQAAAA==.',['你是']='你是星辰大海:BAACKgAFFH8MAAMFAAgIOx0xBQAkAgAFAAcIVxwxBQAkAgAVAAIIDx2sDQBkAAAqAAQKfxoABBUACAg+Hg0VADQBABUABQi6Gw0VADQBAAQABQi6FkcxACIBAAUABAjDIQ1DAP8AAAAA.',['你的']='你的瞳我的影:BAABKgAECn8ZAAISAAgIYB2WJAAmAgASAAgIYB2WJAAmAgAAAA==.',['你艾']='你艾希我奶吗:BAAAKgAFFAMIAwAAAA==.',['信仰']='信仰之萨:BAAAKgAECgEIAQAAAA==.',['俺村']='俺村灬我最帅:BAAAKgAECggICAAAAA==.',['傲娇']='傲娇信仰:BAABKgAFFH8OAAMWAAgIahntBQDWAQAWAAgIngztBQDWAQANAAYIlh3wBQCuAQAAAA==.',['傷别']='傷别灕灬逍遥:BAAAKgAFFAIIAgAAAA==.',['元泽']='元泽:BAAAKgADCgEIAQAAAA==.',['克雷']='克雷斯波:BAABKgAFFH8IAAIFAAgITxATBgAQAgAFAAgITxATBgAQAgAAAA==.',['兔八']='兔八哥:BAAAKgAECgQIBAAAAA==.',['八尾']='八尾:BAABKgAFFH8IAAIIAAMI+RR1GACxAAAIAAMI+RR1GACxAAAAAA==.',['八零']='八零扶墙输出:BAABKgAFFH8LAAMEAAIIxBaoGACIAAAEAAIIxBaoGACIAAAFAAIIqRE9KwBdAAAAAA==.八零落地输出:BAAAKgADCggICAAAAA==.',['关羽']='关羽:BAAAKgAFFAQIBAAAAA==.',['其锐']='其锐:BAAAKgADCgEIAQAAAA==.',['兽刃']='兽刃永不为奴:BAABKgAFFH8IAAMXAAUIdArGIACLAAAXAAMIGgbGIACLAAAPAAII+xAbLwCAAAAAAA==.',['再次']='再次野性生长:BAAAKgADCgEIAQAAAA==.',['冲你']='冲你丫的:BAABKgAFFH8OAAMXAAYIih+fBQDPAQAXAAYIih+fBQDPAQAPAAQIEQwRFgDXAAAAAA==.',['冷小']='冷小熙:BAAAKgAFFAMIAwAAAA==.',['冷萃']='冷萃星冰乐:BAAAKgAFFAgIAgAAAA==.',['冼燊']='冼燊楠:BAAAKgADCgQIBAAAAA==.',['凰尚']='凰尚:BAAAKgAECgYIBgAAAA==.',['刷坐']='刷坐骑专用:BAABKgAFFH8FAAICAAMIEguhHwBjAAACAAMIEguhHwBjAAAAAA==.',['削其']='削其骨為笛:BAABKgAFFH8OAAMCAAgI2xHTCACLAQACAAgIqQzTCACLAQADAAYISRBTCwBcAQAAAA==.',['剑雨']='剑雨魂:BAAAKgAECgUICQAAAA==.',['北冥']='北冥丶光:BAAAKgAECgYIDgAAAA==.',['北铁']='北铁:BAAAKgADCgEIAQAAAA==.',['区区']='区区不才:BAABKgAECn8VAAQNAAcI2hV3SQATAQANAAYIWxd3SQATAQAYAAUIYwt9TQC3AAAWAAQI/QsRcgByAAAAAA==.',['十一']='十一爹:BAAAKgAECgUIBQAAAA==.',['印第']='印第安老斑鸠:BAABKgAFFH8GAAILAAMIbhEbTwDRAAALAAMIbhEbTwDRAAAAAA==.',['又要']='又要改名字:BAABKgAFFH8HAAMJAAMI1w84IQB/AAAZAAIIMxeCNgCIAAAJAAMIzgU4IQB/AAAAAA==.',['双子']='双子十二星:BAAAKgAECgYIBgAAAA==.',['发糖']='发糖专业户:BAAAKgADCgEIAQAAAA==.',['可一']='可一可再:BAAAKgAECggICAABKgAFFAgIFAARAJwjAA==.',['可乐']='可乐爆米花:BAABKgAFFH8IAAMaAAQIlRjgBQDgAAAaAAQI3xbgBQDgAAAUAAQIQAzrGwDVAAAAAA==.',['可爱']='可爱包包:BAABKgAFFH8LAAICAAMIPgSGLABhAAACAAMIPgSGLABhAAAAAA==.',['吃猫']='吃猫卡死的鱼:BAAAKgAECgEIAQAAAA==.',['各有']='各有所爱:BAAAKgAECgEIAQAAAA==.',['吉祥']='吉祥三宝:BAAAKgADCgIIAgAAAA==.',['吕奉']='吕奉先:BAAAKgAECggIDwAAAA==.',['呆萌']='呆萌小魔丶:BAABKgAECn8XAAIUAAgIxhZpRQCSAQAUAAgIxhZpRQCSAQAAAA==.',['命运']='命运终焉:BAABKgAFFH8OAAMVAAYI2SIkBwASAQAVAAQIMCQkBwASAQAFAAYIpxT6LwCuAAAAAA==.',['咕叽']='咕叽咕叽:BAAAKgAECgQIBAAAAA==.咕叽咕叽咪:BAAAKgAECggICQAAAA==.咕叽咕叽牧:BAAAKgAFFAgIBAAAAA==.',['哥们']='哥们够猛:BAAAKgAECgYIBgAAAA==.',['唤醒']='唤醒沉睡的伱:BAABKgAFFH8MAAMWAAQIniJzBgAuAQAWAAQIniJzBgAuAQANAAQI/RLTCgDeAAAAAA==.',['善意']='善意的坏:BAAAKgADCggIGQAAAA==.',['喜剧']='喜剧赢家:BAAAKgAFFAQIBAABKgAFFAgIBAAbAAAAAA==.',['嗷买']='嗷买呷德:BAAAKgAECgEIAQAAAA==.',['嚣张']='嚣张小老头:BAAAKgADCggICAAAAA==.',['团长']='团长的丈母娘:BAAAKgAECgYIBgAAAA==.',['囯囝']='囯囝:BAAAKgAECgUIBQAAAA==.',['圣光']='圣光一审判:BAAAKgAFFAEIAQAAAA==.圣光闪现:BAABKgAECn8nAAMOAAgI4RE8DgArAQAOAAgI4RE8DgArAQAQAAQIhwJhUwA1AAAAAA==.',['圣迪']='圣迪凯:BAAAKgAECgQIBAAAAA==.',['壹个']='壹个丿承诺:BAAAKgADCgIIAgAAAA==.',['夏末']='夏末丶梅梅:BAAAKgAECgcIDgAAAA==.',['夏沫']='夏沫秋初:BAABKgAFFH8FAAINAAMIxwSeGgBoAAANAAMIxwSeGgBoAAAAAA==.',['夜曲']='夜曲:BAAAKgADCggICAAAAA==.',['夜绾']='夜绾绾:BAABKgAFFH8KAAILAAgIlQveGwAEAQALAAgIlQveGwAEAQAAAA==.',['大哥']='大哥灬别开炮:BAAAKgAECggICAAAAA==.',['大海']='大海的女婿:BAAAKgAECggICAABKgAFFAgIEQAHAEEeAA==.',['大红']='大红哥:BAAAKgADCgEIAQAAAA==.',['天下']='天下雨狼嫁人:BAAAKgADCggICAAAAA==.',['天壤']='天壤梦弓:BAAAKgAECggICAAAAA==.',['天才']='天才麻酱少女:BAAAKgAECgYIBgAAAA==.',['天秤']='天秤座的偶:BAAAKgADCgcIBwAAAA==.',['太极']='太极生两姨:BAAAKgAECgEIAQAAAA==.',['失忆']='失忆的猫咪:BAAAKgAECgYICQAAAA==.',['女帝']='女帝柳如烟:BAABKgAFFH8JAAMGAAMIiQjFJwCGAAAGAAMIiQjFJwCGAAAHAAEIBwb4YAA2AAAAAA==.',['威大']='威大世航:BAAAKgAFFAYIBAABKgAFFAgIBgACABkJAA==.',['嬅木']='嬅木兰:BAAAKgAECgQIBQABKgAFFAgIPQASAOAjAA==.',['孤独']='孤独巡礼:BAAAKgADCgIIAgAAAA==.',['宅翔']='宅翔打松鼠丶:BAAAKgADCggICAAAAA==.',['寂寞']='寂寞的小萨:BAABKgAECn89AAMIAAgIMBbaFQCHAQAIAAgIMBbaFQCHAQAcAAIIiQJaSgAmAAAAAA==.',['小勋']='小勋勛:BAABKgAFFH8FAAIFAAUI5xe9GgAvAQAFAAUI5xe9GgAvAQABKgAFFAgIBAAbAAAAAA==.',['小小']='小小紫紫:BAAAKgAFFAgIBAAAAA==.小小迪奥:BAAAKgAECgUIBgAAAA==.',['小幻']='小幻彩:BAABKgAFFH8FAAICAAUIWAYZIQCdAAACAAUIWAYZIQCdAAAAAA==.',['小木']='小木木:BAAAKgAECgUIBQAAAA==.',['小橙']='小橙子灬:BAAAKgAECgEIAgAAAA==.',['小蜗']='小蜗牛快跑:BAAAKgADCggICQAAAA==.',['小钢']='小钢板:BAAAKgAECggIDgAAAA==.',['小马']='小马:BAAAKgADCgQIBAAAAA==.',['少侠']='少侠自重:BAAAKgADCggIDQAAAA==.',['尼哥']='尼哥:BAAAKgAECgcIBwAAAA==.',['尾行']='尾行:BAAAKgADCgEIAQAAAA==.',['巫炎']='巫炎卆:BAAAKgAFFAgIBAAAAA==.',['巴根']='巴根:BAAAKgAECgEIAQAAAA==.',['布萊']='布萊恩铜须:BAAAKgAECgUIBgAAAA==.',['布零']='布零布铃:BAAAKgAECgEIAQAAAA==.',['帅大']='帅大哥恶:BAAAKgADCgEIAQAAAA==.',['希伊']='希伊凹削:BAAAKgADCgIIAgAAAA==.',['希绪']='希绪弗斯:BAABKgAFFH8IAAIRAAgItBI+BgAHAgARAAgItBI+BgAHAgAAAA==.',['帝天']='帝天钧:BAABKgAFFH8FAAIRAAMI6Am+KADHAAARAAMI6Am+KADHAAAAAA==.',['带易']='带易难不难:BAABKgAFFH8FAAMYAAQIwhTDHACfAAAYAAIIBRTDHACfAAANAAIIyRVtLACSAAAAAA==.',['幕后']='幕后老板:BAAAKgAECgQIBAAAAA==.',['幻塵']='幻塵:BAAAKgAECgUIBQAAAA==.',['开盖']='开盖有蒋:BAABKgAFFH8OAAMKAAMI0wbLGgClAAAKAAMI0wbLGgClAAAIAAMIrQshHACXAAAAAA==.',['弑血']='弑血残痕:BAABKgAFFH8MAAMJAAMIoR8EDAAKAQAJAAMIoR8EDAAKAQAZAAII3ga4PgBhAAAAAA==.',['当时']='当时繁星陨:BAAAKgADCggICAAAAA==.',['御灵']='御灵胧:BAAAKgAECgUIBQAAAA==.',['心情']='心情烦躁:BAAAKgADCgEIAQAAAA==.心情煩燥:BAAAKgAECgIIAgAAAA==.',['忄寶']='忄寶寶出沒:BAABKgAFFH8GAAMIAAYIhBMbJADnAAAIAAUIrg4bJADnAAAcAAEIaB1dHABRAAAAAA==.',['必中']='必中大奖:BAAAKgADCgQIBAAAAA==.',['忆兮']='忆兮:BAAAKgADCgIIAgAAAA==.',['思路']='思路的小萨:BAAAKgAECgQIAwAAAA==.',['怨念']='怨念:BAAAKgADCgQIBAAAAA==.',['恭喜']='恭喜我这个逼:BAAAKgAECggICAAAAA==.',['情人']='情人游天地:BAABKgAFFH8FAAIBAAUIBBY6EwAfAQABAAUIBBY6EwAfAQAAAA==.',['情深']='情深终化蝶:BAAAKgAECggIDQAAAA==.',['惟有']='惟有时光:BAAAKgADCggICAAAAA==.',['想名']='想名字头晕:BAAAKgAECgEIAQAAAA==.',['懒惰']='懒惰的小苏:BAAAKgAFFAEIAQAAAA==.',['成大']='成大器:BAABKgAFFH8OAAISAAgI7xGLGAA3AQASAAgI7xGLGAA3AQAAAA==.',['我是']='我是贰货:BAAAKgAECgIIAgAAAA==.',['我纯']='我纯故我在:BAAAKgAFFAYIAgAAAA==.',['我胖']='我胖古我壮:BAAAKgADCgcIBwAAAA==.',['我赌']='我赌你看不到:BAAAKgAECgYIBgAAAA==.',['战无']='战无不胜:BAAAKgAFFAYIBAAAAA==.',['戳圈']='戳圈先生:BAAAKgAECgEIAQAAAA==.',['手提']='手提西瓜刀:BAAAKgAECgMIAwAAAA==.',['抵制']='抵制日货之狼:BAABKgAFFH8GAAIHAAYIaiQPCwDkAQAHAAYIaiQPCwDkAQAAAA==.',['抹不']='抹不去的谜途:BAAAKgAECgIIAQAAAA==.',['拾取']='拾取绑定:BAAAKgAECgMIAwAAAA==.',['搞不']='搞不懂的大圣:BAAAKgADCggICAAAAA==.',['摇铃']='摇铃唤白鹿:BAAAKgAECggICAAAAA==.',['摩西']='摩西:BAAAKgAECggICAAAAA==.',['擂擂']='擂擂:BAAAKgAECgYIBgAAAA==.',['收音']='收音机:BAAAKgAECgUICQAAAA==.',['放逐']='放逐的青春丶:BAABKgAFFH8NAAIDAAQIQRc6KgDkAAADAAQIQRc6KgDkAAAAAA==.',['救祓']='救祓少女:BAABKgAFFH8TAAIUAAYI5BUXAwC1AQAUAAYI5BUXAwC1AQAAAA==.',['文轩']='文轩苒義:BAABKgAFFH8QAAIBAAgIchQjBQBBAgABAAgIchQjBQBBAgAAAA==.',['施主']='施主您过了:BAAAKgAECgUICQAAAA==.',['旅艾']='旅艾华侨:BAAAKgAECgYIDAAAAA==.',['昊闪']='昊闪祯雷:BAAAKgADCgEIAQAAAA==.',['星星']='星星堆满天:BAAAKgADCggIDwAAAA==.',['春风']='春风扶山峦:BAABKgAFFH8IAAICAAgIrRv2AQBRAgACAAgIrRv2AQBRAgAAAA==.春风扶山间:BAABKgAFFH8IAAIRAAgIuRXjBQD8AQARAAgIuRXjBQD8AQAAAA==.',['晨晨']='晨晨清颖:BAAAKgAECgYIBgAAAA==.',['晴天']='晴天小荔枝:BAAAKgAECgMIAwAAAA==.',['有奖']='有奖竞猜:BAABKgAFFH8JAAILAAgIZiSGAgDLAgALAAgIZiSGAgDLAgAAAA==.',['朱元']='朱元璋:BAABKgAFFH8GAAIdAAIIGQjUCgBkAAAdAAIIGQjUCgBkAAAAAA==.',['朱星']='朱星寒:BAABKgAECn8YAAIIAAcIbh3XJAD9AQAIAAcIbh3XJAD9AQAAAA==.',['杀戮']='杀戮小夜曲:BAABKgAFFH8IAAIIAAgICg/tBQDOAQAIAAgICg/tBQDOAQAAAA==.',['杜泽']='杜泽尔:BAAAKgADCggIBgAAAA==.',['来碗']='来碗沙冰:BAAAKgAECgMIAwAAAA==.',['杨林']='杨林欧:BAABKgAECn88AAQSAAgI6yFWEACjAgASAAgIxyFWEACjAgARAAcIxRlHLwCkAQAeAAUIew90DwDYAAAAAA==.',['松鼠']='松鼠的圣光:BAAAKgADCggICAAAAA==.',['果冻']='果冻小战:BAAAKgAECgYICQAAAA==.果冻小骑士:BAAAKgAECgIIAQAAAA==.',['枫之']='枫之语:BAABKgAFFH8PAAIRAAUIoBJxEADyAAARAAUIoBJxEADyAAAAAA==.',['枭熊']='枭熊:BAABKgAECn8UAAQHAAgIsRaSMgDxAQAHAAgIsRaSMgDxAQAGAAMIxw91VQCPAAAMAAEIvQhHRQARAAAAAA==.',['柳西']='柳西:BAAAKgAECgUIBQAAAA==.',['梅莉']='梅莉公爵:BAAAKgAFFAIIAgAAAA==.',['梦断']='梦断阿拉希:BAAAKgAECgEIAQAAAA==.',['梦魇']='梦魇幻魔:BAAAKgAFFAgIBAAAAA==.',['棋盘']='棋盘山老司机:BAABKgAFFH8aAAMSAAYIzh7wCwCwAQASAAYIzh7wCwCwAQARAAQImRStMQCpAAAAAA==.',['楠雨']='楠雨割舍:BAAAKgADCgIIAgAAAA==.',['武器']='武器大師陳派:BAAAKgAECgEIAQAAAA==.',['殘靈']='殘靈之殤:BAAAKgAECgQIBAAAAA==.',['比丝']='比丝姬:BAAAKgAECggIDwAAAA==.',['水瓶']='水瓶:BAAAKgAFFAYIAgAAAA==.',['沉默']='沉默还是谎言:BAAAKgAECgUICQAAAA==.',['沐丶']='沐丶辰曦:BAABKgAFFH8GAAILAAYIcADBgABjAAALAAYIcADBgABjAAAAAA==.',['法号']='法号仪琳:BAAAKgAECggICAAAAA==.',['注满']='注满老马:BAAAKgAECgYIBgAAAA==.',['泰兰']='泰兰徳:BAAAKgAFFAIIAgAAAA==.',['活泼']='活泼的小猪:BAAAKgAECgEIAQAAAA==.',['海盗']='海盗伯爵:BAAAKgAECgEIAgABKgAFFAMIAwAbAAAAAA==.海盗小男爵:BAAAKgAFFAMIAwAAAA==.',['淘气']='淘气依旧:BAABKgAFFH8GAAIFAAQIhySVDgClAQAFAAQIhySVDgClAQAAAA==.',['深巷']='深巷:BAAAKgAECgcIDAAAAA==.',['混子']='混子中的疯子:BAABKgAFFH8IAAILAAMIIQYLNACRAAALAAMIIQYLNACRAAAAAA==.',['温柔']='温柔的诗:BAABKgAFFH8GAAIFAAYIsQ03EwBsAQAFAAYIsQ03EwBsAQAAAA==.',['漫步']='漫步经心:BAABKgAFFH8FAAMJAAMI3QhYJQBoAAAJAAII7QZYJQBoAAAZAAEIvAz0RAA+AAAAAA==.',['潇潇']='潇潇炽雨:BAAAKgAFFAQIBAAAAA==.',['灌奶']='灌奶茶高手:BAAAKgADCgEIAQAAAA==.',['灬夜']='灬夜枫丶殇:BAAAKgAECgQIBAAAAA==.',['灬格']='灬格格乐乐灬:BAAAKgADCggICAAAAA==.灬格格优优灬:BAAAKgADCgQIBAAAAA==.灬格格冲冲灬:BAAAKgADCgEIAQAAAA==.灬格格宝宝灬:BAAAKgADCgQIBAAAAA==.灬格格幽幽灬:BAAAKgADCgIIAgAAAA==.灬格格无敌灬:BAAAKgADCgEIAQAAAA==.灬格格笑灬:BAAAKgADCgQIBAAAAA==.灬格格萨萨灬:BAAAKgAECgUIBQAAAA==.',['灬游']='灬游走边缘灬:BAAAKgAFFAMIAwAAAA==.',['灬灬']='灬灬清風:BAABKgAFFH8MAAILAAgI7QiVDgC3AQALAAgI7QiVDgC3AQAAAA==.',['灬芬']='灬芬达:BAAAKgAECgMIAwAAAA==.',['灬荡']='灬荡丶妇灬:BAAAKgADCgUIBQAAAA==.',['点门']='点门拉人:BAAAKgADCgYIBQAAAA==.',['無名']='無名十哲:BAABKgAECn8UAAMKAAcI3xf+JACoAQAKAAcI3xf+JACoAQAIAAIIJBY0lACAAAAAAA==.',['熊小']='熊小熊:BAAAKgADCggICAAAAA==.',['熏大']='熏大聖:BAAAKgADCggICAAAAA==.',['爱与']='爱与救赎:BAABKgAECn8XAAINAAcIGQcgYQC8AAANAAcIGQcgYQC8AAAAAA==.',['爱丶']='爱丶谁誰:BAAAKgAECgEIAQAAAA==.',['爱以']='爱以惜为贵:BAAAKgADCgIIAgAAAA==.',['爱琴']='爱琴海中渔:BAABKgAFFH8KAAMZAAYI0SKBCgDDAQAZAAYIpCGBCgDDAQAJAAII5CAEHgCVAAAAAA==.',['牛有']='牛有德:BAAAKgADCgQIBAAAAA==.',['狂野']='狂野奈德利:BAAAKgADCgEIAQAAAA==.',['狐不']='狐不皈:BAAAKgADCgEIAQAAAA==.',['狐九']='狐九:BAACKgAFFH8KAAIIAAMIFiRSGAAgAQAIAAMIFiRSGAAgAQAqAAQKfxUAAggACAgWHSAoAOwBAAgACAgWHSAoAOwBAAEqAAUUAwgMAAkAoR8A.',['独孤']='独孤苍健:BAACKgAFFH8RAAILAAMI3CCsNwANAQALAAMI3CCsNwANAQAqAAQKfykAAgsACAh0I/4UALUCAAsACAh0I/4UALUCAAAA.',['猎行']='猎行夜影:BAAAKgAFFAMIAwAAAA==.',['猫九']='猫九:BAAAKgADCgEIAgAAAA==.',['猫蒟']='猫蒟蒻:BAAAKgADCggICAAAAA==.',['玩个']='玩个圣骑:BAAAKgADCggIEQAAAA==.',['玫猫']='玫猫饼丶:BAAAKgAECggICQABKgAFFAgIFAAfAMYaAA==.',['玲儿']='玲儿:BAAAKgAECggICAAAAA==.',['球状']='球状闪电:BAABKgAECn8YAAMKAAgIHx55EQBJAgAKAAgIHx55EQBJAgAIAAYIMgyMmgBxAAAAAA==.',['瓦伦']='瓦伦西亚:BAAAKgADCgQIBAAAAA==.',['疯人']='疯人院丶木丝:BAAAKgADCgEIAQAAAA==.疯人院丶猎手:BAAAKgADCggIDAAAAA==.疯人院丶院长:BAAAKgADCgYIBgAAAA==.',['白云']='白云瑞:BAAAKgADCggICAAAAA==.',['白海']='白海魔:BAABKgAFFH8KAAISAAQI1xHzMADIAAASAAQI1xHzMADIAAAAAA==.',['白狐']='白狐妖姬:BAACKgAFFH8FAAILAAMI5w18PwCJAAALAAMI5w18PwCJAAAqAAQKfx4AAwsACAjGHa1qAMQBAAsACAjGHa1qAMQBABAABggdEU4RAPoAAAAA.',['白色']='白色鸢尾:BAACKgAFFH8YAAIUAAgIViN8AgDKAgAUAAgIViN8AgDKAgAqAAQKfxgAAhQACAh4IJgqAAsCABQACAh4IJgqAAsCAAAA.',['相当']='相当凶残:BAABKgAFFH8IAAMXAAQIoxv6BAAUAQAXAAQIoxv6BAAUAQAPAAQItw3aFADhAAABKgAFFAgIDAAZAFcXAA==.',['相思']='相思花海:BAAAKgAECggIDwAAAA==.',['看上']='看上去啊很刁:BAABKgAFFH8GAAIIAAQIWQ3TFQDNAAAIAAQIWQ3TFQDNAAAAAA==.',['看我']='看我哭的样子:BAAAKgAECggICAAAAA==.',['看箭']='看箭:BAAAKgADCgQIBAAAAA==.',['真丶']='真丶不正常:BAAAKgAFFAIIAgAAAA==.',['督军']='督军九歌:BAABKgAFFH8GAAIXAAYIFBZsCACEAQAXAAYIFBZsCACEAQABKgAFFAgIDgAPAK4iAA==.',['矫治']='矫治:BAABKgAFFH8UAAIfAAgIHQwzBwDEAQAfAAgIHQwzBwDEAQAAAA==.',['社长']='社长爱用手:BAAAKgAECgEIAQAAAA==.',['祈淵']='祈淵:BAAAKgAECgEIAQAAAA==.',['神丶']='神丶灵:BAAAKgADCgMIAwAAAA==.',['神圣']='神圣十字军:BAAAKgAECgMIAwAAAA==.',['神武']='神武雷行:BAAAKgAFFAMIAwAAAA==.',['票票']='票票欲仙:BAAAKgADCgMIAwAAAA==.',['竞技']='竞技场之神:BAAAKgADCgIIAgAAAA==.',['章鱼']='章鱼小丸子:BAAAKgAECggIDgABKgAFFAgIDQAgAPEVAA==.',['笑看']='笑看風雲:BAAAKgADCggICAAAAA==.',['精术']='精术济世:BAABKgAECn8eAAIIAAgIpweFcADbAAAIAAgIpweFcADbAAAAAA==.',['精神']='精神的铁虎:BAAAKgAFFAMIAwAAAA==.',['紫瞳']='紫瞳暮影:BAACKgAFFH8hAAQYAAgIsB0ZBAAnAgAYAAcIsR8ZBAAnAgANAAcIghuMDADUAAAWAAQIfxFiHwCmAAAqAAQKfxcAAg0ACAinFxMkAMUBAA0ACAinFxMkAMUBAAAA.',['紫荆']='紫荆藤:BAAAKgAECgcICAAAAA==.紫荆雨:BAAAKgADCggIDgAAAA==.',['絶色']='絶色傾澄:BAABKgAFFH8KAAIUAAYIgx+gCwDNAQAUAAYIgx+gCwDNAQAAAA==.',['纠结']='纠结的小德:BAAAKgAFFAYIBAAAAA==.',['红星']='红星二锅头:BAAAKgAFFAMIBAAAAA==.',['红运']='红运本命年:BAAAKgADCgQIBAAAAA==.',['红颜']='红颜如霜:BAABKgAFFH8GAAMJAAYIVxFzFQDAAAAJAAQIoRhzFQDAAAAgAAIIaAYBKACAAAAAAA==.',['纯洁']='纯洁的大叔:BAACKgAFFH8IAAIHAAMIHQwlPAC2AAAHAAMIHQwlPAC2AAAqAAQKfxUAAwcACAjlFdBDAJoBAAcABwhXF9BDAJoBACEAAwgSC7cjAIkAAAAA.',['绝世']='绝世关云长:BAACKgAFFH8FAAILAAMIGA1kJwDUAAALAAMIGA1kJwDUAAAqAAQKfyMAAgsACAivIkQhAJQCAAsACAivIkQhAJQCAAAA.绝世小辣椒:BAAAKgADCgYIBgAAAA==.',['维特']='维特:BAABKgAFFH8JAAMHAAMIZBGoOQC9AAAHAAMIZBGoOQC9AAAGAAEIPwO2OgAtAAAAAA==.',['美丽']='美丽要打折:BAABKgAFFH8GAAIdAAYIWSSbAQAaAgAdAAYIWSSbAQAaAgAAAA==.',['羞羞']='羞羞小布丁:BAAAKgAECggICwAAAA==.',['老漠']='老漠:BAAAKgAECgEIAQAAAA==.',['老牛']='老牛鼻了:BAAAKgAECggICwAAAA==.',['花麟']='花麟龙:BAAAKgAECgUIBQAAAA==.',['苦根']='苦根:BAAAKgAECggIDwAAAA==.',['苯并']='苯并吡咯:BAAAKgADCgcIBwAAAA==.',['苹果']='苹果乖不哭:BAAAKgAFFAEIAQAAAA==.',['莉莉']='莉莉沙:BAAAKgAECgMIAwAAAA==.',['菸壮']='菸壮壮:BAAAKgADCgEIAQAAAA==.',['萌萌']='萌萌大咕咕:BAAAKgAFFAQIBAAAAA==.',['萨莉']='萨莉怀特迈恩:BAABKgAFFH8GAAIWAAYIexLrCgBnAQAWAAYIexLrCgBnAQAAAA==.',['蒋伯']='蒋伯芳:BAAAKgADCgUIBQAAAA==.',['蒙牙']='蒙牙:BAABKgAFFH8FAAIRAAMINQ7GLwCvAAARAAMINQ7GLwCvAAAAAA==.',['蓝色']='蓝色毒药:BAAAKgAECgcIBwAAAA==.',['蓝若']='蓝若林:BAABKgAFFH8GAAILAAYINx4ZIABvAQALAAYINx4ZIABvAQAAAA==.',['蔑世']='蔑世审判:BAAAKgAECgEIAQAAAA==.',['蛮汉']='蛮汉:BAAAKgADCgMIAwAAAA==.',['血之']='血之哈梅尔:BAAAKgAECgcIBwAAAA==.',['裘千']='裘千尺:BAABKgAFFH8KAAITAAYIQQ0qCgBBAQATAAYIQQ0qCgBBAQAAAA==.',['訫緖']='訫緖:BAAAKgAECgQIBAAAAA==.',['詮釋']='詮釋我的痛:BAAAKgAECgEIAQAAAA==.',['誰懂']='誰懂爺的芯:BAAAKgAECgcIDwAAAA==.',['让我']='让我进本吧:BAABKgAFFH8JAAMPAAYINCDyEQA5AQAPAAYI3R/yEQA5AQAXAAIIHR49CgDLAAABKgAFFAgIKwAPAC4VAA==.',['诺克']='诺克图娜迩:BAAAKgAECgEIAQAAAA==.',['贝爷']='贝爷专属厨师:BAABKgAFFH8fAAMHAAgI4R4ZAwCrAgAHAAgI4R4ZAwCrAgAGAAQI7yFfDwAlAQAAAA==.',['贾百']='贾百万:BAAAKgAFFAIIAwAAAA==.',['赛茜']='赛茜莉雅:BAAAKgAFFAQIBAAAAA==.',['超速']='超速的小蜗牛:BAAAKgADCggIDQAAAA==.',['跡美']='跡美朱理:BAAAKgAECgUIBQAAAA==.',['辽宁']='辽宁丨铁人:BAAAKgAFFAQIBAAAAA==.',['达瓦']='达瓦里氏:BAABKgAFFH8QAAIfAAYIERJdAwCRAQAfAAYIERJdAwCRAQAAAA==.',['达蒙']='达蒙丶玛特:BAAAKgAFFAYIBAAAAA==.',['过期']='过期牛扒:BAABKgAFFH8JAAIfAAQILxmfEQDeAAAfAAQILxmfEQDeAAAAAA==.',['运儿']='运儿:BAABKgAFFH8IAAIPAAgIWxjNAwB9AgAPAAgIWxjNAwB9AgAAAA==.',['这把']='这把必出:BAAAKgAECgEIAQAAAA==.',['远程']='远程象征:BAABKgAFFH8IAAMSAAQILR3QFwDxAAASAAQIkxfQFwDxAAARAAQI2xzJKADHAAAAAA==.',['迷惑']='迷惑丶猫:BAAAKgADCgEIAQAAAA==.',['迷糊']='迷糊瞄:BAAAKgADCggICAAAAA==.',['那边']='那边那个小德:BAAAKgAECgMIAwAAAA==.',['邪月']='邪月苍炎:BAAAKgAECggIEQAAAA==.',['鄙人']='鄙人很烦:BAAAKgAFFAIIAgAAAA==.',['醉染']='醉染青山:BAABKgAFFH8GAAIJAAIIyRfIHQCXAAAJAAIIyRfIHQCXAAAAAA==.',['醒时']='醒时春山:BAABKgAFFH8XAAMiAAMIwh6kBgADAQAiAAMIwh6kBgADAQADAAEILwGkVwAkAAABKgAFFAgIDgALACocAA==.',['金钢']='金钢牛:BAAAKgAFFAMIAwAAAA==.',['钢铁']='钢铁柱:BAAAKgAECgMIAwAAAA==.',['长天']='长天:BAAAKgAFFAYIAgAAAA==.',['长臂']='长臂猴:BAAAKgADCgEIAQAAAA==.',['阎罗']='阎罗小花:BAABKgAECn8XAAILAAgI9h/BLgBlAgALAAgI9h/BLgBlAgAAAA==.',['阿拉']='阿拉玛:BAAAKgADCgUIBQAAAA==.',['随地']='随地大变:BAAAKgADCgQIBAAAAA==.',['随缘']='随缘丶:BAAAKgADCggICAAAAA==.',['雄赳']='雄赳赳气昂昂:BAACKgAFFH8MAAMSAAMIERjPLQDRAAASAAMITBXPLQDRAAARAAMIHwxSNQCeAAAqAAQKfxwAAhIACAj8HdwmAFgCABIACAj8HdwmAFgCAAAA.',['雑魚']='雑魚:BAAAKgADCggIEAAAAA==.',['雙灬']='雙灬米:BAABKgAECn8YAAMRAAgIWB6tCQA6AgARAAgIHBytCQA6AgASAAgI/R1rKgAGAgAAAA==.',['雨落']='雨落天上:BAAAKgADCgUIBQAAAA==.雨落天下:BAAAKgAECgYICgAAAA==.雨落天晴:BAAAKgAECgYICAAAAA==.',['雪之']='雪之小样:BAABKgAFFH8FAAILAAMIKyRkLwCxAAALAAMIKyRkLwCxAAAAAA==.',['零捌']='零捌肆:BAABKgAFFH8IAAIUAAgI9RW/BgA1AgAUAAgI9RW/BgA1AgAAAA==.',['雷古']='雷古路斯:BAAAKgAFFAgIBAAAAA==.',['露茜']='露茜亚:BAAAKgAECgIIAgAAAA==.',['青衫']='青衫:BAACKgAFFH8ZAAMgAAUIRRNHFAAYAQAgAAUIRRNHFAAYAQAZAAEIAAAJTAAAAAAqAAQKfyEAAyAACAjwGzUhAC0CACAACAjwGzUhAC0CAAkAAQiZDqp5ADIAAAAA.',['青钢']='青钢间:BAAAKgADCggIEAAAAA==.',['顺应']='顺应天意:BAAAKgAFFAQIBAAAAA==.',['风再']='风再起时:BAAAKgAECgYICAAAAA==.',['风霜']='风霜月:BAAAKgAFFAYIBAABKgAFFAgIAQAfALEJAA==.',['飞翼']='飞翼共轻狂丶:BAAAKgAECgIIAgAAAA==.',['骑士']='骑士波波:BAAAKgAECgIIAgAAAA==.',['骑得']='骑得隆冬强:BAAAKgADCgEIAQAAAA==.',['骑着']='骑着小猪看星:BAABKgAECn8gAAMFAAYIgRI/PwAOAQAFAAYIgRI/PwAOAQAEAAEIAACkiwAAAAAAAA==.',['骗老']='骗老头医保:BAAAKgAECggIDAAAAA==.',['高端']='高端黑:BAAAKgADCggICAAAAA==.',['鬼舞']='鬼舞天泉:BAABKgAFFH8IAAMQAAQIvRLSGwCaAAAQAAQIGhLSGwCaAAALAAIIvw3tRwBrAAAAAA==.鬼舞妞妞:BAABKgAECn8ZAAIJAAgIYhyzGADvAQAJAAgIYhyzGADvAQAAAA==.鬼舞少昊:BAABKgAFFH8HAAIfAAcI2hGpBwB/AQAfAAcI2hGpBwB/AQAAAA==.鬼舞雪儿:BAABKgAFFH8LAAIUAAQIEBRYLADIAAAUAAQIEBRYLADIAAAAAA==.',['魑魅']='魑魅梦魇:BAAAKgADCggICgAAAA==.',['魔法']='魔法小鱼儿:BAAAKgAECgUIBQAAAA==.',['鲨鱼']='鲨鱼一辣椒:BAACKgAFFH8GAAIDAAQI7AtmGQDLAAADAAQI7AtmGQDLAAAqAAQKfxgAAwIACAhMHtEQACsCAAIACAg1HdEQACsCACIACAg0GyERAIQBAAAA.',['鴉九']='鴉九:BAAAKgADCggICAAAAA==.',['麻药']='麻药搜查官:BAAAKgAECggIAgAAAA==.',['黑不']='黑不流球就行:BAAAKgAECgQIBAAAAA==.',['黑丶']='黑丶夜:BAAAKgADCggICAAAAA==.',['鼠鼠']='鼠鼠猫个个:BAAAKgAECggICAAAAA==.',['齐碎']='齐碎:BAAAKgADCggIDwAAAA==.',['龘龘']='龘龘蛇:BAAAKgAECgYIBgAAAA==.',['龙里']='龙里格隆:BAABKgAECn8aAAIjAAgInhqoBQA8AgAjAAgInhqoBQA8AgAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end