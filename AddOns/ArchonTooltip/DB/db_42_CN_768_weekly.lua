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
 local lookup = {'Shaman-Elemental','Shaman-Restoration','Warlock-Destruction','Warlock-Affliction','Hunter-BeastMastery','Paladin-Retribution','Paladin-Holy','Paladin-Protection','Unknown-Unknown','Mage-Fire','DeathKnight-Unholy','DeathKnight-Blood','Shaman-Enhancement','DemonHunter-Havoc','Monk-Mistweaver','Priest-Holy','Mage-Frost','Druid-Feral','Priest-Shadow',}; local provider = {region='CN',realm='甜水绿洲',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ba='Ball:AwAFCAUABAoAAA==.',Bi='Bigzai:AwABCAEABAoAAA==.',Ca='Calafiori:AwAECAcABAoAAA==.',Ce='Celine:AwADCAMABAoAAA==.',Ch='Chicagogirl:AwAHCAcABAoAAA==.',Cr='Crsan:AwAICAgABAoAAA==.',Fl='Flyawyya:AwAGCAYABRQDAQAEAQjAAwBNhQsBBRQAAQAEAQjAAwBNhQsBBRQAAgACAQiEHAAjOYUABRQAAA==.',Gi='Ginman:AwAECAQABRQAAA==.',He='Heartinsword:AwADCAcABRQDAwADAQj3DwBAwMkABRQAAwADAQj3DwAfOckABRQABAACAQizCQBcmsAABRQAAA==.',Ic='Icehotflam:AwAECAQABRQAAA==.',Ja='Jacky:AwAHCA0ABAoAAA==.',La='Lalalal:AwAICAgABAoAAQUAPf8GCAkABRQ=.',Na='Naowhlul:AwAECAQABRQAAA==.',Pu='Pulsar:AwADCAMABAoAAA==.',Se='Seirias:AwAGCAcABAoAAA==.',Ti='Tiny:AwAHCAcABAoAAA==.',Ul='Ultrakill:AwABCAEABAoAAA==.',['�']='一只丶:AwAICA4ABAoAAA==.一箭你就笑:AwABCAEABAoAAA==.与风同程:AwAGCAsABRQEBgAEAQiSDABQTA4BBRQABgAEAQiSDABQTA4BBRQABwADAQjgCgA4UpEABRQACAADAQjYCgAUIooABRQAAQkAAAAICAQABRQ=.与风如月:AwAECAMABRQAAA==.与风来电:AwAECAMABRQAAA==.东尼三木:AwADCAgABRQCAQADAQikAgBSjx0BBRQAAQADAQikAgBSjx0BBRQAAA==.丨恺丶屹丨:AwAFCAsABAoAAA==.丹妮利斯:AwACCAIABAoAAA==.丿单车丿:AwABCAEABAoAAA==.',['�']='九摩诃:AwAGCAcABRQCCgAGAQgkBAAax30BBRQACgAGAQgkBAAax30BBRQAAA==.乳糖炒粽子:AwACCAIABRQAAA==.',['�']='五火球毅哥:AwAECAQABRQAAA==.亚瑞:AwADCAMABAoAAA==.人人有功练:AwAGCAsABAoAAA==.',['�']='今日刑满:AwAECAgABRQDCwAEAQi/DABit+YABRQACwAEAQi/DAA3/uYABRQADAAEAAgAAABitwAABRQAAA==.',['�']='何伟姐:AwABCAEABAoAAQkAAAAECAQABRQ=.',['�']='修女面霜:AwABCAEABAoAAA==.',['�']='光之圣堂:AwAECAYABRQCBgAEAQhUEwA0XvQABRQABgAEAQhUEwA0XvQABRQAAA==.全需:AwAECAQABRQAAA==.六六橙:AwABCAEABAoAAA==.',['�']='冥明之中:AwAICAgABAoAAA==.冰霜贼:AwACCAIABRQAAA==.冷馨丨灬:AwACCAIABAoAAA==.',['�']='凤箫声动:AwABCAEABRQAAA==.',['�']='千骨枯:AwAECAQABRQAAA==.南拳嘛嘛:AwAECAQABRQAAA==.印第安老板鸠:AwAHCAwABAoAAA==.',['�']='叽里呱啦:AwAFCAUABAoAAA==.',['�']='呼而嗨哟:AwAECAQABRQAAQkAAAAGCAQABRQ=.',['�']='喜薇曟港:AwAGCAYABAoAAQkAAAAHCAwABAo=.',['�']='嘂猫爷嘂:AwACCAIABRQAAA==.',['�']='噩梦之子:AwAICAkABAoAAA==.',['�']='地九神:AwAGCAcABRQDDQAGAQjBAAA0Zc4BBRQADQAGAQjBAAA0Zc4BBRQAAgABAQglLQAAAAAABRQAAA==.',['�']='天使与魔神:AwABCAEABAoAAA==.天然呆自然萌:AwAFCAUABAoAAA==.',['�']='女乃女馬:AwAICAYABAoAAA==.奶油柠檬:AwADCAMABAoAAA==.',['�']='守护小果冻:AwACCAIABAoAAA==.宝宝别闹:AwAICAYABRQCDgAEAQiqEAA3quoABRQADgAEAQiqEAA3quoABRQAAA==.',['�']='富强民主:AwAECAQABRQAAA==.寒風殤魂:AwAECAQABRQAAA==.',['�']='小屹屹:AwAHCA0ABAoAAA==.小手儿冰凉凉:AwAECAQABRQAAA==.小祭司三三:AwAECAQABRQAAA==.小绵羊:AwAFCAUABAoAAA==.',['�']='弗泽亚莱因丝:AwAFCAYABAoAAA==.强颜欢笑:AwABCAEABRQAAA==.',['�']='彩虹会飞:AwAGCAYABAoAAA==.',['�']='微笑着说放弃:AwAGCAoABRQCBgAGAQj7AAAtRrYBBRQABgAGAQj7AAAtRrYBBRQAAA==.德云社:AwAICAkABAoAAA==.',['�']='怀瑜握瑾:AwAECAQABRQAAA==.',['�']='打小屁孩:AwAFCAUABAoAAA==.',['�']='拐子嗦边边:AwAICAgABAoAAA==.拐子姐:AwAFCAgABAoAAA==.',['�']='振魂醒身:AwAGCAYABRQCDwAGAQiwAQAr15oBBRQADwAGAQiwAQAr15oBBRQAAA==.',['�']='星星陨落之夜:AwACCAIABAoAAA==.春眠白雪:AwAFCAgABAoAAA==.昵芭冻冻:AwAICAYABRQCCgAGAQhrAQBMtOwBBRQACgAGAQhrAQBMtOwBBRQAAA==.昵芭夕夕:AwAECAUABRQCEAAEAQhlBABCqgMBBRQAEAAEAQhlBABCqgMBBRQAAA==.',['�']='晓星沉:AwACCAMABRQAAA==.',['�']='暖巷:AwADCAMABAoAAA==.',['�']='月影诡魅:AwAGCAwABAoAAA==.末末殇:AwAECAQABRQAAA==.',['�']='杀手不太冷:AwADCAEABAoAAA==.来啊小妞:AwADCAMABAoAAA==.来啊美眉:AwAICAgABAoAAA==.来啊美眉丶:AwAICBIABAoAAA==.',['�']='柔软的土肥圆:AwAICAgABAoAAA==.',['�']='桃也丶雾漫漫:AwAFCAUABAoAAA==.桃也雾漫漫:AwAECAsABRQCBgAEAQjdGQAmQ94ABRQABgAEAQjdGQAmQ94ABRQAAA==.',['�']='比上的风大:AwACCAIABRQAAA==.',['�']='氪萝蒂鸭:AwAECAMABAoAAA==.',['�']='沉思录:AwAICBgABAoCBgAIAQiwJQEGK2AABAoABgAIAQiwJQEGK2AABAoAAA==.',['�']='注意你的态度:AwADCAMABAoAAA==.',['�']='洒满:AwADCAMABAoAAA==.',['�']='流光追月神:AwADCAMABAoAAA==.浅酌低唱:AwAECAQABAoAAA==.',['�']='湖人总冠军:AwAGCAIABAoAAA==.湮花不待:AwACCAIABAoAAA==.',['�']='灌注给我土爹:AwAECAQABRQAAA==.灬梦魇编织者:AwAHCAIABAoAAA==.灰烬之刃:AwAICAgABAoAAA==.',['�']='熊猫烧香:AwACCAIABRQAAA==.熹微晨巷:AwAECAkABAoAAA==.',['�']='爆锤大老表:AwABCAEABRQAAA==.父亲:AwAICAgABAoAAA==.',['�']='狐狸爪子:AwADCAMABAoAAA==.狡诈的圣光:AwAGCAYABAoAAA==.',['�']='猫猫头:AwAGCAYABAoAAA==.',['�']='珐师的荣耀丿:AwAICAoABAoAAA==.',['�']='瓦史托德:AwAGCAsABRQDCwAEAQhqBgBWqBIBBRQACwAEAQhqBgBWqBIBBRQADAADAQivFQAF1WsABRQAAQ8AQnAHCAwABRQ=.',['�']='疯牛一代:AwACCAIABAoAAA==.',['�']='眞实:AwACCAYABRQCEQACAQgpDAA/s5QABRQAEQACAQgpDAA/s5QABRQAAA==.真龙:AwAGCAYABAoAAA==.',['�']='立正丶:AwAICBcABAoCEgAIAQh5CABGfx8CBAoAEgAIAQh5CABGfx8CBAoAARMAPCUGCAYABRQ=.',['�']='米奇玄师:AwAECAQABRQAAA==.',['�']='繁華丶落尽:AwAGCAYABAoAAA==.',['�']='红领章:AwAECAQABRQAAA==.纯粹灬忽悠你:AwAFCAUABAoAAA==.',['�']='经典七七:AwAICAgABAoAAA==.给朕跪下丶:AwAICAUABAoAAQkAAAAECAQABRQ=.绿洲小奶牛:AwAGCAwABAoAAA==.',['�']='缺徳组我:AwAGCAYABAoAAA==.',['�']='老挝盾牌兵:AwAECAkABAoAAA==.',['�']='肉蛋葱击:AwABCAEABAoAAA==.肥头大耳:AwAECAQABAoAAA==.',['�']='花大妞:AwACCAIABRQAAA==.花田:AwAICAgABAoAAQ4ARXsGCAoABRQ=.',['�']='莉莉亚斯:AwAECAQABRQAAA==.莓烦恼:AwABCAEABRQAAA==.',['�']='萨拉利丝:AwACCAUABRQCEQACAQgCCwBKXZ0ABRQAEQACAQgCCwBKXZ0ABRQAAA==.落忆:AwAHCAcABAoAAA==.',['�']='葡萄黑牛牛:AwAGCAYABAoAAA==.',['�']='薄暮晨光:AwAHCA8ABAoAAA==.',['�']='虫下月易:AwACCAIABRQAAA==.',['�']='西柚奶糖:AwABCAEABRQAAREAYysCCAQABRQ=.西街的尼采:AwAECAQABRQAAA==.',['�']='贼酷不爱笑:AwAICAgABAoAAA==.',['�']='起名都烦了:AwAICAgABAoAAA==.',['�']='轻裹你的风:AwAECAQABRQAAA==.',['�']='达里尔:AwAECAQABRQAAA==.',['�']='过期:AwABCAEABAoAAA==.',['�']='逆天丶凋零者:AwAICAkABAoAAA==.逆天大地:AwAECAQABRQAAA==.',['�']='遇術临瘋:AwADCAMABAoAAA==.',['�']='钢铁之手:AwAECAQABRQAAA==.',['�']='闪电风暴:AwADCAcABRQCAQADAQjkBgAssOQABRQAAQADAQjkBgAssOQABRQAAA==.',['�']='雾中寻鹿:AwAICB8ABAoCBgAIAQgDAQBjLSMDBAoABgAIAQgDAQBjLSMDBAoAARMAPCUGCAYABRQ=.',['�']='青椰芝士:AwADCAQABAoAAA==.',['�']='風之瀦潴:AwAGCAQABRQAAQMAYjsICBwABRQ=.',['�']='马桶小圣:AwAICAgABAoAAA==.',['�']='鲁智森:AwACCAQABRQAAA==.鲍抱:AwAHCA8ABAoAAA==.',['�']='鸡肥蛋大:AwADCAYABAoAAA==.',['�']='麥洛汀朵:AwACCAIABAoAAA==.',['�']='黑夜丶雨蘅:AwAFCAUABAoAAA==.黑牛战:AwAECAEABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end