-- [[ 玩家属性面板 ]]
-- { Key = "ExTools.PlayerStats", Name = "玩家属性面板", Desc = "在屏幕上显示高度自定义的玩家属性（急速、全能、躲闪等）。", Category = 4 },

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local EXState = ExwindTools.State
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExTools.PlayerStats"
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end
local isEditModeActive = false
local isEditModeVisible = true

local function RefreshEditOverlay(frame)
    if not frame then return end

    if isEditModeActive and isEditModeVisible then
        ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY, frame)
    else
        ExwindTools:HideExwindToolsEditOverlay(frame)
    end
end

local EXDB = _G.EXDB
local LSM = LibStub("LibSharedMedia-3.0")

local function IsSecretValue(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

-- 3. 数据初始化
local function GetDefaultFont()
    return { font = nil, size = 14, outline = "OUTLINE", r = 1, g = 1, b = 1, a = 1, shadow = true, x = 0, y = 0 }
end

local function GetDefaultRows()
    local rows = {}
    local defaultStats = { "主属性", "暴击", "急速", "精通", "全能", "移速" }
    for i = 1, 10 do
        table.insert(rows, {
            enabled = i <= 6,
            label = defaultStats[i] or ("属性" .. i),
            key = defaultStats[i] or "无",
            isPercent = true,
            format = 1,
            syncFont = true,
            roles = { TANK = true, HEALER = true, DAMAGER = true },
            scenes = { ["副本内"] = true, ["副本外"] = true },
            fontLabel = GetDefaultFont(),
            fontValue = GetDefaultFont()
        })
    end
    return rows
end

local function NormalizeDecimalPlaces(value)
    local decimals = tonumber(value)
    if not decimals or decimals ~= decimals or decimals == math.huge or decimals == -math.huge then
        decimals = 1
    end
    decimals = math.floor(decimals)
    if decimals < 0 then
        decimals = 0
    elseif decimals > 3 then
        decimals = 3
    end
    return decimals
end

local STAT_VALUE_FORMATS = {
    [0] = "%.0f",
    [1] = "%.1f",
    [2] = "%.2f",
    [3] = "%.3f",
}

local STAT_PERCENT_FORMATS = {
    [0] = "%.0f%%",
    [1] = "%.1f%%",
    [2] = "%.2f%%",
    [3] = "%.3f%%",
}

local EX_DEFAULTS = {
    bgSettings = {
        bgColorA = 1,
        bgColorB = 1,
        bgColorG = 1,
        bgColorR = 1,
        borderColorA = 1,
        borderColorB = 1,
        borderColorG = 1,
        borderColorR = 1,
        borderTexture = "None",
        edgeSize = 9,
        inset = 8,
        labelAlign = "CENTER:居中",
        labelX = 1,
        rowSpacing = 5,
        texture = "None",
        valueAlign = "LEFT:左对齐",
        valueX = -16,
    },
    locked = false,
    pos = {
        point = "BOTTOMLEFT",
        x = 380.21630859375,
        y = 179.10350036621,
    },
    rows = {
        {
            enabled = true,
            fontLabel = {
                a = 1,
                b = 0,
                font = nil,
                g = 0.63137257099152,
                outline = "THICKOUTLINE",
                r = 1,
                shadow = false,
                shadowX = 1.2000007629395,
                size = 24,
                x = -1,
                y = 2,
            },
            fontValue = {
                a = 1,
                b = 1,
                font = nil,
                g = 1,
                outline = "OUTLINE",
                r = 1,
                shadow = true,
                shadowX = 1,
                size = 14,
                x = 0,
                y = 0,
            },
            format = 0,
            isPercent = false,
            key = "主属性",
            label = "%主属性",
            roles = {
                DAMAGER = true,
                HEALER = true,
                TANK = true,
            },
            scenes = {
                ["副本内"] = true,
                ["副本外"] = true,
            },
            syncFont = true,
        },
        {
            enabled = true,
            fontLabel = {
                a = 1,
                b = 0.32549020648003,
                font = nil,
                g = 0.23921570181847,
                outline = "THICKOUTLINE",
                r = 1,
                shadow = false,
                size = 18,
                x = 0,
                y = 0,
            },
            fontValue = {
                a = 1,
                b = 1,
                font = nil,
                g = 1,
                outline = "OUTLINE",
                r = 1,
                shadow = true,
                shadowX = 1,
                size = 14,
                x = 0,
                y = 0,
            },
            format = 1,
            isPercent = true,
            key = "暴击",
            label = "暴击",
            roles = {
                DAMAGER = true,
                HEALER = true,
                TANK = true,
            },
            scenes = {
                ["副本内"] = true,
                ["副本外"] = true,
            },
            syncFont = true,
        },
        {
            enabled = true,
            fontLabel = {
                a = 1,
                b = 0.0078431377187371,
                font = nil,
                g = 1,
                outline = "THICKOUTLINE",
                r = 0.52156865596771,
                shadow = false,
                size = 18,
                x = 0,
                y = 0,
            },
            fontValue = {
                a = 1,
                b = 1,
                font = nil,
                g = 1,
                outline = "THICKOUTLINE",
                r = 1,
                shadow = false,
                size = 14,
                x = 0,
                y = 0,
            },
            format = 1,
            isPercent = true,
            key = "急速",
            label = "急速",
            roles = {
                DAMAGER = true,
                HEALER = true,
                TANK = true,
            },
            scenes = {
                ["副本内"] = true,
                ["副本外"] = true,
            },
            syncFont = true,
        },
        {
            enabled = true,
            fontLabel = {
                a = 1,
                b = 1,
                font = nil,
                g = 0.57254904508591,
                outline = "THICKOUTLINE",
                r = 0.04313725605607,
                shadow = false,
                size = 18,
                x = 0,
                y = 0,
            },
            fontValue = {
                a = 1,
                b = 1,
                font = nil,
                g = 1,
                outline = "OUTLINE",
                r = 1,
                shadow = true,
                size = 15,
                x = 0,
                y = 0,
            },
            format = 1,
            isPercent = true,
            key = "精通",
            label = "精通",
            roles = {
                DAMAGER = true,
                HEALER = true,
                TANK = true,
            },
            scenes = {
                ["副本内"] = true,
                ["副本外"] = true,
            },
            syncFont = true,
        },
        {
            enabled = true,
            fontLabel = {
                a = 1,
                b = 1,
                font = nil,
                g = 0.90980398654938,
                outline = "THICKOUTLINE",
                r = 0.3647058904171,
                shadow = false,
                size = 18,
                x = 0,
                y = 0,
            },
            fontValue = {
                a = 1,
                b = 1,
                font = nil,
                g = 1,
                outline = "OUTLINE",
                r = 1,
                shadow = false,
                size = 14,
                x = 0,
                y = 0,
            },
            format = 1,
            isPercent = true,
            key = "全能",
            label = "全能",
            roles = {
                DAMAGER = true,
                HEALER = true,
                TANK = true,
            },
            scenes = {
                ["副本内"] = true,
                ["副本外"] = true,
            },
            syncFont = true,
        },
        {
            enabled = true,
            fontLabel = {
                a = 1,
                b = 0.28627452254295,
                font = nil,
                g = 0.91372555494308,
                outline = "THICKOUTLINE",
                r = 1,
                shadow = false,
                size = 18,
                x = 0,
                y = 0,
            },
            fontValue = {
                a = 1,
                b = 1,
                font = nil,
                g = 1,
                outline = "OUTLINE",
                r = 1,
                shadow = true,
                size = 14,
                x = 0,
                y = 0,
            },
            format = 0,
            isPercent = true,
            key = "移速",
            label = "移速",
            roles = {
                DAMAGER = true,
                HEALER = true,
                TANK = true,
            },
            scenes = {
                ["副本内"] = true,
                ["副本外"] = true,
            },
            syncFont = true,
        },
    },
    selectedRow = 1,
    showBg = false,
    showBorder = false,
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)
if not EX_DB.rows or #EX_DB.rows == 0 then
    EX_DB.rows = GetDefaultRows()
end

local STAT_MAP = {
    ["无"] = "None",
    ["主属性"] = "PStat_Major",
    ["力量"] = "PStat_Str",
    ["敏捷"] = "PStat_Agi",
    ["智力"] = "PStat_Int",
    ["暴击"] = "PStat_Crit",
    ["急速"] = "PStat_Haste",
    ["精通"] = "PStat_Mastery",
    ["全能"] = "PStat_VersaText",
    ["吸血"] = "PStat_Leech",
    ["闪避"] = "PStat_Avoidance",
    ["移速"] = "PStat_MovementText",
    ["护甲"] = "PStat_Armor",
    ["躲闪"] = "PStat_Dodge",
    ["招架"] = "PStat_Parry",
    ["格挡"] = "PStat_Block",
    ["装等"] = "PStat_EquippedItemLevel",
    ["血量"] = "PStat_MaxHealth",
    ["耐久"] = "PStat_Durability"
}

ExwindTools.GetRowItems_PlayerStats = function()
    local items = {}
    for i, row in ipairs(EX_DB.rows) do
        local name = (row.label and row.label ~= "") and (L[row.label] or row.label) or (L["属性行 "] .. i)
        table.insert(items, { i .. ": " .. name, i })
    end
    return items
end

ExwindTools.GetPlayerStatTree = function()
    return {
        { L["无"], "无" },
        {
            text = L["主属性"],
            isMenu = true,
            menu = {
                { L["主属性(自动)"], "主属性" }, { L["力量"], "力量" }, { L["敏捷"], "敏捷" }, { L["智力"], "智力" }
            }
        },
        {
            text = L["次要属性"],
            isMenu = true,
            menu = {
                { "|cffFF3D53" .. L["暴击"] .. "|r", "暴击" }, { "|cff85FF02" .. L["急速"] .. "|r", "急速" }, { "|cff0B92FF" .. L["精通"] .. "|r", "精通" }, { "|cff5DE8FF" .. L["全能"] .. "|r", "全能" }
            }
        },
        {
            text = L["第三属性"],
            isMenu = true,
            menu = {
                { L["吸血"], "吸血" }, { L["闪避"], "闪避" }, { L["移速"], "移速" }
            }
        },
        {
            text = L["防御属性"],
            isMenu = true,
            menu = {
                { L["护甲"], "护甲" }, { L["躲闪"], "躲闪" }, { L["招架"], "招架" }, { L["格挡"], "格挡" }
            }
        },
        {
            text = L["其他"],
            isMenu = true,
            menu = {
                { L["装等"], "装等" }, { L["血量"], "血量" }, { L["耐久"], "耐久" }
            }
        }
    }
end

local function EX_RegisterLayout()
    local sel = tonumber(EX_DB.selectedRow) or 1
    if sel < 1 then sel = 1 end
    if sel > #EX_DB.rows then sel = #EX_DB.rows end
    EX_DB.selectedRow = sel

    local currentRowPath = "rows." .. sel
    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 53, h = 2, label = L["玩家属性面板"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 53, h = 2, label = L["实时显示角色属性。右键组件可进入编辑模式。"] },
        { key = "sub_gen", type = "subheader", x = 2, y = 7, w = 53, h = 2, label = L["通用设置"], labelSize = 20 },
        { key = "locked", type = "checkbox", x = 2, y = 11, w = 8, h = 2, label = L["锁定位置"] },
        { key = "showBg", type = "checkbox", x = 2, y = 14, w = 8, h = 2, label = L["显示背景"] },
        { key = "showBorder", type = "checkbox", x = 2, y = 18, w = 8, h = 1, label = L["显示边框"] },
        {
            key = "bgGroup",
            type = "TableGroup",
            x = 1,
            y = 1,
            w = 1,
            h = 1,
            label = "--[[ Function ]]",
            parentKey = "bgSettings",
            children = {
                { key = "texture", type = "lsm_background", x = 11, y = 13, w = 12, h = 2, label = L["背景材质"] },
                { key = "bgColor", type = "color", x = 24, y = 13, w = 10, h = 2, label = L["背景颜色"] },
                { key = "borderTexture", type = "lsm_border", x = 11, y = 17, w = 12, h = 2, label = L["边框材质"] },
                { key = "borderColor", type = "color", x = 24, y = 17, w = 10, h = 2, label = L["边框颜色"] },
                { key = "edgeSize", type = "slider", x = 35, y = 17, w = 10, h = 2, label = L["边框粗细"], min = 1, max = 32 },
                { key = "inset", type = "slider", x = 46, y = 17, w = 10, h = 2, label = L["边框内距"], min = 0, max = 16 },
                { key = "labelAlign", type = "dropdown", x = 2, y = 22, w = 10, h = 2, label = L["标签对齐"], items = "LEFT:左对齐,CENTER:居中,RIGHT:右对齐" },
                { key = "valueAlign", type = "dropdown", x = 13, y = 22, w = 10, h = 2, label = L["数值对齐"], items = "LEFT:左对齐,CENTER:居中,RIGHT:右对齐" },
                { key = "rowSpacing", type = "slider", x = 46, y = 22, w = 10, h = 2, label = L["行间距"], min = -10, max = 30 },
                { key = "labelX", type = "slider", x = 24, y = 22, w = 10, h = 2, label = L["标签全局X"], min = -50, max = 50 },
                { key = "valueX", type = "slider", x = 35, y = 22, w = 10, h = 2, label = L["数值全局X"], min = -50, max = 50 },
            }
        },
        { key = "sub_row", type = "subheader", x = 2, y = 27, w = 53, h = 2, label = L["属性行管理"], labelSize = 20 },
        { key = "selectedRow", type = "dropdown", x = 2, y = 31, w = 16, h = 2, label = L["选择要编辑的行"], items = "func:ExwindTools.GetRowItems_PlayerStats" },
        { key = "btn_up", type = "button", x = 19, y = 31, w = 3, h = 2, label = "↑" },
        { key = "btn_down", type = "button", x = 23, y = 31, w = 3, h = 2, label = "↓" },
        { key = "btn_add", type = "button", x = 27, y = 31, w = 8, h = 2, label = L["新增"] },
        { key = "btn_delete", type = "button", x = 36, y = 31, w = 8, h = 2, label = L["删除"] },
        { key = "btn_reset", type = "button", x = 45, y = 31, w = 8, h = 2, label = L["重置位置"] },
        {
            key = "RowEditor",
            type = "TableGroup",
            x = 1,
            y = 1,
            w = 1,
            h = 1,
            label = "--[[ Function ]]",
            parentKey = "rows." .. sel,
            children = {
                { key = "enabled", type = "checkbox", x = 2, y = 35, w = 8, h = 2, label = L["启用此行"] },
                { key = "label", type = "input", x = 11, y = 35, w = 10, h = 2, label = L["名称"] },
                { key = "key", type = "dropdown", x = 23, y = 35, w = 10, h = 2, label = L["属性"], items = "func:ExwindTools.GetPlayerStatTree" },
                { key = "format", type = "slider", x = 42, y = 35, w = 11, h = 2, label = L["小数"], min = 0, max = 3 },
                { key = "isPercent", type = "checkbox", x = 36, y = 35, w = 4, h = 2, label = "%" },
                { key = "roles", type = "multiselect", x = 22, y = 40, w = 14, h = 2, label = L["显示职责"], items = "TANK,HEALER,DAMAGER" },
                { key = "scenes", type = "multiselect", x = 40, y = 40, w = 13, h = 2, label = L["显示场景"], items = "副本内,副本外" },
                { key = "syncFont", type = "checkbox", x = 2, y = 63, w = 16, h = 2, label = "|cffff0501" .. L["样式同步"] .. "|r", labelSize = 20 },
                { key = "fontLabel", type = "fontgroup", x = 2, y = 43, w = 54, h = 18, label = L["标签样式"], labelSize = 20 },
                { key = "fontValue", type = "fontgroup", x = 2, y = 67, w = 54, h = 18, label = L["数值样式"], labelSize = 20 },
            }
        },
        { key = "divider_2", type = "divider", x = 2, y = 29, w = 53, h = 1, label = "" },
        { key = "divider_5137", type = "divider", x = 2, y = 9, w = 53, h = 1, label = L["新组件"] },
    }



    if ExwindGrid then
        ExwindGrid.ExportReplacements = { [currentRowPath] = '"rows." .. sel' }
    end
    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

