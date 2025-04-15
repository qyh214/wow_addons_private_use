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
 local lookup = {'Shaman-Restoration','Druid-Balance','DeathKnight-Unholy','DeathKnight-Frost','Shaman-Elemental','Unknown-Unknown','Mage-Fire','DeathKnight-Blood','Hunter-Marksmanship','Hunter-BeastMastery','Mage-Frost','DemonHunter-Havoc','Priest-Shadow','Rogue-Subtlety','Rogue-Assassination','DemonHunter-Vengeance','Paladin-Retribution','Druid-Restoration','Monk-Mistweaver',}; local provider = {region='CN',realm='风暴峭壁',name='CN',type='weekly',zone=42,date='2025-04-15',data={Aq='Aqualwitch:AwAECAQABRQAAA==.',At='Atroposs:AwACCAEABRQAAA==.',Cp='Cppxy:AwAGCA0ABAoAAA==.',Cu='Curaplke:AwADCAkABRQCAQADAQjWCABK3gIBBRQAAQADAQjWCABK3gIBBRQAAA==.',De='Devileye:AwACCAMABAoAAA==.',Fi='Firmament:AwACCAkABRQCAgACAQhBGQBSsLYABRQAAgACAQhBGQBSsLYABRQAAA==.',Ho='Hoothoot:AwAFCAUABAoAAA==.',Is='Ishmael:AwABCAEABAoAAA==.',Lo='Longgray:AwAECAQABAoAAA==.',Ma='Manchester:AwAICAoABAoAAA==.Marlee:AwAGCAkABAoAAA==.',Mi='Mintrandir:AwAECAYABAoAAA==.',Po='Pokemongo:AwAGCAYABAoAAA==.',Pp='Ppaalldd:AwAICAgABAoAAA==.',Pr='Proxius:AwAECAQABRQAAA==.',St='Starless:AwAICAgABAoAAA==.',Su='Summerbloom:AwAECAUABRQDAwAEAQhPEQAnodMABRQAAwAEAQhPEQAmZ9MABRQABAABAQgTCAAkVDkABRQAAA==.',Yr='Yrel:AwAICBIABAoAAA==.',Zn='Znye:AwAFCAgABAoAAA==.',['�']='万物皆可盘:AwAICAgABAoAAA==.不吓人的小鬼:AwADCAMABAoAAA==.世界最强:AwAICCMABAoDBQAIAQicEgBMj0ACBAoABQAIAQicEgBMj0ACBAoAAQABAQjKtAAHySUABAoAAA==.世界第一萨满:AwAICA8ABAoAAA==.丨安吉斯丶:AwABCAEABAoAAQYAAAAICAQABRQ=.丶小星星:AwAECAUABRQCAwAEAQifEQAcHdAABRQAAwAEAQifEQAcHdAABRQAAQMAMUoICAgABRQ=.丶摩尔迦娜:AwAGCA8ABRQCBwAGAQi6AQBRtO0BBRQABwAGAQi6AQBRtO0BBRQAAA==.',['�']='久伴丷:AwAECAQABAoAAA==.么么战熊:AwAECAQABAoAAA==.',['�']='云飘飘:AwAHCAgABAoAAA==.亡零杰克:AwADCAMABAoAAA==.',['�']='今夜明珠色:AwADCAMABAoAAA==.',['�']='低调的哀伤:AwACCAMABAoAAA==.',['�']='依然不听你的:AwAICAgABAoAAA==.',['�']='全村你最棒:AwAGCAYABAoAAA==.其实我也难过:AwAICAgABAoAAA==.',['�']='再打我报警:AwADCAcABRQCAwADAQgkDQAuA+0ABRQAAwADAQgkDQAuA+0ABRQAAA==.',['�']='凯瑟斯玲娜:AwAICAgABAoAAA==.',['�']='切位离丶:AwACCAIABAoAAA==.',['�']='勇敢的战神:AwAGCAYABAoAAA==.',['�']='北方冬至:AwAICAgABAoAAA==.',['�']='叫发丝的萨满:AwABCAEABAoAAA==.',['�']='吃鱼割女腰子:AwAICBIABAoAAA==.',['�']='周贱贱同学:AwAICBAABAoAAA==.',['�']='咕噜噜王子:AwAGCBYABAoCAgAGAQiDLQBWGuQBBAoAAgAGAQiDLQBWGuQBBAoAAA==.',['�']='唯一的女神:AwAECAQABAoAAA==.',['�']='喔汣醬:AwAECAEABRQAAA==.',['�']='坠落之心:AwACCAIABAoAAA==.',['�']='墓中无人:AwABCAEABRQAAA==.',['�']='士非闇:AwAGCAYABAoAAA==.壮丶风暴烈酒:AwAICAgABAoAAA==.',['�']='大淇淇:AwAGCAYABAoAAA==.大白无糖:AwAECAQABRQAAA==.天行:AwAICAoABAoAAA==.',['�']='如丶如:AwAFCAcABAoAAA==.妮屁屁:AwAICAgABAoAAA==.',['�']='婲星雨:AwAICBQABAoDCAAIAQioHQBAGHwBBAoACAAIAQioHQA0rnwBBAoAAwAFAQggUwBOyEEBBAoAAA==.',['�']='宠物比我高:AwAICBsABAoDCQAIAQjMDwBS7TICBAoACQAIAQjMDwBS7TICBAoACgACAQj5xAA164AABAoAAA==.',['�']='小哔凯:AwAFCAUABAoAAA==.小时候救过人:AwAICBgABAoDCgAIAQijOwA7o+sBBAoACgAIAQijOwA5iOsBBAoACQAGAQi+JgA+NXYBBAoAAA==.小明丶:AwAECAQABRQAAA==.小母牛倒立:AwAGCAYABAoAAA==.小蛇头:AwABCAEABAoAAA==.尛孟起:AwADCAkABRQDCgADAQjdHwBFi7IABRQACgACAQjdHwA/B7IABRQACQABAQjNGABSkVwABRQAAA==.就瞅你了:AwAGCAYABAoAAA==.',['�']='帕拉丁丁:AwAGCAYABAoAAA==.',['�']='庞然小捅:AwADCAMABAoAAA==.',['�']='弹指灬红颜老:AwAGCAQABRQAAA==.',['�']='我是小熊:AwACCAIABRQCCwAIAQgeHQBFDwACBAoACwAIAQgeHQBFDwACBAoAAA==.戒徒:AwAICAgABAoAAA==.战意无双:AwAGCAcABAoAAA==.',['�']='持剑者:AwAECAIABRQCDAAIAQjvFwBMaGICBAoADAAIAQjvFwBMaGICBAoAAA==.',['�']='掷点王:AwAICAUABAoAAA==.',['�']='无糖小雪碧:AwAECAQABRQAAA==.',['�']='晓手哇凉:AwABCAEABAoAAA==.',['�']='暗黑虎:AwABCAEABRQAAA==.',['�']='曼丽丶:AwABCAEABAoAAA==.',['�']='未晞丶:AwAECAwABRQCDQAEAQgbBgBVlyQBBRQADQAEAQgbBgBVlyQBBRQAAA==.',['�']='残暴的太阳哥:AwAECAQABAoAAA==.',['�']='毕竟大帅比啊:AwAFCAUABAoAAA==.',['�']='求你马老公抱:AwAICAgABAoAAA==.',['�']='没睡醒的猫:AwABCAEABAoAAA==.沧素:AwABCAEABRQAAA==.',['�']='法爷:AwACCAEABRQAAA==.泯灭使者:AwACCAIABRQAAA==.',['�']='浊谷山人主:AwAICAgABAoAAA==.',['�']='淡淡幽香:AwAECAIABRQAAA==.',['�']='清月晚星:AwAGCAwABAoAAA==.温不胜王有胜:AwADCAMABAoAAA==.',['�']='澳斯尔:AwAFCAUABAoAAA==.',['�']='火花闪电:AwABCAMABRQAAA==.灬无幽:AwADCAMABAoAAA==.灬末路:AwABCAEABRQAAA==.灵感:AwAGCBcABAoDDgAGAQg1GgA6UFQBBAoADgAGAQg1GgAwt1QBBAoADwAFAQi7JAAtAQ8BBAoAAA==.灵敏的鲨鱼:AwAICAoABAoAAA==.',['�']='爱甜甜的小哈:AwACCAIABAoAAA==.',['�']='狒狒的逆袭:AwAHCA4ABAoAAA==.',['�']='环杉:AwAICAgABAoAAA==.',['�']='电了个电:AwAECAQABRQAAA==.男演员:AwAECAQABAoAAA==.',['�']='疯狂小防骑:AwAFCAUABAoAAA==.疯狂的石头:AwAICAUABAoAAA==.',['�']='白雪大人:AwAGCAIABRQAAA==.',['�']='皇后殺手:AwAECAYABRQCDAAEAQhIEQAy9OoABRQADAAEAQhIEQAy9OoABRQAAA==.',['�']='看书去呗:AwAHCAcABAoAAA==.看来经济:AwAICA8ABAoAAA==.',['�']='瞎子很风骚:AwACCAcABRQCEAACAQggDQAm7XwABRQAEAACAQggDQAm7XwABRQAAA==.',['�']='短腿基:AwACCAQABRQAAA==.矮大壮:AwAICBoABAoDCQAIAQj+EwBC+QgCBAoACQAIAQj+EwBC+QgCBAoACgABAQhJ+AARySYABAoAAA==.',['�']='碧落紅尘:AwABCAMABRQAAA==.',['�']='社区暴富王胖:AwABCAEABAoAAA==.',['�']='祖师爷上身:AwAECAIABAoAAA==.',['�']='章大宝:AwAICBIABAoAAA==.',['�']='红心番石榴:AwAICBYABAoDAwAIAQiIBABfkvACBAoAAwAIAQiIBABfkvACBAoACAAGAQi6OAAkaMAABAoAAA==.红星照耀:AwABCAEABAoAAA==.红运郎:AwAECAcABRQCEQAEAQhrDwBIjQkBBRQAEQAEAQhrDwBIjQkBBRQAAA==.红门乖乖:AwAGCBAABAoAAA==.纵火狂丶焰:AwAFCAUABAoAAA==.',['�']='羊角挺秀气:AwAICAsABAoAAA==.美丽的大牙:AwAICBAABAoAAA==.美洋洋丶情殇:AwABCAEABAoAAA==.',['�']='聆听我的声音:AwACCAIABAoAAA==.聖丶瓦里安:AwABCAEABAoAAA==.聖丶莫格莱尼:AwAECAQABAoAAA==.',['�']='臭烂碎鸡者:AwAGCAYABAoAAA==.',['�']='芸飞扬:AwADCAUABAoAAA==.',['�']='苦丁花茶:AwABCAEABRQAAA==.',['�']='莉蒂娅:AwACCAIABAoAAA==.莫青青:AwACCAIABAoAAA==.',['�']='菠萝小小熊:AwAICAgABAoAAA==.',['�']='萨你还不了手:AwACCAIABRQAAA==.',['�']='表幻想:AwAGCAQABRQAAA==.',['�']='要樂奈:AwAECAQABRQAAA==.',['�']='诸因解体:AwADCAwABRQCEgADAQgGAgBh5lMBBRQAEgADAQgGAgBh5lMBBRQAAA==.',['�']='超級賽亚人:AwAICAgABAoAAA==.',['�']='跳起来打:AwAICAMABAoAAA==.',['�']='达布:AwABCAEABRQAAQcAQ8QICAcABRQ=.',['�']='迷途不归路:AwABCAEABRQAAA==.追风:AwACCAQABAoAAA==.',['�']='酱椒鱼头:AwAICAIABAoAAA==.',['�']='钟山丽影:AwACCAIABAoAAA==.',['�']='阿古西阁下:AwAFCAkABAoAAA==.',['�']='陨落之星:AwAGCAoABAoAAA==.',['�']='震离星姬:AwACCAIABRQAAA==.',['�']='青花郎:AwAGCA4ABRQDCwAGAQgiBAAm1woBBRQACwAFAQgiBAAUGwoBBRQABwAEAQi2EwA9ZfAABRQAAA==.静静蔓延:AwAFCAUABAoAAA==.',['�']='飘玲丶:AwAGCAYABAoAAA==.飞跃苏联:AwABCAQABRQCEwAIAQhvAgBe0usCBAoAEwAIAQhvAgBe0usCBAoAAQYAAAACCAIABRQ=.',['�']='骑士道:AwAGCAcABAoAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end