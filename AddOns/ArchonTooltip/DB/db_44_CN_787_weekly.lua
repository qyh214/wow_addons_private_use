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
 local lookup = {'Monk-Mistweaver','Druid-Balance','Hunter-BeastMastery','Paladin-Protection','DeathKnight-Frost','DeathKnight-Unholy','Warlock-Destruction','Warlock-Demonology','Shaman-Restoration','Shaman-Elemental','Priest-Holy','Rogue-Assassination','Paladin-Retribution','Warrior-Fury','Hunter-Marksmanship','DemonHunter-Havoc','Mage-Arcane','Rogue-Outlaw','DemonHunter-Vengeance','Warrior-Arms','Priest-Shadow','Druid-Restoration','Mage-Frost','Monk-Windwalker','Warrior-Protection','Rogue-Subtlety','Druid-Feral','Paladin-Holy','DeathKnight-Blood','Mage-Fire','Evoker-Preservation','Evoker-Augmentation','Evoker-Devastation','Monk-Brewmaster','Hunter-Survival','Druid-Guardian','Unknown-Unknown',}; local provider = {region='CN',realm='纳克萨玛斯',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ab='Absol:BAABLAAFFH8GAAIBAAIIXRD7FABxAAABAAIIXRD7FABxAAAAAA==.',An='Angèlia:BAAALAAECgYICQAAAA==.',Ar='Archmage:BAAALAAFFAIIBAAAAA==.',Ax='Axiaoai:BAABLAAECn8qAAICAAYI7gp3OwDOAAACAAYI7gp3OwDOAAAAAA==.',Bi='Biubiubiu:BAAALAADCgIIAgAAAA==.',Bl='Blackshou:BAABLAAFFH8GAAIDAAIIdhqfPACrAAADAAIIdhqfPACrAAAAAA==.',Ch='Cherry:BAAALAAFFAIIAgABLAAFFAYIKAAEALAjAA==.',Cr='Cross:BAAALAAECgUIBQAAAA==.',Dk='Dkabo:BAAALAAECgMIAwAAAA==.',Fo='Fontana:BAAALAADCgEIAQAAAA==.',Gr='Groupiesl:BAAALAADCgIIAgAAAA==.',Ha='Happinezz:BAABLAAFFH8GAAIDAAIIhBwwiwBHAAADAAIIhBwwiwBHAAAAAA==.',Ho='Hollyspirit:BAAALAAFFAIIAgAAAA==.',Is='Isidore:BAACLAAFFH8HAAIFAAMIkRESLQDlAAAFAAMIkRESLQDlAAAsAAQKfxwAAgUACAg9IFAmANgCAAUACAg9IFAmANgCAAAA.',Ja='Jay:BAAALAADCgIIAgAAAA==.',Je='Jerrys:BAAALAAECgYIBgAAAA==.',Jo='Johnnyken:BAAALAAECgQIBAAAAA==.',Lo='Loveisover:BAABLAAFFH8FAAIGAAMITA53DQB9AAAGAAMITA53DQB9AAAAAA==.',Ly='Lysergide:BAAALAAECgYICQAAAA==.',Me='Meruru:BAAALAAECgUIBQAAAA==.',Mo='Moni:BAAALAADCggICAAAAA==.',No='Nofant:BAAALAADCgQIBgAAAA==.',Or='Orionæ:BAABLAAFFH8GAAIDAAIIbRuZgQBTAAADAAIIbRuZgQBTAAAAAA==.',Pi='Pino:BAABLAAECn8UAAMHAAgIYx+qMAB6AgAHAAgIYx+qMAB6AgAIAAQI1worawDKAAAAAA==.Piscês:BAAALAAFFAIIAgAAAA==.',Ra='Rain:BAAALAAECgYIBgAAAA==.',Re='Redamancy:BAAALAAECgYIDAAAAA==.',Sm='Smile:BAAALAADCgYIBgAAAA==.',Sn='Snadow:BAAALAADCgMIBQAAAA==.',Sp='Spellbreake:BAAALAAECgcIDQAAAA==.Spiritwolf:BAAALAAECgcIAQAAAA==.',Sw='Sweetdeathlr:BAAALAAECgQIBAAAAA==.',Ta='Tagi:BAAALAAECggIDAABLAAFFAgIDQAJAGwSAA==.',Tn='Tneisnart:BAABLAAFFH8hAAIKAAYIWB73DwDAAQAKAAYIWB73DwDAAQABLAAFFAcILQALAK4gAA==.',Tr='Truthsm:BAAALAAECgMIAwAAAA==.',Vi='Vivto:BAAALAAECgYICQAAAA==.',['一不']='一不:BAAALAADCggICQAAAA==.',['一二']='一二的布布:BAAALAADCggICgAAAA==.',['七斤']='七斤:BAAALAAECgYIDgAAAA==.',['万奴']='万奴之王:BAAALAAFFAIIAgAAAA==.',['上官']='上官鲁钧:BAABLAAECn8WAAIMAAgI5ggzFwAGAQAMAAgI5ggzFwAGAQAAAA==.',['不想']='不想睡觉呀:BAAALAADCgQIBAAAAA==.',['不朽']='不朽之守護:BAAALAAECgYIDwAAAA==.',['专业']='专业卖萌:BAAALAADCgEIAQAAAA==.',['丨小']='丨小肚脐丨:BAAALAAECggICAAAAA==.',['丨粒']='丨粒蛋卤疯:BAAALAAECgYIDAAAAA==.',['个性']='个性埘玳:BAAALAAECgEIAQAAAA==.',['丶冲']='丶冲钅丶:BAAALAAECgYIDAAAAA==.',['丶夜']='丶夜尽天明:BAAALAAECgIIAgAAAA==.',['丶小']='丶小狐狸丶:BAABLAAFFH8LAAMKAAUIkgm0KAD+AAAKAAUIkgm0KAD+AAAJAAIIpAc1aQBRAAAAAA==.',['丶弹']='丶弹簧:BAAALAAECgMIAwAAAA==.',['丶汐']='丶汐颜丶:BAABLAAFFH8KAAIHAAMIxBYPSQCXAAAHAAMIxBYPSQCXAAAAAA==.',['丿生']='丿生存丨猎手:BAAALAAECgQIBAAAAA==.',['丿酒']='丿酒仙丨傻馒:BAAALAAECgYIDAAAAA==.',['乄花']='乄花葬乄:BAAALAAECgYIBgAAAA==.',['二刀']='二刀流骚年:BAAALAAECgYIEQAAAA==.',['云烟']='云烟汐梦:BAABLAAFFH8GAAIDAAIIMw33ZwCGAAADAAIIMw33ZwCGAAAAAA==.',['亚巴']='亚巴顿:BAAALAAFFAIIAgAAAA==.',['人老']='人老实话不多:BAABLAAECn8VAAINAAgIcw9qSQCAAQANAAgIcw9qSQCAAQAAAA==.',['仁醫']='仁醫:BAABLAAFFH8PAAIGAAMIZRXCCwCeAAAGAAMIZRXCCwCeAAAAAA==.',['伊利']='伊利安慕希:BAAALAADCgcIBwAAAA==.伊利蕾娜:BAAALAAFFAIIAgAAAA==.',['伊尔']='伊尔丹:BAAALAAECgIIAgAAAA==.',['伊立']='伊立丹怒风:BAAALAAECgQIBAAAAA==.',['伊莉']='伊莉妲舞风:BAAALAAECgMIAwAAAA==.',['你好']='你好像有点方:BAAALAAFFAIIAgAAAA==.',['俾面']='俾面派对:BAAALAAECgYIBgAAAA==.',['偏要']='偏要吃兔兔丶:BAABLAAFFH8FAAINAAUIsRdaJQBJAQANAAUIsRdaJQBJAQABLAAFFAUIHwAOAJobAA==.',['傲天']='傲天丶:BAAALAADCgUIBQAAAA==.',['兄弟']='兄弟盟血羽:BAAALAAECgUIBQAAAA==.',['光猫']='光猫:BAABLAAFFH8OAAMEAAIIZB38EACTAAAEAAIIZB38EACTAAANAAIIFw08UQCRAAABLAAFFAYILQADAJIiAA==.',['光脚']='光脚丫:BAAALAAFFAIIAgAAAA==.',['兰陵']='兰陵笑笑生:BAABLAAFFH8IAAMPAAYIYx0fBwBZAQAPAAYIzBYfBwBZAQADAAIIYyBXZQChAAAAAA==.',['养只']='养只猫叫火锅:BAAALAAFFAIIBAAAAA==.',['再来']='再来一刀:BAAALAAECgYIBgAAAA==.',['冰川']='冰川葬华佗:BAAALAADCgcIBwAAAA==.',['冲锋']='冲锋的牛:BAAALAAECgUIBQAAAA==.冲锋释放:BAAALAAFFAIIBAAAAA==.',['凌晨']='凌晨三点睡:BAAALAAECgcICAAAAA==.',['凌风']='凌风刃舞:BAAALAAFFAQIBAABLAAFFAgIIgAQAGEcAA==.',['凛冽']='凛冽寒冬:BAABLAAFFH8bAAIRAAYIJxfDHgCcAQARAAYIJxfDHgCcAQABLAAFFAcILQALAK4gAA==.',['刀刀']='刀刀烈火:BAAALAAECgYIBgAAAA==.',['分解']='分解燃烧:BAAALAAECgIIAgAAAA==.',['刺骨']='刺骨寒冬:BAABLAAFFH8cAAISAAYIDhrzAADIAQASAAYIDhrzAADIAQABLAAFFAcILQALAK4gAA==.',['力丸']='力丸之妮妮:BAAALAAECgEIAQAAAA==.力丸之破灭:BAAALAAECgEIAQAAAA==.力丸之花花:BAAALAAECgEIAQAAAA==.',['办事']='办事:BAACLAAFFH8FAAITAAMIUAt3DQBiAAATAAMIUAt3DQBiAAAsAAQKfxoAAxMABgj1EBE6AAMBABAABgjdCXXdACoBABMABgi1DxE6AAMBAAAA.',['办她']='办她:BAABLAAFFH8JAAIMAAQIKAw8EgDcAAAMAAQIKAw8EgDcAAAAAA==.',['勇往']='勇往直前:BAAALAAECgUICAAAAA==.',['勇敢']='勇敢的牛仔:BAAALAAFFAgIAQAAAA==.',['北野']='北野蔚玳:BAAALAAECggICwAAAA==.',['南丁']='南丁格尔:BAAALAAECgEIAQAAAA==.',['南宫']='南宫舞:BAAALAAECggICwAAAA==.',['南山']='南山一樵夫:BAAALAADCgQIBAAAAA==.',['南湖']='南湖东:BAACLAAFFH8tAAIUAAYIUyJ+AADtAQAUAAYIUyJ+AADtAQAsAAQKfzAAAxQACAgzJYgAAPECABQACAgoJYgAAPECAA4ACAiOIrgHAMoCAAAA.',['博福']='博福斯:BAABLAAECn8YAAIDAAgIXCRODQA0AwADAAgIXCRODQA0AwABLAAFFAgIBgADAIoVAA==.',['卡布']='卡布奇诺德:BAAALAAFFAQIBAAAAA==.',['又菜']='又菜又爱玩:BAAALAADCgEIAQAAAA==.',['叛逆']='叛逆的杨教授:BAACLAAFFH8dAAIDAAYIdhxAJAChAQADAAYIdhxAJAChAQAsAAQKfx0AAgMABgh8JcIlACECAAMABgh8JcIlACECAAAA.',['叫你']='叫你戴帽子:BAAALAAECgMIAwAAAA==.',['可乐']='可乐呢:BAAALAAFFAIIAgAAAA==.',['可爱']='可爱小小牛:BAAALAAFFAIIAgAAAA==.可爱牛牛:BAABLAAFFH8NAAIOAAMIowHSYAAyAAAOAAMIowHSYAAyAAAAAA==.',['司马']='司马秀泽:BAABLAAECn8cAAMLAAcIrA4TPgDrAAALAAcIrA4TPgDrAAAVAAIIZwkLTQAvAAAAAA==.',['吃不']='吃不完的零食:BAAALAAECgYICAAAAA==.',['吃我']='吃我一逼兜:BAAALAAFFAIIBAAAAA==.',['向死']='向死而生丶:BAAALAAFFAIIAwAAAA==.',['君心']='君心倾卿:BAAALAAECgYIDgAAAA==.',['吸血']='吸血鬼丶莱恩:BAAALAADCgEIAQAAAA==.',['呆萌']='呆萌亨特:BAABLAAECn8kAAMTAAYI6AZ8IwB+AAAQAAYIkgaA+AD3AAATAAYIQAR8IwB+AAAAAA==.',['呼啦']='呼啦:BAACLAAFFH8tAAMLAAcIriAHBgBsAgALAAcIriAHBgBsAgAVAAQIrhFHFgDHAAAsAAQKfxUAAxUACAjzIfUWALYCABUACAjzIfUWALYCAAsABAiJITKOANoAAAAA.',['咕咕']='咕咕大:BAAALAAECgYIBwAAAA==.咕咕快奶我:BAABLAAFFH8GAAIFAAIIfhHQcwCOAAAFAAIIfhHQcwCOAAAAAA==.',['哥布']='哥布林公主:BAABLAAFFH8GAAIFAAIIVhBHhABEAAAFAAIIVhBHhABEAAAAAA==.',['啊哒']='啊哒哒:BAAALAADCgYIBgAAAA==.',['喂我']='喂我花生:BAAALAAFFAIIAgAAAA==.',['喵法']='喵法:BAAALAADCggICAAAAA==.喵法的小德:BAAALAADCgEIAQAAAA==.',['四四']='四四飚:BAACLAAFFH8GAAIDAAIIcA8jZACJAAADAAIIcA8jZACJAAAsAAQKfyIAAwMACAg/GRlMAK0BAAMACAjtGBlMAK0BAA8ABgj4Fe5KAIkBAAAA.',['回春']='回春丹:BAABLAAFFH8JAAIWAAMIyyKrFgDIAAAWAAMIyyKrFgDIAAAAAA==.',['圣光']='圣光的复仇:BAAALAAECggIDwAAAA==.',['圣炎']='圣炎裁决:BAAALAADCgIIAgAAAA==.',['坤厚']='坤厚纳百川:BAAALAADCgEIAQAAAA==.',['夏丶']='夏丶目:BAAALAAECggIDgAAAA==.',['夏侯']='夏侯烈煇:BAABLAAECn8WAAIXAAgIzxGOMAC4AQAXAAgIzxGOMAC4AQAAAA==.',['夏禾']='夏禾:BAAALAAFFAIIAgAAAA==.',['夜尽']='夜尽天明丶丶:BAAALAADCgMIAwAAAA==.',['夜月']='夜月摇霁:BAAALAAECgQIBAAAAA==.',['夜枭']='夜枭丶:BAAALAAFFAQIBAAAAA==.',['夜色']='夜色暮雪:BAAALAAECgYIBgAAAA==.',['大侠']='大侠饶命丫:BAACLAAFFH8KAAIJAAUInRVeIQBSAQAJAAUInRVeIQBSAQAsAAQKfyEAAgkACAg1IEAJAMYCAAkACAg1IEAJAMYCAAAA.',['大吉']='大吉祥物:BAABLAAFFH8GAAMCAAYI7A+UGwD3AAACAAUI1AyUGwD3AAAWAAEI+xFmWQA9AAAAAA==.',['大拳']='大拳头:BAAALAAFFAIIAgAAAA==.',['大海']='大海的颜色:BAABLAAECn8UAAMKAAgIthf3NQAvAgAKAAcI0Rr3NQAvAgAJAAMIehPZ+gCnAAAAAA==.',['大火']='大火球呼你脸:BAAALAAECgYIBwAAAA==.',['天亮']='天亮收工:BAABLAAECn8eAAIFAAcIYBfYNAClAQAFAAcIYBfYNAClAQAAAA==.',['天净']='天净沙:BAAALAADCgYIBgAAAA==.',['天坛']='天坛柒月:BAABLAAFFH8PAAMQAAQIsR4EMAAXAQAQAAQIsR4EMAAXAQATAAII/guMFgApAAAAAA==.',['失去']='失去的最美:BAAALAAECgYIEgAAAA==.',['失落']='失落的灵魂:BAAALAAECggICAAAAA==.',['夺命']='夺命踢:BAABLAAFFH8MAAIBAAUItw4CDQAYAQABAAUItw4CDQAYAQAAAA==.',['奈斯']='奈斯:BAAALAAECgYIBgAAAA==.',['奈菲']='奈菲天:BAAALAAECgYICwAAAA==.',['奥术']='奥术丷:BAAALAAECgYIDgAAAA==.',['奶你']='奶你二姑姥:BAABLAAFFH8MAAIJAAYIjBURDwBPAQAJAAYIjBURDwBPAQAAAA==.',['奶咪']='奶咪老辈子:BAAALAADCgIIAgAAAA==.',['奶思']='奶思兔咪特悠:BAABLAAECn8UAAINAAYIbB+dMgDIAQANAAYIbB+dMgDIAQAAAA==.',['奶牛']='奶牛花花:BAAALAADCgIIAgAAAA==.',['奶糖']='奶糖丶:BAACLAAFFH8GAAILAAII/wwyNACJAAALAAII/wwyNACJAAAsAAQKfxoAAwsABwgsGE4cANgBAAsABwgsGE4cANgBABUAAgixDASQAGEAAAAA.',['奶酪']='奶酪吱吱:BAAALAAECgcIEwAAAA==.',['她与']='她与风皆过客:BAAALAADCgEIAQAAAA==.',['好欢']='好欢螺:BAACLAAFFH8OAAIFAAQIuhRPUADdAAAFAAQIuhRPUADdAAAsAAQKfxgAAgUACAgOJeUlANkCAAUACAgOJeUlANkCAAAA.',['妖妖']='妖妖灬妖妖:BAABLAAFFH8OAAIOAAYIOwrKKAAoAQAOAAYIOwrKKAAoAQAAAA==.',['妳丶']='妳丶我见犹怜:BAABLAAECn8UAAIDAAcIKyBAUAA+AgADAAcIKyBAUAA+AgAAAA==.',['妹子']='妹子会有的:BAAALAAECgEIAQAAAA==.妹子你站住丷:BAAALAAECgcICgAAAA==.',['姐姐']='姐姐么么哒:BAACLAAFFH8GAAIYAAQIwBDlDQDYAAAYAAQIwBDlDQDYAAAsAAQKfxoAAhgABwhDHt0LAOQBABgABwhDHt0LAOQBAAAA.',['姿态']='姿态决定成败:BAACLAAFFH8eAAIZAAYIkBqxCgCUAQAZAAYIkBqxCgCUAQAsAAQKfx0AAhkABwj3ILQXAHMCABkABwj3ILQXAHMCAAAA.',['娜尔']='娜尔妮莎:BAAALAAECgYICgAAAA==.',['嫩魔']='嫩魔:BAABLAAECn8UAAITAAcIRQ75MwAmAQATAAcIRQ75MwAmAQAAAA==.',['寂于']='寂于冲锋:BAACLAAFFH8OAAIOAAYItAtgIQBiAQAOAAYItAtgIQBiAQAsAAQKfxUAAg4ABwjPEzhmAMQBAA4ABwjPEzhmAMQBAAAA.',['寂静']='寂静旋律:BAAALAAECgYIBgABLAAFFAUIHwAOAJobAA==.',['富士']='富士壺機械:BAAALAAECgYICQAAAA==.',['富婆']='富婆抱抱我:BAABLAAFFH8PAAIDAAYICBFxPQBPAQADAAYICBFxPQBPAQAAAA==.',['封魔']='封魔战斗:BAAALAAECgUIBQAAAA==.',['尊严']='尊严之战:BAAALAADCgIIAgAAAA==.',['小斑']='小斑爱睡觉:BAAALAAFFAIIAgAAAA==.',['小棉']='小棉花餹:BAAALAADCgYIBgAAAA==.',['小路']='小路老师:BAAALAAFFAEIAQAAAA==.',['尛二']='尛二花丨同学:BAAALAAECgYIBgAAAA==.',['就你']='就你叫萨满啊:BAAALAADCgEIAQAAAA==.',['山岳']='山岳之力:BAAALAAECgYIBgAAAA==.',['岁岁']='岁岁丶:BAABLAAFFH8GAAIRAAYICiUXAgCZAgARAAYICiUXAgCZAgAAAA==.',['崎雨']='崎雨落:BAAALAAECgYIBgAAAA==.',['崧哥']='崧哥:BAACLAAFFH8HAAIOAAIIkBJgUQBDAAAOAAIIkBJgUQBDAAAsAAQKfxkAAg4ABgh3HNkuAJ8BAA4ABgh3HNkuAJ8BAAAA.',['川南']='川南以西:BAAALAAECgMIAwAAAA==.',['巫师']='巫师:BAABLAAFFH8GAAIDAAIIyg62kgBEAAADAAIIyg62kgBEAAAAAA==.',['巫瑟']='巫瑟尔:BAAALAADCggICAAAAA==.',['布尔']='布尔凯索:BAAALAAECggICAAAAA==.',['帅逼']='帅逼丶:BAABLAAFFH8HAAINAAMIZA9kHQDgAAANAAMIZA9kHQDgAAAAAA==.',['希尔']='希尔瓦娜嘶:BAAALAAECgUIBQAAAA==.',['幸运']='幸运术:BAABLAAECn8WAAMHAAYIwx1NJwC7AQAHAAYIhR1NJwC7AQAIAAMIVxksbwC6AAAAAA==.',['幽寒']='幽寒罓冷香:BAAALAAECgMIAwAAAA==.',['幽灵']='幽灵萨:BAAALAADCgcIBwAAAA==.',['张嘴']='张嘴闭嘴吐:BAAALAAECgEIAQAAAA==.',['心响']='心响:BAAALAAECgUIBQAAAA==.',['思丹']='思丹:BAAALAADCgYIBgAAAA==.',['恭贺']='恭贺新禧:BAAALAAECgcICwAAAA==.',['恶魔']='恶魔在背后:BAABLAAECn8kAAIaAAYIoheIDABCAQAaAAYIoheIDABCAQAAAA==.',['悠悠']='悠悠小凡:BAABLAAECn8VAAIIAAYIjB9JDACeAQAIAAYIjB9JDACeAQAAAA==.悠悠萌宝宝:BAABLAAECn8VAAIDAAYIyh0gYgB+AQADAAYIyh0gYgB+AQAAAA==.',['情人']='情人:BAACLAAFFH8UAAIOAAQIMx4mKgAaAQAOAAQIMx4mKgAaAQAsAAQKfx0AAg4ACAg0Hu8kALECAA4ACAg0Hu8kALECAAAA.',['愛霞']='愛霞:BAAALAAECgMICwAAAA==.',['愤怒']='愤怒的圣光:BAAALAAECggIDwAAAA==.',['慕容']='慕容智樱:BAAALAAFFAMIAwAAAA==.',['懓娜']='懓娜娜:BAACLAAFFH8HAAILAAIIVBtlJQCjAAALAAIIVBtlJQCjAAAsAAQKfxYAAwsACAj6Gx0eAIQCAAsACAj6Gx0eAIQCABUABAhBEhI2AK8AAAAA.',['我不']='我不想上班:BAAALAAFFAIIAgAAAA==.',['我去']='我去买俩橘子:BAAALAADCgEIAQAAAA==.',['我是']='我是乃骑:BAAALAAECgMIAwAAAA==.我是小刀:BAAALAAECgMIAwAAAA==.',['我要']='我要去远方:BAACLAAFFH8bAAMRAAUIChnVLwBIAQARAAUIChnVLwBIAQAXAAEIsQ5SJAAAAAAsAAQKfxUAAhEABwh/H6ESABoCABEABwh/H6ESABoCAAAA.',['我还']='我还要去远方:BAABLAAFFH8QAAIPAAUIqg+OCwDXAAAPAAUIqg+OCwDXAAAAAA==.',['战争']='战争牛牛:BAACLAAFFH8GAAIWAAII1xvQIAChAAAWAAII1xvQIAChAAAsAAQKfx8AAxYABwiSHC4lAFMCABYABwiSHC4lAFMCABsAAQjuChpLADYAAAAA.',['战狼']='战狼之狼:BAAALAAECgMIAwAAAA==.',['战盾']='战盾:BAAALAAECgYIBgAAAA==.',['戰狼']='戰狼之狼:BAAALAAECgcIBwAAAA==.',['把嘴']='把嘴给我闭上:BAAALAAFFAMIAwAAAA==.',['拉花']='拉花拉到手滑:BAAALAAFFAIIBAAAAA==.',['拉风']='拉风骑:BAAALAAECgUIBQAAAA==.',['指着']='指着太阳说日:BAAALAAECgUIBQAAAA==.',['挣扎']='挣扎的煎饼果:BAAALAADCgEIAQAAAA==.挣扎的猪脚饭:BAAALAADCgMIAwAAAA==.',['挥剑']='挥剑断天涯:BAAALAAECgYIBgAAAA==.',['接个']='接个大活:BAAALAAECgMIAwAAAA==.',['撒旦']='撒旦的魔力:BAAALAAECgcIBwAAAA==.',['擒兽']='擒兽啊擒兽:BAAALAAECgYIBwAAAA==.',['擦扁']='擦扁球:BAAALAAECgUIBQAAAA==.',['改名']='改名会变好运:BAAALAAFFAQIBAAAAA==.',['放浪']='放浪的財子:BAABLAAFFH8GAAIFAAIIuBQQgQBFAAAFAAIIuBQQgQBFAAAAAA==.',['斌歌']='斌歌:BAABLAAECn8VAAIXAAYI0CIZDAD5AQAXAAYI0CIZDAD5AQAAAA==.',['无尽']='无尽的回忆:BAACLAAFFH8bAAIWAAYI1Bn2EAC6AQAWAAYI1Bn2EAC6AQAsAAQKfzEAAxYACAh6HYUlAFECABYACAh6HYUlAFECAAIAAwiADPSfAFQAAAAA.',['无悔']='无悔的天使:BAAALAAECggIBwAAAA==.',['无敌']='无敌最俊朗:BAAALAAFFAIIAgAAAA==.',['是个']='是个狼灭:BAABLAAFFH8GAAIDAAQInAxHYwCsAAADAAQInAxHYwCsAAAAAA==.',['暗行']='暗行狱史:BAACLAAFFH8HAAMPAAMIzgyKNABCAAAPAAIIwguKNABCAAADAAII5QnVtQAzAAAsAAQKfxUAAw8ABgiaG5QPAFEBAA8ABgiaG5QPAFEBAAMAAgjJDzgPAW0AAAAA.',['最后']='最后的疯狂:BAAALAAECgYIBgAAAA==.',['月影']='月影寒:BAACLAAFFH8GAAIMAAIIcAYBHQCFAAAMAAIIcAYBHQCFAAAsAAQKfxsAAgwABggYFiEUACsBAAwABggYFiEUACsBAAAA.',['有火']='有火没烟:BAAALAADCggICAABLAAFFAgICgAFAOQiAA==.',['望川']='望川:BAAALAADCggICAAAAA==.',['未来']='未来咆哮:BAAALAADCggICAAAAA==.',['术倒']='术倒猢狲散:BAABLAAFFH8JAAMIAAMIRglyCgBzAAAHAAIIkgS4UwB3AAAIAAMIRglyCgBzAAAAAA==.',['来颗']='来颗糖:BAABLAAECn8YAAIHAAYIPwVocACuAAAHAAYIPwVocACuAAAAAA==.',['林沐']='林沐儿:BAAALAAFFAMIBAAAAA==.',['柒丶']='柒丶曜:BAAALAAECgcIAQAAAA==.',['标准']='标准结题:BAABLAAECn8kAAIQAAYIgxTVRwBDAQAQAAYIgxTVRwBDAQAAAA==.',['树鸟']='树鸟熊猫:BAAALAAECgUIBQAAAA==.',['桃气']='桃气泡泡:BAACLAAFFH8aAAIWAAYIIBB5FwB3AQAWAAYIIBB5FwB3AQAsAAQKfxcAAxYACAhaF7lCANUBABYACAhaF7lCANUBAAIABAjEBgGIAKMAAAEsAAUUBggeAAkAsRUA.',['梦乄']='梦乄踏星河:BAABLAAFFH8GAAINAAYI4AuwIgBYAQANAAYI4AuwIgBYAQAAAA==.',['棈灵']='棈灵坏汶汶:BAACLAAFFH8IAAIEAAIIsgsWGwBvAAAEAAIIsgsWGwBvAAAsAAQKfyAABAQACAijFAwyAIYBAAQACAj0EAwyAIYBAA0AAwjEFGa4AIsAABwAAwjKCaA4AH8AAAAA.',['楚乄']='楚乄:BAAALAADCgEIAQAAAA==.',['楼兰']='楼兰绮綾:BAAALAAECgQIBAAAAA==.',['樱火']='樱火:BAAALAAFFAIIAwAAAA==.',['橙天']='橙天捣蛋:BAAALAAFFAQIBAAAAA==.',['欧文']='欧文:BAAALAAFFAIIAgAAAA==.',['欧阳']='欧阳嘉歆:BAABLAAECn8XAAMdAAgIAAfVGgDxAAAdAAgIxgbVGgDxAAAGAAUI+QTRGQCYAAAAAA==.',['欭惗']='欭惗丶:BAABLAAFFH8JAAIRAAYIwgcoMwAzAQARAAYIwgcoMwAzAQAAAA==.',['歸來']='歸來的王子:BAABLAAECn8aAAIFAAcIgRhhiADrAQAFAAcIgRhhiADrAQAAAA==.',['死亡']='死亡终结者:BAAALAAFFAIIAgAAAA==.',['死神']='死神的拥抱:BAAALAAECggICAAAAA==.',['殇牛']='殇牛牛:BAAALAAECgMIBAAAAA==.',['毀天']='毀天滅地:BAAALAAECggICAAAAA==.',['毁灭']='毁灭丷:BAAALAAECgYICgAAAA==.',['毛绒']='毛绒大尾巴:BAAALAAECgIIAgAAAA==.',['气定']='气定乾坤:BAAALAAFFAIIBAAAAA==.',['氵伈']='氵伈佄灬启:BAAALAADCgcIBwAAAA==.',['永芜']='永芜:BAAALAAECgYIBgAAAA==.',['汶丶']='汶丶哥狠帅:BAAALAAECgYIBgAAAA==.',['沁天']='沁天一指:BAAALAAECgIIAgAAAA==.',['没在']='没在怕的:BAAALAADCgYIBgAAAA==.',['没梦']='没梦想的咸鱼:BAABLAAFFH8aAAMeAAYIISGxAwBjAQAeAAUIZCCxAwBjAQARAAQI1iKdIgASAQAAAA==.',['泡泡']='泡泡龙:BAABLAAFFH8jAAQfAAYIHhjgCQAYAQAfAAQI1BjgCQAYAQAgAAUI+gqGCAALAQAhAAQIVRF2EwDSAAAAAA==.',['流云']='流云:BAAALAAECgEIAQAAAA==.',['流刃']='流刃若火:BAAALAAECggICgAAAA==.',['流小']='流小雨:BAABLAAFFH8dAAIDAAUI6SKoKQCNAQADAAUI6SKoKQCNAQABLAAFFAYIKAAEALAjAA==.',['流羽']='流羽:BAACLAAFFH8PAAIWAAMI/xYHLgCzAAAWAAMI/xYHLgCzAAAsAAQKfxUAAhYABggwGI5PAKgBABYABggwGI5PAKgBAAEsAAUUBggoAAQAsCMA.',['浩海']='浩海之源:BAAALAAECgMIAwAAAA==.',['浮生']='浮生万象:BAABLAAFFH8HAAIFAAIILiN5NADMAAAFAAIILiN5NADMAAAAAA==.浮生残梦:BAAALAAFFAIIBAABLAAFFAIIBwAFAC4jAA==.',['涟漪']='涟漪之秀:BAACLAAFFH8bAAINAAUIDQ1NLQAbAQANAAUIDQ1NLQAbAQAsAAQKfyEAAg0ACAinEyE5ALIBAA0ACAinEyE5ALIBAAAA.',['涵涵']='涵涵不洗脚:BAAALAAFFAIIAgAAAA==.',['淡忘']='淡忘丶:BAABLAAFFH8GAAIFAAIIthklZQCWAAAFAAIIthklZQCWAAAAAA==.',['温水']='温水杏菜:BAABLAAFFH8jAAMWAAYI/hmfCgBZAQAWAAYI/hmfCgBZAQACAAQIaQlyIQCsAAAAAA==.',['游戏']='游戏名字:BAAALAAECgYICwAAAA==.',['满甲']='满甲雪:BAAALAADCgIIAgAAAA==.',['潇洒']='潇洒哥:BAAALAADCgQIBAAAAA==.',['潇然']='潇然丶:BAABLAAFFH8JAAMWAAIIygc+TwBVAAAWAAIIygc+TwBVAAACAAIIoA+tMABBAAAAAA==.',['火焰']='火焰队长:BAAALAADCgYIBgAAAA==.',['火腿']='火腿炒饭丶:BAAALAAECgUIBQAAAA==.',['灬佬']='灬佬龍乤灬:BAABLAAECn8cAAMHAAYI9gyaWQDzAAAHAAYI9gyaWQDzAAAIAAEIwAYhPwAAAAAAAA==.',['灬聖']='灬聖魅灬:BAABLAAECn8ZAAINAAcI5BCKVwBbAQANAAcI5BCKVwBbAQAAAA==.',['灬苍']='灬苍丨月灬:BAAALAAECgEIAQAAAA==.',['炭烤']='炭烤懒羊羊:BAAALAAFFAIIAgAAAA==.',['烈风']='烈风疾炎:BAABLAAFFH8eAAMFAAYIZhGIQgAwAQAFAAUItBSIQgAwAQAdAAEI4ACHIAARAAABLAAFFAYIKwAOAO0QAA==.',['熊先']='熊先僧:BAABLAAFFH8IAAIiAAQI8wy3DADZAAAiAAQI8wy3DADZAAAAAA==.',['熊杨']='熊杨:BAACLAAFFH8KAAMYAAIItBv+DACtAAAYAAIItBv+DACtAAABAAIIzQNYGQBUAAAsAAQKfyEAAxgABwj6GogdABkCABgABwj6GogdABkCAAEABwjGDMotADYBAAAA.',['爆奶']='爆奶萌妹:BAAALAAFFAIIAwAAAA==.',['爱德']='爱德华纽盖特:BAAALAADCgEIAQAAAA==.',['爱的']='爱的魔力:BAACLAAFFH8IAAIOAAIInhe8MgCcAAAOAAIInhe8MgCcAAAsAAQKfyYAAg4ACAgKHCwuAIECAA4ACAgKHCwuAIECAAAA.',['爱蜜']='爱蜜莉娅:BAAALAAECgYICAAAAA==.',['爱跳']='爱跳舞的熊熊:BAAALAAFFAIIAgAAAA==.',['牛宝']='牛宝宝小莉莉:BAAALAADCggIDAAAAA==.',['狐狐']='狐狐:BAABLAAFFH8IAAIJAAUIOBWGIgBKAQAJAAUIOBWGIgBKAQABLAAFFAYIIwAWAP4ZAA==.',['猎猎']='猎猎黑巧:BAABLAAFFH8cAAIDAAUIzBiWJQDmAAADAAUIzBiWJQDmAAAAAA==.',['猛扣']='猛扣瞎子好眼:BAAALAADCgMIAwAAAA==.',['猫叔']='猫叔唉:BAACLAAFFH8tAAIDAAYIkiJiGADWAQADAAYIkiJiGADWAQAsAAQKfyIAAgMABgh4JeZIAFACAAMABgh4JeZIAFACAAAA.',['猫哥']='猫哥:BAABLAAECn8aAAINAAcIbhCcWABYAQANAAcIbhCcWABYAQAAAA==.',['玃如']='玃如:BAABLAAFFH8GAAMWAAIIRAZgQwBcAAAWAAIIRAZgQwBcAAAbAAII4gksEQAyAAAAAA==.',['王子']='王子超可爱:BAAALAAECgQIBAAAAA==.',['玛卡']='玛卡瑞納:BAACLAAFFH8nAAMDAAYIhCPMEAAEAgADAAYIhCPMEAAEAgAjAAIINgnkBQCPAAAsAAQKfxcAAwMACAi4It0PAKMCAAMACAi4It0PAKMCACMAAgiBBKgiAFYAAAAA.',['玩闹']='玩闹烟斗:BAAALAADCgcICAAAAA==.',['璃月']='璃月:BAAALAADCgYIBgAAAA==.',['瓜酱']='瓜酱:BAABLAAECn8WAAIQAAYIbRydLgCeAQAQAAYIbRydLgCeAQAAAA==.',['电离']='电离:BAAALAAECgYIDQAAAA==.',['畫心']='畫心:BAAALAAECgcIBwAAAA==.',['疾風']='疾風月影:BAABLAAFFH8GAAMWAAYIACA1BQDaAQAWAAUIDiA1BQDaAQACAAEIag2GKwBSAAABLAAFFAgIPQAWAD4mAA==.',['疾风']='疾风剑濠:BAAALAAECgYIBgAAAA==.',['痴道']='痴道:BAAALAAFFAIIAwAAAA==.',['白虎']='白虎颚小莉莉:BAAALAAECgYIBgAAAA==.',['白雾']='白雾红棽:BAABLAAFFH8NAAINAAYI4wyqIgBYAQANAAYI4wyqIgBYAQABLAAFFAYIKwAOAO0QAA==.',['皧娜']='皧娜娜:BAAALAAECggIDgAAAA==.',['皮几']='皮几万:BAABLAAFFH8GAAIFAAYIpANlSgAKAQAFAAYIpANlSgAKAQAAAA==.',['皮皮']='皮皮大领主:BAAALAAECggICAAAAA==.',['盏茶']='盏茶浅抿:BAACLAAFFH8NAAMKAAUI7wKXLwC1AAAKAAUI7wKXLwC1AAAJAAQIyQLXSQCJAAAsAAQKfxwAAgkACAj2CZBaAPYAAAkACAj2CZBaAPYAAAAA.',['相对']='相对亦忘言丶:BAAALAAFFAIIBAAAAA==.',['看书']='看书看到眼花:BAABLAAFFH8IAAIFAAIIHBEGYgCXAAAFAAIIHBEGYgCXAAAAAA==.',['看我']='看我一笑奈何:BAAALAAECgMIAwAAAA==.',['神也']='神也低调:BAAALAADCggICQAAAA==.神也无奈:BAAALAADCggICwAAAA==.',['神圣']='神圣干涉:BAABLAAECn8UAAINAAYIWyXRRQBqAgANAAYIWyXRRQBqAgAAAA==.',['福尔']='福尔摩斯先生:BAAALAAECgUIBQAAAA==.',['秋风']='秋风只影:BAABLAAFFH8FAAMNAAMI+Q1pVwBLAAANAAEINxJpVwBLAAAEAAII2Qv1HQAvAAAAAA==.',['科比']='科比:BAAALAAFFAIIAgAAAA==.',['立秋']='立秋:BAAALAAECgYIDAAAAA==.',['筱远']='筱远:BAAALAAECggICAAAAA==.',['粉沫']='粉沫:BAAALAAFFAIIAgAAAA==.',['粉黛']='粉黛花颜:BAAALAAFFAQIBAAAAA==.',['糹灵']='糹灵魂行者:BAABLAAFFH8GAAIJAAIIgRFOWQBoAAAJAAIIgRFOWQBoAAAAAA==.',['索然']='索然丶无味:BAAALAAECggIBQAAAA==.',['紫丶']='紫丶汐:BAACLAAFFH8IAAMXAAIIshBSHwBGAAARAAIIEQwnYwByAAAXAAEIIxJSHwBGAAAsAAQKfyYAAxEACAgBHIc/AE0CABEACAgfGIc/AE0CABcABgi4HPMoAOIBAAAA.',['綮诳']='綮诳毹甥:BAAALAAECgYIEgAAAA==.',['红丶']='红丶:BAAALAADCgMIAwAAAA==.',['红手']='红手小蹄子:BAAALAAFFAIIBAAAAA==.红手德小伊:BAAALAAECgUIBQAAAA==.红手萨小蹄:BAABLAAFFH8GAAMJAAIIQAwoZABXAAAJAAIIQAwoZABXAAAKAAEIzwEsWAAAAAAAAA==.',['纯情']='纯情青年:BAABLAAECn8XAAMDAAgIBxFAaQBwAQADAAgIBxFAaQBwAQAPAAEIwgkdyQAnAAAAAA==.',['纳兰']='纳兰卓礼:BAAALAAFFAEIAQAAAA==.',['纳西']='纳西妲:BAAALAAFFAIIAgAAAA==.',['绫波']='绫波丽:BAAALAAECgQIBAAAAA==.',['绿和']='绿和尚:BAAALAAECgYIBgAAAA==.',['罪与']='罪与罚与赎:BAAALAAECgYIBgAAAA==.',['羞涩']='羞涩教母:BAAALAAECgIIAgAAAA==.',['義战']='義战赵云:BAAALAAECggICAAAAA==.',['羽翎']='羽翎:BAAALAAECgYIDAAAAA==.',['翠花']='翠花上电棍:BAAALAAFFAIIBAAAAA==.',['老东']='老东西杨永信:BAAALAAECgYIDAAAAA==.',['聖光']='聖光祈願:BAAALAAECggICAAAAA==.',['肉山']='肉山:BAABLAAFFH8HAAINAAMIfxqJPQCdAAANAAMIfxqJPQCdAAABLAAFFAQIDgAFALoUAA==.',['胡小']='胡小梵:BAAALAADCgEIAwAAAA==.',['胡老']='胡老弟:BAAALAAFFAMIAwAAAA==.',['舒玛']='舒玛:BAAALAAECgYIBgAAAA==.',['船新']='船新的战雕:BAAALAADCgIIAgAAAA==.',['艾力']='艾力克斯:BAAALAAECgYICAABLAAFFAYILQAUAFMiAA==.',['艾欧']='艾欧尼亚:BAAALAAECgIIAgABLAAFFAgIIAAZAFYRAA==.',['芒果']='芒果养乐多:BAACLAAFFH8ZAAILAAUIuheZGgB6AQALAAUIuheZGgB6AQAsAAQKfxoAAgsABggmGKdUAIUBAAsABggmGKdUAIUBAAEsAAUUBggeAAkAsRUA.芒果欧蕾:BAACLAAFFH8rAAMOAAYI7RDvHQB6AQAOAAYIqRDvHQB6AQAUAAEIghL/BABJAAAsAAQKfxUAAg4ABggFGcNzAKMBAA4ABggFGcNzAKMBAAAA.',['芝芝']='芝芝芒芒:BAABLAAFFH8eAAIJAAYIsRXoFwCdAQAJAAYIsRXoFwCdAQAAAA==.',['花不']='花不达:BAABLAAFFH8GAAIOAAYI8glHIQBiAQAOAAYI8glHIQBiAQAAAA==.',['花边']='花边下情未央:BAAALAAECgYIBgAAAA==.',['芽弥']='芽弥酱:BAAALAAECgUIBQAAAA==.',['茶太']='茶太:BAAALAAECgMIAwAAAA==.',['草原']='草原牛王:BAABLAAFFH8MAAIZAAIIUglBLABjAAAZAAIIUglBLABjAAAAAA==.',['莉泽']='莉泽罗忒:BAAALAAECgEIAQAAAA==.',['萌囡']='萌囡囡:BAAALAAFFAIIBAAAAA==.',['萌萌']='萌萌的法師:BAAALAAECggIEwAAAA==.',['萨鼎']='萨鼎鼎:BAAALAADCgQIBAAAAA==.',['落花']='落花成塚:BAABLAAFFH8ZAAIcAAUIyRTWEwBPAQAcAAUIyRTWEwBPAQAAAA==.',['落辞']='落辞:BAABLAAFFH8FAAIWAAIIsQrhTABYAAAWAAIIsQrhTABYAAAAAA==.',['落邪']='落邪:BAAALAAFFAIIAgAAAA==.',['葡萄']='葡萄啵啵:BAAALAAECgYIBgAAAA==.',['蓝莓']='蓝莓:BAABLAAECn8WAAMbAAcIngpmEgAOAQAbAAcIngpmEgAOAQAWAAYIHAZrXQClAAAAAA==.',['蚀魂']='蚀魂狂魔:BAACLAAFFH8YAAIHAAUIuRNcNwAxAQAHAAUIuRNcNwAxAQAsAAQKfxsAAgcACAhGHmwSAFICAAcACAhGHmwSAFICAAAA.',['蝴蝶']='蝴蝶满园春:BAAALAAECgYICgAAAA==.',['血斩']='血斩丶沸:BAAALAAFFAIIBAAAAA==.',['血煞']='血煞冰箱:BAAALAADCgEIAQAAAA==.',['裴伴']='裴伴:BAAALAAECgEIAQAAAA==.',['西农']='西农九七九:BAAALAAECgYIDAAAAA==.',['西敏']='西敏寺有子:BAAALAAECgYIBgAAAA==.',['西门']='西门義峰:BAABLAAECn8UAAIZAAgIIQO6OwCjAAAZAAgIIQO6OwCjAAAAAA==.',['诱僧']='诱僧:BAAALAAECgQIBAAAAA==.',['请叫']='请叫我灰太狼:BAACLAAFFH8SAAIEAAIIOAyKHAAyAAAEAAIIOAyKHAAyAAAsAAQKfxQAAgQABQgWGUAiAP8AAAQABQgWGUAiAP8AAAAA.',['谦玉']='谦玉:BAACLAAFFH8mAAIHAAYIeRdMJACJAQAHAAYIeRdMJACJAQAsAAQKfxcAAwcACAgWHaZFACUCAAcACAgWHaZFACUCAAgAAQhQHgiNAFEAAAEsAAUUBggoAAQAsCMA.',['赤猴']='赤猴:BAABLAAFFH8RAAMLAAUI6hWyIQC0AAALAAQI6BiyIQC0AAAVAAEIkQydJwBIAAAAAA==.',['赤鱬']='赤鱬:BAAALAAFFAEIAQAAAA==.',['赫塞']='赫塞汀:BAABLAAFFH8LAAIGAAUIjhEABgA7AQAGAAUIjhEABgA7AQAAAA==.',['路过']='路过的老百姓:BAAALAAECgEIAQAAAA==.',['辣目']='辣目桃子:BAACLAAFFH8PAAIYAAUI2gnsDAD3AAAYAAUI2gnsDAD3AAAsAAQKfzYAAxgABwhPG5EQAKEBABgABwhPG5EQAKEBACIABggkBgwdAJoAAAAA.',['辰巳']='辰巳希娜:BAAALAAECgYIDAAAAA==.',['辻弌']='辻弌丶:BAABLAAFFH8FAAMIAAQIAABYGwAEAAAIAAQIAABYGwAEAAAHAAEIAAAAAAAAAAAAAA==.',['近战']='近战五码分散:BAACLAAFFH8oAAIEAAYIsCPgAQAQAgAEAAYIsCPgAQAQAgAsAAQKfxYAAgQACAgtJjMBAH4DAAQACAgtJjMBAH4DAAAA.',['远近']='远近都迷人:BAAALAAECggICAAAAA==.',['遗忘']='遗忘的背叛者:BAABLAAECn8XAAIQAAcIDBwsVAAnAgAQAAcIDBwsVAAnAgAAAA==.',['酸菜']='酸菜水饺:BAAALAADCggICAAAAA==.',['重回']='重回世界:BAABLAAFFH8GAAIDAAIIJwS1ugAuAAADAAIIJwS1ugAuAAAAAA==.',['野猪']='野猪佩佩奇:BAAALAADCgEIAQAAAA==.',['釒熊']='釒熊猫:BAAALAAECggIDAAAAA==.',['釗鋒']='釗鋒:BAABLAAFFH8GAAIJAAIIBB8sKQCyAAAJAAIIBB8sKQCyAAAAAA==.',['鎏羽']='鎏羽:BAABLAAFFH8cAAQCAAcImh18CADcAQACAAYIsh98CADcAQAWAAMIKhoAHwCnAAAkAAMIig67BwBvAAAAAA==.',['银丶']='银丶月:BAAALAAECggIDAABLAAFFAgIBwAOAEIWAA==.',['银角']='银角大王:BAAALAADCgYIBgAAAA==.',['长歌']='长歌负轻狂:BAAALAAFFAIIBAAAAA==.',['阿基']='阿基米德:BAAALAAECggIEQAAAA==.',['阿尔']='阿尔萨呗宁:BAAALAAECgYIEgAAAA==.阿尔萨撕:BAAALAAECgEIAQAAAA==.',['阿波']='阿波怒风:BAAALAAECgYIBgAAAA==.',['阿脑']='阿脑哥:BAABLAAECn8UAAIFAAcICB8OjADlAQAFAAcICB8OjADlAQAAAA==.',['陈大']='陈大黑:BAACLAAFFH8sAAIUAAYIniNRAAAZAgAUAAYIniNRAAAZAgAsAAQKf0kAAxQACAh/Jh4AACUDABQACAh/Jh4AACUDABkAAQiLGy+PAE4AAAEsAAUUBggtABQAUyIA.',['陌离']='陌离柰白:BAAALAAECgIIAgABLAAECgYIBgAlAAAAAA==.',['随遇']='随遇而安:BAAALAAECgYIDQAAAA==.',['随风']='随风逝:BAAALAAECgYIBgAAAA==.随风飘远方:BAAALAAFFAIIBAAAAA==.',['雨中']='雨中的宁静:BAAALAADCgYIBgAAAA==.',['雪飘']='雪飘飘:BAACLAAFFH8mAAILAAYIfxauFACvAQALAAYIfxauFACvAQAsAAQKfxsAAwsACAgzIEgIAMsCAAsACAgzIEgIAMsCABUAAQjNCiFVAAAAAAAA.',['雷霆']='雷霆妞妞:BAABLAAFFH8VAAIKAAUIkhb/IgArAQAKAAUIkhb/IgArAQAAAA==.雷霆萬鈞:BAAALAAFFAIIBAAAAA==.',['青青']='青青糯山:BAAALAAFFAIIBAAAAA==.',['靓醒']='靓醒的纯天然:BAAALAAECgYIBgAAAA==.',['风剑']='风剑雅:BAABLAAFFH8GAAIOAAIIASJMHwDNAAAOAAIIASJMHwDNAAAAAA==.',['风沙']='风沙伤我的心:BAAALAAECgMIAwAAAA==.',['风竹']='风竹林:BAAALAAECgIIAgAAAA==.',['风雪']='风雪山高行:BAAALAADCgEIAQAAAA==.风雪漫天路:BAAALAADCgMIAwAAAA==.',['香煙']='香煙味的纏綿:BAAALAAECgcIBwAAAA==.',['骷髅']='骷髅咔咔:BAAALAAFFAIIAgAAAA==.',['鬼鬼']='鬼鬼笑笑:BAAALAAECgYIBwAAAA==.',['魔女']='魔女丶:BAAALAAFFAIIAwAAAA==.',['魔鬼']='魔鬼的步伐:BAAALAAECgYIBgAAAA==.',['魔魔']='魔魔法:BAABLAAECn8TAAIRAAcIWRzeaQDKAQARAAcIWRzeaQDKAQAAAA==.',['鲜花']='鲜花:BAAALAAECgYIBgAAAA==.',['黄昏']='黄昏的乐章:BAAALAAFFAIIAgAAAA==.',['黎明']='黎明的乐章:BAAALAAFFAEIAQAAAA==.',['黑头']='黑头:BAAALAAFFAIIAgAAAA==.',['黑萨']='黑萨:BAAALAAECgEIAQAAAA==.',['龙梅']='龙梅耳:BAABLAAECn8fAAIHAAcIPRXpRAA2AQAHAAcIPRXpRAA2AQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end