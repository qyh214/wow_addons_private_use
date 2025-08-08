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
 local lookup = {'Shaman-Enhancement','Warrior-Protection','Rogue-Melee','Rogue-Assassination','Shaman-Restoration','Evoker-Devastation','Evoker-Preservation','Hunter-Marksmanship','DeathKnight-Frost','Druid-Balance','Druid-Restoration','DeathKnight-Unholy','DeathKnight-Blood','Rogue-Subtlety','Warlock-Destruction','Warlock-Demonology','Priest-Shadow','Hunter-BeastMastery','Paladin-Protection','Paladin-Retribution','Unknown-Unknown','Warrior-Arms','Warrior-Fury','Mage-Arcane','Mage-Fire','Mage-Frost','Monk-Mistweaver','Priest-Holy','Warlock-Affliction',}; local provider = {region='CN',realm='日落沼泽',name='CN',type='weekly',zone=42,date='2025-08-08',data={Aa='Aao:BAAAKgAECgQICQAAAA==.Aaron:BAAAKgAECggICwAAAA==.',Az='Azazelrs:BAAAKgAECgMIAwAAAA==.',Bi='Bishop:BAACKgAFFH8KAAIBAAMIoBjFCAAJAQABAAMIoBjFCAAJAQAqAAQKfxoAAgEACAgGHLsQAE4CAAEACAgGHLsQAE4CAAAA.',Bl='Bloodymonday:BAACKgAFFH8tAAICAAgIbyJjAQA7AgACAAgIbyJjAQA7AgAqAAQKfxwAAgIACAgVJeMCAMQCAAIACAgVJeMCAMQCAAAA.',Da='Dammitita:BAAAKgAECgQIBwAAAA==.Darkeye:BAAAKgADCggIHAAAAA==.Darkne:BAAAKgADCgYIBgAAAA==.',Ha='Haroin:BAAAKgAFFAgIBAAAAA==.',Hn='Hnhunter:BAAAKgAECgMIAwAAAA==.',La='Lapenséede:BAAAKgADCgEIAQAAAA==.',Me='Metalica:BAAAKgAECgYIBgAAAA==.',Pa='Pandaa:BAAAKgADCgEIAQAAAA==.',St='Stories:BAAAKgADCgYIBgAAAA==.',Ul='Ulquiorra:BAAAKgADCggIDAAAAA==.',Xu='Xu:BAABKgAECn8LAAIDAAgIVgAAAAAAAAAEAAgIVgAAAAAAAAAAAA==.',Zh='Zhan:BAAAKgAECgIIAwAAAA==.',['一点']='一点浩然气:BAAAKgADCgYIBgAAAA==.',['一百']='一百个萨满:BAABKgAFFH8GAAIFAAYItAQrGwASAQAFAAYItAQrGwASAQAAAA==.',['七星']='七星龙渊:BAACKgAFFH9CAAMGAAgIuRmrCQDaAQAGAAgIuRmrCQDaAQAHAAIIigm+CQBUAAAqAAQKfywAAwYACAjSGggeAMkBAAYABwjSGggeAMkBAAcABggHCvMVAPcAAAAA.',['三队']='三队的猎手:BAABKgAECn8UAAIIAAgIthanIgDCAQAIAAgIthanIgDCAQAAAA==.',['下个']='下个行程:BAAAKgADCgcIBwAAAA==.',['两周']='两周岁的淏淏:BAAAKgAECgMIAwAAAA==.',['乖巧']='乖巧:BAABKgAFFH8GAAIFAAMIEyGDGwAQAQAFAAMIEyGDGwAQAQAAAA==.',['九周']='九周岁熊孩子:BAAAKgAECggIDwAAAA==.',['九转']='九转大肠:BAAAKgAECgQIBAAAAA==.',['亦非']='亦非:BAAAKgADCgQIBAAAAA==.',['产奶']='产奶的蜗牛:BAAAKgADCgEIAQAAAA==.',['仲夏']='仲夏夜之蜜:BAAAKgADCgEIAQAAAA==.',['伴您']='伴您成长:BAAAKgAFFAYIBAAAAA==.',['似水']='似水流年:BAAAKgAECgIIAgAAAA==.',['你个']='你个灾舅子:BAAAKgAECggIBQAAAA==.',['你飘']='你飘了:BAAAKgADCggICAAAAA==.',['冷無']='冷無情:BAABKgAECn8XAAIJAAgI/x9uBQCBAgAJAAgI/x9uBQCBAgAAAA==.',['初心']='初心依旧:BAAAKgAFFAEIAQAAAA==.',['十三']='十三:BAAAKgAECggIEwAAAA==.十三僧僧:BAAAKgAECggIDwAAAA==.十三声:BAAAKgAFFAMIAwAAAA==.十三黑骑:BAAAKgAECggICAAAAA==.',['卡农']='卡农变奏:BAAAKgAECgcIBwAAAA==.',['卩丶']='卩丶聖光灬誠:BAABKgAECn8YAAMKAAgI3Ra5XgBFAQAKAAcI6xm5XgBFAQALAAUIbxAVVQC5AAAAAA==.',['只会']='只会开无敌:BAAAKgAFFAIIAgAAAA==.',['只是']='只是从前烟雨:BAAAKgAECggICAAAAA==.',['叫我']='叫我小哪吒:BAABKgAFFH8GAAIMAAYIexyyDQC4AQAMAAYIexyyDQC4AQABKgAFFAgIBgANAAgaAA==.叫我小玉面:BAAAKgADCgMIBgAAAA==.叫我沙师弟:BAAAKgAECgYIBgAAAA==.',['右亦']='右亦香:BAACKgAFFH8gAAMOAAQIKx8DAwAAAQAOAAQIKx8DAwAAAQAEAAEI9xVoKABMAAAqAAQKf04AAw4ACAhXIzsBALACAA4ACAhXIzsBALACAAQABwjjGGMhAFMBAAAA.',['名字']='名字真不好起:BAABKgAFFH8GAAMPAAYIdAzyIwDpAAAPAAQIQAvyIwDpAAAQAAIIRBF7KwBDAAABKgAFFAgIEQARALAcAA==.',['哀濡']='哀濡潮水:BAAAKgADCgQIBAAAAA==.',['哈喽']='哈喽恶魔:BAAAKgADCgYIBgAAAA==.',['哥布']='哥布林男模:BAAAKgAECgMIAwAAAA==.',['喀秋']='喀秋莎:BAAAKgADCgMIAwAAAA==.',['四季']='四季豆:BAAAKgAFFAQIBAAAAA==.',['因为']='因为寂寞:BAAAKgADCggICAAAAA==.',['团长']='团长:BAAAKgADCgYIBgAAAA==.',['困兽']='困兽之伊利:BAAAKgAECggICAAAAA==.困兽之希瓦:BAAAKgAECgEIAQAAAA==.困兽之德:BAAAKgADCgIIAgAAAA==.困兽之猎头:BAAAKgAECggIDwAAAA==.困兽之萨:BAAAKgAECgEIAQAAAA==.困兽之骑士:BAAAKgAECgEIAQAAAA==.',['圣光']='圣光之魂:BAAAKgADCgIIAgAAAA==.',['堕落']='堕落天城:BAAAKgAECggICAABKgAFFAgICAASAHMNAA==.堕落灰烬使者:BAAAKgADCgMIAwAAAA==.',['塔罗']='塔罗科鲜橙多:BAAAKgAECgcIBwAAAA==.',['墨夭']='墨夭桃:BAAAKgAECggICAAAAA==.',['墮落']='墮落的車馬炮:BAAAKgADCgEIAQAAAA==.',['壹丶']='壹丶壹:BAABKgAFFH8IAAITAAgIyBEUBgDJAQATAAgIyBEUBgDJAQAAAA==.',['夏花']='夏花灿烂:BAABKgAFFH8GAAIUAAYIzxsHGwCKAQAUAAYIzxsHGwCKAQAAAA==.',['夜夜']='夜夜耶:BAAAKgAECggICAAAAA==.',['大漂']='大漂亮:BAAAKgAECggICAAAAA==.',['大肌']='大肌腿:BAAAKgADCggICAAAAA==.',['头上']='头上有犄角丶:BAAAKgAECgEIAQAAAA==.',['威猛']='威猛牛铁头:BAAAKgADCgEIAQAAAA==.',['孤烟']='孤烟大漠:BAAAKgADCggIDQAAAA==.',['学习']='学习外语:BAAAKgAECgUIBQAAAA==.',['小妖']='小妖妖灬:BAAAKgAFFAYIAgAAAA==.',['小松']='小松许:BAAAKgAECgYIBgAAAA==.',['小欧']='小欧同学丶:BAAAKgAFFAQIAQABKgAFFAgICAAEAFwTAA==.',['小泽']='小泽丶玛莉桑:BAAAKgAECgQIBwAAAA==.',['小莫']='小莫老师:BAAAKgADCgEIAQAAAA==.',['小迷']='小迷糊芳:BAAAKgADCgUIBQAAAA==.',['小黄']='小黄丶:BAAAKgAECggICAAAAA==.',['小黑']='小黑牛贼帅丶:BAAAKgADCggICAAAAA==.',['尐裤']='尐裤叉:BAAAKgADCgMIAwAAAA==.',['岑碧']='岑碧青:BAAAKgAECgEIAQAAAA==.',['崔希']='崔希丝:BAABKgAFFH8FAAISAAMIywsNIADYAAASAAMIywsNIADYAAABKgAFFAgIBAAVAAAAAA==.',['希希']='希希酱紫:BAAAKgAECgYIBgAAAA==.',['带你']='带你飞:BAAAKgADCgQIBAAAAA==.',['幻翎']='幻翎:BAABKgAFFH8LAAIIAAMIahOwKwC8AAAIAAMIahOwKwC8AAAAAA==.',['废废']='废废的阿奔:BAAAKgAECgYIBgAAAA==.',['德不']='德不得:BAAAKgADCggICAAAAA==.',['忆流']='忆流年:BAAAKgAECgYICgAAAA==.',['情缘']='情缘丘比特:BAAAKgAECgYIBAAAAA==.',['成年']='成年雄性:BAABKgAFFH8MAAILAAQI+iFbCAAbAQALAAQI+iFbCAAbAQABKgAFFAgICAAQAEojAA==.',['戒丨']='戒丨色:BAAAKgAECgcIBwAAAA==.',['拿铁']='拿铁:BAACKgAFFH8GAAIWAAMIWgveGQC8AAAWAAMIWgveGQC8AAAqAAQKfx4AAxYACAjSGUISACYCABYACAjSGUISACYCABcAAQgAABKfAAAAAAAA.',['搓翻']='搓翻你:BAAAKgADCgQIBQAAAA==.',['断罪']='断罪者:BAAAKgAECggIDwAAAA==.',['施巴']='施巴拉古:BAAAKgAECggIEQAAAA==.',['无情']='无情葬月:BAAAKgAECgIIAgAAAA==.',['暗影']='暗影猫:BAAAKgAFFAMIBAAAAA==.',['暗血']='暗血微光:BAABKgAFFH8MAAISAAQITBSsGwDmAAASAAQITBSsGwDmAAAAAA==.',['暴暴']='暴暴:BAAAKgAECgMIAwAAAA==.',['暴躁']='暴躁的史瑞克:BAABKgAECn8UAAIMAAcI5RTuSABOAQAMAAcI5RTuSABOAQAAAA==.',['曓虐']='曓虐:BAAAKgAECgcIBwAAAA==.',['木兰']='木兰:BAAAKgADCggICAAAAA==.',['木吉']='木吉他的悲鸣:BAAAKgAFFAEIAQAAAA==.',['朱厌']='朱厌:BAAAKgAECgEIAQAAAA==.',['朱庇']='朱庇特:BAABKgAFFH8LAAIWAAgIVRWnBADGAQAWAAgIVRWnBADGAQAAAA==.',['杰森']='杰森赫沃斯:BAAAKgAECgEIAQAAAA==.',['松千']='松千绪花:BAACKgAFFH8iAAQYAAYIQSHTCQDSAQAYAAYIth/TCQDSAQAZAAUI0RvFDABrAQAaAAMI+RNrCQDiAAAqAAQKfxYAAxkACAgLG60xANUBABkACAjJGa0xANUBABgAAQiLJW59AG0AAAAA.',['松阡']='松阡绪花:BAABKgAFFH8OAAIbAAYI2RJPDQBQAQAbAAYI2RJPDQBQAQABKgAFFAgIBgAbABUEAA==.',['枫丶']='枫丶泷:BAAAKgAECggICAAAAA==.',['橘子']='橘子糖:BAAAKgAECgcICAAAAA==.',['毁灭']='毁灭女神:BAAAKgADCgEIAQAAAA==.',['永信']='永信亦凡人:BAAAKgADCgQIBAAAAA==.',['汪身']='汪身后有尾巴:BAAAKgAECgYICgAAAA==.',['沐丶']='沐丶言:BAABKgAFFH8GAAMcAAYIxw4kCgDjAAAcAAUIWBIkCgDjAAARAAEICQrQLABBAAAAAA==.',['油猫']='油猫饼:BAAAKgAECgYICwAAAA==.',['波奇']='波奇龙虾:BAAAKgAECgQIBAAAAA==.',['波波']='波波爱:BAAAKgAFFAQIBAAAAA==.',['洒满']='洒满阳光:BAAAKgADCgUIBQAAAA==.',['混断']='混断木桥:BAAAKgAECgYIBgAAAA==.',['灬不']='灬不缺牧:BAAAKgAECggIDAABKgAFFAgIEwATAA0TAA==.',['灵月']='灵月仙子:BAAAKgAECgEIAQAAAA==.',['热血']='热血战神:BAAAKgADCgIIAgAAAA==.',['燃烧']='燃烧的胸毛:BAAAKgAECggIEQAAAA==.',['牙签']='牙签骑士:BAAAKgAFFAYIBAAAAA==.',['牧尸']='牧尸:BAAAKgAECgYICAAAAA==.',['特囵']='特囵苏:BAABKgAFFH8IAAIFAAYInRjGEwDWAAAFAAYInRjGEwDWAAAAAA==.',['白雾']='白雾红尘:BAAAKgAECgYICwABKgAFFAYIBgAEAJ0VAA==.',['百濕']='百濕不得骑姊:BAAAKgAECgEIAQAAAA==.',['看你']='看你妹:BAAAKgADCgEIAQAAAA==.',['矛盾']='矛盾属实:BAAAKgADCggIGQAAAA==.',['禽家']='禽家兽:BAABKgAECn8aAAMXAAgIgguHTwAiAQAXAAgICQuHTwAiAQACAAIIng4LQQBWAAAAAA==.',['穿衣']='穿衣显瘦:BAABKgAFFH8SAAMUAAYIWx2HCwAnAQAUAAQInCOHCwAnAQATAAYIBRSkBgD6AAABKgAFFAgIEwATAA0TAA==.',['章台']='章台柳:BAAAKgAECgcIBgAAAA==.',['等得']='等得太久:BAAAKgAECgUIBQAAAA==.',['筱苹']='筱苹果:BAAAKgADCgQIBAAAAA==.',['糖门']='糖门:BAAAKgAECgcICgAAAA==.',['紫月']='紫月流光:BAAAKgAECgQIBgAAAA==.',['紫色']='紫色特长生:BAAAKgADCggICAAAAA==.',['緋聞']='緋聞少女:BAAAKgADCggICAAAAA==.',['繁华']='繁华末日:BAAAKgAECgQIBAAAAA==.',['红莲']='红莲乱舞:BAAAKgADCgEIAQAAAA==.红莲怒斩:BAABKgAECn8ZAAMUAAgIohDJhQBCAQAUAAgIOw/JhQBCAQATAAQIJRATPgCLAAAAAA==.',['纯情']='纯情老鼠人:BAABKgAFFH8GAAILAAYI1gO9FgDqAAALAAYI1gO9FgDqAAAAAA==.',['美丽']='美丽的大牙:BAAAKgAECgUIBQAAAA==.',['羽衣']='羽衣常帶煙霞:BAAAKgAECggICAAAAA==.',['翠花']='翠花俺家牛呢:BAAAKgAECgYIBgAAAA==.',['老司']='老司机:BAAAKgAECggIDgAAAA==.',['背后']='背后来一下:BAAAKgAECgMIAwAAAA==.',['自由']='自由的风:BAAAKgADCgUIBQAAAA==.',['英雄']='英雄慢走:BAAAKgADCgcIBwAAAA==.',['莫丶']='莫丶挨:BAABKgAFFH8OAAMPAAYIvCSRAAAcAgAPAAYIvCSRAAAcAgAQAAEIAAA1IwAAAAABKgAFFAgIBAAVAAAAAA==.',['莫老']='莫老师:BAAAKgADCgEIAQAAAA==.',['菜鸡']='菜鸡德请组我:BAAAKgAECgEIAQAAAA==.',['萧炎']='萧炎:BAABKgAECn8WAAIUAAgIrRMfqgBDAQAUAAgIrRMfqgBDAQAAAA==.',['萨尼']='萨尼泰特:BAABKgAFFH8PAAMKAAYIhx5REQCUAQAKAAYIhx5REQCUAQALAAYIJA8nEQAWAQAAAA==.',['葱油']='葱油饼干:BAAAKgADCggICAAAAA==.',['蒂法']='蒂法:BAAAKgADCggIDwAAAA==.',['蛮子']='蛮子:BAAAKgADCgEIAQAAAA==.',['西格']='西格玛男人:BAAAKgAECgYIBgAAAA==.',['詩酒']='詩酒趁年華:BAAAKgADCggIDAAAAA==.',['赛尔']='赛尔菲:BAAAKgADCggICAAAAA==.',['踢零']='踢零村花:BAABKgAFFH8IAAIFAAgINwZhCwCRAQAFAAgINwZhCwCRAQAAAA==.',['转就']='转就完事了:BAAAKgAECggICAAAAA==.',['追梦']='追梦的大叔:BAAAKgAFFAMIBAAAAA==.',['逐风']='逐风者圣光:BAAAKgAECgQIBAAAAA==.',['邓超']='邓超:BAAAKgAECgQIBwAAAA==.',['邪鬼']='邪鬼皇族公主:BAABKgAECn8fAAMQAAgIahiCOQAPAQAQAAUIlReCOQAPAQAdAAQIhRnNIADTAAAAAA==.',['重型']='重型坦克车:BAAAKgAFFAEIAQAAAA==.',['鐡枫']='鐡枫丶:BAAAKgAECgEIAQAAAA==.',['鑫骑']='鑫骑:BAAAKgADCgMIAwAAAA==.',['铁衣']='铁衣丶:BAAAKgAECgQIBAAAAA==.',['阿珂']='阿珂萌德:BAAAKgAFFAgIBAAAAA==.',['陕西']='陕西凉皮:BAAAKgAECgYIBwAAAA==.',['雷霆']='雷霆猛战:BAAAKgADCgYIBgAAAA==.',['霜殇']='霜殇灬:BAAAKgADCgcIBwAAAA==.',['霰雪']='霰雪纷飞:BAAAKgAECgcIDgAAAA==.',['顷雲']='顷雲:BAAAKgAECggICQAAAA==.',['風舞']='風舞丶云若依:BAABKgAFFH8GAAISAAYI9w57FwA9AQASAAYI9w57FwA9AQAAAA==.',['风其']='风其如雪:BAAAKgAECgIIAgAAAA==.',['风暴']='风暴与雷鸣:BAABKgAECn8bAAIFAAgIDBxJFACcAQAFAAgIDBxJFACcAQAAAA==.',['风波']='风波一啵啵:BAAAKgAECgEIAQAAAA==.',['飛老']='飛老师:BAAAKgAECgYIBgAAAA==.',['飞翔']='飞翔的鱼:BAABKgAFFH8GAAIdAAYIZxJEAwBkAQAdAAYIZxJEAwBkAQAAAA==.',['饕丶']='饕丶餮:BAABKgAFFH8IAAISAAQIig0AHAC5AAASAAQIig0AHAC5AAAAAA==.',['马瑞']='马瑞欧:BAAAKgAECgEIAQAAAA==.',['魅影']='魅影玲珑:BAAAKgAECgIIAgAAAA==.',['魇魔']='魇魔怒猎者:BAABKgAFFH8QAAMSAAgIxRSnCADsAQASAAgIxRSnCADsAQAIAAQIFRK2DwDbAAAAAA==.',['魔兽']='魔兽可太欧啦:BAAAKgADCggIEAAAAA==.魔兽好凉茶:BAAAKgAECgMIAwAAAA==.',['鲁帕']='鲁帕克:BAABKgAECn8iAAISAAgI0xAbSwB+AQASAAgI0xAbSwB+AQAAAA==.',['黄金']='黄金假面人:BAAAKgAFFAQIBAAAAA==.',['龙弦']='龙弦:BAABKgAFFH8MAAMYAAMI2xo2IgDcAAAYAAMI2xo2IgDcAAAZAAEIEhUMLwBEAAAAAA==.',},}; provider.parse = parse;if ArchonTooltip.AddProviderV2 then ArchonTooltip.AddProviderV2(lookup, provider) end