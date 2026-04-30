-- =============================================================
-- [[ 玩家角色定位标记 >> ExTools.PlayerPosition ]]
-- =============================================================
local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end

local EXWIND_MODULE_KEY = "ExTools.PlayerPosition"

-- =============================================================
-- 1. Grid 布局定义
-- =============================================================
local function EX_RegisterLayout()
    local layout = {
        { key = "head", type = "header", x = 1, y = 1, w = 50, h = 2, label = "玩家角色定位标记", labelSize = 25 },
        { key = "desc", type = "description", x = 1, y = 4, w = 50, h = 2, label = "优先加载本地材质(PNG)。若文件缺失，自动回退到纯代码绘图模式。" },

        -- 基础
        { key = "div1", type = "divider", x = 1, y = 6, w = 50, h = 1 },
        { key = "enabled", type = "checkbox", x = 1, y = 8, w = 20, h = 2, label = "启用指示器" },
        {
            key = "shapeType",
            type = "dropdown",
            x = 1,
            y = 13,
            w = 20,
            h = 2,
            label = "图形样式",
            items = {
                { "方块 (Square)", "SQUARE" },
                { "十字 (Cross)", "CROSS" },
                { "圆形 (Circle)", "CIRCLE" },
                { "圆环 (Ring)", "RING" },
                { "菱形 (Diamond)", "DIAMOND" },
            }
        },

        { key = "scale", type = "slider", x = 21, y = 13, w = 19, h = 2, label = "缩放", min = 0.1, max = 1.5, step = 0.1 },
        { key = "color", type = "color", x = 18, y = 27, w = 12, h = 2, label = "正常颜色" },

        -- 偏移
        { key = "offsetX", type = "slider", x = 1, y = 17, w = 20, h = 2, label = "X 轴偏移", min = -500, max = 500, step = 1 },
        { key = "offsetY", type = "slider", x = 21, y = 17, w = 19, h = 2, label = "Y 轴偏移", min = -500, max = 500, step = 1 },

        -- 距离监控
        { key = "div_range", type = "divider", x = 1, y = 22, w = 50, h = 1 },
        { key = "h_range", type = "subheader", x = 1, y = 20, w = 50, h = 2, label = "距离监控", labelSize = 20 },
        { key = "desc_range", type = "description", x = 1, y = 23, w = 50, h = 2, label = "当超出距离时 图标变色 (空=自动使用专精预设)" },

        { key = "rangeSpell", type = "input", x = 1, y = 27, w = 15, h = 2, label = "距离判定法术(ID)", placeholder = "默认: 专精预设" },
        { key = "rangeColor", type = "color", x = 33, y = 27, w = 12, h = 2, label = "超距颜色" },

        -- 显示条件
        { key = "div2", type = "divider", x = 1, y = 33, w = 50, h = 1 },
        { key = "h_vis", type = "subheader", x = 1, y = 31, w = 50, h = 2, label = "显示条件", labelSize = 20 },
        {
            key = "visibility",
            type = "multiselect",
            x = 1,
            y = 36,
            w = 25,
            h = 2,
            label = "触发场景",
            items = { "战斗中显示", "战斗外显示", "仅副本内" }
        },

        -- 专精过滤 (Hardcoded Items List sorted by Class ID)
        { key = "h_specs", type = "subheader", x = 1, y = 40, w = 50, h = 2, label = "专精过滤 (仅在勾选的专精下启用)" },
        {
            key = "enabledSpecs",
            type = "multiselect",
            x = 1,
            y = 44,
            w = 51,
            h = 2,
            label = "启用专精",
            items = {
                "|cffC79C6E战士|r - 武器",
                "|cffC79C6E战士|r - 狂怒",
                "|cffC79C6E战士|r - 防护",
                "|cffF48CBA圣骑士|r - 神圣",
                "|cffF48CBA圣骑士|r - 防护",
                "|cffF48CBA圣骑士|r - 惩戒",
                "|cffABD473猎人|r - 野兽控制",
                "|cffABD473猎人|r - 射击",
                "|cffABD473猎人|r - 生存",
                "|cffFFF468潜行者|r - 奇袭",
                "|cffFFF468潜行者|r - 狂徒",
                "|cffFFF468潜行者|r - 敏锐",
                "|cffFFFFFF牧师|r - 戒律",
                "|cffFFFFFF牧师|r - 神圣",
                "|cffFFFFFF牧师|r - 暗影",
                "|cffC41E3A死亡骑士|r - 鲜血",
                "|cffC41E3A死亡骑士|r - 冰霜",
                "|cffC41E3A死亡骑士|r - 邪恶",
                "|cff0070DD萨满祭司|r - 元素",
                "|cff0070DD萨满祭司|r - 增强",
                "|cff0070DD萨满祭司|r - 恢复",
                "|cff3FC7EB法师|r - 奥术",
                "|cff3FC7EB法师|r - 火焰",
                "|cff3FC7EB法师|r - 冰霜",
                "|cff8788EE术士|r - 痛苦",
                "|cff8788EE术士|r - 恶魔学识",
                "|cff8788EE术士|r - 毁灭",
                "|cff00FF98武僧|r - 酒仙",
                "|cff00FF98武僧|r - 踏风",
                "|cff00FF98武僧|r - 织雾",
                "|cffFF7C0A德鲁伊|r - 平衡",
                "|cffFF7C0A德鲁伊|r - 野性",
                "|cffFF7C0A德鲁伊|r - 守护",
                "|cffFF7C0A德鲁伊|r - 恢复",
                "|cffA330C9恶魔猎手|r - 浩劫",
                "|cffA330C9恶魔猎手|r - 复仇",
                "|cff33937F唤魔师|r - 湮灭",
                "|cff33937F唤魔师|r - 恩护",
                "|cff33937F唤魔师|r - 增辉",
                "|cffA330C9恶魔猎手|r - 噬灭" -- 假设噬灭是新第三专精
            }
        },
    }
    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- =============================================================
