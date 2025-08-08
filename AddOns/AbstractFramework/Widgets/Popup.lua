---@class AbstractFramework
local AF = _G.AbstractFramework
local L = AF.L

local parent, mover
local popups = {}

local MAX_POPUPS = 5
local DEFAULT_WIDTH = 220
local DEFAULT_OFFSET = 10
local DEFAULT_NOTIFICATION_TIMEOUT = 10
local DEFAULT_PROGRESS_TIMEOUT = 5

local DEFAULT_SETTINGS = {
    position = {"BOTTOMLEFT", 1, 420},
    orientation = "bottom_to_top"
}

local notificationPool, confirmPool, progressPool

---------------------------------------------------------------------
-- creation
---------------------------------------------------------------------
local function CreateParent()
    -- parent
    parent = CreateFrame("Frame", "AFPopupParent", AF.UIParent)
    -- parent:SetBackdrop({edgeFile=AF.GetPlainTexture(), edgeSize=AF.GetOnePixelForRegion(parent)})
    -- parent:SetBackdropBorderColor(AF.GetColorRGB("black"))
    AF.SetSize(parent, DEFAULT_WIDTH, 60)
    AF.SetPoint(parent, "BOTTOMLEFT", 0, 420)
    parent:SetFrameStrata("DIALOG")
    parent:SetFrameLevel(1000)
    parent:SetClampedToScreen(true)

    function parent:UpdatePixels()
        AF.ReSize(parent)
    end

    AF.AddToPixelUpdater(parent)
end

---------------------------------------------------------------------
-- show
---------------------------------------------------------------------
local function ShowPopups(stopMoving)
    for i, p in ipairs(popups) do
        if stopMoving then
            p:StopMoving()
        end

        -- show
        if i <= MAX_POPUPS and not popups[i]:IsShown() then
            popups[i]:FadeIn()
        end

        -- set point
        local point, relativePoint, offset
        if parent.orientation == "bottom_to_top" then
            point, relativePoint = "BOTTOMLEFT", "TOPLEFT"
            offset = DEFAULT_OFFSET
        else
            point, relativePoint = "TOPLEFT", "BOTTOMLEFT"
            offset = -DEFAULT_OFFSET
        end

        AF.ClearPoints(popups[i])
        if i == 1 then
            AF.SetPoint(popups[i], point)
        else
            AF.SetPoint(popups[i], point, popups[i - 1], relativePoint, 0, offset)
        end
    end
end

---------------------------------------------------------------------
-- hiding handler
---------------------------------------------------------------------
local hidingQueue = {}

local hidingHandler = CreateFrame("Frame")
hidingHandler:Hide()
hidingHandler:SetScript("OnUpdate", function()
    if hidingQueue[1] then
        if not hidingHandler.isProcessing then
            hidingHandler.isProcessing = true
            hidingQueue[1]:FadeOut()
        end
    else
        hidingHandler:Hide()
        hidingHandler.isProcessing = nil
    end
end)

local function HandleNext()
    ShowPopups()
    hidingQueue[1].isInQueue = nil
    tremove(hidingQueue, 1)
    hidingHandler.isProcessing = nil
end

local function AddToHidingQueue(p)
    if p.isInQueue then return end --! prevent Click and Timeout at the same time
    p.isInQueue = true
    tinsert(hidingQueue, p)
    hidingHandler:Show()
end

local function WipeHidingQueue()
    for _, p in ipairs(hidingQueue) do
        p.isInQueue = nil
    end
    wipe(hidingQueue)
end

