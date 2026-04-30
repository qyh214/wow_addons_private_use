-- [[ 大秘境统计面板 (主界面) ]]
-- { Key = "ExM+InfoMythicFrame", Name = "大秘境统计面板", Desc = "全屏沉浸式的大秘境战绩与称号线进度分析面板。", Category = 2 },

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local EXState = ExwindTools.State
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

-- 1. 识别 Key
local EXWIND_MODULE_KEY = "ExM+InfoMythicFrame"

-- 2. 载入检查
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end



-- 4. Grid 布局
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 47, h = 2, label = L["大米统计面板 (Mythic Dashboard)"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 47, h = 1, label = L["全屏沉浸式的战绩分析面板。显示实时评分、称号线差距、国服排名、低保进度等。"] },
        { key = "open", type = "button", x = 2, y = 6, w = 16, h = 3, label = L["立即打开面板"] },
    }

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

-- 按钮监听
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(data)
    if data.key == "open" then
        if SlashCmdList and SlashCmdList["EXMPLUS"] then SlashCmdList["EXMPLUS"]() end
    end
end)

-- 5. 数据初始化
local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, {})



-- =========================================================
-- [模块 0] Python 导出数据区 & 配置 (严禁修改逻辑)
-- =========================================================
-- [[ PYTHON_DATA_START ]]
local EXMRH_PYTHON_DATA = {
    RankTable = {
        { label = "0.1%", score = 3792.29, count = 1007 },
        { label = "1%", score = 3571.95, count = 10070 },
        { label = "10%", score = 3225.37, count = 100704 },
        { label = "25%", score = 3000.71, count = 251761 },
        { label = "40%", score = 2752.54, count = 402817 },
        { label = "46.10%", score = 2680.00, count = 464255 },
        { label = "50%", score = 2624.29, count = 503522 },
        { label = "54.50%", score = 2560.00, count = 548839 },
        { label = "60%", score = 2336.28, count = 604226 },
        { label = "60.40%", score = 2320.00, count = 608257 },
        { label = "63.30%", score = 2200.00, count = 637459 },
        { label = "65.10%", score = 2080.00, count = 655587 },
        { label = "69.00%", score = 1840.00, count = 694861 },
        { label = "70%", score = 1740.00, count = 704930 },
        { label = "70.20%", score = 1720.00, count = 706945 },
        { label = "73.90%", score = 1480.00, count = 744208 },
        { label = "75.10%", score = 1360.00, count = 756292 },
        { label = "77.80%", score = 1240.00, count = 783482 },
    },
    TotalPopulation = 1007044,
    DataTime = "2026.04.29 08:27",
    ExwindVersion = "v26.4.29.0827",
}
-- [[ PYTHON_DATA_END ]]

local EXMRH_KeystoneAchievementList = {
    { 61253, 30 }, { 61252, 29 }, { 61251, 28 }, { 61250, 27 }, { 61249, 26 },
    { 61248, 25 }, { 61247, 24 }, { 61246, 23 }, { 61245, 22 }, { 61244, 21 },
    { 61243, 20 }, { 61242, 19 }, { 61241, 18 }, { 61240, 17 }, { 61239, 16 },
    { 61237, 15 }, { 61236, 14 }, { 61233, 12 }
}

-- =========================================================
-- [模块 1] 核心定义与视觉主题
-- =========================================================
local EXMRH                         = {}
local LSM                           = LibStub and LibStub("LibSharedMedia-3.0", true)

-- [新增] 副本简称映射表 (解决副本名过长导致 UI 遮挡问题)
local DUNGEON_SHORT_NAMES           = {
    ["zhCN"] = {
        ["奥尔达尼生态圆顶"] = "奥尔达尼生态",
        ["艾拉-卡拉，回响之城"] = "回响之城",
        ["塔扎维什：索·莉亚的宏图"] = "索·莉亚的宏图",
        ["塔扎维什：琳彩天街"] = "琳彩天街",
    },
    ["enUS"] = {
        ["The Underkeep"] = "Underkeep",
        ["Ara-Kara, City of Echoes"] = "Echoes",
        ["Tazavesh: So'leah's Gambit"] = "Gambit",
        ["Tazavesh: Streets of Wonder"] = "Streets",
    }
}

local function GetDungeonShortName(fullName)
    if not fullName then return "??" end
    local locale = GetLocale()
    if locale == "zhCN" and DUNGEON_SHORT_NAMES["zhCN"][fullName] then
        return DUNGEON_SHORT_NAMES["zhCN"][fullName]
    end
    return fullName
end

local EXWIND_THEME            = {
    --@@ 设置背景主色调
    Background  = { 0.08, 0.08, 0.1, 0.98 },
    --@@ 卡片表面亮度
    Surface     = { 1, 1, 1, 0.08 },
    --@@ 边框透明度
    DungeonName = { 0.78, 0.78, 0.78, 1 },
    Border      = { 1, 1, 1, 0.25 },
    Primary     = { 0.64, 0.19, 0.79 },
    TextMain    = { 1, 1, 1, 1 },
    TextSub     = { 0.7, 0.7, 0.75, 1 },
    Success     = { 0.13, 0.77, 0.37, 1 },
    Danger      = { 0.94, 0.27, 0.27, 1 },
    Gold        = { 1, 0.82, 0, 1 },
}

local MAIN_FONT               = ExwindTools.MAIN_FONT or STANDARD_TEXT_FONT

--@@ 主框架总宽度 (1200)
EXMRH.CustomWidth             = 1200
--@@ 主框架总高度 (720)
EXMRH.CustomHeight            = 720

local EXWIND_BACKDROP_ROUNDED = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 14,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

function EXMRH.GetClassColor()
    local _, classFile = UnitClass("player")
    local color = C_ClassColor.GetClassColor(classFile)
    return color or { r = 1, g = 1, b = 1, a = 1 }
end

local function EXMRH_GetHexColor(color)
    if not color then return "ffffffff" end
    return string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end


--获取天赋和英雄天赋
function EXMRH.GetTalentData()
    local data = { specIcon = nil, specName = " ", heroName = " " }
    local specIndex = GetSpecialization()
    if specIndex then
        local specID, name = GetSpecializationInfo(specIndex)
        if specID then
            local _, _, _, specIcon = GetSpecializationInfoForSpecID(specID)
            data.specIcon = specIcon
            data.specName = name
        end
    end
    local heroSubTreeID = C_ClassTalents.GetActiveHeroTalentSpec()
    local configID = C_ClassTalents.GetActiveConfigID()
    if heroSubTreeID and configID then
        local heroInfo = C_Traits.GetSubTreeInfo(configID, heroSubTreeID)
        if heroInfo then data.heroName = heroInfo.name end
    end
    return data