-- 2. 数据初始化
-- =============================================================
local EX_DEFAULTS = {
    enabled = false,
    shapeType = "CROSS",
    scale = 0.5,
    offsetX = 0,
    offsetY = 0,

    colorR = 0.15,
    colorG = 1,
    colorB = 0.25,
    colorA = 1,

    rangeSpell = "",
    rangeColorR = 1,
    rangeColorG = 0,
    rangeColorB = 0,
    rangeColorA = 1,

    visibility = { ["战斗中显示"] = true, ["战斗外显示"] = true, ["仅副本内"] = true },

    -- 默认全选所有专精
    enabledSpecs = {
        ["|cffC79C6E战士|r - 武器"] = true,
        ["|cffC79C6E战士|r - 狂怒"] = true,
        ["|cffC79C6E战士|r - 防护"] = true,
        ["|cffF48CBA圣骑士|r - 神圣"] = true,
        ["|cffF48CBA圣骑士|r - 防护"] = true,
        ["|cffF48CBA圣骑士|r - 惩戒"] = true,
        ["|cffABD473猎人|r - 野兽控制"] = true,
        ["|cffABD473猎人|r - 射击"] = true,
        ["|cffABD473猎人|r - 生存"] = true,
        ["|cffFFF468潜行者|r - 奇袭"] = true,
        ["|cffFFF468潜行者|r - 狂徒"] = true,
        ["|cffFFF468潜行者|r - 敏锐"] = true,
        ["|cffFFFFFF牧师|r - 戒律"] = true,
        ["|cffFFFFFF牧师|r - 神圣"] = true,
        ["|cffFFFFFF牧师|r - 暗影"] = true,
        ["|cffC41E3A死亡骑士|r - 鲜血"] = true,
        ["|cffC41E3A死亡骑士|r - 冰霜"] = true,
        ["|cffC41E3A死亡骑士|r - 邪恶"] = true,
        ["|cff0070DD萨满祭司|r - 元素"] = true,
        ["|cff0070DD萨满祭司|r - 增强"] = true,
        ["|cff0070DD萨满祭司|r - 恢复"] = true,
        ["|cff3FC7EB法师|r - 奥术"] = true,
        ["|cff3FC7EB法师|r - 火焰"] = true,
        ["|cff3FC7EB法师|r - 冰霜"] = true,
        ["|cff8788EE术士|r - 痛苦"] = true,
        ["|cff8788EE术士|r - 恶魔学识"] = true,
        ["|cff8788EE术士|r - 毁灭"] = true,
        ["|cff00FF98武僧|r - 酒仙"] = true,
        ["|cff00FF98武僧|r - 踏风"] = true,
        ["|cff00FF98武僧|r - 织雾"] = true,
        ["|cffFF7C0A德鲁伊|r - 平衡"] = true,
        ["|cffFF7C0A德鲁伊|r - 野性"] = true,
        ["|cffFF7C0A德鲁伊|r - 守护"] = true,
        ["|cffFF7C0A德鲁伊|r - 恢复"] = true,
        ["|cffA330C9恶魔猎手|r - 浩劫"] = true,
        ["|cffA330C9恶魔猎手|r - 复仇"] = true,
        ["|cff33937F唤魔师|r - 湮灭"] = true,
        ["|cff33937F唤魔师|r - 恩护"] = true,
        ["|cff33937F唤魔师|r - 增辉"] = true,
        ["|cffA330C9恶魔猎手|r - 噬灭"] = true
    }
}
local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)

