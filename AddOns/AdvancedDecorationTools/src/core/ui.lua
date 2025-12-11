local ADDON_NAME, ADT = ...
ADT = ADT or {}

-- Slash：/adt 打开设置面板（自定义 CommandDock 样式）
SLASH_ADT1 = "/adt"

-- 单一权威：切换 Dock “主体面板”显隐；容器（SettingsPanel）在编辑器内保持常驻
function ADT.ToggleMainUI()
    local Main = ADT and ADT.CommandDock and ADT.CommandDock.SettingsPanel
    if not Main then return end
    if Settings and ADT.SettingsCategory and SettingsPanel and SettingsPanel:IsShown() then
        Settings.OpenToCategory(ADT.SettingsCategory)
        return
    end

    local inEditor = C_HouseEditor and C_HouseEditor.IsHouseEditorActive and C_HouseEditor.IsHouseEditorActive()

    -- 确保容器已创建
    if not Main:IsShown() then
        local parent, strata
        if inEditor and HouseEditorFrame and HouseEditorFrame:IsShown() then
            parent, strata = HouseEditorFrame, "FULLSCREEN_DIALOG"
        else
            parent, strata = UIParent, "FULLSCREEN_DIALOG"
        end
        Main:ClearAllPoints()
        Main:SetParent(parent)
        if Main.SetFrameStrata then Main:SetFrameStrata(strata) end
        Main:SetPoint("CENTER")
        Main:ShowUI(inEditor and "editor" or "standalone")
    end

    -- 主体面板的真实显隐状态由 DockUI 维护
    local UI = ADT.DockUI
    local visible = UI and UI.AreMainPanelsVisible and UI.AreMainPanelsVisible()

    if visible then
        if inEditor and UI and UI.SetMainPanelsVisible then
            -- 在编辑器内：仅隐藏主体（容器常驻，SubPanel不受影响）
            UI.SetMainPanelsVisible(false)
        else
            -- 非编辑器：直接隐藏整个容器
            Main:Hide()
        end
    else
        -- 无论默认开关如何，手动打开应当强制显示主体
        if UI and UI.SetMainPanelsVisible then UI.SetMainPanelsVisible(true) end
        -- 首次手动打开时，若没有当前分类，则聚焦“通用”
        if Main.ShowSettingsCategory and not (Main.currentSettingsCategory or Main.currentDecorCategory or Main.currentAboutCategory) then
            Main:ShowSettingsCategory('Housing')
            if ADT and ADT.SetDBValue then ADT.SetDBValue('LastCategoryKey', 'Housing') end
        end
    end
end

SlashCmdList["ADT"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    -- /adt visit 角色-服务器
    if msg:match("^visit") then
        if ADT and ADT.VisitAssistant and ADT.VisitAssistant.HandleSlash then
            if ADT.VisitAssistant:HandleSlash(msg) then return end
        end
    end
    -- /adt dock ... 子命令：诊断 Dock 交互问题
    if msg:match("^dock") then
        local _, sub = msg:match("^(%S+)%s*(.*)$")
        sub = (sub or ""):lower():match("^%s*(.-)%s*$")
        local UI = ADT and ADT.DockUI
        if not UI then
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[DockDiag] DockUI 尚未加载") end
            return
        end
        if sub == "diag" or sub == "dump" then
            if UI.Diag then UI.Diag("user") end
            return
        end
        local action, arg = sub:match("^(%S+)%s*(.*)$")
        if action == "trace" then
            arg = (arg or ""):lower()
            if UI.SetTrace then UI.SetTrace(arg == "on" or arg == "1" or arg == "true") end
            return
        elseif action == "stack" then
            if UI.Stack then UI.Stack() else if ADT and ADT.DebugPrint then ADT.DebugPrint("[DockDiag] Stack() 不可用") end end
            return
        end
        -- 未知子命令时给出提示
        if ADT and ADT.DebugPrint then ADT.DebugPrint("[DockDiag] 用法: /adt dock diag | /adt dock trace on|off") end
        return
    end
    -- /adt debug [on|off|show]
    if msg:match("^debug") or msg:match("^dbg") then
        local _, arg = msg:match("^(%S+)%s*(.*)$")
        arg = (arg or ""):lower()
        if ADT and ADT.SetDBValue and ADT.IsDebugEnabled and ADT.Notify then
            if arg == "on" then
                ADT.SetDBValue("DebugEnabled", true)
            elseif arg == "off" then
                ADT.SetDBValue("DebugEnabled", false)
            elseif arg == "show" then
                -- 仅显示状态
            else
                -- toggle
                ADT.SetDBValue("DebugEnabled", not ADT.IsDebugEnabled())
            end
            if ADT.IsDebugEnabled() then
                ADT.Notify(ADT.L["ADT Debug Enabled"], 'success')
            else
                ADT.Notify(ADT.L["ADT Debug Disabled"], 'info')
            end
            if ADT and ADT.DebugPrint then
                ADT.DebugPrint("[Debug] DebugEnabled="..tostring(ADT.IsDebugEnabled()))
            end
        end
        return
    end
    ADT.ToggleMainUI()
end

-- 当编辑模式开关时，自动把设置面板重挂到合适的父级，避免被编辑器遮挡
do
    local function IsOwnedByBlizzardSettings(main)
        local p = main and main.GetParent and main:GetParent()
        return p and (p == _G.ADTSettingsContainer or (p.GetName and p:GetName() == "ADTSettingsContainer"))
    end

    local function ReanchorSettingsPanel()
        local Main = ADT and ADT.CommandDock and ADT.CommandDock.SettingsPanel
        if not (Main and Main:IsShown()) then return end
        -- 如果当前在暴雪设置页中展示，则不干预
        if IsOwnedByBlizzardSettings(Main) then return end

        if HouseEditorFrame and HouseEditorFrame:IsShown() then
            if Main:GetParent() ~= HouseEditorFrame then
                Main:SetParent(HouseEditorFrame)
            end
            if Main.SetFrameStrata then Main:SetFrameStrata("FULLSCREEN_DIALOG") end
        else
            if Main:GetParent() ~= UIParent then
                Main:SetParent(UIParent)
            end
            if Main.SetFrameStrata then Main:SetFrameStrata("FULLSCREEN_DIALOG") end
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function()
        -- 下一帧处理，避免和暴雪自身的布局竞争
        C_Timer.After(0, ReanchorSettingsPanel)
    end)
end
