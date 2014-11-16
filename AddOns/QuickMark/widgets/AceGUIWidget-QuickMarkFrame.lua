--[[-----------------------------------------------------------------------------
Frame Container
-------------------------------------------------------------------------------]]
local Type, Version = "QuickMarkFrame", 22
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local wipe = table.wipe

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: CLOSE

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(frame)
    PlaySound("gsTitleOptionExit")
    frame.obj:Hide()
end

local function Frame_OnClose(frame)
    frame.obj:Fire("OnClose")
end

local function Frame_OnMouseDown(frame)
    if (frame:IsMovable()) then frame:StartMoving() end
    AceGUI:ClearFocus()
end

local function Frame_OnMouseUp(frame)
    frame:StopMovingOrSizing()
end

local function Title_OnMouseDown(frame)
    frame:GetParent():StartMoving()
    AceGUI:ClearFocus()
end

local function MoverSizer_OnMouseUp(mover)
    local frame = mover:GetParent()
    frame:StopMovingOrSizing()
    local self = frame.obj
    local status = self.status or self.localstatus
    status.width = frame:GetWidth()
    status.height = frame:GetHeight()
    status.top = frame:GetTop()
    status.left = frame:GetLeft()
end

local function SizerSE_OnMouseDown(frame)
    frame:GetParent():StartSizing("BOTTOMRIGHT")
    AceGUI:ClearFocus()
end

local function SizerS_OnMouseDown(frame)
    frame:GetParent():StartSizing("BOTTOM")
    AceGUI:ClearFocus()
end

local function SizerE_OnMouseDown(frame)
    frame:GetParent():StartSizing("RIGHT")
    AceGUI:ClearFocus()
end

local function StatusBar_OnEnter(frame)
    frame.obj:Fire("OnEnterStatusBar")
end

local function StatusBar_OnLeave(frame)
    frame.obj:Fire("OnLeaveStatusBar")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ["OnAcquire"] = function(self)
        self.frame:SetParent(UIParent)
        self.frame:SetFrameStrata("MEDIUM")
        self:SetTitle()
        self:SetStatusText()
        self:ApplyStatus()
        self:Show()
    end,
    ["OnRelease"] = function(self)
        self.status = nil
        wipe(self.localstatus)
    end,
    ["OnWidthSet"] = function(self, width)
        local content = self.content
        local contentwidth = width - 34
        if contentwidth < 0 then
            contentwidth = 0
        end
        content:SetWidth(contentwidth)
        content.width = contentwidth
    end,
    ["OnHeightSet"] = function(self, height)
        local content = self.content
        local contentheight = height - 57
        if contentheight < 0 then
            contentheight = 0
        end
        content:SetHeight(contentheight)
        content.height = contentheight
    end,
    ["SetTitle"] = function(self, title)
    end,
    ["SetStatusText"] = function(self, text)
    --self.statustext:SetText(text)
    end,
    ["Hide"] = function(self)
        self.frame:Hide()
    end,
    ["Show"] = function(self)
        self.frame:Show()
    end,
    ["Lock"] = function(self)
        self.frame:SetMovable(false)
    end,
    ["Unlock"] = function(self)
        self.frame:SetMovable(true)
    end,
    ["SetBackdrop"] = function(self, edge_file, r, g, b, a)
        local backdrop = {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = edge_file, --"Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 5, bottom = 3 }
        }

        self.frame:SetBackdrop(backdrop)
        self.frame:SetBackdropColor(r, g, b, a)
    end,

    -- called to set an external table to store status in
    ["SetStatusTable"] = function(self, status)
        assert(type(status) == "table")
        self.status = status
        self:ApplyStatus()
    end,
    ["ApplyStatus"] = function(self)
        local status = self.status or self.localstatus
        local frame = self.frame
        self:SetWidth(status.width or 700)
        self:SetHeight(status.height or 500)
        frame:ClearAllPoints()
        if status.top and status.left then
            frame:SetPoint("TOP", UIParent, "BOTTOM", 0, status.top)
            frame:SetPoint("LEFT", UIParent, "LEFT", status.left, 0)
        else
            frame:SetPoint("CENTER")
        end
    end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local FrameBackdrop = {
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

local PaneBackdrop = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:Hide()

    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetResizable(false)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetBackdrop(PaneBackdrop)
    frame:SetBackdropColor(0, 0, 0, 1)
    frame:SetToplevel(true)
    frame:SetScript("OnHide", Frame_OnClose)
    frame:SetScript("OnMouseDown", Frame_OnMouseDown)
    frame:SetScript("OnMouseUp", Frame_OnMouseUp)

    --Container Support
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 12, -7)
    content:SetPoint("BOTTOMRIGHT", -17, 40)

    local widget = {
        localstatus = {},
        statustext = statustext,
        titlebg = titlebg,
        content = content,
        frame = frame,
        type = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