---------------------------------------------------------------------
-- OnShow, OnHide
---------------------------------------------------------------------
local function OnPopupShow(p)
    -- play sound
    if p.sound then
        PlaySoundFile(p.sound, "Master")
    else
        AF.PlaySound("pop")
    end

    -- icon
    if p.icon then
        p.iconTex:SetTexture(p.icon)

        if type(p.icon) == "number" then
            AF.ApplyDefaultTexCoord(p.iconTex) -- for blizzard item/spell icons
        else
            AF.ClearTexCoord(p.iconTex)
        end

        if strmatch(p.icon, "^!") then
            AF.Show(p.iconTex)
        else
            AF.Show(p.iconTex, p.iconBGTex)
        end
        AF.SetPoint(p.text, "LEFT", p._textLeftX + 7 + 32, p._textLeftY)
    else
        AF.Hide(p.iconTex, p.iconBGTex)
        AF.SetPoint(p.text, "LEFT", p._textLeftX, p._textLeftY)
    end
end

local function OnPopupHide(p)
    -- update index
    for i = p.index + 1, #popups do
        popups[i].index = popups[i].index - 1
    end
    tremove(popups, p.index)

    if #popups == 0 then
        --! all popups hide
        -- the last popup won't move
        WipeHidingQueue()
    else
        -- play move animation
        local hooked
        for i = p.index, MAX_POPUPS do
            if not popups[i] then break end

            -- only hook ONE popup
            if not hooked then
                -- refresh
                hooked = true
                popups[i]:SetOnMoveFinished(HandleNext)
            else
                popups[i]:SetOnMoveFinished()
            end
            popups[i]:Move(Round(p:GetHeight()) + DEFAULT_OFFSET)
        end

        if not hooked then
            HandleNext()
        end
    end

    p.index = nil
    p.sound = nil
end

---------------------------------------------------------------------
-- animation
---------------------------------------------------------------------
local function CreateAnimation(p)
    AF.CreateFadeInOutAnimation(p)

    local move_ag = p:CreateAnimationGroup()
    local move_a = move_ag:CreateAnimation("Translation")
    move_a:SetDuration(0.25)

    function p:Move(offset)
        if not p:IsShown() then p:FadeIn() end
        if not move_ag:IsPlaying() then
            if parent.orientation == "bottom_to_top" then
                move_a:SetOffset(0, -offset)
            else
                move_a:SetOffset(0, offset)
            end
            move_ag:Play()
        end
    end

    function p:SetOnMoveFinished(script)
        move_ag:SetScript("OnFinished", script)
    end

    function p:StopMoving()
        if move_ag:IsPlaying() then
            move_ag:Finish()
        end
    end
end

---------------------------------------------------------------------
-- icon
---------------------------------------------------------------------
local function CreateIcon(p)
    local iconTex = AF.CreateTexture(p, nil, nil, "OVERLAY")
    p.iconTex = iconTex
    iconTex:Hide()
    AF.SetSize(iconTex, 32, 32)
    AF.SetPoint(iconTex, "LEFT", 7, p._textLeftY)

    local iconBGTex = AF.CreateTexture(p, nil, "black", "BORDER")
    p.iconBGTex = iconBGTex
    iconBGTex:Hide()
    AF.SetOnePixelOutside(iconBGTex, iconTex)
end

