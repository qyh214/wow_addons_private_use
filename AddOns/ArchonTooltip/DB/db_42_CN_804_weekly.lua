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
 local lookup = {'Druid-Guardian','Druid-Restoration','Druid-Feral','Rogue-Assassination','Rogue-Subtlety','Mage-Frost','Warrior-Arms','Warrior-Fury','Monk-Mistweaver','Mage-Fire','Druid-Balance','Paladin-Retribution','Unknown-Unknown','Hunter-Marksmanship','Hunter-BeastMastery','DemonHunter-Havoc','Priest-Holy','Warlock-Affliction','Warlock-Demonology','Evoker-Preservation','Evoker-Devastation','Priest-Discipline','Shaman-Enhancement','Shaman-Elemental','Warrior-Protection','Priest-Shadow','Warlock-Destruction','Monk-Brewmaster','DeathKnight-Frost','DeathKnight-Blood',}; local provider = {region='CN',realm='艾露恩',name='CN',type='weekly',zone=42,date='2025-04-15',data={Fo='Foley:AwACCAQABRQEAQAIAQj+FQARMMsABAoAAQAHAQj+FQARMMsABAoAAgAHAQgSUgAHDKUABAoAAwAFAQjZIgAMBXIABAoAAA==.',Fr='Frieren:AwACCAIABAoAAA==.',Ho='Horzin:AwACCAQABRQDBAAIAQj/FAA7v8MBBAoABAAIAQj/FAA4csMBBAoABQAIAQhrFAAmrKgBBAoAAA==.',Ib='Ibaby:AwABCAEABAoAAA==.',Is='Ishtar:AwAGCAYABAoAAA==.',Jo='Jokerfs:AwAICAgABAoAAA==.',Ko='Komorebix:AwAGCAYABAoAAA==.',Kr='Kralph:AwAICAgABAoAAA==.',Ku='Kururur:AwAGCAQABRQAAA==.',La='Langley:AwACCAMABRQCBgAIAQjpHgBBbvQBBAoABgAIAQjpHgBBbvQBBAoAAA==.',Lu='Lueblus:AwAGCAQABRQAAA==.',Me='Meet:AwAFCAgABAoAAA==.',Nb='Nbzs:AwAICAgABAoAAA==.',Pu='Pudgybear:AwAECAQABRQAAA==.',Ri='Rickcater:AwAGCAoABRQDBwAGAQjPAAA2BrUBBRQABwAGAQjPAAAs+bUBBRQACAAEAQjbCABCiA8BBRQAAA==.',Sc='Scbw:AwAECAQABRQAAA==.',Sh='Shigure:AwACCAIABAoAAQkAF34ECAcABRQ=.',Si='Sile:AwAGCAUABAoAAA==.',So='Soultaker:AwABCAEABAoAAA==.',Ti='Tikorei:AwAECAcABRQCCgAEAQjvEABBWfoABRQACgAEAQjvEABBWfoABRQAAA==.',Tr='Tropicanar:AwAGCAYABAoAAA==.',Zz='Zzx:AwAICBEABAoAAA==.',['�']='一头神仙:AwAECAQABRQAAA==.一方神圣:AwAECAgABRQDCwAEAQhLCwBUaAEBBRQACwAEAQhLCwBUaAEBBRQAAgAEAQgCDQAP8KsABRQAAQIAKDkGCAYABRQ=.不语的娃哥:AwADCAkABRQCDAADAQheIAAbv80ABRQADAADAQheIAAbv80ABRQAAA==.丨不灭狂雷丨:AwACCAIABRQAAA==.',['�']='伊斯瑞尔:AwAICAgABAoAAA==.伍六七丶:AwAECAQABRQAAA==.',['�']='俩条悟丶:AwAICAgABAoAAQ0AAAAICAQABRQ=.',['�']='兵马俑的春天:AwAICAUABAoAAA==.',['�']='冰吸生椰拿铁:AwAECAQABRQAAA==.冰雨呀:AwAHCAYABAoAAA==.',['�']='凉拌肥肠:AwAICBAABAoAAA==.',['�']='勇敢牛暖暖:AwAECBQABRQDCwAEAQhACwBIUQIBBRQACwAEAQhACwBIUQIBBRQAAgAEAQiHCgAhGcIABRQAAA==.',['�']='北白河千百合:AwAECAgABRQDCwAEAQiDCwBFvgABBRQACwAEAQiDCwBFvgABBRQAAgAEAQhSDwAGgpQABRQAAA==.北葵向暖:AwAICAgABAoAAA==.',['�']='千石抚子:AwAECAQABRQAAA==.南吕:AwACCAIABRQAAA==.',['�']='去年买的表丶:AwAHCA0ABAoAAA==.',['�']='叫我靓仔:AwAGCA0ABAoAAA==.可我在读条啊:AwAECAMABAoAAA==.',['�']='吃饱黑钥睡觉:AwAECAQABRQAAQ4APEoECAwABRQ=.名字嘎一点:AwAGCAYABAoAAA==.吴丶尔丹:AwAICA4ABAoAAA==.',['�']='和声:AwAECAYABRQCDwAEAQihEABOcf4ABRQADwAEAQihEABOcf4ABRQAAA==.咳咳糖:AwAICAQABAoAAA==.',['�']='嗜胸:AwAICBUABAoCEAAIAQgcNQA1Nb0BBAoAEAAIAQgcNQA1Nb0BBAoAAA==.嗜血的蘇菲:AwAECAQABRQAAA==.',['�']='四月一:AwAGCAYABRQCDwAGAQi2AABO5wACBRQADwAGAQi2AABO5wACBRQAAA==.囝囝:AwABCAMABAoAAA==.',['�']='圣嘉然:AwACCAQABRQCEQAIAQhiBQBePK4CBAoAEQAIAQhiBQBePK4CBAoAAQ0AAAADCAQABRQ=.',['�']='坏三岁:AwAGCAgABRQCBAAGAQhhAABJ4vQBBRQABAAGAQhhAABJ4vQBBRQAAA==.',['�']='复仇男爵:AwAECAgABRQCDAAEAQjTFgA1R/EABRQADAAEAQjTFgA1R/EABRQAAA==.夜天:AwACCAIABRQAAA==.',['�']='奶酪:AwAECAgABRQDCwAEAQg3CwBUagIBBRQACwAEAQg3CwBUagIBBRQAAgABAQjhHwAH/S8ABRQAAA==.',['�']='姜汁可乐:AwAECAQABRQAAA==.',['�']='婉若游龍:AwACCAIABAoAAA==.',['�']='子龙:AwAECAQABRQAAA==.孤影求醉:AwAICAgABAoAAA==.孤行:AwABCAEABRQAAA==.',['�']='安徽大师兄:AwAGCAYABRQDEgAGAQggAgA78SgBBRQAEgADAQggAgBHPygBBRQAEwADAQiZBQAq+qkABRQAAA==.宝宝萨:AwAECAQABRQAAA==.家有凶喵:AwABCAIABRQAAA==.',['�']='射得发麻:AwAFCAUABAoAAA==.小小的老子:AwAICAgABAoAAA==.小玫瑰:AwAGCAYABRQDFAAGAQh7AQAaLBABBRQAFAAFAQh7AQAb8hABBRQAFQABAQhHFwAKzVIABRQAAA==.小的的德:AwACCAIABAoAAA==.小空灬霁月:AwACCAIABRQAAA==.小米丶超人:AwAICAQABAoAAA==.小陀螺扛把子:AwAECAgABRQCCQAEAQh3CQA6YQUBBRQACQAEAQh3CQA6YQUBBRQAAA==.尐萨:AwAECAQABRQAAA==.就也不要怕输:AwAGCAYABRQDFQAEAQjKCwAzyNkABRQAFQADAQjKCwAzyNkABRQAFAACAQiFBwBbsGcABRQAAA==.',['�']='屁屁妞:AwAGCAkABAoAAA==.山泥若:AwAICA0ABAoAAQoAMlIGCA0ABRQ=.',['�']='岛琦瑶香:AwACCAQABRQDBgAIAQhwDQBW94ACBAoABgAIAQhwDQBW94ACBAoACgAEAQgJbAAuLK0ABAoAAA==.',['�']='巴黎欧莱雅:AwACCAMABRQDEQAIAQgfNgAg+0IBBAoAEQAIAQgfNgAdI0IBBAoAFgAFAQgGUwAbFKoABAoAAA==.',['�']='布莱恩特丝:AwAICBAABAoAAQ0AAAAGCAQABRQ=.',['�']='平凡上班族:AwAHCAkABAoAAA==.',['�']='影之怒:AwACCAUABRQDFwACAQj/DgA75pgABRQAFwACAQj/DgA5xZgABRQAGAABAQj0EwBBIksABRQAAA==.',['�']='微笑时那美好:AwAICAYABAoAAA==.德拉萨鲁法尔:AwAGCAQABRQAAA==.',['�']='恨人有:AwAECAgABRQDCwAEAQi1BwBNjxgBBRQACwAEAQi1BwBNjxgBBRQAAgADAQggBgBBNfcABRQAAA==.',['�']='悠悠夏曰:AwACCAYABRQCEAACAQjjGABaB8YABRQAEAACAQjjGABaB8YABRQAAA==.',['�']='慕雨芬芬:AwAECAQABRQAAA==.',['�']='戚薇:AwAGCAYABRQCBQAGAQg3AABTlhgCBRQABQAGAQg3AABTlhgCBRQAAA==.',['�']='把妹丶不负责:AwACCAUABRQCEQACAQjODwBLVpgABRQAEQACAQjODwBLVpgABRQAAA==.',['�']='拔刀吧总管:AwAECAQABRQAAA==.',['�']='撸初雪:AwAICAgABAoAAA==.',['�']='无法评价:AwAICAYABAoAAA==.无责任神:AwAICAgABAoAAA==.',['�']='昡灵子:AwAGCAQABRQAAA==.',['�']='晓晓豆包:AwAHCAgABAoAAA==.晓灬龙:AwAICAgABAoAAA==.',['�']='暴躁的小情绪:AwABCAEABRQAAA==.暴躁的尒情绪:AwACCAIABRQAAA==.',['�']='朱颜海:AwAECAwABRQDDgAEAQhACQA8SuYABRQADgAEAQhACQA4weYABRQADwAEAQiPFwA3aOUABRQAAA==.机智的大兔子:AwAICA4ABAoAAA==.',['�']='格鲁姆:AwAECAQABRQAAA==.',['�']='桔梗的十月:AwAECAQABRQAAA==.',['�']='梵韵的二月:AwACCAQABRQAAA==.',['�']='步婉丶:AwAGCAYABAoAAA==.',['�']='残影灬幽月:AwAECAQABRQAAA==.',['�']='汉堡他大叔:AwAGCAkABRQCEAAGAQgWAgA0OK8BBRQAEAAGAQgWAgA0OK8BBRQAAA==.',['�']='洞里的小秃子:AwAGCAoABRQDBwAGAQhiAAA9TtwBBRQABwAGAQhiAAA9TdwBBRQACAAEAQjqDgAq3/AABRQAAA==.',['�']='淞鼠鳜鱼:AwACCAQABRQEGQAIAQjXFAAp6UwBBAoAGQAIAQjXFAAn1kwBBAoACAAEAQg+UwAk+OsABAoABwABAQilZAAE6xoABAoAAA==.',['�']='清酒:AwAFCAIABRQAAA==.清醒梦之忆:AwAECAQABRQAAA==.',['�']='潜在情人:AwAGCAQABRQAAA==.潮水大师总管:AwAICAsABAoAARcAM3YICAkABRQ=.',['�']='火亦生生不息:AwAHCAcABAoAAA==.灬夜灬:AwAGCAMABAoAAA==.灬氵:AwAICBAABAoAAA==.灬聖镗丶伍仕:AwADCAcABRQCDAADAQiGKgAvHpwABRQADAADAQiGKgAvHpwABRQAAA==.',['�']='炫酷的宝贝:AwACCAIABAoAAA==.',['�']='爆风城酋长:AwAHCAcABAoAAA==.',['�']='猎雨:AwABCAEABRQAAA==.猛弄瘸子右手:AwADCAgABRQCDwADAQiJGQApnNwABRQADwADAQiJGQApnNwABRQAAA==.猪皮星:AwAECAQABRQAAA==.',['�']='王晓虫的世界:AwAHCAcABAoAAA==.玫瑰花一朵:AwACCAIABAoAAA==.',['�']='番茄沙拉:AwAECAkABRQDBAAEAQjABABQ/w8BBRQABAAEAQjABABFzQ8BBRQABQAEAQgOBwAyfvAABRQAAA==.',['�']='白鹭:AwAICAgABAoAAA==.',['�']='瞎摸摸:AwAICAEABAoAAA==.',['�']='神宫寺玖惠澄:AwEICAIABAoAARoAMGgGCAoABRQ=.神牧宁宁:AwAGCAQABRQAAA==.神真子大师:AwAICAgABAoAAA==.',['�']='粘稠的胖纸:AwAICCQABAoCDAAIAQjWDgBbFNMCBAoADAAIAQjWDgBbFNMCBAoAAA==.',['�']='糖门尊者:AwAECAIABRQAAQkARJAICBYABRQ=.',['�']='紫宵丶阿尼亚:AwAICBAABAoAAA==.紫枫孤珏:AwAECAQABRQAAA==.',['�']='红豆氵:AwAECAQABAoAAA==.',['�']='练习两年半:AwACCAIABRQAAQ8AShkGCA4ABRQ=.练习六年半:AwAECAQABRQAAA==.',['�']='羊蝎子:AwACCAEABRQEGQAIAQhADgBIkqsBBAoAGQAHAQhADgBAV6sBBAoACAAGAQgkMQBNiKQBBAoABwABAQh2XAAQoDgABAoAAA==.羡慕许仙睡蛇:AwADCAMABAoAAA==.',['�']='翎乱灬馒头:AwAHCAcABAoAAA==.',['�']='老頭樂:AwACCAIABRQAAA==.',['�']='肝爆的阿昆达:AwAECAQABRQAAA==.肥葵:AwADCAQABRQAAA==.',['�']='花吃了这女孩:AwACCAQABRQEEwAIAQjFFwA5SIgBBAoAEwAGAQjFFwA9KYgBBAoAGwAGAQihQAAoC08BBAoAEgAFAQhlJAAcjLYABAoAAA==.花街卖笑:AwAECAQABRQAAA==.花间游:AwACCAIABAoAAQ0AAAAECAQABRQ=.',['�']='茅台:AwACCAQABRQCHAAIAQhiCwAt1XoBBAoAHAAIAQhiCwAt1XoBBAoAAA==.茗笙笙:AwAECAQABRQAAA==.茫然:AwAICBAABAoAAA==.',['�']='菠萝快跑:AwAICAgABAoAAA==.',['�']='萌喵超人:AwACCAIABRQAAA==.萌面潮人:AwACCAQABRQCFwAIAQh+GAA1ePIBBAoAFwAIAQh+GAA1ePIBBAoAAA==.',['�']='董三更:AwAECAQABAoAAA==.',['�']='蒙牛血蹄:AwADCAMABRQAAA==.',['�']='蓝纹奶酪:AwAECAUABRQDBgACAQhkFQA8404ABRQACgACAQgYKgAwKYkABRQABgABAQhkFQBTaE4ABRQAAA==.',['�']='虛灵灬:AwAECAQABRQAAA==.',['�']='西虹市首富:AwADCAUABRQCDAADAQh0MgAqAYgABRQADAADAQh0MgAqAYgABRQAAA==.',['�']='超级无敌暴龙:AwAICAgABAoAAA==.',['�']='迷踪岛:AwACCAIABRQAAA==.',['�']='遮沙避风:AwAICAIABAoAAA==.',['�']='酆都黎明:AwAICAgABAoAAA==.',['�']='锦时:AwAECAQABRQAAA==.',['�']='阿德莱德:AwAECAwABRQDHQAIAQiNBwBVRy0CBAoAHQAIAQiNBwBQjC0CBAoAHgAIAQiKEwBIoOkBBAoAAQ0AAAAICAEABRQ=.',['�']='陆辛禾:AwAICA4ABAoAAA==.陈景:AwAECAYABRQDBgAEAQidDgAhso4ABRQACgAEAQi7HQAclswABRQABgACAQidDgAjXI4ABRQAAA==.陳永仁:AwAECAQABAoAAA==.',['�']='雨霖铃丶:AwEECAEABRQAAQ0AAAAICAMABRQ=.',['�']='青木倩:AwAECAQABRQDFQAIAQiTFgBB6OoBBAoAFQAIAQiTFgBB6OoBBAoAFAAIAQgwDAAsC40BBAoAAA==.青涩后妈:AwAECAQABRQAAA==.青羽环佩:AwACCAIABAoAAA==.静安面包房:AwACCAUABRQCCgACAQhRIgBOWKsABRQACgACAQhRIgBOWKsABRQAAA==.',['�']='韵香乌龙茶:AwABCAEABRQAAA==.',['�']='风暴劣酒:AwAGCAYABAoAAA==.风魔灵:AwAICAgABAoAAA==.飘零的羽毛:AwAGCAUABRQDEgAEAQj2AwBWUgsBBRQAEgADAQj2AwBWUgsBBRQAEwABAQjjGAAAAAAABRQAAA==.飞鹰成风:AwAGCAoABRQCDAAGAQgPAQBBZ8UBBRQADAAGAQgPAQBBZ8UBBRQAAA==.',['�']='黑心超人:AwAECAQABRQAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end