local EXStatsUI = { RowFrames = {} }
_G.EXStatsUI = EXStatsUI

function EXStatsUI:RefreshStyle()
    if not self.frame then return end
    local conf = EX_DB.bgSettings
    self.frame:SetBackdrop({
        bgFile = EX_DB.showBg and LSM:Fetch("background", conf.texture) or nil,
        edgeFile = EX_DB.showBorder and LSM:Fetch("border", conf.borderTexture) or nil,
        edgeSize = conf.edgeSize or 12,
        insets = { left = conf.inset or 4, right = conf.inset or 4, top = conf.inset or 4, bottom = conf.inset or 4 }
    })

    local r, g, b, a = conf.bgColorR or 0, conf.bgColorG or 0, conf.bgColorB or 0, conf.bgColorA or 0.5
    local br, bg, bb, ba = conf.borderColorR or 1, conf.borderColorG or 1, conf.borderColorB or 1, conf.borderColorA or 1

    self.frame:SetBackdropColor(r, g, b, EX_DB.showBg and a or 0)
    self.frame:SetBackdropBorderColor(br, bg, bb, EX_DB.showBorder and ba or 0)
    -- 鼠标穿透由全局编辑模式控制，此处不再干预
end

function EXStatsUI:RefreshRows()
    if not self.frame then return end
    local specID = ExwindTools.State.SpecID
    local role = "DAMAGER"
    if specID and specID > 0 and EXDB.SpecByID[specID] then
        role = EXDB.SpecByID[specID].role
    end
    local inInstance = IsInInstance()

    -- 1. 清理
    for i, r in pairs(self.RowFrames) do
        r:Hide()
        if r._lastWatchKey then ExwindTools:UnwatchState(r._lastWatchKey, "StatsUI_R" .. i) end
    end

    local yOffset = -12
    local rowHeight = 20
    local spacing = EX_DB.bgSettings.rowSpacing or 2
    local lAlign = EX_DB.bgSettings.labelAlign or "LEFT"
    local vAlign = EX_DB.bgSettings.valueAlign or "RIGHT"
    lAlign = lAlign:match("^([^:]+):") or lAlign
    vAlign = vAlign:match("^([^:]+):") or vAlign

    -- 2. 渲染
    for i, conf in ipairs(EX_DB.rows) do
        if conf.enabled then
            local visible = true
            if conf.roles and not conf.roles[role] then visible = false end
            local sceneKey = inInstance and "副本内" or "副本外"
            if conf.scenes and not conf.scenes[sceneKey] then visible = false end

            if visible then
                local row = self.RowFrames[i]
                if not row then
                    row = CreateFrame("Frame", nil, self.frame)
                    row:SetSize(self.frame:GetWidth() - 16, rowHeight)
                    row:EnableMouse(false) -- 子行永远穿透，鼠标由父框架统一处理
                    row.label = row:CreateFontString(nil, "OVERLAY")
                    row.value = row:CreateFontString(nil, "OVERLAY")
                    self.RowFrames[i] = row
                end

                row:Show(); row:SetPoint("TOPLEFT", 8, yOffset)

                local lf = conf.fontLabel or GetDefaultFont()
                local vf = conf.syncFont and lf or (conf.fontValue or GetDefaultFont())
                EXDB:ApplyFont(row.label, lf)
                EXDB:ApplyFont(row.value, vf)

                row.label:ClearAllPoints(); row.value:ClearAllPoints()
                local halfW = self.frame:GetWidth() / 2
                local gap = 4
                local glX = EX_DB.bgSettings.labelX or 0
                local gvX = EX_DB.bgSettings.valueX or 0

                -- 标题布局 (叠加本地 X/Y 和全局 X)
                if lAlign == "LEFT" then
                    row.label:SetPoint("LEFT", row, "LEFT", 8 + (lf.x or 0) + glX, (lf.y or 0))
                elseif lAlign == "CENTER" then
                    row.label:SetPoint("CENTER", row, "LEFT", halfW / 2 + (lf.x or 0) + glX, (lf.y or 0))
                else -- RIGHT
                    row.label:SetPoint("RIGHT", row, "CENTER", -gap + (lf.x or 0) + glX, (lf.y or 0))
                end
                row.label:SetJustifyH(lAlign)

                -- 数值布局 (叠加本地 X/Y 和全局 X)
                if vAlign == "RIGHT" then
                    row.value:SetPoint("RIGHT", row, "RIGHT", -8 + (vf.x or 0) + gvX, (vf.y or 0))
                elseif vAlign == "CENTER" then
                    row.value:SetPoint("CENTER", row, "RIGHT", -halfW / 2 + (vf.x or 0) + gvX, (vf.y or 0))
                else -- LEFT
                    row.value:SetPoint("LEFT", row, "CENTER", gap + (vf.x or 0) + gvX, (vf.y or 0))
                end
                row.value:SetJustifyH(vAlign)

                local primaryStat = EXDB:GetPlayerPrimaryStat() or "属性"
                local labelText = (conf.label or ""):gsub("%%主属性", primaryStat)
                row.label:SetText(L[labelText] or labelText)

                local internalKey = STAT_MAP[conf.key] or conf.key
                row._lastWatchKey = internalKey
                local function UpdateVal()
                    local val = (internalKey ~= "None") and EXState[internalKey] or nil
                    local decimals = NormalizeDecimalPlaces(conf.format)
                    if conf.format ~= decimals then
                        conf.format = decimals
                    end
                    local fmt = (conf.isPercent and STAT_PERCENT_FORMATS or STAT_VALUE_FORMATS)[decimals] or STAT_VALUE_FORMATS[1]
                    if IsSecretValue(val) then
                        if internalKey == "PStat_VersaText" or internalKey == "PStat_MovementText" then
                            row.value:SetText(val)
                        else
                            row.value:SetText(string.format(fmt, val))
                        end
                    elseif val == nil then
                        row.value:SetText(L["N/A"])
                    elseif type(val) == "string" then
                        row.value:SetText(val)
                    else
                        row.value:SetText(string.format(fmt, val))
                    end
                end

                if internalKey ~= "None" then
                    ExwindTools:WatchState(internalKey, "StatsUI_R" .. i, UpdateVal)
                    UpdateVal()
                else
                    row.value:SetText(L["N/A"])
                end

                yOffset = yOffset - rowHeight - spacing
            end
        end
    end
    self.frame:SetHeight(math.abs(yOffset) + 12)
