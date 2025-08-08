local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local CaCLFrame
local CHAT_TYPES = {
    "SYSTEM", "SAY", "PARTY", "RAID", "RAID_LEADER", "GUILD", "OFFICER", "YELL", "WHISPER", 
    "WHISPER_INFORM", "BN_WHISPER", "REPLY", "EMOTE", "TEXT_EMOTE", "CHANNEL", "AFK", "DND",
    "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "CHANNEL1", "CHANNEL2", "CHANNEL3",
    "CHANNEL4", "CHANNEL5", "CHANNEL6", "CHANNEL7", "CHANNEL8", "CHANNEL9", "CHANNEL10"
}

local function hasPotentialLink(text)
    return text:find("http[%w]*://") or text:find("www%.") or text:find("%S+@%S+%.%a%a") or text:find("%f[%a%d][%w_.%-]+%.%a%a")
end

local function formatURL(url)
    return "|cff00ccff|Hurl:" .. url .. "|h" .. url .. "|h|r"
end

local function processMessage(text)
    local result = ""
    local pos = 1
    local textLen = #text

    while pos <= textLen do
        local s, e, link

        s, e, link = text:find("(%a[%w+.-]+://%S+)", pos) -- protocol

        if not s then
            s, e, link = text:find("(www%S+)", pos) -- www
        end

        if not s then
            s, e, link = text:find("(%S+@[%w_.%-]+%.%a%a+)", pos) -- email
        end        

        if not s then
            s, e, link = text:find("([-%w_%.]+%.%a%a+%S*)", pos) -- short
        end

        if s then
            result = result .. text:sub(pos, s - 1) .. formatURL(link)
            pos = e + 1
        else
            result = result .. text:sub(pos)
            break
        end
    end

    return result
end

local function makeClickable(self, event, msg, sender, languageName, channelName, ...)
    if channelName and channelName:lower():find("dienste") then
        return false, msg, sender, languageName, channelName, ...
    end

    if ns.Addon.db.profile.CreateAndCopyLinks and hasPotentialLink(msg) then
        msg = processMessage(msg)
    end

    return false, msg, sender, languageName, channelName, ...
end

local function AddMessage(self, text, ...)
  if not self._OriginalAddMessage then
      return
  end

  if ns.Addon.db.profile.CreateAndCopyLinks then
      if ns.questID then
          text = text:gsub("https://www.wowhead.com/quest=" .. ns.questID, "|cff00ccff|Hurl:%1|h%1|h|r")
      end
      if ns.achievementID then
          text = text:gsub("https://www.wowhead.com/achievement=" .. ns.achievementID, "|cff00ccff|Hurl:%1|h%1|h|r")
      end
  end

  return self._OriginalAddMessage(self, text, ...)
end

local function URLClicker_OnHyperlinkShow(self, link)
    if ns.Addon.db.profile.CreateAndCopyLinks and link:sub(1, 3) == "url" then
        if CaCLFrame then
            CaCLFrame:Show()
            CaCLFrame.editBox:SetText(link:sub(5))
            CaCLFrame.editBox:HighlightText()
        end
    end
end

function ns.CreateAndCopyLink()
    if ns._CreateAndCopyLinkEnabled then return end

    CaCLFrame = CreateFrame("Frame", "CaCLFrame", UIParent, "DialogBoxFrame")
    CaCLFrame:SetSize(400, 130)
    CaCLFrame:SetPoint("TOP", 0, -300)
    CaCLFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    CaCLFrame:SetBackdropBorderColor(0, 0, 0, 1)
    CaCLFrame:SetMovable(true)
    CaCLFrame:EnableMouse(true)
    CaCLFrame:RegisterForDrag("LeftButton")
    CaCLFrame:SetScript("OnDragStart", CaCLFrame.StartMoving)
    CaCLFrame:SetScript("OnDragStop", CaCLFrame.StopMovingOrSizing)
    CaCLFrame.text = CaCLFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    CaCLFrame.text:SetPoint("TOP", 0, -15)
    CaCLFrame.text:SetText("|cffff0000Map|r|cff00ccffNotes|r\n" .. L["Use CTRL + C to copy the link"] .. "\n" .. L["The window closes automatically after copying"])
    CaCLFrame.editBox = CreateFrame("EditBox", nil, CaCLFrame, "InputBoxTemplate")
    CaCLFrame.editBox:SetSize(370, 30)
    CaCLFrame.editBox:SetPoint("CENTER", 0, -3)
    CaCLFrame.editBox:SetAutoFocus(true)
    CaCLFrame.editBox:SetFontObject(GameFontHighlight)
    CaCLFrame.editBox:SetScript("OnEscapePressed", function() CaCLFrame:Hide() end)
    CaCLFrame.editBox:SetScript("OnKeyUp", function(self, key)
        if IsControlKeyDown() and key == "C" then
            CaCLFrame:Hide()
        end
    end)

    for _, chatType in ipairs(CHAT_TYPES) do
        ChatFrame_AddMessageEventFilter("CHAT_MSG_" .. chatType, makeClickable)
    end

    for i = 1, NUM_CHAT_WINDOWS do
        local chatframe = _G["ChatFrame" .. i]
        if not chatframe._OriginalAddMessage then
            chatframe._OriginalAddMessage = chatframe.AddMessage
            chatframe.AddMessage = AddMessage
        end
    end

    hooksecurefunc("ChatFrame_OnHyperlinkShow", URLClicker_OnHyperlinkShow)

    ns._CreateAndCopyLinkEnabled = true
end

function ns.DisableCreateAndCopyLink()
    if not ns._CreateAndCopyLinkEnabled then return end

    for _, chatType in ipairs(CHAT_TYPES) do
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_" .. chatType, makeClickable)
    end

    for i = 1, NUM_CHAT_WINDOWS do
        local chatframe = _G["ChatFrame" .. i]
        if chatframe._OriginalAddMessage then
            chatframe.AddMessage = chatframe._OriginalAddMessage
            chatframe._OriginalAddMessage = nil
        end
    end

    if CaCLFrame then
        CaCLFrame:Hide()
    end

    ns._CreateAndCopyLinkEnabled = false
end

function ns.ToggleCreateAndCopyLink()
    if ns.Addon.db.profile.CreateAndCopyLinks then
        ns.CreateAndCopyLink()
    else
        ns.DisableCreateAndCopyLink()
    end
end