-- =============================================================
-- 3. 核心业务逻辑
-- =============================================================
local IndicatorFrame = CreateFrame("Frame", "ExwindPlayerPositionIndicator", UIParent)
IndicatorFrame:SetFrameStrata("MEDIUM") -- [v1.1 Fix] 降低层级，避免覆盖过多界面元素
IndicatorFrame:SetSize(64, 64)
IndicatorFrame:SetIgnoreParentAlpha(true)
ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, IndicatorFrame)
-- RegisterHUD 内部会强制 EnableMouse(true)，在其之后再次关闭以实现点击穿透
IndicatorFrame:EnableMouse(false)
IndicatorFrame.textures = {}
IndicatorFrame:Hide()

local TEXTURE_PATHS = {
    ["SQUARE"] = "Interface\\AddOns\\ExwindTools\\Textures\\PlayerPosition\\Square.png",
    ["CROSS"] = "Interface\\AddOns\\ExwindTools\\Textures\\PlayerPosition\\Cross.png",
    ["CIRCLE"] = "Interface\\AddOns\\ExwindTools\\Textures\\PlayerPosition\\Circle.png",
    ["RING"] = "Interface\\AddOns\\ExwindTools\\Textures\\PlayerPosition\\Ring.png",
    ["DIAMOND"] = "Interface\\AddOns\\ExwindTools\\Textures\\PlayerPosition\\Diamond.png",
}

-- 获取或创建 Texture
local function GetTex(idx)
    if not IndicatorFrame.textures[idx] then
        IndicatorFrame.textures[idx] = IndicatorFrame:CreateTexture(nil, "ARTWORK")
    end
    local t = IndicatorFrame.textures[idx]
    t:ClearAllPoints()
    t:SetTexCoord(0, 1, 0, 1)
    t:Show()
    t:SetRotation(0)
    return t
end

-- 绘制图形
local function DrawShape(shape)
    for _, tex in ipairs(IndicatorFrame.textures) do tex:Hide() end
    local w, h = IndicatorFrame:GetSize()

    local path = TEXTURE_PATHS[shape]
    if path then
        local t = GetTex(1); t:SetAllPoints()
        if t:SetTexture(path) then return end -- Success
    end

    -- Fallback: Code Drawing
    if shape == "SQUARE" then
        local t = GetTex(1); t:SetAllPoints(); t:SetColorTexture(1, 1, 1, 1)
    elseif shape == "CROSS" then
        local thickness = 0.125
        local t1 = GetTex(1); t1:SetPoint("CENTER"); t1:SetSize(w * thickness, h); t1:SetColorTexture(1, 1, 1, 1)
        local t2 = GetTex(2); t2:SetPoint("CENTER"); t2:SetSize(w, h * thickness); t2:SetColorTexture(1, 1, 1, 1)
    elseif shape == "DIAMOND" then
        local t = GetTex(1); t:SetSize(w * 0.707, h * 0.707); t:SetPoint("CENTER"); t:SetColorTexture(1, 1, 1, 1); t
            :SetRotation(math.rad(45))
    else
        local t = GetTex(1); t:SetAllPoints(); t:SetColorTexture(1, 1, 1, 1)
    end
end

