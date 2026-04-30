---@diagnostic disable: undefined-global

local ExwindTools = _G.ExwindTools
if not ExwindTools then
    return
end

_G.ExwindToolsDB = _G.ExwindToolsDB or {}
local db = _G.ExwindToolsDB
db.EditMode = db.EditMode or {}
db.EditMode.visibleByKey = type(db.EditMode.visibleByKey) == "table" and db.EditMode.visibleByKey or {}

local state = ExwindTools.EditModeState or {}
ExwindTools.EditModeState = state
state.enabled = false
state.visibleByKey = db.EditMode.visibleByKey
state.handlers = state.handlers or {}

ExwindTools.GlobalEditMode = false
ExwindTools.EditModeCallbacks = ExwindTools.EditModeCallbacks or {}
ExwindTools.HUDs = ExwindTools.HUDs or {}

local originalDisableModuleRuntime = ExwindTools.DisableModuleRuntime
local WHITE_TEX = "Interface\\Buttons\\WHITE8X8"
local HEADER_HEIGHT = 20

local function OwnerBelongsToModule(owner, moduleKey)
    if owner == moduleKey then
        return true
    end
    if type(owner) ~= "string" or type(moduleKey) ~= "string" then
        return false
    end

    return string.sub(owner, 1, #moduleKey + 1) == (moduleKey .. ".")
        or string.sub(owner, 1, #moduleKey + 1) == (moduleKey .. "_")
end

local function SyncEditModeButtonText()
    if ExwindTools.UI and ExwindTools.UI.EditModeToggleButton then
        ExwindTools.UI.EditModeToggleButton:SetText(
            state.enabled and "关闭编辑模式" or "启用编辑模式"
        )
    end
end

local function SyncEditModePopup()
    if state.enabled then
        if not StaticPopupDialogs["EXWIND_EDIT_MODE_EXIT"] then
            StaticPopupDialogs["EXWIND_EDIT_MODE_EXIT"] = {
                text = "是否退出编辑模式？",
                button1 = "确定",
                OnAccept = function()
                    ExwindTools:ToggleGlobalEditMode(false)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false,
                preferredIndex = 3,
            }
        end
        StaticPopup_Show("EXWIND_EDIT_MODE_EXIT")
    else
        StaticPopup_Hide("EXWIND_EDIT_MODE_EXIT")
    end
end

local function ResolveOverlayTitle(moduleKey, title)
    if type(title) == "string" and title ~= "" then
        return title
    end

    if ExwindTools.ModuleIndexByKey and ExwindTools.ModuleList then
        local idx = ExwindTools.ModuleIndexByKey[moduleKey]
        local meta = idx and ExwindTools.ModuleList[idx]
        if meta and type(meta.Name) == "string" and meta.Name ~= "" then
            return meta.Name
        end
    end

    return moduleKey or ""
end

local function EnsureExwindToolsEditOverlay(frame)
    if not frame then
        return nil
    end

    local overlay = frame.__ExwindToolsEditOverlay
    if overlay then
        return overlay
    end

    overlay = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    overlay:SetFrameStrata("DIALOG")
    overlay:SetFrameLevel((frame:GetFrameLevel() or 0) + 200)
    overlay:EnableMouse(false)
    overlay:SetClipsChildren(false)
    overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, HEADER_HEIGHT)
    overlay:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, HEADER_HEIGHT)
    overlay:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    overlay:SetBackdrop({
        edgeFile = WHITE_TEX,
        edgeSize = 1,
    })
    overlay:SetBackdropColor(0, 0, 0, 0)
    overlay:SetBackdropBorderColor(0.68, 0.36, 1.00, 0.92)

    overlay.Header = CreateFrame("Frame", nil, overlay, "BackdropTemplate")
    overlay.Header:SetBackdrop({
        bgFile = WHITE_TEX,
    })
    overlay.Header:SetBackdropColor(0.16, 0.10, 0.28, 0.92)
    overlay.Header:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, 0)
    overlay.Header:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", 0, 0)
    overlay.Header:SetHeight(HEADER_HEIGHT)
    overlay.Header:EnableMouse(true)

    overlay.Content = CreateFrame("Frame", nil, overlay, "BackdropTemplate")
    overlay.Content:SetBackdrop({
        bgFile = WHITE_TEX,
    })
    overlay.Content:SetBackdropColor(0.10, 0.08, 0.18, 0.38)
    overlay.Content:SetPoint("TOPLEFT", overlay, "TOPLEFT", 0, -HEADER_HEIGHT)
    overlay.Content:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", 0, -HEADER_HEIGHT)
    overlay.Content:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", 0, 0)
    overlay.Content:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)
    overlay.Content:EnableMouse(true)

    overlay.Title = overlay.Header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    overlay.Title:SetPoint("LEFT", overlay.Header, "LEFT", 8, 0)
    overlay.Title:SetJustifyH("LEFT")
    overlay.Title:SetTextColor(0.95, 0.90, 1.0, 1.0)

    frame.__ExwindToolsEditOverlay = overlay
    overlay:Hide()
    return overlay
