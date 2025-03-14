---@class BFC
local BFC = select(2, ...)

local UpdateStatus
local currentStatus = "unknown"
local MESSAGE = "<" .. BFC.displayedName .. "> 你好，我在魔兽工坊看到了你的工匠信息，请问现在方便制作装备么？"

---------------------------------------------------------------------
-- message frame
---------------------------------------------------------------------
local messageFrame
local editbox, checkStatusButton, statusTexture, statusText, sendButton

local function CreateMessageFrame()
    messageFrame = CreateFrame("Frame", "BFC_MessageFrame", BFC_MainFrame, "SettingsFrameTemplate") -- PortraitFrameTemplate
    messageFrame:SetFrameStrata("HIGH")
    messageFrame:Hide()

    -- base
    messageFrame:SetSize(200, 160)
    messageFrame:SetPoint("TOPLEFT", BFC_MainFrame, "TOPRIGHT", 5, 0)
    messageFrame:EnableMouse(true)

    -- script
    messageFrame:SetScript("OnShow", function()
        messageFrame:RegisterEvent("CHAT_MSG_SYSTEM")
    end)
    messageFrame:SetScript("OnHide", function()
        messageFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
        messageFrame:Hide()
    end)
    messageFrame:SetScript("OnEvent", function(_, event, message)
        if messageFrame.shortName and message == ERR_CHAT_PLAYER_NOT_FOUND_S:format(messageFrame.shortName) then
            currentStatus = "offline"
        end
    end)

    -- title
    messageFrame.NineSlice.Text:SetText("工匠")

    -- editbox
    editbox = CreateFrame("EditBox", nil, messageFrame, "InputBoxTemplate")
    editbox:SetPoint("TOPLEFT", 20, -35)
    editbox:SetPoint("TOPRIGHT", -10, -35)
    editbox:SetHeight(25)
    editbox:SetAutoFocus(false)

    -- check status button
    checkStatusButton = CreateFrame("Button", nil, messageFrame, "UIPanelButtonTemplate")
    checkStatusButton:SetPoint("TOPLEFT", editbox, "BOTTOMLEFT", -7, -5)
    checkStatusButton:SetPoint("TOPRIGHT", editbox, "BOTTOMRIGHT", 0, -5)
    checkStatusButton:SetHeight(25)
    checkStatusButton:SetText("查看是否在线")
    checkStatusButton:SetScript("OnClick", function()
        currentStatus = "checking"
        C_ChatInfo.SendAddonMessage("BFC", "CHECK_STATUS", "WHISPER", messageFrame.fullName)
        checkStatusButton:SetEnabled(false)
        C_Timer.After(1, function()
            checkStatusButton:SetEnabled(true)
            if currentStatus ~= "offline" and currentStatus ~= "unknown" then
                currentStatus = "online"
            end
            UpdateStatus()
        end)
    end)

    -- status texture
    statusTexture = messageFrame:CreateTexture(nil, "ARTWORK")
    statusTexture:SetPoint("TOPLEFT", checkStatusButton, "BOTTOMLEFT", 2, -7)
    statusTexture:SetPoint("TOPRIGHT", checkStatusButton, "BOTTOMRIGHT", -2, -7)
    statusTexture:SetColorTexture(0.25, 0.25, 0.25, 1)
    statusTexture:SetHeight(20)

    -- status text
    statusText = messageFrame:CreateFontString(nil, "OVERLAY", "BFC_FONT_WHITE")
    statusText:SetPoint("LEFT", statusTexture)
    statusText:SetPoint("RIGHT", statusTexture)

    -- send whisper
    sendButton = CreateFrame("Button", nil, messageFrame, "UIPanelButtonTemplate")
    sendButton:SetPoint("TOPLEFT", checkStatusButton, "BOTTOMLEFT", 0, -34)
    sendButton:SetPoint("TOPRIGHT", checkStatusButton, "BOTTOMRIGHT", 0, -34)
    sendButton:SetHeight(25)
    sendButton:SetText("发送消息询问")
    sendButton:SetScript("OnClick", function()
        SendChatMessage(MESSAGE, "WHISPER", nil, messageFrame.fullName)
        sendButton:SetEnabled(false)
        C_Timer.After(10, function()
            if currentStatus == "online" then
                sendButton:SetEnabled(true)
            end
        end)
    end)
end

function UpdateStatus()
    if currentStatus == "unknown" then
        statusTexture:SetColorTexture(0.1, 0.1, 0.1, 0.9)
        statusText:SetText("未知")
    elseif currentStatus == "offline" then
        statusTexture:SetColorTexture(0.25, 0.25, 0.25, 0.9)
        statusText:SetText("离线")
    else -- online
        statusTexture:SetColorTexture(0.1, 0.5, 0.1, 0.9)
        statusText:SetText("在线")
    end
    sendButton:SetEnabled(currentStatus == "online")
end

function BFC.ShowMessageFrame(shortName, fullName)
    if not messageFrame then
        CreateMessageFrame()
    end
    messageFrame:Show()

    if messageFrame.shortName == shortName and messageFrame.fullName == fullName then
        return
    end

    currentStatus = "unknown"
    messageFrame.shortName = shortName
    messageFrame.fullName = fullName
    editbox:SetText(fullName)
    UpdateStatus()
end

function BFC.HideMessageFrame()
    if not messageFrame then return end
    messageFrame.shortName = nil
    messageFrame.fullName = nil
    messageFrame:Hide()
end