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
 local lookup = {'Mage-Frost','Mage-Arcane','Warrior-Fury','DeathKnight-Frost','Shaman-Elemental','Paladin-Retribution','Hunter-BeastMastery','Warlock-Destruction','Druid-Feral','Druid-Guardian','Druid-Restoration','DeathKnight-Blood','Shaman-Restoration','Unknown-Unknown','Rogue-Subtlety','Warrior-Protection','DemonHunter-Vengeance','Monk-Windwalker','Hunter-Survival','Hunter-Marksmanship','DemonHunter-Havoc','Paladin-Protection','Priest-Shadow','Warrior-Arms','Monk-Mistweaver','Paladin-Holy','Rogue-Assassination','Priest-Holy','Monk-Brewmaster',}; local provider = {region='CN',realm='毁灭之锤',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ac='Acemoment:BAAALAADCgYIBgAAAA==.Acezar:BAAALAAECgcIBwAAAA==.',Al='Alexmoses:BAAALAAECggICgAAAA==.',Az='Azurophia:BAAALAAECgIIAgAAAA==.',Bw='Bwonsamdi:BAAALAAECgYIBgAAAA==.',Ca='Casarchmage:BAACLAAFFH8FAAMBAAMIWROBDQCCAAABAAMIWROBDQCCAAACAAIIVAjSZgAzAAAsAAQKfx8AAwIABwjUF7ZOABkCAAIABwjUF7ZOABkCAAEAAwguECV0AJsAAAAA.Casnn:BAACLAAFFH8rAAIDAAcIjBfBDQDrAQADAAcIjBfBDQDrAQAsAAQKfyAAAgMACAjeIYsXAPoCAAMACAjeIYsXAPoCAAAA.',Ch='Chopper:BAABLAAECn8dAAIEAAYIdRaLSABpAQAEAAYIdRaLSABpAQAAAA==.',Dn='Dnshaman:BAABLAAECn8lAAIFAAcIFhbqJgCFAQAFAAcIFhbqJgCFAQAAAA==.',Ei='Eilmaris:BAAALAAECgIIAgAAAA==.',Er='Error:BAAALAAFFAIIBAAAAA==.',Ge='Geain:BAABLAAFFH8JAAIGAAMIwhzeOQCyAAAGAAMIwhzeOQCyAAABLAAFFAYIGQADAFsYAA==.',Hu='Hullabeyoo:BAAALAADCgMIAwAAAA==.',In='Int:BAAALAAECgIIAgAAAA==.',Ky='Kyllin:BAAALAADCgYIBgAAAA==.',Lo='Lois:BAAALAAECgEIAQAAAA==.',Ma='Macmillan:BAAALAAECgEIAQABLAAFFAMIBwAHAHcQAA==.Maedaatsuko:BAAALAADCgEIAQAAAA==.',Or='Orlandobulu:BAABLAAFFH8JAAIHAAMIQwtdeABsAAAHAAMIQwtdeABsAAAAAA==.',Ri='Rino:BAAALAAECgYICgAAAA==.',Ro='Ronz:BAABLAAFFH8OAAIIAAYIdxUQMQBUAQAIAAYIdxUQMQBUAQAAAA==.Ronzsmiledia:BAAALAAECgMIAwAAAA==.',Se='Senoritad:BAAALAAECgUIBwAAAA==.',St='Stronger:BAABLAAFFH8FAAIEAAII8xdMVwCdAAAEAAII8xdMVwCdAAAAAA==.',Sv='Svnilljoo:BAAALAADCgEIAQAAAA==.',Te='Tezukaj:BAABLAAFFH8OAAIEAAYIghTUMgBvAQAEAAYIghTUMgBvAQAAAA==.',Ti='Timit:BAAALAADCgMIBAAAAA==.',Ve='Vermagillo:BAAALAADCgUIBQAAAA==.',Wh='Why:BAAALAAECgYICAAAAA==.',Xe='Xeain:BAABLAAFFH8ZAAIDAAYIWxjuFgCnAQADAAYIWxjuFgCnAQAAAA==.',Yc='Yccdk:BAAALAADCgYIBwAAAA==.',Ys='Yss:BAABLAAFFH8IAAIGAAII8xS+YgBFAAAGAAII8xS+YgBFAAAAAA==.',['一口']='一口熊根:BAAALAAECgYIBgAAAA==.',['一叶']='一叶孤舟:BAAALAADCgIIAgAAAA==.',['一心']='一心丶一意:BAAALAAFFAIIBAAAAA==.',['一条']='一条咸鱼:BAAALAAECgYIBgAAAA==.',['一眼']='一眼电死你:BAABLAAFFH8MAAIFAAII4gqaSAA/AAAFAAII4gqaSAA/AAAAAA==.',['一锤']='一锤八佰:BAABLAAECn8aAAIGAAgIZh3TLAC+AgAGAAgIZh3TLAC+AgABLAAFFAYIGwABAOIXAA==.',['一页']='一页书:BAAALAAFFAIIAgAAAA==.',['七一']='七一夜:BAAALAAECgYIBgAAAA==.',['七乂']='七乂夜:BAABLAAFFH8MAAIDAAII+hlAKgCmAAADAAII+hlAKgCmAAABLAAFFAgIOAADAHgjAA==.',['万物']='万物死丶:BAAALAAECgYICwAAAA==.',['与人']='与人为善:BAAALAAECgUIBQAAAA==.',['与龙']='与龙共舞:BAAALAAECgYIDAAAAA==.',['丿犄']='丿犄角尖尖:BAAALAAFFAIIAgAAAA==.',['乄小']='乄小蔷薇乄:BAAALAAECgYIBgABLAAECggIIQABAAwVAA==.',['乌薪']='乌薪王戈温:BAAALAAECgYIBgAAAA==.',['九品']='九品侍卫:BAABLAAFFH8MAAIDAAYICQBnZwAKAAADAAYICQBnZwAKAAAAAA==.九品枯术:BAABLAAFFH8SAAIIAAYIDgD1dQAEAAAIAAYIDgD1dQAEAAAAAA==.',['二皇']='二皇子:BAAALAAECgIIAgAAAA==.',['云无']='云无月:BAAALAAECgYIDQAAAA==.',['云飘']='云飘卝如意:BAAALAAFFAIIAwAAAA==.',['五军']='五军营萌新:BAAALAAECggIEAAAAA==.',['五师']='五师兄:BAAALAAECgQICAAAAA==.',['亡魄']='亡魄:BAAALAAECgYIEQAAAA==.',['京城']='京城蚀血者:BAABLAAECn8YAAQJAAgIDxD0EwD4AAAJAAcIiRD0EwD4AAAKAAUIewxfHAChAAALAAYIAAnzYgCTAAAAAA==.',['京都']='京都:BAAALAAFFAEIAQAAAA==.',['仁者']='仁者无欲:BAAALAAFFAEIAQAAAA==.',['今天']='今天吃牛肉面:BAABLAAFFH8LAAILAAgI3h4AAgDSAgALAAgI3h4AAgDSAgAAAA==.',['他不']='他不是英雄:BAABLAAECn8dAAIDAAgIXBHRMgCOAQADAAgIXBHRMgCOAQAAAA==.',['伊利']='伊利咖啡:BAAALAAECgUIBwAAAA==.伊利蛋炒饭:BAAALAAECgMIBAAAAA==.',['你微']='你微笑时好邹:BAAALAADCgQIBAAAAA==.',['你是']='你是自由的:BAAALAAECgYIBgAAAA==.',['你来']='你来咬我啊:BAAALAADCgcIBwAAAA==.',['你的']='你的牛牛:BAAALAAFFAIIAgAAAA==.',['做卜']='做卜爱做的事:BAAALAAECgIIAwAAAA==.',['八咫']='八咫穹苍月:BAAALAAFFAIIAgAAAA==.',['八戒']='八戒:BAAALAADCgEIAQAAAA==.',['兵長']='兵長:BAAALAAFFAIIBAAAAA==.',['其柔']='其柔:BAAALAAECgYIDAAAAA==.',['冰美']='冰美式不好喝:BAABLAAFFH8IAAIEAAMImAxRYgCIAAAEAAMImAxRYgCIAAAAAA==.',['凶猛']='凶猛大狐狸:BAAALAAECgYIBAAAAA==.',['列农']='列农:BAAALAADCgQIBAAAAA==.',['刷漆']='刷漆的皮皮:BAAALAAECgQIBAAAAA==.',['加特']='加特林沃洛克:BAABLAAFFH8GAAIIAAYIPgmYMgBLAQAIAAYIPgmYMgBLAQAAAA==.',['劳大']='劳大:BAAALAADCgMIAwAAAA==.',['勇猛']='勇猛大狐狸:BAAALAAFFAIIAgAAAA==.',['化剑']='化剑为犁:BAABLAAFFH8GAAMEAAYIGwVRTQD0AAAEAAUI3gVRTQD0AAAMAAEISwGBHwAhAAAAAA==.',['北帝']='北帝罗兰:BAAALAAECggICAAAAA==.',['南门']='南门老萨满:BAABLAAFFH8YAAMNAAYI7REgIABbAQANAAYI7REgIABbAQAFAAUISgaBKwDhAAAAAA==.',['卡卡']='卡卡罗:BAABLAAFFH8IAAIGAAIIvgr9UACRAAAGAAIIvgr9UACRAAAAAA==.',['卡洛']='卡洛斯:BAAALAAFFAIIBAAAAA==.',['受死']='受死吧你:BAAALAAFFAIIBAAAAA==.',['可爱']='可爱大狐狸:BAAALAAFFAIIAgAAAA==.可爱菇:BAABLAAFFH8HAAINAAUIEBFIKAAhAQANAAUIEBFIKAAhAQAAAA==.',['叶小']='叶小钗:BAAALAAECgEIAQAAAA==.',['吃奶']='吃奶:BAAALAAECgYIBgAAAA==.',['吃葱']='吃葱不吃蒜:BAAALAAECgEIAQAAAA==.',['后海']='后海大鲨鱼丶:BAAALAAECgEIAQAAAA==.',['后端']='后端爱护:BAAALAAECgQIBwAAAA==.',['后羿']='后羿射曰:BAAALAAECgYICAAAAA==.',['吼吼']='吼吼牛:BAAALAAECgYIDAAAAA==.',['吾心']='吾心即光明:BAAALAAECgYIBwAAAA==.',['呔丶']='呔丶那老贼:BAAALAAECgYIBgAAAA==.',['咒咒']='咒咒:BAABLAAFFH8HAAIHAAIIlhOJcQB9AAAHAAIIlhOJcQB9AAAAAA==.',['咸鱼']='咸鱼无妄:BAABLAAFFH8FAAIMAAIIbAQHHgApAAAMAAIIbAQHHgApAAAAAA==.',['啊闹']='啊闹之术:BAACLAAFFH8kAAIIAAUIPhgANABEAQAIAAUIPhgANABEAQAsAAQKfyEAAggABgjeIIMhAN4BAAgABgjeIIMhAN4BAAAA.',['啥都']='啥都可以:BAAALAADCgYIBgAAAA==.',['喜儿']='喜儿娃纳斯:BAAALAAECgYIEQAAAA==.',['喝奶']='喝奶:BAABLAAFFH8FAAIEAAMIowyXZgB8AAAEAAMIowyXZgB8AAAAAA==.',['喝酒']='喝酒吨吨:BAAALAAFFAIIAgAAAA==.',['喧嚣']='喧嚣的铁蹄:BAAALAADCgIIAgAAAA==.',['嗜血']='嗜血小磊:BAAALAAECgYIDwAAAA==.嗜血小马:BAAALAAECgYIEQAAAA==.嗜血德噜依:BAAALAAFFAIIAgAAAA==.嗜血蓝天:BAABLAAFFH8OAAIDAAIIdhNnRgBNAAADAAIIdhNnRgBNAAAAAA==.嗜血魔骑:BAABLAAFFH8GAAIEAAIINwM3owAyAAAEAAIINwM3owAyAAAAAA==.',['嚣张']='嚣张卝王爷:BAAALAAECgEIAQAAAA==.',['圣丶']='圣丶翊:BAAALAADCgUIBQAAAA==.',['型男']='型男:BAAALAAECgYICAAAAA==.',['墨柒']='墨柒:BAAALAAECgQIBAAAAA==.',['壹贰']='壹贰年十月:BAAALAADCgEIAQAAAA==.壹贰年除夕:BAAALAADCgMIAwAAAA==.',['夏以']='夏以昼:BAABLAAFFH8GAAIDAAYIWhrCCQD2AQADAAYIWhrCCQD2AQAAAA==.',['夏夜']='夏夜晚风:BAAALAAECggICAAAAA==.',['夜浮']='夜浮生若梦:BAAALAAFFAIIAgAAAA==.',['大黑']='大黑子:BAAALAAECgUIBQAAAA==.大黑牛丶:BAAALAADCgYIBgAAAA==.',['天丨']='天丨堂:BAABLAAFFH8TAAIGAAUIRSAxGwCBAQAGAAUIRSAxGwCBAQABLAAFFAYIIAAHAD4dAA==.',['天新']='天新老宝宝:BAABLAAFFH8iAAIEAAYI9hRILQCEAQAEAAYI9hRILQCEAQAAAA==.',['天晴']='天晴萌:BAAALAADCggIJAABLAAECgYIOAANADMgAA==.',['如烟']='如烟花般寂寞:BAAALAAECgYIDQAAAA==.',['妮可']='妮可利爪:BAAALAADCgIIAgAAAA==.',['妲己']='妲己爱你哟:BAAALAAECgYIBgAAAA==.',['妾妾']='妾妾私语:BAAALAAECggIAgAAAA==.',['定于']='定于壹尊:BAABLAAFFH8GAAICAAYIGA5YEQDbAQACAAYIGA5YEQDbAQAAAA==.',['宝宝']='宝宝嘟嘟打雷:BAACLAAFFH8WAAIIAAUIsxTdOAApAQAIAAUIsxTdOAApAQAsAAQKfyUAAggABgiwGplfANIBAAgABgiwGplfANIBAAAA.',['小咸']='小咸鱼的德:BAAALAAECggICwABLAAFFAIIAgAOAAAAAA==.',['小妈']='小妈上位:BAAALAADCgcICQAAAA==.',['小熊']='小熊:BAAALAAFFAIIAgAAAA==.',['小狐']='小狐狐:BAAALAAECgQIBAAAAA==.小狐狸真菜:BAAALAADCgYIBgAAAA==.',['小胖']='小胖巴:BAAALAAECgYICAAAAA==.',['小蒙']='小蒙奇:BAABLAAFFH8KAAINAAIIHhJkXABiAAANAAIIHhJkXABiAAAAAA==.',['小蹄']='小蹄子莉莉:BAAALAAFFAIIAgAAAA==.',['小飞']='小飞棍丶来咯:BAAALAAFFAIIAgAAAA==.',['岩石']='岩石驭兽者:BAAALAAECgYIDAAAAA==.',['巴恩']='巴恩:BAAALAAFFAIIBAAAAA==.',['布答']='布答:BAABLAAFFH8HAAIPAAIIHxWTEgBNAAAPAAIIHxWTEgBNAAAAAA==.',['帅萌']='帅萌:BAAALAADCgIIAgAAAA==.',['希尔']='希尔瓦娜飔:BAAALAADCgIIAgAAAA==.',['带我']='带我呼吸:BAAALAADCgIIAgAAAA==.',['影之']='影之风声:BAAALAADCgMIAwAAAA==.',['很乖']='很乖的牛:BAAALAAECgQIBAAAAA==.',['從前']='從前從前丶:BAABLAAFFH8HAAMQAAMITwjVIwBdAAADAAIIiwdWRACHAAAQAAMIFwfVIwBdAAAAAA==.',['御阪']='御阪美琴:BAAALAAFFAIIAgAAAA==.',['御风']='御风之弦:BAAALAAECgUIBQAAAA==.',['御驾']='御驾亲临:BAAALAADCgIIAgAAAA==.',['快交']='快交增值税:BAAALAAFFAIIAgAAAA==.',['恨无']='恨无悔:BAAALAAFFAIIAgAAAA==.',['恶魔']='恶魔霸主:BAAALAAECgcIDAAAAA==.',['悪魔']='悪魔猎狩:BAABLAAFFH8RAAIRAAQIcAxuCwCJAAARAAQIcAxuCwCJAAABLAAFFAYIHAAMALkWAA==.',['悲伤']='悲伤茶壶:BAAALAAFFAIIAgAAAA==.',['惠惠']='惠惠:BAAALAAECgYIBgAAAA==.',['惩戒']='惩戒天堂:BAABLAAECn8hAAIGAAYIFiMkJwD5AQAGAAYIFiMkJwD5AQAAAA==.',['想我']='想我没:BAAALAAFFAgIBAAAAA==.',['愤怒']='愤怒的豆汁丶:BAAALAADCgYIBwAAAA==.',['慣性']='慣性矩:BAABLAAFFH8JAAISAAMImQoGEgB8AAASAAMImQoGEgB8AAAAAA==.',['我就']='我就是牛插:BAACLAAFFH8oAAMHAAYIyh4PEACtAQAHAAYIyh4PEACtAQATAAIIFASsBgB6AAAsAAQKfxQABAcACAjAHol0APMBAAcABwgKIIl0APMBABMAAwgEH4sKAP0AABQAAwgNDoyfAHcAAAAA.',['我有']='我有一个角丶:BAAALAADCgYIBgAAAA==.',['我狂']='我狂卝我德:BAAALAAFFAIIBAAAAA==.',['战灵']='战灵儿:BAAALAAECgYIDwAAAA==.',['扶摇']='扶摇:BAABLAAFFH8QAAINAAYIFQ4wDQBsAQANAAYIFQ4wDQBsAQAAAA==.',['拉歌']='拉歌朗曰:BAABLAAFFH8PAAIIAAYIPAlVNwAxAQAIAAYIPAlVNwAxAQAAAA==.',['指引']='指引我的利刃:BAABLAAFFH8IAAIVAAII7wiOUwCJAAAVAAII7wiOUwCJAAAAAA==.',['挽星']='挽星河:BAABLAAFFH8KAAIQAAIIuQ24KgA6AAAQAAIIuQ24KgA6AAAAAA==.',['携醉']='携醉枕酒:BAABLAAFFH8HAAIIAAMIEg3aLADTAAAIAAMIEg3aLADTAAAAAA==.',['无敌']='无敌小宝:BAAALAAECgUIBQAAAA==.无敌小飞飞:BAABLAAFFH8PAAIEAAUIsQ5wQwAtAQAEAAUIsQ5wQwAtAQAAAA==.无敌小马:BAAALAAECgYIDwAAAA==.无敌骑神二柒:BAABLAAFFH8GAAIWAAYIdABbJQAMAAAWAAYIdABbJQAMAAAAAA==.',['明天']='明天更好:BAAALAAFFAIIAgAAAA==.',['是一']='是一个萨满:BAAALAAECggICAAAAA==.',['暗流']='暗流:BAAALAAECgQIAgAAAA==.',['暗黑']='暗黑奥本海默:BAAALAAECgUIBQAAAA==.',['暴躁']='暴躁的阿呆:BAABLAAECn8VAAMCAAgIHBtiVAAHAgACAAgIHBtiVAAHAgABAAYIYgzwWAASAQAAAA==.',['最亮']='最亮的星:BAAALAAECgIIAgAAAA==.',['最好']='最好是晴天:BAAALAAECgMIBQAAAA==.',['月下']='月下灬诱人:BAAALAAFFAIIBAAAAA==.',['月华']='月华:BAAALAAECgcIBwAAAA==.',['月影']='月影织韵丶:BAABLAAFFH8GAAINAAYI0w4pJQA3AQANAAYI0w4pJQA3AQAAAA==.',['未夏']='未夏士:BAABLAAFFH8GAAIXAAQIRgo3IQB9AAAXAAQIRgo3IQB9AAAAAA==.',['机械']='机械克制自然:BAAALAAFFAQIBAAAAA==.',['杏花']='杏花:BAAALAAECgYIDAAAAA==.',['来自']='来自怀旧服:BAAALAAECgYIBgAAAA==.',['杯具']='杯具和洗具:BAAALAAFFAIIAgAAAA==.',['枪打']='枪打出头鸟:BAAALAAFFAIIAwAAAA==.',['梅叶']='梅叶彼德:BAABLAAFFH8GAAIYAAIIaRHjBABLAAAYAAIIaRHjBABLAAAAAA==.',['梦乂']='梦乂魇:BAAALAAECgcICwAAAA==.',['梦回']='梦回绿野:BAAALAAECgUIBQAAAA==.',['楠桦']='楠桦:BAAALAAECgIIAgAAAA==.',['槑神']='槑神龙大侠槑:BAAALAAFFAIIAgAAAA==.',['橙时']='橙时:BAABLAAFFH8OAAINAAIIaRuTQwCbAAANAAIIaRuTQwCbAAAAAA==.',['欢乐']='欢乐正前方:BAAALAAECgYIBgAAAA==.',['欧皇']='欧皇僧七:BAACLAAFFH8hAAIZAAgIUA6JCACbAQAZAAgIUA6JCACbAQAsAAQKfxUAAxkACAjcGSIKAB0CABkACAjcGSIKAB0CABIABQhTEZ8gAPUAAAAA.',['正义']='正义的小锤子:BAABLAAFFH8IAAIGAAIIPwp9dwA5AAAGAAIIPwp9dwA5AAAAAA==.',['武動']='武動乾坤:BAAALAAECgQIBQAAAA==.',['武卫']='武卫将军:BAABLAAFFH8IAAINAAIIjg+TYABbAAANAAIIjg+TYABbAAAAAA==.',['死后']='死后必定长眠:BAAALAAECgYIBgAAAA==.',['水晶']='水晶:BAABLAAFFH8GAAIaAAIIphgdGQCZAAAaAAIIphgdGQCZAAAAAA==.',['氺火']='氺火:BAABLAAFFH8GAAIGAAIIbhLcZQBDAAAGAAIIbhLcZQBDAAAAAA==.',['氺蕾']='氺蕾:BAABLAAFFH8GAAIHAAIICBHRmgBAAAAHAAIICBHRmgBAAAAAAA==.',['没踪']='没踪玫瑰刀:BAAALAADCggICAAAAA==.',['沸腾']='沸腾茶壶:BAAALAADCgMIAwAAAA==.',['泡泡']='泡泡无奈:BAABLAAFFH8GAAIIAAUIWA8MQgDdAAAIAAUIWA8MQgDdAAAAAA==.泡泡龙雷:BAABLAAFFH8MAAIIAAYI3RE0LQBlAQAIAAYI3RE0LQBlAQAAAA==.',['浪漫']='浪漫的小说:BAAALAAECgcIBwAAAA==.',['海阁']='海阁力斯:BAAALAAECgIIAgAAAA==.',['消失']='消失了:BAAALAAECgQIBAAAAA==.',['混沌']='混沌:BAAALAAECgMIAwAAAA==.',['清水']='清水樱桃:BAAALAAECgYICwAAAA==.',['溪子']='溪子山丶:BAABLAAECn8fAAMHAAgIlBnHUAA9AgAHAAgIlBnHUAA9AgAUAAYIWQ14bgAQAQAAAA==.',['灿烂']='灿烂如华年:BAAALAAECgYIBgAAAA==.',['烈烈']='烈烈:BAABLAAFFH8FAAIUAAMI1RMOEAB7AAAUAAMI1RMOEAB7AAAAAA==.',['爬墙']='爬墙头等红杏:BAABLAAECn8aAAIGAAYIuCF3VQBCAgAGAAYIuCF3VQBCAgAAAA==.',['爱亦']='爱亦随风起:BAAALAAECgcIDQAAAA==.',['狂風']='狂風:BAAALAADCgYIBgAAAA==.',['猎蜂']='猎蜂:BAAALAAECgIIAQAAAA==.',['玛卡']='玛卡:BAAALAAECgUIBwAAAA==.',['玛格']='玛格丽:BAAALAADCgEIAQAAAA==.',['瑞查']='瑞查儿:BAAALAAECgMIAwABLAAFFAgIGQALAHgiAA==.',['生前']='生前何必贪睡:BAAALAAECgYIBgAAAA==.',['白毛']='白毛向天歌:BAAALAAECgYIDAAAAA==.',['皮斯']='皮斯科丶:BAABLAAFFH8JAAIbAAgI6R+mAADqAgAbAAgI6R+mAADqAgAAAA==.',['皮蛋']='皮蛋子:BAAALAAECgYICQAAAA==.',['皿众']='皿众何:BAAALAAECgUIBQAAAA==.',['看我']='看我眼色行事:BAAALAAFFAQIAgAAAA==.',['瞬间']='瞬间移动:BAAALAAECgUIBQAAAA==.',['知道']='知道啦明天见:BAABLAAECn8ZAAMVAAYIvw+5XwAAAQAVAAYIig+5XwAAAQARAAYIpgYCIQCTAAAAAA==.',['石页']='石页:BAAALAAECgEIAQAAAA==.',['碧火']='碧火蓝天:BAABLAAFFH8IAAILAAIIQwqUUgBPAAALAAIIQwqUUgBPAAAAAA==.',['第五']='第五形态:BAAALAAECgYIDwAAAA==.',['米虫']='米虫豆:BAAALAAFFAIIBAAAAA==.',['精灵']='精灵皇后:BAAALAAECgMIAwAAAA==.',['素还']='素还真:BAAALAAECgYIDAAAAA==.',['紫盒']='紫盒子:BAABLAAECn8dAAMHAAgIwB6eGwBWAgAHAAgIwB6eGwBWAgAUAAYIEBNSXgBDAQAAAA==.',['紫露']='紫露凝香:BAAALAAECgMIAwAAAA==.',['红毛']='红毛小宇宙:BAAALAAECgYIBwAAAA==.',['纯为']='纯为了耍酷:BAAALAAECgYIBgAAAA==.',['羿杉']='羿杉:BAAALAADCgMIAwAAAA==.',['老公']='老公说我胖了:BAAALAAFFAIIAgAAAA==.',['老实']='老实人:BAAALAAECggICAAAAA==.',['聆梵']='聆梵音:BAAALAADCggICAAAAA==.',['职业']='职业道德:BAAALAAECgIIAgAAAA==.',['肉球']='肉球儿:BAAALAAECgYIBgAAAA==.',['脸帝']='脸帝:BAAALAAECgYIDAAAAA==.',['自豪']='自豪:BAAALAAFFAIIAgAAAA==.',['臭宝']='臭宝菇:BAAALAAFFAMIAwAAAA==.',['花倾']='花倾城:BAAALAAECgMIAwAAAA==.',['花枪']='花枪:BAACLAAFFH8JAAILAAYIFwcYLgCzAAALAAYIFwcYLgCzAAAsAAQKfxwAAgsACAhkHYo9AOkBAAsACAhkHYo9AOkBAAEsAAUUCAgCAA4AAAAA.',['花里']='花里胡哨:BAAALAAECgcICwAAAA==.',['芳凝']='芳凝:BAAALAAECgYIDAAAAA==.',['芳菲']='芳菲:BAAALAADCgIIAgAAAA==.',['苍麻']='苍麻叶:BAAALAADCgIIAgAAAA==.',['英勇']='英勇:BAAALAAECgMIAwAAAA==.英勇胜利:BAAALAAECgIIAgAAAA==.',['莱因']='莱因哈特:BAAALAAFFAIIAgAAAA==.',['莽夫']='莽夫:BAAALAADCgYIBgAAAA==.',['萨南']='萨南瓜:BAAALAAECgIIAgAAAA==.',['落叶']='落叶归根:BAAALAADCgIIAgAAAA==.',['虎皮']='虎皮猫大人:BAAALAAECgYICQAAAA==.',['蛮萨']='蛮萨大狐狸:BAAALAAECgYIBgAAAA==.',['蝶舞']='蝶舞梦回:BAAALAAECgcIDwAAAA==.',['血指']='血指甲:BAAALAAECgYICAAAAA==.',['血狱']='血狱妖莲:BAAALAAECggICAAAAA==.',['血霸']='血霸王:BAAALAAECgYICQAAAA==.',['西门']='西门小官人:BAABLAAFFH8cAAIMAAYIuRaWCgBpAQAMAAYIuRaWCgBpAQAAAA==.',['见面']='见面曾相识:BAAALAAECgEIAQAAAA==.',['記仇']='記仇小本本:BAABLAAFFH8GAAIcAAIIJQgyOgCAAAAcAAIIJQgyOgCAAAAAAA==.',['誓约']='誓约胜利之剑:BAABLAAFFH8HAAMMAAMIpAVAFwBPAAAMAAMIwQNAFwBPAAAEAAII8QW/mgA5AAAAAA==.',['诺恩']='诺恩吉雅:BAAALAAECgYIBgAAAA==.',['谷雨']='谷雨春深:BAAALAAFFAIIAgAAAA==.',['豆腐']='豆腐加辣:BAAALAAECgEIAQAAAA==.',['賽先']='賽先僧:BAABLAAFFH8MAAMXAAIIjBGnIwCEAAAXAAIIjBGnIwCEAAAcAAIIRwzPPgBsAAAAAA==.',['贝贝']='贝贝呗极星:BAAALAAFFAIIAgAAAA==.',['超人']='超人不会飞:BAABLAAECn8UAAIEAAYIOQdmiQDXAAAEAAYIOQdmiQDXAAAAAA==.',['超级']='超级下头男:BAAALAAECgMIAwAAAA==.',['轩辕']='轩辕右手:BAAALAAECgQIBAAAAA==.',['迷人']='迷人牛大侠:BAAALAAECgUICgAAAA==.',['逆阳']='逆阳神:BAAALAAFFAIIAgAAAA==.',['逍遥']='逍遥之剑:BAAALAAFFAIIAgABLAAFFAMIBwAIABINAA==.逍遥自得:BAABLAAFFH8GAAIQAAIIUgt2NQAsAAAQAAIIUgt2NQAsAAABLAAFFAMIBwAIABINAA==.',['遠坂']='遠坂丶凛:BAAALAAECgMIAwAAAA==.',['邋里']='邋里邋遢丶:BAAALAAECgEIAQAAAA==.',['邦辛']='邦辛迪:BAABLAAFFH8GAAIHAAYIPwUkWwDaAAAHAAYIPwUkWwDaAAAAAA==.',['邪恶']='邪恶冰霜:BAAALAAECgQIBAAAAA==.',['邪灵']='邪灵之翼:BAAALAADCgYIBgAAAA==.',['酸菜']='酸菜豆花:BAABLAAFFH8NAAINAAYIWCLgBgBTAgANAAYIWCLgBgBTAgAAAA==.',['重合']='重合成功:BAABLAAFFH8GAAMRAAIIXg1YFwAnAAARAAIIXg1YFwAnAAAVAAEI/gEvdAAAAAABLAAFFAMIBwAIABINAA==.',['金箭']='金箭雕翎:BAABLAAFFH8LAAIHAAcItwCrwgAXAAAHAAcItwCrwgAXAAAAAA==.',['铭琴']='铭琴:BAAALAAECgIIAgAAAA==.',['阝湮']='阝湮灭:BAAALAAECgUIBQAAAA==.',['阿卓']='阿卓也疯狂:BAAALAAECgQIBAAAAA==.',['阿巴']='阿巴丷:BAABLAAFFH8gAAICAAgInyBVBACqAgACAAgInyBVBACqAgAAAA==.',['阿扬']='阿扬教授:BAAALAADCgEIAQAAAA==.',['阿里']='阿里路亚:BAAALAAECgMIAwAAAA==.',['雪朵']='雪朵朵:BAAALAAECgUIBQAAAA==.',['雪雪']='雪雪儿:BAAALAAECgEIAQAAAA==.',['霸氣']='霸氣四射:BAAALAAFFAMIAwAAAA==.',['非主']='非主流大爷:BAAALAAECgYIEAAAAA==.',['风暴']='风暴小德:BAAALAAFFAIIAgAAAA==.',['风月']='风月宝鉴:BAAALAAECgcIBwAAAA==.',['飘云']='飘云卝意如:BAAALAAFFAIIAgAAAA==.',['香槟']='香槟拉菲:BAABLAAFFH8GAAIdAAIIOgcsIgAsAAAdAAIIOgcsIgAsAAABLAAFFAMIBwAIABINAA==.',['骑手']='骑手战鹰:BAAALAAECgMIAwAAAA==.',['鬼吻']='鬼吻:BAAALAAECgEIAQAAAA==.',['鲜鲜']='鲜鲜:BAABLAAFFH8FAAMaAAIIEgFpLgBFAAAaAAIIEgFpLgBFAAAWAAII9QETJAAgAAAAAA==.',['黑骑']='黑骑:BAABLAAFFH8GAAIEAAII+BxiWQCbAAAEAAII+BxiWQCbAAABLAAFFAcIMgAIAGQiAA==.',['齊天']='齊天大圣:BAAALAAECggICAAAAA==.',['龙咚']='龙咚呛:BAAALAAFFAIIBAABLAAFFAMIBwAIABINAA==.',['龙妈']='龙妈:BAAALAAECgMIAwAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end