end

function ExwindTools:ShowExwindToolsEditOverlay(moduleKey, frame, options)
    if not frame then
        return
    end

    local overlay = EnsureExwindToolsEditOverlay(frame)
    if not overlay then
        return
    end

    local title = ResolveOverlayTitle(moduleKey, options and options.title)
    overlay:SetFrameStrata("DIALOG")
    overlay:SetFrameLevel((frame:GetFrameLevel() or 0) + 200)
    overlay.Title:SetText(title)
    overlay.__moduleKey = moduleKey
    overlay.__ownerFrame = (options and options.ownerFrame) or frame
    overlay.__options = options

    local function BeginPointerDrag(button)
        local owner = overlay.__ownerFrame
        if not owner then
            return
        end

        if button == "RightButton" and ExwindTools.GlobalEditMode then
            ExwindTools:OpenConfig(overlay.__moduleKey)
            return
        end

        if button ~= "LeftButton" then
            return
        end

        owner.__ExwindOverlayMoving = true
        if owner.StartMoving then
            owner:StartMoving()
        else
            local onDragStart = owner:GetScript("OnDragStart")
            if type(onDragStart) == "function" then
                onDragStart(owner)
            end
        end
    end

    local function EndPointerDrag(button)
        local owner = overlay.__ownerFrame
        if not owner or button ~= "LeftButton" then
            return
        end

        if owner.__ExwindOverlayMoving then
            owner.__ExwindOverlayMoving = nil
            if owner.StopMovingOrSizing then
                owner:StopMovingOrSizing()
            end

            local onDragStop = owner:GetScript("OnDragStop")
            if type(onDragStop) == "function" then
                onDragStop(owner)
            else
                local onMouseUp = owner:GetScript("OnMouseUp")
                if type(onMouseUp) == "function" then
                    onMouseUp(owner, "LeftButton")
                end
            end
        end
    end

    overlay.Header:SetScript("OnMouseDown", function(_, button) BeginPointerDrag(button) end)
    overlay.Header:SetScript("OnMouseUp", function(_, button) EndPointerDrag(button) end)
    overlay.Content:SetScript("OnMouseDown", function(_, button) BeginPointerDrag(button) end)
    overlay.Content:SetScript("OnMouseUp", function(_, button) EndPointerDrag(button) end)

    overlay:Show()
end

function ExwindTools:HideExwindToolsEditOverlay(frame)
    if frame and frame.__ExwindToolsEditOverlay then
        frame.__ExwindToolsEditOverlay:Hide()
    end
end

local function DispatchLegacyCallbacks(enabled)
    for owner, callback in pairs(ExwindTools.EditModeCallbacks) do
        local ok, err = pcall(callback, enabled)
        if not ok and ExwindTools.LogError then
            ExwindTools:LogError(owner, err)
        end
    end
end

local function DispatchHandlers(enabled)
    if enabled then
        for moduleKey, handler in pairs(state.handlers) do
            if type(handler.EnterEditMode) == "function" then
                local ok, err = pcall(handler.EnterEditMode, handler)
                if not ok and ExwindTools.LogError then
                    ExwindTools:LogError(moduleKey .. ".EnterEditMode", err)
                end
            end
        end

        for moduleKey, handler in pairs(state.handlers) do
            local visible = ExwindTools:IsEditModeModuleVisible(moduleKey)
            if type(handler.SetEditVisible) == "function" then
                local ok, err = pcall(handler.SetEditVisible, handler, visible)
                if not ok and ExwindTools.LogError then
                    ExwindTools:LogError(moduleKey .. ".SetEditVisible", err)
                end
            end
            if type(handler.RefreshEditMode) == "function" then
                local ok, err = pcall(handler.RefreshEditMode, handler, true, visible)
                if not ok and ExwindTools.LogError then
                    ExwindTools:LogError(moduleKey .. ".RefreshEditMode", err)
                end
            end
        end
    else
        for moduleKey, handler in pairs(state.handlers) do
            if type(handler.ExitEditMode) == "function" then
                local ok, err = pcall(handler.ExitEditMode, handler)
                if not ok and ExwindTools.LogError then
                    ExwindTools:LogError(moduleKey .. ".ExitEditMode", err)
                end
            end
            if type(handler.RefreshEditMode) == "function" then
                local ok, err = pcall(handler.RefreshEditMode, handler, false, false)
                if not ok and ExwindTools.LogError then
                    ExwindTools:LogError(moduleKey .. ".RefreshEditMode", err)
                end
            end
        end
    end