-- 获取当前生效的 Range 监控法术
local function GetRangeSpell()
    -- 1. 优先使用用户手动输入的
    local userSpell = EX_DB.rangeSpell
    if userSpell and userSpell ~= "" then
        -- Try number conversion
        local spellID = tonumber(userSpell)
        return spellID or userSpell
    end

    -- 2. 尝试获取专精预设
    if ExwindTools.State and ExwindTools.DB_Static then
        local specID = ExwindTools.State.SpecID
        if specID and specID > 0 and ExwindTools.DB_Static.SpecByID then
            local specInfo = ExwindTools.DB_Static.SpecByID[specID]
            if specInfo and specInfo.RangeSpell then
                return specInfo.RangeSpell
            end
        end
    end

    return nil
end

-- 颜色更新 logic (Range Check)
local function UpdateColor()
    local r, g, b, a = EX_DB.colorR or 1, EX_DB.colorG or 1, EX_DB.colorB or 1, EX_DB.colorA or 1

    -- Range Check Logic
    local spell = GetRangeSpell()
    if spell and UnitExists("target") then
        local inRange = C_Spell.IsSpellInRange(spell, "target")
        if inRange == false then
            -- Out of Range
            r, g, b, a = EX_DB.rangeColorR or 1, EX_DB.rangeColorG or 0, EX_DB.rangeColorB or 0, EX_DB.rangeColorA or 1
        end
    end

    for _, t in ipairs(IndicatorFrame.textures) do
        if t:IsShown() then t:SetVertexColor(r, g, b, a) end
    end
end

-- OnUpdate Loop
local throttle = 0
IndicatorFrame:SetScript("OnUpdate", function(self, elapsed)
    throttle = throttle + elapsed
    if throttle > 0.1 then
        UpdateColor()
        throttle = 0
    end
end)

-- Visibility logic
local function UpdateIndicatorVisibility()
    if not EX_DB.enabled then
        IndicatorFrame:Hide(); return
    end

    local inInstance = ExwindTools.State.InInstance
    if EX_DB.visibility["仅副本内"] and not inInstance then
        IndicatorFrame:Hide(); return
    end

    -- Spec Check
    if ExwindTools.State.ClassID and ExwindTools.State.SpecID then
        local cName = ExwindTools.State.ClassName
        local sName = ExwindTools.State.SpecName
        local classInfo = nil
        if _G.EXDB and _G.EXDB.Classes then
            classInfo = _G.EXDB.Classes[ExwindTools.State.ClassID]
        end

        if classInfo and cName and sName then
            local colorHex = classInfo.colorHex or "FFFFFF"
            local entryName = string.format("|cff%s%s|r - %s", colorHex, classInfo.name, sName)

            -- Check if enabled in DB (Default true if nil, but defaults should handle it)
            if EX_DB.enabledSpecs and EX_DB.enabledSpecs[entryName] == false then
                IndicatorFrame:Hide(); return
            end
        end
    end

    local show = ExwindTools.State.InCombat and EX_DB.visibility["战斗中显示"] or EX_DB.visibility["战斗外显示"]
    if show then IndicatorFrame:Show() else IndicatorFrame:Hide() end
end

-- Main Refresh
local function RefreshIndicator()
    IndicatorFrame:ClearAllPoints()
    IndicatorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.offsetX, EX_DB.offsetY)
    IndicatorFrame:SetScale(EX_DB.scale or 1)

    DrawShape(EX_DB.shapeType or "SQUARE")
    UpdateColor()
    UpdateIndicatorVisibility()
end

-- Events
ExwindTools:WatchState("InCombat", EXWIND_MODULE_KEY, UpdateIndicatorVisibility)
ExwindTools:WatchState("InInstance", EXWIND_MODULE_KEY, UpdateIndicatorVisibility)
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, RefreshIndicator)

-- Spec Change Event (Since we filter by spec)
ExwindTools:WatchState("SpecID", EXWIND_MODULE_KEY, UpdateIndicatorVisibility)

-- Init
C_Timer.After(1, function()
    RefreshIndicator()
    local current = GetRangeSpell() or "无"
    -- print("|cff00ff00[ExwindTools] PlayerPosition: Ready (RangeSpell: "..tostring(current)..")|r")
end)
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
