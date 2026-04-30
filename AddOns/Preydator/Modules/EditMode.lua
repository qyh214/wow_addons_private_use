---@diagnostic disable: undefined-field, inject-field, param-type-mismatch

local _, addonTable = ...
local Preydator = _G.Preydator or addonTable
local L = _G.PreydatorL or setmetatable({}, { __index = function(_, k) return k end })

local EditModeModule = {}
Preydator:RegisterModule("EditMode", EditModeModule)

local api = Preydator.API
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local function IsFrameMouseOver(frame)
    return frame and frame.IsMouseOver and frame:IsMouseOver()
end

local function AnchorEditModeWindow(window)
    if not window then
        return
    end

    local editModeFrame = _G.EditModeManagerFrame
    window:ClearAllPoints()
    if editModeFrame and editModeFrame.IsShown and editModeFrame:IsShown() then
        window:SetPoint("BOTTOMRIGHT", editModeFrame, "BOTTOMRIGHT", -520, 0)
    else
        window:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    end
end

local function Clamp(value, minValue, maxValue)
    if api and type(api.Clamp) == "function" then
        return api.Clamp(value, minValue, maxValue)
    end
    return math.max(minValue, math.min(maxValue, value))
end

local function CreateCheckbox(parent, x, y, label, getter, setter)
    return api.CreateCheckboxControl(parent, x, y, label, getter, setter)
end

local function CreateSlider(parent, x, y, label, minValue, maxValue, step, getter, setter, formatter)
    return api.CreateSliderControl(parent, x, y, label, minValue, maxValue, step, getter, setter, formatter, {
        containerWidth = 250,
        containerHeight = 54,
        sliderWidth = 165,
        valueBoxWidth = 52,
        valueBoxHeight = 20,
        valueBoxOffsetX = 10,
    })
end

local function CreateActionButton(parent, x, y, width, text, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

function EditModeModule:RefreshControls()
    for _, control in ipairs(self.controls or {}) do
        local refresh = control and control.PreydatorRefresh
        if type(refresh) == "function" then
            refresh(control)
        end
    end
end

function EditModeModule:CreateWindow()
    if self.window then
        return self.window
    end

    local db = api.GetSettings()
    local window = CreateFrame("Frame", "PreydatorEditModeSettings", UIParent, "BackdropTemplate")
    window:SetSize(430, 390)
    AnchorEditModeWindow(window)
    window:SetFrameStrata("MEDIUM")
    window:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    window:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:Hide()

    local dismissFrame = CreateFrame("Frame", nil, UIParent)
    dismissFrame:SetAllPoints(UIParent)
    dismissFrame:SetFrameStrata("MEDIUM")
    dismissFrame:SetFrameLevel(math.max(1, window:GetFrameLevel() - 1))
    dismissFrame:EnableMouse(true)
    if dismissFrame.SetPropagateMouseClicks then
        dismissFrame:SetPropagateMouseClicks(true)
    end
    dismissFrame:SetScript("OnMouseDown", function()
        local barFrame = Preydator.GetBarFrame and Preydator.GetBarFrame()
        if IsFrameMouseOver(window) or IsFrameMouseOver(barFrame) then
            return
        end

        self:HideWindow()
    end)
    dismissFrame:Hide()

    local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 18, -18)
    title:SetText(L["Preydator Edit Mode"])

    local subtitle = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetWidth(390)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetWordWrap(true)
    subtitle:SetText(L["HINT_EDITMODE_SUBTITLE"])

    local closeButton = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -10, -10)

    self.controls = {}
    self.controls[#self.controls + 1] = CreateCheckbox(window, 18, -70, L["Lock Bar"], function() return db.locked end, function(value)
        db.locked = value
        api.ApplyBarSettings()
    end)
    self.controls[#self.controls + 1] = CreateCheckbox(window, 18, -98, L["Only show in prey zone"], function() return db.onlyShowInPreyZone end, function(value)
        db.onlyShowInPreyZone = value
        api.UpdateBarDisplay()
    end)
    self.controls[#self.controls + 1] = CreateCheckbox(window, 238, -70, L["Disable Default Prey Icon"], function() return db.disableDefaultPreyIcon == true end, function(value)
        db.disableDefaultPreyIcon = value
        api.ApplyDefaultPreyIconVisibility()
        api.UpdateBarDisplay()
    end)
    self.controls[#self.controls + 1] = CreateCheckbox(window, 238, -98, L["Show bar during Edit Mode"], function() return db.showInEditMode ~= false end, function(value)
        db.showInEditMode = value
        api.NormalizeDisplaySettings()
        api.UpdateBarDisplay()
    end)
    self.controls[#self.controls + 1] = CreateActionButton(window, 18, -136, 170, L["Reset Bar Position"], function()
        api.ResetBarPosition()
    end)

    self.controls[#self.controls + 1] = CreateSlider(window, 18, -184, L["Scale"], 0.5, 2, 0.05, function() return db.scale end, function(value)
        db.scale = value
        api.ApplyBarSettings()
    end, function(value) return string.format("%.2f", value) end)
    self.controls[#self.controls + 1] = CreateSlider(window, 18, -244, L["Width"], 160, 500, 1, function() return db.width end, function(value)
        db.width = math.floor(value + 0.5)
        api.RequestBarRefresh()
    end, function(value) return tostring(math.floor(value + 0.5)) end)
    self.controls[#self.controls + 1] = CreateSlider(window, 18, -304, L["Height"], 10, 40, 1, function() return db.height end, function(value)
        db.height = math.floor(value + 0.5)
        api.RequestBarRefresh()
    end, function(value) return tostring(math.floor(value + 0.5)) end)

    self.window = window
    self.dismissFrame = dismissFrame
    return self.window
end

function EditModeModule:ShowWindow()
    local db = api.GetSettings()
    if self._preEditModeLocked == nil then
        self._preEditModeLocked = db.locked and true or false
    end
    if db.locked ~= false then
        db.locked = false
        api.ApplyBarSettings()
        api.UpdateBarDisplay()
    end

    local window = self:CreateWindow()
    AnchorEditModeWindow(window)
    self:RefreshControls()
    if self.dismissFrame then
        self.dismissFrame:Show()
    end
    window:Show()
end

function EditModeModule:HideWindow()
    if self.dismissFrame then
        self.dismissFrame:Hide()
    end

    if self.window then
        self.window:Hide()
    end
end

function EditModeModule:EnterEditMode()
    local db = api.GetSettings()
    if self._preEditModeLocked ~= nil then
        return
    end

    self._preEditModeLocked = db.locked and true or false
    if db.locked ~= false then
        db.locked = false
        api.ApplyBarSettings()
        api.UpdateBarDisplay()
    end
end

function EditModeModule:ExitEditMode()
    local db = api.GetSettings()
    if self._preEditModeLocked ~= nil then
        db.locked = self._preEditModeLocked and true or false
        self._preEditModeLocked = nil
        api.ApplyBarSettings()
        api.UpdateBarDisplay()
    end

    self:HideWindow()
end

function EditModeModule:InitializeHooks()
    local editModeFrame = _G.EditModeManagerFrame
    if not editModeFrame or not editModeFrame.HookScript then
        return
    end

    editModeFrame:HookScript("OnShow", function()
        self:EnterEditMode()
        self:HideWindow()
    end)
    editModeFrame:HookScript("OnHide", function()
        self:ExitEditMode()
    end)
end

function EditModeModule:OnEvent(event)
    if event == "PLAYER_LOGIN" then
        self:InitializeHooks()
    end
end