end

function EXMRH.GetLootInfo(level)
    local rewardIlvl = C_MythicPlus.GetRewardLevelFromKeystoneLevel(level)
    if not rewardIlvl or rewardIlvl == 0 then return "-", L["无奖励"], 0 end
    local lootMap = {
        [259] = { name = L["英雄 1/6"], star = 0 },
        [263] = { name = L["英雄 2/6"], star = 0 },
        [266] = { name = L["英雄 3/6"], star = 0 },
        [269] = { name = L["英雄 4/6"], star = 0 },
        [272] = { name = L["神话 1/6"], star = 1 },
        -- [276] = { name = "神话 2/6", star = 2 },
        -- [279] = { name = "神话 3/6", star = 3 },
        -- [282] = { name = "神话 4/6", star = 4 },
    }
    local data = lootMap[rewardIlvl]
    if data then return rewardIlvl, data.name, data.star else return rewardIlvl, L["未知阶位"], 0 end
end

-- 分数排名计算逻辑
function EXMRH.CalculateRank(score)
    local tableData = EXMRH_PYTHON_DATA.RankTable
    local totalPop = EXMRH_PYTHON_DATA.TotalPopulation

    -- @@ 如果分数超过全服第一名（或0.1%线）
    if score >= tableData[1].score then
        return tableData[1].label:gsub("%%", ""), tableData[1].count, 100, nil
    end

    -- @@ 遍历高密度表寻找区间
    for i = 1, #tableData - 1 do
        local high = tableData[i]
        local low = tableData[i + 1]

        if score <= high.score and score >= low.score then
            local ratio = (score - low.score) / (high.score - low.score)
            local highPct = tonumber((high.label:gsub("%%", "")))
            local lowPct = tonumber((low.label:gsub("%%", "")))
            local currentPct = lowPct - (lowPct - highPct) * ratio
            local currentRank = math.floor(low.count - (low.count - high.count) * ratio)

            return string.format("%.2f", currentPct), currentRank, ratio * 100, high
        end
    end

    -- 防止意外情况
    return "100.00", totalPop, 0, nil
end

-- =========================================================
-- [模块 2] 主框架布局
-- =========================================================
function EXMRH.CreateStandaloneFrame()
    if _G["EXMRH_MainFrame"] then return end

    local f = CreateFrame("Frame", "EXMRH_MainFrame", UIParent, "BackdropTemplate")
    f:SetSize(EXMRH.CustomWidth, EXMRH.CustomHeight)
    f:SetPoint("CENTER", 0, 0); f:SetMovable(true); f:EnableMouse(true)
    f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop",
        f.StopMovingOrSizing)

    --@@ 设置框架层级 (DIALOG)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(50)

    f:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
    f:SetBackdropColor(unpack(EXWIND_THEME.Background))
    f:SetBackdropBorderColor(0, 0, 0, 0.8)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -8, -8)

    tinsert(UISpecialFrames, "EXMRH_MainFrame")
    EXMRH.Main = CreateFrame("Frame", nil, f); EXMRH.Main:SetAllPoints()

    local footer = CreateFrame("Frame", "EXWIND_Footer", f, "BackdropTemplate")
    footer:SetPoint("BOTTOMLEFT", 20, 20); footer:SetPoint("BOTTOMRIGHT", -20, 20); footer:SetHeight(50)
    footer:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
    footer:SetBackdropColor(1, 1, 1, 0.04); footer:SetBackdropBorderColor(unpack(EXWIND_THEME.Border))

    local function CreateFootBtn(name, xOfs)
        local btn = CreateFrame("Button", nil, footer, "BackdropTemplate")
        btn:SetSize(170, 32); btn:SetPoint("RIGHT", xOfs, 0)
        btn:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
        btn:SetBackdropColor(1, 1, 1, 0.08); btn:SetBackdropBorderColor(unpack(EXWIND_THEME.Border))
        local t = btn:CreateFontString(nil, "OVERLAY")
        t:SetFont(MAIN_FONT, 13, "THINOUTLINE"); t:SetPoint("CENTER"); t:SetText(name); t:SetTextColor(unpack(
            EXWIND_THEME
            .TextMain))
        btn:SetScript("OnEnter", function(self) self:SetBackdropColor(1, 1, 1, 0.15) end)
        btn:SetScript("OnLeave", function(self) self:SetBackdropColor(1, 1, 1, 0.08) end)
        return btn
    end

    -- 调用 MythicRunInfo
    EXMRH.BtnHistory = CreateFootBtn(L["本赛季 详细记录"], -185)
    EXMRH.BtnHistory:SetScript("OnClick", function()
        if _G.EXMYRUN and _G.EXMYRUN.ToggleWindow then
            _G.EXMYRUN:ToggleWindow()
        elseif SlashCmdList and SlashCmdList["EXMYRUN"] then
            SlashCmdList["EXMYRUN"]()
        end
    end)

    EXMRH.BtnStats = CreateFootBtn(L["统计分析 (未开启)"], -10)

    local versionText = footer:CreateFontString(nil, "OVERLAY")
    versionText:SetFont(MAIN_FONT, 14, "THINOUTLINE"); versionText:SetPoint("LEFT", 20, 0); versionText:SetTextColor(
        unpack(
            EXWIND_THEME.TextSub))
    -- 全服玩家人口数简写W
    local pop = tonumber(EXMRH_PYTHON_DATA.TotalPopulation) or 0
    local formattedPop = pop >= 10000 and string.format("%.1fW", pop / 10000) or tostring(pop)

    --@@ 底部信息
    versionText:SetText(string.format(L["EXWIND 大秘境统计 v%s  |  称号数据更新于: %s  |  国服玩家总数:%s  | 数据来源:Raider.io"],
        EXMRH_PYTHON_DATA.ExwindVersion, EXMRH_PYTHON_DATA.DataTime, formattedPop))

    EXMRH.InitSubPanels()
    f:Hide()
    SlashCmdList["EXMPLUS"] = function()
        if f:IsShown() then
            f:Hide()
        else
            f:Show(); EXMRH.UpdateAllData()
        end
    end
    SLASH_EXMPLUS1 = "/exm"
