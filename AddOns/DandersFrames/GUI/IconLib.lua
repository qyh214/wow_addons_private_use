local addonName, DF = ...

-- Icon Library Preview
-- Use /dficons to open the preview window

local ICONS_PATH = "Interface\\AddOns\\DandersFrames\\Media\\Icons\\"

local ICONS = {
    "add",
    "check",
    "chevron_right",
    "close",
    "content_copy",
    "delete",
    "download",
    "edit",
    "expand_more",
    "filter_alt",
    "filter_list",
    "info",
    "keyboard",
    "lock",
    "lock_open",
    "menu",
    "mouse",
    "refresh",
    "save",
    "search",
    "settings",
    "upload",
    "visibility",
    "visibility_off",
    "warning",
}

local previewFrame = nil

local function CreateIconPreview()
    if previewFrame then
        previewFrame:Show()
        return
    end
    
    -- Colors
    local C_BG = {r = 0.08, g = 0.08, b = 0.08}
    local C_BORDER = {r = 0.3, g = 0.3, b = 0.3}
    local C_ACCENT = {r = 0.6, g = 0.4, b = 0.8}
    local C_TEXT = {r = 1, g = 1, b = 1}
    local C_TEXT_DIM = {r = 0.6, g = 0.6, b = 0.6}
    
    -- Main frame
    local frame = CreateFrame("Frame", "DFIconPreview", UIParent, "BackdropTemplate")
    frame:SetSize(520, 480)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(C_BG.r, C_BG.g, C_BG.b, 0.95)
    frame:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "DFFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Material Icons Preview")
    title:SetTextColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b)
    
    -- Subtitle
    local subtitle = frame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -4)
    subtitle:SetText("25 icons from Google Material Symbols (Apache 2.0)")
    subtitle:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -8, -8)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER")
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    closeBtn:SetScript("OnEnter", function() closeIcon:SetVertexColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function() closeIcon:SetVertexColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b) end)
    
    -- Color buttons for testing SetVertexColor
    local colorLabel = frame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    colorLabel:SetPoint("TOPLEFT", 16, -50)
    colorLabel:SetText("Theme Color:")
    colorLabel:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local colors = {
        {name = "White", r = 1, g = 1, b = 1},
        {name = "Purple", r = 0.6, g = 0.4, b = 0.8},
        {name = "Blue", r = 0.3, g = 0.5, b = 0.9},
        {name = "Orange", r = 0.9, g = 0.5, b = 0.2},
        {name = "Red", r = 0.9, g = 0.3, b = 0.3},
        {name = "Green", r = 0.3, g = 0.8, b = 0.4},
        {name = "Yellow", r = 1, g = 0.8, b = 0.2},
        {name = "Gray", r = 0.5, g = 0.5, b = 0.5},
    }
    
    local currentColor = colors[1]
    local iconTextures = {}
    
    local function UpdateIconColors()
        for _, tex in ipairs(iconTextures) do
            tex:SetVertexColor(currentColor.r, currentColor.g, currentColor.b)
        end
    end
    
    local colorBtns = {}
    for i, col in ipairs(colors) do
        local btn = CreateFrame("Button", nil, frame, "BackdropTemplate")
        btn:SetSize(20, 20)
        btn:SetPoint("LEFT", colorLabel, "RIGHT", 8 + (i-1) * 24, 0)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(col.r, col.g, col.b, 1)
        btn:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        btn:SetScript("OnClick", function()
            currentColor = col
            UpdateIconColors()
            -- Update button borders
            for j, b in ipairs(colorBtns) do
                if j == i then
                    b:SetBackdropBorderColor(1, 1, 1, 1)
                else
                    b:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
                end
            end
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(col.name)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        if i == 1 then
            btn:SetBackdropBorderColor(1, 1, 1, 1)
        end
        
        table.insert(colorBtns, btn)
    end
    
    -- Icon grid
    local ICON_SIZE = 32
    local CELL_SIZE = 56
    local ICONS_PER_ROW = 8
    local START_X = 24
    local START_Y = -90
    
    for i, iconName in ipairs(ICONS) do
        local row = math.floor((i - 1) / ICONS_PER_ROW)
        local col = (i - 1) % ICONS_PER_ROW
        
        local x = START_X + col * CELL_SIZE
        local y = START_Y - row * (CELL_SIZE + 16)
        
        -- Icon container
        local container = CreateFrame("Button", nil, frame, "BackdropTemplate")
        container:SetSize(CELL_SIZE - 4, CELL_SIZE + 12)
        container:SetPoint("TOPLEFT", x, y)
        container:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        container:SetBackdropColor(0.12, 0.12, 0.12, 1)
        container:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        
        -- Icon texture
        local icon = container:CreateTexture(nil, "ARTWORK")
        icon:SetSize(ICON_SIZE, ICON_SIZE)
        icon:SetPoint("TOP", 0, -4)
        icon:SetTexture(ICONS_PATH .. iconName)
        icon:SetVertexColor(currentColor.r, currentColor.g, currentColor.b)
        table.insert(iconTextures, icon)
        
        -- Label
        local label = container:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        label:SetPoint("BOTTOM", 0, 4)
        label:SetText(iconName)
        label:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        label:SetWidth(CELL_SIZE - 8)
        label:SetWordWrap(false)
        
        -- Hover and click
        container:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(iconName, 1, 1, 1)
            GameTooltip:AddLine(ICONS_PATH .. iconName, 0.6, 0.6, 0.6)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Click to copy texture path", 0.4, 0.8, 0.4)
            GameTooltip:Show()
        end)
        container:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
            GameTooltip:Hide()
        end)
        container:SetScript("OnClick", function()
            local path = ICONS_PATH .. iconName
            print("|cff9966ffDandersFrames:|r Copied: " .. path)
        end)
    end
    
    -- Usage info at bottom
    local usage = frame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    usage:SetPoint("BOTTOM", 0, 12)
    usage:SetText("Click icon to copy path • Icons are white and can be tinted with SetVertexColor()")
    usage:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    previewFrame = frame
end

-- Slash command
SLASH_DFICONS1 = "/dficons"
SlashCmdList["DFICONS"] = function()
    CreateIconPreview()
end

-- Print load message
C_Timer.After(1, function()
    -- Only print if debug mode or first time
    -- print("|cff9966ffDandersFrames:|r Icon library loaded. Use /dficons to preview.")
end)
