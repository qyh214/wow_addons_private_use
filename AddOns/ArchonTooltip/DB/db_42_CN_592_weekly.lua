local V2_TAG_NUMBER = 3

---Parse a single set of spec data from `state`
---@param decoder BitDecoder
---@param state ParseState
---@param lookup table<number, string>
---@return ProviderProfileSpec
local function parseSpecData(decoder, state, lookup)
	local result = {}
	result.spec = decoder.decodeString(state, lookup)
	result.progress = decoder.decodeInteger(state, 1)
	result.partition = decoder.decodeInteger(state, 1)
	result.total = decoder.decodeInteger(state, 1)
	result.rank = decoder.decodeInteger(state, 3)
	result.average = decoder.decodeFixedFloat(state, 1, 1)
	result.asp = decoder.decodeInteger(state, 2)
	result.difficulty = decoder.decodeInteger(state, 1)
	result.size = decoder.decodeInteger(state, 1)

	local encounterCount = decoder.decodeInteger(state, 1)
	result.encounters = {}
	for i = 1, encounterCount do
		local id = decoder.decodeInteger(state, 4)
		local kills = decoder.decodeInteger(state, 2)
		local best = decoder.decodeInteger(state, 1)

		result.encounters[id] = { kills = kills, best = best }
	end
	return result
end

---Parse a binary-encoded data string into a ProviderProfile
---@param decoder BitDecoder
---@param content string
---@param lookup table<number, string>
---@return ProviderProfile|nil
local function parse(decoder, content, lookup) -- luacheck: ignore 211
	---@type ParseState
	local state = { content = content, position = 1 }

	local tag = decoder.decodeInteger(state, 1)
	if tag ~= V2_TAG_NUMBER then
		return nil
	end

	local result = {}

	-- user data
	result.subscriber = decoder.decodeInteger(state, 1)
	-- overall data
	result.progress = decoder.decodeInteger(state, 1)
	result.total = decoder.decodeInteger(state, 1)
	result.totalKillCount = decoder.decodeInteger(state, 2)
	result.difficulty = decoder.decodeInteger(state, 1)
	result.size = decoder.decodeInteger(state, 1)
	result.perSpec = {}

	local specCount = decoder.decodeInteger(state, 1)
	if specCount > 0 then
		result.anySpec = parseSpecData(decoder, state, lookup)

		for _i = 1, specCount - 1 do
			local spec = parseSpecData(decoder, state, lookup)
			table.insert(result.perSpec, spec)
		end
	end

	local hasMainCharacter = decoder.decodeBoolean(state)

	if hasMainCharacter then
		local main = {}
		main.spec = decoder.decodeString(state, lookup)
		main.average = decoder.decodeFixedFloat(state, 1, 1)
		main.progress = decoder.decodeInteger(state, 1)
		main.total = decoder.decodeInteger(state, 1)
		main.totalKillCount = decoder.decodeInteger(state, 2)
		main.difficulty = decoder.decodeInteger(state, 1)
		main.size = decoder.decodeInteger(state, 1)
		result.mainCharacter = main
	end

	return result
