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
 local lookup = {'Evoker-Devastation','Shaman-Enhancement','Shaman-Elemental','Monk-Brewmaster','Evoker-Preservation','Priest-Holy','Shaman-Restoration','Paladin-Retribution','Paladin-Protection','Warlock-Affliction','Warlock-Destruction','Warlock-Demonology','Hunter-BeastMastery','Hunter-Marksmanship','Warrior-Fury','DemonHunter-Havoc','Unknown-Unknown','Mage-Frost','Mage-Arcane','Warrior-Arms','Priest-Discipline','Mage-Fire','Rogue-Assassination','DemonHunter-Vengeance','Monk-Windwalker','Warrior-Protection','DeathKnight-Blood','DeathKnight-Frost','Druid-Restoration','Druid-Guardian','Druid-Balance','Monk-Mistweaver',}; local provider = {region='CN',realm='巴纳扎尔',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ap='Apollo:BAABKgAFFH8MAAIBAAgI7xWiCQDbAQABAAgI7xWiCQDbAQAAAA==.',At='Attlanta:BAAAKgAECgQIBAAAAA==.',Bc='Bcd:BAAAKgAECgEIAQAAAA==.',Co='Coco:BAAAKgAFFAIIAgAAAA==.',Di='Diegoo:BAAAKgAECggICAAAAA==.',Fr='Freaksoldier:BAAAKgAECgIIAwAAAA==.Freakwarlock:BAAAKgAECggICQAAAA==.Freakydoom:BAAAKgAECggICQAAAA==.Freakydragon:BAAAKgAECgEIAQAAAA==.Freakyfriday:BAAAKgAECgQIBAAAAA==.Freakyhunter:BAAAKgAECgUIBQAAAA==.Freakymonday:BAAAKgAECgIIAgAAAA==.Freakymoon:BAAAKgAECgQIBwAAAA==.Freakypastor:BAAAKgAECggICwAAAA==.Freakytoday:BAAAKgAECgEIAQAAAA==.Freakyweek:BAAAKgAECggIDQAAAA==.',Gh='Ghostdz:BAAAKgAFFAQIBAAAAA==.',He='Hebe:BAAAKgADCgMIAwAAAA==.',Hu='Huntersoul:BAAAKgAECgUIBgAAAA==.',Ko='Kooiki:BAAAKgADCggIEAAAAA==.Kouww:BAACKgAFFH8bAAMCAAYIHhwsBABNAQACAAQI4Q8sBABNAQADAAQITyVICgAmAQAqAAQKfy8AAwMACAgpI8UjANMBAAIABwgcHKMdANsBAAMABwhDIsUjANMBAAAA.',Le='Leeo:BAAAKgAECgQIBAAAAA==.',Me='Menisa:BAAAKgAECgQIBAAAAA==.',On='Onmyoji:BAAAKgADCgcICAAAAA==.',Re='Redeem:BAAAKgADCggICQABKgAFFAgIBgAEAPgLAA==.',Sh='Showfreely:BAAAKgAFFAEIAQAAAA==.',Wa='Wanglinfashi:BAAAKgADCgEIAQAAAA==.',Wi='Windcall:BAABKgAECn8mAAIFAAgIciGzBABYAgAFAAgIciGzBABYAgABKgAFFAgIEwAGAP0gAA==.',Zr='Zrio:BAAAKgAECggICAAAAA==.',['一九']='一九九一:BAAAKgAECgYIBgAAAA==.一九九七:BAAAKgAECgIIAgAAAA==.',['一圣']='一圣光守护一:BAABKgAFFH8IAAIHAAMICA8nNQCoAAAHAAMICA8nNQCoAAAAAA==.',['一小']='一小清纯一:BAAAKgAECgYIDgAAAA==.一小风骚一:BAAAKgAECgQICgAAAA==.',['一道']='一道流星光:BAAAKgAECggICAAAAA==.',['一骑']='一骑当先:BAABKgAECn8eAAMIAAgIERumhQBCAQAIAAgIERumhQBCAQAJAAEIOAI7bwAGAAAAAA==.',['丑孃']='丑孃嬢:BAAAKgAECgUIBQAAAA==.',['东北']='东北猛兽:BAAAKgAECgcIDwAAAA==.',['丰收']='丰收祭:BAAAKgADCgUIBQAAAA==.',['临江']='临江仙:BAAAKgAECgIIAgAAAA==.',['丶晚']='丶晚秋:BAAAKgAFFAQIBAAAAA==.',['丶黃']='丶黃昏:BAAAKgAFFAIIAgAAAA==.',['乌鸦']='乌鸦:BAACKgAFFH8KAAQKAAMI4xxkFACaAAAKAAIIRR5kFACaAAALAAIIChvRNgCVAAAMAAEIyQ1rLQBAAAAqAAQKfx0AAwsACAgoIyEHALgCAAsACAgoIyEHALgCAAoAAghMIFUqAK4AAAAA.',['乙巳']='乙巳蛇年大吉:BAAAKgAECgIIAgAAAA==.',['云尽']='云尽秋:BAAAKgADCggICAAAAA==.',['五晨']='五晨寺主持:BAAAKgAFFAQIBAAAAA==.',['以奶']='以奶服人:BAAAKgAECgQIBwAAAA==.',['休息']='休息达人:BAAAKgADCgMIAwAAAA==.',['会飞']='会飞的小骷髅:BAAAKgADCgIIAgAAAA==.',['伤魄']='伤魄:BAAAKgAFFAQIBAAAAA==.',['你好']='你好玛卡巴卡:BAAAKgADCgMIAwAAAA==.',['信仰']='信仰圣光妭:BAAAKgAECgQIBAAAAA==.信仰圣光巴:BAAAKgAFFAYIAwAAAA==.',['俺寻']='俺寻思之力:BAAAKgAECggIDgAAAA==.',['傲决']='傲决:BAABKgAFFH8LAAMNAAMIGRrmKADiAAANAAMIGRrmKADiAAAOAAEIShaLJgBEAAAAAA==.',['僾芄']='僾芄钚芄:BAAAKgAECggICwAAAA==.',['公爵']='公爵罗刹:BAAAKgADCggICAAAAA==.',['冥邪']='冥邪公爵:BAAAKgAECgIIAgAAAA==.',['刀刀']='刀刀烈火:BAAAKgAECgcIBwAAAA==.',['划水']='划水冠军:BAAAKgAFFAYIBAAAAA==.',['删除']='删除回忆:BAAAKgADCgQIBAAAAA==.',['别碰']='别碰我丸子头:BAAAKgADCgUIBQAAAA==.',['剑廿']='剑廿三:BAABKgAFFH8JAAIPAAQI6wwAFQAVAQAPAAQI6wwAFQAVAQAAAA==.',['北船']='北船:BAAAKgAECggIEwAAAA==.',['午夜']='午夜的狂欢:BAABKgAFFH8fAAQLAAUIVhpQEAAwAQALAAUIVhpQEAAwAQAMAAIIcheKKQBHAAAKAAEIAACgKQAAAAAAAA==.',['卌除']='卌除囘忆:BAAAKgAECgUIBQAAAA==.卌除囘憶:BAAAKgAECgQIBAAAAA==.卌除回忆:BAAAKgADCggIEgAAAA==.',['华山']='华山刀客:BAAAKgADCggICAAAAA==.',['卡梅']='卡梅伦:BAAAKgAFFAgIBAAAAA==.',['口味']='口味:BAAAKgAECgMIBAAAAA==.口味丶:BAAAKgAFFAMIAwAAAA==.',['古一']='古一:BAAAKgAECgUIBQAAAA==.',['吸田']='吸田螺一流:BAAAKgAECgYIBwAAAA==.',['哀木']='哀木涕小宁:BAAAKgAECgEIAQAAAA==.',['哈咯']='哈咯:BAAAKgAFFAMIAwAAAA==.',['哞哞']='哞哞向前冲:BAAAKgADCgEIAQAAAA==.',['哥是']='哥是老中医:BAACKgAFFH8OAAIBAAQI6goUJQCrAAABAAQI6goUJQCrAAAqAAQKfyQAAgEACAi6GW8XAAACAAEACAi6GW8XAAACAAAA.',['哦大']='哦大梨啊:BAAAKgAFFAgIBAAAAA==.',['唉幺']='唉幺丶歪:BAAAKgADCgIIAgAAAA==.',['唯一']='唯一的选择:BAAAKgAFFAIIAgAAAA==.',['喵里']='喵里奥:BAAAKgAECgEIAQAAAA==.',['嗳加']='嗳加吥加:BAAAKgAECgYICgAAAA==.',['嗳唻']='嗳唻吥涞:BAABKgAECn8XAAIQAAgIih0PFQBZAgAQAAgIih0PFQBZAgAAAA==.',['嗳骑']='嗳骑吥骑:BAAAKgAECgQIBQAAAA==.',['回忆']='回忆长存:BAAAKgAECgcICQAAAA==.',['土元']='土元素:BAABKgAFFH8GAAIHAAYIPRnPCwCKAQAHAAYIPRnPCwCKAQAAAA==.',['圣都']='圣都仿若鬼服:BAAAKgADCgcIBwAAAA==.',['坐牢']='坐牢角斗士:BAAAKgADCggICAAAAA==.',['士大']='士大夫阿斯顿:BAAAKgAECgIIAgAAAA==.',['复仇']='复仇者柠檬:BAAAKgADCggICAAAAA==.',['夙素']='夙素:BAAAKgAECgQIBAAAAA==.',['夜听']='夜听风吹雨:BAAAKgAECgcIDwAAAA==.',['大佬']='大佬带带我呀:BAAAKgAECgcIDgAAAA==.',['大街']='大街上遛狗:BAAAKgADCggICAAAAA==.',['大西']='大西瓜呀:BAAAKgAECgUIBQAAAA==.',['天丨']='天丨涯:BAAAKgAECgYIBgAAAA==.',['太医']='太医王天合:BAABKgAFFH8FAAICAAUIrwWpDwDbAAACAAUIrwWpDwDbAAAAAA==.',['奔跑']='奔跑的扑老师:BAAAKgAECgIIAwAAAA==.',['奥飞']='奥飞飞:BAABKgAFFH8cAAIIAAUImRWoLQAxAQAIAAUImRWoLQAxAQAAAA==.',['婼夙']='婼夙:BAAAKgAECgUICgAAAA==.',['季末']='季末残阳:BAAAKgAECgQICAAAAA==.',['寒江']='寒江雪:BAAAKgAECgYIBgAAAA==.',['寒鋒']='寒鋒冷锷:BAAAKgADCggICAAAAA==.',['小兰']='小兰:BAABKgAECn+6AAINAAgIZiYlBgDxAgANAAgIZiYlBgDxAgAAAA==.',['小子']='小子贼帥:BAAAKgAFFAgIAQAAAA==.',['小小']='小小世界:BAAAKgADCggICgAAAA==.',['小帅']='小帅:BAAAKgAFFAYIBAABKgAFFAgIBAARAAAAAA==.',['小德']='小德:BAAAKgAECgQIBwAAAA==.',['小星']='小星尘:BAAAKgAECgMIAwAAAA==.',['小李']='小李牛羊肉:BAAAKgADCgcICAAAAA==.',['小梅']='小梅头:BAAAKgAFFAQIBAAAAA==.',['尔蛋']='尔蛋爸爸:BAAAKgADCggICAAAAA==.',['尛蛮']='尛蛮腰丶:BAAAKgAECgYIBgAAAA==.',['尤利']='尤利安怒风:BAAAKgADCggICQAAAA==.',['就一']='就一恶魔:BAABKgAFFH8IAAILAAgIdBDgCQDtAQALAAgIdBDgCQDtAQAAAA==.',['山河']='山河皆有美景:BAABKgAECn8VAAMHAAgIcxMQOACmAQAHAAgIcxMQOACmAQADAAUIGAbPXgB/AAAAAA==.',['幽冰']='幽冰映雪:BAABKgAFFH8KAAIIAAYIKgovKQBDAQAIAAYIKgovKQBDAQAAAA==.',['幽火']='幽火之小德德:BAAAKgADCgYIBgAAAA==.',['张罗']='张罗人:BAAAKgAECgYICAAAAA==.张罗魔:BAAAKgAECgYIBgAAAA==.',['很难']='很难拉得住:BAABKgAECn8ZAAIJAAgIYRslDwAZAgAJAAgIYRslDwAZAgAAAA==.',['御坂']='御坂美琴:BAABKgAFFH8IAAMSAAQIjg5xGQCvAAASAAQIjg5xGQCvAAATAAEIwAMMCgA0AAAAAA==.',['德莱']='德莱霸气的血:BAAAKgADCgYIBgAAAA==.',['忧郁']='忧郁冷疯清:BAAAKgAECgUIBQAAAA==.',['恋恋']='恋恋小奇:BAAAKgADCgQIBAAAAA==.',['恶魔']='恶魔丶吻:BAABKgAECn8VAAIUAAgINQw5KwAzAQAUAAgINQw5KwAzAQAAAA==.',['悟圣']='悟圣:BAAAKgAECgEIAQAAAA==.',['愛屋']='愛屋及乌灬漢:BAAAKgAECgQIBAAAAA==.',['愛的']='愛的魔力:BAAAKgADCggICAAAAA==.',['愤怒']='愤怒的奶牛:BAAAKgAECggICQAAAA==.',['我不']='我不是花生:BAAAKgAECgUIBQABKgAFFAgIAwARAAAAAA==.',['我之']='我之小兽:BAAAKgAECggIEQAAAA==.',['我叫']='我叫喜洋洋:BAAAKgADCgUIBQAAAA==.',['我无']='我无与陌:BAAAKgAECgUIBQAAAA==.',['我是']='我是个秘密:BAABKgAFFH8GAAMKAAYIBA8jDADKAAAKAAQIeQojDADKAAALAAII1RW1NACdAAAAAA==.',['我最']='我最桃燕灬你:BAAAKgAECggIDwAAAA==.',['我本']='我本爱你:BAAAKgAECgIIAQAAAA==.',['我牧']='我牧独自美丽:BAABKgAECn8UAAMGAAgIihK5NABLAQAGAAYIzBe5NABLAQAVAAgI7wQIWQC3AAAAAA==.',['战骑']='战骑:BAAAKgAFFAQIAQAAAA==.',['戴安']='戴安娜:BAABKgAFFH8LAAMWAAYI3x7vCgCJAQAWAAYI3x7vCgCJAQASAAEIaQO7JQAmAAAAAA==.',['手可']='手可摘星辰:BAACKgAFFH8SAAMJAAYIQxe5CwA8AQAJAAYImxO5CwA8AQAIAAMIAx9gGgATAQAqAAQKfxcAAwgACAgLG88ZAPUBAAgABQhuIs8ZAPUBAAkABwg0B5g4AKkAAAAA.',['打队']='打队友别打我:BAAAKgADCgMIAwAAAA==.',['护甲']='护甲很高:BAAAKgADCgIIAgAAAA==.',['撒拉']='撒拉嘿:BAAAKgADCggICAAAAA==.',['斧头']='斧头帮小敏:BAAAKgADCgEIAQAAAA==.',['断点']='断点的青春:BAAAKgAECgYIBgAAAA==.',['断罪']='断罪:BAAAKgAECgYICAAAAA==.',['无为']='无为炙日:BAAAKgADCgMIAwAAAA==.',['无畏']='无畏牛牛:BAAAKgADCggICAAAAA==.',['无际']='无际飘飘:BAAAKgADCgYIBgAAAA==.',['日报']='日报头版明星:BAAAKgAECgYIBgAAAA==.',['星辰']='星辰丶陨落:BAAAKgAECgYIDgAAAA==.',['昨夜']='昨夜雨疏风骤:BAAAKgAECggIDgAAAA==.',['是回']='是回忆啊:BAAAKgADCgYIBgAAAA==.',['智取']='智取小姨妹:BAAAKgADCgMIAwAAAA==.',['暗靈']='暗靈:BAABKgAECn+cAAQKAAgI/CHgAQBRAgAKAAgI/CHgAQBRAgAMAAYIPRcGOAADAQALAAYIQgr4agDKAAAAAA==.',['暴走']='暴走的尐丑:BAAAKgAFFAgIAgAAAA==.',['暴风']='暴风大聪明:BAAAKgADCgYIBgAAAA==.',['曲美']='曲美他嗪:BAAAKgADCgYIBQAAAA==.',['来生']='来生丶瞳:BAAAKgAFFAQIBAAAAA==.',['果涩']='果涩棠棠:BAAAKgAFFAIIAgAAAA==.',['柳林']='柳林风声:BAAAKgAECgQIBAAAAA==.',['核打']='核打击:BAABKgAFFH8IAAIXAAgIVBT2BgANAgAXAAgIVBT2BgANAgAAAA==.',['桃汁']='桃汁夭夭:BAAAKgADCggICAAAAA==.',['樱桃']='樱桃子:BAAAKgAFFAEIAQAAAA==.',['橙芥']='橙芥起司:BAAAKgAFFAQIAwABKgAFFAgICgAIACQhAA==.',['欧欧']='欧欧:BAAAKgAFFAQIBAAAAA==.',['正义']='正义断幺九:BAAAKgADCgMIAwAAAA==.',['残影']='残影幽灵:BAABKgAFFH8MAAMSAAMISBQSFgC+AAASAAMISBQSFgC+AAATAAIIHAwXOwB1AAAAAA==.',['水木']='水木丶圣骑:BAAAKgAECgMIAwAAAA==.水木丶宝晶:BAAAKgADCggICwAAAA==.水木丶斯卡:BAAAKgAECgQIBAAAAA==.',['池石']='池石镇:BAAAKgADCgIIBAAAAA==.',['浪花']='浪花里面浪:BAAAKgAECgUIBwAAAA==.',['浪里']='浪里跟儿浪:BAAAKgADCggIDgAAAA==.',['深森']='深森圣良:BAAAKgADCgEIAQAAAA==.',['清风']='清风舞:BAAAKgAECgYIBgAAAA==.',['港岛']='港岛妹妹:BAAAKgAECggICAAAAA==.',['滑溜']='滑溜溜:BAAAKgADCggICAAAAA==.',['火舞']='火舞化飞蝶:BAAAKgADCggICAAAAA==.',['灿灿']='灿灿魔王:BAABKgAFFH8NAAMYAAMIZx9kCwD3AAAYAAMIZx9kCwD3AAAQAAEI0gUYTQA0AAAAAA==.',['無法']='無法無天灬沭:BAAAKgAECggIDQAAAA==.',['熊猫']='熊猫宁宁:BAAAKgAECgEIAQAAAA==.',['燃烧']='燃烧的圣光:BAAAKgAECggICwAAAA==.',['爱灵']='爱灵儿:BAAAKgAECgIIAgAAAA==.',['牛德']='牛德狠:BAAAKgAECgMIAwAAAA==.',['狂暴']='狂暴输出:BAAAKgAFFAMIAwAAAA==.',['狐小']='狐小仙:BAAAKgADCggICAAAAA==.',['狐狸']='狐狸碰瞎猫:BAABKgAECn8gAAMCAAgI0hgyFwARAgACAAgI0hgyFwARAgAHAAgI8QthXQASAQAAAA==.',['王者']='王者一梦:BAAAKgAFFAQIAwAAAA==.王者司机阿发:BAAAKgAECgUIBQAAAA==.',['甜糖']='甜糖豆:BAAAKgADCggICAAAAA==.',['疯狂']='疯狂八爪鱼:BAAAKgAECgUIDwAAAA==.',['痛苦']='痛苦毁灭:BAAAKgAECgQIBQAAAA==.',['白水']='白水:BAACKgAFFH8LAAIQAAMItxH0MwCxAAAQAAMItxH0MwCxAAAqAAQKfxgAAhAACAgXG0EjADICABAACAgXG0EjADICAAAA.',['百变']='百变鸟德:BAAAKgAECgEIAQAAAA==.',['皮蛋']='皮蛋丶:BAACKgAFFH8SAAIDAAQIWx42DQABAQADAAQIWx42DQABAQAqAAQKfy8AAgMACAiMIgQMAJECAAMACAiMIgQMAJECAAAA.',['盲眼']='盲眼:BAAAKgAECgEIAQAAAA==.',['真别']='真别压力我:BAAAKgADCggICAAAAA==.',['真田']='真田左卫门佐:BAAAKgADCggICQAAAA==.',['社会']='社会你哞哞姐:BAAAKgADCgcIBwAAAA==.社会你菟菟姐:BAAAKgADCggICAAAAA==.',['祈福']='祈福圣尊:BAAAKgAECgYIEwAAAA==.',['秘密']='秘密的小猎:BAABKgAFFH8MAAMNAAYIihUlGgAuAQANAAYIAA4lGgAuAQAOAAYIEhCDFwArAQAAAA==.',['秩序']='秩序始源:BAACKgAFFH8KAAMZAAQIFh5/EQDXAAAZAAQIFh5/EQDXAAAEAAIINAVKCABbAAAqAAQKfxgAAwQACAigFVAQADoBAAQACAiSDVAQADoBABkAAwjBHGo7AOkAAAEqAAUUCAgwABoA2iQA.',['素夙']='素夙:BAABKgAECn8qAAIKAAgI+x6fAwBZAgAKAAgI+x6fAwBZAgAAAA==.',['紫色']='紫色职业第一:BAAAKgADCgcIBwAAAA==.',['紫黑']='紫黑天空:BAAAKgAFFAgIBAAAAA==.',['红莲']='红莲盾盾:BAABKgAFFH8GAAMVAAQIAxJkDwDdAAAVAAQIAxJkDwDdAAAGAAIIiAePIgBFAAAAAA==.',['纯蓝']='纯蓝色:BAABKgAFFH8KAAINAAYIjBanDABvAQANAAYIjBanDABvAQAAAA==.',['给我']='给我啃它:BAAAKgAECggICAAAAA==.',['绝世']='绝世骄傲:BAACKgAFFH8NAAIIAAQI3BT+TADVAAAIAAQI3BT+TADVAAAqAAQKfxQAAggACAizGyVEAPUBAAgACAizGyVEAPUBAAAA.',['缘一']='缘一无恋:BAAAKgAECgQIBAAAAA==.',['群星']='群星:BAAAKgAECgUICgAAAA==.',['艾斯']='艾斯德斯:BAAAKgADCgEIAQAAAA==.',['艾萨']='艾萨不撒:BAAAKgAECgUICAAAAA==.',['艾路']='艾路迪瑞亚:BAAAKgAFFAgIBAAAAA==.',['艾迪']='艾迪尔萨斯:BAABKgAFFH8LAAIbAAQI7Rd/HwCoAAAbAAQI7Rd/HwCoAAAAAA==.',['莹莹']='莹莹:BAAAKgAFFAMIAwAAAA==.',['菲尔']='菲尔丨科尔森:BAAAKgAFFAIIAgAAAA==.',['萨克']='萨克:BAAAKgADCggIEAAAAA==.',['萨贝']='萨贝宁:BAABKgAFFH8JAAIHAAYIKBCGEwA6AQAHAAYIKBCGEwA6AQAAAA==.',['萬伏']='萬伏高压灬電:BAAAKgAECgYICQAAAA==.',['落寞']='落寞式亚卖呆:BAAAKgADCgQIBAAAAA==.',['落日']='落日故人情:BAAAKgADCgEIAQAAAA==.',['落比']='落比达法则:BAAAKgAECgYICQAAAA==.',['葱卷']='葱卷大餅:BAAAKgAECggICAAAAA==.',['虔诚']='虔诚的老六:BAAAKgAECggICAAAAA==.',['虱子']='虱子王:BAAAKgADCgMIAwAAAA==.',['血伯']='血伯爵:BAABKgAECn8ZAAMcAAYI3AynIADbAAAcAAYI3AynIADbAAAbAAQIkgfYSABSAAAAAA==.',['血魔']='血魔:BAAAKgAECggICAAAAA==.',['街舞']='街舞猎手:BAAAKgAECgEIAQAAAA==.',['让我']='让我看一下:BAAAKgADCggICAAAAA==.',['试试']='试试就逝世:BAAAKgADCggIBAAAAA==.',['诸葛']='诸葛亮晶晶:BAAAKgAECgIIAgAAAA==.',['贝尔']='贝尔西瓜:BAAAKgAECgIIAgAAAA==.',['贫僧']='贫僧不戒:BAAAKgAECgYICAAAAA==.',['赛芙']='赛芙蓉:BAABKgAFFH8GAAIaAAII0AZQFABYAAAaAAII0AZQFABYAAAAAA==.',['赤狐']='赤狐青槐:BAAAKgAECggICAAAAA==.',['赤赤']='赤赤小黄人:BAAAKgAECgUIBQAAAA==.',['超赛']='超赛亚村村长:BAAAKgADCggICAAAAA==.',['还有']='还有谁:BAAAKgAECgMIAwAAAA==.',['逆天']='逆天公爵:BAAAKgADCggICAAAAA==.逆天紫无极:BAAAKgADCgMIAwAAAA==.',['途径']='途径你的盛放:BAAAKgADCgQIBgAAAA==.',['那些']='那些往事:BAAAKgAFFAIIAgAAAA==.',['那段']='那段记忆:BAAAKgADCggIEAAAAA==.',['那骑']='那骑士:BAABKgAFFH8IAAMDAAYIxReVBgB+AQADAAYIxReVBgB+AQAHAAIIGwKXLQBgAAAAAA==.',['醒悟']='醒悟的滋味:BAAAKgADCggICQAAAA==.',['铁水']='铁水:BAAAKgAECgIIAgAAAA==.',['閗戰']='閗戰聖佛:BAABKgAFFH8FAAIIAAMIsA1nXAC4AAAIAAMIsA1nXAC4AAAAAA==.',['阿兰']='阿兰:BAAAKgAFFAIIAgAAAA==.',['阿栗']='阿栗:BAAAKgAECgEIAQAAAA==.',['阿狄']='阿狄琉斯:BAAAKgAECgYICgAAAA==.',['阿腾']='阿腾:BAAAKgAFFAQIBAAAAA==.',['阿鲁']='阿鲁阿卓:BAAAKgADCgYIAQAAAA==.',['阿默']='阿默丶:BAAAKgAECggICAAAAA==.',['陰陽']='陰陽師:BAAAKgADCgYIBgAAAA==.',['随便']='随便的随:BAAAKgAECggIDAAAAA==.',['随缘']='随缘喜乐:BAAAKgADCgQIBAAAAA==.',['难得']='难得糊涂:BAABKgAECn8VAAQdAAgI0xRzJgBxAQAdAAgI0xRzJgBxAQAeAAMIUxJZKQCgAAAfAAEIuQnA2AAtAAAAAA==.',['零伍']='零伍叁壹:BAAAKgAECgIIAgAAAA==.',['零点']='零点零零幺:BAAAKgAECgUIBQAAAA==.',['靈魂']='靈魂摆渡人:BAAAKgAFFAQIBAAAAA==.',['風暴']='風暴壁垒:BAAAKgADCgEIAQAAAA==.',['风中']='风中小百合:BAAAKgAECggIBgAAAA==.',['风之']='风之旅人:BAAAKgAECgEIAQAAAA==.',['鸦鸦']='鸦鸦爱你哟:BAAAKgADCgUIBQAAAA==.',['黑潮']='黑潮:BAAAKgADCggICAAAAA==.',['默风']='默风冥:BAABKgAFFH8GAAIgAAYI8wvbBABpAQAgAAYI8wvbBABpAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end