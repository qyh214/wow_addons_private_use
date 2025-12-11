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
 local lookup = {'Hunter-BeastMastery','DemonHunter-Havoc','Warlock-Destruction','Mage-Arcane','Druid-Balance','Druid-Guardian','Druid-Restoration','Hunter-Marksmanship','Unknown-Unknown','Warrior-Fury','Priest-Shadow','DeathKnight-Frost','DeathKnight-Unholy','Evoker-Preservation','Evoker-Devastation','Shaman-Restoration','Mage-Frost','Shaman-Elemental','Paladin-Retribution','Monk-Windwalker','Paladin-Holy',}; local provider = {region='CN',realm='萨洛拉丝',name='CN',type='weekly',zone=44,date='2025-12-07',data={Bl='Blandmaster:BAAALAAECgYIBgAAAA==.',Ch='Chenzz:BAABLAAFFH8PAAIBAAYI4htHKwCKAQABAAYI4htHKwCKAQAAAA==.',De='Demonfiend:BAACLAAFFH8IAAICAAUI0xRvHwDrAAACAAUI0xRvHwDrAAAsAAQKfxgAAgIABwjwH74zAI0CAAIABwjwH74zAI0CAAAA.',Di='Disfrutar:BAABLAAFFH8EAAIDAAQITiCgPwD9AAADAAQITiCgPwD9AAAAAA==.',Ey='Eyl:BAAALAAECgYIDQAAAA==.',Gq='Gqq:BAAALAAECgIIAgAAAA==.',Ma='Makki:BAAALAADCggICAAAAA==.',Me='Memoryreboot:BAAALAADCggICAAAAA==.',Ok='Oksky:BAAALAADCgMIAwAAAA==.',Pl='Playerwtkybr:BAAALAADCgIIAgAAAA==.',Re='Rexom:BAAALAAECgYIEQAAAA==.',Sh='Shadowsong:BAABLAAECn8WAAICAAYIBRfxmgCUAQACAAYIBRfxmgCUAQAAAA==.',Sr='Srdhrr:BAAALAAECgIIAgAAAA==.',Ta='Tangy:BAABLAAFFH8GAAIEAAIIPSG2PACjAAAEAAIIPSG2PACjAAAAAA==.',To='Topmiss:BAAALAADCgMIAwAAAA==.',Ye='Yepat:BAAALAADCgcIBwAAAA==.',Yu='Yukicool:BAAALAAECgYIDAAAAA==.',['一个']='一个球:BAAALAAECgYICgAAAA==.',['一叶']='一叶飘萍:BAAALAAECgQIBgAAAA==.',['上山']='上山打野:BAAALAAFFAMIAwAAAA==.',['丨打']='丨打獵的灬:BAAALAAFFAEIAQAAAA==.',['丶一']='丶一曲离骚:BAAALAAECgYIDQAAAA==.',['丶叁']='丶叁叁:BAAALAAECgcICwAAAA==.',['丶雨']='丶雨雾晴晨:BAACLAAFFH8mAAIFAAYIch5ACgC/AQAFAAYIch5ACgC/AQAsAAQKfywAAgUABwjNJfwMAAgDAAUABwjNJfwMAAgDAAAA.',['丿欧']='丿欧皇骑丶:BAAALAAECggICAAAAA==.',['乄麦']='乄麦克雷灬:BAAALAAECgYIDQAAAA==.',['九门']='九门:BAAALAAECgYICAAAAA==.',['二舅']='二舅丶:BAAALAAECgIIAgAAAA==.',['亚斯']='亚斯娜:BAAALAAECgYIBgAAAA==.',['亚瑟']='亚瑟戴恩:BAAALAADCgMIAwAAAA==.',['你三']='你三叔的表哥:BAAALAAFFAIIAgAAAA==.',['你生']='你生气了吗:BAAALAADCgQIBAAAAA==.',['修修']='修修婉儿:BAAALAAFFAIIAgAAAA==.',['偶来']='偶来丶酱油:BAABLAAFFH8OAAMGAAII8xmDBQCWAAAGAAII8xmDBQCWAAAHAAIIpwYeUQBTAAAAAA==.偶来灬打酱油:BAAALAAFFAYIAgAAAA==.',['光头']='光头也是光:BAAALAAFFAIIAwAAAA==.',['冰融']='冰融雪:BAAALAAECggICAAAAA==.',['剑舞']='剑舞春秋:BAAALAAECgQIBAAAAA==.',['劉氓']='劉氓头子丶:BAAALAAECgMIAwAAAA==.',['千早']='千早爱音:BAAALAADCgMIAwAAAA==.',['千离']='千离:BAAALAAECgYICQAAAA==.',['单机']='单机王:BAAALAAECggICAAAAA==.',['卟黛']='卟黛凶兆:BAAALAAECgQIBAAAAA==.',['召命']='召命:BAABLAAECn8YAAMIAAgIsCNFDwDpAgAIAAgIsCNFDwDpAgABAAYIrxJQFAETAQABLAAFFAQIBAAJAAAAAA==.',['叶落']='叶落剑折鹰:BAAALAAECgQIBAAAAA==.',['吖库']='吖库啦玛塔塔:BAAALAAFFAgIAgAAAA==.',['呵叻']='呵叻猫:BAAALAAECgIIAgAAAA==.',['咆哮']='咆哮的天空:BAABLAAFFH8HAAIBAAYIeB14IwCmAQABAAYIeB14IwCmAQAAAA==.',['和尚']='和尚丶要开荤:BAAALAAECgIIAgAAAA==.',['咕咕']='咕咕涌:BAAALAAFFAIIBAAAAA==.',['唔妞']='唔妞哈基米:BAAALAAFFAIIAgAAAA==.唔妞喂:BAAALAAFFAIIBAAAAA==.',['喂你']='喂你绿粑:BAAALAAECgMIAwAAAA==.',['嗲唔']='嗲唔妞:BAAALAAFFAIIAgAAAA==.',['嘟嘟']='嘟嘟桐桐:BAAALAAECgcIDgAAAA==.',['嘭灬']='嘭灬鉙:BAAALAAECgYICAAAAA==.',['圣光']='圣光来也:BAAALAAECggIDAAAAA==.',['地狱']='地狱魅影:BAAALAADCgIIAgAAAA==.',['坡道']='坡道灬医冢:BAAALAAECgYIBgAAAA==.',['夏乄']='夏乄樱络灬:BAAALAAECggIDwAAAA==.',['夜星']='夜星卿:BAAALAAECgYICgAAAA==.',['太懒']='太懒徳:BAAALAAECgYIBgAAAA==.',['妙脆']='妙脆狐:BAACLAAFFH8QAAIBAAYIUBL3PABTAQABAAYIUBL3PABTAQAsAAQKfyIAAgEACAjvGHdgABsCAAEACAjvGHdgABsCAAAA.妙脆鼠:BAABLAAFFH8VAAIKAAQI+hqDLQD0AAAKAAQI+hqDLQD0AAAAAA==.',['妮萨']='妮萨兰妮:BAAALAADCgIIAgAAAA==.',['宮胁']='宮胁咲良:BAAALAAFFAIIAgAAAA==.',['小学']='小学刚毕业:BAAALAAECgUIBQAAAA==.',['小甜']='小甜甜嘚乳妞:BAAALAAECgYIBgAAAA==.',['小肆']='小肆肆:BAAALAADCgEIAQAAAA==.',['小铁']='小铁柱:BAAALAAECgEIAQAAAA==.',['川上']='川上奈奈美:BAAALAAECgYIBwAAAA==.',['巴纳']='巴纳泽尔:BAABLAAECn8VAAILAAYIPBo2GwBxAQALAAYIPBo2GwBxAQAAAA==.',['布布']='布布熊:BAAALAAECgUIBQAAAA==.',['布鲁']='布鲁玛:BAAALAAFFAIIBAAAAA==.',['帅气']='帅气小砍刀:BAAALAAECgYIDQAAAA==.帅气泡芙:BAAALAAECgYIDAAAAA==.帅气的哆哆:BAAALAAECgIIAgAAAA==.帅气趣多多:BAAALAAECgYIEAAAAA==.帅气饼干:BAAALAADCgYICgAAAA==.',['平谷']='平谷一点红:BAAALAAECgMIAwAAAA==.',['库拉']='库拉玛塔塔:BAAALAAFFAYIBAAAAA==.',['恰柠']='恰柠檬:BAAALAADCgEIAQAAAA==.',['我不']='我不认识你:BAABLAAECn8WAAMMAAgIPBaOdQAMAgAMAAgIPBaOdQAMAgANAAgIiAbrKAB6AQAAAA==.',['我想']='我想丿静静灬:BAAALAADCgYIBgAAAA==.',['挽弓']='挽弓弑众神:BAAALAADCgcICAAAAA==.',['放弃']='放弃丶速度灭:BAAALAAECgYIBgAAAA==.',['断尾']='断尾求生:BAAALAAECggICAAAAA==.',['无关']='无关风月:BAAALAAECgYIBgAAAA==.',['春尹']='春尹帐帷桥:BAAALAAECgEIAQAAAA==.',['有梦']='有梦想的男刀:BAABLAAFFH8HAAICAAIITRUzOgCeAAACAAIITRUzOgCeAAAAAA==.',['来如']='来如疯去如癫:BAAALAAECggICAAAAA==.',['极度']='极度凶残:BAAALAAECgUIBgAAAA==.',['林中']='林中插翅虎:BAAALAAECgMIAwAAAA==.',['枭布']='枭布:BAAALAAFFAIIBAAAAA==.',['柠檬']='柠檬甜橙:BAAALAAECgQIBAAAAA==.',['桐宝']='桐宝:BAAALAAECgYICgAAAA==.',['桑榆']='桑榆晚:BAABLAAFFH8ZAAMOAAUIvgoFEQAZAQAOAAUIvgoFEQAZAQAPAAEImgIOIgA2AAAAAA==.',['梦境']='梦境微凉:BAAALAAECgYIBgAAAA==.',['樱噬']='樱噬妖空:BAAALAADCggICAAAAA==.',['樱花']='樱花咲良:BAAALAAECgYIBgAAAA==.',['欢迎']='欢迎业主回家:BAAALAAFFAYIBAABLAAFFAgIEwANADERAA==.',['水无']='水无缺灬:BAAALAADCgcIBwAAAA==.',['汉考']='汉考克:BAABLAAFFH8IAAIQAAUIOw4ALgD9AAAQAAUIOw4ALgD9AAAAAA==.',['沧桑']='沧桑一箭:BAACLAAFFH8JAAIBAAUIFRLzUgAHAQABAAUIFRLzUgAHAQAsAAQKfxcAAgEABwhSHY0uAAICAAEABwhSHY0uAAICAAAA.',['油物']='油物:BAAALAADCgEIAQAAAA==.',['淘丶']='淘丶小闹:BAAALAAECgMIAwAAAA==.',['淤泥']='淤泥软脚蟹:BAAALAADCgMIAwAAAA==.',['灬玛']='灬玛尔扎哈灬:BAAALAADCgcIBwAAAA==.',['灬神']='灬神说灬:BAAALAAFFAIIBAAAAA==.',['灬阿']='灬阿莫西林灬:BAAALAADCggICAAAAA==.',['灵魂']='灵魂工程师:BAAALAAFFAIIBAAAAA==.',['爆炸']='爆炸小裤衩:BAABLAAECn8XAAIBAAcIjBW5fABOAQABAAcIjBW5fABOAQAAAA==.',['爱莉']='爱莉希雅:BAAALAAECgMIAwAAAA==.',['牛浪']='牛浪浪丶:BAAALAADCgIIAgAAAA==.',['狮吼']='狮吼功丶:BAAALAAECgUIBwAAAA==.',['瓦拉']='瓦拉纳:BAAALAAECgYICwAAAA==.',['田二']='田二妞:BAAALAAFFAIIAgAAAA==.',['白衣']='白衣勝雪丶:BAABLAAFFH8GAAIRAAIIBQVoHgA0AAARAAIIBQVoHgA0AAAAAA==.',['白面']='白面葫芦娃:BAAALAAECgEIAQAAAA==.',['盗版']='盗版萨洛拉丝:BAAALAAECgIIAgAAAA==.',['秋意']='秋意如婵:BAAALAAFFAIIAgAAAA==.',['科长']='科长三号:BAABLAAFFH8IAAISAAgIaRyjBQBzAgASAAgIaRyjBQBzAgAAAA==.科长二号:BAABLAAFFH8UAAMSAAgI/yAEBAChAgASAAgI/yAEBAChAgAQAAEI1RQtcQBGAAAAAA==.科长五号:BAAALAAFFAgIAwAAAA==.科长六号:BAABLAAFFH8OAAMSAAYIXyImDADsAQASAAYIXyImDADsAQAQAAEIxheAdwA+AAAAAA==.科长四号:BAABLAAFFH8GAAMSAAYIcx2/IgAvAQASAAUIuxu/IgAvAQAQAAEIUQ1WegA3AAAAAA==.',['笨鸟']='笨鸟先飞:BAAALAAFFAIIAgAAAA==.',['等会']='等会儿:BAABLAAFFH8RAAIBAAMIHBBVdAB6AAABAAMIHBBVdAB6AAAAAA==.',['等待']='等待丶我的爱:BAAALAADCgIIAgAAAA==.',['箭雨']='箭雨之击:BAAALAADCgYIBgAAAA==.',['红色']='红色欧格林:BAAALAAECgYICQAAAA==.',['芯桃']='芯桃水:BAAALAAECggICgAAAA==.',['花有']='花有重开日:BAAALAAFFAMIAwAAAA==.',['花生']='花生牛腩:BAABLAAFFH8JAAQHAAIIuBARNABsAAAHAAIIuBARNABsAAAFAAEIrwcQOgA0AAAGAAIIxArQEAAjAAAAAA==.',['菲欧']='菲欧娜:BAAALAAECgIIAwAAAA==.',['萌牛']='萌牛奶:BAAALAAECgYIDAAAAA==.',['萌獣']='萌獣獸:BAAALAAECgIIAgAAAA==.',['萨洛']='萨洛天下:BAAALAAECgIIAgAAAA==.',['蒙蔽']='蒙蔽不了双眼:BAAALAAECggIBgAAAA==.',['蘇肆']='蘇肆:BAAALAAECgYICAABLAAFFAgIHgAMAKscAA==.',['贴钱']='贴钱买难受:BAAALAADCgYIBgAAAA==.',['走起']='走起撒:BAABLAAFFH8KAAITAAIIPhsOMgCpAAATAAIIPhsOMgCpAAAAAA==.',['超导']='超导体:BAABLAAFFH8IAAIUAAYIrA+yCwDEAAAUAAYIrA+yCwDEAAAAAA==.',['辛多']='辛多瑞拉丶泪:BAAALAAECgYIBgAAAA==.',['逗战']='逗战胜佛:BAABLAAFFH8IAAIBAAIIphWMVwCRAAABAAIIphWMVwCRAAAAAA==.',['铁柱']='铁柱八号:BAAALAAECgEIAQAAAA==.铁柱哥:BAAALAAECgEIAQAAAA==.',['阿巴']='阿巴不结巴:BAAALAADCgIIAgABLAADCgYIBgAJAAAAAA==.阿巴是个德:BAAALAADCgYIBgAAAA==.',['阿库']='阿库拉玛塔塔:BAABLAAFFH8TAAMNAAgIMRHrBwADAQANAAMIaB3rBwADAQAMAAYI5gteTACkAAAAAA==.',['香甜']='香甜可口:BAABLAAFFH8MAAMTAAYI2xCvHwBtAQATAAYI2xCvHwBtAQAVAAIIRgvlJAB+AAAAAA==.',['骑马']='骑马多多:BAAALAAFFAIIAgAAAA==.',['黄浦']='黄浦江之狼:BAAALAAECgYIBgAAAA==.',['黑心']='黑心德:BAAALAADCgEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end