---------------------------------------------------------------------
-- notificationPool
---------------------------------------------------------------------
local npCreationFn = function()
    local p = AF.CreateBorderedFrame(parent)
    p:Hide()

    AF.ShowNormalGlow(p, "shadow", 2)

    CreateAnimation(p)
    p:EnableMouse(true)

    -- text ---------------------------------------------------------
    local text = AF.CreateFontString(p)
    p.text = text
    p._textLeftX = 7
    p._textLeftY = 0
    AF.SetPoint(p.text, "LEFT", 7, 0)
    AF.SetPoint(p.text, "RIGHT", -7, 0)

    -- icon ---------------------------------------------------------
    CreateIcon(p)

    -- timerBar -----------------------------------------------------
    local timerBar = CreateFrame("StatusBar", nil, p)
    p.timerBar = timerBar
    timerBar:SetStatusBarTexture(AF.GetPlainTexture())
    timerBar:SetStatusBarColor(AF.GetColorRGB("accent"))
    AF.SetPoint(timerBar, "BOTTOMLEFT", 1, 1)
    AF.SetPoint(timerBar, "BOTTOMRIGHT", -1, 1)
    AF.SetHeight(timerBar, 1)

    -- OnMouseUp ----------------------------------------------------
    p:SetOnMouseUp(function(_, button)
        if button == "LeftButton" then
            if p.onClick then p:onClick(button, unpack(p.onClickArgs)) end
        elseif button == "RightButton" then
            if p.timer then
                p.timer:Cancel()
                p.timer = nil
            end
            AddToHidingQueue(p)
        end
    end)

    -- OnHide -------------------------------------------------------
    p:SetOnHide(function()
        OnPopupHide(p)
        -- release
        notificationPool:Release(p)
    end)

    -- OnUpdate -----------------------------------------------------
    p:SetOnUpdate(function()
        -- update height
        p:SetHeight(Round(p.text:GetStringHeight()) + 40)
    end)

    -- SetTimeout ---------------------------------------------------
    function p:SetTimeout(timeout)
        p:SetOnShow(function()
            OnPopupShow(p)
            -- timer bar
            p.timer = C_Timer.NewTimer(timeout, function()
                p.timer = nil
                AddToHidingQueue(p)
            end)
            -- timerBar:SetReverseFill(settings["alignment"]=="RIGHT")
            timerBar:SetMinMaxValues(0, timeout)
            timerBar:SetValue(timeout)
            timerBar:SetScript("OnUpdate", function(self, elapsed)
                timeout = max(0, timeout - elapsed)
                timerBar:SetValue(timeout)
            end)
        end)
    end

    function p:UpdatePixels()
        AF.ReSize(p)
        AF.RePoint(p)
        AF.ReBorder(p)
        AF.ReSize(timerBar)
        AF.RePoint(timerBar)
    end

    return p
end
notificationPool = CreateObjectPool(npCreationFn)

---------------------------------------------------------------------
-- confirmPool
---------------------------------------------------------------------
local cpCreationFn = function()
    local p = AF.CreateBorderedFrame(parent)
    p:Hide()

    AF.ShowNormalGlow(p, "shadow", 2)

    CreateAnimation(p)
    p:EnableMouse(true)

    -- text ---------------------------------------------------------
    local text = AF.CreateFontString(p)
    p.text = text
    p._textLeftX = 7
    p._textLeftY = 5
    AF.SetPoint(p.text, "LEFT", 7, 5)
    AF.SetPoint(p.text, "RIGHT", -7, 5)

    -- icon ---------------------------------------------------------
    CreateIcon(p)

    -- button -------------------------------------------------------
    -- local no = AF.CreateButton(p, nil, "red", 30, 15)
    local no = AF.CreateIconButton(p, AF.GetIcon("Fluent_Color_No"), 16, 16, 1, "gray", "white")
    p.no = no
    AF.SetPoint(no, "BOTTOMRIGHT")
    -- no:SetTexture(AF.GetIcon("Close"), {13, 13})
    no:SetOnClick(function()
        if p.onCancel then p.onCancel() end
        -- AF.Disable(p.yes, p.no)
        AddToHidingQueue(p)
    end)

    -- local yes = AF.CreateButton(p, nil, "green", 30, 15)
    local yes = AF.CreateIconButton(p, AF.GetIcon("Fluent_Color_Yes"), 16, 16, 1, "gray", "white")
    p.yes = yes
    AF.SetPoint(yes, "BOTTOMRIGHT", no, "BOTTOMLEFT", -2, 0)
    -- yes:SetTexture(AF.GetIcon("Tick"), {16, 16})
    yes:SetOnClick(function()
        if p.onConfirm then p.onConfirm() end
        -- AF.Disable(p.yes, p.no)
        AddToHidingQueue(p)
    end)

    local ok = AF.CreateIconButton(p, AF.GetIcon("Fluent_Color_Yes"), 16, 16, 1, "gray", "white")
    p.ok = ok
    AF.SetPoint(ok, "BOTTOMRIGHT", -1, 0)
    ok:SetOnClick(function()
        if p.onConfirm then p.onConfirm() end
        AddToHidingQueue(p)
    end)

    -- OnShow -------------------------------------------------------
    p:SetOnShow(function()
        OnPopupShow(p)
        -- AF.Enable(yes, no)
        if p.onCancel == false then
            p.yes:Hide()
            p.no:Hide()
            p.ok:Show()
        else
            p.yes:Show()
            p.no:Show()
            p.ok:Hide()
        end
    end)

    -- OnHide -------------------------------------------------------
    p:SetOnHide(function()
        OnPopupHide(p)
        -- release
        confirmPool:Release(p)
    end)

    -- OnUpdate -----------------------------------------------------
    p:SetOnUpdate(function()
        -- update height
        p:SetHeight(Round(p.text:GetStringHeight()) + 45)
    end)

    -- OnClick ------------------------------------------------------
    p:SetOnMouseUp(function(_, button)
        if button == "LeftButton" and p.onClick then p:onClick(button, unpack(p.onClickArgs)) end
    end)


    return p
