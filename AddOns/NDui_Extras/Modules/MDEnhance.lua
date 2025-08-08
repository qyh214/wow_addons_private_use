local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:GetModule("Extras")

local MapList = {
	-- 大地的裂变
	[438] = {410080}, -- 旋云之巅
	[456] = {424142}, -- 潮汐王座
	[507] = {445424}, -- 格瑞姆巴托

	-- 熊猫人之谜
	[  2] = {131204}, -- 青龙寺
	[ 56] = {131205}, -- 风暴烈酒酿造厂
	[ 57] = {131225}, -- 残阳关
	[ 58] = {131206}, -- 影踪禅院
	[ 59] = {131228}, -- 围攻砮皂寺
	[ 60] = {131222}, -- 魔古山宫殿
	[ 76] = {131232}, -- 通灵学院
	[ 77] = {131231}, -- 血色大厅
	[ 78] = {131229}, -- 血色修道院

	-- 德拉诺之王
	[161] = {159898}, -- 通天峰
	[163] = {159895}, -- 血槌炉渣矿井
	[164] = {159897}, -- 奥金顿
	[165] = {159899}, -- 影月墓地
	[166] = {159900}, -- 恐轨车站
	[167] = {159902}, -- 黑石塔上层
	[168] = {159901}, -- 永茂林地
	[169] = {159896}, -- 钢铁码头

	-- 军团再临
	[197] = {}, -- 艾萨拉之眼
	[198] = {424163}, -- 黑心林地
	[199] = {424153}, -- 黑鸦堡垒
	[200] = {393764}, -- 英灵殿
	[206] = {410078}, -- 奈萨里奥的巢穴
	[207] = {}, -- 守望者地窟
	[208] = {}, -- 噬魂之喉
	[209] = {}, -- 魔法回廊
	[210] = {393766}, -- 群星庭院
	[227] = {373262}, -- 重返卡拉赞（下层）
	[233] = {}, -- 永夜大教堂
	[234] = {373262}, -- 重返卡拉赞（上层）
	[239] = {}, -- 执政团之座

	-- 争霸艾泽拉斯
	[244] = {424187}, -- 阿塔达萨
	[245] = {410071}, -- 自由镇
	[246] = {}, -- 托尔达戈
	[247] = {467553, 467555}, -- 暴富矿区
	[248] = {424167}, -- 维克雷斯庄园
	[249] = {}, -- 诸王之眠
	[250] = {}, -- 塞塔里斯神庙
	[251] = {410074}, -- 地渊孢林
	[252] = {}, -- 风暴神殿
	[353] = {445418, 464256}, -- 围攻伯拉勒斯
	[369] = {373274}, -- 麦卡贡行动 - 垃圾场
	[370] = {373274}, -- 麦卡贡行动 - 车间

	-- 暗影国度
	[375] = {354464}, -- 塞兹仙林的迷雾
	[376] = {354462}, -- 通灵战潮
	[377] = {354468}, -- 彼界
	[378] = {354465}, -- 赎罪大厅
	[379] = {354463}, -- 凋魂之殇
	[380] = {354469}, -- 赤红深渊
	[381] = {354466}, -- 晋升高塔
	[382] = {354467}, -- 伤逝剧场
	[391] = {367416}, -- 塔扎维什：琳彩天街
	[392] = {367416}, -- 塔扎维什：索·莉亚的宏图

	-- 巨龙时代
	[399] = {393256}, -- 红玉新生法池
	[400] = {393262}, -- 诺库德阻击战
	[401] = {393279}, -- 碧蓝魔馆
	[402] = {393273}, -- 艾杰斯亚学院
	[403] = {393222}, -- 奥达曼：提尔的遗产
	[404] = {393276}, -- 奈萨鲁斯
	[405] = {393267}, -- 蕨皮山谷
	[406] = {393283}, -- 注能大厅
	[463] = {424197}, -- 永恒黎明：迦拉克隆的陨落
	[464] = {424197}, -- 永恒黎明：姆诺兹多的崛起

	-- 地心之战
	[499] = {445444}, -- 圣焰隐修院
	[500] = {445443}, -- 驭雷栖巢
	[501] = {445269}, -- 矶石宝库
	[502] = {445416}, -- 千丝之城
	[503] = {445417}, -- 艾拉-卡拉，回响之城
	[504] = {445441}, -- 暗焰裂口
	[505] = {445414}, -- 破晨号
	[506] = {445440}, -- 燧酿酒庄
	[525] = {1216786}, -- 水闸行动
}

local SpellList = {}
function EX:MDEnhance_UpdateList()
	for mapID, spellIDs in pairs(MapList) do
		local spellID = self:MDEnhance_SelectSpellID(spellIDs)
		if spellID then SpellList[spellID] = mapID end
	end
end

function EX:MDEnhance_SelectSpellID(spellIDs)
	if #spellIDs > 1 then
		for _, spellID in pairs(spellIDs) do
			if IsSpellKnown(spellID) then
				return spellID
			end
		end
	end

	return spellIDs[1]