end

-- =========================================================
-- [模块 3] 上方名片区 (布局微调 & 模块正常比例)
-- =========================================================
function EXMRH.InitHeader()
    local header = CreateFrame("Frame", "EXWIND_Header", EXMRH.Main, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 20, -20); header:SetPoint("TOPRIGHT", -20, -20); header:SetHeight(150)
    header:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
    header:SetBackdropColor(1, 1, 1, 0.06); header:SetBackdropBorderColor(unpack(EXWIND_THEME.Border))

    local classColor = EXMRH.GetClassColor()
    --=======================================================================================
    ----------------------------------------头像框模块--------------------------------------
    --=======================================================================================
    -- 1. 头像框
    local portraitFrame = CreateFrame("Frame", "EXWIND_AvatarBox", header, "BackdropTemplate")
    portraitFrame:SetSize(120, 120); portraitFrame:SetPoint("LEFT", 17, 0)
    portraitFrame:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14, tile = true })
    EXMRH.AvatarFrame = portraitFrame

    --@@ 玩家模组
    local model = CreateFrame("PlayerModel", nil, portraitFrame)
    model:SetPoint("TOPLEFT", 4, -4); model:SetPoint("BOTTOMRIGHT", -4, 4)
    model:SetUnit("player")
    model:SetPortraitZoom(0.9) --@@ 玩家模组缩放比例
    model:SetAlpha(0.95); EXMRH.PlayerModel = model

    -- 装等
    local ilvlFrame = CreateFrame("Frame", nil, portraitFrame, "BackdropTemplate")
    ilvlFrame:SetSize(58, 26); ilvlFrame:SetPoint("BOTTOMRIGHT", portraitFrame, "BOTTOMRIGHT", 6, -6)
    ilvlFrame:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
    ilvlFrame:SetBackdropColor(0, 0, 0, 0.95)
    ilvlFrame:SetFrameLevel(portraitFrame:GetFrameLevel() + 25)
    EXMRH.IlvlFrame = ilvlFrame

    local ilvlStr = ilvlFrame:CreateFontString(nil, "OVERLAY")
    ilvlStr:SetFont(MAIN_FONT, 16, "THINOUTLINE"); ilvlStr:SetPoint("CENTER", 0, 0); ilvlStr:SetTextColor(1, 1, 1)
    EXMRH.IlvlDisplay = ilvlStr
    --=======================================================================================
    ----------------------------------------玩家名称模块--------------------------------------
    --=======================================================================================
    -- 天赋图标
    local specIcon = header:CreateTexture(nil, "OVERLAY")
    --@@ 天赋位置锚点
    specIcon:SetSize(50, 50); specIcon:SetPoint("LEFT", portraitFrame, "RIGHT", 20, 26)
    specIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
    EXMRH.SpecIcon = specIcon

    -- 角色名称
    local nameStr = header:CreateFontString(nil, "OVERLAY")
    --@@ 玩家姓名
    nameStr:SetFont(MAIN_FONT, 44, "THINOUTLINE"); nameStr:SetPoint("LEFT", specIcon, "RIGHT", 5, -8)
    EXMRH.NameStr = nameStr

    -- 天赋信息
    local infoStr = header:CreateFontString(nil, "OVERLAY")
    --@@ 天赋文字
    infoStr:SetFont(MAIN_FONT, 18, "THINOUTLINE"); infoStr:SetPoint("TOPLEFT", specIcon, "BOTTOMLEFT", 0, -8)
    infoStr:SetTextColor(unpack(EXWIND_THEME.TextMain)); EXMRH.PlayerInfoDisplay = infoStr

    -- 3. 饰品框
    local function CreateTrinketFrame(xOfs)
        local btn = CreateFrame("Button", nil, header, "BackdropTemplate")
        --@@ 饰品位置
        btn:SetSize(142, 30); btn:SetPoint("TOPLEFT", infoStr, "BOTTOMLEFT", xOfs, -5)
        btn:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
        btn:SetBackdropColor(0, 0, 0, 0.5); btn:SetBackdropBorderColor(unpack(EXWIND_THEME.Border))

        local ic = btn:CreateTexture(nil, "OVERLAY"); ic:SetSize(22, 22); ic:SetPoint("LEFT", 4, 0.5)
        ic:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
        local tx = btn:CreateFontString(nil, "OVERLAY")
        tx:SetFont(MAIN_FONT, 14, "THINOUTLINE"); tx:SetPoint("LEFT", ic, "RIGHT", 3, 0)
        tx:SetWidth(120); tx:SetJustifyH("LEFT"); tx:SetWordWrap(false)

        btn:SetScript("OnEnter",
            function(self)
                if self.itemID then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetHyperlink(self.itemID); GameTooltip:Show()
                end
            end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return btn, ic, tx
    end
    EXMRH.T1, EXMRH.T1I, EXMRH.T1T = CreateTrinketFrame(-2); EXMRH.T1.slotID = 13
    EXMRH.T2, EXMRH.T2I, EXMRH.T2T = CreateTrinketFrame(138); EXMRH.T2.slotID = 14
    --=======================================================================================
    ----------------------------------------赛季评分模块--------------------------------------
    --=======================================================================================
    -- 4. 评分核心
    local scoreGroup = CreateFrame("Frame", nil, header); scoreGroup:SetSize(300, 100)
    scoreGroup:SetPoint("CENTER", 40, -18)

    local sLabel = scoreGroup:CreateFontString(nil, "OVERLAY")
    --@@ 赛季评分字体
    sLabel:SetFont(MAIN_FONT, 18, "THINOUTLINE"); sLabel:SetPoint("TOPLEFT", 0, 23); sLabel:SetTextColor(unpack(
        EXWIND_THEME
        .TextSub)); sLabel:SetText(L["赛 季 评 分"])
    --@@ 分数字体
    EXMRH.ScoreText = scoreGroup:CreateFontString(nil, "OVERLAY")
    EXMRH.ScoreText:SetFont(MAIN_FONT, 72, "THICKOUTLINE"); EXMRH.ScoreText:SetPoint("TOPLEFT", sLabel, "BOTTOMLEFT", 18,
        -6)
    --@@ 前多少%
    EXMRH.PctText = scoreGroup:CreateFontString(nil, "OVERLAY")
    EXMRH.PctText:SetFont(MAIN_FONT, 18, "OUTLINE"); EXMRH.PctText:SetPoint("TOPLEFT", EXMRH.ScoreText, "BOTTOMLEFT",
        -20, -2)
    EXMRH.PctText:SetTextColor(unpack(EXWIND_THEME.Success))
    --@@ 国服排名
    EXMRH.RankNumText = scoreGroup:CreateFontString(nil, "OVERLAY")
    EXMRH.RankNumText:SetFont(MAIN_FONT, 16, "OUTLINE"); EXMRH.RankNumText:SetPoint("TOPRIGHT", EXMRH.ScoreText,
        "BOTTOMRIGHT", 20, -2)
    EXMRH.RankNumText:SetTextColor(unpack(EXWIND_THEME.TextSub))

    --=======================================================================================
    ----------------------------------------称号计时条模块------------------------------------
    --=======================================================================================
    -- 5. 称号进度与纹章
    local barGroup = CreateFrame("Frame", nil, header);
    --@@ 模块位置
    barGroup:SetSize(260, 110); barGroup:SetPoint("CENTER", 275, -2)

    EXMRH.NextRankText = barGroup:CreateFontString(nil, "OVERLAY")
    --@@ 距离下个阶段(计时条上文字)
    EXMRH.NextRankText:SetFont(MAIN_FONT, 18, "OUTLINE");
    EXMRH.NextRankText:SetPoint("TOPLEFT", 0, -2);
    EXMRH.NextRankText:SetTextColor(unpack(EXWIND_THEME.Gold))

    --@@ 计时条背景
    local barBG = CreateFrame("Frame", nil, barGroup, "BackdropTemplate")
    barBG:SetSize(270, 30);
    barBG:SetPoint("TOPLEFT", 0, -28);
    barBG:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
    barBG:SetBackdropColor(0, 0, 0, 0.6);
    barBG:SetBackdropBorderColor(unpack(EXWIND_THEME.Border))

    --@@ 计时条
    EXMRH.RankBar = CreateFrame("StatusBar", nil, barBG);
    -- 限制前景在背景框内：通过内缩 2 像素避免覆盖边框
    EXMRH.RankBar:SetPoint("TOPLEFT", barBG, "TOPLEFT", 5, -5)
    EXMRH.RankBar:SetPoint("BOTTOMRIGHT", barBG, "BOTTOMRIGHT", -2, 5)

    -- 设置进度条贴图（使用平滑材质）并防止溢出
    EXMRH.RankBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    local EXWIND_BarTex = EXMRH.RankBar:GetStatusBarTexture()
    EXWIND_BarTex:SetHorizTile(false)
    EXWIND_BarTex:SetVertTile(false)
    --@@ 计时条文字
    EXMRH.RankBarText = EXMRH.RankBar:CreateFontString(nil, "OVERLAY");
    EXMRH.RankBarText:SetFont(MAIN_FONT, 14, "OUTLINE");
    EXMRH.RankBarText:SetPoint("CENTER")

    --@@ 称号线文字
    EXMRH.TitleLineText = barGroup:CreateFontString(nil, "OVERLAY")
    EXMRH.TitleLineText:SetFont(MAIN_FONT, 14, "OUTLINE");
    EXMRH.TitleLineText:SetPoint("TOPLEFT", barBG, "BOTTOMLEFT", 0, -6);
    EXMRH.TitleLineText:SetTextColor(1, 0.92, 0.22)

    local function CreateCrestFrame(id, xOfs)
        local cF = CreateFrame("Frame", nil, barGroup, "BackdropTemplate")
        cF:SetSize(130, 30);
        cF:SetPoint("TOPLEFT", EXMRH.TitleLineText, "BOTTOMLEFT", xOfs, -5)
        cF:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
        cF:SetBackdropColor(0, 0, 0, 0.5);
        cF:SetBackdropBorderColor(unpack(EXWIND_THEME.Border))
        --纹章图标设置
        local ic = cF:CreateTexture(nil, "OVERLAY");
        ic:SetSize(25, 25);
        ic:SetPoint("LEFT", 5, 0)
        ic:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
        --纹章文字设置
        local tx = cF:CreateFontString(nil, "OVERLAY");
        tx:SetFont(MAIN_FONT, 15, "THINOUTLINE");
        tx:SetPoint("CENTER", cF, "CENTER", 5, 0)

        cF:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetCurrencyByID(id);
            GameTooltip:Show()
        end)
        cF:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return ic, tx
    end
    --tooltip和FRAME的X轴参数
    EXMRH.C1I, EXMRH.C1T = CreateCrestFrame(3345, 0);
    EXMRH.C2I, EXMRH.C2T = CreateCrestFrame(3347, 140)
    --=======================================================================================
    ----------------------------------------最右侧卡片元素模块--------------------------------
    --=======================================================================================
    -- 6. 最右侧汇总卡片 (使用 Factory 池化)
    EXMRH.MaxKeyCard = ExwindFactory:Acquire("IconTextCard", header)
    EXMRH.MaxKeyCard:SetPoint("TOPRIGHT", -10, -5)
    EXMRH.MaxKeyCard.icon:SetTexture([[Interface\AddOns\ExwindTools\Textures\EJ-UI\M1.png]])
    EXMRH.MaxKeyCard.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
    EXMRH.MaxKeyCard.title:SetFont(MAIN_FONT, 15, "OUTLINE")
    EXMRH.MaxKeyCard.title:SetTextColor(0.76, 0.76, 0.76)
    EXMRH.MaxKeyCard.title:SetText(L["最高钥石"])
    EXMRH.MaxKeyCard.value:SetFont(MAIN_FONT, 32, "THINOUTLINE")
    EXMRH.MaxKeyCard.value:SetTextColor(unpack(EXWIND_THEME.TextMain))
    EXMRH.MaxKeyText = EXMRH.MaxKeyCard.value

    EXMRH.TotalRunsCard = ExwindFactory:Acquire("IconTextCard", header)
    EXMRH.TotalRunsCard:SetPoint("TOPRIGHT", -10, -75)
    EXMRH.TotalRunsCard.icon:SetTexture([[Interface\AddOns\ExwindTools\Textures\EJ-UI\M2.png]])
    EXMRH.TotalRunsCard.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
    EXMRH.TotalRunsCard.title:SetFont(MAIN_FONT, 15, "OUTLINE")
    EXMRH.TotalRunsCard.title:SetTextColor(0.76, 0.76, 0.76)
    EXMRH.TotalRunsCard.title:SetText(L["赛季总计"])
    EXMRH.TotalRunsCard.value:SetFont(MAIN_FONT, 32, "THINOUTLINE")
    EXMRH.TotalRunsCard.value:SetTextColor(unpack(EXWIND_THEME.TextMain))
    EXMRH.TotalRunsText = EXMRH.TotalRunsCard.value