end
confirmPool = CreateObjectPool(cpCreationFn)

---------------------------------------------------------------------
-- progressPool
---------------------------------------------------------------------
local ppCreationFn = function()
    local p = AF.CreateBorderedFrame(parent)
    p:Hide()

    AF.ShowNormalGlow(p, "shadow", 2)

    CreateAnimation(p)
    p:EnableMouse(true)

    -- text ---------------------------------------------------------
    local text = AF.CreateFontString(p)
    p.text = text
    p._textLeftX = 7
    p._textLeftY = 0
    AF.SetPoint(p.text, "LEFT", 7, 0)
    AF.SetPoint(p.text, "RIGHT", -7, 0)

    -- icon ---------------------------------------------------------
    CreateIcon(p)

    -- progressBar --------------------------------------------------
    local bar = AF.CreateBlizzardStatusBar(p, nil, nil, 5, 5, "accent", nil, "percentage")
    p.bar = bar
    AF.SetPoint(bar, "BOTTOMLEFT")
    AF.SetPoint(bar, "BOTTOMRIGHT")

    AF.ClearPoints(bar.progressText)
    AF.SetPoint(bar.progressText, "BOTTOMRIGHT", -2, 2)
    bar.progressText:SetFontObject("AF_FONT_SMALL")

    p.callback = function(value)
            p.bar:SetSmoothedValue(value)
        if value >= bar.maxValue then
            if p:IsShown() then
                C_Timer.After(DEFAULT_PROGRESS_TIMEOUT, function()
                    AddToHidingQueue(p)
                end)
            end
        end
    end

    -- OnShow -------------------------------------------------------
    p:SetOnShow(function()
        OnPopupShow(p)
        -- check if is done
        if bar:GetValue() >= bar.maxValue then
            C_Timer.After(DEFAULT_PROGRESS_TIMEOUT, function()
                AddToHidingQueue(p)
            end)
        end
    end)

    -- OnHide -------------------------------------------------------
    p:SetOnHide(function()
        OnPopupHide(p)
        -- release
        progressPool:Release(p)
    end)

    -- OnUpdate -----------------------------------------------------
    p:SetOnUpdate(function()
        -- update height
        p:SetHeight(Round(p.text:GetStringHeight()) + 40)
    end)

    -- OnClick ------------------------------------------------------
    p:SetOnMouseUp(function(_, button)
        if button == "LeftButton" and p.onClick then p:onClick(button, unpack(p.onClickArgs)) end
    end)

    return p
end
progressPool = CreateObjectPool(ppCreationFn)

