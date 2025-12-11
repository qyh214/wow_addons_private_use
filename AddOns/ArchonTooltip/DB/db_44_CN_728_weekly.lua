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
 local lookup = {'Warlock-Destruction','Warlock-Affliction','DemonHunter-Havoc','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','Mage-Arcane','Rogue-Assassination','Hunter-Survival','Evoker-Augmentation','Priest-Holy','Priest-Shadow','Warlock-Demonology','Evoker-Devastation','Paladin-Retribution','Paladin-Protection','Unknown-Unknown','Warrior-Fury','Warrior-Protection','Druid-Restoration','Evoker-Preservation','Paladin-Holy','Monk-Mistweaver','Shaman-Restoration','Shaman-Elemental','DeathKnight-Frost','Monk-Brewmaster',}; local provider = {region='CN',realm='泰拉尔',name='CN',type='weekly',zone=44,date='2025-12-06',data={Bl='Bloodivan:BAAALAADCgIIAgAAAA==.',Ec='Ecid:BAACLAAFFH8PAAIBAAMIKRxsIgALAQABAAMIKRxsIgALAQAsAAQKfxQAAwEABggfI0g9AEUCAAEABggfI0g9AEUCAAIAAQgtFpE8AEIAAAAA.',Fa='Fantast:BAAALAAECgQIBAAAAA==.',He='Herp:BAAALAAECgYIDgAAAA==.',Ma='Mafiadoudou:BAACLAAFFH8LAAIDAAMIjRPAPQCWAAADAAMIjRPAPQCWAAAsAAQKfxYAAgMABgjlIO8iANUBAAMABgjlIO8iANUBAAAA.',Mo='Moondeity:BAAALAAECgYIBgAAAA==.',No='Nopeace:BAAALAAECgcICAAAAA==.',Ot='Otto:BAACLAAFFH8MAAMEAAIIghplHwCLAAAEAAIIJhZlHwCLAAAFAAII+hRvnAA/AAAsAAQKfx8AAgQABwi0H4cdAHkCAAQABwi0H4cdAHkCAAAA.',Re='Rem:BAACLAAFFH8XAAIGAAMI0RHWDACKAAAGAAMI0RHWDACKAAAsAAQKfycAAwYACAjTGocmAPIBAAYACAjTGocmAPIBAAcABAjvCxrRAMEAAAAA.',Sa='Satella:BAAALAAECgYIBgAAAA==.',Xi='Xiongdiwhl:BAAALAADCgYICgAAAA==.',['一身']='一身正气:BAAALAAECgYICgAAAA==.',['三井']='三井血受:BAAALAAECgUIBQAAAA==.',['上河']='上河图:BAAALAAFFAIIAgAAAA==.',['不死']='不死贫道:BAAALAADCgYIBgAAAA==.',['丝丝']='丝丝暧昧丶:BAAALAAFFAIIBAAAAA==.',['丨上']='丨上帝武装丨:BAAALAADCgEIAQAAAA==.',['丨会']='丨会长丨:BAAALAADCgUIBQAAAA==.',['丨堂']='丨堂前燕丶:BAAALAAECggICAAAAA==.',['丰满']='丰满的夏莎:BAAALAADCgIIAgAAAA==.',['丹丹']='丹丹熊:BAABLAAFFH8SAAIIAAQI0gwtEgDdAAAIAAQI0gwtEgDdAAAAAA==.',['为了']='为了糖果:BAAALAAECgYIBgAAAA==.',['为努']='为努力一爱:BAAALAAECgMIAwAAAA==.',['丿大']='丿大萝卜丶:BAAALAAFFAEIAQAAAA==.',['井荷']='井荷花:BAACLAAFFH8IAAIHAAII0RweRACcAAAHAAII0RweRACcAAAsAAQKfxQAAgcABwiDH1xJACoCAAcABwiDH1xJACoCAAAA.',['仓仓']='仓仓:BAAALAADCgMIAwAAAA==.',['仴橆']='仴橆靈殇:BAABLAAECn8YAAMFAAcIORuEZwBzAQAJAAYIzxV6EQCSAQAFAAcIsRmEZwBzAQABLAAFFAgIDgAKACgXAA==.',['会飞']='会飞的恶魔:BAAALAAECgYICQAAAA==.',['伤恨']='伤恨寒冰枪:BAAALAAFFAIIAgAAAA==.',['佐佐']='佐佐木绯世:BAAALAAFFAIIAgAAAA==.',['你就']='你就是块木头:BAACLAAFFH8cAAILAAYIyRZREwC+AQALAAYIyRZREwC+AQAsAAQKfxUAAwwABwgTEmBYAFUBAAwABwgTEmBYAFUBAAsABwg8DGh2ABkBAAAA.',['依法']='依法治骑:BAAALAAECgEIAQAAAA==.',['依然']='依然九月:BAAALAADCggICAAAAA==.',['倚楼']='倚楼聼风雨:BAAALAAECgUIBwAAAA==.',['傲娇']='傲娇娇:BAAALAAFFAIIBAAAAA==.',['兵临']='兵临城下:BAAALAADCgYICQAAAA==.',['冰火']='冰火震天:BAAALAAECgUIBQAAAA==.',['劲酒']='劲酒越喝越有:BAABLAAECn8XAAIHAAYIsRZgiwB3AQAHAAYIsRZgiwB3AQAAAA==.',['十字']='十字勋章:BAAALAADCgUIBgAAAA==.',['半死']='半死不活:BAAALAAECgUICgAAAA==.',['可口']='可口可乐加冰:BAAALAAFFAIIBAAAAA==.',['可爱']='可爱的熊熊:BAABLAAFFH8WAAMFAAUIDA55YAC8AAAFAAQItAx5YAC8AAAEAAQIXAmaEABzAAAAAA==.',['右手']='右手很酸痛丶:BAAALAAECggICwAAAA==.',['君临']='君临天下:BAAALAAECgQIBAAAAA==.',['吟灬']='吟灬灰狼:BAAALAAECgIIAgAAAA==.',['吾之']='吾之右手:BAAALAAECgUIBQAAAA==.',['咖啡']='咖啡丨因:BAAALAAECgYIBwAAAA==.',['哈姆']='哈姆灰太狼:BAAALAAFFAIIBAAAAA==.',['哈尼']='哈尼小宝:BAAALAAECgYIBgAAAA==.',['哔哩']='哔哩哔哩嘣:BAAALAAECgYICgAAAA==.',['四根']='四根棍一条链:BAAALAADCgYIBgAAAA==.',['围攻']='围攻伯拉勒斯:BAACLAAFFH8XAAIBAAMIEBUvSACdAAABAAMIEBUvSACdAAAsAAQKfyQAAwEACAiLFX52AJYBAAEACAiLFX52AJYBAA0AAQgvE9GQAEYAAAAA.',['圣光']='圣光救赎:BAAALAADCgIIAgAAAA==.圣光照耀:BAAALAAECgYIEQAAAA==.',['增强']='增强辉:BAABLAAFFH8GAAIOAAIIeQ3OGgCJAAAOAAIIeQ3OGgCJAAAAAA==.',['壁谷']='壁谷非常痒:BAAALAAFFAIIAwAAAA==.',['多鸠']='多鸠鱼:BAACLAAFFH8VAAIFAAMI8RENbwCDAAAFAAMI8RENbwCDAAAsAAQKfxwAAgUACAjOFnmsAJoBAAUACAjOFnmsAJoBAAAA.',['夜丶']='夜丶风:BAABLAAECn8WAAMPAAYIeCI0ZAAiAgAPAAYIeCI0ZAAiAgAQAAEIsR7mbQBUAAAAAA==.',['夜风']='夜风的爱:BAAALAADCgQIBAAAAA==.',['大丰']='大丰徐欠:BAAALAAECgQIBAAAAA==.',['大力']='大力豹:BAAALAAECgcIEgAAAA==.大力龙:BAAALAAECgYICAAAAA==.',['天热']='天热开冰箱:BAAALAAFFAIIBAAAAA==.',['奇袭']='奇袭之舞:BAABLAAFFH8GAAIIAAYIWhv0CACIAQAIAAYIWhv0CACIAQAAAA==.',['奈莉']='奈莉莎:BAAALAAECgQIDAABLAAECgYICQARAAAAAA==.',['契约']='契约之瞳:BAACLAAFFH8UAAISAAMIAxecNQCcAAASAAMIAxecNQCcAAAsAAQKfywAAxIACAgxGuAVADICABIACAgxGuAVADICABMABgg5CLhoAOgAAAAA.',['奥林']='奥林花园:BAAALAAECgIIAgAAAA==.',['奶油']='奶油派宝子:BAAALAAECgYIDQAAAA==.奶油派宝贝:BAAALAAECgYICAAAAA==.',['宁静']='宁静祥和:BAAALAADCgEIAQAAAA==.',['安娜']='安娜贝尔:BAACLAAFFH8GAAIUAAIIcxPCQQBtAAAUAAIIcxPCQQBtAAAsAAQKfxQAAhQABwiuHUISAEQCABQABwiuHUISAEQCAAAA.',['安度']='安度因:BAAALAAECgcIBwAAAA==.',['实现']='实现共同富裕:BAAALAAECgYIDAAAAA==.',['小八']='小八儿:BAAALAAECgYIBgAAAA==.',['小白']='小白猫猫:BAAALAADCgIIAgAAAA==.',['小石']='小石头:BAAALAADCgIIAgAAAA==.',['小蝌']='小蝌蚪找媽媽:BAAALAADCgQIBAAAAA==.',['就一']='就一箭丶:BAAALAAECgYICQAAAA==.',['幻雪']='幻雪蓝冰:BAABLAAFFH8MAAIPAAIIkBQvPgCfAAAPAAIIkBQvPgCfAAAAAA==.',['弋弌']='弋弌弍弎丶:BAACLAAFFH8XAAIPAAMIahO9PwCVAAAPAAMIahO9PwCVAAAsAAQKfyAAAg8ACAgUFzw5ALIBAA8ACAgUFzw5ALIBAAAA.',['弓喜']='弓喜发财:BAAALAAECgYIBgAAAA==.',['弥撒']='弥撒之音:BAAALAAECgYIBgAAAA==.',['影之']='影之潮汐:BAACLAAFFH8NAAIBAAMIdhlwMAC5AAABAAMIdhlwMAC5AAAsAAQKfx4ABAEABwi4IyYkALgCAAEABwg3IiYkALgCAA0AAwgCIohVACABAAIAAQi2InIzAGUAAAAA.',['影歌']='影歌之月:BAACLAAFFH8iAAIDAAUITx7RDQDLAQADAAUITx7RDQDLAQAsAAQKfyMAAgMACAjSIskfAOQCAAMACAjSIskfAOQCAAAA.',['彼岸']='彼岸的圣光:BAAALAAECgYICAAAAA==.',['征讨']='征讨者夏娜:BAAALAAECgYIDAAAAA==.',['很给']='很给力:BAAALAAECgYIBwAAAA==.',['心中']='心中的恶魔:BAAALAADCgIIAgAAAA==.',['恐虐']='恐虐神选:BAAALAAECgYICAAAAA==.',['惩你']='惩你戒色骑我:BAAALAADCgMIAwAAAA==.',['惩戒']='惩戒之舞:BAABLAAFFH8GAAIPAAYI1BP9BQAHAgAPAAYI1BP9BQAHAgAAAA==.',['想想']='想想大魔王:BAABLAAFFH8lAAIVAAYIFhwTBgCbAQAVAAYIFhwTBgCbAQAAAA==.',['我选']='我选择死亡:BAAALAAECgYIDAAAAA==.',['拯救']='拯救逗比专员:BAAALAADCgEIAQAAAA==.',['挚嗳']='挚嗳白洁:BAAALAAECgYICQAAAA==.',['撕皮']='撕皮儿剥壳:BAAALAAECgYIBwAAAA==.',['救赎']='救赎之路:BAAALAADCggIDwAAAA==.',['旗仕']='旗仕:BAAALAAECgMIBAAAAA==.',['无粟']='无粟之树:BAAALAAECgYIBgAAAA==.',['明月']='明月重现:BAAALAAFFAIIAwAAAA==.',['是辣']='是辣条的爸爸:BAABLAAFFH8KAAIPAAIIsARUfAA0AAAPAAIIsARUfAA0AAAAAA==.',['暗杀']='暗杀星:BAAALAAECggICAAAAA==.',['更晚']='更晚打老虎:BAAALAAECgYIEgAAAA==.',['月落']='月落尘灬埃:BAABLAAECn8XAAIDAAYIqhl2fQDKAQADAAYIqhl2fQDKAQAAAA==.月落灬星辰:BAAALAAECgYIBgAAAA==.',['核弹']='核弹:BAAALAAFFAIIAwAAAA==.',['楚恋']='楚恋流云:BAAALAAECgYIEwABLAAFFAYIBgAWAAEOAA==.',['正义']='正义市民小马:BAABLAAECn8eAAMFAAYI9BxJigDNAQAFAAYI0RxJigDNAQAEAAYIfRVBUgBtAQAAAA==.',['沐烨']='沐烨:BAAALAAECgEIAQAAAA==.',['泱视']='泱视第一套:BAAALAADCgEIAQAAAA==.',['流年']='流年:BAAALAADCgMIAwAAAA==.',['浩劫']='浩劫之舞:BAABLAAFFH8IAAIDAAgIQhMGCwAWAgADAAgIQhMGCwAWAgAAAA==.',['浪荡']='浪荡德小驴:BAAALAAECgMIAwAAAA==.',['海棠']='海棠朵朵:BAAALAADCgYIBgAAAA==.',['海盗']='海盗帆:BAAALAAECgUIBQAAAA==.海盗猎手:BAAALAAECgYIBgAAAA==.',['消失']='消失的叶子:BAACLAAFFH8IAAIXAAIIFxFlEQCLAAAXAAIIFxFlEQCLAAAsAAQKfx0AAhcABwjZGTwWABoCABcABwjZGTwWABoCAAAA.',['深度']='深度莫愁:BAAALAADCgMIAwAAAA==.',['湮灭']='湮灭之舞:BAABLAAFFH8OAAMKAAgIKBfbAQBTAgAKAAgIKBfbAQBTAgAVAAYI8BfsAwDjAQAAAA==.',['滚石']='滚石不生苔:BAACLAAFFH8UAAMYAAMIjBn0MQDiAAAYAAMIjBn0MQDiAAAZAAIIdAL9OABsAAAsAAQKfy8AAxgACAh1GLdkAL0BABgACAh1GLdkAL0BABkAAwjcC6qsAKcAAAAA.',['火星']='火星有雨:BAAALAAECgUIBgAAAA==.',['火焰']='火焰之舞:BAABLAAFFH8HAAIHAAcIkhV2FADYAQAHAAcIkhV2FADYAQAAAA==.',['火舞']='火舞凌风:BAABLAAECn8mAAMGAAgINh3pEACfAgAGAAgINh3pEACfAgAHAAgI2g74cQC1AQAAAA==.',['灬丶']='灬丶荭颜:BAACLAAFFH8fAAIaAAYIbh8aHADFAQAaAAYIbh8aHADFAQAsAAQKfxQAAhoABgjAIpMuALsBABoABgjAIpMuALsBAAAA.',['灬天']='灬天罚灬:BAAALAAECgMIAwAAAA==.',['灬遇']='灬遇术临疯灬:BAABLAAECn8VAAMNAAYICiL5GAAxAgANAAYIlyD5GAAxAgABAAMIRBchyADaAAAAAA==.',['燃烧']='燃烧的火鸟:BAAALAAECgUIBQAAAA==.',['狂刀']='狂刀血斧:BAAALAAECgYICgAAAA==.',['瑶光']='瑶光贯月:BAAALAAECgYIBgAAAA==.',['男丶']='男丶德:BAAALAADCggICAAAAA==.',['皮固']='皮固非常养:BAABLAAECn8XAAMHAAgIzx7iSgAlAgAHAAgIBx3iSgAlAgAGAAYIfR06MAC6AQAAAA==.',['盾入']='盾入空门:BAAALAAFFAIIAgAAAA==.',['瞬间']='瞬间即逝:BAABLAAFFH8MAAIHAAIIJSVbLQDcAAAHAAIIJSVbLQDcAAAAAA==.',['穿云']='穿云箭:BAAALAADCgIIAgAAAA==.',['笛声']='笛声:BAAALAADCgMIAwAAAA==.',['糖豆']='糖豆儿豆儿:BAAALAADCgQIBAAAAA==.',['给次']='给次机会:BAAALAAECggIBwAAAA==.',['维罗']='维罗娜拉:BAAALAAECgcIDAAAAA==.',['编织']='编织氵谎言:BAAALAADCgIIAgAAAA==.',['罗斯']='罗斯:BAAALAADCgUIBQAAAA==.',['美好']='美好的遇见:BAABLAAFFH8RAAIWAAgIpxa/BABYAgAWAAgIpxa/BABYAgAAAA==.',['美式']='美式加冰:BAAALAAECgYICQAAAA==.',['翠花']='翠花:BAAALAAECgYICgAAAA==.',['老王']='老王:BAAALAAECgcIBwAAAA==.',['老胡']='老胡:BAABLAAFFH8GAAIDAAYI5BXYHwCCAQADAAYI5BXYHwCCAQAAAA==.老胡丨:BAAALAAECgEIAQAAAA==.',['胆大']='胆大囸刺猬:BAAALAAECgMIAwAAAA==.胆大日刺猬:BAAALAAECgYIBgAAAA==.',['若晴']='若晴:BAAALAAECgYIBgAAAA==.',['英雄']='英雄就站光里:BAAALAAFFAIIAgAAAA==.',['荒野']='荒野游侠:BAAALAADCgYIBgAAAA==.',['荷花']='荷花:BAAALAAECgUIBwAAAA==.',['萝莉']='萝莉么么哒:BAAALAAECgEIAQAAAA==.',['萨比']='萨比:BAABLAAFFH8xAAMZAAYI4hO0IQA0AQAZAAUIGBS0IQA0AQAYAAUIhhPYIgDEAAAAAA==.',['蕾蕾']='蕾蕾的玩具:BAAALAAECgUIBQAAAA==.',['被腐']='被腐化的高远:BAAALAAECggIBgAAAA==.',['装备']='装备评分:BAACLAAFFH8zAAIUAAcImBl1CQAWAgAUAAcImBl1CQAWAgAsAAQKfygAAhQACAgLHCApAEACABQACAgLHCApAEACAAAA.',['西球']='西球起丶:BAAALAAFFAIIAgAAAA==.',['路上']='路上有惊慌:BAAALAAECgMIAwAAAA==.',['路过']='路过飘过的猫:BAAALAAFFAIIAgAAAA==.',['邢亥']='邢亥:BAAALAAECgEIAQAAAA==.',['那時']='那時婲开:BAAALAAFFAIIAwAAAA==.',['邪恶']='邪恶的猫咪:BAAALAADCgYIBgAAAA==.',['酒仙']='酒仙之舞:BAABLAAFFH8IAAIbAAgIdRmXBwDWAQAbAAgIdRmXBwDWAQAAAA==.',['闪光']='闪光的岁月:BAAALAAECgYIDAAAAA==.',['阿克']='阿克闷德:BAAALAAFFAIIAgAAAA==.',['阿尔']='阿尔撒斯之心:BAAALAADCggIDAABLAAFFAgICgASAKoiAA==.',['阿迪']='阿迪:BAAALAAECgEIAQAAAA==.',['雁飞']='雁飞残月天:BAABLAAFFH8KAAIYAAIIoBZ+SQCKAAAYAAIIoBZ+SQCKAAAAAA==.',['雅秘']='雅秘海:BAAALAAECgIIAgAAAA==.',['雨夜']='雨夜孤魂:BAAALAAECgYIBgAAAA==.',['雪上']='雪上加霜:BAAALAADCgUIBQAAAA==.',['雾轨']='雾轨银芒:BAAALAAECgIIAgAAAA==.',['霜之']='霜之小唯:BAAALAAECgYIBgAAAA==.霜之瑞希:BAAALAAECgYIBgAAAA==.',['青春']='青春已逝:BAAALAADCgYIBgAAAA==.',['青阑']='青阑:BAAALAAECgYIDAAAAA==.',['风流']='风流一小德:BAAALAAECgIIAgAAAA==.',['飞碟']='飞碟双向:BAAALAAECgEIAQAAAA==.',['馨子']='馨子的宝宝:BAAALAAECgQIBAAAAA==.',['鬼冢']='鬼冢英吉:BAAALAAECgcIDgAAAA==.',['鲜血']='鲜血之舞:BAABLAAFFH8IAAIaAAgIPxzGCABtAgAaAAgIPxzGCABtAgAAAA==.',['龍葵']='龍葵:BAAALAAECggICAAAAA==.',['龙城']='龙城丶:BAAALAAFFAMIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end