end

-- =========================================================
-- [模块 4] 左下大米统计模块
-- =========================================================
function EXMRH.InitStatTable()
    local tableFrame = CreateFrame("Frame", "EXWIND_TableBox", EXMRH.Main, "BackdropTemplate")
    --@@
    tableFrame:SetPoint("TOPLEFT", 20, -185); tableFrame:SetPoint("BOTTOMLEFT", 20, 85); tableFrame:SetWidth(816)
    tableFrame:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
    tableFrame:SetBackdropColor(0, 0, 0, 0); -- [关键] 清空容器原背景，由子层自行绘制
    tableFrame:SetBackdropBorderColor(unpack(EXWIND_THEME.Border))
    -- 提升边框层级，使其成为真正的遮照边缘
    tableFrame:SetFrameLevel(EXMRH.Main:GetFrameLevel() + 10)

    local header = CreateFrame("Frame", nil, tableFrame, "BackdropTemplate");
    header:SetPoint("TOPLEFT", 1, -1); header:SetPoint("TOPRIGHT", -1, -1);
    header:SetHeight(44)
    -- [美化] 顶部标题行背景：带圆角的深色背景
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    header:SetBackdropColor(1, 1, 1, 0.05)
    header:SetBackdropBorderColor(0, 0, 0, 0)
    header:SetFrameLevel(tableFrame:GetFrameLevel() - 1)

    local function ColLabel(txt, x, w, justify)
        local fs = header:CreateFontString(nil, "OVERLAY")
        --@@ 标题文字大小 样式
        fs:SetFont(MAIN_FONT, 16, "OUTLINE"); fs:SetPoint("LEFT", x, 0); fs:SetWidth(w); fs:SetJustifyH(justify or
            "CENTER")
        fs:SetText(txt); fs:SetTextColor(unpack(EXWIND_THEME.TextSub))
    end
    --@@ 标题文字,X轴,宽度,对齐方式
    ColLabel(L["副本名称"], 60, 150, "LEFT"); ColLabel(L["最高层"], 207, 60); ColLabel(L["评分"], 280, 60); ColLabel(
    L["(赛季) 总计/限时/超时"], 380,
        200, "LEFT"); ColLabel(L["(本周) 总计/限时/超时"], 570, 200, "LEFT")

    EXMRH.StatRows = {}
    for i = 1, 9 do
        local r = ExwindFactory:Acquire("StatRow", tableFrame)
        r:SetSize(807.5, 45)

        if i == 9 then
            r:SetPoint("TOPLEFT", 4, -41.3 - 8 * 45)
            -- [核心优化] 汇总行采用独立背景容器，实现“遮照”级别的圆角填满
            if not r.SummaryBG then
                r.SummaryBG = CreateFrame("Frame", nil, r, "BackdropTemplate")
                -- 核心逻辑：锚点直接穿透到父容器的最底部，由父边框负责裁切
                r.SummaryBG:SetPoint("TOPLEFT", r, "TOPLEFT", -3, 5)
                r.SummaryBG:SetPoint("BOTTOMRIGHT", tableFrame, "BOTTOMRIGHT", -1, 1)
                r.SummaryBG:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8X8",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    edgeSize = 14,
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                })
                r.SummaryBG:SetBackdropBorderColor(0, 0, 0, 0)            -- 隐藏自己的边框
                r.SummaryBG:SetFrameLevel(tableFrame:GetFrameLevel() - 2) -- 位于最底层

                -- 应用深蓝科技渐变
                local bgTex = r.SummaryBG.Center
                if bgTex then
                    bgTex:SetGradient("HORIZONTAL", CreateColor(0.05, 0.15, 0.3, 0.6), CreateColor(0.02, 0.05, 0.1, 0.1))
                end

                -- [美化] 在汇总行上方添加一条内缩的分隔线
                r.TopLine = r.SummaryBG:CreateTexture(nil, "OVERLAY")
                r.TopLine:SetHeight(1)
                r.TopLine:SetPoint("TOPLEFT", 10, -5)
                r.TopLine:SetPoint("TOPRIGHT", -10, -5)
                r.TopLine:SetColorTexture(1, 1, 1, 0.2)
            end
            r.bg:Hide() -- 隐藏旧贴图
        else
            r:SetPoint("TOPLEFT", 4, -41.3 - (i - 1) * 45)
            r.bg:SetColorTexture(1, 1, 1, (i % 2 == 0 and 0.025 or 0))
            -- [修复] 普通行背景严禁超出边框感应区
            r.bg:ClearAllPoints()
            r.bg:SetPoint("TOPLEFT", r, "TOPLEFT", 4, 0)
            r.bg:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", -4, 0)
        end

        -- 样式化
        r.name:SetFont(MAIN_FONT, 20, "THICKOUTLINE")
        r.name:SetTextColor(unpack(EXWIND_THEME.DungeonName))

        -- 最高层数 (Cell 1)
        r.max = r.cells[1]
        r.max:SetFont(MAIN_FONT, 18, "THINOUTLINE")
        r.max:SetPoint("LEFT", 200, 0); r.max:SetWidth(60); r.max:SetJustifyH("CENTER")

        -- 副本评分 (Cell 2)
        r.pts = r.cells[2]
        r.pts:SetFont(MAIN_FONT, 18, "THINOUTLINE")
        r.pts:SetPoint("LEFT", 275, 0); r.pts:SetWidth(60); r.pts:SetJustifyH("CENTER")

        local function SetupStatGroup(startIdx, x)
            local t = r.cells[startIdx]
            t:SetFont(MAIN_FONT, 20, "THINOUTLINE"); t:SetPoint("LEFT", x + 30, 0); t:SetTextColor(unpack(EXWIND_THEME
                .TextMain))

            local l = r.cells[startIdx + 1]
            l:SetFont(MAIN_FONT, 20, "THINOUTLINE"); l:SetPoint("LEFT", x + 80, 0); l:SetTextColor(unpack(EXWIND_THEME
                .Success))

            local o = r.cells[startIdx + 2]
            o:SetFont(MAIN_FONT, 20, "THINOUTLINE"); o:SetPoint("LEFT", x + 130, 0); o:SetTextColor(unpack(EXWIND_THEME
                .Danger))

            return t, l, o
        end

        r.s_total, r.s_timed, r.s_over = SetupStatGroup(3, 380)
        r.w_total, r.w_timed, r.w_over = SetupStatGroup(6, 580)

        EXMRH.StatRows[i] = r
    end
