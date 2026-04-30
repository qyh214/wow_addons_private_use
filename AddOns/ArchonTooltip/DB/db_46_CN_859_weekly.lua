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
--- the utf8 global is not available, so we polyfill utf8.offset so we can correctly find prefixes of utf8 strings
---@param str string
---@param index number
---@return number|nil
local function Utf8Offset(str, index)
	local len = #str

	if index <= 0 or index > len then
		return nil -- Out of bounds
	end

	-- Move forward to the nth character
	local count = 0
	for i = 1, len do
		local byte = string.byte(str, i)
		local isContinuationByte = byte >= 128 and byte < 192
		if not isContinuationByte then
			count = count + 1
			if count == index then
				return i
			end
		end
	end

	return nil -- If the nth character is not found
end

---@param table table<string, string> raw data table with character name prefixes as keys
---@param length number the number of complete characters to include in the prefix
---@return fun(characterName: string):string|nil getChunk function to retrieve a character chunk by prefix using a complete character name
local function getChunkLookup(table, length)
	return function(characterName)
		local startOfNextCharacter = Utf8Offset(characterName, length + 1)

		local prefix
		if startOfNextCharacter == nil then
			prefix = characterName
		else
			prefix = string.sub(characterName, 1, startOfNextCharacter - 1)
		end

		return table[prefix]
	end
end

