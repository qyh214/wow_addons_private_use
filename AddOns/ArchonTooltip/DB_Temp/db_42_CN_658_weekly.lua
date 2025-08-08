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
 local lookup = {'Paladin-Retribution','Paladin-Protection','Hunter-BeastMastery','Hunter-Marksmanship','Hunter-Survival','DemonHunter-Havoc','DemonHunter-Vengeance','Monk-Mistweaver','Monk-Brewmaster','DeathKnight-Unholy','Warlock-Demonology','Warlock-Destruction','Warlock-Affliction','Paladin-Holy','Priest-Discipline','Druid-Balance','Shaman-Elemental','Shaman-Restoration','Warrior-Arms','Evoker-Devastation','Warrior-Fury','Shaman-Enhancement','Unknown-Unknown','Monk-Windwalker','Priest-Holy','Mage-Fire','Mage-Frost','Mage-Arcane','Priest-Shadow','DeathKnight-Blood','Rogue-Assassination','Druid-Restoration','Evoker-Preservation',}; local provider = {region='CN',realm='尘风峡谷',name='CN',type='weekly',zone=42,date='2025-08-08',data={Bd='Bdk:BAACKgAFFH8JAAIBAAYImSRsCgAeAgABAAYImSRsCgAeAgAqAAQKfyUAAwEACAiUGBVmAM4BAAEACAiUGBVmAM4BAAIAAQhkAAAAAAAAAAAA.',Bi='Biuboom:BAABKgAECn8XAAQDAAgINxr1dgBQAQADAAcITRX1dgBQAQAEAAQISxFdcAClAAAFAAMIVxgwFACkAAAAAA==.',Br='Brucelec:BAAAKgADCgMIAwAAAA==.',Dd='Ddoododo:BAAAKgADCggICAABKgAFFAgIEQAEAPEhAA==.',De='Deeprising:BAAAKgADCgcIBwAAAA==.',Ed='Edith:BAABKgAFFH8IAAMGAAYIbRQ7IQCzAAAGAAIIvR87IQCzAAAHAAQI4gwVFwCRAAAAAA==.',Er='Eredin:BAAAKgADCgYIBgAAAA==.',Et='Eternaldh:BAAAKgAFFAQIBAAAAA==.',Ho='Honesly:BAAAKgAFFAQIBAAAAA==.Hooters:BAAAKgAECgMIAwAAAA==.',Hu='Hungrybabe:BAAAKgAFFAEIAQAAAA==.',Lo='Loarda:BAAAKgAECgEIAQAAAA==.Loki:BAABKgAFFH8FAAIIAAUIGQF9HgCuAAAIAAUIGQF9HgCuAAAAAA==.',Ma='Malahidiel:BAAAKgADCgMIAwAAAA==.',Mi='Miriam:BAAAKgAECgEIAQAAAA==.',Na='Naturall:BAAAKgAFFAQIBAAAAA==.Naturals:BAAAKgAFFAYIAgAAAA==.',Ns='Ns:BAAAKgAFFAYIBAAAAA==.',Os='Osiris:BAABKgAFFH8SAAMCAAgIJh+ZDAAuAQACAAgIJh+ZDAAuAQABAAQIogkfYwCpAAAAAA==.',Ot='Otz:BAACKgAFFH8VAAIJAAQIxxJUBACxAAAJAAQIxxJUBACxAAAqAAQKfxkAAgkACAgKF5kLAJgBAAkACAgKF5kLAJgBAAAA.',Qu='Quy:BAAAKgADCggICAAAAA==.',Ri='Ricky:BAABKgAFFH8PAAIKAAQIJhE1NwC+AAAKAAQIJhE1NwC+AAAAAA==.',Sa='Sagittãrius:BAAAKgAECgYIBwAAAA==.',Sh='Shadefeaster:BAAAKgAECgEIAQAAAA==.',So='Solania:BAAAKgADCgIIAgAAAA==.',St='Striderl:BAAAKgAFFAMIAwAAAA==.',Zi='Zibbalol:BAAAKgAECgcICQAAAA==.',['不想']='不想做好人:BAABKgAECn8ZAAQLAAgI1RvmFwDBAQALAAcIvxnmFwDBAQAMAAQIIRUocAC6AAANAAIIgBbDMQBqAAAAAA==.',['不扰']='不扰清梦:BAAAKgAFFAgIBAAAAA==.',['丶夕']='丶夕語繁花:BAABKgAECn8gAAQBAAgI3RzLSAAWAgABAAgI3RzLSAAWAgAOAAIIIhdlQACBAAACAAEIXQI7bAAMAAAAAA==.',['亚莉']='亚莉莎的熊:BAAAKgAFFAQIBAABKgAFFAYIBQAPALwJAA==.',['伊拉']='伊拉罐:BAACKgAFFH8TAAIBAAMI2h6mHAD/AAABAAMI2h6mHAD/AAAqAAQKfxoAAgEACAj5If4ZAJ0CAAEACAj5If4ZAJ0CAAAA.',['伊芙']='伊芙琳恩:BAABKgAFFH8IAAIQAAgIjBorBQBxAgAQAAgIjBorBQBxAgAAAA==.',['傻墁']='傻墁:BAAAKgAECggIEQAAAA==.',['克贡']='克贡:BAAAKgAECgQICAABKgAECggIFwADADcaAA==.',['克里']='克里斯开下门:BAACKgAFFH8ZAAMLAAYI1RPbBwDHAAAMAAQIaxQxIQD+AAALAAUI4BLbBwDHAAAqAAQKfxsAAwsACAiBGBUYALkBAAsABwiBFxUYALkBAAwABAj+FDdiAOcAAAAA.',['兔叽']='兔叽不乖:BAAAKgAECgcIBwAAAA==.',['关晓']='关晓彤:BAAAKgAECggICQAAAA==.',['刑诉']='刑诉法年:BAABKgAFFH8JAAMRAAQI6hx1BgD/AAARAAMI6hx1BgD/AAASAAQIDg+mFQDOAAAAAA==.',['动物']='动物园园长:BAAAKgAFFAQIBAABKgAECggIFwADADcaAA==.',['北极']='北极兽:BAAAKgAECgUIBQAAAA==.',['双刀']='双刀阿贷:BAAAKgADCggIDQAAAA==.',['双杀']='双杀小王子:BAABKgAFFH8FAAITAAUIChGAEAALAQATAAUIChGAEAALAQAAAA==.',['史蒂']='史蒂芬周:BAABKgAFFH8PAAIUAAMIqRPOIAC/AAAUAAMIqRPOIAC/AAAAAA==.',['叶轻']='叶轻轻:BAAAKgAECgUICQAAAA==.',['吼怪']='吼怪:BAABKgAFFH8FAAIVAAUIpQXOGgDqAAAVAAUIpQXOGgDqAAAAAA==.',['咪嘻']='咪嘻拉面:BAABKgAECn8mAAMRAAgI8hxNIADsAQARAAgI8hxNIADsAQAWAAMIrQ99SQCbAAAAAA==.',['咸鱼']='咸鱼突刺:BAAAKgAECgEIAQAAAA==.',['哞哞']='哞哞咩咩:BAAAKgAECgMIAwAAAA==.',['噢嘜']='噢嘜雷滴嘎嘎:BAAAKgADCgYIBgAAAA==.',['囧囧']='囧囧有神:BAAAKgADCggICAAAAA==.',['土豪']='土豪小脚丫:BAAAKgAFFAYIAQAAAA==.',['基因']='基因凸变汼:BAAAKgAECggICAAAAA==.',['堕落']='堕落灰烬:BAAAKgAFFAYIBAAAAA==.堕落的小恶魔:BAAAKgAFFAEIAQAAAA==.',['复仇']='复仇乄新:BAAAKgAECgQIBgAAAA==.',['多多']='多多嘟嘟:BAAAKgAFFAYIBAAAAA==.多多龙:BAAAKgAECggIDgAAAA==.',['天不']='天不负:BAAAKgADCgIIAgAAAA==.',['天冥']='天冥之炎:BAAAKgAECgMIAwABKgAECggIFwADADcaAA==.',['天雪']='天雪神傲月:BAACKgAFFH8JAAIGAAMI8BPoKQDPAAAGAAMI8BPoKQDPAAAqAAQKfxYAAgYACAguH80TAGMCAAYACAguH80TAGMCAAAA.',['寒凛']='寒凛雨荷:BAAAKgAECgUIBQABKgAECgYIBwAXAAAAAA==.',['小夜']='小夜:BAAAKgADCggICAAAAA==.',['小妞']='小妞嘟嘟:BAACKgAFFH8IAAIPAAMIRhi/FwDUAAAPAAMIRhi/FwDUAAAqAAQKfx0AAg8ACAgVIp8HAKICAA8ACAgVIp8HAKICAAAA.',['小小']='小小吗喽:BAAAKgAECggICwABKgAFFAgICgAGAAIRAA==.',['小楼']='小楼夜歌声:BAAAKgAECgIIAgAAAA==.',['小那']='小那星人:BAAAKgAECgUICAAAAA==.',['少昊']='少昊:BAABKgAFFH8HAAMIAAQInBT4DgDuAAAIAAQInBT4DgDuAAAYAAMIIRHbFgCyAAAAAA==.',['工友']='工友:BAABKgAFFH8IAAIKAAgI8SBHBABtAgAKAAgI8SBHBABtAgAAAA==.',['巴比']='巴比隆:BAAAKgAECggICAAAAA==.',['希拉']='希拉穆仁:BAAAKgADCgQIBAAAAA==.',['希瑞']='希瑞:BAABKgAFFH8HAAIDAAcIhgQ2DgBKAQADAAcIhgQ2DgBKAQAAAA==.',['幼天']='幼天爹:BAABKgAECn8VAAIUAAgIRhhnIgCmAQAUAAgIRhhnIgCmAQAAAA==.',['忘记']='忘记看星星:BAAAKgADCgcICQAAAA==.',['恍恍']='恍恍惚惚:BAAAKgADCgEIAQAAAA==.',['想做']='想做哥哥的零:BAABKgAECn8WAAIOAAgIuhs2DQAiAgAOAAgIuhs2DQAiAgABKgAFFAMICAAPAEYYAA==.',['我叫']='我叫奶踢:BAAAKgAECgIIAgAAAA==.',['我尽']='我尽力了:BAAAKgAECgQIBAAAAA==.',['我抗']='我抗不住:BAAAKgAECgcIEAAAAA==.',['打豆']='打豆豆:BAAAKgADCggICAAAAA==.',['折木']='折木一茶:BAACKgAFFH9FAAQLAAgI9R/7AABRAQAMAAYIhBr9CAD+AQANAAYITh6YAQCpAQALAAUIkhf7AABRAQAqAAQKfxsABAsACAiTIRkYALkBAAsACAhCIRkYALkBAA0ABAi6HkATAEQBAAwAAgjBHp9dAKYAAAAA.',['拉什']='拉什塔哈:BAABKgAFFH8FAAIPAAQIQiGeBgArAQAPAAQIQiGeBgArAQAAAA==.',['拉斯']='拉斯塔哈:BAAAKgAECgcICQAAAA==.',['招财']='招财熊猫:BAAAKgADCgUIBQAAAA==.',['普拉']='普拉顿桑克斯:BAABKgAFFH8IAAIUAAQIOxVKJACvAAAUAAQIOxVKJACvAAABKgAFFAgICQAMADAUAA==.',['暮色']='暮色百合:BAAAKgAECgcICQAAAA==.',['月光']='月光小白兔:BAAAKgAECgQIBAABKgAFFAMICAAPAEYYAA==.',['月影']='月影凌霜:BAAAKgAFFAgIBAAAAA==.',['月野']='月野兔:BAAAKgAFFAEIAQAAAA==.',['木木']='木木:BAABKgAFFH8vAAMZAAQIXR7tGQDqAAAZAAQIXR7tGQDqAAAPAAMI2xSGHACKAAAAAA==.',['木瓜']='木瓜吃多了:BAAAKgAECgYIBgAAAA==.',['李朝']='李朝鲁:BAAAKgAECgcIDQAAAA==.',['杠上']='杠上开花:BAAAKgAECgQIBAAAAA==.',['松茸']='松茸鱼子酱:BAABKgAFFH8FAAIEAAUIChgYDQAvAQAEAAUIChgYDQAvAQAAAA==.',['柇楓']='柇楓:BAABKgAFFH8GAAIBAAYI7h2TEQDRAQABAAYI7h2TEQDRAQAAAA==.',['桃乃']='桃乃木香萘:BAACKgAFFH8iAAIBAAYI5iUJBwBHAQABAAYI5iUJBwBHAQAqAAQKf2QAAgEACAh9Js8DABADAAEACAh9Js8DABADAAAA.',['水無']='水無月流歌:BAAAKgAECgEIAQAAAA==.',['水煮']='水煮牛肉:BAAAKgADCgEIAQAAAA==.',['沙瑞']='沙瑞全:BAAAKgADCgIIAgAAAA==.',['泰格']='泰格里斯:BAABKgAFFH8GAAMaAAYI0g98IQDQAAAaAAII+iF8IQDQAAAbAAQItgPMFACKAAABKgAFFAgIFgAMAOgSAA==.',['海之']='海之子:BAAAKgAECggICQAAAA==.',['混子']='混子骑:BAABKgAFFH8KAAIBAAgIigxMDADeAQABAAgIigxMDADeAQAAAA==.',['潇洒']='潇洒公子:BAABKgAECn8nAAMbAAgI6iFrHgAWAgAbAAgIESFrHgAWAgAaAAcIAhdrTABOAQABKgAFFAgIKwAcAI0fAA==.',['灾厄']='灾厄渡鸦:BAABKgAFFH8GAAIMAAYIGxgQEQCEAQAMAAYIGxgQEQCEAQAAAA==.',['炽天']='炽天使:BAABKgAFFH8HAAQPAAYIVRP2EQDNAAAPAAMICQz2EQDNAAAdAAIIuiIeGgCuAAAZAAIIoxvxOwBOAAAAAA==.',['烨星']='烨星:BAACKgAFFH8mAAMbAAUIaRllCgDcAAAbAAUIaRllCgDcAAAcAAEI8hLnQwBCAAAqAAQKfyQAAxsACAgPIMUYADsCABsACAi6H8UYADsCABoABggeDSFYABUBAAAA.',['烬落']='烬落:BAABKgAFFH8KAAQMAAYIHRbJAQDRAQAMAAYIHRbJAQDRAQANAAIIbw/6EwCLAAALAAEIAADuJAAAAAABKgAFFAgIHQANAOkaAA==.',['熊十']='熊十三:BAAAKgAECgQIBAAAAA==.',['熊猫']='熊猫会功夫:BAABKgAFFH8KAAMYAAYIlRPZCABfAQAYAAYIlRPZCABfAQAJAAQIRAm3CACAAAAAAA==.',['片刻']='片刻长生:BAAAKgAECgIIAgAAAA==.',['牛肉']='牛肉嘟嘟肥:BAABKgAFFH8LAAMVAAMIEBRPEADxAAAVAAMIzRNPEADxAAATAAII/RHKDwCaAAAAAA==.',['犭孟']='犭孟男顽皮豹:BAAAKgAECgYIBgAAAA==.',['狂拽']='狂拽酷霸炫:BAAAKgAECgIIAgAAAA==.',['狂野']='狂野小魔星:BAAAKgADCggIFQAAAA==.',['狄奥']='狄奥尼索斯:BAAAKgAECgEIAQAAAA==.',['猛踹']='猛踹瘸子好腿:BAAAKgADCgMIAwAAAA==.',['猫不']='猫不易:BAAAKgAFFAgIAwAAAA==.',['獠牙']='獠牙狩:BAABKgAFFH8IAAIDAAQI9BhLGQDtAAADAAQI9BhLGQDtAAAAAA==.',['玩过']='玩过夏雨荷:BAAAKgADCgUIBQABKgAFFAgIOQAOAAEdAA==.',['瑞迪']='瑞迪克尤拉斯:BAAAKgAECgcIDQAAAA==.',['福乐']='福乐硬:BAAAKgAECgMIAwAAAA==.福乐硬核:BAABKgAFFH8FAAIVAAQIRAY1FgCwAAAVAAQIRAY1FgCwAAAAAA==.',['秋叶']='秋叶蓝布城:BAAAKgAFFAQIBAAAAA==.',['章若']='章若楠:BAAAKgAECgQIBAAAAA==.',['糊里']='糊里糊涂法:BAAAKgADCgEIAQAAAA==.',['纽扣']='纽扣丢了:BAAAKgAECggICQAAAA==.',['维娜']='维娜的海狸:BAAAKgAFFAQIBAABKgAFFAYIBQAPALwJAA==.',['羊过']='羊过土人:BAABKgAFFH8IAAMbAAYIeRIkCQAxAQAbAAYIYRIkCQAxAQAcAAIIQiNoBgBoAAAAAA==.',['聖小']='聖小小新:BAAAKgAECgIIAgAAAA==.',['聖阎']='聖阎王:BAABKgAFFH8JAAIBAAQIeAJIOQB5AAABAAQIeAJIOQB5AAAAAA==.',['胖仔']='胖仔:BAABKgAFFH8GAAIYAAMI4wyNDQC7AAAYAAMI4wyNDQC7AAAAAA==.',['能猫']='能猫:BAAAKgAECgUICQAAAA==.',['舞火']='舞火:BAAAKgADCgQIBAAAAA==.',['艾斯']='艾斯德斯:BAAAKgAECggICAABKgAFFAYIAgAXAAAAAA==.',['艾莉']='艾莉丝的仓鼠:BAAAKgAFFAQIAwABKgAFFAYIBQAPALwJAA==.',['艾萨']='艾萨里昂:BAABKgAFFH8NAAIBAAgI1xJsDAAFAgABAAgI1xJsDAAFAgAAAA==.',['莉莉']='莉莉丝的鱼:BAACKgAFFH8FAAMPAAUIvAlOGQCYAAAPAAIIKwNOGQCYAAAZAAMIHQ6DLACSAAAqAAQKfxcAAhkACAgtIa4tAI4BABkACAgtIa4tAI4BAAAA.',['莱斯']='莱斯亚:BAAAKgAFFAIIBAAAAA==.',['菲克']='菲克纽斯:BAAAKgAECgEIAQAAAA==.',['葡萄']='葡萄的皮:BAAAKgADCggIEgAAAA==.',['蓄意']='蓄意轰拳:BAAAKgAECggIEgAAAA==.',['薛迪']='薛迪凯是垃圾:BAAAKgAFFAEIAgAAAA==.',['蛋灬']='蛋灬蛋:BAACKgAFFH8FAAIIAAMI0gciFwDCAAAIAAMI0gciFwDCAAAqAAQKfyIAAggACAiyE14tAJ4BAAgACAiyE14tAJ4BAAAA.',['血公']='血公子:BAAAKgAFFAQIBAAAAA==.',['行万']='行万理路:BAAAKgAECgIIAgAAAA==.',['谁能']='谁能书阁下:BAAAKgADCggIDwAAAA==.',['贝拉']='贝拉的天鹅:BAACKgAFFH8FAAIIAAIImyBzGQCxAAAIAAIImyBzGQCxAAAqAAQKfx8AAggACAirI0IGAMMCAAgACAirI0IGAMMCAAEqAAUUBggFAA8AvAkA.',['赫尔']='赫尔:BAABKgAECn8dAAMKAAgIbBp8TACGAQAKAAgI1xV8TACGAQAeAAYIaxITPADSAAAAAA==.',['赵丽']='赵丽颖:BAAAKgADCgMIAwAAAA==.',['起了']='起了毛球:BAAAKgAECgEIAQAAAA==.',['車路']='車路士:BAACKgAFFH8GAAIDAAMIEhzOJwDmAAADAAMIEhzOJwDmAAAqAAQKfx0AAgMACAhEIp4mABsCAAMACAhEIp4mABsCAAAA.',['轩小']='轩小小新:BAAAKgAFFAIIAgAAAA==.',['部落']='部落奸细:BAABKgAFFH8WAAIfAAYITyJiAgClAQAfAAYITyJiAgClAQAAAA==.',['酱爆']='酱爆葱香大排:BAAAKgAECggIEAAAAA==.',['醉羽']='醉羽舞:BAABKgAFFH8HAAIPAAcIDBHLBACZAQAPAAcIDBHLBACZAQAAAA==.',['锁甲']='锁甲已废:BAABKgAFFH8IAAMSAAgIignCHgAAAQASAAUIuAXCHgAAAQARAAMIVwTSGwCdAAAAAA==.',['阿尔']='阿尔萨新:BAACKgAFFH8FAAMeAAII0BeGJQCBAAAeAAII0BeGJQCBAAAKAAEI5AbBVQA1AAAqAAQKfxwAAx4ABwj2EaIrADEBAB4ABwjyEaIrADEBAAoABQheD76TAKwAAAAA.',['阿斯']='阿斯尔:BAAAKgADCgYIBgAAAA==.',['阿贷']='阿贷的雷神:BAAAKgAECgQIBQAAAA==.',['隐灭']='隐灭:BAAAKgADCggICAAAAA==.',['隐蔑']='隐蔑:BAAAKgAECgUIBQAAAA==.',['零宝']='零宝:BAABKgAFFH8FAAIOAAMIPRzHBwDvAAAOAAMIPRzHBwDvAAAAAA==.',['零魂']='零魂乄惊雪:BAABKgAFFH8GAAIgAAYIFxdBBwAHAQAgAAYIFxdBBwAHAQAAAA==.',['风中']='风中女王:BAAAKgAECgYIBgAAAA==.',['风茫']='风茫茫:BAABKgAFFH8FAAIeAAUIsxCzFwDjAAAeAAUIsxCzFwDjAAAAAA==.',['风车']='风车骑士:BAAAKgAFFAQIBAAAAA==.',['魔丸']='魔丸丸:BAABKgAFFH8MAAMDAAYINhwZAgDNAQADAAYIrxkZAgDNAQAEAAUIhByeAgBWAQABKgAFFAgIEwADAOUdAA==.',['鹰眼']='鹰眼凯思卓:BAAAKgAECggICAABKgAFFAMICAAPAEYYAA==.',['黑昼']='黑昼丶:BAAAKgAECggICAABKgAFFAgICAADABcdAA==.',['鼠十']='鼠十三:BAAAKgADCgcICQAAAA==.',['龙一']='龙一冉:BAAAKgAECgEIAQAAAA==.龙一风暴狂:BAABKgAFFH8KAAISAAYIshf5DgBjAQASAAYIshf5DgBjAQABKgAFFAgICAASALsbAA==.',['龙之']='龙之召唤:BAABKgAFFH8GAAIhAAQIcxRNBgCoAAAhAAQIcxRNBgCoAAAAAA==.',['龙希']='龙希尔:BAAAKgAFFAYIBAABKgAFFAgIBAAXAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end