end

-- =========================================================
-- [模块 5] 右侧记录面板
-- =========================================================
function EXMRH.InitRightPanel()
    local rf = CreateFrame("Frame", "EXWIND_RightSide", EXMRH.Main, "BackdropTemplate")
    --@@ 右下模块宽度
    rf:SetPoint("TOPRIGHT", -20, -185); rf:SetPoint("BOTTOMRIGHT", -20, 85); rf:SetWidth(330)
    rf:SetBackdrop(EXWIND_BACKDROP_ROUNDED)
    rf:SetBackdropColor(unpack(EXWIND_THEME.Surface)); rf:SetBackdropBorderColor(unpack(EXWIND_THEME.Border))
    --=======================================================================================
    ----------------------------------------三个低保栏位逻辑----------------------------------
    --=======================================================================================
    EXMRH.Slots = {}
    --@@ 三个低保栏位宽度
    local sw = (330 - 40) / 3
    for i = 1, 3 do
        local s = CreateFrame("Frame", nil, rf, "BackdropTemplate")
        --@@ 三个低保栏位高度
        s:SetSize(sw, 70); s:SetPoint("TOPLEFT", 15 + (i - 1) * (sw + 5), -15)
        --@@ 低保栏位背景样式/颜色
        s:SetBackdrop(EXWIND_BACKDROP_ROUNDED); s:SetBackdropColor(1, 1, 1, 0.06); s:SetBackdropBorderColor(unpack(
            EXWIND_THEME.Border))
        --@@ 低保栏位装等
        s.ilvl = s:CreateFontString(nil, "OVERLAY"); s.ilvl:SetFont(MAIN_FONT, 24, "OUTLINE"); s.ilvl:SetPoint(
            "CENTER", 0, 6); s.ilvl:SetTextColor(0.64, 0.21, 0.93, 1)
        --@@ 低保栏位神话等级
        s.rank = s:CreateFontString(nil, "OVERLAY"); s.rank:SetFont(MAIN_FONT, 14, "THINOUTLINE"); s.rank:SetPoint(
            "BOTTOM",
            0, 10); s.rank:SetTextColor(1, 0.5, 0, 1)
        EXMRH.Slots[i] = s
    end

    local hLabel = rf:CreateFontString(nil, "OVERLAY"); hLabel:SetFont(MAIN_FONT, 12, "THINOUTLINE"); hLabel:SetPoint(
        "TOPLEFT", 15, -100); hLabel:SetTextColor(unpack(EXWIND_THEME.TextSub)); hLabel:SetText(L["本周大秘境记录(前8)"])
    --=======================================================================================
    ----------------------------------------八个低保副本记录----------------------------------
    --=======================================================================================
    EXMRH.RunRows = {}
    for i = 1, 8 do
        local r = ExwindFactory:Acquire("RunRow", rf)
        r:SetSize(299, 40); r:SetPoint("TOPLEFT", 17, -120 - (i - 1) * 38)
        r:SetBackdropColor(1, 1, 1, 0.03)

        if i == 1 or i == 4 or i == 8 then
            if not r.HighlightBG then
                r.HighlightBG = r:CreateTexture(nil, "BACKGROUND")
                r.HighlightBG:SetPoint("TOPLEFT", 3, -3); r.HighlightBG:SetPoint("BOTTOMRIGHT", -3, 3)
                r.HighlightBG:SetColorTexture(1, 1, 1, 0.12)
            end
            r.HighlightBG:Hide()
        end

        r.text:SetFont(MAIN_FONT, 16, "OUTLINE")
        r.text:SetWidth(155); r.text:SetJustifyH("LEFT")
        r.ilvl:SetFont(MAIN_FONT, 14, "THINOUTLINE")
        r.ilvl:SetTextColor(0.64, 0.21, 0.93, 1)

        EXMRH.RunRows[i] = r
    end
