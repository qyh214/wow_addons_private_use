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
 local lookup = {'Paladin-Retribution','Mage-Arcane','Rogue-Assassination','Unknown-Unknown','Mage-Fire','Priest-Holy','DemonHunter-Havoc','Warlock-Destruction','Warlock-Affliction','Druid-Restoration','DeathKnight-Unholy','DeathKnight-Blood','Priest-Shadow','Warrior-Protection','Mage-Frost','Warrior-Fury','Warrior-Arms','Druid-Balance','Druid-Guardian','Warlock-Demonology','Hunter-BeastMastery','Hunter-Marksmanship','Shaman-Restoration','DeathKnight-Frost','Rogue-Subtlety','Shaman-Elemental','Paladin-Protection','Priest-Discipline','Paladin-Holy','Monk-Windwalker','Evoker-Augmentation','Evoker-Devastation','Evoker-Preservation','Monk-Mistweaver','Hunter-Survival','Shaman-Enhancement','DemonHunter-Vengeance','Rogue-Outlaw',}; local provider = {region='CN',realm='大地之怒',name='CN',type='weekly',zone=42,date='2025-08-08',data={Ai='Aimo:BAAAKgAECgcIBwABKgAFFAgICAABACcVAA==.',Ar='Argon:BAAAKgAECggICAAAAA==.',As='Asunayasina:BAAAKgAECgQIBAAAAA==.',Av='Avenger:BAAAKgAECggICAAAAA==.',Ca='Carllic:BAABKgAECn8ZAAICAAgI+xVuEADLAQACAAgI+xVuEADLAQAAAA==.',Ci='Cill:BAAAKgAECgYICgAAAA==.',Cy='Cymax:BAAAKgADCgYIBgAAAA==.',Da='Darvin:BAABKgAFFH8GAAIDAAYImghfEABLAQADAAYImghfEABLAQAAAA==.',Dd='Ddname:BAAAKgAECgMIAwAAAA==.',Dk='Dkt:BAAAKgAECgYICwAAAA==.',Do='Doname:BAAAKgADCgEIAQABKgAECgMIAwAEAAAAAA==.Donk:BAABKgAFFH8GAAIFAAYIIw9CDgBZAQAFAAYIIw9CDgBZAQAAAA==.Doublechen:BAACKgAFFH8GAAIBAAQIpgo/agCXAAABAAQIpgo/agCXAAAqAAQKfxgAAgEACAg7HNFgANoBAAEACAg7HNFgANoBAAAA.',Ga='Gasshow:BAAAKgADCgMIAwAAAA==.',Gi='Gilgamesh:BAABKgAFFH8GAAIBAAYIqBReIQBpAQABAAYIqBReIQBpAQAAAA==.',He='Helluin:BAAAKgAFFAUIAgAAAA==.',La='Landes:BAABKgAFFH8GAAIGAAYI5wypEAAtAQAGAAYI5wypEAAtAQABKgAFFAgILQAGADsVAA==.',Ma='Macchiatoo:BAABKgAFFH8IAAIHAAcI6SL/BgAyAgAHAAcI6SL/BgAyAgAAAA==.Maddie:BAAAKgADCggICAAAAA==.',Ne='Neverbrecth:BAAAKgAECgUIBQAAAA==.',Re='Redpaladin:BAAAKgAECgYIBwAAAA==.Reisenbeer:BAACKgAFFH8pAAMIAAgIph6FDwCXAQAIAAYIJxmFDwCXAQAJAAUIZxvZCADjAAAqAAQKfzkAAwgACAidJLgbAMgBAAgABwiXJLgbAMgBAAkABAh7IeMVAEMBAAAA.Reislin:BAAAKgAECggICAABKgAFFAgIDwAKAJ4TAA==.',Ry='Rylynn:BAAAKgAECgcICQAAAA==.',Sa='Salaheiyo:BAAAKgADCgMIAwAAAA==.',Sh='Shatan:BAABKgAFFH8IAAIBAAgIXxUdLgAvAQABAAgIXxUdLgAvAQAAAA==.Shengqishi:BAAAKgAECggIAQAAAA==.',Si='Simondemon:BAAAKgAECgUIBwAAAA==.Simondragon:BAAAKgAECgUIBQAAAA==.Simonpally:BAAAKgAECgIIAgAAAA==.Simonpriest:BAAAKgAECgYICQAAAA==.',Sl='Slaughtermen:BAABKgAFFH8IAAMLAAUIsiBPIAAeAQALAAUIsiBPIAAeAQAMAAII6wmeHwBjAAAAAA==.',Sp='Spacex:BAAAKgAECgUIBQAAAA==.',Th='Thebs:BAAAKgAFFAIIAgAAAA==.',To='Tongyma:BAAAKgAECggICAAAAA==.',Ub='Ubear:BAAAKgAECgcIDAAAAA==.',Uy='Uyanzu:BAAAKgAECgIIAgAAAA==.',Va='Vavan:BAABKgAFFH8GAAINAAYILQWDEQD2AAANAAYILQWDEQD2AAABKgAFFAgIDgAIAPkhAA==.',Ve='Veznan:BAAAKgAECgMIAwAAAA==.',Xh='Xhq:BAAAKgADCgEIAQAAAA==.',Xi='Xiaosun:BAAAKgAECggICAAAAA==.',Zo='Zolpidem:BAAAKgAFFAMIAwAAAA==.',['一个']='一个张柏芝:BAAAKgADCggICAAAAA==.',['一减']='一减伤开:BAAAKgAFFAIIAgAAAA==.',['一安']='一安静一:BAAAKgADCgEIAQAAAA==.',['一巴']='一巴掌扇死你:BAAAKgAFFAQIBAAAAA==.一巴掌甩死你:BAAAKgADCgUIBQAAAA==.',['一轩']='一轩一:BAAAKgADCgEIAQAAAA==.',['七玄']='七玄:BAAAKgADCggICAAAAA==.',['丄来']='丄来自己动:BAAAKgAECgQIBAAAAA==.',['三千']='三千焱焱:BAABKgAFFH8GAAIOAAYI7QUqCQDSAAAOAAYI7QUqCQDSAAAAAA==.三千雷动:BAAAKgAECgcIBwAAAA==.',['三界']='三界鱼:BAAAKgAECgUIBQAAAA==.',['不羁']='不羁的风:BAABKgAECn8WAAMPAAgINAifXAD3AAAPAAgINAifXAD3AAAFAAEI4wDQrQAMAAAAAA==.不羁的风啊:BAABKgAFFH8GAAIMAAYI4QheGADeAAAMAAYI4QheGADeAAAAAA==.',['且听']='且听風吟:BAABKgAFFH8GAAMQAAYIfRBFEgDwAAAQAAQIBg9FEgDwAAARAAIIrxJTHgCaAAAAAA==.',['且弑']='且弑天下:BAABKgAECn8WAAMSAAgIChfYNADWAQASAAgIChfYNADWAQATAAYIAApZJgBrAAAAAA==.',['丨三']='丨三上丨悠亜:BAAAKgADCggICAAAAA==.',['丨勒']='丨勒布朗丨:BAABKgAFFH8IAAILAAgIPATsCQCGAQALAAgIPATsCQCGAQAAAA==.',['丶北']='丶北归:BAABKgAFFH8KAAILAAYIFAswBACFAQALAAYIFAswBACFAQAAAA==.',['丶独']='丶独行者:BAAAKgADCgEIAQAAAA==.',['丶风']='丶风骚惊天下:BAABKgAFFH8HAAIUAAMIMA1JDwDAAAAUAAMIMA1JDwDAAAAAAA==.',['乊風']='乊風之痕乊:BAAAKgAECgMIAgAAAA==.',['乌喵']='乌喵喵王:BAAAKgADCgYIBgAAAA==.',['乌拉']='乌拉:BAAAKgAECgQIBwAAAA==.',['九万']='九万:BAABKgAFFH8GAAISAAYI0wYxIQAZAQASAAYI0wYxIQAZAQAAAA==.',['九十']='九十九小狐仙:BAAAKgADCgMIAwAAAA==.',['九月']='九月青年:BAAAKgAFFAIIAgAAAA==.',['乱世']='乱世之主:BAAAKgAECgcIBwAAAA==.',['乾坤']='乾坤无相:BAAAKgAECgcIDgAAAA==.',['于小']='于小咪:BAAAKgAECgUIBwAAAA==.于小鱼:BAAAKgAECgYIDQAAAA==.',['云川']='云川:BAAAKgAECgQIBAAAAA==.',['云淡']='云淡风轻丶:BAAAKgADCgIIAgAAAA==.',['人字']='人字拖拉机:BAAAKgAECgQIBAAAAA==.',['从小']='从小就缺奶:BAAAKgAECgMIAwAAAA==.从小愛萌萌:BAAAKgAECgIIAgAAAA==.',['伏心']='伏心猿降意马:BAAAKgAECgcIBwAAAA==.',['低调']='低调的小白:BAAAKgAFFAEIAQAAAA==.',['佳木']='佳木斯大拐:BAAAKgADCgcIBwAAAA==.',['侃侃']='侃侃闲话:BAAAKgAFFAgIBAAAAA==.',['信小']='信小田:BAABKgAFFH8NAAMVAAQIzSHNDAAeAQAVAAQIPx/NDAAeAQAWAAQIlhsRIgDqAAAAAA==.',['偷内']='偷内酷:BAABKgAFFH8JAAIQAAUIcyM5CgCpAQAQAAUIcyM5CgCpAQAAAA==.',['元大']='元大英:BAAAKgAFFAQIBAAAAA==.',['元素']='元素无用:BAABKgAECn8cAAIXAAgIaSCHEwBUAgAXAAgIaSCHEwBUAgAAAA==.',['克鲁']='克鲁索尔刃拳:BAABKgAFFH8RAAQLAAYIPhTACQAcAQALAAQI3yDACQAcAQAYAAQIaRr5CADcAAAMAAIITAEBEgBaAAAAAA==.',['八卦']='八卦街网格员:BAAAKgAECggIEgAAAA==.',['其手']='其手拉手:BAAAKgADCggIDgAAAA==.',['冄冄']='冄冄乌:BAABKgAFFH8IAAMPAAQIuR3EBAAMAQAPAAQIuR3EBAAMAQAFAAIIzglwNAB3AAAAAA==.',['冰指']='冰指绕温柔:BAAAKgAECgYICAAAAA==.',['冰柯']='冰柯基火锅王:BAAAKgAECgcIBwAAAA==.',['冷锋']='冷锋:BAAAKgAECgYIDwAAAA==.',['凌夜']='凌夜:BAABKgAFFH8MAAMDAAYIyhwDCgCxAQADAAYIyhwDCgCxAQAZAAIIAwkfDgCDAAAAAA==.',['凛冬']='凛冬杀戮:BAAAKgAECgUIBQAAAA==.',['凤僧']='凤僧:BAAAKgADCgUIBQAAAA==.',['刀锋']='刀锋易冷:BAABKgAECn8UAAMRAAgI4BCWIACAAQARAAgI4BCWIACAAQAQAAQIsA1PagCtAAAAAA==.刀锋釹王:BAAAKgAECgMIAwAAAA==.',['制造']='制造一宗惨案:BAAAKgAECgcIBwAAAA==.',['动感']='动感蜗牛:BAABKgAECn8gAAMXAAgI3hSUOwCHAQAXAAgI3hSUOwCHAQAaAAEIMQjxfAAmAAAAAA==.',['动物']='动物变形记:BAAAKgADCgcIAwAAAA==.',['劲杀']='劲杀绝:BAABKgAFFH8JAAIQAAMItAlZFADFAAAQAAMItAlZFADFAAAAAA==.',['劳资']='劳资又没蓝了:BAAAKgAECgQIBAAAAA==.',['包夜']='包夜不销魂:BAAAKgAECggIAwAAAA==.',['北丶']='北丶嘚嘚:BAAAKgAECgYIBwAAAA==.',['午后']='午后的喵小丫:BAAAKgAECgUIBwAAAA==.',['卡灬']='卡灬卡:BAAAKgAFFAYIAgAAAA==.',['卡瓦']='卡瓦格博:BAABKgAFFH8MAAMaAAgIoRLZDQD6AAAaAAUI7AvZDQD6AAAXAAUIvwFbJQDhAAAAAA==.',['厉害']='厉害的大芒果:BAAAKgAECgIIAwAAAA==.',['变的']='变的心烦:BAAAKgAECggICAAAAA==.',['变身']='变身狂魔:BAABKgAFFH8IAAIHAAgIugXWDACHAQAHAAgIugXWDACHAQAAAA==.',['叫我']='叫我法爷:BAAAKgADCggICAAAAA==.',['君不']='君不救:BAAAKgAFFAQIBAAAAA==.',['听讲']='听讲你叫我:BAABKgAFFH8YAAMbAAgI0hsgBQDvAQAbAAgIexcgBQDvAQABAAMIDSYIKQBDAQAAAA==.',['吾乃']='吾乃大学生:BAAAKgADCggICAAAAA==.',['呵邀']='呵邀激:BAAAKgADCgYIBgAAAA==.',['呼丶']='呼丶妖気丶:BAAAKgADCgQIBAAAAA==.',['哈丶']='哈丶妖気丶:BAAAKgAECggIDgAAAA==.',['唰丶']='唰丶妖気丶:BAABKgAFFH8WAAMFAAUIsxtCEgAJAQAFAAQI8CJCEgAJAQACAAMIxBU8EwDxAAAAAA==.',['唱歌']='唱歌女侠:BAABKgAFFH8HAAMGAAMIoCEyDwDFAAAGAAMIoCEyDwDFAAAcAAIIpAHRMQBDAAAAAA==.',['嗜血']='嗜血雷霆:BAAAKgAECggICwAAAA==.',['嘿丶']='嘿丶妖気丶:BAAAKgAECgIIAgAAAA==.',['噗霪']='噗霪鎏:BAAAKgADCggICAAAAA==.',['嚒嚒']='嚒嚒牛:BAABKgAECn8VAAITAAcIUxLEEAA/AQATAAcIUxLEEAA/AQABKgAFFAgIKQASAGQbAA==.',['团灭']='团灭小助手:BAAAKgADCgYIBgAAAA==.',['土豆']='土豆小卷:BAAAKgAECgIIAgAAAA==.土豆炖鸡:BAAAKgADCggICAAAAA==.',['坑娘']='坑娘不坑爹:BAAAKgAECgUICgAAAA==.',['塞萨']='塞萨里安:BAABKgAECn8VAAMLAAYIYQ44YQD7AAALAAYIYQ44YQD7AAAMAAUI3QebTgCBAAAAAA==.',['夏沫']='夏沫诗韵:BAAAKgADCgIIAgAAAA==.',['夏雨']='夏雨下鱼:BAABKgAFFH8JAAMWAAcIQxk8DQCGAQAWAAYIPBk8DQCGAQAVAAMIKhAKEgAFAQAAAA==.',['夏雪']='夏雪瑶:BAABKgAFFH8KAAISAAYISRfdEwB8AQASAAYISRfdEwB8AQAAAA==.',['夕陽']='夕陽西下:BAAAKgADCggICAAAAA==.',['夜半']='夜半鬼叫:BAAAKgADCgUIBQAAAA==.',['夜幕']='夜幕:BAABKgAECn8VAAIQAAgI4BfUCwDlAQAQAAgI4BfUCwDlAQAAAA==.',['大久']='大久保龄球:BAAAKgAFFAgIBAAAAA==.',['大叔']='大叔爱萝莉:BAAAKgAECggIDQAAAA==.',['大吧']='大吧唧:BAABKgAFFH8WAAMRAAMImhrnFADcAAAQAAMINBT5HADgAAARAAMImhrnFADcAAAAAA==.',['大白']='大白兔切萝卜:BAAAKgAFFAQIBAAAAA==.大白兔吃萝卜:BAABKgAFFH8HAAMBAAUI7BVQHADxAAABAAMIhxZQHADxAAAdAAQIew10CADRAAABKgAFFAgIEAANAFsKAA==.大白兔种萝卜:BAAAKgAFFAgIBAAAAA==.',['大霸']='大霸机:BAABKgAFFH8OAAIeAAMIDhejEQDVAAAeAAMIDhejEQDVAAAAAA==.',['大鸟']='大鸟骑士:BAAAKgAECgQICAAAAA==.',['天刀']='天刀丶:BAABKgAECn8iAAILAAgICSOUEQCZAgALAAgICSOUEQCZAgAAAA==.',['天地']='天地会陈进南:BAAAKgAECggICAAAAA==.',['天灵']='天灵子:BAAAKgADCggICAAAAA==.',['天赐']='天赐良鸡:BAAAKgAECgUIBQAAAA==.',['太子']='太子爷:BAABKgAECn8sAAIBAAgIZiFmHwCFAgABAAgIZiFmHwCFAgAAAA==.',['头号']='头号熊猫:BAABKgAFFH8FAAIXAAMI0AV1PQCRAAAXAAMI0AV1PQCRAAAAAA==.头号猛牛:BAAAKgAECgUIBQAAAA==.',['夺宝']='夺宝奇兵:BAAAKgAECggIEwAAAA==.',['奥蛋']='奥蛋肥牛:BAAAKgADCgUIBQAAAA==.',['奶一']='奶一下谢谢:BAAAKgAECgEIAQAAAA==.',['奶珑']='奶珑丶:BAAAKgAECgQIBAAAAA==.',['奶茶']='奶茶君:BAAAKgAECgUICAAAAA==.',['姥姥']='姥姥的豆瓣酱:BAACKgAFFH8dAAIBAAQIPSFsMQAjAQABAAQIPSFsMQAjAQAqAAQKfxgAAgEACAh/HK9KABECAAEACAh/HK9KABECAAAA.',['安杰']='安杰贼哥:BAAAKgAECgcIBwAAAA==.',['安若']='安若丶浮生:BAAAKgAFFAgIBAAAAA==.',['完美']='完美背刺:BAABKgAFFH8GAAIDAAYIfgYNEQBAAQADAAYIfgYNEQBAAQAAAA==.',['富含']='富含三聚氰氨:BAABKgAFFH8IAAICAAgIwgmuCQDPAQACAAgIwgmuCQDPAQAAAA==.',['寒山']='寒山寺:BAAAKgAECgMIAwAAAA==.',['射天']='射天狼:BAAAKgADCgEIAQAAAA==.',['對我']='對我彈琴我懂:BAAAKgAECgEIAQAAAA==.',['小四']='小四龙:BAABKgAFFH8bAAIfAAQIlgBOBAAsAAAfAAQIlgBOBAAsAAABKgAFFAgIJQAIAAkRAA==.',['小奶']='小奶娘:BAAAKgAECgQIBAAAAA==.小奶萨:BAAAKgAECgYIBwAAAA==.',['小小']='小小乖大人优:BAABKgAFFH8GAAIBAAYIKBhWHwBzAQABAAYIKBhWHwBzAQAAAA==.',['小棣']='小棣:BAABKgAFFH8GAAILAAYIlxuuEACWAQALAAYIlxuuEACWAQABKgAFFAgICAAQALMSAA==.',['小甜']='小甜甜牛夫人:BAABKgAFFH8GAAIHAAYI1QuNGQAxAQAHAAYI1QuNGQAxAQAAAA==.',['小苏']='小苏苏:BAABKgAECn8ZAAIIAAgITxOOSQBCAQAIAAgITxOOSQBCAQAAAA==.',['小雷']='小雷来了:BAAAKgAECgYIBgAAAA==.',['小霸']='小霸王:BAABKgAECn8VAAIQAAgIvRazLQDQAQAQAAgIvRazLQDQAQAAAA==.',['尛脸']='尛脸賍兮兮:BAABKgAFFH8OAAIHAAQIiBFJKwDLAAAHAAQIiBFJKwDLAAAAAA==.',['尾巴']='尾巴大手感好:BAAAKgAFFAEIAQAAAA==.',['山月']='山月:BAAAKgADCgcIBwAAAA==.',['山有']='山有牧:BAAAKgAECgYIBgAAAA==.',['巨龙']='巨龙黎明:BAABKgAFFH8OAAMgAAgIdRGuCwCuAQAgAAgIdRGuCwCuAQAhAAEIARX1CQBPAAAAAA==.',['布莱']='布莱克恺特:BAAAKgAFFAQIBAAAAA==.',['帶倪']='帶倪俬渀:BAABKgAFFH8JAAIVAAMI4B1zEQAPAQAVAAMI4B1zEQAPAQAAAA==.',['年世']='年世兰:BAAAKgAECgEIAQAAAA==.',['库萨']='库萨帕利:BAAAKgAFFAQIBAAAAA==.',['建南']='建南春春:BAABKgAFFH8GAAIXAAYICgpxFwAkAQAXAAYICgpxFwAkAQAAAA==.',['弹琴']='弹琴的猛牛:BAAAKgADCggICAAAAA==.',['影丢']='影丢丢:BAACKgAFFH8HAAIWAAMIXRs1KQDFAAAWAAMIXRs1KQDFAAAqAAQKfxkAAhYACAi9IvkIAJ8CABYACAi9IvkIAJ8CAAAA.',['影子']='影子邪手:BAAAKgAECgUIBQAAAA==.',['影琉']='影琉璃:BAAAKgADCgEIAQAAAA==.',['彳亍']='彳亍:BAAAKgAECgEIAQAAAA==.',['微分']='微分:BAAAKgADCgIIAgAAAA==.',['微风']='微风雨露:BAAAKgADCgEIAQAAAA==.',['心袁']='心袁灬懿马:BAACKgAFFH8KAAMIAAUISxM8KADOAAAIAAQIuxE8KADOAAAUAAEIjRmgEgBaAAAqAAQKfx8ABAgACAgLIYUVAEMCAAgACAj8IIUVAEMCAAkAAghzF3MSAIcAABQAAQiBIkdsAGEAAAEqAAUUCAglAAkAIRwA.',['快乐']='快乐德玩耍:BAAAKgAECgYIBgAAAA==.',['快雪']='快雪时晴:BAABKgAFFH8HAAIiAAYIiw4SEAAtAQAiAAYIiw4SEAAtAQAAAA==.',['恶魔']='恶魔低语:BAAAKgADCgEIAgAAAA==.',['惊异']='惊异卡布尔:BAAAKgAECgEIAQAAAA==.惊异玛格南:BAAAKgAECgYIBgAAAA==.惊异百式改:BAAAKgAECgcICQAAAA==.',['惩丨']='惩丨戒:BAAAKgAFFAEIAQAAAA==.',['想吃']='想吃刀削面:BAAAKgADCgQIBAAAAA==.',['慌得']='慌得一批:BAAAKgAECgIIAgAAAA==.',['憨憨']='憨憨小魔:BAAAKgAECgQIBAABKgAFFAYIBgAgAP8QAA==.憨憨小龙:BAACKgAFFH8GAAIgAAMI/xBPFgCbAAAgAAMI/xBPFgCbAAAqAAQKfxMAAyAACAhiHpgOAFwCACAACAhiHpgOAFwCACEAAwjbEJQaALUAAAAA.',['我卡']='我卡掉线了:BAAAKgAECgUIDgAAAA==.',['我又']='我又躲起来了:BAAAKgAECgEIAQAAAA==.',['我是']='我是奈珑:BAAAKgAECgMIAwAAAA==.我是真滴菜:BAACKgAFFH8GAAIIAAYIZxCAEQDfAAAIAAYIZxCAEQDfAAAqAAQKfxoAAhQABwisIQ8OABQCABQABwisIQ8OABQCAAAA.',['战神']='战神啤酒:BAAAKgAECgUIBwAAAA==.',['托柒']='托柒唔识转驳:BAABKgAFFH8LAAMIAAMIfxyCJQDdAAAIAAMIgRmCJQDdAAAUAAEIlyNeHgBqAAAAAA==.',['扛盾']='扛盾走天涯:BAAAKgAECgEIAQAAAA==.',['批鸨']='批鸨鸨:BAAAKgAFFAIIAgAAAA==.',['拉帝']='拉帝欧斯:BAAAKgAFFAYIAQAAAA==.',['拮据']='拮据:BAAAKgAECgMIAwAAAA==.',['拳脚']='拳脚双绝:BAAAKgAECgcIBwAAAA==.',['挺胸']='挺胸左放胯:BAABKgAFFH8GAAIPAAMIlBBiCwDTAAAPAAMIlBBiCwDTAAAAAA==.',['排骨']='排骨炖萝卜:BAAAKgADCggIFAAAAA==.',['接盘']='接盘侠:BAAAKgAFFAIIBAAAAA==.',['敬请']='敬请期待:BAAAKgAECggICAAAAA==.',['新流']='新流星蝴蝶贱:BAAAKgAFFAQIBAAAAA==.',['无可']='无可争议:BAABKgAFFH8GAAIVAAYIsRkuDQCeAQAVAAYIsRkuDQCeAQAAAA==.无可勇猛:BAAAKgAECgEIAQAAAA==.无可抗拒:BAABKgAFFH8MAAMLAAYIuB38CwDPAQALAAYIJR38CwDPAQAMAAYIrhZbBgBZAQAAAA==.无可烬临:BAAAKgAFFAYIAwAAAA==.无可隐匿:BAABKgAFFH8QAAIQAAYIShqHCADQAQAQAAYIShqHCADQAQAAAA==.',['无影']='无影邢者:BAAAKgADCgcIBwAAAA==.',['无聊']='无聊练小号耍:BAAAKgAECggIEQAAAA==.',['日瓦']='日瓦大军三:BAABKgAECn8UAAIUAAgIAhTPCAC3AQAUAAgIAhTPCAC3AQAAAA==.',['星尘']='星尘大海一:BAAAKgAECgEIAQAAAA==.',['星辰']='星辰小小喵:BAAAKgADCgEIAQAAAA==.',['春田']='春田花花男:BAAAKgAECggICAAAAA==.',['晓蘇']='晓蘇:BAAAKgAECggICwAAAA==.',['晴微']='晴微:BAAAKgADCgUIBQAAAA==.',['智轩']='智轩:BAAAKgADCgEIAQAAAA==.',['暖月']='暖月:BAAAKgAECgQICAAAAA==.',['暗夜']='暗夜之贪狼:BAAAKgAECgUIDwAAAA==.暗夜杀戮:BAAAKgAECgUIBQAAAA==.',['暮颜']='暮颜:BAAAKgAFFAgIBAAAAA==.',['暴躁']='暴躁的牛牛:BAAAKgAECggIEQAAAA==.',['曦曦']='曦曦儿:BAAAKgAECggICAAAAA==.',['月光']='月光傳說:BAAAKgAECggIEAAAAA==.',['月影']='月影流光:BAAAKgAECgUIBQAAAA==.',['月落']='月落风翎:BAABKgAFFH8HAAIWAAQIHg/+LQC0AAAWAAQIHg/+LQC0AAAAAA==.月落风萦:BAACKgAFFH8gAAIQAAUIoxxIDQAlAQAQAAUIoxxIDQAlAQAqAAQKfyUAAxAACAihHTYTAG0CABAACAihHTYTAG0CABEAAQgFFz5aAD8AAAAA.',['有时']='有时微风天:BAABKgAFFH8JAAMBAAgIdgZQEACcAQABAAgIdgZQEACcAQAbAAEIAAARMQAAAAAAAA==.',['杀戮']='杀戮本色丶:BAAAKgAFFAQIBAABKgAFFAgICAAVABcdAA==.',['杏花']='杏花雨沾衣:BAAAKgAECgQICAAAAA==.',['来不']='来不得神:BAAAKgAECgEIAQAAAA==.',['果酱']='果酱熊:BAABKgAECn8VAAIPAAgI0hfXHQDCAQAPAAgI0hfXHQDCAQAAAA==.',['枯木']='枯木之心:BAAAKgADCgEIAQAAAA==.',['柠檬']='柠檬味口香糖:BAAAKgAECgMIAwAAAA==.',['树皮']='树皮:BAAAKgADCgIIAgAAAA==.',['格蕾']='格蕾:BAAAKgAECgYIBgAAAA==.',['梅尔']='梅尔加斯:BAAAKgAECgIIAgAAAA==.',['梦里']='梦里丶寻香:BAAAKgAECgMIAwAAAA==.',['棒棒']='棒棒冰:BAAAKgAFFAQIBAAAAA==.',['橙年']='橙年老酒:BAAAKgADCggIEAAAAA==.',['欧狼']='欧狼:BAABKgAFFH8JAAIgAAcImRHmDACVAQAgAAcImRHmDACVAQAAAA==.',['欲辨']='欲辨已忘言:BAABKgAFFH8GAAIBAAYIIQ7RKABEAQABAAYIIQ7RKABEAQAAAA==.',['武大']='武大熊:BAAAKgAECgIIAgAAAA==.',['沐春']='沐春风:BAAAKgADCgcIBwAAAA==.',['没有']='没有游戏玩:BAAAKgADCggICAAAAA==.',['治疗']='治疗:BAAAKgAECgUIBQAAAA==.',['法爷']='法爷:BAAAKgAECgcIDAAAAA==.',['泯灭']='泯灭灬:BAABKgAFFH8PAAILAAcIKx4IBwAjAgALAAcIKx4IBwAjAgAAAA==.',['泰瑞']='泰瑞纳斯:BAACKgAFFH8oAAIBAAUIYiExIgBkAQABAAUIYiExIgBkAQAqAAQKfx8AAgEACAi8JLwWALwCAAEACAi8JLwWALwCAAAA.',['洗澡']='洗澡不打肥皂:BAAAKgADCgYIBgAAAA==.洗澡爱打肥皂:BAAAKgAECgMIAwAAAA==.',['洪流']='洪流:BAAAKgAECgUIBQAAAA==.',['洲泳']='洲泳糠丶正邪:BAAAKgAECgEIAQAAAA==.',['流星']='流星:BAABKgAFFH8GAAIgAAYIpAv1GAD8AAAgAAYIpAv1GAD8AAAAAA==.流星神殿:BAAAKgAFFAQIBAAAAA==.',['浅笑']='浅笑滢滢:BAAAKgAECggICAAAAA==.',['浮华']='浮华立夏:BAAAKgAECgcIBwAAAA==.',['海公']='海公牛:BAAAKgAECgIIAwAAAA==.',['涵涵']='涵涵坨:BAAAKgAECgIIAQAAAA==.',['淡淡']='淡淡的清风:BAAAKgAECgYIBgAAAA==.',['深处']='深处的祂:BAAAKgADCgMIAwAAAA==.',['深海']='深海海绵怪:BAAAKgAFFAIIAgAAAA==.',['清纯']='清纯钱钱:BAABKgAFFH8GAAIBAAMIlB23RADlAAABAAMIlB23RADlAAAAAA==.',['清蒸']='清蒸小奶牛:BAABKgAFFH8IAAISAAgI6BMdCwDjAQASAAgI6BMdCwDjAQAAAA==.',['清风']='清风拂过末梢:BAAAKgAECgUIBQAAAA==.',['渝州']='渝州熊猫叔:BAAAKgADCgQIBgAAAA==.',['游学']='游学者七味:BAAAKgAECgMIAwABKgAECgcIBwAEAAAAAA==.',['滝川']='滝川索菲亚:BAAAKgADCggICAAAAA==.',['潇洒']='潇洒哥:BAAAKgADCgIIAgAAAA==.',['火丨']='火丨球:BAAAKgAECgIIAgAAAA==.',['火因']='火因木仓:BAABKgAFFH8RAAMPAAQIQhWrCADoAAAPAAQIzxOrCADoAAACAAMIohHfFwC+AAAAAA==.',['灬梦']='灬梦迷离灬:BAABKgAFFH8KAAIFAAYI4wteEQA3AQAFAAYI4wteEQA3AQAAAA==.',['灬血']='灬血魇狂魔灬:BAAAKgAECgEIAQAAAA==.',['灵魂']='灵魂丶旋律:BAAAKgADCgQIBAAAAA==.',['炸小']='炸小鱼:BAAAKgAECggICAAAAA==.',['烈焰']='烈焰深寒:BAAAKgAECggIDAAAAA==.',['烈酒']='烈酒加冰:BAAAKgADCgIIAgAAAA==.',['烬燃']='烬燃:BAAAKgAECggIDAAAAA==.',['焉有']='焉有火光:BAAAKgAECgQIBAAAAA==.',['熊本']='熊本熊:BAAAKgAECggIEwAAAA==.熊本熊本熊:BAAAKgAECgYIBgAAAA==.',['爆米']='爆米花不甜丶:BAAAKgAFFAgIBAAAAA==.',['爱咋']='爱咋咋的:BAAAKgAECggIEAAAAA==.',['牛公']='牛公海公牛:BAAAKgADCggIDgAAAA==.',['牛富']='牛富贵:BAAAKgAFFAQIBAAAAA==.',['牛牛']='牛牛恶霸:BAAAKgADCggICAAAAA==.牛牛猛拉大电:BAABKgAECn8iAAIaAAgIHSIwEQBjAgAaAAgIHSIwEQBjAgAAAA==.牛牛超硬:BAAAKgAECggICQAAAA==.',['狐傲']='狐傲天:BAAAKgAECggICAAAAA==.',['猎意']='猎意:BAABKgAECn8YAAIjAAgImRkzBgDOAQAjAAgImRkzBgDOAQAAAA==.',['猛踹']='猛踹瘸子好腿:BAAAKgAECggIDwAAAA==.',['猥琐']='猥琐发育:BAABKgAECn8UAAIVAAcIrhkXPQCxAQAVAAcIrhkXPQCxAQAAAA==.',['猪太']='猪太妹:BAABKgAFFH8FAAICAAMIiAlXHgCRAAACAAMIiAlXHgCRAAAAAA==.',['猫想']='猫想和你洗澡:BAAAKgAECggICAAAAA==.',['玛奇']='玛奇朵:BAAAKgADCgIIAgAAAA==.',['玩宫']='玩宫射大鸟:BAAAKgAECgcIDgAAAA==.',['疯狂']='疯狂嘘曲:BAAAKgAFFAIIAgAAAA==.疯狂小书生:BAACKgAFFH8OAAMIAAYIWSNjCgDlAQAIAAYIWSNjCgDlAQAUAAIIaxYkKQBHAAAqAAQKfyIABAgABwgRIWMMANMBAAgABwjxH2MMANMBABQABAhWHng9AP4AAAkAAQh5F/Q6AEYAAAEqAAUUCAgUAAgAsSEA.疯狂小安安:BAAAKgAECggIEQAAAA==.疯狂敌克:BAAAKgAECgMIAwAAAA==.疯狂猎手:BAAAKgADCggIDwAAAA==.',['白火']='白火石:BAAAKgAECgUIBgAAAA==.',['百万']='百万伏特:BAABKgAFFH8iAAIXAAQIvSLWDAAsAQAXAAQIvSLWDAAsAQAAAA==.',['盼盼']='盼盼:BAAAKgADCggICAAAAA==.',['砍一']='砍一刀:BAABKgAFFH8FAAMLAAMISRrzDgD9AAALAAMISRrzDgD9AAAMAAIIKAyoHgBpAAAAAA==.',['破碎']='破碎战锤:BAAAKgADCgQIBAAAAA==.',['祖国']='祖国老花朵:BAAAKgADCggICAAAAA==.',['祖迪']='祖迪亚克:BAAAKgADCgIIAgAAAA==.',['祝青']='祝青海:BAAAKgAFFAQIBAAAAA==.',['神之']='神之悟智:BAAAKgAFFAIIAgAAAA==.',['神佑']='神佑圣光:BAAAKgAECgcICAAAAA==.',['神明']='神明自在天:BAABKgAFFH8OAAIQAAMIABxVHADjAAAQAAMIABxVHADjAAAAAA==.',['神谕']='神谕暗影:BAAAKgAECgYICAAAAA==.',['神龙']='神龙教主:BAAAKgAECgMIAwAAAA==.',['离晒']='离晒大谱:BAABKgAFFH8GAAIkAAMIbBi7DgDmAAAkAAMIbBi7DgDmAAAAAA==.',['秀气']='秀气翩翩:BAABKgAFFH8QAAMIAAgIhBGkBwAWAgAIAAgIhBGkBwAWAgAJAAQIZA3XCgDVAAABKgAFFAgIJQAJACEcAA==.',['种桃']='种桃花的熊猫:BAAAKgADCgIIAgAAAA==.',['第二']='第二丶夜温柔:BAABKgAFFH8FAAMdAAQIuAvECgCzAAAdAAQIuAvECgCzAAABAAEIAADclAAAAAAAAA==.',['筱筱']='筱筱花椒:BAAAKgAECgUIBQAAAA==.筱筱花椒呢:BAABKgAECn8aAAMGAAgIShZtIgDPAQAGAAgIShZtIgDPAQANAAQIOQP9YABvAAAAAA==.',['箭箭']='箭箭达:BAAAKgAECgEIAQAAAA==.',['粗糙']='粗糙黑色肉垫:BAABKgAFFH8NAAIeAAUIQw5ICQAQAQAeAAUIQw5ICQAQAQAAAA==.',['糊烂']='糊烂你的脸:BAAAKgAECgcICAAAAA==.',['红手']='红手光环:BAABKgAFFH8JAAISAAYInBC1GQBMAQASAAYInBC1GQBMAQAAAA==.',['红龙']='红龙女王:BAAAKgAECgIIAgAAAA==.',['组我']='组我强力熊坦:BAAAKgAECgIIAgAAAA==.',['绿意']='绿意盎然:BAAAKgAECgMIAwAAAA==.',['绿狙']='绿狙人:BAAAKgAECgcIBwAAAA==.',['缘来']='缘来梦醒:BAABKgAFFH8IAAMKAAYI3xC4DwAiAQAKAAQIWhO4DwAiAQASAAIIgBTFLQB7AAAAAA==.',['羁風']='羁風:BAAAKgAFFAgIAwAAAA==.',['羁风']='羁风:BAABKgAFFH8GAAIVAAMI6wn6HACzAAAVAAMI6wn6HACzAAAAAA==.',['羈风']='羈风:BAABKgAFFH8FAAIlAAMINAMfEABgAAAlAAMINAMfEABgAAAAAA==.',['群殴']='群殴凹凸曼:BAAAKgAFFAMIAwAAAA==.',['翩翩']='翩翩神韵:BAAAKgAFFAYIAgABKgAFFAgICAAKAN8QAA==.',['老婆']='老婆抱抱:BAABKgAECn8nAAIBAAgIvR0jEQBPAgABAAgIvR0jEQBPAgAAAA==.',['老子']='老子和你拼了:BAAAKgADCggICAAAAA==.',['胖之']='胖之煞丶:BAAAKgAECgYIBgABKgAFFAgIEwAbAA0TAA==.',['胸口']='胸口睡大锤:BAAAKgAECgEIAQAAAA==.',['自在']='自在极意:BAAAKgADCggICQAAAA==.',['芙蘭']='芙蘭朵露:BAAAKgAFFAIIAgAAAA==.',['花生']='花生殼殼:BAABKgAFFH8KAAIUAAMIYxtpBgDdAAAUAAMIYxtpBgDdAAAAAA==.',['英俊']='英俊的美丽:BAAAKgADCgMIAwAAAA==.',['莉莉']='莉莉娅斯:BAAAKgAECgEIAQAAAA==.',['菠萝']='菠萝丶汽水:BAAAKgAFFAMIAwABKgAFFAgICAAVABcdAA==.',['菲菲']='菲菲的乃乃:BAAAKgADCgEIAQAAAA==.',['萌虎']='萌虎掌:BAABKgAFFH8OAAMiAAYIeRIzCAAoAQAiAAYIeRIzCAAoAQAeAAQICw9YFgC1AAAAAA==.',['萝卜']='萝卜叔叔:BAAAKgADCggIEAAAAA==.',['萨鲁']='萨鲁加尔雷霆:BAAAKgAFFAQIAgAAAA==.',['落叶']='落叶知秋:BAAAKgAECgIIAgAAAA==.',['蓝之']='蓝之精灵:BAABKgAECn8UAAQGAAYIRxr5OABZAQAGAAYIRxr5OABZAQANAAEIgQ17ZQAoAAAcAAEIAABvpgAAAAAAAA==.',['虎啸']='虎啸山林:BAABKgAFFH8FAAIQAAUIqwcoFwABAQAQAAUIqwcoFwABAQAAAA==.',['虾子']='虾子:BAAAKgAECgEIAgAAAA==.',['蛋蛋']='蛋蛋三明治:BAAAKgAFFAQIAwAAAA==.',['蟲兒']='蟲兒飛:BAABKgAFFH8IAAIbAAgIbQW5DQAgAQAbAAgIbQW5DQAgAQAAAA==.',['血羿']='血羿:BAABKgAFFH8FAAMWAAMI0AJYKAA6AAAWAAMI+wFYKAA6AAAVAAEIxQVoYgAvAAAAAA==.',['血色']='血色蒙牛金帝:BAABKgAECn8rAAIKAAgIqho8HQC0AQAKAAgIqho8HQC0AQAAAA==.',['血骑']='血骑士阿尔达:BAABKgAFFH8IAAIbAAgInAFwCgDqAAAbAAgInAFwCgDqAAAAAA==.',['行旅']='行旅离落:BAABKgAFFH8KAAIiAAYIkQl0FQD5AAAiAAYIkQl0FQD5AAABKgAFFAgIBAAEAAAAAA==.',['裂空']='裂空影者:BAAAKgADCgIIAgAAAA==.',['西北']='西北砍王:BAACKgAFFH8GAAIRAAQI4g0JEQAEAQARAAQI4g0JEQAEAQAqAAQKfyMAAhEACAg6FgAWAN0BABEACAg6FgAWAN0BAAAA.',['要来']='要来一发嘛:BAAAKgAFFAIIAgAAAA==.',['谁之']='谁之盘中餐:BAAAKgADCggICAAAAA==.',['谁羊']='谁羊过小龙女:BAAAKgAECggICAAAAA==.',['豆子']='豆子鬼:BAAAKgADCggICAAAAA==.',['轩之']='轩之逸:BAAAKgADCggICAAAAA==.',['轻雨']='轻雨:BAACKgAFFH8cAAILAAUIFCHcBwAsAQALAAUIFCHcBwAsAQAqAAQKfyoAAgsACAjcInUTAI0CAAsACAjcInUTAI0CAAAA.',['迷你']='迷你呲花:BAAAKgAFFAQIBAABKgAFFAgIBAAEAAAAAA==.',['迷途']='迷途萌萌德:BAAAKgADCggIEwAAAA==.',['逃离']='逃离:BAAAKgAECgYIBgAAAA==.',['逆天']='逆天:BAACKgAFFH8GAAIHAAMI/g4cGQDFAAAHAAMI/g4cGQDFAAAqAAQKfxUAAwcACAg3Fn0dAGEBAAcACAjnFX0dAGEBACUABwjHCqY5ANEAAAAA.',['遗憾']='遗憾丶:BAAAKgADCggICQAAAA==.',['那个']='那个劣人丶:BAAAKgAECgQIBAAAAA==.',['那什']='那什么什么了:BAABKgAFFH8cAAMWAAQInCNhCwDxAAAWAAQIMR1hCwDxAAAVAAIItCMoLQDSAAAAAA==.',['邪神']='邪神:BAABKgAFFH8FAAIBAAMIVBhmHwDsAAABAAMIVBhmHwDsAAAAAA==.',['都是']='都是我德:BAAAKgAECggICAAAAA==.',['里丶']='里丶贝留斯:BAAAKgAFFAMIAwAAAA==.',['銀色']='銀色的永生:BAACKgAFFH8qAAImAAUIpRzcAQBTAQAmAAUIpRzcAQBTAQAqAAQKfzAABCYACAgYJCcDAHoCACYACAgYJCcDAHoCABkABwhlFv4VAJYBAAMAAQhnFX9FAEsAAAAA.',['闻夕']='闻夕:BAABKgAFFH8IAAIWAAgIShcrBAA9AgAWAAgIShcrBAA9AgAAAA==.',['阳光']='阳光天堂:BAABKgAFFH8KAAIXAAYIpRyJCQCtAQAXAAYIpRyJCQCtAQAAAA==.',['阴阳']='阴阳師:BAABKgAECn8ZAAQUAAgI+Am1MwAnAQAUAAgIFAm1MwAnAQAIAAMItAsCfgBSAAAJAAII9wM1QAAzAAAAAA==.',['阿兰']='阿兰:BAAAKgAFFAIIAgAAAA==.',['阿叉']='阿叉:BAAAKgAECggIDAAAAA==.',['阿特']='阿特兰斯猎风:BAABKgAFFH8VAAIVAAMI+iH9HAAdAQAVAAMI+iH9HAAdAQAAAA==.',['阿辉']='阿辉打电动:BAAAKgAECgcIEAAAAA==.',['随机']='随机名字:BAAAKgADCggIGAAAAA==.',['雪丶']='雪丶贱:BAAAKgADCgYIBgAAAA==.',['雷公']='雷公指:BAABKgAFFH8IAAMXAAYIRBP5EABNAQAXAAYIRBP5EABNAQAaAAIIEh0+GQCwAAAAAA==.',['雷恩']='雷恩加尔:BAAAKgAECgQICAAAAA==.',['雷欧']='雷欧大侠:BAABKgAFFH8IAAMPAAQIHhSiCgDaAAAPAAQIHhSiCgDaAAAFAAIIsAgHNAB5AAAAAA==.',['雷霆']='雷霆尛福神:BAAAKgADCgEIAQAAAA==.',['霖清']='霖清竹:BAAAKgAECgYIBgAAAA==.',['霜语']='霜语:BAAAKgAECgIIAwAAAA==.',['霸王']='霸王茶几:BAABKgAFFH8LAAMGAAcIsCL+AQBrAgAGAAcIsCL+AQBrAgAcAAQIGwqQIAChAAAAAA==.',['青燚']='青燚破晓:BAAAKgAECgYIBgAAAA==.',['青青']='青青子矜:BAABKgAFFH8IAAICAAgIwhD/BwACAgACAAgIwhD/BwACAgAAAA==.',['風的']='風的季节:BAAAKgAECgcIBwAAAA==.',['风花']='风花醉月:BAABKgAFFH8FAAIiAAUIASAPCwB1AQAiAAUIASAPCwB1AQAAAA==.',['饕餮']='饕餮:BAAAKgAECgcIBwAAAA==.',['馒头']='馒头猫:BAABKgAFFH8IAAIiAAUIPxVSEADlAAAiAAUIPxVSEADlAAAAAA==.',['骑龟']='骑龟看世界:BAABKgAECn8VAAMBAAcIkxdNawCCAQABAAcIkxdNawCCAQAbAAUIWwXDRgBhAAAAAA==.骑龟赏樱花:BAAAKgAECgcIEQAAAA==.骑龟逗蛐蛐:BAAAKgAECgcIDQAAAA==.骑龟闯红灯:BAAAKgAFFAIIAgAAAA==.',['魇灬']='魇灬:BAAAKgAFFAQIBAAAAA==.',['魔力']='魔力精灵:BAAAKgADCgUIBQAAAA==.',['鲜血']='鲜血:BAAAKgADCgEIAQAAAA==.',['鸡火']='鸡火味锅巴丶:BAABKgAFFH8GAAIQAAYIeA61DwBZAQAQAAYIeA61DwBZAQAAAA==.',['黑毛']='黑毛牛:BAAAKgAECggICAAAAA==.',['黯黑']='黯黑烈焰:BAAAKgAECggICAAAAA==.',['龍靈']='龍靈:BAAAKgAFFAQIBAAAAA==.龍靈儿:BAAAKgAFFAQIBAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end