-- =============================================================
-- ExwindTools_Changelog.lua
-- 核心更新日志系统：
-- 1. 将当前版本写入 WTF
-- 2. 根据 WTF 记录判断是否需要在打开设置面板时弹窗（每版本仅一次）
-- 3. 提供手动打开更新日志窗口的 API
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

local EX_DB = _G.ExwindToolsDB
if not EX_DB then return end

EX_DB.Changelog = EX_DB.Changelog or {}
local CL_DB = EX_DB.Changelog

local changelogFrame

local PANEL_THEME = {
    Background = { 0, 0, 0, 1 },
    Border = { 0.22, 0.56, 0.34, 0.9 },
    BodyText = { 0.84, 0.86, 0.89, 1.0 },
    BulletText = { 0.90, 0.92, 0.95, 1.0 },
    NoteText = { 0.95, 0.74, 0.45, 1.0 },
    H1Text = { 1.00, 0.86, 0.45, 1.0 },
    H2Text = { 0.43, 0.68, 0.86, 1.0 },
    DividerText = { 0.52, 0.64, 0.74, 0.75 },
}
local FONT_PATH = (GameFontNormal and select(1, GameFontNormal:GetFont())) or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

local PANEL_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 14,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local function GetCurrentVersion()
    return tostring(ExwindTools.VERSION or (_G.ExwindTools_MetaData and _G.ExwindTools_MetaData.version) or "v0.0.0.0000")
end

local function GetMetaChangelog()
    local meta = _G.ExwindTools_MetaData
    return meta and meta.changelog
end

local function GetChangelogContent()
    local current = GetCurrentVersion()
    local data = GetMetaChangelog()

    if type(data) == "string" and data ~= "" then
        return data
    end

    if type(data) == "table" then
        if type(data[current]) == "string" and data[current] ~= "" then
            return data[current]
        end
        if type(data.content) == "string" and data.content ~= "" then
            return data.content
        end
    end

    return "暂无更新日志内容。"
end

local function GetChangelogFontSize()
    local data = GetMetaChangelog()
    if type(data) == "table" then
        local n = tonumber(data.fontSize)
        if n then
            n = math.floor(n)
            if n < 10 then n = 10 end
            if n > 28 then n = 28 end
            return n
        end
    end
    return 14
end