end

function EXStatsUI:Init()
    if self.frame then return end
    local f = CreateFrame("Frame", "ExwindPlayerStatsFrame", UIParent, "BackdropTemplate")
    local pos = EX_DB.pos or { point = "CENTER", x = 0, y = 0 }
    f:SetSize(220, 100); f:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    f:SetMovable(true); f:RegisterForDrag("LeftButton")
    -- 只有编辑模式下才可拖动
    f:SetScript("OnDragStart", function(s) if ExwindTools.GlobalEditMode then s:StartMoving() end end)
    f:SetScript("OnDragStop",
        function(s)
            s:StopMovingOrSizing(); local p, _, _, x, y = s:GetPoint(); if not EX_DB.pos then EX_DB.pos = {} end; EX_DB.pos.x, EX_DB.pos.y, EX_DB.pos.point =
                x, y, p
        end)
    self.frame = f

    -- RegisterHUD 内部会强行 EnableMouse(true)，注册后立即还原为穿透
    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, f)
    f:EnableMouse(false)

    local function ApplyEditModePresentation()
        if isEditModeActive and isEditModeVisible then
            f:Show()
            f:EnableMouse(true)
        else
            if not isEditModeActive then
                f:Show()
            end
            f:EnableMouse(false)
            if isEditModeActive and not isEditModeVisible then
                f:Hide()
            end
        end
        RefreshEditOverlay(f)
    end

    ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
        EnterEditMode = function()
            isEditModeActive = true
            isEditModeVisible = true
            ApplyEditModePresentation()
        end,
        ExitEditMode = function()
            isEditModeActive = false
            isEditModeVisible = true
            ApplyEditModePresentation()
        end,
        SetEditVisible = function(_, visible)
            isEditModeVisible = (visible ~= false)
            ApplyEditModePresentation()
        end,
    })

    self:RefreshStyle(); self:RefreshRows()

    -- 监控专精变化，自动刷新属性行（解决主属性标签不更新问题）
    ExwindTools:WatchState("SpecID", EXWIND_MODULE_KEY, function()
        if self.frame then self:RefreshRows() end
    end)