---------------------------------------------------------------------
-- notification popup
---------------------------------------------------------------------
---@param text string
---@param timeout? number default 10 seconds
---@param icon? string|number if starts with "!", will show a transparent icon bg instead of black
---@param sound? string
---@param width? number default 220
---@param justify? string default "CENTER"
---@param onClick? fun(popup:AF_BorderedFrame, button:string, ...:any)
---@param ... any arguments to pass to the onClick function
function AF.ShowNotificationPopup(text, timeout, icon, sound, width, justify, onClick, ...)
    local p = notificationPool:Acquire()
    p.text:SetText(text)
    AF.SetWidth(p, width or DEFAULT_WIDTH)
    p:SetTimeout(timeout or DEFAULT_NOTIFICATION_TIMEOUT)
    p.text:SetJustifyH(justify or "CENTER")
    -- AF.ApplyDefaultBackdropWithColors(p, color, borderColor)

    p.icon = icon
    p.sound = sound
    p.onClick = onClick
    p.onClickArgs = {...}

    tinsert(popups, p)
    p.index = #popups
    ShowPopups(true)
end

---------------------------------------------------------------------
-- confirm popup
---------------------------------------------------------------------
---@param text string
---@param onConfirm? function
---@param onCancel? function|false if false, the popup will show single ok button instead of yes/no
---@param icon? string|number if starts with "!", will show a transparent icon bg instead of black
---@param sound? string
---@param width? number default 220
---@param justify? string default "CENTER"
---@param onClick? fun(popup:AF_BorderedFrame, button:string, ...:any)
---@param ... any arguments to pass to the onClick function
function AF.ShowConfirmPopup(text, onConfirm, onCancel, icon, sound, width, justify, onClick, ...)
    local p = confirmPool:Acquire()
    p.text:SetText(text)
    AF.SetWidth(p, width or DEFAULT_WIDTH)
    p.text:SetJustifyH(justify or "CENTER")

    p.onConfirm = onConfirm
    p.onCancel = onCancel
    p.icon = icon
    p.sound = sound
    p.onClick = onClick
    p.onClickArgs = {...}

    tinsert(popups, p)
    p.index = #popups
    ShowPopups(true)
end

---------------------------------------------------------------------
-- progress popup
---------------------------------------------------------------------
---@param text string
---@param maxValue number
---@param icon? string|number if starts with "!", will show a transparent icon bg instead of black
---@param sound? string
---@param width? number default 220
---@param justify? string default "CENTER"
---@param onClick? fun(popup:AF_BorderedFrame, button:string, ...:any)
---@param ... any arguments to pass to the onClick function
function AF.ShowProgressPopup(text, maxValue, icon, sound, width, justify, onClick, ...)
    local p = progressPool:Acquire()
    AF.SetWidth(p, width or DEFAULT_WIDTH)
    p.text:SetText(text)
    p.text:SetJustifyH(justify or "CENTER")
    p.bar:SetMinMaxSmoothedValue(0, maxValue)
    p.bar:SetBarValue(0)

    p.icon = icon
    p.sound = sound
    p.onClick = onClick
    p.onClickArgs = {...}

    tinsert(popups, p)
    p.index = #popups
    ShowPopups(true)

    return p.callback
end

---------------------------------------------------------------------
-- setup
---------------------------------------------------------------------
---@private
---@param config table {position = {anchor, x, y}, orientation = "bottom_to_top"|"top_to_bottom"}
function AF.SetupPopups(config)
    if not parent then
        CreateParent()
        AF.CreateMover(parent, L["Popups"], L["Popups"], AFConfig.popups.position)
    end

    assert(type(config) == "table", "AF.SetupPopups: config must be a table")
    AFConfig.popups.position = config.position or DEFAULT_SETTINGS.position
    AFConfig.popups.orientation = config.orientation or DEFAULT_SETTINGS.orientation

    AF.LoadPosition(parent, AFConfig.popups.position)
    parent.orientation = AFConfig.popups.orientation

    ShowPopups(true)
end