end

function EX:TButton_OnEnter(parent, spellID)
	local dungeonIcon = parent:GetParent()
	if not dungeonIcon then return end

	local dungeonIcon_OnEnter = dungeonIcon:GetScript("OnEnter")
	if dungeonIcon_OnEnter then dungeonIcon_OnEnter(dungeonIcon) end

	local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(dungeonIcon.mapID)
	GameTooltip:AddLine(L["+2timeLimit"]..SecondsToClock(timeLimit*.8), 1, 1, 0)
	GameTooltip:AddLine(L["+3timeLimit"]..SecondsToClock(timeLimit*.6), 0, 1, 0)
	GameTooltip:AddLine(" ")

	if spellID then
		local name = C_Spell.GetSpellName(spellID)
		local CDInfo = C_Spell.GetSpellCooldown(spellID)

		if IsSpellKnown(spellID) and CDInfo then
			if CDInfo.duration == 0 then
				GameTooltip:AddLine(name, 0, 1, 0)
			else
				GameTooltip:AddLine(name, 1, 1, 0)
			end
		else
			GameTooltip:AddLine(name, 1, 0, 0)
		end
	else
		GameTooltip:AddLine(SPELL_FAILED_NOT_KNOWN, 1, 0, 0)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["MapID"]..dungeonIcon.mapID, 1, 1, 1)

	GameTooltip:Show()
end

function EX:TButton_OnLeave(parent)
	GameTooltip:Hide()
end

function EX:MDEnhance_UpdateEnhance(parent, spellIDs)
	if not parent then return end
	parent.BScore:SetText("")

	local spellID = self:MDEnhance_SelectSpellID(spellIDs)
	parent.TButton:SetAttribute("type", "spell")
	parent.TButton:SetAttribute("spell", spellID)
	parent.TButton:SetScript("OnEnter", function(parent) EX:TButton_OnEnter(parent, spellID) end)
	parent.TButton:SetScript("OnLeave", function(parent) EX:TButton_OnLeave(parent) end)

	local affixScores, bestScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(parent.mapID)
	if not affixScores or not bestScore then return end

	local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(bestScore) or HIGHLIGHT_FONT_COLOR
	parent.BScore:SetText(bestScore and bestScore or "")
	parent.BScore:SetTextColor(color.r, color.g, color.b)

--[[
	parent.FScore:SetText(affixScores[1] and affixScores[1].score or "")
	parent.FScore:SetTextColor(1, 1, 0)

	parent.TScore:SetText(affixScores[2] and affixScores[2].score or "")
	parent.TScore:SetTextColor(0, 1, 1)
]]
end

function EX:MDEnhance_CreateEnhance(parent)
	if not parent then return end

	local TButton = CreateFrame("Button", nil, parent, "InsecureActionButtonTemplate")
	TButton:SetAllPoints(parent)
	TButton:RegisterForClicks("AnyDown")

	parent.TButton = TButton
	parent.BScore = B.CreateFS(parent, 18, "", false, "BOTTOM", 0, 0)
	--parent.FScore = B.CreateFS(parent, 16, "", false, "BOTTOMLEFT", 0, 0)
	--parent.TScore = B.CreateFS(parent, 16, "", false, "BOTTOMRIGHT", 0, 0)
end

function EX.MDEnhance_OnCreate()
	if InCombatLockdown() or not ChallengesFrame or not ChallengesFrame.DungeonIcons then return end

	for _, dungeonIcon in pairs(ChallengesFrame.DungeonIcons) do
		if not dungeonIcon.TButton then
			EX:MDEnhance_CreateEnhance(dungeonIcon)
		end
		EX:MDEnhance_UpdateEnhance(dungeonIcon, MapList[dungeonIcon.mapID])
	end
end

function EX.MDEnhance_OnEvent(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		hooksecurefunc(ChallengesFrame, "Update", EX.MDEnhance_OnCreate)
		B:UnregisterEvent(event, EX.MDEnhance_OnEvent)
	end
end

function EX:MDEnhance_Notification(unit, casterID, spellID)
	if unit == "player" and SpellList[spellID] then
		SendChatMessage(format(L["CastAlertInfo"], UnitName("player"), C_Spell.GetSpellLink(spellID) or C_Spell.GetSpellName(spellID), C_ChallengeMode.GetMapUIInfo(SpellList[spellID])), B.GetMSGChannel())
	end
end

function EX:MDEnhance_CheckGroup()
	if IsInGroup() then
		B:RegisterEvent("UNIT_SPELLCAST_START", EX.MDEnhance_Notification)
	else
		B:UnregisterEvent("UNIT_SPELLCAST_START", EX.MDEnhance_Notification)
	end
end

function EX:MDEnhance()
	EX:MDEnhance_UpdateList()
	B:RegisterEvent("ADDON_LOADED", EX.MDEnhance_OnEvent)

	EX:MDEnhance_CheckGroup()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", EX.MDEnhance_CheckGroup)
end
