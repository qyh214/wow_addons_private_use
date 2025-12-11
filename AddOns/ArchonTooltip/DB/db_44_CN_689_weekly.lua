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
 local lookup = {'DeathKnight-Frost','Druid-Restoration','Evoker-Augmentation','Evoker-Devastation','Hunter-Marksmanship','Paladin-Retribution','DemonHunter-Havoc','Mage-Arcane','Rogue-Assassination','Rogue-Subtlety','Warlock-Destruction','Warrior-Fury','DeathKnight-Unholy','Hunter-BeastMastery','Hunter-Survival','Monk-Brewmaster','Priest-Holy','Druid-Balance','DeathKnight-Blood','Warrior-Arms','Druid-Feral','Warrior-Protection','Paladin-Protection','Shaman-Elemental','Monk-Mistweaver','Mage-Frost','Shaman-Restoration','Warlock-Demonology',}; local provider = {region='CN',realm='拉文霍德',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ar='Areslol:BAAALAAFFAIIBAAAAA==.Arthasdk:BAACLAAFFH8MAAIBAAMIYhf4LgDfAAABAAMIYhf4LgDfAAAsAAQKfxwAAgEABwgIHWJvABcCAAEABwgIHWJvABcCAAAA.',Ca='Cady:BAAALAAECgYIEgAAAA==.',Cz='Czq:BAACLAAFFH8HAAICAAMIhA2mHgCoAAACAAMIhA2mHgCoAAAsAAQKfyIAAgIACAgCGVI7APIBAAIACAgCGVI7APIBAAAA.',De='De:BAAALAAECgEIAQAAAA==.',Dy='Dyvoker:BAACLAAFFH8XAAMDAAUIBRBOCAATAQADAAUImg5OCAATAQAEAAUIJw09EgDwAAAsAAQKfxoAAgQACAgnGLsYAFsCAAQACAgnGLsYAFsCAAEsAAUUCAgkAAIApiAA.',Ei='Eian:BAAALAAECgUIBgAAAA==.',Ga='Gaily:BAAALAADCgMIAwAAAA==.',Hi='Himeka:BAAALAAECgIIAgAAAA==.',Ia='Iamdk:BAAALAAECgUIBQAAAA==.',Is='Isha:BAACLAAFFH8GAAIFAAIIECEmEQBqAAAFAAIIECEmEQBqAAAsAAQKfxUAAgUACAijIbcWAK0CAAUACAijIbcWAK0CAAAA.',Iz='Izeroi:BAABLAAFFH8HAAIGAAMIjBcaPgCaAAAGAAMIjBcaPgCaAAAAAA==.',Ja='Jasonwswswws:BAAALAAECggIDgAAAA==.',Jo='Johnny:BAAALAADCgUIBQAAAA==.',Ki='Kisser:BAAALAAECgYIBgAAAA==.',La='Lancelo:BAAALAAECgYIBwAAAA==.',Lo='Losemind:BAAALAAECgcIBgAAAA==.',Lz='Lzeroii:BAABLAAFFH8GAAIHAAIImw/dTQBLAAAHAAIImw/dTQBLAAAAAA==.',Ni='Nineonee:BAAALAAECgMIAwAAAA==.',Oo='Ooggd:BAAALAAECgIIAgAAAA==.',Pz='Pzpz:BAABLAAFFH8IAAICAAII7Br0IQCdAAACAAII7Br0IQCdAAAAAA==.',Sc='Scoflied:BAAALAAFFAIIAgAAAA==.',Si='Silversoul:BAAALAAECggICAAAAA==.',Sl='Slivan:BAAALAAFFAIIAgAAAA==.',Ti='Tindomiel:BAABLAAFFH8FAAIFAAUIgxatCQATAQAFAAUIgxatCQATAQAAAA==.Titanium:BAAALAADCgUIBQAAAA==.',Tx='Txvlog:BAAALAAFFAMIAwAAAA==.',Va='Vance:BAAALAAECgUIBQAAAA==.',Wa='Warning:BAAALAADCgUIBQAAAA==.',Wi='Withered:BAABLAAFFH8GAAIIAAYIwhpAJQCAAQAIAAYIwhpAJQCAAQAAAA==.',['一只']='一只小跳蛙:BAAALAAECgMIAwAAAA==.',['一霸']='一霸王龙一:BAAALAAFFAIIAgAAAA==.',['三妹']='三妹:BAAALAAECgMIAwAAAA==.',['三年']='三年二班啊大:BAAALAAFFAIIAgAAAA==.三年二班阿贰:BAAALAAECgQIBAAAAA==.',['不在']='不在场证明:BAABLAAFFH8MAAMJAAYIpRTgAQAHAgAJAAYIhBHgAQAHAgAKAAYIdhM2BwBmAQAAAA==.',['不朽']='不朽:BAAALAAECgIIAgAAAA==.',['不知']='不知道:BAAALAAFFAIIAgAAAA==.',['不能']='不能怂赶紧送:BAABLAAFFH8IAAILAAYIBhA2HQBKAQALAAYIBhA2HQBKAQAAAA==.',['为了']='为了小小战:BAABLAAFFH8FAAIMAAMInRIXOQCOAAAMAAMInRIXOQCOAAAAAA==.',['主宰']='主宰灬刺心:BAABLAAFFH8KAAMNAAIIUhSeFACGAAANAAIIUhSeFACGAAABAAEIdQFOsAAAAAAAAA==.',['乂哀']='乂哀木涕乂:BAAALAAECgYICAAAAA==.',['九莲']='九莲宝灯:BAAALAADCgUIBQAAAA==.',['五档']='五档太阳神:BAABLAAFFH8GAAIIAAII6hxnTQCTAAAIAAII6hxnTQCTAAAAAA==.',['亲姐']='亲姐没干姐好:BAAALAADCgYIBgAAAA==.',['任我']='任我骑:BAAALAAECgMIAwAAAA==.',['伊卡']='伊卡璐思:BAABLAAECn8YAAMOAAYIvhxXSwCvAQAPAAYI/BaLDgC+AQAOAAYIkBxXSwCvAQAAAA==.',['伊莉']='伊莉雅苏菲尔:BAAALAAECgEIAQAAAA==.',['伯瓦']='伯瓦尔的遗言:BAAALAADCgQIBAAAAA==.',['伴风']='伴风听雨:BAAALAAECgYIBwAAAA==.',['傀灵']='傀灵:BAAALAADCgYICAAAAA==.',['元亨']='元亨利贞:BAAALAAFFAMIAwAAAA==.',['兰斯']='兰斯彼恩:BAAALAADCggICAAAAA==.',['凋零']='凋零了华年:BAAALAAECgYIBgAAAA==.',['凌凌']='凌凌发:BAAALAADCgIIAgAAAA==.',['凨凪']='凨凪凮夙:BAAALAAECgIIAQAAAA==.',['凯瑟']='凯瑟兰斯:BAAALAADCgYIBgAAAA==.',['劣人']='劣人小小:BAAALAAECgUICAAAAA==.',['匚匸']='匚匸凵冂:BAAALAADCgcIBwAAAA==.',['十玖']='十玖鱼:BAAALAADCgEIAQAAAA==.',['华咕']='华咕咕:BAAALAAECggIDAAAAA==.',['华扁']='华扁鹊:BAAALAAECggIEQABLAAFFAgIFQALAJEHAA==.',['南柯']='南柯:BAABLAAFFH8GAAIQAAYIuhrHCgCXAQAQAAYIuhrHCgCXAQAAAA==.',['卡萨']='卡萨丶布兰卡:BAAALAAFFAIIAgAAAA==.',['双魚']='双魚理:BAABLAAFFH8YAAIIAAgI/yI5AwDDAgAIAAgI/yI5AwDDAgAAAA==.',['向哥']='向哥:BAAALAADCgIIAgAAAA==.',['啸天']='啸天:BAAALAADCgEIAQAAAA==.',['喔洡']='喔洡哒哒:BAAALAAECgYIBgAAAA==.',['喝了']='喝了口水就:BAAALAADCgIIAgAAAA==.',['嘟嘟']='嘟嘟熊:BAAALAADCgEIAQAAAA==.',['嘿老']='嘿老师儿:BAAALAADCgMIAwAAAA==.',['圣光']='圣光守护者:BAAALAADCgQIBAAAAA==.',['圣堂']='圣堂银狐:BAAALAAECgEIAQAAAA==.',['地摊']='地摊小贩:BAAALAAECgYIBgAAAA==.',['地狱']='地狱使者:BAAALAADCggICAAAAA==.',['大乃']='大乃起来:BAAALAAFFAMIAwAAAA==.',['大坚']='大坚果:BAAALAAECgYIBgAAAA==.',['大熊']='大熊硬糖:BAAALAAFFAIIBAAAAA==.',['大牛']='大牛儿:BAAALAAECgMIAwAAAA==.',['大神']='大神带带我:BAAALAAECgYIDwAAAA==.',['天蓝']='天蓝的雪球:BAAALAAECgIIAgAAAA==.',['奥莉']='奥莉薇:BAAALAAECgUIBQAAAA==.',['女乃']='女乃木奉兒:BAAALAAECgQICgAAAA==.',['女神']='女神:BAAALAAFFAMIAwAAAA==.',['奶量']='奶量充足:BAABLAAFFH8iAAIRAAYIhR6bCgAfAgARAAYIhR6bCgAfAgAAAA==.',['妳们']='妳们真高:BAABLAAFFH8GAAIBAAII2w1WigBBAAABAAII2w1WigBBAAAAAA==.',['守卫']='守卫瓦坎达:BAAALAAECgEIAQAAAA==.',['安不']='安不丶:BAACLAAFFH8cAAMCAAUIKCO4DADsAQACAAUIKCO4DADsAQASAAUI2QctHgDWAAAsAAQKfxUAAwIACAhSHnUdAH4CAAIACAhSHnUdAH4CABIAAghuFdxMAIIAAAAA.',['完全']='完全兽捕鸟:BAABLAAFFH8FAAMFAAMIERrRDwDxAAAFAAMIERrRDwDxAAAOAAIIjwTftgAyAAAAAA==.',['寂静']='寂静岭之秋:BAAALAAECgYIBwAAAA==.',['寒夜']='寒夜影:BAAALAAECgcICgAAAA==.',['小九']='小九吖:BAAALAAFFAIIAgAAAA==.',['小巨']='小巨巨:BAAALAAECgIIAgAAAA==.',['小熊']='小熊猫:BAABLAAFFH8GAAIBAAIIigkolwA7AAABAAIIigkolwA7AAAAAA==.',['小萨']='小萨满:BAAALAADCgcIBwAAAA==.',['尘殇']='尘殇:BAAALAAECgYIEgAAAA==.',['屁屁']='屁屁熊:BAAALAAFFAIIBAAAAA==.',['属于']='属于龙族:BAAALAAFFAIIAgAAAA==.',['山雾']='山雾:BAAALAADCgEIAQAAAA==.',['岳阳']='岳阳果盘战神:BAABLAAFFH8VAAMBAAYIywrMNADLAAABAAYIywrMNADLAAATAAEINANnHQAsAAAAAA==.',['巧克']='巧克力甜甜圈:BAAALAADCgQIBAAAAA==.',['布莱']='布莱克铁髯:BAAALAAECgYIBgAAAA==.',['布雷']='布雷德:BAAALAAFFAIIAgAAAA==.',['常言']='常言道:BAAALAAFFAIIAwAAAA==.',['干中']='干中学:BAAALAAECggIEwAAAA==.',['弦上']='弦上啭春莺:BAAALAAECgYICAAAAA==.',['弱弱']='弱弱:BAAALAAECgUIBQAAAA==.',['往日']='往日审判:BAAALAAECgUIBQAAAA==.',['很有']='很有趣的名字:BAAALAAECgYICAAAAA==.',['心安']='心安归处:BAAALAAECgIIAgAAAA==.',['心灵']='心灵种子:BAAALAAECgYICAAAAA==.',['心魔']='心魔玄劫:BAABLAAECn8bAAMMAAgIoRE+OAB3AQAMAAcIABI+OAB3AQAUAAMIQg67EQBoAAAAAA==.',['忙碌']='忙碌的小鹏:BAAALAAECgYIBgAAAA==.',['意达']='意达的花:BAAALAAECgIIAwAAAA==.',['我还']='我还能说啥:BAAALAAFFAIIBAAAAA==.',['戲臺']='戲臺:BAAALAADCgIIAgAAAA==.',['扬扬']='扬扬:BAAALAAECgEIAQAAAA==.',['把酒']='把酒叹平生:BAAALAADCggIDAAAAA==.',['护肝']='护肝片:BAAALAADCgEIAQAAAA==.',['拉米']='拉米亚:BAAALAADCgMIAwAAAA==.',['拒绝']='拒绝九九六:BAAALAADCgEIAQAAAA==.',['拾久']='拾久鱼:BAAALAAECgIIAgAAAA==.',['掱機']='掱機在待機:BAABLAAFFH8GAAIVAAQI8xD+CQCMAAAVAAQI8xD+CQCMAAAAAA==.',['摩诃']='摩诃迦叶:BAAALAAECgYIBgAAAA==.',['摸鱼']='摸鱼大王:BAAALAADCgYIBgAAAA==.',['攻必']='攻必克战必胜:BAAALAADCgIIAgAAAA==.',['断幺']='断幺九:BAABLAAFFH8KAAIGAAIISwiGVQCNAAAGAAIISwiGVQCNAAAAAA==.',['断罪']='断罪之光:BAAALAAECggIBwAAAA==.',['时尚']='时尚小海蟹:BAAALAAECgYIBgAAAA==.',['星图']='星图史话:BAABLAAFFH8GAAIOAAIIfR1kPgCpAAAOAAIIfR1kPgCpAAAAAA==.',['晓骄']='晓骄:BAAALAAFFAIIBAAAAA==.',['暮沐']='暮沐沐:BAAALAAECgEIAQAAAA==.',['曲世']='曲世爱丶语风:BAAALAAECgEIAQAAAA==.',['月光']='月光守护者:BAAALAAECgMIAwAAAA==.',['月夜']='月夜之沅:BAAALAADCgQIBAAAAA==.月夜小蚊子:BAAALAADCgIIAgAAAA==.月夜晨夕:BAAALAAECgcIBwAAAA==.',['月隐']='月隐云影:BAAALAAECgQIBAAAAA==.',['末日']='末日傲气:BAAALAAECggIDAAAAA==.',['杀戮']='杀戮未命中:BAAALAAECgMIBAAAAA==.',['来自']='来自虚空:BAAALAAECgUIBQAAAA==.',['梦启']='梦启岚:BAABLAAFFH8GAAIWAAIIrh5QJQBTAAAWAAIIrh5QJQBTAAAAAA==.',['楓飛']='楓飛逸:BAAALAAECgYIAwAAAA==.',['樱岛']='樱岛流京子:BAAALAAFFAIIAgAAAA==.',['殇灬']='殇灬无痕:BAAALAAECgIIAQAAAA==.殇灬浅陌:BAAALAAECgIIAgAAAA==.',['残空']='残空:BAAALAAECgUICQAAAA==.',['沙爆']='沙爆送葬:BAAALAADCgYIBgAAAA==.',['油菜']='油菜妞:BAAALAAECgIIAgAAAA==.',['治愈']='治愈系少女:BAAALAAECgYIBgAAAA==.',['法厄']='法厄同:BAABLAAFFH8UAAITAAgIlx4IAgCHAgATAAgIlx4IAgCHAgAAAA==.',['法林']='法林:BAAALAAECgYIEAAAAA==.',['津雪']='津雪儿:BAAALAAECgYIDgAAAA==.',['灬奔']='灬奔波霸灬:BAAALAADCggICAAAAA==.',['炫灬']='炫灬射手座冫:BAAALAAECgQIBAAAAA==.',['炭烧']='炭烧优酸乳:BAABLAAFFH8GAAIXAAYI2hHQBwBFAQAXAAYI2hHQBwBFAQABLAAFFAYIDAAJAKUUAA==.',['炽阳']='炽阳:BAAALAAFFAIIAwAAAA==.',['燕赤']='燕赤侠:BAABLAAFFH8PAAIYAAYI2weaSgA8AAAYAAYI2weaSgA8AAAAAA==.',['爸吧']='爸吧:BAABLAAECn8WAAIZAAYILw8fMAAkAQAZAAYILw8fMAAkAQABLAAFFAMIDAABAGIXAA==.',['牛肉']='牛肉帝王:BAAALAAECgIIAgAAAA==.',['狐七']='狐七七:BAAALAAECgYIEgAAAA==.',['玄奘']='玄奘:BAAALAADCgIIAgAAAA==.',['玉米']='玉米:BAACLAAFFH8MAAMBAAIIaSJpOQC/AAABAAIIUCJpOQC/AAATAAEISyAdFwBNAAAsAAQKfzYAAgEACAilJVYFAG0DAAEACAilJVYFAG0DAAEsAAUUAggOAAYATCMA.',['王扁']='王扁:BAAALAAECgEIAQAAAA==.',['玓瓑']='玓瓑:BAAALAAECgQIBAAAAA==.',['瑜伽']='瑜伽顽石:BAAALAAECgcIDQAAAA==.',['璀璨']='璀璨剑光:BAAALAAFFAIIAgAAAA==.',['生命']='生命的缚誓者:BAAALAAECgYIEgAAAA==.',['生存']='生存死亡:BAAALAAECgMIAwAAAA==.',['畵镹']='畵镹:BAAALAAECgYIBwAAAA==.',['疯狂']='疯狂小鸡:BAAALAAECgYIBgAAAA==.疯狂的帅鸡:BAACLAAFFH8fAAIIAAYIqwvtKwBgAQAIAAYIqwvtKwBgAQAsAAQKfyMAAwgABwhUG2UdAMABAAgABwhUG2UdAMABABoAAQj7FVaOAD8AAAAA.',['疯魔']='疯魔辣:BAAALAAECgYIBgAAAA==.',['皓博']='皓博迎朝阳:BAAALAAECgYICQAAAA==.',['目垂']='目垂礻申:BAAALAAECgYIBAAAAA==.',['看我']='看我闪:BAAALAADCgUIBQAAAA==.',['碧愈']='碧愈疾风:BAAALAAECggICQAAAA==.',['神聖']='神聖之光:BAAALAADCgIIAgAAAA==.',['秋之']='秋之传说:BAAALAAECgUIBQAAAA==.秋之哀伤:BAAALAADCgEIAQAAAA==.',['空悲']='空悲切:BAAALAADCgYIDAAAAA==.',['筱筱']='筱筱萨:BAAALAAECgUIBQAAAA==.',['糖醋']='糖醋番茄:BAAALAAECgEIAQAAAA==.',['红烧']='红烧大肉肉:BAAALAAFFAMIAwAAAA==.',['终雨']='终雨:BAAALAADCgMIAwAAAA==.',['羡慕']='羡慕忌妒恨:BAAALAAECgYIBgAAAA==.',['老一']='老一套:BAABLAAFFH8IAAIXAAIIrQlGHgAvAAAXAAIIrQlGHgAvAAAAAA==.',['老娘']='老娘是个鸡:BAAALAAECggICAAAAA==.',['聖光']='聖光丶:BAAALAAFFAIIAgAAAA==.',['聪聪']='聪聪那年:BAAALAAECgIIAgAAAA==.',['臣妾']='臣妾:BAAALAAECgcIEwAAAA==.',['自作']='自作多情:BAABLAAECn8fAAIMAAgIbhsyJgDKAQAMAAgIbhsyJgDKAQAAAA==.',['舒叔']='舒叔叔:BAAALAADCggICAAAAA==.',['艾克']='艾克塞琳:BAABLAAFFH8GAAIaAAIIWx/VEgBMAAAaAAIIWx/VEgBMAAAAAA==.',['花卷']='花卷:BAABLAAFFH8GAAIIAAYInQCtJgD5AAAIAAYInQCtJgD5AAAAAA==.',['苏幕']='苏幕遮:BAAALAAECgYIBgAAAA==.',['苦苦']='苦苦吖:BAAALAAECggIDwAAAA==.',['茉莉']='茉莉绿茶:BAAALAAECgYIBgAAAA==.',['荼毒']='荼毒茉莉:BAAALAAECgYIBwAAAA==.',['莫等']='莫等闲:BAAALAAECgYIBgAAAA==.',['萨满']='萨满:BAAALAAECgMIAwAAAA==.',['萨飒']='萨飒飒:BAABLAAFFH8GAAIbAAYIHQAogAAjAAAbAAYIHQAogAAjAAAAAA==.',['蒙哥']='蒙哥丶开摆了:BAAALAAFFAIIBAAAAA==.',['蓝忆']='蓝忆:BAAALAAECgYIBgAAAA==.',['蓝莓']='蓝莓雪葩:BAAALAAECgYIBgAAAA==.',['虚弱']='虚弱老登:BAAALAAECgUIBQAAAA==.',['註縡']='註縡灬刖:BAABLAAFFH8IAAIRAAII4ga/PwB2AAARAAII4ga/PwB2AAAAAA==.',['谁怕']='谁怕你啊:BAAALAAECgYIBwAAAA==.',['赛欧']='赛欧菈:BAAALAAFFAIIAgAAAA==.',['赤炎']='赤炎咆哮:BAAALAAECgQIBgAAAA==.',['路盾']='路盾叁仟:BAAALAAECgYICgAAAA==.',['过劳']='过劳阿姨:BAAALAADCgYIBgAAAA==.',['进击']='进击大娃:BAAALAAECgUIBQAAAA==.',['迷谷']='迷谷:BAAALAAECgQIBAAAAA==.',['逃无']='逃无可桃:BAAALAAECgYIEwAAAA==.',['那么']='那么大鸡排:BAAALAAECgIIAgAAAA==.',['都说']='都说它好玩:BAABLAAFFH8HAAIBAAUIVRopNgBjAQABAAUIVRopNgBjAQAAAA==.',['野蛮']='野蛮旋律:BAAALAADCgcIBwAAAA==.',['锈羽']='锈羽:BAABLAAECn8YAAMcAAcI0R3VEgBlAgAcAAcI0R3VEgBlAgALAAEIdAe4nQAqAAAAAA==.',['阿兹']='阿兹瑞思:BAAALAAFFAIIBAABLAAFFAMIDAABAGIXAA==.',['阿牧']='阿牧丶斯特丹:BAAALAAECgYIBgAAAA==.',['阿萨']='阿萨斯:BAABLAAFFH8GAAIBAAII0Qo5hgBDAAABAAII0Qo5hgBDAAAAAA==.',['阿邦']='阿邦姐:BAABLAAFFH8cAAIGAAYIDyIyCAAIAgAGAAYIDyIyCAAIAgAAAA==.',['阿露']='阿露菲米:BAAALAAFFAIIAgAAAA==.',['陆离']='陆离:BAABLAAFFH8NAAIOAAQI5RnELQDMAAAOAAQI5RnELQDMAAAAAA==.',['陶白']='陶白白:BAABLAAFFH8GAAMVAAIIGxPpDwCJAAAVAAII+hDpDwCJAAASAAEI8wWuLwA3AAAAAA==.',['雪化']='雪化凝冰:BAAALAAECgYIBgAAAA==.',['雷諾']='雷諾:BAABLAAFFH8jAAMJAAYIkhXvAQACAgAJAAYIkhXvAQACAgAKAAIIWArJFwA4AAAAAA==.',['雷霆']='雷霆之子:BAABLAAFFH8KAAIBAAMIeRegVwCnAAABAAMIeRegVwCnAAAAAA==.',['青春']='青春从不绽放:BAAALAAECgYIDwAAAA==.',['静默']='静默时光:BAAALAAFFAIIBAAAAA==.',['韩宇']='韩宇:BAAALAADCgYIBgAAAA==.',['风季']='风季:BAAALAAECgUIBQAAAA==.',['风起']='风起那年:BAAALAADCgYIBgAAAA==.',['风间']='风间流:BAAALAAFFAIIAgAAAA==.',['香香']='香香公主:BAACLAAFFH8kAAIIAAYIjxOAJgB7AQAIAAYIjxOAJgB7AQAsAAQKfxsAAggACAjPG69DAD4CAAgACAjPG69DAD4CAAAA.',['魔瞳']='魔瞳使者:BAABLAAECn8bAAMIAAYIpQwYQwD/AAAIAAYIpQwYQwD/AAAaAAMIcgMbigBMAAAAAA==.',['黑夜']='黑夜:BAAALAAECgYIBgAAAA==.',['黑石']='黑石:BAAALAADCggICAAAAA==.',['黑色']='黑色心情:BAAALAAECgYIDAAAAA==.',['黛蒂']='黛蒂:BAAALAAECgcIDAAAAA==.',['龍腾']='龍腾飞翔:BAAALAADCgUIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end