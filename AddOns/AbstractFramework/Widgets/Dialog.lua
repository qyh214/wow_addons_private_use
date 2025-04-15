---@class AbstractFramework
local AF = _G.AbstractFramework

---------------------------------------------------------------------
-- dialog
---------------------------------------------------------------------
---@class AF_Dialog
local dialog

local function CreateDialog()
    dialog = AF.CreateBorderedFrame(AF.UIParent, "AF_Dialog", 200, 100, nil, "accent")
    dialog:Hide() -- for first OnShow

    dialog:EnableMouse(true)
    dialog:SetClampedToScreen(true)

    -- text holder
    local textHolder = AF.CreateFrame(dialog)
    dialog.textHolder = textHolder
    AF.SetPoint(textHolder, "TOPLEFT", 7, -7)
    AF.SetPoint(textHolder, "TOPRIGHT", -7, -7)

    local text = AF.CreateFontString(textHolder)
    dialog.text = text
    AF.SetPoint(text, "TOPLEFT")
    AF.SetPoint(text, "TOPRIGHT")
    text:SetWordWrap(true)
    text:SetSpacing(3)

    -- frame holder
    local contentHolder = AF.CreateFrame(dialog)
    dialog.contentHolder = contentHolder
    AF.SetPoint(contentHolder, "TOPLEFT", textHolder, "BOTTOMLEFT", 7, -7)
    AF.SetPoint(contentHolder, "TOPRIGHT", textHolder, "BOTTOMRIGHT", -7, -7)

    -- no
    local no = AF.CreateButton(dialog, _G.NO, "red", 50, 17)
    dialog.no = no
    AF.SetPoint(no, "BOTTOMRIGHT")
    no:SetBackdropBorderColor(AF.GetColorRGB("accent"))
    AF.ClearPoints(no.text)
    AF.SetPoint(no.text, "CENTER")
    no:SetScript("OnClick", function()
        if dialog.onCancel then dialog.onCancel() end
        dialog:Hide()
    end)

    -- yes
    local yes = AF.CreateButton(dialog, _G.YES, "green", 50, 17)
    dialog.yes = yes
    AF.SetPoint(yes, "BOTTOMRIGHT", no, "BOTTOMLEFT", 1, 0)
    yes:SetBackdropBorderColor(AF.GetColorRGB("accent"))
    AF.ClearPoints(yes.text)
    AF.SetPoint(yes.text, "CENTER")
    yes:SetScript("OnClick", function()
        if dialog.onConfirm then dialog.onConfirm() end
        dialog:Hide()
    end)

    -- OnHide
    dialog:SetScript("OnHide", function()
        dialog:Hide()

        -- reset
        dialog.minButtonWidth = nil
        dialog.onConfirm = nil
        dialog.onCancel = nil

        -- reset text
        text:SetText()
        textHolder:SetHeight(0)

        -- reset content
        if dialog.content then
            dialog.content:ClearAllPoints()
            dialog.content:Hide()
            dialog.content = nil
        end
        contentHolder:SetHeight(0)

        -- reset button
        yes:SetEnabled(true)
        yes:SetText(_G.YES)
        AF.SetWidth(yes, 50)
        no:SetText(_G.NO)
        AF.SetWidth(no, 50)

        -- hide mask
        if dialog.shownMask then
            dialog.shownMask:Hide()
            dialog.shownMask = nil
        end
    end)

    -- OnShow
    dialog:SetScript("OnShow", function()
        dialog:SetScript("OnUpdate", function()
            if text:GetText() then
                --! NOTE: text width must be set, and its x/y offset should be 0 (not sure), or WEIRD ISSUES would a appear.
                text:SetWidth(Round(dialog:GetWidth() - 14))
                textHolder:SetHeight(Round(text:GetHeight()))
            end
            if dialog.content then
                contentHolder:SetHeight(Round(dialog.content:GetHeight()))
            end
            dialog:SetHeight(Round(textHolder:GetHeight() + contentHolder:GetHeight()) + 40)
            dialog:SetScript("OnUpdate", nil)
        end)
    end)

    -- update pixels
    function dialog:UpdatePixels()
        AF.ReSize(dialog)
        AF.RePoint(dialog)
        AF.ReBorder(dialog)

        if dialog:IsShown() then
            dialog:GetScript("OnShow")()
        end

        if dialog.minButtonWidth then
            AF.ResizeDialogButtonToFitText(dialog.minButtonWidth)
        end
    end
end

-- show
---@param parent Frame
---@param text string
---@param width? number default 200
---@param yesText? string default YES
---@param noText? string default NO
---@param showMask? boolean
---@param content? Frame
---@param yesDisabled? boolean
---@return AF_Dialog
function AF.ShowDialog(parent, text, width, yesText, noText, showMask, content, yesDisabled)
    if not dialog then CreateDialog() end

    dialog:SetParent(parent)
    AF.SetFrameLevel(dialog, 50, parent)
    AF.SetWidth(dialog, width or 200)

    dialog.text:SetText(text)

    if yesText then dialog.yes:SetText(yesText) end
    if noText then dialog.no:SetText(noText) end

    if showMask then
        dialog.shownMask = AF.ShowMask(parent)
    end

    if content then
        dialog.content = content
        content:SetPoint("TOPLEFT")
        content:SetPoint("TOPRIGHT")
        content:Show()
    end

    dialog.yes:SetEnabled(not yesDisabled)
    dialog:Show()

    return dialog
end

-- point
function AF.SetDialogPoint(...)
    AF.ClearPoints(dialog)
    AF.SetPoint(dialog, ...)
