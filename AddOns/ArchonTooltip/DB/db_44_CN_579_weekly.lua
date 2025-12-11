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
 local lookup = {'Druid-Restoration','Priest-Holy','Priest-Shadow','Druid-Balance','Paladin-Holy','Paladin-Retribution','DemonHunter-Havoc','DeathKnight-Frost','Shaman-Elemental','DeathKnight-Unholy','Hunter-BeastMastery','Mage-Arcane','Unknown-Unknown','Shaman-Restoration','DeathKnight-Blood','Warlock-Destruction','Warlock-Demonology','DemonHunter-Vengeance','Mage-Frost','Paladin-Protection','Warrior-Protection','Monk-Brewmaster','Priest-Discipline','Hunter-Marksmanship','Monk-Windwalker','Druid-Guardian','Monk-Mistweaver','Evoker-Devastation','Evoker-Preservation','Rogue-Outlaw','Rogue-Assassination','Warrior-Fury','Druid-Feral','Warlock-Affliction','Hunter-Survival','Mage-Fire',}; local provider = {region='CN',realm='冬拥湖',name='CN',type='weekly',zone=44,date='2025-12-06',data={Ak='Akaziki:BAAALAAECgcIBwAAAA==.Akazikic:BAAALAAFFAIIAgAAAA==.Akazikim:BAAALAAECgYIBgAAAA==.Akazikis:BAAALAAECgEIAQAAAA==.',Am='Ammo:BAAALAAECgIIAgAAAA==.',An='Anonymous:BAABLAAFFH8GAAIBAAYIOhAGGgBdAQABAAYIOhAGGgBdAQAAAA==.',Ar='Arteezy:BAAALAAECgYIEQAAAA==.',Ba='Bababala:BAAALAAECgEIAQAAAA==.Ballala:BAAALAAECgYICgAAAA==.',Bi='Bizkitt:BAAALAAECgYIBwAAAA==.',Br='Bringshadow:BAABLAAECn8XAAMCAAYIJQ2+cwAhAQACAAYIJQ2+cwAhAQADAAQIDgvbOgCPAAAAAA==.',Da='Davids:BAAALAAECgUIBQAAAA==.',Db='Dbdxdry:BAABLAAFFH8HAAMBAAUILBycKADSAAABAAMIIBicKADSAAAEAAQIzgSeIgCcAAAAAA==.Dbdxsqs:BAABLAAFFH8XAAMFAAYIuxtbEQBxAQAFAAUIfxlbEQBxAQAGAAUIagxKNQDXAAAAAA==.',De='Devilocry:BAABLAAFFH8XAAIHAAYIShfRHgCHAQAHAAYIShfRHgCHAQAAAA==.',El='Elakarina:BAAALAAECggICAAAAA==.',Go='Goatmoon:BAAALAAFFAIIBAAAAA==.',He='Headstrong:BAAALAAECgUIBgAAAA==.Helples:BAAALAAECgYIBgAAAA==.',Hm='Hmw:BAAALAAECgYIBgAAAA==.',Ho='Holyheart:BAAALAAFFAEIAQAAAA==.',Hr='Hrh:BAAALAAECgQIBgAAAA==.',Ki='Kioo:BAABLAAFFH8KAAIIAAIIkRsnSgCmAAAIAAIIkRsnSgCmAAAAAA==.Kioomi:BAAALAAFFAEIAQAAAA==.',Kk='Kkeepgone:BAAALAAFFAIIAgABLAAFFAYIFQAJADciAA==.',Kr='Kroenen:BAAALAADCgIIAgAAAA==.',Ku='Kumo:BAABLAAFFH8TAAMIAAgIYSPlAQCdAgAIAAgIYSPlAQCdAgAKAAEIvBXaFwBkAAAAAA==.',La='Lalddter:BAAALAAECgIIAgAAAA==.',Lo='Lorenzo:BAABLAAFFH8MAAILAAYIZhTLMwBsAQALAAYIZhTLMwBsAQAAAA==.',Ma='Macmillan:BAABLAAECn8cAAICAAYIwAqYQgDUAAACAAYIwAqYQgDUAAABLAAFFAMIBwALAHcQAA==.Manastorm:BAABLAAECn8aAAIMAAgIUx1FGADnAQAMAAgIUx1FGADnAQABLAAFFAIIBAANAAAAAA==.Maybeam:BAABLAAFFH8YAAIDAAUIRxjREQBPAQADAAUIRxjREQBPAQAAAA==.Maybefs:BAAALAAFFAIIBAAAAA==.',Me='Mermer:BAAALAAECgYIBwAAAA==.',Mi='Mikasaackerm:BAAALAAECgMIAwAAAA==.Missrobin:BAACLAAFFH8aAAICAAUIYCXHDAABAgACAAUIYCXHDAABAgAsAAQKfygAAgIACAibIHAQAOQCAAIACAibIHAQAOQCAAAA.',Mo='Monday:BAAALAAECgMIAwAAAA==.Moonday:BAAALAADCgYIBgAAAA==.Moying:BAAALAAECgYICQAAAA==.',Mt='Mtt:BAAALAAFFAIIAgAAAA==.',Na='Nanie:BAABLAAFFH8aAAIIAAYITBYjEQDKAQAIAAYITBYjEQDKAQAAAA==.',No='Notinlovel:BAAALAAECgYIBgAAAA==.Noxiv:BAAALAAECgEIAQAAAA==.',Oh='Ohoojeelay:BAABLAAFFH8GAAIOAAIIEhcpVABzAAAOAAIIEhcpVABzAAAAAA==.',Oo='Ootw:BAAALAAECgEIAQAAAA==.',Pa='Pan:BAAALAADCggICAAAAA==.',Pl='Playeryidtho:BAAALAADCggICQAAAA==.',['Qú']='Qúeen:BAABLAAECn8dAAIIAAgITBTnPgCFAQAIAAgITBTnPgCFAQAAAA==.',Re='Realden:BAABLAAFFH8FAAIIAAMIQRmNYQCKAAAIAAMIQRmNYQCKAAAAAA==.',Ry='Rylaicrestfa:BAAALAAFFAIIAwAAAA==.',Sa='Sam:BAABLAAFFH8HAAIJAAMIQwZQHgDCAAAJAAMIQwZQHgDCAAAAAA==.Santorinss:BAABLAAFFH8IAAMKAAgI9BOZAwCMAQAKAAYI3xWZAwCMAQAPAAIIMg45EwCdAAAAAA==.',Sc='Schicksal:BAAALAAECgYIBgAAAA==.',Se='Sendyouhome:BAABLAAECn8aAAMQAAYIQhVvhQB0AQAQAAYI6xNvhQB0AQARAAYIdQusXQAAAQAAAA==.',Su='Superbia:BAAALAAECgMIAwAAAA==.',Sy='Sylphyy:BAAALAAFFAIIAgAAAA==.',['Sè']='Sè:BAABLAAFFH8FAAMPAAIIERZjDgCTAAAPAAIIERZjDgCTAAAIAAIIegYyjwB4AAAAAA==.',Th='Thanatoswd:BAAALAAECgEIAQAAAA==.',Ti='Tibuu:BAAALAAFFAIIAgAAAA==.Tipis:BAAALAAECgYIBwAAAA==.',Ty='Tydrande:BAAALAAECgYIBgAAAA==.',Ul='Ulr:BAAALAAECgYIDAAAAA==.',Wo='Wozai:BAAALAADCgIIAgAAAA==.',Zz='Zzle:BAAALAADCggICAAAAA==.',['Ïï']='Ïïââååæ:BAAALAAECgYICAAAAA==.',['一只']='一只小短腿:BAAALAADCgUICQAAAA==.',['一名']='一名女子:BAAALAAECgYICAAAAA==.',['一哥']='一哥:BAAALAAECgQIBAAAAA==.',['一壶']='一壶美酒:BAABLAAFFH8IAAMSAAUI4w8iCADlAAASAAUI4w8iCADlAAAHAAIIuQilaAA3AAAAAA==.',['一朵']='一朵俊美男子:BAAALAADCggICAAAAA==.一朵小牙牙:BAABLAAFFH8KAAMEAAYIhQFjIQCsAAAEAAYIhQFjIQCsAAABAAEIGwAZYwADAAAAAA==.一朵小芽芽:BAAALAAFFAQIBAAAAA==.',['七个']='七个隆小恰恰:BAAALAAECggIBAAAAA==.',['七分']='七分熟:BAAALAAECggIDAAAAA==.',['七十']='七十七房客:BAAALAADCgMIAwAAAA==.',['东丶']='东丶邪:BAAALAAECgYIDAAAAA==.',['东京']='东京闹五鼠:BAABLAAFFH8MAAMMAAYImAoZKwBkAQAMAAYImAoZKwBkAQATAAIIVAQKGwBnAAAAAA==.',['丨倚']='丨倚栏听风丨:BAAALAADCggICAAAAA==.',['丨凉']='丨凉今丨:BAAALAAECgYIBgAAAA==.',['丨小']='丨小小筱亭丶:BAABLAAFFH8JAAITAAII+QyyFwBAAAATAAII+QyyFwBAAAAAAA==.',['丶桐']='丶桐崎千棘:BAABLAAFFH83AAMEAAcI/COTAgCdAgAEAAcI/COTAgCdAgABAAIIZQpPPABkAAAAAA==.',['丶沐']='丶沐诗:BAAALAAFFAIIAgAAAA==.',['丶流']='丶流刄若火丿:BAAALAAECgIIAgAAAA==.',['丶白']='丶白芷:BAABLAAFFH8SAAIMAAUIzxtfKgDpAAAMAAUIzxtfKgDpAAAAAA==.',['丶维']='丶维罗妮卡:BAAALAAFFAIIAgAAAA==.',['丶龙']='丶龙纹鬼灯丸:BAAALAADCgYIBgAAAA==.',['丷阿']='丷阿冉:BAAALAAECgYIEAAAAA==.',['丿血']='丿血刃灬:BAAALAAECgYICAAAAA==.',['乄红']='乄红尘:BAAALAAFFAIIBAAAAA==.',['乌兰']='乌兰木青:BAACLAAFFH8jAAIQAAYIFhPhKwBrAQAQAAYIFhPhKwBrAQAsAAQKfyAAAxAACAicGX01AGUCABAACAicGX01AGUCABEAAghnAzKMAFQAAAAA.',['九品']='九品神棍:BAAALAADCgQIBAAAAA==.',['予君']='予君:BAAALAAFFAEIAQAAAA==.',['云归']='云归争渡:BAABLAAFFH8iAAILAAYI3xZGLgB9AQALAAYI3xZGLgB9AQAAAA==.',['五星']='五星欧皇:BAAALAAECgYIBgAAAA==.',['五晨']='五晨寺洗脚妹:BAAALAADCgYIBgAAAA==.',['人比']='人比黄瓜瘦:BAAALAAECgQIBAAAAA==.',['仪玄']='仪玄丶:BAABLAAFFH8MAAIIAAYIwhlKIwCnAQAIAAYIwhlKIwCnAQAAAA==.',['任迪']='任迪:BAAALAAECgYICAAAAA==.',['优然']='优然:BAAALAADCgEIAQAAAA==.',['你五']='你五个五个拉:BAAALAADCgMIAwAAAA==.',['你太']='你太卑鄙了:BAAALAAFFAIIAgAAAA==.',['你才']='你才是小偷:BAAALAAECgYIBgAAAA==.你才是阿昆达:BAAALAAECggICAAAAA==.',['你是']='你是我的苏菲:BAABLAAFFH8HAAILAAMICQxnfwBYAAALAAMICQxnfwBYAAAAAA==.',['你最']='你最大:BAAALAAECgMIBAAAAA==.',['你看']='你看我有腹肌:BAABLAAFFH8UAAIOAAMIwxKOQgCeAAAOAAMIwxKOQgCeAAAAAA==.',['佳得']='佳得乐冰橘:BAAALAAECgYIBgAAAA==.佳得乐浆果味:BAAALAAECgIIAgAAAA==.',['佳成']='佳成毛:BAAALAAECgYIBgAAAA==.',['修玛']='修玛:BAAALAAECgEIAQAAAA==.',['倒镜']='倒镜里那公路:BAAALAAFFAYIAgAAAA==.',['倾丶']='倾丶丶城:BAAALAAECgYIDAAAAA==.',['偏偏']='偏偏如此:BAAALAAECgIIAgAAAA==.',['全奶']='全奶练习:BAABLAAFFH8QAAIUAAUImgU3DQC0AAAUAAUImgU3DQC0AAAAAA==.',['全村']='全村的希望:BAAALAAFFAIIAgABLAAFFAIIAgANAAAAAA==.',['八分']='八分青年:BAAALAAECgMIBgAAAA==.',['兽二']='兽二一:BAABLAAFFH8IAAIVAAQIFQ96HACfAAAVAAQIFQ96HACfAAAAAA==.',['兽管']='兽管员:BAAALAADCgYIBgAAAA==.',['再美']='再美也是曾经:BAAALAAECgUIBQAAAA==.',['冰冰']='冰冰大棒棒:BAAALAAFFAIIBAAAAA==.',['冰寒']='冰寒血脉:BAAALAAFFAIIBAAAAA==.',['凯尔']='凯尔薩斯之怒:BAAALAAECgYICgAAAA==.',['凸口']='凸口凸:BAAALAADCggIEAAAAA==.',['刀刀']='刀刀开圣疗:BAACLAAFFH8OAAMDAAYIugTUFwABAQADAAYIugTUFwABAQACAAII0wd6RABiAAAsAAQKfxcAAgIABggCDkQ+AOoAAAIABggCDkQ+AOoAAAEsAAUUCAgTAAgA1hcA.',['刀语']='刀语:BAAALAAFFAIIBAAAAA==.',['刘诗']='刘诗诗:BAABLAAFFH8IAAIWAAgIrQ2PBgDsAQAWAAgIrQ2PBgDsAQABLAAFFAgIIgAWAG0RAA==.',['刚放']='刚放出来的:BAAALAAFFAIIAgAAAA==.',['初月']='初月:BAAALAAFFAIIBAAAAA==.',['勇敢']='勇敢德:BAAALAADCgQIBAAAAA==.勇敢骑:BAAALAADCgQIBAAAAA==.',['動物']='動物饲养员:BAAALAAFFAIIAgAAAA==.',['包里']='包里没钱啊:BAAALAADCgYIBgAAAA==.',['北冥']='北冥先生:BAAALAAFFAEIAQAAAA==.',['北斗']='北斗之渣:BAAALAAECgYICwAAAA==.',['北海']='北海道的樱花:BAAALAAECgIIAgAAAA==.',['半醒']='半醒的浮生:BAAALAAFFAgIAgAAAA==.',['卖萌']='卖萌催生正义:BAAALAAFFAYIBAAAAA==.',['南朝']='南朝鲜我:BAAALAAECgEIAQAAAA==.',['卧龙']='卧龙丶凤雏:BAAALAAFFAIIBAAAAA==.卧龙丶凤雏丶:BAAALAAECgEIAQAAAA==.',['卩丶']='卩丶獨纞灬:BAAALAAECgEIAQAAAA==.卩丶靈魂灬:BAAALAAECgYIBwAAAA==.',['厂长']='厂长:BAAALAAFFAMIAwAAAA==.',['发糖']='发糖咯:BAAALAAECgYIBgAAAA==.',['叶瞬']='叶瞬光丶:BAABLAAFFH8MAAIIAAYI+hXRLACGAQAIAAYI+hXRLACGAQAAAA==.',['君莫']='君莫愁:BAAALAAECgMIAwAAAA==.君莫狂:BAAALAAECgYIBwAAAA==.',['呼叫']='呼叫尼大眼:BAAALAADCgQIBAAAAA==.',['和纱']='和纱:BAAALAAECgYICgAAAA==.',['咸鱼']='咸鱼阿萨:BAAALAAFFAIIAgAAAA==.',['哈莉']='哈莉璐垭:BAABLAAFFH8IAAMQAAYINx1kJACJAQAQAAYINx1kJACJAQARAAIIEwbhHACDAAAAAA==.',['喜人']='喜人:BAAALAAECgYICAAAAA==.',['喵叻']='喵叻咯咪:BAABLAAFFH8cAAIOAAUIoRBBJgAwAQAOAAUIoRBBJgAwAQAAAA==.',['嗜鳕']='嗜鳕和尚:BAAALAAECgYICAAAAA==.',['嚣张']='嚣张的念头:BAAALAAECgYIBgAAAA==.',['囥斯']='囥斯坦丁:BAAALAAECgEIAgAAAA==.',['囵死']='囵死你:BAAALAAECgMIAwAAAA==.',['国色']='国色天香:BAAALAADCgUIBQAAAA==.',['土不']='土不蜡基:BAAALAADCgYIBgAAAA==.',['土豆']='土豆咖喱牛肉:BAAALAAECgMIBAAAAA==.',['圣光']='圣光修蹄大师:BAAALAAECgMIAwAAAA==.',['圣型']='圣型尤物丷:BAACLAAFFH8hAAMCAAgIkBtEBwDkAQACAAgIkBtEBwDkAQADAAEIlA55JwBIAAAsAAQKf54BAwIACAimJqYBAHADAAIACAimJqYBAHADAAMACAjPHDQlAE0CAAAA.',['地狱']='地狱战歌:BAAALAAECgYIBgAAAA==.',['地铁']='地铁伍号:BAAALAAFFAIIBAAAAA==.地铁叁号:BAABLAAFFH8JAAIBAAMIDw5GMQClAAABAAMIDw5GMQClAAAAAA==.地铁四号:BAABLAAFFH8IAAMOAAQIzRTlLwDvAAAOAAQIzRTlLwDvAAAJAAEIowijVwAAAAAAAA==.',['垒岛']='垒岛叭紫:BAAALAAECgIIAgAAAA==.',['塔拉']='塔拉夏的法理:BAABLAAFFH8IAAIMAAIIzQ+fSACXAAAMAAIIzQ+fSACXAAAAAA==.',['塞纳']='塞纳留斯:BAABLAAFFH8KAAIBAAIICCZhEwDbAAABAAIICCZhEwDbAAAAAA==.',['夏天']='夏天的冰:BAAALAAFFAIIAgAAAA==.',['夏日']='夏日的风:BAAALAAECgQIBAAAAA==.',['外星']='外星人红颜:BAAALAAECgcIDQAAAA==.',['大主']='大主教:BAABLAAFFH8FAAIMAAMIwAvLSwBkAAAMAAMIwAvLSwBkAAAAAA==.',['大吼']='大吼大叫:BAAALAAECgMIAwAAAA==.',['大天']='大天使:BAAALAADCgYIBgAAAA==.',['大富']='大富:BAAALAAECgIIAgAAAA==.',['天剑']='天剑正义:BAAALAAECgYIBwAAAA==.',['天意']='天意不可违:BAAALAAECgYIBgAAAA==.',['天火']='天火炎焱:BAAALAAECgMIAwAAAA==.',['天萨']='天萨斯:BAAALAAECgEIAQAAAA==.',['奀黑']='奀黑牛:BAABLAAECn8YAAIJAAYIiw7QdQBdAQAJAAYIiw7QdQBdAQAAAA==.',['女皇']='女皇:BAAALAAECgIIAgAAAA==.',['奶孩']='奶孩子的辣妈:BAABLAAECn8VAAMCAAYIGxCtawA4AQACAAYI2Q+tawA4AQAXAAEILwwRPwAuAAAAAA==.',['奶无']='奶无限:BAAALAAECgYIBgAAAA==.',['好无']='好无丶奈:BAAALAAECgEIAQAAAA==.好无奈:BAABLAAFFH8IAAIFAAQIWwb6JwBsAAAFAAQIWwb6JwBsAAAAAA==.',['好运']='好运常在:BAAALAADCggICAAAAA==.好运的大富:BAAALAAECgIIAgAAAA==.',['好迷']='好迷茫:BAAALAAFFAIIAgAAAA==.',['好问']='好问题:BAAALAAFFAIIBAAAAA==.',['妖冫']='妖冫:BAAALAADCgUIBQAAAA==.',['妖忌']='妖忌:BAABLAAFFH8IAAIKAAIIGBdYDwCdAAAKAAIIGBdYDwCdAAAAAA==.',['姑娘']='姑娘请自动:BAAALAADCgcIBwAAAA==.',['子菲']='子菲鱼:BAAALAAECgQIBAAAAA==.',['存在']='存在的:BAAALAAECgMIAwAAAA==.',['季莫']='季莫申科:BAACLAAFFH8RAAILAAYI7hx9JACgAQALAAYI7hx9JACgAQAsAAQKfxgAAwsABgiuIdZhABgCAAsABgiuIdZhABgCABgABgiLDQFrABsBAAAA.',['宣告']='宣告者的神巫:BAACLAAFFH8tAAIDAAcIHSVbBgD6AQADAAcIHSVbBgD6AQAsAAQKfykAAgMACAiFI38NAAgDAAMACAiFI38NAAgDAAAA.',['射妹']='射妹:BAAALAAECgMIAwAAAA==.',['小卜']='小卜丶柯:BAAALAAFFAIIAgAAAA==.',['小城']='小城往事:BAACLAAFFH8kAAIZAAYIjyA4BQC2AQAZAAYIjyA4BQC2AQAsAAQKfyAAAhkACAg5IxQGAGQCABkACAg5IxQGAGQCAAAA.',['小斑']='小斑哥:BAAALAAFFAIIAgAAAA==.小斑斑:BAAALAAECgYIBgAAAA==.',['小桃']='小桃:BAABLAAFFH8ZAAIIAAYI5x8gFgDjAQAIAAYI5x8gFgDjAQAAAA==.',['小煎']='小煎:BAAALAAECgIIAgAAAA==.',['小牛']='小牛山姆:BAAALAAECgMIAwAAAA==.',['小狐']='小狐咩:BAAALAAECgYIBgAAAA==.',['小猪']='小猪佩饭:BAABLAAFFH8IAAIaAAIIkyDPAwC3AAAaAAIIkyDPAwC3AAAAAA==.',['小薇']='小薇伊:BAAALAAECgQIBgAAAA==.小薇狐:BAAALAAECggIDAAAAA==.',['小酒']='小酒酿:BAAALAAECgMIAwAAAA==.',['小雨']='小雨七:BAAALAADCgYIBgAAAA==.',['小饼']='小饼:BAAALAAECgYICQAAAA==.',['小马']='小马灬飞飞:BAAALAAECgQIBAAAAA==.',['小鹿']='小鹿妈妈:BAABLAAECn8VAAIbAAgIxhx/DQCQAgAbAAgIxhx/DQCQAgAAAA==.',['小龙']='小龙人找尾巴:BAAALAAFFAEIAQAAAA==.',['尐战']='尐战灬:BAAALAADCgEIAQAAAA==.',['就是']='就是弄:BAAALAAECgYICgAAAA==.',['岛屿']='岛屿橙与梦:BAABLAAFFH8GAAILAAYIxBx7IACwAQALAAYIxBx7IACwAQAAAA==.',['崩天']='崩天恨雨:BAACLAAFFH8MAAILAAIIOR3YPwCmAAALAAIIOR3YPwCmAAAsAAQKfxsAAgsABwhaIscdAEkCAAsABwhaIscdAEkCAAAA.',['崭戮']='崭戮:BAAALAAECgYIBwAAAA==.',['帝王']='帝王引擎:BAAALAAECgEIAQAAAA==.',['带翅']='带翅膀的奔驰:BAABLAAFFH8LAAIcAAMIRAfvGQBlAAAcAAMIRAfvGQBlAAAAAA==.',['幼稚']='幼稚园典狱长:BAABLAAFFH8GAAIdAAYIHCMYAQB1AgAdAAYIHCMYAQB1AgAAAA==.',['当我']='当我不存在:BAAALAAECgcIBwAAAA==.',['很迷']='很迷茫:BAAALAAFFAEIAQAAAA==.',['微凉']='微凉:BAABLAAFFH8VAAIGAAgIIBrGBAA7AgAGAAgIIBrGBAA7AgAAAA==.',['微笑']='微笑很倾城:BAAALAADCgYIBgAAAA==.',['德玛']='德玛西亚马仔:BAAALAAECgYIBgAAAA==.',['心渊']='心渊恶魔:BAABLAAFFH8QAAIHAAIIah1IMQCnAAAHAAIIah1IMQCnAAAAAA==.',['怒疯']='怒疯:BAAALAADCgYIBgAAAA==.',['恶魔']='恶魔不在身边:BAAALAAECgEIAQAAAA==.',['想不']='想不到名字:BAAALAADCggICAAAAA==.',['愤怒']='愤怒的阿伟:BAAALAADCgQIBAAAAA==.',['我不']='我不入地獄:BAAALAADCggICAAAAA==.',['战雪']='战雪梦翎羽:BAAALAAECgEIAQAAAA==.',['扛把']='扛把子:BAAALAAECgYIBgAAAA==.',['把额']='把额一贼:BAAALAADCgEIAQAAAA==.',['抽大']='抽大一笔:BAAALAAECgYIDAAAAA==.',['按键']='按键伤人:BAAALAAFFAYIAwAAAA==.',['挖掘']='挖掘机:BAAALAAECgMIAwAAAA==.',['捏擦']='捏擦瓜头:BAAALAAFFAIIAgAAAA==.',['放学']='放学还锤你:BAAALAAECgMIAwAAAA==.',['放开']='放开那公猪:BAAALAAECggIDwAAAA==.',['放羊']='放羊的牛哥:BAAALAAECggICAAAAA==.',['斑点']='斑点牛:BAAALAAFFAIIAgAAAA==.',['斯密']='斯密玛赛:BAAALAAFFAIIBAAAAA==.',['新手']='新手不會玩:BAAALAAECgQIBAAAAA==.',['无情']='无情混分仔:BAAALAAECgIIAgAAAA==.',['旧旅']='旧旅孤笛:BAAALAAFFAMIBAAAAA==.',['星见']='星见雅丶:BAABLAAFFH8LAAIIAAYI7xWbLgCAAQAIAAYI7xWbLgCAAQAAAA==.',['暗影']='暗影光明使者:BAAALAAECgQIBAAAAA==.',['暗黑']='暗黑之殇:BAAALAAECgYIBgAAAA==.',['暧味']='暧味:BAAALAAECgYICAAAAA==.',['暴走']='暴走蕾丝妹:BAAALAAFFAIIAgAAAA==.',['月夜']='月夜下的恶魔:BAAALAAFFAMIAwAAAA==.月夜无痕:BAAALAAFFAQIBAAAAA==.',['朝廷']='朝廷心腹:BAAALAAECgYIDgAAAA==.朝廷心腹之患:BAAALAAECgYIDAAAAA==.',['朝蕣']='朝蕣:BAABLAAFFH8JAAMdAAIINhW5GAB9AAAdAAIINhW5GAB9AAAcAAIISgbsIABnAAAAAA==.',['木三']='木三丶德:BAAALAAFFAIIAgAAAA==.',['朱鹭']='朱鹭子:BAACLAAFFH84AAMBAAgIFiEAAQAWAwABAAgIFiEAAQAWAwAEAAQI8w1UIAC6AAAsAAQKfz0ABAEACAhnIGkUALoCAAEACAhnIGkUALoCAAQACAhzHq8XAKYCABoAAwgVIekRABkBAAAA.',['李思']='李思思:BAABLAAFFH8iAAIWAAgIbRHTBgDmAQAWAAgIbRHTBgDmAQAAAA==.',['杨亦']='杨亦瑶:BAABLAAFFH8NAAILAAYIPBpMJgCZAQALAAYIPBpMJgCZAQAAAA==.',['杨恭']='杨恭如:BAAALAAFFAIIBAAAAA==.',['林深']='林深河:BAAALAAECgYICQAAAA==.',['枯术']='枯术焚骨:BAAALAADCgIIAgAAAA==.',['染淡']='染淡的小麦:BAAALAADCgUIBQAAAA==.',['查理']='查理德森:BAAALAADCgYIBgAAAA==.',['柳姑']='柳姑娘灬:BAABLAAFFH8MAAIIAAYIKSMiPgBCAQAIAAYIKSMiPgBCAQAAAA==.',['梦闫']='梦闫:BAAALAAECgUIBQAAAA==.',['楓葉']='楓葉落:BAAALAAECgYICgAAAA==.',['橘子']='橘子橙:BAABLAAFFH8IAAIIAAIIyxFKbgCRAAAIAAIIyxFKbgCRAAAAAA==.',['欺骗']='欺骗空间:BAACLAAFFH8MAAMCAAQI/AugKQDeAAACAAQI/AugKQDeAAADAAIImALbMQArAAAsAAQKfxwAAgIACAijIjAUAMgCAAIACAijIjAUAMgCAAAA.',['歆之']='歆之莘莘:BAAALAAECgUIBQAAAA==.',['歪丶']='歪丶歪:BAABLAAFFH8FAAILAAUItRnGSgAhAQALAAUItRnGSgAhAQAAAA==.',['殇丶']='殇丶祭奠:BAAALAADCgMIAwAAAA==.',['残月']='残月下的黑暗:BAAALAAECgQIBAAAAA==.',['氮泵']='氮泵爱好者:BAAALAAFFAIIAwAAAA==.',['水晶']='水晶枫叶:BAABLAAFFH8PAAMGAAUIMxR2KwAmAQAGAAUIMxR2KwAmAQAUAAMISBLhEABwAAAAAA==.水晶枫叶丶:BAAALAAECgEIAQAAAA==.',['沉默']='沉默:BAAALAAECggIBgAAAA==.',['沐丨']='沐丨辰:BAAALAAECgYIBgAAAA==.',['沐雨']='沐雨橙风:BAAALAAECgYIBgAAAA==.',['法外']='法外之徒张三:BAAALAAECgYICwAAAA==.',['波涛']='波涛使者:BAAALAADCggICAAAAA==.',['消逝']='消逝的回忆丶:BAAALAAECgUIBQAAAA==.',['深田']='深田用妹:BAAALAAECgUIBwAAAA==.',['湖赛']='湖赛五庄:BAAALAADCgMIAwAAAA==.',['湛蓝']='湛蓝灬小贝:BAAALAAECgYIBgAAAA==.',['潮汐']='潮汐:BAAALAAECgEIAQAAAA==.',['潴小']='潴小薰:BAABLAAFFH8HAAMBAAIIdA3BNwBoAAABAAIIdA3BNwBoAAAaAAIIwAtjCQBoAAAAAA==.',['灬雨']='灬雨灵丶:BAAALAADCgQIBAAAAA==.',['無夜']='無夜:BAAALAAECgYIEQAAAA==.',['熊德']='熊德:BAAALAAECggICAAAAA==.',['爱霏']='爱霏霏:BAAALAAECgYIBwAAAA==.',['父亲']='父亲丶:BAAALAAFFAIIAwAAAA==.',['牛战']='牛战成王:BAAALAADCgIIAgAAAA==.',['牛根']='牛根硕:BAAALAAECgYIBgAAAA==.',['牧路']='牧路人:BAACLAAFFH8SAAICAAIIFSKRLADBAAACAAIIFSKRLADBAAAsAAQKfygAAwIACAhYHUATADUCAAIACAhYHUATADUCAAMAAwjhB51AAGoAAAAA.',['牵着']='牵着晓猪漫步:BAABLAAFFH8HAAMOAAQIExdsOgC5AAAOAAMI8hNsOgC5AAAJAAEIiRPsPgBMAAAAAA==.',['狂暴']='狂暴涉猎:BAAALAAECgIIAgAAAA==.',['狩猎']='狩猎火龙果:BAAALAAECgQIBAAAAA==.',['独孤']='独孤一箭:BAAALAAFFAEIAQAAAA==.',['狸喵']='狸喵菜菜子:BAAALAAECgYIBgAAAA==.',['狼群']='狼群灬牛仔:BAAALAAFFAIIBAAAAA==.',['猛萌']='猛萌德:BAAALAADCgEIAQAAAA==.',['玄武']='玄武湖王处:BAABLAAFFH8JAAIQAAYIqxiyIgCQAQAQAAYIqxiyIgCQAQAAAA==.',['王冰']='王冰冰:BAABLAAFFH8VAAIWAAgIIREfBgD2AQAWAAgIIREfBgD2AQABLAAFFAgIIgAWAG0RAA==.',['王启']='王启年:BAAALAAECgYIBgAAAA==.',['王小']='王小吉丶:BAAALAAECgYIBgAAAA==.',['王者']='王者赞歌:BAAALAAECgYIBgAAAA==.',['玲児']='玲児:BAAALAAFFAMIAwAAAA==.',['琮润']='琮润同学:BAAALAAECgQIBAAAAA==.',['瑞丰']='瑞丰:BAAALAAECggICAAAAA==.',['瑞文']='瑞文黛儿:BAAALAAECgYIBgAAAA==.',['电竞']='电竞李庚希:BAABLAAFFH8IAAIeAAIImxjMAwClAAAeAAIImxjMAwClAAAAAA==.',['百事']='百事:BAAALAAECgYIBwAAAA==.',['盗墓']='盗墓的:BAAALAAECgIIAgAAAA==.',['看窝']='看窝把妮打哭:BAAALAAECgYIBgAAAA==.',['督伱']='督伱柿忽:BAAALAAECggIEQAAAA==.',['瞑目']='瞑目丶怒风:BAAALAADCgIIAgAAAA==.',['码头']='码头搞点男大:BAAALAAECgYIBgAAAA==.',['碧瞳']='碧瞳妖妖:BAACLAAFFH8GAAMRAAII5xM0EgCgAAARAAII5xM0EgCgAAAQAAEIXwcBYQBAAAAsAAQKfyEAAxEABwjCHPAXADgCABEABwhPHPAXADgCABAABAh8GM2rACIBAAAA.',['祝踏']='祝踏岗:BAAALAAFFAIIAgAAAA==.',['神赴']='神赴我:BAABLAAFFH8LAAIGAAYIAw5VHADmAAAGAAYIAw5VHADmAAAAAA==.',['福瑞']='福瑞小英雄:BAAALAAECgcIEQAAAA==.',['秋水']='秋水无尘:BAABLAAFFH8HAAIFAAQIPgVxHQC5AAAFAAQIPgVxHQC5AAAAAA==.',['科赞']='科赞吴彦祖:BAAALAADCgQIBAAAAA==.',['秦琴']='秦琴师妹:BAAALAAECgYIBgAAAA==.',['穿云']='穿云贱:BAABLAAFFH8IAAILAAgIGALVaQCPAAALAAgIGALVaQCPAAAAAA==.',['窃贼']='窃贼的烟玉:BAABLAAFFH8KAAIfAAIIdyLPDwDQAAAfAAIIdyLPDwDQAAAAAA==.',['等差']='等差数猎:BAAALAAFFAIIBAAAAA==.',['精神']='精神病院院长:BAAALAAECgQIBAAAAA==.',['索克']='索克希尔:BAAALAADCgMIAwAAAA==.',['红色']='红色的丝:BAAALAAFFAIIAgAAAA==.',['约翰']='约翰尼杜甫:BAAALAAECggIDAAAAA==.',['纷缘']='纷缘:BAABLAAFFH8UAAMIAAgIQx2FCABxAgAIAAgIihyFCABxAgAPAAIIvAtuEwCZAAAAAA==.',['绿色']='绿色妖怪:BAAALAAECgYIBgAAAA==.',['绿野']='绿野繁花:BAAALAADCgYIBgAAAA==.',['美式']='美式蛇吻:BAABLAAECn8iAAMMAAcIWBqTKwBsAQAMAAcINRiTKwBsAQATAAUIHxqQTgA4AQAAAA==.',['老北']='老北京肉龙:BAAALAADCgUIBwAAAA==.',['老司']='老司机老王:BAAALAAECgYICgAAAA==.',['老鸡']='老鸡奇遇记:BAAALAAECgYIBgAAAA==.',['肖白']='肖白朗:BAAALAADCgcIBwAAAA==.',['脱贫']='脱贫小表哥:BAAALAAECgMIAwAAAA==.',['腤之']='腤之戰殇:BAACLAAFFH8fAAIgAAYInBpVFQCxAQAgAAYInBpVFQCxAQAsAAQKfxgAAiAACAjPHjMqAJQCACAACAjPHjMqAJQCAAAA.',['自然']='自然何用:BAAALAAECgYIDAAAAA==.',['自贡']='自贡夹沙肉:BAAALAADCgYIBwAAAA==.',['至高']='至高岭胡恩:BAAALAADCggICAAAAA==.',['芙莉']='芙莉莲:BAAALAAECgcICAAAAA==.',['芝士']='芝士就是力量:BAABLAAFFH8GAAIJAAYIBQ1pIAA9AQAJAAYIBQ1pIAA9AQAAAA==.',['芸梦']='芸梦之州:BAAALAAECgYIDAABLAAECggIGgAOABEbAA==.',['苁今']='苁今以茩:BAAALAAFFAIIAgAAAA==.',['苏菲']='苏菲丶:BAAALAAECgYIBwAAAA==.',['茶奈']='茶奈奈:BAAALAAFFAIIAgAAAA==.',['草莓']='草莓熊:BAACLAAFFH8FAAIBAAUIbhHzHgArAQABAAUIbhHzHgArAQAsAAQKfxQAAwEABwi1GP1OAKoBAAEABwi1GP1OAKoBACEAAQi+CwNLADcAAAAA.',['荣耀']='荣耀丶之风:BAAALAAECgMIAwAAAA==.',['菊花']='菊花还好吗:BAAALAAECgYIBgAAAA==.',['菲比']='菲比呀:BAAALAAECgYIBgAAAA==.',['萌哥']='萌哥李小龙:BAAALAAECgEIAQAAAA==.',['萤火']='萤火明:BAAALAADCgMIAwAAAA==.',['落单']='落单被人伦:BAAALAAFFAIIBAAAAA==.',['落尘']='落尘:BAAALAAECgMIAwAAAA==.',['葛力']='葛力娒乔:BAACLAAFFH8ZAAIgAAYIRhxcEwC/AQAgAAYIRhxcEwC/AQAsAAQKfxQAAiAACAjnHmYWAC4CACAACAjnHmYWAC4CAAAA.',['蒙娜']='蒙娜丽萨:BAAALAAFFAIIAgAAAA==.',['蒜鸟']='蒜鸟蒜鳥:BAAALAAECggIDwAAAA==.',['蓝莓']='蓝莓兔兔:BAAALAAECgIIAgAAAA==.',['蓝蜗']='蓝蜗牛:BAAALAAFFAIIBAAAAA==.',['蝎子']='蝎子莱莱:BAAALAAECgYICwAAAA==.',['裤衩']='裤衩蒙面侠:BAAALAAECgMIAwAAAA==.',['西城']='西城樹里:BAAALAAECggICQAAAA==.',['见面']='见面火球再说:BAAALAAFFAIIBAAAAA==.',['观骑']='观骑不语:BAAALAAFFAIIAgAAAA==.',['请你']='请你吃大冬瓜:BAAALAADCgIIAgAAAA==.请你吃大芒果:BAAALAADCgIIAgAAAA==.',['豆花']='豆花烤鱼:BAABLAAECn8UAAIgAAgILAPKhACFAAAgAAgILAPKhACFAAAAAA==.',['豆闪']='豆闪:BAABLAAECn8aAAMJAAYI4hLCOgAiAQAJAAYI4hLCOgAiAQAOAAEIMANtrwAYAAAAAA==.',['赤道']='赤道雨:BAABLAAFFH8LAAIQAAYI5Q4WMgBOAQAQAAYI5Q4WMgBOAQAAAA==.',['辺王']='辺王:BAAALAAECgEIAQAAAA==.',['迎风']='迎风布阵:BAAALAAECgMIAwAAAA==.',['远房']='远房大舅子:BAABLAAECn8YAAILAAYIwheysgCRAQALAAYIwheysgCRAQAAAA==.',['迷惘']='迷惘的霊魂:BAABLAAFFH8KAAIBAAIIWh30KQCEAAABAAIIWh30KQCEAAAAAA==.',['追云']='追云影:BAABLAAFFH8KAAIdAAIIwRl9EQCbAAAdAAIIwRl9EQCbAAAAAA==.',['邪恶']='邪恶四季稻:BAABLAAECn8XAAQQAAYIJRptYgDKAQAQAAYIJRptYgDKAQARAAYIdAxVSQBMAQAiAAEIAQPNRAAuAAAAAA==.',['酒心']='酒心巧克力糖:BAAALAADCgUIBgAAAA==.',['酷乐']='酷乐:BAACLAAFFH8KAAILAAYIaR9EGwDHAQALAAYIaR9EGwDHAQAsAAQKfyAABAsACAiAJNYJAEkDAAsACAiAJNYJAEkDABgACAiiGVQrACACACMAAggNAkAmADUAAAEsAAUUCAgVABAApxwA.',['醋芯']='醋芯巧克力:BAAALAAECggICAAAAA==.',['鍩丶']='鍩丶丶唁:BAAALAAFFAIIAgAAAA==.',['鎖鈊']='鎖鈊鎖愛:BAAALAAECgUIBQAAAA==.',['锁定']='锁定你屁屁:BAACLAAFFH8HAAIQAAII7whiUgB7AAAQAAII7whiUgB7AAAsAAQKfxYAAhAACAiNEf43AGkBABAACAiNEf43AGkBAAAA.',['闪亮']='闪亮登场:BAAALAADCgIIAgAAAA==.',['闷了']='闷了闪:BAAALAAECgIIAgAAAA==.',['阳光']='阳光下的星:BAAALAAECgEIAQAAAA==.',['阿东']='阿东:BAABLAAFFH8MAAIMAAYIiQ3FKwBhAQAMAAYIiQ3FKwBhAQAAAA==.',['阿兽']='阿兽五十一:BAAALAADCgEIAQAAAA==.',['阿冉']='阿冉:BAAALAAFFAIIAgAAAA==.',['阿凡']='阿凡达七号:BAABLAAFFH8OAAIMAAgIaR+sBQCQAgAMAAgIaR+sBQCQAgAAAA==.阿凡达三号:BAABLAAFFH8GAAIMAAYIBhVVDAAGAgAMAAYIBhVVDAAGAgAAAA==.阿凡达九号:BAABLAAFFH8IAAIMAAgIuBlxBwBuAgAMAAgIuBlxBwBuAgAAAA==.阿凡达二号:BAABLAAFFH8IAAIMAAYIxRnLJACBAQAMAAYIxRnLJACBAQAAAA==.阿凡达五号:BAABLAAFFH8MAAIMAAgIgyDSBwBnAgAMAAgIgyDSBwBnAgAAAA==.阿凡达八号:BAABLAAFFH8IAAIMAAYIDRu1IgCKAQAMAAYIDRu1IgCKAQAAAA==.阿凡达六号:BAABLAAFFH8LAAIMAAYIIx1PIACVAQAMAAYIIx1PIACVAQAAAA==.',['阿哩']='阿哩路亚:BAABLAAFFH8IAAMMAAQIzBItQACrAAAMAAQIzBItQACrAAAkAAEIfAKvDgA0AAAAAA==.',['阿寳']='阿寳子:BAAALAAECgEIAQAAAA==.',['阿狸']='阿狸璐垭:BAABLAAFFH8OAAIGAAYIoxfTHAB5AQAGAAYIoxfTHAB5AQAAAA==.',['阿黑']='阿黑哥:BAAALAAECgYIBwAAAA==.',['陀螺']='陀螺精:BAABLAAFFH8LAAIgAAIIkCHMMgCcAAAgAAIIkCHMMgCcAAAAAA==.',['陈桂']='陈桂林:BAABLAAFFH8FAAIGAAIIwxDgZABEAAAGAAIIwxDgZABEAAAAAA==.',['陟岵']='陟岵陟屺:BAABLAAFFH8IAAIdAAII5R3mEQCYAAAdAAII5R3mEQCYAAAAAA==.',['随风']='随风的圣光:BAAALAAECgQIBAABLAAFFAIIBwATAG0eAA==.',['雪梨']='雪梨兔兔:BAAALAAECgUIBQAAAA==.',['雪白']='雪白蹄子:BAABLAAFFH8PAAIgAAgI1B5cBQCBAgAgAAgI1B5cBQCBAgAAAA==.',['零三']='零三:BAAALAAECgUIBQAAAA==.',['零冰']='零冰魔妖雪女:BAAALAADCggICAAAAA==.',['霏霏']='霏霏雨雨:BAAALAAECgYIEQAAAA==.',['霸王']='霸王牛:BAAALAAECgYIDAAAAA==.',['青楼']='青楼城灵动:BAABLAAECn8YAAMMAAYIBhTrNwAvAQAMAAYIBhTrNwAvAQATAAQIcQZGdgCSAAAAAA==.',['青饿']='青饿鱼:BAAALAAECgEIAQAAAA==.',['風至']='風至踏來:BAABLAAECn8XAAIZAAcIKxQ1JwDIAQAZAAcIKxQ1JwDIAQAAAA==.',['风吹']='风吹我来了:BAAALAAECgIIAgAAAA==.',['风暴']='风暴之夜:BAABLAAFFH8IAAIJAAIIqAXaSQA9AAAJAAIIqAXaSQA9AAAAAA==.风暴大锤:BAAALAAECgYIDQAAAA==.风暴的快枪猎:BAABLAAFFH8JAAILAAMIjQotfgBbAAALAAMIjQotfgBbAAAAAA==.风暴财团猎手:BAACLAAFFH8KAAIgAAMItQ40OgCKAAAgAAMItQ40OgCKAAAsAAQKfxwAAiAACAipGzATAEoCACAACAipGzATAEoCAAAA.',['风霜']='风霜任漂泊:BAAALAAFFAIIAgAAAA==.',['飙车']='飙车必秃顶:BAAALAAECgMIAwAAAA==.',['饿了']='饿了么猎手:BAAALAAECgUIBQAAAA==.',['香橙']='香橙兔兔:BAAALAAECgUIBQAAAA==.',['香辣']='香辣牛肉面:BAAALAAECgYIBgAAAA==.',['骑士']='骑士老牛:BAAALAAECggICAAAAA==.',['骑着']='骑着晓猪漫步:BAAALAAECgIIAgAAAA==.',['魔刃']='魔刃之龙:BAAALAAECgYIBgAAAA==.',['鸽子']='鸽子王小港:BAAALAAECgYIBgAAAA==.',['黑死']='黑死神:BAAALAAECggICAAAAA==.',['黑色']='黑色的丝:BAAALAAFFAIIBAAAAA==.',['黑蓝']='黑蓝月:BAAALAAECgUIBQAAAA==.',['黑黯']='黑黯圣斗丶士:BAAALAAECgYIBgAAAA==.',['黑鼠']='黑鼠鼠:BAAALAAFFAIIAgAAAA==.',['龙三']='龙三一:BAABLAAFFH8IAAIVAAQIOwyBHACfAAAVAAQIOwyBHACfAAAAAA==.',['龙丿']='龙丿帝:BAAALAAECgYICgAAAA==.',['龙二']='龙二一:BAAALAAFFAEIAQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end