end

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info then return end
    if info.key == "selectedRow" or info.key == "label" or info.key == "syncFont" then
        EX_RegisterLayout(); ExwindTools.UI:RefreshContent()
    end
    if EXStatsUI.frame then
        EXStatsUI:RefreshStyle(); EXStatsUI:RefreshRows()
    end
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end
    local sel = tonumber(EX_DB.selectedRow) or 1
    if info.key == "btn_up" and sel > 1 then
        local t = sel - 1; EX_DB.rows[sel], EX_DB.rows[t] = EX_DB.rows[t], EX_DB.rows[sel]; EX_DB.selectedRow = t; EX_RegisterLayout(); ExwindTools
            .UI:RefreshContent()
    elseif info.key == "btn_down" and sel < #EX_DB.rows then
        local t = sel + 1; EX_DB.rows[sel], EX_DB.rows[t] = EX_DB.rows[t], EX_DB.rows[sel]; EX_DB.selectedRow = t; EX_RegisterLayout(); ExwindTools
            .UI:RefreshContent()
    elseif info.key == "btn_add" then
        table.insert(EX_DB.rows,
            {
                enabled = true,
                label = L["新属性"],
                key = "无",
                isPercent = true,
                format = 1,
                syncFont = true,
                roles = { TANK = true, HEALER = true, DAMAGER = true },
                scenes = { ["副本内"] = true, ["副本外"] = true },
                fontLabel =
                    GetDefaultFont(),
                fontValue = GetDefaultFont()
            })
        EX_DB.selectedRow = #EX_DB.rows; EX_RegisterLayout(); ExwindTools.UI:RefreshContent()
    elseif info.key == "btn_delete" and #EX_DB.rows > 1 then
        table.remove(EX_DB.rows, sel); EX_DB.selectedRow = math.max(1, sel - 1); EX_RegisterLayout(); ExwindTools.UI
            :RefreshContent()
    elseif info.key == "btn_reset" and ExwindPlayerStatsFrame then
        EX_DB.pos = { point = "CENTER", x = 0, y = 0 }; ExwindPlayerStatsFrame:SetPoint("CENTER", 0, 0)
    end
end)

C_Timer.After(1.5, function() EXStatsUI:Init() end)
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