end

-- resize yes/no
function AF.ResizeDialogButtonToFitText(minWidth)
    dialog.minButtonWidth = minWidth or 0
    local yesWidth = Round(dialog.yes.text:GetWidth()) + 10
    local noWidth = Round(dialog.no.text:GetWidth()) + 10
    if minWidth then
        yesWidth = max(minWidth, yesWidth)
        noWidth = max(minWidth, noWidth)
    end
    dialog.yes:SetWidth(yesWidth)
    dialog.no:SetWidth(noWidth)
end

-- content in contentHolder
function AF.CreateDialogContent(height)
    assert(height, "height is required")
    if not dialog then CreateDialog() end
    local f = AF.CreateFrame(dialog.contentHolder)
    f:Hide()
    AF.SetHeight(f, height)
    f.dialog = dialog
    return f
end

-- onConfirm
function AF.SetDialogOnConfirm(fn)
    dialog.onConfirm = fn
end

-- onCancel
function AF.SetDialogOnCancel(fn)
    dialog.onCancel = fn
end

---------------------------------------------------------------------
-- notification dialog
---------------------------------------------------------------------
local notificationDialogQueue = AF.NewQueue()

---@class AF_NotificationDialog:AF_BorderedFrame
local notificationDialog

local function CreateNotificationDialog()
    notificationDialog = AF.CreateBorderedFrame(AF.UIParent, "AF_NotificationDialog", 200, 100, nil, "accent")
    notificationDialog:Hide() -- for first OnShow

    notificationDialog:EnableMouse(true)
    notificationDialog:SetClampedToScreen(true)

    -- text holder
    local textHolder = AF.CreateFrame(notificationDialog)
    notificationDialog.textHolder = textHolder
    AF.SetPoint(textHolder, "TOPLEFT", 7, -7)
    AF.SetPoint(textHolder, "TOPRIGHT", -7, -7)

    local text = AF.CreateFontString(textHolder)
    notificationDialog.text = text
    AF.SetPoint(text, "TOPLEFT")
    AF.SetPoint(text, "TOPRIGHT")
    text:SetWordWrap(true)
    text:SetSpacing(3)

    -- close
    local close = AF.CreateButton(notificationDialog, _G.HELP_TIP_BUTTON_GOT_IT, "accent", 17, 17)
    notificationDialog.close = close
    AF.SetPoint(close, "BOTTOMLEFT", 5, 5)
    AF.SetPoint(close, "BOTTOMRIGHT", -5, 5)
    close:SetScript("OnClick", function()
        notificationDialog:Hide()
    end)

    -- OnHide
    notificationDialog:SetScript("OnHide", function()
        notificationDialog:Hide()

        -- reset text
        text:SetText()
        textHolder:SetHeight(0)

        -- reset timer
        if notificationDialog.timer then
            notificationDialog.timer:Cancel()
            notificationDialog.timer = nil
        end

        -- hide mask
        if notificationDialog.shownMask then
            notificationDialog.shownMask:Hide()
            notificationDialog.shownMask = nil
        end
    end)

    -- OnShow
    notificationDialog:SetScript("OnShow", function()
        notificationDialog:SetScript("OnUpdate", function()
            if text:GetText() then
                --! NOTE: text width must be set, and its x/y offset should be 0 (not sure), or WEIRD ISSUES would a appear.
                text:SetWidth(Round(notificationDialog:GetWidth() - 14))
                textHolder:SetHeight(Round(text:GetHeight()))
            end
            notificationDialog:SetHeight(Round(textHolder:GetHeight()) + 40)
            notificationDialog:SetScript("OnUpdate", nil)
        end)
    end)

    -- update pixels
    function notificationDialog:UpdatePixels()
        AF.ReSize(notificationDialog)
        AF.RePoint(notificationDialog)
        AF.ReBorder(notificationDialog)

        if notificationDialog:IsShown() then
            notificationDialog:GetScript("OnShow")()
        end
    end
end

-- show
---@param parent Frame
---@param text string
---@param width? number default 200
---@param showMask? boolean
---@param countdown? number
---@return AF_NotificationDialog
function AF.ShowNotificationDialog(parent, text, width, showMask, countdown)
    if not notificationDialog then CreateNotificationDialog() end

    notificationDialog:SetParent(parent)
    AF.SetFrameLevel(notificationDialog, 50, parent)
    AF.SetWidth(notificationDialog, width or 200)

    notificationDialog.text:SetText(text)

    if showMask then
        notificationDialog.shownMask = AF.ShowMask(parent)
    end

    if countdown then
        notificationDialog.close:SetEnabled(false)
        notificationDialog.close:SetText(_G.HELP_TIP_BUTTON_GOT_IT .. " (" .. countdown .. ")")
        notificationDialog.timer = C_Timer.NewTicker(1, function()
            notificationDialog.timer = nil
            countdown = countdown - 1
            if countdown == 0 then
                notificationDialog.close:SetText(_G.HELP_TIP_BUTTON_GOT_IT)
                notificationDialog.close:SetEnabled(true)
            else
                notificationDialog.close:SetText(_G.HELP_TIP_BUTTON_GOT_IT .. " (" .. countdown .. ")")
            end
        end, countdown)
    else
        notificationDialog.close:SetEnabled(true)
    end

    notificationDialog:Show()

    return notificationDialog
end

-- point
function AF.SetNotificationDialogPoint(...)
    AF.ClearPoints(notificationDialog)
    AF.SetPoint(notificationDialog, ...)
end