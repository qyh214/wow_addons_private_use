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
 local lookup = {'Mage-Arcane','Warrior-Fury','Warrior-Protection','Mage-Frost','Paladin-Protection','Druid-Guardian','Paladin-Retribution','DeathKnight-Frost','DeathKnight-Unholy','Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Vengeance','Evoker-Devastation','Evoker-Augmentation','Evoker-Preservation','Druid-Restoration','Druid-Balance','Warlock-Destruction','Priest-Shadow','Priest-Holy','Shaman-Restoration','Shaman-Elemental','DemonHunter-Havoc','Monk-Brewmaster','Warlock-Demonology','Paladin-Holy','Mage-Fire','Warlock-Affliction',}; local provider = {region='CN',realm='阿斯塔洛',name='CN',type='weekly',zone=44,date='2025-12-09',data={Ak='Akarin:BAAALAADCgMIAwAAAA==.',Eo='Eo:BAAALAAECgIIAgAAAA==.Eooe:BAABLAAFFH8HAAIBAAQIHhT/HgA5AQABAAQIHhT/HgA5AQAAAA==.',Ko='Ko:BAAALAAECgYIBgAAAA==.',No='Noisy:BAAALAADCgYIBgAAAA==.',Nu='Nuit:BAAALAAFFAIIAwAAAA==.',Pa='Panpan:BAAALAADCgMIAwAAAA==.',Ri='Rion:BAAALAAECggICQAAAA==.',Su='Susuais:BAAALAADCggICAAAAA==.',Wa='Wadragonly:BAAALAAECgYICwAAAA==.',Zz='Zzsaki:BAAALAADCgYIBgAAAA==.',['一枪']='一枪进洞:BAAALAAECgEIAQAAAA==.',['一楚']='一楚楚一:BAAALAAECgYICwAAAA==.',['一箭']='一箭终情:BAAALAADCgUIAwAAAA==.',['丁寜']='丁寜:BAAALAAECgcIDQAAAA==.',['万叔']='万叔叔:BAABLAAFFH8IAAMCAAII9ARfXQA6AAACAAII9ARfXQA6AAADAAIIPQEIPAAcAAAAAA==.',['万小']='万小妤:BAABLAAFFH8GAAIEAAYIUhdnBACRAQAEAAYIUhdnBACRAQAAAA==.万小羽:BAAALAAECgYIDwAAAA==.万小雨:BAABLAAFFH8GAAIFAAIIZgifIAArAAAFAAIIZgifIAArAAAAAA==.',['万晓']='万晓雨:BAAALAAFFAIIAgAAAA==.',['万黍']='万黍叔:BAABLAAFFH8HAAIGAAIIlQieEAAkAAAGAAIIlQieEAAkAAAAAA==.',['不爱']='不爱吃披萨:BAAALAAECgEIAQAAAA==.',['丝绒']='丝绒拿铁:BAAALAAECgYIBwAAAA==.',['丶嘢']='丶嘢謜訫之助:BAAALAAECgEIAQAAAA==.',['丷嘢']='丷嘢嘚噺之助:BAAALAAECgEIAQAAAA==.丷嘢謜訫之助:BAAALAAECgYIBgAAAA==.',['丿皮']='丿皮皮丶:BAAALAAECgYIBgAAAA==.',['乖乖']='乖乖小龙女:BAAALAAFFAIIBAAAAA==.',['五月']='五月丨:BAAALAAECgUIBgAAAA==.',['亚瑟']='亚瑟之盾:BAAALAADCggICwAAAA==.',['亡域']='亡域战歌:BAAALAADCgEIAQAAAA==.',['仲夏']='仲夏夜里的梦:BAAALAAFFAIIBAAAAA==.',['伊夫']='伊夫利特之祭:BAAALAAFFAIIBAAAAA==.',['你有']='你有牙线吗:BAAALAAECggICAAAAA==.',['佰思']='佰思不得其姐:BAAALAAECgQIBAAAAA==.',['倒反']='倒反天罡:BAACLAAFFH8tAAIDAAYIrQsAFQAaAQADAAYIrQsAFQAaAQAsAAQKf0MAAwMACAjhFJgXAIoBAAMACAjhFJgXAIoBAAIAAgjsDQCKAHoAAAAA.',['做一']='做一个梦:BAAALAADCgQIBAAAAA==.',['全能']='全能选手:BAACLAAFFH8pAAIHAAYIOiObDADjAQAHAAYIOiObDADjAQAsAAQKfysAAwcACAifJJQWAFwCAAcACAifJJQWAFwCAAUABQj2FFRFACABAAAA.',['其实']='其实不想死:BAAALAADCgEIAQAAAA==.其实伤心无碍:BAAALAADCgEIAQAAAA==.',['冯晓']='冯晓明:BAAALAAFFAIIAgAAAA==.',['减减']='减减丶:BAAALAAFFAIIBAAAAA==.',['凯恩']='凯恩血踢:BAABLAAECn8hAAMIAAYIuxxMkQDdAQAIAAYIkRtMkQDdAQAJAAYIiRIZMABHAQAAAA==.',['剑锋']='剑锋所指:BAAALAAECgIIAgAAAA==.',['加尔']='加尔撸死:BAAALAAECgUIBQAAAA==.',['勇敢']='勇敢者的心:BAAALAADCgYIBgAAAA==.',['千羽']='千羽:BAABLAAFFH8LAAMKAAIIsB1pFwCwAAAKAAIIsB1pFwCwAAALAAIIdwhLpQA9AAAAAA==.',['千迢']='千迢迢卡到爆:BAAALAADCgIIAgAAAA==.',['半卷']='半卷烟雨入画:BAABLAAFFH8GAAIMAAIIcxIDDwB8AAAMAAIIcxIDDwB8AAAAAA==.',['卓耿']='卓耿:BAACLAAFFH8WAAQNAAYIWxMCCACoAQANAAUIxRUCCACoAQAOAAMILQbxCgC2AAAPAAEIqAL5HAA2AAAsAAQKfy4AAw0ACAgMHRcRAKwCAA0ACAgMHRcRAKwCAA8AAgjKFjA6AIQAAAAA.',['叁十']='叁十七:BAABLAAFFH8GAAILAAYIZAQRYgC/AAALAAYIZAQRYgC/AAAAAA==.',['发如']='发如雪丷:BAAALAAFFAIIAgAAAA==.',['叫我']='叫我苟苟:BAABLAAFFH8GAAMQAAIIbwWOUwBPAAAQAAIIbwWOUwBPAAARAAIIegYRPQAvAAAAAA==.',['名为']='名为记忆的雪:BAAALAAECggICAAAAA==.',['君之']='君之所向:BAABLAAFFH8GAAISAAIIfhTPOQCfAAASAAIIfhTPOQCfAAAAAA==.',['告别']='告别微安:BAAALAADCgEIAQAAAA==.',['咕噜']='咕噜咕噜咪:BAAALAADCgEIAQAAAA==.',['哇大']='哇大灰机:BAAALAAECgIIAgAAAA==.',['哈基']='哈基牛:BAAALAAFFAIIAgAAAA==.',['哐哐']='哐哐两斧:BAAALAAECgYIBwAAAA==.',['啊叔']='啊叔:BAAALAAECgQIBAAAAA==.',['噗噗']='噗噗突突柔柔:BAAALAADCgYIBgAAAA==.',['四百']='四百个萨满:BAAALAAFFAEIAQAAAA==.',['囡囡']='囡囡丶:BAACLAAFFH8wAAMTAAYIZR+KEABiAQATAAUIQR6KEABiAQAUAAUITiQJEABAAQAsAAQKfyMAAxMACAhgHokYAKgCABMACAhgHokYAKgCABQAAwhfJTZBAN8AAAAA.',['土鸡']='土鸡瓦狗:BAAALAAECgQIBAAAAA==.',['圣光']='圣光裁决:BAAALAAFFAEIAQAAAA==.',['埃吉']='埃吉尔:BAAALAAECgIIAgAAAA==.',['堕落']='堕落得尘土:BAAALAADCgEIAQAAAA==.',['壮牛']='壮牛水牛奶:BAAALAAECgYIAgAAAA==.',['大壮']='大壮:BAABLAAFFH8IAAIQAAIIpQqRPABjAAAQAAIIpQqRPABjAAAAAA==.',['大飛']='大飛飛:BAAALAAFFAIIAgAAAA==.',['天上']='天上飞的牛:BAAALAAFFAIIAgAAAA==.',['天启']='天启牛牛:BAAALAADCgIIAgAAAA==.',['天灵']='天灵西:BAAALAAECgYICwAAAA==.',['奔驰']='奔驰五零零:BAAALAADCgIIAgAAAA==.',['奶不']='奶不满:BAAALAAECgUIBQAAAA==.',['她逼']='她逼我说咸的:BAAALAAECggIBgABLAAFFAgIDAAKALgXAA==.',['好一']='好一朵娇花:BAAALAAECggICAAAAA==.',['妹妹']='妹妹别夹我:BAACLAAFFH8nAAIIAAYIDRI9NgBoAQAIAAYIDRI9NgBoAQAsAAQKfyAAAggACAiKGYVfADcCAAgACAiKGYVfADcCAAAA.',['宝丶']='宝丶德:BAAALAAECgYICwAAAA==.宝丶萨满:BAAALAAECggIDAAAAA==.宝丶骑士:BAAALAAECgEIAQAAAA==.',['宝马']='宝马牌的奥拓:BAAALAAECgcIDwAAAA==.',['寒丿']='寒丿琛:BAABLAAFFH8WAAMVAAgIChhtCABBAgAVAAgIChhtCABBAgAWAAQIaAbBMQClAAAAAA==.',['小包']='小包包了包:BAAALAAFFAQIBAAAAA==.',['小狗']='小狗大王:BAABLAAFFH8HAAMFAAQIfRb5DwCDAAAHAAMI+g/7QgCPAAAFAAMIXxb5DwCDAAAAAA==.',['小班']='小班大队长:BAAALAADCgYIBgAAAA==.',['小鸡']='小鸡蒸蘑菇:BAABLAAFFH8GAAIUAAIIgAhYOgCAAAAUAAIIgAhYOgCAAAABLAAFFAgIFgAVAKEbAA==.',['尹喆']='尹喆:BAABLAAFFH8GAAIRAAYINQDZQgANAAARAAYINQDZQgANAAAAAA==.',['希尔']='希尔瓦纳斯:BAAALAAECgYIBgAAAA==.',['弍哥']='弍哥最帅最欧:BAAALAAECgUIBwAAAA==.弍哥霸气威武:BAAALAAECgIIAgAAAA==.',['彡弟']='彡弟:BAAALAAECgYIDQAAAA==.',['往生']='往生的命运:BAAALAAECgYIEwAAAA==.',['心相']='心相印:BAAALAAECgQIBAAAAA==.',['必须']='必须得回去:BAACLAAFFH8IAAIBAAIInwRtYAB6AAABAAIInwRtYAB6AAAsAAQKfxkAAgEABwiBEgF8AJwBAAEABwiBEgF8AJwBAAAA.',['思心']='思心思卿:BAAALAAECgcIDQAAAA==.',['怪我']='怪我菜橙渣灬:BAABLAAFFH8HAAMLAAIIHA27aQCEAAALAAIIHA27aQCEAAAKAAIINARdHQAZAAAAAA==.',['恭喜']='恭喜发财丷:BAABLAAFFH8YAAIDAAYIXxqfBwCCAQADAAYIXxqfBwCCAQAAAA==.',['我只']='我只说一次:BAACLAAFFH8pAAIMAAYIQQ3LBgAUAQAMAAYIQQ3LBgAUAQAsAAQKfzwAAwwACAhcEYAQAEcBAAwACAj9EIAQAEcBABcAAggAFYaQAIIAAAAA.',['战神']='战神:BAAALAAECgMIBgAAAA==.',['无上']='无上仙:BAAALAAFFAIIAgAAAA==.',['无聊']='无聊的菊花:BAACLAAFFH8qAAIFAAYI7hQ0BwBbAQAFAAYI7hQ0BwBbAQAsAAQKfykAAwUACAhTFdkmAMsBAAUACAjlE9kmAMsBAAcAAQjFGtnYAFAAAAAA.',['晴雨']='晴雨灬:BAABLAAFFH8KAAIUAAIIJBqAKwCVAAAUAAIIJBqAKwCVAAAAAA==.',['曲院']='曲院风荷:BAAALAAFFAIIAgAAAA==.',['机智']='机智的阿狗铎:BAAALAAFFAIIBAAAAA==.',['杀千']='杀千刀:BAAALAAFFAIIAgAAAA==.',['杨云']='杨云凡:BAAALAAFFAMIAgABLAAFFAgIFAADAD0eAA==.',['根本']='根本不够毛:BAAALAAECgYIBgAAAA==.',['格林']='格林大酋长:BAAALAAFFAIIAgAAAA==.',['梦娇']='梦娇:BAAALAAECgIIAwAAAA==.',['梦开']='梦开始的地方:BAACLAAFFH8lAAMKAAYISxlCDwD6AAALAAUI7RvmSAAuAQAKAAUIXBVCDwD6AAAsAAQKfzAAAwoACAjDIAcUAMQCAAoACAguIAcUAMQCAAsABwgWIJZHAFMCAAAA.',['此屮']='此屮非彼叉:BAACLAAFFH8GAAISAAIIFQp/XgBBAAASAAIIFQp/XgBBAAAsAAQKfyIAAhIACAgHHHIUAEECABIACAgHHHIUAEECAAAA.',['死式']='死式:BAAALAAECgEIAQAAAA==.',['水丿']='水丿水:BAAALAAECgIIAgAAAA==.',['永无']='永无之理想乡:BAAALAAECgMIBAAAAA==.',['油封']='油封鸭腿:BAAALAADCgYIBgAAAA==.',['油菜']='油菜:BAAALAAECgUICwAAAA==.',['法相']='法相天地:BAAALAAECgQIBAAAAA==.',['海海']='海海丶:BAAALAAECgUIBQAAAA==.',['游侠']='游侠:BAAALAADCgYIBgAAAA==.',['漆黑']='漆黑丶夜:BAAALAADCgYIBgAAAA==.',['潘嘟']='潘嘟嘟:BAACLAAFFH8IAAIYAAMI+QrjGgBnAAAYAAMI+QrjGgBnAAAsAAQKfyIAAhgABgjAGRENAHcBABgABgjAGRENAHcBAAAA.',['火热']='火热的心:BAAALAAECgUIBgAAAA==.',['灬歡']='灬歡丨:BAAALAAECgIIAgAAAA==.',['灭世']='灭世惜惜:BAAALAAFFAEIAQAAAA==.',['熊大']='熊大雷:BAAALAAECgMIAwAAAA==.',['爱吃']='爱吃披萨:BAABLAAFFH8IAAIVAAIIxhvESACPAAAVAAIIxhvESACPAAAAAA==.',['犄角']='犄角美如画:BAAALAAECgEIAQAAAA==.',['猎光']='猎光光:BAAALAAFFAMIAwAAAA==.',['王燕']='王燕雯冲冲:BAAALAAFFAMIAwAAAA==.',['生如']='生如逆旅丶:BAAALAAECgMIAwAAAA==.',['痛苦']='痛苦丧钟:BAABLAAFFH8JAAMSAAUIGgiRQgDhAAASAAUIoQaRQgDhAAAZAAEIFg37IAAAAAAAAA==.',['白灬']='白灬眸:BAABLAAECn8dAAIHAAgIzxC2TwBxAQAHAAgIzxC2TwBxAQAAAA==.',['皮丨']='皮丨皮:BAAALAAFFAIIBAAAAA==.',['皮灬']='皮灬皮:BAABLAAFFH8GAAIVAAII8gb5YQBeAAAVAAII8gb5YQBeAAAAAA==.',['皮皮']='皮皮丶:BAAALAAFFAEIAQAAAA==.',['真的']='真的是被逼的:BAAALAAECgYIBgAAAA==.',['睡竹']='睡竹:BAAALAADCgYIBgAAAA==.',['神带']='神带董香:BAAALAAECgYICAAAAA==.',['神棍']='神棍晓得:BAAALAADCggICAAAAA==.',['空间']='空间上看到你:BAAALAAECgQIBAAAAA==.',['简单']='简单的电脑:BAAALAAECgYIEAAAAA==.',['纳个']='纳个木师:BAAALAAECgYIDAAAAA==.',['结束']='结束开怪:BAAALAAECgYICQAAAA==.',['胸毛']='胸毛姐姐:BAAALAAECgEIAQAAAA==.',['舍你']='舍你骑谁:BAAALAAECgUIBwAAAA==.',['茵蒂']='茵蒂克丝:BAABLAAFFH8GAAIaAAQI9gjWHADGAAAaAAQI9gjWHADGAAAAAA==.',['荣荣']='荣荣仔:BAAALAADCgUIBQAAAA==.',['莫高']='莫高雷的风:BAAALAADCgEIAQAAAA==.',['蓝桉']='蓝桉:BAABLAAFFH8FAAMBAAIIHQvdVgCKAAABAAIIHQvdVgCKAAAbAAEIVAHQDgArAAAAAA==.',['血色']='血色馈赠丶:BAAALAAECgMIAwAAAA==.',['要不']='要不你上吧:BAAALAAECgYIBgAAAA==.',['费斯']='费斯莉:BAABLAAFFH8QAAMaAAgITgkYCwDYAQAaAAgITgkYCwDYAQAHAAIIgQ64agBBAAAAAA==.',['赤龖']='赤龖火炎焱燚:BAABLAAFFH8JAAIBAAYIXxPsKQBrAQABAAYIXxPsKQBrAQAAAA==.',['躺的']='躺的贼快:BAAALAAECgEIAQAAAA==.',['软趴']='软趴趴的黄瓜:BAAALAADCgQIBAAAAA==.',['遗忘']='遗忘者:BAAALAAECgYICwAAAA==.',['醉是']='醉是离人泪:BAAALAAFFAIIAgAAAA==.',['铲开']='铲开心灵:BAACLAAFFH8wAAMSAAcI/Rg0DQAEAgASAAcI/Rg0DQAEAgAZAAEIXBF0KQBOAAAsAAQKfykABBIACAgMIPIfAOwBABIACAhqH/IfAOwBABkABQjUGrdFAFgBABwAAgjDEXouAH8AAAAA.',['阿戈']='阿戈瑞斯:BAABLAAFFH8FAAILAAIIIw+zYwCJAAALAAIIIw+zYwCJAAAAAA==.',['隔离']='隔离屋只奶爸:BAAALAAECgYIBgAAAA==.',['雙采']='雙采收割机:BAAALAAECgYIDgAAAA==.',['零九']='零九:BAAALAAECggICAAAAA==.',['雷电']='雷电法王:BAABLAAFFH8GAAIVAAIIYxrGMgCcAAAVAAIIYxrGMgCcAAAAAA==.',['霉霉']='霉霉:BAAALAADCgcICAAAAA==.',['霸气']='霸气小西瓜:BAAALAAECgYICQAAAA==.',['霸氣']='霸氣丨飛龍:BAABLAAFFH8MAAIHAAYIfRpKGgCLAQAHAAYIfRpKGgCLAQAAAA==.',['风雪']='风雪:BAAALAAECgUIBgAAAA==.风雪梧桐:BAAALAADCggICAAAAA==.',['飞舞']='飞舞的雪花:BAACLAAFFH8MAAIUAAIIyhn7LwCOAAAUAAIIyhn7LwCOAAAsAAQKfxkAAxMABwgLGN9NAH8BABMABggNFt9NAH8BABQABwi7E7ZXAHkBAAAA.',['骑猪']='骑猪冠军:BAAALAAECgYIBwAAAA==.',['黑灬']='黑灬眸:BAABLAAECn8ZAAMLAAgIVQ7vjAA2AQALAAgIeAvvjAA2AQAKAAcIFglXdAD/AAAAAA==.',['黑色']='黑色薄葬:BAAALAAECgQIBAAAAA==.',['龍王']='龍王爷搬家:BAABLAAFFH8KAAIEAAII8RH+FgBCAAAEAAII8RH+FgBCAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end