end

function ExwindTools:IsEditModeEnabled()
    return state.enabled == true
end

function ExwindTools:IsEditModeModuleVisible(moduleKey)
    return state.visibleByKey[moduleKey] ~= false
end

function ExwindTools:GetEditModeState(moduleKey)
    return state.enabled == true, self:IsEditModeModuleVisible(moduleKey)
end

function ExwindTools:RegisterEditModeHandler(moduleKey, handler)
    if type(moduleKey) ~= "string" or moduleKey == "" then
        error("RegisterEditModeHandler: moduleKey must be string", 2)
    end
    if type(handler) ~= "table" then
        error("RegisterEditModeHandler: handler must be table", 2)
    end

    state.handlers[moduleKey] = handler

    if state.enabled then
        if type(handler.EnterEditMode) == "function" then
            pcall(handler.EnterEditMode, handler)
        end
        if type(handler.SetEditVisible) == "function" then
            pcall(handler.SetEditVisible, handler, self:IsEditModeModuleVisible(moduleKey))
        end
        if type(handler.RefreshEditMode) == "function" then
            pcall(handler.RefreshEditMode, handler, true, self:IsEditModeModuleVisible(moduleKey))
        end
    end
end

function ExwindTools:UnregisterEditModeHandler(moduleKey)
    state.handlers[moduleKey] = nil
end

function ExwindTools:SetEditModeModuleVisible(moduleKey, visible, skipRefresh)
    if type(moduleKey) ~= "string" or moduleKey == "" then
        return false
    end

    if visible == false then
        state.visibleByKey[moduleKey] = false
    else
        state.visibleByKey[moduleKey] = nil
    end

    if state.enabled and not skipRefresh then
        self:RefreshEditMode()
    end
    return true
end

function ExwindTools:ShowAllEditModeModules(skipRefresh)
    wipe(state.visibleByKey)
    if state.enabled and not skipRefresh then
        self:RefreshEditMode()
    end
end

function ExwindTools:RefreshEditMode()
    self.GlobalEditMode = state.enabled == true
    DispatchLegacyCallbacks(state.enabled)
    DispatchHandlers(state.enabled)
    SyncEditModeButtonText()
    SyncEditModePopup()
end

function ExwindTools:RegisterEditModeCallback(owner, callback)
    if type(callback) ~= "function" then
        error("RegisterEditModeCallback: callback must be function", 2)
    end
    self.EditModeCallbacks[owner] = callback

    if state.enabled then
        pcall(callback, true)
    end
end

function ExwindTools:UnregisterEditModeCallback(owner)
    self.EditModeCallbacks[owner] = nil
end

function ExwindTools:ToggleGlobalEditMode(forceState)
    if forceState ~= nil then
        state.enabled = forceState and true or false
    else
        state.enabled = not state.enabled
    end

    self.GlobalEditMode = state.enabled
    local status = state.enabled and "|cff00ff00[启用]|r" or "|cffff0000[禁用]|r"
    self:Print("全局编辑模式: " .. status)
    self:RefreshEditMode()
end

function ExwindTools:RegisterHUD(moduleKey, frame)
    if not frame then
        return
    end

    frame:EnableMouse(true)

    if not frame.__ExwindEditModeConfigHooked then
        frame.__ExwindEditModeConfigHooked = true
        frame:HookScript("OnMouseDown", function(_, button)
            if button == "RightButton" and ExwindTools.GlobalEditMode then
                ExwindTools:OpenConfig(frame.__ExwindOpenConfigKey or moduleKey)
            end
        end)
    end

    table.insert(self.HUDs, { key = moduleKey, frame = frame })

    self:RegisterEditModeCallback(moduleKey .. "_HUD_" .. (frame:GetName() or tostring(frame)), function(enabled)
        if enabled then
            frame:EnableMouse(true)
        end
    end)
end

function ExwindTools:DisableModuleRuntime(moduleKey)
    if type(moduleKey) == "string" and moduleKey ~= "" then
        local ownersToRemove = {}
        for owner in pairs(state.handlers) do
            if OwnerBelongsToModule(owner, moduleKey) then
                ownersToRemove[#ownersToRemove + 1] = owner
            end
        end
        for _, owner in ipairs(ownersToRemove) do
            self:UnregisterEditModeHandler(owner)
        end
        state.visibleByKey[moduleKey] = nil
    end

    if type(originalDisableModuleRuntime) == "function" then
        return originalDisableModuleRuntime(self, moduleKey)
    end
    return false
end