end

-- =========================================================
-- [模块 6] 更新逻辑 (动态职业染色)
-- =========================================================
local function FormatRank(n)
    if not n or n == 0 then return "-" end
    if n >= 10000 then return string.format("%.1fW", n / 10000) else return tostring(n) end
end

function EXMRH.UpdateAllData()
    if not _G["EXMRH_MainFrame"] or not _G["EXMRH_MainFrame"]:IsShown() then return end

    local score = C_ChallengeMode.GetOverallDungeonScore() or 0
    local scoreColor = C_ChallengeMode.GetDungeonScoreRarityColor(score)

    -- [Fix] 这里的 SetFont 必须指向绝对安全的路径，且不需要条件判断
    EXMRH.ScoreText:SetFont(MAIN_FONT, 72, "THICKOUTLINE")
    EXMRH.ScoreText:SetText(score);
    if scoreColor then
        EXMRH.ScoreText:SetTextColor(scoreColor.r, scoreColor.g, scoreColor.b)
    end

    local classCol = EXMRH.GetClassColor()
    --@@ 强制重置玩家名称及职业颜色，防止消失
    EXMRH.NameStr:SetText(UnitName("player"))
    EXMRH.NameStr:SetTextColor(classCol.r, classCol.g, classCol.b)
    EXMRH.AvatarFrame:SetBackdropBorderColor(classCol.r, classCol.g, classCol.b, 1)
    EXMRH.IlvlFrame:SetBackdropBorderColor(classCol.r, classCol.g, classCol.b, 1)

    local tal = EXMRH.GetTalentData(); if tal.specIcon then EXMRH.SpecIcon:SetTexture(tal.specIcon) end
    local raceName = UnitRace("player")
    local heroPart = (tal.heroName and tal.heroName ~= " ") and string.format(" • |cFFFFD100%s|r", tal.heroName) or ""
    EXMRH.PlayerInfoDisplay:SetText(string.format("%s • %s%s", raceName or L["未知种族"], tal.specName or "", heroPart))

    local _, eq = GetAverageItemLevel(); EXMRH.IlvlDisplay:SetText(string.format("%.1f", eq))

    -- 饰品更新
    local function UpdateItem(slotID, ic, tx, btn)
        local link = GetInventoryItemLink("player", slotID)
        if link then
            local itemName, _, quality, _, _, _, _, _, _, itemTexture = GetItemInfo(link)
            if itemName then
                tx:SetText(itemName)
                local r, g, b = GetItemQualityColor(quality or 4)
                tx:SetTextColor(r, g, b)
                ic:SetTexture(itemTexture)
            else
                tx:SetText(L["加载中..."])
                tx:SetTextColor(0.5, 0.5, 0.5)
            end
            btn.itemID = link
        else
            ic:SetTexture(nil); tx:SetText(L["未装备"]); tx:SetTextColor(0.5, 0.5, 0.5); btn.itemID = nil
        end
    end
    UpdateItem(13, EXMRH.T1I, EXMRH.T1T, EXMRH.T1); UpdateItem(14, EXMRH.T2I, EXMRH.T2T, EXMRH.T2)

    local summary = { s_tot = 0, s_tim = 0, s_ovr = 0, w_tot = 0, w_tim = 0, w_ovr = 0, minMax = 99 }
    local sRuns = C_MythicPlus.GetRunHistory(true, true, true)
    local wRuns = C_MythicPlus.GetRunHistory(false, true, true)

    local dData = {}
    local function Process(runs, prefix)
        if not runs then return end
        for _, r in ipairs(runs) do
            local _, _, tl = C_ChallengeMode.GetMapUIInfo(r.mapChallengeModeID)
            local isT = (r.durationSec > 0 and tl and tl > 0 and r.durationSec <= tl)
            if not dData[r.mapChallengeModeID] then dData[r.mapChallengeModeID] = { s_tot = 0, s_tim = 0, s_ovr = 0, w_tot = 0, w_tim = 0, w_ovr = 0 } end
            local d = dData[r.mapChallengeModeID]; d[prefix .. "_tot"] = d[prefix .. "_tot"] + 1; summary[prefix .. "_tot"] =
                summary[prefix .. "_tot"] + 1
            if isT then
                d[prefix .. "_tim"] = d[prefix .. "_tim"] + 1; summary[prefix .. "_tim"] = summary[prefix .. "_tim"] + 1
            else
                d[prefix .. "_ovr"] = d[prefix .. "_ovr"] + 1; summary[prefix .. "_ovr"] = summary[prefix .. "_ovr"] + 1
            end
        end
    end
    Process(sRuns, "s"); Process(wRuns, "w")
    EXMRH.TotalRunsText:SetText(summary.s_tot)

    local mT = C_ChallengeMode.GetMapTable()
    if mT then
        for i, mID in ipairs(mT) do
            if EXMRH.StatRows[i] then
                local n, _, _, tex = C_ChallengeMode.GetMapUIInfo(mID); local d = dData[mID] or
                    { s_tot = 0, s_tim = 0, s_ovr = 0, w_tot = 0, w_tim = 0, w_ovr = 0 }
                local inT, overT = C_MythicPlus.GetSeasonBestForMap(mID); local bD = inT or overT
                local ms, ml = bD and bD.dungeonScore or 0, bD and bD.level or 0
                if ml < summary.minMax then summary.minMax = ml end
                local r = EXMRH.StatRows[i]
                local lCol = C_ChallengeMode.GetKeystoneLevelRarityColor(ml); local sCol = C_ChallengeMode
                    .GetSpecificDungeonScoreRarityColor(ms)
                r.icon:SetTexture(tex);
                r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
                r.name:SetText(GetDungeonShortName(n)); r.max:SetText("+" .. ml); r.pts:SetText(ms)
                if lCol then r.max:SetTextColor(lCol.r, lCol.g, lCol.b) end; if sCol then
                    r.pts:SetTextColor(sCol.r,
                        sCol.g, sCol.b)
                end
                r.s_total:SetText(d.s_tot); r.s_timed:SetText(d.s_tim); r.s_over:SetText(d.s_ovr)
                r.w_total:SetText(d.w_tot); r.w_timed:SetText(d.w_tim); r.w_over:SetText(d.w_ovr)
            end
        end
        local rowSum = EXMRH.StatRows[9]; rowSum.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09");
        rowSum.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
        rowSum.name:SetText("|cff00d9ff" .. L["统计汇总"] .. "|r")
        rowSum.name:SetFont(MAIN_FONT, 20, "THICKOUTLINE")
        rowSum.max:SetText(summary.minMax == 99 and "0" or summary.minMax); rowSum.pts:SetText("-")
        rowSum.s_total:SetText(summary.s_tot); rowSum.s_timed:SetText(summary.s_tim); rowSum.s_over:SetText(summary
            .s_ovr)
        rowSum.w_total:SetText(summary.w_tot); rowSum.w_timed:SetText(summary.w_tim); rowSum.w_over:SetText(summary
            .w_ovr)
    end
    --=======================================================================================
    ----------------------------------------称号进度计算模块------------------------------------
    --=======================================================================================
    -- 1. 获取精准排名数据
    local pct, rk, _, _ = EXMRH.CalculateRank(score)
    EXMRH.PctText:SetText(string.format(L["前 %s%%"], pct))
    EXMRH.RankNumText:SetText(string.format(L["第 %s 名"], FormatRank(rk)))

    -- 2. 核心逻辑 (50% -> 25% -> 10% -> 1% -> 0.1%)
    local EXWIND_Milestones = { "50%", "25%", "10%", "1%", "0.1%" }
    local EXWIND_NextTarget = nil
    local currentPctNum = tonumber(pct) or 100

    -- 按照从易到难的顺序寻找第一个百分比数字小于当前百分比的里程碑
    for _, label in ipairs(EXWIND_Milestones) do
        local milestonePct = tonumber((label:gsub("%%", "")))
        if currentPctNum > milestonePct then
            -- 找到第一个比自己现在的百分比更小的（即更靠前的里程碑）
            for _, entry in ipairs(EXMRH_PYTHON_DATA.RankTable) do
                if entry.label == label then
                    EXWIND_NextTarget = entry
                    break
                end
            end
            if EXWIND_NextTarget then break end -- 找到最近的目标后立即跳出
        end
    end

    -- 3. 更新显示文字
    if EXWIND_NextTarget then
        EXMRH.NextRankText:SetText(string.format(L["距离前 |cFFFFFFFF%s|r 还差 |cFF00FF00%.1f|r 分"],
            EXWIND_NextTarget.label, EXWIND_NextTarget.score - score))
    else
        -- 已经冲进 0.1%
        EXMRH.NextRankText:SetText("|cFFFFD100" .. L["恭喜你 已经是称号玩家!"] .. "|r")
    end

    -- 4. 修复：进度条渲染逻辑
    local realVal = 100 - currentPctNum -- 越接近 0.1%，进度条越满
    EXMRH.RankBar:SetMinMaxValues(0, 100)
    EXMRH.RankBar:SetValue(realVal)
    EXMRH.RankBar:SetStatusBarColor(classCol.r, classCol.g, classCol.b) -- 职业染色
    EXMRH.RankBarText:SetText(string.format("%.2f%%", realVal))         -- 进度条中间显示百分比

    -- 更新称号线底下的静态文字
    EXMRH.TitleLineText:SetText(L["当前称号线 (0.1%): "] .. EXMRH_PYTHON_DATA.RankTable[1].score)
    --=======================================================================================
    ----------------------------------------坚韧钥石及低保模块--------------------------------
    ---=======================================================================================

    local hl = 0; for _, ach in ipairs(EXMRH_KeystoneAchievementList) do
        if select(13, GetAchievementInfo(ach[1])) then
            hl = ach[2]; break
        end
    end
    local mc = C_ChallengeMode.GetKeystoneLevelRarityColor(hl)
    EXMRH.MaxKeyText:SetText(hl); if mc then EXMRH.MaxKeyText:SetTextColor(mc.r, mc.g, mc.b) end

    local function UpdateCrest(id, ic, tx)
        local info = C_CurrencyInfo.GetCurrencyInfo(id)
        if info then
            ic:SetTexture(info.iconFileID); local cur, maxW = info.quantity or 0, info.maxWeeklyQuantity or 0; tx
                :SetText(maxW > 0 and string.format("%d/%d", cur, maxW) or tostring(cur))
        end
    end
    UpdateCrest(3345, EXMRH.C1I, EXMRH.C1T); UpdateCrest(3347, EXMRH.C2I, EXMRH.C2T)
    --=======================================================================================
    ----------------------------------------八个低保副本记录----------------------------------
    --=======================================================================================
    if wRuns then
        table.sort(wRuns, function(a, b) return a.level > b.level end)
        for i, idx in ipairs({ 1, 4, 8 }) do
            if wRuns[idx] then
                local il, info = EXMRH.GetLootInfo(wRuns[idx].level); EXMRH.Slots[i].ilvl:SetText(il); EXMRH.Slots[i]
                    .rank:SetText(info)
            else
                EXMRH.Slots[i].ilvl:SetText("-"); EXMRH.Slots[i].rank:SetText(L["未达成"])
            end
        end
        for i = 1, 8 do
            -- 处理低保数据渲染
            local run = wRuns[i]; local r = EXMRH.RunRows[i]
            if r.HighlightBG then
                if run then
                    r.HighlightBG:Show(); r.HighlightBG:SetColorTexture(classCol.r, classCol.g, classCol.b, 0.12)
                else
                    r.HighlightBG:Hide()
                end
            end
            if run then
                local n, _, _, tx = C_ChallengeMode.GetMapUIInfo(run.mapChallengeModeID); local lCol = C_ChallengeMode
                    .GetKeystoneLevelRarityColor(run.level)
                r.icon:SetTexture(tx)
                r.text:SetText(string.format("%s (%d)", n or "??", run.level))
                if lCol then r.text:SetTextColor(lCol.r, lCol.g, lCol.b) end
                local reward = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level); r.ilvl:SetText(reward > 0 and
                    reward or "")
            else
                r.icon:SetTexture(nil); r.text:SetText("-"); r.ilvl:SetText("")
            end
        end
    end