local lookup = {'Unknown-Unknown','Druid-Guardian','Mage-Frost','Priest-Discipline','DeathKnight-Unholy','Evoker-Augmentation','Monk-Brewmaster','Monk-Windwalker','Warrior-Fury','Warlock-Demonology','Warlock-Destruction','Paladin-Retribution','Druid-Restoration','Druid-Balance','Priest-Holy','Rogue-Subtlety','DeathKnight-Blood','Warrior-Arms','Evoker-Devastation','Paladin-Holy','Priest-Shadow','Evoker-Preservation','DemonHunter-Vengeance','DemonHunter-Havoc','DemonHunter-Devourer','Hunter-Marksmanship','Rogue-Assassination','Warrior-Protection','Hunter-BeastMastery','Warlock-Affliction','Paladin-Protection',}
local provider = {region='CN',realm='阿克蒙德',name='CN',type='weekly',zone=46,date='2026-04-25',data={Ak='Akx:BAAALgAECgEJAQAAAA==.',
Al='Alto:BAAALgADCgUJCQAAAA==.',
An='Anillusion:BAAALgAECgQJBAAAAA==.',
Au='Audiliu:BAAALgAECgQJBAAAAA==.',
Bl='Blinkstrike:BAAALgADCgYJBgAAAA==.',
Br='Bricassart:BAAALgAECgEJAQAAAA==.',
Ca='Caber:BAAALgAECgYJAgABLgAECgkJCgABAAAAAA==.',
De='Dedebadedesm:BAAALgAECgYJDAAAAA==.Derhe:BAAALgAECgEJAgAAAA==.',
Do='Douemperor:BAAALgAECgkJCQAAAA==.',
Du='Duncan:BAAALgAFFAEJAgAAAA==.',
Ex='Exc:BAAALgAECgIJAgAAAA==.',
Fa='Fango:BAAALgAECgcJBwAAAA==.',
Fh='Fholykiller:BAAALgAECgYJCwAAAA==.',
Ga='Garuru:BAACLgAFFH8JAAICAAQJNAmmAwCrAAACAAQJNAmmAwCrAAAuAAQKfxUAAgIACAkhGEUIACkCAAIACAkhGEUIACkCAAAA.',
Go='Goat:BAABLgAFFH8FAAIDAAUJnRu3CADbAQADAAUJnRu3CADbAQAAAA==.Goner:BAAALgAECgEJAQAAAA==.Goodend:BAAALgAECgQJBAAAAA==.',
Ha='Habits:BAAALgAECgQJBgAAAA==.Halfyear:BAAALgAECgYJBgABLgAFFAMJBwAEADEZAA==.Hanni:BAACLgAFFH8FAAIFAAMJHh2uHwAcAQAFAAMJHh2uHwAcAQAuAAQKfx8AAgUACAloI4IVAPsCAAUACAloI4IVAPsCAAAA.',
He='Heavensgate:BAAALgAECgUJDgAAAA==.',
Hi='Hibi:BAAALgAECgUJBgAAAA==.',
Ig='Iggy:BAAALgAECgcJBwAAAA==.',
Ja='Jaermasix:BAAALgAECgYJBgAAAA==.',
Jo='Jolyne:BAAALgAECgYJDAAAAA==.',
Kh='Khun:BAABLgAFFH8FAAIFAAIJbRj7IQCdAAAFAAIJbRj7IQCdAAAAAA==.',
Km='Kmii:BAAALgAECgQJBAAAAA==.',
Lu='Luckyday:BAAALgADCgEJAQAAAA==.',
Ly='Lyerch:BAABLgAECn8UAAIFAAcJZhf3ewCMAQAFAAcJZhf3ewCMAQAAAA==.',
Ma='Magica:BAAALgAECgYJCAAAAA==.Marlbore:BAAALgAFFAEJAQAAAA==.',
Md='Mdangel:BAAALgAECgcJDAABLgAFFAcJBgAGADUaAA==.',
Me='Memoryoo:BAAALgAFFAQJBAAAAA==.',
Ni='Niicorobin:BAAALgAECgIJBAAAAA==.',
Nn='Nnyaa:BAAALgAECgYJBgAAAA==.',
No='Nodps:BAAALgAECgIJAgAAAA==.',
Nt='Ntrdk:BAAALgAECgYJCwAAAA==.',
Om='Omnipotent:BAAALgADCgMJAwAAAA==.',
On='Oneplus:BAAALgAFFAQJBAAAAA==.',
Pl='Playermhyfks:BAAALgAECgIJAgAAAA==.Playeroqpwfc:BAAALgADCgYJCgAAAA==.',
Pm='Pmeight:BAAALgAFFAQJAQAAAA==.Pmfive:BAAALgAFFAQJAQAAAA==.Pmfour:BAAALgAFFAUJAQAAAA==.Pmseven:BAAALgAFFAUJAgAAAA==.Pmsix:BAAALgAFFAQJAQAAAA==.',
Pr='Prime:BAAALgAECgQJBQAAAA==.',
Ri='Rick:BAAALgADCgYJBgAAAA==.',
Sa='Samgha:BAABLgAFFH8JAAMHAAMJQh1vDQC4AAAHAAMJQh1vDQC4AAAIAAEJBgxFCwBOAAAAAA==.',
Su='Sumiya:BAAALgAFFAIJBgAAAQ==.Suy:BAAALgAECgYJBwAAAA==.',
Ta='Tacoliu:BAABLgAECn8UAAIJAAcJnB8kIwA8AgAJAAcJnB8kIwA8AgAAAA==.',
Un='Underground:BAAALgAECgMJAwAAAA==.Underneath:BAAALgAECgMJAwAAAA==.Underwater:BAAALgAFFAEJAQAAAA==.',
Wo='Wordbrother:BAAALgAECgEJAQAAAA==.',
Xi='Xiaopi:BAAALgADCgUJBQAAAA==.Xingtu:BAAALgAFFAIJAgAAAA==.',
Zo='Zombie:BAAALgAFFAEJAQAAAA==.',
Zr='Zrwang:BAABLgAFFH8YAAIDAAYJlB7uAQDGAQADAAYJlB7uAQDGAQAAAA==.',
['Äå']='Äåæçëk:BAAALgADCgIJAgAAAA==.',
['一剑']='一剑丹心:BAAALgAECgUJBwAAAA==.',
['一把']='一把大宝剑:BAAALgADCgEJAQAAAA==.',
['一起']='一起烧树吧:BAAALgADCgEJAQAAAA==.',
['七阳']='七阳贯日:BAAALgAECgQJBgAAAA==.',
['三世']='三世逍遥:BAAALgAFFAIJBAAAAA==.',
['三号']='三号人间大炮:BAABLgAFFH8HAAMKAAUJixH+IQD8AAAKAAUJixH+IQD8AAALAAEJcwW1GABMAAAAAA==.',
['不凿']='不凿不如死:BAAALgAFFAEJAgAAAA==.',
['不正']='不正经电疗:BAAALgAECgEJAQAAAA==.',
['世界']='世界尽头的你:BAAALgADCgEJAgAAAA==.',
['两手']='两手都要抓:BAAALgAECgUJBQAAAA==.',
['丨初']='丨初见丨:BAAALgADCgYJBgAAAA==.',
['丨寅']='丨寅丸星丨:BAAALgAECgcJDAAAAA==.',
['丨悠']='丨悠悠我心:BAAALgAECgYJEwAAAA==.',
['丨星']='丨星木:BAAALgAFFAMJBAAAAA==.',
['丨灬']='丨灬烟雨:BAAALgAECgYJBgAAAA==.',
['丨龍']='丨龍神灬:BAAALgAECgQJBAAAAA==.',
['中森']='中森明菜:BAAALgAECgEJAQAAAA==.',
['临东']='临东橙柚子:BAAALgAECgUJBQAAAA==.',
['临冬']='临冬橙枇杷:BAAALgAECgQJBgAAAA==.',
['丶亵']='丶亵渎之影:BAAALgAECgQJBQAAAA==.',
['丶张']='丶张学友丶:BAAALgAECgEJAQAAAA==.',
['丶当']='丶当归:BAAALgAFFAIJAgAAAA==.',
['丶星']='丶星烨:BAAALgAFFAEJAgAAAA==.',
['丶梦']='丶梦的婚礼:BAAALgAECgEJAQAAAA==.',
['丶灵']='丶灵魂:BAAALgAECgEJAQAAAA==.',
['丶白']='丶白粥:BAAALgAECgEJAQAAAA==.',
['丶百']='丶百善孝为先:BAAALgAECgEJAgAAAA==.',
['丶芍']='丶芍药:BAAALgAFFAIJBAAAAA==.',
['为你']='为你倾尽一切:BAAALgAECgUJCQAAAA==.',
['丿秀']='丿秀逗灬回憶:BAAALgAECgMJAwAAAA==.',
['乖小']='乖小豆:BAAALgAECgEJAQAAAA==.',
['乘风']='乘风飘飘:BAAALgADCgQJAgAAAA==.',
['九字']='九字刺印:BAAALgAECgYJCwAAAA==.',
['二号']='二号人间大炮:BAABLgAFFH8HAAMKAAUJZxLPDwBhAQAKAAQJ5hXPDwBhAQALAAMJ4w2XBwD2AAAAAA==.',
['云与']='云与山的彼端:BAAALgAECgEJAQAAAA==.',
['云海']='云海:BAAALgAECgMJAwAAAA==.',
['云逸']='云逸:BAAALgAECgEJAQAAAA==.',
['亚哈']='亚哈丶囧炯囧:BAAALgAFFAEJAQAAAA==.',
['亚里']='亚里莎:BAAALgAECgEJAQABLgAECgYJBwABAAAAAA==.',
['人不']='人不再少年:BAABLgAFFH8GAAIMAAMJnQvjDgDpAAAMAAMJnQvjDgDpAAAAAA==.',
['仙心']='仙心呐:BAAALgADCgEJAQAAAA==.',
['仙芋']='仙芋奶喵:BAAALgADCgEJAQAAAA==.',
['伊利']='伊利球:BAAALgAECgcJCwAAAA==.',
['伊慕']='伊慕:BAACLgAFFH8LAAINAAQJkhXxBQA5AQANAAQJkhXxBQA5AQAuAAQKfxQAAw0ABgn8HfwqAAUCAA0ABgn8HfwqAAUCAA4ABgm+I+wsAJsBAAAA.',
['低调']='低调的竖式:BAAALgADCgYJBgAAAA==.',
['你叫']='你叫潮汐是吧:BAAALgAECgEJAQABLgAFFAYJFwAPANsRAA==.',
['依然']='依然丶安然:BAAALgADCgYJBgAAAA==.',
['假面']='假面骑士剑:BAAALgAFFAEJAQAAAA==.',
['像大']='像大佬学习:BAAALgAECgEJAgAAAA==.',
['光粒']='光粒一号:BAAALgAFFAQJBAAAAA==.光粒四号:BAAALgAFFAQJBAAAAA==.',
['克拉']='克拉克:BAABLgAFFH8FAAIDAAUJVgVEEgCEAQADAAUJVgVEEgCEAQAAAA==.',
['兔子']='兔子:BAAALgADCgUJCQAAAA==.',
['八及']='八及大狂风:BAAALgAECgYJBgAAAA==.',
['兰林']='兰林王:BAAALgADCgMJAwAAAA==.',
['兵长']='兵长:BAACLgAFFH8KAAIQAAMJghW2BgAOAQAQAAMJghW2BgAOAQAuAAQKfxsAAhAABgmpG3EgAPYBABAABgmpG3EgAPYBAAAA.',
['其实']='其实我是头熊:BAAALgAECgQJBwAAAA==.',
['兽儿']='兽儿:BAAALgAECgEJAQAAAA==.',
['再见']='再见枫叶红:BAAALgAECgYJCAAAAA==.',
['冬凌']='冬凌术:BAABLgAFFH8LAAIKAAQJVRKxCwA0AQAKAAQJVRKxCwA0AQAAAA==.',
['冰与']='冰与火之戨:BAAALgADCgEJAQAAAA==.',
['冰火']='冰火奥:BAAALgAECgUJBQAAAA==.',
['冰霜']='冰霜小白龙:BAAALgAFFAIJBAAAAA==.',
['冷烨']='冷烨丶:BAAALgAECgEJAwAAAA==.',
['凊氺']='凊氺洮孓:BAAALgAECgkJBgAAAA==.',
['刘备']='刘备丶:BAAALgAECgQJCgAAAA==.',
['利佩']='利佩之乘黄:BAACLgAFFH8MAAIRAAQJcgFhCACQAAARAAQJcgFhCACQAAAuAAQKfx0AAhEACAk+Bp0kABsBABEACAk+Bp0kABsBAAAA.利佩之九尾:BAAALgAECgMJAwAAAA==.',
['剑气']='剑气浪荡:BAAALgADCgQJAwAAAA==.',
['剑胆']='剑胆琴心侠骨:BAAALgAECgEJAQAAAA==.',
['力透']='力透宣纸背:BAAALgAECgEJAgAAAA==.',
['努力']='努力的探长:BAAALgAFFAEJAQAAAA==.努力的赵老师:BAAALgAECgEJAQAAAA==.',
['動手']='動手動脚:BAAALgAFFAQJBAABLgAFFAgJGAACAFobAA==.',
['勿唯']='勿唯沫矢:BAAALgAECgEJAQAAAA==.',
['化蝶']='化蝶飞舞:BAAALgAECgEJAwAAAA==.',
['北京']='北京理工大学:BAAALgAECgUJBgAAAA==.',
['匹仕']='匹仕不仕:BAAALgAECgUJBgAAAA==.',
['匹士']='匹士不士:BAAALgAECgQJCQAAAA==.',
['匹式']='匹式不式:BAAALgAECgYJDQAAAA==.',
['十大']='十大高手:BAAALgADCgYJBgAAAA==.',
['千千']='千千结:BAAALgAFFAIJAgAAAA==.',
['千山']='千山月:BAAALgAECgEJAQAAAA==.',
['半伤']='半伤残人士:BAAALgADCgcJBwAAAA==.',
['卓明']='卓明:BAABLgAFFH8JAAIDAAUJVhq3HABYAQADAAUJVhq3HABYAQAAAA==.',
['卢克']='卢克天行者:BAAALgAECgkJDwABLgAFFAYJCgASAH4fAA==.',
['危猎']='危猎仙班:BAAALgAECgcJDAAAAA==.',
['厨师']='厨师猫猫:BAAALgAECgEJAgAAAA==.',
['双剑']='双剑茶盾:BAAALgAECgEJAQAAAA==.',
['双花']='双花红棍:BAAALgAECgYJBgAAAA==.',
['变形']='变形的阿坤达:BAAALgAECgYJDAAAAA==.',
['变态']='变态曹小花:BAAALgAECgUJBQAAAA==.',
['叫狗']='叫狗咬死你:BAAALgADCgQJBQAAAA==.',
['叶知']='叶知秋:BAAALgAECgEJAQAAAA==.',
['吃枣']='吃枣药丸:BAACLgAFFH8WAAMKAAYJsg0kAgCcAQAKAAYJsg0kAgCcAQALAAEJqQFdGgBFAAAuAAQKfyMAAwoACQkVI0EbALECAAoACAkEIkEbALECAAsABQlQIUsEADEBAAAA.',
['吉祥']='吉祥妞妞:BAAALgAECgIJAgAAAA==.',
['君与']='君与决丶:BAAALgADCgEJAQAAAA==.',
['吥言']='吥言灬而咲:BAAALgAECgYJDQAAAA==.',
['呼呼']='呼呼儿:BAAALgADCgEJAQAAAA==.',
['咕噜']='咕噜咕噜哈:BAAALgAECgEJAQAAAA==.',
['哦吼']='哦吼哦吼:BAAALgAECgMJAwAAAA==.',
['唯我']='唯我轻狂:BAAALgAECgIJAgAAAA==.',
['喵喵']='喵喵球:BAAALgAECgYJBgAAAA==.',
['喷不']='喷不出眼棱:BAAALgAECgEJAQAAAA==.',
['噩魔']='噩魔猎手:BAAALgADCgUJBQAAAA==.',
['四十']='四十四次日落:BAAALgADCgcJCwAAAA==.',
['四海']='四海皆兄弟:BAAALgAECgYJBgAAAA==.',
['因爱']='因爱而生:BAAALgADCgEJAQAAAA==.',
['囧囧']='囧囧小超人:BAAALgAECgEJAwAAAA==.',
['图拉']='图拉斯:BAAALgAECgIJAgAAAA==.',
['土炮']='土炮:BAAALgAECgQJBgAAAA==.',
['土鳖']='土鳖坏:BAAALgADCgIJAgAAAA==.',
['圣光']='圣光于我心:BAAALgADCgEJAgAAAA==.圣光冲钅:BAAALgAECgkJCwAAAA==.圣光大喷子:BAAALgAFFAMJAwAAAA==.圣光忽悠:BAAALgAECgUJBQABLgAFFAMJAwABAAAAAA==.圣光抓着你:BAAALgAECgIJAgABLgAFFAMJAwABAAAAAA==.',
['圣园']='圣园未花:BAAALgAECgYJBwAAAA==.',
['圣型']='圣型尤物:BAACLgAFFH8SAAIGAAUJFiPNAgAOAgAGAAUJFiPNAgAOAgAuAAQKfxoAAwYACQmVG/4NAJUCAAYACQlaGv4NAJUCABMABwncFF4RAMkBAAAA.',
['圣小']='圣小骑:BAAALgAECgMJAwAAAA==.',
['坏掉']='坏掉的小鱼:BAABLgAECn8RAAIKAAgJFhYRVQDIAQAKAAgJFhYRVQDIAQAAAA==.',
['塞纳']='塞纳牛斯:BAAALgAFFAIJAwAAAA==.',
['多吃']='多吃恩熙玛:BAAALgAECgcJAQAAAA==.',
['夜雨']='夜雨暮色:BAAALgAECgUJBgAAAA==.',
['大喵']='大喵喵会闪现:BAAALgADCgMJAwAAAA==.',
['大师']='大师兄的圣光:BAABLgAECn8UAAIUAAcJWxxsHgAkAgAUAAcJWxxsHgAkAgAAAA==.',
['大德']='大德子:BAAALgAECgEJAQAAAA==.',
['大牙']='大牙大下巴:BAAALgAECgcJCgAAAA==.',
['大犄']='大犄角牛牛:BAAALgAECgEJAQAAAA==.',
['大猪']='大猪脸萌猎:BAAALgADCgQJBAAAAA==.',
['大米']='大米遛狗:BAAALgAECgEJAQAAAA==.',
['大金']='大金镏子:BAABLgAECn8dAAIUAAgJqxZzHgAjAgAUAAgJqxZzHgAjAgAAAA==.',
['天使']='天使的惩戒:BAAALgAECgEJAQAAAA==.',
['天堂']='天堂咆哮:BAAALgAECgcJCgAAAA==.',
['天舞']='天舞野望:BAABLgAFFH8HAAIOAAIJ+BaPCgCqAAAOAAIJ+BaPCgCqAAAAAA==.',
['天蓙']='天蓙:BAAALgAECgUJBQAAAA==.',
['天降']='天降奇缘:BAAALgAECgkJCQAAAA==.',
['太空']='太空浪子:BAAALgAECgEJAQAAAA==.',
['奋斗']='奋斗异族:BAAALgAECgIJAgAAAA==.',
['女神']='女神:BAAALgAFFAEJAQAAAA==.',
['奶命']='奶命贵:BAAALgAECgUJBgAAAA==.',
['好基']='好基友好朋友:BAAALgAECgEJAQAAAA==.',
['妖精']='妖精圆桌领域:BAAALgAECgUJBAAAAA==.',
['娜串']='娜串要火:BAAALgADCgIJAgAAAA==.',
['安娜']='安娜斯塔西娅:BAAALgAECgYJCQAAAA==.',
['安格']='安格斯厚牛堡:BAAALgAECgcJBwABLgAFFAIJBwAHALwTAA==.',
['宠不']='宠不比人强:BAAALgAECgYJCQAAAA==.',
['寄摆']='寄摆:BAAALgAECgYJBgAAAA==.',
['寒月']='寒月光:BAAALgADCgEJAQAAAA==.',
['小小']='小小菜籽:BAAALgAECggJCAAAAA==.',
['小德']='小德练习生:BAAALgADCgUJDQABLgAECgcJFQAFAPEZAA==.',
['小心']='小心脚下:BAAALgAFFAIJAgAAAA==.',
['小早']='小早川紗枝:BAABLgAECn8ZAAMEAAcJdCDHCgCLAgAEAAcJdCDHCgCLAgAVAAcJAxV7JwCcAQABLgAFFAUJAgABAAAAAA==.',
['小眠']='小眠羊:BAAALgAECgEJAQAAAA==.',
['山丘']='山丘丶:BAAALgAFFAIJAwAAAA==.',
['岸上']='岸上:BAAALgADCgcJBwAAAA==.',
['巴鲁']='巴鲁和胖虎:BAAALgAFFAQJBAAAAA==.',
['帅小']='帅小余:BAAALgADCgEJAQAAAA==.',
['帝冲']='帝冲:BAABLgAFFH8JAAIWAAQJ+SQ+BAC7AQAWAAQJ+SQ+BAC7AQAAAA==.',
['带球']='带球撞人:BAAALgAECgEJAQAAAA==.',
['常务']='常务副山羊:BAAALgAFFAQJBAAAAA==.',
['干净']='干净又卫生:BAAALgAECgEJAQAAAA==.',
['幽鬼']='幽鬼之刃:BAAALgAECgUJCgAAAA==.',
['强壮']='强壮白勺牛牛:BAAALgADCgEJAQAAAA==.',
['得得']='得得捌得得:BAAALgAECgUJCwAAAA==.',
['快乐']='快乐小男孩:BAABLgAFFH8KAAIEAAMJDyTWBgAaAQAEAAMJDyTWBgAaAQAAAA==.快乐牛东东:BAAALgADCgYJBgAAAA==.',
['怒刚']='怒刚正面君:BAAALgAECgYJBgAAAA==.',
['恶魔']='恶魔天空:BAAALgAECgMJAwAAAA==.',
['悲伤']='悲伤飘落:BAAALgAECgIJBAAAAA==.',
['悲夜']='悲夜:BAAALgAECgEJAQAAAA==.',
['惟贤']='惟贤惟德:BAAALgADCgEJAQAAAA==.',
['惩戒']='惩戒在我心:BAAALgAFFAEJAQAAAA==.',
['想去']='想去哪:BAAALgADCgEJAQAAAA==.',
['愛罗']='愛罗:BAACLgAFFH8FAAIOAAMJygiqDwDnAAAOAAMJygiqDwDnAAAuAAQKfxYAAw4ABgmgGrQuAI8BAA4ABgmgGrQuAI8BAA0AAglbFcSsAGwAAAAA.',
['感受']='感受一下啦:BAAALgADCgEJAQAAAA==.',
['懒洋']='懒洋洋:BAAALgAECgkJBgAAAA==.',
['成龙']='成龙:BAAALgAECgEJAQAAAA==.',
['我不']='我不要糖:BAAALgAECgUJBQAAAA==.',
['我吉']='我吉利起来了:BAAALgAECgYJBgAAAA==.',
['我得']='我得换副骰子:BAAALgAECgQJBAAAAA==.',
['我爱']='我爱吃油条丶:BAAALgAECgkJEQAAAA==.我爱推塔塔:BAAALgADCgUJBQAAAA==.',
['戚戚']='戚戚:BAAALgAFFAMJAwAAAA==.',
['戰彡']='戰彡孤鳶:BAAALgAECgEJAQAAAA==.',
['打败']='打败我没烦恼:BAAALgAECgkJCQAAAA==.',
['扭曲']='扭曲的神圣:BAAALgAECgEJAQAAAA==.',
['把盏']='把盏几许疏狂:BAABLgAFFH8FAAIXAAMJpx1SAQAKAQAXAAMJpx1SAQAKAQABLgAFFAMJCQAHAEIdAA==.',
['拉塔']='拉塔恩:BAAALgAECgQJBAAAAA==.',
['拉莎']='拉莎加尔:BAABLgAECn8XAAIMAAkJvxW7OABAAgAMAAkJvxW7OABAAgAAAA==.',
['拉鲁']='拉鲁夫:BAAALgAFFAQJBAAAAA==.',
['拳打']='拳打膝盖骨:BAAALgADCgUJAQAAAA==.',
['捕風']='捕風:BAAALgAECgIJAgAAAA==.',
['摇滚']='摇滚按摩师:BAACLgAFFH8JAAIYAAQJoh2JBAApAQAYAAQJoh2JBAApAQAuAAQKfxUAAxgACAkEHNAQAFsCABgABwleHtAQAFsCABkABAmTFauHABYBAAAA.',
['摔个']='摔个屁屁墩:BAAALgAECgYJDgAAAA==.',
['撒油']='撒油娜娜:BAAALgADCgEJAQAAAA==.',
['撒野']='撒野:BAABLgAECn8ZAAIOAAgJZhVTGQA8AgAOAAgJZhVTGQA8AgAAAA==.',
['撸猫']='撸猫摸狗头:BAAALgAECgUJCAAAAA==.',
['散仙']='散仙静:BAABLgAECn8UAAIVAAkJmQyWJwCcAQAVAAkJmgyWJwCcAQAAAA==.',
['斯巴']='斯巴达捕兽机:BAAALgAECgIJAgAAAA==.',
['无限']='无限翼王:BAAALgAECgEJAQAAAA==.',
['旱地']='旱地拔葱:BAAALgADCgcJCAAAAA==.',
['时光']='时光鸡:BAAALgADCgcJAQAAAA==.',
['旺德']='旺德福:BAAALgAECgkJAQAAAA==.',
['明星']='明星:BAAALgADCgMJAwAAAA==.',
['明暗']='明暗交界线:BAAALgAECgkJBgAAAA==.',
['明里']='明里紬:BAAALgAECgUJBQAAAA==.',
['是四']='是四喜呀:BAAALgAECgEJAQAAAA==.',
['晋哥']='晋哥铁马:BAAALgAECgQJBQAAAA==.',
['晓球']='晓球球:BAAALgADCgYJBgAAAA==.',
['晓龙']='晓龙人:BAAALgAECgIJAgAAAA==.',
['晚风']='晚风甜:BAAALgADCgcJBwABLgAFFAYJEwAaANwlAA==.',
['暗伤']='暗伤月煞:BAACLgAFFH8OAAMQAAUJggeIBgB4AQAQAAUJggeIBgB4AQAbAAEJ7QEhBwBTAAAuAAQKfyEAAxAACAnREzsaADACABAACAnREzsaADACABsAAQnQCkAeADwAAAAA.',
['暴躁']='暴躁的阿眯:BAAALgAECgEJAQAAAA==.',
['曾经']='曾经的梦想:BAAALgAECgQJBQAAAA==.',
['最後']='最後的圣光:BAABLgAECn8WAAIFAAgJYCG1GgDdAgAFAAgJYCG1GgDdAgAAAA==.',
['月之']='月之感染:BAAALgAECgMJAwAAAA==.',
['月缺']='月缺:BAAALgAECgEJAQAAAA==.',
['有归']='有归无:BAAALgADCgIJAgAAAA==.',
['朋友']='朋友这对吗:BAAALgAECgMJAwAAAA==.',
['望不']='望不穿的秋水:BAAALgAECgcJBwAAAA==.',
['木梨']='木梨小猎:BAAALgAFFAEJAQAAAA==.',
['杉木']='杉木水影:BAAALgAFFAIJAwAAAA==.',
['板甲']='板甲职业:BAABLgAECn8ZAAIcAAkJnwTcGACMAQAcAAkJnwTcGACMAQAAAA==.',
['枭老']='枭老板:BAAALgAECgYJBgAAAA==.',
['枭萌']='枭萌萌:BAAALgAECgQJBAAAAA==.',
['标准']='标准化分锅师:BAAALgAECgQJBQAAAA==.',
['桂妮']='桂妮薇儿:BAAALgADCgUJBQAAAA==.',
['梅森']='梅森义子:BAAALgAECgEJAQAAAA==.',
['梦可']='梦可喵:BAAALgADCgYJBgAAAA==.',
['椛与']='椛与爱丽丝:BAACLgAFFH8HAAMPAAIJAg4pDwCFAAAEAAIJUAjXCwCOAAAPAAIJfQopDwCFAAAuAAQKfxgAAw8ABwmAG2koAK0BAA8ABgmLF2koAK0BAAQABgkEFVMhAIkBAAAA.',
['欢欢']='欢欢小红手:BAACLgAFFH8FAAIPAAIJLhtuCwCsAAAPAAIJLhtuCwCsAAAuAAQKfxgAAw8ACQlNHF4VADICAA8ABwmSG14VADICABUAAwlIDT5HAMYAAAAA.',
['歌者']='歌者甲一:BAAALgAFFAQJBAAAAA==.',
['武神']='武神太斗:BAAALgAECgQJBAAAAA==.',
['死亡']='死亡湮灭:BAABLgAECn8VAAIFAAcJ8RkATQAMAgAFAAcJ8RkATQAMAgAAAA==.',
['死神']='死神杜兰特:BAAALgAECgQJBQAAAA==.',
['残酷']='残酷雪碧:BAAALgADCgIJAgAAAA==.',
['毛球']='毛球喵:BAAALgAECgYJCwAAAA==.',
['水断']='水断波:BAAALgADCgYJBgAAAA==.',
['水滴']='水滴一号:BAAALgAFFAUJAgAAAA==.水滴七号:BAAALgAFFAUJBAAAAA==.水滴三号:BAAALgAFFAQJAQAAAA==.水滴九号:BAAALgAFFAQJBAAAAA==.水滴五号:BAAALgAFFAUJAgAAAA==.水滴八号:BAABLgAFFH8IAAIdAAUJBBN9BABaAQAdAAUJBBN9BABaAQAAAA==.水滴六号:BAAALgAFFAUJBAAAAA==.水滴十号:BAAALgAFFAMJAgAAAA==.',
['永灭']='永灭:BAAALgAECgEJAQAAAA==.',
['氹仔']='氹仔鸡:BAAALgAECgkJBgAAAA==.',
['池田']='池田伊莱莎:BAAALgAECgQJCAAAAA==.',
['沐小']='沐小边:BAAALgAECgkJDQAAAA==.',
['法斯']='法斯:BAAALgADCgQJBAAAAA==.',
['波塞']='波塞枫妮:BAABLgAFFH8HAAIMAAIJOBjvIQCpAAAMAAIJOBjvIQCpAAAAAA==.',
['泰罗']='泰罗丶:BAAALgAECgIJAgAAAA==.',
['泽塔']='泽塔奥特曼:BAAALgADCgEJAQAAAA==.',
['流氓']='流氓灬奶骑:BAAALgAECgcJDgAAAA==.流氓灬战神:BAABLgAECn8YAAMJAAcJrQ9wQACiAQAJAAcJpw9wQACiAQAcAAIJNQljFwBHAAAAAA==.流氓灬猎手:BAAALgAECgQJBAAAAA==.',
['浅尝']='浅尝丶小岚芽:BAAALgAECgUJBgAAAA==.',
['浅紫']='浅紫色火法:BAAALgAFFAIJAgAAAA==.',
['浮生']='浮生速流电:BAAALgAFFAIJBAAAAA==.',
['海森']='海森堡:BAABLgAFFH8JAAIdAAMJ9R8NBwAwAQAdAAMJ9R8NBwAwAQAAAA==.',
['涉麝']='涉麝:BAAALgADCgUJBQAAAA==.',
['深海']='深海一棵葱:BAAALgADCgUJBQAAAA==.',
['深渊']='深渊之光:BAAALgAECgUJCAAAAA==.',
['混老']='混老头:BAAALgAECgYJBgAAAA==.',
['潘达']='潘达玛丽亚:BAAALgAECgcJCQAAAA==.',
['潜水']='潜水艇司机:BAAALgAECgEJAQAAAA==.',
['灬轩']='灬轩轩灬:BAAALgAECgIJAgAAAA==.',
['灰烬']='灰烬终途:BAAALgADCgUJBgAAAA==.',
['灵风']='灵风拂面:BAAALgAECgYJEAAAAA==.灵风落尘:BAAALgAECgIJAgAAAA==.',
['炭烧']='炭烧积雨云:BAAALgADCgYJBgAAAA==.',
['烈日']='烈日灼空:BAAALgAECgUJBgAAAA==.',
['焰尾']='焰尾扫落叶:BAAALgAFFAEJAQAAAA==.',
['焰灵']='焰灵姬:BAAALgAFFAIJBAAAAA==.',
['熱血']='熱血灬荣耀:BAAALgAECgUJDgAAAA==.',
['爱吃']='爱吃肉:BAAALgAECgEJAQAAAA==.',
['牧羊']='牧羊倾城灬:BAAALgAECgUJBgAAAA==.',
['狐人']='狐人冠军:BAAALgADCgUJBQAAAA==.',
['狐作']='狐作妃为:BAAALgAECgEJAQAAAA==.',
['狙鸡']='狙鸡手:BAAALgAECgQJBQAAAA==.',
['玄崇']='玄崇:BAAALgAECgYJBgAAAA==.',
['玩个']='玩个锤子:BAAALgAECgkJCQAAAA==.',
['珍珠']='珍珠丶:BAAALgAECgkJEwAAAA==.',
['琉璃']='琉璃美人刹:BAAALgADCgIJAgAAAA==.',
['瓦林']='瓦林青石之拳:BAAALgAECgMJBAAAAA==.',
['疯狂']='疯狂乱舞:BAAALgAECgEJAQAAAA==.',
['白菓']='白菓:BAAALgAECgMJAwAAAA==.',
['百变']='百变泡泡女孩:BAAALgAECgYJBAAAAA==.',
['的地']='的地德:BAAALgAECgIJAgAAAA==.',
['皮是']='皮是不是:BAAALgADCgUJBQAAAA==.',
['盗圣']='盗圣白玉汤:BAAALgAECgkJEAAAAA==.',
['矢来']='矢来美羽:BAABLgAFFH8GAAIKAAMJLRiiHgAJAQAKAAMJLRiiHgAJAQAAAA==.',
['礑葒']='礑葒小聖騎:BAAALgADCgUJBQAAAA==.',
['祖尔']='祖尔贾:BAAALgADCgIJAgABLgADCgYJBgABAAAAAA==.',
['神装']='神装也怕羊:BAACLgAFFH8JAAIDAAQJVgegGwDhAAADAAQJVgegGwDhAAAuAAQKfxUAAgMACAkCFtdSAD8CAAMACAkCFtdSAD8CAAAA.',
['禁忌']='禁忌女巫:BAAALgAFFAEJAQAAAA==.',
['秀芹']='秀芹:BAAALgAECgEJAQAAAA==.',
['秃尾']='秃尾巴老李:BAAALgAECgUJBgAAAA==.',
['秋灬']='秋灬陌:BAAALgAECgQJBQAAAA==.',
['秋熙']='秋熙夏京喵:BAAALgAECgYJBgAAAA==.',
['秦皇']='秦皇小德:BAAALgAECgEJAQAAAA==.',
['穹之']='穹之殇痕:BAAALgAECgEJAQAAAA==.',
['穿林']='穿林打叶声:BAAALgADCgYJBgAAAA==.',
['窃业']='窃业仙:BAAALgAECgkJBgAAAA==.',
['站坟']='站坟头丶看戏:BAAALgADCgQJBAAAAA==.',
['箍儿']='箍儿丹:BAAALgAFFAIJAgAAAA==.',
['米尔']='米尔豪七:BAAALgAECgYJBwAAAA==.',
['糊涂']='糊涂小精灵:BAAALgAECgYJCQAAAA==.',
['索恩']='索恩寒霜之锤:BAAALgADCgEJAQAAAA==.',
['紫电']='紫电青霜狂:BAAALgAECgEJAQAAAA==.',
['红毛']='红毛老毕登:BAAALgAECgQJAgAAAA==.',
['红苹']='红苹果:BAAALgAECgYJDgAAAA==.',
['细雨']='细雨湿流光:BAAALgAECggJCwAAAA==.',
['罗刹']='罗刹傀儡:BAAALgADCgYJBgAAAA==.',
['罗斯']='罗斯福先生:BAABLgAFFH8FAAIMAAUJrRUhCgBcAQAMAAUJrRUhCgBcAQAAAA==.',
['羊肝']='羊肝酱:BAABLgAECn8UAAIaAAgJ0BhlAQAYAgAaAAgJ0BhlAQAYAgABLgAFFAEJAQABAAAAAA==.',
['羊角']='羊角咩咩羊:BAAALgAECgEJAQAAAA==.',
['美味']='美味鸡腿:BAAALgAECgcJDwABLgAFFAgJGQAKAPQgAA==.',
['美鸡']='美鸡味腿:BAACLgAFFH8ZAAQKAAgJ9CDgAQAeAgAKAAcJ7iHgAQAeAgALAAUJAhkhAQDrAQAeAAEJAADUAQB3AAAuAAQKfxsAAwoACQlXJnYHAEsDAAoACAkYJnYHAEsDAAsABAlLJGoTALABAAAA.',
['翔哥']='翔哥霸道极了:BAAALgAECgEJAgAAAA==.',
['翻滚']='翻滚吧小芒果:BAAALgAECgEJAQAAAA==.翻滚吧蛋炒饭:BAAALgAECgEJAQAAAA==.',
['老公']='老公出差啦:BAAALgAECgMJAwAAAA==.',
['老妖']='老妖:BAAALgADCgEJAQAAAA==.',
['老爸']='老爸黄岩:BAAALgAECgUJCAAAAA==.',
['耗子']='耗子爷:BAAALgAECgYJDAAAAA==.',
['职业']='职业踩脸:BAAALgAECgUJDgAAAA==.',
['聖光']='聖光永存:BAAALgAECgQJCQAAAA==.',
['肉肉']='肉肉的小宝丶:BAAALgAECgYJBwAAAA==.',
['胖哥']='胖哥丶:BAABLgAECn8VAAIFAAkJZSEJDgArAwAFAAkJZSEJDgArAwAAAA==.',
['胸狠']='胸狠小:BAAALgAECgIJAgAAAA==.',
['能射']='能射下来:BAAALgAECgIJAgAAAA==.',
['脚踩']='脚踩西瓜皮:BAACLgAFFH8MAAQUAAUJLg4/BQCJAQAUAAUJLg4/BQCJAQAMAAIJWAQcOABIAAAfAAEJzwFgBQAhAAAuAAQKfyEABAwACQn0GuoQAAgDAAwACQn0GuoQAAgDABQABAlbESdiAPMAAB8AAQnlBMFIACAAAAAA.',
['腐肉']='腐肉之风:BAAALgAECggJDQAAAA==.',
['自由']='自由羽翼:BAAALgADCgEJAQAAAA==.',
['艾奥']='艾奥里奥:BAAALgADCgUJBQAAAA==.',
['芙兰']='芙兰朵露丶:BAAALgADCgEJAQAAAA==.',
['花生']='花生酱世涛:BAAALgAFFAIJAwAAAA==.',
['苍茫']='苍茫:BAAALgADCgcJBwAAAA==.',
['苦痛']='苦痛靈魂:BAAALgADCgEJAQAAAA==.',
['茄子']='茄子汆面:BAAALgAECgYJBgAAAA==.',
['茉莉']='茉莉蜜茶灬:BAAALgAECgcJBwAAAA==.',
['茶凉']='茶凉酒寒:BAAALgAECgYJBwAAAA==.',
['荞麦']='荞麦面:BAAALgAECgMJAwAAAA==.',
['荻野']='荻野目洋子:BAAALgAECgQJBQAAAA==.',
['莫茗']='莫茗:BAAALgAECgEJAQAAAA==.',
['莫高']='莫高雷的回响:BAACLgAFFH8GAAMcAAIJuRqLBgCcAAAcAAIJuRqLBgCcAAAJAAEJiBOGIABUAAAuAAQKfxoAAxwACQlLG1QFAOgCABwACQlLG1QFAOgCAAkABglqD9dcADwBAAEuAAUUBQkSAAYAFiMA.',
['莽娃']='莽娃儿:BAAALgAECgcJBwAAAA==.',
['菜法']='菜法王德发:BAAALgAECgIJAgAAAA==.',
['菟菟']='菟菟小乖:BAABLgAECn8UAAIWAAgJjg92GQDDAQAWAAgJjg92GQDDAQABLgAFFAQJBAABAAAAAA==.',
['萍萍']='萍萍的猎手:BAAALgAECgUJBQAAAA==.',
['萨小']='萨小满丶:BAAALgAECggJCgAAAA==.',
['落命']='落命:BAAALgADCgUJBQAAAA==.',
['落幕']='落幕丶风羽:BAACLgAFFH8JAAIHAAQJrRrtDQAVAQAHAAQJrRrtDQAVAQAuAAQKfxUAAgcACAlVGtkSAHsCAAcACAlVGtkSAHsCAAAA.',
['落雪']='落雪断江:BAABLgAFFH8GAAINAAQJQyBGBQCHAQANAAQJQyBGBQCHAQAAAA==.落雪沐曦:BAAALgAFFAIJAwABLgAFFAQJBgANAEMgAA==.',
['葬呵']='葬呵呵:BAAALgAECgEJAQAAAA==.',
['蓝带']='蓝带啤酒:BAAALgAECgcJAgABLgAECgkJEwABAAAAAA==.',
['蓝桥']='蓝桥春雪:BAAALgAECgMJBAAAAA==.',
['虾仁']='虾仁饭:BAAALgAFFAEJAgAAAA==.',
['蛋挞']='蛋挞:BAAALgAECgEJAgAAAA==.',
['血影']='血影灵:BAAALgAECgEJAwAAAA==.',
['血色']='血色的残月:BAAALgAECgEJAQAAAA==.',
['讠丶']='讠丶棋子:BAAALgAECgEJAQAAAA==.',
['谜之']='谜之女主角:BAAALgAECgMJAwAAAA==.',
['豆豆']='豆豆闯天涯:BAAALgAECgEJAQAAAA==.',
['财源']='财源广进:BAAALgADCgQJBwAAAA==.',
['败家']='败家小番茄:BAAALgAECgEJAgAAAA==.败家小芹菜:BAAALgAECgMJAwAAAA==.',
['贾艾']='贾艾泽:BAAALgAECgUJBQAAAA==.',
['赤脚']='赤脚跑路:BAAALgADCgUJBQAAAA==.',
['路战']='路战飓风:BAAALgADCgEJAQAAAA==.',
['踏冰']='踏冰渡海真君:BAAALgAECgEJAQAAAA==.',
['踩榴']='踩榴莲抢窝头:BAAALgAECgUJBQAAAA==.',
['轩轩']='轩轩灬:BAAALgADCgUJBQAAAA==.',
['过去']='过去的季莫:BAAALgAECgUJBgAAAA==.',
['迎娶']='迎娶薇尔莉特:BAAALgAECgUJBgAAAA==.',
['迪奥']='迪奥伦娜:BAAALgAECgEJAQAAAA==.',
['迷路']='迷路的喵熊:BAAALgAECgQJBAAAAA==.',
['追光']='追光者:BAAALgADCgEJAQAAAA==.',
['逆风']='逆风飞羽:BAAALgADCgUJBwAAAA==.',
['逐魂']='逐魂影默:BAAALgAECgUJBQAAAA==.',
['遗忘']='遗忘枼愿:BAAALgADCgEJAQAAAA==.',
['遥指']='遥指杏花村:BAAALgAFFAEJAgAAAA==.',
['那你']='那你说咋办:BAAALgAECgcJBwAAAA==.',
['邪丶']='邪丶冥梦:BAAALgAECgUJBQAAAA==.',
['邪修']='邪修:BAAALgAECgEJAgAAAA==.',
['邪神']='邪神镜:BAAALgAECgUJBgAAAA==.',
['郗酱']='郗酱:BAAALgAECgIJBAAAAA==.',
['鄙人']='鄙人不善奔跑:BAACLgAFFH8IAAIFAAMJZyQHDgAaAQAFAAMJZyQHDgAaAQAuAAQKfxYAAgUABgmwGxViAM0BAAUABgmwGxViAM0BAAAA.',
['酒仙']='酒仙:BAAALgAFFAIJAwAAAA==.',
['酷溜']='酷溜奇葩:BAAALgAECgMJAwAAAA==.',
['金爷']='金爷:BAAALgAFFAIJAwAAAA==.',
['铁血']='铁血两分:BAAALgAFFAQJBAAAAA==.',
['铁锅']='铁锅炖媳妇:BAAALgAECgYJCwAAAA==.',
['银光']='银光落刃:BAAALgAECgYJCQAAAA==.',
['闪亮']='闪亮小肉肉丶:BAAALgADCgYJBgAAAA==.',
['闪爍']='闪爍:BAAALgAECgEJAQAAAA==.',
['闻君']='闻君有两意:BAAALgAECgQJBAAAAA==.',
['阿亚']='阿亚尼斯:BAAALgAECgcJAQAAAA==.',
['阿莱']='阿莱克丝:BAAALgADCgcJBwAAAA==.',
['阿达']='阿达西丶:BAAALgAECgUJCAAAAA==.',
['阿鲁']='阿鲁卡德:BAAALgADCgkJEQAAAA==.',
['陈雪']='陈雪:BAAALgAFFAUJBAAAAA==.',
['随安']='随安而遇:BAAALgAECgIJBAAAAA==.',
['难吃']='难吃鸡腿:BAACLgAFFH8JAAIZAAQJOxeCDQBkAQAZAAQJOxeCDQBkAQAuAAQKfxsAAhkACAljHfMvADwCABkACAljHfMvADwCAAAA.',
['雅丨']='雅丨修特拉:BAAALgAECgMJBAAAAA==.',
['雪诺']='雪诺无痕:BAAALgAECgEJAQAAAA==.',
['零时']='零时之月:BAAALgAECgMJBAAAAA==.',
['雾之']='雾之湖的笨蛋:BAAALgAECgIJAgABLgAECgYJBwABAAAAAA==.',
['霜眉']='霜眉:BAACLgAFFH8IAAIFAAMJJhPDEgD6AAAFAAMJJhPDEgD6AAAuAAQKfxYAAgUABgkqGD5/AIQBAAUABgkqGD5/AIQBAAAA.',
['霸王']='霸王硬上班:BAAALgAECgYJBwAAAA==.',
['靓箭']='靓箭靓影:BAAALgAFFAEJAQAAAA==.',
['颤元']='颤元素:BAAALgAECgUJCAAAAA==.',
['風流']='風流丶尐西瓜:BAAALgAECgEJAQAAAA==.',
['颲人']='颲人:BAAALgADCgYJBgAAAA==.',
['风少']='风少爷丶:BAAALgAECgUJCAAAAA==.',
['飞天']='飞天小狐狸:BAAALgADCgcJCwAAAA==.',
['饭团']='饭团猎手:BAAALgAECgEJAQAAAA==.',
['馬橋']='馬橋心玖:BAAALgAECgQJBQAAAA==.',
['骂谁']='骂谁没腿呢:BAAALgAFFAEJAQAAAA==.',
['鸡翅']='鸡翅:BAAALgAECgEJAQAAAA==.',
['鸽咕']='鸽咕崽:BAAALgAFFAMJBAAAAA==.',
['鹏举']='鹏举:BAAALgADCgEJAQAAAA==.',
['黄子']='黄子懋:BAAALgAECgQJBAAAAA==.',
['黄莉']='黄莉莉:BAAALgADCgEJAQAAAA==.',
['黎明']='黎明杀鸭:BAAALgAECgYJBgAAAA==.',
['黑白']='黑白之羽翼:BAABLgAECn8kAAQWAAYJTCShBACgAQAWAAUJxCShBACgAQATAAYJFxeHFQCVAQAGAAYJJBoyLgBQAQAAAA==.',
['黑神']='黑神话虚竹:BAAALgAECgIJAgAAAA==.',
['黑糖']='黑糖:BAAALgADCgYJBgAAAA==.',
},}
provider.parse = parse

local rawData = provider.data
provider.data = {}
provider.getChunk = getChunkLookup(rawData, 2)

setmetatable(provider.data, {
	__index = function(table, key)
		provider.getChunk(key)
	end,
})

if _G["ArchonTooltip"] and ArchonTooltip.AddProviderV2 then
	ArchonTooltip.AddProviderV2(lookup, provider)
end