local function ParseVersion(versionText)
    if not versionText then return nil end
    local text = tostring(versionText):lower():gsub("^v", "")
    local y, m, d, hm = text:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
    if y then
        return tonumber(y) or 0, tonumber(m) or 0, tonumber(d) or 0, tonumber(hm) or 0
    end

    local nums = {}
    for n in text:gmatch("(%d+)") do
        nums[#nums + 1] = tonumber(n) or 0
    end
    if #nums == 0 then return nil end
    while #nums < 4 do nums[#nums + 1] = 0 end
    return nums[1], nums[2], nums[3], nums[4]
end

local function VersionToScore(versionText)
    local y, m, d, hm = ParseVersion(versionText)
    if not y then return nil end
    return y * 100000000 + m * 1000000 + d * 10000 + hm
end

local function IsVersionNewer(newVersion, oldVersion)
    if not oldVersion or oldVersion == "" then return true end
    local n = VersionToScore(newVersion)
    local o = VersionToScore(oldVersion)
    if n and o then
        return n > o
    end
    return tostring(newVersion) ~= tostring(oldVersion)
end

local function MarkSeenVersion()
    CL_DB.LastSeenVersion = GetCurrentVersion()
    CL_DB.LastSeenAt = date("%Y-%m-%d %H:%M:%S")
end

local function MarkPopupShown()
    CL_DB.LastPopupVersion = GetCurrentVersion()
    CL_DB.LastPopupAt = date("%Y-%m-%d %H:%M:%S")
end

local function SplitLines(text)
    text = tostring(text or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
    local lines = {}
    if text == "" then return lines end
    text = text .. "\n"
    for line in text:gmatch("(.-)\n") do
        lines[#lines + 1] = line
    end
    return lines
end

local function ResolveLineStyle(line, baseSize)
    local h2 = line:match("^%s*@H2@%s*(.+)$") or line:match("^%s*##%s+(.+)$")
    if h2 then
        return h2, baseSize + 3, PANEL_THEME.H2Text, "", 7, "h2"
    end

    local h1 = line:match("^%s*@H1@%s*(.+)$") or line:match("^%s*#%s+(.+)$")
    if h1 then
        -- 兼容历史内容：若一级标题末尾带有日期时间，显示时去掉
        h1 = h1:gsub("%s+%d%d%d%d%-%d%d%-%d%d%s+%d%d:%d%d$", "")
        return h1, baseSize + 11, PANEL_THEME.H1Text, "OUTLINE", 10, "h1"
    end

    if line:match("^%s*$") then
        return "", baseSize, PANEL_THEME.BodyText, "", math.max(6, math.floor(baseSize * 0.5)), "blank"
    end

    if line:match("^%s*备注:") then
        return line, baseSize, PANEL_THEME.NoteText, "", math.max(6, math.floor(baseSize * 0.48)), "note"
    end

    if line:match("^%s*%-") then
        return line, baseSize, PANEL_THEME.BulletText, "", math.max(4, math.floor(baseSize * 0.42)), "bullet"
    end

    return line, baseSize, PANEL_THEME.BodyText, "", math.max(4, math.floor(baseSize * 0.4)), "body"
end

local function AcquireLine(frame, index)
    frame.LinePool = frame.LinePool or {}
    local fs = frame.LinePool[index]
    if fs then return fs end

    fs = frame.ScrollChild:CreateFontString(nil, "OVERLAY")
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    if fs.SetNonSpaceWrap then
        fs:SetNonSpaceWrap(true)
    end
    frame.LinePool[index] = fs
    return fs
end

local function AcquireDivider(frame, index)
    frame.DividerPool = frame.DividerPool or {}
    local tex = frame.DividerPool[index]
    if tex then return tex end

    tex = frame.ScrollChild:CreateTexture(nil, "ARTWORK")
    tex:SetColorTexture(unpack(PANEL_THEME.DividerText))
    frame.DividerPool[index] = tex
    return tex
end

local function RenderRichContent(frame, text, contentWidth, baseSize)
    frame.LinePool = frame.LinePool or {}
    frame.DividerPool = frame.DividerPool or {}
    local lines = SplitLines(text)
    local y = 0
    local seenH1 = false
    local dividerIndex = 0

    for i = 1, #lines do
        local fs = AcquireLine(frame, i)
        local lineText, fontSize, color, flags, bottomGap, styleType = ResolveLineStyle(lines[i], baseSize)

        if styleType == "h1" then
            if seenH1 then
                y = y + math.max(18, math.floor(baseSize * 1.4))
            end
            seenH1 = true
        end

        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", 0, -y)
        fs:SetWidth(contentWidth)
        fs:SetFont(FONT_PATH, fontSize, flags)
        fs:SetTextColor(color[1], color[2], color[3], color[4])

        if lineText == "" then
            fs:SetText(" ")
            y = y + bottomGap
        else
            fs:SetText(lineText)
            y = y + fs:GetStringHeight() + bottomGap
            if styleType == "h1" then
                dividerIndex = dividerIndex + 1
                local divider = AcquireDivider(frame, dividerIndex)
                divider:ClearAllPoints()
                divider:SetPoint("TOPLEFT", 0, -y)
                divider:SetSize(contentWidth, 1)
                divider:Show()
                y = y + 12
            end
        end
        fs:Show()
    end

    for i = #lines + 1, #frame.LinePool do
        frame.LinePool[i]:Hide()
    end
    for i = dividerIndex + 1, #frame.DividerPool do
        frame.DividerPool[i]:Hide()
    end

    frame.ScrollChild:SetSize(contentWidth, math.max(1, y + 10))
end

local function EnsureChangelogFrame()
    if changelogFrame then return changelogFrame end

    changelogFrame = CreateFrame("Frame", "ExwindToolsChangelogFrame", UIParent, "BackdropTemplate")
    changelogFrame:SetSize(860, 620)
    changelogFrame:SetBackdrop(PANEL_BACKDROP)
    changelogFrame:SetBackdropColor(unpack(PANEL_THEME.Background))
    changelogFrame:SetBackdropBorderColor(unpack(PANEL_THEME.Border))

    changelogFrame:SetPoint("CENTER")
    changelogFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    changelogFrame:SetFrameLevel(200)
    changelogFrame:SetToplevel(true)
    changelogFrame:SetMovable(true)
    changelogFrame:EnableMouse(true)
    changelogFrame:RegisterForDrag("LeftButton")
    changelogFrame:SetClampedToScreen(false)
    changelogFrame:SetScript("OnDragStart", changelogFrame.StartMoving)
    changelogFrame:SetScript("OnDragStop", changelogFrame.StopMovingOrSizing)

    local close = CreateFrame("Button", nil, changelogFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)
    close:SetScript("OnClick", function() changelogFrame:Hide() end)
    changelogFrame.CloseButton = close

    local scrollFrame = CreateFrame("ScrollFrame", nil, changelogFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 18, -34)
    scrollFrame:SetPoint("BOTTOMRIGHT", -34, 18)
    changelogFrame.ScrollFrame = scrollFrame

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)
    changelogFrame.ScrollChild = scrollChild
    changelogFrame.LinePool = {}
    changelogFrame.DividerPool = {}

    tinsert(UISpecialFrames, "ExwindToolsChangelogFrame")

    -- 应用 ElvUI / NDui 皮肤（EnsureChangelogFrame 在 PLAYER_ENTERING_WORLD 之后首次调用，
    -- 皮肤模块此时必定已完成初始化）
    local f = changelogFrame
    local ElvUISkin = ExwindTools.ElvUISkin
    local NDuiSkin = ExwindTools.NDuiSkin

    if ElvUISkin and ElvUISkin:IsElvUILoaded() then
        -- [ElvUI 模式]
        local E = _G.ElvUI and _G.ElvUI[1]
        local S = E and E:GetModule("Skins", true)
        if S then
            pcall(function()
                -- 主背景：使用 ElvUI Transparent 模板替换自定义 Backdrop
                if f.SetTemplate then
                    f:SetTemplate("Transparent")
                end
                -- 关闭按钮
                if S.HandleCloseButton and f.CloseButton then
                    S:HandleCloseButton(f.CloseButton)
                end
                -- 滚动条（UIPanelScrollFrameTemplate 创建的 ScrollBar）
                local sb = scrollFrame.ScrollBar
                if sb and S.HandleScrollBar then
                    S:HandleScrollBar(sb)
                end
            end)
        end
    elseif NDuiSkin and NDuiSkin:IsNDuiLoaded() then
        -- [NDui 模式]
        local NDui = _G.NDui
        local B = NDui and NDui[1]
        if B then
            pcall(function()
                -- 主背景：直接在 f 上应用 NDui Backdrop（使用 SkinAlpha 透明度）
                B.CreateBD(f)
                -- 添加阴影
                B.CreateSD(f, nil, true)
                -- 添加背景纹理
                B.CreateTex(f)
                -- 关闭按钮（必须用 ReskinClose，否则 × 图标丢失）
                if f.CloseButton then
                    B.ReskinClose(f.CloseButton)
                end
                -- 滚动条
                local sb = scrollFrame.ScrollBar
                if sb then
                    B.ReskinScroll(sb)
                end
            end)
        end
    end

    changelogFrame:Hide()
    return changelogFrame
end

local function RefreshChangelogFrame()
    local frame = EnsureChangelogFrame()
    local fontSize = GetChangelogFontSize()
    local text = GetChangelogContent()
    local contentWidth = math.max(320, frame:GetWidth() - 62)
    RenderRichContent(frame, text, contentWidth, fontSize)
    frame.ScrollFrame:SetVerticalScroll(0)
end

function ExwindTools:ShowChangelog(options)
    options = options or {}
    MarkSeenVersion()
    RefreshChangelogFrame()
    changelogFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    changelogFrame:SetFrameLevel(200)
    changelogFrame:Show()
    changelogFrame:Raise()

    if options.markShown ~= false then
        MarkPopupShown()
    end
end

function ExwindTools:ShouldPopupChangelog()
    local currentVersion = GetCurrentVersion()
    local lastPopupVersion = CL_DB.LastPopupVersion
    return IsVersionNewer(currentVersion, lastPopupVersion)
end

function ExwindTools:HandleChangelogPopupOnUIOpen()
    MarkSeenVersion()
    if not self:ShouldPopupChangelog() then return end
    self:ShowChangelog({ markShown = true })
end

-- 初始化：进入游戏即保存当前版本到 WTF
MarkSeenVersion()