end
 local lookup = {'Paladin-Retribution','Hunter-BeastMastery','Unknown-Unknown','Druid-Balance','Druid-Restoration','Druid-Guardian','Rogue-Outlaw','Hunter-Marksmanship','Warlock-Destruction','Warlock-Demonology','Warlock-Affliction','DemonHunter-Vengeance','Mage-Frost','Paladin-Protection','Monk-Windwalker','Monk-Mistweaver','Monk-Brewmaster','Shaman-Elemental','Shaman-Enhancement','Shaman-Restoration','Warrior-Fury','Warrior-Arms','DeathKnight-Unholy','DeathKnight-Blood','DemonHunter-Havoc','Rogue-Assassination','Evoker-Devastation','Mage-Arcane','Mage-Fire','Priest-Shadow','Paladin-Holy','Hunter-Survival','Evoker-Preservation',}; local provider = {region='CN',realm='加尔',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ca='Carryall:AwAICAEABAoAAA==.',Co='Commedia:AwACCAYABRQCAQACAQiqIgBGLK0ABRQAAQACAQiqIgBGLK0ABRQAAA==.',Cv='Cver:AwACCAIABRQAAA==.',Gu='Gurren:AwABCAEABRQAAA==.',Hu='Hunterliang:AwAECAMABRQCAgADAQhBHQBOhLEABRQAAgADAQhBHQBOhLEABRQAAQMAAAAECAQABRQ=.',Lo='Lovekeri:AwABCAEABAoAAA==.',Lu='Luciferly:AwAICAYABAoAAA==.Luu:AwACCAUABRQEBAAIAQjOLAA+mtwBBAoABAAHAQjOLABECNwBBAoABQAEAQjvWQApkYMABAoABgABAQgHKgAeBCIABAoAAA==.',Mu='Muffin:AwACCAMABRQCBwAIAQhiAQBWWr8CBAoABwAIAQhiAQBWWr8CBAoAAA==.',Se='Senasama:AwAECAQABAoAAA==.',Sh='Shainey:AwAGCAEABAoAAA==.',Su='Supertiger:AwAFCAoABAoAAA==.',Tr='Tresdin:AwADCA0ABRQCAQADAQj+EQA3DvkABRQAAQADAQj+EQA3DvkABRQAAA==.',Un='Unaccessible:AwAECAQABRQAAA==.',Vo='Volice:AwAECAQABRQAAA==.',Wa='Wacl:AwAECAgABRQDCAAEAQgcAwBVrxYBBRQACAAEAQgcAwBPjhYBBRQAAgAEAQgpDgBQOgIBBRQAAA==.',We='Weyue:AwABCAIABRQAAA==.',Wk='Wknight:AwABCAIABRQAAA==.',Yv='Yvwvuyi:AwABCAEABRQECQAIAQhIEQBZpFICBAoACQAHAQhIEQBaGFICBAoACgADAQgnOQBRzbgABAoACwABAQg3OAA9fkMABAoAAA==.',Zs='Zsir:AwAECAQABRQAAA==.',['�']='一帆风顺灬:AwAECAEABRQDAgAIAQiXLABJxyECBAoAAgAIAQiXLAA+9yECBAoACAAFAQjnKwA9g0kBBAoAAA==.一眼见你:AwAECAgABRQCDAAEAQg/CAAZaaUABRQADAAEAQg/CAAZaaUABRQAAA==.一穿三:AwAICBAABAoAAA==.七丶星:AwAECAQABRQAAA==.七分熟的番茄:AwACCAIABRQAAA==.三棍居士:AwAHCAEABAoAAA==.不死十纷坏:AwAICBQABAoCDQAIAQhfFwBBPCQCBAoADQAIAQhfFwBBPCQCBAoAAA==.丨张哥丨:AwAICAkABAoAAQMAAAAICAEABRQ=.丶光怪陆离:AwAICAgABAoAAA==.丶我不胖:AwABCAIABRQDAQAIAQizMwBIRjUCBAoAAQAIAQizMwBIRjUCBAoADgABAQhvXgAIAgsABAoAAA==.丿王者之心:AwAICAgABAoAAA==.',['�']='云途:AwAICBoABAoCAQAIAQgUEABd08gCBAoAAQAIAQgUEABd08gCBAoAAA==.',['�']='伊利丶纯蛋蛋:AwACCAEABRQAAA==.伐克:AwAICB0ABAoEDwAIAQgPOQAeYAQBBAoADwAGAQgPOQAgWAQBBAoAEAAIAQjNRQAYbgIBBAoAEQADAQjDGgAeG3IABAoAAA==.伤心太平洋:AwAICBAABAoAAQMAAAAECAQABRQ=.',['�']='佛悟七音:AwAICBoABAoEEgAIAQg/IgA9RKsBBAoAEgAHAQg/IgA6y6sBBAoAEwAHAQi4LAAaMTQBBAoAFAABAQjLpwAQIjEABAoAAQMAAAADCAMABRQ=.',['�']='倮奔的领头羊:AwACCAQABRQAAA==.',['�']='全糊糊丷:AwAGCBAABRQDFQAGAQjTAABb/qwBBRQAFQAFAQjTAABdq6wBBRQAFgABAQicDgBVSWcABRQAAA==.',['�']='冥夜花伝廊:AwAECAQABRQAAA==.冰封战将:AwAICB0ABAoCAQAIAQh9HgBSeocCBAoAAQAIAQh9HgBSeocCBAoAAA==.',['�']='剑心血影:AwAECAQABRQCAQAIAQjoBwBecPICBAoAAQAIAQjoBwBecPICBAoAAA==.',['�']='十二皇族丶:AwAGCAgABAoAAA==.华法林:AwAGCAoABRQDFwAGAQgeAQA5grABBRQAFwAGAQgeAQA1u7ABBRQAGAAEAQjfDQAjlaoABRQAAA==.华法琳:AwAICAgABAoAAA==.南北小和尚:AwAICA0ABAoAAA==.南栀:AwAICAkABAoAAA==.南瓜二米粥:AwAICBcABAoCEQAIAQjJBgA/HfEBBAoAEQAIAQjJBgA/HfEBBAoAAA==.卡了拉了:AwAECAQABRQAAA==.',['�']='压力怪人:AwACCAUABRQCAQACAQjtHQBYkckABRQAAQACAQjtHQBYkckABRQAAA==.',['�']='又菜又爱玩:AwAECAQABAoAAA==.双蛋瓦斯:AwAECAQABRQAAA==.只狼:AwAECAQABRQAAA==.可爱母牛:AwACCAIABAoAAA==.',['�']='含戳不带笑:AwAHCBkABAoCGQAHAQjQTAAg7EUBBAoAGQAHAQjQTAAg7EUBBAoAAA==.',['�']='命运融合:AwACCAIABRQEBAAIAQhVIQBGCx8CBAoABAAIAQhVIQBGCx8CBAoABQAIAQgzHQAycbEBBAoABgABAQjHJwAoFy0ABAoAAQ0AYAAECA0ABRQ=.',['�']='咕噜咕噜肉:AwAECAQABRQAAA==.',['�']='哈哈蛤:AwABCAEABRQAAA==.',['�']='唐嫣:AwACCAIABRQAAA==.',['�']='喑哑无言:AwAGCAYABRQCGgAGAQhBAABEf/cBBRQAGgAGAQhBAABEf/cBBRQAAA==.喜欢奶茶:AwABCAEABRQAAA==.',['�']='噬魂血:AwABCAEABAoAAA==.',['�']='圣光牛牛:AwAECAQABRQAAA==.圣光百合:AwAECAQABRQAAA==.',['�']='复仇的橘子:AwAICAgABAoAAA==.夜阑谣:AwADCAwABRQCFwADAQhpDAAq7ugABRQAFwADAQhpDAAq7ugABRQAAA==.头铁的阿昆达:AwAICAgABAoAAA==.',['�']='奥义武僧:AwACCAIABRQAAA==.',['�']='妈她亲我:AwAGCAYABAoAAA==.',['�']='娜迦骆:AwAGCAsABAoAAA==.',['�']='安德森先森:AwAECAQABRQAAA==.',['�']='小城丶:AwAECAQABRQAAA==.小月圆舞曲:AwAICAgABAoAAA==.尛乄怪兽:AwAECAQABRQAAA==.',['�']='布莱恩丶铜须:AwAGCAcABRQDFAAGAQg/AAA1bcABBRQAFAAGAQg/AAA1bcABBRQAEgABAQhYFQAufUAABRQAAA==.帝國之绝凶竜:AwAICAYABRQCGwAEAQiZBQBZUg0BBRQAGwAEAQiZBQBZUg0BBRQAAA==.',['�']='幻火狐:AwADCAUABRQEHAADAQgNAgBBY2QABRQAHAABAQgNAgBTa2QABRQADQABAQi3EgBJ7FUABRQAHQABAQgjMAAm0kcABRQAAA==.',['�']='強力炮台:AwADCAgABRQCBAADAQikCQBFFAQBBRQABAADAQikCQBFFAQBBRQAAA==.强力的奶骑:AwAGCAMABRQAAA==.',['�']='影竹:AwABCAEABAoAAA==.',['�']='微微丶邪纹:AwAGCAIABRQCGQAIAQgaBgBfxeQCBAoAGQAIAQgaBgBfxeQCBAoAAA==.',['�']='心慌慌:AwABCAEABRQCGAAIAQgwSwAEHGIABAoAGAAIAQgwSwAEHGIABAoAAA==.忙碌的牛虻:AwAECAQABRQAAA==.',['�']='恩希宝宝:AwAHCAYABAoAAA==.',['�']='情人:AwABCAEABRQCDAAIAQi8RQAGS3cABAoADAAIAQi8RQAGS3cABAoAAA==.',['�']='憮心:AwACCAQABRQCDgAIAQiVJgAT2/EABAoADgAIAQiVJgAT2/EABAoAAA==.',['�']='戏梦悲桑丶:AwABCAEABRQAAA==.',['�']='拽根丶:AwAGCAkABRQCGwAFAQj6AwAp8SwBBRQAGwAFAQj6AwAp8SwBBRQAARIAVZkICAIABRQ=.',['�']='挚爱接触:AwAECA0ABRQDDQAEAQh/AABgAE8BBRQADQAEAQh/AABgAE8BBRQAHQACAQh+IgBIn5oABRQAAA==.',['�']='攸水:AwACCAIABRQAAQIAPf8GCAkABRQ=.',['�']='断桥残雪丶:AwAECAQABRQAAA==.',['�']='晓晓的酥:AwAICAgABAoAAA==.晴天的云:AwABCAEABAoAAA==.',['�']='曦瑶歌尽丶:AwADCAIABRQAAA==.',['�']='有奶就是德:AwACCAMABRQAAA==.',['�']='极品妹纸:AwAGCAYABAoAAA==.林糊糊丷:AwAGCAYABAoAAQMAAAAGCAQABRQ=.',['�']='柯雨:AwAECAMABRQAAR4AQDsGCAoABRQ=.',['�']='棒棒的基枪:AwAGCAgABAoAAA==.',['�']='欧皇大叔:AwAGCBYABAoDBAAGAQg5UwAzSTABBAoABAAGAQg5UwAzSTABBAoABQAEAQgvPQA78/QABAoAAA==.',['�']='江天暮雨:AwAECAgABRQCGwAEAQg7BQBHHxQBBRQAGwAEAQg7BQBHHxQBBRQAAA==.',['�']='沐摇光:AwAECAYABRQCGwAEAQi6DAAYD8IABRQAGwAEAQi6DAAYD8IABRQAAA==.油炸饺子:AwAECAsABRQDAgAEAQhTDQBCdwUBBRQAAgAEAQhTDQBCdwUBBRQACAABAQjYGgALy0AABRQAAA==.',['�']='注咕生:AwADCAgABRQCBAADAQiIBQBKNCMBBRQABAADAQiIBQBKNCMBBRQAAA==.',['�']='清水芽衣:AwACCAIABRQAAA==.',['�']='灰掌丶影:AwAECAQABRQAAA==.',['�']='烨小白:AwAECAQABRQAAA==.热心市民丶:AwAICA8ABAoAAA==.',['�']='無知骚年:AwAICBYABAoDAQAIAQhMNgBIuysCBAoAAQAIAQhMNgBIuysCBAoAHwABAQi5SAAJ1iMABAoAAA==.',['�']='特叼海大副:AwAICA0ABAoAAA==.',['�']='狂怒之雷:AwADCA0ABRQDFQADAQjjDQAmCPAABRQAFQADAQjjDQAmCPAABRQAFgACAQjJDAAdGYoABRQAAA==.狂战兽魔:AwAGCAMABAoAAA==.狂战德魔:AwAFCAcABAoAAA==.狐不服:AwABCAIABRQAAA==.',['�']='猫咪头:AwAICAcABAoAAA==.',['�']='玛里苟萨:AwAICAIABAoAAA==.玩命兽:AwACCAQABRQCFQAIAQhdHAA3tRUCBAoAFQAIAQhdHAA3tRUCBAoAAA==.',['�']='琳娜丶洛娃:AwAICBsABAoDCQAIAQjLLgAqN58BBAoACQAIAQjLLgAqK58BBAoACgABAQhpWwAygkgABAoAAA==.',['�']='疯入膏肓:AwAICAgABAoAAA==.',['�']='笙歌语潇湘:AwABCAEABRQCDgAIAQhZGAAu/XQBBAoADgAIAQhZGAAu/XQBBAoAAA==.',['�']='糖醋椒盐里脊:AwAECAQABRQAAQMAAAAECAQABRQ=.',['�']='红乄为你而战:AwABCAEABRQAAA==.',['�']='给治疗找事做:AwAICAYABAoAAA==.绵呀棉丶:AwABCAEABRQAAA==.',['�']='耐可王:AwAECAQABRQAAA==.',['�']='胖胖哥儿:AwAFCAYABAoAAA==.胖胖的哥:AwACCAIABAoAAA==.',['�']='艺琳:AwAECAIABAoAAA==.',['�']='花下逗狮子:AwACCAIABRQAAA==.',['�']='范丷海辛:AwACCAUABRQEAgACAQgbHQBXY7IABRQAAgACAQgbHQBMRrIABRQACAABAQh5FQBWKGUABRQAIAABAQjdAgAyxFQABRQAAA==.',['�']='荒野之息:AwABCAEABRQAAA==.荷塘月色:AwABCAEABRQAAA==.',['�']='莫得办法:AwABCAEABRQAAA==.',['�']='菈妮:AwAECAIABRQCIQAIAQg9AgBWPp4CBAoAIQAIAQg9AgBWPp4CBAoAAA==.菲亚梅塔:AwAGCAYABRQCGwAGAQgEAQBJNr0BBRQAGwAGAQgEAQBJNr0BBRQAAA==.',['�']='萌丶尐天:AwAECAQABRQAAA==.萌萌小母牛:AwAECAQABRQAAA==.',['�']='薩滿敎義:AwAFCAUABAoAAA==.',['�']='蜀久涵天:AwAECAwABRQCEgAEAQiaBwA4wN0ABRQAEgAEAQiaBwA4wN0ABRQAASEAPlEGCAsABRQ=.',['�']='螭虎:AwABCAEABRQAAA==.',['�']='蟹肉男王:AwABCAEABRQAAA==.',['�']='衰仔:AwAICAgABAoAAA==.',['�']='谢绝观赏:AwABCAEABRQAAA==.',['�']='超级华哥:AwAGCAsABAoAAA==.超级虫子:AwADCA0ABRQCHgADAQjGCQA7EfIABRQAHgADAQjGCQA7EfIABRQAAA==.超级风骚:AwADCA0ABRQDHwADAQiNBQAtpOAABRQAHwADAQiNBQAtpOAABRQADgABAQhjFQAFAiQABRQAAA==.',['�']='躺尸:AwADCAwABRQDCQADAQgsDABIauAABRQACQADAQgsDABAJ+AABRQACwACAQiRCQBP2sIABRQAAA==.',['�']='还能翻滚两次:AwAECAQABAoAAA==.这一刀叫成长:AwAECAQABRQAAA==.',['�']='酷崽咚咚:AwAFCAIABAoAAA==.',['�']='阙大哥的愤怒:AwAECAUABAoAAA==.阿咆:AwAECAgABRQCBAAEAQj1DQA5lO4ABRQABAAEAQj1DQA5lO4ABRQAAA==.阿尔比昂:AwAECAQABRQAAA==.阿弥托佛:AwAFCAIABAoAAA==.阿彌陀佛:AwACCAIABRQAAA==.阿褪:AwAHCAcABAoAAQMAAAAICAIABRQ=.阿飛的小蝴蝶:AwACCAIABRQAAA==.',['�']='隐约雷鸣:AwAECAMABRQAAA==.',['�']='雪月血祭:AwAGCAYABAoAAA==.',['�']='青丘狐帝:AwAECAQABRQAAQMAAAAFCAIABRQ=.青岛婶婶:AwAGCAsABRQCHgAGAQjyAQAsNZsBBRQAHgAGAQjyAQAsNZsBBRQAAA==.',['�']='风暴皮卡丘:AwAHCAYABAoAAA==.飞神雷水门:AwAGCAcABAoAAA==.',['�']='饼干丶:AwACCAIABRQAAA==.',['�']='骑士风雨:AwABCAEABRQAAA==.',['�']='鸣濑白羽:AwAECAEABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end