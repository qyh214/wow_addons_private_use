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
 local lookup = {'Hunter-BeastMastery','Unknown-Unknown','Paladin-Protection','Shaman-Restoration','Hunter-Marksmanship','Priest-Shadow','Priest-Holy','Priest-Discipline','Paladin-Holy','Warlock-Destruction','Warlock-Affliction','Monk-Mistweaver','Shaman-Elemental','Shaman-Enhancement','Warrior-Fury','Monk-Windwalker','Rogue-Subtlety','Druid-Restoration',}; local provider = {region='CN',realm='外域',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ha='Halfkoala:AwAECAQABRQAAA==.',Jo='Joy:AwADCAUABRQCAQADAQjACgBA5hMBBRQAAQADAQjACgBA5hMBBRQAAA==.',Ju='July:AwAHCAcABAoAAA==.',Li='Liadrin:AwAECAQABRQAAA==.',Mo='Monsky:AwABCAEABRQAAA==.',Ya='Yacker:AwAGCA4ABAoAAQIAAAAGCAQABRQ=.',['�']='不要追我:AwADCAUABAoAAA==.丨周二少丶:AwACCAIABRQAAA==.丨爆丶龖丨:AwAECAQABRQAAA==.',['�']='从頭开始:AwABCAEABRQAAA==.',['�']='侃侃盖恩:AwADCAMABRQAAA==.侃侃莱恩:AwAFCAUABAoAAA==.侃侃菲恩:AwAFCAUABRQCAwAFAQgcAgA5i0MBBRQAAwAFAQgcAgA5i0MBBRQAAA==.依然烤香肠:AwAGCA0ABRQCBAAGAQgfAABD4egBBRQABAAGAQgfAABD4egBBRQAAA==.',['�']='光丶:AwACCAIABAoAAA==.关晛:AwAICCQABAoCBQAIAQh+FwBAkdwBBAoABQAIAQh+FwBAkdwBBAoAAA==.',['�']='再打我变熊:AwAECAQABRQAAA==.',['�']='刘大宝:AwACCAMABRQAAA==.',['�']='千幻流光:AwAECAcABAoAAQIAAAAICAIABRQ=.半只鹌鹑:AwAECAQABRQAAA==.',['�']='叽叽:AwAGCAoABRQEBgAGAQgxBAAiPDwBBRQABgAFAQgxBAAeMzwBBRQABwAEAQgHCwAQc70ABRQACAABAQh8GwAzR08ABRQAAA==.',['�']='后跳欸滴滴:AwAICAIABAoAAA==.',['�']='坠入凡尘:AwACCAQABAoAAA==.',['�']='夜溪儿:AwACCAMABRQCCQAIAQgVDQA+JfwBBAoACQAIAQgVDQA+JfwBBAoAAA==.夜溪兒:AwACCAYABRQCCQACAQgKCwAnvJAABRQACQACAQgKCwAnvJAABRQAAA==.大表姐丶:AwADCAEABAoAAA==.',['�']='宇文術学:AwADCAYABRQDCgADAQj1GwAoUXcABRQACgACAQj1GwAm5HcABRQACwABAQitFgArK0wABRQAAA==.',['�']='寇往吾亦可往:AwABCAEABRQAAA==.寒冰宝珠:AwAICAgABAoAAA==.',['�']='小八有神奇:AwAECAYABAoAAA==.小槑:AwAECAQABRQAAA==.',['�']='巫小可:AwAICAgABAoAAA==.巫毒嘎嘎:AwAFCAIABAoAAA==.',['�']='希斯莱杰丶:AwAGCAYABAoAAA==.席琳虛空牧:AwAGCAUABRQCBgAEAQjcCQA/W/EABRQABgAEAQjcCQA/W/EABRQAAA==.',['�']='平静之环:AwAGCAwABRQCDAAGAQiEAgAPxHEBBRQADAAGAQiEAgAPxHEBBRQAAA==.',['�']='心情在变:AwABCAIABRQAAA==.',['�']='恩丶我知道:AwAECAwABRQDDQAEAQgYBwAuZeMABRQADQAEAQgYBwAuZeMABRQABAAEAQiADAApTOIABRQAAQ4AM3YICAkABRQ=.恶念之花:AwAFCAUABAoAAA==.',['�']='放了那大婶:AwAICBgABAoCDwAIAQgsGgBA5yQCBAoADwAIAQgsGgBA5yQCBAoAAA==.',['�']='无妻:AwAECAUABAoAAA==.',['�']='星界德:AwAECAQABRQAAA==.',['�']='晴天小猪:AwAICAoABAoAAQIAAAACCAIABRQ=.',['�']='暗冥之手:AwAICAEABAoAAA==.暗影冲撞:AwAECAQABRQAAA==.',['�']='果壳麋鹿:AwAICAMABAoAAA==.',['�']='槑圆润:AwAECAQABRQAAA==.',['�']='欧乐币:AwAICAsABAoAAA==.欧皇丨利哥哥:AwACCAIABRQAAQIAAAAICAIABRQ=.',['�']='治疗之涌:AwAICAgABAoAAA==.',['�']='浮生若梦丶:AwAECAQABRQAAA==.',['�']='液魔影瑝:AwAGCA4ABAoAAA==.',['�']='淩波麗:AwAECAEABAoAAA==.',['�']='滚球球:AwAECAQABAoAAA==.',['�']='灵行天下麒麟:AwACCAIABRQAAA==.',['�']='無敌最寂寞:AwAICAgABAoAAA==.',['�']='牛丶奶:AwAECAQABRQAAA==.牛牛光环:AwABCAEABRQAAA==.牜丶萨满:AwABCAEABAoAAA==.牧玖:AwAICAgABAoAAA==.牧莱克斯塔萨:AwAECAQABRQAAA==.特仑苏:AwABCAEABAoAAA==.',['�']='狂暴的鸽子:AwACCAIABRQAAA==.',['�']='猫就是我家滴:AwACCAIABAoAAA==.',['�']='琢玉:AwAGCAYABAoAAA==.',['�']='璃丶:AwAGCA0ABAoAAA==.',['�']='生命终章:AwAGCAgABRQDDgAGAQihAAA4dtgBBRQADgAGAQihAAA4dtgBBRQADQACAQifDwAgyn8ABRQAAA==.电动乀小马达:AwAICAgABAoAAA==.',['�']='疯狂的飞机丶:AwAFCAgABAoAAA==.',['�']='真好丸:AwAICAgABAoAAA==.',['�']='空空子:AwAECAQABAoAAA==.',['�']='等我升腾:AwAGCAYABRQCBAAGAQghAABPW+UBBRQABAAGAQghAABPW+UBBRQAAA==.等风起:AwAECAUABAoAAA==.',['�']='索拉之緲:AwADCAYABRQDDAADAQjeDgAngtgABRQADAADAQjeDgAngtgABRQAEAABAQh9GgATZToABRQAAA==.',['�']='纯害人的:AwAECBAABRQCEQAEAQjcAQBbSD0BBRQAEQAEAQjcAQBbSD0BBRQAAA==.',['�']='编号:AwAICAIABAoAAA==.',['�']='羽羽丰:AwABCAEABRQAAA==.',['�']='舌尝思:AwAGCAYABRQCEgAGAQgsAQAnn30BBRQAEgAGAQgsAQAnn30BBRQAAA==.',['�']='艾斯卡诺:AwAGCAoABAoAAA==.',['�']='茉莉绝悬:AwAGCAQABAoAAA==.',['�']='莫西干男人:AwAICAMABAoAAA==.',['�']='落月沉星:AwAECAQABRQAAA==.',['�']='蒋劲夫:AwAECAQABRQAAA==.',['�']='虚空:AwABCAEABRQAAA==.',['�']='言念君子:AwAECAQABRQAAA==.',['�']='请叫我萱总:AwAGCAYABAoAAA==.',['�']='践踏战争:AwAHCAcABAoAAA==.',['�']='身本懮:AwAECAYABRQDBwAEAQhvAQBZszcBBRQABwAEAQhvAQBZszcBBRQABgACAQjjFgAZcHsABRQAAA==.',['�']='车友车行:AwAECAQABRQAAA==.',['�']='过往灬烟云:AwACCAIABRQAAA==.迷你烤鸡翅:AwAHCAcABAoAAA==.',['�']='醉月丶觞:AwAGCAQABRQAAA==.',['�']='钕神矜嘚祈愿:AwACCAIABRQAAA==.',['�']='阿豪诶:AwABCAEABRQAAA==.',['�']='隔离屋只牛:AwAICAMABAoAAA==.',['�']='霜火圣光:AwADCAEABRQAAA==.',['�']='鱼心丸子:AwACCAIABRQAAA==.',['�']='鸡脖断:AwAGCAYABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end