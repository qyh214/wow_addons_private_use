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
 local lookup = {'Warlock-Destruction','Warlock-Demonology','Monk-Brewmaster','DemonHunter-Havoc','DemonHunter-Vengeance','DeathKnight-Frost','Hunter-Marksmanship','Paladin-Retribution','Warlock-Affliction','Hunter-BeastMastery','Mage-Frost','Warrior-Protection','Paladin-Protection','Mage-Arcane','Shaman-Elemental','Shaman-Restoration','Warrior-Fury','DeathKnight-Blood','Paladin-Holy','Druid-Balance','Druid-Restoration','DeathKnight-Unholy','Druid-Feral','Rogue-Assassination','Rogue-Subtlety','Monk-Mistweaver','Priest-Holy','Warrior-Arms',}; local provider = {region='CN',realm='罗曼斯',name='CN',type='weekly',zone=44,date='2025-12-07',data={Ad='Ads:BAAALAAECgYICwAAAA==.',An='Angjila:BAAALAAECgcICQAAAA==.',Ar='Aroden:BAAALAADCgcIBwAAAA==.',Da='Darkbreak:BAAALAAFFAEIAQAAAA==.Darling:BAAALAAFFAIIAgAAAA==.',De='Demonhunters:BAAALAAECgEIAQAAAA==.Derfomation:BAAALAAECgYIEAAAAA==.',Do='Dotmachine:BAABLAAFFH8MAAMBAAMIjBt3SQCXAAABAAMIRBR3SQCXAAACAAIIdhcHFgBAAAAAAA==.',Fu='Furrydada:BAAALAAFFAIIBAAAAA==.',Go='Goldenoolong:BAAALAAFFAIIAgAAAA==.',Li='Lifengws:BAABLAAFFH8EAAIDAAQIjg3aHQBAAAADAAQIjg3aHQBAAAAAAA==.',Lo='Lostzhe:BAABLAAFFH8RAAMEAAYIRBtwGACqAQAEAAYIRBtwGACqAQAFAAII1hcADQCMAAAAAA==.',['Lú']='Lúthien:BAAALAADCgcIBwAAAA==.',Pa='Palado:BAAALAAECgYICQAAAA==.Paladowow:BAAALAAECggIEgAAAA==.Panad:BAAALAADCgIIAgAAAA==.',Pe='Peachoolong:BAABLAAFFH8MAAIGAAIIihZniABCAAAGAAIIihZniABCAAAAAA==.',Pi='Piggy:BAAALAAECgYIBgAAAA==.',Pr='Prometheus:BAAALAAFFAIIBAAAAA==.',Re='Relex:BAABLAAFFH8JAAIHAAMIfA89HACYAAAHAAMIfA89HACYAAAAAA==.',Ro='Roseoolong:BAABLAAFFH8GAAIIAAIIPRSmXABIAAAIAAIIPRSmXABIAAAAAA==.',Se='Sevi:BAAALAAFFAEIAQAAAA==.',Sh='Shadowless:BAAALAAFFAYIAwAAAA==.',Xi='Xianfish:BAACLAAFFH8IAAMBAAMIbxrXIwABAQABAAMIbxrXIwABAQAJAAEIkxCCBwBRAAAsAAQKfy8AAwEACAg2IQIUAA0DAAEACAg2IQIUAA0DAAkABghkHgAMAPMBAAEsAAUUBggiAAEARyQA.',Yo='Yoohao:BAAALAADCgIIAgAAAA==.',Zi='Zih:BAAALAAFFAMIAwAAAA==.',['Çä']='Çä:BAAALAAECgYIDQAAAA==.',['一兽']='一兽栏宝宝:BAABLAAFFH8FAAIKAAIITQzFiQBJAAAKAAIITQzFiQBJAAAAAA==.',['一静']='一静静一:BAABLAAFFH8GAAIDAAYI5x1aAwAQAgADAAYI5x1aAwAQAgAAAA==.',['一颗']='一颗橘子:BAAALAADCgUIBgAAAA==.',['七海']='七海的霸主:BAAALAAFFAIIBAAAAA==.',['万丈']='万丈红尘:BAABLAAFFH8GAAILAAIIDgVgHQBPAAALAAIIDgVgHQBPAAAAAA==.',['三花']='三花猫头:BAABLAAFFH8IAAIGAAYIkBKGMwBvAQAGAAYIkBKGMwBvAQAAAA==.',['三鲜']='三鲜包:BAABLAAFFH8IAAIMAAIIkw7JJgBwAAAMAAIIkw7JJgBwAAAAAA==.',['下水']='下水道修理工:BAAALAAECgYIBgAAAA==.',['不知']='不知:BAAALAAFFAIIAgAAAA==.',['两颗']='两颗大虎牙:BAAALAAECgYICAAAAA==.',['丨德']='丨德灬德丨:BAAALAAECgYIBgAAAA==.',['丨灬']='丨灬老板灬丨:BAAALAAECgYIDwAAAA==.',['中分']='中分老牛:BAAALAAECgUIBQAAAA==.',['丶大']='丶大丸子:BAABLAAFFH8KAAMIAAYIdAk9KwArAQAIAAYIdAk9KwArAQANAAMI6gXBHABqAAAAAA==.',['丶女']='丶女巫:BAABLAAFFH8IAAICAAIIsBxcDACvAAACAAIIsBxcDACvAAAAAA==.',['丶小']='丶小丸子:BAABLAAFFH8GAAIMAAII2xnuIQB6AAAMAAII2xnuIQB6AAAAAA==.丶小淳:BAABLAAFFH8GAAIBAAYIDBRKJwB+AQABAAYIDBRKJwB+AQAAAA==.',['丶月']='丶月迷津渡:BAABLAAFFH8VAAIOAAYIeRXOIwCIAQAOAAYIeRXOIwCIAQAAAA==.',['丶极']='丶极光:BAABLAAFFH8KAAIEAAYIswtxJABrAQAEAAYIswtxJABrAQAAAA==.',['丶淳']='丶淳:BAAALAAFFAYIAQAAAA==.',['丶灵']='丶灵泽:BAABLAAFFH8FAAMPAAQIbwcfLwCLAAAPAAMIzgAfLwCLAAAQAAIIJgHscABHAAAAAA==.',['丶猛']='丶猛牛代言人:BAABLAAFFH8ZAAMRAAcIHhzgCgAKAgARAAcIHhzgCgAKAgAMAAII4RYyGwCMAAAAAA==.',['丶穹']='丶穹灵:BAABLAAECn8UAAIOAAgIXxZ7HgC5AQAOAAgIXxZ7HgC5AQAAAA==.',['丶阿']='丶阿猛:BAACLAAFFH8iAAIGAAYIXCMTFgDmAQAGAAYIXCMTFgDmAQAsAAQKfyMAAgYABwgCJVgYACgCAAYABwgCJVgYACgCAAAA.',['丿京']='丿京酱肉丝:BAAALAAECgYIDgAAAA==.',['丿冷']='丿冷丶漠丨:BAABLAAFFH8JAAIRAAMINxlHMwCtAAARAAMINxlHMwCtAAAAAA==.',['乐咦']='乐咦李:BAAALAAECgEIAQAAAA==.',['云初']='云初:BAACLAAFFH83AAIEAAcIdxzmDAABAgAEAAcIdxzmDAABAgAsAAQKfyEAAwQACAiEIRooAL4CAAQACAiEIRooAL4CAAUAAQiGDg5qACsAAAAA.',['云朵']='云朵很暖:BAABLAAFFH8FAAISAAIIZwEIIAAeAAASAAIIZwEIIAAeAAAAAA==.',['云韵']='云韵:BAAALAAECgYICQAAAA==.',['亲亲']='亲亲子衿:BAAALAAECgcIBwAAAA==.',['仔仔']='仔仔猫:BAAALAAFFAEIAQABLAAFFAgIGAAGALscAA==.',['伊利']='伊利蛋:BAAALAADCgcICAABLAAFFAYIBgATAAEOAA==.',['传奇']='传奇丶无敌:BAAALAADCgEIAQAAAA==.传奇丶爱你:BAAALAAECggICQAAAA==.',['佛丁']='佛丁黒我无敌:BAAALAAECgMIAwAAAA==.',['供给']='供给侧漏:BAABLAAFFH8GAAIIAAYIIgFsUABYAAAIAAYIIgFsUABYAAAAAA==.',['便池']='便池恶蝇:BAAALAADCgcIBwAAAA==.',['保护']='保护熊猫:BAAALAAECgcIBwAAAA==.',['倔强']='倔强的虾米:BAAALAAFFAIIAgAAAA==.',['偷偷']='偷偷奶死你:BAAALAAECgYIDAAAAA==.偷偷射死你:BAAALAAECgYIEQAAAA==.偷偷锤死你:BAAALAAECgcICQAAAA==.',['傻馒']='傻馒儿:BAAALAAECgUIBQAAAA==.',['光与']='光与暗同质:BAAALAAFFAIIBAAAAA==.光与暗的转生:BAAALAAECgUICAAAAA==.',['光启']='光启牛牛:BAABLAAFFH8LAAIIAAIIChWgPQCgAAAIAAIIChWgPQCgAAAAAA==.',['光头']='光头虐人:BAABLAAFFH8GAAIKAAIIfxjEpAA9AAAKAAIIfxjEpAA9AAAAAA==.',['光明']='光明村地痞:BAAALAAECgYIBgAAAA==.光明村打手:BAABLAAFFH8HAAIRAAUIpw7dKQAhAQARAAUIpw7dKQAhAQABLAAFFAYIFAAUALAZAA==.光明村村花:BAABLAAFFH8QAAIBAAUI8RcdNQBAAQABAAUI8RcdNQBAAQABLAAFFAYIFAAUALAZAA==.光明村村长:BAABLAAFFH8UAAMUAAYIsBlUFABDAQAUAAUI7RtUFABDAQAVAAQIHguNKgDIAAAAAA==.光明村钱掌柜:BAAALAAECgYIBgABLAAFFAYIFAAUALAZAA==.',['内个']='内个棋士丶:BAAALAAFFAIIBAABLAAFFAUIBwAKAH8JAA==.内个熊猫丶:BAAALAAECgIIAgABLAAFFAUIBwAKAH8JAA==.内个青楼丶:BAABLAAFFH8HAAIKAAUIfwnlVwDxAAAKAAUIfwnlVwDxAAAAAA==.',['冰霜']='冰霜巨人:BAAALAAECggICAAAAA==.',['冲釒']='冲釒:BAABLAAFFH8GAAIMAAIIkBTbHACFAAAMAAIIkBTbHACFAAAAAA==.',['凌离']='凌离儿:BAABLAAFFH8IAAIKAAgIBQHOxAATAAAKAAgIBQHOxAATAAAAAA==.',['凸秃']='凸秃凸:BAAALAAECgIIAgAAAA==.',['别浪']='别浪:BAABLAAFFH8IAAMWAAIIlw/vEgCOAAAWAAIIzgvvEgCOAAAGAAIIlw87kQA+AAAAAA==.',['北境']='北境老王:BAAALAAECgYIDwAAAA==.',['北极']='北极蝉:BAAALAAECgYIDwAAAA==.',['北落']='北落紫衫:BAAALAAECgIIAgAAAA==.',['单身']='单身的小乳猪:BAAALAADCgcIBwAAAA==.',['原宿']='原宿水儿:BAAALAADCgUIBQAAAA==.',['叁千']='叁千黎明:BAAALAAFFAIIAgAAAA==.',['古月']='古月山:BAABLAAFFH8JAAIQAAIIFRDnTgBsAAAQAAIIFRDnTgBsAAAAAA==.',['只影']='只影向谁:BAAALAADCggICAAAAA==.',['右走']='右走:BAAALAAECgEIAQAAAA==.',['右转']='右转右行:BAAALAADCgIIAgAAAA==.右转左行:BAAALAAECgYICgAAAA==.',['叶子']='叶子非花:BAABLAAECn8UAAIRAAYI9BYHPgBkAQARAAYI9BYHPgBkAQAAAA==.',['君陌']='君陌也:BAABLAAFFH8JAAINAAIImweHIgAmAAANAAIImweHIgAmAAAAAA==.',['吧唧']='吧唧:BAAALAAECgYIBwAAAA==.',['吮指']='吮指原味鸡丶:BAAALAAFFAMIBAAAAA==.',['命定']='命定的英雄:BAAALAAFFAIIAgAAAA==.',['命运']='命运:BAAALAAECgYIDAAAAA==.',['咖啡']='咖啡丿因:BAABLAAFFH8GAAIPAAYITgyvIAA+AQAPAAYITgyvIAA+AQAAAA==.',['咬你']='咬你就两口:BAABLAAFFH8FAAIXAAMI6hbxBQAAAQAXAAMI6hbxBQAAAQAAAA==.',['唐僧']='唐僧的胸毛:BAABLAAFFH8VAAMYAAUIHRoIDABRAQAYAAUIHRoIDABRAQAZAAEINQHSIAAsAAAAAA==.',['唤吾']='唤吾女皇大人:BAAALAAECgMIAwAAAA==.',['啾啾']='啾啾法:BAAALAADCggICAAAAA==.啾啾萨:BAAALAAFFAIIAgAAAA==.',['噬元']='噬元兽:BAAALAAECgYIBgAAAA==.',['团长']='团长缺德么:BAAALAADCgYIBgABLAAFFAMIDAABAIwbAA==.',['圣光']='圣光会忽悠你:BAAALAADCgIIAgAAAA==.',['墨無']='墨無痕:BAABLAAFFH8KAAIKAAIIAyTGVwCRAAAKAAIIAyTGVwCRAAAAAA==.',['夜幕']='夜幕丶晚风:BAAALAADCgMIAwAAAA==.',['夜深']='夜深:BAAALAAECgMIAwAAAA==.',['大发']='大发:BAAALAAFFAIIBAAAAA==.',['大富']='大富:BAAALAADCggICAAAAA==.',['大振']='大振:BAAALAAECgIIAgAAAA==.',['天宇']='天宇崖:BAAALAAECgYICwAAAA==.天宇瞎:BAACLAAFFH8HAAMEAAIIihaBOACfAAAEAAIIihaBOACfAAAFAAIIrgo5FQBgAAAsAAQKfx0AAwQACAiSGV5FAFECAAQACAiSGV5FAFECAAUAAgh8EHpgAEwAAAAA.',['天得']='天得一以淸:BAAALAADCgEIAQAAAA==.',['天灾']='天灾宝宝:BAAALAAECgQIBAAAAA==.',['天霜']='天霜梦影:BAAALAAECgMIAwAAAA==.',['太蔡']='太蔡了:BAABLAAFFH8KAAMaAAII8x7rEQCcAAAaAAII8x7rEQCcAAADAAIIag+nFgB0AAAAAA==.',['失魅']='失魅:BAAALAAFFAIIAgAAAA==.',['头上']='头上有鸡脚:BAAALAAECgYIDAAAAA==.',['奢华']='奢华的瞬间:BAAALAAECgIIAgAAAA==.',['奥术']='奥术洪流:BAABLAAFFH8KAAIOAAIIIA14TgCSAAAOAAIIIA14TgCSAAAAAA==.',['奶潮']='奶潮不能断:BAAALAAECgEIAQAAAA==.',['好咯']='好咯咯:BAABLAAFFH8GAAIQAAIIOSGvPwCoAAAQAAIIOSGvPwCoAAAAAA==.',['好家']='好家伙哦:BAAALAAFFAIIBAAAAA==.',['如果']='如果那是真的:BAAALAAFFAIIBAAAAA==.',['如烟']='如烟往事:BAAALAADCgcIBwAAAA==.',['妙梦']='妙梦渺踪:BAAALAAECgYICgAAAA==.',['妞丶']='妞丶快过来:BAABLAAFFH8HAAIBAAMIqRkpSgCUAAABAAMIqRkpSgCUAAAAAA==.',['妥妥']='妥妥的了:BAAALAADCgcIBwAAAA==.',['孙六']='孙六娘:BAAALAAFFAUIBAAAAA==.',['小丶']='小丶小毅:BAAALAAECgIIBAAAAA==.',['小力']='小力士:BAAALAADCggICAAAAA==.',['小叶']='小叶花:BAAALAAECgYIBwAAAA==.',['小啊']='小啊晓:BAAALAAECgYIBgAAAA==.',['小小']='小小纯洁:BAAALAAFFAIIAgAAAA==.',['小尛']='小尛娴:BAAALAADCggICAAAAA==.',['小巫']='小巫鱼:BAAALAAECgIIAgAAAA==.',['小满']='小满不是满满:BAAALAADCgMIAwAAAA==.',['小火']='小火法:BAAALAAECgMIBAAAAA==.',['小短']='小短裙:BAAALAAECggIDAAAAA==.',['小米']='小米:BAAALAAECgIIAgAAAA==.',['小美']='小美鑫丶:BAAALAAECgYIBgAAAA==.',['小薇']='小薇:BAAALAAFFAIIBAAAAA==.',['尐丶']='尐丶太阳:BAAALAAECggICAAAAA==.尐丶星星:BAABLAAFFH8GAAIBAAYIbxckLwBfAQABAAYIbxckLwBfAQAAAA==.',['尛懮']='尛懮尛:BAAALAADCgYIBgAAAA==.',['尤朵']='尤朵拉:BAAALAADCggICgAAAA==.',['尼马']='尼马烫啊:BAACLAAFFH8uAAIEAAYIKRgQGACtAQAEAAYIKRgQGACtAQAsAAQKf0YAAwQACAiZIbElAMgCAAQACAiZIbElAMgCAAUABwhEEIA3ABIBAAAA.',['屠尽']='屠尽日寇:BAABLAAFFH8SAAIDAAgIXRA4BgD3AQADAAgIXRA4BgD3AQAAAA==.',['左行']='左行左转:BAAALAAFFAEIAQAAAA==.',['帅气']='帅气大发:BAAALAAFFAIIBAAAAA==.',['希蜜']='希蜜:BAAALAAECgUIBQAAAA==.',['帕吉']='帕吉哥:BAABLAAFFH8RAAIQAAIIthinOQCNAAAQAAIIthinOQCNAAAAAA==.',['帕珠']='帕珠珠:BAAALAAECgYICwAAAA==.',['帝弑']='帝弑:BAAALAAECgYICwAAAA==.',['广之']='广之峰:BAAALAADCgYIBgAAAA==.',['庙小']='庙小妖风大:BAAALAAECgEIAQAAAA==.',['废小']='废小物:BAAALAAECgYIBgAAAA==.',['异度']='异度:BAABLAAFFH8NAAIOAAgIZiPHAQDlAgAOAAgIZiPHAQDlAgAAAA==.',['影子']='影子拉的好长:BAAALAAECgYIBgAAAA==.影子有毒:BAAALAAECgYIDQAAAA==.',['影舞']='影舞冲击:BAAALAADCgEIAQAAAA==.',['很爱']='很爱妳:BAABLAAFFH8MAAIFAAIIvg1TEwBmAAAFAAIIvg1TEwBmAAAAAA==.',['德努']='德努妮:BAABLAAFFH8GAAIVAAIIAAcWUQBTAAAVAAIIAAcWUQBTAAAAAA==.',['德彪']='德彪:BAAALAADCgYIAwAAAA==.',['心伤']='心伤奶爹:BAABLAAFFH8FAAIIAAII7BFUSwCWAAAIAAII7BFUSwCWAAAAAA==.心伤小萨满:BAABLAAFFH8FAAIQAAIIvgQsZwBaAAAQAAIIvgQsZwBaAAAAAA==.',['恶魔']='恶魔青豆:BAAALAAFFAIIAgAAAA==.',['悼言']='悼言:BAAALAAECggICAAAAA==.',['慕艾']='慕艾:BAABLAAFFH8KAAMHAAMIxhXhGACoAAAHAAIIAR/hGACoAAAKAAMIfBVMfQBgAAAAAA==.',['懒德']='懒德变熊:BAAALAADCgIIAgAAAA==.',['我家']='我家糊糊:BAAALAAECgUIBQAAAA==.',['我是']='我是夏夏吖丶:BAAALAAECgYIBgAAAA==.我是来叮的:BAAALAAECgEIAQAAAA==.',['战上']='战上风胡总:BAABLAAFFH8VAAIIAAYI6iDdCAADAgAIAAYI6iDdCAADAgAAAA==.',['战神']='战神薇:BAAALAAFFAIIAgAAAA==.',['戦死']='戦死啲丨眫子:BAABLAAFFH8FAAIRAAIIbBlaTwBFAAARAAIIbBlaTwBFAAAAAA==.',['戳戳']='戳戳龙:BAAALAAECggICAAAAA==.',['戴戴']='戴戴叭:BAABLAAFFH8GAAIMAAIIOxEnIAB9AAAMAAIIOxEnIAB9AAABLAAFFAYIEQAEAEQbAA==.',['把酒']='把酒祝东风:BAAALAAECggIBAAAAA==.把酒赴清欢:BAAALAAECgUIBQAAAA==.',['抚一']='抚一曲天涯:BAABLAAECn8YAAMBAAgI4BovVgDuAQABAAcImxwvVgDuAQAJAAIIshRdLACMAAAAAA==.',['拆你']='拆你棒骨:BAAALAAECgYIDgAAAA==.',['拈花']='拈花把酒:BAAALAADCgYIBgAAAA==.',['揍你']='揍你开车:BAABLAAECn8pAAMKAAgIphgcLwAAAgAKAAgIphgcLwAAAgAHAAYIJA8oZAAwAQABLAAFFAYIJgABAHkXAA==.',['揪揪']='揪揪小揪揪:BAAALAAECgMIAwAAAA==.',['搞个']='搞个慕斯玩玩:BAABLAAFFH8NAAIbAAMIOwqbHgDHAAAbAAMIOwqbHgDHAAAAAA==.',['摸鱼']='摸鱼仔:BAAALAAECgUIBQAAAA==.',['故里']='故里有长安:BAAALAAECgMIAwAAAA==.',['旌旗']='旌旗十万:BAAALAADCgQIBAAAAA==.',['无毁']='无毁的湖光:BAABLAAFFH8GAAIMAAIIsgT5LABhAAAMAAIIsgT5LABhAAAAAA==.',['早坂']='早坂爱:BAAALAAECgUIBQAAAA==.',['星小']='星小狐:BAAALAAECgYIDAAAAA==.',['是韭']='是韭菜啊:BAAALAAECgEIAQAAAA==.',['晃荡']='晃荡:BAAALAAFFAIIAgAAAA==.',['晓华']='晓华:BAAALAAECgIIAgAAAA==.',['晚夜']='晚夜微雨:BAAALAAECgYIDAAAAA==.',['晨曦']='晨曦:BAAALAAECgIIAgAAAA==.',['普逗']='普逗众生:BAAALAAFFAMIAwAAAA==.',['晴天']='晴天球球:BAAALAAECgYIBgAAAA==.',['暴怒']='暴怒恒星:BAAALAADCgMIAwAAAA==.',['暴躁']='暴躁小土豆:BAAALAAECgYICgAAAA==.',['月夜']='月夜丶忧伤:BAACLAAFFH8IAAIIAAII4CW/IADOAAAIAAII4CW/IADOAAAsAAQKfxcAAggACAi9I68UACQDAAgACAi9I68UACQDAAAA.',['月影']='月影丨:BAAALAAECgYICwAAAA==.',['有钱']='有钱不粘鱼:BAACLAAFFH8GAAIQAAIIChq0NQCVAAAQAAIIChq0NQCVAAAsAAQKfx0AAhAACAgEIwYOAPcCABAACAgEIwYOAPcCAAAA.',['木有']='木有无敌:BAAALAAECgYICgAAAA==.木有碎片:BAAALAAECgEIAQAAAA==.',['李米']='李米安:BAAALAAECgYIDAAAAA==.',['李阿']='李阿不:BAAALAAECgMIBAAAAA==.',['极度']='极度冰焰:BAAALAAECgEIAQAAAA==.',['柠檬']='柠檬:BAAALAAFFAYIAgAAAA==.',['格格']='格格术:BAAALAAECgEIAQAAAA==.格格猎:BAAALAAFFAIIAwAAAA==.',['梦栖']='梦栖青桫:BAAALAADCgYIBgAAAA==.',['梦见']='梦见故面:BAAALAAECgYIBwAAAA==.',['榆树']='榆树大冰峰丶:BAAALAAECgYIBgAAAA==.',['欧神']='欧神:BAAALAAECggICAAAAA==.',['歡喜']='歡喜自在:BAAALAAECgcICwAAAA==.',['沁心']='沁心凉夏丶:BAAALAAECgMIBAAAAA==.',['沉默']='沉默的桃子:BAAALAAECgEIAQAAAA==.',['沐浴']='沐浴龙血:BAAALAAFFAIIBAAAAA==.',['法影']='法影:BAAALAADCgQIBAAAAA==.',['泠泠']='泠泠哀弦:BAAALAAECgQIBAAAAA==.',['泡泡']='泡泡牧风:BAAALAAECgYIEgAAAA==.',['波塞']='波塞冬丶:BAAALAAECgcIEQAAAA==.',['海蓝']='海蓝时见鲸丶:BAABLAAFFH8GAAIMAAMIiAa7FgCgAAAMAAMIiAa7FgCgAAAAAA==.',['深入']='深入暗影:BAAALAAECgQIBwAAAA==.',['混子']='混子:BAAALAAECgYIDAAAAA==.',['灬空']='灬空城灬:BAACLAAFFH8GAAIBAAIIgQiZTQCFAAABAAIIgQiZTQCFAAAsAAQKfywAAgEACAh8GAc0AGsCAAEACAh8GAc0AGsCAAAA.',['灬芽']='灬芽间灬:BAAALAAECgIIAgAAAA==.',['灬路']='灬路遇尘埃灬:BAAALAAFFAIIAgAAAA==.',['灰烬']='灰烬觉醒:BAAALAAECgIIAwAAAA==.',['灵灵']='灵灵小宝贝:BAABLAAFFH8KAAIFAAMIkhB9DQBkAAAFAAMIkhB9DQBkAAAAAA==.',['灼眼']='灼眼阿苏:BAAALAAECgYICAAAAA==.',['热血']='热血沸腾:BAAALAAECgYICgAAAA==.',['热闹']='热闹丶:BAAALAAECgYICgAAAA==.',['烽火']='烽火洋流:BAAALAAECgMIAwAAAA==.',['然然']='然然:BAABLAAFFH8GAAIPAAYI1x7wEAC5AQAPAAYI1x7wEAC5AQAAAA==.',['煮茶']='煮茶听雪:BAAALAAECgMIAwAAAA==.',['熊猫']='熊猫图腾:BAAALAAFFAIIAgAAAA==.熊猫是熊:BAAALAAECgUIBQAAAA==.',['燃烧']='燃烧军团爪牙:BAAALAAECgMIAwAAAA==.',['爱吃']='爱吃大米饭:BAAALAAECgYIBgAAAA==.',['牛晓']='牛晓德:BAAALAAFFAIIBAAAAA==.',['狂暴']='狂暴戰丶:BAAALAAECgYIBgAAAA==.',['狂踪']='狂踪剑影:BAAALAAFFAIIAgAAAA==.',['独落']='独落丶相思泪:BAAALAADCggICAAAAA==.',['猪橘']='猪橘橘:BAAALAAECgIIAgAAAA==.',['玉米']='玉米地吃过亏:BAAALAAECgQIBQAAAA==.',['珍妮']='珍妮玛飘逸:BAAALAAECgYICQAAAA==.珍妮玛黛劲:BAAALAAECgcIDQABLAAFFAgIBgATAOIhAA==.',['球七']='球七霸:BAAALAAFFAIIBAAAAA==.',['球三']='球三霸:BAAALAAECgcIEAAAAA==.',['球二']='球二霸:BAAALAAFFAIIAgAAAA==.',['球五']='球五霸:BAAALAAECgYIDgAAAA==.',['球六']='球六霸:BAAALAAECgYIDAAAAA==.',['球四']='球四霸:BAAALAAFFAIIAgAAAA==.',['球球']='球球:BAAALAAECgEIAQAAAA==.',['球霸']='球霸:BAAALAAECggIEQAAAA==.',['琦丶']='琦丶玉:BAAALAAECgQIBAAAAA==.',['甜甜']='甜甜的丶:BAAALAAECgYICgAAAA==.',['甜酒']='甜酒:BAAALAADCgcIBwAAAA==.',['生命']='生命的缚誓者:BAAALAADCggICAAAAA==.',['白多']='白多橘少:BAAALAAECgIIAgAAAA==.',['盐酥']='盐酥鸡:BAABLAAFFH8JAAIaAAMIlxHTEACtAAAaAAMIlxHTEACtAAAAAA==.',['瞌睡']='瞌睡骑士:BAAALAAECgIIAgAAAA==.',['瞬狱']='瞬狱戕魂:BAABLAAFFH8KAAIJAAQIkgxtAQAbAQAJAAQIkgxtAQAbAQAAAA==.',['矮子']='矮子乐灬:BAAALAADCgEIAQAAAA==.',['矮粗']='矮粗壮:BAABLAAFFH8IAAIQAAIIBxhWOACQAAAQAAIIBxhWOACQAAAAAA==.',['神之']='神之归来:BAAALAADCgYIBgAAAA==.',['神装']='神装带盾:BAAALAAECgMIAwAAAA==.',['秋冷']='秋冷了玥光:BAAALAAECgYIBgABLAAFFAIIDgARAF4cAA==.',['积积']='积积丶阳阳德:BAAALAADCgEIAQAAAA==.',['程心']='程心:BAAALAAECgYICwAAAA==.',['穷山']='穷山恶水:BAAALAADCgYIBgAAAA==.',['童话']='童话大王:BAAALAAECgEIAQAAAA==.',['等雾']='等雾散了:BAAALAADCgMIAwAAAA==.',['筱弑']='筱弑:BAABLAAFFH8IAAIGAAMIcAY4PAC5AAAGAAMIcAY4PAC5AAAAAA==.',['糖糖']='糖糖不甜:BAAALAAECgUIBQAAAA==.',['繁星']='繁星落幕:BAAALAAECgUIBQAAAA==.',['绾青']='绾青丝挽情思:BAABLAAFFH8LAAIEAAMIWR8uJgDGAAAEAAMIWR8uJgDGAAAAAA==.',['胆南']='胆南丶星:BAAALAAFFAEIAQAAAA==.',['背弃']='背弃死亡:BAABLAAFFH8GAAIGAAII1hONWQCbAAAGAAII1hONWQCbAAAAAA==.',['背着']='背着财神跳舞:BAAALAAECgUIBQAAAA==.',['芙柔']='芙柔桑克斯:BAAALAAFFAIIBAAAAA==.',['芝麻']='芝麻酥糖:BAABLAAFFH8GAAMUAAYIERfDFgAoAQAUAAUIVRbDFgAoAQAVAAEIZxCSWQA+AAAAAA==.',['芥末']='芥末薯片:BAABLAAFFH8GAAIVAAYI4h18DwDNAQAVAAYI4h18DwDNAQAAAA==.',['芳泽']='芳泽堇:BAABLAAFFH8HAAIGAAQI+B5tGAB2AQAGAAQI+B5tGAB2AQAAAA==.',['荣耀']='荣耀即生命:BAAALAADCgEIAQAAAA==.',['莉莉']='莉莉丝:BAAALAAECgQIBAAAAA==.',['莫乱']='莫乱的慌:BAAALAAECgYICwAAAA==.',['莫再']='莫再刁丶:BAAALAAFFAEIAQAAAA==.',['萨尓']='萨尓黑我无敌:BAAALAAFFAIIAgABLAAFFAMIDAABAIwbAA==.',['萨里']='萨里安:BAAALAAFFAIIAwAAAA==.',['蛋总']='蛋总经纪人:BAAALAAECgYIBgAAAA==.',['蛋蛋']='蛋蛋的圣光:BAABLAAFFH8GAAIIAAYIyyG/DgDQAQAIAAYIyyG/DgDQAQAAAA==.',['血与']='血与沙:BAAALAAECgIIAgAAAA==.',['血腥']='血腥丶盒:BAABLAAFFH8FAAIKAAII5RCuXgCMAAAKAAII5RCuXgCMAAAAAA==.',['被召']='被召唤的死骑:BAAALAAFFAIIAwAAAA==.',['西江']='西江月:BAAALAAECgYIBgAAAA==.',['见血']='见血才是目的:BAAALAAECgQIBAAAAA==.',['诅咒']='诅咒甲方:BAACLAAFFH80AAMBAAcILiDHCQAmAgABAAcILiDHCQAmAgACAAII2BSLFQCZAAAsAAQKfyoAAwEACAinISYXAPwCAAEACAinISYXAPwCAAIABAjaH3dKAEgBAAAA.',['误导']='误导开怪假死:BAAALAADCgEIAQAAAA==.',['请甲']='请甲方洗脚:BAACLAAFFH8TAAMPAAMIjAZEOwBmAAAPAAMIjAZEOwBmAAAQAAII7QvNWwBjAAAsAAQKfysAAhAABwikGBVWAOIBABAABwikGBVWAOIBAAEsAAUUBwg0AAEALiAA.',['豆五']='豆五:BAAALAAECgIIAgAAAA==.',['豆十']='豆十四:BAAALAAECgcIEAAAAA==.',['豆四']='豆四:BAABLAAECn8YAAIIAAcIKiItMQCtAgAIAAcIKiItMQCtAgAAAA==.',['豹变']='豹变:BAAALAAECgYIBgAAAA==.',['貌似']='貌似隐藏职业:BAAALAAECgYIBgAAAA==.',['赵梦']='赵梦:BAAALAAECgQIBAAAAA==.',['起锅']='起锅烧油丶:BAAALAAECgUICgAAAA==.',['跪着']='跪着灬唱征服:BAABLAAFFH8KAAIOAAQI4BdbPADjAAAOAAQI4BdbPADjAAAAAA==.',['跳跳']='跳跳怪:BAAALAAECgYIBgAAAA==.',['身板']='身板超级硬核:BAAALAAFFAIIAgAAAA==.',['转瞬']='转瞬葒颜:BAAALAAECgEIAQAAAA==.',['轰咔']='轰咔嚓雷:BAAALAAECgIIAgAAAA==.',['还我']='还我氤氲之息:BAABLAAFFH8LAAIGAAQIOxcfTgDzAAAGAAQIOxcfTgDzAAAAAA==.',['迪克']='迪克丶牛仔:BAACLAAFFH8SAAIGAAMIihZMKgDwAAAGAAMIihZMKgDwAAAsAAQKfxQAAgYACAjBGXNaAEECAAYACAjBGXNaAEECAAAA.',['迪凯']='迪凯:BAAALAAFFAIIAgAAAA==.',['追憶']='追憶思雨:BAAALAADCggICQAAAA==.',['那个']='那个奶森:BAAALAAECgYIBgAAAA==.',['邪能']='邪能魅影:BAAALAADCgEIAQAAAA==.',['酷橙']='酷橙:BAAALAAECgYIBgAAAA==.',['铁岭']='铁岭大呲花:BAABLAAFFH8IAAMcAAQIZgqXAwBrAAAcAAMIEQqXAwBrAAAMAAEIZAsgKgA9AAAAAA==.',['锦绣']='锦绣荒年:BAAALAADCgQIBAAAAA==.',['闪电']='闪电侠刘波:BAAALAAECgUIBwAAAA==.',['队长']='队长灬是我呀:BAAALAAECgEIAQAAAA==.',['阿巴']='阿巴阿巴:BAABLAAFFH8GAAIFAAIIVgO9GgAfAAAFAAIIVgO9GgAfAAAAAA==.',['阿溪']='阿溪:BAABLAAFFH8FAAIYAAUIsh3GCwBVAQAYAAUIsh3GCwBVAQAAAA==.',['陳不']='陳不住气丶:BAAALAAECgQIBAAAAA==.',['雨霏']='雨霏文:BAAALAAFFAIIBAAAAA==.',['雲程']='雲程灬:BAAALAAECggICAAAAA==.',['霜刃']='霜刃未曾试:BAAALAADCgEIAQAAAA==.',['青口']='青口张学友:BAABLAAFFH8IAAIFAAMIBBBoCAC4AAAFAAMIBBBoCAC4AAAAAA==.',['风光']='风光:BAAALAAECgMIAwAAAA==.',['风暴']='风暴战神:BAAALAAFFAIIAgAAAA==.',['飓风']='飓风:BAABLAAFFH8GAAIQAAII7AVCbwBMAAAQAAII7AVCbwBMAAAAAA==.',['飘逸']='飘逸凌风:BAABLAAFFH8IAAIKAAIIRRbVkABFAAAKAAIIRRbVkABFAAAAAA==.',['飘雪']='飘雪兜风:BAACLAAFFH8MAAIOAAQISxBUPQCiAAAOAAQISxBUPQCiAAAsAAQKfxkAAg4ABgjMI0UdAMEBAA4ABgjMI0UdAMEBAAAA.',['飞起']='飞起的大锤:BAAALAAECgYICgAAAA==.',['骑无']='骑无敌:BAAALAAECgcIDQAAAA==.',['黑丶']='黑丶眼圈罒:BAAALAAECggICwAAAA==.',['黑夜']='黑夜信仰:BAAALAAECgYIBgAAAA==.',['黑妞']='黑妞:BAAALAAECgEIAgAAAA==.',['黑浪']='黑浪:BAAALAADCgIIAgAAAA==.',['龍潾']='龍潾:BAABLAAECn8UAAIMAAYIEhp9HABeAQAMAAYIEhp9HABeAQAAAA==.',['龙墨']='龙墨墨呦:BAABLAAFFH8JAAMHAAIILRnrJQB8AAAHAAIILw/rJQB8AAAKAAEIvB6GgQBcAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end