end

function EXMRH.InitSubPanels()
    EXMRH.InitHeader(); EXMRH.InitStatTable(); EXMRH.InitRightPanel()
end

EXMRH.CreateStandaloneFrame()
C_Timer.After(1, function() C_MythicPlus.RequestMapInfo() end)



-- =========================================================
-- [模块 7] ChallengesFrame 启动按钮
-- =========================================================
local function EXMRH_RemoveLegacyButtons()
    if not ChallengesFrame then return end

    local launchBtn = ChallengesFrame.EXMRH_LaunchButton or _G.EXMRH_LaunchButton
    if launchBtn then
        launchBtn:Hide()
        launchBtn:SetParent(UIParent)
    end

    local spellInfoBtn = ChallengesFrame.EXMRH_SpellInfoButton or _G.EXMRH_SpellInfoButton
    if spellInfoBtn then
        spellInfoBtn:Hide()
        spellInfoBtn:SetParent(UIParent)
    end
end

-- 挂钩 ChallengesFrame
local function EXMRH_HookChallenges()
    if not ChallengesFrame then return end
    if ChallengesFrame.__EXMRH_HOOKED then return end
    ChallengesFrame.__EXMRH_HOOKED = true

    EXMRH_RemoveLegacyButtons()
    ChallengesFrame:HookScript("OnShow", EXMRH_RemoveLegacyButtons)

    -- 隐藏暴雪文字
    if ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child and ChallengesFrame.WeeklyInfo.Child.SeasonBest then
        ChallengesFrame.WeeklyInfo.Child.SeasonBest:Hide()
        ChallengesFrame.WeeklyInfo.Child.SeasonBest:SetAlpha(0)
    end
end

-- 事件监听
local EXMRH_EventFrame = CreateFrame("Frame")
EXMRH_EventFrame:RegisterEvent("ADDON_LOADED")
EXMRH_EventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Blizzard_ChallengesUI" then
        EXMRH_HookChallenges()
    end
end)

-- PVE 面板显示时触发
-- [Fix] 移除 PVEFrame Hook 和 盲目 Timer Hook，避免登陆 Taint
-- 仅依赖 ADDON_LOADED 事件来 Hook ChallengesFrame

-- 报告模块加载完成
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
