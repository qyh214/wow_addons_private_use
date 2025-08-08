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
 local lookup = {'Paladin-Retribution','Shaman-Restoration','Shaman-Elemental','Rogue-Assassination','Priest-Holy','Unknown-Unknown','Hunter-BeastMastery','Warlock-Affliction','Warlock-Destruction','Mage-Fire','Druid-Balance','Druid-Restoration','DeathKnight-Blood','DeathKnight-Unholy','Mage-Frost','Monk-Windwalker','Warlock-Demonology','DemonHunter-Havoc','Monk-Mistweaver','Druid-Guardian','Warrior-Arms','Priest-Discipline','Priest-Shadow','Paladin-Protection','Paladin-Holy','Rogue-Outlaw','Monk-Brewmaster','Evoker-Devastation','Evoker-Preservation','Hunter-Marksmanship',}; local provider = {region='CN',realm='蓝龙军团',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ad='Addiction:BAACKgAFFH8TAAIBAAQIbiUPDwAYAQABAAQIbiUPDwAYAQAqAAQKfxEAAgEACAhOJHxDACUCAAEACAhOJHxDACUCAAAA.',Al='Alpha:BAAAKgAFFAQIAwAAAA==.',Ca='Caiono:BAACKgAFFH8bAAICAAQIcRyeIwDpAAACAAQIcRyeIwDpAAAqAAQKfxYAAwIACAiXE3FAAHUBAAIACAiXE3FAAHUBAAMAAQiqAkKCABYAAAAA.',Ce='Ceruledge:BAAAKgAFFAgIBAAAAA==.',Co='Corrine:BAAAKgADCggICAAAAA==.',Dk='Dkl:BAAAKgAECgQIBAAAAA==.',Do='Doxa:BAAAKgAECgcIDAAAAA==.',Fi='Fionasit:BAAAKgAECggIDgAAAA==.',Ho='Hope:BAACKgAFFH8IAAIEAAgITRVDAwBxAgAEAAgITRVDAwBxAgAqAAQKfxUAAgQACAg6EXoNAE8BAAQACAg6EXoNAE8BAAAA.',Jo='Jolin:BAABKgAFFH8GAAIFAAYIGwZFEADKAAAFAAYIGwZFEADKAAAAAA==.',Ju='Judy:BAAAKgAECgcIDwAAAA==.Judyz:BAAAKgAECggIDwAAAA==.',My='Mynameispp:BAAAKgAFFAIIAwAAAA==.',No='Nobrains:BAAAKgAECgUIBQABKgAFFAYIBAAGAAAAAA==.',Pl='Pleasure:BAABKgAFFH8GAAIFAAYI3AUyDwDYAAAFAAYI3AUyDwDYAAAAAA==.',Sa='Sagergesaer:BAAAKgAFFAIIAwAAAA==.',Si='Sideanilafoi:BAAAKgAECgYICQAAAA==.',Sm='Smartmoon:BAAAKgAECgQICQAAAA==.',Su='Supersonic:BAABKgAFFH8PAAIHAAMIMBxnJgDsAAAHAAMIMBxnJgDsAAAAAA==.',Th='Thunder:BAAAKgAECggIEgAAAA==.',Ug='Uglybeauty:BAABKgAFFH8GAAMIAAQI8BR8CQDeAAAIAAQIUhB8CQDeAAAJAAIIMRYEJgB4AAABKgAFFAgIDQAKACMRAA==.',Wa='Wadaxi:BAAAKgAECgEIAQAAAA==.',Zf='Zfocean:BAAAKgAFFAQIAgAAAA==.',['一二']='一二零:BAAAKgAFFAQIAwAAAA==.',['一眼']='一眼杤年:BAAAKgAECgcICAAAAA==.',['一碰']='一碰就倒:BAABKgAECn8VAAMLAAgIqAsjbwAOAQALAAcIEQ0jbwAOAQAMAAcIjApzTwDPAAAAAA==.',['一辈']='一辈子:BAAAKgADCggICAAAAA==.',['三碗']='三碗不过岗:BAAAKgAECgMIAwAAAA==.',['不灭']='不灭意志:BAAAKgADCggICAAAAA==.',['丶隔']='丶隔壁老王:BAAAKgAECgUIBQAAAA==.',['乌帕']='乌帕:BAAAKgAECgQIBAAAAA==.',['乌漆']='乌漆嘛黑:BAABKgAFFH8GAAINAAYIrwaLCgDaAAANAAYIrwaLCgDaAAAAAA==.',['乌瑞']='乌瑞亚斯:BAAAKgAECgYIBgAAAA==.',['乔木']='乔木:BAAAKgAECgYIDQAAAA==.',['乜精']='乜精钢:BAAAKgAECgUICQAAAA==.',['云绝']='云绝妙思:BAAAKgADCggICAAAAA==.',['云飞']='云飞轻扬:BAAAKgAFFAIIAwAAAA==.',['亚特']='亚特尔斯:BAAAKgADCggICAAAAA==.',['今生']='今生:BAAAKgAECggIDAAAAA==.',['他朝']='他朝:BAAAKgAECgEIAQAAAA==.',['仴夜']='仴夜:BAAAKgAECgcIDgAAAA==.',['伊俐']='伊俐丹丶怒风:BAAAKgADCggICAAAAA==.',['伊力']='伊力丹:BAAAKgAECgEIAQAAAA==.',['但丁']='但丁说灬:BAAAKgAECgcIBwAAAA==.',['低调']='低调的杀手:BAAAKgAECgcICgAAAA==.',['依然']='依然那么牛:BAAAKgAECgUIBQAAAA==.',['偌只']='偌只如初見:BAABKgAECn8ZAAIEAAgIICH8EAAcAgAEAAgIICH8EAAcAgAAAA==.',['克丽']='克丽丝蒂:BAAAKgADCgMIAwAAAA==.',['全体']='全体起立:BAAAKgAECgcIBwAAAA==.',['八万']='八万:BAAAKgAFFAYIBAAAAA==.',['八条']='八条:BAABKgAFFH8GAAILAAYIGBZxGwA+AQALAAYIGBZxGwA+AQAAAA==.',['冬幕']='冬幕节咭安娜:BAAAKgADCggICAAAAA==.',['冰帝']='冰帝大西瓜:BAABKgAFFH8GAAIOAAYIgA+MGABZAQAOAAYIgA+MGABZAQAAAA==.',['冰灵']='冰灵之魂:BAABKgAFFH8IAAIPAAQIrRzgBgD3AAAPAAQIrRzgBgD3AAAAAA==.',['凄凉']='凄凉小妖:BAAAKgADCgIIAgAAAA==.',['凤凰']='凤凰棠:BAAAKgAECggICQAAAA==.',['刘大']='刘大江:BAAAKgAFFAgIBAAAAA==.',['刘浪']='刘浪:BAABKgAFFH8GAAIQAAYI8QNoCwDZAAAQAAYI8QNoCwDZAAAAAA==.',['别打']='别打崽崽啦:BAAAKgAFFAgIBAAAAA==.',['前世']='前世:BAAAKgAECgEIAgAAAA==.',['却冬']='却冬:BAAAKgAECgUIBgAAAA==.',['原味']='原味少女胖次:BAAAKgAECggIEAAAAA==.',['司空']='司空震:BAABKgAECn8kAAICAAgIchIJRgBgAQACAAgIchIJRgBgAQAAAA==.',['吃有']='吃有文化不亏:BAAAKgADCgMIAwAAAA==.',['吃没']='吃没文化亏:BAABKgAFFH8FAAIBAAUIRw9DRwDfAAABAAUIRw9DRwDfAAAAAA==.吃没文化的亏:BAAAKgADCgYIBgAAAA==.',['同你']='同你博过:BAAAKgAECgUIBQAAAA==.',['名侦']='名侦探兔美:BAABKgAFFH8oAAQRAAgIfhpZCQDtAAAJAAUIvBo5FwBJAQARAAUINxdZCQDtAAAIAAQI0w4DFgB4AAAAAA==.',['呜喵']='呜喵王啊:BAAAKgAECgUIBQAAAA==.',['呼啸']='呼啸而过:BAAAKgAECgMIBAAAAA==.',['咿利']='咿利丹丶怒風:BAABKgAECn8XAAISAAgIxRQOLAC1AQASAAgIxRQOLAC1AQAAAA==.',['哥布']='哥布美:BAABKgAFFH8IAAILAAgImRjCBQBeAgALAAgImRjCBQBeAgAAAA==.',['啊爾']='啊爾薩斯:BAAAKgADCggICAAAAA==.',['喜欢']='喜欢猫猫:BAABKgAECn8UAAIJAAgI+SAVDACKAgAJAAgI+SAVDACKAgAAAA==.',['喪彪']='喪彪:BAAAKgADCggICAAAAA==.',['四重']='四重梦境:BAAAKgAECgEIAQAAAA==.',['団子']='団子:BAACKgAFFH8ZAAMQAAQIgho6EADjAAAQAAMIgho6EADjAAATAAEIAACAGgAAAAAqAAQKf1sAAxMACAg+Ix8EAMICABMACAg+Ix8EAMICABAACAgPIdgLAI8CAAAA.',['圆圆']='圆圆的大肚纸:BAABKgAECn8WAAIUAAcIRQ3xGwC/AAAUAAcIRQ3xGwC/AAAAAA==.',['圣光']='圣光小女:BAAAKgAECggIDwAAAA==.',['地图']='地图鱼:BAAAKgAFFAIIAgAAAA==.',['多少']='多少信一点:BAAAKgADCggICAAAAA==.',['夜夜']='夜夜相思:BAAAKgAECgIIAwAAAA==.',['夜长']='夜长空:BAAAKgAECggICgAAAA==.',['大头']='大头儿之怒:BAABKgAFFH8GAAIVAAYIig7zCADdAAAVAAYIig7zCADdAAAAAA==.',['大白']='大白狗:BAAAKgAECgcICgAAAA==.',['大罗']='大罗顾小桑:BAAAKgAECggIEgAAAA==.',['大高']='大高个:BAAAKgAFFAIIAwAAAA==.大高個:BAAAKgAECgYICgAAAA==.',['大髙']='大髙个:BAAAKgADCgIIAgAAAA==.',['天使']='天使下了凡:BAABKgAFFH8NAAIJAAMIewiCNACdAAAJAAMIewiCNACdAAAAAA==.天使祝福:BAAAKgADCgQIBAAAAA==.',['天意']='天意:BAAAKgAECgcIBwAAAA==.',['天灵']='天灵灵土灵灵:BAABKgAECn8WAAICAAYIAhXVWAAhAQACAAYIAhXVWAAhAQAAAA==.',['头头']='头头之怒:BAABKgAFFH8IAAMJAAQI5hIJEwDZAAAJAAMI5hIJEwDZAAAIAAEIAAAYJAAAAAAAAA==.',['奈克']='奈克赛斯:BAACKgAFFH8bAAISAAQI2x4VIQD9AAASAAQI2x4VIQD9AAAqAAQKf10AAhIACAgEJLoHANECABIACAgEJLoHANECAAAA.',['女子']='女子无才:BAAAKgADCggICAAAAA==.',['好大']='好大夫:BAAAKgAECgEIAQAAAA==.',['如朕']='如朕躬亲:BAAAKgAECggICAAAAA==.',['如果']='如果我道歉:BAAAKgAECgcICgAAAA==.',['威小']='威小灰:BAAAKgAECgMIAwAAAA==.',['娃娃']='娃娃:BAAAKgAECgEIAQAAAA==.',['守护']='守护者提尔:BAAAKgAFFAMIAwAAAA==.守护者阿洛迪:BAABKgAFFH8KAAQWAAYINxn6DwDaAAAWAAQIjhP6DwDaAAAXAAIIsCJrEQDWAAAFAAQIMAbfEQCyAAAAAA==.',['安娜']='安娜贝丽:BAACKgAFFH81AAILAAgIXxa4BQBKAQALAAgIXxa4BQBKAQAqAAQKfy0AAgsACAhSI14dAFkCAAsACAhSI14dAFkCAAAA.',['宓惠']='宓惠:BAABKgAFFH8WAAMYAAgIAA+3BQCbAQAYAAgIAA+3BQCbAQABAAQIowRCaQCaAAAAAA==.',['射津']='射津津:BAABKgAFFH8GAAIHAAYIMQVFEgAEAQAHAAYIMQVFEgAEAQAAAA==.',['小光']='小光:BAABKgAFFH8NAAIFAAMIsiPAFAAOAQAFAAMIsiPAFAAOAQAAAA==.',['小小']='小小德爱:BAAAKgADCgQIBAAAAA==.',['小李']='小李飞刀:BAABKgAECn8ZAAIZAAgIuxMDGAClAQAZAAgIuxMDGAClAQAAAA==.',['小狗']='小狗快跑:BAABKgAFFH8IAAMZAAQIRBTLDgCIAAAZAAQIRBTLDgCIAAABAAIISB9SSwBVAAAAAA==.',['小艾']='小艾芙:BAAAKgAECgYIBwAAAA==.',['小黑']='小黑哟:BAAAKgAECgcICwAAAA==.',['尼莫']='尼莫玛纳:BAAAKgAECgMIAwAAAA==.',['屁屁']='屁屁猪:BAAAKgADCgEIBAAAAA==.',['差不']='差不多先生灬:BAAAKgAECgIIAgAAAA==.差不多裂人:BAAAKgADCgQIBAAAAA==.',['帅的']='帅的不敢出门:BAAAKgAECgMIAwAAAA==.',['师傅']='师傅不要这样:BAAAKgAECgUIBQAAAA==.',['师斤']='师斤手:BAAAKgAECgUICAAAAA==.',['希尔']='希尔伍德公园:BAAAKgAFFAYIBAAAAA==.希尔娜娜斯:BAAAKgAECgcIBgAAAA==.',['希望']='希望哥:BAAAKgAECgQIBAAAAA==.',['希格']='希格文:BAABKgAFFH8LAAMFAAYIpRl+FgABAQAFAAUIvxd+FgABAQAXAAYIcxaBFgCwAAAAAA==.',['希瓦']='希瓦男爵:BAAAKgAECgQIBAAAAA==.',['德国']='德国妮子:BAAAKgAFFAIIAgABKgAFFAgICgAHAPobAA==.',['心之']='心之冷夜:BAABKgAFFH8NAAIVAAMIehbRFADdAAAVAAMIehbRFADdAAAAAA==.',['念念']='念念不忘:BAAAKgAECgcIDwAAAA==.',['恶魔']='恶魔领主:BAAAKgAECgMIAwAAAA==.',['悠悠']='悠悠残月:BAABKgAECn8cAAMOAAgIzhwtJAD6AQAOAAgIzhwtJAD6AQANAAEIEwXxbAAbAAAAAA==.',['惟名']='惟名狸希:BAABKgAFFH8FAAITAAUIpwpXGAC6AAATAAUIpwpXGAC6AAABKgAFFAgICQABAKIYAA==.',['戀愛']='戀愛:BAAAKgAECggIEAAAAA==.',['戀蕊']='戀蕊:BAAAKgAECgYICQAAAA==.',['戀魚']='戀魚:BAAAKgAECgYIDQAAAA==.',['成就']='成就一牧:BAAAKgADCggIFwAAAA==.成就一萨:BAAAKgAECgQIBAAAAA==.成就壹生:BAAAKgADCgUIBQAAAA==.',['手把']='手把肉:BAABKgAFFH8FAAILAAUIXhYLGgBJAQALAAUIXhYLGgBJAQAAAA==.',['扎昆']='扎昆:BAAAKgAFFAIIAgAAAA==.',['折翼']='折翼的圣光:BAAAKgAECgQIBgAAAA==.折翼的狐狸:BAABKgAECn8ZAAIHAAgIQBk8PAC0AQAHAAgIQBk8PAC0AQAAAA==.',['拉文']='拉文霍德公爵:BAABKgAECn8hAAMEAAgI6RMzFwC0AQAEAAgI6RMzFwC0AQAaAAIIsANWIgAWAAAAAA==.',['拓跋']='拓跋砡儿:BAAAKgAECgYICQABKgAECggIHAAOAM4cAA==.',['捞斯']='捞斯特:BAAAKgAECggICAAAAA==.',['斯托']='斯托姆石锤:BAAAKgAECggICAAAAA==.',['无光']='无光之刃:BAAAKgADCggICgAAAA==.',['无尺']='无尺灬:BAAAKgAECgEIAQAAAA==.',['明俊']='明俊:BAAAKgAECggIDgAAAA==.',['星野']='星野梦夏树:BAAAKgAECgcICgAAAA==.',['普里']='普里斯特:BAAAKgAECgUICgAAAA==.',['暗戳']='暗戳戳:BAAAKgAECggIDQAAAA==.',['月亮']='月亮花:BAAAKgAECggIDQAAAA==.',['月夜']='月夜雪纷飞:BAAAKgAECggIEwABKgAECggIHAAOAM4cAA==.',['月沐']='月沐:BAAAKgAECgQICAAAAA==.',['木瓜']='木瓜:BAAAKgAECgYICgAAAA==.',['李恭']='李恭梓:BAAAKgADCgIIAgAAAA==.',['枫小']='枫小筱:BAAAKgADCggIDQAAAA==.',['枫舞']='枫舞灬晴空:BAAAKgAFFAQIBAAAAA==.',['柏恩']='柏恩泽:BAAAKgADCgIIAgAAAA==.',['桂言']='桂言葉:BAAAKgADCggICAAAAA==.',['残血']='残血:BAAAKgAECgUIBQAAAA==.',['毛咪']='毛咪:BAAAKgAECgYIBwAAAA==.',['氷鎖']='氷鎖:BAAAKgAECggICAAAAA==.',['永胤']='永胤:BAACKgAFFH8KAAIHAAYI+hvoCwCxAQAHAAYI+hvoCwCxAQAqAAQKfxQAAgcACAhHJLwPAMICAAcACAhHJLwPAMICAAAA.',['沐月']='沐月:BAABKgAECn8VAAMTAAgI1A8WJwBXAQATAAgI1A8WJwBXAQAbAAgIoQ1TCgAgAQAAAA==.',['沐瞳']='沐瞳:BAAAKgADCgUIBQAAAA==.',['沐龙']='沐龙:BAABKgAECn8VAAMcAAgIaxHWKQBsAQAcAAgIaxHWKQBsAQAdAAQIYREFFQCYAAAAAA==.',['波雅']='波雅丶汉库克:BAAAKgADCggICAAAAA==.',['流浪']='流浪青春:BAAAKgADCgEIAQAAAA==.',['浪荡']='浪荡天涯:BAAAKgADCggIGAAAAA==.',['浮戌']='浮戌:BAAAKgAECgYICQAAAA==.',['海海']='海海:BAAAKgAECgEIAgAAAA==.',['海盗']='海盗旗他哥:BAAAKgADCgEIAQAAAA==.',['清水']='清水希语:BAAAKgADCgEIAQAAAA==.',['渴望']='渴望偷条野猪:BAACKgAFFH8RAAMHAAQIpAdiHwClAAAHAAQIpAdiHwClAAAeAAMI1wJ+JwA/AAAqAAQKfxgAAgcABAifFSYuABMBAAcABAifFSYuABMBAAAA.',['炎爆']='炎爆羊肉拌面:BAAAKgAECgUICgAAAA==.',['炫蓝']='炫蓝之巫:BAAAKgAECgcIBwAAAA==.炫蓝之森:BAAAKgAECgIIAgAAAA==.',['熊了']='熊了个猫:BAAAKgAECggIEgAAAA==.',['熟术']='熟术叔叔:BAAAKgADCggICAAAAA==.',['燕赤']='燕赤霞:BAAAKgAECggIDQAAAA==.',['爱情']='爱情情爱:BAAAKgAECggICAAAAA==.',['爱马']='爱马仕半巨人:BAAAKgADCggIDwAAAA==.',['爷精']='爷精于潜:BAAAKgADCggICAAAAA==.',['牛奋']='牛奋奋:BAABKgAFFH8IAAINAAgIQAUkBwA7AQANAAgIQAUkBwA7AQAAAA==.',['猪咪']='猪咪:BAABKgAFFH8GAAMJAAYI2xaOCwAEAQAJAAQIuRKOCwAEAQAIAAIIDR2NEgCTAAAAAA==.',['猪崽']='猪崽儿:BAAAKgADCggICAAAAA==.',['玛法']='玛法裏奧怒風:BAABKgAFFH8IAAIMAAgIDha9AwACAgAMAAgIDha9AwACAgAAAA==.',['瑪法']='瑪法里奧怒風:BAAAKgADCggIEAAAAA==.',['用力']='用力用力用力:BAAAKgAECgQIBAAAAA==.',['番茄']='番茄炒鸡蛋:BAABKgAFFH8GAAIeAAYIpw6lEwDDAAAeAAYIpw6lEwDDAAAAAA==.',['疯狂']='疯狂的乞丐:BAAAKgAECgEIAQAAAA==.疯狂的奶:BAAAKgADCggICwAAAA==.',['百香']='百香果:BAAAKgADCggICAAAAA==.',['目标']='目标无法识别:BAAAKgADCgcIBwAAAA==.',['直人']='直人:BAABKgAFFH8LAAIMAAMIMBbxHQC3AAAMAAMIMBbxHQC3AAAAAA==.',['祖尔']='祖尔刚猛:BAABKgAFFH8IAAIYAAgIwRGABwCbAQAYAAgIwRGABwCbAQAAAA==.',['第二']='第二人生:BAAAKgAECgUIBgAAAA==.',['等我']='等我潜行:BAABKgAFFH8GAAIEAAYI1Qt8DgBpAQAEAAYI1Qt8DgBpAQAAAA==.',['筱四']='筱四眼:BAABKgAFFH8GAAIFAAYINxxYCACiAQAFAAYINxxYCACiAQAAAA==.',['筱樱']='筱樱:BAAAKgADCggICAAAAA==.',['箭圣']='箭圣:BAAAKgADCggICAAAAA==.',['糖水']='糖水绿洲:BAABKgAFFH8xAAICAAQIPiPhCwD7AAACAAQIPiPhCwD7AAAAAA==.',['绝世']='绝世大哒哒:BAAAKgADCgIIAgAAAA==.',['绯夜']='绯夜苍穹:BAABKgAFFH8KAAIJAAgIUSQkAQDjAgAJAAgIUSQkAQDjAgABKgAFFAgIJQAJAJ0hAA==.',['维生']='维生素片:BAAAKgAECgIIAgAAAA==.',['聂影']='聂影逞烽:BAAAKgAECggICAAAAA==.',['胖就']='胖就一個字:BAAAKgAECgYIBgAAAA==.',['腿毛']='腿毛黝黑:BAAAKgAECgcIBwAAAA==.',['舞不']='舞不尽痴人梦:BAAAKgAECgUIBgAAAA==.',['色系']='色系:BAABKgAECn8sAAIFAAgIcRT2KACKAQAFAAgIcRT2KACKAQAAAA==.',['艾丶']='艾丶格丶文:BAAAKgAECgcIBwAAAA==.',['芬达']='芬达嚯多了:BAAAKgAECgYIDAAAAA==.',['花虎']='花虎:BAAAKgAECgQIBAAAAA==.花虎花虎:BAACKgAFFH8FAAICAAMI8Bq2DAD2AAACAAMI8Bq2DAD2AAAqAAQKfxYAAgIACAhIHiYpAOcBAAIACAhIHiYpAOcBAAAA.',['芽森']='芽森月歌:BAABKgAFFH8KAAMEAAYI7h9/AAAIAgAEAAYI7h9/AAAIAgAaAAEIAAAKCQAAAAAAAA==.',['菜姐']='菜姐一一:BAAAKgAFFAQIBAAAAA==.菜姐宝一一:BAAAKgAFFAEIAQAAAA==.',['萌兰']='萌兰:BAAAKgAFFAQIBAAAAA==.',['落叶']='落叶之光:BAAAKgAECggIEQAAAA==.落叶无恒:BAAAKgADCgMIAwAAAA==.落叶晨魂:BAAAKgAECgEIAQAAAA==.落叶秋雨:BAAAKgADCggICAAAAA==.落叶醉雨巷:BAAAKgADCgUIBQAAAA==.',['落魄']='落魄山的鱼:BAAAKgAECggIEgAAAA==.',['薇尔']='薇尔莉特丶:BAAAKgAFFAQIBAAAAA==.',['读条']='读条三十秒:BAAAKgAECggICAAAAA==.',['贪玩']='贪玩骨天乐:BAABKgAFFH8JAAITAAYIow1uEwDVAAATAAYIow1uEwDVAAAAAA==.',['赚钱']='赚钱买个妞:BAAAKgADCggICwAAAA==.',['赞美']='赞美诗:BAAAKgADCggICAAAAA==.',['赤小']='赤小豆:BAAAKgAECgQIAQAAAA==.',['赵莉']='赵莉:BAAAKgADCggIDgAAAA==.',['越獄']='越獄:BAAAKgAECgEIAQAAAA==.',['达班']='达班丶王安全:BAAAKgAECggICAAAAA==.',['还是']='还是个泡泡:BAAAKgAFFAYIBAAAAA==.',['逍遥']='逍遥一只鱼:BAAAKgADCgcIBwAAAA==.',['鎹鸦']='鎹鸦:BAAAKgAFFAYIBAAAAA==.',['阿坎']='阿坎玛星歌:BAABKgAFFH8KAAIWAAYIzA/vBwAaAQAWAAYIzA/vBwAaAQAAAA==.',['阿尔']='阿尔薩斯:BAABKgAFFH8HAAIOAAcIoguFGwBBAQAOAAcIoguFGwBBAQAAAA==.阿尔赛利娅:BAAAKgAECgIIAgAAAA==.',['阿萊']='阿萊克丝塔萨:BAAAKgAFFAIIAgAAAA==.',['附魔']='附魔一号:BAAAKgADCggICgAAAA==.',['陈鹏']='陈鹏飞:BAAAKgADCgMIAwAAAA==.',['陌陌']='陌陌芊芊:BAAAKgAFFAYIAQAAAA==.',['雷雷']='雷雷骑士:BAAAKgAECgUIBQAAAA==.',['霍德']='霍德尔:BAAAKgAECgUIBAAAAA==.',['霹雳']='霹雳:BAAAKgAECgcIDQAAAA==.',['预言']='预言者维伦:BAABKgAECn8VAAIDAAgIcRH+KQCHAQADAAgIcRH+KQCHAQAAAA==.',['风继']='风继续吹:BAAAKgAECgYIBgAAAA==.',['飒飒']='飒飒逞风:BAAAKgAECgEIAQAAAA==.',['飞弹']='飞弹:BAAAKgAECggICwAAAA==.',['首席']='首席魔法丨师:BAAAKgAFFAEIAQAAAA==.',['骇人']='骇人津:BAAAKgAFFAgIBAAAAA==.',['鬼与']='鬼与暗哥:BAAAKgAFFAcIBAAAAA==.',['鱼普']='鱼普萝德摩尔:BAABKgAFFH8IAAIKAAgIeRPBEAA+AQAKAAgIeRPBEAA+AQAAAA==.',['鲁智']='鲁智深:BAABKgAFFH8GAAIQAAYIxwpyCgA6AQAQAAYIxwpyCgA6AQAAAA==.',['鲑鱼']='鲑鱼卵派:BAABKgAECn8XAAICAAYIURR2WwAZAQACAAYIURR2WwAZAQAAAA==.',['黎雷']='黎雷萨风行者:BAACKgAFFH8NAAMeAAQIPCEIBwAOAQAeAAQIPCEIBwAOAQAHAAMIwRnKKgDaAAAqAAQKfyQAAwcACAioGGYwAOkBAAcACAioGGYwAOkBAB4AAQhkAAAAAAAAAAAA.',['黑寡']='黑寡妇伊芙琳:BAAAKgADCgMIAwAAAA==.',['黑暗']='黑暗里的火花:BAABKgAFFH8GAAIIAAYIFw0kBABJAQAIAAYIFw0kBABJAQAAAA==.',['黑神']='黑神话熊猫:BAAAKgADCgQIBQAAAA==.',['鼠鼠']='鼠鼠:BAAAKgAECgUIBQAAAA==.',['龙之']='龙之楚天:BAABKgAFFH8JAAMWAAYI2xnrAQCwAQAWAAYI2xnrAQCwAQAXAAMIJRUuFQC6AAAAAA==.',['龙族']='龙族柠檬茶:BAAAKgAECggIBQAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end