-- [[ 大秘境信息增强 (提示) ]]
-- { Key = "ExM+Info.Tooltip", Name = "大秘境信息增强", Desc = "在挑战面板图标上显示详细的最佳记录、队友信息及传送冷却。", Category = 2 },

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local EXState = ExwindTools.State
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

-- 1. 识别 Key
local EXWIND_MODULE_KEY = "ExM+Info.Tooltip"

-- 2. 载入检查
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- 3. 数据初始化
local EXWIND_DEFAULTS = {
    enabled = true,
}
local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)

-- =========================================================
-- [v4.2] 注册与配置
-- =========================================================



-- 2. Grid 布局
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 53, h = 2, label = L["大米信息增强 (Mythic Plus Tooltips)"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 53, h = 3, label = L["开启后，鼠标悬停在 PVE 挑战面板的副本图标上时，会显示该副本的详细通关记录、队友专精以及该副本的快捷传送冷却状态。"] },
        { key = "enabled", type = "checkbox", x = 2, y = 7, w = 13, h = 1, label = L["启用法术提示增强"] },
        { key = "divider_8437", type = "divider", x = 2, y = 11, w = 53, h = 1, label = "新组件" },
    }


    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end

-- 3. 立即注册
EX_RegisterLayout()

-- 5. 业务逻辑实现 (变量前缀: EXMYTOOLTIP)
local EXMYTOOLTIP = {}

-- 使用全局共享数据库
local EXDB = _G.EXDB
if not EXDB then
    print("|cffff0000[ExM+Info.Tooltip]|r " .. L["错误: 共享数据库未加载!"])
    return
end

-- 常量配置
EXMYTOOLTIP.SpellMap = {
    [239] = 1254551,
    [556] = 1254555,
    [161] = 1254557,
    [402] = 393273,
    [557] = 1254400,
    [558] = 1254572,
    [560] = 1254559,
    [559] = 1254563,
    [525] = 1216786,
    [499] = 445444,
    [505] = 445414,
    [503] = 445417,
    [542] = 1237215,
    [378] = 354465,
    [392] = 367416,
    [391] = 367416,
}

-- 161 通天峰：联盟=1254557，部落=159898
function EXMYTOOLTIP.GetTeleportSpellID(mapID)
    if mapID == 161 then
        local function IsKnown(id)
            if C_SpellBook and C_SpellBook.IsSpellKnown then
                return C_SpellBook.IsSpellKnown(id, Enum.SpellBookSpellBank.Player)
            end
            return IsSpellKnown and IsSpellKnown(id)
        end

        local faction = UnitFactionGroup and UnitFactionGroup("player") or ""
        local prefer = (faction == "Horde") and 159898 or 1254557
        local fallback = (prefer == 159898) and 1254557 or 159898

        if IsKnown(prefer) then
            return prefer
        end
        if IsKnown(fallback) then
            return fallback
        end
        return prefer
    end
    return EXMYTOOLTIP.SpellMap[mapID]
end

-- 辅助函数
function EXMYTOOLTIP.GetSpecPriority(specID)
    return EXDB:GetSpecRolePriority(specID)
end

function EXMYTOOLTIP.FormatTime(sec)
    if sec >= 3600 then
        local h = math.floor(sec / 3600)
        local m = math.floor((sec % 3600) / 60)
        return string.format(L["%d小时%d分"], h, m)
    elseif sec >= 60 then
        local m = math.floor(sec / 60)
        local s = math.floor(sec % 60)
        return string.format(L["%d分%d秒"], m, s)
    else
        return string.format(L["%d秒"], math.floor(sec))
    end
end

function EXMYTOOLTIP.RequestData()
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    C_MythicPlus.RequestRewards()
end

