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
 local lookup = {'DeathKnight-Unholy','Monk-Mistweaver','Monk-Brewmaster','Paladin-Protection','Priest-Discipline','Rogue-Assassination','Rogue-Subtlety','Unknown-Unknown','Warrior-Fury','Warrior-Arms','Mage-Fire','Hunter-BeastMastery','Hunter-Marksmanship','Druid-Restoration','Paladin-Retribution','Priest-Shadow','Priest-Holy','Shaman-Enhancement','Shaman-Elemental','Shaman-Restoration','Druid-Balance',}; local provider = {region='CN',realm='千针石林',name='CN',type='weekly',zone=42,date='2025-04-14',data={Ar='Areally:AwAFCAYABAoAAA==.',Ay='Ayalegna:AwAHCBYABAoCAQAHAQh5KgBLJtwBBAoAAQAHAQh5KgBLJtwBBAoAAA==.',Do='Dobi:AwAHCA0ABAoAAA==.',Fc='Fcrown:AwAECAgABRQDAgAEAQjzCgA35u8ABRQAAgAEAQjzCgA35u8ABRQAAwAEAQi8BQAGKXEABRQAAA==.',Ho='Holysprite:AwACCAIABRQCBAAIAQhPGQArimkBBAoABAAIAQhPGQArimkBBAoAAA==.',Ii='Iilidann:AwACCAIABRQAAA==.',In='Innocence:AwACCAIABAoAAA==.',Le='Leonardo:AwAGCAYABAoAAA==.',Mi='Missdk:AwAECAQABRQAAA==.',Na='Nafen:AwAFCAUABAoAAA==.',Ne='Nevin:AwAECAQABRQAAQUANgYGCAYABRQ=.',Sa='Sacredhealer:AwAECAQABRQAAA==.',Sc='Scarletti:AwAGCAQABRQAAA==.',Sh='Shadowdance:AwACCAIABRQDBgAIAQhpGwAv52gBBAoABgAHAQhpGwAnv2gBBAoABwAGAQjgGQAwUVYBBAoAAA==.',Si='Sixmilk:AwAECAQABRQAAA==.',Th='Thislaypain:AwABCAEABAoAAA==.',['�']='一切有为法丶:AwAICAYABAoAAQUAPiAICA4ABRQ=.一枕江风梦:AwAICAUABAoAAA==.丨和光同尘丨:AwAFCAUABAoAAA==.丨小灬飛丨:AwABCAIABRQCBgAIAQg9BgBWaooCBAoABgAIAQg9BgBWaooCBAoAAA==.',['�']='伊利達雷:AwAICAgABAoAAA==.伍子胥:AwAICCMABAoCAgAIAQhTHQA7UuIBBAoAAgAIAQhTHQA7UuIBBAoAAA==.',['�']='你老夜:AwAICAgABAoAAQgAAAAICAQABRQ=.',['�']='冬季的苍白:AwAHCA8ABAoAAA==.冲锋感觉:AwADCAkABRQDCQADAQimEwA2+bIABRQACQACAQimEwA8obIABRQACgABAQiQEQArqVMABRQAAA==.',['�']='制裁之刃:AwAECAgABRQCBAAEAQj5BABG3ewABRQABAAEAQj5BABG3ewABRQAAA==.',['�']='卫老师是我呀:AwADCAYABAoAAA==.',['�']='又见小百事:AwADCAcABRQCAQADAQgIEgATGbgABRQAAQADAQgIEgATGbgABRQAAA==.',['�']='吉吉国王酱:AwAICAgABAoAAA==.吟慧:AwAHCA8ABAoAAA==.',['�']='喂升经:AwAGCAwABAoAAQgAAAAICAkABAo=.',['�']='圣光是信仰丶:AwAHCAcABAoAAA==.',['�']='大殺四方:AwABCAEABAoAAA==.大青龙汤:AwAICA8ABAoAAA==.天地悠悠:AwAECAQABAoAAA==.太子妃:AwAECAQABRQAAQgAAAAICAQABRQ=.',['�']='奇奇格:AwAICAcABAoAAA==.',['�']='姿那诺:AwABCAEABRQAAA==.',['�']='威少:AwACCAIABAoAAA==.',['�']='小小烂仔头:AwAECAQABAoAAA==.小茶壶嘴嘴:AwAECAQABRQAAQoAIZ4GCAoABRQ=.',['�']='布兰克斯:AwACCAIABAoAAA==.带球撞人:AwAICAwABAoAAA==.',['�']='打咩打咩打咩:AwAGCAYABAoAAA==.扶我起来:AwACCAMABRQAAA==.',['�']='拔娜娜:AwAHCAcABAoAAA==.',['�']='時雨丶:AwAECAUABRQCCwAEAQioGAAnzdgABRQACwAEAQioGAAnzdgABRQAAA==.普雷尔踢:AwAECAcABAoAAA==.',['�']='暗夜小美:AwAHCAsABAoAAA==.',['�']='曦钥:AwAGCAYABRQCBAAGAQgOAwAcSyMBBRQABAAGAQgOAwAcSyMBBRQAAA==.',['�']='李唐李糖糖丶:AwAGCBEABAoAAA==.杰神大妈:AwAECAsABRQCDAAEAQjSEABM5PYABRQADAAEAQjSEABM5PYABRQAAQgAAAAICAQABRQ=.',['�']='标星光:AwAHCAcABAoAAA==.',['�']='椰奶凤梨:AwABCAEABAoAAA==.',['�']='沿途右旋:AwAECAQABRQAAA==.',['�']='泰瑞尔丶破晓:AwACCAIABRQAAA==.',['�']='清淵煙寂:AwABCAIABRQAAA==.渣渣非:AwAECAQABRQAAA==.',['�']='滴血残阳:AwABCAEABRQAAA==.',['�']='澤風大過:AwABCAEABAoAAA==.',['�']='灬静香源灬:AwABCAEABAoAAA==.灵能:AwAECAQABRQAAA==.',['�']='热血猎神:AwABCAEABRQDDAAIAQhxYgAnM1kBBAoADAAHAQhxYgAoglkBBAoADQAFAQiTOwAakeoABAoAAA==.',['�']='燕同心:AwAECAgABRQCBgAEAQj0BQBJofoABRQABgAEAQj0BQBJofoABRQAAQgAAAAICAQABRQ=.',['�']='爱之修罗:AwAICAgABAoAAA==.爱的火铳炮:AwAHCAgABAoAAA==.',['�']='生死由命:AwAHCAcABAoAAA==.电话沟通:AwAECAQABRQAAA==.',['�']='疯狂帽子:AwABCAEABAoAAA==.疯狂打铁:AwACCAIABRQAAA==.',['�']='白凤九:AwACCAIABRQAAQ4AOkwGCAUABRQ=.白虎吐沫:AwAGCAIABRQAAA==.',['�']='神圣惩戒龙:AwAECAYABRQCDwAEAQicCABQDx8BBRQADwAEAQicCABQDx8BBRQAAA==.',['�']='笙乄壹:AwAECAsABRQDEAAEAQgyCABH7QABBRQAEAAEAQgyCABH7QABBRQAEQACAQiVGgATS0AABRQAAA==.笙九:AwAECAQABRQAAA==.',['�']='等到花開:AwACCAUABRQCEgACAQgHEwA/10kABRQAEgACAQgHEwA/10kABRQAAA==.',['�']='糯米兮兮:AwAFCAUABAoAAA==.',['�']='紫霞一仙子:AwABCAEABRQAAA==.',['�']='老玖:AwAFCAQABAoAAA==.老财:AwAHCAEABAoAAA==.',['�']='腋毛乱舞:AwAICCAABAoDEwAIAQjNGABOT/kBBAoAEwAIAQjNGABOT/kBBAoAFAAIAQjaKQA+pb4BBAoAAA==.',['�']='虎妞子:AwAICAwABAoAAA==.虚空之触:AwAECAgABRQCEAAEAQhECgBOJ+0ABRQAEAAEAQhECgBOJ+0ABRQAAA==.',['�']='西非要西:AwAECAQABRQAAA==.',['�']='變型伊蘭:AwABCAEABRQAAA==.',['�']='贝丶壳:AwAICAgABAoAAA==.',['�']='这个萨有点电:AwABCAEABRQAAA==.迷途旧梦:AwADCAIABRQAAQsARzEGCAkABRQ=.',['�']='逝之星辰:AwAECAMABAoAAA==.',['�']='陆柒捌带槽:AwAICAYABAoAAQgAAAAECAQABRQ=.',['�']='隨風而逝:AwAICAgABAoAAA==.',['�']='雨宫隼:AwACCAIABRQAAA==.',['�']='飘飖兮若流风:AwABCAEABRQAAA==.',['�']='馮婉貞:AwABCAEABRQAAA==.',['�']='高小恒:AwAECAQABRQAAA==.',['�']='鸡委发言人:AwAICBcABAoDFQAIAQjUKQBARO0BBAoAFQAIAQjUKQBARO0BBAoADgABAQiGfgAJRyYABAoAAA==.',['�']='黑妹儿:AwAGCAkABAoAAA==.',['�']='龍東槍:AwADCAUABRQCFQADAQglFwAVvbIABRQAFQADAQglFwAVvbIABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end