-- 核心逻辑: 更新 Tooltip 内容
function EXMYTOOLTIP.UpdateTooltip(self)
    if not EX_DB.enabled then return end

    local mapID = self.mapID
    if not mapID and self:GetParent() and self:GetParent().mapID then
        mapID = self:GetParent().mapID
        self = self:GetParent()
    end

    if not mapID then return end

    local offset = 8
    local dungeonName, _, baseTimeLimit, texture = C_ChallengeMode.GetMapUIInfo(mapID)
    local intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(mapID)

    local activeKeystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo()
    local timeLimit = baseTimeLimit or 0
    local dungeonIconStr = texture and string.format("|T%d:18:18:0:0|t ", texture) or ""

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()

    if intimeInfo then
        GameTooltip:AddLine(dungeonIconStr .. dungeonName, 1, 1, 1)

        local scoreColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(intimeInfo.dungeonScore)
        if scoreColor then
            GameTooltip:AddLine(L["评分: "] .. "|c" .. scoreColor:GenerateHexColor() .. intimeInfo.dungeonScore .. "|r")
        else
            GameTooltip:AddLine(L["评分: "] .. intimeInfo.dungeonScore)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["最佳记录"], 1, 0.75, 0)
        GameTooltip:AddLine(L["等级 "] .. intimeInfo.level, 1, 1, 1)

        local completionTimeFormatted = string.format("%02d:%02d", math.floor(intimeInfo.durationSec / 60),
            intimeInfo.durationSec % 60)
        local remainingTime = timeLimit - intimeInfo.durationSec
        local remainingTimeFormatted
        if remainingTime >= 0 then
            remainingTimeFormatted = string.format(L["还剩 %02d:%02d"], math.floor(remainingTime / 60), remainingTime % 60)
        else
            remainingTimeFormatted = string.format(L["超时 %02d:%02d"], math.abs(math.floor(remainingTime / 60)),
                math.abs(remainingTime % 60))
        end
        GameTooltip:AddLine(L["时间 "] .. completionTimeFormatted .. " (" .. remainingTimeFormatted .. ")", 1, 1, 1)

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffebca3f" .. L["队伍成员"] .. "|r", 1, 0.75, 0)

        local sortedMembers = {}
        if intimeInfo.members then
            for _, member in ipairs(intimeInfo.members) do
                table.insert(sortedMembers, member)
            end
            table.sort(sortedMembers, function(a, b)
                local pA = EXMYTOOLTIP.GetSpecPriority(a.specID)
                local pB = EXMYTOOLTIP.GetSpecPriority(b.specID)
                if pA ~= pB then return pA < pB else return a.specID < b.specID end
            end)
        end

        for _, member in ipairs(sortedMembers) do
            local classInfo = EXDB.Classes[member.classID]
            local hex = classInfo and classInfo.colorHex or "ffffff"
            local _, _, _, specIcon = GetSpecializationInfoForSpecID(member.specID)
            local iconStr = specIcon and string.format("|T%d:17:17:0:0|t ", specIcon) or ""
            GameTooltip:AddLine(string.format("%s|cff%s%s|r", iconStr, hex, member.name or L["未知"]))
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["副本时间: "] .. string.format("%02d:%02d", math.floor(timeLimit / 60), timeLimit % 60), 1, 1, 1)

        local completionDate = intimeInfo.completionDate
        if completionDate then
            local adjustedYear, adjustedMonth, adjustedDay = completionDate.year + 2000, completionDate.month + 1,
                completionDate.day + 1
            local adjustedHour, adjustedMinute = completionDate.hour + offset, completionDate.minute
            if adjustedHour >= 24 then
                adjustedHour = adjustedHour - 24
                adjustedDay = adjustedDay + 1
            end
            GameTooltip:AddLine(
                string.format(L["完成日期: %02d/%02d/%02d %02d:%02d"], adjustedYear % 100, adjustedMonth, adjustedDay,
                    adjustedHour, adjustedMinute), 1, 1, 1)
        end
    else
        GameTooltip:AddLine(dungeonIconStr .. (dungeonName or L["未知副本"]), 1, 1, 1)
        GameTooltip:AddLine(L["本赛季尚未记录"], 1, 0.5, 0.5)
    end

    -- 传送门逻辑
    local spellID = EXMYTOOLTIP.GetTeleportSpellID(mapID)
    if spellID and C_SpellBook.IsSpellKnown(spellID, Enum.SpellBookSpellBank.Player) then
        -- [v8.0 Fix] 大秘境进行中也允许读取传送法术冷却，移除旧的战斗场景拦截分支
        local cd = C_Spell.GetSpellCooldown(spellID)
        if cd and cd.duration > 0 and cd.startTime > 0 then
            local remain = (cd.startTime + cd.duration) - GetTime()
            if remain > 0 then
                GameTooltip:AddLine(L["传送冷却中 还有 "] .. EXMYTOOLTIP.FormatTime(remain), 1, 0.3, 0.3)
            else
                GameTooltip:AddLine(L["传送可用"], 0, 1, 0)
            end
        else
            GameTooltip:AddLine(L["传送可用"], 0, 1, 0)
        end
    end

    -- [已删除] 应用字体样式设置逻辑
    GameTooltip:Show()
end

-- 挂钩挑战面板图标
function EXMYTOOLTIP.HookDungeonIcons()
    if not ChallengesFrame or not ChallengesFrame.DungeonIcons then return end
    for _, icon in ipairs(ChallengesFrame.DungeonIcons) do
        if not icon.EXWIND_Hooked then
            icon:HookScript("OnEnter", function(self) EXMYTOOLTIP.UpdateTooltip(self) end)
            icon:HookScript("OnLeave", function() GameTooltip:Hide() end)
            icon.EXWIND_Hooked = true
        end
    end
end

-- 初始化监听
EXMYTOOLTIP.Frame = CreateFrame("Frame")
EXMYTOOLTIP.Frame:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
EXMYTOOLTIP.Frame:SetScript("OnEvent", function() EXMYTOOLTIP.HookDungeonIcons() end)

-- PVE 面板显示时触发数据请求
if PVEFrame then
    PVEFrame:HookScript("OnShow", function() EXMYTOOLTIP.RequestData() end)
end

-- 循环检查挂钩 (处理延迟加载的 UI 元素)
C_Timer.NewTicker(5, function() EXMYTOOLTIP.HookDungeonIcons() end)

-- 初始延迟加载
C_Timer.After(5, function()
    EXMYTOOLTIP.RequestData()
    EXMYTOOLTIP.HookDungeonIcons()
end)

-- 报告模块加载完成
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
